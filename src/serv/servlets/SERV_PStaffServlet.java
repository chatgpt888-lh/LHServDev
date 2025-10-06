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
public class SERV_PStaffServlet extends DBServlet  {
	
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
/*
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
 */       
 		res.setContentType("text/html; charset=TIS620");
	 	PrintWriter out = res.getWriter();
		
		System.out.println(req.getParameter("sel_project"));
		
		String mode = doString.checkString(req.getParameter("mode"), "");
		String comId = doString.checkString(req.getParameter("com_id"));
		String projId = doString.checkString(req.getParameter("proj_id"));
		String selProj = doString.checkString(req.getParameter("sel_project"),"");
		String iCom = doString.checkString(req.getParameter("sel_project"),"");//.substring(0,2);
		String iPro = doString.checkString(req.getParameter("sel_project"),"");//.substring(3,6);
		String iEmploy = doString.checkString(req.getParameter("i_employ"),"");//.substring(3,6);
	
	
	
		String userId= doString.checkString(req.getParameter("user_id"),"");
		

		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_PStaff02.jsp?i_employ="+iEmploy;
		String errorPage = "SERV_PStaff02.jsp?="+"&i_company"+iCom+"&i_project"+iPro+"&user_id="+userId+"&i_employ="+iEmploy+"&sel_project="+selProj+"&error=1";
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
				
			    String com = doString.checkString(req.getParameter("sel_project"),"").substring(0,2);
				String project = doString.checkString(req.getParameter("sel_project"),"").substring(3,6);
				System.out.println("------ begin if mode -------");
				
				//---=========== Check com_id and proj_id is exist or not =============---//
				sql.append(" select count(*) as cnt from lan:serv_pstaff  ")
				   .append(" where user_id='").append(userId).append("' ")
			       .append(" and com_id ='").append(comId).append("' ")
				   .append(" and  proj_id='").append(projId).append("' ");
				rs = stmt.executeQuery(sql.toString());
				int cnt = -1;
				if (rs.next()) {
					cnt = rs.getInt("cnt");
				}
				rs.close();
					
				
				
				if (cnt==0) {
				//---======= com_id and proj_id is not exist ========---//*/
					sql.delete(0,sql.length());
					sql.append("insert into lan:serv_pstaff(com_id,proj_id,user_id ")
						  .append(" ) values ( ")
						  .append(" '").append(com).append("' , ")
						  .append(" '").append(project).append("' , ")
						  .append(" '").append(userId).append("' ")
						  .append(" ) "); 						  
					stmt.executeUpdate(sql.toString());
					
					//---- 2014-04-01 , insert docflow:project_staff ----//
					sql.delete(0,sql.length());
					sql.append(" insert into docflow:project_staff ( ")
					   .append(" i_employ, user_id, i_df_type, i_company, i_project, user_who  ")
					   .append(" ) values ( ")
					   .append(" '"+iEmploy+"', '"+userId+"', 'ME', '"+com+"', '"+project+"', null) ");
					stmt.executeUpdate(sql.toString());	
					
					//------2015.03.06
					//---- 2014-04-01 , insert docflow:project_staff ----//
					sql.delete(0,sql.length());
					sql.append("insert into lan:project_staff(com_id,proj_id,user_id ")
					  .append(" ) values ( ")
					  .append(" '").append(com).append("' , ")
					  .append(" '").append(project).append("' , ")
					  .append(" '").append(userId).append("' ")
					  .append(" ) "); 						  

					stmt.executeUpdate(sql.toString());										

				
					successPage = "SERV_PStaff02.jsp?mode=add&user_id="+userId+"&i_employ="+iEmploy;;
				} else {
			//----=========check com_id , check proj_id is exist , return to input page =========--//	
					successPage = errorPage;
					errorCode = "1";
					otherMsg = "โครงการมีอยู่ในระบบแล้วกรุณาเลือกโครงการใหม่ !" ;
				}

		  }
			
			//----======== Delete Mode , Insert Query =========----//
			else if (mode.equalsIgnoreCase("DELETE")) {		
				
				successPage = "SERV_PStaff02.jsp?mode=add&user_id="+userId+"&i_employ="+iEmploy; 
				errorPage = Constants.APP_PATH+"/SERV_PStaff02.jsp?error=1&i_employ="+iEmploy; 
				savePage = "SERV_PStaff02.jsp?mode=add&user_id="+userId+"&i_employ="+iEmploy;  
				
				
				// String ttt = "";
				 String[] delid = req.getParameterValues("del_checkbox");			 
				 String []str = null;
				 if (delid!=null) {
					 for (int i=0;i<delid.length;i++) {					 
						    
						    str = delid[i].split("\\:");
						    
						    sql.delete(0,sql.length());
							sql.append(" delete from lan:serv_pstaff ")
						          .append(" where user_id='").append(str[0]).append("' ")
								  .append(" and com_id='").append(str[1]).append("' ")
								  .append(" and proj_id='").append(str[2]).append("' ");
							stmt.executeUpdate(sql.toString());	

							//---- 2014-04-01 , delete docflow:project_staff ----//
							sql.delete(0,sql.length());
							sql.append(" delete from docflow:project_staff ")
						       .append(" where user_id='").append(str[0]).append("' ")
							   .append(" and i_company='").append(str[1]).append("' ")
							   .append(" and i_project='").append(str[2]).append("' ");
							stmt.executeUpdate(sql.toString());		
							
							//------2015.03.06
							sql.delete(0,sql.length());
							sql.append(" delete from lan:project_staff ")
						          .append(" where user_id='").append(str[0]).append("' ")
								  .append(" and com_id='").append(str[1]).append("' ")
								  .append(" and proj_id='").append(str[2]).append("' ");
							stmt.executeUpdate(sql.toString());	

							//StringTokenizer id = new StringTokenizer(delid[i],":");

							/*/---==== If com_id or proj_id is missing , continue next data =====---- / /
							if (id.countTokens()!=3) continue;
						  	sql.delete(0,sql.length());
							sql.append(" delete from lan:serv_pstaff ")
						          .append(" where user_id='").append(id.nextToken()).append("' ")
								  .append(" and com_id='").append(id.nextToken()).append("' ")
								  .append(" and proj_id='").append(id.nextToken()).append("' ");
							stmt.executeUpdate(sql.toString());	
							
							//---- 2014-04-01 , delete docflow:project_staff ----//
							sql.delete(0,sql.length());
							sql.append(" delete from docflow:project_staff ")
						       .append(" where user_id='").append(id.nextToken()).append("' ")
							   .append(" and i_company='").append(id.nextToken()).append("' ")
							   .append(" and i_project='").append(id.nextToken()).append("' ");
							stmt.executeUpdate(sql.toString());		
							
							//------2015.03.06
							sql.delete(0,sql.length());
							sql.append(" delete from lan:project_staff ")
						          .append(" where user_id='").append(id.nextToken()).append("' ")
								  .append(" and com_id='").append(id.nextToken()).append("' ")
								  .append(" and proj_id='").append(id.nextToken()).append("' ");
							stmt.executeUpdate(sql.toString());	
							*/
							
						System.out.println("--- delete Data---");
						
						stmt.executeUpdate(sql.toString());
						System.out.println("SuccessPae::::"+successPage);
						System.out.println("userId::::"+userId);
					 } // end for
				}
 
			}


			conn.commit();
			stmt.close();
			conn.close();
			conn = null;
			System.out.println("--------- close connection ");
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
