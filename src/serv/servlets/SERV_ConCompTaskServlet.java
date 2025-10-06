package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;

import com.lh.servlet.DBServlet;
import com.lh.util.*;

import serv.common.Constants;
import serv.common.User;
/*
SELECT * FROM serv_infdochd where i_docno = 'LH-205-6000144';
SELECT * FROM serv_infdocdt where i_docno = 'LH-205-6000144';
SELECT * FROM serv_infflow where i_docno = 'LH-205-6000144';
*/
public class SERV_ConCompTaskServlet extends DBServlet {
	private void genRedirectCode(PrintWriter out,String page,String redirect,String error,String otherMsg) {
		out.println("<form method='post' action='"+page+"'>");		
		out.println("<input type='hidden' name='error' value='"+error+"'>");
		out.println("<input type='hidden' name='other_msg' value='"+otherMsg+"'>");
		out.println("<input type='hidden' name='redirect_url' value='"+doString.MS874ToUnicode(redirect)+"'>");		
		out.println("<script> document.forms[0].submit();</script>");
		out.println("</form>");		
	}	

	private String getRunningNumber(Connection conn, Statement stmt, String comId, String projId, String cur_year) throws SQLException, Exception {
		String i_docno_number = "";
		String docNo = "";
		ResultSet rs = null;
		try {
			rs = stmt.executeQuery("SELECT i_docno FROM lan:serv_infdochd WHERE i_docno LIKE '"+comId+"-"+projId+"-"+cur_year+"%' ORDER BY i_docno DESC");
			if (rs != null) {
				if (rs.next() == true) {
					docNo = doString.checkString(rs.getString(1));
				}
				rs.close();
				rs=null;
			}
			if (docNo.equals("")) {
				i_docno_number = "00001";	
			} else {
				String max_i_docno = docNo.substring(9,14);
				i_docno_number = Integer.toString(Integer.parseInt(max_i_docno)+1);
				if (i_docno_number.length() == 1)
					i_docno_number = "0000"+i_docno_number;
				else if (i_docno_number.length() == 2)
					i_docno_number = "000"+i_docno_number;
				else if (i_docno_number.length() == 3)
					i_docno_number = "00"+i_docno_number;
				else if(i_docno_number.length() == 4)
					i_docno_number = "0"+i_docno_number;
			}
		} catch (Exception ignore) {}
		return i_docno_number;
	}
	
	private double getAmount(String value) {
		double amount = 0;
		int i = 0;
		String number = "";
		String fraction = "";
		if (!value.equals("0")) {
			i = value.indexOf(".");
			if (i >= 0) {
				number = doString.checkString(value.substring(0, i),"0");
				fraction = doString.checkString(value.substring(i+1, i+3));
			} else {
				number = value;
				fraction = "00";
			}
			amount = Double.parseDouble(number + "." + fraction);
		}
		return amount;
	}	
	
	public void performTask(HttpServletRequest req, HttpServletResponse res)
			throws ServletException, IOException {
		String mName = new String(this.getClass().getName() + ".performTask: ");
		System.out.println(mName + "start.");
		//-----======= Check Login session =======-----//
		HttpSession session = req.getSession(false);
		if (session == null) {
			//---===== No Session , redirect to warning =======---// 
			res.sendRedirect(Constants.WARNING_PAGE);
			return;
		}
		
		Object obj = session.getAttribute("USER");
		if (obj == null) {
		//---===== Can't get User Login , redirect to warning ======---// 
			res.sendRedirect(Constants.WARNING_PAGE);
			return;
		}
		User user = (User)obj;
		String empId = user.getEmpId();
		String userId = user.getUserID();
		String sessionId = user.getsessionId();
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
		String savePage = Constants.SAVE_PAGE;
		String project = doString.checkString(req.getParameter("sel_project"));
		String comId = "";
		String projId = "";
		if (!project.equals("")) {
			comId = project.substring(0,2);
			projId = project.substring(3);
		}
		String successPage = "SERV_Home.jsp?sel_project="+project;
		String errorPage = successPage + "&error=1"; 		
		String otherMsg = "";
		String errorCode = "";			
		
		String venId = doString.checkString(req.getParameter("i_vendor"));
		String due_list[] = req.getParameterValues("chkDue");
		String dues = "";
		String orderNo;
		String dueNo;
		int seqNo = 0;
		double dueAmnt = 0;
		double adjAmnt = 0;
		double payAmnt = 0;
		double pvAmnt = 0;
		double vatAmnt = 0;
		double taxAmnt = 0;
		
		String curOrder = "";
		String lastOrder = "";
		String jobId = "";
		String jobDesc = "";
		Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
		String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543).substring(2, 4);
		String runNo = "";
		String docNo = "";
		String code = "";
		String payDate = "";
		String vat_tax_code = "";
		double vat = 0;
		double tax = 0;
		String venCut = "";
		String mnth = "";
		String year = "";
		String mnthDate = "";
		String allotType = "";
		String select_account = "";
		String account = "";
		String com_acc = "";
		String cus_acc = "";
		double cutPvAmnt = 0;
		double cutVatAmnt = 0;
		double cutTaxAmnt = 0;
		double comAmnt = 0;
		double cusAmnt = 0;
		double com_ps = 100;
		double cut_ps = 0;
		
		int rowEffected = 0;
		StringBuffer sql = new StringBuffer();
		Connection conn = null;
		Statement stmt = null;
		Statement cstmt = null;
		PreparedStatement dstmt = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		ResultSet rsContact = null;
		try {
			if (ds == null)
				getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
			cstmt = conn.createStatement();
			dstmt = conn.prepareStatement("INSERT INTO lan:serv_infdocdt(i_docno, i_seq, i_itmjob, i_itmtype, i_vendor, q_wage_unit, z_wage_price, q_good_unit, z_good_price, z_amount_pay, z_est_amt, c_itmjob, f_itmstatus) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)");
			pstmt = conn.prepareStatement("INSERT INTO lan:serv_infpayment(i_docno, i_seq, i_itmjob, i_vendor, q_wage_unit, z_wage_price, q_good_unit, z_good_price, z_est_amt, c_itmjob, i_itmjob_area, f_itmstatus, d_payment, i_ven_cut, p_cut, p_com, p_add_pay, vat_tax_code, z_amount_pay, z_amount_pv, z_amount_vat, z_amount_tax, pv_no, d_post_pv, z_amount_cut, z_cut_pv, z_cut_vat, z_cut_tax, z_com_amount, z_cus_amount, i_refno, d_post_cut, f_posted, f_tran, f_reject, i_employ_reject, d_reject, i_itmtype, i_company, i_project, i_order, s_due, i_acct_com, i_acct_cus, i_account, i_month, i_team) VALUES(?,?,?,?,?,?,?,?,0,?,?,?,?,'999999',0,100,?,?,?,?,?,?,NULL,NULL,?,?,?,?,0,0,NULL,NULL,?,'Y',NULL,NULL,NULL,?,?,?,?,?,?,?,?,?,?)");
			//SERV_PAYSCHD
			rs = stmt.executeQuery("SELECT d_payment, MONTH(d_contructor) AS PAY_MNTH, YEAR(d_contructor) AS PAY_YEAR FROM lan:serv_payschd WHERE d_contructor >= TODAY ORDER BY d_payment");
			if (rs != null) {
				if (rs.next() == true) {
					payDate = doString.checkString(rs.getString("D_PAYMENT"));
					mnth = doString.displayNumber("00", rs.getInt("PAY_MNTH"));
					year = doString.checkString(rs.getString("PAY_YEAR"));
				}
				rs.close();
				rs=null;
			}
			if (!mnth.equals("")) {
				mnthDate = year+"-"+mnth+"-01";
			}			
			
			//SERVVENVT
			rs = stmt.executeQuery("SELECT ven_no, vat_tax_flag FROM lan:servvenvt WHERE (ven_no = '"+venId+"' OR ven_no = '999999') ORDER BY ven_no");
			if (rs != null) {
				if (rs.next() == true) {
					vat_tax_code = doString.checkString(rs.getString("VAT_TAX_FLAG"));
				}
				rs.close();
				rs=null;
			}			
			if (!vat_tax_code.equals("")) {
				vat = Double.parseDouble(vat_tax_code.substring(0,1));
				tax = Double.parseDouble(vat_tax_code.substring(1));
			}
			venCut = "999999";
			rs = stmt.executeQuery("SELECT d_effective, i_type FROM lan:serv_allot WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND d_effective <= TODAY ORDER BY d_effective DESC");
			if (rs != null) {
				if (rs.next() == true) {
					allotType = doString.checkString(rs.getString("I_TYPE"));
				}
				rs.close();
				rs=null;
			}
			if (allotType.equals("")) {
				throw new Exception("ไม่พบข้อมูลประเภทการจัดสรร");
			}
			
			stmt.executeUpdate("DELETE FROM lan:serv_chklock WHERE i_session = "+sessionId);
			if (due_list != null) {
				for(int i = 0; i < due_list.length; i++) {
					dues = doString.checkString(due_list[i]);
					if (!dues.equals("")) {
						StringTokenizer tokenizer = new StringTokenizer(dues,"-");
						if (tokenizer.countTokens() < 4) continue;
						comId = tokenizer.nextToken();
						projId = tokenizer.nextToken();
						orderNo = tokenizer.nextToken();
						dueNo = tokenizer.nextToken();
						sql.delete(0, sql.length());
						sql.append("INSERT INTO lan:serv_chklock(i_session, user_id, i_docno, i_company, i_project, i_lock, i_chkseq, f_status) VALUES(")
							.append(sessionId)
							.append(", '")
							.append(userId)
							.append("', '")
							.append(orderNo)
							.append("', '")
							.append(comId)
							.append("', '")
							.append(projId)
							.append("', '00000', ")
							.append(dueNo+", 'O')");
						stmt.executeUpdate(sql.toString());
					}
				}// end for
			}
			
			curOrder = "";
			lastOrder = "";
			docNo = "";
			seqNo = 0;
			rsContact = cstmt.executeQuery("SELECT i_company, i_project, i_docno, i_chkseq FROM lan:serv_chklock WHERE i_session = "+sessionId+" ORDER BY i_company, i_project, i_docno, i_chkseq");
			if (rsContact != null) {
				while (rsContact.next() == true) {
					comId = doString.checkString(rsContact.getString("I_COMPANY"));
					projId = doString.checkString(rsContact.getString("I_PROJECT"));
					orderNo = doString.checkString(rsContact.getString("I_DOCNO"));
					curOrder = comId+projId+orderNo;
					jobId = "";
					rs = stmt.executeQuery("SELECT i_job FROM lan:serv_conhd WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+orderNo+"'");
					if (rs != null) {
						if (rs.next() == true) {
							jobId = doString.checkString(rs.getString("I_JOB"));
						}
						rs.close();
						rs=null;
					}
					com_acc = "";
					cus_acc = "";
					rs = stmt.executeQuery("SELECT i_com_acc"+allotType+" FROM lan:serv_infboq WHERE i_itmjob = '"+jobId+"'");
					if (rs != null) {
						if (rs.next() == true) {
							com_acc = doString.checkString(rs.getString(1));
						}
						rs.close();
						rs=null;
					}						
					account = com_acc;
					if (account.equals("")) {
						throw new Exception("ไม่พบข้อมูลรหัสบัญชีรายการ : "+jobId);						
					}
					
					if (!curOrder.equals(lastOrder)) {
						runNo = getRunningNumber(conn, stmt, comId, projId, cur_year);
						docNo = comId+"-"+projId+"-"+cur_year+runNo;
						//SERV_INFDOCHD
						sql.delete(0, sql.length());
						sql.append("INSERT INTO lan:serv_infdochd(i_docno, i_doc_type, i_company, i_project, d_keyin, d_job, f_status, d_appoint, d_est_close, i_service_employ, f_reject, d_start_min, d_complete_max, i_team) VALUES('")
							.append(docNo)
							.append("', 'C', '")
							.append(comId)
							.append("', '")
							.append(projId)
							.append("', CURRENT, TODAY, 'OPN', TODAY, TODAY, '")
							.append(empId)
							.append("', 'N', TODAY, TODAY,'I')");
						rowEffected = stmt.executeUpdate(sql.toString());
						if (rowEffected <= 0) {
							throw new Exception("SERV_INFDOCHD : Wrong insert count");
						}
						//SERV_INFFLOW
						for (int s = 100; s <= 500; s = s + 100) {
							sql.delete(0, sql.length());
							sql.append("INSERT INTO lan:serv_infflow(i_docno, i_vendor, f_itmstatus, d_approve, i_approve) VALUES('")
								.append(docNo)
								.append("', '")
								.append(venId)
								.append("', '"+Integer.toString(s)+"', CURRENT, '")
								.append(userId+"')");
							rowEffected = stmt.executeUpdate(sql.toString());
							if (rowEffected <= 0) {
								throw new Exception("SERV_INFFLOW : Wrong insert count");
							}
						}// end loop flow
						lastOrder = curOrder;
						seqNo = 0;
					}// Change Order
					seqNo++;
					dueNo = Integer.toString(rsContact.getInt("I_CHKSEQ"));
					dueAmnt = 0;
					code = curOrder+dueNo;
					jobDesc = doString.UnicodeToMS874(doString.checkString(req.getParameter("D"+code)));
					adjAmnt = getAmount(doString.checkString(req.getParameter("A"+code),"0"));
					
					//SERV_CONDT
					rs = stmt.executeQuery("SELECT (z_amount + "+doString.displayNumber("#########.00", adjAmnt)+")::DECIMAL(16,2) FROM lan:serv_condt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+orderNo+"' AND s_due = "+dueNo);
					if (rs != null) {
						if (rs.next() == true) {
							dueAmnt = rs.getDouble(1);
						}
						rs.close();
						rs=null;
					}
					rowEffected = stmt.executeUpdate("UPDATE lan:serv_condt SET z_accrue = z_amount WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+orderNo+"' AND s_due = "+dueNo);
					if (rowEffected <= 0) {
						throw new Exception("SERV_CONDT : Wrong update count");
					}
					
					//SERV_INFDOCDT
					dstmt.clearParameters();
					dstmt.setString(1, docNo);
					dstmt.setInt(2, seqNo);
					dstmt.setString(3, jobId);
					dstmt.setString(4, "03");
					dstmt.setString(5, venId);
					dstmt.setDouble(6, 1);
					dstmt.setDouble(7, dueAmnt);
					dstmt.setDouble(8, 0);
					dstmt.setDouble(9, 0);
					dstmt.setDouble(10, dueAmnt);
					dstmt.setDouble(11, 0);
					dstmt.setString(12, jobDesc);
					dstmt.setString(13, "400");
					rowEffected = dstmt.executeUpdate();
					if (rowEffected <= 0) {
						throw new Exception("SERV_INFDOCDT : Wrong insert count");
					}
					
					//SERV_INFPAYMENT
					payAmnt = dueAmnt;
					cutPvAmnt = payAmnt;
					pvAmnt = payAmnt;
					vatAmnt = pvAmnt * (vat/100.00);
					taxAmnt = pvAmnt * (tax/100.00);
					cutVatAmnt = vatAmnt;
					cutTaxAmnt = taxAmnt;
					
					pstmt.clearParameters();
					pstmt.setString(1, docNo);
					pstmt.setInt(2, seqNo);
					pstmt.setString(3, jobId);
					pstmt.setString(4, venId);
					pstmt.setDouble(5, 1);
					pstmt.setDouble(6, dueAmnt);
					pstmt.setDouble(7, 0);
					pstmt.setDouble(8, 0);
					pstmt.setString(9, jobDesc);
					pstmt.setString(10, "");
					pstmt.setString(11, "600");
					pstmt.setString(12, payDate);
					
					pstmt.setDouble(13, 0);
					pstmt.setString(14, vat_tax_code);
					pstmt.setDouble(15,	payAmnt);
					pstmt.setDouble(16, pvAmnt);
					pstmt.setDouble(17, vatAmnt);
					pstmt.setDouble(18, taxAmnt);
					
					pstmt.setDouble(19, payAmnt);
					pstmt.setDouble(20, cutPvAmnt);
					pstmt.setDouble(21, cutVatAmnt);
					pstmt.setDouble(22, cutTaxAmnt);
					
					pstmt.setString(23, "N");
					pstmt.setString(24, "03");
					pstmt.setString(25, comId);
					pstmt.setString(26, projId);
					pstmt.setString(27, orderNo);
					pstmt.setInt(28, Integer.parseInt(dueNo));
					pstmt.setString(29, com_acc);
					pstmt.setString(30, cus_acc);
					pstmt.setString(31, account);
					pstmt.setString(32, mnthDate);
					pstmt.setString(33, "I");
					rowEffected = pstmt.executeUpdate();
					if (rowEffected <= 0) {
						throw new Exception("SERV_INFPAYMENT : Wrong insert count");
					}					
				}// end while contact
				rsContact.close();
				rsContact=null;
			}
			stmt.executeUpdate("DELETE FROM lan:serv_chklock WHERE i_session = "+sessionId);
			
			conn.commit();
			stmt.close();
			cstmt.close();
			dstmt.close();
			pstmt.close();
			conn.close();
			stmt = null;
			cstmt = null;
			dstmt = null;
			pstmt = null;
			conn = null;
			genRedirectCode(out,savePage,successPage,errorCode,otherMsg);
		} catch (Exception e) {
			try {
				if (conn != null)
					conn.rollback();
			} catch (Exception ignore){}
			System.out.println(" ERROR "+mName+" : " + e.getMessage());
			genRedirectCode(out, savePage, errorPage, "99", e.getMessage());
		} finally {
			out.close();
			try {
				if (rs != null)
					rs.close();
				if (stmt != null)
					stmt.close();
				if (cstmt != null)
					cstmt.close();
				if (dstmt != null)
					dstmt.close();
				if (pstmt != null)
					pstmt.close();
				if (conn != null)
					conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");

	}

}