package serv.servlets;
 import java.io.IOException;
 import java.io.PrintWriter;
 import java.sql.Connection;
 import java.sql.PreparedStatement;
 import java.sql.ResultSet;
 import java.text.DateFormat;
 import java.text.SimpleDateFormat;
 import java.util.ArrayList;
 import java.util.Calendar;
 import java.util.Date;
 import java.util.Enumeration;
import java.util.Iterator;
 import java.util.List;
 import java.util.Locale;
 import javax.servlet.RequestDispatcher;
 import javax.servlet.ServletContext;
 import javax.servlet.ServletException;
 import javax.servlet.http.HttpServletRequest;
 import javax.servlet.http.HttpServletResponse;
 import javax.servlet.http.HttpSession;
 import serv.common.User;
 import com.lh.servlet.DBServlet;
import com.lh.string.doString;

 /**
  * Servlet implementation class for Servlet: SERV_ReportInformRepairServlet
  * create by : pradoem wonkraso ,go2doem@gmail.com, pradoem@lh.co.th
  * date time: 2015.02.27
  * version : 1.0
  * project : Report form  SERV_ReportInformRepairServlet
  * comment:  this class controller servlet for List Report baan transfer
  * check list by user 
  */

  public class SERV_ReportInformRepairServlet extends  DBServlet{
 	    /* (non-Java-doc)
 		 * @see javax.servlet.http.HttpServlet#HttpServlet()
 		 */

 		String thaiMonth[] = new String[] {"มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม",""};
 		String shortMonth[] = new String[] {"ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค.",""};
 	 	
 		String sysName = "LHServ";
 		String clazzName = new String(this.getClass().getName() + ".performTask :");	 
 		public SERV_ReportInformRepairServlet() {
 			super();
 		} 
 		private void GenRedirectForm(PrintWriter out,String page,String redirect,String error,String otherMsg) {
 			out.println("<form method='post' action='"+page+"'>");		
 			out.println("<input type='hidden' name='error' value='"+error+"'>");
 			out.println("<input type='hidden' name='other_msg' value='"+doString.MS874ToUnicode(otherMsg)+"'>");
 			out.println("<input type='hidden' name='redirect_url' value='"+doString.MS874ToUnicode(redirect)+"'>");		
 			out.println("<script> document.forms[0].submit();</script>");
 			out.println("</form>");		
 		}
 		
 		private static void printOutParam(HttpServletRequest request,String msg){
 			String paramNames = "";
 			System.out.println("---------[ Parameter '"+msg+"' List] ------------");
 				for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
 				paramNames = (String)e.nextElement();
 				System.out.println(paramNames+" = "+request.getParameter(paramNames));
 				}		
 				System.out.println("---------- [END Parameter List] --------------");
 		}
 		
 		public void performTask(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {	  
 			System.out.println(clazzName + "start.");
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
 				  if(command.equals("load")){		
 					this.doFormLoad(request,response,user);				
 				  }else if(command.equals("GenReport")){
 					this.doGenReportForm(request,response,user);
 				  }
 			}catch(Exception e){
 				e.printStackTrace();
 				System.out.println(sysName+":"+clazzName +" "+e.toString());		
 			}
 			finally{
 				//out.close();
 			}
 		}
 		
 		//*****	method doFormLoad criteria projectDDL
 		protected void doFormLoad(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
 			// TODO Auto-generated method stub
 			response.setContentType("text/html; charset=TIS-620");
 			Connection conn = null;
 			ServletContext context = getServletContext();
 			HttpSession session = request.getSession(false);		
 			String msgTxt = "";// Constants.APP_PATH+Constants.SAVE_PAGE;
 			String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
 			String errorCode = "99";	
 		
 	        try{
 	        	 //System.out.println("doFormLoad ->Starting.");
 	        	 //printOutParam(request,"doFormLoad");
 	 			//----------Open connection
 				//Open connection
 				if (ds == null){getDS();}			
 				conn = ds.getConnection();
 				conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
 	  			//conn.setAutoCommit(false);
 	            //-------------------------
 					
 	  			ArrayList projectList = this.ListProjectResposible(conn, user.getUserID());
 	           //------------------------------------------------------------------//	
 				request.setAttribute("projectList",projectList);
 		   		//*********Dispatcher  	 

 			  	//System.out.println("doFormLoad ->successfully.");	 
 		   		String tarGetUrl ="/SERV_ReportInformRepairForm.jsp";
 		   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
 				dispatcher.forward(request,response);	
 				 
 				/****** Clear *******/
 				conn.close();
 				conn = null;
 			}catch(Exception e){
 				System.out.println("!!! doFormLoad , " +sysName+":"+ clazzName + " : " + e.getMessage());	
 				msgTxt = "doFormLoad , " +sysName+":"+ clazzName + " : " + e.getMessage();
 				response.sendRedirect(ERROR_PAGE+msgTxt);
 				return;
 			}
 			finally{			
 				//clean up.
 				try{
 					if(conn!=null){conn.close();}
 				}catch(Exception e){}
 			}
 		} 

 		//*****	method doFodoGenReportFormrmLoad criteria projectDDL
 		protected void doGenReportForm(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
 			// TODO Auto-generated method stub
 			response.setContentType("text/html; charset=TIS-620");
 			Connection conn = null;
 			ServletContext context = getServletContext();
 			HttpSession session = request.getSession(false);
 			
 			String okPage = "";//Constants.APP_PATH+Constants.SAVE_PAGE;
 			String targetPage ="";//  Constants.APP_PATH+Constants.APP_HOME;
 			String errorCode = "99";	
 			
 			String msgTxt = "";// Constants.APP_PATH+Constants.SAVE_PAGE;
 			String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
 			//String errorCode = "99";	

 	        try{
 	        	//System.out.println("doGenReportForm ->Starting.");
 	        	//printOutParam(request,"doGenReportForm");
 	 			//----------Open connection
 				//Open connection
 				if (ds == null){getDS();}			
 				conn = ds.getConnection();
 				conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
 	  			//conn.setAutoCommit(false);
 	            //-------------------------
 				String[] projSelDDL = request.getParameterValues("projSelDDL"); 
 	  			String mmDDL1 = doString.checkString(request.getParameter("mmDDL1"),getMonthNow());
 	  			String yyDDL1 = doString.checkString(request.getParameter("yyDDL1"),getYearNow()); 
 	  			String rbtType = doString.checkString(request.getParameter("rbtType"),"12"); 
 	  			String multiFlag = doString.checkString(request.getParameter("multiFlag"),""); //0,1

 	  			/**********************************/
 	  			String [] COULUMN_MONTH_YEAR = new String[12];
 	  			String [] COULUMN_DATE_QUERY = new String[12];
 	  			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");	
 	  			Calendar cal = Calendar.getInstance(Locale.ENGLISH);
 	  			int yearIns = Integer.parseInt(yyDDL1);
 	  		    int monthIns = Integer.parseInt(mmDDL1);
 	  		    int MAX_LOOP = Integer.parseInt(rbtType);
 	  			//update a date
 	  		    cal.set(Calendar.YEAR, yearIns);
 	  		    cal.set(Calendar.MONTH, monthIns);
 	  			cal.set(Calendar.DATE, 1);
 	  		    for(int i = 0;i<12;i++){
 	  		    	  cal.set(Calendar.MONTH, monthIns-1);   	  
 	  		    	  
 	  		    	  COULUMN_MONTH_YEAR[i] = shortMonth[monthIns-1]+" "+(yearIns+543);
 	  		    	  //-----------
 	  		    	  if(i<MAX_LOOP){
 	  		    		if(i==0){
 	  		    			COULUMN_DATE_QUERY[i]= lastDayOfMonth(yearIns, monthIns-1);
 	  		    		} else{
 	  		    			COULUMN_DATE_QUERY[i] = sdf.format(cal.getTime());//2014-05-01
 	  		    		}
 	  		    	  }
 	  		    	  //-------------------------------
 	  		    	  monthIns--;
 	  		    	  if(monthIns==0){
 	  		    		  monthIns = 12;
 	  		    		  yearIns-=1;
 	  		    		  cal.set(Calendar.YEAR, yearIns);
 	  		    	  }
 	  		     }//End for
   		    
 			  	 /**********************************/
 	        	 String temp_tbtResour1 = "temp_tbtResour1";
 	        	 String lableE_cnt = "e_cnt";
 	        	 String lableS_cnt = "s_cnt";
 	  		    
 		  		  ArrayList  projectList = new ArrayList();
 		  		  List reportEserviceList = new ArrayList();
 		  		  List reportSvcList = new ArrayList();	
 		  		  if(multiFlag.equals("0")){//TODO: CASE : ALL Project
 		  			 GenReportCaseAllProject(conn, COULUMN_DATE_QUERY[MAX_LOOP-1], COULUMN_DATE_QUERY[0], MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtResour1);
 		  			 reportEserviceList = ListReportCaseEService(conn, COULUMN_DATE_QUERY[MAX_LOOP-1], COULUMN_DATE_QUERY[0], MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtResour1, lableE_cnt); 
 		  			 reportSvcList = ListReportCaseSVC(conn, COULUMN_DATE_QUERY[MAX_LOOP-1], COULUMN_DATE_QUERY[0], MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtResour1, lableS_cnt);
 		  		  }else{//TODO: CASE : By project
 		  			 GenReportCaseByProject(conn,  COULUMN_DATE_QUERY[MAX_LOOP-1], COULUMN_DATE_QUERY[0], MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtResour1,projSelDDL);
 		  			 reportEserviceList = ListReportCaseEService(conn, COULUMN_DATE_QUERY[MAX_LOOP-1], COULUMN_DATE_QUERY[0], MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtResour1, lableE_cnt);	  			 
 		  			 reportSvcList = ListReportCaseSVC(conn, COULUMN_DATE_QUERY[MAX_LOOP-1], COULUMN_DATE_QUERY[0], MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtResour1, lableS_cnt);

 
 		  			 projectList = this.ListProjectSelect(conn, projSelDDL);
 		  		  }		
 				  //*******************************************************************/
 		  		  request.setAttribute("projSelectdList", projectList);
 		  		  
 		  		  request.setAttribute("SVC_LIST", reportSvcList);
 		  		  request.setAttribute("ESERVIC_LIST", reportEserviceList);
      	  		  
 		  		  request.setAttribute("COULUMN_MONTH_YEAR", COULUMN_MONTH_YEAR);
 				  request.setAttribute("mmDDL1", mmDDL1);
 				  request.setAttribute("yyDDL1",yyDDL1);
 				  request.setAttribute("rbtType",rbtType);//LH:075
 				  request.setAttribute("MAX_LOOP", MAX_LOOP);
 				  request.setAttribute("multiFlag",multiFlag);//0=ALL
 				
 		   		//*********Dispatcher  	 
 			  	//System.out.println("-------------------EVC-------------------------------");	 
 			  	//DisplayList(reportEserviceList);
 			  	//DisplayList(reportSvcList);
 			  	
 			  	String tarGetUrl ="/SERV_ReportInformRepairView.jsp";
 		   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
 				dispatcher.forward(request,response);	
 				 
 				/****** Clear *******/
 				conn.close();
 				conn = null;
 			}catch(Exception e){
 				System.out.println("!!! doGenReportForm , " +sysName+":"+ clazzName + " : " + e.getMessage());
 				msgTxt = "doFormLoad , " +sysName+":"+ clazzName + " : " + e.getMessage();
 				response.sendRedirect(ERROR_PAGE+msgTxt);
 			}
 			finally{			
 				//clean up.
 				try{
 					if(conn!=null){conn.close();}
 				}catch(Exception e){}
 			}
 		} 		

  		private void InsertTempTableProject(Connection conn, String projectArr[]) {
 			StringBuffer sql = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 	        try{
 	        	//initial paramter	        
 	        	String tblByProjectX = "tblByProjectX";
 	        	String sqlDelete = " Delete "+tblByProjectX;
 	        	//int i=1;
 				/******************************************************/
 	        	try{
 		        	sql.delete(0, sql.length());
 					sql.append(" Create temp table "+tblByProjectX+" (  ")
 					   .append(" com_id char(2),  ")
 					   .append(" proj_id char(3) ")
 					   .append(" ); ");	
 		        	pstmt = conn.prepareStatement(sql.toString()); 
 		        	pstmt.executeUpdate();
 	        	}catch(Exception e){
 	        		System.out.println("MSG == already exists in session (bck.tblByProjectX) ==");
 		        	pstmt = conn.prepareStatement(sqlDelete); 
 		        	pstmt.executeUpdate();
 	        	}
 				sql.delete(0, sql.length());
 				sql.append(" INSERT INTO  "+tblByProjectX+"(com_id,proj_id)  VALUES( ? , ? ); ");
 			    pstmt = conn.prepareStatement(sql.toString()); 
 			    
 			    String [] temp = null;
 	        	if(projectArr!=null){
 	        		for(int n = 0;n<projectArr.length;n++){
 	        			temp = projectArr[n].split("\\:");
 	        			pstmt.setString(1, temp[0]);
 	     			    pstmt.setString(2, temp[1]);
 	     			    pstmt.executeUpdate();
 	        		}
 	        	}
 				//********************************************************/
 			}catch(Exception e){
 				System.out.println("!!InsertTempTable , " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.out.println(" SQL Exception: "+sql.toString());		
 			}
 			finally{			
 				//clean up.
 				try{
 					if(rs!=null){rs.close();}
 					if(pstmt!=null){pstmt.close();}
 				}catch(Exception e){}
 			}
 		}
 		
  		private List  ListReportCaseEService(Connection conn,String fromDate,String toDate,int MAX_LOOP,String[] COULUMN_DATE_QUERY,
  				String temp_tbtResour1,String lableE_cnt ){
 			StringBuffer sql1 = new StringBuffer();	
 			StringBuffer sqlFetch = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
  			try{
 	        	List objListESV  = new ArrayList();
 	        	String str[] = null;
 	        	int MAX_COLUMN = 4+MAX_LOOP; //
 	  			//-----------------
 	  			String []tempMatrix = null;
                //Get data for report for E-Serivce
 			    sqlFetch.delete(0, sqlFetch.length());
 			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtResour1,lableE_cnt));			    

 			    pstmt = conn.prepareStatement(sqlFetch.toString()); 
 	        	rs = pstmt.executeQuery();	

 	        	int loopColumn = 4;
 	        	int loop = 1;
 	        	while(rs.next()){
 	        		//System.out.print(" Loop :"+loop);
 	        		//----------------EService	        		
 	        		tempMatrix = new String[MAX_COLUMN];
 	        		for (int i=0; i < MAX_COLUMN; i++) {
 	        			tempMatrix[i] = "";//Allocate a values in row&coulumn	
 	        			if(i>3){
 	        				tempMatrix[i] = "0";//Allocate a values in row&coulumn	
 	        			}
 	 	    		} 
 	        		/*System.out.print(" tempMatrix[i] ");
 	        		for (int i=0; i < MAX_COLUMN; i++) {
 	        			System.out.print(tempMatrix[i]+",");
 	        		}
 	        		System.out.println(" ");*/	        		
 	        		
 	        		tempMatrix[0] = doString.checkString(rs.getString("brd"),"");
 	        		tempMatrix[1] = doString.checkString(rs.getString("com"),"");
 	        		tempMatrix[2] = doString.checkString(rs.getString("prj"),"");
 	        		tempMatrix[3] = doString.checkString(rs.getString("n_proj"),"");

 	        		//--------------	        		
 	        		loopColumn = 4;//4,5,6,7,8,9,10...N
 	        		for(int i = 0;i<MAX_LOOP;i++){
 	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31	        			
 	        			tempMatrix[loopColumn] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
 		        		loopColumn++;
 	        		}

 	        		objListESV.add(tempMatrix);	
 	        		loop++;
 	        	}
 	        	rs = null;

 	        	//---#End ---/
 			  	return objListESV;			  	 
 			}catch(Exception e){
 				System.out.println("!!!ListReportALLProjectCaseEService, " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.out.println(" SQL Exception: "+sql1.toString());		
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
  		
  		private List  ListReportCaseSVC(Connection conn,String fromDate,String toDate,int MAX_LOOP,String[] COULUMN_DATE_QUERY,
  				String temp_tbtResour1,String lableS_cnt ){
 			StringBuffer sql1 = new StringBuffer();	
 			StringBuffer sqlFetch = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
  			try{
 	        	List objListSVC = new ArrayList();
 	        	String str[] = null;
 	        	int MAX_COLUMN = 4+MAX_LOOP; //
 	  			//-----------------
 	  			String []tempMatrix = null;
                //Get data for report for E-Serivce
 			    sqlFetch.delete(0, sqlFetch.length());
 			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtResour1,lableS_cnt));			    
 	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
 	        	rs = pstmt.executeQuery();	
 	        	
 	        	int loopColumn = 5;
 	        	while(rs.next()){
 	        		tempMatrix = new String[MAX_COLUMN];
 	        		for (int i=0; i < MAX_COLUMN; i++) {
 	        			tempMatrix[i] = "";//Allocate a values in row&coulumn	
 	        			if(i>3){
 	        				tempMatrix[i] = "0";//Allocate a values in row&coulumn	
 	        			}
 	 	    		} 
 	        		//----------------CALL SVC
 	        		tempMatrix[0] = doString.checkString(rs.getString("brd"),"");
 	        		tempMatrix[1] = doString.checkString(rs.getString("com"),"");
 	        		tempMatrix[2] = doString.checkString(rs.getString("prj"),"");
 	        		tempMatrix[3] = doString.checkString(rs.getString("n_proj"),"");
 	        		//--------------	        		
 	        		loopColumn = 4;//4,5,6,7,8,9,10...N
 	        		for(int i = 0;i<MAX_LOOP;i++){
 	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31	        			
 	        			tempMatrix[loopColumn] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
 		        		loopColumn++;
 	        		}
 	        		objListSVC.add(tempMatrix);
 	        	}
 	        	rs = null;
 	        	//---#End ---/
 			  	return objListSVC;			  	 
 			}catch(Exception e){
 				System.out.println("!!!ListReportALLProjectCaseSVC, " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.out.println(" SQL Exception: "+sql1.toString());		
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
  		
 
 		private void GenReportCaseAllProject(Connection conn,String fromDate,String toDate,int MAX_LOOP,String[] COULUMN_DATE_QUERY ,String temp_tbtResour1) {
 			//	TODO Auto-generated method stub
 			/*****************/		
 			StringBuffer sql1 = new StringBuffer();	
 			//StringBuffer sqlFetch = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 	        try{
 	        	//initial paramter	
 	        	String temp_tbtData1 = "temp_tbtData1";
 	        	String temp_tbtData2 = "temp_tbtData2";
 	  			
 	  			String sqlDeleteDDLTempTable = " Delete ";
    	  		String sqlCreateDDLTempTable = " Create temp table ";
    	  		String sqlCreateDDLTempTableData = " (brd char(10),com char(2),prj char(3),yymm int,cnt int); ";
    	  		String sqlCreateDDLTempTableResource = " (brd char(10),com char(2),prj char(3),n_proj char(50),yymm int,e_cnt int,s_cnt int); ";
 	  			//*******************************

 	    		/**************************
 	        	 * For e-Service
 	        	 * *************************/
 	    		try{
 		        	pstmt = conn.prepareStatement(sqlCreateDDLTempTable+temp_tbtData1+sqlCreateDDLTempTableData); 
 		        	pstmt.executeUpdate();
 	    		}catch(Exception e){	
 	    			//(bck.temp_tbtdatar1) already exists in session.
 	    			System.out.println("MSG == already exists in session (bck.temp_tbtdata1) == ");
 	    			pstmt = conn.prepareStatement(sqlDeleteDDLTempTable+temp_tbtData1); 
 		        	pstmt.executeUpdate();
 	    		}     	
 	    		/************************** Main sql e-Service**********/	
 	    		sql1.delete(0,sql1.length());
 	        	sql1.append(" Select b.i_zone as brd,a.i_company as com,a.i_project as prj,year(a.d_keyin)||month(a.d_keyin) as yymm,count(*) as cnt    ")
 					.append(" From lan:eser_dochd a,lan:serv_lstaff b ")
 					.append(" Where   ")					
 					.append(" f_status <> 'CAN'   ")
 					.append(" AND a.i_company = b.i_company  ")
 					.append(" AND a.i_project = b.i_project  ")
 					.append(" AND b.i_zone <> '99'  ")
 					.append(" AND date(a.d_keyin) between '"+fromDate+"' and '"+toDate+"'   ")
 					.append(" Group by 1,2,3,4  ");      
 	        	/************
 	        	 * CALL prepared temp table
 	        	 * ***********/
 	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

 	        	//*********End Insert temp tableData#1
 	        		        	
 	    		/**************************
 	        	 * For CALL Service Center
 	        	 * *************************/ 	    		
 	    		try{
 		        	pstmt = conn.prepareStatement(sqlCreateDDLTempTable+temp_tbtData2+sqlCreateDDLTempTableData); 
 		        	pstmt.executeUpdate();
 	    		}catch(Exception e){	
 	    			System.out.println("MSG == already exists in session (bck.temp_tbtdata2) == ");
 	    			pstmt = conn.prepareStatement(sqlDeleteDDLTempTable+temp_tbtData2); 
 		        	pstmt.executeUpdate();
 	    		}		
 	    		
 	    		/********* Main : CALL SVC*****************/ 	
	    		sql1.delete(0,sql1.length());
 	        	sql1.append(" Select b.i_zone as brd,a.i_company as com,a.i_project as prj,year(a.d_keyin)||month(a.d_keyin) as yymm,count(*) as cnt    ")
 					.append(" From lan:svc_dochd a,lan:svc_docdt c,lan:serv_lstaff b ")
 					.append(" Where   ")
 					.append("  a.i_company = b.i_company  ")
 					.append(" AND a.i_project = b.i_project  ")
 					.append(" AND b.i_zone <> '99'  ")
 					.append(" AND c.i_itmno = '01' ")
					.append(" AND c.i_itmsub = '01'  ")
					.append(" AND c.i_docno is not null  ")
					.append(" AND a.i_svc_docno = c.i_svc_docno ")
 					.append(" AND date(a.d_keyin) between '"+fromDate+"' and '"+toDate+"'   ")
 					.append(" Group by 1,2,3,4  ");  
 	        	
 	        	/************
 	        	 * CALL prepared temp table
 	        	 * ***********/
 	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData2);
 	        	//*********End Insert temp tableData#1
	        	
 	    		/**************************
 	        	 * For temp table Data resource
 	        	 * *************************/
 	    		try{
 		        	pstmt = conn.prepareStatement(sqlCreateDDLTempTable+temp_tbtResour1+sqlCreateDDLTempTableResource); 
 		        	pstmt.executeUpdate();

 	    		}catch(Exception e){	
 	    			System.out.println("MSG == already exists in session (bck.temp_tbtResour1) == ");
 	    			pstmt = conn.prepareStatement(sqlDeleteDDLTempTable+temp_tbtResour1); 
 		        	pstmt.executeUpdate();
 	    		}
 	    		/********* Main Unoin table1&table2 *****************/ 
	    		sql1.delete(0,sql1.length());
 	        	sql1.append(" Select  brd , com , prj , yymm from (   ")
 					.append(" (select * From "+temp_tbtData1+" ) ")
 					.append(" union ")
 					.append(" (select * From "+temp_tbtData2+" ) ")
 					.append(" )  ")
 					.append(" Where 1=1 ")
 					.append(" Group by brd , com , prj , yymm ")
 					.append(" Order by brd , com , prj  ");   
 	    		//********************* 	        	
 	        	/************
 	        	 * CALL prepared union temp table
 	        	 * ***********/
 	        	PreparedInsertTempTableResource(conn, sql1.toString(), temp_tbtResour1,temp_tbtData1,temp_tbtData2);
 	        	//*********End Insert temp tableData#1 
 			}catch(Exception e){
 				System.out.println("!!!GenReportCaseAllProject, " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.out.println(" SQL Exception: "+sql1.toString());		
 			}
 			finally{			
 				//clean up.
 				try{
 					if(rs!=null){rs.close();}
 					if(pstmt!=null){pstmt.close();}
 				}catch(Exception e){}
 			}	
 		}
 		
 		private void GenReportCaseByProject(Connection conn,String fromDate,String toDate,int MAX_LOOP,String[] COULUMN_DATE_QUERY ,String temp_tbtResour1,
 				String []projectArr) {
 			//	TODO Auto-generated method stub
 			/*****************/		
 			StringBuffer sql1 = new StringBuffer();	
 			//StringBuffer sqlFetch = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 	        try{
 	        	//initial paramter	
 	        	String temp_tbtData1 = "temp_tbtData1";
 	        	String temp_tbtData2 = "temp_tbtData2";

 	  			//-----------------	  			
 	  			String sqlDeleteDDLTempTable = " Delete ";
    	  		String sqlCreateDDLTempTable = " Create temp table ";
    	  		String sqlCreateDDLTempTableData = " (brd char(10),com char(2),prj char(3),yymm int,cnt int); ";
    	  		String sqlCreateDDLTempTableResource = " (brd char(10),com char(2),prj char(3),n_proj char(50),yymm int,e_cnt int,s_cnt int); ";
 	  			//*******************************
    	  		
 	        	//1.Insert project to temp table
 	    		/************************************************/	
 	    		this.InsertTempTableProject(conn, projectArr);

 	    		/**************************
 	        	 * For e-Service
 	        	 * *************************/
 	    		try{
 		        	pstmt = conn.prepareStatement(sqlCreateDDLTempTable+temp_tbtData1+sqlCreateDDLTempTableData); 
 		        	pstmt.executeUpdate();
 	    		}catch(Exception e){	
 	    			//(bck.temp_tbtdatar1) already exists in session.
 	    			System.out.println("MSG == already exists in session (bck.temp_tbtdata1) == ");
 	    			pstmt = conn.prepareStatement(sqlDeleteDDLTempTable+temp_tbtData1); 
 		        	pstmt.executeUpdate();
 	    		}     	
 	    		/************************** Main sql e-Service**********/	
 	    		sql1.delete(0,sql1.length());
 	        	sql1.append(" Select b.i_zone as brd,a.i_company as com,a.i_project as prj,year(a.d_keyin)||month(a.d_keyin) as yymm,count(*) as cnt    ")
 					.append(" From lan:eser_dochd a,lan:serv_lstaff b ,tblByProjectX x ")
 					.append(" Where   ")
 					.append(" f_status <> 'CAN'   ")
 					.append(" AND a.i_company = b.i_company  ")
 					.append(" AND a.i_project = b.i_project  ")
 					.append(" AND b.i_zone <> '99'  ")
 					.append(" AND a.i_company = x.com_id  ")
 					.append(" AND a.i_project = x.proj_id ")
 					.append(" AND date(a.d_keyin) between '"+fromDate+"' and '"+toDate+"'   ")
 					.append(" Group by 1,2,3,4  ");      
 	        	/************
 	        	 * CALL prepared temp table
 	        	 * ***********/
 	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);
 	        	//*********End Insert temp tableData#1
 	        	        	
 	    		/**************************
 	        	 * For CALL Service Center
 	        	 * *************************/ 	    		
 	    		try{
 		        	pstmt = conn.prepareStatement(sqlCreateDDLTempTable+temp_tbtData2+sqlCreateDDLTempTableData); 
 		        	pstmt.executeUpdate();
 	    		}catch(Exception e){	
 	    			//(bck.temp_tbtdatar1) already exists in session.
 	    			System.out.println("MSG == already exists in session (bck.temp_tbtdata2) == ");
 	    			pstmt = conn.prepareStatement(sqlDeleteDDLTempTable+temp_tbtData2); 
 		        	pstmt.executeUpdate();
 	    		}		
 	    		
 	    		/********* Main : CALL SVC*****************/ 	
	    		sql1.delete(0,sql1.length());
 	        	sql1.append(" Select b.i_zone as brd,a.i_company as com,a.i_project as prj,year(a.d_keyin)||month(a.d_keyin) as yymm,count(*) as cnt    ")
 					.append(" From lan:svc_dochd a,lan:svc_docdt c,lan:serv_lstaff b ,tblByProjectX x ")
 					.append(" Where   ")					
 					.append("  a.i_company = b.i_company  ")
 					.append(" AND a.i_project = b.i_project  ")
 					.append(" AND b.i_zone <> '99'  ")
 					.append(" AND a.i_company = x.com_id  ")
 					.append(" AND a.i_project = x.proj_id ")
 					.append(" AND c.i_itmno = '01' ")
 					.append(" AND c.i_itmsub = '01'  ")
 					.append(" AND c.i_docno is not null  ")
 					.append(" AND a.i_svc_docno = c.i_svc_docno ")
 					.append(" AND date(a.d_keyin) between '"+fromDate+"' and '"+toDate+"'   ")
 					.append(" Group by 1,2,3,4  ");      
 	        	/************
 	        	 * CALL prepared temp table
 	        	 * ***********/
 	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData2);
 	        	//*********End Insert temp tableData#1
 	
 	    		/**************************
 	        	 * For temp table Data resource
 	        	 * *************************/
 	    		try{
 		        	pstmt = conn.prepareStatement(sqlCreateDDLTempTable+temp_tbtResour1+sqlCreateDDLTempTableResource); 
 		        	pstmt.executeUpdate();
 	    		}catch(Exception e){	
 	    			//(bck.temp_tbtdatar1) already exists in session.
 	    			System.out.println("MSG == already exists in session (bck.temp_tbtResour1) == ");
 	    			
 	    			pstmt = conn.prepareStatement(sqlDeleteDDLTempTable+temp_tbtResour1); 
 		        	pstmt.executeUpdate();
 		        	//System.out.println("-->2. Delete temp table :"+sqlDeleteDDLTempTable+temp_tbtResour1);
 	    		}
 	    		/********* Main Unoin table1&table2 *****************/ 
	    		sql1.delete(0,sql1.length());
 	        	sql1.append(" Select  brd , com , prj , yymm from (   ")
 					.append(" (select * From "+temp_tbtData1+" ) ")
 					.append(" union ")
 					.append(" (select * From "+temp_tbtData2+" ) ")
 					.append(" )  ")
 					.append(" Where 1=1 ")
 					.append(" Group by brd , com , prj , yymm ")
 					.append(" Order by brd , com , prj  ");   
 	    		//********************* 	        	
 	        	/************
 	        	 * CALL prepared union temp table
 	        	 * ***********/
 	        	PreparedInsertTempTableResource(conn, sql1.toString(), temp_tbtResour1,temp_tbtData1,temp_tbtData2);
 	        	//*********End Insert temp tableData#1

 				//---------------------  	 
 			}catch(Exception e){
 				System.out.println("!!!GenReportCaseByProject, " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.out.println(" SQL Exception: "+sql1.toString());		
 			}
 			finally{			
 				//clean up.
 				try{
 					if(rs!=null){rs.close();}
 					if(pstmt!=null){pstmt.close();}
 				}catch(Exception e){}
 			}	
 		}
	
 		private void PreparedInsertTempTable(Connection conn,String sqlMain,String temp_table) {
 			//StringBuffer sql = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 	        try{
 	        	//initial paramter	
 	        	boolean isDel = false;
 	  			String sqlInsert = " Insert into "+temp_table+" (brd ,com ,prj ,yymm ,cnt) values (?, ? , ? ,? , ?); ";
 	        	String sqlDeleteTempTable = " Delete "+temp_table;
 	        	String sqlSelectTempTable = " Select * From "+temp_table;
 	        	
 	        	pstmt = conn.prepareStatement(sqlSelectTempTable); 
 	        	rs = pstmt.executeQuery();
 	        	if(rs.next()){
 	        		isDel = true;
 	        	}
 	        	rs = null;
 	        	
 	        	if(isDel){
 	    			pstmt = conn.prepareStatement(sqlDeleteTempTable); 
 		        	pstmt.executeUpdate();
 	        	}
 	
 	  			pstmt = conn.prepareStatement(sqlMain); 
 	        	//System.out.println("2.SQL_main:"+sqlMain);        	
 			    rs = pstmt.executeQuery();	
	    
 			    /* Prepared insert temp table
 			     * */
 			    
 			    pstmt = conn.prepareStatement(sqlInsert); 
 			    //************************
 			    while(rs.next()){
 			    	 pstmt.setString(1, rs.getString("brd"));
 			    	 pstmt.setString(2, rs.getString("com"));
 			    	 pstmt.setString(3, rs.getString("prj"));
 			    	 pstmt.setInt(4, rs.getInt("yymm"));
 			    	 pstmt.setInt(5, rs.getInt("cnt"));
 			    	 //Add row to the batch.
 			    	 pstmt.addBatch();
 			    }
 			    pstmt.executeBatch();
 			    rs.close();

 			    /* Excute bath
 			     * */
 				//********************************************************/			  	 		  	 
 			}catch(Exception e){
 				System.out.println("!!PreparedInsertTempTable , " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.out.println(" SQL Exception: "+sqlMain.toString());		
 			}
 			finally{			
 				//clean up.
 				try{
 					if(rs!=null){rs.close();}
 					if(pstmt!=null){pstmt.close();}
 				}catch(Exception e){}
 			}
 		}
 		
 		private void PreparedInsertTempTableResource(Connection conn,String sqlMain,String temp_table,String tempT1,String tempT2) {
 			//StringBuffer sql = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 	        try{
 	        	//initial paramter	
 	        	boolean isDel = false; 	        	        	
 	  			String sqlInsert = " Insert into "+temp_table+" (brd ,com ,prj, n_proj ,yymm ,e_cnt,s_cnt) values (?, ? , ? ,? , ?, ? , ? ); ";
 	        	String sqlDeleteTempTable = " Delete "+temp_table;
 	        	String sqlSelectTempTable = " Select * From "+temp_table;

 	        	pstmt = conn.prepareStatement(sqlSelectTempTable); 
 	        	rs = pstmt.executeQuery();
 	        	if(rs.next()){
 	        		isDel = true;
 	        	}
 	        	rs = null;
 	        	if(isDel){
 	    			pstmt = conn.prepareStatement(sqlDeleteTempTable); 
 		        	pstmt.executeUpdate();
 	        	}
 	
 	        	//System.out.println("2.SQL_main:"+sqlMain);    
 	  			pstmt = conn.prepareStatement(sqlMain);     	
 			    rs = pstmt.executeQuery();		    
 			    /* Prepared insert temp table
 			     * */
 			    pstmt = conn.prepareStatement(sqlInsert); 
 			    //************************
 			    String n_project = "";
 			    int count1 = 0;
 			    int count2 = 0;
 			    //------------------------
 			    while(rs.next()){
 	 			     n_project = "";
 	 			     count1 = 0;
 	 			     count2 = 0;
 			    	//Get project name 
 	 			    n_project = GetProjectName(conn, rs.getString("com"), rs.getString("prj"));
 			    	//Get cnt off e-Service
 	 			    count1 = GetCountTempTable(conn, rs.getString("brd"), rs.getString("com"), rs.getString("prj"), rs.getInt("yymm"), tempT1);
 			    	//Get cnt off SVC
 	 			    count2 = GetCountTempTable(conn, rs.getString("brd"), rs.getString("com"), rs.getString("prj"), rs.getInt("yymm"), tempT2);
 			    	//---For Add batch
 			    	 pstmt.setString(1, rs.getString("brd"));
 			    	 pstmt.setString(2, rs.getString("com"));
 			    	 pstmt.setString(3, rs.getString("prj"));
 			    	 pstmt.setString(4, doString.UnicodeToMS874(n_project));
 			    	 pstmt.setInt(5, rs.getInt("yymm"));
 			    	 pstmt.setInt(6, count1);
 			    	 pstmt.setInt(7, count2);

 			    	 //Add row to the batch.
 			    	 pstmt.addBatch();
 			    }
 			    pstmt.executeBatch();
 			    rs.close();
 			    //System.out.println("4.-->executeBatch  OK ");
 			    /* Excute bath
 			     * */
 				//********************************************************/			  	 		  	 
 			}catch(Exception e){
 				System.out.println("!!PreparedInsertTempTableResource , " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.out.println(" SQL Exception: "+sqlMain.toString());		
 			}
 			finally{			
 				//clean up.
 				try{
 					if(rs!=null){rs.close();}
 					if(pstmt!=null){pstmt.close();}
 				}catch(Exception e){}
 			}
 		}

		public String GetProjectName(Connection conn, String comId, String projectId) {
 			StringBuffer sql = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 			String  projectNamme = "";
 	        try{
 	        	//initial paramter	     	
 				/*************************************************/			
 	        	//*****Find project by user login  
 				sql.delete(0,sql.length());
 				sql.append("Select n_project From lan:acxprojt Where i_company = ? and i_project = ? ");
 				pstmt = conn.prepareStatement(sql.toString()); 
 				pstmt.setString(1, comId.trim());	
 				pstmt.setString(2, projectId.trim());
 				//System.out.println("SQL GetProjectName :"+sql.toString());
 				rs = pstmt.executeQuery();	
 				if(rs.next()){
 					projectNamme = doString.checkString(rs.getString("n_project"), "");
 				}
 				rs.close();	
 		   			
 				//**************************************************/
 			  	//System.out.println("##GetProjectName ->successfully.");				  	 
 			  	return projectNamme;			  	 
 			}catch(Exception e){
 				System.out.println("!!!GetProjectName , " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.out.println(" SQL Exception: "+sql.toString());		
 				return "";
 			}
 			finally{			
 				//clean up.
 				try{
 					if(rs!=null){rs.close();}
 					if(pstmt!=null){pstmt.close();}
 				}catch(Exception e){}
 			}
 		}
 		
 		public int GetCountTempTable(Connection conn,String brandId, String comId, String projId,int yymm,String temp_table) {
 			StringBuffer sql = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 			int  cnt = 0;
 	        try{
 	        	//initial paramter	     	
 				/*************************************************/			
 	        	//*****Find project by user login  
 				sql.delete(0,sql.length());
 				sql.append("Select cnt From "+temp_table+" ")				
 				   .append(" Where  ")
 				   .append("  brd = ? ")
 				   .append(" AND com = ?  ")
 				   .append(" AND prj = ?  ")
 				   .append(" AND yymm = ? ");
 				pstmt = conn.prepareStatement(sql.toString()); 
 				pstmt.setString(1, brandId);	
 				pstmt.setString(2, comId);
 				pstmt.setString(3, projId);
 				pstmt.setInt(4, yymm);

 				//System.out.println("SQL :"+sql.toString());
 				rs = pstmt.executeQuery();	
 				if(rs.next()){
 					cnt = rs.getInt("cnt");
 				}
 				rs.close();	
 		   			
 				//**************************************************/
 			  	//System.out.println("##GetProjectName ->successfully.");				  	 
 			  	return cnt;			  	 
 			}catch(Exception e){
 				System.out.println("!!!GetCountTempTable , " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.out.println(" SQL Exception: "+sql.toString());		
 				return 0;
 			}
 			finally{			
 				//clean up.
 				try{
 					if(rs!=null){rs.close();}
 					if(pstmt!=null){pstmt.close();}
 				}catch(Exception e){}
 			}
 		}
 		
 		private ArrayList<List> ListProjectSelect(Connection conn,String []projArr) {
 			// TODO Auto-generated method stub
 			StringBuffer sql = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 			//String tempProject = "";
 	        try{
 	        	//initial paramter	
 	        	ArrayList  projectDDL = new ArrayList<List>();
 	       	 	List   strList =  new ArrayList();	      	
 				/******************************************************/			
     			sql.delete(0, sql.length());
     			sql.append("Select a.i_company || ':' || a.i_project  as value, '[' || a.i_company || '-' || a.i_project || '] ' || a.n_project as name    ")
     				.append(" From lan:acxprojt a  ")
     				.append(" Where a.i_company = ? and a.i_project= ?   ");
     			pstmt = conn.prepareStatement(sql.toString()); 
     			
     		    String [] temp = null;
 	        	if(projArr!=null){
 	        		for(int n = 0;n<projArr.length;n++){
 	        			temp = projArr[n].split("\\:");
 	        			pstmt.setString(1, temp[0]);
 	     			    pstmt.setString(2, temp[1]);
 	     			    rs = pstmt.executeQuery();	
 	     			    if(rs.next()){
 							strList = new ArrayList(); 
 							strList.add(0,  doString.checkString(rs.getString("value"),""));
 							strList.add(1,  doString.checkString(rs.getString("name"),""));
 							projectDDL.add(strList);
 	     			   }
 	        		}
 	        	}
 				rs.close();		   			
 				//********************************************************/
 			  	//System.out.println("ListProjectSelect ->successfully.");				  	 
 			  	return projectDDL;			  	 
 			}catch(Exception e){
 				System.out.println("ListProjectSelect , " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.out.println(" SQL Exception: "+sql.toString());		
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

 		private ArrayList<List> ListProjectResposible(Connection conn, String userId) {
 			// TODO Auto-generated method stub
 			StringBuffer sql = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 			String tempProject = "";
 	        try{
 	        	//initial paramter	
 	        	ArrayList  projectDDL = new ArrayList<List>();
 	       	 	List   strList =  new ArrayList();	      	
 	        	//System.out.println("LIST_PROJECT_RESPOSIBLE ->Starting.");        	 

 				/******************************************************/			
 	        	//*****Find project by user login  
 				sql.delete(0,sql.length());
 				sql.append(" Select proj_id From lan:serv_pstaff Where  (user_id= ? ) ");
 				pstmt = conn.prepareStatement(sql.toString()); 
 				pstmt.setString(1, userId);	
 				rs = pstmt.executeQuery();	
 				if(rs.next()){
 					tempProject = doString.checkString(rs.getString("proj_id"), "");
 				}
 				rs.close();	
 				
 				/****************************projectDLL****************************************/
 				if("ALL".equals(tempProject)){
 					//case All project.
 	    			sql.delete(0, sql.length());
 	    			sql.append(" Select  distinct  a.i_company || ':' || a.i_project as value , '[' || a.i_company || '-' || a.i_project || '] ' || n_project as name , a.i_project ")
 	    			.append(" From lan:acsbudgh a ,lan:acxprojt b ")
 	    			.append(" Where a.d_year = year(TODAY)+543  and  a.i_budg_type in ('1','2','9') and  (a.i_company = b.i_company) and (a.i_project= b.i_project)  ")
 	    			.append(" AND a.i_project[1,1]<> 'G' ")
 	    			.append(" Order By value ");	
 	    			pstmt = conn.prepareStatement(sql.toString()); 
 	    			//------------------------
					strList = new ArrayList(); 
					strList.add(0,  "AA:999");
					strList.add(1, doString.UnicodeToMS874("---- ALL Project ----"));
					projectDDL.add(strList);
 				}else{
 					//case by user.
 	    			sql.delete(0, sql.length());
 	    			sql.append("Select a.com_id || ':' || a.proj_id  as value, '[' || a.com_id || '-' || a.proj_id || '] ' || n_project as name , a.proj_id   ")
 	    				.append(" From lan:serv_pstaff a ,lan:acxprojt b  ")
 	    				.append(" Where (user_id= ? ) and (a.com_id = b.i_company) and (a.proj_id= b.i_project)  ")
 	    				.append(" AND b.i_project[1,1]<> 'G' ")
 	    				.append(" Order By value ");
 	    			pstmt = conn.prepareStatement(sql.toString()); 
 	    			pstmt.setString(1, userId);	
 				}
 				//System.out.println("ListProjectResposible SQL :"+sql.toString());
 				rs = pstmt.executeQuery();		    			
 				while(rs.next()){
 					strList = new ArrayList(); 
 					strList.add(0,  doString.checkString(rs.getString("value"),""));
 					strList.add(1,  doString.checkString(rs.getString("name"),""));
 					projectDDL.add(strList);
 				}
 				rs.close();		   			
 				//********************************************************/
 			  	//System.out.println("LIST_PROJECT_RESPOSIBLE ->successfully.");				  	 
 			  	return projectDDL;			  	 
 			}catch(Exception e){
 				System.out.println("LIST_PROJECT_RESPOSIBLE , " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.out.println(" SQL Exception: "+sql.toString());		
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
 	
 		private static String lastDayOfMonth(int year,int month){
 			  Calendar calendar = Calendar.getInstance(Locale.ENGLISH);  

 			  calendar.set(Calendar.YEAR, year);
 		      calendar.set(Calendar.MONTH, month);
 		        
 		      calendar.add(Calendar.MONTH, 1);  
 		      calendar.set(Calendar.DAY_OF_MONTH, 1);  
 		      calendar.add(Calendar.DATE, -1);  
 		      
 		      Date lastDayOfMonth = calendar.getTime();  
 		      DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");  	      
 		      return  sdf.format(lastDayOfMonth);
 		}
 		
 		private static String getFetchSQL(int MAX_LOOP,String []COULUMN_DATE_QUERY,String tempTable,String cnt_Lable){
 			   StringBuffer sql1 = new StringBuffer();
 			   StringBuffer sqlFetch = new StringBuffer();
 			   String []str = null;
 		       sql1.delete(0,sql1.length());
 			   // sql1.append("  ");
 		  		for(int i = 0;i<MAX_LOOP;i++){
 		  		    str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31 
 		  		    //e_cnt,s_cnt 
 		  		    sql1.append(" sum(CASE WHEN YYMM = "+getYYMM(str[0], str[1])+" THEN "+cnt_Lable+" ELSE 0 END) AS  M"+getYYMM(str[0], str[1])+" ,  ");
 		  		}
 		  		sqlFetch.delete(0,sqlFetch.length());
 		  		sqlFetch.append(" SELECT brd ,com ,prj, n_proj, ");
 		  		sqlFetch.append(sql1.toString().substring(0,sql1.toString().lastIndexOf(",")));
 		  		sqlFetch.append("  FROM "+tempTable+"  ")
 		  		        .append("  Group by brd ,com ,prj, n_proj   Order by brd ,com ,prj, n_proj  ");			  	
 		  		return sqlFetch.toString();
 		}
 	
 		private static String getYearNow(){
 			Date today = new Date();  
 			DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");  
 			///System.out.println("Today : " + sdf.format(today));
 			return sdf.format(today).split("\\-")[0];
 		}
 		private static String getMonthNow(){
 			Date today = new Date();  
 			DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");  
 			///System.out.println("Today : " + sdf.format(today));
 			return sdf.format(today).split("\\-")[1];
 		}
 		private static String getYYMM(String args1,String args2){
 			String ret = "";
 			if ((args1 != null || !args1.equals("")) && (args2 != null) || !args2.equals("")) {
 				ret = Integer.parseInt(args1)+""+Integer.parseInt(args2);
 			}
 			return ret;
 		}
 		
 		 public void DisplayList(List arrList) throws Exception{
 			 String  str[] = null;
 			 System.out.println("ArrayList size:"+arrList.size());
 			 if(arrList!=null && arrList.size()>0){							 
 				Iterator it = arrList.iterator();								   							   
 				while(it.hasNext()){	
 					str =(String [])it.next();
 					System.out.print("--> ");
 					for(int i = 0;i<str.length;i++){
 						System.out.print(str[i]+" , ");
 					}
 					System.out.println("");
 				}	
 			 }
 		 }


 }