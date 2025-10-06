<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>

<%@page import="com.lh.util.*" %>
<%@page import="java.text.DecimalFormat" %>
<%@page import="serv.common.User" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%!

	public String displayDate(String date) throws Exception {
		String result = "";
		
		try {
			if (date.length()>=10) {
				int year = Integer.parseInt(date.substring(0,4));
				if (year<2400) year += 543;			
			    result = date.substring(8,10)+"/"+date.substring(5,7)+"/"+year;
			}
		} catch (Exception ex) {
			throw new Exception("DISP_DATE_ERR_"+date);
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
	
	public double calculateZInfAmt(double zUnitMonth,String dStart,String dStop,String dEndProj,String selVat) throws Exception {
		double result = 0.0;
		
		Calendar calEndProj = convertDate(dEndProj);
		int yEndProj = calEndProj.get(Calendar.YEAR);
		int mEndProj = calEndProj.get(Calendar.MONTH);		
		
		Calendar calEnd = convertDate(dStop);
		int yEnd = calEnd.get(Calendar.YEAR);
		int mEnd = calEnd.get(Calendar.MONTH);
		
		//--- check d_end_project & d_stop , use minimum month ---//
		if (yEndProj<yEnd || (yEndProj==yEnd && mEndProj<mEnd)) {
			yEnd = yEndProj;
			mEnd = mEndProj;
		}
		
		//--- start next month for calculate ---//
		Calendar calStart = convertDate(dStart);
		int yStart = 0;
		int mStart = 0;
		
		for (int i=0;i<99;i++) {
			calStart.add(Calendar.MONTH,1);
			yStart = calStart.get(Calendar.YEAR);
			mStart = calStart.get(Calendar.MONTH);
			
			if (yEnd>=yStart) {
				if ((yEnd>yStart) || (yEnd==yStart && mEnd>=mStart)) {
					if (selVat.equals("Y")) {
						result += rounding2Digit(zUnitMonth);
					} else {
						result += rounding2Digit((zUnitMonth*100)/107);
					}		
				} else if (yEnd==yStart && mEnd<mStart) {
					break;
				}							
			} else {
				break;
			}		
		} // end while
		
		return result;
	}
%>


<%
	String selCompany = doString.checkString(request.getParameter("sel_company"),"");
	String selYear = doString.checkString(request.getParameter("sel_year"),"");
	String selTransDate = doString.checkString(request.getParameter("trans_date"),"");
	String selVat = doString.checkString(request.getParameter("sel_vat"),"N");
	int rptYear = 0; 
	int currMonth = 0;
	int currYear = 0;

	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	doString str = new doString();
	   
	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement(); 
		stmt1 = conn.createStatement(); 
        //----=============================================----//   
        		
        //---- get current month -----//
		Calendar now = Calendar.getInstance();
		currMonth  = now.get(Calendar.MONTH)+1; // set current month
		currYear  = now.get(Calendar.YEAR); // set current year
		if (currYear<2400) currYear += 543;
				
        //---- default year -----//
        if (selYear.trim().length()<4) {
			selYear  = Integer.toString(currYear);
        }              
        
        //--- convert sel_year from B.C. to report year in D.C. ---//
        try {
        	rptYear = Integer.parseInt(doString.checkString(selYear,"0"))-543;
        } catch(Exception ex) {
        	rptYear = 0;
        }
        
        
        //----- convert trans_date format -----//
        String selTransDateQuery = "";
        if (selTransDate.length()>=10) {
	       	int y = Integer.parseInt(selTransDate.substring(6,10));
	       	if (y>2400) y -= 543;
	       	selTransDateQuery = y+"-"+selTransDate.substring(3,5)+"-"+selTransDate.substring(0,2);
        }
                
        
        //----- find header data -----//
        Vector projList = new Vector();
        if (selCompany.length()>=2 && selYear.length()>=4 && selTransDateQuery.length()>=10) {
        	String tmp = "";
    	    sql.delete(0,sql.length());
    	    sql.append(" select unique pr.n_project,c.i_company,c.i_project,l.i_phase,p.d_end_project ")
    	       .append(" from lan:acscontr c ")   	       
    	       .append(" left join lan:acxslock l on l.i_company=c.i_company and l.i_project=c.i_project and l.i_lock=c.i_sort ")
    	       .append(" left join lan:acspubhd p on p.i_company=l.i_company and p.i_project=l.i_project and p.i_phase=l.i_phase ")
    	       .append(" left join lan:acxprojt pr on pr.i_company=p.i_company and pr.i_project=p.i_project ")
    	       .append(" where c.i_company='"+selCompany+"' ")
    	       .append(" and c.d_close_law <= '"+selTransDateQuery+"' ")
    	       .append(" and c.d_lor > '1999-03-31' and c.f_contr is null and c.d_close_law is not null ")
    	       .append(" and year(p.d_end_project)+1>='"+rptYear+"' ") 
			   .append(" order by c.i_company,c.i_project,l.i_phase ");
    		rs = stmt.executeQuery(sql.toString());
    		while (rs.next()) {	
    			if (doString.checkString(rs.getString("d_end_project"),"").trim().length()>=10) {
	    			tmp  = doString.checkString(rs.getString("i_company"),"").trim();
	    			tmp += ":"+doString.checkString(rs.getString("i_project"),"").trim();
	    			tmp += ":"+doString.checkString(rs.getString("n_project"),"");
	    			tmp += ":"+doString.checkString(rs.getString("i_phase"),"");
	    			tmp += ":"+doString.checkString(rs.getString("d_end_project"),"");

	    			projList.addElement(tmp);    	
    			}
    		} // end while
    		rs.close();	         	
        }

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

  function selDate(dateType) {
	 var vWinCal = window.open('calendar2.jsp?dateType='+dateType,'blank','width=350,height=300,left=200,top=100');
	 vWinCal.opener = self;
	 ggWinCal = vWinCal;
  }
	
  function validateInput() {
 	 if (document.forms[0].sel_company.value=="") {
   	 	alert(" กรุณาเลือกบริษัท !! ");
   	 	document.forms[0].sel_company.focus();
   	 	return false;
   	 }  
 	 
 	 if (document.forms[0].sel_year.value=="") {
   	 	alert(" กรุณาระบุปีที่ต้องการออกรายงาน !! ");
   	 	document.forms[0].sel_year.focus();
   	 	return false;
     } else if (isNaN(document.forms[0].sel_year.value)) {
   	 	alert(" ปีที่ระบุไม่ถูกต้อง !! ");
   	 	document.forms[0].sel_year.focus();
   	 	return false;    	 
     }   
 	 
 	 if (document.forms[0].trans_date.value=="") {
 	 	alert(" กรุณาระบุวันที่ !! ");
 	 	return false;
 	 } 
 	 
 	 return true;
  }

  function searchData() {
	 if (!validateInput()) {
		 return false; 
	 }
	 
	 document.forms[0].action="SERV_InfPubRemain.jsp";	 
	 document.getElementById("loadingText").style.visibility = "";
	 document.forms[0].submit();
  }  
  
  function printExcel() {
	 if (!validateInput()) {
		 return false; 
	 }
	 
	 alert("เนื่องจากมีการประมวลผลข้อมูลย้อนหลังจำนวนมาก ระบบอาจจะช้า\n\nกรณาคอยซักครู่จนกว่าหน้าจะจะขึ้น!!");	 	 
	 document.forms[0].action="/LHServ/SERV_InfPubReportXlsServlet";
	 document.forms[0].target="_blank";
	 document.forms[0].submit();
	 document.forms[0].target="";
  }    

//-->
</SCRIPT>

</HEAD>

<BODY onload="" leftMargin=0 topMargin=0 marginwidth="0" marginheight="0">

<div id="loadingText" style="visibility:hidden; position: absolute; left:400px; top:200px; background-color: white; layer-background-color: white; height: 10%; width: 30%;">
<table cellspacing="1" cellpadding="0" border="1" bordercolor="red" width="100%" height="100%">
<tr><td>
<table width=100% height="100%"><tr><td valign=middle align=middle><font color="#000080">Page loading ... Please wait...</font></td></tr></table>
</td></tr></table>
</div>


<FORM METHOD="POST" ACTION="">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center" class="BD">
    

      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
          รายงานสรุปค่าบริการสาธารณูปโภคคงเหลือแยกตามโครงการ</td>
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
    <td height="22" class="item ; dotline01">บริษัท :</td>
    <td height="22" class="dotline01">
	<SELECT name="sel_company" style="width:230px" class="box" size="1">
		<option value=''>------ กรุณาเลือก ------</option>
		<%			
		String iCom = "";
		String sel = "";
	
	    sql.delete(0,sql.length());
	    sql.append(" select * from lan:acxcompa ")
	       .append(" order by i_company ");
		rs = stmt.executeQuery(sql.toString());
		while (rs.next()) {
			iCom = doString.checkString(rs.getString("i_company"),"");
			sel = "";
	
			if (selCompany.equalsIgnoreCase(iCom)) {
				sel = " selected";
			}
	
			%><option value="<%=iCom%>"  <%=sel%>><%=iCom+" | "+doString.DisplayThai(doString.checkString(rs.getString("n_company"),""))%></option><%
	
		} // end while
		rs.close();	
	
	
		%>
	</SELECT>    
    </td>
  </tr>
  <tr>
    <td height="22" class="item ; dotline01" width="14%">ปีที่ออกรายงาน :</td>
    <td height="22" width="86%" class="dotline01">
    <input type="text" name="sel_year" class="box" style="width:40px" maxlength="4" value="<%=selYear %>"> 
    </td>
  </tr>
  <tr>
    <td height="22" class="item ; dotline01" width="14%">โอนนิติกรรมถึงวันที่ :</td>
    <td height="22" width="86%" class="dotline01">
     <input type="text" name="trans_date" id="transDate" class="box" style="width:70px" readonly value="<%=selTransDate %>">
     <img src="images/i_calendar.gif" border="0" align="absmiddle" style="cursor:hand" onclick="selDate('transDate');">  
    </td>
  </tr> 
  <tr>
    <td height="22" class="item ; dotline01" width="14%">&nbsp;แสดงรายงานแบบ : </td>
    <td height="22" width="86%" class="dotline01">
    <input type="radio" class="box" value="N" name="sel_vat" <%=selVat.equals("N") ? "checked" : "" %>> ไม่รวม Vat
     &nbsp; 
    <input type="radio" class="box" value="Y" name="sel_vat" <%=selVat.equals("Y") ? "checked" : "" %>> รวม Vat
     &nbsp; &nbsp; &nbsp; 
    <img src="images/bu_go.gif" align="absmiddle" style="cursor:hand" onclick="searchData();"> 
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
      <td width="5%" class="col_name">ลำดับ</td>
      <td width="30%" class="col_name">โครงการ</td>
      <td width="10%" class="col_name">วันที่สิ้นสุด<br>โครงการ</td>
      <td width="7%" class="col_name">เฟส</td>
      <td width="12%" class="col_name">จำนวนเงินรวม (บาท)<br>ณ เดือน <%=str.createID(currMonth,2)+"/"+currYear %></td>
      <td width="12%" class="col_name">จัดเก็บแล้ว (บาท)<br>ณ เดือน <%=str.createID(currMonth,2)+"/"+currYear %></td>
      <td width="12%" class="col_name">คงเหลือโดยประมาณ<br>ณ เดือน <%=str.createID(currMonth,2)+"/"+currYear %></td>
      <td width="12%" class="col_name">ยอดคงเหลือทั้งโครงการ<br>ณ เดือน <%=str.createID(currMonth,2)+"/"+currYear %></td>
   </tr>
      <%
      	double totalInfPub = 0.0;
      	double zUnitMonth = 0.0;
      	double zPublic = 0.0;
      	double zInfAmt = 0.0;
      	double zRemain = 0.0;
      	String dCalculate = "";
      	int zMonth = 0;
      	int cntLock = 0;

		StringTokenizer dat = null;
		String iCompany = "";
		String iProject = "";
		String nProject = "";
		String iPhase = "";
		String dEndProject = "";
		int cntProj = 0;
		int cntProjPhase = 0;
		int cntDispPhase = 0;
		String oldProj = "";
		String bgColor = "#F5F5F5";
		
		//--- total ---//
		double sumOldProjRemain = 0.0;
		double sumInfPub = 0.0;
		double sumInfKeep = 0.0;
		double sumInfRemain = 0.0;		

 		for (int p=0;p<projList.size();p++) {
 			dat = new StringTokenizer(doString.checkString((String) projList.elementAt(p),""),":");
 			if (dat.countTokens()<5) continue;
		
 			iCompany = doString.checkString(dat.nextToken(),"").trim();
 			iProject = doString.checkString(dat.nextToken(),"").trim();
 			nProject = doString.checkString(dat.nextToken(),"").trim();
 			iPhase = doString.checkString(dat.nextToken(),"").trim();
 			dEndProject = doString.checkString(dat.nextToken(),"").trim();
 			
 	      	//--- reset value ---//
 	      	totalInfPub = 0.0;
 	      	zUnitMonth = 0.0;
 	      	zInfAmt = 0.0;
 	      	zRemain = 0.0;
 	      	cntLock = 0; 	      	
 			
 			
 			///---- find z_public -----//
			sql.delete(0,sql.length());
			sql.append(" select d.d_due,d.z_amount,c.i_sort,c.i_lor,c.d_close_law,m.d_pubtran,nvl(m.z_public,0) as z_public,nvl(m.z_month,0) as z_month  ")
			   .append(" from lan:acscontr c ")
			   .append(" left join lan:acrduerv d on d.i_company=c.i_company and d.i_project=c.i_project and d.i_lor=c.i_lor and d.i_due='C0' ")			   
			   .append(" left join lan:acspbmmo m on m.i_company=c.i_company and m.i_project=c.i_project and m.i_lor=c.i_lor and m.f_status = 'OPN' ")
			   .append(" left join lan:acxslock l on l.i_company=c.i_company and l.i_project=c.i_project and l.i_lock=c.i_sort ")
			   .append(" left join lan:acspubhd p on p.i_company=l.i_company and p.i_project=l.i_project and p.i_phase=l.i_phase ")
			   .append(" where c.i_company='"+iCompany+"' and c.i_project='"+iProject+"' ")
			   .append(" and l.i_phase='"+iPhase+"' and c.d_close_law <= '"+selTransDateQuery+"' ")
			   .append(" and c.d_lor > '1999-03-31' and c.f_contr is null and c.d_close_law is not null ");		
			rs = stmt.executeQuery(sql.toString());
			while (rs.next()) {
				zPublic = rounding2Digit(rs.getDouble("z_public"));
				zMonth = rs.getInt("z_month");
			
				//------ 2022-01-14 , data in lan:acspbmm not found , calculate new value from 'C0' -------//
				if (zPublic<=0 || zMonth<=0) {
					zPublic = rs.getDouble("z_amount");
					zMonth = calculateMonthDiff(doString.checkString(rs.getString("d_due"),""),dEndProject);
				} 
				//-----------------------------------------------------------------------------------------//		
				
				if (selVat.equals("Y")) {
					totalInfPub += rounding2Digit(zPublic);
				} else {
					totalInfPub += rounding2Digit((rounding2Digit(zPublic)*100)/107);
				}	
				
				//--- use d_pubran from memo to calculate. if blank, use d_close_law instead ---//
				dCalculate = doString.checkString(rs.getString("d_pubtran"),"");
				if (dCalculate.length()<10) {
					dCalculate = doString.checkString(rs.getString("d_close_law"),"");
				}
				

				//============ 2022-01-14 , special case for d_close_law and d_end_project is same month ============//
				if (dCalculate.substring(0,7).equals(dEndProject.substring(0,7)) && zMonth>0 && zPublic>0) {
					Calendar calDEndProj = convertDate(dEndProject);
					calDEndProj.add(Calendar.MONTH,1);
					int y = calDEndProj.get(Calendar.YEAR);
					if (y>2400) y -= 543;
					int m = calDEndProj.get(Calendar.MONTH)+1;
					
					//zInfAmt += calculateZInfAmt(rounding2Digit(zPublic),dCalculate,selTransDateQuery,dEndProject,selVat);
					zInfAmt += rounding2Digit(calculateZInfAmt(rounding2Digit(zPublic),dCalculate,(currYear-543)+"-"+str.createID(currMonth,2)+"-01",dEndProject,selVat));
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
					
					//zInfAmt += calculateZInfAmt(zUnitMonth,dCalculate,selTransDateQuery,dEndProject,selVat);
					zInfAmt += rounding2Digit(calculateZInfAmt(zUnitMonth,dCalculate,(currYear-543)+"-"+str.createID(currMonth,2)+"-01",dEndProject,selVat));
				}
				//============================//
				
				cntLock++;
			} // end while
			rs.close();	
			
			
			//--- calculate remain & summary ---//
			zRemain = rounding2Digit(totalInfPub)-rounding2Digit(zInfAmt);
			sumInfRemain += rounding2Digit(zRemain);
			sumInfPub += rounding2Digit(totalInfPub);
			sumInfKeep += rounding2Digit(zInfAmt);
			
			//--- no remain data , skip ---//			
			if (cntLock<=0 || (zInfAmt==0.0 && totalInfPub==0.0)) continue; // condition 1
			if (zRemain<1 && zRemain>-1) continue; // condition 2			
										
			if (!oldProj.equals(iCompany+iProject)) {
				if (cntProj%2==0) {
					bgColor = "#FFFFFF";
				} else {
					bgColor = "#F5F5F5";
				}			
	 			cntProj++;
	 			cntProjPhase = 0;
	 			
	 			for (int c=0;c<projList.size();c++) {
	 				if (doString.checkString((String) projList.elementAt(c),"").indexOf(iCompany+":"+iProject)==0) {
	 					cntProjPhase++;
	 				}
	 			} // end for
	 			
	 			if (oldProj.trim().length()>=5) {
		 			%>
		 			<script>
		 				var shwOld = document.getElementById("totalRemain<%=oldProj %>");
		 				if (shwOld!=null) shwOld.innerHTML = "<%=displayAmount(sumOldProjRemain) %>";
		 				
		 				var rowProj1 = document.getElementById("row<%=oldProj %>_1");
		 				if (rowProj1!=null) rowProj1.rowSpan = "<%=cntDispPhase %>";
		 				var rowProj2 = document.getElementById("row<%=oldProj %>_2");
		 				if (rowProj2!=null) rowProj2.rowSpan = "<%=cntDispPhase %>";
		 				var rowProj3 = document.getElementById("row<%=oldProj %>_3");
		 				if (rowProj3!=null) rowProj3.rowSpan = "<%=cntDispPhase %>";
		 			</script>
		 			<%
	 			}
	 			
				%>
			      <tr height="21px" bgcolor="<%=bgColor %>">
			        <td align="center" class="dotline" valign="top" id="row<%=iCompany+iProject %>_1" rowspan="<%=cntProjPhase %>">&nbsp;<%=cntProj %></td>
			        <td align="left" class="dotline" valign="top" id="row<%=iCompany+iProject %>_2" rowspan="<%=cntProjPhase %>"><nobr>&nbsp;<%=iCompany+iProject+" | "+doString.DisplayThai(nProject) %></nobr></td>
			        <td align="center" class="dotline">&nbsp;<%=displayDate(dEndProject) %></td>
			        <td align="center" class="dotline">&nbsp;<%=iPhase %></td>
			        <td align="right" class="dotline"><%=displayAmount(totalInfPub) %></td>
			        <td align="right" class="dotline"><%=displayAmount(zInfAmt) %></td>
		      		<td align="right" class="dotline"><%=displayAmount(zRemain) %></td>	 
		      		<td align="right" class="dotline" valign="top" id="row<%=iCompany+iProject %>_3" rowspan="<%=cntProjPhase %>"><span id="totalRemain<%=iCompany+iProject %>">0.0</span></td>       
			      </tr>			
				<%	
				
				oldProj = iCompany+iProject;
				sumOldProjRemain = rounding2Digit(zRemain); // start new summary
				cntDispPhase = 1; // reset to 1
			} else {
				%>
			      <tr height="21px" bgcolor="<%=bgColor %>">
			        <td align="center" class="dotline">&nbsp;<%=displayDate(dEndProject) %></td>
			        <td align="center" class="dotline">&nbsp;<%=iPhase %></td>
			        <td align="right" class="dotline"><%=displayAmount(totalInfPub) %></td>
			        <td align="right" class="dotline"><%=displayAmount(zInfAmt) %></td>
		      		<td align="right" class="dotline"><%=displayAmount(rounding2Digit(totalInfPub-zInfAmt)) %></td>	 
			      </tr>			
				<%
				
				sumOldProjRemain += rounding2Digit(zRemain);
				cntDispPhase++;	
			}
			
	  } // end while
	  
	  
	  if (oldProj.trim().length()>=5 && sumOldProjRemain!=0.0) {
	  	  %>
		  <script>
		 	var shwOld = document.getElementById("totalRemain<%=oldProj %>");
			if (shwOld!=null) shwOld.innerHTML = "<%=displayAmount(sumOldProjRemain) %>";
			
			var rowProj1 = document.getElementById("row<%=oldProj %>_1");
			if (rowProj1!=null) rowProj1.rowSpan = "<%=cntDispPhase %>";
			var rowProj2 = document.getElementById("row<%=oldProj %>_2");
			if (rowProj2!=null) rowProj2.rowSpan = "<%=cntDispPhase %>";
			var rowProj3 = document.getElementById("row<%=oldProj %>_3");
			if (rowProj3!=null) rowProj3.rowSpan = "<%=cntDispPhase %>";			
		  </script>
		  <%
	  }	  
	        
		  
      if (cntProj<=0) {	
	      %>
	      <tr bgcolor="<%=bgColor %>">
	        <td align="center" class="solidline">&nbsp;</td>
	        <td align="center" class="solidline">&nbsp;</td>
	        <td align="center" class="solidline">&nbsp;</td>
	        <td align="center" class="solidline">&nbsp;</td>
	        <td align="center" class="solidline">&nbsp;</td>
	        <td align="center" class="solidline">&nbsp;</td>
	        <td align="center" class="solidline">&nbsp;</td>
	        <td align="center" class="solidline">&nbsp;</td>
	      </tr> 
		  <%
      }
	  
	  //----- print total line -----//
	  %>  
      <tr>
        <td align="center" class="solidline" colspan="4">&nbsp;<b style='color:red'>รวม</b></td>
        <td align="right" class="item ; solidline"><%=displayAmount(sumInfPub) %></td>
        <td align="right" class="item ; solidline"><%=displayAmount(sumInfKeep) %></td>
        <td align="right" class="item ; solidline"><%=displayAmount(sumInfRemain) %></td>
        <td align="right" class="item ; solidline">&nbsp;</td>
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


        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="90" class="act_tab2">
            <!-- 
			<img border="0" src="images/act_export2excel.gif" onclick="printExcel();"
				onmouseout=nereidFade(this,70,50,5)    
				onmouseover=nereidFade(this,100,50,5)     
				style="FILTER: alpha(opacity=70); cursor:hand" width="70" height="27">	
			-->
			</td>   
            <td class="act_tab3"></td>   
            <td class="act_tab4">&nbsp;
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
		System.out.println("ERROR SERV_InfPubRemain.jsp : " + e.getMessage());
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

