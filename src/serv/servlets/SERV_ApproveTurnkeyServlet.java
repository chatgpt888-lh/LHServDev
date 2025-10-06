package serv.servlets;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.URL;
import java.net.URLConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import serv.common.Constants;
import serv.common.User;
import serv.util.LHSendMail;
//import serv.util.LHSendMailAttach;
import com.lh.servlet.DBServlet;
import com.lh.util.LHMail;
import com.lh.util.doString;

/**
 * Servlet implementation class for Servlet: SERV_CompTaskSaveImgServlet
 * Last Modify by :pradoem
 * date : 2015.05.11
 * desc : project turn key approve || routback
 */
 public class SERV_ApproveTurnkeyServlet extends DBServlet  {
	 static String SysNameLHSERV = "LHSERV";
	 private static String sysName = "(ระบบบริการ";   
	// private static String subjectRQ = sysName+"ใบขออนุมัติ แจ้งซ่อมเลขที่  ";
	 private static String subjectApprove = "ใบขออนุมัติแจ้งซ่อมโครงการ ";
	 private static String subjectDeny = "ใบขออนุมัติแจ้งซ่อมโครงการ  ";
	 
	// private static String msgRQ = " อนุมัติ";
	 private static String msgAP = " ของท่านได้รับการ 'อนุมัติเรียบร้อยแล้ว'";
	 private static String msgDN = " ของท่าน 'ไม่อนุมัติ' ";
	 private static String msgRB = " ของท่าน 'กลับไปแก้ไขใหม่' ";
	 private static String URL_ADDRESS = "http://132.146.1.126";
	 //private static String URL_ADDRESS = "http://132.146.4.24:9080";

	 private void genRedirectCode(PrintWriter out,String page,String redirect,String error,String otherMsg) {
			out.println("<html><body><form method='post' action='"+page+"'>");		
			out.println("<input type='hidden' name='error' value='"+error+"'>");
			out.println("<input type='hidden' name='other_msg' value='"+doString.MS874ToUnicode(otherMsg)+"'>");
			out.println("<input type='hidden' name='redirect_url' value='"+doString.MS874ToUnicode(redirect)+"'>");		
			out.println("<script> document.forms[0].submit();</script>");
			out.println("</form></body></html>");		
	}

	// -------Print Request parameter
	private void GetParamRQ(HttpServletRequest request) {
		Enumeration<String> paramName = (Enumeration<String>) request.getParameterNames();
		while (paramName.hasMoreElements()) {
			String element = (String) paramName.nextElement();
			System.out.println(element + " = " + request.getParameter(element));

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
		
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
		User user = (User) obj;
		String iDocNo = doString.checkString(req.getParameter("i_docno"),"");
		String comment = doString.UnicodeToMS874(doString.checkString(req.getParameter("i_commentDesc"),""));
		String i_remark = doString.UnicodeToMS874(doString.checkString(req.getParameter("i_remark"),""));
	    	
		String statusApp = doString.checkString(req.getParameter("statusApp"),"");
		
		String selProj = doString.checkString(req.getParameter("sel_project"),"");
		String houseId = doString.UnicodeToMS874(doString.checkString(req.getParameter("house_id"),""));
		String iLock = doString.checkString(req.getParameter("i_lock"),"").toUpperCase();
		String nCustomer = doString.UnicodeToMS874(doString.checkString(req.getParameter("n_customer"),""));
		String nCustTel = doString.UnicodeToMS874(doString.checkString(req.getParameter("n_cust_tel"),""));
		String dAppoint = doString.checkString(req.getParameter("d_appoint"),"");
		String dEstClose = doString.checkString(req.getParameter("d_est_close"),"");
		
		//add by pradoem 2023.02.22
		String attCntTmp  = doString.checkString(req.getParameter("attCnt"),"0");
		int tempCnt = Integer.parseInt(attCntTmp);
		
		
		StringBuffer sql = new StringBuffer();
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		
		//GetParamRQ(req);
		
		//*************************** Define Link for redirect *******************//			
		String savePage = Constants.SAVE_PAGE;
				
		String errorPage = "SERV_TurnkeyApprDisp.jsp?error=1&mode=&sel_project="+selProj+"&house_id="+houseId;
		errorPage += "&i_lock="+iLock+"&n_customer="+nCustomer+"&n_cust_tel="+nCustTel+"&d_appoint="+dAppoint+"&d_est_close="+dEstClose;
		
		String otherMsg = "";
		String errorCode = "";
		//*************************** Define Link for redirect *******************//			
		 try {
			if (ds == null){
				getDS();
			}
			
			conn = ds.getConnection();
			conn.setAutoCommit(false);
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);

			// TODO: Start ******************************

			if("".equals(iLock)){
				iLock = GetLockServApporve(conn, iDocNo);
			}		
			 /* Approve Type 
			  * 2 = Wait to Approved
			  * 3 = Approved
			  * 5 = Route back
			  * */
			
			String []temp = GetEmail(conn, iDocNo);
			
			String selProject = "";
			if(temp!=null){
				String projectName = "";
				String subJect = "";

				String str[] = iDocNo.split("\\-");
				sql.delete(0,sql.length());
				sql.append(" select b.n_project from lan:acxprojt b where b.i_company =? and b.i_project =? ");
				pstmt = conn.prepareStatement(sql.toString());
				pstmt.setString(1, str[0]); //comId
				pstmt.setString(2, str[1]); //projId
				rs = pstmt.executeQuery();
				if(rs.next()){
					projectName = doString.checkString(rs.getString("n_project"), "");
				}
				
			    selProject = str[0]+":"+str[1];
			    String mailBody ="";
			    //System.out.println("------Status statusApp: "+statusApp);	
				String tempProjectFull = str[0]+"-"+str[1]+"  "+projectName;
				if("3".equals(statusApp)){
					//Approved
					//msg = "อนุมัติ";
					subJect = iLock+":"+sysName+" แปลง:"+str[0]+"-"+str[1]+"-"+iLock+" )"+subjectApprove+tempProjectFull+" เลขที่ : "+iDocNo+msgAP;
					mailBody= " <html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=windows-874\"> "
						+" <meta http-equiv=\"Content-Language\" content=\"th\"><title>"+subjectApprove+tempProjectFull+" เลขที่ : "+iDocNo+msgAP+"</title></head><body> "
						+" <TABLE border = 0><TR><TD> "
						+subjectApprove+tempProjectFull+" ใบแจ้งซ่อมเลขที่ "+iDocNo+" "+msgAP
						+"</a></TD></TR>";

					//Fix bug by pradoem 2020.05.07
					//System.out.println("111------Status statusApp: "+statusApp);	
					int x = this.UpdateSERV_APPROVE(conn, iDocNo, statusApp, comment+"(by Web)");
					System.out.println("UpdateSERV_APPROVE OK  :"+x);
					//System.out.println("222------Status statusApp: "+statusApp);	
					int ex = this.UpdateBB_APPROVE(conn, iDocNo, "A");
					System.out.println("UpdateBB_APPROVE OK  :"+ex);
					
					//modify by pradoem 2015.07.21
					boolean isEmailAlert = this.isTurnkeyEmailAlert(conn, iDocNo,tempCnt);
					if(isEmailAlert){
						//TODO : Send Mail to พี่ลี่
						/*String url = "http://132.146.1.126/LHServ/SERV_BeyondMail.jsp?mail=N&doc="+iDocNo;//LH-075-5800047
						subJect = iLock+": Alert Turkey จำนวนเงินมากว่า 500 บาท และ ไม่มีรูป";
						mailBody= " <html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=windows-874\"> "
							+" <meta http-equiv=\"Content-Language\" content=\"th\"><title>(Manager Approve กรณี Turkey จำนวนเงินมากว่า 500 และ ไม่มีรูป  เลขที่ : "+iDocNo+"</title></head><body> "
							+" <TABLE border = 0><TR><TD> "
							+" ใบแจ้งซ่อมเลขที่  <a href=\""+url+"\"> "+iDocNo+"</a> "
							+" </TD></TR>";
						EmailSending("sombat@lh.co.th,wichai@lh.co.th", "pradoem@lh.co.th", doString.MS874ToUnicode(subJect), doString.MS874ToUnicode(mailBody));
						*/
						 Map<String, String> mapObj = GetEmailAlertTK(conn);
						 String toEmailVP = "";
						 String toEmailCC = "";
						 if(mapObj!=null){
							 toEmailVP = mapObj.get("TO_VP");
							 toEmailCC = mapObj.get("TO_CC");
						 }
						// System.out.println("toEmailVP :"+toEmailVP);
						// System.out.println("toEmailCC :"+toEmailCC);
						 
						//List ListImagsAttach  = ListImagsAttach(conn, iDocNo);
						try{
							//String [] tempStr = selProj.split("\\:");							
							//String ccEmail =  "pradoem@lh.co.th";
							String TmpeSubJect = iLock+": Alert Turkey จำนวนเงินมากว่า 500 บาท และ ไม่มีรูป";
							StringBuffer sourceCode = new StringBuffer("");
							String doc = iDocNo;
							//URL url = new URL("http://132.146.4.23:9080/LHServ/SERV_BeyondMail.jsp?doc="+doc);
							//System.out.println("URL_ADDRESS :"+URL_ADDRESS);
							URL url = new URL(URL_ADDRESS+"/LHServ/SERV_BeyondMail.jsp?fstatus=disable&doc="+doc);
							//URL url = new URL(req.getScheme() + "://" + req.getServerName() +req.getContextPath()+"/SERV_BeyondMail.jsp?doc="+doc);
							URLConnection urlConn = url.openConnection();
							BufferedReader in = new BufferedReader(new InputStreamReader(urlConn.getInputStream()));
							String inputLine;
							while ((inputLine = in.readLine()) != null){
								sourceCode.append(inputLine);
							}
							in.close();
							String mail = doString.MS874ToUnicode(sourceCode.toString());
							//for local test send email
							//emailSendingAttachImg("sombat@lh.co.th,wichai@lh.co.th", "prapat@lh.co.th,piyapong@lh.co.th,pradoem@lh.co.th", subJect, mail,ListImagsAttach);
							emailSendingAttachImg(toEmailVP, toEmailCC, TmpeSubJect, mail);

							System.out.println("---- Send mail [OK.] ----");
						}catch(Exception ex1){
							ex1.printStackTrace();
							System.err.println("ERR!! :SERV_ApproveTurnkeyServlet(Approve mail TK) :"+ex1.toString());
						}
					}
					
				}else if("5".equals(statusApp)){
					//Route Back
					subJect = iLock+":"+sysName+subjectApprove+tempProjectFull+" เลขที่ : "+iDocNo+msgRB;
					mailBody= " <html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=windows-874\"> "
						+" <meta http-equiv=\"Content-Language\" content=\"th\"><title>"+subjectApprove+tempProjectFull+" เลขที่ : "+iDocNo+msgRB+"</title></head><body> "
						+" <TABLE border = 0><TR><TD> "
						+subjectApprove+tempProjectFull+" ใบแจ้งซ่อมเลขที่ "+iDocNo+" "+msgRB
						+"</a></TD></TR>";
					//Fix bug by pradoem 2020.05.07
					//System.out.println("111------Status statusApp: "+statusApp);	
					int x = this.UpdateSERV_APPROVE(conn, iDocNo, statusApp, comment+"(by Web)");
					System.out.println("UpdateSERV_APPROVE OK  :"+x);
					//System.out.println("333------Status statusApp: "+statusApp);	
					int ex = this.UpdateBB_APPROVE(conn, iDocNo, "B");
				}	
				if(!temp[0].equals("")){
					System.out.println("doc: "+iDocNo+" :sent to :"+temp[0]);
					EmailSending(temp[0], "", doString.MS874ToUnicode(subJect), doString.MS874ToUnicode(mailBody));
					System.out.println("Sender OK..");
				}else{
					System.out.println("Email sender is Empty doc_ref: "+iDocNo);
				}
			}

			// TODO : END *******************************
			conn.commit();
			//stmt.close();		
			conn.close();
			conn = null;
			
			String successPage = "SERV_TurnkeyApprList.jsp?sel_project="+selProject+"&house_id="+houseId;
			successPage += "&i_lock="+iLock+"&n_customer="+nCustomer+"&n_cust_tel="+nCustTel+"&d_appoint="+dAppoint+"&d_est_close="+dEstClose;

			
			genRedirectCode(out,savePage,successPage,errorCode,otherMsg);
		} catch (Exception e) {
			System.out.println(" ERROR "+mName+" : " + e.getMessage());
			System.out.println(" ERROR "+mName+" SQL : " + sql.toString());		
			try{
				conn.rollback();
			}catch (Exception ex) {
				// TODO: handle exception
			}
			genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ : "+e.getMessage());
		} finally {
			try {
				if (rs!=null) rs.close(); 
				if (pstmt != null) pstmt.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");

	}
	//Add by pradoem
	//2012.08.08 for send mail to Approved zero_defection
	protected static void  EmailSending(String toReceive,String toCc,String subject,String body) throws Exception{
		LHMail serverEmail = new LHMail();	
		//production
		//serverEmail.sendBBMail("132.146.1.12", "lh.co.th", "application", toReceive, toCc, doString.MS874ToUnicode(subject), doString.MS874ToUnicode(body));	
		//Test Localhost
		LHSendMail.sendMail("lh.co.th", "application", toReceive, toCc , doString.MS874ToUnicode(subject) , doString.MS874ToUnicode(body));
	}
	
	protected static void emailSendingAttachImg(String toReceive,String toCc,String subject,String body) throws Exception{
		//For lh.co.th production 
		LHSendMail.sendMail("lh.co.th", "application", toReceive, toCc , doString.MS874ToUnicode(subject) , doString.MS874ToUnicode(body));
		
		//For Localhost test 
		//LHSendMailAttach mailServic = new LHSendMailAttach();
		//mailServic.sendMail("lh.co.th", "application", toReceive, toCc , doString.MS874ToUnicode(subject) , doString.MS874ToUnicode(body),listImg);
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
	
	public boolean isTurnkeyEmailAlert (Connection conn,String docId,int tempCnt) {
		ResultSet rs = null;
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		boolean isSendEmail = false;
		
		double amount = 0d;
		int cnt_img = 0;
		try{
			sql.delete(0, sql.length());
			sql.append(" select  sum(x.z_amount_pay) as amount   from lan:serv_docdt x ")
				  .append(" where x.i_docno = '"+docId+"' ");	
			pstmt = conn.prepareStatement(sql.toString()); 
			rs = pstmt.executeQuery();
		   	if(rs.next()){
		   		amount = rs.getDouble("amount");
			} //End While 
			rs.close();
			
			if(amount>500){
				/*sql.delete(0, sql.length());
				sql.append(" select  count(b.i_docno) as cnt_img  from lan:serv_docatt b,lan:serv_docdt x ")
					  .append(" where b.i_docno ='"+docId+"' ")
					  .append(" and b.i_docno = x.i_docno ")
					  .append(" and b.i_keygen = x.i_keygen ");	
				pstmt = conn.prepareStatement(sql.toString()); 
				rs = pstmt.executeQuery();
			   	if(rs.next()){
			   		cnt_img = rs.getInt("cnt_img");
				} //End While 
				rs.close();
				*/
				
				if(tempCnt==0){
					isSendEmail = true;
				}
			}
		}catch(Exception e){
			e.fillInStackTrace();
		}	
		return isSendEmail;
	}
 
	//stmt.executeUpdate("UPDATE docflow:bb_approve set f_status = 'A', d_keyin = CURRENT WHERE n_system = '"+SysNameLHSERV+"' AND i_docno = '" + docNo + "'");
	 public int UpdateBB_APPROVE(Connection conn,String docNo,String f_status) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	     try{
	     	//initial paramter		
				/******************************************************/					
				sql.delete(0, sql.length());
				sql.append(" UPDATE docflow:bb_approve set f_status = '"+f_status+"', d_keyin = CURRENT  WHERE n_system = '"+SysNameLHSERV+"' AND i_docno = '" + docNo + "'");
				pstmt = conn.prepareStatement(sql.toString()); 
				int intUpd = pstmt.executeUpdate();

			  	//System.out.println("##UpdateBB_APPROVE ->end.");				  	 
			  	return intUpd;			  	 
			}catch(Exception e){
				e.printStackTrace();
				System.out.println(" !!UpdateBB_APPROVE Error : " + e.getMessage());
				System.out.println(" !!UpdateBB_APPROVE SQL: "+sql.toString());	
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
  * */
	 public static int UpdateSERV_APPROVE(Connection conn,String docId,String docType,String comment) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	     try{
	     		//initial paramter		    	 
	 			/******************************************************/					
				sql.delete(0, sql.length());
				sql.append(" UPDATE lan:SERV_APPROVE SET  i_doc_type = ").append(removeNull(docType)).append(", d_approve1= CURRENT ,q_empapp_next = q_empapp_next+1 ,i_employ_appcur = null ");
				//value is null or Empty skip not' update record
				if(isValueStrAndObj(comment)){
					//sql.append(" , i_comment1 = '").append(comment).append("' ");
					sql.append(" , i_comment1 = ? ");
				}	
				sql.append(" Where  ")
				   .append("  i_docno = ? ");

				   //.append("  i_docno = '").append(docId).append("' ");
				//System.out.println("-->Update SQL :"+sql.toString());
				pstmt = conn.prepareStatement(sql.toString()); 
				
				int i = 1;
				if(isValueStrAndObj(comment)){
					pstmt.setString(i++, comment);
				}
				pstmt.setString(i++, docId);

				int intUpd = pstmt.executeUpdate();

			  	System.out.println("##UpdateSERV_APPROVE = "+intUpd);				  	 
			  	return intUpd;			  	 
			}catch(Exception e){
				e.printStackTrace();
				System.out.println(" !!UpdateSERV_APPROVE Error : " + e.getMessage());
				System.out.println(" !!UpdateSERV_APPROVE SQL: "+sql.toString());	
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
	 
 /*public int UpdateSERV_APPROVE(Connection conn,String docId,String docType,String comment) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
     try{
     		//initial paramter		    	 
 			/****************************************************** /					
			sql.delete(0, sql.length());
			sql.append(" UPDATE lan:SERV_APPROVE SET  i_doc_type = ").append(Integer.parseInt(docType)).append(", d_approve1= CURRENT ,q_empapp_next = q_empapp_next+1 ,i_employ_appcur = null ");
			//value is null or Empty skip not' update record
			if(isValueStrAndObj(comment)){
				sql.append(" , i_comment1 = '").append(comment).append("' ");
			}	
			sql.append(" Where  ")
			   .append("  i_docno = '").append(docId).append("' ");
			//System.out.println("-->Update SQL :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString()); 
			int intUpd = pstmt.executeUpdate();

		  	//System.out.println("##UpdateSERV_APPROVE ->end.");				  	 
		  	return intUpd;			  	 
		}catch(Exception e){
			e.printStackTrace();
			System.out.println(" !!UpdateSERV_APPROVE Error : " + e.getMessage());
			System.out.println(" !!UpdateSERV_APPROVE SQL: "+sql.toString());	
			return -1;
		}
		finally{			
			//clean up.
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
			}catch(Exception e){}
		}
	}*/
 
	 public String []GetEmail(Connection conn, String docNo) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			 String temp[] = new String[] {"",""};
	     try{	     	
				/*************************************************/		
	    	 
	     	    //*****Find project by user login  
				sql.delete(0,sql.length());
				sql.append("Select i_email_sender,i_email_app1 from lan:SERV_APPROVE  where i_docno = ? ");
				pstmt = conn.prepareStatement(sql.toString()); 
				pstmt.setString(1, docNo);	
				//System.out.println("SQL :"+sql.toString());
				rs = pstmt.executeQuery();	
				if(rs.next()){
					temp[0]= doString.checkString(rs.getString("i_email_sender"), "");
					temp[1] = doString.checkString(rs.getString("i_email_app1"), "");
				}
				rs.close();	
			}catch(Exception e){
					System.out.println(" GetEmail Error : " + e.getMessage());
			}
			finally{			
				//clean up.
				try{
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
				}catch(Exception e){}
			}
		  return temp;		
		}

	 public  Map<String, String> GetEmailAlertTK(Connection conn) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			String  tempEmail = "";
	        try{
	        	//initial paramter	
	        	
				/*************************************************/			
				sql.delete(0,sql.length());
				sql.append("Select i_prjcal_id  From lan:svc_stdpj Where i_company  = 'TO'  and  i_project  = '999' ");
				pstmt = conn.prepareStatement(sql.toString()); 	
				//System.out.println("SQL :"+sql.toString());
				rs = pstmt.executeQuery();	
				if(rs.next()){
					tempEmail = doString.checkString(rs.getString("i_prjcal_id"), "");
				}
				rs.close();	
				
				Map<String, String> objMap = new HashMap();
				objMap.put("TO_VP", tempEmail);
				
				
				sql.delete(0,sql.length());
				sql.append("Select i_prjcal_id  From lan:svc_stdpj Where i_company  = 'TO'  and  i_project  = '888' ");
				pstmt = conn.prepareStatement(sql.toString()); 	
				//System.out.println("SQL :"+sql.toString());
				rs = pstmt.executeQuery();	
				if(rs.next()){
					tempEmail = doString.checkString(rs.getString("i_prjcal_id"), "");
				}
				rs.close();	
				
				objMap.put("TO_CC", tempEmail);
				return objMap;		
			}catch(Exception e){
				System.out.println(" GetEmailAlertTK Error : " + e.getMessage());
				return null;
			}
			finally{			
				//clean up.
				try{
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
				}catch(Exception e){}
			}

		}

	  public String GetLockServApporve(Connection conn, String docNo) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			String  lock = "";
	        try{
	        	//initial paramter	     	
				/*************************************************/			
	        	//*****Find project by user login  
				sql.delete(0,sql.length());
				sql.append("Select i_lock From lan:serv_approve Where i_docno = ? ");
				pstmt = conn.prepareStatement(sql.toString()); 
				pstmt.setString(1, docNo);	
				//System.out.println("SQL :"+sql.toString());
				rs = pstmt.executeQuery();	
				if(rs.next()){
					lock = doString.checkString(rs.getString("i_lock"), "");
				}
				rs.close();	
			}catch(Exception e){
	 				System.out.println(" GetLockServApporve Error : " + e.getMessage());
			}
			finally{			
				//clean up.
				try{
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
				}catch(Exception e){}
			}
		  return lock;		
		}
	  
	/*  comment by pradoem 
	 * 
	 private static List ListImagsAttach (Connection conn,String docNo) {
			StringBuffer sql = new StringBuffer();	
			StringBuffer sql2 = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			
			PreparedStatement pstmt2 = null;
			ResultSet rs2 = null;
			
			String pathImg = "/LHServ/pictures/";
	        try{
	        	//initial paramter	
	        	//List listImg = new ArrayList();
	       	 	List strList = null;	     
	       	 	
	         	String i_keygen = "";
				/************************************************* /
	       	 	
	       String b_file_name = "", b_file_name2 = "", p_file_name1 = "", p_file_name2 = "", a_file_name = "", a_file_name2 = "";
	       sql2.delete(0,sql.length());
	       sql2.append(" select * from lan:serv_docatt where i_keygen = ?  ");

	       	sql.delete(0,sql.length());
	       	sql.append(" Select a.i_docno,b.i_keygen From lan:serv_dochd a , lan:serv_docdt b ")
	       	   .append(" Where a.i_docno = b.i_docno ")
	    	   .append(" and a.i_docno = '"+docNo+"'  ");
	       	
				pstmt = conn.prepareStatement(sql.toString()); 
				//System.out.println("SQL 'ListImagsAttach' :"+sql.toString());
				rs = pstmt.executeQuery();	
				//------------------
				int i = 0;
				//------------------
				strList =  new ArrayList(); 
				while(rs.next()){
					b_file_name = "";
					b_file_name2 = "";
					p_file_name1 = "";
					p_file_name2 = "";
					a_file_name = "";
					a_file_name2 = "";
					
					i_keygen = doString.checkString(rs.getString("i_keygen"),"");
					//strList =  new ArrayList(); 
					pstmt2 = conn.prepareStatement(sql2.toString()); 
					pstmt2.setString(1, i_keygen);
	 				//System.out.println("SQL 'ListImagsAttach2' :"+sql2.toString());
	 				rs2 = pstmt2.executeQuery();
	 				if(rs2.next()){
			 	       	b_file_name = doString.checkString(rs2.getString("b_file_name"),"");
			 	       	b_file_name2 = doString.checkString(rs2.getString("b_file_name2"),"");
			 	       	p_file_name1 = doString.checkString(rs2.getString("p_file_name1"),"");
			 	       	p_file_name2 = doString.checkString(rs2.getString("p_file_name2"),"");
			 	       	a_file_name = doString.checkString(rs2.getString("a_file_name"),"");
			 	       	a_file_name2 = doString.checkString(rs2.getString("a_file_name2"),"");

	 				}
	 				if(!"".equals(b_file_name)){
	 					strList.add(i++, pathImg+docNo+"/"+b_file_name);
	 				}
	 				if(!"".equals(b_file_name2)){
	 					strList.add(i++, pathImg+docNo+"/"+b_file_name2);
	 				}
	 				if(!"".equals(p_file_name1)){
	 					strList.add(i++, pathImg+docNo+"/"+p_file_name1);
	 				}
	 				if(!"".equals(p_file_name2)){
	 					strList.add(i++, pathImg+docNo+"/"+p_file_name2);
	 				}
	 				if(!"".equals(a_file_name)){
	 					strList.add(i++, pathImg+docNo+"/"+a_file_name);
	 				}
	 				if(!"".equals(a_file_name2)){
	 					strList.add(i++, pathImg+docNo+"/"+a_file_name2);
	 				}
	 				//"<%=cid%><%=request.getContextPath()+"/pictures/"+i_document+"/"+b_file_name%>"
	 				
				}
				rs.close();	
		   			
				//************************************************** /
			  	//System.out.println("##ListImagsAttach ->successfully.");				  	 
			  	return strList;			  	 
			}catch(Exception e){
				System.err.println("!!!ListImagsAttach , " +sysName+":" + e.getMessage());
				System.err.println(" SQL Exception: "+sql.toString());		
				return null;
			}
			finally{			
				//clean up.
				try{
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
					if(rs2!=null){rs2.close();}
					if(pstmt2!=null){pstmt2.close();}
				}catch(Exception e){}
			}
		}
 */
	public static  String removeNull(String str){
		if ((str == null) || str.equals("")) {
				return  "0";
			}else{
				return  str;
		}
	}
	public static boolean isValueStrAndObj(String str) throws Exception{
		if ((str == null) || str.equals("")) {
			 return false;
		}else{
			 return true;
		 }
	}
	
}