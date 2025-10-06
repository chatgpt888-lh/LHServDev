<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>

<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%!

public String[] splitDate(String date) {
  String[] result = new String[] {"","",""};
  StringTokenizer tmp = new StringTokenizer(date,"-");
  if (tmp.countTokens()==3) {
     result[2] = doString.checkString(tmp.nextToken(),"0");
     result[1] = tmp.nextToken();
     result[0] = tmp.nextToken();
     
     int year = Integer.parseInt(result[2]);
     if (year<2400) year += 543;
     result[2] = Integer.toString(year);    
     
  }
  
  return result;
}

%>

<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_PaySchd02.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);
	
	String dPayDD = doString.checkString(request.getParameter("d_pay_dd"),"");
	String dPayMM = doString.checkString(request.getParameter("d_pay_mm"),"");
	String dPayYY = doString.checkString(request.getParameter("d_pay_yy"),"");	
	
	String dConDD = doString.checkString(request.getParameter("d_con_dd"),"");
	String dConMM = doString.checkString(request.getParameter("d_con_mm"),"");
	String dConYY = doString.checkString(request.getParameter("d_con_yy"),"");
	
	String dStaffDD = doString.checkString(request.getParameter("d_staff_dd"),"");
	String dStaffMM = doString.checkString(request.getParameter("d_staff_mm"),"");
	String dStaffYY = doString.checkString(request.getParameter("d_staff_yy"),"");
	
	String dManDD = doString.checkString(request.getParameter("d_man_dd"),"");
	String dManMM = doString.checkString(request.getParameter("d_man_mm"),"");
	String dManYY = doString.checkString(request.getParameter("d_man_yy"),"");
	
	String dZoneDD = doString.checkString(request.getParameter("d_zone_dd"),"");
	String dZoneMM = doString.checkString(request.getParameter("d_zone_mm"),"");
	String dZoneYY = doString.checkString(request.getParameter("d_zone_yy"),"");
	
	String dVPDD = doString.checkString(request.getParameter("d_vp_dd"),"");
	String dVPMM = doString.checkString(request.getParameter("d_vp_mm"),"");
	String dVPYY = doString.checkString(request.getParameter("d_vp_yy"),"");
	
	String dChangeDD = doString.checkString(request.getParameter("d_change_dd"),"");
	String dChangeMM = doString.checkString(request.getParameter("d_change_mm"),"");
	String dChangeYY = doString.checkString(request.getParameter("d_change_yy"),"");

	
	String dPayment= dPayDD+"-"+dPayMM+"-"+dPayYY ;
	String dConStructor = dConDD+"-"+dConMM+"-"+dConYY ;
	String dStaff =  dStaffDD+"-"+dStaffMM+"-"+dStaffYY ;
	String dMan =  dManDD+"-"+dManMM+"-"+dManYY ;
	String dZone=  dZoneDD+"-"+dZoneMM+"-"+dZoneYY ;
	String dVP=  dVPDD+"-"+dVPMM+"-"+dVPYY ;
	String dChange=  dChangeDD+"-"+dChangeMM+"-"+dChangeYY ;

	
	String date = doString.checkString(request.getParameter(""),"");
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	String mode = doString.checkString(request.getParameter("mode"),"add");
	String error = doString.checkString(request.getParameter("error"),"");
	
	
	try {
	    //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement(); 
			//---============= If EDIT Mode , load old data  =============----//\
	    if (mode.equalsIgnoreCase("EDIT") && error.length()<=0) {
            dPayment = doString.checkString(request.getParameter("d_payment"),"");  
			
			if (ds == null) getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
			stmt = conn.createStatement();        
	
		   	sql.delete(0,sql.length());
			sql.append(" select * from lan:serv_payschd where ")
			      .append(" d_payment = '").append(dPayment).append("' ");
				      
			servlog.startLog(sql.toString());
		    rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
		    while (rs.next()) {
		        dPayment = doString.checkString(doString.DisplayThai(rs.getString("d_payment")),""); 
		        dConStructor = doString.checkString(doString.DisplayThai(rs.getString("d_contructor")),""); 
		        dStaff = doString.checkString(doString.DisplayThai(rs.getString("d_service_staff")),"");  
		        dMan = doString.checkString(doString.DisplayThai(rs.getString("d_service_man")),"");  
				dZone = doString.checkString(doString.DisplayThai(rs.getString("d_service_zone")),"");  	   
		    	dVP = doString.checkString(doString.DisplayThai(rs.getString("d_vp")),"");
		    	dChange = doString.checkString(doString.DisplayThai(rs.getString("d_change")),"");
		    	
		    	String tmp[] = splitDate(dPayment);
		    	dPayDD = tmp[0];
		    	dPayMM = tmp[1];
		    	dPayYY = tmp[2];
		    	
		    	tmp = splitDate(dConStructor);
		    	dConDD = tmp[0];
		    	dConMM = tmp[1];
		    	dConYY = tmp[2];
		    	
		        tmp = splitDate(dStaff);
		    	dStaffDD = tmp[0];
		    	dStaffMM = tmp[1];
		    	dStaffYY = tmp[2];
		    	
		    	tmp = splitDate(dMan);
		    	dManDD = tmp[0];
		    	dManMM = tmp[1];
		    	dManYY = tmp[2];
		    	
		    	tmp = splitDate(dZone);
		    	dZoneDD = tmp[0];
		    	dZoneMM = tmp[1];
		    	dZoneYY = tmp[2];
		    	
		    	tmp = splitDate(dVP);
		    	dVPDD = tmp[0];
		    	dVPMM = tmp[1];
		    	dVPYY = tmp[2];

		    	tmp = splitDate(dChange);
		    	dChangeDD = tmp[0];
		    	dChangeMM = tmp[1];
		    	dChangeYY = tmp[2];
		    }
		    rs.close();		     
		}

		
%>

<HTML>
<HEAD>
<TITLE>ข้อมูลพื้นฐาน : 03
ตารางการจ่ายเงินผู้รับเหมา</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">


function validateDate(d,m,y) {

    if ((parseInt(d.value,10)>=1 && parseInt(d.value,10)<=31) && d.value.length>0) {
       if((parseInt(m.value,10)>=1 && parseInt(m.value,10)<=12) && m.value.length>0) {
          if((parseInt(y.value,10)>=2000) && y.value.length>0) {
              var yy = parseInt(y.value,10);
              if (yy>2400) yy -= 543;
	           var tmpD = new Date(yy,parseInt(m.value,10)-1,d.value);
	           if (tmpD.getMonth()==(parseInt(m.value,10)-1)) {
	              return true; 
	           } else {
	              alert("วันที่ไม่ถูกต้อง กรุณาตรวจสอบวันใหม่อีกครั้ง !\n(กรณีเป็นวันสิ้นเดือน กรุณาตรวจสอบวันสิ้นเดือนว่าถูกต้องหรือไม่)");
	              d.focus();
	              return false;
	           }
          } else {
	           alert("ปีต้องมากกว่า 2000 เท่านั้น !");
	           y.focus();
	           return false;          
          }

       } else {
           alert("เดือนต้องเป็น 1 - 12 เท่านั้น !");
           m.focus();
           return false;
       }
    } else {
       alert("วันที่ต้องเป็น 1 - 31 เท่านั้น !");
       d.focus();
       return false;
    }
    
    return false;
}

function saveData(){
    
    var form = document.forms[0];

     if (!validateDate(form.d_pay_dd,form.d_pay_mm,form.d_pay_yy)) {
        return false;
     }
     
     if (!validateDate(form.d_con_dd,form.d_con_mm,form.d_con_yy)) {
        return false;
     }
     
     if (!validateDate(form.d_staff_dd,form.d_staff_mm,form.d_staff_yy)) {
        return false;
     }
     
     if (!validateDate(form.d_man_dd,form.d_man_mm,form.d_man_yy)) {
        return false;
     }
     
     if (!validateDate(form.d_zone_dd,form.d_zone_mm,form.d_zone_yy)) {
        return false;
     }
     
     if (!validateDate(form.d_vp_dd,form.d_vp_mm,form.d_vp_yy)) {
        return false;
     }

     if (!validateDate(form.d_change_dd,form.d_change_mm,form.d_change_yy)) {
        return false;
     }

	form.action="<%=Constants.APP_PATH%>/SERV_PaySchdServlet";
   	form.submit();  
}


function nextFocus(value,maxLen,nxtObjName) {
    var obj = document.forms[0].elements(nxtObjName);
    if (obj!=null && value.length==maxLen) obj.focus();
}

</script>
<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" >

<FORM action="" method="post">

<INPUT type="hidden" name="mode" value="<%=mode%>">
<INPUT type="hidden" name="datePayment" value="<%=doString.checkString(request.getParameter("d_payment"),"")%>">
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
    <td class="item ; dotline01" height="22" width="30%">วันที่จ่ายเงิน
      :</td>
    <td height="22" width="70%" class="dotline01">
        <input type="text" name="d_pay_dd" maxlength="2" value="<%=dPayDD%>"  class="boxC" style="width:25px" onkeyup="nextFocus(this.value,2,'d_pay_mm');">/ 
        <input type="text" name="d_pay_mm" maxlength="2" value="<%=dPayMM%>" class="boxC" style="width:25px" onkeyup="nextFocus(this.value,2,'d_pay_yy');">/ 
        <input type="text" name="d_pay_yy" maxlength="4" value="<%=dPayYY%>" class="boxC" style="width:40px" onkeyup="nextFocus(this.value,4,'d_con_dd');">
    </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="30%">วันสุดท้ายที่ผู้รับเหมาต้องส่งงาน
      :</td>
    <td height="22" width="70%" class="dotline01">
      <input type="text" name="d_con_dd" maxlength="2" value="<%=dConDD%>" class="boxC" style="width:25px" onkeyup="nextFocus(this.value,2,'d_con_mm');">/ 
      <input type="text" name="d_con_mm" maxlength="2" value="<%=dConMM%>" class="boxC" style="width:25px" onkeyup="nextFocus(this.value,2,'d_con_yy');">/ 
      <input type="text" name="d_con_yy" maxlength="4" value="<%=dConYY%>" class="boxC" style="width:40px" onkeyup="nextFocus(this.value,4,'d_staff_dd');">
    </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="30%">วันสุดท้ายที่
      Service Staff ต้อง Approve :</td>
    <td height="22" width="70%" class="dotline01">
      <input type="text" name="d_staff_dd" maxlength="2" value="<%=dStaffDD%>" class="boxC" style="width:25px" onkeyup="nextFocus(this.value,2,'d_staff_mm');">/ 
      <input type="text" name="d_staff_mm" maxlength="2" value="<%=dStaffMM%>" class="boxC" style="width:25px" onkeyup="nextFocus(this.value,2,'d_staff_yy');">/ 
      <input type="text" name="d_staff_yy" maxlength="4" value="<%=dStaffYY%>" class="boxC" style="width:40px" onkeyup="nextFocus(this.value,4,'d_man_dd');">
    </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="30%">วันสุดท้ายที่
      Service Manager ต้อง Approve :</td>
    <td height="22" width="70%" class="dotline01">
       <input type="text" name="d_man_dd"  maxlength="2"value="<%=dManDD%>" class="boxC" style="width:25px" onkeyup="nextFocus(this.value,2,'d_man_mm');">/ 
       <input type="text" name="d_man_mm"  maxlength="2" value="<%=dManMM%>"class="boxC" style="width:25px" onkeyup="nextFocus(this.value,2,'d_man_yy');">/ 
       <input type="text" name="d_man_yy"  maxlength="4" value="<%=dManYY%>"class="boxC" style="width:40px" onkeyup="nextFocus(this.value,4,'d_zone_dd');">
    </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="30%">วันสุดท้ายที่
      Service Zone ต้อง Approve</td>
    <td height="22" width="70%" class="dotline01">
       <input type="text" name="d_zone_dd" maxlength="2" value="<%=dZoneDD%>" class="boxC" style="width:25px" onkeyup="nextFocus(this.value,2,'d_zone_mm');">/ 
       <input type="text" name="d_zone_mm" maxlength="2" value="<%=dZoneMM%>" class="boxC" style="width:25px" onkeyup="nextFocus(this.value,2,'d_zone_yy');">/ 
       <input type="text" name="d_zone_yy" maxlength="4" value="<%=dZoneYY%>"class="boxC" style="width:40px" onkeyup="nextFocus(this.value,4,'d_vp_dd');">
    </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="30%">วันสุดท้ายที่
      VP ต้อง Approve</td>
    <td height="22" width="70%" class="dotline01">
       <input type="text" name="d_vp_dd" maxlength="2" value="<%=dVPDD%>" class="boxC" style="width:25px" onkeyup="nextFocus(this.value,2,'d_vp_mm');">/ 
       <input type="text" name="d_vp_mm" maxlength="2" value="<%=dVPMM%>" class="boxC" style="width:25px" onkeyup="nextFocus(this.value,2,'d_vp_yy');">/ 
       <input type="text" name="d_vp_yy" maxlength="4" value="<%=dVPYY%>"class="boxC" style="width:40px" onkeyup="nextFocus(this.value,4,'d_change_dd');">
    </td>
  </tr>
    <tr>
    <td class="item ; dotline01" height="22" width="30%">วันที่เปลี่ยนข้อมูล</td>
    <td height="22" width="70%" class="dotline01">
       <input type="text" name="d_change_dd" maxlength="2" value="<%=dChangeDD%>" class="boxC" style="width:25px" onkeyup="nextFocus(this.value,2,'d_change_mm');">/ 
       <input type="text" name="d_change_mm" maxlength="2" value="<%=dChangeMM%>" class="boxC" style="width:25px" onkeyup="nextFocus(this.value,2,'d_change_yy');">/ 
       <input type="text" name="d_change_yy" maxlength="4" value="<%=dChangeYY%>"class="boxC" style="width:40px">
    </td>
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

            <a href="#" onclick="saveData();"><img border="0" src="images/act_saveandclose.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>

            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_PaySchd01.jsp" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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