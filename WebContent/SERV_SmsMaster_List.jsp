<%@page language="java" contentType="text/html; charset=TIS-620"
	pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="java.util.Date" %>
<%@page import="java.text.*" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="serv.common.*" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%-- 
/**********************************************/
 * create by : pradoem wonkraso
 * date time: 2014.08.02
 * Last modify :
 * version :1.0
 * project Name : Master Data SMS send
 * description : this is page for display && Master SMS List
***************************************************/
--%>
<%
//*****************************************
//*****************************************
	ArrayList projectDDL = (ArrayList)session.getAttribute("SS_PROJECT_DDL");
	ArrayList resultList = (ArrayList)request.getAttribute("arrResult");
	String projectSel	 = request.getAttribute("projectSel")==null?"": request.getAttribute("projectSel").toString();//LH:075
 %>
<HTML>
<HEAD>
<TITLE>ข้อมูลพื้นฐาน-รายการเบอร์ติดต่อแยกตามโครการ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<style type="text/css">
 .box2 {  font-family: Tohama,Arial,sans-serif; font-size:10.1pt; font-weight:normal;
		padding-top: 1px; padding-right: 1px; padding-bottom: 1px; padding-left: 1px; 
	 	color:#165396; background-color: white; border: 1px #BEDCFF solid ; 
}
td.dotlineWhite{
	 color: rgb(255,255,255) ;	
	 border-bottom:1px dotted rgb(220,220,220)	;
	 border-right:1px solid rgb(135,185,247) ; 
	 padding:3px ; mso-number-format:"\@";  }
</style>
<script language="javascript" src="script_fx.js"></script>
<script type="text/javascript" src="eserv_paging.js"></script>
<script>
function initForm(){
      var e = document.getElementById('page');
      //e.style.display == 'block'
      e.style.visibility = 'hidden';
 }
function doSearch(){
    document.forms[0].action="<%=request.getContextPath()%>/SERV_SmsMasterServlet?cmd=search";
    document.forms[0].submit();
}

function doFormLoadData(comId,projId){
    document.forms[0].companyId.value=comId; //LH:075
    document.forms[0].projectId.value=projId; //075
    document.forms[0].action="<%=request.getContextPath()%>/SERV_SmsMasterServlet?cmd=load";
    document.forms[0].submit();
}


function doAdd(){
	document.forms[0].action="<%=request.getContextPath()%>/SERV_SmsMaster_Form.jsp";
	document.forms[0].submit();
}

function doDelete(comId,projectId) {
     var temp = comId+"-"+projectId;
	 if(confirm("คุณต้องการลบข้อมูลรหัสโครงการ '"+temp+"' ใช่หรือไม่?")==true){
	     document.forms[0].companyId.value=comId; //LH
         document.forms[0].projectId.value=projectId; //075
		 //validate from client side
		 document.forms[0].action="<%=request.getContextPath()%>/SERV_SmsMasterServlet?cmd=delete";
		 document.forms[0].submit();
	}
}

</script>
<style type="text/css">    
            .pg-normal {
                font-size:14px;
                color: #20a6f4;
                font-weight: normal;
                text-decoration: none;    
                cursor: pointer;    
            }
            .pg-selected {
               font-size:1.875em;
                color: #fe8002;
                font-weight: bold;        
                text-decoration: underline;
                cursor: pointer;
            }
            
 </style>
 <style type="text/css">
	A:link {text-decoration: none}
	A:visited {text-decoration: none}
	A:active {text-decoration: none}
	A:hover {text-decoration: underline; color: red;}
</style>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="initForm()">
<form action="" name="frm" method="POST">
<input type="hidden" name="companyId" value="">
<input type="hidden" name="projectId" value="">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">
          &nbsp;ข้อมูลพื้นฐาน-รายการเบอร์ติดต่อแยกตามโครการ</td>
        </tr>
      </table>
<br style="font-size:10pt">              
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">Form Search : โครงการ</td>
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
    <td class="item ; dotline01" height="22" width="12%">โครงการ :</td>
    <td height="22" width="88%" class="dotline01">
	<select name="projectDDL" class="box2" style='width:280' size='1' > 
			<option value="">------ กรุณาเลือกโครงการ ------</option>
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
							if (strValue.equals(projectSel)){
								select="selected"; 
							}else{ 
								select=""; 
							} %>
								<option value="<%=strValue%>"  <%=select %>><%=arrList.get(0)%> - <%=doString.checkString(doString.DisplayThai(arrList.get(1).toString())) %></option>
							<%}
					} %>	 
   				</select> 	
   				&nbsp;&nbsp;<a href="javascript:doSearch();"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a>
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

<br style="font-size:5pt">
<p align="left">
<a href="javascript:doAdd();"><img border="0" src="images/act_add.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
  </p>       	
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
      <table id="results" border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td class="col_name" width="5%">NO.</td>
          <td class="col_name" width="10%">รหัสบริษัท</td>
          <td class="col_name" width="20%">ชื่อโครงการ</td>
          <td class="col_name" width="15%">เบอร์ติดต่อ(SMS e-Service)</td>
          <td class="col_name" width="15%">Fax</td>
          <td class="col_name" width="20%">ชื่อเจ้าหน้าที่ผู้รับผิดชอบ</td>
          <td class="col_name" width="15%">Delete</td>
        </tr>
 <%
         int c = 0;
 		if(resultList!=null && resultList.size()>0){
 			ArrayList strArr = null;
 			Iterator it = resultList.iterator(); 			

 			String tagColor = "";
			while(it.hasNext()){
			    c++;		
				strArr =(ArrayList)it.next();	
				tagColor="#ffffff";
				if((c%2)==0){
					tagColor="#f0f0f0";
				}	 
 %>
	        <tr bgcolor="<%=tagColor %>">
	        <td align="center" class="dotline" ><%=c%></td>
	        <td  align="center" class="dotline ; item"><a href="javascript:doFormLoadData('<%=strArr.get(0).toString() %>','<%=strArr.get(1).toString()%>');"><%=strArr.get(0).toString() %>-<%=strArr.get(1).toString() %></a></td>
	        <td class="dotline" align="left" >&nbsp;<%=doString.DisplayThai(strArr.get(5).toString()) %></td>
	        <td class="dotline" align="left" >&nbsp;<%=doString.DisplayThai(strArr.get(2).toString()) %></td>
	        <td class="dotline" align="left" >&nbsp;<%=doString.DisplayThai(strArr.get(3).toString()) %></td>
	        <td class="dotline" >&nbsp;<%=doString.DisplayThai(strArr.get(4).toString()) %></td>
			<td  class="dotline" align="center"><a href="javascript:doDelete('<%=strArr.get(0).toString() %>','<%=strArr.get(1).toString()%>');"><img src="images/bu_del.gif" width="30" height="12" border="0"                                  
	    			    onmouseout=nereidFade(this,70,50,5)    
	                  	onmouseover=nereidFade(this,100,50,5)     
	                  	style="FILTER: alpha(opacity=70)" width="70" height="27" alt="Delete"></a></td>
	        </tr>  
 			<%
 			}
 	}else{
  %>       
        <tr>
		   <td  class="dotline" colspan="7" class="side01" >&nbsp;</td>
        </tr>
       <tr>
		   <td  class="dotline" colspan="7" align="center" class="side01" >&nbsp;ไม่มีข้อมูล</td>
        </tr>
        <tr>
		   <td  class="dotline" colspan="7" class="side01" >&nbsp;</td>
        </tr>
        <%}
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
<% if(c>0){ %>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr  valign="MIDDLE">
    <td align="right" nowrap="nowrap" width="50%">
    <div id="pageNavPosition"></div>
    </td>
   <td valign="middle" align="left" nowrap="nowrap" width="50%" class="pg-normal" >
   &nbsp;&nbsp;<A href="#" onclick="toggle_visibility('page');">|ALL|</A>&nbsp;&nbsp;<div id="page"></div>
    </td>
  </tr>
</table>
<%} %>
<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">
            <%-- <a href="javascript:doDelete();"><img border="0" src="images/act_delete.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
            --%>
           </td>      	
            <td class="act_tab3"></td>   
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
  <br>ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;
  หรือ โทร. 0-2230-8279 (คุณประพัฒน์
  ฝ่ายบริการ)&nbsp; 0-2230-8491-5 (ฝ่าย IT)  
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE> 

</form>
<script type="text/javascript">	
    function toggle_visibility(id) {
      var intX = 0;
      var e = document.getElementById(id);
      if(e.style.visibility == 'hidden'){
         e.style.visibility = 'visible';
         intX = 1;
      }else{
         e.style.visibility = 'hidden';
      }      
      if(intX==1){
         allList();
      }else{
        pageList();
      }
    }

 	function allList(){
 		 totalRec  = "<%=c%>";
 		  var pager = new Pager('results', totalRec); 
	      pager.init(); 
	      pager.showPageNav('pager', 'pageNavPosition'); 
	      pager.showPage(1);
    }
    
    function pageList(){
 		  var pager = new Pager('results', 25); 
	      pager.init(); 
	      pager.showPageNav('pager', 'pageNavPosition'); 
	      pager.showPage(1);
    }
</script>
 <script type="text/javascript"><!--
        var pager = new Pager('results', 25); 
        pager.init(); 
        pager.showPageNav('pager', 'pageNavPosition'); 
        pager.showPage(1);
    //--></script>
</BODY>
</HTML>
