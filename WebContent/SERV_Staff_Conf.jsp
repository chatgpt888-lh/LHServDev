<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="java.text.*" %>
<%@page import="java.io.*" %>
<%@page import="serv.common.*" %>
<%@page import="org.apache.commons.io.FileUtils" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
 
<%!
/**
 * Modify by : pradoem@lh.co.th
 * date : 2015.04.28
 * version 1.1  
 * desc: 
 */
 
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
public void GenerateKeyGenForPayment(Connection conn,String iDocNo){
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
				sql2.append(" UPDATE lan:serv_payment ")
					.append(" SET i_seq = ? , i_keygen = ?  ")
					.append(" WHERE i_docno = ? AND i_itmjob=?  AND i_vendor = ?   AND i_itmjob_area = ?  AND rowid= ? ");	
	      		//---------------------------

            stmt = conn.createStatement();
  			sql.delete(0, sql.length());
			sql.append(" Select count(*) as cnt  ")
				.append(" From lan:serv_payment")
				.append(" Where i_docno  = '"+iDocNo+"' AND i_keygen  is not null  AND i_keygen <> '' "); 
				//System.out.println("SQL  :"+sql.toString());
				rs = stmt.executeQuery(sql.toString());    				   
			    if(rs.next()){
			       cnt  = rs.getInt("cnt");
			    } 					  
                rs.close();
                int ROW_ID = 0;
                if(cnt==0){
				     //Gen KeyGen && Insert into docdt
				     sql.delete(0, sql.length());
					 sql.append(" Select *,rowid ")
						.append(" From lan:serv_payment")
						.append(" Where i_docno  = '"+iDocNo+"'  order by i_itmjob  "); 
				     rs = stmt.executeQuery(sql.toString());
				     int i = 1;    				   
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
    String pathPdfUrl = hostName+"/AppServ/uploads/";
    //String pathUrlX = hostName+"/AppServ/uploads/";
    
   doString str = new doString(); 
//System.out.println("******************xxxxxxxxxx*************************");
//String p2 = "";
//for(Enumeration e = session.getAttributeNames();e.hasMoreElements();){
//	p2 = (String)e.nextElement();
//	System.out.println(p2 + " = "+session.getAttribute(p2));
//}
//System.out.println("*****************xxxxxxxxxx**************************");

   //----============ Declare Variables for input data ===========----//
   String toDate = getDateFromCalendar(Calendar.getInstance())+"&nbsp;"+getTimeFromCalendar(Calendar.getInstance());
//   String mode = doString.checkString(request.getParameter("mode"),"add");
   String load = doString.checkString(request.getParameter("load"),"");
   String deleteJob = doString.checkString(request.getParameter("delete_job"),"");
   String iDocNo = doString.checkString(request.getParameter("i_docno"),"");
   String iVendor = doString.checkString(request.getParameter("i_vendor"),"");

   //-----========= Declare Variables for Search Custoemr ===========----//
   String selProj = doString.checkString(request.getParameter("sel_project"),"");
   String houseId = doString.checkString(request.getParameter("house_id"),"");
   String iLock = doString.checkString(request.getParameter("i_lock"),"").toUpperCase();
   String nCustomer = doString.checkString(request.getParameter("n_customer"),"");
   String nCustTel = doString.checkString(request.getParameter("n_cust_tel"),"");
   String dAppoint = doString.checkString(request.getParameter("d_appoint"),"");
   String dEstClose = doString.checkString(request.getParameter("d_est_close"),"");
   String inFormEmp = "";
   String inFormDate = "";
   String projDesc = "";

   String cDesc = "";
   String housePlan = "-";
   String custName = "-";
   String custTel = "-";
   String guranteeDesc = "-";
   String guranteeDate = "-";
   String iCustomer = "";
   String comId = "";
   String projId = "";
   String iCompany = "";
   String iProject = "";
   String iDocType = "";
   String vendorName = "";
   String rejectStatus = "";
   String rejectComment = "";
   String rejectEmploy = "";
   String rejectDate = "";
   String responseEmp = "";

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

		//-------------- check upload file --------------//
		String uploadId = doString.checkString((String) session.getAttribute("session_upload_id"),user.getsessionId());
		if (uploadId.trim().length()<=0) {
			 uploadId = user.getsessionId();
			 session.setAttribute("session_upload_id",uploadId);
		}
		
		//String realPath = getServletContext().getRealPath("/pictures/temp/")+File.separator+uploadId;
		//String docPath = getServletContext().getRealPath("/pictures/")+File.separator+iDocNo;
		//String delFile = doString.checkString(request.getParameter("del"),"");

       //----=========================== load Openjob Data ===========================------//
	   if (iDocNo.length()>0 && iVendor.length()>0) {
			
			 //Update by pradoem 2015.04.28
			 GenerateKeyGenForPayment(conn,iDocNo);

	        //----======================== Find DocHD Data =============================----//
			 Hashtable tmpHeader = common.getDocHeaderDetails(iDocNo);
		     inFormEmp = doString.checkString((String) tmpHeader.get("inform_emp"),"");
	         projDesc = doString.DisplayThai(doString.checkString((String) tmpHeader.get("proj_desc"),""));
	         iCompany = doString.checkString((String) tmpHeader.get("i_company"),"");
	         iProject = doString.checkString((String) tmpHeader.get("i_project"),"");
	         iDocType = doString.checkString((String) tmpHeader.get("i_doc_type"),"");
	         selProj = iCompany+":"+iProject;
	         nCustomer = doString.checkString((String) tmpHeader.get("n_customer"),"");
	         nCustTel = doString.checkString((String) tmpHeader.get("n_cust_tel"),"");
	         iLock = doString.checkString((String) tmpHeader.get("i_lock"),"");
	         cDesc = doString.DisplayThai(doString.checkString((String) tmpHeader.get("c_desc"),""));
	         cDesc = str.replace(cDesc,"|break|","<br>");
	         cDesc = str.replace(cDesc," ","&nbsp;");
			 inFormDate = doString.checkString((String) tmpHeader.get("inform_date"),"");
 		    dAppoint = doString.checkString((String) tmpHeader.get("d_appoint"),"");
			dEstClose = doString.checkString((String) tmpHeader.get("d_est_close"),"");
			responseEmp = doString.checkString((String) tmpHeader.get("response_emp"),"");


			Vector checkSess = (Vector) session.getAttribute(ItmJobManagement.SESSION_JOBLIST);
			if (iDocType.equalsIgnoreCase("J") && (checkSess==null || (checkSess.size()==0 && load.equalsIgnoreCase("YES")))) {
			    //----========== Find SERV_DOCDT for this HD =========-----//
			    ItmJobManagement itm = new ItmJobManagement(request,response);
                Random rand = new Random();

				sql.delete(0,sql.length());
				sql.append(" select a.*,b.n_itmjob,b.z_wage_unit o_wage,b.z_good_unit o_goods , ")
					  .append(" f.b_name , f.b_file_name , f.b_name2 , f.b_file_name2 ,  ")
					  .append(" f.p_name1 , f.p_file_name1 , f.p_name2 , f.p_file_name2 ,  ")
					  .append(" f.a_name , f.a_file_name , f.a_name2 , f.a_file_name2  ")
					  .append(" from lan:serv_payment a  ")
				      .append(" left join lan:serv_boq b on b.i_itmjob=a.i_itmjob ")
				      .append(" left join lan:serv_docatt f on f.i_docno=a.i_docno and f.i_seq=a.i_seq and f.i_itmjob=a.i_itmjob ")
			  	      .append(" and f.i_vendor=a.i_vendor and f.i_itmjob_area=a.i_itmjob_area")
				      .append(" where a.i_docno='").append(iDocNo).append("' ")
				      .append(" and a.i_vendor='").append(iVendor).append("' ")
				      .append(" and a.f_itmstatus='500' ")
				      .append(" order by i_seq ");// --order by i_seq ,i_itmjob

				String id = "";
				//String seq = "";
				String nItmJob = "";
				String itemKey = "";
				int seq = 1; 
				
				rs = stmt.executeQuery(sql.toString());
				while (rs.next()) {
					   Hashtable docdt = new Hashtable();
					   id = doString.checkString(rs.getString("i_itmjob"),"");
					   //seq = doString.checkString(rs.getString("i_seq"),"");
					   nItmJob = doString.checkString(rs.getString("n_itmjob"),"");

						//modify by pradoem 2015.04.28
						if(!doString.checkString(rs.getString("i_keygen"),"").equals("")){						
						//if (load.equalsIgnoreCase("YES")) {	
							itemKey = doString.checkString(rs.getString("i_keygen"),"");
						}else{
						   itemKey = id+"_";
						   while (itemKey.length()<20) {
								itemKey += rand.nextInt(10); 
						   }
						}
						
					   itm.getJobList().addElement(itemKey);
					   itm.getItmJobList().put(itemKey,id);
					   itm.getItmSeqList().put(itemKey,doString.checkString(rs.getString("i_seq"),""));
					   itm.getVendorList().put(itemKey,doString.checkString(rs.getString("i_vendor"),""));
					   itm.getWageList().put(itemKey,doString.checkString(Double.toString(rs.getDouble("z_wage_price")),""));
					   itm.getCustomWageList().put(itemKey,doString.checkString(Double.toString(rs.getDouble("q_wage_unit")),""));
					   itm.getGoodsList().put(itemKey,doString.checkString(Double.toString(rs.getDouble("z_good_price")),""));
					   itm.getCustomGoodsList().put(itemKey,doString.checkString(Double.toString(rs.getDouble("q_good_unit")),""));
					   itm.getBOQList().put(itemKey,nItmJob+":"+Double.toString(rs.getDouble("o_wage"))+":"+Double.toString(rs.getDouble("o_goods")));
					   itm.getCommentList().put(itemKey,doString.checkString(rs.getString("c_itmjob"),""));
					   itm.getAreaList().put(itemKey,doString.checkString(rs.getString("i_itmjob_area"),""));
					   itm.getFContractList().put(itemKey,doString.checkString(rs.getString("f_contr"),""));

				      //========================================for Edit=================================================================
						//------------- get file attach ----------//
						if (load.equalsIgnoreCase("YES")) {	
						}//#YES
						//========================================for Edit=================================================================	
						 seq++;
				} // end while
				rs.close();
				itm.updateItemSession();
			} // end if check session


			//----=================== Get Vendor Name & Reject Comment ========================----//
			sql.delete(0,sql.length());
			sql.append(" select trim(d.n_prename_th)||trim(d.n_nemploy_th)||' '||trim(d.n_semploy_th) n_app, ")
			      .append(" b.bus_name,a.* from lan:serv_flow a ")
			      .append(" left join lan:stpvendr b on b.vend_code=a.i_vendor ")
			      .append(" left join lan:useracl c on c.user_id=a.i_approve and c.user_acl='S' ")
			      .append(" left join docflow:acemploy d on d.i_employ=c.i_employ where ")
			      .append(" a.i_docno='").append(iDocNo).append("' ")
			      .append(" and a.i_vendor='").append(iVendor).append("' ")
			     .append(" order by a.f_itmstatus desc ");
			rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
		        vendorName = doString.DisplayThai(doString.checkString(rs.getString("bus_name"),""));
			    rejectStatus = doString.checkString(rs.getString("f_reject"),"");
			    rejectComment = doString.DisplayThai(doString.checkString(rs.getString("c_reject"),""));
	            rejectComment = str.replace(rejectComment,"|break|","<br>");
	            rejectComment = str.replace(rejectComment," ","&nbsp;");
	            rejectEmploy = doString.checkString(rs.getString("n_app"),"");

				 Timestamp tmp = rs.getTimestamp("d_approve");
				 if (tmp!=null) {
				     Calendar cal = Calendar.getInstance();
				 	 cal.setTime(tmp);
				     rejectDate = getDateFromCalendar(cal)+" "+getTimeFromCalendar(cal);
			     }
			} // end while
			rs.close();
			//----===========================================================================----//
		}
		//-----===================================================================----//

		//----======================= Get Customer Details ===========================----//
		if (selProj.indexOf(":")>0) {
		   iCompany = selProj.substring(0,selProj.indexOf(":"));
		   iProject = selProj.substring(selProj.indexOf(":")+1);
		}
		Hashtable tmpCust = common.getCustomerDetails(iCompany,iProject,iLock);
	    housePlan = doString.checkString((String) tmpCust.get("i_model"),"");
	    houseId = doString.checkString((String) tmpCust.get("i_house"),"");
	    iLock = doString.checkString((String) tmpCust.get("i_lock"),"");
	    iCustomer = doString.checkString((String) tmpCust.get("i_customer"),"");
		guranteeDesc = doString.checkString((String) tmpCust.get("gurantee_desc"),"");
		guranteeDate = doString.checkString((String) tmpCust.get("gurantee_date"),"");
		custName = doString.checkString((String) tmpCust.get("n_customer"),"");
		custTel = doString.checkString((String) tmpCust.get("n_cust_tel"),"");

       //---================ Add , Update , Delete Item List before get to use ===============----//
       ItmJobManagement itm = new ItmJobManagement(request,response);
       itm.updateItemSession(); // update session before use

       //---======== Get Item Details for show ===========---//
       Vector jobList = itm.getJobList();
       Hashtable jobItm = itm.getItmJobList();
       Hashtable seqItm = itm.getItmSeqList();
       Hashtable jobVendor = itm.getVendorList();
       Hashtable jobWage = itm.getWageList();
       Hashtable jobCustomWage = itm.getCustomWageList();
       Hashtable jobGoods = itm.getGoodsList();
       Hashtable jobCustomGoods = itm.getCustomGoodsList();
       Hashtable jobBOQ = itm.getBOQList();
       Hashtable jobComment = itm.getCommentList();
       Hashtable jobArea = itm.getAreaList();
       Hashtable fContract = itm.getFContractList();
      //---=========================================================================----//
%>

<HTML>
<HEAD>
<TITLE>Service Staff Confirm</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<!--   for upload -->
<script language="javascript" src="resources/js/upload.js"></script>
<!-- use openUploadWindow(contextPath,sessionId) method --->

<script language="javascript" src="jquery/jquery-1.11.3.min.js"></script>

<!-- loading onverlay by pradoem 2023.02 -->
<script src="jquery3/jquery.min3.6.3.js" ></script>
<script src="jquery3/loadingoverlay.min2.1.7.js"></script>


<script language="javascript">
<!--

  /* function openUploadWin(keyFile) {	
  	   var result = openUploadWindow('<%=request.getContextPath()%>','<%=uploadId%>',keyFile);
	   if (result=="OK") {
			document.forms[0].action='SERV_Staff_Conf.jsp';
			document.forms[0].submit();
	   }
   }

	function delFile(id) {
		if (confirm("คุณแน่ใจว่าต้องการลบไฟล์แนบนี้ ?")) {
			document.forms[0].action='SERV_Staff_Conf.jsp?del='+id;
			document.forms[0].submit();
		}
	}*/
	
	
	  var windowObjectReference = null;
  function openUploadWindow2(mm,yyyy,docIdx) {
	/*if (contextPath.length>0 && contextPath.substring(contextPath.length-1)!="/") 	{
	    contextPath += "/";
	}*/
    var vReturnValue = window.open("<%=hostName%>/AppServ/upload_file_main.jsp?mm="+mm+"&yyyy="+yyyy+"&docIdx="+docIdx,"","Left=100,Top=100,width=500,height=250; center: Yes; resizable: No; status: No;");
	//var vReturnValue = window.open(contextPath+"upload2_main.jsp?session_id="+uploadId+"&key_file="+keyFile,"","Left=100,Top=100,width=400,height=380; center: Yes; resizable: No; status: No;");
	//console.log("vReturnValue=",vReturnValue);
	return vReturnValue;
 }
  
 function  refresh() {
  	  onPleaseWait();
  	  document.forms[0].now_page.value=page;
	  doSubmitForm("<%=request.getContextPath()%>/SERV_Staff_Conf.jsp?sel_project=<%=selProj%>");	
 }
		
  var hostNameX = "<%=Utilizer.getPropValue("DOMAIN_NAME")%>";
  function attachFiles(mm,yyyy,docIdx){
    	if(windowObjectReference == null || windowObjectReference.closed){
  	   		  windowObjectReference = openUploadWindow2(mm,yyyy,docIdx);   
  	    }else{
  	   		windowObjectReference.focus();
  	    }
  	    //Create IE + others compatible event handler
		var eventMethod = window.addEventListener ? "addEventListener" : "attachEvent";
		var eventer = window[eventMethod];
		var messageEvent = eventMethod == "attachEvent" ? "onmessage" : "message";

		// Listen to message from child window
		 eventer(messageEvent,function(e) {
			 //console.log('origin: ', e.origin)

			 if(e.origin == hostNameX 
				  ||e.origin == 'http://132.146.1.180:8080' 
				  ||e.origin == 'http://localhost:9080' ||  e.origin == 'http://132.146.1.92' || e.origin == 'http://132.146.1.126' || e.origin == 'https://portal.lh.co.th' ){

				  console.log('popup message!: ', e.data);
				  //attachFileCallback(e.data);
			      if (e.data==="OK") {
						document.forms[0].action='SERV_Staff_Conf.jsp?sel_project=<%=selProj%>';
						document.forms[0].submit();
			      }	      
			  }
		}, false);
   }
   
      function delFile(docId,mm,yyyy,fileId) {
		if(confirm("คุณแน่ใจว่าต้องการลบไฟล์แนบนี้ ?")) {
		 var param = "docId="+docId+"&mm="+mm+"&yyyy="+yyyy+"&fileId="+fileId;
		 //alert(param);
		 $.ajax({
	        crossDomain: true,
	       /* crossorigin : anonymous,*/
		    type: "POST",	
			url: "<%=hostName%>/AppServ/DeleteFileById",
			data: param,
			success: function(data){
				//alert(data); //"A:11111:ทดสอบ"  "E:x:x"   				
				if(data==null || data==""){
					return;
				}  				
				var temp = data.split(":");
				document.forms[0].action='SERV_Staff_Conf.jsp?sel_project=<%=selProj%>';
				document.forms[0].submit();
		    }
		  });
		}
	}


  function checkVendorType(obj) {
       id = obj.name.substring(0,obj.name.indexOf("_vendor_cut"));
       //var p = document.forms[0].elements(id+"_percent_cut");
       //if (obj.value=="999999") {  
       if($('input[name='+id+'_percent_cut]').val()=='999999'){
          //if (p!=null){ p.disabled = true;}
          $('input[name='+id+'_percent_cut]').prop("disabled","true"); //attr
       } else {
          //if (p!=null){ p.disabled = false;}
          $('input[name='+id+'_percent_cut]').prop("disabled","false");
       }
  }

  function validateFormXX(id) {
     var vendor = document.forms[0].elements(id+"_vendor_cut");
     var percent = document.forms[0].elements(id+"_percent_cut");
     var wrongtype = document.forms[0].elements(id+"_wrong_type");
     var fContr = document.forms[0].elements(id+"_f_contract");

     if (vendor.value=="") {
        alert(" กรุณาเลือกผู้รับเหมาที่ต้องการตัดเงิน !");
        vendor.focus();
        return false;
     } else if (vendor.value!="999999") {
	     if (percent.value=="") {
	        alert(" กรุณาเลือก % การตัดเงิน !");
	        percent.focus();
	        return false;
	     }
     }
     if (wrongtype!=null && wrongtype.value=="") {
         alert(" กรุณาเลือกสาเหตุ ! ");
	     wrongtype.focus();
	     return false;
     }
     if (fContr!=null && fContr.value=="") {
         alert(" กรุณาเลือกประเภทการตัด ! ");
	     fContr.focus();
	     return false;
     }
     return true;
  }
  
  function validateForm55(paramName) {
	/* For Drop down List get Value */
	if($('select[name='+paramName+'_vendor_cut] option:selected').val()==''){
		 alert(" กรุณาเลือกผู้รับเหมาที่ต้องการตัดเงิน !");
		 $('select[name='+paramName+'_vendor_cut]').focus();
		 return false;
	}else if($('select[name='+paramName+'_vendor_cut] option:selected').val()!='999999'){
		if($('select[name='+paramName+'_percent_cut] option:selected').val()==''){
			alert(" กรุณาเลือก % การตัดเงิน !");
			$('select[name='+paramName+'_percent_cut]').focus();
			return false;
		}
	}	    
    if($('select[name='+paramName+'_wrong_type] option:selected').val()==''){
         alert(" กรุณาเลือกสาเหตุ ! ");
		 $('select[name='+paramName+'_wrong_type]').focus();
		 return false;
    }  
    if($('select[name='+paramName+'_f_contract] option:selected').val()==''){
         alert(" กรุณาเลือกประเภทการตัด ! ");
		 $('select[name='+paramName+'_f_contract]').focus();
		 return false;
    }
     return true;
  }

  function reject_job() {
      if (confirm("คุณแน่ใจว่าต้องการ Reject ใบงานนี้ ?")) {
          if (document.forms[0].i_comment.value=="") {
             alert(" กรุณากรอกหมายเหตุ เกี่ยวกับการ Reject !");
             document.forms[0].i_comment.focus();
             return false;
          } else {
             pleaseWaiting();
             document.forms[0].mode.value="REJECT";
             document.forms[0].action="<%=Constants.APP_PATH%>/SERV_StaffConfServlet";
             document.forms[0].submit();
          }
      }
  }
  
  
 function doSubmitForm(url){
    //alert("submit");
    pleaseWaiting();
 	$('form').attr('action', url);
	$("form:first").submit();
 }
 
  function approve_job() {
     /*Checkbox:text .length  :check select items_job*/
    if($("input[name='key_itmjob']").length==0){
	   alert("คุณต้องทำการเพิ่มรายการซ่อม อย่างน้อย 1 รายการ !"); 
       return false; 
    } else {
       /* type : Check box|| validate items_job*/
	   var result = false;
	   $.each($("input[name='key_itmjob']"), function(){    	   	       
	      result = validateForm55($(this).val());
	    });
	    if(result==false){
	    	return false;
	    }
    }
    $('input[name="mode"]').val('APPROVE');
    doSubmitForm("<%=Constants.APP_PATH%>/SERV_StaffConfServlet");
  }
  
  function approve_jobXX() {
     var item = document.forms[0].key_itmjob;
     if (item==null) {
        alert("คุณต้องมีรายการซ่อม อย่างน้อย 1 รายการ !");
        return false;
     } else {
        if (item.length!=null) {
            for (var i=0;i<item.length;i++) {
                  var id = item[i].value;
                  var result = validateForm(id);
                  if (!result) return false;
            }
        } else {
           var id = item.value;
           var result = validateForm(id);
           if (!result) return false;
        }
     } // end if check item

/*
	 var total = document.forms[0].total_item;
	 if (total!=null) {
		 for (var i=1;i<=total.value;i++) {
				 if (document.forms[0].elements("havefile"+i+"_before")==null && document.forms[0].elements("havefile"+i+"_before2")==null) {
					 alert(" กรุณาแนบรูปก่อนซ่อมในรายการที่ "+i+" อย่างน้อย 1 รูป !!");
					 return false;
				 }

				 if (document.forms[0].elements("havefile"+i+"_after")==null && document.forms[0].elements("havefile"+i+"_after2")==null) {
					 alert(" กรุณาแนบรูปหลังซ่อมในรายการที่ "+i+" อย่างน้อย 1 รูป !!");
					 return false;
				 }
		 } // end for
	 }
*/
     pleaseWaiting();
     document.forms[0].mode.value="APPROVE";
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_StaffConfServlet";
     document.forms[0].submit();
  }
  
  
  function pleaseWaiting(){
   $.LoadingOverlay("show");
	// Hide it after 3 seconds
	setTimeout(function(){
	    $.LoadingOverlay("hide");
	}, 7000);
  }

//-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">

<input type='hidden' name='i_docno' value='<%=iDocNo%>'>
<input type='hidden' name='i_vendor' value='<%=iVendor%>'>
<input type="hidden" name="mode" value="">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            Staff List : เจ้าหน้าที่บริการ</td>
          <td width="50%" align="right">&nbsp;
          <!--<a href="#" onclick="viewInform();"><img border="0" src="images/icon_view_IFJ.gif" width="120" height="34"></a>-->
          </td>
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
    <td height="22" width="39%" class="dotline01"><%=projDesc%>
    <input type='hidden' name='sel_project' value='<%=selProj%>'>
    </td>
    <td height="22" class="item ; dotline01" width="14%">เลขที่ใบแจ้งซ่อม :</td>
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
    <td class="item ; dotline01" height="22" width="13%">ชื่อผู้แจ้ง/ลูกค้า :</td>
    <td height="22" width="39%" class="dotline01">
    <%=doString.DisplayThai(common.joinContactAndOwner(nCustomer,custName))%>
    </td>
    <td height="22" class="item ; dotline01" width="14%">โทรศัพท์ติดต่อ :</td>
    <td height="22" width="34%" class="dotline01">
    <%=doString.DisplayThai(common.joinContactAndOwner(nCustTel,custTel))%>
    </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ผู้รับเรื่อง :</td>
    <td height="22" width="39%" class="dotline01"><%=doString.DisplayThai(inFormEmp)%></td>
    <td height="22" class="item ; dotline01" width="14%">วันเวลาที่แจ้ง :</td>
    <td height="22" width="34%" class="dotline01"><%=inFormDate%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">วันที่นัดซ่อม :</td>
    <td height="22" width="39%" class="dotline01"><%=dAppoint%></td>
    <td height="22" class="item ; dotline01" width="14%">วันที่ประมาณการเสร็จ :</td>
    <td height="22" width="34%" class="dotline01"><%=dEstClose%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ผู้รับเหมาซ่อม :</td>
    <td height="22" width="39%" class="dotline01"><%=vendorName%></td>
    <td height="22" class="item ; dotline01" width="14%">ผู้รับเหมาสร้าง :</td>
    <td height="22" width="34%" class="dotline01"><%=doString.DisplayThai(responseEmp)%></td>
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
          <td rowspan="2" class="col_name" width="3%">No.</td>
          <td rowspan="2" class="col_name" width="19%">รายละเอียดการซ่อม</td>
          <td class="col_name" width="5%" rowspan="2">หน่วยนับ</td>
          <td colspan="3" class="col_name" width="8%">ค่าแรง</td>
          <td colspan="3" class="col_name" width="8%">ค่าของ</td>
          <td rowspan="2" class="col_name" width="8%">รวมเงิน</td>
          <td rowspan="2" class="col_name" width="17%">ตัดเงิน</td>
          <td rowspan="2" class="col_name" width="6%">%</td>
          <td rowspan="2" class="col_name" width="4%">สาเหตุ</td>
          <td rowspan="2" class="col_name" width="6%">ประเภทการตัด</td>
        </tr>
        <tr>
          <td class="col_nameLow" width="6%">ต่อหน่วย</td>
          <td class="col_nameLow" width="5%">จำนวน</td>
          <td class="col_nameLow" width="8%">รวม</td>
          <td class="col_nameLow" width="6%">ต่อหน่วย</td>
          <td class="col_nameLow" width="5%">จำนวน</td>
          <td class="col_nameLow" width="8%">รวม</td>
        </tr>

        <%
        int line = 0;
        DecimalFormat format = new DecimalFormat("#,##0.00");
        double grandTotalWage = 0.00;
        double grandTotalGoods = 0.00;
        double grandTotal = 0.00;


		String key = "";
		String id = "";
		String seq = "";
		String vendor = "";
		String BOQDesc = "";
		double wageUnit = 0.0;
		double goodsUnit = 0.0;
		String fcontract = "";
		String vendorCut = "";
		String percentCut = "";
		String wrongType = "";
		String itmDesc = "";
		String itmCountUnit = "";
		double wagePrice = 0.00;
		double customWagePrice = 0.00;
		double goodsPrice = 0.00;
		double customGoodsPrice = 0.00;
		double totalWage = 0.00;
		double totalGoods = 0.00;
		double subTotal = 0.00;
		double checkPriceW = 0, checkPriceG = 0;

		String remarkDiff = "";
		double checkWage = 0.0;
		double checkGoods = 0.0;
		boolean foundNoChange = false;

		StringTokenizer boq = null;


        for (int i=0;i<jobList.size();i++) {
                line++;
                key = (String) jobList.elementAt(i);
                id = doString.checkString((String) jobItm.get(key),"");
                seq = doString.checkString((String) seqItm.get(key),"");
                vendor = doString.checkString((String) jobVendor.get(key),"");
                BOQDesc = doString.checkString((String) jobBOQ.get(key),"");
                wageUnit = Double.parseDouble(doString.checkString((String) jobWage.get(key),"0.0"));
                goodsUnit = Double.parseDouble(doString.checkString((String) jobGoods.get(key),"0.0"));
                fcontract = doString.checkString((String) fContract.get(key),"");


                vendorCut = "";
                percentCut = "";
                wrongType = "";

                itmDesc = "";
                itmCountUnit = "";
                wagePrice = 0.00;
                customWagePrice = 0.00;
                goodsPrice = 0.00;
                customGoodsPrice = 0.00;
                totalWage = 0.00;
                totalGoods = 0.00;
                subTotal = 0.00;

                boq = new StringTokenizer(BOQDesc,":");
	            sql.delete(0,sql.length());
	            sql.append(" select * from lan:serv_boq where i_itmjob='").append(id).append("' ");
	            rs = stmt.executeQuery(sql.toString());
	            if (rs.next()) {
	                itmDesc = doString.checkString(rs.getString("n_itmjob"),"");
	                itmCountUnit = doString.checkString(rs.getString("n_count"),"");

	                if (boq.countTokens()==3) {
	                    //---===== Get data from session ======---//
	                    itmDesc = boq.nextToken();
		                wagePrice = Double.parseDouble(boq.nextToken());
		                goodsPrice = Double.parseDouble(boq.nextToken());

		                customWagePrice = Double.parseDouble(doString.checkString((String) jobCustomWage.get(key),"0.00"));
		                customGoodsPrice = Double.parseDouble(doString.checkString((String) jobCustomGoods.get(key),"0.00"));

	                } else {
	                   //---====== Load from SERV_BOQ ======--//
		                wagePrice = rs.getDouble("z_wage_unit");
		                goodsPrice = rs.getDouble("z_good_unit");
		                customWagePrice = wagePrice;
		                customGoodsPrice = goodsPrice;

		                jobBOQ.put(id,itmDesc+":"+Double.toString(wagePrice)+":"+Double.toString(goodsPrice));
		                jobComment.put(key,itmDesc);
		                jobCustomWage.put(key,Double.toString(customWagePrice));
		                jobCustomGoods.put(key,Double.toString(customGoodsPrice));
		                session.setAttribute(ItmJobManagement.SESSION_BOQ,jobBOQ);
		                session.setAttribute(ItmJobManagement.SESSION_CUSTOM_WAGE,jobCustomWage);
		                session.setAttribute(ItmJobManagement.SESSION_CUSTOM_GOODS,jobCustomGoods);
		                session.setAttribute(ItmJobManagement.SESSION_COMMENT,jobComment);
	                } //end if check boq

	                totalWage = customWagePrice * (double) wageUnit;
	                totalGoods = customGoodsPrice * (double) goodsUnit;
	                subTotal = totalWage + totalGoods;

	                grandTotalWage += totalWage;
	                grandTotalGoods += totalGoods;
	                grandTotal += subTotal;

	            }
	            rs.close();


				remarkDiff = "";
				checkWage = 0.0;
				checkGoods = 0.0;
				foundNoChange = false;
	            sql.delete(0,sql.length());
	            sql.append(" select * from lan:serv_docdt where i_itmjob='").append(id).append("' ")
		              .append(" and i_docno='").append(iDocNo).append("' ")
			          .append(" and i_vendor='").append(vendor).append("' ");
	            rs = stmt.executeQuery(sql.toString());
	            while (rs.next()) {
		            checkWage = rs.getDouble("z_wage_price");
		            checkGoods = rs.getDouble("z_good_price");
					checkPriceW = rs.getDouble("q_wage_unit");
					checkPriceG = rs.getDouble("q_good_unit");
					
					if (wageUnit==checkWage && goodsUnit==checkGoods &&
						wagePrice==checkPriceW && goodsPrice==checkPriceG					
					) {
						 foundNoChange = true;
						 break;
					}
	            } // end while
	            rs.close();

				if (!foundNoChange) {
					remarkDiff = "<b style='color:red'>*</b>";
				}

			   Enumeration keys = request.getParameterNames();
				while (keys.hasMoreElements()) {
					String key1 = doString.checkString((String) keys.nextElement(),"");

					if (key1.indexOf("key_line"+line)==0) {
						String realKey = doString.checkString(request.getParameter(key1),"");
						vendorCut = doString.checkString((String) request.getParameter(realKey+"_vendor_cut"),"");
						percentCut =doString.checkString((String) request.getParameter(realKey+"_percent_cut"),"");
						wrongType =doString.checkString((String) request.getParameter(realKey+"_wrong_type"),"");

						if (fcontract.trim().length()<=0) {
							fcontract =doString.checkString((String) request.getParameter(realKey+"_f_contract"),"");
						}
					}
				}

		        %>
		        <tr>
		          <td width="3%" align="center" class="dotline">
		             <%=line%>
		             <input type="hidden" name="key_itmjob" value="<%=key%>">
		             <input type="hidden" name="<%=key%>_i_itmjob" value="<%=id%>">
		             <input type="hidden" name="<%=key%>_seq" value="<%=seq%>">
		             <input type="hidden" name="key_line<%=line%>" value="<%=key%>">
		          </td>
		          <td width="19%" class="dotline"><%=remarkDiff+" "+doString.DisplayThai(itmDesc)%></td>
		          <td width="5%" class="dotline" align="center"><%=doString.DisplayThai(itmCountUnit)%></td>
		          <td width="6%" align="right" class="dotline"><%=format.format(customWagePrice)%></td>
		          <td width="5%" align="center" class="dotline"><input type="hidden" name="<%=key%>_wage" value="<%=wageUnit%>"><%=format.format(wageUnit)%></td>
		          <td width="8%" align="right" class="dotline"><span id="wage_sum_<%=line%>"><%=format.format(totalWage)%></span></td>
		          <td width=6%" align="right" class="dotline"><%=format.format(customGoodsPrice)%></td>
		          <td width="5%" align="center" class="dotline"><input type="hidden" name="<%=key%>_goods"  value="<%=goodsUnit%>"><%=format.format(goodsUnit)%></td>
		          <td width="8%" align="right" class="dotline"><span id="goods_sum_<%=line%>"><%=format.format(totalGoods)%></span></td>
		          <td width="8%" align="right" class="dotline">
		               <span id="sum_total_<%=line%>"><%=format.format(subTotal)%></span>
		               <input type="hidden" name="<%=key%>_sum_total"  value="<%=subTotal%>">
		          </td>
		          <td align="center" class="dotline" width="17%">
				  <%=common.genVendorListForCut(key+"_vendor_cut",selProj,vendorCut," class='box' style='width:100%' onchange='checkVendorType(this);' ")%>
		          </td>
		          <td align="center" class="dotline" width="6%">
		          <%=common.genPercentCutList(key+"_percent_cut",percentCut," class='box' style='width:100%' ")%>
		          </td>
		          <td align="center" class="dotline" width="4%"><SELECT name="<%=key%>_wrong_type" class='box' style='width:65'>
				  <option value=''>- เลือก -</option>
<%
	 String chk_cause = "";
	 String option = "";
	 sql.delete(0, sql.length());
	 sql.append("SELECT i_cause FROM lan:serv_cause ")
		  .append("WHERE i_itmjob = '"+id+"' ");
	 //System.out.println(sql.toString());
	 rs = stmt.executeQuery(sql.toString());
	 if (rs.next() == true) {
			chk_cause = "Y";
	 }


	 if (chk_cause.equals("Y")) {      

			sql.delete(0, sql.length());
		    sql.append("select a.i_code, a.n_desc ")
			   .append("from lan:serv_xstd a, lan:serv_cause b ")
			   .append("where b.i_itmjob = '"+id+"' ") 
			   .append("and a.i_type = '06' ")
			   .append("and a.i_code = b.i_cause ")
			   .append("order by a.i_code ");	
	} else {	
			sql.delete(0, sql.length());
			sql.append("select * from lan:serv_xstd ")
			     .append("where i_type = '06' ")
				 .append("order by i_code ");	
	 }	
		rs = stmt.executeQuery(sql.toString());
		while (rs.next()) {
			option = "";
				if (doString.checkString(rs.getString("i_code")).equals(wrongType)) {
						option = "selected";
				}

%><OPTION value="<%=doString.checkString(rs.getString("i_code"))%>" <%=option%>><%=doString.DisplayThai(doString.checkString(rs.getString("n_desc")))%></OPTION>
<%			
		} // End while
%>
            </SELECT>		         
			      <!---======== Start Check disabled ==========---->
			      <script> 
					  try { 
						checkVendorType(document.forms[0].elements("<%=key%>_vendor_cut")); 
					  } catch (e) { } 
				  </script>
		          </td>
		          <td align="center" class="dotline" width="6%">
						<select name="<%=key%>_f_contract" class='box'>
						     <option value="">--</option>
						     <option value="Y" <%=fcontract.equalsIgnoreCase("Y") ? " selected " : "" %>>Y</option>
						     <option value="N" <%=fcontract.equalsIgnoreCase("N") ? " selected " : "" %>>N</option>
						</select>
		          </td>
		        </tr>
		        <%
        } // end for

        while (line<Constants.SERV_STAFFCONF_LINE) {
            line++;
		        %>
		        <tr>
		          <td align="center" class="dotline" width="3%">&nbsp;</td>
		          <td class="dotline" width="19%">&nbsp;</td>
		          <td align="center" class="dotline" width="5%">&nbsp;</td>
		          <td align="right" class="dotline" width="6%">&nbsp;</td>
		          <td align="center" class="dotline" width="5%">&nbsp;</td>
		          <td align="right" class="dotline" width="8%">&nbsp;</td>
		          <td align="right" class="dotline" width="6%">&nbsp;</td>
		          <td align="center" class="dotline" width="5%">&nbsp;</td>
		          <td align="right" class="dotline" width="8%">&nbsp;</td>
		          <td align="right" class="dotline" width="8%">&nbsp;</td>
		          <td align="center" class="dotline" width="17%">&nbsp;</td>
		          <td align="center" class="dotline" width="6%">&nbsp;</td>
		          <td align="center" class="dotline" width="4%">&nbsp;</td>
		          <td align="center" class="dotline" width="6%">&nbsp;</td>
		        </tr>
				<%
		} // end while
		%>
        <tr>
          <td align="center" class="dotline ; item" width="3%">&nbsp;</td>
          <td class="dotline ; item" align="right" width="19%">รวมเป็นเงิน</td>
          <td align="center" class="dotline ; item" width="5%">&nbsp;</td>
          <td align="right" class="dotline ; item" width="6%">&nbsp;</td>
          <td align="center" class="dotline ; item" width="5%">&nbsp;</td>
          <td align="right" class="dotline ; item" width="8%"><span id="totalWage"><%=format.format(grandTotalWage)%></span></td>
          <td align="right" class="dotline ; item" width="6%">&nbsp;</td>
          <td align="center" class="dotline ; item" width="5%">&nbsp;</td>
          <td align="right" class="dotline ; item" width="8%"><span id="totalGoods"><%=format.format(grandTotalGoods)%></td>
          <td align="right" class="dotline ; item" width="8%"><span id="grandTotal"><%=format.format(grandTotal)%></span></td>
          <td align="center" class="dotline ; item" width="17%">&nbsp;</td>
          <td align="center" class="dotline ; item" width="6%">&nbsp;</td>
          <td align="center" class="dotline ; item" width="4%">&nbsp;</td>
          <td align="center" class="dotline ; item" width="6%">&nbsp;</td>
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
<br style="font-size:4pt">
<table border="0" width="95%" cellspacing="0" cellpadding="0">
  <tr><td>ประเภทการตัด : Y = ตามสัญญา , N = อื่นๆ </td></tr>
</table>


<br style="font-size:10pt">
<br style="font-size:10pt">

<%
   if (jobList.size()>0) {
%>
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดการซ่อม</td>
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
		String itemId = "";
		String comment = "";
		String area = "";
		String areaDesc = "";
        for (int i=0;i<jobList.size();i++) {
                line++;
				itemId = (String) jobList.elementAt(i);
                comment = (String) jobComment.get(itemId);
				area = (String) jobArea.get(itemId);

				areaDesc = "";
				sql.delete(0,sql.length());
				sql.append("select * from lan:serv_xstd where i_type='01' and i_code='").append(area).append("' ");
				rs = stmt.executeQuery(sql.toString());
				while (rs.next()) {
					areaDesc = doString.checkString(rs.getString("n_desc"),"");
				} // end while
				rs.close();

                %>
				  <tr>
				    <td class="item ; dotline01" height="22" width="12%">รายการที่ <%=line%> :</td>
				    <td height="22" width="80%" class="dotline01"><%=doString.DisplayThai(doString.checkString(comment))%></td>
				    <td height="22" width="8%" class="dotline01"><%=doString.DisplayThai(doString.checkString(areaDesc))%></td>
				  </tr>
                <%
         } // end for

        while (line<Constants.SERV_STAFFCONF_LINE) {
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

<%
boolean closeProject = false;
String iCom = "";
String iProj = "";
if (selProj.indexOf(":")>0) {
   iCom = selProj.substring(0,selProj.indexOf(":"));
   iProj = selProj.substring(selProj.indexOf(":")+1);
}
sql.delete(0,sql.length());
sql.append(" select * from lan:serv_clspj where i_type='01'  ")
	  .append(" and i_company='").append(iCom).append("' ")
	  .append(" and i_project='").append(iProj).append("' ");
rs = stmt.executeQuery(sql.toString());
if (rs.next()) {
    closeProject = true;
} else {
	closeProject = false;
} // end if
rs.close();

//out.println(closeProject);
closeProject = true;
if (closeProject) {

		String keyFile = "";
		String yyyyMMdd =  GetDateKeyinYYYYMMDD(conn,iDocNo);
		String []tmp = yyyyMMdd.split("\\-"); //2012-08-15
        String yyyy = tmp[0];
        String month = tmp[1];
        
        String imagesIdUrl = "";
	    //pathPdfUrl += yyyy+"/"+month+"/"+iDocNo+"/";	
	    
		String docPdfPath = "";
		String pdfFileName = "";
		//System.out.println("docPdfPath1="+docPdfPath);
		pdfFileName = "pdf_"+iDocNo+".pdf";
		//System.out.println("pdfFileName="+pdfFileName);							
		docPdfPath = Utilizer.getPropValue("DOMAIN_NAME")+Utilizer.getPropValue("PATH_UPLOAD")+yyyy+"/"+month+"/"+iDocNo+"/"+pdfFileName;
		//System.out.println("docPdfPath2="+docPdfPath);

%>
			<br style="font-size:10pt">

			            <table border="0" width="100%" cellspacing="0" cellpadding="0">
			              <tr>
			                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
			                <td class="item_tab2" width="160">รูปภาพงานซ่อม (ขนาดไม่เกิน 500 K)</td>
			                <td class="item_tab3"></td>
			                <td class="textgray">&nbsp; 
								           &nbsp;
									      <nobr>
											&nbsp;
											<a href="#"><input type="button" name="btnAttach" value="แนบไฟล์ .PDF <%//=iDocNo%>" 
											onclick="attachFiles('<%=month %>','<%=yyyy%>','<%=iDocNo %>');" ></a> 
											&nbsp;
											<%
											//if(getHttpResponseCode(docPdfPath)==200){ 
											%>
											   <img border="0" src="images/attach-file_90371.png" align="absmiddle" width="20" height="20">
											   <a href="<%=docPdfPath%>" target="_blank"><%="pdfFileName"%></a>
											   &nbsp;
											   <a href="javascript:delFile('<%=iDocNo%>','<%=month %>','<%=yyyy %>','<%=pdfFileName%>');" ><img border="0" src="images/trash-9-16.png" align="absmiddle" width="16" height="16">ลบไฟล์ Attach</a>

											<%//}
											%>
										 </nobr>			                
			                
			                </td>
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

			<input type="hidden" name="total_item" value="<%=jobList.size()%>">

			<table border="0" width="100%" cellspacing="0" cellpadding="0">
			 <%
			 
			    //String yyyyMMdd =  GetDateKeyinYYYYMMDD(conn,iDocNo);
			    //String []tmp = yyyyMMdd.split("\\-"); //2012-08-15
                //String yyyy = tmp[0];
                //String month = tmp[1];
                			 
				line = 0;
				//String keyFile = "";
				String itemId = "";
				String qareaId = "";
				String vendorId = "";
				
				//System.out.println("==========================================--------jobList :"+jobList.size());
				String bgColor = "";
				//String imagesIdUrl = "";
				//pathUrlX += yyyy+"/"+month+"/"+iDocNo+"/";	
				String pathUrlX = Utilizer.getPropValue("DOMAIN_NAME")+Utilizer.getPropValue("PATH_UPLOAD")+yyyy+"/"+month+"/"+iDocNo+"/";	
	    		String pathTmp = Utilizer.getPropValue("IP_HOST_UPLOAD")+Utilizer.getPropValue("PATH_UPLOAD")+yyyy+"/"+month+"/"+iDocNo+"/";
				
		
				for (int i=0;i<jobList.size();i++) {
						 line++;
						 bgColor = "#e8f2fe";
						 if(line%2==0){
						  bgColor= "#ffffff";
						 }										
	
						 key = (String) jobList.elementAt(i);               
                         itemId = doString.checkString((String) jobItm.get(key),"");
                         vendorId = doString.checkString((String) jobVendor.get(key),"");
                         qareaId = doString.checkString((String) jobArea.get(key),"");
                         
                         
                         keyFile   = iDocNo+"_"+key+"_"+vendorId+"_"+qareaId+"_"+line;
						 //System.out.println("keyFile = "+keyFile);
						 //System.out.println("======================== print file line ================================");
						//======================== print file line 1 ================================//
						%>
						  <tr bgcolor="<%=bgColor%>">
							<td class="item" height="22" width="5%"><nobr>รายการที่ <%=line%> : </nobr></td>	
							<td class="item" height="22" width="20%"><nobr>รูปภาพก่อนซ่อม1 : 
							<%
							imagesIdUrl = pathUrlX+keyFile+"_a.jpg";
							//System.out.println("imagesIdUrl = "+imagesIdUrl);
							int resCode = getHttpResponseCode(pathTmp+keyFile+"_a.jpg");
							if(resCode==200) {
							    //(docId,mm,yyyy,imgId)
								%>
									<a href="<%=imagesIdUrl%>" target="_blank"><img src="<%=imagesIdUrl%>" width="25" height="20" border="0"></a> &nbsp; &nbsp; 									
								<%								
							}else{
								out.println("ไม่มีรูปภาพ");
							}
							 %>
							</nobr></td>
							<td class="item" height="22" width="20%"><nobr>รูปภาพก่อนซ่อม2 : 
							<%
							imagesIdUrl = pathUrlX+keyFile+"_b.jpg";
							//System.out.println("imagesIdUrl = "+imagesIdUrl);
							resCode = getHttpResponseCode(pathTmp+keyFile+"_b.jpg");
							if(resCode==200) {
								%>
									<a href="<%=imagesIdUrl%>" target="_blank"><img src="<%=imagesIdUrl%>" width="25" height="20" border="0"></a> &nbsp; &nbsp; 
								<%								
							}else{
								out.println("ไม่มีรูปภาพ");
							}
							 %>							
							</nobr></td>
						  </tr>					
						<%
						//System.out.println("###################################################");	
				 } // end for
				%>
			</table>
	</td>
	</tr>
	</table>

			<table border="0" width="100%" cellspacing="0" cellpadding="0">
			  <tr>
			    <td width="5" valign="bottom"><img src="images/Corn03.gif" width="5" height="5"></td>
			    <td class="frmBottom">&nbsp;</td>
			    <td width="5" valign="bottom" align="right"><img src="images/Corn04.gif" width="5" height="5"></td>
			  </tr>
			</table>
<%-- ===================================  Attach File ================================================ --%>


<%

} // end if				
%>
			<br style="font-size:10pt">

			            <table border="0" width="100%" cellspacing="0" cellpadding="0">
			              <tr>
			                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
			                <td class="item_tab2" width="160">หมายเหตุ</td>
			                <td class="item_tab3"></td>
			                <td class="textgray">&nbsp;
			                <!--โดย <%//=doString.DisplayThai(rejectEmploy)+" &nbsp; เมื่อวันที่ "+rejectDate%>-->
			                </td>
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
			    <td width="100%" class="frmLRpad01" valign="top">
			    <!--<%//=doString.DisplayThai(rejectComment)%>-->
			    <textarea rows="5" name="i_comment" class="box" style="width:100%" cols="20"></textarea>
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
   if (rejectStatus.equalsIgnoreCase("Y") || rejectComment.length()>0) {
			%>
			<br style="font-size:10pt">

			            <table border="0" width="100%" cellspacing="0" cellpadding="0">
			              <tr>
			                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
			                <td class="item_tab2" width="160">หมายเหตุการ RouteBack</td>
			                <td class="item_tab3"></td>
			                <td class="textgray">&nbsp; โดย <%=doString.DisplayThai(rejectEmploy)+" &nbsp; เมื่อวันที่ "+rejectDate%></td>
			              </tr>
			            </table>


			<table border="0" width="100%" cellspacing="0" cellpadding="0">
			  <tr>
			    <td width="5" valign="top"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
			    <td class="frmTop">&nbsp;</td>
			    <td width="5" valign="top" align="right"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
			  </tr>
			</table>

			<table border="0" width="100%" cellspacing="0" cellpadding="0" style="height:100px">
			  <tr>
			    <td width="100%" class="frmLRpad01" valign="top"><%=rejectComment%></td>
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
   }
%>
<br style="font-size:10pt">

        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="230" class="act_tab2">
            <img border="0" src="images/act_approve.gif"  onclick="approve_job();"
    			onmouseout=nereidFade(this,70,50,5)
                  	onmouseover=nereidFade(this,100,50,5)
                  	style="cursor:hand;FILTER: alpha(opacity=70)" width="70" height="27"> &nbsp;
            <img border="0" src="images/act_reject.gif"  onclick="reject_job();"
    			onmouseout=nereidFade(this,70,50,5)
                  	onmouseover=nereidFade(this,100,50,5)
                  	style="cursor:hand;FILTER: alpha(opacity=70)" width="70" height="27">&nbsp;
            <!--<img border="0" src="images/act_delete.gif"  onclick="deleteJob();"
    			onmouseout=nereidFade(this,70,50,5)
                  	onmouseover=nereidFade(this,100,50,5)
                  	style="cursor:hand;FILTER: alpha(opacity=70)" width="70" height="27">-->

            </td>


            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_Staff_List.jsp"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
     System.out.println("-------SERV_Staff_Conf.jsp-----");
	} catch (Exception e) {
		System.out.println("ERROR SERV_Staff_Conf.jsp : " + e.getMessage());
		System.out.println("ERROR SERV_Staff_Conf.jsp SQL: " +sql.toString());
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