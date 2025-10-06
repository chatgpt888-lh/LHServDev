package serv.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
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
import com.lh.string.doString;
import java.util.*;

/**
* Servlet implementation class for Servlet: SERV_SettingSendMailServlet
* create by : pradoem wonkraso
* date time: 2016.08.04
* comment:
*/
 public class SERV_SettingSendMailServlet extends  DBServlet{
	/* (non-Java-doc)
	* @see javax.servlet.http.HttpServlet#HttpServlet()
	 */
	String sysName = "LHServ";
	String clazzName = new String(this.getClass().getName() + ".performTask :");	
	final static String SS_projectList = "SS_projectList";	
	final static String SS_typeCategory = "SS_typeCategory";	

	public SERV_SettingSendMailServlet() {
		super();
	}   	
	
	
	private void GenRedirectCode(PrintWriter out,String page,String redirect,String error,String otherMsg) {
		out.println("<form method='post' action='"+page+"'>");		
		out.println("<input type='hidden' name='error' value='"+error+"'>");
		out.println("<input type='hidden' name='other_msg' value='"+doString.MS874ToUnicode(otherMsg)+"'>");
		out.println("<input type='hidden' name='redirect_url' value='"+doString.MS874ToUnicode(redirect)+"'>");		
		out.println("<script> document.forms[0].submit();</script>");
		out.println("</form>");		
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
	    	//System.out.println(("----->User is null");
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
			  if(command.equals("search")){		
				this.doFormSearch(request,response,user);				
			  }else if(command.equals("formAdd1")){
				 this.doFormLoadAdd1(request,response,user);  
			  }else if(command.equals("formAdd2")){
				 this.doFormLoadAdd2(request,response,user);  
			  }else if(command.equals("submit")){
				 this.doFormSubmit(request, response, user);
			  }else if(command.equals("delete")){
				 this.doFormDelete(request, response, user);
			  }else if(command.equals("edit")){
				 this.doFormEdit(request, response, user);
			  }else if(command.equals("onchangeItems")){	  
				String html = this.doEchoItemsDropdownList(request,response);
				out = response.getWriter();
				out.println(html);
			  }else if(command.equals("selNdesc")){	  
				String html = this.doEchoItems(request,response);
				out = response.getWriter();
				out.println(html);
			  }
			  
			  
		}catch(Exception e){
			e.printStackTrace();
			System.out.println(sysName+":"+clazzName +" "+e.toString());		
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
			 String mainDDL =  doString.checkString(request.getParameter("jobTypeDDL"),"");
			 List listTypeCategory = this.ListJobTypeCategory(conn,mainDDL);
			 //System.out.println("==>arrItemsList :"+arrSubsList.size());
			 String temp =  builItemsCategoryDropDownTagHTML(listTypeCategory);
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
	
	
	protected String doEchoItems(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
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
			 String mainDDL =  doString.checkString(request.getParameter("jobTypeDDL"),"");
			 
			 //List listTypeCategory = this.ListJobTypeCategory(conn,mainDDL);
			 String Category = this.SelectJobTypeCategory(conn,mainDDL.substring(0,2),mainDDL.substring(3));
			 
			 
			 //String temp =  builItemsCategoryDropDownTagHTML(listTypeCategory);
			 //System.out.println("==>arrItemsList :"+arrSubsList.size());
			 //System.out.println("==>temp :"+temp);
			 
			//out.print(temp);
	   		//*********Dispatcher  	 
		  	//System.out.println("doEchoItemsDropdownList ->successfully.");	  
			/****** Clear *******/
			conn.close();
			conn = null;
			return Category;
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
	

	private  static String builItemsCategoryDropDownTagHTML(List objList)throws Exception{
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
			    code =  doString.checkString(hashMap.get("TYPE_CODE").toString());
			    valueTxt = code+":"+doString.checkString(hashMap.get("TYPE_SUB").toString());
			    //System.out.println(" valueTxt :"+valueTxt);
			    
			    nameTxt = doString.checkString(hashMap.get("TYPE_NAME").toString());
				str.append("<option value='"+valueTxt+"'  >"+code+doString.checkString(hashMap.get("TYPE_SUB").toString())+" "+doString.DisplayThai(nameTxt)+"</option>");		    		
		    }//End while it.next()
		    return str.toString();
	    }else{
	    	return "";
	    }
	}

    //*****method doFormSearch criteria projectDDL
	protected void doFormSearch(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		ServletContext context = getServletContext();
		HttpSession session = request.getSession(false);	
		String msgTxt = "";// Constants.APP_PATH+Constants.SAVE_PAGE;
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
        try{
        	//System.out.println("doFormSearch ->Starting.");
        	//printOutParam(request, "====== doFormSearch =======");
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			//conn.setAutoCommit(false);	
			
			String projectDDL = doString.checkString(request.getParameter("projectDDL"),"");
			String jobTypeDDL = doString.checkString(request.getParameter("jobTypeDDL"),"") ;
			String employ = doString.checkString(request.getParameter("employ"),"") ;
			
			
			String comId = "";
			String projId = "";
			if(isValueStrAndObj(projectDDL)){
				String [] x = projectDDL.split("\\:");
				comId = x[0];
				projId = x[1];
			}			
			List result =  null;
			if(isValueStrAndObj(projectDDL) || isValueStrAndObj(jobTypeDDL) || isValueStrAndObj(employ)){
				result = this.ListHashSearchCriteria(conn, comId, projId, jobTypeDDL, employ);
			}
			//List ALL Project
			List projectList = this.ListProjectResposible(conn);			
			//List Type ALL
			List typeCategory = this.ListJobTypeCategory(conn);
			
			List typeSubCategory = this.ListJobTypeCategory(conn,jobTypeDDL);
		
			request.setAttribute("typeSubCategory",typeSubCategory);
			request.setAttribute("resultHashList",result);
			session.setAttribute(SS_projectList,projectList);
			session.setAttribute(SS_typeCategory,typeCategory);
			
			System.out.println("====projectDDL : "+projectDDL);
			System.out.println("====jobTypeDDL : "+jobTypeDDL);
			request.setAttribute("projectDDL",projectDDL);
			request.setAttribute("jobTypeDDL",jobTypeDDL);
			request.setAttribute("employ",employ);
			String tarGetUrl ="/SERV_SettingSendMail_01_List.jsp";
	   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			dispatcher.forward(request,response);	
			
			//Close Connection
			conn.close();
			conn= null;
		}catch(Exception e){
			System.out.println("!!! doFormSearch , " +sysName+":"+ clazzName + " : " + e.getMessage());	
			msgTxt = "doFormSearch , " +sysName+":"+ clazzName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
			return;
		}
		finally{			
			//clean up.
			try{
				if(conn!=null){conn.close();}
				conn = null;
			}catch(Exception e){}
		}
	} 
	
	//*****	method doFormDelete criteria projectDDL
	protected void doFormDelete(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		//ServletContext context = getServletContext();
		HttpSession session = request.getSession(false);	
		String errorCode = "99";	
		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";		
		String SUCCESS_PAGE = request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_SettingSendMailServlet?cmd=search";
	
        try{
        	//System.out.println(("doFormDelete ->Starting.");
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			//conn.setAutoCommit(false);	
			//printOutParam(request, "====doFormDelete=====");
			
			String projectDDL = doString.checkString(request.getParameter("projectDDL"),"");
			String jobTypeDDL = doString.checkString(request.getParameter("jobTypeDDL"),"") ;
			
			String projectDelete = doString.checkString(request.getParameter("projectDelete"),"");
			String jobTypeDelete = doString.checkString(request.getParameter("jobTypeDelete"),"") ;			
			String employ = doString.checkString(request.getParameter("employ"),"") ;
			
		    // document.forms[0].projectDelete.value=comId; //LH
	        // document.forms[0].jobTypeDelete.value=typeCode; 
			/*String []temp2 = {"",""};
			if(jobTypeDelete.length()>0){
				temp2 = jobTypeDelete.split("\\:");
			}*/
	
			String [] a = {"",""};
			String code = "";
			String sub  ="";
			a = jobTypeDelete.split("\\:");
			
			if(jobTypeDelete.length()>3){			
				code = a[0];
				sub  = a[1];
			}else{
				code = a[0];
				sub = "";
			}		
			String comId = "";
			String projId = "";
			if(isValueStrAndObj(projectDelete)){
				String [] x =  {"",""};
				x  = projectDelete.split("\\:");
				comId = x[0];
				projId = x[1];
			}			
			//System.out.println("======== comId "+comId);	
			//System.out.println("======== projId "+projId);	
			
			if(isValueStrAndObj(projectDelete) && isValueStrAndObj(jobTypeDelete) ){//&& isValueStrAndObj(employ)
				this.Delete$SVC_STDSETMAIL(conn, comId, projId, code.trim(),sub.trim());
			}		
			//List ALL Project
			//List projectList = this.ListProjectResposible(conn, user.getUserID());
			
			//List Type ALL

			String forward = "|projectDDL="+projectDDL+"|jobTypeDDL="+jobTypeDDL+"|employ="+employ;
			System.out.println("URL Forward :"+SUCCESS_PAGE+forward);
			response.sendRedirect(SUCCESS_PAGE+forward);
			//Close Connection
			conn.close();
			conn= null;
			return;
		}catch(Exception e){
			System.out.println("!!! doFormDelete , " +sysName+":"+ clazzName + " : " + e.getMessage());	
			msgTxt = "doFormDelete , " +sysName+":"+ clazzName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
			return;
		}
		finally{			
			//clean up.
			try{
				if(conn!=null){conn.close();}
				conn = null;
			}catch(Exception e){}
		}
	} 
	//*****	method doFormLoadAdd1 criteria projectDDL
	protected void doFormLoadAdd1(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		ServletContext context = getServletContext();
		HttpSession session = request.getSession(false);	
		String msgTxt = "";// Constants.APP_PATH+Constants.SAVE_PAGE;
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
        try{
        	//System.out.println("doFormLoadAdd1 ->Starting.");
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			//conn.setAutoCommit(false);	
			
			//List ALL Project
			List projectList = this.ListProjectResposible(conn);
			
			//List Type ALL
			List typeCategory = this.ListJobTypeCategory(conn);
			
			session.setAttribute(SS_projectList,projectList);
			session.setAttribute(SS_typeCategory,typeCategory);
			
			String tarGetUrl ="/SERV_SettingSendMail_02_Form.jsp";
	   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			dispatcher.forward(request,response);	
			
			//Close Connection
			conn.close();
			conn= null;
		}catch(Exception e){
			System.out.println("!!! doFormLoadAdd1 , " +sysName+":"+ clazzName + " : " + e.getMessage());	
			msgTxt = "doFormLoadAdd1 , " +sysName+":"+ clazzName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
			return;
		}
		finally{			
			//clean up.
			try{
				if(conn!=null){conn.close();}
				conn = null;
			}catch(Exception e){}
		}
	} 	
	
	
	//*****	method doFormLoadAdd2 criteria projectDDL
	protected void doFormLoadAdd2(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		ServletContext context = getServletContext();
		HttpSession session = request.getSession(false);	
		String msgTxt = "";// Constants.APP_PATH+Constants.SAVE_PAGE;
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
        try{
        	//System.out.println(("doFormLoadAdd2 ->Starting.");
        	//printOutParam(request, "doFormLoadAdd2");
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			//conn.setAutoCommit(false);	
			
			
			
			String[] projSelDDL = request.getParameterValues("projSelDDL"); 
			String jobTypeDDL = request.getParameter("jobTypeDDL");
			String jobSubDDL = request.getParameter("jobSubDDL") == null ? "" : request.getParameter("jobSubDDL").toString();

			
			
			
			String []temp2 = {"",""};
			if(jobSubDDL.length()>0){
				temp2 = jobSubDDL.split("\\:");
			}
			
			List<HashMap>  listHash = new ArrayList<HashMap>();
			HashMap hashTemp = null;
			String []temp = null;
			for(int x = 0;x<projSelDDL.length;x++){
				//System.out.println((x+" ====>"+projSelDDL[x]);
				temp = projSelDDL[x].split("\\:");
				hashTemp = GetHash$SVC_STDSETMAIL(conn, temp[0], temp[1], jobTypeDDL,temp2[1]);
				listHash.add(hashTemp);
			}
			List listTypeCategory = this.ListJobTypeCategory(conn,jobTypeDDL);

			request.setAttribute("listTypeCategory",listTypeCategory); //dddd
			request.setAttribute("jobSubDDL",jobSubDDL); //dddd
			request.setAttribute("hashData",listHash); //String Array
			request.setAttribute("jobTypeDDL",jobTypeDDL);
			String tarGetUrl ="/SERV_SettingSendMail_03_Form.jsp";
	   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			dispatcher.forward(request,response);	
			
			//Close Connection
			conn.close();
			conn= null;
		}catch(Exception e){
			System.out.println("!!! doFormLoadAdd2 , " +sysName+":"+ clazzName + " : " + e.getMessage());	
			msgTxt = "doFormLoadAdd2 , " +sysName+":"+ clazzName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
			return;
		}
		finally{			
			//clean up.
			try{
				if(conn!=null){conn.close();}
				conn = null;
			}catch(Exception e){}
		}
	}
	
	protected void doFormEdit(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		ServletContext context = getServletContext();
		HttpSession session = request.getSession(false);	
		String msgTxt = "";// Constants.APP_PATH+Constants.SAVE_PAGE;
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
        try{
        	//System.out.println(("doFormLoadAdd2 ->Starting.");
        	//printOutParam(request, "doFormLoadAdd2");
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			//conn.setAutoCommit(false);	
			
			String[] projSelDDL = request.getParameterValues("projectDelete"); 
			String jobTypeDDL = request.getParameter("jobTypeDelete");
			String jobSubDDL = request.getParameter("jobSubDDL")==null?"":request.getParameter("jobSubDDL").toString();
			
			
			String part1 = "";
			String part2 = "";

//			 ตรวจสอบว่า jobTypeDDL ไม่เป็น null และมีเครื่องหมาย ":"
			if (jobTypeDDL != null && jobTypeDDL.contains(":")) {
			    String[] parts = jobTypeDDL.split(":");
			    part1 = parts[0]; // 02
			    if (parts.length > 1) {
			        part2 = parts[1]; // 08
			    } else {
			        part2 = ""; // ถ้าไม่มีส่วนที่สองให้เป็นค่าว่าง
			    }
			} else {
			    part1 = jobTypeDDL != null ? jobTypeDDL : ""; // ถ้าไม่มีเครื่องหมาย ":" ให้ part1 เป็น jobTypeDDL
			    part2 = ""; // ให้ part2 เป็นค่าว่าง
			}

			    System.out.println("Part 1: " + part1);
			    System.out.println("Part 2: " + part2);
			
			
			List<HashMap>  listHash = new ArrayList<HashMap>();
			HashMap hashTemp = null;
			String []temp = null;
			for(int x = 0;x<projSelDDL.length;x++){
				//System.out.println((x+" ====>"+projSelDDL[x]);
				temp = projSelDDL[x].split("\\:");
				hashTemp = GetHash$SVC_STDSETMAIL(conn, temp[0], temp[1], part1,part2);
				listHash.add(hashTemp);
			}
			List listTypeCategory = this.ListJobTypeCategory(conn,jobTypeDDL);

			request.setAttribute("listTypeCategory",listTypeCategory); //dddd
			request.setAttribute("jobSubDDL",jobTypeDDL); //dddd
			request.setAttribute("hashData",listHash); //String Array
			request.setAttribute("jobTypeDDL",part1);
			String tarGetUrl ="/SERV_SettingSendMail_04_Form.jsp";
	   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			dispatcher.forward(request,response);	
			
			//Close Connection
			conn.close();
			conn= null;
		}catch(Exception e){
			System.out.println("!!! doFormLoadAdd2 , " +sysName+":"+ clazzName + " : " + e.getMessage());	
			msgTxt = "doFormLoadAdd2 , " +sysName+":"+ clazzName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
			return;
		}
		finally{			
			//clean up.
			try{
				if(conn!=null){conn.close();}
				conn = null;
			}catch(Exception e){}
		}
	} 
	

    //*****method doFormLoad criteria projectDDL
	protected void doFormSubmit(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		//response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		ServletContext context = getServletContext();
		HttpSession session = request.getSession(false);		

		String errorCode = "99";	
		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";		
		String SUCCESS_PAGE = request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_SettingSendMailServlet?cmd=search";
	
        try{
        	 //System.out.println("doFormLoad ->Starting.");
        	//printOutParam(request,"===FormSubmit===");
 			//----------Open connection
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
  			//conn.setAutoCommit(false);
            //-------------------------
			String tempProjectTxt = doString.checkString(request.getParameter("tempProjectTxt"),"");//AR:031:I|LA:003:U|
			String []tempArrProjectId = tempProjectTxt.split("\\|"); //0,1,2
			String jobTypeDDL = doString.checkString(request.getParameter("jobTypeDDL"),"");
			String jobSubDDL = doString.checkString(request.getParameter("jobSubDDL"),"");
			String chk1 = doString.checkString(request.getParameter("chk1"),"");//chk1=1
			String chk2 = doString.checkString(request.getParameter("chk2"),"");//chk1=1
			String chk3 = doString.checkString(request.getParameter("chk3"),"");//chk1=1
			String chk4 = doString.checkString(request.getParameter("chk4"),"");//chk1=1
			String chk5 = doString.checkString(request.getParameter("chk5"),"");//chk1=1
			String chk6 = doString.checkString(request.getParameter("chk6"),"");//chk1=1
			
			String[] temp2 = {"", ""};
			if (jobSubDDL.length() > 0) {
			    temp2 = jobSubDDL.split(":", 2); // แยกสตริงให้ได้ 2 ส่วน
			    if (temp2.length == 1) {
			        temp2 = new String[]{temp2[0], ""}; // ถ้ามีแค่ส่วนเดียว ให้กำหนดส่วนที่สองเป็นค่าว่าง
			    }
			}

			//System.out.println("ddd :"+jobSubDDL);
			//System.out.println("temp2[1] :"+temp2[1]);
			
			
			String emp1 = "";
			String emp2 = "";
			String emp3 = "";
			String emp4 = "";
			String emp5 = "";
			String emp6 = "";
			String desc = "";
			String [] temp = null;
			for(int x =0;x<tempArrProjectId.length;x++){
				 emp1 = "";
				 emp2 = "";
				 emp3 = "";
				 emp4 = "";
				 emp5 = "";
				 emp6 = "";
				 temp = tempArrProjectId[x].split("\\:");
				 emp1 = doString.checkString(request.getParameter("employ1_"+x),"");//AR:031:I|LA:003:U|
				 emp2 = doString.checkString(request.getParameter("employ2_"+x),"");//AR:031:I|LA:003:U|
				 emp3 = doString.checkString(request.getParameter("employ3_"+x),"");//AR:031:I|LA:003:U|
				 emp4 = doString.checkString(request.getParameter("employ4_"+x),"");//AR:031:I|LA:003:U|
				 emp5 = doString.checkString(request.getParameter("employ5_"+x),"");//AR:031:I|LA:003:U|
				 emp6 = doString.checkString(request.getParameter("employ6_"+x),"");//AR:031:I|LA:003:U|
				 desc = doString.checkString(request.getParameter("desc_"+x),"");//AR:031:I|LA:003:U|
				 if("1".equals(chk1)){
					 emp1 = emp1;
				 }
				 if("1".equals(chk2)){
					 emp2 = emp2;
				 }
				 if("1".equals(chk3)){
					 emp3 = emp3;
				 }
				 if("1".equals(chk4)){
					 emp4 = emp4;
				 }
				 if("1".equals(chk5)){
					 emp5 = emp5;
				 }
				 if("1".equals(chk6)){
					 emp6 = emp6;
				 }
				 
				 if(temp[2].equalsIgnoreCase("U")){
					//Update 
					Update$SVC_STDSETMAIL(conn, temp[0], temp[1], jobTypeDDL,temp2[1], emp1, emp2, emp3, emp4, emp5, emp6,desc, user.getEmpId());
				 }else if(temp[2].equalsIgnoreCase("I")){
					//Insert
					Insert$SVC_STDSETMAIL(conn, temp[0], temp[1], jobTypeDDL,temp2[1], emp1, emp2, emp3, emp4, emp5, emp6,desc, user.getEmpId());
				 }
			}//#For
			//***************************************************************************/		
	   		//*********Dispatcher  	 
		  	//System.out.println(("Submit ->successfully.");	  	
		  	 
		  	String forward = "|projectDDL=|jobTypeDDL="+jobTypeDDL+"|employ=";
			response.sendRedirect(SUCCESS_PAGE+forward);
			/****** Clear *******/
			conn.close();
			conn = null;
			return;
		}catch(Exception e){
			System.out.println("!!! doFormSubmit , " +sysName+":"+ clazzName + " : " + e.getMessage());	
			msgTxt = "doFormSubmit , " +sysName+":"+ clazzName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
			return;
		}
		finally{			
			//clean up.
			synchronized(session){
				//session.invalidate();	
				session.removeAttribute(SS_projectList);
				session.removeAttribute(SS_typeCategory);
			}	
			try{
				if(conn!=null){conn.close();}
			}catch(Exception e){}
		}
	} 

	private List<HashMap> ListProjectResposible(Connection conn) {
		// TODO Auto-generated method stub
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial parameter		      
        	List  projectDDL = new ArrayList();
        	HashMap<String, String> hashMap = null;   
        	//System.out.println("LIST_PROJECT_RESPOSIBLE ->Starting.");        	 

        	 //modify by pradoem 2023.07.19 for ALL project the same CALL Center
			 sql.append(" select i_company,i_project,n_project from lan:acxprojt   ")
			   .append(" where i_company in ('LH','LA','NE','PF','LT','AR','AP','SA','SI')   ")
			   .append(" and i_project[1,1] between '0' and '9' ")
			   .append(" and i_project not in ('0','901','909','000')  ")			 
			   .append(" or (i_company = 'LH' and i_project ='099') ")
			   .append(" order by i_company,i_project ");
			//System.out.println("SQL :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString());
			rs = pstmt.executeQuery();				
			while(rs.next()){
				hashMap = new HashMap<String, String>();
				hashMap.put("value", doString.checkString(rs.getString("i_company"),"")+":"+doString.checkString(rs.getString("i_project"),""));
				hashMap.put("pj_name", doString.checkString(rs.getString("n_project"),""));
				projectDDL.add(hashMap);
			}   			
			//********************************************************/
		  	//System.out.println("LIST_PROJECT_RESPOSIBLE ->successfully.");				  	 
		  	return projectDDL;			  	 
		}catch(Exception e){
			System.out.println("!! LIST_PROJECT_RESPOSIBLE , " +sysName+":"+ clazzName + " : " + e.getMessage());
			System.out.println("!! SQL Exception: "+sql.toString());		
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
	private List<HashMap> ListJobTypeCategory(Connection conn) {
		// TODO Auto-generated method stub
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	        try{
	        	//initial paramter	 
	 	       	List  hashArrList = new ArrayList();
	        	HashMap<String, String> hashMap = null;   
				/******************************************************/			
	        	sql.delete(0,sql.length());
				sql.append(" select i_type,n_desc from lan:svc_xstd  ")
				   .append("  where i_code is null  order by i_type ");
				//System.out.println("<<<<<--Group from ListMainCategory:' - SQL :"+sql.toString());
	 			pstmt = conn.prepareStatement(sql.toString()); 
		     	rs = pstmt.executeQuery();	
		     	while(rs.next()){
					hashMap = new HashMap<String, String>();
					hashMap.put("TYPE_CODE", doString.checkString(rs.getString("i_type"),""));//01,02
					hashMap.put("TYPE_NAME", doString.checkString(rs.getString("n_desc"),""));//Value
					hashArrList.add(hashMap);
		        }
				rs.close();		   			
			//********************************************************/
			//System.out.println("ListJobTypeCategory ->successfully.");				  	 
			return hashArrList;			  	 
		}catch(Exception e){
				System.out.println("!! ListJobTypeCategory , " +sysName+":"+ clazzName + " : " + e.getMessage());
				System.out.println("!! SQL Exception: "+sql.toString());		
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
	
	private List<HashMap> ListJobTypeCategory(Connection conn,String itempSub) {
		// TODO Auto-generated method stub
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	        try{
	        	//initial paramter	 
	 	       	List  hashArrList = new ArrayList();
	        	HashMap<String, String> hashMap = null;   
				/******************************************************/			
	        	sql.delete(0,sql.length());
				sql.append(" select i_type,i_code,n_desc from lan:svc_xstd  ")
				   .append("  where i_type = '"+itempSub+"'  and i_code is not null  order by i_type  ");
				//System.out.println("<<<<<--Group from ListJobTypeCategory:' - SQL :"+sql.toString());
	 			pstmt = conn.prepareStatement(sql.toString()); 
		     	rs = pstmt.executeQuery();	
		     	while(rs.next()){
					hashMap = new HashMap<String, String>();
					hashMap.put("TYPE_CODE", doString.checkString(rs.getString("i_type"),""));//01,02
					hashMap.put("TYPE_SUB", doString.checkString(rs.getString("i_code"),""));//01,02
					hashMap.put("TYPE_NAME", doString.checkString(rs.getString("n_desc"),""));//Value
					hashArrList.add(hashMap);
		        }
				rs.close();		   			
			//********************************************************/
			//System.out.println("ListJobTypeCategory ->successfully.");				  	 
			return hashArrList;			  	 
		}catch(Exception e){
				System.out.println("!! ListJobTypeCategory , " +sysName+":"+ clazzName + " : " + e.getMessage());
				System.out.println("!! SQL Exception: "+sql.toString());		
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
	
	private String SelectJobTypeCategory(Connection conn,String itempSub ,String iCode ) {
		// TODO Auto-generated method stub
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			String data = "";
	        try{
	        	//initial paramter	 
				/******************************************************/			
	        	sql.delete(0,sql.length());
				sql.append(" select i_type,i_code,n_desc from lan:svc_xstd  ")
				   .append("  where i_type = '"+itempSub+"'  and i_code = '"+iCode+"'  order by i_type  ");
				//System.out.println("<<<<<--Group from ListJobTypeCategory:' - SQL :"+sql.toString());
	 			pstmt = conn.prepareStatement(sql.toString()); 
		     	rs = pstmt.executeQuery();	
		     	if(rs.next()){
		     		data = doString.checkString(rs.getString("i_type"),"");
		     		data += doString.checkString(rs.getString("i_code"),"");
		     		data += doString.checkString(rs.getString("n_desc"),"");
		        }
				rs.close();		   			
			//********************************************************/
			//System.out.println("ListJobTypeCategory ->successfully.");				  	 
			return data;			  	 
		}catch(Exception e){
				System.out.println("!! SelectJobTypeCategory , " +sysName+":"+ clazzName + " : " + e.getMessage());
				System.out.println("!! SQL Exception: "+sql.toString());		
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
	  
	//Search 
	private List<HashMap> ListHashSearchCriteria(Connection conn,String comId,String projId,String sysCode,String employ) {
		// TODO Auto-generated method stub
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	        try{
	        	//initial paramter	 
	 	       	List  hashArrList = new ArrayList();
	        	HashMap<String, String> hashMap = null;  
	        	HashMap<String, String> hashMapTemp = null;
				/******************************************************/			
	        	sql.delete(0,sql.length());
				sql.append(" Select x.I_COMPANY,x.I_PROJECT,x.SYS_TYPE,x.SYS_TYPE2,n.n_project,x.EMPLOY1,x.EMPLOY2,x.EMPLOY3,x.EMPLOY4,x.EMPLOY5,x.EMPLOY6,x.DESC  ")
				   .append(" From lan:svc_stdsetmail x ,lan:acxprojt n ")
				   .append(" Where 1=1 ")
				   .append(" and x.i_company = n.i_company  ")
				  .append(" and x.i_project = n.i_project ");
				if(isValueStrAndObj(comId) && isValueStrAndObj(projId)){
					sql.append(" and x.i_company = '"+comId+"'  ")
					   .append(" and x.i_project = '"+projId+"' ");
				}	
				if(isValueStrAndObj(sysCode)){
					sql.append(" and x.sys_type = '"+sysCode+"'  ");
				}
				if(isValueStrAndObj(employ)){
					sql.append(" and (x.employ1 = '"+employ+"'  ")
					.append(" or x.employ2 = '"+employ+"' ")
					.append(" or x.employ3 = '"+employ+"' ")
					.append(" or x.employ4 = '"+employ+"' ")
					.append(" or x.employ5 = '"+employ+"' ")
					.append(" or x.employ6 = '"+employ+"' ) ");
				}
				sql.append(" Order by x.i_company,x.i_project ");
				//System.out.println(("SQL "+sql.toString());
				pstmt = conn.prepareStatement(sql.toString()); 
		     	rs = pstmt.executeQuery();	
		     	while(rs.next()){
					hashMap = new HashMap<String, String>();
					hashMap.put("COM_ID", doString.checkString(rs.getString("I_COMPANY"),""));//01,02
					hashMap.put("PROJ_ID", doString.checkString(rs.getString("I_PROJECT"),""));//Value
					hashMap.put("N_PROJECT", doString.checkString(rs.getString("n_project"),""));//Value
					hashMap.put("SYS_TYPE", doString.checkString(rs.getString("SYS_TYPE"),""));
					hashMap.put("SYS_TYPE2", doString.checkString(rs.getString("SYS_TYPE2"),""));
					hashMap.put("EMPLOY1", doString.checkString(rs.getString("EMPLOY1"),""));
					hashMap.put("EMPLOY2", doString.checkString(rs.getString("EMPLOY2"),""));
					hashMap.put("EMPLOY3", doString.checkString(rs.getString("EMPLOY3"),""));
					hashMap.put("EMPLOY4", doString.checkString(rs.getString("EMPLOY4"),""));
					hashMap.put("EMPLOY5", doString.checkString(rs.getString("EMPLOY5"),""));
					hashMap.put("EMPLOY6", doString.checkString(rs.getString("EMPLOY6"),""));
					hashMap.put("DESC", doString.checkString(rs.getString("DESC"),""));
					if(isValueStrAndObj( doString.checkString(rs.getString("EMPLOY1"),""))){
						hashMapTemp = this.GetHashFullName$EmailByEmployID(conn, doString.checkString(rs.getString("EMPLOY1"),""));
						hashMap.put("EMP_NAME1", hashMapTemp.get("EMP_FULLNAME"));
						hashMap.put("EMP_EMAIL1",hashMapTemp.get("EMP_EMAIL"));
					}else{
						hashMap.put("EMP_NAME1", "");
						hashMap.put("EMP_EMAIL1","");
					}
					if(isValueStrAndObj( doString.checkString(rs.getString("EMPLOY2"),""))){
						hashMapTemp = this.GetHashFullName$EmailByEmployID(conn, doString.checkString(rs.getString("EMPLOY2"),""));
						hashMap.put("EMP_NAME2", hashMapTemp.get("EMP_FULLNAME"));
						hashMap.put("EMP_EMAIL2",hashMapTemp.get("EMP_EMAIL"));
					}else{
						hashMap.put("EMP_NAME2", "");
						hashMap.put("EMP_EMAIL2","");
					}
					if(isValueStrAndObj( doString.checkString(rs.getString("EMPLOY3"),""))){
						hashMapTemp = this.GetHashFullName$EmailByEmployID(conn, doString.checkString(rs.getString("EMPLOY3"),""));
						hashMap.put("EMP_NAME3", hashMapTemp.get("EMP_FULLNAME"));
						hashMap.put("EMP_EMAIL3",hashMapTemp.get("EMP_EMAIL"));
					}else{
						hashMap.put("EMP_NAME3", "");
						hashMap.put("EMP_EMAIL3","");
					}	
					if(isValueStrAndObj( doString.checkString(rs.getString("EMPLOY4"),""))){
						hashMapTemp = this.GetHashFullName$EmailByEmployID(conn, doString.checkString(rs.getString("EMPLOY4"),""));
						hashMap.put("EMP_NAME4", hashMapTemp.get("EMP_FULLNAME"));
						hashMap.put("EMP_EMAIL4",hashMapTemp.get("EMP_EMAIL"));
					}else{
						hashMap.put("EMP_NAME4", "");
						hashMap.put("EMP_EMAIL4","");
					}
					if(isValueStrAndObj( doString.checkString(rs.getString("EMPLOY5"),""))){
						hashMapTemp = this.GetHashFullName$EmailByEmployID(conn, doString.checkString(rs.getString("EMPLOY5"),""));
						hashMap.put("EMP_NAME5", hashMapTemp.get("EMP_FULLNAME"));
						hashMap.put("EMP_EMAIL5",hashMapTemp.get("EMP_EMAIL"));
					}else{
						hashMap.put("EMP_NAME5", "");
						hashMap.put("EMP_EMAIL5","");
					}
					if(isValueStrAndObj( doString.checkString(rs.getString("EMPLOY6"),""))){
						hashMapTemp = this.GetHashFullName$EmailByEmployID(conn, doString.checkString(rs.getString("EMPLOY6"),""));
						hashMap.put("EMP_NAME6", hashMapTemp.get("EMP_FULLNAME"));
						hashMap.put("EMP_EMAIL6",hashMapTemp.get("EMP_EMAIL"));
					}else{
						hashMap.put("EMP_NAME6", "");
						hashMap.put("EMP_EMAIL6","");
					}
					hashArrList.add(hashMap);
		        }
				rs.close();		   			
			//********************************************************/
			//System.out.println("ListHashSearchCriteria ->successfully.");				  	 
			return hashArrList;			  	 
		}catch(Exception e){
				System.out.println("!! ListHashSearchCriteria , " +sysName+":"+ clazzName + " : " + e.getMessage());
				System.out.println("!! SQL Exception: "+sql.toString());		
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
	private HashMap GetHash$SVC_STDSETMAIL(Connection conn, String comId, String projectId,String typeCode,String itemSub) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		HashMap hashMapData = null;
		
        try{
        	//initial paramter	
        	boolean isRecord = true;
			/*************************************************/			
        	//*****Find project by user login  
			sql.delete(0,sql.length());
			sql.append(" Select I_COMPANY,I_PROJECT,SYS_TYPE,EMPLOY1,EMPLOY2,EMPLOY3,EMPLOY4,EMPLOY5,EMPLOY6,desc ")
			   .append(" From lan:SVC_STDSETMAIL Where i_company = ? and i_project = ? and SYS_TYPE = ?  and SYS_TYPE2 = ?");
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, comId);	
			pstmt.setString(2, projectId);
			pstmt.setString(3, typeCode);
			pstmt.setString(4, itemSub);
			//System.out.println(("SQL :"+sql.toString());
			rs = pstmt.executeQuery();	
			if(rs.next()){
				isRecord = false;
				//projectNamme = doString.checkString(rs.getString("n_project"), "");
				hashMapData = new HashMap<String,String>();
				hashMapData.put("COM_ID", comId);//I_COMPANY
				hashMapData.put("PROJ_ID", projectId);//I_PROJECT
				hashMapData.put("N_PROJECT", "");
				hashMapData.put("SYS_TYPE", typeCode);//SYS_TYPE	
				hashMapData.put("SYS_TYPE2", itemSub);//SYS_TYPE2
				hashMapData.put("EMP1", doString.checkString(rs.getString("EMPLOY1"), ""));
				hashMapData.put("EMP2", doString.checkString(rs.getString("EMPLOY2"), ""));
				hashMapData.put("EMP3", doString.checkString(rs.getString("EMPLOY3"), ""));
				hashMapData.put("EMP4", doString.checkString(rs.getString("EMPLOY4"), ""));
				hashMapData.put("EMP5", doString.checkString(rs.getString("EMPLOY5"), ""));
				hashMapData.put("EMP6", doString.checkString(rs.getString("EMPLOY6"), ""));
				hashMapData.put("DESC", doString.checkString(rs.getString("desc"), ""));
				hashMapData.put("DUP", "U");
			}
			if(isRecord){
				hashMapData = new HashMap<String,String>();
				hashMapData.put("COM_ID", comId);
				hashMapData.put("PROJ_ID", projectId);
				hashMapData.put("N_PROJECT", "");
				hashMapData.put("SYS_TYPE", typeCode);	
				hashMapData.put("SYS_TYPE2", itemSub);//SYS_TYPE2
				hashMapData.put("EMP1", "");
				hashMapData.put("EMP2", "");
				hashMapData.put("EMP3", "");
				hashMapData.put("EMP4", "");
				hashMapData.put("EMP5", "");
				hashMapData.put("EMP6", "");
				hashMapData.put("DESC", "");
				hashMapData.put("DUP", "I");
			}
			rs.close();	
			//**************************************************/
		  	//System.out.println("##GetHash$SVC_STDSETMAIL ->successfully.");				  	 
		  	return hashMapData;			  	 
		}catch(Exception e){
			System.out.println("!!!GetHash$SVC_STDSETMAIL , " +sysName+":"+ clazzName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
			return hashMapData;
		}
		finally{			
			//clean up.
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
			}catch(Exception e){}
		}
	}
	
	private HashMap GetHashFullName$EmailByEmployID(Connection conn, String employId) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;

        try{
        	//initial paramter	 
        	HashMap hashMapData = null;
    		String  emmployName = "";
    		String  emailAddress = "";
			/*************************************************/			
        	//*****Find project by user login  
			sql.delete(0,sql.length());
			sql.append(" Select unique n_prename_th,n_nemploy_th,n_semploy_th,y.user_email From docflow:acemploy x,docflow:useracl y ")
			   .append(" Where  x.i_employ = y. i_employ ")
		       .append(" and x.i_employ = ? ");
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, employId);	
			//System.out.println("SQL :"+sql.toString());
			rs = pstmt.executeQuery();	
			if(rs.next()){
				emmployName = doString.checkString(rs.getString("n_prename_th"), "")+" "+
				doString.checkString(rs.getString("n_nemploy_th"), "")+"  "+doString.checkString(rs.getString("n_semploy_th"), "");
				emailAddress = doString.checkString(rs.getString("user_email"), "");
			}
			rs.close();	
			hashMapData = new HashMap<String,String>();
			hashMapData.put("EMP_FULLNAME", emmployName);
			hashMapData.put("EMP_EMAIL", emailAddress);

			//**************************************************/
		  	//System.out.println("##GetHashFullName$EmailByEmployID ->successfully.");				  	 
		  	return hashMapData;			  	 
		}catch(Exception e){
			System.out.println("!!!GetHashFullName$EmailByEmployID , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
	private int Insert$SVC_STDSETMAIL(Connection conn,String comId,String projId,String sysType,String sysType2,
			String emp1,String emp2,String emp3,String emp4,String emp5,String emp6,String desc,String empBy) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		
		if ("07".equals(sysType)) { //fix by petch  ***Beyond Service no sys_type2
			sysType2 = "01";
		}
		
        try{
        	//initial parameter	        
        	//System.out.println("##Insert$SVC_STDSETMAIL ->Starting.");        	 
			/******************************************************/
			int i = 1;
			sql.delete(0, sql.length());
			sql.append(" INSERT INTO lan:SVC_STDSETMAIL ( ")
				.append(" I_COMPANY,") //1
				.append(" I_PROJECT,")//2
				.append(" SYS_TYPE,")//3
				.append(" EMPLOY1,") //4
				.append(" EMPLOY2,") //5
				.append(" EMPLOY3,") //6
				.append(" EMPLOY4,") //7
				.append(" EMPLOY5,")  //8
				.append(" EMPLOY6,") //9
				.append(" DESC,")   //10
				.append(" CREATE_BY,")  //11
				.append(" UPDATE_DATE,")  //12
				.append(" UPDATE_BY,")  //13
				.append(" ACCTIVE , ")   //14
				.append(" SYS_TYPE2  ) ")   //15
   	            .append(" VALUES (  ?,  ?,  ?,  ?,  ?,  ?,  ?,  ?,  ?,  ?,  ?  ,null  ,null  ,null    , ? )");  
			                     //1   2   3   4   5   6   7   8   9    10    11   12    13      14
			//System.out.println("SQL Insert :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(i++,comId);
			pstmt.setString(i++,projId);
			pstmt.setString(i++,sysType);
			pstmt.setString(i++, emp1.trim());
			pstmt.setString(i++, emp2.trim());
			pstmt.setString(i++, emp3.trim());
			pstmt.setString(i++, emp4.trim());
			pstmt.setString(i++, emp5.trim());
			pstmt.setString(i++, emp6.trim());
			pstmt.setString(i++, desc.trim());
			pstmt.setString(i++, empBy.trim());
			pstmt.setString(i++,sysType2);
			int Excuete = pstmt.executeUpdate();		
			//********************************************************/
		  	//System.out.println("##Insert$SVC_STDSETMAIL ->successfully.");
		  	return Excuete;
		}catch(Exception e){
			System.out.println("!!Insert$SVC_STDSETMAIL , " +sysName+":"+ clazzName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());	
			return -1;
		}
		finally{			
			//clean up.
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
			}catch(Exception e){}
		}
	}
	
	private int Update$SVC_STDSETMAIL(Connection conn, String comId,String projId,String sysType,String sysType2,
			String emp1,String emp2,String emp3,String emp4,String emp5,String emp6,String desc,String empBy) {
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		
		if ("07".equals(sysType)) { //fix by petch  ***Beyond Service no sys_type2
			sysType2 = "01";
		}
		
		
		try{
				//***************************************/
				sql.delete(0, sql.length());
				sql.append(" UPDATE lan:SVC_STDSETMAIL SET  UPDATE_DATE = CURRENT ,UPDATE_BY = '"+empBy+"' ");
				//value is null or Empty skip not' update record
				//if(isValueStrAndObj(emp1.trim())){
				sql.append(" ,EMPLOY1 = '").append(emp1.trim()).append("' ");
				//}
				//if(isValueStrAndObj(emp2.trim())){
				sql.append(" ,EMPLOY2 = '").append(emp2.trim()).append("' ");
				//}
				//if(isValueStrAndObj(emp2.trim())){
				sql.append(" ,EMPLOY3 = '").append(emp3.trim()).append("' ");
				//}
				//if(isValueStrAndObj(emp4.trim())){
				sql.append(" ,EMPLOY4 = '").append(emp4.trim()).append("' ");
				//}
				//if(isValueStrAndObj(emp5.trim())){
				sql.append(" ,EMPLOY5 = '").append(emp5.trim()).append("' ");
				//}
				//if(isValueStrAndObj(emp6.trim())){
				sql.append(" ,EMPLOY6 = '").append(emp6.trim()).append("' ");
				//}
				sql.append(" ,DESC = '").append(desc.trim()).append("' ");
				
				sql.append(" , SYS_TYPE2 = '").append(sysType2).append("' ");
				
				sql.append(" Where  I_COMPANY = '").append(comId).append("' ")
				   .append(" and I_PROJECT = '").append(projId).append("' ")
				   .append(" and SYS_TYPE = '").append(sysType).append("' ");
				   
				   if(!"07".equals(sysType)) {
					   sql.append(" and SYS_TYPE2 = '").append(sysType2).append("' ");
				   }
				   
				   
				System.out.println("-->Update SQL :"+sql.toString());
				pstmt = conn.prepareStatement(sql.toString()); 
				int intUdp = pstmt.executeUpdate();	
	   		  	/********************************/		
				System.out.println("##Update$SVC_STDSETMAIL : successfully.");
	   		  	return intUdp;			
		}catch(Exception e){
			System.out.println("!!!Update$SVC_STDSETMAIL , " +sysName+":"+ clazzName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
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
	
	
	private void Delete$SVC_STDSETMAIL(Connection conn, String comId,String projId,String sysType,String sysType2) {
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		
		if ("07".equals(sysType)) { //fix by petch  ***Beyond Service no sys_type2
			sysType2 = "";
		}
		
		try{
				//***************************************/
				sql.delete(0, sql.length());
				sql.append(" DELETE lan:SVC_STDSETMAIL  ");
				sql.append(" Where  I_COMPANY = '").append(comId).append("' ")
				   .append(" and I_PROJECT = '").append(projId).append("' ")
				   .append(" and SYS_TYPE = '").append(sysType).append("' ");
					if(!sysType2.equals("")){
						sql.append(" and SYS_TYPE2 = '").append(sysType2).append("' ");
					}
				//System.out.println("-->DELETE SQL :"+sql.toString());
				pstmt = conn.prepareStatement(sql.toString()); 
				int delete = pstmt.executeUpdate();	
	   		  	/********************************/		
			    //System.out.println("##Delete$SVC_STDSETMAIL : successfully. : "+delete);
	   		  	return;			
		}catch(Exception e){
			System.out.println("!!!Delete$SVC_STDSETMAIL , " +sysName+":"+ clazzName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
			return; // update failure
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
	private static boolean isValueStrAndObj(String str) throws Exception{
		if ((str == null) || str.equals("")) {
			 return false;
		}else{
			 return true;
		 }
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