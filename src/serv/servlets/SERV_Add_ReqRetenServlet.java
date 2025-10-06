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
public class SERV_Add_ReqRetenServlet extends DBServlet  {
	
	 
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
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
		
	
		String mode = doString.checkString(req.getParameter("mode"),"");
		String iDocNo = doString.checkString(req.getParameter("i_docno"),"");
		String fIDCard = doString.checkString(req.getParameter("f_id_card"),"N");
		String fLoseReten = doString.checkString(req.getParameter("f_lose_reten"),"N");
		String iCompany = doString.checkString(req.getParameter("i_company"),"");
		String iProject = doString.checkString(req.getParameter("i_project"),"");
		String iSignB = doString.UnicodeToMS874(doString.checkString(req.getParameter("i_signb"),""));
		String iNotice = "";
		String fNotice = doString.checkString(req.getParameter("f_notice"),"N");
		if (fNotice.equalsIgnoreCase("Y")) {
			iNotice = doString.UnicodeToMS874(doString.checkString(req.getParameter("i_notice"),""));
		}
		
		//---- 2022-06-30 , for payin input ----//
		String iPayType = doString.checkString(req.getParameter("iPayType"),"PAYIN");
		String iPayBnk = doString.checkString(req.getParameter("iPayBnk"),"");
		String iPayAcc = doString.checkString(req.getParameter("iPayAcc"),"");
		String iEmail = doString.checkString(req.getParameter("iEmail"),"");
		//--------------------------------------//			
		
		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_Dsp_ReqReten.jsp?i_docno="+iDocNo;
		String errorPage = "SERV_Add_ReqReten.jsp?error=1&refresh=yes&mode="+mode+"&i_docno="+iDocNo;
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
		   
	
		   if (mode.equalsIgnoreCase("ADD")) {		
		   			System.out.println("---------------------Start Update ReqReten ----------------------");
		   			
					sql.delete(0,sql.length());
				 	sql.append(" update lan:serv_rethd set ")
					   .append(" i_doc_status='I' , ")
					   .append(" i_staff_payback='").append(user.getEmpId()).append("' , ")
		  	           .append(" d_staff_payback=current , ")
  			           .append(" d_est_chq=today+15 , ")
					   .append(" i_notice='").append(iNotice).append("' , ")
					   .append(" f_id_card='").append(fIDCard).append("' ,")
			           .append(" f_lost_reten='").append(fLoseReten).append("' ");
					//------ 2022-06-30 , add new field ------//
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
				    stmt.executeUpdate(sql.toString());
				    System.out.println("--------------------- executeUpdate SERV_RETHD ----------------------");		   	

					sql.delete(0,sql.length());
					sql.append(" update lan:serv_signb set ")
					   .append(" d_fin_use=today , ")
					   .append(" f_use='N'  ")
					   .append(" where i_company='").append(iCompany).append("' ")
		           	   .append(" and i_project='").append(iProject).append("' ")
			           .append(" and i_signb='").append(iSignB).append("' ");					
					stmt.executeUpdate(sql.toString());
					System.out.println("--------------------- executeUpdate SERV_SIGNB ----------------------");
		   } 
		   
		   
		   
		   
		   else if (mode.equalsIgnoreCase("EDIT")) {
					sql.delete(0,sql.length());
					sql.append(" update lan:serv_rethd set ")
					   .append(" i_staff_payback='").append(user.getEmpId()).append("' , ")
					   .append(" d_staff_payback=current , ")
					   .append(" i_notice='").append(iNotice).append("' , ")
					   .append(" f_id_card='").append(fIDCard).append("' ,")
					   .append(" f_lost_reten='").append(fLoseReten).append("' ")
					   //------ 2022-06-30 , add new field ------//
					   .append(", i_paytype='"+iPayType+"' ")
					   .append(", i_paybnk='"+iPayBnk+"' ")
					   .append(", i_payacc='"+iPayAcc+"' ")
					   .append(", i_email='"+iEmail+"' ")						
					   //----------------------------------------//						   
					   .append(" where i_docno='").append(iDocNo).append("' ");							
					stmt.executeUpdate(sql.toString());
					System.out.println("--------------------- executeUpdate SERV_RETHD ----------------------");				   	
		   }
		   
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



