<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.Constants" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %> 
<%@ include file="function.jsp" %>
<%
  List  listObj = (ArrayList)request.getAttribute("resultObj"); //resultObj
%>
<HTML>
<HEAD>
<TITLE>ข้อมูลพื้นฐาน : กำหนดโครงการที่รับผิดชอบ Zero Defect</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<base target="_self">
<script type="text/javascript">
function onSubmit(usrId,pfix,fName,lName){
	 var qureyString = "&userId="+usrId+"&prefix="+pfix+"&fname="+fName+"&lname="+lName;
	 document.forms[0].action="<%=request.getContextPath()%>/SERV_ZeroDefectMasterServlet?cmd=list"+qureyString;
	 document.forms[0].submit();
}
</script>
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM method="post" action="" name="frm1">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">
          &nbsp;ข้อมูลพื้นฐาน : กำหนดโครงการที่รับผิดชอบ Zero Defect</td>
        </tr>
      </table>
	<br style="font-size:10pt">             
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">รายการ Zero Staff</td>
                <td class="item_tab3"></td>
                <td>&nbsp;</td>                
              </tr>
            </table>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
    <td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL">
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td class="col_name" width="10%">No.</td>
          <td class="col_name" width="10%">รหัสพนักงาน</td>
          <td class="col_name" width="80%">ชื่อพนักงาน</td>
        </tr>
        <%
        if(listObj!=null && listObj.size()>0){
        	List  strList = new ArrayList();
        	Iterator it = listObj.iterator(); 
        	int i = 1;     	
        	 while(it.hasNext()){
        	   strList = (ArrayList)it.next();
	        	%>
	        	<tr>
			    <td align="center" class="dotline" width="10%">&nbsp;<%=i++%></td>
			    <td align="center" class="dotline" width="10%">&nbsp;&nbsp;&nbsp;
			    <a href="javascript:onSubmit('<%=strList.get(4)%>','<%=doString.DisplayThai(strList.get(1).toString())%>','<%=doString.DisplayThai(strList.get(2).toString())%>','<%=doString.DisplayThai(strList.get(3).toString())%>');">
			    <%=strList.get(0)%></a>
			    </td>
			    <td align="left" class="dotline" width="80%">&nbsp;&nbsp;&nbsp;<%=doString.DisplayThai(strList.get(1).toString())%>&nbsp;
			     <%=doString.DisplayThai(strList.get(2).toString())%>&nbsp;&nbsp;&nbsp;<%=doString.DisplayThai(strList.get(3).toString())%></td>
			    </tr>		
	        	<%
        	}
        }else{
        	%>
	         <tr>
	          <td align="center" class="dotline" width="10%">&nbsp;</td>
	          <td align="center" class="dotline" width="10%">ไม่พบรายการ</td>
	          <td align="center" class="dotline" width="80%">&nbsp;</td>
	         </tr>		
        	<%
        }
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
            <td width="75" class="act_tab2">
            </td>                                     	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:history.back();" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
  <br>ติชมแสดงความคิดเห็น: <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th
  </a> &nbsp; หรือ Computer Department&nbsp; โทร  0-2230-8490-98, 0-2230-8451-3  
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE> 
</FORM>
</BODY>
</HTML>


