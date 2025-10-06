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
String error = doString.checkString(request.getParameter("error"),"");
String targetPage = doString.MS874ToUnicode(doString.checkString(request.getParameter("redirect_url"), Constants.APP_HOME));
String project = doString.checkString(request.getParameter("Project"));
String between = doString.checkString(request.getParameter("between"));
String beg_lock = doString.checkString(request.getParameter("beg_lock"));
String end_lock = doString.checkString(request.getParameter("end_lock"));
if (!between.equals("")) {
	targetPage += "&between="+between;
}
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

function printPayIn(frm) {
	frm.target = "_blank";
	frm.submit();
}
// End -->
</script>
</HEAD>

<BODY topmargin="0" leftmargin="0" class="body1" onload="dynAnimation()">



<FORM name="save_ok" method="post" action="/LHServ/PrintInfPayInServlet">
<INPUT type="hidden" name="empId" value="<%=empId%>">
<INPUT type="hidden" name="userId" value="<%=userId%>">
<INPUT type="hidden" name="Project" value="<%=project%>">
<INPUT type="hidden" name="between" value="<%=between%>">
<INPUT type="hidden" name="beg_lock" value="<%=beg_lock%>">
<INPUT type="hidden" name="end_lock" value="<%=end_lock%>">
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
            <td width="150" class="act_tab2">
            <a href="<%=targetPage%>" ><img border="0" src="images/act_ok.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp;   
                  	            
            <a href="javascript:printPayIn(save_ok)"><img border="0" src="images/act_print.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>   
             
            </td>   
            <td class="act_tab3"></td>   
            <td class="act_tab4">   
              <a href="SERV_InfHome.jsp"><img border="0" src="images/bu_home.gif" align="top"                                  
    		onmouseout=nereidFade(this,70,50,5)   
                onmouseover=nereidFade(this,100,50,5)    
                style="FILTER: alpha(opacity=70)" width="50" height="15"></a>
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