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
public class SERV_Add_RetRetenServlet extends DBServlet  {
	
	 
	private void genRedirectCode(PrintWriter out,String page,String redirect,String error,String otherMsg) {
		out.println("<form method='post' action='"+page+"'>");		
		out.println("<input type='hidden' name='error' value='"+error+"'>");
		out.println("<input type='hidden' name='other_msg' value='"+doString.MS874ToUnicode(otherMsg)+"'>");
		out.println("<input type='hidden' name='redirect_url' value='"+doString.MS874ToUnicode(redirect)+"'>");		
		out.println("<script> document.forms[0].submit();</script>");
		out.println("</form>");		
	}
	
	public double getDoubleValue(String str) {
		 double result = 0.0;
		 str = doString.checkString(str,"0.0");
		 
		 while (str.indexOf(",")>0) {
		 	str = str.substring(0,str.indexOf(","))+str.substring(str.indexOf(",")+1);
		 } // end while
		 
		 try {
		 	result = Double.parseDouble(str);
		 } catch (Exception e) {
		 	result = 0.0; 
		 }
		 
		 return result;
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
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
		
	
		String iDocNo = doString.checkString(req.getParameter("i_docno"),"");
		String iCompany = doString.checkString(req.getParameter("i_company"),"");
		String iProject = doString.checkString(req.getParameter("i_project"),"");
		String iDocStauts = doString.checkString(req.getParameter("i_doc_status"),"");
		String iInSpec = doString.UnicodeToMS874(doString.checkString(req.getParameter("i_inspec"),""));
		String iCurApprove = doString.checkString(req.getParameter("i_cur_apprv"),"");
		String approveFlag = doString.checkString(req.getParameter("approve_flag"),"");
		String cPayback = doString.UnicodeToMS874(doString.checkString(req.getParameter("c_payback"),""));
		String cDamage = "";
		String fInSpec = doString.checkString(req.getParameter("f_inspec"),"Y");
		if (fInSpec.equalsIgnoreCase("N")) {
			cDamage =doString.UnicodeToMS874(doString.checkString(req.getParameter("c_damage"),""));
		}		
		double zDamage = getDoubleValue(req.getParameter("z_damage"));
		double zReten = getDoubleValue(req.getParameter("z_reten"));	
		
		
		//---- 2023-02-22 , for payin input ----//
		String iPayType = doString.checkString(req.getParameter("iPayType"),"PAYIN");
		String iPayBnk = doString.checkString(req.getParameter("iPayBnk"),"");
		String iPayAcc = doString.checkString(req.getParameter("iPayAcc"),"");
		String iEmail = doString.checkString(req.getParameter("iEmail"),"");
		//--------------------------------------//					
		
		
		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_Add_RetReten.jsp?i_docno="+iDocNo;
		String errorPage = "SERV_Add_RetReten.jsp?error=1&refresh=yes&i_docno="+iDocNo;
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
		   
	
		   			System.out.println("---------------------Start Update RetReten ----------------------");
		   			
		   			
					//----- Read Bank name , branch and account --------//		
					String pvBank = "";
					String pvBran = "";
					String pvAcc = "";				
					sql.delete(0,sql.length());
					sql.append(" select * from docflow:icv_acctn where i_system='RET' ")
					      .append(" and i_com_exp='").append(iCompany).append("' ");		  
					rs = stmt.executeQuery(sql.toString());
					if (rs.next()) {
						pvBank = doString.checkString(rs.getString("i_pv_bank"),"");
						pvBran = doString.checkString(rs.getString("i_pv_bran"),"");
						pvAcc = doString.checkString(rs.getString("i_pv_acctyp"),"");
					} 
					rs.close();				   			
		   			
		   			
					sql.delete(0,sql.length());
				 	sql.append(" update lan:serv_rethd set ")
					      .append(" i_reten_payback='").append(user.getEmpId()).append("' , ")
	 		              .append(" d_reten_payback=current , ")
	 		              .append(" d_est_chq=today+15 , ") // 2024-11-26 , always use today+15 for estimated receive cheque date
	 		              .append(" d_staff_payback=current , ") // 2024-12-16 , always use today for staff send request date
			              .append(" f_post='N', ")				 	
						  .append(" i_pv_bank='").append(pvBank).append("' , ")			 	
						  .append(" i_pv_bran='").append(pvBran).append("' , ")				 	
						  .append(" i_acctyp='").append(pvAcc).append("' , ");

					if (fInSpec.equalsIgnoreCase("Y")) {
						sql.append(" f_inspec='Y' , ")
						      .append(" i_inspec=null , ")
						      .append(" c_damage=null , ");      	
					} else {
						sql.append(" f_inspec='N' , ")
						      .append(" i_inspec='").append(iInSpec).append("' , ")
						      .append(" c_damage='").append(cDamage).append("' , ");			       	
					}
			           
			           
			       String iDocStatus = "";
			       String useZApprover = doString.checkString(req.getParameter("use_z_approver"),"");
			       if (!approveFlag.equalsIgnoreCase("Y")) {
			       	   iDocStatus = "S";
			       } else if (useZApprover.trim().equalsIgnoreCase("Y")) {
			       	   iDocStatus = "G";
			       } else { 
			       	   iDocStatus = "W";
			       }
			      sql.append(" i_doc_status='").append(iDocStatus).append("' , ")
				        .append(" i_cur_apprv='").append(iCurApprove).append("' , ");				       
/*			           
			       if (!approveFlag.equalsIgnoreCase("Y")) {
						sql.append(" i_doc_status='S' , ")
							  .append(" i_cur_apprv='").append(iCurApprove).append("' , ");	
			       } else {
						sql.append(" i_doc_status='W' ,  ")
							  .append(" i_cur_apprv='").append(iCurApprove).append("' , ");					       		
			       }
*/
				  sql.append(" z_damage=").append(zDamage).append(" , ")
				        .append(" z_payback=").append(zReten-zDamage).append(" , ")
 			            .append(" c_payback='").append(cPayback).append("' ");				  
				  
					//------ 2023-02-22 , add new field ------//
					if (iPayType.equalsIgnoreCase("PAYIN")) {
						sql.append(", i_paytype='PAYIN' ")						
						   .append(", i_paybnk='"+iPayBnk+"' ")						
						   .append(", i_payacc='"+iPayAcc+"' ")						
						   .append(", i_email='"+iEmail+"' ");					
					} else {
						sql.append(", i_paytype='PAYTO' ")						
						   .append(", i_paybnk=null ")						
						   .append(", i_payacc=null ")						
						   .append(", i_email=null ");
					}											
					//----------------------------------------//				  
				  
				   sql.append(" where i_docno='").append(iDocNo).append("' ");
				   stmt.executeUpdate(doString.UnicodeToMS874(sql.toString()));
				   System.out.println("--------------------- executeUpdate SERV_RETHD ----------------------");		   	



				
					//================================== If Approve =======================================//
					if (approveFlag.equalsIgnoreCase("Y")) {
						//----- Clear old flow for this document ----------//
						sql.delete(0,sql.length());
						sql.append(" delete from lan:serv_apprv where i_docno='").append(iDocNo).append("' ");
						stmt.executeUpdate(sql.toString());
						System.out.println("--------------------- delete SERV_APPRV ----------------------");		   	

						//------- Insert new Flow for this document ------//												 
						sql.delete(0,sql.length());
						sql.append(" insert into lan:serv_apprv (i_flow,i_docno,i_doc_status,i_apprv,d_apprv) ")
						      .append(" values ('R' , '").append(iDocNo).append("' , ")
						      .append(" '").append(iDocStatus).append("' , ")
						      .append(" '").append(user.getEmpId()).append("' , today) "); // old is iCurApprv
						stmt.executeUpdate(sql.toString());
						System.out.println("--------------------- insert SERV_APPRV ----------------------");		
						
						
						
						//----- Read Status Details --------//	
						String statusDesc = "";					
						sql.delete(0,sql.length());
						sql.append(" select n_desc from lan:serv_xstd where i_type='60' and i_code='").append(iDocStatus).append("' ");	
						rs = stmt.executeQuery(sql.toString());
						if (rs.next()) {
							statusDesc = doString.checkString(rs.getString("n_desc"),"");
						} 
						rs.close();	
						
						
						//----- Read i_reten_payback Name --------//		
						String paybackEmp = "";	
						String iSort = "";			
						sql.delete(0,sql.length());
						sql.append(" select trim(b.n_prename_th)||trim(b.n_nemploy_th)||' '||trim(b.n_semploy_th) ")
						      .append(" as emp_name,a.i_sort from lan:serv_rethd a ")
							  .append(" left join docflow:acemploy b on b.i_employ=a.i_reten_payback ")		  
							  .append(" where a.i_docno='").append(iDocNo).append("' ");
						rs = stmt.executeQuery(sql.toString());
						if (rs.next()) {
							paybackEmp = doString.checkString(rs.getString("emp_name"),"");
							iSort = doString.checkString(rs.getString("i_sort"),"");
						} 
						rs.close();			
						
												

						//----- Read Approver Details for send mail --------//						
						sql.delete(0,sql.length());
						sql.append(" select * from lan:useracl where i_employ='").append(iCurApprove).append("' and user_acl='S'  ");	
						rs = stmt.executeQuery(sql.toString());
						if (rs.next()) {
							String email = doString.checkString(rs.getString("user_email"),"");
							String userWho = doString.checkString(rs.getString("user_who"),"");
							
							
							//------ Validate Email before send ------//
							if (email.trim().length()>0) {
								String subject = " เอกสารขอคืนเงินค้ำประกัน เลขที่ "+iDocNo+" สถานะ "+statusDesc;
								//subject = doString.UnicodeToMS874(subject); // 2019-05-27
								//String header = "<HTML><HEAD><TITLE></TITLE><META http-equiv=\"Content-Type\" content=\"text/html; charset=TIS-620\"><META http-equiv=\"Content-Language\" content=\"th\"></HEAD><BODY BGCOLOR=\"#FFFFFF\"><FONT size=\"2\" face=\"Microsoft Sans Serif\">"; // 2019-05-27
								//String footer = "</FONT></BODY></HTML>"; // 2019-05-27
				
								String url = "";
								String mailText = "";
								if (iDocStatus.equalsIgnoreCase("G")) {
									url = Constants.APP_SERVER+Constants.APP_PATH+"/SERV_Conf_RetReten2.jsp?i_docno="+iDocNo+"&user_who="+userWho;
							    } else {
									url = Constants.APP_SERVER+Constants.APP_PATH+"/SERV_Conf_RetReten.jsp?i_docno="+iDocNo+"&user_who="+userWho;
								}
								mailText = " เอกสารขอคืนเงินค้ำประกัน เลขที่ "+iDocNo+" แปลงขาย "+iSort+" ของ "+paybackEmp+" สถานะ "+statusDesc;
								mailText += "<br> กรุณา <a href='"+url+"'>กดที่นี่</a> เพื่อทำการอนุมัติ ";
								//mailText = doString.MS874ToUnicode(mailText); // 2019-05-27												
				

								LHMail mail = new LHMail();
								//--- 2019-05-27 , change send mail method ---//
								//mail.sendMailHtml(Constants.LH_HOST,Constants.LH_DOMAIN,Constants.BOQ_SENDER,email,"",subject,header+mailText+footer);
								mail.sendBBMail("132.146.1.82","lh.co.th","applications <application@lh.co.th>",email,"",doString.MS874ToUnicode(subject),doString.MS874ToUnicode(mailText));
							} // end if validate
								
						} 
						rs.close();		 

					}
					//================================== If Approve =======================================//



		 conn.commit();
		 //conn.rollback();
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



