<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%
	String mode = doString.checkString(request.getParameter("mode"),"add");
	String venNo = doString.checkString(request.getParameter("ven_no"),"");
	String vatTax = doString.checkString(request.getParameter("vat_tax_flag"),"");
	String glCode = doString.checkString(request.getParameter("gl_code"),"");

	String successPage = "SERV_INFVenVt01.jsp";
	String otherMsg = "";
	String errorCode = "";

	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;

	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();        
        //----=======================================----//
		if (mode.equalsIgnoreCase("ADD")) {
				
				//---=========== Check i_type and i_code is exist or not =============---//
				sql.append(" select count(*) as cnt from lan:servvenvt where ")
				   .append(" ven_no='").append(venNo).append("' ");
				rs = stmt.executeQuery(sql.toString());				
				int cnt = -1;
				if (rs.next()) {
					cnt = rs.getInt("cnt");
				}
				rs.close();
				
				if (cnt==0) {
					//---======= i_type and i_code is not exist ========---//
					sql.delete(0,sql.length());
					sql.append("insert into lan:servvenvt (ven_no,vat_tax_flag,gl_code ")
					   .append(" ) values ( ")
					   .append(" '").append(venNo).append("' , ")
					   .append(" '").append(vatTax).append("' , ")
					   .append(" '").append(glCode).append("') ");
					stmt.executeUpdate(sql.toString());
				} else {
					//----========= ven_no and i_job is exist , return to input page =========--//	
					errorCode = "1";
					otherMsg = "รหัสบัญชีที่กำหนด มีอยู่ในระบบแล้วกรุณากรอกรหัสใหม่ !" ;
				}

			}
			//----======== Edit Mode , Update Query =========----//
			else if (mode.equalsIgnoreCase("EDIT")) {
				sql.append("update lan:servvenvt set ")
				   .append(" vat_tax_flag = '").append(vatTax).append("' , ")
				   .append(" gl_code = '").append(glCode).append("' ")
				   .append(" where ven_no='").append(venNo).append("' ");
				stmt.executeUpdate(sql.toString());				
			}
			//----======== Delete Mode , Delete Query =========----//
			else if (mode.equalsIgnoreCase("DELETE")) {		
				 successPage = "SERV_INFVenVt01.jsp";	 
				 String[] delid = request.getParameterValues("del_id");
				 if (delid!=null) {
					 for (int i=0;i<delid.length;i++) {
							sql.delete(0,sql.length());
							sql.append("delete from lan:servvenvt ")
								  .append(" where ven_no='").append(delid[i]).append("' ");
							stmt.executeUpdate(sql.toString());
					 } // end for
				 }	
			}
			stmt.close();
			conn.close();
			conn = null;
			response.sendRedirect("/LHServ/"+successPage);
	} catch (Exception e) {
		System.out.println("ERROR SERV_INFVenVt.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (stmt != null) stmt.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>