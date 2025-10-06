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
String jName = "SERV_AddInfRate.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

Calendar rightNow = Calendar.getInstance();
int Syear = 0, Eyear = 0;
String Act = "Add";
String code = "", option = "", optionSelected = "", chk_dis = "";
String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);  
String extra = doString.checkString(request.getParameter("extra"),"N");   //  add + edit
double Price = Double.parseDouble(doString.checkString(request.getParameter("Price"),"0.0"));  //  edit
String project = doString.checkString(request.getParameter("Project"),"LH000");
String comId = project.substring(0,2);
String projId = project.substring(2);
String startDate = doString.checkString(request.getParameter("startDate"),"00");   //  edit
String endDate = doString.checkString(request.getParameter("endDate"),"0000");   // edit
String start_mnth = doString.checkString(request.getParameter("start_mnth"),"");  
String end_mnth = doString.checkString(request.getParameter("end_mnth"),"");
String flag = doString.checkString(request.getParameter("flag"),"");

String start_year = Integer.toString(rightNow.get(Calendar.YEAR));
if (request.getParameter("start_year") != null) {
	start_year = request.getParameter("start_year");
}
String end_year = Integer.toString(rightNow.get(Calendar.YEAR));
if (request.getParameter("end_year") != null) {
	end_year = request.getParameter("end_year");
}
if (flag.equals("edit")) {   //  EDIT
	 Act = "Edit";
	chk_dis = "disabled";
	if (!startDate.equals("00")) {
		start_mnth = startDate.substring(5,7);
		start_year = startDate.substring(0,4);
	}
	if (!endDate.equals("00")) {
		end_mnth = endDate.substring(5,7);
		end_year = endDate.substring(0,4);
	}
} // end EDIT
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

function saveTime(a) {
	frmTime.action = "/LHServ/AddTimeServlet?Act="+a;
	frmTime.submit();
}

function NextMonth() {
	mnth = parseInt(frmTime.Month.value,10);
	if (mnth == 0) {
		alert("เลือกประเภทเดือน");
		frmTime.Month.focus();
		return;
	}
/*	
	if (mnth == 5) mnth = 6;
	if (mnth == 6) mnth = 12;
*/	
	date = new Date(frmTime.start_mnth.value+"/01/"+frmTime.start_year.value);
	day = date.getDate();
	month = date.getMonth();
	year = date.getFullYear();
	mnth = mnth-1;
	for (m=1; m<=mnth; m++)
	{
		if (month+1 == 12) {
			month = 0;
			year++;
		} else {
			month++;
		}
	}// end for

	date = new Date(year, month, 1);
	for (m=0; m<12; m++) {
		if (m==month)
			frmTime.end_mnth[m].selected = true;
	}
	for (y=0; y<11; y++) {
		if (parseInt(frmTime.end_year[y].value)==year)
			frmTime.end_year[y].selected = true;
	}
}  
//-->
</script>
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" >
<FORM name="frmTime" method="post" action="SERV_AddInfRate.jsp">

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
                  <td class="item ; dotline01" height="22" width="14%">โครงการ 
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
                  <td height="22" width="53%" class="dotline01">&nbsp;</td>
                </tr>


                <tr> 
                  <td class="item ; dotline01" height="22" width="14%">ระยะเวลา 
                    : </td>
                  <td height="22" width="28%" class="dotline01">
                    <select size="1" name="Month" class="box" style="width:85px" onChange="NextMonth()">
                      <option value="0">----- เลือกประเภทเดือน -----</option>   
<%
	sql.delete(0, sql.length());
	sql.append("SELECT i_code, n_desc FROM lan:serv_xstd WHERE i_type = '62' ORDER BY i_code");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	if (rs != null) {
		while (rs.next() == true) {
			optionSelected = "";
			code = doString.checkString(rs.getString("I_CODE"));
%>
                      <option value="<%=code%>" <%=optionSelected%>><%=doString.checkString(doString.DisplayThai(rs.getString("N_DESC")))%></option>
<%		
		}// end while
		rs.close();
		rs=null;
	}
%>      
					</select>&nbsp; ปี&nbsp;
                    <select size="1" name="Year" class="box" style="width:55px">
<%
		Syear = Integer.parseInt(cur_year) - 6;
		Eyear = Integer.parseInt(cur_year) + 5;
		for( int i = Syear;  i <= Eyear;  i++ ){
			option = "";
			if (i == Integer.parseInt(cur_year)) {
				option = " Selected ";
			}
%> 
                  <OPTION value="<%=i%>" <%=option%>><%=i%></OPTION>
<%
		} // End for end_year
%></select>
				  </td>
                  <td height="22" width="5%" class="dotline01">&nbsp;</td>
                  <td height="22" width="53%" class="dotline01">&nbsp;</td>
                </tr>

                <tr> 
                  <td class="item ; dotline01" height="22" width="14%">ตั้งแต่เดือน 
                    :</td>
                  <td height="22" width="28%" class="dotline01"> 
                    <select size="1" name="start_mnth" class="box" style="width:85px" <%=chk_dis%> onChange="NextMonth()">
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
                    <select size="1" name="start_year" class="box" style="width:55px" <%=chk_dis%> onChange="NextMonth()">
<%
		Syear = Integer.parseInt(start_year) - 6;
		Eyear = Integer.parseInt(start_year) + 5;

		for( int i = Syear;  i <= Eyear;  i++ ){
			option = "";
			if (i == Integer.parseInt(start_year)) {
				option = " Selected ";
			}
%> 
                  <OPTION value="<%=i%>" <%=option%>><%=i+543%></OPTION>
<%
		} // End for start_year
%> </select>
                  </td>
                  <td height="22" width="5%" class="dotline01">&nbsp;</td>
                  <td height="22" width="53%" class="dotline01">&nbsp; </td>
                </tr>
                <tr>
                  <td class="item ; dotline01" height="22" width="14%">ถึง :</td>
                  <td height="22" width="28%" class="dotline01">
                    <select size="1" name="end_mnth" class="box" style="width:85px" <%=chk_dis%>>
<%	
			for( int i=1;  i <= 12;  i++ ){
				option = "";
				if( i<=9 )
					code = "0" + Integer.toString(i);
				else
					code = Integer.toString(i);

				if (code.equals(end_mnth)) {
					option = " Selected ";
				}
%> 
                  <option value="<%=code%>" <%=option%>><%=month[i]%></option>
<%
			} // End for end_mnth
%></select>
                    &nbsp; ปี&nbsp; 
                    <select size="1" name="end_year" class="box" style="width:55px" <%=chk_dis%>>
<%
		Syear = Integer.parseInt(end_year) - 6;
		Eyear = Integer.parseInt(end_year) + 5;

		for( int i = Syear;  i <= Eyear;  i++ ){
			option = "";
			if (i == Integer.parseInt(end_year)) {
				option = " Selected ";
			}
%> 
                  <OPTION value="<%=i%>" <%=option%>><%=i+543%></OPTION>
<%
		} // End for end_year
%></select>
                  </td>
                  <td height="22" width="5%" class="dotline01">&nbsp;</td>
                  <td height="22" width="53%" class="dotline01">&nbsp;</td>
                </tr>
                <tr> 
                  <td class="item ; dotline01" height="22" width="14%">ประเภทการจ่าย 
                    : </td>
                  <td height="22" width="28%" class="dotline01"> 
                    <input type="radio" name="extra" value="N"<% if (extra.equals("N")) { out.println("checked"); } %>>
                    ต่อวา &nbsp;
					<input type="radio" name="extra" value="Y"<% if (extra.equals("Y")) { out.println("checked"); } %>>
                    ต่อหลัง</td>
                  <td height="22" width="5%" class="dotline01">&nbsp;</td>
                  <td height="22" width="53%" class="dotline01">&nbsp;</td>
                </tr>
                <tr> 
                  <td class="item ; dotline01" height="22" width="14%">ราคา : 
                  </td>
                  <td height="22" width="28%" class="dotline01"> 
                    <input type="text" name="Price" class="boxR" style="width:100px" size="20" value="<%=Price%>" onKeyPress="if ((event.keyCode < 46 || event.keyCode > 57) || event.keyCode == 47 ) event.returnValue = false;">
                  </td>
                  <td height="22" width="5%" class="dotline01">&nbsp;</td>
                  <td height="22" width="53%" class="dotline01">&nbsp;</td>
                </tr>
              </table>

</td>
  </tr>
</table>
<%  if (flag.equals("edit")) {   //  EDIT  %>
<INPUT TYPE="hidden" NAME="Project" VALUE=<%=project%>>
<INPUT TYPE="hidden" NAME="start_year" VALUE=<%=start_year%>>
<INPUT TYPE="hidden" NAME="start_mnth" VALUE=<%=start_mnth%>>
<INPUT TYPE="hidden" NAME="end_year" VALUE=<%=end_year%>>
<INPUT TYPE="hidden" NAME="end_mnth" VALUE=<%=end_mnth%>>
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
              <a href=""><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
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
	System.out.println("ERROR SERV_AddInfRate.jsp : " + e.getMessage());
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