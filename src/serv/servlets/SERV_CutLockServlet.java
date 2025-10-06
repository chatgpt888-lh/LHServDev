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

import serv.common.User;
import serv.common.Constants;
import serv.common.SERV_CommonData;

/**
 * @version 	1.0
 * @author
 */
public class SERV_CutLockServlet extends DBServlet  {
	
	 
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
		
	
		String selProj = doString.checkString(req.getParameter("sel_project"),"");
		String iCode =doString.checkString(req.getParameter("i_code"),"");
		String mode = doString.checkString(req.getParameter("mode"),"");
		String iLock = doString.checkString(req.getParameter("i_lock"),"");
		String eDate = doString.checkString(req.getParameter("e_date"),"");
		String eMonth = doString.checkString(req.getParameter("e_month"),"");
		String eYear = doString.checkString(req.getParameter("e_year"),"");
		double zAmount = Double.parseDouble(doString.checkString(req.getParameter("z_amount"),"0.00"));
	

		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_CutLock01.jsp?sel_project="+selProj;
		String errorPage = "SERV_CutLock02.jsp?sel_project="+selProj+"&i_lock="+iLock+"&e_date="+eDate+"&e_mounth="+eMonth+"&e_year="+eYear+"&i_code="+(iCode.length()>=1 ?  iCode.substring(0,1) : "")+"&error=1&refresh=yes";
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
		   			
		   			System.out.println("---------------------Start Mode Add ----------------------");
		   			
		   			
			        //--========= Convert dEff to mm/dd/yyyy =============--//
					int yyyy = Integer.parseInt(eYear);
					if (yyyy>2400) yyyy -= 543;			  
					String dEff = Integer.toString(yyyy)+"-"+eMonth+"-"+eDate;      

		
		   	
					//---=========== Check i_type and i_code is exist or not =============---//
					sql.append(" select count(*) as cnt from lan:serv_cutlck where ")
			   		   .append(" i_company='").append(selProj.substring(0,2)).append("' ")
			           .append(" and i_project='").append(selProj.substring(3,6)).append("' ")
					   .append(" and i_lock='").append(iLock).append("' ")
					   .append(" and d_effective='").append(dEff).append("' ");
					rs = stmt.executeQuery(sql.toString());	
			
					int cnt = -1;
						if (rs.next()) {
							cnt = rs.getInt("cnt");
						}
						
					rs.close();
						
					if (cnt==0) {	
						//   	if(iCode.length()==0){
				   	
					//---======= i_company and  i_project  is not exist ========---//
					sql.delete(0,sql.length());
				 	sql.append("insert into lan:serv_cutlck (i_company,i_project,i_lock,d_effective,i_cut_type,z_amount ")
				       .append(" ) values ( ")
					   .append(" '").append(selProj.substring(0,2)).append("' , ")
					   .append(" '").append(selProj.substring(3,6)).append("' , ")
					   .append(" '").append(iLock).append("' , ")
					   .append(" '").append(dEff).append("' ,")
					   .append(" '").append(iCode.substring(0,1)).append("' , ")
					   .append(" ").append(zAmount).append(" ")
					   .append(" ) "); 
				
				    stmt.executeUpdate(sql.toString());
				    System.out.println("--------------------- executeUpdate----------------------");
		   	
		   	
			        successPage = "SERV_CutLock01.jsp?&sel_project="+selProj;
					
					
					} else {
			              //----========= i_type and i_code is exist , return to input page =========--//	
			                 successPage = errorPage;
			                 errorCode = "1";
			                 otherMsg = "แปลงนี้มีการกำหนดการตัดเงินแล้ว กรุณากรอกข้อมูลใหม่ !" ;
			            }
		           
		      }
		      
		      
		      
		    else if (mode.equalsIgnoreCase("EDIT")) {
		   			
		   			System.out.println("---------------------Start Mode Edit  ----------------------");
		   			
				    String editId = doString.checkString(req.getParameter("edit_id"),"");
					StringTokenizer id = new StringTokenizer(editId,":");			
					
					if (id.countTokens()>=5) {
						//---======= i_company and  i_project  is not exist ========---//
						sql.delete(0,sql.length());
						sql.append("update lan:serv_cutlck set ")
							  .append(" i_cut_type='").append(iCode.substring(0,1)).append("' , ")
							  .append(" z_amount=").append(zAmount).append(" ")
							  .append(" where ")
							  .append(" i_company='").append(id.nextToken()).append("' ")
							  .append(" and i_project='").append(id.nextToken()).append("' ")
							  .append(" and i_lock='").append(id.nextToken()).append("' ")
							  .append(" and d_effective='").append(id.nextToken()).append("' ")
							  .append(" and i_cut_type='").append(id.nextToken()).append("' ");
				
						stmt.executeUpdate(sql.toString());
						System.out.println("--------------------- executeUpdate----------------------");
		   	
		   	
						successPage = "SERV_CutLock01.jsp?&sel_project="+selProj;						
					}
		      }
		           
		     
		     else if (mode.equalsIgnoreCase("DELETE")) {		
				    successPage = Constants.APP_PATH+"/SERV_CutLock01.jsp?sel_project="+selProj;	 
				    savePage = successPage;
				    errorPage = successPage+"&error=1";
			
				    System.out.println("--------------------- Start delete Mode----------------------");
				 	String[] delid = req.getParameterValues("del_checkbox");
				 	if (delid!=null) {
					 	for (int i=0;i<delid.length;i++) {
							StringTokenizer id = new StringTokenizer(delid[i],":");
	 			 	 	    
							//---==== If i_type or i_code is missing , continue next data =====----//
							if (id.countTokens()!=5) continue;
	 			 	 	
						System.out.println("--------- Start delete Data  ----------- ");
							sql.delete(0,sql.length());
							sql.append("delete from lan:serv_cutlck ")
							      .append(" where i_company='").append(id.nextToken()).append("' ")
							      .append(" and i_project='").append(id.nextToken()).append("' ")
							      .append(" and i_lock='").append(id.nextToken()).append("' ")
								  .append(" and d_effective='").append(id.nextToken()).append("' ")
 							      .append(" and i_cut_type='").append(id.nextToken()).append("' ");
								   							
								   							
							System.out.println(sql.toString());		   							
							stmt.executeUpdate(sql.toString());
						
						System.out.println("--------- delete Data success ----------- ");
						
					 } // end for
				 }
	 
			}
		       
		 conn.commit();
		 stmt.close();
		 conn.close();
		 conn = null;
		 System.out.println("--------- close connection----------- ");
		 System.out.println("successPage---------------"+successPage);
					
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



