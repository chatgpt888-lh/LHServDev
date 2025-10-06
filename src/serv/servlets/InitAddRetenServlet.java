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
import com.lh.util.DateUtil;

import serv.common.User;
import serv.common.Vendor;
public class InitAddRetenServlet extends DBServlet {
  private static String cName = "/LHServ/InitAddRetenServlet";
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
	Vendor vendor = (Vendor) session.getAttribute("Vendor");
	if (vendor == null) {
		vendor = new Vendor();
	}    
    String successPage = "";
    String docNo = req.getParameter("docNo");
	String comId = req.getParameter("comId");
	String projId = req.getParameter("projId");
	String status = "";
	successPage = "/LHServ/SERV_Add_Reten.jsp?Project="+comId+projId+"&docNo="+docNo;	
	String retenType = "";
	String retentId = "";
	String pname = "";
	String name = "";
	String sname = "";
	String telephone = "";	
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
		rs = stmt.executeQuery("SELECT h.i_ret_custo, h.i_reten, h.i_doc_status FROM lan:serv_rethd h WHERE h.i_company = '"+comId+"' AND h.i_project = '"+projId+"' AND h.i_docno = '"+docNo+"'");
		if (rs != null) {
			if (rs.next() == true) {
				status = doString.checkString(rs.getString("I_DOC_STATUS"));				
				retenType = doString.checkString(rs.getString("I_RET_CUSTO"));
				retentId = doString.checkString(rs.getString("I_RETEN"));
			}
			rs.close();
			rs=null;
		}
		if (status.equals("Y")) {
			successPage = "/LHServ/SERV_Disp_Reten.jsp?comId="+comId+"&projId="+projId+"&docNo="+docNo;
			throw new InvalidParameterException("เอกสารมีการพิมพ์ใบ Pay-In ไปแล้วไม่สามารถแก้ไขได้");
		}
		if (retenType.equals("1")) {
			
		} else {
			if (retenType.equals("2")) {
				retenType = "05";
			} else {
				retenType = "06";
			}
			rs = stmt.executeQuery("SELECT n_pname, n_name, n_sname, i_tel FROM lan:serv_venprj WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_type = '"+retenType+"' AND i_vendor = '"+retentId+"'");
			if (rs != null) {
				if (rs.next() == true) {
					pname = doString.checkString(rs.getString("N_PNAME"));
					name = doString.checkString(rs.getString("N_NAME"));
					sname = doString.checkString(rs.getString("N_SNAME"));
					telephone = doString.checkString(rs.getString("I_TEL"));						
					vendor.setId(retentId);
					vendor.setName(name);
					vendor.setPreName(pname);
					vendor.setSurName(sname);
					vendor.setTelephone(telephone);
				}
				rs.close();
				rs=null;
			}
		}
        stmt.close();
        conn.close();
        stmt = null;
        conn = null;
		session.setAttribute("Vendor", vendor);
        // forward to the success page.
        res.sendRedirect(successPage);
    } catch (InvalidParameterException e) {
    	res.sendRedirect(successPage);
    } catch (Exception e) {
        System.out.println("ERROR /LHServ/InitAddRetenServlet : " + e.getMessage());
        
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