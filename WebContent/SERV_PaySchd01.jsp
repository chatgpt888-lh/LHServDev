<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.Constants" %>
<%@ page import="serv.util.ServLog" %>

<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<% 
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_PaySchd01.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

	String dPayment = "";
	String dConstrutor="";
	String dSerStaff="";
	String dServiceMan="";
	String dServiceZone="";
	String dVP="";  
	String dChange = "";
	 
   	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	
	try {
			if (ds == null) getDS();
			 conn = ds.getConnection();
			 conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			 conn.setAutoCommit(true);
			 stmt = conn.createStatement();        
				
        //----=======================================----//	
	 %>
<HTML>
<HEAD>
<TITLE>ข้อมูลพื้นฐาน : 03
ตารางการจ่ายเงินผู้รับเหมา</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">

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
    	document.forms[0].action = "<%=Constants.APP_PATH%>/SERV_PaySchdServlet?mode=delete"; 
    	document.forms[0].submit();
    } 
}
function saveData() {
 // alert("save data");
  document.forms[0].action="<%=Constants.APP_PATH%>/SERV_PaySchdServlet?mode=add";
  document.forms[0].submit();
  
}


</script>
<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM action=""  method="post">

<INPUT type="hidden" name="datePayment" value="<%=dPayment%>">

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
                <td class="item_tab2" width="250">ตารางการจ่ายเงินผู้รับเหมา</td>
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
          <td class="col_name" width="5%"><input type="checkbox" name="main_check" onclick="checkAll(this,'main_check','del_checkbox');"></td>
          <td class="col_name" width="13%">วันที่จ่ายเงิน</td>
          <td class="col_name" width="13%">วันสุดท้ายที่ผู้รับเหมาต้องส่งงาน</td>
          <td class="col_name" width="13%">วันสุดท้ายที่ Service Staff ต้อง Approve</td>
          <td class="col_name" width="13%">วันสุดท้ายที่ Service Manager ต้อง Approve</td>
          <td class="col_name" width="13%">วันสุดท้ายที่ Service Zone ต้อง Approve</td>
          <td class="col_name" width="13%">วันสุดท้ายที่ VP ต้อง Approve</td>
          <td class="col_name" width="13%">วันที่ทำการเปลี่ยนข้อมูล</td>
        </tr>
      
       <%
         	sql.delete(0,sql.length());
 			sql.append(" select  *  from  lan:serv_payschd order by d_payment ");
			servlog.startLog(sql.toString());
	        rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
		 
		 	int line=0;	
			while (rs.next()){
			 
		     String date = doString.checkString(doString.DisplayThai(rs.getString("d_payment")));
		
				Timestamp tmp,tmp1,tmp2,tmp3,tmp4,tmp5,tmp6;
   				 tmp  = rs.getTimestamp("d_payment");   					
   				 tmp1 = rs.getTimestamp("d_contructor");
   				 tmp2 = rs.getTimestamp("d_service_staff");
   				 tmp3 = rs.getTimestamp("d_service_man");   				   				
   				 tmp4 = rs.getTimestamp("d_service_zone");
   				 tmp5 = rs.getTimestamp("d_vp");
   				 tmp6 = rs.getTimestamp("d_change");
   				
   				Calendar dTmp = Calendar.getInstance();
   				if(tmp!=null){dTmp.setTime(tmp); dPayment = getDateFromCalendar(dTmp);}else {dPayment = "-"; }
   				if(tmp1!=null){dTmp.setTime(tmp1); dConstrutor = getDateFromCalendar(dTmp);}else {dConstrutor = "-"; }
   				if(tmp2!=null){dTmp.setTime(tmp2); dSerStaff = getDateFromCalendar(dTmp);}else {dSerStaff = "-"; }
   				if(tmp3!=null){dTmp.setTime(tmp3); dServiceMan = getDateFromCalendar(dTmp);}else {dServiceMan = "-"; }
   				if(tmp4!=null){dTmp.setTime(tmp4); dServiceZone = getDateFromCalendar(dTmp);}else {dServiceZone = "-"; }   				
   				if(tmp5!=null){dTmp.setTime(tmp5); dVP = getDateFromCalendar(dTmp);}else {dVP = "-"; }   											
   				if(tmp6!=null){dTmp.setTime(tmp6); dChange = getDateFromCalendar(dTmp);}else {dChange = "-"; }   											

		%>
        <tr>
          <td align="center" class="dotline" width="5%"><input type="checkbox" name="del_checkbox"  value="<%=date%>" onclick="checkAll(this,'main_check','del_checkbox');"></td>
          <td class="dotline" align="center" width="13%"><a href="SERV_PaySchd02.jsp?mode=edit&d_payment=<%=date%>"><%=dPayment%></a></td>
          <td class="dotline" align="center" width="13%"><%=dConstrutor%></td>
          <td align="center" class="dotline" width="13%"><%=dSerStaff%></td>
          <td align="center" class="dotline" width="13%"><%=dServiceMan%></td>
          <td align="center" class="dotline" width="13%"><%=dServiceZone%></td>
          <td align="center" class="dotline" width="13%"><%=dVP%></td>
          <td align="center" class="dotline" width="13%"><%=dChange%></td>

        </tr>
       <%
		    line++;
		}
		rs.close();				
		
		//----========= Fill up blank line if this page display data less than 12 line ========--//
		while (line<Constants.SERV_XSTD_LINE) {
	 %>
		
        <tr>
          <td align="center" class="dotline" width="5%">&nbsp;</td>
          <td class="dotline" align="center" width="13%">&nbsp;</td>
          <td class="dotline" align="center" width="13%">&nbsp;</td>
          <td align="center" class="dotline" width="13%">&nbsp;</td>
          <td align="center" class="dotline" width="13%">&nbsp;</td>
          <td align="center" class="dotline" width="13%">&nbsp;</td>
          <td align="center" class="dotline" width="13%">&nbsp;</td>
          <td align="center" class="dotline" width="13%">&nbsp;</td>
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
            <a href="SERV_PaySchd02.jsp"><img border="0" src="images/act_add.gif"                                   
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
		System.out.println("ERROR SERV_PaySchd01.jsp : " + e.getMessage());
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