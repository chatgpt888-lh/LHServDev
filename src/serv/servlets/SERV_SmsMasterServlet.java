package serv.servlets;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Calendar;
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
 * Servlet implementation class for Servlet: SERV_SmsMasterServlet
 * create by : pradoem wonkraso
 * date time: 2014.09.02
 * comment: this is clazz for manage Master Data Add,update,delete table
 * lan:serv_prjdt  for send SMS to service staff by auto run contap 
 * alarms loop run 30 minute 
 */
 public class SERV_SmsMasterServlet extends  DBServlet{
    /* (non-Java-doc)
	 * @see javax.servlet.http.HttpServlet#HttpServlet()
	 */
	String sysName = "LHServ";
	String cName = new String(this.getClass().getName() + ".performTask :");
	
	public SERV_SmsMasterServlet() {
		super();
	}  
	
	/*private void genRedirectCode(PrintWriter out,String page,String redirect,String error,String otherMsg) {
		out.println("<form method='post' action='"+page+"'>");		
		out.println("<input type='hidden' name='error' value='"+error+"'>");
		out.println("<input type='hidden' name='other_msg' value='"+doString.MS874ToUnicode(otherMsg)+"'>");
		out.println("<input type='hidden' name='redirect_url' value='"+doString.MS874ToUnicode(redirect)+"'>");		
		out.println("<script> document.forms[0].submit();</script>");
		out.println("</form>");		
	}*/
	
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
			  if(command.equals("search")){		
				 this.doFormSearch(request,response,user);				
			  }else if(command.equals("load")){
				  this.doFormLoadData(request,response,user);  
			  }else if(command.equals("update")){
				  this.doFormUpdate(request, response, user);
			  }else if(command.equals("add")){
				  this.doFormInsert(request, response, user);
			  }else if(command.equals("delete")){
				  this.doFormDelete(request, response, user);
			  }
		}catch(Exception e){
			e.printStackTrace();
			System.out.println(sysName+":"+cName +" "+e.toString());		
		}
	}
	 
	//*****	method FormLoad criteria projectDDL
	protected void doFormSearch(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;	
		StringBuffer sql = new StringBuffer();			

		ServletContext context = getServletContext();
		HttpSession session = request.getSession(false);
		
		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
        try{
        	 //System.out.println("formLoad ->Starting.");
        	 List projectDDL = new ArrayList();
        	 List strList = null;
        	 List arrResult = new ArrayList();
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			//conn.setAutoCommit(false);	
			
			String projectSel = doString.checkString(request.getParameter("projectDDL"), "");//LH:075
			//System.out.println("---Project Sel :projectDDL:"+projectSel);
			String tempProj[] = null;
			if(!"".equals(projectSel) || projectSel.length()>0 ){
				tempProj = projectSel.split("\\:");
			}
			/**************************
			 * TODO: Check Project Responsibility project by staff
			 * Check session is not null
			 *********************** */
		    Object obj = session.getAttribute("SS_PROJECT_DDL");
		    if (obj == null) {
		    	//System.out.println("!!!Session object Proejct Reposibility is null.");
		        /** Redirect user to login page if there's no session.*/
		    	projectDDL = this.doListProjectResponsibility(conn, user);
		    	session.setAttribute("SS_PROJECT_DDL", projectDDL);
		    }	

			//*******************************For Viewer************************************//
			sql.delete(0, sql.length());
			sql.append(" SELECT  a.i_company,a.i_project,a.i_tel,a.i_fax,a.n_service,b.n_project  ")
				.append(" FROM lan:serv_prjdt a,lan:acxprojt b ")
				.append(" Where a.i_company = b.i_company ")
				.append(" and a.i_project = b.i_project ");
			if(!"".equals(projectSel) || projectSel.length()>0 ){
				sql.append(" and a.i_company ='").append(tempProj[0]).append("'")
				   .append(" and a.i_project ='").append(tempProj[1]).append("'");
			}
			sql.append(" Order by a.i_company,a.i_project asc ");
			pstmt = conn.prepareStatement(sql.toString()); 
			rs = pstmt.executeQuery();
			while(rs.next()){
					strList =  new ArrayList(); 
					strList.add(0,  doString.checkString(rs.getString("i_company"),""));
					strList.add(1,  doString.checkString(rs.getString("i_project"),""));
					strList.add(2,  doString.checkString(rs.getString("i_tel"),""));
					strList.add(3,  doString.checkString(rs.getString("i_fax"),""));
					strList.add(4,  doString.checkString(rs.getString("n_service"),""));
					strList.add(5,  doString.checkString(rs.getString("n_project"),""));
					arrResult.add(strList);
				}
			rs.close();				
			//***************************************************************************/		
			request.setAttribute("projectSel",projectSel);//LH:075
			 request.setAttribute("arrResult",arrResult);
	   		 //*********Dispatcher  	 
		  	 //System.out.println("doFormSearch ->successfully.");	  	
	   		 String tarGetUrl ="/SERV_SmsMaster_List.jsp";
	   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			 dispatcher.forward(request,response);			
		}catch(Exception e){
			System.out.println("!!! doFormSearch , " +sysName+":"+ cName + " : " + e.getMessage());
			System.out.println("!!! SQL Exception: "+sql.toString());		
			msgTxt = "doFormSearch , " +sysName+":"+ cName + " : " + e.getMessage();
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

   //*****	method doFormDelete criteria projectDDL
	protected void doFormDelete(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;	
		StringBuffer sql = new StringBuffer();			

		ServletContext context = getServletContext();
		HttpSession session = request.getSession(false);
		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_SmsMasterServlet?cmd=search&error=true&other_msg=";	
		String SUCCESS_PAGE = request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_SmsMasterServlet?cmd=search&projectDDL=";
        try{
        	//System.out.println("doFormDelete ->Starting.");
        	// List projectDDL = new ArrayList();
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			//conn.setAutoCommit(false);	
			String companyId	=doString.checkString(request.getParameter("companyId"), ""); 
			String projectId	=doString.checkString(request.getParameter("projectId"), ""); 

			/**************************
			 * TODO: Retrive Data by comId,projectId
			 * Check session is not null
			 *********************** */
			int i = 1;
			//*******************************For Viewer************************************//
			sql.delete(0, sql.length());
			sql.append(" DELETE FROM lan:serv_prjdt  ")
				.append(" WHERE i_company = ? AND i_project = ? ");
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(i++,companyId);
			pstmt.setString(i++,projectId);
			int cntDel = pstmt.executeUpdate();
			
			//System.out.println("Delete ---->Succesfully. :"+cntDel);
			pstmt.close();
		    pstmt =null;
			conn.close();
			conn= null;
			//***************************************************************************/	
		    if(cntDel<=0){//false
				//msgTxt = "ไม่พบโครงการในระบบกรุณาทำรายการใหม่!!  "+comId+"-"+projectId;
				response.sendRedirect(ERROR_PAGE+msgTxt);
				System.out.println("!!!Error..");
				return;
			 }else{
				 //TODO: goto Edit Form
				 //System.out.println("Delete Successfully.. :"+SUCCESS_PAGE);
				 response.sendRedirect(SUCCESS_PAGE);
				 return;
			 }
		}catch(Exception e){
			System.out.println("!!! doFormUpdate , " +sysName+":"+ cName + " : " + e.getMessage());
			System.out.println("!!! SQL Exception: "+sql.toString());		
			msgTxt = "doFormUpdate , " +sysName+":"+ cName + " : " + e.getMessage();
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

	
 //	*****	method UpdateData criteria projectDDL
	protected void doFormInsert(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;	
		StringBuffer sql = new StringBuffer();			

		ServletContext context = getServletContext();
		HttpSession session = request.getSession(false);
		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_SmsMaster_Form.jsp&error=1&other_msg=";	
		String SUCCESS_PAGE = request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_SmsMasterServlet?cmd=search&projectDDL=";
        try{
        	//System.out.println("Insert ->Starting.");
        	// List projectDDL = new ArrayList();
        	boolean isDuplicate = false;
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			//conn.setAutoCommit(false);	
			String projectSel	=doString.checkString(request.getParameter("projectDDL"), "");//LH:075
			String mobileTxt	=doString.checkString(request.getParameter("mobileTxt"), ""); 
			String faxTxt	= doString.checkString(request.getParameter("faxTxt"), "");
			String serviceName	=doString.checkString(request.getParameter("serviceName"), ""); 

			String tempProj[] = null;
			if(!"".equals(projectSel) || projectSel.length()>0 ){
				tempProj = projectSel.split("\\:");
			}
			
			/**************************
			 * TODO: Check duplicate Data by LH-075
			 * Check session is not null
			 *********************** */
			sql.delete(0, sql.length());
			sql.append(" SELECT  a.i_tel  ")
				.append(" FROM lan:serv_prjdt a ")
				.append(" Where  a.i_company ='").append(tempProj[0]).append("'")
				.append(" and a.i_project ='").append(tempProj[1]).append("'");
			pstmt = conn.prepareStatement(sql.toString()); 
			rs = pstmt.executeQuery();
			if(rs.next()){
				mobileTxt= doString.checkString(rs.getString("i_tel"),"");
				isDuplicate = true;
			 }
			rs.close();
			if(isDuplicate){
				//TODO :Case Duplicate data LH-075
				msgTxt = "มีรหัสโครงการในระบบแล้ว กรุณาตรวจสอบ!!  "+tempProj[0]+"-"+tempProj[1];
				try{
					conn.close();
				}catch(Exception ex){}
				response.sendRedirect(ERROR_PAGE+doString.UnicodeToMS874(msgTxt));
				return;
			}else{
				//TODO: Insert Data 
				int i = 1;
				//*******************************For Viewer************************************//
				sql.delete(0, sql.length());
				sql.append(" INSERT INTO lan:serv_prjdt (i_company,i_project, i_tel,i_fax,n_service ) ") 
       	           .append(" VALUES (?,?,?,?,?)");  
				pstmt = conn.prepareStatement(sql.toString()); 
				pstmt.setString(i++, tempProj[0]);
				pstmt.setString(i++, tempProj[1]);
				pstmt.setString(i++, mobileTxt);
				pstmt.setString(i++, faxTxt);
				pstmt.setString(i++, serviceName);
				int Excuete = pstmt.executeUpdate();
				
				//System.out.println("Insert table TEST :"+Excuete);
				pstmt.close();
			    pstmt =null;
				conn.close();
				conn= null;
				//***************************************************************************/	
			    if(Excuete<=0){//false
					//msgTxt = "ไม่พบโครงการในระบบกรุณาทำรายการใหม่!!  "+comId+"-"+projectId;
					response.sendRedirect(ERROR_PAGE);
					System.out.println("!!!Error..");
					return;
				 }else{
					 //TODO: goto Edit Form
					 //System.out.println("Successfully.. :"+SUCCESS_PAGE);
					 response.sendRedirect(SUCCESS_PAGE+=projectSel);
					 return;
				 }
			}
		}catch(Exception e){
			System.out.println("!!! doFormInsert , " +sysName+":"+ cName + " : " + e.getMessage());
			System.out.println("!!! SQL Exception: "+sql.toString());		
			msgTxt = "doFormInsert , " +sysName+":"+ cName + " : " + e.getMessage();
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
	//*****	method UpdateData criteria projectDDL
	protected void doFormUpdate(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;	
		StringBuffer sql = new StringBuffer();			

		ServletContext context = getServletContext();
		HttpSession session = request.getSession(false);
		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_SmsMasterServlet?cmd=search&error=true&other_msg=";	
		String SUCCESS_PAGE = request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_SmsMasterServlet?cmd=search&projectDDL=";
        try{
        	//System.out.println("update ->Starting.");
        	// List projectDDL = new ArrayList();
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			//conn.setAutoCommit(false);	
			String projectSel	=doString.checkString(request.getParameter("projectDDL"), ""); 
			String mobileTxt	=doString.checkString(request.getParameter("mobileTxt"), ""); 
			String faxTxt	= doString.checkString(request.getParameter("faxTxt"), "");
			String serviceName	=doString.checkString(request.getParameter("serviceName"), ""); 

			String tempProj[] = null;
			if(!"".equals(projectSel) || projectSel.length()>0 ){
				tempProj = projectSel.split("\\:");
			}
			
			/**************************
			 * TODO: Retrive Data by comId,projectId
			 * Check session is not null
			 *********************** */
			int i = 1;
			//*******************************For Viewer************************************//
			sql.delete(0, sql.length());
			sql.append(" UPDATE lan:serv_prjdt  SET  i_tel = ?,i_fax = ? ,n_service = ? ")
				.append(" Where  i_company = ? ")
				.append(" and   i_project = ? ");
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(i++, mobileTxt);
			pstmt.setString(i++, faxTxt);
			pstmt.setString(i++, serviceName);
			pstmt.setString(i++, tempProj[0]);
			pstmt.setString(i++, tempProj[1]);
			int Excuete = pstmt.executeUpdate();
			
			//System.out.println("---->TEST :"+Excuete);
			pstmt.close();
		    pstmt =null;
			conn.close();
			conn= null;
			//***************************************************************************/	
		    if(Excuete<=0){//false
				//msgTxt = "ไม่พบโครงการในระบบกรุณาทำรายการใหม่!!  "+comId+"-"+projectId;
				response.sendRedirect(ERROR_PAGE+msgTxt);
				System.out.println("!!!Error..");
				return;
			 }else{
				 //TODO: goto Edit Form
				 //System.out.println("Successfully.. :"+SUCCESS_PAGE);
				 response.sendRedirect(SUCCESS_PAGE+=projectSel);
				 return;
			 }
		}catch(Exception e){
			System.out.println("!!! doFormUpdate , " +sysName+":"+ cName + " : " + e.getMessage());
			System.out.println("!!! SQL Exception: "+sql.toString());		
			msgTxt = "doFormUpdate , " +sysName+":"+ cName + " : " + e.getMessage();
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

    //*****	method FormLoad criteria projectDDL
	protected void doFormLoadData(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;	
		StringBuffer sql = new StringBuffer();			

		ServletContext context = getServletContext();
		HttpSession session = request.getSession(false);
		
		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_SmsMasterServlet?cmd=search&error=true&other_msg=";	
        try{
        	 //System.out.println("formLoad ->Starting.");
        	 List projectDDL = new ArrayList();
        	 //String projectSel	= "";//LH:075
        	 String mobileTxt	= "";
        	 String faxTxt	= "";
        	 String serviceName	= "";
        	 boolean isRecord = false;
        	 
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			//conn.setAutoCommit(false);	
			
			String comId = doString.checkString(request.getParameter("companyId"), "");//LH
			String projectId = doString.checkString(request.getParameter("projectId"), "");//075

			/**************************
			 * TODO: Check Project Responsibility project by staff
			 * Check session is not null
			 *********************** */
		    Object obj = session.getAttribute("SS_PROJECT_DDL");
		    if (obj == null) {
		    	//System.out.println("!!!Session object Proejct Reposibility is null.");
		        /** Redirect user to login page if there's no session.*/
		    	projectDDL = this.doListProjectResponsibility(conn, user);
		    	session.setAttribute("SS_PROJECT_DDL", projectDDL);
		    }	
		    
			/**************************
			 * TODO: Retrive Data by comId,projectId
			 * Check session is not null
			 *********************** */
			//*******************************For Viewer************************************//
			sql.delete(0, sql.length());
			sql.append(" SELECT  a.i_company,a.i_project,a.i_tel,a.i_fax,a.n_service  ")
				.append(" FROM lan:serv_prjdt a ")
				.append(" Where  a.i_company ='").append(comId).append("'")
				.append(" and a.i_project ='").append(projectId).append("'");

			pstmt = conn.prepareStatement(sql.toString()); 
			rs = pstmt.executeQuery();
			if(rs.next()){
				mobileTxt= doString.checkString(rs.getString("i_tel"),"");
				faxTxt = doString.checkString(rs.getString("i_fax"),"");
				serviceName = doString.checkString(rs.getString("n_service"),"");
				isRecord = true;
			 }
			 rs.close();				
			 //***************************************************************************/	
			 if(!isRecord){//false
				    //TODO: goto List page and alert Error message.
					msgTxt = "ไม่พบโครงการในระบบกรุณาทำรายการใหม่!!  "+comId+"-"+projectId;
					try{
						conn.close();
					}catch(Exception ex){}
					response.sendRedirect(ERROR_PAGE+doString.UnicodeToMS874(msgTxt));
					return;
			 }else{
				 //TODO: goto Edit Form
				 request.setAttribute("projectSel",comId+":"+projectId);
				 request.setAttribute("mobileTxt",mobileTxt);
				 request.setAttribute("faxTxt",faxTxt);
				 request.setAttribute("serviceName",serviceName);
		   		 //*********Dispatcher  	 
			  	 //System.out.println("doFormLoadData ->successfully.");	  	
		   		 String tarGetUrl ="/SERV_SmsMaster_EditForm.jsp";
		   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
				 dispatcher.forward(request,response);	
			 }
			 rs = null;
			 pstmt.close();
			 pstmt =null;
			 conn.close();
			 conn= null;
		}catch(Exception e){
			System.out.println("!!! doFormLoadData , " +sysName+":"+ cName + " : " + e.getMessage());
			System.out.println("!!! SQL Exception: "+sql.toString());		
			msgTxt = "doFormLoadData , " +sysName+":"+ cName + " : " + e.getMessage();
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
	
	
	protected List doListProjectResponsibility(Connection conn,User user) throws ServletException, IOException {
		// TODO Auto-generated method stub
		PreparedStatement pstmt = null;
		ResultSet rs = null;	
		StringBuffer sql = new StringBuffer();			
		ServletContext context = getServletContext();
		//*********CurrentDate Time
   	 	Calendar rightNow = Calendar.getInstance();
   	 	String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
        try{
        	 List projectDDL = new ArrayList();
        	 List   strList = null;
			//Open connection
			/****************************projectDLL****************************************/
			sql.delete(0, sql.length());
			sql.append("SELECT user_id,com_id,proj_id  FROM lan:serv_pstaff WHERE user_id = ? AND com_id = 'LH' AND proj_id = 'ALL' ");
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, user.getUserID());			
			rs = pstmt.executeQuery();	
			//*******************************For Viewer************************************//
			sql.delete(0, sql.length());
			if (rs.next()) {
				sql.delete(0, sql.length());
				sql.append(" SELECT DISTINCT a.i_company, a.i_project, a.n_project")
					.append(" FROM lan:acxprojt a, lan:acsbudgh b")
					.append(" WHERE b.i_company = a.i_company AND b.i_project = a.i_project")
					.append(" AND b.d_year = '")
					.append(cur_year)
					.append("' ORDER BY a.i_company, a.i_project ");
			} else {
				sql.delete(0, sql.length());
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
					//doString.checkString(doString.DisplayThai(rs.getString("n_customer")),"");
				}
			rs.close();				
			//***************************************************************************/			
			rs = null;
			pstmt.close();
		    pstmt = null;
		    
			return projectDDL;
		}catch(Exception e){
			System.out.println("!!!doListProjectResponsibility , " +sysName+":"+ cName + " : " + e.getMessage());
			System.out.println("!!!SQL Exception: "+sql.toString());	
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
}