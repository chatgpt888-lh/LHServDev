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
 public class OpenChkupJobServlet extends DBServlet {	 
	 private static String cName = "/LHServ/OpenChkupJobServlet";
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
	    String brand = "";
	    if (!project.equals("")) {
		    comId = project.substring(0, 2);
		    projId = project.substring(2);
	    }	    
	    String chk_lock[] = req.getParameterValues("chkLock");
	    String lockId = "";
	    String seqNo = "";
		String custName="";
		String custTel="";	    
	    boolean open_job = false;
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
	    String iDocNo = "";
	    String venId = "";
	    String vendor = "";
	    String comment = "";
	    String id="";
	    String area = "";
	    double wageUnit=0;
	    double goodsUnit=0;
	    double wagePrice=0;
	    double goodsPrice=0;
	    double zAmountPay=0;
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
	    ResultSet rs = null;
	    ResultSet rsBoq = null;
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
	    	if (chk_lock != null) {
	    		for (int i=0; i<chk_lock.length; i++) {
	    			open_job = true;
	    			lockId = doString.checkString(chk_lock[i]);
	    			venId = doString.checkString(req.getParameter("V"+lockId));
	    			
	    			comId = doString.checkString(lockId.substring(0,2));
	    			projId = doString.checkString(lockId.substring(2,5));
	    			seqNo = doString.checkString(lockId.substring(10), "0");
	    			lockId = doString.checkString(lockId.substring(5,10));
	    			
	    			if (venId.equals("")) {
	    				throw new Exception("โปรดเลือกผู้รับเหมาซ่อมแปลง : "+lockId);
	    			}
	    			if (!lockId.equals("") && !seqNo.equals("0")) {
	    				Hashtable tmpCust = common.getCustomerDetails(comId,projId,lockId,"");
						custName = doString.checkString((String) tmpCust.get("n_customer"));
						custTel = doString.checkString((String) tmpCust.get("n_cust_tel"));
						
						brand = "";
				    	rs = stmt.executeQuery("SELECT p_brand FROM lan:serv_brand WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
				    	if (rs != null) {
				    		if (rs.next() == true) {
				    			brand = doString.checkString(rs.getString("P_BRAND"));
				    		}
				    		rs.close();
				    		rs=null;
				    	}						
						
	    				
		    			sql.delete(0,sql.length());
		    			sql.append("SELECT i_lock FROM lan:serv_chkuplck WHERE i_company = '")
		    				.append(comId)
		    				.append("' AND i_project = '")
		    				.append(projId)
		    				.append("' AND i_lock = '")
		    				.append(lockId)
		    				.append("' AND i_chkseq = ")
		    				.append(seqNo+" AND f_status IN ('R', 'O', 'S')"); //Regis, OpenJob, StartTask
		    			rsChkup = cstmt.executeQuery(sql.toString());
		    			if (rsChkup != null) {
		    				if (rsChkup.next() == true) {
		    					open_job = false;
		    				}
		    				rsChkup.close();
		    				rsChkup=null;
		    			}
		    			if (!open_job) {
					        iDocNo = "";
		    				//SERV_CHKUPLCK
			    			sql.delete(0,sql.length());
			    			sql.append("SELECT i_docno FROM lan:serv_chkuplck WHERE i_company = '")
			    				.append(comId)
			    				.append("' AND i_project = '")
			    				.append(projId)
			    				.append("' AND i_lock = '")
			    				.append(lockId)
			    				.append("' AND i_chkseq = ")
			    				.append(seqNo+" AND f_status IN ('R', 'O', 'S')");	    				
			    			rs = stmt.executeQuery(sql.toString());
			    			if (rs != null) {
			    				if (rs.next() == true) {
			    					iDocNo = doString.checkString(rs.getString("I_DOCNO"));	
			    				}
			    				rs.close();
			    				rs=null;
			    			}
					        
			    			sql.delete(0,sql.length());
			    			sql.append("UPDATE lan:serv_chkuplck SET i_vendor = '"+venId+"', f_status = 'O' WHERE i_company = '")
			    				.append(comId)
			    				.append("' AND i_project = '")
			    				.append(projId)
			    				.append("' AND i_lock = '")
			    				.append(lockId)
			    				.append("' AND i_chkseq = ")
			    				.append(seqNo+" AND f_status IN ('R', 'O', 'S')");	    				
			    			rowEffected = stmt.executeUpdate(sql.toString());
					        if (rowEffected != 1) {
					        	throw new Exception("SERV_CHKUPLCK : Wrong update count");
					        }
					        //SERV_CHKUPDT
					        vendor = "";
					        nowDate = "";
					        dEstClose = "";
			    			sql.delete(0,sql.length());
			    			sql.append("SELECT i_vendor, d_chckup, d_chckup+1 AS CLS_DATE FROM lan:serv_chkupdt WHERE i_company = '")
			    				.append(comId)
			    				.append("' AND i_project = '")
			    				.append(projId)
			    				.append("' AND i_lock = '")
			    				.append(lockId)
			    				.append("' AND i_chkseq = ")
			    				.append(seqNo);	 
			    			rs = stmt.executeQuery(sql.toString());
			    			if (rs != null) {
			    				if (rs.next() == true) {
			    					vendor = doString.checkString(rs.getString("I_VENDOR"));
			    					nowDate = doString.checkString(rs.getString("D_CHCKUP"));
			    					dEstClose = doString.checkString(rs.getString("CLS_DATE"));
			    				}
			    				rs.close();
			    				rs=null;
			    			}
			    			vendor = venId;
			    			dAppoint = nowDate;
			    			sql.delete(0,sql.length());
			    			sql.append("UPDATE lan:serv_chkupdt SET f_status = 'O' WHERE i_company = '")
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
							sql.append("update lan:serv_dochd set ")
								  .append(" i_doc_type = 'J' , ")
								  .append(" n_customer='").append(custName).append("' , ")
								  .append(" n_cus_tel='").append(custTel).append("' , ")
								  .append(" d_job='").append(nowDate).append("' , ")
								  .append(" d_appoint='").append(dAppoint).append("' , ")
								  .append(" d_est_close='").append(dEstClose).append("' ")
							      .append(" where i_docno='").append(iDocNo).append("'  ");
							rowEffected = stmt.executeUpdate(sql.toString());
					        if (rowEffected <= 0) {
					        	throw new Exception("SERV_DOCHD : Wrong update count");
					        }
							
							//SERV_DOCDT
							sql.delete(0,sql.length());
							sql.append("DELETE FROM lan:serv_docdt WHERE i_docno = '").append(iDocNo).append("'");
							stmt.executeUpdate(sql.toString());
							rs = stmt.executeQuery("SELECT b.i_itmjob, b.n_itmjob, b.z_wage_unit, b.z_good_unit, b.n_count FROM lan:serv_chkboq c, lan:serv_boq b WHERE c.i_brand = '"+brand+"' AND c.i_chkseq = "+seqNo+" AND c.i_itmjob = b.i_itmjob");
							if (rs != null) {
								while (rs.next() == true) {
									id = doString.checkString(rs.getString("I_ITMJOB"));
									wagePrice = rs.getDouble("Z_WAGE_UNIT");
									goodsPrice = rs.getDouble("Z_GOOD_UNIT");
									wageUnit = 1;
									goodsUnit = 0;
									comment = "";
									area = "";
									zAmountPay = (wagePrice * (double) wageUnit)+(goodsPrice * (double) goodsUnit);
									
									rsBoq = cstmt.executeQuery("SELECT n_itmjob FROM lan:serv_boq WHERE i_itmjob = '"+id+"'");
									if (rsBoq != null) {
										if (rsBoq.next() == true) {
											comment = doString.checkString(rsBoq.getString("N_ITMJOB"));
										}
										rsBoq.close();
										rsBoq=null;
									}
									
									sql.delete(0,sql.length());
									sql.append("INSERT INTO lan:serv_docdt (i_docno , i_itmjob , i_vendor , q_wage_unit , ")
										.append(" z_wage_price , q_good_unit , z_good_price , z_amount_pay , c_itmjob , ")
										.append(" i_itmjob_area , f_itmstatus ) VALUES ( ")
										.append(" '").append(iDocNo).append("' , ")
										.append(" '").append(id).append("' , ")
										.append(" '").append(vendor).append("' , ")
										.append(" '").append(wagePrice).append("' , ")
										.append(" '").append(wageUnit).append("' , ")
										.append(" '").append(goodsPrice).append("' , ")
										.append(" '").append(goodsUnit).append("' , ")
										.append(" '").append(Double.toString(zAmountPay)).append("' , ")
										.append(" '").append(comment).append("' , ")
										.append(" '").append(area).append("' , ")
										.append(" '200' ) ");  //--- Set Status to 200 , Waiting for Start Task ---//
									cstmt.executeUpdate(sql.toString());
								}// end while boq
								rs.close();
								rs=null;
							}
							//SERV_FLOW
							sql.delete(0,sql.length());
							sql.append("DELETE FROM lan:serv_flow WHERE i_docno = '").append(iDocNo).append("'");
							stmt.executeUpdate(sql.toString());
							
							sql.delete(0,sql.length());
							sql.append("INSERT INTO lan:serv_flow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,c_reject ")
								.append(") VALUES (")
								.append(" '").append(iDocNo).append("' , ")
								.append(" '").append(vendor).append("' , ")
								.append(" '100' , ") //-- Set Status to 100 , OPEN JOB Already ---//
								.append(" '").append(nowDateWithTime).append("' , ")
								.append(" '").append(user.getUserID()).append("' , NULL ) ");
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
	        conn = null;
	        genRedirectCode(out,savePage,successPage,errorCode,otherMsg);	        
	    } catch (Exception e) {
			try {
				if (conn != null)
					conn.rollback();
			} catch (Exception ignore) {}	    	
	        System.out.println("ERROR /LHServ/OpenChkupJobServlet : " + e.getMessage());
	        System.out.println("SQL ERROR /LHServ/OpenChkupJobServlet : " + sql.toString());
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