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
	function initform() {
		document.frmDeny.lockId.focus();
	}
  function Save(frm) {
  	if (frm.lockId.value == "") {
  		alert("โปรดระบุแปลง");
  		frm.lockId.focus();
  		return;
  	}
  	if (frm.chkNo.value == "") {
  		alert("โปรดระบุครั้งที่ Checkup");
  		frm.chkNo.focus();
  		return;
  	}
  	if (frm.Cause.value == "") {
  		alert("โปรดระบุสาเหตุ");
  		frm.Cause.focus();
  		return;
  	}
     frm.submit();
  }
//-->
</script>
<base target="_self">
</HEAD>
<%
String comId = "";
String projId = "";
comId = request.getParameter("comId");
projId = request.getParameter("projId");
%>
<BODY leftMargin=0 onload="initform()" topMargin=0 marginheight="0" marginwidth="0">
<FORM NAME="frmDeny" METHOD=POST ACTION="/LHServ/DenyChkLckServlet">
<input type='hidden' name='comId' value='<%=comId%>'>
<input type='hidden' name='projId' value='<%=projId%>'>
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
String site = "";
String code = "";
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;
try {
	if (ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	
	rs = stmt.executeQuery("SELECT n_project FROM lan:acxprojt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
	if (rs != null) {
		if (rs.next() == true) {
			site = doString.DisplayThai(rs.getString("N_PROJECT"));
		}
		rs.close();
		rs=null;
	}
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
						<td height="22" width="47%" class="dotline01"><%=comId%>:<%=projId%> <%=site%></td>
						<td height="22" class="item ; dotline01" width="5%">&nbsp;</td>
						<td height="22" width="41%" class="dotline01">&nbsp;</td>
					</tr>
					<tr>
						<td class="item ; dotline01" height="22" width="7%">แปลง :</td>
						<td height="22" width="47%" class="dotline01">
						<input type="text" maxlength="5" name="lockId" class="box" style="width:50px" value=""/>
						</td>
						<td height="22" class="item ; dotline01" width="5%">&nbsp;</td>
						<td height="22" width="41%" class="dotline01">&nbsp;</td>
					</tr>
					<tr>
						<td class="item ; dotline01" height="22" width="7%">Checkup ครั้งที่ :</td>
						<td height="22" width="47%" class="dotline01">
						<input type="text" maxlength="5" name="chkNo" class="box" style="width:50px" value=""/>
						</td>
						<td height="22" class="item ; dotline01" width="5%">&nbsp;</td>
						<td height="22" width="41%" class="dotline01">&nbsp;</td>
					</tr>
					<tr>
						<td class="item ; dotline01" height="22" width="7%">สาเหตุ :</td>
						<td height="22" width="47%" class="dotline01"><select
							name='Cause' class='box' style='width:150px'>
							<option value=''>----- เลือกสาเหตุ -----</option>
<%
	rs = stmt.executeQuery("SELECT i_code, n_desc FROM lan:serv_xstd WHERE i_type = '68' ORDER BY i_code");
	while (rs.next() == true) {
		code = doString.checkString(rs.getString("I_CODE"));
%>
              <OPTION value="<%=code%>"><%=doString.DisplayThai(doString.checkString(rs.getString("N_DESC")))%></OPTION>
<%
	}
	rs.close();
	rs=null;
%>									
						</select>
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
<%
		stmt.close();
		conn.close();
		stmt = null;
		conn=null;
	} catch (Exception e) {
		System.out.println("ERROR SERV_DenChkupLck.jsp : " + e.getMessage());
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
				<a href="javascript:Save(frmDeny)"><img
					border="0" src="images/act_save.gif"
					onMouseOut=nereidFade(this,70,50,5)
					onMouseOver=nereidFade(this,100,50,5)
					style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
				</td>
				<td class="act_tab3"></td>
				<td class="act_tab4">
				<a href="javascript:history.back()"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>				
				&nbsp; <a href="SERV_Home.jsp"
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
