<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%
//String sessionId = user.getsessionId();
//String userId = user.getUserID();

    String month[] = {"เดือน","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};   
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

		String project = "LHALL", i_company = "", i_project = "", n_project = "", i_house = "", station = "", house = "", i_lock = "", status_detail = "", i_refno = "";
	
		if (request.getParameter("i_company") != null) {
			i_company = doString.checkString(request.getParameter("i_company"));
		}
		if (request.getParameter("i_project") != null) {
			i_project = doString.checkString(request.getParameter("i_project"));
		}
		if (request.getParameter("i_house") != null) {
			i_house = doString.checkString(request.getParameter("i_house"));
		}
		if (request.getParameter("i_lock") != null) {
			i_lock = doString.checkString(request.getParameter("i_lock"));
		}
		if (request.getParameter("i_refno") != null) {
			i_refno = doString.checkString(request.getParameter("i_refno"));
		}
		

        if (request.getParameter("station") != null) {
				station = doString.checkString(request.getParameter("station"));
		} // End if	
		String begDD = "";
		if (request.getParameter("begDD") != null) {
			begDD = doString.checkString(request.getParameter("begDD"),"");
		}
		String begMM = "";
		if (request.getParameter("begMM") != null) {
			begMM = doString.checkString(request.getParameter("begMM"),"");
		}
		String begYY = "";
		if (request.getParameter("begYY") != null) {
			begYY = doString.checkString(request.getParameter("begYY"),"");
		}
		String endDD = "";
		if (request.getParameter("endDD") != null) {
			endDD = doString.checkString(request.getParameter("endDD"),"");
		}
		String endMM = "";
		if (request.getParameter("endMM") != null) {
			endMM = doString.checkString(request.getParameter("endMM"),"");
		}
		String endYY = "";
		if (request.getParameter("endYY") != null) {
			endYY = doString.checkString(request.getParameter("endYY"),"");
		}
		String startTime = doString.checkString(request.getParameter("startTime"),"");
		
		String param = "&station="+station+"&project="+project+"&begDD="+begDD+"&begMM="+begMM+"&begYY="+begYY+"&endDD="+endDD+"&endMM="+endMM+"&endYY="+endYY+"&startTime="+startTime;		
		//---------------------------------------
		
		sql.delete(0, sql.length());
		sql.append("select n_project from lan:acxprojt ")	
			.append("where i_company = '"+i_company+"' ")
			.append("and i_project = '"+i_project+"' ");
		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
			n_project = doString.MS874ToUnicode(doString.checkString(rs.getString("n_project")));
		}

%>
<HTML>
<HEAD>
<TITLE>LH Vender</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="LINE_SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

  <link rel="stylesheet" href="jquery/jquery-ui.css">
  <script src="jquery/jquery-1.12.4.js"></script>
  <script src="jquery/jquery-ui.js"></script>

<script>
 //ajax call
function doSubmit(){
	//var mainDDLx = $('select[name="projectDDL"] option:selected').val();
	do_totals1();
	$.ajax({
		type: "POST",
		url: "<%=request.getContextPath()%>/LINE_UpdateTeleHd.jsp",
		data: $('#frmServ').serialize(),
		success: function(paramRestul){
			 var url = "<%=request.getContextPath()%>/LINE_SERVDetail.jsp?<%=param%>";
		     $(document).ready(function() {
			 $(location).attr('href',url);
		     });
		}
	});
}
</script>
<script language="JavaScript" type="text/JavaScript">
function do_totals1() {
   	 	document.all.pleasewaitScreen.style.pixelTop = (document.body.scrollTop + 180);
    	document.all.pleasewaitScreen.style.visibility = "visible";
    	var msg = "<img src=\"<%=request.getContextPath()%>/images/p_loading.gif\" HEIGHT=\"60px\">";
    	document.getElementById("img1").innerHTML = msg;
    	setInterval(function () {do_totals1()}, 3000);
    }
    function do_totals2() {
   	 document.all.pleasewaitScreen.style.visibility = "hidden";
    }
    function lengthy_calculation() {
    	while(true) {
    	}
    }
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<form method="POST" name="frmServ" id="frmServ">
<input type="hidden" name="refId" value="<%=i_refno%>">
<input type="hidden" name="empId" value="<%=user.getEmpId()%>">


<%--  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --%>
<DIV ID="pleasewaitScreen" STYLE="position: absolute; z-index: 0; top: 45%; left: 42%; visibility: hidden">
<TABLE BORDER="1" BORDERCOLOR="rgb(180,210,250)" CELLPADDING="0" CELLSPACING="0" 
	HEIGHT="125px" WIDTH="265px" ID="Table1">
	<TR>
	<TD BGCOLOR="#FFFFFF" ALIGN="CENTER" VALIGN="MIDDLE" class="test">
	<font color="rgb(255,120,0)"><b>Loading... Please wait</b></font>
	<br>
	<br>
	  <span id="img1"></span>
	</TD> 
	</TR>
</TABLE>
</DIV>
<%--  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --%>
<%
 String tempTfuRemark = "";
 String tempcDesc= "";
 sql.delete(0, sql.length());
 sql.append(" select i_refno,c_tfu_remark,c_desc from lan:tele_dochd where i_refno = '"+i_refno+"' ");
 rs = stmt.executeQuery(sql.toString());
 if(rs.next()) {
 	tempTfuRemark = doString.DisplayThai(doString.checkString(rs.getString("c_tfu_remark"),""));
 	tempcDesc = doString.DisplayThai(doString.checkString(rs.getString("c_desc"),""));
 }
 rs.close();
 
%>

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
    <td class="item ; dotline01" height="22" width="15%">โครงการ :</td>
    <td height="22" width="39%" class="dotline01"><%=i_company%><%=i_project%> | <%=n_project%></td>
    <td height="22" class="item ; dotline01" width="14%">&nbsp;เลขที่อ้างอิง :</td>
    <td height="22" width="32%" class="dotline01">&nbsp;<%=i_refno %></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="15%">บ้านเลขที่
      :</td>
    <td height="22" width="39%" class="dotline01"><%=i_house%></td>
    <td height="22" class="item ; dotline01" width="14%">แปลง :</td>
    <td height="22" width="32%" class="dotline01"><%=i_lock%>&nbsp;&nbsp;&nbsp;&nbsp;</td>
  </tr>
    <tr>
    <td class="item ; dotline01" height="22" width="15%">TFU Remark :</td>
    <td height="22" width="39%" class="dotline01">
    	<textarea rows="8" name="tfuRemark" id="tfuRemark" cols="80" class="box"><%=tempTfuRemark%></textarea>
    </td>
    <td height="22" class="item ; dotline01" width="14%">รายละเอียด:</td>
    <td height="22" width="32%" class="dotline01">
    	<textarea name="descTex" rows="8" cols="80" disabled="disabled" class="box"><%=tempcDesc%></textarea>
    </td>
  </tr>

    <tr>
    <td class="item ; dotline01" height="22" width="15%">&nbsp;</td>
    <td height="22" width="39%" class="dotline01">&nbsp;</td>
    <td height="22" class="item ; dotline01" width="14%">&nbsp;</td>
    <td height="22" width="32%" class="dotline01">&nbsp;</td>
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
                <td class="item_tab2" width="1200">รายการที่ค้นได้</td>
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
          <td class="col_name">สถานะ</td>
          <td class="col_name">รายละเอียดงาน</td>
          <td class="col_name">เวลาที่ปฏิบัติงาน</td>
          <td class="col_name">จนท.</td>
        </tr><%


//tele_dochd
//tele_tracking
//tele_line_log
///var/lib/tomcat/webapps/LHVendor/pictures
//https://132.144.1.46/LHVendor/pictures/630500771/line_img_1589250884120.jpg
//https://epayment.lh.co.th/LHVendor/pictures/630500771/line_img_1589250884120.jpg
String d_employ_update = "", d_tracking = "", d_start = "", t_start = "", d_track = "", t_end = "", i_employ_update = "", n_emp = "";
int no = 0;
String sta = "";

        sql.delete(0, sql.length());
		sql.append("select distinct a.d_tracking, a.c_desc, a.i_seq, a.i_file_name, a.i_type, a.i_refno, b.d_appoint_start, ")
		   .append("c.start_time, c.end_time, d.d_employ_update, d.i_employ_update, a.follow_status ")
		   .append("from lan:tele_line_data a, lan:tele_dochd b, lan:tele_tracking c, lan:tele_line_log d ")
		   .append("where b.i_company = '"+i_company+"' ")
		   .append("and b.i_project = '"+i_project+"' ")
		   .append("and b.i_lock = '"+i_lock+"' ")
		   .append("and a.i_refno = '"+i_refno+"' ")
		   .append("and a.i_refno = b.i_refno ")
		   .append("and b.i_refno = c.i_refno ")
		   .append("and c.i_refno = d.i_refno ")
		   .append("and c.f_status != 'CAN' ")	
		   .append("and a.follow_status = d.follow_status ")
		   .append("and a.i_seq = d.i_seq ")
		   .append("and a.d_tracking = c.d_tracking ")
		   .append("and c.d_tracking = d.d_tracking ")
		   .append("order by a.d_tracking, d.d_employ_update, a.follow_status ");
		  // out.println(sql.toString());	
		rs = stmt.executeQuery(sql.toString());
		while (rs.next()) {
		
				d_employ_update = doString.checkString(rs.getString("d_employ_update"));
				d_tracking = doString.checkString(rs.getString("d_tracking"));
				i_employ_update = doString.checkString(rs.getString("i_employ_update"));
		
				if (d_employ_update.trim().length() == 21){
						d_start = d_employ_update.substring(8,10)+"/"+d_employ_update.substring(5,7)+"/"+d_employ_update.substring(2,4); 
						t_start =  d_employ_update.substring(11,16);
				}
				if (d_tracking.trim().length() == 10){
						d_track = d_tracking.substring(8,10)+"/"+d_tracking.substring(5,7)+"/"+d_tracking.substring(2,4); 					
				}
				
				n_emp = "";
				sql.delete(0, sql.length());
				sql.append("select n_nemploy_th from docflow:acemploy ")
				   .append("where i_employ = '"+i_employ_update+"' ");				
				rs1 = stmt1.executeQuery(sql.toString());
				if (rs1.next()) {
						n_emp = doString.MS874ToUnicode(doString.checkString(rs1.getString("n_nemploy_th")));					
				}
				no++;
if (!sta.equals(doString.checkString(rs.getString("follow_status"))) && no!=1 ) {  // display seq
	no = 1;
}
 %>
        <tr>
          <td align="center" class="dotline"><%=d_track%></td>
          <td align="center" class="dotline"> <%=doString.checkString(rs.getString("start_time"))%>-<%=doString.checkString(rs.getString("end_time"))%></td>
			<td align="center" class="dotline"><%=doString.checkString(rs.getString("follow_status"))%> </td>
			<td class="dotline" valign="top"><%=no%>. &nbsp;
	
<%		if (doString.checkString(rs.getString("i_type")).equals("1")) {    %>
          		<%=doString.MS874ToUnicode(doString.checkString(rs.getString("c_desc")))%>
<%      } else {  %>
		  		<img src="https://epayment.lh.co.th/LHVendor/pictures/<%=doString.checkString(rs.getString("i_refno"))%><%=doString.checkString(rs.getString("i_seq"))%>/<%=doString.checkString(rs.getString("i_file_name"))%>" width="120" height="95"/><%      }       %>
          </td>
          <td align="center" class="dotline"><%=d_start%>&nbsp;&nbsp;<%=t_start%></td>
          <td align="center" class="dotline">&nbsp;<%=n_emp%></td>
        </tr>
<% 
		sta = doString.checkString(rs.getString("follow_status"));		
	} // while 
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
            <td width="75" class="act_tab2">&nbsp;
            <a href="javascript:doSubmit();" ><img border="0" src="images/act_submit.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp; 
            </td>        	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:history.back()" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              </td>  
          </tr>  
        </table>  


          </td>
        </tr>
      </table>

			
<br style="font-size:30pt">
	
	
	
<script language="JavaScript" type="text/JavaScript" src="LINE_SERV_Copyright.js"></script>

</form>	
</BODY>

</HTML><%
	} catch (Exception e) {
		System.out.println("ERROR LINE_SERVList.jsp : " + e.getMessage());
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