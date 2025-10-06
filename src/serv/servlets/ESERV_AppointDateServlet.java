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
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import serv.common.User;
import com.lh.servlet.DBServlet;
import com.lh.util.doString;

/**
 * Servlet implementation class for Servlet: ESERV_AppiontDateServlet
 * create by : pradoem wongkraso
 * date :2012.06.25
 * version : 1.0
 * Last Update : 2013.10.15
 * description : this is class for manage master data appiont date for E-Service System bettween  customer (frontEnd) && 
 * user  service  (blackEnd)
 * 
 */
 public class ESERV_AppointDateServlet extends  DBServlet{
    /* (non-Java-doc)
	 * @see javax.servlet.http.HttpServlet#HttpServlet()
	 */
	public ESERV_AppointDateServlet() {
		super();
	}   	
	
	static String host = "132.144.1.61";
	//host = "www10.lh.co.th";
	static String port = "3306";
	static String dns = "LH_LineService";
	//String schemaName = "onnetimp";
	static String user = "lineapp_db"; //testlan_db
	static String password = "xsw21qaz";
	//password = "7cQ3VxNMHo2L";
	
	String sysName = "LHServ";
	String cName = new String(this.getClass().getName() + ".performTask :");	
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
			  }else if(command.equals("loadTime")){
				  this.doFormLoadTime(request,response,user);  
			  }else if(command.equals("formSubmit")){
				  this.doInsertTempTable(request, response, user);
			  }else if(command.equals("delete")){
				  this.doDeleteTempTable(request, response, user);
			  }else if(command.equals("save")){
				  this.doSave2ESerDate(request, response, user);
			  }
		}catch(Exception e){
			e.printStackTrace();
			System.out.println(sysName+":"+cName +" "+e.toString());		
		}
	} 	
	//*****	method FormLoad criteria projectDDL
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
   	 	
		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
        try{     	
        	 //System.out.println("formLoad ->Starting."); 
        	
        	 GetParamRQ(request);
        	 String mode = request.getParameter("mode")==null?"":request.getParameter("mode");    
        	 String projectNameThai = request.getParameter("projectNameThai")==null?"":request.getParameter("projectNameThai");    
        	 if(mode.equals("add")){
        		 
    	   		 String tarGetUrl ="/ESERV_Appoint_Date.jsp?mode=add&projectNameThai="+projectNameThai;
    	   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
    			 dispatcher.forward(request,response);	
        	 }else{       		 
		       	  synchronized(session) { 		
			    	//Clear session First step process
			    	session.removeAttribute("projectDDL");
			    	session.removeAttribute("timeHD");
			    	session.removeAttribute("timeList");
			    	session.removeAttribute("selProj");
			    	session.removeAttribute("ss_list_sys_type");
		  		  }
		       	  
		       	 List projectDDL = new ArrayList();
            	 List   strList = null;
    			//Open connection
    			if (ds == null){getDS();}			
    			conn = ds.getConnection();
    			conn.setAutoCommit(false);
    			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
    			  //******************************************
		       	  sql.delete(0, sql.length());
		       	  sql.append(" select count(*) as row  from lan:eser_temp_date where user_id = ? ");
			      pstmt = conn.prepareStatement(sql.toString()); 
	    		  pstmt.setString(1, user.getUserID());	
	    		  rs = pstmt.executeQuery();
	    		  int row = 0;
	    		  if(rs.next()){
	    			  row = rs.getInt("row");
	    		  }
	    		  
	    		  if(row>0){
	    			   sql.delete(0, sql.length());     
				 		sql.append(" delete from lan:eser_temp_date where user_id = ? ");
				 		pstmt = conn.prepareStatement(sql.toString()); 
				 		pstmt.setString(1, user.getUserID());
				 		int ex = pstmt.executeUpdate(); 
	    		  }
		 		  conn.commit();
		 		  conn.setAutoCommit(true);	
		       	//*****************************************

    			/****************************projectDLL****************************************/
    			sql.delete(0, sql.length());
    			sql.append("SELECT user_id,com_id,proj_id  FROM lan:serv_pstaff WHERE user_id = ? AND com_id = 'LH' AND proj_id = 'ALL' ");
    			pstmt = conn.prepareStatement(sql.toString()); 
    			pstmt.setString(1, user.getUserID());			
    			rs = pstmt.executeQuery();			
    			//*******************************For Viewer************************************//
    			sql.delete(0, sql.length());
    			if (rs.next()) {
    				sql.append("SELECT DISTINCT proj.i_company, proj.i_project, proj.n_project")
    					.append(" FROM lan:acxprojt proj, lan:acsbudgh bud")
    					.append(" WHERE bud.i_company = proj.i_company AND bud.i_project = proj.i_project")
    					.append(" AND bud.d_year = '")
    					.append(cur_year)
    					.append("' ORDER BY proj.i_company, proj.i_project ");
    			} else {
    				sql.append("SELECT b.i_company, b.i_project, b.n_project ")
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
    			 request.setAttribute("codeDDL", request.getParameter("sysTypeDDL")==null?"":request.getParameter("sysTypeDDL"));	
    			 session.setAttribute("ss_list_sys_type", ListHashSysType(conn));

    	   		 //*********Dispatcher
    		  	 session.setAttribute("projectDDL", projectDDL);
    		  	 request.setAttribute("selProj", null);	
            	 //System.out.println("formLoad ->successfully.");	  	
    	   		 String tarGetUrl ="/ESERV_Appoint_Date.jsp";
    	   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
    			 dispatcher.forward(request,response);	
        	 }
		}catch(Exception e){

			System.err.println("!!! doFormLoad , " +sysName+":"+ cName + " : " + e.getMessage());
			System.err.println("!!! SQL Exception: "+sql.toString());		
			msgTxt = "doFormSearch , " +sysName+":"+ cName + " : " + e.getMessage();
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
	
   //*****	method FormLoadTime criteria By projectDDL
	protected void doFormLoadTime(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;	
		StringBuffer sql = new StringBuffer();			
		ServletContext context = getServletContext();
		//GetParamRQ(request);		
		HttpSession session = request.getSession(false);		
		
		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
        try{
        	     	 
       	 	List timeList = new ArrayList();
       	 	List   strList = null;
       	 	boolean isFetch = true;
        	String projDDL = request.getParameter("projectDDL")==null?"":request.getParameter("projectDDL");  

        	request.setAttribute("codeDDL", request.getParameter("sysTypeDDL")==null?"":request.getParameter("sysTypeDDL"));	
        	
        	
        	
        	 //System.out.println("doFormLoadTime ->Starting.");        	 
        	 //****************************
 			String delimiter = ":";
			String [] tempDDL = new String[2];
			tempDDL[0] = "";
			tempDDL[1] = "";
			if(projDDL.trim().length()>0){	
				tempDDL = projDDL.split(delimiter);
			}
        	 //****************************
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			//conn.setAutoCommit(false);	
			/********************************************************************/			
			sql.delete(0, sql.length());
			sql.append(" select q_apptime_fr1 from lan:eser_time  where i_company = ? and i_project = ? order by q_apptime_fr1 ");
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1,tempDDL[0]);	//com	
			pstmt.setString(2, tempDDL[1]); //proj			
			rs = pstmt.executeQuery();			
			//*******************************For Viewer**************************//
			if (rs.next()) {				
				isFetch = false;
			} else {
				isFetch = true;
			}		
			System.out.println(" == isFetch :"+isFetch);
			if(isFetch){						
				sql.delete(0, sql.length());
				sql.append(" select q_apptime_fr1 from lan:eser_time  where i_company = 'LH' and i_project = '099' order by q_apptime_fr1 ");
				pstmt = conn.prepareStatement(sql.toString()); 
				rs = pstmt.executeQuery();
			}else{
				rs = pstmt.executeQuery();	
			}	
			int i = 0;			
			while(rs.next()){
					strList =  new ArrayList(); 
					//strList.add(0,  doString.checkString(rs.getString("i_company"),""));
					strList.add(0,  doString.checkString(rs.getString("q_apptime_fr1"),""));
					timeList.add(strList);
					i++;
			}
			rs.close();				
			//coppy List to Array
			String []timeHD = new String[i];			
			List arrList = new ArrayList();
			
			if(timeList!=null && timeList.size()>0){
		        Iterator it = timeList.iterator();
		        i = 0;
		        while(it.hasNext()){								
				  	arrList =(ArrayList)it.next();
				  	timeHD [i++] = arrList.get(0).toString();			  	 
		        }   
			}			
			//**********************************************************************/							
	   		 //*********Dispatcher*****
			 session.setAttribute("ss_list_sys_type", ListHashSysType(conn));
	         session.setAttribute("timeHD", timeHD);
		  	 session.setAttribute("timeList", timeList);
		  	 session.setAttribute("selProj", projDDL);		  	 
		  	//System.out.println("doFormLoadTime ->successfully.");	  	
	   		 String tarGetUrl ="/ESERV_Appoint_Date.jsp";
	   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			 dispatcher.forward(request,response);			
		}catch(Exception e){
			/*System.out.println("doFormLoadTime , " +sysName+":"+ cName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
			//Dispat to Error message page
			// String ERROR_PAGE = "/MsgSuccessPage.jsp?msg="+e.getMessage()+"&error=1&url=/SALE_ContractFur.jsp";
			String ERROR_PAGE = "/errorPage.jsp";
			RequestDispatcher dispatcher = context.getRequestDispatcher(ERROR_PAGE);
			dispatcher.forward(request,response);*/
			
			
			System.err.println("!!! doFormLoadTime , " +sysName+":"+ cName + " : " + e.getMessage());
			System.err.println("!!! SQL Exception: "+sql.toString());		
			msgTxt = "doFormLoadTime , " +sysName+":"+ cName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
			
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
	
	protected void doInsertTempTable(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		PreparedStatement pstmt = null;
		PreparedStatement pstmtInt = null;
		ResultSet rs = null;	
		StringBuffer sql = new StringBuffer();	
		StringBuffer sql2 = new StringBuffer();		
		ServletContext context = getServletContext();
		//HttpSession session = request.getSession(false);
		//GetParamRQ(request);		
		
		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
		
        try{   
        	 	//Open connection
	 			if (ds == null){getDS();}			
	 			conn = ds.getConnection();
	 			conn.setAutoCommit(false);
	 			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	 			//*****************************************************************
	        	 //2.Get parameter
	        	 String selectedDate = request.getParameter("MrnList")==null?"":request.getParameter("MrnList"); //date List 18/07/2555 \n 
	        	 //String projDDL = request.getParameter("projectDDL"); //AR:002
	        	 String projDDL = request.getParameter("projectDDL")==null?"":request.getParameter("projectDDL");   
	        	 
	        	 String codeDDL = request.getParameter("sysTypeDDL")==null?"":request.getParameter("sysTypeDDL");
	        	 request.setAttribute("codeDDL", codeDDL);	

	        	 String projectNameThai = request.getParameter("projectNameThai")==null?"" :request.getParameter("projectNameThai");	        	 
	        	 //For get Parameter from Check box
	        	 String timeChecked [] = request.getParameterValues("timeChecked");   

	 			 //String delimiterProj = ":";
	 			// String [] projId = projDDL.split(delimiterProj); 
				String delimiterProj = ":";
	 			String [] projId = new String[2];
				projId[0] = "";
				projId[1] = "";
				if(projDDL.trim().length()>0){	
					projId = projDDL.split(delimiterProj);
				}
	 			 //*******************************************************
	        	 //****************************************************
	        	 //Split value 12/06/2555 \n15/07/2555
	        	 String delimiter = "\n";
	 			 String [] selectedDateArr = selectedDate.split(delimiter); 

	 			 //******************************************************
	 			 ArrayList tempArr = new ArrayList();
	 			 ArrayList tempList = new ArrayList();
            	 //standard format = AR:031|29/06/2555|10:00
	 			 if(selectedDateArr!=null && selectedDateArr.length>0
	 					 && timeChecked!=null && timeChecked .length>0){
		 	      	 for(int c = 0;c<selectedDateArr.length;c++){
	 			 	      	for(int i= 0;i<timeChecked.length;i++){
		 			 	      	tempArr =  new ArrayList<String>(); 
		 				 	    tempArr.add(0,projId[0]);//icom
		 	 	    			tempArr.add(1,projId[1]);//proj
		 	 			 	    tempArr.add(2,ThaiDate2EngDate(selectedDateArr[c].toString().trim()));//date format input 29/06/2555 out 2012-06-29	
		 				 	    tempArr.add(3,timeChecked[i].trim());	
		 				 	    tempArr.add(4,doString.checkString(request.getParameter(timeChecked[i]),""));				 	      	
		 				 	    tempList.add(tempArr);	  
	 				 	 }					
			      	}
	 			 }
 		 	      	      	 
		 		sql.delete(0, sql.length());     
		 		sql.append(" select count(*) as no from lan:eser_temp_date where user_id=? and i_company = ? and i_project = ? and i_date= ? and q_apptime_fr1 = ? and i_type = ? ");	            	 
	            
		 		sql2.delete(0, sql2.length());
	            sql2.append(" INSERT INTO lan:eser_temp_date (user_id,i_company, i_project, i_date, q_apptime_fr1,i_type) ") 
	            	 .append(" VALUES (?,?, ?, ?, ?,?)");  	             
	             if(tempList!=null && tempList.size()>0){ 
	            	//---check duplicate insert
	            	List strList = new ArrayList();
			        Iterator it = tempList.iterator();	
			       // int x = 1;
			        pstmtInt = conn.prepareStatement(sql2.toString()); 
				    while(it.hasNext()){
					    	 int c = 1;
					    	 int recNo = 0;				    	 
					    	 strList =(ArrayList)it.next();//Object case					    	 
			            	 pstmt = conn.prepareStatement(sql.toString()); 
			            	 pstmt.setString(c++,user.getUserID()); //user_id
			     			 pstmt.setString(c++,strList.get(0).toString());//icom	
			     			 pstmt.setString(c++,strList.get(1).toString());//iproj		     			 
			     			 pstmt.setString(c++,strList.get(2).toString());//date	 29/06/2555 format 2555-06-29
			     			 pstmt.setString(c++, strList.get(3).toString());//time
			     			 pstmt.setString(c++, codeDDL);//Type
			     			 rs = pstmt.executeQuery();		     			 
			     			 //---check duplicate insert
	     	     			if (rs.next()) {				
	     	     				recNo = rs.getInt("no");
	     	     			} 	     	
	     	     			if(recNo==0){
	     	     			//*******Not duplicate go insert into
	     	     				c = 1;
	     	     				//pstmtInt = conn.prepareStatement(sql2.toString()); 
	     	     				pstmtInt.setString(c++,user.getUserID());//user_id	
	     	     				pstmtInt.setString(c++,strList.get(0).toString());//icom	
	     	     				pstmtInt.setString(c++,strList.get(1).toString());//iproj		     			 
	     	     				pstmtInt.setString(c++,strList.get(2).toString());//date	 29/06/2555 format 2555-06-29
	     	     				pstmtInt.setString(c++, strList.get(3).toString());//time  
	     	     				pstmtInt.setString(c++, codeDDL);//type  01=e-Service,02=ServiceCenter 
	    		     			//int countRow =  pstmt.executeUpdate(); 
	    		     			pstmtInt.addBatch();
	     	     			}
				    } 
				    pstmtInt.executeBatch();
	             }
	 			 /********************************************************************/		
	 			 conn.commit();
	 			 conn.setAutoCommit(true);	 			 
	 			 
	 			ArrayList dayList = new ArrayList();
	 			sql.delete(0, sql.length());     
		 		sql.append(" select UNIQUE i_date from lan:eser_temp_date where user_id = ? and i_company = ? and i_project = ? order by i_date  ");
		 		pstmt = conn.prepareStatement(sql.toString());
		 		pstmt.setString(1,user.getUserID());
		 		pstmt.setString(2,projId[0]);
		 		pstmt.setString(3,projId[1]);
		 		rs = pstmt.executeQuery();
		 		while(rs.next()){
		 			dayList.add(doString.checkString(rs.getString("i_date"),""));
		 		}		 	
				//****************Dispatcher**********************************************/
			  	request.setAttribute("daysList",dayList);
			  	request.setAttribute("projectNameThai", doString.DisplayThai(projectNameThai));		  	 	
			  	request.setAttribute("selProj", projDDL);				  	
			  	//System.out.println("doPut2Session ->successfully.");	  	
		   		String tarGetUrl ="/ESERV_Appoint_Disp.jsp";
		   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
				dispatcher.forward(request,response);			
		}catch(Exception e){
			try{
				conn.rollback();
			}catch(Exception ex){}		
			
			System.err.println("!!! doInsertTempTable , " +sysName+":"+ cName + " : " + e.getMessage());
			System.err.println("!!! SQL Exception: "+sql.toString());		
			msgTxt = "doInsertTempTable , " +sysName+":"+ cName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
		}
		finally{			
			//clean up.
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
				if(pstmtInt!=null){pstmtInt.close();}
				if(conn!=null){conn.close();}
			}catch(Exception e){}
		}
	} 
	
	//--->method insert into table ESER_DATE
	//--->criteria of insert value
	//--->clean up session all 
	protected void doSave2ESerDate(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		PreparedStatement pstmt = null;
		PreparedStatement pstmtInt = null;
		ResultSet rs = null;	
		StringBuffer sql = new StringBuffer();
		StringBuffer sqlQue = new StringBuffer();
		ServletContext context = getServletContext();
		HttpSession session = request.getSession(false);		
		//GetParamRQ(request);		
		
		/************************************************
		 * For MySQL 
		 * **********************************************/
		Connection myConn = null;
		//Connection infxConn = null;
		StringBuffer mySqlInsert = new StringBuffer();
		PreparedStatement myPstmt = null;
		//ResultSet rs = null;
		
		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
        try{ 
        	
        	GetParamRQ(request);
        	
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

			
        	 System.out.println("doSave2ESerDate ->Starting."); 
        	 //2.Get parameter
        	 String []arrCheckList = request.getParameterValues("timeChk");
        	

        	 String  codeDDL= request.getParameter("sysTypeDDL")==null?"":request.getParameter("sysTypeDDL"); //AR:002
        	 request.setAttribute("codeDDL", codeDDL);	
        	 String projDDL = request.getParameter("projectDDL")==null?"":request.getParameter("projectDDL"); //AR:002
        	 //****************
        	 String [] projId = projDDL.split(":");
        	 //****************      	 
        	 boolean isDup = false;  		 
    		 StringBuffer messageBox = new StringBuffer();   	 
        	 if(arrCheckList!=null && arrCheckList.length>0){ 
        		 /***************************/
        		 /*Check duplicate in table ESerDate
        		  * if duplicate == true then  SKIP (don't insert into)
        		  * else  insert into table EserDate with  icom,iproj,date,time
        		  * end if
        		  * */	     	         	 
            	 sqlQue.delete(0, sqlQue.length());     
            	 sqlQue.append(" select count(*) as no from lan:eser_date where i_company = ? and i_project = ?  and i_date= ? and q_apptime_fr1 = ? and i_date_type = ? ");        	 
            	 
            	 sql.delete(0, sql.length());
            	 sql.append(" INSERT INTO lan:eser_date (i_company, i_project, i_date, q_apptime_fr1, ") 
            	 	.append(" q_apptime_to1, i_eser_docno, i_comment, f_cancel, d_cancel, i_employ_can, i_employ_add, d_create,i_date_type) ")
            	 	.append(" VALUES (?, ?, ?, ?, null, null, null, null, null, null, ?, current,?) ");          	
            	 
            	 //---------------------------------------------------------
            	 if("02".equals(codeDDL)){ //for LINE and SVC1198
	            	 mySqlInsert.delete(0, mySqlInsert.length());
	            	 mySqlInsert.append(" INSERT INTO `lser_date` (`i_company`, `i_project`, `i_date`, `i_time`, `i_docno`) ") 
	            	 			.append(" VALUES  (?, ?, ?, ?, '' ) ") ;
	            	 myPstmt = myConn.prepareStatement(mySqlInsert.toString());
            	 }
            	 //.append(" VALUES  ('NE', '404', '2019-11-22', '14:30:00', 'L-NE-404-620009'); ") ;
            	 //---------------------------------------------------------

            	 //AR:031|29/06/2555|10:00
            	 String delimiter = "\\|";
        		 int recNo = 0;
        		 int c = 1;
        		 int x = 1;
        		 String [] temp = null;
        		 // format  2012-07-28|15:00
        		 pstmtInt = conn.prepareStatement(sql.toString()); 
        		 for(int loop =0;loop<arrCheckList.length;loop++){
 
        			 recNo = 0;
        			 c = 1;
        			 x = 1;
        			 /**************split*****************/
        			 temp = arrCheckList[loop].split(delimiter); //0=2012-07-28,time ,15:00,01 or 02	        		      			 
        			 pstmt = conn.prepareStatement(sqlQue.toString()); 
	     			 pstmt.setString(c++,projId[0]);//icom	
	     			 pstmt.setString(c++, projId[1]);//iproj		     			 
	     			 pstmt.setString(c++,temp[0]);//date	 29/06/2555 format 2555-06-29
	     			 pstmt.setString(c++, temp[1]);//time	
	     			 pstmt.setString(c++, codeDDL);//i_date_type 01,02,03,04,05
	     			 rs = pstmt.executeQuery();		     			 
	     			//*********************************************************//
	     			if (rs.next()) {				
	     				recNo = rs.getInt("no");
	     			} 	     			
	     			//************Not duplicate go insert into
	     			if(recNo==0){
	     				 c = 1;
	     				 //pstmtInt = conn.prepareStatement(sql.toString()); 
	     				 pstmtInt.setString(c++,projId[0]);//icom	
	     				 pstmtInt.setString(c++, projId[1]);//iproj		     			 	     			 
	     				 pstmtInt.setString(c++, temp[0]);//date	 29/06/2555 format 2555-06-29
	     				 pstmtInt.setString(c++, temp[1]);//time
	     				 pstmtInt.setString(c++, user.getUserID()); //id	
	     				 pstmtInt.setString(c++, codeDDL);//i_type 01:e-Service,02:ServiceCenter // temp[2]
		     			 pstmtInt.addBatch();
		     			 System.out.println("-->infomix ++addBatch ");
		     			 //int countRow =  pstmt.executeUpdate(); 
		     			 //***************************************
		     			 if("02".equals(codeDDL)){ //for LINE and SVC1198
			     			 x = 1;
			     			 myPstmt.setString(x++,projId[0]);
			     			 myPstmt.setString(x++,projId[1]);
			     			 myPstmt.setString(x++,temp[0]);
			     			 myPstmt.setString(x++,temp[1]+":00");
			     			 myPstmt.addBatch();
			     			 System.out.println("-->MySQL ++addBatch ");
			     			 //myPstmt.executeUpdate();
			     			 //System.out.println("-->MySQL ++executeUpdate ");
			     			 //***************************************	  
		     			 }
   			 
	     			}else{	
	     				//duplicate set message error
	     				messageBox.append(arrCheckList[loop]+"<br>");
	     				isDup = true;
	     			}
        		 }//End FOR	
        		 int infx[] = pstmtInt.executeBatch();
        		 System.out.println("-->EserDate-> pstmtInt.executeBatch : "+infx.length);
        		 
        		 if("02".equals(codeDDL)){ //for LINE and SVC1198
            		 int inmy[] = myPstmt.executeBatch();
            		 System.out.println("-->LserDate-> myPstmt.executeBatch : "+inmy.length);
        		 }

        		 //------------------------------------
        		 //for MySQL Insert table      		 
        		 //------------------------------------	 
        	 }//End check Null arrChecklist
      	     //-----------------------------------------------------------------
        	  sql.delete(0, sql.length());     
		 	  sql.append(" delete from lan:eser_temp_date  ");
		 	  pstmt = conn.prepareStatement(sql.toString()); 
		 	  int ex = pstmt.executeUpdate(); 
	 		  System.out.println("Delete eser_temp_date :successfully.");
        	 /********************************************************************/		
    		  conn.commit();
    		  conn.close();
    		  conn = null;

    		  
    		  myConn.commit();
    		  myConn.close();
    		  myConn = null;
    		  /*********************************/
    		  //clean session
    	  	  synchronized(session) { 		
	    			//Clear session
	    			session.removeAttribute("projectDDL");
	    			session.removeAttribute("timeHD");
	    			session.removeAttribute("timeList");
	    			session.removeAttribute("selProj");	
	    			session.removeAttribute("ss_list_sys_type");	
    		  }
			//****************Dispatcher*****************************************/
    	  	 //other_msg 
    	  	 String msg = "";
    	  	 String tarGetUrl = "";
    	  	  if(isDup){
    	  		  msg = "ข้อมูลที่ต้องการบันทึก ซ้ำกับรายการที่มีอยุ่แล้วมีรายการดังต่อไปนี้<br>"+messageBox.toString();
    	  		  tarGetUrl="/save_ok.jsp?&other_msg="+msg+"&redirect_url=ESERV_Redirect.html";
    	  	  }else{
    	  		  tarGetUrl="/save_ok.jsp?&error=0&redirect_url=ESERV_Redirect.html"; 
    	  	  }   		
	   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			dispatcher.forward(request,response);	
			//System.out.println("doSave2ESerDate ->successfully.");	  	
		}catch(Exception e){
			try{
				conn.rollback();
			}catch(Exception ex){}		

			System.err.println("doSave2ESerDate SQL1 :"+sqlQue.toString());	
			System.err.println("doSave2ESerDate SQL2 :"+sql.toString());	
			System.err.println("doSave2ESerDate , " +sysName+":"+ cName + " : " + e.getMessage());	
			msgTxt = "doPut2Session , " +sysName+":"+ cName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
		}
		finally{			
			//clean up.
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
				if(pstmtInt!=null){pstmtInt.close();}
				if(conn!=null){conn.close();}
				
				if(myPstmt!=null){
					myPstmt.close();
				}
				if(myConn!=null){
					myConn.close();
				}
			}catch(Exception e){}
		}
	}
	
	//method delete session List 
	protected void doDeleteTempTable(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
//		 TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;	
		StringBuffer sql = new StringBuffer();	
		ServletContext context = getServletContext();
		//GetParamRQ(request);		
		
		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
		
		
        try{   
        		//System.out.println("doDeleteTempTable ->Starting."); 
        	 	//Open connection
	 			if (ds == null){getDS();}			
	 			conn = ds.getConnection();
	 			conn.setAutoCommit(false);
	 			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	 			//*****************************************************************
	        	//2.Get parameter
	 			   request.setAttribute("codeDDL", request.getParameter("sysTypeDDL")==null?"":request.getParameter("sysTypeDDL"));	

	 			    String projDDL = request.getParameter("projectDDL")==null?"":request.getParameter("projectDDL"); //AR:002
	 			    String [] projId = projDDL.split(":");
		        	String DateDel = request.getParameter("DateDel")==null?"":request.getParameter("DateDel"); //AR:002
		        	String projectNameThai = request.getParameter("projectNameThai")==null?"" :request.getParameter("projectNameThai");	        	 
		        	//For get Parameter from Check box
		        	sql.delete(0, sql.length());     
			 		sql.append(" delete from lan:eser_temp_date where user_id = ? and i_date = ? and i_company = ? and i_project = ? ");
			 		pstmt = conn.prepareStatement(sql.toString()); 
			 		//System.out.println("--->>SQL :"+sql.toString());
			 		pstmt.setString(1, user.getUserID());
			 		pstmt.setString(2, DateDel);
			 		pstmt.setString(3, projId[0]);
			 		pstmt.setString(4, projId[1]);
			 		int ex = pstmt.executeUpdate(); 
		 		    //System.out.println("Delete Date :successfully.");
	        	/********************************************************************/		
	 			conn.commit();
	 			conn.setAutoCommit(true);	
	 			
	 			ArrayList dayList = new ArrayList();
	 			sql.delete(0, sql.length());     
		 		sql.append(" select UNIQUE i_date from lan:eser_temp_date where user_id=? and i_company = ? and i_project = ?  order by i_date  ");
		 		pstmt = conn.prepareStatement(sql.toString()); 
		 		pstmt.setString(1, user.getUserID());
		 		pstmt.setString(2, projId[0]);
		 		pstmt.setString(3, projId[1]);
		 		rs = pstmt.executeQuery();
		 		while(rs.next()){
		 			dayList.add(doString.checkString(rs.getString("i_date"),""));
		 		}		 	
				//****************Dispatcher**********************************************/
			  	request.setAttribute("daysList",dayList);
	 			//****************Dispatcher**********************************************/
			  	request.setAttribute("projectNameThai", doString.DisplayThai(projectNameThai));		
			  	request.setAttribute("selProj", projDDL);			  	
			  	//System.out.println("doDeleteTempTable ->successfully.");	  	
		   		String tarGetUrl ="/ESERV_Appoint_Disp.jsp";
		   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
				dispatcher.forward(request,response);			
		}catch(Exception e){
			try{
				conn.rollback();
			}catch(Exception ex){}		

			System.err.println("!!! doDeleteTempTable , " +sysName+":"+ cName + " : " + e.getMessage());
			System.err.println("!!! SQL Exception: "+sql.toString());		
			msgTxt = "doDeleteTempTable , " +sysName+":"+ cName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
			
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
	 
	
     //GET PARAMETER
	 private void GetParamRQ(HttpServletRequest request){
			Enumeration <String> paramName = (Enumeration<String>) request.getParameterNames();
			 while (paramName.hasMoreElements()) {
			            String element = (String) paramName.nextElement();
			            System.out.println(element + " = " + request.getParameter(element));
			        }
	  }
	 
	 private static String ThaiDate2EngDate(String args) throws Exception{  
		    if(!args.equals("")){
				String delimeter = "\\/";
				String [] temp = args.split(delimeter);	
				// return temp[2]+"-"+temp[1]+"-"+ (Integer.parseInt(temp [2])-543);
				 return (Integer.parseInt(temp[2])-543)+"-"+temp[1]+"-"+temp[0];
				 //2012-05-05
			}else{
				 return args;
			}
	 }
	 
		public List<HashMap> ListHashSysType(Connection conn) {
			// TODO Auto-generated method stub
			StringBuffer sql = new StringBuffer();
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			try {
				// initial parameter
				List listData = new ArrayList();
				HashMap<String, String> hashMapData = null;
				/************* List Project for check up ********************/
				sql.delete(0, sql.length());
				sql.append(" select * from lan:serv_xstd where 1=1 and i_type  = '80' and i_code not in ('01','03','05') order by i_code ");
				pstmt = conn.prepareStatement(sql.toString());

				rs = pstmt.executeQuery();
				while (rs.next()) {
					hashMapData = new HashMap<String, String>();
					hashMapData.put("xTYPE", doString.checkString(rs.getString("i_type"), ""));
					hashMapData.put("xCODE", doString.checkString(rs.getString("i_code"), ""));
					hashMapData.put("xNAME", doString.DisplayThai(doString.checkString(rs.getString("n_desc"), "")));
					listData.add(hashMapData);
				}
				rs.close();
				// ********************************************************/
				// System.out.println("ListHashSysType->end.");
				return listData;
			} catch (Exception e) {
				System.out.println("!!! ListHashSysType, " + sysName + " : " + e.getMessage());
				System.out.println("!!! ListHashSysType,SQL Exception: " + sql.toString());
				return null;
			} finally {
				// clean up.
				try {
						if (rs != null) {
							rs.close();
						}
						if (pstmt != null) {
							pstmt.close();
						}
				   } catch (Exception e) {
				}
			}
		}

   	  	    
}
 