package serv.servlets;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
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
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import serv.common.User;
import com.lh.servlet.DBServlet;
import com.lh.string.doString;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.util.HSSFColor;
/*********************************************
 * create by : pradoem wonkraso
 * date time: 2015.08.02
 * Last modify :
 * version :1.0
 * project Name : Report SVC 
 * description :  Report สรุป Call Service Center แยกตาม Column โอน 1-3 เดือน 3-6 เดือน ...
***************************************************/

/**
 * Servlet implementation class for Servlet: SERV_ReportSvcServlet
 *
 */
 public class SERV_ReportSvcServlet extends  DBServlet{

		String sysName = "LHServ";
		String clazzName = new String(this.getClass().getName() + ".performTask :");
		final static String Constant_99 = "99";
		final static String Constant_row = "row";
		final static String Constant_col = "col";
		final static String Constant_type = "type";		
		final static String Constant_agent = "agent";
		final static String Constant_project = "project";
		final static String Constant_All_0 = "0";
		final static String Constant_Y = "Y";
		

		String thaiMonth[] = new String[] {"","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม",""};
		String COLUMN_HD1[] = new String[] {"","โอน  1-3 เดือน","โอน  3-6 เดือน","โอน  6-9 เดือน","โอน  9-12 เดือน","โอน 12-15 เดือน","โอน 15-24 เดือน","โอน 24-36 เดือน",
		                                      "โอน 36-48 เดือน","โอน 48-60 เดือน","โอน 60-72 เดือน","โอน 72-84 เดือน","โอน 84-96 เดือน","โอน 96-108 เดือน","โอน 108-120 เดือน","โอน -120 เดือน"};
    	static String COLUMN_COUNT_DATE[] = new String[] {"0","90","180","270","360","450","720","1080","1440","1800","2160","2520","2880","3240","3600","3600"};

		public SERV_ReportSvcServlet() {
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
 		
 		/*****************************************
 		 * @performTask
 		 ***************************************/
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
 				  }else if(command.equals("Expand")){
 					 this.doExpandReportForm(request,response,user);
 				  }else if(command.equals("Desc")){
 					 this.doDetailsReport(request, response, user);
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
 		   		String tarGetUrl ="/SERV_ReportSvcForm.jsp";
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
 
 		//*****Report dynamic receive paramteter from Form critirai 
 		protected void doDetailsReport(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
 			// TODO Auto-generated method stub
 			
 			Connection conn = null;
 			ServletContext context = getServletContext();
 			HttpSession session = request.getSession(false);
 			//String okPage = "";//Constants.APP_PATH+Constants.SAVE_PAGE;
 			//String targetPage ="";//  Constants.APP_PATH+Constants.APP_HOME;
 			//String errorCode = "99";	
 			String msgTxt = "";// Constants.APP_PATH+Constants.SAVE_PAGE;
 			String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
 	        try{
 	        	//System.out.println("doGenReportForm ->Starting.");
 	        	//printOutParam(request,"doExpandReportForm");
 	 			//----------Open connection
 				//Open connection
 				if (ds == null){getDS();}			
 				conn = ds.getConnection();
 				conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
 	  			//conn.setAutoCommit(false);
 	            //-------------------------
 				
 				String projSelDDL =  doString.checkString(request.getParameter("projectSel"),"");//AA:999
 				String typeDDL =  doString.checkString(request.getParameter("typeDDL"),"");
 				String param1 =  doString.checkString(request.getParameter("param1"),"");
 	  			String param2 = doString.checkString(request.getParameter("param2"),"");
 	  			String transMonth = doString.checkString(request.getParameter("transMonth"),"");//1,2,3,....N
 	  			String fromDate = doString.checkString(request.getParameter("fromDate"),""); ////30/11/2558
 	  			String toDate = doString.checkString(request.getParameter("toDate"),""); //30/11/2558
 	  			String multiFlag = doString.checkString(request.getParameter("multiFlag"),""); //0=All project,1 = by project
 	  			String itemSub = doString.checkString(request.getParameter("itemSub"),"N"); //=Y,N
 	  			String grandTotal = doString.checkString(request.getParameter("grandTotal"),""); //=row,col
 	  			
 	  			String export2Excel = doString.checkString(request.getParameter("export2Excel"),""); //export2Excel
 	  		    List arrReportObj= new ArrayList();
 	  		    List listSelProject  = null;
 	  		    //List listItmSubObj = null;
 		   		//*********Dispatcher  	 
 	  		    String tempTableName = "tblByProjectX3";
	 	  		if(multiFlag.equals(Constant_All_0)){//TODO: CASE : ALL Project	 
	 	  		}else{
	 	  			if(projSelDDL.length()>0){
	 	  				projSelDDL = projSelDDL.substring(0,projSelDDL.length()-1);
   	  				    String [] projTemp = projSelDDL.split("\\|");
   	  				    CreateTempTableProject(conn, projTemp, tempTableName);
	   	  				if(!Constant_project.equalsIgnoreCase(typeDDL)){
	   	  				    listSelProject = ListSelectedProjectName(conn, tempTableName);
	   	  				}
	 	  			}
	 	  		}
	 			//System.err.println("-------------------GenReport OK-------------------------------");	 
 			  	
		  		//---------------------------------------------------------------------//
				int displayLine = Integer.parseInt(doString.checkString(request.getParameter("pageNoDDL"),"25"));				
				//***************Get Row from db
		        int maxRow = 0;
		        if(multiFlag.equals(Constant_All_0)){// all
		        	maxRow = this.IntCountRowReportDetails(conn,typeDDL,ThaiToEngDate(fromDate),ThaiToEngDate(toDate),transMonth,param1,param2,true,tempTableName,itemSub,grandTotal);
		        }else{ // by project
		        	maxRow = this.IntCountRowReportDetails(conn,typeDDL,ThaiToEngDate(fromDate),ThaiToEngDate(toDate),transMonth,param1,param2,false,tempTableName,itemSub,grandTotal);
		        }
		        //---------------- Generate Display Customize and Page Link -------------------------//
		        int nowPage = Integer.parseInt(doString.checkString(request.getParameter("nowPage"),"1"));
		        int startRow = ((nowPage-1)*displayLine);
		        int endRow = startRow+displayLine;       	   
		        String pageLink = "";
		        int tmpMax = maxRow;
		        pageLink = this.genLinkNextPageHTML(tmpMax, nowPage, displayLine);
		
				ArrayList pageNoDDL = new ArrayList();
				int intVal = 25;
				for(int i=0;i<5;i++){
					pageNoDDL.add(0,intVal); 
					intVal +=25;
				}
		        //------------------------------------------------------------------//s	 
				boolean isExport = false;
				if(export2Excel.equalsIgnoreCase("Y")){
					isExport = true;
				}
				 if(multiFlag.equals(Constant_All_0)){// all
					arrReportObj = this.ListReportDetails(conn, typeDDL, ThaiToEngDate(fromDate),ThaiToEngDate(toDate), transMonth, param1, param2,true,tempTableName,itemSub,grandTotal,startRow, endRow, maxRow,isExport);
				 }else{// by project
					arrReportObj = this.ListReportDetails(conn, typeDDL, ThaiToEngDate(fromDate),ThaiToEngDate(toDate), transMonth, param1, param2,false,tempTableName,itemSub,grandTotal,startRow, endRow, maxRow,isExport);
				 }
				//-----------------------------
				/*==Fetch Data By */
				String typeName = "";
				//System.out.println(("====>param1 "+param1);
				if(Constant_row.equals(grandTotal)||Constant_99.equals(grandTotal)){
					typeName = " Grand Total ";
				}else{
					if(Constant_type.equalsIgnoreCase(typeDDL)){
						typeName = GetTypeName(conn, param1);
						if(Constant_Y.equals(itemSub)){
							typeName =param1+typeName+" -> "+GetNameItemSub(conn, param1, param2);
						}
				    }else if(Constant_agent.equalsIgnoreCase(typeDDL)){
				    	typeName = GetNameEmploy(conn, param1);
				    	
				    	//System.out.println(("====>GetNameEmploy "+typeName);
					}else if(Constant_project.equalsIgnoreCase(typeDDL)){
						typeName = GetProjectName(conn, param1, param2);
					}
				}
				//System.out.println("===================TEST ================");
				//System.out.println("===================typeName :"+typeName);
				
 				/****** Clear *******/
 				conn.close();
 				conn = null;
 				
		  		 request.setAttribute("reportResultHD", arrReportObj);
		  		 request.setAttribute("projSelectdList", listSelProject);
		  		 
		  		 request.setAttribute("typeName", typeName);//item_n_desc,agent_name,projectName
		  		 request.setAttribute("fromDate", fromDate);//05/08/2558
				 request.setAttribute("toDate",toDate);//05/08/2558
				 request.setAttribute("typeDDL",typeDDL);//TYPE,PROJECT,AGENT
				 request.setAttribute("transMonth",transMonth);//1,2,3,4...N
				 request.setAttribute("multiFlag",multiFlag);//0=ALL
				 request.setAttribute("param1",param1);//param1
				 request.setAttribute("param2",param2);//param2
				 request.setAttribute("projectSel",projSelDDL+"|");//LH:075|LH:011
				 request.setAttribute("itemSub",itemSub);//Y,N
				 request.setAttribute("grandTotal",grandTotal);//row,col

				/**********************************/
				request.setAttribute("displayLinkPage", pageLink); 
				request.setAttribute("pageNoDDL",pageNoDDL);
				request.setAttribute("displayLine", displayLine);
				request.setAttribute("recordNo", startRow);
				/************************************/
				request.setAttribute("reportResultHD", arrReportObj);

				if(export2Excel.equalsIgnoreCase("Y")){
					/*********************************************/
					//Generate to Excel paper
					/*********************************************/ 	
					Date date = Calendar.getInstance().getTime();
					DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
				     String tempDate = formatter.format(date); //2015-09-07
					
					ByteArrayOutputStream baos = new ByteArrayOutputStream();
					HSSFWorkbook wb = GenExcelPaper(arrReportObj,typeDDL,fromDate,toDate,typeName,grandTotal,transMonth,multiFlag,listSelProject);
				    wb.write(baos);
				    response.setContentType("application/vnd.ms-excel");
				    String fileName = "exportDetail_"+tempDate+".xls";
				    response.setHeader("Content-disposition","inline;filename=\""+fileName+"\"");

				    response.setContentLength(baos.size());
			        ServletOutputStream out = response.getOutputStream();
			        baos.writeTo(out);
			        out.flush();
			        //--------------------------------
				}else{
					response.setContentType("text/html; charset=TIS-620");
	 			  	String tarGetUrl ="/SERV_ReportSvcDetails.jsp";
	 		   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
	 				dispatcher.forward(request,response);	
				}
 			}catch(Exception e){
 				System.err.println("!!! doDetailsReport , " +sysName+":"+ clazzName + " : " + e.getMessage());
 				msgTxt = "doDetailsReport , " +sysName+":"+ clazzName + " : " + e.getMessage();
 				response.sendRedirect(ERROR_PAGE+msgTxt);
 			}
 			finally{			
 				//clean up.
 				try{
 					if(conn!=null){conn.close();}
 				}catch(Exception e){}
 			}
 		} 	
 		

 		/**********************
 		 * doExpandReportForm
 		 * @param request
 		 * @param response
 		 * @param user
 		 * @throws ServletException
 		 * @throws IOException
 		 */
 		protected void doExpandReportForm(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
 			// TODO Auto-generated method stub
 			response.setContentType("text/html; charset=TIS-620");
 			Connection conn = null;
 			ServletContext context = getServletContext();
 			HttpSession session = request.getSession(false);
 			//String okPage = "";//Constants.APP_PATH+Constants.SAVE_PAGE;
 			//String targetPage ="";//  Constants.APP_PATH+Constants.APP_HOME;
 			//String errorCode = "99";	
 			String msgTxt = "";// Constants.APP_PATH+Constants.SAVE_PAGE;
 			String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
 	        try{
 	        	//System.out.println("doGenReportForm ->Starting.");
 	        	//printOutParam(request,"doExpandReportForm");
 	 			//----------Open connection
 				//Open connection
 				if (ds == null){getDS();}			
 				conn = ds.getConnection();
 				conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
 	  			//conn.setAutoCommit(false);
 	            //-------------------------
 				String projSelDDL =  doString.checkString(request.getParameter("projectSel"),"");//AA:999
 	  			String fromDate = doString.checkString(request.getParameter("fromDate"),"");//23/09/2558
 	  			String toDate = doString.checkString(request.getParameter("toDate"),""); //22/09/2558
 	  			String reportType = doString.checkString(request.getParameter("typeDDL"),""); 
 	  			String itmno = doString.checkString(request.getParameter("itmno"),""); 
 	  			String multiFlag = doString.checkString(request.getParameter("multiFlag"),""); //0=All project,1 = by project

 	  		    List arrReportObj= new ArrayList();
 	  		    List listSelProject  = null;
 	  		    List listItmSubObj = null;
 			  	/**********************************/

 	  		    String tempTableName = "tblByProjectX2";
    	  		if(multiFlag.equals("0")){//TODO: CASE : ALL Project
    	  			listItmSubObj = ListTypeItemSub(conn, itmno);
     	  		    arrReportObj = ListReportCaseByTypeItemSub(conn, itmno, listItmSubObj, ThaiToEngDate(fromDate),ThaiToEngDate(toDate), true, tempTableName);

    	  		}else{
    	  			 //call crete temp table & Insert temp table
    	  			 if(projSelDDL.length()>0){
    	  				 projSelDDL = projSelDDL.substring(0,projSelDDL.length()-1);
    	  				 String [] projTemp = projSelDDL.split("\\|");
	    	  			 //System.out.println(""+projTemp.toString());
	    	  			 CreateTempTableProject(conn, projTemp, tempTableName);
    	  			     listItmSubObj = ListTypeItemSub(conn, itmno);
 	  				     arrReportObj = ListReportCaseByTypeItemSub(conn, itmno, listItmSubObj,ThaiToEngDate(fromDate),ThaiToEngDate(toDate), false, tempTableName);
    	  			  
    	  			     listSelProject = ListSelectedProjectName(conn, tempTableName);
    	  			 }
    	  		}
    	  		
    	  		 String typeName = GetTypeName(conn, itmno);
    	  		
    	  		 request.setAttribute("reportResultHD", arrReportObj);
    	  		 request.setAttribute("resultSub", listItmSubObj);
    	  		 request.setAttribute("projSelectdList", listSelProject);
    	  		
    	  		 request.setAttribute("typeName", typeName);//typeName
    	  		 request.setAttribute("fromDate", fromDate);//05/08/2558
 				 request.setAttribute("toDate",toDate);//05/08/2558
 				 request.setAttribute("typeDDL",reportType);//TYPE,PROJECT,AGENT
 				 request.setAttribute("multiFlag",multiFlag);//0=ALL
 				 request.setAttribute("itemNo",itmno);
 				 request.setAttribute("projectSel", projSelDDL+"|");//LH:075|AR:011..

 		   		//*********Dispatcher  	 
 			  	//System.err.println("-------------------GenReport OK-------------------------------");	 
 			  	
 			  	String tarGetUrl ="/SERV_ReportSvcDesc.jsp";
 		   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
 				dispatcher.forward(request,response);	
 				 
 				/****** Clear *******/
 				conn.close();
 				conn = null;
 			}catch(Exception e){
 				System.err.println("!!! doExpandReportForm , " +sysName+":"+ clazzName + " : " + e.getMessage());
 				msgTxt = "doExpandReportForm , " +sysName+":"+ clazzName + " : " + e.getMessage();
 				response.sendRedirect(ERROR_PAGE+msgTxt);
 			}
 			finally{			
 				//clean up.
 				try{
 					if(conn!=null){conn.close();}
 				}catch(Exception e){}
 			}
 		} 	
 		/*********************************
 		 * Method doFodoGenReportFormrmLoad criteria projectDDL
 		 * @param request
 		 * @param response
 		 * @param user
 		 * @throws ServletException
 		 * @throws IOException
 		 *********************************/
 		protected void doGenReportForm(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
 			// TODO Auto-generated method stub
 			response.setContentType("text/html; charset=TIS-620");
 			Connection conn = null;
 			ServletContext context = getServletContext();
 			HttpSession session = request.getSession(false);
 			//String okPage = "";//Constants.APP_PATH+Constants.SAVE_PAGE;
 			//String targetPage ="";//  Constants.APP_PATH+Constants.APP_HOME;
 			//String errorCode = "99";	
 			String msgTxt = "";// Constants.APP_PATH+Constants.SAVE_PAGE;
 			String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
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
 				String[] projSelDDL = request.getParameterValues("projSelDDL"); //AA:999
 	  			String fromDate = doString.checkString(request.getParameter("fromDate"),"");//23/09/2558
 	  			String toDate = doString.checkString(request.getParameter("toDate"),""); //22/09/2558
 	  			String reportType = doString.checkString(request.getParameter("typeDDL"),""); 
 	  			String multiFlag = doString.checkString(request.getParameter("multiFlag"),""); //0=All project,1 = by project

 	  		    List arrReportObj= new ArrayList();
 	  		    List listSelProject  = null;
 	  		    List listObj = null;
 			  	/**********************************/
 	        	String tempTableName = "tblByProjectX1";
    	  		if(multiFlag.equals("0")){//TODO: CASE : ALL Project
    	  			if(Constant_type.equalsIgnoreCase(reportType)){  
    	  				//TODO: Case Type
    	  				listObj = ListTypeRepair(conn);
    	  				arrReportObj = ListReportCaseByType(conn, listObj,ThaiToEngDate(fromDate),ThaiToEngDate(toDate), true, tempTableName);
    	  			}else if(Constant_agent.equalsIgnoreCase(reportType)){
    	  				//TODO: Case Agent
    	  				listObj = ListAgentName(conn);
       	  			 	arrReportObj = ListReportCaseByAgent(conn, listObj,ThaiToEngDate(fromDate),ThaiToEngDate(toDate), true, tempTableName);
    	  			}else if(Constant_project.equalsIgnoreCase(reportType)){ 
    	  				//TODO:Case Project
    	  				listObj = ListAllProjectName(conn, ThaiToEngDate(fromDate), ThaiToEngDate(toDate));
    	  				arrReportObj = ListReportCaseByProject(conn, listObj,ThaiToEngDate(fromDate),ThaiToEngDate(toDate), true, tempTableName);
    	  			}
    	  		}else{
    	  			 //call crete temp table & Insert temp table
    	  			 CreateTempTableProject(conn, projSelDDL, tempTableName);
    	  			 //System.err.println("===========>Crete Table OK.....");
    	  			 listSelProject = ListSelectedProjectName(conn, tempTableName);
    	  			 
    	  			//System.err.println("===========>List Project Selected.....");
     	  			if(Constant_type.equalsIgnoreCase(reportType)){  
    	  				//TODO: Case Type
     	  				listObj = ListTypeRepair(conn);
     	  				arrReportObj = ListReportCaseByType(conn, listObj,ThaiToEngDate(fromDate),ThaiToEngDate(toDate), false, tempTableName);
    	  			}else if(Constant_agent.equalsIgnoreCase(reportType)){
    	  				//TODO: Case Agent
    	  				listObj= ListAgentName(conn);
       	  			 	arrReportObj = ListReportCaseByAgent(conn, listObj,ThaiToEngDate(fromDate),ThaiToEngDate(toDate), false, tempTableName);
    	  			}else if(Constant_project.equalsIgnoreCase(reportType)){ 
    	  				//TODO:Case Project
    	  				
    	  				arrReportObj = ListReportCaseByProject(conn, listSelProject,ThaiToEngDate(fromDate),ThaiToEngDate(toDate), false, tempTableName);
    	  			}
    	  		}
    	  		
    	  		 request.setAttribute("reportResultHD", arrReportObj);
    	  		 request.setAttribute("resultSub", listObj);
    	  		 request.setAttribute("projSelectdList", listSelProject);
    	  		
    	  		 request.setAttribute("fromDate", fromDate);//05/08/2558
 				 request.setAttribute("toDate",toDate);//05/08/2558
 				 request.setAttribute("typeDDL",reportType);//TYPE,PROJECT,AGENT
 				 request.setAttribute("multiFlag",multiFlag);//0=ALL

 		   		//*********Dispatcher  	 
 			  	//System.err.println("-------------------GenReport OK-------------------------------");	 
 			  	
 			  	String tarGetUrl ="/SERV_ReportSvcView.jsp";
 		   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
 				dispatcher.forward(request,response);	
 				 
 				/****** Clear *******/
 				conn.close();
 				conn = null;
 			}catch(Exception e){
 				System.err.println("!!! doGenReportForm , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
 		
 		/****************************************
 		 * Create temp_project select form HTML Form
 		 * @param conn
 		 * @param projectArr
 		 * @param TempTableName
 		 *****************************************/
  		private void CreateTempTableProject(Connection conn, String projectArr[],String TempTableName) {
 			StringBuffer sql = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 	        try{
 	        	//initial paramter	        
 	        	String sqlDelete = " Delete "+TempTableName;
 	        	//int i=1;
 				/******************************************************/
 	        	try{
 		        	sql.delete(0, sql.length());
 					sql.append(" Create temp table "+TempTableName+" (  ")
 					   .append(" com_id char(2),  ")
 					   .append(" proj_id char(3) ")
 					   .append(" ); ");	
 		        	pstmt = conn.prepareStatement(sql.toString()); 
 		        	pstmt.executeUpdate();
 	        	}catch(Exception e){
 	        		System.err.println("MSG == already exists in session (bck."+TempTableName+") ==");
 		        	pstmt = conn.prepareStatement(sqlDelete); 
 		        	pstmt.executeUpdate();
 	        	}
 				sql.delete(0, sql.length());
 				sql.append(" INSERT INTO  "+TempTableName+"(com_id,proj_id)  VALUES( ? , ? ); ");
 				//System.err.println("SQL Insert :"+sql.toString());
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
 				System.err.println("!!InsertTempTable , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
  		
  		public  List  ListReportCaseByType(Connection conn,List listType,String fromDate,String toDate,boolean isProjectALL,String tempTableName){ 
 			StringBuffer sqlFetch = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 			try{
 	        	List objListResult= new ArrayList();
 	        	//String temp_tbtData1 = "temp_tbtData3";
 	  			//-----------------
 	  			String []tempMatrix = null;
 	  			int [] CNT_MATRIX = null;//new int[15];
 	  			int MAX_COLUMN =  19 ;//COLUMN_TRANSFER.length+4; //Asign Array 19 column ,id,prefix,name,lname,0,0,0,...n
 	            //------------------- 			
 	  			if(listType!=null && listType.size()>0){	
 	  				List<String> tempList = null;
 	  				//int Loop = 0;
 	  				for (int i = 0; i < listType.size(); i++) {
 	  					tempList = (List<String>)listType.get(i);
 	  					//System.err.println(i+","+tempList.get(0)+","+tempList.get(1)+","+tempList.get(2));
 	  					//--------------------------------------
 	 	        		tempMatrix = new String[MAX_COLUMN]; //Asign Array 19 column
 	 	        		for (int n=0; n < MAX_COLUMN; n++) {
 	 	        			tempMatrix[n] = "";//Allocate a values in row&coulumn	
 	 	        			if(n>0){
 	 	        				tempMatrix[n] = "0";//Allocate a values in row&coulumn	
 	 	        			}
 	 	 	    		}//#End For  
 	  					//--------------------------------------
 	 	        		tempMatrix[0] = doString.checkString(tempList.get(0),"");//i_type
 	 	        		tempMatrix[1] = doString.checkString(tempList.get(1),"");//i_code = count items_sub
 	 	        		tempMatrix[2] = doString.checkString(tempList.get(2),"");//n_name
 	 	        		tempMatrix[3] = "";//xxx
 	 	        		//--------------------------------------
 	 	        		
 	 	        		//--------------------------------------
 	 	        		CNT_MATRIX = new int[15]; //15 column
 	 	     			for(int x = 0;x<CNT_MATRIX.length;x++){
 	 	     				CNT_MATRIX[x] = 0; //Allocate a values in row&column 
 	 	     			}
 	 	        		//--------------------------------------
 	 	        sqlFetch.delete(0, sqlFetch.length());
 	 	        sqlFetch.append(" select a.i_svc_docno,")
 	 	        		.append("  b.i_itmno, ")
 	 	        		.append(" date(d_keyin)-d.d_close_law,(")
 	 	        	    .append(" CASE")
 	 	        	      	 .append("  when date(a.d_keyin) - d.d_close_law <= 90  then  90 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 180  then 180 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 270  then 270 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 360  then 360 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 450  then 450 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 720  then 720 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 1080 then 1080 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 1440 then 1440 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 1800 then 1800 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 2160 then 2160 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 2520 then 2520 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 2880 then 2880 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 3240 then 3240 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 3600 then 3600 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law > 3600 then  3601  ") 
 	 	        	  .append(" ELSE 0 ")
 	 	        	  .append("  END ")
 	 	        	  .append(" ) as type2 ");
 	 	        	  if(isProjectALL){
 	 	        		  //Case : All project
 	  	 	        	sqlFetch.append(" From lan:svc_dochd a,lan:svc_docdt b,lan:svc_xstd c,lan:acscontr d ")
 	  	 	        	    	.append(" Where a.i_svc_docno = b.i_svc_docno ");
 	 	        	  }else{
 	 	        		 //Case : by project
 	 	  	 	        sqlFetch.append(" From lan:svc_dochd a,lan:svc_docdt b,lan:svc_xstd c,lan:acscontr d ,"+tempTableName+" x  ") //tbtDataName = 'tblByProjectX1'
 	 	  	 	        		.append(" Where a.i_svc_docno = b.i_svc_docno ")
 	 	  	 	        		.append(" and a.i_company = x.com_id ")
 	 	  	 	        		.append(" and a.i_project = x.proj_id ");
 	 	        	  }
 	 	         sqlFetch.append(" and date(a.d_keyin) between '"+fromDate+"' and  '"+toDate+"' ")	  
 	 	        		.append(" and a.i_company = d.i_company ")
	  	 	        	.append(" and a.i_project = d.i_project ")
	  	 	        	.append("  and a.i_project !='075' ")
 	 	        		.append(" and a.i_lock = d.i_sort")
 	 	        		.append(" and b.i_itmno = ?  ") //TYPE
 	 	        		.append(" and d.f_contr is null")
 	 	        		.append(" and (")
 	 	        		.append("  (b.i_itmno = c.i_type  and b.i_itmsub = c.i_code and b.i_itmsub is not null) ")
 	 	        		.append(" or (b.i_itmno = c.i_type  and c.i_code is null and b.i_itmsub is  null)")
 	 	        		.append(" or (b.i_itmno = c.i_type  and c.i_code is null and b.i_itmsub = '' ) ")
 	 	        		.append(" )")     		
 	 	        		.append(" order by type2 ");
 	       			    
 		    			System.err.println(" SQL Get By Type :"+sqlFetch.toString());
 		    			pstmt = conn.prepareStatement(sqlFetch.toString()); 
 					    pstmt.setString(1,doString.checkString(tempList.get(0),""));//i_type
 			 	        rs = pstmt.executeQuery();	
 			 	       
 			 	        int code = 0;
 	 	        		while(rs.next()){
 	 	        			code = 0;
 	 	        			code = rs.getInt("type2");
 	 	        			switch (code) {
 		 	        			case 90:
 		 	        				CNT_MATRIX[0]++;
 		 	        				break;
 		 	        			case 180:
 		 	        				CNT_MATRIX[1]++;
 		 	        				break;
 		 	        			case 270:
 		 	        				CNT_MATRIX[2]++;
 		 	        				break;
 		 	        			case 360:
 		 	        				CNT_MATRIX[3]++;
 		 	        				break;
 		 	        			case 450:
 		 	        				CNT_MATRIX[4]++;
 		 	        				break;
 		 	        			case 720:
 		 	        				CNT_MATRIX[5]++;
 		 	        				break;
 		 	        			case 1080:
 		 	        				CNT_MATRIX[6]++;
 		 	        				break;
 		 	        			case 1440:
 		 	        				CNT_MATRIX[7]++;
 		 	        				break;
 		 	        			case 1800:
 		 	        				CNT_MATRIX[8]++;
 		 	        				break;
 		 	        			case 2160:
 		 	        				CNT_MATRIX[9]++;
 		 	        				break;
 		 	        			case 2520:
 		 	        				CNT_MATRIX[10]++;
 		 	        				break;
 		 	        			case 2880:
 		 	        				CNT_MATRIX[11]++;
 		 	        				break;
 		 	        			case 3240:
 		 	        				CNT_MATRIX[12]++;
 		 	        				break;
 		 	        			case 3600:
 		 	        				CNT_MATRIX[13]++;
 		 	        				break;
 		 	        			case 3601:
 		 	        				CNT_MATRIX[14]++;
 		 	        				break;
 		 	        			default:
 		 	        				//System.err.println("===CNT_MATRIX Unknown result===");
 		 	        	            break;
 		 	        			}//#End Switch Case
 		 	        	}//#End while loop
 	 	        		//----------------------------------
 	 	        		int Loop = 4;
 	 	        		for(int x = 0;x<CNT_MATRIX.length;x++){
 	 	        			tempMatrix[Loop++] = ""+CNT_MATRIX[x];
 	 	        		}
 	 	        		/* Mapping MATRIX for view to html */
 	  					objListResult.add(tempMatrix);
 	  				}//#End For
 	  			}//#End Check size or null ArrayList

 	     	    //---#End ---/
 			  	return objListResult;			  	 
 			}catch(Exception e){
 				System.err.println("!!!ListReportCaseByType, " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.err.println(" SQL Exception: "+sqlFetch.toString());	
 				System.err.println(" Exception: "+e.toString());	
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
  		/**************************************
  		 * CASE : report by Type && All project
  		 * @param conn
  		 * @param listAgentName
  		 * @param fromDate
  		 * @param toDate
  		 * @param isProjectALL
  		 * @param tempTableName
  		 * @return  
  		 ******************************************/
  		public  List  ListReportCaseByTypeItemSub(Connection conn,String itemNo,List listTypeItmSub,String fromDate,String toDate,boolean isProjectALL,String tempTableName){ 
 			StringBuffer sqlFetch = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 			try{
 	        	List objListResult= new ArrayList();
 	        	//String temp_tbtData1 = "temp_tbtData3";
 	  			//-----------------
 	  			String []tempMatrix = null;
 	  			int [] CNT_MATRIX = null;//new int[15];
 	  			int MAX_COLUMN =  19 ;//COLUMN_TRANSFER.length+4; //Asign Array 19 column ,id,prefix,name,lname,0,0,0,...n
 	           //------------------- 			
 	  			if(listTypeItmSub!=null && listTypeItmSub.size()>0){	
 	  				List<String> tempList = null;
 	  				//int Loop = 0;
 	  				for (int i = 0; i < listTypeItmSub.size(); i++) {
 	  					tempList = (List<String>)listTypeItmSub.get(i);
 	  					//System.err.println(i+","+tempList.get(0)+","+tempList.get(1)+","+tempList.get(2));
 	  					//--------------------------------------
 	 	        		tempMatrix = new String[MAX_COLUMN]; //Asign Array 19 column
 	 	        		for (int n=0; n < MAX_COLUMN; n++) {
 	 	        			tempMatrix[n] = "";//Allocate a values in row&coulumn	
 	 	        			if(n>0){
 	 	        				tempMatrix[n] = "0";//Allocate a values in row&coulumn	
 	 	        			}
 	 	 	    		}//#End For  
 	  					//--------------------------------------
 	 	        		tempMatrix[0] = doString.checkString(tempList.get(0),"");//i_type
 	 	        		tempMatrix[1] = doString.checkString(tempList.get(1),"");//i_code 
 	 	        		tempMatrix[2] = doString.checkString(tempList.get(2),"");//n_name
 	 	        		tempMatrix[3] = "";//xxx
 	 	        		//--------------------------------------
 	 	        		
 	 	        		//--------------------------------------
 	 	        		CNT_MATRIX = new int[15]; //15 column
 	 	     			for(int x = 0;x<CNT_MATRIX.length;x++){
 	 	     				CNT_MATRIX[x] = 0; //Allocate a values in row&column 
 	 	     			}
 	 	        		//--------------------------------------
 	 	        sqlFetch.delete(0, sqlFetch.length());
 	 	        sqlFetch.append(" select a.i_svc_docno,")
 	 	        		.append("  b.i_itmsub, ")
 	 	        		.append(" date(d_keyin)-d.d_close_law,(")
 	 	        	    .append(" CASE")
 	 	        	      	 .append("  when date(a.d_keyin) - d.d_close_law <= 90  then  90 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 180  then 180 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 270  then 270 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 360  then 360 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 450  then 450 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 720  then 720 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 1080 then 1080 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 1440 then 1440 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 1800 then 1800 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 2160 then 2160 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 2520 then 2520 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 2880 then 2880 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 3240 then 3240 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 3600 then 3600 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law > 3600 then  3601  ") 
 	 	        	  .append(" ELSE 0 ")
 	 	        	  .append("  END ")
 	 	        	  .append(" ) as type2 ");
 	 	        	  if(isProjectALL){
 	 	        		  //Case : All project
 	  	 	        	sqlFetch.append(" From lan:svc_dochd a,lan:svc_docdt b,lan:svc_xstd c,lan:acscontr d ")
 	  	 	        	    	.append(" Where a.i_svc_docno = b.i_svc_docno ");
 	 	        	  }else{
 	 	        		 //Case : by project
 	 	  	 	        sqlFetch.append(" From lan:svc_dochd a,lan:svc_docdt b,lan:svc_xstd c,lan:acscontr d ,"+tempTableName+" x  ") //tbtDataName = 'tblByProjectX1'
 	 	  	 	        		.append(" Where a.i_svc_docno = b.i_svc_docno ")
 	 	  	 	        		.append(" and a.i_company = x.com_id ")
 	 	  	 	        		.append(" and a.i_project = x.proj_id ");
 	 	        	  }
 	 	         sqlFetch.append(" and date(a.d_keyin) between '"+fromDate+"' and  '"+toDate+"' ")	  
 	 	        		.append(" and a.i_company = d.i_company ")
	  	 	        	.append(" and a.i_project = d.i_project ")
	  	 	        	.append("  and a.i_project !='075' ")
 	 	        		.append(" and a.i_lock = d.i_sort")
 	 	        		.append(" and b.i_itmno = '"+itemNo+"'  ") //itmno
 	 	        		.append(" and b.i_itmsub = ?  ") //itmsub
 	 	        		.append(" and d.f_contr is null")
 	 	        		.append(" and (")
 	 	        		.append("  (b.i_itmno = c.i_type  and b.i_itmsub = c.i_code and b.i_itmsub is not null) ")
 	 	        		.append(" or (b.i_itmno = c.i_type  and c.i_code is null and b.i_itmsub is  null)")
 	 	        		.append(" or (b.i_itmno = c.i_type  and c.i_code is null and b.i_itmsub = '' ) ")
 	 	        		.append(" )")     		
 	 	        		.append(" order by type2 ");
 	       			    
 		    			//System.out.println((" SQL Get By Item_sub :"+sqlFetch.toString());
 		    			pstmt = conn.prepareStatement(sqlFetch.toString()); 
 					    pstmt.setString(1,doString.checkString(tempList.get(1),""));//item_sub
 			 	        rs = pstmt.executeQuery();	
 			 	       
 			 	        int code = 0;
 	 	        		while(rs.next()){
 	 	        			code = 0;
 	 	        			code = rs.getInt("type2");
 	 	        			switch (code) {
 		 	        			case 90:
 		 	        				CNT_MATRIX[0]++;
 		 	        				break;
 		 	        			case 180:
 		 	        				CNT_MATRIX[1]++;
 		 	        				break;
 		 	        			case 270:
 		 	        				CNT_MATRIX[2]++;
 		 	        				break;
 		 	        			case 360:
 		 	        				CNT_MATRIX[3]++;
 		 	        				break;
 		 	        			case 450:
 		 	        				CNT_MATRIX[4]++;
 		 	        				break;
 		 	        			case 720:
 		 	        				CNT_MATRIX[5]++;
 		 	        				break;
 		 	        			case 1080:
 		 	        				CNT_MATRIX[6]++;
 		 	        				break;
 		 	        			case 1440:
 		 	        				CNT_MATRIX[7]++;
 		 	        				break;
 		 	        			case 1800:
 		 	        				CNT_MATRIX[8]++;
 		 	        				break;
 		 	        			case 2160:
 		 	        				CNT_MATRIX[9]++;
 		 	        				break;
 		 	        			case 2520:
 		 	        				CNT_MATRIX[10]++;
 		 	        				break;
 		 	        			case 2880:
 		 	        				CNT_MATRIX[11]++;
 		 	        				break;
 		 	        			case 3240:
 		 	        				CNT_MATRIX[12]++;
 		 	        				break;
 		 	        			case 3600:
 		 	        				CNT_MATRIX[13]++;
 		 	        				break;
 		 	        			case 3601:
 		 	        				CNT_MATRIX[14]++;
 		 	        				break;
 		 	        			default:
 		 	        				//System.err.println("===CNT_MATRIX Unknown result===");
 		 	        	            break;
 		 	        			}//#End Switch Case
 		 	        	}//#End while loop
 	 	        		//----------------------------------
 	 	        		int Loop = 4;
 	 	        		for(int x = 0;x<CNT_MATRIX.length;x++){
 	 	        			tempMatrix[Loop++] = ""+CNT_MATRIX[x];
 	 	        		}
 	 	        		/* Mapping MATRIX for view to html */
 	  					objListResult.add(tempMatrix);
 	  				}//#End For
 	  			}//#End Check size or null ArrayList

 	     	    //---#End ---/
 			  	return objListResult;			  	 
 			}catch(Exception e){
 				System.err.println("!!!ListReportCaseByTypeItemSub, " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.err.println(" SQL Exception: "+sqlFetch.toString());	
 				System.err.println(" Exception: "+e.toString());	
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

 		/*****************************************
 		 * CASE : report by  Project && All project
 		 * @param conn
 		 * @param listAgentName
 		 * @param fromDate
 		 * @param toDate
 		 * @param isProjectALL
 		 * @param tempTableName
 		 * @return
 		 ********************************************/
  		public  List  ListReportCaseByProject(Connection conn,List listProject,String fromDate,String toDate,boolean isProjectALL,String tempTableName){ 
 			StringBuffer sqlFetch = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 			try{
 	        	List objListResult= new ArrayList();    
 	        	//String temp_tbtData1 = "temp_tbtData3";
 	  			//-----------------
 	  			String []tempMatrix = null;
 	  			int [] CNT_MATRIX = null;//new int[15];
 	  			int MAX_COLUMN =  19 ;//COLUMN_TRANSFER.length+4; //Asign Array 19 column ,id,prefix,name,lname,0,0,0,...n
 	           //------------------- 			
 	  			if(listProject!=null && listProject.size()>0){	
 	  				List<String> tempList = null;
 	  				//int Loop = 0;
 	  				for (int i = 0; i < listProject.size(); i++) {
 	  					tempList = (List<String>)listProject.get(i);
 	  					//System.err.println(i+","+tempList.get(0)+","+tempList.get(1)+","+tempList.get(2));
 	  					//--------------------------------------
 	 	        		tempMatrix = new String[MAX_COLUMN]; //Asign Array 19 column
 	 	        		for (int n=0; n < MAX_COLUMN; n++) {
 	 	        			tempMatrix[n] = "";//Allocate a values in row&coulumn	
 	 	        			if(n>0){
 	 	        				tempMatrix[n] = "0";//Allocate a values in row&coulumn	
 	 	        			}
 	 	 	    		}//#End For  
 	  					//--------------------------------------
 	 	        		tempMatrix[0] = doString.checkString(tempList.get(0),"");//com_id
 	 	        		tempMatrix[1] = doString.checkString(tempList.get(1),"");//project_id
 	 	        		tempMatrix[2] = doString.checkString(tempList.get(2),"");//n_project
 	 	        		tempMatrix[3] = "";
 	 	        		//--------------------------------------
 	 	        		
 	 	        		//--------------------------------------
 	 	        		CNT_MATRIX = new int[15]; //15 column
 	 	     			for(int x = 0;x<CNT_MATRIX.length;x++){
 	 	     				CNT_MATRIX[x] = 0; //Allocate a values in row&column 
 	 	     			}
 	 	        		//--------------------------------------
 	 	        sqlFetch.delete(0, sqlFetch.length());
 	 	        sqlFetch.append(" select a.i_svc_docno,")
 	 	        	    .append(" a.i_company,")	   
 	 	        	    .append(" a.i_project,")
 	 	        		.append(" date(d_keyin)-d.d_close_law,(")
 	 	        	    .append(" CASE")
 	 	        	      	 .append("  when date(a.d_keyin) - d.d_close_law <= 90  then  90 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 180  then 180 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 270  then 270 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 360  then 360 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 450  then 450 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 720  then 720 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 1080 then 1080 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 1440 then 1440 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 1800 then 1800 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 2160 then 2160 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 2520 then 2520 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 2880 then 2880 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 3240 then 3240 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 3600 then 3600 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law > 3600 then  3601  ") 
 	 	        	  .append(" ELSE 0 ")
 	 	        	  .append("  END ")
 	 	        	  .append(" ) as type2 ");
 	 	        	  if(isProjectALL){
 	 	        		  //Case : All project
 	  	 	        	sqlFetch.append(" From lan:svc_dochd a,lan:svc_docdt b,lan:svc_xstd c,lan:acscontr d ")
 	  	 	        	    	.append(" Where a.i_svc_docno = b.i_svc_docno ");
 	 	        	  }else{
 	 	        		 //Case : by project
 	 	  	 	        sqlFetch.append(" From lan:svc_dochd a,lan:svc_docdt b,lan:svc_xstd c,lan:acscontr d ,"+tempTableName+" x  ") //tbtDataName = 'tblByProjectX1'
 	 	  	 	        		.append(" Where a.i_svc_docno = b.i_svc_docno ")
 	 	  	 	        		.append(" and a.i_company = x.com_id ")
 	 	  	 	        		.append(" and a.i_project = x.proj_id ");
 	 	        	  }
 	 	         sqlFetch.append(" and date(a.d_keyin) between '"+fromDate+"' and  '"+toDate+"' ")	  
 	 	        		.append(" and a.i_company = d.i_company ")
	  	 	        	.append(" and a.i_project = d.i_project ")
	  	 	        	.append("  and a.i_project !='075' ")
 	 	        		.append(" and a.i_lock = d.i_sort ")
 	 	        		.append(" and a.i_company = ? ")
 	 	        		.append(" and a.i_project = ? ")
 	 	        		.append(" and d.f_contr is null")
 	 	        		.append(" and (")
 	 	        		.append("  (b.i_itmno = c.i_type  and b.i_itmsub = c.i_code and b.i_itmsub is not null) ")
 	 	        		.append(" or (b.i_itmno = c.i_type  and c.i_code is null and b.i_itmsub is  null)")
 	 	        		.append(" or (b.i_itmno = c.i_type  and c.i_code is null and b.i_itmsub = '' ) ")
 	 	        		.append(" )")     		
 	 	        		.append(" order by type2 ");
 	       			    
 		    			//System.err.println(" SQL Get By Project :"+sqlFetch.toString());
 		    			pstmt = conn.prepareStatement(sqlFetch.toString()); 
 					    pstmt.setString(1,doString.checkString(tempList.get(0),""));//i_company
 					    pstmt.setString(2,doString.checkString(tempList.get(1),""));//i_project
 			 	        rs = pstmt.executeQuery();	
 			 	       
 			 	        int code = 0;
 	 	        		while(rs.next()){
 	 	        			code = 0;
 	 	        			code = rs.getInt("type2");
 	 	        			switch (code) {
 		 	        			case 90:
 		 	        				CNT_MATRIX[0]++;
 		 	        				break;
 		 	        			case 180:
 		 	        				CNT_MATRIX[1]++;
 		 	        				break;
 		 	        			case 270:
 		 	        				CNT_MATRIX[2]++;
 		 	        				break;
 		 	        			case 360:
 		 	        				CNT_MATRIX[3]++;
 		 	        				break;
 		 	        			case 450:
 		 	        				CNT_MATRIX[4]++;
 		 	        				break;
 		 	        			case 720:
 		 	        				CNT_MATRIX[5]++;
 		 	        				break;
 		 	        			case 1080:
 		 	        				CNT_MATRIX[6]++;
 		 	        				break;
 		 	        			case 1440:
 		 	        				CNT_MATRIX[7]++;
 		 	        				break;
 		 	        			case 1800:
 		 	        				CNT_MATRIX[8]++;
 		 	        				break;
 		 	        			case 2160:
 		 	        				CNT_MATRIX[9]++;
 		 	        				break;
 		 	        			case 2520:
 		 	        				CNT_MATRIX[10]++;
 		 	        				break;
 		 	        			case 2880:
 		 	        				CNT_MATRIX[11]++;
 		 	        				break;
 		 	        			case 3240:
 		 	        				CNT_MATRIX[12]++;
 		 	        				break;
 		 	        			case 3600:
 		 	        				CNT_MATRIX[13]++;
 		 	        				break;
 		 	        			case 3601:
 		 	        				CNT_MATRIX[14]++;
 		 	        				break;
 		 	        			default:
 		 	        				//System.err.println("===CNT_MATRIX Unknown result===");
 		 	        	            break;
 		 	        			}//#End Switch Case
 		 	        	}//#End while loop
 	 	        		//----------------------------------
 	 	        		int Loop = 4;
 	 	        		for(int x = 0;x<CNT_MATRIX.length;x++){
 	 	        			tempMatrix[Loop++] = ""+CNT_MATRIX[x];
 	 	        		}
 	 	        		/* Mapping MATRIX for view to html */
 	  					objListResult.add(tempMatrix);
 	  				}//#End For
 	  			}//#End Check size or null ArrayList

 	     	    //---#End ---/
 			  	return objListResult;			  	 
 			}catch(Exception e){
 				System.err.println("!!!ListReportCaseByProject, " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.err.println(" SQL Exception: "+sqlFetch.toString());	
 				System.err.println(" Exception: "+e.toString());	
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
 		
 		/***********************************************
 		 * @param conn
 		 * @param listAgentName
 		 * @param fromDate
 		 * @param toDate
 		 * @param isProjectALL
 		 * @param tempTableName
 		 * @return
 		 * CASE : report by Agent&&All project
 		 **********************************************/
  		public  List  ListReportCaseByAgent(Connection conn,List listAgentName,String fromDate,String toDate,boolean isProjectALL,String tempTableName){ 
 			StringBuffer sqlFetch = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 			try{
 	        	List objListResult= new ArrayList();
 	        	//String temp_tbtData1 = "temp_tbtData3";
 	  			//-----------------
 	  			String []tempMatrix = null;
 	  			int [] CNT_MATRIX = null;//new int[15];
 	  			int MAX_COLUMN =  19 ;//COLUMN_TRANSFER.length+4; //Asign Array 19 column ,id,prefix,name,lname,0,0,0,...n
 	           //------------------- 			
 	  			if(listAgentName!=null && listAgentName.size()>0){	
 	  				List<String> tempList = null;
 	  				//int Loop = 0;
 	  				for (int i = 0; i < listAgentName.size(); i++) {
 	  					tempList = (List<String>)listAgentName.get(i);
 	  					//System.err.println(i+","+tempList.get(0)+","+tempList.get(1)+","+tempList.get(2));
 	  					//--------------------------------------
 	 	        		tempMatrix = new String[MAX_COLUMN]; //Asign Array 19 column
 	 	        		for (int n=0; n < MAX_COLUMN; n++) {
 	 	        			tempMatrix[n] = "";//Allocate a values in row&coulumn	
 	 	        			if(n>0){
 	 	        				tempMatrix[n] = "0";//Allocate a values in row&coulumn	
 	 	        			}
 	 	 	    		}//#End For  
 	  					//--------------------------------------
 	 	        		tempMatrix[0] = doString.checkString(tempList.get(0),"");//i_employ
 	 	        		tempMatrix[1] = doString.checkString(tempList.get(1),"");//prefix
 	 	        		tempMatrix[2] = doString.checkString(tempList.get(2),"");//fname
 	 	        		tempMatrix[3] = doString.checkString(tempList.get(3),"");//lname
 	 	        		//--------------------------------------
 	 	        		
 	 	        		//--------------------------------------
 	 	        		CNT_MATRIX = new int[15]; //15 column
 	 	     			for(int x = 0;x<CNT_MATRIX.length;x++){
 	 	     				CNT_MATRIX[x] = 0; //Allocate a values in row&column 
 	 	     			}
 	 	        		//--------------------------------------
 	 	        		sqlFetch.delete(0, sqlFetch.length());
 	 	        		sqlFetch.append(" select a.i_svc_docno,")
 	 	        	   // .append(" a.i_agent,")
 	 	        	   // .append(" a.i_employ,")
 	 	        		.append(" date(d_keyin)-d.d_close_law,(")
 	 	        	    .append(" CASE")
 	 	        	      	 .append("  when date(a.d_keyin) - d.d_close_law <= 90  then  90 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 180  then 180 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 270  then 270 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 360  then 360 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 450  then 450 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 720  then 720 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 1080 then 1080 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 1440 then 1440 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 1800 then 1800 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 2160 then 2160 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 2520 then 2520 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 2880 then 2880 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 3240 then 3240 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law <= 3600 then 3600 ")
 	 	        		     .append("  when date(a.d_keyin) - d.d_close_law > 3600 then  3601  ") 
 	 	        	  .append(" ELSE 0 ")
 	 	        	  .append("  END ")
 	 	        	  .append(" ) as type2 ");
 	 	        	  if(isProjectALL){
 	 	        		  //Case : All project
 	  	 	        	sqlFetch.append(" From lan:svc_dochd a,lan:svc_docdt b,lan:svc_xstd c,lan:acscontr d ")
 	  	 	        	    	.append(" Where a.i_svc_docno = b.i_svc_docno ");
 	 	        	  }else{
 	 	        		 //Case : by project
 	 	  	 	        sqlFetch.append(" From lan:svc_dochd a,lan:svc_docdt b,lan:svc_xstd c,lan:acscontr d ,"+tempTableName+" x  ") //tbtDataName = 'tblByProjectX1'
 	 	  	 	        		.append(" Where a.i_svc_docno = b.i_svc_docno ")
 	 	  	 	        		.append(" and a.i_company = x.com_id ")
 	 	  	 	        		.append(" and a.i_project = x.proj_id ");
 	 	        	  }
 	 	         sqlFetch.append(" and date(a.d_keyin) between '"+fromDate+"' and  '"+toDate+"'  ")	  
 	 	        		.append(" and a.i_company = d.i_company ")
	  	 	        	.append(" and a.i_project = d.i_project ")
	  	 	        	.append("  and a.i_project !='075' ")
 	 	        		.append(" and a.i_lock = d.i_sort")
 	 	        		.append(" and a.i_employ = ? ")
 	 	        		.append(" and d.f_contr is null")
 	 	        		.append(" and (")
 	 	        		.append("  (b.i_itmno = c.i_type  and b.i_itmsub = c.i_code and b.i_itmsub is not null) ")
 	 	        		.append(" or (b.i_itmno = c.i_type  and c.i_code is null and b.i_itmsub is  null)")
 	 	        		.append(" or (b.i_itmno = c.i_type  and c.i_code is null and b.i_itmsub = '' ) ")
 	 	        		.append(" )")     		
 	 	        		.append(" order by type2 ");
 	       			    
 		    			//System.err.println(" SQL Get By Agent :"+sqlFetch.toString());
 		    			pstmt = conn.prepareStatement(sqlFetch.toString()); 
 					    pstmt.setString(1,tempList.get(0));//i_employ
 			 	        rs = pstmt.executeQuery();	
 			 	       
 			 	        int code = 0;
 	 	        		while(rs.next()){
 	 	        			code = 0;
 	 	        			code = rs.getInt("type2");
 	 	        			switch (code) {
 		 	        			case 90:
 		 	        				CNT_MATRIX[0]++;
 		 	        				break;
 		 	        			case 180:
 		 	        				CNT_MATRIX[1]++;
 		 	        				break;
 		 	        			case 270:
 		 	        				CNT_MATRIX[2]++;
 		 	        				break;
 		 	        			case 360:
 		 	        				CNT_MATRIX[3]++;
 		 	        				break;
 		 	        			case 450:
 		 	        				CNT_MATRIX[4]++;
 		 	        				break;
 		 	        			case 720:
 		 	        				CNT_MATRIX[5]++;
 		 	        				break;
 		 	        			case 1080:
 		 	        				CNT_MATRIX[6]++;
 		 	        				break;
 		 	        			case 1440:
 		 	        				CNT_MATRIX[7]++;
 		 	        				break;
 		 	        			case 1800:
 		 	        				CNT_MATRIX[8]++;
 		 	        				break;
 		 	        			case 2160:
 		 	        				CNT_MATRIX[9]++;
 		 	        				break;
 		 	        			case 2520:
 		 	        				CNT_MATRIX[10]++;
 		 	        				break;
 		 	        			case 2880:
 		 	        				CNT_MATRIX[11]++;
 		 	        				break;
 		 	        			case 3240:
 		 	        				CNT_MATRIX[12]++;
 		 	        				break;
 		 	        			case 3600:
 		 	        				CNT_MATRIX[13]++;
 		 	        				break;
 		 	        			case 3601:
 		 	        				CNT_MATRIX[14]++;
 		 	        				break;
 		 	        			default:
 		 	        				//System.err.println("===CNT_MATRIX Unknown result===");
 		 	        	            break;
 		 	        			}//#End Switch Case
 		 	        	}//#End while loop
 	 	        		//----------------------------------
 	 	        		int Loop = 4;
 	 	        		for(int x = 0;x<CNT_MATRIX.length;x++){
 	 	        			tempMatrix[Loop++] = ""+CNT_MATRIX[x];
 	 	        		}
 	 	        		/* Mapping MATRIX for view to html */
 	  					objListResult.add(tempMatrix);
 	  				}//#End For
 	  			}//#End Check size or null ArrayList

 	     	    //---#End ---/
 			  	return objListResult;			  	 
 			}catch(Exception e){
 				System.err.println("!!!ListReportCaseAgent, " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.err.println(" SQL Exception: "+sqlFetch.toString());	
 				System.err.println(" Exception: "+e.toString());	
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
 		
 		/*****************************************
 		 * ListAllProjectName
 		 * @param conn
 		 * @param fromDate
 		 * @param toDate
 		 * @return
 		 ******************************************/
 		private List ListAllProjectName(Connection conn,String fromDate,String toDate) {
 			StringBuffer sql = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 	        try{
 	        	//initial paramter	     	
 				/*************************************************/	
 	        	List listResult = new ArrayList();
 	       	 	List strList = null;	
 	        	//*****Find project by user login  
 				sql.delete(0,sql.length());
 				sql.append(" Select  unique a.i_company,a.i_project,x.n_project  from lan:svc_dochd a, lan:acxprojt x ")
 					.append(" Where date(a.d_keyin) between '"+fromDate+"' and  '"+toDate+"' ")
 					.append(" and a.i_project !='075'  ")
 					.append(" and a.i_company = x.i_company ")
 					.append(" and a.i_project = x.i_project ")
 					.append(" order by a.i_company,a.i_project ");
 				pstmt = conn.prepareStatement(sql.toString()); 
 				//System.out.println("SQL :"+sql.toString());
 				rs = pstmt.executeQuery();	
 				while(rs.next()){
 					//projectNamme = doString.checkString(rs.getString("n_project"), "");
 					strList =  new ArrayList(); 
					strList.add(0,  doString.checkString(rs.getString("i_company"),""));
					strList.add(1,  doString.checkString(rs.getString("i_project"),""));
					strList.add(2,  doString.checkString(rs.getString("n_project"),""));
					listResult.add(strList);
 				}
 				rs.close();	
 		   			
 				//**************************************************/
 			  	//System.out.println("##ListAllProjectName ->successfully.");				  	 
 			  	return listResult;			  	 
 			}catch(Exception e){
 				System.err.println("!!!ListAllProjectName , " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.err.println(" SQL Exception: "+sql.toString());		
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
 		
 		/***********************************
 		 * GetProjectName
 		 * @param conn
 		 * @param tbtTempProject
 		 * @return
 		 ************************************/
 		private List ListSelectedProjectName(Connection conn,String tbtTempProject) {
 			StringBuffer sql = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 	        try{
 	        	//initial paramter	     	
 				/*************************************************/	
 	        	List listResult = new ArrayList();
 	       	 	List strList = null;	
 	        	//*****Find project by user login  
 				sql.delete(0,sql.length());
 				sql.append("Select x.com_id,x.proj_id,a.n_project From lan:acxprojt a,"+tbtTempProject+" x   ")
 					.append(" Where   ")
 					.append(" a.i_company = x.com_id  ")
 					.append(" AND a.i_project = x.proj_id ");
 				pstmt = conn.prepareStatement(sql.toString()); 
 				//System.out.println("SQL :"+sql.toString());
 				rs = pstmt.executeQuery();	
 				while(rs.next()){
 					//projectNamme = doString.checkString(rs.getString("n_project"), "");
 					strList =  new ArrayList(); 
					strList.add(0,  doString.checkString(rs.getString("com_id"),""));
					strList.add(1,  doString.checkString(rs.getString("proj_id"),""));
					strList.add(2,  doString.checkString(rs.getString("n_project"),""));
					listResult.add(strList);
 				}
 				rs.close();	
 		   			
 				//**************************************************/
 			  	//System.out.println("##ListSelectedProjectName ->successfully.");				  	 
 			  	return listResult;			  	 
 			}catch(Exception e){
 				System.err.println("!!!ListSelectedProjectName , " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.err.println(" SQL Exception: "+sql.toString());		
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
 		
 		/**********************************
 		 * @param conn
 		 * @return
 		 **********************************/
 		private List ListAgentName(Connection conn) {
 			StringBuffer sql = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 	        try{
 	        	//initial paramter	
 	        	List listAgent = new ArrayList();
 	       	 	List strList = null;	     
 				/*************************************************/
	 	       	sql.delete(0,sql.length());
	 	       	sql.append(" select a.i_employ,a.n_prename_th,a.n_nemploy_th,a.n_semploy_th ")
	 	       	   .append(" from lan:svc_agent b,docflow:acemploy a ")
	 	    	   .append(" where a.i_employ = b.i_employ ")
	 	    	   .append(" and b.i_employ not in ('0719-1','2154-6') ")
	 	    	   .append(" order by a.n_nemploy_th ");
 				pstmt = conn.prepareStatement(sql.toString()); 
 				//System.err.println("SQL 'ListAgentName' :"+sql.toString());
 				rs = pstmt.executeQuery();	
 				while(rs.next()){
 					strList =  new ArrayList(); 
					strList.add(0,  doString.checkString(rs.getString("i_employ"),""));
					strList.add(1,  doString.checkString(rs.getString("n_prename_th"),""));
					strList.add(2,  doString.checkString(rs.getString("n_nemploy_th"),""));
					strList.add(3,  doString.checkString(rs.getString("n_semploy_th"),""));
 					listAgent.add(strList);
 				}
 				rs.close();	
 		   			
 				//**************************************************/
 			  	//System.out.println("##ListAgentName ->successfully.");				  	 
 			  	return listAgent;			  	 
 			}catch(Exception e){
 				System.err.println("!!!ListAgentName , " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.err.println(" SQL Exception: "+sql.toString());		
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

 		private List ListTypeItemSub(Connection conn,String iType) { 
 			// TODO Auto-generated method stub
 			StringBuffer sql = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 	        try{
 	        	//initial paramter		
 	        	//System.out.println("##ListTypeItemSub ->Starting.");   
 	        	List  resultList = new ArrayList();
 	       	 	List strList = null;
 				/******************************************************/	       	
 				sql.delete(0,sql.length());
 				sql.append(" select i_type,i_code,n_desc from svc_xstd ")
 					.append(" where i_code is not null ")
 					.append(" and i_type = '"+iType+"' ")
 					.append(" order by 1  ");
 
 				//System.err.println("TYPE :' XSTD01 DDL - SQL :"+sql.toString());
 				pstmt = conn.prepareStatement(sql.toString());
 				rs = pstmt.executeQuery();	
 				while(rs.next()){	
 					strList =  new ArrayList(); 
					strList.add(0,  doString.checkString(rs.getString("i_type"),""));
					strList.add(1,  doString.checkString(rs.getString("i_code"),"")); //code
					strList.add(2,  doString.checkString(rs.getString("n_desc"),""));
					resultList.add(strList);
 				}
 				rs.close();				
 				//********************************************************/
 			  	//System.out.println("##ListTypeItemSub ->end.");				  	 
 			  	return resultList;			  	 
 			}catch(Exception e){
 				System.err.println("!!!ListTypeItemSub , " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.err.println(" SQL Exception: "+sql.toString());		
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
 		
 		/**********************************
 		 * ListGroupHomeRepair
 		 * @param conn
 		 * @return
 		 **********************************/
 		private List ListTypeRepair(Connection conn) { 
 			// TODO Auto-generated method stub
 			StringBuffer sql = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 	        try{
 	        	//initial paramter		
 	        	//System.out.println("##ListTypeRepair ->Starting.");   
 	        	List  resultList = new ArrayList();
 	       	 	List strList = null;
 				/******************************************************/	       	
 				sql.delete(0,sql.length());
 				sql.append("select a.i_type,a.n_desc,count(b.i_code) as cnt from svc_xstd a ,svc_xstd b ")
 					.append(" where a.i_code is null ")
 					.append(" and a.i_type = b.i_type ")
 					.append(" group by 1,2 ")
 					.append(" order by 1,2 ");
 				//System.err.println("TYPE :' XSTD01 DDL - SQL :"+sql.toString());
 				pstmt = conn.prepareStatement(sql.toString());
 				rs = pstmt.executeQuery();	
 				while(rs.next()){	
 					strList =  new ArrayList(); 
					strList.add(0,  doString.checkString(rs.getString("i_type"),""));
					strList.add(1,  doString.checkString(rs.getString("cnt"),"")); 
					strList.add(2,  doString.checkString(rs.getString("n_desc"),""));
					resultList.add(strList);
 				}
 				rs.close();				
 				//********************************************************/
 			  	//System.out.println("##ListTypeRepair ->end.");				  	 
 			  	return resultList;			  	 
 			}catch(Exception e){
 				System.err.println("!!!ListTypeRepair , " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.err.println(" SQL Exception: "+sql.toString());		
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
 		private String GetNameItemSub(Connection conn,String iType,String iCode) { 
 			// TODO Auto-generated method stub
 			StringBuffer sql = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 	        try{
 	        	//initial paramter		
 	        	//System.out.println("##GetNameItemSub ->Starting.");   
 	        	String typeName = "";
 				/******************************************************/	       	
 				sql.delete(0,sql.length());
 				sql.append(" Select i_code, n_desc ")
 				   .append(" From lan:svc_xstd    ")
 				   .append(" Where i_type = '"+iType+"' and i_code = '"+iCode+"'  ");
 				
 				//System.err.println("TYPE :' XSTD01 DDL - SQL :"+sql.toString());
 				pstmt = conn.prepareStatement(sql.toString());
 				rs = pstmt.executeQuery();	
 				if(rs.next()){	
					typeName = doString.checkString(rs.getString("i_code"),"")+"-"+doString.checkString(rs.getString("n_desc"),"");
 				}
 				rs.close();				
 				//********************************************************/
 			  	//System.out.println("##GetNameItemSub ->end.");				  	 
 			  	return typeName;			  	 
 			}catch(Exception e){
 				System.err.println("!!!GetNameItemSub , " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.err.println(" SQL Exception: "+sql.toString());		
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
 		
 		private String GetTypeName(Connection conn,String iType) { 
 			// TODO Auto-generated method stub
 			StringBuffer sql = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 	        try{
 	        	//initial paramter		
 	        	//System.out.println("##ListTypeName ->Starting.");   
 	        	String typeName = "";
 				/******************************************************/	       	
 				sql.delete(0,sql.length());
 				sql.append(" Select i_type, i_code, n_desc ")
 				   .append(" From lan:svc_xstd    ")
 				   .append(" Where i_type = '"+iType+"'  ")
 				   .append(" and (i_code is  null or i_code != '') ")
 				   .append(" Order by i_code ");
 				//System.err.println("TYPE :' XSTD01 DDL - SQL :"+sql.toString());
 				pstmt = conn.prepareStatement(sql.toString());
 				rs = pstmt.executeQuery();	
 				if(rs.next()){	
					typeName = doString.checkString(rs.getString("n_desc"),"");
 				}
 				rs.close();				
 				//********************************************************/
 			  	//System.out.println("##ListTypeName ->end.");				  	 
 			  	return typeName;			  	 
 			}catch(Exception e){
 				System.err.println("!!!GetTypeName , " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.err.println(" SQL Exception: "+sql.toString());		
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
 		/*************************************
 		 * ListProjectResposible
 		 * @param conn
 		 * @param userId
 		 * @return
 		 *************************************/
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
					strList.add(0, "AA:999");
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
 				//System.err.println("====>ListProjectResposible SQL :"+sql.toString());
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
 				System.err.println("LIST_PROJECT_RESPOSIBLE , " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.err.println(" SQL Exception: "+sql.toString());		
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

	//String itemSub=Y,N
 	   private int IntCountRowReportDetails(Connection conn, String typeDDL,String fDate, String tDate, String transMonth,
 			   String param1,String param2,boolean isProjectALL,String tempTableName3,String itemSub,String grandTotal) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			int totalRow=0; 
	        try{
	        	//initial paramter	
				/******************************************************/
	        	//System.out.println(("Type report :"+typeDDL);
		        sql.delete(0,sql.length());	    	
		        sql.append(" Select count(a.i_svc_docno) as totalRow ");
		    	 	
		        if(isProjectALL){
	        		  //Case : All project
		        	sql.append(" From lan:svc_dochd a,lan:svc_docdt b,lan:svc_xstd c,lan:acscontr d ")
 	 	        	    .append(" Where a.i_svc_docno = b.i_svc_docno ");
	        	  }else{
	        		 //Case : by project
	        		 sql.append(" From lan:svc_dochd a,lan:svc_docdt b,lan:svc_xstd c,lan:acscontr d ,"+tempTableName3+" x  ") //tbtDataName = 'tblByProjectX1'
	  	 	        	.append(" Where a.i_svc_docno = b.i_svc_docno ")
	  	 	        	.append(" and a.i_company = x.com_id ")
	  	 	        	.append(" and a.i_project = x.proj_id ");
	        	  }
		        sql.append(" and date(a.d_keyin) between '"+fDate+"' and  '"+tDate+"' ");   
		    	if(Constant_Y.equals(itemSub)){ //PageForm Sub Items List 
		    		 //System.out.println(("============Case Items SUB =============");
		    		 if(Constant_type.equalsIgnoreCase(typeDDL)){// type Of Repairing
			    		 if(Constant_99.equals(grandTotal)){ //Interest item Mian Only && From Date ,To Date
			        	     sql.append(" and b.i_itmno = '"+param1+"'  "); //itmno
			    		 }else if(Constant_row.equals(grandTotal)){//Interest item Main && Column TransFer
			    			 //System.out.println(("Get SQL Where : Constant_row1 "+GetConditionSQL(transMonth));		       
						     sql.append(GetConditionSQL(transMonth));
			    			 sql.append(" and b.i_itmno = '"+param1+"'  "); //itmno
			    		 }else if(Constant_col.equals(grandTotal)){//Interest item Main && Items Sub && From Date ,To Date
			        	    sql.append(" and b.i_itmno = '"+param1+"'  ") //itmno
		 	 	        	   .append(" and b.i_itmsub = '"+param2+"'   "); //itmsub
			    		 }else{
			    			 //System.out.println(("Get SQL Where : Constant_row2 "+GetConditionSQL(transMonth));		       
						     sql.append(GetConditionSQL(transMonth));
			        	     sql.append(" and b.i_itmno = '"+param1+"'  ") //itmno
		 	 	        	    .append(" and b.i_itmsub = '"+param2+"'   "); //itmsub
			    		 } 
		    		 }
		    		 
		    		 /*else if(Constant_agent.equalsIgnoreCase(typeDDL)){
		    			 sql.append(" and a.i_employ = '"+param1+"' ");
		    		 }else if(Constant_project.equalsIgnoreCase(typeDDL)){
						 sql.append(" and a.i_company = '"+param1+"' ")
							.append(" and a.i_project = '"+param2+"' ");
		    		 }*/
		    		 //System.out.println(("Get SQL Items Sub : Constant_ROW X :"+sql.toString());
		    	}else{
		    		//System.out.println(("============Case Items MAIN =============");
		    		 if(!Constant_99.equals(grandTotal)){
					      if(!Constant_col.equals(grandTotal)){
						     //System.out.println(("Get SQL Where : Constant_col "+GetConditionSQL(transMonth));		       
						     sql.append(GetConditionSQL(transMonth));
					      }  
					 }
		    		if(!Constant_99.equals(grandTotal)){ 
				    	   if(!Constant_row.equals(grandTotal)){///row==row? true
					           if(Constant_type.equalsIgnoreCase(typeDDL)){
					        	    	sql.append(" and b.i_itmno = '"+param1+"' ");
								}else if(Constant_agent.equalsIgnoreCase(typeDDL)){
									sql.append(" and a.i_employ = '"+param1+"' ");
								}else if(Constant_project.equalsIgnoreCase(typeDDL)){
									sql.append(" and a.i_company = '"+param1+"' ")
									   .append(" and a.i_project = '"+param2+"' ");
								}	
				    		   //System.out.println(("Get SQL Items Main : Constant_ROW :"+sql.toString());
				    	   }//Constant_row
				     }//Constant_99	
		    		//System.out.println(("============END Case Items MAIN =============");
		    	}
		    	sql.append(" and a.i_company = d.i_company  ")
		    	   .append(" and a.i_project = d.i_project  ")
		    	   .append(" and a.i_project !='075'    ")
		    	   .append(" and a.i_lock = d.i_sort    ")
		    	   .append(" and d.f_contr is null     ")
		    	   .append(" and (	")
		    	   .append(" (b.i_itmno = c.i_type  and b.i_itmsub = c.i_code and b.i_itmsub is not null)  ")
		    	   .append(" or (b.i_itmno = c.i_type  and c.i_code is null and b.i_itmsub is  null) 		")
		    	   .append(" or (b.i_itmno = c.i_type  and c.i_code is null and b.i_itmsub = '' ) 		")
		    	   .append(" )  "); 		    	

		    	System.out.println("Count ROW : "+sql.toString());
		    	pstmt = conn.prepareStatement(sql.toString()); 

				rs = pstmt.executeQuery();	
				if(rs.next()){				
					totalRow = rs.getInt("totalRow");
				}
				rs.close();				
				//********************************************************/
			  	//System.out.println("##IntCountRowByType->End.");				  	 
			  	return totalRow;			  	 
			}catch(Exception e){
				System.out.println("!!!IntCountRowReportDetails , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
		
		//and a.i_employ = '2426-7' // Agent
		//.append(" and b.i_itmno = '"+itmNo+"' ")	//type repair
		// and a.i_company = ? 
		// and a.i_project = ? "
		private List ListReportDetails(Connection conn,String typeDDL, String fDate, String tDate, String transMonth,
				String param1,String param2,boolean isProjectALL,String tempTableName3,String itemSub,String grandTotal,int startRow,int endRow,int maxRow,boolean isExport) {
 			StringBuffer sql = new StringBuffer();	
 			PreparedStatement pstmt = null;
 			ResultSet rs = null;
 	        try{
 	        	//initial paramter	     	
 				/*************************************************/	
 	        	List listResult = new ArrayList();
 	       	 	List strList = null;		
 	       	 	//System.out.println(("Type report :"+typeDDL);

 	        	//*****Find project by user login  
 				sql.delete(0,sql.length());   
 				if(isExport){
 			        sql.append(" Select  a.i_svc_docno,a.d_keyin,a.i_tel_ctasia,a.i_company,a.i_project,a.i_lock,a.i_house,a.n_customer,a.i_agent,a.i_employ,d.d_close_law ")
		        	.append(" ,b.d_appoint,b.i_itmno,b.i_itmsub,b.i_docno,c.n_desc,b.c_detail ");
			         if(isProjectALL){ //Case : All project
			        	sql.append(" From lan:svc_dochd a,lan:svc_docdt b,lan:svc_xstd c,lan:acscontr d ")
		 	        	    .append(" Where a.i_svc_docno = b.i_svc_docno ");
		        	  }else{//Case : by project
		        		 sql.append(" From lan:svc_dochd a,lan:svc_docdt b,lan:svc_xstd c,lan:acscontr d ,"+tempTableName3+" x  ") //tbtDataName = 'tblByProjectX1'
		  	 	        	.append(" Where a.i_svc_docno = b.i_svc_docno ")
		  	 	        	.append(" and a.i_company = x.com_id ")
		  	 	        	.append(" and a.i_project = x.proj_id ");
		        	  }	    	 	
		    	  sql.append(" and date(a.d_keyin) between '"+fDate+"' and  '"+tDate+"' ");						
 				}else{
 			        sql.append(" Select  first ").append(endRow).append("  a.i_svc_docno,a.d_keyin,a.i_tel_ctasia,a.i_company,a.i_project,a.i_lock,a.i_house,a.n_customer,a.i_agent,a.i_employ, d.d_close_law ")
		        	.append(" ,b.d_appoint,b.i_itmno,b.i_itmsub,b.i_docno,c.n_desc,b.c_detail ");
			         if(isProjectALL){ //Case : All project
			        	sql.append(" From lan:svc_dochd a,lan:svc_docdt b,lan:svc_xstd c,lan:acscontr d ")
		 	        	    .append(" Where a.i_svc_docno = b.i_svc_docno ");
		        	  }else{//Case : by project
		        		 sql.append(" From lan:svc_dochd a,lan:svc_docdt b,lan:svc_xstd c,lan:acscontr d ,"+tempTableName3+" x  ") //tbtDataName = 'tblByProjectX1'
		  	 	        	.append(" Where a.i_svc_docno = b.i_svc_docno ")
		  	 	        	.append(" and a.i_company = x.com_id ")
		  	 	        	.append(" and a.i_project = x.proj_id ");
		        	  }	    	 	
		    	      sql.append(" and date(a.d_keyin) between '"+fDate+"' and  '"+tDate+"' ");						
 				}

		    	if(Constant_Y.equals(itemSub)){ //PageForm Sub Items List 
		    		 //System.out.println(("============Case Items SUB =============");
		    		 if(Constant_type.equalsIgnoreCase(typeDDL)){// type Of Repairing
			    		 if(Constant_99.equals(grandTotal)){ //Interest item Mian Only && From Date ,To Date
			        	     sql.append(" and b.i_itmno = '"+param1+"'  "); //itmno
			    		 }else if(Constant_row.equals(grandTotal)){//Interest item Main && Column TransFer
			    			 //System.out.println(("Get SQL Where : Constant_row1 "+GetConditionSQL(transMonth));		       
						     sql.append(GetConditionSQL(transMonth));
			    			 sql.append(" and b.i_itmno = '"+param1+"'  "); //itmno
			    		 }else if(Constant_col.equals(grandTotal)){//Interest item Main && Items Sub && From Date ,To Date
			        	    sql.append(" and b.i_itmno = '"+param1+"'  ") //itmno
		 	 	        	   .append(" and b.i_itmsub = '"+param2+"'   "); //itmsub
			    		 }else{
			    			 //System.out.println(("Get SQL Where : Constant_row2 "+GetConditionSQL(transMonth));		       
						     sql.append(GetConditionSQL(transMonth));
			        	     sql.append(" and b.i_itmno = '"+param1+"'  ") //itmno
		 	 	        	    .append(" and b.i_itmsub = '"+param2+"'   "); //itmsub
			    		 } 
		    		 }	    		 
		    		 //System.out.println("Get SQL Items Sub : Constant_ROW X :"+sql.toString());
		    	}else{
		    		//System.out.println(("============Case Items MAIN =============");
		    		 if(!Constant_99.equals(grandTotal)){
					      if(!Constant_col.equals(grandTotal)){
						     //System.out.println(("Get SQL Where : Constant_col "+GetConditionSQL(transMonth));		       
						     sql.append(GetConditionSQL(transMonth));
					      }  
					 }
		    		if(!Constant_99.equals(grandTotal)){ 
				    	   if(!Constant_row.equals(grandTotal)){///row==row? true
					           if(Constant_type.equalsIgnoreCase(typeDDL)){
					        	    	sql.append(" and b.i_itmno = '"+param1+"' ");
								}else if(Constant_agent.equalsIgnoreCase(typeDDL)){
									sql.append(" and a.i_employ = '"+param1+"' ");
								}else if(Constant_project.equalsIgnoreCase(typeDDL)){
									sql.append(" and a.i_company = '"+param1+"' ")
									   .append(" and a.i_project = '"+param2+"' ");
								}	
				    		   //System.out.println(("Get SQL Items Main : Constant_ROW :"+sql.toString());
				    	   }//Constant_row
				     }//Constant_99	
		    		//System.out.println("============END Case Items MAIN =============");
		    	}
		    	sql.append(" and a.i_company = d.i_company  ")
		    	   .append(" and a.i_project = d.i_project  ")
		    	   .append(" and a.i_project !='075'    ")
		    	   .append(" and a.i_lock = d.i_sort    ")
		    	   .append(" and d.f_contr is null     ")
		    	   .append(" and (	")
		    	   .append(" (b.i_itmno = c.i_type  and b.i_itmsub = c.i_code and b.i_itmsub is not null)  ")
		    	   .append(" or (b.i_itmno = c.i_type  and c.i_code is null and b.i_itmsub is  null) ")
		    	   .append(" or (b.i_itmno = c.i_type  and c.i_code is null and b.i_itmsub = '' ) ")
		    	   .append(" ) ") 		    	
		    	   .append(" Order by a.d_keyin  desc  "); // a.i_company,a.i_project,a.i_svc_docno,b.i_itmno,b.i_itmsub asc

 				pstmt = conn.prepareStatement(sql.toString()); 
 				//System.out.println("Fetch DataSQL xxx :"+sql.toString());
 				rs = pstmt.executeQuery();	
 				if(isExport){
 					while(rs.next()){
 							strList =  new ArrayList(); 
							strList.add(0,  doString.checkString(rs.getString("i_svc_docno"),""));
							strList.add(1,  doString.checkString(rs.getString("i_tel_ctasia"),""));
							strList.add(2,  doString.checkString(rs.getString("i_company"),""));
							strList.add(3,  doString.checkString(rs.getString("i_project"),""));
							strList.add(4,  this.GetProjectName(conn, doString.checkString(rs.getString("i_company"),""),doString.checkString(rs.getString("i_project"),"")));					
							strList.add(5,  doString.checkString(rs.getString("i_lock"),""));
							strList.add(6,  doString.checkString(rs.getString("i_house"),""));
							strList.add(7,  doString.checkString(rs.getString("n_customer"),""));
							strList.add(8,  doString.checkString(rs.getString("i_agent"),""));
							strList.add(9,  doString.checkString(rs.getString("i_employ"),""));
							strList.add(10,  this.GetNameEmploy(conn,doString.checkString(rs.getString("i_employ"),"")));
							strList.add(11,  doString.checkString(rs.getString("d_appoint"),""));
							strList.add(12,  doString.checkString(rs.getString("i_itmno"),""));
							strList.add(13,  doString.checkString(rs.getString("i_itmsub"),""));
							strList.add(14,  doString.checkString(rs.getString("i_docno"),""));//n_desc for itm_sub
							strList.add(15,  doString.checkString(rs.getString("n_desc"),""));
							strList.add(16, doString.checkString(GetTypeName(conn,doString.checkString(rs.getString("i_itmno"),"")), ""));//n_desc for itm_main
							strList.add(17,  doString.checkString(rs.getString("d_keyin"),""));
							strList.add(18,  doString.checkString(rs.getString("c_detail"),""));
							strList.add(19,  doString.checkString(rs.getString("d_close_law"),""));
							listResult.add(strList);
 					}
 				}else{
 	 				for (int i=0;i<maxRow;i++) { 
 		                if (rs.next()) {
 		                   if (i>=startRow && i<=endRow) {	
 			 					strList =  new ArrayList(); 
 								strList.add(0,  doString.checkString(rs.getString("i_svc_docno"),""));
 								strList.add(1,  doString.checkString(rs.getString("i_tel_ctasia"),""));
 								strList.add(2,  doString.checkString(rs.getString("i_company"),""));
 								strList.add(3,  doString.checkString(rs.getString("i_project"),""));
 								strList.add(4,  this.GetProjectName(conn, doString.checkString(rs.getString("i_company"),""),doString.checkString(rs.getString("i_project"),"")));					
 								strList.add(5,  doString.checkString(rs.getString("i_lock"),""));
 								strList.add(6,  doString.checkString(rs.getString("i_house"),""));
 								strList.add(7,  doString.checkString(rs.getString("n_customer"),""));
 								strList.add(8,  doString.checkString(rs.getString("i_agent"),""));
 								strList.add(9,  doString.checkString(rs.getString("i_employ"),""));
 								strList.add(10,  this.GetNameEmploy(conn,doString.checkString(rs.getString("i_employ"),"")));
 								strList.add(11,  doString.checkString(rs.getString("d_appoint"),""));
 								strList.add(12,  doString.checkString(rs.getString("i_itmno"),""));
 								strList.add(13,  doString.checkString(rs.getString("i_itmsub"),""));
 								strList.add(14,  doString.checkString(rs.getString("i_docno"),""));//n_desc for itm_sub
 								strList.add(15,  doString.checkString(rs.getString("n_desc"),""));
 								strList.add(16, doString.checkString(GetTypeName(conn,doString.checkString(rs.getString("i_itmno"),"")), ""));//n_desc for itm_main
 								strList.add(17,  doString.checkString(rs.getString("d_keyin"),""));
 								strList.add(18,  doString.checkString(rs.getString("c_detail"),""));
 								strList.add(19,  doString.checkString(rs.getString("d_close_law"),""));
 								
 								listResult.add(strList);
 		                   } //--end if check row
 			               if (i>endRow){ 
 			              	 break;
 			               }
 		                } //end if check rs
 			        } // end for 					
 				}
 				
 				rs.close();	
 				//**************************************************/
 			  	//System.out.println("##ListReportDetails ->successfully.");				  	 
 			  	return listResult;			  	 
 			}catch(Exception e){
 				System.err.println("!!!ListReportDetails , " +sysName+":"+ clazzName + " : " + e.getMessage());
 				System.err.println(" SQL Exception: "+sql.toString());		
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
		
		private String GetNameEmploy(Connection conn, String employId) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			String  emmployName = "";
	        try{
	        	//initial paramter	     	
				/*************************************************/			
	        	//*****Find project by user login  
				sql.delete(0,sql.length());
				sql.append("Select n_prename_th,n_nemploy_th,n_semploy_th From docflow:acemploy Where i_employ = ? ");
				pstmt = conn.prepareStatement(sql.toString()); 
				pstmt.setString(1, employId);	
				//System.out.println("SQL :"+sql.toString());
				rs = pstmt.executeQuery();	
				if(rs.next()){
					emmployName = doString.checkString(rs.getString("n_prename_th"), "")+" "+
					doString.checkString(rs.getString("n_nemploy_th"), "")+"  "+doString.checkString(rs.getString("n_semploy_th"), "");
				}
				rs.close();	
		   			
				//**************************************************/
			  	//System.out.println("##GetNameEmployAssign ->successfully.");				  	 
			  	return emmployName;			  	 
			}catch(Exception e){
				System.out.println("!!!GetNameEmploy , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
 		
		 private  HSSFWorkbook GenExcelPaper(List excelData,String typeDDL,String fromDate,String toDate,String typeName
				 ,String grandTotal,String transMonth,String multiFlag,List projSelectdList) throws Exception{		
	            HSSFWorkbook wb = new HSSFWorkbook();
	            HSSFSheet sheet = wb.createSheet("New Sheet");
	            HSSFRow row = null;
	            HSSFCell cell = null;
	            HSSFCellStyle align_head = wb.createCellStyle();
	            HSSFCellStyle align_center = wb.createCellStyle();
	            HSSFCellStyle align_right = wb.createCellStyle();
	            HSSFCellStyle align_left = wb.createCellStyle();
	            HSSFCellStyle align_left2 = wb.createCellStyle();
	            HSSFCellStyle align_right2 = wb.createCellStyle();
	            
	           // HSSFCellStyle alignCenter1 = wb.createCellStyle();
	            HSSFCellStyle alignCenter2 = wb.createCellStyle();
	            
	            //-----------------------------
	           // alignCenter1.setAlignment(HSSFCellStyle.ALIGN_CENTER);
	            alignCenter2.setAlignment(HSSFCellStyle.ALIGN_CENTER);
	            
	            align_head.setAlignment(HSSFCellStyle.ALIGN_CENTER);
	            align_center.setAlignment(HSSFCellStyle.ALIGN_CENTER);
	            align_right.setAlignment(HSSFCellStyle.ALIGN_RIGHT);
	            align_left2.setAlignment(HSSFCellStyle.ALIGN_LEFT);
	            
	            /******************/ 
	            /*#set color & border to "align_head"
	             * ****************/ 
	            alignCenter2.setFillForegroundColor(HSSFColor.AQUA.index);
	            alignCenter2.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
	            alignCenter2.setBorderBottom(HSSFCellStyle.BORDER_THIN);
	            alignCenter2.setBottomBorderColor(HSSFColor.BLACK.index);
	            alignCenter2.setBorderLeft(HSSFCellStyle.BORDER_THIN);
	            alignCenter2.setLeftBorderColor(HSSFColor.BLACK.index);
	            alignCenter2.setBorderRight(HSSFCellStyle.BORDER_THIN);
	            alignCenter2.setRightBorderColor(HSSFColor.BLACK.index);
	            alignCenter2.setBorderTop(HSSFCellStyle.BORDER_MEDIUM_DASHED);
	            alignCenter2.setTopBorderColor(HSSFColor.BLACK.index);

	            /******************/ 
	            /*#set color & border to "align_head"
	             * ****************/ 
	            align_head.setFillForegroundColor(HSSFColor.GREY_25_PERCENT.index);
	            align_head.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
	            align_head.setBorderBottom(HSSFCellStyle.BORDER_THIN);
	            align_head.setBottomBorderColor(HSSFColor.BLACK.index);
	            align_head.setBorderLeft(HSSFCellStyle.BORDER_THIN);
	            align_head.setLeftBorderColor(HSSFColor.BLACK.index);
	            align_head.setBorderRight(HSSFCellStyle.BORDER_THIN);
	            align_head.setRightBorderColor(HSSFColor.BLACK.index);
	            align_head.setBorderTop(HSSFCellStyle.BORDER_MEDIUM_DASHED);
	            align_head.setTopBorderColor(HSSFColor.BLACK.index);
	         
	            
	            /******************/ 
	            /*#set color & border to  align_right
	             * ****************/ 
	            align_right.setFillForegroundColor(HSSFColor.GREY_25_PERCENT.index);
	            align_right.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
	            align_right.setBorderBottom(HSSFCellStyle.BORDER_THIN);
	            align_right.setBottomBorderColor(HSSFColor.BLACK.index);
	            align_right.setBorderLeft(HSSFCellStyle.BORDER_THIN);
	            align_right.setLeftBorderColor(HSSFColor.BLACK.index);
	            //align_right.setBorderRight(HSSFCellStyle.BORDER_THIN);
	            //align_right.setRightBorderColor(HSSFColor.BLACK.index);
	            align_right.setBorderTop(HSSFCellStyle.BORDER_MEDIUM_DASHED);

	            align_right.setTopBorderColor(HSSFColor.BLACK.index);
	            /******************/ 
	            /*#set color & border to  align_left
	             * ****************/ 
	            
	            align_left.setFillForegroundColor(HSSFColor.GREY_25_PERCENT.index);
	            align_left.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
	            align_left.setBorderBottom(HSSFCellStyle.BORDER_THIN);
	            align_left.setBottomBorderColor(HSSFColor.BLACK.index);
	            //align_left.setBorderLeft(HSSFCellStyle.BORDER_THIN);
	            //align_left.setLeftBorderColor(HSSFColor.BLACK.index);
	            align_left.setBorderRight(HSSFCellStyle.BORDER_THIN);
	            align_left.setRightBorderColor(HSSFColor.BLACK.index);
	            align_left.setBorderTop(HSSFCellStyle.BORDER_MEDIUM_DASHED);
	            align_left.setTopBorderColor(HSSFColor.BLACK.index);
	            
	            /******************/ 
	            /*#set color & border to  align_right2
	             * ****************/ 
	            align_right2.setAlignment(HSSFCellStyle.ALIGN_RIGHT);
	           
	            /******************/ 
	            /*#set width to column in sheet
	             * ****************/
	            int i = 0;
	            sheet.setColumnWidth((short) i++, (short) 5000); //0
	            sheet.setColumnWidth((short) i++, (short) 12000);//1
	            sheet.setColumnWidth((short) i++, (short) 5000);//2
	            sheet.setColumnWidth((short) i++, (short) 5000);//3
	            sheet.setColumnWidth((short) i++, (short) 5000);//4
	            sheet.setColumnWidth((short) i++, (short) 5000);//5
	            sheet.setColumnWidth((short) i++, (short) 12000);//6
	            sheet.setColumnWidth((short) i++,(short)  12000);//7
	            sheet.setColumnWidth((short) i++, (short) 5000);//8
	            sheet.setColumnWidth((short) i++, (short) 5000);//9
	            sheet.setColumnWidth((short) i++, (short) 5000);//10
	            sheet.setColumnWidth((short) i++, (short) 5000);//11
	            sheet.setColumnWidth((short) i++, (short) 5000);//12
	            sheet.setColumnWidth((short) i++, (short) 25000);//13
	            sheet.setColumnWidth((short) i++, (short) 25000);//14
	            /******************/ 
	            /*#  Header
	             *# Create a row and put some cells in it. Rows are 0 based.
	             * ****************/ 
	           
	            /**111 **/
	            row = sheet.createRow((short) 0);
	            row.setHeight((short) 300);
	        
	            cell = row.createCell((short) 0);
	            cell.setCellStyle(align_left2);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellValue("ประเภทรายงาน");
	           
	            String msgType = "";
	            if("type".equalsIgnoreCase(typeDDL)){
	            	msgType = "ประเภทการแจ้งซ่อม";
				}else if("agent".equalsIgnoreCase(typeDDL)){
					msgType = "ตาม Agent";
				}else if("project".equalsIgnoreCase(typeDDL)){
					msgType = "ตามโครงการ";	
				}
	            cell = row.createCell((short) 1);
	            cell.setCellStyle(align_left2);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellValue(msgType);//เบอร์โทร
	            
	            /**2222 **/
	            String []arrFromThaiDate = fromDate.split("\\/");
	            String []arrToThaiDate = toDate.split("\\/");//22/09/2558
	            String tempDate = arrFromThaiDate[0]+" "+thaiMonth[Integer.parseInt(arrFromThaiDate[1])]+" พ.ศ. "+arrFromThaiDate[2]+"   ถึง "
	            +arrToThaiDate[0] +" "+thaiMonth[Integer.parseInt(arrToThaiDate[1])]+" พ.ศ. "+arrToThaiDate[2];            
	            
	            
	            row = sheet.createRow((short) 1);
	            row.setHeight((short) 300);
	            
	            cell = row.createCell((short) 0);
	            cell.setCellStyle(align_left2);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellValue("ระหว่างวันที่");
	            
	            cell = row.createCell((short) 1);
	            cell.setCellStyle(align_left2);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellValue(tempDate);
	            
	            /**3333 **/
	            row = sheet.createRow((short) 2);
	            row.setHeight((short) 300);
	            
	            cell = row.createCell((short) 0);
	            cell.setCellStyle(align_left2);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellValue("ตามประเภท");
	            
	            cell = row.createCell((short) 1);
	            cell.setCellStyle(align_left2);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellValue(doString.DisplayThai(typeName.trim()));
	            
	            /**44444 **/
	            String tempTrans = "-";
	            if(!"col".equals(grandTotal) && !"99".equals(grandTotal)){
	            	tempTrans = COLUMN_HD1[Integer.parseInt(transMonth)] +"  ( "+COLUMN_COUNT_DATE[Integer.parseInt(transMonth)]+" วัน)";
	            }
	            row = sheet.createRow((short) 3);
	            row.setHeight((short) 300);
	            
	            cell = row.createCell((short) 0);
	            cell.setCellStyle(align_left2);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellValue("ตามช่วงโอน");
	            
	            cell = row.createCell((short) 1);
	            cell.setCellStyle(align_left2);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellValue(tempTrans);
	            
	            /**55555 **/
	            row = sheet.createRow((short) 4);
	            row.setHeight((short) 300);
	            
	            cell = row.createCell((short) 0);
	            cell.setCellStyle(align_left2);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellValue("โครงการ");
	       	 	
	            String projectSelection = "";
		       	if(multiFlag.equals("0")){
		       	 	 projectSelection = "เลือกทุกโครงการ ";
		         }else{
		               if(!"project".equalsIgnoreCase(typeDDL)){
		    			 if(projSelectdList!=null && projSelectdList.size()>0){		
		    				ArrayList strList = null;	
		    				String tempNameProject = "";
		    				//String tempProjectId = "";	
		    				int line = 0;
		    				 //-----------------------			 
		    				Iterator it = projSelectdList.iterator();								   							   
		    				while(it.hasNext()){									
		    					strList =(ArrayList)it.next();
		    					tempNameProject = "";		
		    					//tempProjectId = "";									
		    					//tempProjectId = doString.checkString(strList.get(0).toString());//LH:075
		    					tempNameProject =doString.checkString(strList.get(2).toString());
		    					projectSelection +=doString.checkString(strList.get(0).toString())+"-"+doString.checkString(strList.get(1).toString())+" "+tempNameProject+",";
		    				}//#end while
		    	       }//#End if check null
		    	   }//End check All project
		    	   else{
		    		   projectSelection = "";
		    	   }
		      }//Else            
	
	            cell = row.createCell((short) 1);
	            cell.setCellStyle(align_left2);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellValue(projectSelection);
	            
	            
	            /******************/ 
	            /*# Create a cell and put a value in it.
	             * ****************/
	            row = sheet.createRow((short)5);
	            row.setHeight((short) 400);         
	            
	            cell = row.createCell((short) 0);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellStyle(align_head);
	            cell.setCellValue("เลขที่เอกสาร  ");
	            
	            cell = row.createCell((short) 1);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellStyle(align_head);
	            cell.setCellValue("เบอร์โทร ");
	            
	            cell = row.createCell((short) 2);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellStyle(align_head);
	            cell.setCellValue("รหัสโครงการ");

	            cell = row.createCell((short) 3);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellStyle(align_head);
	            cell.setCellValue(" ชื่อโครงการ");
	            
	            cell = row.createCell((short) 4);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellStyle(align_head);
	            cell.setCellValue(" เเปลง ");


	            cell = row.createCell((short) 5);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellStyle(align_head);
	            cell.setCellValue(" บ้านเลขที่ ");


	            cell = row.createCell((short)6 );
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellStyle(align_head);
	            cell.setCellValue("ชื่อลูกค้า ");
	            
	            cell = row.createCell((short) 7);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellStyle(align_head);
	            cell.setCellValue("ชื่อ Agent ");

	            cell = row.createCell((short) 8);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellStyle(align_head);
	            cell.setCellValue("วันรับเรื่อง");
	            
	            cell = row.createCell((short) 9);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellStyle(align_head);
	            cell.setCellValue("รหัส/หมวดหลัก ");

	            cell = row.createCell((short) 10);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellStyle(align_head);
	            cell.setCellValue("รหัส/หมวดย่อย  ");

	            cell = row.createCell((short) 11);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellStyle(align_head);
	            cell.setCellValue("วันนัดหมาย ");

	            cell = row.createCell((short) 12);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellStyle(align_head);
	            cell.setCellValue("เลขที่ใบแจ้งซ่อม  ");
	            
	            cell = row.createCell((short) 13);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellStyle(align_head);
	            cell.setCellValue("รายละเอียด");

	            
	            cell = row.createCell((short) 14);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellStyle(align_head);
	            cell.setCellValue("วันที่โอน");
	               
	            //***********************
	            if(excelData !=null && excelData.size()>0){
	    			//int x = 1;
	    			i=6;
	    			//String bgColor = "";
	    			ArrayList recList = null;					 
	    			Iterator it = excelData.iterator();								   							   
	    			while(it.hasNext()){								
	    				recList =(ArrayList)it.next();	

	    				//****************************
	    				//Generate Excel Row
	            		 row = sheet.createRow((short) i++);
	             	 	 row.setHeight((short) 300);
 
	    				 cell = row.createCell((short) 0);
	    	             cell.setCellStyle(align_left2);
	    	             cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	    	             cell.setCellValue(recList.get(0).toString());//เลขที่เอกสาร

	    	             cell = row.createCell((short) 1);
	    	             cell.setCellStyle(align_left2);
	    	             cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	    	             cell.setCellValue(recList.get(1).toString());//เบอร์โทร

	    	             cell = row.createCell((short) 2);
	    	             cell.setCellStyle(align_left2);
	    	             cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	    	             cell.setCellValue(recList.get(2)+"-"+doString.DisplayThai(recList.get(3).toString()));// รหัสโครงการ 

	    	             cell = row.createCell((short) 3);
	    	             cell.setCellStyle(align_left2);
	    	             cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	    	             cell.setCellValue(doString.DisplayThai(recList.get(4).toString()));// ชื่อโครงการ

	    	             cell = row.createCell((short) 4);
	    	             cell.setCellStyle(align_left2);
	    				 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	    				 cell.setCellValue(recList.get(5).toString());//เเปลง 
	    				 
	    				 
	    	             cell = row.createCell((short)5);
	    	             cell.setCellStyle(align_left2);
	    				 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	    				 cell.setCellValue(recList.get(6).toString());// บ้านเลขที่
	    				 
	    	             cell = row.createCell((short)6);
	    	             cell.setCellStyle(align_left2);
	    				 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	    				 cell.setCellValue(doString.DisplayThai(recList.get(7).toString()));// ชื่อลูกค้า
	    				 
	    				 cell = row.createCell((short) 7);
	    	             cell.setCellStyle(align_left2);
	    	             cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	    	             cell.setCellValue(doString.DisplayThai(recList.get(10).toString()));// ชื่อ Agent

	    	             cell = row.createCell((short) 8);
	    	             cell.setCellStyle(align_left2);
	    	             cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	    	             cell.setCellValue(toDDMMYY_THAI2(recList.get(17).toString()));// วันรับเรื่อง 

	    	             cell = row.createCell((short) 9);
	    	             cell.setCellStyle(align_left2);
	    	             cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	    	             cell.setCellValue(recList.get(12)+" "+doString.DisplayThai(recList.get(16).toString())); //รหัส/หมวดหลัก

	    	             cell = row.createCell((short) 10);
	    	             cell.setCellStyle(align_left2);
	    	             cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	    	             cell.setCellValue(recList.get(13)+" "+doString.DisplayThai(recList.get(15).toString()));//รหัส/หมวดย่อย

	    	             cell = row.createCell((short) 11);
	    	             cell.setCellStyle(align_left2);
	    				 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	    				 cell.setCellValue(toDDMMYY_THAI2(recList.get(11).toString()));//วันนัดหมาย
	    				 
	    				 
	    	             cell = row.createCell((short)12);
	    	             cell.setCellStyle(align_left2);
	    				 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	    				 cell.setCellValue(recList.get(14).toString());//   เลขที่ใบแจ้งซ่อม    
	    				 
	    	             cell = row.createCell((short)13);
	    	             cell.setCellStyle(align_left2);
	    				 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	    				 cell.setCellValue(doString.DisplayThai(recList.get(18).toString()));//รายละเอียด

	    	             cell = row.createCell((short)14);
	    	             cell.setCellStyle(align_left2);
	    				 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	    				 cell.setCellValue(doString.DisplayThai(toDDMMYY_THAI1(recList.get(19).toString())));
	    				 
	    				 /*
	    				 cell = row.createCell((short) 14);
	    	             cell.setCellStyle(align_right2);
	    	             cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	    	             cell.setCellValue(recList.get(14).hashCode());

	    	             cell = row.createCell((short) 15);
	    	             cell.setCellStyle(align_right2);
	    	             cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	    	             cell.setCellValue(recList.get(15).hashCode());

	    	             cell = row.createCell((short) 16);
	    	             cell.setCellStyle(align_right2);
	    	             cell.setEncoding(HSSFCell.ENCODING_UTF_16);//
	    	             cell.setCellValue(recList.get(16).hashCode()); */

	    				 //x++;
	    			}
	            }
	            //***********************
	            return wb;
	    	}

		private static  String GetConditionSQL(String param){ //param = 1,2,3..N
            String sql = "";
            int tempCDate = 0;
	        if(!param.equals("") && param !=null){
	        	tempCDate = Integer.parseInt(param);
	        }
			if(tempCDate==1){//90
				sql= " AND date(a.d_keyin) - d.d_close_law <= "+COLUMN_COUNT_DATE[Integer.parseInt(param)];//90
			}else if(tempCDate==15){
				sql= " AND date(a.d_keyin) - d.d_close_law > "+COLUMN_COUNT_DATE[Integer.parseInt(param)]; //3600
			}else{
				sql= " AND date(a.d_keyin) - d.d_close_law > "+COLUMN_COUNT_DATE[Integer.parseInt(param)-1]+
				     " AND date(a.d_keyin) - d.d_close_law <= "+COLUMN_COUNT_DATE[Integer.parseInt(param)];
			    //and date(a.d_keyin) - d.d_close_law > 180
			    //and date(a.d_keyin) - d.d_close_law <= 270
			} 
			return sql;
		}
 		//	output : 20131021
 		private static  String ThaiToEngDate(String param){ 
 			if ((param == null) || param.equals("")) {
 				//TODO: Case : null
				Date date = Calendar.getInstance().getTime();
				DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
				return formatter.format(date); //2015-09-07
 			}else{
 				//TODO:Not null
 				String d[] = param.split("\\/");//20/10/2558
 				String yymmdd = (Integer.parseInt(d[2])-543)+"-"+d[1]+"-"+d[0];
 				//System.err.println("--------->Date yyyy-MM-dd :"+yymmdd);
 				return yymmdd;
 			}
 		}

 		public static  String toDDMMYY_THAI2(String str){
 			if ((str == null) || str.equals("")) {
 				 return  str;
 			}else{
 			     String x = str.substring(0,10);
 				 String d2[] = x.split("\\-"); //2013-03-29
 				 return d2[2]+"/"+d2[1]+"/"+(Integer.parseInt(d2[0])+543)+" "+str.substring(10,16)+" น.";
 			}
 		}
		/*****************************
		 * Method get Link next page url
		 * @param tmpMax
		 * @param nowPage
		 * @param displayLine
		 * @return
		 * @throws Exception
		 */
		public static String genLinkNextPageHTML(int tmpMax,int nowPage,int displayLine)throws Exception {
			String pageLink = "";
			int tmpPage = 0;
			////System.out.println("tmpMax :"+tmpMax);
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
		
		private static  String toDDMMYY_THAI1(String str){
			if ((str == null) || str.equals("")) {
				 return  str;
			}else{
			     String x = str.substring(0,10);
				 String d2[] = x.split("\\-"); //2013-03-29
				 return d2[2]+"/"+d2[1]+"/"+(Integer.parseInt(d2[0])+543);
			}
		}

		
}