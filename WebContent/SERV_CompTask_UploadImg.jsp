<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="java.text.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@page import="java.io.*" %>
<%@ include file="function.jsp" %>

<%!

public void copyFile(File in, File out) throws Exception {
	FileInputStream fis  = new FileInputStream(in);
	FileOutputStream fos = new FileOutputStream(out);
	byte[] buf = new byte[1024];
	int i = 0;
	while((i=fis.read(buf))!=-1) {
	  fos.write(buf, 0, i);
	  }
	fis.close();
	fos.close();
}


   public void GenerateKeyGen(Connection conn,String iDocNo){
        StringBuffer sql = new StringBuffer();
        StringBuffer sql2 = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        PreparedStatement pstmt  = null;
        
        Random rand = new Random();
        String i_keygen = "";
        String itemKey = "";
        String iItmJob = "";
        int cnt = 0;
        try {
        	//---------------------------
        	sql2.delete(0,sql.length());
			sql2.append(" UPDATE lan:serv_docdt ")
				.append(" SET i_seq = ? , i_keygen = ?  ")
				.append(" WHERE i_docno = ? AND i_itmjob=?  AND i_vendor = ?   AND i_itmjob_area = ? AND rowid= ? ");	
	      	//---------------------------

            stmt = conn.createStatement();
  			sql.delete(0, sql.length());
			sql.append(" Select count(*) as cnt  ")
				.append(" From lan:serv_docdt")
				.append(" Where i_docno  = '"+iDocNo+"' AND i_keygen  is not null  AND i_keygen <> '' "); 
				//System.out.println("SQL  :"+sql.toString());
				rs = stmt.executeQuery(sql.toString());    				   
			    if(rs.next()){
			       cnt  = rs.getInt("cnt");
			    } 					  
                rs.close();
                
                if(cnt==0){
				     //Gen KeyGen && Insert into docdt
				     sql.delete(0, sql.length());
					 sql.append(" Select *,rowid ")
						.append(" From lan:serv_docdt")
						.append(" Where i_docno  = '"+iDocNo+"'  order by i_itmjob  "); 
				     rs = stmt.executeQuery(sql.toString());
				     int i = 1;  
				     int ROW_ID = 0; 
				      				   
					 while(rs.next()){
							i_keygen = "";
							itemKey = "";
							iItmJob = "";
							i_keygen = doString.checkString(rs.getString("i_keygen"),"");
							iItmJob  = doString.checkString(rs.getString("i_itmjob"),"");
							
							ROW_ID = rs.getInt("rowid");
							
							if(i_keygen.equals("")){
		  						 itemKey = iItmJob+"_"; 
							   	 while (itemKey.length()<20) {
									itemKey += rand.nextInt(10); 
							      }
							   	i_keygen = itemKey;
		  					}
							//System.out.println("---i_keygen :"+i_keygen);

							pstmt = conn.prepareStatement(sql2.toString());
							pstmt.setInt(1,i);	
							pstmt.setString(2,i_keygen);
							pstmt.setString(3,iDocNo);
							pstmt.setString(4,iItmJob);
							pstmt.setString(5,doString.checkString(rs.getString("i_vendor"),""));
							pstmt.setString(6,doString.checkString(rs.getString("i_itmjob_area"),""));
							pstmt.setInt(7,ROW_ID);
							
							pstmt.executeUpdate();
							//pstmt.close();							 							 
					 	 
						    //System.out.println(i+":Insert Keygen OK...");
						    i++;
					 } 		
				     //LH-075-5600012 	01010001  	  
                }
                stmt.close();
        }catch(Exception e) {
            System.out.println(" GenerateKeyGen Error : " + e.getMessage());
        } finally{
            try  {
                if(rs != null) {
                    rs.close();
                }
                if(stmt != null){
                    stmt.close();
                }
                if(pstmt != null){
                    pstmt.close();
                }
            }
            catch(Exception ex) { }
        }
    } 

 %>
 
<%
/**
 * Modify by : pradoem@lh.co.th
 * date : 2012.08.22
 * version 1.1
 * desc:  add information list to Zero Defect && send mail to www9.lh.co.th to user
 */ 
 
//String ParameterNames = "";
//for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
//	ParameterNames = (String)e.nextElement();
//	System.out.println(ParameterNames + " = "+request.getParameter(ParameterNames));
//}
//System.out.println("*******************************************");

String sessionId = user.getsessionId();
String userId = user.getUserID();
String empname = user.getEmpName();
String jName = "SERV_CompTask_UploadImg.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);
   doString str = new doString();

   //----============ Declare Variables for input data ===========----//
   String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase();
   if  (selProj.length()==0) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       session.setAttribute("sess_sel_proj",selProj);
   }
   //String docNo = doString.checkString(request.getParameter("i_docno"),"").toUpperCase();
   String houseId = doString.checkString(request.getParameter("i_house"),"").toUpperCase();
   String lock = doString.checkString(request.getParameter("i_lock"),"").toUpperCase();
   
   
   String iDocNo = doString.checkString(request.getParameter("i_docno"),"");
   String load = doString.checkString(request.getParameter("load"),"");
  //String edit = doString.checkString(request.getParameter("edit"),"");
  //String popup = doString.checkString(request.getParameter("popup"),"");
   
    //-------------- check upload file --------------//
	String uploadId = doString.checkString((String) session.getAttribute("session_upload_id"),user.getsessionId());
		
	//System.out.println("<<--uploadId :"+uploadId);
	if (uploadId.trim().length()<=0) {
			 uploadId = user.getsessionId();
			 session.setAttribute("session_upload_id",uploadId);
	} 
   String realPath = getServletContext().getRealPath("/pictures/temp/")+File.separator+uploadId;
   String docPath = getServletContext().getRealPath("/pictures/")+File.separator+iDocNo;
   String delFile = doString.checkString(request.getParameter("del"),"");
   
   //-----========= Declare Variables for OpenJob Page ===========----//
   String mode = doString.checkString(request.getParameter("mode"),"edit");
   //String dAppoint= doString.checkString(request.getParameter("d_appoint"),"");
   //String dEstClose= doString.checkString(request.getParameter("d_est_close"),"");   
   ItmJobManagement itm = new ItmJobManagement(request,response);
   itm.updateValuesFromRequest(); // update new values from request.
   itm.updateItemSession(); // update session before use
  //---=======================================================----//   
   
   //-----========= Declare Variables for Search Custoemr ===========----//
  // String selProj = "";
   String iCompany = "";
   String iProject = "";
   String projDesc = "";
   //String houseId = "";
   String iLock = "";
   String nCustomer = "";
   String nCustTel = "";
   String cDesc = "";   
   String inFormDate = "";
   String inFormEmp = "";
   String dAppoint = "";
   String dEstClose = "";
      
   String housePlan = "-";
   String custName = "-";
   String custTel = "-";
   String guranteeDesc = "-";
   String guranteeDate = "-";
   String iCustomer = "";
   String name_serv = "";
   String emp_serv = "";
   String chk_condo = "";
   Vector jobList = new Vector();
   boolean foundClose = false;
   Hashtable docdt = new Hashtable();

			       
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;

	Statement stmt2 = null;
	ResultSet rs2 = null;
	
	SERV_CommonData common = null;

	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();       
		stmt2 = conn.createStatement();  
		common = new SERV_CommonData(conn);
        //----=======================================----//   
        
	  // System.out.println("iDocNo :"+iDocNo.length());
	   if (iDocNo.length()>0) {
	        
	         
	         //Update by pradoem 2015.04.28
	         GenerateKeyGen(conn,iDocNo);
	         
	        //----======================== Find DocHD Data =============================----//
			 Hashtable tmpHeader = common.getDocHeaderDetails(iDocNo);
		     inFormEmp = doString.DisplayThai(doString.checkString((String) tmpHeader.get("inform_emp"),""));
	         projDesc = doString.DisplayThai(doString.checkString((String) tmpHeader.get("proj_desc"),""));
	         iCompany = doString.checkString((String) tmpHeader.get("i_company"),"");
	         iProject = doString.checkString((String) tmpHeader.get("i_project"),"");
	         selProj = iCompany+":"+iProject;
	         nCustomer = doString.DisplayThai(doString.checkString((String) tmpHeader.get("n_customer"),""));
	         nCustTel = doString.DisplayThai(doString.checkString((String) tmpHeader.get("n_cust_tel"),""));
	         iLock = doString.checkString((String) tmpHeader.get("i_lock"),"");
	         cDesc = doString.DisplayThai(doString.checkString((String) tmpHeader.get("c_desc"),""));
	         cDesc = str.replace(cDesc,"|break|","<br>");
	         cDesc = str.replace(cDesc," ","&nbsp;"); 			
			 inFormDate = doString.DisplayThai(doString.checkString((String) tmpHeader.get("inform_date"),""));
			 dAppoint = doString.DisplayThai(doString.checkString((String) tmpHeader.get("d_appoint"),"-"));
			 dEstClose = doString.DisplayThai(doString.checkString((String) tmpHeader.get("d_est_close"),"-"));

			//----------------------------- Project Condo ------------------------
			sql.delete(0, sql.length());
			sql.append("select i_company, i_project ")
				 .append("from lan:serv_condo ")
				 .append("where i_company = '"+iCompany+"' ")
				 .append("and i_project = '"+iProject+"' ");
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			if (rs.next()==true) {
				chk_condo = "Y";
			} else {
				chk_condo = "N";
			}

			sql.delete(0, sql.length());
			sql.append("select distinct i_service_employ ")
				 .append("from lan:serv_dochd ")
				 .append("where i_docno = '"+iDocNo+"' ");		
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			if (rs.next()) {
				emp_serv = doString.checkString(rs.getString("i_service_employ"));
			}                       

			name_serv = "";			
			if (emp_serv.trim().length()>4) {
						sql.delete(0, sql.length());
						sql.append("select distinct i_employ, n_prename_th, n_nemploy_th, n_semploy_th ")
							 .append("from docflow:acemploy ")
							 .append("where i_employ = '"+emp_serv+"' ");		
						servlog.startLog(sql.toString());
						rs = stmt.executeQuery(sql.toString());
						servlog.endLog();
						if (rs.next()) {
							name_serv = doString.checkString(doString.DisplayThai(rs.getString("n_prename_th")))+doString.checkString(doString.DisplayThai(rs.getString("n_nemploy_th")))+" "+doString.checkString(doString.DisplayThai(rs.getString("n_semploy_th")));
						}	
			} else {
		
						sql.delete(0, sql.length());
						sql.append("select distinct i_cust, n_name, n_sname ")
							 .append("from lan:serv_cname ")
							 .append("where i_cust = '"+emp_serv+"' ");		
						servlog.startLog(sql.toString());
						rs = stmt.executeQuery(sql.toString());
						servlog.endLog();
						if (rs.next()) {
							name_serv = doString.checkString(doString.DisplayThai(rs.getString("n_name")))+" "+doString.checkString(doString.DisplayThai(rs.getString("n_sname")));
						}				
			}//end if chk emp_serv
			
			//----======================= Get Customer Details ===========================----//
			Hashtable tmpCust = common.getCustomerDetails(iCompany,iProject,iLock);
		    housePlan = doString.checkString((String) tmpCust.get("i_model"),"");
		    houseId = doString.checkString((String) tmpCust.get("i_house"),"");
		    iLock = doString.checkString((String) tmpCust.get("i_lock"),"");
		    iCustomer = doString.checkString((String) tmpCust.get("i_customer"),"");
			guranteeDesc = doString.DisplayThai(doString.checkString((String) tmpCust.get("gurantee_desc"),""));
			guranteeDate = doString.DisplayThai(doString.checkString((String) tmpCust.get("gurantee_date"),""));
			custName = doString.DisplayThai(doString.checkString((String) tmpCust.get("n_customer"),""));
			custTel = doString.DisplayThai(doString.checkString((String) tmpCust.get("n_cust_tel"),""));

			
			//----============================= Get JobItem =============================----//
			sql.delete(0,sql.length());
			sql.append(" select a.*,b.n_itmjob,b.n_count,c.n_desc,d.bus_name from lan:serv_docdt a ")
			      .append(" left join lan:serv_boq b on b.i_itmjob=a.i_itmjob ")
			      .append(" left join lan:serv_xstd c on c.i_type='01' and c.i_code=a.i_itmjob_area ")
			      .append(" left join lan:stpvendr d on d.vend_code=a.i_vendor ")
			      .append(" where a.i_docno='").append(iDocNo).append("' and a.f_itmstatus<>'CAN' ")
			      .append(" order by i_seq,i_itmjob ");
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			while (rs.next()) {
				   docdt = new Hashtable();
				   docdt.put("n_itmjob",doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")),""));
				   docdt.put("n_count",doString.checkString(doString.DisplayThai(rs.getString("n_count")),""));
				   docdt.put("bus_name",doString.checkString(doString.DisplayThai(rs.getString("bus_name")),""));
				   docdt.put("q_wage_unit",doString.checkString(doString.DisplayThai(rs.getString("q_wage_unit")),""));
				   docdt.put("z_wage_price",doString.checkString(Double.toString(rs.getDouble("z_wage_price")),""));
				   docdt.put("q_good_unit",doString.checkString(doString.DisplayThai(rs.getString("q_good_unit")),""));
				   docdt.put("z_good_price",doString.checkString(Double.toString(rs.getDouble("z_good_price")),""));
				   docdt.put("z_amount_pay",doString.checkString(doString.DisplayThai(rs.getString("z_amount_pay")),""));
				   docdt.put("c_itmjob",doString.checkString(doString.DisplayThai(rs.getString("c_itmjob")),""));
				   docdt.put("n_desc",doString.checkString(doString.DisplayThai(rs.getString("n_desc")),""));			
				   docdt.put("f_itmstatus",doString.checkString(rs.getString("f_itmstatus"),""));	
				   
				   docdt.put("i_seq",doString.checkString(rs.getString("i_seq"),""));	
				   docdt.put("i_keygen",doString.checkString(rs.getString("i_keygen"),""));	
				   jobList.addElement(docdt);
				   
				   	   //========================================for Edit=================================================================
						//------------- get file attach ----------//
						if (load.equalsIgnoreCase("YES")) {	
						   sql.delete(0, sql.length());
						   sql.append(" Select *  ")
				             .append(" From lan:serv_docatt ")
				       		 .append(" Where i_docno  = '"+iDocNo+"'  AND i_keygen = '"+doString.checkString(rs.getString("i_keygen"),"")+"' ")
				 			 .append(" order by i_seq ");		
		
							//servlog.startLog(sql.toString());
							rs2 = stmt2.executeQuery(sql.toString());
							if(rs2.next()){
								//LH-075-5600057_01010001_38592628198_999999_99
					   			String keyFile   = iDocNo+"_"+doString.checkString(rs.getString("i_keygen"),"");							    						  					    					    
								keyFile += "_999999";
								keyFile += "_99"; 

								if(iDocNo.length()>0 && doString.checkString(rs.getString("i_keygen"),"").length()>0 ){
									//----- before file -----//
									session.setAttribute("session_upload_before_"+keyFile,doString.checkString(rs2.getString("b_file_name"),"")); 
									session.setAttribute("session_realfile_before_"+keyFile,doString.checkString(rs2.getString("b_name"),""));  
									
									session.setAttribute("session_upload_before2_"+keyFile,doString.checkString(rs2.getString("b_file_name2"),""));  
									session.setAttribute("session_realfile_before2_"+keyFile,doString.checkString(rs2.getString("b_name2"),""));  

									//----- process file -----//
									session.setAttribute("session_upload_process_"+keyFile,doString.checkString(rs2.getString("p_file_name1"),""));  
									session.setAttribute("session_realfile_process_"+keyFile,doString.checkString(rs2.getString("p_name1"),""));  
	
									session.setAttribute("session_upload_process2_"+keyFile,doString.checkString(rs2.getString("p_file_name2"),""));  
									session.setAttribute("session_realfile_process2_"+keyFile,doString.checkString(rs2.getString("p_name2"),""));  

	
									//----- after file -----//
									session.setAttribute("session_upload_after_"+keyFile,doString.checkString(rs2.getString("a_file_name"),""));  
									session.setAttribute("session_realfile_after_"+keyFile,doString.checkString(rs2.getString("a_name"),""));  

									session.setAttribute("session_upload_after2_"+keyFile,doString.checkString(rs2.getString("a_file_name2"),""));  
									session.setAttribute("session_realfile_after2_"+keyFile,doString.checkString(rs2.getString("a_name2"),"")); 

	
									//------- check folder -----------//
									File target = new File(realPath);
									if (!target.exists()) {
										target.mkdirs();
									}		
	
									//------------- copy before file -----------//
									File mfile = new File(docPath,doString.checkString(rs2.getString("b_file_name"),""));
									if (doString.checkString(rs2.getString("b_file_name"),"").length()>0 && mfile.exists()) {
										File targetFile = new File(realPath,doString.checkString(rs2.getString("b_file_name"),""));
										if (targetFile.exists()) {
											targetFile.delete();			
										}			
										copyFile(mfile,targetFile);
									}
	
									mfile = new File(docPath,doString.checkString(rs2.getString("b_file_name2"),""));
									if (doString.checkString(rs2.getString("b_file_name2"),"").length()>0 && mfile.exists()) {
										File targetFile = new File(realPath,doString.checkString(rs2.getString("b_file_name2"),""));
										if (targetFile.exists()) {
											targetFile.delete();			
										}			
										copyFile(mfile,targetFile);
									}
	
									//------------- copy process file -----------//
									mfile = new File(docPath,doString.checkString(rs2.getString("p_file_name1"),""));
									if (doString.checkString(rs2.getString("p_file_name1"),"").length()>0 && mfile.exists()) {
										File targetFile = new File(realPath,doString.checkString(rs2.getString("p_file_name1"),""));
										if (targetFile.exists()) {
											targetFile.delete();			
										}			
										copyFile(mfile,targetFile);
									}
	
									mfile = new File(docPath,doString.checkString(rs2.getString("p_file_name2"),""));
									if (doString.checkString(rs2.getString("p_file_name2"),"").length()>0 && mfile.exists()) {
										File targetFile = new File(realPath,doString.checkString(rs2.getString("p_file_name2"),""));
										if (targetFile.exists()) {
											targetFile.delete();			
										}			
										copyFile(mfile,targetFile);
									}
	
									//------------- copy after file -----------//
									mfile = new File(docPath,doString.checkString(rs2.getString("a_file_name"),""));
									if (doString.checkString(rs2.getString("a_file_name"),"").length()>0 && mfile.exists()) {
										File targetFile = new File(realPath,doString.checkString(rs2.getString("a_file_name"),""));
										if (targetFile.exists()) {
											targetFile.delete();			
										}			
										copyFile(mfile,targetFile);
									}
	
									mfile = new File(docPath,doString.checkString(rs2.getString("a_file_name2"),""));
									if (doString.checkString(rs2.getString("a_file_name2"),"").length()>0 && mfile.exists()) {
										File targetFile = new File(realPath,doString.checkString(rs2.getString("a_file_name2"),""));
										if (targetFile.exists()) {
											targetFile.delete();			
										}			
										copyFile(mfile,targetFile);
									}
								}//#if check null docId			
							}//#RS2.next
						}//#YES
						//========================================for Edit=================================================================	

			} // end while
			rs.close();
			//----=====================================================================----//


			//----============================= check close item =============================----//
			sql.delete(0,sql.length());
			sql.append(" select * from lan:serv_payment where i_docno='").append(iDocNo).append("' and f_itmstatus='CLS' ");
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			if (rs.next()) {
				foundClose = true;
			} // end while
			rs.close();
			//----=====================================================================----//
				
		    
	   } // end if check i_docno
   
%>


<HTML>
<HEAD>
<TITLE>Complete Task Upload image</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<!--   for upload -->
<script language="javascript" src="resources/js/upload.js"></script>
<!-- use openUploadWindow(contextPath,sessionId) method --->


<script language="javascript">
<!--
 function openUploadWin(keyFile) {	
  	   var result = openUploadWindow('<%=request.getContextPath()%>','<%=uploadId%>',keyFile);
	   if (result=="OK") {
			document.forms[0].action='SERV_CompTask_UploadImg.jsp';
			document.forms[0].submit();
	   }
   }

	function delFile(id) {
	
		if (confirm("คุณแน่ใจว่าต้องการลบไฟล์แนบนี้ ?")) {
			document.forms[0].action='SERV_CompTask_UploadImg.jsp?del='+id;
			document.forms[0].submit();
		}
	}
 //--------------------------------
 
  function doSubmit() {

     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_CompTaskSaveImgServlet";
     document.forms[0].submit();
  }  
//-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">

<input type="hidden" name="mode" value="<%=mode%>">
<input type="hidden" name="i_docno" value="<%=iDocNo%>">
<input type="hidden" name="d_appoint" value="<%=dAppoint%>">
<input type="hidden" name="d_est_close" value="<%=dEstClose%>">

<input type="hidden" name="sel_project" value="<%=selProj%>">
<input type="hidden" name="i_house" value="<%=houseId%>">
<input type="hidden" name=i_lock value="<%=lock%>">



<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            Complete Task Uploads Images</td>
          <td width="50%" align="right">&nbsp;</td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดการแจ้งซ่อม</td>
                <td class="item_tab3"></td>
                <td>&nbsp;</td>                
              </tr>
            </table>


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop">&nbsp;</td>
    <td width="5" valign="top" align="right"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR" align="center">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td class="item ; dotline01" height="22" width="13%">โครงการ :</td>
    <td height="22" width="39%" class="dotline01"><%=projDesc%></td>
    <td height="22" class="item ; dotline01" width="14%">เลขที่ใบแจ้งซ่อม
      :</td>
    <td height="22" width="34%" class="dotline01"><%=iDocNo%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">บ้านเลขที่ :</td>
    <td height="22" width="39%" class="dotline01"><%=houseId%></td>
    <td height="22" class="item ; dotline01" width="14%">แปลง :</td>
    <td height="22" width="34%" class="dotline01"><%=iLock%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">แบบบ้าน :</td>
    <td height="22" width="39%" class="dotline01"><%=housePlan%></td>
    <td height="22" class="item ; dotline01" width="14%">&nbsp;</td>
    <td height="22" width="34%" class="dotline01">&nbsp;</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ชื่อผู้แจ้ง/ลูกค้า
      :</td>
    <td height="22" width="39%" class="dotline01"><%=common.joinContactAndOwner(nCustomer,custName)%></td>
    <td height="22" class="item ; dotline01" width="14%">โทรศัพท์ติดต่อ :</td>
    <td height="22" width="34%" class="dotline01"><%=common.joinContactAndOwner(nCustTel,custTel)%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">การประกัน :</td>
    <td height="22" width="39%" class="dotline01"><%=guranteeDesc%></td>
    <td height="22" class="item ; dotline01" width="14%">วันที่หมดประกัน
      :</td>
    <td height="22" width="34%" class="dotline01"><%=guranteeDate%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ผู้รับเรื่อง
      :</td>
    <td height="22" width="39%" class="dotline01"><% if(chk_condo.equals("Y")) { out.println(name_serv); } else {  out.println(inFormEmp);  } %></td>
    <td height="22" class="item ; dotline01" width="14%">วันเวลาที่แจ้ง
      :</td>
    <td height="22" width="34%" class="dotline01"><%=inFormDate%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">วันที่นัดซ่อม
      :</td>
    <td height="22" width="39%" class="dotline01"><%=dAppoint%></td>
    <td height="22" class="item ; dotline01" width="14%">วันที่ประมาณการเสร็จ
      :</td>
    <td height="22" width="34%" class="dotline01"><%=dEstClose%></td>
  </tr>
</table>

</td>
  </tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>


<br style="font-size:10pt">


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายการซ่อม</td>
                <td class="item_tab3"></td>
                <td>&nbsp;</td>
              </tr>
            </table>


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
    <td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>





<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL">
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="3%" rowspan="2" class="col_name">No.</td>
          <td width="17%" rowspan="2" class="col_name">รายการซ่อม</td>
          <td width="6%" rowspan="2" class="col_name">หน่วยนับ</td>
          <td width="20%" rowspan="2" class="col_name">ผู้รับเหมา</td>
          <td colspan="3" class="col_name">ค่าแรง</td>
          <td colspan="3" class="col_name">ค่าของ</td>
          <td width="10%" rowspan="2" class="col_name">รวมเงิน</td>
        </tr>
        <tr>
          <td width="8%" class="col_nameLow">ต่อหน่วย</td>
          <td width="5%" class="col_nameLow">จำนวน</td>
          <td width="9%" class="col_nameLow">รวม</td>
          <td width="8%" class="col_nameLow">ต่อหน่วย</td>
          <td width="5%" class="col_nameLow">จำนวน</td>
          <td width="9%" class="col_nameLow">รวม</td>
        </tr>
        <%
        int line = 0;
        DecimalFormat format = new DecimalFormat("#,##0.00");
        double grandTotalWage = 0.00;
        double grandTotalGoods = 0.00;
        double grandTotal = 0.00;

		docdt  = new Hashtable();
		double wageUnit = 0.0;
		double goodsUnit = 0.0;

		double wagePrice = 0.0;
		double goodsPrice = 0.0;
		double totalWage = 0.00;
		double totalGoods = 0.00;
		double subTotal = 0.00;
        
        for (int i=0;i<jobList.size();i++) {
                line++;
                docdt  = (Hashtable) jobList.elementAt(i);
                wageUnit = Double.parseDouble((String) docdt.get("z_wage_price"));
                goodsUnit = Double.parseDouble((String) docdt.get("z_good_price"));

                wagePrice = Double.parseDouble((String) docdt.get("q_wage_unit"));
                goodsPrice = Double.parseDouble((String) docdt.get("q_good_unit"));
                totalWage = 0.00;
                totalGoods = 0.00;
                subTotal = 0.00;
                
                totalWage = wagePrice * (double) wageUnit;
                totalGoods = goodsPrice * (double) goodsUnit;
                subTotal = totalWage + totalGoods;
                
                grandTotalWage += totalWage;
                grandTotalGoods += totalGoods;
                grandTotal += subTotal;

		        %>
		        <tr>
		          <td width="3%" align="center" class="dotline"><%=line%></td>
		          <td width="17%" class="dotline"><%=doString.checkString((String) docdt.get("n_itmjob"))%></td>
		          <td width="6%" class="dotline" align="center"><%=doString.checkString((String) docdt.get("n_count"))%></td>
		          <td width="20%" class="dotline ; item"><%=doString.checkString((String) docdt.get("bus_name"))%></td>
		          <td width="8%" align="right" class="dotline"><%=format.format(wagePrice)%></td>
		          <td width="5%" align="right" class="dotline"><%=format.format(wageUnit)%></td>
		          <td width="9%" align="right" class="dotline"><%=format.format(totalWage)%></td>
		          <td width="8%" align="right" class="dotline"><%=format.format(goodsPrice)%></td>
		          <td width="5%" align="right" class="dotline"><%=format.format(goodsUnit)%></td>
		          <td width="9%" align="right" class="dotline"><%=format.format(totalGoods)%></td>
		          <td width="10%" align="right" class="dotline"><%=format.format(subTotal)%></td>
		        </tr>
		        <%
           } // end for
           
           while (line<Constants.SERV_OPENJOB_LINE) {
                line++;
		        %>
		        <tr>
		          <td width="3%" align="center" class="dotline">&nbsp;</td>
		          <td width="17%" class="dotline">&nbsp;</td>
		          <td width="6%" class="dotline" align="center">&nbsp;</td>
		          <td width="20%" class="dotline ; item">&nbsp;</td>
		          <td width="8%" align="right" class="dotline">&nbsp;</td>
		          <td width="5%" align="right" class="dotline">&nbsp;</td>
		          <td width="9%" align="right" class="dotline">&nbsp;</td>
		          <td width="8%" align="right" class="dotline">&nbsp;</td>
		          <td width="5%" align="right" class="dotline">&nbsp;</td>
		          <td width="9%" align="right" class="dotline">&nbsp;</td>
		          <td width="10%" align="right" class="dotline">&nbsp;</td>
		        </tr>
		        <%
		     }  // end while
        %>
        <tr>
          <td width="3%" align="center" class="dotline">&nbsp;</td>
          <td width="17%" class="dotline">&nbsp;</td>
          <td width="6%" class="dotline" align="center">&nbsp;</td>
          <td width="20%" class="dotline ; item" align="right">รวม</td>
          <td width="8%" align="right" class="dotline ; item">&nbsp;</td>
          <td width="5%" align="right" class="dotline ; item">&nbsp;</td>
          <td width="9%" align="right" class="dotline ; item"><%=format.format(grandTotalWage)%></td>
          <td width="8%" align="right" class="dotline ; item">&nbsp;</td>
          <td width="5%" align="right" class="dotline ; item">&nbsp;</td>
          <td width="9%" align="right" class="dotline ; item"><%=format.format(grandTotalGoods)%></td>
          <td width="10%" align="right" class="dotline ; item"><%=format.format(grandTotal)%></td>
        </tr>      
      </table>
    
    </td>
  </tr>
</table>


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>


<br style="font-size:10pt">


<%
   if (jobList.size()>0) {
%>
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">หมายเหตุ</td>
                <td class="item_tab3"></td>
                <td>&nbsp;</td>
              </tr>
            </table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop">&nbsp;</td>
    <td width="5" valign="top" align="right"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR" align="center">

<table border="0" width="100%" cellspacing="0" cellpadding="0">

 
         <%
        line = 0;
        for (int i=0;i<jobList.size();i++) {
                line++;
                docdt  = (Hashtable) jobList.elementAt(i);          
                %>
				  <tr>
				    <td class="item ; dotline01" height="22" width="12%">รายการที่ <%=line%> :</td>
				    <td height="22" width="80%" class="dotline01"><%=doString.checkString((String) docdt.get("c_itmjob"))%></td>
				    <td height="22" width="8%" class="dotline01"><%=doString.checkString((String) docdt.get("n_desc"))%></td>
				  </tr>
                <%
         } // end for
        
        while (line<Constants.SERV_OPENJOB_LINE) {
            line++;
		        %>  
				  <tr>
				    <td class="item ; dotline01" height="22" width="12%">&nbsp;</td>
				    <td height="22" width="80%" class="dotline01">&nbsp;</td>
				    <td height="22" width="8%" class="dotline01">&nbsp;</td>
				  </tr>
				<%
		  } // end while
       %>  
       
</table>

</td>
  </tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>

<%
   } // end if check jobList
%>

<br style="font-size:10pt">




<%-- ===================================  Attach File ================================================ --%>
<br style="font-size:10pt">

			            <table border="0" width="100%" cellspacing="0" cellpadding="0">
			              <tr>
			                <td class="item_tab1"><img src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
			                <td class="item_tab2" width="160">รูปภาพงานซ่อม(ขนาดไม่เกิน 500 K)</td>
			                <td class="item_tab3"></td>
			                <td class="textgray">&nbsp; </td>
			              </tr>
			            </table>



			<table border="0" width="100%" cellspacing="0" cellpadding="0">
			  <tr>
			    <td width="5" valign="top"><img src="images/Corn01.gif" width="5" height="5"></td>
			    <td class="frmTop">&nbsp;</td>
			    <td width="5" valign="top" align="right"><img src="images/Corn02.gif" width="5" height="5"></td>
			  </tr>
			</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR" align="center">

			<input type="hidden" name="total_item" value="<%=jobList.size()%>">

			<table border="0" width="100%" cellspacing="0" cellpadding="0">
			 <%
				line = 0;
				String keyFile = "";
				String itemId = "";
				String fileName = "";
				String realName = "";
				boolean haveFile = false;
				File file = null;
				
		        String bgColor = "";
				for (int i=0;i<jobList.size();i++) {
						line++;
						bgColor = "#e8f2fe";
						if(line%2==0){
						  bgColor= "#ffffff";
						}
												
						haveFile = false;
						
						docdt  = (Hashtable) jobList.elementAt(i);     
						
						itemId = "";
						itemId = doString.checkString((String) docdt.get("i_keygen"));

						keyFile   = iDocNo+"_"+itemId;
						keyFile += "_999999";
						keyFile += "_99";
			
						//======================== print file line 1 ================================//
						%>
						  <tr bgcolor="<%=bgColor%>">
							<td class="item" height="22" width="10%"><nobr>รายการที่ <%=line%> : </nobr></td>						
						<%

						String[] keyword1 = new String[]{"before","process","after"};						
						String[] label1 = new String[]{"ก่อนซ่อม 1","ระหว่างซ่อม 1","หลังซ่อม 1"};		
						String[] keyword2 = new String[]{"before2","process2","after2"};						
						String[] label2 = new String[]{"ก่อนซ่อม 2","ระหว่างซ่อม 2","หลังซ่อม 2"};		
						
					for (int j=0;j<keyword1.length;j++) {
								fileName = doString.checkString((String) session.getAttribute("session_upload_"+keyword1[j]+"_"+keyFile),"");  
								realName = doString.checkString((String) session.getAttribute("session_realfile_"+keyword1[j]+"_"+keyFile),"");  

								file = new File(realPath,fileName);

								if (fileName.length()>0 && file.exists()) {

									if (delFile.equals(keyword1[j]+"_"+keyFile)) {
										file.delete();
										haveFile = false;
										session.removeAttribute("session_upload_"+keyword1[j]+"_"+keyFile);
										session.removeAttribute("session_realfile_"+keyword1[j]+"_"+keyFile);
										//System.out.println("DELETE [OK...]");	
									} else {
										haveFile = true;
									}
								} else {
									haveFile = false;
									session.removeAttribute("session_upload_"+keyword1[j]+"_"+keyFile);
									session.removeAttribute("session_realfile_"+keyword1[j]+"_"+keyFile);									
								}

								%>
									<td height="22" width="10%"><nobr><%=label1[j]%> : </nobr></td>
									<td height="22" width="20%">
									<%
										if (haveFile) {
											String urlImg =  request.getContextPath()+"/pictures/temp/"+uploadId+"/"+fileName;
											%>
											<input type="hidden" name="havefile<%=line%>_<%=keyword1[j]%>" value="Y">
											<a href="<%=urlImg%>" target="_blank"><img src="<%=urlImg%>" width="25" height="20" border="0"></a> &nbsp; &nbsp; 
											<input type="button" class="box" value="Delete" onclick="delFile('<%=keyword1[j]+"_"+keyFile%>');" style="background-color:#eeeeee">
											<%
										} else {
											%>ไม่มีภาพถ่าย &nbsp; <%
										}				
									%>					
									</td>								
								<%
						} // end for


						%>
								<td class="dotline01" height="22" width="10%" rowspan="2"><input type="button" class="box" value="แนบไฟล์ <%=line%>" onclick="openUploadWin('<%=keyFile%>');" style="background-color:#eeeeee; "> &nbsp;</td>
						  </tr>
						<%
						//======================== print file line 2 ================================//
						%>
						  <tr bgcolor="<%=bgColor%>">
							<td class="item ; dotline01" height="22" width="10%">&nbsp;</td>						
						<%
							for (int j=0;j<keyword2.length;j++) {
								fileName = doString.checkString((String) session.getAttribute("session_upload_"+keyword2[j]+"_"+keyFile),"");  
								realName = doString.checkString((String) session.getAttribute("session_realfile_"+keyword2[j]+"_"+keyFile),"");  	
								file = new File(realPath,fileName);

								if (fileName.length()>0 && file.exists()) {
									if (delFile.equals(keyword2[j]+"_"+keyFile)) {
										file.delete();
										haveFile = false;
										session.removeAttribute("session_upload_"+keyword2[j]+"_"+keyFile);
										session.removeAttribute("session_realfile_"+keyword2[j]+"_"+keyFile);	
										//System.out.println("DELETE [OK...]");										
									} else {
										haveFile = true;
									}
								} else {
									haveFile = false;
									session.removeAttribute("session_upload_"+keyword2[j]+"_"+keyFile);
									session.removeAttribute("session_realfile_"+keyword2[j]+"_"+keyFile);									
								}

								%>
									<td class="dotline01" height="22" width="10%"><nobr><%=label2[j]%> : </nobr></td>
									<td class="dotline01" height="22" width="20%">
									<%
										if (haveFile) {
											String urlImg =  request.getContextPath()+"/pictures/temp/"+uploadId+"/"+fileName;
											%>
											<input type="hidden" name="havefile<%=line%>_<%=keyword2[j]%>" value="Y">
											<a href="<%=urlImg%>" target="_blank"><img src="<%=urlImg%>" width="25" height="20" border="0"></a> &nbsp; &nbsp; 
											<input type="button" class="box" value="Delete" onclick="delFile('<%=keyword2[j]+"_"+keyFile%>');" style="background-color:#eeeeee">
											<%
										} else {
											%>ไม่มีภาพถ่าย &nbsp; <%
										}				
									%>					
									</td>								
								<%

						} // end for
				 } // end for


				while (line<Constants.SERV_STAFFCONF_LINE) {
					line++;
						%>
						  <tr>
							<td class="item ; dotline01" height="22" width="10%">&nbsp;</td>
							<td class="dotline01" height="22" width="10%">&nbsp;</td>
							<td class="dotline01" height="22" width="20%">&nbsp;</td>
							<td class="dotline01" height="22" width="10%">&nbsp;</td>
							<td class="dotline01" height="22" width="20%">&nbsp;</td>
							<td class="dotline01" height="22" width="10%">&nbsp;</td>
							<td class="dotline01" height="22" width="20%">&nbsp;</td>
							<td class="item ; dotline01" height="22" width="10%">&nbsp;</td>
						  </tr>
						<%
				  } // end while
			   %>


			</table>

	</td></tr></table>

			<table border="0" width="100%" cellspacing="0" cellpadding="0">
			  <tr>
			    <td width="5" valign="bottom"><img src="images/Corn03.gif" width="5" height="5"></td>
			    <td class="frmBottom">&nbsp;</td>
			    <td width="5" valign="bottom" align="right"><img src="images/Corn04.gif" width="5" height="5"></td>
			  </tr>
			</table>
<%-- ===================================  Attach File ================================================ --%>




<br style="font-size:5pt">

        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">

            <a href="#" onclick="doSubmit();"><img border="0" src="images/act_submit.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>

            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:history.back();" target="_self" ><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>  
        </table>  

          </td>
        </tr>
      </table>
			
			

<br style="font-size:30pt">

<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
  <tr><td width="100%" class="copyright" align="center">
  Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5  
  <br>ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;
  หรือ โทร. 0-2230-8279 (คุณประพัฒน์
  ฝ่ายบริการ)&nbsp; 0-2230-8491-5 (ฝ่าย IT)  
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE> 
	
</FORM>	
	
</BODY>

</HTML>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_CompTask_UploadImg.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (stmt != null) stmt.close();
			
			if (rs2 != null) rs2.close();
			if (stmt2 != null) stmt2.close();
			
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>