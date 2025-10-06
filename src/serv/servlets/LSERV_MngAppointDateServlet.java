
 package serv.servlets;
 import java.io.IOException;
 import java.io.PrintWriter;
 import java.sql.Connection;
import java.sql.DriverManager;
 import java.sql.PreparedStatement;
 import java.sql.ResultSet;
import java.sql.SQLException;
 import java.util.ArrayList;
 import java.util.Calendar;
 import java.util.Enumeration;
 import java.util.List;
 import javax.servlet.RequestDispatcher;
 import javax.servlet.ServletContext;
 import javax.servlet.ServletException;
 import javax.servlet.http.HttpServletRequest;
 import javax.servlet.http.HttpServletResponse;
 import javax.servlet.http.HttpSession;

 import serv.common.Constants;
 import serv.common.User;
 import com.lh.servlet.DBServlet;
import com.lh.util.doString;

 /**
  * Servlet implementation class for Servlet: ESERV_TimingBookServlet
  * create by : pradoem wonkraso
  * date time: 2012-06-29
  * comment: this is clazz for manage Master Data on BackEnd with E-Service krub
  * booking Timing for  check point on the JOB.
  */


 /**
  * Servlet implementation class for Servlet: LSERV_MngAppointDateServlet
  *
  */
  public class LSERV_MngAppointDateServlet extends  DBServlet{
     /* (non-Java-doc)
 	 * @see javax.servlet.http.HttpServlet#HttpServlet()
 	 */
 	public LSERV_MngAppointDateServlet() {
 		super();
 	}   	
 	static String TBL_LSER_DATE = "lser_date";
	static String host = "132.144.1.61";
	//host = "www10.lh.co.th";
	static String port = "3306";
	static String dns = "LH_LineService";
	//String schemaName = "onnetimp";
	static String user = "lineapp_db"; //testlan_db
	static String password = "xsw21qaz";
 	String sysName = "LHServ";
 	String cName = new String(this.getClass().getName() + ".performTask :");	
 	
 	 /*private void genRedirectCode(PrintWriter out,String page,String redirect,String error,String otherMsg) {
 			out.println("<html><body><form method='post' action='"+page+"'>");		
 			out.println("<input type='hidden' name='error' value='"+error+"'>");
 			out.println("<input type='hidden' name='other_msg' value='"+doString.MS874ToUnicode(otherMsg)+"'>");
 			out.println("<input type='hidden' name='redirect_url' value='"+doString.MS874ToUnicode(redirect)+"'>");		
 			out.println("<script> document.forms[0].submit();</script>");
 			out.println("</form></body></html>");		
 	}*/
 	
 	public void performTask(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {	  
 		System.out.println(cName + "start.");
 		response.setContentType("text/html; charset=TIS-620");
 		PrintWriter out = null;
 		
 		/******************Session User Check************************/
 		HttpSession session = request.getSession(false);
 	    if (session == null) {
 	        /** Redirect user to login page if there's no session.*/
 	        response.sendRedirect(request.getContextPath()+"/login.jsp");
 	        return;
 	    }
 	    Object obj = session.getAttribute("USER");
 	    if (obj == null) {
 	    	System.out.println("----->User is null");
 	        /** Redirect user to login page if there's no session.*/
 	        response.sendRedirect(request.getContextPath()+"/login.jsp");
 	        return;
 	    }		    
 		User user = (User) obj;	
 		/******************Session User Check************************/
 		/*****************
 		 * medthod action
 		 **************** */
 		try{
 			  String  command = request.getParameter("cmd")==null?"":request.getParameter("cmd");					
 			  if(command.equals("formLoad")){		
 				  this.doFormLoad(request,response,user);				
 			  }else if(command.equals("search")){
 				  this.doFormSearch(request,response,user);  
 			  }else if(command.equals("delete")){
 				  this.doDeleteLSerDate(request, response, user);
 			  }
 		}catch(Exception e){
 			e.printStackTrace();
 			System.out.println(sysName+":"+cName +" "+e.toString());		
 		}
 	}

// 	*****	method doFormSearch criteria projectDDL
 	protected void doFormSearch(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
 		// TODO Auto-generated method stub
 		response.setContentType("text/html; charset=TIS-620");
 		Connection conn = null;
 		PreparedStatement pstmt = null;
 		ResultSet rs = null;
 		ResultSet rs2 = null;
 		ResultSet rs3 = null;
 		ResultSet rs4 = null;
 		StringBuffer sql = new StringBuffer();	
 		StringBuffer sql2 = new StringBuffer();
 		StringBuffer sql3 = new StringBuffer();

 		ServletContext context = getServletContext();
 		HttpSession session = request.getSession(false);
 		//*********CurrentDate Time
    	 	//Calendar rightNow = Calendar.getInstance();
    	 	//String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
 		//GetParamRQ(request);
 		String projDDL = request.getParameter("projectDDL"); //format : AR:002  
 		
 		//String savePage = Constants.SAVE_PAGE;	
 		String msgTxt = "";// Constants.APP_PATH+Constants.SAVE_PAGE;
 		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	

 		
         try{
   	
         	//System.out.println("doFormSearch ->Starting.");       	        	
         	String  comId = "";
         	String proejId = "";

         	if(!"".equals(projDDL)){
         		String tempId[] = projDDL.split("\\:"); //icom,iproj
         		comId = tempId[0];
         		proejId = tempId[1];
         	}else{
     			System.out.println("!!! doFormSearch : Please seelct company & project  on Dropdown List. ");	
     			msgTxt = "doFormSearch  : projectDDL is null or Empty ,Please select company&project  on Dropdown List ";
     			response.sendRedirect(ERROR_PAGE+msgTxt);
     			return;
         	}
 	
         	String fday = request.getParameter("dayDDL1");
         	String fmm = request.getParameter("mmDDL1");
         	String fyy = request.getParameter("yyDDL1")==null?"0":request.getParameter("yyDDL1");
         	String tday = request.getParameter("dayDDL2");
         	String tmm = request.getParameter("mmDDL2");
         	String tyy = request.getParameter("yyDDL2")==null?"0":request.getParameter("yyDDL2");
         	
         	String fromDate = fyy+"-"+fmm+"-"+fday;
         	String toDate =   tyy+"-"+tmm+"-"+tday;
         	//String tempFdate = fyy+"-"+fmm+"-"+fday;
         	//String tempTdate = tyy+"-"+tmm+"-"+tday;
         	
         	List resultList = new ArrayList();
 			//Open connection
 			if (ds == null){getDS();}			
 			conn = ds.getConnection();
 			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
 			//conn.setAutoCommit(false);	

 			/****************************1.i_eser_docno is not null ***************************************/
 			sql.delete(0, sql.length());
 			sql.append("Select i_date,q_apptime_fr1,i_eser_docno,i_date_type,i_system From lan:"+TBL_LSER_DATE+" where i_company  = ? and i_project = ?  ")
 			.append(" and i_date >= ? and i_date <=?   order by i_date "); //and i_eser_docdo is not null   //and i_date >= '2012-07-06' and i_date <='2012-07-08'
 			
 			//System.out.println("SQL :"+sql.toString());
 			
 			pstmt = conn.prepareStatement(sql.toString()); 
 			pstmt.setString(1,comId);	
 			pstmt.setString(2,proejId);
 			pstmt.setString(3, fromDate);
 			pstmt.setString(4, toDate);
 			
 			rs = pstmt.executeQuery();
 			/***********************************/
 			
 			sql2.delete(0, sql2.length());
 			sql2.append(" select  a.i_lock,a.i_house ,a.d_keyin,a.n_customer,a.n_cus_tel,a.f_status,a.i_docno ")			
 				.append(" from lan:eser_dochd a where a.i_eser_docno  = ?  ");

 			boolean isExcute = false;
 			String iSystemId = ""; //01=SVC,11,E-Service,08=IND,10=CUP
 			String docNo = "";			
 			StringBuffer idocNoBuf= new StringBuffer();
 			//StringBuffer idate = new StringBuffer();
 			//StringBuffer itime = new StringBuffer();
 			StringBuffer iDocType = new StringBuffer();
 			ArrayList recordList = null;
 			while(rs.next()){
 				//Get i_date,q_apptime_fr1  true==true   multiple recored
 				recordList = new ArrayList();								
 				recordList.add(0,doString.checkString(rs.getString("i_date"),""));
 				recordList.add(1,doString.checkString(rs.getString("q_apptime_fr1"),""));
 				recordList.add(2,doString.checkString(rs.getString("i_eser_docno"),""));
 				
 				isExcute = false;
 				iSystemId = ""; //01=SVC,11,E-Service,08=IND,10=CUP
 				iSystemId = doString.checkString(rs.getString("i_system"),"");
 				idocNoBuf.delete(0, idocNoBuf.length());
 				idocNoBuf.append(doString.checkString(rs.getString("i_eser_docno"),""));
 				
 				recordList.add(3,"");
 				recordList.add(4,"");
 				recordList.add(5,"");
 				recordList.add(6,"");
 				recordList.add(7,"");
 				recordList.add(8,"");
 				recordList.add(9,"");
 				recordList.add(10,"");
 				recordList.add(11,"");

 				//check iducNo
 				if(!idocNoBuf.toString().equals("")){	
 					    pstmt = conn.prepareStatement(sql2.toString()); 
 						pstmt.setString(1,idocNoBuf.toString());
 						rs2 = pstmt.executeQuery();
 						if(rs2.next()){
 							//Get value
 							recordList.add(3,doString.checkString(rs2.getString("i_lock"),""));
 							recordList.add(4,doString.checkString(rs2.getString("i_house"),""));
 							recordList.add(5,doString.checkString(rs2.getString("d_keyin"),""));
 							recordList.add(6,doString.checkString(rs2.getString("n_customer"),""));
 							recordList.add(7,doString.checkString(rs2.getString("n_cus_tel"),""));
 							recordList.add(8,doString.checkString(rs2.getString("f_status"),"")); //svc_dochd  == 001
 							docNo = "";
 							docNo = doString.checkString(rs2.getString("i_docno"),"");
 						}//if(rs2.next())
 					recordList.add(9,"");
 					recordList.add(10,""); //code
 					recordList.add(11,"");//Name										
 				}//if(idocNoBuf.toString() != null)
 				resultList.add(recordList);				
 			 }//while(rs.next())
 											
 	   		 //*********Dispatcher
 		  	// session.setAttribute("projDDL", projDDL);
 		  	 request.setAttribute("resultList", resultList);
 		  	 request.setAttribute("selProj", projDDL);
 		  	 request.setAttribute("fromDate", fromDate);//2555-07-30
 		  	 request.setAttribute("toDate", toDate);
 		  	 
 		  	 //System.out.println("doFormSearch ->successfully.");	  
 		  	 
 	   		 String tarGetUrl ="/LSERV_MngLserDate_List.jsp";
 	   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
 			 dispatcher.forward(request,response);			
 		}catch(Exception e){

 			System.out.println("!!! doFormSearch , " +sysName+":"+ cName + " : " + e.getMessage());	
 			msgTxt = "doFormSearch , " +sysName+":"+ cName + " : " + e.getMessage();
 			response.sendRedirect(ERROR_PAGE+msgTxt);
 			return;
 		}
 		finally{			
 			//clean up.
 			try{
 				if(rs!=null){rs.close();}
 				if(rs2!=null){rs2.close();}
 				if(rs3!=null){rs3.close();}
 				if(rs4!=null){rs4.close();}
 				if(pstmt!=null){pstmt.close();}
 				if(conn!=null){conn.close();}
 			}catch(Exception e){}
 		}
 	} 
 	
 	//doDelete Record eserDate
 	protected void doDeleteLSerDate(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
 		// TODO Auto-generated method stub
 		response.setContentType("text/html; charset=TIS-620");
 		Connection conn = null;
 		PreparedStatement pstmt = null;
 		ResultSet rs = null;	
 		StringBuffer sql = new StringBuffer();
 		StringBuffer mySql = new StringBuffer();
 		ServletContext context = getServletContext();
 		//HttpSession session = request.getSession(false);		
 		
 		Connection myConn = null;
	    PreparedStatement myPstmt = null;
	    ResultSet myRs = null;
 		//String savePage = Constants.SAVE_PAGE;	
 		String msgTxt = "";// Constants.APP_PATH+Constants.SAVE_PAGE;
 		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
         try{     
         	//Open connection
 			if (ds == null){getDS();}			
 			conn = ds.getConnection();
 			conn.setAutoCommit(false);
 			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
 			//*****************************************************************
		    /********** Connection Mysql DB *************/
			myConn = GetConnMysqlJDBC();
			myConn.setAutoCommit(false);
		    /********** Connection Mysql DB *************/

         	//System.out.println("doDeleteESerDate ->Starting."); 
         	String fday = request.getParameter("dayDDL1");
          	String fmm = request.getParameter("mmDDL1");
          	String fyy = request.getParameter("yyDDL1")==null?"0":request.getParameter("yyDDL1");
          	String tday = request.getParameter("dayDDL2");
          	String tmm = request.getParameter("mmDDL2");
          	String tyy = request.getParameter("yyDDL2")==null?"0":request.getParameter("yyDDL2");

         	 //2.Get parameter  AR:002|2555-06-28|12:00  or AR:002|2012-06-28|12:00
         	 String []arrCheckList = request.getParameterValues("chkDel");
         	 String projDDL = request.getParameter("projectDDL"); //format : AR:002    	 
         	
         	 if(arrCheckList!=null && arrCheckList.length>0){ 
         		 /***************************/
             	 sql.delete(0, sql.length());
             	 sql.append(" delete from lan:"+TBL_LSER_DATE)
             	 	.append(" where i_company = ? and i_project = ? and i_date = ? and q_apptime_fr1 = ?");	
             	 //AR:002|2555-06-28|12:00  or AR:002|2012-06-28|12:00
             	 
             	 //---------------------------------             	
             	 mySql.delete(0, mySql.length());
             	 mySql.append(" delete from "+TBL_LSER_DATE)
            	 	 .append(" where i_company = ? and i_project = ? and i_date = ? and i_time = ?");	
             	 
             	 //-----------------------------------
             	 String delimiter = "\\|";
             	 String delimiter2 = ":";//for ID  AR : 031
         		 //int recNo = 0;
         		 int c = 1;
         		 int my = 1;
         		 for(int loop =0;loop<arrCheckList.length;loop++){
         			// recNo = 0;
         			 c = 1;
         			 my = 1;
         			 /**************split*****************/
         			 String [] tempArr  = arrCheckList[loop].split(delimiter);
         			 String [] tempId  = tempArr[0].split(delimiter2);//AR : 031       			      			 
 	        		 pstmt = conn.prepareStatement(sql.toString()); 
 	     			 pstmt.setString(c++,tempId[0]);//icom	
 	     			 pstmt.setString(c++, tempId[1]);//iproj		     			 
 	     			 pstmt.setString(c++,tempArr[1]);//dateformat 2012-06-28
 	     			 pstmt.setString(c++, tempArr[2]);//time  12:00	 	     			 
 	     			 int countRow =  pstmt.executeUpdate(); 
 	     			 System.out.println("-->countRow :"+countRow);
 	     			//*********************************************************//
 	     			 myPstmt = myConn.prepareStatement(mySql.toString()); 
 	     			 myPstmt.setString(my++,tempId[0]);//icom	
 	     			 myPstmt.setString(my++, tempId[1]);//iproj		     			 
 	     			 myPstmt.setString(my++,tempArr[1]);//dateformat 2012-06-28
 	     			 myPstmt.setString(my++, tempArr[2]);//time  12:00	 	     			 
	     			 int countMy =  myPstmt.executeUpdate(); 
	     			 System.out.println("-->countMy :"+countMy);
 	     			 
         		 }//End FOR		
         	 }//End check Null arrChecklist    	     	 
         	 /********************************************************************/		
     		  conn.commit();
     		  conn.setAutoCommit(true);
     		  /*********************************/
		  	  myConn.commit();		  		
			  myConn.close();
			  myConn = null;
 			 //****************Dispatcher*****************************************/ 
  		  	//System.out.println("doDeleteESerDate ->successfully.");	  
  	   		String param = "&dayDDL1="+fday+"&mmDDL1="+fmm+"&yyDDL1="+fyy+"&dayDDL2="+tday+"&&mmDDL2="+tmm+"&yyDDL2="+tyy;
  		  	String tarGetUrl ="/LSERV_MngAppointDateServlet?cmd=search&projectDDL="+projDDL+param;  	   		
 		  	//request.setAttribute("selProj", projDDL);		
  	   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
 			dispatcher.forward(request,response);	  	
 		}catch(Exception e){
 			try{
 				conn.rollback();
 				myConn.rollback();
 			}catch(Exception ex){}		
 			
 			/*System.out.println("doDeleteESerDate SQL2 :"+sql.toString());	
 			System.out.println("doDeleteESerDate , " +sysName+":"+ cName + " : " + e.getMessage());			
 			String ERROR_PAGE = "/errorPage.jsp";
 			RequestDispatcher dispatcher = context.getRequestDispatcher(ERROR_PAGE);
 			dispatcher.forward(request,response);*/
 			System.out.println("!!! doDeleteLSerDate , " +sysName+":"+ cName + " : " + e.getMessage());	
 			msgTxt = "doDeleteESerDate , " +sysName+":"+ cName + " : " + e.getMessage();
 			response.sendRedirect(ERROR_PAGE+msgTxt);
 			return;
 			
 		}
 		finally{			
 			//clean up.
 			try{
 				if(rs!=null){rs.close();}
 				if(pstmt!=null){pstmt.close();}
 				if(conn!=null){conn.close();}
 				//--------------------
 				if(myRs!=null){myRs.close();}
 				if(myPstmt!=null){myPstmt.close();}
 				if(myConn!=null){myConn.close();}
 				System.out.println(" -- Finally --");	
 			}catch(Exception e){}
 		}
 	}
 	
// 	*****	method FormLoad criteria projectDDL
 	protected void doFormLoad(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
 		// TODO Auto-generated method stub
 		response.setContentType("text/html; charset=TIS-620");
 		Connection conn = null;
 		PreparedStatement pstmt = null;
 		ResultSet rs = null;	
 		StringBuffer sql = new StringBuffer();			

 		ServletContext context = getServletContext();
 		HttpSession session = request.getSession(false);
 		//*********CurrentDate Time
    	Calendar rightNow = Calendar.getInstance();
    	String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
    	 	
 		//String savePage = Constants.SAVE_PAGE;	
 		String msgTxt = "";// Constants.APP_PATH+Constants.SAVE_PAGE;
 		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	

         try{
         	
         	 //System.out.println("formLoad ->Starting.");
         	 List projectDDL = new ArrayList();
         	 List   strList = null;
 			//Open connection
 			if (ds == null){getDS();}			
 			conn = ds.getConnection();
 			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
 			//conn.setAutoCommit(false);	

 			/****************************projectDLL****************************************/
 			sql.delete(0, sql.length());
 			sql.append("SELECT user_id,com_id,proj_id  FROM lan:serv_pstaff WHERE user_id = ? AND com_id = 'LH' AND proj_id = 'ALL' ");
 			pstmt = conn.prepareStatement(sql.toString()); 
 			pstmt.setString(1, user.getUserID());			
 			rs = pstmt.executeQuery();
 			
 			//*******************************For Viewer************************************//
 			sql.delete(0, sql.length());
 			if (rs.next()) {
 				sql.delete(0, sql.length());
 				sql.append(" SELECT DISTINCT a.i_company, a.i_project, a.n_project")
 					.append(" FROM lan:acxprojt a, lan:acsbudgh b")
 					.append(" WHERE b.i_company = a.i_company AND b.i_project = a.i_project")
 					.append(" AND b.d_year = '")
 					.append(cur_year)
 					.append("' ORDER BY a.i_company, a.i_project ");
 			} else {
 				sql.delete(0, sql.length());
 				sql.append(" SELECT b.i_company, b.i_project, b.n_project ")
 					.append(" FROM lan:serv_pstaff a, lan:acxprojt b ")
 					.append(" WHERE a.user_id = '")
 					.append(user.getUserID())
 					.append("' AND a.com_id = b.i_company AND a.proj_id = b.i_project ")
 					.append(" ORDER BY b.i_company, b.i_project ");
 			}
 			pstmt = conn.prepareStatement(sql.toString()); 
 			rs = pstmt.executeQuery();
 			while(rs.next()){
 					strList =  new ArrayList(); 
 					strList.add(0,  doString.checkString(rs.getString("i_company"),"")+":"+doString.checkString(rs.getString("i_project"),""));
 					strList.add(1,  doString.checkString(rs.getString("n_project"),""));
 					projectDDL.add(strList);
 					// doString.checkString(doString.DisplayThai(rs.getString("n_customer")),"");
 				}
 			rs.close();				
 			//***************************************************************************/							
 	   		 //*********Dispatcher
 		  	 session.setAttribute("projDDL", projectDDL);
 		  	 request.setAttribute("selProj", null);		  	 
 		  	 //System.out.println("formLoad ->successfully.");	  	
 	   		 String tarGetUrl ="/LSERV_MngLserDate_List.jsp";
 	   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
 			 dispatcher.forward(request,response);			
 		}catch(Exception e){
 			/*System.out.println("doFormLoad , " +sysName+":"+ cName + " : " + e.getMessage());
 			System.out.println(" SQL Exception: "+sql.toString());		
 			//Dispat to Error message page
 			// String ERROR_PAGE = "/MsgSuccessPage.jsp?msg="+e.getMessage()+"&error=1&url=/SALE_ContractFur.jsp";
 			String ERROR_PAGE = "/errorPage.jsp";
 			RequestDispatcher dispatcher = context.getRequestDispatcher(ERROR_PAGE);
 			dispatcher.forward(request,response);*/
 			
 			System.out.println("!!! doFormLoad , " +sysName+":"+ cName + " : " + e.getMessage());	
 			msgTxt = "doFormLoad , " +sysName+":"+ cName + " : " + e.getMessage();
 			response.sendRedirect(ERROR_PAGE+msgTxt);
 			return;
 		}
 		finally{			
 			//clean up.
 			try{
 				if(rs!=null){rs.close();}
 				if(pstmt!=null){pstmt.close();}
 				if(conn!=null){conn.close();}
 			}catch(Exception e){}
 		}
 	}
 	private static Connection GetConnMysqlJDBC() {
		/*String host = "132.144.1.63";
		String port = "3306";
		String dns = "testlan";
		//String schemaName = "onnetimp";
		String user = "testlan_db"; //testlan_db
		String password = "xsw21qaz";*/
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
 	/*private void GetParamRQ(HttpServletRequest request){
 			Enumeration <String> paramName = (Enumeration<String>) request.getParameterNames();
 			 while (paramName.hasMoreElements()) {
 			            String element = (String) paramName.nextElement();
 			            System.out.println(element + " = " + request.getParameter(element));
 			}
 	  }*/
 	
 }