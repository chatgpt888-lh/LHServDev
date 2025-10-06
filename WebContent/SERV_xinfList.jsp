<%@page contentType="text/html; charset=TIS-620"%>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%!
	// Caching the DataSource - It is obtained in the jspInit() method
	private javax.sql.DataSource ds = null;
	private String subcontext = "java:comp/env";
	private void getDS() throws Exception {
		String dsName = "";
		Context ctx = new InitialContext();
		InitialContext initCtx = new InitialContext();
	
		// Perform a naming service lookup to get the DataSource object.
		Context env = (Context)ctx.lookup(subcontext);
		dsName = (String)env.lookup("DATASOURCE_NAME");
		dsName = subcontext + "/" + dsName;
		ds = (javax.sql.DataSource) initCtx.lookup(dsName);
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
<TITLE>รายงานการรับชำระเงินค่าบริการสาธารณะ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
<!--
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

function checkFormatDate(str)
{
	mystring = str;
	if (mystring.match(/(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.]([1-9])\d\d\d/ ) ) { 
	   var yyyy = parseInt(str.substring(6,10),10);
	   var mm = parseInt(str.substring(3,5),10)-1;
	   var dd = parseInt(str.substring(0,2),10);
	   if (yyyy>2400) yyyy -= 543;

       var cdate = new Date(yyyy,mm,dd);
	   if (mm!=cdate.getMonth()) {
	      alert("วันที่ไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
	      return false;
	   }
	} else {
		alert("รูปแบบวันที่ไม่ถูกต้อง !");
		return false;
	}
	
	return true;
}  

function LookupAccount() {
	  if (frmInfPayin.Company.value == "") {
		  alert("กรุณาเลือกบริษัท !!");
		  return;
	  }
	  frmInfPayin.action="/LHServ/SERV_xinfList.jsp";
	  frmInfPayin.submit();
}

function searchData() {
	if (frmInfPayin.Company.value == "") {
		alert("กรุณาเลือกบริษัท !!");
		frmInfPayin.Company.focus();
		return;
	}
	var begDate = Trim(frmInfPayin.Begday.value)+"/"+Trim(frmInfPayin.Begmnth.value)+"/"+Trim(frmInfPayin.Begyear.value);
	var endDate = Trim(frmInfPayin.Endday.value)+"/"+Trim(frmInfPayin.Endmnth.value)+"/"+Trim(frmInfPayin.Endyear.value);
	if (!checkFormatDate(begDate)) {
		frmInfPayin.Begday.focus();
		return;
	}	  
	if (!checkFormatDate(endDate)) {
		frmInfPayin.Endday.focus();
		return;
	}	  	
	begDate = Trim(frmInfPayin.Begday.value)+Trim(frmInfPayin.Begmnth.value)+Trim(frmInfPayin.Begyear.value);	
	endDate = Trim(frmInfPayin.Endday.value)+Trim(frmInfPayin.Endmnth.value)+Trim(frmInfPayin.Endyear.value);		
	var dd = 0;
	var mm = 0;
	var yy = 0;

	var e_dd = 0;
	var e_mm = 0;
	var e_yy = 0;
	
	if (begDate != endDate) {
		dd = parseInt(Trim(frmInfPayin.Begday.value),10);
		mm = parseInt(Trim(frmInfPayin.Begmnth.value),10)-1;
		yy = parseInt(Trim(frmInfPayin.Begyear.value))-543;
		var beg_date = new Date();
		beg_date.setFullYear(yy,mm,dd);

		e_dd = parseInt(Trim(frmInfPayin.Endday.value),10);
		e_mm = parseInt(Trim(frmInfPayin.Endmnth.value),10)-1;
		e_yy = parseInt(Trim(frmInfPayin.Endyear.value))-543;
		var end_date = new Date();
		end_date.setFullYear(e_yy,e_mm,e_dd);
		if (end_date < beg_date) {
			alert("วันที่สิ้นสุดต้องมากกว่าวันที่เริ่มต้น");
			frmInfPayin.Endday.focus();
			return;
		}
	}
	
	frmInfPayin.action="/LHServ/SERV_xinfList.jsp";
	frmInfPayin.submit();
}
function Print() {
	if (frmInfPayin.Company.value == "") {
		alert("กรุณาเลือกบริษัท !!");
		frmInfPayin.Company.focus();
		return;
	}
	var begDate = Trim(frmInfPayin.Begday.value)+"/"+Trim(frmInfPayin.Begmnth.value)+"/"+Trim(frmInfPayin.Begyear.value);
	var endDate = Trim(frmInfPayin.Endday.value)+"/"+Trim(frmInfPayin.Endmnth.value)+"/"+Trim(frmInfPayin.Endyear.value);
	if (!checkFormatDate(begDate)) {
		frmInfPayin.Begday.focus();
		return;
	}	  
	if (!checkFormatDate(endDate)) {
		frmInfPayin.Endday.focus();
		return;
	}	  	
	begDate = Trim(frmInfPayin.Begday.value)+Trim(frmInfPayin.Begmnth.value)+Trim(frmInfPayin.Begyear.value);	
	endDate = Trim(frmInfPayin.Endday.value)+Trim(frmInfPayin.Endmnth.value)+Trim(frmInfPayin.Endyear.value);		
	var dd = 0;
	var mm = 0;
	var yy = 0;

	var e_dd = 0;
	var e_mm = 0;
	var e_yy = 0;
	
	if (begDate != endDate) {
		dd = parseInt(Trim(frmInfPayin.Begday.value),10);
		mm = parseInt(Trim(frmInfPayin.Begmnth.value),10)-1;
		yy = parseInt(Trim(frmInfPayin.Begyear.value))-543;
		var beg_date = new Date();
		beg_date.setFullYear(yy,mm,dd);

		e_dd = parseInt(Trim(frmInfPayin.Endday.value),10);
		e_mm = parseInt(Trim(frmInfPayin.Endmnth.value),10)-1;
		e_yy = parseInt(Trim(frmInfPayin.Endyear.value))-543;
		var end_date = new Date();
		end_date.setFullYear(e_yy,e_mm,e_dd);
		if (end_date < beg_date) {
			alert("วันที่สิ้นสุดต้องมากกว่าวันที่เริ่มต้น");
			frmInfPayin.Endday.focus();
			return;
		}
	}
	
	frmInfPayin.action="http://www7.lh.co.th/LHServ/SERV_PrintPayinInfraServlet";
	frmInfPayin.target = "_blank";
	frmInfPayin.submit();
	frmInfPayin.target = "";
}
//-->
</script>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="pleasewait();">
<div id="hidepage" style="position: absolute; left:300px; top:50px; background-color: white; layer-background-color: white; height: 10%; width: 30%;">
<table width=100%><tr><td valign=middle align=middle><div id="a1">Page loading ... Please wait...</div></td></tr></table></div>
<FORM NAME="frmInfPayin" METHOD=POST ACTION="/LHServ/SERV_xinfList.jsp">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
		<td width="100%" class="BD">
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="50%" class="bigh"><img border="0"
					src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;รายงานการรับชำระเงินค่าบริการสาธารณะ</td>
				<td width="50%" align="right"></td>
			</tr>
		</table>
		<br style="font-size:10pt">
<%
String comId = doString.checkString(request.getParameter("Company"));
String ignoreCompany = "";

Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
String begDate = "";
String begPostDate = "";
String day = request.getParameter("Begday");
String mnth = request.getParameter("Begmnth");
String year = request.getParameter("Begyear");
if (year != null) {
	year = Integer.toString( Integer.parseInt(year) - 543 );
	begDate = day+"-"+mnth+"-"+year;
	begPostDate = year+"-"+mnth+"-"+day;
}

String endDate = ""; 
String endPostDate = "";
day = request.getParameter("Endday");
mnth = request.getParameter("Endmnth");
year = request.getParameter("Endyear");
if (year != null) {
	year = Integer.toString( Integer.parseInt(year) - 543 );
	endDate = day+"-"+mnth+"-"+year;
	endPostDate = year+"-"+mnth+"-"+day;
}

String sel_acc = doString.checkString(request.getParameter("selAccount"));
String bank = "";
String branch = "";
String account = "";
String acctNo = "";


DateUtil date_util = new DateUtil();
String code = "";
String selected = "";
StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
Statement stmt1 = null;
ResultSet rs = null;
ResultSet rs1 = null;
try {
	if (ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	stmt1 = conn.createStatement();
	
	if (begPostDate.equals("")) {
		rs = stmt.executeQuery("SELECT MAX(post_date) FROM lan:serv_misdt WHERE f_confirm IS NULL OR f_confirm != 'D'");
		if (rs != null) {
			if (rs.next() == true) {
				begPostDate = doString.checkString(rs.getString(1));
				endPostDate = begPostDate;
				year = begPostDate.substring(0, 4);
				mnth = begPostDate.substring(5, 7);
				day = begPostDate.substring(8);
				begDate = day+"-"+mnth+"-"+year;
				endDate = begDate;
			}
			rs.close();
			rs=null;
		}
	}
%>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
				<td class="item_tab2" width="100">รายละเอียด</td>
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
                  <td class="item ; dotline01" height="22" width="11%">บริษัท :</td>
                  <td height="22" class="dotline01" width="89%">
                    <select size="1" name="Company" class="box" style="width:250px" onchange="LookupAccount()">
                      <option value="">----- เลือกบริษัท -----</option>
<%
	rs = stmt.executeQuery("SELECT DISTINCT a.i_company, b.n_company FROM lan:acsbudgt a, lan:acxcompa b WHERE b.i_company = a.i_company AND d_year = '"+cur_year+"' ORDER BY a.i_company");
	if (rs != null) {
		while (rs.next() == true) {
			code = doString.checkString(rs.getString("I_COMPANY"));
			if (ignoreCompany.equals("")) {
				ignoreCompany += " WHERE ";
			} else {
				ignoreCompany += " AND ";
			}
			ignoreCompany += " i_company != '"+code+"' ";
			selected = "";
			if (code.equals(comId)) {
				selected = "selected";
			}			
%>
				<OPTION value="<%=code%>" <%=selected%>><%=code%> | <%=doString.checkString(doString.DisplayThai(rs.getString("N_COMPANY")))%></OPTION>
<%			
		}
		rs.close();
		rs=null;
	}
	rs = stmt.executeQuery("SELECT i_company, n_company FROM lan:acxcompa "+ignoreCompany+" ORDER BY i_company");
	if (rs != null) {
		while (rs.next() == true) {
			selected = "";
			code = doString.checkString(rs.getString("I_COMPANY"));
			if (code.equals(comId)) {
				selected = "selected";
			}			
%>
				<OPTION value="<%=code%>" <%=selected%>><%=code%> | <%=doString.checkString(doString.DisplayThai(rs.getString("N_COMPANY")))%></OPTION>
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
                  <td class="item ; dotline01" height="22" width="11%">เลขที่บัญชี :</td>
                  <td height="22" class="dotline01" width="89%">
                    <select size="1" name="selAccount" class="box" style="width:250px">
                      <option value="">----- ไม่ระบุ -----</option>
<%
	rs = stmt.executeQuery("SELECT a.i_bank, a.i_branch, a.i_account, a.i_acct_no, a.n_account FROM lan:acraccnt a, lan:payaccnt b WHERE a.i_company='"+comId+"' AND b.i_account = a.n_account ORDER BY a.i_bank, a.i_branch, a.i_account");
	if (rs != null) {
		while (rs.next() == true) {
			bank = doString.checkString(rs.getString("I_BANK"));
			branch = doString.checkString(rs.getString("I_BRANCH"));
			account = doString.checkString(rs.getString("I_ACCOUNT"));
			acctNo = doString.checkString(rs.getString("I_ACCT_NO"));
			code = bank+"|"+branch+"|"+acctNo;
			selected = "";
			if (code.equals(sel_acc)) {
				selected = "selected";
			}			
%>
				<OPTION value="<%=code%>" <%=selected%>><%=bank%><%=branch%><%=account%> | <%=doString.checkString(doString.DisplayThai(rs.getString("N_ACCOUNT")))%></OPTION>
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
                  <td class="item ; dotline01" height="22" width="11%">วันที่รับชำระตั้งแต่ :</td>
                  <td height="22" class="item ; dotline01" width="89%">
                  <%date_util.printHtmlThaiDateNoTime(out, "Beg", begDate, 5, 2, "white", "#0078FF");%>&nbsp;ถึงวันที่ :&nbsp;
                  <%date_util.printHtmlThaiDateNoTime(out, "End", endDate, 5, 2, "white", "#0078FF");%>&nbsp;&nbsp;
                  <a href="javascript:searchData();"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a>
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
		<br style="font-size: 10pt">
			<table border="0" width="100%" cellspacing="0" cellpadding="0">
				<TBODY>
					<tr>
						<td class="item_tab1"><img border="0" src="images/i_i.gif"
							align="absmiddle" width="20" height="20"></td>
            <td class="item_tab2" width="100">รายการแปลง</td>
						<td class="item_tab3"></td>
						<td>&nbsp;</td>
					</tr>
				</TBODY>
			</table>
			<table border="0" width="100%" cellspacing="0" cellpadding="0">
				<TBODY>
					<tr>
						<td width="5" valign="top" bgcolor="#D7E6FF"><img border="0"
							src="images/Corn01.gif" width="5" height="5"></td>
						<td valign="bottom" class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
						<td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img
							border="0" src="images/Corn02.gif" width="5" height="5"></td>
					</tr>
				</TBODY>
			</table>
			<table border="0" width="100%" cellspacing="0" cellpadding="0">
				<TBODY>
					<tr>
						<td width="100%" class="frmL" align="center">						
              <table border="0" width="100%" cellspacing="0" cellpadding="0">
                <tr> 
                  <td class="col_name" height="14" width="5%">โครงการ</td>
                  <td class="col_name" height="14" width="4%">แปลง</td>
                  <td class="col_name" height="14" width="6%">วันที่รับชำระ</td>
                  
                  <td class="col_name" height="14" width="13%">REF2 No.</td>
                  <td class="col_name" height="14" width="23%">ผู้จ่ายเงินค่าบริการ</td>
                  
                  <td class="col_name" height="14" width="9%">จำนวนเงิน<br>ที่ต้องชำระ</td>
                  <td class="col_name" height="14" width="9%">จำนวนเงิน<br>รับชำระ</td>
                  
                  <td class="col_name" height="14" width="8%">เลขที่เช็ค</td>
                  <td class="col_name" height="14" width="6%">สาขาที่<br>ชำระเงิน</td>
                  <td class="col_name" height="14" width="17%">ผู้รับเรื่อง</td>
                </tr>
<%
	int line = 0;
	String docNo = "";
	String refNo1 = "";
	int ref1_length = 0;
	String postDate = "";
	String dueId = "";
	String ref2No = "";
	int ref2_length = 0;
	String chequeNo = "";
	String projId = "";
	String lockId = "";
	String custName = "";
	String empName = "";
	double infAmnt = 0;
	double payAmnt = 0;
	double totInfAmnt = 0;
	double totPayAmnt = 0;
	String comment = "";
	if (!comId.equals("") && !begPostDate.equals("") && !endPostDate.equals("")) {
		StringTokenizer cutAcc = new StringTokenizer(sel_acc,"|");
		bank = "";
		branch = "";
		acctNo = "";
		if (cutAcc.countTokens() == 3) {
			bank = doString.checkString(cutAcc.nextToken());
			branch = doString.checkString(cutAcc.nextToken());
			acctNo = doString.checkString(cutAcc.nextToken());
		}
		sql.delete(0,sql.length());
		sql.append("SELECT * FROM lan:serv_misdt")
			.append(" WHERE i_company = '").append(comId).append("'")
			.append(" AND post_date >= '").append(begPostDate).append("'")
			.append(" AND post_date <= '").append(endPostDate).append("'")
			.append(" AND (f_confirm IS NULL OR f_confirm != 'D')");
		if (!acctNo.equals("")) {
			sql.append(" AND i_acct_no = '").append(acctNo).append("'");
		}
		sql.append(" ORDER BY i_company, i_project, i_sort, post_date");		
		rs = stmt.executeQuery(sql.toString());
		if (rs != null) {
			while (rs.next() == true) {
				postDate = DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString("POST_DATE")));
				year = postDate.substring(8);
				postDate = postDate.substring(0, 6)+year;				
				refNo1 = doString.checkString(doString.DisplayThai(rs.getString("REF1_NO"))); //lock+dueId
				ref1_length = 0;
				dueId = "";
				if (!refNo1.equals("")) {
					ref1_length = refNo1.length();
				}
				if (ref1_length >= 8) {
					dueId = refNo1.substring(refNo1.length()-3);
				} else {
					dueId = refNo1;
				}
				ref2No = doString.checkString(rs.getString("REF2_NO"));
				ref2_length = 0;
				if (!ref2No.equals("")) {
					ref2_length = ref2No.length();
				}
				chequeNo = doString.checkString(rs.getString("I_CHEQUE"));
				branch = doString.checkString(rs.getString("I_BRANCH"));
				projId = doString.checkString(rs.getString("I_PROJECT"));
				lockId = doString.checkString(rs.getString("I_SORT"));
				payAmnt = rs.getDouble("Z_AMOUNT");
				infAmnt = 0;
				custName = "";
				empName = "";
				comment = "";
				if (!dueId.equals("155")) { //182, Other
					line++;
					docNo = ref2No;
					if (ref2_length >= 13) {
						docNo = comId+projId+"-"+ref2No.substring(5,11);
						sql.delete(0,sql.length());
						sql.append("SELECT TRIM(b.n_prename_th) || TRIM(b.n_nemploy_th) || ' ' || TRIM(b.n_semploy_th), a.*")
							  .append(" FROM lan:serv_infhd a LEFT JOIN docflow:acemploy b ON b.i_employ = a.i_staff")
							  .append(" WHERE a.i_company = '").append(comId).append("'")
							  .append(" AND a.i_project = '").append(projId).append("'")
							  .append(" AND a.i_sort = '").append(lockId).append("'")
							  .append(" AND a.i_docno = '").append(docNo).append("'");
						rs1 = stmt1.executeQuery(sql.toString());
						if (rs1.next() == true) {
							empName = doString.checkString(doString.DisplayThai(rs1.getString(1)));
							custName = doString.checkString(doString.DisplayThai(rs1.getString("N_CUSTO")));
							infAmnt = rs1.getDouble("Z_INFRA");
						} else {
							comment = "ไม่พบข้อมูลแปลงขาย";
						}
						rs1.close();
						rs1=null;
						if (custName.equals("")) {
							if (comment.equals("")) {
								comment = "ไม่พบรายละเอียดลูกค้า";
							}
						}
						if (payAmnt != infAmnt) {
							if (comment.equals("")) {
								comment = "รายละเอียดการรับชำระไม่ตรงกัน";	
							}
						}
						ref2No = ref2No.substring(0,1) + "-" + ref2No.substring(1,2) + "-"+ref2No.substring(2,5) + "-" + ref2No.substring(5,11) + "-" + ref2No.substring(11,12) + "-" + ref2No.substring(12);
					}
					totInfAmnt += infAmnt;
					totPayAmnt += payAmnt;					
%>
                <tr> 
                  <td class="dotline" align="center" width="5%"><%=projId%></td>
                  <td class="dotline" align="center" width="4%"><%=lockId%></td>
                  <td class="dotline" align="center" width="6%"><%=postDate%></td>
                  
                  <td class="dotline" align="center" width="13%"><%=ref2No%></td>
                  <td class="dotline" align="left" width="23%"><%=custName%>&nbsp;</td>
                  
                  <td class="dotline" align="right" width="9%"><%=doString.displayNumber("###,###,###.00", infAmnt)%></td>
                  <td class="dotline" align="right" width="9%"><%=doString.displayNumber("###,###,###.00", payAmnt)%></td>
                  
                  <td class="dotline" align="center" width="8%"><%=chequeNo%>&nbsp;</td>
                  <td class="dotline" align="center" width="6%"><%=branch%>&nbsp;</td>
                  <td class="dotline" align="left" width="17%"><%=empName%>&nbsp;</td>
                </tr>
<%					
					if (!comment.equals("")) {
%>
                <tr> 
                  <td class="dotline" height="22" align="center" width="5%">&nbsp;</td>
                  <td class="dotline" align="left" height="22" colspan="9"><img border="0" src="images/bu_nextPage.gif" align="absmiddle" width="5" height="7">&nbsp;<font color="#FF6699">หมายเหตุ &nbsp;:&nbsp;<%=comment%></font></td>
                </tr>
<%						
					}
				}//182, Other
			}// end while
			rs.close();
			rs=null;
		}
	}
	if (line == 0) {
%>
                <tr> 
                  <td class="dotline" align="center" width="5%">&nbsp;</td>
                  <td class="dotline" align="left" width="4%">&nbsp;</td>
                  <td class="dotline" align="left" width="6%">&nbsp;</td>
                  
                  <td class="dotline" align="left" width="13%">&nbsp;</td>
                  <td class="dotline" align="left" width="23%">&nbsp;</td>
                  
                  <td class="dotline" align="left" width="9%">&nbsp;</td>
                  <td class="dotline" align="left" width="9%">&nbsp;</td>
                  
                  <td class="dotline" align="left" width="8%">&nbsp;</td>
                  <td class="dotline" align="left" width="6%">&nbsp;</td>
                  <td class="dotline" align="left" width="17%">&nbsp;</td>
                </tr>
<%		
	}
%>  
                <tr> 
                  <td class="item ; dotline" align="right" colspan="5">รวมจำนวนเงิน :</td>
                  <td class="item ; dotline" align="right" width="9%"><%=doString.displayNumber("###,###,###.00", totInfAmnt)%></td>
                  <td class="item ; dotline" align="right" width="9%"><%=doString.displayNumber("###,###,###.00", totPayAmnt)%></td>
                  <td class="dotline" align="left" width="8%">&nbsp;</td>
                  <td class="dotline" align="left" width="6%">&nbsp;</td>
                  <td class="dotline" align="left" width="17%">&nbsp;</td>
                </tr>
              </table>
						</td>
					</tr>
				</TBODY>
			</table>

			<table border="0" width="100%" cellspacing="0" cellpadding="0">
				<TBODY>
					<tr>
						<td width="5" valign="bottom"><img border="0"
							src="images/Corn03.gif" width="5" height="5"></td>
						<td class="frmBottom">&nbsp;</td>
						<td width="5" valign="bottom" align="right"><img border="0"
							src="images/Corn04.gif" width="5" height="5"></td>
					</tr>
				</TBODY>
			</table>
<%
		stmt.close();
		stmt1.close();
		conn.close();
		stmt = null;
		stmt1 = null;
		conn=null;
	} catch (Exception e) {
		System.out.println("ERROR SERV_xinfList.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (rs1 != null) rs1.close();
			if (stmt != null) stmt.close();
			if (stmt1 != null) stmt1.close();
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
				<td width="75" class="act_tab2">
				<a href="javascript:Print()"><img
					border="0" src="images/act_print.gif"
					onMouseOut=nereidFade(this,70,50,5)
					onMouseOver=nereidFade(this,100,50,5)
					style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
				</td>
				<td class="act_tab3"></td>
				<td class="act_tab4">
				<a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
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