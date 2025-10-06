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
public class CancelInfraServlet extends DBServlet {
  private static String cName = "/LHServ/CancelInfraServlet";
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
	String docNo = req.getParameter("docNo");
	String comId = req.getParameter("comId");
	String projId = req.getParameter("projId");
	String project = comId+projId;
	String year = doString.checkString(req.getParameter("Year"));
	String month = doString.checkString(req.getParameter("Month"));
	String betweenDate = doString.checkString(req.getParameter("between"));
	String params = "?Project="+project+"&between="+betweenDate+"&Year="+year+"&Month="+month;
	String successPage = "/LHServ/save_ok.jsp?redirect_url=SERV_InfHome.jsp";
	String errorPage = "";
	successPage += params;
	errorPage = successPage+"&error=true";

	int rowEffected = 0;
    Connection conn = null;
    Statement stmt = null;
    try {
        if (ds == null)
            getDS();
        conn = ds.getConnection();
        conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
        conn.setAutoCommit(true);
        stmt = conn.createStatement();
		
		//RESV_INFHD
		rowEffected = stmt.executeUpdate("DELETE FROM lan:serv_infhd WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+docNo+"'");
		if (rowEffected != 1) {
			throw new Exception("SERV_INFHD : Wrong update count");
		}
		stmt.executeUpdate("DELETE FROM lan:serv_payin WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+docNo+"'");
		
        stmt.close();
        conn.close();
        stmt = null;
        conn = null;
        // forward to the success page.
        res.sendRedirect(successPage);
    } catch (Exception e) {
        System.out.println("ERROR /LHServ/CancelInfraServlet : " + e.getMessage());
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