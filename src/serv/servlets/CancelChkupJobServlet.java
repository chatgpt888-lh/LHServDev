package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;


import com.lh.servlet.DBServlet;
import com.lh.util.LHMail;
import com.lh.util.doString;

import serv.common.Constants;
import serv.common.SERV_CommonData;
import serv.common.User;
import serv.common.ResvTime;
import serv.common.ChkTime;
import serv.common.Constants;

import com.svc.call.ws.webservice.WebService;
import com.svc.ws.model.GCalendarRQ;
import com.svc.ws.model.GCalendarRS;
/**
 * Servlet implementation class for Servlet: SetChkupLockServlet
 *
 */
 public class CancelChkupJobServlet extends DBServlet {	 
	 private static String cName = "/LHServ/CancelChkupJobServlet";
		private void genRedirectCode(PrintWriter out,String page,String redirect,String error,String otherMsg) {
			out.println("<form method='post' action='"+page+"'>");		
			out.println("<input type='hidden' name='error' value='"+error+"'>");
			out.println("<input type='hidden' name='other_msg' value='"+doString.MS874ToUnicode(otherMsg)+"'>");
			out.println("<input type='hidden' name='redirect_url' value='"+doString.MS874ToUnicode(redirect)+"'>");		
			out.println("<script> document.forms[0].submit();</script>");
			out.println("</form>");		
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
		
	    String project = doString.checkString(req.getParameter("Project"));
	    String comId = "";
	    String projId = "";
	    if (!project.equals("")) {
		    comId = project.substring(0, 2);
		    projId = project.substring(2);
	    }	    
	    String brand = "";
	    String refId = "";
	    String chk_lock[] = req.getParameterValues("chkLock");
	    String lockId = "";
	    String seqNo = "";
	    String status = "";
	    String iDocNo = "";
	    String cancelId = "";
	    String chkDate = "";
	    String chkTime = "";
	    String frmTime = "";
	    String toTime = "";
	    SERV_CommonData common = null;
		//------ forward page --------//
		String savePage = Constants.SAVE_PAGE;
		String successPage = "InitOpenChkupServlet?Project="+comId+projId;
		String errorPage = successPage + "&error=1"; 		
		String otherMsg = "";
		String errorCode = "";		    
	    int rowEffected = 0;
	    StringBuffer sql = new StringBuffer();
	    Connection conn = null;
	    Statement stmt = null;
	    Statement cstmt = null;
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    ResultSet rsChkup = null;
	    try {
	        if (ds == null)
	            getDS();
	        conn = ds.getConnection();
	        conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	        conn.setAutoCommit(false);
	        stmt = conn.createStatement();
	        cstmt = conn.createStatement();
	        
	        common = new SERV_CommonData(conn);
	    	String begDate = common.getValueFromDateListbox("start",req);
	    	String endDate = common.getValueFromDateListbox("end",req);
	    	String start_date = "";
	    	String start_month = "";
	    	String start_year = "";
	    	String end_date = "";
	    	String end_month = "";
	    	String end_year = "";
	    	String transDate = "";
	    	if (!begDate.equals("")) {
	    		start_year = begDate.substring(0,4);
	    		start_month = begDate.substring(5,7);
	    		start_date = begDate.substring(8);
	    	}
	    	if (!endDate.equals("")) {
	    		end_year = endDate.substring(0,4);
	    		end_month = endDate.substring(5,7);
	    		end_date = endDate.substring(8);
	    	}
	    	String params = "&start_date="+start_date+"&start_month="+start_month+"&start_year="+start_year+"&end_date="+end_date+"&end_month="+end_month+"&end_year="+end_year;
	    	successPage = successPage + params;
	    	errorPage = successPage + "&error=1";
	    	
	    	
	        LHMail MailLH = new LHMail();
	        GCalendarRS calRS = new GCalendarRS();
	        GCalendarRQ rq = new GCalendarRQ();
	        
	    	if (chk_lock != null) {
	    		for (int i=0; i<chk_lock.length; i++) {
	    			lockId = doString.checkString(chk_lock[i]);
	    			cancelId = doString.checkString(req.getParameter("C"+lockId));
	    			if (cancelId.equals("")) {
	    				throw new Exception("Cancel is null");
	    			}
	    			
	    			comId = doString.checkString(lockId.substring(0,2));
	    			projId = doString.checkString(lockId.substring(2,5));
	    			brand = "";
	    	    	rs = stmt.executeQuery("SELECT i_brand FROM lan:serv_brand WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
	    	    	if (rs != null) {
	    	    		if (rs.next() == true) {
	    	    			brand = doString.checkString(rs.getString(1));
	    	    		}
	    	    		rs.close();
	    	    		rs=null;
	    	    	}	    			
	    			seqNo = doString.checkString(lockId.substring(10), "0");
	    			lockId = doString.checkString(lockId.substring(5,10));
	    			
	    			if (!lockId.equals("") && !seqNo.equals("0")) {
	    				iDocNo = "";
	    				status = "";
	    				transDate = "";
	    				refId = "*";
		    			sql.delete(0,sql.length());
		    			sql.append("SELECT i_docno, f_status, d_keyin, i_reference FROM lan:serv_chkuplck WHERE i_company = '")
		    				.append(comId)
		    				.append("' AND i_project = '")
		    				.append(projId)
		    				.append("' AND i_lock = '")
		    				.append(lockId)
		    				.append("' AND i_chkseq = ")
		    				.append(seqNo+" AND f_status != 'D'");
		    			rsChkup = cstmt.executeQuery(sql.toString());
		    			if (rsChkup != null) {
		    				if (rsChkup.next() == true) {
		    					iDocNo = doString.checkString(rsChkup.getString("I_DOCNO"));
		    					status = doString.checkString(rsChkup.getString("F_STATUS"));
		    					transDate = doString.checkString(rsChkup.getString("D_KEYIN"));
		    					refId = doString.checkString(rsChkup.getString("I_REFERENCE"));
		    				}
		    				rsChkup.close();
		    				rsChkup=null;
		    			}
		    			if (!status.equals("") && !status.equals("C")) {
		    				//SERV_CHKUPLCK
			    			sql.delete(0,sql.length());
			    			sql.append("UPDATE lan:serv_chkuplck SET i_docno = NULL, f_status = 'D', i_cancel = '"+cancelId+"', d_cancel = TODAY WHERE i_company = '")
			    				.append(comId)
			    				.append("' AND i_project = '")
			    				.append(projId)
			    				.append("' AND i_lock = '")
			    				.append(lockId)
			    				.append("' AND i_chkseq = ")
			    				.append(seqNo+" AND f_status != 'D'");	    				
			    			rowEffected = stmt.executeUpdate(sql.toString());
					        if (rowEffected <= 0) {
					        	throw new Exception("SERV_CHKUPLCK : Wrong update count");
					        }
					        
					        // DELETE CALENDAR
						    chkTime = "";
						    frmTime = "";
						    toTime = "";		
						    chkDate = "";
			    			sql.delete(0,sql.length());
			    			sql.append("SELECT d_chckup FROM lan:serv_chkupdt WHERE i_company = '")
			    				.append(comId)
			    				.append("' AND i_project = '")
			    				.append(projId)
			    				.append("' AND i_lock = '")
			    				.append(lockId)
			    				.append("' AND i_chkseq = ")
			    				.append(seqNo);
					        rsChkup = cstmt.executeQuery(sql.toString());
					        if (rsChkup != null) {
					        	if (rsChkup.next() == true) {
					        		chkDate = doString.checkString(rsChkup.getString("D_CHCKUP"));
					        	}
					        	rsChkup.close();
					        	rsChkup=null;						        	
					        }
			    			sql.delete(0,sql.length());
			    			sql.append("SELECT DISTINCT t.b_time FROM lan:serv_chkupdt d, lan:serv_bctime t WHERE d.i_company = '")
			    				.append(comId)
			    				.append("' AND d.i_project = '")
			    				.append(projId)
			    				.append("' AND d.i_lock = '")
			    				.append(lockId)
			    				.append("' AND d.i_chkseq = ")
			    				.append(seqNo)
			    				.append(" AND d.i_time = t.c_time AND t.i_brand = '")
			    				.append(brand+"'");
					        rsChkup = cstmt.executeQuery(sql.toString());
					        if (rsChkup != null) {
					        	if (rsChkup.next() == true) {
					        		chkTime = doString.checkString(rsChkup.getString("B_TIME"));
					        	}
					        	rsChkup.close();
					        	rsChkup=null;					        	
					        }
					        rsChkup = cstmt.executeQuery("SELECT n_time FROM lan:serv_btime WHERE i_brand = '"+brand+"' AND i_time = '"+chkTime+"'");
					        if (rsChkup != null) {
					        	if (rsChkup.next() == true) {
					        		chkTime = doString.checkString(rsChkup.getString("N_TIME"));
						        	frmTime = chkTime.substring(0,5);
						        	toTime = chkTime.substring(8,13);					        		
					        	}
					        	rsChkup.close();
					        	rsChkup=null;					        	
					        }
					        if (!refId.equals("*")) {
					        	try {
									rq.setAppName("CUP");
									rq.setReferenceId(refId);
									rq.setDocumentId(iDocNo);
									rq.setCompanyId(comId);
									rq.setProjectId(projId);
									rq.setFromDate(chkDate);
									rq.setFromTime(frmTime);
									rq.setToDate(chkDate);
									rq.setToTime(toTime);
									
									calRS = (GCalendarRS)WebService.dropCalendar(rq);
									if(calRS.getErrMsg()!=null) {
										if (calRS.isError()) {
											MailLH.sendBBMail("132.146.1.12", "lh.co.th", "application", "arthit@lh.co.th", "pradoem@lh.co.th", "Error Delete Service Calendar : "+comId+projId+":"+iDocNo+":"+chkDate+":"+frmTime+":"+toTime, calRS.getErrMsg());
										}
									}
					        	} catch (Exception e) {
					        		System.out.println("ERROR Delete Calendar /LHServ/CancelChkupJobServlet : " + e.getMessage());
					        		MailLH.sendBBMail("132.146.1.12", "lh.co.th", "application", "arthit@lh.co.th", "pradoem@lh.co.th", "Error Delete Service Calendar", e.getMessage());	        		
					        	}
					        }
					        
					        //SERV_CANCHKUP
			    			sql.delete(0,sql.length());
			    			sql.append("SELECT * FROM lan:serv_chkupdt WHERE i_company = '")
			    				.append(comId)
			    				.append("' AND i_project = '")
			    				.append(projId)
			    				.append("' AND i_lock = '")
			    				.append(lockId)
			    				.append("' AND i_chkseq = ")
			    				.append(seqNo);
					        rsChkup = cstmt.executeQuery(sql.toString());
					        if (rsChkup != null) {
					        	while (rsChkup.next() == true) {
									sql.delete(0,sql.length());
							        sql.append("INSERT INTO lan:serv_canchkup(i_chkupno, i_month, i_employ, i_vendor, i_group, i_company, i_project, i_lock, i_chkseq, d_chckup, i_time) VALUES('")
							        	.append(doString.checkString(rsChkup.getString("I_CHKUPNO")))
							        	.append("', '")
							        	.append(doString.checkString(rsChkup.getString("I_MONTH")))
							        	.append("', '")
							        	.append(doString.checkString(rsChkup.getString("I_EMPLOY")))
							        	.append("', '")
							        	.append(doString.checkString(rsChkup.getString("I_VENDOR")))
							        	.append("', '")
							        	.append(doString.checkString(rsChkup.getString("I_GROUP")))
							        	.append("', '")
							        	.append(doString.checkString(rsChkup.getString("I_COMPANY")))
							        	.append("', '")
							        	.append(doString.checkString(rsChkup.getString("I_PROJECT")))
							        	.append("', '")
							        	.append(doString.checkString(rsChkup.getString("I_LOCK")))
							        	.append("', ")
							        	.append(Integer.toString(rsChkup.getInt("I_CHKSEQ")))
							        	.append(", '")
							        	.append(doString.checkString(rsChkup.getString("D_CHCKUP")))
							        	.append("', '")
							        	.append(doString.checkString(rsChkup.getString("I_TIME")))
							        	.append("')");
							        stmt.executeUpdate(sql.toString());					        		
					        	}// end while
					        	rsChkup.close();
					        	rsChkup=null;
					        }
					        
					        //SERV_CHKUPDT
			    			sql.delete(0,sql.length());
			    			sql.append("UPDATE lan:serv_chkupdt SET i_lock = NULL, i_chkseq = NULL, f_status = 'N' WHERE i_company = '")
			    				.append(comId)
			    				.append("' AND i_project = '")
			    				.append(projId)
			    				.append("' AND i_lock = '")
			    				.append(lockId)
			    				.append("' AND i_chkseq = ")
			    				.append(seqNo);	    				
			    			rowEffected = stmt.executeUpdate(sql.toString());
					        if (rowEffected <= 0) {
					        	throw new Exception("SERV_CHKUPDT : Wrong update count");
					        }
					        
					        //SERV_DOCHD
					        sql.delete(0,sql.length());
					        sql.append("UPDATE lan:serv_dochd SET ")
						        .append(" f_status = 'CAN' , ")
						        .append(" d_cancel = TODAY , ")
						        .append(" i_employ_cancel = '").append(user.getEmpId()).append("' ")
						        .append(" WHERE i_docno = '").append(iDocNo).append("' ");
					        stmt.executeUpdate(sql.toString());					        
		    			}// Not Open Job
	    			}
	    		}// end for
	    	}
	    	
	        conn.commit();
	        stmt.close();
	        cstmt.close();
	        conn.close();
	        stmt = null;
	        cstmt = null;
	        pstmt = null;
	        conn = null;
	        genRedirectCode(out,savePage,successPage,errorCode,otherMsg);	        
	    } catch (Exception e) {
			try {
				if (conn != null)
					conn.rollback();
			} catch (Exception ignore) {}	    	
	        System.out.println("ERROR /LHServ/CancelChkupJobServlet : " + e.getMessage());
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
	        if (pstmt != null) {
	            try {
	                pstmt.close();
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