<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%!
	// Caching the DataSource - It is obtained in the jspInit() method	
	private javax.sql.DataSource ds = null;
	private String dsName = Constants.JDBC_LAN;
	private String month[] = {"เดือน","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
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
%>
<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_AddLockDet.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

Calendar rightNow = Calendar.getInstance();
int Syear = 0, Eyear = 0;
int iLor = 0;
double area = 0;
String Act = "Add";
String code = "", option = "", optionSelected = "", chk_dis = "";
String d_end = "", d_year = "", house = "", cus_name = "", address1 = "", address2 = "", address3 = "", nation = "", zipcode = "", id_no = "";
String email = "", corp = "N", addr = "N";
String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543); 
String project = doString.checkString(request.getParameter("Project"),"LH000");
String comId = project.substring(0,2);
String projId = project.substring(2);
String Lock = doString.checkString(request.getParameter("Lock"));
Lock = Lock.toUpperCase();
String i_lor = doString.checkString(request.getParameter("i_lor"),""); 
String flag = doString.checkString(request.getParameter("flag"),"");
//---------------------------- DATE -----------------------------
int start_day = rightNow.get(Calendar.DATE);
if (request.getParameter("start_day") != null) {
	start_day = Integer.parseInt(doString.checkString(request.getParameter("start_day")));
}
String start_mnth = doString.checkNumber(rightNow.get(Calendar.MONTH)+1);
if (request.getParameter("start_mnth") != null) {
	start_mnth = request.getParameter("start_mnth");
}
String start_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
if (request.getParameter("start_year") != null) {
	start_year = request.getParameter("start_year");
}
//---------------------------- DATE -----------------------------
%>
<HTML>
<HEAD>
<TITLE>ข้อมูลพื้นฐาน : 
อัตราค่าบริการสาธารณะ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<base target="_self">
<script language="JavaScript">
<!--
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

function validateIdCardNo(idCardNo) {
	var result = 0;
	var numberRegex = /^\d+$/;
	if (idCardNo.length != 13) {
		result = 1;
	} else if (!numberRegex.test(idCardNo)) {
		result = 2;
	} else {
		var sumVal = 0;
		for(var i=0;i<12;i++) {
			sumVal += parseFloat(idCardNo.substring(i,i+1))*(13-i);
		} // end for
		var chkDigit = idCardNo.substring(12,13);
		var chkCalculate = (11-(sumVal%11))%10;
		if(chkCalculate == parseFloat(chkDigit)) {
			result = 0;
		} else {
			result = 3;
		}
	}
	return result;
}

function saveTime(a) {
	if (Trim(frmTime.id_no.value) == ""){
		alert("โปรดระบุเลขที่บัตรประชาชน");
		frmTime.id_no.focus();
		return;
	}
	
	if (Trim(frmTime.id_no.value) != "-"){
		var chkIdCard = validateIdCardNo(Trim(frmTime.id_no.value));
		if (chkIdCard > 0) {
			switch (chkIdCard) {
				case 1 : alert("กรุณากรอกเลขที่บัตรประชาชน / เลขทะเบียนนิติบุคคล ความยาว 13 หลักเท่านั้น!!"); break;
				case 2 : alert("กรุณากรอกเลขที่บัตรประชาชน / เลขทะเบียนนิติบุคคล เฉพาะตัวเลขเท่านั้น!!"); break;
				case 3 : alert("ข้อมูลเลขที่บัตรประชาชน / เลขทะเบียนนิติบุคคล ไม่ถูกต้อง, กรุณาตรวจสอบ!!"); break;
				default : alert("ID Card No Error."); break;
			}
			frmTime.id_no.focus();
			return;
		}
	}
		
	if (Trim(frmTime.zipcode.value) == ""){
		alert("โปรดระบุรหัสไปรษณีย์");
		frmTime.zipcode.focus();
		return;
	}	
	if (Trim(frmTime.Nation.value) == ""){
		alert("โปรดระบุประเทศ");
		frmTime.Nation.focus();
		return;
	}		
	if (Trim(frmTime.email.value) == ""){
		alert("โปรดระบุ Email");
		frmTime.email.focus();
		return;
	}	
	
	frmTime.action = "/LHServ/AddLockDetServlet?Act="+a;
	frmTime.submit();
}
//-->
</script>
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" >
<FORM name="frmTime" method="post" action="SERV_AddLockDet.jsp">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ข้อมูลพื้นฐาน</td>
        </tr>
      </table>


<br style="font-size:10pt">
<%
StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;
try {
	if (ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();


//----------------------- FLAG = EDIT ---------------------
if (flag.equals("edit")) {   //  EDIT
		 Act = "Edit";
		chk_dis = "disabled";
		sql.delete(0, sql.length());
		sql.append("SELECT distinct * FROM lan:serv_inflck WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_sort = '"+Lock+"' AND i_lor = '"+i_lor+"' ");
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		if (rs.next() == true) {
				iLor = rs.getInt("i_lor");
				area = rs.getDouble("q_area");
				d_end = doString.checkString(doString.DisplayThai(rs.getString("d_end")));	
				start_day = Integer.parseInt(d_end.substring(8,10));
				start_mnth = d_end.substring(5,7);
				start_year = Integer.toString(Integer.parseInt(d_end.substring(0,4))+543);
				house = doString.checkString(rs.getString("i_house"));
				cus_name = doString.checkString(doString.DisplayThai(rs.getString("n_customer")));
				address1 = doString.checkString(doString.DisplayThai(rs.getString("a_address1")));
				address2 = doString.checkString(doString.DisplayThai(rs.getString("a_address2")));
				address3 = doString.checkString(doString.DisplayThai(rs.getString("a_address3")));
				zipcode = doString.checkString(rs.getString("i_zipcode"));
				id_no = doString.checkString(doString.DisplayThai(rs.getString("id_no")));
				nation = doString.checkString(rs.getString("i_nation"));
				email = doString.checkString(rs.getString("i_email"));
				corp = doString.checkString(rs.getString("f_corp"));
				addr = doString.checkString(rs.getString("f_address"));
		} // end if
} // end EDIT
%>
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">อัตราค่าบริการสาธารณะ</td>
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
                  <td class="item ; dotline01" height="22" width="20%">โครงการ 
                    :</td>
                  <td height="22" width="28%" class="dotline01"> 
                     <select size="1" name="Project" class="box" style="width:250px" onChange="frmTime.submit()" <%=chk_dis%>>
                      <option value="LH000">----- เลือกโครงการ -----</option>
                      <%
	sql.delete(0, sql.length());
	sql.append("SELECT * FROM lan:serv_pstaff WHERE user_id = '"+userId+"' AND com_id = 'LH' AND proj_id = 'ALL'");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();

	sql.delete(0, sql.length());
	if (rs.next() == true) {
		sql.append("SELECT DISTINCT proj.i_company, proj.i_project, proj.n_project")
			.append(" FROM lan:acxprojt proj, lan:acsbudgh bud")
			.append(" WHERE bud.i_company = proj.i_company AND bud.i_project = proj.i_project")
			.append(" AND bud.d_year = '")
			.append(cur_year)
			.append("' ORDER BY proj.i_company, proj.i_project");
	} else {
		sql.append("SELECT b.i_company, b.i_project, b.n_project")
			.append(" FROM lan:serv_pstaff a, lan:acxprojt b")
			.append(" WHERE a.user_id = '")
			.append(userId)
			.append("' AND a.com_id = b.i_company AND a.proj_id = b.i_project")
			.append(" ORDER BY b.i_company, b.i_project");
	}
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	if (rs != null) {
		while (rs.next() == true) {
			optionSelected = "";
			code = doString.checkString(rs.getString("I_COMPANY"))+doString.checkString(rs.getString("I_PROJECT"));
			if (project.equals(code)) {
				optionSelected = "selected";
			}
%> 
                      <OPTION value="<%=code%>" <%=optionSelected%>><%=code%> 
                      | <%=doString.checkString(doString.DisplayThai(rs.getString("N_PROJECT")))%></OPTION>
                      <%
		}// end while
		rs.close();
		rs=null;
	}
%> 
                    </select>
                  </td>
                  <td height="22" width="5%" class="dotline01">&nbsp;</td>
                  <td height="22" width="47%" class="dotline01">&nbsp;</td>
                </tr>
				<tr> 
                  <td class="item ; dotline01" height="22" width="20%">แปลง : </td>
                  <td height="22" width="28%" class="dotline01"><INPUT type="text" name="Lock" class="box" value="<%=Lock%>" style="width:60px" <%=chk_dis%> onchange="javascript:frmTime.submit();"></td>
                  <td height="22" width="5%" class="dotline01">&nbsp;</td>
                  <td height="22" width="47%" class="dotline01">&nbsp;</td>
                </tr>
				<tr> 
                  <td class="item ; dotline01" height="22" width="20%">เลขที่ใบจอง : </td>
                  <td height="22" width="28%" class="dotline01"><INPUT type="text" name="iLor" class="box" value="<%=iLor%>" style="width:60px" <%=chk_dis%>></td>
                  <td height="22" width="5%" class="dotline01">&nbsp;</td>
                  <td height="22" width="47%" class="dotline01">&nbsp;</td>
                </tr>
                <tr> 
                  <td class="item ; dotline01" height="22" width="20%">วันที่จ่ายค่าสาธารณะล่าสุด 
                    :</td>
                  <td height="22" width="28%" class="dotline01">&nbsp;<select size="1" name="start_day" class="box" style="width:40px">
<%
		code = "";
		for (int i=1;  i <= 31;  i++) {
			option = "";
			if (i < 9)
				code = "0" + Integer.toString(i);
			else
				code = Integer.toString(i);

			if (i == start_day) {
				option = " Selected ";
			}
%> 
                  <OPTION value="<%=code%>" <%=option%>><%=code%></OPTION>
<%
		} // End for day
%> 
	    </SELECT>&nbsp; 
                    <select size="1" name="start_mnth" class="box" style="width:85px">
<%
	
			for( int i=1;  i <= 12;  i++ ){
				option = "";
				if( i<=9 )
					code = "0" + Integer.toString(i);
				else
					code = Integer.toString(i);

				if (code.equals(start_mnth)) {
					option = " Selected ";
				}
%> 
                  <option value="<%=code%>" <%=option%>><%=month[i]%></option>
<%
			} // End for start_mnth
%></select>
                    &nbsp; ปี&nbsp; 
                    <select size="1" name="start_year" class="box" style="width:55px">
<%
		Syear = Integer.parseInt(start_year) - 5;
		Eyear = Integer.parseInt(start_year) + 5;

		for( int i = Syear;  i <= Eyear;  i++ ){
			option = "";
			if (i == Integer.parseInt(start_year)) {
				option = " Selected ";
			}
%> 
                  <OPTION value="<%=i%>" <%=option%>><%=i%></OPTION>
<%
		} // End for start_year
%> </select>
                  </td>
                  <td height="22" width="5%" class="dotline01">&nbsp;</td>
                  <td height="22" width="47%" class="dotline01">&nbsp; </td>
                </tr>
				<tr> 
                  <td class="item ; dotline01" height="22" width="20%">บ้านเลขที่ : </td>
                  <td height="22" width="28%" class="dotline01"><INPUT type="text" name="house" class="box" value="<%=house%>" style="width:80px"></td>
                  <td height="22" width="5%" class="dotline01">&nbsp;</td>
                  <td height="22" width="47%" class="dotline01">&nbsp;</td>
                </tr>
				<tr> 
                  <td class="item ; dotline01" height="22" width="20%">เนื้อที่ : </td>
                  <td height="22" width="28%" class="dotline01"><INPUT type="text" name="area" class="box" value="<%=doString.displayNumber("###,###,###.00", area)%>" style="width:80px"></td>
                  <td height="22" width="5%" class="dotline01">&nbsp;</td>
                  <td height="22" width="47%" class="dotline01">&nbsp;</td>
                </tr>
				<tr> 
                  <td class="item ; dotline01" height="22" width="20%">ชื่อลูกค้า : </td>
                  <td height="22" width="28%" class="dotline01"><INPUT type="text" name="cus_name" class="box" value="<%=cus_name%>" style="width:200px"></td>
                  <td height="22" width="5%" class="dotline01">&nbsp;</td>
                  <td height="22" width="47%" class="dotline01">&nbsp;</td>
                </tr>
				<tr> 
                  <td class="item ; dotline01" height="22" width="20%">เลขที่บัตรประชาชน : </td>
                  <td height="22" width="28%" class="dotline01"><INPUT type="text" name="id_no" class="box" value="<%=id_no%>" style="width:200px"></td>
                  <td height="22" width="5%" class="dotline01">&nbsp;</td>
                  <td height="22" width="47%" class="dotline01">&nbsp;</td>
                </tr>
				<tr> 
                  <td class="item ; dotline01" height="22" width="20%">ที่อยู่ 1 : </td>
                  <td height="22" width="28%" class="dotline01"><INPUT type="text" name="address1" class="box" value="<%=address1%>" style="width:400px"></td>
                  <td height="22" width="5%" class="dotline01">&nbsp;</td>
                  <td height="22" width="47%" class="dotline01">&nbsp;</td>
                </tr>
				<tr> 
                  <td class="item ; dotline01" height="22" width="20%">ที่อยู่ 2 : </td>
                  <td height="22" width="28%" class="dotline01"><INPUT type="text" name="address2" class="box" value="<%=address2%>" style="width:400px"></td>
                  <td height="22" width="5%" class="dotline01">&nbsp;</td>
                  <td height="22" width="47%" class="dotline01">&nbsp;</td>
                </tr>
				<tr> 
                  <td class="item ; dotline01" height="22" width="20%">ที่อยู่ 3 : </td>
                  <td height="22" width="28%" class="dotline01"><INPUT type="text" name="address3" class="box" value="<%=address3%>" style="width:400px"></td>
                  <td height="22" width="5%" class="dotline01">&nbsp;</td>
                  <td height="22" width="47%" class="dotline01">&nbsp;</td>
                </tr>
				<tr> 
                  <td class="item ; dotline01" height="22" width="20%">รหัสไปรษณีย์ : </td>
                  <td height="22" width="28%" class="dotline01"><INPUT type="text" name="zipcode" class="box" value="<%=zipcode%>" style="width:200px"></td>
                  <td height="22" width="5%" class="dotline01">&nbsp;</td>
                  <td height="22" width="47%" class="dotline01">&nbsp;</td>
                </tr>
				<tr> 
                  <td class="item ; dotline01" height="22" width="20%">ที่อยู่ในใบเสร็จ : </td>
                  <td height="22" width="28%" class="dotline01">
					<input type="radio" name="addr" value="Y" <%if(addr.equals("Y")){ out.print("checked");}%>>&nbsp;Yes&nbsp;&nbsp;
					<input type="radio" name="addr" value="N" <%if(!addr.equals("Y")){ out.print("checked");}%>>&nbsp;No
				  </td>
                  <td height="22" width="5%" class="dotline01">&nbsp;</td>
                  <td height="22" width="47%" class="dotline01">&nbsp;</td>
                </tr>	
				<tr> 
                  <td class="item ; dotline01" height="22" width="20%">ประเทศ : </td>
                  <td height="22" width="28%" class="dotline01">
                     <select size="1" name="Nation" class="box" style="width:250px">
                      <option value="">----- เลือกประเทศ -----</option>
<%
		rs = stmt.executeQuery("SELECT i_seq, i_alpha2, n_tcountry FROM lan:acxcntry ORDER BY i_seq, n_tcountry");
		if (rs != null) {
			while (rs.next() == true) {
				optionSelected = "";
				code = doString.checkString(rs.getString(2));
				if (nation.equals(code)) {
					optionSelected = "selected";
				}
%>
                      <OPTION value="<%=code%>" <%=optionSelected%>><%=code%> <%=doString.checkString(doString.DisplayThai(rs.getString(3)))%></OPTION>
<%				
			}
			rs.close();
			rs=null;
		}			
%>					  
					  </select>
				  </td>
                  <td height="22" width="5%" class="dotline01">&nbsp;</td>
                  <td height="22" width="47%" class="dotline01">&nbsp;</td>
                </tr>					
				<tr> 
                  <td class="item ; dotline01" height="22" width="20%">Email : </td>
                  <td height="22" width="28%" class="dotline01"><INPUT type="text" name="email" class="box" value="<%=email%>" style="width:200px"></td>
                  <td height="22" width="5%" class="dotline01">&nbsp;</td>
                  <td height="22" width="47%" class="dotline01">&nbsp;</td>
                </tr>				
				<tr> 
                  <td class="item ; dotline01" height="22" width="20%">นิติบุคคล : </td>
                  <td height="22" width="28%" class="dotline01">
					<input type="radio" name="corp" value="Y" <%if(corp.equals("Y")){ out.print("checked");}%>>&nbsp;Yes&nbsp;&nbsp;
					<input type="radio" name="corp" value="N" <%if(!corp.equals("Y")){ out.print("checked");}%>>&nbsp;No
				  </td>
                  <td height="22" width="5%" class="dotline01">&nbsp;</td>
                  <td height="22" width="47%" class="dotline01">&nbsp;</td>
                </tr>				
				
              </table></td>
  </tr>
</table>
<%  if (flag.equals("edit")) {   //  EDIT  %>
	<INPUT TYPE="hidden" NAME="Project" VALUE=<%=project%>>
	<INPUT TYPE="hidden" NAME="Lock" VALUE=<%=Lock%>>
	<INPUT TYPE="hidden" NAME="iLor" VALUE=<%=iLor%>>
<%  }   %>

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
            <td width="75" class="act_tab2">
           <a href="javascript:saveTime('<%=Act%>');"><img border="0" src="images/act_saveandclose.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>

            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href=""><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="SERV_InfHome.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>  
        </table>  


          </td>
        </tr>
      </table>
<%
	stmt.close();
	conn.close();
	stmt=null;
	conn=null;
} catch (Exception e) {
	System.out.println("ERROR SERV_AddLockDet.jsp : " + e.getMessage());
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