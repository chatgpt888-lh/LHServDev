<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page errorPage="errorPage.jsp" %>

<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ include file="function.jsp" %>
<%@ include file="confirmLogin.jsp" %>

<%!
	public static String[] collectMethod = new String[]{
		"รูปแบบการจัดเก็บไม่ถูกต้อง !!", "ตั๋วสัญญาใช้เงิน (สำหรับงวด C4)", "รายปี (สำหรับงวด C5)", "ต่อตารางวา (สำหรับงวด C8)"	
	};			
	
	public String displayDate(String date) {
		String result = "";
		
		if (date.trim().length()>=10) {
			int y = Integer.parseInt(date.substring(0,4));
			if (y<2400) y += 543;
			result = date.substring(8,10)+"/"+date.substring(5,7)+"/"+y;
		} else {
			result = "-";
		}
		
		return result;
	}	

	
	public String genProjectListboxByUserId(Connection conn,String userId,String name,String value,String params,boolean getAllProj) {
		 StringBuffer html = new StringBuffer();
		 StringBuffer sql = new StringBuffer();
		Statement stmt = null;
		 ResultSet rs = null;
		 boolean allProject = false;
		 SERV_CommonData common = new SERV_CommonData(conn);

		 try {
			stmt = conn.createStatement();
			//---============= Check user is vendor or employee ===============----//
			String userWho = "";
			String iPerson = "";	

			sql.delete(0,sql.length());
			//remark by pradoem 2012.04.24: sql.append(" select * from lan:useracl where user_id='").append(userId).append("' and user_acl='S' ");
			sql.append(" select user_id,user_acl,user_who,i_person from lan:useracl where user_id='").append(userId).append("' and user_acl='S' ");
			rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
				userWho = doString.checkString(rs.getString("user_who"),""); 
				iPerson = doString.checkString(rs.getString("i_person"),""); 		
			}
			rs.close();			

			///----=============== Generate Query for Vendor and Employee ==================---//

			if (userWho.equalsIgnoreCase(Constants.PERMISSION_VENDOR)) {
				sql.delete(0,sql.length());
				sql.append(" select (a.i_company) as com_id, (a.i_project) as proj_id, b.n_project from lan:serv_venprj a ")
					  .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
					  .append(" where a.i_vendor='").append(iPerson).append("' ")
					  .append(" and a.i_type='01' order by a.i_company, a.i_project ");
			} else {
				 sql.delete(0,sql.length());
				 sql.append(" select a.com_id, a.proj_id, b.n_project  from lan:serv_pstaff a ")
					   .append(" left join lan:acxprojt b on b.i_company=a.com_id  and  b.i_project=a.proj_id ")
					   .append(" where a.user_id = '").append(userId).append("' ")
					   .append(" order by a.com_id,a.proj_id ");

			}
			 rs = stmt.executeQuery(sql.toString());
			 //-------============== Generate List box ===================------//
			 html.append("<select name='").append(name).append("' ").append(params).append(" >");
			 html.append("<option value=''>"+Constants.LISTBOX_SELECT_LABEL+"</option>");

			 while (rs.next()) {
				String comId = doString.checkString(rs.getString("com_id"),"");
				String projId = doString.checkString(rs.getString("proj_id"),"");
				String projName = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
				String val = comId+":"+projId;
				String selected = "";
				if (value!=null && val.equalsIgnoreCase(value)) {
				   selected = " selected "; 
				}

				if (projId.equalsIgnoreCase("ALL")) {
				   //---====== If ALL Permission , set flag and exit loop =======----//
				   allProject = true;
				   break;
				 } else {
				   //---====== Normal Case , generate project by permission =======---//
				   html.append("<option value='").append(val).append("' ").append(selected).append(">")
						   .append(comId).append("-").append(projId).append(" - ").append(projName)
						   .append("</option>");				                   
				 }		        
			 } // end while		 
			 //html.append("<option value='ALL_PROJ' "+(value.equalsIgnoreCase("ALL") ? "selected" : "")+">"+Constants.LISTBOX_ALLPROJECT_LABEL+"</option>");
			 String selected = "";
			 //System.out.println(" value :"+value);
			 if(value.equals("ALL")){
			    selected = " selected";
			 }

			//System.out.println(" selected :"+selected);
			 html.append("<option value='ALL' "+selected+">"+Constants.LISTBOX_ALLPROJECT_LABEL+"</option>");
			 html.append("</select>");
			 //----=====================================================----//
			 rs.close();
			 stmt.close();
			 if (allProject) {
				 //----====== AllProject is true , gen All Project Listbox ========----//
				 html.delete(0,html.length());
				 html.append(common.genAllProjectListbox(name,value,params,getAllProj));
			 }		     
		 } catch (Exception e) {
			 System.out.println(" genProjectListboxByUserId Error : "+e.getMessage());
		 } finally {
			 try {
				if (rs!=null) rs.close();
				if (stmt!=null) stmt.close();
			 } catch (Exception ex) {}
		 }
		 return html.toString();
	}	
%>

<%
	String selProj = doString.checkString(request.getParameter("sel_project"),"");
	String iCompany = selProj.length()>=6 ? selProj.substring(0,2) : "";
	String iProject = selProj.length()>=6 ? selProj.substring(3,6) : "";	
	String error = doString.checkString(request.getParameter("error"),"");	
	String errMsg = doString.checkString(request.getParameter("other_msg"),"");		

	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	
	
	//--- get today for calculate ---//
	Calendar now = Calendar.getInstance(TimeZone.getTimeZone("Asia/Bangkok"));
	int nowYear = now.get(Calendar.YEAR);
	if (nowYear>2400) nowYear -= 543;
	int nowMonth = now.get(Calendar.MONTH)+1;
		   
	try {
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();       
		stmt1 = conn.createStatement();       
        //----=======================================----//    
        		
			
%>

<HTML>
<HEAD>
<TITLE>ตั้งข้อมูลพื้นฐาน เฟสโครงการ (C5,C8)</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="MainStyle.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript" type="text/javascript" src="chromeless_35.js"></script>
<script language="javascript" type="text/javascript" src="window_style.js"></script>
<script language="javascript" type="text/javascript" src="Hscroll.js"></script>

<base target="_self">

<SCRIPT LANGUAGE="JavaScript">

  function searchData() {
  	 if (document.forms[0].sel_project.value=="") {
  		 alert(" กรุณาระบุโครงการ !!");
  	 	 return false;
  	 }
  
	 document.forms[0].action="SERV_PhaseProjList2.jsp";
	 document.forms[0].submit();
  } 
  
  function addData() {
  	 if (document.forms[0].sel_project.value=="") {
  		 alert(" กรุณาระบุโครงการ !!");
  		 return false;
  	 }
  	 
  	 document.forms[0].act.value = "PUBLC_ADD";
  	 document.forms[0].action="SERV_PhaseProjForm2.jsp";
	 document.forms[0].submit();
  }   

  function delData(delPhase) {
  	 if (document.forms[0].sel_project.value=="") {
  		 alert(" กรุณาระบุโครงการ !!");
  		 return false;
  	 }
  	 
  	 if (confirm("คุณแน่ใจว่าต้องการลบเฟส ?")) {
  	 	 document.forms[0].act.value = "PUBLC_DEL";
  	 	 document.forms[0].del_phase.value = delPhase;
	  	 document.forms[0].action="/LHServ/SERV_SavePhaseProjServlet";
		 document.forms[0].submit();
  	 }
  }
  

</SCRIPT>


</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">

<input type="hidden" name="act" value="">
<input type="hidden" name="del_phase" value="">

<TABLE border="0" width="100%" cellpadding="0" cellspacing="0">
<TBODY>
<TR>
<TD valign="top" width="800">

<table border="0" width="780" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center" class="BD">
    
	 <br style="font-size:8pt">
	 
      <table border="0" width="750" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
           ตั้งข้อมูลพื้นฐาน เฟสโครงการ (C5,C8)</td>
          <td width="30%" align="right">
          </td>
        </tr>
      </table>


<br style="font-size:10pt">

	<table border="0" width="750" cellspacing="0" cellpadding="0">
		<tr>
			<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
			<td class="item_tab2" width="200">รายละเอียดเฟส</td>
			<td class="item_tab3"></td>
			<td class="item_tab4">&nbsp;</td>
			<td class="item_tab5" width="25">&nbsp;</td>
		</tr>
	</table>

<table border="0" width="750" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="gray" align="center">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td height="22" class="item ; dotline01" width="10%">โครงการ :</td>
    <td height="22" width="40%" class="dotline01">
		<nobr>
		<%=genProjectListboxByUserId(conn,user.getUserID(),"sel_project",selProj," class='box' style='width:250px' ",true) %>         
	    &nbsp;&nbsp;
        <img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22" style="cursor:hand" onclick="searchData();">
        </nobr>
	</td>
    <td height="22" class="item ; dotline01" width="10%" valign="top">&nbsp;</td>
    <td height="22" width="40%" class="dotline01" valign="top">&nbsp;</td>
  </tr> 
</table>

</td>
  </tr>
</table>


<!---- phase block ---->
<br style="font-size:10pt">

	<table border="0" width="750" cellspacing="0" cellpadding="0">
		<tr>
			<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
			<td class="item_tab2" width="200">รายละเอียดเฟส</td>
			<td class="item_tab3"></td>
			<td class="item_tab4">&nbsp;</td>
			<td class="item_tab5" width="25">&nbsp;</td>
		</tr>
	</table>

<table border="0" width="750" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL" align="center">
    
    
<table border="0" width="100%" cellspacing="0" cellpadding="0">
   <tr style="height:20px">
    <td width="5%" class="col_name1" align="center" valign="middle">เฟส</td>
    <td width="20%" class="col_name2" align="center" valign="middle">รูปแบบการจัดเก็บ</td>
    <td width="14%" class="col_name1" align="center" valign="middle">จำนวนปีที่จัดเก็บ</td>
    <td width="14%" class="col_name2" align="center" valign="middle">จำนวนเงิน</td>
    <td width="5%" class="col_name1" align="center" valign="middle">&nbsp;</td>
   </tr>
  <%
  	String iPhase = "";	
  	int iPublic = 0;
  	int qYear = 0;
  	double zPayAmt = 0.0;
  	
	int cnt = 0;
	int cntLockUsed = 0;
	String link = "";
	String bgColor = "";
	
    sql.delete(0,sql.length());
    sql.append(" select * from lan:acspublc ")
       .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
       .append(" order by i_phase ");
	rs = stmt.executeQuery(sql.toString());
	while (rs.next()) {
		iPhase = doString.checkString(rs.getString("i_phase"),"");			
		iPublic = rs.getInt("i_public");
		qYear = rs.getInt("q_year");
		zPayAmt = rs.getDouble("z_pay_amt");	
		cnt++;	
		
		//--- count lock used ---//
		cntLockUsed = 0;
		sql.delete(0,sql.length());
		sql.append(" select count(*) as cnt from lan:acxslock ")
		   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
		   .append(" and i_phase='"+iPhase+"' and i_lor is not null ");
		rs1 = stmt1.executeQuery(sql.toString());		
		if (rs1.next()) {
			cntLockUsed = rs1.getInt("cnt");
		}
		rs1.close();
		
		bgColor = "col_center";
		if (cnt%2==0) {
			bgColor += " ; gray";		
		}
		link = "SERV_PhaseProjForm2.jsp?sel_project="+selProj+"&i_phase="+iPhase;
			
		%>
		<tr class="<%=bgColor %>">
			<td class="dotline" align="center">&nbsp;<%=iPhase %></td>
			<td class="dotline" align="left">&nbsp;
			<%											
				if (iPublic<0 || iPublic>=collectMethod.length) {
					iPublic = 0; // reset to use error message
				}
				out.println("<span style='color:red'>["+iPublic+"]</span> - "+collectMethod[iPublic]);
			%>
			</td>
			<td class="dotline" align="right"><nobr><%=doString.displayNumber("#,##0",qYear) %> ปี&nbsp;</nobr></td>		
			<td class="dotline" align="right"><nobr><%=doString.displayNumber("#,###,##0.00",zPayAmt) %> บาท&nbsp;</nobr></td>		
			<td class="dotline" align="center">
				<nobr>
				&nbsp;
				<a href="<%=link %>&act=LOAD"><img src="images/i_pen.gif" border="0"></a>
				<%
					if (cntLockUsed<=0) {
						%> &nbsp; <a href="javascript:delData('<%=iPhase %>');"><img src="images/i_delete.gif" border="0"></a><%
					}						
				%>
				&nbsp;
				</nobr>
			</td>	
		</tr>							
		<%			
	} // end while
	rs.close();
	
	if (cnt<=0) {
		//--- no phase in lan:acxslock ---//
		%>
		  <tr>
			<td  colspan="8" class="dotline" align="center">&nbsp;<span style='color:red'>ไม่พบข้อมูลการตั้งเฟสแปลงขาย</span></td>
		  </tr>					
		<%
	}

  %>		
 
</table>    
    
    </td>
  </tr>  
</table>

<table border="0" width="750" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>	

<br style="font-size:5pt">

<table border="0" width="750" cellspacing="0" cellpadding="0">
<tr><td><b style="color:red; font-size:14px">* หน้าจอนี้เป็นการตั้งเฟสค่าบริการสาธารณะสำหรับใช้คำนวนงวด C5, C8</b></td></tr>
</table>   

<br style="font-size:10pt">

<table border="0" width="750" cellspacing="0" cellpadding="0" height="30">
  <tr>
	<td class="act_tab1"></td>
	<td width="75" class="act_tab2">
	<nobr>
		<img border="0" src="images/act_add.gif" 
			onmouseout=nereidFade(this,70,50,5)
			onclick="addData();"
			onmouseover=nereidFade(this,100,50,5)     
			style="FILTER: alpha(opacity=70);cursor:hand" width="70" height="27"> &nbsp;	
	</nobr>
	</td>   
			
			
	<td class="act_tab3">&nbsp;</td>   
	<td class="act_tab4" valign="top">&nbsp;
	 	<a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a> &nbsp;
	</td>  
  </tr>  
</table>  
		
		
        </td>
      </tr>
    </table>
	

<table border="0" width="750" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center">

<br style="font-size:20pt">

<TABLE border=0 cellspacing=0 cellpadding=0 width="600">
  <tr><td width="100%" class="copyright" align="center">
  Best Viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5  
  <br>ติชมแสดงความคิดเห็น : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a> &nbsp;หรือ Computer Department&nbsp; โทร 2308490-98,2308451-3  
  <br><img src="images/copyright.gif" width="510" height="28"></td></tr>
</TABLE> 

    </td>
  </tr>
</table>		


</TD>
</TR>
</TBODY>
</TABLE>

 
</FORM>


</BODY>

</HTML>
<%
		if (error.length()>0) {
			if (errMsg.trim().length()>0) {
				errMsg = "\\n\\n"+errMsg;
			}
			%><script>alert('พบข้อผิดพลาดในการจัดเก็บข้อมูล, กรุณาติดต่อฝ่าย IT !!<%=errMsg %>');</script><%
		}

		stmt.close();
		stmt1.close();
		stmt = null;
		stmt1 = null;

	} catch (Exception e) {
		System.out.println("ERROR SERV_PhaseProjList2.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (rs1 != null) rs1.close();
			if (stmt != null) stmt.close();
			if (stmt1 != null) stmt1.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>
