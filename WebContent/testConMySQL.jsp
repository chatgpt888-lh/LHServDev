<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@page language="java" contentType="text/html; charset=tis-620"
	pageEncoding="tis-620"%>

<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<!--  
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;	
-->	
<%!
private static List ListHash7dateLater(Connection conn) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter		
        	//System.out.println("##ListHash7dateLater ->Starting.");   
        	List  resultList = new ArrayList();
        	HashMap hashMap = null;   
			/******************************************************/	       	
			sql.delete(0,sql.length());
			//sql.append(" select  date(SUBDATE( '2018-10-15', INTERVAL ? day )) as xsysdate "); //now()
			sql.append(" select * from  lser_dochd where 1 = 1 "); //now()

			System.out.println("List7dateLater:"+sql.toString());
			
			//for(int i=0;i<5;i++){
			//for(int i=1;i<=1;i++){		
				pstmt = conn.prepareStatement(sql.toString());	
				//pstmt.setString(1, ""+i);
				rs = pstmt.executeQuery();					
				String temp = "";
				while(rs.next()){	
					//temp = "";
					//temp = doString.checkString(rs.getString("i_lock"),"");
					hashMap = new HashMap();
	    			hashMap.put("xID", doString.checkString(rs.getString("i_line_docno"),""));
	    			hashMap.put("xCOM", doString.checkString(rs.getString("i_company"),""));
	    			hashMap.put("xPROJ", doString.checkString(rs.getString("i_project"),""));
	    			hashMap.put("xLOCK", doString.checkString(rs.getString("i_lock"),""));
	    			hashMap.put("xHOUSE", doString.checkString(rs.getString("i_house"),""));
	    			hashMap.put("xKEYIN", doString.checkString(rs.getString("d_keyin"),""));
	    			hashMap.put("xLINE_NO", doString.checkString(rs.getString("i_line_telno"),""));
	    			hashMap.put("xCUSTOMER", doString.checkString(rs.getString("i_customer"),""));
	    			
					resultList.add(hashMap);	
					System.out.println("Date :"+temp);
				}				
			//}
			rs.close();				
			//********************************************************/
		  	//System.out.println("##ListHash7dateLater->end.");				  	 
		  	return resultList;			  	 
		}catch(Exception e){
			System.out.println("!!! ListHash7dateLater , " + e.getMessage());
			System.out.println("!!! SQL Exception: "+sql.toString());		
			return null;
		}
		finally{			
			//clean up.
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
			}catch(Exception e){}
		}
	}
private static Connection GetConnMysqlJDBC() {
		String host = "132.144.1.63";
		String port = "3306";
		String dns = "testlan";
		//String schemaName = "onnetimp";
		String user = "testlan_db"; //testlan_db
		String password = "xsw21qaz";
		
		/*
		String host = "132.144.1.61";
		//host = "www10.lh.co.th";
		String port = "3306";
		String dns = "LH_LineService";
		//String schemaName = "onnetimp";
		String user = "lineapp_db"; //testlan_db
		String password = "xsw21qaz";
		//password = "7cQ3VxNMHo2L";*/
		
		try{
			 System.out.println("--->> MySQL use Connection Normal JDBC?");
			 //DB2 String conStr = "jdbc:db2://" + host + ":" + port + "/" + dns;
			 //String conStr = "jdbc:mysql://localhost:3306/db_person";
			 //jdbc:mysql://localhost/some_db?useUnicode=yes&characterEncoding=UTF-8?useUnicode=yes&characterEncoding=UTF-8
			 String conStr = "jdbc:mysql://" + host + ":" + port + "/" + dns+"?useUnicode=yes&characterEncoding=UTF-8";
			 System.out.println("conStr = " + conStr);
			
			 //DB2 DriverManager.registerDriver(new DB2Driver());
			 Class.forName("com.mysql.jdbc.Driver");
			 Connection connJDBC = DriverManager.getConnection(conStr, user, password);
			 System.out.println("--->> MySQL use Connection Normal JDBC--->PASSED OK");
			 return connJDBC;
		}
		catch(ClassNotFoundException e){
			System.out.println("!!!--->>ClassNotFoundException :"+e.toString());
			return null;
		}
		catch(SQLException e){
			System.out.println("!!!--->>SQLException :"+e.toString());
			return null;

		}
	}


 %>	
	
<html>
<head>
<title>testRet</title>
<meta http-equiv="Content-Type" content="text/html; charset=tis-620">
<meta name="GENERATOR" content="Rational Application Developer">
</head>
<body>
Test Connect MYSQL  
<form name="frm" method="POST">
<input type="hidden" name="id" value="1001">
<input type="hidden" name="name" value="pradoem">
<input type="hidden" name="salary" value="1500.50">
</form>
<%
	  Connection myConn = null;
		//Connection infxConn = null;
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try{
		
				/********** Connection DB *************/
			    myConn = GetConnMysqlJDBC();
			    myConn.setAutoCommit(true);
				/********** Connection DB *************/

			    //TODO :
			    List listHash7Date = ListHash7dateLater(myConn);

				
   			  if(listHash7Date!=null && listHash7Date.size()>0){ 
   			    HashMap hashMap = null;
	   			for (Iterator iter =listHash7Date.iterator(); iter.hasNext(); ) {
	   			    hashMap = (HashMap)iter.next(); 
					out.println("<br>"+hashMap.get("xID")+","+hashMap.get("xCOM")+","+hashMap.get("xPROJ")
					+","+hashMap.get("xLOCK")+","+hashMap.get("xHOUSE")+","+hashMap.get("xKEYIN")+","+hashMap.get("xLINE_NO")+","+hashMap.get("xCUSTOMER"));	
				}
   			  } 
 				
			    if(myConn!=null){
				    myConn.close();	
				}
				/*if(infxConn!=null){
				    infxConn.close();
				}*/

				System.out.println("=== Successfully  ====");
		 }catch(Exception e){
			System.out.println("!!! Errors :"+e.toString());
			if(myConn!=null){
				try {
					myConn.close();
				} catch (SQLException e1) {
					// TODO Auto-generated catch block
				    e1.printStackTrace();
				}
			}
			/*if(infxConn!=null){
				try {
					infxConn.rollback();
					infxConn.close();
				} catch (SQLException e1) {
					// TODO Auto-generated catch block
				    e1.printStackTrace();
				}
			}*/
		}
		finally{
			 try{
				if(myConn!=null){
					myConn.close();
				}
				/*if(infxConn!=null){
					 infxConn.close();	
				}*/
				 System.out.println("=== Clean up connection DB  ====");
			     //Close connection
			}catch(Exception ex){}
	      } 
	
 %>
</body>
</html>
