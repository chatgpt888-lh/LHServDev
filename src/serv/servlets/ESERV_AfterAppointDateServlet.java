package serv.servlets;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
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
import com.lh.servlet.DBServlet;
import com.lh.util.doString;
import com.svc.call.ws.webservice.WebService;
import com.svc.ws.model.GCalendarRQ;
import com.svc.ws.model.GCalendarRS;

import serv.common.User;

/**
 * Servlet implementation class for Servlet: ESERV_AfterAppointDateServlet
 * create by : pradoem wongkraso
 * date :2012.07.02
 * version : 1.0
 * description : this is class for manage master data after appiont date for E-Service System bettween  customer (frontEnd) && 
 * user  service  (blackEnd)
 * ------------------------
 * Laste update : 2014.02.13
 * by :pradoem
 * version : 2.0
 * decription : change appoint date to google calendar 
 * modify eser_date
 */

 public class ESERV_AfterAppointDateServlet extends  DBServlet{
    /* (non-Java-doc)
	 * @see javax.servlet.http.HttpServlet#HttpServlet()
	 */
	public ESERV_AfterAppointDateServlet() {
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
			  }else if(command.equals("search")){
				  this.doFormSearch(request,response,user);  
			  }else if(command.equals("pupup")){
				  this.doFormPupup(request, response, user);
			  }else if(command.equals("change")){
				  this.doChangeDateDDL(request, response, user);
			  }else if(command.equals("submit")){
				  this.doOnChangeDate(request, response, user);
			  }
		}catch(Exception e){
			e.printStackTrace();
			System.out.println(sysName+":"+cName +" "+e.toString());		
		}
	} 
	
	//***doOnChangeDate krub.
	protected void doOnChangeDate(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		StringBuffer sql = new StringBuffer();	
		ServletContext context = getServletContext();
		HttpSession session = request.getSession(false);
		//*********CurrentDate Time
		
		Connection myConn = null;
		
		
		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
		//String SUCCESS_PAGE = request.getContextPath()+"/save_ok.jsp?redirect_url=";
		
		GetParamRQ(request);		
        try{ 	
        	 String projDDL = doString.checkString(request.getParameter("projectDDL"),"");//projectDDL
        	 String iLock =  request.getParameter("iLock")==null?"": request.getParameter("iLock").toString().toUpperCase();
        	 //doString.checkString(request.getParameter("iLock"),"");//bannNo  
        	 String iDocno = doString.checkString(request.getParameter("iDocno"),"");//iDocno 
        	 String iHouse = doString.checkString(request.getParameter("iHouse"),"");//iHouse        	        	 
        	 String dateDDL = doString.checkString(request.getParameter("dateDDL"),"");//new dateDDL
        	 String timeDDL = doString.checkString(request.getParameter("timeDDL"),"");//new timeDDL       	 
        	 String custName = doString.checkString(request.getParameter("custName"),""); 
        	 String tel = doString.checkString(request.getParameter("tel"),"");
        	 String status = doString.checkString(request.getParameter("status"),"");
        	 
        	 //System.out.println("doOnChangeDate ->Starting.");	 
        	 
        	 if(projDDL.equals("")){
        		 return;
        	 }
        	 String delimiter = "\\:";
 			 String [] projId = projDDL.split(delimiter); 	 			 
 			 //ArrayList dateList = new ArrayList();			
 			 //Open connection
			
 			 if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setAutoCommit(false);
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			
			myConn = GetConnMysqlJDBC();
		    myConn.setAutoCommit(false);
			
			
			/*************************************
			 * Modify by : pradoem
			 * Modify Date : 2014.02.13
			 * version : 2.0
			 * Description : 
			 * Change flow for update eser_date with 
			 * call web service site 132.146.1.118/GCALWebService/
			 * -----------------------------
			 * xx validate  eser_dochd  is reference id is not null
			 * 1. select old date,old time from eser_date where docId
			 * 2. call 'UpdateEvent' web service
			 * 3. Update ESER_DOCHD  
			 * ***********************************/
			
		  	String iDate = "";
		  	String iTime = "";
		  	//String iCom = "";
		  	//String iProj = "";
		  	String refId = "";
		  	String DOC_REF_ID = "";
		  	String Desc = "";
		  	boolean isFlagUp = true;
		  	
			sql.delete(0,sql.length());
			sql.append(" select i_calendar_id,i_docno from lan:eser_dochd ")
		   	   .append(" where i_company = ? and i_project = ? and i_eser_docno = ?  ");			
			 pstmt = conn.prepareStatement(sql.toString()); 
			 pstmt.setString(1,projId[0]);//comId
			 pstmt.setString(2,projId[1]);//proejctId
			 pstmt.setString(3,iDocno);//doc
			 //System.out.println("--->Validate refId:"+sql.toString());
			 rs = pstmt.executeQuery();
			 if(rs.next()){
				 refId =  doString.checkString(rs.getString("i_calendar_id"),"");
				 DOC_REF_ID = doString.checkString(rs.getString("i_docno"),"");
			 }
			 
			 if("".equals(refId)){ // &&!projId[1].equals("075") 
					//System.out.println("!!! Find not' found reference Id by iDoc = "+iDocno);	
					msgTxt = "!!! Find not' found referenceId with iDoc = "+iDocno;
					try{
						conn.rollback();
					}catch(Exception ex){}
					response.sendRedirect(ERROR_PAGE+msgTxt);
					return;
			 }
			 
			 //Modify by pradoem 2014.03.19  get Detail
			 sql.delete(0,sql.length());
			 sql.append(" select i_seq,c_desc from lan:eser_docdt  ")
			   	.append(" where i_eser_docno ='"+iDocno+"' order by i_seq  ");			
				 pstmt = conn.prepareStatement(sql.toString()); 
				 //System.out.println("--->Validate refId:"+sql.toString());
				 rs = pstmt.executeQuery();
				 while(rs.next()){
					 Desc += doString.checkString(rs.getString("i_seq"),"")+"."+ doString.checkString(rs.getString("c_desc"),"")+" ";
				 }
			 //--------------------------------------
				 
		  	sql.delete(0,sql.length());
			sql.append(" Select i_company,i_project,i_date,q_apptime_fr1 From lan:eser_date  ")
		   		.append(" where  i_eser_docno =? ");			
			 pstmt = conn.prepareStatement(sql.toString()); 
			 pstmt.setString(1,iDocno);//doc
			 //System.out.println("--->Retrive record old date :"+sql.toString());
			 rs = pstmt.executeQuery();
			 if(rs.next()){
				 iDate = doString.checkString(rs.getString("i_date"),"");
				 iTime = doString.checkString(rs.getString("q_apptime_fr1"),"");
				 //iCom  = doString.checkString(rs.getString("i_company"),"");
				 //iProj = doString.checkString(rs.getString("i_project"),"");
				 isFlagUp = false;
			 }
			
			 if(isFlagUp){ //Case Error
					//System.out.println("!!! Find not' found i_eser_docno = "+iDocno);	
					msgTxt = "!!! Find not' found i_eser_docno = "+iDocno;
					try{
						conn.rollback();
					}catch(Exception ex){}
					response.sendRedirect(ERROR_PAGE+msgTxt);
					return;
			 }
			
			 GCalendarRS calRS = new GCalendarRS();
			 /***********************************
			  * For  Update Service
			  ***********************************/
			 GCalendarRQ req = new GCalendarRQ();
			 req.setReferenceId(refId);//ReferenceID  //old  xxx
			 req.setAppName("LINE"); //Application
			 req.setCompanyId(projId[0]);//CompanyID
			 req.setProjectId(projId[1]);//ProjectID
			 req.setDocumentId(iDocno); //DocumentID
			 req.setLockNo(iLock);//Lock
			 req.setFromDate(dateDDL);//From Date  //New date : YYYY-MM-DD
			 req.setFromTime(timeDDL);//From Time   //New Time 10:50
			 req.setToDate(iDate);//TO Date  //Old date
			 req.setToTime(iTime);//TO Time  //Old time
			 req.setUserName(user.getUserID());//UserName
			
			 req.setVenderId(DOC_REF_ID); //DOC_REF_ID case E-Service only
			 //For Eservice param
			 req.setDesc(Desc);
			 req.setCustomerName(custName);
			 req.setHouseNo(iHouse);
			 req.setTelNo(tel);
			 req.setStatus(status);		
			
			 calRS = (GCalendarRS)WebService.changeCalendar(req); //mark for test
			 
			 
			 System.out.println("---------Result call web Service---------");
			 String newAppointCust = "";
			 if(!"".equals(dateDDL)&&!"".equals(timeDDL)){
				newAppointCust = dateDDL+"|"+timeDDL; 
			 }

			 if(!calRS.isError()) { //success
				
					//int i = 1;			
					//String dAppointMark = dateDDL+" "+timeDDL+":00.0";	
					String dAppointMark = dateDDL+"|"+timeDDL;
					//System.out.println("----TEST :"+dAppointMark);
					sql.delete(0,sql.length());
					sql.append(" UPDATE lan:eser_dochd SET d_appoint = ?,d_post= current,i_service_post = ?,i_calendar_id = ? ")
						.append(" Where  i_eser_docno = ?  ");
					pstmt = conn.prepareStatement(sql.toString()); 
					
					//2013-10-29||12:00	
			    	if(!"".equals(dateDDL) && !"".equals(timeDDL) ){
			    		pstmt.setTimestamp(1,GetTimestamp(dAppointMark));
			    	}else{
			    		pstmt.setTimestamp(1,null);
			    	}
				  	pstmt.setString(2, user.getEmpId());//empId
				  	pstmt.setString(3, calRS.getReferenceId());//i_eser_dochd
				  	pstmt.setString(4, iDocno);//referenceId
				  	pstmt.executeUpdate();	  	
				  	/********************************************************************/
				  	
				  	if(!"".equals(DOC_REF_ID)){ //docId
				  		String cDesc = GetDescSERV_DOCHD(conn,DOC_REF_ID);
						String msg = cDesc+",(เลือกนัด)เป็นวันที่นัดหมายใหม่  : "+dateDDL+" เวลา  "+timeDDL;
					  	   
					  	UpdateSERV_DOCHD(conn, DOC_REF_ID, newAppointCust,doString.UnicodeToMS874(msg));  
				  	}
				  	//System.out.println("---------UPDATE lan:eser_dochd success---------");
				  	
				  	int update = 0;
				  	update = UpdateESERV_DATE(conn,iDocno,iDate,iTime,dateDDL,timeDDL,projId[0],projId[1]);  ;
				  	
				  	if(update <=0 ){
				  		msgTxt = "!!! CANT UPDATE E = "+iDocno;
						try{
							conn.rollback();
						}catch(Exception ex){}
						response.sendRedirect(ERROR_PAGE+msgTxt);
						return;
				  	}
				  	
				  	update = UpdateLSERV_DATE(myConn,iDocno,iDate,iTime,dateDDL,timeDDL,projId[0],projId[1]);  ;
				  	
				  	if(update <=0 ){
				  		msgTxt = "!!! CANT UPDATE L = "+iDocno;
						try{
							myConn.rollback();
						}catch(Exception ex){}
						response.sendRedirect(ERROR_PAGE+msgTxt);
						return;
				  	}
				  	
				  	update = UpdateLSERV_HD(myConn,iDocno,iDate,iTime,dateDDL,timeDDL,projId[0],projId[1]);  ;
				  	
				  	if(update <=0 ){
				  		msgTxt = "!!! CANT UPDATE L_HD = "+iDocno;
						try{
							myConn.rollback();
						}catch(Exception ex){}
						response.sendRedirect(ERROR_PAGE+msgTxt);
						return;
				  	}
				  	
			 }
	   	    /********************************************************************/	
			 
	
			//conn.rollback();
			//myConn.rollback();
			 
			 
			 conn.commit();
	   		 conn.close();
	   		 conn = null;
   		    
	   		 myConn.commit();
			 myConn.close();
			 myConn = null;
			
   		    System.out.println("doOnChangeDate ->conn.commit()..");	
		    //*************************Search Date******************************************
	  		
   		    //clean session
	  	  	synchronized(session) { 		
		    	//Clear session
		    	session.removeAttribute("timeList");
		    	session.removeAttribute("dateList");
	  		 }	  	  	  
			//System.out.println("doOnChangeDate ->successfully.");		
       	 
			 String param = "&projectDDL="+projDDL+"&iDocno="+iDocno+"&iLock="+iLock+"&iHouse="+iHouse;
	   		 String tarGetUrl ="/ESERV_AfterAppointDateServlet?cmd=search"+param;

	   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			 dispatcher.forward(request,response);		
		}catch(Exception e){			
			System.out.println("doOnChangeDate , " +sysName+":"+ cName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());	
			
			msgTxt = "doOnChangeDate , " +sysName+":"+ cName + " : " + e.getMessage();
			try{
				if(conn!=null){
				   conn.rollback();
				}
			}catch(Exception ex){}
			response.sendRedirect(ERROR_PAGE+msgTxt);
			return;
		}
		finally{			
			//clean up.
			//System.out.println("============ finally Any all case processing===============");
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
				if(conn!=null){conn.close();}
			}catch(Exception e){}
		}
	} 
	
//*****method FormLoad criteria projectDDL
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
		//String SUCCESS_PAGE = request.getContextPath()+"/save_ok.jsp?redirect_url=";
		
        try{      	
        	// System.out.println("formLoad ->Starting.");
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
				sql.append(" SELECT DISTINCT proj.i_company, proj.i_project, proj.n_project")
					.append(" FROM lan:acxprojt proj, lan:acsbudgh bud")
					.append(" WHERE bud.i_company = proj.i_company AND bud.i_project = proj.i_project")
					.append(" AND bud.d_year = '")
					.append(cur_year)
					.append("' ORDER BY proj.i_company, proj.i_project ");
			} else {
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
	   		 //*********Dispatcher
		  	 session.setAttribute("projDDL", projectDDL);
		  	 request.setAttribute("selProj", null);		  	 
		  	 //System.out.println("formLoad ->successfully.");	  	
	   		 String tarGetUrl ="/ESERV_Edit_AppointList.jsp";
	   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			 dispatcher.forward(request,response);			
		}catch(Exception e){
			System.out.println("doFormLoad , " +sysName+":"+ cName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
			
			   msgTxt = "doFormLoad , " +sysName+":"+ cName + " : " + e.getMessage();
			   response.sendRedirect(ERROR_PAGE+msgTxt);
			   return;
		}
		finally{			
			//clean up.
			 //System.out.println("============ finally Any all case processing===============");
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
				if(conn!=null){conn.close();}
			}catch(Exception e){}
		}
	} 
	

	//***FormPupup krub.
	protected void doFormPupup(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		StringBuffer sql = new StringBuffer();	
		ServletContext context = getServletContext();
		HttpSession session = request.getSession(false);
		//*********CurrentDate Time
		
		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
		//String SUCCESS_PAGE = request.getContextPath()+"/save_ok.jsp?redirect_url=";
		
		//GetParamRQ(request);		
        try{ 	
        	 String projDDL = doString.checkString(request.getParameter("projectDDL"),"");//projectDDL
        	 String iLock = request.getAttribute("iLock")==null?"": request.getAttribute("iLock").toString().toUpperCase();//doString.checkString(request.getParameter("iLock"),"");//bannNo  
        	 String iDocno = doString.checkString(request.getParameter("iDocno"),"");//iDocno 
        	 String iHouse = doString.checkString(request.getParameter("iHouse"),"");//iHouse        	        	 
        	 String custName = doString.checkString(request.getParameter("custName"),""); 
        	 String tel = doString.checkString(request.getParameter("tel"),"");
        	 String status = doString.checkString(request.getParameter("status"),"");

        	 //System.out.println("doFormPupup ->Starting.");	       	 
        	 String delimiter = ":";
 			 String [] projId = projDDL.split(delimiter); 	 			 
 			 ArrayList dateList = new ArrayList();
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();	
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			int i = 1;
			/****************************Search criterial by project,company && ilock ***************************************/
			sql.delete(0, sql.length());
			sql.append(" select i_eser_docno,i_company,i_project,i_lock,i_house,d_keyin, n_customer,n_cus_tel,d_appoint ,weekday(d_appoint) as iday from lan:eser_dochd  ")
			   //.append(" where f_status = 'OPN' and ") //icom
			   .append(" where i_company   = ? ")//icom
			   .append(" and i_project = ? ")//project			   			  
			   .append(" and i_eser_docno = ? ");			
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(i++, projId[0]);	
			pstmt.setString(i++, projId[1]);	
			pstmt.setString(i++, iDocno);	
			//System.out.println("SQL2 : "+sql.toString());
			rs = pstmt.executeQuery();
			ArrayList strList = new ArrayList();
			if(rs.next()){
					//strList =  new ArrayList(); 
					strList.add(0,  doString.checkString(rs.getString("i_eser_docno"),""));
					strList.add(1,  doString.checkString(rs.getString("i_company"),""));
					strList.add(2,  doString.checkString(rs.getString("i_project"),""));
					strList.add(3,  doString.checkString(rs.getString("i_lock"),""));
					strList.add(4,  doString.checkString(rs.getString("i_house"),""));
					strList.add(5,  doString.checkString(rs.getString("d_keyin"),""));
					strList.add(6,  doString.checkString(rs.getString("n_customer"),""));
					strList.add(7,  doString.checkString(rs.getString("n_cus_tel"),""));					
					strList.add(8,  doString.checkString(rs.getString("d_appoint"),""));	
					strList.add(9,  doString.checkString(rs.getString("iday"),"7"));
					
					strList.add(10,GetDateDCloseLaw(conn, doString.checkString(rs.getString("i_company"),"")
							,doString.checkString(rs.getString("i_project"),"")
							,doString.checkString(rs.getString("i_lock"),"")));
			}
			rs.close();					
			/****************************Search criterial by project,company && ilock ***************************************/
			
			/******************************************************
			* Modify by pradoem : 2014.04.22
			* */
			String fixDay = "45";
			sql.delete(0,sql.length());
			sql.append(" Select fix_time  From lan:SVC_STDPJ ")
				.append(" Where i_company = 'LH' and i_project = 'SVC'  ");
			//System.out.println(" SQL Get Days :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString());
			rs = pstmt.executeQuery();	
			if(rs.next()){				
				fixDay = doString.checkString(rs.getString("fix_time"),"");
			}rs = null;
			/******************************************************/
			
			sql.delete(0,sql.length());
			sql.append(" select distinct i_date,weekday(i_date) as iday from lan:eser_date where i_company = ? and i_project = ?  ")
			   .append(" and i_date >= today and i_date <= today+"+fixDay+" units day and i_eser_docno is null  and i_date_type in('01','02')  ")
			   .append(" order by i_date ");
			//and q_apptime_fr1[4,5]  in ('00','30') 
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1,projId[0]);//icom_ID
			pstmt.setString(2,projId[1]);//iproj_ID				  
			rs = pstmt.executeQuery();
			List strArr = null;
			while(rs.next()){
				  strArr = new ArrayList();
				  strArr.add(0,doString.checkString(rs.getString("i_date"),""));				  
				  strArr.add(1,doString.checkString(rs.getString("iday"),"7"));
				  dateList.add(strArr);
			  }  
			//*********Dispatcher******************
			 session.setAttribute("result", strList);
			 session.setAttribute("dateList", dateList);
			 
		  	 request.setAttribute("selProj", projDDL);	
		  	 request.setAttribute("iLock", iLock);	
		  	 request.setAttribute("iDocno", iDocno);	
		  	 request.setAttribute("iHouse", iHouse);
		  	 
		  	 request.setAttribute("custName", custName);
		  	 request.setAttribute("tel", tel);
		  	 request.setAttribute("status", status);
  	 
		  	 //System.out.println("doFormPupup ->successfully.");	  		  	 
	   		 String tarGetUrl ="/ESERV_Edit_AppointPopup.jsp";
	   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			 dispatcher.forward(request,response);			
		}catch(Exception e){
			System.out.println("doFormPupup , " +sysName+":"+ cName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
			
			msgTxt = "doFormPupup , " +sysName+":"+ cName + " : " + e.getMessage();
		    response.sendRedirect(ERROR_PAGE+msgTxt);
			return;
		}
		finally{			
			//clean up.
			  //System.out.println("============ finally Any all case processing===============");
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
				if(conn!=null){conn.close();}
			}catch(Exception e){}
		}
	} 
	
	//***FormPupup krub.
	protected void doChangeDateDDL(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		StringBuffer sql = new StringBuffer();	
		ServletContext context = getServletContext();
		HttpSession session = request.getSession(false);
		//*********CurrentDate Time
		//GetParamRQ(request);
		
		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
		//String SUCCESS_PAGE = request.getContextPath()+"/save_ok.jsp?redirect_url=";

		
        try{ 	
        	 String projDDL = doString.checkString(request.getParameter("projectDDL"),"");//projectDDL
        	 String iLock = doString.checkString(request.getParameter("iLock"),"");//bannNo  
        	 String iDocno = doString.checkString(request.getParameter("iDocno"),"");//iDocno 
        	 String iHouse = doString.checkString(request.getParameter("iHouse"),"");//iHouse        	        	 
        	 String dateDDL = doString.checkString(request.getParameter("dateDDL"),"");//dateDDL
        	 
        	// System.out.println("doChangeDateDDL ->Starting.");	       	 
        	 String delimiter = ":";
 			 String [] projId = projDDL.split(delimiter); 	 			 
 			// ArrayList dateList = new ArrayList();
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			ArrayList arr = new ArrayList();
			//int i = 1;
			//Date d = new Date();
			//int timeCurrent = Integer.parseInt(d.getHours()+""+d.getMinutes());
			
			//int hour       = calendar.get(Calendar.HOUR);        // 12 hour clock
			//int hourOfDay  = calendar.get(Calendar.HOUR_OF_DAY); // 24 hour clock			
			Calendar cal = Calendar.getInstance();
			cal.add(Calendar.HOUR_OF_DAY, 1);// Add 1 hour
			int timeCurrentPlus1Hour = Integer.parseInt(cal.get(Calendar.HOUR_OF_DAY)+""+(cal.get(Calendar.MINUTE))); 
			//System.out.println("<<-timeInt:"+timeCurrentPlus1Hour);
			//timeList = new ArrayList();
			ArrayList strArr = null;
			StringBuffer tempInt = new StringBuffer();
			StringBuffer strMun = new StringBuffer();
			StringBuffer strSec = new StringBuffer();
			int getTimeInt = 0;
			sql.delete(0,sql.length());
			sql.append("  select  q_apptime_fr1  from lan:eser_date  ")
		   		.append(" where i_date = ? and i_company =? and i_project = ? and i_eser_docno is null and i_date_type in ('01','02') ");// and q_apptime_fr1[4,5]  in ('00','30')			
			 pstmt = conn.prepareStatement(sql.toString()); 
			 pstmt.setString(1,dateDDL);//appointDate
			 pstmt.setString(2,projId[0]);//i_company
			 pstmt.setString(3,projId[1]);//i_project
			 //System.out.println("--->ListESerTime :"+sql.toString());
			 rs = pstmt.executeQuery();			
			 boolean isDate = false; 
			//2013-09-04 = 2013-09-05 ?
			if(Now("yyyy-MM-dd").equals(dateDDL)){
					isDate = true;
			}else{
					isDate = false;
			}		 
			//System.out.println("TODAY :"+Now("yyyy-MM-dd"));
			//System.out.println("select date :"+dateDDL);
			while (rs.next()) {
					strArr = new ArrayList();	
					getTimeInt = 0;
					tempInt.delete(0,tempInt.length());
					tempInt.append(doString.checkString(rs.getString("q_apptime_fr1"),"00:00")); //11:00
					
					strMun.delete(0,strMun.length());
					strSec.delete(0,strSec.length());
					strMun.append(tempInt.toString().substring(0,2));//11
					strSec.append(tempInt.toString().substring(3));//05							
					getTimeInt = Integer.parseInt(strMun+""+strSec);					  
					//System.out.println("-->current time :"+timeCurrent);											
					if(isDate){						
						if(getTimeInt>=timeCurrentPlus1Hour){
							strArr.add(0,doString.checkString(rs.getString("q_apptime_fr1"),""));					  
							arr.add(strArr);
						}
					}else{
						strArr.add(0,doString.checkString(rs.getString("q_apptime_fr1"),""));					  
						arr.add(strArr);
					}						
			 } // End if rs
			 //System.out.println("--->ListESerTime :successfuly.");
		    //*************************Search Date******************************************
			 session.setAttribute("timeList", arr);			 
		  	 request.setAttribute("selProj", projDDL);	
		  	 request.setAttribute("iLock", iLock);	
		  	 request.setAttribute("iDocno", iDocno);	
		  	 request.setAttribute("iHouse", iHouse);			  	 
		  	 //System.out.println("doChangeDateDDL ->successfully.");	  		  	 
	   		 String tarGetUrl ="/ESERV_Edit_AppointPopup.jsp";
	   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			 dispatcher.forward(request,response);			
		}catch(Exception e){
			System.out.println("doChangeDateDDL , " +sysName+":"+ cName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
			
			msgTxt = "doChangeDateDDL , " +sysName+":"+ cName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
			return;
		}
		finally{			
			//clean up.
			//System.out.println("============ finally Any all case processing===============");
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
				if(conn!=null){conn.close();}
			}catch(Exception e){}
		}
	} 

	
	//***FormSearch krub.
	protected void doFormSearch(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		StringBuffer sql = new StringBuffer();	
		ServletContext context = getServletContext();
		//HttpSession session = request.getSession(false);
		//*********CurrentDate Time

		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
		//String SUCCESS_PAGE = request.getContextPath()+"/save_ok.jsp?redirect_url=";
	
		//GetParamRQ(request);
		
        try{ 
	
        	 String projDDL = doString.checkString(request.getParameter("projectDDL"),"");//projectDDL
        	 String iLock =  request.getParameter("iLock")==null?"": request.getParameter("iLock").toString().toUpperCase();
        	 //doString.checkString(request.getParameter("iLock"),"");//bannNo  
        	 String iDocno = doString.checkString(request.getParameter("iDocno"),"");//iDocno 
        	 String iHouse = doString.checkString(request.getParameter("iHouse"),"");//iHouse         	        	 
        	 //System.out.println("doFormSearch ->Starting.");
        	 if(projDDL.equals("")){
        		 return;
        	 }
        	 String delimiter = ":";
 			 String [] projId = projDDL.split(delimiter); 	
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			
			int i = 1;
			/****************************Search criterial by project,company && ilock ***************************************/
			sql.delete(0, sql.length());
			sql.append(" select i_eser_docno,i_company,i_project,i_lock,i_house,d_keyin, n_customer,n_cus_tel,d_appoint ,weekday(d_appoint) as iday, i_docno,i_calendar_id  ")
			   .append(" from lan:eser_dochd  ")
			   //.append(" where f_status = 'OPN' and ") //icom
			   .append(" where i_company   = ? ")//icom
			   .append(" and i_project = ? "); //project			   			  
			  
			  if (iDocno.trim().length()>0) {
				   sql.append(" and i_eser_docno = ? ");
			   }
			   if (iLock.trim().length()>0) {
				   sql.append(" and i_lock = ? ");
			   }
			   if (iHouse.trim().length()>0) {
				   sql.append(" and i_house = ? ");
			   }			  
			   sql.append(" and d_appoint >= today  ")
			     /* .append(" and (i_docno is  null or i_docno == '') ")*/
			      .append(" and d_appoint is not null order by i_eser_docno ");

			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(i++, projId[0]);	
			pstmt.setString(i++, projId[1]);	
			if(iDocno.trim().length()>0) {
				pstmt.setString(i++, iDocno.trim());	
			}
			if(iLock.trim().length()>0) {
				pstmt.setString(i++, iLock.toUpperCase().trim());	
			}
			if (iHouse.trim().length()>0) {
				pstmt.setString(i++, iHouse.trim());	
			}
			//System.out.println("SQL2 : "+sql.toString());
			rs = pstmt.executeQuery();
			List strList = null;
			ArrayList result = new ArrayList();
			while(rs.next()){
					strList =  new ArrayList(); 
					strList.add(0,  doString.checkString(rs.getString("i_eser_docno"),""));
					strList.add(1,  doString.checkString(rs.getString("i_company"),""));
					strList.add(2,  doString.checkString(rs.getString("i_project"),""));
					strList.add(3,  doString.checkString(rs.getString("i_lock"),""));
					strList.add(4,  doString.checkString(rs.getString("i_house"),""));
					strList.add(5,  doString.checkString(rs.getString("d_keyin"),""));
					strList.add(6,  doString.checkString(rs.getString("n_customer"),""));
					strList.add(7,  doString.checkString(rs.getString("n_cus_tel"),""));					
					strList.add(8,  doString.checkString(rs.getString("d_appoint"),""));	
					strList.add(9,  doString.checkString(rs.getString("iday"),"7"));
					
					strList.add(10,GetDateDCloseLaw(conn, doString.checkString(rs.getString("i_company"),"")
							,doString.checkString(rs.getString("i_project"),"")
							,doString.checkString(rs.getString("i_lock"),"")));
					strList.add(11, doString.checkString(rs.getString("i_docno"),""));
					strList.add(12, doString.checkString(rs.getString("i_calendar_id"),""));
					
					result.add(strList);
					//doString.checkString(doString.DisplayThai(rs.getString("n_customer")),"");
			}
			rs.close();					
			/****************************Search criterial by project,company && ilock ***************************************/

			//*********Dispatcher******************
			 request.setAttribute("result", result);
		  	 request.setAttribute("selProj", projDDL);	
		  	 request.setAttribute("iLock", iLock.toUpperCase());	
		  	 request.setAttribute("iDocno", iDocno);	
		  	 request.setAttribute("iHouse", iHouse);	
		  	 
		  	 //System.out.println("doFormSearch ->successfully.");	  		  	 
	   		 String tarGetUrl ="/ESERV_Edit_AppointList.jsp";
	   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			 dispatcher.forward(request,response);			
		}catch(Exception e){
			System.out.println("doFormSearch , " +sysName+":"+ cName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
			
			msgTxt = "doChangeDateDDL , " +sysName+":"+ cName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
			return;
		} 
		finally{			
			//clean up.
			//System.out.println("============ finally Any all case processing===============");
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
				if(conn!=null){conn.close();}
			}catch(Exception e){}
		}
	} 
	
	
	public String GetDateDCloseLaw(Connection conn, String compId,
			String projectId, String lock) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		//boolean  isGuranTee = false;
		String FLAG = "N";
        try{
        	//initial parameter	  
			/*************************************************/		    	
			sql.delete(0,sql.length());
			sql.append(" select d_close_law From lan:eser_lock ")
			   .append(" where i_company = ?  and i_project =?  and i_lock = ? ");
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, compId);	
			pstmt.setString(2, projectId);
			pstmt.setString(3, lock);
			
			//System.out.println("GetDateDCloseLaw  SQL :"+sql.toString());
			rs = pstmt.executeQuery();	
			if(rs.next()){
				Timestamp dCloseLaw = rs.getTimestamp("d_close_law");
				if (dCloseLaw==null) {
					//obj.setFlagGuranteeDate(Constant.FLAG_GURANTEE_N); //not guruntee
					//isGuranTee = false; //NO
					FLAG = "N";
				} else {
					Calendar calGurantee = Calendar.getInstance(); 
					calGurantee.setTime(dCloseLaw);
					calGurantee.add(Calendar.YEAR,1);
					if (Calendar.getInstance().after(calGurantee)) {
						//obj.setFlagGuranteeDate(Constant.FLAG_GURANTEE_N); //Not gurantee
						//isGuranTee = false;//NO
						FLAG = "N";
					}else{
						//obj.setFlagGuranteeDate(Constant.FLAG_GURANTEE_Y);//bettween gurantee
						//isGuranTee = true; //YES
						FLAG = "Y";
					}
				}
			}
			rs.close();				
			//**************************************************/
		  	//System.out.println("##GetDateDCloseLaw ->successfully.");				  	 
			return FLAG;			  	 
		}catch(Exception e){
			System.out.println("!!!GetDateDCloseLaw ," + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
			return "N";
		}
		finally{			
			//clean up.
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
			}catch(Exception e){}
		}
	}
	
	 public static String Now(String dateFormat) {
		    Calendar cal = Calendar.getInstance();
		    SimpleDateFormat sdf = new SimpleDateFormat(dateFormat);
		    return sdf.format(cal.getTime());
	  }
	 

	private static String GetDescSERV_DOCHD(Connection conn, String docId) {
			StringBuffer sql = new StringBuffer();
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			//boolean isResult = false;
			String cDesc = "";
			try{
					sql.delete(0, sql.length());
					sql.append(" Select c_desc  From lan:serv_dochd Where i_docno = ? ");
					//System.out.println("SQL :"+sql.toString());
					pstmt = conn.prepareStatement(sql.toString()); 
					pstmt.setString(1,docId); //LH
					rs = pstmt.executeQuery();
					if(rs.next()){
						cDesc = doString.DisplayThai(doString.checkString(rs.getString("c_desc"), ""));
						//isResult = true;
					} // End if rs
					
					return cDesc;
			}catch(Exception e){
				//e.fillInStackTrace();
				System.out.println("!!! GetDescSERV_DOCHD ," + e.getMessage());
				System.out.println("!!! SQL Exception: "+sql.toString());	
				return cDesc;
			}
			finally{
				//clean up.
				try{
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
				}catch(Exception e){}
			}
		}
	
	 private static int UpdateSERV_DOCHD(Connection conn,String docId, String dAppointCust, String cDesc) {
			StringBuffer sql = new StringBuffer();
			PreparedStatement pstmt = null;
			//int i = 1;
			//***********
			try{
					//***************************************/
					sql.delete(0, sql.length());
					sql.append(" UPDATE lan:SERV_DOCHD SET  d_appoint_cust = ? ");

					//value is null or Empty skip not' update record
					if(isValueStrAndObj(cDesc)){
						sql.append(" ,c_desc = ? ");
					}
					sql.append(" Where i_docno = ? ");				
					//System.out.println("-->Update SQL :"+sql.toString());
					pstmt = conn.prepareStatement(sql.toString()); 
					int i = 1;
					
					//val 2013-10-29|12:00	
					if(null!=dAppointCust){
			    		pstmt.setTimestamp(i++,GetTimestamp(dAppointCust));
			    	}else{
			    		pstmt.setTimestamp(i++,null);
			    	}
			    	
					if(isValueStrAndObj(cDesc)){
						pstmt.setString(i++,cDesc);
					}
					pstmt.setString(i++,docId);

					int intUdp = pstmt.executeUpdate();
		   			
		   		  	/********************************/		
					//System.out.println("## UpdateSERV_DOCHD : successfully.");
		   		  	return intUdp;			
			}catch(Exception e){
				System.out.println("!!! UpdateSERV_DOCHD ," + e.getMessage());
				System.out.println("!!! SQL Exception: "+sql.toString());		
				return -1; // update failure
			}finally{
				try {
					   if(pstmt!=null){
						  pstmt.close();
					    }	
					}catch (SQLException e) {
					    e.printStackTrace();
				    }
			}
		}	
	 
	 
	 
	 private static int UpdateESERV_DATE(Connection conn,String iDocno, String iDate, String iTime,String dateDDL,String timeDDL ,String iCom,String iPro ) {
			StringBuffer sql = new StringBuffer();
			PreparedStatement pstmt = null;
			//int i = 1;
			//***********
			String sql_d ="";
			int i = 1; 
			int intUdp = -1;
			
			try{
					//***************************************/
				
				sql_d = "UPDATE lan:eser_date SET i_eser_docno = NULL, i_system = NULL WHERE i_eser_docno = '"+iDocno+"'";
					pstmt = conn.prepareStatement(sql_d);
					intUdp = pstmt.executeUpdate();
				
				if(intUdp>0){
					sql.delete(0, sql.length());
					sql.append(" UPDATE lan:eser_date SET i_eser_docno = ? , i_system  = ? ")
						.append("WHERE i_company = ? ")
						.append("AND i_project = ? ")
						.append("AND i_date  = ? ")
						.append("AND q_apptime_fr1 = ? ");
					
					pstmt = conn.prepareStatement(sql.toString());
					
					pstmt.setObject(i++,iDocno);
					pstmt.setObject(i++,"L2");
					
					pstmt.setObject(i++,iCom);
					pstmt.setObject(i++,iPro);
					pstmt.setObject(i++,dateDDL);
					pstmt.setObject(i++,timeDDL);
					
					intUdp =  pstmt.executeUpdate(); 
					return intUdp;	
					
				}else{
					return intUdp;	
				}
			}catch(Exception e){
				System.out.println("!!! UpdateESERV_DATE ," + e.getMessage());
				System.out.println("!!! SQL Exception: "+sql.toString());		
				return -1; // update failure
			}finally{
				try {
					   if(pstmt!=null){
						  pstmt.close();
					    }	
					}catch (SQLException e) {
					    e.printStackTrace();
				    }
			}
		}	
	 
	 private static int UpdateLSERV_DATE(Connection conn,String iDocno, String iDate, String iTime,String dateDDL,String timeDDL ,String iCom,String iPro ) {
			StringBuffer sql = new StringBuffer();
			PreparedStatement pstmt = null;
			//int i = 1;
			//***********
			String sql_d ="";
			int i = 1; 
			int intUdp = -1;
			
			try{
					//***************************************/
				
				sql_d = "UPDATE `lser_date` SET `i_docno` = ''  WHERE `i_docno` = '"+iDocno+"'";
					pstmt = conn.prepareStatement(sql_d);
					intUdp = pstmt.executeUpdate();
				
				if(intUdp>0){
					sql.delete(0, sql.length());
					sql.append("UPDATE `lser_date` SET `i_docno` = ?  ")
						.append("WHERE `i_company` = ? ")
						.append("AND `i_project` = ? ")
						.append("AND `i_date` = ? ")
						.append("AND `i_time` = ?");
					
					pstmt = conn.prepareStatement(sql.toString());
					
					pstmt.setObject(i++,iDocno);
					
					pstmt.setObject(i++,iCom);
					pstmt.setObject(i++,iPro);
					pstmt.setObject(i++,dateDDL);
					pstmt.setObject(i++,timeDDL+":00");
					intUdp =  pstmt.executeUpdate(); 
					return intUdp;	
					
				}else{
					return -1;	
				}
			}catch(Exception e){
				System.out.println("!!! UpdateLSERV_DATE ," + e.getMessage());
				System.out.println("!!! SQL Exception: "+sql.toString());		
				return -1; // update failure
			}finally{
				try {
					   if(pstmt!=null){
						  pstmt.close();
					    }	
					}catch (SQLException e) {
					    e.printStackTrace();
				    }
			}
		}
	 
	 private static int UpdateLSERV_HD(Connection conn,String iDocno, String iDate, String iTime,String dateDDL,String timeDDL ,String iCom,String iPro ) {
			StringBuffer sql = new StringBuffer();
			PreparedStatement pstmt = null;
			//int i = 1;
			//***********
			int i = 1; 
			int intUdp = -1;
			
			try{
					//***************************************/
				
					sql.delete(0, sql.length());
					sql.append("UPDATE `lser_dochd` SET `d_appoint` = ? ,`time_appoint` = ?   ")
						.append("WHERE `i_line_docno` = ? ");
					
					pstmt = conn.prepareStatement(sql.toString());
					
					pstmt.setObject(i++,dateDDL);
					pstmt.setObject(i++,timeDDL+":00");
					pstmt.setObject(i++,iDocno);
					
					intUdp =  pstmt.executeUpdate(); 
					return intUdp;	
					
			}catch(Exception e){
				System.out.println("!!! UpdateLSERV_HD ," + e.getMessage());
				System.out.println("!!! SQL Exception: "+sql.toString());		
				return -1; // update failure
			}finally{
				try {
					   if(pstmt!=null){
						  pstmt.close();
					    }	
					}catch (SQLException e) {
					    e.printStackTrace();
				    }
			}
		}
	 
	 private static Timestamp GetTimestamp(String param){
	    	Calendar cal = Calendar.getInstance(Locale.ENGLISH);
	    	 if("".equals(param)||null==param){
	    		 return new Timestamp(cal.getTimeInMillis());
	    	 }
	    	 //Calendar cal = Calendar.getInstance(Locale.ENGLISH);
	    	 //System.out.println(param);
	    	 String temp[] = param.split("\\|");
	    	 String dTemp[] = temp[0].split("\\-");
	    	 String tTemp[] = temp[1].split("\\:");
	    	 cal.set(Integer.parseInt(dTemp[0]),Integer.parseInt(dTemp[1])-1,Integer.parseInt(dTemp[2]),Integer.parseInt(tTemp[0]),Integer.parseInt(tTemp[1]));

	    	 return new Timestamp(cal.getTimeInMillis());
	    }
	 
	private static boolean isValueStrAndObj(String str) throws Exception{
			if ((str == null) || str.equals("")) {
				 return false;
			}else{
				 return true;
			 }
	}
		    
	private void GetParamRQ(HttpServletRequest request){
			Enumeration <String> paramName = (Enumeration<String>) request.getParameterNames();
			 while (paramName.hasMoreElements()) {
			            String element = (String) paramName.nextElement();
			            System.out.println(element + " = " + request.getParameter(element));
			}
	  }

}