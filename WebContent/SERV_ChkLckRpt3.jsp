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
	private String month[] = {"มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
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
	public String getStatus(String status) {
		if (status.equals("N")) {
			status = "รอบันทึกนัด";
		}
		if (status.equals("D")) {
			status = "ยกเลิกนัด";
		}
		if (status.equals("R")) {
			status = "บันทึกนัดแล้ว";
		}
		if (status.equals("O")) {
			status = "Open Job";
		}
		if (status.equals("C")) {
			status = "Complete Job";
		}
		return status;		
		
	}
%>
<HTML>
<HEAD>
<TITLE>Checkup Lock</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
<!--
	function pleasewait() {
		if (document.getElementById) { // DOM3 = IE5, NS6
			document.getElementById ('hidepage').style.visibility = 'hidden';
		} else {
			if (document.layers) { // Netscape 4
				document.hidepage.visibility = 'hidden';
			}  else { // IE 4 document.all.hidepage.style.visibility = 'hidden';
			}
		}
	}

	function progress() {
		if (document.getElementById) { // DOM3 = IE5, NS6
			document.getElementById ('hidepage').style.visibility = '';
		} else {
			if (document.layers) { // Netscape 4
				document.hidepage.visibility = '';
			}  else { // IE 4 document.all.hidepage.style.visibility = 'hidden';
			}
		}
	}
	
//-->
</script>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="pleasewait();">
<div id="hidepage" style="position: absolute; left:300px; top:100px; background-color: white; layer-background-color: white; height: 10%; width: 30%;">
<table width=100%><tr><td valign=middle align=middle><div id="a1">Page loading ... Please wait...</div></td></tr></table></div>
<FORM NAME="frmChckLock" METHOD=POST ACTION="/LHServ/InitChkLckServlet">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
		<td width="100%" class="BD">
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="50%" class="bigh"><img border="0"
					src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
				Check Up</td>
				<td width="50%" align="right"></td>
			</tr>
		</table>
		<br style="font-size:10pt">
<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String empId = user.getEmpId();
String empName = "";
String comId = "";
String projId = "";
String project = "";
String lockId = "";
String code = "";
String brand = "";
Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
if( request.getParameter("type") != null ){
	code = doString.checkString(request.getParameter("type"));
}
String caption = "";
if (code.equals("05")) {
	caption = "ยกเลิก";
} else {
	caption = "สละสิทธิ";
}
String chkMonth = "";
if( request.getParameter("chkMonth") != null ){
	chkMonth = doString.checkString(request.getParameter("chkMonth"));
}


String chkYear = "";
if( request.getParameter("chkYear") != null ){
	chkYear = doString.checkString(request.getParameter("chkYear"));
}

String chkupNo = "";
if( request.getParameter("seqNo") != null ){
	chkupNo = doString.checkString(request.getParameter("seqNo"));
}



String mnthDate = chkYear+"-"+chkMonth+"-01";
String desc = "";
int i=0;
StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
Statement ustmt = null;
ResultSet rs = null;
ResultSet rsChkup = null;
try {
	if (ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	ustmt = conn.createStatement();
	rs = stmt.executeQuery("SELECT n_desc FROM lan:serv_chkrep WHERE i_main = '"+code+"'");
	if (rs != null) {
		if (rs.next() == true) {
			desc = doString.DisplayThai(rs.getString(1));
		}
		rs.close();
		rs=null;
	}
%>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td class="item_tab1"><img border="0" src="images/i_i.gif"
					align="absmiddle" width="20" height="20"></td>
				<td class="item_tab2" width="250"><%=desc%> Check up ครั้งที่ <%=chkupNo%></td>
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
						<td class="item ; dotline01" height="22" width="7%">เดือน/ปี :</td>
						<td height="22" width="47%" class="dotline01">
<%
	out.print( month[Integer.parseInt(chkMonth)-1]+" "+(Integer.parseInt(chkYear)+543));
%> 	
						</td>
						<td height="22" class="item ; dotline01" width="5%">&nbsp;</td>
						<td height="22" width="41%" class="dotline01">&nbsp;
						</td>
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

				<td class="item_tab2" width="160">รายการแปลงขาย</td>
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
						<td width="4%" class="col_name">ลำดับที่</td>
						<td width="20%" class="col_name">โครงการ</td>
						<td width="6%" class="col_nameO">แปลงขาย</td>
						<td width="11%" class="col_name">สาเหตุการ<%=caption%></td>
						<td width="28%" class="col_name">ชื่อลูกค้า</td>
						<td width="15%" class="col_name">เบอร์โทรศัพท์</td>
						<td width="16%" class="col_name">วันที่โอน</td>
					</tr>
<%
	String time = "";
	int seqNo = 0;
	i=0;
	rsChkup = ustmt.executeQuery("SELECT * FROM lan:serv_chklock WHERE i_session = "+sessionId+" AND user_id = '"+userId+"' AND i_chkseq = "+chkupNo+" ORDER BY i_company, i_project, i_lock");
	if (rsChkup != null) {
		while (rsChkup.next() == true) {
			i++;
			comId = doString.checkString(rsChkup.getString("I_COMPANY"));
			projId = doString.checkString(rsChkup.getString("I_PROJECT"));
			brand = "";
			rs = stmt.executeQuery("SELECT i_brand FROM lan:serv_brand WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
			if (rs != null) {
				if (rs.next() == true) {
					brand = doString.checkString(rs.getString(1));
				}
				rs.close();
				rs=null;
			}	
			project = "";
			rs = stmt.executeQuery("SELECT n_project FROM lan:acxprojt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
			if (rs != null) {
				if (rs.next() == true) {
					project = doString.checkString(rs.getString(1));
				}
				rs.close();
				rs=null;
			}
			lockId = doString.checkString(rsChkup.getString("I_LOCK"));
			seqNo = rsChkup.getInt("I_CHKSEQ");
			time = "";
			if (doString.checkString(rsChkup.getString("I_TIME")).equals("-")) {
				time = "-";						
			} else {
				rs = stmt.executeQuery("SELECT n_time FROM lan:serv_btime WHERE i_brand = '"+brand+"' AND i_time = '"+doString.checkString(rsChkup.getString("I_TIME"))+"'");
				if (rs != null) {
					if (rs.next() == true) {
						time = doString.checkString(rs.getString("N_TIME"));		
					}
					rs.close();
					rs=null;
				}					
			}
%>
					<tr>
						<td width="4%" align="center" class="dotline"><%=i%></td>
						<td width="20%" align="left" class="dotline"><%=comId%><%=projId%> <%=doString.DisplayThai(project)%></td>
						<td width="6%" class="dotline" align="center"><%=lockId%></td>
						<td width="11%" class="dotline" align="center"><%=doString.DisplayThai(rsChkup.getString("N_STATUS"))%></td>
						<td width="28%" align="left" class="dotline"><%=doString.DisplayThai(rsChkup.getString("N_NAME"))%>&nbsp;</td>
						<td width="15%" align="left" class="dotline"><%=doString.DisplayThai(rsChkup.getString("I_TEL"))%>&nbsp;</td>
						<td width="16%" align="center" class="dotline"><%=DateUtil.ifxToThaiDateNoTime(rsChkup.getString("D_CLOSE_LAW"))%></td>
					</tr>
<%		
		}// end while
		rsChkup.close();
		rsChkup=null;
	}
	if (i==0) {
%>
					<tr>
						<td width="4%" align="center" class="dotline">&nbsp;</td>
						<td width="20%" align="left" class="dotline">&nbsp;</td>
						<td width="6%" class="dotline" align="center">&nbsp;</td>
						<td width="11%" class="dotline" align="center">&nbsp;</td>
						<td width="28%" align="left" class="dotline">&nbsp;</td>
						<td width="15%" align="left" class="dotline">&nbsp;</td>
						<td width="16%" align="center" class="dotline">&nbsp;</td>
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
		ustmt.close();
		stmt.close();
		conn.close();
		stmt = null;
		ustmt = null;
		conn=null;
	} catch (Exception e) {
		System.out.println("ERROR SERV_ChkLckRpt2.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (stmt != null) stmt.close();
			if (ustmt != null) ustmt.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%> <br style="font-size:10pt">
		<table border="0" width="100%" cellspacing="0" cellpadding="0"
			height="30">
			<tr>
				<td class="act_tab1"></td>
				<td width="75" class="act_tab2">&nbsp;</td>
				<td class="act_tab3"></td>
				<td class="act_tab4"><a href="javascript:history.back()"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;<a href="SERV_Home.jsp"
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
