<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ include file="confirmLogin.jsp" %>
<%!
	// Caching the DataSource - It is obtained in the jspInit() method
	private javax.sql.DataSource ds = null;
	private String dsName = Constants.JDBC_LAN;
	private String month[] = {"มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
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

StringBuffer sql = new StringBuffer();
Connection conn = null;
PreparedStatement prep = null;
Statement stmt = null;
Statement stmt1 = null;
ResultSet rs = null;
ResultSet rs1 = null;


String i_company = "";
String i_project = "";
String n_project = "";


try {
	if (ds == null)
		getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
    conn.setAutoCommit(true);
	stmt = conn.createStatement();
	stmt1 = conn.createStatement();
	
	Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
	int YY = rightNow.get(Calendar.YEAR);
	int MM = rightNow.get(Calendar.MONTH) + 1;
	int DD = rightNow.get(Calendar.DATE);
	
	
	String i_order = doString.checkString(request.getParameter("i_order"));
	if("".equals(i_order)){
		throw new Exception("Parameter invalid.");
	}
	
%>
<HTML>
<HEAD>
<TITLE>รายละเอียด ใบสั่งซื้อ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
<!--

//-->
</script>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM NAME="frmResvTime" METHOD=POST ACTION="/LHServ/SERV_PODetail.jsp">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
		<td width="100%" class="BD">
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="50%" class="bigh"><img border="0"
					src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
				รายละเอียด ใบสั่งซื้อ</td>
				<td width="50%" align="right"></td>
			</tr>
		</table>
		<br style="font-size:10pt">
		<%	
			int cnt = 0, x = 0; 
			String tmpdate = "", f_status = "", po_status = "", d_acc = "";
			String hdCom = "", hdPrj = "", hdOrd = "", hdLck = "", hdSlck = "";
			double sumdtl = 0;
				
			sql.delete(0, sql.length());
			sql.append("select distinct a.*")
				.append(" from lan:accpohdr a")
				.append(" left join lan:accpodtl b")
				.append(" on a.i_company = b.i_company")
				.append(" and a.i_project = b.i_project")
				.append(" and a.i_order = b.i_order")
				.append(" and a.i_lock = b.i_lock")
				.append(" and a.s_lock = b.s_lock")	
				.append(" , lan:acxlckmd c")
			    .append(" where a.i_order = '")
				.append(i_order)
				.append("' and a.i_company = c.i_company")
				.append(" and a.i_project = c.i_project")
				.append(" and a.i_lock = c.i_lock")
				.append(" and a.s_lock = c.s_lock")
				.append(" order by a.grp_no, a.d_order desc, a.i_lock, a.s_lock");
			System.out.println(">> sql hd = "+sql.toString());	
			rs = stmt.executeQuery(sql.toString());
			
			if (rs.next()) {
				
				hdCom = doString.checkString(rs.getString("i_company"));
				hdPrj = doString.checkString(rs.getString("i_project"));
				hdOrd = doString.checkString(rs.getString("i_order"));
				hdLck = doString.checkString(rs.getString("i_lock"));
				hdSlck = doString.checkString(rs.getString("s_lock"));
				f_status = doString.checkString(rs.getString("f_status"));
				d_acc = "";
				sql.delete(0, sql.length());
				sql.append("select d_acc_confirm from lan:acctrnpo")
					.append(" where i_company = '")
					.append(hdCom)
					.append("' and i_project = '")
					.append(hdPrj)
					.append("' and i_order = '")
					.append(hdOrd)
					.append("'"); 
				//System.out.println(">> sql = "+sql.toString());							
				rs1 = stmt1.executeQuery(sql.toString());
		
				if (rs1.next()) {
					d_acc = doString.checkString(rs1.getString("d_acc_confirm"));
				} // End if rs1
				rs1.close();
		%>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td class="item_tab1"><img border="0" src="images/i_i.gif"
					align="absmiddle" width="20" height="20"></td>
				<td class="item_tab2" width="200">รายละเอียด</td>
				<td class="item_tab3"></td>
				<td>&nbsp;</td>
			</tr>
		</table>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="5" valign="top"><img border="0"
					src="images/Corn01.gif" width="5" height="5"></td>
				<td class="frmTop">&nbsp;</td>
				<td width="5" valign="top" align="right"><img border="0"
					src="images/Corn02.gif" width="5" height="5"></td>
			</tr>
		</table>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="100%" class="frmLR" align="center">
				<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						<td class="item ; dotline01" height="22" width="7%">โครงการ :</td>
						<td height="22" width="47%" class="dotline01">
							<%=hdCom+hdPrj%><%
						sql.delete(0, sql.length());
						sql.append("select n_project from lan:acxprojt")
							.append(" where i_company = '")
							.append(hdCom)
							.append("' and i_project = '")
							.append(hdPrj)
							.append("'"); 
						//System.out.println(">> sql = "+sql.toString());							
						rs1 = stmt1.executeQuery(sql.toString());
			
						if (rs1.next()) {
							out.print("-"+doString.DisplayThai(doString.checkString(rs1.getString("n_project"))));
						} // End if rs1
						rs1.close();
						%>
						</td>
						<td height="22" class="item ; dotline01" width="5%">&nbsp;</td>
						<td height="22" width="41%" class="dotline01">&nbsp;</td>
					</tr>
					<tr>
						<td class="item ; dotline01" height="22" width="7%">เลขที่ PO :</td>
						<td height="22" width="47%" class="dotline01"><%=hdOrd%></td>
						<td height="22" class="item ; dotline01" width="5%">วันที่ PO :</td>
						<td height="22" width="41%" class="dotline01">
							<div class='input-group' style="display: inline;"><%
						tmpdate = doString.checkString(rs.getString("d_order"));
						if (!tmpdate.equals("")) {
							tmpdate = tmpdate.substring(8, 10) + "/" + tmpdate.substring(5, 7) + "/" + Integer.toString(Integer.parseInt(tmpdate.substring(0, 4))+543);						
						} // End tmpdate
						out.print(tmpdate);
						%></div>
						</td>
					</tr>
					<tr>
						<td class="item ; dotline01" height="22" width="7%">วัสดุ :</td>
						<td height="22" width="47%" class="dotline01">
							<div class='input-group' style="display: inline;"><%=doString.checkString(rs.getString("grp_no"))%><%
							sql.delete(0, sql.length());
							sql.append("select grp_desc from lan:itmgrp")
								.append(" where grp_no = '")
								.append(doString.checkString(rs.getString("grp_no")))
								.append("'"); 
							//System.out.println(">> sql = "+sql.toString());
							rs1 = stmt1.executeQuery(sql.toString());
				
							if (rs1.next()) {
								out.print("-"+doString.DisplayThai(doString.checkString(rs1.getString("grp_desc"))));
							} // End if rs1
							rs1.close();
							%></div>
						</td>
						<td height="22" class="item ; dotline01" width="5%">สถานะ :</td>
						<td height="22" width="41%" class="dotline01">	
							<div class='input-group' style="display: inline;"><%=doString.checkString(rs.getString("f_status"))%> (<%
							po_status = doString.checkString(rs.getString("po_status"));
							if (po_status.equals("OPN")) {
								out.print("เปิด PO");
							} else if (po_status.equals("CDPO")) {
								out.print("ร้านค้ายืนยันรับ PO");
							} else if (po_status.equals("CFPO")) {
								out.print("ร้านค้ายืนยันส่งของ");
							} else if (po_status.equals("GRPO")) {
								out.print("โครงการยืนยันรับของ");
							} else if (po_status.equals("PMPO")) {
								out.print("ยืนยันสั่งจ่าย");
							} else if (po_status.equals("INV")) {
								out.print("ทำจ่ายแล้ว");
							}
							%>)</div>
						</td>
					</tr>
					<tr>
						<td class="item ; dotline01" height="22" width="7%">ร้านค้า :</td>
						<td height="22" width="47%" class="dotline01">
							<div class='input-group' style="display: inline;"><%=doString.checkString(rs.getString("i_vendor"))%><%
							sql.delete(0, sql.length());
							sql.append("select ven_name from lan:vendor")
								.append(" where ven_no = '")
								.append(doString.checkString(rs.getString("i_vendor")))
								.append("'"); 
							//System.out.println(">> sql = "+sql.toString());
							rs1 = stmt1.executeQuery(sql.toString());
				
							if (rs1.next()) {
								out.print("-"+doString.DisplayThai(doString.checkString(rs1.getString("ven_name"))));
							} // End if rs1
							rs1.close();
							%></div>
						</td>
						<td height="22" class="item ; dotline01" width="5%">วันที่จ่ายจริง :</td>
						<td height="22" width="41%" class="dotline01"><%
						tmpdate = d_acc;
						if (!tmpdate.equals("")) {
							tmpdate = tmpdate.substring(8, 10) + "/" + tmpdate.substring(5, 7) + "/" + Integer.toString(Integer.parseInt(tmpdate.substring(0, 4))+543);						
						} // End tmpdate
						out.print(tmpdate);
						%></td>
					</tr>
					<tr>
						<td class="item ; dotline01" height="22" width="7%">แปลง :</td>
						<td height="22" width="47%" class="dotline01"><div class='input-group' style="display: inline;"><%=hdLck+"-"+hdSlck%></div></td>
						<td height="22" class="item ; dotline01" width="5%">แบบบ้าน :</td>
						<td height="22" width="41%" class="dotline01">	
							<div class='input-group' style="display: inline;"><%
							sql.delete(0, sql.length());
							sql.append("select i_model from lan:acxlckmd")
								.append(" where i_company = '")
								//.append(project.substring(0, 2))
								.append(hdCom)
								.append("' and i_project = '")
								//.append(project.substring(2))
								.append(hdPrj)
								.append("' and i_lock = '")
								.append(hdLck)
								.append("' and s_lock = '")
								.append(hdSlck)
								.append("'"); 
							//System.out.println(">> sql mdl 1= "+sql.toString());
							rs1 = stmt1.executeQuery(sql.toString());
				
							if (rs1.next()) {
								out.print(doString.checkString(rs1.getString("i_model")));
							} else {
								sql.delete(0, sql.length());
								sql.append("select i_model from lan:acxlckhd")
									.append(" where i_company = '")
									//.append(project.substring(0, 2))
									.append(hdCom)
									.append("' and i_project = '")
									//.append(project.substring(2))
									.append(hdPrj)
									.append("' and i_lock = '")
									.append(hdLck)
									.append("'"); 
								//System.out.println(">> sql mdl 2= "+sql.toString());
								rs1 = stmt1.executeQuery(sql.toString());
					
								if (rs1.next()) {
									out.print(doString.checkString(rs1.getString("i_model")));
								}
							} // End if rs1
							rs1.close();
							%></div>
						</td>
					</tr>
					<tr>
						<td class="item ; dotline01" height="22" width="7%">ผู้รับเหมา :</td>
						<td height="22" width="47%" class="dotline01">	
							<div class='input-group' style="display: inline;"><%=doString.checkString(rs.getString("ven_no"))%><%
							sql.delete(0, sql.length());
							sql.append("select ven_name from lan:vendor")
								.append(" where ven_no = '")
								.append(doString.checkString(rs.getString("ven_no")))
								.append("'"); 
							//System.out.println(">> sql = "+sql.toString());
							rs1 = stmt1.executeQuery(sql.toString());
				
							if (rs1.next()) {
								out.print("-"+doString.DisplayThai(doString.checkString(rs1.getString("ven_name"))));
							} // End if rs1
							rs1.close();
							%></div>
						</td>
						<td height="22" class="item ; dotline01" width="5%">&nbsp;</td>
						<td height="22" width="41%" class="dotline01">&nbsp;</td>
					</tr>
					<tr>
						<td class="item ; dotline01" height="22" width="7%">วันที่ส่ง :</td>
						<td height="22" width="47%" class="dotline01">
							<div class='input-group' style="display: inline;"><%
							tmpdate = doString.checkString(rs.getString("d_send"));
							if (!tmpdate.equals("")) {
								tmpdate = tmpdate.substring(8, 10) + "/" + tmpdate.substring(5, 7) + "/" + Integer.toString(Integer.parseInt(tmpdate.substring(0, 4))+543);						
							} // End tmpdate
							out.print(tmpdate);
							%></div>
						</td>
						<td height="22" class="item ; dotline01" width="5%">สถานะพิมพ์ :</td>
						<td height="22" width="41%" class="dotline01"><div class='input-group' style="display: inline;"><%=doString.checkString(rs.getString("f_print"))%></div></td>
					</tr>
				</table>
				</td>
			</tr>
		</table>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="5" valign="bottom"><img border="0"
					src="images/Corn03.gif" width="5" height="5"></td>
				<td class="frmBottom">&nbsp;</td>
				<td width="5" valign="bottom" align="right"><img border="0"
					src="images/Corn04.gif" width="5" height="5"></td>
			</tr>
		</table>
		
<%		
			} // End if rs
			rs.close();
%>						
		<br style="font-size:10pt">
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td class="item_tab1"><img border="0" src="images/i_i.gif"
					align="absmiddle" width="20" height="20"></td>
				<td class="item_tab2" width="160">รายละเอียดช่วงเวลาที่จอง</td>
				<td class="item_tab3"></td>

				<td>&nbsp;</td>
			</tr>
		</table>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="5" valign="top" bgcolor="#D7E6FF"><img border="0"
					src="images/Corn01.gif" width="5" height="5"></td>
				<td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
				<td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img
					border="0" src="images/Corn02.gif" width="5" height="5"></td>
			</tr>
		</table>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="100%" class="frmL">

				<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						<td width="5%" class="col_name">ประเภท</td>
						<td width="8%" class="col_name">รหัสวัสดุ</td>
						<td width="13%" class="col_name">รายละเอียด</td>
						<td width="26%" class="col_name">Unit</td>
					</tr>
					<%
						x = 0;
						sql.delete(0, sql.length());
						sql.append("select *")
							.append(" from lan:accpodtl")
							.append(" where i_company = '")
							.append(hdCom)
							.append("' and i_project = '")
							.append(hdPrj)
							.append("' and i_lock = '")
							.append(hdLck)
							.append("' and s_lock = '")
							.append(hdSlck)
							.append("' and i_order = '")
							.append(hdOrd)
							.append("' order by itm_frm, itm_no");
						//System.out.println(">> dt sql = "+sql.toString());	
						rs = stmt.executeQuery(sql.toString());
						
						while (rs.next()) {		
							x++;
							
							sumdtl += Double.parseDouble(doString.displayNumber("#####0.00", rs.getDouble("itm_amt"))) * Double.parseDouble(doString.displayNumber("#####0.00", rs.getDouble("itm_qty")));
					%>
					<tr>
						<td width="5%" class="dotline ; item" align="center"><%=doString.checkString(rs.getString("itm_frm"))%></td>
						<td width="8%" class="dotline ; item" align="center"><%=doString.checkString(rs.getString("itm_no"))%></td>
						<td width="13%" class="dotline" align="center"><%
							 out.print(doString.DisplayThai(doString.checkString(rs.getString("itm_desc"))));
						%></td>
						<td width="26%" class="dotline" align="center"><%=doString.checkString(rs.getString("itm_qty"))%></td>
					</tr>
					<%		
						} // End while rs
						rs.close();
						if (x == 0) {
					%>
					<tr>
						<td class="dotline ; item" align="center">&nbsp;</td>
						<td class="dotline ; item" align="center">&nbsp;</td>
						<td class="dotline" align="center">&nbsp;</td>
						<td class="dotline" align="center">&nbsp;</td>
					</tr>
					<%
						}
					%>					
				</table>
				</td>
			</tr>
		</table>

		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="5" valign="bottom"><img border="0"
					src="images/Corn03.gif" width="5" height="5"></td>
				<td class="frmBottom">&nbsp;</td>
				<td width="5" valign="bottom" align="right"><img border="0"
					src="images/Corn04.gif" width="5" height="5"></td>
			</tr>
		</table>
		<br style="font-size:10pt">
		<table border="0" width="100%" cellspacing="0" cellpadding="0"
			height="30">
			<tr>
				<td class="act_tab1"></td>
				<td width="150" class="act_tab2">&nbsp;</td>
				<td class="act_tab3"></td>
				<td class="act_tab4"><a href="javascript:window.history.back()" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;<a href="SERV_Home.jsp"
					target="_top"><img border="0" src="images/bu_home.gif"
					align="absmiddle" width="50" height="15"></a></td>
			</tr>
		</table>
		</td>
	</tr>
</table>
</FORM>
</BODY>
</HTML>

<%
		stmt.close();
		stmt1.close();
		conn.close();
		stmt = null;
		stmt1 = null;
		conn=null;
	} catch (Exception e) {
		System.out.println("ERROR SERV_PODetail.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (rs1 != null) rs1.close();
			if (stmt != null) stmt.close();
			if (stmt1 != null) stmt1.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>
