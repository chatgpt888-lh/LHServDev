<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.Constants" %>
<%@ include file="function.jsp" %>
<%@ include file="confirmLogin.jsp" %>
<%
String userId = user.getUserID();
String empId = user.getEmpId();String user_group = doString.checkString(user.getUserGroup());String team_restrict = "";if (!user_group.equals("A")) {	team_restrict = " AND h.i_team = '"+user_group+"' ";}
String selProj = doString.checkString(request.getParameter("selProj"));
String docNo = doString.checkString(request.getParameter("docNo"));
int line=0;
int maxRow=0;
int nowPage = Integer.parseInt(doString.checkString(request.getParameter("now_page"),"1"));
int displayLine = Integer.parseInt(doString.checkString(request.getParameter("display_line"),"0"));
String dispType = doString.checkString(request.getParameter("display_type"),"L");

String chartGrp = doString.checkString(request.getParameter("chartGrp"));
String status = doString.checkString(request.getParameter("status"));
String itmType = doString.checkString(request.getParameter("itmType"));
String desc = "สาธารณูฯ";
if (itmType.equals("02")) {
	desc = "สาธารณะ";
}
String group = "";
if (chartGrp.equals("S")) {
	group = "Service Staff";
} else if (chartGrp.equals("M")) {
	group = "Service Manager";
} else if (chartGrp.equals("Z")) {
	group = "Manager";
}
String itmType_restrict = "";
if (!itmType.equals("")) {
	itmType_restrict = " AND h.i_docno = d.i_docno AND d.i_itmtype = '"+itmType+"'";
}
String emp_restrict = "";
String targetPage = "";
if (chartGrp.equals("S")) {
	targetPage = "SERV_InfOpenJob.jsp";
	//emp_restrict = " AND h.i_service_employ = '"+empId+"'";
} else {
	targetPage = "SERV_INFOpenJob_Appr.jsp";
}

String comId = "";
String projId = "";
String doc_restrict = "";
String staff_restrict = "";
String site_restrict = "";
String staffId = "";
String apprId = "";
String apprNme = "";
if (!docNo.equals("")) {
	doc_restrict = " AND a.i_docno = '"+docNo+"'";
}
if (!selProj.equals("")) {
	if (!selProj.equals("ALL")) {
		comId = selProj.substring(0,2);
		projId = selProj.substring(3);
		site_restrict = " AND h.i_company = '"+comId+"' AND h.i_project = '"+projId+"'";
	}
} else {
	//site_restrict = " AND h.i_project = 'NOPROJECT'";
}
%>
<HTML>
<HEAD>
<TITLE>INF Open Job List</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--

  function searchDocHD() {
     document.forms[0].now_page.value='1';
     document.forms[0].action="/LHServ/SERV_OpenJob_List.jsp";
     document.forms[0].submit();
  }

  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="/LHServ/SERV_INF_Wait_OpenJob_List.jsp";
     document.forms[0].submit();
  }

//-->
</script>



<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">


<FORM NAME="frmNewJob" METHOD=POST ACTION="/LHServ/SERV_INF_Wait_OpenJob_List.jsp">
<input type="hidden" name="now_page" value="1">

<input type="hidden" name="chartGrp" value="<%=chartGrp%>">
<input type="hidden" name="itmType" value="<%=itmType%>">
<input type="hidden" name="status" value="<%=status%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
            <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
              Open Job List : <%if (status.equals("W")) { out.print("Wait"); } else {out.print("Reject"); }%> <%=group%></td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">



            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดการสั่งซ่อม<%=desc%></td>
                <td class="item_tab3"></td>
                <td>&nbsp;</td>
              </tr>
            </table>
<%

Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
String optionSelected = null;
String code = "";
String from = "";
double amount=0;
String keyinDate = "";
String mode = "";
Calendar keyin = Calendar.getInstance();
StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
Statement pstmt = null;
ResultSet rs = null;
ResultSet rsPay = null;
try {
	if (ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();	
	pstmt = conn.createStatement();		
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
                  <td class="item ; dotline01" height="22" width="15%">โครงการ
                    :</td>
                  <td height="22" width="39%" class="dotline01">
                    <select name='selProj'  class='box' style='width:250px'  >
                      <option value='' <%if (selProj.equals("")) {%>selected<%}%> >------ กรุณาเลือก ------</option>                    
					  <OPTION value="ALL" <%if (selProj.equals("ALL")) {%>selected<%}%>>ทุกโครงการ</OPTION>
<%
	sql.delete(0, sql.length());
	sql.append("SELECT DISTINCT proj.i_company, proj.i_project, proj.n_project FROM lan:acxprojt proj, lan:acsbudgh bud");
	rs = stmt.executeQuery("SELECT proj_id FROM lan:serv_pstaff WHERE user_id = '" + userId + "' AND proj_id = 'ALL'");
	if (rs.next() == false) {
		from = "FROM lan:serv_infdocap a, lan:serv_infdochd h, docflow:acemploy e, lan:serv_pstaff s";
		if (!itmType.equals("")) {
			from += ", lan:serv_infdocdt d";
		}
		staff_restrict = " AND h.i_company = s.com_id AND h.i_project = s.proj_id AND s.user_id = '"+userId+"'";
		sql.append(", lan:serv_pstaff staff WHERE proj.i_company = staff.com_id AND proj.i_project = staff.proj_id AND staff.user_id = '")
			.append(userId + "' AND");
	} else {
		from = "FROM lan:serv_infdocap a, lan:serv_infdochd h, docflow:acemploy e";	
		if (!itmType.equals("")) {
			from += ", lan:serv_infdocdt d";
		}
		sql.append(" WHERE");
	}
	rs.close();
	rs=null;
	sql.append(" bud.i_company = proj.i_company AND bud.i_project = proj.i_project AND bud.d_year = '" + cur_year + "' ORDER BY proj.i_company, proj.i_project");
	rs = stmt.executeQuery(sql.toString());
	while (rs.next() == true) {
		optionSelected = "";
		code = doString.checkString(rs.getString("I_COMPANY")) + ":" + doString.checkString(rs.getString("I_PROJECT"));
		if (selProj.equals(code))
		{
			optionSelected = "selected";
		}
%>
              <OPTION value="<%=code%>" <%=optionSelected%>><%=code%> - <%=doString.DisplayThai(doString.checkString(rs.getString("N_PROJECT")))%></OPTION>
<%
	}
	rs.close();
	rs=null;
%>                    
                    </select>
                  </td>
                  <td height="22" class="item ; dotline01" width="14%">เลขที่ใบสั่งซ่อม
                    :</td>
                  <td height="22" width="32%" class="dotline01">
                    <input type="text" name="docNo" class="box" style="width:100px" value="<%=docNo%>">&nbsp;
                    <input type="image" border="0" name="Go" src="images/i_search.gif" width="20" height="20">
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
<%
	maxRow=0;
	sql.delete(0, sql.length());
	sql.append("SELECT COUNT(DISTINCT h.i_docno) AS NUM_DOC ")
		.append(from)
		.append(" WHERE a.i_chart_grp = '"+chartGrp+"' AND a.f_approve = '"+status+"'")
		.append(doc_restrict)
		.append(" AND a.i_docno = h.i_docno AND h.f_status != 'CAN' ")				.append(team_restrict)		
		.append(staff_restrict)
		.append(site_restrict)
		.append(emp_restrict) //Requester Restrict
		.append(itmType_restrict) 
		.append(" AND h.i_service_employ = e.i_employ");
	rs = stmt.executeQuery(sql.toString());
	if (rs != null) {
		if (rs.next() == true) {
			maxRow = rs.getInt("NUM_DOC");
		}
		rs.close();
		rs=null;
	}			
	if (dispType.equalsIgnoreCase("A")) {
		displayLine = maxRow;
		nowPage = 1;
	}
	if (displayLine<Constants.SERV_OPENJOBLIST_LINE) displayLine = Constants.SERV_OPENJOBLIST_LINE;
	int startRow = ((nowPage-1)*displayLine);
	int endRow = startRow+displayLine;
	int tmpMax = maxRow;
	String pageLink = "";
	int tmpPage = 0;
	while (tmpMax>0) {
		tmpMax -= displayLine;
		tmpPage++;
		if (nowPage==tmpPage) {
			pageLink += "&nbsp; <b>"+tmpPage+"</b> ";
		} else {
			pageLink += "&nbsp; <a href='#' onclick='changePage("+tmpPage+");'>"+tmpPage+"</a> ";
		}
	}
		   
	if (tmpPage>1) {
		int prev = nowPage-1;
		if (prev<1) prev=1;  
		pageLink = "<a href='#' onclick='changePage("+prev+");'>หน้าก่อน</a>&nbsp; "+pageLink;
		int next = nowPage+1;
		if (next>tmpPage) next = tmpPage;
		pageLink += "&nbsp; <a href='#' onclick='changePage("+next+");'>หน้าถัดไป</a>";      
	} else {
		pageLink = "หน้า <b>1</b>";
	}		
%>
<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="160">รายการซ่อม</td>
                <td class="item_tab3"></td>
                <td>&nbsp;<input type="radio" value="L" <%if (dispType.equals("L")) { out.print("checked"); } %> name="display_type" >แสดงจำนวนรายการต่อหน้า&nbsp;
                  <input type="text" name="display_line" class="boxC" style="width:50px" value="<%=displayLine%>">&nbsp;
                  รายการ&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" value="A" name="display_type" <%if (dispType.equals("A")) { out.print("checked"); } %>>
                  แสดงรายการทั้งหมด&nbsp;&nbsp;&nbsp;&nbsp;
                  <a href="#" onclick="changePage(1);"><img border="0" src="images/bu_R.gif" align="absmiddle" style="cursor:hand" width="16" height="16"></a>
                  </td>
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
                  <td width="11%" class="col_name">เลขที่ใบสั่งซ่อม</td>
                  <td width="21%" class="col_name">ชื่อผู้แจ้ง</td>
                  <td width="13%" class="col_name">วันเวลาที่แจ้ง</td>
                  <td width="12%" class="col_name">วันที่นัดซ่อม</td>
                  <td width="11%" class="col_name">วันที่ประมาณการเสร็จ</td>
                  <td width="11%" class="col_name">จำนวนเงิน</td>
                  <td width="21%" class="col_name">ชื่อผู้อนุมัติ</td>
                </tr>
<%
	sql.delete(0, sql.length());
	sql.append("SELECT FIRST "+Integer.toString(endRow)+" DISTINCT h.i_docno, h.i_service_employ, TRIM(e.n_prename_th) || ' ' || TRIM(e.n_nemploy_th) || ' ' || TRIM(e.n_semploy_th) AS EMP_NAME, h.i_approver, h.d_keyin, h.d_appoint, h.d_est_close ")
		.append(from)
		.append(" WHERE a.i_chart_grp = '"+chartGrp+"' AND a.f_approve = '"+status+"'")
		.append(doc_restrict)
		.append(" AND a.i_docno = h.i_docno AND h.f_status != 'CAN' ")		.append(team_restrict)
		.append(staff_restrict)
		.append(site_restrict)
		.append(emp_restrict) //Requester Restrict
		.append(itmType_restrict)
		.append(" AND h.i_service_employ = e.i_employ")
		.append(" ORDER BY h.i_docno");
System.out.println(sql.toString());		
	rs = stmt.executeQuery(sql.toString());
		for (int i=0;i<maxRow;i++) { 
			if (rs.next() == true) {
				if (i>=startRow && i<=endRow) {
					docNo = doString.checkString(rs.getString("I_DOCNO"));
					staffId = doString.checkString(rs.getString("I_SERVICE_EMPLOY"));
					keyinDate = "-";
					Timestamp tmp = rs.getTimestamp("D_KEYIN");
					if (tmp != null) {
						keyin.setTime(tmp);      
						keyinDate = getDateFromCalendar(keyin);    
						keyinDate += "&nbsp;&nbsp;"+getTimeFromCalendar(keyin)+" น.";    		            
					}
					apprId = doString.checkString(rs.getString("I_APPROVER"));
					apprNme = "&nbsp;";
					rsPay = pstmt.executeQuery("SELECT TRIM(n_prename_th) || ' ' || TRIM(n_nemploy_th) || ' ' || TRIM(n_semploy_th) AS EMP_NAME FROM docflow:acemploy WHERE i_employ = '"+apprId+"'");
					if (rsPay != null) {
						if (rsPay.next() == true) {
							apprNme = doString.checkString(rsPay.getString(1));						
						}
						rsPay.close();
						rsPay=null;
					}					
					amount = 0;	
					rsPay = pstmt.executeQuery("SELECT SUM(z_amount_pay) AS PAY_AMT FROM lan:serv_infdocdt WHERE i_docno = '"+docNo+"' AND f_itmstatus != 'CAN'");
					if (rsPay != null) {
						if (rsPay.next() == true) {
							amount = rsPay.getDouble("PAY_AMT");
						}
						rsPay.close();
						rsPay=null;
					}
					mode = "V";
					targetPage = "SERV_INFOpenJob_Disp.jsp";
					if (chartGrp.equals("S")) {
						if (empId.equals(staffId)) {
							mode = "E";
							targetPage = "SERV_INFOpenJob_Disp.jsp";
						}
					} else {
						if (empId.equals(apprId)) {
							targetPage = "SERV_INFOpenJob_Appr.jsp";
						}
					}					
%>
                <tr>
                  <td width="11%" align="center" class="dotline"><a href="<%=targetPage%>?docNo=<%=docNo%>&mode=<%=mode%>&chartGrp=<%=chartGrp%>&itmType=<%=itmType%>"><%=docNo%></a></td>
                  <td width="21%" class="dotline ; item"><%=doString.DisplayThai(rs.getString("EMP_NAME"))%></td>
                  <td width="13%" align="center" class="dotline"><%=keyinDate%></td>
                  <td width="12%" align="center" class="dotline"><%=DateUtil.ifxToThaiDateNoTime(rs.getString("D_APPOINT"))%></td>
                  <td width="11%" align="center" class="dotline"><%=DateUtil.ifxToThaiDateNoTime(rs.getString("D_EST_CLOSE"))%></td>
                  <td width="11%" align="center" class="dotline"><span id="grandTotal"><%=doString.displayNumber("###,###,###.00", amount)%></span></td>
                  <td width="21%" align="center" class="dotline"><%=doString.DisplayThai(apprNme)%></td>
                </tr>
<%		
					line++;
				}
				if (i>endRow) break;
			}
		}// end for
		while (line<displayLine) {
			line++;
%>
                <tr> 
                  <td width="11%" align="center" class="dotline">&nbsp;</td>
                  <td width="21%" class="dotline ; item">&nbsp;</td>
                  <td width="13%" align="center" class="dotline">&nbsp;</td>
                  <td width="12%" align="center" class="dotline">&nbsp;</td>
                  <td width="11%" align="center" class="dotline">&nbsp;</td>
                  <td width="11%" align="center" class="dotline">&nbsp;</td>
                  <td width="21%" align="center" class="dotline">&nbsp;</td>
                </tr>

<%
		}// end while
%>                
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
        <tr class="gray">
          <td width="100%" align="right"><%=pageLink%></td>
        </tr>
      </table>
<%
		pstmt.close();
		stmt.close();
		conn.close();
		stmt = null;
		pstmt = null;
		conn=null;
		System.out.println("----SERV_INF_Wait_OpenJob_List.jsp------ ");
	} catch (Exception e) {
		System.out.println("ERROR SERV_INF_Wait_OpenJob_List.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (stmt != null) stmt.close();
			if (pstmt != null) pstmt.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>


<br style="font-size:10pt">



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2"></td>
            <td class="act_tab3">&nbsp;</td>
            <td class="act_tab4"><a href="SERV_Home.jsp?sel_project=<%=selProj%>"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="SERV_Home.jsp?sel_project=<%=selProj%>"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
          </tr>
        </table>

          </td>
        </tr>
      </table>




<br style="font-size:20pt">

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