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
String jName = "SERV_Add_Reten.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

String project = doString.checkString(request.getParameter("Project"),"LH000");
String comId = project.substring(0,2);
String projId = project.substring(2);
String docNo = doString.checkString(request.getParameter("docNo"));
String lockId = doString.checkString(request.getParameter("lockId"));
lockId = lockId.toUpperCase();
String houseNo = doString.checkString(request.getParameter("houseNo"));
String retenType = doString.checkString(request.getParameter("retenType"),"1");

//---- 2022-06-30 , for payin input ----//
String iPayType = doString.checkString(request.getParameter("iPayType"),"PAYIN");
String iPayBnk = doString.checkString(request.getParameter("iPayBnk"),"");
String iPayAcc = doString.checkString(request.getParameter("iPayAcc"),"");
String iEmail = doString.checkString(request.getParameter("iEmail"),"");
//--------------------------------------//

String docType = "";
String conDate = "";
String comment = "";
double amount = 0;
int conMnth = 0;
%>
<HTML>
<HEAD>
<TITLE>รายละเอียด - ใบวางเงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<META http-equiv="Content-Style-Type" content="text/css">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<SCRIPT language="javascript" src="script_fx.js"></SCRIPT>
<SCRIPT language="javascript" type="text/javascript" src="chromeless_35.js"></SCRIPT>
<SCRIPT language="javascript" type="text/javascript" src="window_style.js"></SCRIPT>
<BASE target="_self">
<SCRIPT LANGUAGE="JavaScript">
<!-- Begin
var ggWinCal ;

function searchData() {
	if (frmAddReten.Project.value == "LH000") {
		alert("โปรดเลือกโครงการ");
		frmAddReten.Project.focus();
		return;
	}
	if (frmAddReten.lockId.value == "") {
		alert("โปรดระบุแปลงขาย");
		frmAddReten.lockId.focus();
		return;
	}	
	
	frmAddReten.action = "SERV_Add_Reten.jsp";
	frmAddReten.submit();
}

function cust_window() {
	var type = "";
	if (frmAddReten.retenType[0].checked) {
		type = "04";
	} else if (frmAddReten.retenType[1].checked) {
		type = "05";
	} else {
		type = "06";
	}
	if (type == "04") {
		frmAddReten.Customer.focus();
	} else {
		search = "";
		venId = frmAddReten.venId.value;
		if (venId != "") {
			search = "true";
		}
		var vWinCal = window.open('SERV_CustReten.jsp?comId=<%=comId%>&projId=<%=projId%>&type='+type,'blank','width=680,height=250,left=200,top=100');
		vWinCal.opener = self;
		ggWinCal = vWinCal;
	}
}
function ChngeTelNo(frm) {
	var custId = frm.Customer.value;
	if (custId == "") {
		telephone = "";
	} else {
		telephone = eval("frm.T"+custId+".value");
	}
	frm.telephone.value = telephone;
}
function chkGuarantor(frm) {
	if (frmAddReten.retenType[0].checked) {
		frm.guarantor.value = "";
	} else {
		frm.guarantor.value = "";
		frm.Customer.value = "";
		frm.telephone.value = "";
	}
}

function SaveAndClose(frm) {
	if (frm.Project.value == "LH000") {
		alert("โปรดเลือกโครงการ");
		frm.Project.focus();
		return;
	}
/*
	if (frm.houseNo.value == "") {
		alert("โปรดระบุเลขที่บ้าน");
		frm.houseNo.focus();
		return;
	}
*/
	if (frm.lockId.value == "") {
		alert("โปรดระบุแปลงขาย");
		frm.lockId.focus();
		return;
	}
	if (frm.lorNo.value == "0") {
		alert("ไม่พบข้อมูลแปลงขาย");
		return;
	}
	if (frm.retenType[0].checked) {
		if (frm.Customer.value == "") {
			alert("โปรดเลือกลูกค้า");
			frm.Customer.focus();
			return;
		}
	} else {
		if (frm.guarantor.value == "") {
			alert("โปรดระบุผู้รับเหมา");
			return;
		}
	}
	if (frm.guarantee.value == "000") {
		alert("เพื่อค้ำประกัน");
		frm.guarantee.focus();
		return;
	}
	var mnth = parseFloat(frm.conMnth.value);
	if (mnth == 0) {
		alert("โปรดระบุเดือน");
		frm.conMnth.focus();
		return;
	}
	
	//----- 2022-06-30 , validate payin input -----//
	if (!validatePayInData()) {
		return;
	}
	
	frm.action = "/LHServ/LayRetentServlet";
	frm.submit();
}

// End -->
</script>
</HEAD>
<BODY leftMargin="0" topMargin="0" marginheight="0" marginwidth="0">
<FORM name="frmAddReten" method="post" action="SERV_Add_Reten.jsp">
<INPUT type="hidden" name="docNo" value="<%=docNo%>">
<TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
  <TBODY>
    <TR>
      <TD width="100%" class="BD">
      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
        <TBODY>
          <TR>
            <TD width="80%" class="bigh"><IMG border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp; ใบวางเงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม</TD>
            <TD width="20%" class="bigh" align="right"></TD>
          </TR>
        </TBODY>
      </TABLE>
      <BR style="font-size:10pt">
<%
String model = "";
String retentId = "";
String custName = "";
String venName = "";
String telephone1 = "";
String telephone2 = "";
String telephone = "";
int lorNo = 0;
int intentNo = 0;
int custNo1 = 0;
int custNo2 = 0;
Calendar rightNow = Calendar.getInstance();
int curYear = rightNow.get(Calendar.YEAR);
if (curYear<2400) curYear += 543;
String cur_year = Integer.toString(curYear);
//String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
SimpleDateFormat formatter = new SimpleDateFormat("dd/MM/yyyy HH:mm", Locale.US);
java.util.Date today = new java.util.Date();
DateUtil date_util = new DateUtil();
String optionSelected = "";
String bgcolor = "";
String code = "";
String type = "";
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
	sql.append("SELECT h.i_sort, h.d_keyin, h.i_doc_type, h.i_lor, h.n_custo, h.i_model, h.i_house, h.i_ret_custo, h.i_reten, h.d_beg_cons, h.i_mon_cons, NVL(h.z_reten,0) AS RETEN_AMT, h.c_advan, h.i_staff, h.i_doc_status FROM lan:serv_rethd h WHERE h.i_company = '"+comId+"' AND h.i_project = '"+projId+"' AND h.i_docno = '"+docNo+"'");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	if (rs != null) {
		if (rs.next() == true) {
			lockId = doString.checkString(rs.getString("I_SORT"));
			docType = doString.checkString(rs.getString("I_DOC_TYPE"));
			retenType = doString.checkString(rs.getString("I_RET_CUSTO"));
			retentId = doString.checkString(rs.getString("I_RETEN"));
			conDate = doString.checkString(doString.DisplayThai(rs.getString("D_BEG_CONS")));
			if (!conDate.equals("")) {
				conDate = conDate.substring(8)+"-"+conDate.substring(5,7)+"-"+conDate.substring(0,4);	
			}
			amount = rs.getDouble("RETEN_AMT");
			conMnth = rs.getInt("I_MON_CONS");
			comment = doString.checkString(doString.DisplayThai(rs.getString("C_ADVAN")));
		}
		rs.close();
		rs=null;
	}



	if (!houseNo.equals("") || !lockId.equals("")) {

		if (!houseNo.equals("")) {
			sql.delete(0, sql.length());
			sql.append("SELECT i_lock, s_lock, i_model, i_house FROM lan:acxlckmd WHERE i_company = '")
				.append(comId)
				.append("' AND i_project = '")
				.append(projId)
				.append("' AND i_house = '")
				.append(houseNo)
				.append("' ORDER BY s_lock");
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			if (rs != null) {
				if (rs.next() == true) {
					model = doString.checkString(rs.getString("I_MODEL"));
					lockId = doString.checkString(rs.getString("I_LOCK"));
				}
				rs.close();
				rs=null;
			}
		}

		if (!lockId.equals("")) {
			sql.delete(0, sql.length());
			sql.append("SELECT i_lock, s_lock, i_model, i_house FROM lan:acxlckmd WHERE i_company = '")
				.append(comId)
				.append("' AND i_project = '")
				.append(projId)
				.append("' AND i_lock = '")
				.append(lockId)
				.append("' ORDER BY s_lock");
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			if (rs != null) {
				if (rs.next() == true) {
					model = doString.checkString(rs.getString("I_MODEL"));
					houseNo = doString.checkString(rs.getString("I_HOUSE"));
				}
				rs.close();
				rs=null;
			}
		}

		sql.delete(0, sql.length());
		sql.append("SELECT c.i_sort, c.i_lor, NVL(c.i_cus_intent1,0) AS CUS_INTENT1, NVL(c.i_exp_intent1,0) EXP_INTENT1, NVL(c.i_cus_intent2,0) AS CUS_INTENT2, NVL(c.i_exp_intent2,0) EXP_INTENT2 FROM lan:acscontr c WHERE c.i_company = '")
			.append(comId)
			.append("' AND c.i_project = '")
			.append(projId)
			.append("' AND c.i_sort = '")
			.append(lockId)
			.append("' AND c.d_close_law IS NOT NULL AND c.f_contr IS NULL");
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		if (rs != null) {
			if (rs.next() == true) {
				lorNo = rs.getInt("I_LOR");
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
		sql.append("SELECT n_prename, n_ncustomer, n_scustomer FROM lan:acxcusto WHERE i_customer = "+Integer.toString(intentNo));
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		if (rs != null) {
			if (rs.next() == true) {
				custName = doString.checkString(doString.DisplayThai(rs.getString("N_PRENAME")))+" "+doString.checkString(doString.DisplayThai(rs.getString("N_NCUSTOMER")))+ " "+doString.checkString(doString.DisplayThai(rs.getString("N_SCUSTOMER")));;
			}
			rs.close();
			rs=null;
		}
		if (!retentId.equals("")) {
			if (retenType.equals("1")) {
				intentNo = Integer.parseInt(retentId);
				retentId = "";
			} else {
				if (retenType.equals("2")) {
					type = "05";
				} else {
					type = "06";
				}
				sql.delete(0, sql.length());
				sql.append("SELECT n_pname, n_name, n_sname, i_tel FROM lan:serv_venprj WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_type = '"+type+"' AND i_vendor = '"+retentId+"'");
				servlog.startLog(sql.toString());
				rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
				if (rs != null) {
					if (rs.next() == true) {
						venName = doString.checkString(doString.DisplayThai(rs.getString("N_PNAME")))+" "+doString.checkString(doString.DisplayThai(rs.getString("N_NAME")))+" "+doString.checkString(doString.DisplayThai(rs.getString("N_SNAME")));
					}
					rs.close();
					rs=null;
				}
			}
		}
	}
%>
		<INPUT type="hidden" name="venId" value="<%=retentId%>">
      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
        <TBODY>
          <TR>
            <TD class="item_tab1"><IMG border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></TD>
            <TD class="item_tab2" width="200">รายละเอียดการวางเงินค้ำประกันฯ</TD>
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
                  <TD class="item ; dotline01" height="22" width="13%">โครงการ :</TD>
                  <TD height="22" width="40%" class="dotline01">
<% if (docNo.equals("")) { %>
                  <SELECT size="1" name="Project" class="box" style="width:250px">
              <OPTION value="LH000">----- เลือกโครงการ -----</OPTION>
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
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	if (rs != null) {
		while (rs.next() == true) {
			optionSelected = "";
			code = doString.checkString(rs.getString("I_COMPANY"))+doString.checkString(rs.getString("I_PROJECT"));
			if (project.equals(code)) {
				optionSelected = "selected";
			}
%>
              <OPTION value="<%=code%>" <%=optionSelected%>><%=code%> | <%=doString.checkString(doString.DisplayThai(rs.getString("N_PROJECT")))%></OPTION>
<%
		}// end while
		rs.close();
		rs=null;
	}
%>
                  </SELECT>
<%} else { 
	sql.delete(0, sql.length());
	sql.append("SELECT n_project FROM lan:acxprojt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	if (rs != null) {
		if (rs.next() == true) {
			out.print(comId+projId+" "+doString.checkString(doString.DisplayThai(rs.getString("N_PROJECT"))));
		}// end if
		rs.close();
		rs=null;
	}
%>
					<INPUT type="hidden" name="Project" value="<%=comId+projId%>">
<%}%>
				  </TD>
                  <TD height="22" class="item ; dotline01" width="12%">เลขที่ใบวางเงิน :</TD>
                  <TD height="22" width="35%" class="dotline01">
<%
	if (docNo.equals("")) {
		out.print("[Auto Generate]");
	} else {
		out.print(docNo);
	}
%>				  
				  </TD>
                </TR>
                <TR>
                  <TD class="item ; dotline01" height="22" width="13%">บ้านเลขที่ :</TD>
                  <TD height="22" width="40%" class="dotline01">
<% if (docNo.equals("")) { %>
                  <INPUT type="text" name="houseNo" class="box" value="<%=houseNo%>" style="width:100px">
<%} else { out.print(houseNo);%>
					<INPUT type="hidden" name="houseNo" value="<%=houseNo%>">
<%}%>
                </TD>
                  <TD height="22" class="item ; dotline01" width="12%">แปลง :</TD>
                  <TD height="22" width="35%" class="dotline01">
<% if (docNo.equals("")) { %>
                  <INPUT type="text" name="lockId" class="box" value="<%=lockId%>" style="width:60px">
					<A HREF="javascript:searchData()"><IMG border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a>
<%} else { out.print(lockId);%>
					<INPUT type="hidden" name="lockId" value="<%=lockId%>">
<%}%>
			<INPUT type="hidden" name="lorNo" value="<%=lorNo%>">
                  &nbsp;&nbsp;
				</TD>
                </TR>
                <TR>
                  <TD class="item ; dotline01" height="22" width="13%">แบบบ้าน</TD>
                  <TD height="22" width="40%" class="dotline01"><INPUT type="text" name="model" class="boxD" value="<%=model%>" style="width:60px"></TD>
                  <TD height="22" class="item ; dotline01" width="12%">ชื่อลูกค้า :</TD>
                  <TD height="22" width="35%" class="dotline01"><INPUT type="text" name="custName" class="boxD" value="<%=custName%>" style="width:200px"></TD>
                </TR>
                <TR>
                  <TD class="item ; dotline01" height="22" width="13%">ผู้รับเรื่อง :</TD>                  
                <TD height="22" width="40%" class="dotline01"><%=doString.DisplayThai(user.getEmpName())%></TD>
                  <TD height="22" class="item ; dotline01" width="12%">วันเวลาที่แจ้ง :</TD>
                  <TD height="22" width="35%" class="dotline01"><%=formatter.format(today)%></TD>
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
      <BR style="font-size:10pt">
      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
        <TBODY>
          <TR>
            <TD class="item_tab1"><IMG border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></TD>
            <TD class="item_tab2" width="200">รายละเอียดผู้ขอวางเงินฯ</TD>
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
                  <TD class="item ; dotline01" height="22" width="13%">ผู้วางเงินค้ำประกันฯ :</TD>
                  <TD height="22" width="15%" class="dotline01">
                  <INPUT type="radio" value="1" name="retenType" onClick="chkGuarantor(frmAddReten); setPayInName();" <%if (retenType.equals("1")) { out.print("checked"); }%>>
                   ลูกค้า</TD>
                  <TD height="22" width="38%" class="dotline01">
<%
	telephone1 = "";
	sql.delete(0, sql.length());
	sql.append("SELECT * FROM lan:acxcusto WHERE i_customer = "+Integer.toString(custNo1));
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	if (rs != null) {
		if (rs.next() == true) {
			type = doString.checkString(rs.getString("I_ADDRESS_TYPE"));
			code = "";
			if (type.equals("1")) {
				code = "ID";
			} else if (type.equals("2")) {
				code = "WK";
			} else {
				code = "ETC";
			}
			code = "A_"+code+"_TEL";
			telephone1 = doString.checkString(doString.DisplayThai(rs.getString(code)));
		}
		rs.close();
		rs=null;
	}
%>
			<INPUT type="hidden" name="T<%=custNo1%>" value="<%=telephone1%>">			
<%
	telephone2 = "";
	sql.delete(0, sql.length());
	sql.append("SELECT * FROM lan:acxcusto WHERE i_customer = "+Integer.toString(custNo2));
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	if (rs != null) {
		if (rs.next() == true) {
			type = doString.checkString(rs.getString("I_ADDRESS_TYPE"));
			code = "";
			if (type.equals("1")) {
				code = "ID";
			} else if (type.equals("2")) {
				code = "WK";
			} else {
				code = "ETC";
			}
			code = "A_"+code+"_TEL";
			telephone2 = doString.checkString(doString.DisplayThai(rs.getString(code)));
		}
		rs.close();
		rs=null;
	}
%>
			<INPUT type="hidden" name="T<%=custNo2%>" value="<%=telephone2%>">			
                  <SELECT size="1" name="Customer" class="box" style="width:290px" onChange="ChngeTelNo(frmAddReten); setPayInName();">
              <OPTION value="">----- เลือกลูกค้า -----</OPTION>
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
              <OPTION value="<%=custNo1%>" <%if (intentNo == custNo1) { out.print("selected"); telephone = telephone1; }%>><%=custNo1%> | <%=custName%></OPTION>
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
              <OPTION value="<%=custNo2%>" <%if (intentNo == custNo2) { out.print("selected"); telephone = telephone2;}%>><%=custNo2%> | <%=custName%></OPTION>
<%
		}
		rs.close();
		rs=null;
	}
%>
                  </SELECT>&nbsp;&nbsp;&nbsp;</TD>
                  <TD height="22" class="item ; dotline01" width="14%">เบอร์โทรติดต่อ :</TD>
                  <TD height="22" width="20%" class="dotline01">
				  <INPUT type="text" name="telephone" class="box" value="<%=telephone%>" style="width:100px">
				  </TD>
                </TR>
                <TR>
                  <TD class="item ; dotline01" height="22" width="13%">&nbsp;</TD>
                  <TD height="22" width="15%" class="dotline01">
                  <INPUT type="radio" value="2" name="retenType" onClick="chkGuarantor(frmAddReten); setPayInName();" <%if (retenType.equals("2")) { out.print("checked"); }%>>
                   ผู้รับเหมา</TD>
                  <TD height="22" width="38%" class="dotline01">
                  <INPUT type="radio" value="3" name="retenType" onClick="chkGuarantor(frmAddReten); setPayInName();" <%if (retenType.equals("3")) { out.print("checked"); }%>>
                  อื่นๆ&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
                  <A href="javascript:cust_window()"><IMG border="0" src="images/bu_add.gif" align="absmiddle" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70) ; cursor:hand" width="30" height="12"></A>&nbsp;&nbsp;&nbsp;&nbsp; 
                  <INPUT type="text" name="guarantor" class="box" style="width:170px" value="<%=venName%>" onFocus="this.blur()"></TD>
                  <TD height="22" class="item ; dotline01" width="14%">&nbsp;</TD>
                  <TD height="22" width="20%" class="dotline01">&nbsp;</TD>
                </TR>
                <TR>
                  <TD class="item ; dotline01" height="22" width="13%">เพื่อค้ำประกัน :</TD>
                  <TD height="22" width="53%" class="dotline01" colspan="2">
		  <SELECT size="1" name="guarantee" class="box" style="width:250px" onChange="frmAddReten.retenAmount.value=frmAddReten.guarantee.value.substring(2);">
              <OPTION value="000">----- เลือกรายการ -----</OPTION>
<%
	sql.delete(0, sql.length());
	sql.append("SELECT i_code, n_desc, NVL(z_reten,0) AS RETEN_AMT FROM lan:serv_xstd WHERE i_type = '50'  ORDER BY i_code");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	if (rs != null) {
		while (rs.next() == true) {
			code = doString.checkString(rs.getString("I_CODE"));
			optionSelected = "";
			if (docType.equals(code)) {
				optionSelected = "selected";
			}
			code += doString.displayNumber("#########.00", rs.getDouble("RETEN_AMT"));
%>
              <OPTION value="<%=code%>" <%=optionSelected%>><%=doString.checkString(rs.getString("I_CODE"))%>|<%=doString.checkString(doString.DisplayThai(rs.getString("N_DESC")))%>|<%=doString.displayNumber("###,###,###.00", rs.getDouble("RETEN_AMT"))%></OPTION>
<%
		}// end while
		rs.close();
		rs=null;
	}
%>
                  </SELECT>
		  </TD>
                  <TD height="22" class="item ; dotline01" width="14%">เป็นจำนวนเงิน :</TD>
                  <TD height="22" width="20%" class="dotline01">
					<INPUT type="text" name="retenAmount" class="boxD" value="<%=doString.displayNumber("#########.00", amount)%>" style="width:100px" onFocus="this.blur()">
                   บาท</TD>
                </TR>
                <TR>
                  <TD class="item ; dotline01" height="22" width="13%">วันที่เริ่มต้นก่อสร้าง :</TD>                  
                <TD height="22" width="53%" class="dotline01" colspan="2"><%date_util.printHtmlThaiDateNoTime(out, "Con", conDate, 5, 2, "white", "#0078FF");%></TD>
                  <TD height="22" class="item ; dotline01" width="14%">คาดว่าเสร็จประมาณ :</TD>
                  <TD height="22" width="20%" class="dotline01">
                  <INPUT type="text" name="conMnth" class="boxR" style="width:100px" size="20" value="<%=conMnth%>" onKeyPress="if ((event.keyCode < 46 || event.keyCode > 57) || event.keyCode == 47 ) event.returnValue = false;">
                   เดือน</TD>
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
      
	  <!--============================ 2022-06-30 , add refund block ========================================-->		      
      <BR style="font-size:10pt">
      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
        <TBODY>
          <TR>
            <TD class="item_tab1"><IMG border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></TD>
            <TD class="item_tab2" width="200">รายละเอียดการคืนเงิน</TD>
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
                  <TD class="item ; dotline01" height="22" width="66%">
                  	<INPUT type="radio" value="PAYIN" name="iPayType" <%=(iPayType.equals("PAYIN") ? "checked" : "") %>>&nbsp; 
			         Pay-In เข้าบัญชี : &nbsp;
                    <SELECT size="1" name="iPayBnk" class="box" style="width:210px">
		              <OPTION value="">----- เลือกธนาคาร -----</OPTION>
<%
	sql.delete(0, sql.length());
	sql.append(" SELECT i_key1, n_desc FROM lan:lhpay_std WHERE i_type = 'R'  ORDER BY i_key1 ");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	if (rs != null) {
		while (rs.next() == true) {
			code = doString.checkString(rs.getString("i_key1"));
			optionSelected = "";
			if (iPayBnk.equals(code)) {
				optionSelected = "selected";
			}
%>
              <OPTION value="<%=code%>" <%=optionSelected%>><%=code+" | "+doString.checkString(doString.DisplayThai(rs.getString("n_desc"))) %></OPTION>
<%
		}// end while
		rs.close();
		rs=null;
	}
%>		              
					</SELECT> &nbsp; &nbsp; 
			                 ชื่อบัญชี : &nbsp;
                    <INPUT type="text" name="payInName" class="box" readonly value="" style="width:200px ; background-color:#ECECEC">
                  </TD>                  
                  <TD height="22" class="item ; dotline01" width="14%">เลขที่บัญชี 10 หลัก : &nbsp;</TD>
                  <TD height="22" width="20%" class="dotline01">&nbsp;
                  <INPUT type="text" name="iPayAcc" class="box" maxlength="10" value="<%=iPayAcc %>" style="width:100px"> &nbsp; 
                  <span style="color:red">* ไม่ต้องระบุ '-' หรือ ช่องว่าง</span>
                  </TD>
                </TR>                
                <!-- 
                <TR>
                  <TD class="item ; dotline01" height="22" width="66%">
                  	<INPUT type="radio" value="" style="visibility:hidden">&nbsp; 
	                E-Mail แจ้งกลับ กรณี Pay-In เรียบร้อยแล้ว : &nbsp;
                    <INPUT type="text" name="iEmail" class="box" value="<%=iEmail %>" style="width:150px">
                  </TD> 
                  <TD height="22" class="item ; dotline01" width="14%">&nbsp;</TD>
                  <TD height="22" width="20%" class="dotline01">&nbsp;</TD>
                </TR> 
                -->    
                <TR>
                  <TD class="item ; dotline01" height="22" colspan="3">&nbsp;</TD>
                </TR>                             
                <TR>
                  <TD class="item ; dotline01" height="22" width="66%">
                  	<INPUT type="radio" value="PAYTO" name="iPayType" <%=(iPayType.equals("PAYTO") ? "checked" : "") %>>&nbsp; 
			                 เช็คคืนเงิน สั่งจ่ายในนาม : &nbsp;
                    <INPUT type="text" name="payToName" class="box" readonly value="" style="width:200px ; background-color:#ECECEC">
                  </TD> 
                  <TD height="22" class="item ; dotline01" width="14%">&nbsp;</TD>
                  <TD height="22" width="20%" class="dotline01">&nbsp;</TD>
                </TR>  
                <TR>
                  <TD class="item ; dotline01" height="22" colspan="3">
                  <span style="color:red">* การคืนเงินจะทำคืนในชื่อของผู้วางเงินค้ำประกันเท่านั้น ไม่สามารถคืนเงินในชื่อคนอื่นได้</span>
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
	  <!--===================================================================================================-->	      
      
      <BR style="font-size:10pt">
      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
        <TBODY>
          <TR>
            <TD class="item_tab1"><IMG border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></TD>
            <TD class="item_tab2" width="200">Comment</TD>
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
            <TD width="100%" class="frmLRpad01"><TEXTAREA rows="5" name="Comment" class="box" style="width:100%" cols="20"><%=comment%></TEXTAREA></TD>
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
	System.out.println("ERROR SERV_Add_Reten.jsp : " + e.getMessage());
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
            <TD width="150" class="act_tab2"><A href="javascript:SaveAndClose(frmAddReten)"><IMG border="0" src="images/act_saveandclose.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27"></A>&nbsp;</TD>
            <TD class="act_tab3"></TD>
            
          <TD class="act_tab4"><A href="javascript:history.back()" target="_top"><IMG border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></A>&nbsp; 
            <A href="SERV_RetenHome.jsp"><IMG border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></A></TD>
          </TR>
        </TBODY>
      </TABLE>
      </TD>
    </TR>
  </TBODY>
</TABLE>
<BR style="font-size:30pt">
<TABLE border="0" cellspacing="0" cellpadding="0" width="100%">
  <TBODY>
    <TR>
      <TD width="100%" class="copyright" align="center">Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer
      version 5 และ 5.5 <BR>
      ติดต่อสอบถามได้ที่ : <A href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</A>&nbsp; หรือ โทร. 0-2230-8279 (คุณประพัฒน์ ฝ่ายบริการ)&nbsp; 0-2230-8491-5
      (ฝ่าย IT) <BR>
      <IMG src="images/copyright.gif" width="475" height="26"></TD>
    </TR>
  </TBODY>
</TABLE>
</FORM>
</BODY>

<script>

//--- 2022-06-30 , new function for payin details ---//
function setPayInName() {
	frmAddReten.payInName.value = "";
	frmAddReten.payToName.value = "";
	
	if (frmAddReten.retenType[0].checked) {
		var custList = frmAddReten.Customer;
		if (custList!=null) {
			var txt = custList.options[custList.selectedIndex].text;
			if (txt.indexOf(" | ")>0) {
				txt = txt.substring(txt.indexOf(" | ")+3);
			} else {
				txt = "";
			}
			frmAddReten.payInName.value = txt;
			frmAddReten.payToName.value = txt;
		}
	} else {
		if (frmAddReten.guarantor!=null) {
			frmAddReten.payInName.value = frmAddReten.guarantor.value;
			frmAddReten.payToName.value = frmAddReten.guarantor.value;
		}
	}
}

function validatePayInData() {
	if (frmAddReten.iPayType[0].checked) {
		if (frmAddReten.iPayBnk.value=="") {
			alert(" กรุณาเลือกธนาคาร!! ");
			frmAddReten.iPayBnk.focus();
			return false;
		}

		//---- validate number ----//
       	var numValidate = /^\d{10}$/;
        if (!numValidate.test(frmAddReten.iPayAcc.value)) {
			alert(" กรุณากรอกเลขบัญชีธนาคารเฉพาะตัวเลข 10 หลัก!! ");
			frmAddReten.iPayAcc.focus();
			return false;        
        }                

        //----- validate email -----//
        /*  disable input 
		if (frmAddReten.iEmail.value.length>0) {
	        var emailValidate = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
	        if (!emailValidate.test(frmAddReten.iEmail.value)) {		
				alert(" รูปแบบ Email ไม่ถูกต้อง!! ");
				frmAddReten.iEmail.focus();
				return false;
			}		
		}
		*/
		        
	} else {
		//--- no validate ---//
	}
	
	return true;
}

//--- load once ---//
setPayInName();

//---------------------------------------------------//

</script>

</HTML>