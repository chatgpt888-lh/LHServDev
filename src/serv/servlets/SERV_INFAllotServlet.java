package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;
import java.awt.Color;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.naming.*;

import com.lh.servlet.DBServlet;
import com.lh.util.*;
import com.lh.exception.InvalidParameterException;

import serv.common.User;
import serv.common.Constants;
import serv.common.SERV_CommonData;

/**
 * @version 	1.0
 * @author
 */
public class SERV_INFAllotServlet extends DBServlet  {
	
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

  
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();

		String mode = doString.checkString(req.getParameter("mode"), "");
		String iGroup = doString.checkString(req.getParameter("i_group"),"");
		
		
		String selProj = doString.checkString(req.getParameter("sel_project"));
		String comId = "";
		String projId = "";
		if (!selProj.equals("")) {
			comId = selProj.substring(0,2);
			projId = selProj.substring(3);
		}		
		String iType = doString.checkString(req.getParameter("i_type"));
		String effctDate = "";		
		
		String savePage =Constants.SAVE_PAGE;
		String successPage = "SERV_INFAllot.jsp?sel_project="+selProj+"&i_type=0";
		String errorPage = successPage + "&error=1";		
		String otherMsg = "";
		String errorCode = "";
    
		StringBuffer sql = new StringBuffer();
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		SERV_CommonData common = null;
		 try {
			if (ds == null)
				getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
			common = new SERV_CommonData(conn);
			
			effctDate = common.getValueFromDateListbox("effct",req);
			sql.delete(0,sql.length());
		    //----======== Add Mode , Inseitrt Query =========----//
			if (mode.equalsIgnoreCase("A")) {
				sql.delete(0,sql.length());
				sql.append("insert into lan:serv_allot (i_company,i_project,i_type,d_effective")
						  .append(" ) values ( ")
						  .append(" '").append(comId).append("' , ") 
						  .append(" '").append(projId).append("' , ")
						  .append(" '").append(iType).append("' , ")
						  .append(" '").append(effctDate).append("' ")
						  .append(" ) "); 
				stmt.executeUpdate(sql.toString());
			} else if (mode.equalsIgnoreCase("D")) {	
	 			String[] delid = req.getParameterValues("delAllot");
	 			if (delid!=null) {
	 			 	 for (int i=0;i<delid.length;i++) {
	 			 	 	    StringTokenizer id = new StringTokenizer(delid[i],"|");
	 			 	 	    iType = id.nextToken();
	 			 	 	    effctDate = id.nextToken();
	 			 	 	
	 			 	 	    sql.delete(0,sql.length());
							sql.append("delete from lan:serv_allot ")
								  .append(" where i_company = '")
								  .append(comId)
								  .append("' and i_project = '")
								  .append(projId)
								  .append("' and i_type = '")
								  .append(iType)
								  .append("' and d_effective = '")
								  .append(effctDate)
								  .append("'");
							stmt.executeUpdate(sql.toString());
	 			 	 } // end for
	 			}
	 		}
			conn.commit();
			stmt.close();
			conn.close();
			conn = null;

			genRedirectCode(out,savePage,successPage,errorCode,otherMsg);
		} catch (Exception e) {
			if (e instanceof InvalidParameterException) {
				showError(out, doString.UnicodeToMS874(e.getMessage()));
			} else {           
				System.out.println(" ERROR "+mName+" : " + e.getMessage());
				System.out.println(" ERROR "+mName+" SQL : " + sql.toString());
			}
			genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ "+e.getMessage());
		} finally {
			out.close();
			try {
				if (rs!=null) rs.close(); 
				if (stmt != null) stmt.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");

	}

}
