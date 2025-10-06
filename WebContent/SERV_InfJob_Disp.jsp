<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%!
/**
 * Modify by : pradoem@lh.co.th
 * date : 2015.05.13
 * version 1.1
 * desc:  add cause popup for cancel
 */
//Fix name CauseDDL
   public String GenCauseHtmlDDL(Connection conn,String name, String value, String params){
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try {
            stmt = conn.createStatement();
            sql.append(" select i_type,i_code,n_desc  from lan:serv_xstd where i_type='55' ").append(" order by i_type,i_code,n_desc  ");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(name).append("' ").append(params).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            String iCode;
            String nDesc;
            String selected;
            for(; rs.next(); html.append("<option value='").append(iCode).append("' ").append(selected).append(">").append(nDesc).append("</option>")) {
                iCode = doString.checkString(rs.getString("i_code"), "");
                nDesc = doString.checkString(doString.DisplayThai(rs.getString("n_desc")), "");
                selected = "";
                if(value != null && iCode.equalsIgnoreCase(value)){
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
        }catch(Exception e) {
            System.out.println("  GenCauseHtmlDDL Error : " + e.getMessage());
        } finally{
            try  {
                if(rs != null) {
                    rs.close();
                }
                if(stmt != null){
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }
  
     /**** For condominium repair 2015.06.24 ****/ 
     public String[] GetCondoProfile(Connection conn,String comId,String projId){
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;

		boolean isCondo = false;
        String tempStr[] = new String[] {"","","","","","",""}; //"YES,NO","LH","075","2015-06-24","Y,N","หมดประกัน/อยู่ระหว่างประกัน","0841013129"
        java.sql.Timestamp dCloseLaw = null;
        try {
            stmt = conn.createStatement();
            /*1. Check project is Condo avaliable ?*/
  			sql.delete(0, sql.length());
			sql.append(" Select i_company,i_project,d_close_law,d_close_law-today as x  ")
				.append(" From  lan:serv_condo ")
				.append(" Where i_company  = '"+comId+"'  ")
				.append(" and i_project = '"+projId+"' ");

				//System.out.println("SQL GetCondo  :"+sql.toString());
				rs = stmt.executeQuery(sql.toString());    				   
			    if(rs.next()){
			       tempStr[0] = "YES";
			       tempStr[1] = doString.checkString(rs.getString("i_company"),"");
			       tempStr[2] = doString.checkString(rs.getString("i_project"),"");
			       //tempStr[3] = doString.checkString(rs.getString("d_close_law"),"");
			       dCloseLaw = rs.getTimestamp("d_close_law");	
			       
			        Calendar gurantee = Calendar.getInstance();
                    gurantee.setTime(dCloseLaw);
                   // gurantee.add(1, 1);       
                    if(rs.getInt("x")>0) {
						tempStr[4] = "Y";
	                    tempStr[5] = doString.DisplayThai(doString.UnicodeToMS874("อยู่ระหว่างประกัน"));
                    } else{
	                    tempStr[4] = "N";
	                    tempStr[5] = doString.DisplayThai(doString.UnicodeToMS874("หมดประกัน"));
                    }
                    tempStr[3] = getDateFromCalendar(gurantee);
			        isCondo = true;       
			    }else{
				    tempStr[0] = "NO";
				    tempStr[2] = "";
				    tempStr[3] ="";
				    tempStr[4] ="";
			    }
 				/** CASE : Condo = true **/
 				if(isCondo){					
	 				sql.delete(0, sql.length());
					sql.append(" Select i_tel ")
						.append(" From  lan:serv_prjdt ")
						.append(" Where i_company  = '"+comId+"'  ")
						.append(" and i_project = '"+projId+"' ");
						//System.out.println("SQL I_tel  :"+sql.toString());
					rs = stmt.executeQuery(sql.toString());    				   
				    if(rs.next()){
				    	tempStr[6] =  doString.checkString(rs.getString("i_tel"),"");
	 				}//#RS.Close
	 			}	  
                rs.close();
                stmt.close();
                
        }catch(Exception e) {
            System.out.println("!!! GetCondoProfile[]  Error : " + e.getMessage());
        } finally{
            try  {
                if(rs != null) {
                    rs.close();
                }
                if(stmt != null){
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }       
        return tempStr;
    }  
 
   /** For DDL เก็บประกันงานซ่อม 2015.06.25 **/ 
     public String GenInformTypeHtmlDDL(Connection conn,String name, String value, String params){
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try {
            stmt = conn.createStatement();
            sql.append(" select i_type,i_code,n_desc  from lan:serv_xstd where i_type='98' ").append(" order by i_type,i_code,n_desc  ");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(name).append("' ").append(params).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            String iCode;
            String nDesc;
            String selected;
            for(; rs.next(); html.append("<option value='").append(iCode).append("' ").append(selected).append(">").append(nDesc).append("</option>")) {
                iCode = doString.checkString(rs.getString("i_code"), "");
                nDesc = doString.checkString(doString.DisplayThai(rs.getString("n_desc")), "");
                selected = "";
                if(value != null && iCode.equalsIgnoreCase(value)){
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
        }catch(Exception e) {
            System.out.println("  GenInformTypeHtmlDDL Error : " + e.getMessage());
        } finally{
            try  {
                if(rs != null) {
                    rs.close();
                }
                if(stmt != null){
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }  
    
    public static  String removeNull(String str){
		 if ((str == null) || str.equals("")) {
			 return  "";
		 }else{
			 return  str;
		 }
	}

 %>
<%

/*String ParameterNames = "";
for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
	ParameterNames = (String)e.nextElement();
	System.out.println(ParameterNames + " = "+request.getParameter(ParameterNames));
}
System.out.println("*******************************************");
System.out.println("******************xxxxxxxxxx*************************");

*/
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_InfJob_Disp.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);
   doString str = new doString();
   //----============ Declare Variables for input data ===========----//
   String iDocNo = doString.checkString(request.getParameter("i_docno"),"");
   String popup = doString.checkString(request.getParameter("popup"),"");
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
   String dAppointCust = "";
   String iSystem = "";
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
   String name_serv = "";
   String emp_serv = "";
   String chk_condo = "";
   String  InformTypeDDL = "";
   String fromTime = "";
   boolean openjob = true; 
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	SERV_CommonData common = null;
	try {
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		//conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		//conn.setAutoCommit(true);
		
		conn.setAutoCommit(true);	
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);//informix
		
		stmt = conn.createStatement();        
		common = new SERV_CommonData(conn);
        //----=======================================----//  
        
         
        /** Last Update 2015.06.24 For Repair Condo ***/
        String tempArr[] = new String[] {"",""};
        if(iDocNo.length()>0){
           tempArr  = iDocNo.split("\\-");
        }
        String condoProfileArr[] = GetCondoProfile(conn,removeNull(tempArr[0]),removeNull(tempArr[1]));
        //---------------------------------------------------------------------

         
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
	         	
			dAppointCust = doString.checkString((String) tmpHeader.get("d_appoint_cust"),"");
			iSystem = doString.checkString((String) tmpHeader.get("i_system"),"");
			InformTypeDDL = doString.checkString((String) tmpHeader.get("i_warranty"),"");
			
			 fromTime  = doString.checkString((String) tmpHeader.get("time"),"");
			//fetch  f_garantee  01,02...
		if (cDesc.equals("Checkup Program")) {
			openjob = false;
		}
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

			//----------------------------- Project Condo ------------------------
			sql.delete(0, sql.length());
			sql.append("select i_company, i_project ")
				 .append("from lan:serv_condo ")
				 .append("where i_company = '"+iCompany+"' ")
				 .append("and i_project = '"+iProject+"' ");
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			if (rs.next()==true) {
				chk_condo = "Y";
			} else {
				chk_condo = "N";
			}
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
			}
		}// end if search Data 
		
		
		/*   System.out.println("nCustomer = "+doString.DisplayThai(nCustomer));
		   System.out.println("custName = "+doString.DisplayThai(custName));
		   System.out.println("nCustTel = "+doString.DisplayThai(nCustTel));
		   System.out.println("custTel = "+doString.DisplayThai(custTel));*/
              
%>
<HTML>
<HEAD>
<TITLE>Add Inform Job - Display</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
<!--
<% /* From Follow */ 
String from_page = doString.checkString(request.getParameter("from_page"),"");
if(!"".equals(from_page)){
	from_page = "/LHServ/"+from_page+"?sel_project="+iCompany+":"+iProject+"&i_docno="+iDocNo+"&itmtype="+doString.checkString(request.getParameter("itmtype"),"");
}
%>
function openJob() {
    MM_showLayersCanBox(false); 
   document.forms[0].action="SERV_OpenJob.jsp?load=<%=load%>";
   document.forms[0].target="";   
   document.forms[0].submit();
}
function editInfJob() {
    MM_showLayersCanBox(false); 
   document.forms[0].action="SERV_InfJob.jsp?load=yes";
   document.forms[0].target="";   
   document.forms[0].submit();
}
function printInfJob() {
    MM_showLayersCanBox(false); 
   document.forms[0].action="<%=Constants.APP_PATH%>/SERV_PrintInfJobServlet?who=J&emp_serv=<%=emp_serv%>";
   document.forms[0].target="_blank";
   document.forms[0].submit();
}

function cancelJob() {
   MM_showLayersCanBox(false); 
   if (confirm(" คุณแน่ใจว่าต้องการยกเลิก Inform Job ใบนี้ ?")) {
   
	   //document.forms[0].action="<%//=Constants.APP_PATH%>/SERV_InfJobServlet";
	   //document.forms[0].target="";
	   //document.forms[0].submit();
	    MM_showLayersCanBox(true);
   }
}

function doCancelBox(status) {
		if(status){
			if(document.forms[0].iCanTypeDDL.value ==''){
				alert("กรุณาเลือกสาเหตุกรณี 'CANCEL' ด้วย!! ");
				document.forms[0].iCanTypeDDL.focus();
		        return;
			}else{   	
			    document.forms[0].mode.value="CANCEL";		
			    document.forms[0].action="<%=Constants.APP_PATH%>/SERV_InfJobServlet";
			    document.forms[0].target="";
			    document.forms[0].submit();
			    //alert("submit");
			 }
		}
		document.getElementById("canBox").style.visibility ='hidden';
}

function MM_showLayersCanBox(status) {
	 if(status){			 
		document.getElementById("canBox").style.visibility ='visible';
	}else{
		 document.getElementById("canBox").style.visibility ='hidden';
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
<input type="hidden" name="iSystem" value="<%=iSystem%>">

<input type="hidden" name="InformTypeDDL" value="<%=InformTypeDDL%>">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            Inform Job</td>
          <td width="50%" align="right">
          <%
			if (openjob) {
			if (!user.getUserWho().equalsIgnoreCase("J")) {	
				  if (!popup.equalsIgnoreCase("Y")) {
				  		if(!"".equals(from_page)){
				  	  %><a href="<%=from_page%>" ><img border="0" src="images/icon_open_Jop.gif" width="120" height="34"></a><%
				  		}else{
					  %><a href="#" onclick="openJob();"><img border="0" src="images/icon_open_Jop.gif" width="120" height="34"></a>
					 <%
					   }
				  }
			   }
			}
           %>
           </td>
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
    <td height="22" class="item ; dotline01" width="14%">จากช่องทาง :</td>
    <td height="22" width="34%" class="dotline01">&nbsp;
    <%
    if(iSystem.equals("LSV")){
    %>
    <img src="https://img.icons8.com/color/18/000000/line-me.png">
    <%
    }else{
      out.println(iSystem);
    }
     %>
    </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ชื่อผู้แจ้ง/ลูกค้า
      :</td>
    <td height="22" width="39%" class="dotline01"><%=common.joinContactAndOwner(removeNull(nCustomer),removeNull(custName))%></td>
    <td height="22" class="item ; dotline01" width="14%">โทรศัพท์ติดต่อ :</td>
    <td height="22" width="34%" class="dotline01"><%=common.joinContactAndOwner(removeNull(nCustTel),removeNull(custTel))%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">การประกัน :</td>
    <td height="22" width="39%" class="dotline01"><%
    //=guranteeDesc
    if(condoProfileArr!=null && removeNull(condoProfileArr[0]).equals("YES")){ //CASE : is Condo
    	out.println(removeNull(condoProfileArr[5]));
    }else{ // CASE : Not Condo
    	out.println(guranteeDesc);
    }
    %></td>
    <td height="22" class="item ; dotline01" width="14%">วันที่หมดประกัน :</td>
    <td height="22" width="34%" class="dotline01"><%
    //=guranteeDate
     if(condoProfileArr!=null && removeNull(condoProfileArr[0]).equals("YES")){ //CASE : is Condo
    	out.println(removeNull(condoProfileArr[3]));
    }else{ // CASE : Not Condo
    	out.println(guranteeDate);
    }
    %></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ผู้รับเรื่อง
      :</td>
    <td height="22" width="39%" class="dotline01"><% if(chk_condo.equals("Y")) { out.println(name_serv); } else {  out.println(inFormEmp);  } %></td>
    <td height="22" class="item ; dotline01" width="14%">วันเวลาที่แจ้ง :</td>
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
<table border="0" width="100%" cellspacing="0" cellpadding="0" >
  <tr>
    <td width="5" valign="top"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop">&nbsp;</td>
    <td width="5" valign="top" align="right"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLRpad01"> <font style="color:rgb(255,100,0)"> ประเภทใบแจ้งซ่อม :</font> 
    <%=GenInformTypeHtmlDDL(conn,"InformTypeDDL",InformTypeDDL," disabled='disabled'  class='box2' style='width:200' ")%>
    </td>
  </tr>
</table>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLRpad01">&nbsp;</td>
  </tr>
</table>
<% if("".equals(iSystem)){%>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLRpad01"> <font style="color:rgb(255,100,0)"> วันที่นัดหมาย :</font> <%=dAppointCust%>  
    &nbsp;&nbsp;&nbsp; 
    <%
     if(!"".equals(fromTime)){
     	%>
     	<font style="color:rgb(255,100,0)"> เวลาที่แจ้ง : </font> <%=fromTime%>  <font style="color:rgb(255,100,0)"> น. </font>
     	<%
     }
     %>
    </td>
  </tr>
</table>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLRpad01">&nbsp;</td>
  </tr>
</table>
<%} %>


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLRpad01"><%=cDesc%></td>
  </tr>
  <br>
  <%
  
  String sql1 = " select b.img_path from lan:eser_dochd a,lan:eser_docdt b where a.i_eser_docno = b.i_eser_docno and a.i_docno = '"+iDocNo+"' ";
  rs = stmt.executeQuery(sql1);  
  String tempImg = ""; 
  String urlImg = "";
  String pathImg = "https://lineapp.lh.co.th/line-bot"; 		
  int xLoop =1;		   
  while(rs.next()){
     	 tempImg = doString.checkString(rs.getString("img_path"),"");
   		 if( !"".equals(tempImg) && tempImg.indexOf(".")!=-1 ){
    		//System.out.println(dd.substring(1,dd.length()));   
    		//tempImg = arrList.get(5).toString();   
    		urlImg = pathImg+tempImg.substring(1,tempImg.length());	
    		System.out.println("----img path :"+urlImg);
   %>
     <tr>
     <td width="100%" class="frmLRpad01"><%=xLoop %>&nbsp;&nbsp;รูปภาพงานซ่อม : <a href="<%=urlImg%>" target="_blank"><img src="<%=urlImg%>" width="25" height="20" border="0"></a></td>
    </tr>
   <% 
      }
      xLoop++;
  }
  rs.close();
   %>
  
  
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
      if (openjob && !popup.equalsIgnoreCase("Y")) {
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
  
  /* modify by pradoem
     date : 2021.06.07
     desc: p.lee request Edit pragram
      M=Manager
      Z=Zone
      P=VP
      A=Admin    
      */
      System.out.println(user.getUserWho());
      if(user.getUserWho().equals("M") ||
      user.getUserWho().equals("Z")||
      user.getUserWho().equals("P")||
      user.getUserWho().equals("A")){
      	openjob = true; //TODO  cencelJob Enable
      }
      if (openjob && !popup.equalsIgnoreCase("Y")) {
	  %>
           <img border="0" src="images/act_cancel.gif" onclick="cancelJob();"                                  
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand" width="70" height="27">
            </td>   
          <% 
      }
  %>                  	          <td class="act_tab3"></td>   
            <td class="act_tab4">
          <%
              if (popup.equalsIgnoreCase("Y")) {
                  %>
                   <a href="javascript:top.window.close()"><img border="0" src="images/bu_close.gif" align="top" width="50" height="15"></a> 
                  <%
              } else {
                  %>
		           <a href="javascript:history.back()" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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

<!-- Click Cancel 
i_can_type
i_can_desc-->
<%-- ========================= Click Cancel =========================================---%>   
<div id="canBox" style="display:block ; visibility:hidden ; z-index:1 ; position:relative ; left:50% ; top:-500px ; margin-left:-250px ; margin-top:100px ; 
background-color:#dcf0ff; border:5px solid rgb(200,200,200)  ; padding:20px ; 
text-align:center ;
width:500px" >

            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">ยกเลิกการแจ้งซ่อม</td>
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
    <td class="item ; dotline01" height="22">สาเหตุการยกเลิก :</td>
    <td height="22" class="dotline01">
    	<%=GenCauseHtmlDDL(conn,"iCanTypeDDL",""," class='box2' style='width:100%' ")%>

    </td>
    </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%" valign="top">รายละเอียด :</td>
    <td height="22" width="39%" class="dotline01" valign="top">
    <textarea name="iCanDesc" id="i_canDesc" rows="5" class="box" style="width:100%"></textarea>
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
<%--  onClick="MM_showHideLayers('alert2','','hide')"    --%>
<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="80" class="act_tab2">&nbsp;
   	        <img src="images/act_ok.gif" width="70" height="27" border="0"     
                  		style="FILTER: alpha(opacity=70);cursor:hand" onClick="doCancelBox(true);"    
                  		onMouseOver=nereidFade(this,100,50,5)                                  
    					onMouseOut=nereidFade(this,70,50,5)></td>   
            <td class="act_tab3">&nbsp;</td>   
            <td class="act_tab4"><img src="images/bu_close.gif" width="50" height="15" border="0" align="absmiddle" onClick="doCancelBox(false);" style="cursor:hand"></td>
            
          </tr>  
        </table>
</div>
<%-- ========================= Click Cancel End =========================================---%>   
</FORM>
</BODY>
</HTML><%	} catch (Exception e) {		System.out.println("!!! ERROR SERV_InfJob_Disp.jsp : " + e.getMessage());		throw new ServletException(e.getMessage());	} finally {		// Clean up.		try {			if (rs != null) rs.close();			if (stmt != null) stmt.close();			if (conn != null) conn.close();		}
		catch( SQLException ignore ){}
	}
%>