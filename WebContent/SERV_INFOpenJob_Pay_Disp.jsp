<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.io.*" %>
<%@page import="java.util.*" %>
<%@page import="java.text.*" %>
<%@page import="serv.common.*" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>


<%
   doString str = new doString();


   //----============ Declare Variables for input data ===========----//
   String iDocNo = doString.checkString(request.getParameter("i_docno"),"");
   String edit = doString.checkString(request.getParameter("edit"),"");
   String popup = doString.checkString(request.getParameter("popup"),"");
   
   
   //-----========= Declare Variables for OpenJob Page ===========----//
   String mode = doString.checkString(request.getParameter("mode"),"edit");
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
   String guranteeDesc = "-";
   String guranteeDate = "-";
   String iCustomer = "";
   Vector jobList = new Vector();
   
			       
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
        

	   if (iDocNo.length()>0) {
	        //----======================== Find DocHD Data =============================----//
			 Hashtable tmpHeader = common.getInfDocHeaderDetails(iDocNo);
		     inFormEmp = doString.checkString((String) tmpHeader.get("inform_emp"),"");
	         projDesc = doString.checkString((String) tmpHeader.get("proj_desc"),"");
	         iCompany = doString.checkString((String) tmpHeader.get("i_company"),"");
	         iProject = doString.checkString((String) tmpHeader.get("i_project"),"");
	         selProj = iCompany+":"+iProject;
	         cDesc = doString.checkString((String) tmpHeader.get("c_desc"),"");
	         cDesc = str.replace(cDesc,"|break|","<br>");
	         cDesc = str.replace(cDesc," ","&nbsp;"); 			
			 inFormDate = doString.checkString((String) tmpHeader.get("inform_date"),"");
			 dAppoint = doString.checkString((String) tmpHeader.get("d_appoint"),"-");
			 dEstClose = doString.checkString((String) tmpHeader.get("d_est_close"),"-");
			 
			
			
			//----======================= Get Customer Details ===========================----//
			//----============================= Get JobItem =============================----//
			sql.delete(0,sql.length());
			sql.append(" select a.*,b.n_itmjob,b.n_count,c.n_desc,d.bus_name,e.n_desc as remark_desc, t.n_desc as item_type from lan:serv_infpayment a ")
			      .append(" left join lan:serv_infboq b on b.i_itmjob=a.i_itmjob ")
			      .append(" left join lan:serv_xstd c on c.i_type='08' and c.i_code=a.i_itmjob_area ")
			      .append(" left join lan:stpvendr d on d.vend_code=a.i_ven_cut ")
				  .append(" left join lan:serv_xstd t on t.i_type='64' and t.i_code=a.i_itmtype ")			      
				  .append(" left join lan:serv_xstd e on e.i_type='10' and e.i_code=a.f_remark ")
			      .append(" where a.i_docno='").append(iDocNo).append("' and a.f_itmstatus<>'CAN' ")
			      .append(" order by i_itmjob,i_seq ");

			rs = stmt.executeQuery(sql.toString());
			while (rs.next()) {
				   Hashtable docdt = new Hashtable();
				   docdt.put("i_itmjob",doString.checkString(rs.getString("i_itmjob"),""));
				   docdt.put("n_itmjob",doString.checkString(rs.getString("n_itmjob"),""));
				   docdt.put("n_count",doString.checkString(rs.getString("n_count"),""));
				   docdt.put("item_type",doString.checkString(rs.getString("item_type"),""));
				   docdt.put("i_vendor",doString.checkString(rs.getString("i_vendor"),""));
				   docdt.put("bus_name",doString.checkString(rs.getString("bus_name"),""));
				   docdt.put("i_ven_cut",doString.checkString(rs.getString("i_ven_cut"),""));
				   docdt.put("p_cut",doString.checkString(rs.getString("p_cut"),""));
				   docdt.put("f_remark",doString.checkString(rs.getString("f_remark"),""));
				   docdt.put("remark_desc",doString.checkString(rs.getString("remark_desc"),""));
				   docdt.put("q_wage_unit",doString.checkString(rs.getString("q_wage_unit"),""));
				   docdt.put("z_wage_price",doString.checkString(Double.toString(rs.getDouble("z_wage_price")),""));
				   docdt.put("q_good_unit",doString.checkString(rs.getString("q_good_unit"),""));
				   docdt.put("z_good_price",doString.checkString(Double.toString(rs.getDouble("z_good_price")),""));
				   docdt.put("z_amount_pay",doString.checkString(rs.getString("z_amount_pay"),""));
				   docdt.put("c_itmjob",doString.checkString(rs.getString("c_itmjob"),""));
				   docdt.put("n_desc",doString.checkString(rs.getString("n_desc"),""));		
				   docdt.put("n_name",doString.checkString(rs.getString("n_name"),""));		
				   docdt.put("i_file_name",doString.checkString(rs.getString("i_file_name"),""));		
				   docdt.put("v_name",doString.checkString(rs.getString("v_name"),""));		
				   docdt.put("v_file_name",doString.checkString(rs.getString("v_file_name"),""));		
				   docdt.put("i_path_name",doString.checkString(rs.getString("i_path_name"),""));		
				   jobList.addElement(docdt);
			} // end while
			rs.close();
			//----=====================================================================----//
				
		    
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
function printOpenJob() {
   document.forms[0].action="/LHServ/SERV_PrintInfOpenJobServlet?print_target=PAYMENT&i_docno=<%=iDocNo%>";
   document.forms[0].target="_blank";   
    document.forms[0].submit();
}

function cancelDoc() {
   if (confirm(" คุณแน่ใจว่าต้องการยกเลิกใบแจ้งซ่อมนี้ ?")) {
	   document.forms[0].action="<%=Constants.APP_PATH%>/CancelInfJobServlet";
	   document.forms[0].target="";
	   document.forms[0].submit();
   }
}

//-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">
<input type="hidden" name="mode" value="<%=mode%>">
<input type="hidden" name="print_target" value="PAYMENT">
<input type="hidden" name="i_docno" value="<%=iDocNo%>">
<input type="hidden" name="docNo" value="<%=iDocNo%>">
<input type="hidden" name="d_appoint" value="<%=dAppoint%>">
<input type="hidden" name="d_est_close" value="<%=dEstClose%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
            <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp; 
              Print Open Job</td>
          <td width="50%" align="right">&nbsp;
          </td>
        </tr>
      </table>


<br style="font-size:10pt">



            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                
            <td class="item_tab2" width="200">รายละเอียดการสั่งซ่อม</td>
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
                  <td height="22" width="39%" class="dotline01"><%=doString.DisplayThai(projDesc)%>
                  </td>
                  <td height="22" class="item ; dotline01" width="14%">เลขที่ใบสั่งซ่อม 
                    :</td>
                  <td height="22" width="34%" class="dotline01"><%=iDocNo%></td>
                </tr>
                <tr> 
                  <td class="item ; dotline01" height="22" width="13%">ชื่อเจ้าหน้าที่
                    :</td>
                  <td height="22" width="39%" class="dotline01"><%=doString.DisplayThai(inFormEmp)%></td>
                  <td height="22" class="item ; dotline01" width="14%">วันเวลาที่แจ้ง 
                    :</td>
                  <td height="22" width="34%" class="dotline01"><%=inFormDate%></td>
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
                  <td rowspan="2" class="col_name" width="2%">No.</td>
                  <td rowspan="2" class="col_name" width="18%">รายละเอียดการซ่อม</td>
                  <td class="col_name" width="6%" rowspan="2">หน่วยนับ</td>
                  <td class="col_name" width="6%" rowspan="2">ประเภท</td>                  
                  <td class="col_name" width="4%" rowspan="2">ผู้รับเหมา</td>
                  <td colspan="3" class="col_name">ค่าแรง</td>
                  <td colspan="3" class="col_name">ค่าของ</td>
                  <td rowspan="2" class="col_name" width="6%">รวมเงิน</td>
                  <td rowspan="2" class="col_name" width="15%">ตัดเงิน</td>
                  <td rowspan="2" class="col_name" width="3%">%</td>
                  <td rowspan="2" class="col_name" width="8%">สาเหตุ</td>
                </tr>
                <tr> 
                  <!-- ค่าแรง -->	
                  <td class="col_nameLow" width="6%">ต่อหน่วย</td>
                  <td class="col_nameLow" width="5%">จำนวน</td>
                  <td class="col_nameLow" width="5%">รวม</td>
                  <!-- ค่าของ -->
                  <td class="col_nameLow" width="6%">ต่อหน่วย</td>
                  <td class="col_nameLow" width="5%">จำนวน</td>
                  <td class="col_nameLow" width="5%">รวม</td>
                </tr>

        <%
        int line = 0;
        DecimalFormat format = new DecimalFormat("#,##0.00");
        double grandTotalWage = 0.00;
        double grandTotalGoods = 0.00;
        double grandTotal = 0.00;

	//------- Get Company Name for used in vendor cut = 999999 ------------//
	String companyName = "-";
	String comId = iDocNo.length()>2 ? iDocNo.substring(0,2) : "";
	 sql.delete(0,sql.length());
	 sql.append(" select * from lan:acxcompa where i_company='").append(comId).append("' ");
	 rs = stmt.executeQuery(sql.toString());
	 if (rs.next()) {
		companyName = doString.checkString(rs.getString("n_company"),"");		 	 
	 }
	 rs.close();

        
        for (int i=0;i<jobList.size();i++) {
                line++;
                Hashtable docdt  = (Hashtable) jobList.elementAt(i);
                double wageUnit = Double.parseDouble((String) docdt.get("z_wage_price"));
                double goodsUnit = Double.parseDouble((String) docdt.get("z_good_price"));

                double wagePrice = Double.parseDouble((String) docdt.get("q_wage_unit"));
                double goodsPrice = Double.parseDouble((String) docdt.get("q_good_unit"));
                double totalWage = 0.00;
                double totalGoods = 0.00;
                double subTotal = 0.00;
                
                totalWage = wagePrice * (double) wageUnit;
                totalGoods = goodsPrice * (double) goodsUnit;
                subTotal = totalWage + totalGoods;
                
                grandTotalWage += totalWage;
                grandTotalGoods += totalGoods;
                grandTotal += subTotal;



		//-------- Get Vendor Cut Name -----------//
		String iVenCut = doString.checkString((String) docdt.get("i_ven_cut"));
		String venCutName = "";
		if (iVenCut.equalsIgnoreCase("999999")) {
		   venCutName = companyName;
		} else {
		   venCutName = doString.checkString((String) docdt.get("bus_name"));
		}


		//------- Get Percent Cut ---------//
                String showPercentCut = doString.checkString((String) docdt.get("p_cut"),"");
		try {
		   showPercentCut = format.format(Double.parseDouble(showPercentCut));
		} catch (Exception e) {
		   showPercentCut = "";
		}


	
		//------ Get Different from docdt and payment -------//
		String remarkDiff = "";
		boolean foundNoChange = false;
		sql.delete(0,sql.length());
		sql.append(" select * from lan:serv_infdocdt where i_itmjob='").append(doString.checkString((String) docdt.get("i_itmjob"))).append("' ")
			  .append(" and i_docno='").append(iDocNo).append("' ")
			  .append(" and i_vendor='").append(doString.checkString((String) docdt.get("i_vendor"))).append("' ");
		rs = stmt.executeQuery(sql.toString());
		while (rs.next()) {
			double checkWage = rs.getDouble("z_wage_price");
			double checkGoods = rs.getDouble("z_good_price");
			if (wageUnit==checkWage && goodsUnit==checkGoods) {
				 foundNoChange = true;
				 break;
			}
		} // end while
		rs.close();

		if (!foundNoChange) {
			remarkDiff = "<b style='color:red'>*</b>";
		}
		//----------- Get Wrong Type Flag ------------//
		String wrongType = doString.checkString((String) docdt.get("remark_desc"));
		%>
                <tr> 
                  <td width="2%" align="center" class="dotline"><%=line%></td>
                  <td width="18%" class="dotline"><%=remarkDiff+doString.DisplayThai(doString.checkString((String) docdt.get("n_itmjob")))%></td>
                  <td width="6%" class="dotline" align="center"><%=doString.DisplayThai(doString.checkString((String) docdt.get("n_count")))%></td>
                  <td width="6%" class="dotline" align="center"><%=doString.DisplayThai(doString.checkString((String) docdt.get("item_type")))%></td>
                  <td width="4%" class="dotline ; item" align="center"><%=doString.checkString((String) docdt.get("i_vendor"))%></td>
                  <td width="6%" align="right" class="dotline"><%=format.format(wageUnit)%></td>
                  <td width="5%" align="center" class="dotline"><%=format.format(wagePrice)%></td>
                  <td width="5%" align="right" class="dotline"><%=format.format(totalWage)%></td>
                  <td width=6% align="right" class="dotline"><%=format.format(goodsUnit)%></td>
                  <td width="5%" align="center" class="dotline"><%=format.format(goodsPrice)%></td>
                  <td width="5%" align="right" class="dotline"><%=format.format(totalGoods)%></td>
                  <td width="6%" align="right" class="dotline"><%=format.format(subTotal)%></td>
                  <td align="center" class="dotline" width="15%"><%=doString.DisplayThai(doString.checkString(venCutName,"-"))%></td>
                  <td align="center" class="dotline" width="3%"><%=doString.checkString(showPercentCut,"-")%></td>
                  <td align="center" class="dotline" width="8%"><%=doString.DisplayThai(doString.checkString(wrongType,"-"))%></td>
                </tr>
		<%

           } // end for
           
           while (line<Constants.SERV_OPENJOB_LINE) {
                line++;
		        %>
                <tr> 
                  <td align="center" class="dotline" width="2%">&nbsp;</td>
                  <td class="dotline" width="18%">&nbsp;</td>
                  <td align="center" class="dotline" width="6%">&nbsp;</td>
                  <td align="center" class="dotline" width="6%">&nbsp;</td>
                  <td align="center" class="dotline" width="4%">&nbsp;</td>
                  <td align="right" class="dotline" width="6%">&nbsp;</td>
                  <td align="center" class="dotline" width="5%">&nbsp;</td>
                  <td align="right" class="dotline" width="5%">&nbsp;</td>
                  <td align="right" class="dotline" width="6%">&nbsp;</td>
                  <td align="center" class="dotline" width="5%">&nbsp;</td>
                  <td align="right" class="dotline" width="5%">&nbsp;</td>
                  <td align="right" class="dotline" width="6%">&nbsp;</td>
                  <td align="center" class="dotline" width="15%">&nbsp;</td>
                  <td align="center" class="dotline" width="3%">&nbsp;</td>
                  <td align="center" class="dotline" width="8%">&nbsp;</td>
                </tr>
		        <%
		     }  // end while
        %>
                <tr> 
                  <td align="center" class="dotline ; item" width="2%">&nbsp;</td>
                  <td class="dotline ; item" align="right" width="18%">รวมเป็นเงิน</td>
                  <td align="center" class="dotline ; item" width="6%">&nbsp;</td>
                  <td align="center" class="dotline ; item" width="6%">&nbsp;</td>
                  <td align="center" class="dotline ; item" width="4%">&nbsp;</td>
                  <td align="right" class="dotline ; item" width="6%">&nbsp;</td>
                  <td align="center" class="dotline ; item" width="5%">&nbsp;</td>
                  <td align="right" class="dotline ; item" width="5%"><%=format.format(grandTotalWage)%></td>
                  <td align="right" class="dotline ; item" width="6%">&nbsp;</td>
                  <td align="center" class="dotline ; item" width="5%">&nbsp;</td>
                  <td align="right" class="dotline ; item" width="5%"><%=format.format(grandTotalGoods)%></td>
                  <td align="right" class="dotline ; item" width="6%"><%=format.format(grandTotal)%></td>
                  <td align="center" class="dotline ; item" width="15%">&nbsp;</td>
                  <td align="center" class="dotline ; item" width="3%">&nbsp;</td>
                  <td align="center" class="dotline ; item" width="8%">&nbsp;</td>
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
                <td class="item_tab2" width="200">รายละเอียดการซ่อม</td>
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
                Hashtable docdt  = (Hashtable) jobList.elementAt(i);          
                %>
				  <tr>
				    <td class="item ; dotline01" height="22" width="12%">รายการที่ <%=line%> :</td>
				    <td height="22" width="80%" class="dotline01"><%=doString.DisplayThai(doString.checkString((String) docdt.get("c_itmjob")))%></td>
				    <td height="22" width="8%" class="dotline01"><%=doString.DisplayThai(doString.checkString((String) docdt.get("n_desc")))%></td>
				  </tr>
                <%
         } // end for
        
        while (line<Constants.SERV_OPENJOB_LINE) {
            line++;
		        %>  
				  <tr>
				    <td class="item ; dotline01" height="22" width="12%">&nbsp;</td>
				    <td height="22" width="80%" class="dotline01">&nbsp;</td>
				    <td height="22" width="8%" class="dotline01">&nbsp;</td>
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




<br style="font-size:10pt">



            <table border="0" width="100%" cellspacing="0" cellpadding="0">

              <tr>

                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>

                <td class="item_tab2" width="200">Attach File</td>

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
	String urlAttach = "";
	String fileName = "";
	String pathName = "";
	String realFiNme = "";
	line = 0;
	for (int i=0;i<jobList.size();i++) {
		line++;
		Hashtable docdt  = (Hashtable) jobList.elementAt(i);    
		fileName = doString.DisplayThai(doString.checkString((String) docdt.get("v_name")));
		pathName = doString.DisplayThai(doString.checkString((String) docdt.get("i_path_name")));
		if (pathName.equals("")) {
			pathName = request.getContextPath()+"/attach/lh/";
		}
		if (fileName.equals("")) {
			fileName = doString.DisplayThai(doString.checkString((String) docdt.get("n_name")));
			realFiNme = doString.checkString((String) docdt.get("i_file_name"));
			urlAttach = pathName+iDocNo+"/"+realFiNme;
		} else {
			realFiNme = doString.checkString((String) docdt.get("v_file_name"));
			urlAttach = "http://www9.lh.co.th/LHServ/attach/vendor/"+iDocNo+"/"+realFiNme;
		}
%>
				  <tr>
				    <td class="item ; dotline01" height="22" width="12%">รายการที่ <%=line%> :</td>
				    <td height="22" width="76%" class="dotline01"><%=doString.DisplayThai(doString.checkString((String) docdt.get("n_itmjob")))%></td>
				    <td height="22" width="12%" class="dotline01"><a href="<%=urlAttach%>" target="_blank"><%=fileName%></a>&nbsp;</td>
				  </tr>
<%			
	}// end for
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



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="230" class="act_tab2">
			<nobr>
           <a href="SERV_PrintInfOpenJobServlet?print_target=PAYMENT&docNo=<%=iDocNo%>" target="_blank"><img border="0" src="images/act_print001.gif" 
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">
			</nobr>
				</td>
            <td class="act_tab3"></td>
            <td class="act_tab4">
          <%
              if (popup.equalsIgnoreCase("Y")) {
                  %>
                   <a href="javascript:top.window.close()"><img border="0" src="images/bu_close.gif" align="top" width="50" height="15"></a> 
                  <%
              } else {
                  %>
		      <a href="javascript:history.back()"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
		      <a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
                  <%
              }
           %>      	    
			  </td>
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
		System.out.println("ERROR SERV_INFOpenJob_Pay_Disp.jsp : " + e.getMessage());
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