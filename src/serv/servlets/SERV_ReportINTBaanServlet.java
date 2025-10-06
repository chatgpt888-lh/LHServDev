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
 * Servlet implementation class for Servlet: SERV_ReportINTBaanServlet
 * create by : pradoem wonkraso ,go2doem@gmail.com, pradoem@lh.co.th
 * date time: 2015.02.12
 * version : 1.0
 * project : Report form  bann introduce
 * comment:  this class controller servlet for List Report baan transfer
 * check list by user 
 */

 public class SERV_ReportINTBaanServlet extends  DBServlet{
	    /* (non-Java-doc)
		 * @see javax.servlet.http.HttpServlet#HttpServlet()
		 */
	 	private final static String APPOINT_IN_7_DAY= "7";
	 	private final static String APPOINT_IN_8_DAY= "8";
	 	private final static String APPOINT_IN_14_DAY= "14";
	 	private final static String APPOINT_IN_15_DAY= "15";
	 	private final static String APPOINT_IN_30_DAY= "30";
	 	
		String thaiMonth[] = new String[] {"มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม",""};
		String shortMonth[] = new String[] {"ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค.",""};
	 	
		String sysName = "LHServ";
		String clazzName = new String(this.getClass().getName() + ".performTask :");	 
		public SERV_ReportINTBaanServlet() {
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

	        try{
	        	//printOutParam(request,"doGenReportForm");
	 			//----------Open connection
				//Open connection
				if (ds == null){getDS();}			
				conn = ds.getConnection();
				conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	  			//conn.setAutoCommit(false);

	            //-------------------------
				String tempProjectTxt = doString.checkString(request.getParameter("tempProjectTxt"),"");//LH:151|LH:152|LH:154|LH:156|LH:157
			
				
	  			String multiFlag = doString.checkString(request.getParameter("multiFlag"),"0"); //0=ALL Project,1= By project	  			
	  			String systemName = doString.checkString(request.getParameter("systemName"),""); 
	  			String args2 = doString.checkString(request.getParameter("args2"),""); //Day
	  			String fStatus = doString.checkString(request.getParameter("fStatus"),""); 
	  			String startDate = doString.checkString(request.getParameter("startDate"),""); 
	  			String endDate = doString.checkString(request.getParameter("endDate"),""); 
	  			//SVC,service
	  			boolean isAllProject = true;
	  			 ArrayList  projectList = new ArrayList();
	  			String sqlCriteria = "";
	  			if(multiFlag.equals("0")){//ALL project
	  				isAllProject = true;
	  			}else{// by project
	  				String []tempProjectId =tempProjectTxt.split("\\|"); 
		    		/************************************************/
		        	//1.Insert project to temp table
		    		/************************************************/	
		    		this.InsertTempTableProject(conn, tempProjectId);
		        	//System.out.println("--Insert temp table OK.");
		    		isAllProject = false;
		    		
		    		projectList = this.ListProjectSelect(conn, tempProjectId);
		    		
	  			}
	  			sqlCriteria = this.GenQuerySQLByProjectALL(systemName, args2, fStatus, startDate, endDate,isAllProject);	  			
	  			//System.out.println("SQL Main :"+sqlCriteria);
  			
				//*******************************************************************/		  		

		  		//------------------------------------------------------------------//
				int displayLine = Integer.parseInt(doString.checkString(request.getParameter("pageNoDDL"),"20"));				
				//***************Get Row from db
		        int maxRow = this.GetCountRowByProjectALL(conn, sqlCriteria);
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
				 ArrayList listDescHD =  this.ListByProjectALL$Paging(conn, sqlCriteria, startRow, endRow, maxRow); //mngService.ListSearchGroup$Items(conn, tempGroupId, tempItemId, doString.UnicodeToMS874(nameFindTxt),rbtFindType, startRow, endRow, maxRow);
				 
		  		 request.setAttribute("listDescHD", listDescHD);
		  		request.setAttribute("projSelectdList", projectList);
				 request.setAttribute("multiFlag",multiFlag);//0=ALL			 
				 request.setAttribute("systemName", systemName);
				 request.setAttribute("args2",args2);
				 request.setAttribute("fStatus",fStatus);
				 request.setAttribute("startDate",startDate);
				 request.setAttribute("endDate",endDate);

		   		//*********Dispatcher  
				/**********************************/
				request.setAttribute("displayLinkPage", pageLink); 
				request.setAttribute("pageNoDDL",pageNoDDL);
				request.setAttribute("displayLine", displayLine);
				request.setAttribute("recordNo", startRow);
					/************************************/
			  	//System.out.println("doGenReportForm ->successfully.");	  	
			  	 
			  	String tarGetUrl ="/SERV_ReportBaanINT_Desc.jsp";
		   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
				dispatcher.forward(request,response);	
				 
				/****** Clear *******/
				conn.close();
				conn = null;
			}catch(Exception e){
				System.out.println("!!! doFormDescription , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
		   		String tarGetUrl ="/SERV_ReportBaanINT.jsp";
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
		  		  ArrayList  projectList = new ArrayList();
		  		  List rptMainDataList = new ArrayList();	
		  		  if(multiFlag.equals("0")){//TODO: CASE : ALL Project
		  			rptMainDataList = this.ListGenReportCaseAllProject(conn, COULUMN_DATE_QUERY[MAX_LOOP-1], COULUMN_DATE_QUERY[0], MAX_LOOP, COULUMN_DATE_QUERY);
		  		  }else{//TODO: CASE : By project
		  			rptMainDataList =   this.ListGenReportCaseByProject(conn, COULUMN_DATE_QUERY[MAX_LOOP-1], COULUMN_DATE_QUERY[0], MAX_LOOP, projSelDDL, COULUMN_DATE_QUERY);
		  			projectList = this.ListProjectSelect(conn, projSelDDL);
		  		  }		
				  //*******************************************************************/		  			  		
		  		  request.setAttribute("projSelectdList", projectList);
		  		  request.setAttribute("rptMainDataList", rptMainDataList);
		  		  request.setAttribute("COULUMN_MONTH_YEAR", COULUMN_MONTH_YEAR);
		  		  request.setAttribute("COULUMN_DATE_QUERY", COULUMN_DATE_QUERY);
				  request.setAttribute("mmDDL1", mmDDL1);
				  request.setAttribute("yyDDL1",yyDDL1);
				  request.setAttribute("rbtType",rbtType);//LH:075
				  request.setAttribute("MAX_LOOP", MAX_LOOP);
				  request.setAttribute("multiFlag",multiFlag);//0=ALL
				
		   		//*********Dispatcher  	 
			  	//System.out.println("doGenReportForm ->successfully.");	  	
			  	 
			  	String tarGetUrl ="/SERV_ReportBaanINT_View.jsp";
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
	    			//---------------------------------------------				
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
		
		private void InsertTempTableProject(Connection conn, String projectArr[]) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	        try{
	        	//initial paramter	        
	        	String tblByProjectX = "tblByProjectX";
	        	String sqlDelete = " Delete "+tblByProjectX;
	        	int i=1;
	        	//System.out.println("##InsertTempTable ->Starting.");        	 
	        	
				/******************************************************/
	        	try{
		        	sql.delete(0, sql.length());
					sql.append(" Create temp table "+tblByProjectX+" (  ")
					   .append(" com_id char(2),  ")
					   .append(" proj_id char(3) ")
					   .append(" ); ");	
		        	pstmt = conn.prepareStatement(sql.toString()); 
		        	pstmt.executeUpdate();
		        	//System.out.println("-->1. executeUpdate : temp  :"+tblByProjectX);
	        	}catch(Exception e){
	        		System.out.println("MSG == already exists in session (bck.tblByProjectX) ==");
		        	pstmt = conn.prepareStatement(sqlDelete); 
		        	pstmt.executeUpdate();
		        	//System.out.println("-->2.Delete temp table :"+tblByProjectX);
	        	}
	        	//insert into tblByProject values( "LH","075" )
				sql.delete(0, sql.length());
				sql.append(" INSERT INTO  "+tblByProjectX+"(com_id,proj_id)  VALUES( ? , ? ); ");
				//System.out.println("2.Insert SQL :"+sql.toString());
			    pstmt = conn.prepareStatement(sql.toString()); 
			    
			    String [] temp = null;
	        	if(projectArr!=null){
	        		for(int n = 0;n<projectArr.length;n++){
	        			temp = projectArr[n].split("\\:");
	        			pstmt.setString(1, temp[0]);
	     			    pstmt.setString(2, temp[1]);
	     			    pstmt.executeUpdate();
	     			    //System.out.println("---Insert Okay :"+n);
	        		}
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
		
		public List ListGenReportCaseAllProject(Connection conn,String fromDate,String toDate,int MAX_LOOP,String[] COULUMN_DATE_QUERY ) {
			//	TODO Auto-generated method stub
			/*****************/		
			StringBuffer sql1 = new StringBuffer();	
			StringBuffer sqlFetch = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	        try{
	        	//initial paramter	
	        	String temp_tbtData1 = "temp_INT_tbtData1";
	        	List objList = new ArrayList();
	        	String str[] = null;
	  			int MAX_ROW = 22;
	  			int MAX_COULUMN = 12;
	  			String [][] strMatrix  = new String[MAX_ROW][MAX_COULUMN];
	  			
	  			String sqlDeleteTempTable = " delete "+temp_tbtData1+"  ";
	  			String sqlCreateTempTable = " Create temp table "+temp_tbtData1+" (yymm int, cnt int );  ";
				/******************************************************/	   	
	        	//------Initial Array 2Dimension table
	    		for (int i=0; i < strMatrix.length; i++) {
	    			for(int j=0; j<MAX_COULUMN;j++){
	    				strMatrix[i][j] = "0";//Allocate a values in row&coulumn	
	    			}
	    		}   			
	    		/************************************************/
	    		try{
		        	pstmt = conn.prepareStatement(sqlCreateTempTable); 
		        	pstmt.executeUpdate();
		        	//System.out.println("-->1. create temp table :"+sqlCreateTempTable);
	    		}catch(Exception e){	
	    			//(bck.temp_tbtdatar1) already exists in session.
	    			System.out.println("MSG == already exists in session (bck.temp_tbtdata1) == ");
	    			pstmt = conn.prepareStatement(sqlDeleteTempTable); 
		        	pstmt.executeUpdate();
		        	//System.out.println("-->2. Delete temp table :"+sqlCreateTempTable);
	    		}	
	    		
	        	
	    		/**************************
	        	 * ROW#1 บ้านโอน 
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_sort) as cnt   ")
					.append(" From lan:acscontr a ")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.f_contr is null   ")
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   "); 
	        	//System.out.println("SQL  :"+sql1.toString());
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[0][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#1----/
	        	
	    		/**************************
	        	 * ROW#2  นัดหมายได้
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.f_status ='CLS'   ")
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[1][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#2----/

	    		/**************************
	        	 * ROW#3  นัดหมายได้ภายใน 7 วัน
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND date(d_appoint) - d_close_law > 0 ")
					.append(" AND date(d_appoint) - d_close_law <="+APPOINT_IN_7_DAY)					
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")			
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[2][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#3----/

	    		/**************************
	        	 * ROW#4  นัดหมายได้ภายใน 8-14 วัน
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND date(d_appoint) - d_close_law >= "+APPOINT_IN_8_DAY)
					.append(" AND date(d_appoint) - d_close_law <="+APPOINT_IN_14_DAY)					
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")			
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[3][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#4----/
	    		
	        	/**************************
	        	 * ROW#5  นัดหมายได้ภายใน 15-30 วัน
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND date(d_appoint) - d_close_law >= "+APPOINT_IN_15_DAY)
					.append(" AND date(d_appoint) - d_close_law <="+APPOINT_IN_30_DAY)					
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")	
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[4][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#5----/

	    		/**************************
	        	 * ROW#6  นัดหมายได้ภายใน >30 วัน
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND date(d_appoint) - d_close_law > "+APPOINT_IN_30_DAY)				
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")	
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[5][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#6----/


	    		/**************************
	        	 * ROW#7 ติดต่อไม่ได้/ไม่รับนัด
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.f_status not in ('CLS','CAN')   ")
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")				
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[6][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#8----/
	        	
	    		/**************************
	        	 * ROW#8    ยกเลิกนัด
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.f_status ='CAN'   ")
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")				
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[7][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#9----/	        	
	        	
	    		/**************************
	        	 * ROW#9     	ติดต่อไม่ได้/ไม่รับนัด 1 ครั้ง
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.f_status ='001'   ")			
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[8][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#11----/

	    		/**************************
	        	 * ROW#10	 ติดต่อไม่ได้/ไม่รับนัด 2 ครั้ง
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.f_status ='002'   ")				
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[9][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#12----/
	        	
	    		/**************************
	        	 * ROW#11	ติดต่อไม่ได้/ไม่รับนัด 3 ครั้ง
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.f_status ='003'   ")			
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[10][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#13----/
	        	
	        	
	    		/**************************
	        	 * ROW#12	ติดต่อไม่ได้/ไม่รับนัด 4 ครั้ง
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.f_status not in ('CLS','CAN','001','002','003')  ")			
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[11][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#14----/
	        	
	    		/**************************
	        	 * ROW#13	Service Site เข้าแนะนำบ้านแล้ว
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(*) as cnt   ")
					.append(" From lan:int_histyh a, lan:svc_follow b")
					.append(" Where   ")
					.append(" a.i_svc_docno = b.i_svc_docno   ")
					.append(" AND b.i_itmno = '08'  ")
					.append(" AND b.i_itmsub = '01'  ")
					.append(" AND b.f_status = 'CLS'   ")	
					.append(" AND a.d_close_law is not null   ")							
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");  
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[12][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#13---/

	    		/**************************
	        	 * ROW#14	ยืนยันการนัดหมาย
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(*) as cnt   ")
					.append(" From lan:int_histyh a ")
					.append(" Where   ")
					.append(" a.d_confirm is not null   ")							
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");  
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[13][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#14---/
	        	
	    		/**************************
	        	 * ROW#15	โทรยืนยัน
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(*) as cnt   ")
					.append(" From lan:int_histyh a ")
					.append(" Where   ")
					.append(" a.d_confirm is not null   ")	
					.append(" AND a.f_confirm = '1'   ")	
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");  
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[14][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#15---/

	    		/**************************
	        	 * ROW#16	SMS ยืนยัน
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(*) as cnt   ")
					.append(" From lan:int_histyh a ")
					.append(" Where   ")
					.append(" a.d_confirm is not null   ")	
					.append(" AND a.f_confirm = '2'   ")	
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");  
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[15][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#16---/
	    		
	        	/**************************
	        	 * ROW#17  นัดหมายได้ by Service staff
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.f_status ='CLS'   ")
					.append(" AND a.f_service ='Y'   ")
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[16][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#17----/

				//---------------------
				objList.add(strMatrix);		
				 //System.out.println("-->Select temptable -------  Succesfully. ");
			  	return objList;			  	 
			}catch(Exception e){
				System.out.println("!!!ListGenReportCaseAllProject, " +sysName+":"+ clazzName + " : " + e.getMessage());
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
		
		
		public List ListGenReportCaseByProject(Connection conn,String fromDate,String toDate,int MAX_LOOP,String []projectArr,String[] COULUMN_DATE_QUERY) {
			//	TODO Auto-generated method stub
			/*****************/
			StringBuffer sqlFetch = new StringBuffer();	
			StringBuffer sql1 = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	        try{
	        	//initial paramter	
	        	//System.out.println("----CASE : By Project");
	        	String temp_tbtData1 = "temp_INT_tbtData2";
	  			String sqlCreateTempTable = " Create temp table "+temp_tbtData1+" (yymm int, cnt int );  ";
	  			String sqlDeleteTempTable = " delete "+temp_tbtData1+"  ";
	  			//String sqlInsert = " Insert into "+temp_tbtData1+" (yymm, cnt ) values (?, ?); ";
	        	List objList = new ArrayList();
	        	String str[] = null;
	  			int MAX_ROW = 22;
	  			int MAX_COULUMN = 12;
	  			String [][] strMatrix  = new String[MAX_ROW][MAX_COULUMN];
 	 
				/******************************************************/	   	
	        	//------Initial Array 2Dimension table
	    		for (int i=0; i < strMatrix.length; i++) {
	    			for(int j=0; j<MAX_COULUMN;j++){
	    				strMatrix[i][j] = "0";//Allocate a values in row&coulumn	
	    			}
	    		}   			
	    		/************************************************/
	        	//1.Insert project to temp table
	    		/************************************************/	
	    		this.InsertTempTableProject(conn, projectArr);
	        	//System.out.println("--Insert temp table OK.");
	        	
	    		/************************************************/

	    		try{
		        	pstmt = conn.prepareStatement(sqlCreateTempTable); 
		        	pstmt.executeUpdate();
		        	//System.out.println("-->1. create temp table :"+sqlCreateTempTable);
	    		}catch(Exception e){	
	    			//(bck.temp_tbtdatar1) already exists in session.
	    			System.out.println("MSG == (bck.temp_tbtdata1) already exists in session == ");
	    			pstmt = conn.prepareStatement(sqlDeleteTempTable); 
		        	pstmt.executeUpdate();
		        	//System.out.println("-->2. Delete temp table :"+sqlDeleteTempTable);
	    		}	
	    		
	    		/**************************
	        	 * ROW#1 บ้านโอน 
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_sort) as cnt   ")
				    .append(" From lan:acscontr a,tblByProjectX x  ")
					.append(" Where   ")
					.append(" a.d_close_law is not null  ")
					.append(" AND a.f_contr is null      ")
					.append(" AND a.i_company = x.com_id  ")
					.append(" AND a.i_project = x.proj_id ")
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");      
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[0][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#1----/
	        	
	    		/**************************
	        	 * ROW#2  นัดหมายได้
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a ,tblByProjectX x ")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.i_company = x.com_id  ")
					.append(" AND a.i_project = x.proj_id ")
					.append(" AND a.f_status ='CLS'   ")
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[1][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#2----/

	    		/**************************
	        	 * ROW#3  นัดหมายได้ภายใน 7 วัน
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a ,tblByProjectX x  ")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.i_company = x.com_id  ")
					.append(" AND a.i_project = x.proj_id ")
					.append(" AND date(d_appoint) - d_close_law > 0 ")
					.append(" AND date(d_appoint) - d_close_law <="+APPOINT_IN_7_DAY)					
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")	
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[2][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#3----/

	    		/**************************
	        	 * ROW#4  นัดหมายได้ภายใน 8-14 วัน
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a ,tblByProjectX x ")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.i_company = x.com_id  ")
					.append(" AND a.i_project = x.proj_id ")					
					.append(" AND date(d_appoint) - d_close_law >= "+APPOINT_IN_8_DAY)
					.append(" AND date(d_appoint) - d_close_law <="+APPOINT_IN_14_DAY)					
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")	
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[3][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#4----/
	    		
	        	/**************************
	        	 * ROW#5  นัดหมายได้ภายใน 15-30 วัน
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a ,tblByProjectX x ")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.i_company = x.com_id  ")
					.append(" AND a.i_project = x.proj_id ")					
					.append(" AND date(d_appoint) - d_close_law >= "+APPOINT_IN_15_DAY)
					.append(" AND date(d_appoint) - d_close_law <="+APPOINT_IN_30_DAY)					
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[4][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#5----/

	    		/**************************
	        	 * ROW#6  นัดหมายได้ภายใน >30 วัน
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a ,tblByProjectX x ")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.i_company = x.com_id  ")
					.append(" AND a.i_project = x.proj_id ")					
					.append(" AND date(d_appoint) - d_close_law > "+APPOINT_IN_30_DAY)				
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")	
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[5][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#6----/


	    		/**************************
	        	 * ROW#7 ติดต่อไม่ได้/ไม่รับนัด
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a ,tblByProjectX x ")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.i_company = x.com_id  ")
					.append(" AND a.i_project = x.proj_id ")					
					.append(" AND a.f_status not in ('CLS','CAN')   ")
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[6][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#7----/


	    		/**************************
	        	 * ROW#8    ยกเลิกนัด
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a ,tblByProjectX x ")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.i_company = x.com_id  ")
					.append(" AND a.i_project = x.proj_id ")					
					.append(" AND a.f_status ='CAN'   ")
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[7][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#8----/
	        	
	    		/**************************
	        	 * ROW#9    	ติดต่อไม่ได้/ไม่รับนัด 1 ครั้ง
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a ,tblByProjectX x ")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.i_company = x.com_id  ")
					.append(" AND a.i_project = x.proj_id ")					
					.append(" AND a.f_status ='001'   ")			
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[8][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#9----/

	    		/**************************
	        	 * ROW#10	 ติดต่อไม่ได้/ไม่รับนัด 2 ครั้ง
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a ,tblByProjectX x ")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.i_company = x.com_id  ")
					.append(" AND a.i_project = x.proj_id ")					
					.append(" AND a.f_status ='002'   ")			
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[9][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#10----/
	        	
	    		/**************************
	        	 * ROW#11	ติดต่อไม่ได้/ไม่รับนัด 3 ครั้ง
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a ,tblByProjectX x ")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.i_company = x.com_id  ")
					.append(" AND a.i_project = x.proj_id ")					
					.append(" AND a.f_status ='003'   ")			
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[10][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#11----/
	        	
	        	
	    		/**************************
	        	 * ROW#12	ติดต่อไม่ได้/ไม่รับนัด 4 ครั้ง
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a ,tblByProjectX x ")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.i_company = x.com_id  ")
					.append(" AND a.i_project = x.proj_id ")					
					.append(" AND a.f_status not in ('CLS','CAN','001','002','003')  ")			
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[11][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#12----/
	        	
	    		/**************************
	        	 * ROW#13	Service Site เข้าแนะนำบ้านแล้ว
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(*) as cnt   ")
					.append(" From lan:int_histyh a, lan:svc_follow b,tblByProjectX x")
					.append(" Where   ")
					.append(" a.i_svc_docno = b.i_svc_docno   ")
					.append(" AND a.i_company = x.com_id  ")
					.append(" AND a.i_project = x.proj_id ")	
					.append(" AND b.i_itmno = '08'  ")
					.append(" AND b.i_itmsub = '01'  ")
					.append(" AND b.f_status = 'CLS'   ")	
					.append(" AND a.d_close_law is not null   ")							
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");  
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[12][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#13----/

	    		/**************************
	        	 * ROW#14	ยืนยันการนัดหมาย
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(*) as cnt   ")
					.append(" From lan:int_histyh a ,tblByProjectX x ")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.i_company = x.com_id  ")
					.append(" AND a.i_project = x.proj_id ")					
					.append(" AND a.d_confirm is not null ")		
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[13][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#14---/
	        	
	    		/**************************
	        	 * ROW#15	โทรยืนยัน
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(*) as cnt   ")
					.append(" From lan:int_histyh a ,tblByProjectX x ")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.i_company = x.com_id  ")
					.append(" AND a.i_project = x.proj_id ")					
					.append(" AND a.d_confirm is not null ")
					.append(" AND a.f_confirm = '1'       ")	
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");   
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[14][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#15---/

	    		/**************************
	        	 * ROW#16	SMS ยืนยัน
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(*) as cnt   ")
					.append(" From lan:int_histyh a ,tblByProjectX x ")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.i_company = x.com_id  ")
					.append(" AND a.i_project = x.proj_id ")					
					.append(" AND a.d_confirm is not null ")
					.append(" AND a.f_confirm = '2'       ")	
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");  

	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[15][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#16---/
	        	
	        	/**************************
	        	 * ROW#17  นัดหมายได้ by Service staff
	        	 * *************************/
	    		sql1.delete(0,sql1.length());
	        	sql1.append(" Select year(a.d_close_law)||month(a.d_close_law) as yymm,count(a.i_lock) as cnt   ")
					.append(" From lan:int_histyh a ,tblByProjectX x")
					.append(" Where   ")
					.append(" a.d_close_law is not null   ")
					.append(" AND a.f_status ='CLS'   ")
					.append(" AND a.f_service ='Y'   ")
					.append(" AND a.i_company = x.com_id  ")
					.append(" AND a.i_project = x.proj_id ")
					.append(" AND a.d_close_law between '"+fromDate+"' and '"+toDate+"'   ")
					.append(" Group by 1   ");    
	        	/************
	        	 * CALL prepared temp table
	        	 * ***********/
	        	PreparedInsertTempTable(conn, sql1.toString(), temp_tbtData1);

                //Get data for report
			    sqlFetch.delete(0, sqlFetch.length());
			    sqlFetch.append(this.getFetchSQL(MAX_LOOP, COULUMN_DATE_QUERY, temp_tbtData1));			    
	        	pstmt = conn.prepareStatement(sqlFetch.toString()); 
	        	rs = pstmt.executeQuery();	
	        	//System.out.println("--->sqlFetch :"+sqlFetch.toString());
	        	if(rs.next()){
	        		for(int i = 0;i<MAX_LOOP;i++){
	        			str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		        		strMatrix[16][i] = doString.checkString(rs.getString("M"+getYYMM(str[0], str[1])),"0");//m20141
	        		}
	        	}
	        	rs = null;
	        	//---#End ROW#17----/

				//---------------------
				objList.add(strMatrix);		
				//System.out.println("-->Select  by project temptable -------  Succesfully. ");
			  	return objList;			  	 	  	 
			}catch(Exception e){
				System.out.println("!!!ListGenReportMonthByAllProjectDisplayProject, " +sysName+":"+ clazzName + " : " + e.getMessage());
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
		
		private void PreparedInsertTempTable(Connection conn,String sqlMain,String temp_tbtData1) {
			//StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	        try{
	        	//initial paramter	
	        	boolean isDel = false;
	  			String sqlInsert = " Insert into "+temp_tbtData1+" (yymm, cnt ) values (?, ?); ";
	        	String sqlDeleteTempTable = " Delete "+temp_tbtData1;
	        	String sqlSelectTempTable = " Select * From "+temp_tbtData1;
	        	
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
			    //System.out.println("-->ExecuteQuery OK ");		    
			    /* Prepared insert temp table
			     * */
			    
			    //System.out.println("3.-->Insert temp table :"+sqlInsert);	
			    pstmt = conn.prepareStatement(sqlInsert); 
			    //************************
			    while(rs.next()){
			    	 pstmt.setInt(1, rs.getInt("yymm"));
			    	 pstmt.setInt(2, rs.getInt("cnt"));
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

		public int GetCountRowByProjectALL(Connection conn, String sqlCriteria) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			int totalRow=0; 
	        try{
	        	//initial paramter	
				/******************************************************/
	        	sql.delete(0,sql.length());
				sql.append(" Select  count(*)as totalRow ")
				   .append(sqlCriteria);
				//System.out.println("Get count Row :"+sql.toString());
				pstmt = conn.prepareStatement(sql.toString()); 
				rs = pstmt.executeQuery();	
				if(rs.next()){				
					totalRow = rs.getInt("totalRow");
				}
				rs.close();				
				//********************************************************/
				//System.out.println("totalRow---->"+totalRow);
			  	//System.out.println("##GetCountRowByProjectALL ->End.");				  	 
			  	return totalRow;			  	 
			}catch(Exception e){
				System.out.println("!!!GetCountRowByProjectALL , " +sysName+":"+ clazzName + " : " + e.getMessage());
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

		public ArrayList ListByProjectALL$Paging(Connection conn, String sqlCriteria,int startRow,int endRow,int maxRow) {
			// TODO Auto-generated method stub
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	        try{
	        	//initial paramter 
	        	ArrayList  listDocHd = new ArrayList();
	        	List strArr = null;
	        	List strArrObj = null;
	        	int line = 0;

				/******************************************************/	
	          	//*****Find project by user login  
				sql.delete(0,sql.length());
				sql.append(" Select first ").append(endRow).append("  a.i_company,a.i_project,a.i_lock,a.f_status,a.i_house,a.n_customer,a.n_custel,a.d_close_law,a.d_appoint,a.c_desc  ")
				   .append(sqlCriteria)
				   .append(" Order by a.i_company,a.i_project,a.i_lock ");
				//System.out.println("SQL Detail :"+sql.toString());
				pstmt = conn.prepareStatement(sql.toString()); 
				rs = pstmt.executeQuery();	
				
		        for (int i=0;i<maxRow;i++) { 
	                if (rs.next()) {
	                   if (i>=startRow && i<=endRow) {	
	                	   	strArr = new ArrayList();
		   					strArr.add(0,doString.checkString(rs.getString("i_company"),""));//1			  
		   					strArr.add(1,doString.checkString(rs.getString("i_project"),""));//2		   					
		   					strArr.add(2,this.GetProjectName(conn, doString.checkString(rs.getString("i_company"),""),doString.checkString(rs.getString("i_project"),"")));	
		   					strArr.add(3,doString.checkString(rs.getString("i_lock"),""));
		   					strArr.add(4,doString.checkString(rs.getString("f_status"),""));
		   					strArr.add(5,doString.checkString(rs.getString("i_house"),""));
		   					strArr.add(6,doString.checkString(rs.getString("n_customer"),""));
		   					strArr.add(7,doString.checkString(rs.getString("n_custel"),""));
		   					strArr.add(8,toDDMMYY_THAI2(doString.checkString(rs.getString("d_close_law"),"")));//D_Keyin 2014-09-11;
		   					
		   					if(isValueStrAndObj(doString.checkString(rs.getString("d_appoint"),""))){
		   						strArr.add(9,toDDMMYY_THAI2(doString.checkString(rs.getString("d_appoint"),"").substring(0,10))+" "+doString.checkString(rs.getString("d_appoint"),"").substring(10,16));
		   						//strArr.add(9,doString.checkString(rs.getString("d_appoint"),""));
							}else{
								strArr.add(9,"");
							}
		   					strArr.add(10,doString.checkString(rs.getString("c_desc"),""));
		   					//--------------------
		   					strArrObj = null;
		   					strArrObj = this.ListHistoryContactINT_HISTYD(conn, doString.checkString(rs.getString("i_company"),""),doString.checkString(rs.getString("i_project"),""), doString.checkString(rs.getString("i_lock"),""));
		    				strArr.add(11,strArrObj);
			       			
		    				listDocHd.add(strArr);
		    				line++;                         
	                   } //--end if check row
		               if (i>endRow){ 
		              	 break;
		               }
	                } //end if check rs
		        } // end for
				//********************************************************/
				rs.close();				
				//********************************************************/
			  	//System.out.println("-->listDocHd :"+listDocHd.size());				  	 
			  	return listDocHd;			  	 
			}catch(Exception e){
				System.out.println("!!!ListByProjectALL$Paging , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
		
		public List ListHistoryContactINT_HISTYD(Connection conn, String comId,
				String projectId, String iLock) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	        try{
	        	//initial paramter	
	        	List  ListHistory = new ArrayList();
	       	 	List   strList = null;	 
	       	    List   strArr = null;
	       	 	String iCode = "";
	        	//System.out.println("ListHistoryContact ->Starting.");        	 
				
				/****************************projectDLL****************************************/
	      	     sql.delete(0,sql.length());
				 sql.append(" Select a.d_keyin,a.i_answer,a.n_customer,a.n_custel,a.c_desc,a.f_status,a.i_employ ")
					   .append(" From lan:int_histyd a  ")
					   .append(" Where a.i_company = ? ")
					   .append(" and a.i_project  = ? ")
					   .append(" and a.i_lock = ? ")
					   .append(" Order by a.d_keyin ");
				//System.out.println("SQL :"+sql.toString());
				pstmt = conn.prepareStatement(sql.toString());
				pstmt.setString(1,comId);
				pstmt.setString(2,projectId);	
				pstmt.setString(3,iLock);	
				rs = pstmt.executeQuery();		
				
				while(rs.next()){
						strList =  new ArrayList(); 
						iCode = "";
						strArr = null;
						iCode = doString.checkString(rs.getString("i_answer"),"");
						strList.add(0,doString.checkString(rs.getString("d_keyin"),""));
						strList.add(1,doString.checkString(rs.getString("i_answer"),""));				
						strList.add(2,doString.checkString(rs.getString("n_customer"),""));
						strList.add(3,doString.checkString(rs.getString("c_desc"),""));
						strList.add(4,doString.checkString(rs.getString("f_status"),""));
						
						if(!"".equals(iCode)){
							strList.add(5,this.GetCauseNameServXSTD(conn, iCode));
						}else{
							strList.add(5,iCode);
						}	
						strList.add(6,doString.checkString(rs.getString("n_custel"),""));
						strList.add(7, this.GetEmployPosition(conn,doString.checkString(rs.getString("i_employ"),"")));	
	   					if("CAN".equals(doString.checkString(rs.getString("f_status"),""))){
	   					     strList.add(8,this.GetDateStrINT_HISTYH(conn, comId, projectId, iLock,"CAN"));//Date update
	   					}else if("CLS".equals(doString.checkString(rs.getString("f_status"),""))){
	   					     strList.add(8,this.GetDateStrINT_HISTYH(conn, comId, projectId, iLock,"CLS"));//Date update
	   					}else{
	   						strList.add(8,"");
	   					}
						ListHistory.add(strList);					
				}
				rs.close();		   			
				//********************************************************/
			  	//System.out.println("ListHistoryContactINT_HISTYD ->end.");				  	 
			  	return ListHistory;			  	 
			}catch(Exception e){
				System.out.println("ListHistoryContactINT_HISTYD , " +sysName+":"+ clazzName + " : " + e.getMessage());
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

		public String GetCauseNameServXSTD(Connection conn, String code) {
			// TODO Auto-generated method stub
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			String  causeName = "";
	        try{
	        	//initial paramter	     	
				/*************************************************/			
	        	//*****Find project by user login  
				sql.delete(0,sql.length());
				sql.append("Select n_desc From lan:serv_xstd Where i_type = '99' and i_code = ? ");
				pstmt = conn.prepareStatement(sql.toString()); 
				pstmt.setString(1, code);	
				//System.out.println("SQL :"+sql.toString());
				rs = pstmt.executeQuery();	
				if(rs.next()){
					causeName = doString.checkString(rs.getString("n_desc"), "");
				}
				rs.close();	
				//**************************************************/
			  	//System.out.println("##GetCauseNameServXSTD ->successfully.");				  	 
			  	return causeName;			  	 
			}catch(Exception e){
				System.out.println("!!!GetCauseNameServXSTD , " +sysName+":"+ clazzName + " : " + e.getMessage());
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

		public String GetEmployPosition(Connection conn, String employId) {
			// TODO Auto-generated method stub
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			String position = "";
			ArrayList strArr = new ArrayList();
	        try{
	        	//initial paramter	     	
	        	//System.out.println("GET_EMPLOY_POSITION ->Starting.");        	
				/*************************************************/			
				sql.delete(0,sql.length());
				sql.append(" select trim(a.n_prename_th)||trim(a.n_nemploy_th)||' '||trim(a.n_semploy_th) as emp_name ,  ")
					.append(" b.n_desc position from docflow:acemploy a  ")
					.append(" left join docflow:acempstd b on b.i_type='10' and b.i_code in ")
					.append("  (select i_job from docflow:acempjob where i_employ=a.i_employ and d_job in  ")
					.append(" (select max(d_job) from docflow:acempjob where i_employ=a.i_employ))  ")
					.append("  where a.i_employ= ?  ");

				//System.out.println("SQL get position :"+sql.toString());
				pstmt = conn.prepareStatement(sql.toString()); 
				pstmt.setString(1, employId);	
				rs = pstmt.executeQuery();	
				if(rs.next()){				
					position = doString.checkString(rs.getString("position"), "");
				}
				rs.close();		   			
				//**************************************************/
			  	//System.out.println("GetEmployPosition ->successfully.");				  	 
			  	return position;			  	 
			}catch(Exception e){
				System.out.println("GetEmployPosition , " +sysName+":"+ clazzName + " : " + e.getMessage());
				System.out.println(" SQL Exception: "+sql.toString());		
				return position;
			}
			finally{			
				//clean up.
				try{
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
				}catch(Exception e){}
			}
		}
		
		public String GetFStatusINT_HISTYH(Connection conn, String comId,
				String projectId, String lock) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			String  fStatus = "";
	        try{
	        	//initial paramter	     	
				/*************************************************/			
	        	//*****Find project by user login  
				sql.delete(0,sql.length());
				sql.append("Select f_status From lan:INT_HISTYH Where i_company = ? and i_project = ? and i_lock = ? ");
				pstmt = conn.prepareStatement(sql.toString()); 
				pstmt.setString(1,comId);
				pstmt.setString(2,projectId);	
				pstmt.setString(3,lock);	
				//System.out.println("SQL :"+sql.toString());
				rs = pstmt.executeQuery();	
				if(rs.next()){
					fStatus = doString.checkString(rs.getString("f_status"), "");
				}
				rs.close();	
				//**************************************************/
			  	//System.out.println("##GetFStatusINT_HISTYH ->successfully.");				  	 
			  	return fStatus;			  	 
			}catch(Exception e){
				System.out.println("!!!GetFStatusINT_HISTYH , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
		
		public String GetDateStrINT_HISTYH(Connection conn, String comId,
				String projectId, String lock,String f_status) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			String  dateStr = "";
	        try{
	        	//initial paramter	     	
				/*************************************************/			
	        	//*****Find project by user login  
				sql.delete(0,sql.length());
				sql.append("Select d_appoint,d_update,c_desc From lan:INT_HISTYH Where i_company = ? and i_project = ?  and i_lock = ? ");
				pstmt = conn.prepareStatement(sql.toString()); 
				pstmt.setString(1,comId);
				pstmt.setString(2,projectId);	
				pstmt.setString(3,lock);	
				//System.out.println("SQL GetDateStrINT_HISTYH :"+sql.toString());
				rs = pstmt.executeQuery();	
				if(rs.next()){				
					if("CAN".equals(f_status)){
						dateStr = doString.checkString(rs.getString("d_update"), "");
					}else if("CLS".equals(f_status)){
						dateStr = doString.checkString(rs.getString("d_appoint"), "");
					}else{
						dateStr = doString.checkString(rs.getString("c_desc"), "");
					}
				}
				rs.close();	
				//**************************************************/	  	 
			  	return dateStr;			  	 
			}catch(Exception e){
				System.out.println("!!!GetDateStrINT_HISTYH , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
		private static String getFetchSQL(int MAX_LOOP,String []COULUMN_DATE_QUERY,String temp_tbtData1){
			   StringBuffer sql1 = new StringBuffer();
			   StringBuffer sqlFetch = new StringBuffer();
			   String []str = null;
		       sql1.delete(0,sql1.length());
			   // sql1.append("  ");
		  		for(int i = 0;i<MAX_LOOP;i++){
		  		    str = COULUMN_DATE_QUERY[i].split("\\-");//2015-02-31
		  		    sql1.append(" sum(CASE WHEN YYMM = "+getYYMM(str[0], str[1])+" THEN cnt ELSE 0 END) AS  M"+getYYMM(str[0], str[1])+" ,  ");
		  		}
		  		sqlFetch.delete(0,sqlFetch.length());
		  		sqlFetch.append(" SELECT ");
		  		sqlFetch.append(sql1.toString().substring(0,sql1.toString().lastIndexOf(",")));
		  		sqlFetch.append("  FROM "+temp_tbtData1+" ; ");	
		  	
		  		return sqlFetch.toString();
		}
		
		//Gent SQL by ALL proejct or By project seperate 
		private static String GenQuerySQLByProjectALL(String args1,String args2,String fStatus,String startDate,String endDate,boolean isAllProject){  
			 StringBuffer sql = new StringBuffer();
			 sql.delete(0,sql.length());
			 if("SVC".equals(args1)){
				 if(isAllProject){
					 sql.delete(0,sql.length());
					 sql.append(" From lan:int_histyh a ")
						.append(" Where   ")
						.append(" a.d_close_law is not null   "); 
				 }else{
					 sql.delete(0,sql.length());
					 sql.append(" From lan:int_histyh a ,tblByProjectX x ")
						.append(" Where   ")
						.append(" a.d_close_law is not null   ")
						.append(" AND a.i_company = x.com_id  ")
						.append(" AND a.i_project = x.proj_id "); 
				 }

				 if("CLS".equals(fStatus)){//CLS
					 sql.append(" AND a.f_status ='CLS'  ");				
					 if(APPOINT_IN_7_DAY.equals(args2)){
						 sql.append(" AND date(d_appoint) - d_close_law > 0 ")
							.append(" AND date(d_appoint) - d_close_law <="+APPOINT_IN_7_DAY);	
					 }else if(APPOINT_IN_8_DAY.equals(args2)){
						 sql.append(" AND date(d_appoint) - d_close_law >= "+APPOINT_IN_8_DAY)
							.append(" AND date(d_appoint) - d_close_law <="+APPOINT_IN_14_DAY);	
					 }else if(APPOINT_IN_15_DAY.equals(args2)){
						 sql.append(" AND date(d_appoint) - d_close_law >= "+APPOINT_IN_15_DAY)
							.append(" AND date(d_appoint) - d_close_law <="+APPOINT_IN_30_DAY);
					 }else if(APPOINT_IN_30_DAY.equals(args2)){
						 sql.append(" AND date(d_appoint) - d_close_law > "+APPOINT_IN_30_DAY);	
					 }
				 }else if("CLSCAN".equals(fStatus)){//CLS-CAN
					 sql.append(" AND a.f_status not in ('CLS','CAN')   ");
				 } else if("CAN".equals(fStatus)){
					 sql.append(" AND a.f_status ='CAN'   ");
				 }else if("001".equals(fStatus)){
					 sql.append(" AND a.f_status ='001'   ");
				 } else if("002".equals(fStatus)){
					 sql.append(" AND a.f_status ='002'   ");
				 } else if("003".equals(fStatus)){
					 sql.append(" AND a.f_status ='003'   ");
				 } else if("004".equals(fStatus)){
					 //('CLS','CAN','001','002','003')
					 sql.append(" AND a.f_status not in ('CLS','CAN','001','002','003')  ")	;
				 } else if("confirm".equals(fStatus)){
					 if(isAllProject){
						 sql.delete(0,sql.length());
						 sql.append(" From lan:int_histyh a ")
							.append(" Where   ")
						    .append(" a.d_confirm is not null   ");	
					 }else{
						 sql.delete(0,sql.length());
						 sql.append(" From lan:int_histyh a ,tblByProjectX x ")
							.append(" Where   ")
						    .append(" a.d_confirm is not null   ")
							.append(" AND a.i_company = x.com_id  ")
							.append(" AND a.i_project = x.proj_id "); 	
					 }
				 } else if("confirmTEL".equals(fStatus)){
					 if(isAllProject){
						 sql.delete(0,sql.length());
						 sql.append(" From lan:int_histyh a ")
							.append(" Where   ")
						    .append(" a.d_confirm is not null   ")	
						 	.append(" AND a.f_confirm = '1'   ");
					 }else{
						 sql.delete(0,sql.length());
						 sql.append(" From lan:int_histyh a  ,tblByProjectX x ")
							.append(" Where   ")
						    .append(" a.d_confirm is not null   ")	
						 	.append(" AND a.f_confirm = '1'   ")
							.append(" AND a.i_company = x.com_id  ")
							.append(" AND a.i_project = x.proj_id "); 
					 }
					 
				 } else if("confirmSMS".equals(fStatus)){
					 if(isAllProject){
						 sql.delete(0,sql.length());
						 sql.append(" From lan:int_histyh a ")
							.append(" Where   ")
						    .append(" a.d_confirm is not null   ")	
						 	.append(" AND a.f_confirm = '2'   ");
					 }else{
						 sql.delete(0,sql.length());
						 sql.append(" From lan:int_histyh a ,tblByProjectX x ")
							.append(" Where   ")
						    .append(" a.d_confirm is not null   ")	
						 	.append(" AND a.f_confirm = '2'   ")							
						 	.append(" AND a.i_company = x.com_id  ")
							.append(" AND a.i_project = x.proj_id "); 
					 }
				 }
			 }else if("service".equals(args1)){			 
				  if("0801".equals(fStatus)){//service staft introduce baan
					  if(isAllProject){					  
						  sql.delete(0,sql.length());
						  sql.append(" From lan:int_histyh a, lan:svc_follow b")
							.append(" Where   ")
							.append(" a.i_svc_docno = b.i_svc_docno   ")
							.append(" AND b.i_itmno = '08'  ")
							.append(" AND b.i_itmsub = '01'  ")
							.append(" AND b.f_status = 'CLS'   ")	
							.append(" AND a.d_close_law is not null   ");	
					  }else{
						  sql.delete(0,sql.length());
						  sql.append(" From lan:int_histyh a, lan:svc_follow b ,tblByProjectX x ")
							.append(" Where   ")
							.append(" a.i_svc_docno = b.i_svc_docno   ")
							.append(" AND b.i_itmno = '08'  ")
							.append(" AND b.i_itmsub = '01'  ")
							.append(" AND b.f_status = 'CLS'   ")	
							.append(" AND a.d_close_law is not null   ")
							.append(" AND a.i_company = x.com_id  ")
							.append(" AND a.i_project = x.proj_id "); 	
					  }
				 }else if("fservcieY".equals(fStatus)){
					  if(isAllProject){	
						 sql.delete(0,sql.length());
						 sql.append(" From lan:int_histyh a")
							.append(" Where   ")
							.append(" a.d_close_law is not null  ")
							.append(" AND a.f_status ='CLS'   ")
							.append(" AND a.f_service ='Y'   ");
					  }else{
							 sql.delete(0,sql.length());
							 sql.append(" From lan:int_histyh a,tblByProjectX x ")
								.append(" Where   ")
								.append(" a.d_close_law is not null  ")
								.append(" AND a.f_status ='CLS'   ")
								.append(" AND a.f_service ='Y'   ")
								.append(" AND a.i_company = x.com_id  ")
								.append(" AND a.i_project = x.proj_id "); 	
					  }
				 }
			 }			 			
			 //End CLS
			 sql.append(" AND a.d_close_law between '"+startDate+"' and '"+endDate+"'  ");   //2015-01-01,2015-01-31
			 
		  	return sql.toString();
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
		public static String GenLinkNextPageHTML(int tmpMax,int nowPage,int displayLine)throws Exception {
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
		
		public static  String toDDMMYY_THAI2(String str){
			 if ((str == null) || str.equals("")) {
				 return  str;
			 }else{
				 String d2[] = str.split("\\-"); //2013-03-29
				 return d2[2]+"/"+d2[1]+"/"+(Integer.parseInt(d2[0])+543);
			 }
		}
		
		public static  String getMonth(String str){
			 if ((str == null) || str.equals("")) {
				 return  str;
			 }else{
				 String d2[] = str.split("\\-"); //2013-03-29
				 return ""+(Integer.parseInt(d2[1]));
			 }
		}
		public static  String getYear(String str){
			 if ((str == null) || str.equals("")) {
				 return  str;
			 }else{
				 String d2[] = str.split("\\-"); //2013-03-29
				 return d2[0];
			 }
		}
		
		
		
		//false = object is null / str is ""
		//true = object have value / string hava value 
		public static boolean isValueStrAndObj(String str) throws Exception{
			if ((str == null) || str.equals("")) {
				 return false;
			}else{
				 return true;
			 }
		}
}