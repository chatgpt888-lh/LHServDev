package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;
import java.text.SimpleDateFormat;

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
 public class InitResvTimeServlet extends DBServlet {	 
	 private static String cName = "/LHServ/InitResvTimeServlet";
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
	    User user = (User) obj;
	    String empId = user.getEmpId();
	    Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
	    java.util.Date today = new java.util.Date();
	    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd", new Locale("en","US"));
	    java.util.Calendar currentCal = java.util.Calendar.getInstance(Locale.ENGLISH);
	    
	    String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
	    ResvTime resv_time = (ResvTime)session.getAttribute("resv_time");
	    if (resv_time == null) {
	    	resv_time = new ResvTime();
	    }
	    String resvDate = formatter.format(today);
	    
	    int day = 0;
	    int month = 0;
	    int year = 0;
	    year = Integer.parseInt(resvDate.substring(0, 4));
	    month = Integer.parseInt(resvDate.substring(5, 7));
	    day = Integer.parseInt(resvDate.substring(8));
	    int week = 1;
	    int firstDay = 1;
	    String begRegisDate = "";
	    
	    java.util.Date begRegDate = null;
	    currentCal = new GregorianCalendar(year, month-1, day);
	    currentCal.add(Calendar.DATE,13);
	    //System.out.println("Date + 14 days is : " + formatter.format(currentCal.getTime()));
	    begRegisDate = formatter.format(currentCal.getTime());
	    formatter = new SimpleDateFormat("yyyy-MM", new Locale("th","TH"));
	    String begMnth = formatter.format(currentCal.getTime());
	    //System.out.println("Date + 14 days is : "+ begMnth);
	    
	    String chkMonth = doString.checkString(req.getParameter("chkMonth"));
	    String chkYear = doString.checkString(req.getParameter("chkYear"));
	    if (chkMonth.equals("")) {
	    	if(Integer.toString(rightNow.get(Calendar.MONTH)+1).length() == 1) {
	    		chkMonth = "0" + Integer.toString(rightNow.get(Calendar.MONTH)+1);
	    	} else {
	    		chkMonth = Integer.toString(rightNow.get(Calendar.MONTH)+1);
	    	}	    	
	    }
	    if (chkYear.equals("")) {
	    	chkYear = cur_year;
	    }
	    String site = doString.checkString(req.getParameter("Project"));
	    String comId = "";
	    String projId = "";
	    if (!site.equals("")) {
	    	comId = site.substring(0, 2);
	    	projId = site.substring(2);
	    }
	    String vendor = doString.checkString(req.getParameter("Vendor"));
	    String group = "";
	    int idx=0;
	    if (!vendor.equals("")) {
	    	idx = vendor.indexOf("|");
	    	if (idx != -1) {
	    		group = vendor.substring(idx+1);
	    		vendor = vendor.substring(0, idx);
	    	}
	    }
	    String view_lock = doString.checkString(req.getParameter("view_lock"),"N");
	    
	    if (view_lock.equals("N")) {
		    resv_time.setEmpId(empId);
		    resv_time.setResvDate(resvDate);
		    resv_time.setChkMonth(chkMonth);
		    resv_time.setChkYear(chkYear);
		    resv_time.setComId(comId);
		    resv_time.setProjId(projId);
		    resv_time.setVendor(vendor);
		    resv_time.setGroup(group);
		    resv_time.setBegRegisDate(currentCal.getTime());
		    resv_time.clearChkTime();
	    }
	    resv_time.setView_lock((view_lock.equals("Y")) ? true : false);
		String targetPage = "SERV_ResvTime.jsp";
		
	    StringBuffer sql = new StringBuffer();
	    Connection conn = null;
	    Statement stmt = null;
	    ResultSet rs = null;
	    try {
	        if (ds == null)
	            getDS();
	        conn = ds.getConnection();
	        conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	        conn.setAutoCommit(true);
	        stmt = conn.createStatement();
	        
		    if (begMnth.equals(Integer.toString(Integer.parseInt(chkYear)-543)+"-"+chkMonth)) {
			    Calendar calendar = new GregorianCalendar();
			    calendar.setTime(currentCal.getTime());
			    week = calendar.get(Calendar.WEEK_OF_MONTH);
			    //System.out.println("Week : "+week);
				if (week == 1) {
					firstDay = 1;
				} else {
			        rs = stmt.executeQuery("SELECT DATE('"+begRegisDate+"'),  DAY(DATE('"+begRegisDate+"')-WEEKDAY(DATE('"+begRegisDate+"'))) FROM lan:pvd_session");
			        if (rs != null) {
			        	if (rs.next() == true) {
			        		firstDay = rs.getInt(2);
			        	}
			        	rs.close();
			        	rs=null;
			        }
				}
		    }
		    if (view_lock.equals("N")) {
		    	resv_time.setWeek(week);
		    	resv_time.setFirstDayOfWeek(firstDay);
		    }
		    
	        stmt.close();
	        conn.close();
	        stmt = null;
	        conn = null;
	        
	        session.setAttribute("resv_time", resv_time);
	        res.sendRedirect(targetPage);
	    } catch (Exception e) {
	        System.out.println("ERROR /LHServ/InitResvTimeServlet : " + e.getMessage());
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