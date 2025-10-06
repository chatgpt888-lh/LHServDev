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

StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;
PreparedStatement prep = null;
ResultSet rs1 = null;
PreparedStatement prep1 = null;


String grp_no = "";
String grp_name = "";
String project = "";
String i_company = "";
String i_project = "";
String n_project = "";
String i_sort = "";	
String i_vendor = "";	


String ven_no = "";

try {

	if (ds == null)
		getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
    conn.setAutoCommit(true);
	stmt = conn.createStatement();
	
	grp_no = doString.checkString(request.getParameter("grp_no"),"");
	project = doString.checkString(request.getParameter("project"),"");
	i_sort = doString.checkString(request.getParameter("i_sort"),"");
	i_vendor = doString.checkString(request.getParameter("i_vendor"),"");
	
	if(!"".equals(project)){
		i_company = project.substring(0,2);
		i_project = project.substring(2,5);
		
		sql.delete(0,sql.length());
		sql.append(" select n_project from lan:acxprojt where i_company =  ?  and i_project = ? ");
		prep = conn.prepareStatement(sql.toString());
		prep.setString(1,i_company);
		prep.setString(2,i_project);
		rs = prep.executeQuery();
		if(rs.next()){
			n_project = doString.DisplayThai(rs.getString("n_project"));
		}
		rs.close();
		prep.close();
	}


	if(!"".equals(grp_no)){

		sql.delete(0,sql.length());
		sql.append(" select grp_desc from lan:itmgrp where grp_no =  ? ");
		prep = conn.prepareStatement(sql.toString());
		prep.setString(1,grp_no);
		rs = prep.executeQuery();
		if(rs.next()){
			grp_name = doString.DisplayThai(rs.getString("grp_desc"));
		}
		rs.close();
		prep.close();
	}
%>

<HTML>
	<HEAD>
		<TITLE>รายงานวันหมดอายุประกันวัสดุ</TITLE>
		<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
		<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
		<link rel="stylesheet" href="<%=request.getContextPath()%>/js/font-awesome-4.7.0/css/font-awesome.css"  type="text/css">
		<style type="text/css" >
		button {
		    padding: 2px 3px;
		    font-size: x-small;
		    background-color: #ffffff;
		    border: 1px #ccc solid;
		    border-radius: 2px;
		    cursor: pointer;
		}
		</style>
		<script language="javascript">
		<!--
		
		//-->
		</script>

		<base target="_self">
	</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM name="frmServ" method="GET" action="<%=request.getContextPath()%>/SERV_ReportItmPO.jsp">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="800" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
           รายการใบสั่งซื้อ</td>
        </tr>
      </table>
		<br style="font-size:10pt">
                 

<br style="font-size:2pt">
<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">รายการ</td>
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
        <tr style="height:22px;">
          <td class="col_name" width="5%">ลำดับ</td>
          <td class="col_name" width="14%">วัสดุ</td>
          <td class="col_name" width="14%">ร้านค้า</td>
          <td class="col_name" width="8%">เลขที่ใบสั่งซื้อ</td>
          <td class="col_name" width="20%">ประเภท/รายละเอียด</td>
          <td class="col_name" width="5%">แปลง</td>
          <td class="col_name" width="8%">วันที่ PO</td>
          <td class="col_name" width="8%">วันที่ร้านค้า</td>
          <td class="col_name" width="8%">วันที่ FM</td>
          <td class="col_name" width="8%">วันที่ PJ</td>
        </tr>
        <%
        if(!"".equals(project)){
        	int idx = 0;
        	int row = 0;
        	
        	String itm_name = "";
        	String ven_name = "";
           	String i_pr_type = "";
           	String i_remark = "";
        	
    		
    		idx = 0;
       		sql.delete(0,sql.length());
       		sql.append("	select a.*,b.i_pr_type , b.i_remark ")
       		.append("		from ")
       		.append("			lan:accpohdr a left join lan:pr_dochd b ")
       		.append("			on a.i_order = b.po_docno ")
       		.append("			and a.i_company = b.i_company ")
       		.append("			and a.i_project = b.i_project ")
       		.append("			and a.grp_no = b.grp_no ")
       		.append("			and a.i_lock = b.i_lock ")
       		.append("		where ")
       		.append("			a.i_company = ? ")
       		.append("			and a.i_project = ? ")
       		.append("			and a.grp_no = ? ")
       		.append("			and a.i_lock = ? ")
       		.append("			and a.f_status = 'OPN' ")
       		//.append("			and (b.i_pr_type is null or b.i_pr_type = '212') ")
       		.append("		order by ")
       		.append("			i_company , ")
       		.append("			i_project , ")
       		.append("			d_order ");
    		System.out.println(sql.toString());
    		prep = conn.prepareStatement(sql.toString());
    		prep.setString(++idx,i_company);
    		prep.setString(++idx,i_project);
    		prep.setString(++idx,grp_no);
    		prep.setString(++idx,i_sort);
    		rs = prep.executeQuery();
    		while(rs.next()){
    		
    			idx = 0;
       			ven_name = "";
               	sql.delete(0,sql.length());
           		sql.append("select ven_name from lan:vendor where ven_no = ? ");
           		//System.out.println(sql.toString());
           		prep1 = conn.prepareStatement(sql.toString());
           		prep1.setString(++idx,doString.checkString(rs.getString("i_vendor"),""));
           		rs1 = prep1.executeQuery();
           		if(rs1.next()){
           			ven_name = doString.checkString(rs1.getString("ven_name"),"");
           		}
           		rs1.close();
           		prep1.close();
                			
           		i_pr_type = doString.checkString(rs.getString("i_pr_type"),"");
           		i_remark = doString.DisplayThai(doString.checkString(rs.getString("i_remark"),""));
       %>
            <tr>
                <td class="dotline" align="center"><%=(++row)%></td>
                <td class="dotline" align="left"><%= grp_no + " - " + grp_name%></td>
                <td class="dotline" align="left"><%=doString.DisplayThai(ven_name)%></td>
                <td class="dotline" align="center"><a href="<%=request.getContextPath()%>/SERV_PODetail.jsp?i_order=<%=doString.checkString(rs.getString("i_order"),"")%>" ><%=doString.checkString(rs.getString("i_order"),"")%></td>
                <% if("".equals(i_pr_type)){ %>
                <td class="dotline"  align="left">ใบสั่งซื้อหลัก</td>
                <% }else if("151".equals(i_pr_type)){ %>
                <td class="dotline"  align="left"><%=(i_remark)%></td>
                <% }else if("212".equals(i_pr_type)){ %>
                <td class="dotline"  align="left"><%=(i_remark)%></td>
                <% }else{ %>
                <td class="dotline"  align="left"><%=(i_remark)%></td>
                <% } %><td class="dotline" align="center"><%=doString.checkString(rs.getString("i_lock"),"")%></td>
                
                <td class="dotline" align="center"><%=DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString("d_order"),""))%></td>
                <td class="dotline" align="center"><%=DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString("vendor_fsend_date"),""))%></td>
                <td class="dotline" align="center"><%=DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString("user_rec_date"),""))%></td>
                <td class="dotline" align="center"><%=DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString("user_confp_date"),""))%></td>
            </tr>
        <%  } 
    		rs.close();
    	
        }else{
        %>
            <tr>
                <td class="dotline"  align="center">&nbsp;</td>
                <td class="dotline"  align="center">&nbsp;</td>
                <td class="dotline"  align="center">&nbsp;</td>
                <td class="dotline"  align="center">&nbsp;</td>
                <td class="dotline"  align="center">&nbsp;</td>
                <td class="dotline"  align="center">&nbsp;</td>
                <td class="dotline"  align="center">&nbsp;</td>
                <td class="dotline"  align="center">&nbsp;</td>
                <td class="dotline"  align="center">&nbsp;</td>
                <td class="dotline"  align="center">&nbsp;</td>
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
            <td width="150" class="act_tab2">&nbsp;
            </td>
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:window.history.back()" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>   
        </table>  
          </td>
        </tr>
      </table>
	</FORM>
</BODY>
</HTML>

<%
	stmt.close();
	conn.close();
	stmt = null;
	conn = null;
	} catch (Exception e) {
		System.out.println("ERROR SERV_ReportItmPO.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (stmt != null) stmt.close();
			if (rs1 != null) rs1.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>
