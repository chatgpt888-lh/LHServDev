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
String jName = "SERV_Report12_1.jsp";
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

	int itm = 0, itm_main = 0, total_q_mth = 0;
	String i_itm[] = new String[40];
	String n_itm[] = new String[40];
	//String ite_det[] = new String[200];
	Integer q_mth[] = newIntegerArray(40);
	Integer q_item[] = newIntegerArray(40);
	String repdisplay = doString.checkString(request.getParameter("repdisplay"),"");
	String sel_time = doString.checkString(request.getParameter("sel_time"),"");
	String r_type = doString.checkString(request.getParameter("r_type"),"");
	//------------------------------------ Date Job -----------------------------------------
	String A_StartM = doString.checkString(request.getParameter("A_StartM"),"00");
	String A_StartY = doString.checkString(request.getParameter("A_StartY"),"0000");
	String A_EndM = doString.checkString(request.getParameter("A_EndM"),"00");
	String A_EndY = doString.checkString(request.getParameter("A_EndY"),"0000");
	//------------------------------------ Date Close Law ---------------------------------
	String B_StartM = doString.checkString(request.getParameter("B_StartM"),"00");
	String B_StartY = doString.checkString(request.getParameter("B_StartY"),"0000");
	String B_EndM = doString.checkString(request.getParameter("B_EndM"),"00");
	String B_EndY = doString.checkString(request.getParameter("B_EndY"),"0000");
	String mainboq = doString.checkString(request.getParameter("mainboq"),"00");	
	String subboq = doString.checkString(request.getParameter("subboq"),"nnnn");	
	String type_amt = doString.checkString(request.getParameter("type_amt"),"A");


	String type_date = "", type_rep = "", d_start = "", d_end = "", d_query = "", d_query2 = "", n_repdisplay = "";
	String option = "", type_display = "", n_subject = "", n_grp = "", f_name = "", tb_name = "", n_field = "", grp_by = "";
	String get_field = "", ven_name = "", head_det = "", chk_prj = "";

	if (repdisplay.equals("01")) {
			n_repdisplay = "ตามแบบบ้าน";
			n_subject = "แบบบ้าน";
	} else if (repdisplay.equals("02")) {
			n_repdisplay = "ตามประเภทบ้าน";
			n_subject = "ประเภทบ้าน";
	} if (repdisplay.equals("03")) {
			n_repdisplay = "ตามผู้รับเหมา";
			n_subject = "ผู้รับเหมา";
	}
	
	if (sel_time.equals("A")) {   // สรุปตามวันแจ้งซ่อม
			 type_date = "แจ้งซ่อม";
			 type_rep = "01";
			 d_start = thaiMonth[Integer.parseInt(A_StartM)]+" "+(Integer.parseInt(A_StartY)+543);
			 d_end = thaiMonth[Integer.parseInt(A_EndM)]+" "+(Integer.parseInt(A_EndY)+543);       
			 d_query = "and i_date between mdy("+A_StartM+",1, "+(Integer.parseInt(A_StartY))+") and mdy("+A_EndM+",1, "+(Integer.parseInt(A_EndY))+") ";
			 //d_query = "and i_month between '"+A_StartM+"' and '"+A_EndM+"' and i_year between '"+(Integer.parseInt(A_StartY)+543)+"' and '"+(Integer.parseInt(A_EndY)+543)+"' ";
			 
	} else if (sel_time.equals("B")) {    //  สรุปตามวันที่โอน
			 type_date = "โอน";
			 type_rep = "02";
			 d_start = thaiMonth[Integer.parseInt(B_StartM)]+" "+(Integer.parseInt(B_StartY)+543);
			 d_end = thaiMonth[Integer.parseInt(B_EndM)]+" "+(Integer.parseInt(B_EndY)+543);   
			 d_query = "and i_date between mdy("+B_StartM+",1, "+(Integer.parseInt(B_StartY))+") and mdy("+B_EndM+",1, "+(Integer.parseInt(B_EndY))+") ";
			 //d_query = "and i_month between '"+B_StartM+"' and '"+B_EndM+"' and i_year between '"+(Integer.parseInt(B_StartY)+543)+"' and '"+(Integer.parseInt(B_EndY)+543)+"' ";   //
			 
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
<TITLE>สรุปงานซ่อมแยกตามสาเหตุการแจ้งซ่อม สรุปตามแบบบ้าน / ผู้รับเหมา</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
<!--

  function goDetail(itm,htyp) {
		document.forms[0].item.value=itm;
		document.forms[0].h_type.value=htyp;	  
	  	document.forms[0].action='<%=Constants.APP_PATH%>/SERV_ReportSubType.jsp';
		document.forms[0].submit();
	}

function returnReport() {
	  	document.forms[0].action='<%=Constants.APP_PATH%>/SERV_Report12.jsp';
		document.forms[0].submit();
}
  //-->
</SCRIPT>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM NAME = "frmRep" ACTION="SERV_Report12_1.jsp" METHOD="POST">
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
<input type="hidden" name="repdisplay" value="<%=repdisplay%>">
<input type="hidden" name="n_repdisplay" value="<%=n_repdisplay%>">

<input type="hidden" name="item" value="">
<input type="hidden" name="h_type" value="">


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            สรุปงานซ่อมแยกตามสาเหตุการแจ้งซ่อม สรุปตามแบบบ้าน / ผู้รับเหมา</td>
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
  <tr>
    <td width="15%" height="22" class="item ; dotline01">รายงานที่ต้องการ : </td>
    <td colspan="2" class="dotline01"><%=n_repdisplay%></td>
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
				 proj = doString.checkString(projList[i],"");  		
				 if (proj.trim().length()>=6) {	
						 if (queryProject.trim().length()>0) queryProject += " or ";
						 queryProject += " (i_company='"+proj.substring(0,2)+"' and i_project='"+proj.substring(3,6)+"') ";	
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
		  queryProject = " i_company='' and i_project='' ";
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

<%
	chk_prj = "";
	if (!proj.equals("") && proj != null) {
		if (proj.equals("LH:ALL")) {
				chk_prj = "ALL";
		} else {
				chk_prj = "";
		}
	}
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
itm = 0;
get_field = "";
 if (mainboq.equals("00")) {    //   Main Boq Only
		tb_name = "lan:serv_mdlmain";
		n_field = "";
		grp_by = "group by 1,2 order by 1,2 ";
		get_field = "i_itmjob_main";


		   sql.delete(0,sql.length());
		   sql.append("select i_itmjob, n_itmjob from lan:serv_boq ")                                               
				.append("where i_type is null ")                                                            
				.append("and i_seq is null ")
		        .append("order by i_itmjob ");

 } else if (!mainboq.equals("00"))  {
		tb_name = "lan:serv_mdlsub";
		n_field = "i_itmjob_sub, ";
		grp_by = "group by 1,2,3 order by 1,2,3 ";
		get_field = "i_itmjob_sub";
	
		   sql.delete(0,sql.length());
		   sql.append("select i_itmjob, n_itmjob from lan:serv_boq ")                                               
				.append("where i_type is not null ")                                                            
				.append("and i_seq is null ")
		        .append("and i_itmjob[1,2] = '"+mainboq+"' ")
			    .append("order by i_itmjob ");
} 
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
		   while (rs.next()) {	
				   i_itm[itm] =  new String(doString.checkString(rs.getString("i_itmjob")));
				   n_itm[itm] =  new String(doString.checkString(doString.DisplayThai(rs.getString("n_itmjob"))));
				   //System.out.println("i_itm[itm]=="+i_itm[itm]);
				   //System.out.println("n_itm[itm]=="+n_itm[itm]);
				   itm++;	
			} // end while

			   //------------------- Name Group ------------------------
			   n_grp = "";
			   sql.delete(0,sql.length());
			   sql.append("select n_itmjob from lan:serv_boq ")                                               
					.append("where i_type is null ")                                                            
					.append("and i_seq is null ")
					.append("and i_itmjob = '"+mainboq+"' ");
			   servlog.startLog(sql.toString());
			   rs = stmt.executeQuery(sql.toString());
			   servlog.endLog();
			   if (rs.next()==true) {	
					n_grp = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob"))); 			   
			   } else {
					n_grp = "";
			   }		
%>

        <tr>
          <td width="17%" rowspan="2" class="col_name"><%=n_subject%></td>
          <td colspan="<%=itm%>" class="col_name">หมวด<%=n_grp%></td>
          <td rowspan="2" class="col_name" width="5%">รวม</td>		  
          </tr>
        <tr>
<%					
			for (int a=0;a<itm;a++) {			
%>
			<td class="col_nameLow" width="3%"><%=i_itm[a]%></td>
<%
			} // end for
%>          
        </tr>
<%
				sql.delete(0,sql.length());
			   sql.append("select distinct i_detail ")                                     
					.append("from "+tb_name+" ")
					.append("where i_type = '"+type_rep+"' ");
		 if (!chk_prj.equals("ALL")) {
			   sql.append("and ("+queryProject+") ");
		 }
			   sql.append("and i_cause = '"+r_type+"' ")
					.append(""+d_query+"")	
				    .append("and i_type_mdl = '"+repdisplay+"' ");
		if (!mainboq.equals("00"))  {
			   sql.append("and i_itmjob_main = '"+mainboq+"' ");
		}
			   sql.append("order by 1 ");
			    servlog.startLog(sql.toString());
				rs= stmt.executeQuery(sql.toString());
				servlog.endLog();
				while (rs.next()) {

									//--------------------------- ITEM Main Only----------------------------
							   sql.delete(0,sql.length());
							   sql.append("select i_detail, i_itmjob_main, "+n_field+" "+f_name+" ")                                     
									.append("from "+tb_name+" ")
									.append("where i_type = '"+type_rep+"' ");
						 if (!chk_prj.equals("ALL")) {
							   sql.append("and ("+queryProject+") ");
						 }
							   sql.append("and i_cause = '"+r_type+"' ")								
									.append(""+d_query+"")	
									.append("and i_type_mdl = '"+repdisplay+"' ")
									.append("and i_detail = '"+doString.checkString(rs.getString("i_detail"))+"' ");
					if (!mainboq.equals("00"))  {
							   sql.append("and i_itmjob_main = '"+mainboq+"' ");
					}
							   sql.append(""+grp_by+"");
							     //out.println("qqq=="+sql.toString());
								 servlog.startLog(sql.toString());
								rs1= stmt1.executeQuery(sql.toString());
								servlog.endLog();
								while (rs1.next()) {
									total_q_mth = 0;
										 for (int j=1;j<=itm;j++) {	
											 //System.out.println("j=="+j);
												 itm_main = rs1.getInt(""+get_field+"");	 // i_itmjob_sub
												 
												 if (itm_main == j) {
														//ite_det[j] = new String(doString.checkString(rs1.getString("i_detail")));
														
														q_item[j] = new Integer(rs1.getInt(""+get_field+""));		//  i_itmjob_sub
														q_mth[j] = new Integer(rs1.getInt("q_sum1"));		
												 }
												 total_q_mth += q_mth[j].intValue();																	
										 } // end for	
								 } // end while		
								//total_all += total_itmmain;



					head_det = "";
					if (repdisplay.equals("01")) {
							head_det = doString.checkString(rs.getString("i_detail"));
					} else if (repdisplay.equals("02")) {
								if (doString.checkString(rs.getString("i_detail")).equals("1")) {
										head_det = "Pre-Cast";
								} else if (doString.checkString(rs.getString("i_detail")).equals("2")) {
										head_det = "Convent";
								} else if (doString.checkString(rs.getString("i_detail")).equals("3")) {
										head_det = "TH Pre-Cast";
								} else if (doString.checkString(rs.getString("i_detail")).equals("4")) {
										head_det = "TH-Convent";
								} else {
										head_det = "ไม่ระบุ";
								}
					} else if (repdisplay.equals("03")) {
								   //------------------------------- Item Area -----------------------------------
									ven_name = "";
									sql.delete(0,sql.length());
									sql.append("select bus_name from lan:stpvendr ")
										 .append("where vend_code = '"+doString.checkString(rs.getString("i_detail"))+"' ");
									servlog.startLog(sql.toString());
									rs1 = stmt1.executeQuery(sql.toString());
									servlog.endLog();
									if (rs1.next()) {
										head_det = doString.checkString(doString.DisplayThai(rs1.getString("bus_name")));
									}    
					} // end if check repdisplay
					

%>
		
		<tr>
		<td align="left" class="dotline"><%=head_det%></td>
<%
					for (int a=1;a<=itm;a++) {						
							 
%>			
							<td class="col_nameLow" width="3%"><A HREF="javascript:goDetail('<%=i_itm[a-1]%>','<%=doString.checkString(rs.getString("i_detail"))%>');"><%=q_mth[a]%></a></td>
<%
					} // end for
%>
          <td align="right" class="dotline"><%=total_q_mth%></td>
        </tr>    
<%
				for (int j=1;j<itm;j++) {		
					q_mth[j] = new Integer(0);											
				} // end for		
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


<br style="font-size:5pt">


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
	for (int a=0;a<itm;a++) {		
		 if (line==0) {
 %>				<tr><td class="item ; dotline01" height="22" width="10%">รหัสรายการซ่อม :</td>
 <%	 } else if (line%3==0 && line!=0) {
%>				<tr><td class="item ; dotline01" height="22" width="10%">&nbsp;</td><%
		 }
%>
					<td width="4%" class="item ; dotline01" align="right"><%=i_itm[a]%> :</td>
					<td width="26%" class="dotline01" align="left"><%=n_itm[a]%></td>
<%		if (line%3==2) {   %>
				 </tr>
<%		}
			line++;
	} // end for
	 while (line%3!=0) {
%>
					<td width="4%" class="item ; dotline01">&nbsp;</td>
					<td width="26%" class="dotline01">&nbsp;</td>
<%
				 line++;
				if (line%3==0) {     %>
					</tr>
	<%	     }
	 } // end while
 
// } // end if check mainboq
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
<input type="hidden" name="query" value="<%=queryProject%>">
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
<%
if (sel_time.equals("B")) {  // เลือกวันโอน

	 String[] projList2 = request.getParameterValues("sel_proj");
	 String queryProject2 = "";			
	 String i_proj = "", type_model = "";
	 int cnt_mlck = 0;
	 int line2 = 0;

	  if (projList2!=null) {
		  for (int i=0;i<projList2.length;i++) {		
				 i_proj = doString.checkString(projList2[i],"");  		
				 if (i_proj.trim().length()>=6) {	
						 if (queryProject2.trim().length()>0) queryProject2 += " or ";
						 queryProject2 += " (a.i_company='"+i_proj.substring(0,2)+"' and a.i_project='"+i_proj.substring(3,6)+"') ";	
				 }
		} // end for
	 } else {
		queryProject2 = " a.i_company='' and a.i_project='' ";
	  }
//out.println("queryProject2=="+queryProject2);

//			 d_end = thaiMonth[Integer.parseInt(B_EndM)]+" "+(Integer.parseInt(B_EndY)+543);  
	/*out.println("B_StartM=="+B_StartM);
	out.println("B_StartY=="+B_StartY);
		out.println("B_StartM=="+B_EndM);
	out.println("B_StartY=="+B_EndY);*/
%>
<table border="0" width="100%" cellspacing="0" cellpadding="0" height="20px">  
<%

				   sql.delete(0,sql.length());
				   sql.append("select c.i_type,count(*) as cnt ")                                             
						.append("from acsregis a ,acxlckmd b ,model_type c ")                                      
						.append("where month(a.d_close_law) between '"+B_StartM+"' and '"+B_EndM+"' ")      
					    .append("and year(a.d_close_law) between '"+B_StartY+"' and '"+B_EndY+"' ");
			 if (!chk_prj.equals("ALL")) {
					sql.append("and ("+queryProject2+") ");
			 }
				   sql.append("and a.i_company = b.i_company ")                                                   
						.append("and a.i_project = b.i_project ")                                                   
						.append("and a.i_lor = b.i_lor ")                                                           
						.append("and b.i_model = c.i_model ")                  
						.append("group by 1 ")                                                                      
						.append("order by 1 ");
				   //out.println(sql.toString());
				   servlog.startLog(sql.toString());
					rs = stmt.executeQuery(sql.toString());
					servlog.endLog();
					while (rs.next()) {
							type_model = doString.checkString(rs.getString("i_type")); 		
							cnt_mlck = rs.getInt("cnt");	
%>
		<tr>
          <td width="100%" align="left" class="item"><FONT COLOR="#0000CC"> <%=type_model%>  มีจำนวนบ้านโอนรวม   </FONT><%=cnt_mlck%><FONT COLOR="#0000CC"> แปลง</FONT></td>
		 </tr>
<% 	}  // end while %>
		<tr>
          <td width="100%" align="left" class="item">** ไม่รวม G05, G12 </td>
		 </tr>


      </table>
<% } // end if %>
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
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>     --></td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15" onclick="returnReport();" style="cursor:hand">&nbsp;
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
	conn.close();
	stmt=null;
	conn=null;
} catch (Exception e) {
	System.out.println("ERROR SERV_Report12_1.jsp : " + e.getMessage());
	System.out.println("ERROR SERV_Report12_1.jsp SQL : " + sql.toString());
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
