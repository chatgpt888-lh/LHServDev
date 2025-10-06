<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ include file="function.jsp" %>
<% 
	String itemId = "";
	String account = "";
	String payDate = "";
	String mnthDate = "";
	String mnth = "";
	String year = "";
	String docNo = "";
	String comId = "";
	String projId = "";
	double com_ps = 0;
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement ustmt = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();   
		ustmt = conn.createStatement();   
		rs = stmt.executeQuery("SELECT i_docno, i_month FROM lan:serv_infpayment");
		if (rs != null) {
			while (rs.next() == true) {

				docNo = rs.getString("I_DOCNO");
				comId = docNo.substring(0,2);
				projId = docNo.substring(3,6);
				mnthDate = rs.getString("I_MONTH");
				year = mnthDate.substring(0,4);
				mnth = mnthDate.substring(5,7);
				com_ps = 0;
				rs1 = ustmt.executeQuery("SELECT z_cal_constr, z_cal_trans FROM lan:avs_area WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_month = '"+mnth+"' AND i_year = '"+year+"'");
				if (rs1 != null) {
					if (rs1.next() == true) {
						com_ps = rs1.getDouble("Z_CAL_CONSTR");
					}
					rs1.close();
					rs1=null;
				}
				ustmt.executeUpdate("UPDATE lan:serv_infpayment SET p_com = '"+com_ps+"' WHERE i_docno = '"+docNo+"' AND i_month = '"+mnthDate+"'");
			}// end while
			rs.close();
			rs=null;
		}
		out.print("OK");
		stmt.close();
		ustmt.close();
		conn.close();
		conn=null;
	} catch (Exception e) {
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (stmt != null) stmt.close();
			if (ustmt != null) ustmt.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>