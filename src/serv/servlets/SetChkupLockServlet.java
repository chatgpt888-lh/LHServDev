package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;

import com.lh.servlet.DBServlet;
import com.lh.util.LHMail;
import com.lh.util.doString;
import com.svc.call.ws.webservice.WebService;
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
 public class SetChkupLockServlet extends DBServlet {	 
	 private static String cName = "/LHServ/SetChkupLockServlet";
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
	    String userId = user.getUserID();
	    ResvTime resv_time = (ResvTime)session.getAttribute("resv_time");
	    if (resv_time == null) {
	        /*
		        * Redirect user to login page if
		        * there's no session.
		        */
		        res.sendRedirect("/LHServ/warning.htm");
		        return;	    	
	    }
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
		
	    String chkDate = "";
	    String brTime = "";
	    String ckTime = "";
	    String chkDay = "";
	    String chkMonth = resv_time.getChkMonth();
	    String chkYear = resv_time.getChkYear();
	    String mnthDate = Integer.parseInt(chkYear)-543+"-"+chkMonth+"-01";
	    String empId =resv_time.getEmpId();
	    String comId = resv_time.getComId();
	    String projId = resv_time.getProjId();
	    String lockId = resv_time.getLockId();
	    int seqNo = resv_time.getSeqNo();
	    String vendor = resv_time.getVendor();
	    String group = resv_time.getGroup();
	    Vector chkTimeList = resv_time.getChkTimeList();
	    String chkTime = doString.checkString(req.getParameter("chkTime"));
	    String comment = doString.UnicodeToMS874(req.getParameter("Comment"));
	    comment = doString.TextToString(comment);
		String custName="";
		String custTel="";	    
	    int idx=0;
	    if (chkTime.equals("")) {
		    if (chkTimeList != null) {
		    	for (int i=0; i<chkTimeList.size(); i++) {
		    		ChkTime aTime = (ChkTime)chkTimeList.elementAt(i);
		    		if (aTime != null) {
		    			chkDay = aTime.getChkDate();
		    			brTime = aTime.getChkTime();
		    		}
		    	}// end for
		    }	    	
	    } else {
    		idx = chkTime.indexOf("-");
    		if (idx > 0) {
    			chkDay = chkTime.substring(0, idx);
    			brTime = chkTime.substring(idx+1);
    		}
	    }
	    chkDate = Integer.parseInt(chkYear)-543+"-"+chkMonth+"-"+chkDay;	    
	    String brand = "";
	    
		//------ forward page --------//
		String savePage = Constants.SAVE_PAGE;
		String successPage = "InitChkLckServlet?Project="+comId+projId+"&chkMonth="+chkMonth+"&chkYear="+Integer.toString(Integer.parseInt(chkYear)-543);
		String errorPage = successPage + "&error=1"; 		
		String otherMsg = "";
		String errorCode = "";		    
	    int rowEffected = 0;
	    
	    doString str = new doString();
	    Calendar now = Calendar.getInstance(Locale.ENGLISH);
	    int year = (now).get(Calendar.YEAR);
		if (year<2400) year += 543;		
		String nowDate = Integer.toString(year>2400 ? year-543 : year);	
		nowDate += "-"+str.createID(now.get(Calendar.MONTH)+1,2);
		nowDate += "-"+str.createID(now.get(Calendar.DATE),2);		
		
		String nowDateWithTime = nowDate;
		nowDateWithTime += " "+str.createID(now.get(Calendar.HOUR_OF_DAY),2);
		nowDateWithTime += ":"+str.createID(now.get(Calendar.MINUTE),2);
		String dAppoint = nowDate;
		String dEstClose = nowDate;
		String twoDigitYear = Integer.toString(year).substring(2);
		String prefixDocNo = comId+"-"+projId+"-"+twoDigitYear;
	    String iDocNo = "";
	    String oldDocNo = "";
	    int lastId = 0;
	    String iTypeCut="";
	    SERV_CommonData common = null;
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
	        if (chkDay.equals("") || brTime.equals("")) {
	        	throw new Exception("โปรดระบุช่วงเวลา");
	        }
	    	rs = stmt.executeQuery("SELECT i_brand FROM lan:serv_brand WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
	    	if (rs != null) {
	    		if (rs.next() == true) {
	    			brand = doString.checkString(rs.getString(1));
	    		}
	    		rs.close();
	    		rs=null;
	    	}
	    	
	        oldDocNo = "";
	        iDocNo = "";
	        lastId = 0;
	        sql.delete(0,sql.length());
	        sql.append("SELECT i_docno FROM lan:serv_dochd WHERE ")
	        	.append(" i_company = '").append(comId).append("' ")
	        	.append(" AND i_project = '").append(projId).append("' ")
	        	.append(" AND i_docno LIKE '").append(prefixDocNo).append("%' ")
	        	.append(" ORDER BY i_docno DESC");
	        rs = stmt.executeQuery(sql.toString());								
	        if (rs.next() == true) {
	        	oldDocNo = doString.checkString(rs.getString("I_DOCNO"));
	        	lastId = Integer.parseInt(oldDocNo.substring(oldDocNo.length()-5));
	        	if (lastId<0) { 
	        		lastId = 1;
	        	} else {
	        		lastId++; 
	        	}
	        	iDocNo = prefixDocNo+str.createID(lastId,5);
	        } else {
	        	iDocNo = prefixDocNo+str.createID(1,5);
	        }
	        rs.close();
	        rs=null;
	    	
	        // ADD CALENDAR
	        LHMail MailLH = new LHMail();
	        GCalendarRS calRS = new GCalendarRS();
	        GCalendarRQ rq = new GCalendarRQ();
	        ckTime = "";
	        String frmTime = "";
	        String toTime = "";
	        String refId = "*";
	        rs = stmt.executeQuery("SELECT n_time FROM lan:serv_btime WHERE i_brand = '"+brand+"' AND i_time = '"+brTime+"'");
	        if (rs != null) {
	        	if (rs.next() == true) {
	        		ckTime = doString.checkString(rs.getString("N_TIME"));
	        	}
	        	rs.close();
	        	rs=null;
	        }
	        if (!ckTime.equals("")) {
	        	try {
		        	frmTime = ckTime.substring(0,5);
		        	toTime = ckTime.substring(8,13);
					rq.setCompanyId(comId);
					rq.setProjectId(projId);
					rq.setDocumentId(iDocNo); 
					rq.setLockNo(lockId);
					rq.setFromDate(chkDate);
					rq.setFromTime(frmTime);
					rq.setToDate(chkDate);
					rq.setToTime(toTime);
					rq.setAppName("CUP");
					rq.setChkseq(seqNo);
					rq.setVenderId(vendor);
					rq.setUserName(userId);
					calRS = (GCalendarRS)WebService.createCalendar(rq);
					if(calRS.getErrMsg()== null) {
						refId = calRS.getReferenceId();
					} else {
						refId = "*";
						MailLH.sendBBMail("132.146.1.12", "lh.co.th", "application", "arthit@lh.co.th", "", "Error Add Service Calendar", calRS.getErrMsg());
					}
	        	} catch (Exception e) {
	        		refId = "*";
	        		System.out.println("ERROR Add Calendar /LHServ/SetChkupLockServlet : " + e.getMessage());
	        		MailLH.sendBBMail("132.146.1.12", "lh.co.th", "application", "arthit@lh.co.th", "", "Error Add Service Calendar", e.getMessage());	        		
	        	}
	        }
	    	
	        //SERV_CHKUPLCK
			sql.delete(0,sql.length());
			sql.append("DELETE FROM lan:serv_chkuplck WHERE i_month = '")
				.append(mnthDate)
				.append("' AND i_company = '")
				.append(comId)
				.append("' AND i_project = '")
				.append(projId)
				.append("' AND i_lock = '")
				.append(lockId)
				.append("' AND i_chkseq = ")
				.append(Integer.toString(seqNo)+" AND f_status = 'R'");
			stmt.executeUpdate(sql.toString());
	        sql.delete(0,sql.length());
	        sql.append("INSERT INTO lan:serv_chkuplck(i_month, d_keyin, d_create, i_company, i_project, i_lock, i_chkseq, f_status, i_docno, i_reference, c_comment) VALUES('")
	        	.append(mnthDate)
	        	.append("', TODAY, CURRENT, '")
	        	.append(comId)
	        	.append("', '")
	        	.append(projId)
	        	.append("', '")
	        	.append(lockId)
	        	.append("', ")
	        	.append(Integer.toString(seqNo))
	        	.append(", 'R', '")
	        	.append(iDocNo)
	        	.append("', '")
	        	.append(refId)
	        	.append("', '")
	        	.append(comment+"')");
	        rowEffected = stmt.executeUpdate(sql.toString());
	        if (rowEffected != 1) {
	        	throw new Exception("SERV_CHKUPLCK : Wrong insert count");
	        }
	        
	        //SERV_CHKUPDT
	        int num_time = 0;
	        int num_rtime = 0; 
	        rs = stmt.executeQuery("SELECT COUNT(*) AS NUM_TIME FROM lan:serv_bctime WHERE i_brand = '"+brand+"' AND b_time = '"+brTime+"'");
	        if (rs != null) {
	        	if (rs.next() == true) {
	        		num_time = rs.getInt("NUM_TIME");
	        	}
	        	rs.close();
	        	rs=null;
	        }
			sql.delete(0,sql.length());
			sql.append("UPDATE lan:serv_chkupdt SET i_lock = NULL, i_chkseq = NULL, f_status = 'N' WHERE i_month = '")
				.append(mnthDate)
				.append("' AND i_company = '")
				.append(comId)
				.append("' AND i_project = '")
				.append(projId)
				.append("' AND i_lock = '")
				.append(lockId)
				.append("' AND i_chkseq = ")
				.append(Integer.toString(seqNo));
			cstmt.executeUpdate(sql.toString());
			
			rs = stmt.executeQuery("SELECT c_time FROM lan:serv_bctime WHERE i_brand = '"+brand+"' AND b_time = '"+brTime+"'");
			if (rs != null) {
				while (rs.next() == true) {
					ckTime = doString.checkString(rs.getString("C_TIME"));
					sql.delete(0,sql.length());
					sql.append("UPDATE lan:serv_chkupdt SET i_lock = '")
						.append(lockId)
						.append("', i_chkseq = ")
						.append(Integer.toString(seqNo))
						.append(", f_status = 'R' WHERE i_month = '")
						.append(mnthDate)
						.append("' AND i_employ = '")
						.append(empId)
						.append("' AND i_vendor = '")
						.append(vendor)
						.append("' AND i_group = '")
						.append(group)
						.append("' AND i_company = '")
						.append(comId)
						.append("' AND i_project = '")
						.append(projId)
						.append("' AND d_chckup = '")
						.append(chkDate)
						.append("' AND i_time = '")
						.append(ckTime+"'");
			        rowEffected = cstmt.executeUpdate(sql.toString());
			        if (rowEffected == 1) {
			        	num_rtime++;
			        } else {
			        	throw new Exception("SERV_CHKUPDT : Wrong update count");
			        }
				}// end while
				rs.close();
				rs=null;
			}
			if (num_time != num_rtime) {
				throw new Exception("ไม่พบข้อมูลช่วงเวลาที่จอง");
			}
			
			//SERV_DOCHD
			Hashtable tmpCust = common.getCustomerDetails(comId,projId,lockId,"");
			custName = doString.checkString((String) tmpCust.get("n_customer"));
			custTel = doString.checkString((String) tmpCust.get("n_cust_tel"));
	        nowDate = chkDate;
	        iTypeCut="";
	        String cDesc = "Checkup Program";
			sql.delete(0,sql.length());
			sql.append("SELECT d_effective, i_cut_type FROM lan:serv_cutlck WHERE ")
				  .append(" i_company = '").append(comId).append("' ")
				  .append(" AND i_project = '").append(projId).append("' ")
				  .append(" AND i_lock = '").append(lockId).append("' ")
				  .append(" AND d_effective <= '").append(nowDate).append("' ")
				  .append(" ORDER BY d_effective DESC");
			rs = stmt.executeQuery(sql.toString());				
			if (rs.next() == true) {
				iTypeCut = doString.checkString(rs.getString("I_CUT_TYPE"));
			}
			rs.close();
			rs=null;
			
			sql.delete(0,sql.length());
			sql.append("insert into lan:serv_dochd (i_docno , i_doc_type , i_company , ")
				  .append(" i_project , i_lock , d_keyin , n_customer , n_cus_tel , c_desc , ")
				  .append(" d_job , f_status , d_appoint , d_est_close , d_close , ")
				  .append(" i_service_employ , i_type_cutlck , d_print_inform , ")
				  .append(" i_employ_pinform , d_print_job , i_employ_pjob , f_reject , ")
				  .append(" i_employ_reject , d_reject , c_reject")
				  .append(" ) values ( ")
				  .append(" ? , 'I' , ? , ? , ? , today , ? , ? , ? , ")
				  .append(" null , 'OPN' , null , null , null , ") // Job Status & Date Details
				  .append(" ? , ? , ")
				  .append(" null , null , ")  // Print InformJob Description
				  .append(" null , null , ") // Print Job Description
				  .append(" 'N' , null , null , null ") // Reject Description
				  .append(" ) "); 					
				  
			//---====== User PrepareStatement instead becase cDesc is an more than 256 Chars ======-----//	  					  
		    pstmt = conn.prepareStatement(sql.toString());
		    pstmt.setString(1,iDocNo);
			pstmt.setString(2,comId);
			pstmt.setString(3,projId);
			pstmt.setString(4,lockId);
			pstmt.setString(5,custName);
			pstmt.setString(6,custTel);
			pstmt.setString(7,cDesc);
			pstmt.setString(8,user.getEmpId());
			pstmt.setString(9,iTypeCut);
			pstmt.executeUpdate();
			pstmt.close();
			
	        conn.commit();
	        stmt.close();
	        cstmt.close();
	        conn.close();
	        stmt = null;
	        cstmt = null;
	        pstmt=null;
	        conn = null;
	        genRedirectCode(out,savePage,successPage,errorCode,otherMsg);	        
	    } catch (Exception e) {
			try {
				if (conn != null)
					conn.rollback();
			} catch (Exception ignore) {}	    	
	        System.out.println("ERROR /LHServ/SetChkupLockServlet : " + e.getMessage());
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