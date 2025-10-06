package serv.servlets;

import java.io.*;
import java.text.*;
import java.util.*;
import java.sql.*;
import java.awt.Color;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.naming.*;

import com.lh.servlet.DBServlet;
import com.lh.util.*;
import com.lh.exception.InvalidParameterException;

import serv.common.User;
import serv.common.Constants;
import serv.common.SERV_CommonData;

/**
 * @version 	1.0
 * @author
 */
public class SERV_PendingServlet extends DBServlet  {
	
	 
	private void genRedirectCode(PrintWriter out,String page,String redirect,String error,String otherMsg) {
		out.println("<form method='post' action='"+page+"'>");		
		out.println("<input type='hidden' name='error' value='"+error+"'>");
		out.println("<input type='hidden' name='other_msg' value='"+doString.MS874ToUnicode(otherMsg)+"'>");
		out.println("<input type='hidden' name='redirect_url' value='"+doString.MS874ToUnicode(redirect)+"'>");		
		out.println("<script> document.forms[0].submit();</script>");
		out.println("</form>");		
	}
	public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		String mName = new String(this.getClass().getName() + ".performTask: ");
		System.out.println(mName + "start.");
		
		HttpSession session = req.getSession(false);
		if (session == null) {
			res.sendRedirect(Constants.WARNING_PAGE);
			return;
		}
		Object obj = session.getAttribute("USER");
		if (obj == null) {
			res.sendRedirect(Constants.WARNING_PAGE);
			return;
		}
 
		User user = (User) obj; 		
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
	
		String i_company = doString.checkString(req.getParameter("i_company"),"");
		String i_project = doString.checkString(req.getParameter("i_project"),"");
		String mode = doString.checkString(req.getParameter("mode"),"");
		String i_docno = doString.checkString(req.getParameter("i_docno"),"");
		String d_pending = doString.checkString(req.getParameter("d_pending"),"");
		String c_desc_pending = doString.checkString(req.getParameter("c_desc_pending"),"");
		String i_pending_type = doString.checkString(req.getParameter("i_pending_type"),"");
		String itmtype = doString.checkString(req.getParameter("itmtype"),"");
		String from_page = doString.checkString(req.getParameter("from_page"),"");
		String i_seq = doString.checkString(req.getParameter("i_seq"),"");

		String savePage = Constants.SAVE_PAGE;
		String successPage = "";
		String errorPage = "/LHServ/SERV_Pending.jsp?i_company="+i_company+"&i_project="+i_project+"&i_docno="+i_docno+"&itmtype="+itmtype+"&error=1&refresh=yes";
		String otherMsg = "";
		String errorCode = "";
		
		String f_document = "";
		
		StringBuffer sql = new StringBuffer();
		PreparedStatement prep;
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
		   
		   if (mode.equalsIgnoreCase("ADD")) {
			   if(!"".equals(from_page)){
				   if("SERV_OpenJob_Follow.jsp".equals(from_page)){
					   f_document = "INF";
					   itmtype = "4.3";
				   }else if("SERV_StartTask_Follow.jsp".equals(from_page)){
					   f_document = "OPN";
					   itmtype = "3.3";
				   }else {
					   f_document = "STK";
					   itmtype = "6.3";
				   }
			   }
			   
			   sql.delete(0, sql.length());
			   sql.append(" insert into lan:serv_pending (i_docno,i_seq,i_pending_type,c_desc_pending,d_pending,i_date,i_employ,f_status,f_document) ")
			   	.append(" values (?,?,?,?,?,today,?,?,?) ");
			   	//.append(" values ('"+i_docno+"',"+i_seq+",'"+i_pending_type+"','"+c_desc_pending+"','"+thaiToDB(d_pending)+"',today,'"+user.getEmpId()+"','OPN','"+f_document+"') ");
			   System.out.println(sql.toString());
			   prep = conn.prepareStatement(sql.toString());
			   prep.setString(1, i_docno);
			   prep.setString(2, i_seq);
			   prep.setString(3, i_pending_type);
			   prep.setString(4, c_desc_pending);
			   prep.setString(5, thaiToDB(d_pending));
			   prep.setString(6, user.getEmpId());
			   prep.setString(7, "OPN");
			   prep.setString(8, f_document);
			   
			   int result = prep.executeUpdate();
			   
			   System.out.println("INSERTED "+result+" ROW");
				   
				   
			   sql.delete(0, sql.length());
			   sql.append(" update lan:serv_dochd set f_pending = '"+f_document+"' ")
			   	.append(" where i_docno = '"+i_docno+"' ");
			   System.out.println(sql.toString());
			   result = stmt.executeUpdate(sql.toString());
			   System.out.println("UPDATED "+result+" ROW");
		   }else if (mode.equalsIgnoreCase("CANCEL")) {
			   if(!"".equals(from_page)){
				   if("SERV_OpenJob_Follow.jsp".equals(from_page)){
					   f_document = "INF";
				   }else if("SERV_StartTask_Follow.jsp".equals(from_page)){
					   f_document = "OPN";
				   }else {
					   f_document = "STK";
				   }
				   
				  
				   if (itmtype.indexOf("3.") != -1) {
					    sql.delete(0, sql.length());
						sql.append(" ( ")
							.append(" select distinct a.i_company , a.i_project , a.i_lock , a.i_docno , date(a.d_keyin) as i_date ,  ")
							.append(" b.n_customer , c.i_house , a.d_appoint , a.count_hddate ")
							.append(" from ( ")
							.append(" select a.i_docno , a.i_lock , a.d_keyin , a.i_company , a.i_project , a.d_appoint ")
							.append(" , CASE WHEN (today - date(a.d_appoint))  > 0  THEN (today - date(a.d_appoint)) ELSE 0 END as count_hddate ")
							.append(" from lan:serv_dochd a , lan:serv_docdt b ")
							.append(" where 1=1 ")
							.append(" and a.i_company = '"+i_company+"' ")
							.append(" and a.i_project = '"+i_project+"' ")
							.append(" and a.c_desc <> 'Checkup Program' ")
							.append(" and a.i_doc_type = 'J' ")
							.append(" and a.f_status = 'OPN' ")
							.append(" and a.i_docno = b.i_docno ")
							.append(" and b.f_itmstatus = '200' ")
							.append(" and (a.d_complete_max is null or d_complete_max = '') ")
							.append(" and a.d_appoint >= today ")
							.append(" and (a.f_pending <> 'OPN' OR a.f_pending is null) ")
							.append(" and (a.i_system = 'ESV' OR a.i_system is null ) ")
							.append(" ) as a , ( ")
							.append(" select a.i_company , a.i_project , a.i_sort as i_lock , ")
							.append(" n_prename || ' ' || n_ncustomer || ' ' || n_scustomer as n_customer ")
							.append(" from lan:acscontr a , lan:acxcusto b ")
							.append(" where 1=1 ")
							.append(" and a.i_company = '"+i_company+"' ")
							.append(" and a.i_project = '"+i_project+"' ")
							.append(" and a.f_contr is null ")
							.append(" and b.i_customer = nvl(a.i_cus_intent1,a.i_exp_intent1) ")
							.append(" ) as b , lan:acxlckmd as c ")
							.append(" where 1=1 ")
							.append(" and a.i_company = b.i_company ")
							.append(" and a.i_project = b.i_project ")
							.append(" and a.i_company = c.i_company ")
							.append(" and a.i_project = c.i_project ")
							.append(" and a.i_lock = b.i_lock ")
							.append(" and a.i_lock = c.i_lock ")
							.append(" ) union ( ")
							.append(" select distinct a.i_company , a.i_project , a.i_lock , b.i_docno , a.i_date ,  ")
							.append(" a.n_customer , a.i_house , c.d_appoint , ")
							.append(" CASE WHEN (today - date(c.d_appoint))  > 0  THEN (today - date(c.d_appoint)) ELSE 0 END as count_hddate  ")
							.append(" from lan:svc_dochd a , lan:svc_docdt b , lan:serv_dochd c , lan:serv_docdt d ")
							.append(" where a.i_svc_docno  = b.i_svc_docno ")
							.append(" and b.i_docno = c.i_docno ")
							.append(" and a.i_company = '"+i_company+"' ")
							.append(" and a.i_project = '"+i_project+"' ")
							.append(" and c.i_doc_type = 'J' ")
							.append(" and c.f_status = 'OPN' ")
							.append(" and c.i_docno = d.i_docno ")
							.append(" and d.f_itmstatus = '200' ")
							.append(" and (c.d_complete_max is null or c.d_complete_max = '') ")
							.append(" and c.d_appoint >= today ")
							.append(" and (c.f_pending <> 'OPN' OR c.f_pending is null) ")
							.append(" and c.c_desc <> 'Checkup Program' ")
							.append(" and c.i_system = 'SVC' ")
							.append(" ) ");
						rs = stmt.executeQuery(sql.toString());
						if(rs.next()){
							itmtype = "3.1";
						}else{
							itmtype = "3.2";
						}
						rs.close();
					}
					if (itmtype.indexOf("4.") != -1) {
					    sql.delete(0, sql.length());
						sql.append(" select distinct a.i_company , a.i_project , a.i_lock , a.i_docno ,  ")
							.append(" a.d_keyin as i_date , ")
							.append(" b.n_customer , c.i_house , a.d_appoint , ")
							.append(" a.count_date, a.d_print_inform ")
							.append(" from ( ")
							.append(" select i_docno , i_lock , d_keyin , i_company , i_project , d_keyin as d_appoint , d_print_inform ")
							.append(" , CASE WHEN (today - date(d_keyin))  > 0  ")
							.append("  THEN (today - date(d_keyin)) ")
							.append("  ELSE 0 END as count_date ")
							.append(" from lan:serv_dochd ")
							.append(" where i_company = '"+i_company+"' ")
							.append(" and i_project = '"+i_project+"' ")
							.append(" and i_system is null ")
							.append(" and i_doc_type = 'I' ")
							.append(" and f_status = 'OPN' ")
							.append(" and d_appoint >= today ")
							.append(" and (f_pending <> 'INF' OR f_pending is null) ")
							.append(" and c_desc <> 'Checkup Program' ")
							.append(" ) as a , ( ")
							.append(" select a.i_company , a.i_project , a.i_sort as i_lock ,  ")
							.append(" n_prename || ' ' || n_ncustomer || ' ' || ")
							.append("  n_scustomer as n_customer ")
							.append(" from lan:acscontr a , lan:acxcusto b ")
							.append(" where a.i_company = '"+i_company+"' ")
							.append(" and a.i_project = '"+i_project+"' ")
							.append(" and a.f_contr is null ")
							.append(" and b.i_customer = nvl(a.i_cus_intent1,a.i_exp_intent1) ")
							.append(" ) as b , lan:acxlckmd as c ")
							.append(" where a.i_company = b.i_company ")
							.append(" and a.i_project = b.i_project ")
							.append(" and a.i_company = c.i_company ")
							.append(" and a.i_project = c.i_project ")
							.append(" and a.i_lock = b.i_lock ")
							.append(" and a.i_lock = c.i_lock ")
							.append(" union ")
							.append(" select distinct a.i_company , a.i_project , a.i_lock , a.i_docno ,  ")
							.append(" a.d_keyin as i_date,b.n_customer,c.i_house, ")
							.append(" a.d_appoint ,  a.count_date, a.d_print_inform ")
							.append(" from ( ")
							.append(" select a.i_docno , a.i_lock , a.d_keyin , a.i_company , a.i_project ,  ")
							.append(" b.d_appoint,a.d_print_inform, ")
							.append(" CASE WHEN (today - date(b.d_appoint))  > 0   ")
							.append(" THEN (today - date(b.d_appoint))  ")
							.append(" ELSE 0 END as count_date ")
							.append(" from lan:serv_dochd a , lan:eser_dochd b ")
							.append(" where 1=1 ")
							.append(" and a.i_docno = b.i_docno ")
							.append(" and a.i_company = '"+i_company+"' ")
							.append(" and a.i_project = '"+i_project+"' ")
							.append(" and a.i_system = 'ESV' ")
							.append(" and a.i_doc_type = 'I' ")
							.append(" and a.f_status = 'OPN' ")
							.append(" and (a.d_appoint >= today or a.d_appoint is null ) ")
							.append(" and (a.f_pending <> 'INF' OR a.f_pending is null) ")
							.append(" and a.c_desc <> 'Checkup Program' ")
							.append(" ) as a , ( ")
							.append(" select a.i_company , a.i_project , a.i_sort as i_lock , n_prename || ' ' || n_ncustomer || ' ' || n_scustomer as n_customer ")
							.append(" from lan:acscontr a , lan:acxcusto b ")
							.append(" where 1=1 ")
							.append(" and a.i_company = '"+i_company+"' ")
							.append(" and a.i_project = '"+i_project+"' ")
							.append(" and a.f_contr is null ")
							.append(" and b.i_customer = nvl(a.i_cus_intent1,a.i_exp_intent1) ")
							.append(" ) as b , lan:acxlckmd as c ")
							.append(" where 1=1 ")
							.append(" and a.i_company = b.i_company ")
							.append(" and a.i_project = b.i_project ")
							.append(" and a.i_company = c.i_company ")
							.append(" and a.i_project = c.i_project ")
							.append(" and a.i_lock = b.i_lock ")
							.append(" and a.i_lock = c.i_lock ")
							.append(" union ")
							.append(" select a.i_company,a.i_project, a.i_lock ,b.i_docno, ")
							.append(" a.d_keyin as i_date,a.n_customer, ")
							.append(" a.i_house , b.d_appoint,   ")
							.append(" CASE WHEN (today - date(b.d_appoint))  > 0 ")
							.append("  THEN (today - date(b.d_appoint)) ")
							.append(" ELSE 0 END as count_date,c.d_print_inform ")
							.append(" from lan:svc_dochd a , lan:svc_docdt b , lan:serv_dochd c ")
							.append(" where a.i_svc_docno = b.i_svc_docno ")
							.append(" and b.i_docno = c.i_docno ")
							.append(" and a.i_company = '"+i_company+"' ")
							.append(" and a.i_project = '"+i_project+"' ")
							.append(" and c.i_doc_type = 'I' ")
							.append(" and c.f_status = 'OPN' ")
							.append(" and b.d_appoint >= today ")
							.append(" and (c.f_pending <> 'INF' OR c.f_pending is null) ")
							.append(" and c.c_desc <> 'Checkup Program' ")
							.append(" and c.i_system = 'SVC' ");
						rs = stmt.executeQuery(sql.toString());
						if(rs.next()){
							itmtype = "4.1";
						}else{
							itmtype = "4.2";
						}
						rs.close();
					}
					if(itmtype.indexOf("6.") != -1) {
					    sql.delete(0, sql.length());
						sql.append(" ( ")
							.append(" select distinct a.i_company , a.i_project , a.i_lock , a.i_docno , date(a.d_keyin) as i_date ,  ")
							.append(" b.n_customer , c.i_house , a.d_appoint , a.count_hddate ")
							.append(" from ( ")
							.append(" select a.i_docno , a.i_lock , a.d_keyin , a.i_company , a.i_project , a.d_est_close as d_appoint ")
							.append(" , CASE WHEN (today - date(a.d_est_close))  > 0  THEN (today - date(a.d_est_close)) ELSE 0 END as count_hddate ")
							.append(" from lan:serv_dochd a , lan:serv_docdt b ")
							.append(" where 1=1 ")
							.append(" and a.i_company = '"+i_company+"' ")
							.append(" and a.i_project = '"+i_project+"' ")
							.append(" and a.c_desc <> 'Checkup Program' ")
							.append(" and a.i_doc_type = 'J' ")
							.append(" and a.f_status = 'OPN' ")
							.append(" and a.i_docno = b.i_docno ")
							.append(" and b.f_itmstatus = '300' ")
							.append(" and (a.d_complete_max is null or d_complete_max = '') ")
							.append(" and a.d_est_close >= today ")
							.append(" and (a.f_pending <> 'STK' OR a.f_pending is null) ")
							.append(" and (a.i_system = 'ESV' OR a.i_system is null ) ")
							.append(" ) as a , ( ")
							.append(" select a.i_company , a.i_project , a.i_sort as i_lock , ")
							.append(" n_prename || ' ' || n_ncustomer || ' ' || n_scustomer as n_customer ")
							.append(" from lan:acscontr a , lan:acxcusto b ")
							.append(" where 1=1 ")
							.append(" and a.i_company = '"+i_company+"' ")
							.append(" and a.i_project = '"+i_project+"' ")
							.append(" and a.f_contr is null ")
							.append(" and b.i_customer = nvl(a.i_cus_intent1,a.i_exp_intent1) ")
							.append(" ) as b , lan:acxlckmd as c ")
							.append(" where 1=1 ")
							.append(" and a.i_company = b.i_company ")
							.append(" and a.i_project = b.i_project ")
							.append(" and a.i_company = c.i_company ")
							.append(" and a.i_project = c.i_project ")
							.append(" and a.i_lock = b.i_lock ")
							.append(" and a.i_lock = c.i_lock ")
							.append(" ) union ( ")
							.append(" select distinct a.i_company , a.i_project , a.i_lock , b.i_docno , a.i_date ,  ")
							.append(" a.n_customer , a.i_house , c.d_est_close as d_appoint , ")
							.append(" CASE WHEN (today - date(c.d_est_close))  > 0  THEN (today - date(c.d_est_close)) ELSE 0 END as count_hddate  ")
							.append(" from lan:svc_dochd a , lan:svc_docdt b , lan:serv_dochd c , lan:serv_docdt d ")
							.append(" where a.i_svc_docno  = b.i_svc_docno ")
							.append(" and b.i_docno = c.i_docno ")
							.append(" and a.i_company = '"+i_company+"' ")
							.append(" and a.i_project = '"+i_project+"' ")
							.append(" and c.i_doc_type = 'J' ")
							.append(" and c.f_status = 'OPN' ")
							.append(" and c.i_docno = d.i_docno ")
							.append(" and d.f_itmstatus = '300' ")
							.append(" and (c.d_complete_max is null or c.d_complete_max = '') ")
							.append(" and c.d_est_close >= today ")
							.append(" and (c.f_pending <> 'STK' OR c.f_pending is null) ")
							.append(" and c.c_desc <> 'Checkup Program' ")
							.append(" and c.i_system = 'SVC' ")
							.append(" ) ");
						rs = stmt.executeQuery(sql.toString());
						if(rs.next()){
							itmtype = "6.1";
						}else{
							itmtype = "6.2";
						}
						rs.close();
					}
			   }
			   
			   sql.delete(0, sql.length());
			   sql.append(" update lan:serv_pending set f_status = 'CAN'  ")
			   	.append(" where i_docno = '"+i_docno+"' ")
			   	.append(" and f_status = 'OPN' ")
			   	.append(" and f_document = '"+f_document+"' ");
			   System.out.println(sql.toString());
			   int result = stmt.executeUpdate(sql.toString());
			   System.out.println("CANCELED "+result+" ROW");
			   
			   sql.delete(0, sql.length());
			   sql.append(" update lan:serv_dochd set f_pending = '' ")
			   	.append(" where i_docno = '"+i_docno+"' ");
			   System.out.println(sql.toString());
			   result = stmt.executeUpdate(sql.toString());
			   System.out.println("UPDATED "+result+" ROW");
			   
			   from_page = "SERV_Pending.jsp";
		   }
		       
		 conn.commit();
		 //conn.rollback();
		 stmt.close();
		 conn.close();
		 conn = null;
		 
		successPage = "/LHServ/"+from_page+"?i_company="+i_company+"&i_project="+i_project+"&i_docno="+i_docno+"&itmtype="+itmtype+"&from_page="+from_page;
		genRedirectCode(out,savePage,successPage,errorCode,otherMsg);
						
		}catch (Exception e) {
			if (e instanceof InvalidParameterException) {
				showError(out, doString.UnicodeToMS874(e.getMessage()));
			} else {
				System.out.println(" ERROR "+mName+" : " + e.getMessage());
				System.out.println(" ERROR "+mName+" SQL : " + sql.toString());
			}
			
		} finally {
					out.close();
					try {
						if (rs!=null) rs.close(); 
						if (stmt != null) stmt.close();
						if (conn != null) conn.close();
					} catch (SQLException ignore) {
					}
				}
		
	}
	private String thaiToDB(String thDate) {
		return (Integer.parseInt(thDate.substring(6, 10)) - 543) + "-"
				+ thDate.substring(3, 5) + "-" + thDate.substring(0, 2);
	}

}



