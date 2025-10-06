<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
 <%!
 	private String getNProject(Statement stmt, String i_company,
			String i_project) throws SQLException {
		String n_project = "";
		ResultSet rs = stmt
				.executeQuery("select n_project from lan:acxprojt where i_company = '"
						+ i_company + "' and i_project = '" + i_project + "' ");
		if (rs.next()) {
			n_project = doString.checkString(rs.getString("n_project"), "");
		}
		rs.close();
		return n_project;
	}
	
	private String thaiToDB(String thDate) {
		return (Integer.parseInt(thDate.substring(6, 10)) - 543) + "-"
				+ thDate.substring(3, 5) + "-" + thDate.substring(0, 2);
	}
	
	private int getDocCode(Statement stmt, String i_docno )  throws SQLException {
		int status = 0;
		ResultSet rs = stmt.executeQuery("select  nvl(min(f_itmstatus),0) as min_itmstatus from lan:serv_flow where i_docno = '"+i_docno+"' ");
		if (rs.next()) {
			status = rs.getInt("min_itmstatus");
		}
		rs.close();
		return status;
	}
	private String getStatus(Statement stmt, String i_docno )throws SQLException{
		int status = getDocCode(stmt,i_docno);
		switch(status){
			case 100 : return "<img src=\"/LHServ/images/i_pass_no2.gif\" border=\"0\" align=\"absmiddle\" />&nbsp;N";
			case 200 : return "<img src=\"/LHServ/images/i_pass2.gif\" border=\"0\" align=\"absmiddle\" />&nbsp;Y";
			default : return "";
		}
	}	
	
	private String getStartTask(Statement stmt, String i_docno )  throws SQLException {
		int count_vendor = 0;
		int count_itmstatus = 0;
		ResultSet rs = stmt.executeQuery("select  count(f_itmstatus) as count_vendor from lan:serv_flow where i_docno = '"+i_docno+"' ");
		if (rs.next()) {
			count_vendor = rs.getInt("count_vendor");
		}
		rs.close();
		rs = stmt.executeQuery("select  count(f_itmstatus) as count_itmstatus from lan:serv_flow where i_docno = '"+i_docno+"' and f_itmstatus = '200' ");
		if (rs.next()) {
			count_itmstatus = rs.getInt("count_itmstatus");
		}
		rs.close();
		rs = null;
		if(count_vendor == count_itmstatus){
			return "<img src=\"/LHServ/images/i_pass2.gif\" border=\"0\" align=\"absmiddle\" />&nbsp;Y";
		}else{
			return "<img src=\"/LHServ/images/i_pass_no2.gif\" border=\"0\" align=\"absmiddle\" />&nbsp;N";
		}
	}
	 private String getNVendor(Statement stmt , String ven_no) throws SQLException{
	 	String ven_name = "";
	 	ResultSet rs = stmt.executeQuery("select ven_name from lan:vendor where ven_no = '"+ven_no+"' ");
	 	if(rs.next()){
	 		ven_name = doString.checkString(rs.getString("ven_name"),"");
	 	}
	 	rs.close();
	 	return ven_name;
	 }
%>
<%
	Calendar right = Calendar.getInstance();
	int dd = right.get(Calendar.DATE);
	int mm = right.get(Calendar.MONTH) + 1;
	int yy = right.get(Calendar.YEAR);
	if (yy < 2400) {
		yy += 543;
	}
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	StringBuffer sql = new StringBuffer("");

	String project = "";
	String i_company = "";
	String i_project = "";
	String d_keyin_beg = "";
	String d_keyin_end = "";
	String vendor_disp = "";
	String status_itm = "";
	String i_vendor  = ""; 

	int count = 0;
	String sort_col = "default";
	try {
		if (ds == null)
			getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();
		stmt1 = conn.createStatement();

		i_company = doString.checkString(request.getParameter("i_company"), "");
		i_project = doString.checkString(request.getParameter("i_project"), "");
		d_keyin_beg = doString.checkString(request.getParameter("d_keyin_beg"), (dd < 10 ? "0" + dd : "" + dd) + "/" + (mm < 10 ? "0" + mm : "" + mm) + "/" + yy);
		d_keyin_end = doString.checkString(request.getParameter("d_keyin_end"), (dd < 10 ? "0" + dd : "" + dd) + "/" + (mm < 10 ? "0" + mm : "" + mm) + "/" + yy);
		sort_col = doString.checkString(request.getParameter("sort_col"), "default");
		vendor_disp = doString.checkString(request.getParameter("n_vendor_disp"),"N");
		i_vendor = doString.checkString(request.getParameter("i_vendor"), "");
		
%>
<HTML>
<HEAD>
<TITLE>Home</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--
function sortBy(theCol){
	var form = document.frmSERV;
	form.sort_col.value = theCol;
	form.submit();
}
   
//-->
</script>


<base target="_self">


</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM method="POST" action="#" name="frmSERV" >
<input type="hidden" name="i_docno" value="" />
<input type="hidden" name="edit" value="" />
<input type="hidden" name="sort_col" value="<%=sort_col%>" />
<input type="hidden" name="i_company" value="<%=i_company%>" />
<input type="hidden" name="i_project" value="<%=i_project%>" />
<input type="hidden" name="d_keyin_beg" value="<%=d_keyin_beg%>" />
<input type="hidden" name="d_keyin_end" value="<%=d_keyin_end%>" />

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center" class="BD">
    

      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ยินดีต้อนรับสู่ระบบบริการหลังการขาย </td>
          <td width="30%" align="right">&nbsp;
	
          </td>
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
    <td height="22" class="item ; dotline01" width="80%">โครงการ : &nbsp; <%=i_company + i_project%> - <%=doString.DisplayThai(getNProject(stmt, i_company,i_project))%>
    &nbsp;</td>
    <td  height="22" class="item ; dotline01" align="right" width="20%">
    	v.2/20
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
                <td class="item_tab2" width="300">รายละเอียดการ Follow Up ผู้รับเหมา</td>
                <td class="item_tab3"></td>
                <td >&nbsp;</td>
              </tr>
            </table>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td valign="bottom" class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
    <td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>


<table border="0" width="100%" cellspacing="0" cellpadding="0">



  <tr>
    <td width="100%" class="frmL" align="center">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
	<td width="5%" class="col_name">No.</td>
	<td width="12%" class="col_name"><a href="javascript:sortBy('default')" >เลขที่เอกสาร</a></td>
	<td width="8%" class="col_name"><a href="javascript:sortBy('i_lock')" >แปลง</a></td>
	<td width="10%" class="col_name"><a href="javascript:sortBy('i_house')" >บ้านเลขที่</a></td>
    <td width="20%" class="col_name">ชื่อผู้แจ้ง / ลูกค้า</td>
    <td class="col_name"><a href="javascript:sortBy('i_date')" >วันที่แจ้งซ่อม</a></td>
    <td class="col_name"><a href="javascript:sortBy('d_appoint')" >วันที่นัดซ่อม</a></td>
    <!--  td class="col_name"><a href="javascript:sortBy('d_dog')" >วันที่ประมาณการเสร็จ</a></td>  -->
    <td class="col_name"><a href="javascript:sortBy('i_vendor')" >ชื่อผู้รับเหมา</a></td>
    <td class="col_name">Start Task</td>
    </tr>
<%
		sql.delete(0, sql.length());
		if ("Y".equals(vendor_disp)) {
			sql.append(" select distinct b.i_docno , a.i_lock , a.i_house , a.n_customer , a.i_date , d.i_vendor , b.d_appoint ")
				.append(" from lan:svc_dochd a , lan:svc_docdt b , lan:serv_dochd c , lan:serv_flow d ")
				.append(" where a.i_svc_docno  = b.i_svc_docno ")
				.append(" and b.i_docno = c.i_docno ")
				.append(" and b.i_docno = d.i_docno ")
				.append(" and a.i_company = '" + i_company + "' ")
				.append(" and a.i_project = '" + i_project + "' ")
				.append(" and date(a.d_keyin) between '"+ thaiToDB(d_keyin_beg)+ "'  and '"+ thaiToDB(d_keyin_end) + "' ")
				.append(" and b.i_itmno = '01' ")
				.append(" and b.i_itmsub = '01' ")
				.append(" and c.i_doc_type = 'J' ")
				.append(" and c.f_status = 'OPN' ")
				.append(" and d.f_itmstatus in ('100','200') ")
				.append(" and d.i_vendor = '"+i_vendor+"' ")
				.append(" and (c.d_complete_max is null or c.d_complete_max = '' ) ");
		}else {
			sql.append(" select distinct b.i_docno , a.i_lock , a.i_house , a.n_customer , a.i_date , d.i_vendor , b.d_appoint ")
				.append(" from lan:svc_dochd a , lan:svc_docdt b , lan:serv_dochd c , lan:serv_flow d ")
				.append(" where a.i_svc_docno  = b.i_svc_docno ")
				.append(" and b.i_docno = c.i_docno ")
				.append(" and b.i_docno = d.i_docno ")
				.append(" and a.i_company = '" + i_company + "' ")
				.append(" and a.i_project = '" + i_project + "' ")
				.append(" and date(a.d_keyin) between '"+ thaiToDB(d_keyin_beg)+ "'  and '"+ thaiToDB(d_keyin_end) + "' ")
				.append(" and b.i_itmno = '01' ")
				.append(" and b.i_itmsub = '01' ")
				.append(" and c.i_doc_type = 'J' ")
				.append(" and c.f_status = 'OPN' ")
				.append(" and d.f_itmstatus in ('100','200') ")
				.append(" and (c.d_complete_max is null or c.d_complete_max = '' ) ");
		}
		if("i_docno".equals(sort_col)){
			sql.append(" order by 1,2 ");
		}else if("i_lock".equals(sort_col)){
			sql.append(" order by 2,1 ");
		}else if("i_house".equals(sort_col)){
			sql.append(" order by 3,1,2 ");
		}else if("i_date".equals(sort_col)){
			sql.append(" order by 5 desc,1,2 ");
		}else if("d_appoint".equals(sort_col)){
			sql.append(" order by 7 desc,1,2 ");
		}else if("d_dog".equals(sort_col)){
			sql.append(" order by 6,1,2 ");
		}else if("i_vendor".equals(sort_col)){
			sql.append(" order by 6,1,2 ");
		}else{
			if ("Y".equals(vendor_disp)) {
				sql.append(" order by 1,2 ");
			}else{
				sql.append(" order by 6,1,2 ");
			}
		}
		System.out.println(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		while (rs.next()) {
%>
	<tr>
	<td class="dotline" align="center"><%=++count%></td>
	<td class="dotline" align="center"><%=doString.checkString(rs.getString("i_docno"), "")%></td>
	<td class="dotline" align="center">&nbsp;<%=doString.checkString(rs.getString("i_lock"), "")%></td>
	<td class="dotline" align="center">&nbsp;<%=doString.checkString(rs.getString("i_house"), "")%></td>
    <td class="dotline" >&nbsp;<%=doString.DisplayThai(doString.checkString(rs.getString("n_customer"), ""))%></td>
    <td class="dotline" align="center">&nbsp;<%=DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString("i_date"), ""))%></td>
    <td class="dotline" align="center">&nbsp;<%=DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString("d_appoint"), ""))%></td>
    <!--  td class="dotline" align="center">&nbsp;xx/xx/xxxx</td --> 
    <td class="dotline" align="center"><%=doString.DisplayThai(getNVendor(stmt1,doString.checkString(rs.getString("i_vendor"), "")))%></td>
    <td class="dotline" align="center">&nbsp;<%=doString.DisplayThai(getStartTask(stmt1,doString.checkString(rs.getString("i_docno"), "")))%></td> 
    </tr>
<%
		}
		rs.close();
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
<br/>
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">

            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:history.back()" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="/LHServ/SERV_Index.jsp" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
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
		conn.close();
		stmt = null;
		conn = null;
	} catch (Exception e) {
		System.out.println("ERROR SERV_VendorFollowDetails.jsp : "
		+ e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null)
		rs.close();
			if (stmt != null)
		stmt.close();
			if (conn != null)
		conn.close();
		} catch (SQLException ignore) {
		}
	}
%>