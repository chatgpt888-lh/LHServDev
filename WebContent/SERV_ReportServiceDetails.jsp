<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
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

	/*String ParameterNames = "";
	for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
		ParameterNames = (String)e.nextElement();
		System.out.println(ParameterNames + ":"+request.getParameter(ParameterNames));
	}*/


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
	
    int inf_col = 10;
    int opn_col[] = {4,3,3};
    boolean is_pending = false;
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
		
		hide_detail = doString.checkString(request.getParameter("hide_detail"),"Y");
		
		
		if ("3.1".equals(itmtype)) {
			status_itm = "Open - ยังไม่ถึงวันนัดหมาย";
		}
		if ("3.2".equals(itmtype)){
			status_itm = "Open - เลยวันนัดหมายแล้ว";
		}
		if ("3.3".equals(itmtype)){
			status_itm = "Open - Pending";
			inf_col = 12+1;
    		opn_col[2] = 5+1;
		}
		if ("4.1".equals(itmtype)) {
			status_itm = "Inform - ยังไม่ถึงวันนัดหมาย";
		}
		if ("4.2".equals(itmtype)) {
			status_itm = "Inform - เลยวันนัดหมายแล้ว";
		}
		if ("4.3".equals(itmtype)) {
			status_itm = "Inform - Pending";
			inf_col = 12;
    		opn_col[2] = 5;
		}
		if ("6.1".equals(itmtype)) {
			status_itm = "Start Task - ยังไม่ถึงวันนัดหมาย";
		}
		if ("6.2".equals(itmtype)) {
			status_itm = "Start Task - เลยวันนัดหมายแล้ว";
		}
		if ("6.3".equals(itmtype)) {
			status_itm = "Start Task - Pending";
			inf_col = 12+1;
    		opn_col[2] = 5+1;
		}
		if ("7.1".equals(itmtype)) {
			status_itm = "Complete";
			
			inf_col = 7+1;
    		opn_col[0] = 3+1;
    		opn_col[1] = 2+1;
    		opn_col[2] = 2+1;
		}
%>
<HTML>
<HEAD>
<TITLE>Home</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<style type="text/css">
.hidden-class { display: none; }
.show-class { display: compact; }
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
	<% if("7.1".equals(itmtype)){ %>
	form.action = '/LHServ/SERV_OpenJob_Disp.jsp';
	<% }else{ %>
	form.action = '/LHServ/SERV_OpenJob_Follow.jsp';
	<% } %>
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
//-->
</script>


<base target="_self">


</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="initPage()">

<FORM method="POST" action="#" name="frmSERV" >
<input type="hidden" name="i_docno" value="" />
<input type="hidden" name="edit" value="" />
<input type="hidden" name="sort_col" value="<%=sort_col%>" />
<input type="hidden" name="i_company" value="<%=i_company%>" />
<input type="hidden" name="i_project" value="<%=i_project%>" />
<input type="hidden" name="d_keyin_beg" value="<%=d_keyin_beg%>" />
<input type="hidden" name="d_keyin_end" value="<%=d_keyin_end%>" />
<input type="hidden" name="itmtype" value="<%=itmtype%>" />
<input type="hidden" name="hide_detail" value="<%=hide_detail%>" />

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center" class="BD">
    

      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ยินดีต้อนรับสู่ระบบบริการหลังการขาย (สถานะ <%=status_itm%>)</td>
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
    	v.3.1
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
                <td class="item_tab2" width="300">รายละเอียดการ Follow Up</td>
                <td class="item_tab3"></td>
                <td >
                <span style="padding-right:20px"><a href="javascript:showDetail()"><img src="images/i_arrow3.gif" width="15" height="15" hspace="5" border="0" align="absmiddle">Show All</a></span>
                	 <span><a href="javascript:hideDetail()"><img src="images/i_arrow3.gif" width="15" height="15" hspace="5" border="0" align="absmiddle">Hide All</a></span>
				&nbsp;
				</td>
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
	<td width="10%" class="col_name"><a href="javascript:sortBy('i_docno')" >เลขที่เอกสาร</a></td>
	<td width="10%" class="col_name">บ้านเลขที่</td>
    <td width="18%" class="col_name">ชื่อผู้แจ้ง / ลูกค้า</td>
    <td class="col_name"><a href="javascript:sortBy('i_date')" >วันที่แจ้งซ่อม</a></td>
    <% if("3.1".equals(itmtype) || "3.2".equals(itmtype) || "3.3".equals(itmtype)){ %>
    	<td class="col_name"><a href="javascript:sortBy('d_appoint')" >วันนัดซ่อม</a></td>
    <% } %>
    <% if("6.1".equals(itmtype) || "6.2".equals(itmtype) || "6.3".equals(itmtype)){ %>
    	<td class="col_name"><a href="javascript:sortBy('d_appoint')" >วันประมาณการเสร็จ</a></td>
    <% } %>
    <% if("7.1".equals(itmtype)){ %>
    	<td class="col_name"><a href="javascript:sortBy('d_appoint')" >วันที่ Complete</a></td>
    <% } %>
    <% if ("4.1".equals(itmtype) || "4.2".equals(itmtype) || "4.3".equals(itmtype)) {  %>
    	<td class="col_name"><a href="javascript:sortBy('d_appoint')" >วันที่นัดหมายลูกค้า</a></td>
    <% } %>
    <td class="col_name"><a href="javascript:sortBy('count_date')" >ระยะเวลาดำเนินการ<span style="color:red" >*</span></a></td>
    <% if("3.1".equals(itmtype) || "3.2".equals(itmtype) || "3.3".equals(itmtype) || "6.1".equals(itmtype) || "6.2".equals(itmtype) || "6.3".equals(itmtype)){ %>
	<td class="col_name">Start Task</td>
	<% } %>
	<% if(!"7.1".equals(itmtype)){ %>
	<td class="col_name">ผู้รับผิดชอบ</td>
	<% } %>
	<%	
	if((itmtype.indexOf("7.") != -1) || (itmtype.indexOf("6.") != -1) ||  (itmtype.indexOf("3.") != -1) ) {
	%>
	   <td class="col_name"><a href="javascript:sortBy('type1')" >ประเภทงาน</a></td>
	<%} %>
	
	<% if ("4.1".equals(itmtype) || "4.2".equals(itmtype) || "4.3".equals(itmtype)) {  %>
	<td class="col_name"><a href="javascript:sortBy('d_print_inform')" >พิมพ์ Inform Job</a></td>
	<% } %>
	<% if(!"7.1".equals(itmtype)){ %>
	<td class="col_name">Pending</td>
	<% } %>
	<% if("3.3".equals(itmtype) || "4.3".equals(itmtype) || "6.3".equals(itmtype)){ %>
	<td class="col_name">สาเหตุ</td>
	<td class="col_name">นัดใหม่</td>
	<% } %>
    </tr>
<%
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
		
		//System.out.println("itmtype :"+itmtype);
		sql.delete(0, sql.length());
		if (itmtype.indexOf("3.") != -1) {
			sql.append(" select distinct a.i_company as i_company , a.i_project as i_project , a.i_lock as i_lock , a.i_docno as i_docno , date(a.d_keyin) as i_date ,  ")
				.append(" b.n_customer as n_customer , c.i_house as i_house , a.d_appoint as d_appoint , a.count_hddate as count_hddate")
				 /* -------201903.11----- */
				.append("  ,a.i_system,a.i_warranty,a.i_vendor,a.i_vendor1 ,a.type1 ")
				.append(" from ( ")
				.append(" select distinct a.i_docno , a.i_lock , a.d_keyin , a.i_company , a.i_project , a.d_appoint ")
				.append(" , CASE WHEN (today - date(a.d_appoint))  > 0  THEN (today - date(a.d_appoint)) ELSE 0 END as count_hddate ")
				
				 /* -------201903.11----- */		
				.append("  ,a.i_system,a.i_warranty ")
				.append("  ,( CASE  when a.i_warranty = '01' then 'Close'  when (b.i_vendor <> c.i_vendor1 ) then 'W1'  ELSE 'W2'  END ) as type1 ")
				.append("   ,b.i_vendor ,c.i_vendor1   ")
				.append(" from lan:serv_dochd a , lan:serv_docdt b ,lan:serv_lstaff c ")
				//.append(" from lan:serv_dochd a , lan:serv_docdt b ")
				.append(" where 1=1 ")
				.append(" and a.i_company = '"+i_company+"' ")
				.append(" and a.i_project = '"+i_project+"' ")
				.append(" and a.c_desc <> 'Checkup Program' ")
				.append(" and a.i_doc_type = 'J' ")
				.append(" and a.f_status = 'OPN' ")
				.append(" and a.i_docno = b.i_docno ")
				 /* -------201903.11----- */
				.append(" and a.i_company = c.i_company ")
				.append(" and a.i_project = c.i_project  ")
				
				.append(" and b.f_itmstatus = '200' ")
				.append(" and (a.d_complete_max is null or d_complete_max = '') ");
			if("3.1".equals(itmtype)){
				sql.append(" and a.d_appoint >= today ")
					.append(" and (a.f_pending <> 'OPN' OR a.f_pending is null) ");
			}else if("3.2".equals(itmtype)){
				sql.append(" and a.d_appoint < today ")
					.append(" and (a.f_pending <> 'OPN' OR a.f_pending is null) ");
			}else{
				sql.append(" and a.f_pending = 'OPN' ");
			}
			sql.append(" ) as a , OUTER ( ")
				.append(" select a.i_company , a.i_project , a.i_sort as i_lock , ")
				.append(" n_prename || ' ' || n_ncustomer || ' ' || n_scustomer as n_customer ")
				.append(" from lan:acscontr a , lan:acxcusto b ")
				.append(" where 1=1 ")
				.append(" and a.i_company = '"+i_company+"' ")
				.append(" and a.i_project = '"+i_project+"' ")
				.append(" and a.f_contr is null ")
				.append(" and b.i_customer = nvl(a.i_cus_intent1,a.i_exp_intent1) ")
				.append(" ) as b , OUTER lan:acxlckmd as c ")
				.append(" where 1=1 ")
				.append(" and a.i_company = b.i_company ")
				.append(" and a.i_project = b.i_project ")
				.append(" and a.i_company = c.i_company ")
				.append(" and a.i_project = c.i_project ")
				.append(" and a.i_lock = b.i_lock ")
				.append(" and a.i_lock = c.i_lock ");
				//System.out.println("333  = "+sql.toString());
		}
		
		if (itmtype.indexOf("4.") != -1) {
			//System.out.println("=========================== 4. <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ================================== ");
			sql.append(" select distinct a.i_company as i_company , a.i_project as i_project , a.i_lock as i_lock, a.i_docno as i_docno,  ")
				.append(" a.d_keyin as i_date , ")
				.append(" b.n_customer as n_customer , c.i_house as i_house, a.d_appoint as d_appoint, ")
				.append(" a.count_date as count_date , a.d_print_inform as d_print_inform ")
				.append(" from ( ")
				.append(" select distinct i_docno , i_lock , d_keyin , i_company , i_project , d_appoint_cust as d_appoint , d_print_inform ")
				.append(" , CASE WHEN (today - date(d_appoint_cust))  > 0  ")
				.append("  THEN (today - date(d_appoint_cust)) ")
				.append("  ELSE 0 END as count_date ")
				.append(" from lan:serv_dochd ")
				.append(" where i_company = '"+i_company+"' ")
				.append(" and i_project = '"+i_project+"' ")
				.append(" and i_doc_type = 'I' ")
				.append(" and f_status = 'OPN' ")
				.append(" and c_desc <> 'Checkup Program' ");
			if("4.1".equals(itmtype)){
				sql.append(" and d_appoint_cust >= today ")
					.append(" and (f_pending <> 'INF' OR f_pending is null) ");
			}else if("4.2".equals(itmtype)){
				sql.append(" and d_appoint_cust < today ")
					.append(" and (f_pending <> 'INF' OR f_pending is null) ");
			}else{
				sql.append(" and f_pending = 'INF' ");
			}
			sql.append(" ) as a , outer ( ")
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
				.append(" and a.i_lock = c.i_lock ");
				//System.out.println("44444.  "+sql.toString());
		}
		
		if(itmtype.indexOf("6.") != -1) {
		sql.append(" select distinct a.i_company as i_company , a.i_project as i_project , a.i_lock as i_lock , a.i_docno as i_docno , date(a.d_keyin) as i_date ,  ")
			.append(" b.n_customer as n_customer , c.i_house as i_house , a.d_appoint as d_appoint , a.count_hddate as count_hddate ")
			 /* -------201903.11----- */
    		.append(" ,a.i_system,a.i_warranty,a.i_vendor,a.i_vendor1 ,a.type1 ")
			.append(" from ( ")
			.append(" select distinct a.i_docno , a.i_lock , a.d_keyin , a.i_company , a.i_project , a.d_est_close as d_appoint ")
			.append(" , CASE WHEN (today - date(a.d_est_close))  > 0  THEN (today - date(a.d_est_close)) ELSE 0 END as count_hddate ")

			 /* -------201903.11----- */ 
			.append(" ,a.i_system,a.i_warranty ")
			.append(" ,( CASE  when a.i_warranty = '01' then 'Close'  when (b.i_vendor <> c.i_vendor1 ) then 'W1'  ELSE 'W2'  END ) as type1 ")
			.append("  ,b.i_vendor ,c.i_vendor1   ")
			.append(" from lan:serv_dochd a , lan:serv_docdt b ,lan:serv_lstaff c ")	 
			.append(" where 1=1 ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and a.c_desc <> 'Checkup Program' ")
			.append(" and a.i_doc_type = 'J' ")
			.append(" and a.f_status = 'OPN' ")
			.append(" and a.i_docno = b.i_docno ")
			
			  /* -------201903.11----- */
			.append(" and a.i_company = c.i_company ")
			.append(" and a.i_project = c.i_project  ")

			.append(" and b.f_itmstatus = '300' ")
			.append(" and (a.d_complete_max is null or d_complete_max = '') ");
			if("6.1".equals(itmtype)){
				sql.append(" and a.d_est_close >= today ")
					.append(" and (a.f_pending <> 'STK' OR a.f_pending is null) ");
			}else if("6.2".equals(itmtype)){
				sql.append(" and a.d_est_close < today ")
					.append(" and (a.f_pending <> 'STK' OR a.f_pending is null) ");
			}else{
				sql.append(" and a.f_pending = 'STK' ");
			}
			sql.append(" ) as a ,outer ( ")
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
			.append(" and a.i_lock = c.i_lock ");

			//System.out.println("66666 == >  "+sql.toString());
		}
		
		if(itmtype.indexOf("7.") != -1) {
		sql.append(" select distinct a.i_company as i_company , a.i_project as i_project , a.i_lock as i_lock , a.i_docno as i_docno , date(a.d_keyin) as i_date ,  ")
			.append(" b.n_customer as n_customer, c.i_house as i_house , a.d_appoint as d_appoint  , a.count_hddate as count_hddate ")
		      /* -------201903.11----- */  
		     
		      .append("  ,a.i_system,a.i_warranty,a.i_vendor,a.i_vendor1 ,a.type1 ")
    			
			.append(" from ( ")
			.append(" select distinct a.i_docno , a.i_lock , a.d_keyin , a.i_company , a.i_project , a.d_complete_max as d_appoint ")
			.append(" , CASE WHEN (date(a.d_complete_max) - date(a.d_keyin))  > 0  THEN (date(a.d_complete_max) - date(a.d_keyin)) ELSE 0 END as count_hddate ")
			/* -------201903.11----- */   
			 .append(" ,a.i_system,a.i_warranty ")
			 .append(" ,( CASE  when a.i_warranty = '01' then 'Close'  when (b.i_vendor <> c.i_vendor1 ) then 'W1'  ELSE 'W2'  END ) as type1 ")
			 .append(" ,b.i_vendor ,c.i_vendor1 ")
			 .append(" from lan:serv_dochd a , lan:serv_docdt b ,lan:serv_lstaff c ")

			.append(" where 1=1 ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and a.c_desc <> 'Checkup Program' ")
			.append(" and a.i_doc_type = 'J' ")
			.append(" and a.f_status <> 'CAN'  ")
			.append(" and a.i_docno = b.i_docno ")
		    /* -------201903.11----- */  
			.append("  and a.i_company = c.i_company ")
			.append(" and a.i_project = c.i_project  ")
						             			
			.append(" and a.d_complete_max is not null ")
			.append(" and a.d_complete_max > '"+d_complete_max_begin+"' ")
			.append(" and a.d_complete_max <= '"+d_complete_max_end+"' ")
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
			.append(" and a.i_lock = c.i_lock ");
			//System.out.println("====777. "+sql.toString());
		}
		//System.out.println("====4.xxxxxxxxxxxxxxxx=== "+sql);
		//System.out.println("====4.xxxxxxxxxxxxxxxx=== "+sort_col);
		
		if(itmtype.length()>0 && sql.toString().length()>0){
		
			if(!"".equals(sort_col) && !"default".equals(sort_col)){
				sql.append(" order by "+sort_col+" , 3 ,5 ,1, 2 ");
			}else{
				//sql.append(" order by i_lock , i_docno , i_company , i_project ");
				sql.append(" order by i_lock , i_docno , i_company , i_project ");
			}
	
			//System.out.println(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			while (rs.next()) {
%>
	<tr>
	<td class="dotline01" align="center"><%=++count%></td>
	<td class="dotline01 ; item" >&nbsp;<%=doString.checkString(rs.getString("i_lock"), "")%></td>
	<% if("3.1".equals(itmtype) || "3.2".equals(itmtype) || "3.3".equals(itmtype) ||  "6.1".equals(itmtype) || "6.2".equals(itmtype) || "6.3".equals(itmtype)){ 
		String pageLink = "SERV_CompTask_Follow.jsp";
		if("3.1".equals(itmtype) || "3.2".equals(itmtype) || "3.3".equals(itmtype)){
			pageLink = "SERV_StartTask_Follow.jsp";
		}
		int status = getDocCode(stmt1,doString.checkString(rs.getString("i_docno"), ""));
		if(100 == status){
		%>
		<td class="dotline01" align="center"><A HREF="<%=request.getContextPath()+"/"+pageLink+"?sel_project="+i_company+":"+i_project+"&i_docno="+doString.checkString(rs.getString("i_docno"), "")+"&d_keyin_beg="+d_keyin_beg+"&d_keyin_end="+d_keyin_end+"&itmtype="+itmtype%>"><%=doString.checkString(rs.getString("i_docno"), "")%></A></td>
		<%
		}else if(200 == status){
		%>
		<td class="dotline01" align="center"><A HREF="<%=request.getContextPath()+"/"+pageLink+"?sel_project="+i_company+":"+i_project+"&i_docno="+doString.checkString(rs.getString("i_docno"), "")+"&d_keyin_beg="+d_keyin_beg+"&d_keyin_end="+d_keyin_end+"&itmtype="+itmtype%>"><%=doString.checkString(rs.getString("i_docno"), "")%></A></td>
		<%
		}else{
		%>
		<td class="dotline01" align="center"><A HREF="<%=request.getContextPath()+"/"+pageLink+"?sel_project="+i_company+":"+i_project+"&i_docno="+doString.checkString(rs.getString("i_docno"), "")+"&d_keyin_beg="+d_keyin_beg+"&d_keyin_end="+d_keyin_end+"&itmtype="+itmtype%>"><%=doString.checkString(rs.getString("i_docno"), "")%></A></td>
		<%
		}
	 }else{ %>
	<td class="dotline01" align="center"><A HREF="javascript:gotoOpenJob('<%=doString.checkString(rs.getString("i_docno"),"")%>')"><%=doString.checkString(rs.getString("i_docno"), "")%></A></td>
	<% } %>
	<td class="dotline01" align="center">&nbsp;<%=doString.checkString(rs.getString("i_house"), "")%></td>
    <td class="dotline01" >&nbsp;<%=doString.DisplayThai(doString.checkString(rs.getString("n_customer"), ""))%></td>
    <td class="dotline01" align="center">&nbsp;<%=DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString("i_date"), ""))%></td>
    
    <!-- TD วันที่แจ้งซ่อม/วันที่ยกเลิก -->
    <% if("3.1".equals(itmtype) || "3.2".equals(itmtype) || "3.3".equals(itmtype) || "6.1".equals(itmtype) || "6.2".equals(itmtype) || "6.3".equals(itmtype) || "7.1".equals(itmtype)){ %>
    <td class="dotline01" align="center">&nbsp;<%=DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString("d_appoint"), ""))%></td>
    <% } %>
    <!-- TD วันที่นัดหมายลูกค้า -->
    <% if("4.1".equals(itmtype) || "4.2".equals(itmtype) || "4.3".equals(itmtype)){ %>
    <td class="dotline01" align="center">&nbsp;<%=DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString("d_appoint"), ""))%></td>
    <% } %>
    
    <!-- TD ระยะเวลาดำเนินการ -->
    <% if("4.1".equals(itmtype) || "4.2".equals(itmtype) || "4.3".equals(itmtype)){ %>
    <td class="dotline01" align="center">&nbsp;<%=rs.getInt("count_date")%></td>
    <% }else if("7.1".equals(itmtype)){ %>
    <td class="dotline01 ; item" align="center">&nbsp;<%=rs.getInt("count_hddate")%></td>
    <% }else{ %>
    <td class="dotline01" align="center">&nbsp;<%=rs.getInt("count_hddate")%></td>
    <% }%>
    
    <!-- TD สถานะ -->
    <% if("3.1".equals(itmtype) || "3.2".equals(itmtype) || "3.3".equals(itmtype) || "6.1".equals(itmtype) || "6.2".equals(itmtype) || "6.3".equals(itmtype)){ %>
	<td class="dotline01" align="center">&nbsp;<%=getStartTask(stmt1,doString.checkString(rs.getString("i_docno"), ""))%></td>
	<% } %>
	
	<!-- TD ผู้รับผิดชอบ -->
	<% if("3.1".equals(itmtype) || "3.2".equals(itmtype) || "3.3".equals(itmtype) || "6.1".equals(itmtype) || "6.2".equals(itmtype) || "6.3".equals(itmtype)){ %>
	<td class="dotline01" align="left">&nbsp;
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
	<!-- TD ประเภทงาน  2019 -->
	<%	
	if((itmtype.indexOf("7.") != -1) || (itmtype.indexOf("6.") != -1) ||  (itmtype.indexOf("3.") != -1) ) { 
	     String clazz = " dotline01 ";
	     if(itmtype.indexOf("3.") != -1){
	     //dotline01 ; item ; dotline
	        clazz ="dotline01 ; item";
	     }
	     if(itmtype.indexOf("7.") != -1){
	       clazz ="dotline";
	     }
	%>
		<td class="<%=clazz %>" align="left">&nbsp;
		 <%
		  String type1 = doString.checkString(rs.getString("type1"), "");
		  if(type1.equalsIgnoreCase("Close")){
		 	 out.print("ปิดประกัน ");
		  }
		  if(type1.equalsIgnoreCase("W1")){
		  	out.print("รอ-ร้านค้า ");
		  }
		  if(type1.equalsIgnoreCase("W2")){
		  	//ซ่อมทั่วไป-ผรม.ซ่อม
		  	out.print("รอ-ผู้รับเหมา ");
		  }
	     %>
		</td>
	<%
	}
	%>

	<% if("4.1".equals(itmtype) || "4.2".equals(itmtype) || "4.3".equals(itmtype)){ %>
	<td class="dotline01" align="center">&nbsp;
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
	<% if(!"7.1".equals(itmtype)){ 
		is_pending = false;
		String pending = "<img src=\"/LHServ/images/i_pass_no2.gif\" border=\"0\" align=\"absmiddle\" />";
		String c_desc_pending = "&nbsp;";
		String d_pending = "&nbsp;";
		sql.delete(0,sql.length());
		sql.append(" select * from lan:serv_pending ")
			.append(" where i_docno = '"+doString.checkString(rs.getString("i_docno"), "")+"' ")
			.append(" and f_status = 'OPN' ");
		if("3.1".equals(itmtype) || "3.2".equals(itmtype) || "3.3".equals(itmtype)){ 
			sql.append(" and f_document = 'OPN' ");
		}else if("4.1".equals(itmtype) || "4.2".equals(itmtype) || "4.3".equals(itmtype)){ 
			sql.append(" and f_document = 'INF' ");
		}else{
			sql.append(" and f_document = 'STK' ");
		}
		rs1 = stmt1.executeQuery(sql.toString());
		if(rs1.next()){
			is_pending = true;
			pending = "<img src=\"/LHServ/images/i_pass2.gif\" border=\"0\" align=\"absmiddle\" />";
			c_desc_pending = doString.DisplayThai(doString.checkString(rs1.getString("c_desc_pending"),""));
			d_pending = doString.checkString(rs1.getString("d_pending"),"");
			if(!"".equals(d_pending)){
				//d_pending = DateUtil.ifxToThaiDateNoTime(d_pending);
			}
		}
		rs1.close();
		if("3.3".equals(itmtype) || "4.3".equals(itmtype) || "6.3".equals(itmtype)){
		%>
			<td class="dotline01" align="center"><%=pending%></td>
			<td class="dotline01" align="center"><%=c_desc_pending%></td>
			<td class="dotline" align="center"><%=d_pending%></td>
		<%
		}else{
		%>
			<td class="dotline" align="center"><%=pending%></td>
		<%
		}
		pending = null;	
	}
	%>
    </tr>
    <% 
   
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
    <tr class="hidden-class">
	  <td class="dotline01">&nbsp;</td>
	  <td colspan="<%=++inf_col%>"  class=dotline><img src="images/i_arrow2.gif" width="11" height="11" border="0" align="absmiddle"> Inform Job</td>
	</tr>
	<%  while(token.hasMoreTokens()){ 
			if(inform_job_count > 0){ 
	%>
	    <tr class="hidden-class">
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
    	if("3.1".equals(itmtype) || "3.2".equals(itmtype) || "3.3".equals(itmtype) || "7.1".equals(itmtype) || "6.1".equals(itmtype) || "6.2".equals(itmtype)|| "6.3".equals(itmtype)){ //if open job
		if(inform_job_count > 0){
		%>
		    <tr class="hidden-class">
			  <td class="dotline01">&nbsp;</td>
			  <td colspan="<%=inf_col%>" class="dotline ; padding-left01">&nbsp;&nbsp;&nbsp;&nbsp;<%=c_desc_line%></td>
		    </tr>
		<% } %>
    <tr class="hidden-class">
	  <td class="dotline01">&nbsp;</td>
	  <td colspan="<%=opn_col[0]%>" class="dotline01 ; bold2 ; padding-left02"><img src="images/i_arrow2.gif" width="11" height="11" border="0" align="absmiddle"> Open Job</td>
	  <td colspan="<%=opn_col[1]%>" class="dotline01">&nbsp;</td>
	  <td colspan="<%=++opn_col[2]%>" class="dotline">&nbsp;</td>
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
				    <tr  class="hidden-class">
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
		    <tr class="hidden-class">
				<td class="dotline01">&nbsp;</td>
				<td colspan="<%=opn_col[0]%>" class="dotline01_01"><%=open_job_count%>. <%=doString.DisplayThai(n_itmjob)%></td>
			    <td colspan="<%=opn_col[1]%>" class="dotline01"><%=doString.DisplayThai(ven_name)%></td>
			    <td colspan="<%=++opn_col[2]%>" class="dotline"><%=doString.DisplayThai(n_desc)%></td>
			</tr>
   			<%
   			}
    	} else { //end if open job 
			if(inform_job_count > 0){
		%>
		    <tr class="hidden-class">
			  <td class="dotline01">&nbsp;</td>
			  <td colspan="<%=inf_col%>" class="dotline ; padding-left01">&nbsp;&nbsp;&nbsp;&nbsp;<%=c_desc_line%></td>
		    </tr>
	 	<% 	}	
    	}
    }//end rs1 if 
    rs1.close();
    
    int count_pending = 0;
    sql.delete(0,sql.length());
    sql.append(" select count(i_docno) as total from lan:serv_pending where i_docno = '"+doString.checkString(rs.getString("i_docno"),"")+"' ");
    rs1 = stmt1.executeQuery(sql.toString());

    while(rs1.next()){
    	count_pending = rs1.getInt("total");
    }
    rs1.close();
    
    if(count_pending > 0){
    %>
    <tr class="hidden-class">
	  <td class="dotline01">&nbsp;</td>
	  <td colspan="<%=inf_col%>" class="dotline ; bold2"><img src="images/i_arrow2.gif" width="11" height="11" border="0" align="absmiddle"> Pending</td>
	</tr>
	<%
    sql.delete(0,sql.length());
    sql.append(" select i_date,i_seq,i_pending_type,c_desc_pending,d_pending,date(i_date) as i_date , f_status , f_document , i_employ ")
    	.append(" from lan:serv_pending where i_docno = '"+doString.checkString(rs.getString("i_docno"),"")+"'  ");
    rs1 = stmt1.executeQuery(sql.toString());

    while(rs1.next()){
    	String c_desc_pending = doString.DisplayThai(doString.checkString(rs1.getString("c_desc_pending"),""));
    	String i_seq = doString.checkString(rs1.getString("i_seq"),"");
    	String i_date = DateUtil.ifxToThaiDateNoTime(doString.checkString(rs1.getString("i_date"),""));
    	String d_pending = DateUtil.ifxToThaiDateNoTime(doString.checkString(rs1.getString("d_pending"),""));
    	String i_employ = doString.checkString(rs1.getString("i_employ"),"");
    	String f_status = doString.checkString(rs1.getString("f_status"),"");
    	if("CAN".equals(f_status)){
    		f_status = "(cancel)";
    	}else{
    		f_status = "";
    	}
    	
    	String status = doString.checkString(rs1.getString("f_document"),"");
    	if("INF".equals(status)){
    		status = "Inform Job";
    	}else if("OPN".equals(status)){
    		status = "Open Job";
    	}else if("STK".equals(status)){
    		status = "Start Task";
    	}else{
    		status = "";
    	}
    	
    	String i_pending_type = doString.checkString(rs1.getString("i_pending_type"),"");
    	String n_desc = "";
    	sql.delete(0,sql.length());
    	sql.append(" select n_desc from lan:serv_xstd where i_type = '77' and i_code = '"+i_pending_type+"' ");
    	rs2 = stmt2.executeQuery(sql.toString());
    	while(rs2.next()){
    		n_desc =  doString.DisplayThai(doString.checkString(rs2.getString("n_desc"),""));
    	}
    	rs2.close();
	%>
	    <tr class="hidden-class">
		  <td class="dotline01">&nbsp;</td>
		  <td colspan="<%=inf_col%>" class="dotline ; padding-left01">&nbsp;&nbsp;&nbsp;&nbsp;
		  ครั้งที่ <%=i_seq%>  วันที่ <%=i_date%> สถานะ <%=status+f_status%> สาเหตุการ Pending <%=n_desc%> หมายเหตุ <span style="color:red;text-decoration: underline;font-weight: bold;" ><%=c_desc_pending%></span> วันที่คาดว่าจะเลื่อนไป <span style="color:red;font-weight: bold;" ><%=d_pending%></span> ผู้ Pending <%=doString.DisplayThai(getNEmploy(stmt2,i_employ))%>
		  </td>
	    </tr>
	 <% 
	 	c_desc_pending = null;
    	i_seq = null;
    	i_date = null;
    	d_pending = null;
    	f_status = null;
    	status = null;
    	n_desc = null;
    	i_employ = null;
		} 
	}
	%>
    <tr class="hidden-class">
	  <td class="dotline01">&nbsp;</td>
	  <td colspan="<%=inf_col%>" class="solidline07 ; padding-left01">&nbsp;</td>
    </tr>
<%
	 }//END while rs.next()
	}//End  itmtype
	else{
	   //no data 
	 %>
	 <tr>
		<td colspan="10" class="dotline01">&nbsp; </td>
	 <tr>
	 <tr>
		<td colspan="10" class="dotline01" align="center">&nbsp; *** ไม่มีข้อมูล *** </td>
	 <tr>
	 	 <tr>
		<td colspan="10" class="dotline01">&nbsp; </td>
	 <tr>
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
<br>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
  	<td align="left" >
  		<% if("7.1".equals(itmtype)){ %>
  		<span style="color:red">*</span>&nbsp;&nbsp;วันที่ Complete - วันที่แจ้งซ่อม
  		<% }else{ %>
		<span style="color:red">*</span>&nbsp;&nbsp;วันที่นัดเข้าซ่อม - ปัจจุบัน
		<% } %>
	</td>
</tr>
</table>
<br/>
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">

            </td> 
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="/LHServ/SERV_ReportService.jsp" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
	    System.out.println("ERROR SQL : "+sql.toString());
		System.out.println("ERROR SERV_ReportServiceDetail.jsp : "
		+ e.getMessage());
		e.printStackTrace();
		//throw new ServletException(e.getMessage());
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