<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
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
String jName = "SERV_CustInfra.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

Vendor vendor = (Vendor) session.getAttribute("Vendor");
String venId = "";
String pname = "";
String name = "";
String sname = "";
String telephone = "";
String address1 = "";
String address2 = "";
if (vendor != null) {
	venId = vendor.getId();
	pname = vendor.getPreName();
	name = vendor.getName();
	sname = vendor.getSurName();
	telephone = vendor.getTelephone();
	address1 = vendor.getAddress1();
	address2 = vendor.getAddress2();
}
String search = doString.checkString(request.getParameter("search"));
String comId = doString.checkString(request.getParameter("comId"));
String projId = doString.checkString(request.getParameter("projId"));
String sortId = doString.checkString(request.getParameter("sortId"));
String type = doString.checkString(request.getParameter("type"));
if (request.getParameter("Vendor") != null) {
	venId = doString.checkString(request.getParameter("Vendor"));
}
if (venId.equals("")) {
	venId = "Auto Generate";
}
%>
<HTML>
<HEAD>
<TITLE>Add - ค่าบริการสาธารณะ</TITLE>
<META http-equiv="Content-Type" content="text/html; charset=TIS-620">
<META http-equiv="Content-Style-Type" content="text/css">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<SCRIPT language="javascript" src="script_fx.js"></SCRIPT>
<BASE target="_self">
<SCRIPT LANGUAGE="JavaScript">
<!-- Begin
function Search(frm) {
	frm.search.value = "true";
	frm.submit();
}

function addVendor(frm)
{
	frm.action="/LHServ/AddInfVendorServlet";
	frm.submit();
}
// End -->
</script>
</HEAD>
<BODY leftMargin="0" topMargin="0" marginheight="0" marginwidth="0">
<FORM name="frmCustInfra" method="post" action="SERV_CustInfra.jsp">
<INPUT type="hidden" name="comId" value="<%=comId%>">
<INPUT type="hidden" name="projId" value="<%=projId%>">
<INPUT type="hidden" name="sortId" value="<%=sortId%>">
<INPUT type="hidden" name="type" value="<%=type%>">
<INPUT type="hidden" name="search" value="">
<TABLE border="0" width="650" cellspacing="0" cellpadding="0">
  <TBODY>
    <TR>
      <TD width="100%" class="BD">
      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
        <TBODY>
          <TR>
            <TD width="80%" class="bigh"><IMG border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp; ใบวางเงินค่าบริการสาธารณะ</TD>
            <TD width="20%" class="bigh" align="right"></TD>
          </TR>
        </TBODY>
      </TABLE>
      <BR style="font-size:10pt">
<%
String code = "";
String desc = "";
String optionSelected = "";
desc = "อื่นๆ";
//desc = doString.UnicodeToMS874(desc);
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;
String sql = "";
try {
	if (ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	if (search.equals("true")) {
		sql = "SELECT n_pname, n_name, n_sname, i_tel, a_addr1, a_addr2 FROM lan:serv_venprj WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_type = '"+type+"' AND i_vendor = '"+venId+"'";
		servlog.startLog(sql);
		rs = stmt.executeQuery(sql);
		servlog.endLog();
		if (rs != null) {
			if (rs.next() == true) {
				pname = doString.checkString(doString.DisplayThai(rs.getString("N_PNAME")));
				name = doString.checkString(doString.DisplayThai(rs.getString("N_NAME")));
				sname = doString.checkString(doString.DisplayThai(rs.getString("N_SNAME")));
				telephone = doString.checkString(rs.getString("I_TEL"));
				address1 = doString.checkString(doString.DisplayThai(rs.getString("A_ADDR1")));
				address2 = doString.checkString(doString.DisplayThai(rs.getString("A_ADDR2")));
			}
			rs.close();
			rs=null;
		}
	}
%>
      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
        <TBODY>
          <TR>
            <TD class="item_tab1"><IMG border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></TD>
            <TD class="item_tab2" width="200">รายละเอียดผู้จ่ายค่าบริการสาธารณะ</TD>
            <TD class="item_tab3"></TD>
            <TD>&nbsp;</TD>
          </TR>
        </TBODY>
      </TABLE>
      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
        <TBODY>
          <TR>
            <TD width="5" valign="top"><IMG border="0" src="images/Corn01.gif" width="5" height="5"></TD>
            <TD class="frmTop">&nbsp;</TD>
            <TD width="5" valign="top" align="right"><IMG border="0" src="images/Corn02.gif" width="5" height="5"></TD>
          </TR>
        </TBODY>
      </TABLE>
      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
        <TBODY>
          <TR>
            <TD width="100%" class="frmLR" align="center">
            <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
              <TBODY> 
              <TR> 
                <TD class="item ; dotline01" height="22" width="17%">ผู้จ่ายค่าบริการสาธารณะ
                  :</TD>
                <TD height="22" width="35%" class="dotline01"><%=desc%></TD>
                <TD height="22" width="13%" class="item ; dotline01">Search ชื่อ 
                  :</TD>
                <TD height="22" width="35%" class="dotline01"> 
                  <SELECT class="box" style="width:200px" name="Vendor" onChange="Search(frmCustInfra)">
              <OPTION value="">. . .</OPTION>

<%
	//System.out.println("SELECT i_vendor, n_pname, n_name, n_sname FROM lan:serv_venprj WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_type = '"+type+"' ORDER BY i_vendor");
	sql = "SELECT i_vendor, n_pname, n_name, n_sname FROM lan:serv_venprj WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_type = '"+type+"' ORDER BY i_vendor";
	servlog.startLog(sql);
	rs = stmt.executeQuery(sql);
	servlog.endLog();

	if (rs != null) {
		while (rs.next() == true) {
			optionSelected = "";
			code = doString.checkString(rs.getString("I_VENDOR"));
			desc = doString.checkString(doString.DisplayThai(rs.getString("N_PNAME"))) + " " + doString.checkString(doString.DisplayThai(rs.getString("N_NAME"))) + " " +doString.checkString(doString.DisplayThai(rs.getString("N_SNAME")));
			if (venId.equals(code)) {
				optionSelected = "selected";
			}
%>
              <OPTION value="<%=code%>" <%=optionSelected%>><%=code%> | <%=desc%></OPTION>
<%
		}// end while
		rs.close();
		rs=null;
	}
%>
                  </SELECT>
                </TD>
              </TR>
              <TR> 
                <TD class="item ; dotline01" height="22" width="17%">รหัสผู้จ่ายเงิน
                  :</TD>
                <TD height="22" width="35%" class="dotline01"> 
                  <INPUT type="text" name="code" class="boxD" style="width:200px" value="<%=venId%>" onFocus="this.blur()">
                </TD>
                <TD height="22" width="13%" class="item ; dotline01">คำนำหน้าชื่อ 
                  :</TD>
                <TD height="22" width="35%" class="dotline01"> 
                  <INPUT type="text" name="prename" class="box" style="width:200px" value="<%=pname%>">
                </TD>
              </TR>
              <TR> 
                <TD class="item ; dotline01" height="22" width="17%">ชื่อ :</TD>
                <TD height="22" width="35%" class="dotline01"> 
                  <INPUT type="text" name="name" class="box" style="width:200px" value="<%=name%>">
                </TD>
                <TD height="22" width="13%" class="item ; dotline01">นามสกุล :</TD>
                <TD height="22" width="35%" class="dotline01"> 
                  <INPUT type="text" name="surname" class="box" style="width:200px" value="<%=sname%>">
                </TD>
              </TR>
              <TR> 
                <TD class="item ; dotline01" height="22" width="17%">เบอร์โทรติดต่อ 
                  :</TD>
                <TD height="22" width="35%" class="dotline01"> 
                  <INPUT type="text" name="telephone" class="box" style="width:200px" value="<%=telephone%>">
                </TD>
                <TD height="22" width="13%" class="item ; dotline01">&nbsp;</TD>
                <TD height="22" width="35%" class="dotline01">&nbsp;</TD>
              </TR>

              <TR> 
                <TD class="item ; dotline01" height="22" width="17%">ที่อยู่1  
                  :</TD>
                <TD height="22" width="35%" class="dotline01"> 
                  <INPUT type="text" name="adderss1" class="box" style="width:200px" value="<%=address1%>">
                </TD>
                <TD height="22" width="13%" class="item ; dotline01">ที่อยู่2 :</TD>
                <TD height="22" width="35%" class="dotline01">
				<INPUT type="text" name="adderss2" class="box" style="width:200px" value="<%=address2%>">
				</TD>
              </TR>
              </TBODY> 
            </TABLE>
            </TD>
          </TR>
        </TBODY>
      </TABLE>
      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
        <TBODY>
          <TR>
            <TD width="5" valign="bottom"><IMG border="0" src="images/Corn03.gif" width="5" height="5"></TD>
            <TD class="frmBottom">&nbsp;</TD>
            <TD width="5" valign="bottom" align="right"><IMG border="0" src="images/Corn04.gif" width="5" height="5"></TD>
          </TR>
        </TBODY>
      </TABLE>
<%
	stmt.close();
	conn.close();
	stmt=null;
	conn=null;
} catch (Exception e) {
	System.out.println("ERROR SERV_CustInfra.jsp : " + e.getMessage());
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
      <BR style="font-size:10pt">
      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
        <TBODY>
          <TR>
            <TD class="act_tab1"></TD>
            <TD width="75" class="act_tab2"><A href="javascript:addVendor(frmCustInfra)"><IMG border="0" src="images/act_saveandclose.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27"></A></TD>
            <TD class="act_tab3">&nbsp;</TD>
            <TD class="act_tab4"><A href="javascript:top.window.close()"><IMG border="0" src="images/bu_close.gif" width="50" height="15"></A></TD>
          </TR>
        </TBODY>
      </TABLE>
      </TD>
    </TR>
  </TBODY>
</TABLE>
</FORM>
</BODY>
</HTML>