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
 public class InitSetLockServlet extends DBServlet {	 
	 private static String cName = "/LHServ/InitSetLockServlet";
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
	    
	    String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
	    ResvTime resv_time = (ResvTime)session.getAttribute("resv_time");
	    if (resv_time == null) {
	    	resv_time = new ResvTime();
	    }
	    String resvDate = formatter.format(today);
	    String chkDay = "";
	    String chkMonth = doString.checkString(req.getParameter("chkMonth"));
	    String chkYear = doString.checkString(req.getParameter("chkYear"));
	    String chkTime = "";
	    String mnthDate = Integer.toString(Integer.parseInt(chkYear)-543)+"-"+chkMonth+"-01";
	    String brand = "";
	    String site = doString.checkString(req.getParameter("Project"));
	    String comId = "";
	    String projId = "";
	    if (!site.equals("")) {
	    	comId = site.substring(0, 2);
	    	projId = site.substring(2);
	    }
	    String lockId = doString.checkString(req.getParameter("lockId"));	    
	    int seqNo = Integer.parseInt(doString.checkString(req.getParameter("seqNo")));
	    
	    String vendor = doString.checkString(req.getParameter("Vendor"),"00000|00");
	    String group = "";
	    int idx=0;
	    if (!vendor.equals("")) {
	    	idx = vendor.indexOf("|");
	    	if (idx != -1) {
	    		group = vendor.substring(idx+1);
	    		vendor = vendor.substring(0, idx);	    		
	    	}
	    }	   
	    int i=0;
	    String comment = "";
		String targetPage = "SERV_SetLock.jsp";
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
	        
	    	i=0;
	    	sql.delete(0, sql.length());
	    	sql.append("SELECT COUNT(*) AS NUM_VEN FROM lan:serv_venprj WHERE i_company = '")
	    		.append(comId)
	    		.append("' AND i_project = '")
	    		.append(projId)
	    		.append("' AND i_type = '03'");
	    	rs = stmt.executeQuery(sql.toString());
	    	if (rs != null) {
	    		if (rs.next() == true) {
	    			i=rs.getInt("NUM_VEN");
	    		}
	    		rs.close();
	    		rs=null;
	    	}
	    	if (i==1) {
		    	sql.delete(0, sql.length());
		    	sql.append("SELECT p.i_vendor, p.i_group FROM lan:serv_venprj p WHERE p.i_company = '")
		    		.append(comId)
		    		.append("' AND p.i_project = '")
		    		.append(projId)
		    		.append("' AND p.i_type = '03'");
		    	rs = stmt.executeQuery(sql.toString());
		    	if (rs != null) {
		    		if (rs.next() == true) {
		    			vendor = doString.checkString(rs.getString("I_VENDOR"));
		    			group = doString.checkString(rs.getString("I_GROUP"));
		    		}
		    		rs.close();
		    		rs=null;
		    	}
	    	}
	    	
	    	rs = stmt.executeQuery("SELECT i_brand FROM lan:serv_brand WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
	    	if (rs != null) {
	    		if (rs.next() == true) {
	    			brand = doString.checkString(rs.getString(1));
	    		}
	    		rs.close();
	    		rs=null;
	    	}			
		    rs = stmt.executeQuery("SELECT c_comment FROM lan:serv_chkuplck WHERE i_month = '"+mnthDate+"' AND i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lock = '"+lockId+"' AND i_chkseq = "+seqNo+" AND f_status != 'D'");
	        if (rs != null) {
	        	if (rs.next() == true) {
	        		comment = doString.checkString(rs.getString("C_COMMENT"));
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
		    resv_time.setLockId(lockId);
		    resv_time.setSeqNo(seqNo);
		    resv_time.setVendor(vendor);
		    resv_time.setGroup(group);
		    resv_time.setWeek(1);
		    resv_time.setFirstDayOfWeek(1);
		    resv_time.setBegRegisDate(null);
		    resv_time.setComment(comment);
		    resv_time.clearChkTime();
		    Vector chkTimeList = resv_time.getChkTimeList();
	        
		    rs = stmt.executeQuery("SELECT DAY(d_chckup) AS CHK_DAY, i_time FROM lan:serv_chkupdt WHERE i_month = '"+mnthDate+"' AND i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lock = '"+lockId+"' AND i_chkseq = "+seqNo);
	        if (rs != null) {
	        	if (rs.next() == true) {
	        		chkDay = doString.displayNumber("00", rs.getInt("CHK_DAY"));
	        		chkTime = doString.checkString(rs.getString("I_TIME"));
	        	}
	        	rs.close();
	        	rs=null;
	        }
	        rs = stmt.executeQuery("SELECT b_time FROM lan:serv_bctime WHERE i_brand = '"+brand+"' AND c_time = '"+chkTime+"'");
	        if (rs != null) {
	        	if (rs.next() == true) {
	        		chkTime = doString.checkString(rs.getString("B_TIME"));
	        	} else {
	        		chkTime = "";
	        	}
	        	rs.close();
	        	rs=null;
	        }
	        if (!chkDay.equals("") && !chkTime.equals("")) {
    			ChkTime aTime = new ChkTime();
    			aTime.setChkDate(chkDay);
    			aTime.setChkTime(chkTime);
    			chkTimeList.addElement(aTime);
	        }
	        
	        stmt.close();
	        conn.close();
	        stmt = null;
	        conn = null;
	        session.setAttribute("resv_time", resv_time);
	        res.sendRedirect(targetPage);
	    } catch (Exception e) {
	        System.out.println("ERROR /LHServ/InitSetLockServlet : " + e.getMessage());
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