package serv.servlets;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

import com.lh.servlet.DBServlet;
import com.lh.util.doString;

public class SERV_INFDenyServlet extends DBServlet  {
	
	public void performTask(HttpServletRequest req, HttpServletResponse res)throws ServletException, IOException {
		String mName = new String(this.getClass().getName() + ".performTask: ");
		System.out.println(mName + "start.");
		String mode = doString.checkString(req.getParameter("Mode"));
		
		String empId = doString.checkString(req.getParameter("i_employ"));
		String project = doString.checkString(req.getParameter("sel_project"));
		String vendor = doString.checkString(req.getParameter("i_vendor"));
		
		String start_date = doString.checkString(req.getParameter("start_date"));
		String start_month = doString.checkString(req.getParameter("start_month"));
		String start_year = doString.checkString(req.getParameter("start_year"));
		
		String end_date = doString.checkString(req.getParameter("end_date"));
		String end_month = doString.checkString(req.getParameter("end_month"));
		String end_year = doString.checkString(req.getParameter("end_year"));

		String pay_date = doString.checkString(req.getParameter("pay_date"));
		String pay_month = doString.checkString(req.getParameter("pay_month"));
		String pay_year = doString.checkString(req.getParameter("pay_year"));
		String payDate = pay_year+"-"+pay_month+"-"+pay_date;
		
		String params = "sel_project="+project+"&i_vendor="+vendor+"&start_date="+start_date+"&start_month="+start_month+"&start_year="+start_year+"&end_date="+end_date+"&end_month="+end_month+"&end_year="+end_year;
		
		Connection conn = null;
		Statement stmt = null;
		try {
			if (ds == null)
				getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
			stmt = conn.createStatement();
			
			String[] doc_list = req.getParameterValues("chkDoc");
			String docNo = "";
			if (mode.equals("D")) { //Deny
				if (doc_list != null) {
					for (int i=0; i<doc_list.length; i++) {
						docNo = doString.checkString(doc_list[i]);
						if (!docNo.equals("")) {
							stmt.executeUpdate("UPDATE lan:serv_infpayment SET f_itmstatus = 'CAN' WHERE i_docno = '"+docNo+"'");
							stmt.executeUpdate("UPDATE lan:serv_infdochd SET d_cancel = TODAY, f_status = 'CAN', i_employ_cancel = '"+empId+"' WHERE i_docno = '"+docNo+"'");
						}
					}//end for
				}
			} else { //Move
				if (doc_list != null) {
					for (int i=0; i<doc_list.length; i++) {
						docNo = doString.checkString(doc_list[i]);
						if (!docNo.equals("")) {
							stmt.executeUpdate("UPDATE lan:serv_infpayment SET d_payment = '"+payDate+"' WHERE i_docno = '"+docNo+"'");							
						}
					}//end for
				}
			}
			stmt.close();
			conn.close();
			stmt = null;
			conn = null;
		} catch (Exception e) {
       		System.out.println(" ERROR "+mName+" : " + e.getMessage());
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
		res.sendRedirect("/LHServ/SERV_INFDeny.jsp?"+params);
		System.out.println(mName + "end.");
	}
}