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
<%@ page import="serv.util.ServLog" %>

<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>


 
 
<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_UpdatePwdOutsource.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

	doString str = new doString();
	
String updateEmploy = request.getParameter("update_employ"); // ใช้เพื่อรับการอัปเดต
String message = ""; // ใช้เพื่อเก็บข้อความสถานะ

	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt2 = null;
	ResultSet rs = null;
	ResultSet rs2 = null;
	SERV_CommonData common = null;

	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();	
		stmt2 = conn.createStatement();	
		common = new SERV_CommonData(conn);
		
		//-------------------


%>

<%@page import="java.util.Date"%>
<HTML>
<HEAD>
<TITLE> อัพเดทรหัสผู้รับเหมา</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">

</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM name="frmDetail" method="post" action="">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >   
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
         อัพเดทรหัสผู้รับเหมา</td>
        </tr>
      </table>


<br style="font-size:10pt">
                
            
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">  อัพเดทรหัสผู้รับเหมา</td>
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
  <!-- 
  	ใส่ข้อมูล qury 
  	SELECT FIRST 1 i_employ, d_modify, d_modify + INTERVAL (3) MONTH TO MONTH AS expire
FROM lan:user_change
WHERE i_employ like 'S%'
AND TODAY >= d_modify + INTERVAL (3) MONTH TO MONTH;

ถ้าเจอให้ขึ้นว่าเจอข้อมูลแต่ถ้าไม่ให้แสดงว่าไม่มีข้อมูล
  
   -->
   <br style="font-size:2pt">
   <%
   sql.delete(0, sql.length());
   sql.append("SELECT FIRST 1 i_employ, d_modify, d_modify + 90 UNITS DAY AS expire,TODAY - (d_modify + 83 UNITS DAY) AS days_expired ")
                 .append("FROM lan:user_change ")
                 .append("WHERE (i_employ LIKE 'S%' OR i_employ LIKE '5%') ")
                 .append("");

rs = stmt.executeQuery(sql.toString());
int remind = 0;
String formattedDate = "";
String iEmploy = "";
if (rs.next()) {

		

       iEmploy = rs.getString("i_employ");
       String dModify = rs.getString("d_modify");
       String expire = rs.getString("expire");
       String days_expired  = rs.getString("days_expired");
       
       System.out.println(expire);
       
       
       SimpleDateFormat inputFormat = new SimpleDateFormat("yyyy-MM-dd");
       SimpleDateFormat outputFormat = new SimpleDateFormat("dd/MM/yyyy");
       Date date = inputFormat.parse(dModify);
            Calendar calendar = Calendar.getInstance();
            calendar.setTime(date);
            calendar.add(Calendar.YEAR, 543); // เพิ่ม 543 ปี ตามระบบพุทธศักราช
            formattedDate = outputFormat.format(calendar.getTime());
            
            // แปลง expireDate
            Date expire1 = inputFormat.parse(expire);
            calendar.setTime(expire1);
            calendar.add(Calendar.YEAR, 543);
            String formattedDate1 = outputFormat.format(calendar.getTime());
       
       remind =  Integer.parseInt(days_expired.trim());
       
	if(remind>7){
		out.println("<p>ข้อมูล: " + iEmploy + ", วันที่แก้ไข: " + formattedDate + ", รหัสหมดอายุมา: " + (remind-7) + " วันแล้ว </p>");
	}else if(remind == 7){
		out.println("<p>ข้อมูล: " + iEmploy + ", วันที่แก้ไข: " + formattedDate + " รหัสหมดอายุแล้ว </p>");
	}else{
		out.println("<span>วันที่แก้ไขล่าสุด: " + formattedDate + ", อีก: " + (7-remind)  + " วันรหัสจะหมดอายุ ("+formattedDate1+") </span> <br> <p>***password มีอายุ  90 วันหลังจาก Update***</p>");
	}
	
	
       if (updateEmploy != null && updateEmploy.equals(iEmploy)) {
           // ทำการอัปเดตวันที่แก้ไข
           String updateSql = "UPDATE lan:user_change SET d_modify = today WHERE (i_employ LIKE 'S%' OR i_employ LIKE '5%') ";
           int rowsUpdated = stmt.executeUpdate(updateSql);
           if (rowsUpdated > 0) {
            // ใช้ alert แทนการแสดงข้อความ
            out.println("<script>alert('อัปเดตสำเร็จ');</script>");
	        } else {
	            out.println("<script>alert('การอัปเดตล้มเหลว');</script>");
	        }
       }

       // สร้างปุ่มเพื่อกด update
       out.println("<input type='hidden' name='update_employ' value='" + iEmploy + "' />");
       out.println("<input type='submit' value='Update Password' />");
   } else {
    out.println("<p>**	ระบบจะแสดงปุ่มให้ Update  Password  ต้องหมดอายุแล้ว 90 วันเท่านั้น	**</p>");

}
    %>
   
   <br style="font-size:2pt">
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


<br style="font-size:2pt">


<br style="font-size:10pt">

        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="150" class="act_tab2">&nbsp;</td>
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="/LHServ/SERV_Index.jsp" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
	} catch (Exception e) {
		System.out.println("ERROR SERV_LckDetail.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
		if (rs != null)
		    rs.close();
		if (rs2 != null)
		    rs2.close();
		if (stmt != null)
		    stmt.close();
		if (stmt2 != null)
		    stmt2.close();
		if (conn != null)
		    conn.close();
		}
		catch( SQLException ignore ){}
	}
%>

