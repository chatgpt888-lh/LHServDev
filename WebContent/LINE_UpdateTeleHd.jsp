<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>


  <html>
  <head>
    <link rel="stylesheet" href="jquery/jquery-ui.css">
  <script src="jquery/jquery-1.12.4.js"></script>
  <script src="jquery/jquery-ui.js"></script>
  </head>
  <form method="POST" name="frmTele" id="frmTele">
<%
	/*
	String ParameterNames = "";
	for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
		ParameterNames = (String)e.nextElement();
		System.out.println(ParameterNames + " = "+request.getParameter(ParameterNames));
	}
	System.out.println("*******************************************");
*/
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

		String refId = "";
		String empId = "";
		String tempTfuRemark = "";
		if(request.getParameter("refId") != null) {
			refId = doString.checkString(request.getParameter("refId"),"");
		}
		if(request.getParameter("empId") != null) {
			empId = doString.checkString(request.getParameter("empId"),"");
		}
		if(request.getParameter("tfuRemark") != null) {
			tempTfuRemark = doString.UnicodeToMS874(doString.checkString(request.getParameter("tfuRemark"),""));
		}
		
	  //update lan:tele_dochd set i_emp_update = '2154-6',d_update = current ,c_tfu_remark = 'test'
      //where i_refno = '62110001'

		sql.delete(0, sql.length());
		sql.append(" update lan:tele_dochd set i_emp_update = '"+empId+"',d_update = current ,c_tfu_remark = '"+tempTfuRemark+"' ")	
		   .append("  where i_refno = '"+refId+"' ");
		int x = stmt.executeUpdate(sql.toString());
		//out.println("Success");
		%>
		<b>Success</b>
		<script>
		//var url = "<%=request.getContextPath()%>/LINE_SERVDetail.jsp";
		// $(document).ready(function() {
		//	$(location).attr('href',url);
		//});
		</script>
		<%
		
	} catch (Exception e) {
		System.out.println("!!! ERROR LINE_UpdateTeleHd.jsp : " + e.getMessage());
		//throw new ServletException(e.getMessage());
		out.println("!!! Error :"+e.getMessage());
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
</form>
</html>