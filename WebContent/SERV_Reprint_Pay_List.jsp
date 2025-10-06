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

<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>


<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_Reprint_Pay_List.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   doString str = new doString();


   //----============ Declare Variables for input data ===========----//
   String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase(); 
   /*if  (selProj.length()==0) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       session.setAttribute("sess_sel_proj",selProj);
   }*/

   String docNo = doString.checkString(request.getParameter("i_docno"),"").toUpperCase();
   String houseId = doString.checkString(request.getParameter("i_house"),"").toUpperCase();
   String lock = doString.checkString(request.getParameter("i_lock"),"").toUpperCase();
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
			condition = " and a.i_company='"+selProj.substring(0,2)+"' and a.i_project='"+selProj.substring(3,6)+"' ";
			subcondition = " and i_docno[1,2]='"+selProj.substring(0,2)+"' and i_docno[4,6]='"+selProj.substring(3,6)+"'  ";
//           condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
        } 

		if (selProj.trim().length()<=0) {
			 //---=== set for no select ===---//
			condition = " and a.i_docno='NOPROJECT' ";
			subcondition = " and i_docno='NOPROJECT' ";
		}
		
		/*
        if (selProj.trim().length()>0 && !selProj.equalsIgnoreCase("ALL")) {
           condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
        }
		if (selProj.trim().length()<=0) {
		   String projList = common.getProjectListByUserId(user.getUserID());
		   if (projList.length()>0) {
		       condition += " and substr(a.i_docno,1,6) in ("+projList+") ";
		   } else {

			sql.delete(0,sql.length());
			sql.append(" select count(*) from serv_pstaff  where user_id='").append(user.getUserID()).append("' and proj_id='ALL' ");
			int checkAllPermission = 0;

			rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
			    checkAllPermission = rs.getInt(1);
			}
			rs.close();
			if (checkAllPermission<=0) { 
			   //----- used for user that no project in hand , set for data not load ----//
			   condition += " and a.i_docno='NOPROEJCT' ";
		       } else {
			  selProj = "ALL";
		       }

		   }
		}*/


        if (docNo.trim().length()>0) {
           condition += " and a.i_docno='"+docNo+"' ";
        }
        if (houseId.trim().length()>0) {
           condition += " and b.i_house='"+houseId+"' ";
        }
        if (lock.trim().length()>0) {
           condition += " and a.i_lock='"+lock+"' ";
        }      
        if (jobStatus.trim().length()>0) {            
           //condition2 = " having max(e.f_itmstatus)='"+jobStatus+"' ";
		   condition2 = "";
		   subcondition += " and e.f_itmstatus='"+jobStatus+"' ";
	}

	if (startDate.length()>0 && endDate.length()>0) {
	   condition += " and a.d_keyin between '"+startDate+" 00:00' and '"+endDate+" 23:59' ";
	}
	//---=========================================================================----//   

        
        //----====================== Get DOCHD Max Row ==============================-----//
        int maxRow = 0;

        sql.delete(0,sql.length());
		if (!jobStatus.equals("100")) {
			sql.append(" select count(*) as cnt from serv_dochd a ")
				  .append(" left join lan:acxlckmd b on b.i_company=a.i_company and b.i_project=a.i_project and b.i_lock=a.i_lock ")
				  .append(" left join lan:acscontr c on c.i_company=a.i_company and c.i_project=a.i_project and c.i_lor=b.i_lor and c.f_contr is null ")
				  .append(" where a.f_status in ('OPN','CLS') and a.i_doc_type = 'J' and (a.i_docno in ( ")
				  .append(" select  i_docno from serv_payment e where f_itmstatus<>'CAN' ")
				  .append(subcondition)
				  .append(" group by i_docno ").append(condition2).append(" )) ")
				  .append(condition);
		}
		servlog.startLog(sql.toString());
        rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
        while (rs.next()) {        
           maxRow += rs.getInt("cnt");  
        }
        rs.close();
		/*
        sql.delete(0,sql.length());
        sql.append(" select count(*) cnt from serv_dochd a ")
              .append(" left join lan:acxlckmd b on b.i_company=a.i_company and b.i_project=a.i_project and b.i_lock=a.i_lock ")
              .append(" left join lan:acscontr c on c.i_company=a.i_company and c.i_project=a.i_project and c.i_lor=b.i_lor and c.f_contr is null ")
              .append(" where a.f_status in ('OPN','CLS') and ( ");
         if (jobStatus.equals("100")) {
            //sql.append("(a.i_doc_type='I') ");
         } else {     
	         sql.append(" (a.i_docno in ( ")
	              .append(" select d.i_docno from serv_dochd d,serv_payment e ")
	              //.append(" where  ((e.i_docno=d.i_docno) or (d.i_doc_type='I')) and e.f_itmstatus<>'CAN' group by d.i_docno ")
	              .append(" where  ((e.i_docno=d.i_docno) ");
		if (jobStatus.trim().length()<=0) {
		   // sql.append(" or (d.i_doc_type='I') ");
		}
		sql.append(" ) and e.f_itmstatus<>'CAN' group by d.i_docno ")
	              .append(condition2).append(")) ");
         }
        sql.append(" ) ").append(condition);
        rs = stmt.executeQuery(sql.toString());
        if (rs.next()) {        
           maxRow = rs.getInt("cnt");  
        }
        rs.close();
		*/
	   //---=========================================================================----//                

        
        
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


<script src="jquery3/jquery.min3.6.3.js" ></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
<script src="jquery3/loadingoverlay.min2.1.7.js"></script>

<script language="javascript">
<!--

function queryProject() {
}

 $(document).ready(function() {
 
 $(window).on('load', function() {
        $.LoadingOverlay("hide");
    });
 
    $('#sel_project').select2({
         matcher: function(params, data) {
            if ($.trim(params.term) === '') {
                return data;
            }

            var searchTerm = params.term.trim().toLowerCase().replace(/-/g, '');
            var optionText = (data.text || '').toLowerCase().replace(/-/g, '');

            if (optionText.indexOf(searchTerm) > -1) {
                return data;
            }

            return null; 
        }
    });
    
});


  function searchDocHD() {
     if (!validDate()) {
        return false;
     }
     $.LoadingOverlay("show");
     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Reprint_Pay_List.jsp";
     document.forms[0].submit();  
  }

  function changePage(page) {
     pleaseWaiting();
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Reprint_Pay_List.jsp";
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
  
  function pleaseWaiting(){
   $.LoadingOverlay("show");
	// Hide it after 3 seconds
	setTimeout(function(){
	    $.LoadingOverlay("hide");
	}, 3000);
  }
//-->
</script>

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
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            พิมพ์ใบแจ้งซ่อมแก้ไขโดยผู้รับเหมา</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดการแจ้งซ่อม</td>
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
    <%=common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:250px' ",true)%>       
    </td>
    <td height="22" class="item ; dotline01" width="14%">เลขที่ใบแจ้งซ่อม
      :</td>
    <td height="22" width="26%" class="dotline01"><input type="text" name="i_docno" class="box" style="width:100px" value="<%=docNo%>"></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="15%">บ้านเลขที่
      :</td>
    <td height="22" width="45%" class="dotline01"><input type="text" name="i_house" class="box" style="width:100px" value="<%=houseId%>"></td>
    <td height="22" class="item ; dotline01" width="14%">แปลง :</td>
    <td height="22" width="26%" class="dotline01"> <input type="text" name="i_lock" class="box" style="width:100px" value="<%=lock%>"></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="11%">วันที่แจ้งซ่อม
      :</td>
    <td height="22" width="45%" class="dotline01">
    <%=common.genDateListbox("start",request," class='box' ")%> &nbsp; ถึง &nbsp; 
    <%=common.genDateListbox("end",request," class='box' ")%>
    </td>
    <td height="22" class="item ; dotline01" width="14%">สถานะ :</td>
    <td height="22" width="26%" class="dotline01"> 
    <select size="1" class="box" style="width:100px" name="job_status">
        <option value=''>ทุกสถานะ</option>
        <option value='400' <%=jobStatus.equals("400") ? " selected " : ""%>>Contractor</option>
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
          <td width="14%" class="col_name">เลขที่ใบแจ้งซ่อม</td>
          <td width="7%" class="col_name">แปลง</td>
          <td width="8%" class="col_name">บ้านเลขที่</td>
          <td width="16%" class="col_name">วันเวลาที่แจ้ง</td>
          <td width="30%" class="col_name">ชื่อผู้แจ้ง /
            ลูกค้า</td>
          <td width="13%" class="col_name">สถานะ</td>
          <td width="16%" class="col_name">โทรศัพท์ติดต่อ</td>
        </tr>
        
        
        <%
			String status = "";
			String iDocNo = "";
			String iLock = "";
			String iHouse = "";
			//String iLor = "";
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


		     //----================== Select Data from SERV_DOCHD ================----//   
		        int line = 0;		 
		        sql.delete(0,sql.length());				
		        sql.append(" select case when a.i_doc_type='I' then 'INFORM' else 'OPEN' end status, ")
		              .append(" b.i_house,b.i_lor,c.i_exp_intent1,c.i_cus_intent1,a.* from serv_dochd a ")
					  .append(" left join lan:acxlckmd b on b.i_company=a.i_company and b.i_project=a.i_project and b.i_lock=a.i_lock ")
					  .append(" left join lan:acscontr c on c.i_company=a.i_company and c.i_project=a.i_project and c.i_lor=b.i_lor and c.f_contr is null ")
					  .append(" where a.f_status in ('OPN','CLS') and a.i_doc_type = 'J' and (a.i_docno in ( ")
					  .append(" select  i_docno from serv_payment e where f_itmstatus<>'CAN' ")
					  .append(subcondition)
					  .append(" group by i_docno ").append(condition2).append(" )) ")
					  .append(condition)
					  .append(" order by 6 ");
/*
		        sql.delete(0,sql.length());
		        sql.append(" select case when a.i_doc_type='I' then 'INFORM' else 'OPEN' end status, ")
		              .append(" b.i_house,b.i_lor,c.i_exp_intent1,c.i_cus_intent1,a.* from serv_dochd a ")
		              .append(" left join lan:acxlckmd b on b.i_company=a.i_company and b.i_project=a.i_project and b.i_lock=a.i_lock ")
		              .append(" left join lan:acscontr c on c.i_company=a.i_company and c.i_project=a.i_project and c.i_lor=b.i_lor and c.f_contr is null ")
		              .append(" where a.f_status in ('OPN','CLS') and ( ");
		         if (jobStatus.equals("100")) {
		            //sql.append("(a.i_doc_type='I') ");
		         } else {     
			         sql.append(" (a.i_docno in ( ")
			              .append(" select d.i_docno from serv_dochd d,serv_payment e ")
			              //.append(" where ((e.i_docno=d.i_docno) or (d.i_doc_type='I')) ")
			              .append(" where ((e.i_docno=d.i_docno) ");
				 if (jobStatus.trim().length()<=0) {
				    //sql.append(" or (d.i_doc_type='I') ");
			 	 }
		   		sql.append(" ) and e.f_itmstatus<>'CAN' group by d.i_docno ")
			              .append(condition2).append(")) ");
		         }
		        sql.append(" ) ").append(condition)
		              .append(" order by a.i_docno ");
*/
				servlog.startLog(sql.toString());
		        rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
		        for (int i=0;i<maxRow;i++) { 
                      if (rs.next()) {
                         if (i>=startRow && i<=endRow) {
                            //------ Data is in this page , display -----//
				            status = doString.checkString(doString.DisplayThai(rs.getString("status")),"");
				            iDocNo = doString.checkString(rs.getString("i_docno"),"");
				            iLock = doString.checkString(rs.getString("i_lock"),"-");
				            iHouse = doString.checkString(rs.getString("i_house"),"-");
				            //iLor = doString.checkString(rs.getString("i_lor"),"");
				            nCustomer = doString.checkString(doString.DisplayThai(rs.getString("n_customer")),"");
				            nCustTel = doString.checkString(doString.DisplayThai(rs.getString("n_cus_tel")),"");
				            iDocType = doString.checkString(rs.getString("i_doc_type"),"");
				            iCompany = doString.checkString(rs.getString("i_company"),"");
				            iProject = doString.checkString(rs.getString("i_project"),"");

							
							tmpCust = common.getCustomerDetails(iCompany,iProject,iLock);
							ownName = doString.DisplayThai(doString.checkString((String) tmpCust.get("n_customer"),""));
							ownTel = doString.DisplayThai(doString.checkString((String) tmpCust.get("n_cust_tel"),""));
					    				            
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
						       //---=================== Inform Status ==================---//
						       jspLink = "SERV_InfJob_Disp.jsp?i_docno="+iDocNo;
						       status = "New Task";
						    } else {
						       jspLink = "SERV_OpenJob_Pay_Disp.jsp?i_docno="+iDocNo;
							   status = "";
							   tmpStat = "";

						       sql.delete(0,sql.length());
						       sql.append(" select distinct f_itmstatus from serv_payment where f_itmstatus<>'CAN' ")
						             .append(" and i_docno='").append(iDocNo).append("' ")
								     .append(" order by f_itmstatus ");
							   servlog.startLog(sql.toString());
						       rs1 = stmt1.executeQuery(sql.toString());
							   servlog.endLog();
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
					          <td width="7%" class="dotline" align="center"><%=doString.checkString(iLock)%></td>
					          <td width="8%" class="dotline" align="center"><%=doString.checkString(iHouse)%></td>
					          <td width="16%" align="center" class="dotline"><%=keyinDate%></td>
					          <td width="30%" class="dotline ; item"><%=common.joinContactAndOwner(nCustomer,ownName)%></td>
					          <td width="13%" align="center" class="dotline"><%=status%></td>
					          <td width="16%" align="center" class="dotline"><%=common.joinContactAndOwner(nCustTel,ownTel)%></td>
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
			          <td width="7%" class="dotline" align="center">&nbsp;</td>
			          <td width="8%" class="dotline" align="center">&nbsp;</td>
			          <td width="16%" align="center" class="dotline">&nbsp;</td>
			          <td width="30%" class="dotline ; item">&nbsp;</td>
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
<%         System.out.println("----- SERV_Reprint_Pay_List.jsp -------");
	} catch (Exception e) {
		System.out.println("ERROR SERV_Reprint_Pay_List.jsp : " + e.getMessage());
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