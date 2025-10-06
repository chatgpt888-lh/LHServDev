<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@page import="java.net.*" %>
<%@page import="java.text.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.Constants" %>
<%@ page import="com.svc.call.utilize.*" %> 

<%!
	// Caching the DataSource - It is obtained in the jspInit() method
	private javax.sql.DataSource ds = null;
	private String dsName = Constants.JDBC_LAN;
    String hostName = "http://132.146.1.180:8080"; //lastest:tag
    //String pathUrlX = "https://portal.lh.co.th/AppServ/uploads/";
    //String hostName = "https://portal.lh.co.th"; //lastest:tag

    //String hostName = "http://132.146.4.24:8080";
       
    String URL_ADDRESS = "http://132.146.1.126/LHServ"; //lastest:tag
    //String URL_ADDRESS = "http://132.146.4.24:9080/LHServ";

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
	
	public String getDateFromCalendar(Calendar cal) {
	    String result = "";
	    if (cal==null) return "-";
	    
		int year = cal.get(Calendar.YEAR);
		if (year<2400) year+= 543;
	    doString str = new doString();
	    result = str.createID(cal.get(Calendar.DATE),2);
	    result += "/"+str.createID(cal.get(Calendar.MONTH)+1,2);
	    result += "/"+year;	
			    
		return result;
	}
	
	public String getTimeFromCalendar(Calendar cal) {
	    String result = "";
	    if (cal==null) return "-";

	    doString str = new doString();
	    result = str.createID(cal.get(Calendar.HOUR_OF_DAY),2);
	    result += ":"+str.createID(cal.get(Calendar.MINUTE),2);
			    
		return result;
	}	
	
	public static int getHttpResponseCode(String url) throws Exception {
        URL urlConn = new URL(url);
        URLConnection con = urlConn.openConnection();
        int responseCode = 0;
        try {
            ((HttpURLConnection) con).setConnectTimeout(7 * 1000); // set timeout to 7 seconds
            ((HttpURLConnection) con).setReadTimeout(7 * 1000); // set timeout to 7 seconds
            con.connect();
            responseCode = ((HttpURLConnection) con).getResponseCode();
            return responseCode;
        } catch (Exception cx) {
            System.out.println("!!! con.setConnectTimeout(7*1000) = " + cx.toString());
            return 404;
        }
    }
    
   	public static String nowByCalendar(String dateFormat) {
			Calendar cal = Calendar.getInstance(Locale.ENGLISH);
			SimpleDateFormat sdf = new SimpleDateFormat(dateFormat);
			return sdf.format(cal.getTime());
	}
	
	public String GetDateKeyinYYYYMMDD(Connection conn, String docNo) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String  dKeyin = "";
	    try{
	    	//initial paramter	     	
			/*************************************************/	
			
	    	sql.delete(0,sql.length());
			sql.append(" select date(d_keyin) as ddate from lan:serv_dochd where i_docno =  ? ");
			pstmt = conn.prepareStatement(sql.toString());
			pstmt.setString(1, docNo); //comId
			rs = pstmt.executeQuery();
			if(rs.next()){
				dKeyin = doString.checkString(rs.getString("ddate"), "");
			}
			//2012-08-15
			
			if("".equals(dKeyin)){
				dKeyin = nowByCalendar("yyyy-MM-dd");
			}
			rs.close();	
		}catch(Exception e){
			System.out.println("!!! GetProjectName Error : " + e.getMessage());
		}
		finally{			
			//clean up.
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
			}catch(Exception e){}
		}
	    return dKeyin;		
  }

 
  		
%>
<script src="jquery3/jquery.min3.6.3.js" ></script>
<script src="jquery3/loadingoverlay.min2.1.7.js"></script>
<script>
  function pleaseWaiting(){
   $.LoadingOverlay("show");
	// Hide it after 3 seconds
	setTimeout(function(){
	    $.LoadingOverlay("hide");
	}, 7000);
  }
  function pleaseWaiting2(){
   $.LoadingOverlay("show");
  }
</script>