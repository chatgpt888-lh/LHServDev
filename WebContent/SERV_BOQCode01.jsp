<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
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
   String iEmpApp = doString.checkString(request.getParameter("i_employ_approve"),"");
   String cDesc1 = doString.checkString(request.getParameter("c_desc1"),"");
   String cDesc2 = doString.checkString(request.getParameter("c_desc2"),"");
   String cDesc3 = doString.checkString(request.getParameter("c_desc3"),"");
   String cDesc4 = doString.checkString(request.getParameter("c_desc4"),"");
   String cDesc5 = doString.checkString(request.getParameter("c_desc5"),"");
   
   //-----====================== Search BOQ Data ================================------//
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	SERV_CommonData common = null;
	   
	try {
	    doString str = new doString();
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();       
		common = new SERV_CommonData(conn); 
        //----=======================================----//    
        
%>

<HTML>
<HEAD>
<TITLE>ขอรหัส BOQ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--

function sendRequest() {
    var forms = document.forms[0];
    if (forms.c_desc1.value=="" && forms.c_desc2.value=="" && forms.c_desc3.value=="" && 
        forms.c_desc4.value=="" && forms.c_desc5.value=="") {
        alert(" กรุณากรอกรายการขอ BOQ อย่างน้อย 1 รายการ !");
        return false;
    }
    
    if (forms.i_employ_approve.value=="") {
        alert(" กรุณาเลือกผู้อนุมัติ !");
        return false;
    }    
    
    forms.action = "<%=Constants.APP_PATH%>/SERV_BOQCodeServlet";
    forms.submit();
    
}

//-->
</script>


<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">

<input type="hidden" name="mode" value="add">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ขอรหัส BOQ</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดการขอรหัส
                  BOQ</td>
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
    <td class="item ; dotline01" height="30" width="10%">ผู้ขออนุมัติ
      :</td>
    <td height="30" width="50%" class="dotline01"><%=doString.DisplayThai(doString.checkString(user.getEmpName(),"-"))%></td>
    <td height="30" class="item ; dotline01" width="10%">Ref No. :</td>
    <td height="30" width="30%" class="dotline01">Auto Generate</td>
  </tr>
</table>


</td>
  </tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR" align="center">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td class="item ; dotline01" height="30" width="10%">รายการที่ 1 :</td>
    <td height="25" width="90%" class="dotline01"><input type="text" name="c_desc1" class="box" style="width:100%" size="20" value="<%=cDesc1%>"></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="30" width="10%">รายการที่ 2 :</td>
    <td height="25" width="90%" class="dotline01"><input type="text" name="c_desc2" class="box" style="width:100%" size="20" value="<%=cDesc2%>"></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="30" width="10%">รายการที่ 3 :</td>
    <td height="25" width="90%" class="dotline01"><input type="text" name="c_desc3" class="box" style="width:100%" size="20" value="<%=cDesc3%>"></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="30" width="10%">รายการที่ 4 :</td>
    <td height="25" width="90%" class="dotline01"><input type="text" name="c_desc4" class="box" style="width:100%" size="20" value="<%=cDesc4%>"></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="30" width="10%">รายการที่ 5 :</td>
    <td height="25" width="90%" class="dotline01"><input type="text" name="c_desc5" class="box" style="width:100%" size="20" value="<%=cDesc5%>"></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="30" width="10%">ผู้อนุมัติ
      :</td>
    <td height="25" width="90%" class="dotline01"><%=common.genBOQApproverList("i_employ_approve",iEmpApp," class='box' style='width:250px' ","wachirap")%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="30" width="10%">&nbsp;</td>
    <td height="25" width="90%" class="dotline01">&nbsp;</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="30" width="10%">&nbsp;</td>
    <td height="25" width="90%" class="dotline01">&nbsp;</td>
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



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">

            <a href="#" onclick="sendRequest();"><img border="0" src="images/act_send2app.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>

            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_BOQSearch.jsp" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
		System.out.println("ERROR SERV_BOQCode01.jsp : " + e.getMessage());
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