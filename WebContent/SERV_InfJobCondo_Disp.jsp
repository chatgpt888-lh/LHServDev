<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_InfJobCondo_Disp.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   doString str = new doString();


   //----============ Declare Variables for input data ===========----//
   String iDocNo = doString.checkString(request.getParameter("i_docno"),"");
   String popup = doString.checkString(request.getParameter("popup"),"");
   String emp_serv = "", name_serv = "";
   
   
   //-----========= Declare Variables for OpenJob Page ===========----//
   String mode = doString.checkString(request.getParameter("mode"),"edit");
   String load = doString.checkString(request.getParameter("load"),"yes");
   String dAppoint= doString.checkString(request.getParameter("d_appoint"),"");
   String dEstClose= doString.checkString(request.getParameter("d_est_close"),"");   
   ItmJobManagement itm = new ItmJobManagement(request,response);
   itm.updateValuesFromRequest(); // update new values from request.
   itm.updateItemSession(); // update session before use
  //---=======================================================----//   
   
   
   
   //-----========= Declare Variables for Search Custoemr ===========----//
   String selProj = "";
   String iCompany = "";
   String iProject = "";
   String projDesc = "";
   String houseId = "";
   String iLock = "";
   String nCustomer = "";
   String nCustTel = "";
   String cDesc = "";   
   String inFormDate = "";
   String inFormEmp = "";
      
   String housePlan = "-";
   String custName = "-";
   String custTel = "-";
   String guranteeDesc = "-";
   String guranteeDate = "-";
   String iCustomer = "";
			       
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	SERV_CommonData common = null;

	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();        
		common = new SERV_CommonData(conn);
        //----=======================================----//   
        

	   if (iDocNo.length()>0) {

	        //----======================== Find DocHD Data =============================----//
			 Hashtable tmpHeader = common.getDocHeaderDetails(iDocNo);
		     inFormEmp = doString.DisplayThai(doString.checkString((String) tmpHeader.get("inform_emp"),""));
	         projDesc = doString.DisplayThai(doString.checkString((String) tmpHeader.get("proj_desc"),""));
	         iCompany = doString.checkString((String) tmpHeader.get("i_company"),"");
	         iProject = doString.checkString((String) tmpHeader.get("i_project"),"");
	         selProj = iCompany+":"+iProject;
	         nCustomer = doString.DisplayThai(doString.checkString((String) tmpHeader.get("n_customer"),""));
	         nCustTel = doString.DisplayThai(doString.checkString((String) tmpHeader.get("n_cust_tel"),""));
	         iLock = doString.checkString((String) tmpHeader.get("i_lock"),"");
	         cDesc = doString.DisplayThai(doString.checkString((String) tmpHeader.get("c_desc"),""));
	         cDesc = str.replace(cDesc,"|break|","<br>");
	         cDesc = str.replace(cDesc," ","&nbsp;"); 			
			 inFormDate = doString.DisplayThai(doString.checkString((String) tmpHeader.get("inform_date"),""));
						

			//----======================= Get Customer Details ===========================----//
			Hashtable tmpCust = common.getCustomerDetails(iCompany,iProject,iLock);
		    housePlan = doString.checkString((String) tmpCust.get("i_model"),"");
		    houseId = doString.checkString((String) tmpCust.get("i_house"),"");
		    iLock = doString.checkString((String) tmpCust.get("i_lock"),"");
		    iCustomer = doString.checkString((String) tmpCust.get("i_customer"),"");
			guranteeDesc = doString.DisplayThai(doString.checkString((String) tmpCust.get("gurantee_desc"),""));
			guranteeDate = doString.DisplayThai(doString.checkString((String) tmpCust.get("gurantee_date"),""));
			custName = doString.DisplayThai(doString.checkString((String) tmpCust.get("n_customer"),""));
			custTel = doString.DisplayThai(doString.checkString((String) tmpCust.get("n_cust_tel"),""));

	   } // end if search Data 

		//----------------------------- Name who = J ------------------------
		sql.delete(0, sql.length());
		sql.append("select distinct i_service_employ ")
			 .append("from lan:serv_dochd ")
			 .append("where i_docno = '"+iDocNo+"' ");		
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		if (rs.next()) {
			emp_serv = doString.checkString(rs.getString("i_service_employ"));
		}                       
					 
		name_serv = "";			
		if (emp_serv.trim().length()>4) {
					sql.delete(0, sql.length());
					sql.append("select distinct i_employ, n_prename_th, n_nemploy_th, n_semploy_th ")
						 .append("from docflow:acemploy ")
						 .append("where i_employ = '"+emp_serv+"' ");		
					servlog.startLog(sql.toString());
					rs = stmt.executeQuery(sql.toString());
					servlog.endLog();
					if (rs.next()) {
						name_serv = doString.checkString(doString.DisplayThai(rs.getString("n_prename_th")))+doString.checkString(doString.DisplayThai(rs.getString("n_nemploy_th")))+" "+doString.checkString(doString.DisplayThai(rs.getString("n_semploy_th")));
					}	
		} else {
	
					sql.delete(0, sql.length());
					sql.append("select distinct i_cust, n_name, n_sname ")
						 .append("from lan:serv_cname ")
						 .append("where i_cust = '"+emp_serv+"' ");		
					servlog.startLog(sql.toString());
					rs = stmt.executeQuery(sql.toString());
					servlog.endLog();
					if (rs.next()) {
						name_serv = doString.checkString(doString.DisplayThai(rs.getString("n_name")))+" "+doString.checkString(doString.DisplayThai(rs.getString("n_sname")));
					}				
		}//end if chk emp_serv
   
%>

<HTML>
<HEAD>
<TITLE>Add Inform Job - Display</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--

function openJob() {
   document.forms[0].action="SERV_OpenJob.jsp?load=<%=load%>";
   document.forms[0].target="";   
   document.forms[0].submit();
}

function editInfJob() {
   document.forms[0].action="SERV_InfJobCondo.jsp?load=yes";
   document.forms[0].target="";   
   document.forms[0].submit();
}

function printInfJob() {
   document.forms[0].action="<%=Constants.APP_PATH%>/SERV_PrintInfJobServlet?who=J&emp_serv=<%=emp_serv%>";
   document.forms[0].target="_blank";
   document.forms[0].submit();
}

function cancelJob() {
   if (confirm(" คุณแน่ใจว่าต้องการยกเลิก Inform Job ใบนี้ ?")) {
       document.forms[0].mode.value="CANCEL";
	   document.forms[0].action="<%=Constants.APP_PATH%>/SERV_InfJobServlet";
	   document.forms[0].target="";
	   document.forms[0].submit();
   }
}

//-->
</script>


<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">

<input type="hidden" name="mode" value="<%=mode%>">
<input type="hidden" name="i_docno" value="<%=iDocNo%>">
<input type="hidden" name="d_appoint" value="<%=dAppoint%>">
<input type="hidden" name="d_est_close" value="<%=dEstClose%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            Inform Job</td>
          <td width="50%" align="right">&nbsp;</td></tr>
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
    <td class="item ; dotline01" height="22" width="13%">โครงการ :</td>
    <td height="22" width="39%" class="dotline01"><%=projDesc%></td>
    <td height="22" class="item ; dotline01" width="14%">เลขที่ใบแจ้งซ่อม
      :</td>
    <td height="22" width="34%" class="dotline01"><%=iDocNo%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">บ้านเลขที่ :</td>
    <td height="22" width="39%" class="dotline01"><%=houseId%></td>
    <td height="22" class="item ; dotline01" width="14%">แปลง :</td>
    <td height="22" width="34%" class="dotline01"><%=iLock%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">แบบบ้าน :</td>
    <td height="22" width="39%" class="dotline01"><%=housePlan%></td>
    <td height="22" class="item ; dotline01" width="14%">&nbsp;</td>
    <td height="22" width="34%" class="dotline01">&nbsp;</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ชื่อผู้แจ้ง/ลูกค้า
      :</td>
    <td height="22" width="39%" class="dotline01"><%=common.joinContactAndOwner(nCustomer,custName)%></td>
    <td height="22" class="item ; dotline01" width="14%">โทรศัพท์ติดต่อ :</td>
    <td height="22" width="34%" class="dotline01"><%=common.joinContactAndOwner(nCustTel,custTel)%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">การประกัน :</td>
    <td height="22" width="39%" class="dotline01"><%=guranteeDesc%></td>
    <td height="22" class="item ; dotline01" width="14%">วันที่หมดประกัน
      :</td>
    <td height="22" width="34%" class="dotline01"><%=guranteeDate%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ผู้รับเรื่อง
      :</td>
    <td height="22" width="39%" class="dotline01"><%=name_serv%></td>
    <td height="22" class="item ; dotline01" width="14%">วันเวลาที่แจ้ง
      :</td>
    <td height="22" width="34%" class="dotline01"><%=inFormDate%></td>
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
                <td class="item_tab2" width="200">รายละเอียดงานซ่อม</td>
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
    <td width="100%" class="frmLRpad01"><%=cDesc%></td>
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
            <td width="260" class="act_tab2">

  <%
      if (!popup.equalsIgnoreCase("Y")) {
	  %>
            <img border="0" src="images/act_edit.gif"  onclick="editInfJob();"                                 
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">&nbsp; 
          <% 
      }
  %>
           <img border="0" src="images/act_printinformjob.gif" onclick="printInfJob();"                                  
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand" width="70" height="27">
            &nbsp; &nbsp; &nbsp; &nbsp; 
  <%
      if (!popup.equalsIgnoreCase("Y")) {
	  %>
           <img border="0" src="images/act_cancel.gif" onclick="cancelJob();"                                  
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand" width="70" height="27">
            </td>   
          <% 
      }
  %>                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4">
          <%
              if (popup.equalsIgnoreCase("Y")) {
                  %>
                   <a href="javascript:top.window.close()"><img border="0" src="images/bu_close.gif" align="top" width="50" height="15"></a> 
                  <%
              } else {
                  %>
		           <a href="<%=Constants.APP_PATH%>/SERV_Reprint_List.jsp" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
		           <a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a>                
                  <%
              }
           %>                        
          </td></tr>  
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
		System.out.println("ERROR SERV_InfJobCondo_Disp.jsp : " + e.getMessage());
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