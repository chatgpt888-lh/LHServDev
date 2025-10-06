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
<HTML>
<HEAD>
<TITLE>รายงานค่าใช้จ่าย /
ต้นทุนทางอ้อม แยกตามโครงการ</TITLE>

<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="MainStyle.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<base target="_self">
<SCRIPT language="JavaScript">
<!--

//-->
</SCRIPT>
</HEAD>

<BODY leftMargin=10 topMargin=5 marginwidth="10" marginheight="5">
<%
StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
Statement stmt1 = null;
Statement stmt2 = null;
Statement stmt3 = null;
ResultSet rs = null;
ResultSet rs1 = null;
ResultSet rs2 = null;
ResultSet rs3 = null;
try {
	if (ds == null)
	{
		getDS();
	}
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	stmt1 = conn.createStatement();
	stmt2 = conn.createStatement();
	stmt3 = conn.createStatement();

	Calendar rightNow = Calendar.getInstance();
	String nowdate = Integer.toString(rightNow.get(Calendar.DATE))+"/"+Integer.toString(rightNow.get(Calendar.MONTH)+1)+"/"+Integer.toString(rightNow.get(Calendar.YEAR)+543);

	//String i_employ = user.getEmpId();	
	//String i_session = user.getsessionId();

	String year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
	if (request.getParameter("year") != null) {
		year = doString.checkString(request.getParameter("year"));
	}
	String type = "V1";  // set default
	if (request.getParameter("type") != null) {
		type = doString.checkString(request.getParameter("type"));
	}
	String typecost = "A";  // set default
	if (request.getParameter("typecost") != null) {
		typecost = doString.checkString(request.getParameter("typecost"));
	}
	String option = "", type_id = "", sum_detail = "", sum_all = "", n_proj = "", com_id = "", proj_id = "", grp = "";
	double r1_m1 = 0, r1_m2 = 0, r1_m3 = 0, r1_m4 = 0, r1_m5 = 0, r1_m6 = 0;
	double r1_m7 = 0, r1_m8 = 0, r1_m9 = 0, r1_m10 = 0, r1_m11 = 0, r1_m12 = 0;
	double r1_m13 = 0, r1_sm1 = 0, r1_sm2 = 0;
	double r2_m1 = 0, r2_m2 = 0, r2_m3 = 0, r2_m4 = 0, r2_m5 = 0, r2_m6 = 0;
	double r2_m7 = 0, r2_m8 = 0, r2_m9 = 0, r2_m10 = 0, r2_m11 = 0, r2_m12 = 0;
	double r2_m13 = 0, r2_sm1 = 0, r2_sm2 = 0;
	double tot_m1 = 0, tot_m2 = 0, tot_m3 = 0, tot_m4 = 0, tot_m5 = 0;
	double tot_m6 = 0, tot_m7 = 0, tot_m8 = 0, tot_m9 = 0, tot_m10 = 0;
	double tot_m11 = 0, tot_m12 = 0, tot_m13 = 0, tot_sm1 = 0, tot_sm2 = 0;
	double all_m1 = 0, all_m2 = 0, all_m3 = 0, all_m4 = 0, all_m5 = 0;
	double all_m6 = 0, all_m7 = 0, all_m8 = 0, all_m9 = 0, all_m10 = 0;
	double all_m11 = 0, all_m12 = 0, all_m13 = 0, all_sm1 = 0, all_sm2 = 0;
	double tot_per = 0, z_per1 = 0, z_per2 = 0, z_net_ytd = 0, sum = 0;


%>
<FORM NAME="frmEIS" METHOD=POST ACTION="EIS_Indirect03.jsp">
  <table border="0" width="100%" cellspacing="0" cellpadding="0">
    <tr>
      <td width="100%" align="right">Last Update : <%=nowdate%></td>
    </tr>
  </table>
  
  <br style="font-size:5pt">  
  
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            รายงานค่าใช้จ่าย / ต้นทุนทางอ้อม
            แยกตามโครงการ</td>
        </tr>
      </table>

<br style="font-size:8pt">

	<table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">เลือกประเภทข้อมูล </td>
                <td class="item_tab3"></td>
                <td class="item_tab4">&nbsp;</td>
                <td class="item_tab5"></td>
              </tr>
            </table>
      <br style="font-size:5pt">
  <table border="0" width="100%" cellspacing="1" cellpadding="0">
    <tr>
      <td width="20%" class="item : 10pt" height="28">ประเภทข้อมูล :<font color = "rgb(0,100,255)"><% if (type.equals("V1")) { out.print(" ค่าใช้จ่าย"); } else if (type.equals("V2")) {out.print(" ต้นทุนทางอ้อม");} else if (type.equals("V3")) {out.print(" ค่าใช้จ่าย+ต้นทุนทางอ้อม"); }%></font></td>
      <td width="80%" height="28"><select size="1" name="typecost" class="box" style="width:180px">
              <option value="A" <% if (typecost.equals("A")) { out.print("Selected"); } %>>โครงการ</option>
              <option value="B" <% if (typecost.equals("B")) { out.print("Selected"); } %>>ปันส่วนจากกลุ่ม</option>
              <option value="C" <% if (typecost.equals("C")) { out.print("Selected"); } %>>ส่วนกลาง</option>
              <option value="D" <% if (typecost.equals("D")) { out.print("Selected"); } %>>โครงการ+ปันส่วนจากกลุ่ม</option>
              <option value="E" <% if (typecost.equals("E")) { out.print("Selected"); } %>>ทั้งหมด</option>
            </select></td>
    </tr>
    <tr>
      <td width="15%" class="item : 10pt" height="28" bgcolor="#F6F6F6">ประจำปี :</td>
      <td width="85%" height="28" bgcolor="#F6F6F6">&nbsp;<SELECT size="1" name="year" class="box" style="width:80px">
<%
		int Byear = Integer.parseInt(year) - 2;
		int Eyear = Integer.parseInt(year) + 2;

		for( int i = Byear;  i <= Eyear;  i++ ){
			option = "";
			if (i == Integer.parseInt(year)) {
				option = "Selected";
			}
%> 
                  <OPTION value="<%=i%>" <%=option%>><%=i%></OPTION>
<%
		} // End for year
%></SELECT>&nbsp;&nbsp;&nbsp;&nbsp;<input type="radio" value="V1" name="type" <% if (type.equals("V1")) { out.print("checked"); }%>>&nbsp;ค่าใช้จ่าย&nbsp;&nbsp;
<input type="radio" value="V2" name="type" <% if (type.equals("V2")) { out.print("checked"); }%>>&nbsp;ต้นทุนทางอ้อม&nbsp;&nbsp;
<input type="radio" value="V3" name="type" <% if (type.equals("V3")) { out.print("checked"); }%>>&nbsp;ค่าใช้จ่าย+ต้นทุนทางอ้อม&nbsp;&nbsp;&nbsp;&nbsp;<A HREF="javascript:frmEIS.submit();"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></A></td>
</tr>
  </table>
  

      <br style="font-size:5pt">  

 
  <table border="0" width="100%" cellspacing="1" cellpadding="0" class="TBLine">
  <tr>
      <td width="20%" class="col_name1" rowspan="2"><a href="#">โครงการ</a></td>
      <td class="col_name1" colspan="15">ปี <%=Integer.parseInt(year)%>&nbsp;&nbsp;หน่วย : พันบาท</td>
      <td class="col_name1" rowspan="2" width="4%"><a href="#">% *</a></td>
    </tr>   
    <tr class="specH1">
      <td width="5%" class="col_name1"><a href="#">Jan</a></td>
      <td width="5%" class="col_name1"><a href="#">Feb</a></td>
      <td width="5%" class="col_name1"><a href="#">Mar</a></td>
      <td width="5%" class="col_name1"><a href="#">Apr</a></td>
      <td width="5%" class="col_name1"><a href="#">May</a></td>
      <td width="5%" class="col_name1"><a href="#">Jun</a></td>
      <td width="5%" class="col_name1"><a href="#">Jul</a></td>
      <td width="5%" class="col_name1"><a href="#">Aug</a></td>
      <td width="5%" class="col_name1"><a href="#">Sep</a></td>
      <td width="5%" class="col_name1"><a href="#">Oct</a></td>
      <td width="5%" class="col_name1"><a href="#">Nov</a></td>
      <td width="5%" class="col_name1"><a href="#">Dec</a></td>
      <td width="5%" class="col_name1"><a href="#">Jan-Jun</a></td>
      <td width="5%" class="col_name1"><a href="#">Jul-Dec</a></td>
      <td width="6%" class="col_name1"><a href="#">Jan-Dec</a></td>
    </tr>
	  <tr class="col_right ; specH1 ; white">
      <td width="20%" class="col_left ; item"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="15" height="15">&nbsp;โครงการเปิด</td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="6%"></td>
      <td width="4%"></td>
    </tr>
<%
		//out.println("typecost=="+typecost);
		//out.println("type=="+type);
		//out.println("year=="+year);
			sum_detail = "";
			sum_all = "";
			grp = "";
			if (typecost.equals("A")) {
				type_id = "= '1'";
				grp = "";
				sum_detail = "z_bugst_m1 m1, z_bugst_m2 m2, z_bugst_m3 m3, z_bugst_m4 m4, z_bugst_m5 m5, ";
				sum_detail += "z_bugst_m6 m6, z_bugst_m7 m7, z_bugst_m8 m8, z_bugst_m9 m9, z_bugst_m10 m10, ";
				sum_detail += "z_bugst_m11 m11, z_bugst_m12 m12, z_bugst_m13 m13, ";
				sum_detail += "(z_bugst_m1+z_bugst_m2+z_bugst_m3+z_bugst_m4+z_bugst_m5+z_bugst_m6) sm1, (z_bugst_m7+z_bugst_m8+z_bugst_m9+z_bugst_m10+z_bugst_m11+z_bugst_m12) sm2";

				sum_all = "sum(z_bugst_m1) m1, sum(z_bugst_m2) m2, sum(z_bugst_m3) m3, sum(z_bugst_m4) m4, sum(z_bugst_m5) m5, ";
				sum_all += "sum(z_bugst_m6) m6, sum(z_bugst_m7) m7, sum(z_bugst_m8) m8, sum(z_bugst_m9) m9, sum(z_bugst_m10) m10, ";
				sum_all += "sum(z_bugst_m11) m11, sum(z_bugst_m12) m12, sum(z_bugst_m13) m13, ";
				sum_all += "sum(z_bugst_m1+z_bugst_m2+z_bugst_m3+z_bugst_m4+z_bugst_m5+z_bugst_m6) sm1, sum(z_bugst_m7+z_bugst_m8+z_bugst_m9+z_bugst_m10+z_bugst_m11+z_bugst_m12) sm2";

		} else if (typecost.equals("B")) { 
				type_id = "= '1'";
				grp = "";
				sum_detail = "z_bugal_m1 m1, z_bugal_m2 m2, z_bugal_m3 m3, z_bugal_m4 m4, z_bugal_m5 m5, ";
				sum_detail += "z_bugal_m6 m6, z_bugal_m7 m7, z_bugal_m8 m8, z_bugal_m9 m9, z_bugal_m10 m10, ";
				sum_detail += "z_bugal_m11 m11, z_bugal_m12 m12, z_bugal_m13 m13, ";
				sum_detail += "(z_bugal_m1+z_bugal_m2+z_bugal_m3+z_bugal_m4+z_bugal_m5+z_bugal_m6) sm1, (z_bugal_m7+z_bugal_m8+z_bugal_m9+z_bugal_m10+z_bugal_m11+z_bugal_m12) sm2";

				sum_all = "sum(z_bugal_m1) m1, sum(z_bugal_m2) m2, sum(z_bugal_m3) m3, sum(z_bugal_m4) m4, sum(z_bugal_m5) m5, ";
				sum_all += "sum(z_bugal_m6) m6, sum(z_bugal_m7) m7, sum(z_bugal_m8) m8, sum(z_bugal_m9) m9, sum(z_bugal_m10) m10, ";
				sum_all += "sum(z_bugal_m11) m11, sum(z_bugal_m12) m12, sum(z_bugal_m13) m13, ";
				sum_all += "sum(z_bugal_m1+z_bugal_m2+z_bugal_m3+z_bugal_m4+z_bugal_m5+z_bugal_m6) sm1, sum(z_bugal_m7+z_bugal_m8+z_bugal_m9+z_bugal_m10+z_bugal_m11+z_bugal_m12) sm2";

		} else if (typecost.equals("C")) {
				type_id = "= '3'";
				grp = "";
				sum_detail = "z_bugal_m1 m1, z_bugal_m2 m2, z_bugal_m3 m3, z_bugal_m4 m4, z_bugal_m5 m5, ";
				sum_detail += "z_bugal_m6 m6, z_bugal_m7 m7, z_bugal_m8 m8, z_bugal_m9 m9, z_bugal_m10 m10, ";
				sum_detail += "z_bugal_m11 m11, z_bugal_m12 m12, z_bugal_m13 m13, ";
				sum_detail += "(z_bugal_m1+z_bugal_m2+z_bugal_m3+z_bugal_m4+z_bugal_m5+z_bugal_m6) sm1, (z_bugal_m7+z_bugal_m8+z_bugal_m9+z_bugal_m10+z_bugal_m11+z_bugal_m12) sm2";

				sum_all = "sum(z_bugal_m1) m1, sum(z_bugal_m2) m2, sum(z_bugal_m3) m3, sum(z_bugal_m4) m4, sum(z_bugal_m5) m5, ";
				sum_all += "sum(z_bugal_m6) m6, sum(z_bugal_m7) m7, sum(z_bugal_m8) m8, sum(z_bugal_m9) m9, sum(z_bugal_m10) m10, ";
				sum_all += "sum(z_bugal_m11) m11, sum(z_bugal_m12) m12, sum(z_bugal_m13) m13, ";
				sum_all += "sum(z_bugal_m1+z_bugal_m2+z_bugal_m3+z_bugal_m4+z_bugal_m5+z_bugal_m6) sm1, sum(z_bugal_m7+z_bugal_m8+z_bugal_m9+z_bugal_m10+z_bugal_m11+z_bugal_m12) sm2";

		} else if (typecost.equals("D")) {
				type_id = "= '1'";
				grp = "";
				sum_detail = "(z_bugst_m1+z_bugal_m1) m1, (z_bugst_m2+z_bugal_m2) m2, (z_bugst_m3+z_bugal_m3) m3, (z_bugst_m4+z_bugal_m4) m4, (z_bugst_m5+z_bugal_m5) m5, ";
				sum_detail += "(z_bugst_m6+z_bugal_m6) m6, (z_bugst_m7+z_bugal_m7) m7, (z_bugst_m8+z_bugal_m8) m8, (z_bugst_m9+z_bugal_m9) m9, (z_bugst_m10+z_bugal_m10) m10, ";
				sum_detail += "(z_bugst_m11+z_bugal_m11) m11, (z_bugst_m12+z_bugal_m12) m12, (z_bugst_m13+z_bugal_m13) m13, ";
				sum_detail += "(z_bugst_m1+z_bugal_m1+z_bugst_m2+z_bugal_m2+z_bugst_m3+z_bugal_m3+z_bugst_m4+z_bugal_m4+z_bugst_m5+z_bugal_m5+z_bugst_m6+z_bugal_m6) sm1, ";
				sum_detail += "(z_bugst_m7+z_bugal_m7+z_bugst_m8+z_bugal_m8+z_bugst_m9+z_bugal_m9+z_bugst_m10+z_bugal_m10+z_bugst_m11+z_bugal_m11+z_bugst_m12+z_bugal_m12) sm2";

				sum_all = "sum(z_bugst_m1+z_bugal_m1) m1, sum(z_bugst_m2+z_bugal_m2) m2, sum(z_bugst_m3+z_bugal_m3) m3, sum(z_bugst_m4+z_bugal_m4) m4, sum(z_bugst_m5+z_bugal_m5) m5, ";
				sum_all += "sum(z_bugst_m6+z_bugal_m6) m6, sum(z_bugst_m7+z_bugal_m7) m7, sum(z_bugst_m8+z_bugal_m8) m8, sum(z_bugst_m9+z_bugal_m9) m9, sum(z_bugst_m10+z_bugal_m10) m10, ";
				sum_all += "sum(z_bugst_m11+z_bugal_m11) m11, sum(z_bugst_m12+z_bugal_m12) m12, sum(z_bugst_m13+z_bugal_m13) m13, ";
				sum_all += "sum(z_bugst_m1+z_bugal_m1+z_bugst_m2+z_bugal_m2+z_bugst_m3+z_bugal_m3+z_bugst_m4+z_bugal_m4+z_bugst_m5+z_bugal_m5+z_bugst_m6+z_bugal_m6) sm1, ";
				sum_all += "sum(z_bugst_m7+z_bugal_m7+z_bugst_m8+z_bugal_m8+z_bugst_m9+z_bugal_m9+z_bugst_m10+z_bugal_m10+z_bugst_m11+z_bugal_m11+z_bugst_m12+z_bugal_m12) sm2";

		} else if (typecost.equals("E")) {
				type_id = "in ('1','3')";				
				grp = "group by i_company, i_project";
				sum_detail = "sum(z_bugst_m1+z_bugal_m1) m1, sum(z_bugst_m2+z_bugal_m2) m2, sum(z_bugst_m3+z_bugal_m3) m3, sum(z_bugst_m4+z_bugal_m4) m4, sum(z_bugst_m5+z_bugal_m5) m5, ";
				sum_detail += "sum(z_bugst_m6+z_bugal_m6) m6, sum(z_bugst_m7+z_bugal_m7) m7, sum(z_bugst_m8+z_bugal_m8) m8, sum(z_bugst_m9+z_bugal_m9) m9, sum(z_bugst_m10+z_bugal_m10) m10, ";
				sum_detail += "sum(z_bugst_m11+z_bugal_m11) m11, sum(z_bugst_m12+z_bugal_m12) m12, sum(z_bugst_m13+z_bugal_m13) m13, ";
				sum_detail += "sum(z_bugst_m1+z_bugal_m1+z_bugst_m2+z_bugal_m2+z_bugst_m3+z_bugal_m3+z_bugst_m4+z_bugal_m4+z_bugst_m5+z_bugal_m5+z_bugst_m6+z_bugal_m6) sm1, ";
				sum_detail += "sum(z_bugst_m7+z_bugal_m7+z_bugst_m8+z_bugal_m8+z_bugst_m9+z_bugal_m9+z_bugst_m10+z_bugal_m10+z_bugst_m11+z_bugal_m11+z_bugst_m12+z_bugal_m12) sm2";

				sum_all = "sum(z_bugst_m1+z_bugal_m1) m1, sum(z_bugst_m2+z_bugal_m2) m2, sum(z_bugst_m3+z_bugal_m3) m3, sum(z_bugst_m4+z_bugal_m4) m4, sum(z_bugst_m5+z_bugal_m5) m5, ";
				sum_all += "sum(z_bugst_m6+z_bugal_m6) m6, sum(z_bugst_m7+z_bugal_m7) m7, sum(z_bugst_m8+z_bugal_m8) m8, sum(z_bugst_m9+z_bugal_m9) m9, sum(z_bugst_m10+z_bugal_m10) m10, ";
				sum_all += "sum(z_bugst_m11+z_bugal_m11) m11, sum(z_bugst_m12+z_bugal_m12) m12, sum(z_bugst_m13+z_bugal_m13) m13, ";
				sum_all += "sum(z_bugst_m1+z_bugal_m1+z_bugst_m2+z_bugal_m2+z_bugst_m3+z_bugal_m3+z_bugst_m4+z_bugal_m4+z_bugst_m5+z_bugal_m5+z_bugst_m6+z_bugal_m6) sm1, ";
				sum_all += "sum(z_bugst_m7+z_bugal_m7+z_bugst_m8+z_bugal_m8+z_bugst_m9+z_bugal_m9+z_bugst_m10+z_bugal_m10+z_bugst_m11+z_bugal_m11+z_bugst_m12+z_bugal_m12) sm2";
		}		
// ------------------------------------ Open Project ---------------------------------------
		sql.delete(0, sql.length());
		sql.append("select a.i_company, a.i_project from lan:vw_project a ")
			.append("where a.i_year = '"+year+"' ")
			.append("and exists (select b.i_company, b.i_project from lan:acbhlprj b ")
			.append("where b.i_year = '"+year+"' ")
			.append("and b.i_hl = 'HL1' ")
			.append("and a.i_company = b.i_company ") 
			.append("and a.i_project = b.i_project ")
			.append("and b.i_bud_type = '1') ")
			.append("order by 1,2 ");
		rs = stmt.executeQuery(sql.toString());
		while (rs.next()) {
	
					if (type.equals("V1")) {								
							  //------------------ ค่าใช้จ่าย ---------------------
							   sql.delete(0, sql.length());
							   sql.append("select "+sum_detail+", i_company, i_project from lan:acbexpbg ")					
									.append("where i_year = '"+year+"' ")
									.append("and i_type "+type_id+" ")
									.append("and i_company = '"+doString.checkString(rs.getString("i_company"))+"' ")
									.append("and i_project = '"+doString.checkString(rs.getString("i_project"))+"' ")
									.append("and i_acctno = 'TOTAL' "+grp+" ")
									.append("order by i_company, i_project ");
							   //out.println(sql.toString());
							   rs1 = stmt1.executeQuery(sql.toString());
							   if (rs1.next()) {
								   			r1_m1 = rs1.getDouble("m1")/1000;
											r1_m2 = rs1.getDouble("m2")/1000;
											r1_m3 = rs1.getDouble("m3")/1000;
											r1_m4 = rs1.getDouble("m4")/1000;
											r1_m5 = rs1.getDouble("m5")/1000;
											r1_m6 = rs1.getDouble("m6")/1000;
											r1_m7 = rs1.getDouble("m7")/1000;
											r1_m8 = rs1.getDouble("m8")/1000;
											r1_m9 = rs1.getDouble("m9")/1000;
											r1_m10 = rs1.getDouble("m10")/1000;
											r1_m11 = rs1.getDouble("m11")/1000;
											r1_m12 = rs1.getDouble("m12")/1000;
											r1_m13 = rs1.getDouble("m13")/1000;
											r1_sm1 = rs1.getDouble("sm1")/1000;
											r1_sm2 = rs1.getDouble("sm2")/1000; 


													  z_net_ytd = 0;
													  z_per1 = 0;
													  sql.delete(0, sql.length());
													  sql.append("select (z_net_ytd/1000) as z_net_ytd from lan:acmycost ")
															.append("where i_year = '"+year+"' ")
															.append("and i_company = '"+doString.checkString(rs.getString("i_company"))+"' ")                                                                
															.append("and i_project = '"+doString.checkString(rs.getString("i_project"))+"' ");      
													  rs3 = stmt3.executeQuery(sql.toString());
													  if (rs3.next()) {
															z_net_ytd = rs3.getDouble("z_net_ytd");
													  }
													  if (z_net_ytd == 0) {
															z_per1 = 0;
													  } else {
															z_per1 = (r1_m13 / z_net_ytd) * 100;
													  }

														com_id = ""; proj_id = ""; n_proj = "";
														rs3 = stmt3.executeQuery("SELECT i_company, i_project, n_project FROM lan:acxprojt WHERE i_company = '"+doString.checkString(rs1.getString("i_company"))+"' and i_project = '"+doString.checkString(rs1.getString("i_project"))+"' ");
														if (rs3.next()) {
															com_id = doString.checkString(rs3.getString("i_company")); 
															proj_id = doString.checkString(rs3.getString("i_project")); 
															n_proj = doString.checkString(rs3.getString("n_project"));
														}
%>
								  <tr class="col_right ; specH1 ; gray">
								  <td width="20%" class="col_left ; Lmar2" style="font-size:8pt"><%=com_id+"-"+proj_id%>&nbsp;<%=n_proj%></td>
								  <td width="5%"></td>
								  <td width="5%"></td>
								  <td width="5%"></td>
								  <td width="5%"></td>
								  <td width="5%"></td>
								  <td width="5%"></td>
								  <td width="5%"></td>
								  <td width="5%"></td>
								  <td width="5%"></td>
								  <td width="5%"></td>
								  <td width="5%"></td>
								  <td width="5%"></td>
								  <td width="5%"></td>
								  <td width="5%"></td>
								  <td width="6%"></td>
								  <td width="4%"></td>
								</tr>
								<tr class="col_right ; specH1 ; white">
								  <td width="20%" class="col_left ; Lmar2">- <a href="EIS_ExpenceMonth.jsp?i_com=<%=doString.checkString(rs1.getString("i_company"))%>&i_proj=<%=doString.checkString(rs1.getString("i_project"))%>&typecost=<%=typecost%>&type=V1&year=<%=year%>"> ค่าใช้จ่าย</a></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m1)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m2)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m3)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m4)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m5)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m6)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m7)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m8)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m9)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m10)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m11)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m12)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r1_sm1)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r1_sm2)%></td>
								  <td width="6%"><%=doString.displayNumber("###,###.0", r1_m13)%></td>
								  <td width="4%"><%=doString.displayNumber("###,###.0", z_per1)%></td>
								</tr>
<%							//  --------------   TOTAL  V1 -----------------										
									tot_m1 += r1_m1;
									tot_m2 += r1_m2;
									tot_m3 += r1_m3;
									tot_m4+= r1_m4;
									tot_m5 += r1_m5;
									tot_m6 += r1_m6;
									tot_m7 += r1_m7;
									tot_m8 += r1_m8;
									tot_m9 += r1_m9;
									tot_m10 += r1_m10;
									tot_m11 += r1_m11;
									tot_m12 += r1_m12;
									tot_sm1 += r1_sm1;
									tot_sm2 += r1_sm2;
									tot_m13 += r1_m13;		
					} // end if
			} // end if type = V1
			 if (type.equals("V2")) {  
							 
							 //------------------ ต้นทุนทางอ้อม ---------------------
						   sql.delete(0, sql.length());
						   sql.append("select "+sum_detail+", i_company, i_project from lan:acbidrbg ")					
								.append("where i_year = '"+year+"' ")
								.append("and i_type "+type_id+" ")
								.append("and i_company = '"+doString.checkString(rs.getString("i_company"))+"' ")
								.append("and i_project = '"+doString.checkString(rs.getString("i_project"))+"' ")
								.append("and i_acctno = 'TOTAL' "+grp+" ")
								.append("order by i_company, i_project ");
							 rs2 = stmt2.executeQuery(sql.toString());
							 if (rs2.next()) {
										r2_m1 = rs2.getDouble("m1")/1000;
										r2_m2 = rs2.getDouble("m2")/1000;
										r2_m3 = rs2.getDouble("m3")/1000;
										r2_m4 = rs2.getDouble("m4")/1000;
										r2_m5 = rs2.getDouble("m5")/1000;
										r2_m6 = rs2.getDouble("m6")/1000;
										r2_m7 = rs2.getDouble("m7")/1000;
										r2_m8 = rs2.getDouble("m8")/1000;
										r2_m9 = rs2.getDouble("m9")/1000;
										r2_m10 = rs2.getDouble("m10")/1000;
										r2_m11 = rs2.getDouble("m11")/1000;
										r2_m12 = rs2.getDouble("m12")/1000;
										r2_m13 = rs2.getDouble("m13")/1000;
										r2_sm1 = rs2.getDouble("sm1")/1000;
										r2_sm2 = rs2.getDouble("sm2")/1000;  


											  z_net_ytd = 0;
											  z_per2 = 0;
											  sql.delete(0, sql.length());
											  sql.append("select (z_net_ytd/1000) as z_net_ytd from lan:acmycost ")
													.append("where i_year = '"+year+"' ")
													.append("and i_company = '"+doString.checkString(rs.getString("i_company"))+"' ")                                                                
													.append("and i_project = '"+doString.checkString(rs.getString("i_project"))+"' ");      
											  rs3 = stmt3.executeQuery(sql.toString());
											  if (rs3.next()) {
													z_net_ytd = rs3.getDouble("z_net_ytd");
											  }
											   if (z_net_ytd == 0) {
													z_per2 = 0;
											  } else {
													z_per2 = (r2_m13 / z_net_ytd) * 100;
											  }


												com_id = ""; proj_id = ""; n_proj = "";
												rs3 = stmt3.executeQuery("SELECT i_company, i_project, n_project FROM lan:acxprojt WHERE i_company = '"+doString.checkString(rs2.getString("i_company"))+"' and i_project = '"+doString.checkString(rs2.getString("i_project"))+"' ");
												if (rs3.next()) {
													com_id = doString.checkString(rs3.getString("i_company")); 
													proj_id = doString.checkString(rs3.getString("i_project")); 
													n_proj = doString.checkString(rs3.getString("n_project"));
												}
%>
									<tr class="col_right ; specH1 ; gray">
									  <td width="20%" class="col_left ; Lmar2" style="font-size:8pt"><%=com_id+"-"+proj_id%>&nbsp;<%=n_proj%></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="6%"></td>
									  <td width="4%"></td>
									</tr>
									<tr class="col_right ; specH1 ; white">
									  <td width="20%" class="col_left ; Lmar2">- <a href="EIS_ExpenceMonth.jsp?i_com=<%=doString.checkString(rs2.getString("i_company"))%>&i_proj=<%=doString.checkString(rs2.getString("i_project"))%>&typecost=<%=typecost%>&type=V2&year=<%=year%>"> ต้นทุนทางอ้อม</a></td>
									  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m1)%></td>
									  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m2)%></td>
									  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m3)%></td>
									  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m4)%></td>
									  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m5)%></td>
									  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m6)%></td>
									  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m7)%></td>
									  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m8)%></td>
									  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m9)%></td>
									  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m10)%></td>
									  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m11)%></td>
									  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m12)%></td>
									  <td width="5%"><%=doString.displayNumber("###,###.0", r2_sm1)%></td>
									  <td width="5%"><%=doString.displayNumber("###,###.0", r2_sm2)%></td>
									  <td width="6%"><%=doString.displayNumber("###,###.0", r2_m13)%></td>
									  <td width="4%"><%=doString.displayNumber("###,###.0", z_per2)%></td>
									</tr>
<%						//  --------------   TOTAL  V2 -----------------										
									tot_m1 += r2_m1;
									tot_m2 += r2_m2;
									tot_m3 += r2_m3;
									tot_m4+= r2_m4;
									tot_m5 += r2_m5;
									tot_m6 += r2_m6;
									tot_m7 += r2_m7;
									tot_m8 += r2_m8;
									tot_m9 += r2_m9;
									tot_m10 += r2_m10;
									tot_m11 += r2_m11;
									tot_m12 += r2_m12;
									tot_sm1 += r2_sm1;
									tot_sm2 += r2_sm2;
									tot_m13 += r2_m13;		
						} // end if
				} // end if type = V1

			 if (type.equals("V3")) {  
							 
						com_id = ""; proj_id = ""; n_proj = "";
						rs3 = stmt3.executeQuery("SELECT i_company, i_project, n_project FROM lan:acxprojt WHERE i_company = '"+doString.checkString(rs.getString("i_company"))+"' and i_project = '"+doString.checkString(rs.getString("i_project"))+"' ");
						if (rs3.next()) {
							com_id = doString.checkString(rs3.getString("i_company")); 
							proj_id = doString.checkString(rs3.getString("i_project")); 
							n_proj = doString.checkString(rs3.getString("n_project"));
						}
%>
									<tr class="col_right ; specH1 ; gray">
									  <td width="20%" class="col_left ; Lmar2" style="font-size:8pt"><%=com_id+"-"+proj_id%>&nbsp;<%=n_proj%></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="5%"></td>
									  <td width="6%"></td>
									  <td width="4%"></td>
									</tr>
<%
								//------------------ ค่าใช้จ่าย ---------------------
									   sql.delete(0, sql.length());
									   sql.append("select "+sum_detail+", i_company, i_project from lan:acbexpbg ")					
											.append("where i_year = '"+year+"' ")
											.append("and i_type "+type_id+" ")
											.append("and i_company = '"+doString.checkString(rs.getString("i_company"))+"' ")
											.append("and i_project = '"+doString.checkString(rs.getString("i_project"))+"' ")
											.append("and i_acctno = 'TOTAL' "+grp+" ")
											.append("order by i_company, i_project ");
									   rs1 = stmt1.executeQuery(sql.toString());
									   if (rs1.next()) {
													r1_m1 = rs1.getDouble("m1")/1000;
													r1_m2 = rs1.getDouble("m2")/1000;
													r1_m3 = rs1.getDouble("m3")/1000;
													r1_m4 = rs1.getDouble("m4")/1000;
													r1_m5 = rs1.getDouble("m5")/1000;
													r1_m6 = rs1.getDouble("m6")/1000;
													r1_m7 = rs1.getDouble("m7")/1000;
													r1_m8 = rs1.getDouble("m8")/1000;
													r1_m9 = rs1.getDouble("m9")/1000;
													r1_m10 = rs1.getDouble("m10")/1000;
													r1_m11 = rs1.getDouble("m11")/1000;
													r1_m12 = rs1.getDouble("m12")/1000;
													r1_m13 = rs1.getDouble("m13")/1000;
													r1_sm1 = rs1.getDouble("sm1")/1000;
													r1_sm2 = rs1.getDouble("sm2")/1000; 

													  z_net_ytd = 0;
													  z_per1 = 0;
													  sql.delete(0, sql.length());
													  sql.append("select (z_net_ytd/1000) as z_net_ytd from lan:acmycost ")
															.append("where i_year = '"+year+"' ")
															.append("and i_company = '"+doString.checkString(rs.getString("i_company"))+"' ")                                                                
															.append("and i_project = '"+doString.checkString(rs.getString("i_project"))+"' ");      
													  rs3 = stmt3.executeQuery(sql.toString());
													  if (rs3.next()) {
															z_net_ytd = rs3.getDouble("z_net_ytd");
													  }
													   if (z_net_ytd == 0) {
															z_per1 = 0;
													  } else {
															z_per1 = (r1_m13 / z_net_ytd) * 100;
													  }
%>
											<tr class="col_right ; specH1 ; white">
											  <td width="20%" class="col_left ; Lmar2">- <a href="EIS_ExpenceMonth.jsp?i_com=<%=doString.checkString(rs1.getString("i_company"))%>&i_proj=<%=doString.checkString(rs1.getString("i_project"))%>&typecost=<%=typecost%>&type=V1&year=<%=year%>"> ค่าใช้จ่าย</a></td>
											  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m1)%></td>
											  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m2)%></td>
											  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m3)%></td>
											  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m4)%></td>
											  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m5)%></td>
											  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m6)%></td>
											  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m7)%></td>
											  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m8)%></td>
											  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m9)%></td>
											  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m10)%></td>
											  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m11)%></td>
											  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m12)%></td>
											  <td width="5%"><%=doString.displayNumber("###,###.0", r1_sm1)%></td>
											  <td width="5%"><%=doString.displayNumber("###,###.0", r1_sm2)%></td>
											  <td width="6%"><%=doString.displayNumber("###,###.0", r1_m13)%></td>
											  <td width="4%"><%=doString.displayNumber("###,###.0", z_per1)%></td>
											</tr>
<%						
					} // end rs 1
									//------------------ ต้นทุนทางอ้อม ---------------------
								   sql.delete(0, sql.length());
								   sql.append("select "+sum_detail+", i_company, i_project from lan:acbidrbg ")					
										.append("where i_year = '"+year+"' ")
										.append("and i_type "+type_id+" ")
										.append("and i_company = '"+doString.checkString(rs.getString("i_company"))+"' ")
										.append("and i_project = '"+doString.checkString(rs.getString("i_project"))+"' ")
										.append("and i_acctno = 'TOTAL' "+grp+" ")
										.append("order by i_company, i_project ");
									 rs2 = stmt2.executeQuery(sql.toString());
									 if (rs2.next()) {
												r2_m1 = rs2.getDouble("m1")/1000;
												r2_m2 = rs2.getDouble("m2")/1000;
												r2_m3 = rs2.getDouble("m3")/1000;
												r2_m4 = rs2.getDouble("m4")/1000;
												r2_m5 = rs2.getDouble("m5")/1000;
												r2_m6 = rs2.getDouble("m6")/1000;
												r2_m7 = rs2.getDouble("m7")/1000;
												r2_m8 = rs2.getDouble("m8")/1000;
												r2_m9 = rs2.getDouble("m9")/1000;
												r2_m10 = rs2.getDouble("m10")/1000;
												r2_m11 = rs2.getDouble("m11")/1000;
												r2_m12 = rs2.getDouble("m12")/1000;
												r2_m13 = rs2.getDouble("m13")/1000;
												r2_sm1 = rs2.getDouble("sm1")/1000;
												r2_sm2 = rs2.getDouble("sm2")/1000;

												      z_net_ytd = 0;
													  z_per2 = 0;
													  sql.delete(0, sql.length());
													  sql.append("select (z_net_ytd/1000) as z_net_ytd from lan:acmycost ")
															.append("where i_year = '"+year+"' ")
															.append("and i_company = '"+doString.checkString(rs.getString("i_company"))+"' ")                                                                
															.append("and i_project = '"+doString.checkString(rs.getString("i_project"))+"' ");      
													  rs3 = stmt3.executeQuery(sql.toString());
													  if (rs3.next()) {
															z_net_ytd = rs3.getDouble("z_net_ytd");
													  }
													   if (z_net_ytd == 0) {
															z_per2 = 0;
													  } else {
															z_per2 = (r2_m13 / z_net_ytd) * 100;
													  }
													  

%>
								<tr class="col_right ; specH1 ; white">
								  <td width="20%" class="col_left ; Lmar2">- <a href="EIS_ExpenceMonth.jsp?i_com=<%=doString.checkString(rs2.getString("i_company"))%>&i_proj=<%=doString.checkString(rs2.getString("i_project"))%>&typecost=<%=typecost%>&type=V2&year=<%=year%>"> ต้นทุนทางอ้อม</a></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m1)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m2)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m3)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m4)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m5)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m6)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m7)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m8)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m9)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m10)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m11)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r2_m12)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r2_sm1)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###.0", r2_sm2)%></td>
								  <td width="6%"><%=doString.displayNumber("###,###.0", r2_m13)%></td>
								  <td width="4%"><%=doString.displayNumber("###,###.0", z_per2)%></td>
								</tr>
<%  								
				} // end rs 2
								// ----------------------  TOTAL  V3   ---------------------										
									tot_m1 += r1_m1+r2_m1;
									tot_m2 += r1_m2+r2_m2;
									tot_m3 += r1_m3+r2_m3;
									tot_m4+= r1_m4+r2_m4;
									tot_m5 += r1_m5+r2_m5;
									tot_m6 += r1_m6+r2_m6;
									tot_m7 += r1_m7+r2_m7;
									tot_m8 += r1_m8+r2_m8;
									tot_m9 += r1_m9+r2_m9;
									tot_m10 += r1_m10+r2_m10;
									tot_m11 += r1_m11+r2_m11;
									tot_m12 += r1_m12+r2_m12;
									tot_sm1 += r1_sm1+r2_sm1;
									tot_sm2 += r1_sm2+r2_sm2;
									tot_m13 += r1_m13+r2_m13;		
									
	} // end if V3
					//  ----------------------  TOTAL  Percent   ---------------------		
							sum += z_net_ytd;
	} // end while rs
%>    
    <tr class="specH1">
      <td width="20%" class="col_name1">รวม Site เปิด</td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###.0", tot_m1)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###.0", tot_m2)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###.0", tot_m3)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###.0", tot_m4)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###.0", tot_m5)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###.0", tot_m6)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###.0", tot_m7)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###.0", tot_m8)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###.0", tot_m9)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###.0", tot_m10)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###.0", tot_m11)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###.0", tot_m12)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###.0", tot_sm1)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###.0", tot_sm2)%></td>
      <td width="6%" class="col_name1r"><%=doString.displayNumber("###,###.0", tot_m13)%></td>
      <td width="4%" class="col_name1r"><%=doString.displayNumber("###,###.0", (tot_m13 / sum) * 100)%></td>
    </tr>  



    <tr class="col_right ; specH1 ; white">
      <td width="20%" class="col_left ; item"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="15" height="15">&nbsp;<a href="EIS_Indirect02.jsp?typecost=<%=typecost%>&type=<%=type%>&year=<%=year%>">โครงการปิด</a></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="5%"></td>
      <td width="6%"></td>
      <td width="4%"></td>
    </tr>
<%
//----------------------------------------------------------------------  Closed Project  --------------------------------------------------------------------   
// Clear Variable 
r1_m1 = 0; r1_m2 = 0; r1_m3 = 0; r1_m4 = 0; r1_m5 = 0; r1_m6 = 0;r1_m7 = 0; r1_m8 = 0; r1_m9 = 0; r1_m10 = 0; r1_m11 = 0; r1_m12 = 0;r1_m13 = 0; r1_sm1 = 0; r1_sm2 = 0;
r2_m1 = 0; r2_m2 = 0; r2_m3 = 0; r2_m4 = 0; r2_m5 = 0; r2_m6 = 0;r2_m7 = 0; r2_m8 = 0; r2_m9 = 0; r2_m10 = 0; r2_m11 = 0; r2_m12 = 0;r2_m13 = 0; r2_sm1 = 0; r2_sm2 = 0;

if (type.equals("V1") || type.equals("V3")) {		   

				   sql.delete(0, sql.length());
				   sql.append("select "+sum_all+" from lan:acbexpbg a ")
						.append("where a.i_year = '"+year+"' ")
						.append("and a.i_type "+type_id+" ")
						.append("and a.i_acctno = 'TOTAL' ")
						.append("and a.i_project != '099' ")
						.append("and a.i_project [1,1] != 'G' ")
						.append("and a.i_company != 'LE' ")
						.append("and a.i_company != 'LK' ")
						.append("and not exists (select i_company, i_project from lan:acbhlprj b ")
						.append("where b.i_year = '"+year+"' ")
						.append("and b.i_hl = 'HL1' ")
						.append("and a.i_company = b.i_company ")
						.append("and a.i_project = b.i_project ")
						.append("and b.i_bud_type = '1')");
				   rs1 = stmt1.executeQuery(sql.toString());
				   if (rs1.next()) {
							r1_m1 = rs1.getDouble("m1")/1000;
							r1_m2 = rs1.getDouble("m2")/1000;
							r1_m3 = rs1.getDouble("m3")/1000;
							r1_m4 = rs1.getDouble("m4")/1000;
							r1_m5 = rs1.getDouble("m5")/1000;
							r1_m6 = rs1.getDouble("m6")/1000;
							r1_m7 = rs1.getDouble("m7")/1000;
							r1_m8 = rs1.getDouble("m8")/1000;
							r1_m9 = rs1.getDouble("m9")/1000;
							r1_m10 = rs1.getDouble("m10")/1000;
							r1_m11 = rs1.getDouble("m11")/1000;
							r1_m12 = rs1.getDouble("m12")/1000;
							r1_m13 = rs1.getDouble("m13")/1000;
							r1_sm1 = rs1.getDouble("sm1")/1000;
							r1_sm2 = rs1.getDouble("sm2")/1000;  
%>
						<tr class="col_right ; specH1 ; white">
						  <td width="20%" class="col_left ; Lmar2">-  ค่าใช้จ่าย</td>
						  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m1)%></td>
						  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m2)%></td>
						  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m3)%></td>
						  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m4)%></td>
						  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m5)%></td>
						  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m6)%></td>
						  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m7)%></td>
						  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m8)%></td>
						  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m9)%></td>
						  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m10)%></td>
						  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m11)%></td>
						  <td width="5%"><%=doString.displayNumber("###,###.0", r1_m12)%></td>
						  <td width="5%"><%=doString.displayNumber("###,###.0", r1_sm1)%></td>
						  <td width="5%"><%=doString.displayNumber("###,###.0", r1_sm2)%></td>
						  <td width="6%"><%=doString.displayNumber("###,###.0", r1_m13)%></td>
						  <td width="4%" align="center">-</td>
						</tr>
<% 
				} // end if rs 1
		} // end type

		if (type.equals("V2") || type.equals("V3")) {	

					   sql.delete(0, sql.length());
					   sql.append("select "+sum_all+" from lan:acbidrbg a ")
							.append("where a.i_year = '"+year+"' ")
							.append("and a.i_type "+type_id+" ")
							.append("and a.i_acctno = 'TOTAL' ")
							.append("and a.i_project != '099' ")
							.append("and a.i_project [1,1] != 'G' ")
							.append("and a.i_company != 'LE' ")
							.append("and a.i_company != 'LK' ")
							.append("and not exists (select i_company from lan:acbhlprj b ")
							.append("where b.i_year = '"+year+"' ")
							.append("and b.i_hl = 'HL1' ")
							.append("and a.i_company = b.i_company ")
							.append("and a.i_project = b.i_project ")
							.append("and b.i_bud_type = '1')");
					   rs2 = stmt2.executeQuery(sql.toString());
					   if (rs2.next()) {
									r2_m1 = rs2.getDouble("m1")/1000;
									r2_m2 = rs2.getDouble("m2")/1000;
									r2_m3 = rs2.getDouble("m3")/1000;
									r2_m4 = rs2.getDouble("m4")/1000;
									r2_m5 = rs2.getDouble("m5")/1000;
									r2_m6 = rs2.getDouble("m6")/1000;
									r2_m7 = rs2.getDouble("m7")/1000;
									r2_m8 = rs2.getDouble("m8")/1000;
									r2_m9 = rs2.getDouble("m9")/1000;
									r2_m10 = rs2.getDouble("m10")/1000;
									r2_m11 = rs2.getDouble("m11")/1000;
									r2_m12 = rs2.getDouble("m12")/1000;
									r2_m13 = rs2.getDouble("m13")/1000;
									r2_sm1 = rs2.getDouble("sm1")/1000;
									r2_sm2 = rs2.getDouble("sm2")/1000;  

									 
			
%>
								<tr class="col_right ; specH1 ; white">
								  <td width="20%" class="col_left ; Lmar2">-  ต้นทุนทางอ้อม</td>
								  <td width="5%"><%=doString.displayNumber("###,###,###,###.0", r2_m1)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###,###,###.0", r2_m2)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###,###,###.0", r2_m3)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###,###,###.0", r2_m4)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###,###,###.0", r2_m5)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###,###,###.0", r2_m6)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###,###,###.0", r2_m7)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###,###,###.0", r2_m8)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###,###,###.0", r2_m9)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###,###,###.0", r2_m10)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###,###,###.0", r2_m11)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###,###,###.0", r2_m12)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###,###,###.0", r2_sm1)%></td>
								  <td width="5%"><%=doString.displayNumber("###,###,###,###.0", r2_sm2)%></td>
								  <td width="6%"><%=doString.displayNumber("###,###,###,###.0", r2_m13)%></td>
								  <td width="4%" align="center">-</td>
								</tr>
<% 																
				}  // end if rs2
		} // end if chk type

									//  ------------------------   TOTAL  V3  ----------------------		
									all_m1 += r1_m1+r2_m1;
									all_m2 += r1_m2+r2_m2;
									all_m3 += r1_m3+r2_m3;
									all_m4+= r1_m4+r2_m4;
									all_m5 += r1_m5+r2_m5;
									all_m6 += r1_m6+r2_m6;
									all_m7 += r1_m7+r2_m7;
									all_m8 += r1_m8+r2_m8;
									all_m9 += r1_m9+r2_m9;
									all_m10 += r1_m10+r2_m10;
									all_m11 += r1_m11+r2_m11;
									all_m12 += r1_m12+r2_m12;
									all_sm1 += r1_sm1+r2_sm1;
									all_sm2 += r1_sm2+r2_sm2;
									all_m13 += r1_m13+r2_m13;		
	
%>
    <tr class="col_right ; specH1 ; gray">
      <td width="20%" class="col_left ; item ; Lmar2">รวม</td>
      <td width="5%"><%=doString.displayNumber("###,###,###,###.0", all_m1)%></td>
      <td width="5%"><%=doString.displayNumber("###,###,###,###.0", all_m2)%></td>
      <td width="5%"><%=doString.displayNumber("###,###,###,###.0", all_m3)%></td>
      <td width="5%"><%=doString.displayNumber("###,###,###,###.0", all_m4)%></td>
      <td width="5%"><%=doString.displayNumber("###,###,###,###.0", all_m5)%></td>
      <td width="5%"><%=doString.displayNumber("###,###,###,###.0", all_m6)%></td>
      <td width="5%"><%=doString.displayNumber("###,###,###,###.0", all_m7)%></td>
      <td width="5%"><%=doString.displayNumber("###,###,###,###.0", all_m8)%></td>
      <td width="5%"><%=doString.displayNumber("###,###,###,###.0", all_m9)%></td>
      <td width="5%"><%=doString.displayNumber("###,###,###,###.0", all_m10)%></td>
      <td width="5%"><%=doString.displayNumber("###,###,###,###.0", all_m11)%></td>
      <td width="5%"><%=doString.displayNumber("###,###,###,###.0", all_m12)%></td>
      <td width="5%"><%=doString.displayNumber("###,###,###,###.0", all_sm1)%></td>
      <td width="5%"><%=doString.displayNumber("###,###,###,###.0", all_sm2)%></td>
      <td width="6%"><%=doString.displayNumber("###,###,###,###.0", all_m13)%></td>
      <td width="4%" align="center">-</td>
    </tr>

    <tr class="specH1">
      <td width="20%" class="col_name1">รวม Site ปิด + เปิด</td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###,###,###.0", tot_m1+all_m1)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###,###,###.0", tot_m2+all_m2)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###,###,###.0", tot_m3+all_m3)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###,###,###.0", tot_m4+all_m4)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###,###,###.0", tot_m5+all_m5)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###,###,###.0", tot_m6+all_m6)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###,###,###.0", tot_m7+all_m7)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###,###,###.0", tot_m8+all_m8)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###,###,###.0", tot_m9+all_m9)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###,###,###.0", tot_m10+all_m10)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###,###,###.0", tot_m11+all_m11)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###,###,###.0", tot_m12+all_m12)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###,###,###.0", tot_sm1+all_sm1)%></td>
      <td width="5%" class="col_name1r"><%=doString.displayNumber("###,###,###,###.0", tot_sm2+all_sm2)%></td>
      <td width="6%" class="col_name1r"><%=doString.displayNumber("###,###,###,###.0", tot_m13+all_m13)%></td>
      <td width="4%" class="col_name1r"><%=doString.displayNumber("###,###.0", (tot_m13 / sum) * 100)%></td>
    </tr>
</table>      
<br style="font-size:3pt">
<table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
<tr>
	<td width="100%"><FONT COLOR="#FF0000">&nbsp;&nbsp;*&nbsp;&nbsp;&nbsp;%&nbsp;&nbsp;เทียบกับยอดขายสุทธิทั้งปี</FONT></td>
</tr>
</table>  

<br style="font-size:5pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">&nbsp;</td>                 	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:history.back()"><img border="0" src="images/bu_back.gif" width="50" height="15"></a><a href="EIS_Indirect03.jsp"><img border="0" src="images/bu_home.gif" width="50" height="15"></a></td>  
          </tr>  
        </table>  

<br style="font-size:20pt">
<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
  <tr><td width="100%" class="copyright" align="center">
  Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5  
  <br>ติชมแสดงความคิดเห็น : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a> &nbsp;หรือ Computer Department&nbsp; โทร
  0-2230-8490-98, 0-2230-8451-3  
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE> 
</FORM>
<%
	stmt.close();
	conn.close();
	stmt = null;
	conn = null;
}
catch (Exception e) {
	System.out.println("!!!ERROR EIS_Indirect03.jsp : " + e.getMessage());
	System.out.println("!!!ERROR EIS_Indirect03.jsp SQL : " + sql.toString());
	throw new ServletException(e.getMessage());
}
finally {
	// Clean up.
	try {
		if (rs != null)
			rs.close();
		if (rs1 != null)
			rs1.close();
		if (rs2 != null)
			rs2.close();
		if (stmt != null)
			stmt.close();
		if (stmt1 != null)
			stmt1.close();
		if (stmt2 != null)
			stmt2.close();
		if (conn != null)
			conn.close();
	}
	catch( SQLException ignore ){}
}
%>
</BODY>
</HTML>