<%@page language="java" contentType="text/html; charset=TIS-620"
	pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%@page import="java.text.*" %>
<%@page import="java.text.SimpleDateFormat" %>
<%-- 
/**********************************************/
 * create by : pradoem wonkraso
 * date time: 2012.07.18
 * Last modify :
 * version :1.0
 * project Name : E-Service
 * description : Page criteria for generate password for eser*
***************************************************/
--%>
<%!
	private static String GenNextId2(int b){
        String temp=""+b;
        String newSp_id;
        switch(temp.length()){ 
           case 1: newSp_id="0"+temp; break;
           default:newSp_id=temp;
        }
        return newSp_id;
   }  
   //DayList method
	private static ArrayList getDayList(){
		ArrayList dayList = new ArrayList();
		dayList.add(0,"");
		for(int i=1;i<32;i++){
			dayList.add(i,GenNextId2(i));
		}
		return dayList;
	}	
	//Month List method
	private static ArrayList getMonthList(){
		ArrayList mmList = new ArrayList();
		int i = 1;
		mmList.add(0,"");
		mmList.add(i++,"มกราคม");
		mmList.add(i++,"กุมภาพันธ์");
		mmList.add(i++,"มีนาคม");
		mmList.add(i++,"เมษายน");
		mmList.add(i++,"พฤษภาคม");
		mmList.add(i++,"มิถุนายน");
		mmList.add(i++,"กรกฎาคม");
		mmList.add(i++,"สิงหาคม");
		mmList.add(i++,"กันยายน");
		mmList.add(i++,"ตุลาคม");
		mmList.add(i++,"พฤจิกายน");
		mmList.add(i++,"ธันวาคม");		
		return mmList;
	}
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
 //***************Initail date,month,year **************************
	SimpleDateFormat th_formatter = new SimpleDateFormat("yyyy-MM-dd", new Locale("th","TH"));
	SimpleDateFormat en_formatter = new SimpleDateFormat("yyyy-MM-dd", new Locale("en","US"));	
	java.util.Date curDate = new java.util.Date();
	java.util.Date toDate = new java.util.Date();		
	String currentDay[] = en_formatter.format(curDate).split("\\-"); //yyyy-MM-dd	
	toDate.setMonth(curDate.getMonth()+3); //3 +current month
	String next3Month[] = en_formatter.format(toDate).split("\\-"); //yyyy-MM-dd		
	toDate.setYear(curDate.getYear()-7);  //current year-3  list year	
	String []tempYY = th_formatter.format(toDate).split("\\-");
	int countYY = Integer.parseInt(tempYY[0]); //thai current year
	ArrayList dayList =  getDayList();
	ArrayList mmList = getMonthList();
	ArrayList yyList = getYearList(countYY);
//******************************************	
 ArrayList projectDDL = (ArrayList)session.getAttribute("projDDL");
 String err_code = request.getAttribute("er_code")==null?"":request.getAttribute("er_code").toString();
 %>
<HTML>
<HEAD>
<TITLE>Generate Password Customer</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
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
var projList = new Array();
function filterProject() {
   var frm = document.forms[0];
	while (frm.projDDL.options.length>0) {
		frm.projDDL.options[frm.projDDL.options.length-1] = null;
	}
	for(var i=0;i<projList.length;i++){
		  var data = projList[i].split("#");
		  if(data[0]==frm.i_company.value || frm.i_company.value=="00") {
			  var chk = false;
			  for(var j=0;j<frm.projSelDDL.length;j++) {
				    if (frm.projSelDDL.options[j].value==data[0]+":"+data[1]) {
						chk = true;
						alert("1");
						break;
					}
			  }
			  if(!chk) frm.projDDL.options[frm.projDDL.options.length] = new Option(data[0]+"-"+data[1]+" | "+data[2],data[0]+":"+data[1]);
		  }
	} // end for
}
function clearSelProj(){
	while(document.forms[0].projSelDDL.options.length>0){
		document.forms[0].projSelDDL.options[document.forms[0].projSelDDL.options.length-1] = null;
	}
	filterProject();
}
function doGenpassword(){
	doSubmit();
}
//Action submit
function doSubmit(){
 	if(document.forms[0].projSelDDL.options.length==0) {
		 alert(" กรุณาเลือกโครงการอย่างน้อย 1 โครงการ !");
		 return false;
	 }
	 var row = 0;
	 var isAll = false;
	 if(document.forms[0].projSelDDL.options.length>1){
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
	 for(i=row;i<document.forms[0].projSelDDL.options.length;i++) {
		document.forms[0].projSelDDL.options[i].selected = true;	
	 } 	 
	 
	 if(document.forms[0].lock1.value!="" || document.forms[0].lock2.value!=""
			||document.forms[0].lock3.value!="" || document.forms[0].lock4.value!=""
			||document.forms[0].lock5.value!="" ){
			if(document.forms[0].projSelDDL.options.length>1 || document.forms[0].projSelDDL.value=='AA:999'){
			   alert("ในกรณีที่ระบุแปลง กรุณาเลือก 1 โครงการเท่านั้น.");
			   return;
			}else{
				 document.forms[0].multiFlag.value = 0;
				 document.forms[0].action="<%=request.getContextPath()%>/ESERV_GenPwdCustServlet?cmd=gen";
				 document.forms[0].submit();
			}
	 }else if(document.forms[0].projSelDDL.options.length==1){
	 	//เลือกโครงการ 1 รายการเท่านั้น
	 	if(document.forms[0].projSelDDL.value=='AA:999'){
	 	    //เลือกโครงการเท่ากับ ทุกโครงการ
			if(document.forms[0].lock1.value!="" || document.forms[0].lock2.value!=""
			||document.forms[0].lock3.value!="" || document.forms[0].lock4.value!=""
			||document.forms[0].lock5.value!="" ){
				alert("กรณีที่เลือกทุกโครงการ ไม่สามารถใส่แปลงได้ กรุณาลบแปลงด้วย..");
				document.forms[0].lock1.focus();
				return;
			}else{
			    if(validDate()){//validate date
			 	    document.forms[0].multiFlag.value = 2;
				    document.forms[0].action="<%=request.getContextPath()%>/ESERV_GenPwdCustServlet?cmd=gen";
				    document.forms[0].submit();
			    }
			}
	 	}else{
	 	   //เลือกโครงการ 1 โครงการเท่านั้น
	 	    if(validDate()){
			 	  document.forms[0].multiFlag.value = 0;
				  document.forms[0].action="<%=request.getContextPath()%>/ESERV_GenPwdCustServlet?cmd=gen";
				  document.forms[0].submit();
	 	     }
	 	   } 
	 }else{	 
	    //เลือกโครงการมากว่า 1 โครงการ
	      if(document.forms[0].lock1.value!="" || document.forms[0].lock2.value!=""
			||document.forms[0].lock3.value!="" || document.forms[0].lock4.value!=""
			||document.forms[0].lock5.value!="" ){
				alert("กรณีที่เลือกโครงการมากว่า 1 โครงการไม่สามารถใส่แปลงได้ กรุณาลบแปลงด้วย..");
				document.forms[0].lock1.focus();
				return;
			}else{
			     if(validDate()){//validate date
					 document.forms[0].multiFlag.value = 1;
					 document.forms[0].action="<%=request.getContextPath()%>/ESERV_GenPwdCustServlet?cmd=gen";
					 document.forms[0].submit();
			     }
		 }
	 }
}

function validDate() {
     var sdate = document.forms[0].dayDDL1.value;
     var smonth = document.forms[0].mmDDL1.value;
     var syear = document.forms[0].yyDDL1.value;
     var edate = document.forms[0].dayDDL2.value;
     var emonth = document.forms[0].mmDDL2.value;
     var eyear = document.forms[0].yyDDL2.value;
     //---- Check select date ---//
     if (sdate.length==0 && smonth.length==0 && syear.length==0 &&
         edate.length==0 && emonth.length==0 && eyear.length==0) {
         alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
         document.forms[0].dayDDL1.focus();
         return false;
        // return true;
     }
     var startDate = new Date(parseInt(syear,10),parseInt(smonth,10)-1,parseInt(sdate,10));
     var endDate = new Date(parseInt(eyear,10),parseInt(emonth,10)-1,parseInt(edate,10));
     if (startDate.getMonth()!=(parseInt(smonth,10)-1)) {
        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].dayDDL1.focus();
        return false;
     }
     if (endDate.getMonth()!=(parseInt(emonth,10)-1)) {
        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].dayDDL2.focus();
        return false;
     }
	if (startDate>endDate) {
	    alert(" วันที่สิ้นสุดต้องไม่น้อยกว่าวันที่เริ่มต้น ! ");
	    return false;
	}
     return true;
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

//-->
</script>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="formLoadErrorCode();">
<FORM METHOD="POST" ACTION="" name="frm">
<input type="hidden" name="multiFlag" value="">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >   
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">
          &nbsp;Generate Password Customer</td>
        </tr>
      </table>
<br style="font-size:10pt">
              
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">ระบุรายละเอียด</td>
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
    <td class="item ; dotline01" height="22" width="18%">วันที่โอน :</td>
    <td height="22" width="82%" class="dotline01">
	
	<select size="1" class="box" style="width:90px" name="dayDDL1" >
	<option value=''>---วัน---</option>
	<%
		//String selected = "";
		for(int i = 1;i<dayList.size();i++){
			//if(currentDay[2].equals(dayList.get(i))){
			//	selected = "selected";
			//}else{//	selected = "";//}
			%><option value="<%=dayList.get(i) %>"  >&nbsp;<%=dayList.get(i)%></option>
			<%}%>       
     </select>
	 &nbsp;&nbsp;
	 	<select size="1" class="box" style="width:100px" name="mmDDL1" >
	 	 <option value=''>--เดือน --</option>
	 	<%
	 	//selected = "";
		for(int i = 1;i<mmList.size();i++){
			   // if(GenNextId2(Integer.parseInt(currentDay[1])).equals(dayList.get(i))){
				//	selected = "selected";}else{selected = "";
				//}%>
					<option value="<%=i%>"  <%//=selected %>>&nbsp;<%=mmList.get(i)%></option>
			<%} %> 
     </select>
	  &nbsp;&nbsp;
	 	<select size="1" class="box" style="width:100px" name="yyDDL1" >
        <option value=''>---ปี---</option>
        <%
       // selected = "";
		for(int i = 0;i<yyList.size();i++){	
		    //int yy = Integer.parseInt(yyList.get(i).toString())-543;   //2012,2555
		    String pYY = Integer.parseInt(yyList.get(i).toString())-543+"".trim();
			//if(currentDay[0].equals(pYY)){
			//	selected = "selected";}else{
			//		selected = "";
			//}%>
				<option value="<%=pYY%>" <%//=selected %>><%=yyList.get(i)%></option>
			<%} %> 
     </select>
	 &nbsp;ถึง &nbsp;
	 <select size="1" class="box" style="width:90px" name="dayDDL2" >
	<option value=''>---วัน---</option>
	<%
		 //selected = "";
		for(int i = 1;i<dayList.size();i++){
			//if(next3Month[2].equals(dayList.get(i))){
			//	selected = "selected";
			//}else{
			//	selected = "";
			//}%>
				<option value="<%=dayList.get(i) %>"   <%//=selected %>>&nbsp;<%=dayList.get(i)%></option>
			<%}%>       
     </select>
	 &nbsp;&nbsp;
	 	<select size="1" class="box" style="width:100px" name="mmDDL2" >
	 	 <option value=''>--เดือน --</option>
	 	<%
	 	//selected = "";
		for(int i = 1;i<mmList.size();i++){
			//if(GenNextId2(Integer.parseInt(next3Month[1])).equals(dayList.get(i))){
			//		selected = "selected";
			//	}else{
			//		selected = "";
			//	}%>
					<option value="<%=i%>"  <%//=selected %>>&nbsp;<%=mmList.get(i)%></option>
			<%}%> 
     </select>
	  &nbsp;&nbsp;
	 	<select size="1" class="box" style="width:100px" name="yyDDL2" >
        <option value=''>---ปี---</option>
        <%
       // selected = "";
		for(int i = 0;i<yyList.size();i++){	
		    //int yy = Integer.parseInt(yyList.get(i).toString())-543;
		     String pYY = Integer.parseInt(yyList.get(i).toString())-543+"".trim();
			//if(next3Month[0].equals(pYY)){
			//		selected = "selected";
			//	}else{
			//		selected = "";
			//}%>
				<option value="<%=pYY%>" <%//=selected %>><%=yyList.get(i)%></option>
			<%} %> 
     </select>
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
		  <select size="20" name="projDDL" multiple class="box" style="width:300px" ondblclick="MoveSelect(frm.projDDL, frm.projSelDDL,'SEL');">
		       <option value="AA:999">--ทุกโครงการ--</option>
		  <%
			   List  arrList = null;
			   if(projectDDL!=null && projectDDL.size()>0){
					Iterator it = projectDDL.iterator();
					String strValue = "";
					while(it.hasNext()){
							 strValue = ""; 									
							 arrList =(ArrayList)it.next();										
							 strValue = doString.checkString(arrList.get(0).toString());
						%>
								<option value="<%=strValue%>"  >[<%=arrList.get(0)%>] - <%=doString.checkString(doString.DisplayThai(arrList.get(1).toString())) %></option>
						<%}
				} %>	       
			</select>
			</td>
          <td align="center" class="dotline" width="10%">&nbsp;</td>
          <td align="center" class="dotline" width="45%" rowspan="6" style="padding:15px 0px 15px 0px">
		  <select size="20" name="projSelDDL" multiple class="box" style="width:300px" ondblclick="MoveSelect(frm.projSelDDL, frm.projDDL,'SEL');">
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
</table>
<br style="font-size:2pt">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop">&nbsp;</td>
    <td width="5" valign="top" align="right"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>

<br style="font-size:2pt">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR" align="center">
	<table border="0" width="100%" cellspacing="0" cellpadding="0">
	  <tr>
		<td class="item ; dotline01" height="22" width="18%">ระบุแปลง (กรณีโครงการเดียว) :</td>
		<td height="22" width="82%" class="dotline01">
		 &nbsp;&nbsp;1.<input type="text" name="lock1" value="" size="10" maxlength="5">
		  &nbsp;&nbsp;2.<input type="text" name="lock2" value="" size="10" maxlength="5">
		 &nbsp; &nbsp;3.<input type="text" name="lock3" value="" size="10" maxlength="5">
		 &nbsp;&nbsp;4.<input type="text" name="lock4" value="" size="10" maxlength="5">
		  &nbsp;&nbsp;5.<input type="text" name="lock5" value="" size="10" maxlength="5">
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

<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="150" class="act_tab2">
            <a href="javascript:doGenpassword();" ><img border="0" src="images/act_generate.gif"                                   
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

