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
import serv.common.Vendor;
import serv.common.Document;
/**
 * @version 	1.0
 * @author
 */
public class UpdPayerServlet extends DBServlet {
	private static String cName = "/LHServ/UpdPayerServlet";
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
		String address1 = "";
		String address2 = "";
		if (vendor != null) {
			venId = vendor.getId();
			pname = vendor.getPreName();
			name = vendor.getName();
			sname = vendor.getSurName();
			telephone = vendor.getTelephone();
			address1 = vendor.getAddress1();
			address2 = vendor.getAddress2();
		}		
		String successPage = "/LHServ/save_prnt.jsp?redirect_url=SERV_InfHome.jsp";
		String errorPage = "";
		String docNo = req.getParameter("docNo");
		String custType = doString.checkString(req.getParameter("custType"));
		String customer = doString.checkString(req.getParameter("Customer"),"0");
		String comId = req.getParameter("comId");
		String projId = req.getParameter("projId");
		String sortId = req.getParameter("sortId");
		String project = comId+projId;
		String payId = "";
		String betweenDate = doString.checkString(req.getParameter("between"));
		String params = "?Project="+project+"&between="+betweenDate+"&Project="+project+"&beg_lock="+sortId;
		successPage += params;
		errorPage = successPage+"&error=true";
		Calendar rightNow = Calendar.getInstance();
		String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);		
		int rowEffected = 0;
		StringBuffer sql = new StringBuffer();	
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		try {
			if (ds == null)
				getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
			if (custType.equals("1")) {
				payId = customer;
			} else {
				if (venId.equals("Auto Generate")) {
					venId = cur_year.substring(2)+doString.displayNumber("000", Document.getDocNo(comId, projId, custType, cur_year));
				}
				payId = venId;
			}
			sql.append("UPDATE lan:serv_infhd SET i_inf_custo = '")
					.append(custType)
					.append("', i_infra = '")
					.append(payId)
					.append("', i_staff = '")
					.append(empId)
					.append("' WHERE i_company = '")
					.append(comId)
					.append("' AND i_project = '")
					.append(projId)	
					.append("' AND i_docno = '")
					.append(docNo+"'");
			rowEffected = stmt.executeUpdate(sql.toString());
			if (rowEffected != 1) {
				throw new Exception("SERV_INFHD : Wrong insert count");
			}
						
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
							.append("', a_addr1 = '")
							.append(address1)
							.append("', a_addr2 = '")
							.append(address2)
							.append("' WHERE i_company = '")
							.append(comId)
							.append("' AND i_project = '")
							.append(projId)	
							.append("' AND i_type = '")
							.append(venType)
							.append("' AND i_vendor = '")
							.append(venId+"'");
					} else {
						sql.append("INSERT INTO lan:serv_venprj(i_company, i_project, i_type, i_vendor, n_pname, n_name, n_sname, i_tel, a_addr1, a_addr2) VALUES('")
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
							.append(telephone)
							.append("', '")
							.append(address1)
							.append("', '")																			
							.append(address2+"')");
					}
					rs.close();
					rs=null;
				}
				rowEffected = stmt.executeUpdate(sql.toString());
				if (rowEffected != 1) {
					throw new Exception("SERV_VENPRJ : Wrong insert count");
				}
			}							
			conn.commit();
			stmt.close();
			conn.close();
			stmt = null;
			conn = null;

			// forward to the success page.
			res.sendRedirect(successPage);
		} catch (Exception e) {
			try {
				if (conn != null)
					conn.rollback();
			} catch (SQLException ignore) {}
			System.out.println("ERROR /LHServ/UpdPayerServlet : " + e.getMessage());
			System.out.println("SQL ERROR /LHServ/UpdPayerServlet : " + sql.toString());
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
