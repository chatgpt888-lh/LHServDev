package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.naming.*;

import com.lh.servlet.DBServlet;
import com.lh.util.doString;
import com.lh.exception.InvalidParameterException;
import serv.common.User;
import serv.exception.*;


public class AddTimeServlet extends DBServlet {
private static String cName = "/LHServ/AddTimeServlet.java";
public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
    String mName = new String(cName + ".performTask: ");
    System.out.println(mName + "start.");
	PrintWriter out = res.getWriter();

    HttpSession session = req.getSession(false);
    if (session == null) {
        /*s
        * Redirect user to login page if
        * there's no session.
        */
        res.sendRedirect("/LHServ/warning.htm");
        return;
    }
    Object obj = session.getAttribute("USER");
    if (obj == null) {
        /*
        * Redirect user to login page if
        * there's no session.
        */
        res.sendRedirect("/LHServ/warning.htm");
        return;
    }


	String comId = "";
	String projId = "";
	String Act = doString.checkString(req.getParameter("Act"),"-");
	double Price = Double.parseDouble(doString.checkString(req.getParameter("Price"),"0.0"));	
	String extra = doString.checkString(req.getParameter("extra"),"-");
	
	String start_mnth = doString.checkString(req.getParameter("start_mnth"),"-");
	String start_year = doString.checkString(req.getParameter("start_year"),"-");	
	String end_mnth = doString.checkString(req.getParameter("end_mnth"),"-");
	String end_year = doString.checkString(req.getParameter("end_year"),"-");		
	String start_date = start_year+"-"+start_mnth+"-01";
	String end_date = end_year+"-"+end_mnth+"-01";	
	
	
	String project = doString.checkString(req.getParameter("Project"),"-");
	if(!project.equals("-")) {
		comId = project.substring(0,2);
		projId = project.substring(2,5);
	}
	String month = doString.checkString(req.getParameter("Month"));
	String year = doString.checkString(req.getParameter("Year"));
	String successPage = "/LHServ/save_ok.jsp?redirect_url=SERV_InfTime.jsp?Project="+project;
	String errorPage = "";	
	

	StringBuffer sql = new StringBuffer();
    Connection conn = null;
    Statement stmt = null;
	Statement stmt1 = null;
    ResultSet rs = null;
    try {
        if (ds == null)
            getDS();
        conn = ds.getConnection();
        conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
        conn.setAutoCommit(false);
        stmt = conn.createStatement();
		stmt1 = conn.createStatement();
		
		
	if (Act.equals("Del")) {	
	
		String v_date = "";
		String startDate = "";
		String endDate = ""; 
		String d_date[] = null;
		d_date = getParameterValues(req, "chkTime", true, true, null, "โปรดระบุรายการที่ต้องการลบ !!!");	   

		 if (d_date != null) {
			for (int x = 0; x < d_date.length; x++) {
				v_date = d_date[x];	
				startDate = v_date.substring(0,10);
				endDate = v_date.substring(10);
				stmt.executeUpdate("DELETE FROM lan:serv_infrate WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND d_start = '" + startDate + "' AND d_end = '"+endDate+"'");
			}// end for
		} //end if != null
	}//end if Act Del
	errorPage = "/LHServ/save_ok.jsp?redirect_url=SERV_InfTime.jsp&error=true";
	
	if (Act.equals("Add")) {				
							

		if (Price == 0.0){		
			throw new InvalidParameterException("ท่านยังไม่ได้ระบุราคา โปรดตรวจสอบ!!!");
		} else {		
		
			sql.delete(0, sql.length());	
			sql.append("SELECT * FROM lan:serv_infrate ")
			   .append("WHERE i_company = '"+comId+"' ")
			   .append("AND i_project = '"+projId+"' ")
			   .append("AND (d_start = '"+start_date+"' AND d_end = '"+end_date+"') ");
			  // .append("AND d_end = '"+end_date+"' ")
			  // .append("AND f_extra = '"+extra+"' ");
			rs = stmt.executeQuery(sql.toString());
			if (rs.next() == true) {	
				throw new InvalidParameterException("ช่วงเวลา /ประเภทการจ่าย ดังกล่าวมีการบันทึกแล้ว โปรดตรวจสอบ!!!");	
			} else {
		
				sql.delete(0, sql.length());
				sql.append("INSERT INTO lan:serv_infrate (i_company, i_project, i_month, i_year, d_start, ")
					 .append("d_end, f_extra, z_price) VALUES ('")
					 .append(comId)
					 .append("', '")
					 .append(projId)
					 .append("', '")
					.append(month)
					.append("', '")
				   .append(year)
					.append("', '")				
					 .append(start_date)
					 .append("', '")
					 .append(end_date)
					 .append("', '")
					 .append(extra)
					 .append("', ")
					 .append(Price)
					 .append(")");										 
				stmt1.executeUpdate(sql.toString()); 				
			}//end if rs
		}// end check Price = 0
	
			errorPage = "/LHServ/save_ok.jsp?redirect_url=SERV_AddInfRate.jsp&error=true";
	
	} // end Act Add	
	if(Act.equals("Edit")) {
	
				sql.delete(0, sql.length());
				sql.append("UPDATE lan:serv_infrate SET f_extra = '")
						.append(extra)
						.append("', z_price = '")
						.append(Price)
						.append("' WHERE i_company = '")
						.append(comId)
						.append("' AND i_project = '")
						.append(projId)	
						.append("' AND d_start = '")
						.append(start_date)	
						.append("' AND d_end = '")
						.append(end_date)
						.append("'");
					stmt1.executeUpdate(sql.toString());
				errorPage = "/LHServ/save_ok.jsp?redirect_url=SERV_InfTime.jsp&error=true";				
	} // end Act Edit
		
		conn.commit();
        stmt.close();
        conn.close();
        stmt = null;
        conn = null;
        // forward to the success page.
        res.sendRedirect(successPage);
	} catch (InvalidParameterException e) {
		   showError(out, e.getMessage());
	   } catch (Exception e) {
		   try {
			   if (conn != null)
				   conn.rollback();
		   } catch (SQLException ignore) {
		   }
		   System.out.println("ERROR /LHServ/AddTimeServlet : " + e.getMessage());
		   System.out.println("ERROR /LHServ/AddTimeServlet SQL : " + sql.toString());
		   res.sendRedirect(errorPage);
	   } finally {
		   out.close();
		   try {
			   if (rs != null)
				   rs.close();
			   if (stmt != null)
				   stmt.close();
			   if (stmt1 != null)
				   stmt1.close();
			   if (conn != null)
				   conn.close();				             
		   } catch (SQLException ignore) {
		   }
	   }
	   System.out.println(mName + "end.");
   }
   }
        
        
   