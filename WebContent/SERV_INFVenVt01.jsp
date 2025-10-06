<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%

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


%>

<HTML>
<HEAD>
<TITLE>ข้อมูลพื้นฐาน : รายละเอียด VAT/TAX งานสาธารณูฯ</TITLE>
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
       document.forms[0].action = "<%=request.getContextPath()%>/SERV_INFVenVt.jsp?mode=delete"; 
       document.forms[0].submit();
    } 
}

//-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM method="post" action="">

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
                <td class="item_tab2" width="250">กำหนดรหัสบัญชี</td>
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
          <td class="col_name" width="5%"><input type="checkbox" name="main_check" onclick="checkAll(this,'main_check','del_id');"></td>
          <td class="col_name" width="17%">รหัสผู้รับเหมาตัดเงิน</td>
          <td class="col_name" width="19%">VAT / TAX</td>
          <td class="col_name" width="19%">รหัส GL</td>
          <td class="col_name" width="12%">&nbsp;</td>
          <td class="col_name" width="12%">&nbsp;</td>
          <td class="col_name" width="16%">&nbsp;</td>
        </tr>        
        <%
        sql.delete(0,sql.length());
		sql.append(" select * from lan:servvenvt  order by ven_no");
		rs = stmt.executeQuery(sql.toString());
		int line = 0;
		while (rs.next()) {
			String venNo = doString.checkString(rs.getString("ven_no"));		    
			String vatTax = doString.checkString(rs.getString("vat_tax_flag"), "&nbsp;");
			String glCode = doString.checkString(rs.getString("gl_code"), "&nbsp;");
		    %>
		        <tr>
		          <td align="center" class="dotline" width="5%"><input type="checkbox" name="del_id" value="<%=venNo%>" onclick="checkAll(this,'main_check','del_id');"></td>
		          <td class="dotline" align="center" width="17%"><a href="SERV_INFVenVt02.jsp?mode=edit&ven_no=<%=venNo%>"><%=venNo%></a></td>
		          <td class="dotline" align="center" width="19%"><%=vatTax%></td>
		          <td class="dotline" align="center" width="19%"><%=glCode%></td>
		          <td class="dotline" align="center" width="12%">&nbsp;</td>
		          <td class="dotline" align="center" width="12%">&nbsp;</td>
		          <td class="dotline" align="center" width="16%">&nbsp;</td>
		        </tr>		    
		    <%
		    line++;
		}
		rs.close();				
		
		//----========= Fill up blank line if this page display data less than 12 line ========--//
		while (line<10) {
		    %>
				<tr>
				  <td class="dotline" width="5%">&nbsp;</td>
				  <td class="dotline" width="17%">&nbsp;</td>
				  <td class="dotline" width="19%">&nbsp;</td>
				  <td class="dotline" width="19%">&nbsp;</td>
				  <td class="dotline" width="12%">&nbsp;</td>
				  <td class="dotline" width="12%">&nbsp;</td>
				  <td class="dotline" width="16%">&nbsp;</td>
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

            <a href="SERV_INFVenVt02.jsp?mode=add"><img border="0" src="images/act_add.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp; 
					
			<a href="#" onclick="deleteData();"><img border="0" src="images/act_delete.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>

            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="<%=request.getContextPath()%>/SERV_Home.jsp" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=request.getContextPath()%>/SERV_Home.jsp" target="_self"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>  
        </table>  






          </td>
        </tr>
      </table>

			
			

<br style="font-size:30pt">

<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
  <tr><td width="100%" class="copyright" align="center">
  Best viewed with 800x600 screen resolution&nbsp;on&nbsp;an Internet Explorer
  version 5.5 และ 6<br>
  ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;
  หรือ โทร. 0-2230-8374 (คุณปรีชาชาญ
  ฝ่ายก่อสร้าง), 0-2230-8457 (ฝ่าย IT)  
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE> 

</FORM>
	
<%
  String error = doString.checkString(request.getParameter("error"),"");
  if (error.length()>0) {
     String msg = " พบปัญหาขณะลบข้อมูล!  กรุณาตรวจสอบข้อมูล และทำการลบใหม่อีกครั้ง";
     %><script>alert("<%=msg%>");</script><%
  }
%>	
	
</BODY>

</HTML>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_INFVenVt01.jsp : " + e.getMessage());
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