package serv.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.StringTokenizer;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import serv.common.Constants;
import serv.common.User;

import com.lh.exception.InvalidParameterException;
import com.lh.servlet.DBServlet;
import com.lh.util.doString;

public class SERV_INFManagerConfServlet extends DBServlet{
	private void genRedirectCode(PrintWriter out,String page,String redirect,String error,String otherMsg) {
		out.println("<form method='post' action='"+page+"'>");		
		out.println("<input type='hidden' name='error' value='"+error+"'>");
		out.println("<input type='hidden' name='other_msg' value='"+doString.MS874ToUnicode(otherMsg)+"'>");
		out.println("<input type='hidden' name='redirect_url' value='"+doString.MS874ToUnicode(redirect)+"'>");		
		out.println("<script> document.forms[0].submit();</script>");
		out.println("</form>");		
	}

	public void performTask(HttpServletRequest request, HttpServletResponse response)throws ServletException, IOException {
		String mName = new String(this.getClass().getName() + ".performTask: ");
		System.out.println(mName + "start.");		
		//-----======= Check Login session =======-----//
		HttpSession session = request.getSession(false);
		if (session == null) {
			//---===== No Session , redirect to warning =======---// 
			response.sendRedirect(Constants.WARNING_PAGE);
			return;
		}
		
		Object obj = session.getAttribute("USER");
		if (obj == null) {
		//---===== Can't get User Login , redirect to warning ======---// 
			response.sendRedirect(Constants.WARNING_PAGE);
			return;
		}
		
		//----===================================----//	
		User user = (User) obj;
		doString str = new doString();		 
		response.setContentType("text/html; charset=TIS620");
		PrintWriter out = response.getWriter();
		
		//------ header table ----//
		String iVendor = doString.checkString(request.getParameter("i_vendor"),"");	
		String mode = doString.checkString(request.getParameter("mode"));			//
		String selProj  = doString.checkString(request.getParameter("selProj"));	//
		String d_payment = "";
		
		
		//---======= Get Now Date with time =========-----//
		Calendar now = Calendar.getInstance();				
		int year = (now).get(Calendar.YEAR);
		if (year<2400) year += 543;		
		String nowDate = Integer.toString(year>2400 ? year-543 : year);	
		nowDate += "-"+str.createID(now.get(Calendar.MONTH)+1,2);
		nowDate += "-"+str.createID(now.get(Calendar.DATE),2);		
		nowDate += " "+str.createID(now.get(Calendar.HOUR_OF_DAY),2);
		nowDate += ":"+str.createID(now.get(Calendar.MINUTE),2);
		
		
		//------ forward page --------//
		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_INFManager_Conf.jsp?i_vendor="+iVendor;
		String errorPage = "SERV_INFManager_Conf.jsp?error=1&i_vendor="+iVendor; 
		String otherMsg = "";
		String errorCode = "";	
		
		
		//-------------- database connection -----// 
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		int rowEffected = 0;
		try {
			if (ds == null)
				getDS();
	
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
			
			
			
			//====== Approve =====================//
			if(mode.equalsIgnoreCase("APPROVE")){
				String iItmJob[] = request.getParameterValues("i_itmjob");
				if (iItmJob!=null) {
					for (int i=0;i<iItmJob.length;i++) {
						String item = doString.checkString(iItmJob[i],"");
						StringTokenizer id = new StringTokenizer(item,":");
						if (id.countTokens()!=2) continue;				
							
						String docno = id.nextToken();
						String vendor = id.nextToken();			
				
						String iComment = doString.UnicodeToMS874(doString.checkString(request.getParameter(item+"_comment"),""));
						iComment = str.replace(iComment,"\r","");
						iComment = str.replace(iComment,"\n","|break|");	
				
						//====== UPDATE SERV_INFPAYMENT ======//
						sql.delete(0,sql.length());
						sql.append("UPDATE lan:serv_infpayment SET f_itmstatus = '")
						.append("700")
						.append("' WHERE i_docno = '")
						.append(docno)
						.append("' AND i_vendor = '")
						.append(vendor)	
						.append("' AND f_itmstatus = '600'");
						rowEffected = stmt.executeUpdate(sql.toString());
						if (rowEffected == 0) {
							throw new Exception("SERV_INFPAYMENT : Wrong insert count");
						}
			
						//====== INSERT SERV_INFFLOW ======//
						sql.delete(0,sql.length());
						sql.append("INSERT INTO lan:serv_infflow(i_docno, i_vendor, f_itmstatus, d_approve, i_approve, f_reject, c_reject )"+
						"VALUES(?,?,?,CURRENT,?,null,?)" );
						pstmt = conn.prepareStatement(sql.toString());
						pstmt.setString(1, 		docno);				//i_docno
						pstmt.setString(2, 		vendor);			//i_vendor 
						pstmt.setString(3, 		"600");				//f_itmstatus
						pstmt.setString(4, 		user.getEmpId());	//i_approve
						pstmt.setString(5, 		iComment);			//i_c_reject
						pstmt.executeUpdate();
						pstmt.close(); 
					}
				}
			
			//====== Reject =====================//
			}else if(mode.equalsIgnoreCase("REJECT")){
				String iItmJob[] = request.getParameterValues("i_itmjob");
				if (iItmJob!=null) {
					for (int i=0;i<iItmJob.length;i++) {
						String item = doString.checkString(iItmJob[i],"");
						StringTokenizer id = new StringTokenizer(item,":");
						if (id.countTokens()!=2) continue;				
							
						String docno = id.nextToken();
						String vendor = id.nextToken();	
											
						String iComment = doString.UnicodeToMS874(doString.checkString(request.getParameter(item+"_comment"),""));
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
						
				
						//====== UPDATE SERV_INFPAYMENT ======//
						sql.delete(0,sql.length());
						sql.append(" update lan:serv_infpayment  set ")
							  .append(" d_payment ='").append(paymentDate).append("' , ")									
							  .append(" f_itmstatus='400' ") // re-status to 400 , Send back to Contractor to approve and edit data again
							  .append(" where i_docno='").append(docno).append("' ")				         
							  .append(" and i_vendor='").append(iVendor).append("' ")
							  .append(" and f_itmstatus='600' ");
						
						rowEffected = stmt.executeUpdate(sql.toString());
						if (rowEffected == 0) {
							throw new Exception("SERV_INFPAYMENT : Wrong insert count");
						}
			
						//====== INSERT SERV_INFFLOW ======//
						sql.delete(0,sql.length());
						sql.append("INSERT INTO lan:serv_infflow(i_docno, i_vendor, f_itmstatus, d_approve, i_approve, f_reject, c_reject )"+
						"VALUES(?,?,?,CURRENT,?,?,?)" );
						pstmt = conn.prepareStatement(sql.toString());
						pstmt.setString(1, 		docno);				//i_docno
						pstmt.setString(2, 		vendor);			//i_vendor 
						pstmt.setString(3, 		"600");				//f_itmstatus
						pstmt.setString(4, 		user.getEmpId());	//i_approve
						pstmt.setString(5, 		"Y");				//f_reject
						pstmt.setString(6, 		iComment);			//c_reject
						pstmt.executeUpdate();
						pstmt.close(); 
					}
				}
			
			
				
			//====== RouteBack =====================//
			}else if(mode.equalsIgnoreCase("ROUTEBACK")){
				String iItmJob[] = request.getParameterValues("i_itmjob");
				if (iItmJob!=null) {
					for (int i=0;i<iItmJob.length;i++) {
						String item = doString.checkString(iItmJob[i],"");
						StringTokenizer id = new StringTokenizer(item,":");
						if (id.countTokens()!=2) continue;				
							
						String docno = id.nextToken();
						String vendor = id.nextToken();	
											
						String iComment = doString.UnicodeToMS874(doString.checkString(request.getParameter(item+"_comment"),""));
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
						
						//====== UPDATE SERV_INFPAYMENT ======//
						sql.delete(0,sql.length());
						sql.append(" update lan:serv_infpayment  set ")
							  .append(" d_payment ='").append(paymentDate).append("' , ")									
							  .append(" f_itmstatus='500' ") // re-status to 500 , Send back to Service Staff to re-check and approve again
							  .append(" where i_docno='").append(docno).append("' ")				         
							  .append(" and i_vendor='").append(iVendor).append("' ")
							  .append(" and f_itmstatus='600' ");
						
						rowEffected = stmt.executeUpdate(sql.toString());
						if (rowEffected == 0) {
							throw new Exception("SERV_INFPAYMENT : Wrong insert count");
						}
			
						//====== INSERT SERV_INFFLOW ======//
						sql.delete(0,sql.length());
						sql.append("INSERT INTO lan:serv_infflow(i_docno, i_vendor, f_itmstatus, d_approve, i_approve, f_reject, c_reject )"+
						"VALUES(?,?,?,CURRENT,?,?,?)" );
						pstmt = conn.prepareStatement(sql.toString());
						pstmt.setString(1, 		docno);				//i_docno
						pstmt.setString(2, 		vendor);			//i_vendor 
						pstmt.setString(3, 		"600");				//f_itmstatus
						pstmt.setString(4, 		user.getEmpId());	//i_approve
						pstmt.setString(5, 		"Y");				//f_reject
						pstmt.setString(6, 		iComment);			//c_reject
						pstmt.executeUpdate();
						pstmt.close(); 
						
					}
				}
			}
			conn.commit();
			stmt.close();
			conn.close();
			stmt = null;
			conn = null;
			
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
