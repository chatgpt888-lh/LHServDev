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
<%@ page import="serv.common.User"%>
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
<HTML>

<HEAD>
<TITLE>รายงานต้นทุนทางอ้อม / ค่าใช้จ่าย</TITLE>

<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="EIS_MainStyle.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<base target="_self">

</HEAD>

<BODY leftMargin=10 topMargin=5 marginwidth="10" marginheight="5">
<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "EIS_ServProjExpenceMnt.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

String Who = user.getUserWho();
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
int Byear = 0, Eyear = 0;
double b_m1 = 0,b_m2 = 0,b_m3 = 0,b_m4 = 0,b_m5 = 0,b_m6 = 0,b_m7 = 0,b_m8 = 0,b_m9 = 0,b_m10 = 0,b_m11 = 0,b_m12 = 0,b_m13 = 0,b_sm1 = 0,b_sm2 = 0;
double v_m1 = 0,v_m2 = 0,v_m3 = 0,v_m4 = 0,v_m5 = 0,v_m6 = 0,v_m7 = 0,v_m8 = 0,v_m9 = 0,v_m10 = 0,v_m11 = 0,v_m12 = 0,v_m13 = 0,v_sm1 = 0,v_sm2 = 0;
double tot_m1 = 0, tot_m2 = 0, tot_m3 = 0, tot_m4 = 0, tot_m5 = 0, tot_m6 = 0, tot_m7 = 0, tot_m8 = 0, tot_m9 = 0, tot_m10 = 0,tot_m11 = 0, tot_m12 = 0, tot_m13 = 0, tot_sm1 = 0, tot_sm2 = 0;
double tot_vm1 = 0, tot_vm2 = 0, tot_vm3 = 0, tot_vm4 = 0, tot_vm5 = 0,tot_vm6 = 0, tot_vm7 = 0, tot_vm8 = 0, tot_vm9 = 0, tot_vm10 = 0, tot_vm11 = 0, tot_vm12 = 0, tot_vm13 = 0, tot_vsm1 = 0, tot_vsm2 = 0;
double i_tot_m1 = 0, i_tot_m2 = 0, i_tot_m3 = 0, i_tot_m4 = 0, i_tot_m5 = 0, i_tot_m6 = 0, i_tot_m7 = 0, i_tot_m8 = 0, i_tot_m9 = 0, i_tot_m10 = 0,i_tot_m11 = 0, i_tot_m12 = 0, i_tot_m13 = 0, i_tot_sm1 = 0, i_tot_sm2 = 0;
double i_tot_vm1 = 0, i_tot_vm2 = 0, i_tot_vm3 = 0, i_tot_vm4 = 0, i_tot_vm5 = 0,i_tot_vm6 = 0, i_tot_vm7 = 0, i_tot_vm8 = 0, i_tot_vm9 = 0, i_tot_vm10 = 0, i_tot_vm11 = 0, i_tot_vm12 = 0, i_tot_vm13 = 0, i_tot_vsm1 = 0, i_tot_vsm2 = 0;
double sum_tot1 = 0,sum_tot2 = 0,sum_tot3 = 0,sum_tot4 = 0,sum_tot5 = 0,sum_tot6 = 0,sum_tot7 = 0,sum_tot8 = 0,sum_tot9 = 0,sum_tot10 = 0,sum_tot11 = 0,sum_tot12 = 0,sum_tot13 = 0,sum_tot14 = 0,sum_tot15 = 0;
double bsum_tot1 = 0,bsum_tot2 = 0,bsum_tot3 = 0,bsum_tot4 = 0,bsum_tot5 = 0,bsum_tot6 = 0,bsum_tot7 = 0,bsum_tot8 = 0,bsum_tot9 = 0,bsum_tot10 = 0,bsum_tot11 = 0,bsum_tot12 = 0,bsum_tot13 = 0,bsum_tot14 = 0,bsum_tot15 = 0;
double z_net_ytd = 0,a_per1 = 0,b_per1 = 0;
double tot_oldyear = 0, tot_nowyear = 0, tot_allyear = 0;



double Aper_all = 0, Bper_all = 0;
double Atpec_m1 = 0, Atpec_m2 = 0, Atpec_m3 = 0, Atpec_m4 = 0, Atpec_m5 = 0, Atpec_m6 = 0;
double Atpec_m7 = 0, Atpec_m8 = 0, Atpec_m9 = 0, Atpec_m10 = 0, Atpec_m11 = 0, Atpec_m12 = 0;
double Atpec_m13 = 0, Atpec_sm1 = 0, Atpec_sm2 = 0;
double Btpec_m1 = 0, Btpec_m2 = 0, Btpec_m3 = 0, Btpec_m4 = 0, Btpec_m5 = 0, Btpec_m6 = 0;
double Btpec_m7 = 0, Btpec_m8 = 0, Btpec_m9 = 0, Btpec_m10 = 0, Btpec_m11 = 0, Btpec_m12 = 0;
double Btpec_m13 = 0, Btpec_sm1 = 0, Btpec_sm2 = 0;
double t9 = 0;
double old_year = 0, now_year = 0, tot_cost = 0, tot_cost2 = 0;

String sum_detail = "", Bsum_detail = "", type_id = "", btype_id = "", sum_total = "";
String i_com = "",i_proj = "", acct_desc = "", chk_link = "", monthly = "", acct_name = "";
//String project = "-";
/*if (request.getParameter("project") != null) {
	project = doString.checkString(request.getParameter("project"),"-");
}*/
String project = doString.checkString(request.getParameter("project"),"-");

//out.println("project="+project);
if (!project.equals("-")) {
	i_com = request.getParameter("project").substring(0,2);
	i_proj = request.getParameter("project").substring(2,5);
}



String typecost = "A";  
if (request.getParameter("typecost") != null) {
	typecost = doString.checkString(request.getParameter("typecost"));
}
String year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
if (request.getParameter("year") != null) {
	year = request.getParameter("year");
}
String dept = "";
if (request.getParameter("dept") != null) {
	dept = doString.checkString(request.getParameter("dept"));
}
String display = "";
/*if (Who.equals("A")) {
	dept = "";
	display = "";
} else {
	display = "disabled";	
	dept = "03";
}*/

if (!Who.equals("A")) { 
	display = "disabled";	
	dept = "03";
}



%>
<FORM NAME="frmEIS" METHOD=POST ACTION="EIS_ServProjExpenceMnt.jsp">


  <br style="font-size:5pt">  
  
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            รายงานต้นทุนทางอ้อม / ค่าใช้จ่าย แยกรายเดือน</td>
        </tr>
      </table>

<br style="font-size:8pt">

	<table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="300">โปรดระบุรายละเอียด</td>
                <td class="item_tab3"></td>
                <td class="item_tab4">&nbsp;</td>
                <td class="item_tab5"></td>
              </tr>
            </table>
      <br style="font-size:5pt">
  <table border="0" width="100%" cellspacing="1" cellpadding="0">
    <tr>
      <td width="10%" class="item : 10pt" height="28">โครงการ : </td>
      <td width="30%" height="28">&nbsp;<SELECT size="1" name="project" class="box" style="width:250px">
	  <!--<OPTION value="ALL">--------------- ทุกโครงการ ---------------</OPTION>  -->
<%
String option = "";

if(user.getUserWho().equals("T") || user.getUserWho().equals("C") || user.getUserWho().equals("A") || user.getUserID().equals("piyapong")) { 
	    
			sql.delete(0, sql.length());
			sql.append("select distinct b.i_company, b.i_project, b.n_project ")
				.append("from lan:acsbudgh a, lan:acxprojt b ")
				.append("where a.d_year in ("+Integer.parseInt(year)+") ")
				.append("and a.i_budg_type in ('1','2','9') ")
				.append("and a.i_company = b.i_company ")
				.append("and a.i_project = b.i_project ")
				.append("order by 1,2,3 ");
} else {

		   sql.delete(0, sql.length());
		   sql.append("select distinct b.i_company, b.i_project, b.n_project ")
				.append("from lan:serv_pstaff a, lan:acxprojt b ") 
				.append("where a.user_id = '"+user.getUserID()+"' ")
				.append("and a.com_id = b.i_company ")
				.append("and a.proj_id = b.i_project ") 
				.append("order by 1,2,3 ");
}
			System.out.println("query=="+sql.toString());

			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());

			servlog.endLog();
			while (rs.next()) {
			option = "";
				if (project.equals(doString.checkString(rs.getString("i_company"))+doString.checkString(rs.getString("i_project")))) {
					option = " Selected ";
				} // End if

%>
			<OPTION value="<%=doString.checkString(rs.getString("i_company"))+doString.checkString(rs.getString("i_project"))%>" <%=option%>>
			<%=doString.checkString(rs.getString("i_company"))+"-"+doString.checkString(rs.getString("i_project"))+"&nbsp;&nbsp;"+doString.DisplayThai(doString.checkString(rs.getString("n_project")))%>
			</OPTION>
<%			
		} // End while
%></SELECT></td>
	  <td width="10%" class="item : 10pt" height="28">ประจำปี : </td>
      <td width="50%" height="28"><SELECT size="1" name="year" class="box" style="width:80px"> 
	  <%	 
		Byear = Integer.parseInt(year) - 5;
		Eyear = Integer.parseInt(year) + 5;
		for(int i = Byear;  i <= Eyear;  i++ ){
			option = "";
			if (i == Integer.parseInt(year)) {
				option = " Selected ";
			}		
%> 
                  <OPTION value="<%=i%>" <%=option%>><%=i%></OPTION>
<%
		} // End for
%> 
		</SELECT></td>
    </tr>
     <tr>
      <td width="10%" class="item : 10pt" height="28" bgcolor="#F6F6F6">ประเภทค่าใช้จ่าย : </td>
      <td width="30%" height="28" bgcolor="#F6F6F6">&nbsp;<select size="1" name="typecost" class="box" style="width:180px">
              <option value="A" <% if (typecost.equals("A")) { out.print("Selected"); } %>>โครงการ</option>
              <option value="B" <% if (typecost.equals("B")) { out.print("Selected"); } %>>ปันส่วนจากกลุ่ม</option>
              <option value="C" <% if (typecost.equals("C")) { out.print("Selected"); } %>>ส่วนกลาง</option>
              <option value="D" <% if (typecost.equals("D")) { out.print("Selected"); } %>>โครงการ+ปันส่วนจากกลุ่ม</option>
              <option value="E" <% if (typecost.equals("E")) { out.print("Selected"); } %>>ทั้งหมด</option>
            </select></td>

<td width="10%" class="item : 10pt" height="28" bgcolor="#F6F6F6">ค่าใช้จ่ายฝ่าย/กลุ่ม :</td>
      <td width="50%" height="28" bgcolor="#F6F6F6">&nbsp;<SELECT size="1" name="dept" class="box" style="width:80px" <%=display%>> 
                  <OPTION value="03"<% if (dept.equals("03")) { out.print("Selected"); } %>>บริการ</OPTION> 
                  <OPTION value="02"<% if (dept.equals("02")) { out.print("Selected"); } %>>PJ</OPTION> 
                  <OPTION value="01"<% if (dept.equals("01")) { out.print("Selected"); } %>>PM / VP</OPTION>
</SELECT>&nbsp;&nbsp;&nbsp;&nbsp;<A HREF="javascript:frmEIS.submit();"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></A></td>
</tr>
  </table>
  <br style="font-size:5pt">  

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
%> 
  <table border="0" width="1870px" cellspacing="1" cellpadding="0" class="TBLine">
  <tr>
      <td width="270px" class="col_name1" rowspan="3"><a href="#">Description ( พันบาท )</a></td>
      <td class="col_name1" colspan="32">ปี <%=Integer.parseInt(year)%>&nbsp;&nbsp;หน่วย : พันบาท</td>      
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
<tr class="col_right ; specH1">
  <td width="270px" class="col_name1"><B>ค่าใช้จ่าย</B></td>
  <td width="50px" class="col_name1" colspan=32>&nbsp;</td>
</tr>
<%
/*
		n_type = "ค่าใช้จ่าย";
		tb_name = "lan:acbexpsm";
		Btb_name = "lan:acbexpbg";
		f_type = "5";
		type_no = "5-ser";  // service dept		
		code_no = "110";
		*/
	
if (!typecost.equals("C")) {	 //  typecost not equals 'C'

			acct_desc = "";
				//------------------------- MAIN ACCTNO ------------------------
				sql.delete(0, sql.length());
				sql.append("select distinct a.i_acctno, b.acct_desc ") 
					.append("from lan:acbexpdp a, lan:stxchrtr b ")
					.append("where a.i_type = 'EXP' ") 
					.append("and a.i_acctno = b.acct_no ")	
				    .append("and i_dep = '"+dept+"' ")
					.append("order by a.i_acctno");				
				rs = stmt.executeQuery(sql.toString());
				while (rs.next()) {
						acct_desc = doString.DisplayThai(doString.checkString(rs.getString("acct_desc")));
							
							   chk_link = "";
							   sql.delete(0, sql.length());
							   sql.append("select rod_acct_no from lan:stgrow2d ")
									.append("where rod_profile_id = 'EISEXP' ")
									.append("and rod_acct_no = '"+doString.checkString(rs.getString("i_acctno"))+"' ");
							   rs1 = stmt1.executeQuery(sql.toString());
							   if (rs1.next()==true) {
									chk_link= "Y";
							   }

								b_m1 = 0; b_m2 = 0;b_m3 = 0;b_m4 = 0;b_m5 = 0;b_m6 = 0;b_m7 = 0;b_m8 = 0;b_m9 = 0;b_m10 = 0;b_m11 = 0;b_m12 = 0;b_m13 = 0;b_sm1 = 0;b_sm2 = 0;
								v_m1 = 0; v_m2 = 0;v_m3 = 0;v_m4 = 0;v_m5 = 0;v_m6 = 0;v_m7 = 0;v_m8 = 0;v_m9 = 0;v_m10 = 0;v_m11 = 0;v_m12 = 0;v_m13 = 0;v_sm1 = 0;v_sm2 = 0;

							 //----------------------  ACTUAL -------------------------------
/* SELECT DISTINCT i_company, i_project
FROM lan:acbexpsm a
WHERE NOT EXISTS (
    SELECT 1 
    FROM lan:serv_local v
    WHERE v.i_company = a.i_company
      AND v.i_project = a.i_project)
	  */
							 
							   sql.delete(0, sql.length());
							   sql.append("select "+sum_detail+" from lan:acbexpsm ") 
									.append("where i_year = '"+year+"' ")                                  
									.append("and i_company = '"+i_com+"' ")                                        
									.append("and i_project = '"+i_proj+"' ")                  
									.append("and i_acctno != 'TOTAL' ")
									.append("and i_type "+type_id+" ")       							
								    .append("and i_acctno = '"+doString.DisplayThai(doString.checkString(rs.getString("i_acctno")))+"' ");							
								rs1 = stmt1.executeQuery(sql.toString());
								if (rs1.next()==true) {

										b_m1 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m1")/1000));
										b_m2 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m2")/1000));
										b_m3 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m3")/1000));
										b_m4 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m4")/1000));
										b_m5 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m5")/1000));
										b_m6 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m6")/1000));
										b_m7 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m7")/1000));
										b_m8 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m8")/1000));
										//b_m9 = rs1.getDouble("m9")/1000;
										b_m9 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m9")/1000));
										b_m10 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m10")/1000));
										b_m11 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m11")/1000));
										b_m12 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m12")/1000));
										b_m13 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m13")/1000));
										b_sm1= Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("sm1")/1000));
										b_sm2 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("sm2")/1000));  				
										
							} // end if rs1	

							  //----------------------  BUDGET -------------------------------							
								   sql.delete(0, sql.length());
								   sql.append("select "+Bsum_detail+", i_acctno from lan:acbexpbg ") 
										.append("where i_year = '"+year+"' ")                                  
										.append("and i_company = '"+i_com+"' ")                                        
										.append("and i_project = '"+i_proj+"' ")                  
										.append("and i_acctno != 'TOTAL' ")
										.append("and i_acctno = '"+doString.DisplayThai(doString.checkString(rs.getString("i_acctno")))+"' ")
										.append("and i_type "+btype_id+" ");                          
									
									rs1 = stmt1.executeQuery(sql.toString());

									if (rs1.next()) {															
											v_m1 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m1")/1000));											
											v_m2 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m2")/1000));
											v_m3 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m3")/1000));
											v_m4 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m4")/1000));
											v_m5 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m5")/1000));
											v_m6 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m6")/1000));
											v_m7 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m7")/1000));
											v_m8 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m8")/1000));
											v_m9 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m9")/1000));
											v_m10 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m10")/1000));
											v_m11= Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m11")/1000));
											v_m12 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m12")/1000));
											v_m13 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m13")/1000));
											v_sm1= Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("sm1")/1000));
											v_sm2 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("sm2")/1000));
								} // end if rs1	  

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
      <td width="270px" class="col_left ; item" style="font-size:8pt"><%=doString.checkString(rs.getString("i_acctno"))%>-<%=acct_desc%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m1)%></td>
      <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=01&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m1)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m2)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=02&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m2)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m3)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=03&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m3)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m4)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=04&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m4)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m5)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=05&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m5)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m6)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=06&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m6)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m7)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=07&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m7)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m8)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=08&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m8)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m9)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=09&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m9)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m10)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=10&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m10)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m11)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=11&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m11)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m12)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=12&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m12)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_sm1)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=Q1&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_sm1)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_sm2)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=Q2&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_sm2)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m13)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=ALL&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m13)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", a_per1)%></td>
      <td width="50px"><%=doString.displayNumber("###,###.0", b_per1)%></td>
    </tr>
<%
			  //-------Total Actual -----						
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
				tot_m13 += b_m13;	
				tot_sm1 += b_sm1;
				tot_sm2 += b_sm2;	
				
			 //--------Total Budget -----
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
	} // end  while rs

} // end if typecost not equals  C

if (typecost.equals("C") || typecost.equals("E")) {
				b_m1 = 0; b_m2 = 0;b_m3 = 0;b_m4 = 0;b_m5 = 0;b_m6 = 0;b_m7 = 0;b_m8 = 0;b_m9 = 0;b_m10 = 0;b_m11 = 0;b_m12 = 0;b_m13 = 0;b_sm1 = 0;b_sm2 = 0;
				 v_m1 = 0; v_m2 = 0;v_m3 = 0;v_m4 = 0;v_m5 = 0;v_m6 = 0;v_m7 = 0;v_m8 = 0;v_m9 = 0;v_m10 = 0;v_m11 = 0;v_m12 = 0;v_m13 = 0;v_sm1 = 0;v_sm2 = 0;

				  //----------------------  ACTUAL -----------------------------
				   sql.delete(0, sql.length());
				   sql.append("select "+sum_detail+", i_acctno from lan:acbexpsm ") 
						.append("where i_year = '"+year+"' ")                                  
						.append("and i_company = '"+i_com+"' ")                                        
						.append("and i_project = '"+i_proj+"' ")                  
						.append("and i_acctno = 'TOTAL' ")
						.append("and i_acctno not in (select a.i_acctno from acbstdep a where a.i_type = '5-ser' and a.i_acctno = i_acctno) ")  
						.append("and i_type = '3' ");

				    rs1 = stmt1.executeQuery(sql.toString());

					if (rs1.next()==true) {		

							/*b_m1 = rs1.getDouble("m1")/1000;
							b_m2 = rs1.getDouble("m2")/1000;
							b_m3 = rs1.getDouble("m3")/1000;
							b_m4 = rs1.getDouble("m4")/1000;
							b_m5 = rs1.getDouble("m5")/1000;
							b_m6 = rs1.getDouble("m6")/1000;
							b_m7 = rs1.getDouble("m7")/1000;
							b_m8 = rs1.getDouble("m8")/1000;
							//b_m9 = rs1.getDouble("m9")/1000;
							b_m9 = Double.parseDouble(doString.displayNumber("#,##0.0", rs1.getDouble("m9")/1000));		
							b_m10 = rs1.getDouble("m10")/1000;
							b_m11 = rs1.getDouble("m11")/1000;
							b_m12 = rs1.getDouble("m12")/1000;
							b_m13 = rs1.getDouble("m13")/1000;
							b_sm1= rs1.getDouble("sm1")/1000;
							b_sm2 = rs1.getDouble("sm2")/1000;  	*/

							b_m1 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m1")/1000));
							b_m2 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m2")/1000));
							b_m3 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m3")/1000));
							b_m4 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m4")/1000));
							b_m5 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m5")/1000));
							b_m6 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m6")/1000));
							b_m7 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m7")/1000));
							b_m8 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m8")/1000));						
							b_m9 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m9")/1000));
							b_m10 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m10")/1000));
							b_m11 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m11")/1000));
							b_m12 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m12")/1000));
							b_m13 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m13")/1000));
							b_sm1= Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("sm1")/1000));
							b_sm2 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("sm2")/1000));  				
						
					} // end if

				     //----------------------  BUDGET -----------------------------
					   sql.delete(0, sql.length());
					   sql.append("select z_amount, month(d_cash) as mnt_cash ")                                                     
							.append("from lan:acbcasfd ")                                                               
							.append("where i_bud_type = '1' ")                                                          
							.append("and i_code = '110' ")                                                              
							.append("and i_detail = '002' ")                                                            
							.append("and year(d_cash) = '"+(Integer.parseInt(year)-543)+"' ")                                  
							.append("and i_company = '"+i_com+"' ")                                                            
							.append("and i_project = '"+i_proj+"' ")                                                            
							.append("order by 2,1");      					    
					    rs = stmt.executeQuery(sql.toString());
						while (rs.next()==true) {	
								/*v_m1 = rs1.getDouble("m1")/1000;
								v_m2 = rs1.getDouble("m2")/1000;
								v_m3 = rs1.getDouble("m3")/1000;
								v_m4 = rs1.getDouble("m4")/1000;
								v_m5 = rs1.getDouble("m5")/1000;
								v_m6 = rs1.getDouble("m6")/1000;
								v_m7 = rs1.getDouble("m7")/1000;
								v_m8 = rs1.getDouble("m8")/1000;
								v_m9 = rs1.getDouble("m9")/1000;
								v_m10 = rs1.getDouble("m10")/1000;
								v_m11= rs1.getDouble("m11")/1000;
								v_m12 = rs1.getDouble("m12")/1000;
								v_m13 = rs1.getDouble("m13")/1000;
								v_sm1= rs1.getDouble("sm1")/1000;
								v_sm2 = rs1.getDouble("sm2")/1000; */


								if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("1")) {
										//v_m1 = rs.getDouble("z_amount")/1000;		
										v_m1 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("2")) {
										v_m2 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));	
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("3")) {
										v_m3 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("4")) {
										v_m4 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));	
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("5")) {
										v_m5 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));	
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("6")) {
										v_m6 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("7")) {
										v_m7 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("8")) {
										v_m8 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("9")) {
										v_m9 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));	
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("10")) {
										v_m10 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));	
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("11")) {
										v_m11 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("12")) {
										v_m12 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));
								} 

											v_sm1 = v_m1+v_m2+v_m3+v_m4+v_m5+v_m6;
											v_sm2 = v_m7+v_m8+v_m9+v_m10+v_m11+v_m12;
											v_m13 = v_sm1+v_sm2;
						} // end while
											 
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
      <td width="270px" class="col_left ; item" style="font-size:8pt">ส่วนกลาง TOTAL - รวมรหัสบัญชี</td>
	 <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m1)%></td>
      <td width="50px"><%=doString.displayNumber("#,##0.0", b_m1)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m2)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m2)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m3)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m3)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m4)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m4)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m5)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m5)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m6)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m6)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m7)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m7)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m8)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m8)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m9)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m9)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m10)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m10)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m11)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m11)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m12)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m12)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_sm1)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_sm1)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_sm2)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_sm2)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m13)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m13)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", a_per1)%></td>
      <td width="50px"><%=doString.displayNumber("#,##0.0", b_per1)%></td>
    </tr>
<%
	//-------Total Actual -----						
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
				tot_m13 += b_m13;	
				tot_sm1 += b_sm1;
				tot_sm2 += b_sm2;	
				
			 //--------Total Budget -----
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


		} // end if typecost = C, E			
%>
<tr class="specH1">
      <td width="270px" class="col_name1">รวมทุกบัญชี</td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_vm1)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_m1)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_vm2)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_m2)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_vm3)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_m3)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_vm4)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_m4)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_vm5)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_m5)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_vm6)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_m6)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_vm7)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_m7)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_vm8)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_m8)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_vm9)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_m9)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_vm10)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_m10)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_vm11)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_m11)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_vm12)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_m12)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_vsm1)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_sm1)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_vsm2)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_sm2)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_vm13)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", tot_m13)%></td>
	
	  <td width="50px" class="col_name1r">-</td>
      <td width="50px" class="col_name1r">-</td>
    </tr>


    
   


  <tr class="col_left ; specH1">
  <td width="270px" class="col_name1" align="left">ต้นทุนทางอ้อม</td>
  <td width="50px" class="col_name1" colspan=32>&nbsp;</td>
  </tr>
<%
		/*n_type = "ต้นทุนทางอ้อม";
		tb_name = "lan:acbidrsm";
		Btb_name = "lan:acbidrbg";
		f_type = "idirec";
		type_no = "idr-se";   // service dept		
		code_no = "105"; */

if (!typecost.equals("C")) {	 //  typecost not equals 'C'
			
			acct_desc = "";
				//------------------------- MAIN ACCTNO ------------------------
				sql.delete(0, sql.length());
				sql.append("select distinct a.i_acctno, b.acct_desc ") 
					.append("from lan:acbexpdp a, lan:stxchrtr b ")
					.append("where a.i_type = 'IDR' ") 
					.append("and a.i_acctno = b.acct_no ")	
				    .append("and i_dep = '"+dept+"' ")
					.append("order by a.i_acctno");				
				rs = stmt.executeQuery(sql.toString());
				while (rs.next()) {
						acct_desc = doString.DisplayThai(doString.checkString(rs.getString("acct_desc")));

							if (doString.checkString(rs.getString("i_acctno")).equals("54010") || doString.checkString(rs.getString("i_acctno")).equals("54011") || doString.checkString(rs.getString("i_acctno")).equals("54012")) {
									monthly = "(monthly)";
							} else {
									monthly = "";
							}								

							   chk_link = "";
							   sql.delete(0, sql.length());
							   sql.append("select rod_acct_no from lan:stgrow2d ")
									.append("where rod_profile_id = 'EISEXP' ")
									.append("and rod_acct_no = '"+doString.checkString(rs.getString("i_acctno"))+"' ");
							   rs1 = stmt1.executeQuery(sql.toString());
							   if (rs1.next()==true) {
									chk_link= "Y";
							   }

							 b_m1 = 0; b_m2 = 0;b_m3 = 0;b_m4 = 0;b_m5 = 0;b_m6 = 0;b_m7 = 0;b_m8 = 0;b_m9 = 0;b_m10 = 0;b_m11 = 0;b_m12 = 0;b_m13 = 0;b_sm1 = 0;b_sm2 = 0;
							 v_m1 = 0; v_m2 = 0;v_m3 = 0;v_m4 = 0;v_m5 = 0;v_m6 = 0;v_m7 = 0;v_m8 = 0;v_m9 = 0;v_m10 = 0;v_m11 = 0;v_m12 = 0;v_m13 = 0;v_sm1 = 0;v_sm2 = 0;

							 //----------------------  ACTUAL -------------------------------
							   sql.delete(0, sql.length());
							   sql.append("select "+sum_detail+" from lan:acbidrsm ") 
									.append("where i_year = '"+year+"' ")                                  
									.append("and i_company = '"+i_com+"' ")                                        
									.append("and i_project = '"+i_proj+"' ")                  
									.append("and i_acctno != 'TOTAL' ")
									.append("and i_type "+type_id+" ")       							
								    .append("and i_acctno = '"+doString.DisplayThai(doString.checkString(rs.getString("i_acctno")))+"' ");								
								rs1 = stmt1.executeQuery(sql.toString());
								if (rs1.next()==true) {

									b_m1 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m1")/1000));
									b_m2 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m2")/1000));
									b_m3 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m3")/1000));
									b_m4 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m4")/1000));
									b_m5 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m5")/1000));
									b_m6 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m6")/1000));
									b_m7 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m7")/1000));
									b_m8 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m8")/1000));						
									b_m9 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m9")/1000));
									b_m10 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m10")/1000));
									b_m11 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m11")/1000));
									b_m12 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m12")/1000));
									b_m13 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m13")/1000));
									b_sm1= Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("sm1")/1000));
									b_sm2 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("sm2")/1000));  			
									
							} // end if rs1	

							  //----------------------  BUDGET -------------------------------							
								   sql.delete(0, sql.length());
								   sql.append("select "+Bsum_detail+", i_acctno from lan:acbidrbg ") 
										.append("where i_year = '"+year+"' ")                                  
										.append("and i_company = '"+i_com+"' ")                                        
										.append("and i_project = '"+i_proj+"' ")                  
										.append("and i_acctno != 'TOTAL' ")
										.append("and i_acctno = '"+doString.DisplayThai(doString.checkString(rs.getString("i_acctno")))+"' ")
										.append("and i_type "+btype_id+" ");                          
									
									rs1 = stmt1.executeQuery(sql.toString());
									
									if (rs1.next()) {															
											v_m1 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m1")/1000));											
											v_m2 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m2")/1000));
											v_m3 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m3")/1000));
											v_m4 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m4")/1000));
											v_m5 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m5")/1000));
											v_m6 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m6")/1000));
											v_m7 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m7")/1000));
											v_m8 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m8")/1000));
											v_m9 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m9")/1000));
											v_m10 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m10")/1000));
											v_m11= Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m11")/1000));
											v_m12 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m12")/1000));
											v_m13 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m13")/1000));
											v_sm1= Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("sm1")/1000));
											v_sm2 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("sm2")/1000));
								} // end if rs1	  

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
      <td width="270px" class="col_left ; item" style="font-size:8pt"><%=doString.checkString(rs.getString("i_acctno"))%>-<%=acct_desc%>&nbsp;&nbsp;<FONT COLOR="#9430D6"><%=monthly%></FONT></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m1)%></td>
      <td width="50px"><% if (chk_link.equals("Y") && !monthly.equals("(monthly)")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=01&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m1)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m2)%></td>
	  <td width="50px"><% if (chk_link.equals("Y") && !monthly.equals("(monthly)")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=02&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m2)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m3)%></td>
	  <td width="50px"><% if (chk_link.equals("Y") && !monthly.equals("(monthly)")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=03&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m3)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m4)%></td>
	  <td width="50px"><% if (chk_link.equals("Y") && !monthly.equals("(monthly)")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=04&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m4)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m5)%></td>
	  <td width="50px"><% if (chk_link.equals("Y") && !monthly.equals("(monthly)")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=05&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m5)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m6)%></td>
	  <td width="50px"><% if (chk_link.equals("Y") && !monthly.equals("(monthly)")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=06&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m6)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m7)%></td>
	  <td width="50px"><% if (chk_link.equals("Y") && !monthly.equals("(monthly)")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=07&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m7)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m8)%></td>
	  <td width="50px"><% if (chk_link.equals("Y") && !monthly.equals("(monthly)")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=08&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m8)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m9)%></td>
	  <td width="50px"><% if (chk_link.equals("Y") && !monthly.equals("(monthly)")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=09&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m9)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m10)%></td>
	  <td width="50px"><% if (chk_link.equals("Y") && !monthly.equals("(monthly)")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=10&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m10)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m11)%></td>
	  <td width="50px"><% if (chk_link.equals("Y") && !monthly.equals("(monthly)")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=11&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m11)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m12)%></td>
	  <td width="50px"><% if (chk_link.equals("Y") && !monthly.equals("(monthly)")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=12&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m12)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_sm1)%></td>
	  <td width="50px"><% if (chk_link.equals("Y") && !monthly.equals("(monthly)")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=Q1&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_sm1)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_sm2)%></td>
	  <td width="50px"><% if (chk_link.equals("Y") && !monthly.equals("(monthly)")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=Q2&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_sm2)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m13)%></td>
	  <td width="50px"><% if (chk_link.equals("Y") && !monthly.equals("(monthly)")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs.getString("i_acctno"))%>&acct_desc=<%=acct_desc%>&month=ALL&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m13)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", a_per1)%></td>
      <td width="50px"><%=doString.displayNumber("###,###.0", b_per1)%></td>
    </tr>
    
<%
				//-------Total Actual -----						
				i_tot_m1 += b_m1;
				i_tot_m2 += b_m2;
				i_tot_m3 += b_m3;
				i_tot_m4+= b_m4;
				i_tot_m5 += b_m5;
				i_tot_m6 += b_m6;
				i_tot_m7 += b_m7;
				i_tot_m8 += b_m8;
				i_tot_m9 += b_m9;
				i_tot_m10 += b_m10;
				i_tot_m11 += b_m11;
				i_tot_m12 += b_m12;
				i_tot_m13 += b_m13;	
				i_tot_sm1 += b_sm1;
				i_tot_sm2 += b_sm2;	
				
				//--------Total Budget -----
				i_tot_vm1 += v_m1;
				i_tot_vm2 += v_m2;
				i_tot_vm3 += v_m3;
				i_tot_vm4+= v_m4;
				i_tot_vm5 += v_m5;
				i_tot_vm6 += v_m6;
				i_tot_vm7 += v_m7;
				i_tot_vm8 += v_m8;
				i_tot_vm9 += v_m9;
				i_tot_vm10 += v_m10;
				i_tot_vm11 += v_m11;
				i_tot_vm12 += v_m12;
				i_tot_vsm1 += v_sm1;
				i_tot_vsm2 += v_sm2;
				i_tot_vm13 += v_m13;		
	} // end while

} // end if 
if (typecost.equals("C") || typecost.equals("E")) {

		b_m1 = 0; b_m2 = 0;b_m3 = 0;b_m4 = 0;b_m5 = 0;b_m6 = 0;b_m7 = 0;b_m8 = 0;b_m9 = 0;b_m10 = 0;b_m11 = 0;b_m12 = 0;b_m13 = 0;b_sm1 = 0;b_sm2 = 0;
		v_m1 = 0; v_m2 = 0;v_m3 = 0;v_m4 = 0;v_m5 = 0;v_m6 = 0;v_m7 = 0;v_m8 = 0;v_m9 = 0;v_m10 = 0;v_m11 = 0;v_m12 = 0;v_m13 = 0;v_sm1 = 0;v_sm2 = 0;


				  //----------------------  ACTUAL -----------------------------
				   sql.delete(0, sql.length());
				   sql.append("select "+sum_detail+", i_acctno from lan:acbidrsm ")   //acbexpsm
						.append("where i_year = '"+year+"' ")                                  
						.append("and i_company = '"+i_com+"' ")                                        
						.append("and i_project = '"+i_proj+"' ")                  
						.append("and i_acctno = 'TOTAL' ")
						.append("and i_acctno not in (select a.i_acctno from acbstdep a where a.i_type = '5-ser' and a.i_acctno = i_acctno) ")  
						.append("and i_type = '3' ");		
					rs1 = stmt1.executeQuery(sql.toString());					
					if (rs1.next()==true) {		

							b_m1 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m1")/1000));
							b_m2 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m2")/1000));
							b_m3 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m3")/1000));
							b_m4 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m4")/1000));
							b_m5 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m5")/1000));
							b_m6 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m6")/1000));
							b_m7 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m7")/1000));
							b_m8 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m8")/1000));						
							b_m9 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m9")/1000));
							b_m10 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m10")/1000));
							b_m11 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m11")/1000));
							b_m12 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m12")/1000));
							b_m13 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m13")/1000));
							b_sm1= Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("sm1")/1000));
							b_sm2 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("sm2")/1000));  	

						/*	Atpec_m1 = rs.getDouble("m1")/1000;
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
							Atpec_sm2 = rs.getDouble("sm2")/1000;  */
					} // end if

				     //----------------------  BUDGET -----------------------------
					   sql.delete(0, sql.length());
					   sql.append("select z_amount, month(d_cash) as mnt_cash ")                                                     
							.append("from lan:acbcasfd ")                                                               
							.append("where i_bud_type = '1' ")                                                          
							.append("and i_code = '105' ")                                                              
							.append("and i_detail = '002' ")                                                            
							.append("and year(d_cash) = '"+(Integer.parseInt(year)-543)+"' ")                                  
							.append("and i_company = '"+i_com+"' ")                                                            
							.append("and i_project = '"+i_proj+"' ")                                                            
							.append("order by 2,1");  
						rs = stmt.executeQuery(sql.toString());
						while (rs.next()==true) {	
								/*v_m1 = rs1.getDouble("m1")/1000;
								v_m2 = rs1.getDouble("m2")/1000;
								v_m3 = rs1.getDouble("m3")/1000;
								v_m4 = rs1.getDouble("m4")/1000;
								v_m5 = rs1.getDouble("m5")/1000;
								v_m6 = rs1.getDouble("m6")/1000;
								v_m7 = rs1.getDouble("m7")/1000;
								v_m8 = rs1.getDouble("m8")/1000;
								v_m9 = rs1.getDouble("m9")/1000;
								v_m10 = rs1.getDouble("m10")/1000;
								v_m11= rs1.getDouble("m11")/1000;
								v_m12 = rs1.getDouble("m12")/1000;
								v_m13 = rs1.getDouble("m13")/1000;
								v_sm1= rs1.getDouble("sm1")/1000;
								v_sm2 = rs1.getDouble("sm2")/1000; */


								
								if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("1")) {
										//v_m1 = rs.getDouble("z_amount")/1000;		
										v_m1 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("2")) {
										v_m2 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));	
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("3")) {
										v_m3 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("4")) {
										v_m4 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));	
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("5")) {
										v_m5 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));	
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("6")) {
										v_m6 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("7")) {
										v_m7 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("8")) {
										v_m8 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("9")) {
										v_m9 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));	
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("10")) {
										v_m10 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));	
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("11")) {
										v_m11 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));
								} else if (doString.checkString(doString.DisplayThai(rs.getString("mnt_cash"))).equals("12")) {
										v_m12 = Double.parseDouble(doString.displayNumber("###0.0", rs.getDouble("z_amount")/1000));
								} 
											v_sm1 = v_m1+v_m2+v_m3+v_m4+v_m5+v_m6;
											v_sm2 = v_m7+v_m8+v_m9+v_m10+v_m11+v_m12;
											v_m13 = v_sm1+v_sm2;
						} // end while
											 
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
     <td width="270px" class="col_left ; item" style="font-size:8pt">ส่วนกลาง TOTAL - รวมรหัสบัญชี</td>
	 <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m1)%></td>
      <td width="50px"><%=doString.displayNumber("#,##0.0", b_m1)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m2)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m2)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m3)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m3)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m4)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m4)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m5)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m5)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m6)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m6)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m7)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m7)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m8)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m8)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m9)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m9)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m10)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m10)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m11)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m11)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m12)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m12)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_sm1)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_sm1)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_sm2)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_sm2)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", v_m13)%></td>
	  <td width="50px"><%=doString.displayNumber("#,##0.0", b_m13)%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("#,##0.0", a_per1)%></td>
      <td width="50px"><%=doString.displayNumber("#,##0.0", b_per1)%></td>
    </tr>
<%
//	out.println("b_m9=="+Double.parseDouble(doString.displayNumber("#,##0.0", b_m9)));



		//-------Total Actual -----						
				i_tot_m1 += b_m1;   
				i_tot_m2 += b_m2;
				i_tot_m3 += b_m3;
				i_tot_m4+= b_m4;
				i_tot_m5 += b_m5;
				i_tot_m6 += b_m6;
				i_tot_m7 += b_m7;
				i_tot_m8 += b_m8;
				i_tot_m9 += b_m9;		
				i_tot_m10 += b_m10;
				i_tot_m11 += b_m11;
				i_tot_m12 += b_m12;
				i_tot_m13 += b_m13;	
				i_tot_sm1 += b_sm1;
				i_tot_sm2 += b_sm2;	
				
				//--------Total Budget -----
				i_tot_vm1 += v_m1;
				i_tot_vm2 += v_m2;
				i_tot_vm3 += v_m3;
				i_tot_vm4+= v_m4;
				i_tot_vm5 += v_m5;
				i_tot_vm6 += v_m6;
				i_tot_vm7 += v_m7;
				i_tot_vm8 += v_m8;
				i_tot_vm9 += v_m9;
				i_tot_vm10 += v_m10;
				i_tot_vm11 += v_m11;
				i_tot_vm12 += v_m12;
				i_tot_vsm1 += v_sm1;
				i_tot_vsm2 += v_sm2;
				i_tot_vm13 += v_m13;		

} // end if typecost = C, E		


%>   
	<tr class="specH1">
      <td width="270px" class="col_name1">รวมทุกบัญชี</td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm1)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m1)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm2)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m2)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm3)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m3)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm4)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m4)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm5)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m5)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm6)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m6)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm7)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m7)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm8)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m8)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm9)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m9)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm10)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m10)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm11)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m11)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm12)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m12)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vsm1)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_sm1)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vsm2)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_sm2)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm13)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m13)%></td>
	  <td width="50px" class="col_name1r">-</td>
      <td width="50px" class="col_name1r">-</td>
    </tr>	
<%
				//-------SUM TOTAL ACTUAL ----------
				sum_tot1 = i_tot_m1 + tot_m1;
				sum_tot2 = i_tot_m2 + tot_m2;
				sum_tot3 = i_tot_m3 + tot_m3;
				sum_tot4 = i_tot_m4+ tot_m4;
				sum_tot5 = i_tot_m5 + tot_m5;
				sum_tot6 = i_tot_m6 + tot_m6;
				sum_tot7 = i_tot_m7 + tot_m7;
				sum_tot8 = i_tot_m8 + tot_m8;
				sum_tot9 = i_tot_m9 + tot_m9;
				sum_tot10 = i_tot_m10 + tot_m10;
				sum_tot11 = i_tot_m11 + tot_m11;
				sum_tot12 = i_tot_m12 + tot_m12;
				sum_tot13 = i_tot_m13 + tot_m13;	
				sum_tot14 = i_tot_sm1 + tot_sm1;
				sum_tot15 = i_tot_sm2 + tot_sm2;	

				//-------SUM TOTAL BUDGET ----------
				bsum_tot1 = i_tot_vm1 + tot_vm1;
				bsum_tot2 = i_tot_vm2 + tot_vm2;
				bsum_tot3 = i_tot_vm3 + tot_vm3;
				bsum_tot4 = i_tot_vm4+ tot_vm4;
				bsum_tot5 = i_tot_vm5 + tot_vm5;
				bsum_tot6 = i_tot_vm6 + tot_vm6;
				bsum_tot7 = i_tot_vm7 + tot_vm7;
				bsum_tot8 = i_tot_vm8 + tot_vm8;
				bsum_tot9 = i_tot_vm9 + tot_vm9;
				bsum_tot10 = i_tot_vm10 + tot_vm10;
				bsum_tot11 = i_tot_vm11 + tot_vm11;
				bsum_tot12 = i_tot_vm12 + tot_vm12;
				bsum_tot13 = i_tot_vm13 + tot_vm13;
				bsum_tot14 = i_tot_vsm1 + tot_vsm1;
				bsum_tot15 = i_tot_vsm2 + tot_vsm2;			
%>
	<tr class="specH1">
      <td width="270px" class="col_name1">รวมทั้งหมดทุกบัญชี</td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", bsum_tot1)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", sum_tot1)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", bsum_tot2)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", sum_tot2)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", bsum_tot3)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", sum_tot3)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", bsum_tot4)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", sum_tot4)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", bsum_tot5)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", sum_tot5)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", bsum_tot6)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", sum_tot6)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", bsum_tot7)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", sum_tot7)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", bsum_tot8)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", sum_tot8)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", bsum_tot9)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", sum_tot9)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", bsum_tot10)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", sum_tot10)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", bsum_tot11)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", sum_tot11)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", bsum_tot12)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", sum_tot12)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", bsum_tot14)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", sum_tot14)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", bsum_tot15)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", sum_tot15)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", bsum_tot13)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", sum_tot13)%></td>
	  <td width="50px" class="col_name1r">-</td>
      <td width="50px" class="col_name1r">-</td>
    </tr>

  </table>
  <br style="font-size:3pt">



<br style="font-size:8pt">

	<table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="300">ค่าซ่อมก่อนส่งมอบนิติฯ (ดึงเฉพาะ PV)</td>
                <td class="item_tab3"></td>
                <td class="item_tab4">&nbsp;</td>
                <td class="item_tab5"></td>
              </tr>
            </table>
			 <table border="0" width="1870px" cellspacing="1" cellpadding="0" class="TBLine">
  <tr>
      <td width="270px" class="col_name1" rowspan="3"><a href="#">Description ( พันบาท )</a></td>
      <td class="col_name1" colspan="32">ปี <%=Integer.parseInt(year)%>&nbsp;&nbsp;หน่วย : พันบาท</td>      
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

<tr class="col_right ; specH1">
  <td width="270px" class="col_name1">ต้นทุนทางอ้อม</td>
  <td width="50px" class="col_name1"colspan="32">&nbsp;</td>
</tr>
<%
i_tot_m1 = 0; i_tot_m2 = 0; i_tot_m3 = 0; i_tot_m4 = 0; i_tot_m5 = 0; i_tot_m6 = 0; i_tot_m7 = 0; i_tot_m8 = 0; i_tot_m9 = 0; i_tot_m10 = 0;i_tot_m11 = 0; i_tot_m12 = 0; i_tot_m13 = 0; i_tot_sm1 = 0; i_tot_sm2 = 0;
i_tot_vm1 = 0; i_tot_vm2 = 0; i_tot_vm3 = 0; i_tot_vm4 = 0; i_tot_vm5 = 0;i_tot_vm6 = 0; i_tot_vm7 = 0; i_tot_vm8 = 0; i_tot_vm9 = 0; i_tot_vm10 = 0; i_tot_vm11 = 0; i_tot_vm12 = 0; i_tot_vm13 = 0; i_tot_vsm1 = 0; i_tot_vsm2 = 0;

			//---------------------  BUDGET -------------------------------							
		   sql.delete(0, sql.length());
		   sql.append("select "+Bsum_detail+", i_acctno from lan:acbidrbg ") 
				.append("where i_year = '"+year+"' ")                                  
				.append("and i_company = '"+i_com+"' ")                                        
				.append("and i_project = '"+i_proj+"' ")                  
				.append("and i_acctno in ('54010','54011','54012','52410') ")	
				.append("and i_type = '3' ");			
		 //  out.println(sql.toString());
			rs1 = stmt1.executeQuery(sql.toString());
			while (rs1.next()) {			
				
				b_m1 = 0; b_m2 = 0;b_m3 = 0;b_m4 = 0;b_m5 = 0;b_m6 = 0;b_m7 = 0;b_m8 = 0;b_m9 = 0;b_m10 = 0;b_m11 = 0;b_m12 = 0;b_m13 = 0;b_sm1 = 0;b_sm2 = 0;
				v_m1 = 0; v_m2 = 0;v_m3 = 0;v_m4 = 0;v_m5 = 0;v_m6 = 0;v_m7 = 0;v_m8 = 0;v_m9 = 0;v_m10 = 0;v_m11 = 0;v_m12 = 0;v_m13 = 0;v_sm1 = 0;v_sm2 = 0;


						//-------------------------  ACCT NAME  ------------------------
						acct_name = "";
						sql.delete(0, sql.length());
						sql.append("select acct_desc ") 
							 .append("from lan:stxchrtr ")
							 .append("where acct_no = '"+doString.checkString(rs1.getString("i_acctno"))+"' ");	
						rs2 = stmt2.executeQuery(sql.toString());
						if (rs2.next()) {
								acct_name = doString.DisplayThai(doString.checkString(rs2.getString("acct_desc")));
						}

						   chk_link = "";
							   sql.delete(0, sql.length());
							   sql.append("select rod_acct_no from lan:stgrow2d ")
									.append("where rod_profile_id = 'EISEXP' ")
									.append("and rod_acct_no = '"+doString.checkString(rs1.getString("i_acctno"))+"' ");
							   rs2 = stmt2.executeQuery(sql.toString());
							   if (rs2.next()==true) {
									chk_link= "Y";
							   }


				
					v_m1 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m1")/1000));											
					v_m2 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m2")/1000));
					v_m3 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m3")/1000));
					v_m4 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m4")/1000));
					v_m5 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m5")/1000));
					v_m6 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m6")/1000));
					v_m7 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m7")/1000));
					v_m8 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m8")/1000));
					v_m9 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m9")/1000));
					v_m10 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m10")/1000));
					v_m11= Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m11")/1000));
					v_m12 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m12")/1000));
					v_m13 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("m13")/1000));
					v_sm1= Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("sm1")/1000));
					v_sm2 = Double.parseDouble(doString.displayNumber("###0.0", rs1.getDouble("sm2")/1000));		

					
									  
//---------------- ACTUAL ----------------
/*sql.delete(0, sql.length());
sql.append("select sum(z_amount) from lan:acxgldtl ")
	.append("where comp_id = 'AR' ")
	.append("and department = '031' ")
	.append("and year(doc_date)+543 = '2557' ")
	.append("and month(doc_date) = '01' ")
	.append("and acct_no = '54010' ")
	.append("and orig_journal != 'GJ' ");
out.println(sql.toString());
rs = stmt.executeQuery(sql.toString());
while (rs.next()) {			



 sql.delete(0, sql.length());
		   sql.append("select "+Bsum_detail+", i_acctno from lan:acbidrbg ") 
				.append("where i_year = '"+year+"' ")                                  
				.append("and i_company = '"+i_com+"' ")                                        
				.append("and i_project = '"+i_proj+"' ")                  
				.append("and i_acctno in ('54010','54011','54012') ")	
				.append("and i_type = '3' ");			
		 //  out.println(sql.toString());
			rs1 = stmt1.executeQuery(sql.toString());
			while (rs1.next()) {			*/
				






sql.delete(0, sql.length());
sql.append("select sum(z_amount) as z_amount, month(doc_date) as mnt_cash from lan:acxgldtl ")
	.append("where comp_id = '"+i_com+"' and department = '"+i_proj+"' ")       
	.append("and year(doc_date)+543 = '"+year+"' ")   
	.append("and acct_no = '"+doString.checkString(rs1.getString("i_acctno"))+"' ")
	.append("and orig_journal != 'GJ' ")  
	.append("group by 2 ")
	.append("order by 2 ");
//out.println(sql.toString());
rs2 = stmt2.executeQuery(sql.toString());
while (rs2.next()) {			

								if (doString.checkString(doString.DisplayThai(rs2.getString("mnt_cash"))).equals("1")) {						
										b_m1 = Double.parseDouble(doString.displayNumber("###0.0", rs2.getDouble("z_amount")/1000));
								} else if (doString.checkString(doString.DisplayThai(rs2.getString("mnt_cash"))).equals("2")) {
										b_m2 = Double.parseDouble(doString.displayNumber("###0.0", rs2.getDouble("z_amount")/1000));	
								} else if (doString.checkString(doString.DisplayThai(rs2.getString("mnt_cash"))).equals("3")) {
										b_m3 = Double.parseDouble(doString.displayNumber("###0.0", rs2.getDouble("z_amount")/1000));
								} else if (doString.checkString(doString.DisplayThai(rs2.getString("mnt_cash"))).equals("4")) {
										b_m4 = Double.parseDouble(doString.displayNumber("###0.0", rs2.getDouble("z_amount")/1000));	
								} else if (doString.checkString(doString.DisplayThai(rs2.getString("mnt_cash"))).equals("5")) {
										b_m5 = Double.parseDouble(doString.displayNumber("###0.0", rs2.getDouble("z_amount")/1000));	
								} else if (doString.checkString(doString.DisplayThai(rs2.getString("mnt_cash"))).equals("6")) {
										b_m6 = Double.parseDouble(doString.displayNumber("###0.0", rs2.getDouble("z_amount")/1000));
								} else if (doString.checkString(doString.DisplayThai(rs2.getString("mnt_cash"))).equals("7")) {
										b_m7 = Double.parseDouble(doString.displayNumber("###0.0", rs2.getDouble("z_amount")/1000));
								} else if (doString.checkString(doString.DisplayThai(rs2.getString("mnt_cash"))).equals("8")) {
										b_m8 = Double.parseDouble(doString.displayNumber("###0.0", rs2.getDouble("z_amount")/1000));
								} else if (doString.checkString(doString.DisplayThai(rs2.getString("mnt_cash"))).equals("9")) {
										b_m9 = Double.parseDouble(doString.displayNumber("###0.0", rs2.getDouble("z_amount")/1000));	
								} else if (doString.checkString(doString.DisplayThai(rs2.getString("mnt_cash"))).equals("10")) {
										b_m10 = Double.parseDouble(doString.displayNumber("###0.0", rs2.getDouble("z_amount")/1000));	
								} else if (doString.checkString(doString.DisplayThai(rs2.getString("mnt_cash"))).equals("11")) {
										b_m11 = Double.parseDouble(doString.displayNumber("###0.0", rs2.getDouble("z_amount")/1000));
								} else if (doString.checkString(doString.DisplayThai(rs2.getString("mnt_cash"))).equals("12")) {
										b_m12 = Double.parseDouble(doString.displayNumber("###0.0", rs2.getDouble("z_amount")/1000));
								} 
						
								b_sm1 = b_m1+b_m2+b_m3+b_m4+b_m5+b_m6;
								b_sm2 = b_m7+b_m8+b_m9+b_m10+b_m11+b_m12;
								b_m13 = b_sm1+b_sm2;

} // end while

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
      <td width="270px" class="col_left ; item" style="font-size:8pt"><%=doString.checkString(rs1.getString("i_acctno"))%>-<%=acct_name%></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m1)%></td>
      <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs1.getString("i_acctno"))%>&acct_desc=<%=acct_name%>&month=01&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m1)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m2)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs1.getString("i_acctno"))%>&acct_desc=<%=acct_name%>&month=02&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m2)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m3)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs1.getString("i_acctno"))%>&acct_desc=<%=acct_name%>&month=03&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m3)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m4)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs1.getString("i_acctno"))%>&acct_desc=<%=acct_name%>&month=04&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m4)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m5)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs1.getString("i_acctno"))%>&acct_desc=<%=acct_name%>&month=05&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m5)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m6)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs1.getString("i_acctno"))%>&acct_desc=<%=acct_name%>&month=06&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m6)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m7)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs1.getString("i_acctno"))%>&acct_desc=<%=acct_name%>&month=07&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m7)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m8)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs1.getString("i_acctno"))%>&acct_desc=<%=acct_name%>&month=08&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m8)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m9)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs1.getString("i_acctno"))%>&acct_desc=<%=acct_name%>&month=09&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m9)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m10)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs1.getString("i_acctno"))%>&acct_desc=<%=acct_name%>&month=10&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m10)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m11)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs1.getString("i_acctno"))%>&acct_desc=<%=acct_name%>&month=11&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m11)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m12)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs1.getString("i_acctno"))%>&acct_desc=<%=acct_name%>&month=12&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m12)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_sm1)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs1.getString("i_acctno"))%>&acct_desc=<%=acct_name%>&month=Q1&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_sm1)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_sm2)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs1.getString("i_acctno"))%>&acct_desc=<%=acct_name%>&month=Q2&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_sm2)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", v_m13)%></td>
	  <td width="50px"><% if (chk_link.equals("Y")) {  %><A HREF="EIS_PvdExpenceMonthDetail.jsp?i_company=<%=i_com%>&i_project=<%=i_proj%>&acctno=<%=doString.checkString(rs1.getString("i_acctno"))%>&acct_desc=<%=acct_name%>&month=ALL&year=<%=year%>"><% } %><%=doString.displayNumber("###,###.0", b_m13)%></A></td>
	  <td width="50px" bgcolor="#FFFFCC"><%=doString.displayNumber("###,###.0", a_per1)%></td>
      <td width="50px"><%=doString.displayNumber("###,###.0", b_per1)%></td>
    </tr>
<%
				//-------Total Actual -----						
				i_tot_m1 += b_m1;   
				i_tot_m2 += b_m2;
				i_tot_m3 += b_m3;
				i_tot_m4+= b_m4;
				i_tot_m5 += b_m5;
				i_tot_m6 += b_m6;
				i_tot_m7 += b_m7;
				i_tot_m8 += b_m8;
				i_tot_m9 += b_m9;		
				i_tot_m10 += b_m10;
				i_tot_m11 += b_m11;
				i_tot_m12 += b_m12;
				i_tot_m13 += b_m13;	
				i_tot_sm1 += b_sm1;
				i_tot_sm2 += b_sm2;	
				
				//--------Total Budget -----
				i_tot_vm1 += v_m1;
				i_tot_vm2 += v_m2;
				i_tot_vm3 += v_m3;
				i_tot_vm4+= v_m4;
				i_tot_vm5 += v_m5;
				i_tot_vm6 += v_m6;
				i_tot_vm7 += v_m7;
				i_tot_vm8 += v_m8;
				i_tot_vm9 += v_m9;
				i_tot_vm10 += v_m10;
				i_tot_vm11 += v_m11;
				i_tot_vm12 += v_m12;
				i_tot_vsm1 += v_sm1;
				i_tot_vsm2 += v_sm2;
				i_tot_vm13 += v_m13;		

	} // end while
%>

	<tr class="specH1">
      <td width="270px" class="col_name1">รวมทุกบัญชี</td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm1)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m1)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm2)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m2)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm3)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m3)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm4)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m4)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm5)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m5)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm6)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m6)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm7)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m7)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm8)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m8)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm9)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m9)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm10)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m10)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm11)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m11)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm12)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m12)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vsm1)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_sm1)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vsm2)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_sm2)%></td>
	  <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_vm13)%></td>
      <td width="50px" class="col_name1r"><%=doString.displayNumber("#,##0.0", i_tot_m13)%></td>
	  <td width="50px" class="col_name1r">-</td>
      <td width="50px" class="col_name1r">-</td>
    </tr>	

</table>      

 <br style="font-size:8pt">

	<table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="300">ค่าซ่อมก่อนส่งมอบนิติฯ (ยอดสะสม)</td>
                <td class="item_tab3"></td>
                <td class="item_tab4">&nbsp;</td>
                <td class="item_tab5"></td>
              </tr>
            </table>
			 <table border="0" width="1870px" cellspacing="1" cellpadding="0" class="TBLine">
  <tr>
      <td width="270px" class="col_name1" rowspan="2"><a href="#">ต้นทุนทางอ้อม</a></td>
      <td class="col_name1" colspan="32">ปี <%=Integer.parseInt(year)%>&nbsp;&nbsp;หน่วย : พันบาท</td>      
	  <tr>
     <td width="100px" class="col_name1" colspan="2">ยอดสะสมถึงปี <%=(Integer.parseInt(year)-1)%></td>
	  <td width="100px" class="col_name1" colspan="2"><%=year%></td>
     <td width="100px" class="col_name1" colspan="2">รวม</td>
      
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
    </tr> 
<%
			//---------------------  BUDGET -------------------------------							
		   sql.delete(0, sql.length());
		   sql.append("select "+Bsum_detail+", i_acctno from lan:acbidrbg ") 
				.append("where i_year = '"+year+"' ")                                  
				.append("and i_company = '"+i_com+"' ")                                        
				.append("and i_project = '"+i_proj+"' ")                  
				.append("and i_acctno in ('54010','54011','54012','52410') ")	
				.append("and i_type = '3' ");			
		 //  out.println(sql.toString());
			rs1 = stmt1.executeQuery(sql.toString());
			while (rs1.next()) {			

						//-------------------------  ACCT NAME  ------------------------
						acct_name = "";
						sql.delete(0, sql.length());
						sql.append("select acct_desc ") 
							 .append("from lan:stxchrtr ")
							 .append("where acct_no = '"+doString.checkString(rs1.getString("i_acctno"))+"' ");	
						rs2 = stmt2.executeQuery(sql.toString());
						if (rs2.next()) {
								acct_name = doString.DisplayThai(doString.checkString(rs2.getString("acct_desc")));
						}

						sql.delete(0, sql.length());
						sql.append("select sum(z_amount) as z_amount from lan:acxgldtl ")
							.append("where comp_id = '"+i_com+"' and department = '"+i_proj+"' ")       
							.append("and year(doc_date)+543 < '"+year+"' ")   
							.append("and acct_no = '"+doString.checkString(rs1.getString("i_acctno"))+"' ")
							.append("and orig_journal != 'GJ' ");
						rs2 = stmt2.executeQuery(sql.toString());
						if (rs2.next()) {		
								old_year = Double.parseDouble(doString.displayNumber("###0.0", rs2.getDouble("z_amount")/1000));	
						}

						sql.delete(0, sql.length());
						sql.append("select sum(z_amount) as z_amount from lan:acxgldtl ")
							.append("where comp_id = '"+i_com+"' and department = '"+i_proj+"' ")       
							.append("and year(doc_date)+543 = '"+year+"' ")   
							.append("and acct_no = '"+doString.checkString(rs1.getString("i_acctno"))+"' ")
							.append("and orig_journal != 'GJ' ");
						rs2 = stmt2.executeQuery(sql.toString());
						if (rs2.next()) {		
								now_year = Double.parseDouble(doString.displayNumber("###0.0", rs2.getDouble("z_amount")/1000));											
						}
%>

<tr class="col_right ; specH1 ; white">
      <td width="270px" class="col_left ; item" style="font-size:8pt"><%=doString.checkString(rs1.getString("i_acctno"))%>-<%=acct_name%></td>
	  <td width="100px" bgcolor="#FFFFCC" colspan="2"><%=old_year%></td>
      <td width="100px" colspan="2"><%=now_year%></td>
	  <td width="100px"  bgcolor="#FFFFCC" colspan="2"><%=doString.displayNumber("###0.0", old_year+now_year)%></td>
	  
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
    </tr>
<%
		  	//----------------Total ---------------						
				tot_oldyear += old_year;   
				tot_nowyear += now_year;   
				tot_allyear = tot_oldyear+tot_nowyear;


	} // end while
%>


<tr class="specH1">
      <td width="270px" class="col_name1">รวม</td>
	  <td width="100px" class="col_name1r" colspan="2"><%=doString.displayNumber("###0.0", tot_oldyear)%></td>
      <td width="100px" class="col_name1r" colspan="2"><%=doString.displayNumber("###0.0", tot_nowyear)%></td>
	  <td width="100px" class="col_name1r" colspan="2"><%=doString.displayNumber("###0.0", tot_allyear)%></td>
	  
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
      <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
	  <td width="50px" class="col_name1">&nbsp;</td>
    </tr>
<%
						sql.delete(0, sql.length());
						sql.append("select sum(z_amount_bf+z_amount_inv) as z_amount from lan:acbinfbf ")
							.append("where i_company = '"+i_com+"' and i_project = '"+i_proj+"' ")       
							.append("and i_year = '"+year+"' ")   
							.append("and i_code = '090' ")
							.append("and i_detail1 = '015' ");
						rs2 = stmt2.executeQuery(sql.toString());
						if (rs2.next()) {		
								tot_cost = Double.parseDouble(doString.displayNumber("###0.0", rs2.getDouble("z_amount")/1000));											
								//tot_cost = Double.parseDouble(doString.displayNumber("###0.0", rs2.getDouble("z_amount")));		
						}

						sql.delete(0, sql.length());
						sql.append("select sum(z_amount) as z_amount from lan:acbcasfd ")                                              
							.append("where i_year = '"+year+"' ")                                                      
							.append("and i_company = '"+i_com+"' ")                                                         
							.append("and i_project = '"+i_proj+"' ")                                                         
							.append("and i_bud_type = '1' ")                                                            
							.append("and i_code = '090' ")                                                              
							.append("and i_detail = '015' ");
						rs2 = stmt2.executeQuery(sql.toString());
						if (rs2.next()) {		
								tot_cost2 = Double.parseDouble(doString.displayNumber("###0.0", rs2.getDouble("z_amount")/1000));											
						}

%>
</table>
<br style="font-size:2pt">

<table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
<tr>
	<td width="100%"><FONT COLOR="#FF0000">&nbsp;&nbsp;งานซ่อมสาธารณูก่อนส่งมอบนิติ (เงินลงทุนทั้งสิ้น) <%=doString.displayNumber("#,###.#", tot_cost+tot_cost2)%> (พันบาท)</FONT></td>
</tr>
</table>   

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
            <td class="act_tab4"><a href="javascript:history.back()"><img border="0" src="images/bu_back.gif" width="50" height="15"></a><a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" width="50" height="15"></a></td>  
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
<%
	stmt.close();
	conn.close();
	stmt = null;
	conn = null;
}
catch (Exception e) {
	System.out.println("!!!ERROR EIS_PvdProjExpenceMnt.jsp : " + e.getMessage());
	System.out.println("!!!ERROR EIS_PvdProjExpenceMnt.jsp SQL : " + sql.toString());
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
</FORM>

</BODY>
</HTML>