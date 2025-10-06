<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="java.util.*" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%@page import="java.text.SimpleDateFormat" %>
<%-- 
/**********************************************/
 * create by : pradoem wonkraso
 * date time: 2016.08.04
 * Last modify :
 * version :1.0
 * project Name : Form Add1
 * description :  Select JobType && Project for Assignment
***************************************************/
--%>

 <%
	//--------------------------------------------
  ArrayList projectList = (ArrayList)session.getAttribute("SS_projectList");
  ArrayList jobTypeList = (ArrayList)session.getAttribute("SS_typeCategory");
	String err_code = request.getAttribute("er_code")==null?"":request.getAttribute("er_code").toString();
	
	
	
 %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
<TITLE>Form Setting Sent Auto Email</TITLE>
<meta http-equiv="Content-Type"  content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css"> 
<style type="text/css">
.box2 {  font-family: Tohama,Arial,sans-serif; font-size:10.1pt; font-weight:normal;
	padding-top: 1px; padding-right: 1px; padding-bottom: 1px; padding-left: 1px; 
	 color:#165396; background-color: white; border: 1px #BEDCFF solid ; 
}
</style>

<script language="javascript" src="script_fx.js"></script>
<script type='text/javascript' src='jquery/jquery-1.11.3.min.js'></script>
<script type='text/javascript' src='jquery/loadImg.js'></script>

<script type="text/javascript">

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

//Action submit
function doSubmit(){
	if($('select[name=jobTypeDDL] option:selected').val()==''){
		alert(" กรุณาเลือกประเภทงานซ่อมด้วย !");
		$('select[name=jobTypeDDL]').focus();
		return;
	}else{
		doValidate1();
	}
}
function doAdd(){
	document.forms[0].action="<%=request.getContextPath()%>/SERV_SettingSendMailServlet?cmd=search";
	document.forms[0].submit();
}

function doValidate1(){
	if(document.forms[0].projSelDDL.options.length==0) {
		 alert(" กรุณาเลือกโครงการอย่างน้อย 1 โครงการ !");
		 document.forms[0].projDDL.focus();
		 return;
	 }
	 var row = 0;
	 var isAll = false;
	 if(document.forms[0].projSelDDL.options.length>=1){
	   //row = 1;
	   	 for(i=row;i<document.forms[0].projSelDDL.options.length;i++) {
		    if(document.forms[0].projSelDDL.options[i].value=='AA:999'){
		       isAll = true;
		       break;
		    }
	    }
	 }
	 if(isAll){
	     row = 1;
	 }	

	 if(isAll){//เลือกโครงการเท่ากับ ทุกโครงการ
	 	if(document.forms[0].projSelDDL.options.length>=1){
		   	 for(i=0;i<document.forms[0].projSelDDL.options.length;i++) {
			    if(document.forms[0].projSelDDL.options[i].value=='AA:999'){
			       document.forms[0].projSelDDL.options[i].selected = true;
			       break;
			    }
		    }
	 	}
	 	document.forms[0].multiFlag.value = 0;
	 	//alert(document.forms[0].multiFlag.value);
	 	onPleaseWait() ;
		document.forms[0].action="<%=request.getContextPath()%>/SERV_SettingSendMailServlet?cmd=formAdd2";
		document.forms[0].submit();
		//alert("Submit Case ALL Project ");
	 }else{//เลือกโครงการเท่ากับ mulitiple project
	 	for(i=row;i<document.forms[0].projSelDDL.options.length;i++) {
			document.forms[0].projSelDDL.options[i].selected = true;	
	 	}	
	    document.forms[0].multiFlag.value = 1;
	 	onPleaseWait() ;	 
	 	document.forms[0].action="<%=request.getContextPath()%>/SERV_SettingSendMailServlet?cmd=formAdd2";
		document.forms[0].submit();
		//alert("Submit Case Select Project ");
	 }	
}

//return the value of the radio button that is checked
//return an empty string if none are checked, or
//there are no radio buttons
//radio check by pradoem 2012-02-28
function getCheckedValue(radioObj) {
		if(!radioObj)
			return "";
		var radioLength = radioObj.length;
		if(radioLength == undefined)
			if(radioObj.checked)
				return radioObj.value;
			else
				return "";
		for(var i = 0; i < radioLength; i++) {
			if(radioObj[i].checked) {
				return radioObj[i].value;
			}
		}
		return "";
}

function MoveSelect(FromBox, TargetBox, Type) {
	var ArrFromBox = new Array();
	var ArrTargetBox = new Array();
	var ArrLookup = new Array();
	for (i = 0; i < TargetBox.options.length; i++) {
		ArrLookup[TargetBox.options[i].text] = TargetBox.options[i].value;
		ArrTargetBox[i] = TargetBox.options[i].text;
	}
	var FromLen = 0;
	var TargetLen = ArrTargetBox.length;
	for(i = 0; i < FromBox.options.length; i++) {
		ArrLookup[FromBox.options[i].text] = FromBox.options[i].value;
		if (FromBox.options[i].value != "" && (Type == 'ALL' || (Type == 'SEL' && FromBox.options[i].selected))){
			ArrTargetBox[TargetLen] = FromBox.options[i].text;
			TargetLen++;
		} else {
			ArrFromBox[FromLen] = FromBox.options[i].text;
			FromLen++;
	   }
	}
	ArrFromBox.sort();
	ArrTargetBox.sort();
	FromBox.length = 0;
	TargetBox.length = 0;
	for(i = 0; i < ArrFromBox.length; i++) {
		var Box = new Option();
		Box.value = ArrLookup[ArrFromBox[i]];
		Box.text = ArrFromBox[i];
		FromBox[i] = Box;
	}
	for(i = 0; i < ArrTargetBox.length; i++) {
		var Box = new Option();
		Box.value = ArrLookup[ArrTargetBox[i]];
		Box.text = ArrTargetBox[i];
		TargetBox[i] = Box;
	}
}
</script>
<script>
function onPleaseWait(){
	document.all.pleasewaitScreen.style.pixelTop = (document.body.scrollTop + 120);
	$('#pleasewaitScreen').show();
	setTimeout(function(){  $('#pleasewaitScreen').css("visibility", 'hidden'); }, 15000); //wait 15 seconds
	$('#pleasewaitScreen').css('visibility', 'visible');
 } 
</script>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" >

<FORM METHOD="POST" ACTION="" name="frm">
<input type="hidden" name="multiFlag" value="">

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
          &nbsp;Form การกำหนดผู้รับ Email ตามโครงการและประเภท</td>
        </tr>
      </table>
<br style="font-size:10pt">
              
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">กรุณาเลือกประเภทงานซ่อม</td>
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
	<%--  ################################## --%>
	<table border="0" width="100%" cellspacing="0" cellpadding="0">
	 <tr>
    <td class="item ; dotline01" height="22" width="15%">ประเภทงานซ่อม  :</td>
    <td class="dotline01" align="left" width="%">&nbsp;
     <select size="1" class="box2" style="width:200px" name="jobTypeDDL"  onchange="javascript:GetDynamicDropdown(this.value);">
        <option value=''>---กรุณาเลือกประเภทงานซ่อม---</option>
        <%
        if(jobTypeList!=null && jobTypeList.size()>0){
        	Iterator it = jobTypeList.iterator();   
        	HashMap hashMap = null;	
        	while(it.hasNext()){	    		    	
		    	hashMap = (HashMap)it.next();
		    	%>
		    	<option value="<%=hashMap.get("TYPE_CODE").toString()%>"  ><%=hashMap.get("TYPE_CODE").toString()%> - <%=hashMap.get("TYPE_NAME").toString()%></option>
		       <%
		    }
        }
		%>
     </select> &nbsp;
	</td>
 </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="15%">หมวดรอง  :</td>
    <td class="dotline01" align="left" width="%">&nbsp;
     <select size="1" class="box2" style="width:200px" name="jobSubDDL" id="jobSubDDL" >
       <option value=''>------ กรุณาเลือกหมวดรอง ------</option>	
     </select>
	</td>
 </tr>
 
	</table>
	<%--  ################################## --%>
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

<br style="font-size:2pt">
<table border="0" width="100%" cellspacing="0" cellpadding="0" height="9">
  <tr>
    <td width="5" valign="top" bgcolor="#D7E6FF" height="9"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop" bgcolor="#D7E6FF" height="9">&nbsp;</td>
    <td width="5" valign="top" align="right" bgcolor="#D7E6FF" height="9"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL">
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td class="col_name" width="45%">โครงการในกลุ่ม</td>
          <td class="col_name" width="10%">&nbsp;</td>
          <td class="col_name" width="45%">โครงการที่เลือก</td>
        </tr>
        <tr>
          <td class="dotline" align="center" width="45%" rowspan="6" style="padding:15px 0px 15px 0px">
		  <select size="20" name="projDDL" multiple class="box2" style="width:300px" ondblclick="MoveSelect(frm.projDDL, frm.projSelDDL,'SEL');">
		   <!-- <option value="AA:999">---ทุกโครงการ---</option>  -->
		  <%
		      
			   HashMap  hashMap = null;
			   if(projectList!=null && projectList.size()>0){
					Iterator it = projectList.iterator();
					String strValue = "";
					String strName = "";
					while(it.hasNext()){
							 hashMap = (HashMap)it.next();
							 strValue = ""; 
							 strName = "";	
							 strValue = hashMap.get("value").toString(); 
							  strName = hashMap.get("pj_name").toString();
							 if("AA:999".equals(strValue)){
							     strName = "---ทุกโครงการ---";
							 } 
						%>
							<option value="<%=strValue%>"  ><%=strValue%> - <%=strName%></option>
						<%}
				} %>	       
			</select>
			</td>
          <td align="center" class="dotline" width="10%">&nbsp;</td>
          <td align="center" class="dotline" width="45%" rowspan="6" style="padding:15px 0px 15px 0px">
			  <select size="20" name="projSelDDL" multiple class="box2" style="width:300px" ondblclick="MoveSelect(frm.projSelDDL, frm.projDDL,'SEL');">
	          </select>
		</td>
        </tr>
       <tr>
          <td align="center" class="dotline" width="10%"><a href="javascript:MoveSelect(frm.projDDL, frm.projSelDDL,'SEL')"><img border="0" src="images/bu_R.gif" align="absmiddle" vspace="5" hspace="5" width="16" height="16" alt="Add"></a></td>
        </tr>
        <tr>
          <td align="center" class="dotline" width="10%"><a href="javascript:MoveSelect(frm.projDDL, frm.projSelDDL,'ALL')"><img border="0" src="images/bu_RR.gif" align="absmiddle" vspace="5" hspace="5" width="16" height="16" alt="Add All"></a></td>
        </tr>
        <tr>
          <td align="center" class="dotline" width="10%"><a href="javascript:MoveSelect(frm.projSelDDL, frm.projDDL,'SEL')"><img border="0" src="images/bu_L.gif" align="absmiddle" vspace="5" hspace="5" width="16" height="16" alt="Remove"></a></td>
        </tr>
        <tr>
          <td align="center" class="dotline" width="10%"><a href="javascript:MoveSelect(frm.projSelDDL, frm.projDDL,'ALL')"><img border="0" src="images/bu_LL.gif" align="absmiddle" vspace="5" hspace="5" width="16" height="16"  alt="Remove All"></a></td>
        </tr>
        <tr>
          <td align="center" class="dotline" width="10%">&nbsp;</td>
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
</table><br style="font-size:2pt"><table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="150" class="act_tab2">
            <a href="javascript:doSubmit();" ><img border="0" src="images/bu_go.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)"  width="40" height="22"></a>&nbsp; 
            </td>                    	                 	
            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="javascript:doAdd();"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="SERV_Home_VP.jsp" target="_self"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
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

