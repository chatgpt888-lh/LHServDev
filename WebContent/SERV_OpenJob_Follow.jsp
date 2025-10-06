<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="java.text.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%!
/**
 * Modify by : pradoem@lh.co.th
 * date : 2015.05.13
 * version 1.1
 * desc: 
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
 
%>
<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String empname = user.getEmpName();
String jName = "SERV_OpenJob_Disp.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);
   doString str = new doString();

   //----============ Declare Variables for input data ===========----//
   String iDocNo = doString.checkString(request.getParameter("i_docno"),"");
   String edit = doString.checkString(request.getParameter("edit"),"");
   String popup = doString.checkString(request.getParameter("popup"),"");
   
   
   //-----========= Declare Variables for OpenJob Page ===========----//
   String mode = doString.checkString(request.getParameter("mode"),"edit");
   //String dAppoint= doString.checkString(request.getParameter("d_appoint"),"");
   //String dEstClose= doString.checkString(request.getParameter("d_est_close"),"");   
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
   String dAppoint = "";
   String dEstClose = "";
      
   String housePlan = "-";
   String custName = "-";
   String custTel = "-";
   String guranteeDesc = "-";
   String guranteeDate = "-";
   String iCustomer = "";
   String name_serv = "";
   String emp_serv = "";
   String chk_condo = "";
   Vector jobList = new Vector();
   boolean foundClose = false;
   Hashtable docdt = new Hashtable();
   
			       
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	SERV_CommonData common = null;
	
	String i_company = "";
	String i_project = "";
	String itmtype = "";
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
			 dAppoint = doString.DisplayThai(doString.checkString((String) tmpHeader.get("d_appoint"),"-"));
			 dEstClose = doString.DisplayThai(doString.checkString((String) tmpHeader.get("d_est_close"),"-"));
			
			itmtype = doString.checkString(request.getParameter("itmtype"),"");
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
			}//end if chk emp_serv
			
			
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


			
			
			//----============================= Get JobItem =============================----//
			sql.delete(0,sql.length());
			sql.append(" select a.*,b.n_itmjob,b.n_count,c.n_desc,d.bus_name from lan:serv_docdt a ")
			      .append(" left join lan:serv_boq b on b.i_itmjob=a.i_itmjob ")
			      .append(" left join lan:serv_xstd c on c.i_type='01' and c.i_code=a.i_itmjob_area ")
			      .append(" left join lan:stpvendr d on d.vend_code=a.i_vendor ")
			      .append(" where a.i_docno='").append(iDocNo).append("' and a.f_itmstatus<>'CAN' ");
			      //.append(" order by i_itmjob ");
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			while (rs.next()) {
				   docdt = new Hashtable();
				   docdt.put("n_itmjob",doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")),""));
				   docdt.put("n_count",doString.checkString(doString.DisplayThai(rs.getString("n_count")),""));
				   docdt.put("bus_name",doString.checkString(doString.DisplayThai(rs.getString("bus_name")),""));
				   docdt.put("q_wage_unit",doString.checkString(doString.DisplayThai(rs.getString("q_wage_unit")),""));
				   docdt.put("z_wage_price",doString.checkString(Double.toString(rs.getDouble("z_wage_price")),""));
				   docdt.put("q_good_unit",doString.checkString(doString.DisplayThai(rs.getString("q_good_unit")),""));
				   docdt.put("z_good_price",doString.checkString(Double.toString(rs.getDouble("z_good_price")),""));
				   docdt.put("z_amount_pay",doString.checkString(doString.DisplayThai(rs.getString("z_amount_pay")),""));
				   docdt.put("c_itmjob",doString.checkString(doString.DisplayThai(rs.getString("c_itmjob")),""));
				   docdt.put("n_desc",doString.checkString(doString.DisplayThai(rs.getString("n_desc")),""));			
				   docdt.put("f_itmstatus",doString.checkString(rs.getString("f_itmstatus"),""));		
				   jobList.addElement(docdt);
			} // end while
			rs.close();
			//----=====================================================================----//


			//----============================= check close item =============================----//
			sql.delete(0,sql.length());
			sql.append(" select * from lan:serv_payment where i_docno='").append(iDocNo).append("' and f_itmstatus='CLS' ");
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			if (rs.next()) {
				foundClose = true;
			} // end while
			rs.close();
			//----=====================================================================----//
				
		    
	   } // end if check i_docno
   
%>


<HTML>
<HEAD>
<TITLE>Open Job - Display2</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">
<!--

function openJob() {    MM_showLayersCanBox(false); 
   document.forms[0].action="SERV_OpenJob.jsp?load=yes";
   document.forms[0].target="";      
   document.forms[0].submit();
}

function printInfJob() {   MM_showLayersCanBox(false); 
   document.forms[0].action="<%=Constants.APP_PATH%>/SERV_PrintInfJobServlet?who=J&emp_serv=<%=emp_serv%>";
   document.forms[0].target="_blank";   
   document.forms[0].submit();
}

function printOpenJob() {
MM_showLayersCanBox(false); 
/*alert("            ขออภัย !! เนื่องจากระบบพิมพ์ใบแจ้งซ่อมมีปัญหา(ชั่วคราว) \n\nถ้าต้องการพิมพ์กรุณาส่งเลขที่ใบแจ้งซ่อมมาทางเมลล์ watinee@lh.co.th \nหรือติดต่อ เป้ 0-2230-8458, ลี่ 0-2230-8491");*/
   //document.forms[0].action="http://www9.lh.co.th/LHServ/SERV_PrintOpenJobServlet?empname=<%=doString.DisplayThai(doString.checkString(empname))%>";
   
   document.forms[0].action="/LHServ/SERV_PrintOpenJobServlet?empname=<%=doString.DisplayThai(doString.checkString(empname))%>";
   document.forms[0].target="_blank";   
   document.forms[0].submit();
}

/*function cancelJob() {
   if (confirm(" คุณแน่ใจว่าต้องการยกเลิก Open Job ใบนี้ ?")) {
       document.forms[0].mode.value="CANCEL";
	   document.forms[0].action="<%=Constants.APP_PATH%>/SERV_OpenJobServlet";
       document.forms[0].from_page.value = 'SERV_ReportServiceDetails.jsp';
	   document.forms[0].target="";
	   document.forms[0].submit();
   }
}
function cancelDoc() {
   if (confirm(" คุณแน่ใจว่าต้องการยกเลิกใบแจ้งซ่อมนี้ ?")) {
       document.forms[0].mode.value="CANCEL_DOC1";
       document.forms[0].from_page.value = 'SERV_ReportServiceDetails.jsp';
	   document.forms[0].action="<%=Constants.APP_PATH%>/SERV_OpenJobServlet";
	   document.forms[0].target="";
	   document.forms[0].submit();
   }
}*/

function cancelJob() {//1
    MM_showLayersCanBox(false); 
   if (confirm(" คุณแน่ใจว่าต้องการยกเลิก Open Job ใบนี้ ?")) {
       /*document.forms[0].mode.value="CANCEL";
	   document.forms[0].action="<%=Constants.APP_PATH%>/SERV_OpenJobServlet";
	   document.forms[0].target="";
	   document.forms[0].submit();*/
	   
	   document.forms[0].mode.value="CANCEL";
	   document.forms[0].from_page.value = 'SERV_ReportServiceDetails.jsp';
	   MM_showLayersCanBox(true);
   }
}

function cancelDoc() { //2
   if (confirm(" คุณแน่ใจว่าต้องการยกเลิกใบแจ้งซ่อมนี้ ?")) {
       /*document.forms[0].mode.value="CANCEL_DOC1";
	   document.forms[0].action="<%=Constants.APP_PATH%>/SERV_OpenJobServlet";
	   document.forms[0].target="";
	   document.forms[0].submit();*/
	   
	   document.forms[0].mode.value="CANCEL";//CANCEL_DOC1
       document.forms[0].from_page.value = 'SERV_ReportServiceDetails.jsp';
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
			    document.forms[0].action="<%=Constants.APP_PATH%>/SERV_OpenJobServlet";
			    document.forms[0].target="";
			    document.forms[0].submit();
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





function doPending(){
	var form = document.forms[0];
	form.mode.value='';
	form.action = '/LHServ/SERV_Pending.jsp';
	form.submit();
}
function gotoInfJob(){
	var form = document.forms[0];
	form.action = '/LHServ/SERV_InfJob_Disp.jsp';
	form.submit();
}
//-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">
<input type="hidden" name="itmtype" value="<%=itmtype%>" />
<input type="hidden" name="from_page" value="SERV_OpenJob_Follow.jsp" />
<input type="hidden" name="i_company" value="<%=iCompany%>" />
<input type="hidden" name="i_project" value="<%=iProject%>" />
<input type="hidden" name="mode" value="<%=mode%>">
<input type="hidden" name="i_docno" value="<%=iDocNo%>">
<input type="hidden" name="load" value="no">
<input type="hidden" name="d_appoint" value="<%=dAppoint%>">
<input type="hidden" name="d_est_close" value="<%=dEstClose%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            Open Job</td>
          <td width="50%" align="right"><a href="javascript:gotoInfJob();"><img border="0" src="images/icon_view_IFJ.gif" align="absmiddle" width="120" height="34"></a></td>
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
    <td height="22" width="39%" class="dotline01"><% if(chk_condo.equals("Y")) { out.println(name_serv); } else {  out.println(inFormEmp);  } %></td>
    <td height="22" class="item ; dotline01" width="14%">วันเวลาที่แจ้ง
      :</td>
    <td height="22" width="34%" class="dotline01"><%=inFormDate%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">วันที่นัดซ่อม
      :</td>
    <td height="22" width="39%" class="dotline01"><%=dAppoint%></td>
    <td height="22" class="item ; dotline01" width="14%">วันที่ประมาณการเสร็จ
      :</td>
    <td height="22" width="34%" class="dotline01"><%=dEstClose%></td>
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
                <td class="item_tab2" width="200">รายการซ่อม</td>
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
          <td width="3%" rowspan="2" class="col_name">No.</td>
          <td width="17%" rowspan="2" class="col_name">รายการซ่อม</td>
          <td width="6%" rowspan="2" class="col_name">หน่วยนับ</td>
          <td width="20%" rowspan="2" class="col_name">ผู้รับเหมา</td>
          <td colspan="3" class="col_name">ค่าแรง</td>
          <td colspan="3" class="col_name">ค่าของ</td>
          <td width="10%" rowspan="2" class="col_name">รวมเงิน</td>
        </tr>
        <tr>
          <td width="8%" class="col_nameLow">ต่อหน่วย</td>
          <td width="5%" class="col_nameLow">จำนวน</td>
          <td width="9%" class="col_nameLow">รวม</td>
          <td width="8%" class="col_nameLow">ต่อหน่วย</td>
          <td width="5%" class="col_nameLow">จำนวน</td>
          <td width="9%" class="col_nameLow">รวม</td>
        </tr>
        <%
        int line = 0;
        DecimalFormat format = new DecimalFormat("#,##0.00");
        double grandTotalWage = 0.00;
        double grandTotalGoods = 0.00;
        double grandTotal = 0.00;

		docdt  = new Hashtable();
		double wageUnit = 0.0;
		double goodsUnit = 0.0;

		double wagePrice = 0.0;
		double goodsPrice = 0.0;
		double totalWage = 0.00;
		double totalGoods = 0.00;
		double subTotal = 0.00;
        
        for (int i=0;i<jobList.size();i++) {
                line++;
                docdt  = (Hashtable) jobList.elementAt(i);
                wageUnit = Double.parseDouble((String) docdt.get("z_wage_price"));
                goodsUnit = Double.parseDouble((String) docdt.get("z_good_price"));

                wagePrice = Double.parseDouble((String) docdt.get("q_wage_unit"));
                goodsPrice = Double.parseDouble((String) docdt.get("q_good_unit"));
                totalWage = 0.00;
                totalGoods = 0.00;
                subTotal = 0.00;
                
                totalWage = wagePrice * (double) wageUnit;
                totalGoods = goodsPrice * (double) goodsUnit;
                subTotal = totalWage + totalGoods;
                
                grandTotalWage += totalWage;
                grandTotalGoods += totalGoods;
                grandTotal += subTotal;

		        %>
		        <tr>
		          <td width="3%" align="center" class="dotline"><%=line%></td>
		          <td width="17%" class="dotline"><%=doString.checkString((String) docdt.get("n_itmjob"))%></td>
		          <td width="6%" class="dotline" align="center"><%=doString.checkString((String) docdt.get("n_count"))%></td>
		          <td width="20%" class="dotline ; item"><%=doString.checkString((String) docdt.get("bus_name"))%></td>
		          <td width="8%" align="right" class="dotline"><%=format.format(wagePrice)%></td>
		          <td width="5%" align="right" class="dotline"><%=format.format(wageUnit)%></td>
		          <td width="9%" align="right" class="dotline"><%=format.format(totalWage)%></td>
		          <td width="8%" align="right" class="dotline"><%=format.format(goodsPrice)%></td>
		          <td width="5%" align="right" class="dotline"><%=format.format(goodsUnit)%></td>
		          <td width="9%" align="right" class="dotline"><%=format.format(totalGoods)%></td>
		          <td width="10%" align="right" class="dotline"><%=format.format(subTotal)%></td>
		        </tr>
		        <%
           } // end for
           
           while (line<Constants.SERV_OPENJOB_LINE) {
                line++;
		        %>
		        <tr>
		          <td width="3%" align="center" class="dotline">&nbsp;</td>
		          <td width="17%" class="dotline">&nbsp;</td>
		          <td width="6%" class="dotline" align="center">&nbsp;</td>
		          <td width="20%" class="dotline ; item">&nbsp;</td>
		          <td width="8%" align="right" class="dotline">&nbsp;</td>
		          <td width="5%" align="right" class="dotline">&nbsp;</td>
		          <td width="9%" align="right" class="dotline">&nbsp;</td>
		          <td width="8%" align="right" class="dotline">&nbsp;</td>
		          <td width="5%" align="right" class="dotline">&nbsp;</td>
		          <td width="9%" align="right" class="dotline">&nbsp;</td>
		          <td width="10%" align="right" class="dotline">&nbsp;</td>
		        </tr>
		        <%
		     }  // end while
        %>
        <tr>
          <td width="3%" align="center" class="dotline">&nbsp;</td>
          <td width="17%" class="dotline">&nbsp;</td>
          <td width="6%" class="dotline" align="center">&nbsp;</td>
          <td width="20%" class="dotline ; item" align="right">รวม</td>
          <td width="8%" align="right" class="dotline ; item">&nbsp;</td>
          <td width="5%" align="right" class="dotline ; item">&nbsp;</td>
          <td width="9%" align="right" class="dotline ; item"><%=format.format(grandTotalWage)%></td>
          <td width="8%" align="right" class="dotline ; item">&nbsp;</td>
          <td width="5%" align="right" class="dotline ; item">&nbsp;</td>
          <td width="9%" align="right" class="dotline ; item"><%=format.format(grandTotalGoods)%></td>
          <td width="10%" align="right" class="dotline ; item"><%=format.format(grandTotal)%></td>
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


<%
   if (jobList.size()>0) {
%>
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">หมายเหตุ</td>
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
        line = 0;
        for (int i=0;i<jobList.size();i++) {
                line++;
                docdt  = (Hashtable) jobList.elementAt(i);          
                %>
				  <tr>
				    <td class="item ; dotline01" height="22" width="12%">รายการที่ <%=line%> :</td>
				    <td height="22" width="80%" class="dotline01"><%=doString.checkString((String) docdt.get("c_itmjob"))%></td>
				    <td height="22" width="8%" class="dotline01"><%=doString.checkString((String) docdt.get("n_desc"))%></td>
				  </tr>
                <%
         } // end for
        
        while (line<Constants.SERV_OPENJOB_LINE) {
            line++;
		        %>  
				  <tr>
				    <td class="item ; dotline01" height="22" width="12%">&nbsp;</td>
				    <td height="22" width="80%" class="dotline01">&nbsp;</td>
				    <td height="22" width="8%" class="dotline01">&nbsp;</td>
				  </tr>
				<%
		  } // end while
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

<%
   } // end if check jobList
%>



<br style="font-size:10pt">



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="<%=edit.equalsIgnoreCase("NO") ? "150" : "320"%>" class="act_tab2">
			<nobr>
<%
	if (!user.getUserWho().equals("J")) {			
	     %>
	     <img border="0" src="images/act_edit.gif"  onclick="openJob();"                                 
  			onmouseout=nereidFade(this,70,50,5)    
                	onmouseover=nereidFade(this,100,50,5)     
                	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">&nbsp; 
	     <%
	}  // end if check who = J

 			%>
           <img border="0" src="images/act_printinformjob.gif" onclick="printInfJob();"                                
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">
<%
if (!user.getUserWho().equals("J")) {
%>				
					&nbsp; <img border="0" src="images/act_print001.gif" onclick="printOpenJob();"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">
<%
			  if (!edit.equalsIgnoreCase("NO")) {			
			     %>
	           <img border="0" src="images/act_cancel.gif" onclick="cancelJob();"                                  
	    			onmouseout=nereidFade(this,70,50,5)    
	                  	onmouseover=nereidFade(this,100,50,5)     
	                  	style="FILTER: alpha(opacity=70);cursor:hand" width="70" height="27">
			     <%
			  }
			   //---========= If have permission , show Cancel Button ===============----//
			   if (edit.equalsIgnoreCase("NO") && SERV_CommonData.checkPermissionOnPage(Constants.PERMISSION_ZONE,user.getUserWho()) && !foundClose) {
					 %>
				   <img border="0" src="images/act_cancel.gif" onclick="cancelDoc();"                                  
						onmouseout=nereidFade(this,70,50,5)    
							onmouseover=nereidFade(this,100,50,5)     
							style="FILTER: alpha(opacity=70);cursor:hand" width="70" height="27">
					 <%
			   }
	} // end if check who = J
%>    
			<img border="0" src="images/act_Pending.gif" onclick="doPending();"                               
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">
			</nobr>
            </td>   
            <td class="act_tab3"></td>   
            <td class="act_tab4">
          <%
              if (popup.equalsIgnoreCase("Y")) {
                  %>
                   <a href="javascript:top.window.close()"><img border="0" src="images/bu_close.gif" align="top" width="50" height="15"></a> 
                  <%
              } else {
                  %>
		      <!--<a href="<%=Constants.APP_PATH%>/SERV_Reprint_List.jsp" target="_self">-->
			  <a href="/LHServ/SERV_ReportServiceDetails.jsp?i_company=<%=iCompany%>&i_project=<%=iProject%>&itmtype=<%=itmtype%>" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
		      <a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
                  <%
              }
           %>      	    
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
<!-- Click Cancel 
i_can_type
i_can_desc-->
<%-- ========================= Click Cancel =========================================---%>   
<div id="canBox" style="display:block ; visibility:hidden ; z-index:1 ; position:relative ; left:50% ; top:-500px ; margin-left:-250px ; margin-top:0px ; 
background-color:#dcf0ff; border:5px solid rgb(200,200,200)  ; padding:20px ; 
text-align:center ;
width:500px">

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
</HTML>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_OpenJob_Disp.jsp : " + e.getMessage());
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