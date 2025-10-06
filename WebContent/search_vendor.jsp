<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.text.*" %>
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
    doString str = new doString();
	
	String searchVendor = doString.checkString(request.getParameter("search_vendor"));
	String venType = doString.checkString(request.getParameter("venType"));
	
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;


	try {

        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();
		stmt1 = conn.createStatement();
        //----=======================================----//


%>

<HTML>
<HEAD>
<TITLE>ร้านค้า</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<base target="_self">

<SCRIPT LANGUAGE="JavaScript">
<!--
	
function searchData() {
   document.forms[0].action = "<%=request.getContextPath()%>/search_vendor.jsp"; 
   document.forms[0].submit();
}

function setID(id) {
	if (window.opener.document.forms[0].i_vendor!=null) {
		window.opener.document.forms[0].i_vendor.value=id;
	} else if (window.opener.document.forms[0].ven_no!=null) {
		window.opener.document.forms[0].ven_no.value=id;
	}

	if (window.opener.refreshPage) {
		window.opener.refreshPage();
	}

	window.close();
}

//-->
</SCRIPT>

</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">
<input type="hidden" name="venType" value="<%=venType%>">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center" class="BD">
    

      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ค้นหาร้านค้า</td>
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
    <td height="22" class="item ; dotline01" width="10%"><nobr> ชื่อร้านค้า :</nobr></td>
    <td height="22" width="90%" class="dotline01"><input type="text" name="search_vendor" value="<%=doString.DisplayThai(searchVendor)%>" class="box">
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
				<td class="col_name" width="10%">รหัสร้านค้า</td>
				<td class="col_name" width="45%">ชื่อร้านค้า</td>
				<td class="col_name" width="45%">&nbsp;</td>
			  </tr>				
			<%

		 int line = 0;	
		  sql.delete(0,sql.length());
		  sql.append(" select * from lan:stpvendr ");
		  if (searchVendor.trim().length()>0) {
			  sql.append(" where lower(bus_name) like lower('%").append(searchVendor).append("%') ");
		  } else {
		  	sql.append(" where vend_code = 'zz'");
		  }
		  sql.append(" order by vend_code ");
		  rs = stmt.executeQuery(sql.toString());
		  while (rs.next()) {
			   String venId = doString.checkString(rs.getString("vend_code"),""); 
			   String venName = doString.checkString(rs.getString("bus_name"),""); 
			   venName = doString.DisplayThai(venName);
			   line++;
			   %>
			  <tr>
				<td class="item ; dotline" width="10%" align="center">&nbsp;<a href="javascript:setID('<%=venId%>');"><%=doString.checkString(venId,"")%></a></td>
				<td class="dotline" width="45%">&nbsp;<a href="javascript:setID('<%=venId%>');"><%=doString.checkString(venName,"")%></a></td>
				<td class="dotline" width="45%">&nbsp;</td>
			  </tr>			   
			   <%
		 } // end while
		 rs.close();		  

		 while (line<10) {
			 line++;
			   %>
			  <tr>
				<td class="item ; dotline" width="10%">&nbsp;</td>
				<td class="dotline" width="45%">&nbsp;</td>
				<td class="dotline" width="45%">&nbsp;</td>
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
			&nbsp;
            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:window.close();" target="_top"><img border="0" src="images/bu_close.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
	} catch (Exception e) {
		System.out.println("ERROR search_vendor.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (rs1 != null) rs.close();
			if (stmt != null) stmt.close();
			if (stmt1 != null) stmt.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>