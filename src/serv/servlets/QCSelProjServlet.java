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
import serv.common.SERV_CommonData;
/**
 * Servlet implementation class for Servlet: ChckQCServlet
 *
 */
 public class QCSelProjServlet extends DBServlet {	 
	 private static String cName = "/LHServ/ChckQCServlet";
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
	    User user = (User)obj;
	    String sessionId = user.getsessionId();
	    String userId = user.getUserID();
	    String proj = "";
	    String comId = "";
	    String projId = "";
	    String rptType = doString.checkString(req.getParameter("rptType"));
	    String targetPage = "";
	    if (rptType.equals("P")) {
			targetPage = "SERV_QCByPrj.jsp";
	    }
		String[] projList = req.getParameterValues("sel_proj");
	    Connection conn = null;
	    Statement stmt = null;
	    try {
	        if (ds == null)
	            getDS();
	        conn = ds.getConnection();
	        conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	        conn.setAutoCommit(true);
	        stmt = conn.createStatement();
			
			stmt.executeUpdate("DELETE FROM lan:serv_chklock WHERE i_session = "+sessionId);
			if (projList!=null) {
				for (int i=0; i<projList.length; i++) {
					proj = doString.checkString(projList[i],"");
					if (!proj.equals("")) {
						comId = proj.substring(0,2);
						projId = proj.substring(3,6);
						stmt.executeUpdate("INSERT INTO lan:serv_chklock(i_session, user_id, i_company, i_project, i_lock, i_chkseq, f_status) VALUES("+sessionId+", '"+userId+"', '"+comId+"', '"+projId+"', '00000', 0, 'Q')");
					}
				}// end for				
			}
			
	        stmt.close();
	        conn.close();
	        stmt = null;
	        conn = null;
			// Redirect to the target page.
			ServletContext sc = getServletContext();
			RequestDispatcher rd = sc.getRequestDispatcher("/" + targetPage);
			rd.forward(req, res);	        
	    } catch (Exception e) {
	        System.out.println("ERROR /LHServ/QCSelProjServlet : " + e.getMessage());
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