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

    public Double[] newDoubleArray(int size) {
        Double result[] = new Double[size];
	for (int i=0;i<size;i++) {
	       result[i] = new Double(0.0);
	}

	return result;
    }

%>


<%
   doString str = new doString();

   //----============ Declare Variables for input data ===========----//
   String search = doString.checkString(request.getParameter("search"),"");
   String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase();
   session.setAttribute("sess_sel_proj",selProj);
   String itmType = doString.checkString(request.getParameter("itmtype"),"01");
   session.setAttribute("sess_itmtype",itmType); 
   String caption = "";
   if (itmType.equals("01")) {
	   caption = "รายละเอียดการส่งงานของผู้รับเหมาสาธารณูฯ(ส่วนกลาง) ตามวันที่จ่าย (สรุปตามใบแจ้งซ่อม)";
   } else {
	   caption = "รายละเอียดการส่งงานของผู้รับเหมาสาธารณะ ตามวันที่จ่าย (สรุปตามใบแจ้งซ่อม)";
   }
   String flag = doString.checkString(request.getParameter("flag"),"");     //   by...pay 8/05/2007
   String iVendor = doString.checkString(request.getParameter("i_vendor"),"");
   String cutVendorId = doString.checkString(request.getParameter("cut_vendor"),"");
   String orderBy = doString.checkString(request.getParameter("order_by"),"b.i_docno");

   String condition = "";
   String condition2 = "";
   String cutCompany = "";
   String tsv = "";
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

		condition += " AND b.i_itmtype = '"+itmType+"' ";
        if (iVendor.trim().length()>0) {
           condition += " AND b.i_vendor = '"+iVendor+"' ";
        }
        if (selProj.trim().length()>=2) {
           cutCompany = selProj.substring(0,2).toUpperCase();
        }
		if (startDate.length()>0 && endDate.length()>0) {
		   condition += " AND b.d_payment BETWEEN '"+startDate+"' AND '"+endDate+"' ";
		}
		if (selProj.length()>=6) {
           condition += " AND a.i_company = '"+selProj.substring(0,2)+"' AND a.i_project = '"+selProj.substring(3,6)+"' ";
		} else {
           condition += " AND a.i_company = '' AND a.i_project = '' ";
		}
		
		if (startDate.length()<=0 && endDate.length()<=0 && !search.equalsIgnoreCase("Y"))  {
			Calendar start = Calendar.getInstance();
			int syear = start.get(Calendar.YEAR);
			if (syear>2400) syear -= 543;
			start.set(syear,start.get(Calendar.MONTH)+1,1);
	
			Calendar end = Calendar.getInstance();
			int eyear = end.get(Calendar.YEAR);
			if (eyear>2400) eyear -= 543;
			end.set(eyear,end.get(Calendar.MONTH)+2,1);
			end.add(Calendar.DATE,-1);
	
			startDate = start.get(Calendar.YEAR)+"-"+str.createID(start.get(Calendar.MONTH)+1,2)+"-"+str.createID(start.get(Calendar.DATE),2);
			endDate = end.get(Calendar.YEAR)+"-"+str.createID(end.get(Calendar.MONTH)+1,2)+"-"+str.createID(end.get(Calendar.DATE),2);
		}
		//---=========================================================================----//



        //----========================== Find Company Name  ==========================-----//
        String companyName = "";
		if (selProj.length()>2) {
			sql.delete(0,sql.length());
			sql.append(" select n_company from lan:acxcompa where i_company='").append(selProj.substring(0,2)).append("' ");
			rs = stmt.executeQuery(sql.toString());
			while (rs.next()) {
			   companyName = doString.checkString(doString.DisplayThai(rs.getString("n_company")),"");
			}
			rs.close();
		}
	//---========================================================================----//




    //----========================== Find All CUt Type  ==========================-----//
    String allCutType = "";
	//---========================================================================----//





        //----================= Get Vendor Percent cut from SERV_XSTD  ==================-----//
        Vector vendorCut = new Vector();
        sql.delete(0,sql.length());
        sql.append(" select * from lan:serv_xstd where i_type='09' ");
        rs = stmt.executeQuery(sql.toString());
        while (rs.next()) {
			double percent = rs.getDouble("p_amount");
			vendorCut.addElement(new Double(percent));
        }
        rs.close();
	//---========================================================================----//




        //----==================== Find all Vendor in this result ============================-----//
        Vector vendorList = new Vector();
        sql.delete(0,sql.length());
        
        sql.append("SELECT DISTINCT b.i_vendor FROM lan:serv_infpayment b, lan:serv_infdochd a ")
	      .append(" WHERE b.f_itmstatus = 'CLS' ");
		if (cutVendorId.length()>0) sql.append(" AND b.i_ven_cut = '").append(cutVendorId).append("' ");
		sql.append(condition);
		sql.append(" AND a.f_status IN ('OPN','CLS') AND b.i_docno = a.i_docno");
		
        rs = stmt.executeQuery(sql.toString());
        while (rs.next()) {
            vendorList.addElement(doString.checkString(rs.getString("i_vendor"),""));
        }
        rs.close();
		rs=null;
		if (vendorList.size()<=0) vendorList.addElement("");
	//---=========================================================================----//
%>

<HTML>
<HEAD>
<TITLE>Manager - ผู้จัดการโครงการ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--

  function orderDoc(orderby) {
     if (!validDate()) {
        return false;
     }

     document.forms[0].order_by.value=orderby;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFReport8.jsp?search=y";
     document.forms[0].submit();
  }

  function searchDocHD() {
     if (!validDate()) {
        return false;
     }

     //document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFReport8.jsp?search=y";
     document.forms[0].submit();
  }

  function goReport7(docno) {
     if (!validDate()) {
        return false;
     }

     //document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFReport7.jsp?search=y&itmtype=<%=itmType%>";
     document.forms[0].submit();
  }

  function goReport9(docno) {
     if (!validDate()) {
        return false;
     }

     //document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFReport9.jsp?i_docno="+docno+"&search=y&itmtype=<%=itmType%>";
     document.forms[0].submit();
  }

  function changePage(page) {
     //document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFReport8.jsp?search=y";
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

   var cutVendor = '<%=cutVendorId%>';
   document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFPrintReport8Servlet";
   if (cutVendor.length>0) document.forms[0].action = document.forms[0].action+"?cut_vendor="+cutVendor;
   document.forms[0].target="_blank";
   document.forms[0].submit();
   document.forms[0].target="";
}


//-->
</script>


<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">


<FORM METHOD="POST" ACTION="">

<input type="hidden" name="order_by" value="<%=orderBy%>">
<input type="hidden" name="itmtype" value="<%=itmType%>">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD">


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            <%=caption%></td>
          <td align="right">&nbsp;</td>
        </tr>
        <tr>
          <td width="70%" class="bigh">&nbsp;</td>
          <td width="30%" align="right">&nbsp;</td>
        </tr>
      </table>


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
    <td width="100%" class="frmLR" align="center"> <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="8%" height="22" class="item ; dotline01">โครงการ : </td>
          <td width="57%" height="22" class="dotline01">
	  <%=common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," onchange='changePage(1);' class='box' style='width:250px' ",false)%>
	    &nbsp;&nbsp;
	   </td>
        </tr>   
        <tr>
          <td width="8%" height="22" class="item ; dotline01">ผู้รับเหมาซ่อม : </td>
          <td width="57%" height="22" class="dotline01">
	  <%=common.genVendorList("i_vendor",selProj,iVendor," class='box' style='width:250px' ")%>
	    &nbsp;&nbsp;
	   </td>
        </tr>
        <tr>
          <td class="item ; dotline01" height="22">วันอนุมัติจ่ายตั้งแต่วันที่ : </td>
	  <td width="57%" height="22" class="dotline01">
		  <%
				int nowYear = Calendar.getInstance().get(Calendar.YEAR);
				if (nowYear>2400) nowYear -= 543;	

				out.println(common.genDateOfMonthListbox("start_date",(startDate.length()==10 ? startDate.substring(8,10) : "")," class='box' "));
				out.println(common.genMonthListbox("start_month",(startDate.length()==10 ? startDate.substring(5,7) : "")," class='box' "));
				out.println(common.genYearListbox("start_year",(startDate.length()==10 ? startDate.substring(0,4) : "")," class='box' ",nowYear-3,5));
		  %>
          &nbsp; &nbsp; ถึง : &nbsp; &nbsp;
		  <%
				out.println(common.genDateOfMonthListbox("end_date",(endDate.length()==10 ? endDate.substring(8,10) : "")," class='box' "));
				out.println(common.genMonthListbox("end_month",(endDate.length()==10 ? endDate.substring(5,7) : "")," class='box' "));
				out.println(common.genYearListbox("end_year",(endDate.length()==10 ? endDate.substring(0,4) : "")," class='box' ",nowYear-3,5));
		  %>
	  &nbsp;&nbsp;&nbsp;&nbsp;
	  <a href="#" onclick="searchDocHD()"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a>
          </td>
        </tr>
      </table></td>
  </tr>
</table>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>
	  <br>
<%
  for (int v=0;v<vendorList.size();v++) {
        String mainVendor = (String) vendorList.elementAt(v);
       double totalWage = 0.00;
       double totalGoods = 0.00;
       double totalPay = 0.00;
       double totalPV = 0.00;
       double totalCutCompany = 0.00;
	   double totalLH = 0;
    	double totalCust = 0;       
       Double sumCutVendor[] =  newDoubleArray(vendorCut.size());

	//----==================== Get Markup Pay from SERV_XSTD  ====================-----//
	String markupPay = "";
	if (selProj.trim().length()>0 && mainVendor.trim().length()>0) {
		 sql.delete(0,sql.length());
		 sql.append(" select * from lan:serv_venprj where ")
			   .append(" i_company='").append(selProj.length()>=6 ? selProj.substring(0,2) : "").append("' ")
			   .append(" and i_project='").append(selProj.length()>=6 ? selProj.substring(3,6) : "").append("' ")
			   .append(" and i_vendor='").append(mainVendor).append("' ");
		 rs = stmt.executeQuery(sql.toString());
		 if (rs.next()) {
			double pAddPay = 0;
			if (itmType.equals("01")) {
				pAddPay = rs.getDouble("p_inf_pay");
			} else {
				pAddPay = rs.getDouble("p_add_pay");
			}
			markupPay = doString.displayNumber("##0.0",pAddPay)+" %";
		 }				        
		 rs.close();	
	}
   //---=========================================================================----//      




	//----======================= Get Repair Vendor Name ===========================----//
	String repairVendorName = "";
	if (mainVendor.equals("999999")) {
	       if (selProj.length()>2) { repairVendorName = companyName; }
	} else {
		sql.delete(0,sql.length());
		sql.append("select bus_name from lan:stpvendr where vend_code='").append(mainVendor).append("' ");
		rs1 = stmt1.executeQuery(sql.toString());
		if (rs1.next()) {
		    repairVendorName = doString.checkString(doString.DisplayThai(rs1.getString("bus_name")),"");
		}
		rs1.close();
	}

	if (repairVendorName.length()>0) {
	    %>
	      <table border="0" width="100%" cellspacing="0" cellpadding="0">
		      <tr>
			<td >
			    <br><br>
			    <b class="bigh" style="">ผู้รับเหมาซ่อม : <%=mainVendor+" - "+repairVendorName%></b><br>
			     <br style="font-size:10pt">
			 </td>
		     </tr>
		</table>
	    <%
	}

%>


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>

          <td class="item_tab2" width="160">รายละเอียดแบบสรุป</td>
                <td class="item_tab3"></td>

          <td class="textgray">&nbsp;</td>
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
<%
	if (itmType.equals("02")) { //Public
%>

      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td rowspan="2" class="col_name" width="6%">ประจำ<br>เดือน</td>          
          <td rowspan="2" class="col_name" width="11%">เลขที่ใบสั่งซ่อม</td>          
		  <td rowspan="2" class="col_name" width="20%">ผู้รับเหมาตัดเงิน</td>          
		  <td rowspan="2" class="col_name" width="5%">รหัสบัญชี</td>          
          <td rowspan="2" class="col_name" width="9%">ค่าแรง</td>
          <td rowspan="2" class="col_name" width="9%">ค่าของ</td>
          <td rowspan="2" class="col_name" width="9%">ค่าของ<BR>+ค่าแรง</td>
          <td rowspan="2" class="col_name" width="10%">รวมค่า<BR>ดำเนินการ <%=markupPay%></td>
          <td class="col_name" width="18%" colspan="3">คชจ.ของ</td>
        </tr>
	  <tr>
	  <td class="col_name" width="5%">%บริษัท</td>	  
	  <td class="col_name" width="8%">บริษัท</td>
	  <td class="col_name" width="8%">ลูกบ้าน</td>	  
	</tr> 
<%
		     //----================== Select Data from SERV_INFDOCHD ================----//
		     	String com_ps = "";
		        int line = 0;
		        sql.delete(0,sql.length());
		        sql.append("SELECT b.i_docno, b.i_month, b.p_com, b.i_ven_cut, b.i_account, SUM(q_wage_unit * z_wage_price) AS SUM_WAGE, ")
		              .append(" SUM(q_good_unit * z_good_price) AS SUM_GOODS, ")
		              .append(" SUM(z_amount_pay) AS SUM_AMOUNT_PAY, SUM(z_amount_pv) AS SUM_AMOUNT_PV, ")
		              .append(" SUM(z_amount_cut) AS SUM_AMOUNT_CUT, SUM(b.z_com_amount) AS SUM_AMOUNT_COM, SUM(b.z_cus_amount) AS SUM_AMOUNT_CUS FROM lan:serv_infpayment b, lan:serv_infdochd a ")
		              .append(" WHERE b.f_itmstatus = 'CLS' ");
				if (cutVendorId.length()>0) sql.append(" AND b.i_ven_cut = '").append(cutVendorId).append("' ");
				if (mainVendor.length()>0) sql.append(" AND b.i_vendor = '").append(mainVendor).append("' ");
				sql.append(condition);
		        sql.append(" AND b.i_docno = a.i_docno AND a.f_status IN ('OPN','CLS') GROUP BY b.i_docno, b.i_month, b.p_com, b.i_ven_cut, b.i_account ")
	              .append(" ORDER BY b.i_docno, b.i_month, b.p_com, b.i_ven_cut, b.i_account");
//out.print(sql.toString());				  
		        rs = stmt.executeQuery(sql.toString());
		        while (rs.next() == true) {
					String iDocNo = doString.checkString(rs.getString("i_docno"));
					String mnthDate = doString.checkString(rs.getString("I_MONTH"));
					String mnth = mnthDate.substring(5,7);
					String year = Integer.toString(Integer.parseInt(mnthDate.substring(0,4))+543);
					double p_com = rs.getDouble("P_COM");
					String vendorId = doString.checkString(rs.getString("i_ven_cut"));
					String acctId = doString.checkString(rs.getString("i_account"));
					com_ps = doString.displayNumber("##0.00", p_com);
					double sumWage = rs.getDouble("sum_wage");
					double sumGoods = rs.getDouble("sum_goods");
					double amountPay = rs.getDouble("sum_amount_pay");
					double amountPV = rs.getDouble("sum_amount_pv");	
					double amountLH = rs.getDouble("SUM_AMOUNT_COM");
					double amountCust = rs.getDouble("SUM_AMOUNT_CUS");						      
					totalWage += sumWage;
					totalGoods += sumGoods;
					totalPay += amountPay;
					totalPV += amountPV;	
					totalLH += amountLH;
					totalCust += amountCust;									  
					String vendorName = "";
					if (vendorId.equals("999999")) {
					       if (selProj.length()>2) { vendorName = companyName; }
					} else {
						sql.delete(0,sql.length());
						sql.append("select bus_name from lan:stpvendr where vend_code='").append(vendorId).append("' ");
						rs1 = stmt1.executeQuery(sql.toString());
						if (rs1.next()) {
						    vendorName = doString.DisplayThai(doString.checkString(rs1.getString("bus_name"),""));
						}
						rs1.close();
					}
%>
			<tr>
			<td class="dotline" width="6%" align="center"><nobr><%=mnth%>/<%=year%></nobr></td>			  			
			  <td class="dotline" width="11%" align="center"><nobr><a href="#" onclick="goReport9('<%=iDocNo%>');"><%=iDocNo%></a></nobr></td>
			  <td class="dotline" width="20%" align="left"><%=doString.checkString(vendorName,"&nbsp;")%></td>
			  <td class="dotline" width="5%" align="center"><%=doString.checkString(acctId,"&nbsp;")%></td>			  
			  <td align="right" class="dotline" width="9%"><%=format.format(sumWage)%></td>
			  <td align="right" class="dotline" width="9%"><%=format.format(sumGoods)%></td>
			  <td align="right" class="dotline" width="9%"><%=format.format(amountPay)%></td>
			  <td align="right" class="dotline" width="10%"><%=format.format(amountPV)%></td>
			   <td width="5%" class="dotline" align="center"><%=com_ps%></td>
			   <td width="8%" class="dotline" align="right"><%=format.format(amountLH)%></td>
			   <td width="8%" class="dotline" align="right"><% if (amountLH == 0 || amountCust == 0) { out.print(format.format(amountCust)); } else { out.print("&nbsp;");} %></td>
			</tr>   
<%					
					line++;	
					if (amountLH > 0 && amountCust > 0) {
						rs1 = stmt1.executeQuery("SELECT i_acct_cus, SUM(z_cus_amount) AS SUM_AMOUNT_CUS FROM lan:serv_infpayment WHERE f_itmstatus = 'CLS' AND i_ven_cut = '"+vendorId+"' AND i_itmtype = '02' AND i_vendor = '"+mainVendor+"' AND (d_payment BETWEEN '"+startDate+"' AND '"+endDate+"') AND i_docno = '"+iDocNo+"' AND i_account = '"+acctId+"' AND p_com = "+com_ps+" GROUP BY i_acct_cus ORDER BY i_acct_cus");
						if (rs1 != null) {
							while (rs1.next() == true) {
								acctId = doString.checkString(rs1.getString("i_acct_cus"));
								amountCust = rs1.getDouble("SUM_AMOUNT_CUS");
%>
			<tr>
			<td class="dotline" width="6%" align="center"><nobr><%=mnth%>/<%=year%></nobr></td>			  			
			  <td class="dotline" width="11%" align="center"><nobr><a href="#" onclick="goReport9('<%=iDocNo%>');"><%=iDocNo%></a></nobr></td>
			  <td class="dotline" width="20%" align="left"><%=doString.checkString(vendorName,"&nbsp;")%></td>
			  <td class="dotline" width="5%" align="center"><%=acctId%></td>			  
			  <td align="right" class="dotline" width="9%">&nbsp;</td>
			  <td align="right" class="dotline" width="9%">&nbsp;</td>
			  <td align="right" class="dotline" width="9%">&nbsp;</td>
			  <td align="right" class="dotline" width="10%">&nbsp;</td>
			   <td width="5%" class="dotline" align="center">&nbsp;</td>
			   <td width="8%" class="dotline" align="right">&nbsp;</td>
			   <td width="8%" class="dotline" align="right"><%=format.format(amountCust)%></td>			   
			</tr>  
<%						
								line++;						
							}// end while
							rs1.close();
							rs1=null;
						}
					}
		        }// end while
		        rs.close();
		        rs=null;
				while (line<Constants.SERV_ZONECONF_LINE) {
					line++;
%>	
			<tr>
			<td class="dotline" width="6%" align="center">&nbsp;</td>			  			
			  <td class="dotline" width="11%" align="center">&nbsp;</td>
			  <td class="dotline" width="20%" align="center">&nbsp;</td>
			  <td class="dotline" width="5%" align="center">&nbsp;</td>			  
			  <td align="right" class="dotline" width="9%">&nbsp;</td>
			  <td align="right" class="dotline" width="9%">&nbsp;</td>
			  <td align="right" class="dotline" width="9%">&nbsp;</td>
			  <td align="right" class="dotline" width="10%">&nbsp;</td>
			   <td width="5%" class="dotline" align="right">&nbsp;</td>
			   <td width="8%" class="dotline" align="right">&nbsp;</td>
			   <td width="8%" class="dotline" align="right">&nbsp;</td>			   
			</tr> 
<%
				}// end while
%>			
			<tr>
			<td align="center" class="dotline ; item" colspan="4">รวมเป็นเงิน</td>
          <td align="right" class="dotline ; item" width="9%"><%=format.format(totalWage)%></td>
          <td align="right" class="dotline ; item" width="9%"><%=format.format(totalGoods)%></td>
          <td align="right" class="dotline ; item" width="9%"><%=format.format(totalPay)%></td>
          <td align="right" class="dotline ; item" width="10%"><%=format.format(totalPV)%></td>
          <td align="right" class="dotline ; item" width="5%">&nbsp;</td>          
          <td align="right" class="dotline ; item" width="8%"><%=format.format(totalLH)%></td>
          <td align="right" class="dotline ; item" width="8%"><%=format.format(totalCust)%></td>
			</tr> 

      </table>			
<%
	} else {
%>
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>

          <td rowspan="2" class="col_name" width="8%"><a href="javascript:orderDoc('b.i_docno');">เลขที่ใบสั่งซ่อม</a></td>
          <td rowspan="2" class="col_name" width="27%">ผู้รับเหมาตัดเงิน</td>
          <td rowspan="2" class="col_name" width="5%">รหัสบัญชี</td>
          <td rowspan="2" class="col_name" width="5%">ค่าแรง</td>
          <td rowspan="2" class="col_name" width="5%">ค่าของ</td>
          <td rowspan="2" class="col_name" width="5%">ค่าของ<br>+ค่าแรง</td>
          <td rowspan="2" class="col_name" width="6%">รวมค่า<BR>ดำเนินการ <%=markupPay%></td>
          <td class="col_name" width="12%" colspan="<%=vendorCut.size()%>">ตัดเงินผู้รับเหมา</td>
		  <td rowspan="2" class="col_name" width="12%">ตัดเงิน<br><%=cutCompany%></td>
        </tr>
	  <tr>
	  <%
	    for (int c=0;c<vendorCut.size();c++) {
		  Double percent = (Double) vendorCut.elementAt(c);
		  %><td width="6%" class="col_name"><nobr><%=format.format(percent.doubleValue())%> %</nobr></td><%
	    }
	  %>
	</tr>
<%
		     //----================== Select Data from SERV_INFDOCHD ================----//
		        int line = 0;
		        sql.delete(0,sql.length());
		        sql.append("SELECT b.i_docno, b.i_ven_cut, b.i_account, SUM(q_wage_unit * z_wage_price) AS SUM_WAGE, ")
		              .append(" SUM(q_good_unit * z_good_price) AS SUM_GOODS, ")
		              .append(" SUM(z_amount_pay) AS SUM_AMOUNT_PAY, SUM(z_amount_pv) AS SUM_AMOUNT_PV, ")
		              .append(" SUM(z_amount_cut) AS SUM_AMOUNT_CUT FROM lan:serv_infpayment b, lan:serv_infdochd a ")
		              .append(" WHERE b.f_itmstatus = 'CLS' ");
				if (cutVendorId.length()>0) sql.append(" AND b.i_ven_cut = '").append(cutVendorId).append("' ");
				if (mainVendor.length()>0) sql.append(" AND b.i_vendor = '").append(mainVendor).append("' ");
				sql.append(condition);
		        sql.append(" AND b.i_docno = a.i_docno AND a.f_status IN ('OPN','CLS') GROUP BY b.i_docno, b.i_ven_cut, b.i_account ")
	              .append(" ORDER BY ").append(orderBy).append(", b.i_ven_cut, b.i_account");
		        rs = stmt.executeQuery(sql.toString());
		        while (rs.next() == true) {
				String iDocNo = doString.checkString(rs.getString("i_docno"),"");
				String vendorId = doString.checkString(rs.getString("i_ven_cut"),"");
				String accountId = doString.checkString(rs.getString("i_account"),"");
				double sumWage = rs.getDouble("sum_wage");
				double sumGoods = rs.getDouble("sum_goods");
				double amountPay = rs.getDouble("sum_amount_pay");
				double amountPV = rs.getDouble("sum_amount_pv");
				double cutComp = 0.00;
				Double cutVendor[] = newDoubleArray(vendorCut.size());

				totalWage += sumWage;
				totalGoods += sumGoods;
				totalPay += amountPay;
				totalPV += amountPV;

				//----======================= Get Customer Details ===========================----//
				String iHouse = "";


				//----======================= Get VendorName ===========================----//
				String vendorName = "";
				if (vendorId.equals("999999")) {
				       if (selProj.length()>2) { vendorName = companyName; }
				} else {
					sql.delete(0,sql.length());
					sql.append("select bus_name from lan:stpvendr where vend_code='").append(vendorId).append("' ");
					rs1 = stmt1.executeQuery(sql.toString());
					if (rs1.next()) {
					    vendorName = doString.DisplayThai(doString.checkString(rs1.getString("bus_name"),""));
					}
					rs1.close();
				}

				//---============ get Cut Type ==============---//
				String cutType = "";
				//---============ Find Vendor Cut ==============---//
				sql.delete(0,sql.length());
				sql.append("SELECT b.p_cut, SUM(z_cut_pv) AS SUM_CUT_PV ")
					  .append(" FROM lan:serv_infdochd a, lan:serv_infpayment b ")
					  .append(" WHERE b.i_docno = a.i_docno AND a.f_status IN ('OPN','CLS') ")
					  .append(" AND b.i_docno = '").append(iDocNo).append("' ")
					  .append(" AND b.f_itmstatus = 'CLS' AND b.i_ven_cut = '").append(vendorId).append("' ")
					  .append(" AND b.i_account = '").append(accountId).append("' ")
					  .append(" AND b.i_itmtype = '").append(itmType).append("' ");
				if (startDate.length()>0 && endDate.length()>0) {
					sql.append(" AND b.d_payment BETWEEN '"+startDate+"' AND '"+endDate+"' ");
				}				   
				if (mainVendor.length()>0) sql.append(" AND b.i_vendor = '").append(mainVendor).append("' ");
				sql.append(" GROUP BY b.p_cut");
				rs1 = stmt1.executeQuery(sql.toString());
				while (rs1.next()) {
				    double pCut = rs1.getDouble("p_cut");
				    double cutValue = rs1.getDouble("sum_cut_pv");

					if (pCut==0.00 && vendorId.equals("999999")) {
						cutComp += cutValue;    
						totalCutCompany += cutValue; 
				    } else {
					    for (int c=0;c<vendorCut.size();c++) {
						  Double cut = (Double)  vendorCut.elementAt(c);
						  if (cut.doubleValue()==pCut) {
						      cutVendor[c] = new Double(cutVendor[c].doubleValue()+cutValue);
						      sumCutVendor[c] = new Double(sumCutVendor[c].doubleValue()+cutValue);
						      break;
						  }
					    } // end for
				    }
				} // end while rs1
				rs1.close();

			   tsv = "";
				%>
				<tr>
				   
				  <td class="dotline" width="8%" align="center"><nobr><a href="#" onclick="goReport9('<%=iDocNo%>');"><%=iDocNo%></a></nobr></td>
				  <td class="dotline" width="27%" align="left"><%=doString.checkString(vendorName,"&nbsp;")%></td>
				  <td align="center" class="dotline" width="5%"><%=accountId%></td>
				  <td align="right" class="dotline" width="5%"><%=format.format(sumWage)%></td>
				  <td align="right" class="dotline" width="5%"><%=format.format(sumGoods)%></td>
				  <td align="right" class="dotline" width="5%"><%=format.format(amountPay)%></td>
				  <td align="right" class="dotline" width="6%">&nbsp;<%=format.format(amountPV)%></td>
				    <%
				     for (int c=0;c<vendorCut.size();c++) {
					  %><td width="6%" class="dotline ; item" align="right">&nbsp;<%=format.format(cutVendor[c].doubleValue())%></td><%
				     }
				     %>
				  <td align="right" class="dotline" width="12%"><%=format.format(cutComp)%></td>
				</tr>
				<%

				 line++;
			} // end while


		   while (line<Constants.SERV_ZONECONF_LINE) {
		       line++;
			%>
			<tr>			  
			  <td class="dotline" width="8%" align="center">&nbsp;</td>
			  <td class="dotline" width="27%" align="center">&nbsp;</td>
			  <td align="center" class="dotline" width="5%">&nbsp;</td>
			  <td align="right" class="dotline" width="5%">&nbsp;</td>
			  <td align="right" class="dotline" width="5%">&nbsp;</td>
			  <td align="right" class="dotline" width="5%">&nbsp;</td>
			  <td align="right" class="dotline" width="6%">&nbsp;</td>
			   <%
			    for (int c=0;c<vendorCut.size();c++) {
				  %><td width="6%" class="dotline" align="right">&nbsp;</td><%
			    }
			   %>
			   <td width="12%" class="dotline" align="right">&nbsp;</td>
			</tr>
		       <%
		  }  // end while
	%>
        <tr>
          <td align="center" class="dotline ; item" colspan="3">รวมเป็นเงิน</td>
          <td align="right" class="dotline ; item" width="5%"><%=format.format(totalWage)%></td>
          <td align="right" class="dotline ; item" width="5%"><%=format.format(totalGoods)%></td>
          <td align="right" class="dotline ; item" width="5%"><%=format.format(totalPay)%></td>
          <td align="right" class="dotline ; item" width="6%"><%=format.format(totalPV)%></td>
	    <%
	     for (int c=0;c<vendorCut.size();c++) {
		  %><td width="6%" class="dotline ; item" align="right"><%=format.format(sumCutVendor[c].doubleValue())%></td><%
	     }
	     %>
	  <td width="12%" class="dotline ; item" align="right"><%=format.format(totalCutCompany)%></td>
        </tr>
      </table>
<%
	}
%>      
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

<span width="100%" align="left">
<br>
</span>


<br style="font-size:10pt">

<%
} // end for vendorList
%>

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
            <td class="act_tab4"><a href="#" onclick="goReport7();" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
		System.out.println("ERROR SERV_INFReport8.jsp : " + e.getMessage());
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