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
<%@ page import="serv.util.*" %>
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
String jName = "SERV_Add_Infra.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

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
String params = "Project="+project+"&beg_lock="+beg_lock+"&end_lock="+end_lock+"&Month="+month+"&Year="+year+"&between="+betweenDate;
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
String seperate = "";
int lorNo = 0;
int i=0;
int f=0;
boolean match = true;
String custType = "";
String infAmnt = "";
int fraction = 0;
%>
<HTML>
<HEAD>
<TITLE>บันทึกค่าบริการสาธารณะ</TITLE>
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
	
function cust_window(frm, sortId) {
	var type = "";
	chkCust = eval("frm.T"+sortId+"[0].checked");
	if (chkCust) {
		eval("frm.C"+sortId+".focus()");
	} else {
		type = "07";
		var vWinCal = window.open('SERV_CustInfra.jsp?comId=<%=comId%>&projId=<%=projId%>&sortId='+sortId+'&type='+type,'blank','width=680,height=250,left=200,top=100');
		vWinCal.opener = self;
		ggWinCal = vWinCal;
	}
}

function SaveAndClose(frm) {
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
	tot_sort = parseInt(frm.tot_sort.value);
	if (tot_sort == 0) {
		alert("ไม่พบข้อมูลแปลงขาย");
		return;	
	}
	document.getElementById ('hidepage').style.visibility = 'visible';
	frm.action = "/LHServ/SetInfAmntServlet";
	frm.submit();
}

//-->
</script>	
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="pleasewait();">
<div id="hidepage" style="position: absolute; left:300px; top:300px; background-color: white; layer-background-color: white; height: 10%; width: 30%;">
<table width=100%><tr><td valign=middle align=middle><div id="a1">Page loading ... Please wait...</div></td></tr></table></div>

<FORM name="frmAddInfra" method="post" action="SERV_Add_Infra.jsp">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;การบันทึกค่าบริการสาธารณะ</td>
          <td width="30%" align="right">&nbsp;</td>
        </tr>
      </table>


<br style="font-size:10pt">
<%
String extra = "";
int mnth = 0;
double price = 0;
double area = 0;
double amount = 0;
String custName = "";
String venName = "";
int intentNo = 0;
int custNo1 = 0;
int custNo2 = 0;
Calendar rightNow = Calendar.getInstance();
String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
//String cur_year = Integer.toString(rightNow.get(Calendar.YEAR));
SimpleDateFormat th_formatter = new SimpleDateFormat("MMMM/yyyy", new Locale("th","TH"));
SimpleDateFormat en_formatter = new SimpleDateFormat("yyyy-MM-dd", new Locale("en","US"));
java.util.Date today = new java.util.Date();
DateUtil date_util = new DateUtil();
String optionSelected = "";
String code = "";
int rowCount = 0;
int lineNumber = 0;
int numberOfSorts = 0;

StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
Statement cstmt = null;
ResultSet rs = null;
ResultSet rsContr = null;
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

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR" align="center">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
                  <td height="22" class="item ; dotline01" width="8%">โครงการ 
                    : </td>
                  <td height="22" width="31%" class="dotline01"> 
                    <select size="1" name="Project" class="box" style="width:250px" onChange="frmAddInfra.between.value='';frmAddInfra.submit();">
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
                    </select>
                  </td>              
                  <td height="22" width="8%" class="item ; dotline01">แปลง :</td>
                  <td height="22" width="53%" class="item ; dotline01"> 
                    <INPUT type="text" name="beg_lock" class="box" value="<%=beg_lock%>" style="width:60px">&nbsp; ถึง&nbsp;
					<INPUT type="text" name="end_lock" class="box" value="<%=end_lock%>" style="width:60px">
                  </td>
  </tr>

  <tr>
                  <td height="22" class="item ; dotline01" width="8%">ประเภท 
                    :</td>
                  <td height="22" width="31%" class="item ; dotline01"> 
                    <select size="1" name="Month" class="box" style="width:150px" onChange="frmAddInfra.between.value='';frmAddInfra.submit();">
                      <option value="">----- เลือกประเภทเดือน -----</option>                    
<%
	sql.delete(0, sql.length());
	sql.append("SELECT i_code, n_desc FROM lan:serv_xstd WHERE i_type = '62' ORDER BY i_code");

	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();

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
                    <select size="1" name="Year" class="box" style="width:80px" onChange="frmAddInfra.between.value='';frmAddInfra.submit();">
                      <option value="">----- เลือกปี -----</option>                    
<%
	sql.delete(0, sql.length());
	sql.append("SELECT DISTINCT i_year FROM lan:serv_infrate WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' ORDER BY i_year");

	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();

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
                  <td height="22" width="8%" class="item ; dotline01">
				  ช่วงเดือน :
                  </td>
                  <td height="22" width="53%" class="item ; dotline01">
                    <select size="1" name="between" class="box" style="width:250px" onChange="frmAddInfra.submit()">
                      <option value="">----- เลือกช่วงเดือน -----</option>
                    
<%
	sql.delete(0, sql.length());
	sql.append("SELECT d_start, d_end FROM lan:serv_infrate WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_month = '"+month+"' AND i_year = '"+year+"' ORDER BY d_start");

	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();

	if (rs != null) {
		while (rs.next() == true) {
			optionSelected = "";
			startDate = doString.checkString(doString.DisplayThai(rs.getString("D_START")));
			endDate = doString.checkString(doString.DisplayThai(rs.getString("D_END")));
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
                  <A HREF="javascript:frmAddInfra.submit()">
                  <img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22">
                  </A>
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
	<td class="item_tab2" width="250">รายการแปลง</td>
	<td class="item_tab3"></td>
	<td>&nbsp;</td>
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
                  <td class="col_name" width="7%">แปลง</td>
                  <td class="col_name" width="44%">ผู้จ่ายค่าสาธารณะ</td>
                  <td class="col_name" width="13%">จำนวนเงิน</td>
                </tr>
<%
	if (!betweenDate.equals("")) {
		i = betweenDate.indexOf("/");
		startDate = betweenDate.substring(0,i);
		endDate = betweenDate.substring(i+1);

		sql.delete(0, sql.length());
		sql.append("SELECT f_extra, z_price, d_start, d_end FROM lan:serv_infrate WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND d_start = '"+startDate+"' AND d_end = '"+endDate+"'");

		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();

		if (rs != null) {
			if (rs.next() == true) {
				extra = doString.checkString(rs.getString("F_EXTRA"));
				price = rs.getDouble("Z_PRICE");
				mnth = Period.getMonth(rs.getTimestamp("D_START"), rs.getTimestamp("D_END"));
			}
			rs.close();
			rs=null;
		}
		numberOfSorts = 0;

		sql.delete(0, sql.length());
		sql.append("SELECT i_sort, i_lor FROM lan:serv_inflck WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' "+restrict+" AND d_end < '"+startDate+"' ORDER BY i_sort");
		rsContr = cstmt.executeQuery(sql.toString());
		if (rsContr != null) {
			while (rsContr.next() == true) {
				sortId = doString.checkString(rsContr.getString("I_SORT"));
				lorNo = rsContr.getInt("I_LOR");
				match = false;
				rs = stmt.executeQuery("SELECT i_lor FROM lan:serv_infhd WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_sort = '"+sortId+"' AND i_lor = "+Integer.toString(lorNo)+" AND d_start = '"+startDate+"' AND d_end = '"+endDate+"'");
				if (rs != null) {
					if (rs.next() == true) {
						match = true;
					}
					rs.close();
					rs=null;
				}
				if (!match) {
					numberOfSorts++;
				}			
			}// end while
			rsContr.close();
			rsContr=null;
		}
		
		i=0;
		lineNumber=0;

		sql.delete(0, sql.length());
		sql.append("SELECT i_sort, i_lor, NVL(q_area,0) AS AREA, n_customer, f_separate FROM lan:serv_inflck WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' "+restrict+" AND d_end < '"+startDate+"' ORDER BY i_sort");

		servlog.startLog(sql.toString());
		rsContr = cstmt.executeQuery(sql.toString());
		servlog.endLog();
		
		if (rsContr != null) {
			while (rsContr.next() == true) {
				sortId = doString.checkString(rsContr.getString("I_SORT"));
				seperate = doString.checkString(rsContr.getString("F_SEPARATE"));
				lorNo = rsContr.getInt("I_LOR");
				intentNo = 0;
				custNo1 = 0;
				custNo2 = 0;
				sql.delete(0, sql.length());
				sql.append("SELECT NVL(i_cus_intent1,0) AS CUS_INTENT1, NVL(i_exp_intent1,0) EXP_INTENT1, NVL(i_cus_intent2,0) AS CUS_INTENT2, NVL(i_exp_intent2,0) EXP_INTENT2 FROM lan:acscontr WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lor = "+Integer.toString(lorNo)+" AND d_close_law IS NOT NULL AND f_contr IS NULL");

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
				custType = "1";
				
				match = false;
				rs = stmt.executeQuery("SELECT i_lor FROM lan:serv_infhd WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_sort = '"+sortId+"' AND i_lor = "+Integer.toString(lorNo)+" AND d_start = '"+startDate+"' AND d_end = '"+endDate+"'");
				if (rs != null) {
					if (rs.next() == true) {
						match = true;
					}
					rs.close();
					rs=null;
				}
				if (!match) {				
					custName = "";

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
					
					area = 0;
					sql.delete(0, sql.length());
					sql.append("SELECT SUM(q_area) AS AREA FROM lan:acxslock WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lor = "+Integer.toString(lorNo));
					rs = stmt.executeQuery(sql.toString());
					if (rs != null) {
						if (rs.next() == true) {
							area = rs.getDouble("AREA");
						}
						rs.close();
						rs=null;
					}
					
					if (seperate.equals("Y")) {
						area = rsContr.getDouble("AREA");
						custName = doString.checkString(doString.DisplayThai(rsContr.getString("N_CUSTOMER")));
						if (!custName.equals("")) {
							f = custName.indexOf("(");
							if (f > 0) {
								custName = custName.substring(0, f);
							}
						}
					}
					
					amount = price*mnth;
					if (extra.equals("N")) {
						amount = amount * area;
					}
					infAmnt = doString.displayNumber("#########.00", amount);
					if (amount > 0) {
						f = infAmnt.indexOf(".");
						fraction = Integer.parseInt(infAmnt.substring(f+1));
						infAmnt = infAmnt.substring(0, f);
						amount = Double.parseDouble(infAmnt);
						if (fraction >= 50) {
							amount++;
						}
					}

					lineNumber = (1 - showRowCount) + i;
					i++;
	                if (lineNumber >= 1) {
    	                if (lineNumber <= MAX_LINE) {
        	                rowCount++;
%>
                <tr> 
                  <td class="dotline" align="center" width="7%"><%=sortId%></td>
                  <td class="dotline" align="left" width="44%"><%=custName%></td>
                  <td class="dotline" align="right" width="13%"><%=doString.displayNumber("###,###,###.00", amount)%></td>
                </tr>
<%        	                
	                    } else {
    	                    break;
        	            }
        	        }
				}
			}// end while
			rsContr.close();
			rsContr=null;
		}
	}
	if (numberOfSorts == 0) {
%>
                <tr> 
                  <td class="dotline" align="center" width="7%">&nbsp;</td>
                  <td class="dotline" align="left" width="44%">&nbsp;</td>
                  <td class="dotline" align="right" width="13%">&nbsp;</td>
                </tr>
<%	
	}
%>                
              </table>
              <INPUT type="hidden" name="tot_sort" value="<%=numberOfSorts%>">
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
			<A href='SERV_Add_Infra.jsp?<%=params%>&show=<%=show%>&selPage=<%=pages%>'><%if (selPage == pages) {%><b><%}%><%=pages%></b></A>&nbsp;&nbsp;
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
	System.out.println("ERROR SERV_Add_Infra.jsp : " + sql.toString());
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
<br style="font-size:5pt">
<table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
  <tr>
    <td class="act_tab1"></td>
            <td width="250" class="act_tab2"> <A href="javascript:SaveAndClose(frmAddInfra)"><IMG border="0" src="images/act_saveandclose.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27"></A>&nbsp; 
              &nbsp; &nbsp; </td>
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