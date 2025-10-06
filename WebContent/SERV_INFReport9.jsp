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


<%
   doString str = new doString();


   //----============ Declare Variables for input data ===========----//
   String search = doString.checkString(request.getParameter("search"),"");
   String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase();
   session.setAttribute("sess_sel_proj",selProj);
   /*
   if  (selProj.length()==0) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       session.setAttribute("sess_sel_proj",selProj);
   }*/

    
   String iDocNo = doString.checkString(request.getParameter("i_docno"),"");
   String iVendor = doString.checkString(request.getParameter("i_vendor"),"");
   String itmType = doString.checkString(request.getParameter("itmtype"),"01");
   String condition = "";
   String condition2 = "";

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

        if (iDocNo.trim().length()>0) {
           condition += " and a.i_docno='"+iDocNo+"'  ";
	   if (iDocNo.length()>=6) {
	       selProj = iDocNo.substring(0,2)+":"+iDocNo.substring(3,6);
	   }
        }

		if (selProj.length()>=6) {
           condition += "  and a.i_company='"+selProj.substring(0,2)+"' and a.i_project='"+selProj.substring(3,6)+"'  ";
		} else {
           condition += " and a.i_company='' and a.i_project=''  ";
		}


/*
        if (selProj.trim().length()>0 && !selProj.equalsIgnoreCase("ALL")) {
           condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
        }

	if (selProj.trim().length()<=0) {
	   String projList = common.getProjectListByUserId(user.getUserID());
	   if (projList.length()>0) {
	       condition += " and substr(a.i_docno,1,6) in ("+projList+") ";
	   } else {

		sql.delete(0,sql.length());
		sql.append(" select count(*) from serv_pstaff  where user_id='").append(user.getUserID()).append("' and proj_id='ALL' ");
		int checkAllPermission = 0;

		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
		    checkAllPermission = rs.getInt(1);
		}
		rs.close();
		if (checkAllPermission<=0) {
		   //----- used for user that no project in hand , set for data not load ----//
		   condition += " and a.i_docno='NOPROEJCT' ";
	       } else {
		  selProj = "ALL";
	       }

	   } // end if check selProj length

	}
*/

	if (startDate.length()>0 && endDate.length()>0) {
	   condition += " and b.d_payment between '"+startDate+"' and '"+endDate+"' ";
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




        //----==================== Find all Vendor in this result ============================-----//
        Vector vendorList = new Vector();
        sql.delete(0,sql.length());
        sql.append(" select distinct i_vendor from serv_infdochd a,serv_infpayment b ")
	      .append(" where  a.f_status in ('OPN','CLS') and b.i_docno=a.i_docno and b.f_itmstatus='CLS' and b.i_itmtype = '")
		  .append(itmType+"' ");
	if (iVendor.length()>0) { sql.append(" and b.i_vendor='").append(iVendor).append("' "); }
	if (selProj.length()>0 && !selProj.equals("ALL")) { 
		sql.append(" and a.i_company='"+(selProj.length()>=6 ? selProj.substring(0,2) : "")+"' and a.i_project='"+(selProj.length()>=6 ? selProj.substring(3,6) : "")+"' "); 
	}
	sql.append(condition);
        rs = stmt.executeQuery(sql.toString());
        while (rs.next()) {
            vendorList.addElement(doString.checkString(rs.getString("i_vendor"),""));
        }
        rs.close();
	//---=========================================================================----//



        //----====================== Get DOCHD Max Row ==============================-----//
        int maxRow = 0;
        sql.delete(0,sql.length());
        sql.append(" select count(*) cnt from serv_infdochd a,serv_infpayment b ")
	      .append(" where  a.f_status in ('OPN','CLS') and b.i_docno=a.i_docno and b.f_itmstatus='CLS' and b.i_itmtype = '")
					  .append(itmType+"' ");
	if (iVendor.length()>0) { sql.append(" and b.i_vendor='").append(iVendor).append("' "); }
	if (selProj.length()>0 && !selProj.equals("ALL")) { 
		sql.append(" and a.i_company='"+(selProj.length()>=6 ? selProj.substring(0,2) : "")+"' and a.i_project='"+(selProj.length()>=6 ? selProj.substring(3,6) : "")+"' "); 
	}
	sql.append(condition);
        sql.append(" group by a.i_docno,b.i_vendor ");
        rs = stmt.executeQuery(sql.toString());
        while (rs.next()) {
           maxRow++;
        }
        rs.close();
	//---=========================================================================----//



	   //-----============== Generate Display Customize and Page Link ==================-----//
	   String displayType = doString.checkString(request.getParameter("display_type"),"");
	   int displayLine = Integer.parseInt(doString.checkString(request.getParameter("display_line"),"0"));
	   int nowPage = Integer.parseInt(doString.checkString(request.getParameter("now_page"),"1"));
	   if (displayType.equalsIgnoreCase("A")) {
	      displayLine = maxRow;
	      nowPage = 1;
	   }
	   if (displayLine<Constants.SERV_MANAGERCONF_LINE) displayLine = Constants.SERV_MANAGERCONF_LINE;

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
<TITLE>Manager - ผู้จัดการกลุ่ม</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--

  function searchDocHD() {
     if (!validDate()) {
        return false;
     }

     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFReport9.jsp?search=y";
     document.forms[0].submit();
  }

  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFReport9.jsp?search=y";
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

   document.forms[0].action='<%=Constants.APP_PATH%>/SERV_INFPrintReport9Servlet<%=iDocNo.length()>0 ? "?i_docno="+iDocNo : ""%>';
   document.forms[0].target="_blank";   
   document.forms[0].submit();
   document.forms[0].target="";   
}


//-->
</script>


<style>
td		{	font-size:8.0pt	}
</style>

<base target="_self">
</HEAD>

<BODY leftMargin=15 topMargin=15 marginheight="15" marginwidth="15">


<FORM METHOD="POST" ACTION="">

<input type="hidden" name="now_page" value="<%=nowPage%>">
<input type="hidden" name="itmtype" value="<%=itmType%>">

      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>

    <td width="63%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
      รายละเอียดการส่งงานของผู้รับเหมาตามวันที่จ่าย (รายละเอียด)</td>
    <td width="37%" align="right">&nbsp; </td>
        </tr>
      </table>
<br>

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
          <%//=common.genDateListbox("start",request," class='box' ")%>
		  <%
				int nowYear = Calendar.getInstance().get(Calendar.YEAR);
			    if (nowYear>2400) nowYear -= 543;

				out.println(common.genDateOfMonthListbox("start_date",(startDate.length()==10 ? startDate.substring(8,10) : "")," class='box' "));
				out.println(common.genMonthListbox("start_month",(startDate.length()==10 ? startDate.substring(5,7) : "")," class='box' "));
				out.println(common.genYearListbox("start_year",(startDate.length()==10 ? startDate.substring(0,4) : "")," class='box' ",nowYear-3,5));
		  %>
          &nbsp; &nbsp; ถึง : &nbsp; &nbsp;
          <%//=common.genDateListbox("end",request," class='box' ")%>
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
<table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>

    <td width="45%" style="font-size: 16pt; color: rgb(255,100,0); letter-spacing: 3px; padding: 5px">&nbsp;
    </td>
          <td width="55%" align="right">
	    &nbsp;<input type="radio" value="L" checked name="display_type" <%=(displayType.equalsIgnoreCase("L") ? "checked" : "")%>>แสดงจำนวนรายการต่อหน้า&nbsp;
            <input type="text" name="display_line" class="boxC" style="width:50px" value="<%=displayLine%>">&nbsp;
            รายการ&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	    <input type="radio" value="A" name="display_type" <%=(displayType.equalsIgnoreCase("A") ? "checked" : "")%>>
            แสดงรายการทั้งหมด&nbsp;&nbsp;
            <a href="#" onclick="changePage(1);"><img border="0" src="images/bu_R.gif" align="absmiddle" style="cursor:hand" width="16" height="16"></a>
	    </td>
        </tr>
      </table>

<br style="font-size:10pt">


<%

 String oldVendor = "";
  int line = 0;
    String docNo = "";
	String iLock = "";
	String nProject = "";
	String iHouse = "";
	String cutType = "";
   String markupPay = "";


		 for (int v=0;v<vendorList.size();v++) {
			   String nowVendor = (String) vendorList.elementAt(v);


		     //----================== Select Data from SERV_DOCHD ================----//
		        sql.delete(0,sql.length());
		        sql.append(" select first ").append(endRow).append(" a.i_docno,c.n_project ")
		              .append(" from serv_infpayment b,serv_infdochd a ")
		              .append(" left join acxprojt c on c.i_company=a.i_company ")
  		              .append(" and c.i_project=a.i_project where ")
		              .append("  a.f_status in ('OPN','CLS') and b.i_docno=a.i_docno ")
		              .append(" and b.f_itmstatus='CLS' and b.i_itmtype = '")
					  .append(itmType+"' ");
		        if (nowVendor.length()>0) { sql.append(" and b.i_vendor='").append(nowVendor).append("' "); }
				if (selProj.length()>0 && !selProj.equals("ALL")) { 
					sql.append(" and a.i_company='"+(selProj.length()>=6 ? selProj.substring(0,2) : "")+"' and a.i_project='"+(selProj.length()>=6 ? selProj.substring(3,6) : "")+"' "); 
				}
			sql.append(condition);
		        sql.append(" group by a.i_docno,c.n_project ")
		              .append(" order by a.i_docno ");

			rs = stmt.executeQuery(sql.toString());
		        for (int i=0;i<maxRow;i++) {

                      if (rs.next()) {
		         line++;
                         if (line>startRow && line<=endRow) {

                                            //------ Data is in this page , display -----//
				             docNo = doString.checkString(rs.getString("i_docno"),"");
				             iLock = "";
				             nProject = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
				             iHouse = "";
				             cutType = "";



					    //---============== Print Vendor Details if has a new Vendor ===============---//
					    if (!oldVendor.equalsIgnoreCase(nowVendor)) {
					        oldVendor = nowVendor;

						String vendorName = "";
						sql.delete(0,sql.length());
						sql.append(" select vend_code,bus_name from lan:stpvendr ")
						      .append(" where vend_code='").append(nowVendor).append("' order by  vend_code ");
					        rs1 = stmt1.executeQuery(sql.toString());
						if (rs1.next()) {
						    vendorName = doString.checkString(doString.DisplayThai(rs1.getString("bus_name")),"");
						}
						rs1.close();


					//----==================== Get Markup Pay from SERV_XSTD  ====================-----//
					if (selProj.trim().length()>0 && nowVendor.trim().length()>0) {
						 sql.delete(0,sql.length());
						 sql.append(" select * from lan:serv_venprj where ")
							   .append(" i_company='").append(selProj.length()>=6 ? selProj.substring(0,2) : "").append("' ")
							   .append(" and i_project='").append(selProj.length()>=6 ? selProj.substring(3,6) : "").append("' ")
							   .append(" and i_vendor='").append(nowVendor).append("' ");
						 rs1 = stmt1.executeQuery(sql.toString());
						 if (rs1.next()) {
							double pAddPay = rs1.getDouble("p_add_pay");
							markupPay = doString.displayNumber("##0.0",pAddPay)+" %";
						 }				        
						 rs1.close();	
					}
				   //---=========================================================================----//      

					         %>
						    <br><br>
						    <b class="bigh" style="">ผู้รับเหมาซ่อม : <%=nowVendor+" - "+vendorName%></b><br>
						     <br style="font-size:10pt">
						<%
					    }



						     //-----============================ Print Header =================================----//

						     %>
					            <table border="0" width="100%" cellspacing="0" cellpadding="0">
					              <tr>
					                <td class="item_tab1">&nbsp;</td>
					                <td class="item_tab2" width="50">&nbsp;</td>
					                <td class="item_tab3"></td>
					                <td class="textgray"><%=nProject%>&nbsp;&nbsp;
					                  เลขที่ใบสั่งซ่อม :
					                  <a href="SERV_INFOpenJob_Pay_Disp.jsp?i_docno=<%=docNo%>&popup=y&edit=no" target="_blank"><%=docNo%></a></td>
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
								          <td class="col_nameS" rowspan="2" width="40%">รายการซ่อม</td>
								          <td rowspan="2" class="col_nameS" width="6%">ประเภทงาน</td>
								          <td rowspan="2" class="col_nameS" width="9%">รหัสบัญชี</td>
								          <td colspan="3" class="col_nameS">ค่าแรง</td>
								          <td colspan="3" class="col_nameS">ค่าของ</td>
								          <td rowspan="2" class="col_nameS" width="7%">ค่าแรง<br>
								            + ค่าของ</td>
								          <td rowspan="2" class="col_nameS" width="7%">รวมค่าดำเนิน<br>
								            การ <%=markupPay%></td>
								        </tr>
								        <tr>
								          <td class="col_nameLow" width="3%">จำนวน</td>
								          <td class="col_nameLow" width="7%">ต่อหน่วย</td>
								          <td class="col_nameLow" width="7%">รวม</td>
								          <td class="col_nameLow" width="3%">จำนวน</td>
								          <td class="col_nameLow" width="7%">ต่อหน่วย</td>
								          <td class="col_nameLow" width="7%">รวม</td>
								        </tr>
						     <%
						     //-----==========================================================================----//






							//----=========================== Get Payment Details ===============================----//
							int itmLine = 0;
						    double sumSumWage = 0.00;
						    double sumSumGoods = 0.00;
						    double sumSumTotal = 0.00;
						    double sumCutVendor = 0.00;
						    double sumCutOnly = 0.00;


							sql.delete(0,sql.length());
							sql.append(" select d.bus_name,c.n_itmjob,b.*, s.n_desc from lan:serv_infpayment b ")
							      .append(" left join lan:serv_infboq c on c.i_itmjob=b.i_itmjob ")
							      .append(" left join lan:serv_xstd s on s.i_type = '64' and s.i_code=b.i_itmtype ")
							      .append(" left join lan:stpvendr d on d.vend_code=b.i_ven_cut ")
							      .append(" where b.i_docno='").append(docNo).append("' ");
							if (nowVendor.length()>0) { sql.append(" and b.i_vendor='").append(nowVendor).append("' "); }
							if (selProj.length()>0 && !selProj.equals("ALL")) { sql.append(" and substr(b.i_docno,1,2)||':'||substr(b.i_docno,4,3)='").append(selProj).append("' "); }
							sql.append(" and b.f_itmstatus='CLS'   ");
							//out.println(sql.toString());
							rs1 = stmt1.executeQuery(sql.toString());
							while (rs1.next()) {
							    itmLine++;
							    String nItmJob = doString.checkString(doString.DisplayThai(rs1.getString("n_itmjob")),"");
							    itmType = doString.checkString(rs1.getString("i_itmtype"));
							    String acc_com = doString.checkString(doString.DisplayThai(rs1.getString("i_acct_com")),"");
							    String acc_cus = doString.checkString(doString.DisplayThai(rs1.getString("i_acct_cus")),"");
								String account = acc_com;
								if (itmType.equals("02")) {
									if (!acc_com.equals("") && !acc_cus.equals("")) {
										account = acc_com+","+acc_cus;
									} else {
										if (acc_com.equals("")) {
											account = acc_cus;
										} else {
											account = acc_com;
										}
									}
								}
								itmType = doString.checkString(doString.DisplayThai(rs1.getString("n_desc")),"");
							    double qWage = rs1.getDouble("q_wage_unit");
							    double zWage = rs1.getDouble("z_wage_price");
							    double qGoods = rs1.getDouble("q_good_unit");
							    double zGoods = rs1.getDouble("z_good_price");
							    double sumWage = qWage * (double) zWage;
							    double sumGoods = qGoods * (double) zGoods;
							    double sumTotal = rs1.getDouble("z_amount_pay");
							    double cutVendor = rs1.getDouble("z_amount_pv");

						        sumSumWage += sumWage;
						        sumSumGoods += sumGoods;
						        sumSumTotal += sumTotal;
						        sumCutVendor += cutVendor;


							    //----============= Check Remark for Cut Vendor =====================---//
							    String iVenCut = doString.checkString(rs1.getString("i_ven_cut"),"");
							    double pCut = rs1.getDouble("p_cut");
							    String remark = "";
							    if ((!iVenCut.equals("999999")) || (iVenCut.equals("999999") && pCut>0)) {
									double cutPv = rs1.getDouble("z_cut_pv");
							        remark = "หมายเหตุ : ตัดเงินผู้รับเหมา ";
							        remark += doString.DisplayThai(doString.checkString(rs1.getString("bus_name"),""));
							        remark += " "+format.format(pCut)+"% เป็นเงิน "+format.format(cutPv)+" บาท ";
 								    sumCutOnly += cutPv;
							    }


							 //-----============================= Print Body =====================================----//
					        %>
							        <tr>
							          <td class="dotline" width="40%" valign="top"><%=itmLine%>. <%=nItmJob%></td>
							          <td class="dotline" align="center" width="6%" valign="top"><%=itmType%></td>
							          <td class="dotline" align="center" width="9%" valign="top"><%=account%></td>
							          <td class="dotline" align="right" width="3%" valign="top"><%=format.format(zWage)%></td>
							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(qWage)%></td>
							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(sumWage)%></td>
							          <td class="dotline" align="right" width="3%" valign="top"><%=format.format(zGoods)%></td>
							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(qGoods)%></td>
							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(sumGoods)%></td>
							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(sumTotal)%></td>
							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(cutVendor)%></td>
							        </tr>
							  <%

							  if (remark.length()>0) {
								  %>
								        <tr>
								          <td class="dotline" width="40%" valign="top"><img border="0" src="images/bu_nextPage.gif" align="absmiddle" width="5" height="7">&nbsp;
								            <font color="#FF6699"><%=remark%></font></td>
								          <td class="dotline" align="right" width="6%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="9%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="3%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="3%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
								        </tr>
							     <%
							  }


                              //-----==========================================================================----//
							}
							rs1.close();

							if (sumCutOnly>0) {
							   %>

							        <tr>
							          <td class="solidline ; item"  width="40%" align="left"> รวมตัดเงินผู้รับเหมางทั้งหมด <%=format.format(sumCutOnly)%> บาท</td>
								          <td class="dotline" align="right" width="6%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="9%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="3%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="3%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
							        </tr>							   
							   <%
							}

							 %>
							        <tr>
							          <td class="solidline ; item" colspan="3" align="center">รวมทั้งหมด</td>
							          <td class="solidline ; item" align="right" width="3%" valign="top">&nbsp;</td>
							          <td class="solidline ; item" align="right" width="7%">&nbsp;</td>
							          <td class="solidline ; item" align="right" width="7%"><%=format.format(sumSumWage)%>&nbsp;</td>
							          <td class="solidline ; item" align="right" width="3%">&nbsp;</td>
							          <td class="solidline ; item" align="right" width="7%">&nbsp;</td>
							          <td class="solidline ; item" align="right" width="7%"><%=format.format(sumSumGoods)%></td>
							          <td class="solidline ; item" align="right" width="7%"><%=format.format(sumSumTotal)%></td>
							          <td class="solidline ; item" align="right" width="7%"><%=format.format(sumCutVendor)%></td>
							        </tr>
							  <%


						     //-----============================ Print Header =================================----//
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
					        <%
					        //-----==========================================================================----//


                         } // end if check row

                         if (i>endRow) break;
                      } //end if check rs
                } // end for


                //-------================== If no data , print blank table ========================------//
                if (line==0) {
                   %>
					            <table border="0" width="100%" cellspacing="0" cellpadding="0">
					              <tr>
					                <td class="item_tab1">&nbsp;</td>
					                <td class="item_tab2" width="50">&nbsp;</td>
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

								      <table border="0" width="100%" cellspacing="0" cellpadding="0">
								        <tr>
								          <td class="col_nameS" rowspan="2" width="40%">รายการซ่อม</td>
								          <td rowspan="2" class="col_nameS" width="6%">ประเภทงาน</td>
								          <td rowspan="2" class="col_nameS" width="9%">รหัสบัญชี</td>
								          <td colspan="3" class="col_nameS">ค่าแรง</td>
								          <td colspan="3" class="col_nameS">ค่าของ</td>
								          <td rowspan="2" class="col_nameS" width="7%">ค่าแรง<br>
								            + ค่าของ</td>
								          <td rowspan="2" class="col_nameS" width="7%">รวมค่าดำเนิน<br>
								            การ 17%</td>
								        </tr>
								        <tr>
								          <td class="col_nameLow" width="3%">จำนวน</td>
								          <td class="col_nameLow" width="7%">ต่อหน่วย</td>
								          <td class="col_nameLow" width="7%">รวม</td>
								          <td class="col_nameLow" width="3%">จำนวน</td>
								          <td class="col_nameLow" width="7%">ต่อหน่วย</td>
								          <td class="col_nameLow" width="7%">รวม</td>
								        </tr>
								        <%
								        for (int l=0;l<5;l++) {
								        %>
							        <tr>
							          <td class="dotline" width="40%" valign="top"><input type="hidden" name="i_itmjob" value="">&nbsp;</td>
							          <td class="dotline" align="center" width="6%" valign="top">&nbsp;</td>
							          <td class="dotline" align="center" width="9%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="3%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="3%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
							        </tr>
								        <%
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

							<br style="font-size:10pt">
                   <%
                }


      } // end for vendorList


                //-------================== If no data , print blank table ========================------//
                if (vendorList.size()<=0) {
                   %>
					            <table border="0" width="100%" cellspacing="0" cellpadding="0">
					              <tr>
					                <td class="item_tab1">&nbsp;</td>
					                <td class="item_tab2" width="50">&nbsp;</td>
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

								      <table border="0" width="100%" cellspacing="0" cellpadding="0">
								        <tr>
								          <td class="col_nameS" rowspan="2" width="40%">รายการซ่อม</td>
								          <td rowspan="2" class="col_nameS" width="6%">ประเภทงาน</td>
								          <td rowspan="2" class="col_nameS" width="9%">รหัสบัญชี</td>
								          <td colspan="3" class="col_nameS">ค่าแรง</td>
								          <td colspan="3" class="col_nameS">ค่าของ</td>
								          <td rowspan="2" class="col_nameS" width="7%">ค่าแรง<br>
								            + ค่าของ</td>
								          <td rowspan="2" class="col_nameS" width="7%">รวมค่าดำเนิน<br>
								            การ 17%</td>
								        </tr>
								        <tr>
								          <td class="col_nameLow" width="3%">จำนวน</td>
								          <td class="col_nameLow" width="7%">ต่อหน่วย</td>
								          <td class="col_nameLow" width="7%">รวม</td>
								          <td class="col_nameLow" width="3%">จำนวน</td>
								          <td class="col_nameLow" width="7%">ต่อหน่วย</td>
								          <td class="col_nameLow" width="7%">รวม</td>
								        </tr>
								        <%
								        for (int l=0;l<5;l++) {
								        %>
							        <tr>
							          <td class="dotline" width="40%" valign="top"><input type="hidden" name="i_itmjob" value="">&nbsp;</td>
							          <td class="dotline" align="center" width="6%" valign="top">&nbsp;</td>
							          <td class="dotline" align="center" width="9%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="3%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="3%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
							          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
							        </tr>
								        <%
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

							<br style="font-size:10pt">
                   <%
                }

    %>


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
             &nbsp; 
	     <img border="0" src="images/act_print.gif" onclick="printReport();"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">
	   </td>

            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_INFReport8.jsp?sel_project=<%=selProj%>&i_vendor=<%=iVendor%>&itmtype=<%=itmType%>" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
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
		System.out.println("ERROR SERV_INFReport9.jsp : " + e.getMessage());
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