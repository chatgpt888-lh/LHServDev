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
	private int MAX_CHEQUE = 4;
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
String jName = "SERV_Conf_Reten.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

RetentDoc retent_doc = (RetentDoc)session.getAttribute("retent_doc");
String init = doString.checkString(request.getParameter("init"));
if (init.equals("true")) {
	if (retent_doc != null) {
		session.removeAttribute("retent_doc");
		retent_doc=null;
	}
}
String mode = doString.checkString(request.getParameter("mode"),"A");
String docNo = doString.checkString(request.getParameter("docNo"));
String comId = doString.checkString(request.getParameter("comId"));
String projId = doString.checkString(request.getParameter("projId"));
String lockId = "";
String houseNo = "";
String retenType = "";
String empName = "";
String docType = "";
String model = "";
String custName = "";
String retenName = "";
String retentId = "";
String comment = "";
String code = "";
String chqDate = "";
String bank = "";
String branch = "";
String lorId = "";
String chequeNo = "";
String payType = "1";
String payDate = "";
String day = "";
String mnth = "";
String year = "";		
String labelNo = "";
String optionSelected = "";
String display = "display:none";
String chqDisplay = "display:none";
String actionPage = "InitConfRetentServlet";
String action = "act_submit";
boolean view = false;
if (retent_doc != null) {
	if (mode.equals("A")) {
		view = true;
		actionPage = "ConfRetentServlet";
		action = "act_saveandclose";
	}
}
double amount = 0;
int payNo = 0;
int recvNo = 0;
String receiptNo = "";
String recDate = "";
int num_chq = 0;
int num_day = 0;
double retenAmnt = 0;
double recvAmnt = 0;
double recvRetAmnt = 0;
double accrueAmnt = 0;
double cashAmnt = 0;
double chqAmnt = 0;
boolean cashFirm = false;
boolean cancel = true;
Cheque cheques[] = new Cheque[MAX_CHEQUE];
 
//---- 2022-06-30 , for payin ----//
String iPayType = "";
String iPayBnk = "";
String nPayBnk = "";
String iPayAcc = "";
String iEmail = "";

boolean disableSave = false; // 2022-08-05 for disable receive input
//-------------------------------//

int cntSignb = 0; // 2025-04-24 , for count signboard


Properties banklist = new Properties();
DateUtil date_util = new DateUtil();
SimpleDateFormat formatter = new SimpleDateFormat("dd/MM/yyyy HH:mm", Locale.US);
java.util.Date today = new java.util.Date();
StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
Statement bstmt = null;
ResultSet rs = null;
ResultSet rsBank = null;
try {
	if (ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	bstmt = conn.createStatement();

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
	sql.append("SELECT i_finance, n_finance FROM lan:acxfinan WHERE i_branch IS NULL AND i_type = '1' ORDER BY n_finance");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	if (rs != null) {
		while (rs.next() == true) {
			code = doString.checkString(rs.getString("I_FINANCE"));
			if (!code.equals("")) {
				banklist.put(code, doString.checkString(doString.DisplayThai(rs.getString("N_FINANCE"))));
			}			
		}
		rs.close();
		rs = null;
	}

	//sql.delete(0, sql.length());
	//sql.append("SELECT h.i_lor, h.i_sort, (TODAY-DATE(h.d_keyin)) AS NUM_DAY, h.i_doc_type, h.i_lor, h.n_custo, h.i_model, h.i_house, h.i_ret_custo, h.i_reten, h.d_beg_cons, h.i_mon_cons, NVL(h.z_reten,0) AS RETEN_AMT, NVL(h.z_recv_reten,0) AS RECV_AMT, h.i_staff, h.i_doc_status, TRIM(e.n_prename_th) || ' ' || TRIM(e.n_nemploy_th) || ' ' || TRIM(e.n_semploy_th) AS EMP_NAME, h.s_payin FROM lan:serv_rethd h, docflow:acemploy e WHERE h.i_company = '"+comId+"' AND h.i_project = '"+projId+"' AND h.i_docno = '"+docNo+"' AND h.i_staff = e.i_employ");
	
	//---- 2022-06-30 , change sql and join lhpay_std for bank name -----//
	sql.delete(0, sql.length());
	sql.append(" SELECT (TODAY-DATE(h.d_keyin)) AS NUM_DAY, NVL(h.z_reten,0) AS RETEN_AMT, NVL(h.z_recv_reten,0) AS RECV_AMT, ")
	   .append(" TRIM(e.n_prename_th) || ' ' || TRIM(e.n_nemploy_th) || ' ' || TRIM(e.n_semploy_th) AS EMP_NAME, ")
	   .append(" s.n_desc as n_paybnk, h.* ")
	   .append(" FROM lan:serv_rethd h ")
	   .append("   left join lan:lhpay_std s on s.i_type='R' and s.i_key1=h.i_paybnk ")
	   .append(" , docflow:acemploy e ")
	   .append(" WHERE h.i_company = '"+comId+"' AND h.i_project = '"+projId+"' ")
	   .append(" AND h.i_docno = '"+docNo+"' AND h.i_staff = e.i_employ ");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	if (rs != null) {
		if (rs.next() == true) {
			lorId = Integer.toString(rs.getInt("I_LOR"));
			lockId = doString.checkString(rs.getString("I_SORT"));
			houseNo = doString.checkString(rs.getString("I_HOUSE"));
			model = doString.checkString(rs.getString("I_MODEL"));
			docType = doString.checkString(rs.getString("I_DOC_TYPE"));
			custName = doString.checkString(doString.DisplayThai(rs.getString("N_CUSTO")));
			retenType = doString.checkString(rs.getString("I_RET_CUSTO"));
			retentId = doString.checkString(rs.getString("I_RETEN"));
			empName = doString.checkString(doString.DisplayThai(rs.getString("EMP_NAME")));
			retenAmnt = rs.getDouble("RETEN_AMT");
			recvRetAmnt = rs.getDouble("RECV_AMT");
			payNo = rs.getInt("S_PAYIN");
			num_day = rs.getInt("NUM_DAY");
			
			//---- 2022-06-30 , for payin ----//
			iPayType = doString.checkString(rs.getString("i_paytype"),"");
			iPayBnk = doString.checkString(rs.getString("i_paybnk"),"");
			nPayBnk = doString.checkString(rs.getString("n_paybnk"),"");
			iPayAcc = doString.checkString(rs.getString("i_payacc"),"");
			iEmail = doString.checkString(rs.getString("i_email"),"");
			//-------------------------------//			
		}
		rs.close();
		rs=null;
	}
		
	if (num_day <= 7) { cancel = false; }
	accrueAmnt = retenAmnt-recvRetAmnt;
%>
<HTML>
<HEAD>
<TITLE>ใบวางเงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<META name="GENERATOR" content="IBM WebSphere Studio">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<SCRIPT language="javascript" src="script_fx.js"></SCRIPT>
<SCRIPT src="dateUtil.js" type="text/javascript"></SCRIPT>
<SCRIPT language="JavaScript" src="NumberUtil.js" type="text/javascript"></SCRIPT>
<BASE target="_self">
<SCRIPT LANGUAGE="JavaScript">
<!-- Begin
var ggWinCal ;

function selChqDate(dateType) {
	var vWinCal = window.open('calendar.jsp?dateType='+dateType,'blank','width=300,height=250,left=200,top=100');
	vWinCal.opener = self;
	ggWinCal = vWinCal;
}

function CalcRecvAmnt(frm) {
    var recvAmnt = 0;
    var amount = "";
	var i = 0;
	if (!frm.payType[0].checked) {
		for (i=1; i<=<%=MAX_CHEQUE%>; i++) {
			amount = eval("frm.Cheque_Amt"+i+".value");
			if (amount == "")
			{
				amount = 0;
			}
	        recvAmnt += eval(amount);
		}
    }
	recvAmnt += eval(frm.cashAmnt.value);
	return recvAmnt;
}

function CalcAccrue(frm, keycode) {
	var amnt = CalcRecvAmnt(frm);
	accrue = 0;

	if (keycode == 13) { //Enter
		accrue = <%=doString.displayNumber("#########.00", retenAmnt)%> - (<%=doString.displayNumber("#########.00", recvRetAmnt)%> + amnt);
		frm.recvAmnt.value = commaSplit(formatCurrency(amnt));
		frm.accrueAmnt.value = formatCurrency(accrue);
		if (accrue == 0) {
			divLabel.style.display="";
		} else {
			divLabel.style.display="none";
		}
	} else {
		if ((keycode < 45 || keycode > 57) || keycode == 47 ) return(false);
	}
	return(true);
}

function DispCheque(frm) {
	if (frm.payType[0].checked) {
		divCheque.style.display="none";
	} else {
		if (frm.payType[1].checked) {
			frm.cashAmnt.value = "0";
		}
		divCheque.style.display="";
	}
}

function ChckAmount(frm) {
    var tot_amount = 0;
    var amount = "";
    var valid = 1;
	var i = 0;
    //var recvAmnt = parseFloat(frm.recvAmnt.value);
    var recvAmnt = 0;

	if (!frm.payType[0].checked) {
		for (i=1; i<=<%=MAX_CHEQUE%>; i++) {
			amount = eval("frm.Cheque_Amt"+i+".value");
			if (amount == "")
			{
				amount = 0;
			}
	        tot_amount += eval(amount);
		}
		if (tot_amount == 0)
		{
			alert("โปรดระบุจำนวนเงินในเช็ค");
			return 0;
		}
    }

	tot_amount += eval(frm.cashAmnt.value);
	tot_amount = eval(formatCurrency(tot_amount));
    return valid;
}


function SaveAndClose(frm) {
    var amount = 0;
	var accrueAmnt = parseFloat(frm.accrueAmnt.value);
	<%if (view) {%>
	frm.submit();
	<%} else {%>
	if (frm.cashFirm.value == "false") {
		if ((!frm.payType[0].checked) && (!frm.payType[1].checked) && (!frm.payType[2].checked)) {
			alert("โปรดระบุประเภทการรับชำระ");
		} else {
			if (frm.payType[1].checked) {
				frm.cashAmnt.value = "0";
			} else {
				amount = eval(frm.cashAmnt.value);
				if (amount <= 0) {
					alert("โปรดระบุจำนวนเงินสด");
					//frm.cashAmnt.focus();
					return;
				}
			}
			if (ChckAmount(frm) == 1) {
				if (accrueAmnt == 0) {
					if (frm.labelNo.value == "") {
						alert("โปรดเลือกเลขที่ป้ายต่อเติม");
						frm.labelNo.focus();
					}
				}
				frm.submit();
			}
		}
	} else {
		if (frm.payType.value == "") {
			alert("โปรดระบุประเภทการรับชำระ");
		} else {
			if (frm.payType.value == "2") {
				frm.cashAmnt.value = "0";
			} else {
				amount = eval(frm.cashAmnt.value);
				if (amount <= 0) {
					alert("โปรดระบุจำนวนเงินสด");
					//frm.cashAmnt.focus();
					return;
				}
			}
			if (accrueAmnt == 0) {
				if (frm.labelNo.value == "") {
					alert("โปรดเลือกเลขที่ป้ายต่อเติม");
					frm.labelNo.focus();
				}
			}
			frm.submit();
		}
	}
	<%}%>
}
// End -->
</script>
</HEAD>
<BODY leftmargin="0" topmargin="0" marginheight="0" marginwidth="0">
<FORM name="frmConfReten" method="post" action="/LHServ/<%=actionPage%>">
<INPUT type="hidden" name="comId" value="<%=comId%>">
<INPUT type="hidden" name="projId" value="<%=projId%>">
<INPUT type="hidden" name="docNo" value="<%=docNo%>">
<INPUT type="hidden" name="lockId" value="<%=lockId%>">
<INPUT type="hidden" name="lorId" value="<%=lorId%>">
<INPUT type="hidden" name="payNo" value="<%=payNo%>">
<INPUT type="hidden" name="status" value="">
<INPUT type="hidden" name="recvRetAmnt" value="<%=doString.displayNumber("#########.00", recvRetAmnt)%>">
<TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
    <TR>
        <TD width="100%" class="BD">
        <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
            <TR>
                <TD width="80%" class="bigh"><IMG border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp; ใบวางเงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม</TD>
                <TD width="20%" class="bigh" align="right">
				<%if (cancel){%><div style="z-index:1 ; position:absolute; left: 900px; top:0px; width: 75px; height: 75px"><img border="0" src="images/icon_cancel15days.gif" align="absmiddle" width="75" height="75"></div><%}%>
</TD>
            </TR>
        </TABLE>
        <BR style="font-size: 10pt">
        <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
            <TR>
                <TD class="item_tab1"><IMG border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></TD>
                <TD class="item_tab2" width="200">Confirm ใบแจ้งชำระเงินค้ำประกัน</TD>
                <TD class="item_tab3"></TD>
                <TD>&nbsp;</TD>
            </TR>
        </TABLE>
        <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
            <TR>
                <TD width="5" valign="top"><IMG border="0" src="images/Corn01.gif" width="5" height="5"></TD>
                <TD class="frmTop">&nbsp;</TD>
                <TD width="5" valign="top" align="right"><IMG border="0" src="images/Corn02.gif" width="5" height="5"></TD>
            </TR>
        </TABLE>
<%
	sql.delete(0, sql.length());
	sql.append("SELECT NVL(s_receive,0) AS RECV_NO, i_receipt, d_payin FROM lan:serv_payin WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+docNo+"' AND s_payin = "+Integer.toString(payNo));
	rs = stmt.executeQuery(sql.toString());
	if (rs != null) {
		if (rs.next() == true) {
			recvNo = rs.getInt("RECV_NO");
			if (recvNo > 0) {
				cashFirm = true;
				payDate = doString.checkString(doString.DisplayThai(rs.getString("D_PAYIN")));
				if (!payDate.equals("")) {
					payDate = payDate.substring(8)+"/"+payDate.substring(5,7)+"/"+payDate.substring(0,4);
				}
				receiptNo = doString.checkString(rs.getString("I_RECEIPT"));
			}
		}
		rs.close();
		rs=null;
	}
	
if (!cashFirm || doString.checkString(receiptNo,"").trim().length()<=0) {
	disableSave = true;
	payType = "";
	payDate = "";
	receiptNo = "";	
}

	
	rs = stmt.executeQuery("SELECT d_receipt FROM lan:acrrecpt WHERE i_company = '"+comId+"' AND i_receipt = '"+receiptNo+"'");
	if (rs != null) {
		if (rs.next() == true) {
			recDate = DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString("D_RECEIPT")));
		}
		rs.close();
		rs=null;
	}
	if (retenType.equals("1")) {
		retenType = "04";
		sql.delete(0, sql.length());
		sql.append("SELECT n_prename, n_ncustomer, n_scustomer FROM lan:acxcusto WHERE i_customer = "+retentId);
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		if (rs != null) {
			if (rs.next() == true) {
				retenName = doString.checkString(doString.DisplayThai(rs.getString("N_PRENAME")))+" "+doString.checkString(doString.DisplayThai(rs.getString("N_NCUSTOMER")))+ " "+doString.checkString(doString.DisplayThai(rs.getString("N_SCUSTOMER")));
			}
			rs.close();
			rs=null;
		}
	} else {
		if (retenType.equals("2")) {
			retenType = "05";
		} else {
			retenType = "06";
		}
		sql.delete(0, sql.length());
		sql.append("SELECT n_pname, n_name, n_sname FROM lan:serv_venprj WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_type = '"+retenType+"' AND i_vendor = '"+retentId+"'");
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		if (rs != null) {
			if (rs.next() == true) {
				retenName = doString.checkString(doString.DisplayThai(rs.getString("N_PNAME")))+" "+doString.checkString(doString.DisplayThai(rs.getString("N_NAME")))+" "+doString.checkString(doString.DisplayThai(rs.getString("N_SNAME")));
			}
			rs.close();
			rs=null;
		}
	}
%>        
        <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
            <TR>
                <TD width="100%" class="frmLR" align="center">
                <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
                    <TR>
                        <TD class="item ; dotline01" height="22" width="12%">โครงการ :</TD>
                        <TD height="22" width="36%" class="dotline01">
<%	
	sql.delete(0, sql.length());
	sql.append("SELECT n_project FROM lan:acxprojt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	if (rs != null) {
		if (rs.next() == true) {
			out.print(comId+projId+" : "+doString.checkString(doString.DisplayThai(rs.getString("N_PROJECT"))));
		}// end if
		rs.close();
		rs=null;
	}
%>
						</TD>
                        <TD height="22" class="item ; dotline01" width="16%">แปลง :</TD>
                        <TD height="22" width="36%" class="dotline01"><%=lockId%></TD>
                    </TR>
                    <TR>
                        <TD class="item ; dotline01" height="22" width="12%">บ้านเลขที่ :</TD>
                        <TD height="22" width="36%" class="dotline01"><%=houseNo%></TD>
                        <TD height="22" class="item ; dotline01" width="16%">เลขที่ใบวางเงินค้ำฯ :</TD>
                        <TD height="22" width="36%" class="dotline01"><%=docNo%></TD>
                    </TR>
                    <TR>
                        <TD class="item ; dotline01" height="22" width="12%">ชื่อลูกค้า :</TD>
                        <TD height="22" width="36%" class="dotline01"><%=custName%></TD>
                        <TD height="22" class="item ; dotline01" width="16%">ชื่อผู้วางเงินค้ำฯ :</TD>
                        <TD height="22" width="36%" class="dotline01"><%=retenName%></TD>
                    </TR>
                </TABLE>
                </TD>
            </TR>
        </TABLE>
        <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
            <TR>
                <TD width="5" valign="bottom"><IMG border="0" src="images/Corn03.gif" width="5" height="5"></TD>
                <TD class="frmBottom">&nbsp;</TD>
                <TD width="5" valign="bottom" align="right"><IMG border="0" src="images/Corn04.gif" width="5" height="5"></TD>
            </TR>
        </TABLE>
        <BR style="font-size: 10pt">
        <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
            <TR>
                <TD class="item_tab1"><IMG border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></TD>
                <TD class="item_tab2" width="200">รายละเอียดการชำระเงิน</TD>
                <TD class="item_tab3"></TD>
                <TD>&nbsp;</TD>
            </TR>
        </TABLE>
        <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
            <TR>
                <TD width="5" valign="top"></TD>
                <TD class="frmTop">&nbsp;</TD>
                <TD width="5" valign="top" align="right"><IMG border="0" src="images/Corn02.gif" width="5" height="5"></TD>
            </TR>
        </TABLE>
        <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
            <TR>
                <TD width="100%" class="frmLR" align="center" style="padding: 0px 4px 0px 4px">
                <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
                    <TR>
                        <TD width="5" valign="top"><IMG border="0" src="images/02Corn01.gif" width="5" height="5"></TD>
                        <TD class="frmTop2">&nbsp;</TD>
                        <TD width="5" valign="top" align="right"><IMG border="0" src="images/02Corn02.gif" width="5" height="5"></TD>
                    </TR>
                </TABLE>
                <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
                    <TR>
                        <TD width="100%" class="frmLR2" align="center">
                        <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
                            <TR>
                                <TD class="item ; dotline01" height="22" width="12%">ข้อมูลจาก :</TD>
                                <TD height="22" width="36%" class="dotline01">
<%
	recvAmnt = 0;
	sql.delete(0, sql.length());
	if (cashFirm) {
		out.print("การ Conf. รับเงินจากแคชเชียร์");
		sql.append("SELECT SUM(z_price) AS RECV_AMT FROM lan:acrrecev WHERE i_company = '")
				.append(comId)
				.append("' AND i_project = '")
				.append(projId)
				.append("' AND i_lor = ")
				.append(lorId)
				.append(" AND i_due = 'O5' AND s_receive = ")
				.append(Integer.toString(recvNo));
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		if (rs != null) {
			if (rs.next() == true) {
				recvAmnt = rs.getDouble("RECV_AMT");
			}
			rs.close();
			rs=null;
		}
		sql.delete(0, sql.length());
		sql.append("SELECT s_item, i_mtype, i_cheque, z_amount, i_fbank, i_fbranch, d_payin, d_receive FROM lan:acrdtrec WHERE i_company = '")
				.append(comId)
				.append("' AND i_project = '")
				.append(projId)
				.append("' AND i_lor = ")
				.append(lorId)
				.append(" AND s_receive = ")
				.append(Integer.toString(recvNo))
				.append(" ORDER BY s_item");
		rs = stmt.executeQuery(sql.toString());
		if (rs != null) {
			while (rs.next() == true) {
				chequeNo = doString.checkString(rs.getString("I_CHEQUE"));
				amount = rs.getDouble("Z_AMOUNT");
				if (doString.checkString(rs.getString("I_MTYPE")).equals("1")) {
					cashAmnt += amount;
				} else {
					
					bank = doString.checkString(rs.getString("I_FBANK"));
					branch = doString.checkString(rs.getString("I_FBRANCH"));

					sql.delete(0, sql.length());
					sql.append("SELECT n_finance FROM lan:acxfinan WHERE i_finance = '"+bank+"' AND i_branch = '"+branch+"' AND i_type = '1'");
					servlog.startLog(sql.toString());
					rsBank = bstmt.executeQuery(sql.toString());
					servlog.endLog();
					if (rsBank != null) {
						if (rsBank.next() == true) {
							branch = doString.checkString(rsBank.getString("N_FINANCE"));
						} else {
							branch = "";
						}
						rsBank.close();
						rsBank=null;
					}
					cheques[num_chq] = new Cheque(chequeNo, DateUtil.ifxToThaiDateNoTime(doString.DisplayThai(rs.getString("D_RECEIVE"))), DateUtil.ifxToThaiDateNoTime(doString.DisplayThai(rs.getString("D_PAYIN"))), bank, branch, amount);
					num_chq++;
					chqAmnt += amount;
				}
			}
			rs.close();
			rs=null;
		}
		if (retent_doc != null) {		
			Vector chequelist = retent_doc.getChequelist();
			if (chequelist != null) {
				if (chequelist.size() > 0) {
					for (int c=0; c<num_chq; c++) {
						cheques[c]=null;
					}
					for (num_chq=0; num_chq<chequelist.size(); num_chq++) {
						Cheque cheque = (Cheque)chequelist.elementAt(num_chq);
						if (cheque != null) {
							cheques[num_chq]=cheque;
						}
					}// end for
				}
			}
		}


		if ((cashAmnt > 0) && (chqAmnt == 0)) {
			payType = "1";
		}
		if ((cashAmnt == 0) && (chqAmnt > 0)) {
			payType = "2";
		}
		if ((cashAmnt > 0) && (chqAmnt > 0)) {
			payType = "3";
		}
		if (retent_doc != null) {
			labelNo = retent_doc.getLabelNo();
		}

	} else {
		if (disableSave) {
			out.println("ไม่พบข้อมูลใบเสร็จรับเงิน"); // no receive input
		} else {
			out.print("บันทึกข้อมูลโดย จนท.บริการ");
			if (retent_doc != null) {
				cashAmnt = retent_doc.getCashAmnt();
				payType = retent_doc.getPayType();
				payDate = retent_doc.getPayDate();
				payDate = payDate.substring(8)+"/"+payDate.substring(5,7)+"/"+payDate.substring(0,4);
				labelNo = retent_doc.getLabelNo();
				num_chq = 0;
				Vector chequelist = retent_doc.getChequelist();
				if (chequelist != null) {
					for (num_chq=0; num_chq<chequelist.size(); num_chq++) {
						Cheque cheque = (Cheque)chequelist.elementAt(num_chq);
						if (cheque != null) {
							chqAmnt += cheque.getAmount();
							cheques[num_chq]=cheque;
						}
					}// end for
				}
			}
		}
	}

	recvAmnt = cashAmnt + chqAmnt;
	accrueAmnt -= recvAmnt;
	if (accrueAmnt == 0)
	{
		display = "display:show";
	}
	if (!payType.equals("") && !payType.equals("1")) {
		chqDisplay = "display:show";
	}
%>
								</TD>
                                <TD class="item ; dotline01" height="22" width="16%">เลขที่ใบเสร็จ :</TD>
                                <TD height="22" width="36%" class="dotline01"><%=receiptNo%>&nbsp;</TD>
                            </TR>
							
                            <TR>
                                <TD class="item ; dotline01" height="22" width="12%">ชำระเป็น :</TD>
                                <TD height="22" width="36%" class="dotline01">
<%if (cashFirm || view || disableSave) {
if (payType.equals("1")) { out.print("เงินสด"); }
if (payType.equals("2")) { out.print("เช็ค"); }
if (payType.equals("3")) { out.print("เงินสดและเช็ค"); }
%>
								<INPUT type="hidden" name="payType" value="<%=payType%>">
<%} else {%>
								<INPUT type="radio" value="1" name="payType" onClick="DispCheque(frmConfReten)" <%if(payType.equals("1")){ out.print("checked");}%>> เงินสด&nbsp;&nbsp;&nbsp;&nbsp;
								<INPUT type="radio" value="2" name="payType" onClick="DispCheque(frmConfReten)" <%if(payType.equals("2")){ out.print("checked");}%>> เช็ค&nbsp;&nbsp;&nbsp;&nbsp;
								<INPUT type="radio" value="3" name="payType" onClick="DispCheque(frmConfReten)" <%if(payType.equals("3")){ out.print("checked");}%>> เงินสดและเช็ค
<%}%>
								</TD>
                                <TD height="22" class="item ; dotline01" width="16%">วันที่ใบเสร็จ :</TD>
                                <TD height="22" width="36%" class="dotline01"><%=recDate%>&nbsp;</TD>
                            </TR>
                            <TR>
                                <TD class="item ; dotline01" height="22" width="12%">เงินสด :</TD>
                                <TD height="22" width="36%" class="dotline01">
<%if (cashFirm || view || disableSave) {%>
								<%=doString.displayNumber("###,###,###.00", cashAmnt)%>
								<INPUT type="hidden" name="cashAmnt" value="<%=doString.displayNumber("#########.00", cashAmnt)%>">
<%} else {%>
								<INPUT type="text" name="cashAmnt" class="boxR" style="width: 100px" value="<%=doString.displayNumber("#########.00", cashAmnt)%>" onFocus="if (frmConfReten.payType[1].checked) { this.blur(); }" onBlur="CalcAccrue(frmConfReten, 13)" onKeyPress="if(CalcAccrue(frmConfReten, event.keyCode)==false){event.returnValue = false;}">
<%}%>
								&nbsp; บาท</TD>
                                <TD height="22" class="item ; dotline01" width="16%">วันที่ Pay in</TD>
                                <TD height="22" width="36%" class="dotline01">
								<%if (cashFirm || view || disableSave) { out.print(payDate);
if (payDate.length()>=10) {
								day = payDate.substring(0,2);
								mnth = payDate.substring(3,5);
								year = payDate.substring(6);
								year = Integer.toString(Integer.parseInt(year)+543);
								%>
								<INPUT type="hidden" name="Payday" value="<%=day%>">
								<INPUT type="hidden" name="Paymnth" value="<%=mnth%>">
								<INPUT type="hidden" name="Payyear" value="<%=year%>">
								<%
}								
								} else { date_util.printHtmlThaiDateNoTime(out, "Pay", payDate, 5, 2, "white", "#0078FF"); }%>								
								</TD>
                            </TR>
                        </TABLE>
                        </TD>
                    </TR>
                </TABLE>

                <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
                    <TR>
                        <TD width="5" valign="bottom"><IMG border="0" src="images/02Corn03.gif" width="5" height="5"></TD>
                        <TD class="frmBottom2">&nbsp;</TD>
                        <TD width="5" valign="bottom" align="right"><IMG border="0" src="images/02Corn04.gif" width="5" height="5"></TD>
                    </TR>
                </TABLE>

				<DIV id="divCheque" style="<%=chqDisplay%>">
                <BR style="font-size: 2pt">
                <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
                    <TR>
                        <TD width="5" valign="top" bgcolor="#D7E6FF"><IMG border="0" src="images/02Corn01.gif" width="5" height="5"></TD>
                        <TD class="frmTop2" bgcolor="#D7E6FF">&nbsp;</TD>
                        <TD width="5" valign="top" align="right" bgcolor="#D7E6FF"><IMG border="0" src="images/02Corn02.gif" width="5" height="5"></TD>
                    </TR>
                </TABLE>
                <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
                    <TR>
                        <TD width="100%" class="frmL2">
                        <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
                            <TR>
                                <TD width="9%" class="col_name02">ฉบับที่</TD>
                                <TD width="14%" class="col_name02">เลขที่เช็ค</TD>
                                <TD width="19%" class="col_name02">วันที่เช็ค</TD>
                                <TD width="14%" class="col_name02">ธนาคาร</TD>
                                <TD width="27%" class="col_name02">สาขา</TD>
                                <TD width="17%" class="col_name02">จำนวนเงิน</TD>
                            </TR>
<%
	int j = 0;
    for (int i=0; i<MAX_CHEQUE; i++) {
        j = i+1;
        code = "";
		chqDate = "&nbsp;";
		payDate = "&nbsp;";
        bank = "";
        branch = "";
        amount = 0;
        if (cheques[i] != null) {
			code = cheques[i].getChequeId();
			chqDate = cheques[i].getChqDate();
			bank = cheques[i].getBank();
			branch = cheques[i].getBranch();
			amount = cheques[i].getAmount();
        }
%>
                            <TR>
                                <TD width="9%" align="center" class="dotline02"><%=j%></TD>
                                <TD width="14%" align="center" class="dotline02">
<% if (cashFirm || view || disableSave) { %>
<INPUT type="hidden" name="Cheque_Id<%=j%>" value="<%=code%>">
<%=code%>&nbsp;
<% } else { %>
					  <INPUT type="text" name="Cheque_Id<%=j%>" style="width: 100%" class="box" maxlength="10" size="10" value="<%=code%>">
<%}%>
								</TD>
                                <TD width="19%" align="center" class="dotline02">
<% if (cashFirm || view || disableSave) { %>
<%=chqDate%>
<INPUT type="hidden" name="chqDate<%=j%>" value="<%=chqDate%>">
<% } else { %>						
					  <INPUT type="text" name="chqDate<%=j%>" class="box" maxlength="10" size="10" onFocus="this.blur()" value="<%=chqDate%>">
					  <A HREF="javascript:selChqDate('chqDate<%=j%>')"><IMG border="0" src="images/i_calendar.gif" align="absmiddle" width="18" height="18"></A>
<%}%>
								</TD>
                                <TD width="14%" align="center" class="dotline02 ; item">
<% if (view || disableSave) { %>
<INPUT type="hidden" name="Bank<%=j%>" value="<%=bank%>">
<%=doString.checkString(banklist.getProperty(bank))%>&nbsp;
<% } else { %>

                        <SELECT name="Bank<%=j%>" class="box" size="1">
<%
        Enumeration e = banklist.propertyNames();
        while (e.hasMoreElements())
        {
            optionSelected = "";
            code = (String)e.nextElement();
            if (code.equals(bank))
            {
                optionSelected = "selected";
            }
%>
                  <OPTION value="<%=code%>" <%=optionSelected%>><%=banklist.getProperty(code)%></OPTION>
<%
        }
%>
                       </SELECT>
<%}%>
								</TD>
                                <TD width="27%" class="dotline02">
<% if (view || disableSave) { %>
<INPUT type="hidden" name="Branch<%=j%>" value="<%=doString.DisplayThai(branch)%>">
<%=doString.DisplayThai(branch)%>&nbsp;
<%} else {%>
					  <INPUT type="text" name="Branch<%=j%>" class="box" style="width: 100%" value="<%=doString.DisplayThai(branch)%>">
<%}%>
								</TD>
                                <TD width="17%" class="dotline02" align="right">
<% if (cashFirm || view || disableSave) { %>
	<% if (amount > 0) { %>
	<%=doString.displayNumber("##,###,###.00", amount)%>
	<% } %>&nbsp;
	<INPUT type="hidden" name="Cheque_Amt<%=j%>" value="<%=doString.displayNumber("#########.00", amount)%>">
<% } else { %>
					  <INPUT type="text" name="Cheque_Amt<%=j%>" value="<%=doString.displayNumber("#########.00", amount)%>" size="20" maxlength="13" style="width: 100%" class="boxR" onBlur="CalcAccrue(frmConfReten, 13)" onKeyPress="if(CalcAccrue(frmConfReten, event.keyCode)==false){event.returnValue = false;}">
<%}%>
								</TD>
                            </TR>
<%
    }// end of for
%>
                        </TABLE>
						<INPUT type="hidden" name="cashFirm" value="<%=cashFirm%>">
                        </TD>
                    </TR>
                </TABLE>
                <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
                    <TR>
                        <TD width="5" valign="bottom"><IMG border="0" src="images/02Corn03.gif" width="5" height="5"></TD>
                        <TD class="frmBottom2">&nbsp;</TD>
                        <TD width="5" valign="bottom" align="right"><IMG border="0" src="images/02Corn04.gif" width="5" height="5"></TD>
                    </TR>
                </TABLE>
				</DIV>
                <BR style="font-size: 2pt">
                <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
                    <TR>
                        <TD width="5" valign="top"><IMG border="0" src="images/02Corn01.gif" width="5" height="5"></TD>
                        <TD class="frmTop2">&nbsp;</TD>
                        <TD width="5" valign="top" align="right"><IMG border="0" src="images/02Corn02.gif" width="5" height="5"></TD>
                    </TR>
                </TABLE>
                <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
                    <TR>
                        <TD width="100%" class="frmLR2" align="center">
                        <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
                            <TR>
                                <TD class="item ; dotline01" height="22" width="20%">จำนวนเงินค้ำประกัน :</TD>
                                <TD height="22" width="12%" class="dotline01" align="right"><%=doString.displayNumber("###,###,###.00", retenAmnt)%></TD>
                                <TD height="22" width="68%" class="dotline01">&nbsp; บาท</TD>
                            </TR>
                            <TR>
                                <TD class="item ; dotline01" height="22" width="20%">รับชำระแล้ว :</TD>
                                <TD height="22" width="12%" class="dotline01" align="right"><%=doString.displayNumber("###,###,###.00", recvRetAmnt)%></TD>
                                <TD height="22" width="68%" class="dotline01">&nbsp; บาท</TD>
                            </TR>
                            <TR>
                                <TD class="item ; dotline01" height="22" width="20%">จน.เงินรับชำระ :</TD>
                                <TD height="22" width="12%" class="dotline01" align="right">
<%if (cashFirm || view || disableSave) {%>
								<%=doString.displayNumber("###,###,###.00", recvAmnt)%>
								<INPUT type="hidden" name="recvAmnt" value="<%=doString.displayNumber("#########.00", recvAmnt)%>">
<%} else {%>
								<INPUT type="text" name="recvAmnt" class="boxDR" style="width: 100px" value="<%=doString.displayNumber("###,###,###.00", recvAmnt)%>">
<%}%>								
								</TD>
                                <TD height="22" width="68%" class="dotline01">&nbsp; บาท</TD>
                            </TR>
                            <TR>
                                <TD class="item ; dotline01" height="22" width="20%">โดย คงค้าง :</TD>
                                <TD height="22" width="12%" class="dotline01 ; item" align="right"><INPUT type="text" name="accrueAmnt" class="boxDR" value="<%=doString.displayNumber("#########.00", accrueAmnt)%>" style="width:60px"></TD>
                                <TD height="22" width="68%" class="dotline01 ; item">&nbsp; บาท</TD>
                            </TR>
                        </TABLE>
                        </TD>
                    </TR>
                </TABLE>
                <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
                    <TR>
                        <TD width="5" valign="bottom"><IMG border="0" src="images/02Corn03.gif" width="5" height="5"></TD>
                        <TD class="frmBottom2">&nbsp;</TD>
                        <TD width="5" valign="bottom" align="right"><IMG border="0" src="images/02Corn04.gif" width="5" height="5"></TD>
                    </TR>
                </TABLE>
                </TD>
            </TR>
        </TABLE>
        <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
            <TR>
                <TD width="5" valign="bottom"><IMG border="0" src="images/Corn03.gif" width="5" height="5"></TD>
                <TD class="frmBottom">&nbsp;</TD>
                <TD width="5" valign="bottom" align="right"><IMG border="0" src="images/Corn04.gif" width="5" height="5"></TD>
            </TR>
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
                <%
                	if (iPayType.equalsIgnoreCase("PAYIN")) {
                		//--- payin , display bank & account ---//
                		if (iPayAcc.length()>=10) {
                			iPayAcc = iPayAcc.substring(0,3)+"-"+iPayAcc.substring(3,4)+"-"+iPayAcc.substring(4,9)+"-"+iPayAcc.substring(9);
                		}
                		
						%>
		                <TR>                  
						  <TD class="item ; dotline01" height="22" width="13%">Pay-In เข้าบัญชี   : </TD>
						  <TD class="dotline01" height="22" width="20%">ธนาคาร<%=doString.DisplayThai(nPayBnk) %></TD>
						  <TD class="item ; dotline01" height="22" width="13%"> ชื่อบัญชี : </TD>
						  <TD class="dotline01" height="22" width="20%">&nbsp;<%=doString.checkString(retenName,"-") %></TD>
						  <TD class="item ; dotline01" height="22" width="14%"> เลขที่บัญชี  : </TD>
						  <TD class="dotline01" height="22" width="20%">&nbsp;<%=doString.checkString(iPayAcc,"-") %></TD>                
		                </TR>  
		                <!-- 
		                <TR>                  
						  <TD class="item ; dotline01" height="22"><nobr>E-Mail แจ้งกลับ กรณี Pay-In เรียบร้อยแล้ว : </nobr></TD>
						  <TD class="dotline01" height="22" colspan="5"><%=doString.checkString(iEmail,"-") %></TD>
						</TR>
						-->						
		                <%
                	} else {
                		//--- payto , display cheque name ---//
                		%>	 
		                <TR>          
						  <TD class="item ; dotline01" height="22" width="13%"><nobr>เช็คคืนเงิน สั่งจ่ายในนาม : </nobr></TD>
						  <TD class="dotline01" height="22" width="87%"><%=doString.checkString(retenName,"-") %></TD>		                
		                </TR> 	                		
                		<%
                	}
                %> 
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
        
        <BR style="font-size: 10pt">
		<DIV id="divLabel" style="<%=display%>">
        <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
            <TR>
                <TD class="item_tab1"><IMG border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></TD>
                <TD class="item_tab2" width="200">รายละเอียดป้ายต่อเติม</TD>
                <TD class="item_tab3"></TD>
                <TD>&nbsp;</TD>
            </TR>
        </TABLE>
        <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
            <TR>
                <TD width="5" valign="top"><IMG border="0" src="images/Corn01.gif" width="5" height="5"></TD>
                <TD class="frmTop">&nbsp;</TD>
                <TD width="5" valign="top" align="right"><IMG border="0" src="images/Corn02.gif" width="5" height="5"></TD>
            </TR>
        </TABLE>
        <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
            <TR>
                <TD width="100%" class="frmLR" align="center">
                <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
                    <TR>
                        <TD class="item ; dotline01" height="22" width="13%">เลขที่ป้ายต่อเติม :</TD>
                        <TD height="22" width="43%" class="dotline01">
<%
	if (view || disableSave) { 
		out.print(labelNo); 
		cntSignb = 1; // 2025-04-24
		%><INPUT type="hidden" name="labelNo" value="<%=labelNo%>"><%
	} else {
		%>
		<SELECT size="1" name="labelNo" class="box" style="width:250px">
		<%
		
	//--- 2025-04-24 , count for check signboard ---//
	sql.delete(0, sql.length());
	sql.append("SELECT i_signb FROM lan:serv_signb WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND f_use = 'N' ORDER BY i_signb");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	if (rs != null) {
		while (rs.next() == true) {
			optionSelected = "";
			code = doString.checkString(rs.getString("I_SIGNB"));
			if (code.equals(labelNo)) {
				optionSelected = "selected";
			}
			
			cntSignb++;
%>
              <OPTION value="<%=code%>" <%=optionSelected%>><%=code%></OPTION>
<%
		}// end while
		rs.close();
		rs=null;
	}
	
	//--- 2025-04-24 , disable some button if no signboard ---//
	if (cntSignb<=0) {
		disableSave = true;
	}
%>
                  </SELECT>
<%}%>
						</TD>
                        <TD height="22" class="item ; dotline01" width="14%">วันที่รับ :</TD>
                        <TD height="22" width="30%" class="dotline01"><%=formatter.format(today)%></TD>
                    </TR>
                    <TR>
                        <TD class="item ; dotline01" height="22" width="13%">ชื่อผู้รับ :</TD>
                        <TD height="22" width="43%" class="dotline01"><%=doString.DisplayThai(user.getEmpName())%></TD>
                        <TD height="22" class="item ; dotline01" width="14%">&nbsp;</TD>
                        <TD height="22" width="30%" class="dotline01">&nbsp;</TD>
                    </TR>
                </TABLE>
                </TD>
            </TR>
        </TABLE>
<%
	stmt.close();
	bstmt.close();
	conn.close();
	stmt=null;
	bstmt=null;
	conn=null;
} catch (Exception e) {
	System.out.println("ERROR SERV_Conf_Reten.jsp : " + e.getMessage());
	throw new ServletException(e.getMessage());
} finally {
	// Clean up.
	try {
		if (rs != null) rs.close();
		if (stmt != null) stmt.close();
		if (bstmt != null) bstmt.close();
		if (conn != null) conn.close();
	}
	catch( SQLException ignore ){}
}
%>        
        <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
            <TR>
                <TD width="5" valign="bottom"><IMG border="0" src="images/Corn03.gif" width="5" height="5"></TD>
                <TD class="frmBottom">&nbsp;</TD>
                <TD width="5" valign="bottom" align="right"><IMG border="0" src="images/Corn04.gif" width="5" height="5"></TD>
            </TR>
        </TABLE>
		</DIV>
        <BR style="font-size: 10pt">
        <TABLE border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
            <TR>
                <TD class="act_tab1"></TD>
                <TD width="250" class="act_tab2">
				<%if(view){%>
				<A href="/LHServ/SERV_Conf_Reten.jsp?mode=E&comId=<%=comId%>&projId=<%=projId%>&docNo=<%=docNo%>"><IMG border="0" src="images/act_edit.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27"></A>&nbsp;
				<%}%>
				<%if(!disableSave){%>
				<A href="javascript:SaveAndClose(frmConfReten)"><IMG border="0" src="images/<%=action%>.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27"></A>&nbsp;
				<%}%>
				<%if(cancel){%>
			<A href="/LHServ/CancelRetentServlet?comId=<%=comId%>&projId=<%=projId%>&docNo=<%=docNo%>"><IMG border="0" src="images/act_cancel003.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27"></A>&nbsp;
				<%}%>
				</TD>

                <TD class="act_tab3"></TD>
                <TD class="act_tab4"><A href="javascript:history.back()" target="_top"><IMG border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></A>&nbsp; <A href="SERV_RetenHome.jsp"><IMG border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></A></TD>
            </TR>
        </TABLE>
        </TD>
    </TR>
</TABLE>
<BR style="font-size: 30pt">
<TABLE border="0" cellspacing="0" cellpadding="0" width="100%">
    <TR>
        <TD width="100%" class="copyright" align="center">Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5 <BR>
        ติดต่อสอบถามได้ที่ : <A href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</A>&nbsp; หรือ โทร. 0-2230-8279 (คุณประพัฒน์ ฝ่ายบริการ)&nbsp; 0-2230-8491-5 (ฝ่าย IT) <BR>
        <IMG src="images/copyright.gif" width="475" height="26"></TD>
    </TR>
</TABLE>
</FORM>

<%
	if (!view && cntSignb<=0) {
		%>
		<script>alert("ไม่พบข้อมูลป้ายต่อเติมว่าง, กรุณาเพิ่มข้อมูลป้ายต่อเติมก่อนทำการบันทึกข้อมูล !!");</script>
		<%
	}
%>
 
 
</BODY>
</HTML>