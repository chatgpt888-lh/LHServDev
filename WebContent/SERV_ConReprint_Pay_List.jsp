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
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>


<%
   doString str = new doString();
   String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase(); 
   String docNo = doString.checkString(request.getParameter("i_docno"),"").toUpperCase();
   String jobStatus = doString.checkString(request.getParameter("job_status"),"").toUpperCase();
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
        String startDate = common.getValueFromDateListbox("start",request);
        String endDate = common.getValueFromDateListbox("end",request);

		
        if (selProj.trim().length()>=6 && !selProj.equalsIgnoreCase("ALL")) {
			condition = " AND a.i_company = '"+selProj.substring(0,2)+"' AND a.i_project = '"+selProj.substring(3,6)+"' ";
			subcondition = " AND e.i_company = '"+selProj.substring(0,2)+"' AND e.i_project = '"+selProj.substring(3,6)+"' ";
        } 

		if (selProj.trim().length()<=0) {
			 //---=== set for no select ===---//
			condition = " AND a.i_docno = 'NOPROJECT' ";
			subcondition = " AND e.i_docno = 'NOPROJECT' ";
		}
		
        if (docNo.trim().length()>0) {
           condition += " AND a.i_docno = '"+docNo+"' ";
        }
        if (jobStatus.trim().length()>0) {            
		   condition2 = "";
		   subcondition += " AND e.f_itmstatus = '"+jobStatus+"' ";
	}

	if (startDate.length()>0 && endDate.length()>0) {
	   condition += " AND a.d_keyin BETWEEN '"+startDate+" 00:00' AND '"+endDate+" 23:59' ";
	}
	//---=========================================================================----//   

        
        //----====================== Get DOCHD Max Row ==============================-----//
        int maxRow = 0;

        sql.delete(0,sql.length());
		if (!jobStatus.equals("100")) {
			sql.append(" SELECT COUNT(*) AS CNT FROM lan:serv_infdochd a ")
				  .append(" WHERE a.f_status IN ('OPN','CLS') AND a.i_doc_type = 'C' AND (a.i_docno IN ( ")
				  .append(" SELECT i_docno FROM lan:serv_infpayment e WHERE e.f_itmstatus != 'CAN' ")
				  .append(subcondition)
				  .append(" GROUP BY e.i_docno ").append(condition2).append(" )) ")
				  .append(condition);
		}
        rs = stmt.executeQuery(sql.toString());
        if (rs.next()) {        
           maxRow = rs.getInt(1);  
        }
        rs.close();
        rs=null;
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
	   while (tmpMax>0) {
	       tmpMax -= displayLine;
	       tmpPage++;
	       if (nowPage==tmpPage) {
	          pageLink += "&nbsp; <b>"+tmpPage+"</b> ";
	       } else {
	          pageLink += "&nbsp; <a href='#' onclick='changePage("+tmpPage+");'>"+tmpPage+"</a> ";
	       }
	   }
	   
	   if (tmpPage>1) {
	      int prev = nowPage-1;
	      if (prev<1) prev=1;  
	      pageLink = "<a href='#' onclick='changePage("+prev+");'>หน้าก่อน</a>&nbsp; "+pageLink;
	      int next = nowPage+1;
	      if (next>tmpPage) next = tmpPage;
	      pageLink += "&nbsp; <a href='#' onclick='changePage("+next+");'>หน้าถัดไป</a>";      
	   } else {
	      pageLink = "หน้า <b>1</b>";
	   }
	 //---=========================================================================----//                
%>
<HTML>
<HEAD>
<TITLE>Reprint List</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--

  function searchDocHD() {
     if (!validDate()) {
        return false;
     }
  
     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_ConReprint_Pay_List.jsp";
     document.forms[0].submit();  
  }

  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_ConReprint_Pay_List.jsp";
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

//-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM METHOD="POST" ACTION="">
<input type="hidden" name="now_page" value="<%=nowPage%>">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;พิมพ์ใบเบิกงวด</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>
<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดการเบิกงวด</td>
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
    <td class="item ; dotline01" height="22" width="15%">โครงการ :</td>
    <td height="22" width="45%" class="dotline01">
    <%=common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:250px' ")%>       
    </td>
    <td height="22" class="item ; dotline01" width="14%">เลขที่ใบเบิกงวด
      :</td>
    <td height="22" width="26%" class="dotline01"><input type="text" name="i_docno" class="box" style="width:100px" value="<%=docNo%>"></td>
  </tr>

  <tr>
    <td class="item ; dotline01" height="22" width="11%">วันที่เบิกงวด
      :</td>
    <td height="22" width="45%" class="dotline01">
    <%=common.genDateListbox("start",request," class='box' ")%> &nbsp; ถึง &nbsp; 
    <%=common.genDateListbox("end",request," class='box' ")%>
    </td>
    <td height="22" class="item ; dotline01" width="14%">สถานะ :</td>
    <td height="22" width="26%" class="dotline01"> 
    <select size="1" class="box" style="width:100px" name="job_status">
        <option value=''>ทุกสถานะ</option>
        <option value='500' <%=jobStatus.equals("500") ? " selected " : ""%>>Service Staff</option>
        <option value='600' <%=jobStatus.equals("600") ? " selected " : ""%>>Service Manager</option>
        <option value='700' <%=jobStatus.equals("700") ? " selected " : ""%>>Manager</option>
        <option value='800' <%=jobStatus.equals("800") ? " selected " : ""%>>VP</option>
        <option value='CLS' <%=jobStatus.equals("CLS") ? " selected " : ""%>>Close</option>
      </select>
      &nbsp;&nbsp;&nbsp;&nbsp;
      <a href="#" onclick="searchDocHD()"><img border="0" src="images/i_search.gif" align="absmiddle" width="20" height="20"></a> 
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
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="160">รายการเบิกงวด</td>
                <td class="item_tab3"></td>
                <td>&nbsp;<input type="radio" value="L" checked name="display_type" <%=(displayType.equalsIgnoreCase("L") ? "checked" : "")%>>แสดงจำนวนรายการต่อหน้า&nbsp;
                  <input type="text" name="display_line" class="boxC" style="width:50px" value="<%=displayLine%>">&nbsp;
                  รายการ&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" value="A" name="display_type" <%=(displayType.equalsIgnoreCase("A") ? "checked" : "")%>>
                  แสดงรายการทั้งหมด&nbsp;&nbsp;&nbsp;&nbsp;
                  <a href="#" onclick="changePage(1);"><img border="0" src="images/bu_R.gif" align="absmiddle" style="cursor:hand" width="16" height="16"></a>
                  </td>
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
          <td width="14%" class="col_name">เลขที่ใบเบิกงวด</td>
          <td width="16%" class="col_name">วันที่เบิก</td>
          <td width="45%" class="col_name">ชื่อผู้ขอเบิก</td>
          <td width="13%" class="col_name">สถานะ</td>
          <td width="16%" class="col_name">&nbsp;</td>
        </tr>
        <%
			String status = "";
			String iDocNo = "";
			String iLock = "";
			String iHouse = "";
			String nCustomer = "";
			String nCustTel = "";
			String iDocType = "";
			String iCompany = "";
			String iProject = "";

			
			Hashtable tmpCust = new Hashtable();
			String ownName = "";
			String ownTel = "";
									
			String keyinDate = "-";			
			Calendar keyin = Calendar.getInstance();        
		    String jspLink = "";
			String tmpStat = "";


		     //----================== Select Data from SERV_INFDOCHD ================----//   
		        int line = 0;		 
		        sql.delete(0,sql.length());				
				sql.append(" SELECT a.* FROM lan:serv_infdochd a ")
				  .append(" WHERE a.f_status IN ('OPN','CLS') AND a.i_doc_type = 'C' AND (a.i_docno IN ( ")
				  .append(" SELECT i_docno FROM lan:serv_infpayment e WHERE e.f_itmstatus != 'CAN' ")
				  .append(subcondition)
				  .append(" GROUP BY e.i_docno ").append(condition2).append(" )) ")
				  .append(condition)
				  .append(" ORDER BY 6");
		        rs = stmt.executeQuery(sql.toString());
		        for (int i=0;i<maxRow;i++) { 
                      if (rs.next()) {
                         if (i>=startRow && i<=endRow) {
                            //------ Data is in this page , display -----//
				            status = "OPEN";
				            iDocNo = doString.checkString(rs.getString("i_docno"),"");
				            iCompany = doString.checkString(rs.getString("i_company"),"");
				            iProject = doString.checkString(rs.getString("i_project"),"");

							Hashtable tmpHeader = common.getInfDocHeaderDetails(iDocNo);
							String inFormEmp = doString.checkString((String) tmpHeader.get("inform_emp"),"");

				            keyinDate = "-";
				            
			                //---- Keyin Date ----// 
						    Timestamp tmp = rs.getTimestamp("d_keyin");
						    if (tmp!=null)  {
						        keyin.setTime(tmp);      
							    keyinDate = getDateFromCalendar(keyin);    
							    keyinDate += "&nbsp;&nbsp;"+getTimeFromCalendar(keyin)+" น.";    		            
						    }
						    
						    jspLink = "";
						    if (status.equalsIgnoreCase("INFORM")) {
						    } else {
						       jspLink = "SERV_ConOpenJob_Pay_Disp.jsp?i_docno="+iDocNo;
							   status = "";
							   tmpStat = "";

						       sql.delete(0,sql.length());
						       sql.append("SELECT DISTINCT f_itmstatus FROM lan:serv_infpayment WHERE f_itmstatus != 'CAN' ")
						             .append(" AND i_docno = '").append(iDocNo).append("' ")
								     .append(" ORDER BY f_itmstatus");
						       rs1 = stmt1.executeQuery(sql.toString());
						       while (rs1.next()) {
						         tmpStat = doString.checkString(rs1.getString("f_itmstatus"),"");
								 if (status.trim().length()>0) status += ", <br>";

						         if (tmpStat.equals("400")) {
						           //---================== Open Status ==================---//
						            status += "Contractor";
						         } else if (tmpStat.equals("500")) {
						            //---=============== Start task , No edit ===============---//
						            status += "Service Staff";
						         } else if (tmpStat.equals("600")) {
						            //---============= Complete task , No edit ============---//
						            status += "Service Manager";
						         } else if (tmpStat.equals("700")) {
						            //---============= Complete task , No edit ============---//
						            status += "Manager";
						         } else if (tmpStat.equals("800")) {
						            //---============= Complete task , No edit ============---//
						            status += "VP";
						         } else if (tmpStat.equals("CLS")) {
						            //---============= Complete task , No edit ============---//
						            status += "Close";
						         } else {
						             //---============ Unknown Status , No edit ===========---// 
						            status = "-";
						         }
						       }
						       rs1.close();

							   jspLink += "&edit=no";
						    }
						            
					        %>
					        <tr>
					          <td width="14%" align="center" class="dotline"><a href="<%=jspLink%>"><%=iDocNo%></a></td>
					          <td width="16%" align="center" class="dotline"><%=keyinDate%></td>
					          <td width="45%" class="dotline ; item"><%=doString.DisplayThai(inFormEmp)%></td>
					          <td width="13%" align="center" class="dotline"><%=status%></td>
					          <td width="16%" align="center" class="dotline">&nbsp;</td>
					        </tr>					        
					        <%
					        
 					         line++;                         
                         } // end if check row
                         
                         if (i>endRow) break;                         
                      } //end if check rs
                } // end for
                
	           while (line<displayLine) {
	               line++;
	                %>    
			        <tr>
			          <td width="14%" align="center" class="dotline">&nbsp;</td>
			          <td width="16%" align="center" class="dotline">&nbsp;</td>
			          <td width="45%" class="dotline ; item">&nbsp;</td>
			          <td width="13%" align="center" class="dotline">&nbsp;</td>
			          <td width="16%" align="center" class="dotline">&nbsp;</td>
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
          <td width="100%" align="right"><%=pageLink%></td>
        </tr>
      </table>
<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">
            </td>   
            <td class="act_tab3"></td>   
            <td class="act_tab4">
              <a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
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
		stmt.close();
		stmt1.close();
		conn.close();
		stmt=null;
		stmt1=null;
		conn=null;
	} catch (Exception e) {
		System.out.println("ERROR SERV_ConReprint_Pay_List.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (rs1 != null) rs1.close();
			if (stmt != null) stmt.close();
			if (stmt1 != null) stmt1.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>