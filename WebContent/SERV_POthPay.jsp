<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%><%@ page import="java.util.*" %><%@ page import="java.sql.*" %><%@ page import="javax.naming.*" %><%@ page import="com.lh.util.doString" %><%@ page import="com.lh.util.DateUtil" %><%@ page import="serv.common.*" %>
<%@ include file="function.jsp" %>
<%@ include file="confirmLogin.jsp" %><%   	 //----============ Declare Variables for search data ===========----//	String comId = doString.checkString(request.getParameter("comId"));
	String projId = doString.checkString(request.getParameter("projId"));
   	String vendor = doString.checkString(request.getParameter("venId"));  
	doString str = new doString();
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
   	String mnthDate = payYear+"-"+payMonth+"-01";	String payDate = "";
   	double wageAmnt = 0;
   	double cntrlAmnt = 0;
    //----============ Declare Variables for data ===========----//	Connection conn = null;	Statement stmt = null;	ResultSet rs = null;	SERV_CommonData com = null;	try {        //----============ Initialize Variable ============----//		if (ds == null) getDS();		conn = ds.getConnection();		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);		conn.setAutoCommit(true);		stmt = conn.createStatement();   		com = new SERV_CommonData(conn);  
		rs = stmt.executeQuery("SELECT z_wage, z_control FROM lan:serv_pothpayment WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_vendor = '"+vendor+"' AND i_month = '"+mnthDate+"'");
		if (rs != null) {
			if (rs.next() == true) {
				wageAmnt = rs.getDouble("Z_WAGE");
				cntrlAmnt = rs.getDouble("Z_CONTROL");
			}
			rs.close();
			rs=null;
		}		rs = stmt.executeQuery("SELECT d_contructor, d_payment FROM lan:serv_payschd WHERE d_contructor <= '"+mnthDate+"' ORDER BY d_contructor DESC");		if (rs != null) {			if (rs.next() == true) {				payDate = doString.checkString(rs.getString("D_PAYMENT"));			}			rs.close();			rs=null;		}		if (wageAmnt != 0) {			rs = stmt.executeQuery("SELECT SUM(p.q_wage_unit * p.z_wage_price) + SUM(p.q_wage_unit*p.z_wage_price*p.p_add_pay)/100 AS SUM_WAGE_ADD_PAY FROM lan:serv_dochd d, lan:serv_payment p WHERE d.i_company = '"+comId+"' AND d.i_project = '"+projId+"' AND d.f_status != 'CAN' AND d.i_docno = p.i_docno AND p.i_vendor = '"+vendor+"' AND p.f_itmstatus = 'CLS' AND p.d_payment = '"+payDate+"'");			if (rs != null) {				if (rs.next() == true) {					wageAmnt = rs.getDouble(1);				}// end if				rs.close();				rs=null;			}		}%><HTML><HEAD><TITLE>ข้อมูลพื้นฐาน : 05สรุปรายการเบิกงวด</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
	function isCurrencyKey(oEvent, uns){

    	var charCode;

    	if (window.event) charCode = window.event.keyCode;

    	else if (oEvent) charCode = oEvent.which;

    	var reNum = /(\d|\.|,|-)/;

    	if(uns) reNum = /(\d|\.|,)/;

    	if(!reNum.test(String.fromCharCode(charCode)))

       		return false;

    	

    	return true;

	}

   function saveData() {
       frmOthPay.submit();
   }

</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0"><FORM NAME="frmOthPay" METHOD=POST ACTION="/LHServ/SERV_POthPayServlet"><input type="hidden" name="mode" value="S">
<input type="hidden" name="sel_project" value="<%=comId%>:<%=projId%>">
<input type="hidden" name="vendor" value="<%=vendor%>"><table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr onclick="return func_1(this, event);">
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            รายการเบิกงานบ้าน อื่นๆ</td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">              <tr>                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>                <td class="item_tab2" width="250">รายการเบิก</td>                <td class="item_tab3"></td>                <td>&nbsp;</td>               
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
  <tr>    <td class="item ; dotline01" height="22" width="15%">โครงการ :</td>    <td height="22" width="35%" class="dotline01">
<%
	rs = stmt.executeQuery("SELECT n_project FROM lan:acxprojt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
	if (rs != null) {
		if (rs.next() == true) {
			out.print(doString.DisplayThai(rs.getString("N_PROJECT")));
		}
		rs.close();
		rs=null;
	}
%>    
    </td>    <td height="22" class="item ; dotline01" width="15%" >&nbsp;</td>    <td height="22" width="35%" class="dotline01">&nbsp;&nbsp;&nbsp;&nbsp;</td>  </tr>  <tr>
    <td class="item ; dotline01" height="22" width="15%">ผู้รับเหมา :</td>
    <td height="22" width="35%" class="dotline01">
<%
	rs = stmt.executeQuery("SELECT ven_name FROM lan:vendor WHERE ven_no = '"+vendor+"'");
	if (rs != null) {
		if (rs.next() == true) {
			out.print(doString.DisplayThai(rs.getString("VEN_NAME")));
		}
		rs.close();
		rs=null;
	}
%>    
    </td>
    <td height="22" class="item ; dotline01" width="15%" >&nbsp;</td>
    <td height="22" width="35%" class="dotline01">&nbsp;&nbsp;&nbsp;&nbsp;</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="15%">ประจำเดือน :</td>
    <td height="22" width="35%" class="dotline01">
	<select name='payMonth' class='box' style="width:100px">
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
	<select name='payYear' class='box' style="width:55px">
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
  <tr>
    <td class="item ; dotline01" height="22" width="15%">ค่าแรงงาน :</td>
    <td height="22" width="35%" class="dotline01"><input type="text" maxlength="12" class="boxR" style="width:100px" name="wage_amnt" value="<%=doString.displayNumber("#########.00", wageAmnt)%>" onKeyPress="return isCurrencyKey(event)"/>&nbsp;บาท
    </td>
    <td height="22" class="item ; dotline01" width="15%" >&nbsp;</td>
    <td height="22" width="35%" class="dotline01">&nbsp;&nbsp;&nbsp;&nbsp;</td>
  </tr>  
  <tr>
    <td class="item ; dotline01" height="22" width="15%">ค่าควบคุมโครงการ :</td>
    <td height="22" width="35%" class="dotline01"><input type="text" maxlength="12" class="boxR" style="width:100px" name="cntrl_amnt" value="<%=doString.displayNumber("#########.00", cntrlAmnt)%>" onKeyPress="return isCurrencyKey(event)"/>&nbsp;บาท
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

            <a href="javascript:saveData()"><img border="0" src="images/act_save.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="SERV_POthPayLst.jsp?sel_project=<%=comId%>:<%=projId%>&vendor=<%=vendor%>"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
<%	} catch (Exception e) {		System.out.println("ERROR SERV_POthPay.jsp : " + e.getMessage());		throw new ServletException(e.getMessage());	} finally {		// Clean up.		try {			if (rs != null) rs.close();			if (stmt != null) stmt.close();			if (conn != null) conn.close();		}		catch( SQLException ignore ){}	}%>