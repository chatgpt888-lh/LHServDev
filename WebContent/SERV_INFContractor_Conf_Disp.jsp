<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="java.text.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%
   doString str = new doString();


   //----============ Declare Variables for input data ===========----//
   String iDocNo = doString.checkString(request.getParameter("i_docno"),"");
   String iVendor = doString.checkString(request.getParameter("i_vendor"),"");
   
   
   //-----========= Declare Variables for OpenJob Page ===========----//
   String mode = doString.checkString(request.getParameter("mode"),"edit");
   //String dAppoint= doString.checkString(request.getParameter("d_appoint"),"");
   //String dEstClose= doString.checkString(request.getParameter("d_est_close"),"");   
   ItmJobManagement itm = new ItmJobManagement(request,response);
   itm.updateValuesFromRequest(); // update new values from request.
   itm.updateItemSession(); // update session before use
  //---=======================================================----//   
   
   
   
   //-----========= Declare Variables for Search Custoemr ===========----//
   String selProj = "";
   String iCompany = "";
   String iProject = "";
   String projDesc = "";
   String houseId = "";
   String iLock = "";
   String nCustomer = "";
   String nCustTel = "";
   String cDesc = "";   
   String inFormDate = "";
   String inFormEmp = "";
   String dAppoint = "";
   String dEstClose = "";
      
   String housePlan = "-";
   String custName = "-";
   String custTel = "-";
   String vendorName = "-";
   String iCustomer = "";
   Vector jobList = new Vector();
   
   String rejectStatus = "";
   String rejectComment = "";   
   String rejectEmploy = "";
   String rejectDate = "";   
	Hashtable docdt = new Hashtable();

			       
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
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
        

	   if (iDocNo.length()>0 ) {
	        //----======================== Find DocHD Data =============================----//
			 Hashtable tmpHeader = common.getInfDocHeaderDetails(iDocNo);
		     inFormEmp = doString.DisplayThai(doString.checkString((String) tmpHeader.get("inform_emp"),""));
	         projDesc = doString.DisplayThai(doString.checkString((String) tmpHeader.get("proj_desc"),""));
	         iCompany = doString.checkString((String) tmpHeader.get("i_company"),"");
	         iProject = doString.checkString((String) tmpHeader.get("i_project"),"");
	         selProj = iCompany+":"+iProject;
	         cDesc = doString.DisplayThai(doString.checkString((String) tmpHeader.get("c_desc"),""));
	         cDesc = str.replace(cDesc,"|break|","<br>");
	         cDesc = str.replace(cDesc," ","&nbsp;"); 			
			 inFormDate = doString.DisplayThai(doString.checkString((String) tmpHeader.get("inform_date"),""));
			 dAppoint = doString.DisplayThai(doString.checkString((String) tmpHeader.get("d_appoint"),"-"));
			 dEstClose = doString.DisplayThai(doString.checkString((String) tmpHeader.get("d_est_close"),"-"));
			 
			
			
			//----======================= Get Customer Details ===========================----//
			//----============================= Get JobItem =============================----//
			sql.delete(0,sql.length());
			sql.append(" select a.*,b.n_itmjob,b.n_count,c.n_desc from lan:serv_infpayment a ")
			      .append(" left join lan:serv_infboq b on b.i_itmjob=a.i_itmjob ")
			      .append(" left join lan:serv_xstd c on c.i_type='08' and c.i_code=a.i_itmjob_area ")
			      .append(" where a.i_docno='").append(iDocNo).append("' ");
			if (iVendor.trim().length()>0) sql.append(" and a.i_vendor='").append(iVendor).append("' ");
			sql.append(" and a.f_itmstatus='400' order by i_itmjob,i_seq ");
			rs = stmt.executeQuery(sql.toString());
			while (rs.next()) {
				   docdt = new Hashtable();
				   docdt.put("n_itmjob",doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")),""));
				   docdt.put("n_count",doString.checkString(doString.DisplayThai(rs.getString("n_count")),""));
				   docdt.put("i_vendor",doString.checkString(rs.getString("i_vendor"),""));
				   docdt.put("q_wage_unit",doString.checkString(doString.DisplayThai(rs.getString("q_wage_unit")),""));
				   docdt.put("z_wage_price",doString.checkString(Double.toString(rs.getDouble("z_wage_price")),""));
				   docdt.put("q_good_unit",doString.checkString(doString.DisplayThai(rs.getString("q_good_unit")),""));
				   docdt.put("z_good_price",doString.checkString(Double.toString(rs.getDouble("z_good_price")),""));
				   docdt.put("z_amount_pay",doString.checkString(doString.DisplayThai(rs.getString("z_amount_pay")),""));
				   docdt.put("c_itmjob",doString.checkString(doString.DisplayThai(rs.getString("c_itmjob")),""));
				   docdt.put("n_desc",doString.checkString(doString.DisplayThai(rs.getString("n_desc")),""));			   
				   jobList.addElement(docdt);
			} // end while
			rs.close();
			//----=====================================================================----//			
				
				
				
				
			//----=================== Get Vendor Name & Reject Comment ========================----//
			sql.delete(0,sql.length());
			sql.append(" select trim(d.n_prename_th)||trim(d.n_nemploy_th)||' '||trim(d.n_semploy_th) n_app, ")
			      .append(" b.bus_name,a.* from lan:serv_infflow a ")
			      .append(" left join lan:stpvendr b on b.vend_code=a.i_vendor ")
			      .append(" left join lan:useracl c on c.user_id=a.i_approve and c.user_acl='S' ")
			      .append(" left join docflow:acemploy d on d.i_employ=c.i_employ where ")
			      .append(" a.i_docno='").append(iDocNo).append("' ");
			if (iVendor.trim().length()>0) sql.append(" and a.i_vendor='").append(iVendor).append("' ");
			sql.append(" order by a.f_itmstatus desc ");
			rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
		        vendorName = doString.checkString(doString.DisplayThai(rs.getString("bus_name")),""); 
			    rejectStatus = doString.checkString(rs.getString("f_reject"),"");
			    rejectComment = doString.checkString(rs.getString("c_reject"),"");
	            rejectComment = str.replace(rejectComment,"|break|","<br>");
	            rejectComment = str.replace(rejectComment," ","&nbsp;"); 				    
			    rejectEmploy = doString.checkString(doString.DisplayThai(rs.getString("n_app")),"");
			    
				 Timestamp tmp = rs.getTimestamp("d_approve");
				 if (tmp!=null) {
				     Calendar cal = Calendar.getInstance();
				 	 cal.setTime(tmp);
				     rejectDate = getDateFromCalendar(cal)+" "+getTimeFromCalendar(cal);
			     }
			} // end while
			rs.close();
			//----===========================================================================----//							
		    
	   } // end if check i_docno
   
%>



<HTML>
<HEAD>
<TITLE>Open Job - Display</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">
<!--
function openJob() {
   document.forms[0].action="SERV_InfOpenJob.jsp?load=yes";
   document.forms[0].target="";      
   document.forms[0].submit();
}

//-->
</script>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM METHOD="POST" ACTION="">
<input type="hidden" name="mode" value="<%=mode%>">
<input type="hidden" name="i_docno" value="<%=iDocNo%>">
<input type="hidden" name="d_appoint" value="<%=dAppoint%>">
<input type="hidden" name="d_est_close" value="<%=dEstClose%>">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
            <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp; 
              Contractor : ผู้รับเหมาส่งงาน</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>
<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                
            <td class="item_tab2" width="200">รายละเอียดการสั่งงานซ่อม</td>
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
                  <td class="item ; dotline01" height="22" width="13%">โครงการ 
                    :</td>
                  <td height="22" width="39%" class="dotline01"> <%=projDesc%>
                  </td>
                  <td height="22" class="item ; dotline01" width="14%">เลขที่ใบสั่งงานซ่อม 
                    :</td>
                  <td height="22" width="34%" class="dotline01"><%=iDocNo%></td>
                </tr>
                <tr> 
                  <td class="item ; dotline01" height="22" width="13%">ชื่อเจ้าหน้าที่ 
                    :</td>
                  <td height="22" width="39%" class="dotline01"><%=inFormEmp%></td>
                  <td height="22" class="item ; dotline01" width="14%">วันเวลาที่แจ้ง 
                    :</td>
                  <td height="22" width="34%" class="dotline01"><%=inFormDate%>
                  </td>
                </tr>
                <tr> 
                  <td class="item ; dotline01" height="22" width="13%">วันที่นัดซ่อม 
                    :</td>
                  <td height="22" width="39%" class="dotline01"><%=dAppoint%></td>
                  <td height="22" class="item ; dotline01" width="14%">วันที่ประมาณการเสร็จ 
                    :</td>
                  <td height="22" width="34%" class="dotline01"><%=dEstClose%></td>
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
                <td class="item_tab2" width="200">รายการซ่อม</td>
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
                <tr> 
                  <td width="3%" rowspan="2" class="col_name">No.</td>
                  <td width="25%" rowspan="2" class="col_name">รายการซ่อม</td>
                  <td width="6%" rowspan="2" class="col_name">หน่วยนับ</td>
                  <td width="10%" rowspan="2" class="col_name">ผู้รับเหมาซ่อม</td>
                  <td colspan="3" class="col_name">ค่าแรง</td>
                  <td colspan="3" class="col_name">ค่าของ</td>
                  <td width="8%" rowspan="2" class="col_name">รวมเงิน</td>
                </tr>
                <tr> 
                  <td width="8%" class="col_nameLow">ต่อหน่วย</td>
                  <td width="4%" class="col_nameLow">จำนวน</td>
                  <td width="8%" class="col_nameLow">รวม</td>
                  <td width="8%" class="col_nameLow">ต่อหน่วย</td>
                  <td width="4%" class="col_nameLow">จำนวน</td>
                  <td width="8%" class="col_nameLow">รวม</td>
                </tr>
				
        <%
        int line = 0;
        DecimalFormat format = new DecimalFormat("#,##0.00");
        double grandTotalWage = 0.00;
        double grandTotalGoods = 0.00;
        double grandTotal = 0.00;
        
		double wageUnit = 0.0;
		double goodsUnit = 0.0;

		double wagePrice = 0.0;
		double goodsPrice = 0.0;
		double totalWage = 0.00;
		double totalGoods = 0.00;
		double subTotal = 0.00;

        for (int i=0;i<jobList.size();i++) {
                line++;
                docdt  = (Hashtable) jobList.elementAt(i);
                wageUnit = Double.parseDouble((String) docdt.get("q_wage_unit"));
                goodsUnit = Double.parseDouble((String) docdt.get("q_good_unit"));

                wagePrice = Double.parseDouble((String) docdt.get("z_wage_price"));
                goodsPrice = Double.parseDouble((String) docdt.get("z_good_price"));

/*
                wageUnit = Double.parseDouble((String) docdt.get("z_wage_price"));
                goodsUnit = Double.parseDouble((String) docdt.get("z_good_price"));

                wagePrice = Double.parseDouble((String) docdt.get("q_wage_unit"));
                goodsPrice = Double.parseDouble((String) docdt.get("q_good_unit"));
*/
                totalWage = 0.00;
                totalGoods = 0.00;
                subTotal = 0.00;
                
                totalWage = wagePrice * (double) wageUnit;
                totalGoods = goodsPrice * (double) goodsUnit;
                subTotal = totalWage + totalGoods;
                
                grandTotalWage += totalWage;
                grandTotalGoods += totalGoods;
                grandTotal += subTotal;

                
		        %>

                <tr> 
                  <td width="3%" align="center" class="dotline"><%=line%></td>
                  <td width="25%" class="dotline"><%=doString.checkString((String) docdt.get("n_itmjob"))%></td>
                  <td width="6%" class="dotline" align="center"><%=doString.checkString((String) docdt.get("n_count"))%></td>
                  <td width="10%" class="dotline ; item"><%=doString.checkString((String) docdt.get("i_vendor"))%></td>
                  <td width="8%" align="right" class="dotline"><%=format.format(wagePrice)%></td>
                  <td width="4%" align="center" class="dotline"><%=format.format(wageUnit)%></td>
                  <td width="8%" align="right" class="dotline"><%=format.format(totalWage)%></td>
                  <td width="8%" align="right" class="dotline"><%=format.format(goodsPrice)%></td>
                  <td width="4%" align="center" class="dotline"><%=format.format(goodsUnit)%></td>
                  <td width="8%" align="right" class="dotline"><%=format.format(totalGoods)%></td>
                  <td width="8%" align="right" class="dotline"><%=format.format(subTotal)%></td>
                </tr>
		        <%
           } // end for

           while (line<Constants.SERV_CONTRACTORCONF_LINE) {
                line++;
		        %>
                <tr> 
                  <td width="3%" align="center" class="dotline">&nbsp;</td>
                  <td width="25%" class="dotline">&nbsp;</td>
                  <td width="6%" class="dotline" align="center">&nbsp;</td>
                  <td width="10%" class="dotline ; item">&nbsp;</td>
                  <td width="8%" align="right" class="dotline">&nbsp;</td>
                  <td width="4%" align="center" class="dotline">&nbsp;</td>
                  <td width="8%" align="right" class="dotline">&nbsp;</td>
                  <td width="8%" align="right" class="dotline">&nbsp;</td>
                  <td width="4%" align="center" class="dotline">&nbsp;</td>
                  <td width="8%" align="right" class="dotline">&nbsp;</td>
                  <td width="8%" align="right" class="dotline">&nbsp;</td>
                </tr>
		        <%
		     }  // end while
        %>

                <tr> 
                  <td width="3%" align="center" class="dotline">&nbsp;</td>
                  <td width="25%" class="dotline">&nbsp;</td>
                  <td width="6%" class="dotline" align="center">&nbsp;</td>
                  <td width="10%" class="dotline ; item" align="right">รวม</td>
                  <td width="8%" align="right" class="dotline ; item">&nbsp;</td>
                  <td width="4%" align="right" class="dotline ; item">&nbsp;</td>
                  <td width="8%" align="right" class="dotline ; item"><%=format.format(grandTotalWage)%></td>
                  <td width="8%" align="right" class="dotline ; item">&nbsp;</td>
                  <td width="4%" align="right" class="dotline ; item">&nbsp;</td>
                  <td width="8%" align="right" class="dotline ; item"><%=format.format(grandTotalGoods)%></td>
                  <td width="8%" align="right" class="dotline ; item"><%=format.format(grandTotal)%></td>
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
<%
   if (jobList.size()>0) {
%>
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">หมายเหตุ</td>
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
         <%
        line = 0;
        for (int i=0;i<jobList.size();i++) {
                line++;
                docdt  = (Hashtable) jobList.elementAt(i);          
                %>
				  <tr>
				    <td class="item ; dotline01" height="22" width="12%">รายการที่ <%=line%> :</td>
				    <td height="22" width="76%" class="dotline01"><%=doString.checkString((String) docdt.get("c_itmjob"))%></td>
				    <td height="22" width="12%" class="dotline01"><%=doString.checkString((String) docdt.get("n_desc"))%></td>
				  </tr>
                <%
         } // end for
        
        while (line<Constants.SERV_CONTRACTORCONF_LINE) {
            line++;
		        %>  
				  <tr>
				    <td class="item ; dotline01" height="22" width="12%">&nbsp;</td>
				    <td height="22" width="76%" class="dotline01">&nbsp;</td>
				    <td height="22" width="12%" class="dotline01">&nbsp;</td>
				  </tr>
				<%
		  } // end while
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

<%
   } // end if check jobList
%>


<%

   if (rejectStatus.equalsIgnoreCase("Y") || rejectComment.length()>0) {
			%>
			<br style="font-size:10pt">
			
			            <table border="0" width="100%" cellspacing="0" cellpadding="0">
			              <tr>
			                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
			                <td class="item_tab2" width="160">หมายเหตุการ Reject</td>
			                <td class="item_tab3"></td>
			                <td class="textgray">&nbsp; โดย <%=rejectEmploy+" &nbsp; เมื่อวันที่ "+rejectDate%></td>                
			              </tr>
			            </table>
			
			
			
			<table border="0" width="100%" cellspacing="0" cellpadding="0">
			  <tr>
			    <td width="5" valign="top"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
			    <td class="frmTop">&nbsp;</td>
			    <td width="5" valign="top" align="right"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
			  </tr>
			</table>
			
			<table border="0" width="100%" cellspacing="0" cellpadding="0" style="height:100px">
			  <tr>
			    <td width="100%" class="frmLRpad01" valign="top"><%=doString.DisplayThai(rejectComment)%></td>
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
   }
%>
<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="230" class="act_tab2">&nbsp; 
            </td>
            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="SERV_INFContractor_List.jsp"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp; 
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
		System.out.println("ERROR SERV_INFContractor_Conf_Disp.jsp : " + e.getMessage());
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