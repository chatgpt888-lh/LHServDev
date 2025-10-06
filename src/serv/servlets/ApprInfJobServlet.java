package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import com.lh.servlet.DBServlet;
import com.lh.util.doString;
import com.lh.util.DateUtil;
import com.lh.util.LHMail;

import serv.common.Constants;
import serv.common.User;

public class ApprInfJobServlet extends DBServlet {
  private static String cName = "/LHServ/ApprInfJobServlet";
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
    
	res.setContentType("text/html; charset=TIS620");
	PrintWriter out = res.getWriter();
    String empId = doString.checkString(req.getParameter("apprId"));
    String userId = doString.checkString(req.getParameter("userId"));
    String docNo = doString.checkString(req.getParameter("docNo"));
    String selProj = doString.checkString(req.getParameter("selProj"));
    String mail = doString.checkString(req.getParameter("mail"));
    String status = doString.checkString(req.getParameter("status"));
    String chartGrp = doString.checkString(req.getParameter("chartGrp"));
    String comment = doString.checkString(req.getParameter("Comment"));
    comment = doString.TextToString(comment);
    comment = doString.UnicodeToMS874(comment);
    String staffId = "";
    String venId = "";
	String savePage = Constants.SAVE_PAGE;
	if (mail.equals("Y")) {
		savePage = "/LHServ/save_close.jsp";
	}
	String successPage = "SERV_INF_Wait_OpenJob_List.jsp?selProj="+selProj+"&chartGrp="+chartGrp+"&status=W";
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
        ustmt = conn.createStatement();
        
        rs = stmt.executeQuery("SELECT i_service_employ FROM lan:serv_infdochd WHERE i_docno = '"+docNo+"'");
        if (rs != null) {
        	if (rs.next() == true) {
        		staffId = doString.checkString(rs.getString("I_SERVICE_EMPLOY"));
        	}
        	rs.close();
        	rs=null;
        }
        
		String Recipients = "";
		String subject = "";
		String mailtext = "";
		String header = "<HTML><HEAD><META http-equiv=\"Content-Type\" content=\"text/html; charset=TIS-620\"><META http-equiv=\"Content-Language\" content=\"th\"><TITLE></TITLE></HEAD><BODY>";
		String footer = "</BODY></HTML>";
		LHMail MailLH = new LHMail();
		rs = stmt.executeQuery("SELECT user_email FROM docflow:useracl WHERE i_employ = '"+staffId+"'");
		if (rs != null) {
			if (rs.next() == true) {
				Recipients = doString.checkString(rs.getString(1));
			}
			rs.close();
			rs=null;
		}
        if (status.equals("A")) {
        	subject = "เอกสารใบสั่งซ่อมสาธารณูฯ เลขที่ : "+docNo+" อนุมัติเรียบร้อยแล้ว";
        	mailtext = "เอกสารใบสั่งซ่อมสาธารณูฯ เลขที่ : "+docNo+" อนุมัติเรียบร้อยแล้ว";
        	
	        //SERV_INFDOCHD
	        rowEffected = stmt.executeUpdate("UPDATE lan:serv_infdochd SET d_start_min = TODAY WHERE i_docno = '"+docNo+"'");
	        if (rowEffected != 1) {
	        	throw new Exception("SERV_INFDOCHD : Wrong Update Count");
	        }
        	
        	//SERV_INFDOCDT
        	stmt.executeUpdate("UPDATE lan:serv_infdocdt SET f_itmstatus = '300' WHERE i_docno = '"+docNo+"'");
        	
        	//SERV_INFDOCAP
	        rowEffected = stmt.executeUpdate("UPDATE lan:serv_infdocap SET d_approve = TODAY, f_approve = 'A' WHERE i_docno = '"+docNo+"' AND i_approver = '"+empId+"' AND i_seq > 1");
	        if (rowEffected != 1) {
	        	throw new Exception("SERV_INFDOCAP : Wrong Update Count");
	        }
	        
	        //SERV_INFFLOW
	        rs = stmt.executeQuery("SELECT DISTINCT i_vendor FROM lan:serv_infdocdt WHERE i_docno = '"+docNo+"'");
	        if (rs != null) {
	        	while (rs.next() == true) {
	        		venId = doString.checkString(rs.getString("I_VENDOR"));
	        		ustmt.executeUpdate("INSERT INTO lan:serv_infflow(i_docno, i_vendor, f_itmstatus, d_approve, i_approve) VALUES('"+docNo+"', '"+venId+"', '200', CURRENT, '"+userId+"')");
	        	}// end while
	        	rs.close();
	        	rs=null;
	        }
			if (!Recipients.equals("")) {
				MailLH.sendBBMail("132.146.1.12", "lh.co.th", "application", Recipients, "", doString.MS874ToUnicode(subject), doString.MS874ToUnicode(mailtext));
			}
        } else { //Reject
        	subject = "เอกสารใบสั่งซ่อมสาธารณูฯ เลขที่ : "+docNo+" ไม่ผ่านการอนุมัติ";
        	mailtext = "เอกสารใบสั่งซ่อมสาธารณูฯ เลขที่ : "+docNo+" ไม่ผ่านการอนุมัติ";
        	
	        //SERV_INFDOCHD
	        rowEffected = stmt.executeUpdate("UPDATE lan:serv_infdochd SET f_status = 'NEW', i_chart = 'S', c_reject = '"+comment+"' WHERE i_docno = '"+docNo+"'");
	        if (rowEffected != 1) {
	        	throw new Exception("SERV_INFDOCHD : Wrong Update Count");
	        }
	        //SER_INFDOCAP
	        rowEffected = stmt.executeUpdate("UPDATE lan:serv_infdocap SET d_approve = NULL, f_approve = 'N' WHERE i_docno = '"+docNo+"' AND i_approver = '"+empId+"' AND i_seq > 1");
	        if (rowEffected != 1) {
	        	throw new Exception("SERV_INFDOCAP : Wrong Update Count");
	        }
	        rowEffected = stmt.executeUpdate("UPDATE lan:serv_infdocap SET d_approve = NULL, f_approve = 'R' WHERE i_docno = '"+docNo+"' AND i_chart_grp = 'S'");
	        if (rowEffected != 1) {
	        	throw new Exception("SERV_INFDOCAP : Wrong Update Count");
	        }
	        //Alert Mail
			if (!Recipients.equals("")) {
				MailLH.sendBBMail("132.146.1.12", "lh.co.th", "application", Recipients, "", doString.MS874ToUnicode(subject), doString.MS874ToUnicode(mailtext));
			}
        }
        
        conn.commit();
        stmt.close();
        ustmt.close();
        conn.close();
        stmt = null;
        ustmt = null;
        conn = null;
        genRedirectCode(out,savePage,successPage,errorCode,otherMsg);
    } catch (Exception e) {
    	try {
    		if (conn != null) conn.rollback();
    	} catch (Exception ignore) {}
        System.out.println("ERROR /LHServ/ApprInfJobServlet : " + e.getMessage());
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
        if (ustmt != null) {
            try {
                ustmt.close();
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