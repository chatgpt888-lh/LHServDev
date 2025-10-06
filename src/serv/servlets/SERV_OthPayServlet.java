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
public class SERV_OthPayServlet extends DBServlet  {
	
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

  
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();

		String mode = doString.checkString(req.getParameter("mode"), "");
		String selProj = doString.checkString(req.getParameter("sel_project"));
		String comId = "";
		String projId = "";
		if (!selProj.equals("")) {
			comId = selProj.substring(0,2);
			projId = selProj.substring(3);
		}		
		String vendor = doString.checkString(req.getParameter("vendor"));
		String payMonth = doString.checkString(req.getParameter("payMonth"));
		String payYear = doString.checkString(req.getParameter("payYear"));
		String mnthDate = payYear+"-"+payMonth+"-01";
		
		java.util.Calendar currentCal = java.util.Calendar.getInstance(Locale.ENGLISH);
		currentCal = new  GregorianCalendar(Integer.parseInt(payYear), Integer.parseInt(payMonth)-1, 1);
		int daysInMonth = currentCal.getActualMaximum(currentCal.DAY_OF_MONTH);
		String conDate = payYear+"-"+payMonth+"-"+doString.displayNumber("00", daysInMonth);
		String payDate = "";
		String wageAmnt = doString.checkString(req.getParameter("wage_amnt"),"0");
		String cntrlAmnt = doString.checkString(req.getParameter("cntrl_amnt"),"0");
		int rowEffected = 0;
		String savePage =Constants.SAVE_PAGE;
		String successPage = "SERV_OthPayLst.jsp?sel_project="+selProj+"&vendor="+vendor;
		String errorPage = successPage + "&error=1";		
		String otherMsg = "";
		String errorCode = "";
    
		StringBuffer sql = new StringBuffer();
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		SERV_CommonData common = null;
		 try {
			if (ds == null)
				getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
			common = new SERV_CommonData(conn);
			rs = stmt.executeQuery("SELECT d_contructor, d_payment FROM lan:serv_payschd WHERE d_contructor <= '"+conDate+"' ORDER BY d_contructor DESC");
			if (rs != null) {
				if (rs.next() == true) {
					payDate = doString.checkString(rs.getString("D_PAYMENT"));
				}
				rs.close();
				rs=null;
			}			
		    //----======== Add Mode , Inseitrt Query =========----//
			if (mode.equalsIgnoreCase("S")) {
				sql.delete(0,sql.length());
				sql.append("update lan:serv_othpayment set z_wage = ")
					.append(wageAmnt)
					.append(", z_control = ")
					.append(cntrlAmnt)
					.append(", d_payment = '")
					.append(payDate)
				  .append("', f_tran = 'Y' where i_company = '")
				  .append(comId)
				  .append("' and i_project = '")
				  .append(projId)
				  .append("' and i_vendor = '")
				  .append(vendor)
				  .append("' and i_month = '")
				  .append(mnthDate)
				  .append("'");
				rowEffected = stmt.executeUpdate(sql.toString());
				if (rowEffected <= 0) {
					sql.delete(0,sql.length());
					sql.append("insert into lan:serv_othpayment (i_company,i_project,i_vendor,i_month,z_wage,z_control,d_payment,f_tran")
							  .append(" ) values ( ")
							  .append(" '").append(comId).append("' , ") 
							  .append(" '").append(projId).append("' , ")
							  .append(" '").append(vendor).append("' , ")
							  .append(" '").append(mnthDate).append("', ")
							  .append(wageAmnt).append(", ")
							  .append(cntrlAmnt).append(", '")
							  .append(payDate).append("', 'Y')");
					rowEffected = stmt.executeUpdate(sql.toString());
					if (rowEffected != 1) {
						throw new Exception("SERV_OTHPAYMENT: Wrong insert count");
					}
				}
			} else if (mode.equalsIgnoreCase("D")) {	
	 			String[] delMnth = req.getParameterValues("delMnth");
	 			if (delMnth!=null) {
	 			 	 for (int i=0;i<delMnth.length;i++) {
	 			 		 	mnthDate = doString.checkString(delMnth[i]);
	 			 		 	if (!mnthDate.equals("")) {
	 							sql.delete(0,sql.length());
	 							sql.append("delete from lan:serv_othpayment ")
	 							  .append(" where i_company = '")
	 							  .append(comId)
	 							  .append("' and i_project = '")
	 							  .append(projId)
	 							  .append("' and i_vendor = '")
	 							  .append(vendor)
	 							  .append("' and i_month = '")
	 							  .append(mnthDate)
	 							  .append("'");	 			 		 		
	 			 		 		stmt.executeUpdate(sql.toString());	
	 			 		 	}
	 			 	 } // end for
	 			}
	 		}
			conn.commit();
			stmt.close();
			conn.close();
			conn = null;

			genRedirectCode(out,savePage,successPage,errorCode,otherMsg);
		} catch (Exception e) {
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
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");

	}

}
