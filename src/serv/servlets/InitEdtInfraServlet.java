package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.naming.*;

import com.lh.servlet.DBServlet;
import com.lh.util.doString;

import serv.common.User;
import serv.common.Vendor;
public class InitEdtInfraServlet extends DBServlet {
  private static String cName = "/LHServ/InitEdtInfraServlet";
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
	String docNo = doString.checkString(req.getParameter("docNo"));
	String mode = doString.checkString(req.getParameter("Mode"));
	String comId = "";
	String projId = "";
	String custType = "";
	String custId = "";
	String successPage = "/LHServ/SERV_Edt_Infra.jsp?docNo="+docNo;
	if (mode.equals("A")) {
		successPage = "/LHServ/SERV_Add_Inflck.jsp";
	}
	if (mode.equals("Y")) {
		successPage = "/LHServ/SERV_Add_YRLck.jsp";
	}
	
	Vendor vendor = new Vendor();
	int rowEffected = 0;
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    try {
        if (ds == null)
            getDS();
        conn = ds.getConnection();
        conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
        conn.setAutoCommit(true);
        stmt = conn.createStatement();
		rs = stmt.executeQuery("SELECT i_company, i_project, i_inf_custo, i_infra FROM lan:serv_infhd WHERE i_docno = '"+docNo+"'");
		if (rs != null) {
			if (rs.next() == true) {
				comId = doString.checkString(rs.getString("I_COMPANY"));
				projId = doString.checkString(rs.getString("I_PROJECT"));
				custType = doString.checkString(rs.getString("I_INF_CUSTO"));
				custId = doString.checkString(rs.getString("I_INFRA"));
			}
			rs.close();
			rs=null;
		}
		if (custType.equals("3")) {
			rs = stmt.executeQuery("SELECT n_pname, n_name, n_sname, i_tel FROM lan:serv_venprj WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_type = '07' AND i_vendor = '"+custId+"'");
			if (rs != null) {
				if (rs.next() == true) {
					vendor.setId(custId);
					vendor.setPreName(doString.checkString(rs.getString("N_PNAME")));
					vendor.setName(doString.checkString(rs.getString("N_NAME")));
					vendor.setSurName(doString.checkString(rs.getString("N_SNAME")));
					vendor.setTelephone(doString.checkString(rs.getString("I_TEL")));
				}
				rs.close();
				rs=null;
			}
		}		
		session.setAttribute("Vendor", vendor);
        stmt.close();
        conn.close();
        stmt = null;
        conn = null;
        // forward to the success page.
        res.sendRedirect(successPage);
    } catch (Exception e) {
        System.out.println("ERROR /LHServ/InitEdtInfraServlet : " + e.getMessage());
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