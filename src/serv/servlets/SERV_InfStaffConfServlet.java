package serv.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.Calendar;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import serv.common.Constants;
import serv.common.User;

import com.lh.exception.InvalidParameterException;
import com.lh.servlet.DBServlet;
import com.lh.util.*;

public class SERV_InfStaffConfServlet  extends DBServlet  {
	 
	private void genRedirectCode(PrintWriter out,String page,String redirect,String error,String otherMsg) {
		out.println("<form method='post' action='"+page+"'>");		
		out.println("<input type='hidden' name='error' value='"+error+"'>");
		out.println("<input type='hidden' name='other_msg' value='"+doString.MS874ToUnicode(otherMsg)+"'>");
		out.println("<input type='hidden' name='redirect_url' value='"+doString.MS874ToUnicode(redirect)+"'>");		
		out.println("<script> document.forms[0].submit();</script>");
		out.println("</form>");		
	}
	 
	public void performTask(HttpServletRequest request, HttpServletResponse response)throws ServletException, IOException {
		String mName = new String(this.getClass().getName() + ".performTask: ");
		System.out.println(mName + "start.");		
		//-----======= Check Login session =======-----//
		HttpSession session = request.getSession(false);
		if (session == null) {
			//---===== No Session , redirect to warning =======---// 
			response.sendRedirect(Constants.WARNING_PAGE);
			return;
		}
		
		Object obj = session.getAttribute("USER");
		if (obj == null) {
		//---===== Can't get User Login , redirect to warning ======---// 
			response.sendRedirect(Constants.WARNING_PAGE);
			return;
		}
		User user = (User)obj;
		String userId = user.getUserID();
		
		//----===================================----//	
		response.setContentType("text/html; charset=TIS620");
		PrintWriter out = response.getWriter();
		
	
		//------ header table ----//
		String i_docno  = doString.checkString(request.getParameter("i_docno"));	//
		String itmType  = doString.checkString(request.getParameter("itemType"));	//
		String i_vendor = doString.checkString(request.getParameter("i_vendor"));	//
		String selProj  = doString.checkString(request.getParameter("selProj"));	//
		String empId = doString.checkString(request.getParameter("empId"));			//
		String d_payment = "";
		String mode = doString.checkString(request.getParameter("mode"));			//approve, reject
		
		
		//--list detail --//
		String[] i_seq = request.getParameterValues("i_seq");		
		String[] i_itmjob = request.getParameterValues("i_itmjob");
		String[] i_itmtype = request.getParameterValues("itmtype");
		String[] i_type = request.getParameterValues("iType");
		String[] vendor_cut = request.getParameterValues("vendor_cut");
		String[] percent_cut = request.getParameterValues("percent_cut");
		String[] wrong_type = request.getParameterValues("wrong_type");
		String comId = i_docno.substring(0,2);
		String projId = i_docno.substring(3,6);
		String iType = "";
		String mnth = "";
		String year = "";
		String mnthDate = "";
		String allotType = "";
		String select_account = "";
		String account = "";
		String com_acc = "";
		String cus_acc = "";
		double z_cut_pv = 0;
		double z_amount_pay = 0;
		double z_amount_pv = 0;
		double z_cut_vat = 0;
		double z_cut_tax = 0;
		double z_amount_com = 0;
		double z_amount_cus = 0;
		double com_ps = 0;
		String vat_tax_code = "";
		double vat = 0;
		double tax = 0;
		
		String i_comment = doString.UnicodeToMS874(doString.checkString(request.getParameter("i_comment"),""));
		i_comment = doString.TextToString(i_comment);
		
		//------ forward page --------//
		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_INFStaff_List.jsp?itmType="+itmType;
		String errorPage = "SERV_INFStaff_Conf.jsp?error=1&itmType="+itmType+"&i_vendor="+i_vendor+"&i_docno="+i_docno; 		
		String otherMsg = "";
		String errorCode = "";	
		
		
		//-------------- database connection -----// 
		doString str = new doString();		
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		int rowEffected = 0;
		try {
			if (ds == null)
				getDS();

			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
			 
			//--------- Get vat_tax_code --------//
			sql.delete(0,sql.length());
			sql.append("SELECT vat_tax_flag, ven_no FROM lan:servvenvt WHERE (ven_no = '"+i_vendor+"' or ven_no ='999999') ORDER BY ven_no");                                                              
			rs = stmt.executeQuery(sql.toString());                             
			if (rs.next()) {
				vat_tax_code = rs.getString("vat_tax_flag").trim();
			}
			rs.close();                            
	
			if(vat_tax_code.length()>0){
				vat = Double.parseDouble(vat_tax_code.substring(0,1));
				tax = Double.parseDouble(vat_tax_code.substring(1));
			}
			
			
			if(mode.equals("APPROVE")){//---approve
				
				//============ UPDATE SERV_INFPAYMENT TABLE ============//
				for(int i=0; i<i_itmjob.length;i++){
					double percentCut = 0;
					
					//---- get z_amount_pay ----//
					z_amount_pay = 0;
					z_amount_pv = 0;
					z_cut_pv = 0;
					z_cut_vat = 0;
					z_cut_tax = 0;
					z_amount_com = 0;
					z_amount_cus = 0;
					mnth = "";
					year = "";	
					mnthDate = "";
					d_payment = "";
					iType = doString.checkString(i_type[i]);
					
					if (itmType.equals("02") || iType.equals("02")) { //Public
						vendor_cut[i] = "999999";
					}
					sql.delete(0,sql.length());
					sql.append("SELECT p_add_pay, z_amount_pay, d_payment, z_amount_pv FROM lan:serv_infpayment WHERE i_docno='"+i_docno+"' AND i_seq = "+i_seq[i]+" AND i_vendor='"+i_vendor+"' AND i_itmjob='"+i_itmjob[i]+"' AND f_itmstatus='500'");	
					rs = stmt.executeQuery(sql.toString());
					if (rs.next() == true) {
						z_amount_pay = rs.getDouble("z_amount_pay");
						z_amount_pv = rs.getDouble("z_amount_pv");
						d_payment = doString.checkString(rs.getString("d_payment"));
						if(vendor_cut[i].equals("999999")){ //Company
							percentCut = 0;
							z_cut_pv = z_amount_pay + (z_amount_pay *(rs.getDouble("p_add_pay")/100.00));
						} else {
							int percentCutSize = percent_cut[i].indexOf("%");
							percentCut = Double.parseDouble(percent_cut[i].substring(0,percentCutSize));
							z_cut_pv = z_amount_pay + (z_amount_pay * (percentCut/100.00));
						}
						z_cut_vat = z_cut_pv * (vat/100.00);
						z_cut_tax = z_cut_pv * (tax/100.00);
					}
					rs.close();
					rs=null;
					
					rs = stmt.executeQuery("SELECT MONTH(d_contructor) AS PAY_MNTH, YEAR(d_contructor) AS PAY_YEAR FROM lan:serv_payschd WHERE d_payment = '"+d_payment+"'");
					if (rs != null) {
						if (rs.next() == true) {
							mnth = doString.displayNumber("00", rs.getInt("PAY_MNTH"));
							year = doString.checkString(rs.getString("PAY_YEAR"));
						}
						rs.close();
						rs=null;
					}
					if (!mnth.equals("")) {
						mnthDate = year+"-"+mnth+"-01";
					}
					z_amount_com = 0;
					z_amount_cus = 0;
					com_ps = 0;
					com_acc = "";
					cus_acc = "";
					if (itmType.equals("02") || iType.equals("02")) { //Public
						allotType = "";
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
						select_account = "i_com_acc"+allotType+", i_cus_acc"+allotType;
						rs = stmt.executeQuery("SELECT "+select_account+" FROM lan:serv_infboq WHERE i_itmjob = '"+doString.checkString(i_itmjob[i])+"'");
						if (rs != null) {
							if (rs.next() == true) {
								com_acc = doString.checkString(rs.getString(1));
								cus_acc = doString.checkString(rs.getString(2));
							}
							rs.close();
							rs=null;
						}						
						com_ps = 0;
						if (com_acc.equals("")) {
							if (cus_acc.equals("")) {
								throw new Exception("ไม่พบข้อมูลรหัสบัญชีรายการซ่อม : "+doString.checkString(i_itmjob[i]));
							} else {
								com_ps = 0;
							}
						} else {
							if (cus_acc.equals("")) {
								com_ps = 100;
							} else { //Share
								rs = stmt.executeQuery("SELECT z_cal_constr, z_cal_trans FROM lan:avs_area WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_month = '"+mnth+"' AND i_year = '"+year+"'");
								if (rs != null) {
									if (rs.next() == true) {
										com_ps = rs.getDouble("Z_CAL_CONSTR");
									}
									rs.close();
									rs=null;
								}
							}
						}
						z_amount_com = (z_amount_pv * com_ps)/100.00;
						z_amount_cus = z_amount_pv - z_amount_com;
					}
					
					//Infra
					if ((itmType.equals("01")) && (iType.equals("01"))) {
						com_ps = 100;
						allotType = "";
						cus_acc = "";
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
						select_account = "i_com_acc"+allotType+", i_cus_acc"+allotType;
						rs = stmt.executeQuery("SELECT "+select_account+" FROM lan:serv_infboq WHERE i_itmjob = '"+doString.checkString(i_itmjob[i])+"'");
						if (rs != null) {
							if (rs.next() == true) {
								com_acc = doString.checkString(rs.getString(1));
							}
							rs.close();
							rs=null;
						}						
					}////////////////////// End If Infra
					
					if (com_ps == 0) {
						com_acc = "";
					}
					account = com_acc;
					if (account.equals("")) account = cus_acc;
					
					if (account.equals("")) {
						throw new Exception("ไม่พบข้อมูลรหัสบัญชีรายการซ่อม : "+doString.checkString(i_itmjob[i]));						
					}
					sql.delete(0,sql.length());
					sql.append("UPDATE lan:serv_infpayment SET i_ven_cut = '")
					.append(doString.checkString(vendor_cut[i]))
					
					.append("', p_cut = ")
					.append(percentCut)
					
					.append(", z_amount_cut = ")
					.append(z_amount_pay)
					
					.append(", z_cut_pv = ")
					.append(z_cut_pv)
					
					.append(", z_cut_vat = ")
					.append(z_cut_vat)
					
					.append(", z_cut_tax = ")
					.append(z_cut_tax)

					.append(", p_com = ")
					.append(doString.displayNumber("###.00", com_ps))
					
					.append(", z_com_amount = ")
					.append(doString.displayNumber("#########.00", z_amount_com))
					
					.append(", z_cus_amount = ")
					.append(doString.displayNumber("#########.00", z_amount_cus))
					
					.append(", f_remark = '")
					.append(doString.checkString(wrong_type[i]))		

					.append("', i_itmtype = '")
					.append(itmType)	

					.append("', i_type = '")
					.append(iType)	
					
					.append("', i_month = '")
					.append(mnthDate)	
					
					.append("', i_acct_com = '")
					.append(com_acc)
					
					.append("', i_acct_cus = '")
					.append(cus_acc)	

					.append("', i_account = '")
					.append(account)	
					
					.append("', cp_no = ")
					.append("null")					
					
					.append(", i_employ_post = ")
					.append("null")	
					
					.append(", d_post_ca = ")
					.append("null")	
					
					.append(", f_itmstatus = '")
					.append("600")	
	
					.append("', f_tran = 'Y' WHERE i_docno = '")
					.append(i_docno)
					.append("' AND i_seq = ")
					.append(i_seq[i])
					.append(" AND i_vendor = '")
					.append(i_vendor)	
					.append("' AND i_itmjob = '")
					.append(doString.checkString(i_itmjob[i]))
					.append("' AND f_itmstatus = '500'");
					rowEffected = stmt.executeUpdate(sql.toString());
					if (rowEffected != 1) {
						throw new Exception("SERV_INFPAYMENT : Wrong update count");
					}
				}// end for
				//============ INSERT SERV_INFFLOW TABLE ============//
				stmt.executeUpdate("DELETE FROM lan:serv_infflow WHERE i_docno = '"+i_docno+"' AND i_vendor ='"+i_vendor+"' AND f_itmstatus >= '500'");
				
				sql.delete(0,sql.length());
				sql.append("INSERT INTO lan:serv_infflow(i_docno, i_vendor, f_itmstatus, d_approve, i_approve, f_reject, c_reject )"+
							"VALUES(?,?,?,CURRENT,?,null,null)" );
				pstmt = conn.prepareStatement(sql.toString());
				pstmt.setString(1, 		i_docno);				//i_docno
				pstmt.setString(2, 		i_vendor);				//i_vendor 
				pstmt.setString(3, 		"500");					//f_itmstatus
				pstmt.setString(4, 		userId);				//i_approve
				pstmt.executeUpdate();
				pstmt.close(); 
			} else {//--reject 
				//----get d_payment ----//
				sql.delete(0,sql.length());
				sql.append("SELECT d_payment FROM lan:serv_payschd WHERE d_contructor >=TODAY ORDER BY d_payment");	
				rs = stmt.executeQuery(sql.toString());
				if (rs.next()) {
					Calendar pay = Calendar.getInstance();
					Timestamp tmp = rs.getTimestamp("d_payment"); 
					if (tmp!=null)  {
						pay.setTime(tmp);    
						int tYear = pay.get(Calendar.YEAR);
						if (tYear>2400) tYear-= 543;
						d_payment += tYear+"-"+str.createID(pay.get(Calendar.MONTH)+1,2);
						d_payment += "-"+str.createID(pay.get(Calendar.DATE),2);
					}
				}
				rs.close();
				
				//============ UPDATE SERV_INFPAYMENT TABLE ============//
				sql.delete(0,sql.length());
				sql.append("UPDATE lan:serv_infpayment SET d_payment = '")
				.append(d_payment)
				.append("', f_itmstatus = '400")
				.append("' WHERE i_docno = '")
				.append(i_docno)
				.append("' AND i_vendor = '")
				.append(i_vendor)	
				.append("' AND f_itmstatus = '500'");
				rowEffected = stmt.executeUpdate(sql.toString());
				if (rowEffected == 0) {
					throw new Exception("SERV_INFFLOW : Wrong insert count");
				}
				
				//============ INSERT SERV_INFFLOW TABLE ============//
				stmt.executeUpdate("DELETE FROM lan:serv_infflow WHERE i_docno = '"+i_docno+"' AND i_vendor ='"+i_vendor+"' AND f_itmstatus >= '500'");
				
				sql.delete(0,sql.length());
				sql.append("INSERT INTO lan:serv_infflow(i_docno, i_vendor, f_itmstatus, d_approve, i_approve, f_reject, c_reject) "+
							"VALUES(?,?,?,current,?,?,?)" );
				pstmt = conn.prepareStatement(sql.toString());
				pstmt.setString(1, 		i_docno);				//i_docno
				pstmt.setString(2, 		i_vendor);				//i_vendor 
				pstmt.setString(3, 		"500");					//f_itmstatus
				pstmt.setString(4, 		userId);				//i_approve
				pstmt.setString(5, 		"Y");					//f_reject
				pstmt.setString(6, 		i_comment);				//f_reject
				pstmt.executeUpdate();
				pstmt.close(); 
			}
			//conn.rollback();
			conn.commit();
			pstmt.close();
			stmt.close();
			conn.close();
			pstmt=null;
			stmt = null;
			conn = null;
			genRedirectCode(out,savePage,successPage,errorCode,otherMsg);
		} catch (Exception e) {
			try {
				if (conn != null)
					conn.rollback();
			} catch (Exception ignore) {}
			if (e instanceof InvalidParameterException) {
				showError(out, doString.UnicodeToMS874(e.getMessage()));
			} else {
           		System.out.println(" ERROR "+mName+" : " + e.getMessage());
				System.out.println(" ERROR "+mName+" SQL : " + sql.toString());
			}
			System.out.println("error = "+errorPage);
			genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ "+e.getMessage());
			
		} finally {
			out.close();
			try {
				if (rs!=null) rs.close(); 
				if (stmt != null) stmt.close();
				if (pstmt != null) pstmt.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");
	}
}
