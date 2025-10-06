<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>

<%//@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>


<%
//String sessionId = user.getsessionId();
//String userId = user.getUserID();
String jName = "SERV_FCAMDetail.jsp";
//ServLog servlog = new ServLog(sessionId, userId, jName);
doString str = new doString();




   //----============ Declare Variables for input data ===========----//
   String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase(); 
   //session.setAttribute("sess_sel_proj",selProj);
   /*
   if  (selProj.length()==0) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       session.setAttribute("sess_sel_proj",selProj);
   }*/

   String month[] = {"เดือน","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};

   String docNo = doString.checkString(request.getParameter("i_docno"),"").toUpperCase();
   String houseId = doString.checkString(request.getParameter("i_house"),"").toUpperCase();
   String lock = doString.checkString(request.getParameter("i_lock"),"").toUpperCase();
   String jobStatus = doString.checkString(request.getParameter("job_status"),"").toUpperCase();
   String cardno = doString.checkString(request.getParameter("cardno"),"");
   String condition = "";
   String condition2 = "";
   String subcondition = "";
			       
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	SERV_CommonData common = null;

	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();   
		stmt1 = conn.createStatement();   
		common = new SERV_CommonData(conn);     
        //----=======================================----//   
        

        //---====================== Generate Serrch Condition ===========================---//
		/*String startDate = yy+"-07-"+dd;
		out.println(startDate);
		String endDate = "";*/
        String startDate = common.getValueFromDateListbox("start", request);
        String endDate = common.getValueFromDateListbox("end",request);
		String option = "";	
		String project = "LHALL", i_company = "", i_project = "", n_project = "";
		if (request.getParameter("project") != null) {
				project = doString.DisplayThai(doString.checkString(request.getParameter("project")));
		} // End if	



	/*if (!project.equals("")) {
		i_company = project.substring(0, 2);
		i_project = project.substring(2);
	} // End if
*/



			String Selected = "", code = "";	
			Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
			int cur_year = rightNow.get(Calendar.YEAR) + 543;
			int YY = 0;
			int MM = 0;
			int DD = 0;
			int YY2 = 0;
			int MM2 = 0;
			int DD2 = 0;	
			int i = 0;
			String d_start = "";
  			String d_stop = "";	
			double sum_wage = 0;

			if (request.getParameter("YY") != null ){
			YY = Integer.parseInt(doString.checkString(request.getParameter("YY")));
		} else {
			YY = rightNow.get(Calendar.YEAR) + 543;
		}
		if (request.getParameter("MM") != null ){
			MM = Integer.parseInt(doString.checkString(request.getParameter("MM")));
		} else {
			MM = rightNow.get(Calendar.MONTH) + 1;
		}
		if (request.getParameter("DD") != null ){
			DD = Integer.parseInt(doString.checkString(request.getParameter("DD")));
		} else {
			DD = rightNow.get(Calendar.DATE);
		}
		if (request.getParameter("YY2") != null ){
			YY2 = Integer.parseInt(doString.checkString(request.getParameter("YY2")));
		} else {
			YY2 = rightNow.get(Calendar.YEAR) + 543;
		}
		if (request.getParameter("MM2") != null ){
			MM2 = Integer.parseInt(doString.checkString(request.getParameter("MM2")));
		} else {
			MM2 = rightNow.get(Calendar.MONTH) + 1;
		}
		if (request.getParameter("DD2") != null ){
			DD2 = Integer.parseInt(doString.checkString(request.getParameter("DD2")));
		} else {
			DD2 = rightNow.get(Calendar.DATE);
		}
	
	 	d_start = doString.displayNumber("0000", YY-543) + doString.displayNumber("00", MM) + doString.displayNumber("00", DD);
		d_stop = doString.displayNumber("0000", YY2-543) + doString.displayNumber("00", MM2) + doString.displayNumber("00", DD2);	

		String orderby = doString.checkString(request.getParameter("order"), "a.i_date");


	if (d_start.length()>0 && d_stop.length()>0) {
	   condition += " and a.i_date between '"+d_start+"' and '"+d_stop+"' ";
	}
	//---=========================================================================----//   

        
        //----====================== Get DOCHD Max Row ==============================-----//
        int maxRow = 0;
      
        
	   //-----============== Generate Display Customize and Page Link ==================-----//
	   String displayType = doString.checkString(request.getParameter("display_type"),"");    
	   int displayLine = Integer.parseInt(doString.checkString(request.getParameter("display_line"),"0"));
	   int nowPage = Integer.parseInt(doString.checkString(request.getParameter("now_page"),"1"));
	   if (displayType.equalsIgnoreCase("A")) {
	      displayLine = maxRow;
	      nowPage = 1;
	   }
	   if (displayLine<Constants.SERV_REPRINT_LINE) displayLine = Constants.SERV_REPRINT_LINE;      
	   
	   int startRow = ((nowPage-1)*displayLine);
	   int endRow = startRow+displayLine;
	   int tmpMax = maxRow;
	   
	   String pageLink = "";
	   int tmpPage = 0;
	  
	 //---=========================================================================----//                
         


%>

<HTML>
<HEAD>
<TITLE>Report Finger Scan</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--

/*  function searchDocHD() {
     if (!validDate()) {
        return false;
     }
  
     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_FCReport.jsp";
     document.forms[0].submit();  
  }

  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_FCReport.jsp";
     document.forms[0].submit();
  }   
  
  function validDate() {
     var sdate = document.forms[0].start_date.value;
     var smonth = document.forms[0].start_month.value;
     var syear = document.forms[0].start_year.value;
     var edate = document.forms[0].end_date.value;
     var emonth = document.forms[0].end_month.value;
     var eyear = document.forms[0].end_year.value; 
     
     //---- Check select date ---//
     if (sdate.length==0 && smonth.length==0 && syear.length==0 &&
         edate.length==0 && emonth.length==0 && eyear.length==0) {
         return true;
     }     

     
     var startDate = new Date(parseInt(syear,10),parseInt(smonth,10)-1,parseInt(sdate,10));
     var endDate = new Date(parseInt(eyear,10),parseInt(emonth,10)-1,parseInt(edate,10));
     
     if (startDate.getMonth()!=(parseInt(smonth,10)-1)) {
        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].start_date.focus();
        return false;
     }
     
     if (endDate.getMonth()!=(parseInt(emonth,10)-1)) {
        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].end_date.focus();
        return false;
     }     
     
	if (startDate>endDate) {
	    alert(" วันที่สิ้นสุดต้องไม่น้อยกว่าวันที่เริ่มต้น ! ");
	    return false;
	}
  
     return true;
  }
*/

function submit()  {		
		Finger.action = "/LHServ/SERV_FCAMDetail.jsp";
		Finger.submit();
}

function OrderBy(orderfld) {
	Finger.order.value = orderfld;
	Finger.submit();
}


//-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM NAME="Finger" METHOD="POST" ACTION="SERV_FCAMDetail.jsp">
<INPUT type="hidden" name="order" value="">
<INPUT type="hidden" name="cardno" value="<%=cardno%>">
<input type="hidden" name="now_page" value="<%=nowPage%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            รายงานสรุปการเข้างานของคนขับรถและแม่บ้าน</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดการเข้างาน</td>
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
 <!-- <tr>
    <td class="item ; dotline01" height="22" width="15%">โครงการ :</td>
    <td height="22" width="45%" class="dotline01">
    <%//=common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:250px' ",true)%>       
    </td>
    <td height="22" class="item ; dotline01" width="14%">&nbsp;</td>
    <td height="22" width="26%" class="dotline01">&nbsp;</td>
  </tr>-->
  <!--
   <tr>
    <td height="22" class="item ; dotline01" width="11%">เลือกโครงการ : &nbsp;
	<td height="22" width="89%" class="dotline01">
    <select name='project' class='box' style='width:250px'  >
    <OPTION value="LHALL">----- ทุกโครงการ-----</OPTION>
<%	
	         sql.delete(0, sql.length());
			 sql.append("SELECT DISTINCT i_header ")
				  .append("from lan:serv_finger ")
				  .append("where i_header = 'Admin Dept' ")
				  .append("order by 1 ");
			rs = stmt.executeQuery(sql.toString());
			while (rs.next()==true) {
	
			option = "";
			if (project.equals(doString.DisplayThai(doString.checkString(rs.getString("i_header"))))) {
				option = " Selected ";
			} // End if
%>
			<OPTION value="<%=doString.DisplayThai(doString.checkString(rs.getString("i_header")))%>" <%=option%>>
			<%=doString.DisplayThai(doString.checkString(rs.getString("i_header")))%>
			</OPTION>
<%			
		} // End while
%></SELECT>&nbsp;&nbsp;</td>
  </tr>
-->
  <tr>
    <td class="item ; dotline01" height="22" width="11%">วันที่ :</td>
    <td height="22" width="45%" class="dotline01"><select size="1" name="DD" class="box" style="width:40px">
<%
		code = "";
		for (i = 1; i <= 31; i++) {
			code = Integer.toString(i);
			if (i < 10) {
				code = "0"+ Integer.toString(i);
			}
			Selected = "";
			if (i == DD) {
				Selected = " Selected ";
			}
%>
			<option value="<%=code%>" <%=Selected%>><%=code%></option>
<%
		} // End for
%></select>&nbsp;<select size="1" name="MM" class="box" style="width:85px">
<%
	code = "";
	for (i = 1; i <= 12; i++) {
		code = Integer.toString(i);
		if (i < 10) {
			code = "0"+ Integer.toString(i);
		}
		Selected = "";
		if (i == MM) {
			Selected = " Selected ";
		}
%>
		<option value="<%=code%>" <%=Selected%>><%=month[i]%></option>
<%
	} // End for
%></select>&nbsp;<select size="1" name="YY" class="box" style="width:55px">
<%
	code = "";
	for (i = YY-5; i <= YY+5; i++) {
		code = Integer.toString(i);
		Selected = "";
		if (i == YY)  {
			Selected = " Selected ";
		}
%>
		<option value="<%=code%>" <%=Selected%>><%=i%></option>
<%
	} // End for 
%></select>&nbsp;&nbsp;&nbsp;&nbsp;ถึง &nbsp;&nbsp;&nbsp;&nbsp;<select size="1" name="DD2" class="box" style="width:40px">
<%
		code = "";
		for (i = 1; i <= 31; i++) {
			code = Integer.toString(i);
			if (i < 10) {
				code = "0"+ Integer.toString(i);
			}
			Selected = "";
			if (i == DD2) {
				Selected = " Selected ";
			}
%>
			<option value="<%=code%>" <%=Selected%>><%=code%></option>
<%
		} // End for
%></select>&nbsp;<select size="1" name="MM2" class="box" style="width:85px">
<%
	code = "";
	for (i = 1; i <= 12; i++) {
		code = Integer.toString(i);
		if (i < 10) {
			code = "0"+ Integer.toString(i);
		}
		Selected = "";
		if (i == MM2) {
			Selected = " Selected ";
		}
%>
		<option value="<%=code%>" <%=Selected%>><%=month[i]%></option>
<%
	} // End for
%></select>&nbsp;<select size="1" name="YY2" class="box" style="width:55px">
<%
	code = "";
	for (i = YY2-5; i <= YY2+5; i++) {
		code = Integer.toString(i);
		Selected = "";
		if (i == YY2)  {
			Selected = " Selected ";
		}
%>
		<option value="<%=code%>" <%=Selected%>><%=i%></option>
<%
	} // End for 
%></select>&nbsp;

   &nbsp;&nbsp;&nbsp;<a href = "javascript:Finger.submit()"><img border="0" src="images/i_search.gif" align="absmiddle" width="20" height="20"></a>
    </td>
    <td height="22" class="item ; dotline01" width="14%"> &nbsp;</td>
    <td height="22" width="30%" class="dotline01">&nbsp;</td>
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

<!--
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="160">รายการซ่อม</td>
                <td class="item_tab3"></td>
                <td>&nbsp;<input type="radio" value="L" checked name="display_type" <%=(displayType.equalsIgnoreCase("L") ? "checked" : "")%>>แสดงจำนวนรายการต่อหน้า&nbsp;
                  <input type="text" name="display_line" class="boxC" style="width:50px" value="<%=displayLine%>">&nbsp;
                  รายการ&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" value="A" name="display_type" <%=(displayType.equalsIgnoreCase("A") ? "checked" : "")%>>
                  แสดงรายการทั้งหมด&nbsp;&nbsp;&nbsp;&nbsp;
                  <a href="#" onclick="changePage(1);"><img border="0" src="images/bu_R.gif" align="absmiddle" style="cursor:hand" width="16" height="16"></a>
                  </td>
              </tr>
            </table> -->


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
          <td width="5%" class="col_name">no.</td>
          <td width="15%" class="col_name">รหัส</td>
          <td width="20%" class="col_name"><A HREF="javascript:OrderBy('a.i_name');">ชื่อ-สกุล</A></td>
   	      <td width="10%" class="col_name"><A HREF="javascript:OrderBy('a.i_date, a.i_checkin, a.i_checkout');">วันที่เข้างาน</A></td>
          <td width="10%" class="col_name"><A HREF="javascript:OrderBy('a.i_checkin');">เวลาเข้างาน</A></td>
          <td width="10%" class="col_name"><A HREF="javascript:OrderBy('a.i_checkout');">เวลาออกงาน</A></td>
          <td width="15%" class="col_name"><A HREF="javascript:OrderBy('b.n_job');">ตำแหน่ง</A></td>
		  <td width="15%" class="col_name">สังกัดบริษัท</td>
        </tr>

<%
        
		     //----================== Select Data from SERV_DOCHD ================----//   
		        int line = 0;		     
				String i_date = "", i_checkin = "", i_checkout = "", n_job = "", n_owner = "";						
				
					String h_proj = "";
					sql.delete(0,sql.length());	
					sql.append("select distinct a.i_cardno, a.i_name, a.i_header, a.i_date, a.i_checkin, a.i_checkout, b.n_job, b.z_wage, b.i_dept ")
						 .append("from lan:serv_finger a, lan:serv_tstaff b ")
						 .append("where a.i_cardno = b.i_cardno ")                 
						 .append("and a.i_header = 'Admin Dept' "+condition)
						 .append("and a.i_cardno = '"+cardno+"' ")
						 .append("order by "+orderby);
				//	out.println(sql.toString());
					rs = stmt.executeQuery(sql.toString());					
					while (rs.next()) {
					
					 line++;         		

					/* if (!h_proj.equals(doString.checkString(rs.getString("i_header")))) {					 
							line = 1;
					 }*/          
					 i_date = doString.checkString(rs.getString("i_date"),"-");
					 i_checkin = doString.checkString(rs.getString("i_checkin"),"-");
					 i_checkout = doString.checkString(rs.getString("i_checkout"),"-");

					 if (!i_checkin.equals("-")) {						
							i_checkin = i_checkin.substring(11,16);
					 }
					  if (!i_checkout.equals("-")) {						
							i_checkout = i_checkout.substring(11,16);
					 }
					  if (!i_date.equals("-")) {						
							i_date = i_date.substring(8,10)+"/"+i_date.substring(5,7)+"/"+i_date.substring(0,4);							
					 } 

					 n_job = "";
					sql.delete(0,sql.length());	
					sql.append("select n_desc from lan:drive_owner ")
						 .append("where i_type = '02' ")	
						 .append("and i_code = '"+doString.DisplayThai(rs.getString("n_job"))+"' ");						  
					rs1 = stmt1.executeQuery(sql.toString());					
					if (rs1.next()==true) {
							n_job = doString.checkString(doString.DisplayThai(rs1.getString("n_desc")));
					}

					n_owner = "";
					sql.delete(0,sql.length());	
					sql.append("select n_desc from lan:drive_owner ")
						 .append("where i_type = '01' ")	
						 .append("and i_code = '"+doString.DisplayThai(rs.getString("i_dept"))+"' ");
					rs1 = stmt1.executeQuery(sql.toString());					
					if (rs1.next()==true) {
							n_owner = doString.checkString(doString.DisplayThai(rs1.getString("n_desc")));
					}

%>
					        <tr>
					          <td width="5%" align="center" class="dotline"><%=line%></td>
					          <td width="15%" class="dotline ; item" align="center"><%=doString.checkString(rs.getString("i_cardno"),"-")%></td>
					          <td width="20%" class="dotline" align="left">&nbsp;<%=doString.checkString(doString.DisplayThai(rs.getString("i_name")),"-")%></td>
					       	  <td width="10%" align="center" class="dotline"><%=i_date%></td>
					          <td width="10%" align="center" class="dotline"><%=i_checkin%></td>
					          <td width="10%" align="center" class="dotline"><%=i_checkout%></td>
					          <td width="15%" align="center" class="dotline"><%=n_job%></td>
							   <td width="15%" align="center" class="dotline"><%=n_owner%>&nbsp;</td>
					        </tr>			

<%
		h_proj = doString.checkString(rs.getString("i_header"));

		sum_wage += rs.getDouble("z_wage");

} // end while

%>

							<tr>
					          <td width="5%" align="center" class="dotline">&nbsp;</td>
					          <td width="15%" class="dotline ; item" align="center">&nbsp;</td>
					          <td width="20%" class="dotline" align="left">&nbsp;</td>
							  <td width="10%" align="center" class="dotline">&nbsp;</td>
					          <td width="10%" align="center" class="dotline">&nbsp;</td>
					          <td width="10%" align="center" class="dotline">&nbsp;</td>
					          <td width="15%" align="right" class="dotline ; item">Total&nbsp;</td>
							   <td width="15%" align="center" class="dotline ; item"><%=line%>&nbsp;วัน</td>
					        </tr>
<%
               
	           if (line<=0) {

%>    							
							<tr>
					          <td width="100%" align="center" class="dotline" colspan=8>....................   ไม่มีรายการ   ....................</td>
							</tr>							
					        
<%               
	           }
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




<br style="font-size:3pt">



      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr class="gray">
          <td width="100%" align="right"><%//=pageLink%></td>
        </tr>
      </table>




<br style="font-size:10pt">



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">

            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="#" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="#" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
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
		System.out.println("ERROR SERV_FCAMDetail.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (rs1 != null) rs.close();
			if (stmt != null) stmt.close();
			if (stmt1 != null) stmt.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>