<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%//@ include file="confirmLogin.jsp" %>
<%//@ include file="function.jsp" %>
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
//String sessionId = user.getsessionId();
//String userId = user.getUserID();
String jName = "SERV_WageAppr.jsp";
//ServLog servlog = new ServLog(sessionId, userId, jName);

    String month[] = {"เดือน","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};   
   	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();   
		stmt1 = conn.createStatement();   
        //----=======================================----//   
String docno = "";
if (request.getParameter("docno") != null) {
		docno = doString.checkString(request.getParameter("docno"));
} 
String status = "";
if (request.getParameter("status") != null) {
		status = doString.checkString(request.getParameter("status"));
} 
String emp_appr = "";
if (request.getParameter("emp_appr") != null) {
		emp_appr = doString.checkString(request.getParameter("emp_appr"));
} 
String project = "";
if (request.getParameter("project") != null) {
		project = doString.checkString(request.getParameter("project"));
} 
String userwho = "";
if (request.getParameter("userwho") != null) {
		userwho = doString.checkString(request.getParameter("userwho"));
} 


String id_card = "", name = "", i_month = "", i_year = "", i_date = "";
//String sta = "APV";
String user_id = "";
String user_password = "";

				sql.delete(0,sql.length());
				sql.append("select distinct user_id, user_password, user_email from lan:useracl ")
					 .append("where i_employ = '"+emp_appr+"' ");			
				rs = stmt.executeQuery(sql.toString());
				if (rs.next() == true) {	
					user_id = doString.checkString(rs.getString("user_id"));
					user_password = doString.checkString(rs.getString("user_password"));				
				} 
				

//String targetUrl = "/LHServ/SERV_WageAppr?status="+sta+"&project="+project;
//String url = "http://www7.lh.co.th"+req.getContextPath()+"/LoginServlet?userid="+user_id+"&password="+user_password+"&url="+targetUrl;


%>
<HTML>

<HEAD>

<TITLE>Home</TITLE>

<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">

<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">

<script language="javascript" src="script_fx.js"></script>

<style type="text/css"> 

.hidden-class { display:none;  } 

.show-class { display:compact;    } 

</style>




<script language="javascript">

<!-- 

function initPage(){ 

if(document.frmSERV.hide_detail.value == 'N') { 

showDetail(); 

} 

if(document.frmSERV.hide_detail.value == 'Y'){ 

hideDetail(); 

} 

}

function gotoOpenJob(i_docno){

var form = document.frmSERV;

form.i_docno.value = i_docno;

form.edit.value = 'no'; 



form.action = '/LHServ/SERV_OpenJob_Follow.jsp'; 



form.submit();

}

function sortBy(theCol){

var form = document.frmSERV;

form.sort_col.value = theCol;

form.submit();

}

function showDetail(){ 

var elements = getElementsByClass('hidden-class'); 

for (i = 0 ; i < elements.length ; i++ ) { 

elements[i].className = 'show-class'; 

} 

document.frmSERV.hide_detail.value = 'N'; 

} 

function hideDetail(){ 

var elements = getElementsByClass('show-class'); 

for (i = 0 ; i < elements.length ; i++ ) { 

elements[i].className = 'hidden-class'; 

} 

document.frmSERV.hide_detail.value = 'Y'; 

} 

function getElementsByClass( searchClass, domNode, tagName) { 

if (domNode == null) domNode = document; 

if (tagName == null) tagName = '*'; 

var el = new Array(); 

var tags = domNode.getElementsByTagName(tagName); 

var tcl = " "+searchClass+" "; 

for(i=0,j=0; i<tags.length; i++) { 

var test = " " + tags[i].className + " "; 

if (test.indexOf(tcl) != -1) 

el[j++] = tags[i]; 

} 

return el; 

} 

//-->

</script>
<base target="_self">
<SCRIPT language="JavaScript">
<!--
function chkValue(sta,a,b,c,d,e,f) { 

	var link2 = "/LHServ/SERV_WageAppr?project="+c;

	var link = "http://132.146.1.92/LHServ/LoginServlet?status="+sta+"&fc_appr=Y&userid="+a+"&password="+b+"&emp_appr="+d+"&docno="+e+"&card_no="+f+"&url="+link2;


	/*alert(frmSERV.chkDate.checked);
	if (frmSERV.chkDate.checked == "false") {
		alert("โปรดระบุวันที่ต้องการเปลี่ยนเวลา");
	} else {*/
			//frmSERV.action ="/LHServ/SERV_WageAppr?status="+sta;
			frmSERV.action = link;
			
			frmSERV.submit();
	//	} // End if
} // End function


//-->
</SCRIPT>
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onLoad="initPage()">
<FORM NAME="frmSERV" METHOD=POST ACTION="SERV_WageAppr.jsp">
<input type="hidden" name="edit" value="" />

<input type="hidden" name="sort_col" value="default" />

<input type="hidden" name="i_company" value="LH" />



<input type="hidden" name="d_keyin_beg" value="" />

<input type="hidden" name="d_keyin_end" value="" />

<input type="hidden" name="itmtype" value="4.1" /> 

<input type="hidden" name="hide_detail" value="Y" />
<input type="hidden" name="emp_appr" value="<%=emp_appr%>">
<input type="hidden" name="docno" value="<%=docno%>">






<table border="0" width="100%" cellspacing="0" cellpadding="0">

<tr>

<td width="100%" align="center" class="BD">






<table border="0" width="100%" cellspacing="0" cellpadding="0">

<tr>

<td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;

ค่าแรงช่าง และค่าแรงคนงาน</td>


</tr>

</table>







<br style="font-size:10pt">




            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="150">รายละเอียดผู้ขออนุมัติ</td>
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
	sql.delete(0,sql.length());	
    sql.append("select * from lan:serv_fingerhd ")
		 .append("where i_docno = '"+docno+"' ");				
	rs = stmt.executeQuery(sql.toString());					
    if (rs.next()==true) {
		id_card = doString.checkString(rs.getString("id_card"));
		name = doString.checkString(doString.DisplayThai(rs.getString("name")));
		i_month = doString.checkString(rs.getString("month"));
		i_year = doString.checkString(rs.getString("year"));
	}
%>

<input type="hidden" name="card_no" value="<%=id_card%>">
<input type="hidden" name="i_name" value="<%=name%>">

   <tr>
    <td class="item ; dotline01" height="22" width="22%">เลขที่เอกสาร :
      :</td>
    <td height="22" width="35%" class="dotline01"><%=docno%></td>
    <td height="22" class="item ; dotline01" width="6%">เดือน : </td>
    <td height="22" width="12%" class="dotline01"><%=month[Integer.parseInt(i_month)]%></td>
    <td width="3%" class="item ; dotline01">ปี : </td>
    <td width="22%" class="dotline01"><%=i_year%></td>
  </tr>

   <tr>
    <td class="item ; dotline01" height="22">เลขที่บัตรประชาชน / Passport
      :</td>
    <td height="22" class="dotline01"><%=id_card%></td>
    <td height="22" class="item ; dotline01">ชื่อ
      :</td>
    <td height="22" colspan="3" class="dotline01"><%=name%></td>
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
                <td class="item_tab2" width="150">เอกสารขออนุมัติ</td>
                <td class="item_tab3"></td>
                <td>&nbsp;</td>                
              </tr>
            </table>




<table border="0" width="100%" cellspacing="0" cellpadding="0">

<tr>

<td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>

<td valign="bottom" class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>

<td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>

</tr>

</table>



<table border="0" width="100%" cellspacing="0" cellpadding="0">

<tr>

<td width="100%" class="frmL" align="center">

<table border="0" width="100%" cellspacing="0" cellpadding="0">

<tr>
<td width="15%" class="col_name"><a href="#">วันที่</a></td>
<td width="15%" class="col_name"><a href="#">เวลาเข้างานจริง</a></td>
<td width="15%" class="col_name"><a href="#">เวลาออกงานจริง</a></td>
<td width="15%" class="col_name"><a href="#">เวลาเข้างานจริง (แก้ไข)</a></td>
<td width="15%" class="col_name"><a href="#">เวลาออกงานจริง (แก้ไข)</a></td>
<td width="25%" class="col_name"><a href="#">หมายเหตุ</a></td>
</tr>
<%

   sql.delete(0,sql.length());	
   sql.append("select * from lan:serv_fingerdt ")
		.append("where i_docno = '"+docno+"' ")
		.append("order by i_date ");
   //out.println(sql.toString());					
	rs = stmt.executeQuery(sql.toString());					
    while (rs.next()==true) {
			
			i_date = doString.checkString(rs.getString("i_date"), "-");
			if (!i_date.equals("-")) {
					i_date = i_date.substring(8,10)+"/"+i_date.substring(5,7)+"/"+i_date.substring(0,4);			
			}
%>


<tr>
<td align="center" class="dotline ; item" ><%=i_date%></td>
<td class="dotline" align="center"><%=doString.checkString(rs.getString("i_checkin"))%></td>
<td class="dotline"><%=doString.checkString(rs.getString("i_checkout"))%></td>
<td class="dotline" align="center"><%=doString.checkString(rs.getString("i_checkin_new"))%></td>
<td class="dotline" align="center"><%=doString.checkString(rs.getString("i_checkout_new"))%></td>
<td class="dotline" align="center"><%=doString.checkString(doString.DisplayThai(rs.getString("i_comment")))%></td>
</tr>


<%
	}  // end while
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

<%   if (status.equals("OPN") && !userwho.equals("V")) {   %>
<A href="javascript:chkValue('APV','<%=user_id%>','<%=user_password%>','<%=project%>','<%=emp_appr%>','<%=docno%>','<%=id_card%>')">
<img border="0" src="images/act_approve.gif" onmouseout=nereidFade(this,70,50,5) onmouseover=nereidFade(this,100,50,5) style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp;<A href="javascript:chkValue('CAN','<%=user_id%>','<%=user_password%>','<%=project%>','<%=emp_appr%>','<%=docno%>','<%=id_card%>')"><img border="0" src="images/act_deny.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
<%  } %>
</td> 

<td class="act_tab3"></td> 

<td class="act_tab4"><a href="javascript:history.back()" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;

<a href="/LHServ/SERV_WageHome.jsp" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td> 

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
		System.out.println("ERROR SERV_WageAppr.jsp : " + e.getMessage());
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
