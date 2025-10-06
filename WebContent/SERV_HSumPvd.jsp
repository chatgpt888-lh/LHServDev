<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%><%@ page import="java.util.*" %><%@ page import="java.sql.*" %><%@ page import="javax.naming.*" %><%@ page import="com.lh.util.doString" %><%@ page import="com.lh.util.DateUtil" %><%@ page import="serv.common.*" %>
<%@ include file="function.jsp" %>
<%@ include file="confirmLogin.jsp" %>
<%!
//create by pradoem 2025-06026
public String genVendorList2(Connection conn, String name, String selProj, String value, String params) {
    StringBuffer html = new StringBuffer();
    StringBuffer sql = new StringBuffer();
    Statement stmt = null;
    ResultSet rs = null;

    String comId = "";
    String projId = "";

    try {
        // แยกค่า selProj เช่น "COM001:PROJ002"
        if (selProj != null && selProj.indexOf(":") != -1) {
            StringTokenizer tokenizer = new StringTokenizer(selProj, ":");
            if (tokenizer.countTokens() == 2) {
                comId = tokenizer.nextToken();
                projId = tokenizer.nextToken();
            }
        }

        // สร้าง SQL query
        sql.append("SELECT b.vend_code, b.bus_name, a.* ")
           .append("FROM lan:serv_venprj a ")
           .append("LEFT JOIN lan:stpvendr b ON b.vend_code = a.i_vendor ")
           .append("WHERE a.i_type = '01' ")
           .append("AND a.i_company = '").append(comId).append("' ")
           .append("AND a.i_project = '").append(projId).append("' ")
           .append("ORDER BY b.bus_name");

        stmt = conn.createStatement();
        rs = stmt.executeQuery(sql.toString());

        // สร้าง HTML select
        html.append("<select id="+name+" name='").append(name).append("' ").append(params).append(">");
        html.append("<option value=''>").append(Constants.LISTBOX_SELECT_LABEL).append("</option>");

        while (rs.next()) {
            String iVendor = doString.checkString(rs.getString("vend_code"), "");
            String vendorName = doString.checkString(doString.DisplayThai(rs.getString("bus_name")), "");

            html.append("<option value='").append(iVendor).append("'");

            if (value != null && iVendor.equalsIgnoreCase(value)) {
                html.append(" selected");
            }

            html.append(">").append(iVendor).append("-").append(vendorName).append("</option>");
        }

        html.append("</select>");
    } catch (Exception e) {
        System.out.println("genVendorList2 Error: " + e.getMessage());
    } finally {
        try {
            if (rs != null) rs.close();
        } catch (Exception ignore) {}

        try {
            if (stmt != null) stmt.close();
        } catch (Exception ignore) {}
    }

    return html.toString();
}
 %>
<%   	 //----============ Declare Variables for search data ===========----//	String selProj = doString.checkString(request.getParameter("sel_project"),"");
	String comId = "";
	String projId = "";
	if (!selProj.equals("")) {
		comId = selProj.substring(0,2);
		projId = selProj.substring(3);
	}
   	String vendor = doString.checkString(request.getParameter("vendor"));  
   	String optionSelected = "";
   	String code = "";
	Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
	String payMonth = "";
	if( request.getParameter("payMonth") != null ){
		payMonth = doString.checkString(request.getParameter("payMonth"));
	}
	if (payMonth.equals("")) {
		if(Integer.toString(rightNow.get(Calendar.MONTH)+1).length() == 1) {
			payMonth = "0" + Integer.toString(rightNow.get(Calendar.MONTH)+1);
		} else {
			payMonth = Integer.toString(rightNow.get(Calendar.MONTH)+1);
		}
	}
	
	String payYear = "";
	if( request.getParameter("payYear") != null ){
		payYear = doString.checkString(request.getParameter("payYear"));
	}
	
	if (payYear.equals("")) {
		payYear = Integer.toString(rightNow.get(Calendar.YEAR));
	}
    //----============ Declare Variables for data ===========----//	Connection conn = null;	Statement stmt = null;	ResultSet rs = null;	SERV_CommonData com = null;	try {        //----============ Initialize Variable ============----//		if (ds == null) getDS();		conn = ds.getConnection();		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);		conn.setAutoCommit(true);		stmt = conn.createStatement();   		com = new SERV_CommonData(conn);  
%><HTML><HEAD><TITLE>รายงาน : สรุปใบเบิกงวดสำหรับผู้รับเหมา</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">

   function queryProject() {
   		frmSumPvd.action="<%=request.getContextPath()%>/SERV_HSumPvd.jsp";
       frmSumPvd.submit();
   }
   function report() {
   	frmSumPvd.action="<%=request.getContextPath()%>/PrintHSumPvdServlet";
	frmSumPvd.target="_blank";
   	frmSumPvd.submit();
   	//alert("Submit");
   	frmSumPvd.target="";
   }
   

</script>

<link rel="stylesheet" href="jquery3/select2.min.css">
<script src="jquery3/select2.min.js"></script>
<style type="text/css">
.select2-selection__rendered {
  	font-family: Tohama, Arial, sans-serif;
    font-size: 10.1pt;
    color: #165396 !important;
}
.select2-results__option {
	font-family: Tohama, Arial, sans-serif;
    font-size: 10.1pt;
    color: #165396;
}    
</style>
<script>
 $(document).ready(function() {
    $('#sel_project').select2({
         matcher: function(params, data) {
            if ($.trim(params.term) === '') {
                return data;
            }
            var searchTerm = params.term.trim().toLowerCase().replace(/:/g, '');
            var optionText = (data.text || '').toLowerCase().replace(/:/g, '');

            if (optionText.indexOf(searchTerm) > -1) {
                return data;
            }
            return null; 
        }
    });

});
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0"><FORM NAME="frmSumPvd" METHOD=POST ACTION="/LHServ/SERV_HSumPvd.jsp"><table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr onclick="return func_1(this, event);">
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            รายงาน</td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">              <tr>                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>                <td class="item_tab2" width="250">สรุปใบเบิกงวดสำหรับผู้รับเหมาบ้าน</td>                <td class="item_tab3"></td>                <td>&nbsp;</td>               
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
  <tr>    <td class="item ; dotline01" height="22" width="15%">โครงการ :</td>    <td height="22" width="35%" class="dotline01"><%=com.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:300px' onChange='queryProject();' ",false)%></td>    <td height="22" class="item ; dotline01" width="15%" >&nbsp;</td>    <td height="22" width="35%" class="dotline01">&nbsp;&nbsp;&nbsp;&nbsp;</td>  </tr>  <tr>
    <td class="item ; dotline01" height="22" width="15%">ผู้รับเหมาซ่อม :</td>
    <td height="22" width="35%" class="dotline01">
     <%=genVendorList2(conn,"vendor",selProj,vendor," class='box' style='width:300px' ")%>
   </td>
    <%//=com.genVendorList("vendor",selProj,vendor," class='box' style='width:250px' ")%>
    <td height="22" class="item ; dotline01" width="15%" >&nbsp;</td>
    <td height="22" width="35%" class="dotline01">&nbsp;&nbsp;&nbsp;&nbsp;</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="15%">ประจำเดือน :</td>
    <td height="22" width="35%" class="dotline01">
	<select name='payMonth' id="payMonth1" class='box' style="width:100px">
<%
	for( int i=0;  i < 12;  i++ ){
		optionSelected = "";
		if( i<9 )
			code = "0" + Integer.toString(i+1);
		else
			code = Integer.toString(i+1);
		if (code.equals(payMonth)) {
			optionSelected = "selected";
		}
%> 
                      <OPTION value="<%=code%>" <%=optionSelected%>><%=DateUtil.TH_month[i]%></OPTION>
<%
	}// end of month
%> 
	</select> 
	<select name='payYear' id="payYear1" class='box' style="width:100px">
<%
	int curYear = Integer.parseInt(payYear);
	int Byear = curYear - 5;
	int Eyear = curYear + 5;
	for( int i = Byear;  i <= Eyear;  i++ ){
  		    optionSelected = "";
			if (i == curYear) {
				optionSelected = "selected";
			}
%>
			<OPTION value="<%=i%>" <%=optionSelected%>><%=i+543%></OPTION>
<%
	}
	curYear = curYear+543;
%> 							
	</select>    
    </td>
    <td height="22" class="item ; dotline01" width="15%" >&nbsp;</td>
    <td height="22" width="35%" class="dotline01">&nbsp;&nbsp;&nbsp;&nbsp;</td>
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
            <td width="150" class="act_tab2">

            <img border="0" src="images/act_print.gif" onclick="report();"                                  
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27">            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>  
        </table>  






          </td>
        </tr>
      </table>

			
			

<br style="font-size:30pt"><TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
  <tr><td width="100%" class="copyright" align="center">
  Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5  
  <br>ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;
  หรือ โทร. 0-2230-8279 (คุณประพัฒน์
  ฝ่ายบริการ)&nbsp; 0-2230-8491-5 (ฝ่าย IT)  
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr></TABLE> </FORM>	</BODY>
<script>
$(document).ready(function() {
      $('#vendor').select2();  
      $('#payMonth1').select2(); 
      $('#payYear1').select2(); 
    
    	    
    /*$('#i_vendor').on('select2:select', function (e) {
        alert("คุณได้เลือก: " + e.params.data.text);
    });*/
});
</script></HTML>
<%	} catch (Exception e) {		System.out.println("ERROR SERV_HSumPvd.jsp : " + e.getMessage());		throw new ServletException(e.getMessage());	} finally {		// Clean up.		try {			if (rs != null) rs.close();			if (stmt != null) stmt.close();			if (conn != null) conn.close();		}		catch( SQLException ignore ){}	}%>