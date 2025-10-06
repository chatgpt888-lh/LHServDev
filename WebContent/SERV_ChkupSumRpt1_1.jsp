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
<TITLE>สรุปงาน Check up ประจำเดือน</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">

function showLock(seqNo, type, chkMnth, chkYear) {
	frmRep.seqNo.value = seqNo;
	frmRep.type.value = type;
	frmRep.chkMonth.value = chkMnth;
	frmRep.chkYear.value = chkYear;
	frmRep.action = "/LHServ/InitChkupLckServlet";
	frmRep.submit();
}
</script>



<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">


<FORM NAME = "frmRep" ACTION="SERV_ChkupSumRpt1_1.jsp" METHOD="POST">


<input type="hidden" name="month_report" value="<%=monthReport%>">
<input type="hidden" name="year_report" value="<%=yearReport%>">
<input type="hidden" name="report_type" value="<%=reportType%>">

<input type="hidden" name="seqNo" value="">
<input type="hidden" name="type" value="">
<input type="hidden" name="chkMonth" value="">
<input type="hidden" name="chkYear" value="">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp; 
            สรุปงาน Check up ประจำเดือน</td>
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
	เดือน : <%=showMonth%> &nbsp; พ.ศ. <%=showYear%> &nbsp; &nbsp; , ประเภท : <%=reportType%> เดือน</td>
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
                
          <td class="item_tab2" width="200">รายละเอียดโครงการ</td>
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
    <td width="100%" class="frmL" align="center">


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="40%" height="1" class="col_name">โครงการ</td>    
    <td width="30%" height="1" class="col_name">ร้านค้าแอร์</td>        
    <td width="30%" height="1" class="col_name">ร้านค้าปลวก</td>            
  </tr>        
	<%
	  String[] projList = request.getParameterValues("sel_proj");
  	  String queryProject = "";			
	  String proj = "", i_proj = "";
	  int line = 0;
	  boolean allProj = false;
	  if (projList!=null) {
		  for (int i=0;i<projList.length;i++) {		
				 proj = doString.checkString(projList[i],"");  		
				 i_proj = proj.substring(3,6);
				 if (proj.trim().length()>=6) {	
						 if (queryProject.trim().length()>0) queryProject += " or ";
						 queryProject += " (a.i_company='"+proj.substring(0,2)+"' and a.i_project='"+proj.substring(3,6)+"') ";	
				 }
				//---============= get Project Details ===============----//
				sql.delete(0,sql.length()); 
				sql.append(" select * from lan:acxprojt ")
					  .append(" where i_company='").append(proj.length()>=6 ? proj.substring(0,2) : "").append("' ")
					  .append(" and i_project='").append(proj.length()>=6 ? proj.substring(3,6) : "").append("' ");
				rs = stmt.executeQuery(sql.toString());
				if (rs.next()) {
							 String nProject = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
							 String air = "&nbsp;";
							 String ant = "&nbsp;";
							 rs2 = stmt2.executeQuery("SELECT v.ven_name FROM lan:serv_venprj p, lan:vendor v WHERE p.i_company = '"+proj.substring(0,2)+"' AND p.i_project = '"+proj.substring(3,6)+"' AND p.i_type = '03' AND p.i_vendor = v.ven_no");
							 if (rs2 != null) {
							 	if (rs2.next() == true) {
								 	air = doString.checkString(doString.DisplayThai(rs2.getString("ven_name")),"");
							 	}
							 	rs2.close();
							 	rs2=null;
							 }
							 rs2 = stmt2.executeQuery("SELECT v.ven_name FROM lan:serv_venprj p, lan:vendor v WHERE p.i_company = '"+proj.substring(0,2)+"' AND p.i_project = '"+proj.substring(3,6)+"' AND p.i_type = '04' AND p.i_vendor = v.ven_no");
							 if (rs2 != null) {
							 	if (rs2.next() == true) {
								 	ant = doString.checkString(doString.DisplayThai(rs2.getString("ven_name")),"");
							 	}
							 	rs2.close();
							 	rs2=null;
							 }
							 
							 String iProj = str.replace(proj,":","-");	
							 
							%>
							  <tr>
							<td height="22" width="40%" class="dotline">
							<input type="hidden" name="sel_proj" value="<%=proj%>">
							<%=iProj%> <%=nProject%>
							</td>
							<td height="22" width="30%" class="dotline"><%=air%></td>
							<td height="22" width="30%" class="dotline"><%=ant%></td>
							</tr> 
<%
				} // end while
				rs.close();
				rs=null;
				

		  } // end for
	  } else {
		  queryProject = " a.i_company='' and a.i_project='' ";
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
                
          <td class="item_tab2" width="200">รายละเอียดงาน Checkup ประจำเดือน</td>
                <td class="item_tab3"></td>                
				<td>&nbsp;</td>
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
<%
		f_name = "sum(a.q_lock) as q_sum1";
%>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr> 
          <td width="100%" class="frmL">
			<table border="0" width="100%" cellspacing="0" cellpadding="0">


			  <!-----------------------------------HEADER TABLE ------------------------------>
              <tr> 
                <td width="19%" height="1" class="col_name">รายละเอียด</td>
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
			String seqNo = "";
			line=0;
			String bgcolor = "";
			for (int c=1; c<=2; c++) {
						seqNo = Integer.toString(c);
						for (int j=0;j<12;j++) {		
								maingrp[j] = new Integer(0);											
						} // end for					
						bgcolor = ((line%2) == 0) ? "FAFAFA" : "FFFFFF";
						line++;
%>
																<tr bgcolor="#<%=bgcolor%>">
																	 <td width="19%" height="1" align="center" class="item ; dotline"><div align="left"><FONT COLOR="rgb(0,50,200)">Check up ครั้งที่ <%=c%></FONT></div></td>
															<%				loop = 0;
																			while (loop<12) {    %>
																					<td width="3%" align="center" valign="middle" class="dotline">&nbsp;</td><%
																						 loop++;															
																			 } // endwhile   %>																			                
																					<td width="3%" align="right" valign="middle" class="dotline">&nbsp;</td>
																		</tr>
<%						
						//-------------------MAIN ITEM ONLY ----------------------
						rs = stmt.executeQuery("SELECT i_main, n_desc FROM lan:serv_chkrep WHERE i_sub = '00' ORDER BY i_main");
						while (rs.next()) {
										n_itmjob = doString.checkString(doString.DisplayThai(rs.getString("n_desc")));
										   sql.delete(0,sql.length());
										   sql.append("select a.i_month, a.i_year, "+f_name+" ")                           
												.append("from lan:serv_chkmain a ") 
												.append("where a.i_chkseq = "+seqNo+" ");      
										if (!i_proj.equals("ALL")) {
										   sql.append("and ("+queryProject+") ");  
										}
										   sql.append("and  a.i_main = '"+doString.checkString(rs.getString("i_main"))+"' ")                                           
												.append("group by a.i_month, a.i_year ")                                                    
												.append("order by a.i_month, a.i_year ");  										   		
											rs2 = stmt2.executeQuery(sql.toString());
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
											bgcolor = ((line%2) == 0) ? "FAFAFA" : "FFFFFF";
											line++;
%>																<tr bgcolor="#<%=bgcolor%>">
																	 <td width="19%" height="1" align="center" class="item ; dotline"><div align="left"><%=n_itmjob%></div></td>
																	<%				loop = 0;
																			for (int i=0;i<Integer.parseInt(reportType);i++) {    
																	 %>			<td width="3%" align="right" valign="middle" class="dotline">
																	 <% if (!doString.checkString(rs.getString("i_main")).equals("08")) {%>
																	 <A HREF="javascript:showLock('<%=seqNo%>', '<%=doString.checkString(rs.getString("i_main"))%>', '<%=doString.displayNumber("00", monthList[i].intValue())%>', '<%=yearList[i].intValue()-543%>')">
																	 <%}%><%=format1.format(maingrp[i].intValue())%>&nbsp;</td>
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
						rs1 = stmt1.executeQuery("SELECT i_main, i_sub, n_desc FROM lan:serv_chkrep WHERE i_main = '"+doString.checkString(rs.getString("i_main"))+"' AND i_sub != '00' ORDER BY i_sub");
						while (rs1.next()) {			
							
										// ------------------------NAME ITMJOB ------------------------
										n_itmjob = doString.checkString(doString.DisplayThai(rs1.getString("n_desc")));
													   sql.delete(0,sql.length());
													   sql.append("select a.i_month, a.i_year, "+f_name+" ")                           
															.append("from lan:serv_chksub a ")  
															.append("where a.i_chkseq = "+seqNo+" ");        
													if (!i_proj.equals("ALL")) {
														sql.append("and ("+queryProject+") ");  
													}
													   sql.append("and  a.i_main = '"+doString.checkString(rs1.getString("i_main"))+"' ")
															.append("and  a.i_sub = '"+doString.checkString(rs1.getString("i_sub"))+"' ")                                           
															.append("group by a.i_month, a.i_year ")                                                    
															.append("order by a.i_month, a.i_year ");    
														rs2 = stmt2.executeQuery(sql.toString());
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
														bgcolor = ((line%2) == 0) ? "FAFAFA" : "FFFFFF";
														line++;
%>																				<tr bgcolor="#<%=bgcolor%>">
																					<td width="19%" height="1" align="center" class="dotline"><div align="left">&nbsp;-&nbsp;<%=n_itmjob%></div></td>
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
						} // end while rs1
				} // end while  rs		
			}// end for
%>

              <tr> 
                <td width="19%" height="1" class="col_name">รายละเอียด</td>
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
            </table>
    </td>
  </tr>
</table>
<!--
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>
-->
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
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_ChkupSumRpt1.jsp" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
		System.out.println("ERROR SERV_ChkupSumRpt1_1.jsp : " + e.getMessage());
		System.out.println("ERROR SQL  SERV_ChkupSumRpt1_1.jsp : " + sql.toString());
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