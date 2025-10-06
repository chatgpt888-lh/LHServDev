<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%
	String selProj = doString.checkString(request.getParameter("sel_project"));
	String comId = "";
	String projId = "";
	if (selProj.length() >= 6) {
		comId = selProj.substring(0,2);
		projId = selProj.substring(3,6);
	} 
	String docNo = doString.checkString(request.getParameter("i_docno"));
	String jobStatus = doString.checkString(request.getParameter("job_status"));
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
		
        String startDate = common.getValueFromDateListbox("start",request);
        String endDate = common.getValueFromDateListbox("end",request);
%>
<HTML>
<HEAD>
<TITLE>Deny List</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
<!--

  function searchDocHD() {
     if (!validDate()) {
        return false;
     }
     document.forms[0].action="SERV_ConDeny_Pay_List.jsp";
     document.forms[0].submit();  
  }

  function validDate() {
     var sdate = document.forms[0].start_date.value;
     var smonth = document.forms[0].start_month.value;
     var syear = document.forms[0].start_year.value;
     var edate = document.forms[0].end_date.value;
     var emonth = document.forms[0].end_month.value;
     var eyear = document.forms[0].end_year.value; 
     
     //---- Check select date ---//
     if (sdate.length==0 && smonth.length==0 && syear.length==0 &&
         edate.length==0 && emonth.length==0 && eyear.length==0) {
         return true;
     }     

     
     var startDate = new Date(parseInt(syear,10),parseInt(smonth,10)-1,parseInt(sdate,10));
     var endDate = new Date(parseInt(eyear,10),parseInt(emonth,10)-1,parseInt(edate,10));
     
     if (startDate.getMonth()!=(parseInt(smonth,10)-1)) {
        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].start_date.focus();
        return false;
     }
     
     if (endDate.getMonth()!=(parseInt(emonth,10)-1)) {
        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].end_date.focus();
        return false;
     }     
     
	if (startDate>endDate) {
	    alert(" วันที่สิ้นสุดต้องไม่น้อยกว่าวันที่เริ่มต้น ! ");
	    return false;
	}
  
     return true;
  }

//-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM METHOD="POST" ACTION="">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;ยกเลิกใบเบิกงวด</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>
<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="150">ค้นหาใบเบิกงวด</td>
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
                  <td class="item ; dotline01" height="22" width="9%">โครงการ 
                    :</td>
                  <td height="22" width="45%" class="dotline01"> <%=common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:250px' ")%> 
                  </td>
                  <td height="22" class="item ; dotline01" width="10%">เลขที่ใบเบิกงวด 
                    :</td>
                  <td height="22" width="36%" class="dotline01">
<input type="text" name="i_docno" class="box" style="width:100px" value="<%=docNo%>"></td>
  </tr>

  <tr>
                  <td class="item ; dotline01" height="22" width="9%">วันที่เบิกงวด 
                    :</td>
                  <td height="22" width="45%" class="dotline01"> <%=common.genDateListbox("start",request," class='box' ")%>&nbsp;ถึง 
                    &nbsp;<%=common.genDateListbox("end",request," class='box' ")%> 
                  </td>
                  <td height="22" class="item ; dotline01" width="10%">สถานะ :</td>
                  <td height="22" width="36%" class="dotline01"> 
                    <select size="1" class="box" style="width:100px" name="job_status">
        <option value=''>ทุกสถานะ</option>
        <option value='600' <%=jobStatus.equals("600") ? " selected " : ""%>>Service Manager</option>
        <option value='700' <%=jobStatus.equals("700") ? " selected " : ""%>>Manager</option>
        <option value='800' <%=jobStatus.equals("800") ? " selected " : ""%>>VP</option>
        <option value='CLS' <%=jobStatus.equals("CLS") ? " selected " : ""%>>Close</option>
      </select>
      &nbsp;&nbsp;&nbsp;&nbsp;
      <a href="#" onclick="searchDocHD()"><img border="0" src="images/i_search.gif" align="absmiddle" width="20" height="20"></a> 
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
                <td class="item_tab2" width="150">รายการใบเบิกงวด</td>
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
          <td width="14%" class="col_name">เลขที่ใบเบิกงวด</td>
          <td width="15%" class="col_name">วันที่เบิก</td>
          <td width="20%" class="col_name">ผู้ขอเบิก</td>
          <td width="25%" class="col_name">ผู้รับเหมา</td>
          <td width="8%" class="col_name">จำนวนงวด</td>
          <td width="8%" class="col_name">จำนวนเงิน</td>
          <td width="14%" class="col_name">สถานะ</td>
        </tr>
<%
				String status = "";
				String iDocType = "";
				String keyinDate = "";
				String vendor = "";
				double pvAmnt = 0;
			    String jspLink = "";
				String tmpStat = "";
		        int line = 0;
		        int num_due = 0;
		        sql.delete(0,sql.length());				
				sql.append("SELECT d.i_docno, d.d_keyin, d.i_service_employ, COUNT(p.i_seq) AS NUM_DUE, SUM(p.z_amount_pv)::DECIMAL(16,2) AS PV_AMNT FROM lan:serv_infdochd d, lan:serv_infpayment p WHERE d.i_company = '")
					.append(comId)
					.append("' AND d.i_project = '")
					.append(projId)
					.append("' AND d.i_doc_type = 'C' AND d.f_status IN ('OPN','CLS')");
				if (!docNo.equals("")) {
					sql.append(" AND d.i_docno = '"+docNo+"'");
				}
				if (!startDate.equals("") && !endDate.equals("")) {
					sql.append(" AND d.d_keyin BETWEEN '"+startDate+" 00:00' AND '"+endDate+" 23:59'");
				}
				sql.append(" AND d.i_docno = p.i_docno");
				if (!jobStatus.equals("")) {
					sql.append(" AND p.f_itmstatus = '"+jobStatus+"'");
				}
				sql.append(" GROUP BY d.i_docno, d.d_keyin, d.i_service_employ ORDER BY d.i_docno");
		        rs = stmt.executeQuery(sql.toString());
		        if (rs != null) {
		        	while (rs.next() == true) {
		        		line++;
			            docNo = doString.checkString(rs.getString("I_DOCNO"));
						Hashtable tmpHeader = common.getInfDocHeaderDetails(docNo);
						String inFormEmp = doString.checkString((String) tmpHeader.get("inform_emp"));
						keyinDate = DateUtil.ifxToThaiDate(doString.checkString(rs.getString("D_KEYIN")));
						num_due = rs.getInt("NUM_DUE");
						pvAmnt = rs.getDouble("PV_AMNT");
						status = "";
						vendor = "";
						rs1 = stmt1.executeQuery("SELECT v.bus_name, p.f_itmstatus FROM lan:serv_infpayment p, lan:stpvendr v WHERE p.i_docno = '"+docNo+"' AND p.i_vendor = v.vend_code");
						if (rs1.next() == true) {
							 vendor = doString.DisplayThai(doString.checkString(rs1.getString("BUS_NAME")));
					         tmpStat = doString.checkString(rs1.getString("F_ITMSTATUS"));
					         if (tmpStat.equals("600")) {
					            status = "Service Manager";
					         } else if (tmpStat.equals("700")) {
					            status = "Manager";
					         } else if (tmpStat.equals("800")) {
					            status = "VP";
					         } else if (tmpStat.equals("CLS")) {
					            status = "Close";
					         } else {
					            status = "-";
					         }
						}
						rs1.close();
						rs1=null;
%>
					        <tr>
					          <td width="14%" align="center" class="dotline"><a href="SERV_ConDenyPay.jsp?docNo=<%=docNo%>"><%=docNo%></a></td>
					          <td width="15%" align="center" class="dotline"><%=keyinDate%> น.</td>
					          <td width="20%" class="dotline"><%=doString.DisplayThai(inFormEmp)%></td>
					          <td width="25%" align="left" class="dotline"><%=vendor%></td>
					          <td width="8%" align="center" class="dotline"><%=num_due%></td>
					          <td width="8%" align="right" class="dotline"><%=doString.displayNumber("###,###,###.00",pvAmnt)%></td>
					          <td width="14%" align="center" class="dotline"><%=status%></td>
					        </tr>					        
<%						
		        	}// end while
		        	rs.close();
		        	rs=null;
		        }
				if (line == 0) {
%>    
			        <tr>
			          <td width="14%" align="center" class="dotline">&nbsp;</td>
			          <td width="15%" align="center" class="dotline">&nbsp;</td>
			          <td width="20%" class="dotline">&nbsp;</td>
			          <td width="25%" class="dotline">&nbsp;</td>
			          <td width="8%" align="center" class="dotline">&nbsp;</td>
			          <td width="8%" align="center" class="dotline">&nbsp;</td>
			          <td width="14%" align="center" class="dotline">&nbsp;</td>
			        </tr>			        
<%               
	           }
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
<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">
            </td>   
            <td class="act_tab3"></td>   
            <td class="act_tab4">
              <a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
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
		stmt.close();
		stmt1.close();
		conn.close();
		stmt=null;
		stmt1=null;
		conn=null;
	} catch (Exception e) {
		System.out.println("ERROR SERV_ConDeny_Pay_List.jsp : " + e.getMessage());
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