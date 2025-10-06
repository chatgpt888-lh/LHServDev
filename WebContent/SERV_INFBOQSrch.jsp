<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@page import="serv.common.*" %>
<%@page import="serv.model.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
 
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<jsp:useBean id="beanPage" class="serv.model.PageBean" scope="session"/> 
 

<%	 	//------------- userlogin session ------------//	String userGroup = doString.checkString(user.getUserGroup());	//-------------------------------
	String checkOut = doString.checkString(request.getParameter("checkOut")); 
	String actionMode = doString.checkString(request.getParameter("actionMode"),"search"); 
	String now_page = doString.checkString(request.getParameter("now_page"),"");
	
	String iGroup = doString.checkString(request.getParameter("i_group"),"");    
   	String iType  = doString.checkString(request.getParameter("i_type"),"");    	String typeId = "";
	String n_itmjob = doString.checkString(doString.DisplayThai(request.getParameter("n_itmjob")),"");
	String searchMode = doString.checkString(request.getParameter("searchMode"),"");    
	System.out.println("searchMode="+searchMode);
	String display_type = doString.checkString(request.getParameter("display_type"),""); 
	int display_line =  Integer.parseInt(doString.checkString(request.getParameter("display_line"),"9")); 
	int max_row = Integer.parseInt(doString.checkString(request.getParameter("max_row"),"0"));
	String itmType = "";
	ServInfOpenJobBean openJobBean = null;
	if(request.getSession().getAttribute("listOpenJob")!=null){
		openJobBean = (ServInfOpenJobBean)request.getSession().getAttribute("listOpenJob");
	}
	if (openJobBean != null) {
		itmType = openJobBean.getI_itmtype();
	}
	//--------------------------------
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;	Statement stmt1 = null;
	ResultSet rs = null;	ResultSet rs1 = null;
	SERV_CommonData common = null;
	boolean BOQApprove = false;
	   
	try {
	    doString str = new doString();
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();       		stmt1 = conn.createStatement();
		common = new SERV_CommonData(conn); 
		
%>

<jsp:setProperty name="beanPage" property="displayLine" param="displayLine" value="<%=display_line%>"/>
<jsp:setProperty name="beanPage" property="startRow" param="startRow"/>
<jsp:setProperty name="beanPage" property="endRow" param="endRow"/>
<jsp:setProperty name="beanPage" property="pageLink" param="pageLink"/>
  
<HTML>
<HEAD>
<TITLE>INF BOQ Search</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<!-- add by pradoem 2023.02.15 -->
<script src="jquery3/jquery.min3.6.3.js" ></script>
<script src="jquery3/loadingoverlay.min2.1.7.js"></script>


<script language="javascript">
  function pleaseWaiting(){
   $.LoadingOverlay("show");
	// Hide it after 3 seconds
	setTimeout(function(){
	    $.LoadingOverlay("hide");
	}, 4000);
  }
function initForm(){
	//var searchMode = document.getElementById('searchMode').value;
	//alert(document.forms[0].i_type.value);
	//remark by pradoem 2023.02.15
	//if(document.getElementById('searchMode').value=="like"){
	
	var elementScr = $('#searchMode').val(); //document.getElementById('searchMode');
	//alert(elementScr);
	/*if(typeof elementScr !== null && elementScr !== 'undefined' ) {	   
	}else{	  
	}*/
	
	if(elementScr=='like') {
	
		document.forms[0].search_type[0].checked = true;
		document.forms[0].n_itmjob.disabled = false;
		document.forms[0].n_itmjob.focus();
		
		document.forms[0].i_group.value="";
		document.forms[0].i_type.value="";
		document.forms[0].i_group.disabled = true;
		document.forms[0].i_type.disabled = true;
		
	}else{
		document.forms[0].search_type[1].checked = true;
		document.forms[0].n_itmjob.value = "";
		document.forms[0].n_itmjob.disabled = true;
		document.forms[0].i_group.disabled = false;
		document.forms[0].i_type.disabled = false;
	}
	
	if(document.forms[0].list_type!=null){
		if(document.forms[0].list_type.value=="ListALL"){
			document.forms[0].display_type[1].checked = true;
			document.forms[0].display_line.value = "";
			document.forms[0].display_line.disabled = true;
		}else{
			document.forms[0].display_type[0].checked = true;
			document.forms[0].display_line.disabled = false;
		
		}		
	}
	
	//document.forms[0].n_itmjob.disabled = true;
	//document.forms[0].search_type[1].checked = true;
}

function  checkAll(obj,mainCheck,subCheck) {
     var main = document.forms[0].elements[mainCheck];
     var sub = document.forms[0].elements[subCheck];
     
     if (obj!=null && main!=null && sub!=null) {
     
         var checkObj = document.forms[0].elements["check_"+obj.value];
         if (checkObj!=null && obj.checked) {
            checkObj.value = "checked";
         } else {
            if (checkObj!=null) checkObj.value = "";
         }
     
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

function switchSearch(){
	if(document.forms[0].search_type[0].checked){
		document.forms[0].searchMode.value = "like";
		document.forms[0].n_itmjob.disabled = false;
		document.forms[0].n_itmjob.focus();
		document.forms[0].i_group.value="";
		document.forms[0].i_type.value="";
		document.forms[0].i_group.disabled = true;
		document.forms[0].i_type.disabled = true;
		
	}if(document.forms[0].search_type[1].checked){
		document.forms[0].searchMode.value = "group";
		document.forms[0].n_itmjob.disabled = true;
		document.forms[0].n_itmjob.value = "";
		document.forms[0].i_group.disabled = false;
		document.forms[0].i_type.disabled = false;
	}
}

function switchDisplay_type(){
	
	if(document.forms[0].display_type[0].checked){
		document.forms[0].display_line.disabled = false;
		document.forms[0].display_line.focus();
	}if(document.forms[0].display_type[1].checked){
		document.forms[0].display_line.value = "";
		document.forms[0].display_line.disabled = true;
	}
	
}

function changePage(page) {
    pleaseWaiting();
	document.forms[0].actionMode.value = "actionPage";
	document.forms[0].now_page.value=page;
   	document.forms[0].action="/LHServ/ServBOQSrch";
   	document.forms[0].submit();
}   

function changeGroup() {
    pleaseWaiting();
	document.forms[0].action="SERV_INFBOQSrch.jsp";
	document.forms[0].submit();
} 

function searchByLike(){
	   	
   	if(document.forms[0].search_type[0].checked){
		if(document.forms[0].n_itmjob.value==""){
			alert("กรุณาระบุประเภทการค้นหาที่ด้านหน้า !");
       	 	document.forms[0].n_itmjob.focus();
       	}else if(document.forms[0].display_type[0].checked && document.forms[0].display_line.value==""){
			alert("กรุณาระบุจำนวนรายการต่อหน้า ");
			document.forms[0].display_line.focus();
		}else{
		    pleaseWaiting();
			document.forms[0].actionMode.value = "search";
   			document.forms[0].action="/LHServ/ServBOQSrch";
			document.forms[0].submit();
		}
   	}
}

function searchByGroup(){
	
	if(document.forms[0].search_type[1].checked){
		if(document.forms[0].i_group.value==""){
			alert("กรุณาระบุหมวดการซ่อม !");
			document.forms[0].i_group.focus();
		}
		else if(document.forms[0].i_type.value==""){
			alert("กรุณาระบุประเภทการซ่อม !");
			document.forms[0].i_type.focus();
		}else if(document.forms[0].display_type[0].checked && document.forms[0].display_line.value==""){
			alert("กรุณาระบุจำนวนรายการต่อหน้า ");
			document.forms[0].display_line.focus();
		}else{
		    pleaseWaiting();
			document.forms[0].actionMode.value = "search";
			document.forms[0].action="/LHServ/ServBOQSrch";
			document.forms[0].submit();
		}
	}
}

function addToCart(){
	//alert(document.forms[0].now_page.value);
	var item_checked = "";
	var del_checkbox = document.forms[0].elements['del_checkbox'];
	
	if (del_checkbox!=null) {
		for (var i=0;i<del_checkbox.length;i++) {
			if(del_checkbox[i].checked){
				item_checked+=del_checkbox[i].value+",";		
			}
		}
	}
	
	document.forms[0].item_checked.value = item_checked;
	//alert(document.forms[0].item_checked.value);
	pleaseWaiting();
	document.forms[0].actionMode.value = "addToCart";
	document.forms[0].action="/LHServ/ServBOQSrch";
	document.forms[0].submit();
}

function checkout(){
    pleaseWaiting();
	document.forms[0].checkOut.value = "checkOut";
	document.forms[0].actionMode.value = "addToCart";
	document.forms[0].action="/LHServ/ServBOQSrch";
	document.forms[0].submit();
}

function back(){
	//document.forms[0].action="SERV_InfOpenJob.jsp";
	//document.forms[0].submit();
	pleaseWaiting();
	document.forms[0].actionMode.value = "back";
   	document.forms[0].action="/LHServ/ServBOQSrch";
	document.forms[0].submit();
}

</script>

<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM METHOD="post" ACTION="">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  	<tr>
    	<td width="100%" class="BD" >
      		<table border="0" width="100%" cellspacing="0" cellpadding="0">
       	 		<tr>
          			<td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;BOQ Search</td>
          			<td width="50%" align="right">
						<span style="position: absolute; left: 72%; top: 0">
						<a href="SERV_INFBOQCode01.html">
						<img border="0" src="images/icon_appr24hrs.gif" width="185" height="75">
						</a>
						</span>
          			</td>
        		</tr>
      		</table>
			<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              	<tr>
                	<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                	<td class="item_tab2" width="160">เลือกวิธีการค้นหา</td>
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
    							<td height="22" width="100%" class="dotline01 ; item">
      								<input type="radio"   value="detail" name="search_type" onclick="switchSearch();">
      								<input type="text" name="n_itmjob" class="box" style="width:490px" value="<%=n_itmjob%>">&nbsp;&nbsp; *ใส่รายการซ่อมที่ต้องการค้นหา&nbsp;&nbsp;&nbsp;&nbsp;
      								<a href="javascript:searchByLike();"><img border="0" src="images/i_search.gif" width="20" height="20"> </a> 
      							</td>
  							</tr>
    							<td height="22" width="100%" class="dotline01">    								<input type="radio" value="list" name="search_type" onclick="switchSearch();">
									<select name='i_group' class='box' style='width:250px' onchange="changeGroup();">									<option value=''>------ กรุณาเลือก ------</option>									<%	String selected = "";	String restrict = "";	if (userGroup.equals("H")) {		restrict = " and a.i_group in ('10','11')";	}		rs = stmt.executeQuery("select distinct a.i_group, a.n_itmjob from lan:serv_infboq a, lan:serv_infboq b where a.i_type = '00' and a.i_seq = '0000' "+restrict+" and a.i_group = b.i_group and b.i_itmtype = '"+itmType+"' order by a.i_group");	if (rs != null) {		while (rs.next() == true) {			typeId = doString.checkString(rs.getString("I_GROUP"));			selected = "";			if (typeId.equals(iGroup)) {				selected = "selected";			}%>							<option value='<%=typeId%>' <%=selected%>><%=typeId%> - <%=doString.DisplayThai(rs.getString("N_ITMJOB"))%></option><%										}		rs.close();		rs=null;	}	%>									</select>									<select name='i_type'  size='1' class='box' style='width:200px'>									<option value=''>------ กรุณาเลือก ------</option>									<option value='ALL' <%if (iType.equals("ALL")) { out.print("selected"); }%>>ทุกประเภท</option><%	selected = "";	rs = stmt.executeQuery("SELECT i_type, n_itmjob FROM lan:serv_infboq WHERE i_group = '"+iGroup+"' AND i_type != '00' AND i_seq = '0000' ORDER BY i_type");	if (rs != null) {		while (rs.next() == true) {			typeId = doString.checkString(rs.getString("I_TYPE"));			selected = "";			if (typeId.equals(iType)) {				selected = "selected";			}			rs1 = stmt1.executeQuery("SELECT i_itmjob, n_itmjob FROM lan:serv_infboq WHERE i_group = '"+iGroup+"' AND i_type = '"+typeId+"' AND i_itmtype = '"+itmType+"' AND (f_cancel = 'N' OR f_cancel IS NULL)");			if (rs1 != null) {				if (rs1.next() == true) {%>									<option value='<%=typeId%>' <%=selected%>><%=doString.DisplayThai(rs.getString("N_ITMJOB"))%></option><%												}				rs1.close();				rs1=null;			}		}		rs.close();		rs=null;	}	%>									
									</select>&nbsp;&nbsp; 
									<a href="javascript:searchByGroup();"><img border="0" src="images/i_search.gif" width="20" height="20"> </a> 
								</td>
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
	<table border="0" width="100%" cellspacing="0" cellpadding="0">
		<tr>
			<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
         	<td class="item_tab2" width="160">รายการซ่อม</td>
           	<td class="item_tab3"></td>
           	<td>&nbsp;<input type="radio" value="ListByPage" checked name="display_type" onclick="switchDisplay_type();">แสดงจำนวนรายการต่อหน้า&nbsp;
            	<input type="text" name="display_line" class="boxC" style="width:50px" value="<%=display_line%>">&nbsp; รายการ&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              	<input type="radio" value="ListALL" name="display_type" onclick="switchDisplay_type();">แสดงรายการทั้งหมด&nbsp;&nbsp;&nbsp;&nbsp;
				<a href="javascript:searchByGroup();"><img border="0" src="images/bu_R.gif" align="absmiddle" style="cursor:hand" width="16" height="16"></a>
			</td>
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
          			<td width="4%" class="col_name"><input type="checkbox" name="main_check" onclick="checkAll(this,'main_check','del_checkbox');"></td>
          			<td width="25%" class="col_name">หมวด</td>
          			<td width="25%" class="col_name">ตำแหน่ง/ที่ตั้ง</td>
          			<td width="46%" class="col_name">รายการซ่อม</td>
        		</tr>
        	
        	<!---------------------- Data List ---------------->	
        	<%
        	String cartItem = "";
        	if(request.getSession().getAttribute("listJobItem")!=null){
        		ListServInfBoqBean bean = (ListServInfBoqBean)request.getSession().getAttribute("listJobItem");
        		ArrayList listBean = (ArrayList)bean.getListBean();
        	%>
        	<%//<jsp:setProperty name="beanPage" property="maxRow" param="maxRow" value="<%=listBean.size()%>     
        	   <input type="hidden" name="max_row" value="<%=bean.getMax_row()%>"/>	
        	   <input type="hidden" name="list_type" value="<%=bean.getDisplay_type()%>" />
        	<%
        		String[] checkItem = (String[])request.getSession().getAttribute("addToCart");
        		
        		for(int i=0; i<listBean.size(); i++){
        			ServInfBoqBean boqBean = (ServInfBoqBean)listBean.get(i);
        			String checked = "";
        	%>
				<tr height="25px">
					
					<td width="4%" align="center" class="dotline">
					<%
					if(checkItem!=null){
						for(int j=0;j<checkItem.length; j++){
							if(doString.checkString(doString.DisplayThai(checkItem[j])).equalsIgnoreCase(doString.checkString(doString.DisplayThai(boqBean.getI_itmjob())))){
								cartItem += checkItem[j]+",";
								checked="checked=checked";
								break;
							}
							
							//out.println(checkItem[j]+",");								
						}
					}
					%>
						<input type="checkbox" name="del_checkbox" <%=checked%> <%=doString.checkString(boqBean.getCheckbox()) %> value="<%=doString.checkString(boqBean.getI_itmjob())%>" onclick="checkAll(this,'main_check','del_checkbox');">
						<%//out.print(doString.checkString(boqBean.getI_itmjob()));%>
					</td>
					<td width="25%" class="dotline ; item"><%=doString.checkString(doString.DisplayThai(boqBean.getI_group()))%></td>
                  	<td width="25%" class="dotline ; item"><%=doString.checkString(doString.DisplayThai(boqBean.getI_type()))%></td>
					<td width="46%" class="dotline ; item"><%=doString.checkString(doString.DisplayThai(boqBean.getN_itmjob()))%></td>
				</tr>
			<%
				}
			}else{
			%>
				<tr height="25px">
        			<td width="100%" align="center" colspan="4">
        				ไม่พบข้อมูล !!
        			</td>
				</tr>
			<%}%>
			
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
	<br style="font-size:3pt">
   	<table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr class="gray">
           <td width="100%" align="right"><jsp:getProperty name="beanPage" property="pageLink"/></td>
        </tr>
   	</table>
	<br style="font-size:10pt">
	<table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
		<tr>
			<td class="act_tab1"></td>
	        <td width="150" class="act_tab2">
		        <a href="javascript:addToCart();"><img border="0" src="images/act_add2cart.gif" onmouseout=nereidFade(this,70,50,5) onmouseover=nereidFade(this,100,50,5)
				style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp;
		       	<a href="javascript:checkout();"><img border="0" src="images/act_checkout.gif" onmouseout=nereidFade(this,70,50,5) onmouseover=nereidFade(this,100,50,5)
		        style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
	        </td>
	        <td class="act_tab3"></td>
	        <td class="act_tab4">
	        	<a href="javascript:history.back();"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp; 
	           	<a href="SERV_Index.jsp" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
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
<input type="hidden" id="checkOut" name="checkOut" value="<%=checkOut%>"/>
<input type="hidden" id="searchMode" name="searchMode" value="<%=searchMode%>"/>
<input type="hidden" id="actionMode" name="actionMode" value="<%=actionMode%>"/>

<input type="hidden" id="now_page" name="now_page" value="<%=now_page%>"/>
<input type="hidden" id="item_checked" name="item_checked" value="<%=cartItem %>"/>
</FORM>
</BODY>
</HTML>
<%		//session.setAttribute("beanPage", beanPage);   
		common = null;
		stmt.close();		stmt1.close();
		conn.close();
		stmt = null;		stmt1 = null;
		conn = null;
	} catch (Exception e) {
		System.out.println("ERROR SERV_INFBOQSrch.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		try {
			if (rs != null) rs.close();
			if (stmt != null) stmt.close();			if (stmt1 != null) stmt1.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>
<script type="text/javascript">
initForm();
</script>
