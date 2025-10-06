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
/**
 * @version 	1.0
 * @author
 */
public class SetInfAmntServlet extends DBServlet {
	private static String cName = "/LHServ/SetInfAmntServlet";
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
		String successPage = "/LHServ/save_ok.jsp?redirect_url=SERV_InfHome.jsp";
		String errorPage = "";
		String docNo = "";
		String project = req.getParameter("Project");
		String comId = project.substring(0,2);
		String projId = project.substring(2);
		String beg_lock = doString.checkString(req.getParameter("beg_lock"));
		String end_lock = doString.checkString(req.getParameter("end_lock"));
		String restrict = "";
		if (!beg_lock.equals("")) {
			if (end_lock.equals("")) {
				restrict = "AND (i_sort = '"+beg_lock+"')";
			} else {
				restrict = "AND (i_sort >= '"+beg_lock+"' AND i_sort <= '"+end_lock+"')";
			}
		}
		String year = doString.checkString(req.getParameter("Year"));
		String mnth = doString.checkString(req.getParameter("Month"));
		String betweenDate = doString.checkString(req.getParameter("between"));
		int i = betweenDate.indexOf("/");
		String startDate = betweenDate.substring(0,i);
		String endDate = betweenDate.substring(i+1);
		String params = "?Project="+comId+projId+"&between="+betweenDate+"&Year="+year+"&Month="+mnth;
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
		String id_no = "";
		String houseNo = "";
		int lorNo = 0;
		int fraction = 0;
		String sortId = "";
		String separate = "";
		String modelId = "";
		String custType = "";
		String infAmnt = "";
		Calendar rightNow = Calendar.getInstance();
		String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
		cur_year = year;
		
		int rowEffected = 0;
		boolean match = false;
		StringBuffer sql = new StringBuffer();	
		Connection conn = null;
		Statement stmt = null;
		Statement cstmt = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		ResultSet rsContr = null;
		try {
			if (ds == null)
				getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
			cstmt = conn.createStatement();
			
			sql.append("INSERT INTO lan:serv_infhd(i_company, i_project, s_payin, d_keyin, d_start, d_end, i_inf_custo, i_staff, i_doc_status, z_recv_infra, i_docno, i_sort, i_lor, n_custo, i_infra, z_infra, z_payin_infra, i_house, id_no) VALUES('")
				.append(comId)
				.append("', '")
				.append(projId)
				.append("', 0, CURRENT, '")
				.append(startDate)
				.append("', '")
				.append(endDate)
				.append("', '1', '")
				.append(empId)
				.append("', 'N', 0, ?,?,?,?,?,?,?,?,?)");
			ps = conn.prepareStatement(sql.toString());
			
			rs = stmt.executeQuery("SELECT f_extra, z_price, d_start, d_end FROM lan:serv_infrate WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND d_start = '"+startDate+"' AND d_end = '"+endDate+"'");
			if (rs != null) {
				if (rs.next() == true) {
					extra = doString.checkString(rs.getString("F_EXTRA"));
					price = rs.getDouble("Z_PRICE");
					month = Period.getMonth(rs.getTimestamp("D_START"), rs.getTimestamp("D_END"));
				}
				rs.close();
				rs=null;
			}
//System.out.println("SELECT i_sort, i_lor, NVL(q_area,0) AS AREA, n_customer, f_separate, i_house, id_no FROM lan:serv_inflck WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' "+restrict+" AND d_end < '"+startDate+"' ORDER BY i_sort");
			rsContr = cstmt.executeQuery("SELECT i_sort, i_lor, NVL(q_area,0) AS AREA, n_customer, f_separate, i_house, id_no FROM lan:serv_inflck WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' "+restrict+" AND d_end < '"+startDate+"' ORDER BY i_sort");
			if (rsContr != null) {
				while (rsContr.next() == true) {
					sortId = doString.checkString(rsContr.getString("I_SORT"));
					lorNo = rsContr.getInt("I_LOR");
					separate = doString.checkString(rsContr.getString("F_SEPARATE"));
					houseNo = doString.checkString(rsContr.getString("I_HOUSE"));
					id_no = doString.checkString(rsContr.getString("ID_NO"));
					custName = doString.checkString(rsContr.getString("N_CUSTOMER"));
                	if (!custName.equals("")) {
                		i = custName.indexOf("(");
                		if (i > 0) {
                			custName = custName.substring(0,i);
                		}
                	}
					if (lorNo == 0) {
						rs = stmt.executeQuery("SELECT i_lor FROM lan:acscontr WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_sort = '"+sortId+"' AND d_close_law IS NOT NULL AND f_contr IS NULL");
						if (rs != null) {
							if (rs.next() == true) {
								lorNo = rs.getInt("I_LOR");
							}
							rs.close();
							rs=null;
						}
					}					
					
					intentNo = 0;
					custNo1 = 0;
					custNo2 = 0;
					rs = stmt.executeQuery("SELECT NVL(i_cus_intent1,0) AS CUS_INTENT1, NVL(i_exp_intent1,0) EXP_INTENT1, NVL(i_cus_intent2,0) AS CUS_INTENT2, NVL(i_exp_intent2,0) EXP_INTENT2 FROM lan:acscontr WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lor = "+Integer.toString(lorNo)+" AND d_close_law IS NOT NULL AND f_contr IS NULL");
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
					custType = "1";
					custId = Integer.toString(intentNo);
					
					match = false;
					rs = stmt.executeQuery("SELECT i_lor FROM lan:serv_infhd WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_sort = '"+sortId+"' AND i_house = '"+houseNo+"' AND d_start = '"+startDate+"' AND d_end = '"+endDate+"'");					
					if (rs != null) {
						if (rs.next() == true) {
							match = true;
						}
						rs.close();
						rs=null;
					}
					if (!match) {
						if (custName.equals("")) {
							rs = stmt.executeQuery("SELECT n_prename, n_ncustomer, n_scustomer FROM lan:acxcusto WHERE i_customer = "+custId);
							if (rs != null) {
								if (rs.next() == true) {
									custName = doString.checkString(rs.getString("N_PRENAME"))+" "+doString.checkString(rs.getString("N_NCUSTOMER"))+ " "+doString.checkString(rs.getString("N_SCUSTOMER"));;
									custName = doString.UnicodeToMS874(custName);
								}
								rs.close();
								rs=null;
							}
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
						if (separate.equals("Y")) {
							area = rsContr.getDouble("AREA");
						}
						
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
						docNo = comId+projId+"-"+cur_year.substring(2)+doString.displayNumber("0000", Document.getDocNo(comId, projId, "I", cur_year));
/*						
						System.out.println(docNo);
						sql.delete(0,sql.length());
						sql.append("INSERT INTO lan:serv_infhd(i_company, i_project, s_payin, d_keyin, d_start, d_end, i_inf_custo, i_staff, i_doc_status, z_recv_infra, i_docno, i_sort, i_lor, n_custo, i_infra, z_infra, z_payin_infra, i_house, id_no) VALUES('")
							.append(comId)
							.append("', '")
							.append(projId)
							.append("', 0, CURRENT, '")
							.append(startDate)
							.append("', '")
							.append(endDate)
							.append("', '1', '")
							.append(empId)
							.append("', 'N', 0, '")
							.append(docNo)
							.append("', '")
							.append(sortId)
							.append("', ")
							.append(Integer.toString(lorNo))
							.append(", '")
							.append(custName)
							.append("', '")
							.append(custId)
							.append("', ")
							.append(doString.displayNumber("#########.00", amount))
							.append(", ")
							.append(doString.displayNumber("#########.00", amount))
							.append(", '")
							.append(houseNo)
							.append("', '")
							.append(id_no+"')");
						System.out.println(sql.toString());						
						stmt.executeUpdate(sql.toString());
*/
						
						//i_docno, i_sort, i_lor, n_custo, i_infra, z_infra, z_payin_infra
						ps.setString(1, docNo);
						ps.setString(2, sortId);
						ps.setInt(3, lorNo);
						ps.setString(4, custName);
						ps.setString(5, custId);
						ps.setDouble(6, amount);
						ps.setDouble(7, amount);
						
						ps.setString(8, houseNo);
						ps.setString(9, id_no);
						ps.execute();
					}
				}// end while
				rsContr.close();
				rsContr=null;
			}
			conn.commit();
			ps.close();
			stmt.close();
			cstmt.close();
			conn.close();
			ps = null;
			stmt = null;
			cstmt = null;
			conn = null;

			// forward to the success page.
			res.sendRedirect(successPage);
		} catch (Exception e) {
			try {
				if (conn != null)
					conn.rollback();
			} catch (SQLException ignore) {}
			System.out.println("ERROR /LHServ/SetInfAmntServlet : " + e.getMessage());
			System.out.println("LOCK ERROR /LHServ/SetInfAmntServlet : " + sortId);
			System.out.println("SQL ERROR /LHServ/SetInfAmntServlet : " + sql.toString());
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
