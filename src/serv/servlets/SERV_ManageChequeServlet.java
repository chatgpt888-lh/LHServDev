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
public class SERV_ManageChequeServlet extends DBServlet  {
	
	 
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
		 
		 while (str.indexOf(",")>0) {
		 	str = str.substring(0,str.indexOf(","))+str.substring(str.indexOf(",")+1);
		 } // end while
		 
		 try {
		 	result = Double.parseDouble(str);
		 } catch (Exception e) {
		 	result = 0.0; 
		 }
		 
		 return result;
	}
	
	public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		String mName = new String(this.getClass().getName() + ".performTask: ");
		System.out.println(mName + "start.");


/*
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
     
 
		User user = (User) obj;*/
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
		
	
		String iDocNo = doString.checkString(req.getParameter("i_docno"),"");
		String nRecvChq = doString.UnicodeToMS874(doString.checkString(req.getParameter("n_recv_chq"),""));
		String actionFlag = doString.checkString(req.getParameter("action_flag"),"");
		String pvAcct = doString.checkString(req.getParameter("pv_acct"),"");
		String iEmploy = doString.checkString(req.getParameter("i_employ"),""); // 2025-05-06

		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_RetenHome.jsp?i_docno="+iDocNo;
		String errorPage = "";
		
		if (actionFlag.equals("A")) {		
			successPage = " SERV_Conf_ARecevChq.jsp?i_docno="+iDocNo;
			errorPage = "SERV_Conf_ARecvChq.jsp?error=1&refresh=yes&i_docno="+iDocNo;
		} else if (actionFlag.equals("K")) {		
		    errorPage = "SERV_Conf_SRecvChq.jsp?error=1&refresh=yes&i_docno="+iDocNo;
		} else if (actionFlag.equals("E")) {		
			errorPage = "SERV_Conf_CRecvChq.jsp?error=1&refresh=yes&i_docno="+iDocNo;
		} else {
			errorPage = "SERV_RetenHome.jsp?error=1&refresh=yes&i_docno="+iDocNo;
		}
		
		String otherMsg = "";
		String errorCode = "";
		
		doString str = new doString();
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
		   sql.delete(0,sql.length());
		   
		   
		   
		   //-----===================== Confirm By Accounting  =========================-----//				
		   if (actionFlag.equals("A")) {				   
			   
				//----- 2022-11-07 , get pvaccount for payto and payin -----//
				String pvPayToBank = "";
				String pvPayToBran = "";
				String pvPayToAcType = "";	
				String pvPayToAcct = ""; // 2025-05-06
				String pvPayInBank = "";
				String pvPayInBran = "";
				String pvPayInAcType = "";	
				String pvPayInAcct = ""; // 2025-05-06
				
				if (pvAcct.length()>0) {
					String tmpPV = "";
					String tmpPayIn = "";
					
					if (pvAcct.indexOf("#")>0) {
						tmpPV = pvAcct.substring(0,pvAcct.indexOf("#")); 
						tmpPayIn = pvAcct.substring(pvAcct.indexOf("#")+1); 
					}
					
					if (tmpPV.length()>0) {
						StringTokenizer tmp = new StringTokenizer(tmpPV,"-");
						if (tmp.countTokens()>=4) {
							pvPayToBank = doString.checkString(tmp.nextToken(),"").trim();
							pvPayToBran = doString.checkString(tmp.nextToken(),"").trim();
							pvPayToAcType = doString.checkString(tmp.nextToken(),"").trim();
							pvPayToAcct = doString.checkString(tmp.nextToken(),"").trim(); // 2025-05-06
						}
					}
					if (tmpPayIn.length()>0) {
						StringTokenizer tmp = new StringTokenizer(tmpPayIn,"-");
						if (tmp.countTokens()>=4) {
							pvPayInBank = doString.checkString(tmp.nextToken(),"").trim();
							pvPayInBran = doString.checkString(tmp.nextToken(),"").trim();
							pvPayInAcType = doString.checkString(tmp.nextToken(),"").trim();
							pvPayInAcct = doString.checkString(tmp.nextToken(),"").trim(); // 2025-05-06
						}
					}								
				} else {
					throw new InvalidParameterException("ERROR_NO_PV_ACCOUNT");								
				}
				//----------------------------------------------------------//		  
				
		   	     
		   	     String[] confId = req.getParameterValues("conf_id");
		   	     if (confId!=null) {
					String retCustType = "";
					String iCompany = "";
					String iProject = "";
					String iReten = "";
					String retCustName = "";
					String iPayType = "";
					double zPayback = 0.0;
					
					//--- 2025-05-06 , for pv ---//
					String iSort = ""; 
					String dKeyIn = "";
					String iStaff = "";
					String dept = "";
					double zRecvReten = 0.0;
					double zDamage = 0.0;
	   	     	
		   	     	 for (int c=0;c<confId.length;c++) {
							retCustType = "";
							iCompany = "";
							iProject = "";
							iReten = "";
							retCustName = "";
							iPayType = "";
							zPayback = 0.0;
							
							//--- 2025-05-06 , for pv ---//
							iSort = ""; 
							dKeyIn = "";
							iStaff = "";	
							zRecvReten = 0.0;
							zDamage = 0.0;							
							
							String dPayTo = doString.checkString(req.getParameter("d_payto"+confId[c]),"");
							if (dPayTo.trim().length()==10) {
								int pYear = Integer.parseInt(dPayTo.substring(6,10));
								if (pYear>2400) pYear -= 543;
								dPayTo = pYear+"-"+dPayTo.substring(3,5)+"-"+dPayTo.substring(0,2);
							}
							
							//-----======== Get Reten Data ==========----//
							sql.delete(0,sql.length());
							sql.append(" select * from lan:serv_rethd where i_docno='").append(confId[c]).append("' ");
							rs = stmt.executeQuery(sql.toString());
							if (rs.next()) {
								iCompany = doString.checkString(rs.getString("i_company"),"");
								iProject = doString.checkString(rs.getString("i_project"),"");
								retCustType = doString.checkString(rs.getString("i_ret_custo"),"");
								iReten = doString.checkString(rs.getString("i_reten"),"");
								zPayback = rs.getDouble("z_payback");								
								iPayType =  doString.checkString(rs.getString("i_paytype"),""); // 2022-11-07
								
								//--- 2025-05-06 , for pv ---//
								iSort = doString.checkString(rs.getString("i_sort"),""); 
								dKeyIn =  doString.checkString(rs.getString("d_keyin"),"");
								iStaff =  doString.checkString(rs.getString("i_staff"),"");
								zRecvReten = rs.getDouble("z_recv_reten");	
								zDamage = rs.getDouble("z_damage");
								if (iPayType.trim().length()<=0) {
									iPayType = "PAYTO"; // default to PAYTO
								}
								
								//--- remove time from date ---//
								if (dKeyIn.length()>10) {
									dKeyIn = dKeyIn.substring(0,10);
								}
							}
							rs.close();
							
							
							//---- check account before update ----//
							
							if (iPayType.equalsIgnoreCase("PAYIN")) {
								if (pvPayInBank.length()<=0 || pvPayInBran.length()<=0 || pvPayInAcType.length()<=0 || pvPayInAcct.length()<=0) {
									throw new InvalidParameterException("ERROR_NO_PAYIN_ACCOUNT");
								}
							} else {
								if (pvPayToBank.length()<=0 || pvPayToBran.length()<=0 || pvPayToAcType.length()<=0 || pvPayToAcct.length()<=0) {
									throw new InvalidParameterException("ERROR_NO_PAYTO_ACCOUNT");
								}								
							}
							
							
							/*
							 *   2022-11-07 , cancel this method , use new method on top of this
							 *
							//----- Read Bank name , branch and account , 2011-02-11 --------//		
							String pvBank = "";
							String pvBran = "";
							String pvAcc = "";	
							 
							//------ check pv account from request -----//
							if (pvAcct.length()>0) {
								StringTokenizer tmp = new StringTokenizer(pvAcct,":");
								if (tmp.countTokens()>=3) {
									pvBank = tmp.nextToken();
									pvBran = tmp.nextToken();
									pvAcc = tmp.nextToken();
								}
							}
							
							//------ no pv account from request , get from table ------//
							if (pvBank.length()<=0 || pvBran.length()<=0 || pvAcc.length()<=0) {
								sql.delete(0,sql.length());
								sql.append(" select * from docflow:icv_acctn where i_system='RET' ")
									  .append(" and i_com_exp='").append(iCompany).append("' ");		  
								rs = stmt.executeQuery(sql.toString());
								if (rs.next()) {
									pvBank = doString.checkString(rs.getString("i_pv_bank"),"");
									pvBran = doString.checkString(rs.getString("i_pv_bran"),"");
									pvAcc = doString.checkString(rs.getString("i_pv_acctyp"),"");
								} 
								rs.close();		
							}
		   	     	 		*/
														
		   	     	 		
							//-----========== Get retCustName ============-----//
							sql.delete(0,sql.length());
							if (retCustType.equals("1")) {
								sql.append(" select trim(n_prename)||trim(n_ncustomer)||' '||trim(n_scustomer) as cust_name ")
									  .append(" from lan:acxcusto where i_customer='").append(iReten).append("' ");
							} else if (retCustType.equals("2")) {
								sql.append(" select trim(nvl(n_pname,''))||trim(nvl(n_name,''))||' '||trim(nvl(n_sname,'')) as cust_name ")
									  .append(" from lan:serv_venprj where i_vendor='").append(iReten).append("' ")
									  .append(" and i_company='").append(iCompany).append("' and i_project='").append(iProject).append("' ")
									  .append(" and i_type='05' ");
							} else {
								sql.append(" select trim(nvl(n_pname,''))||trim(nvl(n_name,''))||' '||trim(nvl(n_sname,'')) as cust_name ")
									  .append(" from lan:serv_venprj where i_vendor='").append(iReten).append("' ")
									  .append(" and i_company='").append(iCompany).append("' and i_project='").append(iProject).append("' ")
									  .append(" and i_type='06' ");
							}
							rs = stmt.executeQuery(sql.toString());
							if (rs.next()) {
								retCustName = doString.checkString(rs.getString("cust_name"),"");
							}
							rs.close();
			   	     	 		
		   	     	 	
		   	     	 		//---======== Update SERV_RETHD ========----//
							sql.delete(0,sql.length());
							sql.append(" update lan:serv_rethd set ")							
							   .append(" i_doc_status='A' , d_ac_conf=today , ")		       		
							   .append(" i_vendor='9' , d_payto='"+dPayTo+"' , ");
							//   .append(" i_pv_bank='").append(pvBank).append("' , ")	  //		 	
							//   .append(" i_pv_bran='").append(pvBran).append("' , ")	  //  modified 2011-02-11			 	
							//   .append(" i_acctyp='").append(pvAcc).append("' , ")      //
							//----- 2022-11-07 -----//
							if (iPayType.equalsIgnoreCase("PAYIN")) {
								sql.append(" i_pv_bank='").append(pvPayInBank).append("' , ")		 	
								   .append(" i_pv_bran='").append(pvPayInBran).append("' , ")			 	
								   .append(" i_acctyp='").append(pvPayInAcType).append("' , ");								
							} else {
								sql.append(" i_pv_bank='").append(pvPayToBank).append("' , ")		 	
								   .append(" i_pv_bran='").append(pvPayToBran).append("' , ")			 	
								   .append(" i_acctyp='").append(pvPayToAcType).append("' , ");								
							}
							//----------------------//
						    sql.append(" n_payto='").append(retCustName).append("' ")		       		
							   .append(" where i_docno='").append(confId[c]).append("' ");							    
						    stmt.executeUpdate(sql.toString());


							//---======== Insert SERV_RVCQ ===========---//
							sql.delete(0,sql.length());
							sql.append("insert into lan:serv_rvcq (i_company,i_docno,i_com_exp,i_seq,i_payto,n_payto,d_payto,z_chq_amt,f_status ")
							   .append(" ) values ( ")
							   .append(" 'LH' , ")
							   .append(" '").append(confId[c]).append("' , ")
							   .append(" '").append(iCompany).append("' , ")
							   .append(" 1 , '9' ,")
							   .append(" '").append(retCustName).append("' , ")
							   .append(" '"+dPayTo+"' , ")
							   .append(" ").append(zPayback).append(" , ")
							   .append(" 'N' ) ");								
							stmt.executeUpdate(sql.toString());
						   
							
							//---=================== 2025-05-06 , insert new lee's table for pv ===================---//
							
							//--- re-check n_payto ---//
							if (retCustName.trim().length()<=0) {
								sql.delete(0,sql.length());
								sql.append(" select n_reten from lan:serv_payin where i_docno='"+confId[c]+"' ");									
								rs = stmt.executeQuery(sql.toString());
								if (rs.next()) {
									retCustName = doString.checkString(rs.getString("n_reten"),"");
								} 
								rs.close();	
								
								if (retCustName.trim().length()<=0) {
									throw new Exception("N_PAYTO_ERROR");
								}
							}
							
							//--- find dept of i_staff ---//
							dept = "";
							sql.delete(0,sql.length());
							sql.append(" select d.a_dept from docflow:acempjob j ")
							   .append(" left join docflow:icv_dept d on d.i_code=j.i_division ")
							   .append(" where j.i_employ='"+iStaff+"' ")
							   .append(" and j.d_job in (select max(d_job) from docflow:acempjob where j.i_employ = i_employ) ");
							rs = stmt.executeQuery(sql.toString());
							if (rs.next()) {
								dept = doString.checkString(rs.getString("a_dept"),"");
							}  
							rs.close();								
							
							//--- 2025-05-06 , insert pv header ---//
							sql.delete(0,sql.length());
							sql.append(" insert into lan:acc_trantopv_hd ( ")
							   .append(" i_type_gl,		i_system,		i_company,			i_project, ") // 1-4
							   .append(" i_lock,		i_document,		d_document,			i_requester, ") // 5-8
							   .append(" i_vendor,		vendor_name,	i_payto,			i_mtax, ") // 9-12
							   .append(" i_scr_desc,	i_bank,			i_branch,			i_account, ") // 13-16
							   .append(" cash_acct, 	z_amount,		i_ap_type,			d_cheque, ") // 17-20
							   .append(" pay_to_name,	i_pvno, 		d_pvno,				i_employ_postpv, ") // 21-24
							   .append(" d_post_pv,		d_insert, 		i_employ_insert,	i_dept, ") // 25-28
							   .append(" i_dept_oth, 	f_cheque_add,	f_posted ") // 29-31
							   .append(" ) values ( ")
							   .append(" 'PV', 'RET', '"+iCompany+"', '"+iProject+"', '"+iSort+"', ") // 1-5
							   .append(" '"+confId[c]+"', '"+dKeyIn+"', '"+iStaff+"', '9',") // 6-9
							   .append(" '"+doString.MS874ToUnicode(retCustName)+"', '"+iPayType+"', ") // 10-11
							   .append(" 'NONTAX', '"+iSort+" คืนเงินประกันต่อเติม ("+confId[c]+")', "); // 12-13
							if (iPayType.equalsIgnoreCase("PAYIN")) {
								sql.append(" '").append(pvPayInBank).append("', ") // 14
								   .append(" '").append(pvPayInBran).append("', ") // 15			 	
								   .append(" '").append(pvPayInAcType).append("', ") // 16								
								   .append(" '").append(pvPayInAcct).append("', "); // 17	
							} else {
								sql.append(" '").append(pvPayToBank).append("', ") // 14		 	
								   .append(" '").append(pvPayToBran).append("', ") // 15			 	
								   .append(" '").append(pvPayToAcType).append("', ") // 16								
								   .append(" '").append(pvPayToAcct).append("', "); // 17	
							}							
							sql.append(" '"+doString.displayNumber("######0.00",zPayback)+"', ") // 18
							   .append(" '1', '"+dPayTo+"','"+doString.MS874ToUnicode(retCustName)+"',null, ") // 19-22
							   .append(" '"+dPayTo+"', null, null, current, '"+iEmploy+"', ") // 23-27
							   .append(" '"+dept+"', '"+dept+"', 'N', 'N' ") //28-31
							   .append(" ) ");
							stmt.executeUpdate(doString.UnicodeToMS874(sql.toString()));

							//--- insert pv details ---//
							if (zRecvReten==(zPayback+zDamage)) {
								String iAcctNo[] = null;
								double zGoodsAmt[] = null;
								
								if (zRecvReten==zPayback) {
									// 1.1) z_recv_retrn = z_payback , insert 1 record with z_payback
									iAcctNo = new String[]{"21603"};
									zGoodsAmt = new double[]{zPayback};  
								} else {
									// 1.2) z_recv_retrn = z_payback + z_damage , insert 2 records with z_recv_reten and -z_damage
									iAcctNo = new String[]{"21603","54012"};
									zGoodsAmt = new double[]{zRecvReten,zDamage*-1}; 
								}								
	
								if (iAcctNo==null) {
									throw new Exception("I_ACCT_NO_ERROR");
								} else {
									for (int i=0;i<iAcctNo.length;i++) {
										sql.delete(0,sql.length());
										sql.append(" insert into lan:acc_trantopv_dt ( ")
										   .append(" i_type_gl,		i_system,		i_company,		i_project, ") // 1-4
										   .append(" i_document,	i_expense,		i_acctno,		i_mtax, ") // 5-8 
										   .append(" i_house_type,	z_goods_amt,	z_dist_amt,		i_vat_acct, ") // 9-12
										   .append(" z_vat_amt,		i_tax_acct,		z_tax_amt,		i_src_desc, ") // 13-16
										   .append(" i_seq,			i_ven_cut,		i_docno,		i_employ_postpvcut,	") // 17-20
										   .append(" d_post_cut,	i_dept_dt ")  // 21-22
										   .append(" ) values ( ")
										   .append(" 'PV', 'RET', '"+iCompany+"', '"+iProject+"', ") // 1-4
										   .append(" '"+confId[c]+"', null, '"+iAcctNo[i]+"', 'NONTAX', null, ") // 5-9	
										   .append(" '"+doString.displayNumber("######0.00",zGoodsAmt[i])+"', ") // 10
										   .append(" '"+doString.displayNumber("######0.00",zGoodsAmt[i])+"', ") // 11
										   .append(" '11960', 0.0, '11960', 0.0, ") // 12-15		
										   .append(" '"+iSort+" คืนเงินประกันต่อเติม ("+confId[c]+")', ") // 16
										   .append(" "+(i+1)+", null, null, null, null, '"+dept+"' ") // 12-15
										   .append(" ) ");										
										stmt.executeUpdate(doString.UnicodeToMS874(sql.toString()));
									} // end for										
								}
								
							} else {
								throw new Exception("RECV_SUMMARY_ERR : "+zRecvReten+"!="+zPayback+"+"+zDamage);
							}
							//---==================================================================================---//
						   		   	     	 	
		   	     	 } // end for
		   	     }
				
						
				//-----================ Read Status Details for use in E-Mail ==============-----//
				String statusDesc = "";					
				sql.delete(0,sql.length());
				sql.append(" select n_desc from lan:serv_xstd where i_type='60' ")
					  .append(" and i_code='").append(actionFlag).append("' ");	
				rs = stmt.executeQuery(sql.toString());
				if (rs.next()) {
					statusDesc = doString.checkString(rs.getString("n_desc"),"");
				} 
				rs.close();		
				//-----=============================================================-----//						
		
		
		
				//-----============ Read i_reten_payback Name for use in E-Mail ==========-----//
				String retenEmp = "";
				String retenEmail = "";
				String iSort = "";				
				sql.delete(0,sql.length());
				sql.append(" select trim(b.n_prename_th)||trim(b.n_nemploy_th)||' '||trim(b.n_semploy_th) ")
					  .append(" as emp_name,c.user_email,a.i_sort from lan:serv_rethd a ")
					  .append(" left join docflow:acemploy b on b.i_employ=a.i_reten_payback ")
					  .append(" left join lan:useracl c on c.i_employ=a.i_reten_payback and c.user_acl='S' ")
					  .append(" where a.i_docno='").append(iDocNo).append("' ");
				rs = stmt.executeQuery(sql.toString());
				if (rs.next()) {
					retenEmp = doString.checkString(rs.getString("emp_name"),"");
					retenEmail = doString.checkString(rs.getString("user_email"),"");
					iSort = doString.checkString(rs.getString("i_sort"),"");
				} 
				rs.close();
				//-----=============================================================-----//		
					
		
	
				
				//----- Read Approver Details for send mail --------//	
				String ccEmail = "";					
				sql.delete(0,sql.length());
				sql.append(" select * from lan:useracl a, lan:serv_apprv b where b.d_apprv is not null and ")
				      .append(" b.i_doc_status in ('O','V') and a.user_acl='S' and a.i_employ=b.i_apprv ")
				      .append(" and b.i_docno='").append(iDocNo).append("' ");
				rs = stmt.executeQuery(sql.toString());
				while (rs.next()) {
					if (ccEmail.trim().length()>0) ccEmail += " , ";  
					ccEmail += doString.checkString(rs.getString("user_email"),"");
				} 
				rs.close();	
				
								
				//------ Validate Email before send ------//
				if (retenEmail.trim().length()>0 || ccEmail.trim().length()>0) {
					String subject = " เอกสารขอคืนเงินค้ำประกัน เลขที่ "+iDocNo+" สถานะ "+statusDesc;
					subject = doString.UnicodeToMS874(subject);
					String header = "<HTML><HEAD><TITLE></TITLE><META http-equiv=\"Content-Type\" content=\"text/html; charset=TIS-620\"><META http-equiv=\"Content-Language\" content=\"th\"></HEAD><BODY BGCOLOR=\"#FFFFFF\"><FONT size=\"2\" face=\"Microsoft Sans Serif\">";
					String footer = "</FONT></BODY></HTML>";					
					String mailText = " เอกสารขอคืนเงินค้ำประกัน เลขที่ "+iDocNo+" แปลงขาย "+iSort+" ของ "+retenEmp+" สถานะ "+statusDesc;
					mailText += "<br> โดยคาดว่าจะส่งเช็คคืน ที่ Center กลุ่ม ภายใน 7 วัน หลังจากที่รับ Mail ";
					mailText = doString.UnicodeToMS874(mailText);				
	
					LHMail mail = new LHMail();
					// 2014-07-04 , change mail method mail.sendMailHtml(Constants.LH_HOST,Constants.LH_DOMAIN,Constants.BOQ_SENDER,retenEmail,"",subject,header+mailText+footer);																	
					//mail.sendBBMail(Constants.LH_HOST,Constants.LH_DOMAIN,Constants.BOQ_SENDER,retenEmail,"",subject,header+mailText+footer);
				} // end if validate
		   } 
		   //-----=================================================================-----//		   
		   
		   
		   
		   
		   
		   //-----==================== Confirm Return Cheque  ========================-----//									
		   else if (actionFlag.equals("K")) {
			    String iCheque = doString.UnicodeToMS874(doString.checkString(req.getParameter("i_cheque"),""));
			    String zCheque = doString.UnicodeToMS874(doString.checkString(req.getParameter("z_cheque"),"0"));
			    
				 sql.delete(0,sql.length());
				 sql.append(" update lan:serv_rethd set ")
					   .append(" i_doc_status='K' , d_srecv_chq=today , ")		       		
					   .append(" i_cheque='").append(iCheque).append("' , ")					 
					   .append(" z_cheque='").append(zCheque).append("' ")				 
				 	   .append(" where i_docno='").append(iDocNo).append("' ");					 	   				 
			    stmt.executeUpdate(sql.toString());
		   } 
		   //-----================================================================-----//


		   
		   
		   //-----================ Save Customer receive Cheque ====================-----//									
		   else if (actionFlag.equals("E")) {		
				sql.delete(0,sql.length());
				sql.append(" update lan:serv_rethd set ")
					  .append(" i_doc_status='E' , d_crecv_chq=today , ")
					  .append(" n_recv_chq='").append(nRecvChq).append("' ")		       		
					  .append(" where i_docno='").append(iDocNo).append("' ");					  					 
			   stmt.executeUpdate(sql.toString());		   	
		   }		   			
		   //-----================================================================-----//
		   			
		   					   			
		   
		 conn.commit();
		 //conn.rollback();
		 stmt.close();
		 conn.close();
		 conn = null;
					
		 // Redirect to the finish page.
		 //res.sendRedirect(doString.UnicodeToMS874(successPage));
		 genRedirectCode(out,savePage,successPage,errorCode,otherMsg);
						
		}catch (Exception e) {
			if (e instanceof InvalidParameterException) {
				showError(out, doString.UnicodeToMS874(e.getMessage()));
		    } else {          
				System.out.println(" ERROR "+mName+" : " + e.getMessage());
				System.out.println(" ERROR "+mName+" SQL : " + sql.toString());
		    }
			
			//res.sendRedirect(errorPage);
			//System.out.println("error = "+errorPage);
			//genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ "+e.getMessage());
			
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