
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
String jName = "SERV_RepRetDet.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   doString str = new doString();
   DecimalFormat format = new DecimalFormat("#,###,##0.00");


   //----============ Declare Variables for input data ===========----//
//   String iCompany = doString.checkString(request.getParameter("i_company"),"");
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

//		if (iCompany.trim().length()>0) condition += " and i_company='"+iCompany+"' ";

	//---=========================================================================----//



%>

<HTML>
<HEAD>
<TITLE>รายงานเงินค้ำประกัน</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="JavaScript">

function genExcel() {
	document.forms[0].action = "<%=request.getContextPath()%>/SERV_RepRetDetServlet";
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
          <td width="100%" align="center">เงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม</td>
        </tr>
        <tr>
          <td width="100%" align="center">วันที่ <%=common.getDateFromCalendar(start)%> - <%=common.getDateFromCalendar(end)%></td>
        </tr>
      </table>


		<%
		  String[] projList = request.getParameterValues("sel_proj");
	      int line=0;

	      if (projList!=null) {
			  for (int i=0;i<projList.length;i++) {
  			         String proj = doString.checkString(projList[i],"");  
					  %><input type="hidden" name="sel_proj" value="<%=proj%>"><%


					//---============= get Project Details ===============----//
					String nProject = "";
					sql.delete(0,sql.length()); 
					sql.append(" select * from lan:acxprojt  ")
						  .append(" where i_company='").append(proj.length()>=6 ? proj.substring(0,2) : "").append("' ")
						  .append(" and i_project='").append(proj.length()>=6 ? proj.substring(3,6) : "").append("' ");
					servlog.startLog(sql.toString());
					rs = stmt.executeQuery(sql.toString());
					servlog.endLog();
					while (rs.next()) {
						 nProject = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
					}
					rs.close();

	  %>

            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                
          <td class="item_tab2" width="300"><%=str.replace(proj,":","-")%>&nbsp; |&nbsp;<%=nProject%></td>
                <td class="item_tab3"></td>
                
          <td>&nbsp;</td>
              </tr>
            </table>


		<table border="0" width="1300" cellspacing="0" cellpadding="0">
		  <tr>
			<td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
			<td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
			<td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
		  </tr>
		</table>

		<table border="0" width="1300" cellspacing="0" cellpadding="0">
		  <tr>
			<td width="100%" class="frmL">
			
			  <table border="0" width="100%" cellspacing="0" cellpadding="0">
				<tr>
				  <td rowspan="3" class="col_name">ลำดับ</td>
				  <td rowspan="3" class="col_name">เลขที่ใบวางเงินฯ</td>
				  <td class="col_name" colspan="2" rowspan="2">รับเงินค้ำประกันต่อเติม</td>
				  <td class="col_name" colspan="2" rowspan="2">คืนเงินค้ำประกันลูกค้า</td>
				  <td class="col_name" rowspan="3">แปลง</td>
				  <td class="col_name" rowspan="3">บ้านเลขที่</td>
				  <td class="col_name" rowspan="3">ผู้วางเงินค้ำประกัน</td>
				  <td class="col_name" rowspan="3">เลขที่ป้าย</td>
				  <td class="col_name" rowspan="3">ยอดยกมา</td>
				  <td class="col_name" colspan="3">ระหว่างงวด</td>
				  <td rowspan="3" class="col_name">ยอดคงเหลือ</td>
				</tr>
				<tr>
				  <td class="col_nameLow" rowspan="2">รับเงินประกัน</td>
				  <td colspan="2" class="col_nameLow">วันเงินประกัน</td>
				</tr>
				<tr>
				  <td class="col_nameLow">วันที่ Pay in</td>
				  <td class="col_nameLow">เลขที่ใบเสร็จ</td>
				  <td class="col_nameLow">วันที่เช็คคืน</td>
				  <td class="col_nameLow">เลขที่ PV.SQ.</td>
				  <td class="col_nameLow">หักค่าเสียหาย</td>
				  <td class="col_nameLow">จำนวนเงินที่คืน</td>
				</tr>

		<%

			//---============= get Doc Details ===============----//
		    line = 0;
			double totalSumOldReten  = 0.0;
			double totalSumNowReten = 0.0;
			double totalsumDamage = 0.0;
			double totalSumPayBack = 0.0;
			int num = 0;

			sql.delete(0,sql.length()); 
			sql.append(" select * from lan:serv_rethd ")
				  .append(" where i_company='").append(proj.length()>=6 ? proj.substring(0,2) : "").append("' ")
				  .append(" and i_project='").append(proj.length()>=6 ? proj.substring(3,6) : "").append("' ")
				  .append(" and (i_doc_status<>'N' and i_doc_status<>'C') ")
				  .append(" and (d_pvno is null or (d_pvno>'").append(endDate).append("')) order by i_docno ");
		 		  // not used //  .append(" and (d_pvno is null or (d_pvno between '").append(startDate).append("' and '").append(endDate).append("')) order by i_docno ");
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			while (rs.next()) {
				  line++;
				  //num++;

					Vector dPayinList = new Vector();
					Vector iReceiptList = new Vector();
					Vector oldReceive = new Vector();
					Vector newReceive = new Vector();


				  String iDocNo = doString.checkString(rs.getString("i_docno"),"");
				  String iCompany = doString.checkString(rs.getString("i_company"),"");
                  String iProject = doString.checkString(rs.getString("i_project"),"");
                  String iReten = doString.checkString(rs.getString("i_reten"),"");
				  String iPvNo = doString.checkString(rs.getString("i_pvno"),"");
				  String iSort = doString.checkString(rs.getString("i_sort"),"");
				  String iHouse = doString.checkString(rs.getString("i_house"),"");
				  String iSignBoard = doString.checkString(rs.getString("i_signboard"),"");
				  String retCustType = doString.checkString(rs.getString("i_ret_custo"),"");
				  double zDamage = rs.getDouble("z_damage");
				  double zPayback = rs.getDouble("z_payback");


				  //---======= Get Cheque Confirm Date =========---//
				  String dConfChq = "";
				  Calendar chqDate = Calendar.getInstance();
				  Timestamp temp = rs.getTimestamp("d_conf_chq");
				  if (temp!=null)  {
				  	  chqDate.setTime(temp);      
					  dConfChq = getDateFromCalendar(chqDate); 
				  }


					//---===== Payto Date is between range , reset z_payback =========--//
					Timestamp pay = rs.getTimestamp("d_payto");
					if (pay!=null)  {
						Calendar payto = Calendar.getInstance(Locale.ENGLISH);
						payto.setTime(pay);
						
						int startD = Integer.parseInt(str.replace(startDate,"-",""));
						int endD = Integer.parseInt(str.replace(endDate,"-",""));
						int payD = Integer.parseInt(str.createID(payto.get(Calendar.YEAR),4)+str.createID(payto.get(Calendar.MONTH)+1,2)+str.createID(payto.get(Calendar.DATE),2));
						
						if (startD<=payD && payD<=endD) {
						   zPayback = 0.0;
						}
					}


					//-----========== Get retCustName ============-----//
				    String retCustName = "";
					sql.delete(0,sql.length());
					if (retCustType.equals("1")) {
					sql.append(" select trim(n_prename)||trim(n_ncustomer)||' '||trim(n_scustomer) as cust_name ")
						  .append(" from lan:acxcusto where i_customer='").append(iReten).append("' ");
					} else if (retCustType.equals("2")) {
					sql.append(" select trim(n_pname)||trim(n_name)||' '||trim(n_sname) as cust_name ")
						  .append(" from lan:serv_venprj where i_vendor='").append(iReten).append("' ")
						  .append(" and i_company='").append(iCompany).append("' and i_project='").append(iProject).append("' ")
						  .append(" and i_type='05' ");
					} else {
					sql.append(" select trim(n_pname)||trim(n_name)||' '||trim(n_sname) as cust_name ")
						  .append(" from lan:serv_venprj where i_vendor='").append(iReten).append("' ")
						  .append(" and i_company='").append(iCompany).append("' and i_project='").append(iProject).append("' ")
						  .append(" and i_type='06' ");
					}
					servlog.startLog(sql.toString());
					rs1 = stmt1.executeQuery(sql.toString());
					servlog.endLog();
					if (rs1.next()) {
						retCustName = doString.checkString(doString.DisplayThai(rs1.getString("cust_name")),"");
					}
					rs1.close();



					boolean used = false;

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
							String iReceipt = doString.checkString(rs1.getString("i_receipt"),"");
							double zReceipt = rs1.getDouble("z_recv");
						    String payinDate = "";
							used = true;


							Calendar payin = Calendar.getInstance(Locale.ENGLISH);
							Timestamp tmp = rs1.getTimestamp("d_payin");
							if (tmp!=null)  {
								payin.setTime(tmp);      
								payinDate = getDateFromCalendar(payin);

								try {
									int startD = Integer.parseInt(str.replace(startDate,"-",""));
									int endD = Integer.parseInt(str.replace(endDate,"-",""));
									int payD = Integer.parseInt(str.createID(payin.get(Calendar.YEAR),4)+str.createID(payin.get(Calendar.MONTH)+1,2)+str.createID(payin.get(Calendar.DATE),2));


								   if (payD<startD) {
									   //---==== Payin Date < Start Date , set to old =======---//
									   oldReceive.addElement(new Double(zReceipt));
									   newReceive.addElement(new Double(0.00));
									   used = true;
								   } else if (startD<=payD && payD<=endD) {
									   //---===== Payin Date is between range , set to new =========--//
									   oldReceive.addElement(new Double(0.00));
									   newReceive.addElement(new Double(zReceipt));
									   used = true;
								   } else {
									   //---===== Payin Date > End Date , set blank =========--//
									   used = false;
								   }

								} catch (Exception e) {
								   used = false;
								}

							} else {
							   //oldReceive.addElement(new Double(zReceipt));
							   //newReceive.addElement(new Double(0.00));
							   used = false;
							} // end if check temp;




							dPayinList.addElement(payinDate);
							iReceiptList.addElement(iReceipt);
							

					} // end while check payin
					rs1.close(); 


if (used) {
					num++;

					double showOldReceipt = (oldReceive.size()>0 ? ((Double) oldReceive.elementAt(0)).doubleValue() : 0.00);
					double showNewReceipt = (newReceive.size()>0 ? ((Double) newReceive.elementAt(0)).doubleValue() : 0.00);


					totalSumOldReten += showOldReceipt;
					totalSumNowReten += showNewReceipt;
					totalsumDamage += zDamage;
					totalSumPayBack += zPayback;

					 %>	
						<tr>
						  <td class="dotline" align="center"><%=num%></td>
						  <td class="dotline" align="center"><%=iDocNo%></td>
						  <td class="dotline" align="center"><%=(dPayinList.size()>0 ? (doString.checkString((String) dPayinList.elementAt(0),"&nbsp;")) : "&nbsp;" )%></td>
						  <td class="dotline" align="center"><%=(iReceiptList.size()>0 ? (doString.checkString((String) iReceiptList.elementAt(0),"&nbsp;")) : "&nbsp;") %></td>
						  <td class="dotline" align="center"><%=doString.checkString(dConfChq,"&nbsp;")%></td>
						  <td class="dotline" align="center"><%=doString.checkString(iPvNo,"&nbsp;")%></td>
						  <td class="dotline" align="center"><%=doString.checkString(iSort,"&nbsp;")%></td>
						  <td class="dotline" align="center"><%=doString.checkString(iHouse,"&nbsp;")%></td>
						  <td class="dotline" align="left"><%=doString.checkString(retCustName,"&nbsp;")%></td>
						  <td class="dotline" align="center"><%=doString.checkString(iSignBoard,"&nbsp;")%></td>
						  <td class="dotline" align="right"><%=format.format(showOldReceipt)%></td>
						  <td class="dotline" align="right"><%=format.format(showNewReceipt)%></td>
						  <td class="dotline" align="right"><%=format.format(zDamage)%></td>
						  <td class="dotline" align="right"><%=format.format(zPayback)%></td>
						  <td class="dotline" align="right"><%=format.format((showOldReceipt+showNewReceipt)-(zDamage+zPayback))%></td>
						</tr>						
					 <%

					if (dPayinList.size()>1) {
						for (int n=1;n<dPayinList.size();n++) {
							  line++;
							  totalSumOldReten += ((Double) oldReceive.elementAt(n)).doubleValue();
							  totalSumNowReten += ((Double) newReceive.elementAt(n)).doubleValue();

							 %>	
								<tr>
								  <td class="dotline" align="center">&nbsp;</td>
								  <td class="dotline" align="center">&nbsp;</td>
								  <td class="dotline" align="center"><%=doString.checkString(((String) dPayinList.elementAt(n)),"&nbsp;")%></td>
								  <td class="dotline" align="center"><%=doString.checkString(((String) iReceiptList.elementAt(n)),"&nbsp;")%></td>
								  <td class="dotline" align="center">&nbsp;</td>
								  <td class="dotline" align="center">&nbsp;</td>
								  <td class="dotline" align="center">&nbsp;</td>
								  <td class="dotline" align="center">&nbsp;</td>
								  <td class="dotline" align="left">&nbsp;</td>
								  <td class="dotline" align="center">&nbsp;</td>
								  <td class="dotline" align="right"><%=format.format(((Double) oldReceive.elementAt(n)).doubleValue())%></td>
								  <td class="dotline" align="right"><%=format.format(((Double) newReceive.elementAt(n)).doubleValue())%></td>
								  <td class="dotline" align="right">&nbsp;</td>
								  <td class="dotline" align="right">&nbsp;</td>
								  <td class="dotline" align="right">&nbsp;</td>
								</tr>						
							 <%
						}
					}

} else {
	  continue;
} // used

					} // end while iDocNo
					rs.close();


					  if (line<5) {
						  for (int k=0;k<5;k++) {
								%>
								<tr>
								  <td class="dotline" align="center">&nbsp;</td>
								  <td class="dotline" align="center">&nbsp;</td>
								  <td class="dotline" align="center">&nbsp;</td>
								  <td class="dotline" align="center">&nbsp;</td>
								  <td class="dotline" align="center">&nbsp;</td>
								  <td class="dotline" align="center">&nbsp;</td>
								  <td class="dotline" align="center">&nbsp;</td>
								  <td class="dotline" align="center">&nbsp;</td>
								  <td class="dotline" align="left">&nbsp;</td>
								  <td class="dotline" align="center">&nbsp;</td>
								  <td class="dotline" align="right">&nbsp;</td>
								  <td class="dotline" align="right">&nbsp;</td>
								  <td class="dotline" align="right">&nbsp;</td>
								  <td class="dotline" align="right">&nbsp;</td>
								  <td class="dotline" align="right">&nbsp;</td>
								</tr>			
								<%
						  }

					  } // end for projList



						%>
								<tr>
								  <td class="dotline ; item" align="center" colspan="10">รวมทั้งหมด</td>
								  <td class="dotline ; item" align="right"><%=format.format(totalSumOldReten)%></td>
								  <td class="dotline ; item" align="right"><%=format.format(totalSumNowReten)%></td>
								  <td class="dotline ; item" align="right"><%=format.format(totalsumDamage)%></td>
								  <td class="dotline ; item" align="right"><%=format.format(totalSumPayBack)%></td>
								  <td class="dotline ; item" align="right"><%=format.format((totalSumOldReten+totalSumNowReten)-(totalsumDamage+totalSumPayBack))%></td>
								</tr>
							  </table>
							</td>
						  </tr>
						</table>

						<table border="0" width="1300" cellspacing="0" cellpadding="0">
						  <tr>
							<td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
							<td class="frmBottom">&nbsp;</td>
							<td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
						  </tr>
						</table>



						  <br style="font-size:10pt">			
						<%


			  }  // end for projList

	     } // end if projList

	%>


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
	
</BODY>

</HTML>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_RepRetDet.jsp : " + e.getMessage());
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