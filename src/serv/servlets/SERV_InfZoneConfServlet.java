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

import serv.common.Constants;
import serv.common.SERV_CommonData;
import serv.common.User;

/**
 * @version 	1.0
 * @author
 */
public class SERV_InfZoneConfServlet extends DBServlet  {
	
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
		String successPage = doString.checkString(req.getParameter("success_page"),"");	
		String errorPage = doString.checkString(req.getParameter("error_page"),"");	
			
		
		String otherMsg = "";
		String errorCode = "";

		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		Connection conn = null;
		Statement stmt = null;
		Statement stmt1 = null;
		ResultSet rs = null;
		ResultSet rs1 = null;

		 try {
			if (ds == null)
				getDS();

			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
			stmt1 = conn.createStatement();




			//-----============================ Approve Vendor Mode =======================================----//
			if (mode.equalsIgnoreCase("APPROVE_VENDOR")) {
				String vendorList[] = req.getParameterValues("i_vendor");
				String selProj = doString.checkString(req.getParameter("sel_project"),"").toUpperCase(); 
				String iCompany = (selProj.length()==6 ? selProj.substring(0,2) : "");
				String iProject = (selProj.length()==6 ? selProj.substring(3,6) : "");				
				
				if (vendorList!=null) {
					for (int i=0;i<vendorList.length;i++) {
							String vendor = doString.checkString(vendorList[i],"");			
							//--====== For use multiple comment =======--//
							//String iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter(vendor+"_comment"),""));
						
						    String iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter("main_comment"),""));
							iComment = str.replace(iComment,"\r","");
							iComment = str.replace(iComment,"\n","|break|");	

					    
					    
					    //---============== Get All iDocNo for this vendor for use in update payment and insert flow ===========---//
					    sql.delete(0,sql.length());
					    sql.append(" select distinct b.i_docno from lan:serv_infdochd a,lan:serv_infpayment b ")
					          .append(" where b.f_itmstatus = '700' and b.i_docno=a.i_docno ") //Wait Zone Confirm                                                       
	  			  		      .append(" and b.i_vendor='").append(vendor).append("' ");
	  			  		if (iCompany.trim().length()>0 && iProject.trim().length()>0) {
							 sql.append(" and a.i_company='").append(iCompany).append("' ")
							       .append(" and a.i_project='").append(iProject).append("' ");
	  			  		}
					    rs = stmt.executeQuery(sql.toString());
					    while (rs.next()) {
					        String docno = doString.checkString(rs.getString("i_docno"),"");

					         
							//---================ Update SERV_INFPAYMENT =================----//
							sql.delete(0,sql.length());
							sql.append(" update lan:serv_infpayment  set ")				  
								  .append(" f_itmstatus='800' ") // set status to 800 , Zone Approve
								  .append(" where i_docno='").append(docno).append("' ")				         
								  .append(" and i_vendor='").append(vendor).append("' ")				         
								  .append(" and f_itmstatus='700' ");							  				          
							stmt1.executeUpdate(sql.toString());
						
												
						
							//-----======================== Insert new SERV_INFFLOW =============================----//
							sql.delete(0,sql.length());
							sql.append(" insert into lan:serv_infflow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,f_reject,c_reject ")
								  .append(") values (")
								  .append(" '").append(docno).append("' , ")
								  .append(" '").append(vendor).append("' , ")
								  .append(" '700' , ") //-- Set Status to 700 , Zone Manager already approve ---//
								  .append(" '").append(nowDate).append("' , ")
								  .append(" '").append(user.getUserID()).append("' , ")
								  .append(" null , ")
								  .append(" '").append(iComment).append("') ");				          
							 stmt1.executeUpdate(sql.toString());					         
					         
					    } // end while
					    rs.close();
						
					} // end for	
									
				} // end if check vendorList is not null						
			}			
			//-----========================================================================================----//
			
			
			
			
			
			
			
			//-----============================ Reject Vendor Mode =======================================----//
			if (mode.equalsIgnoreCase("REJECT_VENDOR")) {
				String vendorList[] = req.getParameterValues("i_vendor");
				String selProj = doString.checkString(req.getParameter("sel_project"),"").toUpperCase(); 
				String iCompany = (selProj.length()==6 ? selProj.substring(0,2) : "");
				String iProject = (selProj.length()==6 ? selProj.substring(3,6) : "");		
								
				if (vendorList!=null) {
					for (int i=0;i<vendorList.length;i++) {
							String vendor = doString.checkString(vendorList[i],"");					
							
							//---======== For use multiple comment ==========---//
						    String iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter("main_comment"),""));							
							iComment = str.replace(iComment,"\r","");
							iComment = str.replace(iComment,"\n","|break|");	
						//---============== Get All iDocNo for this vendor for use in update payment and insert flow ===========---//
						sql.delete(0,sql.length());
						sql.append(" select distinct b.i_docno from lan:serv_infdochd a,lan:serv_infpayment b ")
							  .append(" where b.f_itmstatus = '700' and b.i_docno=a.i_docno ")                                                         
							  .append(" and b.i_vendor='").append(vendor).append("' ");
						if (iCompany.trim().length()>0 && iProject.trim().length()>0) {
							 sql.append(" and a.i_company='").append(iCompany).append("' ")
								   .append(" and a.i_project='").append(iProject).append("' ");
						}							  
						rs = stmt.executeQuery(sql.toString());
						while (rs.next()) {
							String docno = doString.checkString(rs.getString("i_docno"),"");
					       
					       
							//---======== Select Payment Date from SERV_PAYSCHD  ===========----//
							String paymentDate = "";
							sql.delete(0,sql.length());
							sql.append(" select d_payment from lan:serv_payschd where today<=d_contructor order by d_payment ");
							rs1 = stmt1.executeQuery(sql.toString());
							if (rs1.next()) {
								Calendar pay = Calendar.getInstance();
								Timestamp tmp = rs1.getTimestamp("d_payment");
								if (tmp!=null)  {
									pay.setTime(tmp);    
									int tYear = pay.get(Calendar.YEAR);
									if (tYear>2400) tYear-= 543;
									paymentDate += tYear+"-"+str.createID(pay.get(Calendar.MONTH)+1,2);
									paymentDate += "-"+str.createID(pay.get(Calendar.DATE),2);
								}							 
							}				        
							rs1.close();	 					       
							//---================ Update SERV_INFPAYMENT =================----//
							sql.delete(0,sql.length());
							sql.append(" update lan:serv_infpayment  set ")
							      .append(" d_payment ='").append(paymentDate).append("' , ")		
								  .append(" f_itmstatus='400' ") // re-status to 400 , Send back to Contractor to approve and edit data again
								  .append(" where i_docno='").append(docno).append("' ")				         
								  .append(" and i_vendor='").append(vendor).append("' ")
								  .append(" and f_itmstatus='700' ");
							stmt1.executeUpdate(sql.toString());						
				
				
							//-----======================== Insert new SERV_INFFLOW =============================----//
							sql.delete(0,sql.length());
							sql.append(" insert into lan:serv_infflow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,f_reject,c_reject ")
								  .append(") values (")
								  .append(" '").append(docno).append("' , ")
								  .append(" '").append(vendor).append("' , ")
								  .append(" '700' , ") //-- Set Status to 700 , Zone Manager already reject ---//
								  .append(" '").append(nowDate).append("' , ")
								  .append(" '").append(user.getUserID()).append("' , ")
								  .append(" 'Y' , ")
								  .append(" '").append(iComment).append("') ");
							stmt1.executeUpdate(sql.toString());			         
						} // end while
						rs.close();
					} // end for	
				} // end if check vendorList is not null								
			}				
			//-----========================================================================================----//
			
			
			
			
			
			
			//-----============================ Approve Mode =======================================----//
			else if (mode.equalsIgnoreCase("APPROVE")) {
				String iItmJob[] = req.getParameterValues("i_itmjob");
				if (iItmJob!=null) {
					for (int i=0;i<iItmJob.length;i++) {
							String item = doString.checkString(iItmJob[i],"");
							StringTokenizer id = new StringTokenizer(item,":");
							if (id.countTokens()!=2) continue;				
							
							String docno = id.nextToken();
							String vendor = id.nextToken();			
					
							//----========== For use multiple comment =========---//
						    String iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter("main_comment"),""));
							iComment = str.replace(iComment,"\r","");
							iComment = str.replace(iComment,"\n","|break|");	

					    
					
						//---================ Update SERV_INFPAYMENT =================----//
						sql.delete(0,sql.length());
						sql.append(" update lan:serv_infpayment  set ")				  
							  .append(" f_itmstatus='800' ") // set status to 800 , Waiting for VP Approve
							  .append(" where i_docno='").append(docno).append("' ")				         
							  .append(" and i_vendor='").append(vendor).append("' ")				         
							  .append(" and f_itmstatus='700' ");							  
						stmt1.executeUpdate(sql.toString());
						
												
						
						//-----======================== Insert new SERV_INFFLOW =============================----//
						sql.delete(0,sql.length());
						sql.append(" insert into lan:serv_infflow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,f_reject,c_reject ")
							  .append(") values (")
							  .append(" '").append(docno).append("' , ")
							  .append(" '").append(vendor).append("' , ")
							  .append(" '700' , ") //-- Set Status to 700 , Zone Manager already approve ---//
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
							
							//----========== For use multiple comment ===========---//				
							//String iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter(item+"_comment"),""));
						    
						    String iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter("main_comment"),""));
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
							sql.append(" update lan:serv_infpayment  set ")
								  .append(" d_payment ='").append(paymentDate).append("' , ")									
								  .append(" f_itmstatus='400' ") // re-status to 400 , Send back to Contractor to approve and edit data again
								  .append(" where i_docno='").append(docno).append("' ")				         
								  .append(" and i_vendor='").append(vendor).append("' ")
								  .append(" and f_itmstatus='700' ");
							stmt1.executeUpdate(sql.toString());						
				
				
							//-----======================== Insert new SERV_INFFLOW =============================----//
							sql.delete(0,sql.length());
							sql.append(" insert into lan:serv_infflow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,f_reject,c_reject ")
								  .append(") values (")
								  .append(" '").append(docno).append("' , ")
								  .append(" '").append(vendor).append("' , ")
								  .append(" '700' , ") //-- Set Status to 700 , Zone Manager already reject ---//
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
							
							//----========== For use multiple comment ===========---//				
							//String iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter(item+"_comment"),""));
						    
							String iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter("main_comment"),""));
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
							sql.append(" update lan:serv_infpayment  set ")
								  .append(" d_payment ='").append(paymentDate).append("' , ")									
								  .append(" f_itmstatus='500' ") // re-status to 500 , Send back to Service Staff to re-check and approve again
								  .append(" where i_docno='").append(docno).append("' ")				         
								  .append(" and i_vendor='").append(vendor).append("' ")
								  .append(" and f_itmstatus='700' ");
							stmt1.executeUpdate(sql.toString());						
				
				
							//-----======================== Insert new SERV_INFFLOW =============================----//
							sql.delete(0,sql.length());
							sql.append(" insert into lan:serv_infflow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,f_reject,c_reject ")
								  .append(") values (")
								  .append(" '").append(docno).append("' , ")
								  .append(" '").append(vendor).append("' , ")
								  .append(" '700' , ") //-- Set Status to 700 , Zone Manager already routeback ---//
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
			try {
				if (conn != null)
					conn.rollback();
			} catch (Exception ignore) {}			
			if (e instanceof InvalidParameterException) {
				showError(out, doString.UnicodeToMS874(e.getMessage()));
			} else {           
			System.out.println(" ERROR "+mName+" : " + e.getMessage());
			System.out.println(" ERROR "+mName+" SQL : " + sql.toString());
			}
			System.out.println("error = "+errorPage);
			genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ : "+e.getMessage());
			
		} finally {
			out.close();
			try {
				if (rs!=null) rs.close(); 
				if (rs1!=null) rs1.close(); 
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
