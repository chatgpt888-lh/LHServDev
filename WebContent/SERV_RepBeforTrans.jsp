<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="java.util.Date" %>
<%@page import="java.text.*" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@ page import="com.lh.util.doString" %>
<%@ include file="/confirmLogin.jsp" %>
<%!
public static String Get2Digit(String temp){
    String newSp_id;
    switch(temp.length()){ 
       case 1: newSp_id="0"+temp; break;
       default:newSp_id=temp;
    }
    return newSp_id;
}	
%>

<%-- 
/**********************************************/
 * create by : pradoem wonkraso
 * date time: 2014.10.20
 * Last modify :
 * version :1.0
 * project Name : LHSERV
 * description : this is page for Gen report online with search form criteria 
***************************************************/
--%>
<%
java.util.Calendar currentCal = java.util.Calendar.getInstance();  
java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyy-MM-dd", Locale.US);
Calendar rightNow = Calendar.getInstance();
int curday = rightNow.get(Calendar.DAY_OF_MONTH);
String month = Integer.toString(rightNow.get(Calendar.MONTH)+1);
String year = Integer.toString(rightNow.get(Calendar.YEAR));
String today = curday+"/"+Get2Digit(month)+"/"+(Integer.parseInt(year)+543);
//System.out.println("-->"+today);



Object  obIpvQCHD     = request.getAttribute("listIpvQCHD");
ArrayList listIpvQCHD = null;

if(obIpvQCHD!=null){ listIpvQCHD = (ArrayList)obIpvQCHD;
}else{  listIpvQCHD = new ArrayList();}

ArrayList projectList = (ArrayList)request.getAttribute("projectList");
//-----------------------Paging--------------------------
String displayLine = request.getAttribute("displayLine")==null?"10":request.getAttribute("displayLine").toString();  
String displayLinkPage = request.getAttribute("displayLinkPage")==null?"":request.getAttribute("displayLinkPage").toString();  
String recordNo = request.getAttribute("recordNo")==null?"1":request.getAttribute("recordNo").toString();  
Object obj2 = request.getAttribute("pageNoDDL");
ArrayList  pageList = null;
if(obj2!=null){
   pageList = (ArrayList)obj2;
}else{
  pageList = new ArrayList();
}
//-----------------------Paging--------------------------

String projectSel	 = request.getAttribute("projectSel")==null?"": request.getAttribute("projectSel").toString();//LH:075
String rbtType     = request.getAttribute("rbtType")==null?"1": request.getAttribute("rbtType").toString();//0,1
String fDate     = request.getAttribute("fdateTxt")==null?"": request.getAttribute("fdateTxt").toString();//2014-09-22
String tDate     = request.getAttribute("tdateTxt")==null?"": request.getAttribute("tdateTxt").toString();//2014-09-22
String lockTxt     = request.getAttribute("lockTxt")==null?"": request.getAttribute("lockTxt").toString();//01A01


if("".equals(fDate)){
	fDate=today;
}
if("".equals(tDate)){
	tDate=today;
}
if("".equals(rbtType)){
	rbtType = "1"; //Set default Radio button
}

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>

<TITLE>Check List บันทึกรายการเก็บงานก่อนโอน</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
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
</style>
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">
<!--
function onLoad() {
  <%
    //First step or default
    if("1".equals(rbtType)||"2".equals(rbtType)){
     %>
	 	document.getElementById("lockTxt").value = "";
		document.getElementById("lockTxt").disabled = true; //Disable
		document.getElementById("fdateTxt").disabled = false;
		document.getElementById("tdateTxt").disabled = false;
		document.getElementById("calImg1").style.display=''; //Enable
		document.getElementById("calImg2").style.display=''; //Enable
     <%
    }else{%>
		//document.getElementById("lockTxt").value = "";
		document.getElementById("lockTxt").disabled = false;
		document.getElementById("fdateTxt").disabled = true;
		document.getElementById("tdateTxt").disabled = true;
		document.getElementById("calImg1").style.display='none'; //Enable
		document.getElementById("calImg2").style.display='none'; //Enable
    <%	
    }
  %>
} 

	function doClickChange(param){
		//alert(param);
	    if(param==1 || param==2) {	
		 	document.getElementById("lockTxt").value = "";
			document.getElementById("lockTxt").disabled = true; //Disable
			document.getElementById("fdateTxt").disabled = false;
			document.getElementById("tdateTxt").disabled = false;
			document.getElementById("calImg1").style.display=''; //Enable
			document.getElementById("calImg2").style.display=''; //Enable
	     }else {
	 		document.getElementById("lockTxt").disabled = false;
			document.getElementById("fdateTxt").disabled = true;
			document.getElementById("tdateTxt").disabled = true;
			document.getElementById("calImg1").style.display='none'; //Enable
			document.getElementById("calImg2").style.display='none'; //Enable
	     }
	}

  //-----do search form
  function doSearchForm() {
		var obj  = document.forms[0].rbtType;
	    var check = getCheckedValue(obj);

	    //alert(check);
		if (document.forms[0].projectDDL.value=="") {
			alert("กรุณาเลือกรหัสโครงการด้วย !!");
			document.forms[0].projectDDL.focus();
			document.forms[0].projectDDL.select();
			return ;
		}else if(check==""){
			 alert("กรุณาเลือก Radio Button ระบุแปลงหรือระบุวัน Key in.");
			 document.forms[0].rbtType.focus();
		}else if(check=="1" || check=="2"){
			if(validDate(document.forms[0].fdateTxt,document.forms[0].tdateTxt)){	
			     do_totals1();
				 document.forms[0].action="<%=request.getContextPath()%>/SERV_RecBeforeTransferServlet?cmd=frmSearch";
				 document.forms[0].submit();
				 //alert("submit#case 1");
			}
		}else{
		     do_totals1();
			 document.forms[0].action="<%=request.getContextPath()%>/SERV_RecBeforeTransferServlet?cmd=frmSearch";
			 document.forms[0].submit();
			 //alert("submit#case 0");
		}
	}
	 
	//call from  utilizer.genLinkNextPageHTML
	 function changePage(nowPage) { 
		 document.forms[0].nowPage.value=nowPage;
		 doSearchForm();
		 //document.forms[0].action="<%//=request.getContextPath()%>/MngRecordBeforeTransferServlet?cmd=frmSearch";
	     //document.forms[0].submit();
	 } 	
	
	 function onChangePageNomber() {
		  doSearchForm();
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
	
	function validDate(fdate,tdate) {
	     var sdate = fdate.value.split("/")[0];
	     var smonth =fdate.value.split("/")[1];
	     var syear = parseInt(fdate.value.split("/")[2])-543;
	     
	    // alert(fdate.value.split("/")[2]);
	     //alert(sdate+","+smonth+","+syear);
	     
	     var edate = tdate.value.split("/")[0];
	     var emonth = tdate.value.split("/")[1];
	     var eyear = parseInt(tdate.value.split("/")[2])-543;
	     
	     
	    // alert(edate+","+emonth+","+eyear);
	     //---- Check select date ---//
	     if (sdate.length==0 && smonth.length==0 && syear.length==0 &&
	         edate.length==0 && emonth.length==0 && eyear.length==0) {
	         alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
	         document.forms[0].fdateTxt.focus();
	         return false;
	        // return true;
	     }
	     var startDate = new Date(parseInt(syear,10),parseInt(smonth,10)-1,parseInt(sdate,10));
	     var endDate = new Date(parseInt(eyear,10),parseInt(emonth,10)-1,parseInt(edate,10));
	     if (startDate.getMonth()!=(parseInt(smonth,10)-1)) {
	        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
	        document.forms[0].fdateTxt.focus();
	        return false;
	     }
	     if (endDate.getMonth()!=(parseInt(emonth,10)-1)) {
	        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
	        document.forms[0].fdateTxt.focus();
	        return false;
	     }
		if (startDate>endDate) {
		    alert(" วันที่สิ้นสุดต้องไม่น้อยกว่าวันที่เริ่มต้น ! ");
		    return false;
		}
	     return true;
	 }	
//-->
</script>
<script type="text/javascript">
var ggWinCal ;
function doSelChqDate(dateType,iHouse,dCloseLaw) {
	  	var vWinCal = window.open('<%=request.getContextPath()%>/SERV_PopCalendar.jsp?dateType='+dateType,'blank','width=300,height=265,left=200,top=100');
	  	vWinCal.opener = self;
	  	ggWinCal = vWinCal;
}
</script>

<script language="javascript">
    function submitForm(oForm) {
    dototals1();
    oForm.submit();
    // return true;
    }
    function do_totals1() {
   	 	document.all.pleasewaitScreen.style.pixelTop = (document.body.scrollTop + 180);
    	document.all.pleasewaitScreen.style.visibility = "visible";
    	var msg = "<img src=\"<%=request.getContextPath()%>/images/p_loading.gif\" HEIGHT=\"60px\">";
    	document.getElementById("img1").innerHTML = msg;
    	//document.getElementById("img1").innerHTML= "<img src=\"/CALLService/images/p_loading.gif\" HEIGHT=\"60px\">";
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
</head>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="javascript:onLoad();"">

<%--  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --%>
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
<%--  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --%>

<FORM name="frm1" METHOD="POST" ACTION="" >
<input type="hidden" name="nowPage">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
           <td width="100%" class="bigh" align="left"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;Check List บันทึกรายการเก็บงานก่อนโอน</td>
          <td width="100%" align="right">          
          </td>
        </tr>
      </table>

<br style="font-size:10pt">
                

 <table border="0" width="100%" cellspacing="0" cellpadding="0">
 <tr>
     <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
     <td class="item_tab2" width="160">ระบุรายละเอียดการค้นหา</td>
     <td class="item_tab3"></td>
     <td align="left">&nbsp;</td>                
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
  <tr align="left">
    <td class="item ; dotline01" height="22">โครงการ :</td>
    <td height="22" class="dotline01">
    <select name="projectDDL" class="box2" style='width:280' size='1' > 
			<option value="">------ กรุณาเลือกโครงการ ------</option>
   			<%
					List  arrList = null;
					if(projectList!=null && projectList.size()>0){
							Iterator it = projectList.iterator();
							String select = "";
						    String strValue = "";
							while(it.hasNext()){
							    select = "";
								strValue = ""; 									
								arrList =(ArrayList)it.next();										
								strValue = doString.checkString(arrList.get(0).toString());
								if (strValue.equals(projectSel)){
									select="selected"; 
								}else{ 
									select=""; 
								} %>
								<option value="<%=strValue%>"  <%=select %>><%=arrList.get(1).toString()%></option>
							<%}
					} %>	 
   				</select> 	
 
    </td>
    <td class="item ; dotline01" height="22">
    <input type="radio" name="rbtType" value="0" 
    <%  if("0".equals(rbtType)){out.println("checked='checked'");}%> onclick="JavaScript:doClickChange(this.value);">แปลง : <input type="text" class="box" id="lockTxt" name="lockTxt" style="width:60px" maxlength="5" value="<%=lockTxt%>"></td>
    <td height="22" class="item ; dotline01">
    <input type="radio" name="rbtType" value="1"  
    <%  if("1".equals(rbtType)){out.println("checked='checked'");}%> onclick="JavaScript:doClickChange(this.value);">ยังไม่ได้ Key 		
    &nbsp;&nbsp;<input type="radio" name="rbtType" value="2"  
    <%  if("2".equals(rbtType)){out.println("checked='checked'");}%> onclick="JavaScript:doClickChange(this.value);">ทั้งหมด
    </td>    
    </tr>
    <tr align="left">
	    <td class="item ; dotline01" height="22">&nbsp;วันที่โอน :</td>
	    <td height="22" class="dotline01">&nbsp;
		    <input name="fdateTxt" id="fdateTxt" type="text" class="boxC" style="width:65px" value="<%=fDate %>"  readonly="readonly">
	     	<span id="calImg1">
	     	<A HREF="javascript:doSelChqDate('fdateTxt')">
	     	<IMG border="0" src="images/i_calendar.gif" align="absmiddle" width="18" height="18"></A></span>
	     	&nbsp;&nbsp;&nbsp;ถึง&nbsp;&nbsp;&nbsp;
	     	<input name="tdateTxt" id="tdateTxt" type="text" class="boxC" style="width:65px" value="<%=tDate %>" readonly="readonly">
	     	<span id="calImg2">
	     	<A HREF="javascript:doSelChqDate('tdateTxt')">
	     	<IMG border="0" src="images/i_calendar.gif" align="absmiddle" width="18" height="18"></A></span>
            &nbsp;&nbsp;&nbsp;
			<a href="javascript:doSearchForm();"><img src="images/bu_go.gif" align="absmiddle" onmouseout=nereidFade(this,70,50,5) 
			onmouseover=nereidFade(this,100,50,5) style="FILTER: alpha(opacity=70) ; cursor:hand" hspace="10" border="0" >
			</a>
     	</td>
	    <td class="item ; dotline01" height="22">&nbsp;</td>
	    <td height="22" class="dotline01">&nbsp;</td>    
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
                <td class="item_tab2" width="160">รายการค้นหาบันทึกก่อนโอน</td>
                <td class="item_tab3"></td>
                <td align="right">&nbsp;
                 <font style="color:rgb(0,120,255)">แสดง&nbsp;
			  	<select name="pageNoDDL" id="pageNoDDL" class="box" style="width:45px" onchange="javascript:onChangePageNomber();">
					 <%
					 		Collections.sort(pageList);
							String selected = "";
							for(int i=0;i<pageList.size();i++){
								if(pageList.get(i).toString().equals(displayLine)){
									selected ="selected"; 
								}else{
									selected = "";
								}
								%>
								<option value="<%=pageList.get(i)%>"   <%=selected %>> <%=pageList.get(i)%></option>	
								<%		     	
							}//End 
						     %>
						   </select>รายการ&nbsp;
			    </font>
                
                </td>
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
        <tr>
          <td width="5%" class="col_name">No.</td>
          <td width="15%" class="col_name">โครงการ</td>
          <td width="7%" class="col_name">แปลง</td>
          <td width="8%" class="col_name">วันที่โอน</td>
          <td width="18%" class="col_name">ผู้รับเหมา</td>
          <td width="8%" class="col_name">เลขที่อ้างอิง</td>
          <td width="8%" class="col_name">เลขที่ใบเบิก</td>
          <td width="10%" class="col_name">ประเภท</td>
          <td width="7%" class="col_name">สถานะ</td>
          <td width="14%" class="col_name">หมายเหตุ</td>
        </tr>
        <%
         //System.out.println("listDOCHD.size :"+listDOCHD.size());
        if(listIpvQCHD!=null && listIpvQCHD.size()>0){
	        List strList = null;
	        String tagColor = "";
	        int loop = Integer.parseInt(recordNo)+1;
	        boolean isRecord = false;
			int c = 0;
	        //---------------------
	        String tempType = "";
	        Iterator itHD = listIpvQCHD.iterator();
	        while(itHD.hasNext()){
	    	   strList = (ArrayList)itHD.next();
	    	   c++;
	    	   tagColor="#ffffff";
			   if((c%2)==0){
				 tagColor="#f0f0f0";
			    }
			   tempType = "";
			   

			   //System.out.println("--"+strList.get(8));
			   if(strList.get(7).equals("1")){
				   tempType = "จากระบบ Billing";
			   }else if(strList.get(7).equals("2")){
				   tempType = "จากระบบ PR";
			   }else if(strList.get(7).equals("3")){
				   tempType = "มีรายการยอดจ่ายเท่ากับ 0";
			   }else if(strList.get(7).equals("4")){
				   tempType = "ไม่มีรายการ";
			   }else{
				   tempType = "";
			   }  
			   
			    isRecord = false;
			    //System.out.println("strList.get(4).toString() :"+strList.get(4).toString());
			    if("".equals(strList.get(4).toString())){
			      isRecord = true;
			    }
			   
      %>        
		        <tr height="25px" bgcolor="<%=tagColor %>">
		          <td class="dotline ; item"><%=loop%></td>
		          <td class="dotline "><%=strList.get(0).toString()%>-<%=strList.get(1).toString()%> <%=strList.get(11).toString()%></td>
		          <td align="center" class="dotline ; item"><%=strList.get(2).toString()%></td>
		          <td align="center" class="dotline"><%=strList.get(3).toString()%></td>    
		          <td class="dotline" align="left"><%=strList.get(12).toString()%>&nbsp;</td>
		          <td  align="center" class="dotline"><%=strList.get(4)%>&nbsp;</td>
		          <td  align="center" class="dotline"><%=strList.get(6).toString()%></td>
		          <td  align="left" class="dotline"><%=tempType %>&nbsp;</td>
		          <td  align="center"  class="dotline"><%=strList.get(8).toString()%></td>
		          <td  align="center" class="dotline ; item"><%=strList.get(9).toString()%>&nbsp;
		          <% if(isRecord){
		          	out.println("***ยังไม่ Key ข้อมูล***");
		          }
		           %>
		          </td>  		                       
		        </tr>
		        
		<%     loop++;
	       }//#End while Loop;  
        }//#End if chec value
        else{ //No record or data
        	%>
				<tr align="left" > 
                       <td  height="22"  align="center" colspan="10" class="side01" >***ไม่มีข้อมูล***</td>
                </tr>
       <% 	
        }
		%>        	        		                                                          
      </table>
    </td>
  </tr>
</table>
<%--  <a href="javascript:doEdit('<%//=strList.get(0).toString()%>','<%//=strList.get(6).toString()%>','<%//=mode%>');" ><%//=strList.get(0).toString()%></a> --%>
 
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>

<br style="font-size:3pt">

      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr class="gray">
          <td width="100%" align="right"><b>&nbsp;&nbsp;&nbsp;
			<%=displayLinkPage %>&nbsp;&nbsp;</b></td>
        </tr>
      </table>


<br style="font-size:5pt">


        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">
			<%-- 
            <a href="javascript:doFrmAdd();"><img border="0" src="images/act_add.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>  
              --%>    	
            </td>      	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:history.back();" ><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="SERV_Index.jsp" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>  
        </table>  



      </td>
        </tr>
      </table>

<%-- 
          </td>
        </tr>
      </table>
--%>
<br style="font-size: 30pt">
<TABLE border="0" cellspacing="0" cellpadding="0" width="100%">
	<TBODY>
		<tr>
			<td width="100%" class="copyright" align="center">Best viewed with
			800x600 screen resolution on&nbsp;an Internet Explorer version 6 <br>
			ติดต่อสอบถามได้ที่ : <a href="mailto:dept_IT@lh.co.th">dept_IT@lh.co.th</a>&nbsp;
			หรือ โทร. 0-2230-8457 (ฝ่าย IT) <br>
			<img src="images/copyright.gif" width="475" height="26"></td>
		</tr>
	</TBODY>
</TABLE>
	
</FORM>
	
</BODY>

</HTML>
