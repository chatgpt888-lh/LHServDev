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
		if (status.equals("S")) {
			status = "Start Task";
		}
		if (status.equals("C")) {
			status = "Complete Task";
		}
		return status;		
	}

	public String getExpireDate(String closeDate, int liveTime) {
		int mnth = Integer.parseInt(closeDate.substring(5,7));
		int year = Integer.parseInt(closeDate.substring(0,4));
		liveTime += 1;
		for (int m=1; m<liveTime; m++) {
			mnth++;
			if (mnth == 13) {
				mnth = 1;
				year++;
			}			
		}// end for
		String endDate = doString.displayNumber("00", mnth)+"/"+Integer.toString(year+543);
		return endDate;
	}
%>


<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String empId = user.getEmpId();
String empName = "";
String comId = "LH";
String projId = "ALL";
String code = "";
if (!doString.checkString(request.getParameter("Project")).equals("")) {
	comId = request.getParameter("Project").substring(0,2);
	projId = request.getParameter("Project").substring(2);
}
code = comId + projId;
String brand = "";
Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
String chkMonth = "";
if( request.getParameter("chkMonth") != null ){
	chkMonth = doString.checkString(request.getParameter("chkMonth"));
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
	chkYear = doString.checkString(request.getParameter("chkYear"));
}

if (chkYear.equals("")) {
	chkYear = Integer.toString(rightNow.get(Calendar.YEAR));
}
String order = "i_chkseq, i_lock";
if( request.getParameter("order") != null ){
	order = request.getParameter("order");
}

String params = "Project="+comId+projId+"&chkMonth="+chkMonth+"&chkYear="+chkYear;
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
	rs = stmt.executeQuery("SELECT i_brand FROM lan:serv_brand WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
	if (rs != null) {
		if (rs.next() == true) {
			brand = doString.checkString(rs.getString(1));
		}
		rs.close();
		rs=null;
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
  function Cancel(frm) {
     frm.action="/LHServ/CancelChkLockServlet";
     frm.submit();
  }



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
	
function popupEditProfile(lockId){
	MM_openBrWindow('http://132.146.1.118/CALLService/CallOutboundFormController.do?cmd=popEditCustForm&comId=<%=comId%>&projId=<%=projId%>&lockId='+lockId+'&CALL_TYPE=OUT','INxx','resizable=yes,scrollbars=yes,toolbar=yes,menubar=no,location=no,directories=no, status=yes,width=760,height=420');
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
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td class="item_tab1"><img border="0" src="images/i_i.gif"
					align="absmiddle" width="20" height="20"></td>
				<td class="item_tab2" width="200">เลือกแปลงเพื่อนัด Check up</td>
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
							name='Project' class='box' style='width:250px' onChange="progress(); frmChckLock.submit();">
							<option value=''>------ กรุณาเลือก ------</option>
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
						<select name='chkMonth' class='box' style="width:75px" onChange="progress(); frmChckLock.submit();">
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
						</select> 
						<select name='chkYear' class='box' style="width:55px">
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
	curYear = curYear+543;
%> 							
						</select>&nbsp;&nbsp;&nbsp;<a href="javascript:progress(); frmChckLock.submit();"><img border="0" src="images/bu_go.gif"
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
						<td width="3%" class="col_name">Chk</td>					
						<td width="4%" class="col_name">ลำดับที่</td>
						<td width="6%" class="col_nameO"><a href="SERV_ChkLckLst.jsp?<%=params%>&order=i_lock, i_chkseq, i_status">แปลงขาย</a>
<%
	if (order.equals("i_lock, i_chkseq, i_status")) {
		out.print("&nbsp;<img src=\"images/i_down.gif\" width=\"9\" height=\"9\">");
	}
%>						
						</td>
						<td width="5%" class="col_nameO"><a href="SERV_ChkLckLst.jsp?<%=params%>&order=i_chkseq, i_lock">ครั้งที่</a>
<%
	if (order.equals("i_chkseq, i_lock")) {
		out.print("&nbsp;<img src=\"images/i_down.gif\" width=\"9\" height=\"9\">");
	}
%>						
						</td>
						<td width="11%" class="col_name">วัน/เวลานัด Check up</td>
						<td width="8%" class="col_name">เลขที่ใบแจ้งนัด</td>
						<td width="9%" class="col_nameO"><a href="SERV_ChkLckLst.jsp?<%=params%>&order=i_status, i_chkseq, i_lock">สถานะ</a>
<%
	if (order.equals("i_status, i_chkseq, i_lock")) {
		out.print("&nbsp;<img src=\"images/i_down.gif\" width=\"9\" height=\"9\">");
	}
%>												
						</td>
						<td width="5%" class="col_name">บ้านเลขที่</td>
						<td width="10%" class="col_name">ชื่อลูกค้า</td>
						<td width="10%" class="col_name">เบอร์โทรศัพท์</td>
						<td width="8%" class="col_nameO"><a href="SERV_ChkLckLst.jsp?<%=params%>&order=d_close_law">วันที่โอน</A>
<%
	if (order.equals("d_close_law")) {
		out.print("&nbsp;<img src=\"images/i_down.gif\" width=\"9\" height=\"9\">");
	}
%>												
						</td>
						<td width="7%" class="col_name">End Date</td>
						<td width="14%" class="col_name">ร้านค้า</td>
					</tr>
<%
	String lockId = "";
	String time = "";
	String closeDate = "";
	String expireDate = "";
	String vendor = "";
	int seqNo = 0;
	int bckMnth[] = new int[2];
	bckMnth[0]=6;
	bckMnth[1]=12;
	boolean cancel = false;
	i=0;
//System.out.println("SELECT DISTINCT i_lock, i_chkseq, i_time, i_status, i_day, i_docno, n_status, i_house, n_name, i_tel, d_close_law, c_comment FROM lan:serv_chklock WHERE i_session = "+sessionId+" AND user_id = '"+userId+"' AND i_company = '"+comId+"' AND i_project = '"+projId+"' ORDER BY "+order);
	rsChkup = ustmt.executeQuery("SELECT DISTINCT i_lock, i_chkseq, i_time, i_status, i_day, i_docno, n_status, i_house, n_name, i_tel, d_close_law, c_comment FROM lan:serv_chklock WHERE i_session = "+sessionId+" AND user_id = '"+userId+"' AND i_company = '"+comId+"' AND i_project = '"+projId+"' ORDER BY "+order);
	if (rsChkup != null) {
		while (rsChkup.next() == true) {
			i++;
			lockId = doString.checkString(rsChkup.getString("I_LOCK"));
//System.out.println(lockId);
			seqNo = rsChkup.getInt("I_CHKSEQ");
			closeDate = doString.checkString(rsChkup.getString("D_CLOSE_LAW"));
			expireDate = getExpireDate(closeDate, bckMnth[seqNo-1]);
			cancel = false;
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
			vendor = "";
			rs = stmt.executeQuery("SELECT DISTINCT v.ven_no, v.ven_name FROM lan:accpohdr p, lan:vendor v WHERE p.i_company = '"+comId+"' AND p.i_project = '"+projId+"' AND p.i_lock = '"+lockId+"' AND p.grp_no = 'F4' AND p.f_status = 'OPN' AND p.i_vendor = v.ven_no ORDER BY v.ven_no");
			if (rs != null) {
				while (rs.next() == true) {
					vendor += doString.checkString(rs.getString(2))+",";
				}
				rs.close();
				rs=null;
			}
			vendor = doString.DisplayThai(vendor);
			
			rs = stmt.executeQuery("SELECT i_lock FROM lan:serv_canchkup WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lock = '"+lockId+"' AND i_chkseq = "+seqNo);
			if (rs != null) {
				if (rs.next() == true) {
					cancel = true;
				}
				rs.close();
				rs=null;
			}
%>
					<tr>
						<td width="3%" align="center" class="dotline">
<%
			if (rsChkup.getInt("I_STATUS") == 2) {
%>							
						<input type="checkbox" name="chkLock" value="<%=lockId%><%=seqNo%>">
<%
			} else {
				out.print("&nbsp;");
			}
%>						

						</td>					
						<td width="4%" align="center" class="dotline"><%=i%></td>
						<td width="6%" class="dotline" align="center">
<%
			if (cancel) {
					out.print("<font color=red>*</font>");
			}
			if (rsChkup.getInt("I_STATUS") == 1 || rsChkup.getInt("I_STATUS") == 2 || rsChkup.getInt("I_STATUS") == 3) {
%>						
						<a href="InitSetLockServlet?Project=<%=comId%><%=projId%>&chkMonth=<%=chkMonth%>&chkYear=<%=curYear%>&lockId=<%=lockId%>&seqNo=<%=seqNo%>">
<%
			}
%>						
							<%=lockId%>
							</td>
						<td width="5%" class="dotline" align="center"><%=seqNo%></td>
						<td width="11%" align="center" class="dotline"><%=doString.checkString(rsChkup.getString("I_DAY"))%>/<%=doString.DisplayThai(time)%></td>
						<td width="8%" align="center" class="dotline"><%=doString.checkString(rsChkup.getString("I_DOCNO"),"&nbsp;")%></td>
						<td width="9%" align="center" class="dotline"><%=doString.DisplayThai(rsChkup.getString("N_STATUS"))%></td>
						<td width="5%" class="dotline" align="center"><%=doString.checkString(rsChkup.getString("I_HOUSE"))%>&nbsp;</td>
						<td width="10%" align="left" class="dotline"><%=doString.DisplayThai(rsChkup.getString("N_NAME"))%>&nbsp;</td>
						<td width="10%" align="left" class="dotline"><%=doString.DisplayThai(rsChkup.getString("I_TEL"))%>&nbsp;</td>
						<td width="8%" align="center" class="dotline"><%=DateUtil.ifxToThaiDateNoTime(rsChkup.getString("D_CLOSE_LAW"))%></td>
						<td width="7%" align="center" class="dotline"><%=expireDate%></td>
						<td width="14%" align="left" class="dotline"><%=vendor%>&nbsp;</td>
					</tr>
<%	
			sql.delete(0,sql.length());
			sql.append("SELECT i_tel_ctasia, n_customer FROM lan:svc_telno WHERE i_company = '")
				.append(comId)
				.append("' AND i_project = '")
				.append(projId)
				.append("' AND i_lock = '")
				.append(lockId)
				.append("' AND d_update IN (SELECT MAX(d_update) FROM lan:svc_telno WHERE i_company = '")
				.append(comId)
				.append("' AND i_project = '")
				.append(projId)
				.append("' AND i_lock = '")
				.append(lockId+"')");
			rs = stmt.executeQuery(sql.toString());
			if (rs != null) {
				if (rs.next() == true) {
%>
					<tr>
						<td width="3%" align="center" class="dotline">&nbsp;</td>					
						<td width="4%" align="center" class="dotline">&nbsp;</td>
						<td width="6%" class="dotline" align="center">&nbsp;</td>
						<td width="5%" class="dotline" align="center">&nbsp;</td>
						<td width="11%" align="center" class="dotline">&nbsp;</td>
						<td width="8%" align="center" class="dotline">&nbsp;</td>
						<td width="9%" align="center" class="dotline">&nbsp;</td>
						<td width="5%" class="dotline" align="center">&nbsp;</td>
						<td width="10%" align="left" class="dotline"><font color="red">*</font>&nbsp;<a href="javascript:popupEditProfile('<%=lockId%>');"><%=doString.DisplayThai(rs.getString("N_CUSTOMER"))%></a>&nbsp;</td>
						<td width="10%" align="left" class="dotline"><font color="red">*&nbsp;<%=doString.DisplayThai(rs.getString("I_TEL_CTASIA"))%></font>&nbsp;</td>
						<td width="8%" align="center" class="dotline">&nbsp;</td>
						<td width="7%" align="center" class="dotline">&nbsp;</td>
						<td width="14%" align="left" class="dotline">&nbsp;</td>
					</tr>
<%
				}
				rs.close();
				rs=null;
			}

		}// end while
		rsChkup.close();
		rsChkup=null;
	}
	if (i==0) {
%>
					<tr>
						<td width="3%" align="center" class="dotline">&nbsp;</td>					
						<td width="4%" align="center" class="dotline">&nbsp;</td>
						<td width="6%" class="dotline" align="center">&nbsp;</td>
						<td width="5%" class="dotline" align="center">&nbsp;</td>
						<td width="11%" align="center" class="dotline">&nbsp;</td>
						<td width="8%" align="center" class="dotline">&nbsp;</td>
						<td width="9%" align="center" class="dotline">&nbsp;</td>
						<td width="5%" class="dotline" align="center">&nbsp;</td>
						<td width="10%" align="left" class="dotline">&nbsp;</td>
						<td width="10%" align="left" class="dotline">&nbsp;</td>
						<td width="8%" align="center" class="dotline">&nbsp;</td>
						<td width="7%" align="center" class="dotline">&nbsp;</td>
						<td width="14%" align="center" class="dotline">&nbsp;</td>
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
		<br style="font-size:5pt">
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="100%"><font color="red">* รายละเอียดชื่อและเบอร์โทรศัพท์ผู้แจ้ง</font></td>
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
		System.out.println("ERROR SERV_ChkLckLst.jsp : " + e.getMessage());
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
				<td width="75" class="act_tab2">
				<a href="javascript:Cancel(frmChckLock)"><img
					border="0" src="images/act_cancel.gif"
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
