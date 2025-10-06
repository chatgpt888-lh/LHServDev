<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
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
<%@ page import="serv.util.ServLog" %>

<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>


<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_Report9_1.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   doString str = new doString();


   //----============ Declare Variables for input data ===========----//
   String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase();
   session.setAttribute("sess_sel_proj",selProj);
   /*
   if  (selProj.length()==0) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       session.setAttribute("sess_sel_proj",selProj);
   }*/

   String cut_vendor = doString.checkString(request.getParameter("cut_vendor"),"");  
   String vendor = doString.checkString(request.getParameter("vendor"),"");  
   String Proj_doc = doString.checkString(request.getParameter("Proj_doc"),"");  

   String iDocNo = doString.checkString(request.getParameter("i_docno"),"");
   String iVendor = doString.checkString(request.getParameter("i_vendor"),"");
   String condition = "";
   String condition2 = "";

	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	SERV_CommonData common = null;
	DecimalFormat format = new DecimalFormat("#,##0.00");

	try {

        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();
		stmt1 = conn.createStatement();
		common = new SERV_CommonData(conn);
        //----=======================================----//


        //---====================== Generate Serrch Condition ===========================---//
        String startDate = common.getValueFromDateListbox("start",request);
        String endDate = common.getValueFromDateListbox("end",request);

        if (iDocNo.trim().length()>0) {
           condition += " and a.i_docno='"+iDocNo+"'  ";
	   if (iDocNo.length()>=6) {
	       selProj = iDocNo.substring(0,2)+":"+iDocNo.substring(3,6);
	   }
        }

        condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";


/*
        if (selProj.trim().length()>0 && !selProj.equalsIgnoreCase("ALL")) {
           condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
        }

	if (selProj.trim().length()<=0) {
	   String projList = common.getProjectListByUserId(user.getUserID());
	   if (projList.length()>0) {
	       condition += " and substr(a.i_docno,1,6) in ("+projList+") ";
	   } else {

		sql.delete(0,sql.length());
		sql.append(" select count(*) from serv_pstaff  where user_id='").append(user.getUserID()).append("' and proj_id='ALL' ");
		int checkAllPermission = 0;

		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
		    checkAllPermission = rs.getInt(1);
		}
		rs.close();
		if (checkAllPermission<=0) {
		   //----- used for user that no project in hand , set for data not load ----//
		   condition += " and a.i_docno='NOPROEJCT' ";
	       } else {
		  selProj = "ALL";
	       }

	   } // end if check selProj length

	}
*/

	if (startDate.length()>0 && endDate.length()>0) {
	   condition += " and b.d_payment between '"+startDate+"' and '"+endDate+"' ";
	}
	//---=========================================================================----//




        //----==================== Find all Vendor in this result ============================-----//
        Vector vendorList = new Vector();
        sql.delete(0,sql.length());
        sql.append(" select distinct i_vendor from serv_dochd a,serv_payment b ")
	      .append(" where a.f_status in ('OPN','CLS') and b.i_docno=a.i_docno and b.f_itmstatus='CLS' ");
	if (iVendor.length()>0) { sql.append(" and b.i_vendor='").append(iVendor).append("' "); }
	if (selProj.length()>0 && !selProj.equals("ALL")) { sql.append(" and substr(b.i_docno,1,2)||':'||substr(b.i_docno,4,3)='").append(selProj).append("' "); }
	sql.append(condition);
		servlog.startLog(sql.toString());
        rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
        while (rs.next()) {
            vendorList.addElement(doString.checkString(rs.getString("i_vendor"),""));
        }
        rs.close();
	//---=========================================================================----//



        //----==================== Get Markup Pay from SERV_XSTD  ====================-----//
        double markupPay = 0.00;
        sql.delete(0,sql.length());
        sql.append(" select * from lan:serv_xstd where i_type='02' ");
		servlog.startLog(sql.toString());
        rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
        if (rs.next()) {
           markupPay = rs.getDouble("p_amount");
        }
        rs.close();
	   //---=========================================================================----//    


        //----====================== Get DOCHD Max Row ==============================-----//
        int maxRow = 0;
        sql.delete(0,sql.length());
        sql.append(" select count(*) cnt from serv_dochd a,serv_payment b ")
	      .append(" where a.f_status in ('OPN','CLS') and b.i_docno=a.i_docno and b.f_itmstatus='CLS' ");
	if (iVendor.length()>0) { sql.append(" and b.i_vendor='").append(iVendor).append("' "); }
	if (selProj.length()>0 && !selProj.equals("ALL")) { sql.append(" and substr(b.i_docno,1,2)||':'||substr(b.i_docno,4,3)='").append(selProj).append("' "); }
	sql.append(condition);
        sql.append(" group by a.i_docno,b.i_vendor ");
		servlog.startLog(sql.toString());
        rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
        while (rs.next()) {
           maxRow++;
        }
        rs.close();
	//---=========================================================================----//



	   //-----============== Generate Display Customize and Page Link ==================-----//
	   String displayType = doString.checkString(request.getParameter("display_type"),"");
	   int displayLine = Integer.parseInt(doString.checkString(request.getParameter("display_line"),"0"));
	   int nowPage = Integer.parseInt(doString.checkString(request.getParameter("now_page"),"1"));
	   if (displayType.equalsIgnoreCase("A")) {
	      displayLine = maxRow;
	      nowPage = 1;
	   }
	   if (displayLine<Constants.SERV_MANAGERCONF_LINE) displayLine = Constants.SERV_MANAGERCONF_LINE;

	   int startRow = ((nowPage-1)*displayLine);
	   int endRow = startRow+displayLine;
	   int tmpMax = maxRow;

	   String pageLink = "";
	   int tmpPage = 0;
	   while (tmpMax>0) {
	       tmpMax -= displayLine;
	       tmpPage++;
	       if (nowPage==tmpPage) {
	          pageLink += "&nbsp; <b>"+tmpPage+"</b> ";
	       } else {
	          pageLink += "&nbsp; <a href='#' onclick='changePage("+tmpPage+");'>"+tmpPage+"</a> ";
	       }
	   }

	   if (tmpPage>1) {
	      int prev = nowPage-1;
	      if (prev<1) prev=1;
	      pageLink = "<a href='#' onclick='changePage("+prev+");'>หน้าก่อน</a>&nbsp; "+pageLink;
	      int next = nowPage+1;
	      if (next>tmpPage) next = tmpPage;
	      pageLink += "&nbsp; <a href='#' onclick='changePage("+next+");'>หน้าถัดไป</a>";
	   } else {
	      pageLink = "หน้า <b>1</b>";
	   }
	 //---=========================================================================----//



%>

<HTML>
<HEAD>
<TITLE>Manager - ผู้จัดการกลุ่ม</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--

  function searchDocHD() {
     if (!validDate()) {
        return false;
     }

     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Report9.jsp";
     document.forms[0].submit();
  }

  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Report9.jsp";
     document.forms[0].submit();
  }

  function validDate() {
     var sdate = document.forms[0].start_date.value;
     var smonth = document.forms[0].start_month.value;
     var syear = document.forms[0].start_year.value;
     var edate = document.forms[0].end_date.value;
     var emonth = document.forms[0].end_month.value;
     var eyear = document.forms[0].end_year.value;

     //---- Check select date ---//
     if (sdate.length==0 && smonth.length==0 && syear.length==0 &&
         edate.length==0 && emonth.length==0 && eyear.length==0) {
         return true;
     }


     var startDate = new Date(parseInt(syear,10),parseInt(smonth,10)-1,parseInt(sdate,10));
     var endDate = new Date(parseInt(eyear,10),parseInt(emonth,10)-1,parseInt(edate,10));

     if (startDate.getMonth()!=(parseInt(smonth,10)-1)) {
        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].start_date.focus();
        return false;
     }

     if (endDate.getMonth()!=(parseInt(emonth,10)-1)) {
        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].end_date.focus();
        return false;
     }

	if (startDate>endDate) {
	    alert(" วันที่สิ้นสุดต้องไม่น้อยกว่าวันที่เริ่มต้น ! ");
	    return false;
	}

     return true;
  }

function printReport() {
   if (document.forms[0].sel_project.value=="") {
       alert("กรุณาเลือกโครงการ !");
       document.forms[0].sel_project.focus();
       return false;
   }

   //document.forms[0].action='<%=Constants.APP_PATH%>/SERV_PrintReport9Servlet<%=iDocNo.length()>0 ? "?i_docno="+iDocNo : ""%>';
   document.forms[0].action='/LHServ/SERV_PrintReport9Servlet<%=iDocNo.length()>0 ? "?i_docno="+iDocNo : ""%>';
   document.forms[0].target="_blank";   
   document.forms[0].submit();
   document.forms[0].target="";   
}


//-->
</script>


<style>
td		{	font-size:8.0pt	}
</style>

<base target="_self">
</HEAD>

<BODY leftMargin=15 topMargin=15 marginheight="15" marginwidth="15">


<FORM METHOD="POST" ACTION="">

<input type="hidden" name="now_page" value="<%=nowPage%>">


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>

    <td width="63%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
      รายละเอียดการส่งงานของผู้รับเหมาตามวันที่จ่าย (รายละเอียด)</td>
    <td width="37%" align="right">&nbsp; </td>
        </tr>
      </table>
<br>

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
          <td width="8%" height="22" class="item ; dotline01">โครงการ : </td>
          <td width="57%" height="22" class="dotline01">&nbsp;<%=Proj_doc%></td>
        </tr>
        <tr>
          <td width="8%" height="22" class="item ; dotline01">ผู้รับเหมาซ่อม : </td>
          <td width="57%" height="22" class="dotline01">&nbsp;<%=vendor%></td>
        </tr>
  </table>
	  </td>
  </tr>
</table>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5">&nbsp;</td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5">&nbsp;</td>
  </tr>
</table>


<br style="font-size:10pt">


					       
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
								          <td class="col_nameS" rowspan="2" width="52%">รายการซ่อม</td>
								          <td colspan="3" class="col_nameS">ค่าแรง</td>
								          <td colspan="3" class="col_nameS">ค่าของ</td>
								          <td rowspan="2" class="col_nameS" width="7%">ค่าแรง<br>
								            + ค่าของ</td>
								          <td rowspan="2" class="col_nameS" width="7%">รวมค่าดำเนิน<br>
								            การ <%=((int) markupPay)%>%</td>
								        </tr>
								        <tr>
								          <td class="col_nameLow" width="3%">จำนวน</td>
								          <td class="col_nameLow" width="7%">ต่อหน่วย</td>
								          <td class="col_nameLow" width="7%">รวม</td>
								          <td class="col_nameLow" width="3%">จำนวน</td>
								          <td class="col_nameLow" width="7%">ต่อหน่วย</td>
								          <td class="col_nameLow" width="7%">รวม</td>
								        </tr>
						     <%
						     //-----==========================================================================----//






							//----=========================== Get Payment Details ===============================----//
							int itmLine = 0;
						    //double sumQWage = 0.00;
						    //double sumQGoods = 0.00;
						    double sumSumWage = 0.00;
						    double sumSumGoods = 0.00;
						    double sumSumTotal = 0.00;
						    double sumCutVendor = 0.00;
						    double sumCutOnly = 0.00;

						   sql.delete(0,sql.length());
						   sql.append("select d.bus_name,c.n_itmjob,b.* ")
								.append("from lan:serv_payment b left join lan:serv_boq c ") 
								.append("on c.i_itmjob=b.i_itmjob left join lan:stpvendr d ") 
								.append("on d.vend_code=b.i_ven_cut ") 
								.append("where b.i_ven_cut = '"+cut_vendor+"' ")
								.append("and b.i_vendor = '"+vendor+"' ")
								.append("and substr(b.i_docno,1,2)||':'||substr(b.i_docno,4,3)='"+Proj_doc+"' ") 
								.append("and b.f_itmstatus='CLS' ");   
						//out.println(sql.toString());
							servlog.startLog(sql.toString());
							rs1 = stmt1.executeQuery(sql.toString());
							servlog.endLog();
							while (rs1.next()) {
							    itmLine++;
						    String nItmJob = doString.checkString(rs1.getString("n_itmjob"),"");
							    double qWage = rs1.getDouble("q_wage_unit");
							    double zWage = rs1.getDouble("z_wage_price");
							    double qGoods = rs1.getDouble("q_good_unit");
							    double zGoods = rs1.getDouble("z_good_price");
							    double sumWage = qWage * (double) zWage;
							    double sumGoods = qGoods * (double) zGoods;
							    double sumTotal = rs1.getDouble("z_amount_pay");
							    double cutVendor = rs1.getDouble("z_amount_pv");

						        //sumQWage += qWage;
						        //sumQGoods += qGoods;
						        sumSumWage += sumWage;
						        sumSumGoods += sumGoods;
						        sumSumTotal += sumTotal;
						        sumCutVendor += cutVendor;


						

							 //-----============================= Print Body =====================================----//
					        %>
							        <tr>
							          <td class="dotline" width="52%" valign="top"><%=itmLine%>. <%=nItmJob%></td>
							          <td class="dotline" align="right" width="3%" valign="top"><%=format.format(zWage)%></td>
							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(qWage)%></td>
							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(sumWage)%></td>
							          <td class="dotline" align="right" width="3%" valign="top"><%=format.format(zGoods)%></td>
							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(qGoods)%></td>
							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(sumGoods)%></td>
							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(sumTotal)%></td>
							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(cutVendor)%></td>
							        </tr>
		
<%  }  %>
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

<br style="font-size:10pt">



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="80" class="act_tab2">&nbsp; 
<!--	     <img border="0" src="images/act_print.gif" onclick="printReport();"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">
-->
	   </td>

            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_Report8.jsp?sel_project=<%=selProj%>&i_vendor=<%=iVendor%>" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
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
		System.out.println("ERROR SERV_Report9_1.jsp : " + e.getMessage());
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