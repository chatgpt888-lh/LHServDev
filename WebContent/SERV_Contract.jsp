<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.*" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.*" %>
<%@ include file="function.jsp" %>
<%@ include file="confirmLogin.jsp" %>
<%!
public String getEmpName(Statement stmt ,String i_employ){
	StringBuffer sql = new StringBuffer("");
	ResultSet rs = null;
	String name=  "";
	try{
		rs = stmt.executeQuery(" select n_prename_th || ' ' || n_nemploy_th || ' ' || n_semploy_th   as name from docflow:acemploy where i_employ = '"+i_employ+"' ");
		if(rs.next()){
			name = doString.checkString(rs.getString("name"),"");
		}
		rs.close();
	}catch(SQLException e){
	}finally{
		rs = null;
	}
	return name;
}
public String getEmpJob(Statement stmt ,String i_employ){
	StringBuffer sql = new StringBuffer("");
	ResultSet rs = null;
	String i_code = "";
	String n_desc = "";
	try{
		rs = stmt.executeQuery(" select i_job from docflow:acempjob where i_employ = '"+i_employ+"' order by  d_job desc ");
		if(rs.next()){
			i_code = doString.checkString(rs.getString("i_job"),"");
		}
		rs.close();
		
		rs = stmt.executeQuery(" select n_desc from docflow:acempstd where i_code = '"+i_code+"' and i_type = '10' ");
		if(rs.next()){
			n_desc = doString.checkString(rs.getString("n_desc"),"");
		}
		rs.close();
		
	}catch(SQLException e){
	}finally{
		rs = null;
	}
	return n_desc;
}
public String getApprName(Statement stmt , String i_employ_app1 , String emp_sel){
	StringBuffer sql = new StringBuffer("");
	ResultSet rs = null;
	String option = "";
	String i_employ = "";
	String selected = "";
	try{
		sql.delete(0,sql.length());
   		sql.append(" select a.* , b.n_prename_th || ' ' || b.n_nemploy_th || ' ' || b.n_semploy_th   as name ")
   			.append(" from lan:serv_rstaff a, docflow:acemploy b ")
			.append(" where a.i_employ = b.i_employ ")
			.append(" and a.i_role = '"+i_employ_app1+"' order by a.i_employ desc ");
		System.out.println(sql.toString());
		rs = stmt.executeQuery(sql.toString());
   		while(rs.next()){         
   			selected = "";
   			i_employ = doString.checkString(rs.getString("i_employ"),"");
   			if(!"".equals(emp_sel) && i_employ.equals(emp_sel)){
   				selected = "selected";
   			}
     		option = "<option value=\""+i_employ+"\" "+selected+" >"+doString.checkString(rs.getString("name"),"")+"</option>";
   		}
   		rs.close();
	}catch(SQLException e){
	}finally{
		rs = null;
	}
	return option;
  
}
	
public String genDateListbox(String name,String date, String params) throws Exception {
	if(date == null || "".equals(date) || date.length() != 10) return "";
	
	String month = date.substring(5,7);
	String year = date.substring(0,4);
	date = date.substring(8);
	
	StringBuffer html = new StringBuffer();
	doString str = new doString();
	Calendar cal = Calendar.getInstance(Locale.ENGLISH);
	String thaiMonth[] = new String[] {"มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
    
	//-------============== Generate Date List Box =================------//
	html.append("<select name='").append(name+"_date").append("' ").append(params).append(" >");
	html.append("<option value=''>- -</option>");
	for (int i=1;i<=31;i++) {
	  String value = str.createID(i,2); 
	  String selected = "";
	  if (date!=null && value.equalsIgnoreCase(date)) {
		  selected = " selected "; 
	  }		        
	        
	  html.append("<option value='").append(value).append("' ").append(selected).append(">")
			   .append(value).append("</option>");		        
	} // end for date		     
	html.append("</select> ");
	//----======================================================----//     
	
	
	//-------============== Generate Month List Box ================------//
	html.append("<select name='").append(name+"_month").append("' ").append(params).append(" >");
	html.append("<option value=''>- - - - - - - - - -</option>");
	for (int i=1;i<=12;i++) {
		  String value = str.createID(i,2); 
		  String label = thaiMonth[i-1];
		  String selected = "";
		  if (month!=null && value.equalsIgnoreCase(month)) {
			  selected = " selected "; 
		   }
	   html.append("<option value='").append(value).append("' ").append(selected).append(">")
			   .append(label).append("</option>");		        
	} // end for month		     
	html.append("</select> ");
	html.append("<select name='").append(name+"_year").append("' ").append(params).append(" >");
	html.append("<option value=''>- - - -</option>");
	int nowYear = cal.get(Calendar.YEAR);
	if (nowYear>2400) nowYear -= 543;
	for (int i=(nowYear-5);i<=(nowYear+5);i++) {
		  String value = Integer.toString(i);
		  String label = Integer.toString(i+543); 
		  String selected = "";
		  if (year!=null && value.equalsIgnoreCase(year)) {
			  selected = " selected "; 
		   }		        
	        
		 html.append("<option value='").append(value).append("' ").append(selected).append(">").append(label).append("</option>");	
	   
	} // end for year		     
	html.append("</select> ");
	return doString.MS874ToUnicode(html.toString());
}
public String docFormat(String doc){//2559050001 --> 2559-05-0001
	if(doc != null && !"".equals(doc) && doc.length() == 10){
		return doc.substring(0,4) + "-" + doc.substring(4,6) + "-" + doc.substring(6);
	}else{
		return doc;
	}
}
 %>
<%
Calendar right = Calendar.getInstance();
int dd = right.get(Calendar.DATE);
int mm = right.get(Calendar.MONTH)+1;
int yy = right.get(Calendar.YEAR);
if(yy < 2400){
	yy += 543;
}
int pYear = yy - 1;

Connection conn= null;
Statement stmt= null;
Statement stmt1= null;
ResultSet rs=null;
ResultSet rs1=null;
StringBuffer sql = new StringBuffer("");
SERV_CommonData common = null; 
doString str = new doString();
String mode = "";

String project = "";
String i_company = "";
String i_project = "";
String n_project = "";
String i_docno = "";
String search = "";
String clear = "";

String i_vendor = "";
String n_vendor = "";
String i_job = "";
String i_status = "";

int s_due = 0;
double z_due = 0;
double z_amount = 0;
String d_due = "";
String d_due_date = "";
String d_due_month = "";
String d_due_year = "";

String i_phase = "";
String contract_no = "";

String startDate = "";
String endDate = "";
String selected = "";
String c_comment = "";
String from_data = "N";

List apprList = null;
String disabled = "";
try{
	if(ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	stmt1 = conn.createStatement();
	
	
	common = new SERV_CommonData(conn);     
    //----=======================================----//   
    

    //---====================== Generate Serrch Condition ===========================---//
    startDate = common.getValueFromDateListbox("start",request);
    endDate = common.getValueFromDateListbox("end",request);
    
    project = doString.checkString(request.getParameter("project"),"");
	if(!"".equals(project)){
		i_company = project.substring(0,2);
		i_project = project.substring(2);
	}
	i_docno = doString.checkString(request.getParameter("i_docno"),"");
	search = doString.checkString(request.getParameter("search"),"N");
	clear = doString.checkString(request.getParameter("clear"),"N");
	mode = doString.checkString(request.getParameter("mode"),"ADD");
	if(!"".equals(i_docno) 		// have i_docno
		&& !"Y".equals(search) 	// not search
		&& !"Y".equals(clear)){ // not clear
		mode = "UPDATE";
		from_data = "Y";
		sql.delete(0,sql.length());
		sql.append("select * from lan:serv_conhd ")
			.append(" where i_company = '"+i_company+"' ")
			.append(" and i_project = '"+i_project+"' ")
			.append(" and i_docno = '"+i_docno+"' ")
			.append(" and i_status = 'N' ");
		rs = stmt.executeQuery(sql.toString());
		if(rs.next()){
			i_job = doString.checkString(rs.getString("i_job"),"");
			i_vendor = doString.checkString(rs.getString("i_vendor"),"");
			i_phase = doString.checkString(rs.getString("i_phase"),"");
			contract_no = doString.checkString(rs.getString("contract_no"),"");
			
		    s_due = Integer.parseInt(doString.checkString(rs.getString("s_due"),"0"));
		    z_due = Double.parseDouble(doString.checkString(rs.getString("z_due"),"0.00"));
		    
		    d_due = doString.checkString(rs.getString("d_due"),"");
		    if(!"".equals(d_due)){
				d_due_date = d_due.substring(8);
				d_due_month = d_due.substring(5,7);
				d_due_year = d_due.substring(0,4);
			}
			startDate = doString.checkString(rs.getString("d_begin"),"");
			endDate = doString.checkString(rs.getString("d_end"),"");
			z_amount = rs.getDouble("z_amount");
			c_comment = doString.checkString(rs.getString("c_comment"),"");
			c_comment = str.replace(c_comment,"|break|","\n");
		}
		rs.close();
		
		sql.delete(0,sql.length());
        sql.append(" select ven_name from lan:vendor ")
            .append(" where ven_no = '"+i_vendor+"' ");
       	rs = stmt.executeQuery(sql.toString());
        if(rs.next()){
        	n_vendor = doString.checkString(rs.getString("ven_name"),"");
        }
        rs.close();
	}
	if("Y".equals(search) || "Y".equals(clear)){
		i_job = doString.checkString(request.getParameter("i_job"),"");
		i_vendor = doString.checkString(request.getParameter("i_vendor"),"");
		n_vendor = doString.checkString(request.getParameter("n_vendor"),"");
		i_phase = doString.checkString(request.getParameter("i_phase"),"");
		contract_no = doString.checkString(request.getParameter("contract_no"),"");
		
	    s_due = Integer.parseInt(doString.checkString(request.getParameter("s_due"),"0"));
	    z_due = Double.parseDouble(doString.checkString(request.getParameter("z_due"),"0.00"));
	    
		d_due_date = doString.checkString(request.getParameter("d_due_date"),"");
		d_due_month = doString.checkString(request.getParameter("d_due_month"),"");
		d_due_year = doString.checkString(request.getParameter("d_due_year"),"");
		c_comment  = doString.checkString(request.getParameter("c_comment"),"");
	
	}
	
     sql.delete(0,sql.length());
     sql.append(" select i_approver from lan:serv_conap ")
		.append(" where i_company = '"+i_company+"' ")
		.append(" and i_project = '"+i_project+"' ")
		.append(" and i_docno = '"+i_docno+"' ")
		.append(" order by s_approver ");
     rs = stmt.executeQuery(sql.toString());
     while(rs.next()){
     	if(apprList == null){
     		apprList = new ArrayList();
     	}
     	apprList.add(doString.checkString(rs.getString("i_approver"),""));
     }
     rs.close();
     
     if("Y".equals(search) || "Y".equals(from_data)){ //search || data
     	disabled = "disabled";
     }
%>

<HTML>
<HEAD>
<TITLE>บันทึกสัญญา</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript" src="js/numeric.js"></script>
<script language="javascript" src="js/datetime.js"></script>
<SCRIPT LANGUAGE="JavaScript">
<!--
function initPage(){
	<%--
	<% if(s_due > 0 && !mode.equalsIgnoreCase("UPDATE")){ %>
	runDPay(<%=s_due%>,"<%=d_due_date%>","<%=d_due_month%>","<%=d_due_year%>");
	<% } %>
	--%>
	
	runLastDate(<%=s_due%>);
}
function runLastDate(s_due){
	var form = document.frmServ;
	var m;
	for(run = 0 ; run < s_due ; run++){
		var dd = parseInt(eval("form.d_pay"+run+"_date.value"),10);
		var mm = parseInt(eval("form.d_pay"+run+"_month.value"),10);
		var yy = parseInt(eval("form.d_pay"+run+"_year.value"),10);
		
		if(mm < 10){
			m = "0"+mm;
		}else{
			m = ""+mm;
		}
		
		if(dd == "29" || dd == "30"){
			if(mm == 2){
				var lastdate = getLastDateOfMonth(mm,yy);
				dd = lastdate.getDate();
			}
			setDPay(run,dd,m,yy+"");
		}else if(dd == "31"){
			var lastdate = getLastDateOfMonth(mm,yy);
			dd = lastdate.getDate();
			setDPay(run,dd,m,yy+"");
		}else{
			setDPay(run,dd,m,yy+"");
		}
	}
}
function runDPay(s_due,d,m,y){
	var dd = d;
	var mm = parseInt(m,10);
	var yy = parseInt(y,10);
	for(ix = 0 ; ix < s_due ; ix++){
		if(mm < 10){
			m = "0"+mm;
		}else{
			m = ""+mm;
		}
		
		if(d == "29" || d == "30"){
			if(mm == 2){
				var lastdate = getLastDateOfMonth(mm,yy);
				dd = lastdate.getDate();
			}else{
				dd = d;
			}
			setDPay(ix,dd,m,yy+"");
		}else if(d == "31"){
			var lastdate = getLastDateOfMonth(mm,yy);
			dd = lastdate.getDate();
			setDPay(ix,dd,m,yy+"");
		}else{
			setDPay(ix,dd,m,yy+"");
		}
		
		mm = mm+1;
		if(mm>12){
			mm = 1;
			yy = yy+1;
		}
	}
}
function setDPay(seq,d,m,y){
	selected(eval("document.forms[0].d_pay"+seq+"_date"),d);
	selected(eval("document.forms[0].d_pay"+seq+"_month"),m);
	selected(eval("document.forms[0].d_pay"+seq+"_year"),y);
}
function selected(selObj,theVal){
	if(theVal == '') return;
	for(i = 0 ; i < selObj.options.length ; i++){
		if(theVal == selObj.options[i].value){
			selObj.options[i].selected = true;
			return;
		} 
	}
	alert("ไม่พบข้อมูล "+theVal);
	selObj.options[0].selected = true;
}
function refreshPage() {
	frmContract.action="SERV_Contract.jsp";
	frmContract.submit();
}
function openVendor(){
	var form = document.frmServ;
	if(form.project.value == ''){
	 	alert('กรุณาเลือกโครงการก่อนค่ะ');
		return;
	}
	window.open('/LHServ/search_vendor2.jsp?project='+form.project.value,'','width=600,height=400,scrollbars=yes');
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
         alert("กรุณาระบุวันที่สัญญา");
         return false;
     }     

     
     var startDate = new Date(parseInt(syear,10),parseInt(smonth,10)-1,parseInt(sdate,10));
     var endDate = new Date(parseInt(eyear,10),parseInt(emonth,10)-1,parseInt(edate,10));
     
     if (startDate.getMonth()!=(parseInt(smonth,10)-1)) {
        alert("วันที่สัญญาไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].start_date.focus();
        return false;
     }
     
     if (endDate.getMonth()!=(parseInt(emonth,10)-1)) {
        alert("วันที่สัญญาไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].end_date.focus();
        return false;
     }     
     
	if (startDate>endDate) {
	    alert(" วันที่สัญญาสิ้นสุดต้องไม่น้อยกว่าวันที่เริ่มต้น ! ");
	    return false;
	}
  
     return true;
}
function validDueDate() {
     var sdate = document.forms[0].d_due_date.value;
     var smonth = document.forms[0].d_due_month.value;
     var syear = document.forms[0].d_due_year.value;
	 //---- Check select date ---//
     if (sdate.length==0 && smonth.length==0 && syear.length==0) {
     	alert("กรุณาระบุวันที่จ่ายรอบแรก");
         return false;
     }     
     
     var startDate = new Date(parseInt(syear,10),parseInt(smonth,10)-1,parseInt(sdate,10));
     
     if (startDate.getMonth()!=(parseInt(smonth,10)-1)) {
        alert("วันที่จ่ายรอบแรกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].d_due_date.focus();
        return false;
     }
     return true;
}
function genJob(){
	if(!validDate() || !validDueDate()){
		return false;
	}else if(document.forms[0].z_due.value == ''){
		alert('กรุณาระบุจำนวนเงินต่องวด');
		return;
	}else if(document.forms[0].s_due.value == '' || eval(document.forms[0].s_due.value) == 0){
		alert('กรุณาระบุจำนวนงวด');
		return;
	}else{
		document.forms[0].search.value = 'Y';
		document.forms[0].z_due.value = delCommas(document.forms[0].z_due.value);
		document.forms[0].submit();
	}
}
function clearJob(){
	document.forms[0].clear.value = 'Y';
	document.forms[0].z_due.disabled = false;
	document.forms[0].s_due.disabled = false;
	document.forms[0].d_due_date.disabled = false;
	document.forms[0].d_due_month.disabled = false;
	document.forms[0].d_due_year.disabled = false;
	document.forms[0].z_due.value = delCommas(document.forms[0].z_due.value);
	document.forms[0].submit();
}
function doSum(theObj){
	if(theObj.value == '')theObj.value = 0.0;
	theObj.value = addCommas(parseFloat(delCommas(theObj.value),10).toFixed(2));

	var sum_amount = 0.0;
	for(var i = 0 ; i < <%=s_due%> ; i++){
		var obj = eval("document.forms[0].z_amt"+i);
		sum_amount += parseFloat(delCommas(obj.value));
	}
	document.forms[0].z_amount.value = addCommas(parseFloat(sum_amount,10).toFixed(2));
	document.getElementById("sum_amount").innerHTML = addCommas(parseFloat(sum_amount,10).toFixed(2));
}
function validateForm(){	
	
	var form  = document.frmServ;
	document.forms[0].z_due.disabled = false;
	document.forms[0].s_due.disabled = false;
	document.forms[0].d_due_date.disabled = false;
	document.forms[0].d_due_month.disabled = false;
	document.forms[0].d_due_year.disabled = false;
	
	if(form.project.value == ''){
		alert('กรุณาระบุโครงการ');
		return false;
	}
	if(!validDate()){
		return false;
	}
	if(form.i_vendor.value == ''){
		alert('กรุณาระบุผู้รับเหมา');
		return false;
	}
	if(form.i_job.value == ''){
		alert('กรุณาระบุประเภทงาน');
		return false;
	}
	if(form.s_due.value == '' || parseFloat(form.s_due.value) <= 0){
		alert('กรุณาระบุจำนวนงวด');
		return false;
	}
	if(!validDueDate()){
		return false;
	}
	for(var i = 0 ; i < <%=s_due%> ; i++){
		var obj = eval("document.frmServ.z_amt"+i);
		if(obj.value == '' || parseFloat(obj.value) <= 0){
			alert('จำนวนเงินแต่ละงวดต้องไม่เท่ากับศูนย์ครับ');
			return false;
		}
		dx = eval("document.frmServ.d_pay"+i+"_date.value");
		mx = eval("document.frmServ.d_pay"+i+"_month.value");
		yx = eval("document.frmServ.d_pay"+i+"_year.value");
		if(!checkValidDate(dx,mx,yx)){
			alert('วันที่จ่ายตามสัญญาไม่ถูกต้องครับ');
			return false;
		}
	}
	
	var num_appr = form.num_appr.value;
	if(num_appr == 0) return false;
	
	for(var j = 0 ; j < parseInt(num_appr,10) ; j++){
		var obj = eval("document.frmServ.approver"+j);
		if(obj.value == ''){
			alert('กรุณาระบุผุ้อนุมัติด้วยครับ');
			return false;
		}
	}
	return true;
}
function doSaveAndSend(state){
	var form  = document.frmServ;
	if(validateForm()){
		if(state == 'DELETE'){
			form.mode.value = state;
		}
		form.state.value = state;
		form.action = "/LHServ/SERV_ContractServlet";
		form.submit();
	}else{
		document.forms[0].z_due.disabled = true;
		document.forms[0].s_due.disabled = true;
		document.forms[0].d_due_date.disabled = true;
		document.forms[0].d_due_month.disabled = true;
		document.forms[0].d_due_year.disabled = true;
	}
}
//-->
</SCRIPT>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="initPage()">
<FORM name="frmServ" method="post" action="/LHServ/SERV_Contract.jsp">
<input type="hidden" name="mode" value="<%=mode%>" />
<input type="hidden" name="state" value="SAVE" />
<input type="hidden" name="search" value="N" />
<input type="hidden" name="clear" value="N" />
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;บันทึกสัญญา</td>
          <td width="30%" align="right">&nbsp;</td>
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
                  <td height="22" class="item ; dotline01" width="10%">เลขที่สัญญา  : </td>
                  <td height="22" width="36%" class="dotline01">
                  <% if("UPDATE".equals(mode)){ %>
                  <%=docFormat(i_docno)%>
                  <input type="hidden" name="i_docno" value="<%=i_docno%>"/>
                  <% }else{ %>
                  [ Auto Generate ]
                  <% } %>
                  </td>
                  <td height="22" width="11%" class="item ; dotline01">วันที่สัญญาตั้งแต่ 
                    : </td>
                  <td height="22" width="43%" class="item ; dotline01">
                  <% if("UPDATE".equals(mode)){ %>
                  		<%=genDateListbox("start",startDate," class='box' ")%> &nbsp; ถึง &nbsp; 
                  		<%=genDateListbox("end",endDate," class='box' ")%>
                  <% }else{ %>
				    <%=common.genDateListbox("start",request," class='box' ")%> &nbsp; ถึง &nbsp; 
				    <%=common.genDateListbox("end",request," class='box' ")%>
				  <% } %>
                  </td>
                </tr>
                <tr> 
                  <td height="22" class="item ; dotline01" width="10%">โครงการ 
                    :</td>
                  <td height="22" width="36%" class="dotline01"> 
                  	<% if(mode.equalsIgnoreCase("UPDATE")){ 
                  	
                  		sql.delete(0,sql.length());
				        sql.append(" select n_project from lan:acxprojt ")
				            .append(" where i_company = '"+i_company+"' and i_project = '"+i_project+"' ");
				       	rs = stmt.executeQuery(sql.toString());
				        if(rs.next()){
				        	n_project = doString.checkString(rs.getString("n_project"),"");
				        }
				        rs.close();
                  	%>
                  	<%=project%> - <%=doString.DisplayThai(n_project)%>
                  	<input type="hidden" name="project" value="<%=project%>"/>
                  	<% }else{ %>
                     <select name='project' class='box' style='width:250px'>
                      <option value=''>------ โปรดเลือกโครงการ ------</option>
                    	<%
                    	//declaration
                    	String comp_all = "" , tmp_comp = "" , tmp_proj = "";
                    	
                    	//check user all
                    	rs = stmt.executeQuery(" select com_id from lan:serv_pstaff where proj_id = 'ALL' and user_id = '"+user.getUserID()+"' ");
                    	if(rs.next()){
                    		comp_all = "Y";
                    	}
                    	rs.close();
                    	
                    	//query string
                    	sql.delete(0,sql.length());
                    	if("Y".equals(comp_all)){
                    		sql.append(" select distinct a.i_company , a.i_project , a.n_project from lan:acxprojt a , lan:acsbudgh c ")
                    			.append(" where a.i_company = c.i_company ")
                    			.append(" and a.i_project = c.i_project ")
                    			.append(" and c.i_budg_type = '9' ")
                    			.append(" and c.d_year in ('")
								.append(yy).append("' , '")
								.append(pYear).append("') ")
                    			.append(" order by 1,2,3 ");
                    	}else{
	                    	sql.append(" select distinct a.i_company , a.i_project , a.n_project from lan:acxprojt a , lan:serv_pstaff b , lan:acsbudgh c ")
	                    		.append(" where a.i_company = b.com_id ")
	                    		.append(" and a.i_project = b.proj_id ")
	                    		.append(" and a.i_company = c.i_company ")
	                    		.append(" and a.i_project = c.i_project ")
                    			.append(" and c.d_year in ('")
								.append(yy).append("' , '")
								.append(pYear).append("') ")
	                    		.append(" and b.user_id = '"+user.getUserID()+"' ")
                    			.append(" order by 1,2,3 ");
                    	}
                   		rs = stmt.executeQuery(sql.toString());
                   		while(rs.next()){
                   			tmp_comp = doString.checkString(rs.getString("i_company"),"");
                   			tmp_proj = doString.checkString(rs.getString("i_project"),"");
                   			
                   			selected = "";
                   			if((tmp_comp+tmp_proj).equals(project)){
                   				selected = "selected";
                   			}
                   			%><option value="<%=tmp_comp+tmp_proj%>"  <%=selected%>><%=tmp_comp+tmp_proj%> | <%=doString.DisplayThai(doString.checkString(rs.getString("n_project"),""))%></option><%
                   		}
                   		rs.close();
                    	
                      %>
                    </select>
                    <% } %>
                  </td>
                  <td height="22" width="11%" class="item ; dotline01">เฟส :</td>
                  <td height="22" width="43%" class="item ; dotline01"> 
                    <input type="text" name="i_phase" class="box" style="width:30px" value="<%=i_phase%>">
                  </td>
                </tr>
                <tr> 
                  <td height="22" class="item ; dotline01" width="10%">ผู้รับเหมา 
                    :</td>
                  <td height="22" width="36%" class="dotline01"> 
                    <input type="hidden" name="i_vendor" class="box" value="<%=i_vendor%>" readonly="readonly">
                    <input type="text" name="n_vendor" value="<%=doString.DisplayThai(n_vendor)%>" readonly="readonly"  onFocus="this.blur()" class="box" style="width:170px"  />
                    &nbsp;&nbsp;<a href="#" onclick="openVendor()"><img border="0" src="images/i_search.gif" align="absmiddle" ></a> 
                  </td>
                  <td height="22" width="11%" class="item ; dotline01">เลขที่สัญญาอ้างอิง 
                    : </td>
                  <td height="22" width="43%" class="item ; dotline01"> 
                    <input type="text" name="contract_no" class="box" style="width:100px" value="<%=doString.DisplayThai(contract_no)%>">
                  </td>
                </tr>
                <tr> 
                  <td height="22" class="item ; dotline01" width="10%">ประเภทงาน 
                    : </td>
                  <td height="22" width="36%" class="item ; dotline01"> 
                    <select size="1" name="i_job" class="box" style="width:250px">
                      <option value="" >----- เลือกงาน -----</option>
                      <%
                      	String i_itmjob = "";
	               		sql.delete(0,sql.length());
	               		sql.append(" select i_itmjob , n_itmjob from lan:serv_infboq where i_itmtype = '03' AND i_seq != '0000' ");
	               		rs = stmt.executeQuery(sql.toString());
	               		while(rs.next()){
	               			selected = "";
	               			i_itmjob = doString.checkString(rs.getString("i_itmjob"),"");
	               			if(i_job.equals(i_itmjob)){ 
	               				selected = "selected";
	               			}
	               			%><option value="<%=i_itmjob%>" <%=selected%> ><%=doString.DisplayThai(doString.checkString(rs.getString("n_itmjob"),""))%></option><%
	               		}
	               		rs.close();
                       %>
                    </select>
                  </td>
                  <td height="22" width="11%" class="item ; dotline01">&nbsp;</td>
                  <td height="22" width="43%" class="item ; dotline01">&nbsp; </td>
                </tr>
                <tr> 
                  <td height="22" class="item ; dotline01" width="10%">จำนวนงวดงาน 
                    : </td>
                  <td height="22" width="36%" class="item ; dotline01"> 
                    <input name="s_due" type="text" class="boxR" style="width:50px" value="<%=s_due%>" onkeypress="checkNum(event)" <%=disabled%>>
                    &nbsp;งวด </td>
                  <td height="22" width="11%" class="item ; dotline01">จำนวนเงินต่องวด 
                    : </td>
                  <td height="22" width="43%" class="item ; dotline01"> 
                    <input name="z_due" type="text" class="boxR" style="width:100px" <%=disabled%>
                    	value="<%=doString.displayNumber("#,##0.00",z_due)%>" 
                    	onblur="this.value = addCommas(parseFloat(delCommas(this.value),10).toFixed(2))" 
                    	onkeypress="checkNum(event)">
                    &nbsp;บาท</td>
                </tr>
                <tr>
                  <td height="22" class="item ; dotline01" width="10%">วันที่จ่ายรอบแรก 
                    : </td>
                  <td height="22" width="36%" class="item ; dotline01"> 
                  <% if("Y".equals(from_data) && !"Y".equals(search)){ %>
                  		<%=genDateListbox("d_due",d_due," class='box' "+disabled)%>
                  <% }else{ %>
                    	<%=common.genDateListbox("d_due",request," class='box' "+disabled)%>
                  <% } %>
                  </td>
                  <td height="22" width="11%" class="item ; dotline01">&nbsp;</td>
                  <td height="22" width="43%" class="item ; dotline01">&nbsp;</td>
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
<% if(!"Y".equals(search) && !"Y".equals(from_data)){ %>
			<br style="font-size: 5pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="100" class="act_tab2">
            <a href="#" onclick="genJob()"><img border="0" src="images/act_generate.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
				</td>   
            <td class="act_tab3"></td>   
            <td class="act_tab4">&nbsp;</td>  
          </tr>  
        </table>  			
<% } %>

        <br style="font-size:10pt">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
	<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
	<td class="item_tab2" width="160">รายละเอียดงวดงาน</td>
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
                  <td class="col_name" width="6%">งวดที่</td>
                  <td class="col_name" width="62%">รายละเอียด</td>
                  <td class="col_name" width="20%">วันที่จ่ายตามสัญญา</td>
                  <td class="col_name" width="12%">จำนวนเงิน</td>
                </tr>
                <% 
                if("Y".equals(from_data)){ 
                	String ddd = "";
                	int i = 0;
                	sql.delete(0,sql.length());
                	sql.append(" select * from lan:serv_condt ")
                		.append(" where i_company = '"+i_company+"' ")
                		.append(" and i_project = '"+i_project+"' ")
                		.append(" and i_docno = '"+i_docno+"' ")
                		.append(" order by s_due ");
                	rs = stmt.executeQuery(sql.toString());
                	while(rs.next()){
                		ddd = doString.checkString(rs.getString("d_pay"),"");
                %>
	                <tr> 
	                  <td class="dotline" align="center" width="6%"><%=i+1%></td>
	                  <td class="dotline" align="left" width="62%"> 
	                    <input type="text" name="n_job<%=i%>" class="box" style="width:100%"  value="<%=doString.DisplayThai(doString.checkString(rs.getString("n_job"),""))%>">
	                  </td>
	                  <td class="dotline" align="center" width="20%">
	                    <%=genDateListbox("d_pay"+i,ddd," class='box' ")%>
	                  </td>
	                  <td class="dotline" align="center" width="12%"> 
	                    <input name="z_amt<%=i%>" type="text" class="boxR" style="width:100px" onblur="doSum(this)" value="<%=doString.displayNumber("#,##0.00",rs.getDouble("z_amount"))%>" onkeypress="checkNum(event)">
	                  </td>
	                </tr>
	                <%
	                	++i;
                	}
                	rs.close();
                	 %>
	                <tr>
	                  <td class="dotline" align="center" width="6%">&nbsp;</td>
					  <td class="item; dotline" align="left" width="62%">&nbsp;</td>
	                  <td class="item ; dotline01" align="right" width="20%">รวมเงิน :</td>
	                  <td class="dotline01" align="center" width="12%">
	                  	<input name="z_amount" type="hidden" value="<%=doString.displayNumber("#,##0.00",z_amount)%>" >
	                  	<span id="sum_amount" ><%=doString.displayNumber("#,##0.00",z_amount)%></span>
	                  </td>	                  
	                </tr>
                <% }else if("Y".equals(search)){ 
                	if(s_due > 0){
                	
                	int tmp_y = Integer.parseInt(d_due_year);
                	int tmp_m = Integer.parseInt(d_due_month);
	                for(int i = 0 ; i < s_due ; i++){ %>
	                <tr> 
	                  <td class="dotline" align="center" width="6%"><%=i+1%></td>
	                  <td class="dotline" align="left" width="62%"> 
	                    <input type="text" name="n_job<%=i%>" class="box" style="width:100%"  value="<%=doString.DisplayThai(doString.checkString(request.getParameter("n_job"+i),""))%>">
	                  </td>
	                  <td class="dotline" align="center" width="20%"> 
	                  	<% 
	                  	String d_payx_date = doString.checkString(request.getParameter("d_pay"+i+"_date"),"");
	                  	String d_payx_month = doString.checkString(request.getParameter("d_pay"+i+"_month"),"");
	                  	String d_payx_year = doString.checkString(request.getParameter("d_pay"+i+"_year"),"");
	                    if("".equals(d_payx_date)){
	                    	d_payx_date = d_due_date;
	                    }
	                    if("".equals(d_payx_month)){
	                    	d_payx_month = doString.displayNumber("00",tmp_m+0.0);
	                    	tmp_m += 1;
	                    }else{
	                    	//System.out.println(d_payx_month);
	                    	tmp_m = Integer.parseInt(d_payx_month)+1;
	                    }
	                    if("".equals(d_payx_year)){
	                    	d_payx_year = String.valueOf(tmp_y);
	                    }else{
	                    	//System.out.println(d_payx_year);
	                    	tmp_y = Integer.parseInt(d_payx_year);
	                    }
                    	if(tmp_m > 12){
                    		tmp_m = 1;
                    		tmp_y += 1;
                    	}	
	                  	%>
	                    <%=genDateListbox("d_pay"+i,d_payx_year+"-"+d_payx_month+"-"+d_payx_date," class=\"box\" ")%>
	                    &nbsp;
	                  </td>
	                  <td class="dotline" align="center" width="12%"> 
	                    <input name="z_amt<%=i%>" type="text" class="boxR" style="width:100px" onblur="doSum(this)" 
	                    <% 
	                    String z_duex = doString.checkString(request.getParameter("z_amt"+i),"");
	                    if(!"".equals(z_duex)){
	                    %>
	                    value="<%=z_duex%>" 
	                    <% }else{ %>
	                    value="<%=doString.displayNumber("#,##0.00",z_due)%>" 
	                    <% } %>
	                    onkeypress="checkNum(event)">
	                  </td>
	                </tr>
	                <% }  }%>
	                <tr>
	                  <td class="dotline" align="center" width="6%">&nbsp;</td>
					  <td class="item; dotline" align="left" width="62%">&nbsp;</td>					  
	                  <td class="item ; dotline01" align="right" width="20%">รวมเงิน :</td>
	                  <td class="dotline01" align="center" width="12%">
	                  	<input name="z_amount" type="hidden" value="<%=doString.displayNumber("#,##0.00",z_due*s_due)%>" >
	                  	<span id="sum_amount" ><%=doString.displayNumber("#,##0.00",z_due*s_due)%></span>
	                  </td>
	                </tr>
                
                <% }else{ %>
                	<tr>
	                  <td class="dotline" align="center" width="6%">&nbsp;</td>
					  <td class="item; dotline" align="left" width="62%">&nbsp;</td>
	                  <td class="item ; dotline01" align="right" width="20%">รวมเงิน :</td>
	                  <td class="dotline01" align="center" width="12%">&nbsp;
	                  </td>
	                </tr>
	             <% } %>
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
<% if("Y".equals(search)  ||  "Y".equals(from_data)){ %>
	<br style="font-size: 5pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="100" class="act_tab2">
            <a href="#" onclick="clearJob()"><img border="0" src="images/act_clear.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
				</td>   
            <td class="act_tab3"></td>   
            <td class="act_tab4">&nbsp;</td>  
          </tr>  
        </table> 
<% } %>			
<br style="font-size:10pt">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
	<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
	<td class="item_tab2" width="160">บันทึกเพิ่มเติม</td>
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

<br style="font-size:5pt">

<table border="0" width="100%" cellspacing="1" cellpadding="0">
<tr>
<td width="100%">
<textarea rows="5" name="c_comment" cols="20" class="box" style="width:100%"><%=doString.DisplayThai(c_comment)%></textarea>
</td>
</tr>
</table>
<br style="font-size:5pt">
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
<br style="font-size: 10pt">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" valign="top" align="center" style="background-image: url('images/bg_flow.jpg'); background-repeat: no-repeat; background-position: -1px 10px">

            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="160">สายงานการอนุมัติ</td>
                <td class="item_tab3"></td>
                <td class="item_tab4">&nbsp;</td>
                <td class="item_tab5i" style="width:180px"></td> 
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
                  <TR>
                    <TD width="6%">&nbsp;</TD>
                    <TD width="2%">&nbsp;</TD>
                    <TD width="2%">&nbsp;</TD>
                    <TD width="90%">&nbsp;</TD>
                  </TR>
                  <TR>
                    <TD width="6%">&nbsp;</TD>
                    <TD width="2%"><IMG height=15 src="images/no1.gif" width=15 align=absMiddle border=0></TD>
                    <TD width="2%"><IMG height=16 src="images/i_wait.gif" width=19 align=absMiddle border=0></TD>
                    <TD width="90%"><%=doString.DisplayThai(getEmpName(stmt,user.getEmpId()))%></TD>
                  </TR>
                  <TR>
                    <TD width="6%"></TD>
                    <TD width="2%"></TD>
                    <TD width="2%"></TD>
                    <TD width="90%">(<%=doString.DisplayThai(getEmpJob(stmt,user.getEmpId()))%>)</TD>
                  </TR>
                  <TR>
                    <TD width="6%"></TD>
                    <TD width="2%"></TD>
                    <TD width="2%"></TD>
                    <TD width="90%">ผู้ขออนุมัติ</TD>
                  </TR>
                  <TR>
                    <TD colspan="4"><br>
                    </TD>
                  </TR>
                	<%
                	
                	String i_appr_type = "" , i_employ_app = "" , emp_appr_tmp = "";
                	int count_appr = 0;
                	
                	sql.delete(0,sql.length());
                	sql.append(" select * from lan:serv_chart ")
                		.append(" where i_employ = '"+user.getEmpId()+"' and i_df_type = 'JO' ");
                	System.out.println(sql.toString());
                	rs = stmt.executeQuery(sql.toString());
                	if(rs.next()){
                		
                		for(int j = 0 ; j < 5 ; j++){
                			i_appr_type = doString.checkString(rs.getString("i_approve_type"+(j+1)),"");
                			if(!"".equals(i_appr_type)){
                				i_employ_app = doString.checkString(rs.getString("i_employ_app"+(j+1)),"");
                	%>
	                  <TR>
	                    <TD width="6%">&nbsp;</TD>
	                    <TD width="2%"><IMG height=15 src="images/no<%=j+2%>.gif" width=15 align=absMiddle border=0></TD>
	                    <TD width="2%"><IMG height=16 src="images/i_pass_blank.gif" width=19 align=absMiddle border=0></TD>
	                    <TD width="90%">
	                    <select size="1" name="approver<%=count_appr++%>" class="box" style="width: 200px">
	                    	<option value="">----- เลือกผู้อนุมัติ -----</option>  
	                    	<% if(!"".equals(i_employ_app) && i_employ_app.length() == 6){ 
	                    			selected = "";
	                    			if(apprList != null && j < apprList.size()){
	                    			   emp_appr_tmp = (String)apprList.get(j+1);
	                    			   System.out.println(i_employ_app+ ":" + emp_appr_tmp );
	                    			   if(i_employ_app.equals(emp_appr_tmp)){
	                    			   		selected = "selected";
	                    			   }
	                    			}
	                    	%> 
	                    	<option value="<%=i_employ_app%>" <%=selected%>><%=doString.DisplayThai(getEmpName(stmt1,i_employ_app))%></option>
	                    	<% }else{ 
	                    		emp_appr_tmp = "";
	                    		if(apprList != null && j < apprList.size()){
	                    			   emp_appr_tmp = (String)apprList.get(j+1);
	                    		}
	                    	%>
	                    	<%=doString.DisplayThai(getApprName(stmt1,i_employ_app,emp_appr_tmp))%>      
	                    	<% } %>            
	                    </select>
	                    </TD>
	                  </TR>
	                  <TR>
	                    <TD width="6%"></TD>
	                    <TD width="2%"></TD>
	                    <TD width="2%"></TD>
	                    <TD width="90%">
	                    <% if(!"".equals(i_employ_app) && i_employ_app.length() == 6){ %>
	                    	<%=doString.DisplayThai(getEmpJob(stmt1,i_employ_app))%>
	                    <% }else{
			                    sql.delete(0,sql.length());
			                	sql.append(" select * from lan:serv_role ")
			                		.append(" where i_role = '"+i_employ_app+"' ");
			                	System.out.println(sql.toString());
			                	rs1 = stmt1.executeQuery(sql.toString());
			                	if(rs1.next()){
			                		out.print("( "+doString.DisplayThai(doString.checkString(rs1.getString("n_role"),""))+" )");
			                	}
			                	rs1.close();
			                }
	                     %>
	                    </TD>
	                  </TR>
	                  <TR>
	                    <TD width="6%"></TD>
	                    <TD width="2%"></TD>
	                    <TD width="2%"></TD>
	                    <TD width="90%">ผู้อนุมัติคนที่ <%=j+1%></TD>
	                  </TR>
	                  <TR>
	                    <TD colspan="4"><br>
	                    </TD>
	                  </TR>
                	<%     
                			}//if
                		}//for           		
                	}//if
                	rs.close();
                %>
                </TABLE>
                	<input type="hidden" name="num_appr" value="<%=count_appr%>" />
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
<table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
  <tr>
    <td class="act_tab1"></td>
            <td width="220" class="act_tab2">
            <A href="javascript:doSaveAndSend('SAVE')"><IMG border="0" src="images/act_saveandclose.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27"></A>&nbsp;
            <A href="javascript:doSaveAndSend('SEND')"><IMG border="0" src="images/act_send2app.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27"></A>
            <% if("UPDATE".equals(mode)){ %>
            <A href="javascript:doSaveAndSend('DELETE')"><IMG border="0" src="images/act_delete.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27"></A>
            <% } %>
            </td>
    <td class="act_tab3"></td>
            <td class="act_tab4"><a href="SERV_ConHome.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
  </tr>
</table>
</table>
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
	System.out.println("ERROR SERV_Contract.jsp : " + sql.toString());
	System.out.println("ERROR SERV_Contract.jsp : " + e.getMessage());
	throw new ServletException(e.getMessage());
} finally {
	// Clean up.
	try {
		if (rs != null) rs.close();
		if (stmt != null) stmt.close();
		if (stmt1 != null) stmt1.close();
		if (conn != null) conn.close();
	}
	catch( SQLException ignore ){}
}
%>
