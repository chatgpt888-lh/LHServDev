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
	private String DayOfWeek[] = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
	
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
	
	public BetweenDate getBetweenDate(int mnth, int year, int bckMnth) {
		for (int m=1; m<bckMnth; m++) {
			mnth--;
			if (mnth == 0) {
				mnth = 12;
				year--;
			}			
		}// end for
		java.util.Calendar currentCal = java.util.Calendar.getInstance(Locale.ENGLISH);
		currentCal = new GregorianCalendar(year, mnth-1, 1);
		int daysInMonth = currentCal.getActualMaximum(currentCal.DAY_OF_MONTH);		
		String begDate = Integer.toString(year)+"-"+doString.displayNumber("00", mnth)+"-01";
		String endDate = Integer.toString(year)+"-"+doString.displayNumber("00", mnth)+"-"+doString.displayNumber("00", daysInMonth);
		BetweenDate betweenDate = new BetweenDate(begDate, endDate);
		return betweenDate;
	}
%>

<HTML>
<HEAD>
<TITLE>จองเวลาการเข้าบริการ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
<!--
function searchData(frm) {
/*
	if (frm.Project.value == "") {
		alert("โประเลือกโครงการ");
		frm.Project.focus();
		return;
	}
*/	
	frm.action = "/LHServ/InitResvTimeServlet";
	frm.submit();
}

function Go(frm) {
	if (frm.Project.value == "") {
		alert("โประเลือกโครงการ");
		frm.Project.focus();
		return;
	}
	if (frm.Vendor.value == "") {
		alert("โประเลือกร้านค้า");
		frm.Vendor.focus();
		return;
	}
	frm.action = "/LHServ/InitResvTimeServlet";
	frm.submit();
}

function ScrollDate(frm, direct) {
	if (frm.Project.value == "") {
		alert("โประเลือกโครงการ");
		frm.Project.focus();
		return;
	}
	if (frm.Vendor.value == "") {
		alert("โประเลือกร้านค้า");
		frm.Vendor.focus();
		return;
	}
	frm.direction.value = direct;
	frm.action = "/LHServ/ScrollResvTimeServlet";
	frm.submit();
}

function Reseve(frm) {
	if (frm.Project.value == "") {
		alert("โประเลือกโครงการ");
		frm.Project.focus();
		return;
	}
	if (frm.Vendor.value == "") {
		alert("โประเลือกร้านค้า");
		frm.Vendor.focus();
		return;
	}
	frm.action = "/LHServ/ResvChkupTimeServlet";
	frm.submit();
}
//-->
</script>
<base target="_self">


</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM NAME="frmResvTime" METHOD=POST ACTION="/LHServ/InitResvTimeServlet">
<input type="hidden" name="direction" value="">
<table border="0" width="780" cellspacing="0" cellpadding="0">
	<tr>
		<td width="100%" class="BD">
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="80%" class="bigh"><img border="0"
					src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
				จองเวลาการเข้าบริการ</td>
				<td width="20%" class="bigh" align="right"></td>
			</tr>
		</table>
		<br style="font-size:10pt">
<%
String userId = user.getUserID();
int seq =  Integer.parseInt(doString.checkString(request.getParameter("seq"),"0"));
if (seq < 0) seq = 0;
ResvTime resv_time = (ResvTime)session.getAttribute("resv_time");
String empId = "";
String empName = "";
String resvDate = "";
String chkMonth = "";
String chkYear = "0";
String comId = "";
String projId = "";
String brand = "";
String vendor = "";
String group = "";
int week = 1;
int backWeek = 0;
int nextWeek = 0;
int firstDay = 1;
int backDay = 0;
int nextDay = 0;
java.util.Vector chkTimeList = null;
if (resv_time != null) {
	empId = resv_time.getEmpId();
	resvDate = resv_time.getResvDate();
	chkMonth = resv_time.getChkMonth();
	chkYear = resv_time.getChkYear();
	comId = resv_time.getComId();
	projId = resv_time.getProjId();
	vendor = resv_time.getVendor();
	group = resv_time.getGroup();
	week = resv_time.getWeek();
	firstDay = resv_time.getFirstDayOfWeek();
	chkTimeList = resv_time.getChkTimeList();
}
Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);

java.util.Calendar currentCal = java.util.Calendar.getInstance(Locale.ENGLISH);
int curMnth = Integer.parseInt(chkMonth)-1;
int curYear = Integer.parseInt(chkYear)-543;
currentCal = new GregorianCalendar(curYear, curMnth, 1);
int dayOfWeek = 0;
if (week == 1) {
	dayOfWeek = currentCal.get(currentCal.DAY_OF_WEEK)-1;
}
int daysInMonth = currentCal.getActualMaximum(currentCal.DAY_OF_MONTH);
String mnthDate = Integer.toString(curYear)+"-"+chkMonth+"-";
String chkDate = "";
int day = 0;
int mnth = 0;
int year = 0;
SimpleDateFormat formatter=null;
formatter = new SimpleDateFormat("yyyy-MM-dd", Locale.US);
boolean chkDay[] = new boolean[7];
boolean holiday[] = new boolean[7];
boolean busy[] = new boolean[7];
int chkup_day[] = new int[7];
String code = "";
String venId = "";
String groupId = "";
int i=0;

int num_time = 0;
int bckMnth1 = 0;
int bckMnth2 = 0;
Vector timelist = new Vector(5);
StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
Statement ustmt = null;
Statement lstmt = null;
ResultSet rs = null;
try {
	if (ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	ustmt = conn.createStatement();
	lstmt = conn.createStatement();
			
	rs = stmt.executeQuery("SELECT TRIM(n_prename_th) || ' ' || TRIM(n_nemploy_th) || ' ' || TRIM(n_semploy_th) AS EMP_NAME FROM docflow:acemploy WHERE i_employ = '"+empId+"'");
	if (rs != null) {
		if (rs.next() == true) {
			empName = doString.checkString(rs.getString(1));
		}
		rs.close();
		rs=null;
	}			
	rs = stmt.executeQuery("SELECT i_brand FROM lan:serv_brand WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
	if (rs != null) {
		if (rs.next() == true) {
			brand = doString.checkString(rs.getString(1));
		}
		rs.close();
		rs=null;
	}			
	rs = stmt.executeQuery("SELECT i_time, n_time FROM lan:serv_btime WHERE i_brand = '"+brand+"' ORDER BY i_time");
	if (rs != null) {
		while (rs.next() == true) {
			code = doString.checkString(rs.getString(1));
			ChkTime aTime = new ChkTime();
			aTime.setChkTime(code);
			aTime.setDesc(doString.checkString(rs.getString(2)));
			timelist.addElement(aTime);
			num_time++;
		}// end while
		rs.close();
		rs=null;
	}			
	Comparator comparator = new TimeComparator();	
	Collections.sort(timelist, comparator);
	rs = stmt.executeQuery("SELECT p_amount FROM lan:serv_xstd WHERE i_type = '65' AND i_code = '01'");
	if (rs != null) {
		if (rs.next() == true) {
			bckMnth1 = rs.getInt("P_AMOUNT");
		}
		rs.close();
		rs=null;
	}
	rs = stmt.executeQuery("SELECT p_amount FROM lan:serv_xstd WHERE i_type = '66' AND i_code = '01'");
	if (rs != null) {
		if (rs.next() == true) {
			bckMnth2 = rs.getInt("P_AMOUNT");
		}
		rs.close();
		rs=null;
	}	
%>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td class="item_tab1"><img border="0" src="images/i_i.gif"
					align="absmiddle" width="20" height="20"></td>
				<td class="item_tab2" width="200">รายละเอียดการจองเวลา</td>
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
						<td class="item ; dotline01" height="22" width="12%">ชื่อผู้จอง
						:</td>
						<td height="22" width="40%" class="dotline01"><%=doString.DisplayThai(empName)%></td>
						
                <td height="22" class="item ; dotline01" width="13%">วันที่ทำรายการ 
                  :</td>
						
                <td height="22" width="35%" class="dotline01"><%=DateUtil.ifxToThaiDateNoTime(resvDate)%></td>
					</tr>
					<tr>
						<td class="item ; dotline01" height="22" width="12%">เดือน/ปี :</td>
						<td height="22" width="40%" class="dotline01"><%=month[Integer.parseInt(chkMonth)-1]%> <%=chkYear%></td>
                <td height="22" class="item ; dotline01" width="13%">โครงการ :</td>
                <td height="22" width="35%" class="dotline01"> 
<%
	rs = stmt.executeQuery("SELECT n_project FROM lan:acxprojt WHERE i_company = '" + comId + "' AND i_project = '"+projId+"'");
	if (rs.next() == true) {
		out.print(comId+projId+" "+doString.DisplayThai(rs.getString("N_PROJECT")));
	}
	rs.close();
	rs=null;
%>							
						</td>
					</tr>
					<tr>
						<td class="item ; dotline01" height="22" width="12%">ร้านค้าแอร์
						:</td>
						<td height="22" width="40%" class="dotline01">
<%
	rs = stmt.executeQuery("SELECT bus_name FROM lan:stpvendr WHERE vend_code = '"+vendor+"'");
	if (rs != null) {
		if (rs.next() == true) {
			out.print(doString.DisplayThai(rs.getString("BUS_NAME")));
		}
		rs.close();
		rs=null;
	}
%>						
				</td>
                <td height="22" class="item ; dotline01" width="13%">ร้านค้าปลวก :</td>
                <td height="22" width="35%" class="dotline01">
<%
	venId="";
	sql.delete(0, sql.length());
	sql.append("SELECT p.i_vendor, v.bus_name FROM lan:serv_venprj p, lan:stpvendr v WHERE p.i_company = '")
		.append(comId)
		.append("' AND p.i_project = '")
		.append(projId)
		.append("' AND i_type = '04' AND p.i_vendor = v.vend_code ORDER BY p.i_vendor");
	rs = stmt.executeQuery(sql.toString());
	if (rs != null) {
		if (rs.next() == true) {
			venId = doString.checkString(rs.getString("I_VENDOR"));
			out.print(doString.DisplayThai(rs.getString("BUS_NAME")));
		}// end while
		rs.close();
		rs=null;
	}
%>	
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
				<td class="item_tab2" width="200">ตารางการเข้าบริการ เดือน <%=DateUtil.TH_abbr_month[Integer.parseInt(chkMonth)-1]%> <%=chkYear%></td>
				<td class="item_tab3"></td>
				<td align="right">&nbsp;</td>
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
				<td width="100%" class="frmLR" align="center"
					style="padding:0px 4px 0px 4px">
				<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						<td width="5" valign="top"><img border="0"
							src="images/02Corn01.gif" width="5" height="5"></td>
						<td class="frmTop2">&nbsp;</td>
						<td width="5" valign="top" align="right"><img border="0"
							src="images/02Corn02.gif" width="5" height="5"></td>
					</tr>
				</table>
				
				
				<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						<td width="100%" class="frmLR2" align="center">
						<table border="0" width="100%" cellspacing="0" cellpadding="0">
							<tr>
								<td class="dotline01" height="22" width="50%" align="left">
								<a href="SERV_SaveTimeLst.jsp?seq=<%=seq-7%>"><< ย้อมกลับ</a>
								</td>
								<td class="dotline01" height="22" width="50%" align="right">
								<a href="SERV_SaveTimeLst.jsp?seq=<%=seq+7%>">ถัดไป >></a>
								</td>
							</tr>
						</table>
						</td>
					</tr>
				</table>
				<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						<td width="5" valign="bottom"><img border="0"
							src="images/02Corn03.gif" width="5" height="5"></td>
						<td class="frmBottom2">&nbsp;</td>
						<td width="5" valign="bottom" align="right"><img border="0"
							src="images/02Corn04.gif" width="5" height="5"></td>
					</tr>
				</table>
				<br style="font-size:2pt">
				<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						<td width="5" valign="top" bgcolor="#D7E6FF"><img border="0"
							src="images/02Corn01.gif" width="5" height="5"></td>
						<td class="frmTop2" bgcolor="#D7E6FF">&nbsp;</td>
						<td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img
							border="0" src="images/02Corn02.gif" width="5" height="5"></td>
					</tr>
				</table>
				<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						<td width="100%" class="frmL2">
						<table border="0" width="100%" cellspacing="0" cellpadding="0">
							<tr>
								<td width="16%" height="22" class="col_name02">&nbsp;</td>
								<td height="22" colspan="7" class="col_name02">วัน/เวลาที่ไม่สามารถจองได้</td>
							</tr>
							<tr>
								<td width="16%" class="col_name02Low">เวลา</td>
<%
	String strDay[] = new String[31];
	Hashtable day_list = new Hashtable();
	java.util.Vector daylist = new java.util.Vector(5);
	if (chkTimeList != null) {
		for (int c=0; c<chkTimeList.size(); c++) {
			ChkTime cTime = (ChkTime)chkTimeList.elementAt(c);
			if (cTime != null) {
				if (!cTime.isReserve()) {
					day = Integer.parseInt(cTime.getChkDate());
					if( !day_list.containsKey(cTime.getChkDate()) ){
						day_list.put(cTime.getChkDate(), new Integer(day));
					}
				}
			}
		}// end for
	}
	Enumeration e = day_list.keys();
	while( e. hasMoreElements() ){
		ChkTime aTime = new ChkTime();
		aTime.setChkTime((String)e.nextElement());
		daylist.addElement(aTime);	
	}
	Collections.sort(daylist, comparator);
	if (daylist != null) {
		for (int d=0; d<daylist.size(); d++) {
			ChkTime aTime = (ChkTime)daylist.elementAt(d);
			if (aTime != null) {
				strDay[d] = aTime.getChkTime();
			}
		}
	}
	


	String brTime = "";	
	for (i=seq; i<(seq+7); i++) {
%>
								<td width="12%" class="col_name02Low"><%if (i<31) { out.print(doString.checkString(strDay[i])); }%><br>&nbsp;</td>
<%	
	}// end for
%>	
							</tr>
<%
	curYear = Integer.parseInt(chkYear)-543;
	if (timelist != null) {
		for (int t=0; t<timelist.size(); t++) {
			ChkTime aTime = (ChkTime)timelist.elementAt(t);
			if (aTime != null) {
				brTime = aTime.getChkTime();
%>
							<tr height="50">
								<td width="16%" align="center" class="dotline02 ; item"><%=brTime%> <%=doString.DisplayThai(aTime.getDesc())%></td>
<%
				for (i=seq; i<(seq+7); i++) {
					
%>
								<td width="12%" align="center" class="dotline02">
<%
							if (chkTimeList != null) {
								for (int c=0; c<chkTimeList.size(); c++) {
									ChkTime cTime = (ChkTime)chkTimeList.elementAt(c);
									if (cTime != null) {
										if (!cTime.isReserve()) {
											if (i < 31) {
												if (cTime.getChkDate().equals(strDay[i]) && cTime.getChkTime().equals(brTime)) {
													out.print("<img src=\"images/i_pass_no.gif\" width=\"19\" height=\"16\">");											
													break;
												}
											}
										}
									}
								}
							}
%>								
								&nbsp;</td>
<%					
				}// end for
%>
							</tr>
<%			
			}
		}// end for
	}
%>							
						</table>
						</td>
					</tr>
				</table>
				<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						<td width="5" valign="bottom"><img border="0"
							src="images/02Corn03.gif" width="5" height="5"></td>
						<td class="frmBottom2">&nbsp;</td>
						<td width="5" valign="bottom" align="right"><img border="0"
							src="images/02Corn04.gif" width="5" height="5"></td>
					</tr>
				</table>
				<br style="font-size:2pt">
				<table border="0" width="100%" cellspacing="0" cellpadding="0">
				  <tr>
				    <td width="5" valign="top"><img border="0" src="images/02Corn01.gif" width="5" height="5"></td>
				    <td class="frmTop2">&nbsp;</td>
				    <td width="5" valign="top" align="right"><img border="0" src="images/02Corn02.gif" width="5" height="5"></td>
				  </tr>
				</table>				
				
				<table border="0" width="100%" cellspacing="0" cellpadding="0">
				  <tr>
				    <td width="100%" class="frmLR2" align="center">
				<table border="0" width="100%" cellspacing="0" cellpadding="0">
				  <tr>
				                      <td class="dotline01" height="22" width="50%" align="left"><a href="InitResvTimeServlet"><img src="images/i_pen.gif" width="14" height="16" border="0" align="absmiddle"> 
				                        Click เพื่อทำรายการจองใหม่</a></td>
				    <td class="dotline01" height="22" width="50%" align="right"> </td>
				    </tr>
				</table>
				</td>
				  </tr>
				</table>
				
				<table border="0" width="100%" cellspacing="0" cellpadding="0">
				  <tr>
				    <td width="5" valign="bottom"><img border="0" src="images/02Corn03.gif" width="5" height="5"></td>
				    <td class="frmBottom2">&nbsp;</td>
				    <td width="5" valign="bottom" align="right"><img border="0" src="images/02Corn04.gif" width="5" height="5"></td>
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
		ustmt.close();
		lstmt.close();
		conn.close();
		stmt = null;
		ustmt = null;
		lstmt = null;
		conn=null;
	} catch (Exception e) {
		System.out.println("ERROR SERV_SaveTimeLst.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (stmt != null) stmt.close();
			if (ustmt != null) ustmt.close();
			if (lstmt != null) lstmt.close();			
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
				<td width="150" class="act_tab2">&nbsp;
				</td>
				<td class="act_tab3"></td>
				
          <td class="act_tab4">&nbsp; <a
					href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif"
					align="absmiddle" width="50" height="15"></a></td>
			</tr>
		</table>
		</td>
	</tr>
</table>
<br style="font-size:30pt">
<TABLE border=0 cellspacing=0 cellpadding=0 width="780">
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
