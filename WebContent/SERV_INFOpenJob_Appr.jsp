<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.Constants" %>
<%@ include file="function.jsp" %>
<%
String docNo = doString.checkString(request.getParameter("docNo"));
String chartGrp = doString.checkString(request.getParameter("chartGrp"));
String mail = doString.checkString(request.getParameter("mail"));
%>
<HTML>
<HEAD>
<TITLE>Approve Job</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

  
<!-- add by pradoem 2023.02.15 -->
<script src="jquery3/jquery.min3.6.3.js" ></script>
<script src="jquery3/loadingoverlay.min2.1.7.js"></script>


<base target="_self">
<script language="javascript">
<!--

  function Approve(status) {
  	pleaseWaiting();
  	frmApprJob.status.value = status;
  	frmApprJob.submit();
  }
  
  function pleaseWaiting(){
	   $.LoadingOverlay("show");
		// Hide it after 3 seconds
		setTimeout(function(){
		    $.LoadingOverlay("hide");
		}, 7000);
	}

//-->
</script>
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM NAME="frmApprJob" METHOD=POST ACTION="/LHServ/ApprInfJobServlet">
<input type="hidden" name="docNo" value="<%=docNo%>">
<input type="hidden" name="status" value="">
<input type="hidden" name="chartGrp" value="<%=chartGrp%>">
<input type="hidden" name="mail" value="<%=mail%>">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
            <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp; 
              ใบสั่งงานซ่อมสาธารณูฯ</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>
<br style="font-size:10pt">
<%
boolean approve = false;
StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
Statement dstmt = null;
ResultSet rs = null;
ResultSet rsDetl = null;
try {
	if (ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();	
	dstmt = conn.createStatement();	
	String userId = "";
	String empId = "";
	String sender = "";
	String comId = "";
	String projId = "";
	String site = "";
	String keyinDate = "-";
	Calendar keyin = Calendar.getInstance();
	String appDate = "";
	String closeDate = "";
	String apprId = "";
	String approver = "";
	chartGrp = "";
	rs = stmt.executeQuery("SELECT * FROM lan:serv_infdochd WHERE i_docno = '"+docNo+"'");
	if (rs != null) {
		if (rs.next() == true) {
			empId = doString.checkString(rs.getString("i_service_employ"));
			comId = doString.checkString(rs.getString("i_company"));
			projId = doString.checkString(rs.getString("i_project"));						
			keyinDate = "-";
			Timestamp tmp = rs.getTimestamp("D_KEYIN");
			if (tmp != null) {
				keyin.setTime(tmp);      
				keyinDate = getDateFromCalendar(keyin);    
				keyinDate += "&nbsp;&nbsp;"+getTimeFromCalendar(keyin)+" น.";    		            
			}			
			appDate = DateUtil.ifxToThaiDateNoTime(rs.getString("D_APPOINT"));
			closeDate = DateUtil.ifxToThaiDateNoTime(rs.getString("D_EST_CLOSE"));
			apprId = doString.checkString(rs.getString("i_approver"));	
			chartGrp = doString.checkString(rs.getString("i_chart"));
		}
		rs.close();
		rs=null;
	}
	if (chartGrp.equals("M")) {
		chartGrp = "Service Manager";
	} else if (chartGrp.equals("Z")) {
		chartGrp = "Zone Manager";
	}
	rs = stmt.executeQuery("SELECT TRIM(n_prename_th) || ' ' || TRIM(n_nemploy_th) || ' ' || TRIM(n_semploy_th) AS EMP_NAME FROM docflow:acemploy WHERE i_employ = '"+empId+"'");
	if (rs != null) {
		if (rs.next() == true) {
			sender = doString.DisplayThai(rs.getString("EMP_NAME"));
		}
		rs.close();
		rs=null;
	}
	rs = stmt.executeQuery("SELECT TRIM(n_prename_th) || ' ' || TRIM(n_nemploy_th) || ' ' || TRIM(n_semploy_th) AS EMP_NAME FROM docflow:acemploy WHERE i_employ = '"+apprId+"'");
	if (rs != null) {
		if (rs.next() == true) {
			approver = doString.DisplayThai(rs.getString("EMP_NAME"));
		}
		rs.close();
		rs=null;
	}	
	rs = stmt.executeQuery("SELECT user_id FROM docflow:useracl WHERE i_employ = '"+apprId+"'");
	if (rs != null) {
		if (rs.next() == true) {
			userId = doString.checkString(rs.getString("USER_ID"));
		}
		rs.close();
		rs=null;
	}	
	rs = stmt.executeQuery("SELECT f_approve FROM lan:serv_infdocap WHERE i_docno = '"+docNo+"' AND i_approver = '"+apprId+"' AND f_approve = 'W'");
	if (rs != null) {
		if (rs.next() == true) {
			if (doString.checkString(rs.getString(1)).equals("W") ) {
				approve = true;
			}
		}
		rs.close();
		rs=null;
	}
	
	
	rs = stmt.executeQuery("SELECT n_project FROM lan:acxprojt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
	if (rs != null) {
		if (rs.next() == true) {
			site = doString.DisplayThai(rs.getString("N_PROJECT"));
		}
		rs.close();
		rs=null;
	}
%>
			<input type="hidden" name="apprId" value="<%=apprId%>">
			<input type="hidden" name="userId" value="<%=userId%>">			
			<input type="hidden" name="selProj" value="<%=comId%>:<%=projId%>">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                
            <td class="item_tab2" width="200">รายละเอียดการสั่งงานซ่อม</td>
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
                  <td class="item ; dotline01" height="22" width="13%">โครงการ 
                    :</td>
                  <td height="22" width="39%" class="dotline01"> <%=comId%>-<%=projId%>-<%=site%></td>
                  <td height="22" class="item ; dotline01" width="14%">เลขที่ใบสั่งงานซ่อม 
                    :</td>
                  <td height="22" width="34%" class="dotline01"> <span style="width:100px"><%=docNo%></span></td>
                </tr>
                <tr> 
                  <td class="item ; dotline01" height="22" width="13%">ชื่อผู้แจ้ง 
                    :</td>
                  <td height="22" width="39%" class="dotline01"><%=sender%></td>
                  <td height="22" class="item ; dotline01" width="14%">วันเวลาที่แจ้ง 
                    :</td>
                  <td height="22" width="34%" class="dotline01"><%=keyinDate%></td>
                </tr>
                <tr> 
                  <td class="item ; dotline01" height="22" width="13%">วันที่นัดซ่อม 
                    :</td>
                  <td height="22" width="39%" class="dotline01"><%=appDate%></td>
                  <td height="22" class="item ; dotline01" width="14%">วันที่ประมาณการเสร็จ 
                    :</td>
                  <td height="22" width="34%" class="dotline01"><%=closeDate%></td>
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
                <td class="item_tab2" width="200">รายการซ่อม</td>
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
                  <td width="3%" rowspan="2" class="col_name">No.</td>
                  <td width="15%" rowspan="2" class="col_name">รายการซ่อม</td>
                  <td width="6%" rowspan="2" class="col_name">หน่วยนับ</td>
                  <td width="8%" rowspan="2" class="col_name">ประเภทงาน</td>
                  <td width="12%" rowspan="2" class="col_name">ผู้รับเหมาซ่อม</td>
                  <td colspan="3" class="col_name">ค่าแรง</td>
                  <td colspan="3" class="col_name">ค่าของ</td>
                  <td width="8%" rowspan="2" class="col_name">ประมาณการ<br>คชจ.ซ่อม</td>
                  <td width="8%" rowspan="2" class="col_name">รวมเงิน</td>
                </tr>
                <tr> 
                  <td width="8%" class="col_nameLow">ต่อหน่วย</td>
                  <td width="4%" class="col_nameLow">จำนวน</td>
                  <td width="8%" class="col_nameLow">รวม</td>
                  <td width="8%" class="col_nameLow">ต่อหน่วย</td>
                  <td width="4%" class="col_nameLow">จำนวน</td>
                  <td width="8%" class="col_nameLow">รวม</td>
                </tr>
<%
	int seqNo = 0;
	double wage_price = 0;
	double wage_unit = 0;
	double good_price = 0;
	double good_unit = 0;
	double wageAmnt = 0;
	double goodAmnt = 0;
	double estAmnt = 0;
	double payAmnt = 0;
	double totWageAmnt = 0;
	double totGoodAmnt = 0;
	double totEstAmnt = 0;
	double totPayAmnt = 0;
	sql.append("SELECT a.*, b.n_itmjob, b.n_count, d.bus_name, t.n_desc")
		.append(" FROM lan:serv_infdocdt a, lan:serv_infboq b, lan:stpvendr d, lan:serv_xstd t")
		.append(" WHERE a.i_docno = '")
		.append(docNo)
		.append("' AND a.f_itmstatus != 'CAN'")
		.append(" AND a.i_itmjob = b.i_itmjob")
		.append(" AND a.i_vendor = d.vend_code")
		.append(" AND t.i_type = '64' AND a.i_itmtype = t.i_code")
		.append(" ORDER BY a.i_seq");
	rsDetl = dstmt.executeQuery(sql.toString());
	if (rsDetl != null) {
		while (rsDetl.next() == true) {
			seqNo = rsDetl.getInt("I_SEQ");
			wage_price = rsDetl.getDouble("z_wage_price");
			wage_unit = rsDetl.getDouble("q_wage_unit");
			wageAmnt = wage_price * wage_unit;
			totWageAmnt += wageAmnt;
			
			good_price = rsDetl.getDouble("z_good_price");
			good_unit = rsDetl.getDouble("q_good_unit");
			goodAmnt = good_price * good_unit;
			totGoodAmnt += goodAmnt;
			
			estAmnt = rsDetl.getDouble("z_est_amt");
			totEstAmnt += estAmnt;
			payAmnt = rsDetl.getDouble("z_amount_pay");
			totPayAmnt += payAmnt;
			
%>
		        <tr>
		          <td width="3%" align="center" class="dotline"><%=seqNo%></td>
		          <td width="15%" class="dotline"><%=doString.DisplayThai(rsDetl.getString("N_ITMJOB"))%></td>
		          <td width="6%" class="dotline" align="center"><%=doString.DisplayThai(rsDetl.getString("N_COUNT"))%>&nbsp;</td>
		          <td width="8%" class="dotline" align="center"><%=doString.DisplayThai(rsDetl.getString("N_DESC"))%></td>
		          <td width="12%" class="dotline ; item"><%=doString.DisplayThai(rsDetl.getString("BUS_NAME"))%></td>
		          <td width="8%" align="right" class="dotline"><%=doString.displayNumber("###,###,###.00", wage_price)%></td>
		          <td width="4%" align="center" class="dotline"><%=doString.displayNumber("#########.00", wage_unit)%></td>
		          <td width="8%" align="right" class="dotline"><span id="wage_sum_1"><%=doString.displayNumber("###,###,###.00", wageAmnt)%></span></td>
		          <td width="8%" align="right" class="dotline"><%=doString.displayNumber("###,###,###.00", good_price)%></td>
		          <td width="4%" align="center" class="dotline"><%=doString.displayNumber("#########.00", good_unit)%></td>
		          <td width="8%" align="right" class="dotline"><%=doString.displayNumber("###,###,###.00", goodAmnt)%></td>
		          <td width="8%" align="right" class="dotline"><%=doString.displayNumber("###,###,###.00", estAmnt)%></td>
		          <td width="8%" align="right" class="dotline"><%=doString.displayNumber("###,###,###.00", payAmnt)%></td>
		        </tr>
<%			
		}// end while
		rsDetl.close();
		rsDetl=null;
	}
%>
                <tr> 
                  <td width="3%" align="center" class="dotline">&nbsp;</td>
                  <td width="15%" class="dotline">&nbsp;</td>
                  <td width="6%" class="dotline" align="center">&nbsp;</td>
                  <td width="8%" class="dotline" align="center">&nbsp;</td>
                  <td width="12%" class="dotline ; item" align="right">รวม</td>
                  <td width="8%" align="right" class="dotline ; item">&nbsp;</td>
                  <td width="4%" align="right" class="dotline ; item">&nbsp;</td>
                  <td width="8%" align="right" class="dotline ; item"><span id="totalWage"><%=doString.displayNumber("###,###,###.00", totWageAmnt)%></span></td>
                  <td width="8%" align="right" class="dotline ; item">&nbsp;</td>
                  <td width="4%" align="right" class="dotline ; item">&nbsp;</td>
                  <td width="8%" align="right" class="dotline ; item"><span id="totalGoods"><%=doString.displayNumber("###,###,###.00", totGoodAmnt)%></span></td>
                  <td width="8%" align="right" class="dotline ; item"><span id="totalGoods"><%=doString.displayNumber("###,###,###.00", totEstAmnt)%></span></td>
                  <td width="8%" align="right" class="dotline ; item"><span id="grandTotal"><%=doString.displayNumber("###,###,###.00", totPayAmnt)%></span></td>
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
                <td class="item_tab2" width="200">หมายเหตุ</td>
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
<%
	rsDetl = dstmt.executeQuery("SELECT a.i_seq, a.c_itmjob, c.n_desc FROM lan:serv_infdocdt a, lan:serv_xstd c WHERE a.i_docno = '"+docNo+"' AND a.i_itmjob_area = c.i_code AND c.i_type = '08' ORDER BY a.i_seq");
	if (rsDetl != null) {
		while (rsDetl.next() == true) {
			seqNo = rsDetl.getInt("I_SEQ");
%>
				  <tr>
				    <td class="item ; dotline01" height="22" width="12%">รายการที่ <%=seqNo%> :</td>
				    <td height="22" width="76%" class="dotline01"><%=doString.DisplayThai(rsDetl.getString("C_ITMJOB"))%></td>
				    <td height="22" width="12%" class="dotline01"><%=doString.DisplayThai(rsDetl.getString("N_DESC"))%></td>
				  </tr>
<%			
		}// end while
		rsDetl.close();
		rsDetl=null;
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



            <table border="0" width="100%" cellspacing="0" cellpadding="0">

              <tr>

                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>

                <td class="item_tab2" width="200">Attach File</td>

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

<%
	String urlAttach = "";
	rsDetl = dstmt.executeQuery("SELECT a.i_seq, b.n_itmjob, a.n_name, a.i_file_name FROM lan:serv_infdocdt a, lan:serv_infboq b WHERE a.i_docno = '"+docNo+"' AND a.i_itmjob = b.i_itmjob ORDER BY a.i_seq");
	if (rsDetl != null) {
		while (rsDetl.next() == true) {
			seqNo = rsDetl.getInt("I_SEQ");
			urlAttach = request.getContextPath()+"/attach/lh/"+docNo+"/"+doString.checkString(rsDetl.getString("I_FILE_NAME"));
%>
				  <tr>
				    <td class="item ; dotline01" height="22" width="12%">รายการที่ <%=seqNo%> :</td>
				    <td height="22" width="76%" class="dotline01"><%=doString.DisplayThai(rsDetl.getString("N_ITMJOB"))%></td>
				    <td height="22" width="12%" class="dotline01"><a href="<%=urlAttach%>" target="_blank"><%=doString.DisplayThai(rsDetl.getString("N_NAME"))%></a>&nbsp;</td>
				  </tr>
<%			

		}// end while
		rsDetl.close();
		rsDetl=null;
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
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">สายงานการอนุมัติ</td>
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
    <td width="44%" class="BG01" align="center">
<table cellspacing="0" cellpadding="0" width="300">
                                  <tr>
                                    <td width="15"><img border="0" src="images/no1.gif" align="absmiddle" width="15" height="15"></td>
                                    <td width="25"><img border="0" src="images/i_pass.gif" align="absmiddle" width="19" height="16"></td>
                                    
                        <td><font color="#000096"><%=sender%>&nbsp;(เจ้าหน้าที่บริการลูกค้า)</font></td>
                                  </tr>
                                  <tr>
                                    <td width="15"></td>
                                    <td width="25"></td>
                                    <td>ผู้ขออนุมัติ</td>
                                  </tr>
</table>
    </td>
    <td width="12%" class="BG01" align="center" valign="middle">
<img border="0" src="images/arrow5.gif" align="absmiddle" width="90" height="40">
    </td>
    <td width="44%" class="BG01" align="center">
		<table cellspacing="0" cellpadding="0" width="300">
			  <tr>
				<td width="15"><img border="0" src="images/no1.gif" align="absmiddle" width="15" height="15"></td>
				<td width="25"><img border="0" src="images/i_wait.gif" align="absmiddle" width="19" height="16"></td>                                    
			            <td><font color="#000096"><%=approver%> (<%=chartGrp%>)</font></td>
		  </tr>
		  <tr>
			<td width="15"></td>
			<td width="25"></td>
			<td>ผู้อนุมัติ</td>
		  </tr>
		</table>	   
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
                <td class="item_tab2" width="160">หมายเหตุ</td>
                <td class="item_tab3"></td>
                <td class="textgray">&nbsp; </td>                
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
			    <td width="100%" class="frmLRpad01" valign="top">
			    <textarea rows="5" name="Comment" class="box" style="width:100%" cols="20"></textarea>
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
<%
		dstmt.close();
		stmt.close();
		conn.close();
		stmt = null;
		dstmt = null;
		conn=null;
		System.out.println("---- SERV_INFOpenJob_Appr.jsp ------ ");
	} catch (Exception e) {
		System.out.println("ERROR SERV_INFOpenJob_Appr.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (stmt != null) stmt.close();
			if (dstmt != null) dstmt.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>
<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="230" class="act_tab2">            
<%if (approve) {%>            
            <a href="javascript:Approve('A')"><img border="0" src="images/act_approve.gif"
    			onmouseout=nereidFade(this,70,50,5)
                  	onmouseover=nereidFade(this,100,50,5)
                  	style="cursor:hand;FILTER: alpha(opacity=70)" width="70" height="27"></A>&nbsp; 
              <a href="javascript:Approve('R')"><img border="0" src="images/act_routeback.gif"
    			onmouseout=nereidFade(this,70,50,5)
                  	onmouseover=nereidFade(this,100,50,5)
                  	style="cursor:hand;FILTER: alpha(opacity=70)" width="70" height="27"></a> 
<%}%>                  	
            &nbsp;      	
            </td>
            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="javascript:history.back()"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp; 
              <a href="SERV_Home.jsp" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
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