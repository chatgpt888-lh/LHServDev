package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import com.lh.servlet.DBServlet;
import com.lh.util.doString;
import com.lh.util.DateUtil;

import serv.common.Constants;
import serv.common.User;;

public class CancelInfJobServlet extends DBServlet {
  private static String cName = "/LHServ/CancelInfJobServlet";
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
    User user = (User) obj;
    String empId = user.getEmpId();
	res.setContentType("text/html; charset=TIS620");
	PrintWriter out = res.getWriter();
	
    String docNo = doString.checkString(req.getParameter("docNo"));
    String selProj = doString.checkString(req.getParameter("selProj"));
    String chartGrp = doString.checkString(req.getParameter("chartGrp"));
    
    String status = "R";
    String venId = "";
	String savePage = Constants.SAVE_PAGE;
	String successPage = "SERV_INF_Wait_OpenJob_List.jsp?selProj="+selProj+"&chartGrp="+chartGrp;
	String errorPage = successPage + "&error=1"; 
	String otherMsg = "";
	String errorCode = "";
    int rowEffected = 0;
    StringBuffer sql = new StringBuffer();
    Connection conn = null;
    Statement stmt = null;
    Statement ustmt = null;
    ResultSet rs = null;
    try {
        if (ds == null)
            getDS();
        conn = ds.getConnection();
        conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
        conn.setAutoCommit(false);
        stmt = conn.createStatement();
        //SERV_INFDOCHD
        rowEffected = stmt.executeUpdate("UPDATE lan:serv_infdochd SET f_status = 'CAN', i_chart = 'S' WHERE i_docno = '"+docNo+"'");
        if (rowEffected != 1) {
        	throw new Exception("SERV_INFDOCHD : Wrong Update Count");
        }
        
    	//SERV_INFDOCDT
    	stmt.executeUpdate("UPDATE lan:serv_infdocdt SET f_itmstatus = 'CAN' WHERE i_docno = '"+docNo+"'");
        
        //SER_INFDOCAP
        rowEffected = stmt.executeUpdate("UPDATE lan:serv_infdocap SET d_approve = TODAY, f_approve = 'R' WHERE i_docno = '"+docNo+"' AND i_chart_grp = 'S'");
        if (rowEffected != 1) {
        	throw new Exception("SERV_INFDOCAP : Wrong Update Count");
        }
        conn.commit();
        stmt.close();
        conn.close();
        stmt = null;
        conn = null;
        genRedirectCode(out,savePage,successPage,errorCode,otherMsg);
    } catch (Exception e) {
    	try {
    		if (conn != null) conn.rollback();
    	} catch (Exception ignore) {}
        System.out.println("ERROR /LHServ/CancelInfJobServlet : " + e.getMessage());
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