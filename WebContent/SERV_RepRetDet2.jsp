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


<%!

	public String dateDisplay(String date) {
		String result = "";
		
		if (date.length()>=10) {
			int y = Integer.parseInt(date.substring(0,4));
			if (y<2400) y += 543;
			result = date.substring(8,10)+"/"+date.substring(5,7)+"/"+y;
		} else {
			result = "&nbsp;";
		}
		
		return result;
	}
	
	/*
	* //  cancel this function 
	*
	public double getPreviousAmt(Statement stmt,String iCompany,String iProject,String startDate) throws Exception {
		double sumAmt = 0.0;
		StringBuffer sql = new StringBuffer();
		ResultSet rs = null;
		
		//--- find minimum d_close_law from this project ---//
		String minDCloseLaw = "";
		sql.delete(0,sql.length()); 
		sql.append(" select min(d_close_law) as min_close from lan:acscontr ")
		   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
		   .append(" and d_close_law is not null ");
		rs = stmt.executeQuery(sql.toString());
		while (rs.next()) {
			minDCloseLaw = doString.checkString(rs.getString("min_close"),"");
		}
		rs.close();				
		
		//--- default to old date if can't get d_close_law ---//
		if (minDCloseLaw.length()<10) minDCloseLaw = "1990-01-01"; 
		
		
		//--- find details and loop sum amount ---//
		String fRecv = "";
		String fPv = "";
		String iPvNo = "";
		String iReceipt = "";
		double zDamage = 0.0;
		double zPayback = 0.0;
		double zRecv = 0.0;
		double totalSumRecv = 0.0;
		double totalsumDamage = 0.0;
		double totalSumPayBack = 0.0;
		
		sql.delete(0,sql.length()); 
		sql.append(" select (p.d_payin<'"+minDCloseLaw+"' or p.d_payin>'"+startDate+"') as f_recv, ")
		   .append(" (d.d_pvno is null or (d.d_pvno<'"+minDCloseLaw+"' or d.d_pvno>'"+startDate+"')) as f_pv, ")
		   .append(" p.d_payin as d_recv , p.z_payin as z_recv , p.i_receipt , d.* ")
		   .append(" from lan:serv_rethd d,lan:serv_payin p ")
		   .append(" where d.i_company='"+iCompany+"' and d.i_project='"+iProject+"' ")
		   .append(" and p.i_company=d.i_company and p.i_project=d.i_project and p.i_docno=d.i_docno ")
		   .append(" and ( ")
		   .append("   (d.d_pvno is not null and d.d_pvno between '"+minDCloseLaw+"' and '"+startDate+"') ")
		   .append("   or (p.d_payin is not null and p.d_payin between '"+minDCloseLaw+"' and '"+startDate+"') ")
		   .append("   or (d.d_pvno is null and p.i_receipt is not null and p.i_receipt <>'9999999' and p.i_cashier_conf is not null) ")
		   .append(" ) ")
		   .append(" and (d.i_doc_status<>'N' and d.i_doc_status<>'C' and d.i_doc_status<>'D') ")
		   .append(" order by d.i_docno ");	
		rs = stmt.executeQuery(sql.toString());	   
		while (rs.next()) {
			  fRecv = doString.checkString(rs.getString("f_recv"),"").toUpperCase().trim();
			  fPv = doString.checkString(rs.getString("f_pv"),"").toUpperCase().trim();						
			  if (fRecv.equals("T") && fPv.equals("T")) {
			  	 continue;
			  }	
			  
			  iPvNo = doString.checkString(rs.getString("i_pvno"),"");
			  zDamage = rs.getDouble("z_damage");
			  zPayback = rs.getDouble("z_payback");
			  zRecv = rs.getDouble("z_recv");
			  iReceipt = doString.checkString(rs.getString("i_receipt"),"");
			  
			  //--- not use record with psudo receipt ---//
			  if (iReceipt.indexOf("999999")>=0) {
			  	  continue;
			  }
						  			  
			  //--- check d_payin is out of range or not ---//
			  if (fRecv.equals("T")) {
			  	  zRecv = 0.0;	
			  }

			  //--- check d_pvno is out of range or not ---//
			  if (fPv.equals("T")) {
			  	  zDamage = 0.0;
			  	  zPayback = 0.0;	
			  	  iPvNo = "";
			  }		
			  
			  //--- if i_pvno is blank or not ---//
			  if (iPvNo.trim().length()<=0) {
			  	  zPayback = 0.0; 
			  }			
			  
			  totalSumRecv += zRecv;
			  totalsumDamage += zDamage;
			  totalSumPayBack += zPayback;			  			  
		} // end while
		rs.close();
		
		//---- find difference ----//
		sumAmt = totalSumRecv - (totalsumDamage+totalSumPayBack);		
				
		return sumAmt;
	}
	*
	*/

%>


<%
	String sessionId = user.getsessionId();
	String userId = user.getUserID();
	String jName = "SERV_RepRetDet2.jsp";
	ServLog servlog = new ServLog(sessionId, userId, jName);
    doString str = new doString();
 
 
    //----============ Declare Variables for input data ===========----//
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;

	try {

        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();
		stmt1 = conn.createStatement();
        //----=======================================----//


	 	//----========================= get request data ==========================----//
		String iCompany = doString.checkString(request.getParameter("i_company"),"");
		String startDay = doString.checkString(request.getParameter("start_date"),"");
		String startMonth = doString.checkString(request.getParameter("start_month"),"");
		String startYear = doString.checkString(request.getParameter("start_year"),"");
		String endDay = doString.checkString(request.getParameter("end_date"),"");
		String endMonth = doString.checkString(request.getParameter("end_month"),"");
		String endYear = doString.checkString(request.getParameter("end_year"),"");
        String startDate = startYear+"-"+startMonth+"-"+startDay;
        String endDate = endYear+"-"+endMonth+"-"+endDay;
        
		String reportType = doString.checkString(request.getParameter("report_type"),"REMAIN");
	    //---======================================================================----//



%>

<HTML>
<HEAD>
<TITLE>รายงานเงินค้ำประกัน</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="JavaScript">

function genExcel() {
	document.forms[0].action = "<%=request.getContextPath()%>/SERV_RepRetDet2Servlet";
	document.forms[0].target = "_blank";
	document.forms[0].submit();
	document.forms[0].target = "";
}

function backPage() {
	document.forms[0].action = "<%=request.getContextPath()%>/SERV_ScrRetDet2.jsp";
	document.forms[0].submit();
}

</script>


<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">

<input type="hidden" name="i_company" value="<%=iCompany %>">
<input type="hidden" name="start_date" value="<%=startDay %>">
<input type="hidden" name="start_month" value="<%=startMonth %>">
<input type="hidden" name="start_year" value="<%=startYear %>">
<input type="hidden" name="end_date" value="<%=endDay %>">
<input type="hidden" name="end_month" value="<%=endMonth %>">
<input type="hidden" name="end_year" value="<%=endYear %>">

<input type="hidden" name="report_type" value="<%=reportType %>">


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
          <td width="100%" align="center">วันที่ <%=dateDisplay(startDate)%> - <%=dateDisplay(endDate)%></td>
        </tr>
      </table>


		<%
	      int line = 0;
	      int cntProj = 0;
		  double totalSumRecv = 0.0;
		  double totalsumDamage = 0.0;
		  double totalSumPayBack = 0.0;
		
		  iCompany = "";
		  String iDocNo = "";
          String iProject = "";
          String iReten = "";
		  String iPvNo = "";
		  String iSort = "";
		  String iHouse = "";
		  String iSignBoard = "";			
		  String retCustType = "";
		  String retCustName = "";
		  double zDamage = 0.0;
		  double zPayback = 0.0;	

	 	  String dPvNo = "";
		  String dPayIn = "";
		  String iReceipt = "";
		  double zRecv = 0.0;
		  double zPreviousAmt = 0.0;
		  boolean printHeader = false;			
		  String fRecv = "";
		  String fPv = "";	
		  String[] projList = request.getParameterValues("sel_proj");

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


					//---============= get Doc Details ===============----//
				    line = 0;
					//totalSumOldReten  = 0.0;
					//totalSumRecvReten = 0.0;
					totalSumRecv = 0;
					totalsumDamage = 0.0;
					totalSumPayBack = 0.0;
					
					iCompany = "";
					iDocNo = "";
			        iProject = "";
			        iReten = "";
					iPvNo = "";
					iSort = "";
					iHouse = "";
					iSignBoard = "";			
					retCustType = "";
					retCustName = "";
					zDamage = 0.0;
					zPayback = 0.0;
			
					dPvNo = "";
					dPayIn = "";
					iReceipt = "";
					zRecv = 0.0;
					zPreviousAmt = 0.0;
					printHeader = false;
					fRecv = "";
					fPv = "";
					
								
					sql.delete(0,sql.length()); 
					sql.append(" select (p.d_payin<'"+startDate+"' or p.d_payin>'"+endDate+"') as f_recv, ")
					   .append(" (d.d_pvno is null or (d.d_pvno<'"+startDate+"' or d.d_pvno>'"+endDate+"')) as f_pv, ")
					   .append(" p.d_payin as d_recv , p.z_payin as z_recv , p.i_receipt , d.* ")
					   .append(" from lan:serv_rethd d,lan:serv_payin p ")
					   .append(" where d.i_company='"+(proj.length()>=6 ? proj.substring(0,2) : "")+"' ")
					   .append(" and d.i_project='"+(proj.length()>=6 ? proj.substring(3,6) : "")+"' ")
					   .append(" and p.i_company=d.i_company and p.i_project=d.i_project and p.i_docno=d.i_docno ")
					   .append(" and ( ")
					   .append("   (d.d_pvno is not null and d.d_pvno between '"+startDate+"' and '"+endDate+"') ")
					   .append("   or (p.d_payin is not null and p.d_payin between '"+startDate+"' and '"+endDate+"') ")
					   .append("   or (d.d_pvno is null and p.i_receipt is not null and p.i_receipt <>'9999999' and p.i_cashier_conf is not null) ")
					   .append(" ) ")
					   .append(" and (d.i_doc_status<>'N' and d.i_doc_status<>'C' and d.i_doc_status<>'D') ")
					   .append(" order by d.i_docno ");
					servlog.startLog(sql.toString());
					rs = stmt.executeQuery(sql.toString());
					servlog.endLog();
					while (rs.next()) {
						  fRecv = doString.checkString(rs.getString("f_recv"),"").toUpperCase().trim();
						  fPv = doString.checkString(rs.getString("f_pv"),"").toUpperCase().trim();						
						  if (fRecv.equals("T") && fPv.equals("T")) {
						  	 continue;
						  }				  

						  iDocNo = doString.checkString(rs.getString("i_docno"),"");
						  iCompany = doString.checkString(rs.getString("i_company"),"");
		                  iProject = doString.checkString(rs.getString("i_project"),"");
		                  iReten = doString.checkString(rs.getString("i_reten"),"");
						  iPvNo = doString.checkString(rs.getString("i_pvno"),"");
						  iSort = doString.checkString(rs.getString("i_sort"),"");
						  iHouse = doString.checkString(rs.getString("i_house"),"");
						  iSignBoard = doString.checkString(rs.getString("i_signboard"),"");
						  retCustType = doString.checkString(rs.getString("i_ret_custo"),"");
						  zDamage = rs.getDouble("z_damage");
						  zPayback = rs.getDouble("z_payback");
						  dPvNo = doString.checkString(rs.getString("d_pvno"),"");	
						  dPayIn = doString.checkString(rs.getString("d_recv"),"");	
						  iReceipt = doString.checkString(rs.getString("i_receipt"),"");
						  zRecv = rs.getDouble("z_recv");
						  
						  
						  //--- not use record with psudo receipt ---//
						  if (iReceipt.equals("9999999")) {
						  	  continue;
						  }
						  
						  //--- 2023-01-30 , move filter to bottom ---//
						  //if (reportType.equalsIgnoreCase("REMAIN") && iPvNo.trim().length()>0) {
						  //	  continue;
						  //}						  
						  
						  //--- check d_payin is out of range or not ---//
						  if (fRecv.equals("T")) {
						  	  zRecv = 0.0;	
						  }
		
						  //--- check d_pvno is out of range or not ---//
						  if (fPv.equals("T")) {
						  	  zDamage = 0.0;
						  	  zPayback = 0.0;	
						  	  dPvNo = "";
						  	  iPvNo = "";
						  }		
						  
						  //--- 2023-01-30 , filter data for report_type='REMAIN' ---//
						  if (reportType.equalsIgnoreCase("REMAIN") && iPvNo.trim().length()>0) {
						  	  continue;
						  }							  
						  
						  //--- if i_pvno is blank or not ---//
						  if (iPvNo.trim().length()<=0) {
						  	  zPayback = 0.0; 
						  }						  
		
						  //-----========== Get retCustName ============-----//
						  retCustName = "";
						  sql.delete(0,sql.length());
				          if (retCustType.equals("1")) {
				   	         sql.append(" select trim(n_prename)||trim(n_ncustomer)||' '||trim(n_scustomer) as cust_name ")
					            .append(" from lan:acxcusto where i_customer='").append(iReten).append("' ");
				          } else if (retCustType.equals("2")) {
					         sql.append(" select trim(nvl(n_pname,''))||trim(nvl(n_name,''))||' '||trim(nvl(n_sname,'')) as cust_name ")
					            .append(" from lan:serv_venprj where i_vendor='").append(iReten).append("' ")
					            .append(" and i_company='").append(iCompany).append("' and i_project='").append(iProject).append("' ")
					            .append(" and i_type='05' ");
				          } else {
				   	         sql.append(" select trim(nvl(n_pname,''))||trim(nvl(n_name,''))||' '||trim(nvl(n_sname,'')) as cust_name ")
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

						  totalSumRecv += zRecv;
						  totalsumDamage += zDamage;
						  totalSumPayBack += zPayback;
						  
						  
						  //================== print header ===================//
						  if (!printHeader) {
						  	  printHeader = true;
					  	  
						     //------ find previous amount ------//
						     //zPreviousAmt = getPreviousAmt(stmt1,iCompany,iProject,startDate);

						     zPreviousAmt = 0.0;		
						     if (reportType.equalsIgnoreCase("ALL")) {
							     for (int c=1;c<=2;c++) {						     
							     	 if (c==1) {
								     	 sql.delete(0,sql.length());
							     	 	 sql.append(" select sum(p.z_payin) as sum_amt ")
							     	 	    .append(" from lan:serv_rethd d,lan:serv_payin p ")
										    .append(" where d.i_company='"+(proj.length()>=6 ? proj.substring(0,2) : "")+"' ")
										    .append(" and d.i_project='"+(proj.length()>=6 ? proj.substring(3,6) : "")+"' ")						     	 	    
							     	 	    .append(" and p.i_company=d.i_company and p.i_project=d.i_project and p.i_docno=d.i_docno ")
							     	 	    .append(" and (d.i_doc_status<>'N' and d.i_doc_status<>'C' and d.i_doc_status<>'D')  ")
							     	 	    .append(" and p.d_payin is not null and p.d_payin<'"+startDate+"' ")
							     	 	    .append(" and p.i_receipt<>'9999999' ");
							     	 } else {
								     	 sql.delete(0,sql.length());
							     	 	 sql.append(" select sum(d.z_damage+d.z_payback) as sum_amt ")
							     	 	    .append(" from lan:serv_rethd d,lan:serv_payin p ")
										    .append(" where d.i_company='"+(proj.length()>=6 ? proj.substring(0,2) : "")+"' ")
										    .append(" and d.i_project='"+(proj.length()>=6 ? proj.substring(3,6) : "")+"' ")						     	 	    
							     	 	    .append(" and p.i_company=d.i_company and p.i_project=d.i_project and p.i_docno=d.i_docno  ")
							     	 	    .append(" and (d.i_doc_status<>'N' and d.i_doc_status<>'C' and d.i_doc_status<>'D')  ")
							     	 	    .append(" and p.d_payin is not null and p.d_payin<'"+startDate+"' and ( ")
							     	 	    .append("   (d.d_pvno is null and p.i_receipt is not null and p.i_cashier_conf is not null) ")
							     	 	    .append("   or (d.d_pvno is not null and d.d_pvno<'"+startDate+"') ")
							     	 	    .append(" ) ")
							     	 	    .append(" and p.i_receipt<>'9999999' ");
							     	 }
								     servlog.startLog(sql.toString());
								     rs1 = stmt1.executeQuery(sql.toString());
								     servlog.endLog();
								     if (rs1.next()) {
								  	     if (c==1) {
								  	  	     //--- first step , get payin amount ---//
								  	  	     zPreviousAmt += rs1.getDouble("sum_amt");
								  	     } else {
								  	  	     //--- second step , minus amount with reten amount ---//
								  	  	     zPreviousAmt -= rs1.getDouble("sum_amt");
								  	     }
								     }
								     rs1.close();
							     } // end for
						     } // end if report_type						  	  

					   
				  	  			%>
						           <table border="0" width="100%" cellspacing="0" cellpadding="0">
						              <tr>
						                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
						                
						          <td class="item_tab2" width="300"><%=str.replace(proj,":","-")%>&nbsp; |&nbsp;<%=nProject%></td>
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
											  <td rowspan="3" class="col_name">ลำดับ</td>
											  <td rowspan="3" class="col_name">เลขที่ใบวางเงินฯ</td>
											  <td class="col_name" colspan="2" rowspan="2">รับเงินค้ำประกันต่อเติม</td>
											  <td class="col_name" colspan="2" rowspan="2">คืนเงินค้ำประกันลูกค้า</td>
											  <td class="col_name" rowspan="3">แปลง</td>
											  <td class="col_name" rowspan="3">บ้านเลขที่</td>
											  <td class="col_name" rowspan="3">ผู้วางเงินค้ำประกัน</td>
											  <td class="col_name" rowspan="3">เลขที่ป้าย</td>
											  <td class="col_name" colspan="3">ระหว่างงวด</td>
											  <td rowspan="3" class="col_name">ยอดคงเหลือ</td>
											</tr>
											<tr>
											  <td class="col_nameLow" rowspan="2">รับเงินประกัน</td>
											  <td colspan="2" class="col_nameLow">คืนเงินประกัน</td>
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
				  	  			
				  	  			//----- print previous amount for report_tpyp = 'ALL' only -----//
				  	  			if (reportType.equalsIgnoreCase("ALL")) {
				  	  				%>
									<tr bgcolor="#FDE9E9">
									  <td class="dotline" align="center" colspan="13">&nbsp;ยอดยกมาก่อนวันที่ <%=dateDisplay(startDate) %></td>
									  <td class="dotline" align="right"><%=doString.displayNumber("#,###,##0.00",zPreviousAmt)%></td>									
									</tr>				  	  
				  	  				<%
				  	  			}
				  	  			
				  			} // end if 
					 	   //===================================================//


						  //================= print details ===================//
						  line++;						  
						  %>	
							<tr>
							  <td class="dotline" align="center">&nbsp;<%=line %></td>
							  <td class="dotline" align="center">&nbsp;<%=iDocNo %></td>
							  <td class="dotline" align="center"><%=dateDisplay(dPayIn) %></td>
							  <td class="dotline" align="center">&nbsp;<%=iReceipt %></td>
							  <td class="dotline" align="center"><%=dateDisplay(dPvNo) %></td>
							  <td class="dotline" align="center">&nbsp;<%=iPvNo %></td>
							  <td class="dotline" align="center">&nbsp;<%=iSort %></td>
							  <td class="dotline" align="center">&nbsp;<%=iHouse %></td>
							  <td class="dotline" align="left">&nbsp;<%=retCustName %></td>
							  <td class="dotline" align="center">&nbsp;<%=iSignBoard %></td>
							  <td class="dotline" align="right"><%=doString.displayNumber("#,###,##0.00",zRecv)%></td>
							  <td class="dotline" align="right"><%=doString.displayNumber("#,###,##0.00",zDamage)%></td>
							  <td class="dotline" align="right"><%=doString.displayNumber("#,###,##0.00",zPayback)%></td>
							  <td class="dotline" align="right"><%=doString.displayNumber("#,###,##0.00",zRecv-(zDamage+zPayback))%></td>
							</tr>						
						   <%
					 	   //===================================================//

					  } // end while 
					  rs.close();
	
					  
					  //================= print footer ======================//
					  if (printHeader && line>0) {
						%>
								<tr>
								  <td class="dotline ; item" align="center" colspan="10">รวมทั้งหมด</td>
								  <td class="dotline ; item" align="right"><%=doString.displayNumber("#,###,##0.00",totalSumRecv)%></td>
								  <td class="dotline ; item" align="right"><%=doString.displayNumber("#,###,##0.00",totalsumDamage)%></td>
								  <td class="dotline ; item" align="right"><%=doString.displayNumber("#,###,##0.00",totalSumPayBack)%></td>
								  <td class="dotline ; item" align="right">
								  <%=doString.displayNumber("#,###,##0.00",(totalSumRecv+zPreviousAmt)-(totalsumDamage+totalSumPayBack))%></td>
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
						
						cntProj++; // count project has data
					} // end if 
					//===========================================================//

		 	 }  // end for projList

	     } // end if projList

	%>


        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">
			<%
				if (cntProj>0) {
					%>
		            <img border="0" src="images/act_viewexcel.gif" onclick="genExcel();"
		    			onmouseout=nereidFade(this,70,50,5)    
		                  	onmouseover=nereidFade(this,100,50,5)     
		                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">					
					<%
				}
			%>
			&nbsp;
            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:backPage();"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
		System.out.println("ERROR SERV_RepRetDet2.jsp : " + e.getMessage());
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