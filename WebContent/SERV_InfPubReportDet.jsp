<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>

<%@page import="com.lh.util.*" %>
<%@page import="java.text.DecimalFormat" %>
<%@page import="serv.common.User" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%!

	public String displayDate(String date) {
		String result = "";
		
		if (date.length()>=10) {
			int year = Integer.parseInt(date.substring(0,4));
			if (year<2400) year += 543;			
		    result = date.substring(8,10)+"/"+date.substring(5,7)+"/"+year;
		}
		
		return result;
	}
	
	public Calendar convertDate(String date) {
		Calendar result = null;
		
		try {
			if (date.length()>=10) {
				result = Calendar.getInstance();
				int y = Integer.parseInt(date.substring(0,4));
				if (y>2400) y -= 543;
				int m = Integer.parseInt(date.substring(5,7));
				int d = Integer.parseInt(date.substring(8,10));
				
				result.set(y,m-1,d);
			}
		} catch (Exception ex) {
			result = null;
		}
		
		return result;
	}
	
	public int calculateMonthDiff(String sDate,String eDate) {
		int result = 0;
		
		if (sDate.length()>=10 && eDate.length()>=10) {
			int y = Integer.parseInt(sDate.substring(0,4));
			if (y>2400) y -= 543;
			int m = Integer.parseInt(sDate.substring(5,7));
			Calendar start = Calendar.getInstance();
			start.set(y,m,1,0,0,0); // use month+1 to start calculate
			
			y = Integer.parseInt(eDate.substring(0,4));
			if (y>2400) y -= 543;
			m = Integer.parseInt(eDate.substring(5,7));
			Calendar end = Calendar.getInstance();
			end.set(y,m-1,1,0,0,0);
			
			while (!start.after(end)) {
				result++;
				start.add(Calendar.MONTH,1);
			} // end while
		}
		
		return result;
	}	
	
	public String displayAmount(double val) {
		return doString.displayNumber("###,###,##0.00",val);
	}
	
	public double rounding2Digit(double val) throws Exception {		
		double result = 0.0;
		
		try {
			result = Double.parseDouble(doString.displayNumber("######0.00",val));
		} catch (Exception ex) {
			throw new Exception("ROUNDING_ERR_"+val);
		}
		
		return result;
	}

	public double[] sumMonthly(double zUnitMonth,double[] zAmtMonth,String dCalculate,String dEndProj,int zMonth,int rptYear,String selVat) throws Exception {
		double result = 0.0;
		Calendar calDEndProj = convertDate(dEndProj);
		int yEnd = calDEndProj.get(Calendar.YEAR);
		int mEnd = calDEndProj.get(Calendar.MONTH);
		
		//--- start next month for calculate ---//
		Calendar calDCalculate = convertDate(dCalculate);
		int yClose = 0;
		int mClose = 0;
		
		for (int i=0;i<zMonth;i++) {
			calDCalculate.add(Calendar.MONTH,1);
			yClose = calDCalculate.get(Calendar.YEAR);
			mClose = calDCalculate.get(Calendar.MONTH);
			
			if (yClose==rptYear) {
				if ((yEnd>yClose) || (yEnd==yClose && mEnd>=mClose)) {
					if (selVat.equals("Y")) {
						zAmtMonth[mClose] += rounding2Digit(zUnitMonth);
					} else {
						zAmtMonth[mClose] += rounding2Digit((zUnitMonth*100)/107);
					}						
				} 							
			} else if (yClose>rptYear) {
				//--- data after report year not use ---//
				break;
			}
		} // end for
		

		return zAmtMonth;
	}

%>


<%
	String iCompany = doString.checkString(request.getParameter("i_company"),"");
	String iProject = doString.checkString(request.getParameter("i_project"),"");
	String iPhase = doString.checkString(request.getParameter("i_phase"),"");
	int rptYear = Integer.parseInt(doString.checkString(request.getParameter("rpt_year"),"0"));
	String rptTransDate = doString.checkString(request.getParameter("trans_date"),"");
	String selVat = doString.checkString(request.getParameter("sel_vat"),"N");
	  
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
        //----=============================================----// 
        
        
		//----- find project name and phase details -----//
		String nProject = "";
        String dEndProject = "";
        String fExtra = "";
        double zPrice = 0.0;
		sql.delete(0,sql.length());
		sql.append(" select p.n_project,d.z_price,h.* from lan:acxprojt p ")
		   .append(" left join lan:acspubhd h on h.i_company=p.i_company and h.i_project=p.i_project ")
		   .append(" left join lan:acspubdt d on d.i_company=h.i_company and d.i_project=h.i_project and d.i_phase=h.i_phase ")
		   .append(" where p.i_company='"+iCompany+"' and p.i_project='"+iProject+"' ")
		   .append(" and h.i_phase='"+iPhase+"' ");
		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
			nProject = doString.checkString(rs.getString("n_project"),"");
			dEndProject = doString.checkString(rs.getString("d_end_project"),"");
			fExtra = doString.checkString(rs.getString("f_extra"),"");
			zPrice = rs.getDouble("z_price");
		} 
		rs.close();
		
%>

<HTML>
<HEAD>
<TITLE>Report</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<base target="_self">

<SCRIPT LANGUAGE="JavaScript">
<!-- 
	
  function printExcel() {
	 document.forms[0].action="/LHServ/SERV_InfPubReportDetXlsServlet";
	 document.forms[0].target="_blank";
	 document.forms[0].submit();
	 document.forms[0].target="";
  }    

//-->
</SCRIPT>

</HEAD>

<BODY leftMargin=0 topMargin=0 marginwidth="0" marginheight="0">


<FORM METHOD="POST" ACTION="">

<input type="hidden" name="i_company" value="<%=iCompany %>">
<input type="hidden" name="i_project" value="<%=iProject %>">
<input type="hidden" name="i_phase" value="<%=iPhase %>">
<input type="hidden" name="rpt_year" value="<%=rptYear %>">
<input type="hidden" name="trans_date" value="<%=rptTransDate %>">
<input type="hidden" name="sel_vat" value="<%=selVat %>">


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center" class="BD">
    

      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
          รายงานสรุปค่าบริการสาธารณูปโภคแยกตามโครงการ (รายได้ตามเกณฑ์สิทธิ์)</td>
          <td width="30%" align="right">
          </td>
        </tr>
      </table>


<br style="font-size:10pt">


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
    <td height="22" width="14%" class="item ; dotline01">โครงการ :</td>
    <td height="22" width="43%" class="dotline01">&nbsp;<%=iCompany+iProject+" | "+doString.DisplayThai(nProject) %></td>
    <td height="22" width="14%" class="item ; dotline01">เฟส :</td>
    <td height="22" width="43%" class="dotline01">&nbsp;<%=iPhase %></td>
  </tr>
  <tr>
    <td height="22" width="14%" class="item ; dotline01">วันที่สิ้นสุดโครงการ :</td>
    <td height="22" width="43%" class="dotline01">&nbsp;<%=displayDate(dEndProject) %></td>
    <td height="22" width="14%" class="item ; dotline01">อัตราค่าสาธาณูปโภค :</td>
    <td height="22" width="43%" class="dotline01">&nbsp;<%=displayAmount(zPrice) %> &nbsp; 
    <%
    	if (fExtra.equals("Y")) {
    		%>บาท / หลัง<% 
    	} else {
    		%>บาท / ตารางวา<%     		
    	}
    %>
    </td>
    <td height="22" width="14%" class="item ; dotline01">&nbsp;</td>
    <td height="22" width="43%" class="dotline01">&nbsp;</td>
  </tr>   
  <tr>
    <td height="5" width="14%"  class="dotline01" colspan="4">&nbsp;</td>
  </tr>    
  <tr>
    <td height="22" width="14%" class="item ; dotline01" width="14%">ปีที่ออกรายงาน :</td>
    <td height="22" width="43%" class="dotline01">&nbsp;<%=(rptYear+543) %></td>
    <td height="22" width="14%" class="item ; dotline01" width="14%">โอนนิติกรรมถึงวันที่ :</td>
    <td height="22" width="43%" class="dotline01">&nbsp;<%=displayDate(rptTransDate) %></td>
  </tr>
  <tr>
    <td height="22" width="14%" class="item ; dotline01" width="14%">&nbsp;แสดงรายงานแบบ : </td>
    <td height="22" width="86%" class="dotline01" colspan="3">
    <%=(selVat.equals("N") ? "ไม่รวม Vat" : "รวม Vat") %>
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
    <td width="100%" class="frmL" align="center">
    
    
<table border="0" width="100%" cellspacing="0" cellpadding="0">
    <tr>
      <td width="4%" class="col_name">ลำดับ</td>
      <td width="8%" class="col_name">แปลงขาย</td>
      <td width="8%" class="col_name">วันที่โอน</td>
      <td width="8%" class="col_name">วันที่คำนวน</td>
      <td width="5%" class="col_name">จำนวนเดือน</td>
      <td width="8%" class="col_name">จำนวนเงิน</td>
      <td width="8%" class="col_name">ยอดคงค้าง</td>
      <%
      	String monthName[] = new String[]{"","ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค."};
      	for (int m=1;m<=12;m++) {
      		%><td width="4%" class="col_name"><%=monthName[m] %></td><%
      	} // end for
      %>
      <td width="8%" class="col_name">รวม</td>
   </tr>
      <%
        double zAmtMonth[] = new double[]{0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0};
      	double totalInfPub = 0.0;
      	double zUnitMonth = 0.0;
      	double totalYear = 0.0;
      	double zAccrue = 0.0;
      	String dCalculate = "";
      	String dPubTran = "";
      	String dCloseLaw = "";
      	String iSort = "";
      	double zPublic = 0.0;
      	int zMonth = 0;
      	int cntLock = 0;      	
      	int cntSameMonth = 0;
      	boolean noMemo = false;
      	
		//--- total ---//
		double sumInfPub = 0.0;
		double sumAccrue = 0.0;
		double grandTotal = 0.0;
		double sumMonth[] = new double[]{0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0};  
		boolean sameMonthWithEndProj = false;    	

 			
		///---- find z_public -----//
		//sql.delete(0,sql.length());
		//sql.append(" select d.z_accrue,c.i_sort,m.d_pubtran,c.d_close_law,m.z_public,m.z_month ")
		//   .append(" from lan:acscontr c ")
		//   .append(" left join lan:acrduerv d on d.i_company=c.i_company and d.i_project=c.i_project and d.i_lor=c.i_lor and d.i_due='C0' ")
		//   .append(" ,lan:acspbmmo m,lan:acspubhd p ")
		//   .append(" where c.i_company='"+iCompany+"' and c.i_project='"+iProject+"' ")
		//   .append(" and m.i_phase='"+iPhase+"' and c.d_close_law <= '"+rptTransDate+"' ")
		//   .append(" and c.d_lor > '1999-03-31' and c.f_contr is null and c.d_close_law is not null ")
		//   .append(" and m.i_company=c.i_company and m.i_project=c.i_project and m.i_lor=c.i_lor ")
		//   .append(" and p.i_company=m.i_company and p.i_project=m.i_project and p.i_phase=m.i_phase ")
		//   .append(" and m.f_status = 'OPN' ")//and m.f_print in ('Y','R') ")
		//   .append(" order by c.i_sort ");
		
		//---- 2022-01-14 , change query , use i_phase from lan:acxslock and use amount from 'C0' in case no memo found ----//
		sql.delete(0,sql.length());
		sql.append(" select d.z_accrue,d.d_due,d.z_amount,c.i_sort,m.d_pubtran,c.d_close_law, ")
		   .append(" nvl(m.z_public,0) as z_public,nvl(m.z_month,0) as z_month ")
		   .append(" from lan:acscontr c ")
		   .append(" left join lan:acrduerv d on d.i_company=c.i_company and d.i_project=c.i_project and d.i_lor=c.i_lor and d.i_due='C0' ")
		   .append(" left join lan:acspbmmo m on m.i_company=c.i_company and m.i_project=c.i_project and m.i_lor=c.i_lor and m.f_status = 'OPN' ")
		   .append(" left join lan:acxslock l on l.i_company=c.i_company and l.i_project=c.i_project and l.i_lock=c.i_sort ")
		   .append(" left join lan:acspubhd p on p.i_company=l.i_company and p.i_project=l.i_project and p.i_phase=l.i_phase ")
		   .append(" where c.i_company='"+iCompany+"' and c.i_project='"+iProject+"' ")
		   .append(" and l.i_phase='"+iPhase+"' and c.d_close_law <= '"+rptTransDate+"' ")
		   .append(" and c.d_lor > '1999-03-31' and c.f_contr is null and c.d_close_law is not null ") 
		   .append(" order by c.i_sort ");		   
		rs = stmt.executeQuery(sql.toString());
		while (rs.next()) {
			iSort = doString.checkString(rs.getString("i_sort"),"");
			zAmtMonth = new double[]{0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0};
			totalInfPub = 0.0;
			zPublic = rs.getDouble("z_public");
			zMonth = rs.getInt("z_month");			
			zAccrue = rs.getDouble("z_accrue");
			noMemo = false;
			
			//------ 2022-01-14 , data in lan:acspbmm not found , calculate new value from 'C0' -------//
			if (zPublic<=0 || zMonth<=0) {
				zPublic = rs.getDouble("z_amount");
				zMonth = calculateMonthDiff(doString.checkString(rs.getString("d_due"),""),dEndProject);
				noMemo = true;
			} 
			//-----------------------------------------------------------------------------------------//			
			
			if (selVat.equals("Y")) {
				totalInfPub = zPublic;					
			} else {
				totalInfPub = rounding2Digit((zPublic*100)/107);
			}			
			
			
      		//--- sum total data ---//
    		sumInfPub += totalInfPub;			
    		sumAccrue += zAccrue;			
			
			
			//--- use d_pubran fro memo to calculate. if blank, use d_close_law instead ---//
			dPubTran = doString.checkString(rs.getString("d_pubtran"),"");
			dCloseLaw = doString.checkString(rs.getString("d_close_law"),"");
			dCalculate = dPubTran.length()>=10 ? dPubTran : dCloseLaw;
			
			
			//============ 2022-01-14 , special case for d_close_law and d_end_project is same month ============//
			sameMonthWithEndProj = false; 
			if (dCalculate.substring(0,7).equals(dEndProject.substring(0,7)) && zMonth>0 && zPublic>0) {
				doString str = new doString();
				Calendar calDEndProj = convertDate(dEndProject);
				calDEndProj.add(Calendar.MONTH,1);
				int y = calDEndProj.get(Calendar.YEAR);
				if (y>2400) y -= 543;
				int m = calDEndProj.get(Calendar.MONTH)+1;
				
				zAmtMonth = sumMonthly(rounding2Digit(zPublic),zAmtMonth,dCalculate,y+"-"+str.createID(m,2)+"-01",1,rptYear,selVat);
				sameMonthWithEndProj = true;
				cntSameMonth++;
			}
			//===================================================================================================// 			
			
			
			//======== normal case ========//
			else {
				zUnitMonth = 0.0;
				if (zMonth>0) {
					zUnitMonth = rounding2Digit(zPublic/zMonth);
				} else {
					zUnitMonth = 0.0;
				}				
				zAmtMonth = sumMonthly(zUnitMonth,zAmtMonth,dCalculate,dEndProject,zMonth,rptYear,selVat);
			}
			//============================//
			
			
			//---- start print detail line ----//
			cntLock++;
			
			%>
		      <tr height="21px" <%=(noMemo ? " bgcolor='#FDDBDB' " : "") %>>
		        <td align="center" class="dotline">&nbsp;<%=cntLock %></td>
		        <td align="center" class="dotline">&nbsp;<%=iSort %></td>
		        <td align="center" class="dotline">&nbsp;<%=displayDate(dCloseLaw) %></td>
		        <td align="center" class="dotline">&nbsp;<%=displayDate(dPubTran) %></td>
		        <td align="right" class="dotline">&nbsp;<%=zMonth %></td>
		        <td align="right" class="dotline"><%=displayAmount(totalInfPub) %></td>		        		        
		        <td align="right" class="dotline"><%=displayAmount(zAccrue) %></td>
				<%
				totalYear = 0.0;
		      	for (int m=0;m<12;m++) {
		      		totalYear += rounding2Digit(zAmtMonth[m]);
		      		sumMonth[m] += rounding2Digit(zAmtMonth[m]);
		      		
		      		if (sameMonthWithEndProj) {
			  			%><td align="right" class="dotline"><nobr><span style='color:red'>* <%=displayAmount(zAmtMonth[m]) %></span></nobr></td><%
			  		} else {
			  			%><td align="right" class="dotline"><%=displayAmount(zAmtMonth[m]) %></td><%
			  		}
		      		
		      		
		      	} // end for	
		      	
		      	grandTotal += totalYear;
				%>	
				<td align="right" class="dotline"><span style='color:red'><%=displayAmount(totalYear) %></span></td>	        
		      </tr>			
			<%			
			
		} // end while
		rs.close();	
		
        
		  
	    if (cntLock<=0) {	
		      %>		      		      
		      <tr>
		        <td align="center" class="solidline">&nbsp;</td>
		        <td align="center" class="solidline">&nbsp;</td>
		        <td align="center" class="solidline">&nbsp;</td>
		        <td align="center" class="solidline">&nbsp;</td>
		        <td align="center" class="solidline">&nbsp;</td>
		        <td align="center" class="solidline">&nbsp;</td>
		        <td align="center" class="solidline">&nbsp;</td>
				<%
		      	for (int m=0;m<12;m++) {
		      		%><td align="center" class="solidline">&nbsp;</td><%
		      	} // end for				
				%>	
		        <td align="center" class="solidline">&nbsp;</td>
		      </tr> 
			  <%
	  	}
	  
	  	//----- print total line -----//
	  	%>  
		  <tr>
		    <td align="center" class="solidline" colspan="5">&nbsp;<b style='color:red'>รวม</b></td>
		    <td align="right" class="item ; solidline">&nbsp;<%=displayAmount(sumInfPub) %></td>
		    <td align="right" class="item ; solidline">&nbsp;<%=displayAmount(sumAccrue) %></td>
			<%
		  	for (int m=0;m<12;m++) {
		  		%><td align="right" class="item ; solidline">&nbsp;<%=displayAmount(sumMonth[m]) %></td><%
		  	} // end for				
			%>	
		    <td align="right" class="item ; solidline">&nbsp;<b style='color:red'><%=displayAmount(grandTotal) %></b></td>
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

<%
	if (cntSameMonth>0) {
		%>
		<br style="font-size:4pt">
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
		  <tr>
		    <td width="100%">
    		<span style='color:red; font-size:10pt'>&nbsp; * แปลงขายที่วันที่โอนอยู่เดือนเดียวกับวันที่สิ้นสุดโครงการ, ยอดจะลงรวมกันอยู่ในเดือนเดียว ไม่ได้กระจาย</span>
		    </td>
		  </tr>
		</table>		
		<%
	}
 %>

<br style="font-size:10pt">


        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="90" class="act_tab2">
			<img border="0" src="images/act_export2excel.gif" onclick="printExcel();"
				onmouseout=nereidFade(this,70,50,5)    
				onmouseover=nereidFade(this,100,50,5)     
				style="FILTER: alpha(opacity=70); cursor:hand" width="70" height="27">	
			</td>   
            <td class="act_tab3"></td>   
            <td class="act_tab4">&nbsp;
          	<a href="javascript:history.back();"><img border=0 src="images/bu_back.gif" width=50 align=absMiddle height=15></a>
             &nbsp;             
            <a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>  
        </table>  


<br style="font-size:5pt">





    </td>
  </tr>
</table>

			
			

<br style="font-size:30pt">

<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
  <tr><td width="100%" class="copyright" align="center">
  Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version
  6  
  <br>ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;
  หรือ โทร. 0-2230-8498 (ฝ่าย IT)  
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE> 

</HTML>
<%
		stmt.close();
		stmt1.close();
		conn.close();
		stmt = null;
		stmt1 = null;
		conn = null;		

	} catch (Exception e) {
		System.out.println("ERROR O_LOR_InfPubReportDet.jsp : " + e.getMessage());
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

