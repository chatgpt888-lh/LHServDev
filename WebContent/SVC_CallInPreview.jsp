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
 * date time: 2013.10.18
 * Last modify :
 * version :1.0
 * project Name :Service Center 
 * description : 
 -Preview Form
 ***************************************************/
 //****************************************
String ParameterNames = "";
for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
	ParameterNames = (String)e.nextElement();
	System.out.println(ParameterNames + " = "+request.getParameter(ParameterNames));
}
System.out.println("*******************************************");
 
 	String projectSel  = doString.checkString(request.getParameter("projectDDL"),"");//LH:075
 	String tel = doString.checkString(request.getParameter("tel"),"");
	String agentId = doString.checkString(request.getParameter("agentId"),"");
	String houseNo = doString.checkString(request.getParameter("houseNoTxt"),"");
    String lock = doString.checkString(request.getParameter("lockTxt"),""); //LH:075
    String employName = doString.checkString(request.getParameter("employName"),"");
    String employId = doString.checkString(request.getParameter("employId"),""); 
	String mode = doString.checkString(request.getParameter("mode"),""); 

	//***************************************************
	String customerId = doString.checkString(request.getParameter("customerId"),"");
	String model = doString.checkString(request.getParameter("model"),"");
	String cPrefix = doString.checkString(request.getParameter("cPrefix"),"");
	String cFname = doString.checkString(request.getParameter("cFname"),"");
	String cLname = doString.checkString(request.getParameter("cLname"),"");
	String cTelNo = doString.checkString(request.getParameter("cTelNo"),"");
	String flagGuranteeDate = doString.checkString(request.getParameter("flagGuranteeDate"),"");
	String dateGurantee = doString.checkString(request.getParameter("dateGurantee"),"");
	String agentName = doString.checkString(request.getParameter("agentName"),"");
	//---------------------------
	//For เลื่อนนัด from preview&Edit
	//String chngMode	=  request.getAttribute("chngMode")==null?"":request.getAttribute("chngMode").toString();//form EditAction CHANGE_DATE
	String docNo	=doString.checkString(request.getParameter("docNo"),"");
	String type	=	doString.checkString(request.getParameter("type"),"");
	String code	=	doString.checkString(request.getParameter("code"),"");
	String fdate	=doString.checkString(request.getParameter("fdate"),"");
	String fstatus	=doString.checkString(request.getParameter("fstatus"),"");  
	String gEventId  =  doString.checkString(request.getParameter("gEventId"),""); 

	//***************************************************
	String gCalendarId = doString.checkString(request.getParameter("i_prjcal_id"),"");
	String gMail = doString.checkString(request.getParameter("i_gmail"),"");
	String gPassword = doString.checkString(request.getParameter("i_password"),"");
	String gfeedUrl = doString.checkString(request.getParameter("feedUrl"),"");
	String gReadOnlyUrl = doString.checkString(request.getParameter("ReadOnlyUrl"),"");

	//********************************************************************************
	String chkEdit =  doString.checkString(request.getParameter("chkEdit"),""); //YES
	String chkCLS1 =  doString.checkString(request.getParameter("chkCLS1"),""); //YES
	String chkCLS2 =  doString.checkString(request.getParameter("chkCLS2"),""); //YES
	String chkCLS3 =  doString.checkString(request.getParameter("chkCLS3"),""); //YES
	String chkCLS4 =  doString.checkString(request.getParameter("chkCLS4"),""); //YES
	String chkCLS5 =  doString.checkString(request.getParameter("chkCLS5"),""); //YES
	String chkCLS6 =  doString.checkString(request.getParameter("chkCLS6"),""); //YES
	
	//**********For keyin 
	String customerTxt = doString.checkString(request.getParameter("txt1"),"");
	String mobileTxt1 = doString.checkString(request.getParameter("txt2"),"");
	String mobileTxt2 = doString.checkString(request.getParameter("txt3"),"");
	String emailTxt = doString.checkString(request.getParameter("txt4"),"");
	String mobileTxt0 = doString.checkString(request.getParameter("txt5"),"");
	
   if(!"YES".equals(chkEdit)){//case Edit
		customerTxt = cPrefix+" "+cFname+"     "+cLname;
		mobileTxt1 = tel;
	}
	//---------------------------------------------------------------
	//For Key input form krub
	String checkGroup [] = request.getParameterValues("chkQ1");
	//--------------------------------------------------------------
	Object  objProject  = session.getAttribute(Constant.SS_PROJECT_AVAILABLE_LIST);
	Object  objGHomeRepair = session.getAttribute(Constant.SS_GHOME_REPAIR_LIST);
    Object  objGPService   = session.getAttribute(Constant.SS_GPUBLIC_SERVICE_LIST);
	ArrayList   listProject = null;
    ArrayList   listGHomeRepair  = null;
    ArrayList   listGPService  = null;
	
	if(objProject!=null){ listProject = (ArrayList)objProject;
	}else{  listProject = new ArrayList();}
	
	if(objGHomeRepair!=null){  listGHomeRepair = (ArrayList)objGHomeRepair;
	}else{ listGHomeRepair = new ArrayList();}
	
	if(objGPService!=null){ listGPService = (ArrayList)objGPService;
	}else{  listGPService = new ArrayList();}
	 %>
<HTML>
<HEAD>
<TITLE>Service Center Infrom Preview</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
<!--
function doEdit(){
	<%
	 if("CHANGE_DATE".equals(mode)){
	 	%>
	 	 document.forms[0].chngMode.value = "CHANGE_DATE";
	 	<%
	 }else{
	 	%>
	 	document.forms[0].chngMode.value = "<%=mode%>";
	 	<%
	 }%>
	document.forms[0].mode.value = "edit";
	document.forms[0].action="<%=request.getContextPath() %>/SVCInformController.do?cmd=submit";
	document.forms[0].submit();
}
function doSave(){
	<%
	  if("CHANGE_DATE".equals(mode)){
	 	%>
	 	 document.forms[0].mode.value = "CHANGE_DATE";
	 	 //document.forms[0]..value = "CHANGE_DATE";
	 	<%
	 }else{
	 	%>
	 	document.forms[0].mode.value = "save";
	 	<%
	 }%>
	document.forms[0].action="<%=request.getContextPath() %>/SVCInformController.do?cmd=submit";
	document.forms[0].submit();
}
//-->
</script>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" >

<FORM METHOD="POST" ACTION="">
<input type="hidden" name="mode" value="">
<input type="hidden" name="chngMode" value="">
<input type="hidden" name="tel" id="tel" value="<%=tel %>">
<input type="hidden" name="agentId" id="agentId" value="<%=agentId %>">
<input type="hidden" name="projectDDL" id="projectDDL" value="<%=projectSel %>">
<input type="hidden" name="houseNoTxt" id="houseNo" value="<%=houseNo %>">
<input type="hidden" name="lockTxt" id="lock" value="<%=lock %>">
<input type="hidden" name="employName"  value="<%=doString.DisplayThai(employName) %>">
<input type="hidden" name="employId"  value="<%=employId %>">
<input type="hidden" name="chkEdit"  value="<%=chkEdit %>">
<input type="hidden" name="chkCLS1"  value="<%=chkCLS1 %>">
<input type="hidden" name="chkCLS2"  value="<%=chkCLS2 %>">
<input type="hidden" name="chkCLS3"  value="<%=chkCLS3 %>">
<input type="hidden" name="chkCLS4"  value="<%=chkCLS4 %>">
<input type="hidden" name="chkCLS5"  value="<%=chkCLS5 %>">
<input type="hidden" name="chkCLS6"  value="<%=chkCLS6 %>">

<%-- For  Post Pone A date เลื่อนนัด  process --%>
<input type="hidden" name="docNo" id="docNo" value="<%=docNo %>">
<input type="hidden" name="type" id="type" value="<%=type%>">
<input type="hidden" name="code" id="code" value="<%=code%>">
<input type="hidden" name="fdate" id="fdate" value="<%=fdate%>">
<input type="hidden" name="fstatus" id="fstatus" value="<%=fstatus%>">
<input type="hidden" name="gEventId" id="gEvent_id" value="<%=gEventId%>">

<%-- For customer --%>
<input type="hidden" name="customerId"  value="<%=customerId%>">
<input type="hidden" name="model"  value="<%=model %>">
<input type="hidden" name="cPrefix"  value="<%=doString.DisplayThai(cPrefix) %>">
<input type="hidden" name="cFname"  value="<%=doString.DisplayThai(cFname) %>">
<input type="hidden" name="cLname"  value="<%=doString.DisplayThai(cLname) %>">
<input type="hidden" name="cTelNo"  value="<%=cTelNo %>">
<input type="hidden" name="flagGuranteeDate"  value="<%=flagGuranteeDate %>">
<input type="hidden" name="dateGurantee"  value="<%=dateGurantee %>">
<input type="hidden" name="agentName"  value="<%=agentName %>">

<%-- For customer Edit--%>
<input type="hidden" name="chkEdit"  value="<%=chkEdit%>">
<input type="hidden" name="customerTxt"  value="<%=doString.DisplayThai(customerTxt)%>">
<input type="hidden" name="mobileTxt1"  value="<%=mobileTxt1%>">
<input type="hidden" name="mobileTxt2"  value="<%=mobileTxt2%>">
<input type="hidden" name="emailTxt"  value="<%=emailTxt%>">
<input type="hidden" name="mobileTxt0"  value="<%=mobileTxt0%>">

<%-- For Gmail Calendar --%>
<input type="hidden" name="gCalendarId"  value="<%=gCalendarId%>">
<input type="hidden" name="gMail"  value="<%=gMail%>">
<input type="hidden" name="gPassword"  value="<%=gPassword%>">
<input type="hidden" name="gfeedUrl"  value="<%=gfeedUrl%>">
<input type="hidden" name="gReadOnlyUrl"  value="<%=gReadOnlyUrl%>">
<%-- For GCalendar--%>

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
    <td width="12%" height="22" class="item ; dotline01">โครงการ :</td>
    <td width="40%" height="22" class="dotline01"><%=projectSel %> | <%=Utilizer.getLableProject(listProject,projectSel) %></td>
    <td width="14%" height="22" class="item ; dotline01">เลขที่อ้างอิง  :</td>
    <td width="34%" height="22" class="dotline01">[ Auto Generate ]</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22">บ้านเลขที่ :</td>
    <td height="22" class="dotline01"><%=houseNo %></td>
    <td height="22" class="item ; dotline01">แปลง :</td>
    <td height="22" class="dotline01"><%=lock %></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22">แบบบ้าน :</td>
    <td height="22" class="dotline01"><%=model %></td>
    <td height="22" class="item ; dotline01">&nbsp;</td>
    <td height="22" class="dotline01">&nbsp;</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22">ชื่อลูกค้า:</td>
    <td height="22" class="dotline01"><%=doString.DisplayThai(cPrefix)%> <%=doString.DisplayThai(cFname) %>&nbsp;&nbsp;&nbsp;<%=doString.DisplayThai(cLname) %></td>
    <td height="22" class="item ; dotline01">โทรศัพท์ติดต่อ :</td>
    <td height="22" class="dotline01"><%=cTelNo %></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22">การประกัน :</td>
    <td height="22" class="dotline01">
     &nbsp;<%
       if("N".equals(flagGuranteeDate)){
        	out.println("หมดประกัน");
       }else  if("Y".equals(flagGuranteeDate)) {
           out.println("อยู่ระหว่างประกัน");
       }
     %>
    </td>
    <td height="22" class="item ; dotline01">วันที่หมดประกัน :</td>
    <td height="22" class="dotline01">&nbsp;
    <%=dateGurantee %></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22">ผู้รับเรื่อง :</td>
    <td height="22" class="dotline01"><%=agentName %></td>
    <td height="22" class="item ; dotline01">วันเวลาที่แจ้ง :</td>
    <td height="22" class="dotline01"><%=Utilizer.ThisToDay() %>&nbsp;<%=Utilizer.ThisCalendarTimeNow(Calendar.getInstance()) %> น.</td>
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
<!-- -------------------------------Block#1 ------------------- -->

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
        <td align="left" valign="top">
       
<table width="100%" height="28" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td class="GoogleCal01" style="border-bottom:1px solid rgb(170,200,250)">รายละเอียดการแจ้งซ่อม</td>
  </tr>
</table>
       
        
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr height="22">
    <td width="15%" class="item ; dotline01">ชื่อ-สกลุผู้แจ้ง :</td>
    <td class="dotline01"><%=doString.DisplayThai(customerTxt) %></td>
    <td class="item ; dotline01">เบอร์โทร 1 :</td>
    <td class="dotline01"><%=tel %></td>
    <td class="item ; dotline01">เบอร์โทร 2 :</td>
    <td class="dotline01"><%=mobileTxt2 %>
    <%
    /*if(!"".equals(mobileTxt0)&&!"".equals(mobileTxt2)){
    	out.println(","+mobileTxt0);
    }else{
    	out.println(mobileTxt0);
    }*/
     %>
    </td>
  </tr>
</table>

<%
String groupName01 =  doString.checkString(request.getParameter("groupName01"),""); 
String groupName02 =  doString.checkString(request.getParameter("groupName02"),""); 
String groupName03 =  doString.checkString(request.getParameter("groupName03"),""); 
String groupName04 =  doString.checkString(request.getParameter("groupName04"),""); 
String groupName05 =  doString.checkString(request.getParameter("groupName05"),""); 
String groupName06 =  doString.checkString(request.getParameter("groupName06"),""); 

String jobBannDDL =  doString.checkString(request.getParameter("jobBannDDL"),""); 
String dateDDL = doString.checkString(request.getParameter("dateDDL"),""); 
String iDay =  doString.checkString(request.getParameter("iDay"),"0"); 
String timeDDL = doString.checkString(request.getParameter("timeDDL"),""); 
String jobPublicDDL2 = doString.checkString(request.getParameter("jobPublicDDL2"),""); 
//********************************Parameter CASE :2
String txtAreaDescJob99 = doString.checkString(request.getParameter("txtAreaDescJob99"),""); 
String txtAreaDescJob1 = doString.checkString(request.getParameter("txtAreaDescJob1"),""); 
String txtAreaDescJob2 = doString.checkString(request.getParameter("txtAreaDescJob2"),""); 
String txtAreaDescJob3 = doString.checkString(request.getParameter("txtAreaDescJob3"),""); 
String txtAreaDescJob4 = doString.checkString(request.getParameter("txtAreaDescJob4"),""); 
String txtAreaDescJob5 = doString.checkString(request.getParameter("txtAreaDescJob5"),""); 
%>
<input type="hidden" name="jobBannDDL"  value="<%=jobBannDDL %>">
<input type="hidden" name="dateDDL"  value="<%=dateDDL %>">
<input type="hidden" name="timeDDL"  value="<%=timeDDL %>">
<input type="hidden" name="jobPublicDDL2"  value="<%=jobPublicDDL2 %>">

<input type="hidden" name="txtAreaDescJob99"  value="<%=doString.DisplayThai(txtAreaDescJob99) %>">
<input type="hidden" name="txtAreaDescJob1"  value="<%=doString.DisplayThai(txtAreaDescJob1) %>">
<input type="hidden" name="txtAreaDescJob2"  value="<%=doString.DisplayThai(txtAreaDescJob2) %>">
<input type="hidden" name="txtAreaDescJob3"  value="<%=doString.DisplayThai(txtAreaDescJob3) %>">
<input type="hidden" name="txtAreaDescJob4"  value="<%=doString.DisplayThai(txtAreaDescJob4) %>">
<input type="hidden" name="txtAreaDescJob5"  value="<%=doString.DisplayThai(txtAreaDescJob5) %>">
<%

boolean isDisplay = false;
if(checkGroup.length==2){
    //----------------CASE : 01
 	if("01".equals(checkGroup[0])){//CASE:01 CHECK
 	   isDisplay = true;
 	   System.out.println("----Select #2, case 1");
  %>
    <!-- item01 -->
     <input type="hidden" name="chkBox1"  value="1">
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
	    <td class="bigh ; dotline01" style="padding:15px 0px 0px 0px">
	    <img src="images/no1.gif" hspace="5" border="0" align="absmiddle"><%=doString.DisplayThai(groupName01) %>
	    &nbsp;&nbsp;&nbsp;
	    <%if("YES".equals(chkCLS1)) {%>
	    	 <img border="0" src="images/i_pass.gif" align="absmiddle" width="19" height="16">&nbsp;ปิด Job
	     <%} %></td>
	    </tr>
	</table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr height="22">
	    <td width="20%" class="item ; dotline01" style="padding-left:25px">หมวด :</td>
	    <td class="dotline01"><%=doString.DisplayThai(groupName01) %>
	    </td>
	  </tr>
	  <tr height="22">
	    <td class="item ; dotline01" style="padding-left:25px">รายละเอียด :</td>
	    <td class="dotline01"><%=doString.DisplayThai(txtAreaDescJob99) %></td>
	  </tr>
	  <%
	  if("01".equals(jobBannDDL) || "05".equals(jobBannDDL)){
	  	// <font class="item" style="padding:0px 5px 0px 5px ">ถึง</font>16:00	
	  %>
		  <tr height="22">
		    <td class="item ; solidline04" style="padding-left:25px">วันนัดหมาย :</td>
		    <td class="solidline04">
		    <font class="item" style="padding:0px 10px 0px 0px ">วัน<%=Utilizer.GetDayOfWeek[Integer.parseInt(iDay)] %>  </font><%=Utilizer.toDDMMYY_THAI2(dateDDL) %>  
		    <font class="item" style="padding:0px 5px 0px 10px ">เวลา :</font><%=timeDDL %> </td>
		  </tr>
	  <% }%>
	</table>
	<!-- item01 end -->  
 	<%
 	}
 	//---------------CASE : 02
 	if("02".equals(checkGroup[1])){
 		//TODO:************************
 		%>
 		<input type="hidden" name="chkBox2"  value="1">
 		<%
 		 System.out.println("----Select #2, case 2");
 		int number= 0;
 		if(isDisplay){
 		    number= 2;
 		}else{
 		    number=1;
 		}
 		//String groupName,String desc,String nameDDL,boolean isDDL,int number
 		if(!"".equals(txtAreaDescJob1)){
 			out.println(Utilizer.GenDisplayTableHTML(groupName02,txtAreaDescJob1,"",chkCLS2,false,number++));
 		}
 		if(!"".equals(txtAreaDescJob2)){
 		   String lable = Utilizer.getLableNameList(listGPService,jobPublicDDL2);
 		   out.println(Utilizer.GenDisplayTableHTML(groupName03,txtAreaDescJob2,lable,chkCLS3,true,number++));
 		}
 		if(!"".equals(txtAreaDescJob3)){
 		   out.println(Utilizer.GenDisplayTableHTML(groupName04,txtAreaDescJob3,"",chkCLS4,false,number++));
 		}
 		if(!"".equals(txtAreaDescJob4)){
 		    out.println(Utilizer.GenDisplayTableHTML(groupName05,txtAreaDescJob4,"",chkCLS5,false,number++));
 		}
 		if(!"".equals(txtAreaDescJob5)){
 		     out.println(Utilizer.GenDisplayTableHTML(groupName06,txtAreaDescJob5,"",chkCLS6,false,number++)); 
 		}

 	}//#End case 02
 }else{
 isDisplay = false;
 //CASE ELSE FOR CHECK LENGHT || CHECK BOX '1'  or '2' 
 if("01".equals(checkGroup[0])){//CASE:01 CHECK
   isDisplay = true;
    System.out.println("---------TEST Select #1#1----------");
 %>
 <!-- item01 -->
    <input type="hidden" name="chkBox1"  value="1">
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
	    <td class="bigh ; dotline01" style="padding:15px 0px 0px 0px">
	    <img src="images/no1.gif" hspace="5" border="0" align="absmiddle"><%=doString.DisplayThai(groupName01) %>
	    &nbsp;&nbsp;&nbsp;
	    <%if("YES".equals(chkCLS1)) {%>
	    	 <img border="0" src="images/i_pass.gif" align="absmiddle" width="19" height="16">&nbsp;ปิด Job
	     <%} %>
	    </td>
	    </tr>
	</table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr height="22">
	    <td width="20%" class="item ; dotline01" style="padding-left:25px">หมวด :</td>
	    <td class="dotline01"><%=Utilizer.getLableNameList(listGHomeRepair,jobBannDDL) %></td>
	  </tr>
	  <tr height="22">
	    <td class="item ; dotline01" style="padding-left:25px">รายละเอียด :</td>
	    <td class="dotline01"><%=doString.DisplayThai(txtAreaDescJob99)%></td>
	  </tr>
	  <%
	  if("01".equals(jobBannDDL) || "05".equals(jobBannDDL)){
	  	// <font class="item" style="padding:0px 5px 0px 5px ">ถึง</font>16:00	
	  %>
		  <tr height="22">
		    <td class="item ; solidline04" style="padding-left:25px">วันนัดหมาย :</td>
		    <td class="solidline04">
		    <font class="item" style="padding:0px 10px 0px 0px ">วัน<%=Utilizer.GetDayOfWeek[Integer.parseInt(iDay)] %>  </font><%=Utilizer.toDDMMYY_THAI2(dateDDL) %>  
		    <font class="item" style="padding:0px 5px 0px 10px ">เวลา :</font><%=timeDDL %> </td>
		  </tr>
	  <% }%>
	</table>
<!-- item01 end -->  
<% }//#End if CASE:1
   if("02".equals(checkGroup[0])){
   		//TODO:************************
   		%>
 		<input type="hidden" name="chkBox2"  value="1">
 		<%
   		 System.out.println("---------TEST Select #1#2----------");
 		int number= 0;
 		if(isDisplay){
 		    number= 2;
 		}else{
 		    number=1;
 		}
 		//String groupName,String desc,String nameDDL,boolean isDDL,int number
 		if(!"".equals(txtAreaDescJob1)){
 			out.println(Utilizer.GenDisplayTableHTML(groupName02,txtAreaDescJob1,"",chkCLS2,false,number++));
 		}
 		if(!"".equals(txtAreaDescJob2)){
 		   String lable = Utilizer.getLableNameList(listGPService,jobPublicDDL2);
 		   out.println(Utilizer.GenDisplayTableHTML(groupName03,txtAreaDescJob2,lable,chkCLS3,true,number++));
 		}
 		if(!"".equals(txtAreaDescJob3)){
 		      out.println(Utilizer.GenDisplayTableHTML(groupName04,txtAreaDescJob3,"",chkCLS4,false,number++));
 		}
 		if(!"".equals(txtAreaDescJob4)){
 		       out.println(Utilizer.GenDisplayTableHTML(groupName05,txtAreaDescJob4,"",chkCLS5,false,number++));
 		}
 		if(!"".equals(txtAreaDescJob5)){
 		     out.println(Utilizer.GenDisplayTableHTML(groupName06,txtAreaDescJob5,"",chkCLS6,false,number++));
 		}
   }//#End if CASE:2
 }//#End if lenght
 %> 
        </td>
        <%
          if(!"".equals(gReadOnlyUrl)){
         %>
             <td width="40%" class="GoogleCal02" valign="top" height="250">
		        <iframe src="<%=gReadOnlyUrl %>" 
		        width="100%" height="250" frameborder="0" style="border:1px solid rgb(170,200,250)"></iframe>
	        </td>
        <%}else{ %>
          &nbsp;
         <%} %>     
      </tr>
    </table></td>
  </tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>

<!-- -------------------------------End Block#1 ------------------- -->

<br style="font-size:10pt">

    <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="160" class="act_tab2">
			<!-- button krub -->
			 <a href="javascript:doEdit();"><img border="0" src="images/act_edit.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp;	
                  	<a href="javascript:doSave();"><img border="0" src="images/act_submit.gif"                                   
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

<!--  
</td>
</tr>
</table>
-->

</FORM>
</BODY>
</HTML>
