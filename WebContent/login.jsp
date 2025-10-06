<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="serv.common.*" %>
<%@page session="false" %>

<%
	response.setHeader("Cache-Control", "no-cache");
	response.setHeader("Pragma", "no-cache");
	response.setDateHeader("Expires", 0);
	
	String error = null;
	if (request.getParameter("error") != null) {
		error = (String)request.getParameter("error");
	} else {
		error = "0";
	}
	
	String qc = "false";
	if (request.getParameter("qc") != null) {
		qc = request.getParameter("qc");
	}
	String main = "";
	if (request.getParameter("main") != null) {
		main = request.getParameter("main");
	}
	
	User user = (User) request.getSession().getAttribute("USER");
%>
<HTML>
<HEAD>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<meta http-equiv="Content-Language" content="th">
<TITLE>key login SERV</TITLE>

<link rel="STYLESHEET" type="text/css" href="SERV_Style.css">
<script src="script_fx.js" type="text/javascript"></script>
<SCRIPT language="JavaScript">
<!--

function initform() {
	document.loginForm.userid.focus();
}

function submitLogin() {
	txt = Trim(document.loginForm.userid.value);
	if (txt.length == 0) {
		alert("กรุณาระบุรหัสผู้ใช้");
		document.loginForm.userid.value="";
		document.loginForm.userid.focus();
		return false;
	}
	txt = Trim(document.loginForm.password.value);
	if (txt.length == 0) {
		alert("กรุณาระบุรหัสผ่าน");
		document.loginForm.password.value="";
		document.loginForm.password.focus();
		return false;
	}

    /* perform any validation here */
    return true;
}

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

function getCookieVal(offset)
{
	var endstr = document.cookie.indexOf(";", offset);
	if( endstr == -1 )
	endstr = document.cookie.length;
	return unescape( document.cookie.substring(offset,endstr) );
}

function GetCookie(name)
{
	var arg = name + "=";
	var alen = arg.length;
	var clen = document.cookie.length;
	var i = 0;
	while (i < clen)
	{
		var j = i + alen;
		if( document.cookie.substring(i,j) == arg )
			return getCookieVal(j);
		i = document.cookie.indexOf(" ", i) + 1;
		if( i == 0 ) break;
	}
	return null;
}

//-->
</SCRIPT>

<%
   if (user!=null) {
		%>
		<SCRIPT language="JavaScript">
		<!--
			if (GetCookie("<%=Constants.COOKIE_NAME%>") == "yes")
			{
				if(null != main){
					mainPage = document.location.protocol + "//" + document.location.host + "<%=Constants.APP_PATH%>" + "/" +main;
					location.replace (mainPage);
				}else{
					mainPage = document.location.protocol + "//" + document.location.host + "<%=Constants.APP_HOME%>";
					location.replace (mainPage);
				}
			}
		//-->
		</SCRIPT>
		<%
   }
%>

<base target="_self">

</HEAD>
<BODY onload="initform()" bgcolor="#FFFFFF" topmargin="0" leftmargin="0" class="body1">
<FORM name="loginForm" onsubmit="return submitLogin()" method="post" action="/LHServ/LoginServlet">
<input type="hidden" name="qc" value="<%=qc%>">
<INPUT type="hidden" name="dbName" value="lan">
<INPUT type="hidden" name="main" value="<%=main%>">


<table border="0" width="800" cellspacing="0" cellpadding="0">
  <tr>
    <td width="192"><img border="0" src="images/top_logo.gif" width="192" height="38"></td>
    <td rowspan="2" style="background-image: url('images/top_bg.gif'); background-repeat: no-repeat" bgcolor="#E5F2FD">&nbsp;
    <div style="position:absolute ; Z-index:2 ; left:380px ; top:15px ; width: 380px"  class="SysTitle">ระบบบริการหลังการขาย</div>
    <div style="position:absolute ; Z-index:1 ; left:381px ; top:16px ; width: 380px ; color: rgb(180,180,230)"  class="SysTitle">ระบบบริการหลังการขาย</div>    
    </td>
  </tr>
  <tr>
    <td width="192"><img border="0" src="images/top_intranet.gif" width="192" height="10"></td>
  </tr>
</table>




<table border="0" width="800px" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%">



<div style="position: relative ; width: 450px ; left: 170px ; top:20 px ; text-align: center">


      <table border="0" width="440" height="10" cellspacing="0" cellpadding="0" class="edge1">
        <tr>
          <td width="100%">&nbsp;
          
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
      <td width="99%">

<img border="0" src="images/i_alert.gif" align="absmiddle" width="20" height="20">&nbsp;
กรุณาระบุรหัสผู้ใช้และรหัสผ่านของท่าน   
    
    
      </td>    
    </tr>    
  </table>    
   
   


   
     <br style="font-size:4pt">   
   
   

     <table border="0" width="85%" bgcolor="#C8E6FF" cellspacing="1" cellpadding="0" height="60">   
      <tr>   
     <TD bgcolor=#F0FAFF align="center">   

   
     <br style="font-size:10pt">   
   
   

        <table border="0" width="90%" cellspacing="0" cellpadding="0">
          <tr>
            <td width="20%" >รหัสผู้ใช้ :</td> 
            <td width="80%"><input type="text" name="userid" class="box" style="width:150px"></td> 
          </tr> 
          <tr> 
            <td width="20%" >รหัสผ่าน :</td> 
            <td width="80%"><input type="password" name="password" class="box" style="width:150px"></td> 
          </tr> 
        </table> 
	         
		<br style="font-size:8pt">   

        <table border="0" width="90%" cellspacing="0" cellpadding="0">
		  <tr>
		    <td nowrap colspan="2"><FONT color="red"><B>
			<% 
				if( error.equals("1") ) { 
					%><FONT color="red">รหัสผู้ใช้หรือรหัสผ่านไม่ถูกต้อง กรุณาลองใหม่อีกครั้ง</FONT><% 
				}  else if (error.equals("2")) {
					%><FONT color="red">รหัสผ่านหมดอายุ!! กรุณาทำการเปลี่ยนรหัสผ่านก่อนเข้าระบบ</FONT><% 
				}
			%>
			</B></FONT></td>
		  </tr>
		  <tr><td nowrap colspan="2">&nbsp;</td></tr>  
          <tr>
            <td width="20%" valign="top" >หมายเหตุ :</td> 
            <td width="80%" valign="top" style="color:#0066FF">  ระบบนี้เป็นระบบที่ต้องอาศัย รหัสผู้ใช้ และรหัสผ่านของแต่ละคนในการทำงาน ดังนั้นเพื่อความปลอดภัยของข้อมูล และสิทธิของท่าน กรุณา
              Log Out จากระบบนึ้ทุกครั้งหลังจากเลิกใช้งาน&nbsp;</td> 
          </tr> 
        </table> 

  
   
<br style="font-size:10pt">   
   
  
   
   </TD>    
      </tr>    
     </table>    
      </center>    
 
      
   
          
   
        
   
        <br style="font-size:6pt">   
   
                    
    
   
   

    
      
           
        <table border="0" width="85%" cellspacing="0" cellpadding="0" height="30">   
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">
			
			<INPUT type="image"  border="0" src="images/act_ok.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27">
                  	
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


      <table border="0" width="440" height="10" cellspacing="0" cellpadding="0" class="edge2">
        <tr>
          <td width="100%">&nbsp;</td>
        </tr>
      </table>
      
      
</div>



<br style="font-size:15pt">


<div style="position:relative ; width: 500px ; left:180px ; top:10px">


<TABLE border=0 cellspacing=0 cellpadding=0>
  <tr>
  <td width="100%" class="copyright" align="left">Best viewed with 800x600 screen resolution on an Internet Explorer version 6  <br>
  ติดต่อสอบถามได้ที่ : <a href="mailto:dept_IT@lh.co.th">dept_IT@lh.co.th</a>&nbsp;
  หรือ โทร. 0-2230-8458 (ฝ่าย IT) <br>
  <img src="images/copyright.gif" width="475" height="26"></td>
  </tr>
</TABLE> 


</div>

   </td>
  </tr>
</table>


</BODY>
</HTML>