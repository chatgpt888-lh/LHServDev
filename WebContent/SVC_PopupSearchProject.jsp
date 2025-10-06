<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@page language="java" contentType="text/html; charset=TIS-620"
	pageEncoding="TIS-620"%>
<%@ page import="com.lh.util.doString" %>	
<%@ page import="com.svc.call.utilize.Constant" %>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>	
<%
ArrayList projectDDL = (ArrayList)session.getAttribute(Constant.SS_POPUP_PROJECT_LIST);
String mode = request.getAttribute("mode")==null?"":request.getAttribute("mode").toString();
String tel = request.getParameter("tel")==null?"":request.getParameter("tel").toString();
String agentId = request.getParameter("agentId")==null?"":request.getParameter("agentId").toString();

//*********case from  search3 
  String projectTxt = "";
  Object  obj = request.getAttribute("searchProjectList"); //recieve data from controller
  ArrayList   projectList = null;
  if(obj!=null){
     projectList = (ArrayList)obj;
  }else{
     projectList = new ArrayList();
  }
if("search".equals(mode)){
	tel  = request.getAttribute("tel")==null?"":request.getAttribute("tel").toString();
	agentId = request.getAttribute("agentId")==null?"":request.getAttribute("agentId").toString();
	projectTxt = request.getAttribute("projectTxt")==null?"":request.getAttribute("projectTxt").toString();
}
%>	
	
<HTML>
<HEAD>
<title>SVC_PopupSearchProject</title>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
function doAddProject(){
	if(document.forms[0].projectDDL.value=="") {
          alert("กรุณาเลือกโครงการด้วย..");
          document.forms[0].projectDDL.focus();
          return false;
     }else{
        //submit 
     	submitForm(document.forms[0].projectDDL.value);
     } 
}

function submitForm(param){
    try{
   	  		var args = param.split(":"); 
   	  		//Main Form Reference use sent parameter to servlet
	   	  	window.opener.document.getElementById('comId').value = args[0];
			window.opener.document.getElementById('projId').value = args[1];
			window.opener.document.getElementById('nameProject').value = args[2];

			window.opener.document.forms[0].action="<%=request.getContextPath() %>/SVCInformController.do?cmd=search2";
	    	window.opener.document.forms[0].submit();//main submit form
			window.close();//popup this close
	   }catch(e){
	     	alert(e.message);
	     	window.close();
	   }
}
//--Get Rbt value of Element
function GetRadioValue() {
    var inputs = document.getElementsByName("rbtSel");
    for (var i = 0; i < inputs.length; i++) {
         if (inputs[i].checked) {
         return inputs[i].value;
     }
   }
 }
 
 //Function check out 
function getRadioCheckedValue(){ 
   var rad_val;
   try{
     rad_val =  GetRadioValue();
   }catch(e){
     alert("กรุณาเลือกรายการที่ค้นหา 1 รายการ..");
   }
   
   if(rad_val == 'undefined' || rad_val == null ){
      alert("กรุณาเลือกรายการที่ค้นหา 1 รายการ..");
      return;
   }
   //call method
   try{
	  alert(rad_val);
   	  submitForm(rad_val);
   }catch(e){
     alert(e.message);
     window.close();
   }
}

function doChangeRbt(param){
     if(param=='1') {
 		document.getElementById("projectDDL").disabled=false;
 		document.getElementById("projectTxt").disabled=true;
 		document.getElementById("img1").style.display=''; //Enable
 		document.getElementById("img2").style.display='none'; //disable
     }else {
        document.getElementById("projectDDL").disabled=true;
 		document.getElementById("projectTxt").disabled=false;
 		document.getElementById("img1").style.display='none'; //disable
 		document.getElementById("img2").style.display=''; //Enable
     }
  }
  function doSubmitSearch(){   
	if(document.forms[0].projectTxt.value ==""){
	    document.forms[0].projectTxt.focus();
		alert("กรุณากรอกโครงการที่ต้องการค้นหาด้วย!!");
        return;
	} else{   
		 document.forms[0].mode.value = "search";
		 document.forms[0].action="<%=request.getContextPath() %>/SVCInformController.do?cmd=search3";
		 document.forms[0].submit();
	 }
 }

 function doInitial(){
   <%if("search".equals(mode)){%>
       	document.getElementById("projectTxt").disabled=false;
	    document.getElementById("img2").style.display=''; //Enable
	    document.getElementById("img1").style.display='none'; //disable
	    document.getElementById("projectDDL").disabled=true; //disable
   <%}else{%>
	    document.getElementById("projectTxt").disabled=true;
	    document.getElementById("img2").style.display='none'; //disable
    <%}%>
  }
  
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

<FORM method="post">
<input type="hidden" name="tel" id="tel" value="<%=tel %>">
<input type="hidden" name="agentId" id="agentId" value="<%=agentId %>">
<input type="hidden" name="mode" id="mode" value="">


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">
          &nbsp;Search Project</td>
        </tr>
      </table>
<br style="font-size:10pt">

            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">ค้นหาโครงการ</td>
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
    <td class="item ; dotline01" height="22" width="18%">เลือกค้นหาโครงการโดย : </td>
    <td height="22" class="dotline01" colspan="3">
	<input type="radio" value="sel01" name="rbt" checked="checked" onclick="JavaScript:doChangeRbt('1');">
			<select name="projectDDL" id="projectDDL" class="box2" style='width:250' size="1" > 
						<option value="" >------ กรุณาเลือกโครงการ ------</option>
   							<%
							List  arrList = null;
							if(projectDDL!=null && projectDDL.size()>0){
								Iterator it = projectDDL.iterator();
								while(it.hasNext()){								
									 arrList =(ArrayList)it.next();									
									%>
									 	<option value="<%=arrList.get(0)+":"+arrList.get(1)+":"+doString.checkString(doString.DisplayThai(arrList.get(2).toString()))%>"  >
									 	[<%=arrList.get(0)%>-<%=arrList.get(1)%>]  <%=doString.checkString(doString.DisplayThai(arrList.get(2).toString())) %></option>
								   <%}
								} %>	 
   							</select> 					

		<span id="img1">
		 <a href="#" onclick="javascript:doAddProject();">
		 <img border="0" src="images/bu_add.gif" align="absmiddle" width="30" height="15" onmouseout=nereidFade(this,70,50,5)    
	                  	onmouseover=nereidFade(this,100,50,5)     
	                  	style="FILTER: alpha(opacity=70) ; cursor:hand" hspace="5"></a>
	    </span>              	
    </td>
  </tr>
  
  <tr>
    <td class="item ; dotline01" height="22">&nbsp;</td>
    <td height="22" class="dotline01" colspan="3">
   	<input type="radio" value="sel02" name="rbt" onclick="JavaScript:doChangeRbt('2');" 
   	<%
   	if("search".equals(mode)){
   		out.println("checked='checked'");
   	}else{
   		out.println("");
   	}
   	 %>>

    <input type="text" name="projectTxt" name="projectTxt" class="box" style="width:250px" size="20" value="<%=doString.DisplayThai(projectTxt)%>">
	<span id="img2">
			<img border="0" src="images/i_search.gif"	align="absmiddle" width="20" height="20" hspace="5" style="cursor:hand"
				onclick="doSubmitSearch();">
	</span>
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


<br style="font-size:2pt">

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
          <td class="col_name" width="18%">ลำดับ</td>
          <td class="col_name">ชื่อโครงการ</td>
        </tr>
        <%
           if(projectList!=null && projectList.size()>0 && "search".equals(mode)){
        		Iterator it = projectList.iterator();	
        		List strList = null;						   							   
				while(it.hasNext()){								
				strList =(ArrayList)it.next();	
				%>
					 <tr>
			          <td align="center" class="dotline">
			          <input type="radio" name="rbtSel" value="<%=strList.get(0)+":"+strList.get(1)+":"+doString.checkString(doString.DisplayThai(strList.get(2).toString()))%>"></td>
			          <td class="dotline" align="left">[<%=strList.get(0)%>-<%=strList.get(1)%>] <%=doString.checkString(doString.DisplayThai(strList.get(2).toString())) %></td>
			        </tr> 
				<%
				}
           }else{
          %>
		         <tr>
		           <td align="center" class="dotline" colspan="2">&nbsp;</td>
		        </tr>
		         <tr>
		           <td align="center" class="dotline" colspan="2">&nbsp;*** ไม่มีข้อมูล ****</td>
		        </tr>
		         <tr>
		           <td align="center" class="dotline" colspan="2">&nbsp;</td>
		        </tr>
        <%} %>    
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

        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="150" class="act_tab2">

            <a href="JavaScript:getRadioCheckedValue();" target="_top"><img border="0" src="images/act_checkout.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp; 
            <a href="#" onClick="deleteData()"></a>            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="Constants.APP_PATH/SERV_VenPrj.jsp" target="_self"></a>&nbsp;
              <a href="javascript:this.close()" target="_top"><img border="0" src="images/bu_close.gif" align="absmiddle" width="50" height="15"></a></td>  
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

