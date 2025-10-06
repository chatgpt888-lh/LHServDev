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
public String getEmpName(Statement stmt ,String i_employ){
	StringBuffer sql = new StringBuffer("");
	ResultSet rs = null;
	String name=  "";
	try{
		rs = stmt.executeQuery(" select n_prename_th || ' ' || n_nemploy_th || ' ' || n_semploy_th   as name from docflow:acemploy where i_employ = '"+i_employ+"' ");
		if(rs.next()){
			name = doString.checkString(rs.getString("name"),"");
		}
		rs.close();
	}catch(SQLException e){
	}finally{
		rs = null;
	}
	return name;
}
public String getEmpJob(Statement stmt ,String i_employ){
	StringBuffer sql = new StringBuffer("");
	ResultSet rs = null;
	String i_code = "";
	String n_desc = "";
	try{
		rs = stmt.executeQuery(" select i_job from docflow:acempjob where i_employ = '"+i_employ+"' order by  d_job desc ");
		if(rs.next()){
			i_code = doString.checkString(rs.getString("i_job"),"");
		}
		rs.close();
		
		rs = stmt.executeQuery(" select n_desc from docflow:acempstd where i_code = '"+i_code+"' and i_type = '10' ");
		if(rs.next()){
			n_desc = doString.checkString(rs.getString("n_desc"),"");
		}
		rs.close();
		
	}catch(SQLException e){
	}finally{
		rs = null;
	}
	return n_desc;
}
public String getApprName(Statement stmt , String i_employ_app1){
	StringBuffer sql = new StringBuffer("");
	ResultSet rs = null;
	String option = "";
	try{
		sql.delete(0,sql.length());
   		sql.append(" select a.* , b.n_prename_th || ' ' || b.n_nemploy_th || ' ' || b.n_semploy_th   as name ")
   			.append(" from lan:serv_rstaff a, docflow:acemploy b ")
			.append(" where a.i_employ = b.i_employ ")
			.append(" and a.i_role = '"+i_employ_app1+"' order by a.i_employ desc ");
		rs = stmt.executeQuery(sql.toString());
   		while(rs.next()){         
     		option = "<option value=\""+doString.checkString(rs.getString("i_employ"),"")+"\">"+doString.checkString(rs.getString("name"),"")+"</option>";
   		}
   		rs.close();
	}catch(SQLException e){
	}finally{
		rs = null;
	}
	return option;
  
}
public String docFormat(String doc){//2559050001 --> 2559-05-0001
	if(doc != null && !"".equals(doc) && doc.length() == 10){
		return doc.substring(0,4) + "-" + doc.substring(4,6) + "-" + doc.substring(6);
	}else{
		return doc;
	}
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
ResultSet rs1=null;
StringBuffer sql = new StringBuffer("");
SERV_CommonData common = null;    
doString str = new doString();

String project = "";
String i_company = "";
String i_project = "";
String i_docno = "";
String d_begin = "";
String d_end = "";
String i_phase = "";
String contract_no = "";
String i_job = "";
String i_vendor = "" ;
String s_due = "";
String d_due = "";

String d_pay = "";
double z_amt = 0.0;
double z_amount = 0.0;
String n_job = "";
String c_comment = "";
String i_appr = "";

String approve = "";
String i_cur_appr = "";
try{
	if(ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	stmt1 = conn.createStatement();
	
	common = new SERV_CommonData(conn); 

	project = doString.checkString(request.getParameter("project"),"");
	i_docno = doString.checkString(request.getParameter("i_docno"),"");
	if(!"".equals(project) && !"".equals(i_docno)){
		project = doString.checkString(request.getParameter("project"),"");
		if(!"".equals(project)){
			i_company = project.substring(0,2);
			i_project = project.substring(2);
		}

		sql.delete(0,sql.length());
		sql.append(" select * from lan:serv_conhd ")
			.append(" where i_company = '"+i_company+"' ")
			.append(" and i_project = '"+i_project+"' ")
			.append(" and i_docno = '"+i_docno+"' ");
		rs = stmt.executeQuery(sql.toString());
		if(rs.next()){
			d_begin = doString.checkString(rs.getString("d_begin"));
			d_end = doString.checkString(rs.getString("d_end"));
			i_vendor = doString.checkString(rs.getString("i_vendor"),"");
			i_phase = doString.checkString(rs.getString("i_phase"),"");
			contract_no = doString.checkString(rs.getString("contract_no"),"");
			i_job = doString.checkString(rs.getString("i_job"),"");
			s_due = doString.checkString(rs.getString("s_due"),"");
			d_due = doString.checkString(rs.getString("d_due"),"");
			c_comment = doString.checkString(rs.getString("c_comment"),"");
			c_comment = str.replace(c_comment,"|break|","\n");
			i_cur_appr = doString.checkString(rs.getString("i_cur_appr"),"");
		}
		rs.close();
		rs=null;
	}
%>
<HTML>
<HEAD>
<TITLE>สัญญางานบริการ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<base target="_self">
<script type="text/javascript" >
function doApprove(){
	var form = document.frmServ;
	form.mode.value = 'APPROVE';
	form.action = '/LHServ/SERV_ContractServlet';
	form.submit();
}
function doDeny(){
	var form = document.frmServ;
	form.mode.value = 'DENY';
	form.action = '/LHServ/SERV_ContractServlet';
	form.submit();
}
</script>
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM name="frmServ" method="post" action="">
<input type="hidden" name="mode" value="" />
<input type="hidden" name="project" value="<%=project%>" />
<input type="hidden" name="i_docno" value="<%=i_docno%>" />
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
            <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;สัญญางานบริการ</td>
          <td width="30%" align="right">&nbsp;</td>
        </tr>
      </table>
<br style="font-size:10pt">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
	<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
	<td class="item_tab2" width="160">รายละเอียดสัญญา</td>
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
                  <td height="22" class="item ; dotline01" width="10%">เลขที่สัญญา 
                    : </td>
                  <td height="22" width="36%" class="item ; dotline01"><%=docFormat(i_docno)%></td>
                  <td height="22" width="11%" class="item ; dotline01">วันที่สัญญาตั้งแต่ 
                    : </td>
                  <td height="22" width="43%" class="dotline01"><%=DateUtil.ifxToThaiDateNoTime(d_begin)+" - "+DateUtil.ifxToThaiDateNoTime(d_end)%></td>
                </tr>
                <tr> 
                  <td height="22" class="item ; dotline01" width="10%">โครงการ 
                    :</td>
                  <td height="22" width="36%" class="dotline01">
                  <%
                  	if(!"".equals(project)){
                  		rs = stmt.executeQuery(" select n_project from lan:acxprojt where i_company = '"+i_company+"' and i_project = '"+i_project+"'");
                  		if(rs.next()){
                  			out.println(project + " : " + doString.DisplayThai(doString.checkString(rs.getString("n_project"))));
                  		}
                  		rs.close();
                  		rs=null;
                  	}
                  %>
                  </td>
                  <td height="22" width="11%" class="item ; dotline01">เฟส :</td>
                  <td height="22" width="43%" class="dotline01"><%=i_phase%>&nbsp;</td>
                </tr>
                <tr> 
                  <td height="22" class="item ; dotline01" width="10%">ผู้รับเหมา 
                    :</td>
                  <td height="22" width="36%" class="dotline01">
                  <% 
                  	if(!"".equals(i_vendor)){
                  		rs = stmt.executeQuery(" select ven_name from lan:vendor where ven_no = '"+i_vendor+"' ");
                  		if(rs.next()){
                  			out.println(i_vendor+" : "+doString.DisplayThai(doString.checkString(rs.getString("ven_name"),"")));
                  		}
                  		rs.close();
                  	}
				  %>&nbsp;</td>
                  <td height="22" width="11%" class="item ; dotline01">เลขที่สัญญาอ้างอิง 
                    : </td>
                  <td height="22" width="43%" class="dotline01"><%=doString.DisplayThai(contract_no)%>&nbsp;</td>
                </tr>
                <tr> 
                  <td height="22" class="item ; dotline01" width="10%">ประเภทงาน 
                    : </td>
                  <td height="22" width="36%" class="dotline01">
                  <%
                  	if(!"".equals(i_job)){
                  		rs = stmt.executeQuery(" select n_itmjob from lan:serv_infboq where i_itmtype = '03' AND i_seq != '0000' AND i_itmjob = '"+i_job+"'");
                  		if(rs.next()){
                  			out.println(i_job+" : "+doString.DisplayThai(doString.checkString(rs.getString("n_itmjob"),"")));
                  		}
                  		rs.close();
                  	}
                  %>
                  </td>
                  <td height="22" width="11%" class="item ; dotline01">จำนวนงวดงาน 
                    : </td>
                  <td height="22" width="43%" class="dotline01"><%=s_due%>&nbsp;งวด 
                  </td>
                </tr>
                <tr> 
                  <td height="22" class="item ; dotline01" width="10%">วันที่จ่ายรอบแรก 
                    : </td>
                  <td height="22" width="36%" class="dotline01"><%=DateUtil.ifxToThaiDate(d_due)%></td>
                  <td height="22" width="11%" class="dotline01">&nbsp;</td>
                  <td height="22" width="43%" class="dotline01">&nbsp;</td>
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
	<td class="item_tab2" width="160">รายละเอียดงวดงาน</td>
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
                  <td class="col_name" width="6%">งวดที่</td>
				  <td class="col_name" width="62%">รายละเอียด</td>
                  <td class="col_name" width="20%">วันที่จ่ายตามสัญญา</td>
                  <td class="col_name" width="12%">จำนวนเงิน</td>
                </tr>
                <%
                int count = 0;
				double totAmnt = 0;
                if(!"".equals(project) && !"".equals(i_docno)){
	                sql.delete(0,sql.length());
					sql.append(" select * from lan:serv_condt ")
						.append(" where i_company = '"+i_company+"' ")
						.append(" and i_project = '"+i_project+"' ")
						.append(" and i_docno = '"+i_docno+"' ")
						.append(" order by s_due ");
					rs = stmt.executeQuery(sql.toString());
					while(rs.next()){
						totAmnt += rs.getDouble("z_amount");
						%>
                <tr> 
                  <td class="dotline" align="center" width="6%"><%=++count%></td>
				  <td class="dotline" align="left" width="62%"><%=doString.DisplayThai(doString.checkString(rs.getString("n_job"),""))%>&nbsp;</td>				  
                  <td class="dotline" align="center" width="20%"><%=DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString("d_pay"),""))%></td>
                  <td class="dotline" align="right" width="12%"><%=doString.displayNumber("#,##0.00",Double.parseDouble(doString.checkString(rs.getString("z_amount"),"0")))%></td>
                </tr>
						<%
					}
					rs.close();
				}
				if(count == 0){
                %>
                
                <tr> 
                  <td class="dotline" align="center" width="6%" colspan="4">-- ไม่พบข้อมูล --</td>
                </tr>
                <% } %>
                	<tr>
	                  <td class="dotline" align="center" width="6%">&nbsp;</td>
					  <td class="item; dotline" align="left" width="62%">&nbsp;</td>
	                  <td class="item; dotline" align="right" width="20%">รวมเงิน :</td>
	                  <td class="dotline" align="right" width="12%"><%=doString.displayNumber("###,###,###.00", totAmnt)%></td>
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
	<td class="item_tab2" width="160">บันทึกเพิ่มเติม</td>
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

<br style="font-size:5pt">

<table border="0" width="100%" cellspacing="1" cellpadding="0">
<tr>
<td width="100%">
<textarea rows="5" name="Comment" cols="20" class="box" style="width:100%" onFocus="this.blur()"><%=doString.DisplayThai(c_comment)%>&nbsp;</textarea>
</td>
</tr>
</table>
<br style="font-size:5pt">
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
<br style="font-size: 10pt">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" valign="top" align="center" style="background-image: url('images/bg_flow.jpg'); background-repeat: no-repeat; background-position: -1px 10px">

            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="160">สายงานการอนุมัติ</td>
                <td class="item_tab3"></td>
                <td class="item_tab4">&nbsp;</td>
                <td class="item_tab5i" style="width:180px"></td> 
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
                  <TR>
                    <TD width="6%">&nbsp;</TD>
                    <TD width="2%">&nbsp;</TD>
                    <TD width="2%">&nbsp;</TD>
                    <TD width="90%">&nbsp;</TD>
                  </TR>
                  <%
                  String i_status = "" , i_approver = "";
                  int num = 0;
                  if(!"".equals(project) && !"".equals(i_docno)){
	                sql.delete(0,sql.length());
					sql.append(" select * from lan:serv_conap ")
						.append(" where i_company = '"+i_company+"' ")
						.append(" and i_project = '"+i_project+"' ")
						.append(" and i_docno = '"+i_docno+"' ")
						.append(" order by s_approver ");
					rs = stmt.executeQuery(sql.toString());
					while(rs.next()){
						++num;
						i_approver = doString.checkString(rs.getString("i_approver"),"");
						i_status = doString.checkString(rs.getString("i_status"),"");
						if("W".equals(i_status) && i_approver.equals(i_cur_appr) && user.getEmpId().equals(i_approver)){
							approve = "Y";
						}	
						%>
                  <TR>
                    <TD width="6%">&nbsp;</TD>
                    <TD width="2%"><IMG height=15 src="images/no<%=num%>.gif" width=15 align=absMiddle border=0></TD>
                    <TD width="2%">
                    <% if("A".equals(i_status)){ %>
                    <IMG height=16 src="images/i_pass.gif" width=19 align=absMiddle border=0>
                    <% }else if ("W".equals(i_status)) { %>
                    <IMG height=16 src="images/i_wait.gif" width=19 align=absMiddle border=0>
                    <% }else{ %>
                    <IMG height=16 src="images/i_pass_blank.gif" width=19 align=absMiddle border=0>
                    <% } %>
                    </TD>
                    <TD width="90%"><%=doString.DisplayThai(getEmpName(stmt1,doString.checkString(rs.getString("i_approver"),"")))%></TD>
                  </TR>
                  <TR>
                    <TD width="6%"></TD>
                    <TD width="2%"></TD>
                    <TD width="2%"></TD>
                    <TD width="90%">(<%=doString.DisplayThai(getEmpJob(stmt1,doString.checkString(rs.getString("i_approver"),"")))%>)</TD>
                  </TR>
                  <TR>
                    <TD width="6%"></TD>
                    <TD width="2%"></TD>
                    <TD width="2%"></TD>
                    <TD width="90%">
          			<% if(num == 1){ %>          
                    	ผู้ขออนุมัติ	
                    <% }else{ %>
                    	ผู้อนุมัติคนที่ <%=num-1%>
                    <% } %>
                    </TD>
                  </TR>
                  <TR>
                    <TD colspan="4"><br>
                    </TD>
                  </TR>
                   <%
                   }
                   rs.close();
                   
                  }
                    %>
                </TABLE>
						</td>
					</tr>
			</table>
			<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						<td width="5" valign="bottom"><img border="0"
							src="images/Corn03.gif" width="5" height="5"></td>
						<td class="frmBottom">&nbsp;</td>
						<td width="5" valign="bottom" align="right"><img border="0"
							src="images/Corn04.gif" width="5" height="5"></td>
					</tr>
			</table>


<br style="font-size:10pt">
<table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
  <tr>
    <td class="act_tab1"></td>
    <td width="170" class="act_tab2">
    <% if("Y".equals(approve)){ %>
     <A href="javascript:doApprove()"><IMG border="0" src="images/act_approve.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27"></A>&nbsp;
     <A href="javascript:doDeny()"><IMG border="0" src="images/act_deny.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27"></A>
    <% } %> 
    &nbsp;       
    </td>
    <td class="act_tab3"></td>
            <td class="act_tab4"><a href="SERV_ConHome.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
  </tr>
</table>
</table>
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
	System.out.println("ERROR SERV_ViewContract.jsp : " + sql.toString());
	System.out.println("ERROR SERV_ViewContract.jsp : " + e.getMessage());
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