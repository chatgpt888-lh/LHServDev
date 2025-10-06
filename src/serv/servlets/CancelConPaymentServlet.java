package serv.servlets;

import java.io.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;

import com.lh.servlet.DBServlet;
import com.lh.util.*;

import serv.common.User;
import serv.common.Constants;

/**
 * @version 	1.0
 * @author
 */
public class CancelConPaymentServlet extends DBServlet  {
	
	private void genRedirectCode(PrintWriter out,String page,String redirect,String error,String otherMsg) {
		out.println("<form method='post' action='"+page+"'>");		
		out.println("<input type='hidden' name='error' value='"+error+"'>");
		out.println("<input type='hidden' name='other_msg' value='"+doString.MS874ToUnicode(otherMsg)+"'>");
		out.println("<input type='hidden' name='redirect_url' value='"+doString.MS874ToUnicode(redirect)+"'>");		
		out.println("<script> document.forms[0].submit();</script>");
		out.println("</form>");		
	}
	
	public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		String mName = new String(this.getClass().getName() + ".performTask: ");
		System.out.println(mName + "start.");

		//-----======= Check Login session =======-----//
		HttpSession session = req.getSession(false);
		if (session == null) {
			//---===== No Session , redirect to warning =======---// 
			res.sendRedirect(Constants.WARNING_PAGE);
			return;
		}
		Object obj = session.getAttribute("USER");
		if (obj == null) {
			//---===== Can't get User Login , redirect to warning ======---// 
			res.sendRedirect(Constants.WARNING_PAGE);
			return;
		}
		//----===================================----//	

		User user = (User) obj;
		String empId = user.getEmpId();
		
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
		String project = doString.checkString(req.getParameter("sel_project"));
		String docNo = doString.checkString(req.getParameter("docNo"));
		String comment = doString.UnicodeToMS874(doString.checkString(req.getParameter("Comment")));
		comment = doString.TextToString(comment);
		String comId = "";
		String projId = "";
		String orderNo = "";
		String dueNo = "";
		
		String savePage =Constants.SAVE_PAGE;
		String successPage = "SERV_ConDeny_Pay_List.jsp?sel_project="+project;
		String errorPage = successPage + "&error=1";		
		String otherMsg = "";
		String errorCode = "";
    
		StringBuffer sql = new StringBuffer();
		Connection conn = null;
		Statement stmt = null;
		Statement ustmt = null;
		ResultSet rs = null;
		 try {
			if (ds == null)
				getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
			ustmt = conn.createStatement();
			//SERV_INFDOCHD
			stmt.executeUpdate("UPDATE lan:serv_infdochd SET f_status = 'CAN', d_cancel = TODAY, i_employ_reject = '"+empId+"', c_reject = '"+comment+"' WHERE i_docno = '"+docNo+"'");
			
			//SERV_INFPAYMENT
			stmt.executeUpdate("UPDATE lan:serv_infpayment SET f_itmstatus = 'CAN' WHERE i_docno = '"+docNo+"'");

			//SERV_CONHD
			rs = stmt.executeQuery("SELECT i_company, i_project, i_order, s_due FROM lan:serv_infpayment WHERE i_docno = '"+docNo+"'");
			if (rs != null) {
				while (rs.next() == true) {
					comId = doString.checkString(rs.getString("I_COMPANY"));
					projId = doString.checkString(rs.getString("I_PROJECT"));
					orderNo = doString.checkString(rs.getString("I_ORDER"));
					dueNo = Integer.toString(rs.getInt("S_DUE"));
					ustmt.executeUpdate("UPDATE lan:serv_condt SET z_accrue = 0 WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+orderNo+"' AND s_due = "+dueNo);
				}// end while
				rs.close();
				rs=null;
			}
			conn.commit();
			stmt.close();
			ustmt.close();
			conn.close();
			stmt = null;
			ustmt = null;
			conn = null;
			genRedirectCode(out,savePage,successPage,errorCode,otherMsg);
		} catch (Exception e) {
			System.out.println(" ERROR "+mName+" : " + e.getMessage());
			System.out.println(" ERROR "+mName+" SQL : " + sql.toString());
			try {
				if (conn != null) conn.rollback();
			} catch (SQLException ignore) {}
			genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ "+e.getMessage());
		} finally {
			out.close();
			try {
				if (rs!=null) rs.close(); 
				if (stmt != null) stmt.close();
				if (ustmt != null) ustmt.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");
	}
}