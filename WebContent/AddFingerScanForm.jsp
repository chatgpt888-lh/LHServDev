<%@ page contentType="text/html; charset=TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="serv.common.Constants" %>
<%@page import="serv.common.User" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%
/**
 * Servlet implementation class for Servlet: Add finger scan form
 * create by : P.Doem and P.Pay
 * date :2017.10.13
 * by น้องฝึกงาน  : รัน
 * 
 */
 
String mode = request.getParameter("mode")==null?"":request.getParameter("mode").toString();
String tempIdCard = request.getParameter("IdCardNo")==null?"":request.getParameter("IdCardNo").toString();

/*String ParameterNames = "";
for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
	ParameterNames = (String)e.nextElement();
	System.out.println(ParameterNames + " = "+request.getParameter(ParameterNames));
}
System.out.println("*******************************************");*/

%>
  		
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
<TITLE>ข้อมูลพื้นฐาน : 05
 ข้อมูลที่ใช้สแกนนิ้ว</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">

function saveData(){ 

	  var CardId = document.getElementById("IdCardNo").value;
	  var ProjectCode = document.getElementById("projcode").value;
	  var Wage = document.getElementById("wage").value;
	  
	  if(CardId=="" ||  ProjectCode=="" || Wage==""){
		  alert("คำเตือน:กรุณาใส่ข้อมูลในช่องที่่มีเครื่องหมาย * ให้ครบถ้วน");
		  document.getElementById("IdCardNo").focus();
		  document.getElementById("projcode").focus();
		  document.getElementById("wage").focus();
	  }else{
		  document.forms[0].action="<%=request.getContextPath()%>/AddFingerScanServlet";
		  document.forms[0].submit();
	  }
}
function deleteData(id,projId){
	
	 var CardId = document.getElementById("IdCardNo").value = id;
	  var ProjectCode = document.getElementById("projcode").value = projId;
	if(confirm("คุณต้องการลบข้อมูล รหัสบัตรประชาชน "+CardId+" รหัสโครงการ "+ProjectCode+" ใช่หรือไม่?")){
      /*var CardId = document.getElementById("IdCardNo").value = id;
	  var ProjectCode = document.getElementById("projcode").value = projId;*/
	  document.getElementById("mode").value = "del";

	   //alert("Delete data ==> ID:"+CardId+" Project code:"+ProjectCode);
	   document.forms[0].action="<%=request.getContextPath()%>/AddFingerScanServlet";
	   document.forms[0].submit();
	}   
}


function SearchIdNo(){ 
	  var cardId = document.getElementById("IdCardNo").value;
	  //TODO:
		if(cardId==""){
			alert("คำเตือน:กรุณากรอกเลขบัตรประชาชน");
			document.getElementById("IdCardNo").focus();
		}else{
		 	document.forms[0].action="<%=request.getContextPath()%>/AddFingerScanForm.jsp?mode=2";
		    document.forms[0].submit();
		}
	}


</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM action="" method="post">
<input type="hidden" name="mode" value="">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr onclick="return func_1(this, event);">
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ข้อมูลที่ใช้สแกนนิ้ว</td>
        </tr>
      </table>


<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">เพิ่มรายชื่อที่ใช้สแกนนิ้ว</td>
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
  
    <td class="item ; dotline01" height="22" width="15%">รหัสบัตรประชาชน |Passport
      :</td>
    <td height="22" width="35%" class="dotline01">
    <input type="text" name="IdCardNo" id="IdCardNo" value="<%=tempIdCard %>" style="width:200px" maxlength="13"> *13หลัก
    &nbsp;
    
    <!-- Search Button -->
    <button onclick="SearchIdNo()">Search</button>
    
    
    </td>
    <td height="22" class="item ; dotline01" width="15%" >&nbsp;</td>
    <td height="22" width="35%" class="dotline01">  <!-- เส้นคั่น -->
    &nbsp;&nbsp;&nbsp;&nbsp;</td>
  </tr>
  
  <tr>
    <td class="item ; dotline01" height="22" width="15%">ชื่อ-สกุล
      :</td>
    <td height="22" width="35%" class="dotline01">
     <input type="text" name="NameSurname" style="width:200px">

    </td>
    
    <td height="22" class="item ; dotline01" width="15%" >&nbsp;</td>
    <td height="22" width="35%" class="dotline01">
    &nbsp;&nbsp;&nbsp;&nbsp;</td>
  </tr>
  
    <tr>
    <td class="item ; dotline01" height="22" width="15%">รหัสโครงการ
      :</td>
    <td height="22" width="35%" class="dotline01">
     <input type="text" name="ProjectCode" id="projcode" style="width:200px" maxlength="5"> *LH011
     <!-- <input type="hidden" name="ReplaceProjCode" id="replaceprojcode">-->

    </td>
    
    <td height="22" class="item ; dotline01" width="15%" >&nbsp;</td>
    <td height="22" width="35%" class="dotline01">
    &nbsp;&nbsp;&nbsp;&nbsp;</td>
  </tr>
  
  
  <tr>
    <td class="item ; dotline01" height="22" width="15%">ตำแหน่ง
      :</td>
    <td height="22" width="35%" class="dotline01">
     <input type="text" name="Position" style="width:200px">

    </td>
    
    <td height="22" class="item ; dotline01" width="15%" >&nbsp;</td>
    <td height="22" width="35%" class="dotline01">
    &nbsp;&nbsp;&nbsp;&nbsp;</td>
  </tr>
  
  <tr>
    <td class="item ; dotline01" id="wage" height="22" width="15%">ค่าแรง
      :</td>
    <td height="22" width="35%" class="dotline01">
     <input type="text" name="Wage" style="width:200px"> *บาท/วัน
     
    </td>
    
    <td height="22" class="item ; dotline01" width="15%" >&nbsp;</td>
    <td height="22" width="35%" class="dotline01">
    &nbsp;&nbsp;&nbsp;&nbsp;</td>
  </tr>
 
  <tr>
    <td class="item ; dotline01" height="22" width="15%">สังกัด
      :</td>
    <td height="22" width="35%" class="dotline01">
     <input type="text" name="Affiliation" style="width:200px"  disabled="true">
     
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

<br style="font-size:10pt">

<!-- --------------------------------------------------------------------------------------------------------------------------- -->

<%
StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;

try {

   if(mode.equals("2") && !tempIdCard.equals("")){

	    //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();        
	    //----=======================================----// 
	    		
	    			//System.out.println("Database connected");

					//System.out.println("Begin sql query");
	   				sql.delete(0,sql.length());
			        //sql.append(" select * from lan:serv_tstaff where i_cardno="+tempIdCard);
			        sql.append(" select * from lan:serv_tstaff where i_cardno like '%"+tempIdCard+"%'");
			        rs = stmt.executeQuery(sql.toString());
			        //System.out.println("SQL executed command :"+sql.toString());

%>
          <!-- Head of table -->
          <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">รายละเอียดรายชื่อสแกนนิ้ว</td>
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
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0"> <!-- Create header of table -->
        <tr>
          <td class="col_name" width="10%">รหัสบัตรประชาชน.</td>
          <td class="col_name" width="10%">ชื่อ-สกุล</td>
          <td class="col_name" width="10%">รหัสโครงการ</td>
          <td class="col_name" width="10%">ตำแหน่ง</td>
          <td class="col_name" width="10%">ค่าแรง</td>
          <td class="col_name" width="10%">สังกัด</td>
          <td class="col_name" width="5%">Delete</td>
        </tr>
     
		<%
		 String CardNum = "";
		 String Name ="";
		 String Header="";
		 String Job="";
	     String Wage="";
	     String Dept="";
		
		while(rs.next()){ //After fetch the input information
			
             CardNum = doString.checkString(rs.getString("i_cardno"),"");
             Name = doString.DisplayThai(rs.getString("i_name"));    
             Header = doString.checkString(rs.getString("i_header"),"");
             Job = doString.DisplayThai(rs.getString("n_job"));
             Wage = doString.checkString(rs.getString("z_wage"),"");
             Dept = doString.checkString(rs.getString("i_dept"),"");
             
		%>
		
		<!-- Put searched information into table -->
		<tr>
		          <td align="left" class="dotline" width="20%" ><%=CardNum%>&nbsp;</td>
		          <td align="left" class="dotline" width="20%"><%=Name%></td>
		          <td align="left" class="dotline" width="20%"><%=Header%></td>
		          <td align="left" class="dotline" width="20%"><%=Job%></td>
		          <td align="right" class="dotline" width="10%"><%=Wage%></td>
		          <td align="left" class="dotline" width="10%">&nbsp;<%=Dept%></td>
		          <td align="left" class="dotline">&nbsp;
		          <!-- Link to delete the selected record -->
   				    <a href="JavaScript:deleteData('<%=CardNum.toString()%>','<%=Header.toString()%>')"><img border="0" src="images/i_delete.gif"></a>
    			  </td>
		 </tr>	       		
		<%}//#while
		rs.close();
		%>
     </table>
    </td>
  </tr>
</table>


<!-- Footer of table -->
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>

<%}//#mode (if mode=2) %>

<!-- --------------------------------------------------------------------------------------------------------------------------- -->
<br style="font-size:10pt">

        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="150" class="act_tab2">
            
            
             <!--Add Image button --> 
            <a href="JavaScript:saveData();"  ><img border="0" src="images/act_add.gif"                                  
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp; 
            	
            </td>   
                  	
            <!-- Back & Home image button -->
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="/LHServ/SERV_Index.jsp" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="/LHServ/SERV_Index.jsp" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
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
		System.out.println("ERROR AddFingerScanForm.jsp : " + e.getMessage());
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
