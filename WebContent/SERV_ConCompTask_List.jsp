<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="serv.common.Constants"%>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%
String userId = user.getUserID();
String selProj = doString.checkString(request.getParameter("sel_project"));
String comId = "";
String projId = "";
if (!selProj.equals("")) {
	comId = selProj.substring(0,2);
	projId = selProj.substring(3);
}
String venId = doString.checkString(request.getParameter("i_vendor"));
String orderNo = doString.checkString(request.getParameter("orderNo"));
String order_restrict = "";
if (!orderNo.equals("")) {
	order_restrict = " AND h.i_docno = '"+orderNo+"'";
}
String code = "";
String value = "";
String selected = "";
StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
Statement stmt1 = null;
ResultSet rs = null;
ResultSet rs1 = null;	
SERV_CommonData common = null;
try {
	if (ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();        
	stmt1 = conn.createStatement();        
	common = new SERV_CommonData(conn);
%>
<HTML>
<HEAD>
<TITLE>ขอเบิกงวดงาน</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
<!--
var arr_keycode = new Array();
try {
	arr_keycode['8'] = "backspace";
	arr_keycode['9'] = "tab";
	arr_keycode['35'] = "end";
	arr_keycode['36'] = "home";
	arr_keycode['37'] = "left arrow";
	arr_keycode['39'] = "right arrow";
	arr_keycode['46'] = "delete";
	
	arr_keycode['48'] = "0";
	arr_keycode['49'] = "1";
	arr_keycode['50'] = "2";
	arr_keycode['51'] = "3";
	arr_keycode['52'] = "4";
	arr_keycode['53'] = "5";
	arr_keycode['54'] = "6";
	arr_keycode['55'] = "7";
	arr_keycode['56'] = "8";
	arr_keycode['57'] = "9";
	
	arr_keycode['96'] = "numpad0";
	arr_keycode['97'] = "numpad1";
	arr_keycode['98'] = "numpad2";
	arr_keycode['99'] = "numpad3";
	arr_keycode['100'] = "numpad4";
	arr_keycode['101'] = "numpad5";
	arr_keycode['102'] = "numpad6";
	arr_keycode['103'] = "numpad7";
	arr_keycode['104'] = "numpad8";
	arr_keycode['105'] = "numpad9";
	
	arr_keycode['109'] = "substract";
	arr_keycode['110'] = "decimal point";
	arr_keycode['190'] = "period";	

	
} catch(e) {
	alert(e.toString());
}

function Trim( str ) {
	var resultStr = "";
	
	resultStr = TrimLeft(str);
	resultStr = TrimRight(resultStr);
	
	return resultStr;
} // end Trim

function TrimLeft( str ) {
	var resultStr = "";
	var i = len = 0;
	
	// Return immediately if an invalid value was passed in
	if (str+"" == "undefined" || str == null)	
		return null;

	// Make sure the argument is a string
	str += "";

	if (str.length == 0) 
		resultStr = "";
	else {	
  		// Loop through string starting at the beginning as long as there
  		// are spaces.
		//	  	len = str.length - 1;
		len = str.length;
					
  		while ((i <= len) && (str.charAt(i) == " "))
			i++;
	
   	// When the loop is done, we're sitting at the first non-space char,
 		// so return that char plus the remaining chars of the string.
  		resultStr = str.substring(i, len);
  	}
			
  	return resultStr;
} // end TrimLeft
			
function TrimRight( str ) {
	var resultStr = "";
	var i = 0;
	
	// Return immediately if an invalid value was passed in
	if (str+"" == "undefined" || str == null)	
		return null;

	// Make sure the argument is a string
	str += "";
		
	if (str.length == 0) 
		resultStr = "";
	else {
  		// Loop through string starting at the end as long as there
 		// are spaces.
  		i = str.length - 1;
  		while ((i >= 0) && (str.charAt(i) == " "))
 			i--;
			 			
 			// When the loop is done, we're sitting at the last non-space char,
	 		// so return that char plus all previous chars of the string.
	  		resultStr = str.substring(0, i + 1);
	  	}
	  	
	  	return resultStr;  	
} // end TrimRight

function isCurrency(val) {
	var str="0123456789.-";
	var point = 0;
	var valOK = true;
		for (i=0; i<val.length; i++){
			if (val.charAt(i) == "."){
				point++;
			}
		}
		if (point > 1) {
			return false;
		}

		for (i=0; i<val.length & valOK; i++){
			valOK = (str.indexOf(val.charAt(i))!= -1);
		}

		if (!valOK) {
			return false;
		}
		return true;
}

function convertCurrency(obj) {
	if (Trim(obj.value) == "") {
		obj.value = "0";
	}
	obj.value = obj.value.replace(/,/g, '');
	var num = parseFloat(obj.value);
	result = Math.round(num * 100) / 100; 
	obj.value = result.toFixed(2);
}


function ResetAmount(obj) {
	var amount = Trim(obj.value);
	if (amount == "") {
		amount = "0";
	}
	if (isCurrency(amount)) {
		var p = parseFloat(amount);
		if (p == 0) {
			obj.value = "";
		}
	}
}

function checkAmount(obj, keycode) {
	if (keycode == 13) { //Enter	
		if (isCurrency(Trim(obj.value))) {
			convertCurrency(obj);
			return true;
		} else {
			obj.focus();
			return false;
		}
	} else {
		var code = "" + keycode;
		var key = Trim(arr_keycode[code]);
		if (key == null) {
			return false;
		} else {
			return true;
		} 
	}
}

	function resetSearch() {
		document.forms[0].i_vendor.value = "";
		document.forms[0].orderNo.value = "";
		document.forms[0].action="SERV_ConCompTask_List.jsp";
		document.forms[0].submit();  
	}

	function openVendor(){
		var form = document.frmPayment;
		if(form.sel_project.value == ""){
		 	alert("กรุณาเลือกโครงการ");
			return;
		}
		var project = form.sel_project.value;
		var comId = project.substring(0,2);
		var projId = project.substring(3);
		window.open('/LHServ/search_vendor2.jsp?project='+comId+projId,'','width=600,height=400,scrollbars=yes');
	}
	
	function refreshPage() {
		document.frmPayment.action = "SERV_ConCompTask_List.jsp";
		document.frmPayment.submit();
	}
		
	function searchConHD() {
		if (document.forms[0].sel_project.value == "") {
			alert("โปรดเลือกโครงการ");
			document.forms[0].sel_project.focus();
			return;
		}
		if (document.forms[0].i_vendor.value == "") {
			alert("โปรดเลือกผู้รับเหมา");
			document.forms[0].i_vendor.focus();
			return;
		}
		document.forms[0].action="SERV_ConCompTask_List.jsp";
		document.forms[0].submit();  
	}

	function checkDueAll(obj) {
		var mainChecked = obj.checked;
		var orderNo = obj.value;
		var objNumDue = document.getElementById("N"+orderNo);
		var num_due = parseInt(objNumDue.value, 10);
		var d = 1;
		while (d <= num_due) {
			var objChkDue = document.getElementById("C"+orderNo+d);
			if (objChkDue != null) {
				objChkDue.checked = mainChecked;
			}
			d++;
		}// end while
	}	

  function Save() {
		if (frmPayment.sel_project.value == "") {
			alert("โปรดเลือกโครงการ");
			frmPayment.sel_project.focus();
			return;
		}
		if (frmPayment.i_vendor.value == "") {
			alert("โปรดเลือกผู้รับเหมา");
			frmPayment.i_vendor.focus();
			return;
		}
		var objNumOrder = document.getElementById("num_order");
		var num_order = parseInt(objNumOrder.value, 10);
		var o = 0;
		var orderNo = "";
		var dueChecked = false;
		while (o <= num_order) {
			var objOrder = document.getElementById("O"+o);
			if (objOrder != null) {
				orderNo = Trim(objOrder.value);
				if (orderNo != "") {
					var objNumDue = document.getElementById("N"+orderNo);
					var num_due = parseInt(objNumDue.value, 10);
					var d = 1;
					while (d <= num_due) {
						var objChkDue = document.getElementById("C"+orderNo+d);
						if (objChkDue != null) {
							if (objChkDue.checked) {
								dueChecked = true;
								break;
							}
						}
						d++;
					}// end while
				}
			}
			o++;
		}// end while
		if (!dueChecked) {
			alert("โปรดระบุงวดงาน");
			return;
		}
		frmPayment.action="SERV_ConCompTaskServlet";
		frmPayment.submit();
  }  
//-->
</script>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM name="frmPayment" method="POST" action="">
<input type="hidden" name="itmType" value="03">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;ขอเบิกงวดงาน</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>
<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="160">สัญญา</td>
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
                  <td class="item ; dotline01" height="22" width="7%">โครงการ 
                    :</td>
                  <td height="22" width="93%" class="dotline01"><%=common.genProjectListboxByUserId(userId,"sel_project",selProj," class='box' style='width:250px' onchange='resetSearch();'")%></td>
                </tr>
                <tr> 
                  <td class="item ; dotline01" height="22" width="7%">ผู้รับเหมา 
                    :</td>
                  <td height="22" width="93%" class="dotline01"> 
                    <select size="1" name="i_vendor" class="box" style="width:250px">
                      <option value="">----- กรุณาเลือก -----</option>
                      <%
	rs = stmt.executeQuery("SELECT DISTINCT v.ven_no, v.ven_name FROM lan:serv_conhd c, lan:vendor v WHERE c.i_status = 'A' AND c.i_company = '"+comId+"' AND c.i_project = '"+projId+"' AND c.i_vendor = v.ven_no ORDER BY v.ven_no");
	if (rs != null) {
		while (rs.next() == true) {
			selected = "";
			code = doString.checkString(rs.getString("VEN_NO"));
			if (code.equals(venId)) {
				selected = "selected";
			}
%> 
                      <option value="<%=code%>" <%=selected%>><%=code%> - <%=doString.DisplayThai(doString.checkString(rs.getString("VEN_NAME")))%></option>
                      <%			
		}// end while vendor
		rs.close();
		rs=null;
	}
%> 
                    </select>
                    &nbsp;&nbsp;<a href="#" onclick="openVendor()"><img border="0" src="images/i_search.gif" align="absmiddle" ></a> 
                  </td>
                </tr>
                <tr> 
                  <td class="item ; dotline01" height="22" width="7%">เลขที่สัญญา 
                    :</td>
                  <td height="22" width="93%" class="dotline01"> 
                    <input type="text" name="orderNo" class="box" style="width:100px" value="<%=orderNo%>">
                    &nbsp;&nbsp;<A HREF="javascript:searchConHD()"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a>	
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
<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="160">รายละเอียดสัญญา</td>
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
<%
	int line = 0;
	int itmLine = 0;
	int seq_order = 0;
	String vendorName = "";
	String dueNo = "";
	String jobId = "";
	String jobDesc = "";
	String dueDesc = "";
	String dueDate = "";
	double dueAmnt = 0;
	vendorName = "";
	rs = stmt.executeQuery("SELECT ven_name FROM lan:vendor WHERE ven_no = '"+venId+"'");
	if (rs != null) {
		if (rs.next() == true) {
			vendorName = doString.DisplayThai(doString.checkString(rs.getString("VEN_NAME"))); 				
		}
		rs.close();
		rs=null;
	}
	rs = stmt.executeQuery("SELECT DISTINCT h.i_docno, h.i_job FROM lan:serv_conhd h, lan:serv_condt d WHERE h.i_status = 'A' AND h.i_company = '"+comId+"' AND h.i_project = '"+projId+"' AND h.i_vendor = '"+venId+"' "+order_restrict+" AND h.i_company = d.i_company AND h.i_project = d.i_project AND h.i_docno = d.i_docno AND d.z_accrue = 0 ORDER BY h.i_docno");
	while (rs.next() == true) {
		seq_order++;
 		orderNo = doString.checkString(rs.getString("I_DOCNO"));
 		jobId = doString.checkString(rs.getString("I_JOB"));
 		jobDesc = "";
 		rs1 = stmt1.executeQuery("SELECT n_itmjob FROM lan:serv_infboq WHERE i_itmtype = '03' AND i_seq != '0000' AND i_itmjob = '"+jobId+"'");
		if(rs1.next() == true){
			jobDesc = doString.DisplayThai(doString.checkString(rs1.getString("N_ITMJOB")));
		}
		rs1.close();
		rs1=null;
		if (line > 0) {
%>      					        
									<table border="0" width="100%" cellspacing="0" cellpadding="0">
									  <tr>
									    <td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
									    <td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
									    <td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
									  </tr>
									</table>
<%
		}
		//---=========== Get due in this i_order , i_vendor ===========---//
		itmLine = 0;
		rs1 = stmt1.executeQuery("SELECT s_due, n_job, d_pay, z_amount, z_accrue FROM lan:serv_condt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+orderNo+"' AND z_accrue = 0 ORDER BY s_due");
		while (rs1.next() == true) {
			itmLine++;
			dueNo = Integer.toString(rs1.getInt("S_DUE"));
			dueDesc = doString.checkString(doString.DisplayThai(rs1.getString("N_JOB")));
			dueDate = DateUtil.ifxToThaiDateNoTime(doString.checkString(rs1.getString("D_PAY")));
			dueAmnt = rs1.getDouble("Z_AMOUNT");
			//----============== Print Header Table ==================----//
			if (itmLine == 1) {
%>	
										<table border="0" width="100%" cellspacing="0" cellpadding="0">
										  <tr>
										    <td width="100%" class="frmL">
										      <table border="0" width="100%" cellspacing="0" cellpadding="0">
										        <tr>
										          <td width="2%" class="col_name">&nbsp;</td>
										          <td width="40%" class="col_name">ผู้รับเหมา</td>
										          <td width="10%" class="col_name">เลขที่สัญญา</td>
										          <td width="20%" class="col_name">ประเภทงาน</td>
										          <td width="10%" class="col_name">วันที่จ่ายตามสัญญา</td>
										          <td width="9%" class="col_name">จำนวนเงิน</td>
										          <td width="9%" class="col_name">ยอดเงินเพิ่ม/ลด</td>
										        </tr>
										        <tr>
										          <td width="2%" class="dotline" align="center">&nbsp;</td>
										          <td width="40%" class="dotline" align="left"><%=vendorName%></td>
										          <td width="10%" class="item ; dotline" align="center"><%=orderNo%>
										          <input type="hidden" id="O<%=seq_order%>" name="order_list" value="<%=comId%><%=projId%><%=orderNo%>">
										          </td>
										          <td width="20%" class="dotline" align="left"><%=jobDesc%></td>
										          <td width="10%" class="dotline" align="center">&nbsp;</td>
										          <td width="9%" class="dotline" align="center">&nbsp;</td>
										          <td width="9%" class="dotline" align="center">&nbsp;</td>
										        </tr>
										        <tr>
										          <td width="2%" align="center" class="dotline"><input type="checkbox" name="chkAllDue" value="<%=comId%><%=projId%><%=orderNo%>" onclick="checkDueAll(this);"></td>
										          <td width="70%" class="dotline" align="left" colspan="3"><img border="0" src="images/i_arrow2.gif" align="absmiddle" width="11" height="11">&nbsp;รายการงวดงาน</td>
										          <td width="10%" class="dotline" align="center">&nbsp;</td>
										          <td width="9%" class="dotline" align="right">&nbsp;</td>
										          <td width="9%" class="dotline" align="center">&nbsp;</td>										          
										        </tr>							        
<%                                
			} // end if check first line 
			//---============== Print Item List ================----//
			code = comId+projId+orderNo+dueNo;
%>
										        <tr>
										          <td width="2%" class="dotline" align="center"><input type="checkbox" id="C<%=comId%><%=projId%><%=orderNo%><%=itmLine%>" name="chkDue" value="<%=comId%>-<%=projId%>-<%=orderNo%>-<%=dueNo%>"></td>
										          <td width="70%" class="dotline" align="left" colspan="3"><input type="text" class="box" style="width:100%" name="D<%=code%>" value="<%=dueDesc%>"></td>
										          <td width="10%" class="dotline" align="center"><%=dueDate%></td>
										          <td width="9%" class="dotline" align="right"><%=doString.displayNumber("###,###,###.00",dueAmnt)%></td>
										          <td width="9%" class="dotline" align="center"><input type="text" id="A<%=code%>" class="boxR" style="width:80%" name="A<%=code%>" value="0" onFocus="ResetAmount(this)" onkeydown="if(checkAmount(this, event.keyCode)==false){return false;}" Onblur="checkAmount(this, 13)"></td>										          
										        </tr>
<%
		} // end while item	
		rs1.close();
		rs1=null;
		//-----============== Print Footer ================----//
%>
										<input type="hidden" id="N<%=comId%><%=projId%><%=orderNo%>" name="N<%=comId%><%=projId%><%=orderNo%>" value="<%=itmLine%>">								        
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
		line++;                         
	} //end if check rs
	rs.close();
	rs=null;
	//-----================ If No Data , Print Blank Table =================----//
	if (line == 0) {
%>	
					<table border="0" width="100%" cellspacing="0" cellpadding="0">
					  <tr>
					    <td width="100%" class="frmL">
					      <table border="0" width="100%" cellspacing="0" cellpadding="0">
										        <tr>
										          <td width="2%" class="col_name">&nbsp;</td>
										          <td width="40%" class="col_name">ผู้รับเหมา</td>
										          <td width="10%" class="col_name">เลขที่สัญญา</td>
										          <td width="20%" class="col_name">ประเภทงาน</td>
										          <td width="10%" class="col_name">วันที่จ่ายตามสัญญา</td>
										          <td width="9%" class="col_name">จำนวนเงิน</td>
										          <td width="9%" class="col_name">ยอดเงินเพิ่ม/ลด</td>
										        </tr>					      
					        <tr>
					          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
					          <td class="dotline" colspan="6" style="padding-left:20px" height="25">&nbsp;</td>
					        </tr>
					        <tr>
					          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
					          <td class="dotline" colspan="6" style="padding-left:20px" height="25">&nbsp;</td>
					        </tr>
					        <tr>
					          <td width="2%" align="center" class="solidline01" height="25">&nbsp;</td>
					          <td class="dotline" colspan="6" style="padding-left:20px" height="25">&nbsp;</td>
					        </tr>
					        <tr>
					          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
					          <td class="dotline" colspan="6" style="padding-left:20px" height="25">&nbsp;</td>
					        </tr>
					        <tr>
					          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
					          <td class="dotline" colspan="6" style="padding-left:20px" height="25">&nbsp;</td>
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
	} // end if check no data
%>  
<input type="hidden" id="num_order" name="num_order" value="<%=seq_order%>">                
<br style="font-size:5pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">
            <%if (line > 0) {%>
            <a href="javascript:Save();"><img border="0" src="images/act_send2app.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
            <%}%>&nbsp;
            </td>   
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>  
        </table>  
          </td>
        </tr>
      </table>
</FORM>	
</BODY>
</HTML>
<%
	stmt.close();
	stmt1.close();
	conn.close();
	stmt=null;
	stmt1=null;
	conn=null;
} catch (Exception e) {
	System.out.println("ERROR SERV_ConCompTask_List.jsp : " + e.getMessage());
	throw new ServletException(e.getMessage());
} finally {
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