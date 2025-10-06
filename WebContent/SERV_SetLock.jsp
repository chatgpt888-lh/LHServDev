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
<TITLE>ระบุแปลง Check up</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
<!--
function ScrollDate(frm, direct) {
	frm.direction.value = direct;
	frm.action = "/LHServ/ScrollResvTimeServlet";
	frm.submit();
}

function Save(frm) {
	frm.action = "/LHServ/SetChkupLockServlet";
	frm.submit();
}

function ViewChckLock(frm) {
	frm.action = "/LHServ/SERV_SetLockDetl.jsp";
	frm.submit();
}

function Trim( str ) {
	var resultStr = "";
	
	resultStr = TrimLeft(str);
	resultStr = TrimRight(resultStr);
	
	return resultStr;
} // end Trim

function TrimLeft( str ) {
	var resultStr = "";
	var i = len = 0;
	
	// Return immediately if an invalid value was passed in
	if (str+"" == "undefined" || str == null)	
		return null;

	// Make sure the argument is a string
	str += "";

	if (str.length == 0) 
		resultStr = "";
	else {	
  		// Loop through string starting at the beginning as long as there
  		// are spaces.
		//	  	len = str.length - 1;
		len = str.length;
					
  		while ((i <= len) && (str.charAt(i) == " "))
			i++;
	
   	// When the loop is done, we're sitting at the first non-space char,
 		// so return that char plus the remaining chars of the string.
  		resultStr = str.substring(i, len);
  	}
			
  	return resultStr;
} // end TrimLeft
			
function TrimRight( str ) {
	var resultStr = "";
	var i = 0;
	
	// Return immediately if an invalid value was passed in
	if (str+"" == "undefined" || str == null)	
		return null;

	// Make sure the argument is a string
	str += "";
		
	if (str.length == 0) 
		resultStr = "";
	else {
  		// Loop through string starting at the end as long as there
 		// are spaces.
  		i = str.length - 1;
  		while ((i >= 0) && (str.charAt(i) == " "))
 			i--;
			 			
 			// When the loop is done, we're sitting at the last non-space char,
	 		// so return that char plus all previous chars of the string.
	  		resultStr = str.substring(0, i + 1);
	  	}
	  	
	  	return resultStr;  	
} // end TrimRight
function selAll(frm, chkDay) {
	var time = frm.chkTime;
	var day = "";
     if (time != null) {
		if (time.length != null) {
			for (var i=0;i<time.length;i++) {
				day	= Trim(time[i].value);
				if (day != "") {
					day = day.substring(0,2);
					if (day == chkDay) {
						time[i].checked = true;
					}
				}
			}
		}
	}
}
//-->
</script>
<base target="_self">


</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM NAME="frmSetLock" METHOD=POST ACTION="/LHServ/InitSetLockServlet">
<input type="hidden" name="direction" value="">

<table border="0" width="780" cellspacing="0" cellpadding="0">
	<tr>
		<td width="100%" class="BD">
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="80%" class="bigh"><img border="0"
					src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
				ระบุแปลง Check up</td>
				<td width="20%" class="bigh" align="right"></td>
			</tr>
		</table>
		<br style="font-size:10pt">
<%
String userId = user.getUserID();
ResvTime resv_time = (ResvTime)session.getAttribute("resv_time");
String empId = "";
String empName = "";
String resvDate = "";
String chkMonth = "";
String chkYear = "0";
String comId = "";
String projId = "";
String lockId = "";
int seqNo = 0;
String site = "";
String brand = "";
String vendor = "";
String group = "";
String comment = "";
java.util.Date begRegDate = null;
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
	lockId = resv_time.getLockId();
	seqNo = resv_time.getSeqNo();
	site = comId + projId;
	vendor = resv_time.getVendor();
	group = resv_time.getGroup();
	week = resv_time.getWeek();
	comment = resv_time.getComment();
	firstDay = resv_time.getFirstDayOfWeek();
	begRegDate = resv_time.getBegRegisDate();
	chkTimeList = resv_time.getChkTimeList();
}
Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);

java.util.Calendar currentCal = java.util.Calendar.getInstance(Locale.ENGLISH);
int curMnth = Integer.parseInt(chkMonth)-1;
int curYear = Integer.parseInt(chkYear)-543;
String backPage = "SERV_ChkLckLst.jsp?Project="+comId+projId+"&chkMonth="+chkMonth+"&chkYear="+curYear;
currentCal = new GregorianCalendar(curYear, curMnth, 1);
int dayOfWeek = 0;
if (week == 1) {
	dayOfWeek = currentCal.get(currentCal.DAY_OF_WEEK)-1;
}
int daysInMonth = currentCal.getActualMaximum(currentCal.DAY_OF_MONTH);
String mnthDate = Integer.toString(curYear)+"-"+chkMonth+"-";
String chkDate = "";
int mnth = 0;
int year = 0;
SimpleDateFormat formatter=null;
formatter = new SimpleDateFormat("yyyy-MM-dd", Locale.US);
boolean chkDay[] = new boolean[7];
boolean holiday[] = new boolean[7];
boolean busy[] = new boolean[7];
int chkup_day[] = new int[7];
String optionSelected = null;
String code = "";
String venId = "";
String groupId = "";
String bgColor = "";
String checked = "";
int i=0;
int day = 0;
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
ResultSet rsChkup = null;
ResultSet rsLock = null;
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
%>
		<input type="hidden" name="Mode" value="C">
		<input type="hidden" name="targetPage" value="SERV_SetLock.jsp">
		<input type="hidden" name="Project" value="<%=comId%><%=projId%>">
		<input type="hidden" name="chkMonth" value="<%=chkMonth%>">
		<input type="hidden" name="chkYear" value="<%=chkYear%>">
		<input type="hidden" name="lockId" value="<%=lockId%>">
		<input type="hidden" name="seqNo" value="<%=seqNo%>">
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td class="item_tab1"><img border="0" src="images/i_i.gif"
					align="absmiddle" width="20" height="20"></td>
				<td class="item_tab2" width="200">รายละเอียด</td>
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
						
                <td height="22" class="item ; dotline01" width="13%">เดือน/ปี :</td>
                <td height="22" width="35%" class="dotline01"><%=month[Integer.parseInt(chkMonth)-1]%> <%=chkYear%>
                </td>
					</tr>
					
					<tr>
						<td class="item ; dotline01" height="22" width="12%">ร้านค้า :</td>
						<td height="22" width="40%" class="dotline01">
<%
	i=0;
	sql.delete(0, sql.length());
	sql.append("SELECT COUNT(*) AS NUM_VEN FROM lan:serv_venprj WHERE i_company = '")
		.append(comId)
		.append("' AND i_project = '")
		.append(projId)
		.append("' AND i_type = '03'");
	rs = stmt.executeQuery(sql.toString());
	if (rs != null) {
		if (rs.next() == true) {
			i=rs.getInt("NUM_VEN");
		}
		rs.close();
		rs=null;
	}
	if (i>1) {
%>
					<select name='Vendor' class='box' style="width:200px" onChange="frmSetLock.submit();">
						<option value='00000|00'>----- เลือกร้านค้า -----</option>
<%
		sql.delete(0, sql.length());
		sql.append("SELECT p.i_vendor, p.i_group, v.bus_name FROM lan:serv_venprj p, lan:stpvendr v WHERE p.i_company = '")
			.append(comId)
			.append("' AND p.i_project = '")
			.append(projId)
			.append("' AND p.i_type = '03' AND p.i_vendor = v.vend_code ORDER BY p.i_vendor");
		rs = stmt.executeQuery(sql.toString());
		if (rs != null) {
			while (rs.next() == true) {
				venId = doString.checkString(rs.getString("I_VENDOR"));
				optionSelected = "";
				if (venId.equals(vendor) ) {
					optionSelected = "selected";
				}			
%>
							<option value='<%=venId%>|<%=doString.checkString(rs.getString("I_GROUP"))%>' <%=optionSelected%>><%=doString.DisplayThai(rs.getString("BUS_NAME"))%></option>
<%		
			}// end while
			rs.close();
			rs=null;
		}
%>						
						</select>
<%
	} else {
		vendor = "";
		group = "";
		sql.delete(0, sql.length());
		sql.append("SELECT i_vendor, i_group FROM lan:serv_venprj WHERE i_company = '")
			.append(comId)
			.append("' AND i_project = '")
			.append(projId)
			.append("' AND i_type = '03'");
		rs = stmt.executeQuery(sql.toString());
		if (rs != null) {
			if (rs.next() == true) {
	   			vendor = doString.checkString(rs.getString("I_VENDOR"));
	   			group = doString.checkString(rs.getString("I_GROUP"));
			}
			rs.close();
			rs=null;
		}
		out.print(" <input type=\"hidden\" name=\"Vendor\" value=\""+vendor+"|"+group+"\">");
		rs = stmt.executeQuery("SELECT bus_name FROM lan:stpvendr WHERE vend_code = '"+vendor+"'");
		if (rs != null) {
			if (rs.next() == true) {
				out.print(doString.DisplayThai(rs.getString("BUS_NAME")));
			}
			rs.close();
			rs=null;
		}
	}
	i=0;
%>							
						</td>
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
						<td class="item ; dotline01" height="22" width="12%">ร้านค้าปลวก
						:</td>
						<td height="22" width="40%" class="dotline01">
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
                <td height="22" class="item ; dotline01" width="13%">แปลง :</td>
                <td height="22" width="35%" class="dotline01"><%=lockId%></td>
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
				<td align="right"><img src="images/i_list.gif" width="18"
					height="18">&nbsp;<a href="javascript:ViewChckLock(frmSetLock)">รายละเอียดแปลง Check up</a></td>
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
<%
	for (i=1; i<=dayOfWeek; i++) {}// end for
	day = firstDay;
	backDay = firstDay-7;
	backWeek = week-1;
	if (backDay <= 0) backDay = 1;
	if (backWeek <= 0) backWeek = 1;
	for (; i<=7; i++) {
		day++;
	}// end for
	nextDay = day;
	nextWeek = week + 1;
	if (nextDay > daysInMonth) {
		nextDay = firstDay;
		nextWeek = week;
	}
%>							
						<table border="0" width="100%" cellspacing="0" cellpadding="0">
							<tr>
								<td class="dotline01" height="22" width="50%" align="left">
								<a href="javascript:ScrollDate(frmSetLock,'B');"><< ย้อนกลับ</a>
								<input type="hidden" name="BackWeek" value="<%=backWeek%>">																
								<input type="hidden" name="BackDay" value="<%=backDay%>">								
								</td>
								<td class="dotline01" height="22" width="50%" align="right">
								<a href="javascript:ScrollDate(frmSetLock,'N');">ถัดไป >></a>
								<input type="hidden" name="NextWeek" value="<%=nextWeek%>">																
								<input type="hidden" name="NextDay" value="<%=nextDay%>">								
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
								<td height="22" colspan="7" class="col_name02">สัปดาห์ที่ <%=week%>
								<input type="hidden" name="CurWeek" value="<%=week%>">	
								</td>
							</tr>
							
							<tr>
								<td width="16%" class="col_name02Low">เวลา</td>
<%
	Arrays.fill(chkup_day, 0);
	Arrays.fill(busy, false);
	String brTime = "";	
	String chkTime = "";
	String meet_emp = "";
	String meet_user = "";	
	String meet_com = "";
	String meet_proj = "";
	String meet_lock = "";
	int meet_seq = 0;
	int numChkTime=0;	
	for (i=1; i<=dayOfWeek; i++) {
		chkDay[i-1]=false;
		holiday[i-1]=false;
		chkup_day[i-1]=0;
%>
								<td width="12%" class="col_name02Low"><%=DayOfWeek[i-1]%><br>&nbsp;</td>
<%	
	}// end for
	day = firstDay;
	curMnth = Integer.parseInt(chkMonth);
	curYear = Integer.parseInt(chkYear)-543;
	for (; i<=7; i++) {
		if (day <= daysInMonth) {
			chkDate = Integer.toString(curYear)+"-"+chkMonth+"-"+doString.displayNumber("00", day);
			rsChkup = ustmt.executeQuery("SELECT i_company, i_project FROM lan:serv_chkupdt WHERE i_month = '"+mnthDate+"01' AND i_vendor = '"+vendor+"' AND i_group = '"+group+"' AND d_chckup = '"+chkDate+"' AND (TRIM(i_company) || TRIM(i_project) != '"+comId+projId+"')");
			if (rsChkup != null) {
				if (rsChkup.next() == true) {
					busy[i-1] = true;
				}
				rsChkup.close();
				rsChkup=null;
			}
		
			chkup_day[i-1] = day;
			chkDay[i-1]=true;							
/*			
			currentCal = new GregorianCalendar(curYear, curMnth-1, day);			
			if (currentCal.getTime().after(begRegDate)) {
				chkDay[i-1]=true;				
			} else {
				chkDay[i-1]=false;		
				chkup_day[i-1]=0;
			}
*/			
			chkDate = mnthDate+doString.displayNumber("00", day);
			if (DateUtil.isHoliday(formatter.parse(chkDate))) {
				holiday[i-1]=true;
				rs = stmt.executeQuery("SELECT d_holiday, f_chckup FROM lan:serv_holdy WHERE i_vendor = '"+comId+projId+"' AND d_holiday = '"+chkDate+"'");
				if (rs != null) {
					if (rs.next() == true) {
						if (doString.checkString(rs.getString("F_CHCKUP")).equals("Y")) {
							holiday[i-1]=false;
						}
					}
					rs.close();
					rs=null;
				}				
			}
			rs = stmt.executeQuery("SELECT d_holiday, f_chckup FROM lan:serv_holdy WHERE i_vendor = 'LH' AND d_holiday = '"+chkDate+"'");
			if (rs != null) {
				if (rs.next() == true) {
					holiday[i-1]=true;
					if (doString.checkString(rs.getString("F_CHCKUP")).equals("Y")) {
						holiday[i-1]=false;
					}
				}
				rs.close();
				rs=null;
			}
			if (holiday[i-1]==false) {

				rs = stmt.executeQuery("SELECT d_holiday, f_chckup FROM lan:serv_holdy WHERE i_vendor = '"+vendor+"' AND d_holiday = '"+chkDate+"'");
				if (rs != null) {
					if (rs.next() == true) {
						holiday[i-1]=true;
						if (doString.checkString(rs.getString("F_CHCKUP")).equals("Y")) {
							holiday[i-1]=false;
						}
					}
					rs.close();
					rs=null;
				}
			}

			if (holiday[i-1]==false) {
				rs = stmt.executeQuery("SELECT d_holiday, f_chckup FROM lan:serv_holdy WHERE i_vendor = '"+venId+"' AND d_holiday = '"+chkDate+"'");
				if (rs != null) {
					if (rs.next() == true) {
						holiday[i-1]=true;
						if (doString.checkString(rs.getString("F_CHCKUP")).equals("Y")) {
							holiday[i-1]=false;
						}
					}
					rs.close();
					rs=null;
				}
			}
%>
								<td width="12%" class="col_name02Low"><%=DayOfWeek[i-1]%><br>
								<%=day%></td>

<%		
		} else {
			chkup_day[i-1]=0;
			chkDay[i-1]=false;	
			holiday[i-1]=false;	
%>
								<td width="12%" class="col_name02Low"><%=DayOfWeek[i-1]%><br>&nbsp;</td>
<%		
		}
		day++;
	}// end for
%>								
							</tr>
							<tr height="0">
								<td width="16%" align="center" class="dotline02 ; item"></td>
<%
	for (i=0; i<7; i++) {
		if (holiday[i]) {
%>
								<td rowspan="<%=num_time+1%>" align="center" class="dotline02" bgcolor="#F0F0F0" background='images/bg_holiday.gif' style='background-repeat:repeat-y ; background-position:center middle'></td>
<%				
		} else {
%>
								<td width="12%" align="center" class="dotline02"></td>
<%	
		}
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
								<td width="16%" align="center" class="dotline02 ; item"><%=doString.DisplayThai(aTime.getDesc())%></td>
<%
				for (i=0; i<7; i++) {
				
					if (holiday[i]) {
					
					} else {
%>
								<td width="12%" align="center" class="dotline02"
<%					
						if (!chkDay[i]) {
							out.print(" bgcolor=\"#F0F0F0\">"); //Red							
						}
						
/*						
						if (busy[i]) {
							bgColor = "rgb(255,210,255)";
						}
*/						
						if (chkup_day[i] > 0) {
							code = doString.displayNumber("00",chkup_day[i]);
							chkDate = Integer.toString(curYear)+"-"+chkMonth+"-"+code;
							numChkTime=0;
							checked = "";							
							rs = stmt.executeQuery("SELECT c_time FROM lan:serv_bctime WHERE i_brand = '"+brand+"' AND b_time = '"+brTime+"' ORDER BY c_time");
							if (rs != null) {
								while (rs.next() == true) {
									chkTime = doString.checkString(rs.getString("C_TIME"));
									rsChkup = ustmt.executeQuery("SELECT i_employ, i_company, i_project, i_lock, i_chkseq FROM lan:serv_chkupdt WHERE i_month = '"+mnthDate+"01' AND i_vendor = '"+vendor+"' AND i_group = '"+group+"' AND d_chckup = '"+chkDate+"' AND i_time = '"+chkTime+"'");
									
									if (rsChkup != null) {
										if (rsChkup.next() == true) {//Meet
											numChkTime++;
											meet_emp = doString.checkString(rsChkup.getString("I_EMPLOY"));										
											meet_com = doString.checkString(rsChkup.getString("I_COMPANY"));										
											meet_proj = doString.checkString(rsChkup.getString("I_PROJECT"));																					
											meet_lock = doString.checkString(rsChkup.getString("I_LOCK"));																																
											meet_seq = rsChkup.getInt("I_CHKSEQ");
											meet_user = meet_emp;											
											rsLock = lstmt.executeQuery("SELECT user_id FROM docflow:useracl WHERE i_employ = '"+meet_emp+"'");
											if (rsLock != null) {
												if (rsLock.next() == true) {
													meet_user = doString.checkString(rsLock.getString("USER_ID"));																																	
												}
												rsLock.close();
												rsLock=null;
											}
										}
										rsChkup.close();
										rsChkup=null;
									}
								}// end while check time
								rs.close();
								rs=null;
							}
							checked = "";
							if (chkTimeList != null) {
								for (int c=0; c<chkTimeList.size(); c++) {
									ChkTime cTime = (ChkTime)chkTimeList.elementAt(c);
									if (cTime != null) {
										if (cTime.getChkDate().equals(code) && cTime.getChkTime().equals(brTime)) {
											checked = "checked";
											break;
										}
									}
								}// end for
							}
							
							if (numChkTime > 0) {
								if (meet_com.equals(comId) && meet_proj.equals(projId)) {
									if (meet_emp.equals(empId)) {
										if (meet_lock.equals("")) {
											out.print(" bgcolor=\"rgb(255,255,180)\">"); //Yellow
											out.print("<input type=\"radio\" name=\"chkTime\" value=\""+code+"-"+brTime+"\" "+checked+">");
										} else {
											if (meet_lock.equals(lockId) && (meet_seq == seqNo)) {
												out.print(" bgcolor=\"rgb(255,255,180)\">"); //Yellow
												out.print("<input type=\"radio\" name=\"chkTime\" value=\""+code+"-"+brTime+"\" "+checked+">");																						
											} else {
												out.print(" bgcolor=\"rgb(255,255,180)\">"); //Yellow
												out.print(meet_user+"<br>"+meet_lock);
											}
										}
										
									} else {
										out.print(" bgcolor=\"rgb(255,210,255)\">"); //Red
										out.print(meet_user);
										if (meet_lock.equals(lockId) && (meet_seq == seqNo)) {
											out.print("<br>"+meet_lock);
										}
									}
								} else {
									out.print(" bgcolor=\"rgb(255,210,255)\">"); //Red
									out.print("&nbsp;");
								}
							} else {
								out.print(" bgcolor=\"rgb(200,255,200)\">"); //Green
								out.print("&nbsp;");
/*							
								rsChkup = ustmt.executeQuery("SELECT i_company, i_project FROM lan:serv_chkupdt WHERE i_month = '"+mnthDate+"01' AND i_vendor = '"+vendor+"' AND i_group = '"+group+"' AND d_chckup = '"+chkDate+"' AND i_company != '"+comId+"' AND i_project != '"+projId+"'");
								if (rsChkup != null) {
									if (rsChkup.next() == true) {
										out.print("&nbsp;");
									} else {
										if (chkDay[i]) {
											checked = "";
											code = doString.displayNumber("00",chkup_day[i]);
											if (chkTimeList != null) {
												for (int c=0; c<chkTimeList.size(); c++) {
													ChkTime cTime = (ChkTime)chkTimeList.elementAt(c);
													if (cTime != null) {
														if (cTime.getChkDate().equals(code) && cTime.getChkTime().equals(brTime)) {
															checked = "checked";
															break;
														}
													}
												}// end for
											}
										
											out.print("<input type=\"checkbox\" name=\"chkTime\" value=\""+code+"-"+brTime+"\""+checked+">");
										} else {
											out.print("&nbsp;");
										}
									}
									rsChkup.close();
									rsChkup=null;
								}
*/								
							}
						}
%>								
								</td>
<%					
					}
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
<%
	rs = stmt.executeQuery("SELECT DISTINCT DAY(d_holiday) AS HOL_DAY, n_holiday FROM lan:serv_holdy WHERE (i_vendor = 'LH' OR i_vendor = '"+vendor+"') AND d_holiday >= '"+mnthDate+"01' AND d_holiday <= '"+mnthDate+Integer.toString(daysInMonth)+"' ORDER BY 1");
	if (rs != null) {
		while (rs.next() == true) {
%>
					<tr>
						<td width="5%" align="left" class="dotline01"><%=rs.getInt("HOL_DAY")%> <%=doString.DisplayThai(rs.getString("N_HOLIDAY"))%></td>
					</tr>
<%		
		}// end while
		rs.close();
		rs=null;
	}
	rs = stmt.executeQuery("SELECT DISTINCT DAY(d_holiday) AS HOL_DAY, n_holiday FROM lan:serv_holdy WHERE i_vendor = '"+venId+"' AND d_holiday >= '"+mnthDate+"01' AND d_holiday <= '"+mnthDate+Integer.toString(daysInMonth)+"' ORDER BY 1");
	if (rs != null) {
		while (rs.next() == true) {
%>				
					<tr>
						<td width="5%" align="left" class="dotline01"><%=rs.getInt("HOL_DAY")%> <%=doString.DisplayThai(rs.getString("N_HOLIDAY"))%></td>
					</tr>
<%		
		}// end while
		rs.close();
		rs=null;
	}
%>
					<tr>
						<td width="5%" align="left" class="dotline01">&nbsp;</td>
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
			                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
			                <td class="item_tab2" width="160">หมายเหตุ</td>
			                <td class="item_tab3"></td>
			                <td class="textgray">&nbsp;
			                </td>
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
			    <td width="100%" class="frmLRpad01" valign="top">
			    <textarea rows="5" name="Comment" class="box" style="width:100%" cols="20"><%=doString.DisplayThai(comment)%></textarea>
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
		System.out.println("ERROR SERV_SetLock.jsp : " + e.getMessage());
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
				<td width="150" class="act_tab2">
				<a href="javascript:Save(frmSetLock)"><img
					border="0" src="images/act_save.gif"
					onMouseOut=nereidFade(this,70,50,5)
					onMouseOver=nereidFade(this,100,50,5)
					style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
				</td>
				<td class="act_tab3"></td>
				
          <td class="act_tab4"><a href="<%=backPage%>"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp; <a
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