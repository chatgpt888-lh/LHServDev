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
public class SERV_InfPubPostJVServlet extends DBServlet  {
	
	public static String DEBIT_ACC_NO = "21710";
	public static String CREDIT_ACC_NO = "41516";
	public static String shortMonth[] = new String[] {"","ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค."};		
	 
	private void genRedirectCode(PrintWriter out,String page,String redirect,String error,String otherMsg) {
		out.println("<form method='post' action='"+page+"'>");		
		out.println("<input type='hidden' name='error' value='"+error+"'>");
		out.println("<input type='hidden' name='other_msg' value='"+doString.MS874ToUnicode(otherMsg)+"'>");
		out.println("<input type='hidden' name='redirect_url' value='"+doString.MS874ToUnicode(redirect)+"'>");		
		out.println("<script> document.forms[0].submit();</script>");
		out.println("</form>");		
	}
	
	public double getDoubleValue(String str) {
		 double result = 0.0;
		 str = doString.checkString(str,"0.0");
		 str = str.replaceAll(",","");
		 
		 try {
		 	result = Double.parseDouble(str);
		 } catch (Exception e) {
		 	result = 0.0; 
		 }
		 
		 return result;
	}
	
	public String getNextDocument(Statement stmt,String iCompany,int iMonth,int iYear) throws Exception {
		String result = "";
		StringBuffer sql = new StringBuffer();
		ResultSet rs = null;	
		doString str = new doString();
		int seq = 0;
		
		sql.delete(0,sql.length());
		sql.append(" select * from lan:acc_trantojv_hd ")
		   .append(" where i_type_gl='JV' and i_system='INF' and d_document is not null ")
		   .append(" and month(d_document)='"+iMonth+"' and year(d_document)='"+iYear+"'")
		   .append(" order by i_document desc ");
		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
			String tmp = doString.checkString(rs.getString("i_document"),"");
			if (tmp.length()>=9) {
				try {
					seq = Integer.parseInt(tmp.substring(6,9));
				} catch(Exception ex) {
					seq = 0;
				}
			}
		} else {
			seq = 0;
		}
		rs.close();
		
		//--- create new document ---//
		seq++;
		result = iCompany+str.createID(iYear+543,4).substring(2,4)+str.createID(iMonth,2)+str.createID(seq,3);
		
		return result;
	}
	
	public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		String mName = new String(this.getClass().getName() + ".performTask: ");
		System.out.println(mName + "start.");

		//-----======= Check Login session =======-----//
		HttpSession session = req.getSession(false);
		if (session == null) {
			//---===== No Session , redirect to warning =======---// 
			res.sendRedirect(Constants.WARNING_PAGE);
			return;
		}
		Object obj = session.getAttribute("USER");
		if (obj == null) {
			//---===== Can't get User Login , redirect to warning ======---// 
			res.sendRedirect(Constants.WARNING_PAGE);
			return;
		}
		//----===================================----//	
     
 
		User user = (User) obj;
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
		
	
		String selCompany = doString.checkString(req.getParameter("sel_company"),"");
		int selMonth = Integer.parseInt(doString.checkString(req.getParameter("sel_month"),"0"));
		int selYear = Integer.parseInt(doString.checkString(req.getParameter("sel_year"),"0"));				
		String iDocument = doString.checkString(req.getParameter("i_document"),"");
		String empId = doString.checkString(req.getParameter("i_employ"),"");
		int totalProj = Integer.parseInt(doString.checkString(req.getParameter("total_proj"),"0"));
		String projJv = "";
		String iCom = "";
		String iProj = ""; 				
		double zDebit = 0.0;
		double zCredit = 0.0;			
		
		String labelDesc = Integer.toString(selYear+543);
		if (labelDesc.length()>=2) {
			labelDesc = labelDesc.substring(labelDesc.length()-2);
		}
		labelDesc = "บันทึกรายได้ค่าบริการฯ จาก "+DEBIT_ACC_NO +" - "+shortMonth[selMonth]+labelDesc;				
		
		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_InfPubPostJV.jsp";
		String errorPage = "SERV_InfPubPostJV.jsp?sel_company="+selCompany+"&sel_month="+selMonth+"&sel_year="+selYear;
		
		StringBuffer sql = new StringBuffer();
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		doString str = new doString();


		try {
		   if (ds == null)
			   getDS();
	 
		   conn = ds.getConnection();
		   conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		   conn.setAutoCommit(false);
		   stmt = conn.createStatement();
		   sql.delete(0,sql.length());
		   
		   
		    //----- re-check before delete & insert new data -----//
	        String iJvNo = "";	        
			sql.delete(0,sql.length());
			sql.append(" select * from lan:acc_trantojv_hd ")
			   .append(" where i_type_gl='JV' and i_system='INF' and d_document is not null ")
			   .append(" and i_document='"+iDocument+"' ");
			rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
				iJvNo = doString.checkString(rs.getString("i_jvno"),"");
			} 
			rs.close();	
		   
			
			if (iJvNo.length()>0) {
				//--- throw error and can't save ---//
				throw new Exception("ERR_EXIST_JV_"+iJvNo);
			} else {
				//----- clear old data ------//
				if (iDocument.length()>0) {
					//-------- move this method after get new i_document for sequence running --------//
					//--- now , sequence always '001' because data delete before sequence running  ---//
				    sql.delete(0,sql.length());
				    sql.append(" delete from lan:acc_trantojv_hd ")
					   .append(" where i_type_gl='JV' and i_system='INF' ")
					   .append(" and i_document='"+iDocument+"' ");
				    stmt.executeUpdate(doString.UnicodeToMS874(sql.toString()));
	
				    sql.delete(0,sql.length());
				    sql.append(" delete from lan:acc_trantojv_dt ")
					   .append(" where i_type_gl='JV' and i_system='INF' ")
					   .append(" and i_document='"+iDocument+"' ");
				    stmt.executeUpdate(doString.UnicodeToMS874(sql.toString()));		
				}
			    
				//----- find last date of month for today -----//
				Calendar cal = new  GregorianCalendar();
				cal.set(selYear,selMonth-1,1,0,0,0); // set to selected month
				int year = cal.get(Calendar.YEAR);	
				if (year>2400) year -= 543;	
				String lastDateOfMonth = year+"-"+str.createID(cal.get(Calendar.MONTH)+1,2)+"-"+str.createID(cal.getActualMaximum(cal.DAY_OF_MONTH),2);
				
				//------ get new i_document with next sequence ------//
				String newDocument = getNextDocument(stmt,selCompany,selMonth,selYear);
				double totalDebit = getDoubleValue(req.getParameter("total_debit"));
				double totalCredit = getDoubleValue(req.getParameter("total_credit"));
				
			    //---- insert table lan:acc_trantojv_hd ----//
			    sql.delete(0,sql.length());
			    sql.append(" insert into lan:acc_trantojv_hd ( ")
				   .append(" i_type_gl, 		i_system, 		i_company, 			i_document, ") // 1 - 4
				   .append(" i_gl_project, 		d_document, 	d_pv_adv, 			i_pv_adv, ")   // 5 - 8 
				   .append(" d_jvno, 			i_jvno, 		d_rvno, 			i_rvno, ")     // 9 - 12 
				   .append(" d_add_pv, 			i_add_pv, 		i_requester, 		z_adv_amt, ")  // 13 - 16
				   .append(" z_clr_amt, 		z_diff_amt, 	d_clear, 			d_post_jv, ")  // 17 - 20
				   .append(" i_employ_postjv, 	d_post_pv, 		i_employ_postpv, 	d_post_rv, ")  // 21 - 24
				   .append(" i_employ_postrv, 	i_scr_desc,		d_insert, 			i_employ_insert, ") // 25 - 28
				   .append(" i_vendor,			f_update1, 		d_update1, 			f_update2, ")  // 29 - 32
				   .append(" d_update2 ) values ( ") 	// 33	
				   .append(" 'JV', 'INF', '"+selCompany+"', '"+newDocument+"', ") // 1 - 4
				   .append(" '099', '"+lastDateOfMonth+"', null, null, ") // 5 - 8
				   .append(" '"+lastDateOfMonth+"', null, null, null, ") // 9 - 12
				   .append(" null, null, '"+empId+"', ") // 13 - 15
				   .append(" '"+doString.displayNumber("######0.00",totalDebit)+"', ") // 16
				   .append(" '"+doString.displayNumber("######0.00",totalCredit)+"', ") // 17
				   .append(" 0.0, null, null, ") // 18 - 20
				   .append(" null, null, null, null, ") // 21 - 24
				   .append(" null, '"+labelDesc+"', current, '"+empId+"', ") // 25 - 28
				   .append(" null, null, null, null, ") // 29 - 32
				   .append(" null ) "); // 33
				stmt.executeUpdate(doString.UnicodeToMS874(sql.toString()));			   
	
				int line = 0;
				for (int i=1;i<=totalProj;i++) {
					projJv = doString.checkString(req.getParameter("proj_"+i),"");
					iCom = projJv.length()>=6 ? projJv.substring(0,2) : "";
					iProj = projJv.length()>=6 ? projJv.substring(3,6) : ""; 				
					zDebit = getDoubleValue(req.getParameter("debit_"+i));
					zCredit = getDoubleValue(req.getParameter("credit_"+i))*-1; // negative for credit
					
					//---- insert debit in table lan:acc_trantojv_dt ----//
					line++;
					sql.delete(0,sql.length());
					sql.append(" insert into lan:acc_trantojv_dt ( ")
					   .append(" i_type_gl, 	i_system, 	i_company, 			i_document, ") // 1 - 4
					   .append(" i_project, 	i_expense, 	i_acctno, 			i_ioudoc, ") // 5 - 8
					   .append(" i_house_type, 	z_amount, 	i_scr_desc, 		i_seq, ") // 9 - 12
					   .append(" i_ven_cut, 	i_docno, 	i_employ_postvcut, 	d_post_vcut ") // 13 - 16
					   .append(" ) values ( ")
					   .append(" 'JV', 'INF', '"+iCom+"', '"+newDocument+"', ") // 1 - 4
					   .append(" '"+iProj+"',null, '"+DEBIT_ACC_NO+"', null, ") // 5 - 8
					   .append(" null, '"+doString.displayNumber("######0.00",zDebit)+"', ") // 9 - 10
					   .append(" '"+labelDesc+"', '"+line+"', null, ") // 11 - 13
					   .append(" null, null, null) "); // 14 - 16
					stmt.executeUpdate(doString.UnicodeToMS874(sql.toString()));


					//---- insert credit in table lan:acc_trantojv_dt ----//
					line++;
					sql.delete(0,sql.length());
					sql.append(" insert into lan:acc_trantojv_dt ( ")
					   .append(" i_type_gl, 	i_system, 	i_company, 			i_document, ") // 1 - 4
					   .append(" i_project, 	i_expense, 	i_acctno, 			i_ioudoc, ") // 5 - 8
					   .append(" i_house_type, 	z_amount, 	i_scr_desc, 		i_seq, ") // 9 - 12
					   .append(" i_ven_cut, 	i_docno, 	i_employ_postvcut, 	d_post_vcut ") // 13 - 16
					   .append(" ) values ( ")
					   .append(" 'JV', 'INF', '"+iCom+"', '"+newDocument+"', ") // 1 - 4
					   .append(" '"+iProj+"',null, '"+CREDIT_ACC_NO+"', null, ") // 5 - 8
					   .append(" null, '"+doString.displayNumber("######0.00",zCredit)+"', ") // 9 - 10  
					   .append(" '"+labelDesc+"', '"+line+"', null, ") // 11 - 13
					   .append(" null, null, null) "); // 14 - 16
					stmt.executeUpdate(doString.UnicodeToMS874(sql.toString()));
				} // end for
				
			} // endif
			
		 conn.commit();
		 //conn.rollback();
		 stmt.close();
		 conn.close();
		 conn = null;
					
		 genRedirectCode(out,savePage,successPage,"","");
						
		}catch (Exception e) {
			System.out.println(" ERROR "+mName+" : " + e.getMessage());
			System.out.println(" ERROR "+mName+" SQL : " + sql.toString());
			
			genRedirectCode(out,savePage,errorPage,"1",e.getMessage());
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

}



