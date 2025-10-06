<%@page contentType="text/html; charset=TIS-620"%>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ include file="PleaseWaiting.jsp" %>
<%!
	// Caching the DataSource - It is obtained in the jspInit() method
	private javax.sql.DataSource ds = null;
	private String subcontext = "java:comp/env";
	private void getDS() throws Exception {
		String dsName = "";
		Context ctx = new InitialContext();
		InitialContext initCtx = new InitialContext();
	
		// Perform a naming service lookup to get the DataSource object.
		Context env = (Context)ctx.lookup(subcontext);
		dsName = (String)env.lookup("DATASOURCE_NAME");
		dsName = subcontext + "/" + dsName;
		ds = (javax.sql.DataSource) initCtx.lookup(dsName);
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
   doString str = new doString();
	//---------------------- Variable --------------------
    String beg_month = doString.checkString(request.getParameter("beg_month"),"0");
    String beg_year = doString.checkString(request.getParameter("beg_year"),"0");
    String end_month = doString.checkString(request.getParameter("end_month"),"0");
    String end_year = doString.checkString(request.getParameter("end_year"),"0");    
    String begDate = beg_year+"-"+beg_month+"-01";
    String endDate = end_year+"-"+end_month+"-01";
    String comId = doString.checkString(request.getParameter("comId"));    
    String projId = doString.checkString(request.getParameter("projId"));    
    String status = doString.checkString(request.getParameter("status"));    
    String status_restrict = "";
	String caption = "";
    if (status.equals("F")) {
		caption = "จัดเก็บได้";
    	status_restrict = " AND (i_doc_status = 'F' OR i_doc_status = 'P')";
    } else {
		caption = "ยังไม่จัดเก็บ";
    	status_restrict = " AND i_doc_status NOT IN ('F', 'P', 'C')";
    }
	//------------------------------------------------------
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
		
		//---=========== Month Initilize =========----//
		String thaiMonth[] = new String[] {"","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
		String showBegMonth = thaiMonth[Integer.parseInt(beg_month)];
		String showBegYear = Integer.toString(Integer.parseInt(beg_year)+543);
		String showEndMonth = thaiMonth[Integer.parseInt(end_month)];
		String showEndYear = Integer.toString(Integer.parseInt(end_year)+543);		
%>

<HTML>
<HEAD>
<TITLE>สรุปการจัดเก็บค่าบริการสาธารณะแยกตามช่วงเวลา</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript" src="jquery3/jquery-1.10.2.js"></script>
<base target="_self">

<script language="javascript">
<!--
function onPleaseWait() {
	document.all.pleasewaitScreen.style.pixelTop = (document.body.scrollTop + 120);
	$('#pleasewaitScreen').show();
	$('#pleasewaitScreen').css('visibility', 'visible');
}

function offPleaseWait() {
	$('#pleasewaitScreen').css('visibility', 'hidden');
}

//-->
</script>
</HEAD>
<script language="JavaScript">
<!--
onPleaseWait();
//-->
</script>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="offPleaseWait();">

<FORM NAME = "frmRep" ACTION="SERV_InfPayRpt1_2.jsp" METHOD="POST">
<input type="hidden" name="beg_month" value="<%=beg_month%>">
<input type="hidden" name="beg_year" value="<%=beg_year%>">
<input type="hidden" name="end_month" value="<%=end_month%>">
<input type="hidden" name="end_year" value="<%=end_year%>">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp; 
สรุปการจัดเก็บค่าบริการสาธารณะแยกตามช่วงเวลา (<%=caption%>)</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                
          <td class="item_tab2" width="200">รายละเอียดเดือน/ปีที่ระบุ</td>
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
    <td class="item ; dotline01" height="22">
	ตั้งแต่เดือน : <%=showBegMonth%> &nbsp; พ.ศ. <%=showBegYear%> &nbsp;ถึงเดือน : <%=showEndMonth%> &nbsp; พ.ศ. <%=showEndYear%>
	 </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22">โครงการ :&nbsp;
<%
		rs = stmt.executeQuery("SELECT n_project FROM lan:acxprojt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
		if (rs != null) {
			if (rs.next() == true) {
				out.print(doString.DisplayThai(rs.getString("N_PROJECT")));
			}
			rs.close();
			rs=null;
		}
%>    
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
                
          <td class="item_tab2" width="280">รายละเอียดการจัดเก็บค่าบริการสาธารณะ</td>
                <td class="item_tab3">
				</td>                
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


			  <!-----------------------------------HEADER TABLE ------------------------------>
              <tr> 
                <td width="10%" height="1" class="col_name">เลขที่เอกสาร</td>
                <td width="5%" align="center" valign="middle" class="col_name">แปลง</td>
                <td width="5%" align="center" valign="middle" class="col_name">บ้านเลขที่</td>
                <td width="8%" align="center" valign="middle" class="col_name">วันที่โอน</td>
				<td width="7%" align="center" valign="middle" class="col_name">พื้นที่</td>
                <td width="20%" align="center" valign="middle" class="col_name">ชื่อลูกค้า</td>                
                <td width="20%" align="center" valign="middle" class="col_name">ช่วงเดือน</td>
                <td width="10%" align="center" valign="middle" class="col_name">จำนวนเงิน</td>
                <td width="7%" align="center" valign="middle" class="col_name">เลขที่ใบเสร็จ</td>
                <td width="8%" align="center" valign="middle" class="col_name">วันที่ PayIn</td>
              </tr>
			  <!---------------------------------------------------------------------------------------------->
<% 
			int line=0;
			String bgcolor = "";
			String docNo = "";
			String lockId = "";
			String receiptNo = "";
			String payDate = "";
			String clsDate = "";
			double payAmnt = 0;
			double totAmnt = 0;
			double area = 0;
			
			rs = stmt.executeQuery("SELECT i_docno, i_company, i_sort, i_house, n_custo, d_start, d_end, NVL(z_payin_infra,0) AS REQ_AMNT, NVL(z_recv_infra,0) AS REC_AMNT FROM lan:serv_infhd WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND d_start >= '"+begDate+"' AND d_end <= '"+endDate+"' "+status_restrict+" ORDER BY i_sort, d_start, d_end");
			if (rs != null) {
				while (rs.next() == true) {
					line++;
					bgcolor = ((line%2) == 0) ? "FAFAFA" : "FFFFFF";
					comId = doString.checkString(rs.getString("I_COMPANY"));
					docNo = doString.checkString(rs.getString("I_DOCNO"));
					lockId = doString.checkString(rs.getString("I_SORT"));
					begDate = doString.checkString(rs.getString("D_START"));
					endDate = doString.checkString(rs.getString("D_END"));	
					clsDate = "";
					rs1 = stmt1.executeQuery("SELECT d_close_law FROM lan:acscontr WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_sort = '"+lockId+"' AND f_contr IS NULL AND d_close_law IS NOT NULL");
					if (rs1 != null) {
						if (rs1.next() == true) {
							clsDate = DateUtil.ifxToThaiDateNoTime(doString.checkString(rs1.getString(1)));
						}
						rs1.close();
						rs1=null;
					}		
					area = 0;					
					rs1 = stmt1.executeQuery("SELECT NVL(q_area,0) FROM lan:serv_inflck WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_sort = '"+lockId+"'");
					if (rs1 != null) {
						if (rs1.next() == true) {
							area = rs1.getDouble(1);
						}
						rs1.close();
						rs1=null;
					}											
					receiptNo = "-1";
					rs1 = stmt1.executeQuery("SELECT i_receipt FROM lan:serv_payin WHERE i_docno = '"+docNo+"'");
					if (rs1 != null) {
						if (rs1.next() == true) {
							receiptNo = doString.checkString(rs1.getString("I_RECEIPT"),"-1");
						}
						rs1.close();
						rs1=null;
					}
					payDate = "&nbsp;";
					rs1 = stmt1.executeQuery("SELECT d_payin FROM lan:acrdtrec WHERE i_com_recv = '"+comId+"' AND i_receipt = "+receiptNo);
					if (rs1 != null) {
						if (rs1.next() == true) {
							payDate = doString.checkString(rs1.getString("D_PAYIN"));
							payDate = DateUtil.ifxToThaiDate(payDate);
						}
						rs1.close();
						rs1=null;
					}
					if (receiptNo.equals("-1")) {
						receiptNo = "&nbsp;";
					}
					payAmnt = 0;
					if (status.equals("F")) {
						payAmnt = rs.getDouble("REC_AMNT");	
					} else {
						payAmnt = rs.getDouble("REQ_AMNT");	
					}
					totAmnt += payAmnt;
					
%>
			<tr bgcolor="#<%=bgcolor%>">
			 <td width="10%" height="1" align="center" class="item ; dotline"><%=docNo%></td>
			 <td width="5%" align="center" valign="middle" class="dotline"><%=lockId%></td>			 
			 <td width="5%" align="center" valign="middle" class="dotline"><%=doString.checkString(rs.getString("I_HOUSE"),"&nbsp;")%></td>			 
			 <td width="8%" align="center" valign="middle" class="dotline"><%=clsDate%>&nbsp;</td>
			 <td width="7%" align="center" valign="middle" class="dotline"><%=doString.displayNumber("0.00", area)%></td>
			 <td width="20%" align="left" valign="middle" class="dotline"><%=doString.DisplayThai(rs.getString("N_CUSTO"))%></td>			 			 
			 <td width="20%" align="center" valign="middle" class="dotline"><%=Period.getBetween(begDate, endDate)%></td>			 
			 <td width="10%" align="right" valign="middle" class="dotline"><%=doString.displayNumber("###,###,###.00", payAmnt)%></td>			 
			 <td width="7%" align="center" valign="middle" class="dotline"><%=receiptNo%></td>			 
			 <td width="8%" align="center" valign="middle" class="dotline"><%=payDate%></td>			 
			 </tr>
<%					
				}// end while
				rs.close();
				rs=null;
			}
			line++;
			bgcolor = ((line%2) == 0) ? "FAFAFA" : "FFFFFF";
%>			
			<tr bgcolor="#<%=bgcolor%>">
			 <td width="10%" height="1" align="right" class="item ; dotline">รวม</td>
			 <td width="5%" align="right" valign="middle" class="dotline">&nbsp;</td>			 
			 <td width="5%" align="right" valign="middle" class="dotline">&nbsp;</td>			 
			 <td width="8%" align="right" valign="middle" class="dotline">&nbsp;</td>			 
			<td width="7%" align="right" valign="middle" class="dotline">&nbsp;</td>			 			 
			 <td width="20%" align="right" valign="middle" class="dotline">&nbsp;</td>			 
			 <td width="20%" align="right" valign="middle" class="dotline">&nbsp;</td>
			 <td width="10%" align="right" valign="middle" class="dotline"><%=doString.displayNumber("###,###,###,###.00", totAmnt)%></td>			 
			 <td width="7%" align="right" valign="middle" class="dotline">&nbsp;</td>			 
			 <td width="8%" align="right" valign="middle" class="dotline">&nbsp;</td>			 
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




<br style="font-size:3pt">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="left">&nbsp;</td>
	</tr>
	</table>
<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="80" class="act_tab2">&nbsp;</td> 	
            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="javascript:history.back()"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
		System.out.println("ERROR SERV_InfPayRpt1_2.jsp : " + e.getMessage());
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