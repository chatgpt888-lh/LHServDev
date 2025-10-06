<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.Constants"%>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%-- 
/**********************************************/
 * create by : pradoem wonkraso
 * date time: 2014.09.03
 * Last modify :
 * version :1.0
 * project Name : Master Data SMS send
 * description : this is page for display && Master SMS List
***************************************************/
--%>
<%
//*****************************************
ArrayList projectDDL = (ArrayList)session.getAttribute("SS_PROJECT_DDL");
//ArrayList resultList = (ArrayList)request.getAttribute("arrResult");
String projectSel	= request.getAttribute("projectSel")==null?"": request.getAttribute("projectSel").toString();//LH:075
String mobileTxt	= request.getAttribute("mobileTxt")==null?"": request.getAttribute("mobileTxt").toString();//
String faxTxt	= request.getAttribute("faxTxt")==null?"": request.getAttribute("faxTxt").toString();//
String serviceName	= request.getAttribute("serviceName")==null?"": request.getAttribute("serviceName").toString();//

%>
<HTML>
<HEAD>
<TITLE>ข้อมูลพื้นฐาน-แก้ไขรายการเบอร์ติดต่อแยกตามโครการ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">
<!--
function doSubmit() {
   if (document.forms[0].projectDDL.value=="") {
      alert("ระบบมีข้อผิดผลาดเนื่องจากรหัสโครงการเป็นค่าว่าง !!");
      return ;
   }else if (!document.forms[0].mobileTxt.value=="") {
   	   var firstdigit = document.forms[0].mobileTxt.value.substr(0,2);
   	   if(document.forms[0].mobileTxt.value.length<10){
   	       alert("กรุณาตรวจสอบเบอร์โทรติดต่อด้วย.");
		   document.forms[0].mobileTxt.focus();
		   document.forms[0].mobileTxt.select();
		   return;
   	   }else if(firstdigit=='02'||firstdigit=='11'||firstdigit=='22'||firstdigit=='33'||firstdigit=='44'
   	   ||firstdigit=='55'||firstdigit=='66'||firstdigit=='77'||firstdigit=='88'||firstdigit=='99'){
   	       alert("กรุณาตรวจสอบเบอร์โทรติดต่อด้วย(Ex.084101xxxx).");
		   document.forms[0].mobileTxt.focus();
		   document.forms[0].mobileTxt.select();
		   return;
   	   }else if(ValidateNubmeric(document.forms[0].mobileTxt.value)==false) {
			alert("กรุณาตรวจสอบเบอร์โทรติดต่อด้วย(ตัวเลขเท่านั้น).");
			document.forms[0].mobileTxt.focus();
			document.forms[0].mobileTxt.select();
			return;
		}else{
		    document.forms[0].action="<%=request.getContextPath()%>/SERV_SmsMasterServlet?cmd=update";
       		document.forms[0].submit();
       		//alert("Submit");
		}
   }else{
       document.forms[0].action="<%=request.getContextPath()%>/SERV_SmsMasterServlet?cmd=update";
       document.forms[0].submit();
       //alert("Submit");
   }
}
    //Function intput mumberic only
	function NumbericOnlyE(e){
	  //alert(String.fromCharCode(e.keyCode));
	  key = e.keyCode;
	  e.returnValue = false;
	  //64=@,65=A
	  //if((key > 63 && key < 91)   || key == 32 || key == 46){	//BIG English
	  //e.returnValue = true;
	  //}else if((key > 96 && key < 123)  || key == 32 || key == 46 ){//smal English
	  // e.returnValue = true;
	  //}else 
	  if( key > 47 && key < 58 ){//mumberic
	    e.returnValue = true;
	  }
	}

function ValidateNubmeric(inText) {
	var inTextCharacterCount = inText;
	var strValidChars = "1234567890";
	var strChar;
	var FilteredChars = "";
	for (i = 0; i < inTextCharacterCount.length; i++) {
	       strChar = inTextCharacterCount.charAt(i);
	       //if (strValidChars.indexOf(strChar) != -1) {//Equals have plus+1
	       if (strValidChars.indexOf(strChar)== -1) {
	           //FilteredChars = FilteredChars + strChar;
	       	   return false;
	       	   break;
	       }
	} //obj.value = FilteredChars;
	return true;
}	
	
function doResetForm(){
	document.forms[0].reset(); 
}
-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM method="POST" action="">
<input type="hidden" name="projectDDL" value="<%=projectSel%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
   
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;ข้อมูลพื้นฐาน-แก้ไข</td>
        </tr>
      </table>

<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">แก้ไขรายการเบอร์ติดต่อแยกตามโครการ</td>
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
    <td class="item ; dotline01" height="22" width="18%">โครงการ :</td>
    <td height="22" width="82%" class="dotline01">
    <select name="projectDDL" class="box2" style='width:280' size='1' disabled="disabled"> 
			<option value="">------ กรุณาเลือกโครงการ ------</option>
   			<%List  arrList = null;
					if(projectDDL!=null && projectDDL.size()>0){
					    Iterator it = projectDDL.iterator();
						String select = "";
						String strValue = "";
						while(it.hasNext()){
						    select = "";
							strValue = ""; 									
						    arrList =(ArrayList)it.next();										
							strValue = doString.checkString(arrList.get(0).toString());
							if (strValue.equals(projectSel)){
								select="selected"; 
							}else{ 
								select=""; 
							} %>
								<option value="<%=strValue%>"  <%=select %>><%=arrList.get(0)%> - <%=doString.checkString(doString.DisplayThai(arrList.get(1).toString())) %></option>
						<%}
					} %>	 
   		</select> 	
    </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="18%">เบอร์ติดต่อ(SMS e-Service) :</td>
    <td height="22" width="82%" class="dotline01"><input type="text" name="mobileTxt" class="box" style="width:280px" value="<%=doString.DisplayThai(mobileTxt) %>" 
     maxlength="10" onkeypress="NumbericOnlyE(event);" ></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="18%">Fax :</td>
    <td height="22" width="82%" class="dotline01"><input type="text" name="faxTxt" class="box" style="width:280px" value="<%=doString.DisplayThai(faxTxt) %>" ></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="18%">ชื่อเจ้าหน้าที่ผู้รับผิดชอบ :</td>
    <td height="22" width="82%" class="dotline01"><input type="text" name="serviceName" class="box" style="width:300px" value="<%=doString.DisplayThai(serviceName)%>"></td>
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
            <td width="200" class="act_tab2">
            <a href="javascript:doSubmit();"><img border="0" src="images/act_submit.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
                  	&nbsp;
                  	 <a href="javascript:doResetForm();"><img border="0" src="images/act_reset.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
            </td>   
            <td  class="act_tab3"> </td>   
            <td class="act_tab4"><a href="javascript:history.back()" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>  
        </table>  

          </td>
        </tr>
      </table>
<br style="font-size:30pt">

<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
  <tr><td width="100%" class="copyright" align="center">
  Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5  
  <br>ติชมแสดงความคิดเห็น : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a> &nbsp;หรือ Computer Department&nbsp; โทร
  0-2230-8490-98, 0-2230-8451-3  
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE> 

</FORM>	
</BODY>

</HTML>
