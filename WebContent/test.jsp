<%@page language="java" contentType="text/html; charset=TIS-620" 
  pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%
    List  listObj = (ArrayList)request.getAttribute("listObj"); //resultObj
    List  projectDDL =(ArrayList)request.getAttribute("projDDL"); //projDDL
	String userId = request.getAttribute("userId")==null?"":request.getAttribute("userId").toString();
	String prefix = request.getAttribute("prefix")==null?"":request.getAttribute("prefix").toString();
	String fname = request.getAttribute("fname")==null?"":request.getAttribute("fname").toString();
	String lname = request.getAttribute("lname")==null?"":request.getAttribute("lname").toString();
	String sel_project = "";
	
 %>
<HTML>
<HEAD>
<TITLE>Zero Defect</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">

function  checkAll(obj,mainCheck,subCheck) {
     var main = document.forms[0].elements[mainCheck];
     var sub = document.forms[0].elements[subCheck];  
     if (obj!=null && main!=null && sub!=null) {
         if (obj.name==mainCheck) {
		    if (sub.length!=null) {
				for (var i=0;i<sub.length;i++) {
					  sub[i].checked = obj.checked;
				}
			} else {
			   sub.checked = obj.checked;
			}
         } else {
		    if (sub.length!=null) {
			    var flag = true;
				for (var i=0;i<sub.length;i++) {
					  flag = sub[i].checked;
					  if (!flag) break;
				}
				main.checked = flag;
			} else {
			   main.checked = obj.checked;
			} // end if check sub
         } // end if check mainCheck
     } // end if check null
}



</script>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM method="POST" action="" name="form">
<input type="hidden" name="userId" value="<%=userId%>">
<input type="hidden" name="prefix" value="<%=doString.DisplayThai(prefix)%>">
<input type="hidden" name="fname" value="<%=doString.DisplayThai(fname)%>">
<input type="hidden" name="lname" value="<%=doString.DisplayThai(lname)%>">
<input type="hidden" name="mode" value="">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">
          &nbsp;ทดสอบ ทดสอบอีกครั้ง Zero Defect </td>
        </tr>
      </table>
	<br style="font-size:10pt">       
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250"></td>
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
    <td class="item ; dotline01" height="22" width="12%">???????? :</td>
    <td height="22" width="30%" class="dotline01">&nbsp;<%=doString.DisplayThai(prefix)%>&nbsp;<%=doString.DisplayThai(fname)%>&nbsp;&nbsp;<%=doString.DisplayThai(lname)%></td>
    <td height="22" width="12%" class="item ; dotline01">?????????:
    </td>
     <td height="22" width="46%" class="dotline01">
  <select name="projectDDL" class="box7" style='width:200' size='1' > 
			<option value="">------ ????????????? ------</option>
   				<%
					List  arrList = null;
					if(projectDDL!=null && projectDDL.size()>0){
							Iterator it = projectDDL.iterator();
							String select = "";
						     String strValue = "";
							while(it.hasNext()){
						     select = "";
							 strValue = ""; 									
							 arrList =(ArrayList)it.next();										
							 strValue = doString.checkString(arrList.get(0).toString());
							if (strValue.equals(sel_project)){
								select="selected";   
							}else{ 
								select=""; 
							} %>
								<option value="<%=strValue%>"  <%=select %>><%=arrList.get(0)%> - <%=doString.checkString(doString.DisplayThai(arrList.get(1).toString())) %></option>
							<%}
					} %>	 
   				</select> 
     &nbsp;&nbsp;&nbsp;&nbsp;
     <img border="0" src="images/bu_add.gif" align="absmiddle" width="35" height="15" style='cursor:hand' onclick="doAdd('add');">
    </td>
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

<br style="font-size:2pt">  

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
          <td class="col_name" width="10%"><input type="checkbox" name="main_check" onclick="checkAll(this,'main_check','chkDel');"></td>
          <td class="col_name" width="10%">No.</td>
          <td class="col_name" width="90%">?????</td>
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
		          <td align="center" class="dotline" width="10%"><input type="checkbox" name="chkDel" value="<%=userId%>:<%=strList.get(1)%>:<%=strList.get(2)%>" onclick="checkAll(this,'main_check','chkDel');"></td>
		          <td align="center" class="dotline" width="10%"><%=i++%></td>
		          <td class="dotline" width="80%"><%=strList.get(1)%>-<%=strList.get(2)%> - <%=doString.DisplayThai(strList.get(3).toString())%></td>
		        </tr>
        <%     }
           }else{
         %>
	        <tr>
	          <td   colspan="3" align="center" class="dotline" >&nbsp;</td>
	        </tr>
	        <tr>
	          <td   colspan="3" align="center" class="dotline" >&nbsp;----??????????----</td>
	        </tr>
	         <tr>
	          <td   colspan="3" align="center" class="dotline" >&nbsp;</td>
	        </tr>

       <%} %>
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
            <a href="#" onclick="deleteData();"><img border="0" src="images/act_delete.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
            </td>             	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_PStaff01.jsp" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>  
        </table>  
          </td>
        </tr>
      </table>				
<br style="font-size:30pt">

<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
  <tr><td width="100%" class="copyright" align="center">
  Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 ??? 5.5  
  <br> : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;
  ???? ??. 0-2230-8279 (????????
  ????????)&nbsp; 0-2230-8491-5 (???? IT)  
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE> 
</FORM>
</BODY>
</HTML>




