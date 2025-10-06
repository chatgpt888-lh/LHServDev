package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;


import com.lh.servlet.DBServlet;
import com.lh.util.doString;
import serv.common.User;
import serv.common.ResvTime;
import serv.common.ChkTime;
/**
 * Servlet implementation class for Servlet: InitResvTimeServlet
 *
 */
 public class ViewResvTimeServlet extends DBServlet {	 
	 private static String cName = "/LHServ/ViewResvTimeServlet";
	public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
	    String mName = new String(cName + ".performTask: ");
	    System.out.println(mName + "start.");
	    HttpSession session = req.getSession(false);
	    if (session == null) {
	        /*
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
	    
	    String docNo = doString.checkString(req.getParameter("docNo"));
	    String empId = "";
	    java.util.Calendar currentCal = java.util.Calendar.getInstance(Locale.ENGLISH);
	    ResvTime resv_time = (ResvTime)session.getAttribute("resv_time");
	    if (resv_time == null) {
	    	resv_time = new ResvTime();
	    }
	    String resvDate = "";
	    int day = 0;
	    int month = 0;
	    int year = 0;
	    String mnthDate = "";
	    String chkMonth = "";
	    String chkYear = "";
	    String brand = "";
	    String comId = "";
	    String projId = "";
	    String vendor = "";
	    String group = "";
	    String time = "";
	    int idx=0;
	    
	    
		String targetPage = "SERV_ViewTimeLst.jsp";
	    StringBuffer sql = new StringBuffer();
	    Connection conn = null;
	    Statement stmt = null;
	    Statement tstmt = null;
	    ResultSet rs = null;
	    ResultSet rsTime = null;
	    try {
	        if (ds == null)
	            getDS();
	        conn = ds.getConnection();
	        conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	        conn.setAutoCommit(true);
	        stmt = conn.createStatement();
	        tstmt = conn.createStatement();
	        
	        rs = stmt.executeQuery("SELECT i_employ, DATE(d_keyin) AS KEY_DATE, i_month, i_company, i_project, i_vendor, i_group FROM lan:serv_chkuphd WHERE i_chkupno = '"+docNo+"'");
	        if (rs != null) {
	        	if (rs.next() == true) {
	        		empId = doString.checkString(rs.getString("I_EMPLOY"));
	        		resvDate = doString.checkString(rs.getString("KEY_DATE"));
	        	    year = Integer.parseInt(resvDate.substring(0, 4));
	        	    month = Integer.parseInt(resvDate.substring(5, 7));
	        	    day = Integer.parseInt(resvDate.substring(8));
	        	    currentCal = new GregorianCalendar(year, month-1, day);
	        	    currentCal.add(Calendar.DATE,13);
	        		mnthDate = doString.checkString(rs.getString("I_MONTH"));
	        		chkMonth = mnthDate.substring(5,7);
	        		chkYear = Integer.toString(Integer.parseInt(mnthDate.substring(0,4))+543);
	        		comId = doString.checkString(rs.getString("I_COMPANY"));
	        		projId = doString.checkString(rs.getString("I_PROJECT"));
	        		vendor = doString.checkString(rs.getString("I_VENDOR"));
	        		group = doString.checkString(rs.getString("I_GROUP"));
	        	}
	        	rs.close();
	        	rs=null;
	        }
	        rs = stmt.executeQuery("SELECT i_brand FROM lan:serv_brand WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
	        if (rs != null) {
	        	if (rs.next() == true) {
	        		brand = doString.checkString(rs.getString("I_BRAND"));
	        	}
	        	rs.close();
	        	rs=null;
	        }
	        
    	    resv_time.setEmpId(empId);
    	    resv_time.setResvDate(resvDate);
    	    resv_time.setChkMonth(chkMonth);
    	    resv_time.setChkYear(chkYear);
    	    resv_time.setComId(comId);
    	    resv_time.setProjId(projId);
    	    resv_time.setVendor(vendor);
    	    resv_time.setGroup(group);
    	    resv_time.setWeek(1);
    	    resv_time.setFirstDayOfWeek(1);
    	    resv_time.setBegRegisDate(currentCal.getTime());
    	    resv_time.clearChkTime();
    	    Vector chkTimeList = resv_time.getChkTimeList();
    	    rs = stmt.executeQuery("SELECT DAY(d_chckup) AS CHK_DAY, i_time FROM lan:serv_chkupdt WHERE i_chkupno = '"+docNo+"'");
    	    if (rs != null) {
    	    	while (rs.next() == true) {
    	    		ChkTime chkTime = new ChkTime();
    	    		time = doString.checkString(rs.getString("I_TIME"));
    	    		rsTime = tstmt.executeQuery("SELECT b_time FROM lan:serv_bctime WHERE i_brand = '"+brand+"' AND c_time = '"+time+"'");
    	    		if (rsTime != null) {
    	    			if (rsTime.next() == true) {
    	    				time = doString.checkString(rsTime.getString("B_TIME"));
    	    			} else {
    	    				time = "";
    	    			}
    	    			rsTime.close();
    	    			rsTime=null;
    	    		}
    	    		chkTime.setChkDate(doString.displayNumber("00", rs.getInt("CHK_DAY")));
    	    		chkTime.setChkTime(time);
    	    		chkTime.setReserve(false);
    	    		chkTimeList.add(chkTime);
    	    	}
    	    	rs.close();
    	    	rs=null;
    	    }
    	    tstmt.close();
	        stmt.close();
	        conn.close();
	        stmt = null;
	        tstmt = null;
	        conn = null;
	        session.setAttribute("resv_time", resv_time);
	        res.sendRedirect(targetPage);
	    } catch (Exception e) {
	        System.out.println("ERROR /LHServ/ViewResvTimeServlet : " + e.getMessage());
	    } finally {
	        if (rs != null) {
	            try {
	                rs.close();
	            } catch (SQLException ignore) {
	            }
	        }
	        if (stmt != null) {
	            try {
	                stmt.close();
	            } catch (SQLException ignore) {
	            }
	        }
	        if (tstmt != null) {
	            try {
	                tstmt.close();
	            } catch (SQLException ignore) {
	            }
	        }
	        if (conn != null) {
	            try {
	                conn.close();
	            } catch (SQLException ignore) {
	            }
	        }
	    }            
	    System.out.println(mName + "end.");
	}	  	    
}