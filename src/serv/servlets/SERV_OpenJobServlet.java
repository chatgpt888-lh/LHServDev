package serv.servlets;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.util.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*; 
import com.lh.servlet.DBServlet;
import com.lh.util.*;
import com.lh.exception.InvalidParameterException;
import serv.common.User;
import serv.common.Constants;
import serv.common.ItmJobManagement; 
import serv.util.LHSendMail;

/**
 * Last Modify by :pradoem
 * date :2021.05.18
 * desc : fix bug java.io.IOException: Server returned HTTP response code: 502 for URL:
 * ----------------------------------------
 * Last Modify by :pradoem
 * date :2015.10.26
 * desc : Approve ผ่าน email && responsive, autosend e-mail
 * 2015.12.23 modify change table  acxprjdt to serv_prjdt
 * 
 * 
 * Modify by : pradoem@lh.co.th
 * date : 2012.08.09      
 * version 1.1
 * desc:  add information list to Zero Defect && send mail to www9.lh.co.th to user
 * 
 * -------------
 */
   
public class SERV_OpenJobServlet extends DBServlet  {
	
	 private static String sysName = "(ระบบบริการ";
	 private static String subjectRQ = "ใบขออนุมัติ แจ้งซ่อมโครงการ   ";
	 private static String URL_ADDRESS = "http://132.146.1.126";
	 //private static String URL_ADDRESS = "http://132.146.4.24:9080";
	 static String SysNameLHSERV = "LHSERV";
 
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
		doString str = new doString();		 		
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
	
		//GetParamRQ(req);
		
		String mode = doString.checkString(req.getParameter("mode"),"add");
		String iDocNo = doString.checkString(req.getParameter("i_docno"),"");		
		String selProj = doString.checkString(req.getParameter("sel_project"),"");
		String houseId = doString.UnicodeToMS874(doString.checkString(req.getParameter("house_id"),""));
		String iLock = doString.checkString(req.getParameter("i_lock"),"").toUpperCase();
		String nCustomer = doString.UnicodeToMS874(doString.checkString(req.getParameter("n_customer"),""));
		String nCustTel = doString.UnicodeToMS874(doString.checkString(req.getParameter("n_cust_tel"),""));
		String dAppoint = doString.checkString(req.getParameter("d_appoint"),"");
		String dEstClose = doString.checkString(req.getParameter("d_est_close"),"");
		String fQC = doString.checkString(req.getParameter("f_qc"),"N");
		
		String iWarrantyCode = doString.checkString(req.getParameter("iWarrantyCode"),"");
		//TODO: CASE Cancel 
		//iCanTypeDDL
		//iCanDesc
		String iCanTypeDDL = doString.checkString(req.getParameter("iCanTypeDDL"),"");	
		String iCanDesc = doString.UnicodeToMS874(doString.checkString(req.getParameter("iCanDesc"),""));
		
		//TODO : CASE Turnkey Approve Or Not Approve
		//apprStatus = Y,N
		//Y=ถ้าตอบ  Y    -    บันทึกข้อมูล เหมือนเดิม (ลง serv_docdt,serv_flow) Send to Approve ไม่สามารถ Edit ได้
		//N =ถ้าตอบ  N    -    บันทึกข้อมูล เหมือนเดิม (ลง serv_docdt,serv_flow) แสดงปุ่ม Edit ด้วย
		String approveStatus = doString.checkString(req.getParameter("apprStatus"),"");
		String i_remarkDesc = doString.UnicodeToMS874(doString.checkString(req.getParameter("i_remarkDesc"),""));
		String emailApp1  = doString.checkString(req.getParameter("i_employ_email"),"");
		String employAppCur  = doString.checkString(req.getParameter("i_employ_app1"),"");
		
		String attCntTmp  = doString.checkString(req.getParameter("attCnt"),"0");
		int tempCnt = Integer.parseInt(attCntTmp);
		
		String qcStatus = "";
		if (fQC.equals("Y")) {
			qcStatus = "OPN";
		}		 

		String cDesc = "";		
		double zAmountPayLog = 0d; 
		int countItems = 0;
		
		
		int attCnt = 0;
		int dbCnt = 0;

		//---========================== Get Item Job List  ===============================----//
		ItmJobManagement itm = new ItmJobManagement(req,res);
		itm.updateValuesFromRequest(); // update new values from request.
		itm.updateItemSession(); // update session before use
       

		//---======== Get Item Details for show ===========---//
		Vector jobList = itm.getJobList();
		Hashtable jobItm = itm.getItmJobList();
		Hashtable jobVendor = itm.getVendorList();
		Hashtable jobWage = itm.getWageList();
		Hashtable jobCustomWage = itm.getCustomWageList();
		Hashtable jobCustomGoods = itm.getCustomGoodsList();
		Hashtable jobGoods = itm.getGoodsList();
		Hashtable jobBOQ = itm.getBOQList();
		Hashtable jobComment = itm.getCommentList();
		Hashtable jobArea = itm.getAreaList(); 

		//---======= Get Now Date =========-----//
		Calendar now = Calendar.getInstance();				
		int year = (now).get(Calendar.YEAR);
		if (year<2400) year += 543;		
		String nowDate = Integer.toString(year>2400 ? year-543 : year);	
		nowDate += "-"+str.createID(now.get(Calendar.MONTH)+1,2);
		nowDate += "-"+str.createID(now.get(Calendar.DATE),2);		
	
		String nowDateWithTime = nowDate;
		nowDateWithTime += " "+str.createID(now.get(Calendar.HOUR_OF_DAY),2);
		nowDateWithTime += ":"+str.createID(now.get(Calendar.MINUTE),2);				
	   //---=========================================================================----//					

		//----============= Define Link for redirect ===============-----//			
		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_Home.jsp";
		String errorPage = "SERV_OpenJob.jsp?error=1&mode="+mode+"&sel_project="+selProj+"&house_id="+houseId;
		errorPage += "&i_lock="+iLock+"&n_customer="+nCustomer+"&n_cust_tel="+nCustTel+"&d_appoint="+dAppoint+"&d_est_close="+dEstClose;
		if (mode.equalsIgnoreCase("EDIT")) {
			errorPage += "&i_docno="+iDocNo; 
		}		   
		//--========= Convert dAppoint to yyyy-mm-dd =============--//
		if (dAppoint.length()==10) {
		   String dd = dAppoint.substring(0,2);
		   String mm = dAppoint.substring(3,5);
		   int yyyy = Integer.parseInt(dAppoint.substring(6,10));
		   if (yyyy>2400) yyyy -= 543;
		   dAppoint = yyyy+"-"+mm+"-"+dd;
		} else {
		   dAppoint = nowDate;
		}

		//--========= Convert dEstClose to yyyy-mm-dd =============--//
		if (dEstClose.length()==10) {
			 String dd = dEstClose.substring(0,2);
			 String mm = dEstClose.substring(3,5);
			 int yyyy = Integer.parseInt(dEstClose.substring(6,10));
			 if (yyyy>2400) yyyy -= 543;
			 dEstClose = yyyy+"-"+mm+"-"+dd;	   	
		} else {
			 dEstClose = nowDate;
		}				

		String otherMsg = "";
		String errorCode = "";
		String iTypeCut = "";
  
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		//PreparedStatement pstmtIntZero = null;
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
			//----======== Add Mode , Insert Query =========----//
			if (mode.equalsIgnoreCase("ADD")) {																										
				//---==================== generate i_docno ========================---//
				StringTokenizer id = new StringTokenizer(selProj,":"); 
				String comId = id.nextToken();
				String projId = id.nextToken();
				String twoDigitYear = Integer.toString(year).substring(2);
				String prefixDocNo = comId+"-"+projId+"-"+twoDigitYear;
				sql.append(" select * from lan:serv_dochd where ")
					  .append(" i_company='").append(comId).append("' ")
					  .append(" and i_project='").append(projId).append("' ")
					  .append(" and i_docno like '").append(prefixDocNo).append("%' ")
					  .append(" order by i_docno desc ");
				rs = stmt.executeQuery(sql.toString());								
				if (rs.next()) {
					//----========== DocNo Found , increase ID =========----// 
					String oldDocNo = doString.checkString(rs.getString("i_docno"),"");
					int lastId = Integer.parseInt(oldDocNo.substring(oldDocNo.length()-5));
					if (lastId<0) { 
						lastId = 1;
					} else {
						lastId++; 
					}
					iDocNo = prefixDocNo+str.createID(lastId,5);
				} else {
					//----======== No DocNo found , start 1 ========----// 
					iDocNo = prefixDocNo+str.createID(1,5);
				}
				rs.close();
				//-----========================================================------//		
				//------===================== Get Cut Type =======================-----//
				sql.delete(0,sql.length());
				sql.append(" select * from lan:serv_cutlck	where ")
					  .append(" i_company='").append(comId).append("' ")
					  .append(" and i_project='").append(projId).append("' ")
					  .append(" and i_lock='").append(iLock).append("' ")
					  .append(" and d_effective<='").append(nowDate).append("' ")
					  .append(" order by d_effective desc ");
				rs = stmt.executeQuery(sql.toString());				
				if (rs.next()) {
					//----========== DocNo Found , increase ID =========----// 
					iTypeCut = doString.checkString(rs.getString("i_cut_type"),"");
				}
				rs.close();				
				//-----========================================================------//
				//------==================== Gen cDesc ==========================-----//

				cDesc = "";
				for (int i=0;i<jobList.size();i++) {
					   String itmId = (String) jobList.elementAt(i);
					   cDesc += (i+1)+". "+((String) jobComment.get(itmId))+"|break|";
				}				

				//-----========================================================------//
				//------==================== Start Insert ==========================-----//
				sql.delete(0,sql.length());
				sql.append("insert into lan:serv_dochd (i_docno , i_doc_type , i_company , ")
					  .append(" i_project , i_lock , d_keyin , n_customer , n_cus_tel , c_desc , ")
					  .append(" d_job , f_status , d_appoint , d_est_close , d_close , ")
					  .append(" i_service_employ , i_type_cutlck , d_print_inform , ")
					  .append(" i_employ_pinform , d_print_job , i_employ_pjob , f_reject , ")
					  .append(" i_employ_reject , d_reject , c_reject , ")
					  .append(" f_qc, qc_status) values ( ")  // new field
					  .append(" ? ,  'J' , ? , ? , ? , CURRENT , ? , ? , ? , ? , ")
					  .append(" 'OPN' , ? , ? , null , ? , ? , ")
					  .append(" null , null , ")  // Print InformJob Description
					  .append(" null , null , ") // Print Job Description
					  .append(" 'N' , null , null , null , ") // Reject Description
					  .append(" ?, ?) "); // for f_qc

				//---====== User PrepareStatement instead becase cDesc is an more than 256 Chars ======-----//	  
			  	pstmt = conn.prepareStatement(sql.toString());
			  	pstmt.setString(1,iDocNo);
				pstmt.setString(2,comId);
				pstmt.setString(3,projId);
				pstmt.setString(4,iLock);
				pstmt.setString(5,doString.UnicodeToMS874(nCustomer));
				pstmt.setString(6,doString.UnicodeToMS874(nCustTel));
				pstmt.setString(7,doString.UnicodeToMS874(cDesc));
				pstmt.setString(8,nowDate);
				pstmt.setString(9,dAppoint);
				pstmt.setString(10,dEstClose);
				pstmt.setString(11,user.getEmpId());
				pstmt.setString(12,iTypeCut);
				pstmt.setString(13,fQC);
				pstmt.setString(14,qcStatus);
				pstmt.executeUpdate();
				pstmt.close();					  	
				//-----========================================================------//

				successPage = "SERV_OpenJob_Disp.jsp?i_docno="+iDocNo;
				otherMsg = "เลขที่ใบแจ้งซ่อมคือ "+iDocNo;
			}

			//----======================================----//
			//----======== Edit Mode , Insert Query =========----//
			else if (mode.equalsIgnoreCase("EDIT")) {
				sql.delete(0,sql.length());
				sql.append("update lan:serv_dochd set ")
					  .append(" i_doc_type='J' , ")
					  .append(" d_job='").append(nowDate).append("' , ")
					  .append(" d_appoint='").append(dAppoint).append("' , ")
					  .append(" d_est_close='").append(dEstClose).append("', ")
					  .append(" f_qc='").append(fQC).append("', ")
					  .append(" qc_status='").append(qcStatus).append("' ")
				      .append(" where i_docno='").append(iDocNo).append("'  ");

				stmt.executeUpdate(sql.toString());
				String from_page = doString.checkString(req.getParameter("from_page"),"");
				if(!"".equals(from_page)){
					successPage = "/LHServ/"+from_page+"?sel_project="+iDocNo.substring(0,2)+":"+iDocNo.substring(3,6)+"&i_company="+iDocNo.substring(0,2)+"&i_project="+iDocNo.substring(3,6)+"&i_docno="+iDocNo+"&itmtype="+doString.checkString(req.getParameter("itmtype"),"");
					errorPage = "/LHServ/"+from_page+"?error=1&sel_project="+iDocNo.substring(0,2)+":"+iDocNo.substring(3,6)+"&i_company="+iDocNo.substring(0,2)+"&i_project="+iDocNo.substring(3,6)+"&i_docno="+iDocNo+"&itmtype="+doString.checkString(req.getParameter("itmtype"),"");
				}else{
					successPage = "SERV_OpenJob_Disp.jsp?i_docno="+iDocNo;					
				}
			}

			//----======================================----//

			//----======== Cancel Mode , Insert Query =========----//
			else if (mode.equalsIgnoreCase("CANCEL")) {
				iDocNo =  doString.checkString(req.getParameter("i_docno"),"");
				/* From Follow */ 
				String from_page = doString.checkString(req.getParameter("from_page"),"");
				if(!"".equals(from_page)){
					successPage = "/LHServ/"+from_page+"?sel_project="+iDocNo.substring(0,2)+":"+iDocNo.substring(3,6)+"&i_company="+iDocNo.substring(0,2)+"&i_project="+iDocNo.substring(3,6)+"&i_docno="+iDocNo+"&itmtype="+doString.checkString(req.getParameter("itmtype"),"");
					errorPage = "/LHServ/"+from_page+"?error=1&sel_project="+iDocNo.substring(0,2)+":"+iDocNo.substring(3,6)+"&i_company="+iDocNo.substring(0,2)+"&i_project="+iDocNo.substring(3,6)+"&i_docno="+iDocNo+"&itmtype="+doString.checkString(req.getParameter("itmtype"),"");
				}else{
					successPage = "SERV_Reprint_List.jsp";
					errorPage = "SERV_OpenJob_Disp.jsp?error=1&mode="+mode+"&i_docno="+iDocNo+"&edit=no";					
				}
				sql.delete(0,sql.length());
				sql.append(" update lan:serv_dochd set ")
				      .append(" f_status = 'CAN' , ")
					  .append(" d_cancel = today , ")
					  .append(" i_employ_cancel = '").append(user.getEmpId()).append("' , ")
					  .append(" i_can_type = '").append(iCanTypeDDL).append("' , ")
					  .append(" i_can_desc = '").append(iCanDesc).append("' ")
					  .append(" where i_docno='").append(iDocNo).append("' ");
				//System.out.println("SQL Cancel Mode :"+sql.toString());
				stmt.executeUpdate(sql.toString()); 
				
				/*'CAN' table Serv_approve by docNo 
				 * Modified by pradoem 2015.05.22
				 * desc: i_doc_type = 4 , d_approve1= CURRENT ,q_empapp_next = q_empapp_next+1 ,i_employ_appcur = null 
				 * */
				int x = UpdateCAN_SERV_APPROVE(conn, iDocNo);
			}

			//----======================================----//
			//----======== Cancel Mode , Insert Query =========----//
			else if (mode.indexOf("CANCEL_DOC")==0 && mode.length()==11) {
				int docId = Integer.parseInt(mode.substring(10,11));
				iDocNo =  doString.checkString(req.getParameter("i_docno"),"");
				String iCom = iDocNo.length()>=6 ? iDocNo.substring(0,2) : "";
				String iProj = iDocNo.length()>=6 ? iDocNo.substring(3,6) : "";

				/* From Follow */ 
				String from_page = doString.checkString(req.getParameter("from_page"),"");
				if(!"".equals(from_page)){
					successPage = "/LHServ/"+from_page+"?sel_project="+iCom+":"+iProj+"&i_company="+iDocNo.substring(0,2)+"&i_project="+iDocNo.substring(3,6)+"&i_docno="+iDocNo+"&itmtype="+doString.checkString(req.getParameter("itmtype"),"");
					errorPage = "/LHServ/"+from_page+"?error=1&sel_project="+iCom+":"+iProj+"&i_company="+iDocNo.substring(0,2)+"&i_project="+iDocNo.substring(3,6)+"&i_docno="+iDocNo+"&itmtype="+doString.checkString(req.getParameter("itmtype"),"");
				}else{
					successPage = "SERV_Reprint"+(docId==1 ? "" : "_Pay")+"_List.jsp";
					errorPage = "SERV_OpenJob"+(docId==1 ? "" : "_Pay")+"_Disp.jsp?error=1&mode="+mode+"&i_docno="+iDocNo+"&edit=no";			
				}

				//------===================== Check Item in this doc have VP , Close status or not =======================-----//
				boolean VPorClose = false;
				sql.delete(0,sql.length());
				sql.append(" select * from lan:serv_payment where f_itmstatus='CLS' and i_docno='").append(iDocNo).append("' ");
				rs = stmt.executeQuery(sql.toString());				
				if (rs.next()) {
					//----========== DocNo Found , increase ID =========----// 
					VPorClose = true;
				}
				rs.close();				
				//-----========================================================------//				
				if (!VPorClose) {
					sql.delete(0,sql.length());
					sql.append(" update lan:serv_dochd set ")
						  .append(" f_status = 'CAN' , ")
						  .append(" d_cancel = today , ")
						  .append(" i_employ_cancel = '").append(user.getEmpId()).append("', ")
						  .append(" i_can_type = '").append(iCanTypeDDL).append("' , ")
					       .append(" i_can_desc = '").append(iCanDesc).append("' ")
						   .append(" where i_docno='").append(iDocNo).append("' ");
					//System.out.println("SQL CAN VPorClose :"+sql.toString());
					stmt.executeUpdate(sql.toString()); 	
					
					/*'CAN' table Serv_approve by docNo 
					 * Modified by pradoem 2015.05.22
					 * desc: i_doc_type = 4 , d_approve1= CURRENT ,q_empapp_next = q_empapp_next+1 ,i_employ_appcur = null 
					 * */
					int x = UpdateCAN_SERV_APPROVE(conn, iDocNo);
					
				} else {
					throw new Exception("<br>มีรายการในใบแจ้งซ่อมนี้ Close หรือ VP อนุมัติแล้ว, ไม่สามารถยกเลิกได้ !!");
				}
			}
			//----======================================----//		

			if (!mode.equalsIgnoreCase("CANCEL") && mode.indexOf("CANCEL_DOC")<0) {
				//-----============= Manage ItemJob on SERV_DOCDT , Run in every mode except CANCEL =================----//
				
				//---- Clear Old Item before save new item list -----//
				if(jobList.size()>0){ //serv_docdt 
					sql.delete(0,sql.length());
					sql.append(" delete from lan:serv_docdt where i_docno='").append(iDocNo).append("' ");
					stmt.executeUpdate(sql.toString());
				}else{
					System.err.println("<<===I_DOCNO :"+iDocNo+"  jobList or session edit docdt is null , jobList size="+jobList.size());
				}
				//---- Add New Item to SERV_DOCDT -----//
				 String warrantyDesc = "";
				 if(!"99".equals(iWarrantyCode)){
					 warrantyDesc = "("+this.getInformJobDesc(conn, iWarrantyCode)+")";
				 }

				//String i_keygen = "";
				int SEQ = 1;
				for(int i=0;i<jobList.size();i++){

						String key = (String) jobList.elementAt(i);
					    String id = doString.checkString((String) jobItm.get(key),"");
						String vendor = doString.checkString((String) jobVendor.get(key),"");
						String area = doString.checkString((String) jobArea.get(key),"");
						String comment = doString.checkString((String) jobComment.get(key),"") +warrantyDesc;
						
						double wageUnit = Double.parseDouble(str.replace(doString.checkString((String) jobWage.get(key),"0"),",",""));
					    double goodsUnit = Double.parseDouble(str.replace(doString.checkString((String) jobGoods.get(key),"0"),",",""));
						String nItmJob = "";
						double wagePrice = 0.00;
						double goodsPrice = 0.00;
						String BOQDesc = doString.checkString((String) jobBOQ.get(key),"");
						StringTokenizer boq = new StringTokenizer(BOQDesc,":");
						if (boq.countTokens()==3) {
							//---- Get Data from BOQ Session list ------// 
							nItmJob = boq.nextToken();
							wagePrice = Double.parseDouble(str.replace(doString.checkString((String) jobCustomWage.get(key),"0.00"),",",""));
							goodsPrice = Double.parseDouble(str.replace(doString.checkString((String) jobCustomGoods.get(key),"0.00"),",",""));						
							//wagePrice = Double.parseDouble(str.replace(doString.checkString(boq.nextToken(),"0.00"),",",""));
							//goodsPrice = Double.parseDouble(str.replace(doString.checkString(boq.nextToken(),"0.00"),",",""));
						} else {
							//------- Found problem in BOQ Session list , get from table instead ----------//  
							sql.delete(0,sql.length());
							sql.append(" select * from lan:serv_boq where i_itmjob='").append(id).append("' ");
							rs = stmt.executeQuery(sql.toString());
							if (rs.next()) {
								nItmJob = doString.checkString(rs.getString("n_itmjob"),"");
								wagePrice = rs.getDouble("z_wage_unit"); 
								goodsPrice = rs.getDouble("z_good_unit"); 
							}
							rs.close();						
						} // end if

					  //----- Calculate AMount total from wage and goods ------//	
					   double zAmountPay = (wagePrice * (double) wageUnit)+(goodsPrice * (double) goodsUnit);
					   zAmountPayLog += zAmountPay;
					   sql.delete(0,sql.length());
					   sql.append(" insert into lan:serv_docdt (i_docno , i_itmjob , i_vendor , q_wage_unit , ")
							 .append(" z_wage_price , q_good_unit , z_good_price , z_amount_pay , c_itmjob , ")
							 .append(" i_itmjob_area , f_itmstatus ,i_seq,i_keygen) values ( ")
							 .append(" '").append(iDocNo).append("' , ")				         
							 .append(" '").append(id).append("' , ")
							 .append(" '").append(vendor).append("' , ")				         
							 .append(" '").append(wagePrice).append("' , ")				         
							 .append(" '").append(wageUnit).append("' , ")				         
							 .append(" '").append(goodsPrice).append("' , ")				         
							 .append(" '").append(goodsUnit).append("' , ")				         
							 .append(" '").append(Double.toString(zAmountPay)).append("' , ")				         
							 .append(" '").append(doString.UnicodeToMS874(comment.trim())).append("' , ")				         
							 .append(" '").append(area).append("' , ")				         
							 .append(" '200' ,")
							 .append(" "+SEQ+" ,")
							 .append(" '"+key+"' ")
							 .append(" ) ");  //--- Set Status to 200 , Waiting for Start Task ---// 

						stmt.executeUpdate(sql.toString());
						SEQ++;
						countItems++;
				} // end for						
				//-----==================================================================================----//


				/*****************************************************************************************/
				/* Add by pradoem 2012.08.09  for Zerodefect new Insert && Edit  */
				/* update by pradoem 2012.09.12 */
				int MAX_DAY = 0;
				int DIFF_DAY = 0;
				sql.delete(0,sql.length());
				sql.append(" select  n_desc  from lan:serv_xstd	where i_type='11' and i_code = '01' ");
				rs = stmt.executeQuery(sql.toString());
				if (rs.next()) {
					MAX_DAY  =rs.getInt("n_desc"); //90
				}				
				//String dCloseLaw = "";
				String dd = "";
				String mm = "";
				String yy = "";
				String guranteeDate = doString.checkString(req.getParameter("guranteeDate"),"");// 28/11/2550
				//System.out.println("-->D_Close_Law :"+guranteeDate);
				if(!"".equals(guranteeDate)){
					StringTokenizer tempDate = new StringTokenizer(guranteeDate,"/"); 
					 dd = tempDate.nextToken();//28
				     mm = tempDate.nextToken();//11
				     yy = tempDate.nextToken();//2555
				     int tempYY = Integer.parseInt(yy)-543; //2012
				    // dCloseLaw = tempYY+"-"+mm+"-"+dd;
				     sql.delete(0,sql.length());
					 sql.append(" select  UNIQUE  today-(date('"+tempYY+"-"+mm+"-"+dd+"')-365)  as  diff  from lan:serv_xstd ");
					 rs = stmt.executeQuery(sql.toString());
					 if (rs.next()) {
						 DIFF_DAY  =rs.getInt("diff"); //10 day or 50 day
					 }
				}
				//System.out.println("--->MAX_DAY : "+MAX_DAY);
				//System.out.println("--->DIFF_DAY :"+DIFF_DAY);
				if(DIFF_DAY<=MAX_DAY){
				    doZeroDefectAction(conn, user, req, jobList, jobItm, jobVendor,jobArea, mode, selProj, iDocNo, iLock, houseId, nCustomer, nCustTel);
				}
				/**************************************************************************************************/				
				//-----================= Edit Mode , Clear serv_flow before insert new ===================----//
				if (mode.equalsIgnoreCase("EDIT")) {
					sql.delete(0,sql.length());
					sql.append(" delete from lan:serv_flow where i_docno='").append(iDocNo).append("' ");
					stmt.executeUpdate(sql.toString());
				}				
				//-----======================= If no data in SERV_FLOW , insert it =============================----//
				sql.delete(0,sql.length());
				sql.append(" select count(*) cnt from lan:serv_flow where i_docno='").append(iDocNo).append("' ");
				rs = stmt.executeQuery(sql.toString());
				int cnt = -1;
				if (rs.next()) {
					cnt  =rs.getInt("cnt"); 
				}

				rs.close();				
				if (cnt==0) {
					//----- Unique Vendor for insert ----//
					Vector uniqueVendor = new Vector();
					for (int i=0;i<jobList.size();i++) {
							String vendor = (String) jobVendor.get((String) jobList.elementAt(i));
							if (!uniqueVendor.contains(vendor)) {
								uniqueVendor.addElement(vendor);
							} 
					} // end while
					for (int i=0;i<uniqueVendor.size();i++) {
							String iVendor = (String) uniqueVendor.elementAt(i);
							sql.delete(0,sql.length());
							sql.append(" insert into lan:serv_flow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,c_reject ")
								  .append(") values (") 
								  .append(" '").append(iDocNo).append("' , ")
								  .append(" '").append(iVendor).append("' , ")
								  .append(" '100' , ") //-- Set Status to 100 , OPEN JOB Already ---//
								  .append(" '").append(nowDateWithTime).append("' , ")
								  //.append(" today , ")
								  .append(" '").append(user.getUserID()).append("' , null ) "); 
							stmt.executeUpdate(sql.toString());
							//System.out.println(" SQL :"+sql.toString());
					} // end for insert
				} // end if check data in SERV_FLOW
				//-----==================================================================================----//				
			} 

			//SEND EMAIL TO :
			String iEmployApp = "";
			String userEmailApp = "";
			String userNameApp = "";
			String userPwdApp = "";
			String projectName ="";
			String docTempProfile = "";
			if("Y".equalsIgnoreCase(approveStatus)){
				//System.out.println("============CASE  : SERV_APPROVE = Y ");
				boolean isCheckUpdate = IsCheckUpdateSERV_APPROVE(conn, iDocNo);				
				String [] tempStr = selProj.split("\\:");
				String [] approvalStr = GetApproval(conn, tempStr[0], tempStr[1]);
				if(approvalStr!=null && approvalStr.length>3){
					 iEmployApp =   approvalStr[0];
					 userEmailApp = approvalStr[1];
					 userNameApp =  approvalStr[2];
					 userPwdApp =   approvalStr[3];		 
				}
				String emailSender = GetEmailSender(conn, user.getEmpId());
				if(isCheckUpdate){
					//TODO: CASE  UPDATE TABLE
					//System.out.println("============//TODO: Start CASE  UPDATE TABLE ");
					//employAppCur,emailApp1
					int upd = UpdateSERV_APPROVE(conn, iDocNo, emailSender, iEmployApp, iEmployApp, userEmailApp,i_remarkDesc);
					//System.out.println("============//TODO: End CASE  UPDATE TABLE");
				}else{
					//System.out.println("====TODO:Insert  SERV_APPROVE (TURN_KEY) =======");
					//TODO: CASE  INSERT TABLE
					//System.out.println("============//TODO: Start CASE  INSERT TABLE ");
					int insServ =  InsertSERV_APPROVE(conn, iDocNo,user.getEmpId(), tempStr[0], tempStr[1], iLock, i_remarkDesc, emailSender, iEmployApp, userEmailApp);
					//System.out.println("============//TODO: END CASE  INSERT TABLE ");
				}				
				//*******************************************************************	
				 projectName = GetProjectName(conn, tempStr[0], tempStr[1]);	
				 docTempProfile=  getPersonalProfile(conn, iDocNo, employAppCur);
				 
				/**  Insert bb_approve **/
				InsertBB_Approve(conn, iDocNo, iEmployApp);
		
			}else{
				System.out.println(iDocNo+"======CASE  : SERV_APPROVE = N ");
			}
			//----------- save upload data(2015.04.10) -------------//
			//String iLock,double amount,int itemsCnt,String f_appr,String employId
			//tempCnt = saveUpload(session,stmt,iDocNo,user.getsessionId(),jobList,jobItm);

			/*******Add Log by pradoem 2016.01.19***********/
			//String targetPath = getServletContext().getRealPath("/pictures/")+File.separator+iDocNo;
			//attCnt = CountImage(targetPath); //doc
			//modify by pradoem 2022.09.07
			//DeleteFolderAttache(targetPath);

			//dbCnt = CountSERV_DOCATT(conn, iDocNo);//db
			String comId = "";
			String projId = "";
			//System.out.println("doc_no = "+iDocNo);

			if(iDocNo.length()>5){ //LH-075-5800083
					String temp[] = iDocNo.split("\\-");
					comId = temp[0];
					projId = temp[1];
			}		
			InsertLogSERV_LOGTK(conn, iDocNo, comId, projId, iLock, zAmountPayLog,"SERV_OpenJobServlet", "OPEN_JOB", countItems, tempCnt, attCnt, dbCnt, approveStatus, user.getEmpId());

			conn.commit();		
			stmt.close();	

			//------------- clear upload session --------//
			/*Enumeration keys = session.getAttributeNames();
			while (keys.hasMoreElements()) {
				String key = (String) keys.nextElement();
				if (key.indexOf("session_upload_")>=0 || key.indexOf("session_realfile_")>=0) {
					session.removeAttribute(key);
				}
			} // end while	
			System.out.println(iDocNo+"-----SERV_OpenJobServlet : COMMIT----");
			*/
			
			
			/**   For send mail Approve **/
			if("Y".equalsIgnoreCase(approveStatus)){
				try{
					String [] tempStr = selProj.split("\\:");							
					String ccEmail = "";// "pradoem@lh.co.th";
					if(!userEmailApp.equals("")){

						//URL url = new URL(req.getScheme() + "://" + req.getServerName() + ":" + req.getServerPort() + req.getContextPath()+"/SERV_BeyondMail.jsp");		
						String doc = iDocNo;

						//URL url = new URL("http://132.146.4.23:9080/LHServ/SERV_BeyondMail.jsp?doc="+doc);
						//System.out.println("URL_ADDRESS :"+URL_ADDRESS);						
						/*StringBuffer sourceCode = new StringBuffer("");
						 * URL url = new URL(URL_ADDRESS+"/LHServ/SERV_BeyondMail.jsp?doc="+doc);
						//URL url = new URL(req.getScheme() + "://" + req.getServerName() +req.getContextPath()+"/SERV_BeyondMail.jsp?doc="+doc);
						URLConnection urlConn = url.openConnection();
						BufferedReader in = new BufferedReader(new InputStreamReader(urlConn.getInputStream()));
						String inputLine;
						while ((inputLine = in.readLine()) != null){
						      sourceCode.append(inputLine);
						}
						in.close();
						*/
						
						String url = URL_ADDRESS+"/LHServ/SERV_BeyondMail.jsp?doc="+doc;
						String bodyHtml = getText(url); //doString.MS874ToUnicode(sourceCode.toString());
						
						System.out.println("read body Html from [OK]: " +url);
						String mail = doString.MS874ToUnicode(bodyHtml);
						
						System.out.println("mail: " +mail);
						String subJect  =  iLock+":"+sysName+" แปลง:"+tempStr[0]+"-"+tempStr[1]+"-"+iLock+" )"+subjectRQ+" "+tempStr[0]+"-"+tempStr[1]+"  "+projectName +" เลขที่ :"+docTempProfile; 						
						//for local test send email
						//LHSendMail.sendMail("lh.co.th", "application",userEmailApp, ccEmail, doString.MS874ToUnicode(subJect) , doString.MS874ToUnicode(mail));
						emailSendingAttachImg(userEmailApp, ccEmail, subJect, mail);
						System.out.println("---- Send mail [OK.] ----");
					}
				}catch(Exception ex){
					//ex.printStackTrace();
					System.out.println("ERR!! :SERV_OpenJobServlet(Send mail TK) :"+ex.toString());
				}
			}
			
			//Add message to Save OK
			otherMsg  += "<br>จำนวนรูปภาพที่ uploads ได้ : "+attCnt+" รูป";
			//otherMsg  += "<br>จำนวนรูปภาพที่นับได้ : "+dbCnt +" รูป";
			otherMsg  += "<br>จำนวนเงินรวมทั้งหมด : "+doString.displayNumber("#,##0.00", zAmountPayLog)+"  บาท"; 
			
			//conn.close();
			//conn = null;
			//---==== Clear ItemJob Session =====----//
			System.out.println(iDocNo+"-----Successfully----");
			itm.removeItemSession();
			// Redirect to the finish page.
			genRedirectCode(out,savePage+"?docNo="+iDocNo,successPage,errorCode,otherMsg);

		} catch (Exception e) {
			if (e instanceof InvalidParameterException) {
				showError(out, doString.UnicodeToMS874(e.getMessage()));
			} else {           
				System.out.println(iDocNo+" !!ERROR "+mName+" : " + e.toString());
				System.out.println(iDocNo+" !!ERROR "+mName+" SQL : " + sql.toString());
			}	
			try{
				conn.rollback();
				//Add Log 2016.01.20
				if(iDocNo.trim().length()>0){
					InsertLogSERV_LOGTK(conn, iDocNo, "99", "999", iLock, zAmountPayLog,"SERV_OpenJobServlet", "ERROR", countItems, tempCnt, attCnt, dbCnt, approveStatus, user.getEmpId());
				}
			}catch(Exception ex){	
				System.out.println(iDocNo+" !!ERROR2 InsertLogSERV_LOGTK "+mName+" : " + e.toString());
			}
			//res.sendRedirect(errorPage); 
			//System.out.println("error = "+errorPage);
			genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ : "+e.getMessage());
		} finally {
			out.close();
			
			try {
				if (rs!=null) rs.close(); 
				if (stmt != null) stmt.close();
				if (pstmt != null) pstmt.close();
				//if(pstmtIntZero!=null) pstmtIntZero.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");
	}
	
	public static String getText(String url) throws Exception {
        URL urlConn = new URL(url);
        URLConnection con =(HttpURLConnection) urlConn.openConnection();
        int responseCode = 0;
        try{
	        con.setConnectTimeout(15*1000); //set timeout to 10 seconds
	        con.setReadTimeout(15*1000);  //set timeout to 10 seconds
	        con.connect();
	        responseCode = ((HttpURLConnection) con).getResponseCode();
        }catch(Exception cx){
        	System.out.println("info: con.setConnectTimeout(10*1000) = "+cx.toString());
        }
        System.out.println("responseCode = "+responseCode);        
        //con.setConnectTimeout(5000); //set timeout to 5 seconds
        if(responseCode==200){
            //--reader
            BufferedReader in = new BufferedReader(
                                    new InputStreamReader(
                                    		con.getInputStream()));

            StringBuilder response = new StringBuilder();
            String inputLine;
            while ((inputLine = in.readLine()) != null) 
                response.append(inputLine);

            in.close();

            return response.toString();
        }else{
        	return ""+responseCode;
        }
    }	
	
	//Add by pradoem
	//2012.08.08 for send mail to Approved zero_defection
	protected static void   emailSending(String toReceive,String toCc,String subject,String body) throws Exception{
		LHMail serverEmail = new LHMail();			
		//Production
		serverEmail.sendBBMail("132.146.1.12", "lh.co.th", "application", toReceive, toCc, doString.MS874ToUnicode(subject), doString.MS874ToUnicode(body));	
		//lh.co.th
		//LHSendMail.sendMail("lh.co.th", "application", toReceive, toCc , doString.MS874ToUnicode(subject) , doString.MS874ToUnicode(body));
	}
	
	protected static void   emailSendingAttachImg(String toReceive,String toCc,String subject,String body) throws Exception{
		//lh.co.th
		System.out.println("-- emailSendingAttachImg11 --");
		LHSendMail.sendMail("lh.co.th", "application", toReceive, toCc , doString.MS874ToUnicode(subject) , doString.MS874ToUnicode(body));
		System.out.println("-- emailSendingAttachImg22 --");
	}

	//Add by pradoem
    //2012.08.08 for send mail to Approved zero_defection
	protected void doZeroDefectAction(Connection conn,User user,HttpServletRequest req,Vector jobList,Hashtable jobItm,Hashtable jobVendor,Hashtable jobArea,
			String mode,String projectDDL,String iDocNo,String iLock,String houseId,String nCustomer,String nCustTel){
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt= null;
		PreparedStatement pstmtIntZero = null;
		ResultSet rs = null;
		boolean isStep = true;
		try{
			String comId = "";
			String projId = "";
			String fStatus = "";
			//********************************************************
			StringTokenizer tempId = new StringTokenizer(projectDDL,":"); 
			comId = tempId.nextToken();
			projId = tempId.nextToken();		
			String dd ="";
			String mm ="";
			String yy ="";

			String dCloseLaw = "";
			String guranteeDate = doString.checkString(req.getParameter("guranteeDate"),"");// 28/11/2550
			if(!"".equals(guranteeDate)){
				StringTokenizer tempDate = new StringTokenizer(guranteeDate,"/"); 
				 dd = tempDate.nextToken();//28
			     mm = tempDate.nextToken();//11
			     yy = tempDate.nextToken();//2555
			     int tempYY = Integer.parseInt(yy)-543;
			     dCloseLaw = tempYY+"-"+mm+"-"+dd;
			     //System.out.println("dCloseLaw:"+dCloseLaw);
			}
			//********************************************************************************************//
			//**Add by pradoem 2012.08.07 for Zero defection
			//1.if mode == EDIT then   search in SERV_ZEROHD ? record valide OK
			//2. check status = 'CLS' THEN  End processing
			// else status = 'OPN' THEN  goto processing below
			//2.1 delete SERV_ZEROHD by iDocNo && SERV_ZERODT by iDocNO  goto insert processing OK.
			if("edit".equalsIgnoreCase(mode)){
				//System.out.println(" mode edit processing ");
				sql.delete(0,sql.length());
				sql.append(" select f_status from  lan:serv_zerohd  where  i_docno =  ?  ");
				pstmt = conn.prepareStatement(sql.toString());
				pstmt.setString(1, iDocNo);
				//System.out.println("SQL find :"+sql.toString());
				rs = pstmt.executeQuery();
				if(rs.next()){
					fStatus = doString.checkString(rs.getString("f_status"), "");
				}
				//System.out.println("f_status :"+fStatus);
				if("OPN".equals(fStatus)){
					sql.delete(0,sql.length());
					sql.append("delete from lan:serv_zerohd where i_docno = ?  ");
					pstmt = conn.prepareStatement(sql.toString());
					pstmt.setString(1, iDocNo);
					pstmt.executeUpdate();
					//System.out.println(" delete serv_zerohd Okay.");

					sql.delete(0,sql.length());
					sql.append("delete from lan:serv_zerodt where i_docno = ?  ");
					pstmt = conn.prepareStatement(sql.toString());
					pstmt.setString(1, iDocNo);
					pstmt.executeUpdate();
					//System.out.println(" delete serv_zerodt Okay.");
					isStep = true;
				}else if("CLS".equals(fStatus)){
					isStep = false;
				}
				//System.out.println(" end mode edit ");
			}			  
 			/*********************************************************************************************/			
			//**1.Check list is Zero defect ? Y/N and  if list zero defect have insert in to serv_Zerodt .
			//**2.insert into lan:serv_zerohd
			//**3.send mail to  employee for comfirmation.
			//fStatus="";//fStatus=OPN//fStatus=CLS
			if(isStep){ // OPN= true or ADD
				//System.out.println("--------------Starting Test-----------------------");

				sql.delete(0,sql.length());
				sql.append(" select a.i_docno,a.i_itmjob,a.i_vendor ")
				.append(" from lan:serv_docdt a,lan:serv_zero b ")
				.append(" where a.i_docno = ?  and b.i_itmjob= ? and a.i_itmjob = b.i_itmjob order by a.i_itmjob ");
				pstmt = conn.prepareStatement(sql.toString());
				//System.out.println("SQL find :"+sql.toString());
				//***********************************************
				sql.delete(0,sql.length());
				sql.append(" Insert into lan:serv_zerodt(i_docno,i_itmjob,i_vendor,i_seq,f_remark,f_zero,i_itmjob_area ) ")
					.append(" values(?,?,?,?,null,null,?) ");
				pstmtIntZero = conn.prepareStatement(sql.toString());
				//System.out.println("SQL insert :"+sql.toString());
				//**************************************************
				int x = 1;
				int n = 1;
				int iseq = 1;
				StringBuffer bJob = new StringBuffer();
				StringBuffer bVendor = new StringBuffer();
				StringBuffer bArea = new StringBuffer();
				StringBuffer bKey = new StringBuffer();
				//System.out.println("--->jobList :"+jobList.size());
				//***Check Zero Defect List for Insert && bussiness logic
				for(int i=0;i<jobList.size();i++) {
					bKey.delete(0, bKey.length());
			    	bJob.delete(0, bJob.length());
			    	bArea.delete(0, bArea.length());
			    	bVendor.delete(0, bVendor.length());
			    	//*********************************
			    	bKey.append((String)jobList.elementAt(i));
					bJob.append(doString.checkString((String) jobItm.get(bKey.toString()),""));
					bVendor.append(doString.checkString((String) jobVendor.get(bKey.toString()),""));
					bArea.append(doString.checkString((String) jobArea.get(bKey.toString()),""));

				    x = 1;
				    pstmt.setString(x++, iDocNo);
				    pstmt.setString(x++, bJob.toString());
				    rs = pstmt.executeQuery();
				    if(rs.next()){
				    	//check valid 
				    	n = 1;
				    	pstmtIntZero.setString(n++, iDocNo);
				    	pstmtIntZero.setString(n++, bJob.toString());
				    	pstmtIntZero.setString(n++, bVendor.toString());
				    	pstmtIntZero.setInt(n++,iseq++);
				    	pstmtIntZero.setString(n++, bArea.toString());
				    	pstmtIntZero.addBatch();
				    	//System.out.println("--->Add batch");
				    }
				} 
				int intZero[] = pstmtIntZero.executeBatch();
				//System.out.println("--->executeBatch ");
				//System.out.println("--->intZero.length :"+intZero.length);
				if(intZero.length>0){
						//***********************************************
						sql.delete(0,sql.length());
						sql.append(" Insert into lan:serv_zerohd(i_docno,i_company,i_project,i_lock,d_close_law,d_keyin,d_submit,i_employ_submit,f_status,i_house, ")
							.append(" n_customer,n_cus_tel ) ")
							.append(" values(?,?,?,?,?,current,null,null,'OPN',?,?,?) ");
						pstmt = conn.prepareStatement(sql.toString());
						x = 1;
						pstmt.setString(x++,iDocNo);//docNo
						pstmt.setString(x++,comId);//i_company
						pstmt.setString(x++,projId);//i_project
						pstmt.setString(x++,iLock);//i_lock
						if(!"".equals(dCloseLaw)){
							pstmt.setString(x++,dCloseLaw);//guranteedate
						}else{
							pstmt.setString(x++,null);//guranteedate
						}				
						pstmt.setString(x++,houseId);//house_id
						pstmt.setString(x++, doString.UnicodeToMS874(nCustomer));//n_customer
						pstmt.setString(x++, doString.UnicodeToMS874(nCustTel));//n_cust_tel
						pstmt.executeUpdate();
						//System.out.println("--->Insert serv_zerohd successfully. ");				
						//******************************************************************************************/
						//Form Send Mail
						String prefix = "";
						String fName = "";
						String lName = "";
						String telNo = "";
						String userId = "";
						String userEmail = "";
						String projectName = "";
						//***************************************************************
						sql.delete(0,sql.length());
						sql.append(" select n_prename_th,n_nemploy_th,n_semploy_th  from  docflow:acemploy   where i_employ  = ? ");
						pstmt = conn.prepareStatement(sql.toString());
						pstmt.setString(1, user.getEmpId()); //2154-6
						//System.out.println("user EmpId :"+user.getEmpId());
						rs = pstmt.executeQuery();
						if(rs.next()){
							prefix = doString.checkString(rs.getString("n_prename_th"), "");
							fName = doString.checkString(rs.getString("n_nemploy_th"), "");
							lName = doString.checkString(rs.getString("n_semploy_th"), "");
						}

						//******************************************************************			
						sql.delete(0,sql.length());
						sql.append(" select i_tel from lan:serv_prjdt where i_company = ? and i_project = ?  ");
						pstmt = conn.prepareStatement(sql.toString());
						pstmt.setString(1, comId); //comId
						pstmt.setString(2, projId); //projId
						rs = pstmt.executeQuery();
						if(rs.next()){
							telNo = doString.checkString(rs.getString("i_tel"), "");
						}

						//*******************************************************************
						//Find E-mail for Approved
						boolean isUserId = true;
						sql.delete(0,sql.length());
						sql.append(" select user_id from lan:serv_staffqc where i_company = ? and i_project = ?  ");
						pstmt = conn.prepareStatement(sql.toString());
						pstmt.setString(1, comId); //comId
						pstmt.setString(2, projId); //projId
						rs = pstmt.executeQuery();
						if(rs.next()){
							userId = doString.checkString(rs.getString("user_id"), "");
							isUserId = false;
						}

						//-->Case Find in serv_staffqc  find not found.
						if(isUserId){
							//System.out.println("//-->Case Find in serv_staffqc  find not found.");
							sql.delete(0,sql.length());
							sql.append(" select  n_desc  from lan:serv_xstd	where i_type='12' and i_code = '01'  ");
							pstmt = conn.prepareStatement(sql.toString());
							rs = pstmt.executeQuery();
							if(rs.next()){
								userId = doString.checkString(rs.getString("n_desc"), "");
							}
						}

						//*******************************************************************
						String userName = "";
						String userPwd = "";
						sql.delete(0,sql.length());
						sql.append(" select user_id,user_email,user_name,user_password from docflow:useracl where user_id = ?  ");
						pstmt = conn.prepareStatement(sql.toString());
						pstmt.setString(1, userId); //userId
						rs = pstmt.executeQuery();
						if(rs.next()){					
							userName  = doString.checkString(rs.getString("user_id"), "");
							userEmail = doString.checkString(rs.getString("user_email"), "");
							userPwd =  doString.checkString(rs.getString("user_password"), "");
						}						
						//userEmail = "pradoem@lh.co.th";
						String ccEmail = "watinee@lh.co.th,pradoem@lh.co.th";			
						if(!"".equals(userEmail)){
								//*******************************************************************				
								sql.delete(0,sql.length());
								sql.append(" select b.n_project from lan:acxprojt b where b.i_company =? and b.i_project =? ");
								pstmt = conn.prepareStatement(sql.toString());
								pstmt.setString(1, comId); //comId
								pstmt.setString(2, projId); //projId
								rs = pstmt.executeQuery();
								if(rs.next()){
									projectName = doString.checkString(rs.getString("n_project"), "");
								}

								//********************************************************************
								String targetUrl = "http://www7.lh.co.th"+req.getContextPath()+"/SERV_ZeroDefectServlet";
								String url = "http://www7.lh.co.th"+req.getContextPath()+"/LoginServlet?userid="+userName+"&password="+userPwd+"&iDocNo="+iDocNo+"&url="+targetUrl;
								String subJect = "";
								if("edit".equalsIgnoreCase(mode)){
									subJect =  "(แก้ไข)แจ้งเตือนรายการ Zero Defect โครงการ "+projectName;
								}else{
									subJect =  "แจ้งเตือนรายการ Zero Defect โครงการ "+projectName;
								}				
								String mailBody = " <html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=windows-874\"> "
											+" <meta http-equiv=\"Content-Language\" content=\"th\"><title>แจ้งเตือนรายการ Zero Defect โครงการ"+projectName+"</title></head><body> "
											+" <TABLE border = 0><TR><TD> "
											+" แจ้งเตือนรายการ Zero Defect โครงการ "+projectName+" แปลง "+iLock+"<br> เจ้าหน้าที่ฝ่ายบริการชื่อ "+prefix+" "+fName+"&nbsp;&nbsp;"+lName+" เบอร์โทร "+telNo+" ใบแจ้งซ่อมเลขที่ <a href=\""+url+"\">"+iDocNo
											+"</a> </TD></TR>"

											+" </TABLE></body></html> ";	
								//remark by pradoem 2022.02.10
								//emailSending(userEmail,ccEmail,subJect,mailBody);
								//System.out.println("--------------End Test-----------------------");
						}
				}//End if batch >0
			}
			/*********************************************************************************************/
		}catch(Exception e){
			e.printStackTrace();
			System.out.println(" !!Err SERV_OpenJobServlet.doZeroDefectAction : "+e.toString());
			System.out.println(" !!Err SERV_OpenJobServlet.doZeroDefectAction SQL: "+sql.toString());
		}finally{
			try{
				if(rs!=null) rs.close();
				if(pstmt!=null) pstmt.close();
				if(pstmtIntZero!=null) pstmtIntZero.close();
			}catch(Exception e){}
		}
	}
	
	
	//modify by pradoem 2015.04.10
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

	public int xSaveUpload(HttpSession session,Statement stmt,String iDocNo,String sessionId,Vector jobList,Hashtable jobItm) throws Exception {
		//try{
			String uploadId = doString.checkString((String) session.getAttribute("session_upload_id"),"");
			if (uploadId.trim().length()<=0) {
				 uploadId = sessionId;
				 session.setAttribute("session_upload_id",uploadId);
			}
			String targetPath = getServletContext().getRealPath("/pictures/")+File.separator+iDocNo;
			String uploadPath = getServletContext().getRealPath("/pictures/temp/")+File.separator+uploadId;
			
			/*******Add Log by pradoem 2016.01.19***********/
			int tempCnt = 0;
			tempCnt = CountImage(uploadPath); //temp
			
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
			
			//String iDoc = iDocNo;
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
			sql.delete(0,sql.length());
			sql.append(" delete from lan:serv_docatt where i_docno='"+iDocNo+"' ");
			stmt.executeUpdate(sql.toString());
			//System.out.println(sql.toString());	
		
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
					
			//System.out.println("keyList : "+keyList.size());
			//System.out.println("jobList : "+jobList.size());
			
			int SEQ = 1;
			String i_keygen = "";
			for (int i=0;i<keyList.size();i++) {
						i_keygen = "";
						//keyImg= (String) jobList.elementAt(i);//Job
						keyFile = (String) keyList.elementAt(i);//KeyList 	
	
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
						//System.out.println("realFileBefore :"+realFileBefore);
						//data = new StringTokenizer(keyFile,"_");
						//if (data.countTokens()<3) continue;
						String [] temp = keyFile.split("\\_");   
	
						if(temp.length>=4){
							seqId = ""+SEQ;
							jobItem = temp[1];
							vendor = temp[3];;
							area = temp[4];
							i_keygen =  temp[1]+"_"+temp[2];
						}
						//jobItem = id;
						  
						/*System.out.println("seqId :"+seqId);
						System.out.println("jobItem :"+jobItem);
						System.out.println("vendor :"+vendor);
						System.out.println("area: "+area );*/
		
						if (realFileBefore.trim().length()>0 || fileNameBefore.trim().length()>0 ||
							 realFileBefore2.trim().length()>0 || fileNameBefore2.trim().length()>0 ||
							 realFileAfter.trim().length()>0 || fileNameAfter.trim().length()>0 ||
							 realFileAfter2.trim().length()>0 || fileNameAfter2.trim().length()>0 ||
							 realFileProcess.trim().length()>0 || fileNameProcess.trim().length()>0 ||
							 realFileProcess2.trim().length()>0 || fileNameProcess2.trim().length()>0) {
							 
							int cntImg = CountImage(fileNameBefore, fileNameBefore2, fileNameProcess, fileNameProcess2, fileNameAfter, fileNameAfter2);
							 //------ at least 1 file has attach , if no file attach no insert ----------//	
							 sql.delete(0,sql.length());
							 sql.append(" insert into lan:serv_docatt  ")
								   .append(" ( i_docno,			i_seq,					i_itmjob,				i_vendor,				i_itmjob_area, ")
								   .append("   b_name,			b_file_name,		b_name2,			b_file_name2,  ")
								   .append("   a_name,			a_file_name,		a_name2,			a_file_name2,  ")
								   .append("   p_name1,		p_file_name1,	p_name2,			p_file_name2 , i_keygen ,img_cnt ")
								   .append(" ) values ('"+iDocNo+"' , '"+seqId+"' , '"+jobItem+"' , '"+vendor+"' , '"+area+"' , ")
								   .append(" '"+realFileBefore+"','"+fileNameBefore+"','"+realFileBefore2+"','"+fileNameBefore2+"', ")
								   .append(" '"+realFileAfter+"','"+fileNameAfter+"','"+realFileAfter2+"','"+fileNameAfter2+"', ")
								   .append(" '"+realFileProcess+"','"+fileNameProcess+"','"+realFileProcess2+"','"+fileNameProcess2+"','"+i_keygen+"', "+cntImg+" ) ");
							// System.out.println("SQL xx :"+sql.toString());
							 stmt.executeUpdate(sql.toString());					 	
						}
													
						//-----  move file to real folder -------//
						fileList.addElement(moveFile(uploadPath,targetPath,fileNameBefore));
						fileList.addElement(moveFile(uploadPath,targetPath,fileNameBefore2));
						fileList.addElement(moveFile(uploadPath,targetPath,fileNameProcess));
						fileList.addElement(moveFile(uploadPath,targetPath,fileNameProcess2));
						fileList.addElement(moveFile(uploadPath,targetPath,fileNameAfter));
						fileList.addElement(moveFile(uploadPath,targetPath,fileNameAfter2));					
				SEQ++;		
			} // end for
			
			//-------- clear all unused & temp file & folder ---------//
			try {
				//----- clear old file in path -----//
				File delFolder = new File(targetPath);
				if (delFolder.exists() && delFolder.isDirectory()) {
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
				}
							
				//----- clear temp upload path -----//
				delFolder = new File(uploadPath);
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
				System.out.println(iDocNo+",saveUpload : Delete Temp File Error !! ");
				System.out.println(iDocNo+",saveUpload :"+ex.toString());
			}
		return tempCnt;
	}	

	protected int CountImage(String bFile1,String bFile2,String pFile1,String pFile2,String aFile1,String aFile2){
		int countImg = 0;
		try{
			if(bFile1.trim().length()>0){
				countImg++;
			}
			if(bFile2.trim().length()>0){
				countImg++;
			}
			if(pFile1.trim().length()>0){
				countImg++;
			}
			if(pFile2.trim().length()>0){
				countImg++;
			}
			if(aFile1.trim().length()>0){
				countImg++;
			}
			if(aFile2.trim().length()>0){
				countImg++;
			}
		}catch(Exception e){
			e.fillInStackTrace();
		}
		return countImg;
	}
	
	public int xCountSERV_DOCATT(Connection conn,String docNo){
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        
        int cnt = 0;
        try {
            stmt = conn.createStatement();
  			sql.delete(0, sql.length());
			sql.append(" select sum(img_cnt) as cnt ")
				.append(" From lan:serv_docatt ")
				.append(" Where i_docno  ='"+docNo+"'  "); 
				//System.out.println("SQL CountSERV_DOCATT  :"+sql.toString());
				rs = stmt.executeQuery(sql.toString());    				   
			    if(rs.next()){
			       cnt  = rs.getInt("cnt");
			    } 	
            rs.close();
            stmt.close();
        }catch(Exception e) {	          
			e.printStackTrace();
			System.out.println(" CountSERV_DOCATT Error : " + e.getMessage());
			System.out.println(" CountSERV_DOCATT SQL: "+sql.toString());
        } finally{
            try  {
                if(rs != null) {  rs.close();}
                if(stmt != null){stmt.close();}
            }
            catch(Exception ex) { }
        }       
        return cnt;
    }
	
	public boolean IsCheckUpdateSERV_APPROVE(Connection conn,String docNo){
	        StringBuffer sql = new StringBuffer();
	        Statement stmt = null;
	        ResultSet rs = null;
	        
	        int cnt = 0;
	        boolean isRecord = false;
	        try {
	            stmt = conn.createStatement();
	  			sql.delete(0, sql.length());
				sql.append(" select count(*) cnt ")
					.append(" From lan:serv_approve ")
					.append(" Where i_docno  = '"+docNo+"' AND i_doc_type = '5' "); 
					//System.out.println("SQL IsCheckUpdateSERV_APPROVE  :"+sql.toString());
					rs = stmt.executeQuery(sql.toString());    				   
				    if(rs.next()){
				       cnt  = rs.getInt("cnt");
				    } 		
				    if(cnt>0){  
				    	//TODO: CASE  UPDATE TABLE
				       isRecord = true;
				    }else{ 
				    	//TODO: CASE INSERT TABLE
				       isRecord = false;
				    }	  
	                rs.close();
	                stmt.close();
	                
	        }catch(Exception e) {	          
				e.printStackTrace();
				System.out.println(" IsCheckUpdateSERV_APPROVE Error : " + e.getMessage());
				System.out.println(" IsCheckUpdateSERV_APPROVE SQL: "+sql.toString());
	        } finally{
	            try  {
	                if(rs != null) {
	                    rs.close();
	                }
	                if(stmt != null){
	                    stmt.close();
	                }
	            }
	            catch(Exception ex) { }
	        }       
	        return isRecord;
	    }

	public int InsertSERV_APPROVE(Connection conn,String docNo,String employId,String comId,String projId,String iLock,
			   String iRemark,String emailSender,String employAppCur,String employEmailApp1){
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	        try{
	        	//initial paramter		
	        	int i=1;
	        	int intUpd = 0;
	        	boolean isRecord = false;
				sql.delete(0, sql.length());
				sql.append(" Select i_docno  From lan:SERV_APPROVE Where i_docno ='"+docNo+"' ");
				pstmt = conn.prepareStatement(sql.toString()); 
				rs = pstmt.executeQuery();
				if(rs.next()){
					doString.checkString(rs.getString("i_docno"), "");
					isRecord = true;
				} // End if rs        	
				
				if(!isRecord){ //==false;
					/******************************************************/
		        	sql.delete(0, sql.length());
					sql.append(" INSERT INTO  lan:SERV_APPROVE  ")
							.append(" (i_docno, ")
							.append(" i_employ,")
							.append(" d_keyin, ")
							.append(" i_doc_type,  ")
							.append(" i_company,  ")
							.append(" i_project,  ")
							.append(" i_lock,  ")
							.append(" i_remark,  ")
							.append(" i_email_sender,  ")
							.append(" q_empapp_max,  ")
							.append(" q_empapp_next,  ")
							.append(" i_employ_appcur,  ")
							.append(" i_employ_app1,  ")
							.append(" i_email_app1,  ")
							.append(" d_approve1,  ")
							.append(" i_comment1)  ")
							.append(" VALUES ('"+docNo+"', '"+employId+"', current, '2', '"+comId+"', '"+projId+"', '"+iLock+"', ?, '"+emailSender+"', 1, 1, '"+employAppCur+"', '"+employAppCur+"', '"+employEmailApp1+"', null, null) ");
				    //System.out.println("Insert SQL :"+sql.toString());
				 
				    pstmt = conn.prepareStatement(sql.toString());     		    
				    pstmt.setString(1, iRemark);
				    
				    intUpd = pstmt.executeUpdate();
				    System.out.println("INSERT lan:SERV_APPROVE  SQL :"+intUpd);
				}else{
					sql.delete(0, sql.length());
		  			sql.append(" UPDATE lan:SERV_APPROVE SET  i_doc_type = 2 , d_approve1= null ,q_empapp_next = q_empapp_next+1 ,i_employ_appcur = '"+employAppCur+"' ");
		  			sql.append(" Where  i_docno = '").append(docNo).append("' ");
		  			System.out.println(docNo+",CASE duplicate doing Update SQL :"+sql.toString());
		  			pstmt = conn.prepareStatement(sql.toString()); 
		  			int intUpd2 = pstmt.executeUpdate();
		  			System.out.println("intUpd2 :"+intUpd2);
				}
			    //System.out.println("---Insert Okay..");
				//********************************************************/
			  	//System.out.println("##InsertSVC_DOCHD ->end.");				  	 
			  	return intUpd;			  	 
			}catch(Exception e){
				e.printStackTrace();
				System.err.println(" InsertSERV_APPROVE Error :" +docNo+","+ e.getMessage());
				System.err.println(" InsertSERV_APPROVE SQL: "+docNo+","+sql.toString());	
				return -1;
			}
			finally{			
				//clean up.
				try{
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
				}catch(Exception e){}
			}
		}
	   
	   /* i_doc_type 
	    * 2 = Wait to Approved
	    * 3 = Approved
	    * 5 = Route back
	    * **************
	    * 1 - เอกสารใหม่
		* 2 - รอการอนุมัติ
		* 3 - อนุมัติเรียบร้อย
		* 4 - ปฏิเสธ(CAN)
		* 5 - กลับไปแก้ไขใหม่
	    * */
	   public int UpdateCAN_SERV_APPROVE(Connection conn,String docId) {
	  		StringBuffer sql = new StringBuffer();	
	  		PreparedStatement pstmt = null;
	  		ResultSet rs = null;
	       try{
	       		//initial paramter		
	  			/******************************************************/					
	  			sql.delete(0, sql.length());
	  			sql.append(" UPDATE lan:SERV_APPROVE SET  i_doc_type = 4 , d_approve1= CURRENT ,q_empapp_next = q_empapp_next+1 ,i_employ_appcur = null ");
	  			sql.append(" Where  ")
	  			   .append("  i_docno = '").append(docId).append("' ");
	  			//System.out.println("-->Update SQL :"+sql.toString());
	  			pstmt = conn.prepareStatement(sql.toString()); 
	  			int intUpd = pstmt.executeUpdate();

	  		  	//System.out.println("##UpdateCAN_SERV_APPROVE ->end.");				  	 
	  		  	return intUpd;			  	 
	  		}catch(Exception e){
	  			e.printStackTrace();
	  			System.out.println(" !!UpdateCAN_SERV_APPROVE Error : " + e.getMessage());
	  			System.out.println(" !!UpdateCAN_SERV_APPROVE SQL: "+sql.toString());	
	  			return -1;
	  		}
	  		finally{			
	  			//clean up.
	  			try{
	  				if(rs!=null){rs.close();}
	  				if(pstmt!=null){pstmt.close();}
	  			}catch(Exception e){}
	  		}
	  	}
	   
		public int UpdateSERV_APPROVE(Connection conn,String docId,String emailSender,String employAppCur,String employAppCur2,String employEmailApp1,String i_remark) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	        try{
	        	//initial paramter		
	        	//int i=1;

				/******************************************************/					
	       	 	sql.delete(0,sql.length());
	       	 	sql.append(" UPDATE lan:SERV_APPROVE SET  i_doc_type = 2 ,d_keyin = current, d_approve1 = null ,i_comment1 = null ,i_remark = ? , ")
	       	 	   .append(" i_email_sender = '"+emailSender+"',i_employ_appcur = '"+employAppCur+"' ,i_employ_app1 = '"+employAppCur2+"' ,i_email_app1 = '"+employEmailApp1+"' ")
	       	 	   .append(" Where  i_docno = '"+docId+"'  ");
			    //System.out.println("Update SQL :"+sql.toString());
			    pstmt = conn.prepareStatement(sql.toString());
			    pstmt.setString(1, i_remark);
			    int intUpd = pstmt.executeUpdate();
			    System.out.println("---Update Okay :"+intUpd);
				//********************************************************/			  	 
			  	return intUpd;			  	 
			}catch(Exception e){
				e.printStackTrace();
				System.out.println(" UpdateSERV_APPROVE Error : " + e.getMessage());
				System.out.println(" UpdateSERV_APPROVE SQL: "+sql.toString());	
				return -1;
			}
			finally{			
				//clean up.
				try{
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
				}catch(Exception e){}
			}
		}
		 //ระหัสผู้อนุมัติ และ email ผู้อนุมัติ
	    public String[] GetApproval(Connection conn,String comId,String projectId){
	        StringBuffer sql = new StringBuffer();
	        Statement stmt = null;
	        ResultSet rs = null;
	        
	        String tempStr[] = new String[] {"","","",""};
	        try {

	            stmt = conn.createStatement();
	  			sql.delete(0, sql.length());
				sql.append("  Select  a.i_employ_app1,b.user_email,b.user_name,b.user_password ")
					.append(" From lan:serv_lstaff a, lan:useracl b")
					.append(" Where ") 
	     			.append(" a.i_company  = '"+comId+"' ")
					.append(" AND  a.i_project = '"+projectId+"'   ")
	 				.append(" AND  a.i_employ_app1 = b.i_employ  ")
	 				.append(" AND  b.user_acl = 'S' ");
					//System.out.println("SQL Approval  :"+sql.toString());
					rs = stmt.executeQuery(sql.toString());    				   
				    if(rs.next()){
				        tempStr[0]  = doString.checkString(rs.getString("i_employ_app1"),"");
				        tempStr[1]  = doString.checkString(rs.getString("user_email"),"");
				        tempStr[2]  = doString.checkString(rs.getString("user_name"),"");
				        tempStr[3]  = doString.checkString(rs.getString("user_password"),"");
				    } 		 
	                rs.close();
	                stmt.close();
	                
	        }catch(Exception e) {
	            System.out.println(" GetApproval Error : " + e.getMessage());
	        } finally{
	            try  {
	                if(rs != null) {
	                    rs.close();
	                }
	                if(stmt != null){
	                    stmt.close();
	                }
	            }
	            catch(Exception ex) { }
	        }       
	        return tempStr;
	    } 

		 //ผู้ขอ
		 public String GetEmailSender(Connection conn, String employId) {
				StringBuffer sql = new StringBuffer();	
				PreparedStatement pstmt = null;
				ResultSet rs = null;
				String  emailSender = "";
		        try{
		        	//initial paramter	     	
					/*************************************************/			
		        	//*****Find project by user login  
					sql.delete(0,sql.length());
					sql.append("Select user_email from lan:useracl  where i_employ = ? ");
					pstmt = conn.prepareStatement(sql.toString()); 
					pstmt.setString(1, employId);	
					//System.out.println("SQL :"+sql.toString());
					rs = pstmt.executeQuery();	
					if(rs.next()){
						emailSender = doString.checkString(rs.getString("user_email"), "");
					}
					rs.close();	
				}catch(Exception e){
		 				System.out.println(" GetEmailSender Error : " + e.getMessage());
				}
				finally{			
					//clean up.
					try{
						if(rs!=null){rs.close();}
						if(pstmt!=null){pstmt.close();}
					}catch(Exception e){}
				}
			  return emailSender;		
			}

		public String getPersonalProfile(Connection conn,String docId,String i_employ) {
				ResultSet rs = null;
				StringBuffer sql = new StringBuffer();
				PreparedStatement pstmt = null;
				String tempName = "";
				try{
					sql.delete(0, sql.length());
					sql.append(" select i_employ,n_prename_th,n_nemploy_th,n_semploy_th  from docflow:acemploy ")
						  .append(" WHERE  i_employ ='"+i_employ+"' ");
					
					pstmt = conn.prepareStatement(sql.toString()); 
					rs = pstmt.executeQuery();
				   	if(rs.next()){
				   		tempName = docId+" ("+i_employ+" : "+doString.checkString(rs.getString("n_prename_th").trim())+"  "+doString.checkString(rs.getString("n_nemploy_th").trim())+"  "+doString.checkString(rs.getString("n_semploy_th").trim())+")";
					} //End While 
					rs.close();
				}catch(Exception e){
					e.fillInStackTrace();
				}	
				return tempName;
			}

		public String getInformJobDesc(Connection conn,String iType){
			        StringBuffer sql = new StringBuffer();
			        Statement stmt = null;
			        ResultSet rs = null;
			        String desc = "";
			        try {
			            stmt = conn.createStatement();
			  			sql.delete(0, sql.length());
						sql.append(" Select n_desc  ")
							.append(" From lan:serv_xstd ")
							.append(" Where  i_type='98' AND i_code = '"+iType+"' ");	
							//System.out.println("SQL  :"+sql.toString());
							rs = stmt.executeQuery(sql.toString());    				   
						    if(rs.next()){
						       desc  = doString.checkString(rs.getString("n_desc"),"");
						    } 					  
			            rs.close();
			            stmt.close();
			        }catch(Exception e) {
			            System.out.println(" getInformJobDesc Error : " + e.getMessage());
			        } finally{
			            try  {
			                if(rs != null) {
			                    rs.close();
			                }
			                if(stmt != null){
			                    stmt.close();
			                }
			            }
			            catch(Exception ex) { }
			        }
			        return desc;
		}

		 //ผู้ขอ
		 public String GetProjectName(Connection conn, String comId,String projectId) {
				StringBuffer sql = new StringBuffer();	
				PreparedStatement pstmt = null;
				ResultSet rs = null;
				String  projectName = "";
		        try{
		        	//initial paramter	     	
					/*************************************************/			
		        	sql.delete(0,sql.length());
					sql.append(" select n_project from lan:acxprojt  where i_company =? and i_project =? ");
					pstmt = conn.prepareStatement(sql.toString());
					pstmt.setString(1, comId); //comId
					pstmt.setString(2, projectId); //projId
					rs = pstmt.executeQuery();
					if(rs.next()){
						projectName = doString.DisplayThai(doString.checkString(rs.getString("n_project"), ""));
					}
					rs.close();	
				}catch(Exception e){
		 				System.out.println(" GetProjectName Error : " + e.getMessage());
				}
				finally{			
					//clean up.
					try{
						if(rs!=null){rs.close();}
						if(pstmt!=null){pstmt.close();}
					}catch(Exception e){}
				}
			  return projectName;		
			}
		 
		/********************
		 * InsertBB_Approve
		 * @param conn
		 * @param docId
		 * @param CurApp
		 * @return
		 */
		  public int InsertBB_Approve(Connection conn,String docId,String CurApp) {
		  		StringBuffer sql = new StringBuffer();	
		  		PreparedStatement pstmt = null;
		  		ResultSet rs = null;
		       try{
		       		//initial paramter		
		  			/******************************************************/					
		  			sql.delete(0, sql.length());
		  			sql.append(" DELETE FROM docflow:bb_approve WHERE n_system = '"+SysNameLHSERV+"' AND i_docno = '"+docId+"' ");
		  			//System.out.println("SQL Delete : DELETE FROM docflow:bb_approve WHERE n_system = '"+SysNameLHSERV+"' AND i_docno = '"+docId+"'  ");
		  			pstmt = conn.prepareStatement(sql.toString()); 
		  			int x1 = pstmt.executeUpdate();
		  			//System.out.println("DELETE completed.  ");
		  			
		  			
		  			 sql.delete(0, sql.length());
		             sql.append("INSERT INTO docflow:bb_approve (n_system, i_company, i_docno, n_desc, i_cur_app, d_keyin,")
		                .append(" f_status) VALUES ('"+SysNameLHSERV+"','LH','")
		                .append(docId)
		                .append("', '")
		                .append(doString.UnicodeToMS874("บริการ"))
		                .append("', '")
		                .append(CurApp)
		                .append("', CURRENT, 'W')");
		             
		  			//System.out.println("SQL Insert :"+sql.toString());
		  			pstmt = conn.prepareStatement(sql.toString()); 
		  			int x2 = pstmt.executeUpdate();
		  			//System.out.println("INSERT completed.  ");

		  		  	//System.out.println("##UpdateCAN_SERV_APPROVE ->end.");				  	 
		  		  	return x1+x2;			  	 
		  		}catch(Exception e){
		  			e.printStackTrace();
		  			System.out.println(" !!InsertBB_Approve Error : " + e.getMessage());
		  			System.out.println(" !!InsertBB_Approve SQL: "+sql.toString());	
		  			return -1;
		  		}
		  		finally{			
		  			//clean up.
		  			try{
		  				if(rs!=null){rs.close();}
		  				if(pstmt!=null){pstmt.close();}
		  			}catch(Exception e){}
		  		}
		  	}
		  
		  protected int CountImage(String path){
			  int countImg = 0;
			  File fPath = new File(path);//"D:\\usr\\IBM\\workspace2013\\LHServ\\WebContent\\pictures\\LH-075-5800083\\"
			  try{				
			    File [] files = fPath.listFiles();
			    for (int i = 0; i < files.length; i++){
			        if (files[i].isFile()){ //this line weeds out other directories/folders
			            //System.out.println(loop+"="+files[i]);
			        	countImg++; 
			        }
			    }
			    System.out.println("countImg = "+countImg);
			    return countImg;
			  }catch(Exception e){
				  System.out.println("error Delete null Folder(case -1): "+e.toString());
				  return -1;
			  }
			}
		  
		  protected int DeleteFolderAttache(String path){
			  int countImg = 0;
			  File fPath = new File(path);//"D:\\usr\\IBM\\workspace2013\\LHServ\\WebContent\\pictures\\LH-075-5800083\\"
			  try{
				
			    File [] files = fPath.listFiles();
			    for (int i = 0; i < files.length; i++){
			        if (files[i].isFile()){ //this line weeds out other directories/folders
			            //System.out.println(loop+"="+files[i]);
			        	countImg++; 
			        }
			    }
			    if(countImg<=0){
			    	//delete
			    	fPath.delete();
			    	System.out.println("Delete null Folder(Case normal)");
			    }
			    return countImg;
			  }catch(Exception e){
				  try{
					  fPath.delete();
					  System.out.println("Delete null Folder(case -1)");
				  }catch(Exception x){
					  System.out.println("error Delete null Folder(case -1):"+x.toString());
				  }
				  return -1;
			  }
			}
		  
		   // 2016.01.18   update by pradoem
		   public int InsertLogSERV_LOGTK(Connection conn,String docId,String comId,String projId,String lock,double amount,String sys,
				   String step,int itemsCnt,int tempCnt,int attCnt,int dbCnt,String status,String createBy) {
		  		StringBuffer sql = new StringBuffer();	
		  		PreparedStatement pstmt = null;
		  		ResultSet rs = null;
		       try{
		       		//initial paramter		
		    	    //sSystem.out.println("Starting .....");
		  			/******************************************************/					
		        	sql.delete(0, sql.length());
					sql.append(" INSERT INTO  lan:serv_logtk  ")
						.append(" (i_docno, ")
						.append(" i_company,")
						.append(" i_project, ")
						.append(" i_lock,  ")
						.append(" z_amount,  ")
						.append(" log_system,  ")
						.append(" log_step,  ")
						.append(" log_items_cnt,  ")
						.append(" img_temp_cnt,  ")
						.append(" img_att_cnt,  ")
						.append(" img_db_cnt,  ")
						.append(" f_send2appr,  ")
						.append(" CREATE_BY )  ")
						//.append(" CREATE_DATE  ")
						.append(" VALUES ('"+docId+"', '"+comId+"', '"+projId+"', '"+lock+"', "+amount+", '"+sys+"', '"+step+"', "+itemsCnt+", "+tempCnt+", "+attCnt+","+dbCnt+", '"+status+"','"+createBy+"') ");
				   // System.out.println("Insert SQL :"+sql.toString());
				    pstmt = conn.prepareStatement(sql.toString());     		    
				    //pstmt.setString(1, docId);
				    
				    int  insLog = pstmt.executeUpdate();
		  		  	//System.out.println("##InsSERV_LOGTK ->end.");				  	 
		  		  	return insLog;			  	 
		  		}catch(Exception e){
		  			e.printStackTrace();
		  			System.err.println(" !! LOG InsSERV_LOGTK Error : " + e.getMessage());
		  			System.err.println(" !! LOG InsSERV_LOGTK SQL: "+sql.toString());	
		  			return -1;
		  		}
		  		finally{			
		  			//clean up.
		  			try{
		  				if(rs!=null){rs.close();}
		  				if(pstmt!=null){pstmt.close();}
		  			}catch(Exception e){}
		  		}
		  	}
		  
		 
	//-------Print Request parameter
	private void GetParamRQ(HttpServletRequest request){
			Enumeration <String> paramName = (Enumeration<String>) request.getParameterNames();
			 while (paramName.hasMoreElements()) {
			       String element = (String) paramName.nextElement();
			       System.out.println(element + " = " + request.getParameter(element));

			}

	 }

}

