<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
 <%!
 private String getNProject(Statement stmt , String i_company , String i_project) throws SQLException{
 	String n_project = "";
 	ResultSet rs = stmt.executeQuery("select n_project from lan:acxprojt where i_company = '"+i_company+"' and i_project = '"+i_project+"' ");
 	if(rs.next()){
 		n_project = doString.checkString(rs.getString("n_project"),"");
 	}
 	rs.close();
 	return n_project;
 }
 private String thaiToDB(String thDate){
 	return (Integer.parseInt(thDate.substring(6,10))-543)+"-"+thDate.substring(3,5)+"-"+thDate.substring(0,2);
 }
 %>
<%
Calendar right = Calendar.getInstance();
int dd = right.get(Calendar.DATE);
int mm = right.get(Calendar.MONTH)+1;
int yy = right.get(Calendar.YEAR);
if(yy < 2400){
	yy += 543;
}
Connection conn= null;
Statement stmt= null;
Statement stmt1= null;
ResultSet rs=null;
ResultSet rs1=null;
StringBuffer sql = new StringBuffer("");

String project = "";
String i_company = "";
String i_project = "";
String n_project = "";
String i_itmno = "";
String d_keyin_beg = "";
String d_keyin_end = "";

String selected = "";
String search = "N";
String sort_col = "default";//default column;

int sum_call = 0;
int sum_cancel = 0;
int sum_open1 = 0;
int sum_open2 = 0;
int sum_notopen1 = 0;
int sum_notopen2 = 0;
int sum_complete = 0;

String all_in_comp = "";
int count_comp = 0;
String comp_star = "";
try{
	if(ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	stmt1 = conn.createStatement();
	
	project  = doString.checkString(request.getParameter("project"),"ALL");
	if(!"".equals(project) && !"ALL".equals(project)){
		i_company = project.substring(0,2);
		i_project = project.substring(2,5);
	}
	i_itmno = doString.checkString(request.getParameter("i_itmno"),"03");	
	search = doString.checkString(request.getParameter("search"),"Y");
	//fix date begin
	d_keyin_beg = doString.checkString(request.getParameter("d_keyin_beg"),"01/10/2556");
	d_keyin_end = doString.checkString(request.getParameter("d_keyin_end"),(dd<10?"0"+dd:""+dd)+"/"+(mm<10?"0"+mm:""+mm)+"/"+yy);
	
	sort_col = doString.checkString(request.getParameter("sort_col"),"default");
 %>
<%@page import="java.text.SimpleDateFormat"%>
<HTML>
<HEAD>
<TITLE>งานซ่อม</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--

function go(){
	var form = document.frmSERV;
	if(form.project.value == ''){
		alert('กรุณาเลือกโครงการ');
		return;
	}
	if(form.d_keyin_beg.value == ''){
		alert('กรุณาระบุช่วงวันที่');
		return;
	}
	if(form.d_keyin_end.value == ''){
		alert('กรุณาระบุช่วงวันที่');
		return;
	}
	form.search.value='Y'
	form.action = '/LHServ/SERV_Follow1.jsp';
	form.submit();
}
function beyond(theComp,theProj,itmtype){
	var form = document.frmSERV;
	form.i_company.value = theComp;
	form.i_project.value = theProj;
	form.itmtype.value = itmtype;
	form.sort_col.value = '';
	form.action = '/LHServ/SERV_BeyondDetails.jsp';
	form.submit();
}
function initPage(){
	//initial page
}
function sortBy(theCol){
	var form = document.frmSERV;
	if(theCol == '0' && theCol == form.sort_col.value){
		form.sort_col.value = 'default';
	}else{
		form.sort_col.value = theCol;
	}
	go();
}	
//-->
</script>


<base target="_self">


</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="initPage()">

<FORM method="POST" name="frmSERV" action="#" >
<input type="hidden" name="search" value="N" />
<input type="hidden" name="itmtype" value="" />
<input type="hidden" name="i_company" value="" />
<input type="hidden" name="i_project" value="" />
<input type="hidden" name="sort_col" value="<%=sort_col%>" />

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center" class="BD">
    

      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ยินดีต้อนรับสู่ระบบบริการหลังการขาย</td>
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
    <td width="12%" height="22" class="item ; dotline01">เลือกโครงการ :</td>
      <td width="40%" height="22" class="item ; dotline01">
	    <select name='project'  class='box' style='width:200px'  >
	    	<option value="">------ กรุณาเลือก ------</option>
	    <% if("ALL".equals(project)){ 
	    	 selected = "selected";
	       }
	    %>
	    	<option value='ALL' <%=selected%>>ทุกโครงการ</option>
	   	<%
	   	sql.delete(0,sql.length());
	   	sql.append(" select com_id from lan:serv_pstaff where proj_id = 'ALL' and user_id = '"+user.getUserID()+"' ");
	   	//System.out.println(sql.toString());
	   	rs = stmt.executeQuery(sql.toString());
	   	while(rs.next()){
	   		++count_comp;
	   		if(count_comp > 1) all_in_comp += ",";
	   		all_in_comp = "'"+doString.checkString(rs.getString("com_id"),"")+"'";
	   	}
	   	rs.close();
	   	
	   	if(count_comp > 0){
	   		sql.delete(0,sql.length());
		   	sql.append(" select distinct a.i_company as com_id , a.i_project as proj_id, a.n_project ")
		   		.append(" from lan:acxprojt a , lan:acsbudgh b ")
		   		.append(" where a.i_company = b.i_company ")
		   		.append(" and a.i_project = b.i_project ")
		   		//.append(" and a.i_company in ("+all_in_comp+") ")
		   		.append(" and b.d_year = '"+yy+"' ")
		   		.append(" and b.i_budg_type in (9) ")
		   		.append(" and b.i_group not in ('05','10','11','12') ")
		   		.append(" order by a.i_company , a.i_project ");
	   	}else{
		   	sql.delete(0,sql.length());
		   	sql.append(" select distinct a.com_id , a.proj_id , b.n_project ")
		   		.append(" from lan:serv_pstaff a , lan:acxprojt b ")
		   		.append(" where a.com_id = b.i_company ")
		   		.append(" and a.proj_id = b.i_project ")
		   		.append(" and a.user_id = '"+user.getUserID()+"'")
		   		.append(" order by a.com_id , a.proj_id ");
		}
	   	//out.println(sql.toString());
	   	rs = stmt.executeQuery(sql.toString());
	   	while(rs.next()){
	   		String tmpComp = doString.checkString(rs.getString("com_id"),"");
	   		String tmpProj = doString.checkString(rs.getString("proj_id"),"");
	   		selected = "";
	   		if(project.equals(tmpComp+tmpProj)){
	   			selected = "selected";
	   		}
	   		if("LH".equals(tmpComp) && "075".equals(tmpProj)){
	   			//Skip
	   		}else{
	   	%>
	   		<option value="<%=tmpComp+tmpProj%>" <%=selected%> ><%=tmpComp+tmpProj%> - <%=doString.DisplayThai(doString.checkString(rs.getString("n_project"),""))%></option>
	   	<%	
	   		}
	   	}
	   	rs.close();
	   		
	   	 %>
	    </select>
    </td>
     
      <td width="8%" class="item ; dotline01">&nbsp;</td>
      <!--  td width="8%" class="item ; dotline01">วันที่แจ้ง :</td>  -->
      <td height="22" class="item ; dotline01">
      <div style="display:none;" >
		<input name="d_keyin_beg" type="text" class="boxC" style="width:80px" value="<%=d_keyin_beg%>" readonly="readonly">&nbsp;&nbsp;<img src="images/i_calendar.gif" width="18" height="18" align="absmiddle"  style="cursor:hand" onClick="MM_openBrWindow('calendar.jsp?dateType=d_keyin_beg','Calendar','width=300,height=250,left=200,top=100')">
		&nbsp; &nbsp; ถึง : &nbsp; &nbsp;       
		<input name="d_keyin_end" type="text" class="boxC" style="width:80px" value="<%=d_keyin_end%>" readonly="readonly">&nbsp;&nbsp;<img src="images/i_calendar.gif" width="18" height="18" align="absmiddle"  style="cursor:hand" onClick="MM_openBrWindow('calendar.jsp?dateType=d_keyin_end','Calendar','width=300,height=250,left=200,top=100')">
	  </div>
		&nbsp;
	</td>     
  </tr>

<tr>
    <td height="22" class="item ; dotline01">
  ประเภท :</td>
    <td height="22" class="item ; dotline01"><select name="i_itmno"  class="box" style="width:200px"  >
      <!--  option value="00" <% if("00".equals(i_itmno)){ %> selected="selected" <% } %>>ALL</option -->
      <option value="03" <% if("03".equals(i_itmno)){ %> selected="selected" <% } %>>Call Center</option>
      <option value="02" <% if("02".equals(i_itmno)){ %> selected="selected" <% } %>>E-Service</option>
      <option value="01" <% if("01".equals(i_itmno)){ %> selected="selected" <% } %>>งานซ่อมบ้าน</option>
      <!-- 
      <option value="04">E-Service</option>
      <option value="05">แนะนำบ้าน</option>
      <option value="06">Checkup Program</option>
       -->
    </select>
&nbsp;&nbsp;<a href="javascript:go()" ><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22" style="cursor:hand"></a></td>
    <td class="item ; dotline01">&nbsp;</td>
    <td height="22" class="item ; dotline01">&nbsp;</td>
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
                <td class="item_tab2" width="300">สรุปรายละเอียดการ Follow Up งานแจ้งซ่อม</td>
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
    <td class="col_name" rowspan="2"><a href="javascript:sortBy('0')" >โครงการ</a></td>
	<td width="10%" rowspan="2" class="col_name"><a href="javascript:sortBy('1')" >Call</a></td>
	<td width="10%" rowspan="2" class="col_name"><a href="javascript:sortBy('2')" >Cancel</a></td>
    <td width="25%" colspan="2" class="col_name">Open-ยังไม่ Start Task</a></td>
    <td width="25%" colspan="2" class="col_name">Inform Job</td>
    <td width="10%" rowspan="2" class="col_name"><a href="javascript:sortBy('5')" >Complete</a></td>
</tr>
<tr>
	<td class="col_name"><a href="javascript:sortBy('3.1')" >ยังไม่ถึงวันนัดซ่อม</a></td>
    <td class="col_name"><a href="javascript:sortBy('3.2')" >เลยวันนัดซ่อมแล้ว</a></td>
    <td class="col_name"><a href="javascript:sortBy('4.1')" >ยังไม่ถึงวันนัดหมาย</a></td>
    <td class="col_name"><a href="javascript:sortBy('4.2')" >เลยวันนัดหมายแล้ว</a></td>
</tr>
<%
out.flush();
int count = 0;
if(!"".equals(project) &&  "Y".equals(search) && !"".equals(i_itmno)){
	if(!"ALL".equals(project)){
		sql.delete(0,sql.length());
		sql.append(" select * from ( ")
			.append(" select count(a.i_docno) as status_call ")
			.append(" from lan:serv_dochd a  ")
			.append(" where 1=1 ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and a.c_desc <> 'Checkup Program' ");
		if("01".equals(i_itmno)){
			sql.append(" and a.i_system is null ");
		}else if("02".equals(i_itmno)){ 
			sql.append(" and a.i_system = 'ESV' ");
		}else if("03".equals(i_itmno)){
			sql.append(" and a.i_system = 'SVC' ");
		}else{
			sql.append(" and (a.i_system is null OR a.i_system IN ('01','SVC')) ");
		}
		sql.append(" ) as a, ( ")
			.append(" select count(a.i_docno) as status_can ")
			.append(" from lan:serv_dochd a ")
			.append(" where 1=1 ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and a.f_status = 'CAN' ")
			.append(" and a.c_desc <> 'Checkup Program' ");
		if("01".equals(i_itmno)){
			sql.append(" and a.i_system is null ");
		}else if("02".equals(i_itmno)){
			sql.append(" and a.i_system = 'ESV' ");
		}else if("03".equals(i_itmno)){
			sql.append(" and a.i_system = 'SVC' ");
		}else{
			sql.append(" and (a.i_system is null OR a.i_system IN ('01','SVC')) ");
		}
		sql.append(" ) as b,( ")
			.append(" select count(distinct a.i_docno) as status_open1 ")
			.append(" from lan:serv_dochd a , lan:serv_docdt b ")
			.append(" where 1=1 ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and a.i_doc_type = 'J' ")
			.append(" and a.f_status = 'OPN' ")
			.append(" and a.i_docno = b.i_docno ")
			.append(" and b.f_itmstatus = '200' ")
			.append(" and a.c_desc <> 'Checkup Program' ")
			.append(" and (a.d_complete_max is null or a.d_complete_max = '') ");
		if("01".equals(i_itmno)){
			sql.append(" and a.i_system is null ")
				.append(" and a.d_appoint >= TODAY ");//d_keyin
		}else if("02".equals(i_itmno)){
			sql.append(" and a.i_system = 'ESV' ")
				.append(" and a.d_appoint >= TODAY ");
		}else if("03".equals(i_itmno)){
			sql.append(" and a.i_system = 'SVC' ")
				.append(" and a.d_appoint >= TODAY ");
		}else{
			sql.append(" and (a.i_system is null OR a.i_system IN ('01','SVC')) ")
				.append(" and a.d_appoint >= TODAY ");
		}
		sql.append(" ) as c1,( ")
			.append(" select count(distinct a.i_docno) as status_open2 ")
			.append(" from lan:serv_dochd a , lan:serv_docdt b ")
			.append(" where 1=1 ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and a.i_doc_type = 'J' ")
			.append(" and a.f_status = 'OPN' ")                             
			.append(" and a.i_docno = b.i_docno ")                                                     
			.append(" and b.f_itmstatus = '200' ")
			.append(" and a.c_desc <> 'Checkup Program' ")
			.append(" and (a.d_complete_max is null or a.d_complete_max = '') ");;
		if("01".equals(i_itmno)){
			sql.append(" and a.i_system is null ")
				.append(" and a.d_appoint < TODAY ");//d_keyin
		}else if("02".equals(i_itmno)){
			sql.append(" and a.i_system = 'ESV' ")
				.append(" and a.d_appoint < TODAY ");
		}else if("03".equals(i_itmno)){
			sql.append(" and a.i_system = 'SVC' ")
				.append(" and a.d_appoint < TODAY ");
		}else{
			sql.append(" and (a.i_system is null OR a.i_system IN ('01','SVC')) ")
				.append(" and a.d_appoint < TODAY ");
		}
		sql.append(" ) as c2,( ");
		if("01".equals(i_itmno)){
			sql.append(" select count(a.i_docno) as status_notopen1 ")
				.append(" from lan:serv_dochd a ")
				.append(" where 1=1 ")
				.append(" and a.i_company = '"+i_company+"' ")
				.append(" and a.i_project = '"+i_project+"' ")
				.append(" and a.i_doc_type = 'I' ")
				.append(" and a.f_status = 'OPN' ")
				//.append(" and (a.d_appoint >= TODAY or a.d_appoint is null ) ")
				//.append(" and (a.d_keyin >= TODAY or a.d_keyin is null ) ")
				.append(" and (a.d_appoint_cust >= TODAY or a.d_appoint_cust is null ) ")
			    .append(" and a.i_system is null ")
				.append(" and a.c_desc <> 'Checkup Program' ");
		}else if("02".equals(i_itmno)){
			sql.append(" select count(a.i_docno) as status_notopen1 ")
				.append(" from lan:serv_dochd a , lan:eser_dochd b ")
				.append(" where 1=1 ")
				.append(" and a.i_docno = b.i_docno ")
				.append(" and a.i_company = '"+i_company+"' ")
				.append(" and a.i_project = '"+i_project+"' ")
				.append(" and a.i_doc_type = 'I' ")
				.append(" and a.f_status = 'OPN' ")
				.append(" and a.c_desc <> 'Checkup Program' ")
				.append(" and a.i_system = 'ESV' ")
				.append(" and (a.d_appoint >= TODAY or a.d_appoint is null ) ");
		}else{
			sql.append(" select count(c.i_docno) as status_notopen1 ")
				.append(" from lan:svc_docdt b , lan:serv_dochd c ")
				.append(" where 1=1 ")
				.append(" and b.i_docno = c.i_docno ")
				.append(" and c.i_company = '"+i_company+"' ")
				.append(" and c.i_project = '"+i_project+"' ")
				.append(" and b.i_itmno = '01' ")
				.append(" and b.i_itmsub = '01' ")
				.append(" and c.i_doc_type = 'I' ")
				.append(" and c.f_status = 'OPN' ")
				.append(" and c.c_desc <> 'Checkup Program' ");
			if("03".equals(i_itmno)){
				sql.append(" and c.i_system = 'SVC' ")
					.append(" and b.d_appoint >= TODAY ");
			}else{
				sql.append(" and (c.i_system is null OR c.i_system IN ('01','SVC') ")
					.append(" and b.d_appoint >= TODAY ");
			}
		}
		sql.append(" ) as d1,( ");
		if("01".equals(i_itmno)){
			sql.append(" select count(a.i_docno) as status_notopen2 ")
				.append(" from lan:serv_dochd a ")
				.append(" where 1=1 ")
				.append(" and a.i_company = '"+i_company+"' ")
				.append(" and a.i_project = '"+i_project+"' ")
				.append(" and a.i_doc_type = 'I' ")
				.append(" and a.f_status = 'OPN' ")
				.append(" and a.d_appoint_cust < TODAY ")
				.append(" and a.c_desc <> 'Checkup Program' ")
			    .append(" and a.i_system is null ");
		}else if("02".equals(i_itmno)){
			sql.append(" select count(a.i_docno) as status_notopen2  ")
				.append(" from lan:serv_dochd a , lan:eser_dochd b ")
				.append(" where 1=1 ")
				.append(" and a.i_docno = b.i_docno ")
				.append(" and a.i_company = '"+i_company+"' ")
				.append(" and a.i_project = '"+i_project+"' ")
				.append(" and a.i_doc_type = 'I' ")
				.append(" and a.f_status = 'OPN' ")
				//.append(" and a.c_desc <> 'Checkup Program' ")
				.append(" and a.i_system = 'ESV' ")
				.append(" and a.d_appoint < TODAY ");
		}else{
			sql.append(" select count(c.i_docno) as status_notopen2 ")
				.append(" from lan:svc_docdt b , lan:serv_dochd c ")
				.append(" where 1=1 ")
				.append(" and b.i_docno = c.i_docno ")
				.append(" and c.i_company = '"+i_company+"' ")
				.append(" and c.i_project = '"+i_project+"' ")
				.append(" and b.i_itmno = '01' ")
				.append(" and b.i_itmsub = '01' ")
				.append(" and c.i_doc_type = 'I' ")
				.append(" and c.f_status = 'OPN' ")
				//.append(" and c.c_desc <> 'Checkup Program' ")
				.append(" and c.i_system is not null ")
				.append(" and b.d_appoint < TODAY ");
			if("03".equals(i_itmno)){
				sql.append(" and c.i_system = 'SVC' ");
			}else{
				sql.append(" and (c.i_system is null OR c.i_system IN ('01','SVC') ");
			}
		}
		sql.append(" ) as d2,( ")
			.append(" select {+ordered,index(lan:serv_dochd dochd_idx17}  count(a.i_docno) as status_complete ")
			.append(" from lan:serv_dochd a ")
			.append(" where 1=1 ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and a.i_doc_type = 'J' ")
			.append(" and a.f_status <> 'CAN' ")
			//.append(" and a.c_desc <> 'Checkup Program' ")
			.append(" and a.i_system is not null ")
			.append(" and a.d_complete_max is not null ");
		if("02".equals(i_itmno)){
			sql.append(" and a.i_system = 'ESV' ");
		}else if("03".equals(i_itmno)){
			sql.append(" and a.i_system = 'SVC' ");
		}else{
			sql.append(" and (a.i_system is null OR a.i_system IN ('01','SVC') ) ");
		}
		sql.append(" ) as e ")
			.append(" where 1=1 ");
	}else {
		sql.delete(0,sql.length());
		sql.append(" select distinct a.i_company , a.i_project , f.n_project , ")
			.append(" nvl(status_call,0) as status_call , nvl(status_can,0) as status_can , nvl(status_open1,0)  as status_open1 , nvl(status_open2,0)  as status_open2 , ")
			.append(" nvl(status_notopen1,0) as status_notopen1 , nvl(status_notopen2,0) as status_notopen2 , nvl(status_complete,0) as status_complete  from ( ")
			.append(" select count(*) as status_call , a.i_company , a.i_project ")
			.append(" from lan:serv_dochd a ")
			.append(" where 1=1 ");
			if("01".equals(i_itmno)){
				sql.append(" and a.i_system is null ")
					.append(" and a.c_desc <> 'Checkup Program' ");
			}else if("02".equals(i_itmno)){
				sql.append(" and a.i_system = 'ESV' ");
			}else if("03".equals(i_itmno)){
				sql.append(" and a.i_system = 'SVC' ");
			}else{
				sql.append(" and (a.i_system IN ('01','SVC') OR ")
					.append(" (a.i_system is null and a.c_desc <> 'Checkup Program' )) ");
			}
		sql.append(" group by a.i_company , a.i_project ")
			.append(" ) as a, OUTER ( ")
			.append(" select count(*) as status_can , a.i_company , a.i_project ")
			.append(" from lan:serv_dochd a ")
			.append(" where 1=1 ")
			.append(" and a.f_status = 'CAN' ");
			if("01".equals(i_itmno)){
				sql.append(" and a.i_system is null ")
					.append(" and a.c_desc <> 'Checkup Program' ");
			}else if("02".equals(i_itmno)){
				sql.append(" and a.i_system = 'ESV' ");
			}else if("03".equals(i_itmno)){
				sql.append(" and a.i_system = 'SVC' ");
			}else{
				sql.append(" and (a.i_system IN ('01','SVC') OR ")
					.append(" (a.i_system is null and a.c_desc <> 'Checkup Program' )) ");
			}
		sql.append(" group by a.i_company , a.i_project ")
			.append(" ) as b, OUTER ( ")
			.append(" select {+ordered,index(lan:serv_dochd dochd_idx17}  count(*) as status_open1 , a.i_company , a.i_project ")
			.append(" from lan:serv_dochd a , lan:serv_docdt b ")
			.append(" where 1=1 ")
			.append(" and a.i_doc_type = 'J' ")
			.append(" and a.f_status = 'OPN' ")                                          
			.append(" and a.i_docno = b.i_docno ")                                                     
			.append(" and b.f_itmstatus = '200' ");
			if("01".equals(i_itmno)){
				sql.append(" and a.i_system is null ")
					.append(" and a.d_appoint >= TODAY ")
					.append(" and a.c_desc <> 'Checkup Program' ");//d_keyin
			}else if("02".equals(i_itmno)){
				sql.append(" and a.i_system = 'ESV' ")
				.append(" and a.d_appoint >= TODAY ");
			}else if("03".equals(i_itmno)){
				sql.append(" and a.i_system = 'SVC' ")
				.append(" and a.d_appoint >= TODAY ");
			}else{
				sql.append(" and a.d_appoint >= TODAY ")
					.append(" and (a.i_system IN ('01','SVC') OR ")
					.append(" (a.i_system is null and a.c_desc <> 'Checkup Program' )) ");
			}
		sql.append(" and a.d_complete_max is null ")
			.append(" group by a.i_company , a.i_project ")
			.append(" ) as c1, OUTER ( ")
			.append(" select {+ordered,index(lan:serv_dochd dochd_idx17}  count(*) as status_open2 , a.i_company , a.i_project ")
			.append(" from lan:serv_dochd a , lan:serv_docdt b ")
			.append(" where 1=1 ")
			.append(" and a.i_doc_type = 'J' ")
			.append(" and a.f_status = 'OPN' ")                                          
			.append(" and a.i_docno = b.i_docno ")                                                     
			.append(" and b.f_itmstatus = '200' ");
			if("01".equals(i_itmno)){
				sql.append(" and a.d_appoint < TODAY ")
					.append(" and a.i_system is null ")
					.append(" and a.c_desc <> 'Checkup Program' ");//d_keyin
			}else if("02".equals(i_itmno)){
				sql.append(" and a.i_system = 'ESV' ")
					.append(" and a.d_appoint < TODAY ");
			}else if("03".equals(i_itmno)){
				sql.append(" and a.i_system = 'SVC' ")
					.append(" and a.d_appoint < TODAY ");
			}else{
				sql.append(" and a.d_appoint >= TODAY ")
					.append(" and (a.i_system IN ('01','SVC') OR ")
					.append(" (a.i_system is null and a.c_desc <> 'Checkup Program' )) ");
			}
		sql.append(" and a.d_complete_max is null ")
			.append(" group by a.i_company , a.i_project ")
			.append(" ) as c2, OUTER( ");
		if("01".equals(i_itmno)){
			sql.append(" select count(*) as status_notopen1 , a.i_company , a.i_project ")
				.append(" from lan:serv_dochd a ")
				.append(" where 1=1 ")
				.append(" and a.i_doc_type = 'I' ")
				.append(" and a.f_status = 'OPN' ")
				.append(" and a.d_appoint_cust >= TODAY ")
			    .append(" and a.i_system is null ")
				.append(" and a.c_desc <> 'Checkup Program' ")
				.append(" group by a.i_company , a.i_project ");
		}else if("02".equals(i_itmno)){
			sql.append(" select count(*) as status_notopen1 , a.i_company , a.i_project ")
				.append(" from lan:serv_dochd a , lan:eser_dochd b ")
				.append(" where 1=1 ")
				.append(" and a.i_docno = b.i_docno ")
				.append(" and a.i_doc_type = 'I' ")
				.append(" and a.f_status = 'OPN' ")
				.append(" and a.i_system = 'ESV' ")
				.append(" and (a.d_appoint >= TODAY or a.d_appoint is null ) ")
				.append(" group by a.i_company , a.i_project ");
		}else{
			sql.append(" select count(*) as status_notopen1 , c.i_company ,c.i_project ")
				.append(" from lan:svc_docdt b , lan:serv_dochd c ")
				.append(" where 1=1 ")
				.append(" and b.i_docno = c.i_docno ")
				.append(" and b.i_itmno = '01' ")
				.append(" and b.i_itmsub = '01' ")
				.append(" and c.i_doc_type = 'I' ")
				.append(" and c.f_status = 'OPN' ")
				.append(" and (b.d_appoint >= TODAY or b.d_appoint is null ) ");
			if("03".equals(i_itmno)){
				sql.append(" and c.i_system = 'SVC' ");
			}else{
				sql.append(" and (c.i_system IN ('01','SVC') OR ( c.i_system is null OR and c.c_desc <> 'Checkup Program')) ");
			}
			sql.append(" group by c.i_company ,c.i_project ");
		}
		sql.append(" ) as d1, OUTER( ");
		if("01".equals(i_itmno)){
			sql.append(" select count(*) as status_notopen2 , a.i_company , a.i_project ")
				.append(" from lan:serv_dochd a ")
				.append(" where 1=1 ")
				.append(" and a.i_doc_type = 'I' ")
				.append(" and a.f_status = 'OPN' ")
				.append(" and a.d_appoint_cust < TODAY ")
			    .append(" and a.i_system is null ")
				.append(" and a.c_desc <> 'Checkup Program' ")
			    .append(" group by a.i_company , a.i_project ");
		}else if("02".equals(i_itmno)){
			sql.append(" select count(*) as status_notopen2 , a.i_company , a.i_project ")
				.append(" from lan:serv_dochd a , lan:eser_dochd b ")
				.append(" where 1=1 ")
				.append(" and a.i_docno = b.i_docno ")
				.append(" and a.i_doc_type = 'I' ")
				.append(" and a.f_status = 'OPN' ")
				.append(" and a.i_system = 'ESV' ")
				.append(" and a.d_appoint < TODAY ")
				.append(" group by a.i_company , a.i_project ");
		}else{
			sql.append(" select count(*) as status_notopen2 , b.i_company , b.i_project ")
				.append(" from lan:svc_docdt a , lan:serv_dochd b ")
				.append(" where 1=1 ")
				.append(" and a.i_docno = b.i_docno ")
				.append(" and a.i_itmno = '01' ")
				.append(" and a.i_itmsub = '01' ")
				.append(" and b.i_doc_type = 'I' ")
				.append(" and b.f_status = 'OPN' ")
				.append(" and a.d_appoint < TODAY ");
			if("03".equals(i_itmno)){
				sql.append(" and b.i_system = 'SVC' ");
			}else{
				sql.append(" and (b.i_system IN ('01','SVC') OR ( b.i_system is null and b.c_desc <> 'Checkup Program')) ");
			}
			sql.append(" group by b.i_company , b.i_project ");
		}
		sql.append(" ) as d2, OUTER( ")
			.append(" select {+ordered,index(lan:serv_dochd dochd_idx17} count(distinct a.i_docno) as status_complete , a.i_company , a.i_project ")
			.append(" from lan:serv_dochd a ")
			.append(" where 1=1 ")
			.append(" and a.i_doc_type = 'J' ")
			.append(" and a.f_status in ('OPN','CLS') ");
			if("01".equals(i_itmno)){
				sql.append(" and a.i_system is null ")
					.append(" and a.c_desc <> 'Checkup Program' ");
			}else if("02".equals(i_itmno)){
				sql.append(" and a.i_system = 'ESV' ");
			}else if("03".equals(i_itmno)){
				sql.append(" and a.i_system = 'SVC' ");
			}else{
				sql.append(" and (a.i_system IN ('01','SVC') OR ")
					.append(" (a.i_system is null and a.c_desc <> 'Checkup Program' )) ");
			}
		sql.append(" and a.d_complete_max is not null ")
			.append(" group by a.i_company , a.i_project ")
			.append(" ) as e, lan:acxprojt f  ");
		if(count_comp > 0){
			sql.append(" , lan:acsbudgh g ");
		}else{
			sql.append(" , lan:serv_pstaff g ");
		}
		sql.append(" where 1=1 ")
			.append(" and a.i_company = b.i_company ")
			.append(" and a.i_project= b.i_project ")
			.append(" and a.i_company = c1.i_company ")
			.append(" and a.i_project= c1.i_project ")
			.append(" and a.i_company = c2.i_company ")
			.append(" and a.i_project= c2.i_project ")
			.append(" and a.i_company = d1.i_company ")
			.append(" and a.i_project= d1.i_project ")
			.append(" and a.i_company = d2.i_company ")
			.append(" and a.i_project= d2.i_project ")
			.append(" and a.i_company = e.i_company ")
			.append(" and a.i_project= e.i_project ")
			.append(" and a.i_company = f.i_company ")
			.append(" and a.i_project= f.i_project ");
		if(count_comp > 0){
			sql.append(" and a.i_company = g.i_company ")
				.append(" and a.i_project = g.i_project ")
		   		//.append(" and a.i_company in ("+all_in_comp+") ")
		   		.append(" and g.d_year = '"+yy+"' ")
		   		.append(" and g.i_budg_type in (9) ")
		   		//.append(" and g.i_group not in ('05','10','11','12') ");
		   		.append(" and g.i_group in ('01','02','03','04','06','07','08','09','99') ");
		}else{
			sql.append(" and a.i_company = g.com_id ")
				.append(" and a.i_project = g.proj_id ")
		   		.append(" and g.user_id = '"+user.getUserID()+"'");
		}	
		if("default".equals(sort_col)){
			sql.append(" order by a.i_company , a.i_project ");
		}
		if("0".equals(sort_col)){
			sql.append(" order by n_project ");
		}
		if("1".equals(sort_col)){
			sql.append(" order by status_call DESC ,  a.i_company , a.i_project ");
		}
		if("2".equals(sort_col)){
			sql.append(" order by status_can DESC , a.i_company , a.i_project ");
		}
		if("3.1".equals(sort_col)){
			sql.append(" order by status_open1 DESC , a.i_company , a.i_project ");
		}
		if("3.2".equals(sort_col)){
			sql.append(" order by status_open2 DESC , a.i_company , a.i_project ");
		}
		if("4.1".equals(sort_col)){
			sql.append(" order by status_notopen1 DESC , a.i_company , a.i_project ");
		}
		if("4.2".equals(sort_col)){
			sql.append(" order by status_notopen2 DESC , a.i_company , a.i_project ");
		}
		if("5".equals(sort_col)){
			sql.append(" order by status_complete DESC ,a.i_company , a.i_project ");
		}
	}
	System.out.println(sql.toString());
	StringBuffer rowData = new StringBuffer();
	rs = stmt.executeQuery(sql.toString());
	while(rs.next()){
		++count;
		comp_star = "&nbsp;&nbsp;&nbsp;&nbsp;";
		if("ALL".equals(project)){
			i_company = doString.checkString(rs.getString("i_company"),"");
			i_project = doString.checkString(rs.getString("i_project"),"");
		}
		if("LH".equals(i_company) && "075".equals(i_project)){
			continue;
		}
		sum_call += rs.getInt("status_call");
		sum_cancel += rs.getInt("status_can");
		sum_open1 += rs.getInt("status_open1");
		sum_open2 += rs.getInt("status_open2");
		sum_notopen1 += rs.getInt("status_notopen1");
		sum_notopen2 += rs.getInt("status_notopen2");
		sum_complete += rs.getInt("status_complete");
		
		sql.delete(0,sql.length());
  		sql.append(" select * from lan:clearjob ")
  			.append(" where i_company = '"+i_company+"' ")
  			.append(" and i_project = '"+i_project+"' ");
 		rs1 = stmt1.executeQuery(sql.toString());
 		if(rs1.next()){
 			comp_star = "&nbsp;&nbsp;<span style=\"color:#0096ff;font-weight:bold;font-size:14px;\">*</span>";
 		}
 		rs1.close();
  			
		rowData.append("<tr>\n")
	    //.append("<td class=\"item ; dotline\" align=\"left\"><img border=\"0\" src=\"images/i_arrow1.gif\" align=\"absmiddle\" width=\"13\" height=\"13\">&nbsp;"+i_company+i_project+" - "+doString.DisplayThai(getNProject(stmt1,i_company,i_project))+comp_star+"</td>\n");
	    .append("<td class=\"item ; dotline\" align=\"left\">"+comp_star+"&nbsp;"+i_company+i_project+" - "+doString.DisplayThai(getNProject(stmt1,i_company,i_project))+"</td>\n");
		
		if(rs.getInt("status_call") > 0){
			rowData.append("<td align=\"center\" class=\"dotline\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',1)\" >"+rs.getInt("status_call")+"</a></td>\n");
		}else{
			rowData.append("<td align=\"center\" class=\"dotline\">"+rs.getInt("status_call")+"</td>\n");
		}
		if(rs.getInt("status_can") > 0){
			rowData.append("<td align=\"center\" class=\"dotline\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',2)\" >"+rs.getInt("status_can")+"</a></td>\n");
		}else{
			rowData.append("<td align=\"center\" class=\"dotline\">"+rs.getInt("status_can")+"</td>\n");
		}
		if(rs.getInt("status_open1") > 0){
			rowData.append("<td align=\"center\" class=\"dotline\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',3.1)\" >"+rs.getInt("status_open1")+"</a></td>\n");
		}else{
			rowData.append("<td align=\"center\" class=\"dotline\">"+rs.getInt("status_open1")+"</td>\n");
		}
		if(rs.getInt("status_open2") > 0){
			rowData.append("<td align=\"center\" class=\"dotline\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',3.2)\" >"+rs.getInt("status_open2")+"</a></td>\n");
		}else{
			rowData.append("<td align=\"center\" class=\"dotline\">"+rs.getInt("status_open2")+"</td>\n");
		}
		if(rs.getInt("status_notopen1") > 0){
			rowData.append("<td align=\"center\" class=\"dotline\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',4.1)\" >"+rs.getInt("status_notopen1")+"</a></td>\n");
		}else{
			rowData.append("<td align=\"center\" class=\"dotline\">"+rs.getInt("status_notopen1")+"</td>\n");
		}
		if(rs.getInt("status_notopen2") > 0){
			rowData.append("<td align=\"center\" class=\"dotline\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',4.2)\" >"+rs.getInt("status_notopen2")+"</a></td>\n");
		}else{
			rowData.append("<td align=\"center\" class=\"dotline\">"+rs.getInt("status_notopen2")+"</td>\n");
		}
		if(rs.getInt("status_complete") > 0){
			rowData.append("<td align=\"center\" class=\"dotline\"><a href=\"javascript:beyond('"+i_company+"','"+i_project+"',5)\" >"+rs.getInt("status_complete")+"</a></td>\n");
		}else{
			rowData.append("<td align=\"center\" class=\"dotline\">"+rs.getInt("status_complete")+"</td>\n");
		}
		rowData.append("</tr>\n");
	}
	rs.close();
	
	
	
	if(count != 0){
 %>
 	<tr>
	    <td class="item ; dotline" align="left">&nbsp;&nbsp;&nbsp;&nbsp;<u><b>Total</b></u></td>
		<td align="center" class="dotline"><u><b><%=doString.displayNumber("#,###",sum_call+0.0d)%></b></u></td>
		<td align="center" class="dotline"><u><b><%=doString.displayNumber("#,###",sum_cancel+0.0d)%></b></u></td>
	    <td align="center" class="dotline"><u><b><%=doString.displayNumber("#,###",sum_open1+0.0d)%></b></u></td>
	    <td align="center" class="dotline"><u><b><%=doString.displayNumber("#,###",sum_open2+0.0d)%></b></u></td>
	    <td align="center" class="dotline"><u><b><%=doString.displayNumber("#,###",sum_notopen1+0.0d)%></b></u></td>
	    <td align="center" class="dotline"><u><b><%=doString.displayNumber("#,###",sum_notopen2+0.0d)%></b></u></td>
	    <td align="center" class="dotline"><u><b><%=doString.displayNumber("#,###",sum_complete+0.0d)%></b></u></td>
	</tr> 
	<%=rowData.toString()%>
	<tr>
	    <td class="item ; dotline" align="left">&nbsp;&nbsp;&nbsp;&nbsp;<u><b>Total</b></u></td>
		<td align="center" class="dotline"><u><b><%=doString.displayNumber("#,###",sum_call+0.0d)%></b></u></td>
		<td align="center" class="dotline"><u><b><%=doString.displayNumber("#,###",sum_cancel+0.0d)%></b></u></td>
	    <td align="center" class="dotline"><u><b><%=doString.displayNumber("#,###",sum_open1+0.0d)%></b></u></td>
	    <td align="center" class="dotline"><u><b><%=doString.displayNumber("#,###",sum_open2+0.0d)%></b></u></td>
	    <td align="center" class="dotline"><u><b><%=doString.displayNumber("#,###",sum_notopen1+0.0d)%></b></u></td>
	    <td align="center" class="dotline"><u><b><%=doString.displayNumber("#,###",sum_notopen2+0.0d)%></b></u></td>
	    <td align="center" class="dotline"><u><b><%=doString.displayNumber("#,###",sum_complete+0.0d)%></b></u></td>
	</tr> 
<% 
	}
}
if(count ==0){  %>
  <tr>
    <td class="item ; dotline" align="left">&nbsp;</td>
	<td align="center" class="dotline">&nbsp;</td>
	<td align="center" class="dotline">&nbsp;</td>
    <td align="center" class="dotline">&nbsp;</td>
    <td align="center" class="dotline">&nbsp;</td>
    <td align="center" class="dotline">&nbsp;</td>
  </tr>
  <tr>
    <td class="item ; dotline" align="center" colspan="6" >ไม่พบข้อมูล</td>
  </tr> 
<% } %>
  <tr>
    <td align="left" class="item ; dotline">&nbsp;</td>
    <td align="center" class="dotline">&nbsp;</td>
    <td align="center" class="dotline">&nbsp;</td>
    <td align="center" class="dotline">&nbsp;</td>
    <td align="center" class="dotline">&nbsp;</td>
    <td align="center" class="dotline">&nbsp;</td>
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

        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1">&nbsp;</td>
            <td width="250" class="act_tab2">
				&nbsp;&nbsp;&nbsp;<span style=\"color:#0096ff;font-weight:bold;font-size:14px;\">*</span>&nbsp;&nbsp;<span style="color:#ff6400;">โครงการที่เคลียร์ข้อมูลเรียบร้อยแล้ว</span>
            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:history.back()" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
	stmt1.close();
	conn.close();
	stmt=null;
	stmt1=null;
	conn=null;
} catch (Exception e) {
	System.out.println("ERROR SERV_Follow1.jsp : " + sql.toString());
	System.out.println("ERROR SERV_Follow1.jsp : " + e.getMessage());
	throw new ServletException(e.getMessage());
} finally {
	// Clean up.
	try {
		if (rs != null) rs.close();
		if (stmt != null) stmt.close();
		if (stmt1 != null) stmt1.close();
		if (conn != null) conn.close();
	}
	catch( SQLException ignore ){}
}
%>
