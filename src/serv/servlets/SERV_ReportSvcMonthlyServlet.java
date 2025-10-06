package serv.servlets;
import java.io.ByteArrayOutputStream;
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
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.util.HSSFColor;

import serv.common.User;
import com.lh.servlet.DBServlet;
import com.lh.string.doString;

/*********************************************
 * create by : pradoem wonkraso
 * date time: 2015.08.09
 * Last modify :
 * version :1.0
 * project Name : Report SVC 
 * description :  Report สรุป Call Service Center แยกตาม เดือน 1-12 เดือน
***************************************************/

/**
 * Servlet implementation class for Servlet: SERV_ReportSvcMonthlyServlet
 *
 */
 public class SERV_ReportSvcMonthlyServlet extends  DBServlet{

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
		public SERV_ReportSvcMonthlyServlet() {
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
				  }else if(command.equals("Expand")){
 					 this.doExpandReportForm(request,response,user);
 				  }else if(command.equals("Desc")){
 					 this.doDetailsReport(request, response, user);
 				  }
			}catch(Exception e){
				e.printStackTrace();
				System.err.println(sysName+":"+clazzName +" "+e.toString());		
			}
			finally{
				//out.close();
			}
		}
		
	
		//******Report dynamic receive paramteter from Form critirai 
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
 	        	//printOutParam(request,"doDetailsReport");
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
 	  			String Month = doString.checkString(request.getParameter("Month"),"");//1,2,3,....N
 	  			String yyDDL = doString.checkString(request.getParameter("yyDDL"),""); //2015
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
	   	  				if(!"".equalsIgnoreCase(typeDDL)){
	   	  				    listSelProject = ListSelectedProjectName(conn, tempTableName);
	   	  				}
	 	  			}
	 	  		}
	 			//System.err.println("-------------------GenReport OK-------------------------------");	 
 			  	
		  		//---------------------------------------------------------------------//
				int displayLine = Integer.parseInt(doString.checkString(request.getParameter("pageNoDDL"),"50"));				
				//***************Get Row from db
		        int maxRow = 0;
		        if(multiFlag.equals(Constant_All_0)){// all
		        	maxRow = this.IntCountRowReportDetails(conn,typeDDL,yyDDL,Month,param1,param2,true,tempTableName,itemSub,grandTotal);
		        }else{ // by project
		        	maxRow = this.IntCountRowReportDetails(conn,typeDDL,yyDDL,Month,param1,param2,false,tempTableName,itemSub,grandTotal);
		        }
		        //---------------- Generate Display Customize and Page Link -------------------------//
		        int nowPage = Integer.parseInt(doString.checkString(request.getParameter("nowPage"),"1"));
		        int startRow = ((nowPage-1)*displayLine);
		        int endRow = startRow+displayLine;       	   
		        String pageLink = "";
		        int tmpMax = maxRow;
		        pageLink = this.genLinkNextPageHTML(tmpMax, nowPage, displayLine);
		
				ArrayList pageNoDDL = new ArrayList();
				int intVal = 50;
				for(int i=0;i<5;i++){
					pageNoDDL.add(0,intVal); 
					intVal +=50;
				}
		        //------------------------------------------------------------------//s	 
				boolean isExport = false;
				if(export2Excel.equalsIgnoreCase("Y")){
					isExport = true;
				}
				 if(multiFlag.equals(Constant_All_0)){// all
					arrReportObj = this.ListReportDetails(conn, typeDDL,yyDDL, Month, param1, param2,true,tempTableName,itemSub,grandTotal,startRow, endRow, maxRow,isExport);
				 }else{// by project
					arrReportObj = this.ListReportDetails(conn, typeDDL,yyDDL, Month, param1, param2,false,tempTableName,itemSub,grandTotal,startRow, endRow, maxRow,isExport);
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
				//typeName = GetTypeName(conn, param1);
				//System.out.println(("===================TEST ================");
				//System.out.println("===================typeName :"+typeName);

		  		 request.setAttribute("reportResultHD", arrReportObj);
		  		 request.setAttribute("projSelectdList", listSelProject);
		  		 
		  		 request.setAttribute("typeName", typeName);//item_n_desc,agent_name,projectName
		  		 // request.setAttribute("fromDate", fromDate);//05/08/2558
				 request.setAttribute("yyDDL",yyDDL);//yyDDL
				 request.setAttribute("typeDDL",typeDDL);//TYPE,PROJECT,AGENT
				 request.setAttribute("Month",Month);//1,2,3,4...N
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
				/***********************************/

				if(export2Excel.equalsIgnoreCase("Y")){
					/*********************************************/
					//Generate to Excel paper
					/*********************************************/ 	
					Date date = Calendar.getInstance().getTime();
					DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
				     String tempDate = formatter.format(date); //2015-09-07
					
					ByteArrayOutputStream baos = new ByteArrayOutputStream();
					HSSFWorkbook wb = GenExcelPaper(arrReportObj, typeDDL, Month, yyDDL, typeName, grandTotal, multiFlag, listSelProject);
				    wb.write(baos);
				    response.setContentType("application/vnd.ms-excel");
				    String fileName = "exportMonthlyDetail_"+tempDate+".xls";
				    response.setHeader("Content-disposition","inline;filename=\""+fileName+"\"");

				    response.setContentLength(baos.size());
			        ServletOutputStream out = response.getOutputStream();
			        baos.writeTo(out);
			        out.flush();
			        //--------------------------------
				}else{
		 			response.setContentType("text/html; charset=TIS-620");
					request.setAttribute("reportResultHD", arrReportObj);
	 			  	String tarGetUrl ="/SERV_ReportSvcMonthlyDetails.jsp";
	 		   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
	 				dispatcher.forward(request,response);				
				}

 				/****** Clear *******/
 				conn.close();
 				conn = null;
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
 	  			String yyDDL = doString.checkString(request.getParameter("yyDDL"),"");//2015
 	  			String reportType = doString.checkString(request.getParameter("typeDDL"),""); 
 	  			String multiFlag = doString.checkString(request.getParameter("multiFlag"),""); //0=All project,1 = by project

 	  		    List arrReportObj= new ArrayList();
 	  		    List listSelProject  = null;
 	  		    List listObj = null;
 			  	/**********************************/
 	        	String tempTableName = "tblByProjectX1";
    	  		if(multiFlag.equals("0")){//TODO: CASE : ALL Project
    	  			if("type".equalsIgnoreCase(reportType)){  
    	  				//TODO: Case Type
    	  				listObj = ListTypeRepair(conn);
    	  				arrReportObj = ListReportCaseType(conn, listObj, yyDDL, true, tempTableName);
    	  			}else if("agent".equalsIgnoreCase(reportType)){
    	  				//TODO: Case Agent
    	  				listObj = ListAgentName(conn);
       	  			 	arrReportObj = ListReportCaseAgent(conn, listObj, yyDDL, true, tempTableName);
    	  			}else if("project".equalsIgnoreCase(reportType)){ 
    	  				//TODO:Case Project
    	  				listObj = ListAllProjectName(conn, yyDDL);
    	  				arrReportObj = ListReportCaseProject(conn, listObj, yyDDL, true, tempTableName);
    	  			}
    	  		}else{
    	  			 //call crete temp table & Insert temp table
    	  			 CreateTempTableProject(conn, projSelDDL, tempTableName);
    	  			 //System.out.println("===========>Crete Table OK.....");
    	  			 listSelProject = ListSelectedProjectName(conn, tempTableName);
    	  			 
    	  			//System.out.println("===========>List Project Selected.....");
     	  			if("type".equalsIgnoreCase(reportType)){  
    	  				//TODO: Case Type
     	  				listObj = ListTypeRepair(conn);
     	  				arrReportObj = ListReportCaseType(conn, listObj, yyDDL, false, tempTableName);
    	  			}else if("agent".equalsIgnoreCase(reportType)){
    	  				//TODO: Case Agent
    	  				listObj= ListAgentName(conn);
    	  				arrReportObj = ListReportCaseAgent(conn, listObj, yyDDL, false, tempTableName);
    	  			}else if("project".equalsIgnoreCase(reportType)){ 
    	  				//TODO:Case Project
    	  				arrReportObj = ListReportCaseProject(conn, listSelProject, yyDDL, false, tempTableName);
    	  			}
    	  		}
    	  		
    	  		// DisplayMatrixArray2(arrReportObj);
    	  		
    	  		 request.setAttribute("reportResultHD", arrReportObj);
    	  		 request.setAttribute("resultSub", listObj);
    	  		 request.setAttribute("projSelectdList", listSelProject);
    	  		 request.setAttribute("yyDDL", yyDDL);//2015
 				 request.setAttribute("typeDDL",reportType);//TYPE,PROJECT,AGENT
 				 request.setAttribute("multiFlag",multiFlag);//0=ALL

 		   		//*********Dispatcher  	 
 			  	System.out.println("-------------------GenReport OK-------------------------------");	 
 			  	
 			  	String tarGetUrl ="/SERV_ReportSvcMonthlyView.jsp";
 		   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
 				dispatcher.forward(request,response);	
 				 
 				/****** Clear *******/
 				conn.close();
 				conn = null;
 			}catch(Exception e){
 				System.err.println("!!! doGenReportForm , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
 				String itmno = doString.checkString(request.getParameter("itmno"),"");
 	  			String yyDDL = doString.checkString(request.getParameter("yyDDL"),"");//2015
 	  			String reportType = doString.checkString(request.getParameter("typeDDL"),""); 
 	  			String multiFlag = doString.checkString(request.getParameter("multiFlag"),""); //0=All project,1 = by project

 	  		    List arrReportObj= new ArrayList();
 	  		    List listSelProject  = null;
 	  		    List listItmSubObj = null;
 			  	/**********************************/

 	  		    String tempTableName = "tblByProjectX2";

  				if(multiFlag.equals("0")){//TODO: CASE : ALL Project
  	 	  		    listItmSubObj = ListTypeItemSub(conn, itmno);
  	  				arrReportObj = ListReportCaseByTypeItemSub(conn,itmno,listItmSubObj, yyDDL, true, tempTableName);
  				}else{
  					if(projSelDDL.length()>0){
  					     projSelDDL = projSelDDL.substring(0,projSelDDL.length()-1);
   	  				     String [] projTemp = projSelDDL.split("\\|");
	    	  			 //System.out.println(""+projTemp.toString());
	    	  			 CreateTempTableProject(conn, projTemp, tempTableName);
   	  			         listItmSubObj = ListTypeItemSub(conn, itmno);
	  				     arrReportObj =ListReportCaseByTypeItemSub(conn, itmno, listItmSubObj, yyDDL, false, tempTableName);
	  				     listSelProject = ListSelectedProjectName(conn, tempTableName);	 
  					}
  				}

    	  		 String typeName = ListTypeName(conn, itmno);  	  		
    	  		 request.setAttribute("reportResultHD", arrReportObj);
    	  		 //request.setAttribute("resultSub", listObj);
    	  		 request.setAttribute("projSelectdList", listSelProject);
    	  		 request.setAttribute("yyDDL", yyDDL);//2015
 				 request.setAttribute("typeDDL",reportType);//TYPE,PROJECT,AGENT
 				 request.setAttribute("multiFlag",multiFlag);//0=ALL
 				 request.setAttribute("typeName",typeName);
 				 request.setAttribute("itemNo",itmno);
 				 request.setAttribute("projectSel", projSelDDL+"|");//LH:075|AR:011..

 		   		//*********Dispatcher  	 
 			  	//System.err.println("-------------------GenReport OK-------------------------------");	 
 			  	
 			  	String tarGetUrl ="/SERV_ReportSvcMonthlyViewDesc.jsp";
 		   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
 				dispatcher.forward(request,response);	
 				 
 				/****** Clear *******/
 				conn.close();
 				conn = null;
 			}catch(Exception e){
 				System.err.println("!!! doExpandReportForm , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
 				
 			  	//System.out.println("======doFormLoad ->successfully.=============");	 
 		   		String tarGetUrl ="/SERV_ReportSvcMonthlyForm.jsp";
 		   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
 				dispatcher.forward(request,response);	
 				 
 				/****** Clear *******/
 				conn.close();
 				conn = null;
 			}catch(Exception e){
 				System.err.println("!!! doFormLoad , " +sysName+":"+ clazzName + " : " + e.getMessage());	
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
 
 		//String itemSub=Y,N
  	   private int IntCountRowReportDetails(Connection conn, String typeDDL,String yyyy, String month,
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
 		        sql.append("Select count(a.i_svc_docno) as totalRow  ");
 			   if(isProjectALL){
	 		         //Case : All project
	 			     sql.append(" From lan:svc_dochd a ,lan:svc_docdt b ")
	 	 	 	        .append(" Where a.i_svc_docno = b.i_svc_docno ");
 		       }else{
	 		        //Case : by project
	 		        sql.append(" From lan:svc_dochd a ,lan:svc_docdt b ,"+tempTableName3+" x  ") //tbtDataName = 'tblByProjectX1'
	 		  	 	   .append(" Where a.i_svc_docno = b.i_svc_docno  ")
	 		  	 	   .append(" and a.i_company = x.com_id ")
	 		  	 	   .append(" and a.i_project = x.proj_id ");
 		       }	
			   sql.append(" and year(a.d_keyin) = '"+yyyy+"' ") 
 		    	  .append(" and a.i_project !='075' "); 
			   
			   if(Constant_Y.equals(itemSub)){ //PageForm Sub Items List 
		    		 if(Constant_type.equalsIgnoreCase(typeDDL)){// type Of Repairing
			    		 if(Constant_99.equals(grandTotal)){ //#CASE:,Interest item Mian Only && From Date ,To Date
			        	     sql.append(" and b.i_itmno = '"+param1+"'  "); //itmno
			    		 }else if(Constant_row.equals(grandTotal)){//#CASE: ROW,Interest item Main && Column TransFer
			    			 sql.append(" and b.i_itmno = '"+param1+"'  ") //itmno
			    			    .append(" and month(a.d_keyin)= '"+month+"' ");//month
			    		 }else if(Constant_col.equals(grandTotal)){//#CASE: Column ,Interest item Main && Items Sub && From Date ,To Date
			        	    sql.append(" and b.i_itmno = '"+param1+"'  ") //itmno
		 	 	        	   .append(" and b.i_itmsub = '"+param2+"'   "); //itmsub
			    		 }else{	 //#CASE: desc,      
			        	     sql.append(" and b.i_itmno = '"+param1+"'  ") //itmno
		 	 	        	    .append(" and b.i_itmsub = '"+param2+"'   ")//itmsub
		 	 	        	    .append(" and month(a.d_keyin)= '"+month+"' ");//month
			    		 } 
		    		 }	
			   }else{
				   if(!Constant_99.equals(grandTotal)){
					   if(Constant_type.equalsIgnoreCase(typeDDL)){ //CASE : TYPE
							 if(Constant_col.equals(grandTotal)){
							 	 sql.append(" and b.i_itmno = '"+param1+"' "); 
							 }else if(Constant_row.equals(grandTotal)){
							 	 sql.append(" and month(a.d_keyin)= '"+month+"' "); 
							 }else{
							 	sql.append(" and month(a.d_keyin)= '"+month+"' ")
							 		.append(" and b.i_itmno = '"+param1+"' "); 
							 } 					   
					   }else if(Constant_agent.equalsIgnoreCase(typeDDL)){//CASE : AGENT
						    if(Constant_col.equals(grandTotal)){
						    	sql.append(" and a.i_employ = '"+param1+"' ");
					 		}else if(Constant_row.equals(grandTotal)){
					 		    sql.append(" and month(a.d_keyin)= '"+month+"' "); 
					 		}else{
					 		    sql.append(" and month(a.d_keyin)= '"+month+"' ")
					 		       .append(" and a.i_employ = '"+param1+"' "); 
					 		 } 
					   }else if(Constant_project.equalsIgnoreCase(typeDDL)){ //CASE : PROJECT
						    if(Constant_col.equals(grandTotal)){
							  sql.append(" and a.i_company = '"+param1+"' ")
								 .append(" and a.i_project = '"+param2+"' ");
					 		}else if(Constant_row.equals(grandTotal)){
					 		    sql.append(" and month(a.d_keyin)= '"+month+"' "); 
					 		}else{
					 		    sql.append(" and month(a.d_keyin)= '"+month+"' ");
					 		    sql.append(" and a.i_company = '"+param1+"' ")
								   .append(" and a.i_project = '"+param2+"' ");
					 		 } 
					    }	
				   }//# 99 				   
			   }//#ELSE
			   
 		    	//System.out.println("Count MAIN : "+sql.toString());
 		    	pstmt = conn.prepareStatement(sql.toString()); 
 				rs = pstmt.executeQuery();	
 				if(rs.next()){				
 					totalRow = rs.getInt("totalRow");
 				}
 				rs.close();				
 				//********************************************************/
 			  	//System.out.println("##IntCountRowReportDetails->End.");				  	 
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
 
  		private List ListReportDetails(Connection conn,String typeDDL, String yyyy,String month,
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
 			        sql.append(" Select a.i_svc_docno,a.d_keyin,a.i_tel_ctasia,a.i_company,a.i_project,a.i_lock,a.i_house,a.n_customer,a.i_agent,a.i_employ ")
			        	.append(" ,b.d_appoint,b.i_itmno,b.i_itmsub,b.i_docno,b.c_detail "); //,c.n_desc
					    if(isProjectALL){ //Case : All project
						    sql.append(" From lan:svc_dochd a,lan:svc_docdt b  ")
					 	       .append(" Where a.i_svc_docno = b.i_svc_docno ");
				        }else{//Case : by project
					        sql.append(" From lan:svc_dochd a,lan:svc_docdt b,"+tempTableName3+" x  ") //tbtDataName = 'tblByProjectX1'
					  	 	   .append(" Where a.i_svc_docno = b.i_svc_docno ")
					  	 	   .append(" and a.i_company = x.com_id ")
					  	 	   .append(" and a.i_project = x.proj_id ");
				        } 					
 				}else{
 			        sql.append(" Select  first ").append(endRow).append("  a.i_svc_docno,a.d_keyin,a.i_tel_ctasia,a.i_company,a.i_project,a.i_lock,a.i_house,a.n_customer,a.i_agent,a.i_employ ")
 			        	.append(" ,b.d_appoint,b.i_itmno,b.i_itmsub,b.i_docno,b.c_detail "); //,c.n_desc
					    if(isProjectALL){ //Case : All project
						    sql.append(" From lan:svc_dochd a,lan:svc_docdt b  ")
					 	       .append(" Where a.i_svc_docno = b.i_svc_docno ");
				        }else{//Case : by project
					        sql.append(" From lan:svc_dochd a,lan:svc_docdt b,"+tempTableName3+" x  ") //tbtDataName = 'tblByProjectX1'
					  	 	   .append(" Where a.i_svc_docno = b.i_svc_docno ")
					  	 	   .append(" and a.i_company = x.com_id ")
					  	 	   .append(" and a.i_project = x.proj_id ");
				        }
 				}


				sql.append(" and year(a.d_keyin) = '"+yyyy+"' ") 
	 		       .append(" and a.i_project !='075' "); 
				if(Constant_Y.equals(itemSub)){ //PageForm Sub Items List 
		    		 if(Constant_type.equalsIgnoreCase(typeDDL)){// type Of Repairing
			    		 if(Constant_99.equals(grandTotal)){ //#CASE:,Interest item Mian Only && From Date ,To Date
			        	     sql.append(" and b.i_itmno = '"+param1+"'  "); //itmno
			    		 }else if(Constant_row.equals(grandTotal)){//#CASE: ROW,Interest item Main && Column TransFer
			    			 sql.append(" and b.i_itmno = '"+param1+"'  ") //itmno
			    			    .append(" and month(a.d_keyin)= '"+month+"' ");//month
			    		 }else if(Constant_col.equals(grandTotal)){//#CASE: Column ,Interest item Main && Items Sub && From Date ,To Date
			        	    sql.append(" and b.i_itmno = '"+param1+"'  ") //itmno
		 	 	        	   .append(" and b.i_itmsub = '"+param2+"'   "); //itmsub
			    		 }else{	 //#CASE: desc,      
			        	     sql.append(" and b.i_itmno = '"+param1+"'  ") //itmno
		 	 	        	    .append(" and b.i_itmsub = '"+param2+"'   ")//itmsub
		 	 	        	    .append(" and month(a.d_keyin)= '"+month+"' ");//month
			    		 } 
		    		 }	
			   }else{
				   if(!Constant_99.equals(grandTotal)){
					   if(Constant_type.equalsIgnoreCase(typeDDL)){ //CASE : TYPE
							 if(Constant_col.equals(grandTotal)){
							 	 sql.append(" and b.i_itmno = '"+param1+"' "); 
							 }else if(Constant_row.equals(grandTotal)){
							 	 sql.append(" and month(a.d_keyin)= '"+month+"' "); 
							 }else{
							 	sql.append(" and month(a.d_keyin)= '"+month+"' ")
							 		.append(" and b.i_itmno = '"+param1+"' "); 
							 } 					   
					   }else if(Constant_agent.equalsIgnoreCase(typeDDL)){//CASE : AGENT
						    if(Constant_col.equals(grandTotal)){
						    	sql.append(" and a.i_employ = '"+param1+"' ");
					 		}else if(Constant_row.equals(grandTotal)){
					 		    sql.append(" and month(a.d_keyin)= '"+month+"' "); 
					 		}else{
					 		    sql.append(" and month(a.d_keyin)= '"+month+"' ")
					 		       .append(" and a.i_employ = '"+param1+"' "); 
					 		 } 
					   }else if(Constant_project.equalsIgnoreCase(typeDDL)){ //CASE : PROJECT
						    if(Constant_col.equals(grandTotal)){
							  sql.append(" and a.i_company = '"+param1+"' ")
								 .append(" and a.i_project = '"+param2+"' ");
					 		}else if(Constant_row.equals(grandTotal)){
					 		    sql.append(" and month(a.d_keyin)= '"+month+"' "); 
					 		}else{
					 		    sql.append(" and month(a.d_keyin)= '"+month+"' ");
					 		    sql.append(" and a.i_company = '"+param1+"' ")
								   .append(" and a.i_project = '"+param2+"' ");
					 		 } 
					    }	
				   }//# 99 				   
			   }//#ELSE
	  
				 if(Constant_type.equalsIgnoreCase(typeDDL)){//CASE :TYPE
					  sql.append(" Order by a.d_keyin  desc"); 
				  }else{
					  sql.append(" Order by a.d_keyin  asc "); 
				  }

 				pstmt = conn.prepareStatement(sql.toString()); 
 				//System.out.println("Fetch DataSQL :"+sql.toString());
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
						strList.add(14,  doString.checkString(rs.getString("i_docno"),""));
						strList.add(15,  this.GetTypeSubName(conn,doString.checkString(rs.getString("i_itmno"),""),doString.checkString(rs.getString("i_itmsub"),"")));//n_desc for itm_sub
						strList.add(16,  doString.checkString(GetTypeName(conn,doString.checkString(rs.getString("i_itmno"),"")), ""));//n_desc for itm_main
						strList.add(17,  doString.checkString(rs.getString("d_keyin"),""));
						strList.add(18,  doString.checkString(rs.getString("c_detail"),""));
						
						listResult.add(strList);
 					}//#End while loop
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
 								strList.add(14,  doString.checkString(rs.getString("i_docno"),""));
 								strList.add(15,  this.GetTypeSubName(conn,doString.checkString(rs.getString("i_itmno"),""),doString.checkString(rs.getString("i_itmsub"),"")));//n_desc for itm_sub
 								strList.add(16,  doString.checkString(GetTypeName(conn,doString.checkString(rs.getString("i_itmno"),"")), ""));//n_desc for itm_main
 								strList.add(17,  doString.checkString(rs.getString("d_keyin"),""));
 								strList.add(18,  doString.checkString(rs.getString("c_detail"),""));
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
  		
  		private String GetTypeSubName(Connection conn,String iType,String iCode) { 
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
 				   .append(" and i_code = '"+iCode+"' ");
 				//System.err.println("22222:"+sql.toString());
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
		
		/************************************
		 * ListReportCaseProject
		 * @param conn
		 * @param listProjectAll
		 * @param yearEng
		 * @param isProjectAll
		 * @param tempTableName
		 * @return
		 ********************************/
		public List  ListReportCaseProject(Connection conn,List listProjectAll,String yearEng,boolean isProjectAll,String tempTableName){
			StringBuffer sqlFetch = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			try{
	        	List objListResult= new ArrayList();
	  			//-----------------
	  			//String []tempMatrix = null;
	  			//int [] CNT_MATRIX = null;//new int[15];
	  			int MAX_ROW =  listProjectAll.size();
	         	int MAX_COLUMN =  16 ;
	        	int c = 0;
	            String[][] MATRIX = new String[MAX_ROW][MAX_COLUMN]; //int[][] a = new int[2][4];  // Two rows and four columns.           
	            //System.out.println("MAX_ROW :"+listProjectAll.size());
	            //System.out.println("MAX_COLUMN :"+MAX_COLUMN);
	            //System.out.println("MATRIX :"+MATRIX.length);	            
	           if(listProjectAll!=null && listProjectAll.size()>0){
	        	   List<String> tempList = null;
	 				//int Loop = 0;
	 				for (int i = 0; i < listProjectAll.size(); i++) {
	 					tempList = (List<String>)listProjectAll.get(i);
	 					//System.out.println(i+","+tempList.get(0)+","+tempList.get(1)+","+tempList.get(2));
	 					c = 0;
	 					MATRIX[i][c++] = tempList.get(0);//ROW=0,COLUMN=0, i_company
	 					MATRIX[i][c++] = tempList.get(1);//ROW=1,COLUMN=1, i_project
	 					MATRIX[i][c++] = tempList.get(2);//ROW=2,COLUMN=2, n_name
	 					MATRIX[i][c++] = "";//ROW=maxLenght,COLUMN,   
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 1+3 
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 2+3
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 3+3
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 4
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 5
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 6
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 7
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 8
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 9
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 10
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 11
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 12 //index=15
	 				}	
	           }

	           //-------------------
	           String comId = "";
	           String projectId = "";
	           int columX = 0;
	           //-------------------
	  			sqlFetch.delete(0, sqlFetch.length());
				sqlFetch.append(" Select a.i_company,a.i_project,month(a.d_keyin) as month,count(*) as cnt ");
				if(isProjectAll){//ALL
					sqlFetch.append(" From lan:svc_dochd a ,lan:svc_docdt b ")
					    .append(" Where a.i_svc_docno = b.i_svc_docno ")
						.append(" and year(a.d_keyin) = '"+yearEng+"' ")
						.append(" and a.i_project !='075' ")
						.append(" Group by 1,2,3	 ")
						.append(" Order by 1,2,3 asc ");					
				}else{// By Project
					//sqlFetch.append(" From svc_dochd a  ,"+tempTableName+" x ")
					//.append(" Where year(a.d_keyin) = '"+yearEng+"' ")
					sqlFetch.append(" From lan:svc_dochd a ,lan:svc_docdt b ,"+tempTableName+" x ")
						.append(" Where a.i_svc_docno = b.i_svc_docno ")
						.append(" and year(a.d_keyin) = '"+yearEng+"' ")
						.append(" and a.i_project !='075' ")
						.append(" and a.i_company = x.com_id ")
 	 	  	 	        .append(" and a.i_project = x.proj_id ")
						.append(" Group by 1,2,3	 ")
						.append(" Order by 1,2,3 asc ");					
				}
				//System.out.println("SQL By Project :"+sqlFetch.toString());
				pstmt = conn.prepareStatement(sqlFetch.toString()); 
	 	        rs = pstmt.executeQuery();	
	 	        while(rs.next()){
	 	            comId = "";
		            projectId = "";
	 	        	comId = doString.checkString(rs.getString("i_company"),"");
	 	        	projectId = doString.checkString(rs.getString("i_project"),"");
	 	        	for(int x = 0;x<MATRIX.length;x++){
	 	        		if(MATRIX[x][0].equals(comId) && MATRIX[x][1].equals(projectId)){ //code from Loop SQL = code Loop Array
	 	        			//System.out.println(x+"==>"+rs.getInt("month"));
	 	        			columX = 0;
	 	        			columX = (3+Integer.parseInt(doString.checkString(rs.getString("month"),"0")));
	 	        			//System.out.println(columX);
	 	        			MATRIX[x][columX] = ""+rs.getInt("cnt");
	 	        		    break;	
	 	        		}
	 	        	}	
	 	        }
	 	        rs = null;
	 	        objListResult.add(MATRIX);
	 	        //System.out.println("================Complete======================");
	     	    //---#End ---/
			  	return objListResult;			  	 
			}catch(Exception e){
				System.err.println("!!!ListReportCaseProject, " +sysName+":"+ clazzName + " : " + e.getMessage());
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


		/********************************
		 * ListReportCaseType
		 * @param conn
		 * @param listType
		 * @param yearEng
		 * @param isProjectAll
		 * @param tempTableName
		 * @return
		 ******************************/
		public List  ListReportCaseType(Connection conn,List listType,String yearEng,boolean isProjectAll,String tempTableName){
			StringBuffer sqlFetch = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			try{
	        	List objListResult= new ArrayList();
	  			//-----------------
	  			int MAX_ROW =  listType.size();
	         	int MAX_COLUMN =  16 ;
	        	int c = 0;
	            String[][] MATRIX = new String[MAX_ROW][MAX_COLUMN]; //int[][] a = new int[2][4];  // Two rows and four columns.
	           
	            //System.out.println("MAX_ROW :"+listType.size());
	            //System.out.println("MAX_COLUMN :"+MAX_COLUMN);
	            //System.out.println("MATRIX :"+MATRIX.length);
	            
	           if(listType!=null && listType.size()>0){
	        	   List<String> tempList = null;
	 				//int Loop = 0;
	 				for (int i = 0; i < listType.size(); i++) {
	 					tempList = (List<String>)listType.get(i);
	 					//System.out.println(i+","+tempList.get(0)+","+tempList.get(1)+","+tempList.get(2));
	 					c = 0;
	 					MATRIX[i][c++] = tempList.get(0);//ROW=0,COLUMN=0, type 
	 					MATRIX[i][c++] = tempList.get(1);//ROW=1,COLUMN=1, count
	 					MATRIX[i][c++] = tempList.get(2);//ROW=2,COLUMN=2, name
	 					MATRIX[i][c++] = "";//ROW=maxLenght,COLUMN,   
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 1+3 
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 2+3
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 3+3
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 4
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 5
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 6
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 7
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 8
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 9
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 10
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 11
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 12 //index=15
	 				}	
	           }

	           //-------------------
	           String code = "";
	           int columX = 0;
	           //-------------------
	  			sqlFetch.delete(0, sqlFetch.length());
				sqlFetch.append(" Select b.i_itmno,month(a.d_keyin) as month,count(b.i_svc_docno) as cnt ");
				 if(isProjectAll){//ALL
					sqlFetch.append(" From lan:svc_dochd a ,lan:svc_docdt b ")
						.append(" Where a.i_svc_docno = b.i_svc_docno ")
						.append(" and year(a.d_keyin) = '"+yearEng+"' ")
						.append(" and a.i_project !='075' ")
						.append(" Group by 1,2	 ")
						.append(" Order by 1,2 asc ");
				 }else{// By Project
					sqlFetch.append(" From lan:svc_dochd a ,lan:svc_docdt b ,"+tempTableName+" x ")
						.append(" Where a.i_svc_docno = b.i_svc_docno ")
						.append(" and year(a.d_keyin) = '"+yearEng+"' ")
						.append(" and a.i_project !='075' ")
						.append(" and a.i_company = x.com_id ")
 	 	  	 	        .append(" and a.i_project = x.proj_id ")
						.append(" Group by 1,2	 ")
						.append(" Order by 1,2 asc ");
				 }
				//System.out.println("SQL By Type :"+sqlFetch.toString());
				pstmt = conn.prepareStatement(sqlFetch.toString()); 
	 	        rs = pstmt.executeQuery();	
	 	        while(rs.next()){
	 	        	//i_employ=1078-8 ,month=4,cnt=6
	 	        	code = doString.checkString(rs.getString("i_itmno"),"");
	 	        	for(int x = 0;x<MATRIX.length;x++){
	 	        		if(MATRIX[x][0].equals(code)){ //code from Loop SQL = code Loop Array
	 	        			//System.out.println(x+"==>"+rs.getInt("month"));
	 	        			columX = 0;
	 	        			columX = (3+Integer.parseInt(doString.checkString(rs.getString("month"),"0")));
	 	        			//System.out.println(columX);
	 	        			MATRIX[x][columX] = ""+rs.getInt("cnt");
	 	        		    break;	
	 	        		}
	 	        	}	
	 	        }
	 	        rs = null;
	 	        objListResult.add(MATRIX);
	 	        //System.out.println("================Complete======================");
	     	    //---#End ---/
			  	return objListResult;			  	 
			}catch(Exception e){
				System.err.println("!!!ListReportCaseType, " +sysName+":"+ clazzName + " : " + e.getMessage());
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
		
		/********************************
		 * ListReportCaseByTypeItemSub
		 * @param conn
		 * @param listType
		 * @param yearEng
		 * @param isProjectAll
		 * @param tempTableName
		 * @return
		 ******************************/
		public List  ListReportCaseByTypeItemSub(Connection conn,String itemNo,List listType,String yearEng,boolean isProjectAll,String tempTableName){
			StringBuffer sqlFetch = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			try{
	        	List objListResult= new ArrayList();
	  			//-----------------
	  			int MAX_ROW =  listType.size();
	         	int MAX_COLUMN =  16 ;
	        	int c = 0;
	            String[][] MATRIX = new String[MAX_ROW][MAX_COLUMN]; //int[][] a = new int[2][4];  // Two rows and four columns.
	           
	            //System.out.println("MAX_ROW :"+listType.size());
	            //System.out.println("MAX_COLUMN :"+MAX_COLUMN);
	            //System.out.println("MATRIX :"+MATRIX.length);
	            
	           if(listType!=null && listType.size()>0){
	        	   List<String> tempList = null;
	 				//int Loop = 0;
	 				for (int i = 0; i < listType.size(); i++) {
	 					tempList = (List<String>)listType.get(i);
	 					//System.out.println(i+","+tempList.get(0)+","+tempList.get(1)+","+tempList.get(2));
	 					c = 0;
	 					MATRIX[i][c++] = tempList.get(0);//ROW=0,COLUMN=0, type 
	 					MATRIX[i][c++] = tempList.get(1);//ROW=1,COLUMN=1, icode
	 					MATRIX[i][c++] = tempList.get(2);//ROW=2,COLUMN=2, name
	 					MATRIX[i][c++] = "";//ROW=maxLenght,COLUMN,   
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 1+3 
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 2+3
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 3+3
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 4
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 5
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 6
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 7
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 8
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 9
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 10
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 11
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 12 //index=15
	 				}	
	           }

	           //-------------------
	           String code = "";
	           int columX = 0;
	           //-------------------
	  			sqlFetch.delete(0, sqlFetch.length());
				sqlFetch.append(" Select b.i_itmsub,month(a.d_keyin) as month,count(b.i_svc_docno) as cnt ");
				 if(isProjectAll){//ALL
					sqlFetch.append(" From lan:svc_dochd a ,lan:svc_docdt b ")
						.append(" Where a.i_svc_docno = b.i_svc_docno ")
						.append(" and year(a.d_keyin) = '"+yearEng+"' ")
						.append(" and a.i_project !='075' ")
						.append(" and b.i_itmno = '"+itemNo+"' ")
						.append(" Group by 1,2	 ")
						.append(" Order by 1,2 asc ");
				 }else{// By Project
					sqlFetch.append(" From lan:svc_dochd a ,lan:svc_docdt b ,"+tempTableName+" x ")
						.append(" Where a.i_svc_docno = b.i_svc_docno ")
						.append(" and year(a.d_keyin) = '"+yearEng+"' ")
						.append(" and a.i_project !='075' ")
						.append(" and a.i_company = x.com_id ")
 	 	  	 	        .append(" and a.i_project = x.proj_id ")
 	 	  	 	        .append(" and b.i_itmno = '"+itemNo+"' ")
						.append(" Group by 1,2	 ")
						.append(" Order by 1,2 asc ");
				 }
				//System.out.println("SQL By ItemSub :"+sqlFetch.toString());
				pstmt = conn.prepareStatement(sqlFetch.toString()); 
	 	        rs = pstmt.executeQuery();	
	 	        while(rs.next()){
	 	        	//i_employ=1078-8 ,month=4,cnt=6
	 	        	code = doString.checkString(rs.getString("i_itmsub"),"");
	 	        	for(int x = 0;x<MATRIX.length;x++){
	 	        		if(MATRIX[x][1].equals(code)){ //code from Loop SQL = code Loop Array
	 	        			//System.out.println(x+"==>"+rs.getInt("month"));
	 	        			columX = 0;
	 	        			columX = (3+Integer.parseInt(doString.checkString(rs.getString("month"),"0")));
	 	        			//System.out.println(columX);
	 	        			MATRIX[x][columX] = ""+rs.getInt("cnt");
	 	        		    break;	
	 	        		}
	 	        	}	
	 	        }
	 	        rs = null;
	 	        objListResult.add(MATRIX);
	 	        //System.out.println("================Complete======================");
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

		/***********************************
		 * ListReportCaseAgent
		 * @param conn
		 * @param listAgentName
		 * @param yearEng
		 * @param isProjectAll
		 * @param tempTableName
		 * @return  ALL Project && By Project
		 **************************************/
		public  List ListReportCaseAgent(Connection conn,List listAgentName,String yearEng,boolean isProjectAll,String tempTableName){ 
			StringBuffer sqlFetch = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			try{
	        	List objListResult= new ArrayList();
	  			//-----------------
	  			int MAX_ROW =  listAgentName.size();
	         	int MAX_COLUMN =  16 ;
	        	int c = 0;
	            String[][] MATRIX = new String[MAX_ROW][MAX_COLUMN]; //int[][] a = new int[2][4];  // Two rows and four columns.
	           
	            //System.out.println("MAX_ROW :"+listAgentName.size());
	            //System.out.println("MAX_COLUMN :"+MAX_COLUMN);
	            //System.out.println("MATRIX :"+MATRIX.length);
	            
	           if(listAgentName!=null && listAgentName.size()>0){
	        	   List<String> tempList = null;
	 				//int Loop = 0;
	 				for (int i = 0; i < listAgentName.size(); i++) {
	 					tempList = (List<String>)listAgentName.get(i);
	 					//System.out.println(i+","+tempList.get(0)+","+tempList.get(1)+","+tempList.get(2));
	 					c = 0;
	 					MATRIX[i][c++] = tempList.get(0);//ROW=0,COLUMN=0, i_employ 
	 					MATRIX[i][c++] = tempList.get(1);//ROW=1,COLUMN=1, prefix
	 					MATRIX[i][c++] = tempList.get(2);//ROW=2,COLUMN=2, fname
	 					MATRIX[i][c++] = tempList.get(3);//ROW=maxLenght,COLUMN,   lname
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 1+3 
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 2+3
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 3+3
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 4
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 5
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 6
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 7
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 8
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 9
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 10
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 11
	 					MATRIX[i][c++] = "0";//ROW,COLUMN, 12 //index=15
	 				}	
	           }

	           //-------------------
	           String employId = "";
	           int columX = 0;
	           //-------------------
	  			sqlFetch.delete(0, sqlFetch.length());
				sqlFetch.append(" Select a.i_employ,month(a.d_keyin) as month,count(*) as cnt ");
			    if(isProjectAll){//ALL
					 sqlFetch.append(" From lan:svc_dochd a ,lan:svc_docdt b ")
							 .append(" Where a.i_svc_docno = b.i_svc_docno ")
					         .append(" and year(a.d_keyin) = '"+yearEng+"' ")
							 .append(" and a.i_project !='075' ")
							 .append(" and a.i_employ != '' ")
							 .append(" Group by 1,2	 ")
							 .append(" Order by 1,2 asc ");
				  }else{// By project
					  sqlFetch.append(" From lan:svc_dochd a ,lan:svc_docdt b ,"+tempTableName+" x ") //append(" From svc_dochd a, "+tempTableName+" x ")
						 .append(" Where a.i_svc_docno = b.i_svc_docno ")
					     .append(" and year(a.d_keyin) = '"+yearEng+"' ")
						 .append(" and a.i_project !='075' ")
						 .append(" and a.i_employ != '' ")
						 .append(" and a.i_company = x.com_id ")
 	 	  	 	         .append(" and a.i_project = x.proj_id ")
						 .append(" Group by 1,2	 ")
						 .append(" Order by 1,2 asc ");
				 }
			    //and a.i_employ = '2426-7'
				//System.out.println("SQL By Agent :"+sqlFetch.toString());
				pstmt = conn.prepareStatement(sqlFetch.toString()); 
	 	        rs = pstmt.executeQuery();	
	 	        while(rs.next()){
	 	        	//i_employ=1078-8 ,month=4,cnt=6
	 	        	employId = doString.checkString(rs.getString("i_employ"),"");
	 	        	for(int x = 0;x<MATRIX.length;x++){
	 	        		if(MATRIX[x][0].equals(employId)){ //employ from Loop SQL = employ Loop Array
	 	        			//System.out.println(x+"==>"+rs.getInt("month"));
	 	        			columX = 0;
	 	        			columX = (3+Integer.parseInt(doString.checkString(rs.getString("month"),"0")));
	 	        			MATRIX[x][columX] = ""+rs.getInt("cnt");
	 	        		    break;	
	 	        		}
	 	        	}	
	 	        }
	 	        rs = null;
	 	        objListResult.add(MATRIX);
	 	        //System.out.println("================Complete======================");
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
 				//System.out.println("SQL 'ListAgentName' :"+sql.toString());
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
 			
 		private String ListTypeName(Connection conn,String iType) { 
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
 				System.err.println("!!!ListTypeName , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
 				//System.out.println("====>ListProjectResposible SQL :"+sql.toString());
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
 		
 		/*****************************************
 		 * ListAllProjectName
 		 * @param conn
 		 * @param year
 		 * @return
 		 ******************************************/
 		private List ListAllProjectName(Connection conn,String yearEng) {
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
 					.append(" Where year(a.d_keyin)  = '"+yearEng+"' ")
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
 				//System.out.println("SQL Insert :"+sql.toString());
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
 				System.err.println(" SQL Exception: "+sql.toString());		
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
		private  HSSFWorkbook GenExcelPaper(List excelData,String typeDDL,String Month,String yyDDL,String typeName
				 ,String grandTotal,String multiFlag,List projSelectdList) throws Exception{		
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
	  
	            String lableName1 = "";
	            String msgName1 = "";
	            String lableName2 = "";
	            String msgName2 = "";
	
	            if("row".equals(grandTotal) && !"99".equals(grandTotal)){
	            	lableName1 = "ตามประเภท";
	            	msgName1 = " - ";
	            	lableName2 = "ตามช่วง";
	            	msgName2 = thaiMonth[Integer.parseInt(Month)] +" ปี พ.ศ : "+(Integer.parseInt(yyDDL)+543);
	            } else if("col".equals(grandTotal) && !"99".equals(grandTotal)){
	            	lableName1 = "ตามประเภท";
	            	msgName1 = doString.DisplayThai(typeName);
	            	lableName2 = "ตามช่วง";
	            	msgName2 = "ปี พ.ศ :"+(Integer.parseInt(yyDDL)+543) ;
	            }else if("99".equals(grandTotal)){
	            	lableName1 ="ตามประเภท";
	            	msgName1 = "-";
	            	lableName2 = "ตามช่วง";
	            	msgName2 = "ทุกเดือน และ ทุกประเภท   ปี พ.ศ :"+(Integer.parseInt(yyDDL)+543) ;	            	
	            }else{
	            	lableName1 ="ตามประเภท";
	            	msgName1 = doString.DisplayThai(typeName);
	            	lableName2 = "ตามช่วง";
	            	msgName2 = thaiMonth[Integer.parseInt(Month)]+"  ปี พ.ศ :"+(Integer.parseInt(yyDDL)+543) ;	  	            	

	            }

	            /**2222 **/
	            row = sheet.createRow((short) 1);
	            row.setHeight((short) 300);
	            
	            cell = row.createCell((short) 0);
	            cell.setCellStyle(align_left2);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellValue(lableName1);
	            
	            cell = row.createCell((short) 1);
	            cell.setCellStyle(align_left2);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellValue(msgName1);
	            
	            /**3333 **/
	            row = sheet.createRow((short) 2);
	            row.setHeight((short) 300);
	            
	            cell = row.createCell((short) 0);
	            cell.setCellStyle(align_left2);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellValue(lableName2);
	            
	            cell = row.createCell((short) 1);
	            cell.setCellStyle(align_left2);
	            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	            cell.setCellValue(msgName2);
	            
	            /**44444 **/
	            row = sheet.createRow((short) 3);
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
	            row = sheet.createRow((short)4);
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

	               
	            //***********************
	            if(excelData !=null && excelData.size()>0){
	    			//int x = 1;
	    			i=5;
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

 		public static  String toDDMMYY_THAI2(String str){
 			if ((str == null) || str.equals("")) {
 				 return  str;
 			}else{
 			     String x = str.substring(0,10);
 				 String d2[] = x.split("\\-"); //2013-03-29
 				 return d2[2]+"/"+d2[1]+"/"+(Integer.parseInt(d2[0])+543)+" "+str.substring(10,16)+" น.";
 			}
 		}
 		
 		private static void DisplayMatrixArray2(List arrList){
 			if(arrList!=null && arrList.size()>0){		
 				//List<String> tempList = null;
 				String strMatrix[][] = null;
 				Iterator it = arrList.iterator();	
 				int i = 0;
 				int j = 0;
 				System.out.println("==================================================================================");
 				while(it.hasNext()){								
 					strMatrix = (String[][])it.next();
 					
 					for(i=0; i<strMatrix.length; i++) {
 					    for(j=0; j<strMatrix[i].length; j++){
 					    	 System.out.print(strMatrix[i][j]+" , ");
 					    }    
 					    System.out.println("");
 					 }
 				}	
 				System.out.println("==================================================================================");
 			}			
 		}	
}