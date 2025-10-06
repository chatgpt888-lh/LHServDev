<%@page contentType="text/html; charset=TIS-620"%>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ include file="confirmLogin.jsp" %>
<%!
	// Caching the DataSource - It is obtained in the jspInit() method
	private javax.sql.DataSource ds = null;
	private String subcontext = "java:comp/env";
	private void getDS() throws Exception {
		String dsName = "";
		Context ctx = new InitialContext();
		InitialContext initCtx = new InitialContext();
	
		// Perform a naming service lookup to get the DataSource object.
		Context env = (Context)ctx.lookup(subcontext);
		dsName = (String)env.lookup("DATASOURCE_NAME");
		dsName = subcontext + "/" + dsName;
		ds = (javax.sql.DataSource) initCtx.lookup(dsName);
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
<HTML>
<HEAD>
<TITLE></TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
<!--
  function PrintLetter(frm) {
	frm.target = "_blank";
	//frm.action = "/LHServ/PrintInfLetter4Servlet";
	frm.action = "https://www7.lh.co.th/LHServ/PrintInfLetter4Servlet";
	frm.submit();
	frm.target = "_self";     
  }
//-->
</script>
<base target="_self">
</HEAD>
<%
String userId = user.getUserID();
%>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM NAME="frmLetter" METHOD=POST ACTION="/LHServ/PrintInfLetter4Servlet">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
		<td width="100%" class="BD">
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="50%" class="bigh"><img border="0"
					src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;จดหมายขอความร่วมมือในการชำระค่าบริการสาธารณะ ครั้งที่ 2</td>
				<td width="50%" align="right"></td>
			</tr>
		</table>
		<br style="font-size:10pt">
<%
Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
DateUtil date_util = new DateUtil();
String code = "";
StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;
try {
	if (ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
%>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td class="item_tab1"><img border="0" src="images/i_i.gif"
					align="absmiddle" width="20" height="20"></td>
				<td class="item_tab2" width="300">จดหมายขอความร่วมมือในการชำระค่าบริการสาธารณะ ครั้งที่ 2</td>
				<td class="item_tab3"></td>
				<td>&nbsp;</td>
			</tr>
		</table>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="5" valign="top"><img border="0"
					src="images/Corn01.gif" width="5" height="5"></td>
				<td class="frmTop">&nbsp;</td>
				<td width="5" valign="top" align="right"><img border="0"
					src="images/Corn02.gif" width="5" height="5"></td>
			</tr>
		</table>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="100%" class="frmLR" align="center">
				<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						
                  <td class="item ; dotline01" height="22" width="11%">โครงการ 
                    :</td>
						
                  <td height="22" class="dotline01" width="89%">
                    <select size="1" name="Project" class="box" style="width:250px">
                      <option value="LH000">----- เลือกโครงการ -----</option>
<%
	sql.delete(0, sql.length());
	sql.append("SELECT * FROM lan:serv_pstaff WHERE user_id = '"+userId+"' AND com_id = 'LH' AND proj_id = 'ALL'");
	rs = stmt.executeQuery(sql.toString());
	sql.delete(0, sql.length());
	if (rs.next() == true) {
		sql.append("SELECT DISTINCT proj.i_company, proj.i_project, proj.n_project")
			.append(" FROM lan:acxprojt proj, lan:acsbudgh bud")
			.append(" WHERE bud.i_company = proj.i_company AND bud.i_project = proj.i_project")
			.append(" AND bud.d_year = '")
			.append(cur_year)
			.append("' ORDER BY proj.i_company, proj.i_project");
	} else {
		sql.append("SELECT b.i_company, b.i_project, b.n_project")
			.append(" FROM lan:serv_pstaff a, lan:acxprojt b")
			.append(" WHERE a.user_id = '")
			.append(userId)
			.append("' AND a.com_id = b.i_company AND a.proj_id = b.i_project")
			.append(" ORDER BY b.i_company, b.i_project");
	}
	rs = stmt.executeQuery(sql.toString());
	if (rs != null) {
		while (rs.next() == true) {
			code = doString.checkString(rs.getString("I_COMPANY"))+doString.checkString(rs.getString("I_PROJECT"));
%>
              <OPTION value="<%=code%>"><%=code%> | <%=doString.checkString(doString.DisplayThai(rs.getString("N_PROJECT")))%></OPTION>
<%
		}// end while
		rs.close();
		rs=null;
	}
%>                                          
                    </select>
                  </td>
					</tr>
					<tr>
						
                  <td class="item ; dotline01" height="22" width="11%">ประจำปี :</td>
						
                  <td height="22" class="dotline01" width="89%">
			<select size="1" name="inf_year" class="box" style="width:90px">
<%
	int curYear = Integer.parseInt(cur_year);
	int Byear = curYear - 5;
	int Eyear = curYear + 5;
	for(int i = Byear;  i <= Eyear;  i++ ){
%>
			<OPTION value="<%=i%>" <%if (i == curYear) { out.print("selected"); }%>><%=i%></OPTION>
<%
	}
%> 
			</SELECT>                  
                  </td>
					</tr>
					
					<tr>					
                  <td class="item ; dotline01" height="22" width="11%">ตั้งแต่ งวดเดือน/ปี
                    :</td>
                  <td height="22" class="dotline01" width="89%">
									<select size="1" name="BegMonth" class="box" style="width: 90px">
<%
	for(int i=0;  i < 12;  i++ ){
		code = doString.displayNumber("00", i+1);
%> 
                      <OPTION value="<%=code%>"><%=DateUtil.TH_month[i]%></OPTION>
<%
	}// end of month
%> 	
 									
									</select>
									<select size="1" name="BegYear" class="box" style="width: 55px">
<%
	curYear = Integer.parseInt(cur_year)-543;
	Byear = curYear - 5;
	Eyear = curYear + 5;
	for(int i = Byear;  i <= Eyear;  i++ ){
%>
			<OPTION value="<%=i%>" <%if (i == curYear) { out.print("selected"); }%>><%=i+543%></OPTION>
<%
	}
%> 									
									</select>&nbsp;&nbsp;ถึง&nbsp;&nbsp;
									<select size="1" name="EndMonth" class="box" style="width: 90px">
<%
	for(int i=0;  i < 12;  i++ ){
		code = doString.displayNumber("00", i+1);
%> 
                      <OPTION value="<%=code%>" <%if (i == 11) { out.print("selected"); }%>><%=DateUtil.TH_month[i]%></OPTION>
<%
	}// end of month
%> 	
 									
									</select>
									<select size="1" name="EndYear" class="box" style="width: 55px">
<%
	curYear = Integer.parseInt(cur_year)-543;
	Byear = curYear - 5;
	Eyear = curYear + 5;
	for(int i = Byear;  i <= Eyear;  i++ ){
%>
			<OPTION value="<%=i%>" <%if (i == curYear) { out.print("selected"); }%>><%=i+543%></OPTION>
<%
	}
%> 									
									</select>									
					</tr>
					
					<tr>					
                  <td class="item ; dotline01" height="22" width="11%">วันที่จดหมาย<br>ขอความร่วมมือ(1)
                    :</td>
                  <td height="22" class="dotline01" width="89%"><%date_util.printHtmlThaiDateNoTime(out, "First", "", 5, 2, "white", "#0078FF");%></td>
					</tr>
					<tr>
					
					<tr>					
                  <td class="item ; dotline01" height="22" width="11%">วันที่จดหมาย<br>ขอความร่วมมือ(2)
                    :</td>
                  <td height="22" class="dotline01" width="89%"><%date_util.printHtmlThaiDateNoTime(out, "Prnt", "", 5, 2, "white", "#0078FF");%></td>
					</tr>
					<tr>
										
                  <td class="item ; dotline01" height="22" width="11%">ชื่อผู้ติดต่อ
                    :</td>
                  <td height="22" class="dotline01" width="89%"><INPUT type="text" name="Contact" class="box" value="" style="width:250px"></td>
					</tr>					
					<tr>					
                  <td class="item ; dotline01" height="22" width="11%">เบอร์โทรศัพท์
                    :</td>
                  <td height="22" class="dotline01" width="89%"><INPUT type="text" name="Phone" class="box" value="" style="width:250px"></td>
					</tr>						
				</table>
				</td>
			</tr>
		</table>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="5" valign="bottom"><img border="0"
					src="images/Corn03.gif" width="5" height="5"></td>
				<td class="frmBottom">&nbsp;</td>
				<td width="5" valign="bottom" align="right"><img border="0"
					src="images/Corn04.gif" width="5" height="5"></td>
			</tr>
		</table>
<%
		stmt.close();
		conn.close();
		stmt = null;
		conn=null;
	} catch (Exception e) {
		System.out.println("ERROR SERV_PrintInfLetter4.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (stmt != null) stmt.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>
		<br style="font-size:10pt">
		<table border="0" width="100%" cellspacing="0" cellpadding="0"
			height="30">
			<tr>
				<td class="act_tab1"></td>
				<td width="150" class="act_tab2">
				<a href="javascript:PrintLetter(frmLetter)"><img
					border="0" src="images/act_print.gif"
					onMouseOut=nereidFade(this,70,50,5)
					onMouseOver=nereidFade(this,100,50,5)
					style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
				</td>
				<td class="act_tab3"></td>
				<td class="act_tab4">
				<a href="SERV_Home.jsp"
					target="_top"><img border="0" src="images/bu_home.gif"
					align="absmiddle" width="50" height="15"></a></td>
			</tr>
		</table>
		</td>
	</tr>
</table>
<br style="font-size:20pt">
<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
	<tr>
		<td width="100%" class="copyright" align="center">Best viewed
		with 800x600 screen resolution on&nbsp;an Internet Explorer version 5
		และ 5.5 <br>
		ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;
		หรือ โทร. 0-2230-8279 (คุณประพัฒน์ ฝ่ายบริการ)&nbsp; 0-2230-8491-5
		(ฝ่าย IT) <br>
		<img src="images/copyright.gif" width="475" height="26"></td>
	</tr>
</TABLE>
</FORM>
</BODY>
</HTML>