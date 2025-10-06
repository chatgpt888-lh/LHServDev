<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%!
	// Caching the DataSource - It is obtained in the jspInit() method
	private javax.sql.DataSource ds = null;
	private String dsName = Constants.JDBC_LAN;
	private void getDS() throws NamingException {
		// Note the new Initial Context Factory interface available in WebSphere 4.0
		Hashtable parms = new Hashtable();
		parms.put(Context.INITIAL_CONTEXT_FACTORY, "com.ibm.websphere.naming.WsnInitialContextFactory");
		InitialContext ctx = new InitialContext(parms);
		// Perform a naming service lookup to get the DataSource object.
		ds = (javax.sql.DataSource) ctx.lookup(dsName);
		ctx.close();
	}		
	// This Happens Once and is Reused
	public void jspInit() {
		try{
			getDS();
		}catch(Exception es){
		  es.printStackTrace();
		}
	}
%>
<%!
public Integer[] newIntegerArray(int size) {
	Integer data[] = new Integer[size];
	for (int l=0;l<size;l++) {
		  data[l] = new Integer(0);
	}
	return data;
}
public Double[] newDoubleArray(int size) {
	Double data[] = new Double[size];
	for (int l=0;l<size;l++) {
		  data[l] = new Double(0.0);
	}
	return data;
}
%>
<%
//****************************************
//String ParameterNames = "";
//for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
//	ParameterNames = (String)e.nextElement();
//	System.out.println(ParameterNames + " = "+request.getParameter(ParameterNames));
//}
//System.out.println("*******************************************");
//****************************************

String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_ReportZero02.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;
Statement stmt1 = null;
ResultSet rs1 = null;
Statement stmt2 = null;
ResultSet rs2 = null;
Statement stmt3 = null;
ResultSet rs3 = null;
SERV_CommonData common = null;

try {
	if (ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	stmt1 = conn.createStatement();
	stmt2 = conn.createStatement();
	stmt3 = conn.createStatement();
	common = new SERV_CommonData(conn);
	//---=========== Month Initilize =========----//
	String thaiMonth[] = new String[] {"","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
	doString str = new doString();
	DecimalFormat  format1 = new DecimalFormat("#,###,##0");
	Calendar rightNow = Calendar.getInstance();
	Integer q_mth[] = newIntegerArray(15);

//double q_mth1 = 0, q_mth2 = 0, q_mth3 = 0, q_mth4 = 0, q_mth5 = 0, q_mth6 = 0, q_mth7 = 0;
//double q_mth8 = 0, q_mth9 = 0, q_mth10 = 0, q_mth11 = 0, q_mth12 = 0, q_mth13 = 0;
String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);  //+543
String r_type = doString.checkString(request.getParameter("r_type"),"");
String sel_time = doString.checkString(request.getParameter("sel_time"),"");
String type_amt = doString.checkString(request.getParameter("type_amt"),"A");
String f_name = "";
String type_rep = doString.checkString(request.getParameter("type_rep"),"01");
//------------------------------------ Date Job -----------------------------------------
String A_StartM = doString.checkString(request.getParameter("A_StartM"),"00");
String A_StartY = doString.checkString(request.getParameter("A_StartY"),"0000");
String A_EndM = doString.checkString(request.getParameter("A_EndM"),"00");
String A_EndY = doString.checkString(request.getParameter("A_EndY"),"0000");
//------------------------------------ Date Close Law ---------------------------------
String B_StartM = "", B_StartY = "", B_EndM = "", B_EndY = "";

B_StartM = doString.checkString(request.getParameter("B_StartM"),"00");
B_StartY = doString.checkString(request.getParameter("B_StartY"),"0000");
B_EndM = doString.checkString(request.getParameter("B_EndM"),"00");
B_EndY = doString.checkString(request.getParameter("B_EndY"),"0000");
String type_date = "", d_start = "", d_end = "", type_display = "";
String mainboq = "", subboq = "", seqboq = "";
String option = "", grp = "", typ = "", chk_prj = "";
String n_itmjob = "", d_query = "", d_query2 = "", que_itm = "";

mainboq = doString.checkString(request.getParameter("mainboq"),"00");	
subboq = doString.checkString(request.getParameter("subboq"),"nnnn");	
seqboq = doString.checkString(request.getParameter("seqboq"),"nnnnnnnn");		

if (sel_time.equals("A")) {   // สรุปตามวันแจ้งซ่อม
		 type_date = "แจ้งซ่อม";
		 type_rep = "01";
		 d_start = thaiMonth[Integer.parseInt(A_StartM)]+" "+(Integer.parseInt(A_StartY)+543);
		 d_end = thaiMonth[Integer.parseInt(A_EndM)]+" "+(Integer.parseInt(A_EndY)+543);    
		 d_query = "and a.i_date  between mdy("+A_StartM+",1, "+(Integer.parseInt(A_StartY))+") and mdy("+A_EndM+",1, "+(Integer.parseInt(A_EndY))+") ";
		 d_query2 = "and a.i_date between mdy("+A_StartM+",1, "+(Integer.parseInt(A_StartY))+") and mdy("+A_EndM+",1, "+(Integer.parseInt(A_EndY))+") ";
} else if (sel_time.equals("B")) {    //  สรุปตามวันที่โอน
		 type_date = "โอน";
		 type_rep = "02";
		 d_start = thaiMonth[Integer.parseInt(B_StartM)]+" "+(Integer.parseInt(B_StartY)+543);
		 d_end = thaiMonth[Integer.parseInt(B_EndM)]+" "+(Integer.parseInt(B_EndY)+543);   
		 d_query = "and a.i_date between mdy("+B_StartM+",1, "+(Integer.parseInt(B_StartY))+") and mdy("+B_EndM+",1, "+(Integer.parseInt(B_EndY))+") ";
		 d_query2 ="and a.i_date between mdy("+B_StartM+",1, "+(Integer.parseInt(B_StartY))+") and mdy("+B_EndM+",1, "+(Integer.parseInt(B_EndY))+") ";
}
		//----------------------------- Reason Type----------------------------- 
		 type_display = "";
		 sql.delete(0,sql.length());	
		 sql.append("select * from lan:serv_xstd ")
			  .append("where i_type = '00' ")
			  .append("and i_code = '"+r_type+"' ");
		 servlog.startLog(sql.toString());
		 rs = stmt.executeQuery(sql.toString());
		 servlog.endLog();
		 if (rs.next()==true) {
			 type_display = doString.checkString(doString.DisplayThai(rs.getString("n_desc")),"");
		 } else {
			 type_display = "ทุกสาเหตุ";
		 }	
%>
<HTML>
<HEAD>
<TITLE>สรุปรายงาน Zero Defect  สรุปตามวันที่โอน/วันที่แจ้ง</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<style >
.fg_style1 { mso-number-format:"\@";}
 .col_name1{ 	font-size: 8.0pt ; color: rgb(0,50,200) ; /*text-align: right ; */ 
			background-image: url(images/col_bg1.gif) ; background-repeat : repeat-x ;
			border-right:1px solid rgb(135,185,247) ; border-bottom:1px solid rgb(135,185,247) ; 	}
</style>
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
<!--
  function goDetail(projDDL,i_itmjob) {
        document.forms[0].args1.value= "";	
		document.forms[0].projectDDL.value=projDDL; //LH:075
		document.forms[0].i_itm.value=i_itmjob;	  
		document.forms[0].flag_report.value="";	
	  	document.forms[0].action='<%=Constants.APP_PATH%>/SERV_ReportZeroDesc03.jsp';
		document.forms[0].submit();
}
 function gotoAllDetail() {
        document.forms[0].args1.value= "";	
		//document.forms[0].projectDDL.value=projDDL; //LH:075
		//document.forms[0].i_itm.value=i_itmjob;	  
		document.forms[0].flag_report.value="all";	
	  	document.forms[0].action='<%=Constants.APP_PATH%>/SERV_ReportZeroDesc03.jsp';
		document.forms[0].submit();
}	

 function gotoSummaryByProject(projDDL,param) {
 		if(param == 'true'){
			document.forms[0].projectDDL.value=projDDL; //LH:075
		}else{
		   document.forms[0].i_itm.value=projDDL;	 //itm
		}  
		document.forms[0].flag_report.value="";
		document.forms[0].args1.value= param;	
	  	document.forms[0].action='<%=Constants.APP_PATH%>/SERV_ReportZeroDesc03.jsp';
		document.forms[0].submit();
}

function returnReport() {
	  	document.forms[0].action='<%=Constants.APP_PATH%>/SERV_ReportZero01.jsp';
		document.forms[0].submit();
}
  //-->
</SCRIPT>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM NAME = "frmRep" ACTION="SERV_ReportZero02.jsp" METHOD="POST">
<input type="hidden" name="B_StartM" value="<%=B_StartM%>">
<input type="hidden" name="B_StartY" value="<%=B_StartY%>">
<input type="hidden" name="B_EndM" value="<%=B_EndM%>">
<input type="hidden" name="B_EndY" value="<%=B_EndY%>">
<input type="hidden" name="A_StartM" value="<%=A_StartM%>">
<input type="hidden" name="A_StartY" value="<%=A_StartY%>">
<input type="hidden" name="A_EndM" value="<%=A_EndM%>">
<input type="hidden" name="A_EndY" value="<%=A_EndY%>">
<input type="hidden" name="sel_time" value="<%=sel_time%>">
<input type="hidden" name="r_type" value="<%=r_type%>">
<input type="hidden" name="d_query" value="<%=d_query%>">
<input type="hidden" name="d_start" value="<%=d_start%>">
<input type="hidden" name="d_end" value="<%=d_end%>">
<input type="hidden" name="type_rep" value="<%=type_rep%>">
<input type="hidden" name="projectDDL" value="">
<input type="hidden" name="i_itm" value="">
<input type="hidden" name="flag_report" value="">
<input type="hidden" name="args1" value="">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">
          &nbsp;รายงาน Zero Defect  แยกตามวันที่โอน/วันที่แจ้ง</td>
        </tr>
      </table>
<br style="font-size:10pt">               
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">รายละเอียดเดือนปีที่ระบุ</td>
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
    <td class="item ; dotline01" height="22" width="15%">  เดือน/ปี ที่<%=type_date%> :</td>
    <td width="85%" colspan="2" class="dotline01"><%=d_start%>&nbsp;&nbsp; ถึง&nbsp;&nbsp;<%=d_end%></td>
    </tr>
  <tr>
    <td width="15%" height="22" class="item ; dotline01">สาเหตุ : </td>
    <td width="85%" colspan="2" class="dotline01"><%=type_display%>&nbsp;</td>
  </tr>
  </table>
  <table border="0" width="100%" cellspacing="0" cellpadding="0">
  <%
	  String[] projList = request.getParameterValues("sel_proj");

  	  String queryProject = "";			
	  String proj = "";
	  int line = 0;
	  if (projList!=null) {
		  for (int i=0;i<projList.length;i++) {		
		        //System.out.println("---->TEST :"+doString.checkString(projList[i],""));  
				 proj = doString.checkString(projList[i],"");  		
				 if (proj.trim().length()>=6) {	
						 if (queryProject.trim().length()>0) queryProject += " or ";
						 queryProject += " (a.i_company='"+proj.substring(0,2)+"' and a.i_project='"+proj.substring(3,6)+"') ";	
				 }
				  %><input type="hidden" name="sel_proj" value="<%=proj%>"><%
				//---============= get Project Details ===============----//
				sql.delete(0,sql.length()); 
				sql.append(" select i_company,i_project,n_project from lan:acxprojt ")
					  .append(" where i_company='").append(proj.length()>=6 ? proj.substring(0,2) : "").append("' ")
					  .append(" and i_project='").append(proj.length()>=6 ? proj.substring(3,6) : "").append("' ");
				servlog.startLog(sql.toString());
				//System.out.println("SQL :"+sql.toString());
				rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
				while (rs.next()) {
							 String nProject = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
							 String iProj = str.replace(proj,":","-");	
							 if (line==0) {
								 %><tr><td class="item ; dotline01" height="22" width="15%">โครงการ :</td><%
							 } else if (line%3==0 && line!=0) {
								 %><tr><td class="item ; dotline01" height="22" width="15%">&nbsp;</td><%
							}
							%><td height="22" width="28%" class="dotline01"><%=iProj%> <%=nProject%></td><%
							if (line%3==2) {
								%></tr><%
							}
							line++;
				} // end while
				rs.close();				
		  } // end for
				  while (line%3!=0) {
					  %><td height="22" width="28%" class="dotline01">&nbsp;</td><%
					  line++;
					  if (line%3==0) {
						%></tr><%
					  }
				  }
	  } else {
		  queryProject = " a.i_company='' and a.i_project='' ";
	  }
	  //System.out.println("SQL 2:"+queryProject);
	%>
</table>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="15%" height="22" class="item ; dotline01">ระบุหมวด : </td>
    <td width="10%" class="dotline01 ; item">หมวดหลัก      </td>
    <td width="75%" class="dotline01 ; item">
<select size="1" class="box" style="width:400px" name="mainboq" onchange="javascript:frmRep.submit();">
<option value="00">- - - เลือกทุกหมวด - - -</option>
<%
	sql.delete(0,sql.length()); 
	sql.append("  select distinct a.i_itmjob, a.n_itmjob from lan:serv_boq a , lan:serv_zero b  where a.i_type is null and a.i_seq is null   and a.i_itmjob = b.i_itmjob [1,2]  ");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	while (rs.next()) {
		option = "";			
		if (mainboq.equals(doString.checkString(rs.getString("i_itmjob")))) {
			option = " Selected ";
		} // End if
%>
	<option value="<%=doString.checkString(rs.getString("i_itmjob"))%>"<%=option%>><%=doString.checkString(rs.getString("i_itmjob"))+" "+doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")))%></option>
<%
	} // End while
%>
</select></td>
  </tr>
  <tr>
    <td height="22" class="item ; dotline01">&nbsp;</td>
    <td width="10%" class="dotline01 ; item">หมวดรอง      </td>
    <td width="75%" class="dotline01 ; item"><select size="1" class="box" style="width:400px" name="subboq" onchange="javascript:frmRep.submit();">
<option value="nnnn" <%if (subboq.equals("nnnn")) { out.println("Selected"); } %>>- - - - - - - - - -ไม่แสดงหมวดรอง - - - - - - - - -</option>
<option value="0000" <%if (subboq.equals("0000")) { out.println("Selected"); } %>>- - - - - - - - - -เลือกทุกหมวดรอง - - - - - - - - -</option>

<%
	sql.delete(0,sql.length()); 
	sql.append(" select distinct a.i_itmjob, a.n_itmjob from lan:serv_boq a , lan:serv_zero b   where a.i_group = '"+mainboq+"' and  a.i_type is not null and a.i_seq is null  and a.i_itmjob = b.i_itmjob [1,4]  order by a.i_itmjob ");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	while (rs.next()) {
		option = "";			
				if (subboq.equals(doString.checkString(rs.getString("i_itmjob")))) {
					option = " Selected ";
				} // End if
%>	
	<option value="<%=doString.checkString(rs.getString("i_itmjob"))%>"<%=option%>><%=doString.checkString(rs.getString("i_itmjob"))+" "+doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")))%></option>
<%
	} // End while
%>
</select></td>
  </tr>
  <tr>
    <td height="22" class="item ; dotline01">&nbsp;</td>
    <td width="10%" class="dotline01 ; item">หมวดย่อย      </td>
    <td width="75%" class="dotline01 ; item"><select size="1" class="box" style="width:400px" name="seqboq" onchange="javascript:frmRep.submit();">
<option value="nnnnnnnn" <%if (seqboq.equals("nnnnnnnn")) { out.println("Selected"); } %>>- - - - - - - - -- - - - - - - - - ไม่แสดงหมวดย่อย - - - - - - - - -- - - - - - - - -</option>
<option value="00000000" <%if (seqboq.equals("00000000")) { out.println("Selected"); } %>>- - - - - - - - -- - - - - - - - - เลือกทุกหมวดย่อย - - - - - - - - -- - - - - - - - -</option>
<%
	if (!subboq.equals("0000") && !subboq.equals("nnnn")) {
		grp = subboq.substring(0,2);
		typ = subboq.substring(2,4);	
	}
	sql.delete(0,sql.length()); 
	sql.append("  select distinct a.i_itmjob, a.n_itmjob from lan:serv_boq a , lan:serv_zero b ") 
	.append(" where a.i_group = '"+grp+"' and a.i_type = '"+typ+"' and  a.i_type is not null and a.i_seq is not null  ")
	.append("  and a.i_itmjob = b.i_itmjob [1,8]   order by i_itmjob");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	while (rs.next()) {
		option = "";			
				if (seqboq.equals(doString.checkString(rs.getString("i_itmjob")))) {
					option = " Selected ";
				} // End if
%>
	<option value="<%=doString.checkString(rs.getString("i_itmjob"))%>"<%=option%>><%=doString.checkString(rs.getString("i_itmjob"))+" "+doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")))%></option>
<%
	} // End while
%>
</select>
    &nbsp;&nbsp;&nbsp;<A HREF="javascript:frmRep.submit();"><img src="images/bu_go.gif" width="40" height="22" align="absmiddle" border="0"></a></td>
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
          <td class="item_tab2" width="200">รายละเอียด Zero Defect แยกตามหมวด</td>
            <td class="item_tab3"></td>
           <td>&nbsp;
          
            <input type="radio" value="A" name="type_amt" <% if (type_amt.equals("A")) { out.println("checked"); } %>>จำนวนรายการ&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" value="B" name="type_amt" <% if (type_amt.equals("B")) { out.println("checked"); } %>>จำนวนใบแจ้งซ่อม&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" value="C" name="type_amt" <% if (type_amt.equals("C")) { out.println("checked"); } %>>จำนวนเงิน&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" value="D" name="type_amt" <% if (type_amt.equals("D")) { out.println("checked"); } %>>จำนวนแปลง&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<A HREF="javascript:frmRep.submit();">
			<img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22" style="cursor:hand"></a>
			
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

<table border="0" width="100%" cellspacing="" cellpadding="0">
  <tr>
    <td width="100%" class="frmL">
     <table border="0" width="100%" cellspacing="0" cellpadding="0">
    <tr>
    <td class="col_name" width="45%" height="25">รายการ Zero Defect</td>
    <%
    	if (projList!=null) {
			   int max = projList.length;
			   if(max==12){
				     //System.out.println("Case#1");
				     for (int i=0;i<projList.length;i++) {
					  %><td class="col_name" width="4%" height="25"><%if(null == projList[i]){out.println("");}else{out.println(projList[i]);} %></td>					  		
					  <%} %>
				      <td class="col_name" width="7%" height="25">รวม</td>
				      <%
				      //if 12
			    }else{
				      //System.out.println("Case#2");
				       int loop = 12-max;
				       for (int i=0;i<max;i++) {
						   %><td class="col_name" width="4%" align="center" height="25"><%if(null == projList[i]){out.println("");}else{out.println(projList[i]);} %></td><%
				       }
				       //print column null	
				       for (int i=0;i<loop;i++) {
						   %><td class="col_name" width="4%" align="center" height="25">&nbsp;</td>					  		 
						   <%
				       }
				       %><td class="col_name" width="7%" align="center" height="25">รวม</td><%}  
			 }%>
    </tr>
<%-- ####################################################body########################################################################### --%>
<%
  //SQL MAIN
 // mainboq = doString.checkString(request.getParameter("mainboq"),"00");	
 // subboq = doString.checkString(request.getParameter("subboq"),"nnnn");	
 // seqboq = doString.checkString(request.getParameter("seqboq"),"nnnnnnnn");	
 //  System.out.println("Select #2 :"+subboq);
  // System.out.println("Select #3 :"+seqboq);
  //type ==01 is
  //type == 02 is
  //int  sumIntColumn []  = new int[projList.length];
  int  sumIntRow []  = new int[projList.length];
  for(int i = 0;i<sumIntRow.length;i++){
      sumIntRow[i] = 0;
  }
   int MAX =  0;
   MAX = projList.length;
   int MAX_LOOP = 12-MAX;  
   long sumColumn13 = 0;
   
   	//-------------------- Check Field Name -----------------
	if (type_amt.equals("A")) {
		f_name = " sum(a.q_itmjob ) as cnt ";//"sum(q_itmjob) as q_sum1";
	} else if (type_amt.equals("B")) {
		f_name = " sum(a.q_docno ) as cnt  ";//"sum(q_docno) as q_sum1";
	} else if (type_amt.equals("C")) {
		f_name = " sum(a.z_amount ) as cnt ";//"sum(z_amount) as q_sum1";
	} else if (type_amt.equals("D")) {
		f_name =  " sum(a.q_lock ) as cnt ";//"sum(q_lock) as q_sum1";
	}
 //System.out.println("xxx.<<<----Field Name :"+f_name);
 //System.out.println("xxx.<<<----d_query :"+d_query);
   sql.delete(0,sql.length());
   sql.append(" select distinct a.i_itmjob_main,b.n_itmjob from lan:serv_zeromain a,lan:serv_boq b ")
	.append(" where  a.i_type = '"+type_rep+"' ") //type
	.append(d_query) //by date
	.append(" and ("+queryProject+") ")//project
	.append(" and a.i_cause = '"+r_type+"' "); //cause
	if(!mainboq.equals("") && !"00".equals(mainboq)){
		sql.append("  and a.i_itmjob_main = '"+mainboq+"' ");
	}
	sql.append(" and  a.i_itmjob_main = b.i_itmjob   order by a.i_itmjob_main ");
	
	rs = stmt.executeQuery(sql.toString());
	//System.out.println("1.<<<----SQL Main :"+sql.toString());
	//servlog.endLog();
	StringBuffer jobId = new StringBuffer();
	StringBuffer jobName = new StringBuffer();
	StringBuffer tempName = new StringBuffer();
	while (rs.next()) {	
			   jobId.delete(0,jobId.length());
	           jobId.append(doString.checkString(rs.getString("i_itmjob_main")));
	          
	           jobName.delete(0,jobName.length());
	           jobName.append(doString.checkString(rs.getString("n_itmjob")));
			   //************case level#2			
			   if(!"".equals(subboq) || !subboq.equals("nnnn")){			   	
				       %>
				       <%-- ###New Record#1 --%>
				   		<tr bgcolor="#FFFFCC">
			            <td class="fg_style1 ; dotline" width="45%"><%=jobId.toString() %>
			            <%=doString.DisplayThai(jobName.toString()) %>
			            </td>
			            <% 
			            /***********************Fetch by project**********************************/
                       if (projList!=null) {
                          int  sumMain = 0;      
                 	      for (int i=0;i<projList.length;i++) {
	                 	     int cnt = 0;
	                 	  	 String tempId[] = projList[i].split("\\:");
			                 sql.delete(0,sql.length());
			                  //sum(a.q_itmjob) as cnt
			                 sql.append(" select "+f_name+" from lan:serv_zeromain a where a.i_type = '"+type_rep+"'  and a.i_itmjob_main ='"+jobId.toString()+"' and a.i_cause = '"+r_type+"'  ")
			                    .append(" and  a.i_company='"+tempId[0]+"' and a.i_project='"+tempId[1]+"' ")
			                    .append(d_query);
			                 //System.out.println("SQL xxx :"+sql.toString());
			                 rs1 = stmt1.executeQuery(sql.toString());
			                 if(rs1.next()){
			                 	cnt = rs1.getInt("cnt");
			                 } rs1.close();%>
		                      <td class="fg_style1 ; dotline" width="4%" align="right"><A HREF="javascript:goDetail('<%=projList[i]%>','<%=jobId.toString()%>');"><%=doString.displayNumber("#,###",cnt) %></A></td>
		                      <%  sumMain +=cnt;
		                     	 sumIntRow[i]  +=cnt;
		                       }//End for Loop
		                      
		                       //echo free column 
		                       if(MAX<12){
		                            for (int i=0;i<MAX_LOOP;i++) {
							       %><td class="fg_style1 ; dotline" width="4%" align="center" height="25">&nbsp;</td>					  		 
							        <% }
		                       }
		                       %>
		                       <!-- for subm column -->
		                       <td class="fg_style1 ; dotline" width="7%"  align="right"><a href="javascript:gotoSummaryByProject('<%=jobId.toString()%>','false');"><%=doString.displayNumber("#,###",sumMain) %></a>&nbsp;</td>
		                       <%
		                       sumColumn13 +=sumMain;
		                 }//End check ProjectList
		                 /***************************End Fetch by project******************************/
		               %>
	               </tr>  
				   <%  
					  sql.delete(0,sql.length());
				   	  sql.append(" select distinct a.i_itmjob_main,c.i_itmjob_sub from lan:serv_zeromain a,lan:serv_zerosub c ")
				   	   .append(" where  a.i_type = '"+type_rep+"' ") //type
					   .append(d_query) //by date
				   	  .append(" and ("+queryProject+") ")//project
				   	  .append(" and a.i_cause = '"+r_type+"'   ")//cause
				   	  .append(" and a.i_itmjob_main    ='"+jobId.toString()+"' ")
				   	  .append(" and a.i_itmjob_main    =c.i_itmjob_main ");
				   	  if(!"0000".equals(subboq)){
				   	 	   sql.append("  and c.i_itmjob_sub  =  '"+subboq.substring(2)+"' ");
				   	 }
				   	  sql.append(" order by a.i_itmjob_main,c.i_itmjob_sub ");
	 				  rs1 = stmt1.executeQuery(sql.toString());
					  //System.out.println("2.<<<----SQL sub:"+sql.toString());
					  String subId = "";
					  while(rs1.next()){
					   		subId = doString.checkString(rs1.getString("i_itmjob_sub"),"");
					  	    sql.delete(0,sql.length());
					  	    sql.append(" select n_itmjob from lan:serv_boq ")
			                    .append(" where  i_group = '"+jobId.toString()+"' and i_type= '"+subId+"' and i_seq is null ");
			                    //.append(d_query);
			                 //System.out.println("----->N_SQL sub:"+sql.toString());
			                 rs2 = stmt2.executeQuery(sql.toString());
			                 tempName.delete(0,tempName.length());
			                 if(rs2.next()){
			                     tempName.delete(0,tempName.length());
			                     tempName.append(doString.checkString(rs2.getString("n_itmjob"),""));
			                 }
			                 rs2.close();
							%>
						  <%-- ###New Record#2 --%>
					  	   <tr>
			               <td class="fg_style1 ; dotline" width="45%"><FONT COLOR="rgb(0,50,200)">&nbsp;-&nbsp;<%=doString.checkString(rs1.getString("i_itmjob_main"),"")%>
			               <%=doString.checkString(rs1.getString("i_itmjob_sub"),"")%>
			               <%=doString.DisplayThai(tempName.toString()) %>
			               </FONT></td>
					  	<%
					    /***********************Fetch by project**********************************/
                        if (projList!=null) {   
                          int sumSub = 0;            	  
                 	      for (int i=0;i<projList.length;i++) {
	                 	     int cnt = 0;
	                 	  	 String tempId[] = projList[i].split("\\:");
			                 sql.delete(0,sql.length());
			                  //sum(a.q_itmjob ) as cnt
			                 sql.append(" select "+f_name+" from lan:serv_zerosub a where a.i_type = '"+type_rep+"' and a.i_itmjob_main ='"+jobId.toString()+"'  and a.i_itmjob_sub ='"+subId+"' and a.i_cause = '"+r_type+"'  ")
			                    .append(" and  a.i_company='"+tempId[0]+"' and a.i_project='"+tempId[1]+"' ")
			                    .append(d_query);    
			                 //System.out.println("----->sSQL test:"+sql.toString());
			                 rs2 = stmt2.executeQuery(sql.toString());
			                 if(rs2.next()){
			                 	cnt = rs2.getInt("cnt");
			                 } rs2.close();%>
	                         <td class="fg_style1 ; dotline" width="4%" align="right"><A HREF="javascript:goDetail('<%=projList[i]%>','<%=jobId.toString()+subId%>');"><%=doString.displayNumber("#,###",cnt) %></A></td>
	                     <%  sumSub +=cnt;
	                        //sumIntRow[i]  +=cnt;
	                       }//End for Loop	                        
	                        //echo free column 
		                    if(MAX<12){
		                            for (int i=0;i<MAX_LOOP;i++) {
							       %><td class="fg_style1 ; dotline" width="4%" align="center" height="25">&nbsp;</td>					  		 
							        <% }
		                    }
		                     %>
		                     <!-- for subm column -->
		                     <td class="fg_style1 ; dotline" width="7%"  align="right"><a href="javascript:gotoSummaryByProject('<%=jobId.toString()+subId%>','false');"><%=doString.displayNumber("#,###",sumSub) %></a>&nbsp;</td>
		                     <% //sumColumn13 +=sumSub;
		                 }//End check ProjectList
		                  /***************************End Fetch by project******************************/
		                 if("".equals(seqboq) || !"nnnnnnnn".equals(seqboq)){//00000000 all
		                 		//00000000
		                 		sql.delete(0,sql.length());
			                    sql.append(" select distinct a.i_itmjob_main,a.i_itmjob_sub,a.i_itmjob_seq   from lan:serv_zeroseq a  ")
			                       //.append("  where  a.i_type = '01' ")
			                       .append(" where  a.i_type = '"+type_rep+"' ") //type
					   			  .append(d_query) //by date
			                      .append(" and ("+queryProject+") ")//project
			                       .append("  and a.i_cause = '"+r_type+"'   ")//cause
			                       .append("  and a.i_itmjob_main    ='"+jobId.toString()+"' ") //param main
			                       .append("  and a.i_itmjob_sub = '"+subId+"' ");//param second
			                       if(seqboq.equals("00000000")){
			                           sql.append("  order by a.i_itmjob_main,a.i_itmjob_sub   "); //param third
			                       }else{
			                         sql.append(" and a.i_itmjob_seq  = '"+seqboq.substring(4)+"'");
			                       	 sql.append("  order by a.i_itmjob_main,a.i_itmjob_sub ,a.i_itmjob_seq  ");
			                       }
			                      // System.out.println("seqboq.substring(4):"+seqboq.substring(4));
			                     // System.out.println("3.<<----SQL item:"+sql.toString());
			                       rs3 = stmt3.executeQuery(sql.toString());
			                        String itemId = "";
			                       while(rs3.next()){
			                       		  itemId = doString.checkString(rs3.getString("i_itmjob_seq"),"");
			                       		 sql.delete(0,sql.length());
					  	    			 sql.append(" select n_itmjob from lan:serv_boq ")
			                    		    .append(" where  i_group = '"+jobId.toString()+"' and i_type= '"+subId+"' and i_seq ='"+itemId+"' ");
			                				//System.out.println("----->N_SQL item:"+sql.toString());
			                 				rs2 = stmt2.executeQuery(sql.toString());
			                 				tempName.delete(0,tempName.length());
			                 				if(rs2.next()){
			                     				tempName.delete(0,tempName.length());
			                     				tempName.append(doString.checkString(rs2.getString("n_itmjob"),""));
			                 				}
			                 				rs2.close();
			                 				%>
			                 				<%-- ###New Record#3 --%>
			                 			    <tr>
							                <td  class="fg_style1 ; item ; dotline" width="45%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;<%=itemId%>
							                <%=doString.DisplayThai(tempName.toString()) %>
							                </td>
							                <% 
							                /***********************Fetch by project**********************************/
					                        if (projList!=null) {      
					                              int sumSeq= 0;           	  
						                 	      for (int i=0;i<projList.length;i++) {
							                 	     int cnt = 0;
							                 	  	 String tempId[] = projList[i].split("\\:");
									                 sql.delete(0,sql.length());
									                 // sum(a.q_itmjob ) as cnt
									                 sql.append(" select "+f_name+" from lan:serv_zeroseq a where a.i_type = '"+type_rep+"'  and a.i_itmjob_main ='"+jobId.toString()+"'  and a.i_itmjob_sub ='"+subId+"'  ")
									                 	.append(" and i_itmjob_seq = '"+itemId+"'  and a.i_cause = '"+r_type+"'  ")
									                    .append(" and  a.i_company='"+tempId[0]+"' and a.i_project='"+tempId[1]+"' ")
									                    .append(d_query);
									                // System.out.println("----->Get SQL item:"+sql.toString());
									                 rs2 = stmt2.executeQuery(sql.toString());
									                 if(rs2.next()){
									                 	cnt =  rs2.getInt("cnt"); //rs2.getInt("cnt") 
									                 } rs2.close();%>
						                      <td class="fg_style1 ; dotline" width="4%" align="right"><A HREF="javascript:goDetail('<%=projList[i]%>','<%=jobId.toString()+subId+itemId%>');"><%=doString.displayNumber("#,###",cnt) %></A></td>
						                     <% sumSeq +=cnt;
						                        //sumIntRow[i]  +=cnt;
						                        }//End for Loop
						                        
						                         //echo free column 
							                    if(MAX<12){
							                            for (int i=0;i<MAX_LOOP;i++) {
												       %><td class="fg_style1 ; dotline" width="4%" align="center" height="25">&nbsp;</td>					  		 
												        <% }
							                    }
							                     %>
							                     <!-- for subm column -->
							                     <td class="fg_style1 ; dotline" width="7%"  align="right"><a href="javascript:gotoSummaryByProject('<%=jobId.toString()+subId+itemId%>','false');"><%=doString.displayNumber("#,###",sumSeq )%></a>&nbsp;</td>
						                        <%//sumColumn13 +=sumSeq;
							                 }//End check ProjectList
							                 %>
							                 </tr>
							                 <%
							                 /***************************End Fetch by project******************************/
			                 }//End while level#3
		                 }//End check item
					  }//End while rs1 next	 Level#2				  
				   }//End if Level#2
	      }//while main #Level#1
 %>
<%-- ####################################################Footer################################################################### --%>  
    <tr>
    <td class="col_name1" width="45%" height="25" align="center">รวม</td>
    <%
    	if (projList!=null) {
			   int max = projList.length;
			  // int j = 0;
			   if(max==12){
				     for (int i=0;i<projList.length;i++) {
					  %><td  class="fg_style1 ; col_name1" width="4%" height="25"  align="right"><a href="javascript:gotoSummaryByProject('<%=projList[i]%>','true');"><%=doString.displayNumber("#,###",sumIntRow[i]) %></a>&nbsp;</td>					  		
					  <%} %>
				      <td  class="fg_style1 ; col_name1" width="7%" height="25"  align="right"><a href="javascript:gotoAllDetail();"><%=doString.displayNumber("#,###",sumColumn13) %></a>&nbsp;</td>
				      <%
				      //if 12
			    }else{
				       int loop = 12-max;
				       for (int i=0;i<max;i++) {
						   %><td  class="fg_style1 ; col_name1" width="4%" height="25" align="right"><a href="javascript:gotoSummaryByProject('<%=projList[i]%>','true');"><%=doString.displayNumber("#,###",sumIntRow[i]) %></a>&nbsp;</td><%
				       }
				       //print column null	
				       for (int i=0;i<loop;i++) {
						   %><td  class="fg_style1 ; col_name1" width="4%"  height="25" align="right">&nbsp;</td>					  		 
						   <%
				       }
				       %><td  class="fg_style1 ; col_name1" width="7%" height="25" align="right">
				       <a href="javascript:gotoAllDetail();"><%=doString.displayNumber("#,###",sumColumn13) %></a>&nbsp;</td>
				       <%}  
			}%>
    </tr>
 </table>
 </td>
 </tr>
 </table>

<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">&nbsp; </td>                               	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15" onclick="returnReport();" style="cursor:hand">&nbsp;
              <a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>  
        </table>  

          </td>
        </tr>
      </table>
	
<input type="hidden" name="query" value="<%=queryProject%>">
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
	conn.close();
	stmt=null;
	conn=null;
} catch (Exception e) {
	System.out.println("ERROR SERV_ReportZero02.jsp : " + e.getMessage());
	System.out.println("ERROR SERV_ReportZero02.jsp SQL : " + sql.toString());
	throw new ServletException(e.getMessage());
} finally {
	// Clean up.
	try {
		if (rs != null) rs.close();
		if (rs1 != null) rs1.close();
		if (rs2 != null) rs2.close();
		if (rs3 != null) rs2.close();
		if (stmt != null) stmt.close();
		if (stmt1 != null) stmt1.close();
		if (stmt2 != null) stmt2.close();
		if (stmt3 != null) stmt2.close();
		if (conn != null) conn.close();
	}
	catch( SQLException ignore ){}
}
%>
