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
%>
<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_Report11_1.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   doString str = new doString();
   DecimalFormat  format1 = new DecimalFormat("#,###,##0");
	//---------------------- Variable --------------------
	String f_name = "";
    String n_itmjob = "";
	String tb_name = "";
	Integer maingrp[] = newIntegerArray(12);
	Integer totmnth[] = newIntegerArray(12);
	Integer summnth[] = newIntegerArray(12);
	String QTY = doString.checkString(request.getParameter("QTY"),"Q1");	
    String monthReport = doString.checkString(request.getParameter("month_report"),"0");
    String yearReport = doString.checkString(request.getParameter("year_report"),"0");
    String reportType = doString.checkString(request.getParameter("report_type"),"0");
	String Type_itm = doString.checkString(request.getParameter("Type_itm"),"Main");	
	String mainboq = "";
	mainboq = doString.checkString(request.getParameter("mainboq"),"00");	
	String subboq = "";
	subboq = doString.checkString(request.getParameter("subboq"),"nnnn");	
	String seqboq = "";
	seqboq = doString.checkString(request.getParameter("seqboq"),"nnnnnnnn");		
	String option = "", grp = "", typ = "";

	/*out.println("mainboq=="+mainboq);
	out.println("subboq=="+subboq);
	out.println("seqboq=="+seqboq);*/
	
	int total_itmmain = 0, total_itmsub = 0, total_itmseq = 0;
	int total_all = 0;	
	int total_main = 0;
	int  iMonth = 0, iYear = 0;

	//------------------------------------------------------
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	Statement stmt2 = null;
	Statement stmt3 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	ResultSet rs2 = null;
	ResultSet rs3 = null;
	SERV_CommonData common = null;
	try {
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();
		stmt1 = conn.createStatement();
		stmt2 = conn.createStatement();
		stmt3 = conn.createStatement();
		common = new SERV_CommonData(conn);


		//---=========== Month Initilize =========----//
		String thaiMonth[] = new String[] {"","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
		String shortMonth[] = new String[] {"","ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค."};
		String showMonth = thaiMonth[Integer.parseInt(monthReport)];
		String showYear = Integer.toString(Integer.parseInt(yearReport)+543);
		String startQueryDate = "";
		String endQueryDate = "";

		Integer monthList[] = newIntegerArray(12);
		Integer yearList[] = newIntegerArray(12);
		Calendar now = Calendar.getInstance(Locale.ENGLISH);
		now.set(Integer.parseInt(yearReport),Integer.parseInt(monthReport)-1,1,0,0,0);

		for (int i=0;i<Integer.parseInt(reportType);i++) {
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
		} // end for

%>

<HTML>
<HEAD>
<TITLE>สรุปงานซ่อมแยกหมวดตามเดือนที่ผู้รับเหมาส่งงวดงาน</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">

</script>



<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">


<FORM NAME = "frmRep" ACTION="SERV_Report11_1.jsp" METHOD="POST">


<input type="hidden" name="month_report" value="<%=monthReport%>">
<input type="hidden" name="year_report" value="<%=yearReport%>">
<input type="hidden" name="report_type" value="<%=reportType%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp; 
            สรุปงานซ่อมแยกหมวดตามเดือนที่ผู้รับเหมาส่งงวดงาน</td>
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
	  String proj = "", i_proj = "";
	  int line = 0;
	  if (projList!=null) {
		  for (int i=0;i<projList.length;i++) {		
				 proj = doString.checkString(projList[i],"");  		

				 i_proj = proj.substring(3,6);
				 if (proj.trim().length()>=6) {	
						 if (queryProject.trim().length()>0) queryProject += " or ";
						 queryProject += " (a.i_company='"+proj.substring(0,2)+"' and a.i_project='"+proj.substring(3,6)+"') ";	
				 }
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
		  queryProject = " a.i_company='' and a.i_project='' ";
	  }
	%>
<tr>
<td class="item ; dotline01" height="22" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;หมวดหลัก :&nbsp;&nbsp;
<select size="1" class="box" style="width:140px" name="mainboq" onchange="javascript:frmRep.submit();">
<option value="00">- - - เลือกทุกหมวด - - -</option>
<%
	sql.delete(0,sql.length());
	sql.append("select distinct i_itmjob, n_itmjob from lan:serv_boq where i_type is null and i_seq is null ");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	while (rs.next()) {
		option = "";			
				if (mainboq.equals(doString.checkString(rs.getString("i_itmjob")))) {
					option = " Selected ";
				} // End if

%>
	<option value="<%=doString.checkString(rs.getString("i_itmjob"))%>"<%=option%>><%=doString.checkString(rs.getString("i_itmjob"))+" "+doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")))%></option>
<%
	} // End while
%>
</select>&nbsp;&nbsp;&nbsp;หมวดรอง :&nbsp;&nbsp;
<select size="1" class="box" style="width:200px" name="subboq" onchange="javascript:frmRep.submit();">
<option value="nnnn" <%if (subboq.equals("nnnn")) { out.println("Selected"); } %>>- - - - - - - - - -ไม่แสดงหมวดรอง - - - - - - - - -</option>
<option value="0000" <%if (subboq.equals("0000")) { out.println("Selected"); } %>>- - - - - - - - - -เลือกทุกหมวดรอง - - - - - - - - -</option>

<%
	sql.delete(0,sql.length());
	sql.append("select distinct i_itmjob, n_itmjob from lan:serv_boq where i_group = '"+mainboq+"' and  i_type is not null and i_seq is null order by i_itmjob ");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	while (rs.next()) {
		option = "";			
				if (subboq.equals(doString.checkString(rs.getString("i_itmjob")))) {
					option = " Selected ";
				} // End if

%>	
	<option value="<%=doString.checkString(rs.getString("i_itmjob"))%>"<%=option%>><%=doString.checkString(rs.getString("i_itmjob"))+" "+doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")))%></option>
<%
	} // End while
%>
</select>&nbsp;&nbsp;&nbsp;หมวดย่อย :&nbsp;&nbsp;
<select size="1" class="box" style="width:380px" name="seqboq" onchange="javascript:frmRep.submit();">
<option value="nnnnnnnn" <%if (seqboq.equals("nnnnnnnn")) { out.println("Selected"); } %>>- - - - - - - - -- - - - - - - - - ไม่แสดงหมวดย่อย - - - - - - - - -- - - - - - - - -</option>
<option value="00000000" <%if (seqboq.equals("00000000")) { out.println("Selected"); } %>>- - - - - - - - -- - - - - - - - - เลือกทุกหมวดย่อย - - - - - - - - -- - - - - - - - -</option>
<%
	if (!subboq.equals("0000") && !subboq.equals("nnnn")) {
		grp = subboq.substring(0,2);
		typ = subboq.substring(2,4);	
	}
	sql.delete(0,sql.length());
	sql.append("select distinct i_itmjob, n_itmjob from lan:serv_boq where i_group = '"+grp+"' and i_type = '"+typ+"' and  i_type is not null and i_seq is not null order by i_itmjob ");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	while (rs.next()) {
		option = "";			
				if (seqboq.equals(doString.checkString(rs.getString("i_itmjob")))) {
					option = " Selected ";
				} // End if

%>
	
	<option value="<%=doString.checkString(rs.getString("i_itmjob"))%>"<%=option%>><%=doString.checkString(rs.getString("i_itmjob"))+" "+doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")))%></option>
<%
	} // End while
%>
</select>&nbsp;&nbsp;<A HREF="javascript:frmRep.submit();"><img border="0" src="images/bu_R.gif" align="absmiddle" style="cursor:hand" width="16" height="16"></A>
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
                
          <td class="item_tab2" width="200">รายละเอียดงานซ่อมประจำเดือน</td>
                <td class="item_tab3"></td>                
				<td><input type="radio" value="Q1" name="QTY" <% if (QTY.equals("Q1")) { out.println("checked"); } %>>จำนวนรายการ&nbsp;
						<input type="radio" value="Q2" name="QTY" <% if (QTY.equals("Q2")) { out.println("checked"); } %>>จำนวนใบ&nbsp;
						<input type="radio" value="Q3" name="QTY" <% if (QTY.equals("Q3")) { out.println("checked"); } %>>จำนวนเงิน&nbsp;
						<input type="radio" value="Q4" name="QTY" <% if (QTY.equals("Q4")) { out.println("checked"); } %>>จำนวนแปลง&nbsp;&nbsp;&nbsp;<A HREF="javascript:frmRep.submit();"><img border="0" src="images/bu_R.gif" align="absmiddle" style="cursor:hand" width="16" height="16"></A>&nbsp;&nbsp;&nbsp;</td>
               <td>หมวดที่แสดง : &nbsp;<input type="radio" value="Main" name="Type_itm" <% if (Type_itm.equals("Main")) { out.println("checked"); } %>>
					  หมวดหลัก&nbsp;&nbsp;<input type="radio" value="Sub" name="Type_itm" <% if (Type_itm.equals("Sub")) { out.println("checked"); } %>>
                      หมวดรอง&nbsp;&nbsp; <input type="radio" value="Seq" name="Type_itm" <% if (Type_itm.equals("Seq")) { out.println("checked"); } %>>
                      หมวดย่อย&nbsp;&nbsp;&nbsp;<A HREF="javascript:frmRep.submit();"><img border="0" src="images/bu_R.gif" align="absmiddle" style="cursor:hand" width="16" height="16"></A></td>
			  </tr>

            </table>


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
    <td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>
<%
		if (QTY.equals("Q1")) {
			f_name = "sum(a.q_itmjob) as q_sum1";
		} else if (QTY.equals("Q2")) {
			f_name = "sum(a.q_docno) as q_sum1";
		} else if (QTY.equals("Q3")) {
			f_name = "sum(a.z_amount) as q_sum1";
		} else if (QTY.equals("Q4")) {
			f_name = "sum(a.q_lock) as q_sum1";
		}
%>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr> 
          <td width="100%" class="frmL">
			<table border="0" width="100%" cellspacing="0" cellpadding="0">


			  <!-----------------------------------HEADER TABLE ------------------------------>
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
			  <!---------------------------------------------------------------------------------------------->
<% 
if (subboq.equals("nnnn") && seqboq.equals("nnnnnnnn")) {
		tb_name = "lan:serv_itmmain a";	
} else {
		tb_name = "lan:serv_itmseq a";	
}

						//-------------------MAIN ITEM ONLY ----------------------
						sql.delete(0,sql.length());
						sql.append("select distinct a.i_itmjob_main ")                                                 
							.append("from lan:serv_itmmain a ") 							
							.append("where a.i_type = '01' ");
				if (!i_proj.equals("ALL")) {
					   sql.append("and ("+queryProject+") ");  
				}
				if (!mainboq.equals("00")) {
					   sql.append("and i_itmjob_main = '"+mainboq+"' ");
				}
                       sql.append("order by a.i_itmjob_main ");
						servlog.startLog(sql.toString());
						rs = stmt.executeQuery(sql.toString());
						servlog.endLog();
						while (rs.next()) {

											// ------------------------NAME ITMJOB ------------------------
											n_itmjob = "";
											sql.delete(0,sql.length());
											sql.append("select n_itmjob from lan:serv_boq ")
												 .append("where i_itmjob = '"+doString.checkString(rs.getString("i_itmjob_main"))+"' ");
											servlog.startLog(sql.toString());
											rs2 = stmt2.executeQuery(sql.toString());
											servlog.endLog();
											if (rs2.next()) {
													n_itmjob = doString.checkString(doString.DisplayThai(rs2.getString("n_itmjob")));
											}							
						
										   sql.delete(0,sql.length());
										   sql.append("select a.i_month, a.i_year, "+f_name+" ")                           
												.append("from lan:serv_itmmain a ") 
												.append("where a.i_type = '01' ");      
										if (!i_proj.equals("ALL")) {
										   sql.append("and ("+queryProject+") ");  
										}
										   sql.append("and  a.i_itmjob_main = '"+doString.checkString(rs.getString("i_itmjob_main"))+"' ")                                           
												.append("group by a.i_month, a.i_year ")                                                    
												.append("order by a.i_month, a.i_year ");  										   		
											servlog.startLog(sql.toString());
											rs2 = stmt2.executeQuery(sql.toString());
											servlog.endLog();
											while (rs2.next()) {
												total_itmmain = 0;
													 for (int j=0;j<12;j++) {	
															 iMonth = rs2.getInt("i_month");
															 iYear = rs2.getInt("i_year");	
															  if (monthList[j].intValue()==iMonth && yearList[j].intValue()==iYear) {
																	maingrp[j] = new Integer(rs2.getInt("q_sum1"));																
															  } // end if		
																	total_itmmain += maingrp[j].intValue();	// totol item main																	
													} // end for	
											 } // end while		
																	total_all += total_itmmain;
				
%>																<tr>
																	 <td width="19%" height="1" align="center" class="item ; dotline"><div align="left"><FONT COLOR="rgb(0,50,200)"><%=doString.checkString(rs.getString("i_itmjob_main"))%>&nbsp;<%=n_itmjob%></FONT></div></td>
																	<%				loop = 0;
																			for (int i=0;i<Integer.parseInt(reportType);i++) {    

																	 %>			<td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(maingrp[i].intValue())%>&nbsp;</td>
																	 <%
																					loop++;		
																			} // end for				  
																			while (loop<12) {    %>
																					<td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
																						 loop++;															
																			 } // endwhile   %>																			                
																					<td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(total_itmmain)%>&nbsp;</td>
																		</tr>
<% 									
						for (int j=0;j<12;j++) {		
								maingrp[j] = new Integer(0);											
						} // end for	
						//-------------------SUB ITEM ONLY ----------------------
						sql.delete(0,sql.length());
						sql.append("select distinct a.i_itmjob_main, a.i_itmjob_sub ")                                                 
							.append("from lan:serv_itmsub a ") 
							.append("where a.i_type = '01' ");
				if (!i_proj.equals("ALL")) {
					   sql.append("and ("+queryProject+") ");  
				}
					   sql.append("and a.i_itmjob_main = '"+doString.checkString(rs.getString("i_itmjob_main"))+"' ");
				if (!subboq.equals("0000")) {
						sql.append("and a.i_itmjob_sub = '"+subboq.substring(2,4)+"' ");
				}
                        sql.append("order by a.i_itmjob_main, a.i_itmjob_sub ");
					//out.println(sql.toString());
						servlog.startLog(sql.toString());
						rs1 = stmt1.executeQuery(sql.toString());
						servlog.endLog();
						while (rs1.next()) {			
							
										// ------------------------NAME ITMJOB ------------------------
											n_itmjob = "";
											sql.delete(0,sql.length());
											sql.append("select n_itmjob from lan:serv_boq ")
												 .append("where i_itmjob = '"+doString.checkString(rs1.getString("i_itmjob_main"))+doString.checkString(rs1.getString("i_itmjob_sub"))+"' ");
											servlog.startLog(sql.toString());
											rs2 = stmt2.executeQuery(sql.toString());
											servlog.endLog();
											if (rs2.next()) {
													n_itmjob = doString.checkString(doString.DisplayThai(rs2.getString("n_itmjob")));
											}
													  
													   sql.delete(0,sql.length());
													   sql.append("select a.i_month, a.i_year, "+f_name+" ")                           
															.append("from lan:serv_itmsub a ")  
															.append("where a.i_type = '01' ");        
													if (!i_proj.equals("ALL")) {
														sql.append("and ("+queryProject+") ");  
													}
													   sql.append("and  a.i_itmjob_main = '"+doString.checkString(rs1.getString("i_itmjob_main"))+"' ")
															.append("and  a.i_itmjob_sub = '"+doString.checkString(rs1.getString("i_itmjob_sub"))+"' ")                                           
															.append("group by a.i_month, a.i_year ")                                                    
															.append("order by a.i_month, a.i_year ");    
														servlog.startLog(sql.toString());
														rs2 = stmt2.executeQuery(sql.toString());
														servlog.endLog();
														while (rs2.next()) {
															total_itmsub = 0;
																 for (int j=0;j<12;j++) {	
																		 iMonth = rs2.getInt("i_month");
																		 iYear = rs2.getInt("i_year");	
																		  if (monthList[j].intValue()==iMonth && yearList[j].intValue()==iYear) {
																				maingrp[j] = new Integer(rs2.getInt("q_sum1"));																
																		  } // end if			
																				total_itmsub += maingrp[j].intValue();	// totol item sub																				
																} // end for	
														 } // end while	
																				total_all += total_itmsub;
																					
%>																				<tr>	
																					<td width="19%" height="1" align="center" class="item ; dotline"><div align="left"><FONT COLOR="rgb(0,50,200)">&nbsp;-&nbsp;<%=doString.checkString(rs1.getString("i_itmjob_main"))+doString.checkString(rs1.getString("i_itmjob_sub"))%>&nbsp;<%=n_itmjob%></FONT></div></td>
																					<%				loop = 0;
																							for (int i=0;i<Integer.parseInt(reportType);i++) {    

																					 %>			<td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(maingrp[i].intValue())%>&nbsp;</td>
																					 <%
																									loop++;		
																							} // end for				  
																							while (loop<12) {    %>
																									<td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
																										 loop++;															
																							 } // endwhile   %>																			                
																									<td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(total_itmsub)%>&nbsp;</td>
																									</tr>	
<%	
										for (int j=0;j<12;j++) {		
												maingrp[j] = new Integer(0);											
										} // end for	
								   //------------------ SEQ ITEM ------------------------												  
								   sql.delete(0,sql.length());
								   sql.append("select distinct c.i_itmjob_main, c.i_itmjob_sub, c.i_itmjob_seq ")                 
										.append("from lan:serv_itmmain a, lan:serv_itmsub b, lan:serv_itmseq c ")
										.append("where a.i_type = '01' ");       
							if (!i_proj.equals("ALL")) {
								  sql.append("and ("+queryProject+") ");  
						    }
								   sql.append("and a.i_company = b.i_company ")                                                   
										.append("and b.i_company = c.i_company ")                                                   
										.append("and a.i_project = b.i_project ")                                                   
										.append("and b.i_project = c.i_project ")                                                   
										.append("and a.i_type = b.i_type ")                                                         
										.append("and b.i_type = c.i_type ")     										
										.append("and c.i_itmjob_main = '"+doString.checkString(rs1.getString("i_itmjob_main"))+"' ")
										.append("and c.i_itmjob_sub = '"+doString.checkString(rs1.getString("i_itmjob_sub"))+"' ");
						if (!seqboq.equals("00000000")) {
							       sql.append("and c.i_itmjob = '"+seqboq+"' ");
						}
								   sql.append("and a.i_itmjob_main = b.i_itmjob_main ")                                           
										.append("and b.i_itmjob_main = c.i_itmjob_main ")                                           
										.append("and b.i_itmjob_sub = c.i_itmjob_sub ")                                    
										.append("order by c.i_itmjob_main, c.i_itmjob_sub, c.i_itmjob_seq ");
									servlog.startLog(sql.toString());
									rs3 = stmt3.executeQuery(sql.toString());
									servlog.endLog();
									while (rs3.next()) {

														// ------------------------NAME ITMJOB ------------------------
														n_itmjob = "";
														sql.delete(0,sql.length());
														sql.append("select n_itmjob from lan:serv_boq ")
															 .append("where i_itmjob = '"+doString.checkString(rs3.getString("i_itmjob_main"))+doString.checkString(rs3.getString("i_itmjob_sub"))+doString.checkString(rs3.getString("i_itmjob_seq"))+"' ");
														servlog.startLog(sql.toString());
														rs2 = stmt2.executeQuery(sql.toString());
														servlog.endLog();
														if (rs2.next()) {
																 if (doString.checkString(doString.DisplayThai(rs2.getString("n_itmjob")))!=null && !doString.checkString(doString.DisplayThai(rs2.getString("n_itmjob"))).equals("")) {
																			 if (doString.checkString(doString.DisplayThai(rs2.getString("n_itmjob"))).length() >= 50) {
																					n_itmjob = doString.checkString(doString.DisplayThai(rs2.getString("n_itmjob"))).substring(0,50);																										
																			 } else {
																					n_itmjob = doString.checkString(doString.DisplayThai(rs2.getString("n_itmjob")));
																			 }
																 }																									
														} // end if rs2

																	   sql.delete(0,sql.length());
																	   sql.append("select a.i_month, a.i_year, "+f_name+" ")                           
																			.append("from lan:serv_itmseq a ")    
																			.append("where a.i_type = '01' ");        
															  if (!i_proj.equals("ALL")) {
																	   sql.append("and ("+queryProject+") ");  
															   }
																	   sql.append("and  a.i_itmjob_main = '"+doString.checkString(rs3.getString("i_itmjob_main"))+"' ")
																			.append("and  a.i_itmjob_sub = '"+doString.checkString(rs3.getString("i_itmjob_sub"))+"' ")  
																		    .append("and  a.i_itmjob_seq = '"+doString.checkString(rs3.getString("i_itmjob_seq"))+"' ")          
																			.append("group by a.i_month, a.i_year ")                                                    
																			.append("order by a.i_month, a.i_year ");    
																		servlog.startLog(sql.toString());
																		rs2 = stmt2.executeQuery(sql.toString());
																		servlog.endLog();
																		while (rs2.next()) {
																			total_itmseq = 0;
																				 for (int j=0;j<12;j++) {	
																						 iMonth = rs2.getInt("i_month");
																						 iYear = rs2.getInt("i_year");	
																						  if (monthList[j].intValue()==iMonth && yearList[j].intValue()==iYear) {
																								maingrp[j] = new Integer(rs2.getInt("q_sum1"));																										
																						  } // end if		
																						 total_itmseq += maingrp[j].intValue();																							 
																				} // end for	
																		 } // end while	
																						 total_all += total_itmseq;

%>
																					<tr> 
																						<td width="19%" height="1" align="center" class="item ; dotline"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;<%=doString.checkString(rs3.getString("i_itmjob_main"))+doString.checkString(rs3.getString("i_itmjob_sub"))+doString.checkString(rs3.getString("i_itmjob_seq"))%>&nbsp;<%=n_itmjob%></div></td>
																			<%		loop = 0;
																				for (int i=0;i<Integer.parseInt(reportType);i++) {   						
																			%>		<td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(maingrp[i].intValue())%>&nbsp;</td>
																			<%		loop++;
																				} // end for				  
																				while (loop<12) {    %>
																						<td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
																						loop++;
																				} // endwhile   %>																			                
																						<td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(total_itmseq)%>&nbsp;</td>
																					</tr>
<%  									
											for (int j=0;j<12;j++) {		
												maingrp[j] = new Integer(0);											
											} // end for	
								}    // end while rs3
						} // end while rs1
				} // end while  rs		
	//} // end if check 
%>
<%
										   //----------------------------  Grand Total -------------------------------
										   sql.delete(0,sql.length());
										   sql.append("select a.i_month, a.i_year, "+f_name+" ")                           
												.append("from "+tb_name+" ")        
												.append("where a.i_type = '01' ");
									 if (!i_proj.equals("ALL")) {
										   sql.append("and ("+queryProject+") ");  
									  }
									  if (!mainboq.equals("00")) {
										  sql.append("and a.i_itmjob_main = '"+mainboq+"' ");
									} if (!subboq.equals("0000") && !subboq.equals("nnnn")) {
										  sql.append("and a.i_itmjob_sub = '"+subboq.substring(2,4)+"' ");
									} if (!seqboq.equals("00000000") && !seqboq.equals("nnnnnnnn")) {
							               sql.append("and a.i_itmjob = '"+seqboq+"' ");
									}
									       sql.append("group by a.i_month, a.i_year ")                                                    
												.append("order by a.i_month, a.i_year ");    
										  //out.println(sql.toString());
											servlog.startLog(sql.toString());
											rs2 = stmt2.executeQuery(sql.toString());
											servlog.endLog();
											while (rs2.next()) {
													 for (int j=0;j<12;j++) {	
															 iMonth = rs2.getInt("i_month");
															 iYear = rs2.getInt("i_year");	
															  if (monthList[j].intValue()==iMonth && yearList[j].intValue()==iYear) {
																	summnth[j] = new Integer(rs2.getInt("q_sum1"));																
															  } // end if					
													} // end for	
											 } // end while		                                                                              
                                  
%>
															<tr> 
															<td width="19%" height="1" align="center" class="item ; dotline"><div align="right">รวม</div></td>
											<%
																loop = 0;
																for (int i=0;i<Integer.parseInt(reportType);i++) { 						
											%>					  
																	  <td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(summnth[i].intValue())%></td><%
																	   loop++;
																} // end for				  
																while (loop<12) {
																	%><td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
																	loop++;
																}
															%>                
															<td width="3%" align="right" valign="middle" class="dotline"><%=format1.format(total_all)%>&nbsp;</td>
														  </tr>
<%
											for (int j=0;j<12;j++) {		
												summnth[j] = new Integer(0);											
											} // end for	
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
  <tr>
    <td width="100%" align="left"><FONT COLOR="#FF0000">*** เดือนที่ผู้รับเหมาส่งงวดงาน หมายถึง เดือนที่ผู้รับเหมา click ส่งงวดงาน </FONT></td>
	</tr>
	</table>
<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="80" class="act_tab2">&nbsp;</td> 	
            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_Report11.jsp" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
		System.out.println("ERROR SERV_Report11_1.jsp : " + e.getMessage());
		System.out.println("ERROR SQL  SERV_Report11_1.jsp : " + sql.toString());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (rs1 != null) rs1.close();
			if (rs2 != null) rs2.close();
			if (rs3 != null) rs3.close();
			if (stmt != null) stmt.close();
			if (stmt1 != null) stmt1.close();
			if (stmt2 != null) stmt2.close();
			if (stmt3 != null) stmt3.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>