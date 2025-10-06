package serv.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Enumeration;
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
 * Servlet implementation class for Servlet: SVCMasterGCalendarServlet
 *
 */
 public class SVCMasterGCalendarServlet extends   DBServlet{
    /* (non-Java-doc)
	 * @see javax.servlet.http.HttpServlet#HttpServlet()
	 */
	public SVCMasterGCalendarServlet() {
		super();
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
		 * method action
		 **************** */
		try{
			  String  command = request.getParameter("cmd")==null?"":request.getParameter("cmd");					
			  if(command.equals("load")){		
				  this.doFormLoad(request, response, user);			
			  }else if(command.equals("search")){
				  this.searchCal(request,response,user);  
			  } 
		}catch(Exception e){
			e.printStackTrace();
			System.out.println(sysName+":"+cName +" "+e.toString());		
		}
	}
	
	//	*****method FormLoad criteria projectDDL
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
   	 	String cur_year1 = Integer.toString((rightNow.get(Calendar.YEAR)+543)-1);
   	 	
   	 	String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
        try{      	
        	 System.out.println("formLoad ->Starting.");
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setAutoCommit(true);	
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);//informi
			/****************************projectDLL****************************************/
			List  projectDDL = new ArrayList();
       	 	List  strList = null;	      	
        	
       	 	/*System.out.println("ListProjectAllByBudget ->Starting.");        	 
			/****************************projectDLL****************************************/
			//int year = Calendar.getInstance().get(Calendar.YEAR);
			// if (year<2400) year += 543;
			//int pYear = year-1;

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
					.append(" AND bud.d_year in('"+cur_year1+"','"+cur_year+"')   ")
					//.append(cur_year)
					.append(" ORDER BY proj.i_company, proj.i_project ");
			} else {
				sql.append(" SELECT b.i_company, b.i_project, b.n_project ")
					.append(" FROM lan:serv_pstaff a, lan:acxprojt b ")
					.append(" WHERE a.user_id = '")
					.append(user.getUserID())
					.append("' AND a.com_id = b.i_company AND a.proj_id = b.i_project ")
					.append(" ORDER BY b.i_company, b.i_project ");
			}
			
			//System.out.println("SQL  :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString()); 
			rs = pstmt.executeQuery();				
			while(rs.next()){
					strList =  new ArrayList(); 
					strList.add(0,  doString.checkString(rs.getString("i_company"),""));
					strList.add(1,  doString.checkString(rs.getString("i_project"),""));
					strList.add(2,  doString.checkString(rs.getString("n_project"),""));
					projectDDL.add(strList);
				}
			rs.close();				
			//***************************************************************************/	
			//********************************************************/
		  	System.out.println("ListProjectAllByBudget ->end.");										
	   		 //*********Dispatcher
		  	request.setAttribute("projectList", projectDDL); 
		  	System.out.println("formLoad ->successfully.");	  	
	   		String tarGetUrl ="/SVC_GCalendarViewer.jsp";
	   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			dispatcher.forward(request,response);			
		}catch(Exception e){
			System.out.println("doFormLoad , " +sysName+":"+ cName + " : " + e.getMessage());
			System.out.println("!!! SQL Exception: "+sql.toString());		
			//Dispat to Error message page
			// String ERROR_PAGE = "/MsgSuccessPage.jsp?msg="+e.getMessage()+"&error=1&url=/SALE_ContractFur.jsp";
			//String ERROR_PAGE = "/errorPage.jsp";
			//RequestDispatcher dispatcher = context.getRequestDispatcher(ERROR_PAGE);
			//dispatcher.forward(request,response);
			msgTxt = "!!! doFormLoad, " +sysName+":"+ cName + " : " + e.getMessage();
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
	protected void searchCal(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;	
		StringBuffer sql = new StringBuffer();			
		ServletContext context = getServletContext();
		//HttpSession session = request.getSession(false);
		//*********CurrentDate Time
   	 	Calendar rightNow = Calendar.getInstance();
   	 	String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
   	 	String cur_year1 = Integer.toString((rightNow.get(Calendar.YEAR)+543)-1);
   	 	String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
		//String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";		
        try{      	
        	// System.out.println("xxxxxxxxxxxxxxx ->Starting.");
        	
        	//printOutParam(request);
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);	
			/****************************projectDLL****************************************/
			List  projectDDL = new ArrayList();
       	 	List  strList = null;	      	
        	
			/****************************projectDLL****************************************/
       	 	String projectDDLsel = request.getParameter("projectDDL")==null?"":request.getParameter("projectDDL").toString();
       	 	//projectDDLsel = LH:075
       	 	String comId = "";
       	 	String projId = "";
    		if(!"".equals(projectDDLsel) && projectDDLsel.length()>=5){
    			String arrStr[] = projectDDLsel.split("\\:");
    			comId = arrStr[0];
    			projId = arrStr[1];
			}
			
       	 	
       	 	//int year = Calendar.getInstance().get(Calendar.YEAR);
			// if (year<2400) year += 543;
			//int pYear = year-1;

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
					.append(" AND bud.d_year in('"+cur_year1+"','"+cur_year+"')   ")
					//.append(cur_year)
					.append(" ORDER BY proj.i_company, proj.i_project ");
			} else {
				sql.append(" SELECT b.i_company, b.i_project, b.n_project ")
					.append(" FROM lan:serv_pstaff a, lan:acxprojt b ")
					.append(" WHERE a.user_id = '")
					.append(user.getUserID())
					.append("' AND a.com_id = b.i_company AND a.proj_id = b.i_project ")
					.append(" ORDER BY b.i_company, b.i_project ");
			}
			
			//System.out.println("xxxxxxxxx SQL  :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString()); 
			rs = pstmt.executeQuery();				
			while(rs.next()){
					strList =  new ArrayList(); 
					strList.add(0,  doString.checkString(rs.getString("i_company"),""));
					strList.add(1,  doString.checkString(rs.getString("i_project"),""));
					strList.add(2,  doString.checkString(rs.getString("n_project"),""));
					projectDDL.add(strList);
				}
			rs.close();				
			//***************************************************************************/	
			String ReadOnlyUrl = "";

		  	/******************************************************/	       	
			sql.delete(0,sql.length());
			sql.append(" Select i_company, i_project, i_prjcal_id, i_gmail, i_password From lan:SVC_STDPJ ")
			   .append(" Where i_company = ? and i_project = ?  ");
			//System.out.println("xxxxxxxxxxxxx  SQL Get calendar :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString());
			pstmt.setString(1, comId);
			pstmt.setString(2, projId);
			rs = pstmt.executeQuery();	
			if(rs.next()){				
				//ReadOnlyUrl = "https://www.google.com/calendar/embed?height=260&amp;wkst=1&amp;bgcolor=%23ffffff&amp;src="
				//	+doString.checkString(rs.getString("i_prjcal_id"),"")+"&amp;color=%232F6309&amp;ctz=Asia%2FBangkok";
				ReadOnlyUrl = "https://calendar.google.com/calendar/u/0/embed?src="
					+doString.checkString(rs.getString("i_prjcal_id"),"")+"&ctz=Asia/Bangkok";
				
			}
			rs.close();				
			//********************************************************/

			 /**********************************/
			 request.setAttribute("projectList", projectDDL); 
			 request.setAttribute("ReadOnlyUrl",ReadOnlyUrl);
			 request.setAttribute("selProj",projectDDLsel);
		  	  	
	   		 String tarGetUrl ="/SVC_GCalendarViewer.jsp";
	   		 System.out.println("tarGetUrl = "+tarGetUrl);	
	   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			 dispatcher.forward(request,response);			
		}catch(Exception e){
			/*System.out.println("searchCal , " +sysName+":"+ cName + " : " + e.getMessage());
				
			//Dispat to Error message page
			// String ERROR_PAGE = "/MsgSuccessPage.jsp?msg="+e.getMessage()+"&error=1&url=/SALE_ContractFur.jsp";
			//String ERROR_PAGE = "/errorPage.jsp";
			//RequestDispatcher dispatcher = context.getRequestDispatcher(ERROR_PAGE);
			//dispatcher.forward(request,response);
			
			msgTxt = "!!! searchCal, " +sysName+":"+ cName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
			*/
			System.out.println("!!! searchCal , " +sysName+":"+ cName + " : " + e.getMessage());	
			System.out.println("!!! SQL Exception: "+sql.toString());	
			msgTxt = "searchCal , " +sysName+":"+ cName + " : " + e.getMessage();
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
	
	private static void printOutParam(HttpServletRequest request){
		String paramNames = "";
		System.out.println("---------[ Parameter List] ------------");
			for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
			paramNames = (String)e.nextElement();
			System.out.println(paramNames+" = "+request.getParameter(paramNames));
			}		
			System.out.println("---------- [END Parameter List] --------------");
	} 	    
}