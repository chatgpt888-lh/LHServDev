<%@page language="java" contentType="text/html; charset=TIS-620"
	pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%@page import="java.text.*" %>
<%@page import="java.text.SimpleDateFormat" %>
<%-- 
/**********************************************/
 * create by : pradoem wonkraso
 * date time: 2015.08.09
 * Last modify :
 * version :1.0
 * project Name : Report SVC 
 * description :  Report สรุป Call Service Center แยกตาม Column ตามเดือน
***************************************************/
--%>
<%!
	//For Year   current year-3 && year+4 
	//thai year formate ex.2555,2556
	private static ArrayList getYearList(int countYY){
		ArrayList yyList = new ArrayList();		
		for(int c=0;c<8;c++){
			yyList.add(c,""+countYY++);
		}			
		return yyList;
	}
 %>
 
 <%
   Calendar calendar = Calendar.getInstance(Locale.ENGLISH);  
   int curMonth = calendar.get(Calendar.MONTH);
   int curYear = calendar.get(Calendar.YEAR);
 //***************Initail date,month,year **************************
	SimpleDateFormat th_formatter = new SimpleDateFormat("yyyy-MM-dd", new Locale("th","TH"));
	SimpleDateFormat en_formatter = new SimpleDateFormat("yyyy-MM-dd", new Locale("en","US"));	
	java.util.Date curDate = new java.util.Date();
	java.util.Date toDate = new java.util.Date();		
	toDate.setYear(curDate.getYear()-7);  //current year-3  list year	
	String []tempYY = th_formatter.format(toDate).split("\\-");
	
	int countYY = Integer.parseInt(tempYY[0]); //thai current year
	ArrayList yyList = getYearList(countYY);
//------------------------------------------
 ArrayList projectDDL = (ArrayList)request.getAttribute("projectList");
 String err_code = request.getAttribute("er_code")==null?"":request.getAttribute("er_code").toString();
 %>
 
<HTML>
<HEAD>
<TITLE>รายงานฐานการรับสายตามเดือน</TITLE>

<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<style type="text/css">
.box2 {  font-family: Tohama,Arial,sans-serif; font-size:10.1pt; font-weight:normal;
	padding-top: 1px; padding-right: 1px; padding-bottom: 1px; padding-left: 1px; 
	 color:#165396; background-color: white; border: 1px #BEDCFF solid ; 
}
</style>

<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
<!--
function formLoadErrorCode(){
	//err_code  E01 = invalidate ,E02= Find not found record
	var err_code = "<%=err_code%>";
	if(err_code != ""){
		if(err_code=='E02'){
			alert("ไม่มีแปลงที่โอนในช่วงเวลาดังกล่าว.");
		   return;
		}
	}
}

function doGenReport(){
	//alert("test");
	if(document.forms[0].yyDDL.value ==""){
		document.forms[0].yyDDL.focus();
		document.forms[0].yyDDL.select;
		alert("กรุณาปีด้วย!!");
	    return;
	}else if(document.forms[0].typeDDL.value ==""){
		document.forms[0].typeDDL.focus();
		document.forms[0].typeDDL.select;
		alert("กรุณาเลือกประเภทรายงาน!!");
	    return;	
	}else if(document.forms[0].projSelDDL.options.length==0) {
		 alert(" กรุณาเลือกโครงการอย่างน้อย 1 โครงการ !");
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
			 	document.forms[0].multiFlag.value = 0;
				doSubmitForm();
		}
	 }else{//เลือกโครงการเท่ากับ mulitiple project
	 	for(i=row;i<document.forms[0].projSelDDL.options.length;i++) {
			document.forms[0].projSelDDL.options[i].selected = true;	
	 	} 
	 	document.forms[0].multiFlag.value = 1;
		doSubmitForm();
	 }
}

function doSubmitForm(){
	do_totals1();
	document.forms[0].action="<%=request.getContextPath()%>/SERV_ReportSvcMonthlyServlet?cmd=GenReport";
	document.forms[0].submit();
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
-->
</script>
<script language="javascript">
    function submitForm(oForm) {
	    dototals1();
	    oForm.submit();
	    // return true;
    }
    function do_totals1() {
   	 	document.all.pleasewaitScreen.style.pixelTop = (document.body.scrollTop + 120);
    	document.all.pleasewaitScreen.style.visibility = "visible";
	    document.getElementById("img1").innerHTML= "<img src=\"<%=request.getContextPath()%>/images/p_loading.gif\" HEIGHT=\"60px\">";
    }
    function do_totals2() {
    document.all.pleasewaitScreen.style.visibility = "hidden";
    }
    function lengthy_calculation() {
    	while(true) {
    	}
    }
</script>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="formLoadErrorCode();">
<FORM METHOD="POST" ACTION="" name="frm">
<input type="hidden" name="multiFlag" value="">

<!-- ############################## -->
	<DIV ID="pleasewaitScreen" STYLE="position: absolute; z-index: 0; top: 45%; left: 42%; visibility: hidden">
	<TABLE BORDER="1" BORDERCOLOR="rgb(180,210,250)" CELLPADDING="0" CELLSPACING="0" 
	HEIGHT="125px" WIDTH="265px" ID="Table1">
	<TR>
	<TD BGCOLOR="#FFFFFF" ALIGN="CENTER" VALIGN="MIDDLE" class="test">
	<font color="rgb(255,120,0)" Size=3><b>Loading... Please wait</b></font>
	<br>
	<br>
	  <span id="img1"></span>
	</TD> 
	</TR>
	</TABLE>
	</DIV>

<!-- ############################## -->
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >   
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">
          &nbsp;รายงานฐานการรับสายตามเดือน</td>
        </tr>
      </table>
<br style="font-size:10pt">
              
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">กรุณาเลือกช่วงเวลาและประเภทที่ต้องการ</td>
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
	<!--  ################################## --><br>
	<table border="0" width="100%" cellspacing="0" cellpadding="0">
  	<tr>
    <td class="item ; dotline01" height="22" width="15%">ประเภท :</td>
    <td height="22" width="%" colspan="3" class="dotline01">
		<select size="1" class="box2" style="width:100px" name="yyDDL" >
        <option value=''>---ปี---</option>
        <%
       String selected = "";
		for(int i = 0;i<yyList.size();i++){	
		    int pYY = Integer.parseInt(yyList.get(i).toString())-543;   //2012,2555
			if(1==1){
				selected = "selected";
			}else{
				selected = "";
			}%>
				<option value="<%=pYY%>" <%=selected %>><%=yyList.get(i)%></option>
			<%} %> 
     </select>	

    </td>
  	</tr>
  	<tr>
    <td class="item ; dotline01" height="22" width="15%">ประเภท :</td>
    <td height="22" width="%" colspan="3" class="dotline01">
		<select size="1" class="box2" style="width:250px" name="typeDDL" >
       			<option value=''>---กรุณาเลือกประเภทรายงาน ---</option>
				<option value="type" >ประเภทการแจ้ง</option>
				<option value="agent" >ตาม Agent</option>
				<option value="project" >ตามโครงการ</option>
     	</select>	
    </td>
  	</tr>
  	
	</table>
	<!--  ################################## -->
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
			  <%
			      //<option value="AA:999">---ทุกโครงการ---</option>
				   List  arrList = null;
				   if(projectDDL!=null && projectDDL.size()>0){
						Iterator it = projectDDL.iterator();
						String strValue = "";
						String strName = "";
						while(it.hasNext()){
								 strValue = ""; 									
								 arrList =(ArrayList)it.next();										
								 strValue = doString.checkString(arrList.get(0).toString());
								 strName =  arrList.get(1).toString();
								if("AA:999".equals(strValue)){
								    strName = "---- ALL Project ----";
								 }
							%>
								<option value="<%=strValue%>"  ><%=strName%></option>
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
            <a href="javascript:doGenReport();" ><img border="0" src="images/act_generate.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp; 
            </td>                    	                 	
            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="javascript:history.back();"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="SERV_Home.jsp" target="_self"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
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