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
import serv.common.ResvTime;
import serv.common.ChkTime;
import serv.common.Constants;
/**
 * Servlet implementation class for Servlet: InitResvTimeServlet
 *
 */
 public class ClrResvTimeServlet extends DBServlet {	 
	 private static String cName = "/LHServ/ClrResvTimeServlet";
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
	    
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
		
	    String project = req.getParameter("Project");
	    String chkMonth = req.getParameter("chkMonth");
	    String chkYear = req.getParameter("chkYear");
	    String mnthDate = chkYear+"-"+chkMonth+"-01";
	    String[] chkDocNo = req.getParameterValues("docNo");
	    String docNo="";
		//------ forward page --------//
		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_ResvTimeLst.jsp?Project="+project+"&chkMonth="+chkMonth+"&chkYear="+chkYear;
		String errorPage = successPage + "&error=1"; 		
		String otherMsg = "";
		String errorCode = "";
		
	    Connection conn = null;
	    Statement stmt = null;
	    try {
	        if (ds == null)
	            getDS();
	        conn = ds.getConnection();
	        conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	        conn.setAutoCommit(false);
	        stmt = conn.createStatement();

	        //SERV_CHKUPHD
	        if (chkDocNo != null) {
	        	for (int i=0; i<chkDocNo.length; i++) {
	        		docNo = doString.checkString(chkDocNo[i]);
	    	        stmt.executeUpdate("DELETE FROM lan:serv_chkuphd WHERE i_chkupno = '"+docNo+"'");
	    	        stmt.executeUpdate("DELETE FROM lan:serv_chkupdt WHERE i_chkupno = '"+docNo+"'");
	        	}// end for
	        }
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
			} catch (Exception ignore) {}	    	
	        System.out.println("ERROR /LHServ/ClrResvTimeServlet : " + e.getMessage());
	        genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ "+e.getMessage());
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