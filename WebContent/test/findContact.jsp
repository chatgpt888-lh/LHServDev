<%@page language="java" contentType="text/html; charset=windows-874" pageEncoding="windows-874"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<!--  % @ include file="confirmLogin.jsp" %>-->
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
		try{
			getDS();
		}catch(Exception es){
		  es.printStackTrace();
		}
	}
%>
<html>
<%
 String args1 = request.getParameter("args1")==null?"":request.getParameter("args1");
 String args2 = request.getParameter("args2")==null?"":request.getParameter("args2");
 String args3 = request.getParameter("args3")==null?"":request.getParameter("args3");
 String args4 = request.getParameter("args4")==null?"":request.getParameter("args4");
 %>

<head>
<title>Find Contact </title>

<meta http-equiv="Content-Type" content="text/html; charset=windows-874">
<meta name="GENERATOR" content="Rational Application Developer">

</head>
<body>
 <%
System.out.println("---------------------Param Request---------------------------");
String ParameterNames = "";
for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
	ParameterNames = (String)e.nextElement();
	System.out.println(ParameterNames + " = "+request.getParameter(ParameterNames));
}
System.out.println("-----------------------------------------------------------");
 
StringBuffer sql = new StringBuffer();
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
try {
  if("".equals(args1)){
  %>
     <b><li>!!!! กรุณาตรวจสอบ เบอร์โทรศัพท์ด้วย....</b>
  <%
  }else{
	   //case  tel fin in data base
	   // connect db   
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
	   //**************************
	   boolean isRecord = true;
	   String telNo = "";
	   String fName = "";
	   String lName = "";
	   String comId = "";
	   String project = "";
	   String iLock = "";
	   String projectName = "";
	   //**************************
	   sql.delete(0,sql.length());
	   sql.append(" select a.i_telno,a.n_customer,a.n_scustomer,a.i_company,a.i_project,a.i_lock,b.n_project ")
	   	  .append(" From lan:csv_telno a,lan:acxprojt b  where i_telno = ? ")
	   	  .append(" and a.i_company  = b.i_company  and a.i_project = b.i_project ");					 	   
		pstmt = conn.prepareStatement(sql.toString()); 
		pstmt.setString(1, args1);				
		//System.out.println("SQL :"+sql.toString());	
		rs = pstmt.executeQuery();	
		if(rs.next()){
		     isRecord = false;
			 telNo = doString.checkString(rs.getString("i_telno"),"");
		     fName = doString.checkString(rs.getString("n_customer"),"");
		     lName = doString.checkString(rs.getString("n_scustomer"),"");
		     comId = doString.checkString(rs.getString("i_company"),"");
		     project = doString.checkString(rs.getString("i_project"),"");
		     iLock = doString.checkString(rs.getString("i_lock"),"");
		     projectName = doString.checkString(rs.getString("n_project"),"");
		}
		rs.close();			 	  
	   //**************************
	   if(isRecord){//Find not found record.
	   %>
	   		<table width="100%" cellspacing=1 cellpadding=2 bgcolor=#FFFFFF>
		      <tr>
		        <td align="center" bgcolor="#D2E6FF">&nbsp;</td>
		      </tr>
		       <tr>
		        <td align="center" bgcolor="#D2E6FF">&nbsp;ไม่พบข้อมูล !!!</td>
		      </tr>
		       <tr>
		        <td align="center" bgcolor="#D2E6FF">&nbsp;</td>
		      </tr>
		     </table> 
	   <%
	   }else{ // Find successfully
	   %>
	   		 <table width="100%" cellspacing=1 cellpadding=2 bgcolor=#FFFFFF>
		      <tr>
		        <td align="center" bgcolor="#D2E6FF">เบอร์โทร :</td>
		        <td align="center" bgcolor="#BEDCFF"><font color="#000080" size="2" face="MS Sans Serif">
		        &nbsp;
		        <%=telNo %>
		        </font></td>
		      </tr>
		      <tr>
		        <td align="center" bgcolor="#D2E6FF">ชื่อ-สกุล :</td>
		        <td align="center" bgcolor="#BEDCFF"><font color="#000080" size="2" face="MS Sans Serif">
		        &nbsp;
		         <%=doString.DisplayThai(fName) %>&nbsp; <%=doString.DisplayThai(lName) %>
		        </font></td>
		      </tr>
		      		      <tr>
		        <td align="center" bgcolor="#D2E6FF">ชื่อโครงการ : </td>
		        <td align="center" bgcolor="#BEDCFF"><font color="#000080" size="2" face="MS Sans Serif">
		        &nbsp;
		           <%=doString.DisplayThai(comId) %>&nbsp; <%=doString.DisplayThai(project) %>&nbsp;<%=doString.DisplayThai(projectName) %>
		        </font></td>
		      </tr>
		      <tr>
		        <td align="center" bgcolor="#D2E6FF">แปลง :</td>
		        <td align="center" bgcolor="#BEDCFF"><font color="#000080" size="2" face="MS Sans Serif">
		        &nbsp;
		       <%=doString.DisplayThai(iLock) %>
		        </font></td>
		      </tr>
		      </table>
	   <%
	   }
  	}
  }catch(Exception e){
      System.out.println("!!Exception :"+e.toString());
      System.out.println("!!SQL  :"+sql.toString());
  }finally{
     if(rs!=null){rs.close();}
     if(pstmt!=null){pstmt.close();}
     if(conn!=null){conn.close();}
  }
  %>
</body>
</html>
