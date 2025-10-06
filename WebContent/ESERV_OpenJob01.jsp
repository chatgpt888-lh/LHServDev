<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="java.util.*" %>
<%@page import="serv.common.*" %>
<%@page import="serv.common.User" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %> 
<%@ page import="com.lh.util.doString" %>
<%@ page import="java.text.*" %>
<%@page import="java.util.Date" %>
<%@page import="java.util.Calendar" %>
<%! 
    private static String []  GetDayOfWeek = {"อาทิตย์","จันทร์","อังคาร","พุธ","พฤหัสบดี","ศุกร์","เสาร์",""};
	private static String  thaiDateFormate(String tempDate){
	  //IN format : 2555-06-28  ,2012-06-28
	  //Out format : 28/06/2555
		if(!tempDate.equals("")){
		  String temp [] = tempDate.split("\\-");
		  //return (Integer.parseInt(temp[0])-543)+"-"+temp[1]+"-"+temp[0];
		  return temp[2]+"/"+temp[1]+"/"+(Integer.parseInt(temp[0])+543);
		}else{
			return tempDate;
		}
	}
	
   private static String ToThaiDateFormat(String date){
       if(!date.equals("")){
	        String time = date.substring(10);
			String yy = date.substring(0,10);
			String delimeter = "-";
			String [] temp = yy.split(delimeter);	
		    return temp[2]+"/"+temp[1]+"/"+ (Integer.parseInt(temp [0])+543)+time;
		}else{
		    return date;
		}
   }   
   private boolean isGuaranteeYear (String dateVaruntee){
        try{
             if(dateVaruntee.equals("")){
                return true;
             }
            Date date = Calendar.getInstance().getTime();
   		  	 // Display a date in day, month, year format//dd/MM/yyyy
   		  	DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
   		  	String today = formatter.format(date);
         	Date varunteeDate = formatter.parse(dateVaruntee);
         	Date currentDate  = formatter.parse(today);
         	if(currentDate.after(varunteeDate)){
         	     return true; //expire date vanruntee
         	}else{
         	     return false; //bettween varuntee Ok.
         	}
         }catch(ParseException ex){
	    	ex.printStackTrace();
	    	return true;// 
	    }
   }
  
%>
<%   
/************************************/
// create by pradoem
// date : 2012-03-13
// decription : for E-Service system Open job list  eser_dochd krub.
// version :1.0
//String dateTime = appointDate+" "+timeLine+":00.0 น.";
/************************************/
	String sessionId = user.getsessionId();
	String userId = user.getUserID();
	String jName = "ESERV_OpenJob01.jsp";
   // doString str = new doString();  
    List  listHD = (ArrayList)request.getAttribute("list");
    List  listDT = (ArrayList)request.getAttribute("list2");
    String mode = doString.checkString(request.getParameter("mode"),"");
    String timeLine =request.getAttribute("timeLine")==null? "" :request.getAttribute("timeLine").toString();
	String appointDate = request.getAttribute("appointDate")==null? "" :request.getAttribute("appointDate").toString();
	String iday = request.getAttribute("iDay")==null? "0" :request.getAttribute("iDay").toString();
    //for appointDate
	String flagDate = request.getAttribute("flagDate")==null?"":request.getAttribute("flagDate").toString();
	ArrayList  timeList	=(ArrayList)request.getAttribute("timeList"); //Array of Array  
	ArrayList  appoint2List	=(ArrayList)request.getAttribute("appoint2List"); //Array of Array  
	if("".equals(iday)){
	   iday = "0";
	}
	int weekDay = Integer.parseInt(iday);
   //******************************* Declare Variables for input data ********************************//  
   // System.out.println("---->TEST GuaranteeYear :"+listHD.get(10).toString());  //2007-11-28
    String status = "";  
    //String date2 = "2015-03-31";
    //date2 = "2014-06-25";
    //31/03/2558
   // System.out.println("---->TEST date2 :"+date2);
    if(isGuaranteeYear(listHD.get(10).toString())){
         status = "N";//out.println("หมดประกัน");//expire date vanruntee
     }else{
        status = "Y"; //out.println("อยู่ระหว่างประกัน"); //No expire date vanruntee
     } 
     //System.out.println("---->TEST GuaranteeYear :"+status);       
%>
<HTML> 
<HEAD>
<TITLE>OPEN JOB (ESV/LSV)</TITLE>
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
var ggWinCal ;
function selChqDate(dateType) {
	var vWinCal = window.open('calendar.jsp?dateType='+dateType,'blank','width=300,height=250,left=200,top=100');
	vWinCal.opener = self;
	ggWinCal = vWinCal;
}
function openJob() {
   do_totals1();
   document.forms[0].action="SERV_OpenJob.jsp?load=yes";
   document.forms[0].target="";   
   document.forms[0].submit();
}

function cancelJob() {
   if (confirm(" คุณแน่ใจว่าต้องการยกเลิก Inform Job ใบนี้ ?")) {
      do_totals1();
	   document.forms[0].action="<%=request.getContextPath()%>/ESERV_OpenJobServlet?cmd=can&i_docno=<%=listHD.get(11)%>&comId=<%=listHD.get(12)%>&projectId=<%=listHD.get(13)%>";
	   document.forms[0].submit();
   }
}

function doConfirm(){
	  var count = "<%=listDT.size() %>";
	  var temp = 0;
	  for(i = 1;i<=count;i++){ 
			if(document.getElementById("rbt"+i).checked == false){
			   temp++;
			}
		}
	 if(count==temp){
	     alert("กรุณาคลิกปุ่ม Cancel เนื่องจากคุณไม่ได้เลือกรายการซ่อม ");
	 }else if(document.forms[0].appointDate.value==""){
	 	 alert("กรุณากรอกวันนัดเข้าตรวจสอบ ด้วย.. ");
	     document.forms[0].appointDate.value="";
	     document.forms[0].appointDate.focus();
	 }else if(document.forms[0].timeLine.value==""){
	 	 alert("กรุณากรอกเวลาด้วย");
	     document.forms[0].timeLine.value="";
	     document.forms[0].timeLine.focus();
	 }else{ 
	      do_totals1();
		  document.forms[0].mode.value="view";
		  document.forms[0].action="<%=request.getContextPath()%>/ESERV_OpenJobServlet?cmd=view&i_docno=<%=listHD.get(11)%>&sel_project=<%=listHD.get(12)+":"+listHD.get(13) %>&iHouse=<%=listHD.get(7)%>&status=<%=status%>";
		  document.forms[0].submit();
	 }
}

function doSubmit(vDate,vTime){
 	if(document.forms[0].iLock.value==""){
		 alert("ไม่สามารถทำรายการได้เนื่องจากแปลงเป็นค่าว่าง กรุณาติดต่อผู้ดูแลระบบ.. ");
		  return;
	 }else{
	      do_totals1();
		  document.forms[0].mode.value="add";
		  document.forms[0].appointDate.value = vDate;
		  document.forms[0].timeLine.value = vTime;
		  document.forms[0].action="<%=request.getContextPath()%>/ESERV_OpenJobServlet?cmd=add&i_docno=<%=listHD.get(11)%>&sel_project=<%=listHD.get(12)+":"+listHD.get(13)%>&iHouse=<%=listHD.get(7)%>&status=<%=status%>";
		  document.forms[0].submit();
	 } 
}

function doChangeDDL() {
 	  document.forms[0].mode.value="CHGDDL";	
	  document.forms[0].action="<%=request.getContextPath()%>/ESERV_OpenJobServlet?cmd=find&i_docno=<%=listHD.get(11)%>&sel_project=<%=listHD.get(12)+":"+listHD.get(13) %>";
	  document.forms[0].submit();
}
//-->
</script>
<SCRIPT language="JavaScript">
<!--
//  check for valid numeric strings	
function IsNumeric(strString) {
   var strValidChars = "0123456789.";
   var strChar;
   var blnResult = true;
   if (strString.length == 0) return false;
   //  test strString consists of valid characters listed above
   for (i = 0; i < strString.length && blnResult == true; i++){
      strChar = strString.charAt(i);
      if (strValidChars.indexOf(strChar) == -1){
         blnResult = false;
        }
      }
 	return blnResult;
  }
 // -->
</SCRIPT>
<script language="javascript">
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
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM METHOD="POST" ACTION=""  name="frmConfReten">
<input type="hidden" name="mode" value="edit">
<input type="hidden" name="eser_docno" value="<%=listHD.get(11)%>">
<input type="hidden" name="d_appoint" value="">
<input type="hidden" name="d_est_close" value="">
<input type="hidden" name="cntDesc" value="<%=listDT.size() %>">
<input type="hidden" name="iLock" value="<%=listHD.get(0) %>">
<input type="hidden" name="nCustomer" value="<%=doString.DisplayThai(listHD.get(3).toString())%>">
<input type="hidden" name="nCustel" value="<%=doString.DisplayThai(listHD.get(4).toString())%>">
<input type="hidden" name="msg1" value="นัดวันเข้าตรวจสอบวันที่">
<input type="hidden" name="msg2" value=" เวลา ">

<%-- ############################## --%>
<DIV ID="pleasewaitScreen" STYLE="position: absolute; z-index: 0; top: 45%; left: 42%; visibility: hidden">
<TABLE BORDER="1" BORDERCOLOR="rgb(180,210,250)" CELLPADDING="0" CELLSPACING="0" 
HEIGHT="125px" WIDTH="265px" ID="Table1">
<TR>
<TD BGCOLOR="#FFFFFF" ALIGN="CENTER" VALIGN="MIDDLE" class="test">
<font color="rgb(255,120,0)"><b>Loading... Please wait</b></font>
<br>
<br>
  <span id="img1"></span>
</TD> 
</TR>
</TABLE>
</DIV>
<%-- ############################## --%>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;&nbsp;LINE/E-SERVICE Inform Job List : Wait</td>
          <td width="50%" align="right">
          <!--
          <a href="#" onClick="openJob();"><img border="0" src="images/icon_open_Jop.gif" width="120" height="34"></a>
            -->
            
          </td>
        </tr>
      </table>
<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดการแจ้งซ่อม</td>
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
    <td class="item ; dotline01" height="22" width="13%">โครงการ :</td>
    <td height="22" width="39%" class="dotline01"><%=listHD.get(12) %> <%=listHD.get(13) %> <%=doString.DisplayThai(listHD.get(5).toString()) %></td>
    <td height="22" class="item ; dotline01" width="14%">เลขที่ใบแจ้งซ่อม :</td>
    <td height="22" width="34%" class="dotline01">Auto Generate<%//=listHD.get(11) %></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">บ้านเลขที่ :</td>
    <td height="22" width="39%" class="dotline01"><%=listHD.get(7) %></td>
    <td height="22" class="item ; dotline01" width="14%">แปลง :</td>
    <td height="22" width="34%" class="dotline01"><%=listHD.get(0) %></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">แบบบ้าน :</td>
    <td height="22" width="39%" class="dotline01"><%=listHD.get(6) %></td>
    <td height="22" class="item ; dotline01" width="14%">จากระบบ :</td>
    <td height="22" width="34%" class="dotline01">
      <%if(listHD.get(11).toString().indexOf("L-")!= -1){ %>
			<img src="https://img.icons8.com/color/18/000000/line-me.png">
		<%}else{ %>
			EVC
	 <%} %>
    </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ชื่อผู้แจ้ง/ลูกค้า:</td>
    <td height="22" width="39%" class="dotline01"><%=doString.DisplayThai(listHD.get(3).toString())%></td>
    <td height="22" class="item ; dotline01" width="14%">โทรศัพท์ติดต่อ :</td>
    <td height="22" width="34%" class="dotline01"><%=doString.DisplayThai(listHD.get(4).toString())%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">การประกัน :</td>
    <td height="22" width="39%" class="dotline01">
      <%
          if(isGuaranteeYear(listHD.get(10).toString())){
             out.println("หมดประกัน");
          }else{
             out.println("อยู่ระหว่างประกัน");
          }
       %>
    </td>
    <td height="22" class="item ; dotline01" width="14%">วันที่หมดประกัน :</td>
    <td height="22" width="34%" class="dotline01"><%=ToThaiDateFormat(listHD.get(10).toString()) %></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ผู้รับเรื่อง :</td>
    <td height="22" width="39%" class="dotline01"><%=doString.DisplayThai(user.getEmpName())%>

</td>
    <td height="22" class="item ; dotline01" width="14%">วันเวลาที่แจ้ง:</td>
    <td height="22" width="34%" class="dotline01"><%=ToThaiDateFormat(listHD.get(1).toString()) %> น.</td>
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
                <td class="item_tab2" width="200">รายละเอียดงานซ่อม</td>
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
    <td width="100%" class="frmLRpad01">
<%
List  arrList = null;
int i = 1;
String pathImg = "https://lineapp.lh.co.th/line-bot";
String urlImg = "";
// http://132.144.1.61/line-bot/Job_img/Document_no/2019/L-LH-075-620005/
// /Job_img/Document_no/2019
String tempImg = "";
if(listDT!=null && listDT.size()>0){
	Iterator it = listDT.iterator();
	//String select = "";
	while(it.hasNext()){
		 arrList =(ArrayList)it.next();
 %>
      <p>รายการที่ <%=i %>. <span class="dotline01">
      <input type="text" name="jobDesc<%=i %>" class="box" style="width:300px" value="<%=doString.DisplayThai(arrList.get(2).toString()) %>" <% if(mode.equals("view")){out.println("readonly");} %>>
      </span><span class="dotline01"></span>
      <%
	   if(mode.equals("view")){
	       %><label><input type="hidden" name="rbt<%=i %>"  id="rbt<%=i %>" value="<%=arrList.get(3) %>"  >
			 &nbsp;&nbsp;<% if(arrList.get(3).equals("OPN")){out.println("ซ่อม");}else{out.println("ไม่ซ่อม");} %>
			 </label>
	      <%
      }else{ 
        if(arrList.get(3).equals("CAN")){%>
			<label><input type="radio" name="rbt<%=i %>"  id="rbt<%=i %>"   value="OPN"  ></label>ซ่อม
			 <label><input type="radio"  name="rbt<%=i %>" id="rbt<%=i %>"   value="CAN" checked="checked" ></label>ไม่ซ่อม
		<%} else{%>			<label><input type="radio" name="rbt<%=i %>"  id="rbt<%=i %>"   value="OPN"  checked="checked"></label>ซ่อม
			 <label><input type="radio"  name="rbt<%=i %>" id="rbt<%=i %>"   value="CAN"  ></label>ไม่ซ่อม	
		<% }
   		 }
   		 tempImg = "";
   		 if( !"".equals(arrList.get(5).toString()) && arrList.get(5).toString().indexOf(".")!=-1 ){
    		//System.out.println(dd.substring(1,dd.length()));   
    		tempImg = arrList.get(5).toString();   
    		urlImg = pathImg+tempImg.substring(1,tempImg.length());	
    		//System.out.println("----img path :"+urlImg);
   		    %>
   		     &nbsp;&nbsp;รูปภาพงานซ่อม : <a href="<%=urlImg%>" target="_blank"><img src="<%=urlImg%>" width="25" height="20" border="0"></a>
   		   <%
   		 }
    	 i++;
  }
}
 %>
 

      <p>
      <%
      	   if("view".equals(mode) || flagDate.equals("true")){//System.out.println("------------>>Test ");
	        	out.println("ระบุวันเวลาให้เจ้าหน้าที่เข้าตรวจสอบ&nbsp;&nbsp;วัน "+GetDayOfWeek[Integer.parseInt(iday)]+" "+thaiDateFormate(appointDate)+" &nbsp;"+timeLine);
	        	%>
	        	<input type="hidden" name="appointDate"  value="<%=appointDate %>">
	        	<input type="hidden" name="timeLine"   value="<%=timeLine %>">
	        	<%
	        }else{	
	          //System.out.println("--->appoint2List :"+appoint2List.size());
	          %>	           
	           <br>&nbsp;&nbsp; ระบุวันเวลาให้เจ้าหน้าที่เข้าตรวจสอบ&nbsp;&nbsp;
      		   <span class="dotline01">
      		   <select name="appointDate" class="box2" <%// if(flagDate.equals("true")){out.println("disabled");} %>  onchange="javascript:doChangeDDL();">
      		   <option value="" >--กรุณาระบุวันที่ -- </option>
	          <%
      		  if(appoint2List!=null && appoint2List.size()>0){
	      			//for date
	      			arrList = new ArrayList();
	      			Iterator it = appoint2List.iterator();
	      			String selected = "";
	      			int x = 0;      			
					while(it.hasNext()){
					x = 0;
				 	arrList =(ArrayList)it.next();				 	
				 	x = Integer.parseInt(arrList.get(2).toString());
				   if(arrList.get(0).equals(appointDate)){
				 		selected ="selected"; 
				 		//x = Integer.parseInt(iday);
				 		weekDay = x;
				 	}else{
				 		selected = "";
				 	}
				 	%>
					<option value="<%=arrList.get(0)%>" <%=selected %> >วัน<%=GetDayOfWeek[x] %> &nbsp;<%=thaiDateFormate(arrList.get(0).toString())%></option>	
				 	<%}%>
				 </select><font color="#FF0000"> *</font> 
				 </span>
				 <%
      		}%> &nbsp;  เวลา &nbsp;  
	 			<select name="timeLine"  class="box2"  <% //if(flagDate.equals("true")){out.println("disabled");} %>>
		 		<option value="" >--กรุณาระบุเวลา-- </option>      
	         <%
	        if(timeList!=null && timeList.size()>0){	        
	        	arrList = new ArrayList();
      			Iterator it = timeList.iterator();
      			String selected = "";    			
				while(it.hasNext()){
					arrList =(ArrayList)it.next();
					if(arrList.get(0).equals(appointDate)){
				 		selected ="selected"; 
				 	}else{
				 		selected = "";
				 	}
					%>
					<option value="<%=arrList.get(0)%>"  <%=selected %>><%=arrList.get(0)%></option>	
				 	<%
				}%></select><font color="#FF0000"> *</font> 
				<% }
	       }   %>
        <br>
        <br>
        <br></p></td>
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
            <td width="260" class="act_tab2">&nbsp;
                  	<%
                  	  if("view".equals(mode)){
                  	 %>
                  	     <img border="0" src="images/act_edit.gif" onClick="javacript:history.back();"                                  
    						onMouseOut=nereidFade(this,70,50,5)    
                  			onMouseOver=nereidFade(this,100,50,5)     
                  			style="FILTER: alpha(opacity=70);cursor:hand" width="70" height="27">	&nbsp;&nbsp;
                  			<a href="javascript:doSubmit('<%=appointDate %>','<%=timeLine %>');"><img src="images/act_submit.gif" width="70" height="27" border="0"></a>
                  	<%}else{ %>
                  	     <img border="0" src="images/act_cancel.gif" onClick="javascript:cancelJob();"                                  
    					onMouseOut=nereidFade(this,70,50,5)    
                  		onMouseOver=nereidFade(this,100,50,5)     
                  		style="FILTER: alpha(opacity=70);cursor:hand" width="70" height="27">	&nbsp;&nbsp;
                  	   <a href="javascript:doConfirm();"><img src="images/act_confirm.gif" width="70" height="27" border="0"></a>
                  	<%} %>
                  	&nbsp; &nbsp;</td>   
            <td class="act_tab3"></td>   
            <td class="act_tab4">      
		    <a href="javascript:history.back();" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
          <a href="/LHServ/SERV_Index.jsp" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a>         
           </td></tr>  
        </table>  
      </td>
        </tr>
      </table>
<br style="font-size:30pt">
<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
  <tr><td width="100%" class="copyright" align="center">
  Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5  
  <br>ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;หรือ โทร. 0-2230-8279 (คุณประพัฒน์ฝ่ายบริการ)&nbsp; 0-2230-8491-5 (ฝ่าย IT)  
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE> 
<input type="hidden" name="iDay" value="<%=weekDay %>">
</FORM>
</BODY>
</HTML>

