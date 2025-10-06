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
String jName = "SERV_SearchLetter2.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

Connection conn = null;
Statement stmt = null;
Statement stmt1 = null;
Statement stmt2 = null;
ResultSet rs = null;
ResultSet rs1 = null;
ResultSet rs2 = null;
ResultSet rs3 = null;
Statement stmt3 = null;
StringBuffer query = new StringBuffer();

int d_close_law_year = 0;
String d_close_law_mnth = "";
String d_close_law_date = "";
String chk_condo = "";

//-------------Calendar class(พวกวันที่)-------------------
String code = "";
String option = "";
int start_day = 0;
String start_mnth = "";
String start_year = "";
int SEyear = 0;

int end_day = 0;
String end_mnth = "";
String end_year = "";
int EEyear = 0;

//------------ String vatiable --------------------------

String i_lor = "";
String i_sort = "";
String i_house = "";
String i_exp_intent1 = "";
String i_cus_intent1 = "";
String full_cusname = "";
String cust_tel = "";
String i_model = "";
String d_close_law = "";
String fix_d_close_law = "";
String redirect = "";

Vector Vec_i_lor = new Vector();
String a[] = request.getParameterValues("number");
String b = "";


//-------------- Get Date Paramiter --------------------


start_day = Integer.parseInt(doString.checkString(request.getParameter("start_day"),"01"));

start_mnth = doString.checkString(request.getParameter("start_mnth"),"");

start_year = doString.checkString(request.getParameter("start_year"),"2008");

end_day = Integer.parseInt(doString.checkString(request.getParameter("end_day"),"31"));

end_mnth = doString.checkString(request.getParameter("end_mnth"),"");

end_year = doString.checkString(request.getParameter("end_year"),"2008");

redirect = doString.checkString(request.getParameter("redirect"),"");


//----========== Declare Variable ==========----
String com_id = "";
String proj_id = "";
String company_id = "";
String project_id = "";
String cyear = "";
String name_project = "";
String id_project = "";
String projID = "LH000";
projID = doString.checkString(request.getParameter("proj_name"),"LH000");
//System.out.println("projID=="+projID);
String comId = projID.substring(0,2);
String projId = projID.substring(2);

String Sname = "";
String Stel = "1198 กด 2";
String optionSelected ="";
int count = 1;

try {

	//----============ Initialize Variable ============----//
	if (ds == null)
		getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	stmt1 = conn.createStatement();
	stmt2 = conn.createStatement();
	stmt3 = conn.createStatement();
	//----=======================================----//
	Calendar days = Calendar.getInstance(Locale.ENGLISH);
	Calendar days2 = Calendar.getInstance(Locale.ENGLISH);

	String nowyear = Integer.toString(days.get(Calendar.YEAR));


if (start_mnth.equalsIgnoreCase("")){
	if(start_mnth.length() < 1){
start_mnth = "0" + Integer.toString(days.get(Calendar.MONTH) + 1);
	}
}
if (end_mnth.equalsIgnoreCase("")){
	if(end_mnth.length() < 1){
end_mnth = "0" + Integer.toString(days.get(Calendar.MONTH) + 1);
	}
}




int sday = Integer.parseInt(doString.checkString(request.getParameter("start_day"),"01"));
int smnth = Integer.parseInt(doString.checkString(request.getParameter("start_mnth"),"01"));
int ssmnth = smnth - 1;
int syear = Integer.parseInt(doString.checkString(request.getParameter("start_year"), nowyear)); 
days.set(syear,ssmnth,sday);
days.add(Calendar.YEAR,-1);

int eday = Integer.parseInt(doString.checkString(request.getParameter("end_day"),"01"));
int emnth = Integer.parseInt(doString.checkString(request.getParameter("end_mnth"),"01"));
int eemnth = emnth - 1;
int eyear = Integer.parseInt(doString.checkString(request.getParameter("end_year"), nowyear));
days2.set(eyear,eemnth,eday);
days2.add(Calendar.YEAR,-1);

String sdate = days.get(Calendar.YEAR)+"-"+(days.get(Calendar.MONTH)+1)+"-"+days.get(Calendar.DATE);
String fdate = days2.get(Calendar.YEAR)+"-"+(days2.get(Calendar.MONTH)+1)+"-"+days2.get(Calendar.DATE);


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


%>

<script language="javascript" src="script_fx.js"></SCRIPT>


<SCRIPT LANGUAGE="JavaScript">
<!--


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

	function gosubmit()
	{
	  searchForm.redirect.value="C";
	  document.forms[0].target="";
	  document.forms[0].action="/LHServ/SERV_SearchLetter2.jsp";
	  searchForm.submit();
	  searchForm.redirect.value="C";
	}

	
	function open()
	{
	  searchForm.redirect.value="Y";
	  document.forms[0].target="";
	  document.forms[0].action="/LHServ/SERV_SearchLetter2.jsp";
	  searchForm.submit();
	}

	function deleted()
	{
	  searchForm.redirect.value="D";
	  document.forms[0].target="";
	  document.forms[0].action="/LHServ/SERV_SearchLetter2.jsp";
	  searchForm.submit();
	}


	function checkDate(oday , omonth , oyear)
	{	

			year = oyear.value;

			switch (omonth.value)
			{		case '02' : 	if ((((year%4)%100)%400) == 0)	
											{
													if (oday.value > '29')		
													{		oday.value = '29';		}
											}
											else 
											{		if (oday.value > '28')
													{	oday.value = '28';		}
											}	
											break;

					case '04' : 	if (oday.value == '31')	{	oday.value = '30';	}	break;
					case '06' :		if (oday.value == '31')	{	oday.value = '30';	}	break;
					case '09' : 	if (oday.value == '31')	{	oday.value = '30';	}	break;
					case '11' : 	if (oday.value == '31')	{	oday.value = '30';	}	break;
					}
	  year=oyear.value-0;
	  month=omonth.value-0;
	}


  /*function reload(order)
   {
	 document.forms[0].start_date.value=document.forms[0].starty.value+"-"+document.forms[0].startm.value+"-"+document.forms[0].startd.value;
	 document.forms[0].end_date.value=document.forms[0].stopy.value+"-"+document.forms[0].stopm.value+"-"+document.forms[0].stopd.value;	
     document.forms[0].i_proj.value=document.forms[0].project.value;
	 temp=document.forms[0].project.value.split("-");
	 document.forms[0].i_com.value=temp[0];
	 document.forms[0].i_proj.value=temp[1];
	 if (order!="none")
	   { document.forms[0].orderby.value=order; }
     document.forms[0].action="SERV_SearchLetter2.jsp";
 	 document.forms[0].submit();
   }
*/
  function print(a)
   {
	document.forms[0].target="_blank";
	document.forms[0].action="/LHServ/SERV_SearchLetter2Servlet?chk_condo="+a;  
	document.forms[0].submit();
	document.forms[0].target="";
   }



	
//-->
</SCRIPT>





<base target="_self">
<style type="text/css">

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

</style>
<script language="JavaScript" fptype="dynamicanimation">

function dynAnimation() {}
function clickSwapImg() {}

</script>
<script language="JavaScript1.2" fptype="dynamicanimation"
	src="animate.js">
</script>


<%

//user.getUserID()

query.delete(0, query.length());
query
	.append("select com_id,proj_id from lan:serv_pstaff where user_id ='")
	.append(user.getUserID())
	.append("'");
	
	servlog.startLog(query.toString());
	rs = stmt.executeQuery(query.toString());
	servlog.endLog();

	while (rs.next()) {
		com_id = doString.checkString(rs.getString("com_id"),"");
		proj_id = doString.checkString(rs.getString("proj_id"),"");
	}
	rs.close();


%>

<HTML>
<HEAD>
<TITLE>Open Job List</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<Form name = "searchForm" method = "post" action = "SERV_SearchLetter2.jsp">


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            จดหมายแจ้งให้บริการงานซ่อมบ้านก่อนหมดประกัน</td>
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
    <td width="100%" class="frmLR" align="center">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td class="item ; dotline01" height="22" width="15%">โครงการ :</td>
    <td height="22" width="39%" class="dotline01">
	<select name = "proj_name" size="1" class="box" style="width:200px" onChange="gosubmit();">

	<OPTION value="LH000">------กรุณาเลือก------</option>
<%
//------------------------------------Generate Project option panel-------------------------------------------------

		if (proj_id.equalsIgnoreCase("ALL")) // ดึงทุกโครงการ
	{
		query.delete(0, query.length());
		query.append("select unique i_company,i_project from lan:acsbudgh where d_year=(year(today)+543) and i_budg_type ='9'");

			servlog.startLog(query.toString());
			rs = stmt.executeQuery(query.toString());
			servlog.endLog();
			while (rs.next()) {
				company_id = doString.checkString(rs.getString("i_company"),"");
				project_id = doString.checkString(rs.getString("i_project"),"");
								query.delete(0, query.length());
								query.append("select n_project from lan:acxprojt where i_company ='")
									 .append(company_id)
									 .append("' ")
									 .append(" and i_project = '")
									 .append(project_id)
									 .append("' ");
									servlog.startLog(query.toString());
									rs1 = stmt1.executeQuery(query.toString());
									servlog.endLog();
					while (rs1.next()){
								id_project = doString.DisplayThai(doString.checkString(rs.getString("i_company"),"")+doString.checkString(rs.getString("i_project"),""));
								name_project = doString.DisplayThai(doString.checkString(rs.getString("i_company"),"")+"-"+doString.checkString(rs.getString("i_project"),"")+ " "+doString.checkString(rs1.getString("n_project"),""));
								optionSelected = "";
								if (projID.equals(id_project)) {
								optionSelected = "selected";

								}
%>
						<OPTION value="<%=id_project%>"<%=optionSelected%>><%=name_project%></option>
<%
						}
						rs1.close();
					}
					rs.close();
	}
	
		else // ดึงตามคนที่ไม่ได้ ALL
		{

		query.delete(0, query.length());
		query.append("select com_id,proj_id from lan:serv_pstaff where user_id ='")
			 .append(user.getUserID())
			 .append("'");
		servlog.startLog(query.toString());
	   	rs = stmt.executeQuery(query.toString());
		servlog.endLog();

	while (rs.next()) {
		com_id = doString.checkString(rs.getString("com_id"),"");
		proj_id = doString.checkString(rs.getString("proj_id"),"");
							query.delete(0, query.length());
      						query.append("select n_project from lan:acxprojt where i_company ='")
								 .append(com_id)
								 .append("' ")
								 .append("and i_project = '")
								 .append(proj_id)
								 .append("' ");
								servlog.startLog(query.toString());
								rs1 = stmt1.executeQuery(query.toString());
								servlog.endLog();
					while (rs1.next()){
								id_project = doString.DisplayThai(doString.checkString(rs.getString("com_id"),"")+doString.checkString(rs.getString("proj_id"),""));
								name_project = doString.DisplayThai(doString.checkString(rs.getString("com_id"),"")+doString.checkString(rs.getString("proj_id"),"")+ " |  "+doString.checkString(rs1.getString("n_project"),""));
								optionSelected = "";
								if (projID.equals(id_project)) {
								optionSelected = "selected";

			}
%>
						<OPTION value="<%=id_project%>" <%=optionSelected%>><%=name_project%></option>
<%
						}
				rs1.close();			
			}
			rs.close();
		}
//---------------------------------------------Gen end---------------------------------------------------
%>
      </select></td>
	
    <td height="22" class="item ; dotline01" width="14%">&nbsp;</td>
    <td height="22" width="32%" class="dotline01">&nbsp;</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22">วันที่บ้านหมดประกันตั้งแต่   :</td>
	<td height="22" width="28%" class="dotline01">&nbsp;
                    <select size="1" name="start_day" class="box" style="width:40px" onChange="checkDate(start_day,start_mnth,start_year);">
                      <%
		code = "";
		for (int i=1;  i <= 31;  i++) {
			option = "";
			if (i <= 9)
				code = "0"+ Integer.toString(i);
			else
				code = Integer.toString(i);

			if (i == start_day) {
				option = " Selected ";
			}
%>
                      <option value="<%=code%>" <%=option%>><%=code%></option>
                      <%
		} // End for start_day
%>
</select>
	                    <select size="1" name="start_mnth" class="box" style="width:85px" onChange="javascript:checkDate(start_day,start_mnth,start_year);" >
<%
	
			for( int i=1;  i <= 12;  i++ ){
				option = "";
				if( i<=9 )
					code = "0" + Integer.toString(i);
				else
					code = Integer.toString(i);

				if (code.equals(start_mnth)) {
					option = " Selected ";
				}
%> 
                  <option value="<%=code%>" <%=option%>><%=month[i]%></option>
<%
			} // End for start_mnth
%>
</select>
 <select size="1" name="start_year" class="box" style="width:55px" onChange="javascript:checkDate(start_day,start_mnth,start_year);" >
<%

		for( int i = Integer.parseInt(nowyear) -5 ;  i <= Integer.parseInt(nowyear) + 5;  i++ ){
			option = "";
			if (i == Integer.parseInt(start_year)) {
				option = " Selected ";
			}
%> 
                  <OPTION value="<%=i%>" <%=option%>><%=i+543%></OPTION>
<%
		} // End for start_year
%> </select>                 </td>
    <td height="22" class="item ; dotline01">ถึง :</td>
	<td height="22" width="28%" class="dotline01">&nbsp;
    <select size="1" name="end_day" class="box" style="width:40px" onChange="javascript:checkDate(end_day,end_mnth,end_year);">
                      <%
		code = "";
		for (int i=1;  i <= 31;  i++) {
			option = "";
			if (i <= 9)
				code = "0" + Integer.toString(i);
			else
				code = Integer.toString(i);

			if (i == end_day) {
				option = " Selected ";
			}
%>
                      <option value="<%=code%>" <%=option%>><%=code%></option>
                      <%
		} // End for end_day
%>
</select>
	                    <select size="1" name="end_mnth" class="box" style="width:85px" onChange="javascript:checkDate(end_day,end_mnth,end_year);">
<%
	
			for( int i=1;  i <= 12;  i++ ){
				option = "";
				if( i<=9 )
					code = "0" + Integer.toString(i);
				else
					code = Integer.toString(i);

				if (code.equals(end_mnth)) {
					option = " Selected ";
				}
%> 
                  <option value="<%=code%>" <%=option%>><%=month[i]%></option>
<%
			} // End for end_mnth
%>
</select>
 <select size="1" name="end_year" class="box" style="width:55px" onChange="javascript:checkDate(end_day,end_mnth,end_year);">
<%

		for( int i = Integer.parseInt(nowyear) -5 ;  i <= Integer.parseInt(nowyear) + 5;  i++ ){
			option = "";
			if (i == Integer.parseInt(end_year)) {
				option = " Selected ";
			}
%> 
                  <OPTION value="<%=i%>" <%=option%>><%=i+543%></OPTION>
<%
		} // End for end_year
%> </select></td>
  </tr>

<%

//------------------------------ Get Staff name and Telephone number--------------------------------

query.delete(0, query.length());
query.append("select n_service,i_tel from lan:serv_prjdt where i_company ='")
	 .append(comId)
	 .append("' ")
	 .append("and i_project = '")
	 .append(projId)
	 .append("'");
	
	servlog.startLog(query.toString());
	rs = stmt.executeQuery(query.toString());
	servlog.endLog();
		if (rs.next()) {
		Sname = doString.DisplayThai(doString.checkString(rs.getString("n_service"),"-"));
		Stel = doString.DisplayThai(doString.checkString(rs.getString("i_tel"),"-"));
	}
	rs.close();


%>

	<tr>
    <td class="item ; dotline01" height="22">ชื่อเจ้าหน้าที่ : </td>
		 <td height="22" class="dotline01"><input name="Staffname" type="text" class="box" style="width:280px" value="<%=Sname%>" size="60"></td>
		 <td height="22" class="item ; dotline01">เบอร์โทรติดต่อ : </td>
		 <td height="22" class="dotline01"><input name="Stafftel" type="text" class="box" style="width:250px" value="<%=Stel%>" size="40">
		   <a	href="javascript:open();"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a></td>
  </tr>
</table>

</td>
  </tr>
</table>
<INPUT TYPE="hidden" NAME="redirect" value ="">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>

<p>&nbsp;</p>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
    <td class="item_tab2" width="200">รายการซ่อม</td>
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
    <td width="100%" class="frmL"><table border="0" width="100%" cellspacing="0" cellpadding="0">
      <tr>
        <td width="3%" class="col_name"><span class="dotline01">
          <input name="numberm" type="checkbox" class="box"  size="80" onclick="checkAll(this,'numberm','number');">
        </span></td>
        <td width="2%" class="col_name">No.</td>
        <td width="6%" class="col_name">แปลง</td>
        <td width="5%" class="col_name">บ้านเลขที่</td>
        <td width="16%" class="col_name">ชื่อผู้แจ้ง/ลูกค้า</td>
        <td width="10%" class="col_name">แบบบ้าน</td>
        <td width="12%" class="col_name">วันที่หมดประกัน</td>
        <td width="18%" class="col_name">เบอร์โทรลูกค้า</td>
        <td width="16%" class="col_name">ที่อยู่ลูกค้า</td>
        <td width="12%" class="col_name">แจ้งภายในวันที่ (dd/mm/yyyy ปี พศ. )</td>
      </tr>     
<%

String start_date = "2008-01-01";
String stop_date = "2008-01-01";
if (start_day <= 9) {
	start_date = start_year + "-" + start_mnth + "-" + "0" + start_day;
	}
else {
	start_date = start_year + "-" + start_mnth + "-" + start_day;
}
if (end_day <= 9) {
	stop_date = end_year + "-" + end_mnth + "-" + "0" + end_day;
	}
else { 
	stop_date = end_year + "-" + end_mnth + "-" + end_day;
	}

if (redirect.equalsIgnoreCase("Y")) {

Vec_i_lor = new Vector();
query.delete(0, query.length());
query.append("select i_lor from lan:acscontr where i_company ='")
	 .append(comId)
	 .append("' ")
	 .append(" and i_project = '")
	 .append(projId)
	 .append("' ")
	 .append("and f_contr is null and d_close_law between '")
	 .append(sdate)
	 .append("' and '")
	 .append(fdate)
	 .append("'");


servlog.startLog(query.toString());
rs = stmt.executeQuery(query.toString());
servlog.endLog();

while(rs.next()) {
	Vec_i_lor.addElement(doString.DisplayThai(doString.checkString(rs.getString("i_lor"),"")));
	}
rs.close();

session.setAttribute("VecKey",Vec_i_lor);
}

//=--------- compare new selected ---------------------

Vec_i_lor = ((Vector) session.getAttribute("VecKey"));
if(Vec_i_lor == null){
	Vec_i_lor= new Vector();
}

if (redirect.equalsIgnoreCase("D")) {

if(a != null){
for (int i = 0; i < a.length; i++) {
	//System.out.println(a[i]);
	for (int j = 0; j < Vec_i_lor.size(); j++){
		b = ((String) Vec_i_lor.elementAt(j));
		if (a[i].equalsIgnoreCase(b)) {
			Vec_i_lor.remove(j);
			break;
			} //end
		} //end for j
	} // end for i
}// end if

session.setAttribute("VecKey",Vec_i_lor);
}

if (redirect.equalsIgnoreCase("C")) {
	Vec_i_lor= new Vector();
	session.setAttribute("VecKey",Vec_i_lor);
}

for(int i=0; i < Vec_i_lor.size(); i++) {

query.delete(0, query.length());
query.append("select i_sort,d_close_law,i_cus_intent1,i_exp_intent1 from lan:acscontr where i_company ='")
	 .append(comId)
	 .append("' ")
	 .append(" and i_project = '")
	 .append(projId)
	 .append("' ")
	 .append(" and i_lor = '")
	 .append((String) Vec_i_lor.get(i))
	 .append("' ")
	 .append("and f_contr is null and d_close_law between '")
	 .append(sdate)
	 .append("' and '")
	 .append(fdate)
	 .append("'");

	 servlog.startLog(query.toString());
	 rs = stmt.executeQuery(query.toString());
	 servlog.endLog();

 	 
	 while(rs!=null && rs.next()) {

	 i_lor = ((String)Vec_i_lor.get(i));
	 i_sort = doString.DisplayThai(doString.checkString(rs.getString("i_sort"),""));
	 i_exp_intent1 = doString.DisplayThai(doString.checkString(rs.getString("i_exp_intent1"),""));
	 i_cus_intent1 = doString.DisplayThai(doString.checkString(rs.getString("i_cus_intent1"),""));
	 d_close_law= doString.DisplayThai(doString.checkString(doString.DisplayThai(rs.getString("d_close_law")),""));
	 d_close_law_year = Integer.parseInt(doString.checkString(d_close_law.substring(0,4)));
	 d_close_law_mnth = d_close_law.substring(8,10); 
	 d_close_law_date = d_close_law.substring(5,7);

 
	query.delete(0, query.length());
	query.append("select i_house from lan:acxlckmd where i_company ='")
		.append(comId)
		.append("' ")
		.append(" and i_project = '")
		.append(projId)
		.append("' and i_lor = '")
		.append((String) Vec_i_lor.get(i))
		.append("'");

	servlog.startLog(query.toString());
	rs1 = stmt1.executeQuery(query.toString());
	servlog.endLog();

	if(rs1.next()) {

	 i_house = doString.DisplayThai(doString.checkString(rs1.getString("i_house"),"-"));

		if (i_cus_intent1.length()>0){

		query.delete(0, query.length());
		query.append("select n_prename, n_ncustomer, n_scustomer, a_id_tel, a_wk_tel, a_etc_tel from lan:acxcusto where i_customer ='")
			.append(i_cus_intent1)
			.append("'");
			}
		else {
		query.delete(0, query.length());
		query.append("select n_prename, n_ncustomer, n_scustomer, a_id_tel, a_wk_tel, a_etc_tel from lan:acxcusto where i_customer ='")
			.append(i_exp_intent1)
			.append("'");
		}
			 servlog.startLog(query.toString());
			 rs2 = stmt2.executeQuery(query.toString());
			 servlog.endLog();
			if(rs2.next()) {
			 full_cusname = doString.DisplayThai(doString.checkString(rs2.getString("n_prename"),"")) + doString.DisplayThai(doString.checkString(rs2.getString("n_ncustomer"),"") + " " + doString.checkString(rs2.getString("n_scustomer"),""));
			 cust_tel = doString.DisplayThai(doString.checkString(rs2.getString("a_id_tel"),"&nbsp") + " " + doString.checkString(rs2.getString("a_wk_tel"),"&nbsp") + " " + doString.checkString(rs2.getString("a_etc_tel"),"&nbsp") );
				
				i_model = "-";
				/*
				query.delete(0, query.length());
				query.append("select i_model from lan:acxlckhd a where i_company ='")
					.append(comId)
					.append("' ")
					.append(" and i_project = '")
				   	.append(projId)
					.append("' and i_lor = '")
					.append((String) Vec_i_lor.get(i))
					.append("'");*/
					query.delete(0, query.length());
					query.append("select a.i_lor,a.i_model,a.i_house,a.i_lock,b.i_exp_intent1,b.i_cus_intent1,b.d_close_law from lan:acxlckmd a ")
							  .append(" left join lan:acscontr b on b.i_company=a.i_company and b.i_project=a.i_project ")
							  .append(" and b.i_lor=a.i_lor and b.f_contr is null ")
							  .append(" where a.i_company='").append(comId).append("' ")
							  .append(" and a.i_project='").append(projId).append("' ")
							  .append(" and a.i_lor = '")
							  .append((String) Vec_i_lor.get(i))
							  .append("'");
						servlog.startLog(query.toString());
						rs3 = stmt3.executeQuery(query.toString());
						servlog.endLog();
						if(rs3.next()) {
							i_model = doString.DisplayThai(doString.checkString(rs3.getString("i_model"),""));
						}//loop 4
					rs3.close();
%>

	<tr>
	<td width="3%" align="center" class="dotline"><input name="number" value ="<%=i_lor%>" type="checkbox" class="box"  size="80" onclick="checkAll(this,'numberm','number');"></td>
	<td width="2%" name = "count" align="center" class="dotline"><%=count%></td>
	<td width="6%" name = "i_sort" class="dotline"><div align="center"><%=i_sort%></div></td>
    <td width="5%" name = "i_house" class="dotline" align="center"><div align="center"><%=i_house%></div></td>
    <td width="16%" name = "full_cusname"  class="dotline ; item"><div align="center"><%=full_cusname%></div></td>
    <td width="10%" name = "i_model" class="dotline ; item"><div align="center"><%=i_model%></div></td>
    <td width="12%" name = "d_close_law" class="dotline ; item"><div align="center"><%=d_close_law.substring(8,10) +"/"+d_close_law.substring(5,7)+"/"+(Integer.parseInt(doString.checkString(d_close_law.substring(0,4)))+544)%></div></td>
    <td width="18%" name = "cust_tel" class="dotline ; item"><div align="center"><%=cust_tel%></div></td>
    <td width="16%" class="dotline ; item"><input name="CusAdd<%=i_lor%>" type="radio" value="A">
	ที่อยู่เดิม
  <input name="CusAdd<%=i_lor%>" type="radio" value="B" checked="checked"/>
	ที่อยู่โครงการ </td>
    <td width="12%" class="dotline ; item"><span class="dotline01">
    <input name = "fix_d_close_law<%=i_lor%>" type="text" onchange="convertDateFormat(this);" class="box" style="width:100px" value="<%=d_close_law.substring(8,10) +"/"+d_close_law.substring(5,7)+"/"+(Integer.parseInt(doString.checkString(d_close_law.substring(0,4)))+544)%>" size="30">
    </span></td>
    </tr>	

<%				
						
				
count++;
			} // loop 3
			rs2.close();

		} // loop 2
		rs1.close();
		
	} // loop 1
	rs.close();

}// Go

//--------------------------- Check Site is Condo -------------------
		chk_condo = "";
		query.delete(0, query.length());
		query.append("select i_company, i_project ")
			 .append("from lan:serv_condo ")
			 .append("where i_company = '"+comId+"' ")
			 .append("and i_project = '"+projId+"' ");
		rs = stmt.executeQuery(query.toString());
		if (rs.next()==true) {
			chk_condo = "Y";
		} else {
			chk_condo = "N";
		}
%>
        

      <tr>
        <td width="3%" align="center" class="dotline">&nbsp;</td>
        <td width="2%" align="center" class="dotline">&nbsp;</td>
            <td width="6%" class="dotline">&nbsp;</td>
        <td width="5%" class="dotline" align="center">&nbsp;</td>
        <td width="16%" class="dotline ; item">&nbsp;</td>
        <td width="10%" class="dotline ; item">&nbsp;</td>
        <td width="12%" class="dotline ; item">&nbsp;</td>
        <td width="18%" class="dotline ; item">&nbsp;</td>
        <td width="16%" class="dotline ; item">&nbsp;</td>
        <td width="12%" class="dotline ; item">&nbsp;</td>


    </table></td>
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
<table border="0" width="100%" cellspacing="0" cellpadding="0"
							height="30" >
          <tr>
            <td width="6" valign="top"><img border="0"
									src="images/b3_tab1.gif" width="6" height="30"></td>
            <td width="75" background="images/b3_tab2.gif"
									style="background-repeat: repeat-x" valign="top"><p><a href="javascript:print('<%=chk_condo%>');"><img border="0" src="images/act_print.gif" width="70" height="27"></a> </td>
            <td width="70" valign="top"><a href ="javascript:deleted();" ><img src="images/act_delete.gif" width="70" height="27" border="0"></a></td>
            <td width="57" valign="top"><img border="0"
									src="images/b3_tab3.gif" width="57" height="30"></td>
            <td width="100%" valign="top" background="images/b3_tab4.gif"
									style="background-repeat: repeat-x"><p align="right"><a href="javascript:history.back()"></a><span class="act_tab4"><a href="javascript:history.back()" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp; <a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></span>&nbsp;&nbsp;&nbsp; <a href="CRM_Home.jsp"></a> </td>
          </tr>
      </table>
    <p>&nbsp;</p></td>
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
</Form>	
</BODY>

</HTML>


<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_SearchLetter2.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (rs1 != null) rs.close();
			if (rs2 != null) rs.close();
			if (rs3 != null) rs.close();
			if (stmt != null) stmt.close();
			if (stmt1 != null) stmt.close();
			if (stmt2 != null) stmt.close();
			if (stmt3 != null) stmt.close();
			if (conn != null) conn.close();

		}
		catch( SQLException ignore ){}
	}
%>