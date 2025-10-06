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
public class SERV_PaySchdServlet extends DBServlet  {
	
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
 */       
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
		String payDate="",conStrucDate="",staffDate="",manDate="",zoneDate="",vpDate="",changeDate="";// for convert date to String
		String dd="",mm="";
		int yyyy=0;
		
		String mode = doString.checkString(req.getParameter("mode"), "");
		String dPayDD = doString.checkString(req.getParameter("d_pay_dd"),"");
		String dPayMM = doString.checkString(req.getParameter("d_pay_mm"),"");
		String dPayYY = doString.checkString(req.getParameter("d_pay_yy"),"");	
	
		String dConDD = doString.checkString(req.getParameter("d_con_dd"),"");
		String dConMM = doString.checkString(req.getParameter("d_con_mm"),"");
		String dConYY = doString.checkString(req.getParameter("d_con_yy"),"");
	
		String dStaffDD = doString.checkString(req.getParameter("d_staff_dd"),"");
		String dStaffMM = doString.checkString(req.getParameter("d_staff_mm"),"");
		String dStaffYY = doString.checkString(req.getParameter("d_staff_yy"),"");
	
		String dManDD = doString.checkString(req.getParameter("d_man_dd"),"");
		String dManMM = doString.checkString(req.getParameter("d_man_mm"),"");
		String dManYY = doString.checkString(req.getParameter("d_man_yy"),"");
	
		String dZoneDD = doString.checkString(req.getParameter("d_zone_dd"),"");
		String dZoneMM = doString.checkString(req.getParameter("d_zone_mm"),"");
		String dZoneYY = doString.checkString(req.getParameter("d_zone_yy"),"");
		
		String dVPDD = doString.checkString(req.getParameter("d_vp_dd"),"");
		String dVPMM = doString.checkString(req.getParameter("d_vp_mm"),"");
		String dVPYY = doString.checkString(req.getParameter("d_vp_yy"),"");
		
		String dChangeDD = doString.checkString(req.getParameter("d_change_dd"),"");
		String dChangeMM = doString.checkString(req.getParameter("d_change_mm"),"");
		String dChangeYY = doString.checkString(req.getParameter("d_change_yy"),"");		
		
		String datePayment = doString.checkString(req.getParameter("datePayment"),""); // recieve value for is key to update 
		
		
		//============= Format dd-mm-yyy=============
		String dPayment = dPayDD+"-"+dPayMM+"-"+dPayYY;
		String dConStructor = dConDD+"-"+dConMM+"-"+dConYY;
		String dStaff = dStaffDD+"-"+dStaffMM+"-"+dStaffYY;
		String dMan = dManDD+"-"+dManMM+"-"+dManYY;
		String dZone= dZoneDD+"-"+dZoneMM+"-"+dZoneYY;
		String dVP= dVPDD+"-"+dVPMM+"-"+dVPYY;
		String dChange=  dChangeDD+"-"+dChangeMM+"-"+dChangeYY ;		
		//		============= Format dd-mm-yyy=============
		
		String savePage =Constants.SAVE_PAGE;
		String successPage ="SERV_PaySchd01.jsp";
		String errorPage = "SERV_PaySchd02.jsp?error=1";
		errorPage += "&d_pay_dd="+dPayDD+"&d_pay_mm="+dPayMM+"&d_pay_yy="+dPayYY;
		errorPage += "&d_con_dd="+dConDD+"&d_con_mm="+dConMM+"&d_con_yy="+dConYY;
		errorPage += "&d_staff_dd="+dStaffDD+"&d_staff_mm="+dStaffMM+"&d_staff_yy="+dStaffYY;
		errorPage += "&d_man_dd="+dManDD+"&d_man_mm="+dManMM+"&d_man_yy="+dManYY;
		errorPage += "&d_zone_dd="+dZoneDD+"&d_zone_mm="+dZoneMM+"&d_zone_yy="+dZoneYY;
		errorPage += "&d_vp_dd="+dVPDD+"&d_vp_mm="+dVPMM+"&d_vp_yy="+dVPYY;
		errorPage += "&d_change_dd="+dChangeDD+"&d_change_mm="+dChangeMM+"&d_change_yy="+dChangeYY;
		errorPage += "&d_payment="+datePayment+"&mode="+mode;
		
		
		String otherMsg = "";
		String errorCode = "";
    
		StringBuffer sql = new StringBuffer();
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		int cnt = -1;

		System.out.println("mode="+mode);

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
				System.out.println("start add mode");
			//---=========== Check d_payment is exist or not =============---//
			  int chkY = Integer.parseInt(doString.checkString(dPayYY,"0"));
			  if (chkY>2400) chkY -= 543;
			
			   sql.delete(0,sql.length());
			   sql.append(" select count(*) as cnt from lan:serv_payschd where ")
				  .append(" d_payment='").append(chkY+"-"+dPayMM+"-"+dPayDD).append("' ");			
				rs = stmt.executeQuery(sql.toString());			
					
		
			if (rs.next()){
				 cnt = rs.getInt("cnt");
				}
				rs.close();
	
				
			 if (cnt==0) {
			 System.out.println("cnt="+cnt);
			//---======= d_payment is not exist ========---//
			 
			 if (dPayment.length()==10) {
			    dd = dPayment.substring(0,2);
			    mm = dPayment.substring(3,5);
			    yyyy = Integer.parseInt(dPayment.substring(6,10));
			    if (yyyy>2400) yyyy -= 543;
				   	dPayment = yyyy+"-"+mm+"-"+dd;
				   	payDate = dPayment.toString();
			 } // end if dPayment
					
			if (dConStructor.length()==10) {
				dd = dConStructor.substring(0,2);
				mm = dConStructor.substring(3,5);
				yyyy = Integer.parseInt(dConStructor.substring(6,10));
				if (yyyy>2400) yyyy -= 543;
					dConStructor = yyyy+"-"+mm+"-"+dd;
					conStrucDate = dConStructor.toString();
			} // end if dConStrucDate

			if (dStaff.length()==10) {
				dd = dStaff.substring(0,2);
				mm = dStaff.substring(3,5);
				yyyy = Integer.parseInt(dStaff.substring(6,10));
				if (yyyy>2400) yyyy -= 543;
					dStaff = yyyy+"-"+mm+"-"+dd;
					staffDate = dStaff.toString();
			} // end if dStaff
						 
			if (dMan.length()==10) {
				dd = dMan.substring(0,2);
				mm = dMan.substring(3,5);
				yyyy = Integer.parseInt(dMan.substring(6,10));
				if (yyyy>2400) yyyy -= 543;
					dMan = yyyy+"-"+mm+"-"+dd;
					manDate = dMan.toString();
			} // end if dMan		
			if (dZone.length()==10) {
				dd = dZone.substring(0,2);
				mm = dZone.substring(3,5);
				yyyy = Integer.parseInt(dZone.substring(6,10));
				if (yyyy>2400) yyyy -= 543;
					dZone = yyyy+"-"+mm+"-"+dd;
					zoneDate = dZone.toString();
			} // end if Zone
						 
			if (dVP.length()==10) {
				dd = dVP.substring(0,2);
				mm = dVP.substring(3,5);
				yyyy = Integer.parseInt(dVP.substring(6,10));
				if (yyyy>2400) yyyy -= 543;
					dVP = yyyy+"-"+mm+"-"+dd;
					vpDate = dVP.toString();
			} // end if VP
				
			if (dChange.length()==10) {
				dd = dChange.substring(0,2);
				mm = dChange.substring(3,5);
				yyyy = Integer.parseInt(dChange.substring(6,10));
				if (yyyy>2400) yyyy -= 543;
				    dChange = yyyy+"-"+mm+"-"+dd;
					changeDate = dVP.toString();
			} // end if VP				
				
				
				sql.delete(0,sql.length());
				sql.append("insert into lan:serv_payschd (d_payment,d_contructor,d_service_staff,d_service_man,d_service_zone,d_vp,d_change")
				   .append(" ) values ( ")
				   .append(" '").append(payDate).append("' , ")
				   .append(" '").append(conStrucDate).append("' , ")
				   .append(" '").append(staffDate).append("' , ")
				   .append(" '").append(manDate).append("' , ")
				   .append(" '").append(zoneDate).append("', ")
				   .append(" '").append(vpDate).append("' , ")
			 	   .append(" '").append(changeDate).append("' ")
				   .append(" ) "); 
				
				stmt.executeUpdate(sql.toString());
				successPage = "SERV_PaySchd01.jsp";
				System.out.println("successADD");
												
				} else {
				//----========= d_payment is exist , return to input page =========--//	
					successPage = errorPage;
					errorCode = "1";
					otherMsg = "วันที่จ่ายเงิน  มีอยู่ในระบบแล้วกรุณากรอกวันที่ใหม่ !" ;
				}
		}//end add  mode
		else if (mode.equalsIgnoreCase("DELETE")) {		
			
			savePage =Constants.APP_PATH+"/SERV_PaySchd01.jsp";
			successPage = Constants.APP_PATH+"/SERV_PaySchd01.jsp";
			errorPage = Constants.APP_PATH+"/SERV_PaySchd01.jsp?error=1";	
			otherMsg = "";
		
			String ttt = "";
			String[] delid = req.getParameterValues("del_checkbox");
			if (delid!=null) {
			  for (int i=0;i<delid.length;i++) {
				StringTokenizer id = new StringTokenizer(delid[i],":");
	 			 	 	    
					//---==== If d_payment is missing , continue next data =====----//
					if (id.countTokens()!=1) continue;
						sql.delete(0,sql.length());
						sql.append(" delete from lan:serv_payschd ")
						   .append(" where d_payment='").append(id.nextToken()).append("' "); 
								
				        stmt.executeUpdate(sql.toString());
			 } // end for
	       }
	     }//end delete mode
		 else if (mode.equalsIgnoreCase("EDIT")) {
			
			// ===================== dPayment=update key    ================================
	
		 	 	int yearPay = Integer.parseInt(dPayYY); 
				int yearCon = Integer.parseInt(dConYY); 
				int yearStaff = Integer.parseInt(dStaffYY); 
				int yearMan = Integer.parseInt(dManYY); 
				int yearZone = Integer.parseInt(dZoneYY); 
				int yearVP = Integer.parseInt(dVPYY); 
				int yearChange = Integer.parseInt(dChangeYY); 
				
			 	if (yearPay>2400){yearPay -= 543;}
			 	if (yearCon>2400){yearCon -= 543;}
			 	if (yearStaff>2400){yearStaff -= 543;} 
			 	if (yearMan>2400){yearMan -= 543;}
			 	if (yearZone>2400){yearZone -= 543;}
			 	if (yearVP>2400){yearVP -= 543;}
				if (yearChange>2400){yearChange -= 543;}
			 
			  	dPayment = yearPay+"-"+dPayMM+"-"+dPayDD;
				dConStructor = yearCon+"-"+dConMM+"-"+dConDD;
				dStaff = yearStaff+"-"+dStaffMM+"-"+dStaffDD;
				dMan = yearMan+"-"+dManMM+"-"+dManDD;
				dZone= yearZone+"-"+dZoneMM+"-"+dZoneDD;
				dVP=  yearVP+"-"+dVPMM+"-"+dVPDD;
				dChange=  yearChange+"-"+dChangeMM+"-"+dChangeDD;

				
				if(!dPayment.toString().equals(datePayment.toString())){
					sql.delete(0,sql.length());
					sql.append(" select count(*) as cnt from lan:serv_payschd  ")
					   .append(" where d_payment='").append(dPayment).append("' ")//key update
					   .append(" and  d_payment <>'").append(datePayment).append("' ");// hidden key		       
					rs = stmt.executeQuery(sql.toString());	 
				
					System.out.println(sql.toString());
					if (rs.next()){
					   cnt = rs.getInt("cnt");
						 }
					rs.close();
				
				} else {
				   cnt=0;	 
				}

				
				if (cnt==0) {
						 	
					sql.delete(0,sql.length());		 	
			 		sql.append("update lan:serv_payschd set ")
						   .append(" d_payment = '").append(dPayment.toString()).append("' , ")
						   .append(" d_contructor = '").append(dConStructor.toString()).append("', ")
						   .append(" d_service_staff = '").append(dStaff.toString()).append("', ")
						   .append(" d_service_man = '").append(dMan.toString()).append("', ")
						   .append(" d_service_zone = '").append(dZone.toString()).append("', ")
						   .append(" d_vp = '").append(dVP.toString()).append("' , ")
						   .append(" d_change = '").append(dChange.toString()).append("' ")
						   .append(" where d_payment='").append(datePayment).append("' ");
					
					 stmt.executeUpdate(sql.toString());
					 otherMsg="";
					 successPage = "SERV_PaySchd01.jsp";
					 System.out.println("successEDIT");
					 
				}else { //----========= d_payment is exist , return to input page =========--//
					successPage = errorPage;
					errorCode = "1";
					otherMsg = "วันที่จ่ายเงิน  มีอยู่ในระบบแล้วกรุณากรอกวันที่ใหม่ !" ;		
				}
	
			}
  //----========================================----//
	
			conn.commit();
			stmt.close();
			conn.close();
			conn = null;

			// Redirect to the finish page.
			//res.sendRedirect(doString.UnicodeToMS874(successPage));
			System.out.println("redirect 1");
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
			System.out.println("redirect 2");
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
