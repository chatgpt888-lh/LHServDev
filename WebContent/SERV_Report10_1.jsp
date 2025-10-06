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
		try
		{
			getDS();
		}
		catch(Exception es)
		{
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
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_Report10_1.jsp";
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


double q_mth1 = 0, q_mth2 = 0, q_mth3 = 0, q_mth4 = 0, q_mth5 = 0, q_mth6 = 0, q_mth7 = 0;
double q_mth8 = 0, q_mth9 = 0, q_mth10 = 0, q_mth11 = 0, q_mth12 = 0, q_mth13 = 0;
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

  String[] projList = request.getParameterValues("sel_proj");
  	  String queryProject = "";			
	  String proj = "";
	  int line = 0;

mainboq = doString.checkString(request.getParameter("mainboq"),"00");	
subboq = doString.checkString(request.getParameter("subboq"),"nnnn");	
seqboq = doString.checkString(request.getParameter("seqboq"),"nnnnnnnn");		

if (sel_time.equals("A")) {   // สรุปตามวันแจ้งซ่อม
		 type_date = "แจ้งซ่อม";
		 type_rep = "01";
		 d_start = thaiMonth[Integer.parseInt(A_StartM)]+" "+(Integer.parseInt(A_StartY)+543);
		 d_end = thaiMonth[Integer.parseInt(A_EndM)]+" "+(Integer.parseInt(A_EndY)+543);    
		 d_query = "and i_date between mdy("+A_StartM+",1, "+(Integer.parseInt(A_StartY))+") and mdy("+A_EndM+",1, "+(Integer.parseInt(A_EndY))+") ";
		 d_query2 = "and c.i_date between mdy("+A_StartM+",1, "+(Integer.parseInt(A_StartY))+") and mdy("+A_EndM+",1, "+(Integer.parseInt(A_EndY))+") ";
		 //d_query = "and i_month between '"+A_StartM+"' and '"+A_EndM+"' and i_year between '"+(Integer.parseInt(A_StartY)+543)+"' and '"+(Integer.parseInt(A_EndY)+543)+"' ";
		 //d_query2 = "and c.i_month between '"+A_StartM+"' and '"+A_EndM+"' and c.i_year between '"+(Integer.parseInt(A_StartY)+543)+"' and '"+(Integer.parseInt(A_EndY)+543)+"' ";
} else if (sel_time.equals("B")) {    //  สรุปตามวันที่โอน
		 type_date = "โอน";
		 type_rep = "02";
		 d_start = thaiMonth[Integer.parseInt(B_StartM)]+" "+(Integer.parseInt(B_StartY)+543);
		 d_end = thaiMonth[Integer.parseInt(B_EndM)]+" "+(Integer.parseInt(B_EndY)+543);   
		 d_query = "and i_date between mdy("+B_StartM+",1, "+(Integer.parseInt(B_StartY))+") and mdy("+B_EndM+",1, "+(Integer.parseInt(B_EndY))+") ";
		 d_query2 = "and c.i_date between mdy("+B_StartM+",1, "+(Integer.parseInt(B_StartY))+") and mdy("+B_EndM+",1, "+(Integer.parseInt(B_EndY))+") ";
		 //d_query = "and i_month between '"+B_StartM+"' and '"+B_EndM+"' and i_year between '"+(Integer.parseInt(B_StartY)+543)+"' and '"+(Integer.parseInt(B_EndY)+543)+"' ";   //
		 //d_query2 = "and c.i_month between '"+B_StartM+"' and '"+B_EndM+"' and c.i_year between '"+(Integer.parseInt(B_StartY)+543)+"' and '"+(Integer.parseInt(B_EndY)+543)+"' ";   //
}
		//----------------------------- Reason Type----------------------------- 
		 type_display = "";
		 sql.delete(0,sql.length());	
		 sql.append("select * from lan:serv_xstd ")
			  .append("where i_type = '06' ")
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
<TITLE>สรุปงานซ่อมแยกตามสาเหตุการแจ้งซ่อม สรุปตามวันที่โอน/วันที่แจ้ง</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
<!--

  function goDetail(t_tran,i_itmjob) {
		//document.forms[0].d_st.value=d_start;	
		//document.forms[0].d_en.value=d_end;
		//document.forms[0].d_qu.value=d_query;
		//document.forms[0].query.value=query;
		//document.forms[0].r_ty.value=r_type;
		//document.forms[0].type_r.value=type_rep;
		document.forms[0].t_tr.value=t_tran;
		document.forms[0].i_itm.value=i_itmjob;	  
	  	document.forms[0].action='<%=Constants.APP_PATH%>/SERV_ReportSubDet.jsp';
		document.forms[0].submit();
	}

function returnReport() {
	  	document.forms[0].action='<%=Constants.APP_PATH%>/SERV_Report10.jsp';
		document.forms[0].submit();
}

  //-->
</SCRIPT>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM NAME = "frmRep" ACTION="SERV_Report10_1.jsp" METHOD="POST">

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
<input type="hidden" name="t_tr" value="">
<input type="hidden" name="i_itm" value="">



<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            สรุปงานซ่อมแยกตามสาเหตุการแจ้งซ่อม สรุปตามวันที่โอน/วันที่แจ้ง</td>
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
    <td class="item ; dotline01" height="22" width="15%">      เดือน/ปี ที่<%=type_date%> :</td>
    <td width="85%" colspan="2" class="dotline01"><%=d_start%>&nbsp;&nbsp; ถึง&nbsp;&nbsp;<%=d_end%></td>
    </tr>
  <tr>
    <td width="15%" height="22" class="item ; dotline01">สาเหตุ : </td>
    <td width="85%" colspan="2" class="dotline01"><%=type_display%>&nbsp;</td>
  </tr>
  </table>
  
  <table border="0" width="100%" cellspacing="0" cellpadding="0">
  <%
    if (projList==null) {
		   chk_prj = "ALL";
	}
	  if (projList!=null) {
		  for (int i=0;i<projList.length;i++) {		
				 proj = doString.checkString(projList[i],"");  		
				 
				 System.out.println("proj=="+proj);
				 
				 
				 if (proj.trim().length()>=6) {	
						 if (queryProject.trim().length()>0) queryProject += " or ";
						 queryProject += " (a.i_company='"+proj.substring(0,2)+"' and a.i_project='"+proj.substring(3,6)+"') ";	
				 }
				  %><input type="hidden" name="sel_proj" value="<%=proj%>"><%


				//---============= get Project Details ===============----//
				sql.delete(0,sql.length()); 
				sql.append(" select * from lan:acxprojt ")
					  .append(" where i_company='").append(proj.length()>=6 ? proj.substring(0,2) : "").append("' ")
					  .append(" and i_project='").append(proj.length()>=6 ? proj.substring(3,6) : "").append("' ");
				servlog.startLog(sql.toString());
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
	%>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="15%" height="22" class="item ; dotline01">ระบุหมวด : </td>
    <td width="10%" class="dotline01 ; item">หมวดหลัก      </td>
    <td width="75%" class="dotline01 ; item"><select size="1" class="box" style="width:400px" name="mainboq" onchange="javascript:frmRep.submit();">
<option value="00">- - - เลือกทุกหมวด - - -</option>
<%
	sql.delete(0,sql.length()); 
	sql.append("select distinct i_itmjob, n_itmjob from lan:serv_boq where i_type is null and i_seq is null ");
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
	sql.append("select distinct i_itmjob, n_itmjob from lan:serv_boq where i_group = '"+mainboq+"' and  i_type is not null and i_seq is null order by i_itmjob ");
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
	sql.append("select distinct i_itmjob, n_itmjob from lan:serv_boq where i_group = '"+grp+"' and i_type = '"+typ+"' and  i_type is not null and i_seq is not null order by i_itmjob ");
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
                <td class="item_tab2" width="200">รายละเอียดงานซ่อมแยกตามหมวด</td>
                <td class="item_tab3"></td>
                <td>&nbsp;<input type="radio" value="A" name="type_amt" <% if (type_amt.equals("A")) { out.println("checked"); } %>>จำนวนรายการ&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" value="B" name="type_amt" <% if (type_amt.equals("B")) { out.println("checked"); } %>>จำนวนใบแจ้งซ่อม&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" value="C" name="type_amt" <% if (type_amt.equals("C")) { out.println("checked"); } %>>จำนวนเงิน&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" value="D" name="type_amt" <% if (type_amt.equals("D")) { out.println("checked"); } %>>จำนวนแปลง&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				  <A HREF="javascript:frmRep.submit();"><img border="0" src="images/bu_R.gif" align="absmiddle" width="16" height="16" style="cursor:hand"></a></td>
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
          <td class="col_name" width="22%">รายการซ่อม</td>
          <td class="col_name" width="6%">หลังโอน<br>
            1 เดือน</td>
          <td class="col_name" width="6%">หลังโอน<br>
2 เดือน</td>
          <td class="col_name" width="6%">หลังโอน<br>
3 เดือน</td>
          <td class="col_name" width="6%">หลังโอน<br>
4 เดือน</td>
          <td class="col_name" width="6%">หลังโอน<br>
5 เดือน</td>
          <td class="col_name" width="6%">หลังโอน<br>
6 เดือน</td>
          <td class="col_name" width="6%">หลังโอน<br>
7 เดือน</td>
          <td class="col_name" width="6%">หลังโอน<br>
8 เดือน</td>
          <td class="col_name" width="6%">หลังโอน<br>
9 เดือน</td>
          <td class="col_name" width="6%">หลังโอน<br>
10 เดือน</td>
          <td class="col_name" width="6%">หลังโอน<br>
11 เดือน</td>
          <td class="col_name" width="6%">หลังโอน<br>
12 เดือน</td>
          <td class="col_name" width="6%">หลังโอน<br>
            &gt;12 เดือน </td>
        </tr>

<%
	int type_trf = 0;
	/*chk_prj = "";
	if (!proj.equals("") && proj != null) {
		if (proj.equals("LH:ALL")) {
				chk_prj = "ALL";
		} else {
				chk_prj = "";
		}
	}
*/

	/*//-------------------- Check Table Name -----------------
		if (subboq.equals("nnnn") && seqboq.equals("nnnnnnnn")) {
				tb_name = "lan:serv_trfmain a";	
		} else {
				tb_name = "lan:serv_trfseq a";	
		}*/
		//-------------------- Check Field Name -----------------
		if (type_amt.equals("A")) {
			f_name = "sum(q_itmjob) as q_sum1";
		} else if (type_amt.equals("B")) {
			f_name = "sum(q_docno) as q_sum1";
		} else if (type_amt.equals("C")) {
			f_name = "sum(z_amount) as q_sum1";
		} else if (type_amt.equals("D")) {
			f_name = "sum(q_lock) as q_sum1";
		}


	//-------------------Main Query ----------------------
	sql.delete(0,sql.length());
	sql.append("select distinct a.i_itmjob_main ")                                                 
		.append("from lan:serv_trfmain a ")
		.append("where a.i_type = '"+type_rep+"' ");
if (!chk_prj.equals("ALL")) {
   sql.append("and ("+queryProject+") ");
}
   sql.append("and a.i_cause = '"+r_type+"' ");	
if (!mainboq.equals("00")) {
   sql.append("and a.i_itmjob_main = '"+mainboq+"' ");
}
  sql.append(""+d_query+"")			  
	   .append("order by a.i_itmjob_main ");
 //System.out.println("main=="+sql.toString());
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	while (rs.next()) {		

							// ------------------------NAME ITMJOB ------------------------
							n_itmjob = "";
							sql.delete(0,sql.length());
							sql.append("select n_itmjob from lan:serv_boq ")
								 .append("where i_itmjob = '"+doString.checkString(rs.getString("i_itmjob_main"))+"' ");
							  //System.out.println(sql.toString());
							servlog.startLog(sql.toString());
							rs2 = stmt2.executeQuery(sql.toString());
							servlog.endLog();
							if (rs2.next()) {
									n_itmjob = doString.checkString(doString.DisplayThai(rs2.getString("n_itmjob")));
							}	

				//--------------------------- ITEM Main Only----------------------------
			   sql.delete(0,sql.length());
			   sql.append("select i_itmjob_main, i_type_trf, "+f_name+" ")                                     
					.append("from lan:serv_trfmain a ")	
					.append("where i_type = '"+type_rep+"' ");
		 if (!chk_prj.equals("ALL")) {
			   sql.append("and ("+queryProject+") ");
		  }
			   sql.append("and i_cause = '"+r_type+"' ")								
					.append("and i_itmjob_main = '"+doString.checkString(rs.getString("i_itmjob_main"))+"' ")
			        .append(""+d_query+"")	
				    .append("group by 1,2 ")
				    .append("order by 1,2 ");
			  System.out.println("qqq=="+sql.toString());
			   servlog.startLog(sql.toString());
				rs2 = stmt2.executeQuery(sql.toString());
				servlog.endLog();
				while (rs2.next()) {
				//	total_itmmain = 0;
		
						 for (int j=0;j<13;j++) {	
								 type_trf = rs2.getInt("i_type_trf");			
					
								 if (type_trf-1 == j) {
										q_mth[j] = new Integer(rs2.getInt("q_sum1"));			
								 } 
							//	 total_itmmain += q_mth[j].intValue();	// totol item main																	
						 } // end for	
				 } // end while		
				//total_all += total_itmmain;

			%>					<tr>								
										 <td width="22%" height="1" align="center" class="item ; dotline" bgcolor="#FFFFCC"><div align="left"><FONT COLOR="rgb(0,50,200)"><%=doString.checkString(rs.getString("i_itmjob_main"))%>&nbsp;<%=n_itmjob%></FONT></div></td>
										<%				//loop = 0;
												for (int i=0;i<13;i++) {    

										 %>			<td width="6%" align="right" valign="middle" class="dotline" bgcolor="#FFFFCC"><A HREF="javascript:goDetail('<%=i+1%>','<%=doString.checkString(rs.getString("i_itmjob_main"))%>');"><%=format1.format(q_mth[i].intValue())%>&nbsp;</A></td>
										 <%
														//loop++;		
												} // end for	
										%>
       	</tr>
<% 
		for (int j=0;j<13;j++) {		
				q_mth[j] = new Integer(0);											
			} // end for	

						
						
						//-------------------ITEM Sub Only ----------------------
						sql.delete(0,sql.length());
						sql.append("select distinct a.i_itmjob_main, a.i_itmjob_sub ")                                                 
							.append("from lan:serv_trfsub a ")	
							.append("where a.i_type = '"+type_rep+"' ");
				if (!chk_prj.equals("ALL")) {
					   sql.append("and ("+queryProject+") ");
				}
					   sql.append(""+d_query+"")
						    .append("and i_cause = '"+r_type+"' ")	
				            .append("and a.i_itmjob_main = '"+doString.checkString(rs.getString("i_itmjob_main"))+"' ");
				if (!subboq.equals("0000")) {
					   sql.append("and a.i_itmjob_sub = '"+subboq.substring(2,4)+"' ");
				}
                       sql.append("order by a.i_itmjob_main, a.i_itmjob_sub ");
					  System.out.println("qqq=="+sql.toString());
					   servlog.startLog(sql.toString());
					   rs1 = stmt1.executeQuery(sql.toString());
					   servlog.endLog();
					   while (rs1.next()==true) {			
							
										
										
										// ------------------------NAME ITMJOB ------------------------
											n_itmjob = "";
											sql.delete(0,sql.length());
											sql.append("select n_itmjob from lan:serv_boq ")
												 .append("where i_itmjob = '"+doString.checkString(rs1.getString("i_itmjob_main"))+doString.checkString(rs1.getString("i_itmjob_sub"))+"' ");
											servlog.startLog(sql.toString());
											rs2 = stmt2.executeQuery(sql.toString());
											servlog.endLog();
											if (rs2.next()) {
													n_itmjob = doString.checkString(doString.DisplayThai(rs2.getString("n_itmjob")));
											}

													   sql.delete(0,sql.length());
													   sql.append("select i_itmjob_sub, i_type_trf, "+f_name+" ")                           
															.append("from lan:serv_trfsub a ")                                                         
															.append("where a.i_type = '"+type_rep+"' ");
												if (!chk_prj.equals("ALL")) {
													   sql.append("and ("+queryProject+") ");
												}
													   sql.append("and i_cause = '"+r_type+"' ")											 
													        .append("and  a.i_itmjob_main = '"+doString.checkString(rs1.getString("i_itmjob_main"))+"' ")
															.append("and  a.i_itmjob_sub = '"+doString.checkString(rs1.getString("i_itmjob_sub"))+"' ")                                           
															.append(""+d_query+"")	
															.append("group by 1,2 ")
															.append("order by 1,2 ");  
													   	  //out.println(sql.toString());
														servlog.startLog(sql.toString());
														rs2 = stmt2.executeQuery(sql.toString());
														servlog.endLog();
														while (rs2.next()) {
															 for (int j=0;j<13;j++) {	
																 type_trf = rs2.getInt("i_type_trf");			
																	 if (type_trf-1 == j) {
																			q_mth[j] = new Integer(rs2.getInt("q_sum1"));			
																	 }																													
															 } // end for	
														 } // end while		
%>					
									<tr>						
										 <td width="22%" height="1" align="center" class="item ; dotline"><div align="left"><FONT COLOR="rgb(0,50,200)">&nbsp;-&nbsp;<%=doString.checkString(rs1.getString("i_itmjob_main"))+doString.checkString(rs1.getString("i_itmjob_sub"))%>&nbsp;<%=n_itmjob%></FONT></div></td>
										<%			
												for (int i=0;i<13;i++) {    

										 %>	<td width="6%" align="right" valign="middle" class="dotline"><A HREF="javascript:goDetail('<%=i+1%>','<%=doString.checkString(rs1.getString("i_itmjob_main"))+doString.checkString(rs1.getString("i_itmjob_sub"))%>');"><%=format1.format(q_mth[i].intValue())%>&nbsp;</A></td>
										 <%
														
												} // end for	
										%>
       	</tr>
<%
			for (int j=0;j<13;j++) {		
					q_mth[j] = new Integer(0);											
			} // end for	



									
									//------------------ SEQ ITEM ------------------------												  
								   sql.delete(0,sql.length());
								   sql.append("select distinct c.i_itmjob_main, c.i_itmjob_sub, c.i_itmjob_seq ")                 
										.append("from lan:serv_trfmain a, lan:serv_trfsub b, lan:serv_trfseq c ")                   
										.append("where a.i_type = '"+type_rep+"' ")
									    .append(""+d_query2+"");
							if (!chk_prj.equals("ALL")) {
								   sql.append("and ("+queryProject+") ");
							 }									
								   sql.append("and c.i_cause = '"+r_type+"' ")					
								        .append("and a.i_month = b.i_month ")                                                   
										.append("and b.i_month = c.i_month ")                                                   
										.append("and a.i_year = b.i_year ")                                                   
										.append("and b.i_year = c.i_year ")    
										.append("and a.i_company = b.i_company ")                                                   
										.append("and b.i_company = c.i_company ")                                                   
										.append("and a.i_project = b.i_project ")                                                   
										.append("and b.i_project = c.i_project ")                                                   
										.append("and a.i_type = b.i_type ")                                                         
										.append("and b.i_type = c.i_type ")     
									    .append("and a.i_cause = b.i_cause ")                                                   
										.append("and b.i_cause = c.i_cause ")  
										.append("and c.i_itmjob_main = '"+doString.checkString(rs1.getString("i_itmjob_main"))+"' ")
										.append("and c.i_itmjob_sub = '"+doString.checkString(rs1.getString("i_itmjob_sub"))+"' ");
						if (!seqboq.equals("00000000")) {
							       sql.append("and c.i_itmjob_seq = '"+seqboq+"' ");
						}
								   sql.append("and a.i_itmjob_main = b.i_itmjob_main ")                                           
										.append("and b.i_itmjob_main = c.i_itmjob_main ")                                           
										.append("and b.i_itmjob_sub = c.i_itmjob_sub ")                                    
										.append("order by c.i_itmjob_main, c.i_itmjob_sub, c.i_itmjob_seq ");
										//out.println(sql.toString());
								   servlog.startLog(sql.toString());
									rs3 = stmt3.executeQuery(sql.toString());
									servlog.endLog();
									while (rs3.next()) {

														// ------------------------NAME ITMJOB ------------------------
														n_itmjob = "";
														sql.delete(0,sql.length());
														sql.append("select n_itmjob from lan:serv_boq ")
															 .append("where i_itmjob = '"+doString.checkString(rs3.getString("i_itmjob_main"))+doString.checkString(rs3.getString("i_itmjob_sub"))+doString.checkString(rs3.getString("i_itmjob_seq"))+"' ");
														servlog.startLog(sql.toString());
														rs2 = stmt2.executeQuery(sql.toString());
														servlog.endLog();
														if (rs2.next()) {
																 if (doString.checkString(doString.DisplayThai(rs2.getString("n_itmjob")))!=null && !doString.checkString(doString.DisplayThai(rs2.getString("n_itmjob"))).equals("")) {
																			 if (doString.checkString(doString.DisplayThai(rs2.getString("n_itmjob"))).length() >= 30) {
																					n_itmjob = doString.checkString(doString.DisplayThai(rs2.getString("n_itmjob"))).substring(0,30);																										
																			 } else {
																					n_itmjob = doString.checkString(doString.DisplayThai(rs2.getString("n_itmjob")));
																			 }
																 }																									
														} // end if rs2													  
														

															   
															   
															   sql.delete(0,sql.length());
															   sql.append("select i_itmjob_seq, i_type_trf, "+f_name+" ")                           
																	.append("from lan:serv_trfseq a ") 
																	.append("where a.i_type = '"+type_rep+"' ");
													if (!chk_prj.equals("ALL")) {
														       sql.append("and ("+queryProject+") ");
													}		
															   sql.append("and i_cause = '"+r_type+"' ")												
															        .append("and  a.i_itmjob_main = '"+doString.checkString(rs3.getString("i_itmjob_main"))+"' ")
																	.append("and  a.i_itmjob_sub = '"+doString.checkString(rs3.getString("i_itmjob_sub"))+"' ")  
																	.append("and  a.i_itmjob_seq = '"+doString.checkString(rs3.getString("i_itmjob_seq"))+"' ")          
																	.append(""+d_query+"")	
																	.append("group by 1,2 ")
																	.append("order by 1,2 ");    
															   //System.out.println(sql.toString());
															   servlog.startLog(sql.toString());
																rs2 = stmt2.executeQuery(sql.toString());
																servlog.endLog();
																while (rs2.next()) {											
																	 for (int j=0;j<13;j++) {	
																		 type_trf = rs2.getInt("i_type_trf");			
																			 if (type_trf-1 == j) {
																					q_mth[j] = new Integer(rs2.getInt("q_sum1"));			
																			 }																													
																	 } // end for	
																 } // end while		
%>
										<tr>
												<td width="22%" height="1" align="center" class="item ; dotline"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;<%=doString.checkString(rs3.getString("i_itmjob_main"))+doString.checkString(rs3.getString("i_itmjob_sub"))+doString.checkString(rs3.getString("i_itmjob_seq"))%>&nbsp;<%=n_itmjob%></div></td>
										<%			
												for (int i=0;i<13;i++) {    

										 %>	<td width="6%" align="right" valign="middle" class="dotline"><A HREF="javascript:goDetail('<%=i+1%>','<%=doString.checkString(rs3.getString("i_itmjob_main"))+doString.checkString(rs3.getString("i_itmjob_sub"))+doString.checkString(rs3.getString("i_itmjob_seq"))%>');"><%=format1.format(q_mth[i].intValue())%>&nbsp;</A></td>
										 <%														
												} // end for	
										%>
       						</tr>
<%
						for (int j=0;j<13;j++) {		
							q_mth[j] = new Integer(0);											
						} // end for	
			} // end while
		} // end while rs1 
	} // end while main 
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

<%
	int cnt_itmjob = 0, cnt_docno = 0, cnt_amount = 0, cnt_lock = 0;
	//---------------------- TOTAL ITMJOB -----------------------
		   sql.delete(0,sql.length());
		   sql.append("select count(a.i_itmjob) as cnt ")
				.append("from lan:serv_trfdet a ")
			    .append("where a.i_rep_type = '"+type_rep+"' ");
	 if (!chk_prj.equals("ALL")) {
		   sql.append("and ("+queryProject+") ");
      }		   
		   sql.append(""+d_query+"");
	if (!r_type.equals("99")) {
		   sql.append("and a.f_remark = '"+r_type+"' ");
	}		   
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
		    if (rs.next()) {
				cnt_itmjob = rs.getInt("cnt");
			}

	//---------------------- TOTAL DOCNO -----------------------
		   sql.delete(0,sql.length());
		   sql.append("select count(distinct a.i_docno) as cnt ")
				.append("from lan:serv_trfdet a ")
			    .append("where a.i_rep_type = '"+type_rep+"' ");
	 if (!chk_prj.equals("ALL")) {
		   sql.append("and ("+queryProject+") ");
      }		   
		   sql.append(""+d_query+"");
	if (!r_type.equals("99")) {
		   sql.append("and a.f_remark = '"+r_type+"' ");
	}		   
			servlog.startLog(sql.toString());
		   rs = stmt.executeQuery(sql.toString());
		   servlog.endLog();
		    if (rs.next()) {
				cnt_docno = rs.getInt("cnt");
			}
	//---------------------- TOTAL Z_AMOUNT -----------------------
		   sql.delete(0,sql.length());
		   sql.append("select sum(a.z_amount_pv) as cnt ")
				.append("from lan:serv_trfdet a ")
			    .append("where a.i_rep_type = '"+type_rep+"' ");
	 if (!chk_prj.equals("ALL")) {
		   sql.append("and ("+queryProject+") ");
      }		   
		   sql.append(""+d_query+"");
	if (!r_type.equals("99")) {
		   sql.append("and a.f_remark = '"+r_type+"' ");
	}		   
			servlog.startLog(sql.toString());
		   rs = stmt.executeQuery(sql.toString());
		   servlog.endLog();
		    if (rs.next()) {
				cnt_amount = rs.getInt("cnt");
			}
	//---------------------- TOTAL LOCK -----------------------
			sql.delete(0,sql.length());
		   sql.append("select count(distinct a.i_lock) as cnt ")
				.append("from lan:serv_trfdet a ")
			    .append("where a.i_rep_type = '"+type_rep+"' ");
	 if (!chk_prj.equals("ALL")) {
		   sql.append("and ("+queryProject+") ");
      }		   
		   sql.append(""+d_query+"");
	if (!r_type.equals("99")) {
		   sql.append("and a.f_remark = '"+r_type+"' ");
	}		   
			servlog.startLog(sql.toString());
			//out.println(sql.toString());
		   rs = stmt.executeQuery(sql.toString());
		   servlog.endLog();
		    if (rs.next()) {
				cnt_lock = rs.getInt("cnt");
			}
%>
	<table border="0" width="100%" cellspacing="0" cellpadding="0" height="20px">
        <tr>
          <td width="100%" align="left" class="item"><FONT COLOR="#0000CC">จำนวนรายการรวม </FONT><%=cnt_itmjob%><FONT COLOR="#0000CC"> รายการ,    จำนวนใบแจ้งซ่อม </FONT><%=cnt_docno%><FONT COLOR="#0000CC"> ใบ,    จำนวนเงิน </FONT><%=doString.displayNumber("#,###.0", cnt_amount)%><FONT COLOR="#0000CC"> บาท,    จำนวนแปลง </FONT><%=cnt_lock%><FONT COLOR="#0000CC"> แปลง</FONT></td>
        </tr>
      </table>
		<br style="font-size:3pt">
      <table border="0" width="100%" cellspacing="0" cellpadding="0" height="20px">
        <tr class="gray">
          <td width="100%" align="left" class="item">** ทุกรายการต้องผ่านการ Approve จาก VP</td>
        </tr>
      </table>
<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">
<!--
            <a href="#"><img border="0" src="images/act_viewexcel.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>       --> </td>   
                  	
                  	
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
	System.out.println("ERROR SERV_Report10_1.jsp : " + e.getMessage());
	System.out.println("ERROR SERV_Report10_1.jsp SQL : " + sql.toString());
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
