<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%//@page contentType="text/html;charset=TIS620"%>
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
String jName = "SERV_Report6Det.jsp";
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

//----------------------
int no = 0;
double z_sumcut_con = 0, z_sumcut_oth = 0, tot_r8 = 0, tot_oth = 0;
String lock = doString.checkString(request.getParameter("lock"),"");
String model = doString.checkString(request.getParameter("model"),"");
String sel_project = doString.checkString(request.getParameter("sel_project"),"-");
String sel_month = doString.checkString(request.getParameter("sel_month"),"");
String sel_year = doString.checkString(request.getParameter("sel_year"),"");
String ven_name = "", n_area = "", f_remark = "", c_itmjob = "";
String i_company = "", i_project = "", n_project = "";
String payment = "", d_payment = "";

if (sel_month.equals("12")) {
	sel_month = "01";
}


sel_month = Integer.toString(Integer.parseInt(sel_month)); //+1
if (Integer.parseInt(sel_month) <=9) {
		sel_month = "0"+sel_month;
}	
String d_pay = sel_year+sel_month+"01";     //  yyyymmdd
if (!sel_project.equals("-")) {
		i_company = sel_project.substring(0,2);
		i_project = sel_project.substring(3,6);
}		
				n_project = "";	
				sql.delete(0,sql.length());
				sql.append("select n_project from lan:acxprojt ")
					 .append("where i_company = '"+i_company+"' ")
					 .append("and i_project = '"+i_project+"' ");
				servlog.startLog(sql.toString());
				rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
				if (rs.next()) {
						n_project = doString.checkString(doString.DisplayThai(rs.getString("n_project")));
				}		

				sql.delete(0,sql.length());
				sql.append("select z_sumcut_con, z_sumcut_oth from lan:serv_sumcut ")
					 .append("where i_company = '"+i_company+"' ")
					 .append("and i_project = '"+i_project+"' ")
					 .append("and i_lock = '"+lock+"' ");
				servlog.startLog(sql.toString());
				rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
				if (rs.next()==true) {
						z_sumcut_con = rs.getDouble("z_sumcut_con");
						z_sumcut_oth = rs.getDouble("z_sumcut_oth");						
				} 

//---------------------
/*String c_itmjob = "", d_query2 = "", itm_query = "", n_area = "", f_remark = "", n_group = "", ven_name = "";
String type_date = "", type_display = "", whr = "";
String r_type = doString.checkString(request.getParameter("r_type"),""); 
String sel_time = doString.checkString(request.getParameter("sel_time"),"");  
String type_amt = doString.checkString(request.getParameter("type_amt"),"A");
String d_query = doString.checkString(request.getParameter("d_query"),""); 
String query = doString.checkString(request.getParameter("query"),"");  


//String item = doString.checkString(request.getParameter("item"),"");
String h_type = doString.checkString(request.getParameter("h_type"),"");
String repdisplay = doString.checkString(request.getParameter("repdisplay"),"");
String n_repdisplay = doString.checkString(request.getParameter("n_repdisplay"),"");
String d_start = doString.checkString(request.getParameter("d_start"),"");
String d_end = doString.checkString(request.getParameter("d_end"),"");
String type_rep = doString.checkString(request.getParameter("type_rep"),"");  */
/*
if (sel_time.equals("A")) {   // สรุปตามวันแจ้งซ่อม
		 type_date = "แจ้งซ่อม";		 
} else if (sel_time.equals("B")) {    //  สรุปตามวันที่โอน
		 type_date = "โอน";		
}
	
		
	/*	
		//------------------------- Group Name Item ---------------------	
		n_group = "";
		if(i_itmjob.length() >=2) { 
				sql.delete(0,sql.length());
				sql.append("select n_itmjob from lan:serv_boq ")
					 .append("where i_itmjob[1,2] = '"+i_itmjob.substring(0,2)+"' ");
				rs = stmt.executeQuery(sql.toString());
				if (rs.next()) {
						n_group = doString.checkString(rs.getString("n_itmjob"));
				}		
		}
		//------------------------Field Where -------------------
			whr = "";
			if (repdisplay.equals("01")) {
				 whr = "and i_model = '"+h_type+"' ";
			} else if (repdisplay.equals("02")) {
				whr = "and i_mdl_type = '"+h_type+"' ";
			} else if (repdisplay.equals("03")) {
				whr = "and i_venno = '"+h_type+"' ";
			}
			*/
%>
<HTML>
<HEAD>
<TITLE>สรุปค่าซ่อมสะสมทั้งโครงการ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
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
    <td class="item ; dotline01" height="22" width="7%">โครงการ : </td>
    <td width="28%" class="dotline01" align="left"><%=i_company+"-"+i_project%>&nbsp;&nbsp;<%=n_project%></td>
	<td class="item ; dotline01" height="22" width="7%">แปลง : </td>
	<td width="8%" class="dotline01" align="left"><%=lock%></td>
	<td class="item ; dotline01" height="22" width="7%">แบบบ้าน : </td>
	<td width="43%" class="dotline01" align="left"><%=model%></td>
    </tr>
</table>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
  <td width="100%" class="dotline01" align="left">** ยอดสะสมก่อนเดือน พฤศจิกายน 2550 (ตามสัญญา R8 เป็นจำนวน <FONT COLOR="rgb(255,100,0)"><%=doString.displayNumber("#,##0.00",z_sumcut_con)%></FONT> บาท, อื่นๆ เป็นจำนวน <FONT COLOR="rgb(255,100,0)"><%=doString.displayNumber("#,##0.00",z_sumcut_oth)%></FONT> บาท)</td>
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
          <td width="34%" class="col_name" height="22">หมายเหตุรายการซ่อม</td>
          <td width="18%" class="col_name" height="22">ผู้รับเหมา</td>
		  <td width="8%" class="col_name" height="22">วันที่จ่าย</td>
          <td width="8%" class="col_name" height="22">ค่าของ+ค่าแรง <br>(รวมค่าดำเนินการ) </td>
          <td width="5%" class="col_name">เข้า<br>
            R8 </td>
          <td width="8%" class="col_name">บริเวณ</td>
          <td width="7%" class="col_name">สาเหตุ</td>
        </tr>

<%
		   sql.delete(0,sql.length());
		   sql.append("select a.i_docno, a.i_lock, a.i_venno, b.c_itmjob, ")
				.append("b.z_amount_pv, b.f_contr, b.f_remark, b.i_itmjob_area, b.d_payment ")
				.append("from lan:serv_dochd a, lan:serv_payment b ")
				.append("where a.i_company = '"+i_company+"' ")
				.append("and a.i_project = '"+i_project+"' ")
				.append("and a.i_lock = '"+lock+"' ")
				.append("and a.f_status != 'CAN' ")
				.append("and a.i_docno = b.i_docno ")
				.append("and b.f_itmstatus = 'CLS' ")
			    .append("and b.d_payment < '"+d_pay+"' ")
				.append("order by 1,2,3 ");
		   //out.println("det=="+sql.toString());
		   servlog.startLog(sql.toString());
		   rs = stmt.executeQuery(sql.toString());
		   servlog.endLog();
		   while (rs.next()) {
			   no++;
	
							 //--------------------------------- Comment Itmjob -----------------------------
							 c_itmjob = "";
							 if (doString.checkString(doString.DisplayThai(rs.getString("c_itmjob")))!=null && !doString.checkString(doString.DisplayThai(rs.getString("c_itmjob"))).equals("")) {
									 if (doString.checkString(doString.DisplayThai(rs.getString("c_itmjob"))).length() >= 75) {
											c_itmjob = doString.checkString(doString.DisplayThai(rs.getString("c_itmjob"))).substring(0,75);																										
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

								payment = "";
								d_payment = doString.checkString(doString.DisplayThai(rs.getString("d_payment")),"-");
								 if(!d_payment.equals("-")) {
									 payment = d_payment.substring(8,10)+"/"+d_payment.substring(5,7)+"/"+(Integer.parseInt(d_payment.substring(0,4))+543);
								 }
%>

        <tr>
          <td width="2%" class="dotline ; item"><%=no%></td>
          <td width="10%" class="dotline ; item" height="25" align="center"><%=doString.checkString(rs.getString("i_docno"))%></td>
		  <td width="34%" class="dotline" align="left" height="25"><%=c_itmjob%></td>
		  <td width="18%" class="dotline" align="left" height="25"><%=ven_name%></td>
          <td width="8%" class="dotline" align="center" height="25"><%=payment%></td>
          <td width="8%" class="dotline" align="right" height="25"><%=doString.displayNumber("#,##0.00",rs.getDouble("z_amount_pv"))%></td>
          <td width="5%" class="dotline" align="center"><%=doString.checkString(rs.getString("f_contr"),"-")%></td>
          <td width="8%" class="dotline" align="left"><%=n_area%></td>
          <td width="7%" class="dotline" align="left"><%=f_remark%></td>
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
<br style="font-size:1pt">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop">&nbsp;</td>
    <td width="5" valign="top" align="right"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>
<%
			tot_r8 = 0;
			tot_oth = 0;
		   sql.delete(0,sql.length());
		   sql.append("select sum(b.z_amount_pv) as amt ")	
				.append("from lan:serv_dochd a, lan:serv_payment b ")
				.append("where a.i_company = '"+i_company+"' ")
				.append("and a.i_project = '"+i_project+"' ")
				.append("and a.i_lock = '"+lock+"' ")
			    .append("and b.d_payment < '"+d_pay+"' ")
				.append("and a.f_status != 'CAN' ")
				.append("and a.i_docno = b.i_docno ")
				.append("and b.f_itmstatus = 'CLS' ")
			    .append("and b.f_contr = 'Y' ");
				servlog.startLog(sql.toString());
				rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
				if (rs.next()) {
					tot_r8 = rs.getDouble("amt");
				}

		   sql.delete(0,sql.length());
		   sql.append("select sum(b.z_amount_pv) as amt ")	
				.append("from lan:serv_dochd a, lan:serv_payment b ")
				.append("where a.i_company = '"+i_company+"' ")
				.append("and a.i_project = '"+i_project+"' ")
				.append("and a.i_lock = '"+lock+"' ")
			    .append("and b.d_payment < '"+d_pay+"' ")
				.append("and a.f_status != 'CAN' ")
				.append("and a.i_docno = b.i_docno ")
				.append("and b.f_itmstatus = 'CLS' ")
			    .append("and b.f_contr = 'N' ");
				servlog.startLog(sql.toString());
				rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
				if (rs.next()) {
					tot_oth = rs.getDouble("amt");
				}
%>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR" align="center">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="66%" height="22" align="right" class="item ; dotline01">รวมตัด R8 เป็นจำนวนเงิน
      :</td>
    <td width="11%" align="right" class="dotline01"><%=doString.displayNumber("#,##0.00",tot_r8)%></td>
    <td height="22" width="23%" class="dotline01 ; item">บาท</td>
    </tr>
  <tr>
    <td width="66%" height="22" align="right" class="item ; dotline01">Land รับผิดชอบ + ตัดเงินผู้รับเหมาเป็นจำนวนเงิน 
      :</td>
    <td width="11%" align="right" class="dotline01"><%=doString.displayNumber("#,##0.00",tot_oth)%></td>
    <td height="22" width="23%" class="dotline01 ; item">บาท</td>
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
	System.out.println("ERROR SERV_Report6Det.jsp : " + e.getMessage());
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
