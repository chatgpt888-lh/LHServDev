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
	String getStatus(String code)
	{
		String status = "";		
		if (code.equals("N")) {
			status = "เอกสารใหม่";
		} else if (code.equals("C")) {
			status = "ยกเลิก";
		} else if (code.equals("Y")) {
			status = "รอ Conf.PayIn";
		} else if (code.equals("P")) {
			status = "Conf.Payin แล้ว(รับเงินไม่ครบ)";
		} else if (code.equals("F")) {
			status = "รับเงินเรียบร้อย";
		} else if (code.equals("C")) {
		} else if (code.equals("E")) {
		} else if (code.equals("B")) {
		} else if (code.equals("D")) {
		}
		return (status);
	}	
%>
<%
String userId = user.getUserID();
String empId = user.getEmpId();

String project = doString.checkString(request.getParameter("Project"),"LH000");
String comId = project.substring(0,2);
String projId = project.substring(2);
String beg_lock = doString.checkString(request.getParameter("beg_lock"));
beg_lock = beg_lock.toUpperCase();
String end_lock = doString.checkString(request.getParameter("end_lock"));
end_lock = end_lock.toUpperCase();
String restrict = "";
if (!beg_lock.equals("")) {
	if (end_lock.equals("")) {
		restrict = "AND (i_sort = '"+beg_lock+"')";
	} else {
		restrict = "AND (i_sort >= '"+beg_lock+"' AND i_sort <= '"+end_lock+"')";
	}
}
String month = doString.checkString(request.getParameter("Month"));
String year = doString.checkString(request.getParameter("Year"));
String betweenDate = doString.checkString(request.getParameter("between"));
int showRowCount = 0;
if (request.getParameter("show") != null) {
	showRowCount = Integer.parseInt(request.getParameter("show"));
}
String params = "Project="+project+"&beg_lock="+beg_lock+"&end_lock="+end_lock+"&between="+betweenDate;
int prevPage = 0;
int nextPage = 0;
int selPage = 1;
if (request.getParameter("selPage") != null) {
	selPage = Integer.parseInt(request.getParameter("selPage"));
}
prevPage = selPage - 1;
nextPage = selPage + 1;

String startDate = "";
String endDate = "";
String sortId = "";
int lorNo = 0;
int i=0;
String docNo = "";
String custType = "";
String status = "";
%>

<HTML>
<HEAD>
<TITLE>Print ใบแจ้งการชำระเงินค่าบริการสาธารณะ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<base target="_self">
<script language="JavaScript">
<!--
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
function chckAll(frm){
	var i = 0;
	var numDoc = eval(frm.NumDoc.value);
	if ( numDoc == 1)
	{
		frm.chkDoc.checked = frm.selAll.checked;
	} else {
		while( i < numDoc)
		{
			frm.chkDoc[i].checked = frm.selAll.checked;
			i++;
		}
	}
}	
function printPayIn(frm) {
	
	if (frm.Project.value == "LH000") {
		alert("โปรดเลือกโครงการ");
		frm.Project.focus();
		return;
	}
	if (frm.between.value == "") {
		alert("โปรดเลือกช่วงเวลา");
		frm.between.focus();
		return;
	}
	frm.target = "_blank";
	frm.action = "/LHServ/SERV_PrintInfPayInCBServlet";
	frm.submit();
}

function Go(frm) {
	frm.target = "_self";
	frm.action = "/LHServ/SERV_InfPayin.jsp";
	frm.submit();
}

function viewexcel(a,b,c,d) {
	window.open('/LHServ/PrintPayinExcelServlet?comId=<%=comId%>&projId=<%=projId%>&month=<%=month%>&year=<%=year%>&betweenDate=<%=betweenDate%>&startDate='+a+'&endDate='+b+'&beg_lock='+c+'&end_lock='+d);
} 
//-->
</script>	
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="pleasewait();">
<div id="hidepage" style="position: absolute; left:300px; top:100px; background-color: white; layer-background-color: white; height: 10%; width: 30%;">
<table width=100%><tr><td valign=middle align=middle><div id="a1">Page loading ... Please wait...</div></td></tr></table></div>
<FORM name="frmPrntPayIn" method="post" action="SERV_InfPayin.jsp">
<INPUT type="hidden" name="empId" value="<%=empId%>">
<INPUT type="hidden" name="userId" value="<%=userId%>">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;พิมพ์ใบแจ้งการชำระเงินค่าบริการสาธารณะ</td>
          <td width="30%" align="right">&nbsp;</td>
        </tr>
      </table>


<br style="font-size:10pt">
<%
double amount = 0;
String custId = "";
String custName = "";
Calendar rightNow = Calendar.getInstance();
String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
SimpleDateFormat th_formatter = new SimpleDateFormat("MMMM/yyyy", new Locale("th","TH"));
SimpleDateFormat en_formatter = new SimpleDateFormat("yyyy-MM-dd", new Locale("en","US"));
java.util.Date today = new java.util.Date();
DateUtil date_util = new DateUtil();
String optionSelected = "";
String code = "";
int rowCount = 0;
int lineNumber = 0;
int numberOfSorts = 0;
String targetPage = "";
StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
Statement cstmt = null;
ResultSet rs = null;
ResultSet rsCust = null;
try {
	if (ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	cstmt = conn.createStatement();

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
                    <select size="1" name="Project" class="box" style="width:250px" onChange="frmPrntPayIn.between.value='';frmPrntPayIn.submit();">
                      <option value="LH000">----- เลือกโครงการ -----</option>
<%
	sql.delete(0, sql.length());
	sql.append("SELECT * FROM lan:serv_pstaff WHERE user_id = '"+userId+"' AND com_id = 'LH' AND proj_id = 'ALL'");
	rs = stmt.executeQuery(sql.toString());
	
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
              <OPTION value="<%=code%>" <%=optionSelected%>><%=code%> | <%=doString.checkString(doString.DisplayThai(rs.getString("N_PROJECT")))%></OPTION>
<%
		}// end while
		rs.close();
		rs=null;
	}
%>                                          
                    </select>
                  </td>
                  <td height="22" width="7%" class="item ; dotline01">ค้นหาแปลง 
                    :</td>
                  <td height="22" width="53%" class="dotline01"> 
                    <INPUT type="text" name="beg_lock" class="box" value="<%=beg_lock%>" style="width:60px">&nbsp; ถึง&nbsp;
					<INPUT type="text" name="end_lock" class="box" value="<%=end_lock%>" style="width:60px">&nbsp; &nbsp; 
                  </td>
                </tr>
                <tr> 
                  <td height="22" class="item ; dotline01" width="9%">ประเภท 
                    : </td>
                  <td height="22" width="31%" class="dotline01"> 
                    <select size="1" name="Month" class="box" style="width:150px" onChange="frmPrntPayIn.between.value='';frmPrntPayIn.submit();">
                      <option value="">----- เลือกประเภทเดือน -----</option>                    
<%
	sql.delete(0, sql.length());
	sql.append("SELECT i_code, n_desc FROM lan:serv_xstd WHERE i_type = '62' ORDER BY i_code");
	rs = stmt.executeQuery(sql.toString());
	if (rs != null) {
		while (rs.next() == true) {
			optionSelected = "";
			code = doString.checkString(rs.getString("I_CODE"));
			if (month.equals(code)) {
				optionSelected = "selected";
			}
%>
                      <option value="<%=code%>" <%=optionSelected%>><%=doString.checkString(doString.DisplayThai(rs.getString("N_DESC")))%></option>
<%		
		}// end while
		rs.close();
		rs=null;
	}
%>                      
                    </select>&nbsp; ปี&nbsp;
                    <select size="1" name="Year" class="box" style="width:80px" onChange="frmPrntPayIn.between.value='';frmPrntPayIn.submit();">
                      <option value="">----- เลือกปี -----</option>                    
<%
	sql.delete(0, sql.length());
	sql.append("SELECT DISTINCT i_year FROM lan:serv_infrate WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' ORDER BY i_year");
	rs = stmt.executeQuery(sql.toString());
	if (rs != null) {
		while (rs.next() == true) {
			optionSelected = "";
			code = doString.checkString(rs.getString("I_YEAR"));
			if (year.equals(code)) {
				optionSelected = "selected";
			}
%>
                      <option value="<%=code%>" <%=optionSelected%>><%=code%></option>
<%		
		}// end while
		rs.close();
		rs=null;
	}
%> 
					</select>

                  </td>
                  <td height="22" width="7%" class="item ; dotline01">ช่วงเดือน :</td>
                  <td height="22" width="53%" class="dotline01">
                    <select size="1" name="between" class="box" style="width:250px" onChange="frmPrntPayIn.submit()">
                      <option value="">----- เลือกช่วงเดือน -----</option>                    
<%
	sql.delete(0, sql.length());
	sql.append("SELECT d_start, d_end FROM lan:serv_infrate WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_month = '"+month+"' AND i_year = '"+year+"' ORDER BY d_start");
	rs = stmt.executeQuery(sql.toString());
	if (rs != null) {
		while (rs.next() == true) {
			optionSelected = "";
			startDate = doString.checkString(doString.DisplayThai(rs.getString("D_START")));
			endDate = doString.checkString(doString.DisplayThai(rs.getString("D_END")));
			java.util.Date frmDate = en_formatter.parse(startDate);
			java.util.Date toDate = en_formatter.parse(endDate);
			code = startDate+"/"+endDate;
			if (betweenDate.equals(code)) {
				optionSelected = "selected";
			}
%>
						<option value="<%=code%>" <%=optionSelected%>><%=Period.getBetween(startDate, endDate)%></option>
<%		
		}// end while
		rs.close();
		rs=null;
	}
%>                      
                    </select>
                    <A HREF="javascript:Go(frmPrntPayIn)"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a> 
                  </td>
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
	<td class="item_tab2" width="250">เอกสารค่าบริการสาธารณะ</td>
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
                  <td class="col_name" width="11%">เลขที่เอกสาร</td>                
                  <td class="col_name" width="6%">แปลง</td>
				  <td class="col_name" width="7%">บ้านเลขที่</td>
                  <td class="col_name" width="11%">วันที่แจ้ง</td>
                  <td class="col_name" width="30%">ผู้ชำระค่าสาธารณะ</td>
                  <td class="col_name" width="11%">จำนวนเงิน</td>
                  <td class="col_name" width="24%">สถานะ</td>
                </tr>
<%
	if (!betweenDate.equals("")) {
		i = betweenDate.indexOf("/");
		startDate = betweenDate.substring(0,i);
		endDate = betweenDate.substring(i+1);
		numberOfSorts = 0;
		sql.delete(0, sql.length());
		sql.append("SELECT COUNT(*) AS NUM_LOCK FROM lan:serv_infhd WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' "+restrict+" AND d_start = '"+startDate+"' AND d_end = '"+endDate+"' AND i_doc_status != 'F'");
		rs = stmt.executeQuery(sql.toString());
		if (rs != null) {
			if (rs.next() == true) {
				numberOfSorts = rs.getInt("NUM_LOCK");
			}// end 
			rs.close();
			rs=null;
		}
		i=0;
		rowCount=0;
		sql.delete(0, sql.length());
		sql.append("SELECT i_docno, i_sort, i_lor, i_house, d_keyin, i_inf_custo, i_infra, NVL(z_infra,0) AS INF_AMT, i_doc_status FROM lan:serv_infhd WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' "+restrict+" AND d_start = '"+startDate+"' AND d_end = '"+endDate+"' AND i_doc_status != 'F' ORDER BY i_sort");
		rs = stmt.executeQuery(sql.toString());
		if (rs != null) {
			while (rs.next() == true) {
				lineNumber = (1 - showRowCount) + i;
				i++;
                if (lineNumber >= 1) {
	                if (lineNumber <= MAX_LINE) {
    	                rowCount++;
    	                docNo = doString.checkString(rs.getString("I_DOCNO"));
						sortId = doString.checkString(rs.getString("I_SORT"));
						amount = rs.getDouble("INF_AMT");
						status = doString.checkString(rs.getString("I_DOC_STATUS"));
						custType = doString.checkString(rs.getString("I_INF_CUSTO"));
						custId = doString.checkString(rs.getString("I_INFRA"));
    	                custName = "";
						if (custType.equals("1")) {
							sql.delete(0, sql.length());
							sql.append("SELECT n_prename, n_ncustomer, n_scustomer FROM lan:acxcusto WHERE i_customer = "+custId);
							rsCust = cstmt.executeQuery(sql.toString());
							if (rsCust != null) {
								if (rsCust.next() == true) {
									custName = doString.checkString(rsCust.getString("N_PRENAME"))+" "+doString.checkString(rsCust.getString("N_NCUSTOMER"))+ " "+doString.checkString(rsCust.getString("N_SCUSTOMER"));;
								}
								rsCust.close();
								rsCust=null;
							}					
						
						} else {
							sql.delete(0, sql.length());
							sql.append("SELECT n_pname, n_name, n_sname FROM lan:serv_venprj WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_type = '07' AND i_vendor = '"+custId+"'");
							rsCust = cstmt.executeQuery(sql.toString());
							if (rsCust != null) {
								if (rsCust.next() == true) {
									custName = doString.checkString(rsCust.getString("N_PNAME"))+" "+doString.checkString(rsCust.getString("N_NAME"))+" "+doString.checkString(rsCust.getString("N_SNAME"));
								}
								rsCust.close();
								rsCust=null;
							}
						}
%>
                <tr> 
                  <td class="item ; dotline" align="center" width="11%"><%=docNo%></td>
                  <td class="dotline" align="center" width="6%"><%=sortId%></td>
				  <td class="dotline" align="center" width="7%"><%=doString.checkString(rs.getString("I_HOUSE"),"&nbsp;")%></td>
                  <td class="dotline" align="center" width="11%"><%=DateUtil.ifxToThaiDateNoTime(doString.DisplayThai(rs.getString("D_KEYIN")))%></td>
                  <td class="dotline" width="30%"><%=doString.DisplayThai(custName)%></td>
                  <td class="dotline" align="right" width="11%"><%=doString.displayNumber("###,###,###.00", amount)%></td>
                  <td class="dotline" align="center" width="24%"><%=getStatus(status)%></td>
                </tr>
<%    	                
                    } else {
   	                    break;
       	            }
       	        } 
            }// end while
            rs.close();
            rs=null;
		}           
	}
	if (numberOfSorts == 0) {
%>
                <tr> 
                  <td class="dotline" align="center" width="11%">&nbsp;</td>                
                  <td class="dotline" align="center" width="6%">&nbsp;</td>
				  <td class="dotline" align="center" width="7%">&nbsp;</td>
                  <td class="dotline" align="center" width="11%">&nbsp;</td>
                  <td class="dotline" width="30%">&nbsp;</td>
                  <td class="dotline" align="right" width="11%">&nbsp;</td>
                  <td class="dotline" align="center" width="24%">&nbsp;</td>
                </tr>

<%	
	}
%>                             
              </table>
              <INPUT type="hidden" name="NumDoc" value="<%=rowCount%>">
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

      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
        <TBODY>
          <TR>
            <TD width="4%" class="item" height="22">หน้าที่ :</TD>
            <TD width="96%" height="22">
<%
			//PAGE LIST
			int show = 0;
			int TotSort = numberOfSorts;
			int pages = 0;
			while (true)
			{
				TotSort -= MAX_LINE;
				pages++;
%>
			<A href='SERV_InfPayin.jsp?<%=params%>&show=<%=show%>&selPage=<%=pages%>'><%if (selPage == pages) {%><b><%}%><%=pages%></b></A>&nbsp;&nbsp;
<%
				show += MAX_LINE;
				if (TotSort <= 0)
				{
					break;
				}
			}
%>

			</TD>
          </TR>
        </TBODY>
      </TABLE>
<%
	stmt.close();
	cstmt.close();	
	conn.close();
	stmt=null;
	cstmt=null;
	conn=null;
} catch (Exception e) {
	System.out.println("ERROR SERV_InfPayin.jsp : " + e.getMessage());
	throw new ServletException(e.getMessage());
} finally {
	// Clean up.
	try {
		if (rs != null) rs.close();
		if (rsCust != null) rsCust.close();
		if (stmt != null) stmt.close();
		if (cstmt != null) cstmt.close();
		if (conn != null) conn.close();
	}
	catch( SQLException ignore ){}
}
%>
<table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
  <tr>
    <td class="act_tab1"></td>
            <td width="250" class="act_tab2">
            <A href="javascript:printPayIn(frmPrntPayIn)"><IMG border="0" src="images/act_printpayin1.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27"></A>&nbsp;
             &nbsp;<A href="javascript:viewexcel('<%=startDate%>','<%=endDate%>','<%=beg_lock%>','<%=end_lock%>')"><IMG border="0" src="images/act_viewexcel.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27"></A>&nbsp;</td>
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