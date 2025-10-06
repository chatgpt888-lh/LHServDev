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
 public class ScrollResvTimeServlet extends DBServlet {	 
	 private static String cName = "/LHServ/ScrollResvTimeServlet";
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
	    ResvTime resv_time = (ResvTime)session.getAttribute("resv_time");
	    if (resv_time == null) {
	        /*
		        * Redirect user to login page if
		        * there's no session.
		        */
		        res.sendRedirect("/LHServ/warning.htm");
		        return;	    	
	    }
	    
	    Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
	    java.util.Date today = new java.util.Date();
	    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd", new Locale("en","US"));
	    String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
	    String resvDate = formatter.format(today);
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
	    String targetPage = doString.checkString(req.getParameter("targetPage"), "SERV_ResvTime.jsp");
	    String mode = doString.checkString(req.getParameter("Mode"),"A");
	    String view_lock = doString.checkString(req.getParameter("view_lock"),"N");
	    
	    int curWeek = Integer.parseInt(doString.checkString(req.getParameter("CurWeek"),"1"));	    
	    String direct = doString.checkString(req.getParameter("direction"));
	    int backWeek = Integer.parseInt(doString.checkString(req.getParameter("BackWeek"),"1"));
	    int backDay = Integer.parseInt(doString.checkString(req.getParameter("BackDay"),"1"));
	    
	    int nextDay = Integer.parseInt(doString.checkString(req.getParameter("NextDay"),"0"));
	    int nextWeek = Integer.parseInt(doString.checkString(req.getParameter("NextWeek"),"0"));
	    if (direct.equals("N")) { //Next
	    	resv_time.setFirstDayOfWeek(nextDay);
	    	resv_time.setWeek(nextWeek);
	    } else { //Back
	    	resv_time.setFirstDayOfWeek(backDay);
	    	resv_time.setWeek(backWeek);
	    }
	    
/*	    
	    resv_time.setEmpId(empId);
	    resv_time.setResvDate(resvDate);
	    resv_time.setChkMonth(chkMonth);
	    resv_time.setChkYear(chkYear);
	    resv_time.setComId(comId);
	    resv_time.setProjId(projId);
*/
	    resv_time.setView_lock((view_lock.equals("Y")) ? true : false);
	    resv_time.setVendor(vendor);
	    resv_time.setGroup(group);	 
	    Vector timeList = new Vector(5);
	    Vector chkTimeList = resv_time.getChkTimeList();
	    if (mode.equals("A")) {
		    if (chkTimeList != null) {
		    	for (int i=0; i<chkTimeList.size(); i++) {
		    		ChkTime aTime = (ChkTime)chkTimeList.elementAt(i);
		    		if (aTime != null) {
		    			if (curWeek != aTime.getWeek()) {
		    				timeList.add(aTime);
		    			}
		    		}
		    	}// end for
		    }
		    chkTimeList.removeAllElements();
		    if (timeList != null) {
		    	for (int i=0; i<timeList.size(); i++) {
		    		ChkTime aTime = (ChkTime)timeList.elementAt(i);
		    		if (aTime != null) {
		    			chkTimeList.add(aTime);
		    		}
		    	}// end for
		    }
	    }//Add Mode
	    String time = "";
	    String chkDay = "";
	    idx = 0;
	    if (mode.equals("A")) {
	    	String[] chkTime = req.getParameterValues("chkTime");
		    if (chkTime != null) {
		    	for(int i=0; i<chkTime.length;i++){
		    		time = doString.checkString(chkTime[i]);
		    		idx = time.indexOf("-");
		    		chkDay = "";
		    		if (idx > 0) {
		    			chkDay = time.substring(0, idx);
		    			time = time.substring(idx+1);
		    			ChkTime aTime = new ChkTime();
		    			aTime.setWeek(curWeek);
		    			aTime.setChkDate(chkDay);
		    			aTime.setChkTime(time);
		    			chkTimeList.addElement(aTime);
		    		}
		    	}// end for
		    }
	    }//Add Mode
	    if (mode.equals("C")) {
	    	time = doString.checkString(req.getParameter("chkTime"));
	    	if (!time.equals("")) {
	    		chkTimeList.removeAllElements();
	    		idx = time.indexOf("-");
	    		chkDay = "";
	    		if (idx > 0) {
	    			chkDay = time.substring(0, idx);
	    			time = time.substring(idx+1);
	    			ChkTime aTime = new ChkTime();
	    			aTime.setWeek(curWeek);
	    			aTime.setChkDate(chkDay);
	    			aTime.setChkTime(time);
	    			chkTimeList.addElement(aTime);
	    		}
	    	}
	    }
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
	        
	        stmt.close();
	        conn.close();
	        stmt = null;
	        conn = null;
	        session.setAttribute("resv_time", resv_time);
	        res.sendRedirect(targetPage);
	    } catch (Exception e) {
	        System.out.println("ERROR /LHServ/ScrollResvTimeServlet : " + e.getMessage());
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