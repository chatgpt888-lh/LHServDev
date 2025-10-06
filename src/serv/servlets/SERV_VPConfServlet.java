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
public class SERV_VPConfServlet extends DBServlet  {
	
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
		String dPayment = doString.checkString(req.getParameter("d_payment"),"");//03/08/2566	
		
		
		//---======= Get Now Date with time =========-----//
		Calendar now = Calendar.getInstance();				
		int year = (now).get(Calendar.YEAR);
		if (year<2400) year += 543;		
		/*String nowDate = Integer.toString(year>2400 ? year-543 : year);	
		nowDate += "-"+str.createID(now.get(Calendar.MONTH)+1,2);
		nowDate += "-"+str.createID(now.get(Calendar.DATE),2);		
		nowDate += " "+str.createID(now.get(Calendar.HOUR_OF_DAY),2);
		nowDate += ":"+str.createID(now.get(Calendar.MINUTE),2);*/
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
			conn.setAutoCommit(true);
			//conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);

			stmt = conn.createStatement();
			stmt1 = conn.createStatement();


			//---- Keep iDocNo that update status to 'CLS' for check complete all payment or not -----//
			Vector checkIDocNoComplete = new Vector();
			
			//edit by pradoem 2023.07.04
			StringBuilder sqlB = new StringBuilder();
			sqlB.delete(0,sqlB.length());
			
			/*if(user.getUserCom().equals("LH")){
				//LH-ALL
				sqlB.append(" and not exists ( ")
				    .append(" select c.i_project from lan:serv_local c  ")
				    .append(" where  i_docno[1,2]= c.i_company ")
				    .append(" and  i_docno[4,6] = c.i_project ")
				    .append(" ) ");
	             //-- and  c.i_type = "NE"
			}else{		
			    //NE-ALL,LN-ALL
			    sqlB.append(" and  exists ( ")
				    .append(" select c.i_project from lan:serv_local c  ")
				    .append(" where  i_docno[1,2] = c.i_company ")
				    .append(" and  i_docno[4,6] = c.i_project ")
				    .append(" and  c.i_type = '"+user.getUserCom()+"' ")
				    .append(" ) ");
			}*/
			if(user.getUserCom().equals("LH")){
				//LH-ALL
				sqlB.append(" and not exists ( ")
				    .append(" select c.i_project from lan:serv_local c  ")
				    .append(" where  a.i_company = c.i_company ")
				    .append(" and  a.i_project = c.i_project ")
				    .append(" ) ");
	             //-- and  c.i_type = "NE"
			}else{		
			    //NE-ALL,LN-ALL
			    sqlB.append(" and  exists ( ")
				    .append(" select c.i_project from lan:serv_local c  ")
				    .append(" where  a.i_company = c.i_company ")
				    .append(" and  a.i_project  = c.i_project ")
				    .append(" and  c.i_type = '"+user.getUserCom()+"' ")
				    .append(" ) ");
			}
			if(user.getUserWho().equals("A")){ //lee admin
			   sqlB.delete(0,sqlB.length());
			}

			//-----============================ Approve Vendor Mode =======================================----//
			
			List payList = new ArrayList();
			List servflowList = new ArrayList();
			HashMap payHash = null;
			HashMap flowHash = null;
			
			if (mode.equalsIgnoreCase("APPROVE_COMPANY")) {
				String companyList[] = req.getParameterValues("i_company");
				if (companyList!=null) {

					String company = "";
					String iComment = "";
					String docno = "";
					String vendor = "";
					
					int cnt = 1;
					for (int i=0;i<companyList.length;i++) {
						     company = "";
							 company = doString.checkString(companyList[i],"");				
							
							//--====== For use multiple comment =======--//
							//String iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter(vendor+"_comment"),""));
						
							iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter("main_comment"),""));
							iComment = str.replace(iComment,"\r","");
							iComment = str.replace(iComment,"\n","|break|");	

					    
					    
						//---============== Get All iDocNo for this company for use in update payment and insert flow ===========---//
						/* remark by pradoem 2023.08.15 
						 * 
						 * sql.delete(0,sql.length());
						sql.append(" select distinct i_docno,i_vendor from lan:serv_payment where f_itmstatus='800' ")
							  .append(" and substr(i_docno,1,2)='").append(company).append("' ")
							  .append(" and d_payment = '").append(toDateEng(dPayment)).append("'")
							  .append(sqlB.toString());*/
							
						sql.delete(0,sql.length());
						sql.append(" select distinct b.i_docno,b.i_vendor from lan:serv_payment b,lan:serv_dochd a   ")
							.append(" where b.f_itmstatus='800' ")
							.append(" and a.f_status = 'OPN' ")
							.append(" and b.i_docno = a.i_docno   ")
							.append(" and a.i_company = '").append(company).append("' ")
							.append(" and b.d_payment = '").append(toDateEng(dPayment)).append("'")
							.append(sqlB.toString());

						System.out.println("Approve = "+sql.toString());
						rs = stmt.executeQuery(sql.toString());
						while (rs.next()) {
							 docno = "";
							 vendor = "";
							 docno = doString.checkString(rs.getString("i_docno"),"");
							 vendor = doString.checkString(rs.getString("i_vendor"),"");
							 checkIDocNoComplete.addElement(docno);

					         
							 /*remark by pradoem 2023.08.11*/
							//---================ Update SERV_PAYMENT =================----//
							/*sql.delete(0,sql.length());
							sql.append(" update lan:serv_payment  set ")				  
								  .append(" f_itmstatus='CLS' ") // set status to CLS , Close this payment
								  .append(" where i_docno='").append(docno).append("' ")				         
								  .append(" and i_vendor='").append(vendor).append("' ")				         
								  .append(" and f_itmstatus='800' ");	
							//System.out.println("SQL1111 = "+sql.toString());
							stmt1.executeUpdate(sql.toString());*/
							 
							 //modify by pradoem 2023.08.11
							 payHash = new HashMap();
							 payHash.put("xDATE_PAYMENT","");
							 payHash.put("xDOC_NO",docno);
							 payHash.put("xVENDOR_NO",vendor);
							 payList.add(payHash);

							//-----======================== Insert new SERV_FLOW =============================----//
							 /*remark by pradoem 2023.08.11*/
							/*sql.delete(0,sql.length());
							sql.append(" insert into lan:serv_flow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,f_reject,c_reject ")
								  .append(") values (")
								  .append(" '").append(docno).append("' , ")
								  .append(" '").append(vendor).append("' , ")
								  .append(" '800' , ") //-- Set Status to 800 , VP already approve ---//
								  .append(" '").append(nowDate).append("' , ")
								  .append(" '").append(user.getUserID()).append("' , ")
								  .append(" null , ")
								  .append(" '").append(iComment).append("') ");			
							//System.out.println("SQL22222 = "+sql.toString());
							stmt1.executeUpdate(sql.toString()); */
							 
							 //modify by pradoem 2023.08.11
							 flowHash = new HashMap();
							 flowHash.put("xDOC_NO",docno);
							 flowHash.put("xVENDOR_NO",vendor);
							 //flowHash.put("xNOW_DATE",nowDate);
							 flowHash.put("xEMP_ID",user.getUserID());
							 flowHash.put("xF_REJECT",""); //null
							 flowHash.put("xCOMMENT",iComment);
							 servflowList.add(flowHash);
							 
							//System.out.println("Add List Approve(servflowList,payList)  = "+cnt++);

						} // end while
						rs.close();
						
					} //# end for	
					
					
					conn.setAutoCommit(false);
					conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
					//modify by pradoem 2023.08.11
					if(payList!=null && payList.size()>0){
						UpdateServPayment(conn, payList);
					}
					if(servflowList!=null && servflowList.size()>0){
						InsertServflow(conn, servflowList);
					}
					conn.commit();
					System.out.println("==Approve Success==");

				} // end if check vendorList is not null						
			}			
			//-----========================================================================================----//
			
			
			
			//-----============================ Reject Vendor Mode =======================================----//
			if (mode.equalsIgnoreCase("REJECT_COMPANY")) {
				String companyList[] = req.getParameterValues("i_company");
				if (companyList!=null) {
					
					String company = "";
					String iComment = "";
					String docno = "";
					String vendor = "";
					String paymentDate = "";
					int cnt =1;
					for (int i=0;i<companyList.length;i++) {
							 company = doString.checkString(companyList[i],"");					
							
							//---======== For use multiple comment ==========---//
							//String iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter(vendor+"_comment"),""));
						    
							iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter("main_comment"),""));							
							iComment = str.replace(iComment,"\r","");
							iComment = str.replace(iComment,"\n","|break|");	

					    
					    
						//---============== Get All iDocNo for this company for use in update payment and insert flow ===========---//
						/* comment by pradoem 2023.08.16
						 * 
						 * sql.delete(0,sql.length());
						sql.append(" select distinct i_docno,i_vendor from lan:serv_payment where f_itmstatus='800' ")
							  .append(" and substr(i_docno,1,2)='").append(company).append("' ")
							  .append(" and d_payment = '").append(toDateEng(dPayment)).append("'")
							  .append(sqlB.toString());
							  
							  */
						
						sql.delete(0,sql.length());
						sql.append(" select distinct b.i_docno,b.i_vendor from lan:serv_payment b,lan:serv_dochd a   ")
								.append(" where b.f_itmstatus='800' ")
								.append(" and a.f_status = 'OPN' ")
								.append(" and b.i_docno = a.i_docno   ")
								.append(" and a.i_company = '").append(company).append("' ")
								.append(" and b.d_payment = '").append(toDateEng(dPayment)).append("'")
								.append(sqlB.toString());
						
						System.out.println("Reject = "+sql.toString());
						rs = stmt.executeQuery(sql.toString());
						while (rs.next()) {
							
							 docno = "";
							 vendor = "";
							 docno = doString.checkString(rs.getString("i_docno"),"");
							 vendor = doString.checkString(rs.getString("i_vendor"),"");					
							
							
							//---======== Select Payment Date from SERV_PAYSCHD  ===========----//
							paymentDate = "";
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
					       
					         
							//---================ Update SERV_PAYMENT =================----//
							/*sql.delete(0,sql.length());
							sql.append(" update lan:serv_payment  set ")
								  .append(" d_payment ='").append(paymentDate).append("' , ")									
								  .append(" f_itmstatus='400' ") // re-status to 400 , Send back to Contractor to approve and edit data again
								  .append(" where i_docno='").append(docno).append("' ")				         
								  .append(" and i_vendor='").append(vendor).append("' ")
								  .append(" and f_itmstatus='800' ");
							stmt1.executeUpdate(sql.toString());*/
							
							 
							 //modify by pradoem 2023.08.11
							 payHash = new HashMap();
							 payHash.put("xDATE_PAYMENT",paymentDate);
							 payHash.put("xDOC_NO",docno);
							 payHash.put("xVENDOR_NO",vendor);
							 payList.add(payHash);
				
				
							//-----======================== Insert new SERV_FLOW =============================----//
							/*sql.delete(0,sql.length());
							sql.append(" insert into lan:serv_flow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,f_reject,c_reject ")
								  .append(") values (")
								  .append(" '").append(docno).append("' , ")
								  .append(" '").append(vendor).append("' , ")
								  .append(" '800' , ") //-- Set Status to 800 , VP already reject ---//
								  .append(" '").append(nowDate).append("' , ")
								  .append(" '").append(user.getUserID()).append("' , ")
								  .append(" 'Y' , ")
								  .append(" '").append(iComment).append("') ");
							stmt1.executeUpdate(sql.toString());*/
							 
							 //modify by pradoem 2023.08.11
							 flowHash = new HashMap();
							 flowHash.put("xDOC_NO",docno);
							 flowHash.put("xVENDOR_NO",vendor);
							 //flowHash.put("xNOW_DATE",nowDate);
							 flowHash.put("xEMP_ID",user.getUserID());
							 flowHash.put("xF_REJECT","Y");
							 flowHash.put("xCOMMENT",iComment);
							 servflowList.add(flowHash);
							 
							 //System.out.println("Add List Reject(servflowList,payList)  = "+cnt++);
					         
						} // end while
						rs.close();
						
					} // end for	
					
					conn.setAutoCommit(false);
					conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
					//modify by pradoem 2023.08.11
					if(payList!=null && payList.size()>0){
						UpdateServPaymentByStatus(conn, payList,"400");
					}
					if(servflowList!=null && servflowList.size()>0){
						InsertServflowReject(conn, servflowList);
					}
					conn.commit();
			
				} // end if check vendorList is not null								
			}				
			//-----========================================================================================----//
			

			
			//-----============================ Approve Mode =======================================----//
			else if (mode.equalsIgnoreCase("APPROVE_PROJECT")) {
				String iItmJob[] = req.getParameterValues("i_project");
				if (iItmJob!=null) {
									
					String item = "";
					String company = "";
					String project = "";
					String iComment = "";
					String docno = "";
					String vendor = "";
					for (int i=0;i<iItmJob.length;i++) {
						    item = "";
							item = doString.checkString(iItmJob[i],"");
							StringTokenizer id = new StringTokenizer(item,":");
							if (id.countTokens()!=2) continue;				
							
							 company = "";
							 project = "";
							 company = id.nextToken();
							 project = id.nextToken();			
					
							//----========== For use multiple comment =========---//
							//String iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter(item+"_comment"),""));
						    
							iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter("main_comment"),""));
							iComment = str.replace(iComment,"\r","");
							iComment = str.replace(iComment,"\n","|break|");	


							//---============== Get All iDocNo for this project for use in update payment and insert flow ===========---//
							/*sql.delete(0,sql.length());
							sql.append(" select distinct i_docno,i_vendor from lan:serv_payment where f_itmstatus='800' ")
								  .append(" and substr(i_docno,1,2)='").append(company).append("' ")
						      	  .append(" and substr(i_docno,4,3)='").append(project).append("' ")
						      	  .append(" and d_payment = '").append(toDateEng(dPayment)).append("'")
								  .append(sqlB.toString()); */
							
							
							sql.delete(0,sql.length());
							sql.append(" select distinct b.i_docno,b.i_vendor from lan:serv_payment b,lan:serv_dochd a   ")
								.append(" where b.f_itmstatus='800' ")
								.append(" and a.f_status = 'OPN' ")
								.append(" and b.i_docno = a.i_docno   ")
								.append(" and a.i_company = '").append(company).append("' ")
								.append(" and a.i_project = '").append(project).append("' ")
								.append(" and b.d_payment = '").append(toDateEng(dPayment)).append("'")
								.append(sqlB.toString());
							
							rs = stmt.executeQuery(sql.toString());
							while (rs.next()) {
								 docno = doString.checkString(rs.getString("i_docno"),"");
								 vendor = doString.checkString(rs.getString("i_vendor"),"");
								 checkIDocNoComplete.addElement(docno);
													    
						
								//---================ Update SERV_PAYMENT =================----//
								/*sql.delete(0,sql.length());
								sql.append(" update lan:serv_payment  set ")				  
									  .append(" f_itmstatus='CLS' ") // set status to CLS , Close this payment
									  .append(" where i_docno='").append(docno).append("' ")				         
									  .append(" and i_vendor='").append(vendor).append("' ")				         
									  .append(" and f_itmstatus='800' ");							  
								stmt1.executeUpdate(sql.toString()); */
								 //modify by pradoem 2023.08.11
								 payHash = new HashMap();
								 payHash.put("xDATE_PAYMENT","");
								 payHash.put("xDOC_NO",docno);
								 payHash.put("xVENDOR_NO",vendor);
								 payList.add(payHash);
														
								
								//-----======================== Insert new SERV_FLOW =============================----//
								/*sql.delete(0,sql.length());
								sql.append(" insert into lan:serv_flow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,f_reject,c_reject ")
									  .append(") values (")
									  .append(" '").append(docno).append("' , ")
									  .append(" '").append(vendor).append("' , ")
									  .append(" '800' , ") //-- Set Status to 800 , VP already approve ---//
									  .append(" '").append(nowDate).append("' , ")
									  .append(" '").append(user.getUserID()).append("' , ")
									  .append(" null , ")
									  .append(" '").append(iComment).append("') ");
								 stmt1.executeUpdate(sql.toString());
								 */
								 //modify by pradoem 2023.08.11
								 flowHash = new HashMap();
								 flowHash.put("xDOC_NO",docno);
								 flowHash.put("xVENDOR_NO",vendor);
								 //flowHash.put("xNOW_DATE",nowDate);
								 flowHash.put("xEMP_ID",user.getUserID());
								 flowHash.put("xF_REJECT","");
								 flowHash.put("xCOMMENT",iComment);
								 servflowList.add(flowHash);
								//-----==================================================================================----//
							
							
						} // end while
						rs.close();
						
					} // end for	
					
					conn.setAutoCommit(false);
					conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
					//modify by pradoem 2023.08.11
					if(payList!=null && payList.size()>0){
						UpdateServPayment(conn, payList);
					}
					if(servflowList!=null && servflowList.size()>0){
						InsertServflow(conn, servflowList);
					}
					conn.commit();
									
				} // end if check i_itmjob is not null									
			}
			//-----===============================================================================----//

			//-----============================ Reject Mode =======================================----//
			else if (mode.equalsIgnoreCase("REJECT_PROJECT")) {
				String iItmJob[] = req.getParameterValues("i_project");
				if (iItmJob!=null) {
					String item = "";
					String company = "";
					String project = "";
					String iComment = "";
					String docno = "";
					String vendor = "";				
					String paymentDate = "";
					for (int i=0;i<iItmJob.length;i++) {
							 item = doString.checkString(iItmJob[i],"");
							StringTokenizer id = new StringTokenizer(item,":");
							if (id.countTokens()!=2) continue;	
							
							 company = "";
							 project = "";
							 company = id.nextToken();
							 project = id.nextToken();	
							
							//----========== For use multiple comment ===========---//				
							//String iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter(item+"_comment"),""));
						    
						    iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter("main_comment"),""));
							iComment = str.replace(iComment,"\r","");
							iComment = str.replace(iComment,"\n","|break|");												
											

						//---============== Get All iDocNo for this project for use in update payment and insert flow ===========---//
						/* comment by pradoem 2023.08.16
						 * 
						 * sql.delete(0,sql.length());
						sql.append(" select distinct i_docno,i_vendor from lan:serv_payment where f_itmstatus='800' ")
							  .append(" and substr(i_docno,1,2)='").append(company).append("' ")
							  .append(" and substr(i_docno,4,3)='").append(project).append("' ")
							  .append(" and d_payment = '").append(toDateEng(dPayment)).append("'")
							  .append(sqlB.toString());*/
							
						sql.delete(0,sql.length());
						sql.append(" select distinct b.i_docno,b.i_vendor from lan:serv_payment b,lan:serv_dochd a   ")
								.append(" where b.f_itmstatus='800' ")
								.append(" and a.f_status = 'OPN' ")
								.append(" and b.i_docno = a.i_docno   ")
								.append(" and a.i_company = '").append(company).append("' ")
								.append(" and a.i_project = '").append(project).append("' ")
								.append(" and b.d_payment = '").append(toDateEng(dPayment)).append("'")
								.append(sqlB.toString());	
							
						rs = stmt.executeQuery(sql.toString());
						while (rs.next()) {
							 docno = doString.checkString(rs.getString("i_docno"),"");
							 vendor = doString.checkString(rs.getString("i_vendor"),"");											
											

							//---======== Select Payment Date from SERV_PAYSCHD  ===========----//
							paymentDate = "";
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
											
											
							/*sql.delete(0,sql.length());
							sql.append(" update lan:serv_payment  set ")
								  .append(" d_payment ='").append(paymentDate).append("' , ")									
								  .append(" f_itmstatus='400' ") // re-status to 400 , Send back to Contractor to approve and edit data again
								  .append(" where i_docno='").append(docno).append("' ")				         
								  .append(" and i_vendor='").append(vendor).append("' ")
								  .append(" and f_itmstatus='800' ");
							stmt1.executeUpdate(sql.toString());*/
							
							 //modify by pradoem 2023.08.11
							 payHash = new HashMap();
							 payHash.put("xDATE_PAYMENT",paymentDate);
							 payHash.put("xDOC_NO",docno);
							 payHash.put("xVENDOR_NO",vendor);
							 payList.add(payHash);
								
							//-----======================== Insert new SERV_FLOW =============================----//
							/*sql.delete(0,sql.length());
							sql.append(" insert into lan:serv_flow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,f_reject,c_reject ")
								  .append(") values (")
								  .append(" '").append(docno).append("' , ")
								  .append(" '").append(vendor).append("' , ")
								  .append(" '800' , ") //-- Set Status to 800 , VP already reject ---//
								  .append(" '").append(nowDate).append("' , ")
								  .append(" '").append(user.getUserID()).append("' , ")
								  .append(" 'Y' , ")
								  .append(" '").append(iComment).append("') ");
							stmt1.executeUpdate(sql.toString());*/
							
							 //modify by pradoem 2023.08.11
							 flowHash = new HashMap();
							 flowHash.put("xDOC_NO",docno);
							 flowHash.put("xVENDOR_NO",vendor);
							 //flowHash.put("xNOW_DATE",nowDate);
							 flowHash.put("xEMP_ID",user.getUserID());
							 flowHash.put("xF_REJECT","Y");
							 flowHash.put("xCOMMENT",iComment);
							 servflowList.add(flowHash);
						   //-----==================================================================================----//
							
						} // end while
						rs.close();
																	
					} // end for	
					
					
					conn.setAutoCommit(false);
					conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
					//modify by pradoem 2023.08.11
					if(payList!=null && payList.size()>0){
						UpdateServPaymentByStatus(conn, payList,"400");
					}
					if(servflowList!=null && servflowList.size()>0){
						InsertServflowReject(conn, servflowList);
					}
					conn.commit();				
					
									
				} // end if check i_itmjob is not null							
			}			 
			//-----===============================================================================----//



			//-----=========== Check if some iDocNo has set to 'CLS' , check is complete or not ==========-----//
			if (checkIDocNoComplete.size()>0) {
				 String docno = "";
				 String status = "";
				 String dCloseLaw = "";
				 String venNo = "";
				 String iModel = "";
				 
				for (int l=0;l<checkIDocNoComplete.size();l++) {
					   docno = "";
					   docno = doString.checkString((String) checkIDocNoComplete.elementAt(l),"");
					   boolean allComplete = false;
					   
					   /*
					   sql.delete(0,sql.length());
					   sql.append(" select f_itmstatus from lan:serv_payment ")
					         .append(" where i_docno='").append(docno).append("' and f_itmstatus<>'CLS' ");
						rs = stmt.executeQuery(sql.toString());
						if (rs.next()) {
							allComplete = false;
						} else {
							allComplete = true;
						}
						rs.close();
						*/

					   sql.delete(0,sql.length());
				  	   sql.append(" select b.f_itmstatus as pay_status from lan:serv_docdt a ")
						     .append(" left join lan:serv_payment b on b.i_docno=a.i_docno and b.i_itmjob=a.i_itmjob and b.i_vendor=a.i_vendor ")
						     .append(" where a.i_docno='").append(docno).append("' ");
						rs = stmt.executeQuery(sql.toString());
						
						while (rs.next()) {
							status = "";
							status = doString.checkString(rs.getString("pay_status"),"");
							if (status.equalsIgnoreCase("CLS")) {
								allComplete = true;
							} else {
								allComplete = false;
								break; 
							}
						} // end while
						rs.close();
						
						
						if (allComplete) {
							//---============= Find other data for update SERV_DOCHD ===============----//
							 dCloseLaw = "";
							 venNo = "";
							 iModel = "";
							 
							sql.delete(0,sql.length());
							sql.append(" select b.d_close_law,c.ven_no,c.i_model from lan:serv_dochd a ")
							      .append(" left join lan:acscontr b on b.i_company=a.i_company and b.i_project=a.i_project and b.i_sort=a.i_lock and b.f_contr is null ")
							      .append(" left join lan:unit c on c.i_company=a.i_company and c.i_project=a.i_project and c.i_lock=a.i_lock and c.unit_status='OPN' ")
							      .append(" where a.i_docno='").append(docno).append("' ");
							rs = stmt.executeQuery(sql.toString());
							if (rs.next()) {
								venNo = doString.checkString(rs.getString("ven_no"),"");
								iModel = doString.checkString(rs.getString("i_model"),"");
								
								Calendar est = Calendar.getInstance(Locale.ENGLISH);
								Timestamp tmp = rs.getTimestamp("d_close_law");
								if (tmp!=null) {
								   est.setTime(tmp);
								   dCloseLaw = " '"+str.createID(est.get(Calendar.YEAR),4);
								   dCloseLaw += "-"+str.createID((est.get(Calendar.MONTH)+1),2);
								   dCloseLaw += "-"+str.createID(est.get(Calendar.DATE),2)+"' ";
								} else {
									dCloseLaw = " null ";
								}								
							}
							rs.close();							
														
							//---====== Update serv_dochd to 'CLS' when is complete all payment ========----//
							sql.delete(0,sql.length());
							sql.append(" update lan:serv_dochd set ")
							      .append(" f_status='CLS' , ")
								  .append(" d_close=today , ")							      
								  .append(" d_close_law=").append(dCloseLaw).append(" , ")
								  .append(" i_venno='").append(venNo).append("' , ")
								  .append(" i_model='").append(iModel).append("' ")
						          .append(" where i_docno='").append(docno).append("' ");
							stmt1.executeUpdate(sql.toString());						          
						}
								   
				} // end for 
			}

			//conn.commit();
			System.out.println(" ===conn.commit(); ==== ");
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
	
    //Generic Type : 
	public int UpdateServPaymentByStatus(Connection conn,List<HashMap>  hObjList,String status) {
		  	StringBuffer sql = new StringBuffer();	
		  	PreparedStatement pstmtBatch = null;
		  	ResultSet rs = null;
		  	
		      try{
		      	//initial parameter	
		      	int cnt = 0;
		      	if(hObjList!=null && hObjList.size()>0){
		          	 int i=1;
		          	 HashMap hItm = null;	        		 	        	
		  			/******************************************************/
		          	
					sql.append(" update lan:serv_payment  set ")
					  .append(" d_payment = ? , ")									
					  .append(" f_itmstatus= '"+status+"' ") // re-status to 400 , Send back to Contractor to approve and edit data again
					  .append(" where i_docno= ? ")				         
					  .append(" and i_vendor= ? ")
					  .append(" and f_itmstatus='800' ");
		          	

		  			System.out.println("SQL :"+sql.toString());	
	          		pstmtBatch = conn.prepareStatement(sql.toString());
					//================
					int count = 0;
					int batchSize = 1000;
					//================
		          	for (Iterator<HashMap> iter = hObjList.iterator(); iter.hasNext(); ) {
		          		hItm =  (HashMap)iter.next();
		          		i = 1;   
		          		
		          		pstmtBatch.setString(i++, hItm.get("xDATE_PAYMENT").toString());
		          		pstmtBatch.setString(i++, hItm.get("xDOC_NO").toString());
		          		pstmtBatch.setString(i++, hItm.get("xVENDOR_NO").toString());

		          		//TODO:Insert : add batch		          		
		          	    pstmtBatch.addBatch();
		          	    count++;
		          	    //System.out.println("UpdateServPaymentByStatus addBatch :"+count);	
		   			    if(count % batchSize == 0){
		   				  System.out.println("Commit the batch");
		   				  int[] result = pstmtBatch.executeBatch();
		   				  cnt = result.length;
		   				  System.out.println("Number of rows Update: "+ result.length);
		   				  // Clear the batch
		   				  pstmtBatch.clearBatch();
		   			   }
		  			   	
		          	}//#End For Loop	   
		        	//TODO: Action ExecuteBacth Insert
		          	// Execute the remaining batch
		            if (count % batchSize != 0) {
			        	int[] bcnt = pstmtBatch.executeBatch();	
			        	cnt = cnt+bcnt.length;
		            }

		        	System.out.println("---UpdateServPaymentByStatus Count Update  : "+cnt);	
		        	System.out.println("---UpdateServPaymentByStatus Action ExecuteBacth Update Completed ");
		  			//***************************************************/	 	
		      	}	
		      	return cnt;
		  	}catch(Exception e){
		  		System.out.println("!!! UpdateServPaymentByStatus , " + e.getMessage());
		  		System.out.println("!!! UpdateServPaymentByStatus,SQL Exception: "+sql.toString());	
		  		return -1;
		  	}
		  	finally{			
		  		//clean up.
		  		try{
		  			if(rs!=null){rs.close();}
		  			if(pstmtBatch!=null){pstmtBatch.close();}
		  		}catch(Exception e){}
		  	}
    }
	
	
    //Generic Type : 
	public int UpdateServPayment(Connection conn,List<HashMap>  hObjList) {
		  	StringBuffer sql = new StringBuffer();	
		  	//PreparedStatement pstmt = null;
		  	PreparedStatement pstmtBatch = null;
		  	ResultSet rs = null;
		  	
		      try{
		      	//initial parameter	
		      	int cnt = 0;
		      	if(hObjList!=null && hObjList.size()>0){
		          	int i=1;
		          	HashMap hItm = null;	        		 	        	
		  			/******************************************************/
					sql.append(" update lan:serv_payment  set ")				  
					  .append("  f_itmstatus = 'CLS' ") // set status to CLS , Close this payment
					  .append("  where i_docno= ? ")				         
					  .append("  and i_vendor= ? ")				         
					  .append("  and f_itmstatus='800' ");	

		  			System.out.println("SQL :"+sql.toString());	
	          		pstmtBatch = conn.prepareStatement(sql.toString());
					//================
					int count = 0;
					int batchSize = 1000;
					//================
		          	for (Iterator<HashMap> iter = hObjList.iterator(); iter.hasNext(); ) {
		          		hItm =  (HashMap)iter.next();
		          		i = 1;   
		          		
		          		pstmtBatch.setString(i++, hItm.get("xDOC_NO").toString());
		          		pstmtBatch.setString(i++, hItm.get("xVENDOR_NO").toString());

		          		//TODO:Insert : add batch		          		
		          	    pstmtBatch.addBatch();
		          	    count++;
		          	   // System.out.println("UpdateServPayment addBatch :"+count);	
		   			    if(count % batchSize == 0){
		   				  System.out.println("Commit the batch");
		   				  int[] result = pstmtBatch.executeBatch();
		   				  cnt = result.length;
		   				  System.out.println("Number of rows Update: "+ result.length);
		   				  // Clear the batch
		   				  pstmtBatch.clearBatch();
		   			   }
		  			   	
		          	}//#End For Loop	   
		        	//TODO: Action ExecuteBacth Insert
		          	// Execute the remaining batch
		            if (count % batchSize != 0) {
			        	int[] bcnt = pstmtBatch.executeBatch();	
			        	cnt = cnt+bcnt.length;
		            }
		        	System.out.println("UpdateServPayment---Count Update  : "+cnt);	
		        	System.out.println("UpdateServPayment---Action ExecuteBacth Update Completed ");
		  			//***************************************************/	 	
		      	}	
		      	return cnt;
		  	}catch(Exception e){
		  		System.out.println("!!! UpdateServPayment , " + e.getMessage());
		  		System.out.println("!!! UpdateServPayment,SQL Exception: "+sql.toString());	
		  		return -1;
		  	}
		  	finally{			
		  		//clean up.
		  		try{
		  			if(rs!=null){rs.close();}
		  			if(pstmtBatch!=null){pstmtBatch.close();}
		  		}catch(Exception e){}
		  	}
    }
	
    //Generic Type : 
	public int InsertServflow(Connection conn,List<HashMap>  hObjList) {
		  	StringBuffer sql = new StringBuffer();	
		  	//PreparedStatement pstmt = null;
		  	PreparedStatement pstmtBatch = null;
		  	ResultSet rs = null;
		  	
		      try{
		      	//initial parameter	
		      	int cnt = 0;
		      	if(hObjList!=null && hObjList.size()>0){
		          	int i=1;
		         	HashMap hItm = null;	 	 	        	
		  			/******************************************************/	       
		         	
		         	/*sql.delete(0,sql.length());
					sql.append(" insert into lan:serv_flow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,f_reject,c_reject ")
						  .append(") values (")
						  .append(" '").append(docno).append("' , ")
						  .append(" '").append(vendor).append("' , ")
						  .append(" '800' , ") //-- Set Status to 800 , VP already approve ---//
						  .append(" '").append(nowDate).append("' , ")
						  .append(" '").append(user.getUserID()).append("' , ")
						  .append(" null , ")
						  .append(" '").append(iComment).append("') "); */
		         
		         	
					sql.delete(0,sql.length());
					sql.append(" insert into lan:serv_flow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,c_reject ")
						  .append(" ) values ( ")
						  .append(" ? , ?  , '800' , current , ? , ?  )");
					
		  			System.out.println("SQL :"+sql.toString());	
	          		pstmtBatch = conn.prepareStatement(sql.toString());
					//================
					int count = 0;
					int batchSize = 1000;
					//================
		          	for (Iterator<HashMap> iter = hObjList.iterator(); iter.hasNext(); ) {
		          		hItm = (HashMap)iter.next();
		          		i = 1;          		

		          		pstmtBatch.setString(i++, hItm.get("xDOC_NO").toString());
		          		pstmtBatch.setString(i++, hItm.get("xVENDOR_NO").toString());
		          		//pstmtBatch.setString(i++, hItm.get("xNOW_DATE").toString());
		          		pstmtBatch.setString(i++, hItm.get("xEMP_ID").toString());
		          		pstmtBatch.setString(i++, hItm.get("xCOMMENT").toString());

		          		//TODO:Insert : add batch
		          		pstmtBatch.addBatch();
		          		count++;
		          		//System.out.println("addBatch :"+count);	
		   			    if(count % batchSize == 0){
		   			    	System.out.println("Commit the batch");
		   				    int[] result = pstmtBatch.executeBatch();
		   				    cnt = result.length;
		   				    System.out.println("executeBatch cnt : "+ cnt);
		   				    System.out.println("Number of rows inserted: "+ result.length);
		                    // Clear the batch
		   				    pstmtBatch.clearBatch();
		   			   }
		  			   	
		          	}//#End For Loop	   
		        	//TODO: Action ExecuteBacth Insert
		          	// Execute the remaining batch
		            if (count % batchSize != 0) {
			        	int[] bcnt = pstmtBatch.executeBatch();	
			        	cnt = cnt+bcnt.length;
		            }
		        	System.out.println("---Insert InsertServflow Total :"+cnt);
		        	System.out.println("---List Insert size:"+ hObjList.size());	
		        	System.out.println("---Action ExecuteBacth Insert Completed ");
		  			//********************************************************/
		  		  	//Log.info("##InsertStgJourdDt ->end.");		 	
		      	}	
		      	return cnt;
		  	}catch(Exception e){
		  		System.out.println("!!! InsertServflow , " + e.getMessage());
		  		System.out.println("!!! InsertServflow,SQL Exception: "+sql.toString());	
		  		return -1;
		  	}
		  	finally{			
		  		//clean up.
		  		try{
		  			if(rs!=null){rs.close();}
		  			if(pstmtBatch!=null){pstmtBatch.close();}
		  		}catch(Exception e){}
		  	}
    }
	
	  //Generic Type : 
	public int InsertServflowReject(Connection conn,List<HashMap>  hObjList) {
		  	StringBuffer sql = new StringBuffer();	
		  	//PreparedStatement pstmt = null;
		  	PreparedStatement pstmtBatch = null;
		  	ResultSet rs = null;
		  	
		      try{
		      	//initial parameter	
		      	int cnt = 0;
		      	if(hObjList!=null && hObjList.size()>0){
		          	int i=1;
		         	HashMap hItm = null;	 	 	        	
		  			/******************************************************/	       
		         	
		         	/*sql.delete(0,sql.length());
					sql.append(" insert into lan:serv_flow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,f_reject,c_reject ")
						  .append(") values (")
						  .append(" '").append(docno).append("' , ")
						  .append(" '").append(vendor).append("' , ")
						  .append(" '800' , ") //-- Set Status to 800 , VP already approve ---//
						  .append(" '").append(nowDate).append("' , ")
						  .append(" '").append(user.getUserID()).append("' , ")
						  .append(" null , ")
						  .append(" '").append(iComment).append("') "); */
		         
		         	
					sql.delete(0,sql.length());
					sql.append(" insert into lan:serv_flow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,f_reject,c_reject ")
						  .append(" ) values ( ")
						  .append(" ? , ?  , '800' , current , ? , ? , ? )");
					
		  			System.out.println("SQL :"+sql.toString());	
	          		pstmtBatch = conn.prepareStatement(sql.toString());
					//================
					int count = 0;
					int batchSize = 1000;
					//================
		          	for (Iterator<HashMap> iter = hObjList.iterator(); iter.hasNext(); ) {
		          		hItm = (HashMap)iter.next();
		          		i = 1;          		

		          		pstmtBatch.setString(i++, hItm.get("xDOC_NO").toString());
		          		pstmtBatch.setString(i++, hItm.get("xVENDOR_NO").toString());
		          		//800
		          		//pstmtBatch.setString(i++, hItm.get("xNOW_DATE").toString());
		          		pstmtBatch.setString(i++, hItm.get("xEMP_ID").toString());		          		
		          		pstmtBatch.setString(i++, hItm.get("xF_REJECT").toString());
		          		pstmtBatch.setString(i++, hItm.get("xCOMMENT").toString());

		          		//TODO:Insert : add batch
		          		pstmtBatch.addBatch();
		          		count++;
		          		//System.out.println("addBatch :"+count);	
		   			    if(count % batchSize == 0){
		   			    	System.out.println("Commit the batch");
		   				    int[] result = pstmtBatch.executeBatch();
		   				    cnt = result.length;
		   				    System.out.println("executeBatch cnt : "+ cnt);
		   				    System.out.println("Number of rows inserted: "+ result.length);
		                    // Clear the batch
		   				    pstmtBatch.clearBatch();
		   			   }
		  			   	
		          	}//#End For Loop	   
		        	//TODO: Action ExecuteBacth Insert
		          	// Execute the remaining batch
		            if (count % batchSize != 0) {
			        	int[] bcnt = pstmtBatch.executeBatch();	
			        	cnt = cnt+bcnt.length;
		            }
		        	System.out.println("---Insert InsertServflow Total :"+cnt);
		        	System.out.println("---List Insert size:"+ hObjList.size());	
		        	System.out.println("---Action ExecuteBacth Insert Completed ");
		  			//********************************************************/
		  		  	//Log.info("##InsertStgJourdDt ->end.");		 	
		      	}	
		      	return cnt;
		  	}catch(Exception e){
		  		System.out.println("!!! InsertServflow , " + e.getMessage());
		  		System.out.println("!!! InsertServflow,SQL Exception: "+sql.toString());	
		  		return -1;
		  	}
		  	finally{			
		  		//clean up.
		  		try{
		  			if(rs!=null){rs.close();}
		  			if(pstmtBatch!=null){pstmtBatch.close();}
		  		}catch(Exception e){}
		  	}
    }
	
	private static  String toDateEng(String str){
		 if ((str == null) || str.equals("")) {
			 return  str;
		 }else{
			 String d2[] = str.split("\\/"); //03/08/2566
			// return d2[2]+"-"+d2[1]+"-"+(Integer.parseInt(d2[0])-543);
			 return (Integer.parseInt(d2[2])-543)+"-"+d2[1]+"-"+d2[0];
		 }
	}

}
