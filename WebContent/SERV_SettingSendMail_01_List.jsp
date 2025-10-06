<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="java.util.*" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%@page import="java.text.SimpleDateFormat" %>
<%-- 
/**********************************************/
 * create by : pradoem wonkraso
 * date time: 2016.08.06
 * Last modify :
 * version :1.0
 * project Name : 
 * description : 
***************************************************/
--%>
<%!

private static String GetSysTypeName(ArrayList ssTypeList,String args){
	 String retStr = "";
	 try{
	 	 if ((args == null) || args.equals("")) {
			 return args;
		}else{
		 	 if(ssTypeList!=null && ssTypeList.size()>0){
		        Iterator it = ssTypeList.iterator();   
		        HashMap hashMap = null;	
		        while(it.hasNext()){	    		    	
				    hashMap = (HashMap)it.next();
				    if(hashMap.get("TYPE_CODE").toString().equals(args)){
				    	retStr = hashMap.get("TYPE_NAME").toString();
				    	break;
				    }
			    }
			}
		  return retStr;		
		}
	 }catch(Exception e){
	 	e.printStackTrace();
	 	return retStr;
	 }
}

private static String GetSubSysTypeName(ArrayList ssTypeList,String args){
	 String retStr = "";
	 try{
	 	 if ((args == null) || args.equals("")) {
			 return args;
		}else{
		 	 if(ssTypeList!=null && ssTypeList.size()>0){
		        Iterator it = ssTypeList.iterator();   
		        HashMap hashMap = null;
		        String val = "";	
		        while(it.hasNext()){	    		    	
				    hashMap = (HashMap)it.next();
				    val = doString.checkString(hashMap.get("TYPE_CODE").toString())+":"+doString.checkString(hashMap.get("TYPE_SUB").toString());
				    if(val.equals(args)){
				    	retStr = hashMap.get("TYPE_NAME").toString();
				    	break;
				    }
			    }
			}
		  return retStr;		
		}
	 }catch(Exception e){
	 	e.printStackTrace();
	 	return retStr;
	 }
}



private static String GetDisplayEmail(String args){
	 String temp = "";
	 try{
	 	 if ((args == null) || args.equals("")) {
			 return args;
		}else{
			temp = ", "+args;
		 }
	 }catch(Exception e){
	 	e.printStackTrace();
	 }
	 return temp;
}

 %>
<%

//*****************************************
  ArrayList projectList = (ArrayList)session.getAttribute("SS_projectList");
  ArrayList jobTypeList = (ArrayList)session.getAttribute("SS_typeCategory");
  ArrayList resultList = null;
  
    ArrayList listSubCategory =(ArrayList)request.getAttribute("listTypeCategory"); //dddd

  ArrayList typeSubCategory = (ArrayList)request.getAttribute("typeSubCategory");


 Object objResult = request.getAttribute("resultHashList");
 List resultHashList = null;
 if(objResult!=null){
    resultHashList = (List)objResult;
 }else{
    resultHashList = new ArrayList();
 }

String projectDDL	 = request.getAttribute("projectDDL")==null?"": request.getAttribute("projectDDL").toString();//LH:075
String employ	 = request.getAttribute("employ")==null?"": request.getAttribute("employ").toString();//LH:075
String jobTypeDDL = request.getAttribute("jobTypeDDL")==null?"":request.getAttribute("jobTypeDDL").toString();

 %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
<TITLE>ข้อมูลพื้นฐาน-กำหนดสายงานรับผิดชอบสำหรับรับ Email</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">


<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<style type="text/css">
 .box2 {  font-family: Tohama,Arial,sans-serif; font-size:10.1pt; font-weight:normal;
		padding-top: 1px; padding-right: 1px; padding-bottom: 1px; padding-left: 1px; 
	 	color:#165396; background-color: white; border: 1px #BEDCFF solid ; 
}
td.dotlineWhite{
	 color: rgb(255,255,255) ;	
	 border-bottom:1px dotted rgb(220,220,220)	;
	 border-right:1px solid rgb(135,185,247) ; 
	 padding:3px ; mso-number-format:"\@";  }
	 
	 
.select2-selection__rendered {
  	font-family: Tohama, Arial, sans-serif;
    font-size: 10.1pt;
    color: #165396 !important;
}


.select2-results__option {
    font-family: Tohama, Arial, sans-serif;
    font-size: 10.1pt;
    color: #165396 !important;
}    
</style>
<script type='text/javascript' src='jquery/loadImg.js'></script>
<script language="javascript" src="script_fx.js"></script>
<script type="text/javascript" src="eserv_paging.js"></script>
<script type="text/javascript" >


$(document).ready(function() {
     $('#projectSelect').select2({
        matcher: function(params, data) {
            if ($.trim(params.term) === '') {
                return data;
            }

            var searchTerm = params.term.trim().toLowerCase().replace(/:/g, '');
            var optionText = (data.text || '').toLowerCase().replace(/:/g, '');

            if (optionText.indexOf(searchTerm) > -1) {
                return data;
            }

            return null; 
        }
    });
});

function initFormX(){
  try{
      var e = $('#page');
      /*document.getElementById('page');*/
      /*e.style.display == 'block'*/
       e.style.visibility = 'hidden';
	  }catch(err) {
	   /* document.getElementById("demo").innerHTML = err.message;*/
	   //alert(err.message);
	}    
 }
 
function onPleaseWait(){
	document.all.pleasewaitScreen.style.pixelTop = (document.body.scrollTop + 120);
	$('#pleasewaitScreen').show();
	setTimeout(function(){  $('#pleasewaitScreen').css("visibility", 'hidden'); }, 7000); //wait 7 seconds
	$('#pleasewaitScreen').css('visibility', 'visible');
 }
  
function doSearch(){
	if($('select[name=projectDDL] option:selected').val()!='' ||
	   $('select[name=jobTypeDDL] option:selected').val()!='' ||
	   $('input[name=employ]').val()!='' ){
    	onPleaseWait();
	    document.forms[0].action="<%=request.getContextPath()%>/SERV_SettingSendMailServlet?cmd=search";
	    document.forms[0].submit();
    }else{

	    alert(" กรุณาเลือกเงื่อนไขการค้นหาอย่างน้อย 1 เงื่อนไข !");
		$('select[name=projectDDL]').focus();
		return;
    }
}

function doAdd(){
	document.forms[0].action="<%=request.getContextPath()%>/SERV_SettingSendMailServlet?cmd=formAdd1";
	document.forms[0].submit();
}

function doDelete(comId,typeCode) {
     var temp = comId+" , "+typeCode;
	 if(confirm("คุณต้องการลบข้อมูลรหัสโครงการ '"+temp+"' ใช่หรือไม่?")==true){
	     document.forms[0].projectDelete.value=comId; //LH
         document.forms[0].jobTypeDelete.value=typeCode; //01:03
		 //validate from client side
		  onPleaseWait();
		 document.forms[0].action="<%=request.getContextPath()%>/SERV_SettingSendMailServlet?cmd=delete";
		 document.forms[0].submit();
	}
}

function goUpdate(comId,typeCode) {
     var temp = comId+" , "+typeCode;
	 
	     document.forms[0].projectDelete.value=comId; //LH
         document.forms[0].jobTypeDelete.value=typeCode; //01:03
		 //validate from client side
		  onPleaseWait();
		 document.forms[0].action="<%=request.getContextPath()%>/SERV_SettingSendMailServlet?cmd=edit";
		 document.forms[0].submit();
	
}

function isNumber(evt) {
       var theEvent = evt || window.event;
       var key = theEvent.keyCode || theEvent.which;
       key = String.fromCharCode(key);
       if (key.length == 0) return;
          var regex = /^[0-9\-]+$/;
          //var regex = /^[0-9.,\b]+$/;
          if (!regex.test(key)) {
              theEvent.returnValue = false;
              if (theEvent.preventDefault) theEvent.preventDefault();
       }
}

function doReset(){
  document.getElementById("myForm").reset();
}

function doSubmit(){
    onPleaseWait();
 	doSubmitForm("<%=Constants.APP_PATH%>/SERV_SettingSendMailServlet?cmd=submit");		
}
function doSubmitForm(url){
 	$('form').attr('action', url);
	$("form:first").submit();
}

function GetDynamicDropdown(val) {
	//var mainDDLx = $('select[name="mainDDL"] option:selected').val();
	$.ajax({
	type: "POST",
	url: "<%=Constants.APP_PATH%>/SERV_SettingSendMailServlet?cmd=onchangeItems",
	data: 'jobTypeDDL='+val,
	success: function(data){
		$("#jobSubDDL").html(data);
	  }
	});
}

</script>
<style type="text/css">    
            .pg-normal {
                font-size:14px;
                color: #20a6f4;
                font-weight: normal;
                text-decoration: none;    
                cursor: pointer;    
            }
            .pg-selected {
               font-size:1.875em;
                color: #fe8002;
                font-weight: bold;        
                text-decoration: underline;
                cursor: pointer;
            }
            
 </style>
 <style type="text/css">
	A:link {text-decoration: none}
	A:visited {text-decoration: none}
	A:active {text-decoration: none}
	A:hover {text-decoration: underline; color: red;}
</style>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="initFormX()">
<form action="" name="frm" method="POST">
<input type="hidden" name="projectDelete">
<input type="hidden" name="jobTypeDelete">

<!-- ##########################################  rgb(255,120,0)-->
<DIV ID="pleasewaitScreen" STYLE="position: absolute; z-index: 0; top: 45%; left: 42%; display: none;">
<TABLE BORDER="1" BORDERCOLOR="rgb(180,210,250)" CELLPADDING="0" CELLSPACING="0" 
HEIGHT="125px" WIDTH="265px" ID="Table1">
	<TR>
	<TD BGCOLOR="#FFFFFF" ALIGN="CENTER" VALIGN="MIDDLE" class="test">
	<font  style="font-family:Tahoma,Arial,sans-serif; color:rgb(112,112,112); font-size:2.0em;" ><b>Loading... Please wait</b></font>
	<br>
	<br>
	  <span id="img1">
	   <img src="<%=request.getContextPath()%>/images/loading2.GIF" HEIGHT="64px">
	  </span>
	</TD> 
	</TR>
</TABLE>
</DIV>
<!-- ########################################## -->

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">
          &nbsp;ข้อมูลพื้นฐาน-กำหนดสายงานรับผิดชอบสำหรับรับ Email</td>
        </tr>
      </table>
<br style="font-size:10pt">              
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">Form Search : เงื่อนไขการค้นหา</td>
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
    <td class="item ; dotline01" height="22" width="12%">โครงการ :</td>
    <td height="22" width="88%" class="dotline01">
     <select id="projectSelect" size="1" name="projectDDL"  class="box2" style="width:280">
			<option value="">------ กรุณาเลือกโครงการ ------</option>
		  <%
			   if(projectList!=null && projectList.size()>0){			   		      
			   		HashMap  hashMap = null;
					Iterator it = projectList.iterator();
					String strValue = "";
					String strName = "";
					String selected = "";
					while(it.hasNext()){
							hashMap = (HashMap)it.next();
							strValue = ""; 
							strName = "";	
							strValue = hashMap.get("value").toString(); 
							strName = hashMap.get("pj_name").toString();
							selected = "";
						  if(strValue.equals(projectDDL)){
							   selected = " selected ";
						  } 
						%>
							<option value="<%=strValue%>"  <%=selected %>><%=strValue%> - <%=strName%></option>
						<%}
				} %>	       
			</select>
     </td>
    </tr>
     <tr>
    <td class="item ; dotline01" height="22" width="12%">ประเภทงานซ่อม :</td>
    <td height="22" width="88%" class="dotline01">
    	<select size="1" class="box2" style="width:280px" name="jobTypeDDL" onchange="javascript:GetDynamicDropdown(this.value);"  >
        <option value=''>---กรุณาเลือกประเภทงานซ่อม---</option>
        <%
        if(jobTypeList!=null && jobTypeList.size()>0){
        	String selected = "";
        	Iterator it = jobTypeList.iterator();   
        	HashMap hashMap = null;		
        	while(it.hasNext()){	    		    	
		    	hashMap = (HashMap)it.next();
		    	selected = "";
		    	if(hashMap.get("TYPE_CODE").toString().equals(jobTypeDDL)){
		    	  selected = "selected";
		    	}
		    	%>
		    	<option value="<%=hashMap.get("TYPE_CODE").toString()%>"  <%=selected %>><%=hashMap.get("TYPE_CODE").toString()%> - <%=hashMap.get("TYPE_NAME").toString()%></option>
		       <%
		    }
        }
		%>
     </select> 
    </td>
    </tr>
     <tr>
    <td class="item ; dotline01" height="22" width="12%">รหัสพนักงาน :</td>
    <td height="22" width="88%" class="dotline01">
    <input type="text"  id="employ"  name="employ" value="<%=employ %>" placeholder="2154-6" maxlength="6" value="" onkeypress="return isNumber(event)">   
	&nbsp;&nbsp;&nbsp;<a href="javascript:doSearch();"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a>
    </td>
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

<br style="font-size:20pt">
  <div align="left">
  <a href="javascript:doAdd();"><img border="0" src="images/act_add.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
 </div>   	
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
      <table id="results" border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td class="col_name" width="3%">NO.</td>
          <td class="col_name" width="5%">รหัสบริษัท</td>
          <td class="col_name" width="10%">ชื่อโครงการ</td>
          <td class="col_name" width="8%">ประเภทงานซ่อม</td>
          <td class="col_name" width="10%">รหัสพนักงาน#1</td>
          <td class="col_name" width="10%">รหัสพนักงาน#2</td>
          <td class="col_name" width="10%">รหัสพนักงาน#3</td>
          <td class="col_name" width="10%">รหัสพนักงาน#4</td>
          <td class="col_name" width="8%">รหัสพนักงาน#5</td>
          <td class="col_name" width="8%">รหัสพนักงาน#6</td>
          <td class="col_name" width="%">Other Email</td>
          <td class="col_name" width="10%">Action</td>
        </tr>
 <%
		//hashMap.put("EMP_NAME1", hashMapTemp.get("EMP_FULLNAME"));
		//hashMap.put("EMP_EMAIL1",hashMapTemp.get("EMP_EMAIL"));			
        int c = 0;
 		if(resultHashList!=null && resultHashList.size()>0){
 			HashMap hashMap = null;	
 			Iterator it = resultHashList.iterator(); 			

 			String tagColor = "";
			while(it.hasNext()){
			    c++;		
				hashMap =(HashMap)it.next();		
				 tagColor="#ffffff";
				 if(c%2==0){
					 	tagColor="#f7f7f7";
				 }	 
 %>
	        <tr bgcolor="<%=tagColor %>" >
	        <td align="center" class="dotline" ><%=c%></td>
	        <td  align="center" class="dotline ; item">&nbsp;<%=hashMap.get("COM_ID") %>-<%=hashMap.get("PROJ_ID") %></td>
	        <td class="dotline" align="left" >&nbsp;<%=hashMap.get("N_PROJECT").toString() %></td>
	        <td class="dotline" align="left" >&nbsp;<%=hashMap.get("SYS_TYPE")+hashMap.get("SYS_TYPE2").toString() %> 
	        <%
	          if(typeSubCategory!=null && typeSubCategory.size()>0){
	          	out.println(GetSubSysTypeName(typeSubCategory,hashMap.get("SYS_TYPE").toString()+":"+hashMap.get("SYS_TYPE2").toString()));
	          }
	         %>
	        </td>
	        <td class="dotline" align="left" title="<%=hashMap.get("EMP_NAME1").toString() %>">&nbsp;<%=hashMap.get("EMPLOY1") %><%=GetDisplayEmail(hashMap.get("EMP_EMAIL1").toString()) %></td>
	        <td class="dotline" align="left" title="<%=hashMap.get("EMP_NAME2").toString() %>">&nbsp;<%=hashMap.get("EMPLOY2") %><%=GetDisplayEmail(hashMap.get("EMP_EMAIL2").toString()) %></td>
	        <td class="dotline" align="left" title="<%=hashMap.get("EMP_NAME3").toString() %>">&nbsp;<%=hashMap.get("EMPLOY3") %><%=GetDisplayEmail(hashMap.get("EMP_EMAIL3").toString()) %></td>
	        <td class="dotline" align="left" title="<%=hashMap.get("EMP_NAME4").toString() %>">&nbsp;<%=hashMap.get("EMPLOY4") %><%=GetDisplayEmail(hashMap.get("EMP_EMAIL4").toString()) %></td>
	        <td class="dotline" align="left" title="<%=hashMap.get("EMP_NAME5").toString() %>">&nbsp;<%=hashMap.get("EMPLOY5") %><%=GetDisplayEmail(hashMap.get("EMP_EMAIL5").toString()) %></td>
	        <td class="dotline" align="left" title="<%=hashMap.get("EMP_NAME6").toString() %>">&nbsp;<%=hashMap.get("EMPLOY6") %><%=GetDisplayEmail(hashMap.get("EMP_EMAIL6").toString()) %></td>
			<td class="dotline" align="left" title="<%=hashMap.get("DESC").toString() %>">&nbsp;<%=hashMap.get("DESC") %></td>			
			<td  class="dotline" align="center">
			
			<a href="javascript:goUpdate('<%=hashMap.get("COM_ID") %>:<%=hashMap.get("PROJ_ID") %>','<%=hashMap.get("SYS_TYPE")+":"+hashMap.get("SYS_TYPE2") %>')">
			    <span style='font-size: 17px; '>
			        <i class="fa fa-pencil-square-o" style="color: #008BFC;" aria-hidden="true"></i>
			    </span>
			</a>
			&nbsp;&nbsp;&nbsp;
			<a href="javascript:doDelete('<%=hashMap.get("COM_ID") %>:<%=hashMap.get("PROJ_ID") %>','<%=hashMap.get("SYS_TYPE")+":"+hashMap.get("SYS_TYPE2") %>');">
			    <span style='font-size: 17px;'>
			        <i class="fa fa-trash-o fa-lg text-danger" style="color: #FF5733;" aria-hidden="true"></i>
			    </span>
			</a>
			
		      	
		      	
		      	
		      	</td>
	        </tr>  
 			<%
 			}
 	}else{
  %>       
        <tr>
		   <td  class="dotline" colspan="12" class="side01" >&nbsp;</td>
        </tr>
       <tr>
		   <td  class="dotline" colspan="12" align="center" class="side01" >&nbsp;ไม่มีข้อมูล</td>
        </tr>
        <tr>
		   <td  class="dotline" colspan="12" class="side01" >&nbsp;</td>
        </tr>
        <%}
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
<% if(c>0){ %>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr  valign="MIDDLE">
    <td align="right" nowrap="nowrap" width="50%">
    <div id="pageNavPosition"></div>
    </td>
   <td valign="middle" align="left" nowrap="nowrap" width="50%" class="pg-normal" >
   &nbsp;&nbsp;<A href="#" onclick="toggle_visibility('page');">|ALL|</A>&nbsp;&nbsp;<div id="page"></div>
    </td>
  </tr>
</table>
<%}else{
%>
<div id="page"></div>
<%
} %>
<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">
            <% if(c>0){ %>
 			<a href="javascript:doAdd();"><img border="0" src="images/act_add.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
            <%} %>      	
           </td>      	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:history.back()" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
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

</form>
<script type="text/javascript">	
    function toggle_visibility(id) {
    try{
	      var intX = 0;
	      var e = document.getElementById(id);
	      if(e.style.visibility == 'hidden'){
	         e.style.visibility = 'visible';
	         intX = 1;
	      }else{
	         e.style.visibility = 'hidden';
	      }      
	      if(intX==1){
	         allList();
	      }else{
	        pageList();
	      }
      }catch(err) {
   		/* document.getElementById("demo").innerHTML = err.message;*/
   		//alert(err.message);
	 }
    }

 	function allList(){
 	   try{
 		 totalRec  = "<%=c%>";
 		  var pager = new Pager('results', totalRec); 
	      pager.init(); 
	      pager.showPageNav('pager', 'pageNavPosition'); 
	      pager.showPage(1);
	 }catch(err) {
   		/* document.getElementById("demo").innerHTML = err.message;*/
   		//alert(err.message);
	 }
    }
    
    function pageList(){
    try{
 		  var pager = new Pager('results', 25); 
	      pager.init(); 
	      pager.showPageNav('pager', 'pageNavPosition'); 
	      pager.showPage(1);
	 }catch(err) {
   		/* document.getElementById("demo").innerHTML = err.message;*/
   		//alert(err.message);
	 }	      
    }
</script>
 <script type="text/javascript"><!--
    try{
        var pager = new Pager('results', 25); 
        pager.init(); 
        pager.showPageNav('pager', 'pageNavPosition'); 
        pager.showPage(1);
	 }catch(err) {
   		/* document.getElementById("demo").innerHTML = err.message;*/
   		//alert(err.message);
	 }        
    //--></script>
</BODY>
</HTML>
