<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@page language="java" contentType="text/html; charset=TIS-620"
	pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="serv.common.*" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %> 
<%-- 
/**********************************************/
 * create by : pradoem wonkraso
 * date time: 2013.11.14
 * version :1.0
 * project Name : E-Service
 * description : this is page for display && Master Data Google calendar
***************************************************/
--%>
<%
	ArrayList projectDDL = (ArrayList)request.getAttribute("projectList");
	String sel_project	= request.getAttribute("selProj")==null?"": request.getAttribute("selProj").toString();
    String ReadOnlyUrl	= request.getAttribute("ReadOnlyUrl")==null?"": request.getAttribute("ReadOnlyUrl").toString();
 %>
<HTML>
<HEAD>
<TITLE>ข้อมูลตารางนัดซ่อม Google Calendar</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
   <link rel="stylesheet" href="jquery/jquery-ui.css">
  <script src="jquery/jquery-1.11.3.min.js"></script>
  <script src="jquery/jquery-ui.min.js"></script>
  
 <style>
 .select2-selection__rendered {
  	font-family: Tohama, Arial, sans-serif;
    font-size: 10.1pt;
    color: #165396 !important;
}


.select2-results__option {
	font-family: Tohama, Arial, sans-serif;
    font-size: 10.1pt;
    color: #165396;
}    
 
  .custom-combobox {
    position: relative;
    display: inline-block;
   
  }
  .custom-combobox-toggle {
    position:relative;
    top:-5px;
  /*  margin-left: 0px;*/
    padding:0px;
    height:22px;
  }
  .custom-combobox-input {
    margin: 0;
    padding:0px;
    width:250px;        
    height:24px;
     font-size:10pt;
    }            
  </style>
  <script>
   $(document).ready(function() {
 
    $('#projectDDL').select2({
         matcher: function(params, data) {
            if ($.trim(params.term) === '') {
                return data;
            }

            var searchTerm = params.term.trim().toLowerCase().replace(/-/g, '');
            var optionText = (data.text || '').toLowerCase().replace(/-/g, '');

            if (optionText.indexOf(searchTerm) > -1) {
                return data;
            }

            return null; 
        }
    });
    
});
  </script>
  
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>



<script src="jquery3/jquery.min3.6.3.js" ></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
<script src="jquery3/loadingoverlay.min2.1.7.js"></script>
<style type=text/css>
.box7 {
      font-family: "Microsoft Sans Serif" ; font-size: 8pt;
      padding-top: 1px; padding-right: 2px; padding-bottom: 1px; padding-left: 2px; 
       color: #0033cc ; background-color: white; border: 1px #BEDCFF solid ; 
}
.box2 {  font-family: Tohama,Arial,sans-serif; font-size:10.1pt; font-weight:normal;
	padding-top: 1px; padding-right: 1px; padding-bottom: 1px; padding-left: 1px; 
	 color:#165396; background-color: white; border: 1px #BEDCFF solid ; 
}

</style>
<SCRIPT LANGUAGE="JavaScript">
<!-- 
function doSubmit(){
     if(document.forms[0].projectDDL.value=="" ){
        alert("กรุณาเลือกโครงการด้วย");
        return;
     }else{  
	     //validate from client side
		 document.forms[0].action="<%=request.getContextPath()%>/SVCMasterGCalendarServlet?cmd=search";
		 document.forms[0].submit();
	 }
}
-->
</SCRIPT>

<base target="_self">
</HEAD>

   
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM name="callForm" METHOD="POST" ACTION="" > 


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >

<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="350">กำหนดเวลานัดเข้าตรวจสอบรายการซ่อม (By Google Calendar)</td>
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
	    <td class="item ; dotline01" height="22" width="12%" valign="top">โครงการ :</td>
	    <td height="22" width="88%" class="dotline01">
		   
		   <!-- Project List -->
		    <table border="0" width="100%" cellspacing="0" cellpadding="0">		
				<tr><td>
				<select name="projectDDL" id="projectDDL" style="width:350px; height:24px" > 
						<option value="" >------ กรุณาเลือกโครงการ ------</option>
   							<%
							List  arrList = null;
							if(projectDDL!=null && projectDDL.size()>0){
								Iterator it = projectDDL.iterator();
								 String select = "";
								 String StrValue = "";
								while(it.hasNext()){
								    select = "";
							        StrValue = ""; 									
									arrList =(ArrayList)it.next();									
									StrValue = doString.checkString(arrList.get(0).toString())+":"+doString.checkString(arrList.get(1).toString());
									if (StrValue.equals(sel_project)){
									 	select="selected"; 
									}else{ 
										select=""; 
									} %>
									 	<option value="<%=StrValue%>"  <%=select %> ><%=arrList.get(0)%>-<%=arrList.get(1)%> <%=doString.checkString(doString.DisplayThai(arrList.get(2).toString())) %></option>
								   <%}
								} %>	 
   							</select> 					
						 &nbsp;<a href="javascript:doSubmit();">
						 <img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a>
				</td></tr>  
			</table>						
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
	        <tr height="25">
	          <td class="col_name" width="100%">GOOGLE CALENDAR
	          </td>
	        </tr>  
	        <tr >
	          <td class="side01" width="100%">
	     <%
          if(!"".equals(ReadOnlyUrl)){
         %>
	        <iframe src="<%=ReadOnlyUrl %>" 
	        width="100%" height="530" frameborder="0" style="border:1px solid rgb(170,200,250)"></iframe>
        <%}else{ %>
          &nbsp;
         <%} %>
	          
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
<table border="0" width="100%" cellspacing="1" cellpadding="1">
  <tr>
    <td align='center' colspan="2"><b>ตัวอย่างการวิธีดูตารางนัดหมาย Calendar</b></td>
  </tr>
  <tr>
    <td align='left' width="400"><img border="0" src="images/titleFormat.jpg" width="429" height="103" ></td>
    <td align='left' valign="top">
    	<table border="0" width="100%" cellspacing="1" cellpadding="1">
		  <tr>
		    <td align='left' colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>ตัวย่อชื่อระบบ</b></td>
		  </tr>
  		 <tr>
    	  <td align='right' width="10%" >SVC</td>
   		  <td align='left'>: ระบบแจ้งซ่อมทั่วไป</td>
 		 </tr>
 		  <tr>
    	  <td align='right' >EVC</td>
   		  <td align='left'>: ระบบ e-Service</td>
 		 </tr>
 		 <tr>
    	  <td align='right' >IND</td>
   		  <td align='left'>: ระบบแนะนำบ้าน</td>
 		 </tr>
 		  <tr>
    	  <td align='right' >CUP1,CUP2</td>
   		  <td align='left'>: ระบบ Check Up</td>
 		 </tr>
		</table>
    </td>
  </tr>
</table>

<br style="font-size:10pt">
<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
	<tr>
		<td width="100%" class="copyright" align="center">Best viewed
		with 800x600 screen resolution on&nbsp;an Internet Explorer version 5
		และ 5.5 <br>
		ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;
		หรือ โทร. 0-2230-8279 (คุณประพัฒน์ ฝ่ายบริการ)&nbsp; 0-2230-8491-5
		(ฝ่าย IT) <br>
		<img src="images/copyright.gif" width="475" height="26"></td>
	</tr>
</TABLE>

</td>
</tr>
</table>
</FORM>
</BODY>
</HTML>
