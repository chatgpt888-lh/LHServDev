<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="javax.servlet.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="serv.common.Constants"%>
<%@page import="java.util.*" %>
<%@ include file="confirmLogin.jsp" %>

<%
String empId = "";
String userId = "";
if (user!=null) {
   empId = user.getEmpId();
   userId = user.getUserID();
} 

String popup = doString.checkString(request.getParameter("popup"));
String venType = doString.checkString(request.getParameter("venType"));
String error = doString.checkString(request.getParameter("error"),"");
String otherMsg = doString.MS874ToUnicode(doString.checkString(request.getParameter("other_msg"),""));
String vendor = doString.DisplayThai(doString.checkString(request.getParameter("vendor"),""));
String targetPage = doString.MS874ToUnicode(doString.checkString(request.getParameter("redirect_url"), Constants.APP_HOME));

//modify by pradoem 2016.08.08
if(!targetPage.equals("")){
   targetPage = targetPage.replace("|","&");
}
//System.out.println("targetPage=="+targetPage);
String action = "act_ok";
String comId = doString.checkString(request.getParameter("comId"));
String projId = doString.checkString(request.getParameter("projId"));
String docNo = doString.checkString(request.getParameter("docNo"));
String between = doString.checkString(request.getParameter("between"));
String month = doString.checkString(request.getParameter("Month"));
String year = doString.checkString(request.getParameter("Year"));
if (!between.equals("")) {
	targetPage += "&Month="+month+"&Year="+year+"&between="+between;
}
String prntPayIn = doString.checkString(request.getParameter("prntPayIn"),"false");
if (popup.equals("true")) {
	targetPage = "javascript:setVendor()";
	if (venType.equals("I")) {
		targetPage = "javascript:setInfVendor()";
	}
}

String homePage = "SERV_Home.jsp";
String target = "_self";
if (prntPayIn.equals("true"))
{
	// 2019-08-19 , chagnge print servlet ## targetPage = "PrintPayInServlet";
	targetPage = "SERV_PrintPayInCBServlet";
	action = "act_print";
}

if (user==null) {
    targetPage = "warning.htm";
}

//---- 2022-02-01 , redirect "PrintPayInServlet" to "SERV_PrintPayInCBServlet" -----//
if (targetPage.equalsIgnoreCase("PrintPayInServlet")) {
		targetPage = "SERV_PrintPayInCBServlet";
		action = "act_print";
}

//if (request.getQueryString() != null) {
//	targetPage = Constants.APP_PATH+"/"+request.getQueryString();
//}

/*
String ParameterNames = "";
for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
	ParameterNames = (String)e.nextElement();
	System.out.println(ParameterNames + " = "+request.getParameter(ParameterNames));
}
System.out.println("*******************************************");
System.out.println("******************xxxxxxxxxx*************************");
*/

%>

<HTML>
<HEAD>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<meta http-equiv="Content-Language" content="th">
<TITLE>Save</TITLE>

<!-- loading onverlay by pradoem 2023.02 -->
<script src="jquery3/jquery.min3.6.3.js" ></script>
<script src="jquery3/loadingoverlay.min2.1.7.js"></script>

<link rel="STYLESHEET" type="text/css" href="SERV_Style.css">
<script src="script_fx.js" type="text/javascript"></script>
<base target="_self">

<SCRIPT LANGUAGE="JavaScript">
<!-- Begin

function setVendor()
{
	with (self.opener.document.frmAddReten) {
		guarantor.value = "<%=vendor%>";
	}
	
	//--- 2022-06-30 , set payin name ---//
	if (self.opener.setPayInName!=null) {
		self.opener.setPayInName();
	}	
	//-----------------------------------//
	
	top.window.close();
}
function setInfVendor()
{
	with (self.opener.document.frmEdtInfra) {
		payer.value = "<%=vendor%>";
	}
	top.window.close();
}
function printPayIn(frm) {
	pleaseWaiting();
	frm.target = "_blank";
	frm.submit();
}

  function pleaseWaiting(){
   $.LoadingOverlay("show");
	// Hide it after 3 seconds
	setTimeout(function(){
	    $.LoadingOverlay("hide");
	}, 7000);
  }
  
  function doSubmitForm(url){
    //alert("submit");
     pleaseWaiting();
 	$('form').attr('action', url);
	$("form:first").submit();
}
// End -->
</script>
</HEAD>

<BODY topmargin="0" leftmargin="0" class="body1" >

<FORM name="save_ok" method="post" action="/LHServ/<%=targetPage%>">
<INPUT type="hidden" name="sel_project" value="<%=comId+":"+projId%>">
<INPUT type="hidden" name="comId" value="<%=comId%>">
<INPUT type="hidden" name="projId" value="<%=projId%>">
<INPUT type="hidden" name="docNo" value="<%=docNo%>">
<INPUT type="hidden" name="empId" value="<%=empId%>">
<INPUT type="hidden" name="userId" value="<%=userId%>">
<%
if (targetPage.equals("SERV_Disp_Reten.jsp")) {
	targetPage += "?comId="+comId +"&projId="+projId+"&docNo="+docNo;
}
if (targetPage.equals("PrintPayInServlet")) {
	//targetPage += "?comId="+comId +"&projId="+projId+"&docNo="+docNo;
	//targetPage = "javascript:save_ok.submit()";
	targetPage = "javascript:printPayIn(save_ok)";
	target = "_blank";
	homePage = "SERV_RetenHome.jsp";
	action = "act_print";
}
if (targetPage.equals("PrintRetRetenServlet")) {
	//targetPage += "?comId="+comId +"&projId="+projId+"&docNo="+docNo;
	//targetPage = "javascript:save_ok.submit()";
	targetPage = "javascript:printPayIn(save_ok)";
	target = "_blank";
	homePage = "SERV_RetenHome.jsp";
	action = "act_print";
}

//---- 2022-02-01 , redirect "PrintPayInServlet" to "SERV_PrintPayInCBServlet" -----//
if (targetPage.equalsIgnoreCase("SERV_PrintPayInCBServlet")) {
	targetPage = "javascript:printPayIn(save_ok)";
	target = "_blank";
	homePage = "SERV_RetenHome.jsp";
	action = "act_print";
}


%>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%">

<div style="position: relative ; width: 450px ; left: 170px ; top:20 px ; text-align: center">

      <table border="0" width="440" height="10" cellspacing="0" cellpadding="0" class="edge1">
        <tr>
          <td width="100%">
          &nbsp;
          </td>
        </tr>
      </table>

      <table border="0" width="450" cellspacing="0" cellpadding="0">
        <tr>
          <td width="10" class="edge3">&nbsp;</td>
          <td width="430" align="center">
          
          
<table border="0" width="100%" cellspacing="1" cellpadding="0">
  <tr>
    <td width="100%" align="center">
        <center>
   
  &nbsp;

  <table border="0" width="85%" cellspacing="0" cellpadding="0" height="25">
    <tr>
      <td width="99%" class="alert">

<img border="0" src="images/i_save.gif" align="absmiddle" width="18" height="18">&nbsp; S a v e   

      </td>    
    </tr>    
  </table>    
 
     <br style="font-size:4pt">     
      <table border="0" width="85%" bgcolor="#C8E6FF" cellspacing="1" cellpadding="0" height="60">   
      <tr>   
     <TD bgcolor=#F0FAFF align="center">   
  
<br style="font-size:10pt">   
      

      <P align="center" >&nbsp;. . <FONT color="#800000">
		<%
		     if (error.length()>0 && !error.equals("0")) { 
				out.println("การบันทึกมีปัญหาโปรดลองอีกครั้ง . . เริ่มต้นใหม่");
		     } else { 
				out.println("การจัดเก็บข้อมูลเรียบร้อยแล้ว . . ");
				//update by pradoem :2014.04.30
				if(!"".equals(docNo)){
				  	out.println("<br>เลขที่เอกสาร : "+docNo);
				}
		     }
		     
		     if (otherMsg.length()>0) {
		        out.println("<br><br> <span style='color:red'>["+otherMsg+"]</span> ");
		     }  		
		%>		
	  <BR><br>
      </FONT><IMG border="0" src="images/i_save.gif" ></P><br><br>
   </TD>    
      </tr>    
     </table>    
      </center>  
        <br style="font-size:6pt">   
        <table border="0" width="85%" cellspacing="0" cellpadding="0" height="30">   
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">
            <a href="<%=targetPage%>" ><img border="0" src="images/<%=action%>.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>   
             
            </td>   
            <td class="act_tab3"></td>   
            <td class="act_tab4">   
<%if (popup.equals("true")) {%>
             <a href="javascript:top.window.close()">
                  <img border="0" src="images/bu_close.gif" align="top" width="50" height="15"></a>
<%} else {%>
              <a href="<%=homePage%>"><img border="0" src="images/bu_home.gif" align="top"                                  
    		onmouseout=nereidFade(this,70,50,5)   
                onmouseover=nereidFade(this,100,50,5)    
                style="FILTER: alpha(opacity=70)" width="50" height="15"></a>
<%}%>
		  </td>  
          </tr>
        </table>    
     <br style="font-size:10pt">      
    </td>
  </tr>
</table>
          </td>
          <td width="10" class="edge4">&nbsp;</td>
        </tr>
      </table>

      <table border="0" width="440" height="10" cellspacing="0" cellpadding="0" class="edge2">
        <tr>
          <td width="100%">&nbsp;</td>
        </tr>
      </table>
    
</div>
<br style="font-size:15pt">
<div style="position:relative ; width: 500px ; left:180px ; top:10px">

<TABLE border=0 cellspacing=0 cellpadding=0>
  <tr><td width="100%" class="copyright" align="left">
  Best viewed with 800x600 screen resolution&nbsp;<br>
 on&nbsp;an Internet Explorer version 5 และ 5.5  
  <br>ติชมแสดงความคิดเห็น : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a> &nbsp;<br>
  หรือ Computer Department&nbsp; โทร 0-2230-8490-98, 0-2230-8451-3  
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE> 

</div>

   </td>
  </tr>
</table>
</FORM>

</BODY>
</HTML>