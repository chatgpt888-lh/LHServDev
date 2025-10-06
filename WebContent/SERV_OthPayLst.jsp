<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%><%@ page import="java.util.*" %><%@ page import="java.sql.*" %><%@ page import="javax.naming.*" %><%@ page import="com.lh.util.doString" %><%@ page import="com.lh.util.DateUtil" %><%@ page import="serv.common.*" %>
<%@ include file="function.jsp" %>
<%@ include file="confirmLogin.jsp" %><%   	 //----============ Declare Variables for search data ===========----//	String selProj = doString.checkString(request.getParameter("sel_project"),"");
	doString str = new doString();
	String comId = "";
	String projId = "";
	if (!selProj.equals("")) {
		comId = selProj.substring(0,2);
		projId = selProj.substring(3);
	}
   	String vendor = doString.checkString(request.getParameter("vendor"));  
   	String desc = "";
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
   	String mnthDate = "";
   	String payDate = "";
   	String status = "";
    //----============ Declare Variables for data ===========----//	Connection conn = null;	Statement stmt = null;	ResultSet rs = null;	SERV_CommonData com = null;	try {        //----============ Initialize Variable ============----//		if (ds == null) getDS();		conn = ds.getConnection();		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);		conn.setAutoCommit(true);		stmt = conn.createStatement();   		com = new SERV_CommonData(conn);  
%><HTML><HEAD><TITLE>ข้อมูลพื้นฐาน : 05สรุปรายการเบิกงวด</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">

function deleteData() {
    document.forms[0].mode.value = "D";
 	document.forms[0].action="<%=Constants.APP_PATH%>/SERV_OthPayServlet";
    document.forms[0].submit();
}

function chckAll(){
	var i = 0;
	var num_month = eval(document.forms[0].num_month.value);
	if ( num_month == 1)
	{
		document.forms[0].delMnth.checked = document.forms[0].selAll.checked;
	} else {
		while( i < num_month)
		{
			document.forms[0].delMnth[i].checked = document.forms[0].selAll.checked;
			i++;
		}
	}
}
   function queryProject() {
       document.forms[0].action = "SERV_OthPayLst.jsp?search=y";
       document.forms[0].submit();
   }

</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0"><FORM NAME="frmOthPayLst" METHOD=POST ACTION="/LHServ/SERV_OthPayLst.jsp">
<input type="hidden" name="mode" value="D">
<input type="hidden" name="payMonth" value="01">
<input type="hidden" name="payYear" value="2001">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr onclick="return func_1(this, event);">
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;            รายการเบิกงวดสาธารณูฯ และงานสาธารณะ อื่นๆ</td>
        </tr>      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">              <tr>                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>                <td class="item_tab2" width="250">สรุปรายการเบิกงวด</td>                <td class="item_tab3"></td>                <td>&nbsp;</td>               
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
  <tr>    <td class="item ; dotline01" height="22" width="15%">โครงการ :</td>    <td height="22" width="35%" class="dotline01"><%=com.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:250px' onChange='queryProject();' ",false)%></td>    <td height="22" class="item ; dotline01" width="15%" >&nbsp;</td>    <td height="22" width="35%" class="dotline01">&nbsp;&nbsp;&nbsp;&nbsp;</td>  </tr>  <tr>
    <td class="item ; dotline01" height="22" width="15%">ผู้รับเหมา :</td>
    <td height="22" width="35%" class="dotline01"><%=com.genVendorOpenJobDropDown("vendor",vendor,comId,projId," class='box' style='width:250px' onChange='queryProject();' " )%>
	&nbsp;&nbsp;&nbsp;<a href="javascript:frmOthPayLst.submit();"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a>    
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
        <tr>          <td class="col_name" width="5%"><input type="checkbox" name="selAll" onClick="javascript:chckAll();"></td>          <td class="col_name" width="15%">ประจำเดือน</td>          <td class="col_name" width="10%">ค่าแรงงาน</td>
          <td class="col_name" width="10%">ค่าควบคุมโครงการ</td>
          <td class="col_name" width="30%">วันที่จ่าย</td>
          <td class="col_name" width="30%">สถานะ</td>
        </tr>           <%
           		int line = 0;		        rs = stmt.executeQuery("SELECT i_month, z_wage, z_control, d_payment, f_tran FROM lan:serv_othpayment WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_vendor = '"+vendor+"' ORDER BY i_month");                while (rs.next() == true) {
                	mnthDate = doString.checkString(rs.getString("I_MONTH"));
                	status = doString.checkString(rs.getString("F_TRAN"));
					payDate = DateUtil.ifxToThaiDateNoTime(rs.getString("D_PAYMENT"));
                	if (!mnthDate.equals("")) {
                		payMonth = mnthDate.substring(5,7);
                		payYear = mnthDate.substring(0,4);

                		line++;			%>		     <tr height="25px">
						<td width="5%" align="center" class="dotline">
<%if (!status.equals("T")) {%>
						<input type="checkbox" name="delMnth"  value="<%=mnthDate%>">
<%} else {out.print("&nbsp;");}%>
						</td>
						<td class="dotline" width="15%" align="center">
<%if (!status.equals("T")) {%>
						<a href="SERV_OthPay.jsp?comId=<%=comId%>&projId=<%=projId%>&venId=<%=vendor%>&payMonth=<%=payMonth%>&payYear=<%=payYear%>"><%=DateUtil.ifxToThaiDateNoTime(rs.getString("I_MONTH"))%></a>

<%} else {%>
						<%=DateUtil.ifxToThaiDateNoTime(rs.getString("I_MONTH"))%>
<%}%>
						</td>
						<td class="dotline" width="10%" align="right"><%=doString.displayNumber("###,###,###.00", rs.getDouble("Z_WAGE"))%></td>
				<td class="dotline" width="10%" align="right"><%=doString.displayNumber("###,###,###.00", rs.getDouble("Z_CONTROL"))%></td>
				<td class="dotline" width="30%" align="center"><%=payDate%>&nbsp;</td>			
				<td class="dotline" width="30%" align="center"><%=status%>&nbsp;</td>			
				</tr> 
<%
					}
				}// end while
				rs.close();
				rs=null;
				if (line == 0) {
%>
		     <tr height="25px">
			   	<td width="5%" align="center" class="dotline">&nbsp;</td>
			   	<td class="dotline" width="15%" align="center">&nbsp;</td>
				<td class="dotline" width="10%" align="center">&nbsp;</td>
				<td class="dotline" width="10%">&nbsp;</td>
				<td class="dotline" width="30%">&nbsp;</td>
				<td class="dotline" width="30%">&nbsp;</td>
			</tr> 
<%				
				}
%>			      </table><input type="hidden" name="num_month" value="<%=line%>">
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
<%if (!projId.equals("") && !vendor.equals("")){%>
            <a href="SERV_OthPay.jsp?comId=<%=comId%>&projId=<%=projId%>&venId=<%=vendor%>"><img border="0" src="images/act_add.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp; 
<%}%>
             <a href="#" onclick="deleteData();"><img border="0" src="images/act_delete.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>

            </td>   
                  	
                  	
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
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr></TABLE> </FORM>	</BODY></HTML>
<%	} catch (Exception e) {		System.out.println("ERROR SERV_OthPayLst.jsp : " + e.getMessage());		throw new ServletException(e.getMessage());	} finally {		// Clean up.		try {			if (rs != null) rs.close();			if (stmt != null) stmt.close();			if (conn != null) conn.close();		}		catch( SQLException ignore ){}	}%>