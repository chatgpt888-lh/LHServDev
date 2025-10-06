package serv.servlets;

import java.io.*;
import java.sql.*;

import javax.servlet.ServletException;
import javax.servlet.http.*;

import com.lh.servlet.DBServlet;
import com.lh.util.doString;

public class AddLockDetServlet extends DBServlet {
	private static String cName = "/LHServ/AddLockDetServlet.java";

	public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		String mName = new String(cName + ".performTask: ");
		System.out.println(mName + "start.");
		HttpSession session = req.getSession(false);
		if (session == null) {
			res.sendRedirect("/LHServ/warning.htm");
			return;
		}
		Object obj = session.getAttribute("USER");
		if (obj == null) {
			res.sendRedirect("/LHServ/warning.htm");
			return;
		}
		
		String comId = "", projId = "", f_separate = "";
		
		String project = doString.checkString(req.getParameter("Project"), "-");
		if (!project.equals("-")) {
			comId = project.substring(0, 2);
			projId = project.substring(2, 5);
		}
		String Act = doString.checkString(req.getParameter("Act"), "-");
		String Lock = doString.checkString(req.getParameter("Lock"), "-");
		String flag = doString.checkString(req.getParameter("flag"), "-");
		
		String start_day = Integer.toString(Integer.parseInt(req.getParameter("start_day")));
		String start_mnth = doString.checkString(req.getParameter("start_mnth"), "-");
		String start_year = doString.checkString(req.getParameter("start_year"), "-");
		String d_end = Integer.toString(Integer.parseInt(start_year)-543) + "-" + start_mnth + "-" + start_day;
		
		String house = doString.checkString(req.getParameter("house"), "-");
		
		String cus_name = doString.checkString(req.getParameter("cus_name"), "-");
		cus_name = doString.UnicodeToMS874(cus_name);
		
		String id_no = doString.checkString(req.getParameter("id_no"), "");
		
		String address1 = doString.checkString(req.getParameter("address1"), "-");
		address1 = doString.UnicodeToMS874(address1);
		
		String address2 = doString.checkString(req.getParameter("address2"), "-");
		address2 = doString.UnicodeToMS874(address2);
		
		String address3 = doString.checkString(req.getParameter("address3"), "-");
		address3 = doString.UnicodeToMS874(address3);
		String addr = doString.checkString(req.getParameter("addr"), "N");
		
		String nation = doString.checkString(req.getParameter("Nation"), "");
		String zipcode = doString.checkString(req.getParameter("zipcode"), "");
		
		int iLor = Integer.parseInt(doString.checkString(req.getParameter("iLor")));
		double area = Double.parseDouble(doString.checkString(req.getParameter("area"), "0"));
		if (iLor == 0) {
			f_separate = "Y";
		} else {
			f_separate = "N";
		}
		
		String email = doString.checkString(req.getParameter("email"), "");
		String corp = doString.checkString(req.getParameter("corp"), "");
		if (corp.equals("Y")) {
			corp = "'"+corp+"'";
		} else {
			corp = "NULL";
		}
		
		String successPage = "/LHServ/save_ok.jsp?redirect_url=SERV_LockDet.jsp?Project=" + project;
		
		StringBuffer sql = new StringBuffer();
		Connection conn = null;
		Statement stmt = null;
		Statement stmt1 = null;
		ResultSet rs = null;
		try {
			if (ds == null)
				getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(1);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
			stmt1 = conn.createStatement();
			
			if (Act.equals("Add")) {
				sql.delete(0, sql.length());
				sql.append("INSERT INTO lan:serv_inflck (i_company, i_project, i_lor, ")
						.append("i_sort, d_end, i_house, q_area, n_customer, a_address1, ")
						.append("a_address2, a_address3, f_address, i_zipcode, i_nation, id_no, f_separate, i_email, f_corp) VALUES ('")
						.append(comId)
						.append("', '")
						.append(projId)
						.append("', ")
						.append(iLor)
						.append(", '")
						.append(Lock)
						.append("', '")
						.append(d_end)
						.append("', '")
						.append(house)
						.append("', ")
						.append(area)
						.append(", '")
						.append(cus_name)
						.append("', '")
						.append(address1)
						.append("', '")
						.append(address2)
						.append("', '")
						.append(address3)
						.append("', '")
						.append(addr)
						.append("', '")
						.append(zipcode)
						.append("', '")
						.append(nation)
						.append("', '")
						.append(id_no)
						.append("', '")
						.append(f_separate)
						.append("', '")
						.append(email)
						.append("', ")
						.append(corp)
						.append(")");
				stmt1.executeUpdate(sql.toString());
				
				if (iLor == 0) {
					sql.delete(0, sql.length());
					sql.append("UPDATE lan:serv_inflck SET f_separate = '").append(f_separate)
							.append("' WHERE i_company = '").append(comId).append("' AND i_project = '").append(projId)
							.append("' AND i_sort = '").append(Lock).append("'");
					stmt1.executeUpdate(sql.toString());
				}
			}
			if (Act.equals("Edit")) {
				sql.delete(0, sql.length());
				sql.append("UPDATE lan:serv_inflck SET d_end = '").append(d_end)
						.append("', i_house = '").append(house)
						.append("', q_area = ").append(area)
						.append(", n_customer = '").append(cus_name)
						.append("', id_no = '").append(id_no)
						.append("', a_address1 = '").append(address1)
						.append("', a_address2 = '").append(address2)
						.append("', a_address3 = '").append(address3)
						.append("', f_address = '").append(addr)
						.append("', i_zipcode = '").append(zipcode)
						.append("', i_nation = '").append(nation)
						.append("', f_separate = '").append(f_separate)
						.append("', i_email = '").append(email)
						.append("', f_corp = ").append(corp)
						.append(" WHERE i_company = '").append(comId)
						.append("' AND i_project = '").append(projId)
						.append("' AND i_sort = '").append(Lock)
						.append("' AND i_lor = ").append(iLor);
				stmt1.executeUpdate(sql.toString());
			}
			
			conn.commit();
			
			stmt.close();
			stmt1.close();
			conn.close();
			
			stmt = null;
			stmt1 = null;
			conn = null;
			res.sendRedirect(successPage);
		} catch (Exception e) {
			try {
				if (conn != null)
					conn.rollback();
			} catch (SQLException ignore) {}
			System.out.println("ERROR /LHServ/AddLockDetServlet : " + e.getMessage());
		} finally {
			try {
				if (rs != null)
					rs.close();
				if (stmt != null)
					stmt.close();
				if (stmt1 != null)
					stmt1.close();
				if (conn != null)
					conn.close();
			} catch (SQLException sQLException) {
			}
		}
		System.out.println(mName + "end.");
	}
}