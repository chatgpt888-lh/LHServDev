<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%//@ include file="confirmLogin.jsp" %>
<%!
	// Caching the DataSource - It is obtained in the jspInit() method	
	private javax.sql.DataSource ds = null;
	private String dsName = Constants.JDBC_LAN;
	private String month[] = {"เดือน","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
	private void getDS() throws NamingException {
		// Note the new Initial Context Factory interface available in WebSphere 4.0
		Hashtable parms = new Hashtable();
		parms.put(Context.INITIAL_CONTEXT_FACTORY, "com.ibm.websphere.naming.WsnInitialContextFactory");
		InitialContext ctx = new InitialContext(parms);

		// Perform a naming service lookup to get the DataSource object.
		ds = (javax.sql.DataSource) ctx.lookup(dsName);
		ctx.close();

	}	
	
	// This Happens Once and is Reused
	public void jspInit() {
		try
		{
			getDS();
		}
		catch(Exception es)
		{
		  es.printStackTrace();
		}
	}
%>
<%
//String sessionId = user.getsessionId();
//String userId = user.getUserID();
String jName = "SERV_WageLaborProj.jsp";
//ServLog servlog = new ServLog(sessionId, userId, jName);

    String month[] = {"เดือน","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};   
   	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();   
		stmt1 = conn.createStatement();   
        //----=======================================----//   

		String option = "";	
		String project = "LHALL", i_company = "", i_project = "", n_project = "", n_proj = "";
		if (request.getParameter("project") != null) {
				project = doString.DisplayThai(doString.checkString(request.getParameter("project")));
		} // End if	
		
		if (!project.equals("")) {
			i_company = project.substring(0, 2);
			i_project = project.substring(2);
		} // End if

		String Selected = "", code = "";	
		Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
		int cur_year = rightNow.get(Calendar.YEAR) + 543;
		int YY = 0, YY1 = 0;
		int MM = 0, MM1 = 0;			
		int i= 0, no = 0, day = 0, day1 = 0, q_day = 0, days = 0;
		String d_start = "";
		String d_stop = "";	
		String img = "";
		String i_vendor1 = "", n_vendor = "";
		double sum_wage = 0, totsum_wage = 0, z_wage = 0, rate= 0;
		double cnt = 0;

		if (request.getParameter("YY") != null ){
			YY = Integer.parseInt(doString.checkString(request.getParameter("YY")));
		} else {
			YY = rightNow.get(Calendar.YEAR) + 543;
		}
		if (request.getParameter("MM") != null ){
			MM = Integer.parseInt(doString.checkString(request.getParameter("MM")));
		} else {
			MM = rightNow.get(Calendar.MONTH) + 1;
		}

%>
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<link rel="stylesheet" href="SERV_Style.css" type="text/css">
<link rel="stylesheet" href="SERV_WageStyle.css" type="text/css">

<style type="text/css">
TD				{ 	font-size:8pt ; font-family : Microsoft Sans Serif ; color : rgb(0,0,0) ; 		}
</style>
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">
<!--

function submit()  {		
		Wage.action = "/LHServ/SERV_WageLaborProj.jsp";
		Wage.submit();
}

/*function OrderBy(orderfld) {
	Wage.order.value = orderfld;
	Wage.submit();
}*/


//-->
</script>

<base target="_self">
</head>
<body marginwidth="10" marginheight="10" leftmargin="10" topmargin="10">
<FORM NAME="Wage" METHOD="POST" ACTION="SERV_WageLaborProj.jsp">

            <table border="0" width="1270" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">ระบุรายละเอียด</td>
                <td class="item_tab3"></td>
                <td>&nbsp;</td>                
              </tr>
            </table>


<table border="0" width="1270" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop">&nbsp;</td>
    <td width="5" valign="top" align="right"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>

<table border="0" width="1270" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR" align="center">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td class="item ; dotline01" height="22" width="12%">โครงการ
      :</td>
    <td height="22" width="40%" class="dotline01"><select name='project' class='box' style='width:250px'  >
    <OPTION value="LHALL">----------------- ทุกโครงการ -----------------</OPTION>
<%	
	         sql.delete(0, sql.length());
			 sql.append("SELECT DISTINCT a.i_header, b.n_project ")
				  .append("from lan:serv_finger a, lan:acxprojt b ")
				  .append("where a.i_header != 'Admin Dept' ")
				  .append("and a.i_header[1,2] = b.i_company ")
				  .append("and a.i_header[3,5] = b.i_project ")
				  .append("order by 1 ");
			rs = stmt.executeQuery(sql.toString());
			while (rs.next()==true) {
	
			option = "";
			if (project.equals(doString.DisplayThai(doString.checkString(rs.getString("i_header"))))) {
				option = " Selected ";
			} // End if
%>
			<OPTION value="<%=doString.DisplayThai(doString.checkString(rs.getString("i_header")))%>" <%=option%>>
			<%=doString.DisplayThai(doString.checkString(rs.getString("i_header")))%>&nbsp;&nbsp;<%=doString.DisplayThai(doString.checkString(rs.getString("n_project")))%>
			</OPTION>
<%			
		} // End while
%></SELECT>&nbsp;&nbsp;</td>
    <td height="22" class="item ; dotline01" width="10%">เดือน/ปี :</td>
    <td height="22" width="38%" class="dotline01"><select size="1" name="MM" class="box" style="width:85px">
<%
	code = "";
	for (i = 1; i <= 12; i++) {
		code = Integer.toString(i);
		if (i < 10) {
			code = "0"+ Integer.toString(i);
		}
		Selected = "";
		if (i == MM) {
			Selected = " Selected ";
		}
%>
		<option value="<%=code%>" <%=Selected%>><%=month[i]%></option>
<%
	} // End for
%></select>&nbsp;<select size="1" name="YY" class="box" style="width:55px">
<%
	code = "";
	for (i = YY-5; i <= YY+5; i++) {
		code = Integer.toString(i);
		Selected = "";
		if (i == YY)  {
			Selected = " Selected ";
		}
%>
		<option value="<%=code%>" <%=Selected%>><%=i%></option>
<%
	} // End for 
%></select>&nbsp;&nbsp;&nbsp;&nbsp; <a href = "javascript:Wage.submit()"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a></td>
  </tr>
</table>

</td>
  </tr>
</table>

<table border="0" width="1270" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>


<br style="font-size:10pt">
<%
		/* sql.delete(0, sql.length());
		 sql.append("SELECT n_project ")
			  .append("from lan:acxprojt ")
			  .append("where i_company = '"+i_company+"' ")
			  .append("and i_project =  '"+i_project+"' ");
		 //out.println(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		if (rs.next()==true) {
			n_project = doString.checkString(doString.DisplayThai(rs.getString("n_project")));
		}
		
		sql.delete(0,sql.length());
 		sql.append("select * from lan:serv_lstaff ")
			 .append("where i_company = '"+i_company+"' ")
			 .append("and i_project = '"+i_project+"' ");
 		rs = stmt.executeQuery(sql.toString());
 		if(rs.next()){ 			
 			i_vendor1 = doString.checkString(rs.getString("i_vendor1"));
		}

		sql.delete(0,sql.length());
 		sql.append("select bus_name[1,30] as bus_name ")
			 .append("from lan:stpvendr ")
			 .append("where vend_code = '"+i_vendor1+"' ");
 		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
			n_vendor = doString.checkString(doString.DisplayThai(rs.getString("bus_name")));
		}*/
%>

<table border="0" cellpadding="0" cellspacing="0" width="1270px">
 <tr height="30">
  <td width="100%" class="bigh" colspan="2">ตารางสรุปค่าแรงช่าง และค่าแรงคนงาน : โครงการ<%=n_project%></td>
 </tr>
 <tr height="30">
  <td width="80%" class="bigh ; item"><%=n_vendor%></td>
  <td width="20%" class="bigh" align="right">ประจำเดือน : <%=month[MM]%> <%=YY%></td>
 </tr> 
</table>

<br style="font-size:3pt">
<%
//---------check last month --------
MM1 = MM-1;
YY1 = YY;

if (MM == 1) {  // Jan 
	MM1 = 12;
	YY1 = YY-1;
} 

if ((MM1 == 1) || (MM1 == 3) || (MM1 == 5) || (MM1 == 7) || (MM1 == 8) || (MM1 == 10) || (MM1 == 12)) {   // จำนวนวันต่อเดือน
	day1 = 31;
	q_day = 11;
} else if (MM1 == 2) {
	day1 = 28;
	q_day = 8;
} else {
	day1 = 30;
	q_day = 10;
}

%>
<table width="1270px" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td class="col_nameREP" style="border-left:1px solid rgb(135,185,247) ; border-top:1px solid rgb(135,185,247)" rowspan="2">No</td>
    <td class="col_nameREP" style="border-top:1px solid rgb(135,185,247)" rowspan="2">ชื่อ-สกุล</td>
    <td class="col_nameREP" style="border-top:1px solid rgb(135,185,247)" rowspan="2">เลขที่บัตรประชาชน</td>
    <td class="col_nameREP" style="border-top:1px solid rgb(135,185,247)" rowspan="2">ค่าแรงต่อวัน</td>
	<td class="col_nameREP" style="border-top:1px solid rgb(135,185,247)" colspan="<%=q_day%>">เดือน<%=month[MM1]%></td>
	<td class="col_nameREP" style="border-top:1px solid rgb(135,185,247)" colspan="20">เดือน<%=month[MM]%></td> 
	<td class="col_nameREP" style="border-top:1px solid rgb(135,185,247)" rowspan="2">จำนวนวัน</td>
	<td class="col_nameREP" style="border-top:1px solid rgb(135,185,247)" rowspan="2">รวมค่าแรง</td>            
	<td class="col_nameREP" style="border-top:1px solid rgb(135,185,247)" rowspan="2">ประเภทช่าง</td>
  </tr>
  <tr>
  <%    for (int dd = 21;dd <= day1;dd++) {    %>    
  
	 <td class="col_nameREP"><%=dd%></td>

<%   } //end for  %>

 <%    for (int ed = 1;ed <= 20;ed++) {   %>    
    
	<td class="col_nameREP01"><%=ed%></td>      

<%   } //end for  %>   
  </tr>
<%

  






	img = "";
   sql.delete(0,sql.length());	
   sql.append("select distinct b.i_company, b.i_project, b.n_project, a.i_header ")
		.append("from lan:serv_finger a, lan:acxprojt b ")
		.append("where a.i_header[1,2] = b.i_company ")
		.append("and a.i_header[3,5] = b.i_project ")
		.append("order by b.i_company, b.i_project, b.n_project ");
 // out.println(sql.toString());			
   rs = stmt.executeQuery(sql.toString());					
   while (rs.next()) {
	   no++;
	   days = 0;
	//   z_wage = rs.getDouble("z_wage");
	 

%>

    <tr>
    <td class="dotlineREP" style="border-left:1px solid rgb(135,185,247)" align="center"><%=no%></td>
    <td class="dotlineREP ; item"><%=doString.checkString(doString.DisplayThai(rs.getString("n_project")))%>&nbsp;</td>
    <td class="dotlineREP" align="center">&nbsp;</td>
    <td align="center" class="dotlineREP">&nbsp;</td>

 <%    for (int dd = 21;dd <= day1;dd++) {   
	 	 
   sql.delete(0,sql.length());	
   sql.append("select count(i_cardno) as cnt ")
		.append("from lan:serv_finger ")
		.append("where i_header=  '"+doString.checkString(rs.getString("i_header"))+"' ")
		.append("and month(i_date) = '"+MM1+"' ")
		.append("and year(i_date) = '"+(YY1-543)+"' ")
	    .append("and day(i_date) = '"+dd+"' ");
   //out.println(sql.toString());			
   rs1 = stmt1.executeQuery(sql.toString());					
   if (rs1.next()==true) {
			cnt = rs1.getDouble("cnt");
			days++;
   } 
	 
%>    
  
	<td class="dotlineREP" align="center"><%=doString.displayNumber("#,###,##0",cnt)%></td>

<%   } //end for  
 
 for (int ed = 1;ed <= 20;ed++) {   

		   sql.delete(0,sql.length());	
		   sql.append("select count(i_cardno) as cnt ")
				.append("from lan:serv_finger ")
				.append("where i_header =  '"+doString.checkString(rs.getString("i_header"))+"' ")
				.append("and month(i_date) = '"+MM+"' ")
				.append("and year(i_date) = '"+(YY-543)+"' ")
				.append("and day(i_date) = '"+ed+"' ");
		   //out.println(sql.toString());			
		   rs1 = stmt1.executeQuery(sql.toString());					
		   if (rs1.next()==true) {
					cnt = rs1.getDouble("cnt");
					days++;
		   } 
%>        
	 <td class="dotlineREP" align="center"><%=doString.displayNumber("#,###,##0",cnt)%></td>

<%   } //end for  

sum_wage = z_wage*days;

%>

    <td class="dotlineREP" align="right"><%=days%></td>  
    <td class="dotlineREP" align="right"><%=doString.displayNumber("#,###,##0.00",sum_wage)%></td>
    <td class="dotlineREP" align="center">&nbsp;</td>
  </tr>
<% 
	totsum_wage +=sum_wage;
	} // end while

	rate = (totsum_wage*17)/100;
%>
       
    <tr>
    <td class="dotlineREP ; bold" style="border-left:1px solid rgb(135,185,247)" align="right" colspan="<%=q_day+24%>">รวมเป็นเงิน</td>
    <td class="dotlineREP" align="right" colspan="2"><%=doString.displayNumber("#,###,##0.00",totsum_wage)%></td>
    <td class="dotlineREP">บาท</td>
    </tr> 
    <tr>
    <td class="dotlineREP ; bold" style="border-left:1px solid rgb(135,185,247)" align="right" colspan="<%=q_day+24%>">ค่าดำเนินการ 17%</td>
    <td class="dotlineREP" align="right" colspan="2"><%=doString.displayNumber("#,###,##0.00",rate)%></td>
    <td class="dotlineREP">บาท</td>
    </tr> 
    <tr>
    <td class="solidlineREP01 ; bold" style="border-left:1px solid rgb(135,185,247)" align="right" colspan="<%=q_day+24%>">รวมเป็นเงินทั้งสิ้น</td>
    <td class="solidlineREP01" align="right" colspan="2"><%=doString.displayNumber("#,###,##0.00",totsum_wage+rate)%></td>
    <td class="solidlineREP01">บาท</td>
    </tr>          
</table>


<div width="1270px" height="20px">&nbsp;</div>


<div style="width:1270px">

<span style="float:left">
<table width="200" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="30" height="22"><img src="images/i_pass3.gif" align="absmiddle" border="0"></td>
    <td>หมายถึง มาทำงานครบ</td>
  </tr>
  <tr>
    <td height="22"><img src="images/i_pass_no3.gif" align="absmiddle" border="0"></td>
    <td>หมายถึง ไม่มาทำงาน</td>
  </tr>
 <!-- <tr>
    <td height="22"><img src="images/i_exclamation.gif" align="absmiddle" border="0"></td>
    <td>หมายถึง ข้อมูลไม่สมบูร์</td>
  </tr>
  -->
</table>
</span>

<span style="float:right">
<table width="280" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="35" height="22">ลงชื่อ</td>
    <td width="165" style="border-bottom:1px dashed rgb(200,200,200) ; text-align:center">&nbsp;</td>
    <td width="80">เจ้าหน้าที่บริการ</td>
  </tr>
</table>
</span>

<span style="float:right ; margin-right:100px">
<table width="280" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="35" height="22">ลงชื่อ</td>
    <td width="165" style="border-bottom:1px dashed rgb(200,200,200) ; text-align:center">&nbsp;</td>
    <td width="80">ผู้รับเหมา</td>
  </tr>
</table>
</span>
</div>
</body>
</html>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_WageLaborProj.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (rs1 != null) rs.close();
			if (stmt != null) stmt.close();
			if (stmt1 != null) stmt.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>