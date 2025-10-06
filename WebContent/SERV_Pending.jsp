<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%!
 	private String getNProject(Statement stmt, String i_company,String i_project) throws SQLException {
		String n_project = "";
		ResultSet rs = stmt.executeQuery("select n_project from lan:acxprojt where i_company = '"+ i_company + "' and i_project = '" + i_project + "' ");
		if (rs.next()){
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
	
	private String thaiToDB(String thDate) {
		return (Integer.parseInt(thDate.substring(6, 10)) - 543) + "-"
				+ thDate.substring(3, 5) + "-" + thDate.substring(0, 2);
	}
	
	private int getDocCode(Statement stmt, String i_docno )  throws SQLException {
		int status = 0;
		ResultSet rs = stmt.executeQuery("select  nvl(max(f_itmstatus),0) as max_itmstatus from lan:serv_flow where i_docno = '"+i_docno+"' ");
		if (rs.next()) {
			status = rs.getInt("max_itmstatus");
		}
		rs.close();
		return status;
	}
	
	private String getStartTask(Statement stmt, String i_docno )  throws SQLException {
		int count_vendor = 0;
		int count_itmstatus = 0;
		ResultSet rs = stmt.executeQuery("select  count(distinct i_vendor) as count_vendor from lan:serv_flow where i_docno = '"+i_docno+"' ");
		if (rs.next()) {
			count_vendor = rs.getInt("count_vendor");
		}
		rs.close();
		rs = stmt.executeQuery("select  count( distinct f_itmstatus) as count_itmstatus from lan:serv_flow where i_docno = '"+i_docno+"' and f_itmstatus = '200' ");
		if (rs.next()) {
			count_itmstatus = rs.getInt("count_itmstatus");
		}
		rs.close();
		rs = null;
		if(count_vendor == count_itmstatus){
			return "<img src=\"/LHServ/images/i_pass2.gif\" border=\"0\" align=\"absmiddle\" />&nbsp;Y";
		}else{
			return "<img src=\"/LHServ/images/i_pass_no2.gif\" border=\"0\" align=\"absmiddle\" />&nbsp;N";
		}
	}
	
	private String getStatus(Statement stmt, String i_docno , String itmtype) throws SQLException{
		int status = getDocCode(stmt,i_docno);
		switch(status){
			case 100 : return "Open Job";
			case 200 : return "Start Task";
			case 300 : return "Complete Task";
			case 400 : return "Vendor Approve";
			case 500 : return "Staff Comfirm";
			case 600 : return "Service Manager Approve";
			case 700 : return "Manager Approve";
			case 800 : return "VP Approve";
			default : return "Inform Job";
		}
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
	String d_keyin_beg = "";
	String d_keyin_end = "";
	String itmtype = "";
	String status_itm = "";
	
	String hide_detail = "";

	int count = 0;
	String sort_col = "default";
	
	String n_itmno = "";
	
    String i_docno = "";
    String mode = "";
    
	String c_desc_pending = "";
	String i_pending_type = "";
	String d_pending = ((dd < 10 ? "0" + dd : ""+ dd)+ "/" + (mm < 10 ? "0" + mm : "" + mm) + "/" + yy);
	int i_seq = 1;
	String from_page = "";
	try {
		if (ds == null)
			getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();
		stmt1 = conn.createStatement();
		stmt2 = conn.createStatement();

		i_company = doString.checkString(request.getParameter("i_company"), "");
		i_project = doString.checkString(request.getParameter("i_project"), "");
		itmtype = doString.checkString(request.getParameter("itmtype"),"");
		sort_col = doString.checkString(request.getParameter("sort_col"), "default");
		mode =  doString.checkString(request.getParameter("mode"), "");
		hide_detail = doString.checkString(request.getParameter("hide_detail"),"Y");
		
		
		c_desc_pending = doString.checkString(request.getParameter("c_desc_pending"),"");
		i_pending_type = doString.checkString(request.getParameter("i_pending_type"),"");
		d_pending = doString.checkString(request.getParameter("d_pending"),((dd < 10 ? "0" + dd : ""+ dd)+ "/" + (mm < 10 ? "0" + mm : "" + mm) + "/" + yy));
		i_seq =  Integer.parseInt(doString.checkString(request.getParameter("i_seq"),"1"));
		from_page = doString.checkString(request.getParameter("from_page"),"");
		i_docno = doString.checkString(request.getParameter("i_docno"),"");
		
		if ("3.1".equals(itmtype)) {
			status_itm = "Open - ยังไม่ถึงวันนัดหมาย";
		}
		if ("3.2".equals(itmtype)){
			status_itm = "Open - เลยวันนัดหมายแล้ว";
		}
		if ("3.3".equals(itmtype)){
			status_itm = "Open - เลยวันนัดหมายแล้ว";
		}
		if ("4.1".equals(itmtype)) {
			status_itm = "ไม่ Open - ยังไม่ถึงวันนัดหมาย";
		}
		if ("4.2".equals(itmtype)) {
			status_itm = "ไม่ Open - เลยวันนัดหมายแล้ว";
		}
		if ("4.3".equals(itmtype)) {
			status_itm = "ไม่ Open - เลยวันนัดหมายแล้ว";
		}
		if ("6.1".equals(itmtype)) {
			status_itm = "Start Task - ยังไม่ถึงวันนัดหมาย";
		}
		if ("6.2".equals(itmtype)) {
			status_itm = "Start Task - เลยวันนัดหมายแล้ว";
		}
		if ("6.3".equals(itmtype)) {
			status_itm = "Start Task - เลยวันนัดหมายแล้ว";
		}
%>
<HTML>
<HEAD>
<TITLE>Pending</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<style type="text/css">
.hidden-class { display: none; }
.show-class { display: inline; }
</style>

<script language="javascript">
<!--
function initPage(){
	if(document.frmSERV.hide_detail.value == 'N') {
		showDetail();
	}
	if(document.frmSERV.hide_detail.value == 'Y'){
		hideDetail();
	}
}
function gotoOpenJob(i_docno){
	var form = document.frmSERV;
	form.i_docno.value = i_docno;
	form.edit.value = 'no';
	form.action = '/LHServ/SERV_OpenJob_Follow.jsp';
	form.submit();
}
function sortBy(theCol){
	var form = document.frmSERV;
	form.sort_col.value = theCol;
	form.submit();
}
function showDetail(){
	var elements = getElementsByClass('hidden-class');
	for (i = 0 ; i < elements.length ; i++ ) {
	    elements[i].className = 'show-class';
	}
	document.frmSERV.hide_detail.value = 'N';
}
function hideDetail(){
	var elements = getElementsByClass('show-class');
	for (i = 0 ; i < elements.length ; i++ ) {
	    elements[i].className = 'hidden-class';
	}
	document.frmSERV.hide_detail.value = 'Y';
}  
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
function doAction(theParam){
	var form = document.frmSERV;
	form.mode.value = theParam;
	if(theParam != 'cancel' &&  theParam != 'edit'){
		if(form.c_desc_pending.value == '') {
			alert('กรุณาระบุ หมายเหตุ');
			return;
		}
		if(form.d_pending.value == '') {
			alert('กรุณาระบุ วันที่คาดว่าจะเลื่อนไป');
			return;
		}
	}
	if(theParam == 'preview' || theParam == 'edit'){
		form.action = '/LHServ/SERV_Pending.jsp';
	}else{
		form.action = '/LHServ/SERV_PendingServlet';
	}
	form.submit();
}
//-->
</script>


<base target="_self">


</HEAD>
 
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onLoad="initPage()">
 

<FORM method="POST" action="SERV_Pending.jsp" name="frmSERV" >
<input type="hidden" name="edit" value="" />
<input type="hidden" name="sort_col" value="<%=sort_col%>" />
<input type="hidden" name="i_company" value="<%=i_company%>" />
<input type="hidden" name="i_project" value="<%=i_project%>" />
<input type="hidden" name="itmtype" value="<%=itmtype%>" />
<input type="hidden" name="mode" value="<%=mode%>" /> 
<input type="hidden" name="hide_detail" value="Y" />
<input type="hidden" name="from_page" value="<%=from_page%>" />
<input type="hidden" name="i_docno" value="<%=i_docno%>" />
 
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center" class="BD">
    
 
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            Pending</td>
          <td width="30%" align="right">&nbsp;
	
          </td>
        </tr>
      </table>
 
 
<br style="font-size:10pt">
                
 
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
    <td height="22" class="item ; dotline01" width="80%">โครงการ : &nbsp; <%=i_company + i_project%> - <%=doString.DisplayThai(getNProject(stmt, i_company,i_project))%>
    &nbsp;</td>
    <td  height="22" class="item ; dotline01" align="right" width="20%">
    	v.3.0
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
                <td class="item_tab2" width="300">รายละเอียดการ Pending</td>
                <td class="item_tab3"></td>
                <td >&nbsp;</td>
              </tr>
            </table>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td valign="bottom" class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
    <td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>
 
 
<table border="0" width="100%" cellspacing="0" cellpadding="0">
 
 
 
  <tr>
    <td width="100%" class="frmL" align="center">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
	<td width="5%" class="col_name">No.</td>
	<td width="8%" class="col_name"><a href="javascript:sortBy('i_lock')" >แปลง</a></td>
	<td width="12%" class="col_name"><a href="javascript:sortBy('i_docno')" >เลขที่เอกสาร</a></td>
	<td width="10%" class="col_name">บ้านเลขที่</td>
    <td width="20%" class="col_name">ชื่อผู้แจ้ง / ลูกค้า</td>
    <td class="col_name"><a href="javascript:sortBy('i_date')" >วันที่แจ้งซ่อม</a></td>
    <% if("3.1".equals(itmtype) || "3.2".equals(itmtype) || "3.3".equals(itmtype)){ %>
    	<td class="col_name"><a href="javascript:sortBy('d_appoint')" >วันนัดซ่อม</a></td>
    <% } %>
    <% if("6.1".equals(itmtype) || "6.2".equals(itmtype) || "6.3".equals(itmtype)){ %>
    	<td class="col_name"><a href="javascript:sortBy('d_appoint')" >วันประมาณการเสร็จ</a></td>
    <% } %>
    <% if ("4.1".equals(itmtype) || "4.2".equals(itmtype) || "4.3".equals(itmtype)) {  %>
    	<td class="col_name"><a href="javascript:sortBy('d_appoint')" >วันที่นัดหมายลูกค้า</a></td>
    <% } %>
    <td class="col_name"><a href="javascript:sortBy('count_date')" >ระยะเวลาดำเนินการ<span style="color:red" >*</span></a></td>
    <% if("3.1".equals(itmtype) || "3.2".equals(itmtype) || "3.3".equals(itmtype) || "6.1".equals(itmtype) || "6.2".equals(itmtype) || "6.3".equals(itmtype)){ %>
	<td class="col_name">Start Task</td>
	<% } %>
	<td class="col_name">ผู้รับผิดชอบ</td>
	<% if ("4.1".equals(itmtype) || "4.2".equals(itmtype) || "4.3".equals(itmtype)) {  %>
	<td class="col_name"><a href="javascript:sortBy('d_print_inform')" >พิมพ์ Inform Job</a></td>
	<% } %>
    </tr>
<%
		sql.delete(0, sql.length());
		sql.append(" select * from ( ");
		if ("3.1".equals(itmtype)) {
		sql.append(" ( ")
			.append(" select distinct a.i_company , a.i_project , a.i_lock , a.i_docno , date(a.d_keyin) as i_date ,  ")
			.append(" b.n_customer , c.i_house , a.d_appoint , a.count_hddate ")
			.append(" from ( ")
			.append(" select a.i_docno , a.i_lock , a.d_keyin , a.i_company , a.i_project , a.d_appoint ")
			.append(" , CASE WHEN (today - date(a.d_appoint))  > 0  THEN (today - date(a.d_appoint)) ELSE 0 END as count_hddate ")
			.append(" from lan:serv_dochd a , lan:serv_docdt b ")
			.append(" where 1=1 ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and a.c_desc <> 'Checkup Program' ")
			.append(" and a.i_doc_type = 'J' ")
			.append(" and a.f_status = 'OPN' ")
			.append(" and a.i_docno = b.i_docno ")
			.append(" and b.f_itmstatus = '200' ")
			.append(" and (a.d_complete_max is null or d_complete_max = '') ")
			.append(" and a.d_appoint >= today ")
			.append(" and (a.i_system = 'ESV' OR a.i_system is null ) ")
			.append(" ) as a , ( ")
			.append(" select a.i_company , a.i_project , a.i_sort as i_lock , ")
			.append(" n_prename || ' ' || n_ncustomer || ' ' || n_scustomer as n_customer ")
			.append(" from lan:acscontr a , lan:acxcusto b ")
			.append(" where 1=1 ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and a.f_contr is null ")
			.append(" and b.i_customer = nvl(a.i_cus_intent1,a.i_exp_intent1) ")
			.append(" ) as b , lan:acxlckmd as c ")
			.append(" where 1=1 ")
			.append(" and a.i_company = b.i_company ")
			.append(" and a.i_project = b.i_project ")
			.append(" and a.i_company = c.i_company ")
			.append(" and a.i_project = c.i_project ")
			.append(" and a.i_lock = b.i_lock ")
			.append(" and a.i_lock = c.i_lock ")
			.append(" ) union ( ")
			.append(" select distinct a.i_company , a.i_project , a.i_lock , b.i_docno , a.i_date ,  ")
			.append(" a.n_customer , a.i_house , c.d_appoint , ")
			.append(" CASE WHEN (today - date(c.d_appoint))  > 0  THEN (today - date(c.d_appoint)) ELSE 0 END as count_hddate  ")
			.append(" from lan:svc_dochd a , lan:svc_docdt b , lan:serv_dochd c , lan:serv_docdt d ")
			.append(" where a.i_svc_docno  = b.i_svc_docno ")
			.append(" and b.i_docno = c.i_docno ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and c.i_doc_type = 'J' ")
			.append(" and c.f_status = 'OPN' ")
			.append(" and c.i_docno = d.i_docno ")
			.append(" and d.f_itmstatus = '200' ")
			.append(" and (c.d_complete_max is null or c.d_complete_max = '') ")
			.append(" and c.d_appoint >= today ")
			.append(" and c.c_desc <> 'Checkup Program' ")
			.append(" and c.i_system = 'SVC' ")
			.append(" ) ");
		}
		if ("3.2".equals(itmtype)) {
		sql.append(" ( ")
			.append(" select distinct a.i_company , a.i_project , a.i_lock , a.i_docno , date(a.d_keyin) as i_date ,  ")
			.append(" b.n_customer , c.i_house , a.d_appoint , a.count_hddate ")
			.append(" from ( ")
			.append(" select a.i_docno , a.i_lock , a.d_keyin , a.i_company , a.i_project , a.d_appoint ")
			.append(" , CASE WHEN (today - date(a.d_appoint))  > 0  THEN (today - date(a.d_appoint)) ELSE 0 END as count_hddate ")
			.append(" from lan:serv_dochd a , lan:serv_docdt b ")
			.append(" where 1=1 ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and a.c_desc <> 'Checkup Program' ")
			.append(" and a.i_doc_type = 'J' ")
			.append(" and a.f_status = 'OPN' ")
			.append(" and a.i_docno = b.i_docno ")
			.append(" and b.f_itmstatus = '200' ")
			.append(" and (a.d_complete_max is null or d_complete_max = '') ")
			.append(" and a.d_appoint < today ")
			.append(" and (a.i_system = 'ESV' OR a.i_system is null ) ")
			.append(" ) as a , ( ")
			.append(" select a.i_company , a.i_project , a.i_sort as i_lock , ")
			.append(" n_prename || ' ' || n_ncustomer || ' ' || n_scustomer as n_customer ")
			.append(" from lan:acscontr a , lan:acxcusto b ")
			.append(" where 1=1 ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and a.f_contr is null ")
			.append(" and b.i_customer = nvl(a.i_cus_intent1,a.i_exp_intent1) ")
			.append(" ) as b , lan:acxlckmd as c ")
			.append(" where 1=1 ")
			.append(" and a.i_company = b.i_company ")
			.append(" and a.i_project = b.i_project ")
			.append(" and a.i_company = c.i_company ")
			.append(" and a.i_project = c.i_project ")
			.append(" and a.i_lock = b.i_lock ")
			.append(" and a.i_lock = c.i_lock ")
			.append(" ) union ( ")
			.append(" select distinct a.i_company , a.i_project , a.i_lock , b.i_docno , a.i_date ,  ")
			.append(" a.n_customer , a.i_house , c.d_appoint , ")
			.append(" CASE WHEN (today - date(c.d_appoint))  > 0  THEN (today - date(c.d_appoint)) ELSE 0 END as count_hddate  ")
			.append(" from lan:svc_dochd a , lan:svc_docdt b , lan:serv_dochd c , lan:serv_docdt d ")
			.append(" where a.i_svc_docno  = b.i_svc_docno ")
			.append(" and b.i_docno = c.i_docno ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and c.i_doc_type = 'J' ")
			.append(" and c.f_status = 'OPN' ")
			.append(" and c.i_docno = d.i_docno ")
			.append(" and d.f_itmstatus = '200' ")
			.append(" and (c.d_complete_max is null or c.d_complete_max = '') ")
			.append(" and c.d_appoint < today ")
			.append(" and c.c_desc <> 'Checkup Program' ")
			.append(" and c.i_system = 'SVC' ")
			.append(" ) ");
		}
		if ("3.3".equals(itmtype)) {
		sql.append(" ( ")
			.append(" select distinct a.i_company , a.i_project , a.i_lock , a.i_docno , date(a.d_keyin) as i_date ,  ")
			.append(" b.n_customer , c.i_house , a.d_appoint , a.count_hddate ")
			.append(" from ( ")
			.append(" select a.i_docno , a.i_lock , a.d_keyin , a.i_company , a.i_project , a.d_appoint ")
			.append(" , CASE WHEN (today - date(a.d_appoint))  > 0  THEN (today - date(a.d_appoint)) ELSE 0 END as count_hddate ")
			.append(" from lan:serv_dochd a , lan:serv_docdt b ")
			.append(" where 1=1 ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and a.c_desc <> 'Checkup Program' ")
			.append(" and a.i_doc_type = 'J' ")
			.append(" and a.f_status = 'OPN' ")
			.append(" and a.i_docno = b.i_docno ")
			.append(" and b.f_itmstatus = '200' ")
			.append(" and (a.d_complete_max is null or d_complete_max = '') ")
			.append(" and (a.i_system = 'ESV' OR a.i_system is null ) ")
			.append(" ) as a , ( ")
			.append(" select a.i_company , a.i_project , a.i_sort as i_lock , ")
			.append(" n_prename || ' ' || n_ncustomer || ' ' || n_scustomer as n_customer ")
			.append(" from lan:acscontr a , lan:acxcusto b ")
			.append(" where 1=1 ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and a.f_contr is null ")
			.append(" and b.i_customer = nvl(a.i_cus_intent1,a.i_exp_intent1) ")
			.append(" ) as b , lan:acxlckmd as c ")
			.append(" where 1=1 ")
			.append(" and a.i_company = b.i_company ")
			.append(" and a.i_project = b.i_project ")
			.append(" and a.i_company = c.i_company ")
			.append(" and a.i_project = c.i_project ")
			.append(" and a.i_lock = b.i_lock ")
			.append(" and a.i_lock = c.i_lock ")
			.append(" ) union ( ")
			.append(" select distinct a.i_company , a.i_project , a.i_lock , b.i_docno , a.i_date ,  ")
			.append(" a.n_customer , a.i_house , c.d_appoint , ")
			.append(" CASE WHEN (today - date(c.d_appoint))  > 0  THEN (today - date(c.d_appoint)) ELSE 0 END as count_hddate  ")
			.append(" from lan:svc_dochd a , lan:svc_docdt b , lan:serv_dochd c , lan:serv_docdt d ")
			.append(" where a.i_svc_docno  = b.i_svc_docno ")
			.append(" and b.i_docno = c.i_docno ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and c.i_doc_type = 'J' ")
			.append(" and c.f_status = 'OPN' ")
			.append(" and c.i_docno = d.i_docno ")
			.append(" and d.f_itmstatus = '200' ")
			.append(" and (c.d_complete_max is null or c.d_complete_max = '') ")
			.append(" and c.c_desc <> 'Checkup Program' ")
			.append(" and c.i_system = 'SVC' ")
			.append(" ) ");
		}
		if ("4.1".equals(itmtype)) {
			sql.append(" select distinct a.i_company , a.i_project , a.i_lock , a.i_docno ,  ")
				.append(" a.d_keyin as i_date , ")
				.append(" b.n_customer , c.i_house , a.d_appoint , ")
				.append(" a.count_date, a.d_print_inform ")
				.append(" from ( ")
				.append(" select i_docno , i_lock , d_keyin , i_company , i_project , d_keyin as d_appoint , d_print_inform ")
				.append(" , CASE WHEN (today - date(d_keyin))  > 0  ")
				.append("  THEN (today - date(d_keyin)) ")
				.append("  ELSE 0 END as count_date ")
				.append(" from lan:serv_dochd ")
				.append(" where i_company = '"+i_company+"' ")
				.append(" and i_project = '"+i_project+"' ")
				.append(" and i_system is null ")
				.append(" and i_doc_type = 'I' ")
				.append(" and f_status = 'OPN' ")
				.append(" and d_keyin >= today ")
				.append(" and c_desc <> 'Checkup Program' ")
				.append(" ) as a , ( ")
				.append(" select a.i_company , a.i_project , a.i_sort as i_lock ,  ")
				.append(" n_prename || ' ' || n_ncustomer || ' ' || ")
				.append("  n_scustomer as n_customer ")
				.append(" from lan:acscontr a , lan:acxcusto b ")
				.append(" where a.i_company = '"+i_company+"' ")
				.append(" and a.i_project = '"+i_project+"' ")
				.append(" and a.f_contr is null ")
				.append(" and b.i_customer = nvl(a.i_cus_intent1,a.i_exp_intent1) ")
				.append(" ) as b , lan:acxlckmd as c ")
				.append(" where a.i_company = b.i_company ")
				.append(" and a.i_project = b.i_project ")
				.append(" and a.i_company = c.i_company ")
				.append(" and a.i_project = c.i_project ")
				.append(" and a.i_lock = b.i_lock ")
				.append(" and a.i_lock = c.i_lock ")
				.append(" union ")
				.append(" select distinct a.i_company , a.i_project , a.i_lock , a.i_docno ,  ")
				.append(" a.d_keyin as i_date,b.n_customer,c.i_house, ")
				.append(" a.d_appoint ,  a.count_date, a.d_print_inform ")
				.append(" from ( ")
				.append(" select a.i_docno , a.i_lock , a.d_keyin , a.i_company , a.i_project ,  ")
				.append(" b.d_appoint,a.d_print_inform, ")
				.append(" CASE WHEN (today - date(b.d_appoint))  > 0   ")
				.append(" THEN (today - date(b.d_appoint))  ")
				.append(" ELSE 0 END as count_date ")
				.append(" from lan:serv_dochd a , lan:eser_dochd b ")
				.append(" where 1=1 ")
				.append(" and a.i_docno = b.i_docno ")
				.append(" and a.i_company = '"+i_company+"' ")
				.append(" and a.i_project = '"+i_project+"' ")
				.append(" and a.i_system = 'ESV' ")
				.append(" and a.i_doc_type = 'I' ")
				.append(" and a.f_status = 'OPN' ")
				.append(" and (a.d_appoint >= today or a.d_appoint is null) ")
				.append(" and a.c_desc <> 'Checkup Program' ")
				.append(" ) as a , ( ")
				.append(" select a.i_company , a.i_project , a.i_sort as i_lock , n_prename || ' ' || n_ncustomer || ' ' || n_scustomer as n_customer ")
				.append(" from lan:acscontr a , lan:acxcusto b ")
				.append(" where 1=1 ")
				.append(" and a.i_company = '"+i_company+"' ")
				.append(" and a.i_project = '"+i_project+"' ")
				.append(" and a.f_contr is null ")
				.append(" and b.i_customer = nvl(a.i_cus_intent1,a.i_exp_intent1) ")
				.append(" ) as b , lan:acxlckmd as c ")
				.append(" where 1=1 ")
				.append(" and a.i_company = b.i_company ")
				.append(" and a.i_project = b.i_project ")
				.append(" and a.i_company = c.i_company ")
				.append(" and a.i_project = c.i_project ")
				.append(" and a.i_lock = b.i_lock ")
				.append(" and a.i_lock = c.i_lock ")
				.append(" union ")
				.append(" select a.i_company,a.i_project, a.i_lock ,b.i_docno, ")
				.append(" a.d_keyin as i_date,a.n_customer, ")
				.append(" a.i_house , b.d_appoint,   ")
				.append(" CASE WHEN (today - date(b.d_appoint))  > 0 ")
				.append("  THEN (today - date(b.d_appoint)) ")
				.append(" ELSE 0 END as count_date,c.d_print_inform ")
				.append(" from lan:svc_dochd a , lan:svc_docdt b , lan:serv_dochd c ")
				.append(" where a.i_svc_docno = b.i_svc_docno ")
				.append(" and b.i_docno = c.i_docno ")
				.append(" and a.i_company = '"+i_company+"' ")
				.append(" and a.i_project = '"+i_project+"' ")
				.append(" and c.i_doc_type = 'I' ")
				.append(" and c.f_status = 'OPN' ")
				.append(" and b.d_appoint >= TODAY ")
				.append(" and c.c_desc <> 'Checkup Program' ")
				.append(" and c.i_system = 'SVC' ");
		}
		if ("4.2".equals(itmtype)) {
			sql.append(" select distinct a.i_company , a.i_project , a.i_lock , a.i_docno ,  ")
				.append(" a.d_keyin as i_date , ")
				.append(" b.n_customer , c.i_house , a.d_appoint , ")
				.append(" a.count_date, a.d_print_inform ")
				.append(" from ( ")
				.append(" select i_docno , i_lock , d_keyin , i_company , i_project , d_keyin as d_appoint , d_print_inform ")
				.append(" , CASE WHEN (today - date(d_keyin))  > 0  ")
				.append("  THEN (today - date(d_keyin)) ")
				.append("  ELSE 0 END as count_date ")
				.append(" from lan:serv_dochd ")
				.append(" where i_company = '"+i_company+"' ")
				.append(" and i_project = '"+i_project+"' ")
				.append(" and i_system is null ")
				.append(" and i_doc_type = 'I' ")
				.append(" and f_status = 'OPN' ")
				.append(" and d_keyin < today ")
				.append(" and c_desc <> 'Checkup Program' ")
				.append(" ) as a , ( ")
				.append(" select a.i_company , a.i_project , a.i_sort as i_lock ,  ")
				.append(" n_prename || ' ' || n_ncustomer || ' ' || ")
				.append("  n_scustomer as n_customer ")
				.append(" from lan:acscontr a , lan:acxcusto b ")
				.append(" where a.i_company = '"+i_company+"' ")
				.append(" and a.i_project = '"+i_project+"' ")
				.append(" and a.f_contr is null ")
				.append(" and b.i_customer = nvl(a.i_cus_intent1,a.i_exp_intent1) ")
				.append(" ) as b , lan:acxlckmd as c ")
				.append(" where a.i_company = b.i_company ")
				.append(" and a.i_project = b.i_project ")
				.append(" and a.i_company = c.i_company ")
				.append(" and a.i_project = c.i_project ")
				.append(" and a.i_lock = b.i_lock ")
				.append(" and a.i_lock = c.i_lock ")
				.append(" union ")
				.append(" select distinct a.i_company , a.i_project , a.i_lock , a.i_docno ,  ")
				.append(" a.d_keyin as i_date,b.n_customer,c.i_house, ")
				.append(" a.d_appoint ,  a.count_date, a.d_print_inform ")
				.append(" from ( ")
				.append(" select a.i_docno , a.i_lock , a.d_keyin , a.i_company , a.i_project ,  ")
				.append(" b.d_appoint,a.d_print_inform, ")
				.append(" CASE WHEN (today - date(b.d_appoint))  > 0   ")
				.append(" THEN (today - date(b.d_appoint))  ")
				.append(" ELSE 0 END as count_date ")
				.append(" from lan:serv_dochd a , lan:eser_dochd b ")
				.append(" where 1=1 ")
				.append(" and a.i_docno = b.i_docno ")
				.append(" and a.i_company = '"+i_company+"' ")
				.append(" and a.i_project = '"+i_project+"' ")
				.append(" and a.i_system = 'ESV' ")
				.append(" and a.i_doc_type = 'I' ")
				.append(" and a.f_status = 'OPN' ")
				.append(" and a.d_appoint < TODAY ")
				.append(" and a.c_desc <> 'Checkup Program' ")
				.append(" ) as a , ( ")
				.append(" select a.i_company , a.i_project , a.i_sort as i_lock , n_prename || ' ' || n_ncustomer || ' ' || n_scustomer as n_customer ")
				.append(" from lan:acscontr a , lan:acxcusto b ")
				.append(" where 1=1 ")
				.append(" and a.i_company = '"+i_company+"' ")
				.append(" and a.i_project = '"+i_project+"' ")
				.append(" and a.f_contr is null ")
				.append(" and b.i_customer = nvl(a.i_cus_intent1,a.i_exp_intent1) ")
				.append(" ) as b , lan:acxlckmd as c ")
				.append(" where 1=1 ")
				.append(" and a.i_company = b.i_company ")
				.append(" and a.i_project = b.i_project ")
				.append(" and a.i_company = c.i_company ")
				.append(" and a.i_project = c.i_project ")
				.append(" and a.i_lock = b.i_lock ")
				.append(" and a.i_lock = c.i_lock ")
				.append(" union ")
				.append(" select a.i_company,a.i_project, a.i_lock ,b.i_docno, ")
				.append(" a.d_keyin as i_date,a.n_customer, ")
				.append(" a.i_house , b.d_appoint,   ")
				.append(" CASE WHEN (today - date(b.d_appoint))  > 0 ")
				.append("  THEN (today - date(b.d_appoint)) ")
				.append(" ELSE 0 END as count_date,c.d_print_inform ")
				.append(" from lan:svc_dochd a , lan:svc_docdt b , lan:serv_dochd c ")
				.append(" where a.i_svc_docno = b.i_svc_docno ")
				.append(" and b.i_docno = c.i_docno ")
				.append(" and a.i_company = '"+i_company+"' ")
				.append(" and a.i_project = '"+i_project+"' ")
				.append(" and c.i_doc_type = 'I' ")
				.append(" and c.f_status = 'OPN' ")
				.append(" and b.d_appoint < TODAY ")
				.append(" and c.c_desc <> 'Checkup Program' ")
				.append(" and c.i_system = 'SVC' ");
		}
		if ("4.3".equals(itmtype)) {
			sql.append(" select distinct a.i_company , a.i_project , a.i_lock , a.i_docno ,  ")
				.append(" a.d_keyin as i_date , ")
				.append(" b.n_customer , c.i_house , a.d_appoint , ")
				.append(" a.count_date, a.d_print_inform ")
				.append(" from ( ")
				.append(" select i_docno , i_lock , d_keyin , i_company , i_project , d_keyin as d_appoint , d_print_inform ")
				.append(" , CASE WHEN (today - date(d_keyin))  > 0  ")
				.append("  THEN (today - date(d_keyin)) ")
				.append("  ELSE 0 END as count_date ")
				.append(" from lan:serv_dochd ")
				.append(" where i_company = '"+i_company+"' ")
				.append(" and i_project = '"+i_project+"' ")
				.append(" and i_system is null ")
				.append(" and i_doc_type = 'I' ")
				.append(" and f_status = 'OPN' ")
				.append(" and c_desc <> 'Checkup Program' ")
				.append(" ) as a , ( ")
				.append(" select a.i_company , a.i_project , a.i_sort as i_lock ,  ")
				.append(" n_prename || ' ' || n_ncustomer || ' ' || ")
				.append("  n_scustomer as n_customer ")
				.append(" from lan:acscontr a , lan:acxcusto b ")
				.append(" where a.i_company = '"+i_company+"' ")
				.append(" and a.i_project = '"+i_project+"' ")
				.append(" and a.f_contr is null ")
				.append(" and b.i_customer = nvl(a.i_cus_intent1,a.i_exp_intent1) ")
				.append(" ) as b , lan:acxlckmd as c ")
				.append(" where a.i_company = b.i_company ")
				.append(" and a.i_project = b.i_project ")
				.append(" and a.i_company = c.i_company ")
				.append(" and a.i_project = c.i_project ")
				.append(" and a.i_lock = b.i_lock ")
				.append(" and a.i_lock = c.i_lock ")
				.append(" union ")
				.append(" select distinct a.i_company , a.i_project , a.i_lock , a.i_docno ,  ")
				.append(" a.d_keyin as i_date,b.n_customer,c.i_house, ")
				.append(" a.d_appoint ,  a.count_date, a.d_print_inform ")
				.append(" from ( ")
				.append(" select a.i_docno , a.i_lock , a.d_keyin , a.i_company , a.i_project ,  ")
				.append(" b.d_appoint,a.d_print_inform, ")
				.append(" CASE WHEN (today - date(b.d_appoint))  > 0   ")
				.append(" THEN (today - date(b.d_appoint))  ")
				.append(" ELSE 0 END as count_date ")
				.append(" from lan:serv_dochd a , lan:eser_dochd b ")
				.append(" where 1=1 ")
				.append(" and a.i_docno = b.i_docno ")
				.append(" and a.i_company = '"+i_company+"' ")
				.append(" and a.i_project = '"+i_project+"' ")
				.append(" and a.i_system = 'ESV' ")
				.append(" and a.i_doc_type = 'I' ")
				.append(" and a.f_status = 'OPN' ")
				.append(" and a.c_desc <> 'Checkup Program' ")
				.append(" ) as a , ( ")
				.append(" select a.i_company , a.i_project , a.i_sort as i_lock , n_prename || ' ' || n_ncustomer || ' ' || n_scustomer as n_customer ")
				.append(" from lan:acscontr a , lan:acxcusto b ")
				.append(" where 1=1 ")
				.append(" and a.i_company = '"+i_company+"' ")
				.append(" and a.i_project = '"+i_project+"' ")
				.append(" and a.f_contr is null ")
				.append(" and b.i_customer = nvl(a.i_cus_intent1,a.i_exp_intent1) ")
				.append(" ) as b , lan:acxlckmd as c ")
				.append(" where 1=1 ")
				.append(" and a.i_company = b.i_company ")
				.append(" and a.i_project = b.i_project ")
				.append(" and a.i_company = c.i_company ")
				.append(" and a.i_project = c.i_project ")
				.append(" and a.i_lock = b.i_lock ")
				.append(" and a.i_lock = c.i_lock ")
				.append(" union ")
				.append(" select a.i_company,a.i_project, a.i_lock ,b.i_docno, ")
				.append(" a.d_keyin as i_date,a.n_customer, ")
				.append(" a.i_house , b.d_appoint,   ")
				.append(" CASE WHEN (today - date(b.d_appoint))  > 0 ")
				.append("  THEN (today - date(b.d_appoint)) ")
				.append(" ELSE 0 END as count_date,c.d_print_inform ")
				.append(" from lan:svc_dochd a , lan:svc_docdt b , lan:serv_dochd c ")
				.append(" where a.i_svc_docno = b.i_svc_docno ")
				.append(" and b.i_docno = c.i_docno ")
				.append(" and a.i_company = '"+i_company+"' ")
				.append(" and a.i_project = '"+i_project+"' ")
				.append(" and c.i_doc_type = 'I' ")
				.append(" and c.f_status = 'OPN' ")
				.append(" and c.c_desc <> 'Checkup Program' ")
				.append(" and c.i_system = 'SVC' ");
		}
		if ("6.1".equals(itmtype)) {
		sql.append(" ( ")
			.append(" select distinct a.i_company , a.i_project , a.i_lock , a.i_docno , date(a.d_keyin) as i_date ,  ")
			.append(" b.n_customer , c.i_house , a.d_appoint , a.count_hddate ")
			.append(" from ( ")
			.append(" select a.i_docno , a.i_lock , a.d_keyin , a.i_company , a.i_project , a.d_est_close as d_appoint ")
			.append(" , CASE WHEN (today - date(a.d_est_close))  > 0  THEN (today - date(a.d_est_close)) ELSE 0 END as count_hddate ")
			.append(" from lan:serv_dochd a , lan:serv_docdt b ")
			.append(" where 1=1 ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and a.c_desc <> 'Checkup Program' ")
			.append(" and a.i_doc_type = 'J' ")
			.append(" and a.f_status = 'OPN' ")
			.append(" and a.i_docno = b.i_docno ")
			.append(" and b.f_itmstatus = '300' ")
			.append(" and (a.d_complete_max is null or d_complete_max = '') ")
			.append(" and a.d_est_close >= today ")
			.append(" and (a.i_system = 'ESV' OR a.i_system is null ) ")
			.append(" ) as a , ( ")
			.append(" select a.i_company , a.i_project , a.i_sort as i_lock , ")
			.append(" n_prename || ' ' || n_ncustomer || ' ' || n_scustomer as n_customer ")
			.append(" from lan:acscontr a , lan:acxcusto b ")
			.append(" where 1=1 ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and a.f_contr is null ")
			.append(" and b.i_customer = nvl(a.i_cus_intent1,a.i_exp_intent1) ")
			.append(" ) as b , lan:acxlckmd as c ")
			.append(" where 1=1 ")
			.append(" and a.i_company = b.i_company ")
			.append(" and a.i_project = b.i_project ")
			.append(" and a.i_company = c.i_company ")
			.append(" and a.i_project = c.i_project ")
			.append(" and a.i_lock = b.i_lock ")
			.append(" and a.i_lock = c.i_lock ")
			.append(" ) union ( ")
			.append(" select distinct a.i_company , a.i_project , a.i_lock , b.i_docno , a.i_date ,  ")
			.append(" a.n_customer , a.i_house , c.d_est_close as d_appoint , ")
			.append(" CASE WHEN (today - date(c.d_est_close))  > 0  THEN (today - date(c.d_est_close)) ELSE 0 END as count_hddate  ")
			.append(" from lan:svc_dochd a , lan:svc_docdt b , lan:serv_dochd c , lan:serv_docdt d ")
			.append(" where a.i_svc_docno  = b.i_svc_docno ")
			.append(" and b.i_docno = c.i_docno ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and c.i_doc_type = 'J' ")
			.append(" and c.f_status = 'OPN' ")
			.append(" and c.i_docno = d.i_docno ")
			.append(" and d.f_itmstatus = '300' ")
			.append(" and (c.d_complete_max is null or c.d_complete_max = '') ")
			.append(" and c.d_est_close >= today ")
			.append(" and c.c_desc <> 'Checkup Program' ")
			.append(" and c.i_system = 'SVC' ")
			.append(" ) ");
		}
		if ("6.2".equals(itmtype)) {
		sql.append(" ( ")
			.append(" select distinct a.i_company , a.i_project , a.i_lock , a.i_docno , date(a.d_keyin) as i_date ,  ")
			.append(" b.n_customer , c.i_house , a.d_appoint , a.count_hddate ")
			.append(" from ( ")
			.append(" select a.i_docno , a.i_lock , a.d_keyin , a.i_company , a.i_project , a.d_est_close as d_appoint ")
			.append(" , CASE WHEN (today - date(a.d_est_close))  > 0  THEN (today - date(a.d_est_close)) ELSE 0 END as count_hddate ")
			.append(" from lan:serv_dochd a , lan:serv_docdt b ")
			.append(" where 1=1 ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and a.c_desc <> 'Checkup Program' ")
			.append(" and a.i_doc_type = 'J' ")
			.append(" and a.f_status = 'OPN' ")
			.append(" and a.i_docno = b.i_docno ")
			.append(" and b.f_itmstatus = '300' ")
			.append(" and (a.d_complete_max is null or d_complete_max = '') ")
			.append(" and a.d_est_close < today ")
			.append(" and (a.i_system = 'ESV' OR a.i_system is null ) ")
			.append(" ) as a , ( ")
			.append(" select a.i_company , a.i_project , a.i_sort as i_lock , ")
			.append(" n_prename || ' ' || n_ncustomer || ' ' || n_scustomer as n_customer ")
			.append(" from lan:acscontr a , lan:acxcusto b ")
			.append(" where 1=1 ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and a.f_contr is null ")
			.append(" and b.i_customer = nvl(a.i_cus_intent1,a.i_exp_intent1) ")
			.append(" ) as b , lan:acxlckmd as c ")
			.append(" where 1=1 ")
			.append(" and a.i_company = b.i_company ")
			.append(" and a.i_project = b.i_project ")
			.append(" and a.i_company = c.i_company ")
			.append(" and a.i_project = c.i_project ")
			.append(" and a.i_lock = b.i_lock ")
			.append(" and a.i_lock = c.i_lock ")
			.append(" ) union ( ")
			.append(" select distinct a.i_company , a.i_project , a.i_lock , b.i_docno , a.i_date ,  ")
			.append(" a.n_customer , a.i_house , c.d_est_close as d_appoint , ")
			.append(" CASE WHEN (today - date(c.d_est_close))  > 0  THEN (today - date(c.d_est_close)) ELSE 0 END as count_hddate  ")
			.append(" from lan:svc_dochd a , lan:svc_docdt b , lan:serv_dochd c , lan:serv_docdt d ")
			.append(" where a.i_svc_docno  = b.i_svc_docno ")
			.append(" and b.i_docno = c.i_docno ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and c.i_doc_type = 'J' ")
			.append(" and c.f_status = 'OPN' ")
			.append(" and c.i_docno = d.i_docno ")
			.append(" and d.f_itmstatus = '300' ")
			.append(" and (c.d_complete_max is null or c.d_complete_max = '') ")
			.append(" and c.d_est_close < today ")
			.append(" and c.c_desc <> 'Checkup Program' ")
			.append(" and c.i_system = 'SVC' ")
			.append(" ) ");
		}
		if ("6.3".equals(itmtype)) {
		sql.append(" ( ")
			.append(" select distinct a.i_company , a.i_project , a.i_lock , a.i_docno , date(a.d_keyin) as i_date ,  ")
			.append(" b.n_customer , c.i_house , a.d_appoint , a.count_hddate ")
			.append(" from ( ")
			.append(" select a.i_docno , a.i_lock , a.d_keyin , a.i_company , a.i_project , a.d_est_close as d_appoint ")
			.append(" , CASE WHEN (today - date(a.d_est_close))  > 0  THEN (today - date(a.d_est_close)) ELSE 0 END as count_hddate ")
			.append(" from lan:serv_dochd a , lan:serv_docdt b ")
			.append(" where 1=1 ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and a.c_desc <> 'Checkup Program' ")
			.append(" and a.i_doc_type = 'J' ")
			.append(" and a.f_status = 'OPN' ")
			.append(" and a.i_docno = b.i_docno ")
			.append(" and b.f_itmstatus = '300' ")
			.append(" and (a.d_complete_max is null or d_complete_max = '') ")
			.append(" and (a.i_system = 'ESV' OR a.i_system is null ) ")
			.append(" ) as a , ( ")
			.append(" select a.i_company , a.i_project , a.i_sort as i_lock , ")
			.append(" n_prename || ' ' || n_ncustomer || ' ' || n_scustomer as n_customer ")
			.append(" from lan:acscontr a , lan:acxcusto b ")
			.append(" where 1=1 ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and a.f_contr is null ")
			.append(" and b.i_customer = nvl(a.i_cus_intent1,a.i_exp_intent1) ")
			.append(" ) as b , lan:acxlckmd as c ")
			.append(" where 1=1 ")
			.append(" and a.i_company = b.i_company ")
			.append(" and a.i_project = b.i_project ")
			.append(" and a.i_company = c.i_company ")
			.append(" and a.i_project = c.i_project ")
			.append(" and a.i_lock = b.i_lock ")
			.append(" and a.i_lock = c.i_lock ")
			.append(" ) union ( ")
			.append(" select distinct a.i_company , a.i_project , a.i_lock , b.i_docno , a.i_date ,  ")
			.append(" a.n_customer , a.i_house , c.d_est_close as d_appoint , ")
			.append(" CASE WHEN (today - date(c.d_est_close))  > 0  THEN (today - date(c.d_est_close)) ELSE 0 END as count_hddate  ")
			.append(" from lan:svc_dochd a , lan:svc_docdt b , lan:serv_dochd c , lan:serv_docdt d ")
			.append(" where a.i_svc_docno  = b.i_svc_docno ")
			.append(" and b.i_docno = c.i_docno ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and c.i_doc_type = 'J' ")
			.append(" and c.f_status = 'OPN' ")
			.append(" and c.i_docno = d.i_docno ")
			.append(" and d.f_itmstatus = '300' ")
			.append(" and (c.d_complete_max is null or c.d_complete_max = '') ")
			.append(" and c.c_desc <> 'Checkup Program' ")
			.append(" and c.i_system = 'SVC' ")
			.append(" ) ");
		}
		sql.append(" ) where i_docno = '"+i_docno+"' order by i_lock , i_docno ,  i_company , i_project ");
		//System.out.println(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		if(rs.next()) {
			i_docno = doString.checkString(rs.getString("i_docno"), "");
%>
	<tr>
	<td class="dotline01" align="center"><%=++count%></td>
	<td class="dotline01 ; item" >&nbsp;<%=doString.checkString(rs.getString("i_lock"), "")%></td>
	<td class="dotline01" align="center"><%=doString.checkString(rs.getString("i_docno"), "")%></td>
	<td class="dotline01" align="center">&nbsp;<%=doString.checkString(rs.getString("i_house"), "")%></td>
    <td class="dotline01" >&nbsp;<%=doString.DisplayThai(doString.checkString(rs.getString("n_customer"), ""))%></td>
    <td class="dotline01" align="center">&nbsp;<%=DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString("i_date"), ""))%></td>
    
    <!-- TD วันที่แจ้งซ่อม/วันที่ยกเลิก -->
    <% if("3.1".equals(itmtype) || "3.2".equals(itmtype) || "3.3".equals(itmtype) || "6.1".equals(itmtype) || "6.2".equals(itmtype) || "6.3".equals(itmtype)){ %>
    <td class="dotline01" align="center">&nbsp;<%=DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString("d_appoint"), ""))%></td>
    <% } %>
    
    <!-- TD วันที่นัดหมายลูกค้า -->
    <% if("4.1".equals(itmtype) || "4.2".equals(itmtype) || "4.3".equals(itmtype)){ %>
    <td class="dotline01" align="center">&nbsp;<%=DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString("d_appoint"), ""))%></td>
    <% } %>
    
    <!-- TD ระยะเวลาดำเนินการ -->
    <% if("4.1".equals(itmtype) || "4.2".equals(itmtype) || "4.3".equals(itmtype)){ %>
    <td class="dotline01" align="center">&nbsp;<%=rs.getInt("count_date")%></td>
    <% }else{ %>
    <td class="dotline01" align="center">&nbsp;<%=rs.getInt("count_hddate")%></td>
    <% }%>
    
    <!-- TD สถานะ -->
    <% if("3.1".equals(itmtype) || "3.2".equals(itmtype) || "3.3".equals(itmtype) || "6.1".equals(itmtype) || "6.2".equals(itmtype) || "6.3".equals(itmtype)){ %>
	<td class="dotline01" align="center">&nbsp;<%=getStartTask(stmt1,doString.checkString(rs.getString("i_docno"), ""))%></td>
	<% } %>
	
	<!-- TD ผู้รับผิดชอบ -->
	<% if("3.1".equals(itmtype) || "3.2".equals(itmtype) || "3.3".equals(itmtype) || "6.1".equals(itmtype) || "6.2".equals(itmtype) || "6.3".equals(itmtype)){ %>
	<td class="dotline" align="left">&nbsp;
		<%
		int appoint = rs.getInt("count_hddate");
		if(appoint <= 3){//0-3
			out.print("<span style=\"color:green;font-weight:bold;\" >S</span>ervice Staff");
		}else if(appoint <= 10){//4-10
			out.print("<span style=\"color:orange;font-weight:bold;\" >M</span>anager");
		}else{
			out.print("<span style=\"color:red;font-weight:bold;\" >Z</span>one Manager");
		}
		%>
	</td>
	<% } %>
	<% if("4.1".equals(itmtype) || "4.2".equals(itmtype) || "4.3".equals(itmtype)){ %>
	<td class="dotline01" align="left">&nbsp;
		<%
		int appoint = rs.getInt("count_date");
		if(appoint <= 3){//0-3
			out.print("<span style=\"color:green;font-weight:bold;\" >S</span>ervice Staff");
		}else if(appoint <= 10){//4-10
			out.print("<span style=\"color:orange;font-weight:bold;\" >M</span>anager");
		}else{
			out.print("<span style=\"color:red;font-weight:bold;\" >Z</span>one Manager");
		}
		%>
	</td>
	<% } %>
	
	<% if("4.1".equals(itmtype) || "4.2".equals(itmtype) || "4.3".equals(itmtype)){ %>
	<td class="dotline" align="center">&nbsp;
		<%
		if("".equals(doString.checkString(rs.getString("d_print_inform"),""))){
			//out.print("ไม่พิมพ์");
			out.print("<img src=\"/LHServ/images/i_pass_no2.gif\" border=\"0\" align=\"absmiddle\" />");
		}else{
			//out.print("พิมพ์");
			out.print("<img src=\"/LHServ/images/i_pass2.gif\" border=\"0\" align=\"absmiddle\" />");
		}
		%>
	</td>
	<% }%>
    </tr>
    <% 
    
    int inf_col = 9;
    int opn_col[] = {4,3,2};
    int inform_job_count = 0;
    String c_desc_line = "";
    sql.delete(0,sql.length());
    sql.append(" select c_desc from lan:serv_dochd where i_docno = '"+doString.checkString(rs.getString("i_docno"),"")+"' ");
    rs1 = stmt1.executeQuery(sql.toString());
    if(rs1.next()){
    	String c_desc = doString.DisplayThai(doString.checkString(rs1.getString("c_desc"),"")); 
    	c_desc = c_desc.replace("|break|",";");
    	StringTokenizer token = new StringTokenizer(c_desc,";");
    %>
    <tr >
	  <td class="dotline01">&nbsp;</td>
	  <td colspan="<%=inf_col%>" class="dotline ; bold2"><img src="images/i_arrow2.gif" width="11" height="11" border="0" align="absmiddle"> Inform Job</td>
	</tr>
	<%  while(token.hasMoreTokens()){ 
			if(inform_job_count > 0){
	%>
	    <tr >
		  <td class="dotline01">&nbsp;</td>
		  <td colspan="<%=inf_col%>" class="dotline ; padding-left01">&nbsp;&nbsp;&nbsp;&nbsp;<%=c_desc_line%></td>
	    </tr>
	 <% 		
	 		}
	 		c_desc_line = doString.checkString(token.nextToken(),"");
	 		++inform_job_count;
	 	} 
    	c_desc = null;
    	token = null;
    	if("3.1".equals(itmtype) || "3.2".equals(itmtype) || "3.3".equals(itmtype)){ //if open job
    %>
    <tr >
	  <td class="dotline01">&nbsp;</td>
	  <td colspan="<%=inf_col%>" class="dotline ; padding-left01">&nbsp;&nbsp;&nbsp;&nbsp;<%=c_desc_line%></td>
    </tr>
    <tr >
	  <td class="dotline01">&nbsp;</td>
	  <td colspan="<%=opn_col[0]%>" class="dotline01 ; bold2 ; padding-left02"><img src="images/i_arrow2.gif" width="11" height="11" border="0" align="absmiddle"> Open Job</td>
	  <td colspan="<%=opn_col[1]%>" class="dotline01">&nbsp;</td>
	  <td colspan="<%=opn_col[2]%>" class="dotline">&nbsp;</td>
	  </tr>
	 <%
	 		int open_job_count = 0;
	 		String n_itmjob  = "";
	 		String ven_name = "";
	 		String n_desc = "";
    		sql.delete(0,sql.length());
    		sql.append(" select d.n_itmjob , b.ven_name , c.n_desc from lan:serv_docdt a , lan:vendor b , lan:serv_xstd c , lan:serv_boq d ")
    			.append(" where a.i_vendor = b.ven_no ")
    			.append(" and a.i_itmjob_area = c.i_code ")
    			.append(" and c.i_type = '01' ")
    			.append(" and a.i_itmjob = d.i_itmjob ")
    			.append(" and a.i_docno = '"+doString.checkString(rs.getString("i_docno"),"")+"' ");
    		rs2 = stmt2.executeQuery(sql.toString());
    		while(rs2.next()){
    			if(open_job_count > 0){
    			%>
    <tr  >
		<td class="dotline01">&nbsp;</td>
		<td colspan="<%=opn_col[0]%>" class="dotline01_01"><%=open_job_count%>. <%=doString.DisplayThai(n_itmjob)%></td>
	    <td colspan="<%=opn_col[1]%>" class="dotline01"><%=doString.DisplayThai(ven_name)%></td>
	    <td colspan="<%=opn_col[2]%>" class="dotline"><%=doString.DisplayThai(n_desc)%></td>
	</tr>
    			<%
    			}
    			n_itmjob = doString.checkString(rs2.getString("n_itmjob"),"");
    			ven_name = doString.checkString(rs2.getString("ven_name"),"");
    			n_desc = doString.checkString(rs2.getString("n_desc"),"");
    			
    			++open_job_count;
    		}
    		rs2.close();
    		if(open_job_count > 0){
   			%>
		    <tr >
				<td class="dotline01">&nbsp;</td>
				<td colspan="<%=opn_col[0]%>" class="dotline01_01  ; padding-left01"><%=open_job_count%>. <%=doString.DisplayThai(n_itmjob)%></td>
			    <td colspan="<%=opn_col[1]%>" class="dotline01"><%=doString.DisplayThai(ven_name)%></td>
			    <td colspan="<%=opn_col[2]%>" class="dotline"><%=doString.DisplayThai(n_desc)%></td>
			</tr>
   			<%
   			}
    	} else { //end if open job 
		%>
	    <tr >
		  <td class="dotline01">&nbsp;</td>
		  <td colspan="<%=inf_col%>" class="dotline ; padding-left01">&nbsp;&nbsp;&nbsp;&nbsp;<%=c_desc_line%></td>
	    </tr>
	 	<% 		
    	}
    }//end rs1 if 
    rs1.close();
    %>
    
<%
	}
	rs.close();
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
<br style="font-size:2pt">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop">&nbsp;</td>
    <td width="5" valign="top" align="right"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>
 
<%
boolean is_pending = false;
String f_document = "";
if(!"".equals(from_page)){
  if("SERV_OpenJob_Follow.jsp".equals(from_page)){
   f_document = "INF";
  }else if("SERV_StartTask_Follow.jsp".equals(from_page)){
   f_document = "OPN";
  }else {
   f_document = "STK";
  }
}
if(!"preview".equals(mode) && !"edit".equals(mode)){
	sql.delete(0,sql.length());
	sql.append(" select * from lan:serv_pending ")
		.append(" where i_docno = '"+i_docno+"' ")
		.append(" and f_status = 'OPN' ")
		.append(" and f_document = '"+f_document+"' ");
	rs = stmt.executeQuery(sql.toString());
	if(rs.next()){
		is_pending = true;
		c_desc_pending = doString.checkString(rs.getString("c_desc_pending"),"");
		i_pending_type = doString.checkString(rs.getString("i_pending_type"),"");
		d_pending = DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString("d_pending"),""));
		i_seq = rs.getInt("i_seq");
	}
	rs.close();
	
	if(!is_pending){
		sql.delete(0,sql.length());
		sql.append(" select max(i_seq) + 1 as i_seq from lan:serv_pending ")
			.append(" where i_docno = '"+i_docno+"' ");
		rs = stmt.executeQuery(sql.toString());
		if(rs.next()){
			i_seq = rs.getInt("i_seq");
		}
		rs.close();
		if(i_seq == 0) i_seq = 1;
	}
}
 %>
 
 <% if(is_pending || "preview".equals(mode)){ %>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR" align="center">
 
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td height="22" class="item ; noline01" width="25%">สาเหตุการ Pending : <font style="color:rgb(0,70,150) ; font-size:12pt ; font-style:bold"> ครั้งที่ <%=i_seq%></font>
    <input type="hidden" name="i_seq" value="<%=i_seq%>" />
    </td>
    <td  height="22" class="noline01" width="80%">
    <% 
    	boolean pt_flag = false;
    	String checked = "";
    	sql.delete(0,sql.length());
    	sql.append(" select i_code , n_desc from lan:serv_xstd where i_type = '77' ");
    	rs = stmt.executeQuery(sql.toString());
    	while(rs.next()){
    		if(i_pending_type.equals(doString.checkString(rs.getString("i_code"),""))){
    	%>
    	<img src="images/i_pass.gif" width="19" height="16"> <%=doString.DisplayThai(doString.checkString(rs.getString("n_desc"),""))%> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    	<%
    		}else{
    	%>
    	<img src="images/i_pass_blank.gif" width="19" height="16"> <%=doString.DisplayThai(doString.checkString(rs.getString("n_desc"),""))%> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    	<%
    		}
    	}
    	rs.close();
     %>
     <input type="hidden" name="i_pending_type" value="<%=i_pending_type%>" />
     </td>
  </tr>
  <tr>
    <td height="22" class="item ; noline01" valign="top">หมายเหตุ :</td>
    <td  height="22" class="noline01" valign="top">
    <textarea name="c_desc_pending" id="textarea" cols="45" rows="5" class="box" style="width:100%" readonly><%=doString.DisplayThai(c_desc_pending)%></textarea>
    </td>
  </tr>
  <tr>
    <td height="22" class="item ; noline01" valign="top">วันที่คาดว่าจะเลื่อนไป :</td>
    <td  height="22" class="noline01" valign="top"><%=d_pending%>
    <input type="hidden" name="d_pending" value="<%=d_pending%>" />
    </td>
  </tr>
</table>
 
</td>
  </tr>
</table>
 <% }else{ %>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR" align="center">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td height="22" class="item ; noline01" width="25%">สาเหตุการ Pending : <font style="color:rgb(0,70,150) ; font-size:12pt ; font-style:bold"> ครั้งที่ <%=i_seq%></font>
    <input type="hidden" name="i_seq" value="<%=i_seq%>" />
    </td>
    <td  height="22" class="noline01" width="80%">
    <% 
    	boolean pt_flag = false;
    	String checked = "";
    	sql.delete(0,sql.length());
    	sql.append(" select i_code , n_desc from lan:serv_xstd where i_type = '77' ");
    	rs = stmt.executeQuery(sql.toString());
    	while(rs.next()){
    		if(!"".equals(i_pending_type)){
    			if(i_pending_type.equals(doString.checkString(rs.getString("i_code"),""))){
    				checked = "checked=\"checked\"";
    			}else{
    				checked = "";
    			}
    		}else{
	    		if(!pt_flag){
	    			checked = "checked=\"checked\"";
	    			pt_flag = true;
	    		}else{
	    			checked = "";
	    		}
	    	}
    		%>
    	<input type="radio" name="i_pending_type" <%=checked%>  id="radio" value="<%=doString.checkString(rs.getString("i_code"),"")%>"><%=doString.DisplayThai(doString.checkString(rs.getString("n_desc"),""))%> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	
    		<%
    	}
    	rs.close();
     %>
    </td>
  </tr>
  <tr>
    <td height="22" class="item ; noline01" valign="top">หมายเหตุ :</td>
    <td  height="22" class="noline01" valign="top">
    <textarea name="c_desc_pending" id="textarea" cols="45" rows="5" class="box" style="width:100%"><%=doString.DisplayThai(c_desc_pending)%></textarea>
    </td>
  </tr>
  <tr>
    <td height="22" class="item ; noline01" valign="top">วันที่คาดว่าจะเลื่อนไป :</td>
    <td  height="22" class="noline01" valign="top">
    	<input name="d_pending" type="text" readonly="readonly" class="boxC" style="width:80px" value="<%=d_pending%>">
    	<img src="images/i_calendar.gif" width="18" height="18" align="absmiddle" hspace="5" style="cursor:hand" onClick="MM_openBrWindow('/LHServ/calendar.jsp?dateType=d_pending','Calendar','width=300,height=250,left=200,top=100')">
    </td>
  </tr>
</table>
</td>
  </tr>
</table>
 <% } %>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>




<br>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
  	<td align="left" >
 
<span style="color:red">*</span>&nbsp;&nbsp;วันที่นัดเข้าซ่อม - ปัจจุบัน
 
	</td>
</tr>
</table>
<br/>
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <% if(is_pending){ %>
			<a href="javascript:doAction('cancel')">
			<img border="0" src="images/act_cancel.gif"                                   
   			onmouseout=nereidFade(this,70,50,5)    
                 	onmouseover=nereidFade(this,100,50,5)     
                 	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>                                                    
            </td> 
            <% }else if("preview".equals(mode)){ %>
            <td width="230" class="act_tab2">
            <a href="javascript:doAction('add')">
            <img border="0" src="images/act_submit.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a> 
			<a href="javascript:doAction('edit')">
			<img border="0" src="images/act_edit.gif"                                   
   			onmouseout=nereidFade(this,70,50,5)    
                 	onmouseover=nereidFade(this,100,50,5)     
                 	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
            <% }else{ %>
            <td width="180" class="act_tab2">
            <a href="javascript:doAction('add')">
            <img border="0" src="images/act_submit.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
            <a href="javascript:javascript:doAction('preview')">
            <img border="0" src="images/act_PreviewAndSave.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
            </td>
            <% } %>
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="/LHServ/SERV_ReportServiceDetails.jsp?i_company=<%=i_company%>&i_project=<%=i_project%>&itmtype=<%=itmtype%>" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="/LHServ/SERV_Index.jsp" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
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
 

<%
		stmt.close();
		conn.close();
		stmt = null;
		conn = null;
	} catch (Exception e) {
		System.out.println("ERROR SERV_Pending.jsp : " + sql.toString());
		System.out.println("ERROR SERV_Pending.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null)
		rs.close();
			if (stmt != null)
		stmt.close();
			if (conn != null)
		conn.close();
		} catch (SQLException ignore) {
		}
	}
%>

 

