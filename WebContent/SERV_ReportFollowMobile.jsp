<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.*" %>
<%@page import="serv.common.*" %>
<%@page import="serv.util.ServLog" %>
<%-- @include file="confirmLogin.jsp" --%>
<%@include file="function.jsp" %> 
<%
Calendar right = Calendar.getInstance();
int dd = right.get(Calendar.DATE);
int mm = right.get(Calendar.MONTH) + 1;
int yy = right.get(Calendar.YEAR);
if (yy < 2400) {
	yy += 543;
}
String currentDate = (dd < 10?"0"+dd:""+dd)+ "/" + (mm <10?"0"+mm:""+mm) + "/" + yy;
Connection conn = null;
Statement stmt = null;
Statement stmt1 = null;
Statement stmt2 = null;
ResultSet rs = null;
ResultSet rs1 = null;
ResultSet rs2 = null;
StringBuffer sql = new StringBuffer("");

String zone = "";
String brand = "";
int sum_starttask1 = 0;
int sum_starttask2 = 0;
int sum_pending_starttask = 0;
int sum_open1 = 0;
int sum_open2 = 0;
int sum_pending_open = 0;
int sum_notopen1 = 0;
int sum_notopen2 = 0;
int sum_notopen2x = 0;
int sum_pending_notopen = 0;

String header = doString.checkString(request.getParameter("header"),"N");
try{
	if(ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	stmt1 = conn.createStatement();

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
.append(" from lan:acsbudgh a , lan:acxprojt b , lan:serv_lstaff d ")
.append(" where 1=1 ")
.append(" and a.i_company = b.i_company ")
.append(" and a.i_project = b.i_project ")
.append(" and a.i_company = d.i_company ")
.append(" and a.i_project = d.i_project ")
.append(" and (d.i_zone is not null and d.i_zone <> '') ")
.append(" and a.d_year = '"+yy+"' ")
.append(" and a.i_budg_type in (9) ")
//.append(" and a.i_group not in ('05','10','11','12') ")
//.append(" and a.i_group not in ('10','11','12') ")
.append(" and a.i_group not in ('10','12') ")
.append(" ) as g, OUTER ( ")
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
.append(" group by g.i_zone ")
.append(" order by g.i_zone ");
System.out.println(sql.toString());
 %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv=Content-Type content="text/html; charset=TIS-620">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<link rel="stylesheet" href="SERV_Report_Style.css" type="text/css">
<style type="text/css">
/* -------------------------------------*/ 
body {margin: 0; padding: 0; min-width: 100%!important;}
/*span { color:#ffffff; font-weight:bold; padding:0px 5px 0px 5px; background-color:#F03F34; } */
.content {width: 100%; max-width: 600px;} 
 /*.header {padding: 40px 30px 20px 30px;}*/
.header {padding: 0px 30px 0px 30px;}
.subhead {font-size: 15px; font-weight:bold; color: #153643; font-family: sans-serif; }
.h1 {font-size: 33px; line-height: 38px; font-weight: bold;}
.h1, .h2, .bodycopy {color: #153643; font-family: sans-serif;}
     	
.innerpadding {padding: 30px}
.borderbottom {border-bottom: 1px solid #f2eeed;}
.h2 {padding:10px 5px 5px 5px; font-size: 15px; line-height: 28px; font-weight: bold;}
.bodycopy {font-size: 14px; line-height: 20px;}

.button {text-align: center; font-size: 18px; font-family: sans-serif; font-weight: bold; padding: 0 30px 0 30px;}
.button a {color: #ffffff; text-decoration: none;}

.footer {padding: 20px 30px 15px 30px;}
.footercopy {font-family: sans-serif; font-size: 14px; color: #ffffff;}
.footercopy a {color: #ffffff; text-decoration: underline;}

.col_nameREP{
	font-size:0.8em;
	color: #0032C8; 
	text-align: center ;  
	background-color:#C8DCFF; 
	border-right:1px solid #87B9F7; 
	border-bottom:1px solid #87B9F7; 	
}
 	
.dotlineREP	{
	font-size:0.8em;
	border-bottom:1px dotted #C8C8C8 ; 
	border-right:1px solid #87B9F7; 
	padding:3px ; 
	color:#0050DC;  
}
</style>
<!--[if (gte mso 9)|(IE)]>
<style type="text/css">


</style>
<![endif]-->
<script type="text/javascript" >
//Script
</script>
</head>
<body marginwidth="10" marginheight="10" leftmargin="10" topmargin="10">
<table width="100%" bgcolor="#f6f8f1" border="0" cellpadding="0" cellspacing="0">
    <tr>
        <td>
        <!--[if (gte mso 9)|(IE)]>
<table width="100%" align="center" cellpadding="0" cellspacing="0" border="0">
    <tr>
        <td>
            <![endif]-->
        <table class="content" align="center" cellpadding="0" cellspacing="0" border="0">
            <tr>
                <td class="header" bgcolor="#c7d8a7">
					<!--[if (gte mso 9)|(IE)]>
			           <table width="100%" align="left" cellpadding="0" cellspacing="0" border="0">
			             <tr>
			               <td>
				          <![endif]-->
				          <table class="col425" align="left" border="0" cellpadding="0" cellspacing="0" style="width: 100%; max-width: 425px;">  
				            <tr>
				              <td height="70">
				                <table width="100%" border="0" cellspacing="0" cellpadding="0">
				                  <tr>
				                    <td class="subhead" style="padding: 0 0 0 3px;">
				                 สรุปรายงานซ่อมหลังโอน ณ วันที่ <%=currentDate%> 
				                    </td>
				                  </tr>
				                </table>
				              </td>
				            </tr>
				          </table>
				          <!--[if (gte mso 9)|(IE)]>
			               </td>
			             </tr>
			         </table>
			       <![endif]-->
				</td>
            </tr>
         <tr>
    <td class="borderbottom" style="padding: 20px">
    
<%  
	rs = stmt.executeQuery(sql.toString());
	while(rs.next()){
		zone = doString.checkString(rs.getString("i_zone"),"0") ;
		brand = "";
		
		sql.delete(0,sql.length());
		sql.append(" select i_code , n_desc from lan:serv_xstd ")
			.append(" where i_type = '20' ")
			.append(" and i_code = '"+zone+"' ");
		System.out.println(sql.toString());
		rs1 = stmt1.executeQuery(sql.toString());
		if(rs1.next()){
			if("99".equals(zone)){
				brand = "โครงการปิด - " + doString.DisplayThai(doString.checkString(rs1.getString("n_desc"),""));
			}else{
				brand = doString.DisplayThai(doString.checkString(rs1.getString("n_desc"),"")); 
			}
		}
		rs1.close();
			
		sum_starttask1 += rs.getInt("status_starttask1");
		sum_starttask2 += rs.getInt("status_starttask2");
		sum_pending_starttask += rs.getInt("pending_starttask");
		sum_open1 += rs.getInt("status_open1");
		sum_open2 += rs.getInt("status_open2");
		sum_pending_open += rs.getInt("pending_open");
		sum_notopen1 += rs.getInt("status_notopen1");
		sum_notopen2 += rs.getInt("status_notopen2");
		sum_notopen2x += rs.getInt("status_notopen2x");
		sum_pending_notopen += rs.getInt("pending_notopen");
		
 %>
    <!--[if (gte mso 9)]>
    <table width="265px" align="left" border="0" cellspacing="0" cellpadding="0" style="margin-left:2px;" >
    	<tr>
    		<td>
    <![endif]-->
    <table align="left" border="0" cellspacing="0" cellpadding="0" style="margin-top:2px; width:100%; max-width:278px;">
    	<tr>
    		<td>
    			<span style="color:#ffffff; font-weight:bold; padding:0px 5px 0px 5px; background-color:#F03F34; ">Zone <%=Integer.parseInt(zone)%> - <%=brand%></span>
    		</td>
    	</tr>
		<tr>
			<td>
				<table border="0" cellspacing="0" cellpadding="0" style="width:100%; max-width:265px; border-left:1px solid #87B9F7 ; border-top:1px solid #87B9F7 ; border-bottom:1px solid #87B9F7;">		
				    <tr>
				      <td width="40%" class="col_nameREP" bgcolor="#C8DCFF" style="font-size:0.8em; color: #0032C8; text-align: center ; background-color:#C8DCFF; border-right:1px solid #87B9F7; border-bottom:1px solid #87B9F7; font-weight:bold;">Activity</th>
				      <td width="20%" class="col_nameREP" bgcolor="#C8DCFF" style="font-size:0.8em; color: #0032C8; text-align: center ; background-color:#C8DCFF; border-right:1px solid #87B9F7; border-bottom:1px solid #87B9F7; font-weight:bold;">ยังไม่<br/>เลย<br/>กำหนด</th>
				      <td width="20%" class="col_nameREP" colspan="2" bgcolor="#C8DCFF" style="font-size:0.8em; color: #0032C8; text-align: center ; background-color:#C8DCFF; border-right:1px solid #87B9F7; border-bottom:1px solid #87B9F7; font-weight:bold;">เลย<br/>กำหนด</th>
				      <td width="20%" class="col_nameREP" bgcolor="#C8DCFF" style="font-size:0.8em; color: #0032C8; text-align: center ; background-color:#C8DCFF; border-right:1px solid #87B9F7; border-bottom:1px solid #87B9F7; font-weight:bold;">Pending</th>
				    </tr>
				    <tr>
				      <td class="dotlineREP" style="font-size:0.8em; border-bottom:1px dotted #C8C8C8 ;  border-right:1px solid #87B9F7; padding:3px ; color:#0050DC; ">Inform</td>
				      <td align="center" class="dotlineREP" style="padding-right:25px; font-size:0.8em; border-bottom:1px dotted #C8C8C8 ;  border-right:1px solid #87B9F7; padding:3px ; color:#0050DC; "><%=doString.checkString(rs.getString("status_notopen1"),"0")%></td>
				      <% if(rs.getInt("status_notopen2x") == rs.getInt("status_notopen2")){  %>
				      <td align="center" colspan="2" class="dotlineREP" style="padding-right:25px; font-size:0.8em; border-bottom:1px dotted #C8C8C8 ;  border-right:1px solid #87B9F7; padding:3px ; color:#0050DC; "><%=doString.checkString(rs.getString("status_notopen2x"),"0")%></td>
				      <% }else{ %>
				      <td align="right" class="dotline01" style="text-align:right; font-size:0.8em; border-bottom:1px dotted #C8C8C8 ;  color:#0050DC; "><%=doString.checkString(rs.getString("status_notopen2x"),"0")%></td>
				      <td class="dotlineREP" style="text-align:left; font-size:0.8em; border-bottom:1px dotted #C8C8C8 ;  border-right:1px solid #87B9F7; color:#0050DC; padding: 0px;"><%=" ("+ doString.checkString(rs.getString("status_notopen2"),"0")+")"%></td>
				      <% } %>
				      <td align="center" class="dotlineREP" style="padding-right:25px; font-size:0.8em; border-bottom:1px dotted #C8C8C8 ;  border-right:1px solid #87B9F7; padding:3px ; color:#0050DC; "><%=doString.checkString(rs.getString("pending_notopen"),"0")%></td>
				    </tr>
				    <tr>
				      <td class="dotlineREP" style="font-size:0.8em; border-bottom:1px dotted #C8C8C8 ;  border-right:1px solid #87B9F7; padding:3px ; color:#0050DC; ">Open</td>
				      <td align="center" class="dotlineREP" style="padding-right:25px; font-size:0.8em; border-bottom:1px dotted #C8C8C8 ;  border-right:1px solid #87B9F7; padding:3px ; color:#0050DC; "><%=doString.checkString(rs.getString("status_open1"),"0")%></td>
				      <td align="center" colspan="2" class="dotlineREP" style="padding-right:25px; font-size:0.8em; border-bottom:1px dotted #C8C8C8 ;  border-right:1px solid #87B9F7; padding:3px ; color:#0050DC; "><%=doString.checkString(rs.getString("status_open2"),"0")%></td>
				      <td align="center" class="dotlineREP" style="padding-right:25px; font-size:0.8em; border-bottom:1px dotted #C8C8C8 ;  border-right:1px solid #87B9F7; padding:3px ; color:#0050DC; "><%=doString.checkString(rs.getString("pending_open"),"0")%></td>
				    </tr>
				    <tr>
				      <td class="dotlineREP" style="font-size:0.8em; border-bottom:1px dotted #C8C8C8 ;  border-right:1px solid #87B9F7; padding:3px ; color:#0050DC; ">Start Task</td>
				      <td align="center" class="dotlineREP" style="padding-right:25px; font-size:0.8em; border-bottom:1px dotted #C8C8C8 ;  border-right:1px solid #87B9F7; padding:3px ; color:#0050DC; "><%=doString.checkString(rs.getString("status_starttask1"),"0")%></td>
				      <td align="center" colspan="2" class="dotlineREP" style="padding-right:25px; font-size:0.8em; border-bottom:1px dotted #C8C8C8 ;  border-right:1px solid #87B9F7; padding:3px ; color:#0050DC; "><%=doString.checkString(rs.getString("status_starttask2"),"0")%></td>
				      <td align="center" class="dotlineREP" style="padding-right:25px; font-size:0.8em; border-bottom:1px dotted #C8C8C8 ;  border-right:1px solid #87B9F7; padding:3px ; color:#0050DC; "><%=doString.checkString(rs.getString("pending_starttask"),"0")%></td>
				    </tr>
		 		</td>
		 	</tr>
		 </table>
	</table> 
	<!--[if (gte mso 9)]>
           </td>
         </tr>
     </table>
   <![endif]-->
   
<%  }
	rs.close();
 %>
			        
			    </td>
			</tr>
<% if(!"Y".equals(header)){ %>
			<tr>
                <td class="header" >
					<!--[if (gte mso 9)|(IE)]>
			           <table width="100%" align="left" cellpadding="0" cellspacing="0" border="0">
			             <tr>
			               <td>
				          <![endif]-->
				          <table class="col425" align="left" border="0" cellpadding="0" cellspacing="0" style="width: 100%; max-width: 425px;">  
				            <tr>
				              <td height="70">
				               <table width="100%" border="0" cellspacing="0" cellpadding="0">
						            <tr>
						                <td class="h2">
						                    Follow Service Email Report
						                </td>
						            </tr>
						            <tr>
						                <td class="bodycopy">
						                    If you want view detail for more information report. Please visit the link below.
						                    <a href="http://132.146.1.126/LHServ/login.jsp?main=SERV_ReportServiceByZone.jsp" >http://132.146.1.126/LHServ/login.jsp</a>
						                </td>
						            </tr>
						        </table>
				              </td>
				            </tr>
				          </table>
				          <!--[if (gte mso 9)|(IE)]>
			               </td>
			             </tr>
			         </table>
			       <![endif]-->
				</td>
            </tr>
</table>
        <!--[if (gte mso 9)|(IE)]>
        </td>
    </tr>
</table>
<![endif]-->
        </td>
    </tr>
</table>
</body>
</html>
<% } %>
<%		
		stmt.close();
		stmt1.close();
		conn.close();
		stmt = null;
		rs = null;
		stmt1 = null;
		rs1 = null;
		conn = null;
} catch (Exception e) {
	System.out.println("ERROR SERV_ReportFollowMobile.jsp : " + e.getMessage()); 
	throw new ServletException(e.getMessage());
} finally {
	// Clean up.
	try {
		if (rs != null) rs.close();
		if (stmt != null) stmt.close();
		if (rs1 != null) rs.close();
		if (stmt1 != null) stmt.close();
		if (conn != null) conn.close();
		stmt = null;
		rs = null;
		conn = null;
	} catch (SQLException ignore) {
	}
}
%>