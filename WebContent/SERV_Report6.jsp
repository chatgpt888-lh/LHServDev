<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="java.text.DecimalFormat" %>

<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.Constants" %>
<%@ page import="serv.common.User" %>
<%@ page import="serv.util.ServLog" %>

<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>


<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_Report6.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   doString str = new doString();
   DecimalFormat format = new DecimalFormat("#,##0.00");


   //----============ Declare Variables for input data ===========----//
   String iCom = "", iProj = "";
   String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase(); 
   String iCompany = (selProj.length()==6 ? selProj.substring(0,2) : "");
   String iProject = (selProj.length()==6 ? selProj.substring(3,6) : "");

   String showMonth[] = new String[] {"","ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค."};
   String selMonth = doString.checkString(request.getParameter("sel_month"),"");
   String selYear = doString.checkString(request.getParameter("sel_year"),"");

   String orderBy = doString.checkString(request.getParameter("order_by"),"");
   String orderType = doString.checkString(request.getParameter("order_type"),"");

   if (orderType.equalsIgnoreCase("ASC")) {
	   orderType = "DESC";
   } else {
	   orderType = "ASC";
   }

			       
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	SERV_CommonData common = null;

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
		String startDate = common.getValueFromDateListbox("start",request);
        String endDate = common.getValueFromDateListbox("end",request);
		String t_typ = doString.checkString(request.getParameter("t_typ"),"B");
        

        //----========================== Find All CUt Type  ==========================-----//
       String allCutType = "";
		sql.delete(0,sql.length());
		sql.append(" select * from lan:serv_xstd where i_type='03' ");
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		while (rs.next()) {
			if (allCutType.length()>0) allCutType += " , ";
		   allCutType += doString.checkString(rs.getString("i_code"),"");
		   allCutType += " = "+doString.checkString(doString.DisplayThai(rs.getString("n_desc")),"");
		}
		rs.close();
	    //---========================================================================----//

		
        //----====================== Get i_lock Max Row ==============================-----//
        int maxRow = 0;
        sql.delete(0,sql.length());
		sql.append(" select count(*) as cnt from lan:serv_cutlck a ")
  		     .append(" left join lan:acscontr c on c.i_company=a.i_company ")
			 .append(" and c.i_project=a.i_project and c.i_sort=a.i_lock and c.f_contr is null ")
			 .append(" where 1=1 ");
		if (t_typ.equals("A")) {
			  sql.append(" and c.d_close_law between '"+startDate+"' and '"+endDate+"' ");
		}
		if (!selProj.equalsIgnoreCase("ALL")) {
			  sql.append(" and a.i_company='").append(iCompany).append("' ")
			        .append(" and a.i_project='").append(iProject).append("' ");
		}
		servlog.startLog(sql.toString());
        rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
        while (rs.next()) {        
           maxRow += rs.getInt("cnt");  
        }
        rs.close();
	   //---=========================================================================----//                

        
		//----- get month name for table header -------//
		String monthName = "";
		if (selMonth.length()>0 && selYear.length()>0) {
			 try {
				 int month = Integer.parseInt(selMonth);
				 int year = Integer.parseInt(selYear);
				 if (year<2400) year += 543;
				 monthName = showMonth[month]+" "+Integer.toString(year).substring(2,4);
			 } catch (Exception ex) {
				 monthName = "";
			 }
		}

        
	   //-----============== Generate Display Customize and Page Link ==================-----//
	   String displayType = doString.checkString(request.getParameter("display_type"),"");    
	   int displayLine = Integer.parseInt(doString.checkString(request.getParameter("display_line"),"0"));
	   int nowPage = Integer.parseInt(doString.checkString(request.getParameter("now_page"),"1"));
	   if (displayType.equalsIgnoreCase("A")) {
	      displayLine = maxRow;
	      nowPage = 1;
	   }
	   if (displayLine<Constants.SERV_REPRINT_LINE) displayLine = Constants.SERV_REPRINT_LINE;      
	   
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
<TITLE>Report 6</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">
<!--

  function searchData() {
     if (!valiDate()) {
        return false;
     }
  
     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Report6.jsp";
     document.forms[0].submit();  
  }

  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Report6.jsp";
     document.forms[0].submit();
  }   
  
  function valiDate() {
     var selproj = document.forms[0].sel_project;
     var selmonth = document.forms[0].sel_month;
     var selyear = document.forms[0].sel_year;
	 var minMonth = 10;
	 var minYear = 2007;
     	    
	if (selproj.value.length<=0) {
		alert(" กรุณาเลือกโครงการ !! ");
		selproj.focus();
		return false;
	}

	if (selmonth.value.length<=0) {
		alert(" กรุณาเลือกเดือน !! ");
		selmonth.focus();
		return false;
	}

	if (selyear.value.length<=0) {
		alert(" กรุณาเลือกปี !! ");
		selyear.focus();
		return false;
	}

	if (((selyear.value-0)<minYear) || ((selyear.value-0)==minYear && (selmonth.value-0)<=minMonth)) {
	    alert(" เดือนที่เลือกต้องไม่น้อยกว่าเดือนพฤศจิกายน 2550 !! ");
		document.forms[0].sel_month.focus();
	    return false;
	}
  
     return true;
  }

function printReport() {
   if (!valiDate()) {
       return false;
   }

   document.forms[0].action="<%=Constants.APP_PATH%>/SERV_PrintReport6Servlet";
   document.forms[0].target="_blank";   
   document.forms[0].submit();
   document.forms[0].target="";   
}

  function orderData(orderby,ordertype) {
     document.forms[0].order_by.value=orderby;
     document.forms[0].order_type.value=ordertype;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Report6.jsp";
     document.forms[0].submit();
  }   

  function goDetail(lock,model) {
		document.forms[0].lock.value=lock;
		document.forms[0].model.value=model;
	  	document.forms[0].action='<%=Constants.APP_PATH%>/SERV_Report6Det.jsp';
		document.forms[0].submit();
 }

  //-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">

<input type="hidden" name="now_page" value="<%=nowPage%>">
<input type="hidden" name="order_by" value="<%=orderBy%>">
<input type="hidden" name="order_type" value="<%=orderType%>">
<input type="hidden" name="lock" value="">
<input type="hidden" name="model" value="">


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            สรุปค่าซ่อมสะสมทั้งโครงการ</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">ระบุโครงการ
                  / เดือน</td>
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
    <td class="item ; dotline01" height="22" width="6%">โครงการ :</td>
    <td height="22" width="28%" class="dotline01">
    <%=common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:250px' ",true)%>       
	</td>
    <td height="22" width="7%" class="dotline01 ; item"><nobr>ประจำเดือน :</nobr></td>
    <td height="22" width="13%" class="dotline01">
	<%=common.genMonthListbox("sel_month",selMonth," class='box' ")%>
	</td>
    <td height="22" class="item ; dotline01" width="3%">ปี :</td>
    <td height="22" width="43%" class="dotline01">
	<%
		Calendar tmpCal = Calendar.getInstance();
		int nowYear = tmpCal.get(Calendar.YEAR);
		if (nowYear>2400) nowYear -= 543;
         out.println(common.genYearListbox("sel_year",selYear," class='box' ",2007,(nowYear-2007)+1));
	%>	
	</td>
  </tr>
</table>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td class="item ; dotline01" height="22" width="10%"><input type="radio" value="A" name="t_typ" <% if (t_typ.equals("A")) { out.println("checked"); } %>>ระบุวันที่โอน :</td>
    <td height="22" width="90%" class="dotline01"><%
		 if (nowYear>2400) nowYear -= 543;
				out.println(common.genDateOfMonthListbox("start_date",(startDate.length()==10 ? startDate.substring(8,10) : "")," class='box' "));
				out.println(common.genMonthListbox("start_month",(startDate.length()==10 ? startDate.substring(5,7) : "")," class='box' "));
				out.println(common.genYearListbox("start_year",(startDate.length()==10 ? startDate.substring(0,4) : "")," class='box' ",nowYear-18,19));
		  %>
          &nbsp; &nbsp; ถึง : &nbsp; &nbsp;       
		  <%
				out.println(common.genDateOfMonthListbox("end_date",(endDate.length()==10 ? endDate.substring(8,10) : "")," class='box' "));
				out.println(common.genMonthListbox("end_month",(endDate.length()==10 ? endDate.substring(5,7) : "")," class='box' "));
				out.println(common.genYearListbox("end_year",(endDate.length()==10 ? endDate.substring(0,4) : "")," class='box' ",nowYear-18,19));
		  %>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  <input type="radio" value="B" name="t_typ" <% if (t_typ.equals("B")) { out.println("checked"); } %>>ไม่ระบุ
	&nbsp;&nbsp;&nbsp;&nbsp; <a href="#" onclick="searchData()"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a></td>
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
                <td class="item_tab2" width="200">รายละเอียดแต่ละหมวดงานซ่อม</td>
                <td class="item_tab3"></td>
                <td>&nbsp;<input type="radio" value="L" checked name="display_type" <%=(displayType.equalsIgnoreCase("L") ? "checked" : "")%>>แสดงจำนวนรายการต่อหน้า&nbsp;
                  <input type="text" name="display_line" class="boxC" style="width:50px" value="<%=displayLine%>">&nbsp;
                  รายการ&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" value="A" name="display_type" <%=(displayType.equalsIgnoreCase("A") ? "checked" : "")%>>
                  แสดงรายการทั้งหมด&nbsp;&nbsp;&nbsp;&nbsp;
                  <a href="#" onclick="changePage(1);"><img border="0" src="images/bu_R.gif" align="absmiddle" style="cursor:hand" width="16" height="16"></a>
                  </td>
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
          <td width="3%" class="col_name" rowspan="2">ลำดับ</td>
          <td width="8%" class="col_name" rowspan="2">โครงการ</td>
          <td width="4%" class="col_name" rowspan="2">
			<a href="javascript:orderData('a.i_lock','<%=orderType%>');">แปลง</a>
		  </td>
          <td width="7%" class="col_name" rowspan="2">แบบบ้าน</td>
          <td width="5%" class="col_name" rowspan="2">
		  <a href="javascript:orderData('c.d_close_law','<%=orderType%>');">วันที่หมดประกัน</a>
		  </td>
          <td width="14%" class="col_name" rowspan="2">ผู้รับเหมาสร้าง</td>
          <td class="col_name" colspan="2">สะสมก่อนเดือน <%=monthName%></td>
          <td class="col_name" colspan="2">เดือนที่เบิก <%=monthName%></td>
          <td class="col_name" colspan="3">สะสมทั้งหมด</td>
          <td class="col_name" colspan="2">รูปแบบการตัดเงิน</td>
          <td width="9%" class="col_name" rowspan="2">คงเหลือ</td>
        </tr>
        <tr>
          <td width="7%" class="col_nameLow">ตามสัญญา</td>
          <td width="7%" class="col_nameLow">อื่นๆ</td>
          <td width="7%" class="col_nameLow">ตามสัญญา</td>
          <td width="7%" class="col_nameLow">อื่นๆ</td>
          <td width="7%" class="col_nameLow">ตามสัญญา</td>
          <td width="7%" class="col_nameLow">อื่นๆ</td>
          <td width="7%" class="col_nameLow">รวม</td>
          <td width="3%" class="col_nameLow">**</td>
          <td width="7%" class="col_nameLow">บาท</td>
        </tr>
		<%
		  //startDate==2009-01-01 endDate==2009-01-31 
		        int line = 0;
				int checkMonth = 0;
				int checkYear = 0;
				try {
					 checkMonth = Integer.parseInt(selMonth);
					 checkYear = Integer.parseInt(selYear);
					 if (checkYear>2400) checkYear -= 543;
				 } catch (Exception ex) {}


				sql.delete(0,sql.length());
				sql.append(" select b.i_lor,b.i_model,b.i_house, c.d_close_law,e.ven_name,a.* from lan:serv_cutlck a ")
					  .append(" left join lan:acxlckmd b on b.i_company=a.i_company and b.i_project=a.i_project and b.i_lock=a.i_lock ")
					  .append(" left join lan:acscontr c on c.i_company=a.i_company and c.i_project=a.i_project and c.i_sort=a.i_lock and c.f_contr is null ")
					  .append(" left join lan:unit d on d.i_company=a.i_company and d.i_project=a.i_project and d.i_lock=a.i_lock and d.unit_status='OPN' ")
					  .append(" left join lan:vendor e on e.ven_no=d.ven_no where 1=1 ");
				if (t_typ.equals("A")) {
				      sql.append(" and c.d_close_law between '"+startDate+"' and '"+endDate+"' ");
				}
				if (!selProj.equalsIgnoreCase("ALL")) {
					  sql.append(" and a.i_company='").append(iCompany).append("' ")
							.append(" and a.i_project='").append(iProject).append("' ");
				}		
				if (orderBy.trim().length()>0 && orderType.trim().length()>0) {
				   sql.append(" order by "+orderBy+" "+orderType);
				} else {
				   sql.append(" order by a.i_company,a.i_project,a.i_lock asc");
				}
//System.out.println(sql.toString());
				servlog.startLog(sql.toString());
		        rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
		        for (int i=0;i<maxRow;i++) { 
                      if (rs.next()) {
                         if ((i+1)>=(startRow+1) && (i+1)<=endRow) {
                            //------ Data is in this page , display -----//
							iCom = doString.checkString(rs.getString("i_company"),""); 
							iProj = doString.checkString(rs.getString("i_project"),""); 
				            String iLock = doString.checkString(rs.getString("i_lock"),"");
				            String iModel = doString.checkString(rs.getString("i_model"),"");
							String venName = doString.checkString(doString.DisplayThai(rs.getString("ven_name")),"");
							String iCutType = doString.checkString(rs.getString("i_cut_type"),"");
							double zCutAmount = rs.getDouble("z_amount");
							double prevSumContr = 0.0;
							double prevSumOther = 0.0;
							double currSumContr = 0.0;
							double currSumOther = 0.0;
				            
			                //-------- d_close_law Date --------// 
							String dCloseLaw = "";
						    Timestamp tmp = rs.getTimestamp("d_close_law");
						    if (tmp!=null)  {
								Calendar cal = Calendar.getInstance();
						        cal.setTime(tmp);      
								cal.add(Calendar.YEAR,1);
							    dCloseLaw = getDateFromCalendar(cal);    
						    }


							//-------------- get old commulative money ---------//
							sql.delete(0,sql.length());
							sql.append(" select * from lan:serv_sumcut a ")
							      .append(" where a.i_company='").append(iCom).append("' ")
							      .append(" and a.i_project='").append(iProj).append("' ")
							      .append(" and a.i_lock='").append(iLock).append("' ");
							servlog.startLog(sql.toString());
							rs1 = stmt1.executeQuery(sql.toString());
							servlog.endLog();
							while (rs1.next()) {
									prevSumContr += rs1.getDouble("z_sumcut_con");
									prevSumOther += rs1.getDouble("z_sumcut_oth");									
							}
							rs1.close();

							//-------------- get summary money ---------//
							sql.delete(0,sql.length());
							sql.append(" select b.i_ven_cut,month(b.d_payment) as pay_month,year(b.d_payment) as pay_year , ")
								  .append(" b.f_contr,sum(b.z_amount_pv) as sum_pv from lan:serv_dochd a, lan:serv_payment b ")
								  .append(" where b.f_itmstatus='CLS' and b.i_docno=a.i_docno ")
							      .append(" and a.i_company='").append(iCom).append("' ")
							      .append(" and a.i_project='").append(iProj).append("' ")
							      .append(" and a.i_lock='").append(iLock).append("' ");
						if (t_typ.equals("A")) {
							 sql.append(" and a.d_close_law between '"+startDate+"' and '"+endDate+"' ");
						}
						     sql.append(" group by b.i_ven_cut,b.d_payment,b.f_contr ");
							 //out.println(sql.toString());
							servlog.startLog(sql.toString());
							rs1 = stmt1.executeQuery(sql.toString());
							servlog.endLog();
							while (rs1.next()) {
									String fContr = doString.checkString(rs1.getString("f_contr"),"");
									String iVenCut = doString.checkString(rs1.getString("i_ven_cut"),"");
									int payMonth = rs1.getInt("pay_month");
									int payYear = rs1.getInt("pay_year");
									double sumPv = rs1.getDouble("sum_pv");
									if (payYear>2400) payYear -= 543;


									if (payYear==checkYear && payMonth==checkMonth) {
										if ((iCutType.equals("1") || iCutType.equals("2") || iCutType.equals("3")) && (iVenCut.equalsIgnoreCase("999999"))) {
											if (fContr.equalsIgnoreCase("Y")) {
												currSumContr += sumPv;
											} else {
												currSumOther += sumPv;
											}
										} else {
											currSumOther += sumPv;
										}
										/*
										if (fContr.equalsIgnoreCase("N")) {
											currSumOther += sumPv;
										} else {
											currSumContr += sumPv;
										}
										*/
									} else if ((payYear<checkYear) || ((payYear==checkYear) && payMonth<checkMonth)) {
										if (payYear>2007 || (payYear==2007 && payMonth>10)) {
											if ((iCutType.equals("1") || iCutType.equals("2") || iCutType.equals("3")) && (iVenCut.equalsIgnoreCase("999999"))) {
												if (fContr.equalsIgnoreCase("Y")) {
													prevSumContr += sumPv;
												} else {
													prevSumOther += sumPv;
												}
											} else {
												prevSumOther += sumPv;
											}
											/*
											if (fContr.equalsIgnoreCase("N")) {
												prevSumOther += sumPv;
											} else {
												prevSumContr += sumPv;
											}
											*/
										}
									} else {
										continue;
									}

							}
							rs1.close();


					        %>
							<tr>
							  <td width="3%" align="center" class="dotline"><%=(i+1)%></td>
							  <td width="8%" align="center" class="dotline"><%=iCom+":"+iProj%></td>
							  <td width="4%" align="center" class="dotline" style="mso-number-format:'\@';"><A HREF="javascript:goDetail('<%=doString.checkString(iLock,"&nbsp;")%>','<%=doString.checkString(iModel,"&nbsp;")%>')"><%=doString.checkString(iLock,"&nbsp;")%></A></td>
							  <td width="7%" class="dotline" align="center"><%=doString.checkString(iModel,"&nbsp;")%></td>
							  <td width="5%" class="dotline" align="center"><%=doString.checkString(dCloseLaw,"&nbsp;")%></td>
							  <td width="14%" class="dotline ; item"><nobr><%=doString.checkString(venName,"&nbsp;")%></nobr></td>
							  <td width="7%" class="dotline" align="right"><%=format.format(prevSumContr)%></td>
							  <td width="7%" align="right" class="dotline"><%=format.format(prevSumOther)%></td>
							  <td width="7%" align="right" class="dotline"><%=format.format(currSumContr)%></td>
							  <td width="7%" class="dotline" align="right"><%=format.format(currSumOther)%></td>
							  <td width="7%" class="dotline" align="right"><%=format.format(currSumContr+prevSumContr)%></td>
							  <td width="7%" class="dotline" align="right"><%=format.format(currSumOther+prevSumOther)%></td>
							  <td width="7%" align="right" class="dotline"><%=format.format(currSumContr+prevSumContr+currSumOther+prevSumOther)%></td>
							  <td width="3%" align="right" class="dotline"><%=doString.checkString(iCutType,"&nbsp;")%></td>
							  <td width="7%" align="right" class="dotline"><%=format.format(zCutAmount)%></td>
							  <!--<td width="9%" align="right" class="dotline"><%//=format.format(zCutAmount-(currSumContr+prevSumContr+currSumOther+prevSumOther))%></td>-->
							  <td width="9%" align="right" class="dotline"><%=format.format(zCutAmount-(currSumContr+prevSumContr))%></td>
							</tr>					        
					        <%
					        
 					         line++;                         
                         } // end if check row
                         
                         if (i>endRow) break;                         
                      } //end if check rs
                } // end for
                
	           while (line<displayLine) {
	               line++;
	                %>    
					<tr>
					  <td width="3%" align="center" class="dotline">&nbsp;</td>
					  <td width="8%" align="center" class="dotline">&nbsp;</td>
					  <td width="4%" align="center" class="dotline">&nbsp;</td>
					  <td width="7%" class="dotline" align="center">&nbsp;</td>
					  <td width="5%" class="dotline" align="center">&nbsp;</td>
					  <td width="14%" class="dotline ; item">&nbsp;</td>
					  <td width="7%" class="dotline" align="right">&nbsp;</td>
					  <td width="7%" align="right" class="dotline">&nbsp;</td>
					  <td width="7%" align="right" class="dotline">&nbsp;</td>
					  <td width="7%" class="dotline" align="right">&nbsp;</td>
					  <td width="7%" class="dotline" align="right">&nbsp;</td>
					  <td width="7%" class="dotline" align="right">&nbsp;</td>
					  <td width="7%" align="right" class="dotline">&nbsp;</td>
					  <td width="3%" align="center" class="dotline">&nbsp;</td>
					  <td width="7%" align="right" class="dotline">&nbsp;</td>
					  <td width="9%" align="right" class="dotline">&nbsp;</td>
					</tr>		        
	                <%               
	           }		  
		%>
                          


		<%

		//-------------- get total money ---------//
		double prevTotalContr = 0.0;
		double prevTotalOther = 0.0;
		double currTotalContr = 0.0;
		double currTotalOther = 0.0;
		double cutTotal = 0.0;

		//-------------- get old commulative money ---------//
		sql.delete(0,sql.length());
		sql.append(" select sum(z_sumcut_con) as sum_con,sum(z_sumcut_oth) as sum_oth from lan:serv_sumcut a ");
		if (!selProj.equalsIgnoreCase("ALL")) {
			  sql.append(" where a.i_company='").append(iCompany).append("' ")
					.append(" and a.i_project='").append(iProject).append("' ");
		}
		servlog.startLog(sql.toString());
		rs1 = stmt1.executeQuery(sql.toString());
		servlog.endLog();
		while (rs1.next()) {
				prevTotalContr += rs1.getDouble("sum_con");
				prevTotalOther += rs1.getDouble("sum_oth");									
		}
		rs1.close();

		//-------------- get total money ---------//
		currTotalContr = 0;
		currTotalOther = 0;
		prevTotalContr = 0;
		cutTotal = 0;

		sql.delete(0,sql.length());
		sql.append(" select b.i_ven_cut,a.i_type_cutlck,month(b.d_payment) as pay_month,year(b.d_payment) as pay_year , ")
			  .append(" b.f_contr,sum(b.z_amount_pv) as sum_pv from lan:serv_dochd a, lan:serv_payment b ")
			  .append(" where b.f_itmstatus='CLS' and b.i_docno=a.i_docno ");
		if (!selProj.equalsIgnoreCase("ALL")) {
			  sql.append(" and a.i_company='").append(iCompany).append("' ")
					.append(" and a.i_project='").append(iProject).append("' ");    
		}
		if (t_typ.equals("A")) {
				      sql.append(" and a.d_close_law between '"+startDate+"' and '"+endDate+"' ");
		}
		sql .append(" group by b.i_ven_cut,a.i_type_cutlck,b.d_payment,b.f_contr ");
//out.println(sql.toString());
		servlog.startLog(sql.toString());
		rs1 = stmt1.executeQuery(sql.toString());
		servlog.endLog();
		while (rs1.next()) {
				String iCutType = doString.checkString(rs1.getString("i_type_cutlck"),"");
				String iVenCut = doString.checkString(rs1.getString("i_ven_cut"),"");
				String fContr = doString.checkString(rs1.getString("f_contr"),"");
				int payMonth = rs1.getInt("pay_month");
				int payYear = rs1.getInt("pay_year");
				double sumPv = rs1.getDouble("sum_pv");
				if (payYear>2400) payYear -= 543;


				if (payYear==checkYear && payMonth==checkMonth) {
					if ((iCutType.equals("1") || iCutType.equals("2") || iCutType.equals("3")) && (iVenCut.equalsIgnoreCase("999999"))) {
						if (fContr.equalsIgnoreCase("Y")) {
							currTotalContr += sumPv;
						} else {
							currTotalOther += sumPv;
						}
					} else {
						currTotalOther += sumPv;
					}
					/*
					if (fContr.equalsIgnoreCase("N")) {
						currTotalOther += sumPv;
					} else {
						currTotalContr += sumPv;
					}
					*/
				} else if ((payYear<checkYear) || ((payYear==checkYear) && payMonth<checkMonth)) {
					if (payYear>2007 || (payYear==2007 && payMonth>10)) {
						if ((iCutType.equals("1") || iCutType.equals("2") || iCutType.equals("3")) && (iVenCut.equalsIgnoreCase("999999"))) {
							if (fContr.equalsIgnoreCase("Y")) {
								prevTotalContr += sumPv;
							} else {
								prevTotalOther += sumPv;
							}
						} else {
							prevTotalOther += sumPv;
						}
						/*
						if (fContr.equalsIgnoreCase("N")) {
							prevTotalOther += sumPv;
						} else {
							prevTotalContr += sumPv;
						}
						*/
					}
				} else {
					continue;
				}

		}
		rs1.close();		


		//------------- find cut total ---------//
		sql.delete(0,sql.length());
		sql.append(" select  sum(z_amount) as sum_cut from lan:serv_cutlck a ")
			  .append(" left join lan:acscontr c on c.i_company=a.i_company and c.i_project=a.i_project and c.i_sort=a.i_lock and c.f_contr is null ")
			  .append(" where 1=1 ");
		if (!selProj.equalsIgnoreCase("ALL")) {
			  sql.append(" and a.i_company='").append(iCompany).append("' ")
					.append(" and a.i_project='").append(iProject).append("' ");    
		}
		if (t_typ.equals("A")) {
				      sql.append(" and c.d_close_law between '"+startDate+"' and '"+endDate+"' ");
		}

		servlog.startLog(sql.toString());
		rs1 = stmt1.executeQuery(sql.toString());
		servlog.endLog();
		if (rs1.next()) {
			cutTotal = rs1.getDouble("sum_cut");
		} // if 
		rs1.close();
		
		%>
        <tr>
          <td align="center" class="dotline ; item" colspan="6">รวม (ข้อมูลทุกหน้า)</td>
		  <td width="7%" class="dotline ; item" align="right"><%=format.format(prevTotalContr)%></td>
		  <td width="7%" align="right" class="dotline ; item"><%=format.format(prevTotalOther)%></td>
		  <td width="7%" align="right" class="dotline ; item"><%=format.format(currTotalContr)%></td>
		  <td width="7%" class="dotline ; item" align="right"><%=format.format(currTotalOther)%></td>
		  <td width="7%" class="dotline ; item" align="right"><%=format.format(currTotalContr+prevTotalContr)%></td>
		  <td width="7%" class="dotline ; item" align="right"><%=format.format(currTotalOther+prevTotalOther)%></td>
		  <td width="7%" align="right" class="dotline ; item"><%=format.format(currTotalContr+prevTotalContr+currTotalOther+prevTotalOther)%></td>
          <td width="3%" align="center" class="dotline ; item">&nbsp;</td>
          <td width="7%" align="right" class="dotline ; item"><%=format.format(cutTotal)%></td>
          <td width="9%" align="right" class="dotline ; item"><%=format.format(cutTotal-(currTotalContr+prevTotalContr))%></td>
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
        <tr class="gray">
          <td width="100%" align="right"><%=pageLink%></td>
        </tr>
      </table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td align="left"><br><%=allCutType%></td>
  </tr>
  <tr>
    <td align="left"><br>** ประเภทการตัดเงิน</td>
  </tr>
</table>


<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="80" class="act_tab2">
				 &nbsp; 
			 <img border="0" src="images/act_print.gif" onclick="printReport();"                                   
					onmouseout=nereidFade(this,70,50,5)    
						onmouseover=nereidFade(this,100,50,5)     
						style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">
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
		System.out.println("ERROR SERV_Report6.jsp : " + e.getMessage());
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