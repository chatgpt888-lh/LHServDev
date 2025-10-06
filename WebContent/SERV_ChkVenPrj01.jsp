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

	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;

	try {
        //----============ Initialize Variable ============----//        
	    String error = "";
	    String iVendor = doString.checkString(request.getParameter("i_vendor"));
	    String iType = doString.checkString(request.getParameter("i_type"),"");
	    String iCode = "";
        String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase();
        String iCompany = selProj.length()>=6 ? selProj.substring(0,2) : "";
        String iProject = selProj.length()>=6 ? selProj.substring(3,6) : "";


		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();        


        //----======== Find Project Name ===========----//
		String nProject = "";
		sql.delete(0,sql.length());
		sql.append(" select n_project from lan:acxprojt where i_company='").append(iCompany).append("' and i_project = '").append(iProject+"'");
		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
			nProject = doString.checkString(rs.getString("n_project"),""); 
		}
		rs.close();		 
		String venName = "";
		rs = stmt.executeQuery("select bus_name from lan:stpvendr where vend_code = '"+iVendor+"'");
		if (rs.next()) {
			venName = doString.checkString(rs.getString("bus_name"),""); 
		}
		rs.close();		 
		
		

        //----======== Find Type & Job Description ===========----//
		String typeDesc = "";
		String jobDesc = "";
		if (iType.equals("03")) {
			typeDesc = "ร้านค้าแอร์";
		} else {
			typeDesc = "ร้านค้าปลวก";
		}
%>

<HTML>
<HEAD>
<TITLE>ข้อมูลพื้นฐาน : 01รายละเอียดร้านค้าภายในโครงการ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">
<!--
function save() {

   if (document.forms[0].i_vendor.value=="") {
      alert(" กรุณาระบุร้านค้า !");
      return false;
   }
   if (document.forms[0].i_type.value=="03") {
	   if (document.forms[0].i_group.value=="") {
	      alert(" กรุณาเลือกกลุ่ม Staff !");
	      return false;
	   }
	}
   document.forms[0].action="<%=Constants.APP_PATH%>/SERV_ChkVenPrjServlet";
   document.forms[0].submit();
}


function refreshPage() {
   document.forms[0].action="<%=Constants.APP_PATH%>/SERV_ChkVenPrj01.jsp";
   document.forms[0].submit();
}

-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">


<FORM method="POST" action="">

<input type="hidden" name="mode" value="add">
<input type="hidden" name="sel_project" value="<%=selProj%>">
<input type="hidden" name="i_type" value="<%=iType%>">

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
                <td class="item_tab2" width="250">รายละเอียดร้านค้า</td>
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
    <td class="item ; dotline01" height="22" width="18%">โครงการ
      :</td>
    <td height="22" width="82%" class="dotline01">
			<input type="hidden" name="sel_project" value="<%=selProj%>">
			<nobr><%=iCompany+iProject+" | "+doString.DisplayThai(nProject)%></nobr>
	</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="18%">ประเภท
      :</td>
    <td height="22" width="82%" class="dotline01">
				<%=typeDesc%>&nbsp;
				<input type="hidden" name="i_type" value="<%=iType%>">
	</td>
  </tr>

  <tr>
    <td class="item ; dotline01" height="22" width="18%">ร้านค้า
      :</td>
    <td height="22" width="82%" class="dotline01">
	<input type="text" name="i_vendor" value="<%=iVendor%>" class="box" maxlength="10" size="10" style="width:80px;color:#999999" readonly>
	&nbsp;&nbsp;<a href="#"><img border="0" src="images/i_search.gif" align="absmiddle" onclick="window.open('search_vendor.jsp?venType=<%=iType%>','','width=600,height=400,scrollbars=yes');"></a> &nbsp; 
	<%=doString.DisplayThai(venName)%>
	</td>
  </tr>
  <tr>
<%if (iType.equals("03")) {%>  
  <tr>
    <td class="item ; dotline01" height="22" width="18%">Staff No. :</td>
    <td height="22" width="82%" class="dotline01">
    <select name='i_group' class='box' style='width:180px'>
       <option value="">------ กรุณาเลือก ------</option>
       <option value="01">01</option>
       <option value="02">02</option>
       <option value="03">03</option>
       <option value="04">04</option>
       <option value="05">05</option>
       <option value="06">06</option>
       <option value="07">07</option>
       <option value="08">08</option>
       <option value="09">09</option>
       <option value="10">10</option>                            
    </select>    
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



<br style="font-size:10pt">


        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">

            <a href="#" onclick="save();"><img border="0" src="images/act_saveandclose.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>

            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="<%=request.getContextPath()%>/SERV_ChkVenPrj.jsp?sel_project=<%=selProj%>&i_type=<%=iType%>" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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

	
</BODY>

</FORM>

</HTML>

<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_ChkVenPrj01.jsp : " + e.getMessage());
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