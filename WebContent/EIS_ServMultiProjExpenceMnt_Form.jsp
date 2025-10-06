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
<%@ page import="serv.common.User"%>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>

<%!
	// Caching the DataSource - It is obtained in the jspInit() method
	private javax.sql.DataSource ds = null;
	private String dsName = Constants.JDBC_LAN;
	
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
<HTML>

<HEAD>
<TITLE>รายงานต้นทุนทางอ้อม / ค่าใช้จ่าย</TITLE>

<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="EIS_MainStyle.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
function MoveSelect(FromBox, TargetBox, Type) {
	var ArrFromBox = new Array();
	var ArrTargetBox = new Array();
	var ArrLookup = new Array();

	for (i = 0; i < TargetBox.options.length; i++) {
		ArrLookup[TargetBox.options[i].text] = TargetBox.options[i].value;
		ArrTargetBox[i] = TargetBox.options[i].text;
	}

	var FromLen = 0;
	var TargetLen = ArrTargetBox.length;
	for(i = 0; i < FromBox.options.length; i++) {
		ArrLookup[FromBox.options[i].text] = FromBox.options[i].value;
		if (FromBox.options[i].value != "" && (Type == 'ALL' || (Type == 'SEL' && FromBox.options[i].selected))){
			ArrTargetBox[TargetLen] = FromBox.options[i].text;
			TargetLen++;
		} else {
			ArrFromBox[FromLen] = FromBox.options[i].text;
			FromLen++;
	   }
	}
	ArrFromBox.sort();
	ArrTargetBox.sort();
	FromBox.length = 0;
	TargetBox.length = 0;
	for(i = 0; i < ArrFromBox.length; i++) {
		var Box = new Option();
		Box.value = ArrLookup[ArrFromBox[i]];
		Box.text = ArrFromBox[i];
		FromBox[i] = Box;
	}
	for(i = 0; i < ArrTargetBox.length; i++) {
		var Box = new Option();
		Box.value = ArrLookup[ArrTargetBox[i]];
		Box.text = ArrTargetBox[i];
		TargetBox[i] = Box;
	}
}

  function goReport() {

	 if (document.forms[0].sel_proj.options.length==0) {
		 alert(" กรุณาเลือกโครงการอย่างน้อย 1 โครงการ !");
		 return false;
	 }
	  if (document.forms[0].sel_proj.options.length>20) {
		 alert(" กรุณาเลือกโครงการไม่เกิน 20 โครงการ !");
		 return false;
	 }

	 for (i = 0; i < document.forms[0].sel_proj.options.length; i++) {
		document.forms[0].sel_proj.options[i].selected = true;
	 }
     document.forms[0].action="<%=Constants.APP_PATH%>/EIS_ServMultiProjExpenceMnt_List.jsp";
     document.forms[0].submit();
  }

</script>

<base target="_self">

</HEAD>

<BODY leftMargin=10 topMargin=5 marginwidth="10" marginheight="5">
<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "EIS_ServMultiProjExpenceMnt_Form.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

String Who = user.getUserWho();
StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;
	try {
	if (ds == null)
	{
		getDS();
	}
conn = ds.getConnection();
conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
stmt = conn.createStatement();

Calendar rightNow = Calendar.getInstance();
int Byear = 0, Eyear = 0;
String i_com = "",i_proj = "", acct_desc = "", chk_link = "", monthly = "", acct_name = "";
//String project = "-";
/*if (request.getParameter("project") != null) {
	project = doString.checkString(request.getParameter("project"),"-");
}*/
String project = doString.checkString(request.getParameter("project"),"-");

//out.println("project="+project);
if (!project.equals("-")) {
	i_com = request.getParameter("project").substring(0,2);
	i_proj = request.getParameter("project").substring(2,5);
}



String typecost = "A";  
if (request.getParameter("typecost") != null) {
	typecost = doString.checkString(request.getParameter("typecost"));
}
String year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
if (request.getParameter("year") != null) {
	year = request.getParameter("year");
}
String dept = "";
if (request.getParameter("dept") != null) {
	dept = doString.checkString(request.getParameter("dept"));
}
String display = "";
/*if (Who.equals("A")) {
	dept = "";
	display = "";
} else {
	display = "disabled";	
	dept = "03";
}*/

if (!Who.equals("A") && !Who.equals("T")) { 
	display = "disabled";	
	dept = "03";
}



%>
<FORM NAME="frmEIS" METHOD=POST >


  <br style="font-size:5pt">  
  
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            รายงานต้นทุนทางอ้อม / ค่าใช้จ่าย แยกรายเดือน</td>
        </tr>
      </table>

<br style="font-size:8pt">
	<table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="300">โปรดระบุรายละเอียด</td>
                <td class="item_tab3"></td>
                <td class="item_tab4">&nbsp;</td>
                <td class="item_tab5"></td>
              </tr>
            </table>
           
  <table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop">&nbsp;</td>
    <td width="5" valign="top" align="right"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>          

  <table border="0" width="100%" cellspacing="1" cellpadding="0">
    <tr>
     
	  <td width="10%" class="item : 10pt" height="28">ประจำปี : </td>
      <td width="50%" height="28"><SELECT size="1" name="year" class="box" style="width:80px"> 
	  <%	 
	    String option = "";
		Byear = Integer.parseInt(year) - 5;
		Eyear = Integer.parseInt(year) + 5;
		for(int i = Byear;  i <= Eyear;  i++ ){
			option = "";
			if (i == Integer.parseInt(year)) {
				option = " Selected ";
			}		
%> 
                  <OPTION value="<%=i%>" <%=option%>><%=i%></OPTION>
<%
		} // End for
%> 
		</SELECT></td>
    </tr>
     <tr>
      <td width="10%" class="item : 10pt" height="28" bgcolor="#F6F6F6">ประเภทค่าใช้จ่าย : </td>
      <td width="30%" height="28" bgcolor="#F6F6F6">&nbsp;<select size="1" name="typecost" class="box" style="width:180px">
              <option value="A" <% if (typecost.equals("A")) { out.print("Selected"); } %>>โครงการ</option>
              <option value="B" <% if (typecost.equals("B")) { out.print("Selected"); } %>>ปันส่วนจากกลุ่ม</option>
              <option value="C" <% if (typecost.equals("C")) { out.print("Selected"); } %>>ส่วนกลาง</option>
              <option value="D" <% if (typecost.equals("D")) { out.print("Selected"); } %>>โครงการ+ปันส่วนจากกลุ่ม</option>
              <option value="E" <% if (typecost.equals("E")) { out.print("Selected"); } %>>ทั้งหมด</option>
            </select></td>

<td width="10%" class="item : 10pt" height="28" bgcolor="#F6F6F6">ค่าใช้จ่ายฝ่าย/กลุ่ม :</td>
      <td width="50%" height="28" bgcolor="#F6F6F6">&nbsp;<SELECT size="1" name="dept" class="box" style="width:80px" <%=display%>> 
                  <OPTION value="03"<% if (dept.equals("03")) { out.print("Selected"); } %>>บริการ</OPTION> 
                  <OPTION value="02"<% if (dept.equals("02")) { out.print("Selected"); } %>>PJ</OPTION> 
                  <OPTION value="01"<% if (dept.equals("01")) { out.print("Selected"); } %>>PM / VP</OPTION>
</SELECT></td>
</tr>
</table>

  
  
  <table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>


<br style="font-size:2pt">





  <!-- project list box -->
    <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr> 
          <td width="100%" class="frmL"><table border="0" width="98%" cellspacing="1" cellpadding="0">
              <tr> 
                <td width="8%" align="center" valign="top" bgcolor="#F5F5F5"> 
                  <p> </p></td>
                <td width="38%" valign="top" bgcolor="#F5F5F5">
				  <select size="15" name="all_proj" multiple class="box" style="width:300px" ondblclick="MoveSelect(frmEIS.all_proj, frmEIS.sel_proj,'SEL');">
					<%
			if(user.getUserWho().equals("T") || user.getUserWho().equals("C") || user.getUserWho().equals("A") || user.getUserID().equals("piyapong")) { 
	    
			sql.delete(0, sql.length());
			sql.append("select distinct b.i_company, b.i_project, b.n_project ")
				.append("from lan:acsbudgh a, lan:acxprojt b ")
				.append("where a.d_year in ("+Integer.parseInt(year)+") ")
				.append("and a.i_budg_type in ('1','2','9') ")
				.append("and a.i_company = b.i_company ")
				.append("and a.i_project = b.i_project ")
				.append("order by 1,2,3 ");
			} else {

		   sql.delete(0, sql.length());
		   sql.append("select distinct b.i_company, b.i_project, b.n_project ")
				.append("from lan:serv_pstaff a, lan:acxprojt b ") 
				.append("where a.user_id = '"+user.getUserID()+"' ")
				.append("and a.com_id = b.i_company ")
				.append("and a.proj_id = b.i_project ") 
				.append("order by 1,2,3 ");
			}
						 servlog.startLog(sql.toString());
						 rs = stmt.executeQuery(sql.toString());
						 servlog.endLog();
						 while (rs.next()) {
							 String comId = doString.checkString(rs.getString("i_company"),"");
							 String projId = doString.checkString(rs.getString("i_project"),"");
							 String nProj = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");


							 %><option value='<%=comId+":"+projId%>'><%="["+comId+"-"+projId+"] - "+nProj%></option><%
						 }
						 rs.close();




					%>
				 </select>
				 </td>
                <td width="6%" align="center" valign="middle" bgcolor="#F5F5F5"> 
                  <table border="0" width="100%" cellspacing="1" cellpadding="0">
                    <tr> 
                      <td width="100%" align="center" height="30" bgcolor="#F0F0F0"> 
						<a href="javascript:MoveSelect(frmEIS.all_proj, frmEIS.sel_proj,'SEL')"><img border="0" src="images/b_r.gif" align="absmiddle" vspace="5" hspace="5" alt="Add"></a>
                      </td>
                    </tr>
                    <tr> 
                      <td width="100%" align="center" height="30" bgcolor="#F0F0F0"> 
                       <a href="javascript:MoveSelect(frmEIS.all_proj, frmEIS.sel_proj,'ALL')"><img border="0" src="images/b_rr.gif" align="absmiddle" vspace="5" hspace="5" alt="Add All">
                      </td>
                    </tr>
                    <tr> 
                      <td width="100%" align="center" height="30" bgcolor="#F0F0F0"> 
                        <a href="javascript:MoveSelect(frmEIS.sel_proj, frmEIS.all_proj,'ALL')"><img border="0" src="images/b_ll.gif" align="absmiddle" vspace="5" hspace="5" alt="Remove All"></a>
                      </td>
                    </tr>
                    <tr> 
                      <td width="100%" align="center" height="30" bgcolor="#F0F0F0"> 
                        <a href="javascript:MoveSelect(frmEIS.sel_proj, frmEIS.all_proj,'SEL')"><img border="0" src="images/b_l.gif" align="absmiddle" vspace="5" hspace="5" alt="Remove"></a>
                      </td>
                    </tr>
                  </table></td>
                <td width="38%" align="right" valign="top" bgcolor="#F5F5F5"> 
				  <select size="15" name="sel_proj" multiple class="box" style="width:300px" ondblclick="MoveSelect(frmEIS.sel_proj, frmEIS.all_proj,'SEL');">
				  </select>                  
				 </td>
                <td width="10%" align="center" valign="top" bgcolor="#F5F5F5">&nbsp; 
                </td>
              </tr>
              <tr> 
                <td align="center" valign="top" bgcolor="#F5F5F5" colspan="2">&nbsp;</td>
                <td width="6%" align="center" valign="top" bgcolor="#F5F5F5">&nbsp;</td>
                <td align="center" valign="top" bgcolor="#F5F5F5" colspan="2">&nbsp; 
                </td>
              </tr>
            </table></td>
        </tr>
      </table>
 
<br style="font-size:5pt">
	<table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">&nbsp;<a href="#" onclick="javascript:goReport();"><img border="0" src="images/act_submit.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp; </td>          	
			<td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:history.back()"><img border="0" src="images/bu_back.gif" width="50" height="15"></a><a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" width="50" height="15"></a></td>  
          </tr>  
        </table>  	

<br style="font-size:20pt">
<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
  <tr><td width="100%" class="copyright" align="center">
  Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5  
  <br>ติชมแสดงความคิดเห็น : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a> &nbsp;หรือ Computer Department&nbsp; โทร
  0-2230-8490-98, 0-2230-8451-3  
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE> 
<%
	stmt.close();
	conn.close();
	stmt = null;
	conn = null;
}
catch (Exception e) {
	System.out.println("!!!ERROR EIS_ServMultiProjExpenceMnt_Form.jsp : " + e.getMessage());
	System.out.println("!!!ERROR EIS_ServMultiProjExpenceMnt_Form.jsp SQL : " + sql.toString());
	throw new ServletException(e.getMessage());
}
finally {
	// Clean up.
	try {
		if (rs != null)
			rs.close();
		if (stmt != null)
			stmt.close();
		if (conn != null)
			conn.close();
	}
	catch( SQLException ignore ){}
}
%>
</FORM>

</BODY>
</HTML>