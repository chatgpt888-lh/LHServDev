<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>

<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%
	String userId = user.getUserID();
	String who = user.getUserWho();
	String venId = doString.checkString(request.getParameter("i_vendor"));
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;

	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();        
        //----=======================================----//


		String Selected = "";		
        String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase();
        String iCompany = selProj.length()>=6 ? selProj.substring(0,2) : "";
        String iProject = selProj.length()>=6 ? selProj.substring(3,6) : "";
		String iType = doString.checkString(request.getParameter("i_type"),"");
		String iCode = "";
%>

<HTML>
<HEAD>
<TITLE>ข้อมูลพื้นฐาน : กำหนดผู้รับเหมาร้านค้า</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">
<!--

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

function deleteData() {
    if (confirm("คุณต้องการลบข้อมูลที่ทำการเลือกทั้งหมดนี้ ?")) {
	   document.forms[0].mode.value="delete";
       document.forms[0].action = "<%=request.getContextPath()%>/VendorServlet"; 
       document.forms[0].submit();
    } 
}

function refreshPage() {
   document.forms[0].action = "<%=request.getContextPath()%>/vendor.jsp"; 
   document.forms[0].submit();
}

function addData() {
	if (document.forms[0].sel_project.value=="") {
		alert(" กรุณาเลือกโครงการ !! ");
		document.forms[0].sel_project.focus();
		return false;
	}
	if (document.forms[0].i_type.value=="") {
		alert(" กรุณาเลือกประเภทงาน !! ");
		document.forms[0].i_type.focus();
		return false;
	}
	if (document.forms[0].i_code.value=="") {
		alert(" กรุณาเลือกงาน !! ");
		document.forms[0].i_code.focus();
		return false;
	}

   document.forms[0].mode.value="add";
   document.forms[0].action = "<%=request.getContextPath()%>/vendor2.jsp"; 
   document.forms[0].submit();
}


//-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM NAME="frmVendor" method="post" action="vendor.jsp">

<input type="hidden" name="mode" value="">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ข้อมูลพื้นฐาน</td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">รายละเอียดผู้รับเหมาร้านค้า</td>
                <td class="item_tab3"></td>
                <td>&nbsp;</td>                
              </tr>
            </table>




<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top" ><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop" >&nbsp;</td>
    <td width="5" valign="top" align="right" ><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR" align="center">


  <table border="0" width="100%" cellspacing="1" cellpadding="0">
    <tr>
      <td width="10%" class="item ; dotline01"><nobr>โครงการ :</nobr></td>
      <td width="30%" class="dotline01">
				<select name='sel_project' class='box' style='width:250px' >
				<option value=''>------ กรุณาเลือก ------</option>
				<%
						int nowYear = (Calendar.getInstance()).get(Calendar.YEAR);
						if (nowYear<2400) nowYear += 543;
						sql.delete(0,sql.length());
						if (who.equals("A") || who.equals("B")) {
							sql.append(" select distinct p.i_company,p.i_project,p.n_project from ")
								  .append(" lan:acxprojt p,lan:acsbudgh b where ")
								  .append(" b.i_company=p.i_company and b.i_project=p.i_project ")
								  .append(" and b.d_year='").append(nowYear).append("' ")
								  .append(" order by p.i_company,p.i_project ");
						} else {
							sql.append(" select * from lan:serv_pstaff where user_id='").append(userId).append("' and proj_id='ALL' ");
							rs = stmt.executeQuery(sql.toString());
							if (rs.next()) {
								sql.delete(0,sql.length());
								sql.append(" select distinct p.i_company,p.i_project,p.n_project from ")
									  .append(" lan:acxprojt p,lan:acsbudgh b where ")
									  .append(" b.i_company=p.i_company and b.i_project=p.i_project ")
									  .append(" and b.d_year='").append(nowYear).append("' ")
									  .append(" order by p.i_company,p.i_project ");
							} else {
								sql.delete(0,sql.length());
								sql.append(" select p.i_company,p.i_project,p.n_project from ")
									  .append(" lan:acxprojt p,lan:job_staff b where ")
									  .append(" b.com_id=p.i_company and b.proj_id=p.i_project ")
									  .append(" and b.user_id='").append(userId).append("' ")
									  .append(" order by p.i_company,p.i_project ");
							}
							rs.close();
							rs=null;
						}
						if (sql.length()>0) {
							rs = stmt.executeQuery(sql.toString());
							while (rs.next()) {
								String iCom = doString.checkString(rs.getString("i_company"));
								String iProj = doString.checkString(rs.getString("i_project"));
								String nProj = doString.checkString(rs.getString("n_project"));
								String value = iCom+":"+iProj;
								String sel = "";

								if (value.equalsIgnoreCase(selProj)) {
									sel = " selected";
								}

								%><option value="<%=value%>"  <%=sel%>><%=iCom+iProj+" | "+nProj%></option><%

							} // end while
							rs.close();									
						}

				%>
			  </select>


      </td>
      <td width="10%" class="item ; dotline01"><nobr>ประเภท :</nobr></td>
      <td width="50%" class="dotline01">
				<select size="1" name="i_type" class="box" style="width:200px" onchange="refreshPage();">
				<option value=''>------ กรุณาเลือก ------</option>
       <option value="03" <%=iType.equals("03") ? " selected " : ""%>>03 ร้านค้าแอร์</option>
       <option value="04" <%=iType.equals("04") ? " selected " : ""%>>04 ร้านค้าปลวก</option>
				</select>	&nbsp;&nbsp;&nbsp;
				<a href="#"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22" onclick="refreshPage();"></a>
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
          <td class="col_name" width="5%"><input type="checkbox" name="main_check" onclick="checkAll(this,'main_check','del_id');"></td>
          <td class="col_name" width="65%">ผู้รับเหมา</td>
          <td class="col_name" width="10%">% Advance</td>
          <td class="col_name" width="10%">% หักเงินประกัน</td>
          <td class="col_name" width="10%">เงินฝาก</td>
        </tr>
        
        <%
        //-----====================== Get inf_stdc Data =======================---//
		int line = 0;
		String comId = "";
		String projId = "";
		String jobId = "";
		String venNme = "";
        sql.delete(0,sql.length());
		sql.append(" select c.ven_name,nvl(b.f_adv,'N') as f_adv,d.*,a.i_company,a.i_project,a.i_job,a.i_vendor from lan:inf_vendor a ")
			  .append(" left join lan:inf_stdc b on b.i_code=a.i_job ")
			  .append(" left join lan:vendor   c on c.ven_no=a.i_vendor ")
			  .append(" left join lan:inf_vend d on d.ven_no=a.i_vendor ")
			  .append(" where a.i_company='").append(iCompany).append("' ")
			  .append(" and a.i_project='").append(iProject).append("' ")
			  .append(" and a.i_job='").append(iCode).append("' ")
			  .append(" and d.ven_type='").append(iType).append("' ");
		rs = stmt.executeQuery(sql.toString());		
		while (rs.next()) {
			comId = doString.checkString(rs.getString("i_company"));		    
			projId = doString.checkString(rs.getString("i_project"));		    
			jobId = doString.checkString(rs.getString("i_job"));
			venId = doString.checkString(rs.getString("i_vendor"));
			venNme = doString.checkString(rs.getString("ven_name"));

			double zPcAdv = 0.0;
			double zPcDed = rs.getDouble("z_pc_ded");
			double zFixAmt = rs.getDouble("z_fix_amt");

			String fAdv = doString.checkString(rs.getString("f_adv"));
			if (fAdv.equalsIgnoreCase("Y")) {
				zPcAdv = rs.getDouble("z_pc_adv");
			} else {
				zPcAdv = 0.0;
			}


		    %>
		        <tr>
		          <td align="center" class="dotline" width="5%"><input type="checkbox" name="del_id" value="<%=comId%>:<%=projId%>:<%=jobId%>:<%=venId%>" onclick="checkAll(this,'main_check','del_id');"></td>
		          <td align="left" class="dotline" width="65%"><%=venId+" | "+venNme%></td>
		          <td class="dotline" align="right" width="10%"><%=doString.displayNumber("###,###.00", zPcAdv)%></td>
		          <td class="dotline" align="right" width="10%"><%=doString.displayNumber("###,###.00", zPcDed)%></td>
		          <td class="dotline" align="right" width="10%"><%=doString.displayNumber("###,###.00", zFixAmt)%></td>
		        </tr>		    
		    <%
		    line++;
		}
		rs.close();				
		
		//----========= Fill up blank line if this page display data less than 12 line ========--//
		while (line<10) {
		    %>
		        <tr>
		          <td align="center" class="dotline" width="5%" height="25px">&nbsp;</td>
		          <td class="dotline" align="center" width="65%">&nbsp;</td>
		          <td align="left" class="dotline" width="10%">&nbsp;</td>
		          <td align="left" class="dotline" width="10%">&nbsp;</td>
		          <td align="left" class="dotline" width="10%">&nbsp;</td>
		        </tr>		    
		    <%
		    line++;
		}
        //-----=================================================================---//        
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
            <td width="150" class="act_tab2">

            <img border="0" src="images/act_add.gif"             
			     onclick="addData();"
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">&nbsp; 
					
			<a href="#" onclick="deleteData();"><img border="0" src="images/act_delete.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>

            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4">
              <a href="<%=request.getContextPath()%>/SERV_Home.jsp" target="_self"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
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
	} catch (Exception e) {
		System.out.println("ERROR SERV_ChkupVend.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (stmt != null) stmt.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>