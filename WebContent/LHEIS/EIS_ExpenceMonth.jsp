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
<TITLE>รายงานค่าใช้จ่าย</TITLE>

<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="MainStyle.css" type="text/css">
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

	String typecost = "";  
	if (request.getParameter("typecost") != null) {
		typecost = doString.checkString(request.getParameter("typecost"));
	}
	String i_com = "";  
	if (request.getParameter("i_com") != null) {
		i_com = doString.checkString(request.getParameter("i_com"));
	}
	String i_proj = "";  
	if (request.getParameter("i_proj") != null) {
		i_proj = doString.checkString(request.getParameter("i_proj"));
	}
	String type = "";  
	if (request.getParameter("type") != null) {
		type = doString.checkString(request.getParameter("type"));
	}
	String year = "";
	if (request.getParameter("year") != null) {
		year = doString.checkString(request.getParameter("year"));
	}
	String option = "", n_type = "", type_id = "", sum_detail = "", tb_name = "", n_proj = "", acct_desc = "", sum_total = "";
	String type_no = "", chk_acct = "", code_no = "", f_type = "", btype_id = "";
	String Bsum_detail = "", Btb_name = "", chk_link = "";

	double v_m1 = 0, v_m2 = 0, v_m3 = 0, v_m4 = 0, v_m5 = 0, v_m6 = 0;
	double v_m7 = 0, v_m8 = 0, v_m9 = 0, v_m10 = 0, v_m11 = 0, v_m12 = 0;
	double v_m13 = 0, v_sm1 = 0, v_sm2 = 0;
	double b_m1 = 0, b_m2 = 0, b_m3 = 0, b_m4 = 0, b_m5 = 0, b_m6 = 0;
	double b_m7 = 0, b_m8 = 0, b_m9 = 0, b_m10 = 0, b_m11 = 0, b_m12 = 0;
	double b_m13 = 0, b_sm1 = 0, b_sm2 = 0, stot_vper = 0, stot_per = 0;

	/*double v2_m1 = 0, v2_m2 = 0, v2_m3 = 0, v2_m4 = 0, v2_m5 = 0, v2_m6 = 0;
	double v2_m7 = 0, v2_m8 = 0, v2_m9 = 0, v2_m10 = 0, v2_m11 = 0, v2_m12 = 0;
	double v2_m13 = 0, v2_sm1 = 0, v2_sm2 = 0;*/

	/*double b2_m1 = 0, b2_m2 = 0, b2_m3 = 0, b2_m4 = 0, b2_m5 = 0, b2_m6 = 0;
	double b2_m7 = 0, b2_m8 = 0, b2_m9 = 0, b2_m10 = 0, b2_m11 = 0, b2_m12 = 0;
	double b2_m13 = 0, b2_sm1 = 0, b2_sm2 = 0;*/

	double Atot_m1 = 0, Atot_m2 = 0, Atot_m3 = 0, Atot_m4 = 0, Atot_m5 = 0;
	double Atot_m6 = 0, Atot_m7 = 0, Atot_m8 = 0, Atot_m9 = 0, Atot_m10 = 0;
	double Atot_m11 = 0, Atot_m12 = 0, Atot_m13 = 0, Atot_sm1 = 0, Atot_sm2 = 0;
	double Atot_vm1 = 0, Atot_vm2 = 0, Atot_vm3 = 0, Atot_vm4 = 0, Atot_vm5 = 0;
	double Atot_vm6 = 0, Atot_vm7 = 0, Atot_vm8 = 0, Atot_vm9 = 0, Atot_vm10 = 0;
	double Atot_vm11 = 0, Atot_vm12 = 0, Atot_vm13 = 0, Atot_vsm1 = 0, Atot_vsm2 = 0;
	double tot_m1 = 0, tot_m2 = 0, tot_m3 = 0, tot_m4 = 0, tot_m5 = 0;
	double tot_m6 = 0, tot_m7 = 0, tot_m8 = 0, tot_m9 = 0, tot_m10 = 0;
	double tot_m11 = 0, tot_m12 = 0, tot_m13 = 0, tot_sm1 = 0, tot_sm2 = 0;
	double tot_vm1 = 0, tot_vm2 = 0, tot_vm3 = 0, tot_vm4 = 0, tot_vm5 = 0;
	double tot_vm6 = 0, tot_vm7 = 0, tot_vm8 = 0, tot_vm9 = 0, tot_vm10 = 0;
	double tot_vm11 = 0, tot_vm12 = 0, tot_vm13 = 0, tot_vsm1 = 0, tot_vsm2 = 0;
	double stot_m1 = 0, stot_m2 = 0, stot_m3 = 0, stot_m4 = 0, stot_m5 = 0;
	double stot_m6 = 0, stot_m7 = 0, stot_m8 = 0, stot_m9 = 0, stot_m10 = 0;
	double stot_m11 = 0, stot_m12 = 0, stot_m13 = 0, stot_sm1 = 0, stot_sm2 = 0;
	double stot_vm1 = 0, stot_vm2 = 0, stot_vm3 = 0, stot_vm4 = 0, stot_vm5 = 0;
	double stot_vm6 = 0, stot_vm7 = 0, stot_vm8 = 0, stot_vm9 = 0, stot_vm10 = 0;
	double stot_vm11 = 0, stot_vm12 = 0, stot_vm13 = 0, stot_vsm1 = 0, stot_vsm2 = 0;
	double all_m1 = 0, all_m2 = 0, all_m3 = 0, all_m4 = 0, all_m5 = 0, all_m6 = 0, all_m7 = 0;
	double all_m8 = 0, all_m9 = 0, all_m10 = 0, all_m11 = 0, all_m12 = 0, all_sm1 = 0, all_sm2 = 0, all_m13 = 0;  
	double all_vm1 = 0, all_vm2 = 0, all_vm3 = 0, all_vm4 = 0, all_vm5 = 0, all_vm6 = 0, all_vm7 = 0;
	double all_vm8 = 0, all_vm9 = 0, all_vm10 = 0, all_vm11 = 0, all_vm12 = 0, all_vsm1 = 0, all_vsm2 = 0, all_vm13 = 0;  
	double all_actper = 0, all_budper = 0;
	double Atot_vper = 0, Atot_per = 0, z_net_ytd = 0;
	double a_per1 = 0, b_per1 = 0, Aper_all = 0, Bper_all = 0;
	double Atpec_m1 = 0, Atpec_m2 = 0, Atpec_m3 = 0, Atpec_m4 = 0, Atpec_m5 = 0, Atpec_m6 = 0;
	double Atpec_m7 = 0, Atpec_m8 = 0, Atpec_m9 = 0, Atpec_m10 = 0, Atpec_m11 = 0, Atpec_m12 = 0;
	double Atpec_m13 = 0, Atpec_sm1 = 0, Atpec_sm2 = 0;
	double Btpec_m1 = 0, Btpec_m2 = 0, Btpec_m3 = 0, Btpec_m4 = 0, Btpec_m5 = 0, Btpec_m6 = 0;
	double Btpec_m7 = 0, Btpec_m8 = 0, Btpec_m9 = 0, Btpec_m10 = 0, Btpec_m11 = 0, Btpec_m12 = 0;
	double Btpec_m13 = 0, Btpec_sm1 = 0, Btpec_sm2 = 0;

//		, tot_per = 0, per_all = 0, tot_vper = 0;

	

	if (type.equals("V1")) {
		n_type = "ค่าใช้จ่าย";
		tb_name = "lan:acbexpsm";
		Btb_name = "lan:acbexpbg";
		f_type = "5";
		type_no = "5-ser";  // service dept		
		code_no = "110";

	} else if (type.equals("V2")) {
		n_type = "ต้นทุนทางอ้อม";
		tb_name = "lan:acbidrsm";
		Btb_name = "lan:acbidrbg";
		f_type = "idirec";
		type_no = "idr-se";   // service dept		
		code_no = "105";
	} 
%>
<FORM NAME="frmEIS" METHOD=POST ACTION="EIS_ExpenceMonth.jsp">
<INPUT TYPE="hidden" NAME="i_com" VALUE="<%=i_com%>">
<INPUT TYPE="hidden" NAME="i_proj" VALUE="<%=i_proj%>">
<%		
			n_proj = "";
			rs = stmt.executeQuery("SELECT n_project FROM lan:acxprojt WHERE i_company = '"+i_com+"' and i_project = '"+i_proj+"' ");
			if (rs.next()) {
					n_proj = doString.checkString(rs.getString("n_project"));
			}
%>
  <table border="0" width="100%" cellspacing="0" cellpadding="0">
    <tr>
      <td width="100%" align="right">Last Update : <%=nowdate%></td>
    </tr>
  </table>
  
  <br style="font-size:5pt">  
  
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            รายงาน<%=n_type%> แยกรายเดือน</td>
        </tr>
      </table>

<br style="font-size:8pt">

	<table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="300"><%=i_com%>-<%=i_proj%> <%=doString.DisplayThai(doString.checkString(n_proj))%></td>
                <td class="item_tab3"></td>
                <td class="item_tab4">&nbsp;</td>
                <td class="item_tab5"></td>
              </tr>
            </table>
      <br style="font-size:5pt">
  <table border="0" width="100%" cellspacing="1" cellpadding="0">
    <tr>
      <td width="20%" class="item : 10pt" height="28">ประเภทข้อมูล :<font color = "rgb(0,100,255)"><% if (type.equals("V1")) { out.print(" ค่าใช้จ่าย"); } else if (type.equals("V2")) {out.print(" ต้นทุนทางอ้อม");} %></font></td>
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
&nbsp;&nbsp;&nbsp;&nbsp;<A HREF="javascript:frmEIS.submit();"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></A></td>
</tr>
  </table>
  

      <br style="font-size:5pt">  

 
  <table border="0" width="1870px" cellspacing="1" cellpadding="0" class="TBLine">
  <tr>
      <td width="270px" class="col_name1" rowspan="3"><a href="#">Description ( พันบาท )</a></td>
      <td class="col_name1" colspan="32">ปี <%=year%>&nbsp;&nbsp;หน่วย : พันบาท</td>
      
    </tr>   
    <tr class="specH1">
      <td class="col_name1" colspan="2"><a href="#">Jan</a></td>
      <td class="col_name1" colspan="2"><a href="#">Feb</a></td>
      <td class="col_name1" colspan="2"><a href="#">Mar</a></td>
      <td class="col_name1" colspan="2"><a href="#">Apr</a></td>
      <td class="col_name1" colspan="2"><a href="#">May</a></td>
      <td class="col_name1" colspan="2"><a href="#">Jun</a></td>
      <td class="col_name1" colspan="2"><a href="#">Jul</a></td>
      <td class="col_name1" colspan="2"><a href="#">Aug</a></td>
      <td class="col_name1" colspan="2"><a href="#">Sep</a></td>
      <td class="col_name1" colspan="2"><a href="#">Oct</a></td>
      <td class="col_name1" colspan="2"><a href="#">Nov</a></td>
      <td class="col_name1" colspan="2"><a href="#">Dec</a></td>
      <td class="col_name1" colspan="2"><a href="#">Jan-Jun</a></td>
      <td class="col_name1" colspan="2"><a href="#">Jul-Dec</a></td>
      <td class="col_name1" colspan="2"><a href="#">Jan-Dec</a></td>
	  <td  class="col_name1" colspan="2"><a href="#">* %</a></td>
    </tr>

    <tr class="specH1">
      <td width="50px" class="col_name1">B</td>
	  <td width="50px" class="col_name1">A</td>
      <td width="50px" class="col_name1">B</td>
	  <td width="50px" class="col_name1">A</td>
      <td width="50px" class="col_name1">B</td>
	  <td width="50px" class="col_name1">A</td>
      <td width="50px" class="col_name1">B</td>
	  <td width="50px" class="col_name1">A</td>
      <td width="50px" class="col_name1">B</td>
	  <td width="50px" class="col_name1">A</td>
      <td width="50px" class="col_name1">B</td>
	  <td width="50px" class="col_name1">A</td>
      <td width="50px" class="col_name1">B</td>
	  <td width="50px" class="col_name1">A</td>
      <td width="50px" class="col_name1">B</td>
	  <td width="50px" class="col_name1">A</td>
      <td width="50px" class="col_name1">B</td>
	  <td width="50px" class="col_name1">A</td>
      <td width="50px" class="col_name1">B</td>
	  <td width="50px" class="col_name1">A</td>
      <td width="50px" class="col_name1">B</td>
	  <td width="50px" class="col_name1">A</td>
      <td width="50px" class="col_name1">B</td>
	  <td width="50px" class="col_name1">A</td>
      <td width="50px" class="col_name1">B</td>
	  <td width="50px" class="col_name1">A</td>
	  <td width="50px" class="col_name1">B</td>
	  <td width="50px" class="col_name1">A</td>
      <td width="50px" class="col_name1">B</td>
	  <td width="50px" class="col_name1">A</td>
	  <td width="50px" class="col_name1">B</td>
	  <td width="50px" class="col_name1">A</td>
    </tr>
<%
			sum_total = "";
		if (typecost.equals("A")) {
				type_id = "= '1'";
				btype_id = "= '1'";
				sum_detail = "z_expst_m1 m1, z_expst_m2 m2, z_expst_m3 m3, z_expst_m4 m4, z_expst_m5 m5, ";
				sum_detail += "z_expst_m6 m6, z_expst_m7 m7, z_expst_m8 m8, z_expst_m9 m9, z_expst_m10 m10, ";
				sum_detail += "z_expst_m11 m11, z_expst_m12 m12, z_expst_m13 m13, ";
				sum_detail += "(z_expst_m1+z_expst_m2+z_expst_m3+z_expst_m4+z_expst_m5+z_expst_m6) sm1, (z_expst_m7+z_expst_m8+z_expst_m9+z_expst_m10+z_expst_m11+z_expst_m12) sm2";

				Bsum_detail = "z_bugst_m1 m1, z_bugst_m2 m2, z_bugst_m3 m3, z_bugst_m4 m4, z_bugst_m5 m5, ";
				Bsum_detail += "z_bugst_m6 m6, z_bugst_m7 m7, z_bugst_m8 m8, z_bugst_m9 m9, z_bugst_m10 m10, ";
				Bsum_detail += "z_bugst_m11 m11, z_bugst_m12 m12, z_bugst_m13 m13, ";
				Bsum_detail += "(z_bugst_m1+z_bugst_m2+z_bugst_m3+z_bugst_m4+z_bugst_m5+z_bugst_m6) sm1, (z_bugst_m7+z_bugst_m8+z_bugst_m9+z_bugst_m10+z_bugst_m11+z_bugst_m12) sm2";
		
		} else if (typecost.equals("B")) { 
				type_id = "= '1'";
				btype_id = "= '1'";
				sum_detail = "z_expal_m1 m1, z_expal_m2 m2, z_expal_m3 m3, z_expal_m4 m4, z_expal_m5 m5, ";
				sum_detail += "z_expal_m6 m6, z_expal_m7 m7, z_expal_m8 m8, z_expal_m9 m9, z_expal_m10 m10, ";
				sum_detail += "z_expal_m11 m11, z_expal_m12 m12, z_expal_m13 m13, ";
				sum_detail += "(z_expal_m1+z_expal_m2+z_expal_m3+z_expal_m4+z_expal_m5+z_expal_m6) sm1, (z_expal_m7+z_expal_m8+z_expal_m9+z_expal_m10+z_expal_m11+z_expal_m12) sm2";

				Bsum_detail = "z_bugal_m1 m1, z_bugal_m2 m2, z_bugal_m3 m3, z_bugal_m4 m4, z_bugal_m5 m5, ";
				Bsum_detail += "z_bugal_m6 m6, z_bugal_m7 m7, z_bugal_m8 m8, z_bugal_m9 m9, z_bugal_m10 m10, ";
				Bsum_detail += "z_bugal_m11 m11, z_bugal_m12 m12, z_bugal_m13 m13, ";
				Bsum_detail += "(z_bugal_m1+z_bugal_m2+z_bugal_m3+z_bugal_m4+z_bugal_m5+z_bugal_m6) sm1, (z_bugal_m7+z_bugal_m8+z_bugal_m9+z_bugal_m10+z_bugal_m11+z_bugal_m12) sm2";
		
		} else if (typecost.equals("C")) {
				type_id = "= '3'";
				btype_id = "= '3'";
				sum_detail = "z_expal_m1 m1, z_expal_m2 m2, z_expal_m3 m3, z_expal_m4 m4, z_expal_m5 m5, ";
				sum_detail += "z_expal_m6 m6, z_expal_m7 m7, z_expal_m8 m8, z_expal_m9 m9, z_expal_m10 m10, ";
				sum_detail += "z_expal_m11 m11, z_expal_m12 m12, z_expal_m13 m13, ";
				sum_detail += "(z_expal_m1+z_expal_m2+z_expal_m3+z_expal_m4+z_expal_m5+z_expal_m6) sm1, (z_expal_m7+z_expal_m8+z_expal_m9+z_expal_m10+z_expal_m11+z_expal_m12) sm2";

				Bsum_detail = "z_bugal_m1 m1, z_bugal_m2 m2, z_bugal_m3 m3, z_bugal_m4 m4, z_bugal_m5 m5, ";
				Bsum_detail += "z_bugal_m6 m6, z_bugal_m7 m7, z_bugal_m8 m8, z_bugal_m9 m9, z_bugal_m10 m10, ";
				Bsum_detail += "z_bugal_m11 m11, z_bugal_m12 m12, z_bugal_m13 m13, ";
				Bsum_detail += "(z_bugal_m1+z_bugal_m2+z_bugal_m3+z_bugal_m4+z_bugal_m5+z_bugal_m6) sm1, (z_bugal_m7+z_bugal_m8+z_bugal_m9+z_bugal_m10+z_bugal_m11+z_bugal_m12) sm2";

		} else if (typecost.equals("D")) {
				type_id = "= '1'";
				btype_id = "= '1'";
				sum_detail = "(z_expst_m1+z_expal_m1) m1, (z_expst_m2+z_expal_m2) m2, (z_expst_m3+z_expal_m3) m3, (z_expst_m4+z_expal_m4) m4, (z_expst_m5+z_expal_m5) m5, ";
				sum_detail += "(z_expst_m6+z_expal_m6) m6, (z_expst_m7+z_expal_m7) m7, (z_expst_m8+z_expal_m8) m8, (z_expst_m9+z_expal_m9) m9, (z_expst_m10+z_expal_m10) m10, ";
				sum_detail += "(z_expst_m11+z_expal_m11) m11, (z_expst_m12+z_expal_m12) m12, (z_expst_m13+z_expal_m13) m13, ";
				sum_detail += "(z_expst_m1+z_expal_m1+z_expst_m2+z_expal_m2+z_expst_m3+z_expal_m3+z_expst_m4+z_expal_m4+z_expst_m5+z_expal_m5+z_expst_m6+z_expal_m6) sm1, ";
				sum_detail += "(z_expst_m7+z_expal_m7+z_expst_m8+z_expal_m8+z_expst_m9+z_expal_m9+z_expst_m10+z_expal_m10+z_expst_m11+z_expal_m11+z_expst_m12+z_expal_m12) sm2";

				Bsum_detail = "(z_bugst_m1+z_bugal_m1) m1, (z_bugst_m2+z_bugal_m2) m2, (z_bugst_m3+z_bugal_m3) m3, (z_bugst_m4+z_bugal_m4) m4, (z_bugst_m5+z_bugal_m5) m5, ";
				Bsum_detail += "(z_bugst_m6+z_bugal_m6) m6, (z_bugst_m7+z_bugal_m7) m7, (z_bugst_m8+z_bugal_m8) m8, (z_bugst_m9+z_bugal_m9) m9, (z_bugst_m10+z_bugal_m10) m10, ";
				Bsum_detail += "(z_bugst_m11+z_bugal_m11) m11, (z_bugst_m12+z_bugal_m12) m12, (z_bugst_m13+z_bugal_m13) m13, ";
				Bsum_detail += "(z_bugst_m1+z_bugal_m1+z_bugst_m2+z_bugal_m2+z_bugst_m3+z_bugal_m3+z_bugst_m4+z_bugal_m4+z_bugst_m5+z_bugal_m5+z_bugst_m6+z_bugal_m6) sm1, ";
				Bsum_detail += "(z_bugst_m7+z_bugal_m7+z_bugst_m8+z_bugal_m8+z_bugst_m9+z_bugal_m9+z_bugst_m10+z_bugal_m10+z_bugst_m11+z_bugal_m11+z_bugst_m12+z_bugal_m12) sm2";

		} else if (typecost.equals("E")) {
				type_id = "in ('1','3')";
				btype_id = "= '1'";
				sum_detail = "(z_expst_m1+z_expal_m1) m1, (z_expst_m2+z_expal_m2) m2, (z_expst_m3+z_expal_m3) m3, (z_expst_m4+z_expal_m4) m4, (z_expst_m5+z_expal_m5) m5, ";
				sum_detail += "(z_expst_m6+z_expal_m6) m6, (z_expst_m7+z_expal_m7) m7, (z_expst_m8+z_expal_m8) m8, (z_expst_m9+z_expal_m9) m9, (z_expst_m10+z_expal_m10) m10, ";
				sum_detail += "(z_expst_m11+z_expal_m11) m11, (z_expst_m12+z_expal_m12) m12, (z_expst_m13+z_expal_m13) m13, ";
				sum_detail += "(z_expst_m1+z_expal_m1+z_expst_m2+z_expal_m2+z_expst_m3+z_expal_m3+z_expst_m4+z_expal_m4+z_expst_m5+z_expal_m5+z_expst_m6+z_expal_m6) sm1, ";
				sum_detail += "(z_expst_m7+z_expal_m7+z_expst_m8+z_expal_m8+z_expst_m9+z_expal_m9+z_expst_m10+z_expal_m10+z_expst_m11+z_expal_m11+z_expst_m12+z_expal_m12) sm2";
				
				Bsum_detail = "(z_bugst_m1+z_bugal_m1) m1, (z_bugst_m2+z_bugal_m2) m2, (z_bugst_m3+z_bugal_m3) m3, (z_bugst_m4+z_bugal_m4) m4, (z_bugst_m5+z_bugal_m5) m5, ";
				Bsum_detail += "(z_bugst_m6+z_bugal_m6) m6, (z_bugst_m7+z_bugal_m7) m7, (z_bugst_m8+z_bugal_m8) m8, (z_bugst_m9+z_bugal_m9) m9, (z_bugst_m10+z_bugal_m10) m10, ";
				Bsum_detail += "(z_bugst_m11+z_bugal_m11) m11, (z_bugst_m12+z_bugal_m12) m12, (z_bugst_m13+z_bugal_m13) m13, ";
				Bsum_detail += "(z_bugst_m1+z_bugal_m1+z_bugst_m2+z_bugal_m2+z_bugst_m3+z_bugal_m3+z_bugst_m4+z_bugal_m4+z_bugst_m5+z_bugal_m5+z_bugst_m6+z_bugal_m6) sm1, ";
				Bsum_detail += "(z_bugst_m7+z_bugal_m7+z_bugst_m8+z_bugal_m8+z_bugst_m9+z_bugal_m9+z_bugst_m10+z_bugal_m10+z_bugst_m11+z_bugal_m11+z_bugst_m12+z_bugal_m12) sm2";

				/*sum_total = "sum(z_expst_m1+z_expal_m1) m1, sum(z_expst_m2+z_expal_m2) m2, sum(z_expst_m3+z_expal_m3) m3, sum(z_expst_m4+z_expal_m4) m4, sum(z_expst_m5+z_expal_m5) m5, ";
				sum_total += "sum(z_expst_m6+z_expal_m6) m6, sum(z_expst_m7+z_expal_m7) m7, sum(z_expst_m8+z_expal_m8) m8, sum(z_expst_m9+z_expal_m9) m9, sum(z_expst_m10+z_expal_m10) m10, ";
				sum_total += "sum(z_expst_m11+z_expal_m11) m11, sum(z_expst_m12+z_expal_m12) m12, sum(z_expst_m13+z_expal_m13) m13, ";
				sum_total += "sum(z_expst_m1+z_expal_m1+z_expst_m2+z_expal_m2+z_expst_m3+z_expal_m3+z_expst_m4+z_expal_m4+z_expst_m5+z_expal_m5+z_expst_m6+z_expal_m6) sm1, ";
				sum_total += "sum(z_expst_m7+z_expal_m7+z_expst_m8+z_expal_m8+z_expst_m9+z_expal_m9+z_expst_m10+z_expal_m10+z_expst_m11+z_expal_m11+z_expst_m12+z_expal_m12) sm2";
				*/
		}
			 //---------------------- Calculate % ---------------------
			  z_net_ytd = 0;
			  sql.delete(0, sql.length());
			  sql.append("select (z_net_ytd/1000) as z_net_ytd from lan:acmycost ")
					.append("where i_year = '"+year+"' ")
					.append("and i_company = '"+i_com+"' ")                                                                
					.append("and i_project = '"+i_proj+"' ");      
			  rs1 = stmt1.executeQuery(sql.toString());
			  if (rs1.next()) {
					z_net_ytd = rs1.getDouble("z_net_ytd");
			  }


if (!typecost.equals("C")) {	 //  typecost not equals 'C'

		//---------------------- MAIN ACCOUNT ---------------------
				/*sql.delete(0, sql.length());
				sql.append("select a.i_acctno, b.acct_desc ") 
					.append("from lan:acbstdep a, lan:stxchrtr b ")
					.append("where a.i_type = '"+f_type+"' ")     // Not Accountt Service
					.append("and a.i_acctno = b.acct_no ")	
					.append("order by a.i_acctno");  */
					
				sql.delete(0, sql.length());
				sql.append("select distinct a.i_acctno, b.acct_desc ") 
					.append("from lan:acbexpdp a, lan:stxchrtr b ");					
		 if (type.equals("V2")) {	
                sql.append("where a.i_type = 'IDR' ");	 
		 } else {			
				sql.append("where a.i_type = 'EXP' ");
		 }
				sql.append("and a.i_acctno = b.acct_no ")	
				    .append("and i_dep = '01' ")
					.append("order by a.i_acctno");				
				rsmain = stmtmain.executeQuery(sql.toString());
				while (rsmain.next()==true) {
						
					acct_desc = doString.DisplayThai(doString.checkString(rsmain.getString("acct_desc")));

					   chk_link = "";
					   sql.delete(0, sql.length());
					   sql.append("select rod_acct_no from lan:stgrow2d ")
							.append("where rod_profile_id = 'EISEXP' ")
							.append("and rod_acct_no = '"+doString.checkString(rsmain.getString("i_acctno"))+"' ");
					   rs = stmt.executeQuery(sql.toString());
					   if (rs.next()==true) {
							chk_link = "Y";
					   }
				
					
					// Clear Value
					v_m1 = 0; v_m2 = 0; v_m3 = 0; v_m4 = 0; v_m5 = 0; v_m6 = 0; v_m7 = 0; v_m8 = 0; v_m9 = 0; v_m10 = 0; v_m11 = 0; v_m12 = 0; v_m13 = 0; v_sm1 = 0; v_sm2 = 0;
					b_m1 = 0; b_m2 = 0; b_m3 = 0; b_m4 = 0; b_m5 = 0; b_m6 = 0; b_m7 = 0; b_m8 = 0; b_m9 = 0; b_m10 = 0; b_m11 = 0; b_m12 = 0; b_m13 = 0; b_sm1 = 0; b_sm2 = 0;
								
							  //----------------------  ACTUAL -------------------------------
							   sql.delete(0, sql.length());
							   sql.append("select "+sum_detail+", a.i_acctno, b.acct_desc from "+tb_name+" a, lan:stxchrtr b ") 
									.append("where i_year = '"+year+"' ")                                  
									.append("and i_company = '"+i_com+"' ")                                        
									.append("and i_project = '"+i_proj+"' ")                  
									.append("and i_acctno != 'TOTAL' ")
									.append("and i_type "+type_id+" ")                                                     
								    .append("and i_acctno = '"+doString.checkString(rsmain.getString("i_acctno"))+"' ");
							   //out.println(sql.toString());
								rs = stmt.executeQuery(sql.toString());
								if (rs.next()==true) {
										b_m1 = rs.getDouble("m1")/1000;
										b_m2 = rs.getDouble("m2")/1000;
										b_m3 = rs.getDouble("m3")/1000;
										b_m4 = rs.getDouble("m4")/1000;
										b_m5 = rs.getDouble("m5")/1000;
										b_m6 = rs.getDouble("m6")/1000;
										b_m7 = rs.getDouble("m7")/1000;
										b_m8 = rs.getDouble("m8")/1000;
										b_m9 = rs.getDouble("m9")/1000;
										b_m10 = rs.getDouble("m10")/1000;
										b_m11 = rs.getDouble("m11")/1000;
										b_m12 = rs.getDouble("m12")/1000;
										b_m13 = rs.getDouble("m13")/1000;
										b_sm1= rs.getDouble("sm1")/1000;
										b_sm2 = rs.getDouble("sm2")/1000;  
										
							} // end if rs						
							
							    //----------------------  BUDGET -------------------------------
								//bv_m1 = 0; bv_m2 = 0; bv_m3 = 0; bv_m4 = 0; bv_m5 = 0; bv_m6 = 0; bv_m7 = 0; bv_m8 = 0; bv_m9 = 0; bv_m10 = 0; bv_m11 = 0; bv_m12 = 0; bv_m13 = 0; bv_sm1 = 0; bv_sm2 = 0;
										   sql.delete(0, sql.length());
										   sql.append("select "+Bsum_detail+", i_acctno from "+Btb_name+" ") 
												.append("where i_year = '"+year+"' ")                                  
												.append("and i_company = '"+i_com+"' ")                                        
												.append("and i_project = '"+i_proj+"' ")                  
												.append("and i_acctno != 'TOTAL' ")
											    .append("and i_acctno = '"+doString.checkString(rsmain.getString("i_acctno"))+"' ")
												.append("and i_type "+btype_id+" ");                          
											rsb = stmtb.executeQuery(sql.toString());
											if (rsb.next()) {					
																
												v_m1 = rsb.getDouble("m1")/1000;
												v_m2 = rsb.getDouble("m2")/1000;
												v_m3 = rsb.getDouble("m3")/1000;
												v_m4 = rsb.getDouble("m4")/1000;
												v_m5 = rsb.getDouble("m5")/1000;
												v_m6 = rsb.getDouble("m6")/1000;
												v_m7 = rsb.getDouble("m7")/1000;
												v_m8 = rsb.getDouble("m8")/1000;
												v_m9 = rsb.getDouble("m9")/1000;
												v_m10 = rsb.getDouble("m10")/1000;
												v_m11= rsb.getDouble("m11")/1000;
												v_m12 = rsb.getDouble("m12")/1000;
												v_m13 = rsb.getDouble("m13")/1000;
												v_sm1= rsb.getDouble("sm1")/1000;
												v_sm2 = rsb.getDouble("sm2")/1000;  							
				
									} // end if rsb	  

										 //---------------------- Calculate % ---------------------										
										  a_per1 = 0;
										  b_per1 = 0;
								
										  if (z_net_ytd == 0) {
												b_per1 = 0;
												a_per1 = 0;														
										  } else {
												b_per1 = (b_m13 / z_net_ytd) * 100;    //  % Actual
												a_per1 = (v_m13 / z_net_ytd) * 100;    //  % Budget														
										  }					
										  

%>
    <tr class="col_right ; specH1 ; white">
      <td width="270px" class="col_left ; item" style="font-size:8pt"><%=doString.checkString(rsmain.getString("i_acctno"))%>-<%=acct_desc%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m1)%></td>
      <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=01&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m1)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m2)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=02&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m2)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m3)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=03&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m3)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m4)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=04&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m4)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m5)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=05&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m5)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m6)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=06&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m6)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m7)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=07&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m7)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m8)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=08&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m8)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m9)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=09&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m9)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m10)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=10&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m10)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m11)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=11&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m11)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m12)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=12&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m12)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_sm1)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=Q1&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_sm1)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_sm2)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=Q2&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_sm2)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m13)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=ALL&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m13)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", a_per1)%></td>
      <td width="50px"><%=doString.displayNumber("###,###.0", b_per1)%></td>
    </tr>
<%		
					//  --------------   Total Acct -----------------										
									tot_m1 += b_m1;
									tot_m2 += b_m2;
									tot_m3 += b_m3;
									tot_m4+= b_m4;
									tot_m5 += b_m5;
									tot_m6 += b_m6;
									tot_m7 += b_m7;
									tot_m8 += b_m8;
									tot_m9 += b_m9;
									tot_m10 += b_m10;
									tot_m11 += b_m11;
									tot_m12 += b_m12;
									tot_sm1 += b_sm1;
									tot_sm2 += b_sm2;
									tot_m13 += b_m13;		

									tot_vm1 += v_m1;
									tot_vm2 += v_m2;
									tot_vm3 += v_m3;
									tot_vm4+= v_m4;
									tot_vm5 += v_m5;
									tot_vm6 += v_m6;
									tot_vm7 += v_m7;
									tot_vm8 += v_m8;
									tot_vm9 += v_m9;
									tot_vm10 += v_m10;
									tot_vm11 += v_m11;
									tot_vm12 += v_m12;
									tot_vsm1 += v_sm1;
									tot_vsm2 += v_sm2;
									tot_vm13 += v_m13;
		} // end while main
} // end if typecost not equals  C

if (typecost.equals("C") || typecost.equals("E")) {

				   //----------------------  ACTUAL -----------------------------
				   sql.delete(0, sql.length());
				   sql.append("select "+sum_detail+", i_acctno from "+tb_name+" ") 
						.append("where i_year = '"+year+"' ")                                  
						.append("and i_company = '"+i_com+"' ")                                        
						.append("and i_project = '"+i_proj+"' ")                  
						.append("and i_acctno = 'TOTAL' ")
						.append("and i_acctno not in (select a.i_acctno from acbstdep a where a.i_type = '"+type_no+"' and a.i_acctno = i_acctno) ")  
						.append("and i_type = '3' ");
				   rs = stmt.executeQuery(sql.toString());
				   if (rs.next()==true) {				
							Atpec_m1 = rs.getDouble("m1")/1000;
							Atpec_m2 = rs.getDouble("m2")/1000;
							Atpec_m3 = rs.getDouble("m3")/1000;
							Atpec_m4 = rs.getDouble("m4")/1000;
							Atpec_m5 = rs.getDouble("m5")/1000;
							Atpec_m6 = rs.getDouble("m6")/1000;
							Atpec_m7 = rs.getDouble("m7")/1000;
							Atpec_m8 = rs.getDouble("m8")/1000;
							Atpec_m9 = rs.getDouble("m9")/1000;
							Atpec_m10 = rs.getDouble("m10")/1000;
							Atpec_m11 = rs.getDouble("m11")/1000;
							Atpec_m12 = rs.getDouble("m12")/1000;
							Atpec_m13 = rs.getDouble("m13")/1000;
							Atpec_sm1= rs.getDouble("sm1")/1000;
							Atpec_sm2 = rs.getDouble("sm2")/1000;  
					} // end if
				
									   //----------------------  BUDGET -----------------------------
									   sql.delete(0, sql.length());
									   sql.append("select z_amount, month(d_cash) as mnt_cash ")                                                     
											.append("from lan:acbcasfd ")                                                               
											.append("where i_bud_type = '1' ")                                                          
											.append("and i_code = '"+code_no+"' ")                                                              
											.append("and i_detail = '002' ")                                                            
											.append("and year(d_cash) = '"+(Integer.parseInt(year)-543)+"' ")                                  
											.append("and i_company = '"+i_com+"' ")                                                            
											.append("and i_project = '"+i_proj+"' ")                                                            
											.append("order by 2,1");      
									rs = stmt.executeQuery(sql.toString());
									while (rs.next()==true) {	

											if (doString.checkString(rs.getString("mnt_cash")).equals("1")) {
													Btpec_m1 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("2")) {
													Btpec_m2 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("3")) {
													Btpec_m3 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("4")) {
													Btpec_m4 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("5")) {
													Btpec_m5 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("6")) {
													Btpec_m6 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("7")) {
													Btpec_m7 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("8")) {
													Btpec_m8 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("9")) {
													Btpec_m9 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("10")) {
													Btpec_m10 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("11")) {
													Btpec_m11 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("12")) {
													Btpec_m12 = rs.getDouble("z_amount")/1000;		
											} 
											Btpec_sm1 = Btpec_m1+Btpec_m2+Btpec_m3+Btpec_m4+Btpec_m5+Btpec_m6;
											Btpec_sm2 = Btpec_m7+Btpec_m8+Btpec_m9+Btpec_m10+Btpec_m11+Btpec_m12;
											Btpec_m13 = Btpec_sm1+Btpec_sm2;
									} // end while
											 
										//---------------------- Calculate % ---------------------											 
										  Aper_all = 0;
										  Bper_all = 0;
										  if (z_net_ytd == 0) {									
													Aper_all = 0;
													Bper_all = 0;
										   } else {									
													Aper_all = (Atpec_m13/z_net_ytd) * 100;
													Bper_all = (Btpec_m13/z_net_ytd) * 100;
										   }
%>
<tr class="col_right ; specH1 ; white">
      <td width="270px" class="col_left ; item" style="font-size:8pt">ส่วนกลาง TOTAL - รวมรหัสบัญชี</td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m1)%></td>
      <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m1)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m2)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m2)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m3)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m3)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m4)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m4)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m5)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m5)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m6)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m6)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m7)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m7)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m8)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m8)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m9)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m9)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m10)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m10)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m11)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m11)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m12)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m12)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_sm1)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_sm1)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_sm2)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_sm2)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m13)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m13)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Bper_all)%></td>
      <td width="50px"><%=doString.displayNumber("###,###.0", Aper_all)%></td>
    </tr>
<%
} // end if typecost = C, E						

					//-------- รวมทุกบัญชี  Actual -----------
						Atot_m1 = tot_m1+Atpec_m1;
						Atot_m2 = tot_m2+Atpec_m2;
						Atot_m3 = tot_m3+Atpec_m3;
						Atot_m4 = tot_m4+Atpec_m4;
						Atot_m5 = tot_m5+Atpec_m5;
						Atot_m6 = tot_m6+Atpec_m6;
						Atot_m7 = tot_m7+Atpec_m7;
						Atot_m8 = tot_m8+Atpec_m8;
						Atot_m9 = tot_m9+Atpec_m9;
						Atot_m10 = tot_m10+Atpec_m10;
						Atot_m11 = tot_m11+Atpec_m11;
						Atot_m12 = tot_m12+Atpec_m12;
						Atot_sm1 = tot_sm1+Atpec_sm1;
						Atot_sm2 = tot_sm2+Atpec_sm2;
						Atot_m13 = tot_m13+Atpec_m13;
					//-------- รวมทุกบัญชี  Budget -----------
						Atot_vm1 = tot_vm1+Btpec_m1;
						Atot_vm2 = tot_vm2+Btpec_m2;
						Atot_vm3 = tot_vm3+Btpec_m3;
						Atot_vm4 = tot_vm4+Btpec_m4;
						Atot_vm5 = tot_vm5+Btpec_m5;
						Atot_vm6 = tot_vm6+Btpec_m6;
						Atot_vm7 = tot_vm7+Btpec_m7;
						Atot_vm8 = tot_vm8+Btpec_m8;
						Atot_vm9 = tot_vm9+Btpec_m9;
						Atot_vm10 = tot_vm10+Btpec_m10;
						Atot_vm11 = tot_vm11+Btpec_m11;
						Atot_vm12 = tot_vm12+Btpec_m12;
						Atot_vsm1 = tot_vsm1+Btpec_sm1;
						Atot_vsm2 = tot_vsm2+Btpec_sm2;
						Atot_vm13 = tot_vm13+Btpec_m13;	
						
					   //  -----------------  TOTAL  Percent   ---------------
						if (z_net_ytd == 0) {
								Atot_vper = 0;
								Atot_per = 0;
						} else {
								Atot_vper = (Atot_vm13 / z_net_ytd) * 100;	//  %  Budget		 
								Atot_per = (Atot_m13 / z_net_ytd) * 100;		//  %  Actual
						}		
%>
    <tr class="specH1">
      <td width="270px" class="col_name1">รวมทุกบัญชี</td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_vm1)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_m1)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_vm2)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_m2)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_vm3)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_m3)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_vm4)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_m4)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_vm5)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_m5)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_vm6)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_m6)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_vm7)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_m7)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_vm8)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_m8)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_vm9)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_m9)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_vm10)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_m10)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_vm11)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_m11)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_vm12)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_m12)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_vsm1)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_sm1)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_vsm2)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_sm2)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_vm13)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_m13)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_vper)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", Atot_per)%></td>
    </tr>

  <tr class="col_right ; specH1">
  <td width="270px" class="col_name1"><%=n_type%> ฝ่ายบริการ</td>
  <td width="50px" class="col_name1" colspan=32>&nbsp;</td>
  </tr>
<%
//====================== FOR SERVICE ============================

// Clear Variable
int line_a = 0, line_b = 0;
tot_m1 = 0; tot_m2 = 0; tot_m3 = 0; tot_m4 = 0; tot_m5 = 0; tot_m6 = 0; tot_m7 = 0; tot_m8 = 0; tot_m9 = 0; tot_m10 = 0; tot_m11 = 0; tot_m12 = 0; tot_m13 = 0; tot_sm1 = 0; tot_sm2 = 0;
tot_vm1 = 0; tot_vm2 = 0; tot_vm3 = 0; tot_vm4 = 0; tot_vm5 = 0; tot_vm6 = 0; tot_vm7 = 0; tot_vm8 = 0; tot_vm9 = 0; tot_vm10 = 0; tot_vm11 = 0; tot_vm12 = 0; tot_vm13 = 0; tot_vsm1 = 0; tot_vsm2 = 0;
Atpec_m1 = 0; Atpec_m2 = 0; Atpec_m3 = 0; Atpec_m4 = 0; Atpec_m5 = 0; Atpec_m6 = 0; Atpec_m7 = 0; Atpec_m8 = 0; Atpec_m9 = 0; Atpec_m10 = 0; Atpec_m11 = 0; Atpec_m12 = 0; Atpec_m13 = 0; Atpec_sm1 = 0; Atpec_sm2 = 0;
Btpec_m1 = 0; Btpec_m2 = 0; Btpec_m3 = 0; Btpec_m4 = 0; Btpec_m5 = 0; Btpec_m6 = 0; Btpec_m7 = 0; Btpec_m8 = 0; Btpec_m9 = 0; Btpec_m10 = 0; Btpec_m11 = 0; Btpec_m12 = 0; Btpec_m13 = 0; Btpec_sm1 = 0; Btpec_sm2 = 0;


  if (!typecost.equals("C")) {	 //  typecost not equals 'C'

		//---------------------- MAIN ACCOUNT ---------------------
				sql.delete(0, sql.length());
				sql.append("select a.i_acctno, b.acct_desc ") 
					.append("from lan:acbstdep a, lan:stxchrtr b ")
					.append("where a.i_type = '"+type_no+"' ")     // Service Only
					.append("and a.i_acctno = b.acct_no ")	
					.append("order by a.i_acctno");
				//	out.println(sql.toString());
				rsmain = stmtmain.executeQuery(sql.toString());
				while (rsmain.next()==true) {
					line_a++;
						
					acct_desc = doString.DisplayThai(doString.checkString(rsmain.getString("acct_desc")));
					
					// Clear Value
					v_m1 = 0; v_m2 = 0; v_m3 = 0; v_m4 = 0; v_m5 = 0; v_m6 = 0; v_m7 = 0; v_m8 = 0; v_m9 = 0; v_m10 = 0; v_m11 = 0; v_m12 = 0; v_m13 = 0; v_sm1 = 0; v_sm2 = 0;
					b_m1 = 0; b_m2 = 0; b_m3 = 0; b_m4 = 0; b_m5 = 0; b_m6 = 0; b_m7 = 0; b_m8 = 0; b_m9 = 0; b_m10 = 0; b_m11 = 0; b_m12 = 0; b_m13 = 0; b_sm1 = 0; b_sm2 = 0;
					chk_link = "";			
						   								
							  //----------------------  ACTUAL -------------------------------
							   sql.delete(0, sql.length());
							   sql.append("select "+sum_detail+", a.i_acctno, b.acct_desc from "+tb_name+" a, lan:stxchrtr b ") 
									.append("where i_year = '"+year+"' ")                                  
									.append("and i_company = '"+i_com+"' ")                                        
									.append("and i_project = '"+i_proj+"' ")                  
									.append("and i_acctno != 'TOTAL' ")
									.append("and i_type "+type_id+" ")                                                     
								    .append("and i_acctno = '"+doString.checkString(rsmain.getString("i_acctno"))+"' ");
								rs = stmt.executeQuery(sql.toString());
								if (rs.next()==true) {
										b_m1 = rs.getDouble("m1")/1000;
										b_m2 = rs.getDouble("m2")/1000;
										b_m3 = rs.getDouble("m3")/1000;
										b_m4 = rs.getDouble("m4")/1000;
										b_m5 = rs.getDouble("m5")/1000;
										b_m6 = rs.getDouble("m6")/1000;
										b_m7 = rs.getDouble("m7")/1000;
										b_m8 = rs.getDouble("m8")/1000;
										b_m9 = rs.getDouble("m9")/1000;
										b_m10 = rs.getDouble("m10")/1000;
										b_m11 = rs.getDouble("m11")/1000;
										b_m12 = rs.getDouble("m12")/1000;
										b_m13 = rs.getDouble("m13")/1000;
										b_sm1= rs.getDouble("sm1")/1000;
										b_sm2 = rs.getDouble("sm2")/1000;  
										
							} // end if rs						
							
							    //----------------------  BUDGET -------------------------------
								//bv_m1 = 0; bv_m2 = 0; bv_m3 = 0; bv_m4 = 0; bv_m5 = 0; bv_m6 = 0; bv_m7 = 0; bv_m8 = 0; bv_m9 = 0; bv_m10 = 0; bv_m11 = 0; bv_m12 = 0; bv_m13 = 0; bv_sm1 = 0; bv_sm2 = 0;
										   sql.delete(0, sql.length());
										   sql.append("select "+Bsum_detail+", i_acctno from "+Btb_name+" ") 
												.append("where i_year = '"+year+"' ")                                  
												.append("and i_company = '"+i_com+"' ")                                        
												.append("and i_project = '"+i_proj+"' ")                  
												.append("and i_acctno != 'TOTAL' ")
											    .append("and i_acctno = '"+doString.checkString(rsmain.getString("i_acctno"))+"' ")
												.append("and i_type "+btype_id+" ");                          
											rsb = stmtb.executeQuery(sql.toString());
											if (rsb.next()) {					
																
												v_m1 = rsb.getDouble("m1")/1000;
												v_m2 = rsb.getDouble("m2")/1000;
												v_m3 = rsb.getDouble("m3")/1000;
												v_m4 = rsb.getDouble("m4")/1000;
												v_m5 = rsb.getDouble("m5")/1000;
												v_m6 = rsb.getDouble("m6")/1000;
												v_m7 = rsb.getDouble("m7")/1000;
												v_m8 = rsb.getDouble("m8")/1000;
												v_m9 = rsb.getDouble("m9")/1000;
												v_m10 = rsb.getDouble("m10")/1000;
												v_m11= rsb.getDouble("m11")/1000;
												v_m12 = rsb.getDouble("m12")/1000;
												v_m13 = rsb.getDouble("m13")/1000;
												v_sm1= rsb.getDouble("sm1")/1000;
												v_sm2 = rsb.getDouble("sm2")/1000;  							
				
									} // end if rsb	  
												 //---------------------- Calculate % ---------------------												  
												  a_per1 = 0;
												  b_per1 = 0;
												  if (z_net_ytd == 0) {
														b_per1 = 0;
														a_per1 = 0;														
												  } else {
													    b_per1 = (b_m13 / z_net_ytd) * 100;    //  % Actual
														a_per1 = (v_m13 / z_net_ytd) * 100;    //  % Budget														
												  }																								 
%>
 <tr class="col_right ; specH1 ; white">
      <td width="270px" class="col_left ; item" style="font-size:8pt"><%=doString.checkString(rsmain.getString("i_acctno"))%>-<%=acct_desc%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m1)%></td>
      <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=01&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m1)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m2)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=02&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m2)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m3)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=03&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m3)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m4)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=04&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m4)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m5)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=05&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m5)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m6)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=06&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m6)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m7)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=07&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m7)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m8)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=08&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m8)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m9)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=09&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m9)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m10)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=10&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m10)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m11)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=11&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m11)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m12)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=12&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m12)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_sm1)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=Q1&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_sm1)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_sm2)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=Q2&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_sm2)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m13)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_ExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rsmain.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=ALL&year=<%=year%>&type=<%=type%>"><% } %><%=doString.displayNumber("###,###.0", b_m13)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", a_per1)%></td>
      <td width="50px"><%=doString.displayNumber("###,###.0", b_per1)%></td>
    </tr>   
<%						//  --------------   Total Actual -----------------										
									tot_m1 += b_m1;
									tot_m2 += b_m2;
									tot_m3 += b_m3;
									tot_m4+= b_m4;
									tot_m5 += b_m5;
									tot_m6 += b_m6;
									tot_m7 += b_m7;
									tot_m8 += b_m8;
									tot_m9 += b_m9;
									tot_m10 += b_m10;
									tot_m11 += b_m11;
									tot_m12 += b_m12;
									tot_sm1 += b_sm1;
									tot_sm2 += b_sm2;
									tot_m13 += b_m13;		
							//  --------------   Total Budget -----------------
									tot_vm1 += v_m1;
									tot_vm2 += v_m2;
									tot_vm3 += v_m3;
									tot_vm4+= v_m4;
									tot_vm5 += v_m5;
									tot_vm6 += v_m6;
									tot_vm7 += v_m7;
									tot_vm8 += v_m8;
									tot_vm9 += v_m9;
									tot_vm10 += v_m10;
									tot_vm11 += v_m11;
									tot_vm12 += v_m12;
									tot_vsm1 += v_sm1;
									tot_vsm2 += v_sm2;
									tot_vm13 += v_m13;
		} // end while main
} // end if typecost not equals  C

		if (typecost.equals("C")) {     //|| typecost.equals("E")
				line_b++;
				   //----------------------  ACTUAL -----------------------------
				   sql.delete(0, sql.length());
				   sql.append("select "+sum_detail+", i_acctno from "+tb_name+" ") 
						.append("where i_year = '"+year+"' ")                                  
						.append("and i_company = '"+i_com+"' ")                                        
						.append("and i_project = '"+i_proj+"' ")                  
						.append("and i_acctno = 'TOTAL' ")
						.append("and i_acctno in (select a.i_acctno from acbstdep a where a.i_type = '"+type_no+"' and a.i_acctno = i_acctno) ")  
						.append("and i_type = '3' ");						
				   rs = stmt.executeQuery(sql.toString());
				   if (rs.next()==true) {				
							Atpec_m1 = rs.getDouble("m1")/1000;
							Atpec_m2 = rs.getDouble("m2")/1000;
							Atpec_m3 = rs.getDouble("m3")/1000;
							Atpec_m4 = rs.getDouble("m4")/1000;
							Atpec_m5 = rs.getDouble("m5")/1000;
							Atpec_m6 = rs.getDouble("m6")/1000;
							Atpec_m7 = rs.getDouble("m7")/1000;
							Atpec_m8 = rs.getDouble("m8")/1000;
							Atpec_m9 = rs.getDouble("m9")/1000;
							Atpec_m10 = rs.getDouble("m10")/1000;
							Atpec_m11 = rs.getDouble("m11")/1000;
							Atpec_m12 = rs.getDouble("m12")/1000;
							Atpec_m13 = rs.getDouble("m13")/1000;
							Atpec_sm1= rs.getDouble("sm1")/1000;
							Atpec_sm2 = rs.getDouble("sm2")/1000;  
					} // end if
				
									   //----------------------  BUDGET -----------------------------
									   sql.delete(0, sql.length());
									   sql.append("select z_amount, month(d_cash) as mnt_cash ")                                                     
											.append("from lan:acbcasfd ")                                                               
											.append("where i_bud_type = '1' ")                                                          
											.append("and i_code = '"+code_no+"' ")                                                              
											.append("and i_detail = '002' ")                                                            
											.append("and year(d_cash) = '"+(Integer.parseInt(year)-543)+"' ")                                  
											.append("and i_company = '"+i_com+"' ")                                                            
											.append("and i_project = '"+i_proj+"' ")                                                            
											.append("order by 2,1");      
									rs = stmt.executeQuery(sql.toString());
									while (rs.next()==true) {	

											if (doString.checkString(rs.getString("mnt_cash")).equals("1")) {
													Btpec_m1 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("2")) {
													Btpec_m2 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("3")) {
													Btpec_m3 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("4")) {
													Btpec_m4 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("5")) {
													Btpec_m5 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("6")) {
													Btpec_m6 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("7")) {
													Btpec_m7 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("8")) {
													Btpec_m8 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("9")) {
													Btpec_m9 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("10")) {
													Btpec_m10 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("11")) {
													Btpec_m11 = rs.getDouble("z_amount")/1000;		
											} else if (doString.checkString(rs.getString("mnt_cash")).equals("12")) {
													Btpec_m12 = rs.getDouble("z_amount")/1000;		
											} 
											Btpec_sm1 = Btpec_m1+Btpec_m2+Btpec_m3+Btpec_m4+Btpec_m5+Btpec_m6;
											Btpec_sm2 = Btpec_m7+Btpec_m8+Btpec_m9+Btpec_m10+Btpec_m11+Btpec_m12;
											Btpec_m13 = Btpec_sm1+Btpec_sm2;
									} // end while
											 
											//---------------------- Calculate % ---------------------											  
											  Aper_all = 0;
											  Bper_all = 0;											  
											   if (z_net_ytd == 0) {									
														Aper_all = 0;
														Bper_all = 0;
											   } else {									
														Aper_all = (Atpec_m13/z_net_ytd) * 100;
														Bper_all = (Btpec_m13/z_net_ytd) * 100;
											   }
%>
	   <tr class="col_right ; specH1 ; white">
      <td width="270px" class="col_left ; item" style="font-size:8pt">ส่วนกลาง TOTAL - รวมรหัสบัญชี</td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m1)%></td>
      <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m1)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m2)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m2)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m3)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m3)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m4)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m4)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m5)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m5)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m6)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m6)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m7)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m7)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m8)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m8)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m9)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m9)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m10)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m10)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m11)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m11)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m12)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m12)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_sm1)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_sm1)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_sm2)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_sm2)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Btpec_m13)%></td>
	  <td width="50px"><%=doString.displayNumber("###,###.0", Atpec_m13)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", Bper_all)%></td>
      <td width="50px"><%=doString.displayNumber("###,###.0", Aper_all)%></td>
    </tr>
<%
		} // end if typecost = C, E	

						//-------- รวมทุกบัญชี Service  Actual -----------
							stot_m1 = tot_m1+Atpec_m1;
							stot_m2 = tot_m2+Atpec_m2;
							stot_m3 = tot_m3+Atpec_m3;
							stot_m4 = tot_m4+Atpec_m4;
							stot_m5 = tot_m5+Atpec_m5;
							stot_m6 = tot_m6+Atpec_m6;
							stot_m7 = tot_m7+Atpec_m7;
							stot_m8 = tot_m8+Atpec_m8;
							stot_m9 = tot_m9+Atpec_m9;
							stot_m10 = tot_m10+Atpec_m10;
							stot_m11 = tot_m11+Atpec_m11;
							stot_m12 = tot_m12+Atpec_m12;
							stot_sm1 = tot_sm1+Atpec_sm1;
							stot_sm2 = tot_sm2+Atpec_sm2;
							stot_m13 = tot_m13+Atpec_m13;
						//-------- รวมทุกบัญชี  Service  Budget -----------
							stot_vm1 = tot_vm1+Btpec_m1;
							stot_vm2 = tot_vm2+Btpec_m2;
							stot_vm3 = tot_vm3+Btpec_m3;
							stot_vm4 = tot_vm4+Btpec_m4;
							stot_vm5 = tot_vm5+Btpec_m5;
							stot_vm6 = tot_vm6+Btpec_m6;
							stot_vm7 = tot_vm7+Btpec_m7;
							stot_vm8 = tot_vm8+Btpec_m8;
							stot_vm9 = tot_vm9+Btpec_m9;
							stot_vm10 = tot_vm10+Btpec_m10;
							stot_vm11 = tot_vm11+Btpec_m11;
							stot_vm12 = tot_vm12+Btpec_m12;
							stot_vsm1 = tot_vsm1+Btpec_sm1;
							stot_vsm2 = tot_vsm2+Btpec_sm2;
							stot_vm13 = tot_vm13+Btpec_m13;	 				
						 //  -----------------  TOTAL  Percent   ---------------
							if (z_net_ytd == 0) {
									stot_vper = 0;
									stot_per = 0;
							} else {
									stot_vper = (stot_vm13 / z_net_ytd) * 100;	//  %  Budget		 
									stot_per = (stot_m13 / z_net_ytd) * 100;		//  %  Actual
							}

		if (line_a ==0 && line_b ==0){
%>
		<tr class="col_center ; specH1 ; white">
			<td width="23%" colspan=33>*****  ไม่มีรหัสบัญชีของฝ่ายบริการ  *****</td>
		</tr>
<%	} // end chk line       %>
   
	<tr class="specH1">
      <td width="270px" class="col_name1">รวมทุกบัญชี ฝ่ายบริการ</td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_vm1)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_m1)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_vm2)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_m2)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_vm3)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_m3)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_vm4)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_m4)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_vm5)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_m5)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_vm6)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_m6)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_vm7)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_m7)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_vm8)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_m8)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_vm9)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_m9)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_vm10)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_m10)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_vm11)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_m11)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_vm12)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_m12)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_vsm1)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_sm1)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_vsm2)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_sm2)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_vm13)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_m13)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_vper)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", stot_per)%></td>
    </tr>	
<%
						//-------- รวมทุกบัญชี  Actual -----------
						all_m1 = stot_m1+Atot_m1;
						all_m2 = stot_m2+Atot_m2;
						all_m3 = stot_m3+Atot_m3;
						all_m4 = stot_m4+Atot_m4;
						all_m5 = stot_m5+Atot_m5;
						all_m6 = stot_m6+Atot_m6;
						all_m7 = stot_m7+Atot_m7;
						all_m8 = stot_m8+Atot_m8;
						all_m9 = stot_m9+Atot_m9;
						all_m10 = stot_m10+Atot_m10;
						all_m11 = stot_m11+Atot_m11;
						all_m12 = stot_m12+Atot_m12;
						all_sm1 = stot_sm1+Atot_sm1;
						all_sm2 = stot_sm2+Atot_sm2;
						all_m13 = stot_m13+Atot_m13;
						//-------- รวมทุกบัญชี  Budget -----------
						all_vm1 = stot_vm1+Atot_vm1;
						all_vm2 = stot_vm2+Atot_vm2;
						all_vm3 = stot_vm3+Atot_vm3;
						all_vm4 = stot_vm4+Atot_vm4;
						all_vm5 = stot_vm5+Atot_vm5;
						all_vm6 = stot_vm6+Atot_vm6;
						all_vm7 = stot_vm7+Atot_vm7;
						all_vm8 = stot_vm8+Atot_vm8;
						all_vm9 = stot_vm9+Atot_vm9;
						all_vm10 = stot_vm10+Atot_vm10;
						all_vm11 = stot_vm11+Atot_vm11;
						all_vm12 = stot_vm12+Atot_vm12;
						all_vsm1 = stot_vsm1+Atot_vsm1;
						all_vsm2 = stot_vsm2+Atot_vsm2;
						all_vm13 = stot_vm13+Atot_vm13;
					//  -----------------  TOTAL  Percent   ---------------
							all_actper = 0;
							all_budper = 0;						 
							if (z_net_ytd == 0) {
									all_actper = 0;
									all_budper = 0;
							} else {
									all_budper = (all_vm13 / z_net_ytd) * 100;	//  %  Budget		 
									all_actper = (all_m13 / z_net_ytd) * 100;		//  %  Actual
							}
%>
	<tr class="specH1">
      <td width="270px" class="col_name1">รวมทุกบัญชี</td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_vm1)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_m1)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_vm2)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_m2)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_vm3)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_m3)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_vm4)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_m4)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_vm5)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_m5)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_vm6)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_m6)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_vm7)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_m7)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_vm8)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_m8)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_vm9)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_m9)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_vm10)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_m10)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_vm11)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_m11)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_vm12)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_m12)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_vsm1)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_sm1)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_vsm2)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_sm2)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_vm13)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_m13)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_budper)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("###,###.0", all_actper)%></td>
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
            <td class="act_tab4"><a href="javascript:history.back()"><img border="0" src="images/bu_back.gif" width="50" height="15"></a><a href="EIS_Indirect01.jsp"><img border="0" src="images/bu_home.gif" width="50" height="15"></a></td>  
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
	System.out.println("!!!ERROR EIS_ExpenceMonth.jsp : " + e.getMessage());
	System.out.println("!!!ERROR EIS_ExpenceMonth.jsp SQL : " + sql.toString());
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