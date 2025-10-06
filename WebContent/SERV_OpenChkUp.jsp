<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ include file="confirmLogin.jsp" %>
<%!
	// Caching the DataSource - It is obtained in the jspInit() method
	private javax.sql.DataSource ds = null;
	private String dsName = Constants.JDBC_LAN;
	private String month[] = {"มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
	private void getDS() throws NamingException {
		// Note the new Initial Context Factory interface available in WebSphere 4.0
		Hashtable parms = new Hashtable();
		parms.put(Context.INITIAL_CONTEXT_FACTORY, "com.ibm.websphere.naming.WsnInitialContextFactory");
		InitialContext ctx = new InitialContext(parms);

		// Perform a naming service lookup to get the DataSource object.
		ds = (javax.sql.DataSource) ctx.lookup(dsName);
		ctx.close();

	}	
	
	// This Happens Once and is Reused
	public void jspInit() {
		try
		{
			getDS();
		}
		catch(Exception es)
		{
		  es.printStackTrace();
		}
	}
	public String getStatus(String status) {
		if (status.equals("N")) {
			status = "รอบันทึกนัด";
		}
		if (status.equals("D")) {
			status = "ยกเลิกนัด";
		}
		if (status.equals("R")) {
			status = "บันทึกนัดแล้ว";
		}
		if (status.equals("O")) {
			status = "Open Job";
		}
		if (status.equals("S")) {
			status = "Start Task";
		}
		if (status.equals("C")) {
			status = "Complete Task";
		}
		return status;		
		
	}
%>
<HTML>
<HEAD>
<TITLE>INF Open Job List</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
<!--


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
/*	 
	if (document.forms[0].Project.value == "") {
		alert("โปรดเลือกโครงการ");
		return false;
	}
*/
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

	function pleasewait() {
		if (document.getElementById) { // DOM3 = IE5, NS6
			document.getElementById ('hidepage').style.visibility = 'hidden';
		} else {
			if (document.layers) { // Netscape 4
				document.hidepage.visibility = 'hidden';
			}  else { // IE 4 document.all.hidepage.style.visibility = 'hidden';
			}
		}
	}

	function progress() {
		if (document.getElementById) { // DOM3 = IE5, NS6
			document.getElementById ('hidepage').style.visibility = '';
		} else {
			if (document.layers) { // Netscape 4
				document.hidepage.visibility = '';
			}  else { // IE 4 document.all.hidepage.style.visibility = 'hidden';
			}
		}
	}  

  function Go(frm, order) {
  		frm.order.value = order;
     if (validDate()) {
		 progress();
		 frm.action="/LHServ/InitOpenChkupServlet";
		 frm.target="";
    	 frm.submit();
     }
  }
  
	function chckAll(frm){
		var i = 0;
		var numlock = eval(frm.num_lock.value);
		if ( numlock == 1)
		{
			frm.chkLock.checked = frm.selAll.checked;
		} else {
			while( i < numlock)
			{
				frm.chkLock[i].checked = frm.selAll.checked;
				i++;
			}
		}
	}  
  
  
  function OpenJob(frm) {
	var numlock = parseInt(frm.num_lock.value);
	var lockId = "";
	var docNo = "";
	var status = "";
	var venId = "";
	var check = false;

	for (i=0; i<numlock; i++) {

		if (numlock == 1) {
			if (frm.chkLock.checked) {
				check = true;
				lockId = frm.chkLock.value;
				venId = eval("frmOpenChkup.V" + lockId + ".value");
				lockId = lockId.substring(0,10);
				docNo = frm.jobNo.value;
				status = frm.status.value;
				if (status != "R") {
					alert("แปลง "+lockId+" ได้เปิด Job ไปแล้ว");
					return;
				}
/*
				if (docNo != "") {
					alert("แปลง "+lockId+" ได้เปิด Job ไปแล้ว");
					return;
				}
*/
				if (venId == "") {
					alert("โปรดระบุผู้รับเหมา แปลง "+lockId);
					return;
				}
			}
		} else {
			if (frm.chkLock[i].checked) {
				check = true;
				lockId = frm.chkLock[i].value;
				venId = eval("frmOpenChkup.V" + lockId + ".value");
				lockId = lockId.substring(0,10);
/*
				docNo = frm.jobNo[i].value;
				if (docNo != "") {
					alert("แปลง "+lockId+" ได้เปิด Job ไปแล้ว");
					return;
				}
*/
				status = frm.status[i].value;
/*
				if (status != "R") {
					alert("แปลง "+lockId+" ได้เปิด Job ไปแล้ว");
					return;
				}
*/
				if (venId == "") {
					alert("โปรดระบุผู้รับเหมา แปลง "+lockId);
					return;
				}
			}
		}	
	}// end for	
	if (!check) {
		alert("โปรดระบุแปลง");
		return;
	}
	progress();
  	frm.action="/LHServ/OpenChkupJobServlet";
  	frm.target="";
  	frm.submit();
  }
  
  function CancelJob(frm) {
	var numlock = parseInt(frm.num_lock.value);
	var check = false;
	var lockId = "";
	var code = "";
	var docNo = "";
	var cancelId = "";
	var status = "";
	for (i=0; i<numlock; i++) {
		if (numlock == 1) {
			if (frm.chkLock.checked) {
				check = true;
				lockId = frm.chkLock.value;
				cancelId = eval("frmOpenChkup.C" + lockId + ".value");
				lockId = lockId.substring(0,10);
				status = frm.status.value;
				if (status == "C") {
					alert("แปลง "+lockId+" ไม่สามารถยกเลิกนัดได้");
					return;
				}
				if (cancelId == "") {
					alert("โปรดระบุสาเหตุการยกเลิก แปลง "+lockId);
					return;
				}
			}
		} else {
			if (frm.chkLock[i].checked) {
				check = true;
				code = frm.chkLock[i].value;
				lockId = lockId.substring(0,10);
				
				status = frm.status[i].value;
				if (status == "C") {
					alert("แปลง "+lockId+" ไม่สามารถยกเลิกนัดได้");
					return;
				}
				cancelId = eval("frmOpenChkup.C" + code + ".value");
				if (cancelId == "") {
					alert("โปรดระบุสาเหตุการยกเลิก แปลง "+lockId);
					return;
				}
			}
		}	
	}// end for
	if (!check) {
		alert("โปรดระบุแปลง");
		return;
	}
	progress();
  	frm.action="/LHServ/CancelChkupJobServlet";
  	frm.target="";
  	frm.submit();
  }  
  
  function doCancel(){
    alert('ไม่สามารถยกเลิกรายการได้ กรุณาติดต่อ Service Center เพื่อทำรายการยกเลิก !!!');
  }


  function StartTask(frm) {
	var numlock = parseInt(frm.num_lock.value);
	var check = false;
	var num_chck = 0;
	var lockId = "";
	var docNo = "";
	var status = "";
	for (i=0; i<numlock; i++) {
		if (numlock == 1) {
			if (frm.chkLock.checked) {
				check = true;
				lockId = frm.chkLock.value;
				lockId = lockId.substring(0,10);
				status = frm.status.value;
				if (status != "O") {
					alert("แปลง "+lockId+" ยังไม่ได้ทำการเปิด Job");
					return;
				}
/*
				docNo = frm.jobNo.value;
				if (docNo == "") {
					alert("แปลง "+lockId+" ยังไม่ได้ทำการเปิด Job");
					return;
				}
*/
			}
		} else {
			if (frm.chkLock[i].checked) {
				check = true;
				lockId = frm.chkLock[i].value;
				lockId = lockId.substring(0,10);
				status = frm.status[i].value;
				if (status != "O") {
					alert("แปลง "+lockId+" ยังไม่ได้ทำการเปิด Job");
					return;
				}
/*
				docNo = frm.jobNo[i].value;
				if (docNo == "") {
					alert("แปลง "+lockId+" ยังไม่ได้ทำการเปิด Job");
					return;
				}
*/
			}
		}	
	}// end for
	if (!check) {
		alert("โปรดระบุแปลง");
		return;
	}
  	frm.action="/LHServ/StartChkupJobServlet";
	frm.target="";
  	frm.submit();
  }  
  
  function CompleteJob(frm) {
	var numlock = parseInt(frm.num_lock.value);
	var check = false;
	var num_chck = 0;
	var status = "";
	var docNo = "";
	for (i=0; i<numlock; i++) {
		if (numlock == 1) {
			if (frm.chkLock.checked) {
				check = true;
				lockId = frm.chkLock.value;
				lockId = lockId.substring(0,10);
				status = frm.status.value;
				if (status != "S") {
					alert("แปลง "+lockId+" ยังไม่ได้ทำการ Start Task");
					return;
				}
			}
		} else {
			if (frm.chkLock[i].checked) {
				check = true;
				lockId = frm.chkLock[i].value;
				lockId = lockId.substring(0,10);
				status = frm.status[i].value;
				if (status != "S") {
					alert("แปลง "+lockId+" ยังไม่ได้ทำการ Start Task");
					return;
				}
			}
		}	
	}// end for
	if (!check) {
		alert("โปรดระบุแปลง");
		return;
	}
  	frm.action="/LHServ/CompleteChkupJobServlet";
	frm.target="";
  	frm.submit();
  }  
  

  function PrintJob(frm) {
	var numlock = parseInt(frm.num_lock.value);
	var check = false;
	var num_chck = 0;
	var lockId = "";
	var docNo = "";
	var j=0;
	var status = "";
	frm.i_docno.length = 0;
	for (i=0; i<numlock; i++) {
		if (numlock == 1) {
			if (frm.chkLock.checked) {
				check = true;
				lockId = frm.chkLock.value;
				lockId = lockId.substring(0,10);
/*
				docNo = frm.jobNo.value;
				if (docNo == "") {
					alert("แปลง "+lockId+" ยังไม่ได้ทำการเปิด Job");
					return;
				}
*/
				docNo = frm.jobNo.value;
				status = frm.status.value;
				if (status == "R") {
					alert("แปลง "+lockId+" ยังไม่ได้ทำการเปิด Job");
					return;
				}
				var Box = new Option();
				Box.value = docNo;
				Box.text = docNo;
				frm.i_docno[j] = Box;
				j++;
			}
		} else {
			if (frm.chkLock[i].checked) {
				check = true;
				lockId = frm.chkLock[i].value;
				lockId = lockId.substring(0,10);
/*
				docNo = frm.jobNo[i].value;
				if (docNo == "") {
					alert("แปลง "+lockId+" ยังไม่ได้ทำการเปิด Job");
					return;
				}
*/
				status = frm.status[i].value;
				if (status == "R") {
					alert("แปลง "+lockId+" ยังไม่ได้ทำการเปิด Job");
					return;
				}
				docNo = frm.jobNo[i].value;
				var Box = new Option();
				Box.value = docNo;
				Box.text = docNo;
				frm.i_docno[j] = Box;
				j++;

			}
		}	
	}// end for
	if (!check) {
		alert("โปรดระบุแปลง");
		return;
	}
	for (i=0;i < frm.i_docno.options.length; i++)
	{
		frm.i_docno.options[i].selected = true;
	}

  	//frm.action="http://www9.lh.co.th/LHServ/SERV_PrintOpenJobServlet";
	frm.action="/LHServ/SERV_PrintOpenJobServlet";
	frm.target="_blank";
  	frm.submit();
  }  

  function Export(frm) {
  	frm.action="/LHServ/ExportOpenChkupServlet";
	frm.target="";
  	frm.submit();
  }  
//-->
</script>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="pleasewait();">
<div id="hidepage" style="position: absolute; left:300px; top:100px; background-color: white; layer-background-color: white; height: 10%; width: 30%;">
<table width=100%><tr><td valign=middle align=middle><div id="a1">Page loading ... Please wait...</div></td></tr></table></div>
<FORM NAME="frmOpenChkup" METHOD=POST ACTION="/LHServ/InitOpenChkupServlet">
<input type="hidden" name="order" value="">
<select multiple size="1" name="i_docno" style="width:2;">
</select>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
		<td width="100%" class="BD">
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="50%" class="bigh"><img border="0"
					src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
				Open Job</td>
				<td width="50%" align="right"></td>
			</tr>
		</table>
		<br style="font-size:10pt">
<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String empId = user.getEmpId();
String empName = "";
String comId = "";
String projId = "";
String code = "";
if (!doString.checkString(request.getParameter("Project")).equals("")) {
	comId = request.getParameter("Project").substring(0,2);
	projId = request.getParameter("Project").substring(2);
}
code = comId + projId;

String order = doString.checkString(request.getParameter("order"), "i_company, i_project, i_lock");

String brand = "";
Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
String venId = "";
Vector vendor_list = new Vector(5);
Vector cancel_list = new Vector(5);
doString str = new doString();
String optionSelected = "";
int i=0;
int j=0;
StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
Statement ustmt = null;
Statement vstmt = null;
ResultSet rs = null;
ResultSet rsChkup = null;
ResultSet rsVendor = null;
SERV_CommonData common = null;
try {
	if (ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	ustmt = conn.createStatement();
	vstmt = conn.createStatement();
	common = new SERV_CommonData(conn);
/*	
	if (userId.equals("pop")) {
	        String docNo = "";
	        String jobDate = "";
	        rs = stmt.executeQuery("select distinct l.i_docno, d.d_chckup from lan:serv_chkuplck l, lan:serv_chkupdt d where l.f_status != 'R' and l.f_status != 'D' and l.i_company = d.i_company and l.i_project = d.i_project and l.i_lock = d.i_lock and l.i_chkseq = d.i_chkseq");
	        if (rs != null) {
	        	while (rs.next() == true) {
	        		docNo = doString.checkString(rs.getString("I_DOCNO"));
	        		jobDate = doString.checkString(rs.getString("D_CHCKUP"));
System.out.println(docNo+":"+jobDate);
	        		ustmt.executeUpdate("UPDATE lan:serv_dochd SET d_job = '"+jobDate+"', d_appoint = '"+jobDate+"', d_est_close = '"+jobDate+"' WHERE i_docno = '"+docNo+"'");
	        	}
	        	rs.close();
	        	rs=null;
	        }	
	}	
*/	
	String startDate = common.getValueFromDateListbox("start",request);
	String endDate = common.getValueFromDateListbox("end",request);
	if (startDate.length()<=0 && endDate.length()<=0)  {
		Calendar start = Calendar.getInstance(Locale.ENGLISH);
		int syear = start.get(Calendar.YEAR);
		if (syear>2400) syear -= 543;
		start.set(syear,start.get(Calendar.MONTH),1);
		
		
		Calendar end = Calendar.getInstance(Locale.ENGLISH);
		int eyear = end.get(Calendar.YEAR);
		if (eyear>2400) eyear -= 543;
		end.set(eyear,end.get(Calendar.MONTH)+1,1);
		end.add(Calendar.DATE,-1);
		
		startDate = start.get(Calendar.YEAR)+"-"+str.createID(start.get(Calendar.MONTH)+1,2)+"-"+str.createID(start.get(Calendar.DATE),2);
		endDate = end.get(Calendar.YEAR)+"-"+str.createID(end.get(Calendar.MONTH)+1,2)+"-"+str.createID(end.get(Calendar.DATE),2);
	}	
	rs = stmt.executeQuery("SELECT TRIM(n_prename_th) || ' ' || TRIM(n_nemploy_th) || ' ' || TRIM(n_semploy_th) AS EMP_NAME FROM docflow:acemploy WHERE i_employ = '"+empId+"'");
	if (rs != null) {
		if (rs.next() == true) {
			empName = doString.checkString(rs.getString(1));
		}
		rs.close();
		rs=null;
	}		
/*
	j=0;
	vendor_list.removeAllElements();
	rs = stmt.executeQuery("SELECT p.i_vendor, v.bus_name FROM lan:serv_venprj p, lan:stpvendr v WHERE p.i_company = '"+comId+"' AND p.i_project = '"+projId+"' AND p.i_type = '01' AND p.i_vendor = v.vend_code ORDER BY v.bus_name");
	if (rs != null) {
		while (rs.next() == true) {
			venId = doString.checkString(rs.getString(1));
			rsVendor = vstmt.executeQuery("SELECT i_vendor FROM lan:serv_venprj WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND (i_type = '03' OR i_type = '04') AND i_vendor = '"+venId+"'");
			if (rsVendor.next() == false) {
				Vendor aVendor = new Vendor();
				aVendor.setId(venId);
				aVendor.setName(doString.checkString(rsVendor.getString("BUS_NAME")));
				vendor_list.add(i, aVendor);
				j++;
			}
			rsVendor.close();
			rsVendor=null;	
		}// end while
		rs.close();
		rs=null;
	}
*/
	i=0;
	rs = stmt.executeQuery("SELECT i_code, n_desc FROM lan:serv_xstd WHERE i_type = '67' ORDER BY i_code");
	if (rs != null) {
		while (rs.next() == true) {
			Vendor aCancel = new Vendor();
			venId = doString.checkString(rs.getString(1));
			aCancel.setId(venId);
			aCancel.setName(doString.checkString(rs.getString("N_DESC")));
			cancel_list.add(i, aCancel);
			i++;
		}// end while
		rs.close();
		rs=null;
	}
	i=0;
%>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td class="item_tab1"><img border="0" src="images/i_i.gif"
					align="absmiddle" width="20" height="20"></td>
				<td class="item_tab2" width="200">เลือกแปลง</td>
				<td class="item_tab3"></td>
				<td>&nbsp;</td>
			</tr>
		</table>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="5" valign="top"><img border="0"
					src="images/Corn01.gif" width="5" height="5"></td>
				<td class="frmTop">&nbsp;</td>
				<td width="5" valign="top" align="right"><img border="0"
					src="images/Corn02.gif" width="5" height="5"></td>
			</tr>
		</table>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="100%" class="frmLR" align="center">
				<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						<td class="item ; dotline01" height="22" width="12%">ชื่อเจ้าหน้าที่
						:</td>
						<td height="22" width="42%" class="dotline01"><%=doString.DisplayThai(empName)%></td>
						<td height="22" class="item ; dotline01" width="5%">&nbsp;</td>
						<td height="22" width="41%" class="dotline01">&nbsp;</td>
					</tr>
					<tr>
						<td height="22" class="item ; dotline01" width="5%">โครงการ :</td>
						<td height="22" width="42%" class="dotline01"><select
							name='Project' class='box' style='width:250px' onChange="Go(frmOpenChkup, 'i_company, i_project, i_lock');">
							<option value=''>------ กรุณาเลือก ------</option>
							<option value='LHALL' <%if(code.equals("LHALL")){ out.print("selected"); }%>>------ ทุกโครงการ ------</option>
<%
	sql.delete(0, sql.length());
	sql.append("SELECT DISTINCT proj.i_company || proj.i_project AS SITE, proj.n_project FROM lan:acxprojt proj, lan:acsbudgh bud");
	rs = stmt.executeQuery("SELECT proj_id FROM lan:serv_pstaff WHERE user_id = '" + userId + "' AND proj_id = 'ALL'");
	if (rs.next() == false) {
		sql.append(", lan:serv_pstaff staff WHERE proj.i_company = staff.com_id AND proj.i_project = staff.proj_id AND staff.user_id = '")
			.append(userId + "' AND");
	} else {
		sql.append(" WHERE");
	}
	rs.close();
	rs=null;
	sql.append(" bud.i_company = proj.i_company AND bud.i_project = proj.i_project AND bud.d_year = '" + cur_year + "' ORDER BY SITE");
	rs = stmt.executeQuery(sql.toString());
	while (rs.next() == true) {
		optionSelected = "";
		if (rs.getString("SITE").equals(code) )
		{
			optionSelected = "selected";
		}
%>
              <OPTION value="<%=rs.getString("SITE")%>" <%=optionSelected%>><%=rs.getString("SITE")%> <%=doString.DisplayThai(doString.checkString(rs.getString("N_PROJECT")))%></OPTION>
<%
	}
	rs.close();
	rs=null;
%>									
						</select></td>
						<td height="22" class="item ; dotline01" width="5%">&nbsp;</td>
						<td height="22" width="41%" class="dotline01">&nbsp;</td>
					</tr>
					<tr>
						<td class="item ; dotline01" height="22" width="12%">วันนัด
						Check up ตั้งแต่วันที่ :</td>
						<td height="22" width="42%" class="dotline01">
						<p>
<%
	int nowYear = Calendar.getInstance(Locale.ENGLISH).get(Calendar.YEAR);
    if (nowYear>2400) nowYear -= 543;
	out.println(common.genDateOfMonthListbox("start_date",(startDate.length()==10 ? startDate.substring(8,10) : "")," class='box' "));
	out.println(common.genMonthListbox("start_month",(startDate.length()==10 ? startDate.substring(5,7) : "")," class='box' "));
	out.println(common.genYearListbox("start_year",(startDate.length()==10 ? startDate.substring(0,4) : "")," class='box' ",nowYear-3,5));
%>																		
						&nbsp;&nbsp;ถึง :&nbsp;&nbsp;

<%
	out.println(common.genDateOfMonthListbox("end_date",(endDate.length()==10 ? endDate.substring(8,10) : "")," class='box' "));
	out.println(common.genMonthListbox("end_month",(endDate.length()==10 ? endDate.substring(5,7) : "")," class='box' "));
	out.println(common.genYearListbox("end_year",(endDate.length()==10 ? endDate.substring(0,4) : "")," class='box' ",nowYear-3,5));
%>						
						&nbsp;<a href="javascript:Go(frmOpenChkup, 'i_lock')"><img border="0" src="images/bu_go.gif"
							align="absmiddle" width="40" height="22"></a>
						</td>
						<td height="22" class="item ; dotline01" width="5%">&nbsp;</td>
						<td height="22" width="41%" class="dotline01">&nbsp;</td>
					</tr>
				</table>
				</td>
			</tr>
		</table>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="5" valign="bottom"><img border="0"
					src="images/Corn03.gif" width="5" height="5"></td>
				<td class="frmBottom">&nbsp;</td>
				<td width="5" valign="bottom" align="right"><img border="0"
					src="images/Corn04.gif" width="5" height="5"></td>
			</tr>
		</table>
		<br style="font-size:10pt">
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td class="item_tab1"><img border="0" src="images/i_i.gif"
					align="absmiddle" width="20" height="20"></td>
				<td class="item_tab2" width="160">รายการแปลงขาย</td>
				<td class="item_tab3"></td>
				<td>&nbsp;</td>
			</tr>
		</table>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="5" valign="top" bgcolor="#D7E6FF"><img border="0"
					src="images/Corn01.gif" width="5" height="5"></td>
				<td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
				<td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img
					border="0" src="images/Corn02.gif" width="5" height="5"></td>
			</tr>
		</table>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="100%" class="frmL">
				<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						<td width="3%" class="col_name"><INPUT type="checkbox" name="selAll" onClick="javascript:chckAll(frmOpenChkup);"></td>
						<td width="4%" class="col_name">โครงการ</td>
						<td width="4%" class="col_nameO"><a href="javascript:Go(frmOpenChkup, 'i_company, i_project, i_lock');">แปลง</a>
<%
	if (order.equals("i_company, i_project, i_lock")) {
		out.print("&nbsp;<img src=\"images/i_down.gif\" width=\"9\" height=\"9\">");
	}
%>							
						</td>
						<td width="4%" class="col_nameO"><a href="javascript:Go(frmOpenChkup, 'i_chkseq, i_company, i_project, i_lock');">ครั้งที่</a>
<%
	if (order.equals("i_chkseq, i_company, i_project, i_lock")) {
		out.print("&nbsp;<img src=\"images/i_down.gif\" width=\"9\" height=\"9\">");
	}
%>							
						</td>
						<td width="8%" class="col_nameO"><a href="javascript:Go(frmOpenChkup, 'd_chckup, i_time, i_chkseq, i_company, i_project, i_lock');">วันนัด Check up</a>
<%
	if (order.equals("d_chckup, i_time, i_chkseq, i_company, i_project, i_lock")) {
		out.print("&nbsp;<img src=\"images/i_down.gif\" width=\"9\" height=\"9\">");
	}
%>							
						
						</td>						
						<td width="8%" class="col_name">เวลานัด Check up</td>
						<td width="8%" class="col_name">เลขที่ใบแจ้งนัด</td>
						<td width="7%" class="col_nameO"><a href="javascript:Go(frmOpenChkup, 'i_status, i_chkseq, i_company, i_project, i_lock');">สถานะ</a>
<%
	if (order.equals("i_status, i_chkseq, i_company, i_project, i_lock")) {
		out.print("&nbsp;<img src=\"images/i_down.gif\" width=\"9\" height=\"9\">");
	}
%>							
						</td>
						<td width="14%" class="col_name">ผรม.ซ่อม</td>
						
						<td width="7%" class="col_name">บ้านเลขที่</td>
						<td width="15%" class="col_name">ชื่อลูกค้า</td>
						<td width="12%" class="col_name">เบอร์โทรศัพท์</td>
						<td width="6%" class="col_name">สาเหตุ</td>
					</tr>
<%
	String docNo = "";
	String lockId = "";
	String chkDate = "";
	String time = "";
	String status = "";
	String comment = "";
	int seqNo = 0;
	int num_lock = 0;
	i=0;
	rsChkup = ustmt.executeQuery("SELECT * FROM lan:serv_chklock WHERE i_session = "+sessionId+" ORDER BY "+order);
	if (rsChkup != null) {
		while (rsChkup.next() == true) {
			i++;
			docNo = doString.checkString(rsChkup.getString("I_DOCNO"));			
			comId = doString.checkString(rsChkup.getString("I_COMPANY"));
			projId = doString.checkString(rsChkup.getString("I_PROJECT"));
			lockId = doString.checkString(rsChkup.getString("I_LOCK"));
			seqNo = rsChkup.getInt("I_CHKSEQ");
			status = doString.checkString(rsChkup.getString("F_STATUS"));			
			chkDate = doString.checkString(rsChkup.getString("D_CHCKUP"));			
			comment = doString.checkString(rsChkup.getString("C_COMMENT"));			
			brand = "";
			rs = stmt.executeQuery("SELECT i_brand FROM lan:serv_brand WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
			if (rs != null) {
				if (rs.next() == true) {
					brand = doString.checkString(rs.getString(1));
				}
				rs.close();
				rs=null;
			}			

			time = "";
			if (doString.checkString(rsChkup.getString("I_TIME")).equals("-")) {
				time = "-";						
			} else {
				rs = stmt.executeQuery("SELECT n_time FROM lan:serv_btime WHERE i_brand = '"+brand+"' AND i_time = '"+doString.checkString(rsChkup.getString("I_TIME"))+"'");
				if (rs != null) {
					if (rs.next() == true) {
						time = doString.checkString(rs.getString("N_TIME"));		
					}
					rs.close();
					rs=null;
				}					
			}
%>					
					<tr>
						<td width="3%" align="center" class="dotline">
<%
			if (rsChkup.getInt("I_STATUS") == 6) {
				//out.print("&nbsp;");
				num_lock++;
%>
						<input type="checkbox" name="chkLock" value="<%=comId%><%=projId%><%=lockId%><%=seqNo%>">
						<input type="hidden" name="jobNo" value="<%=docNo%>">
						<input type="hidden" name="status" value="<%=status%>">
<%
			} else {
				num_lock++;
%>
						<input type="checkbox" name="chkLock" value="<%=comId%><%=projId%><%=lockId%><%=seqNo%>">
						<input type="hidden" name="jobNo" value="<%=docNo%>">
						<input type="hidden" name="status" value="<%=status%>">
<%			
			}
%>							
						</td>
						<td width="4%" align="center" class="dotline"><%=comId%><%=projId%></td>
						<td width="4%" class="dotline ; item" align="center"><%=lockId%></td>
						<td width="4%" class="dotline" align="center"><%=seqNo%></td>
						<td width="8%" align="center" class="dotline"><%=DateUtil.ifxToThaiDateNoTime(chkDate)%></td>						
						<td width="8%" align="center" class="dotline"><%=doString.DisplayThai(time)%></td>
						<td width="8%" align="center" class="dotline"><%=docNo%></td>
						<td width="7%" align="center" class="dotline"><%=doString.DisplayThai(rsChkup.getString("N_STATUS"))%></td>
						<td width="14%" class="dotline" align="left">
<%
			if (status.equals("R")) {
				j=0;
				vendor_list.removeAllElements();
				rs = stmt.executeQuery("SELECT p.i_vendor, v.bus_name FROM lan:serv_venprj p, lan:stpvendr v WHERE p.i_company = '"+comId+"' AND p.i_project = '"+projId+"' AND p.i_type = '01' AND p.i_vendor = v.vend_code ORDER BY v.bus_name");
				if (rs != null) {
					while (rs.next() == true) {
						venId = doString.checkString(rs.getString(1));
						rsVendor = vstmt.executeQuery("SELECT i_vendor FROM lan:serv_venprj WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND (i_type = '03' OR i_type = '04') AND i_vendor = '"+venId+"'");
						if (rsVendor.next() == false) {
							Vendor aVendor = new Vendor();
							aVendor.setId(venId);
							aVendor.setName(doString.checkString(rs.getString("BUS_NAME")));
							vendor_list.add(j, aVendor);
							j++;
						}
						rsVendor.close();
						rsVendor=null;	
					}// end while
					rs.close();
					rs=null;
				}
%>						
						<select name='V<%=comId%><%=projId%><%=lockId%><%=seqNo%>' class='box' style='width:200px'>
						<option value=''>------ กรุณาเลือก ------</option>
<%
				if (vendor_list != null) {
					for (int v=0; v<vendor_list.size(); v++) {
						Vendor aVendor = (Vendor)vendor_list.elementAt(v);
						if (aVendor != null) {
%>
						<option value='<%=aVendor.getId()%>'><%=doString.DisplayThai(aVendor.getName())%></option>
<%					
						}
					}// end for
				}
%>
						</select>
<%				
			} else {
				rs = stmt.executeQuery("SELECT ven_no FROM lan:vendor WHERE ven_name = '"+doString.checkString(rsChkup.getString("VEN_NAME"))+"'");
				if (rs != null) {
					if (rs.next() == true) {
%>
				<input type="hidden" name="V<%=comId%><%=projId%><%=lockId%><%=seqNo%>" value="<%=doString.checkString(rs.getString("VEN_NO"))%>">
<%
					}
					rs.close();
					rs=null;
				}
				out.print(doString.DisplayThai(rsChkup.getString("VEN_NAME")));						
			}
%>						
						</td>
						<td width="7%" class="dotline" align="center"><%=doString.checkString(rsChkup.getString("I_HOUSE"))%>&nbsp;</td>
						<td width="15%" align="left" class="dotline"><%=doString.DisplayThai(rsChkup.getString("N_NAME"))%>&nbsp;</td>
						<td width="12%" align="left" class="dotline"><%=doString.DisplayThai(rsChkup.getString("I_TEL"))%>&nbsp;</td>
						<td width="6%" align="center" class="dotline">
<%
			if (!status.equals("C")) {
%>			
						<select name='C<%=comId%><%=projId%><%=lockId%><%=seqNo%>' class='box' style='width:100px'>
						<option value=''>--- กรุณาเลือก ---</option>
<%
				if (cancel_list != null) {
					for (int c=0; c<cancel_list.size(); c++) {
						Vendor aCancel = (Vendor)cancel_list.elementAt(c);
						if (aCancel != null) {
%>
						<option value='<%=aCancel.getId()%>'><%=doString.DisplayThai(aCancel.getName())%></option>
<%					
						}
					}// end for
				}
%>
					</select>
<%				
			} else {
				out.print("&nbsp;");						
			}
%>						
						</td>
					</tr>
<%
			if (!comment.equals("")) {
%>
					<tr>
						<td width="3%" align="center" class="dotline">&nbsp;</td>
						<td width="4%" align="center" class="dotline">&nbsp;</td>

						<td colspan="7" align="left" class="dotline">&nbsp;&nbsp;&nbsp;&nbsp;
<img border="0" src="images/bu_nextPage.gif" align="absmiddle" width="5" height="7">&nbsp;
								            <font color="#FF6699">หมายเหตุ : <%=doString.DisplayThai(comment)%></font>
						</td>
						<td width="7%" class="dotline" align="center">&nbsp;</td>
						<td width="15%" align="left" class="dotline">&nbsp;</td>
						<td width="12%" align="center" class="dotline">&nbsp;</td>
						<td width="6%" align="center" class="dotline">&nbsp;</td>
					</tr>
<%
			}
%>

<%		
		}// end while
		rsChkup.close();
		rsChkup=null;
	}
	if (i==0) {
%>
					<tr>
						<td width="3%" align="center" class="dotline">&nbsp;</td>
						<td width="4%" align="center" class="dotline">&nbsp;</td>
						<td width="4%" class="dotline ; item" align="center">&nbsp;</td>
						<td width="4%" class="dotline" align="center">&nbsp;</td>
						<td width="8%" align="center" class="dotline">&nbsp;</td>						
						<td width="8%" align="center" class="dotline">&nbsp;</td>
						<td width="8%" align="center" class="dotline">&nbsp;</td>
						<td width="7%" align="center" class="dotline">&nbsp;</td>
						<td width="14%" class="dotline" align="left">&nbsp;</td>
						<td width="7%" class="dotline" align="center">&nbsp;</td>
						<td width="15%" align="left" class="dotline">&nbsp;</td>
						<td width="12%" align="center" class="dotline">&nbsp;</td>
						<td width="6%" align="center" class="dotline">&nbsp;</td>
					</tr>
<%
	}
%>						
				</table>
				</td>
			</tr>
		</table>
		<INPUT type="hidden" name="num_lock" value="<%=num_lock%>">
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="5" valign="bottom"><img border="0"
					src="images/Corn03.gif" width="5" height="5"></td>
				<td class="frmBottom">&nbsp;</td>
				<td width="5" valign="bottom" align="right"><img border="0"
					src="images/Corn04.gif" width="5" height="5"></td>
			</tr>
		</table>
<%
		ustmt.close();
		vstmt.close();
		stmt.close();
		conn.close();
		stmt = null;
		ustmt = null;
		vstmt = null;
		conn=null;
	} catch (Exception e) {
		System.out.println("ERROR SERV_OpenChkUp.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (stmt != null) stmt.close();
			if (ustmt != null) ustmt.close();
			if (vstmt != null) vstmt.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
		%> <br style="font-size:10pt">
		<table border="0" width="100%" cellspacing="0" cellpadding="0"
			height="30">
			<tr>
				<td class="act_tab1"></td>
				<td width="500" class="act_tab2">

				<a href="javascript:OpenJob(frmOpenChkup);"><img
					border="0" src="images/act_openJob.gif"
					onMouseOut=nereidFade(this,70,50,5)
					onMouseOver=nereidFade(this,100,50,5)
					style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp;

				<a href="javascript:StartTask(frmOpenChkup);"><img
					border="0" src="images/act_starttask.gif"
					onMouseOut=nereidFade(this,70,50,5)
					onMouseOver=nereidFade(this,100,50,5)
					style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp;


				<a href="javascript:CompleteJob(frmOpenChkup);"><img border="0" src="images/act_complete.gif"
					onMouseOut=nereidFade(this,70,50,5)
					onMouseOver=nereidFade(this,100,50,5)
					style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp;
				<a href="javascript:PrintJob(frmOpenChkup);"><img border="0" src="images/act_print001.gif"
					onMouseOut=nereidFade(this,70,50,5)
					onMouseOver=nereidFade(this,100,50,5)
					style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
					&nbsp;
				<a href="javascript:Export(frmOpenChkup);"><img
					border="0" src="images/act_export2excel.gif"
					onMouseOut=nereidFade(this,70,50,5)
					onMouseOver=nereidFade(this,100,50,5)
					style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
					&nbsp;
				<%-- CancelJob(frmOpenChkup);  doCancel();--%>
				<%if("2154-6".equals(user.getEmpId())){ %>
				<a href="javascript:CancelJob(frmOpenChkup);"><img border="0" src="images/act_cancelCheckUp.gif"
					onMouseOut=nereidFade(this,70,50,5)
					onMouseOver=nereidFade(this,100,50,5)
					style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
				<%}else{ %>
				<a href="javascript:doCancel();"><img border="0" src="images/act_cancelCheckUp.gif"
					onMouseOut=nereidFade(this,70,50,5)
					onMouseOver=nereidFade(this,100,50,5)
					style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
				<%} %>
					</td>
				<td class="act_tab3"></td>
				<td class="act_tab4"><a
					href="SERV_Home.jsp"><img border="0"
					src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
			</tr>
		</table>
		</td>
	</tr>
</table>
<br style="font-size:20pt">
<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
	<tr>
		<td width="100%" class="copyright" align="center">Best viewed
		with 800x600 screen resolution on&nbsp;an Internet Explorer version 5
		และ 5.5 <br>
		ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;
		หรือ โทร. 0-2230-8279 (คุณประพัฒน์ ฝ่ายบริการ)&nbsp; 0-2230-8491-5
		(ฝ่าย IT) <br>
		<img src="images/copyright.gif" width="475" height="26"></td>
	</tr>
</TABLE>
</FORM>
</BODY>
</HTML>
