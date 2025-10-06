<%@ page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page errorPage="errorPage.jsp" %>

<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ include file="function.jsp" %>
<%@ include file="confirmLogin.jsp" %>

<%!
	public static String[] collectMethod = new String[]{
		"รูปแบบการจัดเก็บไม่ถูกต้อง !!", "ตั๋วสัญญาใช้เงิน (สำหรับงวด C4)", "รายปี (สำหรับงวด C5)", "ต่อตารางวา (สำหรับงวด C8)"	
	};	
	
%>

<%
	String selProj = doString.checkString(request.getParameter("sel_project"),"");
	String iCompany = selProj.length()>=6 ? selProj.substring(0,2) : "";
	String iProject = selProj.length()>=6 ? selProj.substring(3,6) : "";		
	int iPhase = Integer.parseInt(doString.checkString(request.getParameter("i_phase"),"0"));
	String act = doString.checkString(request.getParameter("act"),"");	
	String error = doString.checkString(request.getParameter("error"),"");	
	String errMsg = doString.checkString(request.getParameter("other_msg"),"");			

	int iPublic = Integer.parseInt(doString.checkString(request.getParameter("i_public"),"0"));
	int qYear = Integer.parseInt(doString.checkString(request.getParameter("q_year"),"0"));
	double zPayAmt = Double.parseDouble(doString.checkString(request.getParameter("z_pay_amt"),"0.00"));

	
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	
	try {
		if (ds == null)
		{
			getDS();
		}
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();
	
	
		//----- find n_project -------//
		String nProject = "";
		sql.delete(0,sql.length());
		sql.append(" select * from lan:acxprojt ")
		   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ");
		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
			nProject = doString.checkString(rs.getString("n_project"),"");
		} 
		rs.close();	
		
		//----- find lastest phase -----//
		int lastPhase = 0;
		int lastIPublic = 0;
		int lastQYear = 0;
		double lastZPayAmt = 0.0;
		
		sql.delete(0,sql.length());
	    sql.append(" select * from lan:acspublc ")
	       .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
	       .append(" order by i_phase desc ");		
		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
			lastPhase = rs.getInt("i_phase");
			lastIPublic = rs.getInt("i_Public");
			lastQYear = rs.getInt("q_year");
			lastZPayAmt = rs.getDouble("z_pay_amt");
		} 
		rs.close();	
		
		
		//--- default phase ---//
		if (act.equals("LOAD") || (iPhase<=0 && iPublic<=0 && qYear<=0 && zPayAmt<=0.0)) {
			iPhase = lastPhase;				
			if (act.equals("PUBLC_ADD")) {
				iPhase++; // auto increate for add mode
			}	
			iPublic = lastIPublic;
			qYear = lastQYear;
			zPayAmt = lastZPayAmt;
			
			if (act.equals("LOAD")) {
				act = "PUBLC_EDIT";
			}
		}
		
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

<script language="JavaScript">
<!--

	function saveData() {
		var chkForm = document.forms[0];
	
		var tmpChk = chkForm.i_phase.value;
		if (tmpChk=="" || isNaN(tmpChk) || tmpChk-0<=0.0) {
			alert(" กรุณาระบุเฟส !!");
			chkForm.i_phase.focus();
			return false;
		}	
		
		if (chkForm.i_public.value=="") {
			alert(" กรุณาระบุประเภทการจัดเก็บ !!");
			chkForm.i_public.focus();
			return false;
		}		
		
		tmpChk = chkForm.q_year.value;
		if (tmpChk=="" || isNaN(tmpChk) || tmpChk-0<=0.0) {
			alert(" กรุณาระบุจำนวนปีที่จัดเก็บ !!");
			chkForm.q_year.focus();
			return false;
		}
		
		tmpChk = chkForm.z_pay_amt.value;
		if (tmpChk=="" || isNaN(tmpChk) || tmpChk-0<=0.0) {
			alert(" กรุณาระบุจำนวนเงินที่จัดเก็บ !!");
			chkForm.z_pay_amt.focus();
			return false;
		}
			
		document.forms[0].action="/LHServ/SERV_SavePhaseProjServlet";
		document.forms[0].submit();
	}
	
//-->
</script>
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM method="POST" action="">

<input type="hidden" name="act" id="act" value="<%=act %>">
<input type="hidden" name="sel_project" id="sel_project" value="<%=selProj %>">


<TABLE border="0" width="100%" cellpadding="0" cellspacing="0">
<TBODY>
<TR>
<TD valign="top" width="800">

<!-- Start insert your HTML body here -->

<table border="0" width="780" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center">
    
                    <br style="font-size:8pt">
    

      <table border="0" width="750" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
           ตั้งข้อมูลพื้นฐาน เฟสโครงการ (C5,C8)</td>
          <td width="50%" align="right">
                  
			<div id="SubMenu">
			<table border="0" width="300" cellspacing="1" cellpadding="0">
			  <tr>
				<td width="70%" class="submenu">&nbsp;</td>
				<td width="30%" class="submenu">&nbsp;</td>
			  </tr>
			  <tr>
				<td width="70%">&nbsp;</td>
				<td width="30%">&nbsp;</td>
			</tr>
			</table>
			</div>
                  
          </td>
        </tr>
      </table>

<br style="font-size:1pt">





<table border="0" width="750" cellspacing="0" cellpadding="0">
  <tr>
	<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
	<td class="item_tab2" width="200">รายละเอียดเฟส</td>
	<td class="item_tab3"></td>
	<td class="item_tab4">&nbsp;</td>
	<td class="item_tab5"></td>
  </tr>
</table>
                    <br style="font-size:3pt">



	<table border="0" width="750" cellspacing="1" cellpadding="1">
	  <tr class="gray">
		<td  width="120" class="item"><nobr>โครงการ :</nobr></td>
		<td><%=iCompany+iProject+" | "+doString.DisplayThai(nProject) %></td>
      </tr>	  	
	  <tr>
		<td  width="120" class="item"><nobr>เฟส :</nobr></td>
		<td>
		<%
			if (act.equals("PUBLC_ADD")) {
				%>
				<input type="text" class="box" style="width:40px" maxlength="2" name="i_phase" id="i_phase" value="<%=iPhase %>">
				&nbsp; &nbsp;<%=lastPhase>0 ? "(เฟสปัจจุบันคือ "+lastPhase+")" : "ไม่พบข้อมูลเฟสก่อนหน้า" %>		
				<%
			} else {
				%>
				<input type="hidden" name="i_phase" id="i_phase" value="<%=iPhase %>">
				<%=iPhase %>		
				<%
			}
		%>
		</td>
	  </tr>
	  <tr class="gray">
		<td  width="120" class="item"><nobr>ประเภทการจัดเก็บ :</nobr></td>
		<td>
		<select name="i_public" id="i_public" class="box" style="width:200px">
		<option value="">--- กรุณาเลือก ---</option>
		<%
			String sel = "";
			for (int i=1;i<collectMethod.length;i++) {
				sel = "";
				if (iPublic==i) {
					sel = "selected";
				}
			
				%><option value="<%=i %>" <%=sel %>><%="["+i+"] - "+collectMethod[i] %></option><%
			} // end for
		%>
		</select>
		</td>
	  </tr>	      	  									
	  <tr class="gray">
		<td  width="120" class="item"><nobr>จำนวนปีที่จัดเก็บ :</nobr></td>
		<td><input name="q_year" id="q_year" type="text" class="box" style="width:40px;" value="<%=qYear %>"> &nbsp; ปี</td>
      </tr>	      		      		      			      		     		
	  <tr>
		<td  width="120" class="item"><nobr>จำนวนเงินที่จัดเก็บ :</nobr></td>
		<td>
		<input type="text" class="boxR" name="z_pay_amt" id="z_pay_amt" style="width:80px;" value="<%=doString.displayNumber("######0.00",zPayAmt) %>">
		 &nbsp; บาท
		</td>
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
			<IMG border="0" src="images/act_save.gif" 
			onmouseout="nereidFade(this,70,50,5)" 
			onmouseover="nereidFade(this,100,50,5)" 
			onclick="saveData()"
			style="FILTER: alpha(opacity=70); cursor:hand" width="70" height="27">
		&nbsp;
		</td>   
		<td class="act_tab3">&nbsp;</td>   
		<td class="act_tab4"><a href="SERV_PhaseProjList2.jsp?sel_project=<%=selProj %>">
		<img border="0" src="images/bu_back.gif" width="50" height="15"></a>
		<a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" width="50" height="15"></a>
		</td>  
	  </tr>  
	</table>  

	  </td>
	</tr>

    </table>

<!-- End insert your HTML body  -->

</TD>
</TR>
</TABLE>
			
			<!-- Start insert your HTML footer here -->			
			
<table border="0" width="780" cellspacing="0" cellpadding="0">
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


</FORM>      

<%
		if (error.length()>0) {
			if (errMsg.trim().length()>0) {
				if (errMsg.indexOf("ERR_EXIST_PHASE")>=0) {
					errMsg = "มีข้อมูลเฟสนี้ในระบบแล้ว!!";
				} else {
					errMsg = "พบข้อผิดพลาดในการจัดเก็บข้อมูล, กรุณาติดต่อฝ่าย IT !!\\n\\n"+errMsg;
				}
			}
			%><script>alert('<%=errMsg %>');</script><%
		}


		stmt.close();
		conn.close();
		conn = null;
	}
	catch (Exception e) {
		System.out.println("!!!ERROR SERV_PhaseProjForm2.jsp : " + e.getMessage());
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

</BODY>
</HTML>