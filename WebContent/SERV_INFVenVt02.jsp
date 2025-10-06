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
	    String error = doString.checkString(request.getParameter("error"),"");
	    String mode = doString.checkString(request.getParameter("mode"),"add");
	    String venNo = doString.UnicodeToMS874(doString.checkString(request.getParameter("ven_no"),""));
	    String iJob = "";
	    String vatTax = doString.UnicodeToMS874(doString.checkString(request.getParameter("vat_tax_flag"),""));
	    String glCode = doString.UnicodeToMS874(doString.checkString(request.getParameter("gl_code"),""));
	    String advCode = "";
	    String dedCode = "";
	    String fAdv = "";


		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();        



		//---============= If EDIT Mode , load old data  =============----//
        if (mode.equalsIgnoreCase("EDIT") && error.length()<=0) {
			sql.delete(0,sql.length());
			sql.append(" select * from lan:servvenvt where ")
			      .append(" ven_no = '").append(venNo).append("' ");
		    rs = stmt.executeQuery(sql.toString());
		    while (rs.next()) {
		        venNo = doString.checkString(rs.getString("ven_no"),""); 
		        vatTax = doString.checkString(rs.getString("vat_tax_flag"),""); 
		        glCode = doString.checkString(rs.getString("gl_code"),""); 
		    }
		    rs.close();		     
		}
		
		/*
		if (error.length()>0) {
		    //-----======= If receive error from servlet , get value =========-----//
		    venNo = doString.checkString(request.getParameter("ven_no"),"");
		    iJob = doString.checkString(request.getParameter("i_job"),"");
		}*/
		
		//----===== Special Attribute for edit mode (Key Fields) =======-----//
		String editAttr = "";
		if (mode.equalsIgnoreCase("EDIT")) {
		   editAttr = " readonly style='color:#CCCCCC' "; 
		}
		
		
        //----===================================================----//

%>

<HTML>
<HEAD>
<TITLE>ข้อมูลพื้นฐาน : รายละเอียดรหัสบัญชีงานสาธารณูฯ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">
<!--
function save() {



   if (document.forms[0].ven_no.value=="") {
      alert(" กรุณาเลือกผู้รับเหมา !");
      document.forms[0].ven_no.focus();
      return false;
   }

   if (document.forms[0].vat_tax_flag.value=="") {
      alert(" กรุณากรอก Vat / Tax !");
      document.forms[0].vat_tax_flag.focus();
      return false;
   }
/*
   if (document.forms[0].gl_code.value=="") {
      alert(" กรุณากรอกรหัส GL !");
      document.forms[0].gl_code.focus();
      return false;
   }
*/

   document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFVenVt.jsp";
   document.forms[0].submit();
}

function  inputFloat(obj) {
      if((event.keyCode < 48 || event.keyCode > 57) && event.keyCode!=46) {
	     event.returnValue = false;
	  } else if (event.keyCode==46) {
	     var chkval = obj.value+".";
	     if (chkval.indexOf(".")!=chkval.lastIndexOf(".")) {
	         event.returnValue = false;
	     }
	  }
}

function refreshPage() {
	document.forms[0].action="<%=request.getContextPath()%>/SERV_INFVenVt02.jsp";
	document.forms[0].submit();
}

-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">


<FORM method="POST" action="">

  <input type="hidden" name="mode" value="<%=mode%>">

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
    <td class="item ; dotline01" height="22" width="18%">รหัสผู้รับเหมา
      :</td>
    <td height="22" width="82%" class="dotline01">
	<%
		if (mode.equalsIgnoreCase("ADD")) {			
			%>
				<select size="1" name="ven_no" class="box" style="width:300px">
				<option value=''>------ กรุณาเลือก ------</option>
				<option value='999999'>999999 - ALL VENDOR</option>
				<%
					sql.delete(0,sql.length());
					sql.append(" select distinct a.i_vendor,b.ven_name from lan:serv_venprj a ")
						  .append(" left join lan:vendor b on b.ven_no=a.i_vendor where a.i_type = '02'")
						  .append(" order by a.i_vendor ");
					rs = stmt.executeQuery(sql.toString());
					while (rs.next()) {
						String iVendor = doString.checkString(rs.getString("i_vendor"),""); 
						String venName = doString.DisplayThai(doString.checkString(rs.getString("ven_name"),"")); 
						String sel = "";
						if (iVendor.equals(venNo)) {
							sel = " selected ";
						}

						%><option value="<%=iVendor%>" <%=sel%>><%=iVendor+" - "+venName%></option><%
					} // end while
					rs.close();		    
				%>
				</select>		
			<%
		} else {
			%>
			<%=venNo%>
			<input type="hidden" name="ven_no" value="<%=venNo%>">
			<%
		}
	%>
	</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="18%">Vat / Tax
      :</td>
    <td height="22" width="82%" class="dotline01"><input type="text" name="vat_tax_flag" class="box" style="width:100px" maxlength="50" value="<%=vatTax%>" onkeypress="inputFloat(this);"></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="18%">รหัส GL
      :</td>
    <td height="22" width="82%" class="dotline01"><input type="text" name="gl_code" class="box" style="width:100px" maxlength="50" value="<%=glCode%>"></td>
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
            <td class="act_tab4"><a href="<%=request.getContextPath()%>/SERV_INFVenVt01.jsp" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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

	
</BODY>

</FORM>

</HTML>

<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_INFVenVt02.jsp : " + e.getMessage());
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