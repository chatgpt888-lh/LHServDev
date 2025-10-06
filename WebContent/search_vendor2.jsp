<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.*" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.*" %>
<%@ include file="function.jsp" %>
<%@ include file="confirmLogin.jsp" %>
<%
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;

	String project = "";
	String search_vendor = "";
	try {

        //----============ Initialize Variable ============----//
		if(ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();

		project = doString.checkString(request.getParameter("project"),"");
		search_vendor = doString.checkString(request.getParameter("search_vendor"),"");
%>

<HTML>
<HEAD>
<TITLE>ค้นหาผู้รับเหมา/ร้านค้า</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<base target="_self">
<SCRIPT LANGUAGE="JavaScript">
<!--
function initPage(){
<% if("".equals(project)){ %>
	window.close();
<% } %>
}
function searchData() {
   document.forms[0].action = "/LHServ/search_vendor2.jsp"; 
   document.forms[0].submit();
}

function setID(id,name) {
	if (window.opener.document.forms[0].i_vendor != null) {
		window.opener.document.forms[0].i_vendor.value=id;
	}
	if (window.opener.document.forms[0].n_vendor != null) {
		window.opener.document.forms[0].n_vendor.value=name;
	}
	window.close();
}
//-->
</SCRIPT>
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="initPage()">
<FORM METHOD="POST" ACTION="search_vendor2.jsp" name="frmServ">
<input type="hidden" name="project" value="<%=project%>" />
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center" class="BD">
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;ค้นหาผู้รับเหมา</td>
          <td width="30%" align="right">
          </td>
        </tr>
      </table>
<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">รายละเอียด</td>
                <td class="item_tab3"></td>
                <td >&nbsp;</td>
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
    <td height="22" class="item ; dotline01" width="10%"><nobr> ชื่อผู้รับเหมา :</nobr></td>
    <td height="22" width="90%" class="dotline01"><input type="text" name="search_vendor" value="<%=doString.DisplayThai(search_vendor)%>" class="box">
	&nbsp;&nbsp;<a href="#"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22" onclick="searchData();"></a>	
	</td>
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
				<td class="col_name" width="20%">รหัสผู้รับเหมา</td>
				<td class="col_name" width="80%">ชื่อผู้รับเหมา</td>
			  </tr>		
			  <%
				if(!"".equals(project)){
			  	  	int count = 0;
			  	  	
				  	sql.delete(0,sql.length());
				  	sql.append(" select distinct a.i_vendor , b.ven_name from lan:serv_venprj a , lan:vendor b  ")
					  	.append(" where a.i_company = '"+project.substring(0,2)+"' ")
					  	.append(" and a.i_project = '"+project.substring(2)+"' ")
					  	.append(" and a.i_type = '09' ")
					  	.append(" and a.i_vendor = b.ven_no ");
				  	if(!"".equals(search_vendor)){
						sql.append(" and b.ven_name like '%"+doString.UnicodeToMS874(search_vendor)+"%' ");
					}
					sql.append(" order by 1 ");
					rs = stmt.executeQuery(sql.toString());
				    while(rs.next()){
				  		++count;
				%>
				<tr>
					<td class="item ; dotline" width="20%" align="center"><a href="javascript:setID('<%=doString.checkString(rs.getString("i_vendor"),"")%>','<%=doString.DisplayThai(doString.checkString(rs.getString("ven_name"),""))%>')" >
					<%=doString.checkString(rs.getString("i_vendor"),"")%>
					</a></td>
					<td class="dotline" width="80%" align="center">
					<a href="javascript:setID('<%=doString.checkString(rs.getString("i_vendor"),"")%>','<%=doString.DisplayThai(doString.checkString(rs.getString("ven_name"),""))%>')" >
					<%=doString.DisplayThai(doString.checkString(rs.getString("ven_name"),""))%>
					</a></td>
				</tr>
				<%
				    }
					rs.close();
					if(count == 0){
				%>
				<tr>
					<td class="item ; dotline" width="20%" align="center">&nbsp;</td>
					<td class="dotline" width="80%" align="center">ไม่พบข้อมูล</td>
				</tr>
				<%
					}
				}else{
				%>	
				<tr>
					<td class="item ; dotline" width="20%" align="center">&nbsp;</td>
					<td class="dotline" width="80%" align="center">ไม่พบข้อมูล</td>
				</tr>		
			  <% } %>	   
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
            <td width="75" class="act_tab2">&nbsp;</td>   
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:window.close();" target="_top"><img border="0" src="images/bu_close.gif" align="absmiddle" width="50" height="15"></a>
             </td>  
          </tr>  
        </table>  
          </td>
        </tr>
      </table>
</FORM>
</BODY>
</HTML>

<%
	if (rs != null){
		rs.close();
	}
	rs = null;
	stmt.close();
	stmt = null;
	conn.close();
	conn = null;
	
	} catch (Exception e) {
		e.printStackTrace();
		System.out.println("ERROR search_vendor2.jsp : " + e.getMessage());
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