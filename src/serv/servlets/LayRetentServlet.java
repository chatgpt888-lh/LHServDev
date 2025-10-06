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

import serv.common.User;
import serv.common.Vendor;
import serv.common.Document;
public class LayRetentServlet extends DBServlet {
  private static String cName = "/LHServ/LayRetentServlet";
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
    String successPage = "/LHServ/save_ok.jsp?redirect_url=PrintPayInServlet&comId=";
    String errorPage = successPage+"&error=true";
    
    Vendor vendor = (Vendor) session.getAttribute("Vendor");
    String docNo = req.getParameter("docNo");
    boolean found = false;
	String project = req.getParameter("Project");
	String comId = project.substring(0,2);
	String projId = project.substring(2);
	String houseNo = req.getParameter("houseNo");
	String lorNo = req.getParameter("lorNo");
	String lockId = req.getParameter("lockId");
	String modelId = req.getParameter("model");
	String custName = doString.UnicodeToMS874(req.getParameter("custName"));
	String retenType = req.getParameter("retenType");
	String customer = req.getParameter("Customer");
	String custTelNo = req.getParameter("telephone");	
	custTelNo = doString.UnicodeToMS874(custTelNo);
	String retentId = "";
	String venId = "";
	String venType = "";
	String pname = "";
	String name = "";
	String sname = "";
	String telephone = "";
	if (vendor != null) {
		venId = vendor.getId();
		pname = vendor.getPreName();
		name = vendor.getName();
		sname = vendor.getSurName();
		telephone = vendor.getTelephone();
	}
	String guarantee = req.getParameter("guarantee");
	guarantee = guarantee.substring(0,2);
	String retenAmount = req.getParameter("retenAmount");
	String day = req.getParameter("Conday");
	String mnth = req.getParameter("Conmnth");
	String year = req.getParameter("Conyear");		
	String begConDate = Integer.toString(Integer.parseInt(year)-543) + "-" + mnth + "-" + day;
	String conMnth = req.getParameter("conMnth");
	String comment = doString.UnicodeToMS874(req.getParameter("Comment"));
	comment = doString.TextToString(comment);
	
	//---- 2022-06-30 , for payin input ----//
	String iPayType = doString.checkString(req.getParameter("iPayType"),"PAYIN");
	String iPayBnk = doString.checkString(req.getParameter("iPayBnk"),"");
	String iPayAcc = doString.checkString(req.getParameter("iPayAcc"),"");
	String iEmail = doString.checkString(req.getParameter("iEmail"),"");
	//--------------------------------------//	
	
	Calendar rightNow = Calendar.getInstance();
	int curYear = rightNow.get(Calendar.YEAR);
	if (curYear<2400) curYear += 543;
	String cur_year = Integer.toString(curYear);
	//String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
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
        if (docNo.equals("")) {
			docNo = comId+projId+"-"+cur_year.substring(2)+doString.displayNumber("000", Document.getDocNo(comId, projId, "R", cur_year));
        } else {
        	found = true;
        }
	    successPage += comId +"&projId="+projId+"&docNo="+docNo;
	    errorPage = successPage+"&error=true";
		if (retenType.equals("1")) {
			venType = "04";
			retentId = customer;
		} else {
			if (venId.equals("Auto Generate")) {
				venId = cur_year.substring(2)+doString.displayNumber("000", Document.getDocNo(comId, projId, retenType, cur_year));
			}
			retentId = venId;
			if (retenType.equals("2")) {
				venType = "05";
			} else {
				venType = "06";				
			}
		}
		//RESV_RETHD
		if (found) {
				stmt.executeUpdate("DELETE FROM lan:serv_payin WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+docNo+"'");
				stmt.executeUpdate("DELETE FROM lan:serv_retdt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+docNo+"'");
	            sql.append("UPDATE lan:serv_rethd SET i_doc_status = 'N', s_payin = 0, i_doc_type = '")
						.append(guarantee)
						.append("', i_ret_custo = '")
						.append(retenType)
						.append("', i_reten = '")
						.append(retentId)
						.append("', i_reten_tel = '")
						.append(custTelNo)
						.append("', d_beg_cons = '")
						.append(begConDate)
						.append("', i_mon_cons = ")
						.append(conMnth)
						.append(", z_reten = ")
						.append(retenAmount)
						.append(", z_payin_reten = ")
						.append(retenAmount)
						.append(", c_advan = '")
						.append(comment)
						.append("', i_staff = '")
						.append(empId)
						.append("' ");
						//------ 2022-06-30 , add new field ------//
						if (iPayType.equalsIgnoreCase("PAYIN")) {
							sql.append(", i_paytype='PAYIN' ")						
							   .append(", i_paybnk='"+iPayBnk+"' ")						
							   .append(", i_payacc='"+iPayAcc+"' ")						
							   .append(", i_email='"+iEmail+"' ");					
						} else {
							sql.append(", i_paytype='PAYTO' ")						
							   .append(", i_paybnk=null ")						
							   .append(", i_payacc=null ")						
							   .append(", i_email=null ");
						}											
						//----------------------------------------//
				 	 sql.append(" WHERE i_company = '")
						.append(comId)
						.append("' AND i_project = '")
						.append(projId)	
						.append("' AND i_docno = '")
						.append(docNo+"'");
		} else {
			sql.append("INSERT INTO lan:serv_rethd(i_docno, i_company, i_project, i_sort, d_keyin, s_payin, i_doc_type, i_lor, n_custo, ")
			   .append(" i_model, i_house, i_ret_custo, i_reten, i_reten_tel, d_beg_cons, i_mon_cons, z_reten, z_payin_reten, z_recv_reten, ")
			   .append(" c_advan, i_staff, i_doc_status, i_paytype, i_paybnk, i_payacc, i_email ) VALUES( '")
				.append(docNo)
				.append("', '")
				.append(comId)
				.append("', '")
				.append(projId)
				.append("', '")
				.append(lockId)
				.append("', CURRENT, 0, '")
				.append(guarantee)
				.append("', ")
				.append(lorNo)
				.append(", '")
				.append(custName)
				.append("', '")
				.append(modelId)
				.append("', '")
				.append(houseNo)
				.append("', '")
				.append(retenType)
				.append("', '")
				.append(retentId)
				.append("', '")
				.append(custTelNo)
				.append("', '")			
				.append(begConDate)
				.append("', ")
				.append(conMnth)
				.append(", ")
				.append(retenAmount)
				.append(", ")
				.append(retenAmount)
				.append(", 0, '")
				.append(comment)
				.append("', '")
				.append(empId)
				.append("', 'N' ");
				//------ 2022-06-30 , add new field ------//
				if (iPayType.equalsIgnoreCase("PAYIN")) {
					sql.append(", 'PAYIN' ")						
					   .append(", '"+iPayBnk+"' ")						
					   .append(", '"+iPayAcc+"' ")						
					   .append(", '"+iEmail+"' ");					
				} else {
					sql.append(", 'PAYTO' ")						
					   .append(", null ")						
					   .append(", null ")						
					   .append(", null ");
				}
				//----------------------------------------//
			 sql.append(") ");
		}					
		rowEffected = stmt.executeUpdate(sql.toString());
		if (rowEffected != 1) {
			throw new Exception("SERV_RETHD : Wrong insert count");
		}
		
		//SERV_VENPRJ
		if (!retenType.equals("1")) {
			sql.delete(0, sql.length());
			rs = stmt.executeQuery("SELECT n_name FROM lan:serv_venprj WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_type = '"+venType+"' AND i_vendor = '"+venId+"'");
			if (rs != null) {
				if (rs.next() == true) { //UPDATE
	            sql.append("UPDATE lan:serv_venprj SET n_pname = '")
						.append(pname)
						.append("', n_name = '")
						.append(name)
						.append("', n_sname = '")
						.append(sname)
						.append("', i_tel = '")
						.append(telephone)
						.append("' WHERE i_company = '")
						.append(comId)
						.append("' AND i_project = '")
						.append(projId)	
						.append("' AND i_type = '")
						.append(venType)
						.append("' AND i_vendor = '")
						.append(venId+"'");
				} else {
					sql.append("INSERT INTO lan:serv_venprj(i_company, i_project, i_type, i_vendor, n_pname, n_name, n_sname, i_tel) VALUES('")
						.append(comId)
						.append("', '")
						.append(projId)
						.append("', '")
						.append(venType)
						.append("', '")
						.append(venId)
						.append("', '")
						.append(pname)
						.append("', '")
						.append(name)
						.append("', '")
						.append(sname)
						.append("', '")
						.append(telephone+"')");
				}
				rs.close();
				rs=null;
			}			
			rowEffected = stmt.executeUpdate(sql.toString());
			if (rowEffected != 1) {
				throw new Exception("SERV_VENPRJ : Wrong insert count");
			}
		}
		
		conn.commit();
		//conn.rollback();
        stmt.close();
        conn.close();
        stmt = null;
        conn = null;

        // forward to the success page.
        res.sendRedirect(successPage);
    } catch (Exception e) {
	    try {
		    if (conn != null)
		    	conn.rollback();
	    } catch (SQLException ignore) {}
        System.out.println("ERROR /LHServ/LayRetentServlet : " + e.getMessage());
        System.out.println("SQL ERROR /LHServ/LayRetentServlet : " + sql.toString());
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
