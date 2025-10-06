package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;

import com.lh.servlet.DBServlet;
import com.lh.util.*;
import com.lh.exception.InvalidParameterException;

import serv.common.User;
import serv.common.Constants;
import serv.common.CONMail;

/**
 * @version 	1.0
 * @author
 */
public class SERV_ContractServlet extends DBServlet  {
	
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
		doString str = new doString();	
		
		//Date
		Calendar right = Calendar.getInstance();
		int dd = right.get(Calendar.DATE);
		int mm = right.get(Calendar.MONTH)+1;
		int yy = right.get(Calendar.YEAR);
		if(yy < 2400){
			yy += 543;
		}
		
		//Page Control
		String savePage =Constants.SAVE_PAGE;
		String successPage = "SERV_ConHome.jsp?";
		String errorPage = successPage + "error=1";		
		String otherMsg = "";
		String errorCode = "";

		String mode = doString.checkString(req.getParameter("mode"), "");
		String project = doString.checkString(req.getParameter("project"));
		String i_company = "";
		String i_project = "";
		String site = "";
		if (!project.equals("")) {
			i_company = project.substring(0,2);
			i_project = project.substring(2);
		}
    
		StringBuffer sql = new StringBuffer();
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		
		String start_date = doString.checkString(req.getParameter("start_date"),"");
		String start_month = doString.checkString(req.getParameter("start_month"),"");
		String start_year = doString.checkString(req.getParameter("start_year"),"");
		String end_date = doString.checkString(req.getParameter("end_date"),"");
		String end_month = doString.checkString(req.getParameter("end_month"),"");
		String end_year = doString.checkString(req.getParameter("end_year"),"");
		String i_phase = doString.checkString(req.getParameter("i_phase"),"");
		String i_vendor = doString.checkString(req.getParameter("i_vendor"),"");
		String contract_no = doString.checkString(req.getParameter("contract_no"),"");
		String i_job = doString.checkString(req.getParameter("i_job"),"");
		String s_due = doString.checkString(req.getParameter("s_due"),"0");
		String z_due = doString.checkString(req.getParameter("z_due"),"");
		String d_due_date = doString.checkString(req.getParameter("d_due_date"),"");
		String d_due_month = doString.checkString(req.getParameter("d_due_month"),"");
		String d_due_year = doString.checkString(req.getParameter("d_due_year"),"");
		String z_amount = doString.checkString(req.getParameter("z_amount"),"");
		String num_appr = doString.checkString(req.getParameter("num_appr"),"");
		String state = doString.checkString(req.getParameter("state"),"");
		String c_comment = doString.UnicodeToMS874(doString.checkString(req.getParameter("c_comment"),""));
		c_comment = str.replace(c_comment,"\r","");
		c_comment = str.replace(c_comment,"\n","|break|");	
		
		String i_docno = "";
		String i_status = "";
		String s_cur_appr = "";
		String i_cur_appr = "";
		String d_cur_appr = "";
		String n_job = "";
		String d_pay = "";
		String z_accrue = "";
		String s_approver = "";
		String i_approver = "";
		String d_approve = "";
		String curApprId = "";
		String z_amt = "";
		String email = "";
		
		int s_doc = 0;
		int result = 0;
		 try {
			if (ds == null)
				getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
			
			rs = stmt.executeQuery("SELECT n_project FROM lan:acxprojt WHERE i_company = '"+i_company+"' AND i_project = '"+i_project+"'");
			if (rs != null) {
				if (rs.next() == true) {
					site = doString.MS874ToUnicode(doString.checkString(rs.getString(1)));	
				}
				rs.close();
				rs=null;
			}			
		    //----======== Add Mode , Inseitrt Query =========----//
			if (mode.equalsIgnoreCase("ADD")) {
				//Save, SendToApprove
				//start Generate Contract No.
				s_doc = 0;
				sql.delete(0, sql.length());
				sql.append(" select s_doc from lan:serv_cntrl ")
					.append(" where i_company = '"+i_company+"' ")
					.append(" and i_project = '"+i_project+"' ")
					.append(" and i_doc_type = 'C' ")
					.append(" and d_year = '"+yy+"' ");
				rs = stmt.executeQuery(sql.toString());
				if(rs.next()){
					s_doc = rs.getInt("s_doc");
				}
				rs.close();
				
				if(s_doc == 0){
					result = stmt.executeUpdate("insert into lan:serv_cntrl (i_company , i_project , i_doc_type , d_year , s_doc ) values ('"+i_company+"' , '"+i_project+"' , 'C', '"+yy+"', 1) ");
				}else{
					result = stmt.executeUpdate("update lan:serv_cntrl set s_doc = "+(s_doc+1)+" where i_company = '"+i_company+"' and i_project = '"+i_project+"' and i_doc_type = 'C' and d_year = '"+yy+"' ");
				}
				
				i_docno = yy+(mm<10?"0"+mm:""+mm)+String.format("%04d",(s_doc+1));
				//System.out.println("GENERATE DOCUMENT : "+i_docno);
				//end
				
				//SERV_CONHD
				//set init value
				i_status = "A";
				i_cur_appr = "";
				s_cur_appr = "";
				//start insert serv_conhd
				sql.delete(0, sql.length());
				sql.append(" insert into lan:serv_conhd ( ")
					.append(" i_company,i_project,i_docno,i_employ,d_keyin,i_vendor ")
					.append(" ,contract_no,i_phase,d_begin,d_end,i_job,s_due,z_due,d_due,z_amount ")
					.append(" ,i_status,s_cur_appr,i_cur_appr,d_cur_appr,c_comment ) values ( ");
				sql.append("'"+ i_company + "',");
				sql.append("'"+ i_project + "',");
				sql.append("'"+ i_docno + "',");
				sql.append("'"+ user.getEmpId() + "',");
				sql.append("today,");
				sql.append("'"+ i_vendor + "',");
				sql.append("'"+ doString.UnicodeToMS874(contract_no) + "',");
				sql.append("'"+ i_phase + "',");
				sql.append("'"+ start_year +"-"+start_month+"-"+start_date+ "',");
				sql.append("'"+ end_year +"-"+end_month+"-"+end_date+ "',");
				sql.append("'"+ i_job + "',");
				sql.append("'"+ s_due + "',");
				sql.append("'"+ z_due.replace(",", "") + "',");
				sql.append("'"+ d_due_year +"-"+d_due_month+"-"+d_due_date+ "',");
				sql.append("'"+ z_amount.replace(",", "") + "',");
				if("SAVE".equals(state)){
					sql.append("'N',");
					sql.append("1,");
					sql.append("'"+ user.getEmpId() + "',");
				}else{ //SEND
					i_approver = doString.checkString(req.getParameter("approver0"),"");
					sql.append("'W',");
					sql.append("2,");
					sql.append("'"+ i_approver + "',");
				}
				sql.append(" today , ");
				sql.append("'"+doString.UnicodeToMS874(c_comment)+"' )");
				//System.out.println(sql.toString());
				result = stmt.executeUpdate(sql.toString());
				
				//SERV_CONDT
				int dt = Integer.parseInt(s_due);
				for(int i = 0 ; i < dt ; i++){
					d_pay = doString.checkString(req.getParameter("d_pay"+i+"_year"),"");
					d_pay += "-"+doString.checkString(req.getParameter("d_pay"+i+"_month"),"");
					d_pay += "-"+doString.checkString(req.getParameter("d_pay"+i+"_date"),"");
					
					z_amt = doString.checkString(req.getParameter("z_amt"+i),"");
					n_job = doString.checkString(req.getParameter("n_job"+i),"");
					
					sql.delete(0, sql.length());
					sql.append(" insert into lan:serv_condt (")
						.append(" i_company , i_project , i_docno , s_due , n_job , d_pay , z_amount , z_accrue ) values ( ");
					sql.append("'"+ i_company + "',");
					sql.append("'"+ i_project + "',");
					sql.append("'"+ i_docno + "',");
					sql.append((i+1) + ",");
					sql.append("'"+ doString.UnicodeToMS874(n_job) + "',");
					sql.append("'"+ d_pay + "',");
					sql.append(z_amt.replace(",", "") + ",");
					sql.append("0.0 )");
					result = stmt.executeUpdate(sql.toString());
				}
				
				//SERV_CONAP
				sql.delete(0, sql.length());
				sql.append(" insert into lan:serv_conap (")
					.append("i_company , i_project , i_docno , s_approver , i_approver , d_approve , i_status ) values ( ");
				sql.append("'"+ i_company + "',");
				sql.append("'"+ i_project + "',");
				sql.append("'"+ i_docno + "',");
				sql.append(1+",");
				sql.append("'"+ user.getEmpId() + "',");
				if("SAVE".equals(state)){
					sql.append("NULL , ");
					sql.append("'W' ");
				}else{ //SEND
					sql.append("TODAY, ");
					sql.append("'A' ");
				}
				sql.append(" )");
				//System.out.println(sql.toString());
				result = stmt.executeUpdate(sql.toString());
				
				curApprId = "";
				int n_appr = Integer.parseInt(num_appr); //2
				for(int i = 0 ; i < n_appr ; i++){ //0,1
					i_approver = doString.checkString(req.getParameter("approver"+i),"");
					if(i == 0){ //First Approver
						if("SAVE".equals(state)){
							i_status = "N";
						}else{
							i_status = "W";
							curApprId = i_approver;
						}
					}else { //Other Approver
						i_status = "N";
					}
					sql.delete(0, sql.length());
					sql.append(" insert into lan:serv_conap (")
						.append("i_company , i_project , i_docno , s_approver , i_approver , i_status ) values ( ");
					sql.append("'"+ i_company + "',");
					sql.append("'"+ i_project + "',");
					sql.append("'"+ i_docno + "',");
					sql.append((i+2)+",");
					sql.append("'"+ i_approver + "',");
					sql.append("'"+ i_status + "' )");
					//System.out.println(sql.toString());
					result = stmt.executeUpdate(sql.toString());
				}// end for approver
				
				//Approve Mail
				if (!curApprId.equals("")) {
					email = CONMail.findEmail(conn, curApprId);
				}
				if (!email.equals("")) {
					//BB_APPROVE
					stmt.executeUpdate("DELETE FROM docflow:bb_approve WHERE n_system = 'CONSERV' AND i_docno = '"+i_company+i_project+i_docno+"'");
					stmt.executeUpdate("INSERT INTO docflow:bb_approve(n_system, i_company, i_docno, n_desc, i_cur_app, d_keyin, f_status) VALUES('CONSERV', 'LH', '"+i_company+i_project+i_docno+"', '"+doString.UnicodeToMS874("สัญญางานบริการ")+"', '"+curApprId+"', CURRENT, 'W')");
					//MAIL
					try {
						LHMail MailLH = new LHMail();
						String subject = "เอกสารสัญญางานบริการโครงการ : "+i_company+i_project+" "+site+" เลขที่ : "+i_docno+" สถานะเอกสารรอการอนุมัติ";
						String mailtext = CONMail.genConApprMail(conn, i_company, i_project, i_docno, curApprId);
						MailLH.sendBBMail("132.146.1.12", "lh.co.th", "application", email, "", subject, mailtext);
					} catch (Exception e) {
						System.out.println("Send Con Approve Mail ERROR "+mName+" : " + e.getMessage());					
					}				
				}
			} //End If ADD Mode
			
			if (mode.equalsIgnoreCase("APPROVE")) {
				//SERV_ViewContract.jsp
				i_docno = doString.checkString(req.getParameter("i_docno"));
				if(!"".equals(i_docno) && !"".equals(project)){
					int s_appr = 0;
					String requester = "";
					i_approver = "";
					
					sql.delete(0, sql.length());
					sql.append(" select i_employ from lan:serv_conhd ");
					sql.append(" where i_company = '"+i_company+"' and i_project = '"+i_project+"' and i_docno = '"+i_docno+"'");
					rs = stmt.executeQuery(sql.toString());
					if (rs != null) {
						if (rs.next() == true) {
							requester = doString.checkString(rs.getString("i_employ"));
						}
						rs.close();
						rs=null;
					}
					
//					Current Approver
					sql.delete(0, sql.length());
					sql.append(" select s_approver, i_approver from lan:serv_conap ");
					sql.append(" where i_company = '"+i_company+"' and i_project = '"+i_project+"' and i_docno = '"+i_docno+"' ");
					sql.append(" and i_status = 'W'");
					rs = stmt.executeQuery(sql.toString());
					if(rs.next()){
						s_appr = rs.getInt("s_approver");
						i_approver = doString.checkString(rs.getString("i_approver"));
					}
					rs.close();
					rs=null;
					sql.delete(0, sql.length());
					sql.append(" update lan:serv_conap set i_status = 'A', d_approve = TODAY ");
					sql.append(" where i_company = '"+i_company+"' and i_project = '"+i_project+"' and i_docno = '"+i_docno+"' ");
					sql.append(" and s_approver = ");
					sql.append(Integer.toString(s_appr));
					result = stmt.executeUpdate(sql.toString());
					
					//Next Approver
					result = 0;
					sql.delete(0, sql.length());
					sql.append(" update lan:serv_conap set i_status = 'W' ");
					sql.append(" where i_company = '"+i_company+"' and i_project = '"+i_project+"' and i_docno = '"+i_docno+"' ");
					sql.append(" and s_approver = "+(s_appr+1));
					result = stmt.executeUpdate(sql.toString());
					
					if(result <= 0){ //Last Approver
						sql.delete(0, sql.length());
						sql.append(" update lan:serv_conhd set i_status = 'A' , d_cur_appr = today, i_cur_appr = '"+i_approver+"', s_cur_appr = "+s_appr);
						sql.append(" where i_company = '"+i_company+"' and i_project = '"+i_project+"' and i_docno = '"+i_docno+"'");
						result = stmt.executeUpdate(sql.toString());
						//BB_APPROVE
						stmt.executeUpdate("UPDATE docflow:bb_approve SET i_cur_app = '"+i_approver+"', f_status = 'A' WHERE n_system = 'CONSERV' AND i_docno = '"+i_company+i_project+i_docno+"'");
						email = "";
						if (!requester.equals("")) {
							email = CONMail.findEmail(conn, requester);
						}		
						//MAIL
						if (!email.equals("")) {
							try {
								LHMail MailLH = new LHMail();
								String subject = "เอกสารสัญญางานบริการโครงการ : "+i_company+i_project+" "+site+" เลขที่ : "+i_docno+" สถานะเอกสารผ่านการอนุมัติ";
								String mailtext = CONMail.genConApproveMail(i_company, i_project, site, i_docno);
								MailLH.sendBBMail("132.146.1.12", "lh.co.th", "application", email, "", subject, mailtext);
							} catch (Exception e) {
								System.out.println("Send Con Approve Mail ERROR "+mName+" : " + e.getMessage());					
							}
						}
					} else {
						i_approver = "";
						sql.delete(0, sql.length());
						sql.append(" select i_approver from lan:serv_conap ");
						sql.append(" where i_company = '"+i_company+"' and i_project = '"+i_project+"' and i_docno = '"+i_docno+"' ");
						sql.append(" and s_approver = "+(s_appr+1));
						rs = stmt.executeQuery(sql.toString());
						if(rs.next()){
							i_approver = doString.checkString(rs.getString("i_approver"),"");
						}
						rs.close();
						
						sql.delete(0, sql.length());
						sql.append(" update lan:serv_conhd set i_cur_appr = '"+i_approver+"' , s_cur_appr  = "+(s_appr+1)+" , d_cur_appr = today  ");
/*						
						if(s_appr == 1){
							sql.append(" , i_status = 'W' ");
						}
*/						
						sql.append(" where i_company = '"+i_company+"' and i_project = '"+i_project+"' and i_docno = '"+i_docno+"'");
						result = stmt.executeUpdate(sql.toString());
						//BB_APPROVE
						stmt.executeUpdate("UPDATE docflow:bb_approve SET i_cur_app = '"+i_approver+"', f_status = 'W' WHERE n_system = 'CONSERV' AND i_docno = '"+i_company+i_project+i_docno+"'");
						
						//Approve Mail
						email = "";
						if (!i_approver.equals("")) {
							email = CONMail.findEmail(conn, i_approver);
						}				
						if (!email.equals("")) {
							//MAIL
							try {
								LHMail MailLH = new LHMail();
								String subject = "เอกสารสัญญางานบริการโครงการ : "+i_company+i_project+" "+site+" เลขที่ : "+i_docno+" สถานะเอกสารรอการอนุมัติ";
								String mailtext = CONMail.genConApprMail(conn, i_company, i_project, i_docno, i_approver);
								MailLH.sendBBMail("132.146.1.12", "lh.co.th", "application", email, "", subject, mailtext);
							} catch (Exception e) {
								System.out.println("Send Con Approve Mail ERROR "+mName+" : " + e.getMessage());					
							}				
						}						
					}
				}
	 		}// End If APPROVE Mode
			
			if (mode.equalsIgnoreCase("DENY")) {
				//SERV_ViewContract.jsp
				i_docno = doString.checkString(req.getParameter("i_docno"),"");
				if(!"".equals(i_docno) && !"".equals(project)){
					//SERV_CONHD
					String requester = "";
					sql.delete(0, sql.length());
					sql.append(" select i_employ from lan:serv_conhd ");
					sql.append(" where i_company = '"+i_company+"' and i_project = '"+i_project+"' and i_docno = '"+i_docno+"'");
					rs = stmt.executeQuery(sql.toString());
					if (rs != null) {
						if (rs.next() == true) {
							requester = doString.checkString(rs.getString("i_employ"));
						}
						rs.close();
						rs=null;
					}
					sql.delete(0, sql.length());
					sql.append(" update lan:serv_conhd set i_status = 'D'  ");
					sql.append(" where i_company = '"+i_company+"' and i_project = '"+i_project+"' and i_docno = '"+i_docno+"' ");
					result = stmt.executeUpdate(sql.toString());
					
					//SERV_CONAP
					int s_appr = 0;
					sql.delete(0, sql.length());
					sql.append(" select s_approver, i_approver from lan:serv_conap ");
					sql.append(" where i_company = '"+i_company+"' and i_project = '"+i_project+"' and i_docno = '"+i_docno+"' ");
					sql.append(" and i_status = 'W'");
					rs = stmt.executeQuery(sql.toString());
					if(rs.next()){
						s_appr = rs.getInt("s_approver");
					}
					rs.close();
					
					//Current Approver
					sql.delete(0, sql.length());
					sql.append(" update lan:serv_conap set i_status = 'D', d_approve = TODAY ");
					sql.append(" where i_company = '"+i_company+"' and i_project = '"+i_project+"' and i_docno = '"+i_docno+"' ");
					sql.append(" and s_approver = ");
					sql.append(Integer.toString(s_appr));
					result = stmt.executeUpdate(sql.toString());
					
					//BB_APPROVE
					stmt.executeUpdate("UPDATE docflow:bb_approve SET f_status = 'D' WHERE n_system = 'CONSERV' AND i_docno = '"+i_company+i_project+i_docno+"'");
					email = "";
					if (!requester.equals("")) {
						email = CONMail.findEmail(conn, requester);
					}		
					//MAIL
					if (!email.equals("")) {
						try {
							LHMail MailLH = new LHMail();
							String subject = "เอกสารสัญญางานบริการโครงการ : "+i_company+i_project+" "+site+" เลขที่ : "+i_docno+" สถานะเอกสารไม่ผ่านการอนุมัติ";
							String mailtext = CONMail.genConDenyMail(i_company, i_project, site, i_docno);
							MailLH.sendBBMail("132.146.1.12", "lh.co.th", "application", email, "", subject, mailtext);
						} catch (Exception e) {
							System.out.println("Send Con Deny Mail ERROR "+mName+" : " + e.getMessage());					
						}
					}
				}
			}// End If DENY Mode
			
			if (mode.equalsIgnoreCase("UPDATE")) {
				//SERV_Contract.jsp Screen
				i_docno = doString.checkString(req.getParameter("i_docno"),"");
				if(!"".equals(i_docno) && !"".equals(project)){
					
//					SERV_CONHD
					sql.delete(0, sql.length());
					sql.append(" update lan:serv_conhd set  ")
						.append(" i_vendor = '"+i_vendor+"' ")
						.append(" , contract_no = '"+doString.UnicodeToMS874(contract_no)+"' ")
						.append(" , d_begin = '"+start_year +"-"+start_month+"-"+start_date+"' ")
						.append(" , d_end = '"+end_year +"-"+end_month+"-"+end_date+"' ")
						.append(" , i_job = '"+i_job+"' ")
						.append(" , s_due = '"+s_due+"' ")
						.append(" , z_due = '"+z_due.replace(",", "")+"' ")
						.append(" , d_due = '"+d_due_year +"-"+d_due_month+"-"+d_due_date+"' ")
						.append(" , z_amount = '"+z_amount.replace(",", "")+"' ")
						.append(" , i_phase = '"+i_phase+"' ")
						.append(" , c_comment = '"+doString.UnicodeToMS874(c_comment)+"' ");
					if("SEND".equals(state)){ //SendToApprove
						sql.append(" , i_status = 'W' ")
						.append(" , s_cur_appr = 2 ")
						.append(" , i_cur_appr = '"+doString.checkString(req.getParameter("approver0"),"")+"' ")
						.append(" , d_cur_appr = today ");
					}
					sql.append(" where i_company = '"+i_company+"' and i_project = '"+i_project+"' and i_docno = '"+i_docno+"' ");
					result = stmt.executeUpdate(sql.toString());
					
					//SERV_CONDT
					sql.delete(0, sql.length());
					sql.append(" delete from lan:serv_condt ");
					sql.append(" where i_company = '"+i_company+"' and i_project = '"+i_project+"' and i_docno = '"+i_docno+"' ");
					result = stmt.executeUpdate(sql.toString());
					int dt = Integer.parseInt(s_due);
					for(int i = 0 ; i < dt ; i++){
						d_pay = doString.checkString(req.getParameter("d_pay"+i+"_year"),"");
						d_pay += "-"+doString.checkString(req.getParameter("d_pay"+i+"_month"),"");
						d_pay += "-"+doString.checkString(req.getParameter("d_pay"+i+"_date"),"");
						
						z_amt = doString.checkString(req.getParameter("z_amt"+i),"");
						n_job = doString.checkString(req.getParameter("n_job"+i),"");
						
						sql.delete(0, sql.length());
						sql.append(" insert into lan:serv_condt (")
							.append(" i_company , i_project , i_docno , s_due , n_job , d_pay , z_amount , z_accrue ) values ( ");
						sql.append("'"+ i_company + "',");
						sql.append("'"+ i_project + "',");
						sql.append("'"+ i_docno + "',");
						sql.append((i+1) + ",");
						sql.append("'"+ doString.UnicodeToMS874(n_job) + "',");
						sql.append("'"+ d_pay + "',");
						sql.append(z_amt.replace(",", "") + ",");
						sql.append("0.0 )");
						System.out.println(sql.toString());
						result = stmt.executeUpdate(sql.toString());
						System.out.println("INSERT SERV_CONDT + "+result+" ROW");
					}
					
					//SERV_CONAP
					if("SEND".equals(state)){ //SendToApprove
						//Requester
						sql.delete(0, sql.length());
						sql.append(" update lan:serv_conap set i_status = 'A', d_approve = TODAY ");
						sql.append(" where i_company = '"+i_company+"' and i_project = '"+i_project+"' and i_docno = '"+i_docno+"' and s_approver = 1 ");
						result = stmt.executeUpdate(sql.toString());
					}
					
					//Approver
					sql.delete(0, sql.length());
					sql.append(" delete from lan:serv_conap ");
					sql.append(" where i_company = '"+i_company+"' and i_project = '"+i_project+"' and i_docno = '"+i_docno+"' and s_approver > 1 ");
					result = stmt.executeUpdate(sql.toString());
					
					curApprId = "";
					int n_appr = Integer.parseInt(num_appr);
					for(int i = 0 ; i < n_appr ; i++){
						i_approver = doString.checkString(req.getParameter("approver"+i),"");
						if(i == 0){ //First Approver
							if("SAVE".equals(state)){
								i_status = "N";
							}else{
								i_status = "W";
								curApprId = i_approver;
							}
						}else{
							i_status = "N";
						}
						
						sql.delete(0, sql.length());
						sql.append(" insert into lan:serv_conap (")
							.append("i_company , i_project , i_docno , s_approver , i_approver , i_status ) values ( ");
						sql.append("'"+ i_company + "',");
						sql.append("'"+ i_project + "',");
						sql.append("'"+ i_docno + "',");
						sql.append((i+2)+",");
						sql.append("'"+ i_approver + "',");
						sql.append("'"+ i_status + "' )");
						result = stmt.executeUpdate(sql.toString());
					}// end for approver
					//Approve Mail
					email = "";
					if (!curApprId.equals("")) {
						email = CONMail.findEmail(conn, curApprId);
					}
					if (!email.equals("")) {
						//BB_APPROVE
						stmt.executeUpdate("DELETE FROM docflow:bb_approve WHERE n_system = 'CONSERV' AND i_docno = '"+i_company+i_project+i_docno+"'");
						stmt.executeUpdate("INSERT INTO docflow:bb_approve(n_system, i_company, i_docno, n_desc, i_cur_app, d_keyin, f_status) VALUES('CONSERV', 'LH', '"+i_company+i_project+i_docno+"', '"+doString.UnicodeToMS874("สัญญางานบริการ")+"', '"+curApprId+"', CURRENT, 'W')");
						//MAIL
						try {
							LHMail MailLH = new LHMail();
							String subject = "เอกสารสัญญางานบริการโครงการ : "+i_company+i_project+" "+site+" เลขที่ : "+i_docno+" สถานะเอกสารรอการอนุมัติ";
							String mailtext = CONMail.genConApprMail(conn, i_company, i_project, i_docno, curApprId);
							MailLH.sendBBMail("132.146.1.12", "lh.co.th", "application", email, "", subject, mailtext);
						} catch (Exception e) {
							System.out.println("Send Con Approve Mail ERROR "+mName+" : " + e.getMessage());					
						}				
					}
				}
			}// End If UPDATE Mode
			
			if (mode.equalsIgnoreCase("DELETE")) {
				i_docno = doString.checkString(req.getParameter("i_docno"),"");
				if(!"".equals(i_docno) && !"".equals(project)){
					//SERV_CONHD
					sql.delete(0, sql.length());
					sql.append(" delete from lan:serv_conhd ");
					sql.append(" where i_company = '"+i_company+"' and i_project = '"+i_project+"' and i_docno = '"+i_docno+"' ");
					result = stmt.executeUpdate(sql.toString());
					//SERV_CONDT
					sql.delete(0, sql.length());
					sql.append(" delete from lan:serv_condt ");
					sql.append(" where i_company = '"+i_company+"' and i_project = '"+i_project+"' and i_docno = '"+i_docno+"' ");
					result = stmt.executeUpdate(sql.toString());
					//SERV_CONAP
					sql.delete(0, sql.length());
					sql.append(" delete from lan:serv_conap ");
					sql.append(" where i_company = '"+i_company+"' and i_project = '"+i_project+"' and i_docno = '"+i_docno+"' ");
					result = stmt.executeUpdate(sql.toString());
					i_vendor = "";
					i_job = "";
				}
			}// End If DELETE Mode
			
			//conn.rollback();
			conn.commit();
			stmt.close();
			conn.close();
			stmt = null;
			conn = null;
			successPage += "search=Y&project="+project+"&i_vendor="+i_vendor+"&i_job="+i_job;
			genRedirectCode(out,savePage,successPage,errorCode,otherMsg);
		} catch (Exception e) {
			if (e instanceof InvalidParameterException) {
				showError(out, doString.UnicodeToMS874(e.getMessage()));
			} else {           
				System.out.println(" ERROR "+mName+" : " + e.getMessage());
				System.out.println(" ERROR "+mName+" SQL : " + sql.toString());
			}
			try {
				if (conn != null) conn.rollback();
			} catch (SQLException ignore) {
			}
			genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ "+e.getMessage());
		} finally {
			out.close();
			try {
				if (rs!=null) rs.close(); 
				if (stmt != null) stmt.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");

	}

}
