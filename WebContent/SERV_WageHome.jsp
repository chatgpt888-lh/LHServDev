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
<%//@ include file="function.jsp" %>
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
String userId = user.getUserID();
String empname = user.getEmpName();
String userwho = user.getUserWho();
String jName = "SERV_WageHome.jsp";
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
String project = "";
if (request.getParameter("project") != null) {
		project = doString.checkString(request.getParameter("project"));
} 
String i_company = "", i_project = "";
if (!project.equals("")) {
		i_company = project.substring(0, 2);
		i_project = project.substring(2);
} // End if

int cnt_date = 0;
String emp_appr = "", name_appr = "";
String option = "";
String userWho = "", i_header = "", user_proj = "";
%>
<HTML>

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

/*function OrderBy(orderfld) {
	Wage.order.value = orderfld;
	Wage.submit();
}*/


//-->
</script>

<base target="_self">
</head>
<body marginwidth="0" marginheight="0" leftmargin="0" topmargin="0">
<FORM NAME="Wage" METHOD="POST" ACTION="SERV_WageHome.jsp">

<table border="0" width="100%" cellspacing="0" cellpadding="0">

<tr>

<td width="100%" align="center" class="BD">






<table border="0" width="100%" cellspacing="0" cellpadding="0">

<tr>

<td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;

ค่าแรงช่าง และค่าแรงคนงาน</td>


</tr>

</table>







<br style="font-size:10pt">




            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="150">รายละเอียดผู้ขออนุมัติ</td>
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
    <td width="10%" height="22" class="item ; dotline01">ชื่อผู้รับเหมา/เจ้าหน้าที่ : </td>
    <td width="30%" height="22" class="dotline01"><%=doString.DisplayThai(doString.checkString(empname))%></td>
    <td width="10%" height="22" class="item ; dotline01">&nbsp;</td>
    <td width="50%" height="22" class="dotline01">&nbsp;</td>
    </tr>
	  <tr>
    <td width="10%" height="22" class="item ; dotline01">โครงการ
      :</td>
    <td width="40%" height="22" class="dotline01"><select name='project' class='box' style='width:250px'  >
    <OPTION value="LHALL">----------------- ทุกโครงการ -----------------</OPTION>
<%	
	// if (userWho.equals("A")) {
	 if (user_proj.equals("ALL")) {
				sql.delete(0, sql.length());
			sql.append("SELECT DISTINCT a.i_header[1,2] as com_id, a.i_header[3,5] as proj_id, b.n_project ")
				  .append("from lan:serv_finger a, lan:acxprojt b ")
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
%></SELECT>&nbsp;&nbsp;&nbsp;<a href = "javascript:Wage.submit()"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a></td>
    <td width="10%" height="22" class="item ; dotline01">&nbsp;</td>
    <td width="40%" height="22" class="dotline01"> &nbsp;</td>
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
                <td class="item_tab2" width="220">รายละเอียดเอกสารการขอนุมัติปรับวัน / เวลา</td>
                <td class="item_tab3"></td>
                <td>&nbsp;</td>                
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
<td width="12%" class="col_name"><a href="#">โครงการ</a></td>
<td width="15%" class="col_name"><a href="#">เลขที่เอกสาร</a></td>
<td width="31%" class="col_name"><a href="#">ชื่อ-สกุล</a></td>
<td width="12%" class="col_name"><a href="#">จำนวนวัน</a></td>
<td width="15%" class="col_name"><a href="#">สถานะ</a></td>
<td width="15%" class="col_name"><a href="#">ผู้อนุมัติ</a></td>
</tr>
<%

		/*//---------------------------- ผู้อนุมัติแต่ละโครงการ -------------------------------
		sql.delete(0,sql.length());
		sql.append("select a.user_id, b.i_employ, b.user_email from lan:serv_pstaff a, lan:useracl b ")
			.append("where a.com_id = '"+i_company+"' ")
			.append("and a.proj_id = '"+i_project+"' ")
			.append("and a.user_id = b.user_id ")
			.append("and b.user_acl = 'S' ")
			.append("and b.user_who = 'M' ");
		rs1 = stmt1.executeQuery(sql.toString());
		if (rs1.next() == true) {	
				emp_appr = doString.checkString(rs1.getString("i_employ"));
		}*/					
   sql.delete(0,sql.length());	
   sql.append("select * from lan:serv_fingerhd ")
	    .append("where i_docno[4,8] = '"+project+"' ")
	//	.append("and status = 'OPN' ")	   
		.append("order by i_docno ");
   //out.println(sql.toString());					
	rs = stmt.executeQuery(sql.toString());					
    while (rs.next()==true) {

			emp_appr = doString.checkString(rs.getString("i_empappr"));

		   cnt_date = 0;
		   sql.delete(0,sql.length());	
		   sql.append("select count(i_date) as cnt_date from lan:serv_fingerdt ")
				.append("where i_docno = '"+doString.checkString(rs.getString("i_docno"))+"' ");
		   rs1 = stmt1.executeQuery(sql.toString());					
		   if (rs1.next()==true) {
					cnt_date = rs1.getInt("cnt_date");
		   }
			name_appr = "-";
			sql.delete(0,sql.length());
			sql.append("select n_prename_th,n_nemploy_th,n_semploy_th ") 
				 .append("from docflow:acemploy ")  
				 .append("where i_employ = '"+emp_appr+"' ");
			rs1 = stmt1.executeQuery(sql.toString());
			if (rs1.next() == true) {	
					name_appr = doString.checkString(doString.DisplayThai(rs1.getString("n_nemploy_th")))+" "+doString.checkString(doString.DisplayThai(rs1.getString("n_nemploy_th")));
			}
%>
<tr>
<td align="center" class="dotline ; item" ><%=project%></td>
<td class="dotline" align="center"><A HREF="SERV_WageApprweb.jsp?docno=<%=doString.checkString(rs.getString("i_docno"))%>&status=<%=doString.checkString(rs.getString("status"))%>&emp_appr=<%=emp_appr%>&project=<%=project%>&userwho=<%=userwho%>"><%=doString.checkString(rs.getString("i_docno"))%></A></td>
<td class="dotline"><%=doString.checkString(doString.DisplayThai(rs.getString("name")))%></td>
<td class="dotline" align="center"><%=cnt_date%></td>
<td class="dotline" align="center"><%=doString.checkString(rs.getString("status"))%></td>
<td class="dotline" align="center"><%=name_appr%></td>
</tr>
<%
	}  // end while
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


<br style="font-size:5pt">


<table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">

<tr>

<td class="act_tab1"></td>

<td width="75" class="act_tab2">&nbsp;</td> 

<td class="act_tab3"></td> 

<td class="act_tab4"><a href="javascript:history.back()" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;

<a href="/LHServ/SERV_WageHome.jsp" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td> 

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
	} catch (Exception e) {
		System.out.println("ERROR SERV_WageHome.jsp : " + e.getMessage());
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
