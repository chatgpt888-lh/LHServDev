package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.naming.*;

import com.lh.servlet.DBServlet;
import com.lh.exception.InvalidParameterException;
import com.lh.util.doString;
import com.lh.util.DateUtil;

import serv.common.User;
import serv.common.Cheque;
public class ConfRetentServlet extends DBServlet {
  private static String cName = "/LHServ/ConfRetentServlet";
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
    User user = (User) obj;
    String empId = user.getEmpId();
    String successPage = "";
    String errorPage = "";
    errorPage = "/LHServ/save_ok.jsp?redirect_url=SERV_RetenHome.jsp&error=true";
    String targetPage = "PrintPayInServlet";
    res.setContentType("text/html; charset=TIS620");
    PrintWriter out = res.getWriter();
        
    String docNo = req.getParameter("docNo");
	String comId = req.getParameter("comId");
	String projId = req.getParameter("projId");
	String lockId = req.getParameter("lockId");    
	String lorId = req.getParameter("lorId");    
	String payNo = req.getParameter("payNo");    
	String payType = req.getParameter("payType");
	String recvAmnt = "0";
	String cashFirm = req.getParameter("cashFirm");
	double cashAmnt = Double.parseDouble(doString.checkString(req.getParameter("cashAmnt"),"0"));
	
	String day = req.getParameter("Payday");
	String mnth = req.getParameter("Paymnth");
	String year = req.getParameter("Payyear");		
	String payDate = Integer.toString(Integer.parseInt(year)-543) + "-" + mnth + "-" + day;
	
	double accrue = Double.parseDouble(doString.checkString(req.getParameter("accrueAmnt"),"0"));
	Cheque cheques[] = new Cheque[MAX_CHEQUE];
	Cheque cheque = null;
	String lastCheque = "";
	String chequeId = "";
	String chqDate = "";
	String chqPayDate = "";	
	String bank = "";
	String branch = "";		
	String mType = "";
	boolean valid = false;
	double amount = 0;	
	double tot_amount = 0;
	String labelNo = req.getParameter("labelNo");
	String status = "P";
	if (accrue == 0) {
		status = "F";
		targetPage = "PrintRetRetenServlet";		
	} else {
		labelNo = "0";
	}
    successPage = "/LHServ/save_ok.jsp?redirect_url="+targetPage+"&comId=";
    successPage += comId +"&projId="+projId+"&docNo="+docNo;
    
	Calendar rightNow = Calendar.getInstance();
	String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
	int rowEffected = 0;
	StringBuffer sql = new StringBuffer();	
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    try {
        if (ds == null)
            getDS();
        conn = ds.getConnection();
        conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
        conn.setAutoCommit(false);
        stmt = conn.createStatement();
        
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
					try {
						chqDate = DateUtil.thaiToifxDate(chqDate);
					} catch (Exception e) {
						throw new InvalidParameterException("วันที่เช็คผิดพลาด");
					}								
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
						cheques[i] = new Cheque(chequeId, bank, branch, amount);		
						cheques[i].setChqDate(chqDate);
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
		cheques[0] = new Cheque(cashAmnt);		
		tot_amount += cashAmnt;
		recvAmnt = doString.displayNumber("#########.00", tot_amount);
		
		//RESV_RETHD
		sql.append("UPDATE lan:serv_rethd SET z_recv_reten = z_recv_reten + ")
						.append(recvAmnt)
						.append(", i_doc_status = '")
						.append(status)
						.append("', i_conf_payin = '")
						.append(empId)
						.append("', i_signboard = '")
						.append(labelNo)
						.append("', d_conf_payin = TODAY WHERE i_company = '")
						.append(comId)
						.append("' AND i_project = '")
						.append(projId)
						.append("' AND i_docno = '")
						.append(docNo+"'");
		rowEffected = stmt.executeUpdate(sql.toString());
		if (rowEffected != 1) {
			throw new Exception("SERV_RETHD : Wrong update count");
		}
		
		//RESV_RETDT		
		for (int i=0; i<MAX_CHEQUE; i++) {
			cheque = cheques[i];
			if (cheque != null) {				
				chequeId = cheque.getChequeId();
				if (chequeId.equals("")) {
					chequeId = "NULL";
				} else {
					chequeId = "'"+chequeId+"'";
				}
				bank = cheque.getBank();
				branch = cheque.getBranch();
				amount = cheque.getAmount();
				chqDate = cheque.getChqDate();
				if (amount > 0) {
					if (i==0) {
						mType = "1";
					} else {
						mType = "2";						
					}
			        sql.delete(0, sql.length());
					sql.append("INSERT INTO lan:serv_retdt(i_company, i_project, i_docno, i_lor, i_sort, s_payin, d_payin, i_due, i_mtype, d_receive, i_cheque, i_fbank, i_fbranch, z_amount) VALUES('")
							.append(comId)
							.append("', '")
							.append(projId)
							.append("', '")
							.append(docNo)
							.append("', ")
							.append(lorId)
							.append(", '")
							.append(lockId)							
							.append("', ")
							.append(payNo)
							.append(", '")
							.append(payDate)
							.append("', 'O5', '")
							.append(mType)
							.append("', '")
							.append(chqDate)
							.append("', ")
							.append(chequeId)
							.append(", '")							
							.append(bank)
							.append("', '")							
							.append(branch)
							.append("', ")														
							.append(amount)
							.append(")");							
					stmt.executeUpdate(sql.toString());
				}				
			}
        }// end of for cheques
   		
   		//SERV_PAYIN
   		sql.delete(0, sql.length());
		sql.append("UPDATE lan:serv_payin SET ");
		if (cashFirm.equals("false")) {
			sql.append("z_recv_reten = ")
				.append(recvAmnt)
				.append(", d_payin = '")
				.append(payDate)
				.append("', s_receive = 99, i_receipt = 9999999, ");
		}
		sql.append("i_serv_conf = '")
			.append(empId)
			.append("', d_serv_conf = TODAY WHERE i_company = '")
			.append(comId)
			.append("' AND i_project = '")
			.append(projId)	
			.append("' AND i_docno = '")
			.append(docNo)
			.append("' AND s_payin = ")
			.append(payNo);
		rowEffected = stmt.executeUpdate(sql.toString());
		if (rowEffected != 1) {
			throw new Exception("SERV_PAYIN : Wrong update count");
		}
		
		//SERV_SIGNB
		if (status.equals("F")) {
			stmt.executeUpdate("UPDATE lan:serv_signb SET d_beg_use = TODAY, f_use = 'A' WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_signb = '"+labelNo+"'");	
		}
		conn.commit();
        stmt.close();
        conn.close();
        stmt = null;
        conn = null;

        // forward to the success page.
        res.sendRedirect(successPage);
    } catch (InvalidParameterException e) {
	    showError(out, e.getMessage());        
    } catch (Exception e) {
	    try {
		    if (conn != null)
		    	conn.rollback();
	    } catch (SQLException ignore) {}
        System.out.println("ERROR /LHServ/ConfRetentServlet : " + e.getMessage());
        System.out.println("SQL ERROR /LHServ/ConfRetentServlet : " + sql.toString());
        res.sendRedirect(errorPage);
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