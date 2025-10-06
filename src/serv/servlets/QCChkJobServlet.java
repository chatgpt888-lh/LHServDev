package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;


import com.lh.servlet.DBServlet;
import com.lh.util.doString;

import serv.common.Constants;
import serv.common.User;
/**
 * Servlet implementation class for Servlet: ChckQCServlet
 *
 */
 public class QCChkJobServlet extends DBServlet {	 
	 private static String cName = "/LHServ/QCChkJobServlet";
	private void genRedirectCode(PrintWriter out,String page,String redirect,String error,String otherMsg) {
		out.println("<form method='post' action='"+page+"'>");		
		out.println("<input type='hidden' name='error' value='"+error+"'>");
		out.println("<input type='hidden' name='other_msg' value='"+doString.MS874ToUnicode(otherMsg)+"'>");
		out.println("<input type='hidden' name='redirect_url' value='"+doString.MS874ToUnicode(redirect)+"'>");		
		out.println("<script> document.forms[0].submit();</script>");
		out.println("</form>");		
	} 
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
		String sel_project = doString.checkString(req.getParameter("sel_project"));
	    String docNo = doString.checkString(req.getParameter("docNo"));
		String qcNo = "";
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
		
		//------ forward page --------//
		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_QCJobLst.jsp?sel_project="+sel_project;
		String errorPage = "SERV_QCJobLst.jsp?sel_project="+sel_project;
		String otherMsg = "";
		String errorCode = "";
		int rowEffected = 0;
	    Connection conn = null;
	    Statement stmt = null;
	    ResultSet rs =null;
	    try {
	        if (ds == null)
	            getDS();
	        conn = ds.getConnection();
	        conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	        conn.setAutoCommit(false);
	        stmt = conn.createStatement();
			
			rowEffected = stmt.executeUpdate("UPDATE lan:serv_dochd SET f_qc = 'N', qc_status = NULL, qc_date = NULL WHERE i_docno = '"+docNo+"'");
			if (rowEffected != 1) {
				throw new Exception("SERV_DOCHD : Wrong Update Count !!!");
			}
			rs = stmt.executeQuery("SELECT i_qcno FROM lan:serv_qchd WHERE i_docno = '"+docNo+"'");
			if (rs != null) {
				if (rs.next() == true) {
					qcNo = doString.checkString(rs.getString("I_QCNO"));
				}
				rs.close();
				rs=null;
			}
			stmt.executeUpdate("DELETE FROM lan:serv_qchd WHERE i_qcno = '"+qcNo+"'");
			stmt.executeUpdate("DELETE FROM lan:serv_qcdt WHERE i_qcno = '"+qcNo+"'");
			
	        conn.commit();
	        stmt.close();
	        conn.close();
	        stmt = null;
	        conn = null;
			genRedirectCode(out,savePage,successPage,errorCode,otherMsg);
	    } catch (Exception e) {
	    	try {
	    		if (conn != null)
	    			conn.rollback();
	    	} catch (SQLException ignore) {}
	        System.out.println("ERROR /LHServ/QCChkJobServlet : " + e.getMessage());
			genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ : "+e.getMessage());
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