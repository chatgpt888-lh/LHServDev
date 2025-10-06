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
%>

<HTML>
<HEAD>
<TITLE>Reserve Time List</TITLE>
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
<FORM NAME="frmResvTime" METHOD=POST ACTION="/LHServ/SERV_ResvTimeLst.jsp">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
		<td width="100%" class="BD">
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="50%" class="bigh"><img border="0"
					src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
				จองเวลาการทำ Check up</td>
				<td width="50%" align="right"></td>
			</tr>
		</table>
		<br style="font-size:10pt">
<%

String userId = user.getUserID();
String empId = user.getEmpId();
String empName = "";
String comId = "LH";
String projId = "ALL";
String code = "";
if (request.getParameter("Project") != null) {
	comId = request.getParameter("Project").substring(0,2);
	projId = request.getParameter("Project").substring(2);
}
code = comId + projId;
Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
String chkMonth = "";
if( request.getParameter("chkMonth") != null ){
	chkMonth = request.getParameter("chkMonth");
}
if (chkMonth.equals("")) {
	if(Integer.toString(rightNow.get(Calendar.MONTH)+1).length() == 1) {
		chkMonth = "0" + Integer.toString(rightNow.get(Calendar.MONTH)+1);
	} else {
		chkMonth = Integer.toString(rightNow.get(Calendar.MONTH)+1);
	}
}

String chkYear = "";
if( request.getParameter("chkYear") != null ){
	chkYear = request.getParameter("chkYear");
}

if (chkYear.equals("")) {
	chkYear = Integer.toString(rightNow.get(Calendar.YEAR));
}
String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
String restrict = "";
if (!code.equals("LHALL")) {
	restrict = "c.i_company = '" + comId + "' AND c.i_project = '" + projId + "' AND ";
}
String mnthDate = chkYear+"-"+chkMonth+"-01";
String optionSelected = "";
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
	rs = stmt.executeQuery("SELECT TRIM(n_prename_th) || ' ' || TRIM(n_nemploy_th) || ' ' || TRIM(n_semploy_th) AS EMP_NAME FROM docflow:acemploy WHERE i_employ = '"+empId+"'");
	if (rs != null) {
		if (rs.next() == true) {
			empName = doString.checkString(rs.getString(1));
		}
		rs.close();
		rs=null;
	}		
%>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td class="item_tab1"><img border="0" src="images/i_i.gif"
					align="absmiddle" width="20" height="20"></td>

				<td class="item_tab2" width="200">จองเวลาการทำ Check up</td>
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
						<td class="item ; dotline01" height="22" width="7%">ชื่อเจ้าหน้าที่
						:</td>
						<td height="22" width="47%" class="dotline01"><%=doString.DisplayThai(empName)%></td>
						<td height="22" class="item ; dotline01" width="5%">&nbsp;</td>
						<td height="22" width="41%" class="dotline01">&nbsp;</td>
					</tr>
					<tr>
						<td class="item ; dotline01" height="22" width="7%">โครงการ :</td>
						<td height="22" width="47%" class="dotline01"><select
							name='Project' class='box' style='width:250px' onChange="frmResvTime.submit();">
							<option value='LHALL'>ทุกโครงการ</option>
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
						</select></td>
						<td height="22" class="item ; dotline01" width="5%">เดือน/ปี
						:</td>
						<td height="22" width="41%" class="dotline01">
						<select name='chkMonth' class='box' style="width:75px">
<%
	for( i=0;  i < 12;  i++ ){
		optionSelected = "";
		if( i<9 )
			code = "0" + Integer.toString(i+1);
		else
			code = Integer.toString(i+1);
		if (code.equals(chkMonth)) {
			optionSelected = "selected";
		}
%> 
                      <OPTION value="<%=code%>" <%=optionSelected%>><%=month[i]%></OPTION>
<%
	}// end of month
%> 						
						</select> <select name='chkYear' class='box' style="width:55px">
<%
	int curYear = Integer.parseInt(chkYear);
	int Byear = curYear - 5;
	int Eyear = curYear + 5;
	for( i = Byear;  i <= Eyear;  i++ ){
  		    optionSelected = "";
			if (i == curYear) {
				optionSelected = "selected";
			}
%>
			<OPTION value="<%=i%>" <%=optionSelected%>><%=i+543%></OPTION>
<%
	}
%> 						
						</select> &nbsp; <a href="javascript:frmResvTime.submit();"><img border="0" src="images/bu_go.gif"
							align="absmiddle" width="40" height="22"></a></td>
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
				<td class="item_tab2" width="160">รายละเอียดช่วงเวลาที่จอง</td>
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
						<td width="5%" class="col_name">Chk</td>
						<td width="8%" class="col_name">ครั้งที่จอง</td>
						<td width="13%" class="col_name">วันเวลาที่ทำรายการ</td>
						<td width="26%" class="col_name">โครงการ</td>
						<td width="25%" class="col_name">ร้านค้า</td>
						<td width="23%" class="col_name">วันเวลาที่จอง</td>
					</tr>
<%
	String docNo = "";
	boolean clear = false;
	i=0;
	rs = stmt.executeQuery("SELECT c.i_chkupno, c.i_seq, c.d_keyin, p.n_project, v.bus_name FROM lan:serv_chkuphd c, lan:acxprojt p, lan:stpvendr v WHERE c.i_employ = '"+empId+"' AND "+restrict+" c.i_month = '"+mnthDate+"' AND c.i_company = p.i_company AND c.i_project = p.i_project AND c.i_vendor = v.vend_code ORDER BY c.i_seq"); 
	if (rs != null) {
		while (rs.next() == true) {
			i++;
			docNo = doString.checkString(rs.getString("I_CHKUPNO"));
			clear = true;
			rsChkup = ustmt.executeQuery("SELECT f_status FROM lan:serv_chkupdt WHERE i_chkupno = '"+docNo+"' AND f_status != 'N'");
			if (rsChkup != null) {
				if (rsChkup.next() == true) {
					clear = false;
				}
				rsChkup.close();
				rsChkup=null;
			}
%>
					<tr>
						<td width="5%" class="dotline ; item" align="center">
<%
			if (clear) {
				out.print("<input type=\"checkbox\" name=\"docNo\" value=\""+docNo+"\">");
			} else {
				out.print("&nbsp;");
			}
%>						
						</td>
						<td width="8%" class="dotline ; item" align="center"><%=rs.getInt("I_SEQ")%></td>
						<td width="13%" class="dotline" align="center"><%=DateUtil.ifxToThaiDate(rs.getString("D_KEYIN"))%></td>
						<td width="26%" class="dotline" align="center"><%=doString.DisplayThai(rs.getString("N_PROJECT"))%></td>
						<td width="25%" align="center" class="dotline"><%=doString.DisplayThai(rs.getString("BUS_NAME"))%></td>
						<td width="23%" align="center" class="dotline">
						<a href="ViewResvTimeServlet?docNo=<%=docNo%>"><img src="images/i_list.gif" width="18" height="18" border="0"></a>						
						</td>
					</tr>

<%		
		}// end while
		rs.close();
		rs=null;
	}
	if (i == 0) {
%>
					<tr>
						<td width="5%" class="dotline ; item" align="center">&nbsp;</td>
						<td width="8%" class="dotline ; item" align="center">&nbsp;</td>
						<td width="13%" class="dotline" align="center">&nbsp;</td>
						<td width="26%" class="dotline" align="center">&nbsp;</td>
						<td width="25%" align="center" class="dotline">&nbsp;</td>
						<td width="23%" align="center" class="dotline">&nbsp;</td>
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
		System.out.println("ERROR SERV_ResvTimeLst.jsp : " + e.getMessage());
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
%>
		<br style="font-size:10pt">
		<table border="0" width="100%" cellspacing="0" cellpadding="0"
			height="30">
			<tr>
				<td class="act_tab1"></td>
				<td width="150" class="act_tab2">
				<a href="InitResvTimeServlet?Project=<%=comId%><%=projId%>&chkMonth=<%=chkMonth%>&chkYear=<%=Integer.parseInt(chkYear)+543%>"><img
					border="0" src="images/act_add.gif"
					onMouseOut=nereidFade(this,70,50,5)
					onMouseOver=nereidFade(this,100,50,5)
					style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp;
				<a href="javascript:ClrResvTime(frmResvTime)"><img
					border="0" src="images/act_clear.gif"
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
