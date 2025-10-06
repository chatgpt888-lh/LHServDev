<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ include file="confirmLogin.jsp" %>
<%!
	// Caching the DataSource - It is obtained in the jspInit() method
	private javax.sql.DataSource ds = null;
	private String dsName = Constants.JDBC_LAN;
	private String month[] = {"มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
	private void getDS() throws NamingException {
		// Note the new Initial Context Factory interface available in WebSphere 4.0
		Hashtable parms = new Hashtable();
		parms.put(Context.INITIAL_CONTEXT_FACTORY, "com.ibm.websphere.naming.WsnInitialContextFactory");
		InitialContext ctx = new InitialContext(parms);

		// Perform a naming service lookup to get the DataSource object.
		ds = (javax.sql.DataSource) ctx.lookup(dsName);
		ctx.close();

	}	
	
	// This Happens Once and is Reused
	public void jspInit() {
		try
		{
			getDS();
		}
		catch(Exception es)
		{
		  es.printStackTrace();
		}
	}
	

	
%>
<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String empId = user.getEmpId();

String comId = "LH";
String projId = "ALL";
String code = "";
if (!doString.checkString(request.getParameter("Project")).equals("")) {
	comId = request.getParameter("Project").substring(0,2);
	projId = request.getParameter("Project").substring(2);
}
code = comId + projId;
Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
Statement ustmt = null;
ResultSet rs = null;
ResultSet rsChkup = null;
try {
	if (ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	
	
%>
<HTML>
<HEAD>
<TITLE>LH Vender</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<LINK rel="StyleSheet" href="LINE_SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">



<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            LH Vender</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">ระบุรายละเอียด</td>
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
    <td class="item ; dotline01" height="22">Station :</td>
    <td height="22" class="dotline01"><select name="select2" size="1" class="box" style="width:200px">
      <option>Station 1</option>
      <option>Station 2</option>
      <option>Station 3</option>
    </select></td>
    <td height="22" class="item ; dotline01">โครงการ :</td>
    <td height="22" class="dotline01"><select name="select3" size="1" class="box" style="width:200px">
      <option>LH071 | ปาริชาต-ปิ่นเกล้า</option>
    </select></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="15%">บ้านเลขที่
      :</td>
    <td height="22" width="39%" class="dotline01"><input type="text" name="T1" class="box" style="width:100px"></td>
    <td height="22" class="item ; dotline01" width="14%">แปลง :</td>
    <td height="22" width="32%" class="dotline01"> <input type="text" name="T1" class="box" style="width:100px">&nbsp;&nbsp;&nbsp;&nbsp;</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22">วันที่นัดซ่อม :</td>
    <td height="22" class="dotline01">
	
		<input name="text3" type="text" class="boxC" style="width:80px" value="dd/mm/yyyy">&nbsp;&nbsp;<img src="images/i_calendar.gif" width="18" height="18" align="absmiddle"  style="cursor:hand" onClick="MM_openBrWindow('LINE_SERV_Calendar.html','Calendar','status=yes,width=700,height=320')">

          &nbsp; &nbsp; ถึง : &nbsp; &nbsp;       

<input name="text3" type="text" class="boxC" style="width:80px" value="dd/mm/yyyy">&nbsp;&nbsp;<img src="images/i_calendar.gif" width="18" height="18" align="absmiddle"  style="cursor:hand" onClick="MM_openBrWindow('LINE_SERV_Calendar.html','Calendar','status=yes,width=700,height=320')">
	  
	</td>
    <td height="22" class="item ; dotline01">สถานะ :</td>
    <td height="22" class="dotline01"><select name="select" size="1" class="box" style="width:200px">
      <option>ทุกสถานะ</option>
      <option>Check in</option>
    </select>
      <img border="0" src="images/i_search.gif" align="absmiddle" width="20" height="20"></td>
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
                <td class="item_tab2" width="200">รายการที่ค้นได้</td>
                <td class="item_tab3"></td>
                <td></td>
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
          <td class="col_name">วันที่</td>
          <td class="col_name">เวลานัด</td>
          <td class="col_name">บ้านเลขที่</td>
          <td class="col_name">แปลง</td>
          <td class="col_name">ชื่อลูกค้า</td>
          <td class="col_name">โทร</td>
          <td class="col_name">สถานะ</td>
          <td class="col_name">Ref_no</td>
          <td class="col_name">เลขที่ใบแจ้งซ่อม</td>
          <td class="col_name">ผู้บันทึกนัด</td>
        </tr>
        <tr>
          <td align="center" class="dotline">20/02/2563</td>
          <td align="center" class="dotline">10:00</td>
			<td align="center" class="dotline ; item"><a href="LINE_SERV_List.html">299/855</a></td>
          <td class="dotline" align="center">01G10</td>
          <td class="dotline">นายสมชาย ใจซื่อ</td>
          <td align="center" class="dotline">0895855555</td>
          <td align="center" class="dotline">Checkin (100)</td>
          <td class="dotline" align="center">62001</td>
          <td align="center" class="dotline">LH-195-6300002</td>
          <td align="center" class="dotline">&nbsp;</td>
        </tr>
        <tr>
          <td align="center" class="dotline">20/02/2563</td>
          <td align="center" class="dotline">11:00</td>
			<td align="center" class="dotline ; item"><a href="LINE_SERV_List.html">299/672</a></td>
          <td class="dotline" align="center">01M10</td>
          <td class="dotline">นางใจดี สมหญิง</td>
          <td align="center" class="dotline">0814441115</td>
          <td align="center" class="dotline">เข้าซ่อม (200)</td>
          <td class="dotline" align="center">62002</td>
          <td align="center" class="dotline">LH-195-6300045</td>
          <td align="center" class="dotline">&nbsp;</td>
        </tr>
        <tr>
          <td align="center" class="dotline">&nbsp;</td>
          <td align="center" class="dotline">&nbsp;</td>
          <td align="center" class="dotline ; item">&nbsp;</td>
          <td class="dotline" align="center">&nbsp;</td>
          <td class="dotline">&nbsp;</td>
          <td align="center" class="dotline">&nbsp;</td>
          <td align="center" class="dotline">&nbsp;</td>
          <td class="dotline" align="center">&nbsp;</td>
          <td align="center" class="dotline">&nbsp;</td>
          <td align="center" class="dotline">&nbsp;</td>
        </tr>
        <tr>
          <td align="center" class="dotline">&nbsp;</td>
          <td align="center" class="dotline">&nbsp;</td>
          <td align="center" class="dotline ; item">&nbsp;</td>
          <td class="dotline" align="center">&nbsp;</td>
          <td class="dotline">&nbsp;</td>
          <td align="center" class="dotline">&nbsp;</td>
          <td align="center" class="dotline">&nbsp;</td>
          <td class="dotline" align="center">&nbsp;</td>
          <td align="center" class="dotline">&nbsp;</td>
          <td align="center" class="dotline">&nbsp;</td>
        </tr>
        <tr>
          <td align="center" class="dotline">&nbsp;</td>
          <td align="center" class="dotline">&nbsp;</td>
          <td align="center" class="dotline ; item">&nbsp;</td>
          <td class="dotline" align="center">&nbsp;</td>
          <td class="dotline">&nbsp;</td>
          <td align="center" class="dotline">&nbsp;</td>
          <td align="center" class="dotline">&nbsp;</td>
          <td class="dotline" align="center">&nbsp;</td>
          <td align="center" class="dotline">&nbsp;</td>
          <td align="center" class="dotline">&nbsp;</td>
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



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">&nbsp;</td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:history.back()" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="SERV_Home.html"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>  
        </table>  






          </td>
        </tr>
      </table>

			
<br style="font-size:30pt">
	
	
	
<script language="JavaScript" type="text/JavaScript" src="LINE_SERV_Copyright.js"></script>
<script language="JavaScript" type="text/JavaScript">
writeCopyright();
</script> 
	
</BODY>

</HTML>
<%
		stmt.close();
		conn.close();
		stmt = null;
		conn=null;
	} catch (Exception e) {
		System.out.println("ERROR LINE_SERV_Detail.jsp : " + e.getMessage());
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
