package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.naming.*;
import com.lh.exception.InvalidParameterException;
import com.lh.servlet.DBServlet;
import com.lh.util.doString;
import com.lh.util.DateUtil;

import serv.common.User;
import serv.common.RetentDoc;
import serv.common.Cheque;
public class InitConfRetentServlet extends DBServlet {
  private static String cName = "/LHServ/InitConfRetentServlet";
  private int MAX_CHEQUE = 4;  
public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
    String mName = new String(cName + ".performTask: ");
    System.out.println(mName + "start.");

    HttpSession session = req.getSession(false);
    if (session == null) {
        /*
        * Redirect user to login page if
        * there's no session.
        */
        res.sendRedirect("/LHServ/warning.htm");
        return;
    }
    Object obj = session.getAttribute("USER");
    if (obj == null) {
        /*
        * Redirect user to login page if
        * there's no session.
        */
        res.sendRedirect("/LHServ/warning.htm");
        return;
    }
	RetentDoc retent_doc = (RetentDoc)session.getAttribute("retent_doc");
	if (retent_doc == null) {
		retent_doc = new RetentDoc();
	}
	Vector chequelist = retent_doc.getChequelist();
	chequelist.removeAllElements();
    res.setContentType("text/html; charset=TIS620");
    PrintWriter out = res.getWriter();    
    String docNo = req.getParameter("docNo");
	String comId = req.getParameter("comId");
	String projId = req.getParameter("projId");
	String targetPage = "/LHServ/SERV_Conf_Reten.jsp?comId="+comId+"&projId="+projId+"&docNo="+docNo;	
	String payType = req.getParameter("payType");
	double cashAmnt = Double.parseDouble(doString.checkString(req.getParameter("cashAmnt"),"0"));
	String day = req.getParameter("Payday");
	String mnth = req.getParameter("Paymnth");
	String year = req.getParameter("Payyear");		
	String payDate = Integer.toString(Integer.parseInt(year)-543) + "-" + mnth + "-" + day;
	
	Cheque cheque = null;
	String lastCheque = "";
	String chequeId = "";
	String chqDate = "";
	String bank = "";
	String branch = "";		
	String mType = "";
	boolean valid = false;
	double amount = 0;	
	double tot_amount = 0;
	String labelNo = doString.checkString(req.getParameter("labelNo"));
	
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    try {
        if (ds == null)
            getDS();
        conn = ds.getConnection();
        conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
        conn.setAutoCommit(true);
        stmt = conn.createStatement();

		retent_doc.setComId(comId);
		retent_doc.setProjId(projId);
		retent_doc.setDocNo(docNo);
		retent_doc.setPayType(payType);
		retent_doc.setPayDate(payDate);
		retent_doc.setLabelNo(labelNo);
		if (payType.equals("2") || payType.equals("3")) { //CHEQUE, CASH&CHEQUE
			for (int i=1; i<MAX_CHEQUE; i++) {
				valid = false;
				chequeId = getParameter(req, "Cheque_Id"+i, true, false, false, "", "");
				chqDate = getParameter(req, "chqDate"+i, true, false, false, "", "");
				bank = getParameter(req, "Bank"+i, true, false, false, "", "");
				branch = getParameter(req, "Branch"+i, true, false, false, "", "");
				branch = doString.UnicodeToMS874(branch);
				
				amount = Double.parseDouble(getParameter(req, "Cheque_Amt"+i, true, false, false, "0", ""));
				if ((amount > 0) && chequeId.equals("")) {
					throw new InvalidParameterException("โปรดระบุเลขที่เช็ค");
				}
				
				if (!chequeId.equals("")) {
					if (chequeId.equals(lastCheque)) {
						throw new InvalidParameterException("เลขที่เช็คซ้ำ");
					}
					lastCheque = chequeId;
					if (chqDate.equals("")) {
						throw new InvalidParameterException("โปรดระบุวันที่เช็ค");
					}
/*					
					try {
						chqDate = DateUtil.thaiToifxDate(chqDate);
					} catch (Exception e) {
						throw new InvalidParameterException("วันที่เช็คผิดพลาด");
					}								
*/					
				}
				
				if (!chequeId.equals("") || (amount > 0)) {
					valid = true;
/*					
					rs = stmt.executeQuery("SELECT n_finance FROM lan:acxfinan WHERE i_finance = '"+bank+"' AND i_branch = '"+branch+"' AND i_type = '1'");
					if (rs != null) {
						if (rs.next() == true) {
							valid = true;
						}
						rs.close();
						rs = null;
					}
*/					
					if (valid) {
						cheque = new Cheque(chequeId, bank, branch, amount);		
						cheque.setChqDate(chqDate);
						chequelist.addElement(cheque);
					} else {
						throw new InvalidParameterException("ไม่พบข้อมูลสาขาธนาคาร");
					}
				}
				tot_amount += amount;				
			}// end for
			if (tot_amount == 0) {
				throw new InvalidParameterException("โปรดระบุเช็ค");
			}
		}
		if (payType.equals("1") || payType.equals("3")) { //CASH, CASH&CHEQUE
			if (cashAmnt == 0) {
				throw new InvalidParameterException("โปรดระบุจำนวนเงินสด");				
			}
		} else { //CHEQUE
			cashAmnt = 0;
		}
		retent_doc.setCashAmnt(cashAmnt);
		session.setAttribute("retent_doc", retent_doc);
        stmt.close();
        conn.close();
        stmt = null;
        conn = null;
        
        // forward to the success page.
        res.sendRedirect(targetPage);
    } catch (InvalidParameterException e) {
	    showError(out, e.getMessage());              
    } catch (Exception e) {
        System.out.println("ERROR /LHServ/InitConfRetentServlet : " + e.getMessage());
    } finally {
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException ignore) {
            }
        }

        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException ignore) {
            }
        }
    }

    System.out.println(mName + "end.");
}
}