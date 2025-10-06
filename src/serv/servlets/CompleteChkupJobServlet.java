package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;


import com.lh.servlet.DBServlet;
import com.lh.util.doString;

import serv.common.Constants;
import serv.common.SERV_CommonData;
import serv.common.User;
import serv.common.ResvTime;
import serv.common.ChkTime;
import serv.common.Constants;
/**
 * Servlet implementation class for Servlet: SetChkupLockServlet
 *
 */
 public class CompleteChkupJobServlet extends DBServlet {	 
	 private static String cName = "/LHServ/CompleteChkupJobServlet";
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
	    String chk_lock[] = req.getParameterValues("chkLock");
	    String lockId = "";
	    String seqNo = "";
	    String status = "";
	    String iDocNo = "";
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
    		sql.delete(0,sql.length());
    		sql.append(" insert into lan:serv_payment ( ")
    		.append(" i_docno ,                               i_seq ,                                         i_itmjob ,                                                      i_vendor ,                      q_wage_unit ,                   z_wage_price , ")
    		.append(" q_good_unit ,           z_good_price ,  c_itmjob ,                                              i_itmjob_area ,         f_itmstatus ,                           d_payment , ")
    		.append(" i_ven_cut ,                     p_cut ,                                         p_add_pay ,                                     vat_tax_code ,  z_amount_pay ,          z_amount_pv , ")
    		.append(" z_amount_vat ,  z_amount_tax ,  pv_no ,                                                         d_post_pv ,             z_amount_cut ,                  z_cut_pv ,  ")
    		.append(" z_cut_vat ,                     z_cut_tax ,                     i_refno ,                                                       d_post_cut ,            f_posted ,                                      f_reject ,  ")
    		.append(" i_employ_reject ,       d_reject ,                              c_reject ,                              f_remark ")
    		.append(" ) values ( ")
    		.append(" ?,?,?,?,?,?,                ?,?,?,?,'400',?,                null,null,?,null,?,null,                null,null,null,null,null,null,          null,null,null,null,null,null,          null,null,null,null) ");
    		pstmt = conn.prepareStatement(sql.toString());
	        
	        
	    	String begDate = common.getValueFromDateListbox("start",req);
	    	String endDate = common.getValueFromDateListbox("end",req);
	    	String start_date = "";
	    	String start_month = "";
	    	String start_year = "";
	    	String end_date = "";
	    	String end_month = "";
	    	String end_year = "";
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
	    	String pAmount = "";
	    	String paymentDate = "";
	    	String vendor = "";
	    	doString str = new doString();
	    	
	    	Calendar now = Calendar.getInstance(Locale.ENGLISH);
	    	int year = (now).get(Calendar.YEAR);
	    	if (year<2400) year += 543;
	    	String nowDate = Integer.toString(year>2400 ? year-543 : year);
	    	nowDate += "-"+str.createID(now.get(Calendar.MONTH)+1,2);
	    	nowDate += "-"+str.createID(now.get(Calendar.DATE),2);
	    	nowDate += " "+str.createID(now.get(Calendar.HOUR_OF_DAY),2);
	    	nowDate += ":"+str.createID(now.get(Calendar.MINUTE),2);	    	
	    	
	        pAmount = "";
	        rs = stmt.executeQuery("SELECT p_amount FROM lan:serv_xstd WHERE i_type = '02'");
	        if (rs.next() == true) {
	        	pAmount = doString.checkString(rs.getString("P_AMOUNT"),"0");
	        }
	        rs.close();
	        rs=null;
	        
	        rs = stmt.executeQuery("SELECT d_payment FROM lan:serv_payschd WHERE TODAY <= d_contructor ORDER BY d_payment");
	        if (rs.next() == true) {
	        	Calendar pay = Calendar.getInstance(Locale.ENGLISH);
	        	Timestamp tmp = rs.getTimestamp("D_PAYMENT");
	        	if (tmp != null) {
	        		pay.setTime(tmp);
	        		int tYear = pay.get(Calendar.YEAR);
	        		if (tYear>2400) tYear-= 543;
	        		paymentDate += tYear+"-"+str.createID(pay.get(Calendar.MONTH)+1,2);
	        		paymentDate += "-"+str.createID(pay.get(Calendar.DATE),2);
	        	}
	        }
	        rs.close();
	        rs=null;
	    	
	    	
	    	
	    	int line=0;
	    	String params = "&start_date="+start_date+"&start_month="+start_month+"&start_year="+start_year+"&end_date="+end_date+"&end_month="+end_month+"&end_year="+end_year;
	    	successPage = successPage + params;
	    	errorPage = successPage + "&error=1";
	    	if (chk_lock != null) {
	    		for (int i=0; i<chk_lock.length; i++) {
	    			lockId = doString.checkString(chk_lock[i]);
	    			comId = doString.checkString(lockId.substring(0,2));
	    			projId = doString.checkString(lockId.substring(2,5));
	    			seqNo = doString.checkString(lockId.substring(10), "0");
	    			lockId = doString.checkString(lockId.substring(5,10));	    			
	    			if (!lockId.equals("") && !seqNo.equals("0")) {
	    				iDocNo = "";
	    				status = "";
		    			sql.delete(0,sql.length());
		    			sql.append("SELECT i_docno, f_status FROM lan:serv_chkuplck WHERE i_company = '")
		    				.append(comId)
		    				.append("' AND i_project = '")
		    				.append(projId)
		    				.append("' AND i_lock = '")
		    				.append(lockId)
		    				.append("' AND i_chkseq = ")
		    				.append(seqNo+" AND f_status = 'S'");
		    			rsChkup = cstmt.executeQuery(sql.toString());
		    			if (rsChkup != null) {
		    				if (rsChkup.next() == true) {
		    					iDocNo = doString.checkString(rsChkup.getString("I_DOCNO"));
		    					status = doString.checkString(rsChkup.getString("F_STATUS"));
		    				}
		    				rsChkup.close();
		    				rsChkup=null;
		    			}
		    			if (status.equals("S")) { //Start Task
		    				//SERV_CHKUPLCK
			    			sql.delete(0,sql.length());
			    			sql.append("UPDATE lan:serv_chkuplck SET f_status = 'C' WHERE i_company = '")
			    				.append(comId)
			    				.append("' AND i_project = '")
			    				.append(projId)
			    				.append("' AND i_lock = '")
			    				.append(lockId)
			    				.append("' AND i_chkseq = ")
			    				.append(seqNo+" AND f_status = 'S'");	    				
			    			rowEffected = stmt.executeUpdate(sql.toString());
					        if (rowEffected != 1) {
					        	throw new Exception("SERV_CHKUPLCK : Wrong update count");
					        }
					        
					        //SERV_CHKUPDT			    			
			    			sql.delete(0,sql.length());
			    			sql.append("UPDATE lan:serv_chkupdt SET f_status = 'C' WHERE i_company = '")
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
					        sql.append("UPDATE lan:serv_dochd SET d_complete_max = TODAY ")
					        	.append(" WHERE i_docno = '").append(iDocNo).append("' ");
					        stmt.executeUpdate(sql.toString());
					        
					        
					        //SERV_DOCDT
					        sql.delete(0,sql.length());
					        sql.append("UPDATE lan:serv_docdt SET ")
					        	.append(" f_itmstatus = '400' ") //---- Set status to 400 , Complete Task
					        	.append(" WHERE i_docno = '").append(iDocNo).append("'");
					        stmt.executeUpdate(sql.toString());
					        
					        //SERV_PAYMENT
					        line=0;
					        rs = stmt.executeQuery("SELECT * FROM lan:serv_docdt WHERE i_docno = '"+iDocNo+"'");
					        if (rs != null) {
					        	while (rs.next() == true) {
					        		line++;
					        		String iItmJob = doString.checkString(rs.getString("i_itmjob"));
					        		String iVendor = doString.checkString(rs.getString("i_vendor"));
					        		String qWage = doString.checkString(rs.getString("q_wage_unit"),"0.00");
					        		String zWage = doString.checkString(rs.getString("z_wage_price"),"0.00");
					        		String qGoods = doString.checkString(rs.getString("q_good_unit"),"0.00");
					        		String zGoods = doString.checkString(rs.getString("z_good_price"),"0.00");
					        		String cItmJob = doString.checkString(rs.getString("c_itmjob"));
					        		String iItmJobArea = doString.checkString(rs.getString("i_itmjob_area"));
					        		String zAmountPay = doString.checkString(rs.getString("z_amount_pay"),"0.00");
					        		
					        		pstmt.setString(1,iDocNo);
					        		pstmt.setInt(2,line);
					        		pstmt.setString(3,iItmJob);
					        		pstmt.setString(4,iVendor);
					        		pstmt.setString(5,qWage);
					        		pstmt.setString(6,zWage);
					        		pstmt.setString(7,qGoods);
					        		pstmt.setString(8,zGoods);
					        		pstmt.setString(9,cItmJob);
					        		pstmt.setString(10,iItmJobArea);
					        		pstmt.setString(11,paymentDate);
					        		pstmt.setString(12,pAmount);
					        		pstmt.setString(13,zAmountPay);
					        		pstmt.executeUpdate();
					        	}// end while
					        	rs.close();
					        	rs=null;
					        }
					        
					        
					        //SERV_FLOW
					        rs = stmt.executeQuery("SELECT DISTINCT i_vendor FROM lan:serv_docdt WHERE i_docno = '"+iDocNo+"'");
					        if (rs != null) {
					        	while (rs.next() == true) {
					        		vendor = doString.checkString(rs.getString("I_VENDOR"));
					        		sql.delete(0,sql.length());
					        		sql.append(" INSERT INTO lan:serv_flow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,c_reject ")
						        		.append(") VALUES (")
						        		.append(" '").append(iDocNo).append("' , ")
						        		.append(" '").append(vendor).append("' , ")
						        		.append(" '300' , ") //-- Set Status to 300 , Complete Task Already ---//
						        		.append(" '").append(nowDate).append("' , ")
						        		.append(" '").append(user.getUserID()).append("' , NULL ) ");
					        		cstmt.executeUpdate(sql.toString());					        		
					        	}// end while
					        	rs.close();
					        	rs=null;
					        }
					        
					        
		    			}//Open Job
	    			}
	    		}// end for
	    	}
	    	
	        conn.commit();
	        pstmt.close();
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
	        System.out.println("ERROR /LHServ/CompleteChkupJobServlet : " + e.getMessage());
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