package serv.servlets;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Calendar;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.StringTokenizer;
import java.util.Vector;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import serv.common.Constants;
import serv.common.ItmJobManagement;
import serv.common.User;
import com.lh.exception.InvalidParameterException;
import com.lh.servlet.DBServlet;
import com.lh.util.doString;

/**
 * Servlet implementation class for Servlet: SERV_CompTaskSaveImgServlet
 * Last Modify by :pradoem
 * date : 2015.04.10
 * desc : upload picture 
 */
   
public class SERV_CompTaskSaveImgServlet extends DBServlet  {
	
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
		
		//String mode = doString.checkString(req.getParameter("mode"),"add");
		String iDocNo = doString.checkString(req.getParameter("i_docno"),"");		
		String selProj = doString.checkString(req.getParameter("sel_project"),"");
		String houseId = doString.UnicodeToMS874(doString.checkString(req.getParameter("house_id"),""));
		String iLock = doString.checkString(req.getParameter("i_lock"),"").toUpperCase();
		//String nCustomer = doString.UnicodeToMS874(doString.checkString(req.getParameter("n_customer"),""));
		//String nCustTel = doString.UnicodeToMS874(doString.checkString(req.getParameter("n_cust_tel"),""));
		//String dAppoint = doString.checkString(req.getParameter("d_appoint"),"");
		String dEstClose = doString.checkString(req.getParameter("d_est_close"),"");
		String fQC = doString.checkString(req.getParameter("f_qc"),"N");
		String qcStatus = "";
		if (fQC.equals("Y")) {
			qcStatus = "OPN";
		}		 

		String cDesc = "";		
		//---========================== Get Item Job List  ===============================----//
		ItmJobManagement itm = new ItmJobManagement(req,res);
		itm.updateValuesFromRequest(); // update new values from request.
		itm.updateItemSession(); // update session before use
       

		//---======== Get Item Details for show ===========---//
		Vector jobList = itm.getJobList();
		Hashtable jobItm = itm.getItmJobList();
		/*Hashtable jobVendor = itm.getVendorList();
		Hashtable jobWage = itm.getWageList();
		Hashtable jobCustomWage = itm.getCustomWageList();
		Hashtable jobCustomGoods = itm.getCustomGoodsList();
		Hashtable jobGoods = itm.getGoodsList();
		Hashtable jobBOQ = itm.getBOQList();
		Hashtable jobComment = itm.getCommentList();
		Hashtable jobArea = itm.getAreaList();*/ 

		  

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
		String successPage = "SERV_CompTask_List.jsp?i_docno="+iDocNo+"&sel_project="+selProj+"&i_house="+houseId+"&i_lock="+iLock;
		String errorPage = "SERV_CompTask_UploadImg.jsp?load=YES&i_docno="+iDocNo;

		String otherMsg = "";
		String errorCode = "";

		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		//PreparedStatement pstmtIntZero = null;
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;

		 try {
			if (ds == null){
				getDS();
			}
			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();

			//----------- save upload data(2015.04.10) -------------//
			//saveUpload(session,stmt,iDocNo,user.getsessionId(),jobList,jobItm);
			
			
			conn.commit();		
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
			
			//---==== Clear ItemJob Session =====----//
			itm.removeItemSession();
			// Redirect to the finish page.
			genRedirectCode(out,savePage,successPage,errorCode,otherMsg);

		} catch (Exception e) {
			if (e instanceof InvalidParameterException) {
				showError(out, doString.UnicodeToMS874(e.getMessage()));
			} else {           
			System.out.println(" ERROR "+mName+" : " + e.getMessage());
			System.out.println(" ERROR "+mName+" SQL : " + sql.toString());
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

	public void XsaveUpload(HttpSession session,Statement stmt,String iDocNo,String sessionId,Vector jobList,Hashtable jobItm) throws Exception {

		String uploadId = doString.checkString((String) session.getAttribute("session_upload_id"),"");
		if (uploadId.trim().length()<=0) {
			 uploadId = sessionId;
			 session.setAttribute("session_upload_id",uploadId);
		}
		String targetPath = getServletContext().getRealPath("/pictures/")+File.separator+iDocNo;
		String uploadPath = getServletContext().getRealPath("/pictures/temp/")+File.separator+uploadId;
		
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
				
		int SEQ = 1;
		String i_keygen = "";
		for (int i=0;i<keyList.size();i++) {	
					i_keygen = "";
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

					//data = new StringTokenizer(keyFile,"_");
					//System.out.println("data  :"+data);
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
						 
						 //------ at least 1 file has attach , if no file attach no insert ----------//	
						 sql.delete(0,sql.length());
						 sql.append(" insert into lan:serv_docatt  ")
							   .append(" ( i_docno,			i_seq,					i_itmjob,				i_vendor,				i_itmjob_area, ")
							   .append("   b_name,			b_file_name,		b_name2,			b_file_name2,  ")
							   .append("   a_name,			a_file_name,		a_name2,			a_file_name2,  ")
							   .append("   p_name1,		p_file_name1,	p_name2,			p_file_name2 , i_keygen ")
							   .append(" ) values ('"+iDocNo+"' , '"+seqId+"' , '"+jobItem+"' , '"+vendor+"' , '"+area+"' , ")
							   .append(" '"+realFileBefore+"','"+fileNameBefore+"','"+realFileBefore2+"','"+fileNameBefore2+"', ")
							   .append(" '"+realFileAfter+"','"+fileNameAfter+"','"+realFileAfter2+"','"+fileNameAfter2+"', ")
							   .append(" '"+realFileProcess+"','"+fileNameProcess+"','"+realFileProcess2+"','"+fileNameProcess2+"','"+i_keygen+"') ");
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
			System.out.println("Delete Temp File Error !!");
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