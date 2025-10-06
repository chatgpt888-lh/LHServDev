<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%!
 private String getNProject(Statement stmt , String i_company , String i_project) throws SQLException{
 	String n_project = "";
 	ResultSet rs = stmt.executeQuery("select n_project from lan:acxprojt where i_company = '"+i_company+"' and i_project = '"+i_project+"' ");
 	if(rs.next()){
 		n_project = doString.checkString(rs.getString("n_project"),"");
 	}
 	rs.close();
 	return n_project;
 }
 private String getNVendor(Statement stmt , String ven_no) throws SQLException{
 	String ven_name = "";
 	ResultSet rs = stmt.executeQuery("select ven_name from lan:vendor where ven_no = '"+ven_no+"' ");
 	if(rs.next()){
 		ven_name = doString.checkString(rs.getString("ven_name"),"");
 	}
 	rs.close();
 	return ven_name;
 }
 private String thaiToDB(String thDate){
 	return (Integer.parseInt(thDate.substring(6,10))-543)+"-"+thDate.substring(3,5)+"-"+thDate.substring(0,2);
 }
 %>
<%
Calendar right = Calendar.getInstance();
int dd = right.get(Calendar.DATE);
int mm = right.get(Calendar.MONTH)+1;
int yy = right.get(Calendar.YEAR);
if(yy < 2400){
	yy += 543;
}
Connection conn= null;
Statement stmt= null;
Statement stmt1= null;
ResultSet rs=null;
StringBuffer sql = new StringBuffer("");

String project = "";
String i_company = "";
String i_project = "";
String n_project = "";
String i_itmno = "";
String d_keyin_beg = "";
String d_keyin_end = "";

String search = "";
String n_vendor_disp = "";
String selected = "selected";
String sort_col = "";

StringBuffer row_project = new StringBuffer();
StringBuffer row_vendor = new StringBuffer();
String old_project = "";
int row_count = 0;
int project_total = 0;
try{
	if(ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	stmt1 = conn.createStatement();
	
	project  = doString.checkString(request.getParameter("project"),"ALL");
	if(!"".equals(project) && !"ALL".equals(project)){
		i_company = project.substring(0,2);
		i_project = project.substring(2,5);
	}
	i_itmno = doString.checkString(request.getParameter("i_itmno"),"01");	
	search = doString.checkString(request.getParameter("search"),"Y");
	n_vendor_disp = doString.checkString(request.getParameter("n_vendor_disp"),"N");
	
	//fix date begin
	d_keyin_beg = doString.checkString(request.getParameter("d_keyin_beg"),"01/10/2556");
	d_keyin_end = doString.checkString(request.getParameter("d_keyin_end"),(dd<10?"0"+dd:""+dd)+"/"+(mm<10?"0"+mm:""+mm)+"/"+yy);
	
	sort_col = doString.checkString(request.getParameter("sort_col"),"default");
%>
<HTML>
<HEAD>
<TITLE>งานซ่อม</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--
function initPage(){
	var form = document.frmSERV;
	form.i_itmno.options[1].selected = true;
}
function go(){
	var form = document.frmSERV;
	if(form.project.value == ''){
		alert('กรุณาเลือกโครงการ');
		return;
	}
	if(form.d_keyin_beg.value == ''){
		alert('กรุณาระบุช่วงวันที่');
		return;
	}
	if(form.d_keyin_end.value == ''){
		alert('กรุณาระบุช่วงวันที่');
		return;
	}
	form.search.value='Y'
	form.action = '/LHServ/SERV_VendorFollow.jsp';
	form.submit();
}
function sortBy(theCol){
	var form = document.frmSERV;
	form.sort_col.value = theCol;
	go();
}	
function go2Details(theVendor,theCompany,theProject){
	var form = document.frmSERV;
	form.i_vendor.value = theVendor;
	form.i_company.value = theCompany;
	form.i_project.value = theProject;
	form.action = '/LHServ/SERV_VendorFollowDetails.jsp';
	form.submit();
}
//-->
</script>


<base target="_self">


</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="initPage()">

<FORM method="POST" name="frmSERV" action="/LHServ/SERV_VendorFollow.jsp">
<input type="hidden" name="search" value="" />
<input type="hidden" name="sort_col" value="" />
<input type="hidden" name="i_vendor" value="" />
<input type="hidden" name="i_company" value="" />
<input type="hidden" name="i_project" value="" />
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center" class="BD">
    

      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ยินดีต้อนรับสู่ระบบบริการหลังการขาย</td>
          <td width="30%" align="right">&nbsp;
	
          </td>
        </tr>
      </table>


<br style="font-size:10pt">
                

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
    <td width="12%" height="22" class="item ; dotline01">เลือกโครงการ :</td>
      <td width="40%" height="22" class="item ; dotline01">
    	<select name='project'  class='box' style='width:200px'  >
	    	<option value="">------ กรุณาเลือก ------</option>
		    <% if("ALL".equals(project)){ 
		    	 selected = "selected";
		       }
		    %>
		    	<option value='ALL' <%=selected%>>ทุกโครงการ</option>
		   	<%
		   	String all_in_comp = "";
		   	int count_comp = 0;
		   	sql.delete(0,sql.length());
		   	sql.append(" select com_id from lan:serv_pstaff where proj_id = 'ALL' and user_id = '"+user.getUserID()+"' ");
		   	System.out.println(sql.toString());
		   	rs = stmt.executeQuery(sql.toString());
		   	while(rs.next()){
		   		++count_comp;
		   		if(count_comp > 1) all_in_comp += ",";
		   		all_in_comp = "'"+doString.checkString(rs.getString("com_id"),"")+"'";
		   	}
		   	rs.close();
		   	
		   	if(count_comp > 0){
		   		sql.delete(0,sql.length());
			   	sql.append(" select distinct a.i_company as com_id , a.i_project as proj_id, a.n_project ")
			   		.append(" from lan:acxprojt a , lan:acsbudgh b ")
			   		.append(" where a.i_company = b.i_company ")
			   		.append(" and a.i_project = b.i_project ")
			   		//.append(" and a.i_company in ("+all_in_comp+") ")
			   		.append(" and b.d_year = '"+yy+"' ")
			   		.append(" and b.i_budg_type in (9) ")
			   		.append(" order by a.i_company , a.i_project ");
		   	}else{
			   	sql.delete(0,sql.length());
			   	sql.append(" select distinct a.com_id , a.proj_id , b.n_project ")
			   		.append(" from lan:serv_pstaff a , lan:acxprojt b ")
			   		.append(" where a.com_id = b.i_company ")
			   		.append(" and a.proj_id = b.i_project ")
			   		.append(" and a.user_id = '"+user.getUserID()+"'")
			   		.append(" order by a.com_id , a.proj_id ");
			}
		   	System.out.println(sql.toString());
		   	rs = stmt.executeQuery(sql.toString());
		   	while(rs.next()){
		   		String tmpComp = doString.checkString(rs.getString("com_id"),"");
		   		String tmpProj = doString.checkString(rs.getString("proj_id"),"");
		   		selected = "";
		   		if(project.equals(tmpComp+tmpProj)){
		   			selected = "selected";
		   		}
		   		
		   	%>
		   		<option value="<%=tmpComp+tmpProj%>" <%=selected%> ><%=tmpComp+tmpProj%> - <%=doString.DisplayThai(doString.checkString(rs.getString("n_project"),""))%></option>
		   	<%	
		   	}
		   	rs.close();
		   		
		   	 %>
		    </select>
      </td>
     
      <!-- 
      <td width="8%" class="item ; dotline01">วันที่แจ้ง :</td>
      -->
      <td width="8%" class="item ; dotline01">&nbsp;</td>
      <td height="22" class="item ; dotline01">
	      <div style="display:none;">
			<input name="d_keyin_beg" type="text" class="boxC" style="width:80px" value="<%=d_keyin_beg%>" readonly="readonly">&nbsp;&nbsp;<img src="images/i_calendar.gif" width="18" height="18" align="absmiddle"  style="cursor:hand" onClick="MM_openBrWindow('calendar.jsp?dateType=d_keyin_beg','Calendar','width=300,height=250,left=200,top=100')">
	          &nbsp; &nbsp; ถึง : &nbsp; &nbsp; 
			<input name="d_keyin_end" type="text" class="boxC" style="width:80px" value="<%=d_keyin_end%>" readonly="readonly">&nbsp;&nbsp;<img src="images/i_calendar.gif" width="18" height="18" align="absmiddle"  style="cursor:hand" onClick="MM_openBrWindow('calendar.jsp?dateType=d_keyin_end','Calendar','width=300,height=250,left=200,top=100')">
		  </div>
		  &nbsp;
	  </td>     
  </tr>

<tr>
    <td height="22" class="item ; dotline01">
  ประเภท :</td>
    <td height="22" class="item ; dotline01">
    <select name="i_itmno"  class='box' style='width:200px'  >
      <option value="00">ALL</option>
      <option value="01">งานซ่อมบ้าน</option>
      <option value="02">งานซ่อมสาธารณูฯ</option>
      <option value="03">งานซ่อมสาธารณะ</option>
      <option value="04">E-Service</option>
      <option value="05">แนะนำบ้าน</option>
      <option value="06">Checkup Program</option>      
    </select>
&nbsp;&nbsp;</td>
    <td class="item ; dotline01">&nbsp;</td>
    <td height="22" class="dotline01">
    <input type="radio" name="n_vendor_disp" id="radio1" value="N" <% if("N".equals(n_vendor_disp)){ %> checked="checked" <% } %>>
      ไม่แสดงผู้รับเหมา
      &nbsp;&nbsp;&nbsp;
    <input type="radio" name="n_vendor_disp" id="radio2" value="Y" <% if("Y".equals(n_vendor_disp)){ %> checked="checked" <% } %>>
      แสดงผู้รับเหมา  
      &nbsp;&nbsp;&nbsp;
      <img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22" style="cursor:hand" onclick="go()">
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
<br style="font-size:10pt">
			<table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="300">รายละเอียดการ Follow Up งานแจ้งซ่อม Call Center</td>
                <td class="item_tab3"></td>
                <td >&nbsp;</td>
              </tr>
            </table>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td valign="bottom" class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
    <td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>


<table border="0" width="100%" cellspacing="0" cellpadding="0">



  <tr>
    <td width="100%" class="frmL" align="center">
    
    
<table border="0" width="100%" cellspacing="0" cellpadding="0">
<tr>
	<% if("Y".equals(n_vendor_disp)){  %>
	    <td width="35%" class="col_name"><a href="javascript:sortBy('project')" >โครงการ</a></td>
		<td width="35%" class="col_name"><a href="javascript:sortBy('i_vendor')" >ผู้รับเหมา</a></td>
		<td class="col_name">จำนวนใบแจ้งซ่อม</td>
	<% }else{ %>
	    <td width="50%" class="col_name">โครงการ</td>
		<td width="50%" class="col_name">จำนวนใบแจ้งซ่อม</td>
	<% } %>
	</tr>
	
<% if("Y".equals(search)){ 

	row_vendor.delete(0,row_vendor.length());
	row_project.delete(0,row_project.length());
	if("ALL".equals(project)){
		sql.delete(0,sql.length());
		sql.append(" select count(c.i_docno) as i_docno , a.i_company , a.i_project ");
		if("Y".equals(n_vendor_disp)){
			sql.append(" , d.i_vendor ");
		}
		sql.append(" from lan:svc_dochd a, lan:svc_docdt b,lan:serv_dochd c,lan:serv_flow d ")
			.append(" where a.i_svc_docno = b.i_svc_docno ")
			.append(" and b.i_docno = c.i_docno ")
			//.append(" and a.i_company in ("+all_in_comp+") ")
			.append(" and date(a.d_keyin) between '"+thaiToDB(d_keyin_beg)+"'  and '"+thaiToDB(d_keyin_end)+"' ")
			//.append(" and b.i_itmno = '01' ")
			//.append(" and b.i_itmsub = '01' ")
			.append(" and c.i_doc_type = 'J' ")
			.append(" and c.f_status = 'OPN' ")
			.append(" and (c.d_complete_max is null or c.d_complete_max = '') ")
			.append(" and b.i_docno = d.i_docno")
			.append(" and d.f_itmstatus = '100' ");
		if("Y".equals(n_vendor_disp)){
			sql.append(" group by a.i_company , a.i_project , d.i_vendor ");
		}else{
			sql.append(" group by a.i_company , a.i_project  ");
		}
	}else{
		sql.delete(0,sql.length());
		sql.append(" select count(c.i_docno) as i_docno ");
		if("Y".equals(n_vendor_disp)){
			sql.append(" , d.i_vendor ");
		}
		sql.append(" from lan:svc_dochd a, lan:svc_docdt b,lan:serv_dochd c,lan:serv_flow d ")
			.append(" where a.i_svc_docno = b.i_svc_docno ")
			.append(" and b.i_docno = c.i_docno ")
			.append(" and a.i_company = '"+i_company+"' ")
			.append(" and a.i_project = '"+i_project+"' ")
			.append(" and date(a.d_keyin) between '"+thaiToDB(d_keyin_beg)+"'  and '"+thaiToDB(d_keyin_end)+"' ")
			.append(" and b.i_itmno = '01' ")
			.append(" and b.i_itmsub = '01' ")
			.append(" and c.i_doc_type = 'J' ")
			.append(" and c.f_status = 'OPN' ")
			.append(" and (c.d_complete_max is null or c.d_complete_max = '') ")
			.append(" and b.i_docno = d.i_docno")
			.append(" and d.f_itmstatus = '100' ");
		if("Y".equals(n_vendor_disp)){
			sql.append(" group by d.i_vendor ");
		}
	}
	
	//Sort Column
	if("ALL".equals(project)){
		if("Y".equals(n_vendor_disp)){
			if("project".equals(sort_col)){
				sql.append(" order by a.i_company , a.i_project , d.i_vendor ");
			}else if("i_vendor".equals(sort_col)){
				sql.append(" order by d.i_vendor , a.i_company , a.i_project ");
			}else{
				sql.append(" order by a.i_company , a.i_project , d.i_vendor ");
			}
		}else{
			sql.append(" order by a.i_company , a.i_project  ");
		}
	}else{
		if("Y".equals(n_vendor_disp)){
			sql.append(" order by d.i_vendor ");
		}
	}
	System.out.println(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	while(rs.next()){
		row_project.delete(0,row_project.length());
		project_total += rs.getInt("i_docno");
		
		if("ALL".equals(project)){
			String tmp_company = doString.checkString(rs.getString("i_company"),"");
			String tmp_project = doString.checkString(rs.getString("i_project"),"");
			row_project.append("<tr>");
			row_project.append("<td class=\"item ; dotline\" align=\"left\">&nbsp;");
			if("default".equals(sort_col) || "project".equals(sort_col)){
				if(old_project.equals(tmp_company+tmp_project)){
					row_project.append("&nbsp;");
				}else{
					old_project = tmp_company+tmp_project;
					row_project.append(tmp_company+tmp_project+"  "+doString.DisplayThai(getNProject(stmt1,tmp_company,tmp_project)));
				}
			}else{
				row_project.append(tmp_company+tmp_project+"  "+doString.DisplayThai(getNProject(stmt1,tmp_company,tmp_project)));
			}
			row_project.append("</td>");
			if("Y".equals(n_vendor_disp)){
				row_project.append("<td class=\"dotline\" align=\"left\">&nbsp;");
				row_project.append(doString.DisplayThai(getNVendor(stmt1,doString.checkString(rs.getString("i_vendor"),""))));
				row_project.append("</td>");
				row_project.append("<td align=\"center\" class=\"dotline\">");
				row_project.append("<a href=\"javascript:go2Details('"+doString.checkString(rs.getString("i_vendor"),"")+"','"+tmp_company+"','"+tmp_project+"');\">"+doString.displayNumber("#,##0",rs.getInt("i_docno")+0.0d)+"</a>");
				row_project.append("</td>");
			}else{
				row_project.append("<td align=\"center\" class=\"dotline\">");
				row_project.append("<a href=\"javascript:go2Details('','"+tmp_company+"','"+tmp_project+"');\">"+doString.displayNumber("#,##0",rs.getInt("i_docno")+0.0d)+"</a>");
				row_project.append("</td>");
			}
			row_project.append("</tr>\n");
		}else{
			row_project.append("<tr>");
			row_project.append("<td class=\"item ; dotline\" align=\"left\">&nbsp;");
			if(old_project.equals(i_company+i_project)){
				row_project.append("&nbsp;");
			}else{
				old_project = i_company+i_project;
				row_project.append(i_company+i_project+"  "+doString.DisplayThai(getNProject(stmt1,i_company,i_project)));
			}
			row_project.append("</td>");
			if("Y".equals(n_vendor_disp)){
				row_project.append("<td class=\"dotline\" align=\"left\">&nbsp;");
				row_project.append(doString.DisplayThai(getNVendor(stmt1,doString.checkString(rs.getString("i_vendor"),""))));
				row_project.append("</td>");
				row_project.append("<td align=\"center\" class=\"dotline\">");
				row_project.append("<a href=\"javascript:go2Details('"+doString.checkString(rs.getString("i_vendor"),"")+"','"+i_company+"','"+i_project+"');\">"+doString.displayNumber("#,##0",rs.getInt("i_docno")+0.0d)+"</a>");
				row_project.append("</td>");
			}else{
				row_project.append("<td align=\"center\" class=\"dotline\">");
				row_project.append("<a href=\"javascript:go2Details('','"+i_company+"','"+i_project+"');\">"+doString.displayNumber("#,##0",rs.getInt("i_docno")+0.0d)+"</a>");
				row_project.append("</td>");
			}
			row_project.append("</tr>\n");
		}
		out.print(row_project.toString());
	}
	rs.close();
%>
<% }  %>
<% if("ALL".equals(project) && "Y".equals(n_vendor_disp)){  %>
  <tr>
    <td class="dotline" align="left"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="13" height="13">&nbsp;<b>รวมทุกโครงการ</b></td>
    <td align="center" class="dotline">&nbsp;</td>
	<td align="center" class="dotline"><b><%=doString.displayNumber("#,##0",project_total+0.0d)%></b></td>
	</tr> 
<% }  %>
<% if("ALL".equals(project) && !"Y".equals(n_vendor_disp)){  %>
  <tr>
    <td class="dotline" align="left"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="13" height="13">&nbsp;<b>รวมทุกโครงการ</b></td>
	<td align="center" class="dotline"><b><%=doString.displayNumber("#,##0",project_total+0.0d)%></b></td>
	</tr> 
<% }  %>
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







        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">

            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:history.back()" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="/LHServ/SERV_Index.jsp" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
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
	
</FORM>

</BODY>

</HTML>
<%
	stmt.close();
	stmt1.close();
	conn.close();
	stmt=null;
	stmt1=null;
	conn=null;
} catch (Exception e) {
	e.printStackTrace();
	System.out.println("ERROR SERV_VendorFollow.jsp : " + sql.toString());
	System.out.println("ERROR SERV_VendorFollow.jsp : " + e.getMessage());
	throw new ServletException(e.getMessage());
} finally {
	// Clean up.
	try {
		if (rs != null) rs.close();
		if (stmt != null) stmt.close();
		if (stmt1 != null) stmt1.close();
		if (conn != null) conn.close();
	}
	catch( SQLException ignore ){}
}
%>
