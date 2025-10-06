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
   	String iType = doString.checkString(request.getParameter("i_type"),"0");  
	String effctDate = "";   	  
   	String desc = "";
    //----============ Declare Variables for data ===========----//	Connection conn = null;	Statement stmt = null;	ResultSet rs = null;	SERV_CommonData com = null;	try {        //----============ Initialize Variable ============----//		if (ds == null) getDS();		conn = ds.getConnection();		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);		conn.setAutoCommit(true);		stmt = conn.createStatement();   		com = new SERV_CommonData(conn);  
		effctDate = com.getValueFromDateListbox("effct",request);   	 
		if (effctDate.length()<=0)  {
			Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);			
			int syear = rightNow.get(Calendar.YEAR);
			if (syear>2400) syear -= 543;
			rightNow.set(syear,rightNow.get(Calendar.MONTH),rightNow.get(Calendar.DATE));
			effctDate = rightNow.get(Calendar.YEAR)+"-"+str.createID(rightNow.get(Calendar.MONTH)+1,2)+"-"+str.createID(rightNow.get(Calendar.DATE),2);
		}		 %><HTML><HEAD><TITLE>ข้อมูลพื้นฐาน : 05ข้อมูลประเภทการจัดสรร</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">

function deleteData() {
    document.forms[0].mode.value = "D";
 	document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFAllotServlet";
    document.forms[0].submit();
}

function chckAll(){
	var i = 0;
	var num_allot = eval(document.forms[0].num_allot.value);
	if ( num_allot == 1)
	{
		document.forms[0].delAllot.checked = document.forms[0].selAll.checked;
	} else {
		while( i < num_allot)
		{
			document.forms[0].delAllot[i].checked = document.forms[0].selAll.checked;
			i++;
		}
	}
}

    function queryProject() {
   		document.forms[0].i_type.value = "0";
       document.forms[0].action = "SERV_INFAllot.jsp?search=y";
       document.forms[0].submit();
   }

  function saveData(){
    if (document.forms[0].i_type.value=="0") {
       alert(" กรุณาเลือกประเภทจัดสรร ");
       document.forms[0].i_type.focus();
       return false;
    }
    document.forms[0].mode.value = "A";
 	document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFAllotServlet";
    document.forms[0].submit();
}
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0"><FORM action="" method="get"><input type="hidden" name="mode" value=""><table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr onclick="return func_1(this, event);">
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ข้อมูลพื้นฐาน</td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">              <tr>                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>                <td class="item_tab2" width="250">กำหนดประเภทการจัดสรร</td>                <td class="item_tab3"></td>                <td>&nbsp;</td>               
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
  <tr>    <td class="item ; dotline01" height="22" width="15%">โครงการ      :</td>    <td height="22" width="35%" class="dotline01">	   <%=com.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:250px' onChange='queryProject();' ",false)%>
		&nbsp;<img border="0" src="images/bu_go.gif"  align="absmiddle" width="40" height="22" onclick="queryProject();" style='cursor:hand'>	   
    </td>    <td height="22" class="item ; dotline01" width="15%" >&nbsp;</td>    <td height="22" width="35%" class="dotline01">    &nbsp;&nbsp;&nbsp;&nbsp;</td>  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="15%">ประเภทจัดสรร
      :</td>
    <td height="22" width="35%" class="dotline01">
    <select name='i_type' class='box' style='width:250px'>
       <option value="0">------ กรุณาเลือก ------</option>
       <option value="1" <%=iType.equals("1") ? " selected " : ""%>>กทม.ใหม่</option>
       <option value="2" <%=iType.equals("2") ? " selected " : ""%>>ปริมณฑลใหม่</option>
       <option value="3" <%=iType.equals("3") ? " selected " : ""%>>โครงการเดิม</option>       
    </select>    
    </td>
    <td height="22" class="item ; dotline01" width="15%" >&nbsp;</td>
    <td height="22" width="35%" class="dotline01">
    &nbsp;&nbsp;&nbsp;&nbsp;</td>
  </tr>

  <tr>
    <td class="item ; dotline01" height="22" width="15%">วันที่มีผล
      :</td>
    <td height="22" width="35%" class="dotline01">
<%
	int nowYear = Calendar.getInstance(Locale.ENGLISH).get(Calendar.YEAR);
    if (nowYear>2400) nowYear -= 543;
	out.println(com.genDateOfMonthListbox("effct_date",(effctDate.length()==10 ? effctDate.substring(8,10) : "")," class='box' "));
	out.println(com.genMonthListbox("effct_month",(effctDate.length()==10 ? effctDate.substring(5,7) : "")," class='box' "));
	out.println(com.genYearListbox("effct_year",(effctDate.length()==10 ? effctDate.substring(0,4) : "")," class='box' ",nowYear-3,5));
%>	    
    </td>
    <td height="22" class="item ; dotline01" width="15%" >&nbsp;</td>
    <td height="22" width="35%" class="dotline01">
    &nbsp;&nbsp;&nbsp;&nbsp;</td>
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


<br style="font-size:2pt">


      


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
        <tr>          <td class="col_name" width="5%"><input type="checkbox" name="selAll" onClick="javascript:chckAll();"></td>          <td class="col_name" width="15%">ประเภทจัดสรร</td>          <td class="col_name" width="10%">วันที่มีผล</td>
          <td class="col_name" width="70%">&nbsp;</td>
        </tr>           <%
           		int line = 0;		        rs = stmt.executeQuery("SELECT i_type, d_effective FROM lan:serv_allot WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' ORDER BY d_effective");                while (rs.next() == true) {
                line++;               	 iType = doString.checkString(rs.getString("i_type"));  
               	 effctDate = doString.checkString(rs.getString("d_effective"));  
               	 if (iType.equals("1")) {
               	 	desc = "กทม.ใหม่";
               	 } else if (iType.equals("2")) {
               	 	desc = "ปริมณฑลใหม่";
               	 } else if (iType.equals("3")) {
               	 	desc = "โครงการเก่า";
               	 }			%>		     <tr height="25px">			   	<td width="5%" align="center" class="dotline"><input type="checkbox" name="delAllot"  value="<%=iType%>|<%=effctDate%>"></td>			   	<td class="dotline" width="15%" align="center"><%=desc%></td>				<td class="dotline" width="10%" align="center"><%=DateUtil.ifxToThaiDateNoTime(effctDate)%></td>
				<td class="dotline" width="70%">&nbsp;</td>			</tr> 
<%
				}// end while
				rs.close();
				rs=null;
				if (line == 0) {
%>
		     <tr height="25px">
			   	<td width="5%" align="center" class="dotline">&nbsp;</td>
			   	<td class="dotline" width="15%" align="center">&nbsp;</td>
				<td class="dotline" width="10%" align="center">&nbsp;</td>
				<td class="dotline" width="70%">&nbsp;</td>
			</tr> 

<%				
				}
%>			      </table><input type="hidden" name="num_allot" value="<%=line%>">
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

            <a href="#" onclick="saveData();"><img border="0" src="images/act_add.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp; 
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
		System.out.println("ERROR SERV_INFAllot.jsp : " + e.getMessage());
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