<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%!
	// Caching the DataSource - It is obtained in the jspInit() method
	private javax.sql.DataSource ds = null;
	private String subcontext = "java:comp/env";
	private String mth[] = {"เดือน","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
	private void getDS() throws NamingException {
		String dsName = "";
		Context ctx = new InitialContext();

		// Perform a naming service lookup to get the DataSource object.
		Context env = (Context)ctx.lookup(subcontext);
		dsName = (String)env.lookup("DATASOURCE_NAME");
		dsName = subcontext + "/" + dsName;
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
<%@ include file="confirmLogin.jsp" %>
<HTML>

<HEAD>
<TITLE>รายงานค่าใช้จ่าย</TITLE>

<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="EIS_MainStyle.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<base target="_self">

</HEAD>

<BODY leftMargin=10 topMargin=5 marginwidth="10" marginheight="5">
<%
StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
Statement stmtmain = null;
Statement stmt1 = null;
Statement stmt2 = null;
Statement stmtb = null;
ResultSet rs = null;
ResultSet rsmain = null;
ResultSet rs1 = null;
ResultSet rs2 = null;
ResultSet rsb = null;
try {
	if (ds == null)
	{
		getDS();
	}
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	stmt = conn.createStatement();
	stmtmain = conn.createStatement();
	stmt1 = conn.createStatement();
	stmt2 = conn.createStatement();
	stmtb = conn.createStatement();

	Calendar rightNow = Calendar.getInstance();
	String nowdate = Integer.toString(rightNow.get(Calendar.DATE))+"/"+Integer.toString(rightNow.get(Calendar.MONTH)+1)+"/"+Integer.toString(rightNow.get(Calendar.YEAR)+543);

	
	String acctno = "";
		if (request.getParameter("acctNoDetail") != null) {
		acctno = doString.checkString(request.getParameter("acctNoDetail"));
	}
	String acct_desc = "";
	if (request.getParameter("acctDescDetail") != null) {
		acct_desc = doString.checkString(request.getParameter("acctDescDetail"));
	}

	String month = "";
		if (request.getParameter("monthDetail") != null) {
		month = doString.checkString(request.getParameter("monthDetail"));
	}

	String year = "";  
	if (request.getParameter("yearDetail") != null) {
		year = doString.checkString(request.getParameter("yearDetail"));
	}
	
	
	String ref_no = "", doc_date = "", orig_journal = "", doc_id = "", t_doc_no = "", chq_no = "";
	String doc_desc = "", bus_name = "", company = "", project = "";
	double z_amount = 0, tot_amt = 0;
 	
%>
<FORM NAME="frmEIS" METHOD=POST >

  <table border="0" width="100%" cellspacing="0" cellpadding="0">
    <tr>
      <td width="100%" align="right">Last Update : <%=nowdate%>&nbsp;</td>
    </tr>
  </table>
  
  <br style="font-size:5pt">  
  
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            รายงานค่าใช้จ่าย
            แยกรายเดือน</td>
        </tr>
      </table>

<br style="font-size:8pt">

	<table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="300">LH-ALL -ทุกโครงการ-</td>
                <td class="item_tab3"></td>
                <td class="item_tab4">&nbsp;</td>
                <td class="item_tab5"></td>
              </tr>
            </table>
      <br style="font-size:5pt">
  <table border="0" width="100%" cellspacing="1" cellpadding="0">
    <tr>
      <td width="12%" class="item : 10pt" height="28">รหัสบัญชี :</td>
      <td width="45%" height="28" align="left"><%=acctno%> - <%=doString.DisplayThai(doString.checkString(acct_desc))%><%// if (type.equals("V1")) { out.print(" ค่าใช้จ่าย"); } else if (type.equals("V2")) {out.print(" ต้นทุนทางอ้อม");} %></td>
      <td width="8%" class="item : 10pt" height="28">เดือน / ปี :</td>
      <td align="left"><% if (month.equals("Q1")){  
						out.println("Jan - Jun");
					 } else if (month.equals("Q2")){
						 out.println("July - Dec");
					 } else if (month.equals("ALL")){
						 out.println("Jan - Dec");
					 } else {
						out.println(mth[Integer.parseInt(month)]);
					 }%> / <%=year%></td>
  
  </table>
  

<br style="font-size:5pt">  

 
  <table border="0" width="100%" cellspacing="1" cellpadding="0" class="TBLine">
  <tr>
   <td width="12%" class="col_name1"><a href="#">โครงการ</a></td>
      <td width="12%" class="col_name1"><a href="#">วันที่</a></td>
      <td class="col_name1" width="8%"><a href="#">เลขที่รายการ</a></td>
      <td width="8%" class="col_name1"><a href="#">เลขที่ใบสำคัญ</a></td>
      <td width="10%" class="col_name1"><a href="#">เลขที่เช็ค</a></td>
      <td class="col_name1"><a href="#">ผู้รับเหมา</a></td>
      <td class="col_name1"><a href="#">รายละเอียด</a></td>
      <td width="10%" class="col_name1"><a href="#">จำนวนเงิน</a></td>
    </tr>
<%
 String[] projList = request.getParameterValues("sel_proj");
  	  String queryProject = "";
  	  String queryProjectComId = "";
		
	  if (projList!=null) {
		  for (int i=0;i<projList.length;i++) {
				 String proj = doString.checkString(projList[i],"");  
				 if (proj.trim().length()>=6) {
					 if (queryProject.trim().length()>0){ queryProject += " or " ; queryProjectComId += " or " ;  } 
					 queryProject += " (i_company='"+proj.substring(0,2)+"' and i_project='"+proj.substring(3,6)+"') ";
					 queryProjectComId += " (comp_id='"+proj.substring(0,2)+"' and department='"+proj.substring(3,6)+"') ";
				 }
		}
		}
	  sql.delete(0, sql.length());
	  sql.append("select comp_id, department, doc_date, orig_journal, t_doc_no, ref_no, doc_desc, chq_no, z_amount, bus_name ")
		    .append("from lan:acxgldtl ")
			.append("where acct_no = '"+acctno+"' ")
	    	.append(" and (").append(queryProjectComId).append(") ")
	    	.append(" and orig_journal != 'GJ' ");
if (month.equals("Q1")){  
	   sql.append("and month(doc_date) between '01' and '06' ");
} else if (month.equals("Q2")){
	   sql.append("and month(doc_date) between '07' and '12' ");
} else if (month.equals("ALL")){
	   sql.append("and month(doc_date) between '01' and '12' ");
} else {
	   sql.append("and month(doc_date) = '"+month+"' ");
}	
       sql.append("and year(doc_date) = '"+(Integer.parseInt(year)-543)+"' ")
	        .append("order by  comp_id, department,doc_date, ref_no ");		 
	  //out.println(sql.toString());
	  rs = stmt.executeQuery(sql.toString());
	  while (rs.next()) {
				doc_date = doString.checkString(rs.getString("doc_date"),"-");
				if (!doc_date.equals("-")) {		
					doc_date = doc_date.substring(8,10)+"/"+doc_date.substring(5,7)+"/"+Integer.toString(Integer.parseInt(doc_date.substring(0,4))+543);
				}
				ref_no = doString.checkString(rs.getString("ref_no"));
				t_doc_no = doString.checkString(rs.getString("t_doc_no"));
				orig_journal = doString.checkString(rs.getString("orig_journal"));
				chq_no = doString.checkString(rs.getString("chq_no"));
				bus_name = doString.checkString(rs.getString("bus_name"));
				doc_desc = doString.checkString(rs.getString("doc_desc"));
				project = doString.checkString(rs.getString("department"));
				company = doString.checkString(rs.getString("comp_id"));
				

				if (orig_journal.equals("CD")) {
						doc_id = "PV";
				} else if (orig_journal.equals("CR")) {
						doc_id = "RV";
				} else if (orig_journal.equals("GJ")) {
						doc_id = "JV";
				}
				z_amount = rs.getDouble("z_amount");
				tot_amt += z_amount;

%>
    <tr class="col_left ; specH1 ; white">
    <td class="col_center ; item"><%=company%>-<%=project %></td>
      <td class="col_center ; item"><%=doc_date%></td>
      <td class="col_center"><%=ref_no%></td>
      <td class="col_center"><%=doc_id%>-<%=t_doc_no%></td>
      <td class="col_center"><%=chq_no%></td>
      <td>&nbsp;<%=doString.DisplayThai(doString.checkString(bus_name))%></td>
      <td>&nbsp;<%=doString.DisplayThai(doString.checkString(doc_desc))%></td>
      <td class="col_right"><B><%=doString.displayNumber("#,###.00", z_amount)%></B>&nbsp;</td>
    </tr>
<%
	  } // end while
%>
  
    <tr class="specH1">
     <td class="col_name1">&nbsp;</td>
      <td class="col_name1">&nbsp;</td>
      <td class="col_name1">&nbsp;</td>
      <td class="col_name1">&nbsp;</td>
      <td class="col_name1">&nbsp;</td>
      <td class="col_name1">&nbsp;</td>
      <td class="col_name1">Total</td>
      <td class="col_name1r"><FONT COLOR="red"><B><%=doString.displayNumber("#,###.00", tot_amt)%></B></FONT>&nbsp;</td>
    </tr>
  </table>
                    

<br style="font-size:5pt">



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">&nbsp;</td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4">
			 <a href="javascript:history.back()" target="_top">
			<img border="0" src="images/bu_back.gif" width="50" height="15"></a><a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" width="50" height="15"></a></td>  
          </tr>  
        </table>  

		

<br style="font-size:20pt">



<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
  <tr>
    <td width="100%" class="copyright" align="center">  ติชมแสดงความคิดเห็น : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a> &nbsp;หรือ Computer Department&nbsp; โทร
  0-2230-8491  
  <br>
  <font color="rgb(0,100,255)">&copy; Copyright 2011  <img src="images/logoLH_copyright.gif" align="absmiddle">  Land & Houses Public Company Limited All right reserved.</font>
</td>
  </tr>
</TABLE> 
</FORM>
<%
	stmt.close();
	conn.close();
	stmt = null;
	conn = null;
}
catch (Exception e) {
	System.out.println("!!!ERROR EIS_ServMultiProjExpenceMonthDetail.jsp : " + e.getMessage());
	System.out.println("!!!ERROR EIS_ServMultiProjExpenceMonthDetail.jsp SQL : " + sql.toString());
	throw new ServletException(e.getMessage());
}
finally {
	// Clean up.
	try {
		if (rs != null)
			rs.close();
		if (rsmain != null)
			rsmain.close();
		if (rs1 != null)
			rs1.close();
		if (rs2 != null)
			rs2.close();
		if (rsb != null)
			rsb.close();
		if (stmt != null)
			stmt.close();
		if (stmtmain != null)
			stmtmain.close();
		if (stmt1 != null)
			stmt1.close();
		if (stmt2 != null)
			stmt2.close();
		if (stmtb != null)
			stmtb.close();
		if (conn != null)
			conn.close();
	}
	catch( SQLException ignore ){}
}
%>
</BODY>
</HTML>