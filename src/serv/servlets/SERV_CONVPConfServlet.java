package serv.servlets;

import java.io.*;
import java.sql.*;
import java.util.*;

import javax.servlet.*;
import javax.servlet.http.*;

import serv.common.Constants;
import serv.common.User;

import com.lh.exception.InvalidParameterException;
import com.lh.servlet.DBServlet;
import com.lh.util.*;

public class SERV_CONVPConfServlet extends DBServlet{

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
		String empId = user.getEmpId();
		doString str = new doString();		
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();

			
		String iVendor = doString.checkString(req.getParameter("i_vendor"),"");				
		String mode = doString.checkString(req.getParameter("mode"),"");
		String itmType  = doString.checkString(req.getParameter("itmType"));
		String itmType_restrict = "";
		if (!itmType.equals("")) {
			itmType_restrict = " AND i_itmtype = '"+itmType+"'";
		}
		String comId = "";
		String projId = "";
		String orderNo = "";
		String dueNo = "";			
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
		Connection conn = null;
		Statement stmt = null;
		Statement stmt1 = null;
		Statement ustmt = null;
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
			ustmt = conn.createStatement();
			
			//---- Keep iDocNo that update status to 'CLS' for check complete all payment or not -----//
			Vector checkIDocNoComplete = new Vector();

			
			//-----============================ Approve Vendor Mode =======================================----//
			if (mode.equalsIgnoreCase("APPROVE_COMPANY")) {
				String companyList[] = req.getParameterValues("i_company");
				if (companyList!=null) {
					for (int i=0;i<companyList.length;i++) {
						String company = doString.checkString(companyList[i],"");				
							
						//--====== For use multiple comment =======--//
						
						String iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter("main_comment"),""));
						iComment = str.replace(iComment,"\r","");
						iComment = str.replace(iComment,"\n","|break|");	

					    
					    
						//---============== Get All iDocNo for this company for use in update payment and insert flow ===========---//
						sql.delete(0,sql.length());
						sql.append(" select distinct i_docno,i_vendor from lan:serv_infpayment where f_itmstatus='800' ")
								.append(itmType_restrict)
							  .append(" and substr(i_docno,1,2)='").append(company).append("' ");
						rs = stmt.executeQuery(sql.toString());
						while (rs.next()) {
							String docno = doString.checkString(rs.getString("i_docno"),"");
							String vendor = doString.checkString(rs.getString("i_vendor"),"");
							checkIDocNoComplete.addElement(docno);

					         
							//---================ Update SERV_INFPAYMENT =================----//
							sql.delete(0,sql.length());
							sql.append(" update lan:serv_infpayment  set ")				  
								  .append(" f_itmstatus='CLS' ") // set status to CLS , Close this payment
								  .append(" where i_docno='").append(docno).append("' ")				         
								  .append(" and i_vendor='").append(vendor).append("' ")				         
								  .append(" and f_itmstatus='800' ");							  				          
							stmt1.executeUpdate(sql.toString());
						
												
						
							//-----======================== Insert new SERV_INFFLOW =============================----//
							sql.delete(0,sql.length());
							sql.append(" insert into lan:serv_infflow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,f_reject,c_reject ")
								  .append(") values (")
								  .append(" '").append(docno).append("' , ")
								  .append(" '").append(vendor).append("' , ")
								  .append(" '800' , ") //-- Set Status to 800 , VP already approve ---//
								  .append(" '").append(nowDate).append("' , ")
								  .append(" '").append(user.getUserID()).append("' , ")
								  .append(" null , ")
								  .append(" '").append(iComment).append("') ");				          
							 stmt1.executeUpdate(sql.toString());					         
					         
						} 
						rs.close();
						
					} 	
									
				} 					
			}				
			
			//-----============================ Reject Vendor Mode =======================================----//
			if (mode.equalsIgnoreCase("REJECT_COMPANY")) {
				String companyList[] = req.getParameterValues("i_company");
				if (companyList!=null) {
					for (int i=0;i<companyList.length;i++) {
						String company = doString.checkString(companyList[i],"");					
							
						//---======== For use multiple comment ==========---//
					    String comment = doString.UnicodeToMS874(doString.checkString(req.getParameter("main_comment"),""));
					    comment = doString.TextToString(comment);						

					    
						//---============== Get All iDocNo for this company for use in update payment and insert flow ===========---//
						sql.delete(0,sql.length());
						sql.append(" select distinct i_docno,i_vendor from lan:serv_infpayment where f_itmstatus='800' ")
								.append(itmType_restrict)
							  .append(" and substr(i_docno,1,2)='").append(company).append("' ");
						rs = stmt.executeQuery(sql.toString());
						while (rs.next()) {
							String docNo = doString.checkString(rs.getString("i_docno"),"");
							String vendor = doString.checkString(rs.getString("i_vendor"),"");					
							
							//SERV_INFDOCHD
							stmt1.executeUpdate("UPDATE lan:serv_infdochd SET f_status = 'CAN', d_cancel = TODAY, i_employ_reject = '"+empId+"', c_reject = '"+comment+"' WHERE i_docno = '"+docNo+"'");
							
							//SERV_INFPAYMENT
							stmt1.executeUpdate("UPDATE lan:serv_infpayment SET f_itmstatus = 'CAN' WHERE i_docno = '"+docNo+"'");
							
							//SERV_CONHD
							rs1 = stmt1.executeQuery("SELECT i_company, i_project, i_order, s_due FROM lan:serv_infpayment WHERE i_docno = '"+docNo+"'");
							if (rs1 != null) {
								while (rs1.next() == true) {
									comId = doString.checkString(rs1.getString("I_COMPANY"));
									projId = doString.checkString(rs1.getString("I_PROJECT"));
									orderNo = doString.checkString(rs1.getString("I_ORDER"));
									dueNo = Integer.toString(rs1.getInt("S_DUE"));
									ustmt.executeUpdate("UPDATE lan:serv_condt SET z_accrue = 0 WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+orderNo+"' AND s_due = "+dueNo);
								}// end while
								rs1.close();
								rs1=null;
							}
						} 
						rs.close();
						rs=null;
					} 	
									
				} 								
			}			
			
			
			//-----============================ Approve Mode =======================================----//
			else if (mode.equalsIgnoreCase("APPROVE_PROJECT")) {
				String iItmJob[] = req.getParameterValues("i_project");
				if (iItmJob!=null) {
					for (int i=0;i<iItmJob.length;i++) {
							String item = doString.checkString(iItmJob[i],"");
							StringTokenizer id = new StringTokenizer(item,":");
							if (id.countTokens()!=2) continue;				
							
							String company = id.nextToken();
							String project = id.nextToken();			
					
							//----========== For use multiple comment =========---//
						    
							String iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter("main_comment"),""));
							iComment = str.replace(iComment,"\r","");
							iComment = str.replace(iComment,"\n","|break|");	


						//---============== Get All iDocNo for this project for use in update payment and insert flow ===========---//
						sql.delete(0,sql.length());
						sql.append(" select distinct i_docno,i_vendor from lan:serv_infpayment where f_itmstatus='800' ")
								.append(itmType_restrict)
							  .append(" and substr(i_docno,1,2)='").append(company).append("' ")
					      	  .append(" and substr(i_docno,4,3)='").append(project).append("' ");
						rs = stmt.executeQuery(sql.toString());
						while (rs.next()) {
							String docno = doString.checkString(rs.getString("i_docno"),"");
							String vendor = doString.checkString(rs.getString("i_vendor"),"");
							checkIDocNoComplete.addElement(docno);
												    
					
							//---================ Update SERV_INFPAYMENT =================----//
							sql.delete(0,sql.length());
							sql.append(" update lan:serv_infpayment  set ")				  
								  .append(" f_itmstatus='CLS' ") // set status to CLS , Close this payment
								  .append(" where i_docno='").append(docno).append("' ")				         
								  .append(" and i_vendor='").append(vendor).append("' ")				         
								  .append(" and f_itmstatus='800' ");							  
							stmt1.executeUpdate(sql.toString());
							
													
							
							//-----======================== Insert new SERV_INFFLOW =============================----//
							sql.delete(0,sql.length());
							sql.append(" insert into lan:serv_infflow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,f_reject,c_reject ")
								  .append(") values (")
								  .append(" '").append(docno).append("' , ")
								  .append(" '").append(vendor).append("' , ")
								  .append(" '800' , ") //-- Set Status to 800 , VP already approve ---//
								  .append(" '").append(nowDate).append("' , ")
								  .append(" '").append(user.getUserID()).append("' , ")
								  .append(" null , ")
								  .append(" '").append(iComment).append("') ");
							 stmt1.executeUpdate(sql.toString());
							
						} 
						rs.close();
						
					} 	
									
				} 								
			}
			
			
			//-----============================ Reject Mode =======================================----//
			else if (mode.equalsIgnoreCase("REJECT_PROJECT")) {
				String iItmJob[] = req.getParameterValues("i_project");
				if (iItmJob!=null) {
					for (int i=0;i<iItmJob.length;i++) {
							String item = doString.checkString(iItmJob[i],"");
							StringTokenizer id = new StringTokenizer(item,":");
							if (id.countTokens()!=2) continue;				
							
							String company = id.nextToken();
							String project = id.nextToken();	
							
							//----========== For use multiple comment ===========---//				
						    String comment = doString.UnicodeToMS874(doString.checkString(req.getParameter("main_comment"),""));
						    comment = doString.TextToString(comment);						
							
											

						//---============== Get All iDocNo for this project for use in update payment and insert flow ===========---//
						sql.delete(0,sql.length());
						sql.append(" select distinct i_docno,i_vendor from lan:serv_infpayment where f_itmstatus='800' ")
							.append(itmType_restrict)
							  .append(" and substr(i_docno,1,2)='").append(company).append("' ")
							  .append(" and substr(i_docno,4,3)='").append(project).append("' ");
						rs = stmt.executeQuery(sql.toString());
						while (rs.next()) {
							String docNo = doString.checkString(rs.getString("i_docno"),"");
							String vendor = doString.checkString(rs.getString("i_vendor"),"");											
							//SERV_INFDOCHD
							stmt1.executeUpdate("UPDATE lan:serv_infdochd SET f_status = 'CAN', d_cancel = TODAY, i_employ_reject = '"+empId+"', c_reject = '"+comment+"' WHERE i_docno = '"+docNo+"'");
							
							//SERV_INFPAYMENT
							stmt1.executeUpdate("UPDATE lan:serv_infpayment SET f_itmstatus = 'CAN' WHERE i_docno = '"+docNo+"'");
							
							//SERV_CONHD
							rs1 = stmt1.executeQuery("SELECT i_company, i_project, i_order, s_due FROM lan:serv_infpayment WHERE i_docno = '"+docNo+"'");
							if (rs1 != null) {
								while (rs1.next() == true) {
									comId = doString.checkString(rs1.getString("I_COMPANY"));
									projId = doString.checkString(rs1.getString("I_PROJECT"));
									orderNo = doString.checkString(rs1.getString("I_ORDER"));
									dueNo = Integer.toString(rs1.getInt("S_DUE"));
									ustmt.executeUpdate("UPDATE lan:serv_condt SET z_accrue = 0 WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+orderNo+"' AND s_due = "+dueNo);
								}// end while
								rs1.close();
								rs1=null;
							}
						} 
						rs.close();
						rs=null;
					}
				} 						
			}			 
			


			//-----=========== Check if some iDocNo has set to 'CLS' , check is complete or not ==========-----//
			if (checkIDocNoComplete.size()>0) {
				boolean allComplete = false;
				for (int l=0;l<checkIDocNoComplete.size();l++) {
					String docno = doString.checkString((String) checkIDocNoComplete.elementAt(l),"");
					sql.delete(0,sql.length());
					sql.append("SELECT b.f_itmstatus AS PAY_STATUS FROM lan:serv_infdocdt a")
						.append(" LEFT JOIN lan:serv_infpayment b ON b.i_docno = a.i_docno AND b.i_itmjob = a.i_itmjob AND b.i_vendor = a.i_vendor")
						.append(" WHERE a.i_docno = '").append(docno).append("'");
					rs = stmt.executeQuery(sql.toString());
					while (rs.next()) {
						String status = doString.checkString(rs.getString("PAY_STATUS"));
						if (status.equalsIgnoreCase("CLS")) {
							allComplete = true;
						} else {
							allComplete = false;
							break; 
						}
					}
					rs.close();
					rs=null;
					
					if (allComplete) {
						//---====== Update serv_infdochd to 'CLS' when is complete all payment ========----//
						sql.delete(0,sql.length());
						sql.append("UPDATE lan:serv_infdochd SET f_status = 'CLS', d_close = TODAY WHERE i_docno = '")
							.append(docno+"'");
						stmt1.executeUpdate(sql.toString());						          
					}
				} 
			}
			conn.commit();
			stmt.close();
			stmt1.close();
			ustmt.close();
			conn.close();
			stmt = null;
			ustmt = null;
			stmt1 = null;
			conn = null;			

			// Redirect to the finish page.
			genRedirectCode(out,savePage,successPage,errorCode,otherMsg);

		} catch (Exception e) {
			try {
				if (conn != null)
					conn.rollback();
			} catch (Exception ignore) {}
			System.out.println(" ERROR "+mName+" : " + e.getMessage());
			System.out.println(" ERROR "+mName+" SQL : " + sql.toString());
			genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ : "+e.getMessage());
			
		} finally {
			out.close();
			try {
				if (rs!=null) rs.close(); 
				if (rs1!=null) rs1.close(); 
				if (stmt != null) stmt.close();
				if (ustmt != null) ustmt.close();
				if (stmt1 != null) stmt1.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");
	}
}
