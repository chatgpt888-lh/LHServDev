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
<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_ReportSubDet.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

doString str = new doString();
Calendar rightNow = Calendar.getInstance();
StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;
Statement stmt1 = null;
ResultSet rs1 = null;
SERV_CommonData common = null;

try {
	if (ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	stmt1 = conn.createStatement();
	common = new SERV_CommonData(conn);



String r_type = doString.checkString(request.getParameter("r_type"),""); 
String sel_time = doString.checkString(request.getParameter("sel_time"),"");  
String type_amt = doString.checkString(request.getParameter("type_amt"),"A");
String type_date = "", type_display = "", chk_prj = "";
//String mainboq = "", subboq = "", seqboq = "";
//String option = "", grp = "", typ = "", tb_name = "";
String c_itmjob = "", d_query2 = "", itm_query = "", n_area = "", f_remark = "", n_group = "", ven_name = "";
/*mainboq = doString.checkString(request.getParameter("mainboq"),"00");	
subboq = doString.checkString(request.getParameter("subboq"),"nnnn");	
seqboq = doString.checkString(request.getParameter("seqboq"),"nnnnnnnn");		
*/

String d_query = "";
String query = doString.checkString(request.getParameter("query"),"");  
String i_itmjob = doString.checkString(request.getParameter("i_itm"),"");
String A_StartM = doString.checkString(request.getParameter("A_StartM"),"00");
String A_StartY = doString.checkString(request.getParameter("A_StartY"),"0000");
String A_EndM = doString.checkString(request.getParameter("A_EndM"),"00");
String A_EndY = doString.checkString(request.getParameter("A_EndY"),"0000");
String B_StartM = doString.checkString(request.getParameter("B_StartM"),"00");
String B_StartY = doString.checkString(request.getParameter("B_StartY"),"0000");
String B_EndM = doString.checkString(request.getParameter("B_EndM"),"00");
String B_EndY = doString.checkString(request.getParameter("B_EndY"),"0000");
if (i_itmjob.length() == 2) {
		itm_query = "and a.i_itmjob[1,2] = '"+i_itmjob+"' ";
} else if (i_itmjob.length() == 4) {
		itm_query = "and a.i_itmjob[1,4] = '"+i_itmjob+"' ";
} else {
		itm_query = "and a.i_itmjob = '"+i_itmjob+"' ";
}

String t_tran = doString.checkString(request.getParameter("t_tr"),"");  
if (Integer.parseInt(t_tran) <=9) {  // หลังโอน 1,2,3,..13
	t_tran = "0"+t_tran;
}
String n_tran = "";
if (t_tran.equals("01")) {
		n_tran = "หลังโอน 1 เดือน";
} else if (t_tran.equals("02")) {
		n_tran = "หลังโอน 2 เดือน"; 
} else if (t_tran.equals("03")) {
		n_tran = "หลังโอน 3 เดือน"; 
} else if (t_tran.equals("04")) {
		n_tran = "หลังโอน 4 เดือน"; 
} else if (t_tran.equals("05")) {
		n_tran = "หลังโอน 5 เดือน"; 
} else if (t_tran.equals("06")) {
		n_tran = "หลังโอน 6 เดือน"; 
} else if (t_tran.equals("07")) {
		n_tran = "หลังโอน 7 เดือน";
} else if (t_tran.equals("08")) {		
		n_tran = "หลังโอน 8 เดือน";
} else if (t_tran.equals("09")) {		
		n_tran = "หลังโอน 9 เดือน"; 
} else if (t_tran.equals("10")) {
		n_tran = "หลังโอน 10 เดือน";
} else if (t_tran.equals("11")) {
		n_tran = "หลังโอน 11 เดือน"; 
} else if (t_tran.equals("12")) {
		n_tran = "หลังโอน 12 เดือน"; 
} else if (t_tran.equals("13")) {
		n_tran = "หลังโอน >12 เดือน"; 
} 



String d_start = doString.checkString(doString.DisplayThai(request.getParameter("d_start")),"");
String d_end = doString.checkString(doString.DisplayThai(request.getParameter("d_end")),"");
String type_rep = doString.checkString(request.getParameter("type_rep"),"");

if (sel_time.equals("A")) {   // สรุปตามวันแจ้งซ่อม
		 type_date = "แจ้งซ่อม";
		 //type_rep = "01";
		 //d_start = A_StartM+" "+A_StartY;
		 //d_end = A_EndM+" "+A_EndY;
		d_query = "and month(d_keyin) between '"+A_StartM+"' and '"+A_EndM+"' and year(d_keyin) between '"+(Integer.parseInt(A_StartY))+"' and '"+(Integer.parseInt(A_EndY))+"' ";
		 //d_query2 = "and c.i_month between '"+A_StartM+"' and '"+A_EndM+"' and c.i_year between '"+(Integer.parseInt(A_StartY)+543)+"' and '"+(Integer.parseInt(A_EndY)+543)+"' ";
} else if (sel_time.equals("B")) {    //  สรุปตามวันที่โอน
		 type_date = "โอน";
		 //type_rep = "02";
		 //d_start = B_StartM+" "+B_StartY;
		 //d_end = B_EndM+" "+B_EndY;
		d_query = "and month(d_close_law) between '"+B_StartM+"' and '"+B_EndM+"' and year(d_close_law) between '"+(Integer.parseInt(B_StartY))+"' and '"+(Integer.parseInt(B_EndY))+"' ";
		 //d_query2 = "and c.i_month between '"+B_StartM+"' and '"+B_EndM+"' and c.i_year between '"+(Integer.parseInt(B_StartY)+543)+"' and '"+(Integer.parseInt(B_EndY)+543)+"' ";
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
			 type_display = doString.DisplayThai(doString.checkString(rs.getString("n_desc"),""));
		 } else {
			 type_display = "ทุกสาเหตุ";
		 }

		//------------------------- Group Name Item ---------------------	
		n_group = "";
		if(i_itmjob.length() >=2) { 
				sql.delete(0,sql.length());
				sql.append("select n_itmjob from lan:serv_boq ")
					 .append("where i_itmjob[1,2] = '"+i_itmjob.substring(0,2)+"' ");
				servlog.startLog(sql.toString());
				rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
				if (rs.next()) {
						n_group = doString.DisplayThai(doString.checkString(rs.getString("n_itmjob")));
				}		
		}
%>
<HTML>
<HEAD>
<TITLE>สรุปค่าซ่อมสะสมทั้งโครงการ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<META http-equiv="Content-Language" content="th">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">



<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            รายละเอียดใบแจ้งซ่อม</td>
          <td width="50%">&nbsp;</td>
        </tr>
      </table>





<br style="font-size:10pt">




            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">ที่มาของข้อมูล</td>
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
    <td width="160%" class="dotline01"><%=d_start%>&nbsp;&nbsp; ถึง&nbsp;&nbsp;<%=d_end%></td>
    </tr>
  <tr>
    <td width="15%" height="22" class="item ; dotline01">สาเหตุ : </td>
    <td width="85%" class="dotline01"><%=type_display%></td>
  </tr>
  <!--<tr>
    <td width="15%" height="22" class="item ; dotline01">รายงานที่น้องการ : </td>
    <td class="dotline01">ตามแบบบ้าน</td>
  </tr>-->
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
						out.print("</tr>");
					  }
				  }

	  } else {
		  queryProject = " a.i_company='' and a.i_project='' ";
	  }
	%>
  <tr>
  </table>
  <table border="0" width="100%" cellspacing="0" cellpadding="0">
  	<tr>
    <td width="15%" height="22" class="item ; dotline01">หมวด : </td>
    <td class="dotline01"><%=n_group%></td>
    </tr>
  <tr>
    <td height="22" class="item ; dotline01">ระยะเวลา : </td>
    <td class="dotline01"><%=n_tran%></td>
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
                <td class="item_tab2" width="200">รายละเอียดการซ่อม</td>
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
          <td width="2%" class="col_name">&nbsp;</td>
		   <td width="10%" class="col_name" height="22">เลขที่ใบแจ้งซ่อม</td>
          <td width="23%" class="col_name" height="22">หมายเหตุรายการซ่อม</td>
          <td width="6%" class="col_name" height="22">แปลง</td>
          <td width="8%" class="col_name" height="22">แบบบ้าน</td>
          <td width="20%" class="col_name" height="22">ผู้รับเหมา</td>
          <td width="11%" class="col_name" height="22">ค่าของ+ค่าแรง (รวมค่าดำเนินการ) </td>
          <td width="5%" class="col_name">เข้า<br>
            R8 </td>
          <td width="8%" class="col_name">บริเวณ</td>
          <td width="7%" class="col_name">สาเหตุ</td>
        </tr>

<%
			chk_prj = "";
			if (!proj.equals("") && proj != null) {
				if (proj.equals("LH:ALL")) {
						chk_prj = "ALL";
				} else {
						chk_prj = "";
				}
			}		   
			int no = 0;
		   sql.delete(0,sql.length());
		   sql.append("select a.i_itmjob, a.i_docno, a.i_lock, a.i_model, a.i_venno, a.z_amount_pv, a.f_contr, a.i_itmjob_area, a.f_remark, a.c_itmjob ")
				.append("from lan:serv_trfdet a ")
			    .append("where a.i_trf_type = '"+t_tran+"' ")
			    .append(""+itm_query+"");	    
	 if (!chk_prj.equals("ALL")) {
		   sql.append("and ("+query+") ");
      }
		   sql.append("and a.i_rep_type = '"+type_rep+"' ")
			    .append(""+d_query+"");
if (!r_type.equals("99")) {
		   sql.append("and a.f_remark = '"+r_type+"' ");
}
		   sql.append("order by 2,1,3 ");
//out.println(sql.toString());
			servlog.startLog(sql.toString());
		    rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
		    while (rs.next()) {
				no++;
							 //--------------------------------- Comment Itmjob -----------------------------
							 c_itmjob = "";
							 if (doString.checkString(doString.DisplayThai(rs.getString("c_itmjob")))!=null && !doString.checkString(doString.DisplayThai(rs.getString("c_itmjob"))).equals("")) {
									 if (doString.checkString(doString.DisplayThai(rs.getString("c_itmjob"))).length() >= 100) {
											c_itmjob = doString.checkString(doString.DisplayThai(rs.getString("c_itmjob"))).substring(0,100);																										
									 } else {
											c_itmjob = doString.checkString(doString.DisplayThai(rs.getString("c_itmjob")));
									 }
								}		
								//------------------------------- Item Area -----------------------------------
								n_area = "";
								sql.delete(0,sql.length());
								sql.append("select n_desc from lan:serv_xstd ")
									 .append("where i_type = '01' ")
									 .append("and i_code = '"+doString.checkString(rs.getString("i_itmjob_area"))+"' ");
								servlog.startLog(sql.toString());
								rs1 = stmt1.executeQuery(sql.toString());
								servlog.endLog();
								if (rs1.next()) {
									n_area = doString.checkString(doString.DisplayThai(rs1.getString("n_desc")));
								}
								//------------------------------- Item Area -----------------------------------
								f_remark = "";
								sql.delete(0,sql.length());
								sql.append("select n_desc from lan:serv_xstd ")
									 .append("where i_type = '06' ")
									 .append("and i_code = '"+doString.checkString(rs.getString("f_remark"))+"' ");
								servlog.startLog(sql.toString());
								rs1 = stmt1.executeQuery(sql.toString());
								servlog.endLog();
								if (rs1.next()) {
									f_remark = doString.checkString(doString.DisplayThai(rs1.getString("n_desc")));
								}    

								//------------------------------- Item Area -----------------------------------
								ven_name = "";
								sql.delete(0,sql.length());
								sql.append("select bus_name from lan:stpvendr ")
									 .append("where vend_code = '"+doString.checkString(rs.getString("i_venno"))+"' ");
								servlog.startLog(sql.toString());
								rs1 = stmt1.executeQuery(sql.toString());
								servlog.endLog();
								if (rs1.next()) {
									ven_name = doString.checkString(doString.DisplayThai(rs1.getString("bus_name")));
								}    
%>

        <tr>
          <td width="2%" class="dotline ; item"><%=no%>.</td>
          <td width="10%" class="dotline ; item" height="25"><%=doString.checkString(rs.getString("i_docno"))%></td>
		  <td width="23%" class="dotline" align="left" height="25"><%=c_itmjob%></td>
          <td width="6%" class="dotline" align="center" height="25"><%=doString.checkString(rs.getString("i_lock"))%></td>
          <td width="8%" class="dotline" align="center" height="25"><%=doString.checkString(rs.getString("i_model"))%></td>
          <td width="20%" class="dotline" align="left" height="25"><%=ven_name%></td>
          <td width="11%" class="dotline" align="right" height="25"><%=doString.displayNumber("###,##0.00", rs.getDouble("z_amount_pv"))%></td>
          <td width="5%" class="dotline" align="center"><%=doString.checkString(rs.getString("f_contr"))%></td>
          <td width="8%" class="dotline" align="left"><%=n_area%></td>
          <td width="7%" class="dotline" align="left"><%=f_remark%>&nbsp;</td>
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



<br style="font-size:10pt">



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">&nbsp;

           <!-- <a href="#"><img border="0" src="images/act_print.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>            --></td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:history.back()" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="SERV_Home.html"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
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
	
</BODY>

</HTML>
<%
	stmt.close();
	conn.close();
	stmt=null;
	conn=null;
} catch (Exception e) {
	System.out.println("ERROR SERV_ReportSubDet.jsp : " + e.getMessage());
	throw new ServletException(e.getMessage());
} finally {
	// Clean up.
	try {
		if (rs != null) rs.close();
		if (stmt != null) stmt.close();
		if (rs1 != null) rs1.close();
		if (stmt1 != null) stmt1.close();
		if (conn != null) conn.close();
	}
	catch( SQLException ignore ){}
}
%>
