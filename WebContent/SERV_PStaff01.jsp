<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.Constants" %>
<%@ page import="serv.util.ServLog" %>

<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>


<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_PStaff01.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

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
<TITLE>ข้อมูลพื้นฐาน : 04
รายละเอียดโครงการที่รับผิดชอบ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM method="post" action="">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ข้อมูลพื้นฐาน</td>
        </tr>
      </table>
<br style="font-size:10pt">
              
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">รายละเอียดโครงการที่รับผิดชอบ</td>
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
          <td class="col_name" width="10%">No.</td>
          <td class="col_name" width="10%">รหัสพนักงาน</td>
          <td class="col_name" width="60%">ชื่อพนักงาน</td>
          <td class="col_name" width="20%">ระดับ</td>
        </tr>
  <%
        //-----====================== Get SERV_PStaff Data =======================---//
        sql.delete(0,sql.length());
  		sql.append(" select * from lan:useracl a left join docflow:acemploy b ")
		     .append(" on b.i_employ=a.i_employ where  a.user_acl='S'  and a.user_who != 'J' ")
			 .append(" order by b.n_nemploy_th, b.i_employ, a.i_person ");
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		int line = 0;
		int i = 0;
		while (rs.next()) {
		    i++;
		
			String iEmploy = doString.checkString(rs.getString("i_employ"));		    
			String user_id = doString.checkString(doString.DisplayThai(rs.getString("user_id")));		    
			String preName = doString.checkString(doString.DisplayThai(rs.getString("n_prename_th")));		    
			String fName = doString.checkString(doString.DisplayThai(rs.getString("n_nemploy_th")));		    
			String lName = doString.checkString(doString.DisplayThai(rs.getString("n_semploy_th")));		    		    
			String userWho = doString.checkString(doString.DisplayThai(rs.getString("user_who")));		    
			
			if (userWho.length()>0) {
			    switch (userWho.charAt(0)) {
				   case 'A' : userWho += " - Admin"; break;
				   case 'C' : userWho += " - Center"; break;
				   case 'V' : 
				       userWho += " - Vendor"; 
					   iEmploy = doString.checkString(rs.getString("i_person"));		  
		  	           
					   sql.delete(0,sql.length());
   		  	           sql.append(" select * from lan:stpvendr where vend_code='").append(iEmploy).append("' order by vend_code, bus_name ");
					   servlog.startLog(sql.toString());
					   rs1 = stmt1.executeQuery(sql.toString());
					   servlog.endLog();
					   if (rs1.next()) {
			             preName = "";
			             fName = doString.checkString(doString.DisplayThai(rs1.getString("bus_name")));		    
			             lName = "";
					   }
					   rs1.close();

				   break;
				   case 'S' : userWho += " - Service Staff"; break;
				   case 'P' : userWho += " - VP"; break;
				   case 'Z' : userWho += " - Zone Manager"; break;
				   case 'M' : userWho += " - Manager Service"; break;
				}
			}
		
		    %>
				<tr>
		          <td align="center" class="dotline" width="10%"><%=i%>&nbsp;</td>
		          <td align="left" class="dotline" width="10%"><%=iEmploy%></td>
		          <td align="left" class="dotline" width="10%">
		          <a href="SERV_PStaff02.jsp?&user_id=<%=user_id%>&i_employ=<%=iEmploy%>">
		          <%=preName+fName%>&nbsp;<%=lName%></a></td>
		          <td align="left" class="dotline" width="10%"><%=userWho%></td>
		        </tr>	    
		   <%
		   
		    line++;
		}
		rs.close();				
		
		//----========= Fill up blank line if this page display data less than 12 line ========--//
		while (line<Constants.SERV_XSTD_LINE) {
	 %>
		<tr>
          <td align="center" class="dotline" width="10%">&nbsp;</td>
          <td align="center" class="dotline" width="10%">&nbsp;</td>
          <td align="center" class="dotline" width="10%">&nbsp;</td>
          <td align="center" class="dotline" width="10%">&nbsp;</td>
        </tr>		    
   <%
		    line++;
		}
        //-----=================================================================---//        
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
            <td class="act_tab4"><a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
  <br>ติชมแสดงความคิดเห็น : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a> &nbsp;หรือ Computer Department&nbsp; โทร
  0-2230-8490-98, 0-2230-8451-3  
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE> 
</FORM>

<%
  String error = doString.checkString(request.getParameter("error"),"");
  if (error.length()>0) {
     String msg = " พบปัญหาขณะลบข้อมูล!  กรุณาตรวจสอบข้อมูล และทำการลบใหม่อีกครั้ง";
     %><script>alert("<%=msg%>");</script><%
  }
%>

</BODY>

</HTML>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_PStaff01.jsp : " + e.getMessage());
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

