package serv.servlets;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
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
import com.lh.util.doString;
import com.svc.call.ws.webservice.WebService;
import com.svc.ws.model.GCalendarRQ;
import com.svc.ws.model.GCalendarRS;
/**
 * Servlet implementation class for Servlet: ESERV_OpenJobServlet
 * create by : pradoem wonkraso
 * update date : 22-09-2020
 * date time: 2012-03-15
 * List modify : 2014.02.18
 * comment: for Select ,Get ,Update,Insert  and Support E-Service System 
 * Open Job  
 */
 public class ESERV_OpenJobServlet  extends DBServlet{
	public ESERV_OpenJobServlet() {
		super();
	}  
	String sysName = "LHServ";
    String cName = new String(this.getClass().getName() + ".performTask :");	

	static String host = "132.144.1.61";
	//host = "www10.lh.co.th";
	static String port = "3306";
	static String dns = "LH_LineService";
	//String schemaName = "onnetimp";
	static String user = "lineapp_db"; //testlan_db
	static String password = "xsw21qaz";
    
    /*static String host = Utilizer.getPropValue("mysql_host");
	static String port = Utilizer.getPropValue("mysql_port");
	static String dns = Utilizer.getPropValue("mysql_dns");
	static String user = Utilizer.getPropValue("mysql_user");
	static String password = Utilizer.getPropValue("mysql_password");
	*/
	//password = "7cQ3VxNMHo2L";
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
		/* medthod action
		 **************** */
		try{
			  String  command = request.getParameter("cmd")==null?"":request.getParameter("cmd");					
			  if(command.equals("find")){			
				  this.doRetrieve(request,response);				
			  }else if(command.equals("view")){
				  this.doViewer(request,response);  
			  }else if(command.equals("can")){
				  this.doCancel(request, response, user);
			  }else if(command.equals("add")){
				   String eserDocId = doString.checkString(request.getParameter("eser_docno"),"");
				   if("".equals(eserDocId)){//Case e_serDocId is null
						System.out.println("!!! Find not' found reference Id by iDoc = "+eserDocId);	
						//msgTxt = "!!ระบบไม่สามาถทำรายการได้เนื่องจากไม่มีเลขที่เอกสาร กรุณาติดต่อผู้ดูแลระบบ 'ระหัสโครงการ : "+selProj+"' ";
						//response.sendRedirect(ERROR_PAGE+doString.UnicodeToMS874(msgTxt));
						return;
				    }else{
				    	if(eserDocId.indexOf("L-")!= -1){ 
				    		 this.doGenOpenJobLSV(request, response, user);
						}else{
							 this.doGenOpenJobESV(request, response, user);
						}
				    }
			  }
		}catch(Exception e){
			e.printStackTrace();
			System.out.println(sysName+":"+cName +" "+e.toString());		
		}finally{
		}
	}
	

//	Retrieve Record
	protected void doViewer(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;	
		StringBuffer sql = new StringBuffer();			
		
		String eserDocId = doString.checkString(request.getParameter("i_docno"),"");
		String selProj  = doString.checkString(request.getParameter("sel_project"),"").toUpperCase(); 		
		String timeLine = doString.checkString(request.getParameter("timeLine"),"");
		String appointDate  =  doString.checkString(request.getParameter("appointDate"),"");
		String iDay  =  doString.checkString(request.getParameter("iDay"),"");			
		//String iHouse = doString.checkString(request.getParameter("iHouse"),"");
		//String status = doString.checkString(request.getParameter("status"),"");
		
		
		//GetParamRQ(request);		
		String tbt_eserdt = "eser_docdt";
		
		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
		//String SUCCESS_PAGE = request.getContextPath()+"/save_ok.jsp?redirect_url=";
		ServletContext context = getServletContext();
       try{
    	    List   list = new ArrayList<String>();  
    	    List   strList = null;
    	    List list2 = new ArrayList();
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			//conn.setAutoCommit(false);
	
			/********************************************************************/
			String delimiter = "\\-";
			String tempId [] = eserDocId.split(delimiter);	
			//E-LH-075-560005
			/********************************************************************/
			sql.delete(0,sql.length());
			sql.append("  select a.i_eser_docno,a.i_lock,a.d_keyin,a.i_customer,a.n_customer,a.n_cus_tel , b.n_project from lan:eser_dochd a,lan:acxprojt b ")
				.append(" Where a.i_company = ? and a.i_project = ? and a.i_eser_docno = ?  and a.i_company = b.i_company and a.i_project = b.i_project");
			
			pstmt = conn.prepareStatement(sql.toString()); 
		  	pstmt.setString(1, tempId[1]);//i_company
		  	pstmt.setString(2, tempId[2]);//i_project
		  	pstmt.setString(3, eserDocId);//i_eser_dochd
			rs = pstmt.executeQuery();
			//System.out.println("-->SQL#1:"+sql.toString());
			if(rs.next()){
				list.add(0,  doString.checkString(rs.getString("i_lock"),""));
				list.add(1,  doString.checkString(rs.getString("d_keyin"),""));
				list.add(2,  doString.checkString(rs.getString("i_customer"),""));
				list.add(3,  doString.checkString(rs.getString("n_customer"),""));
				list.add(4,  doString.checkString(rs.getString("n_cus_tel"),""));
				list.add(5,  doString.checkString(rs.getString("n_project"),""));
			}
   		  	rs.close();
   		  	/********************************************************************/
   		  	sql.delete(0,sql.length());
			sql.append("  select a.i_model,a.i_house,b.i_exp_intent1,b.i_cus_intent1,date(b.d_close_law)+365 as d_close_law ")
				.append(" from lan:acxlckmd a left join lan:acscontr b ")
				.append(" on b.i_company = a.i_company and b.i_project = a.i_project ")
				.append(" and b.i_lor = a.i_lor and b.f_contr is null ")
			.append(" where a.i_company=? and a.i_project = ? and a.i_lock = ? ");
			pstmt = conn.prepareStatement(sql.toString()); 
		  	pstmt.setString(1, tempId[1]);//i_company
		  	pstmt.setString(2, tempId[2]);//i_project
		  	pstmt.setString(3, list.get(0).toString());//i_lock
			rs = pstmt.executeQuery();
			//System.out.println("-->SQL#2:"+sql);
			if(rs.next()){
				//due_date = doString.checkString(rs.getString("d_due"),"");
				list.add(6,  doString.checkString(rs.getString("i_model"),""));
				list.add(7,  doString.checkString(rs.getString("i_house"),""));
				list.add(8,  doString.checkString(rs.getString("i_exp_intent1"),""));
				list.add(9,  doString.checkString(rs.getString("i_cus_intent1"),""));
				list.add(10,  doString.checkString(rs.getString("d_close_law"),""));
			}else{
				list.add(6,  "");
				list.add(7,  "");
				list.add(8,  "");
				list.add(9,  "");
				list.add(10, "");
			}
		  	rs.close();
		  	list.add(11,eserDocId);//docHD
		  	list.add(12,tempId[1]);//icom
		  	list.add(13,tempId[2]);//iproj		  	
		  	int cnt = Integer.parseInt(doString.checkString(request.getParameter("cntDesc"),"0"));		  	
		  	
		  	if(cnt>0){
		  		
	   		  	sql.delete(0,sql.length());
				sql.append("  select *  from lan:"+tbt_eserdt+" where i_eser_docno = ? and i_seq =  ? ");
				pstmt = conn.prepareStatement(sql.toString()); 


		  		for(int i =1;i<=cnt;i++){
			  		strList =  new ArrayList<String>(); 
					strList.add(0,  "");
					strList.add(1,  "");
					strList.add(2,  doString.checkString(request.getParameter("jobDesc"+i),""));
					strList.add(3,  doString.checkString(request.getParameter("rbt"+i),""));
					
     				strList.add(4,"");
     				strList.add(5,"");
					//--------------------------
				  	pstmt.setString(1,eserDocId);//ID
				  	pstmt.setInt(2, i);
					rs = pstmt.executeQuery();
					if(rs.next()){
	     				strList.add(4,doString.checkString(rs.getString("f_type"),""));
	     				strList.add(5,doString.checkString(rs.getString("img_path"),""));	
					}
					//--------------------------
					list2.add(strList);
		  		}
		  	}

		  	/********************************************************************/
	   		 //*********Dispatcher
		  	 request.setAttribute("iDay", iDay);
		  	 request.setAttribute("timeLine", timeLine);
		  	 request.setAttribute("appointDate", appointDate);
  	
		  	 request.setAttribute("list",list); 
		  	 request.setAttribute("list2", list2);
		  	 //System.out.println("doViewer successfully.");
	   		 String tarGetUrl ="/ESERV_OpenJob01.jsp?mode=view";
	   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			 dispatcher.forward(request,response);			
		}catch(Exception e){
			System.out.println("doViewer , " +sysName+":"+ cName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
		
			msgTxt = "doViewer , " +sysName+":"+ cName + " : " + e.getMessage();
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
	
	//Retrieve Record
	protected void doRetrieve(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;	
		StringBuffer sql = new StringBuffer();			
		String eserDocId = doString.checkString(request.getParameter("i_docno"),"");
		String selProj  = doString.checkString(request.getParameter("sel_project"),"").toUpperCase(); 
		String mode = doString.checkString(request.getParameter("mode"),"");

		String selectDDL = doString.checkString(request.getParameter("appointDate"),"");
		String iDay  =  doString.checkString(request.getParameter("iDay"),"");
		//GetParamRQ(request);
		ServletContext context = getServletContext();
		
		String tbt_eserdt = "eser_docdt";
		
		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
		//String SUCCESS_PAGE = request.getContextPath()+"/save_ok.jsp?redirect_url=";
       try{
    	    List   list = new ArrayList<String>();  
    	    List   strList = null;
    	    List list2 = new ArrayList();
			
    	    int cnt = Integer.parseInt(doString.checkString(request.getParameter("cntDesc"),"0"));
    	    //System.out.println("--->TEST :"+cnt);
    	    List descList = null;
    	    List rbtList = null;
    	   // System.out.println("TEST 111");
    	    if(cnt>0){
    	    	descList = new ArrayList();
    	    	rbtList  = new ArrayList();
    	    	int loop = 1;
    	    	//System.out.println("TEST 22222");
	    	    for(int c=0;c<cnt;c++){
	    	    	//System.out.println("TEST 333333");
	    	    	descList.add(c,doString.checkString(request.getParameter("jobDesc"+loop),""));
	    	    	rbtList.add(c,doString.checkString(request.getParameter("rbt"+loop),"")); //OPN,CAN
	    	    	loop++;
	    	    }
    		}
    
    	    //Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			//conn.setAutoCommit(false);	
			/********************************************************************/
			String delimiter = "\\-";
			String tempId [] = eserDocId.split(delimiter);	
			/********************************************************************/
			String iLock = "";
			sql.delete(0,sql.length());
			sql.append("  select a.i_eser_docno,a.i_lock,a.d_keyin,a.i_customer,a.n_customer,a.n_cus_tel , b.n_project from lan:eser_dochd a,lan:acxprojt b ")
				.append(" Where a.i_company = ? and a.i_project = ? and a.i_eser_docno = ?  and a.i_company = b.i_company and a.i_project = b.i_project ");
				//.append(" order by a.i_eser_docno ");
			
			pstmt = conn.prepareStatement(sql.toString()); 
		  	pstmt.setString(1, tempId[1]);//i_company
		  	pstmt.setString(2, tempId[2]);//i_project
		  	pstmt.setString(3, eserDocId);//i_eser_dochd
			rs = pstmt.executeQuery();
			//System.out.println("-->SQL#1:"+sql.toString());
			if(rs.next()){
				iLock = doString.checkString(rs.getString("i_lock"),"");
				list.add(0,  doString.checkString(rs.getString("i_lock"),""));
				list.add(1,  doString.checkString(rs.getString("d_keyin"),""));
				list.add(2,  doString.checkString(rs.getString("i_customer"),""));
				list.add(3,  doString.checkString(rs.getString("n_customer"),""));
				list.add(4,  doString.checkString(rs.getString("n_cus_tel"),""));
				list.add(5,  doString.checkString(rs.getString("n_project"),""));
			}
   		  	rs.close();   
   		  	/********************************************************************/
   		  	sql.delete(0,sql.length());
			sql.append("  select a.i_model,a.i_house,b.i_exp_intent1,b.i_cus_intent1,date(b.d_close_law)+365 as d_close_law  ")
				.append(" from lan:acxlckmd a left join lan:acscontr b ")
				.append(" on b.i_company = a.i_company and b.i_project = a.i_project ")
				.append(" and b.i_lor = a.i_lor and b.f_contr is null ")
			.append(" where a.i_company=? and a.i_project = ? and a.i_lock = ? ");
			pstmt = conn.prepareStatement(sql.toString()); 
		  	pstmt.setString(1, tempId[1]);//i_company
		  	pstmt.setString(2, tempId[2]);//i_project
		  	pstmt.setString(3, iLock);//i_lock
			rs = pstmt.executeQuery();
			//System.out.println("-->SQL#2:"+sql);
			if(rs.next()){
				//due_date = doString.checkString(rs.getString("d_due"),"");
				list.add(6,  doString.checkString(rs.getString("i_model"),""));
				list.add(7,  doString.checkString(rs.getString("i_house"),""));
				list.add(8,  doString.checkString(rs.getString("i_exp_intent1"),""));
				list.add(9,  doString.checkString(rs.getString("i_cus_intent1"),""));
				list.add(10,  doString.checkString(rs.getString("d_close_law"),""));
			}else{
				list.add(6, "");
				list.add(7,  "");
				list.add(8,  "");
				list.add(9,  "");
				list.add(10, "");
			}
		  	rs.close();
		  	list.add(11,eserDocId);//docHD
		  	list.add(12,tempId[1]);//icom
		  	list.add(13,tempId[2]);//iproj
		  	
		  	/********************************************************************/
   		  	sql.delete(0,sql.length());
			sql.append("  select *  from lan:"+tbt_eserdt+" where i_eser_docno = ? ");
				pstmt = conn.prepareStatement(sql.toString()); 
			  	pstmt.setString(1,eserDocId);//ID
				rs = pstmt.executeQuery();
				
				int x = 0;
				while(rs.next()){
					strList =  new ArrayList<String>(); 
					strList.add(0,  doString.checkString(rs.getString("i_eser_docno"),""));
					strList.add(1,  doString.checkString(rs.getString("i_seq"),""));
					
					//For text box
					if(descList!=null && descList.size()>0){
						strList.add(2,descList.get(x)); //Get From screeen
					}else{
						strList.add(2,doString.checkString(rs.getString("c_desc"),""));
					}
					
					//For rbtButton
     				if(rbtList!=null && rbtList.size()>0){
     					strList.add(3,rbtList.get(x));
     				}else{
     					strList.add(3,doString.checkString(rs.getString("f_status"),""));
     				}    
     				strList.add(4,doString.checkString(rs.getString("f_type"),""));
     				strList.add(5,doString.checkString(rs.getString("img_path"),""));
     				
					list2.add(strList);
					
					x++;
				}
			  	rs.close(); 
 	
			  //**************************Search Date*****************************************
			  //if rs.next()  todo :xxxx
			  //else query from eser_date
			  boolean isAppointDate = false;	
			  boolean isSysLine = false;
			  ArrayList timeList = new ArrayList();
			  ArrayList appoint2List = new ArrayList();
			  String tempDateAppoint = "";
			  String appointDate = "";
			  String timeLine = "";
			 // String iDay = "";		  
			  String flagDate = "false";
			  sql.delete(0,sql.length());
			  sql.append("  select d_appoint , weekday(d_appoint) as iday from lan:eser_dochd where i_eser_docno = ? and d_appoint is not null ");//'E-LH-075-550003'			  
			  pstmt = conn.prepareStatement(sql.toString()); 
			  pstmt.setString(1,eserDocId);//ID
			  rs = pstmt.executeQuery();
			  if(rs.next()){
				  isAppointDate = true;
				  flagDate = "true";					 
				  tempDateAppoint = doString.checkString(rs.getString("d_appoint"),"");
				  iDay = doString.checkString(rs.getString("iday"),"0");
			  }
			  rs.close();		  
			  if(isAppointDate){
				  //already record 
				   flagDate = "true";	
				   timeLine = tempDateAppoint.substring(10,16);//10:00
			       appointDate = tempDateAppoint.substring(0,10);//2012-06-18					
			  }else{
				 //not record 
				  
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

				  ArrayList strArr = null;
				  flagDate = "false";
				  
				  sql.delete(0,sql.length());
				  sql.append(" select distinct i_date,weekday(i_date) as iday from lan:eser_date where i_company = ? and i_project = ?  ")
				  	 .append("  and i_date >= today and i_date <= today+"+fixDay+" units day and i_eser_docno is null  and i_date_type = '02' ")
				  	 .append(" order by i_date ");	

				  /* remark by pradoem 2023.11.15
				   * 
				   * if(eserDocId.indexOf("L-")!= -1){ 
					  sql.delete(0,sql.length());
					  sql.append(" select distinct i_date,weekday(i_date) as iday from lan:lser_date where i_company = ? and i_project = ?  ")
					  	 .append(" and  i_eser_docno is null and date(i_date)>=TODAY  and i_date_type = '03' ")
					  	 .append(" order by i_date ");		
					 
					  isSysLine = true;
				  }else{ 
					  sql.delete(0,sql.length());
					  sql.append(" select distinct i_date,weekday(i_date) as iday from lan:eser_date where i_company = ? and i_project = ?  ")
					  	 .append("  and i_date >= today and i_date <= today+"+fixDay+" units day and i_eser_docno is null  and i_date_type in ('01','02')  ")
					  	 .append(" order by i_date ");	
					  //and q_apptime_fr1[4,5]  in ('00','30')
			      } */
				  System.out.println("-->SQL DateAppoint :"+sql.toString());
				  pstmt = conn.prepareStatement(sql.toString()); 
				  pstmt.setString(1,tempId[1]);//icom_ID
				  pstmt.setString(2,tempId[2]);//iproj_ID				  

				  rs = pstmt.executeQuery();
				  while(rs.next()){
					  strArr = new ArrayList();
					  strArr.add(0,doString.checkString(rs.getString("i_date"),""));
					  strArr.add(1,"");					  
					  strArr.add(2,doString.checkString(rs.getString("iday"),"7"));
					  appoint2List.add(strArr);
					  //timeList.add(strArr);
				  }  
			  }	
			  
			  if(!selectDDL.equals("")){
				  int i = 1;
					Date d = new Date();
					//System.out.println("<<----------:"+d.getHours()+":"+d.getMinutes());
					int timeCurrent = Integer.parseInt(d.getHours()+""+d.getMinutes());
					//System.out.println("<<----------timeInt:"+timeCurrent);
					//timeList = new ArrayList();
					ArrayList strArr = null;
					StringBuffer tempInt = new StringBuffer();
					StringBuffer strMun = new StringBuffer();
					StringBuffer strSec = new StringBuffer();
					int getTimeInt = 0;
					
					/* new 2023.11.15 merge LINE&SVC */
					sql.delete(0,sql.length());
					sql.append("  select  q_apptime_fr1  from lan:eser_date  ")
				   		.append(" where i_date = ? and i_company =? and i_project = ? and i_eser_docno is null and i_date_type = '02' ");
					
					/*
					 * remark by pradoem 2023.11.15
					 * if(isSysLine){ //for line
						sql.delete(0,sql.length());
						sql.append("  select  q_apptime_fr1  from lan:lser_date  ")
					   		.append(" where i_date = ? and i_company =? and i_project = ? and i_eser_docno is null and i_date_type = '02' ");	
					}else{
						sql.delete(0,sql.length());
						sql.append("  select  q_apptime_fr1  from lan:eser_date  ")
					   		.append(" where i_date = ? and i_company =? and i_project = ? and i_eser_docno is null and i_date_type in ('01','02')  ");	//and q_apptime_fr1[4,5]  in ('00','30')
					}*/
					 //System.out.println("SQL Time :"+sql.toString());
					 pstmt = conn.prepareStatement(sql.toString()); 
					 pstmt.setString(1,selectDDL);//appointDate
					 pstmt.setString(2,tempId[1]);//i_company
					 pstmt.setString(3,tempId[2]);//i_project
					 //System.out.println("--->ListESerTime :"+sql.toString());
					 rs = pstmt.executeQuery();			
					boolean isDate = false; 
					if(Now("yyyy-MM-dd").equals(selectDDL)){
							isDate = true;
					}else{
							isDate = false;
					}		 
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
							//System.out.println("-->Get time :"+getTimeInt);
							//System.out.println("-->current time :"+timeCurrent);														
							if(isDate){						
								if(getTimeInt>=timeCurrent ){
									strArr.add(0,doString.checkString(rs.getString("q_apptime_fr1"),""));					  
									timeList.add(strArr);
								}
							}else{
								strArr.add(0,doString.checkString(rs.getString("q_apptime_fr1"),""));					  
								timeList.add(strArr);
							}						
					 } // End if rs
					 appointDate = selectDDL;
				    //*************************Search Date******************************************
			  }
			  //*************************Search Date******************************************
		  	  //for appointDate
			  request.setAttribute("flagDate", flagDate);
			  request.setAttribute("timeLine", timeLine);
			  request.setAttribute("appointDate", appointDate);
			  request.setAttribute("iDay", iDay);
			  request.setAttribute("timeList", timeList); //0,1
			  request.setAttribute("appoint2List", appoint2List); //Array of Array			  
	   		 //*********Dispatcher
		  	 request.setAttribute("list",list); 
		  	 request.setAttribute("list2", list2);		  	 
		  	 //System.out.println("---->doRetrieve successfully.");
	   		 String tarGetUrl ="/ESERV_OpenJob01.jsp?mode="+mode;
	   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			 dispatcher.forward(request,response);			
		}catch(Exception e){
			System.out.println("doRetrieve , " +sysName+":"+ cName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
			
			msgTxt = "doRetrieve , " +sysName+":"+ cName + " : " + e.getMessage();
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
	
	//doCancelation transaction
	protected void doCancel(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;	
		StringBuffer sql = new StringBuffer();			
		//GetParamRQ(request);
		 Connection myConn = null;
		 PreparedStatement myPstmt = null;
		 ResultSet myRs = null;	
		 boolean isAppointFlag = true;
		 
		 String MYSQL_LSER_DATE = "lser_date";
		 String ESER_DATE = "eser_date";
		
		 String msgTxt = "";
		 String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
		 //String SUCCESS_PAGE = request.getContextPath()+"/save_ok.jsp?redirect_url=";
		
		 ServletContext context = getServletContext();
         try{
   		
   			String eserDocId = doString.checkString(request.getParameter("i_docno"),"");		
    	    String comId =  doString.checkString(request.getParameter("comId"),"");	
    	    String projectId = doString.checkString(request.getParameter("projectId"),"");	
    		String timeLine = doString.checkString(request.getParameter("timeLine"),"");//AppiontTime
    		String appointDate  =  doString.checkString(request.getParameter("appointDate"),"");//AppointDate
    	   //Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			/*******************************************
			 * TODO: Flow processing
			 * CAN Case#1 appoint date is not null
			 * 1.Flag eser_dochd 
			 * CAN Case#2 appoint date is null
			 * 1.select reference id from eser_dochd is available or existing field
			 * 2.call web GCALWebService Interface for Delelete google calendar
			 * 3.update eser_dochd and i_calendar_id is null also
			 * ******************************************/
			boolean isLine = false;
			if(eserDocId.indexOf("L-")!= -1){ 
				MYSQL_LSER_DATE = "lser_date";
				isLine = true;
			}else{
				ESER_DATE = "eser_date";
				isLine = false;
			}
			
		  	String iDate = "";
		  	String iTime = "";
		  	//String iCom = "";
		  	//String iProj = "";
		  	String refId = "";
		  	boolean isFlagUp = true;
		  	
			sql.delete(0,sql.length());
			sql.append(" select i_calendar_id from lan:eser_dochd ")
		   	   .append(" where i_company = ? and i_project = ? and i_eser_docno = ?  ");			
			 pstmt = conn.prepareStatement(sql.toString()); 
			 pstmt.setString(1,comId);//comId
			 pstmt.setString(2,projectId);//proejctId
			 pstmt.setString(3,eserDocId);//doc
			 //System.out.println("--->Validate refId:"+sql.toString());
			 rs = pstmt.executeQuery();
			 if(rs.next()){
				 refId =  doString.checkString(rs.getString("i_calendar_id"),"");
			 }
			 
			 //---Update by pradoem20200928
	   		  //Validate appion flag
	   		 String tempDoc = "";
			 sql.delete(0,sql.length());
			 sql.append(" Select i_company,i_project,i_date,q_apptime_fr1,i_eser_docno From lan:"+ESER_DATE)
				.append(" Where  i_company = '"+comId+"'  and i_project = '"+projectId+"' and i_date = '"+appointDate+"' and q_apptime_fr1 = '"+timeLine+"'  and i_date_type = '02' ");			
				pstmt = conn.prepareStatement(sql.toString()); 
				//pstmt.setString(1,eserDocId);//doc
				//System.out.println("--->(doGenOpenJobLSV)Validate SQL :"+sql.toString());
				rs = pstmt.executeQuery();
				if(rs.next()){
					tempDoc = doString.checkString(rs.getString("i_eser_docno"),"");
				}
				if((tempDoc == null) || tempDoc.equals("")) {
					 isAppointFlag = false; //Not Appointment 
				}else{
				    isAppointFlag = true; //Appointmented
				}
			//------------------------------
			 
			conn.setAutoCommit(false);
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			/********************************************************************/
			
			 //System.out.println("refId :"+refId);
			 if(!"".equals(refId)){
				 	//*****CASE#1
				 	//*****CASE#2
				  	sql.delete(0,sql.length());
					sql.append(" Select i_company,i_project,i_date,q_apptime_fr1 From lan:"+ESER_DATE)
				   		.append(" where  i_eser_docno =? ");			
					 pstmt = conn.prepareStatement(sql.toString()); 
					 pstmt.setString(1,eserDocId);//doc
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
						//System.out.println("!!! Find not' found i_eser_docno = "+eserDocId);	
						msgTxt = "!!! Find not' found i_eser_docno = "+eserDocId;
						response.sendRedirect(ERROR_PAGE+msgTxt);
						return;
					 }
					/*******************************************************
					 * ==Call GCALWebSerivce method : DeleteEventId
					 * *****************************************************/
					 if(!isLine){ //!= line
						 GCalendarRS resObj = new GCalendarRS();
						 GCalendarRQ req = new GCalendarRQ();
						 req.setCompanyId(comId);
						 req.setProjectId(projectId);
						 req.setDocumentId(eserDocId); 
						 req.setReferenceId(refId);
						 req.setAppName("EVC");
							
						 req.setFromDate(iDate);//From Date  
						 req.setFromTime(iTime);//From Time  		 
						 
						 //delete calendar
						 resObj = (GCalendarRS)WebService.dropCalendar(req);
						 if(resObj.isError()){//case Error
							//System.out.println(resObj.getErrMsg());	
							msgTxt = resObj.getErrMsg();
							response.sendRedirect(ERROR_PAGE+msgTxt);
							return;
						 }
					 }
			 }//#End if else
			/********************************************************************/
			sql.delete(0,sql.length());
			sql.append(" UPDATE lan:eser_dochd SET  f_status='CAN',d_post=TODAY ,i_service_post = ? ,i_calendar_id = null")
				.append(" Where  i_eser_docno = ? ");
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, user.getEmpId());//user Login
			pstmt.setString(2, eserDocId);//i_eser_dochd
			//System.out.println("-->SQL#update after call service:"+sql.toString());
			int xUp = pstmt.executeUpdate();
			//System.out.println("-->update successfully. :"+xUp);
			
			if(isLine){
		        /********** Connection Mysql DB *************/
				myConn = GetConnMysqlJDBC();
				myConn.setAutoCommit(false);
			    /********** Connection Mysql DB *************/
				boolean isUpdateLSerDateMySQL = false;
				String myDocNo = "";
				String myTimeApp = "";
				sql.delete(0,sql.length());
	       	 	sql.append(" SELECT f_status,i_docno FROM lser_dochd WHERE 1=1 ")
	       	 	   .append(" and i_line_docno = '"+eserDocId+"' ")
	       	 	   .append(" and f_status = 'TFR' ");
	       	    
	       	 	 //System.out.println("--> mysql is SQL :"+sql.toString());
	       	     myPstmt = myConn.prepareStatement(sql.toString()); 
	       	     myRs = myPstmt.executeQuery();
	 			 if(myRs.next()){
	 				doString.checkString(myRs.getString("f_status"),"");
	 				myDocNo = doString.checkString(myRs.getString("i_docno"),"");
	 				//myDateApp = doString.checkString(myRs.getString("d_appoint"),"");
	 				//myTimeApp = doString.checkString(myRs.getString("time_appoint"),"");
	 				isUpdateLSerDateMySQL = true;
	 			 }
	 			 myRs.close();
	 			 //System.out.println("--> isUpdateLSerDateMySQL :"+isUpdateLSerDateMySQL);

				if(isAppointFlag){//true old appoint
					 sql.delete(0,sql.length());
			       	 sql.append(" UPDATE lser_dochd SET  f_status = 'CAN',d_post = CURRENT_TIMESTAMP  ")
			       	    .append("  WHERE 1=1 and i_line_docno = '"+eserDocId+"' ")
			       	 	.append(" and f_status = 'TFR' ");
			       	 //System.out.println("--> mysql Update SQL :"+sql.toString());
			       	 myPstmt = myConn.prepareStatement(sql.toString()); 
			       	 //myPstmt.setString(i++, eserDocId);
					 int updMy1 = myPstmt.executeUpdate();						
		   		     //System.out.println("-->Update SQL(1)  :"+updMy1);
			       	 	
					//UPDATE `testlan`.`lser_date` SET `i_docno`='555555' WHERE  `i_company`='LH' AND `i_project`='011' AND `i_date`='2019-09-24' AND `i_time`='10:00:00';
					sql.delete(0,sql.length());
				    sql.append(" UPDATE "+MYSQL_LSER_DATE+" SET  i_docno = ''   ")
				       	 	.append(" WHERE  i_company = '"+comId+"'  and i_project = '"+projectId+"' and i_date = '"+appointDate+"' and i_time = '"+timeLine+":00' ");			       	    
				       	 //System.out.println("--> mysql Update SQL :"+sql.toString());
				       	 myPstmt = myConn.prepareStatement(sql.toString()); 
				       	 //myPstmt.setString(i++, eserDocId);
						 int updMy = myPstmt.executeUpdate();						
			   		     //System.out.println("---LSER_DATE MY_SQL  :"+updMy);			   		     
				}else{//New appiont
					//remark by pradoem2022.04.25
					sql.delete(0,sql.length());
				    sql.append(" UPDATE "+MYSQL_LSER_DATE+" SET  i_docno = ''   ")
				       .append(" WHERE  i_company = '"+comId+"'  and i_project = '"+projectId+"' and i_docno = '"+eserDocId+"'  ");			       	    
				        //.append(" WHERE  i_company = '"+comId+"'  and i_project = '"+projectId+"' and i_date = '"+appointDate+"' and i_time = '"+timeLine+":00' ");			       	    
				    	//System.out.println("--> mysql Update "+TBL_DATE+" SQL :"+sql.toString());
				       	 myPstmt = myConn.prepareStatement(sql.toString()); 
				       	 //myPstmt.setString(i++, eserDocId);
						 int updMy = myPstmt.executeUpdate();						
			   		     //System.out.println("---LSER_DATE MY_SQL  :"+updMy);			   		     
					
					 
					 sql.delete(0,sql.length());
			       	 sql.append(" UPDATE lser_dochd SET  f_status = 'CAN' ,d_post = CURRENT_TIMESTAMP  ")	       	 
			       	    .append("  WHERE 1=1 and i_line_docno = '"+eserDocId+"' ")
			       	 	.append(" and f_status = 'TFR' ");	
			       	 	//System.out.println("--> mysql Update SQL :"+sql.toString());
			       	 	myPstmt = myConn.prepareStatement(sql.toString()); 
			       	 	//myPstmt.setString(i++, eserDocId);
			       	 	int updMy1 = myPstmt.executeUpdate();						
			       	 	//System.out.println("-->Update SQL(2)  :"+updMy1);			       	 	
				}
				//remark by pradoem2022.04.25
				sql.delete(0,sql.length());
				sql.append(" UPDATE lan:"+MYSQL_LSER_DATE+" SET  i_eser_docno=null ")
					.append(" Where  i_eser_docno = ? ");
				pstmt = conn.prepareStatement(sql.toString()); 
				pstmt.setString(1, eserDocId);//user Login
				//System.out.println("-->SQL#update after call service:"+sql.toString());
				int xUp2 = pstmt.executeUpdate();
				//System.out.println("-->update  :"+sql.toString());
				//System.out.println("-->update xUp2. :"+xUp2);
				
				//Update lser_date : mysql 
		  		myConn.commit();		  		
				myConn.close();
				myConn = null;
				System.out.println(" == Step CANCEL Complete Mysql (close MyConn) ==");
			}
			
			conn.commit();
			System.out.println("-->Commit transection.");
		   	//*********Dispatcher		  	
		   	String tarGetUrl ="/save_ok.jsp?error=0&redirect_url=ESERV_OpenJob_List.jsp";
		   	RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			dispatcher.forward(request,response);	

		}catch(Exception e){
			System.out.println("!!! doCancel, " +sysName+":"+ cName + " : " + e.getMessage());
			System.out.println("!!! SQL Exception: "+sql.toString());	
			try{
				conn.rollback();
			}catch(Exception ex){}
			msgTxt = "!!!doCancel, " +sysName+":"+ cName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
			return;
		}
		finally{			
			//clean up.
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
				if(conn!=null){conn.close();}
				
				if(myRs!=null){
					myRs.close();
				}
				if(myPstmt!=null){
					myPstmt.close();
				}
				if(myConn!=null){
					myConn.close();
				}
			}catch(Exception e){}
		}
	}

	//doGenOpenJobESV 
	protected void doGenOpenJobESV(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;	
		StringBuffer sql = new StringBuffer();			
		String MYSQL_LSER_DATE = "lser_date";
		String ESER_DATE = "eser_date";

		String eserDocId = doString.checkString(request.getParameter("i_docno"),"");
		String selProj  = doString.checkString(request.getParameter("sel_project"),"").toUpperCase(); 
		String iLock = doString.checkString(request.getParameter("iLock"),"");
		String iHouse = doString.checkString(request.getParameter("iHouse"),"");
		String status = doString.checkString(request.getParameter("status"),"");
		String nCustomer = doString.checkString(request.getParameter("nCustomer"),"");
		String nCustel  = doString.checkString(request.getParameter("nCustel"),"");
		
		String timeLine = doString.checkString(request.getParameter("timeLine"),"");//AppiontTime
		String appointDate  =  doString.checkString(request.getParameter("appointDate"),"");//AppointDate
		
		int cntDesc =  request.getParameter("cntDesc")==null? 0: Integer.parseInt(request.getParameter("cntDesc"));	
		String msg1=doString.checkString(request.getParameter("msg1"),"");
		String msg2 =doString.checkString(request.getParameter("msg2"),"");

		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
		//String SUCCESS_PAGE = request.getContextPath()+"/save_ok.jsp?redirect_url=";
		
		//GetParamRQ(request);
	    ServletContext context = getServletContext();
	    if("".equals(eserDocId)){//Case e_serDocId is null
			//System.out.println("!!! Find not' found reference Id by iDoc = "+iDocno);	
			msgTxt = "!!ระบบไม่สามาถทำรายการได้เนื่องจากไม่มีเลขที่เอกสาร กรุณาติดต่อผู้ดูแลระบบ 'ระหัสโครงการ : "+selProj+"' ";
			response.sendRedirect(ERROR_PAGE+doString.UnicodeToMS874(msgTxt));
			return;
	    }
	    if("".equals(iLock)){//Case I_Lock is null
			msgTxt = "!!ไม่สามารถทำรายได้เนื่องจากไม่มีแปลง กรุณาติดต่อผู้ดูแลระบบ 'เลขที่เอกสาร :"+eserDocId+"' ";
			response.sendRedirect(ERROR_PAGE+doString.UnicodeToMS874(msgTxt));
			return;
	    }
	    
	    //-------------------------------------------------------
	    Connection myConn = null;
	    PreparedStatement myPstmt = null;
	    ResultSet myRs = null;	
	    String SysName = "";
	    boolean isLineSys = false;
		if(eserDocId.indexOf("L-")!= -1){ 
			MYSQL_LSER_DATE = "lser_date";
			SysName = "LSV"; //LINE
			isLineSys = true;
		}else{
			ESER_DATE = "eser_date";
			SysName = "ESV"; //ESERVICE
			isLineSys = false;
		}
		//----------------------------------------------------
	    try{
    	   	//List strList = new ArrayList<String>();
   			String docTemp = "";
   			String descTemp = "";
   			boolean isFlagPostCalendar= true;
    	   //Get parameter
    		if(cntDesc>0){
	    	    for(int c=1;c<=cntDesc;c++){
	    	    	String f_status = doString.checkString(request.getParameter("rbt"+c),"");
	    	    	if(f_status.equals("OPN")){
	    	    		docTemp  += c+"."+ doString.checkString(request.getParameter("jobDesc"+c),"")+"|break|";
	    	    		descTemp += c+"."+ doString.checkString(request.getParameter("jobDesc"+c),"");
	    	    	}
	    	    }
    		}
    	    docTemp += "|break| "+msg1+" "+toDDMMYY_THAI2(appointDate)+" "+msg2+" "+timeLine+" ("+eserDocId+")";
    	    /********************************************
    	     * Last updat : 2014.02.19 (my birthday )
    	     * TODO : Flow logic business 
    	     * 1. UPDATE eser_docdt status repair OPN,CAN
    	     * 2. GET i_cut_type
    	     * 3. INSERT INTO lan:serv_dochd 'OPN'
    	     * 4. Call WebService GCALWebService for Create google calendar
    	     * 5. UPDATE lan:eser_dochd SET  f_status='CLS',i_calendar_id
    	     * ******************************************/

    	   //************Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setAutoCommit(false);
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			
			//2014.06.10 by pradoem
			boolean isDocId = false;
			String iDocNo = "";
			sql.delete(0,sql.length());
			sql.append(" Select i_docno from lan:eser_dochd ")
			   .append(" where i_eser_docno = ?  and i_docno is not null and i_docno <> '' ");			
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, eserDocId);
			//System.out.println("--->validate i_docno :"+sql.toString());
			rs = pstmt.executeQuery();
			if(rs.next()){
				iDocNo = doString.checkString(rs.getString("i_docno"),"");
				isDocId = true;
			}
			//System.out.println("EEEEEEEEEEEEEE");
		    if(isDocId){//Case I_Lock is null
				msgTxt = doString.UnicodeToMS874("!!ไม่สามารถทำรายได้เนื่องจากระบบมีเลขที่ใบแจ้งซ่อมแล้ว กรุณาติดต่อผู้ดูแลระบบ 'เลขที่ใบแจ้งซ่อม:"+iDocNo+"' ");
				response.sendRedirect(ERROR_PAGE+msgTxt);
				return;
		    }
			//---------------------------------------------------------

			/********************************************************************/
			//System.out.println("--->"+cntDesc);
			if(cntDesc>0){
				sql.delete(0,sql.length());
				sql.append(" UPDATE lan:eser_docdt SET  f_status=?  ")
					.append(" Where  i_eser_docno = ?  and i_seq = ?");			
	    	    for(int c=1;c<=cntDesc;c++){
	    	    	String f_status = doString.checkString(request.getParameter("rbt"+c),"");
					pstmt = conn.prepareStatement(sql.toString()); 
					pstmt.setString(1, f_status);//OPN,CAN
				  	pstmt.setString(2, eserDocId);//i_eser_dochd
				  	pstmt.setInt(3, c);//i_seq	
				  	pstmt.executeUpdate();
	    	    }
			}  
			/********************************************************************/
			String delimiter = "\\:";
			String tempId [] = selProj.split(delimiter);
		  	
		  	int i_cut_type = 0;
		  	sql.delete(0,sql.length());
			sql.append("  select d_effective,i_cut_type  from lan:serv_cutlck  ")
				.append(" where i_company = ?  and i_project = ? and i_lock = ?  and d_effective <= TODAY order by d_effective desc ");
				pstmt = conn.prepareStatement(sql.toString()); 
			  	pstmt.setString(1,tempId [0]);//ID
			  	pstmt.setString(2,tempId [1]);//ID
			  	pstmt.setString(3,iLock);//ID
				rs = pstmt.executeQuery();
				//System.out.println("-->SQL#2:"+sql);
				if(rs.next()){
					i_cut_type =rs.getInt("i_cut_type");
				}
				rs.close();
		  	/********************************************************************/
		  	String AUTO_ID = this.GenerateAutoID(conn,tempId [0],tempId [1]);
			/********************************************************************/
		  	String tempDateTimeApp = "";
			if(!"".equals(appointDate) &&!"".equals(timeLine)){
				tempDateTimeApp = appointDate+"|"+timeLine; //2013-10-29 11:30
			}
			sql.delete(0, sql.length());
			sql.append(" INSERT INTO lan:serv_dochd (i_docno      ,")//1
					.append(" i_doc_type        ,")//2
					.append(" i_company         ,")//3
					.append(" i_project        ,")//4
					.append(" i_lock            ,")//5
					.append(" d_keyin           ,")//6
					.append(" n_customer        ,")//7
					.append(" n_cus_tel         ,")//8
					.append(" c_desc            ,")//9
					.append(" d_job             ,")//10
					.append(" f_status          ,")//11
					.append(" d_appoint         ,")//12 
					.append(" d_est_close       ,")//13
					.append(" d_close           ,")//14
					.append(" i_service_employ  ,")//15 
					.append(" i_type_cutlck     ,")//16
					.append(" i_employ_pinform  ,")//17 
					.append(" d_print_job       ,")//18
					.append(" i_employ_pjob     ,")//19
					.append(" f_reject          ,")//20
					.append(" i_employ_reject   ,")//21
					.append(" d_reject          ,")//22
					.append(" c_reject          ,")//23	
					.append(" i_system          ,")//24	
					.append(" d_appoint_cust    )")//25	
					.append("  VALUES (?, 'I', ?, ?,  ?, current, ?, ?, ?, null, 'OPN', null, null, null, ? , ?, null ,null ,null , 'N',  null, null,  null ,? ,?)"); 			
			                         //1   2   3  4   5    6      7  8  9   10    11    12    13     14   15  16  17    18    19     20     21    22    23  24  25
			//System.out.println("AUTO_ID:"+AUTO_ID);
			int i = 1;
			pstmt = conn.prepareStatement(sql.toString()); 
   		  	pstmt.setString(i++, AUTO_ID);//1.DOC_ID
   		  	//2
   		  	pstmt.setString(i++, tempId[0]);//3.i_com
   		  	pstmt.setString(i++, tempId[1]);//4.i_proj  		  	
   		    pstmt.setString(i++, iLock);//5.lock
   		    //6
   		  	pstmt.setString(i++, nCustomer);//7.n_customer
   		  	pstmt.setString(i++, nCustel);//8.n_cus_tel
   		  	pstmt.setString(i++, docTemp);//9.c_desc
   		  	//10,
   		  	//11=OPN
   		  	//,12,
   		  	//13,
   		  	//14,
   		  	pstmt.setString(i++, user.getEmpId());//15.i_service_employ
   		  	pstmt.setInt(i++, i_cut_type);//16.i_type_cutlck
   		  	//17
   		    //18
   		    //19
   		    //20 = 'N'
   		    //21
   		    //22
   		    //23
   		    pstmt.setString(i++,SysName);//"ESV" 24. System   ESV,SVC
   		    if(!"".equals(tempDateTimeApp)){
   		    	pstmt.setTimestamp(i++,GetTimestamp(tempDateTimeApp));//25
   		    }else{
   		    	pstmt.setTimestamp(i++,null);//25
   		    }
   		    //d_appoint_cust
   		  	int genDocHd = pstmt.executeUpdate(); 
   		    System.out.println("-->(doGenOpenJobESV)INSERT INTO lan:serv_dochd :"+genDocHd+": successfully.");
   		  	/********************************************************************/
   		  
   		    //Validate Post google calendar
			sql.delete(0,sql.length());
			sql.append(" Select i_company,i_project,i_date,q_apptime_fr1 From lan:"+ESER_DATE)
			   .append(" where  i_eser_docno = '"+eserDocId+"' ");			
			pstmt = conn.prepareStatement(sql.toString()); 
			//pstmt.setString(1,eserDocId);//doc
			System.out.println("--->(doGenOpenJobESV)Validate SQL :"+sql.toString());
			rs = pstmt.executeQuery();
			if(rs.next()){
				doString.checkString(rs.getString("q_apptime_fr1"),"");
				isFlagPostCalendar = false;
			}			
			
			System.out.println("--->(doGenOpenJobESV)isFlagUp SQL :"+isFlagPostCalendar);
			//case table eser_date(eservice),lser_date(line) is Empty on field i_eser_docno is null
			if(isFlagPostCalendar){ //#Case i_eser_docno is null or not post google calendar
				//System.out.println("---------(doGenOpenJobESV)Call WebService on site google calendar --------");
				GCalendarRS calRS = new GCalendarRS();
				 /***********************************
				  * For  Create Service
				  ***********************************/
				GCalendarRQ req = new GCalendarRQ();
				req.setAppName("EVC"); //Application :EVC				
				req.setCompanyId(tempId [0]);//CompanyID
				req.setProjectId(tempId [1]);//ProjectID
				req.setDocumentId(eserDocId); //DocumentID
				req.setLockNo(iLock);//Lock
				req.setFromDate(appointDate);//From Date
				req.setFromTime(timeLine);//From Time
				req.setToDate(appointDate);//TO Time
				req.setToTime(timeLine);//TO Time
				req.setUserName(user.getUserID());//UserName
				req.setDesc(descTemp); //Description
				req.setReferenceId(AUTO_ID);
				//For Eservice param
				req.setCustomerName(nCustomer);
				req.setHouseNo(iHouse);
				req.setTelNo(nCustel);
				req.setStatus(status);//N,Y
				
				calRS = (GCalendarRS)WebService.createCalendar(req);
				System.out.println("---------Result call web Service--------- :"+calRS.isError());
				if(calRS.isError()){//case Error
					try{
						conn.rollback();
						conn.setAutoCommit(true);
					}catch(Exception ex){}
					//System.out.println("Errors msg:"+calRS.getErrMsg());
					msgTxt = calRS.getErrMsg();
					response.sendRedirect(ERROR_PAGE+msgTxt);
					return;
				}else{
					//#case success call WebService From Call Post google calendar
					//Case Line Service && EService select Dropdown List 
					String dateTimeApp = appointDate+" "+timeLine;
		   		  	System.out.println("dateTime App :"+dateTimeApp);
					sql.delete(0,sql.length());
					sql.append(" UPDATE lan:eser_dochd SET  f_status='CLS' ,d_appoint ='"+dateTimeApp+"',d_post= current,i_service_post = ? ,i_docno = ? ")
						.append(",i_calendar_id = ?  Where  i_eser_docno = ?  ");
					System.out.println("-->>SQL :"+sql.toString());
					pstmt = conn.prepareStatement(sql.toString()); 
					//pstmt.setString(1, appointDate+" "+timeLine);//date+time appointDate+" "+timeLine   dateTime
				  	pstmt.setString(1, user.getEmpId());//empId
				  	pstmt.setString(2, AUTO_ID);//documentId
				  	pstmt.setString(3, calRS.getReferenceId());//ReferenceId
					pstmt.setString(4, eserDocId);//i_eser_dochd
				  	int xUpd = pstmt.executeUpdate();
				  	System.out.println("-->xUpd:"+xUpd);
				}				
			}else{//#case is i_eser_docno or calse post google calendar
				sql.delete(0,sql.length());
				sql.append(" UPDATE lan:eser_dochd SET  f_status='CLS' ,d_post= current,i_service_post = ? ,i_docno = ? ")
				   .append(" Where  i_eser_docno = ?  ");
				pstmt = conn.prepareStatement(sql.toString()); 
			  	pstmt.setString(1, user.getEmpId());//empId
			  	pstmt.setString(2, AUTO_ID);//documentId
				pstmt.setString(3, eserDocId);//i_eser_dochd
			  	pstmt.executeUpdate();
			}
   		  	conn.commit();
   		    conn.setAutoCommit(true);
   		    
   		    System.out.println("====Commit (doGenOpenJobESV)transection=====");
	   		//*********Dispatcher 
		  	//String ERROR_PAGE = "/MsgSuccessPage.jsp?msg="+e.getMessage()+"&error=1&url=/SALE_ContractFur.jsp";		  	
	   		String tarGetUrl ="/save_ok.jsp?docNo="+AUTO_ID+"&error=0&redirect_url=ESERV_OpenJob_List.jsp";
	   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			dispatcher.forward(request,response);			

	    }catch(Exception e){
			System.out.println(" doGenOpenJobESV, " +sysName+":"+ cName + " : " + e.getMessage());
			System.out.println("!!! doGenOpenJobESV, SQL Exception: "+sql.toString());	
			try{
				conn.rollback();
				conn.setAutoCommit(true);
			}catch(Exception ex){}
			msgTxt = "!!! doGenOpenJobESV, " +sysName+":"+ cName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
		}
		finally{			
			//clean up.
			//System.out.println("----->Finally DDDDDDDDDDDDDDDDDDDDD..");
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
				if(conn!=null){conn.close();}
				
				if(myRs!=null){
					myRs.close();
				}
				if(myPstmt!=null){
					myPstmt.close();
				}
				if(myConn!=null){
					myConn.close();
				}
			}catch(Exception e){}
		}
	}
	
	//doGenOpenJobLSV 
	protected void doGenOpenJobLSV(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;	
		StringBuffer sql = new StringBuffer();			
		//String TBL_DATE = "eser_date";
		
		String MYSQL_LSER_DATE = "lser_date";
		String ESER_DATE = "eser_date";

		String eserDocId = doString.checkString(request.getParameter("i_docno"),"");
		String selProj  = doString.checkString(request.getParameter("sel_project"),"").toUpperCase(); 
		String iLock = doString.checkString(request.getParameter("iLock"),"");
		String iHouse = doString.checkString(request.getParameter("iHouse"),"");
		String status = doString.checkString(request.getParameter("status"),"");
		String nCustomer = doString.checkString(request.getParameter("nCustomer"),"");
		String nCustel  = doString.checkString(request.getParameter("nCustel"),"");
		
		String timeLine = doString.checkString(request.getParameter("timeLine"),"");//AppiontTime
		String appointDate  =  doString.checkString(request.getParameter("appointDate"),"");//AppointDate
		
		int cntDesc =  request.getParameter("cntDesc")==null? 0: Integer.parseInt(request.getParameter("cntDesc"));	
		String msg1=doString.checkString(request.getParameter("msg1"),"");
		String msg2 =doString.checkString(request.getParameter("msg2"),"");

		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
		//String SUCCESS_PAGE = request.getContextPath()+"/save_ok.jsp?redirect_url=";
		
		//GetParamRQ(request);
	    ServletContext context = getServletContext();
	    if("".equals(eserDocId)){//Case e_serDocId is null
			//System.out.println("!!! Find not' found reference Id by iDoc = "+iDocno);	
			msgTxt = "!!ระบบไม่สามาถทำรายการได้เนื่องจากไม่มีเลขที่เอกสาร กรุณาติดต่อผู้ดูแลระบบ 'ระหัสโครงการ : "+selProj+"' ";
			response.sendRedirect(ERROR_PAGE+doString.UnicodeToMS874(msgTxt));
			return;
	    }
	    if("".equals(iLock)){//Case I_Lock is null
			msgTxt = "!!ไม่สามารถทำรายได้เนื่องจากไม่มีแปลง กรุณาติดต่อผู้ดูแลระบบ 'เลขที่เอกสาร :"+eserDocId+"' ";
			response.sendRedirect(ERROR_PAGE+doString.UnicodeToMS874(msgTxt));
			return;
	    }
	    
	    //-------------------------------------------------------
	    // lser_date ,i_system
	    //L1 = นัดหมายจาก Line App (ลูกบ้านนัดหมายเอง)
	    //L2 = นัดหมายโดนเจ้าหน้าที่ 
	    Connection myConn = null;
	    PreparedStatement myPstmt = null;
	    ResultSet myRs = null;	
	    String SysName = "";

		if(eserDocId.indexOf("L-")!= -1){ 
			MYSQL_LSER_DATE = "lser_date";
			SysName = "LSV"; //LINE
		}else{
			ESER_DATE = "eser_date";
			SysName = "ESV"; //ESERVICE
		}
		//----------------------------------------------------
	    try{
    	   	//List strList = new ArrayList<String>();
   			String docTemp = "";
   			String descTemp = "";
   			boolean isAppointFlag = true;
    	   //Get parameter
    		if(cntDesc>0){
	    	    for(int c=1;c<=cntDesc;c++){
	    	    	String f_status = doString.checkString(request.getParameter("rbt"+c),"");
	    	    	if(f_status.equals("OPN")){
	    	    		docTemp  += c+"."+ doString.checkString(request.getParameter("jobDesc"+c),"")+"|break|";
	    	    		descTemp += c+"."+ doString.checkString(request.getParameter("jobDesc"+c),"");
	    	    	}
	    	    }
    		}
    	    docTemp += "|break| "+msg1+" "+toDDMMYY_THAI2(appointDate)+" "+msg2+" "+timeLine+" ("+eserDocId+")";
    	    /********************************************
    	     * Last updat : 2014.02.19 (my birthday )
    	     * TODO : Flow logic business 
    	     * 1. UPDATE eser_docdt status repair OPN,CAN
    	     * 2. GET i_cut_type
    	     * 3. INSERT INTO lan:serv_dochd 'OPN'
    	     * 4. Call WebService GCALWebService for Create google calendar
    	     * 5. UPDATE lan:eser_dochd SET  f_status='CLS',i_calendar_id
    	     * ******************************************/

    	   //************Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setAutoCommit(false);
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			
			//2014.06.10 by pradoem
			boolean isDocId = false;
			String iDocNo = "";
			sql.delete(0,sql.length());
			sql.append(" Select i_docno from lan:eser_dochd ")
			   .append(" where i_eser_docno = ?  and i_docno is not null and i_docno <> '' ");			
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, eserDocId);
			//System.out.println("--->validate i_docno :"+sql.toString());
			rs = pstmt.executeQuery();
			if(rs.next()){
				iDocNo = doString.checkString(rs.getString("i_docno"),"");
				isDocId = true;
			}
			//System.out.println("EEEEEEEEEEEEEE");
		    if(isDocId){//Case I_Lock is null
				msgTxt = doString.UnicodeToMS874("!!ไม่สามารถทำรายได้เนื่องจากระบบมีเลขที่ใบแจ้งซ่อมแล้ว กรุณาติดต่อผู้ดูแลระบบ 'เลขที่ใบแจ้งซ่อม:"+iDocNo+"' ");
				response.sendRedirect(ERROR_PAGE+msgTxt);
				return;
		    }
			//---------------------------------------------------------

			/********************************************************************/
			//System.out.println("--->"+cntDesc);
			if(cntDesc>0){
				sql.delete(0,sql.length());
				sql.append(" UPDATE lan:eser_docdt SET  f_status=?  ")
					.append(" Where  i_eser_docno = ?  and i_seq = ?");			
	    	    for(int c=1;c<=cntDesc;c++){
	    	    	String f_status = doString.checkString(request.getParameter("rbt"+c),"");
					pstmt = conn.prepareStatement(sql.toString()); 
					pstmt.setString(1, f_status);//OPN,CAN
				  	pstmt.setString(2, eserDocId);//i_eser_dochd
				  	pstmt.setInt(3, c);//i_seq	
				  	pstmt.executeUpdate();
	    	    }
			}  
			/********************************************************************/
			String delimiter = "\\:";
			String tempId [] = selProj.split(delimiter);
		  	
		  	int i_cut_type = 0;
		  	sql.delete(0,sql.length());
			sql.append("  select d_effective,i_cut_type  from lan:serv_cutlck  ")
				.append(" where i_company = ?  and i_project = ? and i_lock = ?  and d_effective <= TODAY order by d_effective desc ");
				pstmt = conn.prepareStatement(sql.toString()); 
			  	pstmt.setString(1,tempId [0]);//ID
			  	pstmt.setString(2,tempId [1]);//ID
			  	pstmt.setString(3,iLock);//ID
				rs = pstmt.executeQuery();
				//System.out.println("-->SQL#2:"+sql);
				if(rs.next()){
					i_cut_type =rs.getInt("i_cut_type");
				}
				rs.close();
		  	/********************************************************************/
		  	String AUTO_ID = this.GenerateAutoID(conn,tempId [0],tempId [1]);
			/********************************************************************/
		  	String tempDateTimeApp = "";
			if(!"".equals(appointDate) &&!"".equals(timeLine)){
				tempDateTimeApp = appointDate+"|"+timeLine; //2013-10-29 11:30
			}
			sql.delete(0, sql.length());
			sql.append(" INSERT INTO lan:serv_dochd (i_docno      ,")//1
					.append(" i_doc_type        ,")//2
					.append(" i_company         ,")//3
					.append(" i_project        ,")//4
					.append(" i_lock            ,")//5
					.append(" d_keyin           ,")//6
					.append(" n_customer        ,")//7
					.append(" n_cus_tel         ,")//8
					.append(" c_desc            ,")//9
					.append(" d_job             ,")//10
					.append(" f_status          ,")//11
					.append(" d_appoint         ,")//12 
					.append(" d_est_close       ,")//13
					.append(" d_close           ,")//14
					.append(" i_service_employ  ,")//15 
					.append(" i_type_cutlck     ,")//16
					.append(" i_employ_pinform  ,")//17 
					.append(" d_print_job       ,")//18
					.append(" i_employ_pjob     ,")//19
					.append(" f_reject          ,")//20
					.append(" i_employ_reject   ,")//21
					.append(" d_reject          ,")//22
					.append(" c_reject          ,")//23	
					.append(" i_system          ,")//24	
					.append(" d_appoint_cust    )")//25	
					.append("  VALUES (?, 'I', ?, ?,  ?, current, ?, ?, ?, null, 'OPN', null, null, null, ? , ?, null ,null ,null , 'N',  null, null,  null ,? ,?)"); 			
			                         //1   2   3  4   5    6      7  8  9   10    11    12    13     14   15  16  17    18    19     20     21    22    23  24  25
			//System.out.println("AUTO_ID:"+AUTO_ID);
			int i = 1;
			pstmt = conn.prepareStatement(sql.toString()); 
   		  	pstmt.setString(i++, AUTO_ID);//1.DOC_ID
   		  	//2
   		  	pstmt.setString(i++, tempId[0]);//3.i_com
   		  	pstmt.setString(i++, tempId[1]);//4.i_proj  		  	
   		    pstmt.setString(i++, iLock);//5.lock
   		    //6
   		  	pstmt.setString(i++, nCustomer);//7.n_customer
   		  	pstmt.setString(i++, nCustel);//8.n_cus_tel
   		  	pstmt.setString(i++, docTemp);//9.c_desc
   		  	//10,
   		  	//11=OPN
   		  	//,12,
   		  	//13,
   		  	//14,
   		  	pstmt.setString(i++, user.getEmpId());//15.i_service_employ
   		  	pstmt.setInt(i++, i_cut_type);//16.i_type_cutlck
   		  	//17
   		    //18
   		    //19
   		    //20 = 'N'
   		    //21
   		    //22
   		    //23
   		    pstmt.setString(i++,SysName);//"ESV" 24. System   ESV,SVC
   		    if(!"".equals(tempDateTimeApp)){
   		    	pstmt.setTimestamp(i++,GetTimestamp(tempDateTimeApp));//25
   		    }else{
   		    	pstmt.setTimestamp(i++,null);//25
   		    }
   		    //d_appoint_cust
   		  	int genDocHd = pstmt.executeUpdate(); 
   		    System.out.println("-->(doGenOpenJobLSV)INSERT INTO lan:serv_dochd :"+genDocHd+": successfully.");
   		  	/********************************************************************/
   		  
   		    //Validate appion flag
   		    String tempDoc = "";
			sql.delete(0,sql.length());
			sql.append(" Select i_company,i_project,i_date,q_apptime_fr1,i_eser_docno From lan:"+ESER_DATE)
			   .append(" Where  i_company = '"+tempId[0]+"'  and i_project = '"+tempId [1]+"' and i_date = '"+appointDate+"' and q_apptime_fr1 = '"+timeLine+"'  and i_date_type = '02' ");			
			pstmt = conn.prepareStatement(sql.toString()); 
			//pstmt.setString(1,eserDocId);//doc
			System.out.println("--->(doGenOpenJobLSV)Validate SQL :"+sql.toString());
			rs = pstmt.executeQuery();
			if(rs.next()){
				tempDoc = doString.checkString(rs.getString("i_eser_docno"),"");
			}
			 if((tempDoc == null) || tempDoc.equals("")) {
				 isAppointFlag = false; //Not Appointment 
			 }else{
			    isAppointFlag = true; //Appointmented
			 }
			//------------------------------
				
		        /********** Connection Mysql DB *************/
				myConn = GetConnMysqlJDBC();
				myConn.setAutoCommit(false);
			    /********** Connection Mysql DB *************/
				boolean isUpdateLSerDateMySQL = false;
				String myDocNo = "";
				String myTimeApp = "";
				sql.delete(0,sql.length());
	       	 	sql.append(" SELECT f_status,i_docno FROM lser_dochd WHERE 1=1 ")
	       	 	   .append(" and i_line_docno = '"+eserDocId+"' ")
	       	 	   .append(" and f_status = 'TFR' ");
	       	    
	       	 	 //System.out.println("--> mysql is SQL :"+sql.toString());
	       	     myPstmt = myConn.prepareStatement(sql.toString()); 
	       	     myRs = myPstmt.executeQuery();
	 			 if(myRs.next()){
	 				doString.checkString(myRs.getString("f_status"),"");
	 				myDocNo = doString.checkString(myRs.getString("i_docno"),"");
	 				//myDateApp = doString.checkString(myRs.getString("d_appoint"),"");
	 				//myTimeApp = doString.checkString(myRs.getString("time_appoint"),"");
	 				isUpdateLSerDateMySQL = true;
	 			 }
	 			 myRs.close();
	 			 System.out.println("--> isUpdateLSerDateMySQL :"+isUpdateLSerDateMySQL);

				if(isAppointFlag){//true old appoint
					 sql.delete(0,sql.length());
			       	 sql.append(" UPDATE lser_dochd SET  f_status = 'TFR',d_post = CURRENT_TIMESTAMP  ");
			       	 if(myDocNo==null || myDocNo.equals("")){
			       		 sql.append(", i_docno = '"+AUTO_ID+"' ");
			       	 }
			       	sql.append("  WHERE 1=1 and i_line_docno = '"+eserDocId+"' ")
			       	 	.append(" and f_status = 'TFR' ");
			       	 //System.out.println("--> mysql Update SQL :"+sql.toString());
			       	 myPstmt = myConn.prepareStatement(sql.toString()); 
			       	 //myPstmt.setString(i++, eserDocId);
					 int updMy1 = myPstmt.executeUpdate();						
		   		     //System.out.println("-->Update SQL(1)  :"+updMy1);
				}else{//New appiont
					 sql.delete(0,sql.length());
			       	 sql.append(" UPDATE lser_dochd SET  f_status = 'TFR' ,d_post = CURRENT_TIMESTAMP  ");
			       	 if(myDocNo==null || myDocNo.equals("")){
			       		 sql.append(", i_docno = '"+AUTO_ID+"' ");
			       	 }			       	 
			       	sql.append(", d_appoint = '"+appointDate+"', time_appoint = '"+timeLine+":00'  ");			       	 
			       	sql.append("  WHERE 1=1 and i_line_docno = '"+eserDocId+"' ")
			       	 	.append(" and f_status = 'TFR' ");	
			       	 	System.out.println("--> mysql Update SQL :"+sql.toString());
			       	 	myPstmt = myConn.prepareStatement(sql.toString()); 
			       	 	//myPstmt.setString(i++, eserDocId);
			       	 	int updMy1 = myPstmt.executeUpdate();						
			       	 	//System.out.println("-->Update SQL(2)  :"+updMy1);
			       	 	
						//UPDATE `testlan`.`lser_date` SET `i_docno`='555555' WHERE  `i_company`='LH' AND `i_project`='011' AND `i_date`='2019-09-24' AND `i_time`='10:00:00';
						sql.delete(0,sql.length());
				       	sql.append(" UPDATE "+MYSQL_LSER_DATE+" SET  i_docno = '"+eserDocId+"'   ")
				       	 	.append(" WHERE  i_company = '"+tempId[0]+"'  and i_project = '"+tempId[1]+"' and i_date = '"+appointDate+"' and i_time = '"+timeLine+":00' ");			       	    
				       	 System.out.println("--> mysql Update SQL :"+sql.toString());
				       	 myPstmt = myConn.prepareStatement(sql.toString()); 
				       	 //myPstmt.setString(i++, eserDocId);
						 int updMy = myPstmt.executeUpdate();						
			   		     //System.out.println("---LSER_DATE MY_SQL  :"+updMy);				       	 	
				}
				//Update lser_date : mysql 
		  		myConn.commit();		  		
				myConn.close();
				myConn = null;
				System.out.println(" == Step Complete Mysql (close MyConn) ==");
		 
				
		     boolean isG0512 = IsProjInG5andG12(conn, tempId [0], tempId [1]);
		     GCalendarRS calRS = new GCalendarRS();
		     
		     System.out.println(" isG0512 :"+isG0512);
		     if(isG0512){
		    	 calRS.setError(false);
		    	 calRS.setErrMsg("---Skip G05&G12 not post into google calendar ---");
		    	// calRS.isError(
		     }else{
				 //-----------------------------
				//กรณีที่มีการนัดหมายไปแล้ว post ขึ้น calendar อย่างเดียว
				//กรณีที่ยังไม่นัดหมายให้เลือกวันที่นัดหมายแล้ว post จากนั้น update lser_date
				System.out.println("---------(doGenOpenJobLSV)Call WebService on site google calendar --------");
				
				 /***********************************
				  * For  Create Service
				  ***********************************/
				GCalendarRQ req = new GCalendarRQ();
				req.setAppName("LINE"); //Application :LINE	
				req.setCompanyId(tempId [0]);//CompanyID
				req.setProjectId(tempId [1]);//ProjectID
				req.setDocumentId(eserDocId); //DocumentID
				req.setLockNo(iLock);//Lock
				req.setFromDate(appointDate);//From Date
				req.setFromTime(timeLine);//From Time
				req.setToDate(appointDate);//TO Time
				req.setToTime(timeLine);//TO Time
				req.setUserName(user.getUserID());//UserName
				req.setDesc(descTemp); //Description
				req.setReferenceId(AUTO_ID);
				//For Eservice param
				req.setCustomerName(nCustomer);
				req.setHouseNo(iHouse);
				req.setTelNo(nCustel);
				req.setStatus(status);//N,Y
				
				calRS = (GCalendarRS)WebService.createCalendar(req);
		     }

			System.out.println("---------Result call web Service---------");
			System.out.println("---->>> :"+calRS.isError());
			if(calRS.isError()){//case Error false
				try{
					conn.rollback();
					conn.setAutoCommit(true);
				}catch(Exception ex){}
				System.out.println("!!Errors msg(doGenOpenJobLSV):"+calRS.getErrMsg());
				msgTxt = calRS.getErrMsg();
				response.sendRedirect(ERROR_PAGE+msgTxt);
				return;
			}else{
				//#case success call WebService From Call Post google calendar
				//Case Line Service && EService select Dropdown List 
				System.out.println("--->(doGenOpenJobLSV) status :"+isAppointFlag);
				if(isAppointFlag){//true old appoint		
					//System.out.println("--->(doGenOpenJobLSV) Case Old Appoint.");
					sql.delete(0,sql.length());
					sql.append(" UPDATE lan:eser_dochd SET  f_status='CLS' ,d_post= current,i_service_post = ? ,i_docno = ? ")
					   .append(" Where  i_eser_docno = ?  ");
					pstmt = conn.prepareStatement(sql.toString()); 
				  	pstmt.setString(1, user.getEmpId());//empId
				  	pstmt.setString(2, AUTO_ID);//documentId
					pstmt.setString(3, eserDocId);//i_eser_dochd
				  	int intUp = pstmt.executeUpdate();
				  	//System.out.println("--->(doGenOpenJobLSV) intUp :"+intUp);
				}else{//false
					//System.out.println("--->(doGenOpenJobLSV) Case New Appoint .");
					String dateTimeApp = appointDate+" "+timeLine;
		   		  	System.out.println("(doGenOpenJobLSV)dateTime App :"+dateTimeApp);
					sql.delete(0,sql.length());
					sql.append(" UPDATE lan:eser_dochd SET  f_status='CLS' ,d_appoint ='"+dateTimeApp+"',d_post= current,i_service_post = ? ,i_docno = ? ")
						.append(",i_calendar_id = ?  Where  i_eser_docno = ?  ");
					//System.out.println("-->>(doGenOpenJobLSV)SQL :"+sql.toString());
					pstmt = conn.prepareStatement(sql.toString()); 
					//pstmt.setString(1, appointDate+" "+timeLine);//date+time appointDate+" "+timeLine   dateTime
				  	pstmt.setString(1, user.getEmpId());//empId
				  	pstmt.setString(2, AUTO_ID);//documentId
				  	pstmt.setString(3, calRS.getReferenceId());//ReferenceId
					pstmt.setString(4, eserDocId);//i_eser_dochd
				  	int xUpd = pstmt.executeUpdate();
				  	//System.out.println("-->xUpd:"+xUpd);
				  	
					//********************************************
					//System.out.println("---appointDate :"+appointDate);
					//System.out.println("---timeLine :"+timeLine);
					sql.delete(0,sql.length());
		       	 	sql.append(" UPDATE lan:"+ESER_DATE+" SET  i_eser_docno = ? ,i_system = 'L2'  ")
		       	 	   .append(" Where  i_company = ?  and i_project = ? and i_date = ? and q_apptime_fr1 = ?  and i_date_type = '02' ");
		       	     
		       	 	i = 1;
		       	 	System.out.println("Update SQL :"+sql.toString());
				    pstmt = conn.prepareStatement(sql.toString()); 
				    pstmt.setString(i++, eserDocId);
					//pstmt.setString(i++, SysName);    
				    pstmt.setString(i++, tempId[0]);
				    pstmt.setString(i++, tempId[1]);
				    pstmt.setString(i++, appointDate);
				    pstmt.setString(i++, timeLine);
				   //pstmt.setString(i++, obj.getI_date_type());				    
				    //System.out.println("---Update SQL :"+sql.toString());
				    int intUpd = pstmt.executeUpdate();						
	   		        System.out.println("---Update SQL :"+intUpd);
				}

	   		  	conn.commit();
	   		  	System.out.println("====Commit  (doGenOpenJobLSV )transection=====");
			}//#Else succes from webService				
			System.out.println(" == Step Complete mission ==");
   		    conn.setAutoCommit(true);

	   		//*********Dispatcher 
		  	//String ERROR_PAGE = "/MsgSuccessPage.jsp?msg="+e.getMessage()+"&error=1&url=/SALE_ContractFur.jsp";		  	
	   		String tarGetUrl ="/save_ok.jsp?docNo="+AUTO_ID+"&error=0&redirect_url=ESERV_OpenJob_List.jsp";
	   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			dispatcher.forward(request,response);			

	    }catch(Exception e){
			System.out.println("!!! doGenOpenJobLSV, " +sysName+":"+ cName + " : " + e.getMessage());
			System.out.println("!!! doGenOpenJobLSV, SQL Exception: "+sql.toString());	
			try{
				conn.rollback();
				myConn.rollback();
				conn.setAutoCommit(true);
			}catch(Exception ex){}
			msgTxt = "!!! doGenOpenJobLSV, " +sysName+":"+ cName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
		}
		finally{			
			//clean up.
			//System.out.println("----->Finally DDDDDDDDDDDDDDDDDDDDD..");
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
				if(conn!=null){conn.close();}
				
				if(myRs!=null){
					myRs.close();
				}
				if(myPstmt!=null){
					myPstmt.close();
				}
				if(myConn!=null){
					myConn.close();
				}
			}catch(Exception e){}
		}
	}
	
	public boolean IsProjInG5andG12(Connection conn,String comId,String projId){
        StringBuffer sql = new StringBuffer();
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String allProject = "";
        boolean isRecord = false;
        try {
  			sql.delete(0, sql.length());
			sql.append("  select distinct i_company, i_project  ")
				.append(" from lan:acsbudgh ")
				.append(" where i_group in ('05','12') ")
				.append(" and i_company = '"+comId+"' ")
				.append(" and i_project = '"+projId+"' ");
				System.out.println("SQL  :"+sql.toString());
			    pstmt = conn.prepareStatement(sql.toString()); 
			    rs = pstmt.executeQuery();   				   
			    if(rs.next()){
			       allProject  = doString.checkString(rs.getString("i_project"),"");
			       isRecord = true;
			    } 		
                rs.close();
             return isRecord;
        }catch(Exception e) {
            System.out.println("!! IsLHALL Error : " + e.getMessage());
            return false;
        } finally{
            try  {
                if(rs != null) {
                    rs.close();
                }
                if(pstmt != null){
                	pstmt.close();
                }
            }
            catch(Exception ex) { }
        }
    }
	
	
   //GEN Auto ID By year,by project
	private   String GenerateAutoID(Connection conn,String iCompany,String iProject) {
		// TODO Auto-generated method stub
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		int id = 0;
		String tempId = "";
		try{
				sql.delete(0, sql.length());
				sql.append("  select max(i_docno[10,14]) as maxid from lan:serv_dochd where i_company = ? and i_project = ?  and  i_docno[8,9] = ? ");
				pstmt = conn.prepareStatement(sql.toString()); 
				pstmt.setString(1,iCompany);
				pstmt.setString(2,iProject);
				pstmt.setString(3, getThaiCurrentDDMMYYYY().substring(8));			
				rs = pstmt.executeQuery();
				if (rs.next()) {
					//0001
					id = rs.getInt("maxid");
				} // End if rs
				
				if(id>0){
					id++;
					tempId = iCompany+"-"+iProject+"-"+getThaiCurrentDDMMYYYY().substring(8)+GenNextId(id);
				}else{
					tempId = iCompany+"-"+iProject+"-"+getThaiCurrentDDMMYYYY().substring(8)+"00001";
				}
				return tempId;
		}catch(Exception e){
			e.fillInStackTrace();
			System.out.println(sysName+":"+cName+":GenerateAutoID :"+e.toString());
			return "";
		}
		finally{
			try {
				if(rs!=null)rs.close();
				if(pstmt!=null)pstmt.close();
			}catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
	 
	private static String GenNextId(int b){
	        String temp=""+b;
	        String newSp_id;
	        switch(temp.length()){ 
	          // case 1: newSp_id="00000"+temp; break; // case 2: newSp_id="0000"+temp; break; //case 1: newSp_id="000"+temp; break;
	           case 1: newSp_id="0000"+temp; break;
	           case 2: newSp_id="000"+temp; break;
	           case 3: newSp_id="00"+temp; break;
	           case 4: newSp_id="0"+temp; break;
	           default:newSp_id=temp;
	        }
	        return newSp_id;
	 }
	
	 public static String Now(String dateFormat) {
		    Calendar cal = Calendar.getInstance();
		    SimpleDateFormat sdf = new SimpleDateFormat(dateFormat);
		    return sdf.format(cal.getTime());
	  }
	 
	private static String getThaiCurrentDDMMYYYY(){
			//Date format
		  	Date date = Calendar.getInstance().getTime();
		  	 // Display a date in day, month, year format
		  	DateFormat formatter = new SimpleDateFormat("dd/MM/yyyy");
		  	String today = formatter.format(date);
		  	String [] tempDate ;
		  	tempDate = today.split("/");
		  	int yyy = Integer.parseInt(tempDate[2])+543;
	  	return	tempDate[0]+"/"+tempDate[1]+"/"+yyy;
	}
	
	private static  String toDDMMYY_THAI2(String str){
		 if ((str == null) || str.equals("")) {
			 return  str;
		 }else{
			 String d2[] = str.split("\\-"); //2013-03-29
			 return d2[2]+"/"+d2[1]+"/"+(Integer.parseInt(d2[0])+543);
		 }
	}
	
    public static Timestamp GetTimestamp(String param){
    	Calendar cal = Calendar.getInstance(Locale.ENGLISH);
    	 if("".equals(param)||null==param){
    		 return new Timestamp(cal.getTimeInMillis());
    	 }
    	 //Calendar cal = Calendar.getInstance(Locale.ENGLISH);
    	 System.out.println(param);
    	 String temp[] = param.split("\\|");
    	 String dTemp[] = temp[0].split("\\-");
    	 String tTemp[] = temp[1].split("\\:");
    	 cal.set(Integer.parseInt(dTemp[0]),Integer.parseInt(dTemp[1])-1,Integer.parseInt(dTemp[2]),Integer.parseInt(tTemp[0]),Integer.parseInt(tTemp[1]));

    	 return new Timestamp(cal.getTimeInMillis());
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
	 private void GetParamRQ(HttpServletRequest request){
			Enumeration <String> paramName = (Enumeration<String>) request.getParameterNames();
			 while (paramName.hasMoreElements()) {
			            String element = (String) paramName.nextElement();
			            System.out.println(element + " = " + request.getParameter(element));
			 }
	  }
}