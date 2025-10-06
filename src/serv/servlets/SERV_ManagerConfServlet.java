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

/**
 * @version 	1.0
 * @author
 */
public class SERV_ManagerConfServlet extends DBServlet  {
	
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

			
		String iVendor = doString.checkString(req.getParameter("i_vendor"),"");				
		String mode = doString.checkString(req.getParameter("mode"),"");
		
		//add by pradoem 2023.02.22
		String selProj = doString.checkString(req.getParameter("sel_project"),"");//LH:075
		String comId = "";
		String projId = "";
		if (selProj.length()>0 && selProj.indexOf(":")!=-1) {
			  String tmp[] = selProj.split("\\:");
			  comId = tmp[0];
			  projId = tmp[1];
		}

		
		//---======= Get Now Date with time =========-----//
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
		String successPage = "SERV_Manager_Conf.jsp?&comId="+comId+"&projId="+projId+"&i_vendor="+iVendor;
		String errorPage = "SERV_Manager_Conf.jsp?error=1&comId="+comId+"&projId="+projId+"&i_vendor="+iVendor; 
			
		
		String otherMsg = "";
		String errorCode = "";
		String iTypeCut = "";
    
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		Connection conn = null;
		Statement stmt = null;
		Statement stmt1 = null;
		ResultSet rs = null;

		 try {
			if (ds == null)
				getDS();

			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
			stmt1 = conn.createStatement();

			
			//---============== Select Vat & Tax From ACCVENVT ================----//
			 int vat = 0;
			 int tax = 0;
			String pVatTax = "00";
			 sql.delete(0,sql.length());
			 sql.append(" select * from lan:accvenvt where grp_no='R8' and (ven_no='").append(iVendor).append("' ")
				   .append(" or ven_no='999999') order by ven_no ");		       
			 rs = stmt.executeQuery(sql.toString());
			 if (rs.next()) {
				 pVatTax = doString.checkString(rs.getString("vat_tax_flag"),"00");				 
				 if (pVatTax.length()==2) {
					 try {
						vat = Integer.parseInt(pVatTax.substring(0,1)); 
						tax = Integer.parseInt(pVatTax.substring(1)); 
					 } catch (Exception e) {
						System.out.println("Vat , Tax Conversion Error : "+e.getMessage());
					 }
				 }
			 }				        
			 rs.close();	
			 

			
			//-----============================ Approve Mode =======================================----//
			if (mode.equalsIgnoreCase("APPROVE")) {
				String iItmJob[] = req.getParameterValues("i_itmjob");
				if (iItmJob!=null) {
					for (int i=0;i<iItmJob.length;i++) {
							String item = doString.checkString(iItmJob[i],"");
							StringTokenizer id = new StringTokenizer(item,":");
							if (id.countTokens()!=2) continue;				
							
							String docno = id.nextToken();
							String vendor = id.nextToken();			
				
							String iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter(item+"_comment"),""));
							iComment = str.replace(iComment,"\r","");
							iComment = str.replace(iComment,"\n","|break|");	
 
					
						//---================ Update SERV_PAYMENT =================----//
						sql.delete(0,sql.length());
						sql.append(" update lan:serv_payment  set ")						  
							  .append(" f_itmstatus='700' ") // set status to 700 , Waiting for Zone Manager Approve
							  .append(" where i_docno='").append(docno).append("' ")				         
							  .append(" and i_vendor='").append(vendor).append("' ")				         
							  .append(" and f_itmstatus='600' ");							  
						stmt1.executeUpdate(sql.toString());
						
												
						
						//-----======================== Insert new SERV_FLOW =============================----//
						sql.delete(0,sql.length());
						sql.append(" insert into lan:serv_flow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,f_reject,c_reject ")
							  .append(") values (")
							  .append(" '").append(docno).append("' , ")
							  .append(" '").append(vendor).append("' , ")
							  .append(" '600' , ") //-- Set Status to 600 , Service Manager already approve ---//
							  .append(" '").append(nowDate).append("' , ")
							  .append(" '").append(user.getUserID()).append("' , ")
							  .append(" null , ")
							  .append(" '").append(iComment).append("') ");
						 stmt1.executeUpdate(sql.toString());
						//-----==================================================================================----//
						
					} // end for	
									
				} // end if check i_itmjob is not null									
			}
			//-----===============================================================================----//



			
			
			//-----============================ Reject Mode =======================================----//
			else if (mode.equalsIgnoreCase("REJECT")) {
				String iItmJob[] = req.getParameterValues("i_itmjob");
				if (iItmJob!=null) {
					for (int i=0;i<iItmJob.length;i++) {
							String item = doString.checkString(iItmJob[i],"");
							StringTokenizer id = new StringTokenizer(item,":");
							if (id.countTokens()!=2) continue;				
							
							String docno = id.nextToken();
							String vendor = id.nextToken();	
											
							String iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter(item+"_comment"),""));
							iComment = str.replace(iComment,"\r","");
							iComment = str.replace(iComment,"\n","|break|");				
							
															
							//---======== Select Payment Date from SERV_PAYSCHD  ===========----//
							String paymentDate = "";
							sql.delete(0,sql.length());
							sql.append(" select d_payment from lan:serv_payschd where today<=d_contructor order by d_payment ");
							rs = stmt.executeQuery(sql.toString());
							if (rs.next()) {
								Calendar pay = Calendar.getInstance();
								Timestamp tmp = rs.getTimestamp("d_payment");
								if (tmp!=null)  {
									pay.setTime(tmp);    
									int tYear = pay.get(Calendar.YEAR);
									if (tYear>2400) tYear-= 543;
									paymentDate += tYear+"-"+str.createID(pay.get(Calendar.MONTH)+1,2);
									paymentDate += "-"+str.createID(pay.get(Calendar.DATE),2);
								}							 
							}				        
							rs.close();	 
																					
											
							sql.delete(0,sql.length());
							sql.append(" update lan:serv_payment  set ")
								  .append(" d_payment ='").append(paymentDate).append("' , ")									
								  .append(" f_itmstatus='400' ") // re-status to 400 , Send back to Contractor to approve and edit data again
								  .append(" where i_docno='").append(docno).append("' ")				         
								  .append(" and i_vendor='").append(iVendor).append("' ")
								  .append(" and f_itmstatus='600' ");
							stmt1.executeUpdate(sql.toString());						
				
				
							//-----======================== Insert new SERV_FLOW =============================----//
							sql.delete(0,sql.length());
							sql.append(" insert into lan:serv_flow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,f_reject,c_reject ")
								  .append(") values (")
								  .append(" '").append(docno).append("' , ")
								  .append(" '").append(vendor).append("' , ")
								  .append(" '600' , ") //-- Set Status to 600 , Service Manager already reject ---//
								  .append(" '").append(nowDate).append("' , ")
								  .append(" '").append(user.getUserID()).append("' , ")
								  .append(" 'Y' , ")
								  .append(" '").append(iComment).append("') ");
							stmt1.executeUpdate(sql.toString());
				           //-----==================================================================================----//
						
					} // end for	
									
				} // end if check i_itmjob is not null							
			}			 
			//-----===============================================================================----//





			//-----============================ RouteBack Mode =======================================----//
			else if (mode.equalsIgnoreCase("ROUTEBACK")) {
				String iItmJob[] = req.getParameterValues("i_itmjob");
				if (iItmJob!=null) {
					for (int i=0;i<iItmJob.length;i++) {
							String item = doString.checkString(iItmJob[i],"");
							StringTokenizer id = new StringTokenizer(item,":");
							if (id.countTokens()!=2) continue;				
							
							String docno = id.nextToken();
							String vendor = id.nextToken();	
											
							String iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter(item+"_comment"),""));
							iComment = str.replace(iComment,"\r","");
							iComment = str.replace(iComment,"\n","|break|");				
							
							
							//---======== Select Payment Date from SERV_PAYSCHD  ===========----//
							String paymentDate = "";
							sql.delete(0,sql.length());
							sql.append(" select d_payment from lan:serv_payschd where today<=d_service_staff order by d_payment ");
							rs = stmt.executeQuery(sql.toString());
							if (rs.next()) {
								Calendar pay = Calendar.getInstance();
								Timestamp tmp = rs.getTimestamp("d_payment");
								if (tmp!=null)  {
									pay.setTime(tmp);    
									int tYear = pay.get(Calendar.YEAR);
									if (tYear>2400) tYear-= 543;
									paymentDate += tYear+"-"+str.createID(pay.get(Calendar.MONTH)+1,2);
									paymentDate += "-"+str.createID(pay.get(Calendar.DATE),2);
								}							 
							}				        
							rs.close();	 
							
											
							sql.delete(0,sql.length());
							sql.append(" update lan:serv_payment  set ")
						          .append(" d_payment ='").append(paymentDate).append("' , ")									
								  .append(" f_itmstatus='500' ") // re-status to 500 , Send back to Service Staff to re-check and approve again
								  .append(" where i_docno='").append(docno).append("' ")				         
								  .append(" and i_vendor='").append(iVendor).append("' ")
								  .append(" and f_itmstatus='600' ");
							stmt1.executeUpdate(sql.toString());						
				
				
							//-----======================== Insert new SERV_FLOW =============================----//
							sql.delete(0,sql.length());
							sql.append(" insert into lan:serv_flow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,f_reject,c_reject ")
								  .append(") values (")
								  .append(" '").append(docno).append("' , ")
								  .append(" '").append(vendor).append("' , ")
								  .append(" '600' , ") //-- Set Status to 600 , Service Manager already routebak ---//
								  .append(" '").append(nowDate).append("' , ")
								  .append(" '").append(user.getUserID()).append("' , ")
								  .append(" 'Y' , ")
								  .append(" '").append(iComment).append("') ");
							stmt1.executeUpdate(sql.toString());
						   //-----==================================================================================----//
						
					} // end for	
									
				} // end if check i_itmjob is not null							
			}			 
			//-----===============================================================================----//
			
			
			




			conn.commit();
			stmt.close();
			conn.close();
			conn = null;			

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
				if (stmt1 != null) stmt1.close();
				if (pstmt != null) pstmt.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");

	}

}
