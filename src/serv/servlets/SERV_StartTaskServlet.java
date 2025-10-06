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
public class SERV_StartTaskServlet extends DBServlet  {
	
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

		String mode = doString.checkString(req.getParameter("mode"),"add");
		String selProj = doString.checkString(req.getParameter("sel_project"),"");		String i_docno = doString.checkString(req.getParameter("i_docno"),"");

			
		//---======= Get Now Date =========-----//
		Calendar now = Calendar.getInstance();				
		int year = (now).get(Calendar.YEAR);
		if (year<2400) year += 543;		
		String nowDate = Integer.toString(year>2400 ? year-543 : year);	
		nowDate += "-"+str.createID(now.get(Calendar.MONTH)+1,2);
		nowDate += "-"+str.createID(now.get(Calendar.DATE),2);		
		nowDate += " "+str.createID(now.get(Calendar.HOUR_OF_DAY),2);
		nowDate += ":"+str.createID(now.get(Calendar.MINUTE),2);						
	   //---=========================================================================----//		
		
		
		//----============= Define Link for redirect ===============-----//			
		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_StartTask_List.jsp?sel_project="+selProj;
		String errorPage = "SERV_StartTask_List.jsp?error=1&sel_project="+selProj;		String itmtype = doString.checkString(req.getParameter("itmtype"),"");		String i_itmno = doString.checkString(req.getParameter("i_itmno"),"");
		
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
						
			
			//----========================= Start Task ==============================----//
			
			if("CANCEL".equalsIgnoreCase(mode)){
				String d_keyin_beg = doString.checkString(req.getParameter("d_keyin_beg"),"");
				String d_keyin_end = doString.checkString(req.getParameter("d_keyin_end"),"");
				successPage = "SERV_BeyondDetails.jsp?i_company="+selProj.substring(0,2)+"&i_project="+selProj.substring(3, 6)+"&itmtype="+itmtype+"&d_keyin_beg="+d_keyin_beg+"&d_keyin_end="+d_keyin_end+"&i_itmno="+i_itmno;
				errorPage = "SERV_BeyondDetails.jsp?error=1&i_company="+selProj.substring(0,2)+"&i_project="+selProj.substring(3, 6)+"&itmtype="+itmtype+"&d_keyin_beg="+d_keyin_beg+"&d_keyin_end="+d_keyin_end+"&i_itmno="+i_itmno;
				
				sql.delete(0,sql.length());
				sql.append("update lan:serv_dochd set ")
					  .append(" f_status = 'CAN' , ")
					  .append(" d_cancel = today , ")
					  .append(" i_employ_cancel = '"+user.getUserID()+"' ")
					  .append(" where i_docno='"+i_docno+"'  ");  
				System.out.println(sql.toString());
				stmt.executeUpdate(sql.toString());
				
				
			}else{
				String[] vendor = req.getParameterValues("i_vendor");			
				
				if (vendor!=null) {
					for (int i=0;i<vendor.length;i++) {
						   StringTokenizer id = new StringTokenizer(vendor[i],"_");
						   if (id.countTokens()!=2) continue; 
						   
						   String iDocNo = id.nextToken();
						   String iVendor = id.nextToken();
						   boolean neverInsertFlow = false;
						   
	
							//---======== Update Item Status to 300 if that item is for this vendor ========----//
							sql.delete(0,sql.length());
							sql.append("update lan:serv_docdt set ")
								  .append(" f_itmstatus='300' ") //---- Set status to 300 , Start Task 
								  .append(" where i_docno='").append(iDocNo).append("'  ")
								  .append(" and i_vendor='").append(iVendor).append("'  ")
					        	  .append(" and f_itmstatus='200'  ");				        	  
							stmt.executeUpdate(sql.toString());
							
							
							//---======== check SERV_FLOW before insert ========----//
							sql.delete(0,sql.length());
							sql.append(" select count(*) from lan:serv_flow where i_docno='").append(iDocNo).append("' ");
							rs = stmt.executeQuery(sql.toString());
							if (rs.next()) {
								neverInsertFlow = false;
							} else {
								neverInsertFlow = true;
							}
							rs.close();	
						
						
							//---======== Insert SERV_FLOW Data ========----//
							sql.delete(0,sql.length());
							sql.append(" insert into lan:serv_flow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,c_reject ")
								  .append(") values (")
								  .append(" '").append(iDocNo).append("' , ")
								  .append(" '").append(iVendor).append("' , ")
								  .append(" '200' , ") //-- Set Status to 200 , Start Task Already ---//
								  .append(" '").append(nowDate).append("' , ")
								  //.append(" today , ")
						          .append(" '").append(user.getUserID()).append("' , null ) "); 
							stmt.executeUpdate(sql.toString());	
											
						
							//---========= If can get data from i_itmjob_xxx , that mean this i_itmjob is cancel =========------//
							String[] itm = req.getParameterValues("i_itmjob_"+vendor[i]);		
							if (itm!=null) {
								for (int j=0;j<itm.length;j++) {						
										StringTokenizer delId = new StringTokenizer(itm[j],":");
										if (delId.countTokens()!=3) continue; 								
									
										sql.delete(0,sql.length());
										sql.append("update lan:serv_docdt set ")
											  .append(" f_itmstatus='CAN' ") //---- Set status to CAN , Cancel ItemJob
											  .append(" where i_docno='").append(delId.nextToken()).append("'  ")
											  .append(" and i_vendor='").append(delId.nextToken()).append("'  ")
									          .append(" and i_itmjob='").append(delId.nextToken()).append("'  ");
										stmt.executeUpdate(sql.toString());											
								} // end for j
							 }
							 
							 
							 
							 //---- If this insert is a first inserted , update d_start_min -----//
							 if (neverInsertFlow) {
								sql.delete(0,sql.length());
								sql.append(" update lan:serv_dochd set d_start_min = today ")
									  .append(" where i_docno='").append(iDocNo).append("'  ");
								stmt.executeUpdate(sql.toString());
							 }
						
						
					} // end for i		
				}
			}
			//----======================================----//


			conn.commit();
			//conn.rollback();
			stmt.close();
			conn.close();
			conn = null;
			/* From Follow */
			String from_page = doString.checkString(req.getParameter("from_page"),"");			if(!"".equals(from_page)){				successPage = "/LHServ/"+from_page+"?sel_project="+selProj+"&i_docno="+i_docno+"&itmtype="+doString.checkString(req.getParameter("itmtype"),"");				errorPage = "/LHServ/"+from_page+"?error=1&sel_project="+selProj+"&i_docno="+i_docno+"&itmtype="+doString.checkString(req.getParameter("itmtype"),"");			}			/* End */
			// Redirect to the finish page.
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
			genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ : "+e.getMessage());
			
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
