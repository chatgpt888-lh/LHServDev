package com.svc.call.dao.services;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.*;
import java.util.Hashtable;
import javax.naming.Context;

/*********************************************/
 /* date:2013-10-29
 * author: pradoem wongkraso
 * verion 1.0
 * contact : go2doem@gmail.com,pradoem@lh.co.th
 * description: for connection database basic  with have other class extends 
 * for  connection Informix database krub.
 */
/********************************************/

public class Common {

	private static String host;
	private static String port;
	private static String dns;
	private static String user;
	private static String password;
	private static String schemaName; 
	private static String datasourceName; 
	private static int method;

	public static void setConfig(String host1, String port1, String dns1,
			String user1, String password1) {
		host = host1;
		port = port1;
		dns = dns1;
		user = user1;
		password = password1;
		datasourceName = "";
	}

	public static void setConfig(String host1, String port1, String dns1,
			String user1, String password1, String schemaNamel) {
		host = host1;
		port = port1;
		dns = dns1;
		user = user1;
		password = password1;
		schemaName = schemaNamel;
		datasourceName = "";
	}

	public static void setConfigForConnectionPool(String schemaName1,
			String datasourceName1) {
		// for user Connection Pool in Application Server or web server
		host = "";
		port = "";
		dns = "";
		user = "";
		password = "";
		schemaName = schemaName1;
		datasourceName = datasourceName1;

	}

	public static void setMethod(int way) {
		method = way;
	}

	public static String getSchemaName() {
		return schemaName;
	}

	public static Connection open() {
		if (datasourceName.equals("")) {
			method = 1;
		} 
		else{
			// use connection pool
			method = 2;
		}

		if (method == 2) {
			DataSource ds = null;
			Connection connJNDI=null;
			try{
			    //New get Data source
				/*				System.out.println("--->>GetDataSource from JNDI ") ;
				Context initCtx = new InitialContext();
			    Context envCtx = (Context) initCtx.lookup("java:comp/env");			    
			    ds = (DataSource) envCtx.lookup(datasourceName);			    
			    connJNDI = ds.getConnection();
			    System.out.println("--->>GetDataSource from JNDI WORKS--->PASSED OK") ;*/
			    
			    
			    //Old Data source Use below.
   		        /*// System.out.println("--->>GetDataSource from JNDI ") ;
				Context initCtx = new InitialContext();				
			    //Context envCtx = (Context) initCtx.lookup("java:comp/env");
				//ds = (DataSource) envCtx.lookup(datasourceName);
		
			    datasourceName = "jdbc/crm130";
				ds = (DataSource) initCtx.lookup(datasourceName);
			    connJNDI = ds.getConnection();
			    //System.out.println("--->>GetDataSource from JNDI Successfully.") ;
   		        */			
			    
			    
				//******LHServ Project
				Hashtable parms = new Hashtable();
				parms.put(Context.INITIAL_CONTEXT_FACTORY, "com.ibm.websphere.naming.WsnInitialContextFactory");
				InitialContext ctx = new InitialContext(parms);
				//Perform a naming service lookup to get the DataSource object.
				ds = (javax.sql.DataSource) ctx.lookup(datasourceName);
								
				connJNDI = ds.getConnection();	
				ctx.close();

				//System.out.println("--->>GetDataSource from JNDI(CRM Project) Successfully.") ;
			}catch (NamingException e) {
				System.out.println("--->Naming Exception :"+e.toString());
				e.printStackTrace();
			}catch (Exception e) {
				// TODO Auto-generated catch block
				System.out.println("--->Exception :"+e.toString());
				e.printStackTrace();
			}			
			return connJNDI;
		} else {
			//db-name:lan
			//Server-name:onnetimp
			//port :1530
			//iFxHost:132.146.1.2
			//user:bck
			//pwd:bck
			//onnetimp;user=bck;password=bck	
			//jdbc:informix-sqli://132.146.1.2:1530/lan:INFORMIXSERVER=onnetimp
			try{
				 System.out.println("Connection Normal JDBC?");
				 //jdbc:informix-sqli://<HOST>:<PORT>/<DB>:INFORMIXSERVER=<SERVER_NAME>
				 String conStr = "jdbc:informix-sqli://" + host + ":" + port + "/" +dns+":INFORMIXSERVER="+schemaName+";user="+user+";password="+password;
				 System.out.println("ConnURL :"+conStr);
				 //jdbc:informix-sqli://123.45.67.89:1533/testDB:INFORMIXSERVER=myserver;user=rdtest;password=test
				 //DB2 DriverManager.registerDriver(new DB2Driver());
				 Class.forName("com.informix.jdbc.IfxDriver");
				// Connection connJDBC = DriverManager.getConnection(conStr, user, password);
				 Connection jConn = DriverManager.getConnection(conStr);
				 System.out.println("--->Connecting successfully.");
				 return jConn;
			}catch(ClassNotFoundException e){
				System.out.println("--->>ClassNotFoundException :"+e.toString());
				return null;
			}
			catch(SQLException e){
				System.out.println("--->>SQLException :"+e.toString());
				return null;
			}
		}
	}
	
	public static void defaultTransaction(Connection conn) throws SQLException {
		conn.setAutoCommit(true);	
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);//informix
	}
	
	public static void beginTransaction(Connection conn) throws SQLException {
		conn.setAutoCommit(false);
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		//for db2conn.setTransactionIsolation(Connection.TRANSACTION_REPEATABLE_READ);
	}

	public static void rollbackTransaction(Connection conn) {
		try {
			if (conn != null) {
				conn.rollback();
				
				conn.setAutoCommit(true);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public static void commitTransaction(Connection conn) {
		try {
			if (conn != null) {
				conn.commit();
				
				conn.setAutoCommit(true);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public static Statement getStatement(Connection conn) {
		try {
			return conn.createStatement();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
	}

	public static void close(Connection conn) {
		try {
			if (conn != null) {
				conn.close();

			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally{
			conn = null;
		}
	}
	public static void close(PreparedStatement pstmt,ResultSet rs,Connection conn){
		try {
			if (rs != null) {
				try{
					rs.close();
				}
				catch(SQLException e){}
			}
			if (pstmt != null){
				try{
					pstmt.close();
				}
				catch(SQLException e){}
				
			}
			if(conn!=null){
				try{
					conn.close();
				}
				catch(SQLException  e){}
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		finally{
			rs= null;
			pstmt= null;
			conn = null;
		}
	}
	public static void close(Statement stmt, ResultSet rs) {
		try {
			if (rs != null) {
				try{
					rs.close();
				}
				catch(SQLException e){}
			}
			if (stmt != null) {
				try{
					stmt.close();
				}
				catch(SQLException e){}
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		finally{
			rs = null;
			stmt = null;
		}
	}

//	 TODO::Remove later
	public static void close(PreparedStatement pstmt, ResultSet rs) {
		try {
			if (rs != null) {
				try{
					rs.close();
				}
				catch (SQLException e) {}
			}
			if (pstmt != null) {
				try{
					pstmt.close();
				}catch (SQLException e) {}
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		finally{
			rs = null;
			pstmt = null;
		}
	}

	// TODO::Remove later
	public static void close(Connection conn, Statement stmt, ResultSet rs) {
		try {
			if (rs != null) {
				rs.close();
			}
			if (stmt != null) {
				stmt.close();
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	
	public static Connection GetConnMyCd() {
		String host = "132.146.1.88";
		String port = "3306";
		String dns = "cdrom_system";
		//String schemaName = "onnetimp";
		String user = "lhcdrom"; //testlan_db
		String password = "lhcdrom!@#";
		try{
			 System.out.println("--->> MySQL use Connection Normal JDBC?");
			 //DB2 String conStr = "jdbc:db2://" + host + ":" + port + "/" + dns;
			 //String conStr = "jdbc:mysql://localhost:3360/db_person";
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
			System.out.println("--->>ClassNotFoundException :"+e.toString());
			return null;
		}
		catch(SQLException e){
			System.out.println("--->>SQLException :"+e.toString());
			return null;
		}
	}

}
