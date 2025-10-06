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
 * Servlet implementation class for Servlet: ChckQCServlet
 *
 */
 public class ChckQCServlet extends DBServlet {	 
	 private static String cName = "/LHServ/ChckQCServlet";
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
	    String empId = user.getEmpId();
		String mode = doString.checkString(req.getParameter("mode"));
	    String setId = doString.checkString(req.getParameter("Set"));
		String jobId = doString.checkString(req.getParameter("Job"),"00");
		String nxtJob = doString.displayNumber("00", Double.parseDouble(jobId)+1);
		String comId = doString.checkString(req.getParameter("comId"));
		String projId = doString.checkString(req.getParameter("projId"));
		String projNme = "";
	    String docNo = doString.checkString(req.getParameter("i_docno"));
		String qcNo = doString.checkString(req.getParameter("qcNo"));
		String venId = "";
		String venNme = "";
		String mainId = "";
		String subId = "";
		String answer = "";
		String acqNo = "";
		String comment = "";
		Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
		String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
		cur_year = cur_year.substring(2);		
		int unit = 0;
		double score = 0;
		double mark = 0;
		double max_score = 0;
		double tot_score = 0;
		
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
		
		//------ forward page --------//
		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_QCDetail.jsp?i_docno="+docNo+"&Job="+nxtJob;
		String errorPage = "SERV_QCList.jsp?sel_project="+comId+":"+projId; 		
		String otherMsg = "";
		String errorCode = "";
		int rowEffected = 0;
		StringBuffer sql = new StringBuffer();
	    Connection conn = null;
	    Statement stmt = null;
	    Statement ustmt = null;
		Statement mstmt = null;
		Statement sstmt = null;
	    ResultSet rs =null;
		ResultSet rsMain =null;
		ResultSet rsSub =null;
	    try {
	        if (ds == null)
	            getDS();
	        conn = ds.getConnection();
	        conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	        conn.setAutoCommit(false);
	        stmt = conn.createStatement();
	        ustmt = conn.createStatement();
			mstmt = conn.createStatement();
			sstmt = conn.createStatement();
			rs = stmt.executeQuery("SELECT MAX(i_job) AS MAX_JOB FROM lan:serv_qcstd WHERE i_set = '"+setId+"'");
			if (rs != null) {
				if (rs.next() == true) {
					if (doString.checkString(rs.getString("MAX_JOB")).equals(jobId)) {
						successPage = "SERV_QCList.jsp?sel_project="+comId+":"+projId;
					}
				}
				rs.close();
				rs=null;
			}
			
	        rs = stmt.executeQuery("SELECT n_project FROM lan:acxprojt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
	        if (rs != null) {
	        	if (rs.next() == true) {
					projNme = rs.getString("N_PROJECT");
	        	}
	        	rs.close();
	        	rs=null;
	        }
			rs = stmt.executeQuery("SELECT i_vendor FROM lan:serv_docdt WHERE i_docno = '"+docNo+"'");
			if (rs != null) {
				if (rs.next() == true) {
					venId = doString.checkString(rs.getString("I_VENDOR"));
				}
				rs.close();
				rs=null;
			}
			rs = stmt.executeQuery("SELECT ven_name FROM lan:vendor WHERE ven_no = '"+venId+"'");
			if (rs != null) {
				if (rs.next() == true) {
					venNme = rs.getString("VEN_NAME");
				}
				rs.close();
				rs=null;
			}
				        
			if (qcNo.equals("")) {
				String prefixDocNo = comId+"-"+projId+"-"+cur_year;
				sql.delete(0, sql.length());
				sql.append("SELECT i_qcno FROM lan:serv_qchd WHERE i_company = '")
					.append(comId)
					.append("' AND i_project = '")
					.append(projId)
					.append("' AND i_qcno LIKE '")
					.append(prefixDocNo)
					.append("%' ORDER BY i_qcno DESC");
				rs = stmt.executeQuery(sql.toString());								
				if (rs.next() == true) {
					String oldDocNo = doString.checkString(rs.getString("I_QCNO"));
					int lastId = Integer.parseInt(oldDocNo.substring(oldDocNo.length()-5));
					if (lastId<0) { 
						lastId = 1;
					} else {
						lastId++; 
					}
					qcNo = prefixDocNo+doString.displayNumber("00000", lastId);
				} else {
					//----======== No DocNo found , start 1 ========----// 
					qcNo = prefixDocNo+doString.displayNumber("00000", 1);
				}
				rs.close();
				rs=null;
				//SERV_QCHD
				sql.delete(0, sql.length());
				sql.append("INSERT INTO lan:serv_qchd(i_qcno, i_company, i_project, i_docno, i_set, i_job, i_date, i_employ) VALUES('")
					.append(qcNo)
					.append("', '")
					.append(comId)
					.append("', '")
					.append(projId)
					.append("', '")
					.append(docNo)
					.append("', '")
					.append(setId)
					.append("', '")
					.append(jobId)
					.append("', TODAY, '")
					.append(empId)
					.append("')");
				rowEffected = stmt.executeUpdate(sql.toString());
				if (rowEffected != 1) {
					throw new Exception("SERV_QCHD : Wrong insert count");
				}
			}
			//SERV_QCDT
			stmt.executeUpdate("DELETE FROM lan:serv_qcdt WHERE i_qcno = '"+ qcNo + "'");
			if (mode.equals("D")) { //Delete Mode
				stmt.executeUpdate("DELETE FROM lan:serv_qchd WHERE i_qcno = '"+ qcNo + "'");
				stmt.executeUpdate("DELETE FROM lan:serv_qcsum WHERE i_docno = '" + docNo + "' AND i_job = '" + jobId + "'");				
			} else {
				sql.delete(0, sql.length());
				sql.append("SELECT i_main, i_sub FROM lan:serv_qcstd WHERE i_set = '")
					.append(setId)
					.append("' AND i_job = '")
					.append(jobId)
					.append("' AND i_sub > '00' AND i_answer = '0' ORDER BY i_main, i_sub");
				rs = stmt.executeQuery(sql.toString());
				while (rs.next() == true) {
					mainId = doString.checkString(rs.getString("I_MAIN"));
					subId = doString.checkString(rs.getString("I_SUB"));
					acqNo = setId + jobId + mainId + subId;
					answer = doString.checkString(req.getParameter("QC"+acqNo));
					comment = doString.checkString(req.getParameter("R"+acqNo));
					comment = doString.UnicodeToMS874(comment);
					if (!answer.equals("")) {
						score = 0;
						rsSub = sstmt.executeQuery("SELECT z_mark FROM lan:serv_qcstd WHERE i_set = '"+setId+"' AND i_job = '"+jobId+"' AND i_main = '"+mainId+"' AND i_sub = '"+subId+"' AND i_answer = '"+answer+"'");
						if (rsSub != null) {
							if (rsSub.next() == true) {
								score = rsSub.getDouble("Z_MARK");								
							}
							rsSub.close();
							rsSub=null;
						}						
						
						sql.delete(0, sql.length());
						sql.append("INSERT INTO lan:serv_qcdt(i_qcno, i_main, i_sub, i_answer, z_score, n_remark) VALUES('")
							.append(qcNo)
							.append("', '")
							.append(mainId)
							.append("', '")
							.append(subId)
							.append("', '")
							.append(answer)
							.append("', ")			
							.append(doString.displayNumber("#########.00", score))
							.append(", '")																		
							.append(comment+"')");		
						//Answer
						rowEffected = ustmt.executeUpdate(sql.toString());
						if (rowEffected != 1) {
							throw new Exception("SERV_QCDT : Wrong insert count");
						}						
					}
				} //Read until EOF()
				rs.close();
				rs=null;	
				//SERV_QCSUM
				rs = stmt.executeQuery("SELECT i_docno FROM lan:serv_qcsum WHERE i_docno = '"+docNo+"' AND i_job = '"+jobId+"'");
				if (rs.next() == false) {
					sql.delete(0, sql.length());
					sql
						.append("INSERT INTO lan:serv_qcsum(i_company, i_project, n_project, i_docno, user_id, ven_no, ven_name, i_set, i_job, i_date, qc_date, ")
						.append("z_unit01, z_score01, z_mark01, z_jbscore01, z_unit02, z_score02, z_mark02, z_jbscore02, z_unit03, z_score03, z_mark03, z_jbscore03, z_unit04, z_score04, z_mark04, z_jbscore04, z_unit05, z_score05, z_mark05, z_jbscore05, ")
						.append("z_unit06, z_score06, z_mark06, z_jbscore06, z_unit07, z_score07, z_mark07, z_jbscore07, z_unit08, z_score08, z_mark08, z_jbscore08, z_unit09, z_score09, z_mark09, z_jbscore09, z_unit10, z_score10, z_mark10, z_jbscore10, z_unit11, z_score11, z_mark11, z_jbscore11) VALUES('")
						.append(comId)
						.append("', '")
						.append(projId)
						.append("', '")
						.append(projNme)
						.append("', '")
						.append(docNo)
						.append("', '")
						.append(userId)
						.append("', '")
						.append(venId)
						.append("', '")
						.append(venNme)
						.append("', '")
						.append(setId)												
						.append("', '")
						.append(jobId)
						.append("', TODAY, TODAY, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)");
					rowEffected = stmt.executeUpdate(sql.toString());
					if (rowEffected != 1) {
						throw new Exception("SERV_QCSUM : Wrong insert count");
					}					
				}
				rs.close();
				rs=null;
				sql.delete(0, sql.length());					
				rsMain = mstmt.executeQuery("SELECT DISTINCT i_main FROM lan:serv_qcdt WHERE i_qcno = '"+qcNo+"' ORDER BY i_main");
				if (rsMain != null) {
					while (rsMain.next() == true) {
						mainId = doString.checkString(rsMain.getString("I_MAIN"));
						tot_score = 0;
						score = 0;
						rsSub = sstmt.executeQuery("SELECT DISTINCT i_sub FROM lan:serv_qcdt WHERE i_qcno = '"+qcNo+"' AND i_main = '"+mainId+"' ORDER BY i_sub");
						if (rsSub != null) {
							while (rsSub.next() == true) {
								subId = doString.checkString(rsSub.getString("I_SUB"));
								max_score = 0;
								rs = stmt.executeQuery("SELECT MAX(z_mark) AS MAX_SCORE FROM lan:serv_qcstd WHERE i_set = '"+setId+"' AND i_job = '"+jobId+"' AND i_main = '"+mainId+"' AND i_sub = '"+subId+"'");
								if (rs != null) {
									if (rs.next() == true) {
										max_score = rs.getDouble("MAX_SCORE");								
									}
									rs.close();
									rs=null;
								}
								tot_score += max_score;
								rs = stmt.executeQuery("SELECT z_score FROM lan:serv_qcdt WHERE i_qcno = '"+qcNo+"' AND i_main = '"+mainId+"' AND i_sub = '"+subId+"'");
								if (rs != null) {
									if (rs.next() == true) {
										score += rs.getDouble("Z_SCORE");																		
									}
									rs.close();
									rs=null;
								}
							}// end while sub
							rsSub.close();
							rsSub=null;
						}
						mark = 0;
						if (tot_score > 0) {
							mark = (score / tot_score) * 100.00;
						} 
						sql.append(", z_unit" + mainId + " = 1")
							.append(", z_score" + mainId + " = ")
							.append(doString.displayNumber("#########.00", score))
							.append(", z_mark" + mainId + " = ")
							.append(doString.displayNumber("###.00", mark))
							.append(", z_jbscore" + mainId + " = ")
							.append(doString.displayNumber("#########.00", tot_score));
					}// end while Main
					rsMain.close();
					rsMain=null;
				}
				//////////
				rowEffected = ustmt.executeUpdate("UPDATE lan:serv_qcsum SET i_set = 1"+sql.toString()+" WHERE i_docno = '"+docNo+"' AND i_job = '" + jobId + "'");
				if (rowEffected != 1) {
					throw new Exception("SERV_QCSUM : Wrong update count");
				}
				
				unit = 0;
				rs = stmt.executeQuery("SELECT SUM(z_unit01) AS UNIT01 FROM lan:serv_qcsum WHERE i_docno = '"+docNo+"'");
				if (rs != null) {
					if (rs.next() == true) {
						unit = rs.getInt("UNIT01");
					}
					rs.close();
					rs=null;
				}
				if (unit > 1) {
					jobId = "";
					rs = stmt.executeQuery("SELECT i_job FROM lan:serv_qcsum WHERE i_docno = '"+docNo+"' AND z_unit01 = 1 ORDER BY i_job DESC");
					if (rs != null) {
						if (rs.next() == true) {
							jobId = doString.checkString(rs.getString("I_JOB"));
						}
						rs.close();
						rs=null;
					}
					if (!jobId.equals("")) {
						stmt.executeUpdate("UPDATE lan:serv_qcsum SET z_unit01 = 0 WHERE i_docno = '"+docNo+"' AND z_unit01 = 1");
						stmt.executeUpdate("UPDATE lan:serv_qcsum SET z_unit01 = 1 WHERE i_docno = '"+docNo+"' AND i_job = '"+jobId+"'");
					}
				}
			}
	        
			conn.commit();
	        stmt.close();
	        ustmt.close();
			mstmt.close();
			sstmt.close();
	        conn.close();
	        stmt = null;
	        ustmt = null;
			mstmt = null;
			sstmt = null;
	        conn = null;
			genRedirectCode(out,savePage,successPage,errorCode,otherMsg);
	    } catch (Exception e) {
			try {
				if (conn != null)
					conn.rollback();
			} catch (Exception ignore) {}
	        System.out.println("ERROR /LHServ/ChckQCServlet : " + e.getMessage());
			genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ : "+e.getMessage());
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
			if (mstmt != null) {
				try {
					mstmt.close();
				} catch (SQLException ignore) {
				}
			}	 
			if (sstmt != null) {
				try {
					sstmt.close();
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