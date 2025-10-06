package serv.servlets;

import java.io.*;
import java.text.*;
import java.util.*;
import java.sql.*;
import java.awt.Color;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.naming.*;

import com.lh.servlet.DBServlet;
import com.lh.util.*;
import com.lh.exception.InvalidParameterException;

import serv.common.Constants;

/**
 * @version 	1.0
 * @author
 */
public class SERV_SignbServlet extends DBServlet  {
	
	 
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
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
		
	
		String mode = doString.checkString(req.getParameter("mode"),"add");
		String selProj = doString.checkString(req.getParameter("sel_project"),"");
		String iSignb = doString.checkString(req.getParameter("i_signb"),"");
		String startDate = doString.checkString(req.getParameter("d_beg_use"),"");
		String endDate = doString.checkString(req.getParameter("d_fin_use"),"");
	
	

		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_Signb.jsp?sel_project="+selProj;
		String errorPage = "SERV_Signb01.jsp?sel_project="+selProj+"&i_signb="+iSignb+"&d_beg_use="+startDate+"&d_fin_use="+endDate+"&mode="+mode+"&error=1&refresh=yes";
		String otherMsg = "";
		String errorCode = "";
		
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
		   		 

		   
		   if (mode.equalsIgnoreCase("ADD")) {
		   			
		   			String date="";
		   			System.out.println("---------------------Start Mode Add ----------------------");
		   			
					if (selProj.trim().length()>=6) {
						
						
						//--========= Convert Start Date =============--//
						 if (startDate.length()==10) {
							 String dd = startDate.substring(0,2);
							 String mm = startDate.substring(3,5);
							 int yyyy = Integer.parseInt(startDate.substring(6,10));
							 if (yyyy>2400) yyyy -= 543;
					
							 startDate = yyyy+"-"+mm+"-"+dd;
						 }				   			


						 //--========= Convert End Date =============--//
						  if (endDate.length()==10) {
							  String dd = endDate.substring(0,2);
							  String mm = endDate.substring(3,5);
							  int yyyy = Integer.parseInt(endDate.substring(6,10));
							  if (yyyy>2400) yyyy -= 543;
							
							 endDate = yyyy+"-"+mm+"-"+dd;
						  }				   			

		   	
						 //---=========== Check i_type and i_code is exist or not =============---//
						 sql.append(" select count(*) as cnt from lan:serv_signb where ")
							.append(" i_company='").append(selProj.substring(0,2)).append("' ")
							.append(" and i_project='").append(selProj.substring(3,6)).append("' ")
							.append(" and i_signb='").append(iSignb).append("' ");
						 rs = stmt.executeQuery(sql.toString());	
						 int cnt = -1;
							 if (rs.next()) {
								 System.out.println("--- count  ----");
								 cnt = rs.getInt("cnt");
							 }
						
						 rs.close();
						
							 if (cnt==0) {	
				   	
								 //---======= i_company and  i_project  is not exist ========---//
								 sql.delete(0,sql.length());
								 sql.append("insert into lan:serv_signb (i_company,i_project,i_signb,d_beg_use,d_fin_use,f_use ")
									.append(" ) values ( ")
									.append(" '").append(selProj.substring(0,2)).append("' , ")
									.append(" '").append(selProj.substring(3,6)).append("' , ")
									.append(" '").append(iSignb).append("' , ")
									.append(" '").append(startDate).append("' , ")
									.append(" '").append(endDate).append("' ,")
									.append(" 'N' ) ");   //  set new Signboard to "N" = No used
						
								 stmt.executeUpdate(sql.toString());
								 System.out.println("--------------------- executeUpdate----------------------");

						 } else {
							   //----========= i_type and i_code is exist , return to input page =========--//	
								  successPage = errorPage;
								  errorCode = "1";
								  otherMsg = "เลขที่ป้ายต่อเติมนี้มีอยู่ในโครงการที่เลือกแล้ว กรุณากรอกรหัสใหม่ !" ;
						}
						
						
					} else {
						//---- sel_proj length less than 6 -----//
						successPage = errorPage;
						errorCode = "1";
						otherMsg = "กรุณาเลือกโครงการ !" ;		   	
					}
		   			
		           
		      }
		      

   
		     else if (mode.equalsIgnoreCase("DELETE")) {		
				   // successPage = Constants.APP_PATH+"/SERV_CutLock01.jsp?sel_project="+selProj;	 
				    successPage = "SERV_Signb.jsp?sel_project="+selProj;				   
				    savePage = successPage;
				    errorPage = successPage+"&error=1";
			
				    System.out.println("--------------------- Start delete Mode----------------------");
				 	String[] delid = req.getParameterValues("del_checkbox");
				 	if (delid!=null) {
					 	for (int i=0;i<delid.length;i++) {
							StringTokenizer id = new StringTokenizer(delid[i],":");
	 			 	 	    
							//---==== If i_type or i_code is missing , continue next data =====----//
							if (id.countTokens()!=3) continue;

							sql.delete(0,sql.length());
							sql.append("delete from lan:serv_signb ")
							      .append(" where i_company='").append(id.nextToken()).append("' ")
							      .append(" and i_project='").append(id.nextToken()).append("' ")
							      .append(" and i_signb='").append(id.nextToken()).append("' ");
								   							
								   							
							//System.out.println(sql.toString());		   							
							stmt.executeUpdate(sql.toString());
						
						System.out.println("--------- delete Data success ----------- ");
						
					 } // end for
				 }
	 
			} // end if check mode


		 conn.commit();
		 stmt.close();
		 conn.close();
		 conn = null;
					
		 // Redirect to the finish page.
		 //res.sendRedirect(doString.UnicodeToMS874(successPage));
		genRedirectCode(out,savePage,successPage,errorCode,otherMsg);
						
		}catch (Exception e) {
			if (e instanceof InvalidParameterException) {
						showError(out, doString.UnicodeToMS874(e.getMessage()));
			   } else {
           
					System.out.println(" ERROR "+mName+" : " + e.getMessage());
					System.out.println(" ERROR "+mName+" SQL : " + sql.toString());
					}
			
					//res.sendRedirect(errorPage);
					//System.out.println("error = "+errorPage);
					//genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ "+e.getMessage());
			
		} finally {
					out.close();
					try {
						if (rs!=null) rs.close(); 
						if (stmt != null) stmt.close();
						if (conn != null) conn.close();
					} catch (SQLException ignore) {
					}
				}
		
	}

}



