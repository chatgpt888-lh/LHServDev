package serv.servlets;
import java.io.*;
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

/**
 * @version 	1.0
 * @author
 */

/**
 * Modify by : pradoem@lh.co.th
 * date : 2015.04.28
 * version 1.1
 * desc: 
 */ 
public class SERV_StaffConfServlet extends DBServlet  {
	
	private void genRedirectCode(PrintWriter out,String page,String redirect,String error,String otherMsg) {
		out.println("<form method='post' action='"+page+"'>");		
		out.println("<input type='hidden' name='error' value='"+error+"'>");
		out.println("<input type='hidden' name='other_msg' value='"+doString.MS874ToUnicode(otherMsg)+"'>");
		out.println("<input type='hidden' name='redirect_url' value='"+doString.MS874ToUnicode(redirect)+"'>");		
		out.println("<script> document.forms[0].submit();</script>");
		out.println("</form>");		
	}
	
	public String moveFile(String uploadPath,String targetPath,String fileName) throws Exception {
		String newName = "";
		File file = new File(uploadPath,fileName);
		if (fileName.length()>0 && file.exists()) {
			File targetFile = new File(targetPath,fileName);
			if (targetFile.exists()) {
				targetFile.delete();			
			}			
			file.renameTo(targetFile);
			newName = targetFile.getName();
		}
		
		return newName;						
	}

	public boolean XsaveUpload(HttpSession session,Statement stmt,String iDocNo,String sessionId) {// throws Exception {

		String uploadId = doString.checkString((String) session.getAttribute("session_upload_id"),"");
		if (uploadId.trim().length()<=0) {
			 uploadId = sessionId;
			 session.setAttribute("session_upload_id",uploadId);
		}
		String targetPath = getServletContext().getRealPath("/pictures/")+File.separator+iDocNo;
		String uploadPath = getServletContext().getRealPath("/pictures/temp/")+File.separator+uploadId;
		
		boolean isSaveUpload = true;
		try{
				String keyFile = "";
				
				String fileNameBefore = "";
				String realFileBefore = "";
				String fileNameBefore2 = "";
				String realFileBefore2 = "";
				
				String fileNameProcess = "";
				String realFileProcess = "";
				String fileNameProcess2 = "";
				String realFileProcess2 = "";
							
				String fileNameAfter = "";
				String realFileAfter = "";
				String fileNameAfter2 = "";
				String realFileAfter2 = "";
				
				StringTokenizer data = null;
				StringBuffer sql = new StringBuffer();
				File file = null;
				File targetFile = null;
				Vector fileList = new Vector();
				
				//String iDoc = "";
				String seqId = "";
				String jobItem = "";
				String vendor = "";
				String area = "";
		
				//------- check folder -----------//
				File target = new File(targetPath);
				if (!target.exists()) {
					target.mkdirs();
				}		
		
				//---------- clear old file data ----------//
				/*sql.delete(0,sql.length());
				sql.append(" delete from lan:serv_docatt where i_docno='"+iDocNo+"' ");
				stmt.executeUpdate(sql.toString());
				//System.out.println(sql.toString());*/

				//---------- insert new file data ----------//
				Vector keyList = new Vector();
				Enumeration keys = session.getAttributeNames();
				while (keys.hasMoreElements()) {
					String key = (String) keys.nextElement();
					if (key.indexOf("session_upload_")>=0) {
						keyFile = "";				
						if (key.indexOf("session_upload_before_")>=0) {
							keyFile = key.substring(key.indexOf("session_upload_before_")+22);
						} else if (key.indexOf("session_upload_before2_")>=0) {
							keyFile = key.substring(key.indexOf("session_upload_before2_")+23);
						} else if (key.indexOf("session_upload_process_")>=0) {
							keyFile = key.substring(key.indexOf("session_upload_process_")+23);
						} else if (key.indexOf("session_upload_process2_")>=0) {
							keyFile = key.substring(key.indexOf("session_upload_process2_")+24);
						} else if (key.indexOf("session_upload_after_")>=0) {
							keyFile = key.substring(key.indexOf("session_upload_after_")+21);
						} else if (key.indexOf("session_upload_after2_")>=0) {
							keyFile = key.substring(key.indexOf("session_upload_after2_")+22);
						}
						if (keyFile.trim().length()>0 && !keyList.contains(keyFile)) {
							keyList.addElement(keyFile);
						}
					}	
				 } // end while
						
				int SEQ = 1;
				String i_keygen = "";
				
				//System.out.println("==========> "+keyList.size());
				if(keyList.size()>0){
					sql.delete(0,sql.length());
					sql.append(" delete from lan:serv_docatt where i_docno='"+iDocNo+"' ");
					stmt.executeUpdate(sql.toString());
					//System.out.println(sql.toString());
				
				  for (int i=0;i<keyList.size();i++) {							
						keyFile = (String) keyList.elementAt(i); 
						//System.out.println("keyFile :"+keyFile);
						//--------- before files -------//
						fileNameBefore = doString.UnicodeToMS874(doString.checkString((String) session.getAttribute("session_upload_before_"+keyFile),""));  
						realFileBefore = doString.UnicodeToMS874(doString.checkString((String) session.getAttribute("session_realfile_before_"+keyFile),""));
						fileNameBefore2 = doString.UnicodeToMS874(doString.checkString((String) session.getAttribute("session_upload_before2_"+keyFile),""));  
						realFileBefore2 = doString.UnicodeToMS874(doString.checkString((String) session.getAttribute("session_realfile_before2_"+keyFile),""));
			
						//--------- process files -------//
						fileNameProcess = doString.UnicodeToMS874(doString.checkString((String) session.getAttribute("session_upload_process_"+keyFile),""));  
						realFileProcess = doString.UnicodeToMS874(doString.checkString((String) session.getAttribute("session_realfile_process_"+keyFile),""));  									
						fileNameProcess2 = doString.UnicodeToMS874(doString.checkString((String) session.getAttribute("session_upload_process2_"+keyFile),""));  
						realFileProcess2 = doString.UnicodeToMS874(doString.checkString((String) session.getAttribute("session_realfile_process2_"+keyFile),""));  									
		
						//--------- after files -------//
						fileNameAfter = doString.UnicodeToMS874(doString.checkString((String) session.getAttribute("session_upload_after_"+keyFile),""));  
						realFileAfter = doString.UnicodeToMS874(doString.checkString((String) session.getAttribute("session_realfile_after_"+keyFile),""));  									
						fileNameAfter2 = doString.UnicodeToMS874(doString.checkString((String) session.getAttribute("session_upload_after2_"+keyFile),""));  
						realFileAfter2 = doString.UnicodeToMS874(doString.checkString((String) session.getAttribute("session_realfile_after2_"+keyFile),""));  									

						/*data = new StringTokenizer(keyFile,"_");
						if (data.countTokens()<5) continue;
						iDoc = doString.checkString(data.nextToken(),"");
						seqId = doString.checkString(data.nextToken(),"");
						jobItem = doString.checkString(data.nextToken(),"");
						vendor = doString.checkString(data.nextToken(),"");
						area = doString.checkString(data.nextToken(),"");*/
						
						String [] temp = keyFile.split("\\_");   	
						if(temp.length>=4){
							seqId = ""+SEQ;
							jobItem = temp[1];
							vendor = temp[3];;
							area = temp[4];
							i_keygen =  temp[1]+"_"+temp[2];
						}
						//jobItem = id;
		
						if (realFileBefore.trim().length()>0 || fileNameBefore.trim().length()>0 ||
							 realFileBefore2.trim().length()>0 || fileNameBefore2.trim().length()>0 ||
							 realFileAfter.trim().length()>0 || fileNameAfter.trim().length()>0 ||
							 realFileAfter2.trim().length()>0 || fileNameAfter2.trim().length()>0 ||
							 realFileProcess.trim().length()>0 || fileNameProcess.trim().length()>0 ||
							 realFileProcess2.trim().length()>0 || fileNameProcess2.trim().length()>0) {
							 
							 //------ at least 1 file has attach , if no file attach no insert ----------//	
							 sql.delete(0,sql.length());
							 sql.append(" insert into lan:serv_docatt  ")
								   .append(" ( i_docno,			i_seq,					i_itmjob,				i_vendor,				i_itmjob_area, ")
								   .append("   b_name,			b_file_name,		b_name2,			b_file_name2,  ")
								   .append("   a_name,			a_file_name,		a_name2,			a_file_name2,  ")
								   .append("   p_name1,		p_file_name1,	p_name2,			p_file_name2 ,i_keygen ")
								   .append(" ) values ('"+iDocNo+"' , '"+seqId+"' , '"+jobItem+"' , '"+vendor+"' , '"+area+"' , ")
								   .append(" '"+realFileBefore+"','"+fileNameBefore+"','"+realFileBefore2+"','"+fileNameBefore2+"', ")
								   .append(" '"+realFileAfter+"','"+fileNameAfter+"','"+realFileAfter2+"','"+fileNameAfter2+"', ")
								   .append(" '"+realFileProcess+"','"+fileNameProcess+"','"+realFileProcess2+"','"+fileNameProcess2+"','"+i_keygen+"') ");
							 stmt.executeUpdate(sql.toString());
							 //System.out.println(sql.toString());						 	
						}											
						//-----  move file to real folder -------//
						fileList.addElement(moveFile(uploadPath,targetPath,fileNameBefore));
						fileList.addElement(moveFile(uploadPath,targetPath,fileNameBefore2));
						fileList.addElement(moveFile(uploadPath,targetPath,fileNameProcess));
						fileList.addElement(moveFile(uploadPath,targetPath,fileNameProcess2));
						fileList.addElement(moveFile(uploadPath,targetPath,fileNameAfter));
						fileList.addElement(moveFile(uploadPath,targetPath,fileNameAfter2));
						
						SEQ++;	
				   } //#end for
				}//#KeyList > 0		
				
				//-------- clear all unused & temp file & folder ---------//
				try {
					//----- clear old file in path -----//
					//File delFolder = new File(targetPath);
					/*if (delFolder.exists() && delFolder.isDirectory()) {
						File[] listTmp = delFolder.listFiles();
						if (listTmp!=null) {
							for (int f=0;f<listTmp.length;f++) {						
								  boolean found = false;	
								   for (int l=0;l<fileList.size();l++) {	
											String list = (String) fileList.elementAt(l);			
											if (list.equals(listTmp[f].getName())) {
												found = true;
												break;
											} 	
								   } // end for l
								   if (!found) {
									   listTmp[f].delete();
								   }
							} // end for f
						}
					}*/
								
					//----- clear temp upload path -----//
					File delFolder = new File(uploadPath);
					if (delFolder.exists() && delFolder.isDirectory()) {
						File[] listTmp = delFolder.listFiles();
						if (listTmp!=null) {
							for (int f=0;f<listTmp.length;f++) {
								listTmp[f].delete();	
							} // end for
						}
						delFolder.delete();	
					}
				} catch (Exception ex) {
					System.out.println("Delete Temp File Error !!");
					System.err.println("!!! Delete Temp File Error !! :"+ex.toString());
				}
			return isSaveUpload;	
		}catch(Exception e) {
			System.out.println("Error Method SaveUploads !!");
			System.err.println("!!! Error Method SaveUploads  :"+e.toString());
			return false;
		}
			
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
		doString str = new doString();		 		
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();

		String iDocNo = doString.checkString(req.getParameter("i_docno"),"");				
		String iVendor = doString.checkString(req.getParameter("i_vendor"),"");				
		String mode = doString.checkString(req.getParameter("mode"),"");
		String iComment = doString.UnicodeToMS874(doString.checkString(req.getParameter("i_comment"),""));
		iComment = str.replace(iComment,"\r","");
		iComment = str.replace(iComment,"\n","|break|");	
		
		
		//---======= Get Now Date with time =========-----//
		Calendar now = Calendar.getInstance();				
		int year = (now).get(Calendar.YEAR);
		if (year<2400) year += 543;		
		String nowDate = Integer.toString(year>2400 ? year-543 : year);	
		nowDate += "-"+str.createID(now.get(Calendar.MONTH)+1,2);
		nowDate += "-"+str.createID(now.get(Calendar.DATE),2);		
		nowDate += " "+str.createID(now.get(Calendar.HOUR_OF_DAY),2);
		nowDate += ":"+str.createID(now.get(Calendar.MINUTE),2);
	   //---=========================================================================----//		
		
		
		//----============= Define Link for redirect ===============-----//			
		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_Staff_List.jsp";
		String errorPage = "SERV_Staff_Conf.jsp?error=1&i_vendor="+iVendor+"&i_docno="+iDocNo; 
			
		
		String otherMsg = "";
		String errorCode = "";
		String iTypeCut = "";     
    
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		Connection conn = null;
		Statement stmt = null;
		Statement stmt1 = null;
		ResultSet rs = null;

		 try {
			if (ds == null)
				getDS();

			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
			stmt1 = conn.createStatement();

			
			//---============== Select Vat & Tax From ACCVENVT ================----//
			 int vat = 0;
			 int tax = 0;
			String pVatTax = "00";
			 sql.delete(0,sql.length());
			 sql.append(" select * from lan:accvenvt where grp_no='R8' and (ven_no='").append(iVendor).append("' ")
				   .append(" or ven_no='999999') order by ven_no ");		       
			 rs = stmt.executeQuery(sql.toString());
			 if (rs.next()) {
				 pVatTax = doString.checkString(rs.getString("vat_tax_flag"),"00");				 
				 if (pVatTax.length()==2) {
					 try {
						vat = Integer.parseInt(pVatTax.substring(0,1)); 
						tax = Integer.parseInt(pVatTax.substring(1)); 
					 } catch (Exception e) {
						System.out.println("Vat , Tax Conversion Error : "+e.getMessage());
					 }
				 }
			 }				        
			 rs.close();	

			//-----============================ Approve Mode =======================================----//
			if (mode.equalsIgnoreCase("APPROVE")) {
				String iItmJob[] = req.getParameterValues("key_itmjob");
				if (iItmJob!=null) {
					for (int i=0;i<iItmJob.length;i++) {
							String key = doString.checkString(iItmJob[i],"");
						    String id = doString.checkString(req.getParameter(key+"_i_itmjob"),"");
						    String seq = doString.checkString(req.getParameter(key+"_seq"),"");
							String iVenCut = doString.checkString(req.getParameter(key+"_vendor_cut"),"");
							String percentCut = doString.checkString(req.getParameter(key+"_percent_cut"),"");
							String wrongType = doString.checkString(req.getParameter(key+"_wrong_type"),"");
						    double zAmountCut  = Double.parseDouble(doString.checkString(req.getParameter(key+"_sum_total"),"0.00"));
						    String fContract = doString.checkString(req.getParameter(key+"_f_contract"),"");

							//---========= If cut Company , not keep percent cut =========---//
						   double zCutPV = 0.0;
							if (iVenCut.equals("999999")) {
								percentCut = "0"; 
								
								double addPay = 0.0;
								sql.delete(0,sql.length());
								sql.append(" select p_add_pay from lan:serv_payment ")
								      .append(" where i_docno='").append(iDocNo).append("' ")				         
								      .append(" and i_vendor='").append(iVendor).append("' ")				         
								      .append(" and i_itmjob='").append(id).append("'  ")
								      .append(" and f_itmstatus='500' ");		
								rs = stmt.executeQuery(sql.toString());
								if (rs.next()) {
									try {
										   addPay = Double.parseDouble(doString.checkString(rs.getString("p_add_pay"),"0.0"));
										} catch (Exception e) {
										   System.out.println("Get p_add_pay Error : "+e.getMessage());
										}
								}				        
								rs.close();									
																
								zCutPV = zAmountCut+(zAmountCut*(addPay/100));
							} else {
								zCutPV = zAmountCut+(zAmountCut*(Double.parseDouble(percentCut)/100));
							}

					    //-----=========== Calculate Cut Amount ===============-----//
					    double zCutVAT = zCutPV*((double) vat/100);
					    double zCutTAX = zCutPV*((double) tax/100);

						//---================ Update SERV_PAYMENT =================----//
		
						//----------------------------------------------- modified by sompoch , 04/02/2008 -----------------------------------------------------------//
						String fTran = "N";						
						if (fContract.trim().equalsIgnoreCase("Y") && iVenCut.trim().equals("999999")) {
							sql.delete(0,sql.length());
							sql.append(" select i_type_cutlck from lan:serv_dochd where i_docno='").append(iDocNo).append("'  ");
							rs = stmt.executeQuery(sql.toString());
							if (rs.next()) {
								 String iTypeCutlck = doString.checkString(rs.getString("i_type_cutlck"),"");
								 if (iTypeCutlck.trim().equals("1") || iTypeCutlck.trim().equals("2") || iTypeCutlck.trim().equals("3")) {
								 	//------- f_contr='Y' and i_type_cutlck in (1,2,3) , set ftran='Y' , else set 'N' --------//
									 fTran = "Y";
								 } else {
									 fTran = "N";
								 }
							} else {
								fTran = "N";				        
							}
							rs.close();
						}
						//--------------------------------------------------------------------------------------------------------------------------------------------------------------//
						sql.delete(0,sql.length());
						sql.append(" update lan:serv_payment  set ")
							  .append(" i_ven_cut='").append(iVenCut).append("' , ")				         
							  .append(" p_cut='").append(percentCut).append("' , ")
							  .append(" z_amount_cut='").append(zAmountCut).append("' , ")
							  .append(" z_cut_pv='").append(zCutPV).append("' , ")
							  .append(" z_cut_vat='").append(zCutVAT).append("' , ")
							  .append(" z_cut_tax='").append(zCutTAX).append("' , ")
							  .append(" f_remark='").append(wrongType).append("' , ")  
							  .append(" f_contr='").append(fContract).append("' , ")
							  .append(" cp_no=null , i_employ_post=null , d_post_ca=null , ")  // add 04/02/2008
							  .append(" f_tran='").append(fTran).append("' , ")  // add 04/02/2008
						      .append(" f_itmstatus='600' ") // set status to 600 , Waiting for Service Manager Approve
							  .append(" where i_docno='").append(iDocNo).append("' ")				         
							  .append(" and i_vendor='").append(iVendor).append("' ")				         
							  .append(" and i_itmjob='").append(id).append("'  ")
							  .append(" and i_seq='").append(seq).append("'  ")
							  .append(" and f_itmstatus='500' ");	
					    stmt1.executeUpdate(sql.toString());
						//System.out.println(sql.toString());						 	
					} // end for	
									
				} // end if check i_itmjob is not null									
			}
			//-----===============================================================================----//

			//-----============================ Reject Mode =======================================----//
			else if (mode.equalsIgnoreCase("REJECT")) {
				//---======== Select Payment Date from SERV_PAYSCHD  ===========----//
				String paymentDate = "";
				sql.delete(0,sql.length());
				sql.append(" select d_payment from lan:serv_payschd where today<=d_contructor order by d_payment ");
				rs = stmt.executeQuery(sql.toString());
				if (rs.next()) {
					Calendar pay = Calendar.getInstance();
					Timestamp tmp = rs.getTimestamp("d_payment");
					if (tmp!=null)  {
						pay.setTime(tmp);    
						int tYear = pay.get(Calendar.YEAR);
						if (tYear>2400) tYear-= 543;
						paymentDate += tYear+"-"+str.createID(pay.get(Calendar.MONTH)+1,2);
						paymentDate += "-"+str.createID(pay.get(Calendar.DATE),2);
					}							 
				}				        
				rs.close();	 				
				
				sql.delete(0,sql.length());
				sql.append(" update lan:serv_payment  set ")
				      .append(" d_payment ='").append(paymentDate).append("' , ")		
					  .append(" f_itmstatus='400' ") // re-status to 400 , Send back to Contractor to approve and edit data again
					  .append(" where i_docno='").append(iDocNo).append("' ")				         
					  .append(" and i_vendor='").append(iVendor).append("' ")
					  .append(" and f_itmstatus='500' ");
			    stmt1.executeUpdate(sql.toString());		
				//System.out.println(sql.toString());						 			
			}			 
			//-----===============================================================================----//

			//-----===================Clear SERV_FLOW that status more than 500 ========================----//
			sql.delete(0,sql.length());
			sql.append(" delete from lan:serv_flow where i_docno='").append(iDocNo).append("' ")
				  .append(" and i_vendor='").append(iVendor).append("' and f_itmstatus>='500' ");
			stmt.executeUpdate(sql.toString());
			//System.out.println(sql.toString());						 	

			//-----======================== Insert new SERV_FLOW =============================----//
			sql.delete(0,sql.length());
			sql.append(" insert into lan:serv_flow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,f_reject,c_reject ")
				  .append(") values (")
				  .append(" '").append(iDocNo).append("' , ")
				  .append(" '").append(iVendor).append("' , ")
				  .append(" '500' , ") //-- Set Status to 500 , Service Staff already approve or reject ---//
				  .append(" '").append(nowDate).append("' , ")
				  .append(" '").append(user.getUserID()).append("' , ")
				  .append(" ").append(mode.equalsIgnoreCase("REJECT") ? " 'Y' " : " null ").append(" , ")
				  .append(" '").append(iComment).append("') ");
		    stmt.executeUpdate(sql.toString());
			//System.out.println(sql.toString());						 	
			//-----==================================================================================----//

			//----------- save upload data -------------//
			/*
			 * remark by pradoem
			 * boolean  isSaveUpload = saveUpload(session,stmt,iDocNo,user.getsessionId());

			if(isSaveUpload){
				conn.commit();
				//conn.rollback();
				stmt.close();
				conn.close();
				conn = null;			
				//------------- clear upload session --------//
				Enumeration keys = session.getAttributeNames();
				while (keys.hasMoreElements()) {
					String key = (String) keys.nextElement();
					if (key.indexOf("session_upload_")>=0 || key.indexOf("session_realfile_")>=0) {
						session.removeAttribute(key);
					}
				} // end while		
				System.err.println(" ==== SERV_StaffConfServlet : Completed =========");
				// Redirect to the finish page.
				genRedirectCode(out,savePage,successPage,errorCode,otherMsg);
			}else{
				System.err.println(" ==== ERROR  Rollback =========");
				conn.rollback();
				System.err.println("error = "+errorPage);
				genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ : ");
			}*/
		    
			conn.commit();
			//conn.rollback();
			stmt.close();
			conn.close();
			conn = null;			
			//------------- clear upload session --------//
			try{
				Enumeration keys = session.getAttributeNames();
				while (keys.hasMoreElements()) {
					String key = (String) keys.nextElement();
					if (key.indexOf("session_upload_")>=0 || key.indexOf("session_realfile_")>=0) {
						session.removeAttribute(key);
					}
				} // end while		
				System.err.println(" ==== SERV_StaffConfServlet : Completed =========");
				// Redirect to the finish page.
			}catch (Exception e) {
				// TODO: handle exception
			}
			genRedirectCode(out,savePage,successPage,errorCode,otherMsg);

		} catch (Exception e) {
			if (e instanceof InvalidParameterException) {
				showError(out, doString.UnicodeToMS874(e.getMessage()));
			} else {           
			System.out.println(" ERROR "+mName+" : " + e.getMessage());
			System.out.println(" ERROR "+mName+" SQL : " + sql.toString());
			}
			
			try{
				conn.rollback();
			}catch (Exception ex) {
				// TODO: handle exception
			}
			//res.sendRedirect(errorPage);
			System.out.println("error = "+errorPage);
			genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ : "+e.getMessage());
			
		} finally {
			out.close();
			try {
				if (rs!=null) rs.close(); 
				if (stmt != null) stmt.close();
				if (stmt1 != null) stmt1.close();
				if (pstmt != null) pstmt.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");

	}

}
