<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="javax.servlet.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="serv.common.Constants"%>
<%@ include file="confirmLogin.jsp" %>

<%
String empId = "";
String userId = "";
if (user!=null) {
   empId = user.getEmpId();
   userId = user.getUserID();
} 

String popup = doString.checkString(request.getParameter("popup"));
String error = doString.checkString(request.getParameter("error"),"");
String vendor = doString.DisplayThai(doString.checkString(request.getParameter("vendor"),""));
String targetPage = doString.MS874ToUnicode(doString.checkString(request.getParameter("redirect_url"), Constants.APP_HOME));
String action = "act_ok";
String comId = doString.checkString(request.getParameter("comId"));
String projId = doString.checkString(request.getParameter("projId"));
String docNo = doString.checkString(request.getParameter("docNo"));
String prntPayIn = doString.checkString(request.getParameter("prntPayIn"),"false");
String otherMsg = "";
if (popup.equals("true")) {
	targetPage = "javascript:setVendor()";
}
String homePage = "SERV_Home.jsp";
String target = "_self";
if (prntPayIn.equals("true"))
{
	targetPage = "PrintPayInServlet";
	action = "act_print";
}

if (user==null) {
    targetPage = "warning.htm";
}

//if (request.getQueryString() != null) {
//	targetPage = Constants.APP_PATH+"/"+request.getQueryString();
//}
%>

<HTML>
<HEAD>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<meta http-equiv="Content-Language" content="th">
<TITLE>Save</TITLE>

<link rel="STYLESHEET" type="text/css" href="SERV_Style.css">
<script src="script_fx.js" type="text/javascript"></script>


<base target="_self">

<script language="JavaScript" fptype="dynamicanimation">
<!--
function dynAnimation() {}
function clickSwapImg() {}
//-->
</script>
<script language="JavaScript1.2" fptype="dynamicanimation" src="animate.js">
</script>

<SCRIPT LANGUAGE="JavaScript">
<!-- Begin

function setVendor()
{
	with (self.opener.document.frmAddReten) {
		guarantor.value = "<%=vendor%>";
	}
	top.window.close();
}

function printPayIn(frm) {
	frm.target = "_blank";
	frm.submit();
}
// End -->
</script>
</HEAD>

<BODY topmargin="0" leftmargin="0" class="body1" onload="dynAnimation()">



<FORM name="save_ok" method="post" action="/LHServ/<%=targetPage%>">
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
      

      <P align="center" dynamicanimation="fpAnimzoomOutFP1" id="fpAnimzoomOutFP1" style="position: relative !important; visibility: hidden" language="Javascript1.2">&nbsp;. . <FONT color="#800000">
		<%
		     if (error.length()>0 && !error.equals("0")) { 
				out.println("การบันทึกมีปัญหาโปรดลองอีกครั้ง . . เริ่มต้นใหม่");
		     } else { 
				out.println("การจัดเก็บข้อมูลเรียบร้อยแล้ว . . ");
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