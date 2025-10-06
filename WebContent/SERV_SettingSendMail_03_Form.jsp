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
 * project Name : 
 * description :  
***************************************************/
--%>
<%!

private static String GetProjectName(ArrayList ssProjectList,String args){
	 String retNameProject = "";
	 try{
	 	 if(ssProjectList!=null && ssProjectList.size()>0){
	        Iterator it = ssProjectList.iterator();   
	        HashMap hashMap = null;	
	        while(it.hasNext()){	    		    	
			    hashMap = (HashMap)it.next();
			    if(hashMap.get("value").toString().equals(args)){
			    	retNameProject = hashMap.get("pj_name").toString();
			    	break;
			    }
		    }
		}
	 }catch(Exception e){
	 	e.printStackTrace();
	 }
	 return retNameProject;
}

 %>

<%
//******************************************
  ArrayList projectList = (ArrayList)session.getAttribute("SS_projectList");
  ArrayList jobTypeList = (ArrayList)session.getAttribute("SS_typeCategory");

  ArrayList listSubCategory =(ArrayList)request.getAttribute("listTypeCategory"); //dddd
  String jobSubDDL = request.getAttribute("jobSubDDL")==null?"":request.getAttribute("jobSubDDL").toString(); //01:05

 Object objHashList = request.getAttribute("hashData");
 List hashList = new ArrayList();
 if(objHashList!=null){
 	hashList = (ArrayList)objHashList;
 }

//request.setAttribute("hashData",listHash); //String Array
//Parameter
String jobTypeDDL = request.getAttribute("jobTypeDDL")==null?"":request.getAttribute("jobTypeDDL").toString();


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
<TITLE>Form การกำหนดผู้รับ Email ตามโครงการและประเภท</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script type='text/javascript' src='jquery/jquery-1.11.3.min.js'></script>
<script type='text/javascript' src='jquery/loadImg.js'></script>
<script  type='text/javascript' >


$(document).ready(function() {
			 var val = '<%= jobSubDDL %>';
            $.ajax({
                type: "POST",
                url: "<%=Constants.APP_PATH%>/SERV_SettingSendMailServlet?cmd=selNdesc",
                data: 'jobTypeDDL='+val,
                success: function(data) {
                    $("#SeljobSubDDL").val(data);
                }
            });
        });


function onPleaseWait(){
	document.all.pleasewaitScreen.style.pixelTop = (document.body.scrollTop + 120);
	$('#pleasewaitScreen').show();
	setTimeout(function(){  $('#pleasewaitScreen').css("visibility", 'hidden'); }, 7000); //wait 7 seconds
	$('#pleasewaitScreen').css('visibility', 'visible');
 }

function doCheckALL(chkName,index){
try {
	var cnt = $('#cnt').val();
	/*
	$('input[name=employ1_1]').val("88888");
	$('#employ1_2').val("99999");
	alert(cnt);*/
	if(chkName==true){
		for(var i=0;i<cnt;i++){
			$('#employ'+index+'_'+i).val($('#employ'+index+'_0').val());
		}
	}else{
		for(var i=0;i<cnt;i++){
			$('#employ'+index+'_'+i).val('');
		}
		//doReset();
	}
  /*if($('.myCheckbox').is(':checked')==true);*/
}
catch(err) {
   /* document.getElementById("demo").innerHTML = err.message;
   alert(err.message);*/
}
}



function doCheckALL2(chkName){
try {
	var cnt = $('#cnt').val();
	/*
	$('input[name=employ1_1]').val("88888");
	$('#employ1_2').val("99999");
	alert(cnt);*/
	if(chkName==true){
		for(var i=0;i<cnt;i++){
			$('#desc_'+i).val($('#desc_0').val());
		}
	}else{
		for(var i=0;i<cnt;i++){
			$('#desc_'+i).val('');
		}
		//doReset();
	}
   /*if($('.myCheckbox').is(':checked')==true);*/
  }catch(err) {
   /* document.getElementById("demo").innerHTML = err.message;
   alert(err.message);*/
  }
}

function doAdd(){
	document.forms[0].action="<%=request.getContextPath()%>/SERV_SettingSendMailServlet?cmd=formAdd1";
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

function CheckEmail(str) {
	var supported = 0;
  	if (window.RegExp) {
    	var tempStr = "a";
    	var tempReg = new RegExp(tempStr);
    	if (tempReg.test(tempStr)) supported = 1;
	}
	if (!supported) return (str.indexOf(".") > 2) && (str.indexOf("@") > 0);
	var r1 = new RegExp("(@.*@)|(\\.\\.)|(@\\.)|(^\\.)");
  	var r2 = new RegExp("^.+\\@(\\[?)[a-zA-Z0-9\\-\\.]+\\.([a-zA-Z]{2,3}|[0-9]{1,3})(\\]?)$");
  	//var r1 = new RegExp("^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@");
  	//var r2 = new RegExp("[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$");
  	return (!r1.test(str) && r2.test(str));
}

function doReset(){
  document.getElementById("myForm").reset();
}

function doSubmit(){
    /*if(!CheckEmail(frm.email.value)){
		alert("Email ไม่ถูกต้อง (e.g. name@yourdomain.com)");
		return;
	}else{
    	onPleaseWait();
 		doSubmitForm("<%=Constants.APP_PATH%>/SERV_SettingSendMailServlet?cmd=submit");			
	}*/
try {
	/*var cnt = $('#cnt').val();
	for(var i=0;i<cnt;i++){
	   if(!CheckEmail($('#desc_'+i).val())){
		alert("Email ไม่ถูกต้อง (e.g. name@yourdomain.com)");
		return;
	   }
	}*/
	onPleaseWait();
 	doSubmitForm("<%=Constants.APP_PATH%>/SERV_SettingSendMailServlet?cmd=submit");		
}
catch(err) {
   /* document.getElementById("demo").innerHTML = err.message;
   alert(err.message);*/
}	
	
	
}
function doSubmitForm(url){
 	$('form').attr('action', url);
	$("form:first").submit();
}

</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<form ACTION="" name="myForm" METHOD="POST" >
<input type="hidden" name="jobTypeDDL" value="<%=jobTypeDDL%>"/>
<input type="hidden" name="jobSubDDL"  value="<%=jobSubDDL%>"/>

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


<%
try{
 %>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">
          &nbsp;Form การกำหนดผู้รับ Email ตามโครงการและประเภท</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>                
          		<td class="item_tab2" width="400">Form การกำหนดผู้รับ Email </td>
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
    <td class="item ; dotline01" height="22" colspan="4">ประเภทงานซ่อม : 
  	<select size="1" class="box2" style="width:200px" name="jobTypeDDLx" disabled="disabled" >
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
     </select>   &nbsp; 
    </td>
  </tr>
   <tr>
    <td class="item ; dotline01" height="22" colspan="4">หมวดรอง  :
      <input type="text" id="SeljobSubDDL" value = "" disabled="disabled" style="width: 300;"/>
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


<br style="font-size:10pt">

            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>               
          		<td class="item_tab2" width="200">กำหนดสายงานรับผิดชอบเกี่ยวกับงานบริการ(Auto Sent Email)</td>
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
			  <!--========================== Header Table ===========================---->
              <tr> 
                <td width="7%" height="18" class="col_name"  >รหัส</td>
                <td width="20%" height="18" class="col_name" >ชื่อโครงการ</td>
                <td width="%" height="18" class="col_name"  >รหัสพนักงาน#1</td>
                <td width="%" height="18" class="col_name"  >รหัสพนักงาน#2</td>
                <td width="%" height="18" class="col_name"  >รหัสพนักงาน#3</td>
                <td width="%" height="18" class="col_name"  >รหัสพนักงาน#4</td>
                <td width="%" height="18" class="col_name"  >รหัสพนักงาน#5</td>
                <td width="%" height="18" class="col_name"  >รหัสพนักงาน#6</td>
                <td width="%" height="18" class="col_name"  >Other Email Address</td>
              </tr>
              <tr> 
	                <td  height="18" valign="middle" class="dotline01" colspan="2" align="right">&nbsp; CHECK ALL</td>
	                <td  height="18" valign="middle" class="dotline01" ><input type="checkbox" id="chk1" name="chk1" value="1"  onClick="JavaScript:doCheckALL(this.checked,1);"></td>
	                <td  height="18" valign="middle" class="dotline01" ><input type="checkbox" id="chk2" name="chk2" value="1"  onClick="JavaScript:doCheckALL(this.checked,2);"></td>
	                <td  height="18" valign="middle" class="dotline01" ><input type="checkbox" id="chk3" name="chk3" value="1"  onClick="JavaScript:doCheckALL(this.checked,3);"></td>
	                <td  height="18" valign="middle" class="dotline01" ><input type="checkbox" id="chk4" name="chk4" value="1"  onClick="JavaScript:doCheckALL(this.checked,4);"></td>
	                <td  height="18" valign="middle" class="dotline01" ><input type="checkbox" id="chk5" name="chk5" value="1"  onClick="JavaScript:doCheckALL(this.checked,5);"></td>
	                <td  height="18" valign="middle" class="dotline"  ><input type="checkbox" id="chk6" name="chk6" value="1"  onClick="JavaScript:doCheckALL(this.checked,6);"></td>
	        		<td  height="18" valign="middle" class="dotline"  ><input type="checkbox" id="chk7" name="chk7" value="1"  onClick="JavaScript:doCheckALL2(this.checked);">abcd@ddd.com,test@gmail.com</td>
	        </tr>
             <%
             //Value =  LH:075
             String projectID = "";
            // if(selProjArr!=null && selProjArr.length>0){
            int x = 0;
            if(hashList!=null && hashList.size()>0){
             	 String tagColor = "";
             	 String tempProjectId = "";
				 Iterator it = hashList.iterator();   
        	     HashMap hashMap = null;	 	     
        	     
        	     while(it.hasNext()){	    		    	
		    		hashMap = (HashMap)it.next();
 	        		//for(int x = 0;x<hashList.size();x++){
 	        	    tagColor="#ffffff";
					if(x%2==0){
					 	tagColor="#f7f7f7";
					 }	
					tempProjectId = "";									
					tempProjectId =  hashMap.get("COM_ID").toString()+":"+hashMap.get("PROJ_ID").toString()+":"+hashMap.get("DUP").toString();
					//selProjArr[x];//LH:075
					//LH:075:1|LH:011:0|LH:234:0				 
					if(projectID.equals("")){
						projectID = tempProjectId;
					}else{
					   projectID  +="|"+tempProjectId;
					}	
					%>
	           		<tr bgcolor="<%=tagColor%>"> 
	                <td  height="18" valign="middle" class="dotline01" align="right" ><%=hashMap.get("COM_ID").toString()+":"+hashMap.get("PROJ_ID").toString() %></td>
	                <td  height="18" valign="middle" class="dotline01" ><%=GetProjectName(projectList,hashMap.get("COM_ID").toString()+":"+hashMap.get("PROJ_ID").toString())%></td>
	                <td  height="18" valign="middle" class="dotline01" ><input type="text" size="10"  id="employ1_<%=x%>"  name="employ1_<%=x %>" placeholder="2154-6" maxlength="6" value="<%=hashMap.get("EMP1").toString() %>" onkeypress="return isNumber(event)"></td>
	                <td  height="18" valign="middle" class="dotline01" ><input type="text" size="10"   id="employ2_<%=x%>"  name="employ2_<%=x %>" placeholder="2154-6" maxlength="6" value="<%=hashMap.get("EMP2").toString() %>" onkeypress="return isNumber(event)"></td>
	                <td  height="18" valign="middle" class="dotline01" ><input type="text" size="10"   id="employ3_<%=x%>"  name="employ3_<%=x %>" placeholder="2154-6" maxlength="6" value="<%=hashMap.get("EMP3").toString() %>" onkeypress="return isNumber(event)"></td>
	                <td  height="18" valign="middle" class="dotline01" ><input type="text" size="10"   id="employ4_<%=x%>"  name="employ4_<%=x %>" placeholder="2154-6" maxlength="6" value="<%=hashMap.get("EMP4").toString() %>" onkeypress="return isNumber(event)"></td>
	                <td  height="18" valign="middle" class="dotline01" ><input type="text" size="10"   id="employ5_<%=x%>"  name="employ5_<%=x %>" placeholder="2154-6" maxlength="6" value="<%=hashMap.get("EMP5").toString() %>" onkeypress="return isNumber(event)"></td>
	                <td  height="18" valign="middle" class="dotline"  ><input type="text"  size="10"   id="employ6_<%=x%>"  name="employ6_<%=x %>" placeholder="2154-6" maxlength="6" value="<%=hashMap.get("EMP6").toString() %>" onkeypress="return isNumber(event)"></td>
	                <td  height="18" valign="middle" class="dotline"  ><input type="text"  size="40"  id="desc_<%=x%>"  name="desc_<%=x %>" placeholder="abcd@abcd.com"  value="<%=hashMap.get("DESC").toString() %>" ></td>	              
	              	</tr>					
					<%
					x++;	
 	        	}
             } 
             %>
            </table>
            <input type="hidden" name="tempProjectTxt" value="<%=projectID %>"> 
            <input type="hidden" id="cnt" name="cnt" value="<%=x %>"> 
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


<br style="font-size:3pt">
<br style="font-size:10pt">

        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="80" class="act_tab2">&nbsp;
            <a href="javascript:doSubmit();" ><img border="0" src="images/act_submit.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp; 
                  	
            </td>        	
            <td class="act_tab3">
                        <a href="javascript:doReset();" ><img border="0" src="images/act_reset.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp; </td>
            <td class="act_tab4"><a href="javascript:doAdd();" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
          </tr>
        </table>
<%}catch(Exception e){
  System.out.println("!!Errors : SERV_SettingSendMail_03_Form.jsp :"+e.toString());
} %>
<br style="font-size:30pt">

<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
  <tr><td width="100%" class="copyright" align="center">
  Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5  
  <br>ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;
  หรือ โทร. 0-2230-8279 (คุณประพัฒน์
  ฝ่ายบริการ)&nbsp; 0-2230-8491-5 (ฝ่าย IT)  
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE> 

</td>
</tr>
</table>


</form>
</BODY>
</HTML>

