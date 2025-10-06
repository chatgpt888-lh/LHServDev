<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>

<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>


<%
doString str = new doString();

Calendar current = Calendar.getInstance();
int thYear = current.get(Calendar.YEAR);
if(thYear<2400){
	thYear += 543;
}

//----=================== Get data from parameter =======================----//

StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
Statement stmt1 = null;
ResultSet rs = null;
ResultSet rs1 = null;
PreparedStatement prep = null;
PreparedStatement prep1 = null;

String i_company = "";
String i_project = "";

String grp_no = "";
String grp_name = "";
String project = "";
String n_project = "";
String datepick = "";	
String datepick1 = "";	
String i_house = "";	
String i_sort = "";	


String ven_no = "";
String i_type = "";
String i_due = "";
String s_warranty = "";
String unit_warranty = "";
String c_desc = "";

String order_by = "";

String house_transfer = "";

int pageNo = 1;
int rowPerPage = 40;

try {
	
    //----============ Initialize Variable ============----//
	if (ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();        
	stmt1 = conn.createStatement();       
       //----=======================================----//
       
    pageNo = Integer.parseInt(doString.checkString(request.getParameter("pageNo"),"1"));
	
	grp_no = doString.checkString(request.getParameter("grp_no"),"");
	project = doString.checkString(request.getParameter("project"),"");
	order_by = doString.checkString(request.getParameter("order_by"),"");
	i_house = doString.checkString(request.getParameter("i_house"),"");
	i_sort = doString.checkString(request.getParameter("i_sort"),"");
	house_transfer  = doString.checkString(request.getParameter("house_transfer"),"N");
	
	if(!"".equals(project)){
		i_company = project.substring(0,2);
		i_project = project.substring(2,5);
		
		sql.delete(0,sql.length());
		sql.append(" select n_project from lan:acxprojt where i_company =  ?  and i_project = ? ");
		prep = conn.prepareStatement(sql.toString());
		prep.setString(1,i_company);
		prep.setString(2,i_project);
		rs = prep.executeQuery();
		if(rs.next()){
			n_project = doString.DisplayThai(rs.getString("n_project"));
		}
		rs.close();
		prep.close();
	}
	
	String beg_month = doString.checkString(request.getParameter("beg_month"));
	String beg_year = doString.checkString(request.getParameter("beg_year"));
	String end_month = doString.checkString(request.getParameter("end_month"));
	String end_year = doString.checkString(request.getParameter("end_year"));
	
	/*
	if (!"".equals(beg_month) && !"".equals(beg_year)) {
		datepick = tmpBegMonth+"-"+tmpBegYear;
	}
	if (!"".equals(end_month) && !"".equals(end_year)) {
		datepick1 = tmpEndMonth+"-"+tmpEndYear;
	}
	*/

	if(!"".equals(grp_no)){

		sql.delete(0,sql.length());
		sql.append(" select grp_desc from lan:itmgrp where grp_no =  ? ");
		prep = conn.prepareStatement(sql.toString());
		prep.setString(1,grp_no);
		rs = prep.executeQuery();
		if(rs.next()){
			grp_name = doString.DisplayThai(rs.getString("grp_desc"));
		}
		rs.close();
		prep.close();
	}
%>

<HTML>
	<HEAD>
		<TITLE>รายงานวันหมดอายุประกันวัสดุ</TITLE>
		<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
		<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
		<link rel="stylesheet" href="<%=request.getContextPath()%>/js/font-awesome-4.7.0/css/font-awesome.css"  type="text/css">
		<style type="text/css" >
		button {
		    padding: 2px 3px;
		    font-size: x-small;
		    background-color: #ffffff;
		    border: 1px #ccc solid;
		    border-radius: 2px;
		    cursor: pointer;
		}
		</style>
		<script language="javascript">
		<!--
		function doGo(){
			var form = document.frmServ;
			form.pageNo.value = '1';
			if(doValidate()){
				form.action = '<%=request.getContextPath()%>/SERV_ReportItmWarranty.jsp';
				form.submit();
			}
		}
		function doValidate(){
			var form = document.frmServ;
			if(form.project.value == '' ){
				alert('กรุณาระบุโครงการ');
				return false;
			}
			if(form.beg_month.value != '' || form.beg_year.value != '' || form.end_month.value != '' || form.end_year.value != ''){
				if(form.beg_month.value == '' || form.beg_year.value == '' || form.end_month.value == '' || form.end_year.value == ''){
					alert('กรุณาระบุช่วงระยะเวลาที่หมดอายุให้ถูกต้อง');
					return false;
				}
			}
			return true;
		}
		function doPage(page){
			var form = document.frmServ;
			form.pageNo.value = page;
			if(doValidate()){
				form.action = '<%=request.getContextPath()%>/SERV_ReportItmWarranty.jsp';
				form.submit();
			}
		}
		//-->
		</script>

		<base target="_self">
	</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM name="frmServ" method="GET" action="<%=request.getContextPath()%>/SERV_ReportItmWarranty.jsp">
<input type="hidden" name="pageNo" value="<%=pageNo%>" />
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="800" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
           รายงานวันหมดอายุประกันวัสดุ</td>
        </tr>
      </table>
		<br style="font-size:10pt">
        <table border="0" width="800" cellspacing="0" cellpadding="0">
          <tr>
            <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
            <td class="item_tab2" width="250">ค้นหา</td>
            <td class="item_tab3"></td>
            <td>&nbsp;</td>
          </tr>
        </table>            


<table border="0" width="800" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop">&nbsp;</td>
    <td width="5" valign="top" align="right"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>

<table border="0" width="800" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR" align="center">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td class="item ; dotline01" height="22" width="12%" colspan="2">โครงการ :</td>
    <td height="22" width="43%" class="dotline01">
     	<select name="project" class='box' style='width:220px' >
	    	<OPTION value="" >---เลือกโครงการ---</OPTION>
     	<% 
     	String tmpProj = "";
     	String tmpComp = "";
     	sql.delete(0,sql.length());
     	sql.append(" select distinct a.i_company , a.i_project , a.n_project from lan:acxprojt a , lan:acsbudgh b ")
     		.append(" where a.i_company = b.i_company ")
     		.append(" and a.i_project = b.i_project ")
     		.append(" and b.d_year = '"+thYear+"' ")
     		.append(" and b.i_budg_type = 9 ")
     		.append(" order by 1,2 ");
     	rs = stmt.executeQuery(sql.toString());
     	while(rs.next()){
     		tmpComp = doString.checkString(rs.getString("i_company"),"");
     		tmpProj = doString.checkString(rs.getString("i_project"),"");
     	%>
     		<option value="<%=tmpComp+tmpProj%>" <% if(project.equals(tmpComp+tmpProj)){ %> selected <% } %> ><%=tmpComp+tmpProj + " - " +doString.DisplayThai(doString.checkString(rs.getString("n_project"),""))%></option>
     	<% 
     	}
     	rs.close();
     	%>
     	</select>
    </td>
    <td height="22" class="item ; dotline01" width="10%">บ้านเลขที่ :</td>
    <td height="22" width="35%" class="dotline01">
	    <input type="text" name='i_house' class='box' value="<%=i_house%>" style='width:80px;text-align:center' />
     </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="12%" colspan="2">รหัสวัสดุ :</td>
    <td height="22" width="43%" class="dotline01">
     	<select name="grp_no" class='box'  >
	    	<OPTION value="" >---เลือกวัสดุ---</OPTION>
     	<% 
     	String tmpGrpNo = "";
     	sql.delete(0,sql.length());
     	sql.append(" select distinct a.grp_no , b.grp_desc from lan:itmwarranty a , lan:itmgrp b ")
     		.append(" where a.grp_no = b.grp_no ")
     		.append(" order by 1 ");
     	rs = stmt.executeQuery(sql.toString());
     	while(rs.next()){
     		tmpGrpNo = doString.checkString(rs.getString("grp_no"),"");
     	%>
     		<option value="<%=tmpGrpNo%>" <% if(grp_no.equals(tmpGrpNo)){ %> selected <% } %> ><%=tmpGrpNo + " - " +doString.DisplayThai(doString.checkString(rs.getString("grp_desc"),""))%></option>
     	<% 
     	}
     	rs.close();
     	%>
     	</select>
    </td>
    <td height="22" class="item ; dotline01" width="10%">แปลง :</td>
    <td height="22" width="35%" class="dotline01">
	    <input type="text" name='i_sort' class='box' value="<%=i_sort%>" style='width:80px;text-align:center' />
     </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="12%" colspan="2">ช่วงวันที่หมดอายุ :</td>
    <td height="22" width="43%" class="dotline01">
	    <select name="beg_month" class='box' style='width:70px' >
	    	<OPTION value="" >---เดือน---</OPTION>
	    	<OPTION value="01" <% if("01".equals(beg_month)){ %> selected  <% } %> >มกราคม</OPTION>
            <OPTION value="02" <% if("02".equals(beg_month)){ %> selected  <% } %> >กุมภาพันธ์</OPTION>
            <OPTION value="03" <% if("03".equals(beg_month)){ %> selected  <% } %> >มีนาคม</OPTION>
            <OPTION value="04" <% if("04".equals(beg_month)){ %> selected  <% } %> >เมษายน</OPTION>
            <OPTION value="05" <% if("05".equals(beg_month)){ %> selected  <% } %> >พฤษภาคม</OPTION>
            <OPTION value="06" <% if("06".equals(beg_month)){ %> selected  <% } %> >มิถุนายน</OPTION>
            <OPTION value="07" <% if("07".equals(beg_month)){ %> selected  <% } %> >กรกฎาคม</OPTION>
            <OPTION value="08" <% if("08".equals(beg_month)){ %> selected  <% } %> >สิงหาคม</OPTION>
            <OPTION value="09" <% if("09".equals(beg_month)){ %> selected  <% } %> >กันยายน</OPTION>
            <OPTION value="10" <% if("10".equals(beg_month)){ %> selected  <% } %> >ตุลาคม</OPTION>
            <OPTION value="11" <% if("11".equals(beg_month)){ %> selected  <% } %> >พฤศจิกายน</OPTION>
            <OPTION value="12" <% if("12".equals(beg_month)){ %> selected  <% } %> >ธันวาคม</OPTION>
	    </select>
	    <select name="beg_year" class='box' style='width:50px' >
	    	<OPTION value="" >---ปี---</OPTION>
	    <%
	    int tmpBegYear = thYear-3;
	    for(int i =0 ; i< 10 ; i++){
	     %>
	    	<option value="<%=((tmpBegYear-543)+i)%>"  <% if(beg_year.equals(String.valueOf((tmpBegYear-543)+i))){ %> selected  <% } %>><%=(tmpBegYear+i)%></option>
	    <% } %>
	    </select>
	    &nbsp;<span class="item">ถึง</span>&nbsp;
	    <select name="end_month" class='box' style='width:70px' >
	    	<OPTION value="" >---เดือน---</OPTION>
	    	<OPTION value="01" <% if("01".equals(end_month)){ %> selected  <% } %> >มกราคม</OPTION>
            <OPTION value="02" <% if("02".equals(end_month)){ %> selected  <% } %> >กุมภาพันธ์</OPTION>
            <OPTION value="03" <% if("03".equals(end_month)){ %> selected  <% } %> >มีนาคม</OPTION>
            <OPTION value="04" <% if("04".equals(end_month)){ %> selected  <% } %> >เมษายน</OPTION>
            <OPTION value="05" <% if("05".equals(end_month)){ %> selected  <% } %> >พฤษภาคม</OPTION>
            <OPTION value="06" <% if("06".equals(end_month)){ %> selected  <% } %> >มิถุนายน</OPTION>
            <OPTION value="07" <% if("07".equals(end_month)){ %> selected  <% } %> >กรกฎาคม</OPTION>
            <OPTION value="08" <% if("08".equals(end_month)){ %> selected  <% } %> >สิงหาคม</OPTION>
            <OPTION value="09" <% if("09".equals(end_month)){ %> selected  <% } %> >กันยายน</OPTION>
            <OPTION value="10" <% if("10".equals(end_month)){ %> selected  <% } %> >ตุลาคม</OPTION>
            <OPTION value="11" <% if("11".equals(end_month)){ %> selected  <% } %> >พฤศจิกายน</OPTION>
            <OPTION value="12" <% if("12".equals(end_month)){ %> selected  <% } %> >ธันวาคม</OPTION>
	    </select>
	    <select name="end_year" class='box' style='width:50px' >
	    	<OPTION value="" >---ปี---</OPTION>
	    <%
	    int tmpEndYear = thYear-3;
	    for(int i =0 ; i< 10 ; i++){
	     %>
	    	<option value="<%=((tmpEndYear-543)+i)%>"  <% if(end_year.equals(String.valueOf((tmpEndYear-543)+i))){ %> selected  <% } %>><%=(tmpEndYear+i)%></option>
	    <% } %>
	    </select>
    </td>
    <td height="22" class="item ; dotline01" width="10%">การโอน :</td>
    <td height="22" width="35%" class="dotline01">
	    <input type="radio" value="A" id="house_transfer_all" name="house_transfer" <% if("A".equals(house_transfer)) { %> checked="checked" <% } %>> ทั้งหมด&nbsp;
	                                  <input type="radio" value="N" id="house_transfer_not" name="house_transfer" <% if("".equals(house_transfer) || "N".equals(house_transfer)) { %> checked="checked" <% } %>> ยังไม่โอน&nbsp;
	                                  <input type="radio" value="Y" id="house_transfer_yes" name="house_transfer" <% if("Y".equals(house_transfer)) { %> checked="checked" <% } %>> โอนแล้ว
     </td>
  </tr>
  
  <tr>
  	<td height="22" class="item ; dotline01" width="12%" colspan="2">เรียงตาม :</td>
  	<td height="22" width="35%" class="dotline01">
	    <input type="radio" value="lock" id="order_by_lock" name="order_by" <% if("".equals(order_by) || "lock".equals(order_by)) { %> checked="checked" <% } %>> แปลง&nbsp;
        <input type="radio" value="end" id="order_by_end" name="order_by" <% if("end".equals(order_by)) { %> checked="checked" <% } %>> วันสิ้นสุดการรับประกัน&nbsp;
        <!--  <input type="radio" value="group" id="order_by_group" name="order_by" <% if("group".equals(order_by)) { %> checked="checked" <% } %>> รหัสวัสดุ     -->                    
     </td>
    <td class="item ; dotline01" height="22"  ><a href="javascript:doGo()" ><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a>
     </td>
  </tr>
</table>
</td>
  </tr>
</table>

<table border="0" width="800" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>


<br style="font-size:2pt">
<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">รายการ</td>
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
    <td width="100%" class="frmL">
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr style="height:22px;">
          <td class="col_name" >ลำดับ</td>
          <td class="col_name" >วัสดุ</td>
          <td class="col_name" >ร้านค้า</td>
          <td class="col_name" >แปลง</td>
          <td class="col_name" >บ้านเลขที่</td>
          <td class="col_name" >วันที่โอน</td>
          <td class="col_name" >แบบบ้าน</td>
          <td class="col_name" >วันที่เริ่มต้นรับประกัน</td>
          <td class="col_name" >วันสิ้นสุดการรับประกัน</td>
          <td class="col_name" >Note</td>
        </tr>
        <%
              if(!"".equals(project)){
              	int row = rowPerPage*(pageNo-1);
              	
              	int idx = 0;
               	int totalRow = 0;
           		String ven_name = "";
           		String itm_name = "";
           		String d_close_law = "";
           		
           		String grpNoTmp = "";

               	int orderCount = 0;
               	int orderTotal = 0;
               	String tmpWarranty = "";
                String warning_b2 = "";
                String tmp_pob2 = "";
               	
           		sql.delete(0,sql.length());
                		sql.append(" select SKIP "+row+" FIRST  "+rowPerPage+" distinct a.i_company , a.i_project ,  a.grp_no  , a.i_lock , a.i_vendor , a.user_rec_date , b.i_type , b.c_desc  , d.d_close_law, ")
                			.append(" case  ")
                			.append(" 	when b.i_type = 'T' and d.d_close_law is not null then  ")
                			.append(" 		case ")
                			.append(" 			when b.unit_warranty = 'D' then d.d_close_law + b.s_warranty units day ")
                			.append(" 			else d.d_close_law + b.s_warranty units year ")
                			.append(" 		end  ")
                			.append(" 	when b.i_type = 'R' then  ")
                			.append(" 		case ")
                			.append(" 			when b.unit_warranty = 'D' then a.user_rec_date + b.s_warranty units day ")
                			.append(" 			else a.user_rec_date + b.s_warranty units year ")
                			.append(" 		end  ")
                			.append("	when b.i_type = 'S' then  ")
                			.append("		case ")
                			.append("			when b.unit_warranty = 'D' then a.vendor_fsend_date + b.s_warranty units day ")
                			.append("			else a.vendor_fsend_date + b.s_warranty units year ")
                			.append("		end ")
                			.append("	when b.i_type = 'P' then ")
                			.append("		case ")
                			.append("			when b.unit_warranty = 'D' then a.user_confp_date + b.s_warranty units day ")
                			.append("			else a.user_confp_date + b.s_warranty units year ")
                			.append("		end ")
                			.append(" 	else null ")
                			.append(" end as end_warranty , ")
                			.append(" case  ")
                			.append(" 	when a.grp_no = 'B2' and d.d_close_law is not null  then 'Y' else 'N' ")
            				.append(" end as b2_check ")
            				.append(" , c.i_house , c.i_model ");
           		
           		String selectQuery = sql.toString();
           		
           		sql.delete(0,sql.length());
           		sql.append("select count(*) as total from  ( select  a.i_company , a.i_project ,  a.grp_no  , a.i_lock , a.i_vendor ");

           		String countQuery = sql.toString();
           		
           		sql.delete(0,sql.length());
           		sql.append(" from lan:itmwarranty b , ")
	                		.append(" (select * ")
	                		.append(" 		from ")
	                		.append(" 		lan:accpohdr ")
	                		.append(" 	where ")
	                		.append(" 		i_company = ? ")
	                		.append(" 		and i_project = ? ")
	                		.append(" 		and f_status = 'OPN') a , ")
	                		.append(" lan:acxlckmd c , ")
	                		.append(" ( ")
	                		.append(" select ")
	                		.append(" a.i_company , ")
	                		.append(" a.i_project , ")
	                		.append(" a.i_lock , ")
	                		.append(" a.grp_no , ")
	                		.append(" max(a.d_order) as d_order ")
	                		.append(" from ")
	                		.append(" lan:accpohdr a ")
	                		.append(" left join lan:pr_dochd c ")
	                		.append(" on a.i_order = c.po_docno ")
	                		.append(" and a.i_company = c.i_company ")
	                		.append(" and a.i_project = c.i_project ")
	                		.append(" and a.grp_no = c.grp_no ")
	                		.append(" and a.i_lock = c.i_lock , ")
	                		.append(" lan:itmwarranty b ")
	                		.append(" where ")
	                		.append(" a.i_company = ? ")
	                		.append(" and a.i_project = ? ")
	                		.append(" and a.grp_no = b.grp_no ")
	                		.append(" and a.f_status = 'OPN' ")
	                		.append(" and a.po_status not in ('OPN', 'CDPO') ")
	                		.append(" and a.i_vendor = b.i_vendor ")
	                		.append(" and (c.i_pr_type is null or c.i_pr_type = '212') ")
	                		.append(" group by 1, 2, 3, 4 ) x  ")
	                		.append(" left join lan:acscontr d on ")
	                		.append(" x.i_company = d.i_company ")
	                		.append(" and x.i_project = d.i_project ")
	                		.append(" and x.i_lock = d.i_sort ")
	                		.append(" and d.f_contr is null ")
	                		.append(" and d.d_cancl_lor is null ")
	                		//.append(" and d.d_close_law is not null ")
                			.append(" where  ")
                			.append(" x.i_company = a.i_company ")
                			.append(" and x.i_project = a.i_project ")
                			.append(" and x.grp_no = a.grp_no ")
                			.append(" and x.i_lock = a.i_lock ")
                			.append(" and x.d_order = a.d_order ")
                			.append(" and a.grp_no = b.grp_no ")
                			.append(" and a.i_vendor = b.i_vendor ")
                			.append(" and x.i_company = c.i_company ")
                			.append(" and x.i_project = c.i_project ")
                			.append(" and x.i_lock = c.i_lock ");
                			
                		
                		if("N".equals(house_transfer)){
	                		sql.append(" and d.d_close_law is null ");
	                	}else if("Y".equals(house_transfer)){
	                		sql.append(" and d.d_close_law is not null ");
	                	}else{
	                		//
	                	}
           		
           		if(!"".equals(grp_no)){
           			sql.append(" and a.grp_no = '"+grp_no+"' ");
           		}
           		if(!"".equals(i_house)){
           			sql.append(" and c.i_house = '"+i_house+"' ");
           		}
           		if(!"".equals(i_sort)){
           			sql.append(" and a.i_lock = '"+i_sort+"' ");
           		}
				if(!"".equals(datepick) && !"".equals(datepick1) ){
           			sql.append(" and a.user_rec_date + b.s_warranty units year between '"+DateUtil.thaiToifxDate(datepick)+"' and '"+DateUtil.thaiToifxDate(datepick1)+"' ");
           		}

           		countQuery = countQuery + sql.toString() + " group by a.i_company , a.i_project ,  a.grp_no  , a.i_lock , a.i_vendor ) as countrow ";
           		System.out.println(countQuery);
				idx = 0;
           		prep = conn.prepareStatement(countQuery);
           		prep.setString(++idx,i_company);
           		prep.setString(++idx,i_project);
           		prep.setString(++idx,i_company);
           		prep.setString(++idx,i_project);
           		rs = prep.executeQuery();
           		if(rs.next()){
           			totalRow = rs.getInt("total");
           		}
           		rs.close();
           		prep.close();
           		
				//order by
				if("group".equals(order_by)){
					sql.append(" order by a.i_company , a.i_project , a.grp_no , end_warranty ");
				}else if("end".equals(order_by)){
					sql.append(" order by a.i_company , a.i_project , end_warranty , a.i_lock ");
				}else{
					sql.append(" order by a.i_company , a.i_project , a.i_lock , end_warranty ");
				}
           		System.out.println(selectQuery + sql.toString());
           		idx = 0;
           		prep = conn.prepareStatement(selectQuery + sql.toString());
           		prep.setString(++idx,i_company);
           		prep.setString(++idx,i_project);
           		prep.setString(++idx,i_company);
           		prep.setString(++idx,i_project);
           		rs = prep.executeQuery();
          		while(rs.next()){
              		
          			i_type = doString.checkString(rs.getString("i_type"),"");
           			d_close_law = doString.checkString(rs.getString("d_close_law"),"");
           			grpNoTmp = doString.checkString(rs.getString("grp_no"),"");
           			
           			orderTotal = 0;
               		sql.delete(0,sql.length());
               		//sql.append(" select count(*) as total from lan:accpohdr where i_company = ? and i_project = ? and grp_no = ? and i_lock = ? and f_status = 'OPN' and po_status not in ('OPN', 'CDPO') ");
               		sql.append("	select count(*) as total  ")
                    		.append("		from ")
                    		.append("			lan:accpohdr a left join lan:pr_dochd b ")
                    		.append("			on a.i_order = b.po_docno ")
                    		.append("			and a.i_company = b.i_company ")
                    		.append("			and a.i_project = b.i_project ")
                    		.append("			and a.grp_no = b.grp_no ")
                    		.append("			and a.i_lock = b.i_lock ")
                    		.append("		where ")
                    		.append("			a.i_company = ? ")
                    		.append("			and a.i_project = ? ")
                    		.append("			and a.grp_no = ? ")
                    		.append("			and a.i_lock = ? ")
                    		.append("			and a.f_status = 'OPN' ")
                    		.append("			and (b.i_pr_type is null or b.i_pr_type = '212') ");
               		
               		prep1 = conn.prepareStatement(sql.toString());
               		prep1.setString(1,i_company);
               		prep1.setString(2,i_project);
               		prep1.setString(3,grpNoTmp);
               		prep1.setString(4,doString.checkString(rs.getString("i_lock"),""));
               		rs1 = prep1.executeQuery();
               		if(rs1.next()){
               			orderTotal = rs1.getInt("total");
               		}
               		rs1.close();
               		prep1.close();
               		
           			ven_name = "";
               		sql.delete(0,sql.length());
               		sql.append(" select ven_name from lan:vendor where ven_no = ? ");
               		prep1 = conn.prepareStatement(sql.toString());
               		prep1.setString(1,doString.checkString(rs.getString("i_vendor"),""));
               		rs1 = prep1.executeQuery();
               		if(rs1.next()){
               			ven_name = doString.DisplayThai(doString.checkString(rs1.getString("ven_name"),""));
               		}
               		rs1.close();
               		prep1.close();
               		
               		itm_name = "";
               		
               		sql.delete(0,sql.length());
               		sql.append(" select grp_desc from lan:itmgrp where 	grp_no = ? ");
               		prep1 = conn.prepareStatement(sql.toString());
               		prep1.setString(1,doString.checkString(rs.getString("grp_no"),""));
               		rs1 = prep1.executeQuery();
               		if(rs1.next()){
               			itm_name = doString.DisplayThai(doString.checkString(rs1.getString("grp_desc"),""));
               		}
               		rs1.close();
               		prep1.close();
               		

                   	String b2_check = doString.checkString(rs.getString("b2_check"),""); //โอนบ้านแล้ว
              
             %>
        				<tr>
                            <td class="dotline" align="center"><%=(++row)%></td>
                            <td class="dotline" align="left">
                            	<a href="<%=request.getContextPath()%>/SERV_ReportItmPO.jsp?grp_no=<%=doString.checkString(rs.getString("grp_no"),"")%>&i_sort=<%=doString.checkString(rs.getString("i_lock"),"")%>&project=<%=project%>&i_vendor=<%=doString.checkString(rs.getString("i_vendor"),"")%>" >
                            		<%=doString.checkString(rs.getString("grp_no"),"") + " - " + itm_name%>&nbsp;
                            	</a>
                            	<% if(orderTotal > 1){ %>
                            	<i class="fa fa-file-text-o po-doc" aria-hidden="true" ></i>
                            	<% } %>
                            </td>
                            <td class="dotline" align="left"><%=doString.checkString(rs.getString("i_vendor"),"") + " - " + ven_name%></td>
                            <td class="dotline" align="center"><%=doString.checkString(rs.getString("i_lock"),"")%></td>
                            <td class="dotline" align="center"><%=doString.checkString(rs.getString("i_house"),"")%></td>
                            <td class="dotline" align="center"><%=DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString("d_close_law"),""))%></td>
                            <td class="dotline" align="center"><%=doString.checkString(rs.getString("i_model"),"")%></td>
                            <td class="dotline" align="center">
                            <%
                            	if("T".equals(i_type)){
		                        %>
                            		<%=DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString("d_close_law"),""))%>
                            	<%
                            	}else if("R".equals(i_type)){
                            		
                            		if("B2".equals(grp_no) && !"".equals(d_close_law)){
        		                    %>
                                		<%=DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString("d_close_law"),""))%>
                                	<%
                            		}else{
			                            sql.delete(0,sql.length());
			                    		sql.append(" select min(user_rec_date) as user_rec_date ")
			                    			.append(" from lan:accpohdr where i_company  = ?  and i_project  = ? and i_lock = ? and grp_no = ? and f_status = 'OPN' ");
			                    		prep1 = conn.prepareStatement(sql.toString());
			                    		prep1.setString(1,doString.checkString(rs.getString("i_company"),""));
			                    		prep1.setString(2,doString.checkString(rs.getString("i_project"),""));
			                    		prep1.setString(3,doString.checkString(rs.getString("i_lock"),""));
			                    		prep1.setString(4,doString.checkString(rs.getString("grp_no"),""));
			                    		rs1 = prep1.executeQuery();
			                    		if(rs1.next()){
			                            %>
			                            	<%=DateUtil.ifxToThaiDateNoTime(doString.checkString(rs1.getString("user_rec_date"),""))%>
			                            <% 
			                    		}
			                    		rs1.close();
			                    		prep1.close();
                            		}
                            	}else if("S".equals(i_type)){
		                            sql.delete(0,sql.length());
			                    		sql.append(" select min(vendor_fsend_date) as vendor_fsend_date ")
			                    			.append(" from lan:accpohdr where i_company  = ?  and i_project  = ? and i_lock = ? and grp_no = ? and f_status = 'OPN' ");
		                    		prep1 = conn.prepareStatement(sql.toString());
		                    		prep1.setString(1,doString.checkString(rs.getString("i_company"),""));
		                    		prep1.setString(2,doString.checkString(rs.getString("i_project"),""));
		                    		prep1.setString(3,doString.checkString(rs.getString("i_lock"),""));
		                    		prep1.setString(4,doString.checkString(rs.getString("grp_no"),""));
		                    		rs1 = prep1.executeQuery();
		                    		if(rs1.next()){
		                            %>
		                            	<%=DateUtil.ifxToThaiDateNoTime(doString.checkString(rs1.getString("vendor_fsend_date"),""))%>
		                            <% 
		                    		}
		                    		rs1.close();
		                    		prep1.close();
                            		
                            	}else if("P".equals(i_type)){
                            	
                            	if("B2".equals(grp_no) && !"".equals(d_close_law)){
            		                    %>
                                    		<%=DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString("d_close_law"),""))%>
                                    	<%
                                	}else{
                                	
                            	
                            	
                            	
                            	
		                            sql.delete(0,sql.length());
		                    		sql.append(" select min(user_confp_date) as user_confp_date ")
			                    			.append(" from lan:accpohdr where i_company  = ?  and i_project  = ? and i_lock = ? and grp_no = ? and f_status = 'OPN' ");
		                    		prep1 = conn.prepareStatement(sql.toString());
		                    		prep1.setString(1,doString.checkString(rs.getString("i_company"),""));
		                    		prep1.setString(2,doString.checkString(rs.getString("i_project"),""));
		                    		prep1.setString(3,doString.checkString(rs.getString("i_lock"),""));
		                    		prep1.setString(4,doString.checkString(rs.getString("grp_no"),""));
		                    		rs1 = prep1.executeQuery();
		                    		if(rs1.next()){
		                            %>
		                            	<%=DateUtil.ifxToThaiDateNoTime(doString.checkString(rs1.getString("user_confp_date"),""))%>
		                            <% 
		                    		}
		                    		rs1.close();
		                    		prep1.close();
		                    		
		                    		}
                            		
                            	}else{
                            		out.print("&nbsp;");
                            	}
                            %>
                            </td>
                            <td  class="dotline" align="center" >
                            <%

                            	orderCount = 0 ;
                            	tmpWarranty = "";
                            	warning_b2 = "";
                            	
                            	//วัสดุเสาเข็ม
                            	if("B2".equals(grpNoTmp)){ 
                            	
                            orderCount = 0;
                            		tmp_pob2 = "";
		                    		sql.delete(0,sql.length());
		                    		sql.append(" select a.* ")
		                    		.append(" from ")
		                    		.append(" lan:accpohdr a left join lan:pr_dochd b ")
		                    		.append(" on a.i_order = b.po_docno ")
		                    		.append(" and a.i_company = b.i_company ")
		                    		.append(" and a.i_project = b.i_project ")
		                    		.append(" and a.grp_no = b.grp_no ")
		                    		.append(" and a.i_lock = b.i_lock ")
		                    		.append(" where ")
		                    		.append(" a.i_company = ? ")
		                    		.append(" and a.i_project = ? ")
		                    		.append(" and a.i_lock = ? ")
		                    		.append(" and a.grp_no = ? ")
		                    		.append(" and a.f_status = 'OPN' ")
		                    		.append(" and a.po_status not in ('OPN','CDPO') ")
		                    		.append(" and (b.i_pr_type is null or b.i_pr_type = '212') ") 
		                    		.append(" order by a.d_order desc ") ;
		                    		System.out.println(sql.toString());
		                    		prep1 = conn.prepareStatement(sql.toString());
		                    		prep1.setString(1,doString.checkString(rs.getString("i_company"),""));
		                    		prep1.setString(2,doString.checkString(rs.getString("i_project"),""));
		                    		prep1.setString(3,doString.checkString(rs.getString("i_lock"),""));
		                    		prep1.setString(4,doString.checkString(rs.getString("grp_no"),""));
		                    		rs1 = prep1.executeQuery();
		                    		while(rs1.next()){
		                    			++orderCount;
		                    			if("".equals(tmp_pob2)){
		                    				tmp_pob2 = doString.checkString(rs1.getString("i_order"));
		                    			}
		                    		}
		                    		rs1.close();
		                    		prep1.close();

		                    		System.out.println("count " + orderCount);
		                    		System.out.println("i_order " + tmp_pob2);
		                    		System.out.println("b2_check " + b2_check);
                            
	                            
		                    		//R and B2 and Transfered*
	                            	if("Y".equals(b2_check)){
	                            		if(orderCount > 1){ //มีหลายใบ ใบที่ 2 เป็นต้นไป ประกันนับ 1 ปี
		                            		sql.delete(0,sql.length());
		                            		sql.append(" select DATE('"+rs.getString("d_close_law")+"') + 1 units year as w1 , ")
		                            			.append(" case when user_confp_date + 1 units year < DATE('"+rs.getString("d_close_law")+"') + 1 units year then 'Y' else 'N' end as w2 , ")
		                            			.append(" user_confp_date + 1 units year as w3 ")
		                            			.append(" from lan:accpohdr where i_company  = ?  and i_project  = ? and i_lock = ? and grp_no = ? and i_order = ? ");
		                            		prep1 = conn.prepareStatement(sql.toString());
		                            		prep1.setString(1,doString.checkString(rs.getString("i_company"),""));
		                            		prep1.setString(2,doString.checkString(rs.getString("i_project"),""));
		                            		prep1.setString(3,doString.checkString(rs.getString("i_lock"),""));
		                            		prep1.setString(4,doString.checkString(rs.getString("grp_no"),""));
		                            		prep1.setString(5,tmp_pob2);
		                            		rs1 = prep1.executeQuery();
		                            		if(rs1.next()){
		                            			
		                            			warning_b2 = doString.checkString(rs1.getString("w2"),"");
		                            			if("Y".equals(warning_b2)){
		                            				tmpWarranty = DateUtil.ifxToThaiDateNoTime(doString.checkString(rs1.getString("w3"),""));
		                            			}else{
		                            				tmpWarranty = DateUtil.ifxToThaiDateNoTime(doString.checkString(rs1.getString("w1"),""));
		                            			}
		                            		}
		                            		rs1.close();
		                            		prep1.close();
	                            		}else{ //ใบแรก ประกันนับตามข้อมูลพื้นฐาน
	                            			sql.delete(0,sql.length());
		                            		sql.append(" select DATE('"+rs.getString("d_close_law")+"') + 1 units year as w1 , ")
		                            			.append("case when user_confp_date + 3 units year < DATE('"+rs.getString("d_close_law")+"') + 1 units year then 'Y' else 'N' end as w2, ")
		                            			.append(" user_confp_date + 3 units year as w3 ")
		                            			.append(" from lan:accpohdr where i_company  = ?  and i_project  = ? and i_lock = ? and grp_no = ? and f_status = 'OPN' and i_order = ? ");
		                            		prep1 = conn.prepareStatement(sql.toString());
		                            		prep1.setString(1,doString.checkString(rs.getString("i_company"),""));
		                            		prep1.setString(2,doString.checkString(rs.getString("i_project"),""));
		                            		prep1.setString(3,doString.checkString(rs.getString("i_lock"),""));
		                            		prep1.setString(4,doString.checkString(rs.getString("grp_no"),""));
		                            		prep1.setString(5,tmp_pob2);
		                            		rs1 = prep1.executeQuery();
		                            		if(rs1.next()){
		                            			warning_b2 = doString.checkString(rs1.getString("w2"),"");
		                            			if("Y".equals(warning_b2)){
		                            				tmpWarranty = DateUtil.ifxToThaiDateNoTime(doString.checkString(rs1.getString("w3"),""));
		                            			}else{
		                            				tmpWarranty = DateUtil.ifxToThaiDateNoTime(doString.checkString(rs1.getString("w1"),""));
		                            			}
		                            		}
		                            		rs1.close();
		                            		prep1.close();
	                            		}
	                            	}else{ //ยังไม่โอน
	                            		
	                            		if(orderCount > 1){ //มีหลายใบ ใบที่ 2 เป็นต้นไป ประกันนับ 1 ปี
		                            		
		                            		sql.delete(0,sql.length());
		                            		sql.append(" select user_confp_date + 1 units year as user_confp_date , ")
		                            			.append(" case when user_confp_date + 1 units year < DATE(current) then 'Y' else 'N' end as w2 ")
		                            			.append(" from lan:accpohdr where i_company  = ?  and i_project  = ? and i_lock = ? and grp_no = ? and f_status = 'OPN' and i_order = ? ");
		                            		prep1 = conn.prepareStatement(sql.toString());
		                            		prep1.setString(1,doString.checkString(rs.getString("i_company"),""));
		                            		prep1.setString(2,doString.checkString(rs.getString("i_project"),""));
		                            		prep1.setString(3,doString.checkString(rs.getString("i_lock"),""));
		                            		prep1.setString(4,doString.checkString(rs.getString("grp_no"),""));
		                            		prep1.setString(5,tmp_pob2);
		                            		rs1 = prep1.executeQuery();
		                            		if(rs1.next()){
		                            			tmpWarranty = DateUtil.ifxToThaiDateNoTime(doString.checkString(rs1.getString("user_confp_date"),""));
		                            			warning_b2 = doString.checkString(rs1.getString("w2"),"");
		                            		}
		                            		rs1.close();
		                            		prep1.close();
		                            		
	                            		}else{ //ใบแรก ประกันนับตามข้อมูลพื้นฐาน
			                            		
		                            		sql.delete(0,sql.length());
		                            		sql.append(" select user_confp_date + 3 units year as user_confp_date , ")
	                            				.append(" case when  user_confp_date + 3 units year < DATE(current) then 'Y' else 'N' end as w2 ")
		                            			.append(" from lan:accpohdr where i_company  = ?  and i_project  = ? and i_lock = ? and grp_no = ? and f_status = 'OPN' and i_order = ? ");
		                            		prep1 = conn.prepareStatement(sql.toString());
		                            		prep1.setString(1,doString.checkString(rs.getString("i_company"),""));
		                            		prep1.setString(2,doString.checkString(rs.getString("i_project"),""));
		                            		prep1.setString(3,doString.checkString(rs.getString("i_lock"),""));
		                            		prep1.setString(4,doString.checkString(rs.getString("grp_no"),""));
		                            		prep1.setString(5,tmp_pob2);
		                            		rs1 = prep1.executeQuery();
		                            		if(rs1.next()){
		                            			tmpWarranty = DateUtil.ifxToThaiDateNoTime(doString.checkString(rs1.getString("user_confp_date"),""));
		                            			warning_b2 = doString.checkString(rs1.getString("w2"),"");
		                            		}
		                            		rs1.close();
		                            		prep1.close();
	                            		}
	                            	}
                            	}
                               if("B2".equals(grpNoTmp)){
                            %>
                            	<span <% if("Y".equals(warning_b2)){ %>style="color:red"<% } %>><%=tmpWarranty%></span>
                            	
                            <% }else{ %>
                            	<%=DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString("end_warranty"),""))%>
                            <% } %>
                            <% if("Y".equals(warning_b2)){ %><span style="color:red" ><b>*</b></span><% } %>
                            </td>
                            <td  class="dotline" align="left"><%=doString.DisplayThai(doString.checkString(rs.getString("c_desc"),""))%></td>
                        </tr>
                    <%  } 
                		rs.close();
                	%>
                	
                		<tr style="height:22px;">
                            <td align="left"  class="dotline" colspan="2"><span class="item" style="font-weight:bold" >Total :</span> <%=totalRow%> </td>
                            <td align="right"  class="dotline" colspan="8">Page : 
                            <%
                            int totalPage = totalRow / rowPerPage;
                            if((totalRow % rowPerPage) > 0) totalPage += 1;
                            
                            for(int i = 1 ; i <= totalPage ; i++){
                            	if(pageNo == i){
                            %>
                             <b style="padding: 5px 10px;"><%=i%></b>
                            <%
                            
                            	}else{
                            %>
                            	<button type="button" onclick="doPage(<%=i%>)" ><%=i%></button>
                            <% }} %>
                            </td>
                        </tr>
                	<% 	
                    }else{
                    %>
				        <tr>
				          <td align="center" class="dotline" >&nbsp;</td>
				          <td align="center" class="dotline" >&nbsp;</td>
				          <td align="center" class="dotline" >&nbsp;</td>
				          <td align="center" class="dotline" >&nbsp;</td>
				          <td align="center" class="dotline" >&nbsp;</td>
				          <td align="center" class="dotline" >&nbsp;</td>
				          <td align="center" class="dotline" >&nbsp;</td>
				          <td align="center" class="dotline" >&nbsp;</td>
				          <td align="center" class="dotline" >&nbsp;</td>
				          <td align="center" class="dotline" >&nbsp;</td>
				        </tr>  
                    <% } %>
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
                  	<p style="font-size:12px;text-align:left;">เครื่องหมาย&nbsp;<span style="color:red" >*</span>&nbsp; หมายถึง วันหมดอายุการรับประกันจากใบสั่งซื้อ ไม่ตรงกับเงื่อนไข กรุณาตรวจสอบ</p>
                    <p style="font-size:12px;text-align:left;">เครื่องหมาย&nbsp;<i class="fa fa-file-text-o po-doc" aria-hidden="true" ></i>&nbsp; หมายถึง มีใบสั่งซื้อมากกว่า 1 ใบ</p>
		
		<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="150" class="act_tab2">&nbsp;</td>
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>   
        </table>  
          </td>
        </tr>
      </table>
	</FORM>
</BODY>
</HTML>

<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_ReportItmWarranty.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (rs1 != null) rs1.close();
			if (stmt != null) stmt.close();
			if (stmt1 != null) stmt1.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>
