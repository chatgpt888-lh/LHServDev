<%@page contentType="text/html; charset=TIS-620"%>
<%@page import="com.lh.util.*" %>
<%@page import="serv.common.*" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%
	String userId = user.getUserID();
	String empId = user.getEmpId();
   String selProj = doString.checkString(request.getParameter("sel_project"),"");
   String comId = "";
   String projId = "";
   if (!selProj.equals("")) {
		comId = selProj.substring(0,2);
		projId = selProj.substring(3);
   }

   String lockId = doString.checkString(request.getParameter("lockId"),"");
   lockId = lockId.toUpperCase();
   String project = "";
	String docNo = "";
	Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
	String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);   
   //-----====================== Search BOQ Data ================================------//
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	try {
	    doString str = new doString();

        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();
%>


<HTML>
<HEAD>
<TITLE>พิมพ์ใบ Payin และระเบียบปฏิบัติการปลูกสร้างหรือต่อเติมอาคาร</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">
<!--
   function PrintReten() {
   		if (frmPrntReten.sel_project.value == "") {
   			alert("โปรดเลือกโครงการ");
   			frmPrntReten.sel_project.focus();
   			return;
   		}   
   		if (frmPrntReten.lockId.value == "") {
   			alert("โปรดระบุแปลงขาย");
   			frmPrntReten.lockId.focus();
   			return;
   		}
   		if (frmPrntReten.docNo.value == "") {
   			alert("โปรดเลือกเลขที่ใบวางเงิน");
   			frmPrntReten.docNo.focus();
   			return;
   		}
		frmPrntReten.target = "_blank";   		
       //frmPrntReten.action = "/LHServ/PrintPayInServlet";
       frmPrntReten.action = "/LHServ/SERV_PrintPayInCBServlet";
       frmPrntReten.submit();
       frmPrntReten.target = "_self"; 
   }
   function Go() {
   		if (frmPrntReten.sel_project.value == "") {
   			alert("โปรดเลือกโครงการ");
   			frmPrntReten.sel_project.focus();
   			return;
   		}   
   		if (frmPrntReten.lockId.value == "") {
   			alert("โปรดระบุแปลงขาย");
   			frmPrntReten.lockId.focus();
   			return;
   		}
		  		
       frmPrntReten.action = "SERV_PrntReten2.jsp";
       frmPrntReten.submit();
   }
//-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM name="frmPrntReten" method="post" action="SERV_PrntReten2.jsp">
<input type="hidden" name="comId" value="<%=comId%>">
<input type="hidden" name="projId" value="<%=projId%>">
<input type="hidden" name="empId" value="<%=empId%>">
<input type="hidden" name="userId" value="<%=userId%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            พิมพ์ใบ Payin และระเบียบปฏิบัติการปลูกสร้างหรือต่อเติมอาคาร</td>
          <td width="30%" align="right">&nbsp;</td>
        </tr>
      </table>


<br style="font-size:10pt">
                

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
    <td height="22" class="item ; dotline01" width="8%">ชื่อ :</td>
    <td height="22" width="37%" class="dotline01"><%=doString.DisplayThai(user.getEmpName())%></td>
    <td height="22" width="15%" class="item ; dotline01">&nbsp;</td>
    <td height="22" width="40%" class="dotline01">&nbsp;</td>
  </tr>
  <tr>
    <td height="22" class="item ; dotline01" width="8%">โครงการ :</td>
    <td height="22" width="37%" class="dotline01">
                    <select size="1" name="sel_project" class="box" style="width:250px">
                      <option value="">----- เลือกโครงการ -----</option>
<%
	String code = "";
	String optionSelected = "";
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
			code = doString.checkString(rs.getString("I_COMPANY"))+":"+doString.checkString(rs.getString("I_PROJECT"));
			if (code.equals(selProj)) {
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
    <td height="22" width="15%" class="item ; dotline01">&nbsp;</td>
    <td height="22" width="40%" class="dotline01">&nbsp;</td>
  </tr>
  <tr>
    <td height="22" class="item ; dotline01" width="8%">แปลง :</td>
    <td height="22" width="37%" class="dotline01"><INPUT type="text" name="lockId" class="box" value="<%=lockId%>" style="width:60px">
	&nbsp;&nbsp;
	<a href="javascript:Go()"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a>
    </td>
    <td height="22" width="15%" class="item ; dotline01">&nbsp;</td>
    <td height="22" width="40%" class="dotline01">&nbsp;</td>
  </tr>
  <tr>
    <td height="22" class="item ; dotline01" width="8%">เลขที่ใบวางเงิน : </td>
    <td height="22" width="37%" class="dotline01">
		  <SELECT size="1" name="docNo" class="box" style="width:250px" >
              <OPTION value="">----- เลือกรายการ -----</OPTION>
<%
	sql.delete(0,sql.length());
	sql.append("SELECT i_docno FROM lan:serv_rethd WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_sort = '"+lockId+"' AND d_conf_payin IS NULL ORDER BY i_docno");
	rs = stmt.executeQuery(sql.toString());
	if (rs != null) {
		while (rs.next() == true) {
			docNo = doString.checkString(rs.getString("I_DOCNO"));
%>
              <OPTION value="<%=docNo%>"><%=docNo%></OPTION>
<%
		}// end while
		rs.close();
		rs=null;
	}
%>
                  </SELECT>
	</td>
    <td height="22" width="15%" class="item ; dotline01">&nbsp;</td>
    <td height="22" width="40%" class="dotline01">&nbsp;</td>
  </tr>
  <tr>
    <td height="22" class="item ; dotline01" width="8%">ประเภทเอกสาร :</td>
    <td height="22" width="37%" class="dotline01">
    <input type="radio" name="docType" value="A" checked>ทั้งหมด
    <input type="radio" name="docType" value="P">ใบ Payin
    <input type="radio" name="docType" value="R">ระเบียบปฏิบัติการปลูกสร้างหรือต่อเติมอาคาร
    </td>
    <td height="22" width="15%" class="item ; dotline01">&nbsp;</td>
    <td height="22" width="40%" class="dotline01">&nbsp;</td>
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
<br style="font-size:10pt">
<table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
  <tr>
    <td class="act_tab1"></td>
    <td width="75" class="act_tab2">
			<A href="javascript:PrintReten(frmPrntReten)"><IMG border="0" src="images/act_print.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27"></A>
	</td>
    <td class="act_tab3"></td>
    <td class="act_tab4"><a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
      <a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
  </tr>
</table>
<!--/table-->


	  </td>
        </tr>
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
<%
		conn.close();
		stmt.close();
		conn=null;
		stmt=null;
	} catch (Exception e) {
		System.out.println("ERROR SERV_PrntReten2.jsp : " + e.getMessage());
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