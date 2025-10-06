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
 * Servlet implementation class for Servlet: SERV_RptTransAfterEndServlet
 * create by : pradoem wonkraso ,go2doem@gmail.com, pradoem@lh.co.th
 * date time: 2016.06.07
 * version : 1.0
 * project : Report form  bann transfer check form  QC
 * comment:  this class controller servlet for List Report baan transfer
 * check list by user 
 */

 public class SERV_RptTransAfterEndServlet extends  DBServlet{
    /* (non-Java-doc)
	 * @see javax.servlet.http.HttpServlet#HttpServlet()
	 */
	String sysName = "LHServ";
	String clazzName = new String(this.getClass().getName() + ".performTask :");	
	String USER_ID = "";
	String thaiMonth[] = new String[] {"มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม",""};
	String shortMonth[] = new String[] {"ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค.",""};
	final static String C_STATUS = "C";
	final static String D_STATUS = "D";

	public SERV_RptTransAfterEndServlet() {
		super();
	}  
	public void performTask(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {	  
		System.out.println(clazzName + "start.");   
		response.setContentType("text/html; charset=TIS-620");
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

		/*else{
			User user = null;
			if(session != null){
				user =(User)session.getAttribute("USER");
			}
		}*/
	    /*if (session == null) {
	        /** Redirect user to login page if there's no session. * /
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
		PrintWriter out =null;//= response.getWriter();
		String  command = request.getParameter("cmd")==null?"":request.getParameter("cmd");	
		try{			
			  if(command.equals("frmLoad")){	
				 this.doFormLoad(request,response,user);				
			  }else if(command.equals("GenReport")){			  
				 this.doGenReportForm(request,response,user);
			  }else if(command.equals("GenReport2")){
				this.doGenerateReport(request,response,user);
			  }else if(command.equals("onchange")){			  
				String html = this.doEchoSubDropdownList(request,response);
				out = response.getWriter();
				out.println(html);
			  }else if(command.equals("onchangeItems")){	  
				String html = this.doEchoItemsDropdownList(request,response);
				out = response.getWriter();
				out.println(html);
			  }else if(command.equals("desc")){			  
				this.doFormDescription(request, response, user);  
			  }
		}catch(Exception e){
			e.printStackTrace();
			System.out.println(sysName+":"+clazzName +" "+e.toString());		
		}
		finally{
			//System.out.println("======Finally======");
			if(out!=null){
			   out.close();
			   out = null;
			}
			/*if(out2!=null){
				out2.close();
				out2 = null;
			}*/
		}
	}	
	
	protected String doEchoSubDropdownList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
		// TODO Auto-generated method stub
		//response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;	
		String msgTxt = "";// Constants.APP_PATH+Constants.SAVE_PAGE;
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
		//String errorCode = "99";	
	
        try{
        	//System.out.println("doEchoSubDropdownList ->Starting.");
        	// printOutParam(request,"doEchoSubDropdownList");
 			//----------Open connection
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
  			//conn.setAutoCommit(false);
            //-------------------------
			 String mainDDL =  doString.checkString(request.getParameter("mainDDL"),"");
			 if(!"AAA".equals(mainDDL)){
				 String temp[] = mainDDL.split("\\:");
				 mainDDL = temp[1];
			 }
			 
			List arrSubsList = this.ListSubsCategory(conn, mainDDL);
			//System.out.println("==>arrSubsList :"+arrSubsList.size());
			String temp = builSubCategoryDropDownTagHTML(arrSubsList, mainDDL,"");
			//System.out.println("==>temp :"+temp);
			 
			//out.print(temp);
	   		//*********Dispatcher  	 
		  	//System.out.println("doEchoSubDropdownList ->successfully.");	  
			/****** Clear *******/
			conn.close();
			conn = null;
			return temp;
		}catch(Exception e){
			//return;
			System.out.println("!!! doEchoSubDropdownList , " +sysName+":"+ clazzName + " : " + e.getMessage());	
			msgTxt = "doEchoSubDropdownList , " +sysName+":"+ clazzName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
			return "";
		}
		finally{			
			//clean up.
			try{
				if(conn!=null){conn.close();}
			}catch(Exception e){}
		}
	}
	
	protected String doEchoItemsDropdownList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
		// TODO Auto-generated method stub
		//response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;	
		String msgTxt = "";// Constants.APP_PATH+Constants.SAVE_PAGE;
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
		//String errorCode = "99";	
	
        try{
        	 //System.out.println("doEchoItemsDropdownList ->Starting.");
        	 //printOutParam(request,"doEchoItemsDropdownList");
 			//----------Open connection
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
  			//conn.setAutoCommit(false);
            //-------------------------
			 String mainDDL =  doString.checkString(request.getParameter("mainDDL"),"");
			 String subDDL =  doString.checkString(request.getParameter("subDDL"),"");
			 if(!"AAA".equals(mainDDL)){
				 String temp[] = mainDDL.split("\\:");
				 mainDDL = temp[1];
			 }
			 List arrSubsList = this.ListItemsCategory(conn, mainDDL, subDDL);
			 //System.out.println("==>arrItemsList :"+arrSubsList.size());
			 String temp = builItemsCategoryDropDownTagHTML(arrSubsList, mainDDL,"");
			 //System.out.println("==>temp :"+temp);
			 
			//out.print(temp);
	   		//*********Dispatcher  	 
		  	//System.out.println("doEchoItemsDropdownList ->successfully.");	  
			/****** Clear *******/
			conn.close();
			conn = null;
			return temp;
		}catch(Exception e){
			//return;
			System.out.println("!!! doEchoItemsDropdownList , " +sysName+":"+ clazzName + " : " + e.getMessage());	
			msgTxt = "doEchoItemsDropdownList , " +sysName+":"+ clazzName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
			return "";
		}
		finally{			
			//clean up.
			try{
				if(conn!=null){conn.close();}
			}catch(Exception e){}
		}
	}
	
	//*****method doFormLoad criteria projectDDL
	protected void doFormLoad(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		//response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		ServletContext context = getServletContext();
		HttpSession session = request.getSession(false);		
		String msgTxt = "";// Constants.APP_PATH+Constants.SAVE_PAGE;
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
		String errorCode = "99";	
	
        try{
        	 //System.out.println("doFormLoad ->Starting.");
        	// printOutParam(request,"doFormLoad");
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
		  	 
	   		String tarGetUrl ="/SERV_RptTransAfterEnd_01_Form.jsp";
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

	 //*****method doFodoGenReportFormrmLoad criteria projectDDL
	public void doGenerateReport(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		//response.setContentType("text/html; charset=TIS-620");
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
        	//printOutParam(request,"doGenerateReport");
 			//----------Open connection
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
  			//conn.setAutoCommit(false);

			/*A=จำนวนรายการ  count(*)
			B=จำนวนเลขที่อ้างอิง / เลขที่ใบเบิก
			C=จำนวนเงิน
			D=จำนวนแปลง*/
            //-------------------------
			String tempProjectTxt = doString.checkString(request.getParameter("tempProjectTxt"),"");//LH:151|LH:152|LH:154|LH:156|LH:157
  			String multiFlag = doString.checkString(request.getParameter("multiFlag"),"0"); //0=ALL Project,1= By project	  
			String type_amt = doString.checkString(request.getParameter("type_amt"),"A");
  			String rbtType = doString.checkString(request.getParameter("rbtType"),"A");//A,B 
  			
  			String mainDDL = doString.checkString(request.getParameter("mainDDL"),""); 
  			String subDDL = doString.checkString(request.getParameter("subDDL"),""); 
  			String itemsDDL = doString.checkString(request.getParameter("itemsDDL"),"");
  			
  			String fromDate = doString.checkString(request.getParameter("fromDate"),""); //2016-05-01
  			String toDate = doString.checkString(request.getParameter("toDate"),""); //2016-05-31		
			
  			if(!"AAA".equals(mainDDL)){
				 String temp[] = mainDDL.split("\\:");
				 mainDDL = temp[1];
			}
	  		/**********************************/
  			//System.out.println("======= fromDate :"+fromDate);
  			//System.out.println("======= toDate :"+toDate);

		  	/**********************************/
        	String temp_tbtProject = "temp_proj_"+USER_ID;

	  		 List  selProjectList= new ArrayList();
	  		 List rptMainGroupList = new ArrayList();
	  		 List rptSubsList = new ArrayList();
	  		 List rptItempsList = new ArrayList();
	  		 
	  		 //หมวดหลัก 
	  		 List listMainGroup =this.ListMainCategory(conn);
			 //*******************************************************************/
	  		 List arrSubsList = null;
	  		 List arrItempsList = null;
	  		 
	  		 int caseNumber = 0;
	  		 if("AAA".equals(mainDDL)&& "nnnn".equals(subDDL) && "nnnnnnnn".equals(itemsDDL)){ 
	  			 //TODO :CASE ALL Main,No display Subs,No Display items
	  			 //===>Main=AAA,Sub=nnnn,items=nnnnnnn
	  			caseNumber = 1;
	  		 }else if("AAA".equals(mainDDL)&& "ALL".equals(subDDL) && "nnnnnnnn".equals(itemsDDL)){ 
	  			 //TODO :CASE ALL Main,ALL, No Display items
	  			 //===>Main=AAA,Sub=ALL,items=nnnnnnn
	  			caseNumber = 2;
	  		 }else if(!"AAA".equals(mainDDL) && "nnnn".equals(subDDL) && "nnnnnnnn".equals(itemsDDL)){
	  			 //TODO :CASE Select Main,No display Subs,No Display items
	  			 //===>Main=08,Sub=nnnn,items=nnnnnnn
	  			caseNumber= 3;
	  		 }else if(!"AAA".equals(mainDDL) && "ALL".equals(subDDL) && "nnnnnnnn".equals(itemsDDL)){
	  			 //TODO :CASE Select Main,No display Subs,No Display items
	  			 //===>Main=08,Sub=ALL,items=nnnnnnn
	  			caseNumber= 4;
	  		 }else if(!"AAA".equals(mainDDL) && !"ALL".equals(subDDL) && "nnnnnnnn".equals(itemsDDL)){
	  			 //TODO :CASE Select 08,Subs 04 ,No Display items
	  			 //===>Main=08,===>Sub= 0802,items=nnnnnnn
		  		 //หมวดรอง 
		  		 arrSubsList = this.ListSubsCategory(conn, mainDDL);
		  		 caseNumber= 5;
	  		 }else if(!"AAA".equals(mainDDL) && !"ALL".equals(subDDL) && "ALL".equals(itemsDDL)){
	  			 //TODO :CASE Select 08,Subs 04 ,ALL Display items
	  			 //===>Main=08,=>Sub=0802,items=ALL
		  		 //หมวดรอง 
		  		 arrSubsList = this.ListSubsCategory(conn, mainDDL);
		  		 caseNumber= 6;
	  		 }else{
	  			 arrSubsList = this.ListSubsCategory(conn, mainDDL);
	  			 //รายการ by items
		  		 arrItempsList = this.ListItemsCategory(conn,mainDDL,subDDL);
		  		 caseNumber= 7;
	  		 }
	  		 
	  		 if(multiFlag.equals("0")){//TODO: CASE : ALL Project
	  			 GeneratePreparedIntoTempTable(conn, true, temp_tbtProject, tempProjectTxt);
	  		 }else{//TODO: CASE : By project  			
	        	 /************************************************/
	             //1.Insert project to temp table
	  			 GeneratePreparedIntoTempTable(conn, false, temp_tbtProject, tempProjectTxt);		 	
	  			 selProjectList = this.ListProjectSelect(conn, tempProjectTxt);
	  		 }//#IF End Check ALL Project
	  		 
	  		 List ListMainCategory = null;
			 switch(caseNumber){
    			case 1: //TODO: ALL,Not view,Not view
	  			 	rptMainGroupList = ListReportCaseByMainGroup(conn, listMainGroup,"","", fromDate, toDate, temp_tbtProject,rbtType,type_amt);
		  			//System.out.println("1===================CASE BY PROJECT :TODO :CASE ALL Main,No display Subs,No Display items ======");
		  			//DisplayMaxtrixList(rptMainGroupList);	
	        		break;
    			case 2: //TODO: ALL,ALL,Not view
	  			 	rptMainGroupList = ListReportCaseByMainGroup(conn, listMainGroup, "","",fromDate, toDate, temp_tbtProject,rbtType,type_amt);
		  			//DisplayMaxtrixList(rptMainGroupList);
		  			rptSubsList = ListReportCaseBySubsGroup01(conn, listMainGroup, fromDate, toDate, temp_tbtProject, rbtType,type_amt);
		  			//System.out.println("22222===================CASE BY PROJECT:TODO :CASE Select ALL Main,ALL Subs,No Display items ======");
		  			//DisplayMaxtrixList(rptSubsList);
	        		break;	
    			case 3: //TODO: CASE Select 18Main,No display Subs,No Display items
    				ListMainCategory = ListMainCategory(conn, mainDDL);//08
	  			 	rptMainGroupList = ListReportCaseByMainGroup(conn, ListMainCategory,"","", fromDate, toDate, temp_tbtProject,rbtType,type_amt);
		  			//System.out.println("3333333=============CASE BY PROJECT:TODO :CASE Select 08 Main,No display Subs,No Display items ======");
		  			//DisplayMaxtrixList(rptMainGroupList);
	        		break;
    			case 4: //TODO:
        			//===>Main=08//Sub=ALL//items=nnnnnnn
    				ListMainCategory = ListMainCategory(conn, mainDDL);//08
	  			 	rptMainGroupList = ListReportCaseByMainGroup(conn, ListMainCategory,"","", fromDate, toDate, temp_tbtProject,rbtType,type_amt);
	  			 	
		  			rptSubsList = ListReportCaseBySubsGroup01(conn, listMainGroup, fromDate, toDate, temp_tbtProject, rbtType,type_amt);
		  			//System.out.println("44444==================CASE BY PROJECT:TODO :CASE Select 18,Main,ALL Subs,No Display items ======");
		  			//DisplayMaxtrixList(rptSubsList);
	        		break;	
    			case 5: 
    				//TODO :CASE Main=08,Sub= 0802,items=nnnnnnn
    				ListMainCategory = ListMainCategory(conn, mainDDL);//08=1 Record
    				
	  			 	rptMainGroupList = ListReportCaseByMainGroup(conn, ListMainCategory,subDDL,"", fromDate, toDate, temp_tbtProject,rbtType,type_amt);
	  			 	
	  			 	rptSubsList = ListReportCaseBySubsGroup02(conn, ListMainCategory,subDDL,"", fromDate, toDate, temp_tbtProject, rbtType,type_amt);
		  			//System.out.println("55555=============CASE BY PROJECT:TODO :CASE Select 18 Main,0201 Subs,No Display items ======");

	        		break;	
    			case 6 :
    				//TODO :CASE Main=05, 0504,items=ALL
    				//Return 1 Rec
    				ListMainCategory = ListMainCategory(conn, mainDDL);//08=1 Record
	  			 	rptMainGroupList = ListReportCaseByMainGroup(conn, ListMainCategory,subDDL,"", fromDate, toDate, temp_tbtProject,rbtType,type_amt);
	  			 	
	  			 	//Return 1 Rec
	  			 	rptSubsList = ListReportCaseBySubsGroup02(conn, ListMainCategory,subDDL,"", fromDate, toDate, temp_tbtProject, rbtType,type_amt);
	  			 	
	  			 	//Return ALL items
	  			 	rptItempsList = ListReportCaseByItems(conn, listMainGroup, subDDL,true, fromDate, toDate, temp_tbtProject, rbtType,type_amt);
		  			//System.out.println("66666==========CASE BY PROJECT:TODO :CASE Select 05 Main,0504 Subs,ALL Display items ======");
		  			break;	
    			case 7 :
    				//TODO :CASE Main=05,Sub= 0504,items=050401
    				//Return 1 Rec
    				ListMainCategory = ListMainCategory(conn, mainDDL);//08=1 Record
	  			 	rptMainGroupList = ListReportCaseByMainGroup(conn, ListMainCategory,subDDL,itemsDDL, fromDate, toDate, temp_tbtProject,rbtType,type_amt);
	  			 	
	  			 	//Return 1 Rec
	  			 	rptSubsList = ListReportCaseBySubsGroup02(conn, ListMainCategory,subDDL,itemsDDL, fromDate, toDate, temp_tbtProject, rbtType,type_amt);
	  			 	
	  			 	//Return 1 Rec
	  			 	rptItempsList = ListReportCaseByItems(conn, ListMainCategory, itemsDDL,false, fromDate, toDate, temp_tbtProject, rbtType,type_amt);
		  			//System.out.println("77777==========CASE BY PROJECT:TODO :CASE Select 05 Main,0503 Subs,05030001 Display items ======");
		  			break;		
	        	default: //TODO:
	        		  //System.out.println("===xxxxxxxx default xxxxxxxxxxxxx===");
	        	break;
			 } 
			 //*******************************************************************/		  		 
	  		 request.setAttribute("projSelectdList", selProjectList);
	  		 request.setAttribute("rptMainGroupList", rptMainGroupList);
	  		 request.setAttribute("rptSubsList", rptSubsList);
	  		 request.setAttribute("rptItempsList", rptItempsList);
	  		 
	  		 request.setAttribute("arrMainList", listMainGroup);
	  		 request.setAttribute("arrSubsList", arrSubsList);
	  		 request.setAttribute("arrItempsList", arrItempsList);

			 request.setAttribute("fromDate", fromDate);
			 request.setAttribute("toDate",toDate);
			 request.setAttribute("type_amt",type_amt);
			 request.setAttribute("rbtType",rbtType);//LH:075
			 request.setAttribute("multiFlag",multiFlag);//0=ALL
			 //Select criteria

			 request.setAttribute("mainDDL", mainDDL);
			 request.setAttribute("subDDL", subDDL);
			 request.setAttribute("itemsDDL", itemsDDL);
			 request.setAttribute("caseNumber",""+caseNumber);
	   		 //*********Dispatcher  	 
		  	 //System.out.println("doGenerateReport ->successfully.");	  	 	 
		  	 String tarGetUrl ="/SERV_RptTransAfterEnd_02_View.jsp";
		  	
		  	 //String tarGetUrl ="/SERV_ReportBaanINT_View.jsp";
	   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			 dispatcher.forward(request,response);	
			 
			 /****** Clear *******/
			 conn.close();
			 conn = null;
		}catch(Exception e){
			System.out.println("!!! doGenerateReport , " +sysName+":"+ clazzName + " : " + e.getMessage());
			msgTxt = "doGenerateReport , " +sysName+":"+ clazzName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
		}
		finally{			
			//clean up.
			try{
				if(conn!=null){conn.close();}
			}catch(Exception e){}
		}
	}
	 //*****method doFodoGenReportFormrmLoad criteria projectDDL
	protected void doGenReportForm(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		//response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		ServletContext context = getServletContext();
		HttpSession session = request.getSession(false);
		
		//String okPage = "";//Constants.APP_PATH+Constants.SAVE_PAGE;
		//String targetPage ="";//  Constants.APP_PATH+Constants.APP_HOME;
		//String errorCode = "99";	
		USER_ID = user.getUserName();
		String msgTxt = "";// Constants.APP_PATH+Constants.SAVE_PAGE;
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	

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
  			
			String AmmF1 = doString.checkString(request.getParameter("AmmDDL_F1"),getMonthNow());
  			String AyyF1 = doString.checkString(request.getParameter("AyyDDL_F1"),getYearNow()); 
  			String AmmT1 = doString.checkString(request.getParameter("AmmDDL_T1"),getMonthNow());
  			String AyyT1 = doString.checkString(request.getParameter("AyyDDL_T1"),getYearNow()); 
  			
  			String BmmF2 = doString.checkString(request.getParameter("BmmDDL_F2"),getMonthNow());
  			String ByyF2 = doString.checkString(request.getParameter("ByyDDL_F2"),getYearNow()); 
  			String BmmT2 = doString.checkString(request.getParameter("BmmDDL_T2"),getMonthNow());
  			String ByyT2 = doString.checkString(request.getParameter("ByyDDL_T2"),getYearNow()); 

  			String rbtType = doString.checkString(request.getParameter("rbtType"),"A");//A,B 
  			String multiFlag = doString.checkString(request.getParameter("multiFlag"),""); //0,1

	  		/**********************************/
  			String fromDate= "";
  			String toDate ="";
  			if("A".equals(rbtType)){
  				fromDate =  AyyF1+"-"+GenNextId2(Integer.parseInt(AmmF1))+"-01"; //2016-02-01
  				toDate = lastDayOfMonth(Integer.parseInt(AyyT1),Integer.parseInt(AmmT1)); //2016-02-31
  			}else if("B".equals(rbtType)){
  				fromDate = ByyF2+"-"+GenNextId2(Integer.parseInt(BmmF2))+"-01"; //2016-02-01
  				toDate = lastDayOfMonth(Integer.parseInt(ByyT2),Integer.parseInt(BmmT2));//2016-02-31
  			}
  			//System.out.println("======= fromDate :"+fromDate);
  			//System.out.println("======= toDate :"+toDate);

	  		 List  selProjectList= new ArrayList();
	  		 if(multiFlag.equals("0")){//TODO: CASE : ALL Project
	  			selProjectList = new ArrayList();
	  		 }else{//TODO: CASE : By project
	  			 selProjectList = this.ListProjectSelect(conn, projSelDDL);
	  		 }
			 //*******************************************************************/	
	  		 //หมวดหลัก 
	  		 List arrMainList =this.ListMainCategory(conn);
	  		 //หมวดรอง 
	  		 //List arrSubsList = this.ListSubsCategory(conn, "");
	  		 //รายการ
	  		 //List arrItempsList = this.ListItemsCategory(conn, "", "");
	  		 
			 //*******************************************************************/		  		 
	  		 request.setAttribute("projSelectdList", selProjectList);

	  		 request.setAttribute("arrMainList", arrMainList);
	  		 request.setAttribute("arrSubsList", null);
	  		 request.setAttribute("arrItempsList", null);

			 request.setAttribute("fromDate", fromDate);
			 request.setAttribute("toDate",toDate);
			 request.setAttribute("rbtType",rbtType);//LH:075
			 request.setAttribute("multiFlag",multiFlag);//0=ALL
			
	   		//*********Dispatcher  	 
		  	//System.out.println("doGenReportForm ->successfully.");	  	 	 
		  	String tarGetUrl ="/SERV_RptTransAfterEnd_02_View.jsp";

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
	
	//*****method doFodoGenReportFormrmLoad criteria projectDDL
	protected void doFormDescription(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		//response.setContentType("text/html; charset=TIS-620");
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
			/*A=จำนวนรายการ  count(*)
			B=จำนวนเลขที่อ้างอิง / เลขที่ใบเบิก
			C=จำนวนเงิน
			D=จำนวนแปลง*/
            //-------------------------
			String tempProjectTxt = doString.checkString(request.getParameter("tempProjectTxt"),"");//LH:151|LH:152|LH:154|LH:156|LH:157
  			String multiFlag = doString.checkString(request.getParameter("multiFlag"),"0"); //0=ALL Project,1= By project	  
  			String rbtType = doString.checkString(request.getParameter("rbtType"),"A");//A,B
  			String CAT_TYPE =  doString.checkString(request.getParameter("CAT_TYPE"),"01");//01,02,03

  			String groupNo = doString.checkString(request.getParameter("groupNo"),""); 
  			String subNo = doString.checkString(request.getParameter("subNo"),""); 
  			String itemsNo = doString.checkString(request.getParameter("itemsNo"),"");
  			String xid = doString.checkString(request.getParameter("xid"),"0");
  			//String type = doString.checkString(request.getParameter("type"),"0"); 
  			
  			String fromDate = doString.checkString(request.getParameter("fromDate"),""); //2016-05-01
  			String toDate = doString.checkString(request.getParameter("toDate"),""); //2016-05-31		
  			
  			String temp_tbtProject = "temp_proj_"+USER_ID;
  		
  			//boolean isAllProject = true;
  			List  selProjectList = new ArrayList();
  			String projectName = "";
  			
  			if(multiFlag.equals("0")){//TODO: CASE : ALL Project
  				GeneratePreparedIntoTempTableFor$DESC(conn, true, temp_tbtProject, tempProjectTxt);
	  		 }else{//TODO: CASE : By project  			
	        	 /************************************************/
	             //1.Insert project to temp table
	  			GeneratePreparedIntoTempTableFor$DESC(conn, false, temp_tbtProject, tempProjectTxt);		 	
	  			selProjectList = this.ListProjectSelect(conn, tempProjectTxt);
	  		 }//#IF End Check ALL Project
			//*******************************************************************/		  		
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
			ArrayList listDescHD =  this.ListSearchDetails$IPV_QCHD(conn, CAT_TYPE, groupNo, subNo, itemsNo,Integer.parseInt(xid), fromDate, toDate, rbtType, temp_tbtProject);
			//System.out.println(" ========listDescHD : "+listDescHD.size());	
	  		
			//Get Name of GroupNo,subNo,ItemsNo
			String groupName = "";
			String subName = "";
			String itemsName = "";
			
			if(!"".equals(groupNo)){
				List groupList = ListMainCategory(conn, groupNo);
				groupName = GetNameOf$GroupList(groupList);
			}
			if(!"".equals(groupNo)&&!"".equals(subNo) ){
				List gategory = ListSubsCategoryByGroupId$SubsId(conn, groupNo, subNo);
				subName = GetNameOf$GategoryAnd$ItemsList(gategory);
			}
			if(!"".equals(itemsNo)){
				List itemsList = ListItemsByItemsId(conn, itemsNo);
				itemsName = GetNameOf$GategoryAnd$ItemsList(itemsList);
			}
			
			request.setAttribute("listDescHD", listDescHD);
	  		request.setAttribute("projSelectdList", selProjectList);
			request.setAttribute("multiFlag",multiFlag);//0=ALL			 

			request.setAttribute("projectName",projectName);
			request.setAttribute("startDate",fromDate);
			request.setAttribute("endDate",toDate);
			request.setAttribute("rbtType",rbtType);
			request.setAttribute("groupName",groupName);
			request.setAttribute("subName",subName);
			request.setAttribute("itemsName",itemsName);		
	   		//*********Dispatcher  
			/**********************************/
			request.setAttribute("displayLinkPage", pageLink); 
			request.setAttribute("pageNoDDL",pageNoDDL);
			request.setAttribute("displayLine", displayLine);
			request.setAttribute("recordNo", startRow);
		    /************************************/
			//System.out.println(" ========doFormDescription  successfully ========");	
		  	String tarGetUrl ="/SERV_RptTransAfterEnd_03_Desc.jsp";
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

	private void GeneratePreparedIntoTempTable(Connection conn,boolean isALL,String temp_tbtProject,String tempProjectTxt) {
			StringBuffer sql1 = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	        try{
	        	//initial parameter	
	    		/************************************************/
	        	//1.Insert project to temp table
	    		/************************************************/
	  			if(isALL){
	  				this.InsertTempTableProjectALL(conn, temp_tbtProject);
	  			}else{
	        		this.InsertTempTableProject(conn,temp_tbtProject,tempProjectTxt);	
	  			} 
	  			//System.out.println("--Insert temp table OK.");       	
	    		/************************************************/		 
			}catch(Exception e){
				System.out.println("!!!GeneratePreparedIntoTempTable, " +sysName+":"+ clazzName + " : " + e.getMessage());
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
	private void GeneratePreparedIntoTempTableFor$DESC(Connection conn,boolean isALL,String temp_tbtProject,String tempProjectTxt) {
		StringBuffer sql1 = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial parameter	
    		/************************************************/
        	//1.Insert project to temp table
    		/************************************************/
  			if(isALL){
  				this.InsertTempTableProjectALL$ForDesc(conn, temp_tbtProject);
  			}else{
        		this.InsertTempTableProjectFor$DESC(conn,temp_tbtProject,tempProjectTxt);	
  			}     	
    		/************************************************/		 
		}catch(Exception e){
			System.out.println("!!!GeneratePreparedIntoTempTableFor$DESC, " +sysName+":"+ clazzName + " : " + e.getMessage());
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
			    	pstmt.executeBatch();
			    	pstmt.clearBatch();//clear the batch after execution
			    	count = 0;//reset count
		    	}//#End IF
			}		    
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
	private void InsertTempTableProjectALL$ForDesc(Connection conn,String tempTableProject) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial parameter	        
        	String sqlDelete = " Delete "+tempTableProject;
        	//int i=1;
        	//System.out.println("##InsertTempTableProjectALL$ForDesc ->Starting.");        	 
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
	        	//pstmt = conn.prepareStatement(sqlDelete); 
	        	//pstmt.executeUpdate();
	        	//System.out.println("=====Return END=========");
	        	return;
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
			    	pstmt.executeBatch();
			    	pstmt.clearBatch();//clear the batch after execution
			    	count = 0;//reset count
		    	}//#End IF
			}		    
		    pstmt.executeBatch();
			//********************************************************/
		  	//System.out.println("##InsertTempTableProjectALL$ForDesc ->successfully.");				  	 		  	 
		}catch(Exception e){
			System.out.println("!!InsertTempTableProjectALL$ForDesc , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
	private void InsertTempTableProject(Connection conn,String tempTableProject, String tempProjectSelect) {
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
        	if(tempProjectSelect.length()> 0){
        		String []projectArr = tempProjectSelect.split("\\|");             
        		for(int n = 0;n<projectArr.length;n++){
        			temp = projectArr[n].split("\\:");
        			pstmt.setString(1, temp[0]);
     			    pstmt.setString(2, temp[1]);
     			    //pstmt.executeUpdate();
     			    //System.out.println("---Insert Okay :"+n);
     			    pstmt.addBatch();
	  		    	if(++count % batchSize == 0) {
	  		    		 pstmt.executeBatch();
	  		    		 pstmt.clearBatch();//clear the batch after execution
	  		    	     count = 0;//reset count
	  		    	}//#End IF
        		}//#End For
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
	private void InsertTempTableProjectFor$DESC(Connection conn,String tempTableProject, String tempProjectSelect) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial parameter	        
        	String sqlDelete = " Delete "+tempTableProject;
        	//int i=1;
        	//System.out.println("##InsertTempTableProjectFor$DESC ->Starting.");        	 
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
	        	//pstmt = conn.prepareStatement(sqlDelete); 
	        	//pstmt.executeUpdate();
	        	//System.out.println("==========Return End ==============");
        		return;
        	}
        	//insert into tblByProject values( "LH","075" )
			sql.delete(0, sql.length());
			sql.append(" INSERT INTO  "+tempTableProject+"(com_id,proj_id)  VALUES( ? , ? ); ");
			//System.out.println("2.Insert SQL :"+sql.toString());
		    pstmt = conn.prepareStatement(sql.toString()); 
		    
		    String [] temp = null;
		    final int batchSize = 1000;//1000;
		    int count = 0;
        	if(tempProjectSelect.length()> 0){
        		String []projectArr = tempProjectSelect.split("\\|");             
        		for(int n = 0;n<projectArr.length;n++){
        			temp = projectArr[n].split("\\:");
        			pstmt.setString(1, temp[0]);
     			    pstmt.setString(2, temp[1]);
     			    //pstmt.executeUpdate();
     			    //System.out.println("---Insert Okay :"+n);
     			    pstmt.addBatch();
	  		    	if(++count % batchSize == 0) {
	  		    		 pstmt.executeBatch();
	  		    		 pstmt.clearBatch();//clear the batch after execution
	  		    	     count = 0;//reset count
	  		    	}//#End IF
        		}//#End For
    		    pstmt.executeBatch();
        	}
			//********************************************************/
		  	//System.out.println("##InsertTempTableProjectFor$DESC ->successfully.");				  	 		  	 
		}catch(Exception e){
			System.out.println("!!InsertTempTableProjectFor$DESC , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
	

	public ArrayList<List> ListSearchDetails$IPV_QCHD(Connection conn,String CAT_TYPE,String groupNo,String subNo,String itemsNo,int xid,String fromDate,String toDate,String typeRpt,String tempTableName) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial parameter		
        	//int line = 0;
        	//System.out.println("##ListSearchByACSContr$IPV_QCHD->Starting.");   
        	ArrayList<List>  resultList = new ArrayList<List> ();
        	List strArr = null;  
    		sql.delete(0, sql.length());
     		sql.append(" Select   a.i_company,a.i_project,c.i_sort,c.d_close_law as DCLOSE,a.i_docno,a.i_vendor,a.i_ipv_docno,a.i_type,a.f_status,a.c_desc,a.d_keyin as DKEYIN   ")
     		   .append(" ,b.i_in_out,b.i_itmno,b.z_amount_pv,d.date_qc,a.f_qa_type,a.i_qa_vendor  ,c.d_close_law - d.date_qc as diffDay ")
     		   .append(" From lan:ipv_qchd a,lan:ipv_qcdt b,lan:acscontr c,lan:acxlckhd d , "+tempTableName+" x ")
     		   .append(" Where a.i_docno = b.i_qc_docno  ")
     		   .append(" and a.i_project <> '' ")
     		   .append(" and a.i_company =  c.i_company  ")
     		   .append(" and a.i_project =  c.i_project ")
     		   .append(" and a.i_lock =  c.i_sort ")
     		   .append(" and a.i_company =  d.i_company ")
     		   .append(" and a.i_project =  d.i_project ")
     		   .append(" and a.i_lock =  d.i_lock ")
     		   .append(" AND ((a.i_type = '1' and a.i_ipv_docno is not null ) or (a.i_type in ('2','3','4'))) ")
     		   .append(" and a.i_company =  x.com_id  ")
     		   .append(" and a.i_project =  x.proj_id ")
     		   .append(" and c.d_close_law is not null ");
	     		
     		    if("01".equals(CAT_TYPE)){
	     		   sql.append(" and b.i_itmno[1,2] = '"+groupNo+"' ");
	     		}else if("02".equals(CAT_TYPE)){
		     	   sql.append(" and b.i_itmno[1,2] = '"+groupNo+"' ")
		     		  .append(" and b.i_itmno[3,4] = '"+subNo+"' ");
	     		}else if("03".equals(CAT_TYPE)){
	     		    sql.append(" and b.i_itmno = '"+itemsNo+"'   ");
	     		}
	     		if("A".equals(typeRpt)){
 	     			sql.append(" and c.d_close_law  between '"+fromDate+"' and '"+toDate+"' ");
 	     		}else if("B".equals(typeRpt)){
 	     			sql.append(" and date(a.d_keyin)  between '"+fromDate+"' and '"+toDate+"' ");
 	     		}
	     		sql.append(this.GetWhereDiffDate(xid))
     		   .append(" ORDER by  a.i_company,a.i_project,c.i_sort ");
	     	//System.out.println("SQL detail : "+sql.toString());
	     	pstmt = conn.prepareStatement(sql.toString()); 
			rs = pstmt.executeQuery();
			while(rs.next()){
			//for (int i=0;i<maxRow;i++) { 
	        //if (rs.next()) {
	        //if (i>=startRow && i<=endRow) {	
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
		   		strArr.add(13,doString.checkString(rs.getString("i_in_out"),"&nbsp;"));//i_in_out
		   		strArr.add(14,doString.checkString(rs.getString("i_itmno"),"&nbsp;"));//i_itmno
		   		strArr.add(15,doString.checkString(rs.getString("z_amount_pv"),"0.0"));//c_desc
		   		strArr.add(16,"");
		   		if(isValueStrAndObj(rs.getString("i_ipv_docno"))){
		   			strArr.add(16,toDDMMYY_THAI2(this.GetDpayFrom$IPV_PVDHD(conn, rs.getString("i_ipv_docno"))));
		   		}
		   		strArr.add(17,toDDMMYY_THAI2(doString.checkString(rs.getString("date_qc"),"")));//date_qc
		   		strArr.add(18,doString.checkString(rs.getString("diffDay"),""));//diffDay
		   		
	   			strArr.add(19, doString.checkString(rs.getString("f_qa_type"),""));//null,1,2
	   			if(isValueStrAndObj(rs.getString("f_qa_type"))){
	   				strArr.add(20,"&nbsp;");
	   				if(doString.checkString(rs.getString("f_qa_type"),"").equals("2") && isValueStrAndObj(rs.getString("i_qa_vendor"))){
		   				strArr.add(20,GetVendorNameQA(conn,doString.checkString(rs.getString("i_qa_vendor"),"")));
	   				}
	   			}else{
	   				strArr.add(20,"&nbsp;");
	   			}
		   		resultList.add(strArr);	
			    //line++;                         
	            //} //--end if check row
		        //if (i>endRow){ 
		        //break;
		        //}
	            //} //end if check rs
		    } // end for
			//********************************************************/	
			//System.out.println(" ========Successfully=========== ");	
        	return resultList;			  	 
		}catch(Exception e){
			System.out.println("!!!ListSearchDetails$IPV_QCHD , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
	
	//typeRpt=A=d_close_law,B=d_keyin
	//type_amt=A,B,C,D
	public  List  ListReportCaseByMainGroup(Connection conn,List listMainGroup,String subDDL,String itemDDL,String fromDate,String toDate,String tempTableName,String typeRpt,String type_amt){ 
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
 	  			String []STR_MATRIX = null;
 	            //------------------- 		
 	  		    //System.out.println("===1. MainGroup ===");
 	  			if(listMainGroup!=null && listMainGroup.size()>0){	
 	  				HashMap hashMap = null;	
 	  				//int Loop = 0;
 	  				for (int i = 0; i < listMainGroup.size(); i++) {
 	  					 hashMap = (HashMap)listMainGroup.get(i);
 	  					 //--------------------------------------
 	 	        		 tempMatrix = new String[MAX_COLUMN]; //Asign Array 19 column
 	 	        		 for (int n=0; n < MAX_COLUMN; n++) {
 	 	        			tempMatrix[n] = "";//Allocate a values in row&coulumn	
 	 	        			if(n>0){
 	 	        				tempMatrix[n] = "0";//Allocate a values in row&coulumn	
 	 	        			}
 	 	 	    		}//#End For  
  	 	        		if(type_amt.equals(C_STATUS)){
 	 	 	  				STR_MATRIX = new String[13];
 	 	 	  				for(int x = 0;x<STR_MATRIX.length;x++){
 	 	 	  					STR_MATRIX[x] = "0"; //Allocate a values in row&column 
	  	 	     			}
 	 	 	  			}else{
 	  	 	        		CNT_MATRIX = new int[13]; //15 column
 	  	 	     			for(int x = 0;x<CNT_MATRIX.length;x++){
 	  	 	     				CNT_MATRIX[x] = 0; //Allocate a values in row&column 
 	  	 	     			}
 	 	 	  			}
 	  					//--------------------------------------
 	 	        		tempMatrix[0] = doString.checkString(hashMap.get("f_in_out").toString(),"");//f_in_out
 	 	        		tempMatrix[1] = doString.checkString(hashMap.get("i_group").toString(),"");//i_group: mainGroup
 	 	        		tempMatrix[2] = doString.checkString("","");//i_itmjob : Sub
 	 	        		tempMatrix[3] = doString.checkString("","");//i_itmjob : items
 	 	        		tempMatrix[4] = doString.checkString(hashMap.get("n_itmjob").toString(),"");//n_itemjob

 	 	     			sqlFetch.delete(0, sqlFetch.length());
 	 	     			if(type_amt.equals("A")){
 	 	 	     			sqlFetch.append(" Select b.i_itmno[1,2],count(*) as cnt  ");
 	 	     			}else if(type_amt.equals("B")){
 	 	     				sqlFetch.append(" Select b.i_itmno[1,2],count(DISTINCT a.i_docno) as cnt  ");
 	 	     			}else if(type_amt.equals(C_STATUS)){//z_amount_pv
 	 	     				sqlFetch.append(" Select b.i_itmno[1,2],sum(b.z_amount_pv) as sumAmount  ");
 	 	     			}
 	 	     			
 	 	     			if(type_amt.equals(D_STATUS)){
 	 	     				sqlFetch.append("  Select itmno12,count(distinct xid) as cnt ")
	 	 	     				 .append(",(CASE ")
		 	     			     .append(" when diffday <= 30  then  30 ") 
		 	     			     .append(" when diffday <= 60  then  60 ")
		 	     			 	 .append(" when diffday <= 90  then  90 ")
		 	     			     .append(" when diffday <= 120  then  120 ") 
		 	     			     .append(" when diffday <= 150  then  150 ") 
		 	     			     .append(" when diffday <= 180  then  180 ") 
		 	     			     .append(" when diffday <= 210  then  210 ") 
		 	     			     .append(" when diffday <= 240  then  240 ")
		 	     			     .append(" when diffday <= 270  then  270 ")
		 	     			     .append(" when diffday <= 300  then  300 ")
		 	     			     .append(" when diffday <= 330  then  330 ")
		 	     			     .append(" when diffday <= 360  then  360 ")
		 	     			     .append(" when diffday  > 360  then  999 ")
		 	 	     			 .append(" ELSE 0 END ")
		 	 	     			 .append(" ) as type2 ")
		 	 	     			 .append(" From( ")
 	 	     			 		 .append(" Select distinct a.i_company||a.i_project||a.i_lock as xid,b.i_itmno[1,2] as itmno12 ")
 	 	     			 		 .append(" ,c.d_close_law - d.date_qc as diffDay ") 
 	 	     					 .append(" From lan:ipv_qchd a,lan:ipv_qcdt b,lan:acscontr c,lan:acxlckhd d , "+tempTableName+" x    ")       
		 	 	     			 .append(" Where a.i_docno = b.i_qc_docno  ")                                               
		 	 	     			 .append(" and a.i_project <> ''   ")                                                    
		 	 	     			 .append(" and a.i_company =  c.i_company ")                                                
		 	 	     			 .append(" and a.i_project =  c.i_project ")                                                
		 	 	     			 .append(" and a.i_lock =  c.i_sort     ")                                                  
		 	 	     			 .append(" and a.i_company =  d.i_company ")                                               
		 	 	     			 .append(" and a.i_project =  d.i_project ")                                                
		 	 	     			 .append(" and a.i_lock =  d.i_lock ")
		 	 	     			 .append(" and a.f_status <> 'CAN' ")
		 	 	     			 .append(" AND ((a.i_type = '1' and a.i_ipv_docno is not null ) or (a.i_type in ('2','3','4'))) ")
		 	 	     			 .append(" and a.i_company =  x.com_id   ")                                            
		 	 	     			 .append(" and a.i_project =  x.proj_id  ")                                                                                                 
		 	 	     			 .append(" and c.d_close_law is not null ");
	 	 	     		     	 if(!"".equals(itemDDL)){ //CASE : itemDDL
	 	 	     					sqlFetch.append(" and b.i_itmno = '"+itemDDL+"'   ");
	 	 	     				 }else if(!"".equals(subDDL)){ //CASE : Sub
	 	 	     					sqlFetch.append(" and b.i_itmno[1,4] = '"+doString.checkString(hashMap.get("i_group").toString(),"")+subDDL+"'   ");
	 	 	     				 }else{//CASE: Main
	 	 	     					sqlFetch.append(" and b.i_itmno[1,2] = '"+doString.checkString(hashMap.get("i_group").toString(),"")+"'   "); 
	 	 	     				 }
 	 	     					 
		 	 	     			if("A".equals(typeRpt)){
		 	 	     				sqlFetch.append(" and c.d_close_law  between '"+fromDate+"' and '"+toDate+"' ");
		 	 	     			}else if("B".equals(typeRpt)){
		 	 	     				sqlFetch.append(" and date(a.d_keyin)  between '"+fromDate+"' and '"+toDate+"' ");
		 	 	     			}
		 	 	     			sqlFetch.append(" Group by 1,2,3    ") 
 	 	     					 .append(" Order by  1,2,3 ")		
 	 	     					 .append(" ) as xtable ")
 	 	     					 .append(" Group by 1,type2 ")
 	 	     					 .append(" Order by 1,type2 ");
 	 	     			}else{
 	 	 	     			sqlFetch.append(",(CASE ")
		 	     			     .append(" when c.d_close_law - d.date_qc <= 30  then  30 ") 
		 	     			     .append(" when c.d_close_law - d.date_qc <= 60  then  60 ")
		 	     			 	 .append(" when c.d_close_law - d.date_qc <= 90  then  90 ")
		 	     			     .append(" when c.d_close_law - d.date_qc <= 120  then  120 ") 
		 	     			     .append(" when c.d_close_law - d.date_qc <= 150  then  150 ") 
		 	     			     .append(" when c.d_close_law - d.date_qc <= 180  then  180 ") 
		 	     			     .append(" when c.d_close_law - d.date_qc <= 210  then  210 ") 
		 	     			     .append(" when c.d_close_law - d.date_qc <= 240  then  240 ")
		 	     			     .append(" when c.d_close_law - d.date_qc <= 270  then  270 ")
		 	     			     .append(" when c.d_close_law - d.date_qc <= 300  then  300 ")
		 	     			     .append(" when c.d_close_law - d.date_qc <= 330  then  330 ")
		 	     			     .append(" when c.d_close_law - d.date_qc <= 360  then  360 ")
		 	     			     .append(" when c.d_close_law - d.date_qc  > 360  then  999 ")
		 	 	     			 .append(" ELSE 0 END ")
		 	 	     			 .append(" ) as type2 ")
	 	 	 	     			 .append(" From lan:ipv_qchd a,lan:ipv_qcdt b,lan:acscontr c,lan:acxlckhd d , "+tempTableName+" x    ")       
		 	 	     			 .append(" Where a.i_docno = b.i_qc_docno  ")                                               
		 	 	     			 .append(" and a.i_project <> ''   ")                                                    
		 	 	     			 .append(" and a.i_company =  c.i_company ")                                                
		 	 	     			 .append(" and a.i_project =  c.i_project ")                                                
		 	 	     			 .append(" and a.i_lock =  c.i_sort     ")                                                  
		 	 	     			 .append(" and a.i_company =  d.i_company  ")                                               
		 	 	     			 .append(" and a.i_project =  d.i_project ")                                                
		 	 	     			 .append(" and a.i_lock =  d.i_lock ")
		 	 	     			 .append(" AND ((a.i_type = '1' and a.i_ipv_docno is not null ) or (a.i_type in ('2','3','4'))) ")
		 	 	     			 .append(" and a.i_company =  x.com_id    ")                                            
		 	 	     			 .append(" and a.i_project =  x.proj_id  ")  
		 	 	     			 .append(" and a.f_status <> 'CAN' ")
		 	 	     			 .append(" and c.d_close_law is not null  "); 
		 	 	     		     if(!"".equals(itemDDL)){ //CASE : itemDDL
		 	 	     		    	sqlFetch.append(" and b.i_itmno = '"+itemDDL+"'   ");
	 	 	     				 }else if(!"".equals(subDDL)){ //CASE : Sub
	 	 	     					sqlFetch.append(" and b.i_itmno[1,4] = '"+doString.checkString(hashMap.get("i_group").toString(),"")+subDDL+"'   ");
	 	 	     				 }else{//CASE: Main
	 	 	     					sqlFetch.append(" and b.i_itmno[1,2] = '"+doString.checkString(hashMap.get("i_group").toString(),"")+"'   "); 
	 	 	     				 }
		 	 	     		    
		 	 	     			if("A".equals(typeRpt)){
		 	 	     				sqlFetch.append(" and c.d_close_law  between '"+fromDate+"' and '"+toDate+"' ");
		 	 	     			}else if("B".equals(typeRpt)){
		 	 	     				sqlFetch.append(" and date(a.d_keyin)  between '"+fromDate+"' and '"+toDate+"' ");
		 	 	     			}
		 	 	     			sqlFetch.append(" Group by 1,type2    ")                                                       
		 	 	     				.append(" Order by 1,type2	 "); 
 	 	     			}
 	 	     			
 	 	     			//if(i==1){
 	 	     			//System.out.println(" SQL Get data By ALL Main :"+sqlFetch.toString());
 	 	     			//}
 		    			pstmt = conn.prepareStatement(sqlFetch.toString()); 
 					    //pstmt.setString(1,doString.checkString(hashMap.get("i_group").toString(),""));//i_group
 			 	        rs = pstmt.executeQuery();	
 			 	        int code = 0;
 	 	        		while(rs.next()){
 	 	        			code = 0;
 	 	        			code = rs.getInt("type2");
 	 	        			//System.out.println("== code : "+code);
 	 	        			switch (code) {
 		 	        			case 30: //5
 		 	        				if(C_STATUS.equals(type_amt)){
 		 	        				   STR_MATRIX[0] = rs.getString("sumAmount");
 		 	        				}else{
 	 		 	        			   CNT_MATRIX[0] +=rs.getInt("cnt");
 		 	        				}
 		 	        				break;
 		 	        			case 60://6
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[1] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[1] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 90://7
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[2] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[2] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 120://8
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[3] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[3] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 150://9
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[4] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[4] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 180://10
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[5] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[5] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 210://11
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[6] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[6] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 240://12
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[7] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[7] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 270://13
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[8] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[8] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 300://14
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[9] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[9] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 330://15
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[10] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[10] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 360://16
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[11] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[11] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 999://17	
 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				STR_MATRIX[12] = rs.getString("sumAmount");
	  		 	        			}else{
	  	 		 	        			CNT_MATRIX[12] +=rs.getInt("cnt");
	  		 	        			}
 		 	        				break;
 		 	        			default:
	 		 	        			//System.out.println("===CNT_MATRIX Unknown result===");
 		 	        	            break;
 		 	        			}//#End Switch Case	 	        			
 		 	        	}//#End while loop
 	 	        		//----------------------------------
 	 	        		int Loop = 5;
 	 	        		if(type_amt.equals(C_STATUS)){
 	 	 	        		for(int x = 0;x<STR_MATRIX.length;x++){
 	 	 	        		  tempMatrix[Loop++] = STR_MATRIX[x];
 	 	 	        		}
 	 	        		}else{
 	 	 	        		//System.out.println("===CNT_MATRIX=== :"+CNT_MATRIX.length);
 	 	 	        		//System.out.println("===tempMatrix===:"+tempMatrix.length);
 	 	 	        		for(int x = 0;x<CNT_MATRIX.length;x++){
 	 	 	        			tempMatrix[Loop++] = ""+CNT_MATRIX[x];
 	 	 	        		}
 	 	        		}
 	 	        		//System.out.println("===rrrrrrrrrrrrrr===");
 	 	        		/* Mapping MATRIX for view to html */
 	  					objListResult.add(tempMatrix);
 	  				}//#End For
 	  			}//#End Check size or null ArrayList

 	     	    //---#End ---/
 			  	return objListResult;			  	 
 			}catch(Exception e){
 				System.err.println("!!!ListReportCaseByMainGroup, " +sysName+":"+ clazzName + " : " + e.getMessage());
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
	
	public  List  ListReportCaseBySubsGroup01(Connection conn,List listMainGroup,String fromDate,String toDate,String tempTableName,String typeRpt,String type_amt){ 
		StringBuffer sqlFetch = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try{
        	List objListResult= new ArrayList();
        	List objSubsList = null;
  			//-----------------
  			String []tempMatrix = null;
  			int [] CNT_MATRIX = null;//new int[15];
  			String []STR_MATRIX = null;
  			int MAX_COLUMN =  19 ;//COLUMN_TRANSFER.length+4; //Asign Array 19 column ,id,prefix,name,lname,0,0,0,...n
            //------------------- 			
  			
  			if(listMainGroup!=null && listMainGroup.size()>0){	
  				HashMap hashMap = null;	
  				HashMap hashMapSub = null;	
  				//int Loop = 0;
  				for (int i = 0; i < listMainGroup.size(); i++) {
  					 hashMap = (HashMap)listMainGroup.get(i);
 	        		//--------------------------------------
 	        		objSubsList = null;
 	        		objSubsList = ListSubsCategoryByGroupId(conn, doString.checkString(hashMap.get("i_group").toString(),""));
 	        		//System.out.println(i+",xxxxx=== objSubsList :"+objSubsList.size());
 	        		
 	        		if(objSubsList!=null && objSubsList.size()>0){
 	        			
 	        			for (int s = 0; s < objSubsList.size(); s++) {
 	        				hashMapSub = (HashMap)objSubsList.get(s);
 	        				//--------------------------------------Sub
 		 	        		 tempMatrix = new String[MAX_COLUMN]; //Asign Array 19 column
 		 	        		 for (int n=0; n < MAX_COLUMN; n++) {
 		 	        			tempMatrix[n] = "";//Allocate a values in row&coulumn	
 		 	        			if(n>0){
 		 	        				tempMatrix[n] = "0";//Allocate a values in row&coulumn	
 		 	        			}
 		 	 	    		}//#End For  

  		 	        		//--------------------------------------
  	  	 	        		if(type_amt.equals(C_STATUS)){
  	 	 	 	  				STR_MATRIX = new String[13];
  	 	 	 	  				for(int x = 0;x<STR_MATRIX.length;x++){
  	 	 	 	  					STR_MATRIX[x] = "0"; //Allocate a values in row&column 
  		  	 	     			}
  	 	 	 	  			}else{
  	 	  	 	        		CNT_MATRIX = new int[13]; //15 column
  	 	  	 	     			for(int x = 0;x<CNT_MATRIX.length;x++){
  	 	  	 	     				CNT_MATRIX[x] = 0; //Allocate a values in row&column 
  	 	  	 	     			}
  	 	 	 	  			}
 		  					//--------------------------------------Group
 	        				tempMatrix[0] = doString.checkString(hashMap.get("f_in_out").toString(),"");//f_in_out
 	        				tempMatrix[1] = doString.checkString(hashMapSub.get("x_group").toString(),"");//i_group: mainGroup
 	        				tempMatrix[2] = doString.checkString(hashMapSub.get("x_type").toString(),"");//i_itmjob : Sub
 		 	        		tempMatrix[3] = doString.checkString(hashMapSub.get("x_itmjob").toString(),"");//i_itmjob : items
 		 	        		tempMatrix[4] = doString.checkString(hashMapSub.get("xname_itmjob").toString(),"");//n_itmjob

 		 	     			sqlFetch.delete(0, sqlFetch.length());
 		 	     			//sqlFetch.append(" Select b.i_itmno[1,4],count(b.i_qc_docno) as cnt  ")
 		 	     			if(type_amt.equals("A")){
 	 	 	 	     			sqlFetch.append(" Select b.i_itmno[1,4],count(*) as cnt  ");
 	 	 	     			}else if(type_amt.equals("B")){
 	 	 	     				sqlFetch.append(" Select b.i_itmno[1,4],count(DISTINCT a.i_docno) as cnt  ");
 	 	 	     			}else if(type_amt.equals(C_STATUS)){//z_amount_pv
 	 	 	     				sqlFetch.append(" Select b.i_itmno[1,4],sum(b.z_amount_pv) as sumAmount  ");
 	 	 	     			}
 	 	 	     			
 		 	     			if(type_amt.equals(D_STATUS)){
 	 	 	     				sqlFetch.append("  Select itmno14,count(distinct xid) as cnt ")
 		 	 	     				 .append(",(CASE ")
 			 	     			     .append(" when diffday <= 30  then  30 ") 
 			 	     			     .append(" when diffday <= 60  then  60 ")
 			 	     			 	 .append(" when diffday <= 90  then  90 ")
 			 	     			     .append(" when diffday <= 120  then  120 ") 
 			 	     			     .append(" when diffday <= 150  then  150 ") 
 			 	     			     .append(" when diffday <= 180  then  180 ") 
 			 	     			     .append(" when diffday <= 210  then  210 ") 
 			 	     			     .append(" when diffday <= 240  then  240 ")
 			 	     			     .append(" when diffday <= 270  then  270 ")
 			 	     			     .append(" when diffday <= 300  then  300 ")
 			 	     			     .append(" when diffday <= 330  then  330 ")
 			 	     			     .append(" when diffday <= 360  then  360 ")
 			 	     			     .append(" when diffday  > 360  then  999 ")
 			 	 	     			 .append(" ELSE 0 END ")
 			 	 	     			 .append(" ) as type2 ")
 			 	 	     			 .append(" From( ")
 	 	 	     			 		 .append(" Select distinct a.i_company||a.i_project||a.i_lock as xid,b.i_itmno[1,4] as itmno14 ")
 	 	 	     			 		 .append(" ,c.d_close_law - d.date_qc as diffDay ") 
 	 	 	     					 .append(" From lan:ipv_qchd a,lan:ipv_qcdt b,lan:acscontr c,lan:acxlckhd d , "+tempTableName+" x    ")       
 			 	 	     			 .append(" Where a.i_docno = b.i_qc_docno  ")                                               
 			 	 	     			 .append(" and a.i_project <> ''   ")                                                    
 			 	 	     			 .append(" and a.i_company =  c.i_company ")                                                
 			 	 	     			 .append(" and a.i_project =  c.i_project ")                                                
 			 	 	     			 .append(" and a.i_lock =  c.i_sort     ")                                                  
 			 	 	     			 .append(" and a.i_company =  d.i_company ")                                               
 			 	 	     			 .append(" and a.i_project =  d.i_project ")                                                
 			 	 	     			 .append(" and a.i_lock =  d.i_lock ")
 			 	 	     			 .append(" AND ((a.i_type = '1' and a.i_ipv_docno is not null ) or (a.i_type in ('2','3','4'))) ")
 			 	 	     			 .append(" and a.i_company =  x.com_id   ")                                            
 			 	 	     			 .append(" and a.i_project =  x.proj_id  ")                                                                                                 
 			 	 	     			 .append(" and c.d_close_law is not null ") 
 			 	 	     			 .append(" and a.f_status <> 'CAN' ")
 			 	 	     			 .append(" and b.i_itmno[1,2] = '"+doString.checkString(hashMapSub.get("x_group").toString(),"")+"'   ")
 			 	 	     			 .append(" and b.i_itmno[3,4] = '"+doString.checkString(hashMapSub.get("x_type").toString(),"")+"'   ");
 			 	 	     			if("A".equals(typeRpt)){
 			 	 	     				sqlFetch.append(" and c.d_close_law  between '"+fromDate+"' and '"+toDate+"' ");
 			 	 	     			}else if("B".equals(typeRpt)){
 			 	 	     				sqlFetch.append(" and date(a.d_keyin)  between '"+fromDate+"' and '"+toDate+"' ");
 			 	 	     			}
 			 	 	     			sqlFetch.append(" Group by 1,2,3    ") 
 	 	 	     					 .append(" Order by  1,2,3 ")		
 	 	 	     					 .append(" ) as xtable ")
 	 	 	     					 .append(" Group by 1,type2 ")
 	 	 	     					 .append(" Order by 1,type2 ");
 	 	 	     			}else{
 	 	 	 	     			sqlFetch.append(",(CASE ")
 			 	     			     .append(" when c.d_close_law - d.date_qc <= 30  then  30 ") 
 			 	     			     .append(" when c.d_close_law - d.date_qc <= 60  then  60 ")
 			 	     			 	 .append(" when c.d_close_law - d.date_qc <= 90  then  90 ")
 			 	     			     .append(" when c.d_close_law - d.date_qc <= 120  then  120 ") 
 			 	     			     .append(" when c.d_close_law - d.date_qc <= 150  then  150 ") 
 			 	     			     .append(" when c.d_close_law - d.date_qc <= 180  then  180 ") 
 			 	     			     .append(" when c.d_close_law - d.date_qc <= 210  then  210 ") 
 			 	     			     .append(" when c.d_close_law - d.date_qc <= 240  then  240 ")
 			 	     			     .append(" when c.d_close_law - d.date_qc <= 270  then  270 ")
 			 	     			     .append(" when c.d_close_law - d.date_qc <= 300  then  300 ")
 			 	     			     .append(" when c.d_close_law - d.date_qc <= 330  then  330 ")
 			 	     			     .append(" when c.d_close_law - d.date_qc <= 360  then  360 ")
 			 	     			     .append(" when c.d_close_law - d.date_qc  > 360  then  999 ")
 			 	 	     			 .append(" ELSE 0 END ")
 			 	 	     			 .append(" ) as type2 ")
 		 	 	 	     			 .append(" From lan:ipv_qchd a,lan:ipv_qcdt b,lan:acscontr c,lan:acxlckhd d , "+tempTableName+" x    ")       
 			 	 	     			 .append(" Where a.i_docno = b.i_qc_docno  ")                                               
 			 	 	     			 .append(" and a.i_project <> ''   ")                                                    
 			 	 	     			 .append(" and a.i_company =  c.i_company ")                                                
 			 	 	     			 .append(" and a.i_project =  c.i_project ")                                                
 			 	 	     			 .append(" and a.i_lock =  c.i_sort     ")                                                  
 			 	 	     			 .append(" and a.i_company =  d.i_company  ")                                               
 			 	 	     			 .append(" and a.i_project =  d.i_project ")                                                
 			 	 	     			 .append(" and a.i_lock =  d.i_lock ")
 			 	 	     			 .append(" AND ((a.i_type = '1' and a.i_ipv_docno is not null ) or (a.i_type in ('2','3','4'))) ")
 			 	 	     			 .append(" and a.i_company =  x.com_id    ")                                            
 			 	 	     			 .append(" and a.i_project =  x.proj_id  ")   
 			 	 	     			 .append(" and a.f_status <> 'CAN' ")
 			 	 	     			 .append(" and c.d_close_law is not null  ") 
 			 	 	     			 .append(" and b.i_itmno[1,2] = '"+doString.checkString(hashMapSub.get("x_group").toString(),"")+"'   ")
 			 	 	     			 .append(" and b.i_itmno[3,4] = '"+doString.checkString(hashMapSub.get("x_type").toString(),"")+"'   ");
 			 	 	     			if("A".equals(typeRpt)){
 			 	 	     				sqlFetch.append(" and c.d_close_law  between '"+fromDate+"' and '"+toDate+"' ");
 			 	 	     			}else if("B".equals(typeRpt)){
 			 	 	     				sqlFetch.append(" and date(a.d_keyin)  between '"+fromDate+"' and '"+toDate+"' ");
 			 	 	     			}
 			 	 	     		sqlFetch.append(" Group by 1,type2    ")                                                       
 			 	 	     				.append(" Order by 1,type2	 "); 
 	 	 	     			}

 			    			//System.out.println(" SQL Get data By ALL Subs :"+sqlFetch.toString());
 			    			pstmt = conn.prepareStatement(sqlFetch.toString()); 
 						    //pstmt.setString(1,doString.checkString(hashMap.get("i_group").toString(),""));//i_group
 				 	        rs = pstmt.executeQuery();	
 				 	       
 				 	        int code = 0;
 		 	        		while(rs.next()){
 		 	        			code = 0;
 		 	        			code = rs.getInt("type2");
 		 	        			//System.out.println("== code : "+code);
 	 	 	        			switch (code) {
 		 	        			case 30: //5
 		 	        				if(C_STATUS.equals(type_amt)){
 		 	        				   STR_MATRIX[0] = rs.getString("sumAmount");
 		 	        				}else{
 	 		 	        			   CNT_MATRIX[0] +=rs.getInt("cnt");
 		 	        				}
 		 	        				break;
 		 	        			case 60://6
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[1] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[1] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 90://7
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[2] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[2] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 120://8
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[3] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[3] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 150://9
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[4] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[4] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 180://10
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[5] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[5] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 210://11
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[6] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[6] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 240://12
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[7] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[7] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 270://13
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[8] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[8] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 300://14
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[9] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[9] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 330://15
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[10] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[10] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 360://16
 		 	        				if(C_STATUS.equals(type_amt)){
  		 	        				   STR_MATRIX[11] = rs.getString("sumAmount");
  		 	        				}else{
  	 		 	        			   CNT_MATRIX[11] +=rs.getInt("cnt");
  		 	        				}
 		 	        				break;
 		 	        			case 999://17	
 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				STR_MATRIX[12] = rs.getString("sumAmount");
	  		 	        			}else{
	  	 		 	        			CNT_MATRIX[12] +=rs.getInt("cnt");
	  		 	        			}
 		 	        				break;	
 		 	        		   default:
	 		 	        			//System.out.println("===CNT_MATRIX Unknown result===");
 		 	        	            break;
 		 	        		    }//#End Switch Case
 		 	        		}//#End while loop
 		 	        		//----------------------------------
 	 	 	        		int Loop = 5;
 	 	 	        		if(type_amt.equals(C_STATUS)){
 	 	 	 	        		for(int x = 0;x<STR_MATRIX.length;x++){
 	 	 	 	        		  tempMatrix[Loop++] = STR_MATRIX[x];
 	 	 	 	        		}
 	 	 	        		}else{
 	 	 	 	        		//System.out.println("===CNT_MATRIX=== :"+CNT_MATRIX.length);
 	 	 	 	        		//System.out.println("===tempMatrix===:"+tempMatrix.length);
 	 	 	 	        		for(int x = 0;x<CNT_MATRIX.length;x++){
 	 	 	 	        			tempMatrix[Loop++] = ""+CNT_MATRIX[x];
 	 	 	 	        		}
 	 	 	        		}
 		 	        		/* Mapping MATRIX for view to html */
 		  					objListResult.add(tempMatrix);
 	        			}//#for Sub
 	        		}//#End for objSubsList	 
  				}//#End For listMainGroup
  			}//#End Check size or null ArrayList

     	    //---#End ---/
		  	return objListResult;			  	 
		}catch(Exception e){
			System.err.println("!!!ListReportCaseBySubsGroup01, " +sysName+":"+ clazzName + " : " + e.getMessage());
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
	
	//ListGrupMain=1,ListSubsGate=1,No dis items
	public  List  ListReportCaseBySubsGroup02(Connection conn,List listMainGroup,String subId,String itemsDDL,String fromDate,String toDate,String tempTableName
			,String typeRpt,String type_amt){ 
			StringBuffer sqlFetch = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			try{
	        	List objListResult= new ArrayList();
	        	List objSubsList = null;
	  			//-----------------
	  			String []tempMatrix = null;
	  			int [] CNT_MATRIX = null;//new int[15];
	  			String []STR_MATRIX = null;
	  			int MAX_COLUMN =  19 ;//COLUMN_TRANSFER.length+4; //Asign Array 19 column ,id,prefix,name,lname,0,0,0,...n
	            //------------------- 			
	  			//System.out.println("========= 66666 ===== : ListReportCaseBySubsGroup02 ");
	  			if(listMainGroup!=null && listMainGroup.size()>0){	
	  				HashMap hashMap = null;	
	  				HashMap hashMapSub = null;	
	  				//int Loop = 0;
	  				for (int i = 0; i < listMainGroup.size(); i++) {
	  					hashMap = (HashMap)listMainGroup.get(i);
	 	        		//--------------------------------------
	 	        		objSubsList = null;
	 	        		objSubsList = ListSubsCategoryByGroupId$SubsId(conn, doString.checkString(hashMap.get("i_group").toString(),""),subId);
	 	        		//System.out.println(i+",66666=== objSubsList :"+objSubsList.size());
	 	        		
	 	        		if(objSubsList!=null && objSubsList.size()>0){
	 	        			for (int s = 0; s < objSubsList.size(); s++) {
	 	        				hashMapSub = (HashMap)objSubsList.get(s);
	 	        				//--------------------------------------Sub
	 		 	        		tempMatrix = new String[MAX_COLUMN]; //Asign Array 19 column
	 		 	        		for (int n=0; n < MAX_COLUMN; n++) {
	 		 	        			tempMatrix[n] = "";//Allocate a values in row&coulumn	
	 		 	        			if(n>0){
	 		 	        				tempMatrix[n] = "0";//Allocate a values in row&coulumn	
	 		 	        			}
	 		 	 	    		}//#End For  
	 		 	        		 
		 		 	        	//--------------------------------------
		 	  	 	        	if(type_amt.equals(C_STATUS)){
		 	 	 	 	  			STR_MATRIX = new String[13];
		 	 	 	 	  			for(int x = 0;x<STR_MATRIX.length;x++){
		 	 	 	 	  				STR_MATRIX[x] = "0"; //Allocate a values in row&column 
		 		  	 	     		}
		 	 	 	 	  		}else{
		 	 	  	 	        	CNT_MATRIX = new int[13]; //15 column
		 	 	  	 	     		for(int x = 0;x<CNT_MATRIX.length;x++){
		 	 	  	 	     			CNT_MATRIX[x] = 0; //Allocate a values in row&column 
		 	 	  	 	     		}
		 	 	 	 	  		}
		 		 	        	//--------------------------------------	
		 	  	 	        	
	 		  					//--------------------------------------Group
	 	        				tempMatrix[0] = doString.checkString(hashMap.get("f_in_out").toString(),"");//f_in_out
	 	        				tempMatrix[1] = doString.checkString(hashMapSub.get("x_group").toString(),"");//i_group: mainGroup
	 	        				tempMatrix[2] = doString.checkString(hashMapSub.get("x_type").toString(),"");//i_itmjob : Sub
	 		 	        		tempMatrix[3] = doString.checkString(hashMapSub.get("x_itmjob").toString(),"");//i_itmjob : items
	 		 	        		tempMatrix[4] = doString.checkString(hashMapSub.get("xname_itmjob").toString(),"");//n_itmjob

	 		 	     			sqlFetch.delete(0, sqlFetch.length());
	 		 	     			//sqlFetch.append(" Select b.i_itmno[1,4],count(b.i_qc_docno) as cnt  ")
	 		 	     			if(type_amt.equals("A")){
	 	 	 	 	     			sqlFetch.append(" Select b.i_itmno[1,4],count(*) as cnt  ");
	 	 	 	     			}else if(type_amt.equals("B")){
	 	 	 	     				sqlFetch.append(" Select b.i_itmno[1,4],count(DISTINCT a.i_docno) as cnt  ");
	 	 	 	     			}else if(type_amt.equals(C_STATUS)){//z_amount_pv
	 	 	 	     				sqlFetch.append(" Select b.i_itmno[1,4],sum(b.z_amount_pv) as sumAmount  ");
	 	 	 	     			}
	 		 	     			
			 	     			if(type_amt.equals(D_STATUS)){
	 	 	 	     				sqlFetch.append("  Select itmno14,count(distinct xid) as cnt ")
	 		 	 	     				 .append(",(CASE ")
	 			 	     			     .append(" when diffday <= 30  then  30 ") 
	 			 	     			     .append(" when diffday <= 60  then  60 ")
	 			 	     			 	 .append(" when diffday <= 90  then  90 ")
	 			 	     			     .append(" when diffday <= 120  then  120 ") 
	 			 	     			     .append(" when diffday <= 150  then  150 ") 
	 			 	     			     .append(" when diffday <= 180  then  180 ") 
	 			 	     			     .append(" when diffday <= 210  then  210 ") 
	 			 	     			     .append(" when diffday <= 240  then  240 ")
	 			 	     			     .append(" when diffday <= 270  then  270 ")
	 			 	     			     .append(" when diffday <= 300  then  300 ")
	 			 	     			     .append(" when diffday <= 330  then  330 ")
	 			 	     			     .append(" when diffday <= 360  then  360 ")
	 			 	     			     .append(" when diffday  > 360  then  999 ")
	 			 	 	     			 .append(" ELSE 0 END ")
	 			 	 	     			 .append(" ) as type2 ")
	 			 	 	     			 .append(" From( ")
	 	 	 	     			 		 .append(" Select distinct a.i_company||a.i_project||a.i_lock as xid,b.i_itmno[1,4] as itmno14 ")
	 	 	 	     			 		 .append(" ,c.d_close_law - d.date_qc as diffDay ") 
	 	 	 	     					 .append(" From lan:ipv_qchd a,lan:ipv_qcdt b,lan:acscontr c,lan:acxlckhd d , "+tempTableName+" x    ")       
	 			 	 	     			 .append(" Where a.i_docno = b.i_qc_docno  ")                                               
	 			 	 	     			 .append(" and a.i_project <> ''   ")                                                    
	 			 	 	     			 .append(" and a.i_company =  c.i_company ")                                                
	 			 	 	     			 .append(" and a.i_project =  c.i_project ")                                                
	 			 	 	     			 .append(" and a.i_lock =  c.i_sort     ")                                                  
	 			 	 	     			 .append(" and a.i_company =  d.i_company ")                                               
	 			 	 	     			 .append(" and a.i_project =  d.i_project ")                                                
	 			 	 	     			 .append(" and a.i_lock =  d.i_lock ")
	 			 	 	     			 .append(" and a.f_status <> 'CAN' ")
	 			 	 	     			 .append(" AND ((a.i_type = '1' and a.i_ipv_docno is not null ) or (a.i_type in ('2','3','4'))) ")
	 			 	 	     			 .append(" and a.i_company =  x.com_id   ")                                            
	 			 	 	     			 .append(" and a.i_project =  x.proj_id  ")                                                                                                 
	 			 	 	     			 .append(" and c.d_close_law is not null ") ;
	 	 	 	     				
		 	 	 	     				  if(!"".equals(itemsDDL)){
			 	 	 	     				 sqlFetch.append(" and b.i_itmno = '"+itemsDDL+"'   ");
		 	 	 	     				  }else{
			 	 	 	     				sqlFetch.append(" and b.i_itmno[1,2] = '"+doString.checkString(hashMapSub.get("x_group").toString(),"")+"'   ")
		 			 	 	     			 	.append(" and b.i_itmno[3,4] = '"+doString.checkString(hashMapSub.get("x_type").toString(),"")+"'   ");	 	 	 	     					  
		 	 	 	     				  } 
		 			 	 	     		  if("A".equals(typeRpt)){
		 			 	 	     				sqlFetch.append(" and c.d_close_law  between '"+fromDate+"' and '"+toDate+"' ");
		 			 	 	     		  }else if("B".equals(typeRpt)){
		 			 	 	     				sqlFetch.append(" and date(a.d_keyin)  between '"+fromDate+"' and '"+toDate+"' ");
		 			 	 	     		  }
	 			 	 	     			sqlFetch.append(" Group by 1,2,3    ") 
	 	 	 	     					  .append(" Order by  1,2,3 ")		
	 	 	 	     					  .append(" ) as xtable ")
	 	 	 	     					  .append(" Group by 1,type2 ")
	 	 	 	     					  .append(" Order by 1,type2 ");
	 	 	 	     			}else{
	 	 	 	 	     			sqlFetch.append(",(CASE ")
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 30  then  30 ") 
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 60  then  60 ")
	 			 	     			 	 .append(" when c.d_close_law - d.date_qc <= 90  then  90 ")
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 120  then  120 ") 
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 150  then  150 ") 
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 180  then  180 ") 
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 210  then  210 ") 
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 240  then  240 ")
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 270  then  270 ")
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 300  then  300 ")
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 330  then  330 ")
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 360  then  360 ")
	 			 	     			     .append(" when c.d_close_law - d.date_qc  > 360  then  999 ")
	 			 	 	     			 .append(" ELSE 0 END ")
	 			 	 	     			 .append(" ) as type2 ")
	 		 	 	 	     			 .append(" From lan:ipv_qchd a,lan:ipv_qcdt b,lan:acscontr c,lan:acxlckhd d , "+tempTableName+" x    ")       
	 			 	 	     			 .append(" Where a.i_docno = b.i_qc_docno  ")                                               
	 			 	 	     			 .append(" and a.i_project <> ''   ")                                                    
	 			 	 	     			 .append(" and a.i_company =  c.i_company ")                                                
	 			 	 	     			 .append(" and a.i_project =  c.i_project ")                                                
	 			 	 	     			 .append(" and a.i_lock =  c.i_sort     ")                                                  
	 			 	 	     			 .append(" and a.i_company =  d.i_company  ")                                               
	 			 	 	     			 .append(" and a.i_project =  d.i_project ")                                                
	 			 	 	     			 .append(" and a.i_lock =  d.i_lock ")
	 			 	 	     			 .append(" and a.f_status <> 'CAN' ")
	 			 	 	     			 .append(" AND ((a.i_type = '1' and a.i_ipv_docno is not null ) or (a.i_type in ('2','3','4'))) ")
	 			 	 	     			 .append(" and a.i_company =  x.com_id    ")                                            
	 			 	 	     			 .append(" and a.i_project =  x.proj_id  ")                                                                                                 
	 			 	 	     			 .append(" and c.d_close_law is not null  "); 
		 	 	 	     				if(!"".equals(itemsDDL)){
				 	 	 	     			sqlFetch.append(" and b.i_itmno = '"+itemsDDL+"'   ");
			 	 	 	     			}else{
				 	 	 	     			sqlFetch.append(" and b.i_itmno[1,2] = '"+doString.checkString(hashMapSub.get("x_group").toString(),"")+"'   ")
			 			 	 	     			 .append(" and b.i_itmno[3,4] = '"+doString.checkString(hashMapSub.get("x_type").toString(),"")+"'   ");	 	 	 	     					  
			 	 	 	     			} 
	 			 	 	     			if("A".equals(typeRpt)){
	 			 	 	     				sqlFetch.append(" and c.d_close_law  between '"+fromDate+"' and '"+toDate+"' ");
	 			 	 	     			}else if("B".equals(typeRpt)){
	 			 	 	     				sqlFetch.append(" and date(a.d_keyin)  between '"+fromDate+"' and '"+toDate+"' ");
	 			 	 	     			}
	 			 	 	     		sqlFetch.append(" Group by 1,type2    ")                                                       
	 			 	 	     				.append(" Order by 1,type2	 "); 
	 	 	 	     			}
	 			    			//System.out.println(" SQL Get data By ALL Subs :"+sqlFetch.toString());
	 			    			pstmt = conn.prepareStatement(sqlFetch.toString()); 
	 						    //pstmt.setString(1,doString.checkString(hashMap.get("i_group").toString(),""));//i_group
	 				 	        rs = pstmt.executeQuery();	
	 				 	       
	 				 	        int code = 0;
	 		 	        		while(rs.next()){
	 		 	        			code = 0;
	 		 	        			code = rs.getInt("type2");
	 		 	        			////System.out.println("== code : "+code);
	 	 	 	        			switch (code) {
	 		 	        			case 30: //5
	 		 	        				if(C_STATUS.equals(type_amt)){
	 		 	        				   STR_MATRIX[0] = rs.getString("sumAmount");
	 		 	        				}else{
	 	 		 	        			   CNT_MATRIX[0] +=rs.getInt("cnt");
	 		 	        				}
	 		 	        				break;
	 		 	        			case 60://6
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[1] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[1] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 90://7
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[2] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[2] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 120://8
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[3] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[3] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 150://9
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[4] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[4] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 180://10
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[5] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[5] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 210://11
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[6] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[6] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 240://12
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[7] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[7] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 270://13
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[8] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[8] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 300://14
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[9] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[9] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 330://15
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[10] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[10] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 360://16
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[11] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[11] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 999://17	
	 		 	        				if(C_STATUS.equals(type_amt)){
		  		 	        				STR_MATRIX[12] = rs.getString("sumAmount");
		  		 	        			}else{
		  	 		 	        			CNT_MATRIX[12] +=rs.getInt("cnt");
		  		 	        			}
	 		 	        				break;	 		 	        				
	 		 	        			default:
		 		 	        			  //System.out.println("===CNT_MATRIX Unknown result===");
	 		 	        	            break;
	 		 	        			}//#End Switch Case
	 		 	        		}//#End while loop
	 		 	        		//----------------------------------
	 	 	 	        		int Loop = 5;
	 	 	 	        		if(type_amt.equals(C_STATUS)){
	 	 	 	 	        		for(int x = 0;x<STR_MATRIX.length;x++){
	 	 	 	 	        		  tempMatrix[Loop++] = STR_MATRIX[x];
	 	 	 	 	        		}
	 	 	 	        		}else{
	 	 	 	 	        		//System.out.println("===CNT_MATRIX=== :"+CNT_MATRIX.length);
	 	 	 	 	        		//System.out.println("===tempMatrix===:"+tempMatrix.length);
	 	 	 	 	        		for(int x = 0;x<CNT_MATRIX.length;x++){
	 	 	 	 	        			tempMatrix[Loop++] = ""+CNT_MATRIX[x];
	 	 	 	 	        		}
	 	 	 	        		}
	 	 	 	        		//System.out.println("===rrrrrrrrrrrrrr===");
	 		 	        		/* Mapping MATRIX for view to html */
	 		  					objListResult.add(tempMatrix);
	 	        			}//#for Sub
	 	        		}//#End for objSubsList	 
	  				}//#End For listMainGroup
	  			}//#End Check size or null ArrayList
	     	    //---#End ---/
			  	return objListResult;			  	 
			}catch(Exception e){
				System.err.println("!!!ListReportCaseBySubsGroup, " +sysName+":"+ clazzName + " : " + e.getMessage());
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
	
	//ListGrupMain=1,ListSubsGate=1,ListItems= ALL,Or Items Code
	public  List  ListReportCaseByItems(Connection conn,List listMainGroup,String subId,boolean isItemsAll,String fromDate,String toDate,String tempTableName
			,String typeRpt,String type_amt){ 
			StringBuffer sqlFetch = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			try{
	        	List objListResult= new ArrayList();
	        	List objItemsList = null;
	  			//-----------------
	  			String []tempMatrix = null;
	  			int [] CNT_MATRIX = null;//new int[15];
	  			String []STR_MATRIX = null;
	  			int MAX_COLUMN =  19 ;//COLUMN_TRANSFER.length+4; //Asign Array 19 column ,id,prefix,name,lname,0,0,0,...n
	  			
	  			//System.out.println(",xxxxx=== ListReportCaseByItems  ============ ");
	            //------------------- 				
	  			if(listMainGroup!=null && listMainGroup.size()>0){	
	  				HashMap hashMap = null;	
	  				HashMap hashMapItems = null;	
	  				//int Loop = 0;
	  				
	  				//System.out.println(",xxxxx=== listMainGroup :"+listMainGroup.size());
	  				for (int i = 0; i < listMainGroup.size(); i++) {
	  					 hashMap = (HashMap)listMainGroup.get(i);
	 	        		//--------------------------------------
	  					objItemsList = null;
	 	        		//Get ALL Items Record
	  					if(isItemsAll){
	  						objItemsList = ListItemsByGroupId$SubsId(conn, doString.checkString(hashMap.get("i_group").toString(),""),subId);	 
	  					}else{//By Record
	  						objItemsList = ListItemsByItemsId(conn, subId);
	  					}
	 	        		//System.out.println(i+",xxxxx=== objItemsList :"+objItemsList.size());
	 	        		
	 	        		if(objItemsList!=null && objItemsList.size()>0){
	 	        			for (int s = 0; s < objItemsList.size(); s++) {
	 	        				hashMapItems = (HashMap)objItemsList.get(s);
	 	        				//--------------------------------------Sub
	 		 	        		 tempMatrix = new String[MAX_COLUMN]; //Asign Array 19 column
	 		 	        		 for (int n=0; n < MAX_COLUMN; n++) {
	 		 	        			tempMatrix[n] = "";//Allocate a values in row&coulumn	
	 		 	        			if(n>0){
	 		 	        				tempMatrix[n] = "0";//Allocate a values in row&coulumn	
	 		 	        			}
	 		 	 	    		}//#End For 
			 		 	        //--------------------------------------
			 	  	 	        if(type_amt.equals(C_STATUS)){
			 	 	 	 	  		STR_MATRIX = new String[13];
			 	 	 	 	  		for(int x = 0;x<STR_MATRIX.length;x++){
			 	 	 	 	  			STR_MATRIX[x] = "0"; //Allocate a values in row&column 
			 		  	 	     	}
			 	 	 	 	  	}else{
			 	 	  	 	        CNT_MATRIX = new int[13]; //15 column
			 	 	  	 	     	for(int x = 0;x<CNT_MATRIX.length;x++){
			 	 	  	 	     		CNT_MATRIX[x] = 0; //Allocate a values in row&column 
			 	 	  	 	     	}
			 	 	 	 	  	}
	 		  					//--------------------------------------Group
	 	        				tempMatrix[0] = doString.checkString(hashMap.get("f_in_out").toString(),"");//f_in_out
	 	        				tempMatrix[1] = doString.checkString(hashMapItems.get("x_group").toString(),"");//i_group: mainGroup
	 	        				tempMatrix[2] = doString.checkString(hashMapItems.get("x_type").toString(),"");//i_itmjob : Sub
	 		 	        		tempMatrix[3] = doString.checkString(hashMapItems.get("x_itmjob").toString(),"");//i_itmjob : items
	 		 	        		tempMatrix[4] = doString.checkString(hashMapItems.get("xname_itmjob").toString(),"");//n_itmjob
	
	 		 	     			sqlFetch.delete(0, sqlFetch.length());
	 		 	     			//sqlFetch.append(" Select b.i_itmno,count(b.i_qc_docno) as cnt  ")
	 		 	     			if(type_amt.equals("A")){
	 	 	 	 	     			sqlFetch.append(" Select b.i_itmno,count(*) as cnt  ");
	 	 	 	     			}else if(type_amt.equals("B")){
	 	 	 	     				sqlFetch.append(" Select b.i_itmno,count(DISTINCT a.i_docno) as cnt  ");
	 	 	 	     			}else if(type_amt.equals(C_STATUS)){//z_amount_pv
	 	 	 	     				sqlFetch.append(" Select b.i_itmno,sum(b.z_amount_pv) as sumAmount  ");
	 	 	 	     			}
			 	     			if(type_amt.equals(D_STATUS)){
	 	 	 	     				sqlFetch.append("  Select itmno,count(distinct xid) as cnt ")
	 		 	 	     				 .append(",(CASE ")
	 			 	     			     .append(" when diffday <= 30  then  30 ") 
	 			 	     			     .append(" when diffday <= 60  then  60 ")
	 			 	     			 	 .append(" when diffday <= 90  then  90 ")
	 			 	     			     .append(" when diffday <= 120  then  120 ") 
	 			 	     			     .append(" when diffday <= 150  then  150 ") 
	 			 	     			     .append(" when diffday <= 180  then  180 ") 
	 			 	     			     .append(" when diffday <= 210  then  210 ") 
	 			 	     			     .append(" when diffday <= 240  then  240 ")
	 			 	     			     .append(" when diffday <= 270  then  270 ")
	 			 	     			     .append(" when diffday <= 300  then  300 ")
	 			 	     			     .append(" when diffday <= 330  then  330 ")
	 			 	     			     .append(" when diffday <= 360  then  360 ")
	 			 	     			     .append(" when diffday  > 360  then  999 ")
	 			 	 	     			 .append(" ELSE 0 END ")
	 			 	 	     			 .append(" ) as type2 ")
	 			 	 	     			 .append(" From( ")
	 	 	 	     			 		 .append(" Select distinct a.i_company||a.i_project||a.i_lock as xid,b.i_itmno as itmno ")
	 	 	 	     			 		 .append(" ,c.d_close_law - d.date_qc as diffDay ") 
	 	 	 	     					 .append(" From lan:ipv_qchd a,lan:ipv_qcdt b,lan:acscontr c,lan:acxlckhd d , "+tempTableName+" x    ")       
	 			 	 	     			 .append(" Where a.i_docno = b.i_qc_docno  ")                                               
	 			 	 	     			 .append(" and a.i_project <> ''   ")                                                    
	 			 	 	     			 .append(" and a.i_company =  c.i_company ")                                                
	 			 	 	     			 .append(" and a.i_project =  c.i_project ")                                                
	 			 	 	     			 .append(" and a.i_lock =  c.i_sort     ")                                                  
	 			 	 	     			 .append(" and a.i_company =  d.i_company ")                                               
	 			 	 	     			 .append(" and a.i_project =  d.i_project ")                                                
	 			 	 	     			 .append(" and a.i_lock =  d.i_lock ")
	 			 	 	     			 .append(" and a.f_status <> 'CAN' ")
	 			 	 	     			 .append(" AND ((a.i_type = '1' and a.i_ipv_docno is not null ) or (a.i_type in ('2','3','4'))) ")
	 			 	 	     			 .append(" and a.i_company =  x.com_id   ")                                            
	 			 	 	     			 .append(" and a.i_project =  x.proj_id  ")                                                                                                 
	 			 	 	     			 .append(" and c.d_close_law is not null ") 
	 			 	 	     			 .append(" and b.i_itmno = '"+doString.checkString(hashMapItems.get("x_itmjob").toString(),"")+"'   ");
	 	 	 	     				
	 			 	 	     			if("A".equals(typeRpt)){
	 			 	 	     				sqlFetch.append(" and c.d_close_law  between '"+fromDate+"' and '"+toDate+"' ");
	 			 	 	     			}else if("B".equals(typeRpt)){
	 			 	 	     				sqlFetch.append(" and date(a.d_keyin)  between '"+fromDate+"' and '"+toDate+"' ");
	 			 	 	     			}
	 			 	 	     			sqlFetch.append(" Group by 1,2,3    ") 
	 	 	 	     					 .append(" Order by  1,2,3 ")		
	 	 	 	     					 .append(" ) as xtable ")
	 	 	 	     					 .append(" Group by 1,type2 ")
	 	 	 	     					 .append(" Order by 1,type2 ");
	 	 	 	     			}else{
	 	 	 	 	     			sqlFetch.append(",(CASE ")
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 30  then  30 ") 
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 60  then  60 ")
	 			 	     			 	 .append(" when c.d_close_law - d.date_qc <= 90  then  90 ")
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 120  then  120 ") 
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 150  then  150 ") 
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 180  then  180 ") 
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 210  then  210 ") 
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 240  then  240 ")
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 270  then  270 ")
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 300  then  300 ")
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 330  then  330 ")
	 			 	     			     .append(" when c.d_close_law - d.date_qc <= 360  then  360 ")
	 			 	     			     .append(" when c.d_close_law - d.date_qc  > 360  then  999 ")
	 			 	 	     			 .append(" ELSE 0 END ")
	 			 	 	     			 .append(" ) as type2 ")
	 		 	 	 	     			 .append(" From lan:ipv_qchd a,lan:ipv_qcdt b,lan:acscontr c,lan:acxlckhd d , "+tempTableName+" x    ")       
	 			 	 	     			 .append(" Where a.i_docno = b.i_qc_docno  ")                                               
	 			 	 	     			 .append(" and a.i_project <> ''   ")                                                    
	 			 	 	     			 .append(" and a.i_company =  c.i_company ")                                                
	 			 	 	     			 .append(" and a.i_project =  c.i_project ")                                                
	 			 	 	     			 .append(" and a.i_lock =  c.i_sort     ")                                                  
	 			 	 	     			 .append(" and a.i_company =  d.i_company  ")                                               
	 			 	 	     			 .append(" and a.i_project =  d.i_project ")                                                
	 			 	 	     			 .append(" and a.i_lock =  d.i_lock ")
	 			 	 	     			 .append(" and a.f_status <> 'CAN' ")
	 			 	 	     			 .append(" AND ((a.i_type = '1' and a.i_ipv_docno is not null ) or (a.i_type in ('2','3','4'))) ")
	 			 	 	     			 .append(" and a.i_company =  x.com_id    ")                                            
	 			 	 	     			 .append(" and a.i_project =  x.proj_id  ")                                                                                                 
	 			 	 	     			 .append(" and c.d_close_law is not null  ") 
	 			 	 	     			 .append(" and b.i_itmno = '"+doString.checkString(hashMapItems.get("x_itmjob").toString(),"")+"'   ");
	 			 	 	     			if("A".equals(typeRpt)){
	 			 	 	     				sqlFetch.append(" and c.d_close_law  between '"+fromDate+"' and '"+toDate+"' ");
	 			 	 	     			}else if("B".equals(typeRpt)){
	 			 	 	     				sqlFetch.append(" and date(a.d_keyin)  between '"+fromDate+"' and '"+toDate+"' ");
	 			 	 	     			}
	 			 	 	     		sqlFetch.append(" Group by 1,type2    ")                                                       
	 			 	 	     				.append(" Order by 1,type2	 "); 
	 	 	 	     			}	 		 	     			

	 			    			//System.out.println(" SQL Get data By ALL Items :"+sqlFetch.toString());
	 			    			pstmt = conn.prepareStatement(sqlFetch.toString()); 
	 						    //pstmt.setString(1,doString.checkString(hashMap.get("i_group").toString(),""));//i_group
	 				 	        rs = pstmt.executeQuery();	
	 				 	       
	 				 	        int code = 0;
	 		 	        		while(rs.next()){
	 		 	        			code = 0;
	 		 	        			code = rs.getInt("type2");
	 		 	        			//System.out.println("== code : "+code);
	 	 	 	        			switch (code) {
	 		 	        			case 30: //5
	 		 	        				if(C_STATUS.equals(type_amt)){
	 		 	        				   STR_MATRIX[0] = rs.getString("sumAmount");
	 		 	        				}else{
	 	 		 	        			   CNT_MATRIX[0] +=rs.getInt("cnt");
	 		 	        				}
	 		 	        				break;
	 		 	        			case 60://6
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[1] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[1] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 90://7
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[2] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[2] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 120://8
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[3] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[3] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 150://9
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[4] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[4] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 180://10
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[5] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[5] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 210://11
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[6] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[6] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 240://12
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[7] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[7] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 270://13
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[8] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[8] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 300://14
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[9] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[9] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 330://15
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[10] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[10] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 360://16
	 		 	        				if(C_STATUS.equals(type_amt)){
	  		 	        				   STR_MATRIX[11] = rs.getString("sumAmount");
	  		 	        				}else{
	  	 		 	        			   CNT_MATRIX[11] +=rs.getInt("cnt");
	  		 	        				}
	 		 	        				break;
	 		 	        			case 999://17	
	 		 	        				if(C_STATUS.equals(type_amt)){
		  		 	        				STR_MATRIX[12] = rs.getString("sumAmount");
		  		 	        			}else{
		  	 		 	        			CNT_MATRIX[12] +=rs.getInt("cnt");
		  		 	        			}
	 		 	        				break;	 		 	        				
	 		 	        			default:
		 		 	        			//System.out.println("===CNT_MATRIX Unknown result===");
	 		 	        	            break;
	 		 	        			}//#End Switch Case
	 		 	        		}//#End while loop
	 		 	        		//----------------------------------
	 	 	 	        		int Loop = 5;
	 	 	 	        		if(type_amt.equals(C_STATUS)){
	 	 	 	 	        		for(int x = 0;x<STR_MATRIX.length;x++){
	 	 	 	 	        		  tempMatrix[Loop++] = STR_MATRIX[x];
	 	 	 	 	        		}
	 	 	 	        		}else{
	 	 	 	 	        		//System.out.println("===CNT_MATRIX=== :"+CNT_MATRIX.length);
	 	 	 	 	        		//System.out.println("===tempMatrix===:"+tempMatrix.length);
	 	 	 	 	        		for(int x = 0;x<CNT_MATRIX.length;x++){
	 	 	 	 	        			tempMatrix[Loop++] = ""+CNT_MATRIX[x];
	 	 	 	 	        		}
	 	 	 	        		}
	 	 	 	        		//System.out.println("===ListReportCaseByItems===");
	 	 	 	        		/* Mapping MATRIX for view to html */
	 		  					objListResult.add(tempMatrix);
	 	        			}//#for Sub
	 	        		}//#End for objSubsList	 
	  				}//#End For listMainGroup
	  			}//#End Check size or null ArrayList

	     	    //---#End ---/
			  	return objListResult;			  	 
			}catch(Exception e){
				System.err.println("!!!ListReportCaseByItems, " +sysName+":"+ clazzName + " : " + e.getMessage());
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

    private List<HashMap> ListMainCategory(Connection conn) {
		// TODO Auto-generated method stub
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			//String tempProject = "";
	        try{
	        	//initial paramter	 	       	 	
	 	       	List  hashArrList = new ArrayList();
	        	HashMap<String, String> hashMap = null;   
				/******************************************************/			
	        	sql.delete(0,sql.length());
				sql.append(" Select f_in_out,i_group,n_itmjob,i_itmjob  ")
				   .append("  From lan:ipv_qcboq   ")
				   .append("  Where i_group is not null    ")
				   .append("  and i_type is  null  ")
				   .append("  and i_seq is null  ")
				   .append(" Order by f_in_out,i_group,n_itmjob ");
				//System.out.println("<<<<<--Group from ListMainCategory:' - SQL :"+sql.toString());
	 			pstmt = conn.prepareStatement(sql.toString()); 
		     	rs = pstmt.executeQuery();	
		     	while(rs.next()){
					hashMap = new HashMap<String, String>();
					hashMap.put("f_in_out", doString.checkString(rs.getString("f_in_out"),""));//01,02
					hashMap.put("i_group", doString.checkString(rs.getString("i_group"),""));//Value
					hashMap.put("n_itmjob", doString.checkString(rs.getString("n_itmjob"),""));//NameText
					hashMap.put("i_itmjob", doString.checkString(rs.getString("i_itmjob"),""));//Value
					hashArrList.add(hashMap);
		        }
				rs.close();		   			
			//********************************************************/
			//System.out.println("ListMainCategory ->successfully.");				  	 
			return hashArrList;			  	 
		}catch(Exception e){
				System.out.println("ListMainCategory , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
    
    private List<HashMap> ListMainCategory(Connection conn,String iGroupId) {
		// TODO Auto-generated method stub
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			//String tempProject = "";
	        try{
	        	//initial paramter	 	       	 	
	 	       	List  hashArrList = new ArrayList();
	        	HashMap<String, String> hashMap = null;   
				/******************************************************/			
	        	sql.delete(0,sql.length());
				sql.append(" Select f_in_out,i_group,n_itmjob,i_itmjob  ")
				   .append("  From lan:ipv_qcboq   ")
				   .append("  Where i_group is not null    ")
				   .append("  and i_type is  null  ")
				   .append("  and i_seq is null  ")
				   .append("  and i_group = '"+iGroupId+"' ")
				   .append(" Order by f_in_out,i_group,n_itmjob ");
				//System.out.println("xxxx-Group from ListMainCategory:' - SQL :"+sql.toString());
	 			pstmt = conn.prepareStatement(sql.toString()); 
		     	rs = pstmt.executeQuery();	
		     	while(rs.next()){
					hashMap = new HashMap<String, String>();
					hashMap.put("f_in_out", doString.checkString(rs.getString("f_in_out"),""));//01,02
					hashMap.put("i_group", doString.checkString(rs.getString("i_group"),""));//Value
					hashMap.put("n_itmjob", doString.checkString(rs.getString("n_itmjob"),""));//NameText
					hashMap.put("i_itmjob", doString.checkString(rs.getString("i_itmjob"),""));//Value
					hashArrList.add(hashMap);
		        }
				rs.close();		   			
			//********************************************************/
			//System.out.println("ListMainCategory ->successfully.");				  	 
			return hashArrList;			  	 
		}catch(Exception e){
				System.out.println("ListMainCategory , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
    
    private List<HashMap> ListSubsCategory(Connection conn,String mainGroupId) {
		// TODO Auto-generated method stub
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			//String tempProject = "";
	        try{
	        	//initial paramter	 	       	 	
 	       	List  hashArrList = new ArrayList();
        	HashMap<String, String> hashMap = null;   
			/******************************************************/	
 			sql.delete(0, sql.length());
        	if("AAA".equals(mainGroupId)){//CASE : ALL

        		hashMap = new HashMap<String, String>();
    			hashMap.put("i_group", "");
    			hashMap.put("i_type", "");
    			hashMap.put("i_itmjob", "");
    			hashMap.put("n_itmjob", "------ กรุณาเลือกหมวดรอง ------");
    			hashArrList.add(hashMap);

    	     	hashMap = new HashMap<String, String>();
    			hashMap.put("i_group", "nnnn");
    			hashMap.put("i_type", "nnnn");
    			hashMap.put("i_itmjob", "nnnn");
    			hashMap.put("n_itmjob", "**** ไม่แสดงหมวดรอง ****");
    			hashArrList.add(hashMap);
    			
    			hashMap = new HashMap<String, String>();
    			hashMap.put("i_group", "ALL");
    			hashMap.put("i_type", "ALL");
    			hashMap.put("i_itmjob", "ALL");
    			hashMap.put("n_itmjob", "ALL เลือกทุกหมวดรอง ");
    			hashArrList.add(hashMap);      		

    			return hashArrList;
        	}else{
        		
        		hashMap = new HashMap<String, String>();
    			hashMap.put("i_group", "");
    			hashMap.put("i_type", "");
    			hashMap.put("i_itmjob", "");
    			hashMap.put("n_itmjob", "------ กรุณาเลือกหมวดรอง ------");
    			hashArrList.add(hashMap);

    	     	hashMap = new HashMap<String, String>();
    			hashMap.put("i_group", "nnnn");
    			hashMap.put("i_type", "nnnn");
    			hashMap.put("i_itmjob", "nnnn");
    			hashMap.put("n_itmjob", "**** ไม่แสดงหมวดรอง ****");
    			hashArrList.add(hashMap);
    			
    			hashMap = new HashMap<String, String>();
    			hashMap.put("i_group", "ALL");
    			hashMap.put("i_type", "ALL");
    			hashMap.put("i_itmjob", "ALL");
    			hashMap.put("n_itmjob", "ALL เลือกทุกหมวดรอง ");
    			hashArrList.add(hashMap);      		

     			sql.append(" Select f_in_out,i_group,i_type,n_itmjob,i_itmjob  ")
     			   .append(" From lan:ipv_qcboq ")
     			   .append(" Where i_group ='"+mainGroupId+"' ")
     			   .append(" and i_type is not null  ")
     			   .append(" and i_seq is null ")
     			   .append("  Order by i_group,i_type,n_itmjob  "); 

     			//System.out.println("SQLSub :"+sql.toString());
     			pstmt = conn.prepareStatement(sql.toString()); 
    	     	rs = pstmt.executeQuery();	
    	     	while(rs.next()){
    				hashMap = new HashMap<String, String>();
    				hashMap.put("i_group", doString.checkString(rs.getString("i_group"),""));//0
    				hashMap.put("i_type", doString.checkString(rs.getString("i_type"),""));//1
    				hashMap.put("n_itmjob", doString.checkString(rs.getString("n_itmjob"),""));//2
    				hashMap.put("i_itmjob", doString.checkString(rs.getString("i_itmjob"),""));//3
    				hashArrList.add(hashMap);
    	        }
    			rs.close();		   			
    			//********************************************************/
    			//System.out.println("ListSubsCategory ->successfully.");				  	 
    			return hashArrList;	       		
        	}		  	 
		}catch(Exception e){
				System.out.println("ListSubsCategory , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
    
    private List<HashMap> ListSubsCategoryByGroupId(Connection conn,String mainGroupId) {
		// TODO Auto-generated method stub
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			//String tempProject = "";
	        try{
	        	//initial paramter	 	       	 	
	 	       	List  hashArrList = new ArrayList();
	        	HashMap<String, String> hashMap = null;   
				/******************************************************/	
	 			sql.delete(0, sql.length());
	     		sql.append(" Select f_in_out,i_group,i_type,i_itmjob,n_itmjob  ")
	     		   .append(" From lan:ipv_qcboq ")
	     		   .append(" Where i_group ='"+mainGroupId+"' ")
	     		   .append(" and i_type is not null  ")
	     		   .append(" and i_seq is null ")
	     		   .append(" Order by i_group,i_type,i_itmjob,n_itmjob  "); 
	
	     			//System.out.println("SQLSub With ALL :"+sql.toString());
	     			pstmt = conn.prepareStatement(sql.toString()); 
	    	     	rs = pstmt.executeQuery();	
	    	     	while(rs.next()){
	    				hashMap = new HashMap<String, String>();
	    				hashMap.put("x_group", doString.checkString(rs.getString("i_group"),""));//0
	    				hashMap.put("x_type", doString.checkString(rs.getString("i_type"),""));//1
	    				hashMap.put("x_itmjob", doString.checkString(rs.getString("i_itmjob"),""));//3
	    				hashMap.put("xname_itmjob", doString.checkString(rs.getString("n_itmjob"),""));//2
	    				hashArrList.add(hashMap);
	    	        }
	    			rs.close();		   			
	    			//********************************************************/
    			   //System.out.println("ListSubsCategoryByGroupId ->successfully.");				  	 
    			   return hashArrList;	       				  	 
		}catch(Exception e){
				System.out.println("ListSubsCategoryByGroupId , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
    
    private List<HashMap> ListSubsCategoryByGroupId$SubsId(Connection conn,String mainGroupId,String subId) {
		// TODO Auto-generated method stub
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			//String tempProject = "";
	        try{
	        	//initial paramter	 	       	 	
	 	       	List  hashArrList = new ArrayList();
	        	HashMap<String, String> hashMap = null;       
				/******************************************************/	
	 			sql.delete(0, sql.length());
	     		sql.append(" Select f_in_out,i_group,i_type,i_itmjob,n_itmjob  ")
	     		   .append(" From lan:ipv_qcboq ")
	     		   .append(" Where i_group ='"+mainGroupId+"' ")    
	     		   .append(" and i_type = '"+subId+"'  ")
	     		   .append(" and i_seq is null ")
	     		   .append(" Order by i_group,i_type,i_itmjob,n_itmjob  "); 
	
	     			//System.out.println("SQLSub :"+sql.toString());
	     			pstmt = conn.prepareStatement(sql.toString()); 
	    	     	rs = pstmt.executeQuery();	
	    	     	while(rs.next()){
	    				hashMap = new HashMap<String, String>();
	    				hashMap.put("x_group", doString.checkString(rs.getString("i_group"),""));//0
	    				hashMap.put("x_type", doString.checkString(rs.getString("i_type"),""));//1
	    				hashMap.put("x_itmjob", doString.checkString(rs.getString("i_itmjob"),""));//3
	    				hashMap.put("xname_itmjob", doString.checkString(rs.getString("n_itmjob"),""));//2
	    				hashArrList.add(hashMap);
	    	        }
	    			rs.close();		   			
	    			//********************************************************/
    			   //System.out.println("ListSubsCategoryByGroupId ->successfully.");				  	 
    			   return hashArrList;	       				  	 
		}catch(Exception e){
				System.out.println("ListSubsCategoryByGroupId , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
    
    private List<HashMap> ListItemsByGroupId$SubsId(Connection conn,String mainGroupId,String subId) {
		// TODO Auto-generated method stub
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			//String tempProject = "";
	        try{
	        	//initial paramter	 	       	 	
	 	       	List  hashArrList = new ArrayList();
	        	HashMap<String, String> hashMap = null;   
				/******************************************************/	
	 			sql.delete(0, sql.length());
	     		sql.append(" Select f_in_out,i_group,i_type,i_itmjob,n_itmjob  ")
	     		   .append(" From lan:ipv_qcboq ")
	     		   .append(" Where i_group ='"+mainGroupId+"' ")
	     		   .append(" and i_type = '"+subId+"'  ")
	     		   .append(" and i_seq is not null ")
	     		   .append(" Order by i_group,i_type,i_itmjob,n_itmjob  "); 
	
	     			//System.out.println("SQLSub :"+sql.toString());
	     			pstmt = conn.prepareStatement(sql.toString()); 
	    	     	rs = pstmt.executeQuery();	
	    	     	while(rs.next()){
	    				hashMap = new HashMap<String, String>();
	    				hashMap.put("x_group", doString.checkString(rs.getString("i_group"),""));//0
	    				hashMap.put("x_type", doString.checkString(rs.getString("i_type"),""));//1
	    				hashMap.put("x_itmjob", doString.checkString(rs.getString("i_itmjob"),""));//3
	    				hashMap.put("xname_itmjob", doString.checkString(rs.getString("n_itmjob"),""));//2
	    				hashArrList.add(hashMap);
	    	        }
	    			rs.close();		   			
	    			//********************************************************/
    			   //System.out.println("ListItemsByGroupId$SubsId ->successfully.");				  	 
    			   return hashArrList;	       				  	 
		}catch(Exception e){
				System.out.println("ListItemsByGroupId$SubsId , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
    
    private List<HashMap> ListItemsByItemsId(Connection conn,String itemsId) {
		// TODO Auto-generated method stub
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			//String tempProject = "";
	        try{
	        	//initial paramter	 	       	 	
	 	       	List  hashArrList = new ArrayList();
	        	HashMap<String, String> hashMap = null;   
				/******************************************************/	
	 			sql.delete(0, sql.length());
	     		sql.append(" Select f_in_out,i_group,i_type,i_itmjob,n_itmjob  ")
	     		   .append(" From lan:ipv_qcboq ")
	     		   .append(" Where i_itmjob ='"+itemsId+"' ");
	     		
	     		//System.out.println("SQL Items Sub :"+sql.toString());
	     		pstmt = conn.prepareStatement(sql.toString()); 
	    	     rs = pstmt.executeQuery();	
	    	     if(rs.next()){
	    				hashMap = new HashMap<String, String>();
	    				hashMap.put("x_group", doString.checkString(rs.getString("i_group"),""));//0
	    				hashMap.put("x_type", doString.checkString(rs.getString("i_type"),""));//1
	    				hashMap.put("x_itmjob", doString.checkString(rs.getString("i_itmjob"),""));//3
	    				hashMap.put("xname_itmjob", doString.checkString(rs.getString("n_itmjob"),""));//2
	    				hashArrList.add(hashMap);
	    	        }
	    			rs.close();		   			
	    			//********************************************************/
    			   //System.out.println("ListSubsCategoryByGroupId ->successfully.");				  	 
    			   return hashArrList;	       				  	 
		}catch(Exception e){
				System.out.println("ListSubsCategoryByGroupId , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
   
    private List<HashMap> ListItemsCategory(Connection conn,String mainGroupId,String itemsId) {
		// TODO Auto-generated method stub
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			//String tempProject = "";
	        try{
	        	//initial paramter	 	       	 	
	 	       	List  hashArrList = new ArrayList();
	        	HashMap<String, String> hashMap = null;   
				/******************************************************/	
	        	//System.out.println(" ============= "+mainGroupId);
	        	//System.out.println(" ============= "+itemsId);
	        	if("AAA".equals(mainGroupId) || "ALL".equals(itemsId)){
					hashMap = new HashMap<String, String>();
					hashMap.put("i_group", "");
					hashMap.put("i_type", "");
					hashMap.put("i_itmjob", "");
					hashMap.put("n_itmjob", "------ กรุณาเลือกหมวดหย่อย ------");			
					hashArrList.add(hashMap);
		
			     	hashMap = new HashMap<String, String>();
					hashMap.put("i_group", "nnnnnnnn");
					hashMap.put("i_type", "nnnnnnnn");
					hashMap.put("i_itmjob", "nnnnnnnn");
					hashMap.put("n_itmjob", "**** ไม่แสดงหมวดย่อย ****");
					hashArrList.add(hashMap);
					return hashArrList;
	        	}else{
		        	sql.delete(0,sql.length());
					sql.append(" Select  i_group,i_type,i_itmjob,n_itmjob,f_in_out  ")
					   .append(" From lan:ipv_qcboq ")
					   .append(" Where ")
					   .append(" i_group = '").append(mainGroupId).append("'  ");
						if(!"ALL".equals(itemsId)){
							 sql.append(" and i_type = '").append(itemsId).append("'  ");
						}
					sql.append(" and i_seq is not null")
						.append("  Order by i_group,i_type,i_itmjob,n_itmjob   ");
					//System.out.println("SQL Items :"+sql.toString());
					
		 			pstmt = conn.prepareStatement(sql.toString()); 
			     	rs = pstmt.executeQuery();	
		
					hashMap = new HashMap<String, String>();
					hashMap.put("i_group", "");
					hashMap.put("i_type", "");
					hashMap.put("i_itmjob", "");
					hashMap.put("n_itmjob", "------ กรุณาเลือกหมวดหย่อย ------");			
					hashArrList.add(hashMap);
		
			     	hashMap = new HashMap<String, String>();
					hashMap.put("i_group", "nnnnnnnn");
					hashMap.put("i_type", "nnnnnnnn");
					hashMap.put("i_itmjob", "nnnnnnnn");
					hashMap.put("n_itmjob", "**** ไม่แสดงหมวดย่อย ****");
					hashArrList.add(hashMap);
					
					if(!"nnnn".equals(itemsId)){
		    			hashMap = new HashMap<String, String>();
		    			hashMap.put("i_group", "ALL");
		    			hashMap.put("i_type", "ALL");
		    			hashMap.put("i_itmjob", "ALL");
		    			hashMap.put("n_itmjob", "เลือกทุกหมวดย่อย ");
		    			hashArrList.add(hashMap); 
					}

			     	while(rs.next()){
						hashMap = new HashMap<String, String>();
						hashMap.put("i_group", doString.checkString(rs.getString("i_group"),""));//0
						hashMap.put("i_type", doString.checkString(rs.getString("i_type"),""));//1
						hashMap.put("i_itmjob", doString.checkString(rs.getString("i_itmjob"),""));//2
						hashMap.put("n_itmjob", doString.checkString(rs.getString("n_itmjob"),""));//3
						hashArrList.add(hashMap);
			        }
					rs.close();		   			
					//********************************************************/
					//System.out.println("ListItemsCategory ->successfully.");				  	 
					return hashArrList;			  	 
	        	}
		}catch(Exception e){
				System.out.println("ListItemsCategory , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
    private List<HashMap> ListProjectSelect(Connection conn,String tempProjectTxt) {
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
   		      if(tempProjectTxt.length()>0){
 	 		   		String []projectArr = tempProjectTxt.split("\\|");             
 	 		   		for(int n = 0;n<projectArr.length;n++){
 	 	   			   temp = projectArr[n].split("\\:");
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
    
	private  static String builSubCategoryDropDownTagHTML(List objList,String allFlag,String selected)throws Exception{
		StringBuffer  str = new StringBuffer();
	    //List arrList = null;
		HashMap hashMap = null;		
	    if(objList!=null && objList.size()>0){
	    	String code = "";
	    	String valueTxt = "";
	    	String nameTxt = "";
	    	Iterator it = objList.iterator();
		    while(it.hasNext()){	    		    	
		    	hashMap = (HashMap)it.next();
		    	//if("AAA".equals(allFlag)){
		    		//valueTxt = doString.checkString(hashMap.get("value").toString());//LH:075
					//nameTxt =doString.checkString(hashMap.get("name").toString());					
					//valueTxt = doString.checkString(hashMap.get("i_type").toString());//xx:111 
			    	//nameTxt = doString.checkString(hashMap.get("n_itmjob").toString());					
					//str.append("<option value='"+valueTxt+"'  >"+doString.DisplayThai(nameTxt)+"</option>");	
		    	//}else{
			    	code =  doString.checkString(hashMap.get("i_group").toString())+doString.checkString(hashMap.get("i_type").toString());
			    	if("ALLALL".equalsIgnoreCase(code)){
			    		code = "";
			    	}
			    	if("nnnnnnnn".equals(code)){
			    		code = doString.checkString(hashMap.get("i_group").toString());
			    	}
			    	valueTxt = doString.checkString(hashMap.get("i_type").toString());//xx:111 
			    	nameTxt = doString.checkString(hashMap.get("n_itmjob").toString());
				    str.append("<option value='"+valueTxt+"' "+selected+" >"+code+" "+doString.DisplayThai(nameTxt)+"</option>");		    		
		    	//}

		    }//End while it.next()
		    return str.toString();
	    }else{
	    	return "";
	    }
	}
	private  static String builItemsCategoryDropDownTagHTML(List objList,String allFlag,String selected)throws Exception{
		StringBuffer  str = new StringBuffer();
	    //List arrList = null;
		HashMap hashMap = null;		
	    if(objList!=null && objList.size()>0){
	    	String code = "";
	    	String valueTxt = "";
	    	String nameTxt = "";
	    	Iterator it = objList.iterator();
		    while(it.hasNext()){	    		    	
		    	hashMap = (HashMap)it.next();
			    code =  doString.checkString(hashMap.get("i_itmjob").toString());
		    	//code =  doString.checkString(hashMap.get("i_group").toString())+doString.checkString(hashMap.get("i_type").toString());
		    	//if("ALLALL".equalsIgnoreCase(code)){
		    	//	code = "";
		    	//}
			    valueTxt = doString.checkString(hashMap.get("i_itmjob").toString());//+":"+doString.checkString(hashMap.get("i_type").toString());//xx:111
			    nameTxt = doString.checkString(hashMap.get("n_itmjob").toString());
				str.append("<option value='"+valueTxt+"' "+selected+" >"+code+" "+doString.DisplayThai(nameTxt)+"</option>");		    		
		    }//End while it.next()
		    return str.toString();
	    }else{
	    	return "";
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
	
	private static String lastDayOfMonth(int year,int month){
		  Calendar calendar = Calendar.getInstance(Locale.ENGLISH);  

		  calendar.set(Calendar.YEAR, year);
	      calendar.set(Calendar.MONTH, month);
	        
	      calendar.add(Calendar.MONTH, 0);  
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
	
	private static String GenNextId2(int b){
        String temp=""+b;
        String newSp_id;
        switch(temp.length()){ 
           case 1: newSp_id="0"+temp; break;
           default:newSp_id=temp;
        }
        return newSp_id;
   }
	
   private static String GetWhereDiffDate(int x){
	  StringBuffer temp = new StringBuffer();
	  switch(x){
	  	case 1:
	  		temp.delete(0, temp.length());
	  		temp.append(" and c.d_close_law - d.date_qc >=0 ")
	  		    .append(" and c.d_close_law - d.date_qc <=30 ");
		    break;
	  	case 2:
	  		temp.delete(0, temp.length());
	  		temp.append(" and c.d_close_law - d.date_qc >=30 ")
	  		    .append(" and c.d_close_law - d.date_qc <=60 ");
	  		break;
	  	case 3:
	  		temp.append(" and c.d_close_law - d.date_qc >=60 ")
  		    	.append(" and c.d_close_law - d.date_qc <=90 ");
	  		break;	
	  	case 4:
	  		temp.append(" and c.d_close_law - d.date_qc >=90 ")
		    	.append(" and c.d_close_law - d.date_qc <=120 ");	  			
	  		break;
	  	case 5:
	  		temp.append(" and c.d_close_law - d.date_qc >=120 ")
	  			.append(" and c.d_close_law - d.date_qc <=150 ");		  		
	  		break;	
	  	case 6:
	  		temp.append(" and c.d_close_law - d.date_qc >=150 ")
  				.append(" and c.d_close_law - d.date_qc <=180 ");	
	  		break;	 
	  	case 7:
	  		temp.append(" and c.d_close_law - d.date_qc >=180 ")
  				.append(" and c.d_close_law - d.date_qc <=210 ");
	  		break;	
	  	case 8:
	  		temp.append(" and c.d_close_law - d.date_qc >=210 ")
  				.append(" and c.d_close_law - d.date_qc <=240 ");
	  		break;
	  	case 9:
	  		temp.append(" and c.d_close_law - d.date_qc >=240 ")
  				.append(" and c.d_close_law - d.date_qc <=270 ");
	  		break;	  
	  	case 10:
	  		temp.append(" and c.d_close_law - d.date_qc >=270 ")
  				.append(" and c.d_close_law - d.date_qc <=300 ");
	  		break;
	  	case 11:
	  		temp.append(" and c.d_close_law - d.date_qc >=300 ")
  				.append(" and c.d_close_law - d.date_qc <=330 ");
	  		break;  
	  	case 12:
	  		temp.append(" and c.d_close_law - d.date_qc >=330 ")
  				.append(" and c.d_close_law - d.date_qc <=360 ");
	  		break;	
	  	default ://13
	  		temp.append(" and c.d_close_law - d.date_qc >360 ");
	  		break;
	  }
	  return temp.toString();	
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
	
   private static String GetNameOf$GroupList(List objList){
	   String ret = "";
	   HashMap hashMap = null;		
	   if(objList!=null && objList.size()>0){
	    	Iterator it = objList.iterator();
		    if(it.hasNext()){	    		    	
		    	hashMap = (HashMap)it.next();
		    	ret = hashMap.get("i_group").toString()+" &nbsp; "+hashMap.get("n_itmjob").toString();//NameText
		    }
	   }
	   return ret;
   }
   
   private static String GetNameOf$GategoryAnd$ItemsList(List objList){
	   String ret = "";
	   HashMap hashMap = null;		
	   if(objList!=null && objList.size()>0){
	    	Iterator it = objList.iterator();
		    if(it.hasNext()){	    		    	
		    	hashMap = (HashMap)it.next();
		    	ret = hashMap.get("x_itmjob").toString()+" &nbsp; "+hashMap.get("xname_itmjob").toString();//NameText
		    }
	   }
	   return ret;
   }

	public void DisplayMaxtrixList(List arrList) throws Exception{
		 String  str[] = null;
		 //System.out.println("=====ArrayList size:"+arrList.size());
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
	
	  //input :yyyy-MM-dd
	  //output :2013-10-17
	  // use : System.out.println(Utilizer.NowByCalendar("yyyy-MM-dd"));
	  //System.out.println(Utilizer.NowByCalendar("H:mm"));
	 public static String NowByCalendar(String dateFormat) {
		 Calendar cal = Calendar.getInstance(Locale.ENGLISH);
		 SimpleDateFormat sdf = new SimpleDateFormat(dateFormat);
		 return sdf.format(cal.getTime());
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
}