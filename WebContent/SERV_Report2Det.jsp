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

<%!

public Integer[] newIntegerArray(int size) {
	Integer data[] = new Integer[size];
	for (int l=0;l<size;l++) {
		  data[l] = new Integer(0);
	}

	return data;
}

public Double[] newDoubleArray(int size) {
	Double data[] = new Double[size];
	for (int l=0;l<size;l++) {
		  data[l] = new Double(0.0);
	}

	return data;
}

public String convertTimestamp(Timestamp data,int addType,int addVal) {
	String result = "";
	Calendar cal = Calendar.getInstance();
	if (data!=null)  {
		cal.setTime(data);
		if (addType>0) {
			cal.add(addType,addVal); 
		}
		result = getDateFromCalendar(cal);
		if (result.trim().length()==10) result = result.trim().substring(0,6)+result.trim().substring(8,10);
	}

    return result;
}

%>

<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_Report2Det.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   doString str = new doString();
   DecimalFormat  format1 = new DecimalFormat("#,###,##0");
   DecimalFormat  format2 = new DecimalFormat("#,###,##0.00");


   String monthReport = doString.checkString(request.getParameter("month_report"),"0");
   String yearReport = doString.checkString(request.getParameter("year_report"),"0");

   String keyProject = doString.checkString(request.getParameter("key_project"),"");
   String[] projList = request.getParameterValues("sel_proj");

   String startDate = doString.checkString(request.getParameter("start_date"),"");
   String startMonth = doString.checkString(request.getParameter("start_month"),"");
   String startYear = doString.checkString(request.getParameter("start_year"),"0");
   String endDate = doString.checkString(request.getParameter("end_date"),"");
   String endMonth = doString.checkString(request.getParameter("end_month"),"");
   String endYear = doString.checkString(request.getParameter("end_year"),"0");


   String startQueryDate = startYear+"-"+startMonth+"-"+startDate;
   String endQueryDate = endYear+"-"+endMonth+"-"+endDate;
   double total_qarea = 0, total_publicamt = 0, total_amount = 0, total_estcon = 0;
   //----============ Declare Variables for input data ===========----//
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	SERV_CommonData common = null;
   Calendar now = Calendar.getInstance(Locale.ENGLISH);


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




		//---============= get Project Details ===============----//
		String projectName = "";
		sql.delete(0,sql.length()); 
		sql.append(" select * from lan:acxprojt ")
			  .append(" where i_company='").append(keyProject.length()>=6 ? keyProject.substring(0,2) : "").append("' ")
			  .append(" and i_project='").append(keyProject.length()>=6 ? keyProject.substring(3,6) : "").append("' ");
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		while (rs.next()) {
			 projectName = str.replace(keyProject,":","-")+" "+doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
		} // end while
		rs.close();



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



		//----============== Count Max Row ==================-----//
		int maxRow = 0;
		sql.delete(0,sql.length());
		sql.append(" select count(*) cnt from lan:acsregis a ")
			  .append(" where a.d_close_law between '").append(startQueryDate).append("' and '").append(endQueryDate).append("' ")
			  .append(" and a.i_company='").append(keyProject.length()>=6 ? keyProject.substring(0,2) : "").append("' ")
			  .append(" and a.i_project='").append(keyProject.length()>=6 ? keyProject.substring(3,6) : "").append("' ");
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		while (rs.next()) {
			 maxRow = rs.getInt("cnt");
		} // end while
		rs.close();


        
        
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
<TITLE>Open Job List</TITLE>
<STYLE>
 .fg_style1 { mso-number-format:"\@";}
</STYLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">
<!--

  function searchData() {
     if (!validDate()) {
        return false;
     }
  
     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Report2Det.jsp";
     document.forms[0].submit();  
  }

  function goReport21(docno) {
     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Report2_1.jsp";
     document.forms[0].submit();
  }

  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Report2Det.jsp";
     document.forms[0].submit();
  }


function printReport() {
     if (!validDate()) {
        return false;
     }

   document.forms[0].action="<%=Constants.APP_PATH%>/SERV_PrintReport2DetServlet";
   //document.forms[0].action="http://www9.lh.co.th/LHServ/SERV_PrintReport2DetServlet";
   document.forms[0].target="_blank";
   document.forms[0].submit();
   document.forms[0].target="";
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

//-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">


<FORM ACTION="" METHOD="POST">


<input type="hidden" name="month_report" value="<%=monthReport%>">
<input type="hidden" name="year_report" value="<%=yearReport%>">

<input type="hidden" name="key_project" value="<%=keyProject%>">
<input type="hidden" name="now_page" value="<%=nowPage%>">

<%
    if (projList!=null) {
	    for (int i=0;i<projList.length;i++) {
			  %><input type="hidden" name="sel_proj" value="<%=doString.checkString(projList[i],"")%>"><%
		} // end for
    }
%>


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp; 
            สรุปจำนวนบ้านโอนย้อนหลัง 24 เดือน</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


      <br style="font-size:10pt">


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250"><nobr>โครงการ : <%=projectName%></nobr></td>
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
                <td width="5%" height="22" class="item ; dotline01"> วันที่ &nbsp; 
					<%=common.genDateOfMonthListbox("start_date",startDate," class='box' ")%> 
					<%=common.genMonthListbox("start_month",startMonth," class='box' ")%> 
					<%=common.genYearListbox("start_year",startYear," class='box' ",now.get(Calendar.YEAR)-15,15)%> 					
					&nbsp; ถึง &nbsp; 
					<%=common.genDateOfMonthListbox("end_date",endDate," class='box' ")%> 
					<%=common.genMonthListbox("end_month",endMonth," class='box' ")%> 
					<%=common.genYearListbox("end_year",endYear," class='box' ",now.get(Calendar.YEAR)-15,15)%> 		
				    &nbsp; &nbsp; &nbsp; <a href="#" onclick="searchData()"><img border="0" src="images/i_search.gif" align="absmiddle" width="20" height="20"></a> 
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


<br style="font-size:5pt">


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
                <td width="1%" rowspan="2" class="col_name">ลำดับ</td>
                <td width="7%" rowspan="2" align="center" valign="middle" class="col_name">ชื่อ-สกุล / โทรศัพท์</td>
<!--                <td width="4%" rowspan="2" align="center" valign="middle" class="col_name">โทรศัพท์</td>  -->
                <td width="3%" rowspan="2" align="center" valign="middle" class="col_name">แปลง</td>
                <td width="3%" rowspan="2" align="center" valign="middle" class="col_name">บ้านเลขที่</td>
                <td width="3%" rowspan="2" align="center" valign="middle" class="col_name">พื้นที่</td>
                <td width="3%" rowspan="2" align="center" valign="middle" class="col_name">แบบบ้าน</td>
                <td width="3%" rowspan="2" align="center" valign="middle" class="col_name">วันที่ทำสัญญา</td>
                <td width="3%" rowspan="2" align="center" valign="middle" class="col_name">วันที่โอน</td>
                <td width="3%" rowspan="2" align="center" valign="middle" class="col_name">วันที่หมดประกัน</td>
                <td width="3%" rowspan="2" align="center" valign="middle" class="col_name">วันที่จ่ายงวด 9</td>
                <td width="3%" rowspan="2" align="center" valign="middle" class="col_name">วันที่ End Product</td>
                <td width="3%" rowspan="2" align="center" valign="middle" class="col_name">ผู้รับเหมาสร้าง</td>
                <td width="3%" rowspan="2" align="center" valign="middle" class="col_name">ราคาจ้างเหมา</td>
                <td height="1" colspan="2" align="center" valign="middle" class="col_name">รูปแบบการตัดเงิน</td>
                <td colspan="3" align="center" valign="middle" class="col_name">ค่าบริการสาธารณะ</td>
              </tr>
              <tr> 
                <td width="2%" height="1" align="center" valign="middle" class="col_name"><b style="color:red">*</b></td>
                <td width="2%" align="center" valign="middle" class="col_name">บาท</td>
                <td width="2%" align="center" valign="middle" class="col_name">แบบ</td>
                <td width="2%" align="center" valign="middle" class="col_name">บาท/ตรว.</td>
                <td width="2%" align="center" valign="middle" class="col_name">จำนวนเงิน</td>
              </tr>
				<%
					//----========================= Get DOCHD Data  ==============================-----//
					int line=0;
					int dataLine = 0;

					sql.delete(0,sql.length());
					sql.append(" select trim(b.n_prename)||trim(b.n_ncustomer)||' '||trim(b.n_scustomer) as cust_name ")
						  .append(" ,b.a_id_tel,b.a_wk_tel,b.a_etc_tel,a.d_close_law,a.i_company,a.i_project,a.i_lor ")
						  .append(" from lan:acsregis a ")
						  .append(" left join lan:acxcusto b on b.i_customer=a.i_cus_intent1 ")
						  .append(" where a.d_close_law between '").append(startQueryDate).append("' and '").append(endQueryDate).append("' ")
						  .append(" and a.i_company='").append(keyProject.length()>=6 ? keyProject.substring(0,2) : "").append("' ")
						  .append(" and a.i_project='").append(keyProject.length()>=6 ? keyProject.substring(3,6) : "").append("' ")
						  .append(" order by 1 ");
					servlog.startLog(sql.toString());
					rs = stmt.executeQuery(sql.toString());
					servlog.endLog();
					for (int i=0;i<maxRow;i++) {
						  if (rs.next()) {
							dataLine++;
							 if (dataLine>startRow && dataLine<=endRow) {
									line++;

									String custName = doString.checkString(doString.DisplayThai(rs.getString("cust_name")),"");
									String iLor = doString.checkString(rs.getString("i_lor"),"");

									String dCloseLaw = convertTimestamp(rs.getTimestamp("d_close_law"),0,0);
									String expireDate = convertTimestamp(rs.getTimestamp("d_close_law"),Calendar.YEAR,1);

									String idTel = doString.checkString(doString.DisplayThai(rs.getString("a_id_tel")),"");
									String workTel = doString.checkString(doString.DisplayThai(rs.getString("a_wk_tel")),"");
									String etcTel = doString.checkString(doString.DisplayThai(rs.getString("a_etc_tel")),"");
									String showTel = idTel;
									if (showTel.trim().length()>0 && workTel.trim().length()>0) showTel += " , ";
									showTel += workTel;
									if (showTel.trim().length()>0 && etcTel.trim().length()>0) showTel += " , ";
									showTel += etcTel;



									//----=============== Get Other Data with i_lor ====================-----//
									String iLock = "";
									String iHouse = "";
									String qArea = "";
									String iModel = "";
									String dLoi = "";
									String qcDate = "";
									String zPrice = "";
									String zPublicAmount = "";
									
									sql.delete(0,sql.length());
									sql.append(" select a.i_lock,d.i_house,a.q_area,d.i_model,e.d_loi,g.date_qc,k.z_price,l.z_amount from lan:acxslock a ")
										  .append(" left join lan:acxlckmd d on d.i_company=a.i_company and d.i_project=a.i_project and d.i_lor=a.i_lor ")
										  .append(" left join lan:acscontr e on e.i_company=a.i_company and e.i_project=a.i_project and e.i_lor=a.i_lor ")
										  .append(" left join lan:acxlckhd g on g.i_company=a.i_company and g.i_project=a.i_project and g.i_lor=a.i_lor ")
										  .append(" left join lan:acspubdt k on k.i_company=a.i_company and k.i_project=a.i_project and k.i_phase=a.i_phase ")
										  .append(" left join lan:acrduerv l on l.i_company=a.i_company and l.i_project=a.i_project and l.i_lor=a.i_lor and l.i_due='C0' ")
										  .append(" where a.i_company='").append(keyProject.length()>=6 ? keyProject.substring(0,2) : "").append("' ")
										  .append(" and a.i_project='").append(keyProject.length()>=6 ? keyProject.substring(3,6) : "").append("' ")
										  .append(" and a.i_lor='").append(iLor).append("'  ");
									servlog.startLog(sql.toString());
									rs1 = stmt1.executeQuery(sql.toString());
									servlog.endLog();
									if (rs1.next()) {
								   	    iLock = doString.checkString(rs1.getString("i_lock"),"");
									    iHouse = doString.checkString(rs1.getString("i_house"),"");
									    qArea = format2.format(rs1.getDouble("q_area"));
									    iModel = doString.checkString(rs1.getString("i_model"),"");
									    dLoi = convertTimestamp(rs1.getTimestamp("d_loi"),0,0);
									    qcDate = convertTimestamp(rs1.getTimestamp("date_qc"),0,0);
										zPrice = format2.format(rs1.getDouble("z_price"));
										zPublicAmount = format2.format(rs1.getDouble("z_amount"));

										//total_qarea += rs1.getDouble("q_area");
										//total_publicamt += rs1.getDouble("z_amount");
									}
									rs1.close();
								
									


									//----=============== Get Other Data width i_lock ====================-----//
									String lastPaidDate = "";
									String venNo = "";
									String estConst1 = "";
									String zAmount = "";
									String nDesc = "";
									sql.delete(0,sql.length());
									sql.append(" select a.last_paid_date,h.ven_no,h.est_const_1 ,i.i_cut_type,i.z_amount from lan:untcon a ")
										  .append(" left join lan:unit h on h.i_company=a.i_company and h.i_project=a.i_project and h.i_lock=a.i_lock ")
										  .append(" left join lan:serv_cutlck i on i.i_company=a.i_company and i.i_project=a.i_project and i.i_lock=a.i_lock ")
//										  .append(" left join lan:serv_xstd j on j.i_type='03' and trim(j.i_code)=trim(i.i_cut_type ")
										  .append(" where a.i_company='").append(keyProject.length()>=6 ? keyProject.substring(0,2) : "").append("' ")
										  .append(" and a.i_project='").append(keyProject.length()>=6 ? keyProject.substring(3,6) : "").append("' ")
										  .append(" and a.i_lock='").append(iLock).append("' and a.ins_no='9'  ");
									servlog.startLog(sql.toString());						
									rs1 = stmt1.executeQuery(sql.toString());
									servlog.endLog();
									if (rs1.next()) {
									    lastPaidDate = convertTimestamp(rs1.getTimestamp("last_paid_date"),0,0);
								   	    venNo = doString.checkString(rs1.getString("ven_no"),"");
									    estConst1 = format2.format(rs1.getDouble("est_const_1"));
									    zAmount = format2.format(rs1.getDouble("z_amount"));
									    nDesc = doString.checkString(rs1.getString("i_cut_type"),"");

										//total_amount += rs1.getDouble("z_amount");
										//total_estcon += rs1.getDouble("est_const_1");
									}
									rs1.close();									
				

									if (custName.trim().length()>30) custName = custName.substring(0,30);
									if (showTel.trim().length()>30) showTel = showTel.substring(0,30);

									%>
									  <tr> 
										<td valign="top" class="dotline"><%=dataLine%></td>
										<td align="left" valign="top" class="dotline" class = fg_style1>
										<nobr><%=doString.checkString(custName,"&nbsp;")%></nobr><br>
										<nobr>'<%=doString.checkString(showTel,"&nbsp;")%>'</nobr>
										</td>
<!--										<td width="4%" height="1" align="center" valign="top" class="dotline"><%=doString.checkString(showTel,"&nbsp;")%></td>-->
										<td height="1" align="center" valign="top" class="dotline" style="mso-number-format:'\@';"><%=doString.checkString(iLock,"&nbsp;")%></td>
										<td height="1" align="center" valign="top" class="dotline"><%=doString.checkString(iHouse,"&nbsp;")%></td>
										<td height="1" align="center" valign="top" class="dotline"><%=doString.checkString(qArea,"&nbsp;")%></td>
										<td height="1" align="center" valign="top" class="dotline"><%=doString.checkString(iModel,"&nbsp;")%></td>
										<td height="1" align="center" valign="top" class="dotline">-</td>  <%/*=doString.checkString(dLoi,"&nbsp;") */%>
										<td height="1" align="center" valign="top" class="dotline"><%=doString.checkString(dCloseLaw,"&nbsp;")%></td>
										<td height="1" align="center" valign="top" class="dotline"><%=doString.checkString(expireDate,"&nbsp;")%></td>
										<td height="1" align="center" valign="top" class="dotline">-</td>  <%/*=doString.checkString(lastPaidDate,"&nbsp;")*/ %>
										<td align="center" valign="top" class="dotline"><%=doString.checkString(qcDate,"&nbsp;")%></td>
										<td align="center" valign="top" class="dotline"><%=doString.checkString(venNo,"&nbsp;")%></td>
										<td align="center" valign="top" class="dotline">-</td>  <%/*=doString.checkString(estConst1,"&nbsp;") */%>
										<td width="2%" align="center" valign="top" class="dotline"><%=doString.checkString(nDesc,"&nbsp;")%></td>
										<td width="2%" align="right" valign="top" class="dotline"><%=doString.checkString(zAmount,"&nbsp;")%></td>
										<td width="2%" align="center" valign="top" class="dotline">C0</td>
										<td width="2%" align="right" valign="top" class="dotline"><%=doString.checkString(zPrice,"&nbsp;")%></td>
										<td width="2%" align="right" valign="top" class="dotline"><%=doString.checkString(zPublicAmount,"&nbsp;")%></td>
									  </tr>					
									<%
									sql.delete(0,sql.length());
									sql.append(" select a.i_lock,d.i_house,a.q_area,d.i_model,e.d_loi,g.date_qc,k.z_price,l.z_amount from lan:acxslock a ")
										  .append(" left join lan:acxlckmd d on d.i_company=a.i_company and d.i_project=a.i_project and d.i_lor=a.i_lor ")
										  .append(" left join lan:acscontr e on e.i_company=a.i_company and e.i_project=a.i_project and e.i_lor=a.i_lor ")
										  .append(" left join lan:acxlckhd g on g.i_company=a.i_company and g.i_project=a.i_project and g.i_lor=a.i_lor ")
										  .append(" left join lan:acspubdt k on k.i_company=a.i_company and k.i_project=a.i_project and k.i_phase=a.i_phase ")
										  .append(" left join lan:acrduerv l on l.i_company=a.i_company and l.i_project=a.i_project and l.i_lor=a.i_lor and l.i_due='C0' ")
										  .append(" where a.i_company='").append(keyProject.length()>=6 ? keyProject.substring(0,2) : "").append("' ")
										  .append(" and a.i_project='").append(keyProject.length()>=6 ? keyProject.substring(3,6) : "").append("' ")
										  .append(" and e.d_close_law between '"+startQueryDate+"' and '"+endQueryDate+"' ");
									servlog.startLog(sql.toString());
									rs1 = stmt1.executeQuery(sql.toString());
									servlog.endLog();
									while (rs1.next()) {
										total_qarea += rs1.getDouble("q_area");
										total_publicamt += rs1.getDouble("z_amount");
									}
									rs1.close();

											
									sql.delete(0,sql.length());
									sql.append(" select a.last_paid_date,h.ven_no,h.est_const_1 ,i.i_cut_type,i.z_amount from lan:untcon a ")
										  .append(" left join lan:unit h on h.i_company=a.i_company and h.i_project=a.i_project and h.i_lock=a.i_lock ")
										  .append(" left join lan:serv_cutlck i on i.i_company=a.i_company and i.i_project=a.i_project and i.i_lock=a.i_lock ")
										  .append(" where a.i_company='").append(keyProject.length()>=6 ? keyProject.substring(0,2) : "").append("' ")
										  .append(" and a.i_project='").append(keyProject.length()>=6 ? keyProject.substring(3,6) : "").append("' ")
										  .append(" and a.ins_no='9' ");									
									servlog.startLog(sql.toString());
									rs1 = stmt1.executeQuery(sql.toString());
									servlog.endLog();
									while (rs1.next()) {
											total_amount += rs1.getDouble("z_amount");
											total_estcon += rs1.getDouble("est_const_1");
									}
									rs1.close();
																				
							 } // end if between page							 
				

						} // end if rs.next()
						 if (i>endRow) break;		

					} // end for
					rs.close();
				   while (line<displayLine) {
					   line++;
					   %>
						  <tr> 
							<td width="1%" align="center" class="dotline">&nbsp;</td>
							<td width="7%" align="center" valign="middle" class="dotline">&nbsp;</td>
<!--							<td width="4%" height="1" align="center" valign="middle" class="dotline">&nbsp;</td>-->
							<td width="3%" height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="3%" height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="3%" height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="3%" height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="3%" height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="3%" height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="3%" height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="3%" height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="2%" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="2%" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="2%" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="2%" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="2%" align="center" valign="middle" class="dotline">&nbsp;</td>
						  </tr>
					   <%
				  }  // end while

//out.println("total_qarea="+total_qarea);



%>

						<tr> 
							<td width="1%" align="center" class="dotline">&nbsp;</td>
							<td width="7%" align="center" valign="middle" class="dotline"><FONT COLOR="#FF0000">Total รวมทุกหน้า</FONT></td>
							<td width="3%" height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="3%" height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="3%" height="1" align="center" valign="middle" class="dotline"><FONT COLOR="#FF0000"><%=format2.format(total_qarea)%></FONT></td>
							<td width="3%" height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="3%" height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="3%" height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="3%" height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="3%" height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="3%" align="center" valign="middle" class="dotline"><FONT COLOR="#FF0000"><%=format2.format(total_estcon)%></FONT></td>
							<td width="2%" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="2%" align="center" valign="middle" class="dotline"><FONT COLOR="#FF0000"><%=format2.format(total_amount)%></FONT></td>
							<td width="2%" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="2%" align="center" valign="middle" class="dotline">&nbsp;</td>
							<td width="2%" align="center" valign="middle" class="dotline"><FONT COLOR="#FF0000"><%=format2.format(total_publicamt)%></FONT></td>
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
</table>

<br style="font-size:10pt">



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="80" class="act_tab2">

            <img border="0" src="images/act_print.gif"  onclick="javascript:printReport();" 
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">&nbsp; 
            </td>      
                  	
                  	
            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="#" onclick="goReport21();" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
		System.out.println("ERROR SERV_Report2Det.jsp : " + e.getMessage());
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