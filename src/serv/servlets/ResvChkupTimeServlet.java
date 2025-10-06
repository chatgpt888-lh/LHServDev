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
import serv.common.Constants;
/**
 * Servlet implementation class for Servlet: InitResvTimeServlet
 *
 */
 public class ResvChkupTimeServlet extends DBServlet {	 
	 private static String cName = "/LHServ/ResvChkupTimeServlet";
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
	    String chkMonth = resv_time.getChkMonth();
	    String chkYear = resv_time.getChkYear();
	    String mnthDate = Integer.parseInt(chkYear)-543+"-"+chkMonth+"-01";
	    String empId =resv_time.getEmpId();
	    String comId = resv_time.getComId();
	    String projId = resv_time.getProjId();
	    String vendor = resv_time.getVendor();
	    String group = resv_time.getGroup();
	    int curWeek = Integer.parseInt(doString.checkString(req.getParameter("CurWeek"),"1"));
	    vendor = doString.checkString(req.getParameter("Vendor"));
	    group = "";
	    int idx=0;
	    if (!vendor.equals("")) {
	    	idx = vendor.indexOf("|");
	    	if (idx != -1) {
	    		group = vendor.substring(idx+1);
	    		vendor = vendor.substring(0, idx);
	    	}
	    }	    
	    String sub_vend = doString.checkString(req.getParameter("sub_vend"));
	    
	    int seqNo = 0;
	    String docNo = "";
	    String brand = "";
		//------ forward page --------//
		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_ResvTimeLst.jsp?Project="+comId+projId+"&chkMonth="+chkMonth+"&chkYear="+Integer.toString(Integer.parseInt(chkYear)-543);
		String errorPage = successPage + "&error=1"; 		
		String otherMsg = "";
		String errorCode = "";		    
	    Vector timeList = new Vector(5);
	    Vector chkTimeList = resv_time.getChkTimeList();
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
	    String[] chkTime = req.getParameterValues("chkTime");
	    String time = "";
	    String chkDay = "";
	    idx = 0;
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
	    int rowEffected = 0;
	    int num_time = chkTimeList.size();
	    int num_resvtime = 0;
	    StringBuffer sql = new StringBuffer();
	    Connection conn = null;
	    Statement stmt = null;
	    Statement cstmt = null;
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

	    	rs = stmt.executeQuery("SELECT i_brand FROM lan:serv_brand WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
	    	if (rs != null) {
	    		if (rs.next() == true) {
	    			brand = doString.checkString(rs.getString(1));
	    		}
	    		rs.close();
	    		rs=null;
	    	}		        
	        rs = stmt.executeQuery("SELECT NVL(MAX(i_seq),0) AS CUR_SEQ FROM lan:serv_chkuphd WHERE i_employ = '"+empId+"' AND i_month = '"+mnthDate+"'");
	        if (rs != null) {
	        	if (rs.next() == true) {
	        		seqNo = rs.getInt("CUR_SEQ")+1;
	        	}
	        	rs.close();
	        	rs=null;
	        }
	        docNo = empId + "-" + chkMonth + chkYear.substring(2) + "-" + doString.displayNumber("0000", seqNo);
	        if (num_time <= 0) {
	        	throw new Exception("ไม่พบข้อมูลช่วงเวลาการจอง");
	        }	        
	        //SERV_CHKUPHD
	        sql.delete(0,sql.length());
	        sql.append("INSERT INTO lan:serv_chkuphd(i_chkupno, i_month, d_keyin, i_seq, i_employ, i_vendor, i_group, i_company, i_project, i_sub_vend) VALUES('")
	        	.append(docNo)
	        	.append("', '")
	        	.append(mnthDate)
	        	.append("', CURRENT, ")
	        	.append(Integer.toString(seqNo))
	        	.append(", '")
	        	.append(empId)
	        	.append("', '")
	        	.append(vendor)
	        	.append("', '")
	        	.append(group)
	        	.append("', '")
	        	.append(comId)
	        	.append("', '")
	        	.append(projId)
	        	.append("', '")	        	
	        	.append(sub_vend+"')");
	        rowEffected = stmt.executeUpdate(sql.toString());
	        if (rowEffected != 1) {
	        	throw new Exception("SERV_CHKUPHD : Wrong insert count");
	        }
	        //SERV_CHKUPDT
	        if (chkTimeList != null) {
		        for (int t=0; t<chkTimeList.size(); t++) {
		        	ChkTime aTime = (ChkTime)chkTimeList.elementAt(t);
		        	if (aTime != null) {
		        		chkDay = aTime.getChkDate();
		        		chkDate = Integer.parseInt(chkYear)-543+"-"+chkMonth+"-"+chkDay;
		        		brTime = aTime.getChkTime();
		        		aTime.setReserve(true);
						try {
							rs = stmt.executeQuery("SELECT c_time FROM lan:serv_bctime WHERE i_brand = '"+brand+"' AND b_time = '"+brTime+"' ORDER BY c_time");
							if (rs != null) {
								while (rs.next() == true) {
									ckTime = doString.checkString(rs.getString("C_TIME"));
									sql.delete(0,sql.length());
							        sql.append("INSERT INTO lan:serv_chkupdt(i_chkupno, i_month, i_employ, i_vendor, i_group, i_company, i_project, d_chckup, i_time, f_status) VALUES('")
							        	.append(docNo)
							        	.append("', '")
							        	.append(mnthDate)
							        	.append("', '")
							        	.append(empId)
							        	.append("', '")
							        	.append(vendor)
							        	.append("', '")
							        	.append(group)
							        	.append("', '")
							        	.append(comId)
							        	.append("', '")
							        	.append(projId)
							        	.append("', '")
							        	.append(chkDate)
							        	.append("', '")							        	
							        	.append(ckTime+"', 'N')");
							        rowEffected = cstmt.executeUpdate(sql.toString());
							        num_resvtime++;
								}// end while
								rs.close();
								rs=null;
							}
						} catch (Exception e) {
							savePage = "SERV_SaveTimeLst.jsp";
							aTime.setReserve(false);
							rs = stmt.executeQuery("SELECT c_time FROM lan:serv_bctime WHERE i_brand = '"+brand+"' AND b_time = '"+brTime+"' ORDER BY c_time");
							if (rs != null) {
								while (rs.next() == true) {
									ckTime = doString.checkString(rs.getString("C_TIME"));
							        cstmt.executeUpdate("DELETE FROM lan:serv_chkupdt WHERE i_chkupno = '"+docNo+"' AND d_chckup = '"+chkDate+"' AND i_time = '"+ckTime+"'");
								}// end while
								rs.close();
								rs=null;
							}
						}
/*							
							rs = stmt.executeQuery("SELECT c_time FROM lan:serv_bctime WHERE i_brand = '"+brand+"' AND b_time = '"+brTime+"' ORDER BY c_time");
							if (rs != null) {
								while (rs.next() == true) {
									ckTime = doString.checkString(rs.getString("C_TIME"));
									rsChkup = cstmt.executeQuery("SELECT i_employ FROM lan:serv_chkupdt WHERE i_month = '"+mnthDate+"' AND d_chckup = '"+chkDate+"' AND i_time = '"+ckTime+"'");
									if (rsChkup != null) {
										if (rsChkup.next() == true) {
											empty = false;
											break;
										}
										rsChkup.close();
										rsChkup=null;
									}
								}// end while
								rs.close();
								rs=null;
							}
							if (empty) {
							} else {
								notime_list.addElement(aTime);
								savePage = "";
							}
*/							
		        	}
		        }// end for
	        }
	        if (num_resvtime == 0) {
	        	throw new Exception("คุณไม่สามารถจองเวลาได้เลย");	        	
	        }
	        conn.commit();
	        stmt.close();
	        cstmt.close();
	        conn.close();
	        stmt = null;
	        cstmt = null;
	        conn = null;
	        session.setAttribute("resv_time", resv_time);
	        genRedirectCode(out,savePage,successPage,errorCode,otherMsg);	        
	    } catch (Exception e) {
			try {
				if (conn != null)
					conn.rollback();
			} catch (Exception ignore) {}	    	
	        System.out.println("ERROR /LHServ/ResvChkupTimeServlet : " + e.getMessage());
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