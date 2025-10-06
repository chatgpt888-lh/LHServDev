<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@page language="java" contentType="text/html; charset=tis-620"
	pageEncoding="tis-620"%>
<%@ page import="com.lh.util.doString" %>	
<%@ page import="com.svc.call.utilize.Constant" %>
<%@ page import="com.svc.call.bean.CustomerBean" %>
<%@ page import="com.svc.call.bean.SVC_DOCHD" %>
<%@ page import="com.svc.call.bean.SVC_DOCDT" %>
<%@ page import="com.svc.call.bean.SVC_TELNO" %>
<%@ page import="com.svc.call.bean.SVC_XSTD" %>
<%@ page import="com.svc.call.bean.SVC_STDPJ" %>
<%@ page import="com.svc.call.utilize.Utilizer" %>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>	
<%@page import="java.text.*" %>	
<%
/**********************************************
 * create by : pradoem wonkraso
 * date time: 2013.10.17
 * Last modify :
 * version :1.0
 * project Name :Service Center 
 * description : implement for Service call center End user
 -Receive call  input form
 -Add to google calendar 
 ***************************************************/

	ArrayList projectDDL = (ArrayList)session.getAttribute(Constant.SS_PROJECT_AVAILABLE_LIST);
	String tel = request.getAttribute("tel")==null?"":request.getAttribute("tel").toString();
	String agentId = request.getAttribute("agentId")==null?"":request.getAttribute("agentId").toString();
	String employId = request.getAttribute("employId")==null?"":request.getAttribute("employId").toString();
	String employName = request.getAttribute("employName")==null?"":request.getAttribute("employName").toString();
    String projectSel = request.getAttribute("projectSel")==null?"":request.getAttribute("projectSel").toString(); //LH:075
	String houseNo = request.getAttribute("houseNo")==null?"":request.getAttribute("houseNo").toString();
    String lock = request.getAttribute("lock")==null?"":request.getAttribute("lock").toString(); //LH:075

	//----For Keyin value
	/*******************
	* CASE : Edit form 
	**********************/
	String selJobBannDDL = request.getAttribute("jobBannDDL")==null?"":request.getAttribute("jobBannDDL").toString();
	String selDateDDL = request.getAttribute("dateDDL")==null?"":request.getAttribute("dateDDL").toString();
	String selTimeDDL = request.getAttribute("timeDDL")==null?"":request.getAttribute("timeDDL").toString();
	String selJobPublicDDL2 = request.getAttribute("jobPublicDDL2")==null?"":request.getAttribute("jobPublicDDL2").toString();
	String txtAreaDescJob99 = request.getAttribute("txtAreaDescJob99")==null?"":request.getAttribute("txtAreaDescJob99").toString();
	String txtAreaDescJob1 = request.getAttribute("txtAreaDescJob1")==null?"":request.getAttribute("txtAreaDescJob1").toString();
	String txtAreaDescJob2 = request.getAttribute("txtAreaDescJob2")==null?"":request.getAttribute("txtAreaDescJob2").toString();
	String txtAreaDescJob3 = request.getAttribute("txtAreaDescJob3")==null?"":request.getAttribute("txtAreaDescJob3").toString();
	String txtAreaDescJob4 = request.getAttribute("txtAreaDescJob4")==null?"":request.getAttribute("txtAreaDescJob4").toString();
	String txtAreaDescJob5 = request.getAttribute("txtAreaDescJob5")==null?"":request.getAttribute("txtAreaDescJob5").toString();
	String chkBox1	=  request.getAttribute("chkBox1")==null?"":request.getAttribute("chkBox1").toString();
	String chkBox2	=  request.getAttribute("chkBox2")==null?"":request.getAttribute("chkBox2").toString();
	String mode	=  request.getAttribute("mode")==null?"":request.getAttribute("mode").toString();//form EditAction 
	//For เลื่อนนัด from preview&Edit
	String chngMode	=  request.getAttribute("chngMode")==null?"":request.getAttribute("chngMode").toString();//form EditAction CHANGE_DATE
	String docNo	=  request.getAttribute("docNo")==null?"":request.getAttribute("docNo").toString();
	String type	=  request.getAttribute("type")==null?"":request.getAttribute("type").toString();
	String code	=  request.getAttribute("code")==null?"":request.getAttribute("code").toString();
	String fdate	=  request.getAttribute("fdate")==null?"":request.getAttribute("fdate").toString();
	String fstatus	=  request.getAttribute("fstatus")==null?"":request.getAttribute("fstatus").toString();
	String gEventId  =  request.getAttribute("gEventId")==null?"":request.getAttribute("gEventId").toString();
	
	//For close Job
	String chkCLS1 =  request.getAttribute("chkCLS1")==null?"":request.getAttribute("chkCLS1").toString();
	String chkCLS2 =  request.getAttribute("chkCLS2")==null?"":request.getAttribute("chkCLS2").toString();
	String chkCLS3 =  request.getAttribute("chkCLS3")==null?"":request.getAttribute("chkCLS3").toString();
	String chkCLS4 =  request.getAttribute("chkCLS4")==null?"":request.getAttribute("chkCLS4").toString();
	String chkCLS5 =  request.getAttribute("chkCLS5")==null?"":request.getAttribute("chkCLS5").toString();
	String chkCLS6 =  request.getAttribute("chkCLS6")==null?"":request.getAttribute("chkCLS6").toString();
						
	//For Edit customer 
	String chkEdit =  request.getAttribute("chkEdit")==null?"":request.getAttribute("chkEdit").toString(); //YES		    
	String customerTxt = request.getAttribute("customerTxt")==null?"":request.getAttribute("customerTxt").toString();
	//String mobileTxt1 = request.getAttribute("mobileTxt1")==null?"":request.getAttribute("mobileTxt1").toString();
	String mobileTxt2 = request.getAttribute("mobileTxt2")==null?"":request.getAttribute("mobileTxt2").toString();
	String emailTxt = request.getAttribute("emailTxt")==null?"":request.getAttribute("emailTxt").toString();
	//String mobileTxt0 = request.getAttribute("mobileTxt0")==null?"":request.getAttribute("mobileTxt0").toString();
	//************************************
	Object  objNStandard   = session.getAttribute(Constant.SS_NAME_STANDARD_LIST);
	Object  objGHomeRepair = session.getAttribute(Constant.SS_GHOME_REPAIR_LIST);
    Object  objGPService   = session.getAttribute(Constant.SS_GPUBLIC_SERVICE_LIST);
   
    Object  objDateAppoint =  request.getAttribute("listDateAppoint");
    Object  objCust = request.getAttribute("CustomerBean");
    Object  objTelNo = request.getAttribute("SVC_TELNO");
    Object  objDocHd = request.getAttribute("listDOCHD");
    Object  objGCalendar =  request.getAttribute("SVC_STDPJ");
    Object  objDocDt =   request.getAttribute("SVC_DOCDT");
    
    CustomerBean  custObj = null;
    SVC_TELNO    telNoObj = null;
    SVC_DOCDT	svcDocDt = null;
    SVC_XSTD  	xstdObj = null;
    SVC_STDPJ   GcalendarObj = null;
    ArrayList   listDOCHD = null;
    ArrayList   listGHomeRepair  = null;
    ArrayList   listGPService  = null;
    ArrayList   listNStandard = null;
    ArrayList   listDateAppoint = null;

	if(objCust!=null){ custObj = (CustomerBean)objCust;
	}else{ custObj = new CustomerBean();}
	
	if(objTelNo!=null){telNoObj = (SVC_TELNO)objTelNo;
	}else{ telNoObj = new SVC_TELNO();}
	
    if(objDocHd!=null){ listDOCHD = (ArrayList)objDocHd;
	}else{  listDOCHD = new ArrayList();}
	
	if(objGHomeRepair!=null){  listGHomeRepair = (ArrayList)objGHomeRepair;
	}else{ listGHomeRepair = new ArrayList();}
	
	if(objGPService!=null){ listGPService = (ArrayList)objGPService;
	}else{  listGPService = new ArrayList();}
	
	if(objNStandard!=null){ listNStandard = (ArrayList)objNStandard;
	}else{  listNStandard = new ArrayList();}
	
	if(objDateAppoint!=null){ listDateAppoint = (ArrayList)objDateAppoint;
	}else{  listDateAppoint = new ArrayList();}
	
	if(objGCalendar!=null){ GcalendarObj = (SVC_STDPJ)objGCalendar;
	}else{  GcalendarObj = new SVC_STDPJ();}
	
	if(objDocDt!=null){ svcDocDt = (SVC_DOCDT)objDocDt;
	}else{  svcDocDt = new SVC_DOCDT();}
  
  System.out.println("-->txtAreaDescJob99 :"+txtAreaDescJob99);
  if("CHANGE_DATE".equalsIgnoreCase(chngMode)){
	  	//selJobBannDDL = 05  changeDate Fix
	  	//CASE: preview
	  	if(Utilizer.replaceNull(svcDocDt.getC_detail()).length()>0){
	  		txtAreaDescJob99 = Utilizer.replaceNull(svcDocDt.getC_detail());}
	  	if(Utilizer.replaceNull(svcDocDt.getI_svc_docno()).length()>0){
	  		docNo = Utilizer.replaceNull(svcDocDt.getI_svc_docno());}
	  	if(Utilizer.replaceNull(svcDocDt.getI_itmno()).length()>0){
	  		type = Utilizer.replaceNull(svcDocDt.getI_itmno());}
	  	if(Utilizer.replaceNull(svcDocDt.getI_itmsub()).length()>0){
	  		code = Utilizer.replaceNull(svcDocDt.getI_itmsub());}
	    if(Utilizer.replaceNull(svcDocDt.getD_appoint()).length()>0){
	  		fdate = Utilizer.replaceNull(svcDocDt.getD_appoint());}
	  	if(Utilizer.replaceNull(svcDocDt.getF_status()).length()>0){
	  		fstatus = Utilizer.replaceNull(svcDocDt.getF_status());}
	   if(Utilizer.replaceNull(svcDocDt.getI_calendar_id()).length()>0){
	  		gEventId = Utilizer.replaceNull(svcDocDt.getI_calendar_id());}
	  	if( Utilizer.replaceNull(svcDocDt.getD_appoint()).length() > 0){
	  		String []tempDate = Utilizer.replaceNull(svcDocDt.getD_appoint()).split("\\ ");
	  	  	selDateDDL = tempDate[0];
	  		selTimeDDL = tempDate[1].substring(0,5);
	  		System.out.println("-->selDateDDL:"+selDateDDL);
	  		System.out.println("-->selTimeDDL :"+selTimeDDL);
	  	}
	  	System.out.println("-->CASE MODE :"+chngMode);
	  	mode = chngMode;
  }
  
  //case Edit customer profile
  System.out.println("Email :"+telNoObj.getIEmail());
  if("YES".equals(chkEdit)){
  		telNoObj.setNCustomer(customerTxt);
  		telNoObj.setIEmail(emailTxt);
  		//tel = mobileTxt1;
  		//telNoObj.setITelNo(mobileTxt2);	
  }
 %>

<HTML>
<HEAD>
<title>SVC_CallInForm</title>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script src="SVC_Prototype.js" type="text/JavaScript"></script>
<script language="javascript" src="script_fx.js"></script>
<SCRIPT LANGUAGE="JavaScript">
	/*
	 * create by : pradoem wonkraso
	 * date time: 2013.10.17
	 * Last modify :
	 * version :1.0
	 * project Name :Service Center 
	 onChange event of the dropDownList will calls this function
	 which has AJAX call to Struts Action class
	 @param: dropDownList object (this)
	 @param: URL or Struts Action
	 */
 function doDepedentDropDown(obj, url) {
	if(document.forms[0].projectDDL.value ==""){
	    document.forms[0].projectDDL.focus();
	    document.forms[0].projectDDL.select;
		alert("กรุณาเลือกโครงการด้วย!!");
        return;
	}else{
	    var varDateDDL = $F(obj);
	    var varProjectDDL = document.forms[0].projectDDL.value;
		var pars = "dateDDL="+varDateDDL+"&projectDDL="+varProjectDDL; //parameter send to
		alert(pars);
		var myAjax = new Ajax.Request(url, {
			method : 'POST',
			parameters : pars,
			onComplete : showResponse
		});
	}
 }//End

	/*
	 Upon completing the request the AJAX will call this method
	 which is responsible for loading the depedent list from the XML
	 */
	function showResponse(originalRequest) {
		var list = $('timeDDL');
		var xmlString = originalRequest.responseXML;
		var items = xmlString.getElementsByTagName('labelValueBean');
		clearList(list);
		if (items.length > 0) {
			for ( var i = 0; i < items.length; i++) {
				var node = items[i];
				var value = "";
				var label = "";
				if (node.getElementsByTagName("label")[0].firstChild.nodeValue) {
					value = node.getElementsByTagName("label")[0].firstChild.nodeValue;
					label = node.getElementsByTagName("value")[0].firstChild.nodeValue;
				}
				addElementToList(list, value, label);
			}
		} else {
			addElementToList(list, "", "---กรุณาระบุเวลา---");
		}
	}
	/**
	 remove the content of te list
	 */
	function clearList(list) {
		while (list.length > 0) {
			list.remove(0);
		}
	}

	/**
	 Add a new element to a selection list
	 */
	function addElementToList(list, value, label) {
		var option = document.createElement("option");
		option.value = value;
		var labelNode = document.createTextNode(label);
		option.appendChild(labelNode);
		list.appendChild(option);
	}
</SCRIPT>
<script language="javascript">
<!--
 function doInitial(){
 	try{
 		<%//Case Modify customer profile
 		if("YES".equals(chkEdit)){
			for(int i=1;i<=5;i++){
			   if(i!=2 && i!=5){
			   %>
	           document.getElementById("txt<%=i%>").disabled=false;
 		   <%}}
 		}else{
 		    for(int i=1;i<=5;i++){
 		        if(i!=2 && i!=5){
 		       %>
	           document.getElementById("txt<%=i%>").disabled=true;
 		   <%}}
 		}%>
 		
 		<%
 		System.out.println("TEST :"+mode);
 		System.out.println("box1 :"+chkBox1);
 		System.out.println("box2 :"+chkBox2);
 		 if("edit".equals(mode)){
 		 	if("1".equals(chkBox1)){
 		 %>
 		 		 document.getElementById("job1").style.display=''; //Enable
 		 <%
 		 	}
 		 	if("0".equals(chkBox2)){
 		 	    for(int i=2;i<=5;i++){
 		 		%>
		    	   document.getElementById("job<%=i%>").style.display='none'; //disable
		       <%}	 
 		 	}	
 		 }else{//First step
 		      for(int i=2;i<=5;i++){
 		     %>
	    	   document.getElementById("job<%=i%>").style.display='none'; //disable
 		    <% }
 		 }
 		%>

    }catch(e){}
 }
  function doViewAction(param,cnt){
     if(param==true) {	 
		 	document.getElementById("job"+cnt).style.display='';
      }else {
		 	document.getElementById("job"+cnt).style.display='none';
      }
  }
 
  function doChkEdit(param){
	   if(true==param){
		  for(i=1;i<=5;i++){
			  if(i!= 2 && i!= 5){
		       document.getElementById("txt"+i).disabled=false;
		      }
	     }
	   }else{
	   	 for(i=1;i<=5;i++){
	   	    if(i!= 2 && i!= 5){
	          document.getElementById("txt"+i).disabled=true;
	        }  
	    }
    }
}

 function onChangeGroupHomeRepair(param){
    //01 Repair Home,and 05 change date 
 	if(param== '01' || param== '05'){
 		 document.getElementById("dateDDL").disabled=false; //Enable
 		 document.getElementById("timeDDL").disabled=false; //Enable
 	}else{
 	    document.getElementById("dateDDL").disabled=true;//Disable
 	    document.getElementById("timeDDL").disabled=true;//Disable
 	}
 } 

 function doSubmitSearhCust(){   
     if(document.forms[0].projectDDL.value ==""){
	    document.forms[0].projectDDL.focus();
	    document.forms[0].projectDDL.select;
		alert("กรุณาเลือกโครงการด้วย!!");
        return;
	}else if(document.forms[0].houseNoTxt.value =="" && document.forms[0].lockTxt.value ==""){
	    document.forms[0].houseNoTxt.focus();
		alert("กรุณาระบุบ้านเลขที่/ระบุแปลง ด้วย!!");
        return;
	}
	 /*else if(document.forms[0].lockTxt.value ==""){
	    document.forms[0].lockTxt.focus();
		alert("กรุณากรอกแปลงด้วย!!");
        return;
	}*/
	else{  
		 //document.forms[0].mode.value = "search";
		 document.forms[0].action="<%=request.getContextPath() %>/SVCInformController.do?cmd=searchCust";
		 document.forms[0].submit();
	 }
 }
 
  function doSubmitPreview(){   
  	var chks = document.getElementsByName('chkQ1');
  	var chkCLS1 = document.getElementsByName('chkCLS1');
	if(chks[0].checked==false && chks[1].checked==false){
		alert("กรุณาเลือก Check Box งานซ่อมบ้านหรืองานซ่อมอื่นๆด้วย!!");
		document.forms[0].chkQ1[0].focus();
		return;
	}else{
		//alert(chkCLS1[0].checked);
		if(chkCLS1[0].value=="YES"){
			// alert("submit preview(case :00 Emty not input iLock.)");
			 doSubmitForm();
		} else if(document.forms[0].projectDDL.value ==""){
		    document.forms[0].projectDDL.focus();
		    document.forms[0].projectDDL.select;
			alert("กรุณาเลือกโครงการด้วย!!");
	        return;
		}else if(document.forms[0].houseNoTxt.value ==""){
		    document.forms[0].houseNoTxt.focus();
			alert("กรุณากรอกบ้านเลขที่ด้วย!!");
	        return;
		} else if(document.forms[0].lockTxt.value ==""){
		    document.forms[0].lockTxt.focus();
			alert("กรุณากรอกแปลงด้วย!!");
	        return;
		}else{  
			 var varJobBannDDL = document.forms[0].jobBannDDL.value;
			 if(varJobBannDDL != ""){
			     if(varJobBannDDL =="01" || varJobBannDDL=="05"){
			     	//CASE:#1
			     	if(document.forms[0].dateDDL.value==""){
			     		document.forms[0].dateDDL.focus();
						alert("กรุณาระบุวันที่ด้วย!!");
				        return;
			     	}else if(document.forms[0].timeDDL.value==""){
			     		document.forms[0].timeDDL.focus();
						alert("กรุณาระบุเวลาด้วย!!");
				        return;
			     	}else{
			     		//alert("submit preview(success case :1)");
			     		doSubmitForm();
			     	}
			     }else{
			        // alert(" submit preview(case :2 in case 1)");
			         //if(chks[1].checked==true){//CASE:check box other service
			         // }else{
			         //}
			         doSubmitForm();
			     }
			  }else{
			     alert("submit preview(case :3 Emty)");
			     doSubmitForm();
			  }
	 	}//#End else
	}
}
 
function doSubmitForm(){ 
	var chEdit = document.getElementsByName('chkEdit');
	if(chEdit[0].value=="YES"){
		if(document.forms[0].txt3.value !="" && document.forms[0].txt3.value.length<10){
	    	  alert("กรุณาตรวจสอบเบอร์มือถือ#2 ต้องครบ 10 หลัก..");	
	    	  document.getElementById("txt3").focus();
	    	  document.getElementById("txt3").select(); 
	    	  return;
		}else if(document.forms[0].txt4.value!="" &&  !validatemail(document.forms[0].txt4.value)){
			alert("กรุณาตรวจสอบ E-mail ผู้แจ้ง ด้วย..");
			document.getElementById("txt4").focus();
	    	document.getElementById("txt4").select(); 
	    	return;// document.forms[0].focus();// document.forms[0].select();
		}else{
			document.forms[0].action="<%=request.getContextPath() %>/SVC_CallInPreview.jsp";
			document.forms[0].submit();
		}
	}else{
		document.forms[0].action="<%=request.getContextPath() %>/SVC_CallInPreview.jsp";
		document.forms[0].submit();
	}
}

	 function validatemail(tempEmail){		
			var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
			//var address = document.form1.txtaltermail.value;
			if(reg.test(tempEmail) == false){
				return false;
			}else{
				return(true);
			}
	}
	
  function doChangeProjectDDL() {
		if(document.forms[0].projectDDL.value ==""){
		    document.forms[0].projectDDL.focus();
		    document.forms[0].projectDDL.select;
			alert("กรุณาเลือกโครงการด้วย!!");
	        return;
		}else{
			document.forms[0].action="<%=request.getContextPath() %>/SVCInformController.do?cmd=search11";
			document.forms[0].submit();	
		}
   }
   
	function popupSvcHistory(){
		MM_openBrWindow('<%=request.getContextPath()%>/SVCHistoryController.do?cmd=formLoad&tel=<%=tel%>&agentId=<%=agentId%>&projectDDL=<%=projectSel%>&houseNoTxt=<%=houseNo%>&lockTxt=<%=lock%>',
		'ServiceCenterHistory','status=yes,scrollbars=yes,resizable=yes,width=1000,height=520');
	}

//-->
</script>
<base target="_self">
<style type="text/css">
.box2 {  font-family: Tohama,Arial,sans-serif; font-size:10.1pt; font-weight:normal;
	padding-top: 1px; padding-right: 1px; padding-bottom: 1px; padding-left: 1px; 
	 color:#165396; background-color: white; border: 1px #BEDCFF solid ; 
}
</style>
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onLoad="javascript:doInitial();">

<FORM METHOD="POST" ACTION="">
<input type="hidden" name="tel" id="tel" value="<%=tel %>">
<input type="hidden" name="agentId" id="agentId" value="<%=agentId %>">
<%-- For  select project  process --%>
<input type="hidden" name="comId" id="comId" value="">
<input type="hidden" name="projId" id="projId" value="">
<input type="hidden" name="nameProject" id="nameProject" value="">
<input type="hidden" name="employName"  value="<%=employName %>">
<input type="hidden" name="employId"  value="<%=employId %>">
<input type="hidden" name="mode" value="<%=mode %>">

<%-- For  Post Pone A date เลื่อนนัด  process --%>
<input type="hidden" name="docNo" id="docNo" value="<%=docNo %>">
<input type="hidden" name="type" id="type" value="<%=type%>">
<input type="hidden" name="code" id="code" value="<%=code%>">
<input type="hidden" name="fdate" id="fdate" value="<%=fdate%>">
<input type="hidden" name="fstatus" id="fstatus" value="<%=fstatus%>">
<input type="hidden" name="gEventId" id="gEvent_id" value="<%=gEventId%>">

<%-- For customer --%>
<input type="hidden" name="customerId"  value="<%=Utilizer.replaceNull(custObj.getCustomerId()) %>">
<input type="hidden" name="model"  value="<%=Utilizer.replaceNull(custObj.getModel()) %>">
<input type="hidden" name="cPrefix"  value="<%=doString.DisplayThai(Utilizer.replaceNull(custObj.getPrefixName())) %>">
<input type="hidden" name="cFname"  value="<%=doString.DisplayThai(Utilizer.replaceNull(custObj.getFName())) %>">
<input type="hidden" name="cLname"  value="<%=doString.DisplayThai(Utilizer.replaceNull(custObj.getLName()) )%>">
<input type="hidden" name="cTelNo"  value="<%=Utilizer.replaceNull(custObj.getTelNo()) %>">
<input type="hidden" name="flagGuranteeDate"  value="<%=Utilizer.replaceNull(custObj.getFlagGuranteeDate()) %>">
<input type="hidden" name="dateGurantee"  value="<%=Utilizer.replaceNull(custObj.getDateGurantee()) %>">

<%-- For customer --%>

<%-- For Gmail Calendar --%>
<input type="hidden" name="i_prjcal_id"  value="<%=Utilizer.replaceNull(GcalendarObj.getCalendarId())%>">
<input type="hidden" name="i_gmail"  value="<%=Utilizer.replaceNull(GcalendarObj.getGmail())%>">
<input type="hidden" name="i_password"  value="<%=Utilizer.replaceNull(GcalendarObj.getPassword())%>">
<input type="hidden" name="feedUrl"  value="<%=Utilizer.replaceNull(GcalendarObj.getFeedUrl())%>">
<input type="hidden" name="ReadOnlyUrl"  value="<%=Utilizer.replaceNull(GcalendarObj.getReadOnlyUrl())%>">
<%-- For customer--%>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;&nbsp;Service Center</td>
          <td width="50%" align="right">&nbsp;
          </td>
        </tr>
      </table>
      
<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดการรับเรื่อง</td>
                <td class="item_tab3"></td>
                <td>&nbsp; </td>
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
    <td class="item ; dotline01" height="22" width="13%">โครงการ:</td>
    <td height="22" width="39%" class="dotline01">

			<select name="projectDDL" id="projectDDL" class="box2" style='width:250' size="1"  onchange="javascript:doChangeProjectDDL();"> 
						<option value="" >------ กรุณาเลือกโครงการ ------</option>
   							<%
							List  strList = null;
							String tempId = "";
							String selectd = "";
							if(projectDDL!=null && projectDDL.size()>0){
								Iterator it = projectDDL.iterator();
								while(it.hasNext()){		
									 tempId = "";						
									 strList =(ArrayList)it.next();	
									 tempId = strList.get(0).toString()+":"+strList.get(1).toString();		
									 
									 System.out.println(tempId+","+projectSel);
									 selectd = "";
									 if(projectSel.equals(tempId)){
									 	selectd = "selected";	
									 }	
									 if(projectDDL.size()==1){//set default
									    selectd = "selected";	
									 }			
									%>
									 	<option value="<%=strList.get(0)+":"+strList.get(1)%>" <%=selectd %>>
									 	[<%=strList.get(0)%>-<%=strList.get(1)%>]  <%=doString.checkString(doString.DisplayThai(strList.get(2).toString())) %></option>
								   <%}
								} %>	 
   				</select> 					
	      &nbsp;&nbsp;
       <img src="images/i_search.gif" width="20" height="20" border="0" align="absmiddle" style="cursor:hand"
        onClick="MM_openBrWindow('SVC_PopupSearchProject.jsp?tel=<%=tel%>&agentId=<%=agentId %>','SVC_PopupSearchProject','status=yes,scrollbars=yes,resizable=yes,width=1000,height=600')">
      </td>
    <td height="22" class="item ; dotline01" width="14%">เลขที่อ้างอิง :</td>
    <td height="22" width="34%" class="dotline01">[ Auto Generate ] </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">บ้านเลขที่ :</td>
    <td height="22" width="39%" class="dotline01"><input type="text" name="houseNoTxt" class="box" style="width:100px" value="<%=houseNo %>" tabindex="1"></td>
    <td height="22" class="item ; dotline01" width="14%">แปลง :</td>
    <td height="22" width="34%" class="dotline01"> <input type="text" name="lockTxt" class="box" style="width:100px" value="<%=lock %>" tabindex="2">&nbsp;&nbsp;
      <a href="javascript:doSubmitSearhCust();"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a> </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">แบบบ้าน :</td>
    <td height="22" width="39%" class="dotline01">&nbsp;<%=Utilizer.replaceNull(custObj.getModel()) %></td>
    <td height="22" class="item ; dotline01" width="14%">&nbsp;</td>
    <td height="22" width="34%" class="dotline01">&nbsp;</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ชื่อลูกค้า:</td>
    <td height="22" width="39%" class="dotline01">&nbsp;<%=doString.DisplayThai(Utilizer.replaceNull(custObj.getPrefixName()).trim()) %>  
    <%=doString.DisplayThai(Utilizer.replaceNull(custObj.getFName()).trim())%>&nbsp;&nbsp;<%=doString.DisplayThai(Utilizer.replaceNull(custObj.getLName()).trim())%></td>
    <td height="22" class="item ; dotline01" width="14%">โทรศัพท์ติดต่อ  :</td>
    <td height="22" width="34%" class="dotline01">&nbsp;<%=Utilizer.replaceNull(custObj.getTelNo())%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">การประกัน:</td>
    <td height="22" width="39%" class="dotline01">
    &nbsp;<%
       if("N".equals(custObj.getFlagGuranteeDate())){
        	out.println("หมดประกัน");
       }else  if("Y".equals(custObj.getFlagGuranteeDate())) {
           out.println("อยู่ระหว่างประกัน");
       }
     %>
</td>
    <td height="22" class="item ; dotline01" width="14%">วันที่หมดประกัน :</td>
    <td height="22" width="34%" class="dotline01">
    <%=Utilizer.replaceNull(custObj.getDateGurantee()) %>
    </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ผู้รับเรื่อง  :</td>
    <td height="22" width="39%" class="dotline01"><%=employName %></td>
    <td height="22" class="item ; dotline01" width="14%">วันเวลาที่แจ้ง :</td>
    <td height="22" width="34%" class="dotline01"><%=Utilizer.ThisToDay() %>&nbsp;<%=Utilizer.ThisCalendarTimeNow(Calendar.getInstance()) %> น.</td>
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
<!-- -------------------------------Block#00 ------------------- -->
<table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1">
                <img border="0" src="images/i_i.gif" align="absmiddle"	width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดผู้แจ้ง</td>
                <td class="item_tab3"></td>
                <td>&nbsp;
                 <input type="checkbox" name="chkEdit" value="YES" onClick="JavaScript:doChkEdit(this.checked);"
                 <%if("YES".equals(chkEdit)){
                 	out.println("checked");
                 }%>> &nbsp; แก้ไขข้อมูลลูกค้า</td>
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
	<table border="0" width="100%" cellspacing="0" cellpadding="0" id="jobxx">
	<tr>
    <td height="22" class="dotline01 ; item">ชื่อ-สกุลผู้แจ้ง : </td>
    <td height="22" class="dotline01">
    	<input type="text" name="txt1" id="txt1" value="<%=doString.DisplayThai(Utilizer.replaceNull(telNoObj.getNCustomer()).trim()) %>" size="25"  class="box" style="width:250px" >
    </td>
    <td height="22"class="dotline01 ; item">เบอร์มือถือ#1 :</td>
    <td height="22" class="dotline01">
    	<input type="text" name="txt2"  id="txt2" value="<%=tel %>" size="15"  class="box" style="width:150px" disabled="disabled">
    </td>
    <td height="22"class="dotline01 ; item">เบอร์มือถือ#2 : </td>
    <td height="22" class="dotline01">
    	<input type="text" name="txt3"  id="txt3" value="<%=mobileTxt2 %>" size="15"  class="box" style="width:150px" >
    </td>
  </tr>

  <tr>
    <td height="22" class="dotline01 ; item" >E-mail :</td>
    <td height="22" class="dotline01">
    	<input type="text" name="txt4" id="txt4" value="<%=Utilizer.replaceNull(telNoObj.getIEmail()) %>" size="25"  class="box" style="width:250px" >
    </td>
    <td height="22" class="dotline01 ; item">เบอร์อื่นๆ :</td>
    <td height="22" class="dotline01">
    	<input type="text" name="txt5" id="txt5" value="<%=Utilizer.replaceNull(telNoObj.getITelNo()) %>" size="30"  class="box" style="width:150px" disabled="disabled">
    </td>
    <td height="22" class="dotline01 ; item">&nbsp;</td>
    <td height="22" class="dotline01">&nbsp; </td>
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
<!-- -------------------------------End Block#00 ------------------- -->

<br style="font-size:10pt">
<!-- -------------------------------Block#xx ------------------- -->
<table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1">
                <img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">ประวัติการติดต่อ</td>
                <td class="item_tab3"></td>
                <td>
           
&nbsp;
<a href="javascript:popupSvcHistory();"><img border="0" src="images/act_ViewRecord.gif" width="110" height="22"></a></td>
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
	    <td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/02Corn01.gif" width="5" height="5"></td>
	    <td class="frmTop2" bgcolor="#D7E6FF">&nbsp;</td>
	    <td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/02Corn02.gif" width="5" height="5"></td>
	  </tr>
	</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL2">
    		<%--********************************  History Call Recent  **************************--%>
              <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <%--********************************  Header table  **************************--%>
                <tr align="left"> 
                    <td  height="22" width="5%" class="col_name02" align="left">No.</td>
                    <td  height="22" width="15%" class="col_name02" align="left">วันเวลาที่แจ้ง</td>
				    <td height="22" width="20%" class="col_name02" align="left">เลขที่อ้างอิง</td>
				    <td height="22" width="20%" class="col_name02" align="left">ผู้รับเรื่อง</td>
				    <td height="22" width="20%" class="col_name02" align="left">ชื่อผู้แจ้ง</td>
				    <td height="22" width="20%" class="col_name02" align="left">สถานะ</td>
                </tr>
                <%--********************************  end Header table   **************************
				if(projectDDL!=null && projectDDL.size()>0){
					Iterator it = projectDDL.iterator();
					while(it.hasNext()){	 strList =(ArrayList)it.next();	
    
                --%>
                <%
                System.out.println("listDOCHD.size :"+listDOCHD.size());
                if(listDOCHD!=null && listDOCHD.size()>0){
                	SVC_DOCHD  docdhObj = null;
                	SVC_DOCDT  docdtObj = null;
                	int loop = 1;
                	//---------------------
                	Iterator itHD = listDOCHD.iterator();
                	Iterator itDT = null;
                	while(itHD.hasNext()){
                		docdhObj = (SVC_DOCHD)itHD.next();
                		%>
	                	<tr> 
						    <td  height="22" width="5%" class="dotline01 ; item" align="center"><%=loop %></td>
						    <td  height="22" width="15%" class="dotline01" align="left">&nbsp;<%=Utilizer.toDDMMYY_THAI2(docdhObj.getD_keyin())%></td>
						    <td height="22" width="20%" class="dotline01" align="left">&nbsp;<%=docdhObj.getI_svc_docno() %></td>
						    <td height="22" width="20%" class="dotline01" align="left">&nbsp;<%=doString.DisplayThai(docdhObj.getEmployName()) %></td>
						    <td height="22" width="20%" class="dotline01" align="left">&nbsp;<%=doString.DisplayThai(docdhObj.getN_customer()) %></td>
						    <td height="22" width="20%" class="dotline02" align="left">&nbsp;
						    <%if(Utilizer.replaceNull(docdhObj.getF_status()).equals("001")){
						    	out.println("บันทึกรายการเรียบร้อยแล้ว");
						    }else if(Utilizer.replaceNull(docdhObj.getF_status()).equals("002")){
						        out.println("อยู่ระหว่างดำเนินการ");
						    }%></td>
	                  	</tr>
	                   <%--********************************  Header table sub&deatil **************************--%>
		                 <tr>
				               <td  height="22" width="5%" class="dotline01" align="center">&nbsp;</td>
			                    <td  height="22" width="15%" class="dotline01 ; item" align="left">หมวด</td>
								    <td height="22" width="20%" class="dotline01 ; item" align="left">รายละเอียด</td>
								    <td height="22" width="20%" class="dotline01 ; item" align="left">Start Task</td>
								    <td height="22" width="20%" class="dotline01 ; item" align="left">End Task</td>
								    <td height="22" width="20%" class="dotline02 ; item" align="left">สถานะ</td>
						 </tr>
						 <% 
						     itDT = null; //Iterator
						     if(docdhObj.getSvcDocdtList()!=null && docdhObj.getSvcDocdtList().size()>0){
						     	itDT = docdhObj.getSvcDocdtList().iterator();
						     	while(itDT.hasNext()){
                					docdtObj = (SVC_DOCDT)itDT.next();
                					%>
                					<tr> 
				                    <td  height="22" width="5%" class="dotline01" align="center">&nbsp;</td>
			                        <td  height="22" width="15%" class="dotline01">
			                        <img src="images/i_arrow2.gif" width="11" height="11" hspace="3" border="0" align="absmiddle"><%=doString.DisplayThai(docdtObj.getN_desc()) %></td>
							        <td height="22" width="20%" class="dotline01" TITLE="<%=doString.DisplayThai(docdtObj.getC_detail()) %>">&nbsp;<%
							        if(docdtObj.getC_detail().length()>50){
							        	out.println(doString.DisplayThai(docdtObj.getC_detail().substring(0,48))+"...");
							        }else{
							           out.println(doString.DisplayThai(docdtObj.getC_detail()));
							        }
							        %></td>
								    <td height="22" width="20%" class="dotline01">&nbsp;<%=Utilizer.toDDMMYY_THAI2(docdtObj.getD_start()) %></td>
								    <td height="22" width="20%" class="dotline01">&nbsp;<%=Utilizer.toDDMMYY_THAI2(docdtObj.getD_complete()) %></td>
								    <td height="22" width="20%" class="dotline02">&nbsp;
								    <%if(Utilizer.replaceNull(docdtObj.getF_status()).equals("001")){
								    	out.println("บันทึกรายการเรียบร้อยแล้ว");
								    }else if(Utilizer.replaceNull(docdtObj.getF_status()).equals("002")){
								        out.println("อยู่ระหว่างดำเนินการ");
								    }%></td>
								 	</tr>
                					<%
                				}//#End itDT
						     }//#End check null&& size  docDT
						 %>
                	     <%		
                	     loop++;
                	}//#End header
                }//#End listDOCHD
                else{
                  %>
                    <tr align="left"> 
                       <td  height="22"  align="center" colspan="6" class="side01">***ไม่มีข้อมูล***</td>
                   </tr>
                  <%
                }
                %>
               </table>
</td>
</tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/02Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom2">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/02Corn04.gif" width="5" height="5"></td>
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
<!-- -------------------------------End Block#xx ------------------- -->
<br style="font-size:10pt">
<!-- -------------------------------Block#1 ------------------- -->
<table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item">
                 <input type="checkbox" name="chkQ1" value="01" onClick="JavaScript:doViewAction(this.checked,1);"  
                 <%
                 	if("".equals(chkBox1)||"1".equals(chkBox1)){
                 		out.println("checked");
                 	}
                  %>>
                 <%//งานซ่อมบ้าน
                   if(listNStandard!=null && listNStandard.size()>0){
                   		xstdObj =(SVC_XSTD) listNStandard.get(0);
                   		out.println(doString.DisplayThai(xstdObj.getN_desc()));
                   		%>
                   		<input type="hidden" name="groupName01" value="<%=doString.DisplayThai(xstdObj.getN_desc()) %>">
                   		<%
                   }
                  %>
                </td>
              </tr>
</table>

<div id="job1">
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
        <td height="22" align="right" class="item ; dotline01">&nbsp;หมวด :</td>
        <td height="22" colspan="2"class="dotline01" style="border:0px">
        
        <select  name="jobBannDDL" class="box2" style="width:200px" onChange="javascript:onChangeGroupHomeRepair(this.value);">
		<option value=''>---กรุณาเลือกหมวดงานซ่อม---</option>
        <%
        if(listGHomeRepair!=null && listGHomeRepair.size()>0){
        	String select = "";
			Iterator itGHome = listGHomeRepair.iterator();
			while(itGHome.hasNext()){
				 xstdObj =(SVC_XSTD)itGHome.next();
				 select = "";
				 if(selJobBannDDL.equals(xstdObj.getI_code())){
				  	select= "selected";
				 }
				 	
				 %>
		            <option value="<%=xstdObj.getI_code()%>"  <%=select %>><%=doString.DisplayThai(xstdObj.getN_desc())%></option>
				 <%
			}	 
        }
        %>
        </select>
        
        </td>
        </tr>
      <tr>
        <td width="20%" rowspan="2" align="right" valign="top" class="item ; dotline01">รายละเอียด : </td>
        <td width="40%" height="45" valign="top" class="GoogleCal01">รายละเอียดการแจ้งซ่อม</td>
        <td width="40%" rowspan="2" class="GoogleCal02">
        <%--
        https://www.google.com/calendar/embed?height=260&amp;wkst=1&amp;bgcolor=%23ffffff&amp;src=p093iqnp6676m22cjc2f3v5edg%40group.calendar.google.com&amp;color=%232F6309&amp;ctz=Asia%2FBangkok 
        --%>
        <%
          System.out.println("----->"+GcalendarObj.getReadOnlyUrl());
          System.out.println("----->"+GcalendarObj.getFeedUrl());
          if(!Utilizer.replaceNull(GcalendarObj.getReadOnlyUrl()).equals("")){
         %>
	        <iframe src="<%=GcalendarObj.getReadOnlyUrl() %>" 
	        width="100%" height="250" frameborder="0" style="border:1px solid rgb(170,200,250)"></iframe>
        <%}else{ %>
          &nbsp;
         <%} %>
        </td>
      </tr>
      <tr>
        <td >
        <textarea rows="5" cols="100" name="txtAreaDescJob99" class="boxGoogle" style="width:100% ; height:205px"><%=doString.DisplayThai(txtAreaDescJob99)%></textarea>
        </td>
      </tr>
      <tr>
        <td class="item ; dotline01" height="22" align="right">วันนัดหมาย :</td>
        <td height="22" colspan="2" class="dotline01">
         <select name="dateDDL" 
          onChange="doDepedentDropDown(this,'<%=request.getContextPath() %>/SVC_TimeListXML.jsp')"
           id="dateDDL" class="box2" style="width:200px">
	     <option value="">-- กรุณาระบุวันที่ --</option>   
         <%
        String iDay = "0";
        if(listDateAppoint!=null && listDateAppoint.size()>0){
            List strArr = null; 
            String select = "";
            int x = 0;
			Iterator itDApp = listDateAppoint.iterator();
			while(itDApp.hasNext()){
				 strArr =(ArrayList)itDApp.next();	
				 x = 0;
				 x = Integer.parseInt(strArr.get(1).toString()); //0:2013-10-21   1:2 tu
				 select = "";
				 if(selDateDDL.equals(strArr.get(0).toString())){
				 	select = "selected";
				 	x = Integer.parseInt(strArr.get(1).toString()); //0:2013-10-21   1:2 tu
				 }
				 iDay = ""+x;
				 %>
		            <option value="<%=strArr.get(0)%>" <%=select %>>วัน<%=Utilizer.GetDayOfWeek[x] %>  &nbsp;<%=Utilizer.toDDMMYY_THAI2(strArr.get(0).toString())%></option>
				 <%//<option value="2013-10-08"  >วันอังคาร &nbsp;08/10/2556</option>	
			}	 
        }
        %>
        <input type="hidden" name="iDay" value="<%=iDay %>">
        </select>&nbsp; เวลา &nbsp;
        		<%-- For Ajax writer by jsp/xml file--%>
			    <select name="timeDDL"  id="timeDDL" class="box2" style="width:120px">
	           	 <%if(!"".equals(selTimeDDL)){
	           	    %>
	           	    <option value="<%=selTimeDDL %>" selected><%=selTimeDDL %></option>	
	           	    <%
	           	 }else{
		           	 %>
		           	 <option value="">--กรุณาระบุเวลา-- </option>		
		           	 <%
	           	 }
	           	  %>		     
				</select>
        </td>
      </tr>
     <tr>
        <td class="item ; dotline01" height="22" align="right">&nbsp;</td>
        <td height="22" colspan="2" class="dotline01"><input type="checkbox" name="chkCLS1" value="YES" TITLE="Check กรณีต้องการปิด Job นี้." 
        <%if("YES".equals(chkCLS1)){out.println("checked");} %>> ปิด Job</td>
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
</div>
<!-- -------------------------------End Block#1 ------------------- -->
<br style="font-size:10pt">
<!-- -------------------------------Block#2------------------- -->
<table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item">
                <input type="checkbox" name="chkQ1" value="02" onClick="JavaScript:doViewAction(this.checked,2);"
                <%if("1".equals(chkBox2)){
                	out.println("checked");
                }
                if("CHANGE_DATE".equalsIgnoreCase(mode)){
                    out.println(" disabled");//CASE  เลื่อนนัด
                 }
                 %>
                > งานซ่อมอื่นๆ (งานซ่อมสาธารณูฯ, งานบริการสาธารณะ, ขอคำปรึกษา, ร้องเรียน)</td>
              </tr>
</table>

<div id="job2">
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
				  <td width="20%" valign="top" class="item ; dotline01">
				  <img src="images/no1.gif" width="15" height="15" hspace="5" vspace="5" border="0" align="absmiddle">
				 <%// งานซ่อมสาธารณู
                   if(listNStandard!=null && listNStandard.size()>0){
                   		xstdObj =(SVC_XSTD) listNStandard.get(1);
                   		out.println(doString.DisplayThai(xstdObj.getN_desc()));
                   		%>
                   		<input type="hidden" name="groupName02" value="<%=doString.DisplayThai(xstdObj.getN_desc()) %>">
                   		<%
                   }
                  %>
				  </td>
				    <td width="80%" class="dotline01">&nbsp;</td>
				</tr>
				<tr>
				  <td align="right" valign="top" class="item ; solidline02">รายละเอียด : </td>
				  <td class="solidline02">
				    <textarea rows="5" cols="100" name="txtAreaDescJob1" class="box" style="width:400px"><%=doString.DisplayThai(txtAreaDescJob1) %></textarea>
				  &nbsp; <input type="checkbox" name="chkCLS2" value="YES" TITLE="Check กรณีต้องการปิด Job นี้." 
				  <%if("YES".equals(chkCLS2)){out.println("checked");} %>> ปิด Job</td>
				  </tr>
				<tr>
				  <td valign="top" class="item ; dotline01">
				  <img src="images/no2.gif" width="15" height="15" hspace="5" vspace="5" border="0" align="absmiddle">  
				 <%//งานบริการสาธารณะ
                   if(listNStandard!=null && listNStandard.size()>0){
                   		xstdObj =(SVC_XSTD) listNStandard.get(2);
                   		out.println(doString.DisplayThai(xstdObj.getN_desc()));
                   		%>
                   		<input type="hidden" name="groupName03" value="<%=doString.DisplayThai(xstdObj.getN_desc()) %>">
                   		<%
                   }
                  %>
				  </td>
				  <td class="item ; dotline01">&nbsp;</td>
				  </tr>
				<tr>
				  <td align="right" valign="top" class="item ; dotline01">หมวดสาธารณะ : </td>
				  <td class="dotline01">
				  
				  <select  name="jobPublicDDL2" class="box2" style="width:200px">
                  <option value=''>---กรุณาเลือกหมวดสาธารณะ---</option>
				   <%
			        if(listGPService!=null && listGPService.size()>0){
			        	String select = "";
						Iterator itGS = listGPService.iterator();
						while(itGS.hasNext()){
							 xstdObj =(SVC_XSTD)itGS.next();	
							 select = "";
							 if(selJobPublicDDL2.equals(xstdObj.getI_code())){
							 	select = "selected";
							 }
							 %>
					            <option value="<%=xstdObj.getI_code()%>" <%=select %>><%=doString.DisplayThai(xstdObj.getN_desc())%></option>
							 <%
						}	 
			        }
        		   %>
                    </select>
                    </td>
				  </tr>
				<tr>
				  <td align="right" valign="top" class="item ; solidline02">รายละเอียด :</td>
				  <td class="solidline02">
				  	<textarea rows="5" cols="100" name="txtAreaDescJob2" class="box" style="width:400px"><%=doString.DisplayThai(txtAreaDescJob2) %></textarea>
				  	 &nbsp; <input type="checkbox" name="chkCLS3" value="YES" TITLE="Check กรณีต้องการปิด Job นี้." 
				  	 <%if("YES".equals(chkCLS3)){out.println("checked");} %>> ปิด Job</td>
				  </tr>
				<tr>
				  <td valign="top" class="item ; dotline01"><img src="images/no3.gif" width="15" height="15" hspace="5" vspace="5" border="0" align="absmiddle"> 
				 <%// ขอคำปรึกษา
                   if(listNStandard!=null && listNStandard.size()>0){
                   		xstdObj =(SVC_XSTD) listNStandard.get(3);
                   		out.println(doString.DisplayThai(xstdObj.getN_desc()));
                   		%>
                   		<input type="hidden" name="groupName04" value="<%=doString.DisplayThai(xstdObj.getN_desc()) %>">
                   		<%
                   }
                  %>				  
				  </td>
				  <td class="dotline01">&nbsp;</td>
				  </tr>
				<tr>
				  <td align="right" valign="top" class="item ; solidline02">รายละเอียด :</td>
				  <td class="solidline02">
				    <textarea rows="4" cols="100" name="txtAreaDescJob3" class="box" style="width:400px"><%=doString.DisplayThai(txtAreaDescJob3) %></textarea>
				   &nbsp; <input type="checkbox" name="chkCLS4" value="YES" TITLE="Check กรณีต้องการปิด Job นี้." 
				   <%if("YES".equals(chkCLS4)){out.println("checked");} %>> ปิด Job</td>
				  </tr>
				<tr>
				  <td valign="top" class="item ; dotline01"><img src="images/no4.gif" width="15" height="15" hspace="5" vspace="5" border="0" align="absmiddle">
				<%// ร้องเรียน
                   if(listNStandard!=null && listNStandard.size()>0){
                   		xstdObj =(SVC_XSTD) listNStandard.get(4);
                   		out.println(doString.DisplayThai(xstdObj.getN_desc()));
                   		%>
                   		<input type="hidden" name="groupName05" value="<%=doString.DisplayThai(xstdObj.getN_desc()) %>">
                   		<%
                   }
                  %>
				  </td>
				  <td class=" dotline01">&nbsp;</td>
				  </tr>
				<tr>
				  <td align="right" valign="top" class="item ; dotline01">รายละเอียด :</td>
				  <td class="dotline01"><textarea rows="5" cols="100" name="txtAreaDescJob4" class="box" style="width:400px"><%=doString.DisplayThai(txtAreaDescJob4) %></textarea>
				   &nbsp; <input type="checkbox" name="chkCLS5" value="YES" TITLE="Check กรณีต้องการปิด Job นี้." 
				   <%if("YES".equals(chkCLS5)){out.println("checked");} %>> ปิด Job</td>
				</tr>
				
				<tr>
				<td valign="top" class="item ; dotline01"><img src="images/no5.gif" width="15" height="15" hspace="5" vspace="5" border="0" align="absmiddle">
				<%// อื่นๆ
                   if(listNStandard!=null && listNStandard.size()>0){
                   		xstdObj =(SVC_XSTD) listNStandard.get(5);
                   		out.println(doString.DisplayThai(xstdObj.getN_desc()));
                   		%>
                   		<input type="hidden" name="groupName06" value="<%=doString.DisplayThai(xstdObj.getN_desc())%>">
                   		<%
                   }
                  %>
				  </td>
				  <td class=" dotline01">&nbsp;</td>
				  </tr>

				<tr>
				  <td align="right" valign="top" class="item ; dotline01">รายละเอียด :</td>
				  <td class="dotline01"><textarea rows="5" cols="100" name="txtAreaDescJob5" class="box" style="width:400px"><%=doString.DisplayThai(txtAreaDescJob5) %></textarea>
				   &nbsp; <input type="checkbox" name="chkCLS6" value="YES" TITLE="Check กรณีต้องการปิด Job นี้." 
				   <%if("YES".equals(chkCLS6)){out.println("checked");} %>> ปิด Job</td>
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

</div>
<!-- -------------------------------End Block#2 ------------------- -->

<br style="font-size:30pt">

    <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="230" class="act_tab2">
			<!-- button krub -->
			 <a href="javascript:doSubmitPreview();"><img border="0" src="images/act_PreviewAndSave.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp;
				<a href="javascript:doADD();"><img border="0" src="images/act_reset.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a> </td>
            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="/LHServ/SERV_Staff_List.jsp"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="/LHServ/SERV_Index.jsp" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
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
<%-- 
	</td>
  </tr>
</table>
--%>

</FORM>
</BODY>
</HTML>
