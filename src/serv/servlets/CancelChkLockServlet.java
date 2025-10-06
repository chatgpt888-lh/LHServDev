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
 public class CancelChkLockServlet extends DBServlet {	 
	 private static String cName = "/LHServ/CancelChkLockServlet";
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
	    String empId = user.getEmpId();
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
		
	    String project = req.getParameter("Project");
	    String comId = "";
	    String projId = "";
	    if (!project.equals("")) {
	    	comId = project.substring(0, 2);
	    	projId = project.substring(2);
	    }	    
	    String chkMonth = req.getParameter("chkMonth");
	    String chkYear = req.getParameter("chkYear");
	    String mnthDate = chkYear+"-"+chkMonth+"-01";
	    String[] chkLock = req.getParameterValues("chkLock");
	    String code = "";
	    String lockId = "";
	    String seqNo = "";
	    String docNo = "";
		//------ forward page --------//
		String savePage = Constants.SAVE_PAGE;
		String successPage = "InitChkLckServlet?Project="+project+"&chkMonth="+chkMonth+"&chkYear="+chkYear;
		String errorPage = successPage + "&error=1"; 		
		String otherMsg = "";
		String errorCode = "";
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

	        if (chkLock != null) {
	        	for (int i=0; i<chkLock.length; i++) {
	        		code = doString.checkString(chkLock[i]);
	        		if (!code.equals("")) {
	        			lockId = code.substring(0,5);
	        			seqNo = code.substring(5);
	        		}
	        		//SERV_CHKUPLCK
	        		docNo = "";
	    			sql.delete(0,sql.length());
	    			sql.append("SELECT i_docno FROM lan:serv_chkuplck WHERE i_month = '")
	    				.append(mnthDate)
	    				.append("' AND i_company = '")
	    				.append(comId)
	    				.append("' AND i_project = '")
	    				.append(projId)
	    				.append("' AND i_lock = '")
	    				.append(lockId)
	    				.append("' AND i_chkseq = ")
	    				.append(seqNo+" AND f_status = 'R'");
	        		rs = stmt.executeQuery(sql.toString());
	        		if (rs != null) {
	        			if (rs.next() == true) {
	        				docNo = doString.checkString(rs.getString("I_DOCNO"));
	        			}
	        			rs.close();
	        			rs=null;
	        		}
	        		
	    			sql.delete(0,sql.length());
	    			sql.append("DELETE FROM lan:serv_chkuplck WHERE i_month = '")
	    				.append(mnthDate)
	    				.append("' AND i_company = '")
	    				.append(comId)
	    				.append("' AND i_project = '")
	    				.append(projId)
	    				.append("' AND i_lock = '")
	    				.append(lockId)
	    				.append("' AND i_chkseq = ")
	    				.append(seqNo+" AND f_status = 'R'");
	    			rowEffected = stmt.executeUpdate(sql.toString());
	    	        if (rowEffected != 1) {
	    	        	throw new Exception("SERV_CHKUPLCK : Wrong update count");
	    	        }	    			
	    	        //SERV_CHKUPDT
	    			sql.delete(0,sql.length());
	    			sql.append("UPDATE lan:serv_chkupdt SET i_lock = NULL, i_chkseq = NULL, f_status = 'N' WHERE i_month = '")
	    				.append(mnthDate)
	    				.append("' AND i_company = '")
	    				.append(comId)
	    				.append("' AND i_project = '")
	    				.append(projId)
	    				.append("' AND i_lock = '")
	    				.append(lockId)
	    				.append("' AND i_chkseq = ")
	    				.append(seqNo);	    	        
	    	        stmt.executeUpdate(sql.toString());
	    	        
	    	        //SERV_DOCHD
	    	        stmt.executeUpdate("UPDATE lan:serv_dochd SET f_status = 'CAN', d_cancel = TODAY, i_employ_cancel = '"+empId+"' WHERE i_docno = '"+docNo+"'");
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
	        System.out.println("ERROR /LHServ/CancelChkLockServlet : " + e.getMessage());
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