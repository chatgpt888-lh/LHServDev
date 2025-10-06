package serv.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
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
 * Servlet implementation class for Servlet: SERV_RptKeepBeforeServlet
 * create by : pradoem wonkraso ,go2doem@gmail.com, pradoem@lh.co.th
 * date time: 2016.05.06
 * version : 1.0
 * project : Report form  bann transfer check form  QC
 * comment:  this class controller servlet for List Report baan transfer
 * check list by user 
 */
 public class SERV_RptKeepBeforeServlet extends  DBServlet{
    /* (non-Java-doc)
	 * @see javax.servlet.http.HttpServlet#HttpServlet()
	 */
	public SERV_RptKeepBeforeServlet() {
			super();
	}  
	static String Field_T_CNT = "t_cnt";
	static String Field_K_CNT ="k_cnt";
	String sysName = "LHServ";
	String clazzName = new String(this.getClass().getName() + ".performTask :");	
	String USER_ID = "";
	String thaiMonth[] = new String[] {"มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม",""};
	String shortMonth[] = new String[] {"ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค.",""};
 	
	public void performTask(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {	  
		System.out.println(clazzName + "start.");   
		response.setContentType("text/html; charset=TIS-620");
		PrintWriter out = null;		
		/******************Session User Check************************/
		HttpSession session = request.getSession();
		String userId = doString.checkString(request.getParameter("userId"), "");		
		if(!"".equals(userId)){	
			Connection conn = null;
			try{
				if (ds == null){getDS();}			
				conn = ds.getConnection();
				conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
				conn.setAutoCommit(true);	
				User user = authenUser(conn, userId);
				session.setAttribute("USER",user);	
				conn.close();
				conn = null;
			}catch(Exception e){
				if(conn!=null){
					try {
						conn.close();
					} catch (SQLException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					}
					conn = null;	
				}
			}
			finally{
				try {
					if(conn!=null){
					    conn.close();
					}
				} catch (SQLException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
				conn = null;
			}
		}
		
	    /*if (session == null) {
	        /** Redirect user to login page if there's no session.* /
	        response.sendRedirect(request.getContextPath()+"/login.jsp");
	        return;
	    }*/
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
		 //out = response.getWriter();
		try{
			  String  command = request.getParameter("cmd")==null?"":request.getParameter("cmd");					
			  if(command.equals("frmLoad")){		
				 this.doFormLoad(request,response,user);				
			  }else if(command.equals("GenReport")){
				 this.doGenReportForm(request,response,user);
			  }else if(command.equals("desc")){
				this.doFormDescription(request,response,user);
			  }
		}catch(Exception e){
			e.printStackTrace();
			System.out.println(sysName+":"+clazzName +" "+e.toString());		
		}
		finally{
			//out.close();
		}
	}	

//	*****	method doFormLoad criteria projectDDL
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
  			List projectList = this.ListProjectResposible(conn, user.getUserID());

			//***************************************************************************/		
			request.setAttribute("projectList",projectList);
	   		//*********Dispatcher  	 
		  	//System.out.println("doFormLoad ->successfully.");	  	
		  	 
	   		String tarGetUrl ="/SERV_RptKeepBefore_01_Form.jsp";
	   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			dispatcher.forward(request,response);	
			 
			/****** Clear *******/
			conn.close();
			conn = null;
		}catch(Exception e){
			//System.out.println("!!! doFormLoad , " +sysName+":"+ clazzName + " : " + e.getMessage());
			//GenRedirectForm(out,okPage,targetPage,errorCode,"กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ "+e.getMessage());
			//return;
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
		USER_ID = user.getUserName();
		String msgTxt = "";// Constants.APP_PATH+Constants.SAVE_PAGE;
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
		//String errorCode = "99";	

        try{
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
	  		    	}else{
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
        	String temp_tbtProject = "temp_proj_"+USER_ID;
        	String temp_tbtDataTrans1 = "temp_data1_"+USER_ID;
        	String temp_tbtDataKeyin2 = "temp_data2_"+USER_ID;
        	String temp_tbtResource = "temp_resource_"+USER_ID;
        	
	  		 List  selProjectList= new ArrayList();
	  		 //List rptMainDataList = new ArrayList();
	  		 List reportDataTrans = new ArrayList();
	  		 List reportDataKeyin = new ArrayList();
	  		 if(multiFlag.equals("0")){//TODO: CASE : ALL Project
	  			
	  			GeneratePreparedIntoTempTable(conn,COULUMN_DATE_QUERY[MAX_LOOP-1], COULUMN_DATE_QUERY[0], true,temp_tbtProject,temp_tbtDataTrans1,temp_tbtDataKeyin2,temp_tbtResource,null);
	  			reportDataTrans = ListReportCaseFetchData(conn, COULUMN_DATE_QUERY[MAX_LOOP-1], COULUMN_DATE_QUERY[0], MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtResource,Field_T_CNT);	  			 
	  			reportDataKeyin = ListReportCaseFetchData(conn, COULUMN_DATE_QUERY[MAX_LOOP-1], COULUMN_DATE_QUERY[0], MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtResource,Field_K_CNT);
	
	  			//System.out.println("===================CASE BY ALL PROJECT Transfer=============================");
	  			//DisplayMaxtrixList(reportDataTrans);
	  			
	  			//System.out.println("===================CASE BY ALL PROJECT KeyIn=============================");
	  			//DisplayMaxtrixList(reportDataKeyin);
	  			
	  		 }else{//TODO: CASE : By project
	  			
	  			GeneratePreparedIntoTempTable(conn,COULUMN_DATE_QUERY[MAX_LOOP-1], COULUMN_DATE_QUERY[0], false,temp_tbtProject,temp_tbtDataTrans1,temp_tbtDataKeyin2,temp_tbtResource,projSelDDL);
	  			reportDataTrans = ListReportCaseFetchData(conn, COULUMN_DATE_QUERY[MAX_LOOP-1], COULUMN_DATE_QUERY[0], MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtResource,Field_T_CNT);	  			 
	  			reportDataKeyin = ListReportCaseFetchData(conn, COULUMN_DATE_QUERY[MAX_LOOP-1], COULUMN_DATE_QUERY[0], MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtResource,Field_K_CNT);
	  			selProjectList = this.ListProjectSelect(conn, projSelDDL);
	  			
	  			//System.out.println("===================CASE BY PROJECT Transfer=============================");
	  			//DisplayMaxtrixList(reportDataTrans);
	  			
	  			//System.out.println("===================CASE BY PROJECT KeyIn=============================");
	  			//DisplayMaxtrixList(reportDataKeyin);
	  		 }		
			 //*******************************************************************/		  			  		
	  		 request.setAttribute("projSelectdList", selProjectList);
	  		 request.setAttribute("TRANS_LIST", reportDataTrans);
	  		 request.setAttribute("KEYIN_LIST", reportDataKeyin);	  		  
	  		 request.setAttribute("COULUMN_MONTH_YEAR", COULUMN_MONTH_YEAR);
	  		 request.setAttribute("COULUMN_DATE_QUERY", COULUMN_DATE_QUERY);

			 request.setAttribute("mmDDL1", mmDDL1);
			 request.setAttribute("yyDDL1",yyDDL1);
			 request.setAttribute("rbtType",rbtType);//LH:075
			 request.setAttribute("MAX_LOOP", MAX_LOOP);
			 request.setAttribute("multiFlag",multiFlag);//0=ALL
			
	   		//*********Dispatcher  	 
		  	//System.out.println("doGenReportForm ->successfully.");	  	
		  	 
		  	String tarGetUrl ="/SERV_RptKeepBefore_02_View.jsp";
		  	//String tarGetUrl ="/SERV_ReportBaanINT_View.jsp";
	   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			dispatcher.forward(request,response);	
			 
			/****** Clear *******/
			conn.close();
			conn = null;
		}catch(Exception e){
			System.out.println("!!! doGenReportForm , " +sysName+":"+ clazzName + " : " + e.getMessage());
			msgTxt = "doGenReportForm , " +sysName+":"+ clazzName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
		}
		finally{			
			//clean up.
			try{
				if(conn!=null){conn.close();}
			}catch(Exception e){}
		}
	}
	
  //*****	method doFodoGenReportFormrmLoad criteria projectDDL
	protected void doFormDescription(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
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
		USER_ID = user.getUserName();
        try{
        	//printOutParam(request,"DESC");
 			//----------Open connection
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
  			//conn.setAutoCommit(false);
            //-------------------------
			String tempProjectTxt = doString.checkString(request.getParameter("tempProjectTxt"),"");//LH:151|LH:152|LH:154|LH:156|LH:157

  			String multiFlag = doString.checkString(request.getParameter("multiFlag"),"0"); //0=ALL Project,1= By project	  			
  			String type = doString.checkString(request.getParameter("type"),"0"); 
  			String comId = doString.checkString(request.getParameter("comId"),""); //Day
  			String projId = doString.checkString(request.getParameter("projId"),""); 
  			String fromDate = doString.checkString(request.getParameter("fdate"),""); //2016-05-01
  			String toDate = doString.checkString(request.getParameter("tdate"),""); //2016-05-31
  		
  			//boolean isAllProject = true;
  			List  projectList = new ArrayList();
  			String projectName = "";
			String temp_tbtProject = "temp_proj_"+USER_ID;
  			if(type.equals("1") || type.equals("2")){
  					projectName = this.GetProjectName(conn, comId, projId);
  			}else{
  				if(multiFlag.equals("0")){//CASE ALL
  		  			this.InsertTempTableProjectALL(conn, temp_tbtProject);
  				}else{
  	  	  			String []tempArrProjectId =tempProjectTxt.split("\\|"); 
  	  		    	/************************************************/
  	  		        //1.Insert project to temp table
  	  		    	/************************************************/	
  	  	  			this.InsertTempTableProject(conn,temp_tbtProject,tempArrProjectId);
  	  		        //System.out.println("--Insert temp table OK.");
  	  		    	projectList = this.ListProjectSelect(conn, tempArrProjectId);
  				}
  			}

			//*******************************************************************/		  		
	  		//------------------------------------------------------------------//
			int displayLine = Integer.parseInt(doString.checkString(request.getParameter("pageNoDDL"),"20"));				
			//***************Get Row from db
	        int maxRow = 0;//this.IntCountRowByACSContr$IPV_QCHD(conn, comId, projId, temp_tbtProject, type, fromDate, toDate);
	        
	        //System.out.println("==Count ROW :"+maxRow);
	        //---------------- Generate Display Customize and Page Link -------------------------//
	        int nowPage = Integer.parseInt(doString.checkString(request.getParameter("nowPage"),"1"));
	        int startRow = ((nowPage-1)*displayLine);
	        int endRow = startRow+displayLine;       	   
	        String pageLink = "";
	        int tmpMax = maxRow;
	        pageLink = GenLinkNextPageHTML(tmpMax, nowPage, displayLine);
	
			ArrayList pageNoDDL = new ArrayList();
			int intVal = 20;
			for(int i=0;i<5;i++){
				pageNoDDL.add(0,intVal); 
				intVal +=20;
			}
	        //------------------------------------------------------------------//s		
			/***********************
			 * Search HD  
			 **********************/
			 ArrayList listDescHD =  this.ListSearchByACSContr$IPV_QCHD(conn, comId, projId, temp_tbtProject, type, fromDate, toDate, startRow, endRow, maxRow);

	  		 request.setAttribute("listDescHD", listDescHD);
	  		 request.setAttribute("projSelectdList", projectList);
			 request.setAttribute("multiFlag",multiFlag);//0=ALL			 
			
			 request.setAttribute("type", type);
			 request.setAttribute("comId",comId);
			 request.setAttribute("projId",projId);
			 request.setAttribute("projectName",projectName);
			 request.setAttribute("startDate",fromDate);
			 request.setAttribute("endDate",toDate);
	   		//*********Dispatcher  
			/**********************************/
			request.setAttribute("displayLinkPage", pageLink); 
			request.setAttribute("pageNoDDL",pageNoDDL);
			request.setAttribute("displayLine", displayLine);
			request.setAttribute("recordNo", startRow);
		    /************************************/
		  	//System.out.println("doGenReportForm ->successfully.");	  	
		  	 
		  	String tarGetUrl ="/SERV_RptKeepBefore_03_Desc.jsp";
	   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			dispatcher.forward(request,response);	
			 
			/****** Clear *******/
			conn.close();
			conn = null;
		}catch(Exception e){
			System.out.println("!!! doFormDescription , " +sysName+":"+ clazzName + " : " + e.getMessage());
			msgTxt = "doFormDescription , " +sysName+":"+ clazzName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
		}
		finally{			
			//clean up.
			try{
				if(conn!=null){conn.close();}
			}catch(Exception e){}
		}
	} 	
	
	private void GeneratePreparedIntoTempTable(Connection conn,String fromDate,String toDate,boolean isALL,String temp_tbtProject, String temp_tbtDataTrans1, String temp_tbtDataKeyin2,
 				String temp_tbtResource,String []projectArr) {
 			StringBuffer sql1 = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 	        try{
 	        	//initial parameter	
 	  			//*******************************
    			String sqlCreateTempDataTable1 = " Create temp table "+temp_tbtDataTrans1+" (com_id char(2),proj_id char(3),n_proj varchar(60),yymm int, cnt int );  ";
      			String sqlDeleteTempDataTable1 = " delete "+temp_tbtDataTrans1;
      			
      			String sqlCreateTempDataTable2 = " Create temp table "+temp_tbtDataKeyin2+" (com_id char(2),proj_id char(3),n_proj varchar(60),yymm int, cnt int );  ";
      			String sqlDeleteTempDataTable2 = " delete "+temp_tbtDataKeyin2;
      			
      			String sqlCreateTempResource3 = " Create temp table "+temp_tbtResource+" (com_id char(2),proj_id char(3),n_proj varchar(60),yymm int, "+Field_T_CNT+" int,"+Field_K_CNT+" int );  ";
      			String sqlDeleteTempResource3 = " delete "+temp_tbtResource;

      			//String sqlCreateDDLTempTableResource = " (brd char(10),com char(2),prj char(3),n_proj char(50),yymm int,e_cnt int,s_cnt int); ";

        		/************************************************/
            	//1.Insert project to temp table
        		/************************************************/
      			if(isALL){
      				this.InsertTempTableProjectALL(conn, temp_tbtProject);
      			}else{
            		this.InsertTempTableProject(conn,temp_tbtProject,projectArr);	
      			} 
      			//System.out.println("--Insert temp table OK.");       	
        		/************************************************/
        		//Create Temp table data1
        		try{
    	        	pstmt = conn.prepareStatement(sqlCreateTempDataTable1); 
    	        	pstmt.executeUpdate();
    	        	//System.err.println("-->1. create temp table :"+sqlCreateTempDataTable1);
        		}catch(Exception e){	
        			//(bck.temp_tbtdatar1) already exists in session.
        			System.err.println("MSG == (bck.temp_tbtdata1) already exists in session == ");
        			pstmt = conn.prepareStatement(sqlDeleteTempDataTable1); 
    	        	pstmt.executeUpdate();
    	        	//System.out.println("-->2. Delete temp table :"+sqlDeleteTempTable);
        		}	
        		
        		/**************************
            	 * Create SQL บ้านโอน  From acscontr
            	 * *************************/
        		sql1.delete(0,sql1.length());
            	sql1.append(" Select  x.com_id ,x.proj_id,year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_sort) as cnt   ")
    			    .append(" From lan:acscontr a,"+temp_tbtProject+" x  ")
    				.append(" Where   ")
    				.append(" a.d_close_law is not null  ")
    				.append(" AND a.f_contr is null      ")
    				.append(" AND a.i_company = x.com_id  ")
    				.append(" AND a.i_project = x.proj_id ")
    				.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
    				.append(" Group by 1,2,3  ")
    				.append(" Order by com_id,proj_id,yymm ");      
            	/************
            	 * CALL prepared temp table 1
            	 * ***********/
            	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtDataTrans1);

        		/**************************
            	 * ROW#2  Key ในระบบ
            	 * *************************/
        		//Create Temp table data2
        		try{
    	        	pstmt = conn.prepareStatement(sqlCreateTempDataTable2); 
    	        	pstmt.executeUpdate();
    	        	//System.out.println("-->2. create temp temp_tbtDataKeyin2 :"+sqlCreateTempDataTable2);
        		}catch(Exception e){	
        			//(bck.temp_tbtdatar1) already exists in session.
        			System.err.println("MSG == (bck.temp_tbtDataKeyin2) already exists in session == ");
        			pstmt = conn.prepareStatement(sqlDeleteTempDataTable2); 
    	        	pstmt.executeUpdate();
    	        	//System.out.println("-->2. Delete temp table :"+sqlDeleteTempTable);
        		}
        		sql1.delete(0,sql1.length());
            	sql1.append(" Select  x.com_id ,x.proj_id, year(a.d_close_law)||month(a.d_close_law) as yymm,count(distinct b.i_lock) as cnt   ")
    				.append(" FROM lan:acscontr a ,lan:ipv_qchd b,"+temp_tbtProject+" x")
    				.append(" Where  a.i_company = b.i_company    ")
    				.append(" AND a.i_project = b.i_project    ")
    				.append(" AND a.i_sort = b.i_lock   ")
    				.append(" AND b.f_status <> 'CAN'  ")
    				.append(" AND a.i_company = x.com_id ")
    				.append(" AND a.i_project = x.proj_id ")
    				.append(" AND a.f_contr is null  ")
    				.append(" AND ((b.i_type = '1' and b.i_ipv_docno is not null ) or (b.i_type in ('2','3','4'))) ")
    				.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
    				.append(" Group by 1,2,3 ")
    				.append(" Order by com_id,proj_id,yymm ");    

            	/************
            	 * CALL prepared temp table
            	 * ***********/
            	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtDataKeyin2);
 	        	//*********End Insert temp tableData#1

            	/**************************
 	        	 * For temp table Data resource
 	        	 * *************************/
        		try{
    	        	pstmt = conn.prepareStatement(sqlCreateTempResource3); 
    	        	pstmt.executeUpdate();
    	        	//System.out.println("-->2. create temp temp_tbtResource :"+sqlCreateTempResource3);
        		}catch(Exception e){	
        			//(bck.temp_tbtdatar1) already exists in session.
        			System.err.println("MSG == (bck.temp_tbtResource) already exists in session == ");
        			pstmt = conn.prepareStatement(sqlDeleteTempResource3); 
    	        	pstmt.executeUpdate();
    	        	//System.out.println("-->2. Delete temp table :"+sqlDeleteTempTable);
        		}
 	    		/********* Main Unoin table1&table2 *****************/ 
	    		sql1.delete(0,sql1.length());
 	        	sql1.append(" Select  com_id , proj_id ,  yymm From (   ")
 					.append(" (select * From "+temp_tbtDataTrans1+" ) ")
 					.append(" union ")
 					.append(" (select * From "+temp_tbtDataKeyin2+" ) ")
 					.append(" )  ")
 					.append(" Where 1=1 ")
 					.append(" Group by com_id , proj_id ,yymm ")
 					.append(" Order by com_id , proj_id , yymm  ");      		

 	    		//********************* 	        	
 	        	/************
 	        	 * CALL prepared union temp table
 	        	 * ***********/
 	        	PreparedInsertTempTableResource(conn, sql1.toString(), temp_tbtResource,temp_tbtDataTrans1,temp_tbtDataKeyin2);
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

	private void InsertTempTableProjectALL(Connection conn,String tempTableProject) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial parameter	        
        	String sqlDelete = " Delete "+tempTableProject;
        	//int i=1;
        	//System.out.println("##InsertTempTable ->Starting.");        	 
			/******************************************************/
        	try{
	        	sql.delete(0, sql.length());
				sql.append(" Create temp table "+tempTableProject+" (  ")
				   .append(" com_id char(2),  ")
				   .append(" proj_id char(3) ")
				   .append(" ); ");	
	        	pstmt = conn.prepareStatement(sql.toString()); 
	        	pstmt.executeUpdate();
	        	//System.out.println("-->1. executeUpdate : temp  :"+tempTableProject);
        	}catch(Exception e){
        		System.err.println("MSG == already exists in session (bck."+tempTableProject+") ==");
	        	pstmt = conn.prepareStatement(sqlDelete); 
	        	pstmt.executeUpdate();
	        	//System.out.println("-->2.Delete temp table :"+tempTableProject);
        	}

 			sql.delete(0, sql.length());
 			sql.append(" Select  distinct a.i_company ,a.i_project ")
 			   .append(" From lan:acsbudgh a ,lan:acxprojt b ")
 			   .append(" Where a.d_year = year(TODAY)+543  and  a.i_budg_type in ('1','2','9') and  (a.i_company = b.i_company) and (a.i_project= b.i_project)  ")
 			   .append(" AND a.i_project[1,1]<> 'G' ")
 			   .append(" Order By i_company,i_project ");	
 			pstmt = conn.prepareStatement(sql.toString()); 
 			rs = pstmt.executeQuery();	
 			
 			
        	//insert into tblByProject values( "LH","075" )
			sql.delete(0, sql.length());
			sql.append(" INSERT INTO  "+tempTableProject+"(com_id,proj_id)  VALUES( ? , ? ); ");
			//System.out.println("2.Insert SQL :"+sql.toString());
		    pstmt = conn.prepareStatement(sql.toString()); 

		    final int batchSize = 1000;//1000;
		    int count = 0;
		    
			while(rs.next()){
				pstmt.setString(1,doString.checkString(rs.getString("i_company"),""));
 			    pstmt.setString(2,doString.checkString(rs.getString("i_project"),""));				
 			    pstmt.addBatch();
 			    if(++count % batchSize == 0) {
			    	//System.out.println("===xxx:"+count);
			    	pstmt.executeBatch();
			    	pstmt.clearBatch();//clear the batch after execution
			    	count = 0;//reset count
		    	}//#End IF
			}		    
		    //System.out.println("-->1. xxxx");
		    pstmt.executeBatch();
			//********************************************************/
		  	//System.out.println("##InsertTempTableProjectALL ->successfully.");				  	 		  	 
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
	private void InsertTempTableProject(Connection conn,String tempTableProject, String projectArr[]) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial parameter	        
        	String sqlDelete = " Delete "+tempTableProject;
        	//int i=1;
        	//System.out.println("##InsertTempTable ->Starting.");        	 
			/******************************************************/
        	try{
	        	sql.delete(0, sql.length());
				sql.append(" Create temp table "+tempTableProject+" (  ")
				   .append(" com_id char(2),  ")
				   .append(" proj_id char(3) ")
				   .append(" ); ");	
	        	pstmt = conn.prepareStatement(sql.toString()); 
	        	pstmt.executeUpdate();
	        	//System.out.println("-->1. executeUpdate : temp  :"+tempTableProject);
        	}catch(Exception e){
        		System.err.println("MSG == already exists in session (bck."+tempTableProject+") ==");
	        	pstmt = conn.prepareStatement(sqlDelete); 
	        	pstmt.executeUpdate();
	        	//System.out.println("-->2.Delete temp table :"+tempTableProject);
        	}
        	//insert into tblByProject values( "LH","075" )
			sql.delete(0, sql.length());
			sql.append(" INSERT INTO  "+tempTableProject+"(com_id,proj_id)  VALUES( ? , ? ); ");
			//System.out.println("2.Insert SQL :"+sql.toString());
		    pstmt = conn.prepareStatement(sql.toString()); 
		    
		    String [] temp = null;
		    final int batchSize = 1000;//1000;
		    int count = 0;
        	if(projectArr!=null){
        		for(int n = 0;n<projectArr.length;n++){
        			temp = projectArr[n].split("\\:");
        			pstmt.setString(1, temp[0]);
     			    pstmt.setString(2, temp[1]);
     			    //pstmt.executeUpdate();
     			    //System.out.println("---Insert Okay :"+n);
     			    pstmt.addBatch();
	  		    	if(++count % batchSize == 0) {
	  		    		 //System.out.println("===xxx:"+count);
	  		    		 pstmt.executeBatch();
	  		    		 pstmt.clearBatch();//clear the batch after execution
	  		    	     count = 0;//reset count
	  		    	}//#End IF
        		}//#End For
    		    //System.out.println("-->1. xxxx");
    		    pstmt.executeBatch();
        	}
			//********************************************************/
		  	//System.out.println("##InsertTempTable ->successfully.");				  	 		  	 
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
	
	private List  ListReportCaseFetchData(Connection conn,String fromDate,String toDate,int MAX_LOOP,String[] COULUMN_DATE_QUERY,
			String temp_tbtResource,String cnt){
			StringBuffer sql1 = new StringBuffer();	
			StringBuffer sqlFetch = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			try{
	        	List objListRet  = new ArrayList();
	        	String str[] = null;
	        	int MAX_COLUMN = 3+MAX_LOOP; //
	  			//-----------------
	  			String []tempMatrix = null;
	  			//Get data for report for E-Serivce
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.GetFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtResource,cnt));			    
			    //System.out.println("SQL from table :"+temp_tbtResource);
			    pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	int loopColumn = 3;
	        	int loop = 1;
	        	while(rs.next()){
	        		//System.out.println(" Loop :"+loop);
	        		//----------------EService	        		
	        		tempMatrix = new String[MAX_COLUMN];
	        		for (int i=0; i < MAX_COLUMN; i++) {
	        			tempMatrix[i] = "";//Allocate a values in row&coulumn	
	        			if(i>2){
	        				tempMatrix[i] = "0";//Allocate a values in row&coulumn	
	        			}
	 	    		} 
	        		tempMatrix[0] = doString.checkString(rs.getString("com_id"),"");
	        		tempMatrix[1] = doString.checkString(rs.getString("proj_id"),"");
	        		tempMatrix[2] = doString.checkString(rs.getString("n_proj"),"");

	        		//--------------	        		
	        		loopColumn = 3;//3,4,5,6,7,8,9,10...N
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31	        			
	        			tempMatrix[loopColumn] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
		        		loopColumn++;
	        		}
	        		objListRet.add(tempMatrix);	
	        		loop++;
	        	}
	        	rs = null;

	        	//---#End ---/
			  	return objListRet;			  	 
			}catch(Exception e){
				System.out.println("!!!ListReportCaseFetchData, " +sysName+":"+ clazzName + " : " + e.getMessage());
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

	private int IntCountRowByACSContr$IPV_QCHD(Connection conn, String comId, String projId, String temp_tbtProject,String rbtType,String fromDate,String toDate) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		int totalRow=0; 
        try{
        	//initial parameter	  
			/******************************************************/
        	if(rbtType.equals("1") || rbtType.equals("2")){//Left Join
	            sql.delete(0,sql.length());
	    		sql.append(" Select  count( a.i_sort) as totalRow  ")
	    			.append(" FROM lan:acscontr a LEFT JOIN lan:ipv_qchd b ON ")
	    			.append(" ( a.i_company 	= b.i_company  ")
	    			.append("  and a.i_project = b.i_project   ")
	    			.append("  and a.i_sort = b.i_lock  ) ")
	    			.append("  Where ")
	    			.append("  a.i_company = ? and a.i_project = ?  ")
	    			.append("  AND ((b.i_type = '1' and b.i_ipv_docno is not null ) or (b.i_type in ('2','3','4'))) ")
	    			.append("  and  a.f_contr is null ")
	    			.append("  and a.d_close_law between  '").append(fromDate).append("'").append(" and '").append(toDate).append("'");
	    		//System.out.println("SQL Query CASE 2 : "+sql.toString());
	    		pstmt = conn.prepareStatement(sql.toString()); 
	    		pstmt.setString(1,comId);
	    		pstmt.setString(2,projId);
    		}else if(rbtType.equals("3") ||rbtType.equals("4") ){
    			sql.delete(0,sql.length());
    			sql.append(" Select  count( a.i_sort) as totalRow  ")
    				.append(" FROM lan:acscontr a ,lan:ipv_qchd b,"+temp_tbtProject+" x")
    				.append(" Where  a.i_company = b.i_company    ")
    				.append(" AND a.i_project = b.i_project    ")
    				.append(" AND a.i_sort = b.i_lock   ")
    				.append(" AND a.i_company = x.com_id ")
    				.append(" AND a.i_project = x.proj_id ")
    				.append(" AND a.f_contr is null  ")
    				.append(" AND ((b.i_type = '1' and b.i_ipv_docno is not null ) or (b.i_type in ('2','3','4'))) ")
    				.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ");

	    		//System.out.println("SQL Query CASE 3 : "+sql.toString());
	    		pstmt = conn.prepareStatement(sql.toString());    			
    		}      		
			rs = pstmt.executeQuery();	
			if(rs.next()){				
				totalRow = rs.getInt("totalRow");
			}
			rs.close();				
			//********************************************************/
		  	//System.out.println("##IntCountRowByACSContr$IPV_QCHD->End.");				  	 
		  	return totalRow;			  	 
		}catch(Exception e){
			System.out.println("!!!IntCountRowByACSContr$IPV_QCHD , " +sysName+":"+ clazzName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
			return totalRow;
		}
		finally{			
			//clean up.
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
			}catch(Exception e){}
		}
	}
	
	private ArrayList<List> ListSearchByACSContr$IPV_QCHD(Connection conn,String comId, String projId, String temp_tbtProject,String rbtType,String fromDate,String toDate,int startRow,int endRow,int maxRow) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter		
        	//int line = 0;
        	//System.out.println("##ListSearchByACSContr$IPV_QCHD->Starting.");   
        	ArrayList<List>  resultList = new ArrayList<List> ();
        	List strArr = null;    	 
        	if(rbtType.equals("1") || rbtType.equals("2")){//Left Join CASE,1,2
	            sql.delete(0,sql.length());
    			//sql.append(" Select   a.i_company,a.i_project,a.i_sort,a.d_close_law as DCLOSE,b.i_docno,b.i_vendor,b.i_ipv_docno,b.i_type,b.f_status,b.c_desc,date(b.d_keyin) as DKEYIN ")
	            sql.append(" Select   a.i_company,a.i_project,a.i_sort,a.d_close_law as DCLOSE,b.i_docno,b.i_vendor,b.i_ipv_docno,b.i_type,b.f_status,b.c_desc,b.d_keyin as DKEYIN ")
	     		   .append(" ,b.z_amount_pv,b.f_qa_type,b.i_qa_vendor ")
	     		   .append(" FROM lan:acscontr a LEFT JOIN lan:ipv_qchd b ON ")
	     		   .append(" ( a.i_company 	= b.i_company  ")
	     		   .append("  and a.i_project = b.i_project   ")
	     		   .append("  and a.i_sort = b.i_lock  ) ")
	     		   .append("  Where ")
	     		   .append("  a.i_company = ? and a.i_project = ?  ")
	     		   .append("  AND b.f_status <> 'CAN'  ")
	     		   .append("  and  a.f_contr is null ")
	     		   .append("  AND ((b.i_type = '1' and b.i_ipv_docno is not null ) or (b.i_type in ('2','3','4'))) ")
	     		   .append("  and a.d_close_law between  '").append(fromDate).append("'").append(" and '").append(toDate).append("'")
	     		   .append("  ORDER BY  a.i_company,a.i_project,a.i_sort,b.d_keyin ");
    			
	    		//System.out.println("SQL Query CASE 1,2: "+sql.toString());
	    		pstmt = conn.prepareStatement(sql.toString()); 
	    		pstmt.setString(1,comId);
	    		pstmt.setString(2,projId);
    		}else if(rbtType.equals("3") ||rbtType.equals("4") ){
    			sql.delete(0,sql.length());
     			//sql.append(" Select   a.i_company,a.i_project,a.i_sort,a.d_close_law as DCLOSE,b.i_docno,b.i_vendor,b.i_ipv_docno,b.i_type,b.f_status,b.c_desc,date(b.d_keyin) as DKEYIN ")
	            sql.append(" Select   a.i_company,a.i_project,a.i_sort,a.d_close_law as DCLOSE,b.i_docno,b.i_vendor,b.i_ipv_docno,b.i_type,b.f_status,b.c_desc,b.d_keyin as DKEYIN ")
	     		    .append(" ,b.z_amount_pv ,b.f_qa_type,b.i_qa_vendor ")
	     		    .append(" FROM lan:acscontr a LEFT JOIN lan:ipv_qchd b ON ")
 	    			.append(" ( a.i_company 	= b.i_company  ")
 	    			.append("  and a.i_project = b.i_project   ")
 	    			.append("  and a.i_sort = b.i_lock  ) ,"+temp_tbtProject+" x")
 	    			.append("  Where ")
 	    			.append("  a.i_company = x.com_id  and a.i_project = x.proj_id  ")
 	    			.append("  AND b.f_status <> 'CAN'  ")
 	    			.append("  and  a.f_contr is null ")
 	    			.append("  AND ((b.i_type = '1' and b.i_ipv_docno is not null ) or (b.i_type in ('2','3','4'))) ")
 	    			.append("  and a.d_close_law between  '").append(fromDate).append("'").append(" and '").append(toDate).append("'")
 	    			.append("  ORDER BY  a.i_company,a.i_project,a.i_sort,b.d_keyin ");

	    		//System.out.println("SQL Query CASE 3 : "+sql.toString());
	    		pstmt = conn.prepareStatement(sql.toString());    			
    		}        		

			rs = pstmt.executeQuery();
			while(rs.next()){
			//for (int i=0;i<maxRow;i++) { 
	        //        if (rs.next()) {
	        //           if (i>=startRow && i<=endRow) {	
							strArr = new ArrayList();
				   			strArr.add(0,doString.checkString(rs.getString("i_company"),""));//i_company		  
				   			strArr.add(1,doString.checkString(rs.getString("i_project"),""));//i_project
				   			strArr.add(2,doString.checkString(rs.getString("i_sort"),""));//i_sort	
				   			strArr.add(3,toDDMMYY_THAI2(doString.checkString(rs.getString("DCLOSE"),"")));//DCLOSE
				   			strArr.add(4,doString.checkString(rs.getString("i_docno"),""));//i_docno-----------------------KEY is Available
				   			strArr.add(5,doString.checkString(rs.getString("i_vendor"),"&nbsp;"));//i_vendor
				   			strArr.add(6,doString.checkString(rs.getString("i_ipv_docno"),"&nbsp;"));//i_ipv_docno
				   			strArr.add(7,doString.checkString(rs.getString("i_type"),"&nbsp;"));//i_type
				   			strArr.add(8,doString.checkString(rs.getString("f_status"),"&nbsp;"));//f_status
				   			strArr.add(9,doString.checkString(rs.getString("c_desc"),"&nbsp;"));//c_desc
				   		    strArr.add(10,toDDMMYY_TIME_THAI2(doString.checkString(rs.getString("DKEYIN"),"")));//D_Keyin 2014-09-11    
				   		    strArr.add(11,GetProjectName(conn, doString.checkString(rs.getString("i_company"),""),doString.checkString(rs.getString("i_project"),"")));//N_project
				   			if(isValueStrAndObj(rs.getString("i_vendor"))){
				   				strArr.add(12,GetVendorName(conn, doString.checkString(rs.getString("i_vendor"),"&nbsp;")));
				   			}else{
				   				strArr.add(12,"");
				   			}
				   			strArr.add(13,doString.checkString(rs.getString("z_amount_pv"),"0"));//i_in_out
				   			strArr.add(14,"");
				   			if(isValueStrAndObj(rs.getString("i_ipv_docno"))){
				   				strArr.add(14,doString.checkString(toDDMMYY_THAI2(this.GetDpayFrom$IPV_PVDHD(conn, rs.getString("i_ipv_docno"))),"&nbsp;"));
				   			}
				   			
				   			strArr.add(15, doString.checkString(rs.getString("f_qa_type"),""));//null,1,2
				   			if(isValueStrAndObj(rs.getString("f_qa_type"))){
				   				strArr.add(16,"&nbsp;");
				   				if(doString.checkString(rs.getString("f_qa_type"),"").equals("2") && isValueStrAndObj(rs.getString("i_qa_vendor"))){
					   				strArr.add(16,GetVendorNameQA(conn,doString.checkString(rs.getString("i_qa_vendor"),"")));
				   				}
				   			}else{
				   				strArr.add(16,"&nbsp;");
				   			}

				   			//GetVendorNameQA(conn, vendorId);
		   					resultList.add(strArr);	
			       		//line++;                         
	                   //} //--end if check row
		               //if (i>endRow){ 
		               //break;
		               //}
	                //} //end if check rs
		        } // end for
				//********************************************************/				
        	return resultList;			  	 
		}catch(Exception e){
			System.out.println("!!!ListSearchByACSContr$IPV_QCHD , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
	
	private String GetVendorName(Connection conn, String vendorId) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String  tempName = "";
        try{
        	//initial parameter	     	
			/*************************************************/			
			sql.delete(0,sql.length());
			sql.append(" Select a.i_vendor,b.bus_name   ")
			   .append(" From lan:ipv_vendor a,lan:stpvendr b ")
			   .append(" Where  a.i_vendor = b.vend_code ")
			   .append(" and  a.i_vendor = ? ");
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, vendorId);	
			//System.out.println("SQL :"+sql.toString());
			rs = pstmt.executeQuery();	
			if(rs.next()){
				tempName = doString.checkString(rs.getString("bus_name"), "");
			}
			rs.close();	
	   			
			//**************************************************/
		  	//System.out.println("##GetVendorName ->successfully.");				  	 
		  	return tempName;			  	 
		}catch(Exception e){
			System.out.println("!!!GetVendorName , " +sysName+":"+ clazzName + " : " + e.getMessage());
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

	private String GetDpayFrom$IPV_PVDHD(Connection conn, String docId) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String  dPay = "";
        try{
        	//initial parameter	     	
			/*************************************************/			
			sql.delete(0,sql.length());
			sql.append(" Select  d_pay  ")
			   .append(" From lan:ipv_pvdhd  ")
			   .append(" Where  i_docno = ? ");
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, docId);	
			//System.out.println("SQL :"+sql.toString());
			rs = pstmt.executeQuery();	
			if(rs.next()){
				dPay = doString.checkString(rs.getString("d_pay"), "");
			}
			rs.close();	
	   			
			//**************************************************/
		  	//System.out.println("##GetDpayFrom$IPV_PVDHD ->successfully.");				  	 
		  	return dPay;			  	 
		}catch(Exception e){
			System.out.println("!!!GetDpayFrom$IPV_PVDHD , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
	
	public int GetCountTempTable(Connection conn,String comId, String projId,int yymm,String temp_table) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			int  cnt = 0;
	        try{
	        	//initial parameter	     	
				/*************************************************/			
	        	//*****Find project by user login  
				sql.delete(0,sql.length());
				sql.append("Select cnt From "+temp_table+" ")				
				   .append(" Where  ")
				   .append(" com_id = ?  ")
				   .append(" AND proj_id = ?  ")
				   .append(" AND yymm = ? ");
				pstmt = conn.prepareStatement(sql.toString()); 	
				pstmt.setString(1, comId);
				pstmt.setString(2, projId);
				pstmt.setInt(3, yymm);

				//System.out.println("GetCountTempTable SQL :"+sql.toString());
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
	
	private void PreparedInsertTempTableResource(Connection conn,String sqlMain,String temp_table,String tempT1,String tempT2) {
			//StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	        try{
	        	//initial paramter	
	        	boolean isDel = false; 	        	        	
	  			String sqlInsert = " Insert into "+temp_table+" (com_id ,proj_id, n_proj ,yymm ,t_cnt,k_cnt) values (?, ? , ? ,? , ?, ?  ); ";
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
			  
			    final int batchSize = 1000;//1000;
			    int count = 0;
			    //------------------------
			    while(rs.next()){
	 			    n_project = "";
	 			    count1 = 0;
	 			    count2 = 0;
			    	//Get project name 
	 			    n_project = GetProjectName(conn, rs.getString("com_id"), rs.getString("proj_id"));
			    	//Get cnt off e-Service
	 			    count1 = GetCountTempTable(conn, rs.getString("com_id"), rs.getString("proj_id"), rs.getInt("yymm"), tempT1);
			    	//Get cnt off SVC
	 			    count2 = GetCountTempTable(conn,rs.getString("com_id"), rs.getString("proj_id"), rs.getInt("yymm"), tempT2);
			    	//---For Add batch

			    	 pstmt.setString(1, rs.getString("com_id"));
			    	 pstmt.setString(2, rs.getString("proj_id"));
			    	 pstmt.setString(3, doString.UnicodeToMS874(n_project));
			    	 pstmt.setInt(4, rs.getInt("yymm"));
			    	 pstmt.setInt(5, count1);
			    	 pstmt.setInt(6, count2);
			    	 
			    	 pstmt.addBatch();
			    	 //Add row to the batch.
					 if(++count % batchSize == 0) {
						//System.out.println("===xxx:"+count);
						pstmt.executeBatch();
						pstmt.clearBatch();//clear the batch after execution
						count = 0;//reset count
					}//#End IF
			    }
			    //pstmt.executeBatch();
    		    //System.out.println("-->1. xxxx");
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
	
	private void PreparedInsertTempTable(Connection conn,String sqlMain,String temp_tbtData) {
		//StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter	
        	boolean isDel = false;
  			String sqlInsert = " Insert into "+temp_tbtData+" (com_id ,proj_id ,n_proj ,yymm, cnt ) values (?, ?, ?, ?, ?); ";
        	String sqlDeleteTempTable = " Delete "+temp_tbtData;
        	String sqlSelectTempTable = " Select * From "+temp_tbtData;
        	
        	pstmt = conn.prepareStatement(sqlSelectTempTable); 
        	rs = pstmt.executeQuery();
        	if(rs.next()){
        		isDel = true;
        	}
        	rs = null;
        	
        	if(isDel){
    			pstmt = conn.prepareStatement(sqlDeleteTempTable); 
	        	pstmt.executeUpdate();
	        	//System.out.println("-->1. Delete temp table :"+sqlDeleteTempTable);
        	}
  			pstmt = conn.prepareStatement(sqlMain); 
        	//System.out.println("2.SQL_main:"+sqlMain);        	
		    rs = pstmt.executeQuery();	

		    /* Prepared insert temp table
		     * */	
		    pstmt = conn.prepareStatement(sqlInsert); 
		    //System.out.println("-->1. SQL: "+sqlInsert.toString());
		    //************************
		    final int batchSize = 1000;//1000;
		    int count = 0;
		    String projectName = "";
		    while(rs.next()){

		    	 projectName = "";
		    	 projectName = GetProjectName(conn, rs.getString("com_id"), rs.getString("proj_id"));
		    	 pstmt.setString(1, rs.getString("com_id"));
		    	 pstmt.setString(2, rs.getString("proj_id"));
		    	 pstmt.setString(3, doString.UnicodeToMS874(projectName));
		    	 pstmt.setInt(4, rs.getInt("yymm"));
		    	 pstmt.setInt(5, rs.getInt("cnt"));
		    	 //Add row to the batch.
		    	 pstmt.addBatch();
		    	 if(++count % batchSize == 0) {
		    		 //System.out.println("===count:"+count);
		    		 pstmt.executeBatch();
		    		 pstmt.clearBatch();//clear the batch after execution
		    	     count = 0;//reset count
		    	 }
		    }
		    pstmt.executeBatch();
		    rs.close();
		    //System.out.println("4.-->executeBatch  OK ");
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
	private String GetProjectName(Connection conn, String comId, String projectId) {
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
			pstmt.setString(1, comId);	
			pstmt.setString(2, projectId);
			//System.out.println("SQL :"+sql.toString());
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
	private static String GetFetchSQL(int MAX_LOOP,String []COULUMN_DATE_QUERY,String temp_tbtData,String cnt){
		   StringBuffer sql1 = new StringBuffer();
		   StringBuffer sqlFetch = new StringBuffer();
		   String []str = null;
	       
		   sql1.delete(0,sql1.length());
		  //sql1.append("  ");
	  		for(int i = 0;i<MAX_LOOP;i++){
	  		    str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
	  		    sql1.append(" sum(CASE WHEN YYMM = "+getYYMM(str[0], str[1])+" THEN "+cnt+" ELSE 0 END) AS  M"+getYYMM(str[0], str[1])+" ,  ");
	  		}

	  		sqlFetch.delete(0,sqlFetch.length());
	  		sqlFetch.append(" SELECT  com_id,proj_id,n_proj,   ");
	  		sqlFetch.append(sql1.toString().substring(0,sql1.toString().lastIndexOf(",")));
	  		sqlFetch.append(" FROM "+temp_tbtData+"  ")
	  				.append(" Group by com_id,proj_id,n_proj  ")
	  				.append(" ORDER BY com_id,proj_id ");	
	  		//System.out.println("SQL xxx :"+sqlFetch.toString());
	  		return sqlFetch.toString();
	}	
	private List<HashMap> ListProjectResposible(Connection conn, String userId) {
		// TODO Auto-generated method stub
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String tempProject = "";
        try{
        	//initial parameter		      
        	List  projectDDL = new ArrayList();
        	HashMap<String, String> hashMap = null;   
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
 	    		hashMap = new HashMap<String, String>();
				hashMap.put("value", "AA:999");
				hashMap.put("name", "---- ALL Project ----");//doString.UnicodeToMS874("---- ALL Project ----")
				projectDDL.add(hashMap);
			}else{
				//case by user.
    			sql.delete(0, sql.length());
    			sql.append("Select a.com_id || ':' || a.proj_id  as value, '[' || a.com_id || '-' || a.proj_id || '] ' || n_project as name , a.proj_id   ")
    				.append(" From lan:serv_pstaff a ,lan:acxprojt b  ")
    				.append(" Where (user_id= ? ) and (a.com_id = b.i_company) and (a.proj_id= b.i_project)  ")
    				.append(" Order By value ");
    			pstmt = conn.prepareStatement(sql.toString()); 
    			pstmt.setString(1, userId);	
			}
		
			//System.out.println("ListProjectResposible SQL :"+sql.toString());
			rs = pstmt.executeQuery();		    			
			while(rs.next()){
				hashMap = new HashMap<String, String>();
				hashMap.put("value", doString.checkString(rs.getString("value"),""));
				hashMap.put("name", doString.checkString(rs.getString("name"),""));
				projectDDL.add(hashMap);
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
    private List<HashMap> ListProjectSelect(Connection conn,String []projArr) {
			// TODO Auto-generated method stub
 			StringBuffer sql = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 			//String tempProject = "";
 	        try{
 	        	//initial paramter	 	       	 	
	 	       	List  projectDDL = new ArrayList();
	        	HashMap<String, String> hashMap = null;   
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
 	        			//set parameter into prepared sql
 	        			pstmt.setString(1, temp[0]);
 	     			    pstmt.setString(2, temp[1]);
 	     			    rs = pstmt.executeQuery();	
 	     			    if(rs.next()){
 							hashMap = new HashMap<String, String>();
 							hashMap.put("value", doString.checkString(rs.getString("value"),""));
 							hashMap.put("name", doString.checkString(rs.getString("name"),""));
 							projectDDL.add(hashMap);
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
    
    private static String GetVendorNameQA(Connection conn, String vendorId) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String  tempName = "";
        try{
        	//initial paramter	     	
			/*************************************************/			
			sql.delete(0,sql.length());
			sql.append(" select I_COMPANY,I_PROJECT,I_VENDOR,N_VENDOR,C_DESC,STATUS from lan:IPV_QCVENDOR ")
			   .append(" WHERE STATUS = 'A' ")
			   .append(" and I_VENDOR = ? ");
			pstmt = conn.prepareStatement(sql.toString());
			pstmt.setString(1, vendorId); //vendorId
			rs = pstmt.executeQuery();
			if(rs.next()){
				tempName = doString.DisplayThai(doString.checkString(rs.getString("N_VENDOR"), ""));
			}
			rs.close();	
		}catch(Exception e){
 				System.out.println("!!! GetVendorNameQA Error : " + e.getMessage());
		}
		finally{			
			//clean up.
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
			}catch(Exception e){}
		}
	  return tempName;		
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
	//Method get Link next page url
	private static String GenLinkNextPageHTML(int tmpMax,int nowPage,int displayLine)throws Exception {
		String pageLink = "";
		int tmpPage = 0;
		//System.out.println("tmpMax :"+tmpMax);
    	while (tmpMax>0) {
    	       tmpMax -= displayLine;
    	       tmpPage++;
    	       if (nowPage==tmpPage) {
    	          pageLink += "&nbsp; <b>"+tmpPage+"</b> ";
    	       } else {
    	          pageLink += "&nbsp; <a href='#' onclick='changePage("+tmpPage+");'>"+tmpPage+"</a> ";
    	       }
    	}//End while
    	if (tmpPage>1) {
    	      int prev = nowPage-1;
    	      if (prev<1) {
    	    	  prev=1; 
    	      }
    	      pageLink = "<a href='#' onclick='changePage("+prev+");'><img src=\"images/b4_previous.gif\" border=\"0\" align=\"absmiddle\" style=\"cursor:hand\"></a>&nbsp; "+pageLink;
    	      int next = nowPage+1;
    	      if (next>tmpPage) {
    	    	  next = tmpPage;
    	      }
    	      pageLink += "&nbsp; <a href='#' onclick='changePage("+next+");'><img src=\"images/b4_next.gif\" border=\"0\" align=\"absmiddle\" style=\"cursor:hand\"></a>";      
    	   } else {
    	      pageLink = "หน้า <b>1</b>";
    	   }
    	return pageLink;
	}
	private static  String toDDMMYY_THAI2(String str){
		 if ((str == null) || str.equals("")) {
			 return  str;
		 }else{
			 String d2[] = str.split("\\-"); //2013-03-29
			 return d2[2]+"/"+d2[1]+"/"+(Integer.parseInt(d2[0])+543);
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
	//false = object is null / str is ""
	//true = object have value / string hava value 
	private static boolean isValueStrAndObj(String str) throws Exception{
		if ((str == null) || str.equals("")) {
			 return false;
		}else{
			 return true;
		 }
	} 
	//2016-04-25 22:10:00
	private static  String toDDMMYY_TIME_THAI2(String str){
		 if ((str == null) || str.equals("")) {
			 return  str;
		 }else{
			 String temp[] = str.split("\\ ");//2016-04-25 22:10:00
			 
			 String d2[] = temp[0].split("\\-"); //2013-03-29
			 return d2[2]+"/"+d2[1]+"/"+(Integer.parseInt(d2[0])+543+" "+temp[1].substring(0,5));
		 }
	}
	 private User authenUser(Connection conn, String userid) throws Exception {
		  Statement ustmt = null;
		  ResultSet rsUser = null;
		  User user = null;
		  String who = "";
		  String empId = "";
		  String name = "";
		  String password = "";
		  boolean acap = false;
		  StringBuffer sql = new StringBuffer();
		  try {
			  ustmt = conn.createStatement();
			  
			  //----========== If this user is vendor , get new name from stpvendr ==========----//
			  String userWho = "";
			  String userGroup = "";
			  String iPerson = "";
			  sql.delete(0,sql.length());
			  sql.append(" select user_who,i_person, user_group,user_password from lan:useracl where   user_id='").append(userid).append("' ");
			  rsUser = ustmt.executeQuery(sql.toString());
			  if (rsUser.next()) {
				  userWho = doString.checkString(rsUser.getString("user_who"),"");
				  iPerson = doString.checkString(rsUser.getString("i_person"),"");
				  userGroup = doString.checkString(rsUser.getString("user_group"),"");
				  password = doString.checkString(rsUser.getString("user_password"),"");
			  }
			  rsUser.close();
			  rsUser = null;
			  
			  sql.delete(0,sql.length());
			  sql.append("SELECT u.user_name, u.user_who, u.user_group, u.user_acl, u.user_email, ")
						.append("                  e.i_employ, TRIM(e.n_prename_th) || ' ' || TRIM(e.n_nemploy_th) || ' ' || TRIM(e.n_semploy_th) AS EMP_NAME, ")
						.append("                  j.i_job, j.i_company, c.n_company, j.i_division, j.d_job, d.n_desc AS DIVISION, ")
						.append("                  p.n_desc AS POSITION, g.a_dept, j.i_level ")
						.append(" FROM   lan:useracl u, docflow:acemploy e, docflow:acempjob j, ")
						.append("                 docflow:acempstd d, docflow:acempstd p, docflow:acxcompa c, docflow:dfz_dept g")
						.append(" WHERE u.user_id = '").append(userid).append("' ")
						.append("                  AND u.user_password = '").append(password).append("' ")
						.append("                  AND u.user_acl='S' AND e.i_employ = u.i_employ AND e.d_retry IS NULL ")
						.append("                  AND j.i_employ = e.i_employ AND d.i_type = '11' AND d.i_code = j.i_division ")
						.append("                  AND g.i_code = j.i_division AND p.i_type = '10' ")
						.append("                  AND p.i_code = j.i_job AND c.i_company = j.i_company ")
						.append(" ORDER BY j.d_job DESC ");
					//System.out.println("SQL : "+sql.toString());
					rsUser = ustmt.executeQuery(sql.toString());
		         
					//allow user
					if (rsUser != null) {
						if (rsUser.next() == true) {
							user = new User();
							empId = doString.checkString(rsUser.getString("I_EMPLOY"));
							user.setUserID(userid);
							user.setUserName(rsUser.getString("USER_NAME"));
							user.setUserWho(rsUser.getString("USER_WHO"));
							user.setUserGroup(rsUser.getString("USER_GROUP"));
							user.setUserACL(rsUser.getString("USER_ACL"));
							user.setEmail(rsUser.getString("USER_EMAIL"));
							user.setEmpId(empId);
							name = doString.checkString(rsUser.getString("EMP_NAME"));
							user.setEmpName(doString.checkString(rsUser.getString("EMP_NAME")));
							user.setPosition(doString.checkString(rsUser.getString("POSITION")));
							user.setDivisionId(doString.checkString(rsUser.getString("I_DIVISION")));
							user.setGroup(doString.checkString(rsUser.getString("A_DEPT")));
							user.setDivision(doString.checkString(rsUser.getString("DIVISION")));
							user.setCompanyId(doString.checkString(rsUser.getString("I_COMPANY")));
							user.setCompany(doString.checkString(rsUser.getString("N_COMPANY")));
							//user.setLevel(Integer.parseInt(doString.checkString(rsUser.getString("I_LEVEL"))));		        
						}
						rsUser.close();
						rsUser = null;
					}
			  ustmt.close();
			  ustmt = null;        
		  } catch (Exception e) {
			  System.out.println(e.getMessage());           
			   throw e;
		  }
		  // Do this no matter what.
		  finally {
			  // Clean up.
			  try {
				  try {
					  if (rsUser != null) {
						  rsUser.close();
					  }
				  } finally {
					  if (ustmt != null) {
						  ustmt.close();
					  }
				  }
			  } catch (SQLException ignore) {
			  }
		  }
		  return (user);
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
	private void DisplayMaxtrixList(List arrList) throws Exception{
		 String  str[] = null;
		 System.out.println("=====ArrayList size:"+arrList.size());
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