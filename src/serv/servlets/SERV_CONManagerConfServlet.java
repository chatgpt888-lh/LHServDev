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

public class SERV_CONManagerConfServlet extends DBServlet{
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
		String empId = user.getEmpId();
		doString str = new doString();		 
		response.setContentType("text/html; charset=TIS620");
		PrintWriter out = response.getWriter();
		
		//------ header table ----//
		String itmType  = doString.checkString(request.getParameter("itmType"));	//
		String iVendor = doString.checkString(request.getParameter("i_vendor"),"");	
		String mode = doString.checkString(request.getParameter("mode"));			//
		String selProj  = doString.checkString(request.getParameter("selProj"));	//
		String d_payment = "";
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
		
		
		//------ forward page --------//
		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_CONManager_Conf.jsp?itmType="+itmType+"&i_vendor="+iVendor;
		String errorPage = "SERV_CONManager_Conf.jsp?error=1&itmType="+itmType+"&i_vendor="+iVendor; 
		String otherMsg = "";
		String errorCode = "";	
		
		
		//-------------- database connection -----// 
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		Connection conn = null;
		Statement stmt = null;
		Statement ustmt = null;
		ResultSet rs = null;
		int rowEffected = 0;
		try {
			if (ds == null)
				getDS();
	
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
			ustmt = conn.createStatement();
			
			
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
							
						String docNo = id.nextToken();
						String vendor = id.nextToken();	
											
						String comment = doString.UnicodeToMS874(doString.checkString(request.getParameter(item+"_comment"),""));
						comment = doString.TextToString(comment);
							
						//SERV_INFDOCHD
						stmt.executeUpdate("UPDATE lan:serv_infdochd SET f_status = 'CAN', d_cancel = TODAY, i_employ_reject = '"+empId+"', c_reject = '"+comment+"' WHERE i_docno = '"+docNo+"'");
						
						//SERV_INFPAYMENT
						stmt.executeUpdate("UPDATE lan:serv_infpayment SET f_itmstatus = 'CAN' WHERE i_docno = '"+docNo+"'");
						
						//SERV_CONHD
						rs = stmt.executeQuery("SELECT i_company, i_project, i_order, s_due FROM lan:serv_infpayment WHERE i_docno = '"+docNo+"'");
						if (rs != null) {
							while (rs.next() == true) {
								comId = doString.checkString(rs.getString("I_COMPANY"));
								projId = doString.checkString(rs.getString("I_PROJECT"));
								orderNo = doString.checkString(rs.getString("I_ORDER"));
								dueNo = Integer.toString(rs.getInt("S_DUE"));
								ustmt.executeUpdate("UPDATE lan:serv_condt SET z_accrue = 0 WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+orderNo+"' AND s_due = "+dueNo);
							}// end while
							rs.close();
							rs=null;
						}
					}
				}
			//====== RouteBack =====================//
			}else if(mode.equalsIgnoreCase("ROUTEBACK")){
			}
			conn.commit();
			stmt.close();
			ustmt.close();
			conn.close();
			stmt = null;
			ustmt = null;
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
			genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ "+e.getMessage());
			
		} finally {
			out.close();
			try {
				if (rs!=null) rs.close(); 
				if (stmt != null) stmt.close();
				if (ustmt != null) ustmt.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");
	}	
}
