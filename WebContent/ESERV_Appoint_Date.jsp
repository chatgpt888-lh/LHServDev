<%@page language="java" contentType="text/html; charset=TIS-620"
	pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%-- 
/**********************************************/
 * create by : pradoem wonkraso
 * date time: 2012.06.25
 * Last Update : 2013.10.15
 * version :1.0
 * project Name : E-Service
 * description : this is page for display && Master Data Appiont date form
***************************************************/
--%>
<%



/*System.out.println("***************** Parameter JSP **************************");
String ParameterNames = "";
for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
 ParameterNames = (String)e.nextElement();
 System.out.println(ParameterNames + " = "+request.getParameter(ParameterNames));
}
System.out.println("******************* Parameter JSP  ************************");*/




	ArrayList projectDDL = (ArrayList)session.getAttribute("projectDDL");
	ArrayList timeList = (ArrayList)session.getAttribute("timeList");
	ArrayList sysList = (ArrayList)session.getAttribute("ss_list_sys_type");
	
	
	String sel_project	= session.getAttribute("selProj")==null?"": session.getAttribute("selProj").toString();
	  
	String codeDDL = request.getAttribute("codeDDL")==null?"":request.getAttribute("codeDDL").toString();
	if(codeDDL.equals("")){
	    codeDDL = request.getParameter("sysTypeDDL");
	}
	String mode = request.getParameter("mode")==null?"":request.getParameter("mode");  
	int val = 1;	
	String projectNameThai = "";
	projectNameThai = request.getParameter("projectNameThai")==null?"" :request.getParameter("projectNameThai").toString();
	
	

 %>
<HTML>
<HEAD>
<TITLE>กำหนดเวลานัดเข้าตรวจสอบรายการซ่อม</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
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
var ggWinCal ;
function SelectAppointDate(ArgValue) {
		//doucument.forms[0].chkList.value = ArgValue;
		callForm.ChkList.value = 1;
	    var vWinCal = window.open('ESERV_Calendar.jsp','Calendar','width=820, height=333, status=no, resizable=no, top=100, left=0');		
		vWinCal.opener = self;
		ggWinCal = vWinCal;	
}

function doGO(){
      if( document.forms[0].projectDDL.value=='' ){
         alert("กรุณาเลือกโครงการด้วย...");
         doucument.forms[0].projectDDL.focus();
         doucument.forms[0].projectDDL.select();
      }else{
		  document.forms[0].action="<%=request.getContextPath()%>/ESERV_AppointDateServlet?cmd=loadTime";
		  document.forms[0].submit();
	  }
}

//create by pradoem 
//validate checkbox
  function validateCheckBox(){
		var chks = document.getElementsByName('timeChecked');
		var checkCount = 0;
		for (var i = 0; i < chks.length; i++){

			if(chks[i].checked){
				//if(document.forms[0].productTypeDDL.value==""){
				if(document.getElementById("sysDDL"+i).value==""){					 
					alert("กรุณาเลือกเวลานัดหมายของระบบ!!");
					//document.forms[0].productTypeDDL.focus();
					document.getElementById("sysDDL"+i).focus();
					//document.forms[0].productTypeDDL.select();
					document.getElementById("sysDDL"+i).select();
					checkCount = 0;
					return false;
				}else{
					checkCount++;
				}
			}
		}
		if (checkCount < 1){
			//alert("Please select at least four.");
			return false;
		}
		return true;
    }
function trim(str){
    if(!str || typeof str != 'string')
        return null;
    return str.replace(/^[\s]+/,'').replace(/[\s]+$/,'').replace(/[\s]{2,}/,' ');
}

function doSubmit(){
      var checkedLength = $("input[name='timeChecked']:checked").length;

     if(trim(document.forms[0].MrnList.value)=="" || document.forms[0].MrnList.value.length == 0){
        alert("กรุณาเลือกวันนัดเข้าตรวจสอบด้วย");
        return;
     }else if($('#projectDDL').val()==''){
    	 alert("กรุณาเลือกโครงการ");
    	 $('#projectDDL').focus();
    	 return;
     }else if($('#sysTypeDDL').val()==''){
    	 alert("กรุณาเลือกระบบที่ต้องการตั้งวัน-เวลา นัดหมายเข้าตรวจสอบ");
    	 $('#sysTypeDDL').focus();
    	 return;
    }else if(validateCheckBox("timeChecked")==false){
	    alert("กรุณาเลือกเวลานัดเข้าตรวจสอบ อย่างน้อย 1 รายการ!");
	    $('input[type="checkbox"]')[1].focus();	 
	    return;  
	}else if(checkedLength>13){
		alert("!! กรุณาเลือกช่วงเวลาไม่เกิน 13 ช่วงเวลา!  (period ที่เลือก "+checkedLength+" ) ");
	    $('input[type="timeChecked"]')[1].focus();	  
	    return;
	 }else{ 
	     //validate from client side
		 document.forms[0].action="<%=request.getContextPath()%>/ESERV_AppointDateServlet?cmd=formSubmit";
		 document.forms[0].submit();
		 //alert("Submit "+checkedLength);
	 }
}


//validate check box
function validateCheckBox(elementName){
		var chks = document.getElementsByName(elementName); //'chkDel'
		var checkCount = 0;
		for (var i = 0; i < chks.length; i++){
			if (chks[i].checked){
				checkCount++;
			}
		}
		if (checkCount < 1){
			//alert("Please select at least four.");
			return false;
		}
		return true;
 }


//create by pradoem 
//click check all uncheck all
function checkAllBox(obj){
  var theForm = obj.form;
  var i;
  if(obj.checked){
   for(i=1;i<theForm.length; i++){
     theForm[i].checked = true;
   }
  }else if(!obj.checked){
   for(i=1;i<theForm.length; i++){
     theForm[i].checked = false;
   }
  }
}

 $(document).ready(function() {
 
    $('#projectDDL').select2({
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


-->
</SCRIPT>

<style type="text/css">

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
    
</style>


<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM name="callForm" METHOD="POST" ACTION="" >
<INPUT TYPE="HIDDEN" NAME="ChkList" value="">
<INPUT TYPE="HIDDEN" NAME="MrnTotDate" value="">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
		<td width="100%" class="BD">
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="100%" class="bigh"><img border="0"
					src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;ข้อมูลพื้นฐาน</td>
			</tr>
		</table>
		<br style="font-size:10pt">
	<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td class="item_tab1"><img border="0" src="images/i_i.gif"
					align="absmiddle" width="20" height="20"></td>
				<td class="item_tab2" width="250">กำหนดวันนัดเข้าตรวจสอบรายการซ่อม</td>
				<td class="item_tab3"></td>
				<td>&nbsp;</td>
			</tr>
		</table>

		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="5" valign="top"><img border="0"
					src="images/Corn01.gif" width="5" height="5"></td>
				<td class="frmTop">&nbsp;</td>
				<td width="5" valign="top" align="right"><img border="0"
					src="images/Corn02.gif" width="5" height="5"></td>
			</tr>
		</table>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="100%" class="frmLR" align="center">

				<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						<td class="item ; dotline01" height="22" width="12%">โครงการ:</td>
						<td height="22" width="88%" >
					<%
					 if(mode.equals("add")){
					  %>
					    <input type="hidden" name="projectDDL" id="projectDDL" value="<%=sel_project %>">
					    &nbsp;<%=doString.DisplayThai(projectNameThai)%>
					  <%
							List  arrList = null;
							if(projectDDL!=null && projectDDL.size()>0){
								Iterator it = projectDDL.iterator();
								String StrValue = "";
								while(it.hasNext()){								
									 arrList =(ArrayList)it.next();	
									 StrValue = arrList.get(0).toString();							
									if (StrValue.equals(sel_project)){
									 	projectNameThai = arrList.get(0)+" - "+doString.checkString(doString.DisplayThai(arrList.get(1).toString()));
									}
								} 
							}	
					 }else{
					   %>
						<select name="projectDDL" id="projectDDL" class="box2" style='width:250' size='1'  > 
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
									 StrValue = doString.checkString(arrList.get(0).toString());
									if (StrValue.equals(sel_project)){
									 	select="selected"; 
									 	projectNameThai = arrList.get(0)+" - "+doString.checkString(doString.DisplayThai(arrList.get(1).toString()));
									}else{ 
										select=""; 
									} %>
									 	<option value="<%=StrValue%>"  <%=select %> ><%=arrList.get(0)%> - <%=doString.checkString(doString.DisplayThai(arrList.get(1).toString())) %></option>
								   <%}
								} %>	 
   							</select></td>
					<%}
					 %>
					</tr>
					<tr>
						<td class="item ; dotline01" height="22" width="12%">เลือกระบบ :</td>
						<td height="22" width="88%" >
											   <select size="1" name="sysTypeDDL"  id="sysTypeDDL" class="box2" style="width:250px;" >
									   		   <option value="" >------ กรุณาเลือกระบบ ------</option>
									      	   <%
									   			  if(sysList!=null && sysList.size()>0){  
									   			    HashMap hashMap = null;
													String select = "";
													String disable = "";

													String type = "";
													String code = "";
													String name = "";
										   			for (Iterator iter = sysList.iterator(); iter.hasNext(); ) {
										   					hashMap = (HashMap)iter.next(); 
															select = "";
															type = "";
															code = "";
															name = "";
															
															type = hashMap.get("xTYPE").toString();
															code = hashMap.get("xCODE").toString();
															name = hashMap.get("xNAME").toString();
															
															disable = "";
															if(code.equals("01")||code.equals("03") ||code.equals("05")){
															 disable = "disabled";
															}
	
															if (code.equals(codeDDL)){
																select="selected"; 
															}else{ 
																select="";  
															}%>
															<option value="<%=code%>"  <%=select %> <%=disable %>><%=code%> <%=name%></option>
														<%}
													} %>
												 </select> 				
						 &nbsp;&nbsp;&nbsp;&nbsp;
						 <a href="javascript:doGO();">
						 <img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a></td>
					</tr>

					<tr>
					<td class="item ; dotline01" colspan="2">&nbsp;</td>
					</tr>
				</table>

				</td>
			</tr>
		</table>

		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="5" valign="bottom"><img border="0"
					src="images/Corn03.gif" width="5" height="5"></td>
				<td class="frmBottom">&nbsp;</td>
				<td width="5" valign="bottom" align="right"><img border="0"
					src="images/Corn04.gif" width="5" height="5"></td>
			</tr>
		</table>

		<br style="font-size:5pt">

		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<!-- Left Column -->
				<td width="50%" style="padding-right:4px" valign="top">
				<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						<td width="5" valign="top" bgcolor="#D7E6FF"><img border="0"
							src="images/Corn01.gif" width="5" height="5"></td>
						<td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
						<td width="5" valign="top" align="right" bgcolor="#D7E6FF">
						<img border="0" src="images/Corn02.gif" width="5" height="5"></td>
					</tr>
				</table>

				<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						<td width="100%" class="frmL" valign="top">
						<table border="0" width="100%" cellspacing="0" cellpadding="0" >
							<tr>
								<td class="col_name" width="80%">ระบุวันที่นัดเข้าตรวจสอบ <img
									src="images/i_calendar.gif" width="18" height="18"
									align="absmiddle" hspace="5" style="cursor:hand"
									onClick ="SelectAppointDate(<%=val %>);">
									</td>
							</tr>
							<tr>
								<td class="dotline ; item" width="80%" align="center">
							 	<TEXTAREA name="MrnList" cols=35 rows=6 wrap=physical style="font-family: MS Sans Serif;font-size:10pt" readonly class="box7">
								</TEXTAREA>
								</td>
							</tr>
						</table>
						</td>
					</tr>
				</table>

				<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						<td width="5" valign="bottom"><img border="0"	src="images/Corn03.gif" width="5" height="5"></td>
						<td class="frmBottom">&nbsp;</td>
						<td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
					</tr>
				</table>

				</td>
				<!-- Left Column End -->
				<!-- Right Column -->
				<td width="50%" style="padding-left:4px" valign="top">

				<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						<td width="5" valign="top" bgcolor="#D7E6FF"><img border="0"
							src="images/Corn01.gif" width="5" height="5"></td>
						<td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
						<td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img
							border="0" src="images/Corn02.gif" width="5" height="5"></td>
					</tr>
				</table>

				<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						<td width="100%" class="frmL" valign="top">
							<table border="0" width="100%" cellspacing="0" cellpadding="0">
								<tr>
								   <td class="col_name" width="4%"></td>
									<td class="col_name" width="10%">
									<input type="checkbox" name="C1" value="ON" checked  onclick="checkAllBox(this)"></td>
									<td class="col_name" width="50%">เวลาที่นัดเข้าตรวจสอบ</td>
								</tr>
						
						<%
								List  arrList2 = null;
								int i = 0;
								int cnt = 1;
								if(timeList!=null && timeList.size()>0){
								Iterator it = timeList.iterator();
								while(it.hasNext()){  								
									 arrList2 =(ArrayList)it.next();
									 %>
									<tr>
									 <td align="center" class="dotline"  width="4%"><%=cnt++ %></td>
									 <td align="center" class="dotline" width="10%">
									<input type="checkbox" name="timeChecked" id="chk<%=i %>" value="<%=arrList2.get(0).toString() %>" checked 
 										></td>
									<td class="dotline ; item" width="50%"><%=arrList2.get(0).toString() %></td>
									<!--  <td class="dotline ; item" width="40%">&nbsp;</td>-->
									</tr>
									 <%
									   i++;
									 }
								}else{%>
								   <tr>
								        <td align="center" class="dotline"  width="4%">&nbsp;</td>
										<td align="center" class="dotline ; item" width="10%">&nbsp;</td>
										<td class="dotline ; item" width="50%">&nbsp;</td>
									</tr>
									<tr>
									    <td align="center" class="dotline" width="4%">&nbsp;</td>
										<td align="center" class="dotline ; item" width="10%">&nbsp;</td>
										<td class="dotline ; item" width="50%">&nbsp;</td>
									</tr>
							<% }
						%>			
							</table>
						</td>
					</tr>
				</table>
				<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						<td width="5" valign="bottom"><img border="0"
							src="images/Corn03.gif" width="5" height="5"></td>
						<td class="frmBottom">&nbsp;</td>
						<td width="5" valign="bottom" align="right"><img border="0"
							src="images/Corn04.gif" width="5" height="5"></td>
					</tr>
				</table>
				</td>
				<!-- Right Column End -->
			</tr>
		</table>

		<br style="font-size:10pt">

		<table border="0" width="100%" cellspacing="0" cellpadding="0"
			height="30">
			<tr>
				<td class="act_tab1"></td>
				<td width="75" class="act_tab2"><a
					href="javascript:doSubmit();"><img border="0"
					src="images/act_submit.gif" onmouseout=nereidFade(this,70,50,5)
					onmouseover=nereidFade(this,100,50,5)
					style="FILTER: alpha(opacity=70)" width="70" height="27"></a></td>

				<td class="act_tab3"></td>
				<td class="act_tab4"><a href="javascript:history.back()"
					target="_top"><img border="0" src="images/bu_back.gif"
					align="absmiddle" width="50" height="15"></a>&nbsp; <a
					href="SERV_Home_VP.jsp"><img border="0" src="images/bu_home.gif"
					align="absmiddle" width="50" height="15"></a></td>
			</tr>
		</table>
		</td>
	</tr>
</table>
<br style="font-size:30pt">
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
<input type="hidden" value="<%=i %>" name="cntTimeCheckList">
<input type="hidden" value="<%=projectNameThai%>" name="projectNameThai">
</FORM>
</BODY>
</HTML>
