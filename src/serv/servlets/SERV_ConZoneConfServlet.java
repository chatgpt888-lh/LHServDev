package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.naming.*;

import com.lh.servlet.DBServlet;
import com.lh.util.*;

import serv.common.Constants;
import serv.common.User;

/**
 * @version 	1.0
 * @author
 */
public class SERV_ConZoneConfServlet extends DBServlet  {
	
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
			itmType_restrict = " AND b.i_itmtype = '"+itmType+"'";
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
						    String iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter("main_comment"),""));
							iComment = str.replace(iComment,"\r","");
							iComment = str.replace(iComment,"\n","|break|");	

					    
					    
					    //---============== Get All iDocNo for this vendor for use in update payment and insert flow ===========---//
					    sql.delete(0,sql.length());
					    sql.append(" select distinct b.i_docno from lan:serv_infdochd a,lan:serv_infpayment b ")
					          .append(" where b.f_itmstatus = '700' and b.i_docno=a.i_docno ") //Wait Zone Confirm                                                       
	  			  		      .append(" and b.i_vendor='").append(vendor).append("' ")
					    		.append(itmType_restrict);
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
						    String comment = doString.UnicodeToMS874(doString.checkString(req.getParameter("main_comment"),""));
						    comment = doString.TextToString(comment);
						//---============== Get All iDocNo for this vendor for use in update payment and insert flow ===========---//
						sql.delete(0,sql.length());
						sql.append(" select distinct b.i_docno from lan:serv_infdochd a,lan:serv_infpayment b ")
							  .append(" where b.f_itmstatus = '700' and b.i_docno=a.i_docno ")                                                         
							  .append(" and b.i_vendor='").append(vendor).append("' ")
							  .append(itmType_restrict);
						if (iCompany.trim().length()>0 && iProject.trim().length()>0) {
							 sql.append(" and a.i_company='").append(iCompany).append("' ")
								   .append(" and a.i_project='").append(iProject).append("' ");
						}							  
						rs = stmt.executeQuery(sql.toString());
						while (rs.next()) {
							String docNo = doString.checkString(rs.getString("i_docno"));
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
							
							String docNo = id.nextToken();
							String vendor = id.nextToken();	
							
							//----========== For use multiple comment ===========---//				
						    String comment = doString.UnicodeToMS874(doString.checkString(req.getParameter("main_comment"),""));
						    comment = doString.TextToString(comment);
						    
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
					} // end for	
									
				} // end if check i_itmjob is not null							
			}			 
			//-----============================ RouteBack Mode =======================================----//
			else if (mode.equalsIgnoreCase("ROUTEBACK")) {
			}			 
			
			conn.commit();
			stmt.close();
			ustmt.close();
			stmt1.close();
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
