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
public class SERV_BOQCodeServlet extends DBServlet  {
	
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
		String iEmpApp = doString.checkString(req.getParameter("i_employ_approve"),"");
		String cDesc1 = doString.UnicodeToMS874(doString.checkString(req.getParameter("c_desc1"),""));
		String cDesc2 = doString.UnicodeToMS874(doString.checkString(req.getParameter("c_desc2"),""));
		String cDesc3 = doString.UnicodeToMS874(doString.checkString(req.getParameter("c_desc3"),""));
		String cDesc4 = doString.UnicodeToMS874(doString.checkString(req.getParameter("c_desc4"),""));
		String cDesc5 = doString.UnicodeToMS874(doString.checkString(req.getParameter("c_desc5"),""));		
					
		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_BOQSearch.jsp";
		String errorPage = "SERV_BOQCode01.jsp?error=1&mode="+mode+"&i_employ_approve="+iEmpApp;
        errorPage += "&c_desc1="+cDesc1+"&c_desc2="+cDesc2+"&c_desc3="+cDesc3+"&c_desc4="+cDesc4+"&c_desc5="+cDesc5;
		
		String otherMsg = "";
		String errorCode = "";
		String refId = "";
    
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
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
						
			//----======== Add Mode , Insert Query =========----//
			if (mode.equalsIgnoreCase("ADD")) {
														
																
				//---==================== generate i_ref_no ========================---//
				sql.delete(0,sql.length());			 				 
				sql.append(" select max(i_refno) ref_no from lan:serv_noboq ");
				rs = stmt.executeQuery(sql.toString());								
				if (rs.next()) {
					//----========== DocNo Found , increase ID =========----// 
					String oldRef = doString.checkString(rs.getString("ref_no"),"0");
					int lastId = Integer.parseInt(oldRef);
					if (lastId<0) { 
						lastId = 1;
					} else {
						lastId++; 
					}
					refId = str.createID(lastId,4);
				} else {
					//----======== No DocNo found , start 1 ========----// 
					refId = "0001";
				}
				rs.close();
				//-----========================================================------//

								


				//---================== get Alll Approver Email  ===================---//
				String mainEmail = "";
				String approverName = "";
				String ccEmail = "";
				
				sql.delete(0,sql.length());			 				 
				sql.append(" select a.i_employ,a.user_email, ")
				      .append(" trim(b.n_prename_th)||trim(b.n_nemploy_th)||' '||trim(b.n_semploy_th) n_employ ")
				      .append(" from lan:useracl a left join docflow:acemploy b on b.i_employ=a.i_employ ")
				      .append(" where (a.user_who='C' or a.user_who='Z') and a.user_acl='S' ");                                    
				rs = stmt.executeQuery(sql.toString());								
				while (rs.next()) {
					String iEmp = doString.checkString(rs.getString("i_employ"),"");
					String email = doString.checkString(rs.getString("user_email"),"");
					
					if (iEmp.equalsIgnoreCase(iEmpApp)) {
						mainEmail = email;  					
						approverName = doString.checkString(rs.getString("n_employ"),"");
					} else {
						if (ccEmail.length()>0) ccEmail += " , ";
						ccEmail += email; 
					}
					
				} // end while
				rs.close();
				//-----=======================================================------//
				



				//------==================== Start Insert ==========================-----//
				sql.delete(0,sql.length());
				sql.append(" insert into lan:serv_noboq (i_refno , i_employ_req , d_keyin , i_email_req , ")
				      .append(" c_desc1, c_desc2 , c_desc3 , c_desc4 , c_desc5 , ")
				      .append(" i_employ_approve , i_email_approve , cc_mail , d_approve , ")
				      .append(" i_itmjob1, i_itmjob2 , i_itmjob3 , i_itmjob4 ,i_itmjob5 , c_remark ")
					  .append(" ) values ( ")
					  .append(" ? , ? , current , ? , ? , ? , ? , ? , ? , ") // header and c_desc1 - 5
					  .append(" ? , ? , ? , null , ") // Approver Description
					  .append(" null , null , null , null , null , null ") // i_itemjob1 - 5 and remark
					  .append(" ) "); 					
					  
				//---====== User PrepareStatement instead becase cDesc is an more than 256 Chars ======-----//	  					  
				pstmt = conn.prepareStatement(sql.toString());
				pstmt.setString(1,refId);
				pstmt.setString(2,user.getEmpId());
				pstmt.setString(3,user.getEmail());
				pstmt.setString(4,cDesc1);
				pstmt.setString(5,cDesc2);
				pstmt.setString(6,cDesc3);
				pstmt.setString(7,cDesc4);
				pstmt.setString(8,cDesc5);
				pstmt.setString(9,iEmpApp);
				pstmt.setString(10,mainEmail);
				pstmt.setString(11,ccEmail);
				pstmt.executeUpdate();
				pstmt.close();
				//-----========================================================------//




				
				//---================== send Email to Alll Approver ===================---//
				String subject = Constants.BOQ_SUBJECT_REQUEST;
				subject = str.replace(subject,"%I_REF_NO%",refId);
				subject = str.replace(subject,"%REQ_EMP_NO%",user.getEmpId());
				subject = str.replace(subject,"%REQ_EMP_NAME%",user.getEmpName());
				subject = str.replace(subject,"%REQ_APP_NO%",iEmpApp);
				subject = str.replace(subject,"%REQ_APP_NAME%",appName);
				subject = doString.UnicodeToMS874(subject);
				

				String mailText = Constants.BOQ_CONTENT_REQUEST;
				mailText = str.replace(mailText,"%I_REF_NO%",refId);
				mailText = str.replace(mailText,"%REQ_EMP_NO%",user.getEmpId());
				mailText = str.replace(mailText,"%REQ_EMP_NAME%",user.getEmpName());
				mailText = str.replace(mailText,"%REQ_APP_NO%",iEmpApp);
				mailText = str.replace(mailText,"%REQ_APP_NAME%",appName);		
				mailText = doString.UnicodeToMS874(mailText);

				
				
				LHMail mail = new LHMail();
				ccEmail = ""; // fixed to send main approver only , remove this line if you want to send E-Mail to other Approver
				mail.sendMailHtml(Constants.LH_HOST,Constants.LH_DOMAIN,Constants.BOQ_SENDER,mainEmail,ccEmail,subject,mailText+"\r\n");				
				//-----==========================================================------//


						
				otherMsg = "เลขที่ใบอนุมัติ BOQ คือ "+refId;
			}
			//----======================================----//


			
			//----======== Edit Mode , Insert Query =========----//
			else if (mode.equalsIgnoreCase("EDIT")) {
			}
			//----======================================----//


			
			//----======== Delete Mode , Insert Query =========----//
			else if (mode.equalsIgnoreCase("DELETE")) {		
			}
			//----========================================----//
			

			conn.commit();
			stmt.close();
			conn.close();
			conn = null;

			// Redirect to the finish page.
			//res.sendRedirect(doString.UnicodeToMS874(successPage));
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
				if (pstmt != null) pstmt.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");

	}

}
