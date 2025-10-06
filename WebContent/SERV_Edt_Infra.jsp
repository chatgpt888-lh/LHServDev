<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.sql.*" %>
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
	private int MAX_LINE = 30;
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
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_Edt_Infra.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

String empId = user.getEmpId();
Vendor vendor = (Vendor) session.getAttribute("Vendor");
String payer = "";
if (vendor != null) {
	payer = vendor.getPreName()+" "+vendor.getName()+" "+vendor.getSurName();
}
String docNo = doString.checkString(request.getParameter("docNo"));
String comId = "";
String projId = "";
String site = "";
String sortId = "";
int intentNo = 0;
int custNo1 = 0;
int custNo2 = 0;
String custName = "";
String custType = "";
String startDate = "";
String month = "";
String year = "";
String betweenDate = "";
String endDate = "";
double amount = 0;
double recvAmnt = 0;
double accrueAmnt = 0;
SimpleDateFormat th_formatter = new SimpleDateFormat("MMMM/yyyy", new Locale("th","TH"));
SimpleDateFormat en_formatter = new SimpleDateFormat("yyyy-MM-dd", new Locale("en","US"));
boolean cancel = true;
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
	sql.delete(0, sql.length());
	sql.append("SELECT s_receive FROM lan:serv_payin WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+docNo+"' AND s_receive > 0");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	if (rs != null) {
		if (rs.next() == true) {
			cancel = false;
		}
		rs.close();
		rs=null;
	}	
	sql.delete(0, sql.length());
	sql.append("SELECT i.i_company, i.i_project, p.n_project, i.i_sort, i.i_lor, i.d_keyin, i.d_start, i.d_end, i.n_custo, i.i_inf_custo, i.i_infra, NVL(i.z_infra,0) AS INF_AMT, NVL(i.z_recv_infra,0) AS RECV_AMT FROM lan:serv_infhd i, lan:acxprojt p WHERE i.i_docno = '"+docNo+"' AND i.i_company = p.i_company AND i.i_project = p.i_project");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	if (rs != null) {
		if (rs.next() == true) {
			comId = doString.checkString(rs.getString("I_COMPANY"));
			projId = doString.checkString(rs.getString("I_PROJECT"));
			site = doString.checkString(doString.DisplayThai(rs.getString("N_PROJECT")));
			sortId = doString.checkString(rs.getString("I_SORT"));
			startDate = doString.checkString(doString.DisplayThai(rs.getString("D_START")));
			endDate = doString.checkString(doString.DisplayThai(rs.getString("D_END")));			
			custName = doString.checkString(doString.DisplayThai(rs.getString("N_CUSTO")));
			custType = doString.checkString(rs.getString("I_INF_CUSTO"));
			amount = rs.getDouble("INF_AMT");
			recvAmnt = rs.getDouble("RECV_AMT");
			accrueAmnt = amount - recvAmnt;
			java.util.Date frmDate = en_formatter.parse(startDate);
			java.util.Date toDate = en_formatter.parse(endDate);	
			betweenDate = Period.getBetween(startDate, endDate);
		}
		rs.close();
		rs=null;
	}
	sql.delete(0, sql.length());
	sql.append("SELECT i_month, i_year FROM lan:serv_infrate WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND d_start = '"+startDate+"' AND d_end = '"+endDate+"'");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	if (rs != null) {
		if (rs.next() == true) {
			month = doString.checkString(rs.getString("I_MONTH"));
			year = doString.checkString(rs.getString("I_YEAR"));
		}
		rs.close();
		rs=null;
	}	
%>
<HTML>
<HEAD>
<TITLE>บันทึกค่าบริการสาธารณะ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<base target="_self">
<SCRIPT LANGUAGE="JavaScript">
<!-- Begin
var ggWinCal ;
function cust_window() {
	var type = "07";
		search = "";
		frmEdtInfra.custType[1].checked = true;
		var vWinCal = window.open('SERV_CustInfra.jsp?comId=<%=comId%>&projId=<%=projId%>&type='+type,'blank','width=680,height=300,left=200,top=100');
		vWinCal.opener = self;
		ggWinCal = vWinCal;
}

function SaveAndClose(frm) {
	frm.action = "/LHServ/UpdPayerServlet";
	frm.submit();
}
function Cancel(frm) {
	frm.action = "/LHServ/CancelInfraServlet";
	frm.submit();
}

function printPayIn(frm) {
	frm.target = "_blank";
	frm.action = "/LHServ/SERV_PrintInfPayInCBServlet";	
	frm.submit();
}
// End -->
</script>

</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM name="frmEdtInfra" method="post" action="SERV_Edt_Infra.jsp">
<INPUT type="hidden" name="docNo" value="<%=docNo%>">
<INPUT type="hidden" name="empId" value="<%=empId%>">
<INPUT type="hidden" name="userId" value="<%=userId%>">
<INPUT type="hidden" name="sortId" value="<%=sortId%>">
<INPUT type="hidden" name="Month" value="<%=month%>">
<INPUT type="hidden" name="Year" value="<%=year%>">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
            <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;รายละเอียดค่าบริการสาธารณะ</td>
          <td width="30%" align="right">&nbsp;</td>
        </tr>
      </table>


<br style="font-size:10pt">
                
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
	<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
	<td class="item_tab2" width="250">รายละเอียดค่าบริการสาธารณะ</td>
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
<%
	sql.delete(0, sql.length());
	sql.append("SELECT c.i_sort, c.i_lor, NVL(c.i_cus_intent1,0) AS CUS_INTENT1, NVL(c.i_exp_intent1,0) EXP_INTENT1, NVL(c.i_cus_intent2,0) AS CUS_INTENT2, NVL(c.i_exp_intent2,0) EXP_INTENT2 FROM lan:acscontr c WHERE c.i_company = '")
		.append(comId)
		.append("' AND c.i_project = '")
		.append(projId)
		.append("' AND c.i_sort = '")
		.append(sortId)
		.append("' AND c.d_close_law IS NOT NULL AND c.f_contr IS NULL");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	if (rs != null) {
		if (rs.next() == true) {
			custNo1 = rs.getInt("CUS_INTENT1");
			if (custNo1 == 0) {
				custNo1 = rs.getInt("EXP_INTENT1");
			}
			custNo2 = rs.getInt("CUS_INTENT2");
			if (custNo2 == 0) {
				custNo2 = rs.getInt("EXP_INTENT2");
			}
			intentNo = custNo1;
			if (intentNo == 0) {
				intentNo = custNo2;
			}
		}
		rs.close();
		rs=null;
	}
	sql.delete(0, sql.length());
	sql.append("SELECT i_lor, NVL(q_area,0) AS AREA, n_customer, f_separate FROM lan:serv_inflck WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_sort = '"+sortId+"'");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	if (rs != null) {
		if (rs.next() == true) {
			if (doString.checkString(rs.getString("F_SEPARATE")).equals("Y")) {
				custNo1 = 0;
				custNo2 = 0;
				intentNo = 0;
			}
		}
		rs.close();
		rs=null;
	}
%>
<INPUT type="hidden" name="Project" value="<%=comId+projId%>">
<INPUT type="hidden" name="comId" value="<%=comId%>">
<INPUT type="hidden" name="projId" value="<%=projId%>">
<INPUT type="hidden" name="beg_lock" value="<%=sortId%>">
<INPUT type="hidden" name="end_lock" value="<%=sortId%>">
<INPUT type="hidden" name="between" value="<%=startDate+"/"+endDate%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR" align="center">
              <table border="0" width="100%" cellspacing="0" cellpadding="0">
                <tr> 
                  <td height="22" class="item ; dotline01" width="12%">โครงการ 
                    : </td>
                  <td height="22" width="28%" class="dotline01"><%=comId%><%=projId%> 
                    <%=site%> </td>
                  <td height="22" width="12%" class="item ; dotline01">แปลง :</td>
                  <td height="22" width="48%" class="dotline01"><%=sortId%></td>
                </tr>
                <tr> 
                  <td height="22" class="item ; dotline01" width="12%">ช่วงเดือน :</td>
                  <td height="22" width="28%" class="dotline01"><%=betweenDate%></td>
                  <td height="22" width="12%" class="item ; dotline01">&nbsp;</td>
                  <td height="22" width="48%" class="dotline01">&nbsp;</td>
                </tr>
                <tr> 
                  <td height="22" class="item ; dotline01" width="12%">ชื่อลูกค้า 
                    :</td>
                  <td height="22" width="28%" class="dotline01"><%=custName%></td>
                  <td height="22" width="12%" class="item ; dotline01">ผู้จ่ายค่าสาธารณะ 
                    : </td>
                  <td height="22" width="48%" class="item ; dotline01"> 
                    <input type="radio" value="1" name="custType" <%if (custType.equals("1")) { out.print("checked"); }%>>
                    ลูกค้า&nbsp;&nbsp; 
                    <select size="1" name="Customer" class="box" style="width:290px">
                      <option value="">----- เลือกลูกค้า -----</option>
                      <%
	sql.delete(0, sql.length());
	sql.append("SELECT * FROM lan:acxcusto WHERE i_customer = "+Integer.toString(custNo1));
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	if (rs != null) {
		if (rs.next() == true) {
			custName = doString.checkString(doString.DisplayThai(rs.getString("N_PRENAME")))+" "+doString.checkString(doString.DisplayThai(rs.getString("N_NCUSTOMER")))+ " "+doString.checkString(doString.DisplayThai(rs.getString("N_SCUSTOMER")));;
%> 
                      <OPTION value="<%=custNo1%>" <%if (intentNo == custNo1) { out.print("selected"); }%>><%=custNo1%> 
                      | <%=custName%></OPTION>
                      <%
		}
		rs.close();
		rs=null;
	}

	sql.delete(0, sql.length());
	sql.append("SELECT n_prename, n_ncustomer, n_scustomer FROM lan:acxcusto WHERE i_customer = "+Integer.toString(custNo2));
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	if (rs != null) {
		if (rs.next() == true) {
			custName = doString.checkString(doString.DisplayThai(rs.getString("N_PRENAME")))+" "+doString.checkString(doString.DisplayThai(rs.getString("N_NCUSTOMER")))+ " "+doString.checkString(doString.DisplayThai(rs.getString("N_SCUSTOMER")));;
%> 
                      <OPTION value="<%=custNo2%>" <%if (intentNo == custNo2) { out.print("selected");}%>><%=custNo2%> 
                      | <%=custName%></OPTION>
                      <%
		}
		rs.close();
		rs=null;
	}
%> 
                    </select>
                  </td>
                </tr>
                <tr> 
                  <td height="22" class="item ; dotline01" width="12%">&nbsp;</td>
                  <td height="22" width="28%" class="dotline01">&nbsp;</td>
                  <td height="22" width="12%" class="item ; dotline01">&nbsp;</td>
                  <td height="22" width="48%" class="item ; dotline01"> 
                    <input type="radio" value="3" name="custType" <%if (custType.equals("3")) { out.print("checked"); }%>>
                    อื่นๆ &nbsp;&nbsp;<A href="javascript:cust_window()"><img border="0" src="images/bu_add.gif" align="absmiddle" onMouseOut="nereidFade(this,70,50,5)" onMouseOver="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70) ; cursor:hand" width="30" height="12"></a>&nbsp; 
                    &nbsp;
                    <input type="text" name="payer" class="box" style="width:170px" value="<%=doString.DisplayThai(payer)%>" onFocus="this.blur()">
                  </td>
                </tr>
				</table>
              <table border="0" width="100%" cellspacing="0" cellpadding="0">
                <tr> 
                  <td height="22" class="item ; dotline01" width="15%">จำนวนเงินค่าสาธารณะ 
                    : </td>
                  <td height="22" width="15%" align="right" class="dotline01"><%=doString.displayNumber("###,###,###.00", amount)%></td>
                  <td height="22" width="22%" class="item ; dotline01">บาท</td>
                  <td height="22" width="48%" class="item ; dotline01">&nbsp;</td>
                </tr>
                <tr> 
                  <td height="22" class="item ; dotline01" width="15%">รับชำระแล้ว 
                    : </td>
                  <td height="22" width="15%" align="right" class="dotline01"><%=doString.displayNumber("###,###,###.00", recvAmnt)%></td>
                  <td height="22" width="22%" class="item ; dotline01">บาท</td>
                  <td height="22" width="48%" class="item ; dotline01">&nbsp;</td>
                </tr>
                <tr> 
                  <td height="22" class="item ; dotline01" width="15%">โดย คงค้าง 
                    : </td>
                  <td height="22" width="15%" align="right" class="dotline01"><%=doString.displayNumber("###,###,###.00", accrueAmnt)%></td>
                  <td height="22" width="22%" class="item ; dotline01">บาท</td>
                  <td height="22" width="48%" class="item ; dotline01">&nbsp;</td>
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
<table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
  <tr>
    <td class="act_tab1"></td>
            <td width="250" class="act_tab2"> <a href="javascript:SaveAndClose(frmEdtInfra)"><IMG border="0" src="images/act_saveandclose.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp; 
            <%if (accrueAmnt > 0) {%>
              <a href="javascript:printPayIn(frmEdtInfra)"><IMG border="0" src="images/act_printpayin1.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27">&nbsp;</a> 
              <%}%>
				<%if (cancel) {%>
			<A href="javascript:Cancel(frmEdtInfra)"><IMG border="0" src="images/act_delete.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27"></A>&nbsp;
				<%}%>              
            </td>
    <td class="act_tab3"></td>
            <td class="act_tab4"><a href="javascript:history.back()"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp; 
              <a href="SERV_InfHome.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
  </tr>
</table>
<%
	stmt.close();
	conn.close();
	stmt=null;
	conn=null;
} catch (Exception e) {
	System.out.println("ERROR SERV_Edt_Infra.jsp : " + e.getMessage());
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
</table>

<br style="font-size:30pt">
<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
  <tr><td width="100%" class="copyright" align="center">
  Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer
  version 5 และ 5.5
  <br>ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;
  หรือ โทร. 0-2230-8279 (คุณประพัฒน์
  ฝ่ายบริการ)&nbsp; 0-2230-8491-5 (ฝ่าย IT)
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE>
</FORM>
</BODY>
</HTML>