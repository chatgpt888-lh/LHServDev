
<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="java.text.*" %>
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
String jName = "SERV_RepRetSum.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   doString str = new doString();
   DecimalFormat format = new DecimalFormat("#,###,##0.00");


   //----============ Declare Variables for input data ===========----//
   String iCompany = doString.checkString(request.getParameter("i_company"),"");
   String condition = "";

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
	    Calendar start = Calendar.getInstance();
	    Calendar end = Calendar.getInstance();

		if (startDate.trim().length()>=10) {
		    start.set(Integer.parseInt(startDate.substring(0,4)),Integer.parseInt(startDate.substring(5,7))-1,Integer.parseInt(startDate.substring(8,10)));
		}
		if (endDate.trim().length()>=10) {
		    end.set(Integer.parseInt(endDate.substring(0,4)),Integer.parseInt(endDate.substring(5,7))-1,Integer.parseInt(endDate.substring(8,10)));
		}

		if (iCompany.trim().length()>0) condition += " and i_company='"+iCompany+"' ";

	//---=========================================================================----//



%>

<HTML>
<HEAD>
<TITLE>สรุปเงินค้ำประกัน</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="JavaScript">

function genExcel() {
	document.forms[0].action = "<%=request.getContextPath()%>/SERV_RepRetSumServlet";
	document.forms[0].target = "_blank";
	document.forms[0].submit();
	document.forms[0].target = "";
}

</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">

<input type="hidden" name="start_date" value="<%=startDate%>">
<input type="hidden" name="end_date" value="<%=endDate%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            รายงานรายละเอียดการวางเงินค้ำประกัน</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


      <br style="font-size:5pt">


      <table border="0" width="100%" cellspacing="0" cellpadding="3">
        <tr>
          <td width="100%" align="center" class="bigh">บมจ. แลนด์
            แอนด์ เฮ้าส์</td>
        </tr>
        <tr>
          <td width="100%" align="center">สรุปเงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม</td>
        </tr>
        <tr>
          <td width="100%" align="center">วันที่ <%=common.getDateFromCalendar(start)%> - <%=common.getDateFromCalendar(end)%></td>
        </tr>
      </table>


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                
          <td class="item_tab2" width="300">&nbsp;</td>
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
          <td class="col_name" width="7%">ลำดับ</td>
          <td class="col_name" width="33%">โครงการ</td>
          <td class="col_name" width="8%">จำนวน</td>
          <td class="col_name" width="13%">ยอดยกมา</td>
          <td class="col_name" width="13%">รับเงินค้ำประกัน</td>
          <td class="col_name" width="13%">คืนเงินค้ำประกัน</td>
          <td class="col_name" width="13%">ยอดคงเหลือ</td>
        </tr>
		<%
		  String[] projList = request.getParameterValues("sel_proj");
	      int line=0;
		  int totalCountProj = 0;
		  double totalSumPayBack = 0.0;
		  double totalSumOldReten = 0.0;
		  double totalSumNowReten = 0.0;


	      if (projList!=null) {
			  for (int i=0;i<projList.length;i++) {
				     line++;
  			         String proj = doString.checkString(projList[i],"");  
					 %><input type="hidden" name="sel_proj" value="<%=proj%>"><%


					//---============= get Project Details ===============----//
					String nProject = "";
					sql.delete(0,sql.length()); 
					sql.append(" select * from lan:acxprojt ")
						  .append(" where i_company='").append(proj.length()>=6 ? proj.substring(0,2) : "").append("' ")
						  .append(" and i_project='").append(proj.length()>=6 ? proj.substring(3,6) : "").append("' ");
					servlog.startLog(sql.toString());
					rs = stmt.executeQuery(sql.toString());
					servlog.endLog();
					while (rs.next()) {
						 nProject = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
					}
					rs.close();


					//---============= get countProject ===============----//
					int countProj = 0;
					double sumPayback = 0.0;
					String idocList = "";
					sql.delete(0,sql.length()); 
					sql.append(" select * from lan:serv_rethd ")
						  .append(" where i_company='").append(proj.length()>=6 ? proj.substring(0,2) : "").append("' ")
						  .append(" and i_project='").append(proj.length()>=6 ? proj.substring(3,6) : "").append("' ")
						  .append(" and (i_doc_status<>'N' and i_doc_status<>'C') ")
						  .append(" and (d_pvno is null or (d_pvno>'").append(endDate).append("')) order by i_docno ");
					servlog.startLog(sql.toString());
					rs = stmt.executeQuery(sql.toString());
					servlog.endLog();
					while (rs.next()) {
						  String iDocNo = doString.checkString(rs.getString("i_docno"),"");
						  double zPayback = rs.getDouble("z_payback");
						  //sumPayback += zPayback;

							//---============= Get Payin List ===============----//
							sql.delete(0,sql.length()); 
							sql.append(" select a.*,b.i_receipt,b.z_recv_reten as z_recv,b.d_payin from lan:serv_rethd a,lan:serv_payin b where ")
								  .append(" b.i_company=a.i_company and b.i_project=a.i_project and b.i_docno=a.i_docno ")
								  .append(" and (b.i_receipt is not null and b.i_receipt <>'999999') and b.i_cashier_conf is not null ")
								  .append(" and a.i_docno='").append(iDocNo).append("' ");
							servlog.startLog(sql.toString());
							rs1 = stmt1.executeQuery(sql.toString());
							servlog.endLog();
							while (rs1.next()) {
									Calendar payin = Calendar.getInstance(Locale.ENGLISH);
									Timestamp tmp = rs1.getTimestamp("d_payin");
									if (tmp!=null)  {
										payin.setTime(tmp);      

										try {
											int startD = Integer.parseInt(str.replace(startDate,"-",""));
											int endD = Integer.parseInt(str.replace(endDate,"-",""));
											int payD = Integer.parseInt(str.createID(payin.get(Calendar.YEAR),4)+str.createID(payin.get(Calendar.MONTH)+1,2)+str.createID(payin.get(Calendar.DATE),2));

											if (startD<=payD && payD<=endD) {
												countProj++;
												sumPayback += zPayback;
												if (idocList.length()>0) idocList+= ",";
												idocList += " '"+iDocNo+"' ";
											}

										} catch (Exception e) {
										   //sumPayback += 0;
										}

									} else {
									   //sumPayback += 0;
									} // end if check temp;

							} // end while check payin
							rs1.close(); 

					} // end while iDocNo
					rs.close();




/*------------------------------------------------------------------
					//---============= get countProject ===============----//
					int countProj = 0;
					double sumPayback = 0.0;
					sql.delete(0,sql.length()); 
					sql.append(" select count(*) cnt ,sum(z_payback) sum_payback from lan:serv_rethd ")
						  .append(" where i_company='").append(proj.length()>=6 ? proj.substring(0,2) : "").append("' ")
						  .append(" and i_project='").append(proj.length()>=6 ? proj.substring(3,6) : "").append("' ")
 				          .append(" and (i_doc_status<>'N' and i_doc_status<>'C') ")
						  .append(" and (d_pvno is null or (d_pvno>='").append(startDate).append("')) ");
					rs = stmt.executeQuery(sql.toString());
					while (rs.next()) {
						 countProj = rs.getInt("cnt");
						 sumPayback = rs.getDouble("sum_payback");
					}
					rs.close();
--------------------------------------------------------------------------------*/


					//---============= Sum Old z_reten ===============----//
					double sumOldReten = 0.0;
					sql.delete(0,sql.length()); 
					sql.append(" select sum(b.z_recv_reten) sum_reten from lan:serv_rethd a,lan:serv_payin b where ")
						  .append(" b.i_company=a.i_company and b.i_project=a.i_project and b.i_docno=a.i_docno ")
						  .append(" and (b.i_receipt is not null and b.i_receipt <>'999999') and b.i_cashier_conf is not null ")
						  .append(" and a.i_company='").append(proj.length()>=6 ? proj.substring(0,2) : "").append("' ")
						  .append(" and a.i_project='").append(proj.length()>=6 ? proj.substring(3,6) : "").append("' ")
						  .append(" and b.d_payin<'").append(startDate).append("' ")
						  .append(" and (d_pvno is null or (a.d_pvno>'").append(endDate).append("')) ");
					//if (idocList.length()>0) sql.append(" and a.i_docno in ("+idocList+") ");
					servlog.startLog(sql.toString());
					rs = stmt.executeQuery(sql.toString());
					servlog.endLog();
					while (rs.next()) {
						 sumOldReten = rs.getDouble("sum_reten");
					}
					rs.close();



					//---============= Sum Now z_reten ===============----//
					double sumNowReten = 0.0;
					sql.delete(0,sql.length()); 
					sql.append(" select sum(b.z_recv_reten) sum_reten from lan:serv_rethd a,lan:serv_payin b where ")
						  .append(" b.i_company=a.i_company and b.i_project=a.i_project and b.i_docno=a.i_docno ")
						  .append(" and (b.i_receipt is not null and b.i_receipt <>'999999') and b.i_cashier_conf is not null ")
						  .append(" and a.i_company='").append(proj.length()>=6 ? proj.substring(0,2) : "").append("' ")
						  .append(" and a.i_project='").append(proj.length()>=6 ? proj.substring(3,6) : "").append("' ")
						  .append(" and b.d_payin>='").append(startDate).append("' ")
						  .append(" and b.d_payin<='").append(endDate).append("' ")
						  .append(" and (d_pvno is null or (a.d_pvno>'").append(endDate).append("')) ");
					//if (idocList.length()>0) sql.append(" and a.i_docno in ("+idocList+") ");
					servlog.startLog(sql.toString());
					rs = stmt.executeQuery(sql.toString());
					servlog.endLog();
					while (rs.next()) {
						 sumNowReten = rs.getDouble("sum_reten");
					}
					rs.close();



					totalCountProj += countProj;
					totalSumPayBack += sumPayback;
					totalSumOldReten += sumOldReten;
					totalSumNowReten += sumNowReten;


					 %>
						<tr>
						  <td class="dotline" align="center" width="7%"><%=line%></td>
						  <td class="dotline" width="33%"><%=str.replace(proj,":","-")%>&nbsp; |&nbsp;<%=nProject%></td>
						  <td class="dotline" align="right" width="8%"><%=countProj%></td>
						  <td class="dotline" align="right" width="13%"><%=format.format(sumOldReten)%></td>
						  <td class="dotline" align="right" width="13%"><%=format.format(sumNowReten)%></td>
						  <td class="dotline" align="right" width="13%"><%=format.format(sumPayback)%></td>
						  <td class="dotline" align="right" width="13%"><%=format.format((sumOldReten+sumNowReten)-sumPayback)%></td>
						</tr>					 
					 <%
			  }
		  }

		  if (line<10) {
			  for (int i=0;i<10;i++) {
				    %>
					<tr>
					  <td class="dotline" align="center" width="7%">&nbsp;</td>
					  <td class="dotline" width="33%">&nbsp;</td>
					  <td class="dotline" align="right" width="8%">&nbsp;</td>
					  <td class="dotline" align="right" width="13%">&nbsp;</td>
					  <td class="dotline" align="right" width="13%">&nbsp;</td>
					  <td class="dotline" align="right" width="13%">&nbsp;</td>
					  <td class="dotline" align="right" width="13%">&nbsp;</td>
					</tr>					
					<%
			  }
		  }
	  
	    %>

        <tr>
          <td class="dotline ; item" align="center" width="40%" colspan="2">รวม</td>
          <td class="dotline ; item" align="right" width="8%"><%=totalCountProj%></td>
          <td class="dotline ; item" align="right" width="13%"><%=format.format(totalSumOldReten)%></td>
          <td class="dotline ; item" align="right" width="13%"><%=format.format(totalSumNowReten)%></td>
          <td class="dotline ; item" align="right" width="13%"><%=format.format(totalSumPayBack)%></td>
          <td class="dotline ; item" align="right" width="13%"><%=format.format((totalSumOldReten+totalSumNowReten)-totalSumPayBack)%></td>
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



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">

            <img border="0" src="images/act_viewexcel.gif" onclick="genExcel();"
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">

            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:history.back()"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=Constants.APP_PATH%>/SERV_RetenHome.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
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
	} catch (Exception e) {
		System.out.println("ERROR SERV_ScrDet.jsp : " + e.getMessage());
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