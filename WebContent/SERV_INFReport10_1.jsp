<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>

<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%!

public Integer[] newIntegerArray(int size) {
	Integer data[] = new Integer[size];
	for (int l=0;l<size;l++) {
		  data[l] = new Integer(0);
	}

	return data;
}
%>

<%
   doString str = new doString();
   DecimalFormat  format1 = new DecimalFormat("#,###,##0");
	//---------------------- Variable --------------------
	String sessionId = user.getsessionId();
	String userId = user.getUserID();
    String monthReport = doString.checkString(request.getParameter("month_report"),"0");
    String yearReport = doString.checkString(request.getParameter("year_report"),"0");
    String reportType = doString.checkString(request.getParameter("report_type"),"0");
    String dispType = doString.checkString(request.getParameter("display_type"),"I");
	String disp_field = "";
	if (dispType.equals("I")) {
		disp_field = "COUNT(*)";
	} else if (dispType.equals("D")) {
		disp_field = "COUNT(distinct p.i_docno)";
	} else if (dispType.equals("A")) {
		disp_field = "SUM(p.z_amount_pv)";
	}
	String mainboq = "";
	Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
	String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
	//------------------------------------------------------
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	SERV_CommonData common = null;
	try {
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();
		stmt1 = conn.createStatement();
		common = new SERV_CommonData(conn);
		stmt.executeUpdate("DELETE FROM lan:serv_selproj WHERE i_session = "+sessionId);

		//---=========== Month Initilize =========----//
		String thaiMonth[] = new String[] {"","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
		String shortMonth[] = new String[] {"","ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค."};
		String showMonth = thaiMonth[Integer.parseInt(monthReport)];
		String showYear = Integer.toString(Integer.parseInt(yearReport)+543);
		String startQueryDate = "";
		String endQueryDate = "";

		double[] qtys = new double[12];
		double[] tot_qtys = new double[12];
		String[] months = new String[12];
		Integer monthList[] = newIntegerArray(12);
		Integer yearList[] = newIntegerArray(12);
		Calendar now = Calendar.getInstance(Locale.ENGLISH);
		now.set(Integer.parseInt(yearReport),Integer.parseInt(monthReport)-1,1,0,0,0);
		java.util.Calendar currentCal = java.util.Calendar.getInstance();  
		for (int i=0;i<Integer.parseInt(reportType);i++) {
			  int month = now.get(Calendar.MONTH)+1;
			  int year = now.get(Calendar.YEAR);
			  int daysInMonth = 0;
			  if (year>2400) year -= 543;
			  	
			  if (i==0)	 {
				 endQueryDate = str.createID(year,4)+"-"+str.createID(month,2)+"-01";
				currentCal = new  GregorianCalendar(year, month-1, 1);
				daysInMonth = currentCal.getActualMaximum(currentCal.DAY_OF_MONTH);
				endQueryDate = str.createID(year,4)+"-"+str.createID(month,2)+"-"+str.createID(daysInMonth,2);
			  } 
			 startQueryDate = str.createID(year,4)+"-"+str.createID(month,2)+"-01";
			  now.add(Calendar.MONTH,-1);
			  monthList[i] = new Integer(month);
			  yearList[i] = new Integer(year+543);
			months[i]=str.createID(year,4)+"-"+str.createID(month,2);
		} // end for

%>

<HTML>
<HEAD>
<TITLE>สรุปงานซ่อมแยกหมวดตามวันที่จ่าย</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<base target="_self">

<script language="javascript">
<!--

  function Go() {
     document.frmRep.action="<%=Constants.APP_PATH%>/SERV_INFReport10_1.jsp";
	 progress();  
     document.frmRep.submit();
  }

  function dispSub(group) {
	document.frmRep.itm_group.value = group;
     document.frmRep.action="<%=Constants.APP_PATH%>/SERV_INFReport10_2.jsp";
	 progress();  
     document.frmRep.submit();
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
//-->
</script>
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="pleasewait();">
<div id="hidepage" style="position: absolute; left:300px; top:50px; background-color: white; layer-background-color: white; height: 10%; width: 30%;">
<table width=100%><tr><td valign=middle align=middle><div id="a1">Page loading ... Please wait...</div></td></tr></table></div>

<FORM NAME = "frmRep" ACTION="SERV_INFReport10_1.jsp" METHOD="POST">
<input type="hidden" name="month_report" value="<%=monthReport%>">
<input type="hidden" name="year_report" value="<%=yearReport%>">
<input type="hidden" name="report_type" value="<%=reportType%>">
<input type="hidden" name="itm_group" value="">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp; 
            สรุปงานซ่อมแยกหมวดตามเดือนที่จ่าย</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                
          <td class="item_tab2" width="200">รายละเอียดเดือน/ปีที่ระบุ</td>
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
    <td class="item ; dotline01" height="22">
	เดือน : <%=showMonth%> &nbsp; พ.ศ. <%=showYear%> &nbsp; &nbsp; , ประเภท : <%=reportType%> เดือน</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22">โครงการ :&nbsp;
<%
	  String[] projList = request.getParameterValues("sel_proj");
	  String proj = "", i_com = "", i_proj = "";
	  int line = 0;
	  if (projList!=null) {
		  for (int i=0;i<projList.length;i++) {		
				 proj = doString.checkString(projList[i],"");  		
				i_com = proj.substring(0,2);
				 i_proj = proj.substring(3,6);
				 if (!i_proj.equals("ALL")) {
					stmt.executeUpdate("INSERT INTO lan:serv_selproj(i_session,i_company,i_project) VALUES("+sessionId+", '"+i_com+"', '"+i_proj+"')");
				 }
				//---============= get Project Details ===============----//
				sql.delete(0,sql.length()); 
				sql.append(" select * from lan:acxprojt ")
					  .append(" where i_company='").append(i_com).append("' ")
					  .append(" and i_project='").append(i_proj).append("' ");
				rs = stmt.executeQuery(sql.toString());
				if (rs.next()) {
							 String nProject = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");							 
							 String iProj = str.replace(proj,":","-");			
%>
							<input type="hidden" name="sel_proj" value="<%=proj%>">
							<%=iProj%> <%=nProject%>,
<%							 
				} // end while
				rs.close();
				rs=null;
		  } // end for
	  }
	  if (i_proj.equals("ALL")) {
			sql.delete(0,sql.length()); 
			sql.append("SELECT DISTINCT proj.i_company, proj.i_project, proj.n_project FROM lan:acxprojt proj, lan:acsbudgh bud");
			rs = stmt.executeQuery("SELECT proj_id FROM lan:serv_pstaff WHERE user_id = '"+userId+"' AND proj_id = 'ALL'");
			if (rs.next() == false) {
				sql.append(", lan:serv_pstaff staff WHERE proj.i_company = staff.com_id AND proj.i_project = staff.proj_id AND staff.user_id = '")
					.append(userId + "' AND");
			} else {
				sql.append(" WHERE");
			}
			rs.close();
			sql.append(" bud.i_company = proj.i_company AND bud.i_project = proj.i_project AND bud.d_year = '" + cur_year + "'");
			rs = stmt.executeQuery(sql.toString());
			while (rs.next() == true) {
				i_com = doString.checkString(rs.getString("I_COMPANY"));
				i_proj = doString.checkString(rs.getString("I_PROJECT"));
				stmt1.executeUpdate("INSERT INTO lan:serv_selproj(i_session,i_company,i_project) VALUES("+sessionId+", '"+i_com+"', '"+i_proj+"')");
			}// end while
			rs.close();
	  }
%>
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
                
          <td class="item_tab2" width="200">รายละเอียดงานซ่อมตามเดือนที่จ่าย</td>
                <td class="item_tab3">
				</td>                
				<td>
				&nbsp;
				<input type="radio" value="I" name="display_type" <%if (dispType.equals("I")){ out.print("checked");}%>>จำนวนรายการ&nbsp;
              	<input type="radio" value="D" name="display_type" <%if (dispType.equals("D")){ out.print("checked");}%>>จำนวนใบ&nbsp;
              	<input type="radio" value="A" name="display_type" <%if (dispType.equals("A")){ out.print("checked");}%>>จำนวนเงิน&nbsp;
				<a href="javascript:Go()"><img border="0" src="images/bu_R.gif" align="absmiddle" style="cursor:hand" width="16" height="16"></a></td>
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


			  <!-----------------------------------HEADER TABLE ------------------------------>
              <tr> 
                <td width="19%" height="1" class="col_name">รายละเอียดการแจ้งซ่อม</td>
				<%
					int loop = 0;
					for (int i=0;i<12;i++) {
						   String monthCol = "";
						    if (i<Integer.parseInt(reportType)) {
							   monthCol = shortMonth[monthList[i].intValue()]+" "+Integer.toString(yearList[i].intValue()).substring(2,4);
							   //monthCol = months[i];
							}
						   %><td width="3%" align="center" valign="middle" class="col_name"><%=doString.checkString(monthCol,"&nbsp;")%></td><%	
							loop++;
					}
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="col_name">&nbsp;</td><%
						loop++;
					}
				%>
                <td width="3%" align="center" valign="middle" class="col_name">รวม</td>
              </tr>
			  <!---------------------------------------------------------------------------------------------->
<% 
			line=0;
			String bgcolor = "";
			double qty = 0;
			double sum_qty = 0;
			String payMnth = "";
			java.util.Arrays.fill(tot_qtys, 0);
			rs = stmt.executeQuery("select distinct g.i_group, g.i_itmjob, g.n_itmjob from lan:serv_infboq i, lan:serv_infboq g where i.i_itmtype = '01' and i.i_group = g.i_group and g.i_type = '00' and g.i_seq = '0000' order by g.i_itmjob");
			if (rs != null) {
				while (rs.next() == true) {
					line++;
					bgcolor = ((line%2) == 0) ? "FAFAFA" : "FFFFFF";
					mainboq = doString.checkString(rs.getString("I_GROUP"));
					java.util.Arrays.fill(qtys, 0);
					sql.delete(0,sql.length()); 
					sql.append("SELECT p.d_payment, ")
						.append(disp_field)
						.append(" FROM lan:serv_infboq b, lan:serv_infpayment p, lan:serv_infdochd h, lan:serv_selproj s")
						.append(" WHERE b.i_group = '"+mainboq+"' AND b.i_seq > '0000' AND b.i_itmtype = '01'")
						.append(" AND b.i_itmjob = p.i_itmjob AND p.i_itmtype = '01'")
						.append(" AND p.d_payment >= '")
						.append(startQueryDate)
						.append("' AND p.d_payment <= '")
						.append(endQueryDate)
						.append("' AND p.f_itmstatus = 'CLS'")
						.append(" AND p.i_docno = h.i_docno")
						.append(" AND h.i_company = s.i_company AND h.i_project = s.i_project AND s.i_session = "+sessionId+" AND h.f_status != 'CAN'")
						.append(" GROUP BY p.d_payment ORDER BY p.d_payment DESC");
					rs1 = stmt1.executeQuery(sql.toString());
					if (rs1 != null) {
						while (rs1.next() == true) {
							payMnth = doString.checkString(rs1.getString(1));
							qty = 0;
							if (!payMnth.equals("")) {
								payMnth = payMnth.substring(0,7);
								qty = rs1.getDouble(2);
								for (int i=0;i<Integer.parseInt(reportType);i++) {
									if (payMnth.equals(months[i])) {
										qtys[i]=qty;
										break;
									}
								}// end for
							}
						}// end while
						rs1.close();
						rs1=null;
					}
%>
			<tr bgcolor="#<%=bgcolor%>">
			 <td width="19%" height="1" align="left" class="item ; dotline"><A HREF="javascript:dispSub('<%=mainboq%>')"><FONT COLOR="rgb(0,50,200)"><%=mainboq%>&nbsp;<%=doString.DisplayThai(rs.getString("N_ITMJOB"))%></font></A></td>
<%
					loop = 0;
					sum_qty = 0;
					for (int i=0;i<12;i++) {
						   qty = 0;
						    if (i<Integer.parseInt(reportType)) {
								qty = qtys[i];
								tot_qtys[i] += qtys[i];
								sum_qty += qty;
							}
						   %><td width="3%" align="right" valign="middle" class="dotline"><%=doString.displayNumber("###,###,###.00", qty)%></td><%	
							loop++;
					}
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
				%>
				<td width="3%" align="right" valign="middle" class="dotline"><%=doString.displayNumber("###,###,###.00", sum_qty)%></td>
<%
				}// end while
				rs.close();
				rs=null;
			}
%>
			</tr>
<%
			line++;
			bgcolor = ((line%2) == 0) ? "FAFAFA" : "FFFFFF";
%>
              <tr bgcolor="#<%=bgcolor%>">
                <td width="19%" height="1" class="item ; dotline" align="right">รวม</td>
<%
					loop = 0;					
					sum_qty = 0;
					for (int i=0;i<12;i++) {							
							qty = tot_qtys[i];
							sum_qty += qty;
						   %><td width="3%" align="right" valign="middle" class="dotline"><%=doString.displayNumber("###,###,###.00", qty)%></td><%	
							loop++;
					}
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
				%>
                <td width="3%" align="right" valign="middle" class="dotline"><%=doString.displayNumber("###,###,###.00", sum_qty)%></td>
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




<br style="font-size:3pt">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="left">&nbsp;</td>
	</tr>
	</table>
<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="80" class="act_tab2">&nbsp;</td> 	
            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_INFReport10.jsp" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
          </tr>
        </table>
          </td>
        </tr>
      </table>

<br style="font-size:30pt">

<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
  <tr><td width="100%" class="copyright" align="center">
  Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5  
  <br>ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;
  หรือ โทร. 0-2230-8279 (คุณประพัฒน์
  ฝ่ายบริการ)&nbsp; 0-2230-8491-5 (ฝ่าย IT)  
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE> 	
</FORM>
</BODY>
</HTML>
<%
	    stmt.executeUpdate("DELETE FROM lan:serv_selproj WHERE i_session = "+sessionId);
		stmt.close();
		stmt1.close();
		conn.close();
		stmt=null;
		stmt1=null;
		conn=null;
	} catch (Exception e) {
		System.out.println("ERROR SERV_SERV_INFReport10_1.jsp : " + e.getMessage());
		System.out.println("ERROR SQL  SERV_INFReport10_1.jsp : " + sql.toString());
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