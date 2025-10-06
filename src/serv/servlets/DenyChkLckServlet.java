package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;


import com.lh.servlet.DBServlet;
import com.lh.util.doString;

import serv.common.Constants;
import serv.common.User;
/**
 * Servlet implementation class for Servlet: SetChkupLockServlet
 *
 */
 public class DenyChkLckServlet extends DBServlet {	 
	 private static String cName = "/LHServ/DenyChkLckServlet";
		private void genRedirectCode(PrintWriter out,String page,String redirect,String error,String otherMsg) {
			out.println("<form method='post' action='"+page+"'>");		
			out.println("<input type='hidden' name='error' value='"+error+"'>");
			out.println("<input type='hidden' name='other_msg' value='"+doString.MS874ToUnicode(otherMsg)+"'>");
			out.println("<input type='hidden' name='redirect_url' value='"+doString.MS874ToUnicode(redirect)+"'>");		
			out.println("<script> document.forms[0].submit();</script>");
			out.println("</form>");		
		}	 
		public String getChkupDate(String closeDate, int liveTime) {
			int mnth = Integer.parseInt(closeDate.substring(5,7));
			int year = Integer.parseInt(closeDate.substring(0,4));
			for (int m=1; m<liveTime; m++) {
				mnth++;
				if (mnth == 13) {
					mnth = 1;
					year++;
				}			
			}// end for
			String endDate = Integer.toString(year)+"-"+doString.displayNumber("00", mnth)+"-01";
			return endDate;
		}		
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
	    User user = (User)obj;
	    
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
		
	    String comId = doString.checkString(req.getParameter("comId"));
	    String projId = doString.checkString(req.getParameter("projId"));
	    String lockId = doString.checkString(req.getParameter("lockId"));
	    lockId = lockId.toUpperCase();
	    String chkNo = doString.checkString(req.getParameter("chkNo"),"0");
	    String cause = doString.checkString(req.getParameter("Cause"));
	    String closeDate = "";
	    String mnthDate = "";
	    java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyy-MM-dd", Locale.US);
	    String mnth = "";
	    String year = "";
	    String chkDate = "";
	    String denyDate = "";
		//------ forward page --------//
		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_DenLckLst.jsp?Project="+comId+projId;
		String errorPage = successPage + "&error=1"; 		
		String otherMsg = "";
		String errorCode = "";		    
	    int rowEffected = 0;
	    boolean chckup = true;
	    Connection conn = null;
	    Statement stmt = null;
	    Statement cstmt = null;
	    ResultSet rs = null;
	    try {
	        if (ds == null)
	            getDS();
	        conn = ds.getConnection();
	        conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	        conn.setAutoCommit(false);
	        stmt = conn.createStatement();
	        cstmt = conn.createStatement();
//System.out.println( formatter.parse("2010-01-01").after(formatter.parse("2010-01-01")) );	        
	        rs = stmt.executeQuery("SELECT d_close_law FROM lan:acscontr WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_sort = '"+lockId+"' AND f_contr IS NULL AND d_close_law IS NOT NULL");
	        if (rs != null) {
	        	if (rs.next() == true) {
	        		closeDate = doString.checkString(rs.getString("D_CLOSE_LAW"));
	        	} else {
	        		throw new Exception("ไม่พบข้อมูลแปลง : "+lockId);
	        	}
	        	rs.close();
	        	rs=null;
	        }
	        
	        chckup = false;
	        rs = stmt.executeQuery("SELECT i_lock FROM lan:serv_chkuplck WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lock = '"+lockId+"' AND i_chkseq = "+chkNo+" AND f_status != 'D'");
	        if (rs != null) {
	        	if (rs.next() == true) {
	        		chckup = true;
	        	}
	        	rs.close();
	        	rs=null;
	        }
	        if (chckup) {
	        	throw new Exception("แปลง : "+lockId+" ได้ทำ Check up ไปแล้วไม่สามารถสละสิทธิได้");
	        }
	        
	        mnthDate = "";
	        rs = stmt.executeQuery("SELECT i_year, i_month FROM lan:serv_chkmain WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' ORDER BY i_year DESC, i_month DESC");                                    
			if (rs != null) {
				if (rs.next() == true) {
					mnth = doString.checkString(rs.getString("I_MONTH"));
					year = Integer.toString(Integer.parseInt(rs.getString("I_YEAR"))-543);
					mnthDate = year+"-"+mnth+"-01";
				}
				rs.close();
				rs=null;
			}

	        if (mnthDate.equals("")) {
	        	if (chkNo.equals("1")) {
	        		denyDate = getChkupDate(closeDate, 5);
	        	}
	        	if (chkNo.equals("2")) {
	        		denyDate = getChkupDate(closeDate, 11);
	        	}
	        } else {
	        	//Checkup 1
	        	if (chkNo.equals("1")) {
			        for (int i=5; i<=7; i++) {
				        chkDate = getChkupDate(closeDate, i);
				        if (formatter.parse(chkDate).after(formatter.parse(mnthDate))) {
				        	denyDate = chkDate;
				        	break;
				        }
			        }// end for
	        	}
	        	
		        //Checkup 2
	        	if (chkNo.equals("2")) {
			        for (int i=11; i<=13; i++) {
				        chkDate = getChkupDate(closeDate, i);
				        if (formatter.parse(chkDate).after(formatter.parse(mnthDate))) {
				        	denyDate = chkDate;
				        	break;
				        }
			        }// end for
		        }
	        }
	        if (!denyDate.equals("")) {	
		        rowEffected = stmt.executeUpdate("INSERT INTO lan:serv_denchkup(i_company, i_project, i_lock, i_chkseq, i_month, i_cause, d_deny) VALUES('"+comId+"', '"+projId+"', '"+lockId+"', "+chkNo+", '"+denyDate+"', '"+cause+"', TODAY)");
			    if (rowEffected != 1) {
			       	throw new Exception("SERV_DENCHKUP : Wrong Insert Count");
			    }
	        } else {
	        	throw new Exception("แปลง : "+lockId+" หมดสิทธิการทำ Check up ไปแล้ว");
	        }
	        
	        conn.commit();
	        stmt.close();
	        cstmt.close();
	        conn.close();
	        stmt = null;
	        cstmt = null;
	        conn = null;
	        genRedirectCode(out,savePage,successPage,errorCode,otherMsg);	        
	    } catch (Exception e) {
			try {
				if (conn != null)
					conn.rollback();
			} catch (Exception ignore) {}	    	
	        System.out.println("ERROR /LHServ/DenyChkLckServlet : " + e.getMessage());
	        genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ "+e.getMessage());
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
	        if (cstmt != null) {
	            try {
	                cstmt.close();
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