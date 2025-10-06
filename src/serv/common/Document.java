package serv.common;

/**
 * Insert the type's description here.
 * Creation date: (30/5/2002 16:38:20)
 * @author: Administrator
 */
import java.io.*;
import java.util.*;
import java.sql.*;

import javax.sql.*;
import javax.naming.*;

public class Document {

/**
 * Document constructor comment.
 */
public Document() {
}
public static synchronized int getDocNo(String comId, String projId, String type, String year) throws Exception {
	int docNo = 0;
	boolean match = false;
	int rowEffected = 0;
	
	Context initCtx, env;
	String dsName = null;
	String subcontext = "java:comp/env";
	DataSource ds = null;
	
	Connection conn = null;
    Statement docstmt = null;
    ResultSet rsDocument = null;
    
	try {
		initCtx = new InitialContext();
		env = (Context)initCtx.lookup(subcontext);
		dsName = (String)env.lookup("DATASOURCE_NAME");
		dsName = subcontext + "/" + dsName;
		ds = (DataSource) initCtx.lookup(dsName);
	} catch (NamingException ne) {throw ne;}
	
    
    try {
		if (ds != null) {
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
		}
	    
	    docstmt = conn.createStatement();
	    
	    match = false;
	    String where = "i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_doc_type = '"+type+"' AND d_year = '"+year+"'";
	    rsDocument = docstmt.executeQuery("SELECT s_doc FROM lan:serv_cntrl WHERE "+where);
	    if (rsDocument != null) {
		    if (rsDocument.next() == true) {
			    match = true;
			    docNo = rsDocument.getInt("S_DOC");
			    docstmt.executeUpdate("UPDATE lan:serv_cntrl SET s_doc = s_doc + 1 WHERE "+where);
		    }
	    }
	    if (!match) {
			rowEffected = docstmt.executeUpdate("INSERT INTO lan:serv_cntrl(i_company, i_project, i_doc_type, d_year, s_doc) VALUES('"+comId+"', '"+projId+"', '"+type+"', '"+year+"', 2)");
			if (rowEffected != 1) {
				throw new Exception("ERROR : SERV_CNTRL wrong insert count");
			}
			docNo = 1;
	    }
		docstmt.close();
		conn.close();
		docstmt = null;
		conn = null;
    } catch (Exception e) {
	    throw e;
    } finally {
	    if (rsDocument != null)
	    	rsDocument.close();
		if (docstmt != null)
			docstmt.close();
		if (conn != null)
			conn.close();			
    }
	return docNo;
}
}
