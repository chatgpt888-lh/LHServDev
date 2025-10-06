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
String jName = "SERV_LockDet.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

String project = doString.checkString(request.getParameter("Project"),"LH000");
String comId = project.substring(0,2);
String projId = project.substring(2);
String Lock = doString.checkString(request.getParameter("Lock"));
Lock = Lock.toUpperCase();
String i_sort = "", d_end = "", i_house = "", n_customer = "";
int i_lor = 0; 
double q_area = 0;

%>

<HTML>
<HEAD>
<TITLE>ค่าบริการสาธารณะ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<base target="_self">
<script language="JavaScript">
<!--
/*function chckAll(frm){
	var i = 0;
	var numTime = eval(frm.NumTime.value);
	if ( numTime == 1)
	{
		frm.chkTime.checked = frm.selAll.checked;
	} else {
		while( i < numTime)
		{
			frm.chkTime[i].checked = frm.selAll.checked;
			i++;
		}
	}
}*/

function saveTime(a) {
	frmTime.action = "/LHServ/AddTimeServlet?Act="+a;
	frmTime.submit();
}

//-->
</script>
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM name="frmTime" method="post" action="SERV_LockDet.jsp">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
            <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp; 
              ข้อมูลพื้นฐาน</td>
          <td width="30%" align="right">&nbsp;</td>
        </tr>
      </table>


<br style="font-size:10pt">
<%
//double amount = 0;
String optionSelected = "";
String code = "";
int numTime = 0;
Calendar rightNow = Calendar.getInstance();
String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);  
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
                  <td height="22" class="item ; dotline01" width="9%">เลือกโครงการ 
                    : </td>
                  <td height="22" width="31%" class="dotline01"> 
                    <select size="1" name="Project" class="box" style="width:250px">
                      <option value="LH000">----- เลือกโครงการ -----</option>
                      <%
	sql.delete(0, sql.length());
	sql.append("SELECT * FROM lan:serv_pstaff WHERE user_id = '"+userId+"' AND com_id = 'LH' AND proj_id = 'ALL'");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
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
			optionSelected = "";
			code = doString.checkString(rs.getString("I_COMPANY"))+doString.checkString(rs.getString("I_PROJECT"));
			if (project.equals(code)) {
				optionSelected = "selected";
			}
%> 
                      <OPTION value="<%=code%>" <%=optionSelected%>><%=code%> 
                      | <%=doString.checkString(doString.DisplayThai(rs.getString("N_PROJECT")))%></OPTION>
                      <%
		}// end while
		rs.close();
		rs=null;
	}
%> 
                    </select>
                  </td>
                  <td height="22" width="7%" class="item ; dotline01">ค้นหาแปลง : </td>
                  <td height="22" width="53%" class="dotline01"><INPUT type="text" name="Lock" class="box" value="<%=Lock%>" style="width:60px" maxlength="5">&nbsp; &nbsp; 
                    <A HREF="javascript:frmTime.submit()"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a></td>
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
	<td class="item_tab2" width="250">แก้ไขข้อมูลค่าบริการสาธารณะรายแปลง</td>
	<td class="item_tab3"></td>
                <td class="item_tab4">&nbsp;</td>
                
            <td class="item_tab5i" style="width:180px" >&nbsp;</td>
	</tr>
</table>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
    <td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL">
              <table border="0" width="100%" cellspacing="0" cellpadding="0">
                <tr> 
                  <td class="col_name" width="3%">No.</td>
                  <td class="col_name" width="7%">แปลง</td>
                  <td class="col_name" width="15%">เลขที่ใบจอง</td>
                  <td class="col_name" width="10%">วันที่จ่าย</td>
                  <td class="col_name" width="10%">บ้านเลขที่</td>
				  <td class="col_name" width="10%">เนื้อที่</td>
                  <td class="col_name" width="35%">ชื่อลูกค้า</td>
                  <td class="col_name" width="10%">บัตรประชาชน</td>
                </tr>
<%
String whr = "";
if (Lock.equals("") || Lock == null) {
	whr = "WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'";
} else {
	whr = "WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_sort = '"+Lock+"'";
}
	
	sql.delete(0, sql.length());
	sql.append("SELECT i_sort, i_lor, d_end, i_house, q_area, n_customer, id_no FROM lan:serv_inflck "+whr+" ORDER BY i_sort, d_end");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	if (rs != null) {
		while (rs.next() == true) {
			numTime++;
			i_sort = doString.checkString(rs.getString("i_sort"));			
			d_end = doString.checkString(doString.DisplayThai(rs.getString("d_end")));
			i_house = doString.checkString(rs.getString("i_house"),"-");
			n_customer = doString.checkString(doString.DisplayThai(rs.getString("n_customer")));
			i_lor = rs.getInt("i_lor");
			q_area = rs.getDouble("q_area");
%>
                <tr> 
                  <td class="dotline" align="center" width="3%"><%=numTime%></td>
                  <td class="dotline" align="center" width="7%"><a href="SERV_AddLockDet.jsp?Project=<%=project%>&Lock=<%=i_sort%>&i_lor=<%=i_lor%>&flag=edit"><%=i_sort%></a></td>
                  <td class="dotline" align="center" width="15%"><%=i_lor%></td>
                  <td class="dotline" align="center" width="10%"><%=DateUtil.ifxToThaiDate(d_end)%></td>
                  <td class="dotline" align="center" width="10%"><%=i_house%></td>
				  <td class="dotline" align="center" width="10%"><%=doString.displayNumber("###,###,###.00", q_area)%></td>
				  <td class="dotline" align="left" width="35%"><%=n_customer%></td>
				  <td class="dotline" align="center" width="10%"><%=doString.checkString(rs.getString("id_no"))%></td>
				  </tr>

<%			
		}// end while
		rs.close();
		rs=null;
	}
%>                
              </table>
              <INPUT type="hidden" name="NumTime" value="<%=numTime%>">
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
	conn.close();
	stmt=null;
	conn=null;
} catch (Exception e) {
	System.out.println("ERROR SERV_LockDet.jsp : " + e.getMessage());
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
<table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
  <tr>
    <td class="act_tab1"></td>
    <td width="160" class="act_tab2">
    <a href="SERV_AddLockDet.jsp?Project=<%=project%>&flag=add"><IMG border="0" src="images/act_add.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp;
    <a href="javascript:saveTime('Del');"></a>&nbsp;
    </td>
    <td class="act_tab3"></td>
            <td class="act_tab4"><a href="javascript:history.back()"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp; 
              <a href="SERV_InfHome.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>

  </tr>
</table>
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