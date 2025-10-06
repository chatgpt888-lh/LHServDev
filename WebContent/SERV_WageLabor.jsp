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
<%@ include file="confirmLogin.jsp" %>
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
	
	public static int GetLastDayOfMonth(int MM,int YY){
	int retLastDayOfMonth = 0;
	 try{
		    
		   String dd = "01";
		   String mm = ""+MM;
		   String yy = ""+(YY-543);
		   String strYYYMMDD = yy.trim()+"-"+mm.trim()+"-"+dd;

		  // System.out.println("Date Selected: "+strYYYMMDD);

		   DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");  

		    
	       // Date today = new Date();  
	        java.util.Date currentDay  =  dateFormat.parse(strYYYMMDD);
	
	        Calendar calendar =  Calendar.getInstance(Locale.ENGLISH); 
	        calendar.setTime(currentDay);  
	
	        calendar.add(Calendar.MONTH, 1);  
	        calendar.set(Calendar.DAY_OF_MONTH, 1);  
	        calendar.add(Calendar.DATE, -1);  
	
	        java.util.Date DateLastDayOfMonth = calendar.getTime();  

	        //System.out.println("Today            : " + dateFormat.format(currentDay));  
	        
	        String temp[] = dateFormat.format(DateLastDayOfMonth).split("\\-");
	        //System.out.println("Last Day of Month: " + dateFormat.format(DateLastDayOfMonth));  
	        
	        retLastDayOfMonth = Integer.parseInt(temp[2]);
	  }catch(Exception e){
		  System.out.println("GetLastDayOfMonth : "+e.toString());
	  }
	  return retLastDayOfMonth;
}
%>
<%
//String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_WageLabor.jsp";
//ServLog servlog = new ServLog(sessionId, userId, jName);

    String month[] = {"เดือน","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};   
   	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	Statement stmt2 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	ResultSet rs2 = null;
	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();   
		stmt1 = conn.createStatement();   
		stmt2 = conn.createStatement();   
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
		int pYear = cur_year-1;
		int YY = 0, YY1 = 0;
		int MM = 0, MM1 = 0;			
		int i= 0, no = 0, day = 0, day1 = 0, q_day = 0;
		double days = 0;
		String d_start = "";
		String d_stop = "";	
		String img = "";
		String i_vendor1 = "", n_vendor = "";
		String i_date = "", chk = "", chk_date = "";
		double sum_wage = 0, totsum_wage = 0, z_wage = 0, rate= 0;

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

		String h_checkin = "", m_checkin = "", h_checkout = "", m_checkout = "";
		String i_checkin = "", i_checkout = "";
		String text = "";
		String userWho = "", i_header = "", user_proj = "";

		sql.delete(0,sql.length());
		sql.append(" select * from lan:useracl where user_id='").append(userId).append("' and user_acl='S' ");
		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
					userWho = doString.checkString(rs.getString("user_who"),""); 				
		}
		rs.close();

		
		 sql.delete(0,sql.length());
		 sql.append(" select com_id, proj_id from lan:serv_pstaff ")
			  .append(" where user_id = '"+userId+"' ");
		 rs = stmt.executeQuery(sql.toString());
		 while (rs.next()) {
					user_proj = "";
					if (doString.checkString(rs.getString("proj_id")).equals("ALL")) {
							user_proj = "ALL";
					}
		 }
		 rs.close();


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
		Wage.action = "/LHServ/SERV_WageLabor.jsp";
		Wage.submit();
}

function gotoPrintPDF(){   
	document.forms[0].project.value = "<%=project%>";
	document.forms[0].MM.value = "<%=MM%>";
	document.forms[0].YY.value = "<%=YY%>";
	document.forms[0].action="<%=request.getContextPath() %>/SERV_WageLaborPrint?MM=<%=MM%>&YY=<%=YY%>";
	document.forms[0].submit();
 }


//-->
</script>

<base target="_self">
</head>
<body marginwidth="10" marginheight="10" leftmargin="10" topmargin="10">
<FORM NAME="Wage" METHOD="POST" ACTION="SERV_WageLabor.jsp">

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
    <OPTION value="LHALL">----------------- กรุณาระบุโครงการ -----------------</OPTION>
<%	
	// if (userWho.equals("A")) {
	 if (user_proj.equals("ALL")) {
				sql.delete(0, sql.length());
			sql.append("SELECT DISTINCT a.i_header[1,2] as com_id, a.i_header[3,5] as proj_id, b.n_project ")
				  .append("from lan:serv_tstaff a, lan:acxprojt b ") //serv_finger
				  .append("where a.i_header != 'Admin' ")
				  .append("and a.i_header[1,2] = b.i_company ")
				  .append("and a.i_header[3,5] = b.i_project ")
				  .append("order by 1 ");			
	} else {

		 sql.delete(0,sql.length());
		 sql.append(" select a.com_id, a.proj_id, b.n_project  from lan:serv_pstaff a ")
			   .append(" left join lan:acxprojt b on b.i_company=a.com_id  and  b.i_project=a.proj_id ")
			   .append(" where a.user_id = '").append(userId).append("' ")
			   .append(" order by a.com_id,a.proj_id ");
	}
			rs = stmt.executeQuery(sql.toString());
			while (rs.next()==true) {				
				i_header = doString.checkString(rs.getString("com_id"))+doString.checkString(rs.getString("proj_id"));
	
				option = "";
				if (project.equals(i_header)) {
						option = " Selected ";
				} // End if
%>
			<OPTION value="<%=i_header%>" <%=option%>>
			<%=i_header%>&nbsp;&nbsp;<%=doString.DisplayThai(doString.checkString(rs.getString("n_project")))%>
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
		 sql.delete(0, sql.length());
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
		}
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

/*
Modify by pradoem 2016.03.03
*/
day1 = GetLastDayOfMonth(MM1, YY1);
if(day1==29){
	q_day = 9;
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
	d_start = Integer.toString((YY1-543))+"-"+Integer.toString(MM1)+"-"+"21";
	d_stop = Integer.toString((YY-543))+"-"+Integer.toString(MM)+"-"+"20";  

   /*sql.delete(0,sql.length());	
   sql.append("select distinct i_name, i_cardno, z_wage, n_job ")
		.append("from lan:serv_tstaff ")
		.append("where i_header = '"+project+"' ")
		.append("order by n_job, i_name ");*/
   //out.println(sql.toString());		
   

   sql.delete(0,sql.length());	
   sql.append("select distinct a.i_name, a.i_cardno, a.z_wage, a.n_job ")
		.append("from lan:serv_tstaff a, lan:serv_finger b ")
		.append("where a.i_header = b.i_header ")
		.append("and a.i_cardno = b.i_cardno ")
		.append("and a.i_header = '"+project+"' ")
		.append("and b.i_date between '"+d_start+"' and '"+d_stop+"' ")
	    .append("and a.z_wage > 0 ")
		.append("order by a.i_name ");
    rs = stmt.executeQuery(sql.toString());					
    while (rs.next()) {
		
	  	
	   no++;
	   days = 0;
	   z_wage = rs.getDouble("z_wage");

%>

    <tr>
    <td class="dotlineREP" style="border-left:1px solid rgb(135,185,247)" align="center"><%=no%></td>
    <td class="dotlineREP ; item"><A HREF="SERV_WageViewEdit.jsp?card_no=<%=doString.checkString(rs.getString("i_cardno"))%>&YY=<%=YY%>&YY1=<%=YY1%>&MM=<%=MM%>&MM1=<%=MM1%>&day1=<%=day1%>&project=<%=project%>"><%=doString.checkString(doString.DisplayThai(rs.getString("i_name")))%></A>&nbsp;</td>
    <td class="dotlineREP" align="center"><%=doString.checkString(rs.getString("i_cardno"),"-")%></td>
    <td align="center" class="dotlineREP"><%=doString.displayNumber("######0.00",z_wage)%></td>

 <%    for (int dd = 21;dd <= day1;dd++) {   

	h_checkin = "-";
	m_checkin = "-";
	h_checkout = "-";
	m_checkout = "-";
	i_checkin = "-";
	i_checkout = "-";
	text = "1";
	i_date = "";
	chk = "";
	chk_date = "";
	img = "images/i_pass3.gif";
	
	 	 
   sql.delete(0,sql.length());	
   sql.append("select distinct i_name, i_cardno, i_date, i_checkin, i_checkout ")
		.append("from lan:serv_finger ")
		.append("where i_header= '"+project+"' ")
		.append("and month(i_date) = '"+MM1+"' ")
		.append("and year(i_date) = '"+(YY1-543)+"' ")
	    .append("and day(i_date) = '"+dd+"' ")
	    .append("and i_cardno = '"+doString.checkString(rs.getString("i_cardno"))+"' ")
		.append("order by i_checkout desc ");
   //out.println(sql.toString());			
   rs1 = stmt1.executeQuery(sql.toString());					
   if (rs1.next()==true) {
			//img = "images/i_pass3.gif";
			days++;			
			i_checkin = doString.checkString(rs1.getString("i_checkin"),"-");
			i_checkout = doString.checkString(rs1.getString("i_checkout"),"-");
			i_date = doString.checkString(rs1.getString("i_date"),"-");
			
			//2015-08-02
			if (!i_date.equals("-")) {
					chk_date = Integer.toString(Integer.parseInt(i_date.substring(0, 4)))+"-"+i_date.substring(5,7)+"-"+i_date.substring(8,10);					
			}
				   sql.delete(0,sql.length());	
				   sql.append("select b.i_date, a.id_card ")
						.append("from lan:serv_fingerhd a, lan:serv_fingerdt b ")
						.append("where a.i_docno = b.i_docno ")
						.append("and a.id_card = '"+doString.checkString(rs.getString("i_cardno"))+"' ")
						.append("and b.i_date = '"+chk_date+"' ");
					rs2 = stmt2.executeQuery(sql.toString());					
					if (rs2.next()==true) {
						chk = "*";
					}


			if(i_checkin.equals("-") || i_checkout.equals("-")) {
				text = "!";
				img = "images/i_question4.gif";
				days = days-1;
			} 

   } else {
			img = "images/i_pass_no3.gif";
			text = "-";			
   }

   

//------------------- Check AM, PM -------------------

/*02/03/2015 15:19:09
08/03/2015 8:17:08*/
//21/01/2015 08:30

		if (!i_checkin.equals("-")) {
			if (i_checkin.length()==18) {
					h_checkin = i_checkin.substring(11,12);
					m_checkin = i_checkin.substring(13,15);		
			} else {
					h_checkin = i_checkin.substring(11,13);
					m_checkin = i_checkin.substring(14,16);
			}
		}		

		if (!i_checkout.equals("-")) {						
			if (i_checkout.length() ==18) {
					h_checkout = i_checkout.substring(11,12);
					m_checkout = i_checkout.substring(13,15);
			} else {
					h_checkout = i_checkout.substring(11,13);
					m_checkout = i_checkout.substring(14,16);
			}
		}

//----------------------------------------------------------


if(!h_checkin.equals("-") && !text.equals("!")) {
		 if (Integer.parseInt(h_checkin) >= 11) {
			 text = "บ่าย";
			 img = "images/i_PM.gif";
			 days = days-0.5;
		 }
		 /*else {
			text = "1"; 
		 }*/
}
if(!h_checkout.equals("-") && !text.equals("!")) {
		if (Integer.parseInt(h_checkout) <= 13) {
			text = "เช้า";
			img = "images/i_AM.gif";
			days = days-0.5;
		}
		/*else {
			text = "1"; 
		}*/
}

%>    

	<td class="dotlineREP" align="center"><%=chk%><img src="<%=img%>" align="absmiddle" border="0"></td>

<%   } //end for  
 
 for (int ed = 1;ed <= 20;ed++) {   

		   /*sql.delete(0,sql.length());	
		   sql.append("select distinct i_name, i_cardno, i_date ")
				.append("from lan:serv_finger ")
				.append("where i_header= '"+project+"' ")
				.append("and month(i_date) = '"+MM+"' ")
				.append("and year(i_date) = '"+(YY-543)+"' ")
				.append("and day(i_date) = '"+ed+"' ")
				.append("and i_cardno = '"+doString.checkString(rs.getString("i_cardno"))+"' ")
				.append("order by i_name ");
		  // out.println(sql.toString());			
		   rs1 = stmt1.executeQuery(sql.toString());					
		   if (rs1.next()==true) {
					img = "images/i_pass3.gif";
					days++;
		   } else {
					img = "images/i_pass_no3.gif";
		   }*/
	
	
	
	h_checkin = "-";
	m_checkin = "-";
	h_checkout = "-";
	m_checkout = "-";
	i_checkin = "-";
	i_checkout = "-";
	text = "1";
	i_date = "";
	chk = "";
	chk_date = "";
	img = "images/i_pass3.gif";
	 	 
   sql.delete(0,sql.length());	
   sql.append("select distinct i_name, i_cardno, i_date, i_checkin, i_checkout ")
		.append("from lan:serv_finger ")
		.append("where i_header= '"+project+"' ")
		.append("and month(i_date) = '"+MM+"' ")
		.append("and year(i_date) = '"+(YY-543)+"' ")
	    .append("and day(i_date) = '"+ed+"' ")
	    .append("and i_cardno = '"+doString.checkString(rs.getString("i_cardno"))+"' ")
		.append("order by i_checkout desc ");
 //  out.println(sql.toString());			
   rs1 = stmt1.executeQuery(sql.toString());					
   if (rs1.next()==true) {
			//img = "images/i_pass3.gif";
			days++;	
			i_checkin = doString.checkString(rs1.getString("i_checkin"),"-");
			i_checkout = doString.checkString(rs1.getString("i_checkout"),"-");
			i_date = doString.checkString(rs1.getString("i_date"),"-");
			
			//2015-08-02
			if (!i_date.equals("-")) {
					chk_date = Integer.toString(Integer.parseInt(i_date.substring(0, 4)))+"-"+i_date.substring(5,7)+"-"+i_date.substring(8,10);					
			}		
					
			
				   sql.delete(0,sql.length());	
				   sql.append("select b.i_date, a.id_card ")
						.append("from lan:serv_fingerhd a, lan:serv_fingerdt b ")
						.append("where a.i_docno = b.i_docno ")
						.append("and a.id_card = '"+doString.checkString(rs.getString("i_cardno"))+"' ")
						.append("and b.i_date = '"+chk_date+"' ");
					rs2 = stmt2.executeQuery(sql.toString());					
					if (rs2.next()==true) {
						chk = "*";
					}


			if(i_checkin.equals("-") || i_checkout.equals("-")) {
				text = "!";
				img = "images/i_question4.gif";
				days = days-1;
			} 

   } else {
			img = "images/i_pass_no3.gif";
			text = "-";
   }

//------------------- Check AM, PM -------------------

/*02/03/2015 15:19:09
08/03/2015 8:17:08*/
//21/01/2015 08:30

		if (!i_checkin.equals("-")) {
			if (i_checkin.length()==18) {
					h_checkin = i_checkin.substring(11,12);
					m_checkin = i_checkin.substring(13,15);		
			} else {
					h_checkin = i_checkin.substring(11,13);
					m_checkin = i_checkin.substring(14,16);
			}
		}		

		if (!i_checkout.equals("-")) {						
			if (i_checkout.length() ==18) {
					h_checkout = i_checkout.substring(11,12);
					m_checkout = i_checkout.substring(13,15);
			} else {
					h_checkout = i_checkout.substring(11,13);
					m_checkout = i_checkout.substring(14,16);
			}
		}

		//----------------------------------------------------------

if(!h_checkin.equals("-") && !text.equals("!")) {
		 if (Integer.parseInt(h_checkin) >= 11) {
			 text = "บ่าย";
			 img = "images/i_PM.gif";
			 days = days-0.5;
		 }
		 /*else {
			text = "1"; 
		 }*/
}
if(!h_checkout.equals("-") && !text.equals("!")) {
		if (Integer.parseInt(h_checkout) <= 13) {
			text = "เช้า";
			img = "images/i_AM.gif";
			days = days-0.5;
		}
		/*else {
			text = "1"; 
		}*/
}


%>        
	 <td class="dotlineREP" align="center"><%=chk%><img src="<%=img%>" align="absmiddle" border="0"></td>

<%   } //end for  

if (z_wage > 10000) {
	//sum_wage = z_wage;
	sum_wage = (z_wage/30) * days;
} else {
	sum_wage = z_wage*days;
}

%>

    <td class="dotlineREP" align="right"><%=doString.displayNumber("#,###,##0.0",days)%></td>  
    <td class="dotlineREP" align="right"><%=doString.displayNumber("#,###,##0.00",sum_wage)%></td>
    <td class="dotlineREP" align="center"><%=doString.checkString(doString.DisplayThai(rs.getString("n_job")))%>&nbsp;</td>
  </tr>
<% 
		if (z_wage < 10000) {   // ค่าแรงของธุรการ+วิศวกร ไม่นำมารวม
				totsum_wage +=sum_wage;
		}
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
  <tr>
    <td height="22"><img src="images/i_AM.gif" align="absmiddle" border="0"></td>
    <td>หมายถึง มาทำงานครึ่งเช้า</td>
  </tr>
  <tr>
    <td height="22"><img src="images/i_PM.gif" align="absmiddle" border="0"></td>
    <td>หมายถึง มาทำงานครึ่งบ่าย</td>
  </tr>
  <tr>
    <td height="22"><img src="images/i_question4.gif" align="absmiddle" border="0"></td>
    <td>หมายถึง scan นิ้วไม่ครบ</td>
  </tr>
  <tr>
    <td height="22">&nbsp; * </td>
    <td>หมายถึง มีการปรับเวลา</td>
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

<br style="font-size:25pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="230" class="act_tab2">
            <!--<a href="javascript:gotoPrintPDF();" ><img border="0" src="images/act_print.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp; -->
            </td>
            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="<%=request.getContextPath() %>/SERV_Staff_List.jsp"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=request.getContextPath() %>/SERV_Index.jsp" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
          </tr>
        </table>

</div>
</body>
</html>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_WageLabor.jsp : " + e.getMessage());
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