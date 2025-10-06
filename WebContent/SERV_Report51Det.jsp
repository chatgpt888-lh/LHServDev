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

public String convertTimestamp(Timestamp data) {
	String result = "";
	Calendar cal = Calendar.getInstance();
	if (data!=null)  {
		cal.setTime(data);      
		result = getDateFromCalendar(cal);    
		if (result.trim().length()==10) result = result.trim().substring(0,6)+result.trim().substring(8,10);
	}

    return result;
}

%>

<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_Report51Det.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   doString str = new doString();
   DecimalFormat  format1 = new DecimalFormat("#,###,##0");
   DecimalFormat  format2 = new DecimalFormat("#,###,##0.00");

   String monthReport = doString.checkString(request.getParameter("month_report"),"0");
   String yearReport = doString.checkString(request.getParameter("year_report"),"0");
   String reportType = doString.checkString(request.getParameter("report_type"),"0");

   String keyDetail = doString.checkString(request.getParameter("key_detail"),"");
   String monthDetail = doString.checkString(request.getParameter("month_detail"),"0");
   String yearDetail = doString.checkString(request.getParameter("year_detail"),"0");
   String typeDetail = doString.checkString(request.getParameter("type_detail"),"");

 /*   if (Integer.parseInt(monthDetail) <= 9) {
			monthDetail = "0"+monthDetail;
   } else {
			monthDetail = monthDetail;
   }
*/
   //----============ Declare Variables for input data ===========----//
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	SERV_CommonData common = null;


	try {

        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();
		common = new SERV_CommonData(conn);
        //----=======================================----//



		//---=========== Month Initilize =========----//
		String thaiMonth[] = new String[] {"","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
		String showMonth = thaiMonth[Integer.parseInt(monthDetail)];
		String showYear = Integer.toString(Integer.parseInt(yearDetail)+543);


		//------=================== generate Condition ======================----//
		String condition = "";
		String label = "";
		if (keyDetail.equalsIgnoreCase("CURRENT")) {
			condition += " and month(a.d_keyin)="+monthDetail+" and year(a.d_keyin)="+yearDetail+" ";
			label = "ใบแจ้งซ่อมที่เกิดในเดือน";
		} else if (keyDetail.equalsIgnoreCase("COMPLETE")) {
			condition += " and month(a.d_complete)="+monthDetail+" and year(a.d_complete)="+yearDetail+" ";
			label = "ซ่อมเสร็จ (Complete แล้ว)";
		} else if (keyDetail.equalsIgnoreCase("CANCEL")) {
			condition += " and month(a.d_cancel)="+monthDetail+" and year(a.d_cancel)="+yearDetail+" ";
			label = "ใบแจ้งซ่อมที่ยกเลิกในเดือน";
		} else if (keyDetail.equalsIgnoreCase("INTIME")) {
			condition += " and a.f_appoint='Y' and a.d_complete is not null ";
			condition += " and month(a.d_complete)="+monthDetail+" and year(a.d_complete)="+yearDetail+" ";
			label = "ซ่อมเสร็จ (ตามกำหนดนัดหมาย) - ตามกำหนดนัดหมาย";
		} else if (keyDetail.equalsIgnoreCase("OVERTIME")) {
			condition += " and a.f_appoint='N' and a.d_complete is not null ";
			condition += " and month(a.d_complete)="+monthDetail+" and year(a.d_complete)="+yearDetail+" ";
			label = "ซ่อมเสร็จ (ตามกำหนดนัดหมาย) - เลยกำหนดนัดหมาย";
		} else if (keyDetail.equalsIgnoreCase("PAST_INTIME")) {
			condition += " and f_bf_past='N' ";
			label = "งานซ่อมคงค้างยกไป - ยังไม่เลยกำหนดนัดหมาย";
		} else if (keyDetail.equalsIgnoreCase("PAST_OVERTIME")) {
			condition += " and f_bf_past='Y' ";
			label = "งานซ่อมคงค้างยกไป - เลยกำหนดนัดหมาย";
		}
		//---==============================================================----//

%>


<HTML>
<HEAD>
<TITLE>Open Job List</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--

  function goReport51(docno) {
     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Report5_11.jsp";
     document.forms[0].submit();
  }


  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Report51Det.jsp";
     document.forms[0].submit();
  }


function printReport() {
   document.forms[0].action="<%=Constants.APP_PATH%>/SERV_PrintReport5DetServlet";
   //document.forms[0].action="http://www9.lh.co.th/LHServ/SERV_PrintReport5DetServlet";
   document.forms[0].target="_blank";
   document.forms[0].submit();
   document.forms[0].target="";
}


//-->
</script>

<FORM ACTION="" METHOD="POST">

<input type="hidden" name="month_report" value="<%=monthReport%>">
<input type="hidden" name="year_report" value="<%=yearReport%>">
<input type="hidden" name="report_type" value="<%=reportType%>">

<input type="hidden" name="key_detail" value="<%=keyDetail%>">
<input type="hidden" name="month_detail" value="<%=monthDetail%>">
<input type="hidden" name="year_detail" value="<%=yearDetail%>">
<input type="hidden" name="type_detail" value="<%=typeDetail%>">


<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">



<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            รายละเอียดใบแจ้งซ่อม</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


      <br style="font-size:10pt">



            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="220">ที่มาของข้อมูล</td>
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
    <td class="item ; dotline01" height="22" width="46%" colspan="2"><%=label%>
      : <%=showMonth+" &nbsp;"+showYear%></td>
<!--    <td height="22" width="27%" class="dotline01"><%=showMonth+" &nbsp;"+showYear%></td>-->
    <td height="22" class="dotline01" width="27%">&nbsp;</td>
    <td height="22" width="27%" class="dotline01"> &nbsp; </td>
  </tr>

	<%
	  String[] projList = request.getParameterValues("sel_proj");
  	  String queryProject = "";
	  int line = 0;

	  if (projList!=null) {
		  for (int i=0;i<projList.length;i++) {
				 String proj = doString.checkString(projList[i],"");  
				 if (queryProject.trim().length()>0) queryProject += " , ";
				 queryProject += " '"+proj+"' ";


				  %><input type="hidden" name="sel_proj" value="<%=proj%>"><%


				//---============= get Project Details ===============----//
				sql.delete(0,sql.length()); 
				sql.append(" select * from lan:acxprojt where i_company||':'||i_project='").append(proj).append("' ");
				servlog.startLog(sql.toString());
				rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
				while (rs.next()) {
					 String nProject = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
					 String iProj = str.replace(proj,":","-");	

					 if (line==0) {
						 %><tr><td class="item ; dotline01" height="22" width="10%">โครงการ :</td><%
					 } else if (line%3==0 && line!=0) {
						 %><tr><td class="item ; dotline01" height="22" width="10%">&nbsp;</td><%
					}

				    %><td height="22" width="30%" class="dotline01"><%=iProj%> <%=nProject%></td><%

					if (line%3==2) {
						%></tr><%
					}

					line++;
				} // end while
				rs.close();

		  } // end for

		  while (line%3!=0) {
			  %><td height="22" width="30%" class="dotline01">&nbsp;</td><%
			  line++;

		 	  if (line%3==0) {
			 	  out.print("</tr>");
			  }
		  }

	  } else {
		  queryProject = " 'NODATA' ";
	  }


		//----====================== Get DOCHD Max Row ==============================-----//
		int maxRow = 0;
		if (condition.trim().length()>0 && monthDetail.trim().length()>0 && yearDetail.trim().length()>0) {
			sql.delete(0,sql.length());
			sql.append(" select count(*) as cnt from lan:serv_mdoc a where ")
				  .append(" a.i_company||':'||a.i_project in (").append(queryProject).append(") ")
				  .append(" and a.i_rep_type='01' and a.i_year='"+(Integer.parseInt(yearDetail)+543)+"' and a.i_month="+monthDetail+" ")
				  .append(" and a.i_type = '"+typeDetail+"' ");
			//out.println(sql.toString());
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			while (rs.next()) {
			   maxRow = rs.getInt("cnt");
			}
			rs.close();
		}
		//---=========================================================================----//


		   //-----============== Generate Display Customize and Page Link ==================-----//
		   String displayType = doString.checkString(request.getParameter("display_type"),"");
		   int displayLine = Integer.parseInt(doString.checkString(request.getParameter("display_line"),"0"));
		   int nowPage = Integer.parseInt(doString.checkString(request.getParameter("now_page"),"1"));
		   if (displayType.equalsIgnoreCase("A")) {
			  displayLine = maxRow;
			  nowPage = 1;
		   }
		   if (displayLine<Constants.SERV_OPENJOBLIST_LINE) displayLine = Constants.SERV_OPENJOBLIST_LINE;

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


<input type="hidden" name="now_page" value="<%=nowPage%>">


<br style="font-size:10pt">


<!--
            <table border="1" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                
          <td class="item_tab2" width="200">รายละเอียดการซ่อม</td>
                <td class="item_tab3"></td>                
				<td>


				</td>
              </tr>
            </table>
-->




<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
	<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
	<td class="item_tab2" width="160">รายละเอียดการซ่อม</td>
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
          <td rowspan="2" class="col_name">ลำดับ</td>
          <td rowspan="2" class="col_name">เลขที่ใบแจ้งซ่อม</td>
          <td rowspan="2" class="col_name">แปลง</td>
          <td rowspan="2" class="col_name">เลขที่บ้าน</td>
          <td colspan="12" class="col_name">รายละเอียดตามหมวดงาน (จำนวนรายการ)</td>
          <td colspan="5" class="col_name">วันที่</td>
          <td class="col_name" rowspan="2">ดำเนินการ<br>
                  ถึงปัจจุบัน</td>
          <td class="col_name" rowspan="2">รวมค่าดำเนิน<br>
            การ 17%</td>
          <td class="col_name" colspan="3">ตัดเงินผู้รัเหมา</td>
          <td class="col_name" rowspan="2"> F</td>
        </tr>
        <tr>
          <td class="col_nameLow" width="1%">01</td>
          <td class="col_nameLow" width="1%">02</td>
          <td class="col_nameLow" width="1%">03</td>
          <td class="col_nameLow" width="1%">04</td>
          <td class="col_nameLow" width="1%">05</td>
          <td class="col_nameLow" width="1%">06</td>
          <td class="col_nameLow" width="1%">07</td>
          <td class="col_nameLow" width="1%">08</td>
          <td class="col_nameLow" width="1%">09</td>
          <td class="col_nameLow" width="1%">10</td>
          <td class="col_nameLow" width="1%">11</td>
          <td class="col_nameLow" width="1%">12</td>
          <td class="col_nameLow">รับเรื่อง</td>
          <td class="col_nameLow">Open  Job</td>
          <td class="col_nameLow">นัดซ่อม</td>
          <td class="col_nameLow">ประมาณการ</td>
          <td class="col_nameLow">Complete&nbsp;<br>
 Task</td>
          <td class="col_nameLow">17%</td>
          <td class="col_nameLow">35%</td>
          <td class="col_nameLow">LH</td>
        </tr>

<%
	//----========================= Get DOCHD Data  ==============================-----//
	line=0;
	int dataLine = 0;
	if (condition.trim().length()>0 && monthDetail.trim().length()>0 && yearDetail.trim().length()>0) {

			sql.delete(0,sql.length());
			sql.append(" select * from lan:serv_mdoc a, lan:serv_mdet b where ")
				  .append(" a.i_company||':'||a.i_project in (").append(queryProject).append(") ")
				  .append(" and a.i_rep_type='01' and a.i_year='"+(Integer.parseInt(yearDetail)+543)+"' and a.i_month="+monthDetail+" ")
				  .append(" and a.i_type = '"+typeDetail+"' ")
				  .append(" and a.i_docno = b.i_docno ")	
				  .append(" order by a.i_docno ");
			//out.println(sql.toString());
					servlog.startLog(sql.toString());
					rs = stmt.executeQuery(sql.toString());
					servlog.endLog();
					for (int i=0;i<maxRow;i++) {
						  if (rs.next()) {
						    dataLine++;
							 if (dataLine>startRow && dataLine<=endRow) {
								    line++;
									String iDocNo = doString.checkString(rs.getString("i_docno"),"");
									String iLock = doString.checkString(rs.getString("i_lock"),"");
									String iModel = doString.checkString(rs.getString("i_model"),"");
									String flag = doString.checkString(doString.DisplayThai(rs.getString("pv_no")),"");
									if (flag.trim().length()>0) {
										flag = "Y";
									} else {
										flag = "N";
									}

									String keyinDate = convertTimestamp(rs.getTimestamp("d_keyin"));
									String openJobDate = convertTimestamp(rs.getTimestamp("d_open_job"));
									String appointDate = convertTimestamp(rs.getTimestamp("d_appoint"));
									String estCloseDate = convertTimestamp(rs.getTimestamp("d_est_close"));
									String completeDate = convertTimestamp(rs.getTimestamp("d_complete"));

									String zAmountPv = format2.format(rs.getDouble("z_amount_pv"));
									String cut17 = format2.format(rs.getDouble("z_cut_17"));
									String cut35 = format2.format(rs.getDouble("z_cut_35"));
									String cutLH = format2.format(rs.getDouble("z_cut_LH"));


									Timestamp complete = rs.getTimestamp("d_complete");
									Timestamp estClose = rs.getTimestamp("d_est_close");

									long dateDiff = 0;
									if (estClose!=null) {
										Calendar scal = Calendar.getInstance(Locale.ENGLISH);
										Calendar ecal = Calendar.getInstance(Locale.ENGLISH);

										if (complete!=null) {
											ecal.setTime(complete);
										    scal.setTime(estClose);
										} else {
											ecal.set(Integer.parseInt(yearDetail),Integer.parseInt(monthDetail),1);
											ecal.add(Calendar.DATE,-1);
										    scal.setTime(estClose);
										}

										dateDiff = ((ecal.getTime().getTime() - scal.getTime().getTime())/(1000*60*60*24));
									}

									%>
									<tr>
									  <td class="dotline" align="center"><%=dataLine%></td>
									  <td class="dotline" align="center"><A HREF="SERV_OpenJob_Disp.jsp?i_docno=<%=doString.checkString(iDocNo)%>&edit=no"><%=doString.checkString(iDocNo,"&nbsp;")%></A></td>
									  <td class="dotline" align="center"><%=doString.checkString(iLock,"&nbsp;")%></td>
									  <td class="dotline" align="center"><%=doString.checkString(iModel,"&nbsp;")%></td>
									  <%
										for (int d=1;d<=12;d++) {
											  String data = format1.format(rs.getInt("q_itmjob_"+str.createID(d,2)));
											  %><td class="dotline" align="center" width="2%"><%=data%></td><%
										}
									  %>
									  <td class="dotline" align="center" width="5%"><%=doString.checkString(keyinDate,"&nbsp;")%></td>
									  <td class="dotline" align="center" width="5%"><%=doString.checkString(openJobDate,"&nbsp;")%></td>
									  <td class="dotline" align="center" width="5%"><%=doString.checkString(appointDate,"&nbsp;")%></td>
									  <td class="dotline" align="center" width="5%"><%=doString.checkString(estCloseDate,"&nbsp;")%></td>
									  <td class="dotline" align="center" width="5%"><%=doString.checkString(completeDate,"&nbsp;")%></td>
									  <td class="dotline" align="center"><%=format1.format(dateDiff)%></td>
									  <td class="dotline" align="right"><%=doString.checkString(zAmountPv,"&nbsp;")%></td>
									  <td class="dotline" align="right"><%=doString.checkString(cut17,"&nbsp;")%></td>
									  <td class="dotline" align="right"><%=doString.checkString(cut35,"&nbsp;")%></td>
									  <td class="dotline" align="right"><%=doString.checkString(cutLH,"&nbsp;")%></td>
									  <td class="dotline" align="center"> <%=doString.checkString(flag,"&nbsp;")%></td>
									</tr>						
									<%
							 } // end if between page
						} // end if rs.next()

						 if (i>endRow) break;
					} // end for
					rs.close();

				} // end if condition 


			   while (line<displayLine) {
				   line++;
				   %>
					<tr>
					  <td class="dotline" align="center">&nbsp;</td>
					  <td class="dotline" align="center">&nbsp;</td>
					  <td class="dotline" align="center">&nbsp;</td>
					  <td class="dotline" align="center">&nbsp;</td>
					  <td class="dotline" align="center" width="1%">&nbsp;</td>
					  <td class="dotline" align="center" width="1%">&nbsp;</td>
					  <td class="dotline" align="center" width="1%">&nbsp;</td>
					  <td class="dotline" align="center" width="1%">&nbsp;</td>
					  <td class="dotline" align="center" width="1%">&nbsp;</td>
					  <td class="dotline" align="center" width="1%">&nbsp;</td>
					  <td class="dotline" align="center" width="1%">&nbsp;</td>
					  <td class="dotline" align="center" width="1%">&nbsp;</td>
					  <td class="dotline" align="center" width="1%">&nbsp;</td>
					  <td class="dotline" align="center" width="1%">&nbsp;</td>
					  <td class="dotline" align="center" width="1%">&nbsp;</td>
					  <td class="dotline" align="center" width="1%">&nbsp;</td>
					  <td class="dotline" align="center">&nbsp;</td>
					  <td class="dotline" align="center">&nbsp;</td>
					  <td class="dotline" align="center">&nbsp;</td>
					  <td class="dotline" align="center">&nbsp;</td>
					  <td class="dotline" align="center">&nbsp;</td>
					  <td class="dotline" align="center">&nbsp;</td>
					  <td class="dotline" align="right">&nbsp;</td>
					  <td class="dotline" align="right">&nbsp;</td>
					  <td class="dotline" align="right">&nbsp;</td>
					  <td class="dotline" align="right">&nbsp;</td>
					  <td class="dotline" align="center">&nbsp;</td>
					</tr>
				   <%
			  }  // end while

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




<br style="font-size:3pt">



      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr class="gray">
          <td width="100%" align="right"><%=pageLink%></td>
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
            <td class="act_tab4"><a href="#" onclick="goReport51();" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
	

</BODY>

</HTML>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_Report51Det.jsp : " + e.getMessage());
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