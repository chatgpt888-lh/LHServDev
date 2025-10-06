<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.*" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.*" %>
<%@ include file="function.jsp" %>
<%@ include file="confirmLogin.jsp" %>
<%!
public String docFormat(String doc){//2559050001 --> 2559-05-0001
	if(doc != null && !"".equals(doc) && doc.length() == 10){
		return doc.substring(0,4) + "-" + doc.substring(4,6) + "-" + doc.substring(6);
	}else{
		return doc;
	}
}
 %>
<%
String empId = user.getEmpId();

Calendar right = Calendar.getInstance();
int dd = right.get(Calendar.DATE);
int mm = right.get(Calendar.MONTH)+1;
int yy = right.get(Calendar.YEAR);
if(yy < 2400){
	yy += 543;
}
int pYear = yy - 1;
Connection conn= null;
Statement stmt= null;
Statement stmt1= null;
ResultSet rs=null;
ResultSet rs1=null;
StringBuffer sql = new StringBuffer("");

String project = "";
String i_company = "";
String i_project = "";
String n_project = "";
String search = "";

String i_vendor = "";
String i_job = "";
String i_status = "";
try{
	if(ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	stmt1 = conn.createStatement();
	
	
	project = doString.checkString(request.getParameter("project"),"");
	if(!"".equals(project)){
		i_company = project.substring(0,2);
		i_project = project.substring(2);
	}

	search = doString.checkString(request.getParameter("search"),"N");
	i_vendor = doString.checkString(request.getParameter("i_vendor"),"");
	i_job = doString.checkString(request.getParameter("i_job"),"");
	i_status = doString.checkString(request.getParameter("i_status"),"");
	
	if("Y".equals(search) && !"".equals(project)){
       	sql.delete(0,sql.length());
   		sql.append(" select n_project from lan:acxprojt ")
   			.append(" where i_company = '"+i_company+"' ")
   			.append(" and i_project = '"+i_project+"' ");
   		rs = stmt.executeQuery(sql.toString());
   		if(rs.next()){
   			n_project = doString.DisplayThai(doString.checkString(rs.getString("n_project"),""));
   		}
   		rs.close();
   	}
%>
<HTML>
<HEAD>
<TITLE>สัญญา</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<SCRIPT LANGUAGE="JavaScript">
<!--
function refreshPage() {
	frmConHome.action="/LHServ/SERV_ConHome.jsp";
	frmConHome.submit();
}
function openVendor(){
	var form = document.frmConHome;
	if(form.project.value == ''){
	 	alert('กรุณาเลือกโครงการก่อนค่ะ');
		return;
	}
	window.open('/LHServ/search_vendor2.jsp?project='+form.project.value,'','width=600,height=400,scrollbars=yes');
}
function goSearch(){
	var form = document.frmConHome;
	form.search.value = 'Y';
	form.action="/LHServ/SERV_ConHome.jsp";
	form.submit();
}
function goAppr(i_docno,i_status){
	var form = document.frmConHome;
	form.i_docno.value = i_docno;
	form.search.value = 'N';
	if('N' == i_status){
		form.action="/LHServ/SERV_Contract.jsp";
	}else{
		form.action="/LHServ/SERV_ViewContract.jsp";
	}
	form.submit();
}
//-->
</SCRIPT>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM name="frmConHome" method="post" action="SERV_ConHome.jsp">
<input type="hidden" name="i_company" value="" />
<input type="hidden" name="i_project" value="" />
<input type="hidden" name="search" value="" />
<input type="hidden" name="i_docno" value="" />
<table border="0" width="100%" cellspacing="0" cellpadding="15">
  <tr>
    <td width="100%" align="center" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;รายละเอียดสัญญา</td>
        </tr>
      </table>
      <br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="160">ระบุรายละเอียด</td>
          <td class="item_tab3"></td>
                <td class="item_tab4">&nbsp;</td>
          <td class="item_tab5i" style="width:180px" >&nbsp;</td>
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
              <table border="0" width="100%" cellspacing="1" cellpadding="0">
                <tr> 
                  <td width="9%" class="item ; dotline01" height="22">โครงการ 
                    :</td>
                  <td width="91%" class="dotline01" height="22"> 
                    <select name='project' class='box' style='width:250px'>
                      <option value=''>------ โปรดเลือกโครงการ ------</option>
                    	<%
                    	//declaration
                    	String comp_all = "" , tmp_comp = "" , tmp_proj = "" , selected = "";
                    	
                    	//check user all
                    	rs = stmt.executeQuery(" select com_id from lan:serv_pstaff where proj_id = 'ALL' and user_id = '"+user.getUserID()+"' ");
                    	if(rs.next()){
                    		comp_all = "Y";
                    	}
                    	rs.close();
                    	
                    	//query string
                    	sql.delete(0,sql.length());
                    	if("Y".equals(comp_all)){
                    		sql.append(" select distinct a.i_company , a.i_project , a.n_project from lan:acxprojt a , lan:acsbudgh c ")
                    			.append(" where a.i_company = c.i_company ")
                    			.append(" and a.i_project = c.i_project ")
                    			.append(" and c.i_budg_type = '9' ")
                    			.append(" and c.d_year in ('")
								.append(yy).append("' , '")
								.append(pYear).append("') ")
                    			.append(" order by 1,2,3 ");
                    	}else{
	                    	sql.append(" select distinct a.i_company , a.i_project , a.n_project from lan:acxprojt a , lan:serv_pstaff b , lan:acsbudgh c ")
	                    		.append(" where a.i_company = b.com_id ")
	                    		.append(" and a.i_project = b.proj_id ")
	                    		.append(" and a.i_company = c.i_company ")
	                    		.append(" and a.i_project = c.i_project ")
                    			.append(" and c.d_year in ('")
								.append(yy).append("' , '")
								.append(pYear).append("') ")
	                    		.append(" and b.user_id = '"+user.getUserID()+"' ")
                    			.append(" order by 1,2,3 ");
                    	}
                    	//get 
                   		rs = stmt.executeQuery(sql.toString());
                   		while(rs.next()){
                   			tmp_comp = doString.checkString(rs.getString("i_company"),"");
                   			tmp_proj = doString.checkString(rs.getString("i_project"),"");
                   			
                   			selected = "";
                   			if((tmp_comp+tmp_proj).equals(project)){
                   				selected = "selected";
                   			}
                   			%><option value="<%=tmp_comp+tmp_proj%>"  <%=selected%>><%=tmp_comp+tmp_proj%> | <%=doString.DisplayThai(doString.checkString(rs.getString("n_project"),""))%></option><%
                   		}
                   		rs.close();
                    	
                    	
                      %>
                    </select>
                  </td>
                </tr>
                <tr> 
                  <td width="9%" class="item ; dotline01" height="22">ผู้รับเหมา 
                    : </td>
                  <td width="91%" class="dotline01" height="22">
                    <input type="text" name="i_vendor" class="box" style="width:70px"  value="<%=i_vendor%>">
                    &nbsp;&nbsp;<a href="#"><img border="0" src="images/i_search.gif" align="absmiddle" onclick="openVendor()"></a> 
                  </td>
                </tr>
                <tr>
                  <td width="9%" class="item ; dotline01" height="22">ประเภทงาน 
                    :</td>
                  <td width="91%" class="dotline01" height="22">
                    <select size="1" name="i_job" class="box" style="width:250px">
                      <option value="" >----- ทั้งหมด -----</option>
                      <%
                      		String i_itmjob = "";
	                		sql.delete(0,sql.length());
	                		sql.append(" select i_itmjob , n_itmjob from lan:serv_infboq where i_itmtype = '03' AND i_seq != '0000' ");
	                		rs = stmt.executeQuery(sql.toString());
	                		while(rs.next()){
	                			selected = "";
	                			i_itmjob = doString.checkString(rs.getString("i_itmjob"),"");
	                			if(i_job.equals(i_itmjob)){ 
	                				selected = "selected";
	                			}
	                			%><option value="<%=i_itmjob%>" <%=selected%> ><%=doString.DisplayThai(doString.checkString(rs.getString("n_itmjob"),""))%></option><%
	                		}
	                		rs.close();
	                  %>
                    </select>
                  </td>
                </tr>
                <tr>
                  <td width="9%" class="item ; dotline01" height="22">สถานะ 
                    :</td>
                  <td width="91%" class="dotline01" height="22">
                    <select size="1" name="i_status" class="box" style="width:250px">
                      <option value="" selected>----- ทั้งหมด -----</option>
                      <option value="N" <% if("N".equals(i_status)){ %> selected <% } %>>เอกสารใหม่</option>
                      <option value="W" <% if("W".equals(i_status)){ %> selected <% } %>>รออนุมัติ</option>
                      <option value="A" <% if("A".equals(i_status)){ %> selected <% } %>>อนุมัติแล้ว</option>
                      <option value="D" <% if("D".equals(i_status)){ %> selected <% } %>>ไม่อนุมัติ</option>
                    </select>
					&nbsp;<a href="#" onclick="goSearch()"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22" /></a>                  
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
</form>
<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
          <td class="item_tab2" width="160">เอกสารสัญญา</td>
                <td class="item_tab3"></td>
                <td class="item_tab4">&nbsp;</td>
                <td class="item_tab5">&nbsp;</td>
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
                <td width="15%" class="col_name" height="14">โครงการ</td>
                <td width="8%" class="col_name" height="14">เลขที่สัญญา</td>
                <td width="11%" class="col_name" height="14">วันที่สัญญา</td>
                <td width="15%" class="col_name" height="14">ประเภทงาน</td>
                <td width="15%" class="col_name" height="14">ผู้รับเหมา</td>
                <td width="7%" class="col_name" height="14">เลขที่สัญญา<br>อ้างอิง</td>
                <td width="7%" class="col_name" height="14">ยอดเงิน</td>
                <td width="8%" class="col_name" height="14">สถานะ</td>
                <td width="14%" class="col_name" height="14">ผู้อนุมัติ</td>
              </tr>
              <%
              if("Y".equals(search) && !"".equals(project)){
              
              	int count1 = 0;
				sql.delete(0,sql.length());
				sql.append(" select * from lan:serv_conhd ")
					.append(" where i_company = '"+i_company+"' ")
					.append(" and i_project = '"+i_project+"' ")
					.append(" and i_employ = '"+empId+"' ");
				if(!"".equals(i_vendor)){
					sql.append(" and i_vendor = '"+i_vendor+"' ");
				}
				if(!"".equals(i_job)){
					sql.append(" and i_job = '"+i_job+"' ");
				}
				if(!"".equals(i_status)){
					sql.append(" and i_status = '"+i_status+"' ");
				}
				sql.append(" order by i_company , i_project , i_docno ");
              	rs = stmt.executeQuery(sql.toString());
              	while(rs.next()){
              		++count1;
              		i_status = doString.checkString(rs.getString("i_status"),"");
              	%>
	              <tr> 
	                <td width="15%" class="dotline" align="left" ><%=n_project%></td>
	                <td width="8%" class="item ; dotline" align="center" ><a href="#" onclick="goAppr('<%=doString.checkString(rs.getString("i_docno"),"")%>','<%=i_status%>')"><%=docFormat(doString.checkString(rs.getString("i_docno"),""))%></a></td>
	                <td width="11%" class="dotline" align="center" ><%=DateUtil.ifxToThaiDate(doString.checkString(rs.getString("d_begin"),""))+" - "+DateUtil.ifxToThaiDate(doString.checkString(rs.getString("d_end"),""))%></td>
	                <td width="15%" class="dotline" align="left">
	                	<% i_job = doString.checkString(rs.getString("i_job"),"");
	                	
	                		sql.delete(0,sql.length());
	                		sql.append(" select n_itmjob from lan:serv_infboq where i_itmtype = '03' AND i_seq != '0000' AND i_itmjob = '"+i_job+"' ");
	                		rs1 = stmt1.executeQuery(sql.toString());
	                		if(rs1.next()){
	                			out.print(doString.DisplayThai(doString.checkString(rs1.getString("n_itmjob"),"")));
	                		}
	                		rs1.close();
	                	 %>
	                </td>
	                <td width="15%" class="dotline" align="left">
	                	<% 
	                	sql.delete(0,sql.length());
	                	sql.append(" select ven_name from lan:vendor ")
	                		.append(" where ven_no = '"+doString.checkString(rs.getString("i_vendor"),"")+"' ");
	                	rs1 = stmt1.executeQuery(sql.toString());
	                	if(rs1.next()){
	                		out.print(doString.DisplayThai(doString.checkString(rs1.getString("ven_name"),"")));
	                	}
	                	rs1.close();
	                	%>
	                </td>
	                <td width="7%" class="dotline" align="center"><%=doString.DisplayThai(doString.checkString(rs.getString("contract_no"),""))%>&nbsp;</td>
	                <td width="7%" class="dotline" align="right"><%=doString.displayNumber("#,##0.00",rs.getDouble("z_amount"))%></td>
	                <td width="8%" class="dotline" align="center" >
	                	<%
	                		
	                		if("N".equals(i_status)){
	                			out.print("เอกสารใหม่");
	                		}
	                		if("W".equals(i_status)){
	                			out.print("รออนุมัติ");
	                		}
	                		if("A".equals(i_status)){
	                			out.print("อนุมัติ");
	                		}
	                		if("D".equals(i_status)){
	                			out.print("ไม่อนุมัติ");
	                		}
	                	
	                	 %>
	                </td>
	                <td width="14%" class="dotline" align="left" >
	                <% 
	                	sql.delete(0,sql.length());
	                	sql.append(" select  n_prename_th  , n_nemploy_th , n_semploy_th from docflow:acemploy ")
	                		.append(" where i_employ = '"+doString.checkString(rs.getString("i_cur_appr"),"")+"' ");
	                	rs1 = stmt1.executeQuery(sql.toString());
	                	if(rs1.next()){
	                		out.print(doString.DisplayThai(doString.checkString(rs1.getString("n_prename_th"),"")) + " " + doString.DisplayThai(doString.checkString(rs1.getString("n_nemploy_th"),"")) + " " + doString.DisplayThai(doString.checkString(rs1.getString("n_semploy_th"),"")));
	                	}
	                	rs1.close();
	                %>
	                </td>
	              </tr>
              	<%
              	}
              	rs.close();
              	if(count1 == 0){
              	%>
              	
              <tr> 
                <td width="15%" class="dotline" align="center" colspan="9">-- ไม่พบข้อมูล --</td>
              </tr>
              	<%
              	}
              }else{
              	%>
              <tr> 
                <td width="15%" class="dotline" align="center" colspan="9">-- กรุณาเลือกโครงการที่ต้องการค้นหา --</td>
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
			<br style="font-size: 5pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="100" class="act_tab2">
            <a href="/LHServ/SERV_Contract.jsp"><img border="0" src="images/act_addcontractTH.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
				</td>   
            <td class="act_tab3"></td>   
            <td class="act_tab4">&nbsp;</td>  
          </tr>  
        </table>  
		<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
          <td class="item_tab2" width="160">เอกสารสัญญารออนุมัติ</td>
                <td class="item_tab3"></td>
                <td class="item_tab4">&nbsp;</td>
                <td class="item_tab5">&nbsp;</td>
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
                <td width="15%" class="col_name" height="14">โครงการ</td>
                <td width="8%" class="col_name" height="14">เลขที่สัญญา</td>
                <td width="11%" class="col_name" height="14">วันที่สัญญา</td>
                <td width="15%" class="col_name" height="14">ประเภทงาน</td>
                <td width="15%" class="col_name" height="14">ผู้รับเหมา</td>
                <td width="7%" class="col_name" height="14">เลขที่สัญญา<br>
                  อ้างอิง</td>
                <td width="7%" class="col_name" height="14">ยอดเงิน</td>
                <td width="8%" class="col_name" height="14">สถานะ</td>
                <td width="14%" class="col_name" height="14">ผู้ขออนุมัติ</td>
              </tr>
              <%
               if("Y".equals(search) && !"".equals(project)){
               	int count2 = 0;
				sql.delete(0,sql.length());
				sql.append(" select * from lan:serv_conhd ")
					.append(" where i_company = '"+i_company+"' ")
					.append(" and i_project = '"+i_project+"' ")
					.append(" and i_cur_appr = '"+empId+"' ");
				if(!"".equals(i_vendor)){
					sql.append(" and i_vendor = '"+i_vendor+"' ");
				}
				if(!"".equals(i_job)){
					sql.append(" and i_job = '"+i_job+"' ");
				}
				sql.append(" and i_status = 'W' ");
				sql.append(" order by i_company , i_project , i_docno ");
              	rs = stmt.executeQuery(sql.toString());
              	while(rs.next()){
              		++count2;
                %>
	              <tr> 
	                <td width="15%" class="dotline" align="left" ><%=n_project%></td>
	                <td width="8%" class="item ; dotline" align="center" ><a href="#" onclick="goAppr('<%=doString.checkString(rs.getString("i_docno"),"")%>','')"><%=docFormat(doString.checkString(rs.getString("i_docno"),""))%></a></td>
	                <td width="11%" class="dotline" align="center" ><%=DateUtil.ifxToThaiDate(doString.checkString(rs.getString("d_begin"),""))+" - "+DateUtil.ifxToThaiDate(doString.checkString(rs.getString("d_end"),""))%></td>
	                <td width="15%" class="dotline" align="left">
	                	<% i_job = doString.checkString(rs.getString("i_job"),"");
	                	
	                		sql.delete(0,sql.length());
	                		sql.append(" select n_itmjob from lan:serv_infboq where i_itmtype = '03' AND i_seq != '0000' AND i_itmjob = '"+i_job+"' ");
	                		rs1 = stmt1.executeQuery(sql.toString());
	                		if(rs1.next()){
	                			out.print(doString.DisplayThai(doString.checkString(rs1.getString("n_itmjob"),"")));
	                		}
	                		rs1.close();
	                	 %>
	                </td>
	                <td width="15%" class="dotline" align="left">
	                	<% 
	                	sql.delete(0,sql.length());
	                	sql.append(" select ven_name from lan:vendor ")
	                		.append(" where ven_no = '"+doString.checkString(rs.getString("i_vendor"),"")+"' ");
	                	rs1 = stmt1.executeQuery(sql.toString());
	                	if(rs1.next()){
	                		out.print(doString.DisplayThai(doString.checkString(rs1.getString("ven_name"),"")));
	                	}
	                	rs1.close();
	                	%>
	                </td>
	                <td width="7%" class="dotline" align="center"><%=doString.DisplayThai(doString.checkString(rs.getString("contract_no"),""))%>&nbsp;</td>
	                <td width="7%" class="dotline" align="right"><%=doString.displayNumber("#,##0.00",rs.getDouble("z_amount"))%></td>
	                <td width="8%" class="dotline" align="center" >รออนุมัติ
	                </td>
	                <td width="14%" class="dotline" align="left" >
	                <% 
	                	sql.delete(0,sql.length());
	                	sql.append(" select  n_prename_th  , n_nemploy_th , n_semploy_th from docflow:acemploy ")
	                		.append(" where i_employ = '"+doString.checkString(rs.getString("i_employ"),"")+"' ");
	                	rs1 = stmt1.executeQuery(sql.toString());
	                	if(rs1.next()){
	                		out.print(doString.DisplayThai(doString.checkString(rs1.getString("n_prename_th"),"")) + " " + doString.DisplayThai(doString.checkString(rs1.getString("n_nemploy_th"),"")) + " " + doString.DisplayThai(doString.checkString(rs1.getString("n_semploy_th"),"")));
	                	}
	                	rs1.close();
	                %>
	                </td>
	              </tr>
              <%
              	}
              	rs.close();
              	if(count2 == 0){
              	%>
              	
              <tr> 
                <td width="15%" class="dotline" align="center" colspan="9">-- ไม่พบข้อมูล --</td>
              </tr>
              	<%
              	}
              }else{
              	%>
              <tr> 
                <td width="15%" class="dotline" align="center" colspan="9">-- กรุณาเลือกโครงการที่ต้องการค้นหา --</td>
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
            <td width="75" class="act_tab2"></td>
            <td class="act_tab3"></td>
          <td class="act_tab4">&nbsp; <a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" width="50" height="15"></a></td>
          </tr>
        </table>
          </td>
        </tr>
      </table>
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
	System.out.println("ERROR SERV_ConHome.jsp : " + sql.toString());
	System.out.println("ERROR SERV_ConHome.jsp : " + e.getMessage());
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
