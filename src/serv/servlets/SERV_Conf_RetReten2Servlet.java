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
public class SERV_Conf_RetReten2Servlet extends DBServlet  {
	
	 
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
     
 
		User user = (User) obj;*/
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
		
	
		String iDocNo = doString.checkString(req.getParameter("i_docno"),"");
		String iCompany = doString.checkString(req.getParameter("i_company"),"");
		String iProject = doString.checkString(req.getParameter("i_project"),"");
		String iDocStauts = doString.checkString(req.getParameter("i_doc_status"),"");
		String cApprv = doString.UnicodeToMS874(doString.checkString(req.getParameter("c_apprv"),""));
		String iCurApprove = doString.checkString(req.getParameter("i_cur_apprv"),"");
		String approveFlag = doString.checkString(req.getParameter("approve_flag"),"");

		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_RetenHome.jsp?i_docno="+iDocNo;
		String errorPage = "SERV_Conf_RetReten.jsp?error=1&refresh=yes&i_docno="+iDocNo;
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
		   

				   //-----=========== Read Old Approver for used in SERV_APPRV ===========-----//
				   String oldApprv = "";					
				   sql.delete(0,sql.length());
				   sql.append("select i_cur_apprv from lan:serv_rethd where i_docno='").append(iDocNo).append("' ");	
				   rs = stmt.executeQuery(sql.toString());
				   if (rs.next()) {
					oldApprv = doString.checkString(rs.getString("i_cur_apprv"),"");
				   } 
				   rs.close();		
				   //-----=============================================================-----//				
		   
		   
		   			
					//-----==================== Update SERV_RETHD  ========================-----//
					sql.delete(0,sql.length());
				 	sql.append(" update lan:serv_rethd set ");
					      
				   if (approveFlag.equalsIgnoreCase("O")) {	      
						sql.append(" i_doc_status='O' ,  ")
							  .append(" i_cur_apprv='").append(iCurApprove).append("'  ");
			       } else {
						sql.append(" i_doc_status='U' ,  ")
							  .append(" i_cur_apprv=null  ");				       		
			       }

				   sql.append(" where i_docno='").append(iDocNo).append("' ");					 
				   stmt.executeUpdate(sql.toString());
				   //-----================================================================-----//



			       //-----================== Insert new Flow for this document ===============-----//
					sql.delete(0,sql.length());
					sql.append(" insert into lan:serv_apprv (i_flow,i_docno,i_doc_status,i_apprv,d_apprv,c_apprv) ")
						  .append(" values ('R' , '").append(iDocNo).append("' , ")
						  .append(" '").append(approveFlag.equalsIgnoreCase("O") ? "O" : "U").append("' , ")
						  .append(" '").append(oldApprv).append("' , today , ") // old is iCurApprv
						  .append(" '").append(cApprv).append("') ");      		
					stmt.executeUpdate(sql.toString());
					//-----=============================================================-----//
						
						
						
									
					//-----================ Read Status Details for use in E-Mail ==============-----//
					String statusDesc = "";					
					sql.delete(0,sql.length());
					sql.append(" select n_desc from lan:serv_xstd where i_type='60' ")
					      .append(" and i_code='").append(approveFlag).append("' ");	
					rs = stmt.executeQuery(sql.toString());
					if (rs.next()) {
						statusDesc = doString.checkString(rs.getString("n_desc"),"");
					} 
					rs.close();		
					//-----=============================================================-----//						
	
	
	
					//-----============ Read i_reten_payback Name for use in E-Mail ==========-----//
					String retenEmp = "";
					String retenEmail = "";
					String iSort = "";
					sql.delete(0,sql.length());
					sql.append(" select trim(b.n_prename_th)||trim(b.n_nemploy_th)||' '||trim(b.n_semploy_th) ")
						  .append(" as emp_name,c.user_email,a.i_sort from lan:serv_rethd a ")
						  .append(" left join docflow:acemploy b on b.i_employ=a.i_reten_payback ")
						  .append(" left join lan:useracl c on c.i_employ=a.i_reten_payback and c.user_acl='S' ")
						  .append(" where a.i_docno='").append(iDocNo).append("' ");
					rs = stmt.executeQuery(sql.toString());
					if (rs.next()) {
						retenEmp = doString.checkString(rs.getString("emp_name"),"");
						retenEmail = doString.checkString(rs.getString("user_email"),"");
						iSort = doString.checkString(rs.getString("i_sort"),"");
					} 
					rs.close();
					//-----=============================================================-----//								
	



					//---============ Send E-Mail to Approver if this document is approve ================----//
					if (approveFlag.equalsIgnoreCase("O")) {
						out.println("<html><body>");
						out.println("<form action='SERV_Apprv_RetRetenServlet' method='post'>");
						out.println("<input type='hidden' name='i_docno' value='"+iDocNo+"'>");
						out.println("<input type='hidden' name='i_company' value='"+iCompany+"'>");
						out.println("<input type='hidden' name='i_project' value='"+iProject+"'>");					
						out.println("<input type='hidden' name='i_doc_status' value='"+iDocStauts+"'>");
						out.println("<input type='hidden' name='c_apprv' value='"+cApprv+"'>");
						out.println("<input type='hidden' name='i_cur_apprv' value='"+iCurApprove+"'>");
						out.println("<input type='hidden' name='approve_flag' value='V'>");					
						out.println("<script>document.forms[0].submit();</script>");
						out.println("</form></body></html>");
						
						
						/*----------------- modified 23/12/2008 --------------------			
						//----- Read Approver Details for send mail --------//			
						sql.delete(0,sql.length());
						sql.append(" select user_email from lan:useracl where i_employ='").append(iCurApprove).append("' and user_acl='S'  ");	
						rs = stmt.executeQuery(sql.toString());
						if (rs.next()) {
							String email = doString.checkString(rs.getString("user_email"),"");
							
							//------ Validate Email before send ------//
							if (email.trim().length()>0) {
								String subject = " เอกสารขอคืนเงินค้ำประกัน เลขที่ "+iDocNo+" สถานะ "+statusDesc;
								subject = doString.UnicodeToMS874(subject);
				
				
								String url = Constants.APP_SERVER+Constants.APP_PATH+"/SERV_Apprv_RetReten.jsp?i_docno="+iDocNo;
								String mailText = " เอกสารขอคืนเงินค้ำประกัน เลขที่ "+iDocNo+" แปลงขาย "+iSort+" ของ "+retenEmp+" สถานะ "+statusDesc;
								mailText += "<br> กรุณา <a href='"+url+"'>กดที่นี่</a> เพื่อทำการอนุมัติ ";
								mailText = doString.UnicodeToMS874(mailText);				

								LHMail mail = new LHMail();
								mail.sendMailHtml(Constants.LH_HOST,Constants.LH_DOMAIN,Constants.BOQ_SENDER,email,"",subject,mailText);																	
							} // end if validate
													
						} 
						rs.close();	
						------------------------------------------------------------*/
					}
					//-----===========================================================================-----//		
					
					
					
					
			         //---========= Send E-Mail to i_reten_payback if this document is route back ==============----//					
					else {
						//------ Validate Email before send ------//
						if (retenEmail.trim().length()>0) {
							String header = "<HTML><HEAD><TITLE></TITLE><META http-equiv=\"Content-Type\" content=\"text/html; charset=TIS-620\"><META http-equiv=\"Content-Language\" content=\"th\"></HEAD><BODY BGCOLOR=\"#FFFFFF\"><FONT size=\"2\" face=\"Microsoft Sans Serif\">";
							String footer = "</FONT></BODY></HTML>";							
							String subject = " เอกสารขอคืนเงินค้ำประกัน เลขที่ "+iDocNo+" สถานะ "+statusDesc;
							//subject = doString.UnicodeToMS874(subject); // 2019-05-27
				
							String mailText = " เอกสารขอคืนเงินค้ำประกัน เลขที่ "+iDocNo+" แปลงขาย "+iSort+" ของ "+retenEmp+" สถานะ "+statusDesc;
							//mailText = doString.UnicodeToMS874(mailText); // 2019-05-27				

							LHMail mail = new LHMail();							
						    //--- 2019-05-27 , change end mail method ---//
							//mail.sendMailHtml(Constants.LH_HOST,Constants.LH_DOMAIN,Constants.BOQ_SENDER,retenEmail,"",subject,header+mailText+footer);
						    mail.sendBBMail("132.146.1.82","lh.co.th","applications <application@lh.co.th>",retenEmail,"",doString.MS874ToUnicode(subject),doString.MS874ToUnicode(mailText));
						} // end if validate
					}
					//-----===========================================================================-----//		
						
			
			

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



