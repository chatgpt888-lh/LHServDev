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
public class SERV_BOQCodeApproveServlet extends DBServlet  {
	
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

		String mode = doString.checkString(req.getParameter("mode"),"approve");
		String iRefNo = doString.checkString(req.getParameter("i_refno"),"");
		String iEmpReq = doString.checkString(req.getParameter("req_id"),"");
		String cRemark = doString.UnicodeToMS874(doString.checkString(req.getParameter("c_remark"),""));
		String iGroup[] = new String[] {"","","","",""};
		String iType[] = new String[] {"","","","",""};
		String iItmJob[] = new String[] {"","","","",""};
   
					
		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_BOQCode.jsp";
		String errorPage = "SERV_BOQCode02.jsp?error=1&mode="+mode+"&i_refno="+iRefNo+"&c_remark="+cRemark;		
		for (int i=0;i<5;i++) {
			  iGroup[i] = doString.checkString(req.getParameter("i_group_"+(i+1)),"");
			  iType[i] = doString.checkString(req.getParameter("i_type_"+(i+1)),"");
			  iItmJob[i] = doString.checkString(req.getParameter("i_itmjob_"+(i+1)),"");
			  if (iItmJob[i].length()>0) {
					errorPage += "&i_group_"+(i+1)+"="+iGroup[i];
					errorPage += "&i_type_"+(i+1)+"="+iType[i];
					errorPage += "&i_itmjob_"+(i+1)+"="+iItmJob[i];			  	
			  }
		}		


		
		String otherMsg = "";
		String errorCode = "";
    
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
			if (mode.equalsIgnoreCase("APPROVE")) {
														

				//---================ get Requestor Name & Email  ===============---//
				String reqName = "";
				String mainEmail = "";
				
				sql.delete(0,sql.length());			 				 
				sql.append(" select a.i_employ,a.user_email, ")
					  .append(" trim(b.n_prename_th)||trim(b.n_nemploy_th)||' '||trim(b.n_semploy_th) n_employ ")
					  .append(" from lan:useracl a left join docflow:acemploy b on b.i_employ=a.i_employ ")
					  .append(" where a.i_employ='").append(iEmpReq).append("' ");                                    
				rs = stmt.executeQuery(sql.toString());								
				while (rs.next()) {
					reqName = doString.checkString(rs.getString("n_employ"),"");
					mainEmail = doString.checkString(rs.getString("user_email"),"");
				} // end while
				rs.close();
				//-----=======================================================------//



				//------==================== Start Insert ==========================-----//
				sql.delete(0,sql.length());
				sql.append(" update lan:serv_noboq set ")
					  .append(" d_approve = today , ");
					  
				for (int i=0;i<5;i++) {	  
					   if (iItmJob[i].length()>0) {
						   sql.append(" i_itmjob").append(i+1).append("='").append(iItmJob[i]).append("' , ");					   	
					   }					  
				}
				
				sql.append(" c_remark = ?  where i_refno= ? ");
					  
				//---====== User PrepareStatement instead becase cRemark is an more than 256 Chars ======-----//	  					  
				pstmt = conn.prepareStatement(sql.toString());
				pstmt.setString(1,cRemark);
				pstmt.setString(2,iRefNo);
				pstmt.executeUpdate();
				pstmt.close();
				//-----========================================================------//




				
				//---================== send Email to Requestor ===================---//
				String subject = Constants.BOQ_SUBJECT_APPROVE;
				subject = str.replace(subject,"%I_REF_NO%",iRefNo);
				subject = str.replace(subject,"%REQ_EMP_NO%",iEmpReq);
				subject = str.replace(subject,"%REQ_EMP_NAME%",reqName);
				subject = str.replace(subject,"%REQ_APP_NO%",user.getEmpId());
				subject = str.replace(subject,"%REQ_APP_NAME%",user.getEmpName());
				subject = doString.UnicodeToMS874(subject);
				

				String mailText = Constants.BOQ_CONTENT_APPROVE;
				mailText = str.replace(mailText,"%I_REF_NO%",iRefNo);
				mailText = str.replace(mailText,"%REQ_EMP_NO%",iEmpReq);
				mailText = str.replace(mailText,"%REQ_EMP_NAME%",reqName);
				mailText = str.replace(mailText,"%REQ_APP_NO%",user.getEmpId());
				mailText = str.replace(mailText,"%REQ_APP_NAME%",user.getEmpName());		
				mailText = doString.UnicodeToMS874(mailText);

				
				LHMail mail = new LHMail();
				mail.sendMailLH(Constants.LH_HOST,Constants.LH_DOMAIN,Constants.BOQ_SENDER,mainEmail,"",subject,mailText+"\r\n");				
				//-----==========================================================------//


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
