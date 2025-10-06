<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@page import="java.text.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<% 
	//------------- userlogin session ------------//
	String companyId = user.getCompanyId();
	String empId = user.getEmpId();
	Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
	String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);	

	doString str = new doString();
	
	//----- Declare Variables for input data -----//
	String i_docno  = doString.checkString(request.getParameter("i_docno"),"");
	String i_vendor = doString.checkString(request.getParameter("i_vendor"),""); 
	String itmType = doString.checkString(request.getParameter("itmType"));
	String iType = "";
	
	//----- Declare Variables for INFStaff Page -----//
	String mode 	= doString.checkString(request.getParameter("mode"),"");			//new edit 
		
	
	//----- Declare Variables for Search Payment -----//
	String selProj = "";					//โครงการ
   	String iCompany = i_docno.substring(0,2);					//รหัส บ.	
   	String iProject = i_docno.substring(3,6);					//รหัสโครงการ
   	String projDesc = "";					//ชื่อโครงการ
	String inFormEmp = "";					//ชื่อผู้แจ้ง
	String d_payment = "";					//วันที่แจ้ง
	String payDate = "";
	String mnth = "";
	String year = "";
	String d_keyin = "";					//วันที่แจ้ง เวลา
	String d_appoint = "";					//วันที่นัดซ่อม
	String d_est_close = "";				//วันที่ประมาณเสร็จ
	String vendorName = "-";				//ผู้รับเหมาซ่อม
	
	
	Vector jobList = new Vector(); 			//List รายการซ่อม
	String rejectStatus = "";
   	String rejectComment = "";   
   	String rejectEmploy = "";
   	String rejectDate = "";  
	
	String vendor_cut = "";					//ตัดเงินผู้รับเหมา
	String percent_cut = "";				//%
	String wrong_type = "";					//%สาเหตุ
	String allotType = "";
	String com_acc = "";
	String cus_acc = "";
	String select_account = "";
	int not_share = 0;
	boolean share = true;
	Vector mnthlist = new Vector(3);
	//-------------- Connection --------------//
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	SERV_CommonData common = null;
	SERV_InfCommonData inf_common = null;
	try {
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();       
		common = new SERV_CommonData(conn);
		inf_common = new SERV_InfCommonData(conn);
		
		
		if(i_docno.length()>0){
			//======================= Find DocHD Data ===========================//
			//--- GET PROJECT ----//
			sql.delete(0,sql.length());
			sql.append("SELECT * FROM lan:serv_infdochd WHERE i_docno ='"+i_docno+"'");
			rs = stmt.executeQuery(sql.toString());
			if(rs.next()){
				companyId = rs.getString("i_company");
				iProject = rs.getString("i_project");
				empId = doString.checkString(rs.getString("i_service_employ"));
				Calendar inform = Calendar.getInstance();
				Timestamp tmp = rs.getTimestamp("d_keyin");
				if (tmp!=null) {
					inform.setTime(tmp);    
					d_payment = getDateFromCalendar(inform);
					d_keyin = getDateFromCalendar(inform)+" "+getTimeFromCalendar(inform);
				}		
				
				tmp = rs.getTimestamp("d_appoint");
				if (tmp!=null) {
				   	inform.setTime(tmp);     
				   	d_appoint = getDateFromCalendar(inform);
				}				
					
				tmp = rs.getTimestamp("d_est_close");
				if (tmp!=null) {
				   	inform.setTime(tmp);      
				   	d_est_close = getDateFromCalendar(inform);
				}						 
					
			}
			rs.close();
			
			sql.delete(0,sql.length());
			sql.append("SELECT n_project FROM lan:acxprojt WHERE i_company ='"+companyId+"' AND i_project='"+iProject+"'");
			rs = stmt.executeQuery(sql.toString());
			if(rs.next()){
				selProj = companyId+":"+iProject;
				projDesc = companyId+"-"+iProject+"-"+doString.checkString(doString.DisplayThai(rs.getString("n_project")));
			}
			rs.close();
			//-- Get Allot Type ---//
			rs = stmt.executeQuery("SELECT d_effective, i_type FROM lan:serv_allot WHERE i_company = '"+companyId+"' AND i_project = '"+iProject+"' AND d_effective <= TODAY ORDER BY d_effective DESC");
			if (rs != null) {
				if (rs.next() == true) {
					allotType = doString.checkString(rs.getString("I_TYPE"));
				}
				rs.close();
				rs=null;
			}			
			select_account = "i_com_acc"+allotType+", i_cus_acc"+allotType;
			
			//--- Get EMPLOY_NAME  ----//
			sql.delete(0,sql.length());
			sql.append("SELECT n_prename_th, n_nemploy_th, n_semploy_th FROM docflow:acemploy WHERE i_employ ='"+empId+"'");
			rs = stmt.executeQuery(sql.toString());
			if(rs.next()){
				inFormEmp = doString.checkString(doString.DisplayThai(rs.getString("n_prename_th")+" "+rs.getString("n_nemploy_th")+" "+rs.getString("n_semploy_th")));
			}
			rs.close();
		
		
			//--- Get VendorName -----//
			sql.delete(0,sql.length());
			sql.append("SELECT bus_name FROM lan:stpvendr WHERE vend_code ='"+i_vendor+"'");
			rs = stmt.executeQuery(sql.toString());
			if(rs.next()){
				vendorName = doString.checkString(doString.DisplayThai(rs.getString("bus_name")));
			}
			rs.close();
			
			
			
			//-------- GET LIST JOB DETAIL ------//
			sql.delete(0,sql.length());
			sql.append(" select a.*,b.n_itmjob,b.n_count,c.n_desc, v.bus_name from lan:serv_infpayment a ")
				.append(" left join lan:serv_infboq b on b.i_itmjob=a.i_itmjob ")
				.append(" left join lan:stpvendr v on v.vend_code=a.i_vendor ")
			   	.append(" left join lan:serv_xstd c on c.i_type='08' and c.i_code=a.i_itmjob_area ")
			   	.append(" where a.i_docno='").append(i_docno).append("' ")
				.append(" and a.i_vendor='").append(i_vendor).append("' ")
				.append(" and a.f_itmstatus='500' order by i_itmjob,i_seq ");
			
			rs = stmt.executeQuery(sql.toString());
			while (rs.next()) {
				Hashtable docdt = new Hashtable();
				docdt.put("i_seq",doString.checkString(rs.getString("i_seq"),""));
				docdt.put("i_itmjob",doString.checkString(rs.getString("i_itmjob"),""));
				docdt.put("i_itmtype",doString.checkString(rs.getString("i_itmtype"),""));
				docdt.put("n_itmjob",doString.checkString(rs.getString("n_itmjob"),""));
				docdt.put("n_count",doString.checkString(rs.getString("n_count"),""));
				docdt.put("i_vendor",doString.checkString(rs.getString("bus_name"),""));
				docdt.put("q_wage_unit",doString.checkString(rs.getString("q_wage_unit"),""));
				docdt.put("z_wage_price",doString.checkString(Double.toString(rs.getDouble("z_wage_price")),""));
				docdt.put("q_good_unit",doString.checkString(rs.getString("q_good_unit"),""));
				docdt.put("z_good_price",doString.checkString(Double.toString(rs.getDouble("z_good_price")),""));
				docdt.put("z_amount_pay",doString.checkString(rs.getString("z_amount_pay"),""));
				docdt.put("c_itmjob",doString.checkString(rs.getString("c_itmjob"),""));
				docdt.put("i_itmjob_area",doString.checkString(rs.getString("i_itmjob_area"),""));
				docdt.put("n_desc",doString.checkString(rs.getString("n_desc"),""));
				docdt.put("vendor_cut",doString.checkString(rs.getString("i_ven_cut"),""));
				docdt.put("percent_cut",doString.checkString(rs.getString("p_cut"),""));
				docdt.put("wrong_type",doString.checkString(rs.getString("f_remark"),""));
				docdt.put("d_payment",doString.checkString(rs.getString("d_payment"),""));
				   docdt.put("n_name",doString.checkString(rs.getString("n_name"),""));		
				   docdt.put("i_file_name",doString.checkString(rs.getString("i_file_name"),""));		
				   docdt.put("v_name",doString.checkString(rs.getString("v_name"),""));		
				   docdt.put("v_file_name",doString.checkString(rs.getString("v_file_name"),""));	
				   docdt.put("i_path_name",doString.checkString(rs.getString("i_path_name"),""));	
				    
				jobList.addElement(docdt);
			} 
			rs.close();
			
			//=================== Get Vendor Name & Reject Comment ========================//
			sql.delete(0,sql.length());
			sql.append(" select trim(d.n_prename_th)||trim(d.n_nemploy_th)||' '||trim(d.n_semploy_th) n_app, ")
			   	.append(" b.bus_name,a.* from lan:serv_infflow a ")
			   	.append(" left join lan:stpvendr b on b.vend_code=a.i_vendor ")
			   	.append(" left join lan:useracl c on c.i_employ=a.i_approve and c.user_acl='S' ")
			   	.append(" left join docflow:acemploy d on d.i_employ=c.i_employ where ")
			   	.append(" a.i_docno='").append(i_docno).append("' ")
				.append(" and a.i_vendor='").append(i_vendor).append("' ")
				.append(" order by a.f_itmstatus desc ");
			
			rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
			    rejectStatus = doString.checkString(rs.getString("f_reject"),"");
			    rejectComment = doString.DisplayThai(doString.checkString(rs.getString("c_reject"),""));
	            rejectComment = str.replace(rejectComment,"|break|","<br>");
	            rejectComment = str.replace(rejectComment," ","&nbsp;"); 				    
			    rejectEmploy = doString.checkString(rs.getString("n_app"),"");
			    
				Timestamp tmp = rs.getTimestamp("d_approve");
				if (tmp!=null) {
					Calendar cal = Calendar.getInstance();
					cal.setTime(tmp);
				   	rejectDate = getDateFromCalendar(cal)+" "+getTimeFromCalendar(cal);
			   	}
			} 
			rs.close();
			
			
		}
%>
<HTML>
<HEAD>
<TITLE>Service Staff Confirm</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<!--   for upload -->
<script language="javascript" src="resources/js/upload.js"></script>
<!-- use openUploadWindow(contextPath,sessionId) method --->

<script language="javascript">
<!--
function validateForm() {
	var itmType = "";
	var iType = "";
	var num_item = parseInt(document.forms[0].num_item.value,10);
	var share = "";
	var venId = "";
	var allotType = "";
	var com_acc = "";
	var cus_acc = "";
	allotType = document.forms[0].allotType.value;
	if (num_item > 0) {
		for (var i=0; i<num_item; i++) {
			itmType = document.getElementsByName("itmtype")[i].value;
			iType = document.getElementsByName("iType")[i].value;

			if(document.getElementsByName("itmtype")[i].value==""){
				alert("รายการซ่อม No."+(i+1)+"กรุณาเลือกประเภทงาน");
				return false;
			}

			if (allotType == "") {
				alert("ไม่พบข้อมูลประเภทการจัดสรรสำหรับโครงการนี้");
				return false;
			}
			com_acc = document.getElementsByName("com_acc")[i].value;
			cus_acc = document.getElementsByName("cus_acc")[i].value;
			if ((itmType == "01") && (iType == "01")) { //Infra
				if (com_acc == "") {
					alert("รายการซ่อม No."+(i+1)+" ไม่พบข้อมูลรหัสบัญชี");
					//document.getElementsByName("itmtype")[i].focus();
					return false;
				}
			}

			if ((itmType == "02") || (iType == "02")) { //Public
				if ((com_acc == "") && (cus_acc == "")) {
					alert("รายการซ่อม No."+(i+1)+" ไม่พบข้อมูลรหัสบัญชี");
					//document.getElementsByName("itmtype")[i].focus();
					return false;
				}
			}

			share = document.getElementsByName("share")[i].value;
			if ((itmType == "02") || (iType == "02")) { //Public
				if ((com_acc != "") && (cus_acc != "")) { //Share
					if (share == "false") {
						alert("รายการซ่อม No."+(i+1)+" ไม่พบข้อมูลปันส่วน");
						//document.getElementsByName("itmtype")[i].focus();
						return false;
					}
				}
			}

			venId = document.getElementsByName("vendor_cut")[i].value;
			if(document.getElementsByName("vendor_cut")[i].value==""){
				alert("รายการซ่อม No."+(i+1)+"กรุณาเลือกผู้รับเหมาที่ต้องการตัดเงิน !");
				document.getElementsByName("vendor_cut")[i].focus();
				return false;
			}			
			if (venId != "999999") {
				if(document.getElementsByName("percent_cut")[i].value==""){
					alert("รายการซ่อม No."+(i+1)+"กรุณาเลือก % การตัดเงิน !");
					document.getElementsByName("percent_cut")[i].focus();
					return false;
				}			
			}
			if(document.getElementsByName("wrong_type")[i].value==""){
				alert("รายการซ่อม No."+(i+1)+"กรุณาเลือกสาเหตุ !");
				document.getElementsByName("wrong_type")[i].focus();
				return false;
			}			
		}
     }

     return true;
}

function reject_job() {
    
    	if (document.getElementById("i_comment").value=="") {
        	alert(" กรุณากรอกหมายเหตุ เกี่ยวกับการ Reject !");
         	document.getElementById("i_comment").focus();
           	
      	} else {
          	if (confirm("คุณแน่ใจว่าต้องการ Reject ใบงานนี้ ?")) {
          		document.forms[0].mode.value="REJECT";
          		document.forms[0].action="/LHServ/SERV_InfStaffConfServlet";
          		document.forms[0].submit();
          	}
      	}
	
}

function approve_job() {
	if(validateForm()){
		document.forms[0].mode.value="APPROVE";
		document.forms[0].action="/LHServ/SERV_InfStaffConfServlet";
        document.forms[0].submit();
	} 
 
}

function changeType(j) {
	if (document.getElementsByName("i_itmjob").length>0) {
		itmType = document.getElementsByName("itmtype")[j].value;
		if (itmType == "02") {
			document.getElementsByName("vendor_cut")[j].value="999999";
		}
	}
}

//-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">

<input type="hidden" name="i_docno" value="<%=i_docno%>">
<input type="hidden" name="i_vendor" value="<%=i_vendor%>">
<input type="hidden" name="selProj" value="<%=selProj%>">
<input type="hidden" name="d_payment" value="<%=d_payment%>">
<input type="hidden" name="empId" value="<%=empId%>">
<input type="hidden" name="mode" value="<%=mode%>">
<input type="hidden" name="allotType" value="<%=allotType%>">
<input type="hidden" name="itemType" value="<%=itmType%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            Staff List : เจ้าหน้าที่บริการ</td>
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
                  <td height="22" width="39%" class="dotline01"><%=projDesc %>
                  </td>
                  <td height="22" class="item ; dotline01" width="14%">เลขที่ใบสั่งซ่อม 
                    :</td>
                  <td height="22" width="34%" class="dotline01"><span style="width:100px"><%=i_docno%></span></td>
                </tr>
                <tr> 
                  <td class="item ; dotline01" height="22" width="13%">ชื่อผู้แจ้ง 
                    :</td>
                  <td height="22" width="39%" class="dotline01"><%=inFormEmp%></td>
                  <td height="22" class="item ; dotline01" width="14%">วันเวลาที่แจ้ง 
                    :</td>
                  <td height="22" width="34%" class="dotline01"><%=d_keyin %></td>
                </tr>
                <tr> 
                  <td class="item ; dotline01" height="22" width="13%">วันที่นัดซ่อม 
                    :</td>
                  <td height="22" width="39%" class="dotline01"><%=d_appoint %></td>
                  <td height="22" class="item ; dotline01" width="14%">วันที่ประมาณการเสร็จ 
                    :</td>
                  <td height="22" width="34%" class="dotline01"><%=d_est_close %></td>
                </tr>
                <tr> 
                  <td class="item ; dotline01" height="22" width="13%">ผู้รับเหมาซ่อม 
                    :</td>
                  <td height="22" width="39%" class="dotline01"><%=vendorName%></td>
                  <td height="22" class="item ; dotline01" width="14%">&nbsp;</td>
                  <td height="22" width="34%" class="dotline01">&nbsp;</td>
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
	<!-- ================= LIST JOB DETAIL ================ -->
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        
        <tr>
          <td rowspan="2" class="col_name" width="3%">No.</td>
          <td rowspan="2" class="col_name" width="19%">รายละเอียดการซ่อม</td>
          <td rowspan="2" class="col_name" width="7%">ประเภทงาน</td>
          <td rowspan="2" class="col_name" width="5%">หน่วยนับ</td>
          <td colspan="3" class="col_name" width="8%">ค่าแรง</td>
          <td colspan="3" class="col_name" width="8%">ค่าของ</td>
          <td rowspan="2" class="col_name" width="6%">รวมเงิน</td>
          <td rowspan="2" class="col_name" width="12%">ตัดเงิน</td>
          <td rowspan="2" class="col_name" width="4%">%</td>
          <td rowspan="2" class="col_name" width="12%">สาเหตุ</td>
        </tr>
        <tr>
          <td class="col_nameLow" width="6%">ต่อหน่วย</td>
          <td class="col_nameLow" width="5%">จำนวน</td>
          <td class="col_nameLow" width="8%">รวม</td>
          <td class="col_nameLow" width="6%">ต่อหน่วย</td>
          <td class="col_nameLow" width="5%">จำนวน</td>
          <td class="col_nameLow" width="8%">รวม</td>
        </tr>
      	<% 
		    //================= LIST JobItem ===================//
		   	int line = 0;
		   	DecimalFormat format = new DecimalFormat("#,##0.00");
		   	double grandTotalWage = 0.00;
		   	double grandTotalGoods = 0.00;
			double grandTotal = 0.00;
			not_share=0;
			String account = "";
			mnthlist.removeAllElements();
			for (int i=0;i<jobList.size();i++) {
                line++;
                Hashtable docdt  = (Hashtable) jobList.elementAt(i);
				payDate = (String) docdt.get("d_payment");
				mnth = "";
				year = "";
				rs = stmt.executeQuery("SELECT MONTH(d_contructor) AS PAY_MNTH, YEAR(d_contructor) AS PAY_YEAR FROM lan:serv_payschd WHERE d_payment = '"+payDate+"'");
				if (rs != null) {
					if (rs.next() == true) {
						mnth = doString.displayNumber("00", rs.getInt("PAY_MNTH"));
						year = doString.checkString(rs.getString("PAY_YEAR"));
					}
					rs.close();
					rs=null;
				}
				com_acc = "";
				cus_acc = "";
				if (!allotType.equals("")) {
						rs = stmt.executeQuery("SELECT "+select_account+" FROM lan:serv_infboq WHERE i_itmjob = '"+doString.checkString((String)docdt.get("i_itmjob"))+"'");
						if (rs != null) {
							if (rs.next() == true) {
								com_acc = doString.checkString(rs.getString(1));
								cus_acc = doString.checkString(rs.getString(2));
							}
							rs.close();
							rs=null;
						}
				}
				iType = "";
				if (!com_acc.equals("") && !cus_acc.equals("")) {
					iType = "02";
				} else {
					account = com_acc;
					if (account.equals("")) account = cus_acc;

					if (!account.equals("")) {
						if (account.substring(0,3).equals("540") || account.substring(0,3).equals("551")) {
							iType = "01";
						} else {
							iType = "02";
						}
					}
				}
				share = false;
				rs = stmt.executeQuery("SELECT z_constr_area, z_trans_area FROM lan:avs_area WHERE i_company = '"+iCompany+"' AND i_project = '"+iProject+"' AND i_month = '"+mnth+"' AND i_year = '"+year+"'");
				if (rs.next() == true) {
					share = true;
				}
				rs.close();
				rs=null;

                double wagePrice = Double.parseDouble((String) docdt.get("z_wage_price"));
                double goodsPrice = Double.parseDouble((String) docdt.get("z_good_price"));

                double wageUnit = Double.parseDouble((String) docdt.get("q_wage_unit"));
                double goodsUnit = Double.parseDouble((String) docdt.get("q_good_unit"));
                double totalWage = 0.00;
                double totalGoods = 0.00;
                double subTotal = 0.00;
                
                totalWage = wagePrice * (double) wageUnit;
                totalGoods = goodsPrice * (double) goodsUnit;
                subTotal = totalWage + totalGoods;
                
                grandTotalWage += totalWage;
                grandTotalGoods += totalGoods;
                grandTotal += subTotal;                
		%>
				<tr>
				  <input type="hidden" name="i_seq" value="<%=(String)docdt.get("i_seq")%>"/>
				  <input type="hidden" name="i_itmjob" value="<%=(String)docdt.get("i_itmjob")%>"/>
				  <input type="hidden" name="share" value="<%=share%>"/>
				  <input type="hidden" name="com_acc" value="<%=com_acc%>"/>
				  <input type="hidden" name="cus_acc" value="<%=cus_acc%>"/>
		          <td width="3%" align="center" class="dotline"><%=line%></td>
		          <td width="19%" class="dotline"><b style='color:red'>
		          	<%=common.checkAmountJobdetail(i_docno,i_vendor,(String)docdt.get("i_itmjob"), wagePrice, wageUnit, goodsPrice, goodsUnit) %></b>
		          	<%=doString.checkString(doString.DisplayThai((String) docdt.get("n_itmjob")))%></td>
		          <td width="7%" class="dotline" align="center">
<%
					if (itmType.equals("01")) { out.print("ซ่อมสาธารณู"); }
					if (itmType.equals("02")) { out.print("ซ่อมสาธารณะ"); }

%>
					<input type="hidden" name="itmtype"  value="<%=itmType%>">
					<input type="hidden" name="iType"  value="<%=iType%>">
				  </td>
		          <td width="5%" class="dotline" align="center"><%=doString.checkString(doString.DisplayThai((String) docdt.get("n_count")))%></td>
		          
		          <td width="6%" align="right" class="dotline">
		          	<input type="text" class="boxR" style="width:100%;border: none;" readonly="readonly" name="customwage" value="<%=format.format(wagePrice)%>" /></td>
		          <td width="5%" align="center" class="dotline">
		          	<input type="text" class="boxR" style="width:100%;border: none;" readonly="readonly" name="wage" value="<%=format.format(wageUnit)%>" /></td>
		          <td width="8%" align="right" class="dotline">
		          	<input type="text" class="boxR" style="width:100%;border: none;" readonly="readonly" name="wage_sum" value="<%=format.format(totalWage)%>" /></td>
		          
		          <td width=6%" align="right" class="dotline">
		          	<input type="text" class="boxR" style="width:100%;border: none;" readonly="readonly" name="customgoods" value="<%=format.format(goodsPrice)%>" /></td>
		          <td width="5%" align="center" class="dotline">
		          	<input type="text" class="boxR" style="width:100%;border: none;" readonly="readonly" name="goods" value="<%=format.format(goodsUnit)%>" /></td>
		          <td width="8%" align="right" class="dotline">
		          	<input type="text" class="boxR" style="width:100%;border: none;" readonly="readonly" name="goods_sum" value="<%=format.format(totalGoods)%>" /></td>
		          
		          <td width="6%" align="right" class="dotline">
		          	<input type="text" class="boxR" style="width:100%;border: none;" readonly="readonly" name="sum_total" value="<%=format.format(subTotal)%>" /></td>
		          
		          <td align="center" class="dotline" width="12%">
		          	<%=common.genVendorListForCut("vendor_cut",selProj ,(String)docdt.get("vendor_cut"), "class='box' style='width:100%' "  ) %>
				  </td>
		          <td align="center" class="dotline" width="4%">
		          	<%
		          		String percenCut = "";
		          		percent_cut = (String)docdt.get("percent_cut"); 
		          		if(percent_cut!=null && percent_cut.length()>0){
		          			int percent_cut_lenght =  percent_cut.lastIndexOf(".");
		          			percenCut = percent_cut.substring(0,percent_cut_lenght);
		          			percenCut+="%";
		          		}
		          	%>
		          	<%=common.genAmountCutListBox("percent_cut",percenCut,"class='box' style='width:100%' ")%>
		          </td>
		          <td align="center" class="dotline" width="12%">
		          	<%=inf_common.genWrongTypeCutList("wrong_type",(String)docdt.get("wrong_type"),"class='box' style='width:100%' ",doString.checkString((String)docdt.get("i_itmjob")))%>
		          </td>
		        </tr>        
<%
           	} // end for
           	if (line==0) {
%>
 				<tr>
		          <td align="center" class="dotline" width="3%">&nbsp;</td>
		          <td class="dotline" width="19%">&nbsp;</td>
		          <td align="center" class="dotline" width="7%">&nbsp;</td>
		          <td align="center" class="dotline" width="5%">&nbsp;</td>
		          <td align="right" class="dotline" width="6%">&nbsp;</td>
		          <td align="center" class="dotline" width="5%">&nbsp;</td>
		          <td align="right" class="dotline" width="8%">&nbsp;</td>
		          <td align="right" class="dotline" width="6%">&nbsp;</td>
		          <td align="center" class="dotline" width="5%">&nbsp;</td>
		          <td align="right" class="dotline" width="8%">&nbsp;</td>
		          <td align="right" class="dotline" width="6%">&nbsp;</td>
		          <td align="center" class="dotline" width="12%">&nbsp;</td>
		          <td align="center" class="dotline" width="4%">&nbsp;</td>
		          <td align="center" class="dotline" width="12%">&nbsp;</td>
		        </tr>
<%
		 	}  // end while
%>
		<tr>
          <td align="center" class="dotline ; item" width="3%">&nbsp;<input type="hidden" name="num_item" value="<%=line%>"></td>
          <td class="dotline ; item" align="right" width="19%">รวมเป็นเงิน</td>
          <td align="center" class="dotline ; item" width="7%">&nbsp;</td>
          <td align="center" class="dotline ; item" width="5%">&nbsp;</td>
          <td align="right" class="dotline ; item" width="6%">&nbsp;</td>
          <td align="center" class="dotline ; item" width="5%">&nbsp;</td>
          <td align="right" class="dotline ; item" width="8%">
          	<input type="text" maxlength="8" class="dotline ; item" style="width:100%;border: none;text-align: right;font-size:12" readonly="readonly" name="totalWage" value="<%=format.format(grandTotalWage)%>" /></td>
          <td align="right" class="dotline ; item" width="6%">&nbsp;</td>
          <td align="center" class="dotline ; item" width="5%">&nbsp;</td>
          <td align="right" class="dotline ; item" width="8%">
          	<input type="text" maxlength="8" class="dotline ; item" style="width:100%;border: none;text-align: right;font-size:12" readonly="readonly" name="totalGoods" value="<%=format.format(grandTotalGoods)%>" /></td>      
          <td align="right" class="dotline ; item" width="6%">
          	<input type="text" maxlength="8" class="dotline ; item" style="width:100%;border: none;text-align: right;font-size:12" readonly="readonly" name="grandTotal" value="<%=format.format(grandTotal)%>" /></td>
          <td align="center" class="dotline ; item" width="12%">&nbsp;</td>
          <td align="center" class="dotline ; item" width="4%">&nbsp;</td>
          <td align="center" class="dotline ; item" width="12%">&nbsp;</td>
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
<!--
<table border="0" width="95%" cellspacing="0" cellpadding="0">
  <tr><td>ประเภทการตัด : Y = ตามสัญญา , N = อื่นๆ </td></tr>
</table>
-->

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
				    <td class="item ; dotline01" height="22" width="12%">รายการที่ <%=i+1%> :</td>
				    <td height="22" width="80%" class="dotline01">
                  		<%=doString.checkString(doString.DisplayThai((String) docdt.get("c_itmjob")))%></td>
				    <td height="22" width="8%" class="dotline01">
                  		<%=doString.checkString(doString.DisplayThai((String) docdt.get("n_desc")))%></td>
				  </tr>
                <%
         		} // end for
        
        		while (line<Constants.SERV_CONTRACTORCONF_LINE) {
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
	String realFiNme = "";
	line = 0;
	if (jobList.size()>0) {
		for (int i=0;i<jobList.size();i++) {
			line++;
			Hashtable docdt  = (Hashtable) jobList.elementAt(i);    
			fileName = doString.DisplayThai(doString.checkString((String) docdt.get("v_name")));
			urlAttach = doString.checkString((String) docdt.get("i_path_name"));
			if (fileName.equals("")) {
				fileName = doString.DisplayThai(doString.checkString((String) docdt.get("n_name")));
				realFiNme = doString.checkString((String) docdt.get("i_file_name"));
				if (urlAttach.equals("")) {
					urlAttach = request.getContextPath()+"/attach/lh/"+i_docno+"/"+realFiNme;
				} else {
					urlAttach = urlAttach + i_docno+"/"+realFiNme;
				}
			} else {
				realFiNme = doString.checkString((String) docdt.get("v_file_name"));
				urlAttach = "http://www7.lh.co.th/LHServ/attach/vendor/"+i_docno+"/"+realFiNme;
			}
%>
				  <tr>
				    <td class="item ; dotline01" height="22" width="12%">รายการที่ <%=line%> :</td>
				    <td height="22" width="76%" class="dotline01"><%=doString.DisplayThai(doString.checkString((String) docdt.get("n_itmjob")))%></td>
				    <td height="22" width="12%" class="dotline01"><a href="<%=urlAttach%>" target="_blank"><%=fileName%></a>&nbsp;</td>
				  </tr>
<%			
		}// end for
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
			                <td class="item_tab2" width="160">หมายเหตุ</td>
			                <td class="item_tab3"></td>
			                <td class="textgray">&nbsp;
			                </td>
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
			    <td width="100%" class="frmLRpad01" valign="top">
			    <textarea rows="5" id="i_comment" name="i_comment" class="box" style="width:100%" cols="20"></textarea>
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
   if (rejectStatus.equalsIgnoreCase("Y") || rejectComment.length()>0) {
			%>

<br style="font-size:10pt">
			            <table border="0" width="100%" cellspacing="0" cellpadding="0">
			              <tr>
			                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
			                <td class="item_tab2" width="160">หมายเหตุการ RouteBack</td>
			                <td class="item_tab3"></td>
			                
            <td class="textgray">&nbsp; โดย <%=doString.DisplayThai(rejectEmploy)+" &nbsp; เมื่อวันที่ "+rejectDate%></td>
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
			    <td width="100%" class="frmLRpad01" valign="top"><%=rejectComment%>&nbsp;</td>
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
            <td width="230" class="act_tab2">
            <a href="javascript:approve_job();">
            <img border="0" src="images/act_approve.gif"
    			onmouseout=nereidFade(this,70,50,5)
                  	onmouseover=nereidFade(this,100,50,5)
                  	style="cursor:hand;FILTER: alpha(opacity=70)" width="70" height="27"></a> &nbsp;
            <a href="javascript:reject_job();">
            <img border="0" src="images/act_reject.gif" 
    			onmouseout=nereidFade(this,70,50,5)
                  	onmouseover=nereidFade(this,100,50,5)
                  	style="cursor:hand;FILTER: alpha(opacity=70)" width="70" height="27"></a>
					&nbsp;
            </td>
            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="SERV_INFStaff_List.jsp?itmType=<%=itmType%>"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="SERV_Index.jsp" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
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
<input type="hidden" name="share_mnth" value="">
</FORM>
</BODY>
</HTML>
<%
		stmt.close();
		conn.close();
		stmt=null;
		conn=null;

	} catch (Exception e) {
		System.out.println("ERROR SERV_INFStaff_Conf.jsp : " + e.getMessage());
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
