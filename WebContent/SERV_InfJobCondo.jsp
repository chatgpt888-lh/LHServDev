<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="serv.common.Constants" %>
<%@page import="serv.common.User" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_InfJobCondo.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   doString str = new doString();

   String toDate = getDateFromCalendar(Calendar.getInstance())+"&nbsp;"+getTimeFromCalendar(Calendar.getInstance());
   String mode = doString.checkString(request.getParameter("mode"),"add");
   String load = doString.checkString(request.getParameter("load"),"");
   String iDocNo = doString.checkString(request.getParameter("i_docno"),"");
   String searchCust = doString.checkString(request.getParameter("search_cust"),"");   
   String foundCust = "";

   //----============ Declare Variables for input data ===========----//
   String selProj = doString.checkString(request.getParameter("sel_project"),"");
   if  (selProj.length()==0) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       session.setAttribute("sess_sel_proj",selProj);
   }

   String houseId = doString.checkString(request.getParameter("house_id"),"");
   String iLock = doString.checkString(request.getParameter("i_lock"),"").toUpperCase();
   String nCustomer = doString.checkString(request.getParameter("n_customer"),"");
   String nCustTel = doString.checkString(request.getParameter("n_cust_tel"),"");
   String cDesc = doString.checkString(request.getParameter("c_desc"),"");
   cDesc = str.replace(cDesc,"|break|","\r\n");

   
   //-----========= Declare Variables for Search Custoemr ===========----//
   String housePlan = "-";
   String custName = "-";
   String custTel = "-";
   String guranteeDesc = "-";
   String guranteeDate = "-";
   String iCustomer = "";
   String guranteeOk = "";
   Calendar gurantee = null;
   String projName = "-";
			       
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
        
        
        if (iDocNo.length()>0 && mode.equalsIgnoreCase("EDIT")) {
            sql.delete(0,sql.length());
            sql.append(" select * from lan:serv_dochd where i_docno='").append(iDocNo).append("' ");
			servlog.startLog(sql.toString());
            rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
            if (rs.next()) {
                selProj = doString.checkString(rs.getString("i_company"),"");
                selProj += ":"+doString.checkString(rs.getString("i_project"),"");
			    houseId = "";
			    iLock = doString.checkString(rs.getString("i_lock"),"").toUpperCase();
			    
			    if (load.equalsIgnoreCase("YES")) {
			        //------ Load in first time only ---------//
				    nCustomer = doString.checkString(doString.DisplayThai(rs.getString("n_customer")),"");
				    nCustTel = doString.checkString(doString.DisplayThai(rs.getString("n_cus_tel")),"");
				    cDesc = doString.checkString(doString.DisplayThai(rs.getString("c_desc")),"");
				    cDesc = str.replace(cDesc,"|break|","\n");
			    }
            }
            rs.close();
            
			String com = selProj.length()>=6 ? selProj.substring(0,2) : "";
			String proj = selProj.length()>=6 ? selProj.substring(3,6) : "";
            sql.delete(0,sql.length());
            sql.append(" select * from lan:acxprojt where i_company='"+com+"'  and i_project='"+proj+"' ");
			servlog.startLog(sql.toString());
            rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
            if (rs.next()) {
               projName = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
            }
            rs.close();            
            
            searchCust = "YES";
        }
        

	   if (searchCust.equalsIgnoreCase("YES")) {
			//----======================= Get Customer Details ===========================----//	  
			String iCompany = "";
			String iProject = "";
			if (selProj.indexOf(":")>0) {
			   iCompany = selProj.substring(0,selProj.indexOf(":"));
			   iProject = selProj.substring(selProj.indexOf(":")+1);
			}
			 
			Hashtable tmpCust = common.getCustomerDetails(iCompany,iProject,iLock,houseId);
		    housePlan = doString.DisplayThai(doString.checkString((String) tmpCust.get("i_model"),""));
		    houseId = doString.DisplayThai(doString.checkString((String) tmpCust.get("i_house"),houseId));
		    iLock = doString.checkString((String) tmpCust.get("i_lock"),iLock);
		    iCustomer = doString.checkString((String) tmpCust.get("i_customer"),"");
			guranteeDesc = doString.DisplayThai(doString.checkString((String) tmpCust.get("gurantee_desc"),"-"));
			guranteeDate = doString.DisplayThai(doString.checkString((String) tmpCust.get("gurantee_date"),"-"));
			custName = doString.DisplayThai(doString.checkString((String) tmpCust.get("n_customer"),""));
			custTel = doString.DisplayThai(doString.checkString((String) tmpCust.get("n_cust_tel"),""));	
			guranteeOk = doString.DisplayThai(doString.checkString((String) tmpCust.get("gurantee_ok"),""));	
			foundCust = doString.DisplayThai(doString.checkString((String) tmpCust.get("found_cust"),""));	

	   } // end if search customer	   
   
%>

<HTML>
<HEAD>
<TITLE>Add Inform Job</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">
<!--
 
  function searchCust() {
      var forms = document.forms[0];
      if (forms.house_id.value=="" && forms.i_lock.value=="") {
         alert(" กรุณากรอก บ้านเลขที่ หรือ แปลง อย่างน้อย  1 ตัว !");
      } else {
         forms.search_cust.value="YES";
         forms.action="<%=Constants.APP_PATH%>/SERV_InfJobCondo.jsp";
         forms.submit();
      }
  }
  
  function validateCustData() {
     var forms = document.forms[0];

      if (forms.house_id.value=="") {
         alert(" กรุณากรอกบ้านเลขที่ !");
         forms.house_id.focus();
         return false;
      }

      if (forms.i_lock.value=="") {
         alert(" กรุณากรอกเลขที่แปลง !");
         forms.i_lock.focus();
         return false;
      }

      if (forms.found_cust.value.toUpperCase()!="YES") {
         alert(" กรุณาทำการดึงข้อมูลลูกค้าที่ต้องการ เพื่อทำการตรวจสอบก่อน !");
         return false;
      }

	  return true;
  }
  
  function saveInform() {
     if (!validateCustData())  {
	     return false;
	 }

     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_InfJobServlet?who=J";
     document.forms[0].submit();
  }  
  
  function resetSearch() {
      document.forms[0].search_cust.value="";
      document.forms[0].found_cust.value="";
  }
  
  function openNewJob() {
     if (!validateCustData())  {
	     return false;
	 }

     var forms = document.forms[0];
     forms.action="<%=Constants.APP_PATH%>/SERV_OpenJob.jsp";
     forms.submit();    
  }
 
//-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM method="POST" action="">

<input type="hidden" name="mode" value="<%=mode%>">
<input type="hidden" name="search_cust" value="">
<input type="hidden" name="found_cust" value="<%=foundCust%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            Inform Job</td>
          <td width="50%" align="right">&nbsp;</td>
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
<%
   if (mode.equalsIgnoreCase("ADD")) {
		%>
		  <tr>
		    <td class="item ; dotline01" height="22" width="13%">โครงการ :</td>
		    <td height="22" width="39%" class="dotline01"> 












		    <%=common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:250px' onchange='resetSearch();' ")%>
		    </td>
		    <td height="22" class="item ; dotline01" width="14%">เลขที่ใบแจ้งซ่อม :</td>
		    <td height="22" width="34%" class="dotline01"><span style="width:100px">Auto Generated</span></td>
		  </tr>
		  <tr>
		    <td class="item ; dotline01" height="22" width="13%">บ้านเลขที่ :</td>
		    <td height="22" width="39%" class="dotline01">
		    <input type="text" name="house_id" class="box" style="width:100px" value="<%=houseId%>" onchange='resetSearch();'></td>
		    <td height="22" class="item ; dotline01" width="14%">แปลง :</td>
		    <td height="22" width="34%" class="dotline01"> 
		    <input type="text" name="i_lock" class="box" style="width:100px" value="<%=iLock%>" onchange='resetSearch();'>&nbsp;&nbsp;
		      <a href='#' onclick='searchCust();'><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a> </td>
		  </tr>
		  <%
  } else {
		%>
		  <tr>
		    <td class="item ; dotline01" height="22" width="13%">โครงการ :</td>
		    <td height="22" width="39%" class="dotline01">
		    <%=projName%>
		    <input type="hidden" name="sel_project" value="<%=selProj%>">
		    </td>
		    <td height="22" class="item ; dotline01" width="14%">เลขที่ใบแจ้งซ่อม :</td>
		    <td height="22" width="34%" class="dotline01">
		    <span style="width:100px"><%=iDocNo%></span>
		    <input type="hidden" name="i_docno" value="<%=iDocNo%>">
		    </td>
		  </tr>
		  <tr>
		    <td class="item ; dotline01" height="22" width="13%">บ้านเลขที่ :</td>
		    <td height="22" width="39%" class="dotline01">
		    <%=houseId%>
		    <input type="hidden" name="house_id" value="<%=houseId%>">
		    </td>
		    <td height="22" class="item ; dotline01" width="14%">แปลง :</td>
		    <td height="22" width="34%" class="dotline01"> 
		    <%=iLock%>
		    <input type="hidden" name="i_lock" value="<%=iLock%>">
            </td>
		  </tr>
		  <%  
  } // end if mode
  %>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">แบบบ้าน :</td>
    <td height="22" width="39%" class="dotline01"><%=doString.checkString(housePlan,"-")%></td>
    <td height="22" class="item ; dotline01" width="14%">&nbsp;</td>
    <td height="22" width="34%" class="dotline01">&nbsp;</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ชื่อลูกค้า
      :</td>
    <td height="22" width="39%" class="dotline01"><%=doString.checkString(custName,"-")%></td>
    <td height="22" class="item ; dotline01" width="14%">โทรศัพท์ติดต่อ
      :</td>
    <td height="22" width="34%" class="dotline01"><%=doString.checkString(custTel,"-")%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">การประกัน
      :</td>
    <td height="22" width="39%" class="dotline01"><%=guranteeDesc%></td>
    <td height="22" class="item ; dotline01" width="14%">วันที่หมดประกัน
      :</td>
    <td height="22" width="34%" class="dotline01"><%=doString.checkString(guranteeDate,"-")%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ผู้รับเรื่อง
      :</td>
    <td height="22" width="39%" class="dotline01"><%=doString.DisplayThai(doString.checkString(user.getEmpName(),"-"))%></td>
    <td height="22" class="item ; dotline01" width="14%">วันเวลาที่แจ้ง
      :</td>
    <td height="22" width="34%" class="dotline01"><%=doString.checkString(toDate,"-")%></td>
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
                <td class="item_tab2" width="200">รายละเอียดผู้แจ้งซ่อม</td>
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
    <td class="item ; dotline01" height="22" width="13%">ชื่อผู้แจ้ง
      :</td>
    <td height="22" width="39%" class="dotline01">
    <input type="text" name="n_customer" class="box" style="width:300px" value="<%=nCustomer%>" size='50' maxlength='50'></td>
    <td height="22" class="item ; dotline01" width="14%">โทรศัพท์ติดต่อ
      :</td>
    <td height="22" width="34%" class="dotline01">
    <input type="text" name="n_cust_tel" class="box" style="width:200px" value="<%=nCustTel%>" size='20' maxlength='20'></td>
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
                <td class="item_tab2" width="200">กรุณาระบุรายละเอียดงานซ่อม</td>
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
    <td width="100%" class="frmLRpad01">
 	    <textarea name="c_desc" class="box" style="width:960px;height:200px" maxlength="255"><%=cDesc%></textarea>
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

            <a href="#" onclick="saveInform();"><img border="0" src="images/act_submit.gif"                                   
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

<%
  if (guranteeOk.length()>0 && !guranteeOk.equalsIgnoreCase("YES")) {
     %>
     <script>
           alert("..แปลงที่ระบุยังไม่โอน ไม่สามารถทำรายการได้..");
           document.forms[0].found_cust.value='';
     </script>
     <%
  }

  if (foundCust.trim().length()>0 && (custName.trim().length()<=0 || custName.equals("-"))) {
     %>
     <script>
           alert("ข้อมูลมีปัญหา ไม่พบชื่อลูกค้า , กรุณาตรวจสอบข้อมูลใหม่อีกครั้ง !!");
           document.forms[0].found_cust.value='';
     </script>
     <%
  }  

  if (searchCust.equalsIgnoreCase("YES") && foundCust.trim().length()==0) {
     %>
     <script>
           alert("ไม่พบข้อมูล [บ้านเลขที่ / แปลง] ที่ค้นหา , กรุณาตรวจสอบข้อมูลใหม่อีกครั้ง !!");
           document.forms[0].found_cust.value='';
     </script>
     <%
  }  
%>
	
</BODY>

</HTML>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_InfJobCondo.jsp : " + e.getMessage());
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