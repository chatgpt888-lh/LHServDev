<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
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
    String mode = doString.checkString(request.getParameter("mode"),"add");
    String selProj = doString.checkString(request.getParameter("sel_project"),"");
	String iSignb = doString.checkString(request.getParameter("i_signb"),"");
	String startDate = doString.checkString(request.getParameter("d_beg_use"),"");
	String endDate = doString.checkString(request.getParameter("d_fin_use"),"");

	
    StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	SERV_CommonData com = null;
	doString str = new doString();
	
	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();   
	    com = new SERV_CommonData(conn);  
        //----=======================================----//	
        
        

        
        
	 %>

<HTML>
<HEAD>
<TITLE>ข้อมูลพื้นฐาน : 06
รายละเอียดการตัดเงินตามแปลง</TITLE>
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


function save() {
     var form = document.forms[0];

     if (form.sel_project.value=="") {
        alert(" กรุณาเลือกโครงการ !");
		form.sel_project.focus();
        return false;
     }  	  
 
	if (!checkFormatDate(form.d_beg_use.value)) {
	   form.d_beg_use.focus();
	   return false;
	}

	if (!checkFormatDate(form.d_fin_use.value)) {
	   form.d_fin_use.focus();
	   return false;
	}


	if (form.d_beg_use.value.length==10 && form.d_fin_use.value.length==10) {
		 var yearStart = parseInt(form.d_beg_use.value.substring(6,10),10);
		 if (yearStart>2400) yearStart-=543;
		 var yearEnd = parseInt(form.d_fin_use.value.substring(6,10),10);
		 if (yearEnd>2400) yearEnd-=543;     
		 
		 var dStart = new Date(yearStart,parseInt(form.d_beg_use.value.substring(3,5),10)-1,form.d_beg_use.value.substring(0,2),23,59,59);
		 var dEnd = new Date(yearEnd,parseInt(form.d_fin_use.value.substring(3,5),10)-1,form.d_fin_use.value.substring(0,2),23,59,59);

		 if (dStart>dEnd) {
			alert("วันที่สิ้นสุดต้องไม่น้อยกว่าวันที่เริ่มต้น !");
				form.d_fin_use.focus();
				return false;	    
		 }
	}


  form.action="<%=Constants.APP_PATH%>/SERV_SignbServlet";
  form.submit();
  
}


	function convertDateFormat(dateObj) {
	   if (dateObj==null) return false;

		var countSlash = 0;
	    for (var i=0;i<dateObj.value.length;i++) {
		       if (dateObj.value.charAt(i)=='/') countSlash++;
		} // end for

		if (countSlash!=2) {
		    alert("รูปแบบวันที่ไม่ถูกต้อง!");
		    dateObj.focus();
		    return false;
		}

	    var splitDate = dateObj.value.split("/"); 
		var day = 0;
		var month = 0;
		var year = 0;

		try {
		    day = parseInt(splitDate[0],10);
		    month = parseInt(splitDate[1],10);
		    year = parseInt(splitDate[2],10);
		} catch (e) {
		   alert("วันที่ไม่ถูกต้อง!");
		   dateObj.focus();
		   return false;
		}

		if (day>=1 && day<=31) {
		    if (month>=1 && month<=12) {

		    if (isNaN(year) || (year>=100 && year<=999)) {
		        alert("กรุณาใส่ปีเป็นรูปแบบ yy หรือ yyyy เท่านั้น!");
			dateObj.focus();
			return false;
		      }

			   //----- Convert to BC. -------//	
			   if (year<45) year += 2543;
			   if (year>=45 && year<100) year += 2500;
			   if (year<2400) year += 543;

			    var dateStr = (day<10 ? "0"+day : day)+"/"+(month<10 ? "0"+month : month)+"/"+year;
	                    dateObj.value = dateStr;

				if (!checkFormatDate(dateStr)) {
				    dateObj.focus();
				    return false;
				}

			} else {
			   alert("เดือนต้องมีค่าระหว่าง 1 - 12 เท่านั้น!");
			   dateObj.focus();
			   return false;
			}
		} else {
		   alert("วันที่ต้องมีค่าระหว่าง 1 - 31 เท่านั้น!");
		   dateObj.focus();
		   return false;
		}

	}
  
	function checkFormatDate(str)
	{
		var mystring = str;
		if (mystring.match(/(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.]([1-9])\d\d\d/ ) ) { 
		   var yyyy = parseInt(str.substring(6,10),10);
		   var mm = parseInt(str.substring(3,5),10)-1;
		   var dd = parseInt(str.substring(0,2),10);
		   if (yyyy>2400) yyyy -= 543;
	
	       var cdate = new Date(yyyy,mm,dd);
		   if (mm!=cdate.getMonth()) {
		      alert("วันที่ไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
		      return false;
		   }
		} else {
			alert("รูปแบบวันที่ไม่ถูกต้อง !");
			return false;
		}
		
		return true;
	}  



</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM action="" method="post">

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
                <td class="item_tab2" width="250">รายละเอียดป้ายต่อเติม</td>
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
    <td class="item ; dotline01" height="22" width="20%">โครงการ :</td>
    <td height="22" width="80%" class="dotline01">
    <%=com.genAllProjectListbox("sel_project",selProj," size='1' class='box' style='width:250px' onchange='refreshPage();' ",false)%>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="20%">เลขที่ป้ายต่อเติม :</td>
    <td height="22" width="80%" class="dotline01"><input type="text""  name="i_signb" class="box" value="<%=iSignb%>"  style="width:60px" ></td>
  </tr>
 <tr>
    <td class="item ; dotline01" height="22" width="20%">วันที่เริ่มต้น :</td>
   <td height="22" width="80%" class="dotline01">
     <input type="text" onchange="convertDateFormat(this);" name="d_beg_use" style="width:120px" class="box" value="<%=startDate%>"> &nbsp; (d/m/yy หรือ dd/mm/yyyy)
   </td>
  </tr>
 <tr>
    <td class="item ; dotline01" height="22" width="20%">วันที่สิ้นสุด :</td>
   <td height="22" width="80%" class="dotline01">
     <input type="text" onchange="convertDateFormat(this);" name="d_fin_use" style="width:120px" class="box" value="<%=endDate%>"> &nbsp; (d/m/yy หรือ dd/mm/yyyy)
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

            <img border="0" src="images/act_saveandclose.gif" onclick="save();"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">

            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_Signb.jsp" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
		System.out.println("ERROR SERV_Signb.jsp : " + e.getMessage());
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