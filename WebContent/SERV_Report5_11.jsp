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

<%--
  Modify by : pradoem
  Date : 2015.03.31
  DESC : เพิ่มรายงานเกี่ยวกับ E-Service,SVC,Call 1198  แซกในหน้า Report นี้
 --%>

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
%>
<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_Report5_11.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   doString str = new doString();
   DecimalFormat  format1 = new DecimalFormat("#,###,##0");
   DecimalFormat  format2 = new DecimalFormat("#,###,##0.00");
   DecimalFormat  format3 = new DecimalFormat("#,###,##0.0");


   String monthReport = doString.checkString(request.getParameter("month_report"),"0");
   String yearReport = doString.checkString(request.getParameter("year_report"),"0");
   String reportType = doString.checkString(request.getParameter("report_type"),"0");


	Integer previousList[] = newIntegerArray(12); //12
	Integer currentList[] = newIntegerArray(12);
	Integer completeList[] = newIntegerArray(12);
	Integer cancelList[] = newIntegerArray(12);
	Integer nextList[] = newIntegerArray(12);
	Integer inTimeList[] = newIntegerArray(12);
	Integer overTimeList[] = newIntegerArray(12);
	Integer pastInTimeList[] = newIntegerArray(12);
	Integer pastOverTimeList[] = newIntegerArray(12);
	Integer transferList[] = newIntegerArray(12);
	Integer sumTransferList[] = newIntegerArray(12);
	Integer expireList[] = newIntegerArray(12);
	Integer sumExpireList[] = newIntegerArray(12);
	Integer repairList[] = newIntegerArray(12);
	Double repairPriceList[] =  newDoubleArray(12);

	int a_pastInTime = 0;
	int a_pastOverTime = 0;
	int aa = 0;
	int bb = 0;

	Integer currentInfList[] = newIntegerArray(12);
	Integer previousInfList[] = newIntegerArray(12);
	Integer nextInfList[] = newIntegerArray(12);
	Integer cancelInfList[] = newIntegerArray(12);

	//---Modify by : pradoem  Date:2015.03.31
	int [] intESV = new int[12];
	int [] int1198 = new int[12];
	int [] intSVC = new int[12];
	
	//------------------------------------
	int previousTotal = 0;
	int currentTotal = 0;
	int completeTotal = 0;
	int cancelTotal = 0;
	int nextTotal = 0;
	int inTimeTotal = 0;
	int overTimeTotal = 0;
	int pastInTimeTotal = 0;
	int pastOverTimeTotal = 0;
	int transferTotal = 0;
	int sumTransferTotal = 0;
	int expireTotal = 0;
	int sumExpireTotal = 0;
	int repairTotal = 0;
	double repairPriceTotal = 0.0;

	int currentListTotal = 0;
	int previousInfTotal = 0;
	int nextInfTotal = 0;
	int cancelInfTotal = 0;

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
		String shortMonth[] = new String[] {"","ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค."};
		String showMonth = thaiMonth[Integer.parseInt(monthReport)];
		String showYear = Integer.toString(Integer.parseInt(yearReport)+543);
		String startQueryDate = "";
		String endQueryDate = "";

		Integer monthList[] = newIntegerArray(13);
		Integer yearList[] = newIntegerArray(13);
		Calendar now = Calendar.getInstance(Locale.ENGLISH);
		now.set(Integer.parseInt(yearReport),Integer.parseInt(monthReport)-1,1,0,0,0);


	//---Modify by : pradoem  Date:2015.03.31
	//Declared Value
	for(int i=0;i<12;i++){
		intESV[i] = 0;
		int1198[i] = 0;
		intSVC[i] = 0;
	}


	//for (int i=0;i<7;i++) {
		
	for (int i=0;i<(Integer.parseInt(reportType)+1);i++) {
			  int month = now.get(Calendar.MONTH)+1;
			  int year = now.get(Calendar.YEAR);  
			  if (year>2400) year -= 543;
			  	
			  if (i==0)	 {
				 startQueryDate = str.createID(year,4)+"-"+str.createID(month,2)+"-01";
			  } 
			 endQueryDate = str.createID(year,4)+"-"+str.createID(month,2)+"-01";

			  now.add(Calendar.MONTH,-1);
			  monthList[i] = new Integer(month);
			  yearList[i] = new Integer(year+543);


			  aa = monthList[i].intValue();
			  bb = yearList[i].intValue();

		} // end for


	//	out.println("aa="+aa);
	//	out.println("bb="+bb);

%>

<HTML>
<HEAD>
<TITLE>Open Job List</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">

function printReport() {
   document.forms[0].action='<%=Constants.APP_PATH%>/SERV_PrintReport5Servlet';
   //document.forms[0].action='http://www9.lh.co.th/LHServ/SERV_PrintReport5Servlet';
   document.forms[0].target="_blank";   
   document.forms[0].submit();
   document.forms[0].target="";   
}

function goSubReport(key,month,year,type) {
	document.forms[0].key_detail.value=key;
	document.forms[0].month_detail.value=month;
	document.forms[0].year_detail.value=year;
	document.forms[0].type_detail.value=type;

	document.forms[0].action='<%=Constants.APP_PATH%>/SERV_Report51Det.jsp';
    document.forms[0].submit();
}


function goSubReport2(selproj,sd,sm,sy,ed,em,ey) {
	document.forms[0].key_project.value=selproj;
	
	document.forms[0].start_date.value=sd;
	document.forms[0].start_month.value=sm;
	document.forms[0].start_year.value=sy;

	document.forms[0].end_date.value=ed;
	document.forms[0].end_month.value=em;
	document.forms[0].end_year.value=ey;

	document.forms[0].action='<%=Constants.APP_PATH%>/SERV_Report2Det.jsp';
    document.forms[0].submit();
}


</script>



<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">


<FORM ACTION="" METHOD="POST">


<input type="hidden" name="month_report" value="<%=monthReport%>">
<input type="hidden" name="year_report" value="<%=yearReport%>">
<input type="hidden" name="report_type" value="<%=reportType%>">

<input type="hidden" name="key_detail" value="">
<input type="hidden" name="month_detail" value="">
<input type="hidden" name="year_detail" value="">
<input type="hidden" name="type_detail" value="">


<!--========== Use for goto Report2Det =============-->
<input type="hidden" name="key_project" value="">

<input type="hidden" name="start_date" value="">
<input type="hidden" name="start_month" value="">
<input type="hidden" name="start_year" value="">

<input type="hidden" name="end_date" value="">
<input type="hidden" name="end_month" value="">
<input type="hidden" name="end_year" value="">



<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp; 
            สรุปงานซ่อมประจำเดือน</td>
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
    <td class="item ; dotline01" height="22" colspan="4">
	เดือน : <%=showMonth%> &nbsp; พ.ศ. <%=showYear%> &nbsp; &nbsp; , ประเภท : <%=reportType%> เดือน</td>
  </tr>


	<%
	  String[] projList = request.getParameterValues("sel_proj");
  	  String queryProject = "";
	  int line = 0;

	  if (projList!=null) {
		  for (int i=0;i<projList.length;i++) {
				 String proj = doString.checkString(projList[i],"");  
				 if (proj.trim().length()>=6) {
					 if (queryProject.trim().length()>0) queryProject += " or ";
					 queryProject += " (i_company='"+proj.substring(0,2)+"' and i_project='"+proj.substring(3,6)+"') ";
				 }
				 /*
				 if (queryProject.trim().length()>0) queryProject += " , ";
				 queryProject += " '"+proj+"' ";*/


				  %><input type="hidden" name="sel_proj" value="<%=proj%>"><%


				//---============= get Project Details ===============----//
				sql.delete(0,sql.length()); 
				sql.append(" select * from lan:acxprojt ")
					  .append(" where i_company='").append(proj.length()>=6 ? proj.substring(0,2) : "").append("' ")
					  .append(" and i_project='").append(proj.length()>=6 ? proj.substring(3,6) : "").append("' ");
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
		  queryProject = " i_company='' and i_project='' ";
	  }



		//---================== Get Summary Data ======================---//
		int sumItem = 0;
		int sumDoc = 0;
		double sumAmt = 0.0;
			int zz = 0;
			int iMonth = 0;

		sql.delete(0,sql.length());
		sql.append(" select i_month,i_year, sum(q_request) as sum_req , sum(q_cancel) as sum_can , ")
			  .append(" sum(q_appoint_y) as sum_appy , sum(q_appoint_n) as sum_appn , ")
			  .append(" sum(q_bf_pasty) as sum_pasty , sum(q_bf_pastn) as sum_pastn , ")
			  .append(" sum(q_tranfer) as sum_trans , sum(q_tranfer_sum) as sum_trans_sum , ")
			  .append(" sum(q_nserv) as sum_nserv , sum(q_nserv_sum) as sum_nserv_sum , ")
			  .append(" sum(q_avg_doc) as sum_avg_doc , sum(q_avg_amt) as sum_avg_amt , ")
			  .append(" sum(q_complete) as sum_com , sum(q_sum_item) as sum_sum_item , ")
			  .append(" sum(q_sum_doc) as sum_sum_doc , sum(z_sum_amt) as sum_sum_amt , ")
			  .append(" sum(q_infjob) as sum_inf , ")
			  .append(" sum(q_can_inf) as sum_caninf, ")
			  
			   .append(" sum(q_infjob_1198) as sum_1198, ")
			   .append(" sum(q_infjob_esv) as sum_esv, ")
			   .append(" sum(q_infjob_svc) as sum_svc ")
			  
		      .append(" from lan:serv_sumrep2 where ")  // serv_sumrep
			  .append("  (").append(queryProject).append(") ")
			  .append(" and i_rep_type='01' group by i_month,i_year ");
		servlog.startLog(sql.toString());
		//System.out.println(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		int  iYear = 0;
		while (rs.next()) {
			  iMonth = rs.getInt("i_month");
			  iYear = 0;
			  iYear = rs.getInt("i_year");	
			
			/*for (int j=Integer.parseInt(reportType)+1;j<Integer.parseInt(reportType)+2;j++) {
					a_pastInTimeList[j] = new Integer(rs.getInt("sum_pastn"));
					a_pastOverTimeList[j] = new Integer(rs.getInt("sum_pasty"));
					out.println("test =="+a_pastInTimeList[j].intValue());
					out.println("j="+j);
			}*/

			for (int j=0;j<Integer.parseInt(reportType);j++) {							
					/*  if (monthList[j].intValue()==iMonth && yearList[j].intValue()==iYear) {
							a_pastInTimeList[j] = new Integer(rs.getInt("sum_pastn"));
							a_pastOverTimeList[j] = new Integer(rs.getInt("sum_pasty"));
					  }*/
				  if (monthList[j].intValue()==iMonth && yearList[j].intValue()==iYear) {					
					 zz++;

					  currentInfList[j] = new Integer(rs.getInt("sum_inf"));
					  cancelInfList[j] = new Integer(rs.getInt("sum_caninf"));

					  currentList[j] = new Integer(rs.getInt("sum_req"));
					  completeList[j] = new Integer(rs.getInt("sum_com"));
					  cancelList[j] = new Integer(rs.getInt("sum_can"));

					  inTimeList[j] = new Integer(rs.getInt("sum_appy"));
					  overTimeList[j] = new Integer(rs.getInt("sum_appn"));
					  pastInTimeList[j] = new Integer(rs.getInt("sum_pastn"));
					  pastOverTimeList[j] = new Integer(rs.getInt("sum_pasty"));
					  transferList[j] = new Integer(rs.getInt("sum_trans"));
					  sumTransferList[j] = new Integer(rs.getInt("sum_trans_sum"));
					  expireList[j] = new Integer(rs.getInt("sum_nserv"));
					  sumExpireList[j] = new Integer(rs.getInt("sum_nserv_sum"));

					//modify by pradoem 2015.03.31
					intESV[j] = rs.getInt("sum_esv");
					int1198[j] = rs.getInt("sum_1198");
					intSVC[j] = rs.getInt("sum_svc");


					  int  itemSum = rs.getInt("sum_sum_item");
					  int docSum = rs.getInt("sum_sum_doc");
					  double amtSum = rs.getDouble("sum_sum_amt");
					  sumItem += itemSum;
					  sumDoc += docSum;
					  sumAmt += amtSum;

					  if (docSum>0) {
						  repairList[j] = new Integer((int) Math.round(itemSum/docSum));
						  repairPriceList[j] = new Double(amtSum/docSum);
					  }
					  //repairList[j] = new Integer(rs.getInt("sum_avg_doc"));
					  //repairPriceList[j] = new Double(rs.getDouble("sum_avg_amt"));

					 currentTotal += currentList[j].intValue();
					 currentListTotal += currentInfList[j].intValue();
					 cancelInfTotal += cancelInfList[j].intValue();

					 completeTotal += completeList[j].intValue();
					 cancelTotal += cancelList[j].intValue();

					 inTimeTotal += inTimeList[j].intValue();
					 overTimeTotal += overTimeList[j].intValue();
					 pastInTimeTotal += pastInTimeList[j].intValue();
					 pastOverTimeTotal += pastOverTimeList[j].intValue();
					 transferTotal += transferList[j].intValue();
					 sumTransferTotal += sumTransferList[j].intValue();
					 expireTotal += expireList[j].intValue();
					 sumExpireTotal = sumExpireList[j].intValue();
					 //repairTotal += repairList[j].intValue();
					 //repairPriceTotal += repairPriceList[j].intValue();
				  }			  
				//out.println("monthList=="+(monthList[j].intValue()));
			   //out.println("iMonth=="+iMonth);				 
			} // end for	
		}
		rs.close();

		//--------- calculate average summary ---------//
		if (sumDoc>0)  {
			repairTotal = (int) Math.round(sumItem/sumDoc);
			repairPriceTotal = sumAmt/sumDoc;
		}			

			for (int i=0;i<Integer.parseInt(reportType);i++) {
				//----========== Get Previous Doc ==============-----//
				sql.delete(0,sql.length());
				sql.append(" select sum(q_bf_pasty)+sum(q_bf_pastn) as sum_next from serv_sumrep2 where ")
					  .append(" (").append(queryProject).append(") ")
					  .append(" and i_rep_type='01' and d_start='"+(yearList[i].intValue()-543)+"-"+str.createID(monthList[i].intValue(),2)+"-01' ");
				servlog.startLog(sql.toString());
				//out.println(sql.toString());
				rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
				while (rs.next()) {					
						previousList[i] = new Integer(rs.getInt("sum_next")); 
						//previousTotal += previousList[i].intValue();
				}
				rs.close();
			} // end for

		for (int i=0;i<Integer.parseInt(reportType);i++) {
				//----========== Get Next Doc ==============-----//
				sql.delete(0,sql.length());
				sql.append(" select sum(q_request) - sum(q_cancel) - sum(q_complete) as sum_prev, sum(q_bf_pasty)+sum(q_bf_pastn) as sum_next from serv_sumrep2 where ")
					  .append(" (").append(queryProject).append(") ")
					  .append(" and i_rep_type='01' and d_start='"+(yearList[i].intValue()-543)+"-"+str.createID(monthList[i].intValue(),2)+"-01' ");
				servlog.startLog(sql.toString());
				//out.println(sql.toString());
				rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
				while (rs.next()) {					
					//previousList[i] = new Integer(rs.getInt("sum_next")); //sum_prev
				    //nextList[i] = new Integer((previousList[i].intValue() + currentList[i].intValue()) - (completeList[i].intValue() + cancelList[i].intValue()));
					nextList[i] = new Integer(rs.getInt("sum_next"));					
					nextTotal += nextList[i].intValue();
				}
				rs.close();
		} // end for

		//------------------------------- Inform Job Report ------------------------------//
		for (int i=0;i<Integer.parseInt(reportType);i++) {
				//----========== Get Previous Doc ==============-----//
				sql.delete(0,sql.length());
				sql.append(" select sum(q_infjob) - sum(q_request) - sum(q_can_inf) as sum_prev from lan:serv_sumrep2 where ")
					  .append(" (").append(queryProject).append(") ")
					  .append(" and i_rep_type='01' and d_start<'"+(yearList[i].intValue()-543)+"-"+str.createID(monthList[i].intValue(),2)+"-01' ");
				servlog.startLog(sql.toString());
				//out.println(sql.toString());
				rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
				while (rs.next()) {
					
					previousInfList[i] = new Integer(rs.getInt("sum_prev"));					
					nextInfList[i] = new Integer((previousInfList[i].intValue() + currentInfList[i].intValue()) - (cancelInfList[i].intValue()) - (currentList[i].intValue()));

				    //nextList[i] = new Integer((previousList[i].intValue() + currentList[i].intValue()) - (completeList[i].intValue() + cancelList[i].intValue()));

					previousInfTotal += previousInfList[i].intValue();
					nextInfTotal += nextInfList[i].intValue();
				}
				rs.close();			
		} // end for
		//------------------------------- EndInform Job Report ------------------------------//
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

    <!---------------------------------------------- Inform Job Data ---------------------------------------------->
<br style="font-size:10pt">


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                
          <td class="item_tab2" width="200">ใบรับเรื่องลูกค้า</td>
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


			  <!--========================== Header Table ===========================---->
              <tr> 
                <td width="19%" height="1" class="col_name">รายละเอียดการแจ้งซ่อม</td>
				<%
					int loop = 0;
					for (int i=0;i<12;i++) {
						   String monthCol = "";
						    if (i<Integer.parseInt(reportType)) {
							   monthCol = shortMonth[monthList[i].intValue()]+" "+Integer.toString(yearList[i].intValue()).substring(2,4);
							}
						   %><td width="3%" align="center" valign="middle" class="col_name"><%=doString.checkString(monthCol,"&nbsp;")%></td><%	
							loop++;
					}
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="col_name">&nbsp;</td><%
						loop++;
					}
				%>
                <td width="3%" align="center" valign="middle" class="col_name">รวม</td>
              </tr>


			   <!--========================== Previous Data ===========================---->
              <tr> 
                <td width="19%" height="1" align="center" class="item ; dotline"><div align="left">ใบรับเรื่องยกมา </div></td>
				<%
				    loop = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
						  %><td width="3%" align="right" valign="middle" class="dotline">
						  <!--<A HREF="javascript:goSubReport('CURRENT','< %=monthList[i].intValue()%>','< %=yearList[i].intValue()-543%>','010');">-->
						  <%=format1.format(previousInfList[i].intValue())%>&nbsp;</td><%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>                
                <td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(previousInfTotal)%>&nbsp;</td>
              </tr>
			  <!--==================================================================---->



			   <!--========================== Current Data ============================---->
              <tr> 
                <td height="1" align="center" class="item ; dotline"><div align="left">ใบรับเรื่องในเดือน</div></td>
				<%
				    loop = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
						  %><td width="3%" align="right" valign="middle" class="dotline" style="cursor:hand;" >
						  <A HREF="javascript:goSubReport('CURRENT','<%=monthList[i].intValue()%>','<%=yearList[i].intValue()-543%>','020');"><%=format1.format(currentInfList[i].intValue())%></A>&nbsp;</td><%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>                
                <td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(currentListTotal)%>&nbsp;</td>
              </tr>
			  <!--==================================================================---->
			  
			  
			 <!--========================== modify by pradoem 31.03.2015 ============================---->
              <tr> 
                <td height="1" align="center" class="dotline"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ใบรับเรื่องผ่าน 1198 ในเดือน</div></td>
				<%
				    loop = 0;
				    int sumColumnX = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
						 sumColumnX +=int1198[i];
						  %><td width="3%" align="right" valign="middle" class="dotline" style="cursor:hand;" >
						  <A HREF="javascript:goSubReport('CURRENT','<%=monthList[i].intValue()%>','<%=yearList[i].intValue()-543%>','021');"><%=format1.format(int1198[i])%></A>&nbsp;</td><%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>                
                <td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(sumColumnX)%>&nbsp;</td>
              </tr>
			  <!--==================================================================---->
			   <!--========================== modify by pradoem 31.03.2015 ============================---->
              <tr> 
                <td height="1" align="center" class="dotline"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ใบรับเรื่องผ่าน e-Service ในเดือน</div></td>
				<%
				    loop = 0;
				    sumColumnX = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
						 sumColumnX += intESV[i];
						  %><td width="3%" align="right" valign="middle" class="dotline" style="cursor:hand;" >
						  <A HREF="javascript:goSubReport('CURRENT','<%=monthList[i].intValue()%>','<%=yearList[i].intValue()-543%>','022');"><%=format1.format(intESV[i])%></A>&nbsp;</td><%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>                
                <td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(sumColumnX)%>&nbsp;</td>
              </tr>
			  <!--==================================================================---->
			  <!--========================== modify by pradoem 31.03.2015 ============================---->
              <tr> 
                <td height="1" align="center" class="dotline"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ใบรับเรื่องผ่าน Call Center ในเดือน</div></td>
				<%
				    loop = 0;
				    sumColumnX = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
					 	   sumColumnX += intSVC[i];
						  %><td width="3%" align="right" valign="middle" class="dotline" style="cursor:hand;" >
						  <A HREF="javascript:goSubReport('CURRENT','<%=monthList[i].intValue()%>','<%=yearList[i].intValue()-543%>','023');"><%=format1.format( intSVC[i])%></A>&nbsp;</td><%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>                
                <td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(sumColumnX)%>&nbsp;</td>
              </tr>
			  <!--==================================================================---->

			  <!--========================== modify by pradoem 31.03.2015
			  Summary : XY
			   ============================---->
			   
              <tr> 
                <td height="1" align="center" class="dotline"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;% สัดส่วนการแจ้งซ่อมระบบ e-Service </div></td>
				<%
				    loop = 0;
				    sumColumnX = 0;
				    			    
				    double percenTag  = 0d;		
				    double percenTagTotal  = 0d;		    
					for (int i=0;i<Integer.parseInt(reportType);i++) {
					 	    percenTag = 0d;
					        if(intESV[i]>0){
						         percenTag = (Double.parseDouble(""+intESV[i])/Double.parseDouble(""+currentInfList[i].intValue()))*100;
						     }else{
						         percenTag = 0d;
						    }
						    sumColumnX += intESV[i];
					 	   
						  %><td width="3%" align="right" valign="middle" class="dotline" ><%=format3.format(percenTag)%>%</td>
						  <%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
					//---total
					if(sumColumnX>0){
						percenTagTotal = (Double.parseDouble(""+sumColumnX)/Double.parseDouble(""+currentListTotal))*100;
					}else{
						percenTagTotal = 0;
					}

			    %>                
                <td width="3%" align="right" valign="middle" class="dotline"><%=format3.format(percenTagTotal)%>%</td>
              </tr>
			  <!--==================================================================---->


			   <!--========================= 3===========================---->
              <tr> 
                <td width="19%" height="1" align="center" class="item ; dotline"><div align="left">Open Job ในเดือน</div></td>
				<%
				    loop = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
						  %><td width="3%" align="right" valign="middle" class="dotline" style="cursor:hand;" ><A HREF="javascript:goSubReport('CURRENT','<%=monthList[i].intValue()%>','<%=yearList[i].intValue()-543%>','030');"><%=format1.format(currentList[i].intValue())%></A>&nbsp;</td><%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>        
                <td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(currentTotal)%>&nbsp;</td>
              </tr>
			  <!--==================================================================---->
			   <!--========================== 4=============================---->
              <tr> 
                <td width="19%" height="1" align="center" class="item ; dotline"><div align="left">ใบรับเรื่องที่ยกเลิกในเดือน</div></td>
				<%
				    loop = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
						  %><td width="3%" align="right" valign="middle" class="dotline" style="cursor:hand;" >
						  <A HREF="javascript:goSubReport('CURRENT','<%=monthList[i].intValue()%>','<%=yearList[i].intValue()-543%>','040');"><%=format1.format(cancelInfList[i].intValue())%></A>&nbsp;</td><%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>        
                <td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(cancelInfTotal)%>&nbsp;</td>
              </tr>


			  <!--========================== 5=============================---->
              <tr> 
                <td width="19%" height="1" align="center" class="item ; dotline"><div align="left">ใบรับเรื่องยกไป</div></td>
				<%
				    loop = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
						  %><td width="3%" align="right" valign="middle" class="dotline" style="cursor:hand;" >
						  <!--<A HREF="javascript:goSubReport('CURRENT','< %=monthList[i].intValue()%>','< %=yearList[i].intValue()-543%>','050');">-->
						  <%=format1.format(nextInfList[i].intValue())%>&nbsp;</td>
						  <%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>        
                <td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(nextInfTotal)%>&nbsp;</td>
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
  <!---------------------------------------------- End Inform Job Data ---------------------------------------------->
<br style="font-size:10pt">


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                
          <td class="item_tab2" width="200">รายละเอียดงานซ่อมประจำเดือน</td>
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


			  <!--========================== Header Table ===========================---->
              <tr> 
                <td width="19%" height="1" class="col_name">รายละเอียดการแจ้งซ่อม</td>
				<%
					loop = 0;
					for (int i=0;i<12;i++) {
						   String monthCol = "";
						    if (i<Integer.parseInt(reportType)) {
							   monthCol = shortMonth[monthList[i].intValue()]+" "+Integer.toString(yearList[i].intValue()).substring(2,4);
							}
						   %><td width="3%" align="center" valign="middle" class="col_name"><%=doString.checkString(monthCol,"&nbsp;")%></td><%	
							loop++;
					}
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="col_name">&nbsp;</td><%
						loop++;
					}
				%>
                <td width="3%" align="center" valign="middle" class="col_name">รวม</td>
              </tr>
			  <!--==================================================================---->

<%
String m_aa = "";	   
if (aa <= 9){
	m_aa = "0"+Integer.toString(aa);
} else {
	m_aa = Integer.toString(aa);
}

		sql.delete(0,sql.length());
		sql.append(" select sum(q_bf_pasty)+sum(q_bf_pastn) as sum ") 	 
		      .append(" from lan:serv_sumrep2 where ")  
			  .append("  (").append(queryProject).append(") ")
			  .append(" and i_rep_type='01' ")
			  .append(" and i_month = '"+m_aa+"' ")
			  .append(" and i_year = '"+bb+"' ");
		servlog.startLog(sql.toString());
		//out.println(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		if (rs.next()) {
			a_pastInTime = rs.getInt("sum");
		}
%>
			  <!--========================== Previous Data ===========================---->
              <tr> 
                <td width="19%" height="1" align="center" class="item ; dotline"><div align="left">ใบแจ้งซ่อมยกมา </div></td>
				<%	  

				    loop = 0;
					for (int i=1;i<Integer.parseInt(reportType);i++) {   // get nextlist ของเดือนถัดไปมาแสดง
						  %><td width="3%" align="right" valign="middle" class="dotline">
						  <!--<A HREF="javascript:goSubReport('CURRENT','< %=monthList[i].intValue()%>','< %=yearList[i].intValue()-543%>','060');">-->
						  <%=format1.format(previousList[i].intValue())%>&nbsp;</td>
						  <%
						   loop++;
						  previousTotal += previousList[i].intValue();						  
					} // end for				  
				    while (loop<12) {
						
						%><td width="3%" align="right" valign="middle" class="dotline">
							<% if (loop == Integer.parseInt(reportType)-1) { %><A HREF="javascript:goSubReport('CURRENT','<%=monthList[loop].intValue()%>','<%=yearList[loop].intValue()-543%>','060');"><% out.println(a_pastInTime); }  // ยกยอดรวมมาแสดง %></A>&nbsp;</td>
					<%
						loop++;
					}					
			    %><%//=format1.format(nextTotal)%>                
                <td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(previousTotal)%>&nbsp;</td>
              </tr>
			  <!--==================================================================---->



			   <!--========================== Current Data ============================---->
              <tr> 
                <td height="1" align="center" class="item ; dotline"><div align="left">ใบแจ้งซ่อมที่เกิดในเดือน</div></td>
				<%
				    loop = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
						  %><td width="3%" align="right" valign="middle" class="dotline" style="cursor:hand;">
						  <A HREF="javascript:goSubReport('CURRENT','<%=monthList[i].intValue()%>','<%=yearList[i].intValue()-543%>','030');"><%=format1.format(currentList[i].intValue())%></A>&nbsp;</td><%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>                
                <td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(currentTotal)%>&nbsp;</td>
              </tr>
			  <!--==================================================================---->



			   <!--========================= Complete Data ===========================---->
              <tr> 
                <td width="19%" height="1" align="center" class="item ; dotline"><div align="left">ซ่อมเสร็จ (Complete แล้ว)</div></td>
				<%
				    loop = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
						  %><td width="3%" align="right" valign="middle" class="dotline" style="cursor:hand;" >
						  <A HREF="javascript:goSubReport('CURRENT','<%=monthList[i].intValue()%>','<%=yearList[i].intValue()-543%>','080');"><%=format1.format(completeList[i].intValue())%></A>&nbsp;</td><%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>        
                <td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(completeTotal)%>&nbsp;</td>
              </tr>
			  <!--==================================================================---->



			  <!--========================== Cancel Data =============================---->
              <tr> 
                <td width="19%" height="1" align="center" class="item ; dotline"><div align="left">ใบแจ้งซ่อมที่ยกเลิกในเดือน</div></td>
				<%
				    loop = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
						  %><td width="3%" align="right" valign="middle" class="dotline" style="cursor:hand;" >
						  <A HREF="javascript:goSubReport('CURRENT','<%=monthList[i].intValue()%>','<%=yearList[i].intValue()-543%>','090');"><%=format1.format(cancelList[i].intValue())%></A>&nbsp;</td><%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>        
                <td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(cancelTotal)%>&nbsp;</td>
              </tr>
			  <!--==================================================================---->



			  <!--=========================== Next Data =============================---->
              <tr> 
                <td height="1" align="center" class="item ; dotline"><div align="left">งานซ่อมยกไป</div></td>
				<%
				    loop = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
						  %><td width="3%" align="right" valign="middle" class="dotline">
						  <!--<A HREF="javascript:goSubReport('CURRENT','< %=monthList[i].intValue()%>','< %=yearList[i].intValue()-543%>','100');">-->
						  <%=format1.format(nextList[i].intValue())%>&nbsp;</td>
						  <%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>                
                <td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(nextTotal)%>&nbsp;</td>
              </tr>
			  <!--==================================================================---->



			  <!--==================================================================---->
              <tr> 
                <td height="1" align="center" class="item ; dotline"><div align="left">ซ่อมเสร็จ (ตามกำหนดนัดหมาย) </div></td>
                <td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td>
                <td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td>
                <td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td>
                <td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td>
                <td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td>
                <td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td>
                <td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td>
                <td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td>
                <td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td>
                <td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td>
                <td width="3%" align="center" valign="middle" class="dotline ; item">&nbsp;</td>
                <td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td>
                <td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td>
              </tr>
			  <!--==================================================================---->



			  <!--========================= IntimeData Data ===========================---->
              <tr> 
                <td height="1" align="center" class="dotline"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1. 
                    ตามกำหนดนัดหมาย </div></td>
				<%
				    loop = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
						  %><td width="3%" align="right" valign="middle" class="dotline" style="cursor:hand;" >
						  <A HREF="javascript:goSubReport('CURRENT','<%=monthList[i].intValue()%>','<%=yearList[i].intValue()-543%>','120');"><%=format1.format(inTimeList[i].intValue())%></A>&nbsp;</td><%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>       
                <td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(inTimeTotal)%>&nbsp;</td>
              </tr>
			  <!--==================================================================---->



		  	 <!--========================= OverTime Data ===========================---->
              <tr> 
                <td height="1" align="center" class="dotline"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2. 
                    เลยกำหนดนัดหมาย </div></td>
				<%
				    loop = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
						  %><td width="3%" align="right" valign="middle" class="dotline" style="cursor:hand;" >
						  <A HREF="javascript:goSubReport('CURRENT','<%=monthList[i].intValue()%>','<%=yearList[i].intValue()-543%>','130');"><%=format1.format(overTimeList[i].intValue())%></A>&nbsp;</td><%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>       
                <td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(overTimeTotal)%>&nbsp;</td>
              </tr>
			  <!--==================================================================---->



		  	 <!--========================= OverTime Data ===========================---->
              <tr> 
                <td height="1" align="center" class="item ; dotline"><div align="left">งานซ่อมคงค้างยกไป</div></td>
                <td align="center" valign="middle" class="dotline">&nbsp;</td>
                <td align="center" valign="middle" class="dotline">&nbsp;</td>
                <td align="center" valign="middle" class="dotline">&nbsp;</td>
                <td align="center" valign="middle" class="dotline">&nbsp;</td>
                <td align="center" valign="middle" class="dotline">&nbsp;</td>
                <td align="center" valign="middle" class="dotline">&nbsp;</td>
                <td align="center" valign="middle" class="dotline">&nbsp;</td>
                <td align="center" valign="middle" class="dotline">&nbsp;</td>
                <td align="center" valign="middle" class="dotline">&nbsp;</td>
                <td align="center" valign="middle" class="dotline">&nbsp;</td>
                <td align="center" valign="middle" class="dotline ; item">&nbsp;</td>
                <td align="center" valign="middle" class="dotline">&nbsp;</td>
                <td align="center" valign="middle" class="dotline">&nbsp;</td>
              </tr>
			  <!--==================================================================---->



		  	 <!--========================= Past InTime Data ==========================---->
              <tr> 
                <td height="1" align="center" class="dotline"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1. 
                    ยังไม่เลยกำหนดนัดหมาย </div></td>
				<%
				    loop = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
						  %><td width="3%" align="right" valign="middle" class="dotline" style="cursor:hand;" >
						  <A HREF="javascript:goSubReport('CURRENT','<%=monthList[i].intValue()%>','<%=yearList[i].intValue()-543%>','160');"><%=format1.format(pastInTimeList[i].intValue())%></A>&nbsp;</td><%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>       
                <td align="right" valign="middle" class="dotline"><%=format1.format(pastInTimeTotal)%>&nbsp;</td>
              </tr>
			  <!--==================================================================---->



		  	 <!--======================== Past OverTime Data ========================---->
              <tr> 
                <td height="1" align="center" class="dotline"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2. 
                    เลยกำหนดนัดหมาย </div></td>
				<%
				    loop = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
						  %><td width="3%" align="right" valign="middle" class="dotline" style="cursor:hand;" >
						  <A HREF="javascript:goSubReport('CURRENT','<%=monthList[i].intValue()%>','<%=yearList[i].intValue()-543%>','150');"><%=format1.format(pastOverTimeList[i].intValue())%></A>&nbsp;</td><%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>       
                <td align="right" valign="middle" class="dotline"><%=format1.format(pastOverTimeTotal)%>&nbsp;</td>
              </tr>
			  <!--==================================================================---->



   		  	 <!--========================= Transfer Data ===========================---->
             <tr> 
                <td height="1" align="center" class="item ; dotline"><div align="left">บ้านโอนในเดือน</div></td>
				<%
				    loop = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
						  String showData = "";
						  if (projList!=null && projList.length==1) {
							 Calendar tmp = Calendar.getInstance(Locale.ENGLISH);
							 tmp.set(yearList[i].intValue()-543,monthList[i].intValue(),1);
							 tmp.add(Calendar.DATE,-1);
							 int endDate = tmp.get(Calendar.DATE);
							 String params = "'"+str.createID(endDate,2)+"','"+str.createID(monthList[i].intValue(),2)+"','"+(yearList[i].intValue()-543)+"'";
							 params = "'01','"+str.createID(monthList[i].intValue(),2)+"','"+(yearList[i].intValue()-543)+"',"+params;
							 showData = format1.format(transferList[i].intValue());   // "<a href=\"javascript:goSubReport2('"+projList[0]+"',"+params+");\">"+format1.format(transferList[i].intValue())+"</a>";
						  } else {
							  showData = format1.format(transferList[i].intValue());
						  }


						  %><td width="3%" align="right" valign="middle" class="dotline"><%=showData%>&nbsp;</td><%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>       
                <td align="right" valign="middle" class="dotline"><%=format1.format(transferTotal)%>&nbsp;</td>
              </tr>
			  <!--==================================================================---->



		  	 <!--========================= Transfer Sum Data =========================---->
              <tr> 
                <td height="1" align="center" class="item ; dotline"><div align="left">ยอดบ้านโอนสะสม</div></td>
				<%
				    loop = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
						  %><td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(sumTransferList[i].intValue())%>&nbsp;</td><%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>       
                <td align="right" valign="middle" class="dotline">
				<%//=format1.format(sumTransferTotal)%>
				<%=format1.format(sumTransferList[0].intValue())%>
				&nbsp;</td>
              </tr>
			  <!--==================================================================---->



		  	 <!--============================ Expire Data ============================---->
              <tr> 
                <td height="1" align="center" class="item ; dotline"><div align="left">บ้านหมดประกันในเดือน</div></td>
				<%
				    loop = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
						  %><td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(expireList[i].intValue())%>&nbsp;</td><%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>       
                <td align="right" valign="middle" class="dotline"><%=format1.format(expireTotal)%>&nbsp;</td>
              </tr>
			  <!--==================================================================---->



 		  	 <!--========================= Expire Sum Data ==========================---->
             <tr> 
                <td height="1" align="center" class="item ; dotline"><div align="left">ยอดบ้านหมดประกันสะสม</div></td>
				<%
				    loop = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
						  %><td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(sumExpireList[i].intValue())%>&nbsp;</td><%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>       
                <td align="right" valign="middle" class="dotline">
				<%//=format1.format(sumExpireTotal)%>
				<%=format1.format(sumExpireList[0].intValue())%>
				&nbsp;</td>
              </tr>
			  <!--==================================================================---->



   		  	 <!--========================== Average Doc  ===========================---->
           <tr> 
                <td height="1" align="center" class="item ; dotline"><div align="left">รายการแจ้งซ่อม 
                    เฉลี่ยต่อใบ </div></td>
				<%
				    loop = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
						  %><td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(repairList[i].intValue())%>&nbsp;</td><%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>       
                <td align="right" valign="middle" class="dotline"><%=format1.format(repairTotal)%>&nbsp;</td>
              </tr>
			  <!--==================================================================---->



		  	 <!--========================= Repair Price Data =========================---->
              <tr> 
                <td width="19%" height="1" align="center" class="item ; dotline"><div align="left">ราคางานแจ้งซ่อม 
                    เฉลี่ยต่อใบ</div></td>
				<%
				    loop = 0;
					for (int i=0;i<Integer.parseInt(reportType);i++) {
						  %><td width="3%" align="right" valign="middle" class="dotline"><%=format2.format(repairPriceList[i].doubleValue())%>&nbsp;</td><%
						   loop++;
					} // end for				  
				    while (loop<12) {
						%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
						loop++;
					}
			    %>       
                <td width="3%" align="right" valign="middle" class="dotline"><%=format2.format(repairPriceTotal)%>&nbsp;</td>
              </tr>
			  <!--==================================================================---->

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
            <td width="80" class="act_tab2">

            <!--<img border="0" src="images/act_print.gif"  onclick="javascript:printReport();" 
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27"> -->
					&nbsp; 
            </td>      
                  	
                  	
            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_Report5.jsp" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
		System.out.println("ERROR SERV_Report5_11.jsp : " + e.getMessage());
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