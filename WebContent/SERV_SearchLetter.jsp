<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="serv.common.*" %>
<%@ page import="com.lh.util.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="serv.util.ServLog" %>

<%@ page errorPage="errorPage.jsp" %>
<%@ include file="function.jsp" %>
<%@ include file="confirmLogin.jsp" %>





<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_SearchLetter.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

Connection conn = null;
Statement stmt = null;
Statement stmt1 = null;
ResultSet rs = null;
ResultSet rs1 = null;
StringBuffer query = new StringBuffer();


//----========== Declare Variable ==========----
String colone ="";
String coltwo ="";
String colthr ="";
String colfou ="";
String colfiv ="";
String colsix ="";
String colsev ="";
String coleig ="";
String colnin ="";
StringBuffer ecold = new StringBuffer();
LinkedList coldata = new LinkedList(); // ประกาศข้างนอก
StringTokenizer seperate;




String com_id = "";
String proj_id = "";
String n_project = "";
String I_company = "";
String I_project = "";
String I_lock = "";
String I_docno = "";
String n_customer = "";
String I_house = "";
String n_service = "";
String I_tel = "";
String I_cus_intent1 = "";
String I_exp_intent1 = "";
String n_ncustomer = "";
String n_scustomer = "";
String i_cust = "";

//----========== Get Parameter ==========----
String TNoProj = doString.checkString(request.getParameter("TNoProj"));
String TNoHome = doString.checkString(request.getParameter("TNoHome"));
String TNoBed = doString.checkString(request.getParameter("TNoBed"));
String TNoFix = doString.checkString(request.getParameter("TNoFix"));



//----========== Use in program ==========----
int count=0;
boolean nextstate = true;
boolean checkname = true;
LinkedList deleteList = new LinkedList();
String[] checklist = null;
try {

	//----============ Initialize Variable ============----//
	if (ds == null)
		getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	stmt1 = conn.createStatement();
	//----=======================================----//
	Calendar days = Calendar.getInstance(Locale.ENGLISH);
	String month[] =
		{
			"",
			"มกราคม",
			"กุมภาพันธ์",
			"มีนาคม",
			"เมษายน",
			"พฤษภาคม",
			"มิถุนายน",
			"กรกฎาคม",
			"สิงหาคม",
			"กันยายน",
			"ตุลาคม",
			"พฤศจิกายน",
			"ธันวาคม" };
	int DD = days.get(Calendar.DATE);
	int MM = days.get(Calendar.MONTH) + 1;
	int YY = days.get(Calendar.YEAR);
	String Mont = null;
	String Dayt = null;
	YY = YY+543;
	if (MM<10)
	{
		Mont = "0"+MM;
	}
	else
	{
		Mont = ""+MM;
	}
	if (DD<10)
	{
		Dayt = "0"+DD;
	}
	else
	{
		Dayt = ""+DD;
	}


	String year = doString.displayNumber("0000", YY);
	String Day = Dayt+"/"+Mont+"/"+year;//(year.substring(2,4));
	String search = doString.checkString(request.getParameter("flagsearch"),"");


	if (search.equalsIgnoreCase("Yes"))
	{
			deleteList = new LinkedList();
			session.setAttribute("sess_del",deleteList);
	}
	else if (search.equalsIgnoreCase("No"))	{
		coldata = (LinkedList) session.getAttribute("dsearchletter");
		if (coldata==null)
			{
				coldata = new LinkedList();
			}

		deleteList = (LinkedList) session.getAttribute("sess_del");
		if (deleteList==null) {
			deleteList = new LinkedList();
		}

		checklist = request.getParameterValues("check");
		
		if (checklist!=null)
		{
			String b = "";
			for (int i = 0; i < checklist.length; i++) {
				for (int j = 0; j < coldata.size(); j++){
					b = ((String) coldata.get(j));
					if (checklist[i].length()>=14 && b.length()>=14) {
						if (checklist[i].substring(0,14).equalsIgnoreCase(b.substring(0,14))) {
							coldata.remove(j);
							break;
						} //end
					}
				} //end for j
			} // end for i


		}
		
		session.setAttribute("dsearchletter",coldata);

//=====================

	
	}
	
%>



<HTML>

<HEAD>
<TITLE>Open Job List</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<SCRIPT LANGUAGE="JavaScript">
<!--

	function convertDateFormat(dateObj) {
	   if (dateObj==null) return false;

		var countSlash = 0;
	    for (var i=0;i<dateObj.value.length;i++) {
		       if (dateObj.value.charAt(i)=='/') countSlash++;
		} // end for

		if (countSlash!=2) {
		    alert("รูปแบบวันที่ไม่ถูกต้อง!");
		    dateObj.focus();
		    return false;
		}

	    var splitDate = dateObj.value.split("/"); 
		var day = 0;
		var month = 0;
		var year = 0;

		try {
		    day = parseInt(splitDate[0],10);
		    month = parseInt(splitDate[1],10);
		    year = parseInt(splitDate[2],10);
		} catch (e) {
		   alert("วันที่ไม่ถูกต้อง!");
		   dateObj.focus();
		   return false;
		}

		if (day>=1 && day<=31) {
		    if (month>=1 && month<=12) {

		    if (isNaN(year) || (year>=100 && year<=999)) {
		        alert("กรุณาใส่ปีเป็นรูปแบบ yy หรือ yyyy เท่านั้น!");
			dateObj.focus();
			return false;
		      }

			   //----- Convert to BC. -------//	
			   if (year<45) year += 2543;
			   if (year>=45 && year<100) year += 2500;
			   if (year<2400) year += 543;

			    var dateStr = (day<10 ? "0"+day : day)+"/"+(month<10 ? "0"+month : month)+"/"+year;
	                    dateObj.value = dateStr;

				if (!checkFormatDate(dateStr)) {
				    dateObj.focus();
				    return false;
				}

			} else {
			   alert("เดือนต้องมีค่าระหว่าง 1 - 12 เท่านั้น!");
			   dateObj.focus();
			   return false;
			}
		} else {
		   alert("วันที่ต้องมีค่าระหว่าง 1 - 31 เท่านั้น!");
		   dateObj.focus();
		   return false;
		}

	}
	function checkFormatDate(str)
	{
		mystring = str;
		if (mystring.match(/(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.]([1-9])\d\d\d/ ) ) { 
		   var yyyy = parseInt(str.substring(6,10),10);
		   var mm = parseInt(str.substring(3,5),10)-1;
		   var dd = parseInt(str.substring(0,2),10);
		   if (yyyy>2400) yyyy -= 543;
	
	       var cdate = new Date(yyyy,mm,dd);
		   if (mm!=cdate.getMonth()) {
		      alert("วันที่ไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
		      return false;
		   }
		} else {
			alert("รูปแบบวันที่ไม่ถูกต้อง !");
			return false;
		}
		
		return true;
	}  

	function checkTime(update)
	{
		var time = document.forms[0].elements[update][1];
		for (var i =0;i<time.value.length;i++)
		{
			if (time.value.charAt(i)!='0'&&time.value.charAt(i)!='1'&&time.value.charAt(i)!='2'&&time.value.charAt(i)!='3'&&time.value.charAt(i)!='4'&&time.value.charAt(i)!='5'&&time.value.charAt(i)!='6'&&time.value.charAt(i)!='7'&&time.value.charAt(i)!='8'&&time.value.charAt(i)!='9'&&time.value.charAt(i)!=':'){
				time.value = "";
			}
		}
		if (time.value.length==4)
		{
			if ( parseInt(time.value.charAt(0))>2 )
			{
				alert("รูปแบบเวลาไม่ถูกต้อง!");
				time.value = "00:00";
			}
			if ((parseInt(time.value.charAt(0))==2)&&( parseInt(time.value.charAt(1))>4))
			{
				alert("รูปแบบเวลาไม่ถูกต้อง!");
				time.value = "00:00" ;
			}
			if (parseInt(time.value.charAt(2))>5)
			{
				alert("รูปแบบเวลาไม่ถูกต้อง!");
				time.value = "00:00" ;
			}
			if(time.value.charAt(1)!=':'&&time.value!="00:00")
			{
				time.value = time.value.substring(0,2)+":"+time.value.substring(2,4);
			}
		}
		else if (time.value.length==3)
		{
			if (parseInt(time.value.charAt(1))>5)
			{
				alert("รูปแบบเวลาไม่ถูกต้อง!");
				time.value = "00:00" ;
			}
			if (time.value!="00:00")
			{
				time.value = time.value.substring(0,1)+":"+time.value.substring(1,3);
			}
		}
		else if (time.value.length==5)
		{
			if (time.value.charAt(2)!=':')
			{
				alert("รูปแบบเวลาไม่ถูกต้อง!");
				time.value = "00:00";
			}
			if ( parseInt(time.value.charAt(0))>2 )
			{
				alert("รูปแบบเวลาไม่ถูกต้อง!");
				time.value = "00:00";
			}
			if ((parseInt(time.value.charAt(0))==2)&&( parseInt(time.value.charAt(1))>4))
			{
				alert("รูปแบบเวลาไม่ถูกต้อง!");
				time.value = "00:00" ;
			}
			if (parseInt(time.value.charAt(3))>5)
			{
				alert("รูปแบบเวลาไม่ถูกต้อง!");
				time.value = "00:00" ;
			}
		}
		else
		{
			alert("รูปแบบเวลาไม่ถูกต้อง!");
			time.value = "00:00";
		}
	}

	function  checkAll(obj,mainCheck,subCheck) {
		 var main = document.forms[0].elements[mainCheck];
		 var sub = document.forms[0].elements[subCheck];
		 
		 if (obj!=null && main!=null && sub!=null) {
			 if (obj.name==mainCheck) {
				if (sub.length!=null) {
					for (var i=0;i<sub.length;i++) {
						  sub[i].checked = obj.checked;
					}
				} else {
				   sub.checked = obj.checked;
				}
			 } else {
				if (sub.length!=null) {
					var flag = true;
					for (var i=0;i<sub.length;i++) {
						  flag = sub[i].checked;
						  if (!flag) break;
					}
					main.checked = flag;
				} else {
				   main.checked = obj.checked;
				} // end if check sub
			 } // end if check mainCheck
		 } // end if check null
	}
	function showprint(mainCheck,subCheck)
		{
		//=========================== Add-on function ===========================  
				var main = document.forms[0].elements[mainCheck];
				var sub = document.forms[0].elements[subCheck];
				var con = true;
				for (var i=0;i<sub.length;i++)
				{
					if(sub[i].checked==true)
					{
						con = false;
					}
				}
				if (main!=null&&con==true)
				{
					if (sub.length!=null)
					{
						for (var i=0;i<sub.length;i++)
						{
							sub[i].checked = true;
						}
					}
					else
					{
						sub.checked = true;
					}
					main.checked = true;
				}
				
		//===========================  Main function  ===========================  
				document.forms[0].target="_blank";
				document.forms[0].action="/LHServ/gensearchletter";  // somewhere to create pdf
				document.forms[0].submit();
				document.forms[0].target="";
		}
	function SearchData()
		{
			document.forms[0].flagsearch.value = "Yes";
			document.forms[0].action="SERV_SearchLetter.jsp";
			document.forms[0].submit();
		}
	function DeleteData()
		{
			document.forms[0].flagsearch.value = "No";
			document.forms[0].action="SERV_SearchLetter.jsp";
			document.forms[0].submit();
		}
	function displaymessage() 
		{ 
			alert("บ้านเลขที่ไม่ตรงกับแปลง");
		}
//-->		
</SCRIPT>





<base target="_self">
<style type="text/css">
<!--
.box2 {
	font-family: "MS Sans Serif";
	font-size: 7pt;
	padding-top: 1px;
	padding-right: 1px;
	padding-bottom: 1px;
	padding-left: 1px;
	color: #0033CC;
	background-color: white;
	border: 1px #BEDCFF solid;
	scrollbar-color: red
}
-->
</style>
<script language="JavaScript" fptype="dynamicanimation">
<!--
function dynAnimation() {}
function clickSwapImg() {}
//-->
</script>
<script language="JavaScript1.2" fptype="dynamicanimation"
	src="animate.js">
</script>
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<Form name="SearchData" method="post" action="SERV_SearchLetter.jsp">
<%

//----========== Check ID and Authorize ==========----
query.delete(0, query.length());
query
	.append("select com_id,proj_id from serv_pstaff where user_id ='")
	.append(user.getUserID())
	.append("'");
	servlog.startLog(query.toString());
	rs = stmt.executeQuery(query.toString());
	servlog.endLog();

	if (rs.next()) {
		com_id = doString.checkString(rs.getString("com_id"),"");
		proj_id = doString.checkString(rs.getString("proj_id"),"");
	}
	rs.close();



%>


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            จดหมายแจ้งการตรวจรับงานซ่อม</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียด</td>
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
    <td width="100%" class="frmLR" align="center"><table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="15%" height="22" class="item ; dotline01">โครงการ :</td>
    <td width="39%" height="22" class="dotline01"><select size="1" class="box" style="width:200px" name="TNoProj">
<%

	if (com_id.equalsIgnoreCase("LH") && proj_id.equalsIgnoreCase("ALL"))
	{
		//----========== Code = LH && Proj = ALL ==========----
		query.delete(0, query.length());
		query
			.append("select I_company,I_project from lan:acsbudgh where d_year='")
			.append(year) 		//---- Year in Thai ----
			.append("' and I_budg_type ='9'");

			servlog.startLog(query.toString());
			rs = stmt.executeQuery(query.toString());
			servlog.endLog();
			while (rs.next()) {
				I_company = doString.checkString(rs.getString("I_company"),"");
				I_project = doString.checkString(rs.getString("I_project"),"");
				query.delete(0, query.length());
				query
					.append("select n_project from lan:acxprojt where I_company='")
					.append(I_company)
					.append("' and I_project ='")
					.append(I_project)
					.append("'");
					servlog.startLog(query.toString());
					rs1 = stmt1.executeQuery(query.toString());
					servlog.endLog();
					while (rs1.next()) {
						n_project = doString.checkString(doString.DisplayThai(rs1.getString("n_project")),"");
						%><option <%if((TNoProj.length()!=0)&&(TNoProj.substring(0,2)).equalsIgnoreCase(I_company)&&(TNoProj.substring(3,6)).equalsIgnoreCase(I_project)){out.print("selected");}%>><%out.println(I_company+"-"+I_project+" "+n_project);%></option><%
					}
					rs1.close();
			}
			rs.close();
	}
	else
	{
		//----========== Code != LH || Proj != ALL ==========----
		query.delete(0, query.length());
		query
			.append("select com_id,proj_id from serv_pstaff where user_id ='")
			.append(user.getUserID())
			.append("'");
			servlog.startLog(query.toString());
			rs = stmt.executeQuery(query.toString());
			servlog.endLog();
			while (rs.next()) {
				I_company = doString.checkString(rs.getString("com_id"),"");
				I_project = doString.checkString(rs.getString("proj_id"),"");
				query.delete(0, query.length());
				query
					.append("select n_project from lan:acxprojt where I_company='")
					.append(I_company) 
					.append("' and I_project ='")
					.append(I_project)
					.append("' ");

					servlog.startLog(query.toString());
					rs1 = stmt1.executeQuery(query.toString());
					servlog.endLog();
					while (rs1.next()) {
						n_project = doString.checkString(doString.DisplayThai(rs1.getString("n_project")),"");
						%><option <%if((TNoProj.length()!=0)&&(TNoProj.substring(0,2)).equalsIgnoreCase(I_company)&&(TNoProj.substring(3,6)).equalsIgnoreCase(I_project)){out.print("selected");}%>><%out.println(I_company+"-"+I_project+" "+n_project);%></option><%
					}
					rs1.close();
		}
		rs.close();
	}
%>
    </select></td>
    <td width="14%" height="22" class="item ; dotline01">เลขที่ใบแจ้งซ่อม
      :</td>
    <td width="32%" height="22" class="dotline01"><input type="text" name="TNoFix" class="box" style="width:100px" value="<%=TNoFix%>"></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22">บ้านเลขที่   
      :</td>
    <td height="22" class="dotline01"><input type="text" name="TNoHome" class="box" style="width:100px" value="<%=TNoHome%>"></td>
    <td height="22" class="item ; dotline01">แปลง :</td>
    <td height="22" class="dotline01"><input type="text" name="TNoBed" class="box" style="width:100px" value="<%=TNoBed%>">
			&nbsp;&nbsp;&nbsp;&nbsp; 
	<a href ="javascript:SearchData();">
      <img border="0" src="images/i_search.gif" align="absmiddle" width="20" height="20" style="cursor:hand"> 
	  </a>
	  
	  
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
                <td class="item_tab2" width="200">รายละเอียดใบแจ้งซ่อม</td>
                <td class="item_tab3"></td>
                <td>&nbsp;<!--<input type="radio" value="V1" checked name="R1">แสดงจำนวนรายการต่อหน้า&nbsp;
                  <input type="text" name="T1" class="boxC" style="width:50px">&nbsp;
                  รายการ&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" value="V2" name="R1">
                  แสดงรายการทั้งหมด&nbsp;&nbsp;&nbsp;&nbsp;
                  <img border="0" src="images/bu_R.gif" align="absmiddle" style="cursor:hand" width="16" height="16">--></td>
              </tr>
            </table>


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
    <td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>





<table border="0" width="100%" cellspacing="0" cellpadding="0" onchange="SERV_SearchLetter.jsp">
  <tr>
    <td width="100%" class="frmL">
    <!-- Condition checkbox -->
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="3%" class="col_name"><input name="maincheck" type="checkbox" onclick="checkAll(this,'maincheck','check');"></td>
          <td width="10%" class="col_name">เลขที่ใบแจ้งซ่อม</td>
          <td width="5%" class="col_name">แปลง</td>
          <td width="5%" class="col_name">บ้านเลขที่</td>
          <td width="14%" class="col_name">ชื่อผู้แจ้ง /
            ลูกค้า</td>
          <td width="15%" class="col_name">วันและเวลาตรวจรับงานซ่อม            </td>
          <td width="20%" class="col_name">ชื่อเจ้าหน้าที่</td>
          <td width="12%" class="col_name">โทรศัพท์ติดต่อ</td>
          <td width="18%" class="col_name">ที่อยู่ลูกค้า</td>
        </tr>

	  <%
		//----========== Start Searching ==========----

		if (TNoHome.length() != 0 || TNoBed.length() != 0 || TNoFix.length() != 0)
		{
			nextstate = true;
			I_company = TNoProj.substring(0,2);
			I_project = TNoProj.substring(3,6);
			I_lock = "";
			I_docno = "";
			if (!TNoHome.equalsIgnoreCase(""))
			{
				query.delete(0, query.length());
				query
					.append("select I_lock from lan:acxlckmd where I_company='")
					.append(I_company) 
					.append("' and I_project ='")
					.append(I_project)
					.append("' and I_house ='")
					.append(TNoHome)
					.append("' ");

					servlog.startLog(query.toString());
					rs = stmt.executeQuery(query.toString());
					servlog.endLog();

					
					if (rs.next()) {
						I_lock = doString.checkString(rs.getString("I_lock"),"");
					}
					rs.close();
			}
			if (!TNoBed.equalsIgnoreCase(""))
			{
				if (I_lock.equalsIgnoreCase(""))
				{
					I_lock = TNoBed;
				}
				else if (!I_lock.equalsIgnoreCase(TNoBed))
				{
					%><Script>displaymessage();</Script><%
					I_lock = "";
					nextstate = false;
				}
			}
			if (!TNoFix.equalsIgnoreCase(""))
			{
				I_docno = TNoFix;
			}

			//----========== Check State when I_lock != TNoBed ==========---- แปลง
			coldata = (LinkedList) session.getAttribute("dsearchletter");
			if (coldata==null)
			{
				coldata = new LinkedList();
			}

			if (nextstate == true && search.equalsIgnoreCase("YES"))
			{
					query.delete(0, query.length());
					query
						.append("select I_docno,I_lock,n_customer from lan:serv_dochd a where I_company='")
						.append(I_company)
						.append("' and I_project='")
						.append(I_project)
						.append("' and f_status in ('OPN','CLS') and d_complete_max is not null");
						if (!I_docno.equalsIgnoreCase(""))
						{
							I_docno = I_docno.toUpperCase();
							query
								.append(" and I_docno ='")
								.append(I_docno)
								.append("'");
						}
						if (!I_lock.equalsIgnoreCase(""))
						{
							I_lock = I_lock.toUpperCase();
							query
								.append(" and I_lock='")
								.append(I_lock)
								.append("'");
						}
					servlog.startLog(query.toString());
					//out.println(query.toString());
					rs = stmt.executeQuery(query.toString());
					servlog.endLog();
					while (rs.next())
					{
						I_docno = doString.checkString(rs.getString("I_docno"),"");
						I_lock = doString.checkString(rs.getString("I_lock"),"");
					//	n_customer = doString.checkString(doString.DisplayThai(rs.getString("n_customer")),"");
						query.delete(0, query.length());
						query
							.append("select I_house from lan:acxlckmd where I_company='")
							.append(I_company)
							.append("' and I_project='")
							.append(I_project)
							.append("' and I_lock='")
							.append(I_lock)
							.append("'");
						servlog.startLog(query.toString());
						rs1 = stmt1.executeQuery(query.toString());
						servlog.endLog();
						if (rs1.next())
						{
							I_house = doString.checkString(rs1.getString("I_house"),"");
						}
						rs1.close();
						
						query.delete(0, query.length());
						query
							.append("select n_service,I_tel from lan:serv_prjdt where I_company='")
							.append(I_company)
							.append("' and I_project='")
							.append(I_project)
							.append("'");
						servlog.startLog(query.toString());
						rs1 = stmt1.executeQuery(query.toString());
						servlog.endLog();
						if(rs1.next())
						{
							n_service = doString.checkString(rs1.getString("n_service"),"");
							I_tel = doString.checkString(rs1.getString("I_tel"),"");
						}
						rs1.close();


					//	if(n_customer.length()==0)
					//	{
							checkname = true;
							I_cus_intent1 = "";
							I_exp_intent1 = "";
							i_cust = "";
							query.delete(0, query.length());
							query
								.append("select I_cus_intent1,I_exp_intent1 from lan:acscontr where I_company='")
								.append(I_company)
								.append("' and I_project ='")
								.append(I_project)
								.append("' and f_contr is null and i_sort='")
								.append(I_lock)
								.append("'");
							servlog.startLog(query.toString());
							rs1 = stmt1.executeQuery(query.toString());
							servlog.endLog();
							if(rs1.next())
							{
								I_cus_intent1 = doString.checkString(rs1.getString("I_cus_intent1"),"");
								I_exp_intent1 = doString.checkString(rs1.getString("I_exp_intent1"),"");
									if (I_cus_intent1.length() > 0) {
										i_cust = I_cus_intent1;
									} else {
										i_cust = I_exp_intent1;
									}

							/*	if (I_exp_intent1.length()==0)
								{
									I_exp_intent1 = I_cus_intent1;
									checkname = false;
								}
								else if(I_exp_intent1.length()!=0)
								{
									checkname = false;
								}*/
							}
							rs1.close();
					//		if(checkname==false)
					//		{
								query.delete(0, query.length());
								query
									.append("select n_ncustomer,n_scustomer from lan:acxcusto where I_customer='")
									.append(i_cust)
									.append("'");
								servlog.startLog(query.toString());
								//out.println(query.toString());
								rs1 = stmt1.executeQuery(query.toString());
								servlog.endLog();
								if(rs1.next())
								{
									n_ncustomer = doString.checkString(rs1.getString("n_ncustomer"),"");
									n_scustomer = doString.checkString(rs1.getString("n_scustomer"),"");
								}
								rs1.close();
								n_customer = n_ncustomer+" "+n_scustomer;
								
							//}
						//}
//==insert session======

	ecold.delete(0, ecold.length());
	ecold
		.append(doString.checkString(I_docno,"null")) // colone
		.append(";")
		.append(doString.checkString(I_lock,"null")) // coltwo
		.append(";")
		.append(doString.checkString(I_house,"null")) // colthr
		.append(";")
		.append(doString.checkString(n_customer,"null")) // colfou
		.append(";")
		.append(doString.checkString(Day,"null")) // colfiv
		.append(";")
		.append("00:00") // colsix
		.append(";")
		.append(doString.checkString(n_service,"")) // colsev
		.append(";")
		.append(doString.checkString(I_tel,"null")) // coleig
		.append(";")
		.append(doString.checkString(I_docno,"null")); //colnin


	//coldata.add(ecold.toString());
	boolean exists = false;
	for (int j = 0; j < coldata.size(); j++){
		String b = doString.checkString(((String) coldata.get(j)));
		if (b.indexOf(";")>0) {
			if (b.substring(0,b.indexOf(";")).equalsIgnoreCase(I_docno)) {
				exists = true;
				break;
			} //end
		}
	} //end for j

	if (!exists) {
		coldata.addLast(ecold.toString());
	}


//	coldata = (LinkedList) session.getAttribute("dsearchletter");



//======================








					} // end while rs
					rs.close();
			} // end if check netstate

			
			session.setAttribute("dsearchletter",coldata);
			
			//==show data===========


//		coldata = new LinkedList();
//	coldata = (LinkedList) session.getAttribute("dsearchletter");
	if (coldata==null)
	{
		coldata = new LinkedList();
	}
					if(coldata.size()>0)
					{


						for (int tb = 0; tb<coldata.size();tb++)
						{   

							String gg = doString.checkString((String) coldata.get(tb),"");
							seperate = new StringTokenizer(gg,";");
							colone = doString.checkString(seperate.nextToken(),"null");
							coltwo = doString.checkString(seperate.nextToken(),"null");
							colthr = doString.checkString(seperate.nextToken(),"null");
							colfou = doString.checkString(seperate.nextToken(),"null");
							colfiv = doString.checkString(seperate.nextToken(),"null");
							colsix = doString.checkString(seperate.nextToken(),"null");
							colsev = doString.checkString(seperate.nextToken(),"null");
							//coleig = doString.checkString(seperate.nextToken(),"");
							coleig = "1198 กด 89";

							colnin = doString.checkString(seperate.nextToken(),"null");
						if(!deleteList.contains(colone))//pop
							{
						%>
						<tr>

						  <td width="3%" align="center" class="dotline"><input name="check" type="checkbox" value="<%=colone%>;<%=coltwo%>" onclick="checkAll(this,'maincheck','check');"></td>
						  <td width="10%" align="center" class="dotline"><%=colone%></td>
						  <td width="5%" class="dotline" align="center"><%=coltwo%></td>
						  <td width="5%" class="dotline" align="center"><%=colthr%></td>
						  <td width="14%" align="center" class="dotline"><span class="dotline ; item"><%=doString.DisplayThai(n_customer)%>&nbsp;
							</span></td>
						  <td width="15%" class="dotline ; item"><div align="center">
							<input name="<%=colone%>" type="text" size="7" value="<%=colfiv%>" onchange="convertDateFormat(this);">&nbsp;&nbsp;&nbsp;&nbsp;
							<input name="<%=colone%>" type="text" size="2" value="00:00" onchange="checkTime('<%=colone%>')">
						  </div></td>
						  <td width="20%" class="dotline ; item"><input name="<%=colone%>" type="text" value="<%=doString.DisplayThai(colsev)%>" size="25"></td>
						  <td width="12%" align="center" class="dotline"><input name="<%=colone%>" type="text" value="<%=coleig%>" size="15"></td>
						  <td width="18%" align="center" class="dotline"><span class="dotline ; item">
							<input name="<%=colone%>" type="radio" value="old_address">
				ที่อยู่เดิม
				<input name="<%=colone%>" type="radio" value="proj_address" checked>
				ที่อยู่โครงการ</span></td>
						</tr>
						<%
							}
						}
					}
		}
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




<table border="0" width="800" cellspacing="0" cellpadding="0"
							height="30" align="left">
							<tr>
								<td width="5" valign="top"><img border="0"
									src="images/b3_tab1.gif" width="6" height="30"></td>
								<td width="75" background="images/b3_tab2.gif"
									style="background-repeat: repeat-x" valign="top">
								<p><a
									onmouseover="document['fpAnimswapImgFP3'].imgRolln=document['fpAnimswapImgFP3'].src;document['fpAnimswapImgFP3'].src=document['fpAnimswapImgFP3'].lowsrc;"
									onmouseout="document['fpAnimswapImgFP3'].src=document['fpAnimswapImgFP3'].imgRolln"
									href="javascript:showprint('maincheck','check');"><img border="0"
									src="images/act_print.gif" id="fpAnimswapImgFP3"
									name="fpAnimswapImgFP3" dynamicanimation="fpAnimswapImgFP3"
									lowsrc="images/act_print_over.gif" width="70" height="27"></a>								</td>
								<td width="57" valign="top"><a href="javascript:DeleteData();"><img src="images/act_delete.gif" width="70" height="27" border="0"></a></td>
								<td width="57" valign="top"><img border="0"
									src="images/b3_tab3.gif" width="57" height="30"></td>
								<td background="images/b3_tab4.gif"
									style="background-repeat: repeat-x" valign="top">
								<p align="right"><a href="javascript:history.back()"></a>&nbsp;&nbsp;&nbsp;
								<a href="CRM_Home.jsp"></a>								</td>
							</tr>
	  </table>
<p>&nbsp;</p>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr class="gray">
          <td width="100%" align="right"><!--<a href="#">หน้าก่อน</a>&nbsp; |&nbsp;
            <a href="#">1</a>&nbsp; |&nbsp; <a href="#">2</a>&nbsp; |&nbsp; <a href="#">3</a>&nbsp; |&nbsp;
            <a href="#">หน้าถัดไป</a>--></td>
        </tr>
      </table>




<br style="font-size:10pt">



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">

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
  <tr><td width="100%" height="108" align="center" class="copyright">
  Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5  
  <br>
  ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;
  หรือ โทร. 0-2230-8279 (คุณประพัฒน์
  ฝ่ายบริการ)&nbsp; 0-2230-8491-5 (ฝ่าย IT)  
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE>
<INPUT type = "Hidden" name = "flagsearch" value = "">
</Form>	
</BODY>

</HTML>


<%
	} 
	catch (Exception e) 
	{
		System.out.println("ERROR_QUERY : " + query.toString());
		System.out.println("ERROR INFC_Home.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} 
	finally 
		{ //----========== Clean UP ==========----
		try 
			{
			if (rs != null)
				rs.close();
			if (rs1 != null)
				rs.close();
			if (stmt != null)
				stmt.close();
			if (stmt1 != null)
				stmt1.close();
			if (conn != null)
				conn.close();
			} 
		catch (SQLException ignore) {
	}
}
%>
