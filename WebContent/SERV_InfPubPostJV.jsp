<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>

<%@page import="com.lh.util.*" %>
<%@page import="java.text.DecimalFormat" %>
<%@page import="serv.common.User" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%!
	public static String DEBIT_ACC_NO = "21710";
	public static String CREDIT_ACC_NO = "41516";
	public static String thaiMonth[] = new String[] {"","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
	public static String shortMonth[] = new String[] {"","ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค."};	

	public String displayDate(Calendar date) throws Exception {
		String result = "";
		
		try {
			if (date!=null) {
				int year = date.get(Calendar.YEAR);
				if (year>2400) year -= 543;			
			    result = year+"-"+(date.get(Calendar.MONTH)+1)+"-"+date.get(Calendar.DATE);
			}
		} catch (Exception ex) {
			throw new Exception("CAL_DATE_ERR_"+date);
		}
		
		return result;
	}

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
				
				result.set(y,m-1,d,0,0,0);
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
	
%>


<%
	String selCompany = doString.checkString(request.getParameter("sel_company"),"");
	int selMonth = Integer.parseInt(doString.checkString(request.getParameter("sel_month"),"0"));
	int selYear = Integer.parseInt(doString.checkString(request.getParameter("sel_year"),"0"));
	String error = doString.checkString(request.getParameter("error"),"");
	
	String monthDisp = Integer.toString(selYear+543);
	if (monthDisp.length()>=2) {
		monthDisp = monthDisp.substring(monthDisp.length()-2);
	}
	monthDisp = shortMonth[selMonth]+monthDisp;
   	  

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
        		
        		
        //---- default year & month -----//
		Calendar now = Calendar.getInstance();
		int curYear = now.get(Calendar.YEAR);
		if (curYear>2400) curYear -= 543;
        
        if (selMonth<=0 || selYear<=0) {			
			selMonth = now.get(Calendar.MONTH)+1;
			selYear = curYear;
        }  

       
		//----- find last date of month for query -----//
       	String transDateQuery = "";
        if (selMonth>=0 || selYear>=0) {
			now = new  GregorianCalendar();
			now.set(selYear,selMonth-1,1,0,0,0);
			int year = now.get(Calendar.YEAR);	
			if (year>2400) year -= 543;	
			transDateQuery = year+"-"+str.createID(now.get(Calendar.MONTH)+1,2)+"-"+str.createID(now.getActualMaximum(now.DAY_OF_MONTH),2);	                    
		}

		
		//---- find account details -----//
		String debitAccDesc = "";
		String creditAccDesc = "";
				
		sql.delete(0,sql.length());
		sql.append(" select * from lan:stxchrtr ")
		   .append(" where acct_no in ('"+DEBIT_ACC_NO+"','"+CREDIT_ACC_NO+"')  ");
		rs = stmt.executeQuery(sql.toString());
		while (rs.next()) {
			if (doString.checkString(rs.getString("acct_no"),"").equals(DEBIT_ACC_NO)) {
				debitAccDesc = doString.checkString(rs.getString("acct_desc"),"");
			} else {
				creditAccDesc = doString.checkString(rs.getString("acct_desc"),"");
			}
		} // end while
		rs.close();		        
        
        
        //--- find previous for this month post ---//
        String iDocument = "";
        String dInsert = "";
        String iJvNo = "";
        
        if (selCompany.length()>0 && transDateQuery.length()>=10 && selMonth>0 && selYear>0) {
	        String queryDoc = selCompany+str.createID(selYear+543,4).substring(2,4)+str.createID(selMonth,2);
	        
			sql.delete(0,sql.length());
			sql.append(" select * from lan:acc_trantojv_hd ")
			   .append(" where i_type_gl='JV' and i_system='INF' and d_document is not null ")
			   .append(" and i_company='"+selCompany+"' and ( ")
			   .append("      i_document like '"+queryDoc+"%' or ") // check with i_document pattern
			   .append("     (month(d_document)='"+selMonth+"' and year(d_document)='"+selYear+"') ") // check with month/year of d_document
			   .append(" ) ");
			rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
				iDocument = doString.checkString(rs.getString("i_document"),"");
				dInsert = doString.checkString(rs.getString("d_insert"),"");
				iJvNo = doString.checkString(rs.getString("i_jvno"),"");
				
				//--- get d_insert ---//
		    	if (dInsert.length()>=10) {
		    		int y = Integer.parseInt(dInsert.substring(0,4));
		    		if (y<2400) y += 543;
		    		
		    		if (dInsert.length()>=16) {
		    			//--- display time ---//
		    			dInsert = dInsert.substring(8,10)+"/"+dInsert.substring(5,7)+"/"+y+" , "+dInsert.substring(11,16);
		    		} else {
		    			//--- date only ---//
		    			dInsert = dInsert.substring(8,10)+"/"+dInsert.substring(5,7)+"/"+y;    		
		    		}
		    	}				
			} 
			rs.close();	
		}        



        //----- find header data from lan:acc_trantojv_hd or source table if found i_document and i_jvno -----//
        Vector projList = new Vector();
        if (iDocument.length()>0 && iJvNo.length()>0) {
        	String tmp = "";
        	
        	//---- get data from lan:acc_trantojv_hd -----//
    	    sql.delete(0,sql.length());
    	    sql.append(" select distinct dt.i_company,dt.i_project,p.n_project ")
    	       .append(" from lan:acc_trantojv_dt dt ")
    	       .append(" left join lan:acxprojt p on p.i_company=dt.i_company and p.i_project=dt.i_project ")
    	       .append(" where i_type_gl='JV' and i_system='INF' ")
    	       .append(" and i_document='"+iDocument+"' ")
    	       .append(" order by dt.i_company,dt.i_project ");
    		rs = stmt.executeQuery(sql.toString());
    		while (rs.next()) {
    			tmp  = doString.checkString(rs.getString("i_company"),"");
    			tmp += ":"+doString.checkString(rs.getString("i_project"),"");
    			tmp += ":"+doString.checkString(rs.getString("n_project"),"");
    			tmp += ":99:9999-12-31"; // dummy , not used
    			
    			projList.addElement(tmp);   
    		} // end while
    		rs.close();	           	
        }         
        
        
       	//---- get data from source table for first post or edit data without i_jvno -----//
        else {
	        if (selCompany.length()>=2 && selMonth>0 && selYear>0 && transDateQuery.length()>=10) {
	        	String tmp = "";
	    	    
	    	    //---- 2022-01-14 , change query , use i_phase from lan:acxslock instead ----//
	    	    sql.delete(0,sql.length());
	    	    sql.append(" select unique pr.n_project,c.i_company,c.i_project,l.i_phase,p.d_end_project ")
	    	       .append(" from lan:acscontr c ")  // not used  lan:acspbmmo , use lan:acxslock instead    	       
	    	       .append(" left join lan:acxslock l on l.i_company=c.i_company and l.i_project=c.i_project and l.i_lock=c.i_sort ")
	    	       .append(" left join lan:acspubhd p on p.i_company=l.i_company and p.i_project=l.i_project and p.i_phase=l.i_phase ")
	    	       .append(" left join lan:acxprojt pr on pr.i_company=p.i_company and pr.i_project=p.i_project ")
	    	       .append(" where c.i_company='"+selCompany+"' ")
	    	       .append(" and c.d_close_law <= '"+transDateQuery+"' ")
	    	       .append(" and c.d_lor > '1999-03-31' and c.f_contr is null and c.d_close_law is not null ")
	    	       .append(" and year(p.d_end_project)+1>='"+selYear+"' ")
				   .append(" order by c.i_company,c.i_project,l.i_phase ");
	    		rs = stmt.executeQuery(sql.toString());
	    		while (rs.next()) {
	    			if (doString.checkString(rs.getString("d_end_project"),"").trim().length()>=10) {
		    			tmp  = doString.checkString(rs.getString("i_company"),"");
		    			tmp += ":"+doString.checkString(rs.getString("i_project"),"");
		    			tmp += ":"+doString.checkString(rs.getString("n_project"),"");
		    			tmp += ":"+doString.checkString(rs.getString("i_phase"),"");
		    			tmp += ":"+doString.checkString(rs.getString("d_end_project"),"");
	
		    			projList.addElement(tmp);    	
	    			}
	    		} // end while
	    		rs.close();	         	
	        }        	
        }
        

%>

<HTML>
<HEAD>
<TITLE>Post JV</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<base target="_self">

<SCRIPT LANGUAGE="JavaScript">
<!-- 

  function selDate(dateType) {
	 var vWinCal = window.open('calendar2.jsp?dateType='+dateType,'blank','width=300,height=250,left=200,top=100');
	 vWinCal.opener = self;
	 ggWinCal = vWinCal;
  }
	
  function validateInput() {
 	 if (document.forms[0].sel_company.value=="") {
   	 	alert(" กรุณาเลือกบริษัท !! ");
   	 	document.forms[0].sel_company.focus();
   	 	return false;
   	 }  
   	 
 	 if (document.forms[0].sel_month.value=="" || document.forms[0].sel_year.value=="") {
   	 	alert(" กรุณาระบุเดือน/ปี ให้ถูกต้อง !! ");
   	 	return false;
     }   
 	 
 	 return true;
  }

  function searchData() {
	 if (!validateInput()) {
		 return false; 
	 }
	 
	 document.forms[0].action="SERV_InfPubPostJV.jsp";	 
	 document.getElementById("loadingText").style.visibility = "";
	 document.forms[0].submit();
  }  
  
  function saveData() {
	 if (!validateInput()) {
		 return false; 
	 }
	 
	 var totProj = document.getElementById("totalProj").value-0;
	 if (isNaN(totProj) || totProj<=0) {
	 	alert("ไม่พบข้อมูลค่าบริการฯ ที่จะทำการ Post JV !!");
	 	return false;
	 }
	 
	 document.forms[0].action="/LHServ/SERV_InfPubPostJVServlet";
	 document.forms[0].submit();
  }   
  
  function adjustAmt(idx,val) {
  	var debit = document.getElementById("debit"+idx);
  	var credit = document.getElementById("credit"+idx);
  	
  	if (val==null || val.length<=0) {
  		val = 0.0;
  	}
  	
  	if (debit!=null) {
  		debit.value = addComma(val,2);
  	}
  	if (credit!=null) {
  		credit.value = addComma(val,2);
  	}
  	
  	//---- summary new value ----//
  	var totalDebit = document.getElementById("totalDebit");
  	var totalCredit = document.getElementById("totalCredit");
  	var debitDisp = document.getElementById("totalDebitDisp");
  	var creditDisp = document.getElementById("totalCreditDisp");
  	var totProj = document.getElementById("totalProj").value-0;
  	var sumDebit = 0.0;
  	var sumCredit = 0.0;
  	
  	for (var i=1;i<=totProj;i++) {
	  	debit = document.getElementById("debit"+i);
	  	credit = document.getElementById("credit"+i);
	  	
	  	if (debit!=null) {
	  		sumDebit += delComma(debit.value)-0;
	  	}
	  	if (credit!=null) {
	  		sumCredit += delComma(credit.value)-0;
	  	}	  	
  	} // end for  
  	
  	if (totalDebit!=null) {
  		totalDebit.value = addComma(sumDebit,2);
  	}
  	if (debitDisp!=null) {
  		debitDisp.innerHTML = addComma(sumDebit,2);
  	}
  	if (totalCredit!=null) {
  		totalCredit.value = addComma(sumCredit,2);
  	}   	
  	if (creditDisp!=null) {
  		creditDisp.innerHTML = addComma(sumCredit,2);
  	} 	
  	
  }
  
	function addComma(number,prec) {
		 var val = delComma(number);
		 var decimal = "";
		 var minus = "";
	
		 if (val.indexOf(".")>=0) {
			decimal = val.substring(val.indexOf(".")+1);
			val = val.substring(0,val.indexOf("."));
		 }
		 if (val.indexOf("-")==0) {
			minus = val.substring(0,1);
			val = val.substring(1);
		 }
	
		var result = "";	
		 while (val.length>3) {
			 result = ","+val.substring(val.length-3) + result;
			 val = val.substring(0,val.length-3);
		 } // end while
	
	
		 if (decimal.length>(prec-0)) {
		 	 decimal = decimal.substring(0,prec-0);
		 } else {
			 while (decimal.length<(prec-0)) {
				 decimal += "0"; 
			 }
		 }
		 if (decimal.length>0) decimal = "."+decimal;
	
		 result = minus + val + result + decimal;
	
		 return result;
	}
	
	function delComma(str) {
		var result = "";
		str = str+"";
		
		if (str!=null) {
			result = str.replace(/,/g,"");
		} else {
			result = str;
		}
		
		return result;
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

<input type="hidden" name="i_document" value="<%=iDocument %>">
<input type="hidden" name="i_employ" value="<%=user.getEmpId() %>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center" class="BD">
    

      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
          รายการค่าบริการสาธารณูปโภคสำหรับทำ JV</td>
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
    <td height="22" class="item ; dotline01" width="14%">เดือนที่ Post :</td>
    <td height="22" width="86%" class="dotline01">
	<SELECT name="sel_month" style="width:110px" class="box" size="1">
		<option value=''>---- กรุณาเลือก ----</option>
		<%			
		for (int i=1;i<=12;i++)	 {
			sel = "";
			if (i==selMonth) {
				sel = "selected";
			}
		
			%><option value="<%=i %>"  <%=sel%>><%=thaiMonth[i] %></option><%
		} // end for
		%>
	</SELECT>   
	&nbsp; &nbsp;
	<SELECT name="sel_year" style="width:80px" class="box" size="1">
		<option value=''>------ กรุณาเลือก ------</option>
		<%			
		for (int i=curYear-2;i<=curYear+2;i++)	 {
			sel = "";
			if (i==selYear) {
				sel = "selected";
			}
		
			%><option value="<%=i %>"  <%=sel%>><%=(i+543) %></option><%
		} // end for
		%>
	</SELECT>  
     &nbsp; &nbsp; &nbsp; 
    <img src="images/bu_go.gif" align="absmiddle" style="cursor:hand" onclick="searchData();"> 		
    </td>
  </tr>  
  <%
  	if (dInsert.length()>0) {
  		%>
		  <tr>
		    <td height="22" class="item ; dotline01" width="14%">เลขที่เอกสาร :</td>
		    <td height="22" width="86%" class="dotline01">&nbsp;<%=iDocument %></td>
		  </tr>   		
  		<%
  	}   
  	if (dInsert.length()>0) {
  		%>
		  <tr>
		    <td height="22" class="item ; dotline01" width="14%">วันที่บันทึกข้อมูลล่าสุด :</td>
		    <td height="22" width="86%" class="dotline01">&nbsp;<%=dInsert %></td>
		  </tr>   		
		  <tr>
		    <td height="22" class="item ; dotline01" width="14%">JV เลขที่ :</td>
		    <td height="22" width="86%" class="dotline01">&nbsp;<%=doString.checkString(iJvNo,"<span style='color:red'>[ยังไม่ออก JV]</span>") %></td>
		  </tr>   
		<%
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

      <%
		StringTokenizer dat = null;		
		String iCompany = "";
		String iProject = "";
		String nProject = "";
		String iPhase = "";
		String dEndProject = "";
		String dCalculate = "";
		
		int zMonth = 0;
		int yCal = 0;
		int mCal = 0;
		int yEP = 0;
		int mEP = 0;		
		double zUnitMonth = 0.0;
		double zPublic = 0.0;
		double zAmtMonth = 0.0;
		
		boolean closeProj = false;
		int maxPhaseMonth = 0;
		int maxPhaseYear = 0; 	
		int chkClose = 0;
		
		Hashtable jvData = new Hashtable(); // keep all amount
		String remarkFinal = "";
		
		//---- set jv month for check data ----//
		Calendar calSelMonthJV = Calendar.getInstance();
		calSelMonthJV.set(selYear,selMonth-1,1,0,0,0);
		Calendar calDEndProj = null;

 		for (int p=0;p<projList.size();p++) {
 		
 			dat = new StringTokenizer(doString.checkString((String) projList.elementAt(p),""),":");
 			if (dat.countTokens()<5) continue;
		
 			iCompany = doString.checkString(dat.nextToken(),"").trim();
 			iProject = doString.checkString(dat.nextToken(),"").trim();
 			nProject = doString.checkString(dat.nextToken(),"").trim();
 			iPhase = doString.checkString(dat.nextToken(),"").trim();
 			dEndProject = doString.checkString(dat.nextToken(),"").trim();

			zMonth = 0;
			zUnitMonth = 0.0;
			zPublic = 0.0;
			zAmtMonth = 0.0;
			yCal = 0;
			mCal = 0;
			yEP = 0;
			mEP = 0;
 			calDEndProj = convertDate(dEndProject);
 			if (calDEndProj==null) {
 				continue; // no d_end_project , skip data
 			} else {
				yEP = calDEndProj.get(Calendar.YEAR);
				if (yEP>2400) yEP -= 543;
				mEP = calDEndProj.get(Calendar.MONTH)+1;
 			}
			
			//---- check project is close or not and last date of maximum phase -----//
			closeProj = false;
			maxPhaseMonth = 0;
			maxPhaseYear = 0; 
			chkClose = -1;
			
			sql.delete(0,sql.length());
			sql.append(" select count(*) as cnt from lan:acxslock l ")
			   .append(" left join lan:acsregis r on r.i_company=l.i_company and r.i_project=l.i_project and r.i_lor=l.i_lor ")
			   .append(" where l.i_company='"+iCompany+"' and l.i_project='"+iProject+"' ")
			   .append(" and r.d_close_law is null ");		
			rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
				chkClose = rs.getInt("cnt");
			}
			rs.close();			
				
			//--- if this project transfer all lock , find max phase and d_end_project ---//				
			if (chkClose==0) {
				closeProj = true;
				
				sql.delete(0,sql.length());
				sql.append(" select distinct l.i_phase , month(p.d_end_project) as m_phase , year(p.d_end_project) as y_phase ")
				   .append(" from lan:acxslock l,lan:acspubhd p ")
				   .append(" where l.i_company='"+iCompany+"' and l.i_project='"+iProject+"' ")
				   .append(" and p.i_company=l.i_company and p.i_project=l.i_project and p.i_phase=l.i_phase ")
				   .append(" order by l.i_phase desc ");
				rs = stmt.executeQuery(sql.toString());
				if (rs.next()) {
					maxPhaseMonth = rs.getInt("m_phase");
					maxPhaseYear = rs.getInt("y_phase");
				}
				rs.close();					
			} else {
			    //-- chkClose > 0 or -1 --//
				closeProj = false;
			}
			
			//---- if "max phase's d_end_project" from close project is before JV , skip ----//
			if (closeProj) {
				if (maxPhaseYear<selYear || (maxPhaseYear==selYear && maxPhaseMonth<selMonth)) {
					continue;
				}
			}
			
			//======================= Case 0 : data already had i_jvno , use data from lan:acc_trantojv_dt instead ================================//
			if (iDocument.length()>0 && iJvNo.length()>0) {
				double zAmt = 0.0;
			
				sql.delete(0,sql.length());
				sql.append(" select z_amount from lan:acc_trantojv_dt ")
				   .append(" where i_type_gl='JV' and i_system='INF' ")
				   .append(" and i_acctno='"+DEBIT_ACC_NO+"' and i_document='"+iDocument+"' ")
				   .append(" and i_company='"+iCompany+"' and i_project='"+iProject+"' ");
				rs = stmt.executeQuery(sql.toString());
				if (rs.next()) {
					zAmt = rs.getDouble("z_amount");
				}
				rs.close();	
				
				//--- set diff to data list ---//
				Double tmp = (Double) jvData.get(iCompany+iProject);
				if (tmp==null) tmp = new Double(0.0);
				jvData.put(iCompany+iProject,new Double(tmp.doubleValue()+zAmt));								
			} else 
			//=====================================================================================================================================//			
			
				
			//===================== Case 1 : "close project" and "month of JV" is same month with "max phase's d_end_project" =====================//
			if (closeProj && maxPhaseYear==selYear && maxPhaseMonth==selMonth) {
				double balanceAmt = 0.0;
												
				if (remarkFinal.indexOf(iCompany+iProject+"#")<0) {
					remarkFinal += iCompany+iProject+"#";

					//--- find remain balance from previous month ---//
					int chkYear = selYear;
					int chkMonth = selMonth-1; // previous month
					if (chkMonth<=0) {
						chkYear--;
						chkMonth = 12;
					}
					if (chkYear<2400) chkYear += 543; 
					
					sql.delete(0,sql.length());
					sql.append(" select balance from lan:stxchrtd ")
					   .append(" where comp_id='"+iCompany+"' and department='"+iProject+"' ")
					   .append(" and period_month='"+str.createID(chkMonth,2)+"' and period_year='"+chkYear+"' ") 
					   .append(" and acct_no='"+DEBIT_ACC_NO+"' ");
					rs = stmt.executeQuery(sql.toString());
					if (rs.next()) {
						balanceAmt = rs.getDouble("balance");
					}
					rs.close();							
				}
				
				//--- set diff to data list ---//
				Double tmp = (Double) jvData.get(iCompany+iProject);
				if (tmp==null) tmp = new Double(0.0);
				jvData.put(iCompany+iProject,new Double(tmp.doubleValue()+balanceAmt));
			} 
			//=====================================================================================================================================//			


			//================ Case 2 : "open project" or "close project" and "month of JV" less than "max phase's d_end_project"   ===============//
			else {
			
				//---- use same query with report ----//
				sql.delete(0,sql.length());
				sql.append(" select d.d_due,d.z_amount,c.i_sort,c.i_lor,c.d_close_law,m.d_pubtran,nvl(m.z_public,0) as z_public,nvl(m.z_month,0) as z_month  ")
				   .append(" from lan:acscontr c ")
				   .append(" left join lan:acrduerv d on d.i_company=c.i_company and d.i_project=c.i_project and d.i_lor=c.i_lor and d.i_due='C0' ")			   
				   .append(" left join lan:acspbmmo m on m.i_company=c.i_company and m.i_project=c.i_project and m.i_lor=c.i_lor and m.f_status = 'OPN' ")
				   .append(" left join lan:acxslock l on l.i_company=c.i_company and l.i_project=c.i_project and l.i_lock=c.i_sort ")
				   .append(" left join lan:acspubhd p on p.i_company=l.i_company and p.i_project=l.i_project and p.i_phase=l.i_phase ")
				   .append(" where c.i_company='"+iCompany+"' and c.i_project='"+iProject+"' ")
				   .append(" and l.i_phase='"+iPhase+"' and c.d_close_law <= '"+transDateQuery+"' ")
				   .append(" and c.d_lor > '1999-03-31' and c.f_contr is null and c.d_close_law is not null ");
				rs = stmt.executeQuery(sql.toString());
				while (rs.next()) {
					zPublic = rs.getDouble("z_public");
					zMonth = rs.getInt("z_month");
				
					//------ 2022-01-14 , data in lan:acspbmm not found , calculate new value from 'C0' -------//
					if (zPublic<=0 || zMonth<=0) {
						zPublic = rs.getDouble("z_amount");
						zMonth = calculateMonthDiff(doString.checkString(rs.getString("d_due"),""),dEndProject);
					} 
					//-----------------------------------------------------------------------------------------//		

					
					//--- use d_pubran from memo to calculate. if blank, use d_close_law instead ---//
					dCalculate = doString.checkString(rs.getString("d_pubtran"),"");
					if (dCalculate.length()<10) {
						dCalculate = doString.checkString(rs.getString("d_close_law"),"");
					}
	
					//---- calculate z_unit_month ----//
					if (zMonth>0) {
						//zUnitMonth = rounding2Digit((rounding2Digit(zPublic/zMonth)/107)*100);
						zUnitMonth = rounding2Digit(((rounding2Digit(zPublic/zMonth)*100)/107));
					} else {
						zUnitMonth = 0.0;
					}
										
					//---- set d_calculate + z_month for check data ----//
					Calendar calDCalculate = convertDate(dCalculate);
					
					for (int i=0;i<zMonth;i++) {
						calDCalculate.add(Calendar.MONTH,1);
						yCal = calDCalculate.get(Calendar.YEAR);
						if (yCal>2400) yCal -= 543;
						mCal = calDCalculate.get(Calendar.MONTH)+1;

						if ((yEP>yCal) || (yEP==yCal && mEP>=mCal)) { // check d_calculate <= d_end_project							
							if (yCal==selYear && mCal==selMonth) { // check d_calculate = selected month
								zAmtMonth += zUnitMonth;
								break;
							}
						}
					} // end for
					
				} // end while
				rs.close();	
				
				
				//--- set diff to data list ---//
				Double tmp = (Double) jvData.get(iCompany+iProject);
				if (tmp==null) tmp = new Double(0.0);
				jvData.put(iCompany+iProject,new Double(tmp.doubleValue()+zAmtMonth));				
			
			} // end if check month
			//=====================================================================================================================================//			
			
			
	  } // end for project list			
		
	 %>
	 <table border="0" width="100%" cellspacing="0" cellpadding="0">
	    <tr height="21px">
	      <td width="20%" class="col_name">โครงการ</td>
	      <td width="10%" class="col_name">รหัสบัญชี</td>
	      <td width="20%" class="col_name">ชื่อบัญชี</td>
	      <td width="30%" class="col_name">รายการ</td>
	      <td width="10%" class="col_name">เดบิต</td>
	      <td width="10%" class="col_name">เครดิต</td>
	   </tr>	     
	  <%	
		
		
	  int cntProj = 0;
	  double sumJVAmt = 0.0;
	  String dispProj = "";
	  String bgColor = "";
	  
 	  for (int p=0;p<projList.size();p++) {
 		
 			dat = new StringTokenizer(doString.checkString((String) projList.elementAt(p),""),":");
 			if (dat.countTokens()<5) continue;
		
 			iCompany = doString.checkString(dat.nextToken(),"").trim();
 			iProject = doString.checkString(dat.nextToken(),"").trim();
 			nProject = doString.checkString(dat.nextToken(),"").trim();
 			
 			if (dispProj.indexOf(iCompany+iProject+"#")<0) {
 				dispProj += iCompany+iProject+"#";
 			} else {
 				//-- already display project, skip --//
 				continue;
 			}
 			
			Double tmp = (Double) jvData.get(iCompany+iProject);
			if (tmp==null) tmp = new Double(0.0); 			
			zAmtMonth = tmp.doubleValue();
 			 	  
			//---- if all data is 0 , no display ----//
			if (zAmtMonth>0) {
	      		cntProj++; 
	      		sumJVAmt += rounding2Digit(zAmtMonth);
	      		
	      		bgColor = "#FFFFFF";
	      		if (remarkFinal.indexOf(iCompany+iProject+"#")>=0) {
		      		bgColor = "#FFEAEA";
	      		}

				%>					
				  <input type="hidden" name="proj_<%=cntProj %>" value="<%=iCompany+":"+iProject %>">
				  
			      <tr height="24px" bgcolor="<%=bgColor %>">
			        <td align="left" class="dotline"><nobr>&nbsp;<%=iCompany+iProject+" | "+doString.DisplayThai(nProject) %></nobr></td>
			        <td align="center" class="dotline">&nbsp;<%=DEBIT_ACC_NO %></td>			        
			        <td align="left" class="dotline">&nbsp;<%=doString.DisplayThai(debitAccDesc) %></td>			        
			        <td align="left" class="dotline">&nbsp;บันทึกรายได้ค่าบริการฯ จาก <%=DEBIT_ACC_NO %> - <%=monthDisp %></td>
			      	<td align="right" class="dotline">&nbsp;
			      	<%
			      		if (remarkFinal.indexOf(iCompany+iProject+"#")>=0) {
			      			if (iJvNo.trim().length()<=0) {
			      				//--- edit mode --//
				      			%>
				      			<b style='color:red'>*</b> 
				      			<input type="text" class="boxR" name="debit_<%=cntProj %>" id="debit<%=cntProj %>" value="<%=displayAmount(zAmtMonth) %>"
				      			 onfocus="this.value=delComma(this.value);this.select();" onblur="adjustAmt('<%=cntProj %>',this.value);">
				      			<%		
			      			} else {
			      				//--- display mode ---//
				      			%>
				      			<b style='color:red'>*</b> 
				      			<input type="hidden" name="debit_<%=cntProj %>" id="debit<%=cntProj %>" value="<%=displayAmount(zAmtMonth) %>">
				      			<%=displayAmount(zAmtMonth) %>
				      			<%			      			
			      			}	      		
			      		} else {
			      			//--- display mode ---//
			      			%>
			      			<input type="hidden" name="debit_<%=cntProj %>" id="debit<%=cntProj %>" value="<%=displayAmount(zAmtMonth) %>">
			      			<%=displayAmount(zAmtMonth) %>
			      			<%
			      		}
			      	%>
			      	</td>
			      	<td align="right" class="dotline">&nbsp;</td>
			      </tr>	
			      <tr height="24px" bgcolor="<%=bgColor %>">
			        <td align="left" class="dotline"><nobr>&nbsp;<%=iCompany+iProject+" | "+doString.DisplayThai(nProject) %></nobr></td>
			        <td align="center" class="dotline">&nbsp;<%=CREDIT_ACC_NO %></td>			        
			        <td align="left" class="dotline">&nbsp;<%=doString.DisplayThai(creditAccDesc) %></td>			        
			        <td align="left" class="dotline">&nbsp;บันทึกรายได้ค่าบริการฯ จาก <%=DEBIT_ACC_NO %> - <%=monthDisp %></td>
			      	<td align="right" class="dotline">&nbsp;</td>
			      	<td align="right" class="dotline">&nbsp;
			      	<%
			      		if (remarkFinal.indexOf(iCompany+iProject+"#")>=0) {
							if (iJvNo.trim().length()<=0) {			      		
				      			%>
				      			<b style='color:red'>*</b> 
				      			<input type="text" class="boxR" name="credit_<%=cntProj %>" id="credit<%=cntProj %>" value="<%=displayAmount(zAmtMonth) %>"
				      			 onfocus="this.value=delComma(this.value);this.select();" onblur="adjustAmt('<%=cntProj %>',this.value);">
				      			<%			      		
			      			} else {
				      			%>
				      			<b style='color:red'>*</b> 
				      			<input type="hidden" name="credit_<%=cntProj %>" id="credit<%=cntProj %>" value="<%=displayAmount(zAmtMonth) %>">
				      			<%=displayAmount(zAmtMonth) %>
				      			<%
			      			}
			      		} else {
			      			%>
			      			<input type="hidden" name="credit_<%=cntProj %>" id="credit<%=cntProj %>" value="<%=displayAmount(zAmtMonth) %>">
			      			<%=displayAmount(zAmtMonth) %>
			      			<%
			      		}
			      	%>		      	
			      	</td>
			      </tr>				      		
				<%
			}
	  } // end for
	  
		  
      if (cntProj<=0) {	
	      %>
	      <tr>
	        <td align="left" class="dotline">&nbsp;</td>
	        <td align="center" class="dotline">&nbsp;</td>
	        <td align="left" class="dotline">&nbsp;</td>
	        <td align="left" class="dotline">&nbsp;</td>
	        <td align="right" class="dotline">&nbsp;</td>
	        <td align="right" class="dotline">&nbsp;</td>
	      </tr> 
		  <%
      }
	  
	  //----- print total line -----//
	  %>  
	  <input type="hidden" name="total_proj" id="totalProj" value="<%=cntProj %>">
	  <input type="hidden" name="total_debit" id="totalDebit" value="<%=displayAmount(sumJVAmt) %>">
	  <input type="hidden" name="total_credit" id="totalCredit" value="<%=displayAmount(sumJVAmt) %>">
	  
      <tr>
        <td align="center" class="solidline" colspan="4">&nbsp;<b style='color:red'>รวม</b></td>
        <td align="right" class="item ; solidline">&nbsp;<b style="color:red"><span id="totalDebitDisp"><%=displayAmount(sumJVAmt) %></span></b></td>
        <td align="right" class="item ; solidline">&nbsp;<b style="color:red"><span id="totalCreditDisp"><%=displayAmount(sumJVAmt) %></span></b></td>
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
    	if (remarkFinal.length()>0) {
    		%>
    		<br style="font-size:6pt">
			<table border="0" width="100%" cellspacing="0" cellpadding="0">
			  <tr>
			    <td align="left" valign="bottom"><span style="font-size:12px; color:red">* ค่าบริการสาธารณะเฉลี่ยเดือนสุดท้ายของโครงการ (โครงการปิด)</span></td>
			  </tr>
			</table>    		
    		<%
    	}
    %>

<br style="font-size:10pt">


        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="90" class="act_tab2">&nbsp;
            <%
            	if (selCompany.length()>0 && transDateQuery.length()>=10 && selMonth>0 && selYear>0 && iJvNo.trim().length()<=0) {	
            		%>
					<img border="0" src="images/act_save.gif" onclick="saveData();"
						onmouseout=nereidFade(this,70,50,5)    
						onmouseover=nereidFade(this,100,50,5)     
						style="FILTER: alpha(opacity=70); cursor:hand" width="70" height="27">	            		
            		<%
            	}
            %>
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

<script>
   <%
   	if (error.length()>0) {
   		error = doString.checkString(request.getParameter("other_msg"),"");
   		if (error.indexOf("ERR_EXIST_JV_")==0) {
   			iJvNo = error.substring(0,13);
   			%>alert("การบันทึกมีปัญหา!!\n\nมีการออก JV แล้วเลขที่ <%=iJvNo %>!!");<%
   		} else {
   			%>alert("การบันทึกมีปัญหา!!\n\n<%=error %>!!");<%
   		}
   	} else {   
	   	if (remarkFinal.length()>0) {  
	   		%>alert("มีโครงการที่มียอดค่าบริการสาธารณะเป็นเดือนสุดท้าย (โครงการปิด) , กรุณาตรวจสอบยอดเงินให้ถูกต้องก่อนทำการ Post JV");<%
	   	}
   	}
   %>
</script>  		

</HTML>
<%
		stmt.close();
		stmt1.close();
		conn.close();
		stmt = null;
		stmt1 = null;
		conn = null;		

	} catch (Exception e) {
		System.out.println("ERROR SERV_InfPubPostJV.jsp : " + e.getMessage());
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

