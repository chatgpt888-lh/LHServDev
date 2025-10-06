<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.*" %>
<%@page import="serv.common.*" %>
<%@page import="serv.util.ServLog" %>
<%@include file="confirmLogin.jsp" %>
<%@include file="function.jsp" %> 
<%!
 	private String getNProject(Statement stmt, String i_company,String i_project) throws SQLException {
		String n_project = "";
		ResultSet rs = stmt.executeQuery("select n_project from lan:acxprojt where i_company = '"+ i_company + "' and i_project = '" + i_project + "' ");
		
		//System.out.println("select n_project from lan:acxprojt where i_company = '"+ i_company + "' and i_project = '" + i_project + "' ");
		if (rs.next()) {
			n_project = doString.checkString(rs.getString("n_project"), "");
		}
		rs.close();
		return n_project;
	}
	private String getNEmploy(Statement stmt, String i_employ) throws SQLException {
		String n_employ = "";
		ResultSet rs = stmt.executeQuery("select n_nemploy_th || ' ' || n_semploy_th as n_employ from docflow:acemploy where i_employ = '"+i_employ+"' ");
		//System.out.println("select n_nemploy_th || ' ' || n_semploy_th as n_employ from docflow:acemploy where i_employ = '"+i_employ+"' ");
		if (rs.next()) {
			n_employ = doString.checkString(rs.getString("n_employ"), "");
		}
		rs.close();
		return n_employ;
	}
	private String getNVendor(Statement stmt, String i_vendor) throws SQLException {
		String n_vendor = "";
		ResultSet rs = stmt.executeQuery("select bus_name[1,30] as bus_name from lan:stpvendr where vend_code = '"+i_vendor+"' ");
		//System.out.println("select bus_name[1,30] as bus_name from lan:stpvendr where vend_code = '"+i_vendor+"' ");
		if (rs.next()) {
			n_vendor = doString.checkString(rs.getString("bus_name"), "");
		}
		rs.close();
		return n_vendor;
	}
%>

<%
	Calendar right = Calendar.getInstance();
	int dd = right.get(Calendar.DATE);
	int mm = right.get(Calendar.MONTH) + 1;
	int yy = right.get(Calendar.YEAR);
	if (yy < 2400) {
		yy += 543;
	}
	String shortMonth[] = {"ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค."};
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	Statement stmt2 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	ResultSet rs2 = null;
	StringBuffer sql = new StringBuffer("");

	String project = "";
	String i_company = "";
	String i_project = "";
	
	String col_order = "";
	String i_vendor1 = "";
	String have_03 = "";
	String i_employ_m1 = "";
	String i_employ_m2 = "";
	String i_employ_m3 = "";
	String i_employ_s1 = "";
	String i_employ_s2 = "";
	String i_employ_s3 = "";
	int count_emp = 0;
	
	StringBuffer tableRow = new StringBuffer("");
	StringBuffer tableRow99 = new StringBuffer("");
	StringBuffer tableSum99 = new StringBuffer("");
	String i_zone_args = "";
	
	try {
		if(ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(false);
		stmt = conn.createStatement();
		stmt1 = conn.createStatement();
		stmt2 = conn.createStatement();
		
		col_order = doString.checkString(request.getParameter("col_order"), "i_zone");
		
		String go  = doString.checkString(request.getParameter("go"), "N");
		project = doString.checkString(request.getParameter("project"), "");
		i_zone_args = doString.checkString(request.getParameter("i_zone"), "");
		

		i_company = doString.checkString(request.getParameter("i_company"), "");
		i_project = doString.checkString(request.getParameter("i_project"), "");
		
		if(!"".equals(project) && !"all".equals(project) ){
			i_company = project.substring(0,2);
			i_project = project.substring(2,5);
		}
		
		if("Y".equals(go) && "all".equals(project)){
			i_zone_args = "01";
			project = "";
		}
		
		int check_user_all = 0;
		sql.delete(0,sql.length());
		sql.append(" select count(*) as total from lan:serv_pstaff where user_id = '"+user.getUserID()+"' and proj_id = 'ALL' ");
		rs = stmt.executeQuery(sql.toString());
		if(rs.next()){
			check_user_all = rs.getInt("total");
		}
		rs.close();
				
		
%>
<%@page import="java.text.SimpleDateFormat"%>
<html>
<head>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8">
<link rel="stylesheet" href="SERV_Report_Style.css" type="text/css">
<script src="/LHServ/js/device.js" type="text/javascript" ></script>
<script src="jquery/jquery.min.js" type="text/javascript" ></script>
<style type="text/css">
.hidden-one { display: none; }
.show-one { display: inline; }
.hidden-two { display: none; }
.show-two { display: inline; }

@media only screen and (max-width:700px) {
	.showhide{
        display: none;
    }
}
.rotate {
	/* Safari */
	-webkit-transform: rotate(-90deg);
	
	/* Firefox */
	-moz-transform: rotate(-90deg);
	
	/* IE */
	-ms-transform: rotate(-90deg);
	
	/* Opera */
	-o-transform: rotate(-90deg);
	
	/* Internet Explorer */
	filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);

}
.loader {
	position: fixed;
	left: 0px;
	top: 0px;
	width: 100%;
	height: 100%;
	z-index: 9999;
	background: url('images/ajax-loader.gif') 50% 50% no-repeat rgba(249,249,249,0.6);
	color:#333;
	font-size:14px;
	font-family: url('font/SMALLE.FON');
}
body{
	margin:0;
	padding:0;
}
#content{
	padding:5px;
}
</style>
<script type="text/javascript" >
$(window).load(function() {
	$(".loader").fadeOut("slow");
});

function initPage(){
	var form = document.frmSERV;
	if(device.mobile()){
		//document.getElementById("mobile").innerHTML = 'Hello Mobile';
	}
}
function dispSide(){
	if(document.frmSERV.hide_one.value == 'Y'){
		var elements = getElementsByClass('hidden-one');
		for (i = 0 ; i < elements.length ; i++ ) {
		    //elements[i].className = 'show-one';
		    elements[i].style.display = 'inline';
		}
		document.frmSERV.hide_one.value = 'N';
		document.getElementById("disp-side-btn").src = 'images/bu_R.gif';
		document.getElementById("td-header").colSpan = 10;
	}else{
		var elements = getElementsByClass('hidden-one');
		for (i = 0 ; i < elements.length ; i++ ) {
		    //elements[i].className = 'hidden-one';
		    elements[i].style.display = 'none';
		}
		document.frmSERV.hide_one.value = 'Y';
		document.getElementById("disp-side-btn").src = 'images/bu_L.gif';
		document.getElementById("td-header").colSpan = 7;
	}
}
function dispDown(){
	if(document.frmSERV.hide_two.value == 'Y'){
		var elements = getElementsByClass('hidden-two');
		for (i = 0 ; i < elements.length ; i++ ) {
		    //elements[i].className = 'show-two';
		    elements[i].style.display = 'inline';
		}
		document.frmSERV.hide_two.value = 'N';
		document.getElementById("disp-down-btn").src = 'images/bu_U.gif';
	}else{
		var elements = getElementsByClass('hidden-two');
		for (i = 0 ; i < elements.length ; i++ ) {
		    //elements[i].className = 'hidden-two';
		    elements[i].style.display = 'none';
		}
		document.frmSERV.hide_two.value = 'Y';
		document.getElementById("disp-down-btn").src = 'images/bu_D.gif';
	}
}
//Function Support
function getElementsByClass( searchClass, domNode, tagName) { 
	if (domNode == null) domNode = document;
	if (tagName == null) tagName = '*';
	var el = new Array();
	var tags = domNode.getElementsByTagName(tagName);
	var tcl = " "+searchClass+" ";
	for(i=0,j=0; i<tags.length; i++) { 
		var test = " " + tags[i].className + " ";
		if (test.indexOf(tcl) != -1) 
			el[j++] = tags[i];
	} 
	return el;
} 
function beyond(theComp,theProj,itmtype){
	var form = document.frmSERV;
	form.i_company.value = theComp;
	form.i_project.value = theProj;
	form.itmtype.value = itmtype;
	//form.sort_col.value = '';
	form.action = '/LHServ/SERV_ReportServiceDetails.jsp';
	form.submit();
}
function doOrder(theCol){
	var form = document.frmSERV;
	form.col_order.value = theCol;
	form.action = '/LHServ/SERV_ReportService.jsp';
	form.submit();
}

function goByProject(){
	var form = document.frmSERV;
	form.go.value = 'Y';
	form.submit();
}
</script>
</head>

<body marginwidth="10" marginheight="10" leftmargin="10" topmargin="10" onload="initPage()" >
<div id="content" >
<form name="frmSERV" method="POST" action="/LHServ/SERV_ReportService.jsp"  >
<!-- input hidden -->
<input type="hidden" name="hide_one" value="Y" />
<input type="hidden" name="hide_two" value="Y" />
<input type="hidden" name="i_company" />
<input type="hidden" name="i_project" />
<input type="hidden" name="itmtype" />
<input type="hidden" name="col_order" />
<input type="hidden" name="go" />
<input type="hidden" name="i_zone" value="<%=i_zone_args%>" />
<%--
<table border="0" cellpadding="0" cellspacing="0" width="1270px">
 <tr height="30">
  <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
  สรุปรายงานซ่อมหลังโอน   ณ วันที่ <%=dd%>/<%=mm%>/<%=yy%> </td>
 </tr>
</table>
--%>
<div id="content-table" >
<br/>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr height="22">
		<td id="td-header" colspan="7" class="bigh" >
		<img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp; สรุปรายงานซ่อมหลังโอน   ณ วันที่ <%=dd%>/<%=mm%>/<%=yy%></td>
  	</tr>
</table>
<br/>
<table border="0" width="800" cellspacing="0" cellpadding="0">
  <tbody>
  <tr>
    <td width="5" valign="top"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop">&nbsp;</td>
    <td width="5" valign="top" align="right"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
 </tbody>
</table>
<table border="0" width="800" cellspacing="0" cellpadding="0">
  <tbody>
  	<tr>
	    <td width="100%" class="frmLR" align="center">
			<table border="0" width="100%" cellspacing="0" cellpadding="0">
				<tbody>
					<%--
				  <tr>
				    <td height="22" width="37%" class="item dotline01"><a href="<%=request.getContextPath()%>/SERV_ReportServiceByZone.jsp" >แสดงรายงานสรุปรวม Zone</a></td>
				  </tr>
				  
				  <tr>
				    <td height="22" width="37%" class="item dotline01">แสดงรายงานตาม Zone &nbsp;
						<select name="i_zone" class="boxC">
						<%
						sql.delete(0,sql.length());
						sql.append(" select distinct d.i_zone ")
						.append(" from lan:acsbudgh a , lan:serv_pstaff c  , lan:serv_lstaff d ")
						.append(" where a.i_company = c.com_id ")
						.append(" and a.i_project = c.proj_id ")
						.append(" and a.i_company = d.i_company ")
						.append(" and a.i_project = d.i_project ")
						.append(" and (d.i_zone is not null and d.i_zone <> '') ")
						.append(" and a.d_year = '"+yy+"' ")
						.append(" and a.i_budg_type = 9 ")
						//.append(" and a.i_group not in ('05','10','11','12') ")
						//.append(" and a.i_group not in ('10','11','12') ");
						//.append(" and a.i_group not in ('10','12') ");
						.append(" and a.i_group in ('00','01','02','03','04','05','06','07','08','09','11','99','G9') ");
						if(check_user_all == 0){
							sql.append(" and c.user_id = '"+user.getUserName()+"' ");
						}
						rs = stmt.executeQuery(sql.toString());
						while(rs.next()){
						%>
						<option value="<%=rs.getString("i_zone")%>" >Zone <%=Integer.parseInt(rs.getString("i_zone"))%></option>
						<%
						}
						rs.close();
						
						 %>
						</select>
						&nbsp;
						<a href="#" onclick="goByZone()"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a>
					</td>
				  </tr>
				  --%>
				  <tr>
				    <td height="22" width="37%" class="item dotline01">โครงการ &nbsp;
						<select name="project" class="box">
						<option value="all" >---------ดูทุกโครงการ---------</option>
						<%
						sql.delete(0,sql.length());
						sql.append(" select distinct a.i_company , a.i_project , b.n_project ")
						.append(" from lan:acsbudgh a , lan:acxprojt b , lan:serv_pstaff c  , lan:serv_lstaff d ")
						.append(" where 1=1 ")
						.append(" and a.i_company = b.i_company ")
						.append(" and a.i_project = b.i_project ")
						.append(" and a.i_company = c.com_id ")
						.append(" and a.i_project = c.proj_id ")
						.append(" and a.i_company = d.i_company ")
						.append(" and a.i_project = d.i_project ")
						.append(" and (d.i_zone is not null and d.i_zone <> '') ")
						.append(" and a.d_year = year(today)+543 ")
						.append(" and a.i_budg_type = 9 ")
						//.append(" and a.i_group not in ('05','10','11','12') ")
						//.append(" and a.i_group not in ('10','11','12') ");
						//.append(" and a.i_group not in ('10','12') ");
						.append(" and a.i_group in ('00','01','02','03','04','05','06','07','08','09','11','99','G9') ");
						if(check_user_all == 0){
							sql.append(" and c.user_id = '"+user.getUserName()+"' ");
							//	.append(" and c.user_who  = 'Z' ");
						}
						rs= stmt.executeQuery(sql.toString());
						while(rs.next()){
						%>
						<option value="<%=rs.getString("i_company")+rs.getString("i_project")%>" <% if(project.equals(rs.getString("i_company")+rs.getString("i_project"))){ %> selected <% } %>><%=rs.getString("i_company")+rs.getString("i_project")+" - "+doString.DisplayThai(rs.getString("n_project"))%></option>
						<%
						}
						rs.close();
						 %>
						</select>
						&nbsp;
						<a href="#" onclick="goByProject()"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a>
					</td>
				  </tr>
				</tbody>
			</table>
		</td>
	  </tr>
	</tbody>
</table>
<table border="0" width="800" cellspacing="0" cellpadding="0">
	  <tbody><tr>
	    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
	    <td class="frmBottom">&nbsp;</td>
	    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
	  </tr>
	</tbody>
</table>
<br/>

<% if("Y".equals(go) || !"".equals(i_zone_args)){ %>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr height="22">
	<td>&nbsp;</td>
	<td id="td-header" colspan="10" class="bigh" >&nbsp;</td>
	<td colspan="4" align="center" bgcolor="#E1F5FF" style="color:rgb(50,100,200) ; font-weight:bold ; font-size:10pt ; border-left:1px solid rgb(135,185,247) ; border-top:1px solid rgb(135,185,247) ; border-right:1px solid rgb(135,185,247)">Service<br/>Request</td>
    <td colspan="3" align="center" bgcolor="#E1F5FF" style="color:rgb(50,100,200) ; font-weight:bold ; font-size:10pt ; border-top:1px solid rgb(135,185,247) ; border-right:1px solid rgb(135,185,247)">Service<br/>Order</td>
	<td></td>
    <td colspan="4" align="center" bgcolor="#E1F5FF" style="color:rgb(50,100,200) ; font-weight:bold ; font-size:10pt ; border-left:1px solid rgb(135,185,247) ; border-top:1px solid rgb(135,185,247) ; border-right:1px solid rgb(135,185,247)">Service<br/>WIP</td>    
	              
  </tr>
  <tr>
    <td rowspan="3" class="col_nameREP" style="border-left:1px solid rgb(135,185,247) ; border-top:1px solid rgb(135,185,247)">No.</td>
    <td rowspan="3" class="col_nameREP" style="border-left:1px solid rgb(135,185,247) ; border-top:1px solid rgb(135,185,247)">Zone</td>
    <td colspan="3" rowspan="2" class="col_nameREP" style="border-left:1px solid rgb(135,185,247) ; border-top:1px solid rgb(135,185,247)">ผู้รับผิดชอบ</td>
    <td width="2px" rowspan="3" >&nbsp;</td>
    <td rowspan="3" class="col_nameREP" style="border-left:1px solid rgb(135,185,247) ; border-top:1px solid rgb(135,185,247)">โครงการ</td>
    <td colspan="3" rowspan="2" class="col_nameREP" style="border-top:1px solid rgb(135,185,247)">จำนวนบ้าน(หลัง)</td>
    <td rowspan="3" >&nbsp;</td>
    <td colspan="4" rowspan="2" class="col_nameREP" bgcolor="#E1F5FF" style="border-left:1px solid rgb(135,185,247) ; border-top:1px solid rgb(135,185,247)">Inform<br/>(วันที่นัดหมาย)</td>
    <td colspan="3" rowspan="2" class="col_nameREP" bgcolor="#E1F5FF" style="border-top:1px solid rgb(135,185,247)">Open<br/>(วันที่นัดซ่อม)</td>    
    <td rowspan="3" >&nbsp;</td>
    <td colspan="3" rowspan="2" class="col_nameREP02" style="border-left:1px solid rgb(135,185,247) ; border-top:1px solid rgb(135,185,247)">Start Task<br/>(วันประมาณการเสร็จ)</td>
    <td rowspan="3" class="col_nameREP02" style="border-top:1px solid rgb(135,185,247)">Complete</td>
  </tr>
  <tr>
    
  </tr>
  <tr>
    <td width="7%" class="col_nameREP ; ">Manager</td>
    <td width="7%" class="col_nameREP ; ">Engineer&amp;Staff</td>
    <td width="3%" class="col_nameREP ; ">#Emp</td>
    <td width="4%" class="col_nameREP">Total</td>
    <td width="4%" class="col_nameREP">โอนแล้ว</td>
    <td width="4%" class="col_nameREP">ประกัน(15M)</td>
    <td width="4%" class="col_nameREP" bgcolor="#E1F5FF" style="border-left:1px solid rgb(135,185,247)">ยังไม่เลยกำหนด</td>
    <td width="4%" colspan="2" class="col_nameREP" bgcolor="#E1F5FF">เลยกำหนด<span style="color:green;">*</span></td>
    <td width="4%" class="col_nameREP" bgcolor="#E1F5FF">Pending</a></td>
    <td width="4%" class="col_nameREP" bgcolor="#E1F5FF">ยังไม่เลยกำหนด</a></td>
    <td width="4%" class="col_nameREP" bgcolor="#E1F5FF" style="border-left:1px solid rgb(135,185,247)">เลยกำหนด</a></td>
    <td width="4%" class="col_nameREP" bgcolor="#E1F5FF">Pending</a></td>
    <td width="4%" class="col_nameREP02"  style="border-left:1px solid rgb(135,185,247)">ยังไม่เลยกำหนด</td>
    <td width="4%" class="col_nameREP02" >เลยกำหนด</td>
    <td width="" class="col_nameREP02" bgcolor="#E1F5FF">Pending</td>
    </td>
  </tr>
 <%
 out.flush();
 
 int day1 = 0;
 int day2 = 0;
 int day3 = 0;
 int day4 = 0;
 int day5 = 0;
 int day6 = 0;
 int day7 = 0; 
 
 int sum_day1 = 0;
 int sum_day2 = 0;
 int sum_day3 = 0;
 int sum_day4 = 0;
 int sum_day5 = 0;
 int sum_day6 = 0;
 int sum_day7 = 0;
 
 int sum99_day1 = 0;
 int sum99_day2 = 0;
 int sum99_day3 = 0;
 int sum99_day4 = 0;
 int sum99_day5 = 0;
 int sum99_day6 = 0;
 int sum99_day7 = 0;
 
 String i_zone = "";
 String tmp_zone = "";
 String n_project = "";
 int status_starttask1 = 0;
 int status_starttask2 = 0;
 int status_open1 = 0;
 int status_open2 = 0;
 int status_notopen1 = 0;
 int status_notopen2 = 0;
 int status_notopen1x = 0;
 int status_notopen2x = 0;
 int status_complete = 0;
 int pending_open = 0;
 int pending_notopen = 0;
 int pending_starttask = 0;
 int count = 0;
 
 int sum_status_starttask1 = 0;
 int sum_status_starttask2 = 0;
 int sum_status_open1 = 0;
 int sum_status_open2 = 0;
 int sum_status_notopen1 = 0;
 int sum_status_notopen2 = 0;
 int sum_status_notopen2x = 0;
 int sum_status_complete = 0;
 int sum_pending_open = 0;
 int sum_pending_notopen = 0;
 int sum_pending_starttask = 0;
 
 int sum99_status_starttask1 = 0;
 int sum99_status_starttask2 = 0;
 int sum99_status_open1 = 0;
 int sum99_status_open2 = 0;
 int sum99_status_notopen1 = 0;
 int sum99_status_notopen2 = 0;
 int sum99_status_notopen2x = 0;
 int sum99_status_complete = 0;
 int sum99_pending_open = 0;
 int sum99_pending_notopen = 0;
 int sum99_pending_starttask = 0;
 
 //Hidden Bottom
 boolean f_99 = false;
 
 
 int num_total = 0;
 int num_lor = 0;
 int num_m15 = 0;
 
 int sum_num_total = 0;
 int sum_num_lor = 0;
 int sum_num_m15 = 0;
 
 int sum99_num_total = 0;
 int sum99_num_lor = 0;
 int sum99_num_m15 = 0;
 
 String old_zone = "";
 String stlyeClass = "";
 String stlyeClassX = "";
 
String d_complete_max_begin = "";
String d_complete_max_end = "";
sql.delete(0,sql.length());
sql.append(" select day(d_contructor) day1 , month(d_contructor) month1 , year(d_contructor) year1 , ")
 	.append(" day(d_contructor - 1 units month) day2 , month(d_contructor - 1 units month) month2 , year(d_contructor - 1 units month) year2  ")
	.append(" from lan:serv_payschd  ")
	.append(" where month(d_contructor) = month(today)  ")
	.append(" and year(d_contructor) = year(today)  ");
rs = stmt.executeQuery(sql.toString());
if(rs.next()){
	d_complete_max_begin = rs.getInt("year2")+"-"+rs.getInt("month2")+"-"+rs.getInt("day2");
	d_complete_max_end = rs.getInt("year1")+"-"+rs.getInt("month1")+"-"+rs.getInt("day1");
}
rs.close();

SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy hh:mm:ss");

System.out.println("Report Service : User "+user.getUserID());
System.out.println("Report Service : Before start select "+ sdf.format(new java.util.Date()));

sql.delete(0,sql.length());
sql.append(" select distinct g.i_zone , g.i_company , g.i_project , g.n_project , ")
.append(" nvl(status_starttask1,0) as status_starttask1 ,  ")
.append(" nvl(status_starttask2,0) as status_starttask2 ,  ")
.append(" nvl(status_open1,0)  as status_open1 ,  ")
.append(" nvl(status_open2,0)  as status_open2 , ")
.append(" nvl(status_notopen1,0) as status_notopen1 ,  ")
.append(" nvl(status_notopen2,0) as status_notopen2 ,  ")
.append(" nvl(status_notopen2x,0) as status_notopen2x ,  ")
.append(" nvl(status_complete,0) as status_complete ,  ")
.append(" nvl(pending_notopen,0) as pending_notopen ,  ")
.append(" nvl(pending_open,0) as pending_open ,  ")
.append(" nvl(pending_starttask,0) as pending_starttask  ")
.append(" from ( ")
.append(" select distinct d.i_zone , a.i_company , a.i_project , b.n_project ")
.append(" from lan:acsbudgh a , lan:acxprojt b , lan:serv_pstaff c  , lan:serv_lstaff d ")
.append(" where a.i_company = b.i_company ")
.append(" and a.i_project = b.i_project ")
.append(" and a.i_company = c.com_id ")
.append(" and a.i_project = c.proj_id ")
.append(" and a.i_company = d.i_company ")
.append(" and a.i_project = d.i_project ")
.append(" and a.d_year = year(today)+543 ")
.append(" and d.i_zone = '01' ")
.append(" and a.i_budg_type = 9 ")
//.append(" and a.i_group not in ('05','10','11','12') ")
//.append(" and a.i_group not in ('10','11','12') ");
//.append(" and a.i_group not in ('10','12') ");
.append(" and a.i_group in ('00','01','02','03','04','05','06','07','08','09','11','99','G9') ");
if(!"".equals(project)){
	sql.append(" and a.i_company = '"+i_company+"' ")
		.append(" and a.i_project = '"+i_project+"' ");
}
if(check_user_all == 0){
	sql.append(" and c.user_id = '"+user.getUserName()+"' ");
	//	.append(" and c.user_who  = 'Z' ");
}
sql.append(" ) as g, OUTER ( ")
.append(" select count(distinct a.i_docno) as status_starttask1 , a.i_company , a.i_project  ")
.append(" from lan:serv_dochd a , lan:serv_docdt b  ") 
.append(" where 1=1  ")   
.append(" and a.i_doc_type = 'J'  ")   
.append(" and a.f_status = 'OPN'  ") 
.append(" and a.i_docno = b.i_docno ")
.append(" and b.f_itmstatus = '300'  ")
.append(" and a.d_est_close >= today  ")  
.append(" and a.c_desc <> 'Checkup Program' ") 
.append(" and a.d_complete_max is null ")
.append(" and (a.f_pending in ('','OPN','INF') OR a.f_pending is null) ");
if(!"".equals(project)){
	sql.append(" and a.i_company = '"+i_company+"' ")
		.append(" and a.i_project = '"+i_project+"' ");
}
sql.append(" group by a.i_company , a.i_project ")
.append(" ) as a, OUTER ( ")
.append(" select count(distinct a.i_docno) as status_starttask2 , a.i_company , a.i_project ")
.append(" from lan:serv_dochd a , lan:serv_docdt b  ")                                       
.append(" where 1=1 ")                                                                    
.append(" and a.i_doc_type = 'J'  ")
.append(" and a.f_status = 'OPN' ")
.append(" and a.i_docno = b.i_docno   ")
.append(" and b.f_itmstatus = '300' ")
.append(" and a.d_est_close < today  ")                           
.append(" and a.c_desc <> 'Checkup Program' ")  
.append(" and a.d_complete_max is null  ") 
.append(" and (a.f_pending in ('','OPN','INF') OR a.f_pending is null) ");
if(!"".equals(project)){
	sql.append(" and a.i_company = '"+i_company+"' ")
		.append(" and a.i_project = '"+i_project+"' ");
}
sql.append(" group by a.i_company , a.i_project ")
.append(" ) as b, OUTER ( ")
.append(" select count(distinct a.i_docno) as status_open1 , a.i_company , a.i_project ")
.append(" from lan:serv_dochd a , lan:serv_docdt b ")
.append(" where a.i_doc_type = 'J' ")
.append(" and a.f_status = 'OPN' ")
.append(" and a.i_docno = b.i_docno ")
.append(" and b.f_itmstatus = '200' ")
.append(" and a.d_appoint >= TODAY ")
.append(" and a.c_desc <> 'Checkup Program' ")
.append(" and a.d_complete_max is null ")
.append(" and (a.f_pending in ('','STK','INF') OR a.f_pending is null) ");
if(!"".equals(project)){
	sql.append(" and a.i_company = '"+i_company+"' ")
		.append(" and a.i_project = '"+i_project+"' ");
}
sql.append(" group by a.i_company , a.i_project ")
.append(" ) as c1, OUTER ( ")
.append(" select count(distinct a.i_docno) as status_open2 , a.i_company , a.i_project ")
.append(" from lan:serv_dochd a , lan:serv_docdt b ")
.append(" where a.i_doc_type = 'J' ")
.append(" and a.f_status = 'OPN' ")
.append(" and a.i_docno = b.i_docno ")
.append(" and b.f_itmstatus = '200' ")
.append(" and a.d_appoint < TODAY ")
.append(" and a.c_desc <> 'Checkup Program' ")
.append(" and a.d_complete_max is null ")
.append(" and (a.f_pending in ('','STK','INF') OR a.f_pending is null) ");
if(!"".equals(project)){
	sql.append(" and a.i_company = '"+i_company+"' ")
		.append(" and a.i_project = '"+i_project+"' ");
}
sql.append(" group by a.i_company , a.i_project ")
.append(" ) as c2, OUTER( ")
.append(" SELECT COUNT(a.i_docno) AS status_notopen1 , a.i_company , a.i_project ")
.append(" FROM lan:serv_dochd a ")
.append(" WHERE a.i_doc_type = 'I' ")
.append(" AND a.f_status = 'OPN' ")
.append(" AND a.d_appoint_cust >= TODAY  ")
.append(" AND a.c_desc <> 'Checkup Program' ")
.append(" AND (a.f_pending in ('','OPN','STK') OR a.f_pending IS NULL)  ");
if(!"".equals(project)){
	sql.append(" and a.i_company = '"+i_company+"' ")
		.append(" and a.i_project = '"+i_project+"' ");
}
sql.append(" GROUP BY a.i_company , a.i_project   ")
.append(" ) as d1, OUTER ( ")
.append(" SELECT COUNT(a.i_docno) AS status_notopen2 , a.i_company , a.i_project ")
.append(" FROM lan:serv_dochd a ")
.append(" WHERE a.i_doc_type = 'I' ")
.append(" AND a.f_status = 'OPN' ")
.append(" AND a.d_appoint_cust < TODAY ")
.append(" AND a.c_desc <> 'Checkup Program' ")
.append(" AND (a.f_pending in ('','OPN','STK') OR a.f_pending IS NULL) ");
if(!"".equals(project)){
	sql.append(" and a.i_company = '"+i_company+"' ")
		.append(" and a.i_project = '"+i_project+"' ");
}
sql.append(" GROUP BY a.i_company , a.i_project ")
.append(" ) as d2, OUTER( ")
.append(" SELECT COUNT(a.i_docno) AS status_notopen2x , a.i_company , a.i_project ")
.append(" FROM lan:serv_dochd a ")
.append(" WHERE a.i_doc_type = 'I' ")
.append(" AND a.f_status = 'OPN' ")
.append(" AND a.d_appoint_cust < (TODAY-2) ")
.append(" AND a.c_desc <> 'Checkup Program' ")
.append(" AND (a.f_pending in ('','OPN','STK') OR a.f_pending IS NULL) ");
if(!"".equals(project)){
	sql.append(" and a.i_company = '"+i_company+"' ")
		.append(" and a.i_project = '"+i_project+"' ");
}
sql.append(" GROUP BY a.i_company , a.i_project ")
.append(" ) as d2x, OUTER( ")
.append(" select count(a.i_docno) as status_complete , a.i_company ,  ")
.append(" a.i_project  ")
.append(" from lan:serv_dochd as a ")
.append(" where a.i_doc_type = 'J'   ")
.append(" and a.d_complete_max > '"+d_complete_max_begin+"'  ")
.append(" and a.d_complete_max <= '"+d_complete_max_end+"'  ")
.append(" and a.c_desc <> 'Checkup Program' ")
.append(" and a.f_status <> 'CAN' ");
if(!"".equals(project)){
	sql.append(" and a.i_company = '"+i_company+"' ")
		.append(" and a.i_project = '"+i_project+"' ");
}
sql.append(" group by a.i_company , a.i_project ")
.append(" ) as e , OUTER( ")
.append(" select i_company,i_project,count(distinct i_docno) as pending_notopen from serv_dochd ")
.append(" where i_doc_type = 'I' ")
.append(" and f_status = 'OPN' ")
.append(" and f_pending = 'INF' ")
.append(" and c_desc <> 'Checkup Program'  ");
if(!"".equals(project)){
	sql.append(" and i_company = '"+i_company+"' ")
		.append(" and i_project = '"+i_project+"' ");
}
sql.append(" group by 1,2 ) as h ,  OUTER( ")
.append(" select i_company,i_project,count(distinct a.i_docno) as pending_open from ")
.append("  lan:serv_dochd a , lan:serv_docdt b  ")
.append(" where a.i_doc_type = 'J' ")
.append(" and a.f_status = 'OPN' ")
.append(" and a.f_pending = 'OPN' ")
.append(" and a.i_docno = b.i_docno ")
.append(" and b.f_itmstatus = '200' ")
.append(" and c_desc <> 'Checkup Program' ")
.append(" and a.d_complete_max is null ");
if(!"".equals(project)){
	sql.append(" and a.i_company = '"+i_company+"' ")
		.append(" and a.i_project = '"+i_project+"' ");
}
sql.append(" group by 1,2  ) as j ,  OUTER( ")
.append(" select a.i_company,a.i_project,count(distinct a.i_docno) as pending_starttask ")
.append(" from lan:serv_dochd a , lan:serv_docdt b  ")
.append(" where a.i_doc_type = 'J' ")
.append(" and a.f_status = 'OPN' ")
.append(" and a.f_pending = 'STK'  ")
.append(" and b.f_itmstatus = '300'  ")
.append(" and c_desc <> 'Checkup Program' ")
.append(" and a.d_complete_max is null ")
.append(" and a.i_docno = b.i_docno ");
if(!"".equals(project)){
	sql.append(" and a.i_company = '"+i_company+"' ")
		.append(" and a.i_project = '"+i_project+"' ");
}
sql.append(" group by 1,2 ) as k ")
.append(" where 1=1 ")
.append(" and g.i_company = a.i_company ")
.append(" and g.i_project = a.i_project ")
.append(" and g.i_company = b.i_company ")
.append(" and g.i_project= b.i_project ")
.append(" and g.i_company = c1.i_company ")
.append(" and g.i_project= c1.i_project ")
.append(" and g.i_company = c2.i_company ")
.append(" and g.i_project= c2.i_project ")
.append(" and g.i_company = d1.i_company ")
.append(" and g.i_project= d1.i_project ")
.append(" and g.i_company = d2.i_company ")
.append(" and g.i_project= d2.i_project ")
.append(" and g.i_company = d2x.i_company ")
.append(" and g.i_project= d2x.i_project ")
.append(" and g.i_company = e.i_company ")
.append(" and g.i_project= e.i_project ")
.append(" and g.i_company = h.i_company ")
.append(" and g.i_project= h.i_project ")
.append(" and g.i_company = j.i_company ")
.append(" and g.i_project= j.i_project ")
.append(" and g.i_company = k.i_company ")
.append(" and g.i_project= k.i_project ");
if(!"".equals(project)){
	sql.append(" and g.i_company = '"+i_company+"' ")
		.append(" and g.i_project = '"+i_project+"' ");
}
if(!"".equals(i_zone_args)){
	sql.append(" and g.i_zone = '"+i_zone_args+"' ");
}
sql.append(" order by g.i_zone , g.i_company , g.i_project ");

/*
if("n_project".equals(col_order)){
	sql.append(" order by g.n_project , g.i_company , g.i_project , g.i_zone ");
}else if("status_open1".equals(col_order)){
	sql.append(" order by status_open1 desc , g.i_zone , g.i_company , g.i_project ");
}else if("status_open2".equals(col_order)){
	sql.append(" order by status_open2 desc , g.i_zone , g.i_company , g.i_project ");
}else if("status_notopen1".equals(col_order)){
	sql.append(" order by status_notopen1 desc , g.i_zone , g.i_company , g.i_project ");
}else if("status_notopen2".equals(col_order)){
	sql.append(" order by status_notopen2 desc , g.i_zone , g.i_company , g.i_project ");
}else if("status_starttask1".equals(col_order)){
	sql.append(" order by status_starttask1 desc , g.i_zone , g.i_company , g.i_project ");
}else if("status_starttask2".equals(col_order)){
	sql.append(" order by status_starttask2 desc , g.i_zone , g.i_company , g.i_project ");
}else if("status_complete".equals(col_order)){
	sql.append(" order by status_complete desc , g.i_zone , g.i_company , g.i_project ");
}else if("pending_open".equals(col_order)){
	sql.append(" order by pending_open desc , g.i_zone , g.i_company , g.i_project ");
}else if("pending_notopen".equals(col_order)){
	sql.append(" order by pending_notopen desc , g.i_zone , g.i_company , g.i_project ");
}else if("pending_starttask".equals(col_order)){
	sql.append(" order by pending_starttask desc , g.i_zone , g.i_company , g.i_project ");
}else{
	sql.append(" order by g.i_zone , g.i_company , g.i_project ");
}
*/
System.out.println(sql.toString());
rs = stmt.executeQuery(sql.toString());
while(rs.next()){
 		
 		++count;
 		tmp_zone = doString.checkString(rs.getString("i_zone"),"");
 		
 		if("i_zone".equals(col_order)){
	 		if("".equals(old_zone)){
	 			old_zone = tmp_zone;
	 			stlyeClass = "dotlineREP";
	 			stlyeClassX = "dotline01";
	 		}else if(!old_zone.equals(tmp_zone)){
	 			old_zone = tmp_zone;
	 			stlyeClass = "solidlineREP01";
	 			stlyeClassX = "solidlineREP03";
	 		}else{
	 			stlyeClass = "dotlineREP";
	 			stlyeClassX = "dotline01";
	 		}
	 	}else{
	 		stlyeClass = "dotlineREP";
	 		stlyeClassX = "dotline01";
	 	}
 		
 		if(count > 1){
 			tableRow.delete(0,tableRow.length());
		 	tableRow.append("<tr>\n")
		    .append("<td align=\"right\" class=\"item "+stlyeClass+"\"  style=\"border-left:1px solid rgb(135,185,247);text-align:center\" >"+(count-1)+"&nbsp;</td>\n")
		    .append("<td align=\"center\" class=\""+stlyeClass+"\" style=\"border-left:1px solid rgb(135,185,247)\" >"+i_zone+"</td>\n")
		    .append("<td class=\""+stlyeClass+" ; item ; \" style=\"color: rgb(255,100,0);\">"+doString.DisplayThai(i_employ_m1)+"&nbsp;</td>\n")
		    .append("<td class=\""+stlyeClass+" ; \" style=\"color: rgb(255,100,0);\">"+doString.DisplayThai(i_employ_s1)+"&nbsp;</td>\n")
		    .append("<td align=\"center\" class=\""+stlyeClass+" ; \">"+count_emp+"&nbsp;</td>\n")
		    .append("<td >&nbsp;</td>\n")
		    .append("<td class=\""+stlyeClass+" ; item\" style=\"border-left:1px solid rgb(135,185,247);color: rgb(255,100,0);\">"+i_company+i_project+ " - " +doString.DisplayThai(n_project)+have_03+"</td>\n")
		    .append("<td align=\"right\" class=\""+stlyeClass+"\">"+doString.displayNumber("#,##0",num_total+0.0d)+"</td>\n")
		    .append("<td align=\"right\" class=\""+stlyeClass+"\">"+doString.displayNumber("#,##0",num_lor+0.0d)+"</td>\n")
		    .append("<td align=\"right\" class=\""+stlyeClass+" ; item\">"+doString.displayNumber("#,##0",num_m15+0.0d)+"</td>\n")
		    .append("<td >&nbsp;</td>\n")
		    .append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\""+stlyeClass+"\" style=\"border-left:1px solid rgb(135,185,247)\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',4.1)\" >"+status_notopen1+"</a></td>\n")
		 	.append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\""+stlyeClassX+"\"><a href=\"#\" onclick=\"beyond('"+i_company+"','"+i_project+"',4.2)\" >"+status_notopen2x+"</a></td>\n")
		 	.append("<td bgcolor=\"#E1F5FF\" class=\""+stlyeClass+"\"><a href=\"#\" onclick=\"beyond('"+i_company+"','"+i_project+"',4.2)\" >");
			if( 0 == status_notopen2x &&  0 == status_notopen2){
				tableRow.append("&nbsp;");
			}else{
				tableRow.append("&nbsp;("+status_notopen2+")");
			}
		  	tableRow.append("</a></td>\n")
		    .append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\""+stlyeClass+"\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',4.3)\" >"+pending_notopen+"</a></td>\n")
		    .append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\""+stlyeClass+"\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',3.1)\" >"+status_open1+"</a></td>\n")
		    .append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\""+stlyeClass+"\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',3.2)\" >"+status_open2+"</a></td>\n")
		    .append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\""+stlyeClass+"\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',3.3)\" >"+pending_open+"</a></td>\n")
		    .append("<td >&nbsp;</td>\n")
		    .append("<td align=\"right\" bgcolor=\"#EBFFEB\" class=\""+stlyeClass+"\" style=\"border-left:1px solid rgb(135,185,247)\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',6.1)\" >"+status_starttask1+"</a></td>\n")
		    .append("<td align=\"right\" bgcolor=\"#EBFFEB\" class=\""+stlyeClass+"\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',6.2)\" >"+status_starttask2+"</a></td>\n")
		    .append("<td align=\"right\" bgcolor=\"#EBFFEB\" class=\""+stlyeClass+"\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',6.3)\" >"+pending_starttask+"</a></td>\n")
		    .append("<td align=\"right\" bgcolor=\"#EBFFEB\" class=\""+stlyeClass+"\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',7.1)\" >"+doString.displayNumber("#,##0",status_complete+0.0d)+"</a></td>\n")
		    .append("</tr>\n");
			 out.println(tableRow.toString());
 		}
 		
		i_zone = tmp_zone;
 		i_company = doString.checkString(rs.getString("i_company"),"");
		i_project = doString.checkString(rs.getString("i_project"),"");
		n_project = doString.checkString(rs.getString("n_project"),"");
		
		status_starttask1 = rs.getInt("status_starttask1");
		status_starttask2 = rs.getInt("status_starttask2");
		status_open1 = rs.getInt("status_open1");
		status_open2 = rs.getInt("status_open2");
		status_notopen1 = rs.getInt("status_notopen1");
		status_notopen2 = rs.getInt("status_notopen2");
		status_notopen2x = rs.getInt("status_notopen2x");
		status_complete = rs.getInt("status_complete");
		pending_notopen = rs.getInt("pending_notopen");
		pending_open = rs.getInt("pending_open");
		pending_starttask = rs.getInt("pending_starttask");
		
		sum_status_starttask1 += status_starttask1;
		sum_status_starttask2 += status_starttask2;
		sum_status_open1 += status_open1;
		sum_status_open2 += status_open2;
		sum_status_notopen1 += status_notopen1;
		sum_status_notopen2 += status_notopen2;
		sum_status_notopen2x += status_notopen2x;
		sum_status_complete += status_complete;
		sum_pending_notopen += pending_notopen;
		sum_pending_open += pending_open;
		sum_pending_starttask += pending_starttask;
		
 		num_total = 0;
 		sql.delete(0,sql.length());
 		sql.append(" select count(*) as num_total from lan:acxslock where i_company = '"+i_company+"' and i_project = '"+i_project+"' ");
 		rs1 = stmt1.executeQuery(sql.toString());
 		if(rs1.next()){
 			num_total = rs1.getInt("num_total");
 			sum_num_total += num_total;
 		}
 		rs1.close();
 		
 		num_lor = 0;
 		sql.delete(0,sql.length());
 		sql.append(" select count(*) as num_lor from lan:acscontr where d_close_law is not null and ( f_contr is null or f_contr = '' ) and i_company = '"+i_company+"' and i_project = '"+i_project+"' ");
 		
		//System.out.println(sql.toString());
 		rs1 = stmt1.executeQuery(sql.toString());
 		if(rs1.next()){
 			num_lor = rs1.getInt("num_lor");
 			sum_num_lor += num_lor;
 		}
 		rs1.close();
 		
 		num_m15 = 0;
 		sql.delete(0,sql.length());
 		sql.append(" select count(*) as num_m15 from lan:acscontr where d_close_law is not null and (d_close_law + 450) >= today and ( f_contr is null or f_contr = '' ) and i_company = '"+i_company+"' and i_project = '"+i_project+"' ");
		//System.out.println(sql.toString());
 		rs1 = stmt1.executeQuery(sql.toString());
 		if(rs1.next()){
 			num_m15 = rs1.getInt("num_m15");
 			sum_num_m15 += num_m15;
 		}
 		rs1.close();
 		
 		i_employ_m1 = "";
 		i_employ_m2 = "";
 		i_employ_m3 = "";
 		i_employ_s1 = "";
 		i_employ_s2 = "";
 		i_employ_s3 = "";
 		count_emp = 0;
 		
		sql.delete(0,sql.length());
 		sql.append(" select * from lan:serv_lstaff ")
			.append(" where  i_company = '"+i_company+"'  ")
			.append(" and i_project = '"+i_project+"' ")
			.append(" and i_zone = '01' ");
 		rs1 = stmt1.executeQuery(sql.toString());
 		if(rs1.next()){
			
			// Start Employ Response
			i_employ_m1 = doString.checkString(rs1.getString("i_employ_m1"),"");
	 		i_employ_m2 = doString.checkString(rs1.getString("i_employ_m2"),"");
	 		i_employ_m3 = doString.checkString(rs1.getString("i_employ_m3"),"");
	 		i_employ_s1 = doString.checkString(rs1.getString("i_employ_s1"),"");
	 		i_employ_s2 = doString.checkString(rs1.getString("i_employ_s2"),"");
	 		i_employ_s3 = doString.checkString(rs1.getString("i_employ_s3"),"");
	 		
	 		i_employ_m1 = getNEmploy(stmt2,i_employ_m1); 
	 		++count_emp;
	 		if(!"".equals(i_employ_m2)){
	 			i_employ_m1 = i_employ_m1 + " , " + getNEmploy(stmt2,i_employ_m2); 
	 			++count_emp;
	 		}
	 		if(!"".equals(i_employ_m3)){
	 			i_employ_m1 = i_employ_m1 + " , " + getNEmploy(stmt2,i_employ_m3); 
	 			++count_emp;
	 		}
	 		
	 		i_employ_s1 = getNEmploy(stmt2,i_employ_s1); 
	 		++count_emp;
	 		if(!"".equals(i_employ_s2)){
	 			i_employ_s1 = i_employ_s1 + " , " + getNEmploy(stmt2,i_employ_s2); 
	 			++count_emp;
	 		}
	 		if(!"".equals(i_employ_s3)){
	 			i_employ_s1 = i_employ_s1 + " , " + getNEmploy(stmt2,i_employ_s3); 
	 			++count_emp;
	 		}
			// End Employ Response
 		}
 		rs1.close();
 		
 		have_03 = "&nbsp;";
 		sql.delete(0,sql.length());
 		sql.append(" select i_type from lan:clearjob ")
 			.append(" where i_company = '"+i_company+"' ")
 			.append(" and i_project = '"+i_project+"' ")
 			.append(" and i_type = '03' ");
		rs1 = stmt1.executeQuery(sql.toString());
		if(rs1.next()){
			have_03 = "&nbsp;&nbsp;<span style=\"color:#0096ff;font-weight:bold;font-size:14px;\">*</span>";
		}
		rs1.close();
	}
	rs.close();
	
 	tableRow.delete(0,tableRow.length());
	tableRow.append("<tr>\n")
    .append("<td align=\"right\" class=\"item "+stlyeClass+"\"  style=\"border-left:1px solid rgb(135,185,247);text-align:center\" >"+count+"&nbsp;</td>\n")
    .append("<td align=\"center\" class=\""+stlyeClass+"\" style=\"border-left:1px solid rgb(135,185,247)\" >"+i_zone+"</td>\n")
    .append("<td class=\""+stlyeClass+" ; item ; \" style=\"color: rgb(255,100,0);\">"+doString.DisplayThai(i_employ_m1)+"&nbsp;</td>\n")
    .append("<td class=\""+stlyeClass+" ; \" style=\"color: rgb(255,100,0);\">"+doString.DisplayThai(i_employ_s1)+"&nbsp;</td>\n")
    .append("<td align=\"center\" class=\""+stlyeClass+" ; \">"+count_emp+"&nbsp;</td>\n")
    .append("<td >&nbsp;</td>\n")
    .append("<td class=\""+stlyeClass+" ; item\" style=\"border-left:1px solid rgb(135,185,247);color: rgb(255,100,0);\">"+i_company+i_project+ " - " +doString.DisplayThai(n_project)+have_03+"</td>\n")
    .append("<td align=\"right\" class=\""+stlyeClass+"\">"+doString.displayNumber("#,##0",num_total+0.0d)+"</td>\n")
    .append("<td align=\"right\" class=\""+stlyeClass+"\">"+doString.displayNumber("#,##0",num_lor+0.0d)+"</td>\n")
    .append("<td align=\"right\" class=\""+stlyeClass+" ; item\">"+doString.displayNumber("#,##0",num_m15+0.0d)+"</td>\n")
    .append("<td >&nbsp;</td>\n")
    .append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\""+stlyeClass+"\" style=\"border-left:1px solid rgb(135,185,247)\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',4.1)\" >"+status_notopen1+"</a></td>\n")
 	.append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\""+stlyeClassX+"\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',4.2)\" >"+status_notopen2x+"</a></td>\n")
 	.append("<td bgcolor=\"#E1F5FF\" class=\""+stlyeClass+"\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',4.2)\" >");;
	if( 0 == status_notopen2x &&  0 == status_notopen2){
		tableRow.append("&nbsp;");
	}else{
		tableRow.append("&nbsp;("+status_notopen2+")");
	}
  	tableRow.append("</a></td>\n")
 	.append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\""+stlyeClass+"\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',4.3)\" >"+pending_notopen+"</a></td>\n")
    .append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\""+stlyeClass+"\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',3.1)\" >"+status_open1+"</a></td>\n")
    .append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\""+stlyeClass+"\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',3.2)\" >"+status_open2+"</a></td>\n")
    .append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\""+stlyeClass+"\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',3.3)\" >"+pending_open+"</a></td>\n")
    .append("<td >&nbsp;</td>\n")
    .append("<td align=\"right\" bgcolor=\"#EBFFEB\" class=\""+stlyeClass+"\" style=\"border-left:1px solid rgb(135,185,247)\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',6.1)\" >"+status_starttask1+"</a></td>\n")
    .append("<td align=\"right\" bgcolor=\"#EBFFEB\" class=\""+stlyeClass+"\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',6.2)\" >"+status_starttask2+"</a></td>\n")
    .append("<td align=\"right\" bgcolor=\"#EBFFEB\" class=\""+stlyeClass+"\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',6.3)\" >"+pending_starttask+"</a></td>\n")
    .append("<td align=\"right\" bgcolor=\"#EBFFEB\" class=\""+stlyeClass+"\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',7.1)\" >"+doString.displayNumber("#,##0",status_complete+0.0d)+"</a></td>\n")
    .append("</tr>\n");
    out.println(tableRow.toString());
    out.flush();
%>
<%--
 <tr>
    <td align="right" class="item" style="border-left:1px solid rgb(135,185,247) ;">&nbsp;</td>
    <td align="center" class="dotlineREP" style="border-left:1px solid rgb(135,185,247)" >&nbsp;</td>
    <td class="dotlineREP ; item ; " style="color: rgb(255,100,0);">&nbsp;</td>
    <td class="dotlineREP ; " style="color: rgb(255,100,0);">&nbsp;</td>
    <td align="center" class="dotlineREP ; ">&nbsp;</td>
    <td >&nbsp;</td>
    <td class="dotlineREP ; item" style="border-left:1px solid rgb(135,185,247);color: rgb(255,100,0);">&nbsp;</td>
    <td align="right" class="dotlineREP"><b><%=doString.displayNumber("#,##0",sum_num_total+0.0d)%></b></td>
    <td align="right" class="dotlineREP"><b><%=doString.displayNumber("#,##0",sum_num_lor+0.0d)%></b></td>
    <td align="right" class="dotlineREP ; item"><b><%=doString.displayNumber("#,##0",sum_num_m15+0.0d)%></b></td>
    <td >&nbsp;</td>
    <td align="right" bgcolor="#E1F5FF" class="dotlineREP" style="border-left:1px solid rgb(135,185,247)"><b><%=doString.displayNumber("#,##0",sum_status_notopen1+0.0d)%></b></td>
    <td width="3%" align="right" bgcolor="#E1F5FF" class="dotline01" style="color: rgb(0,80,220)"><b><%=doString.displayNumber("#,##0",sum_status_notopen2x+0.0d)%></b></td>
    <td bgcolor="#E1F5FF" class="dotlineREP" style="color: rgb(0,80,220)"><b>
  		<% if( 0 == sum_status_notopen2x && 0 == sum_status_notopen2 ){ %>
  			&nbsp;
  		<% }else{ %>
  			&nbsp;(<%=doString.displayNumber("#,##0",sum_status_notopen2+0.0d)%>)
  		<% } %>
    </b></td>
    <td align="right" bgcolor="#E1F5FF" class="dotlineREP"><b><%=doString.displayNumber("#,##0",sum_pending_notopen+0.0d)%></b></td>
    <td align="right" bgcolor="#E1F5FF" class="dotlineREP"><b><%=doString.displayNumber("#,##0",sum_status_open1+0.0d)%></b></td>
    <td align="right" bgcolor="#E1F5FF" class="dotlineREP"><b><%=doString.displayNumber("#,##0",sum_status_open2+0.0d)%></b></td>
    <td align="right" bgcolor="#E1F5FF" class="dotlineREP"><b><%=doString.displayNumber("#,##0",sum_pending_open+0.0d)%></b></td>
    <td >&nbsp;</td>
    <td align="right" bgcolor="#EBFFEB" class="dotlineREP" style="border-left:1px solid rgb(135,185,247)"><b><%=doString.displayNumber("#,##0",sum_status_starttask1+0.0d)%></b></td>
    <td align="right" bgcolor="#EBFFEB" class="dotlineREP"><b><%=doString.displayNumber("#,##0",sum_status_starttask2+0.0d)%></b></td>
    <td align="right" bgcolor="#EBFFEB" class="dotlineREP"><b><%=doString.displayNumber("#,##0",sum_pending_starttask+0.0d)%></b></td>
    <td align="right" bgcolor="#EBFFEB" class="dotlineREP"><b><%=doString.displayNumber("#,##0",sum_status_complete+0.0d)%></b></td>
    
</tr>
--%>
 <tr>
    <td align="right" style="border-left:1px solid rgb(135,185,247)" class="item solidlineREP01">&nbsp;</td>
    <td align="center" class="solidlineREP01" style="border-left:1px solid rgb(135,185,247)" >&nbsp;</td>
    <td class="solidlineREP01 ; item ; " style="color: rgb(255,100,0);">&nbsp;</td>
    <td class="solidlineREP01 ; " style="color: rgb(255,100,0);">&nbsp;</td>
    <td align="center" class="solidlineREP01 ; ">&nbsp;</td>
    <td >&nbsp;</td>
    <td class="solidlineREP01 ; item" style="border-left:1px solid rgb(135,185,247);color: rgb(255,100,0);"><b>Total</b></td>
    <td align="right" class="solidlineREP01"><b><%=doString.displayNumber("#,##0",sum_num_total+0.0d)%></b></td>
    <td align="right" class="solidlineREP01"><b><%=doString.displayNumber("#,##0",sum_num_lor+0.0d)%></b></td>
    <td align="right" class="solidlineREP01 ; item"><b><%=doString.displayNumber("#,##0",sum_num_m15+0.0d)%></b></td>
    <td >&nbsp;</td>
    <td align="right" bgcolor="#E1F5FF" class="solidlineREP01" style="border-left:1px solid rgb(135,185,247)"><b><%=doString.displayNumber("#,##0",sum_status_notopen1+0.0d)%></b></td>
    <td align="right" bgcolor="#E1F5FF" class="solidlineREP03" style="color: rgb(0,80,220)"><b><%=doString.displayNumber("#,##0",sum_status_notopen2x+0.0d)%></b></td>
    <td bgcolor="#E1F5FF" class="solidlineREP01" ><b>
   		<% if( 0 == sum_status_notopen2x && 0 == sum_status_notopen2 ){ %>
   			&nbsp;
   		<% }else{ %>
   			&nbsp;(<%=doString.displayNumber("#,##0",sum_status_notopen2+0.0d)%>)
   		<% } %>
	</b></td>
    <td align="right" bgcolor="#E1F5FF" class="solidlineREP01"><b><%=doString.displayNumber("#,##0",sum_pending_notopen+0.0d)%></b></td>
    <td align="right" bgcolor="#E1F5FF" class="solidlineREP01"><b><%=doString.displayNumber("#,##0",sum_status_open1+0.0d)%></b></td>
    <td align="right" bgcolor="#E1F5FF" class="solidlineREP01"><b><%=doString.displayNumber("#,##0",sum_status_open2+0.0d)%></b></td>
    <td align="right" bgcolor="#E1F5FF" class="solidlineREP01"><b><%=doString.displayNumber("#,##0",sum_pending_open+0.0d)%></b></td>
    <td >&nbsp;</td>
    <td align="right" bgcolor="#EBFFEB" class="solidlineREP01" style="border-left:1px solid rgb(135,185,247)"><b><%=doString.displayNumber("#,##0",sum_status_starttask1+0.0d)%></b></td>
    <td align="right" bgcolor="#EBFFEB" class="solidlineREP01"><b><%=doString.displayNumber("#,##0",sum_status_starttask2+0.0d)%></b></td>
    <td align="right" bgcolor="#EBFFEB" class="solidlineREP01"><b><%=doString.displayNumber("#,##0",sum_pending_starttask+0.0d)%></b></td>
    <td align="right" bgcolor="#EBFFEB" class="solidlineREP01"><b><%=doString.displayNumber("#,##0",sum_status_complete+0.0d)%></b></td>
    
</tr>
</table>
<% } //end if go %>
</div> <!-- end division content table -->
<br/>
<% if("Y".equals(go) || !"".equals(i_zone_args)){ %>
<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
	<tr>
    	<td>&nbsp;&nbsp;&nbsp;<span style="color:rgb(50,100,200)" ><span style="color:#0096ff;">*</span>&nbsp;&nbsp;โครงการที่เป็น Turn Key</span></td>
    </tr>
    <tr>
    	<td>&nbsp;&nbsp;&nbsp;<span style="color:rgb(50,100,200)" ><span style="color:green;">*</span>&nbsp;&nbsp;ความหมายของ เลยกำหมด เช่น 6(14) คือ 6 - เลยกำหนดหลังจากวันนัดหมายบวก 2 วัน , 14 - เลยกำหนด ทั้งหมดจากวันปัจจุบัน</span></td>
    </tr>
    <tr>
    	<td>&nbsp;&nbsp;&nbsp;<span style="color:rgb(50,100,200)" ><span style="color:red;">*</span>&nbsp;&nbsp;update ข้อมูลหลัง 11 โมง ไม่รวมวิศวกรควบคุมงาน และ ธุรการ</span></td>
    </tr>
</TABLE>
<% } %>
</form>
</div>
</body>
</html>

<%		
		stmt.close();
		stmt1.close();
		stmt2.close();
		conn.close();
		stmt = null;
		stmt1 = null;
		stmt2 = null;
		rs = null;
		rs1 = null;
		rs2 = null;
		conn = null;
} catch (Exception e) {
	System.out.println("ERROR SERV_ReportService.jsp : " + e.getMessage()); 
	throw new ServletException(e.getMessage());
	
} finally {
	// Clean up.
	try {
		if (rs != null) rs.close();
		if (rs1 != null) rs1.close();
		if (rs2 != null) rs2.close();
		if (stmt != null) stmt.close();
		if (stmt1 != null) stmt1.close();
		if (stmt2 != null) stmt2.close();
		if (conn != null) conn.close();
		stmt = null;
		stmt1 = null;
		stmt2 = null;
		rs = null;
		rs1 = null;
		rs2 = null;
		conn = null;
	} catch (SQLException ignore) {
	}
}
%>
