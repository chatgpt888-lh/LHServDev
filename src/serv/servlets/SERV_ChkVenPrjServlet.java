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
public class SERV_ChkVenPrjServlet extends DBServlet  {
	
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
		doString str = new doString();		 		
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
		
		String mode = doString.checkString(req.getParameter("mode"), "");
		String selProj = doString.checkString(req.getParameter("sel_project"),"");
		String iType = doString.checkString(req.getParameter("i_type"),"");
		String iVendor = doString.checkString(req.getParameter("i_vendor"),"");
		String iGroup = doString.checkString(req.getParameter("i_group"),"");
		
		String savePage = Constants.SAVE_PAGE;
		String successPage = Constants.APP_PATH+"/SERV_ChkVenPrj.jsp?sel_project="+selProj+"&i_type="+iType;
		String errorPage = "SERV_ChkVenPrj01.jsp?sel_project="+selProj+"&i_type="+iType+"&i_vendor="+iVendor+"&error=1";
		String otherMsg = "";
		String errorCode = "";
    
       
	  	//---======== Get Item Details for show ===========---//
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
	
			sql.delete(0,sql.length());
			//----======== Add Mode , Insert Query =========----//
			if (mode.equalsIgnoreCase("ADD")) {
				if(selProj.length()>=6 && selProj!= null){

					String iCom = selProj.substring(0,2);
					String iProj = selProj.substring(3,6);
					//---======= i_company,i_project,i_type  is not exist ========---//
					sql.delete(0,sql.length());
					sql.append("insert into lan:serv_venprj (i_company,i_project,i_type,i_vendor,i_group ")
					   .append(" ) values ( ")
					   .append(" '").append(iCom).append("' , ")
					   .append(" '").append(iProj).append("' , ")
					   .append(" '").append(iType).append("' , ")
					   .append(" '").append(iVendor).append("' , ")
					   .append(" '").append(iGroup).append("' ")
					   .append(" ) ");					    
				    stmt.executeUpdate(sql.toString());
				    successPage = Constants.APP_PATH+"/SERV_ChkVenPrj.jsp?mode=add&sel_project="+selProj;							
				} else {
					//----========= i_company and i_project  is exist , return to input page =========--//	
					successPage = errorPage;
					errorCode = "1";
					otherMsg = "พบข้อผิดพลาดในระบบ กรุณาดำเนินการใหม่อีกครั้ง !" ;
				}
			}//end  add mode
			
			//----======== Delete Mode , Insert Query =========----//
			else if (mode.equalsIgnoreCase("DELETE")) {		
				
				 successPage = Constants.APP_PATH+"/SERV_ChkVenPrj.jsp?sel_project="+selProj+"&i_type="+iType;
				 savePage = Constants.APP_PATH+"/SERV_ChkVenPrj.jsp?sel_project="+selProj+"&i_type="+iType;
				 errorPage = Constants.APP_PATH+"/SERV_ChkVenPrj.jsp?error=1&sel_project="+selProj+"&i_type="+iType;
	 
				 String ttt = "";
				 String[] delid = req.getParameterValues("vend_code");
				 if (delid!=null) {
					 for (int i=0;i<delid.length;i++) {
							StringTokenizer id = new StringTokenizer(delid[i],":");
	 			 	 	    
							//---==== If i_company or i_project is missing , continue next data =====----//
							if (id.countTokens()!=4) continue;
	 			 	 	
							sql.delete(0,sql.length());
							sql.append("delete from lan:serv_venprj ")
								  .append(" where i_company ='").append(id.nextToken()).append("' ")
								  .append(" and i_project ='").append(id.nextToken()).append("' ")
								  .append(" and i_type ='").append(id.nextToken()).append("' ")
								  .append(" and i_vendor = '").append(id.nextToken()).append("' ");
					  
							
							stmt.executeUpdate(sql.toString());
					 } // end for
				 }
 			}
			//----========================================----//
			

			conn.commit();
			stmt.close();
			conn.close();
			conn = null;
			
			// Redirect to the finish page.
			//res.sendRedirect(doString.UnicodeToMS874(successPage));
			genRedirectCode(out,savePage,successPage,errorCode,otherMsg);

		} catch (Exception e) {
			if (e instanceof InvalidParameterException) {
				showError(out, doString.UnicodeToMS874(e.getMessage()));
			} else {
           
			System.out.println(" ERROR "+mName+" : " + e.getMessage());
			System.out.println(" ERROR "+mName+" SQL : " + sql.toString());
			}
			
			//res.sendRedirect(errorPage);
			System.out.println("error = "+errorPage);
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
