<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
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
	private String dsName = Constants.JDBC_LAN;
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

<HTML>
<HEAD>
<TITLE>Deny Lock List</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
<!--

  function ClrResvTime(frm) {
     frm.action="/LHServ/ClrResvTimeServlet";
     frm.submit();
  }

//-->
</script>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM NAME="frmDeny" METHOD=POST ACTION="/LHServ/SERV_DenLckLst.jsp">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
		<td width="100%" class="BD">
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="50%" class="bigh"><img border="0"
					src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
				สละสิทธิการทำ Check up</td>
				<td width="50%" align="right"></td>
			</tr>
		</table>
		<br style="font-size:10pt">
<%

String userId = user.getUserID();
String comId = "";
String projId = "";
String code = "";
if (request.getParameter("Project") != null) {
	comId = request.getParameter("Project").substring(0,2);
	projId = request.getParameter("Project").substring(2);
}
code = comId + projId;
String lockId = "";
int line = 0;
Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
String optionSelected = "";
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

				<td class="item_tab2" width="200">สละสิทธิการทำ Check up</td>
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
						<td class="item ; dotline01" height="22" width="7%">โครงการ :</td>
						<td height="22" width="47%" class="dotline01"><select
							name='Project' class='box' style='width:250px' onChange="frmDeny.submit();">
							<option value='LHALL'>----- เลือกโครงการ -----</option>
<%
	sql.delete(0, sql.length());
	sql.append("SELECT DISTINCT proj.i_company || proj.i_project AS SITE, proj.n_project FROM lan:acxprojt proj, lan:acsbudgh bud");
	rs = stmt.executeQuery("SELECT proj_id FROM lan:serv_pstaff WHERE user_id = '" + userId + "' AND proj_id = 'ALL'");
	if (rs.next() == false) {
		sql.append(", lan:serv_pstaff staff WHERE proj.i_company = staff.com_id AND proj.i_project = staff.proj_id AND staff.user_id = '")
			.append(userId + "' AND");
	} else {
		sql.append(" WHERE");
	}
	rs.close();
	rs=null;
	sql.append(" bud.i_company = proj.i_company AND bud.i_project = proj.i_project AND bud.d_year = '" + cur_year + "' ORDER BY SITE");
	rs = stmt.executeQuery(sql.toString());
	while (rs.next() == true) {
		optionSelected = "";
		if (rs.getString("SITE").equals(code) )
		{
			optionSelected = "selected";
		}
%>
              <OPTION value="<%=rs.getString("SITE")%>" <%=optionSelected%>><%=rs.getString("SITE")%> <%=doString.DisplayThai(doString.checkString(rs.getString("N_PROJECT")))%></OPTION>
<%
	}
	rs.close();
	rs=null;
%>									
						</select>&nbsp;&nbsp;<a href="javascript:frmDeny.submit();"><img border="0" src="images/bu_go.gif"
							align="absmiddle" width="40" height="22"></a>						
						</td>
						<td height="22" class="item ; dotline01" width="5%">&nbsp;</td>
						<td height="22" width="41%" class="dotline01">&nbsp;</td>
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
		<br style="font-size:10pt">
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td class="item_tab1"><img border="0" src="images/i_i.gif"
					align="absmiddle" width="20" height="20"></td>
				<td class="item_tab2" width="160">รายการแปลงสละสิทธิ</td>
				<td class="item_tab3"></td>

				<td>&nbsp;</td>
			</tr>
		</table>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="5" valign="top" bgcolor="#D7E6FF"><img border="0"
					src="images/Corn01.gif" width="5" height="5"></td>
				<td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
				<td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img
					border="0" src="images/Corn02.gif" width="5" height="5"></td>
			</tr>
		</table>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="100%" class="frmL">

				<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						<td width="13%" class="col_name">แปลง</td>
						<td width="13%" class="col_name">สาเหตุ</td>
						<td width="14%" class="col_name">ครั้งที่ Checkup</td>
						<td width="60%" class="col_name">&nbsp;</td>
					</tr>
<%
	rs = stmt.executeQuery("SELECT d.i_lock, s.n_desc, d.i_chkseq FROM lan:serv_denchkup d, lan:serv_xstd s WHERE d.i_company = '"+comId+"' AND d.i_project = '"+projId+"' AND s.i_type = '68' AND d.i_cause = s.i_code ORDER BY d.i_lock"); 
	if (rs != null) {
		while (rs.next() == true) {
			line++;
			lockId = doString.checkString(rs.getString("I_LOCK"));
%>
					<tr>
						<td width="13%" class="dotline ; item" align="center"><%=lockId%></td>
						<td width="13%" class="dotline" align="center"><%=doString.DisplayThai(rs.getString("N_DESC"))%></td>
						<td width="14%" class="dotline" align="center"><%=rs.getInt("I_CHKSEQ")%></td>
						<td width="60%" class="dotline" align="center">&nbsp;</td>
					</tr>
<%		
		}// end while
		rs.close();
		rs=null;
	}
	if (line == 0) {
%>
					<tr>
						<td width="13%" class="dotline ; item" align="center">&nbsp;</td>
						<td width="13%" class="dotline" align="center">&nbsp;</td>
						<td width="14%" class="dotline" align="center">&nbsp;</td>
						<td width="60%" class="dotline" align="center">&nbsp;</td>
					</tr>
<%	
	}
%>					
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
		System.out.println("ERROR SERV_DenLckLst.jsp : " + e.getMessage());
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
				<a href="SERV_DenChkupLck.jsp?comId=<%=comId%>&projId=<%=projId%>"><img
					border="0" src="images/act_add.gif"
					onMouseOut=nereidFade(this,70,50,5)
					onMouseOver=nereidFade(this,100,50,5)
					style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
				</td>
				<td class="act_tab3"></td>
				<td class="act_tab4">&nbsp; <a href="SERV_Home.jsp"
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
