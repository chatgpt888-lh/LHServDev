<%@page language="java" contentType="text/html; charset=tis-620"
	pageEncoding="tis-620"%>
<%@ page import="com.svc.call.utilize.Constant" %>	
	
<HTML>
<HEAD>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<meta http-equiv="Content-Language" content="th">
<TITLE>ระบบมีข้อผิดผลาด(Error Massage)</TITLE>
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
</HEAD>
<BODY topmargin="0" leftmargin="0" class="body1" onLoad="dynAnimation()">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%">

<div style="position: relative ; width: 650px ; left: 170px ; top:20 px ; text-align: center">

      <table border="0" width="640" height="10" cellspacing="0" cellpadding="0" class="edge1">
        <tr>
          <td width="100%">&nbsp;
          
          </td>
        </tr>
      </table>

      <table border="0" width="650" cellspacing="0" cellpadding="0">
        <tr>
          <td width="10" class="edge3">&nbsp;</td>
          <td width="630" align="center">

<table border="0" width="100%" cellspacing="1" cellpadding="0">
  <tr>
    <td width="100%" align="center">
        <center>
  &nbsp;<table border="0" width="85%" cellspacing="0" cellpadding="0" height="25">
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
      
<p dynamicanimation="fpAnimzoomOutFP1" id="fpAnimzoomOutFP1" style="position: relative !important; visibility: hidden" language="Javascript1.2">
&nbsp;ระบบมีข้อผิดผลาดกรุณาทำรายการใหม่!!!</p>

<br style="font-size:5pt">   

   </TD>    
      </tr>    
     </table>    
      </center>    

<br style="font-size:10pt">
 
        <table border="0" width="85%" cellspacing="0" cellpadding="0" height="30">   
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">
            &nbsp;
            <%-- 
            <a href="HomeServiceCenter2.html" target="_self"><img border="0" src="images/act_NewJob.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>  
              --%>    	        
              </td>   
            <td class="act_tab3"></td>   
            <td class="act_tab4">   
             <a href="javascript:top.window.close()">
                  <img border="0" src="images/bu_close.gif" align="top" width="50" height="15"></a></td>  
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


      <table border="0" width="640" height="10" cellspacing="0" cellpadding="0" class="edge2">
        <tr>
          <td width="100%">&nbsp;</td>
        </tr>
      </table>
</div>

<br style="font-size:15pt">

<div style="position:relative ; width: 500px ; left:180px ; top:10px">

<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
  <tr><td width="100%" class="copyright" align="center">
  Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5
  <br>ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;
  หรือ โทร. 0-2230-8279 (คุณประพัฒน์
  ฝ่ายบริการ)&nbsp; 0-2230-8491-5 (ฝ่าย IT)
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE>

</div>

   </td>
  </tr>
</table>
</BODY>
</HTML>
<%				
//------Clean session
try{
	synchronized(session){
		//session.removeAttribute(Constant.SS_PROJECT_AVAILABLE_LIST);//remove
		//session.removeAttribute(Constant.SS_POPUP_PROJECT_LIST);//remove
		//session.removeAttribute(Constant.SS_NAME_STANDARD_LIST);
		//session.removeAttribute(Constant.SS_GHOME_REPAIR_LIST);
		//session.removeAttribute(Constant.SS_GPUBLIC_SERVICE_LIST);
		session.invalidate();	
	}	
}catch(Exception e){}	   					
%>