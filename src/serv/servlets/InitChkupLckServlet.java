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
 public class InitChkupLckServlet extends DBServlet {	 
	 private static String cName = "/LHServ/InitChkupLckServlet";
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
	public static String getExpireDate(String closeDate, int liveTime) {
		int mnth = Integer.parseInt(closeDate.substring(5,7));
		int year = Integer.parseInt(closeDate.substring(0,4));
		liveTime += 1;
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
			status = "Complete Job";
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
		if (status.equals("S")) {
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
	    String sessionId = user.getsessionId();
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
		String brand = "";
		String proj = "";
	    String comId = "";
	    String projId = "";
	    String[] projList = req.getParameterValues("sel_proj");
	    Vector proj_list = new Vector(5);
	    
	    String type = doString.checkString(req.getParameter("type"));
	    String chkMonth = doString.checkString(req.getParameter("chkMonth"));
	    String chkYear = doString.checkString(req.getParameter("chkYear"));
	    String chkDate = "";
	    if (!chkYear.equals("")) {
	    	chkDate = chkYear+"-"+chkMonth+"-01";
	    }
	    int seqNo = Integer.parseInt(doString.checkString(req.getParameter("seqNo"),"0"));
	    
	    java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyy-MM-dd", Locale.US);	
	    String mnthDate="";
	    int mnth=0;
	    int year=0;
	    String lockId="";
		String houseId="";
		String custName="";
		String custTel="";
		String closeDate="";
		String expireDate="";
		String cancelDate="";
		String venId = "";
		String venName = "";
		String docNo = "";
		String code = "";
		String status = "";
		String chkDay = "";
		String chkTime = "";
		String comment = "";
		//------ forward page --------//
		String savePage = Constants.SAVE_PAGE;
		String targetPage = "";
		targetPage = "type="+type+"&chkMonth="+chkMonth+"&chkYear="+chkYear+"&seqNo="+seqNo;		
		String errorPage = ""; 		
		String otherMsg = "";
		String errorCode = "";
		int[] bckMnth = new int[2];
		boolean chckup = false;
		boolean deny = false;
		boolean insert = false;
		boolean flood = false;
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
	    	rs = stmt.executeQuery("SELECT p_amount FROM lan:serv_xstd WHERE i_type = '65' AND i_code = '01'");
	    	if (rs != null) {
	    		if (rs.next() == true) {
	    			bckMnth[0] = rs.getInt("P_AMOUNT");
	    		}
	    		rs.close();
	    		rs=null;
	    	}
	    	rs = stmt.executeQuery("SELECT p_amount FROM lan:serv_xstd WHERE i_type = '66' AND i_code = '01'");
	    	if (rs != null) {
	    		if (rs.next() == true) {
	    			bckMnth[1] = rs.getInt("P_AMOUNT");
	    		}
	    		rs.close();
	    		rs=null;
	    	}
	        
	    	BetweenDate betweenDate = null;
	    	String begDate = "";
	    	String endDate = "";	
	    	int curMnth = Integer.parseInt(chkMonth);
	    	int curYear = Integer.parseInt(chkYear);
	    	int s = seqNo;
	    	
	    	if (type.equals("01")) { //Before
	    		targetPage = "SERV_ChkLckRpt1.jsp?"+targetPage;
				betweenDate = getBetweenDate(curMnth, curYear, bckMnth[s-1]);
				begDate = betweenDate.getBegDate();
				year = Integer.parseInt(begDate.substring(0, 4));
				mnth = Integer.parseInt(begDate.substring(5, 7));
/*				
				betweenDate = getBetweenDate(mnth, year, 2);
				endDate = betweenDate.getEndDate();
				betweenDate = getBetweenDate(mnth, year, 3);
				begDate = betweenDate.getBegDate();
*/
				betweenDate = getBetweenDate(mnth, year, 2);
				begDate = betweenDate.getBegDate();
				endDate = betweenDate.getEndDate();
	    	} else if (type.equals("02")) { //Transfer
	    		targetPage = "SERV_ChkLckRpt1.jsp?"+targetPage;
				betweenDate = getBetweenDate(curMnth, curYear, bckMnth[s-1]);
				begDate = betweenDate.getBegDate();
				endDate = betweenDate.getEndDate();
	    	} else {
/*	    		
				betweenDate = getBetweenDate(curMnth, curYear, bckMnth[s-1]+2);
				begDate = betweenDate.getBegDate();
				betweenDate = getBetweenDate(curMnth, curYear, bckMnth[s-1]);
				endDate = betweenDate.getEndDate();
*/				
				betweenDate = getBetweenDate(curMnth, curYear, bckMnth[s-1]+1);
				begDate = betweenDate.getBegDate();
				betweenDate = getBetweenDate(curMnth, curYear, bckMnth[s-1]);
				endDate = betweenDate.getEndDate();
				
				if (type.equals("03")) {
					targetPage = "SERV_ChkLckRpt2.jsp?"+targetPage;
				}
				if (type.equals("04") || type.equals("07")) {
					targetPage = "SERV_ChkLckRpt3.jsp?"+targetPage;
				}
				if (type.equals("05")) {
					targetPage = "SERV_ChkLckRpt1.jsp?"+targetPage;
				}
				if (type.equals("06")) {
					targetPage = "SERV_ChkLckRpt1.jsp?"+targetPage;
				}
				
	    	}
	        stmt.executeUpdate("DELETE FROM lan:serv_chklock WHERE i_session = "+sessionId);
	        
	        
	        if (projList!=null) {
	        	if (projList.length == 1) {
	        		proj = doString.checkString(projList[0],"");		
	        		projId = proj.substring(3,6);
	        		if (projId.equals("ALL")) {
	        			rs = stmt.executeQuery("SELECT DISTINCT i_company, i_project FROM lan:serv_chkmain WHERE i_chkseq = "+Integer.toString(s)+" AND i_month = '"+chkMonth+"' AND i_year = '"+Integer.toString(curYear+543)+"' AND i_main = '"+type+"' AND q_lock > 0");
	        			if (rs != null) {
	        				while (rs.next() == true) {
	        					comId = doString.checkString(rs.getString("I_COMPANY"));
	        					projId = doString.checkString(rs.getString("I_PROJECT"));
	        					proj = comId+":"+projId;
	        					proj_list.add(proj);
	        				}// end while
	        				rs.close();
	        				rs=null;
	        			}
	        		} else { // All Project
	        			proj_list.add(proj);
	        		}
	        	} else {
	        		for (int i=0; i<projList.length; i++) {
	        			proj = doString.checkString(projList[i],"");
	        			if (!proj.equals("")) {
	        				proj_list.add(proj);
	        			}
	        		}// end for
	        	}
	        	
	  		  for (int i=0;i<proj_list.size();i++) {
	  			  
	  				 proj = doString.checkString((String)proj_list.elementAt(i));  	
	  				 if (proj.trim().length()>=6) {
	  					comId = proj.substring(0,2);
	  					projId = proj.substring(3,6);
	  					brand = "";
	  					rs = stmt.executeQuery("SELECT i_brand FROM lan:serv_brand WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
	  					if (rs != null) {
		  		    		if (rs.next() == true) {
		  		    			brand = doString.checkString(rs.getString(1));
		  		    		}
		  		    		rs.close();
		  		    		rs=null;
	  					}
//System.out.println("SELECT i_sort, d_close_law FROM lan:acscontr WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND f_contr IS NULL AND d_close_law >= '"+begDate+"' AND d_close_law <= '"+endDate+"'");
	  					
						rsChkup = ustmt.executeQuery("SELECT i_sort, d_close_law FROM lan:acscontr WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND f_contr IS NULL AND d_close_law >= '"+begDate+"' AND d_close_law <= '"+endDate+"'");
						if (rsChkup != null) {
							while (rsChkup.next() == true) {
								lockId = doString.checkString(rsChkup.getString("I_SORT"));
								//System.out.println(lockId);								
								Hashtable tmpCust = common.getCustomerDetails(comId,projId,lockId,"");
							    houseId = doString.checkString((String) tmpCust.get("i_house"));
								custName = doString.checkString((String) tmpCust.get("n_customer"));
								custTel = doString.checkString((String) tmpCust.get("n_cust_tel"));
								closeDate = doString.checkString(rsChkup.getString("D_CLOSE_LAW"));
								flood = false;
								rs = stmt.executeQuery("SELECT i_lock FROM lan:serv_flood WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lock = '"+lockId+"'");
								if (rs != null) {
									if (rs.next() == true) {
										flood = true;
									}
									rs.close();
									rs=null;
								}
								if (flood) {
									expireDate = getExpireDate(closeDate, 24);
								} else {
									expireDate = getExpireDate(closeDate, bckMnth[s-1]);
								}								
								deny = false;
								rs = stmt.executeQuery("SELECT i_month FROM lan:serv_denchkup WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lock = '"+lockId+"' AND i_chkseq = "+Integer.toString(seqNo));
								if (rs != null) {
									if (rs.next() == true) {
										mnthDate = rs.getString(1);	//Deny Month
										if (formatter.parse(mnthDate).before(formatter.parse(chkDate))) { //Before
											deny = true;
										}
									}
									rs.close();
									rs=null;
								}
								//System.out.println(lockId+":"+deny);					
								if (!deny) {
									chckup = false;
									rs = stmt.executeQuery("SELECT DISTINCT i_month, f_status FROM lan:serv_chkuplck WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lock = '"+lockId+"' AND i_chkseq = "+Integer.toString(seqNo));
									if (rs != null) {
										while (rs.next() == true) {
											mnthDate = doString.checkString(rs.getString("I_MONTH"));	//Checkup Month
											status = doString.checkString(rs.getString("F_STATUS"));
											if (!status.equals("D")) {
												if (formatter.parse(mnthDate).before(formatter.parse(chkDate))) {
													chckup = true;
													break;
												}
											}
										}// end while
										rs.close();
										rs=null;
									}
								
								
									if (!chckup) {							
										chckup = false;
										comment = "";
										docNo = "";
										sql.delete(0,sql.length());
										sql.append("SELECT i_docno, f_status, i_month, i_vendor FROM lan:serv_chkuplck WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lock = '"+lockId+"' AND i_chkseq = "+Integer.toString(seqNo) + " AND f_status != 'D'");									
										if (type.equals("03") || type.equals("07")) {	//Checkup
											sql.delete(0,sql.length());
											sql.append("SELECT f_status, i_month, i_vendor FROM lan:serv_chkuplck WHERE i_month = '")
												.append(chkDate)
												.append("' AND i_company = '")
												.append(comId)
												.append("' AND i_project = '")
												.append(projId)
												.append("' AND i_lock = '")
												.append(lockId)
												.append("' AND i_chkseq = ")
												.append(Integer.toString(seqNo))
												.append(" AND f_status != 'D'");
										} else if (type.equals("07")) { //Cancel

										}
										rs = stmt.executeQuery(sql.toString());								
										if (rs != null) {
											if (rs.next() == true) {
												chckup = true;
												status = doString.checkString(rs.getString("F_STATUS"));
												mnthDate = doString.checkString(rs.getString("I_MONTH"));
												
												
												
												venId = doString.checkString(rs.getString("I_VENDOR"));
												venName = "";
												rsTime = cstmt.executeQuery("SELECT bus_name FROM lan:stpvendr WHERE vend_code = '"+venId+"'");
												if (rsTime != null) {
													if (rsTime.next() == true) {
														venName = doString.checkString(rsTime.getString("BUS_NAME"));
													}
													rsTime.close();
													rsTime=null;
												}												
												chkDay = "-";
												chkTime = "-";
												rsTime = cstmt.executeQuery("SELECT DAY(d_chckup) AS CHK_DAY, i_time FROM lan:serv_chkupdt WHERE i_month = '"+mnthDate+"' AND i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lock = '"+lockId+"' AND i_chkseq = "+Integer.toString(seqNo));
												if (rsTime != null) {
													if (rsTime.next() == true) {
														chkDay = doString.displayNumber("00", rsTime.getInt("CHK_DAY"));
														chkTime = doString.checkString(rsTime.getString("I_TIME"));
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
												if (!type.equals("07") && !type.equals("04") && !type.equals("05") && !type.equals("06")) {
													sql.delete(0,sql.length());
											        sql.append("INSERT INTO lan:serv_chklock(i_session, user_id, i_company, i_project, i_lock, i_chkseq, i_status, f_status, n_status, i_house, n_name, i_tel, d_close_law, i_day, i_time, i_docno, ven_name, c_comment) VALUES(")
											        	.append(sessionId)
											        	.append(", '")								        	
											        	.append(userId)
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
											        	.append(docNo)
											        	.append("', '")
											        	.append(venName)
											        	.append("', '")
											        	.append(comment+"')");
											        cstmt.executeUpdate(sql.toString());
												}
											}// end if
											rs.close();
											rs=null;
										}
										if (type.equals("06")) {
											if (chckup) {
												if (formatter.parse(mnthDate).after(formatter.parse(chkDate))) {
													chckup = false;
												}
											}
										}
										if ((type.equals("01") || type.equals("02") || type.equals("07") || type.equals("04") || type.equals("05") || type.equals("06")) && !chckup) {
											code = "";
											status = "N";
											cancelDate = "";
											if (type.equals("07")) {
												rs = stmt.executeQuery("SELECT f_status, i_cancel, d_cancel FROM lan:serv_chkuplck WHERE i_month = '"+chkDate+"' AND i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lock = '"+lockId+"' AND i_chkseq = "+Integer.toString(seqNo)+" AND f_status = 'D' ORDER BY d_cancel DESC");
												if (rs != null) {
													if (rs.next() == true) {
														status = "D";
														code = doString.checkString(rs.getString("I_CANCEL"));
														cancelDate = doString.checkString(rs.getString("D_CANCEL"));
													}// end if
													rs.close();
													rs=null;
												}
												rs = stmt.executeQuery("SELECT n_desc FROM lan:serv_xstd WHERE i_type = '67' AND i_code = '"+code+"'");
												code = "";
												if (rs != null) {
													if (rs.next() == true) {
														code = doString.checkString(rs.getString("N_DESC"));
													}
													rs.close();
													rs=null;
												}
												
											}
											if (type.equals("04")) {
												rs = stmt.executeQuery("SELECT * FROM lan:serv_denchkup WHERE i_month = '"+chkDate+"' AND i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lock = '"+lockId+"' AND i_chkseq = "+Integer.toString(seqNo));
												if (rs != null) {
													if (rs.next() == true) {
														status = "D";
														code = doString.checkString(rs.getString("I_CAUSE"));
														cancelDate = doString.checkString(rs.getString("D_DENY"));
													}// end if
													rs.close();
													rs=null;
												}
												rs = stmt.executeQuery("SELECT n_desc FROM lan:serv_xstd WHERE i_type = '68' AND i_code = '"+code+"'");
												code = "";
												if (rs != null) {
													if (rs.next() == true) {
														code = doString.checkString(rs.getString("N_DESC"));
													}
													rs.close();
													rs=null;
												}
											}
											if (type.equals("05")) {
												if (expireDate.equals(chkDate)) {
													rs = stmt.executeQuery("SELECT * FROM lan:serv_denchkup WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lock = '"+lockId+"' AND i_chkseq = "+Integer.toString(seqNo));
													if (rs != null) {
														if (rs.next() == false) {
															status = "D";
														}// end if
														rs.close();
														rs=null;
													}
												}
											}
											
											if (type.equals("06")) {
												if (!expireDate.equals(chkDate)) {
													rs = stmt.executeQuery("SELECT * FROM lan:serv_denchkup WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lock = '"+lockId+"' AND i_chkseq = "+Integer.toString(seqNo));
													if (rs != null) {
														if (rs.next() == true) {
															mnthDate = doString.checkString(rs.getString("I_MONTH"));	//Deny Month
															if (formatter.parse(mnthDate).after(formatter.parse(chkDate))) {
																status = "D";
															}
														} else {
															status = "D";
														}
														rs.close();
														rs=null;
													}
												}
											}
											
											insert = false;
											if (type.equals("01") || type.equals("02") ) {
												insert = true;
											} else {
												if (status.equals("D") ) {
													insert = true;
												}
											}
											if (insert) {
												sql.delete(0,sql.length());
										        sql.append("INSERT INTO lan:serv_chklock(i_session, user_id, i_company, i_project, i_lock, i_chkseq, i_status, f_status, n_status, i_house, n_name, i_tel, d_close_law, d_cancel) VALUES(")
											        .append(sessionId)
										        	.append(", '")								        
										        	.append(userId)
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
										        	.append(", '"+status+"', '")
										        	.append(code)
										        	.append("', '")						        	
										        	.append(houseId)
										        	.append("', '")
										        	.append(custName)
										        	.append("', '")
										        	.append(custTel)
										        	.append("', '")
										        	.append(closeDate)
										        	.append("', '")
										        	.append(cancelDate+"')");
												cstmt.executeUpdate(sql.toString());
											}
										}
									}
								}// Not Deny
							}// end while
							rsChkup.close();
							rsChkup=null;
						}	     
	  				 }
	  		  }// end for project
	        }
	        
			//conn.commit();
	        stmt.close();
	        ustmt.close();
	        cstmt.close();
	        conn.close();
	        stmt = null;
	        ustmt = null;
	        cstmt = null;
	        conn = null;
	        res.sendRedirect(targetPage);
	    } catch (Exception e) {
/*	    	
			try {
				if (conn != null)
					conn.rollback();
			} catch (Exception ignore) {}
*/				    	
	        System.out.println("ERROR /LHServ/InitChkupLckServlet : " + sql.toString());
	        genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ "+e.getMessage());
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