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
import serv.common.ResvTime;
import serv.common.ChkTime;
import serv.common.BetweenDate;
import serv.common.SERV_CommonData;
/**
 * Servlet implementation class for Servlet: InitResvTimeServlet
 *
 */
 public class InitOpenChkupServlet extends DBServlet {	 
	 private static String cName = "/LHServ/InitOpenChkupServlet";
		private void genRedirectCode(PrintWriter out,String page,String redirect,String error,String otherMsg) {
			out.println("<form method='post' action='"+page+"'>");		
			out.println("<input type='hidden' name='error' value='"+error+"'>");
			out.println("<input type='hidden' name='other_msg' value='"+doString.MS874ToUnicode(otherMsg)+"'>");
			out.println("<input type='hidden' name='redirect_url' value='"+doString.MS874ToUnicode(redirect)+"'>");		
			out.println("<script> document.forms[0].submit();</script>");
			out.println("</form>");		
		}	 
	public BetweenDate getBetweenDate(int mnth, int year, int bckMnth) {
		for (int m=1; m<bckMnth; m++) {
			mnth--;
			if (mnth == 0) {
				mnth = 12;
				year--;
			}			
		}// end for
		java.util.Calendar currentCal = java.util.Calendar.getInstance(Locale.ENGLISH);
		currentCal = new GregorianCalendar(year, mnth-1, 1);
		int daysInMonth = currentCal.getActualMaximum(currentCal.DAY_OF_MONTH);		
		String begDate = Integer.toString(year)+"-"+doString.displayNumber("00", mnth)+"-01";
		String endDate = Integer.toString(year)+"-"+doString.displayNumber("00", mnth)+"-"+doString.displayNumber("00", daysInMonth);
		
		
		BetweenDate betweenDate = new BetweenDate(begDate, endDate);
		return betweenDate;
	}		
	public String getStatus(String status) {
		if (status.equals("N")) {
			status = "รอบันทึกนัด";
		}
		if (status.equals("D")) {
			status = "ยกเลิกนัด";
		}
		if (status.equals("R")) {
			status = "บันทึกนัดแล้ว";
		}
		if (status.equals("O")) {
			status = "Open Job";
		}
		if (status.equals("S")) {
			status = "Start Task";
		}
		
		if (status.equals("C")) {
			status = "Complete Task";
		}
		return status;		
	}	

	public String getSeqStatus(String status) {
		int seqNo=0;
		if (status.equals("N")) {
			seqNo = 1;
		}
		if (status.equals("D")) {
			seqNo = 3;
		}
		if (status.equals("R")) {
			seqNo = 2;
		}
		if (status.equals("O")) {
			seqNo = 4;
		}
		if (status.equals("O")) {
			seqNo = 5;
		}		
		if (status.equals("C")) {
			seqNo = 6;
		}
		return Integer.toString(seqNo);		
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
	    String userId = user.getUserID();
		String empId = user.getEmpId();
		String sessionId = user.getsessionId();
		String brand = "";
	    String project = doString.checkString(req.getParameter("Project"));
	    String comId = "";
	    String projId = "";
	    if (!project.equals("")) {
		    comId = project.substring(0, 2);
		    projId = project.substring(2);
	    }
	    String mnthDate = "";	    
	    String chkDate = "";
	    String docNo = "";
	    String venId = "";
	    String venName = "";
	    String lockId="";
	    int seqNo=0;
		String houseId="";
		String custName="";
		String custTel="";
		String closeDate="";
		String status = "";
		String chkDay = "";
		String chkTime = "";
		String comment = "";
		//------ forward page --------//
		String savePage = Constants.SAVE_PAGE;
		String targetPage = "SERV_OpenChkUp.jsp";
		String errorPage = ""; 		
		String otherMsg = "";
		String errorCode = "";
		StringBuffer sql = new StringBuffer();
	    Connection conn = null;
	    Statement stmt = null;
	    Statement ustmt = null;
	    Statement cstmt = null;
	    ResultSet rs =null;
	    ResultSet rsChkup =null;
	    ResultSet rsTime =null;
	    SERV_CommonData common = null;
	    try {
	        if (ds == null)
	            getDS();
	        conn = ds.getConnection();
	        conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	        conn.setAutoCommit(true);
	        stmt = conn.createStatement();
	        ustmt = conn.createStatement();
	        cstmt = conn.createStatement();
	        common = new SERV_CommonData(conn);
	    	String begDate = common.getValueFromDateListbox("start",req);
	    	String endDate = common.getValueFromDateListbox("end",req);
	    	
	    	
	    	
	    	
	    	stmt.executeUpdate("DELETE FROM lan:serv_chklock WHERE i_session = "+sessionId);
	    	
	    	
			//rsChkup = ustmt.executeQuery("SELECT DISTINCT i_lock, i_chkseq, i_month FROM lan:serv_chkupdt WHERE i_employ = '"+empId+"' AND i_company = '"+comId+"' AND i_project = '"+projId+"' AND d_chckup >= '"+begDate+"' AND d_chckup <= '"+endDate+"' AND i_chkseq > 0");
	    	String from = "lan:serv_chkupdt c";
	    	String where = "";
	    	if (projId.equals("ALL")) {
	    		from += ", lan:serv_pstaff s";	    		
	    		where = "s.user_id = '"+userId+"' AND s.com_id = c.i_company AND s.proj_id = c.i_project";	    		
	    	} else {
	    		where = "c.i_company = '"+comId+"' AND c.i_project = '"+projId+"'";	    		
	    	}
			rsChkup = ustmt.executeQuery("SELECT DISTINCT c.i_company, c.i_project, c.i_lock, c.i_chkseq, c.i_month FROM "+from+" WHERE "+where+" AND c.d_chckup >= '"+begDate+"' AND c.d_chckup <= '"+endDate+"' AND c.i_chkseq > 0");			
			if (rsChkup != null) {
				while (rsChkup.next() == true) {
					comId = doString.checkString(rsChkup.getString("I_COMPANY"));
					projId = doString.checkString(rsChkup.getString("I_PROJECT"));
			    	rs = stmt.executeQuery("SELECT i_brand FROM lan:serv_brand WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
			    	if (rs != null) {
			    		if (rs.next() == true) {
			    			brand = doString.checkString(rs.getString(1));
			    		}
			    		rs.close();
			    		rs=null;
			    	}		    	
					
					lockId = doString.checkString(rsChkup.getString("I_LOCK"));
					seqNo = rsChkup.getInt("I_CHKSEQ");
					mnthDate = doString.checkString(rsChkup.getString("I_MONTH"));
					Hashtable tmpCust = common.getCustomerDetails(comId,projId,lockId,"");
				    houseId = doString.checkString((String) tmpCust.get("i_house"));
					custName = doString.checkString((String) tmpCust.get("n_customer"));
					custTel = doString.checkString((String) tmpCust.get("n_cust_tel"));
					closeDate = doString.checkString((String) tmpCust.get("close_date"));
					
					docNo = "";
					status = "";
					venId = "";
					venName = "";
					comment = "";
					rs = stmt.executeQuery("SELECT i_docno, i_vendor, f_status, c_comment FROM lan:serv_chkuplck WHERE i_month = '"+mnthDate+"' AND i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lock = '"+lockId+"' AND i_chkseq = "+Integer.toString(seqNo)+" AND f_status != 'D'");
					if (rs != null) {
						if (rs.next() == true) {
							docNo = doString.checkString(rs.getString("I_DOCNO"));
							status = doString.checkString(rs.getString("F_STATUS"));
							venId = doString.checkString(rs.getString("I_VENDOR"));
							comment = doString.checkString(rs.getString("C_COMMENT"));
						}
						rs.close();
						rs=null;
					}
					rs = stmt.executeQuery("SELECT bus_name FROM lan:stpvendr WHERE vend_code = '"+venId+"'");
					if (rs != null) {
						if (rs.next() == true) {
							venName = doString.checkString(rs.getString("BUS_NAME"));
						}
						rs.close();
						rs=null;
					}
					
					
					chkDay = "-";
					chkTime = "-";
					chkDate = "";
					rsTime = cstmt.executeQuery("SELECT d_chckup, DAY(d_chckup) AS CHK_DAY, i_time FROM lan:serv_chkupdt WHERE i_month = '"+mnthDate+"' AND i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lock = '"+lockId+"' AND i_chkseq = "+Integer.toString(seqNo));
					if (rsTime != null) {
						if (rsTime.next() == true) {
							chkDay = doString.displayNumber("00", rsTime.getInt("CHK_DAY"));
							chkTime = doString.checkString(rsTime.getString("I_TIME"));
							chkDate = doString.checkString(rsTime.getString("D_CHCKUP"));
						}
						rsTime.close();
						rsTime=null;
					}
					rsTime = cstmt.executeQuery("SELECT b_time FROM lan:serv_bctime WHERE i_brand = '"+brand+"' AND c_time = '"+chkTime+"'");
					if (rsTime != null) {
						if (rsTime.next() == true) {
							chkTime = doString.checkString(rsTime.getString("B_TIME"));
						} else {
							chkTime = "-";
						}
						rsTime.close();
						rsTime=null;
					}
					sql.delete(0,sql.length());
			        sql.append("INSERT INTO lan:serv_chklock(i_session, user_id, i_docno, ven_name, i_company, i_project, i_lock, i_chkseq, i_status, f_status, n_status, i_house, n_name, i_tel, d_close_law, i_day, i_time, c_comment, d_chckup) VALUES(")
			        	.append(sessionId)
			        	.append(", '")
			        	.append(userId)
			        	.append("', '")
			        	.append(docNo)
			        	.append("', '")
			        	.append(venName)
			        	.append("', '")
			        	.append(comId)
			        	.append("', '")
			        	.append(projId)
			        	.append("', '")
			        	.append(lockId)
			        	.append("', ")
			        	.append(seqNo)
			        	.append(", ")
			        	.append(getSeqStatus(status))
			        	.append(", '")							        	
			        	.append(status)
			        	.append("', '")
			        	.append(doString.UnicodeToMS874(getStatus(status)))							        	
			        	.append("', '")
			        	.append(houseId)
			        	.append("', '")
			        	.append(custName)
			        	.append("', '")
			        	.append(custTel)
			        	.append("', '")
			        	.append(closeDate)
			        	.append("', '")
			        	.append(chkDay)
			        	.append("', '")
			        	.append(chkTime)
			        	.append("', '")
			        	.append(comment)
			        	.append("', '")			        	
			        	.append(chkDate+"')");
			        cstmt.executeUpdate(sql.toString());							
				}// end while
				rsChkup.close();
				rsChkup=null;
			}
					
	        stmt.close();
	        ustmt.close();
	        cstmt.close();
	        conn.close();
	        stmt = null;
	        ustmt = null;
	        cstmt = null;
	        conn = null;
			ServletContext sc = getServletContext();
			RequestDispatcher rd = sc.getRequestDispatcher("/" + targetPage);
			rd.forward(req, res);
	    } catch (Exception e) {
	        System.out.println("ERROR /LHServ/InitOpenChkupServlet : " + e.getMessage());
	    } finally {
	        if (stmt != null) {
	            try {
	                stmt.close();
	            } catch (SQLException ignore) {
	            }
	        }
	        if (ustmt != null) {
	            try {
	                ustmt.close();
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