package serv.servlets;
import java.io.*;
import java.util.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.naming.*;

import com.lh.servlet.DBServlet;
import com.lh.exception.InvalidParameterException;
import com.lh.util.doString;

import serv.common.User;
import serv.common.Document;
import serv.common.Period;
import serv.common.Vendor;
/**
 * @version 	1.0
 * @author
 */
public class SetLckInfAmntServlet extends DBServlet {
	private static String cName = "/LHServ/SetLckInfAmntServlet";
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
		User user = (User) obj;
		String empId = user.getEmpId();
		Vendor vendor = (Vendor) session.getAttribute("Vendor");
		String venId = "";
		String venType = "07";
		String pname = "";
		String name = "";
		String sname = "";
		String telephone = "";
		if (vendor != null) {
			venId = vendor.getId();
			pname = vendor.getPreName();
			name = vendor.getName();
			sname = vendor.getSurName();
			telephone = vendor.getTelephone();
		}			
		String successPage = "/LHServ/save_ok.jsp?redirect_url=SERV_InfHome.jsp";
		String errorPage = "";
		String docNo = "";
		String project = req.getParameter("Project");
		String comId = project.substring(0,2);
		String projId = project.substring(2);
		String beg_lock = doString.checkString(req.getParameter("beg_lock"));
		String year = doString.checkString(req.getParameter("Year"));
		String mnth = doString.checkString(req.getParameter("Month"));
		String custType = doString.checkString(req.getParameter("custType"));
		String payId = "";
		String betweenDate[] = req.getParameterValues("chkTime");
		double intRate = Double.parseDouble(doString.checkString(req.getParameter("interest"),"0"));
		intRate = intRate/100.00;
		double interest = 0;
		String startDate = "";
		String endDate = "";
		String params = "?Project="+comId+projId+"&between=&Year="+year+"&Month="+mnth;
		successPage += params;
		errorPage = successPage+"&error=true";
		
		String extra = "";
		int month = 0;
		double price = 0;
		double area = 0;
		double amount = 0;
		String custName = "";
		int intentNo = 0;
		int custNo1 = 0;
		int custNo2 = 0;
		String custId = "";
		String houseNo = "";
		String id_no = "";
		int lorNo = 0;
		int fraction = 0;
		int i=0;
		String sortId = beg_lock;
		String modelId = "";
		String infAmnt = "";
		Calendar rightNow = Calendar.getInstance();
		String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
		int rowEffected = 0;
		boolean match = false;
		StringBuffer sql = new StringBuffer();	
		Connection conn = null;
		Statement stmt = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		try {
			if (ds == null)
				getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
			sql.append("INSERT INTO lan:serv_infhd(i_company, i_project, s_payin, d_keyin, i_staff, i_doc_status, z_recv_infra, i_docno, i_sort, i_lor, n_custo, i_infra, z_infra, z_payin_infra, d_start, d_end, i_inf_custo, i_house, id_no) VALUES('")
				.append(comId)
				.append("', '")
				.append(projId)
				.append("', 0, CURRENT, '")
				.append(empId)
				.append("', 'N', 0, ?,?,?,?,?,?,?,?,?,?,?,?)");
			ps = conn.prepareStatement(sql.toString());
			
			rs = stmt.executeQuery("SELECT i_lor, i_house, id_no FROM lan:serv_inflck WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_sort = '"+sortId+"'");
			if (rs != null) {
				if (rs.next() == true) {
					lorNo = rs.getInt("I_LOR");
					houseNo = doString.checkString(rs.getString("I_HOUSE"));
					id_no = doString.checkString(rs.getString("ID_NO"));
				}
				rs.close();
				rs=null;
			}			
			sql.delete(0, sql.length());
			sql.append("SELECT c.i_sort, c.i_lor, NVL(c.i_cus_intent1,0) AS CUS_INTENT1, NVL(c.i_exp_intent1,0) EXP_INTENT1, NVL(c.i_cus_intent2,0) AS CUS_INTENT2, NVL(c.i_exp_intent2,0) EXP_INTENT2 FROM lan:acscontr c WHERE c.i_company = '")
				.append(comId)
				.append("' AND c.i_project = '")
				.append(projId)
				.append("' AND c.i_sort = '")
				.append(sortId)
				.append("' AND c.d_close_law IS NOT NULL AND c.f_contr IS NULL");
			rs = stmt.executeQuery(sql.toString());
			if (rs != null) {
				if (rs.next() == true) {
					custNo1 = rs.getInt("CUS_INTENT1");
					if (custNo1 == 0) {
						custNo1 = rs.getInt("EXP_INTENT1");
					}
					custNo2 = rs.getInt("CUS_INTENT2");
					if (custNo2 == 0) {
						custNo2 = rs.getInt("EXP_INTENT2");
					}
					intentNo = custNo1;
					if (intentNo == 0) {
						intentNo = custNo2;
					}
				}
				rs.close();
				rs=null;
			}			
			custName = "";
			rs = stmt.executeQuery("SELECT n_prename, n_ncustomer, n_scustomer FROM lan:acxcusto WHERE i_customer = "+Integer.toString(intentNo));
			if (rs != null) {
				if (rs.next() == true) {
					custName = doString.checkString(rs.getString("N_PRENAME"))+" "+doString.checkString(rs.getString("N_NCUSTOMER"))+ " "+doString.checkString(rs.getString("N_SCUSTOMER"));;
				}
				rs.close();
				rs=null;
			}					
			area = 0;
			rs = stmt.executeQuery("SELECT SUM(q_area) AS AREA FROM lan:acxslock WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lor = "+Integer.toString(lorNo));
			if (rs != null) {
				if (rs.next() == true) {
					area = rs.getDouble("AREA");
				}
				rs.close();
				rs=null;
			}			
			if (betweenDate != null) {
				if (betweenDate.length > 0) {
					if (custType.equals("1")) {
						payId = Integer.toString(intentNo);
					} else {
						if (venId.equals("Auto Generate")) {
							venId = cur_year.substring(2)+doString.displayNumber("000", Document.getDocNo(comId, projId, custType, cur_year));
						}
						payId = venId;
					}			
					for (int d=0; d<betweenDate.length; d++) {
						startDate = betweenDate[d].substring(0,10);
						endDate = betweenDate[d].substring(10);					
						rs = stmt.executeQuery("SELECT f_extra, z_price, d_start, d_end FROM lan:serv_infrate WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND d_start = '"+startDate+"' AND d_end = '"+endDate+"'");
						if (rs != null) {
							if (rs.next() == true) {
								extra = doString.checkString(rs.getString("F_EXTRA"));
								price = rs.getDouble("Z_PRICE");
								month = Period.getMonth(rs.getTimestamp("D_START"), rs.getTimestamp("D_END"));
								amount = price*month;
								if (extra.equals("N")) {
									amount = amount * area;
								}
								infAmnt = doString.displayNumber("#########.00", amount);
								i = infAmnt.indexOf(".");
								fraction = Integer.parseInt(infAmnt.substring(i+1));
								infAmnt = infAmnt.substring(0, i);
								amount = Double.parseDouble(infAmnt);
								if (fraction >= 50) {
									amount++;
								}
								interest = amount*intRate;
								amount += interest;
								docNo = comId+projId+"-"+cur_year.substring(2)+doString.displayNumber("0000", Document.getDocNo(comId, projId, "I", cur_year));
								//i_docno, i_sort, i_lor, n_custo, i_infra, z_infra, z_payin_infra, d_start, d_end, i_inf_custo
								ps.setString(1, docNo);
								ps.setString(2, sortId);
								ps.setInt(3, lorNo);
								ps.setString(4, custName);
								ps.setString(5, payId);
								ps.setDouble(6, amount);
								ps.setDouble(7, amount);
								ps.setString(8, startDate);
								ps.setString(9, endDate);
								ps.setString(10, custType);
								ps.setString(11, houseNo);
								ps.setString(12, id_no);
								ps.execute();							
							}
							rs.close();
							rs=null;
						}			
					}// end for
					//SERV_VENPRJ
					if (!custType.equals("1")) {
						sql.delete(0, sql.length());
						rs = stmt.executeQuery("SELECT n_name FROM lan:serv_venprj WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_type = '"+venType+"' AND i_vendor = '"+venId+"'");
						if (rs != null) {
							if (rs.next() == true) { //UPDATE
							sql.append("UPDATE lan:serv_venprj SET n_pname = '")
									.append(pname)
									.append("', n_name = '")
									.append(name)
									.append("', n_sname = '")
									.append(sname)
									.append("', i_tel = '")
									.append(telephone)
									.append("' WHERE i_company = '")
									.append(comId)
									.append("' AND i_project = '")
									.append(projId)	
									.append("' AND i_type = '")
									.append(venType)
									.append("' AND i_vendor = '")
									.append(venId+"'");
							} else {
								sql.append("INSERT INTO lan:serv_venprj(i_company, i_project, i_type, i_vendor, n_pname, n_name, n_sname, i_tel) VALUES('")
									.append(comId)
									.append("', '")
									.append(projId)
									.append("', '")
									.append(venType)
									.append("', '")
									.append(venId)
									.append("', '")
									.append(pname)
									.append("', '")
									.append(name)
									.append("', '")
									.append(sname)
									.append("', '")
									.append(telephone+"')");
							}
							rs.close();
							rs=null;
						}
						stmt.executeUpdate(sql.toString());
					}							
				}
			}
			conn.commit();
			ps.close();
			stmt.close();
			conn.close();
			ps = null;
			stmt = null;
			conn = null;

			// forward to the success page.
			res.sendRedirect(successPage);
		} catch (Exception e) {
			try {
				if (conn != null)
					conn.rollback();
			} catch (SQLException ignore) {}
			System.out.println("ERROR /LHServ/SetLckInfAmntServlet : " + e.getMessage());
			System.out.println("SQL ERROR /LHServ/SetLckInfAmntServlet : " + sql.toString());
			res.sendRedirect(errorPage);
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
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
