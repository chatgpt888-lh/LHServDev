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
		if (rs.next()) {
			n_project = doString.checkString(rs.getString("n_project"), "");
		}
		rs.close();
		return n_project;
	}
	private String getNEmploy(Statement stmt, String i_employ) throws SQLException {
		String n_employ = "";
		ResultSet rs = stmt.executeQuery("select n_nemploy_th || ' ' || n_semploy_th as n_employ from docflow:acemploy where i_employ = '"+i_employ+"' ");
		if (rs.next()) {
			n_employ = doString.checkString(rs.getString("n_employ"), "");
		}
		rs.close();
		return n_employ;
	}
	private String getNVendor(Statement stmt, String i_vendor) throws SQLException {
		String n_vendor = "";
		ResultSet rs = stmt.executeQuery("select bus_name[1,30] as bus_name from lan:stpvendr where vend_code = '"+i_vendor+"' ");
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
	String have_finger = "";
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
	try {
		if(ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(false);
		stmt = conn.createStatement();
		stmt1 = conn.createStatement();
		stmt2 = conn.createStatement();

		i_company = doString.checkString(request.getParameter("i_company"), "");
		i_project = doString.checkString(request.getParameter("i_project"), "");
		col_order = doString.checkString(request.getParameter("col_order"), "i_zone");
		
%>
<html>
<head>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8">
<link rel="stylesheet" href="SERV_Report_Style.css" type="text/css">
<script src="js/device.js" type="text/javascript" ></script>
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
</style>
<script type="text/javascript" >
function initPage(){
	var form = document.frmSERV;
	if(device.mobile()){
		document.getElementById("mobile").innerHTML = 'Hello Mobile';
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
	form.action = '/LHServ/SERV_ReportServiceByZone.jsp';
	form.submit();
}
</script>
</head>

<body marginwidth="10" marginheight="10" leftmargin="10" topmargin="10" onload="initPage()">
<form name="frmSERV" method="POST" action="/LHServ/SERV_ReportServiceByZone.jsp"  >
<!-- input hidden -->
<input type="hidden" name="hide_one" value="Y" />
<input type="hidden" name="hide_two" value="Y" />
<input type="hidden" name="i_company" />
<input type="hidden" name="i_project" />
<input type="hidden" name="itmtype" />
<input type="hidden" name="col_order" />
<div id="content-table" >
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr height="22">
	<td id="td-header" colspan="7" class="bigh" >
	<img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp; สรุปรายงานซ่อมหลังโอน   ณ วันที่ <%=dd%>/<%=mm%>/<%=yy%></td>
	<td colspan="4" align="center" bgcolor="#E1F5FF" style="color:rgb(50,100,200) ; font-weight:bold ; font-size:10pt ; border-left:1px solid rgb(135,185,247) ; border-top:1px solid rgb(135,185,247) ; border-right:1px solid rgb(135,185,247)">Service<br/>Request</td>
    <td colspan="3" align="center" bgcolor="#E1F5FF" style="color:rgb(50,100,200) ; font-weight:bold ; font-size:10pt ; border-top:1px solid rgb(135,185,247) ; border-right:1px solid rgb(135,185,247)">Service<br/>Order</td>
	<td>&nbsp;</td>
    <td colspan="3" align="center" bgcolor="#E1F5FF" style="color:rgb(50,100,200) ; font-weight:bold ; font-size:10pt ; border-left:1px solid rgb(135,185,247) ; border-top:1px solid rgb(135,185,247) ; border-right:1px solid rgb(135,185,247)">Service<br/>WIP</td>    
	<td style="color:rgb(50,100,200) ;text-align:right;">v.4.0</td>                
  </tr>
  <tr>
    <td width="8%"  rowspan="2" class="col_nameREP"  style="border-left:1px solid rgb(135,185,247) ; border-top:1px solid rgb(135,185,247)"><a href="javascript:doOrder('i_zone')" >Zone</a></td>
    <td width="2px" rowspan="2" >&nbsp;</td>
    <td colspan="4" class="col_nameREP" style="border-left:1px solid rgb(135,185,247) ; border-top:1px solid rgb(135,185,247)">จำนวนบ้าน(หลัง)</td>
    <td width="2px" rowspan="2" >&nbsp;</td>
    <td colspan="4" class="col_nameREP" bgcolor="#E1F5FF" style="border-left:1px solid rgb(135,185,247) ; border-top:1px solid rgb(135,185,247)">Inform<br/>(วันที่นัดหมาย)</td>
    <td colspan="3" class="col_nameREP" bgcolor="#E1F5FF" style="border-top:1px solid rgb(135,185,247)">Open<br/>(วันที่นัดซ่อม)</td>    
    <td width="2px" rowspan="2" >&nbsp;</td>
    <td colspan="3" class="col_nameREP02" style="border-left:1px solid rgb(135,185,247) ; border-top:1px solid rgb(135,185,247)">Start Task<br/>(วันประมาณการเสร็จ)</td>
    <td width="6%"  rowspan="2" class="col_nameREP02" style="border-top:1px solid rgb(135,185,247)"><a href="javascript:doOrder('status_complete')" >Complete</a></td>
  </tr>
  <tr>
    <td width="8%" class="col_nameREP" style="border-left:1px solid rgb(135,185,247)">Sites</td>
    <td width="7%" class="col_nameREP">Total</td>
    <td width="7%" class="col_nameREP">โอนแล้ว</td>
    <td width="7%" class="col_nameREP">ประกัน(15M)</td>
    <td width="6%" class="col_nameREP" bgcolor="#E1F5FF" style="border-left:1px solid rgb(135,185,247)"><a href="javascript:doOrder('status_notopen1')" >ยังไม่เลยกำหนด</a></td>
    <td width="6%" colspan="2" class="col_nameREP" bgcolor="#E1F5FF"><a href="javascript:doOrder('status_notopen2')" >เลยกำหนด</a></td>
    <td width="6%" class="col_nameREP" bgcolor="#E1F5FF"><a href="javascript:doOrder('pending_notopen')" >Pending</a></td>
    <td width="6%" class="col_nameREP" bgcolor="#E1F5FF"><a href="javascript:doOrder('status_open1')" >ยังไม่เลยกำหนด</a></td>
    <td width="6%" class="col_nameREP" bgcolor="#E1F5FF" style="border-left:1px solid rgb(135,185,247)"><a href="javascript:doOrder('status_open2')" >เลยกำหนด</a></td>
    <td width="6%" class="col_nameREP" bgcolor="#E1F5FF"><a href="javascript:doOrder('pending_open')" >Pending</a></td>
    <td width="6%" class="col_nameREP02"  style="border-left:1px solid rgb(135,185,247)"><a href="javascript:doOrder('status_starttask1')" >ยังไม่เลยกำหนด</a></td>
    <td width="6%" class="col_nameREP02" ><a href="javascript:doOrder('status_starttask2')" >เลยกำหนด</a>
    <td width="8%" class="col_nameREP02" bgcolor="#E1F5FF"><a href="javascript:doOrder('pending_starttask')" >Pending</a></td>
    </td>
  </tr>
 <%
 String i_zone = "";
 String tmp_zone = "";
 String n_project = "";
 int status_starttask1 = 0;
 int status_starttask2 = 0;
 int status_open1 = 0;
 int status_open2 = 0;
 int status_notopen1 = 0;
 int status_notopen2 = 0;
 int status_notopen2x = 0;
 int status_complete = 0;
 int pending_open = 0;
 int pending_notopen = 0;
 int pending_starttask = 0;
 int count = 0;
 int site = 0;
 int sum_site = 0;
 
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
 
 int sum_notopen1 = 0;
 int sum_notopen2 = 0;
 int sum_notopen2x = 0;
 int sum_notopen3 = 0;
 int sum_open1 = 0;
 int sum_open2 = 0;
 int sum_open3 = 0;
 int sum_starttask1 = 0;
 int sum_starttask2 = 0;
 int sum_starttask3 = 0;
 int sum_complete = 0;
 
 String old_zone = "";
 String stlyeClass = "";

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

int check_user_all = 0;
sql.delete(0,sql.length());
sql.append(" select count(*) as total from lan:serv_pstaff where user_id = '"+user.getUserID()+"' and proj_id = 'ALL' ");
rs = stmt.executeQuery(sql.toString());
if(rs.next()){
	check_user_all = rs.getInt("total");
}
rs.close();

sql.delete(0,sql.length());
sql.append(" select distinct g.i_zone , count(nvl(g.i_project,'')) as site , ")
.append(" sum(nvl(status_starttask1,0)) as status_starttask1 ,  ")
.append(" sum(nvl(status_starttask2,0)) as status_starttask2 ,  ")
.append(" sum(nvl(status_open1,0))  as status_open1 ,  ")
.append(" sum(nvl(status_open2,0))  as status_open2 , ")
.append(" sum(nvl(status_notopen1,0)) as status_notopen1 ,  ")
.append(" sum(nvl(status_notopen2,0)) as status_notopen2 ,  ")
.append(" sum(nvl(status_notopen2x,0)) as status_notopen2x ,  ")
.append(" sum(nvl(status_complete,0)) as status_complete ,  ")
.append(" sum(nvl(pending_notopen,0)) as pending_notopen ,  ")
.append(" sum(nvl(pending_open,0)) as pending_open ,  ")
.append(" sum(nvl(pending_starttask,0)) as pending_starttask  ")
.append(" from ( ")
.append(" select distinct d.i_zone , a.i_company , a.i_project , b.n_project ")
.append(" from lan:acsbudgh a , lan:acxprojt b , lan:serv_pstaff c  , lan:serv_lstaff d ")
.append(" where 1=1 ")
.append(" and a.i_company = b.i_company ")
.append(" and a.i_project = b.i_project ")
.append(" and a.i_company = c.com_id ")
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
sql.append(" ) as g, OUTER ( ")
.append(" select count(distinct a.i_docno) as status_starttask1 , a.i_company , a.i_project  ")
.append(" from lan:serv_dochd a , lan:serv_docdt b  ") 
.append(" where 1=1  ")   
.append(" and a.c_desc <> 'Checkup Program' ") 
.append(" and a.i_doc_type = 'J'  ")   
.append(" and a.f_status = 'OPN'  ") 
.append(" and a.i_docno = b.i_docno ")
.append(" and b.f_itmstatus = '300'  ")
.append(" and (a.d_complete_max is null or a.d_complete_max = '') ")
.append(" and a.d_est_close >= today  ")  
.append(" and (a.f_pending <> 'STK' OR a.f_pending is null) ")
.append(" group by a.i_company , a.i_project ")
.append(" ) as a, OUTER ( ")
.append(" select count(distinct a.i_docno) as status_starttask2 , a.i_company , a.i_project ")
.append(" from lan:serv_dochd a , lan:serv_docdt b  ")                                       
.append(" where 1=1 ")                                                   
.append(" and a.c_desc <> 'Checkup Program' ")                                               
.append(" and a.i_doc_type = 'J'  ")
.append(" and a.f_status = 'OPN' ")
.append(" and a.i_docno = b.i_docno   ")
.append(" and b.f_itmstatus = '300' ")
.append(" and (a.d_complete_max is null or a.d_complete_max = '') ")
.append(" and a.d_est_close < today  ")
.append(" and (a.f_pending <> 'STK' OR a.f_pending is null) ")
.append(" group by a.i_company , a.i_project ")
.append(" ) as b, OUTER ( ")
.append(" select count(distinct a.i_docno) as status_open1 , a.i_company , a.i_project ")
.append(" from lan:serv_dochd a , lan:serv_docdt b ")
.append(" where 1=1 ")
.append(" and a.c_desc <> 'Checkup Program' ")
.append(" and a.i_doc_type = 'J' ")
.append(" and a.f_status = 'OPN' ")
.append(" and a.i_docno = b.i_docno ")
.append(" and b.f_itmstatus = '200' ")
.append(" and (a.d_complete_max is null or a.d_complete_max = '') ")
.append(" and a.d_appoint >= TODAY ")
.append(" and (a.f_pending <> 'OPN' OR a.f_pending is null) ")
.append(" group by a.i_company , a.i_project ")
.append(" ) as c1, OUTER ( ")
.append(" select count(distinct a.i_docno) as status_open2 , a.i_company , a.i_project ")
.append(" from lan:serv_dochd a , lan:serv_docdt b ")
.append(" where 1=1 ")
.append(" and a.c_desc <> 'Checkup Program' ")
.append(" and a.i_doc_type = 'J' ")
.append(" and a.f_status = 'OPN' ")
.append(" and a.i_docno = b.i_docno ")
.append(" and b.f_itmstatus = '200' ")
.append(" and (a.d_complete_max is null or a.d_complete_max = '') ")
.append(" and a.d_appoint < TODAY ")
.append(" and (a.f_pending <> 'OPN' OR a.f_pending is null) ")
.append(" group by a.i_company , a.i_project ")
.append(" ) as c2, OUTER( ")
.append(" SELECT COUNT(a.i_docno) AS status_notopen1 , a.i_company , a.i_project ")
.append(" FROM lan:serv_dochd a ")
.append(" WHERE 1=1 ")
.append(" AND a.c_desc <> 'Checkup Program' ")
.append(" AND a.i_doc_type = 'I' ")
.append(" AND a.f_status = 'OPN' ")
.append(" AND a.d_appoint_cust >= TODAY  ")
.append(" AND (a.f_pending <> 'INF' OR a.f_pending IS NULL)  ")
.append(" GROUP BY a.i_company , a.i_project   ")
.append(" ) as d1, OUTER ( ")
.append(" SELECT COUNT(a.i_docno) AS status_notopen2 , a.i_company , a.i_project ")
.append(" FROM lan:serv_dochd a ")
.append(" WHERE 1=1 ")
.append(" AND a.i_doc_type = 'I' ")
.append(" AND a.f_status = 'OPN' ")
.append(" AND a.d_appoint_cust < TODAY ")
.append(" AND a.c_desc <> 'Checkup Program' ")
.append(" AND (a.f_pending <> 'INF' ")
.append(" OR a.f_pending IS NULL) ")
.append(" GROUP BY a.i_company , a.i_project ")
.append(" ) as d2, OUTER( ")
.append(" SELECT COUNT(a.i_docno) AS status_notopen2x , a.i_company , a.i_project ")
.append(" FROM lan:serv_dochd a ")
.append(" WHERE 1=1 ")
.append(" AND a.i_doc_type = 'I' ")
.append(" AND a.f_status = 'OPN' ")
.append(" AND a.d_appoint_cust < (TODAY-2) ")
.append(" AND a.c_desc <> 'Checkup Program' ")
.append(" AND (a.f_pending <> 'INF' ")
.append(" OR a.f_pending IS NULL) ")
.append(" GROUP BY a.i_company , a.i_project ")
.append(" ) as d2x, OUTER( ")
.append(" select count(tab1.i_docno) as status_complete , tab1.i_company ,  ")
.append(" tab1.i_project  ")
.append(" from lan:serv_dochd as tab1 ")
.append(" where tab1.i_doc_type = 'J'   ")
.append(" and tab1.f_status <> 'CAN'     ")
.append(" and tab1.c_desc <> 'Checkup Program'   ")
.append(" and tab1.d_complete_max is not null   ")
.append(" and tab1.d_complete_max > '"+d_complete_max_begin+"'  ")
.append(" and tab1.d_complete_max <= '"+d_complete_max_end+"'  ")
.append(" group by tab1.i_company , tab1.i_project ")
.append(" ) as e , OUTER( ")
.append(" select i_company,i_project,count(distinct i_docno) as pending_notopen from serv_dochd ")
.append(" where i_doc_type = 'I' ")
.append(" and c_desc <> 'Checkup Program'  ")
.append(" and f_status = 'OPN' ")
.append(" and f_pending = 'INF' ")
.append(" group by 1,2 ) as h ,  OUTER( ")
.append(" select i_company,i_project,count(distinct a.i_docno) as pending_open from ")
.append("  lan:serv_dochd a , lan:serv_docdt b  ")
.append(" where i_doc_type = 'J' ")
.append(" and c_desc <> 'Checkup Program' ")
.append(" and f_status = 'OPN' ")
.append(" and a.i_docno = b.i_docno ")
.append(" and b.f_itmstatus = '200' ")
.append(" and (a.d_complete_max is null or a.d_complete_max = '') ")
.append(" and a.f_pending = 'OPN' ")
.append(" group by 1,2  ) as j ,  OUTER( ")
.append(" select a.i_company,a.i_project,count(distinct a.i_docno) as pending_starttask ")
.append(" from lan:serv_dochd a , lan:serv_docdt b  ")
.append(" where i_doc_type = 'J' ")
.append(" and c_desc <> 'Checkup Program' ")
.append(" and f_status = 'OPN' ")
.append(" and a.i_docno = b.i_docno ")
.append(" and b.f_itmstatus = '300'  ")
.append(" and (a.d_complete_max is null or a.d_complete_max = '')   ")
.append(" and a.f_pending = 'STK'  ")
.append(" group by 1,2 ) as k ")
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
.append(" and g.i_project= k.i_project ")
.append(" group by g.i_zone ");

if("i_zone".equals(col_order)){
	sql.append(" order by g.i_zone ");
}else if("status_open1".equals(col_order)){
	sql.append(" order by status_open1 desc , g.i_zone ");
}else if("status_open2".equals(col_order)){
	sql.append(" order by status_open2 desc , g.i_zone ");
}else if("status_notopen1".equals(col_order)){
	sql.append(" order by status_notopen1 desc , g.i_zone ");
}else if("status_notopen2".equals(col_order)){
	sql.append(" order by status_notopen2 desc , g.i_zone ");
}else if("status_starttask1".equals(col_order)){
	sql.append(" order by status_starttask1 desc , g.i_zone ");
}else if("status_starttask2".equals(col_order)){
	sql.append(" order by status_starttask2 desc , g.i_zone ");
}else if("status_complete".equals(col_order)){
	sql.append(" order by status_complete desc , g.i_zone ");
}else if("pending_open".equals(col_order)){
	sql.append(" order by pending_open desc , g.i_zone ");
}else if("pending_notopen".equals(col_order)){
	sql.append(" order by pending_notopen desc , g.i_zone ");
}else if("pending_starttask".equals(col_order)){
	sql.append(" order by pending_starttask desc , g.i_zone ");
}else{
	sql.append(" order by g.i_zone ");
}
 System.out.println(sql.toString());
 rs = stmt.executeQuery(sql.toString());
 while(rs.next()){
 		++count;
 		i_zone = doString.checkString(rs.getString("i_zone"),"0");
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
		site = rs.getInt("site");
		 
		sum_notopen1 += status_notopen1;
		sum_notopen2 += status_notopen2;
		sum_notopen2x += status_notopen2x;
		sum_notopen3 += pending_notopen;
		sum_open1 += status_open1;
		sum_open2 += status_open2;
		sum_open3 += pending_open;
		sum_starttask1 += status_starttask1;
		sum_starttask2 += status_starttask2;
		sum_starttask3 += pending_starttask;
		sum_complete += status_complete;
		sum_site += site;
		
		//ถ้า user all ให้หา zone จาก serv_lstaff 
		if(check_user_all != 0){
			num_total = 0;
	 		sql.delete(0,sql.length());
	 		sql.append(" select sum(i_lock) as num_total from ( ")
			.append(" select count(distinct d.i_lock ) as i_lock ")
			.append(" from lan:acsbudgh a , lan:acxprojt b , lan:acxslock d , lan:serv_lstaff e ")
			.append(" where 1=1 ")
			.append(" and a.i_company = b.i_company ")
			.append(" and a.i_project = b.i_project ")
			.append(" and a.i_company = d.i_company ")
			.append(" and a.i_project = d.i_project ")
			.append(" and a.i_company = e.i_company ")
			.append(" and a.i_project = e.i_project ")
			.append(" and e.i_zone = '"+i_zone+"' ")
			.append(" and a.d_year = '"+yy+"' ")
			.append(" and a.i_budg_type in (9) ")
			//.append(" and a.i_group not in ('10','11','12') ")
			.append(" and a.i_group not in ('10','12') ")
			.append(" group by e.i_zone , a.i_company , a.i_project ")
			.append(" ) where 1=1 ");
	 		rs1 = stmt1.executeQuery(sql.toString());
	 		if(rs1.next()){
	 			num_total = rs1.getInt("num_total");
	 		}
	 		rs1.close();
	 		
	 		num_lor = 0;
	 		sql.delete(0,sql.length());
	 		sql.append(" select sum(i_sort) as num_lor from ( ")
			.append(" select count(distinct d.i_sort ) as i_sort ")
			.append(" from lan:acsbudgh a , lan:acxprojt b , lan:serv_lstaff c , lan:acscontr d ")
			.append(" where 1=1 ")
			.append(" and a.i_company = b.i_company ")
			.append(" and a.i_project = b.i_project ")
			.append(" and a.i_company = c.i_company ")
			.append(" and a.i_project = c.i_project ")
			.append(" and a.i_company = d.i_company ")
			.append(" and a.i_project = d.i_project ")
			.append(" and c.i_zone = '"+i_zone+"' ")
			.append(" and d.d_close_law is not null ")
			.append(" and ( d.f_contr is null or d.f_contr = '' ) ")
			.append(" and a.d_year = '"+yy+"' ")
			.append(" and a.i_budg_type in (9) ")
			//.append(" and a.i_group not in ('10','11','12') ")
			.append(" and a.i_group not in ('10','12') ")
			.append(" group by c.i_zone , a.i_company , a.i_project ")
			.append(" ) where 1=1 ");
	 		rs1 = stmt1.executeQuery(sql.toString());
	 		if(rs1.next()){
	 			num_lor = rs1.getInt("num_lor");
	 		}
	 		rs1.close();
	 		
	 		num_m15 = 0;
	 		sql.delete(0,sql.length());
	 		sql.append(" select sum(i_sort) as num_m15 from ( ")
			.append(" select count(distinct d.i_sort ) as i_sort ")
			.append(" from lan:acsbudgh a , lan:acxprojt b , lan:serv_lstaff c , lan:acscontr d ")
			.append(" where 1=1 ")
			.append(" and a.i_company = b.i_company ")
			.append(" and a.i_project = b.i_project ")
			.append(" and a.i_company = c.i_company ")
			.append(" and a.i_project = c.i_project ")
			.append(" and a.i_company = d.i_company ")
			.append(" and a.i_project = d.i_project ")
			.append(" and c.i_zone = '"+i_zone+"' ")
			.append(" and (d.d_close_law + 450) >= today  ")
			.append(" and d.d_close_law is not null ")
			.append(" and ( d.f_contr is null or d.f_contr = '' ) ")
			.append(" and a.d_year = '"+yy+"' ")
			.append(" and a.i_budg_type in (9) ")
			//.append(" and a.i_group not in ('10','11','12') ")
			.append(" and a.i_group not in ('10','12') ")
			.append(" group by c.i_zone , a.i_company , a.i_project ")
			.append(" ) where 1=1 ");
	 		rs1 = stmt1.executeQuery(sql.toString());
	 		if(rs1.next()){
	 			num_m15 = rs1.getInt("num_m15");
	 		}
	 		rs1.close();
 		}else{
 			//ถ้า user ไม่ใช่ all ให้เอาโครงการมาหาจาก serv_pstaff และ i_zone จาก serv_lstaff
	 		num_total = 0;
	 		sql.delete(0,sql.length());
	 		sql.append(" select sum(i_lock) as num_total from ( ")
			.append(" select count(distinct d.i_lock ) as i_lock ")
			.append(" from lan:acsbudgh a , lan:acxprojt b , lan:serv_pstaff c , lan:acxslock d , lan:serv_lstaff e ")
			.append(" where 1=1 ")
			.append(" and a.i_company = b.i_company ")
			.append(" and a.i_project = b.i_project ")
			.append(" and a.i_company = c.com_id ")
			.append(" and a.i_project = c.proj_id ")
			.append(" and a.i_company = d.i_company ")
			.append(" and a.i_project = d.i_project ")
			.append(" and a.i_company = e.i_company ")
			.append(" and a.i_project = e.i_project ")
			.append(" and c.user_id = '"+user.getUserName()+"' ")
			.append(" and e.i_zone = '"+i_zone+"' ")
			.append(" and a.d_year = '"+yy+"' ")
			.append(" and a.i_budg_type in (9) ")
			//.append(" and a.i_group not in ('10','11','12') ")
			.append(" and a.i_group not in ('10','12') ")
			.append(" group by e.i_zone , a.i_company , a.i_project ")
			.append(" ) where 1=1 ");
	 		rs1 = stmt1.executeQuery(sql.toString());
	 		if(rs1.next()){
	 			num_total = rs1.getInt("num_total");
	 		}
	 		rs1.close();
	 		
	 		num_lor = 0;
	 		sql.delete(0,sql.length());
	 		sql.append(" select sum(i_sort) as num_lor from ( ")
			.append(" select count(distinct d.i_sort ) as i_sort ")
			.append(" from lan:acsbudgh a , lan:acxprojt b , lan:serv_pstaff c , lan:acscontr d , lan:serv_lstaff e ")
			.append(" where 1=1 ")
			.append(" and a.i_company = b.i_company ")
			.append(" and a.i_project = b.i_project ")
			.append(" and a.i_company = c.com_id ")
			.append(" and a.i_project = c.proj_id ")
			.append(" and a.i_company = d.i_company ")
			.append(" and a.i_project = d.i_project ")
			.append(" and a.i_company = e.i_company ")
			.append(" and a.i_project = e.i_project ")
			.append(" and e.i_zone = '"+i_zone+"' ")
			.append(" and c.user_id = '"+user.getUserName()+"' ")
			.append(" and d.d_close_law is not null ")
			.append(" and ( d.f_contr is null or d.f_contr = '' ) ")
			.append(" and a.d_year = '"+yy+"' ")
			.append(" and a.i_budg_type in (9) ")
			//.append(" and a.i_group not in ('10','11','12') ")
			.append(" and a.i_group not in ('10','12') ")
			.append(" group by e.i_zone , a.i_company , a.i_project ")
			.append(" ) where 1=1 ");
	 		rs1 = stmt1.executeQuery(sql.toString());
	 		if(rs1.next()){
	 			num_lor = rs1.getInt("num_lor");
	 		}
	 		rs1.close();
	 		
	 		num_m15 = 0;
	 		sql.delete(0,sql.length());
	 		sql.append(" select sum(i_sort) as num_m15 from ( ")
			.append(" select count(distinct d.i_sort ) as i_sort ")
			.append(" from lan:acsbudgh a , lan:acxprojt b , lan:serv_pstaff c , lan:acscontr d , lan:serv_lstaff e ")
			.append(" where 1=1 ")
			.append(" and a.i_company = b.i_company ")
			.append(" and a.i_project = b.i_project ")
			.append(" and a.i_company = c.com_id ")
			.append(" and a.i_project = c.proj_id ")
			.append(" and a.i_company = d.i_company ")
			.append(" and a.i_project = d.i_project ")
			.append(" and a.i_company = e.i_company ")
			.append(" and a.i_project = e.i_project ")
			.append(" and e.i_zone = '"+i_zone+"' ")
			.append(" and c.user_id = '"+user.getUserName()+"' ")
			.append(" and (d.d_close_law + 450) >= today  ")
			.append(" and d.d_close_law is not null ")
			.append(" and ( d.f_contr is null or d.f_contr = '' ) ")
			.append(" and a.d_year = '"+yy+"' ")
			.append(" and a.i_budg_type in (9) ")
			//.append(" and a.i_group not in ('10','11','12') ")
			.append(" and a.i_group not in ('10','12') ")
			.append(" group by e.i_zone , a.i_company , a.i_project ")
			.append(" ) where 1=1 ");
	 		rs1 = stmt1.executeQuery(sql.toString());
	 		if(rs1.next()){
	 			num_m15 = rs1.getInt("num_m15");
	 		}
	 		rs1.close();
	 		
	 		/*
	 		num_total = 0;
	 		sql.delete(0,sql.length());
	 		sql.append(" select count(*) as num_total from lan:acxslock a , lan:serv_pstaff b , lan:serv_lstaff c ")
	 			.append(" where a.i_company = b.com_id ")
	 			.append(" and a.i_project = b.proj_id ")
	 			.append(" and a.i_company = c.i_company ")
	 			.append(" and a.i_project = c.i_project ")
	 			.append(" and b.user_who = 'Z' ")
	 			.append(" and b.user_id = '"+user.getUserName()+"' ");
	 		rs1 = stmt1.executeQuery(sql.toString());
	 		if(rs1.next()){
	 			num_total = rs1.getInt("num_total");
	 		}
	 		rs1.close();
	 		
	 		num_lor = 0;
	 		sql.delete(0,sql.length());
	 		sql.append(" select count(*) as num_lor from lan:acscontr a , lan:serv_pstaff b ")
	 			.append(" where a.d_close_law is not null and ( a.f_contr is null or a.f_contr = '' ) ")
	 			.append(" and a.i_company = b.com_id and a.i_project = b.proj_id ")
	 			.append(" and b.user_id = '"+user.getUserName()+"' ");
	 		rs1 = stmt1.executeQuery(sql.toString());
	 		if(rs1.next()){
	 			num_lor = rs1.getInt("num_lor");
	 		}
	 		rs1.close();
	 		
	 		num_m15 = 0;
	 		sql.delete(0,sql.length());
	 		sql.append(" select count(*) as num_m15 from lan:acscontr a , lan:serv_pstaff b ")
	 			.append(" where a.d_close_law is not null and (a.d_close_law + 450) >= today and ( a.f_contr is null or a.f_contr = '' ) ")
	 			.append(" and a.i_company = b.com_id and a.i_project = b.proj_id ")
	 			.append(" and b.user_id = '"+user.getUserName()+"' ");
	 		rs1 = stmt1.executeQuery(sql.toString());
	 		if(rs1.next()){
	 			num_m15 = rs1.getInt("num_m15");
	 		}
	 		rs1.close();
	 		*/
 		}
 		
 		sum_num_total += num_total;
		sum_num_lor += num_lor;
		sum_num_m15 += num_m15;
		
		tableRow.delete(0,tableRow.length());
	 	tableRow.append("<tr>\n")
	    .append("<td align=\"center\" class=\"dotlineREP\" style=\"border-left:1px solid rgb(135,185,247)\" ><a href=\"/LHServ/SERV_ReportService.jsp?i_zone="+i_zone+"\" >Zone "+Integer.parseInt(i_zone)+"</a></td>\n")
	    .append("<td >&nbsp;</td>\n")
	    .append("<td align=\"right\" class=\"dotlineREP\" style=\"border-left:1px solid rgb(135,185,247)\" >"+doString.displayNumber("#,##0",site+0.0d)+"</td>\n")
	    .append("<td align=\"right\" class=\"dotlineREP\">"+doString.displayNumber("#,##0",num_total+0.0d)+"</td>\n")
	    .append("<td align=\"right\" class=\"dotlineREP\">"+doString.displayNumber("#,##0",num_lor+0.0d)+"</td>\n")
	    .append("<td align=\"right\" class=\"dotlineREP ; item\">"+doString.displayNumber("#,##0",num_m15+0.0d)+"</td>\n")
	    .append("<td >&nbsp;</td>\n")
	    .append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\"dotlineREP\" style=\"border-left:1px solid rgb(135,185,247)\">"+status_notopen1+"</td>\n")
	    .append("<td width=\"4%\" align=\"right\" bgcolor=\"#E1F5FF\" class=\"dotline01\" style=\"color: rgb(0,80,220)\" >"+status_notopen2x+"</td>\n")
	    .append("<td bgcolor=\"#E1F5FF\" class=\"dotlineREP\">");
	    if( 0 == status_notopen2x &&  0 == status_notopen2){
			tableRow.append("&nbsp;");
		}else{
			tableRow.append("&nbsp;("+status_notopen2+")");
		}
	    tableRow.append("</td>\n")
	    .append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\"dotlineREP\">"+pending_notopen+"</td>\n")
	    .append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\"dotlineREP\">"+status_open1+"</td>\n")
	    .append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\"dotlineREP\">"+status_open2+"</td>\n")
	    .append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\"dotlineREP\">"+pending_open+"</td>\n")
	    .append("<td >&nbsp;</td>\n")
	    .append("<td align=\"right\" bgcolor=\"#EBFFEB\" class=\"dotlineREP\" style=\"border-left:1px solid rgb(135,185,247)\">"+status_starttask1+"</td>\n")
	    .append("<td align=\"right\" bgcolor=\"#EBFFEB\" class=\"dotlineREP\">"+status_starttask2+"</td>\n")
	    .append("<td align=\"right\" bgcolor=\"#EBFFEB\" class=\"dotlineREP\">"+pending_starttask+"</td>\n")
	    .append("<td align=\"right\" bgcolor=\"#EBFFEB\" class=\"dotlineREP\">"+doString.displayNumber("#,##0",status_complete+0.0d)+"</td>\n")
	    .append("</tr>\n");
	   	out.println(tableRow.toString());
 }
 rs.close();
 tableRow.delete(0,tableRow.length());
tableRow.append("<tr style=\"font-weight:bold\">\n")
  .append("<td align=\"center\" class=\"dotlineREP\" style=\"border-left:1px solid rgb(135,185,247)\" ><a href=\"/LHServ/SERV_ReportService.jsp\" >ALL</a></td>\n")
  .append("<td >&nbsp;</td>\n")
  .append("<td align=\"right\" class=\"dotlineREP\" style=\"border-left:1px solid rgb(135,185,247)\" >"+doString.displayNumber("#,##0",sum_site+0.0d)+"</td>\n")
  .append("<td align=\"right\" class=\"dotlineREP\">"+doString.displayNumber("#,##0",sum_num_total+0.0d)+"</td>\n")
  .append("<td align=\"right\" class=\"dotlineREP\">"+doString.displayNumber("#,##0",sum_num_lor+0.0d)+"</td>\n")
  .append("<td align=\"right\" class=\"dotlineREP ; item\">"+doString.displayNumber("#,##0",sum_num_m15+0.0d)+"</td>\n")
  .append("<td >&nbsp;</td>\n")
  .append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\"dotlineREP\" style=\"border-left:1px solid rgb(135,185,247)\">"+doString.displayNumber("#,##0",sum_notopen1+0.0d)+"</td>\n")
  .append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\"dotline01\" style=\"color: rgb(0,80,220)\" >" + sum_notopen2x + "</td>")
  .append("<td bgcolor=\"#E1F5FF\" class=\"dotlineREP\">");
	if( 0 == sum_notopen2x &&  0 == sum_notopen2){
		tableRow.append("&nbsp;");
	}else{
		tableRow.append("&nbsp;("+sum_notopen2+")");
	}
  tableRow.append("</td>\n")
  .append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\"dotlineREP\">"+doString.displayNumber("#,##0",sum_notopen3+0.0d)+"</td>\n")
  .append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\"dotlineREP\">"+doString.displayNumber("#,##0",sum_open1+0.0d)+"</td>\n")
  .append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\"dotlineREP\">"+doString.displayNumber("#,##0",sum_open2+0.0d)+"</td>\n")
  .append("<td align=\"right\" bgcolor=\"#E1F5FF\" class=\"dotlineREP\">"+doString.displayNumber("#,##0",sum_open3+0.0d)+"</td>\n")
  .append("<td >&nbsp;</td>\n")
  .append("<td align=\"right\" bgcolor=\"#EBFFEB\" class=\"dotlineREP\" style=\"border-left:1px solid rgb(135,185,247)\">"+doString.displayNumber("#,##0",sum_starttask1+0.0d)+"</td>\n")
  .append("<td align=\"right\" bgcolor=\"#EBFFEB\" class=\"dotlineREP\">"+doString.displayNumber("#,##0",sum_starttask2+0.0d)+"</td>\n")
  .append("<td align=\"right\" bgcolor=\"#EBFFEB\" class=\"dotlineREP\">"+doString.displayNumber("#,##0",sum_starttask3+0.0d)+"</td>\n")
  .append("<td align=\"right\" bgcolor=\"#EBFFEB\" class=\"dotlineREP\">"+doString.displayNumber("#,##0",sum_complete+0.0d)+"</td>\n")
  .append("</tr>\n");
 out.println(tableRow.toString());
%>
<tr>
    <td align="right" class="solidlineREP01" style="border-left:1px solid rgb(135,185,247);">&nbsp;</td>
    <td >&nbsp;</td>
    <td class="solidlineREP01 ; item" style="border-left:1px solid rgb(135,185,247);color: rgb(255,100,0);">&nbsp;</td>
    <td align="right" class="solidlineREP01">&nbsp;</td>
    <td align="right" class="solidlineREP01">&nbsp;</td>
    <td align="right" class="solidlineREP01 ; item">&nbsp;</td>
    <td >&nbsp;</td>
    <td align="right" bgcolor="#E1F5FF" class="solidlineREP01" style="border-left:1px solid rgb(135,185,247)">&nbsp;</td>
    <td align="right" bgcolor="#E1F5FF" class="solidlineREP03">&nbsp;</td>
    <td align="right" bgcolor="#E1F5FF" class="solidlineREP01">&nbsp;</td>
    <td align="right" bgcolor="#E1F5FF" class="solidlineREP01">&nbsp;</td>
    <td align="right" bgcolor="#E1F5FF" class="solidlineREP01">&nbsp;</td>
    <td align="right" bgcolor="#E1F5FF" class="solidlineREP01">&nbsp;</td>
    <td align="right" bgcolor="#E1F5FF" class="solidlineREP01">&nbsp;</td>
    <td >&nbsp;</td>
    <td align="right" bgcolor="#EBFFEB" class="solidlineREP01" style="border-left:1px solid rgb(135,185,247)">&nbsp;</td>
    <td align="right" bgcolor="#EBFFEB" class="solidlineREP01">&nbsp;</td>
    <td align="right" bgcolor="#EBFFEB" class="solidlineREP01">&nbsp;</td>
    <td align="right" bgcolor="#EBFFEB" class="solidlineREP01">&nbsp;</td>
  </tr>
</table>
</div> <!-- end division content table -->
<br style="font-size:30pt">
<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
  <tr><td width="100%" class="copyright" align="center">
  Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5  
  <br>ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;
  หรือ โทร. 0-2230-8279 (คุณประพัฒน์
  ฝ่ายบริการ)&nbsp; 0-2230-8491-5 (ฝ่าย IT)  
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE> 
</form>
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
	System.out.println("ERROR SERV_ReportServiceByZone.jsp SQL : " + sql.toString()); 
	System.out.println("ERROR SERV_ReportServiceByZone.jsp : " + e.getMessage()); 
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
