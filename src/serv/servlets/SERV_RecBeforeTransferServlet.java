package serv.servlets;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
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

/**
 * Servlet implementation class for Servlet: SERV_RecBeforeTransferServlet
 * create by : pradoem wonkraso ,go2doem@gmail.com, pradoem@lh.co.th
 * date time: 2014.10.15
 * version : 1.0
 * project : Report form  bann transfer check form  QC
 * comment:  this class controller servlet for List Report baan transfer
 * check list by user 
 */

 public class SERV_RecBeforeTransferServlet extends  DBServlet{
	    /* (non-Java-doc)
		 * @see javax.servlet.http.HttpServlet#HttpServlet()
		 */
		String sysName = "LHServ";
		String clazzName = new String(this.getClass().getName() + ".performTask :");	 
		public SERV_RecBeforeTransferServlet() {
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
			 //out = response.getWriter();
			try{
				  String  command = request.getParameter("cmd")==null?"":request.getParameter("cmd");					
				  if(command.equals("load")){		
					 this.doFormLoad(request,response,user);				
				  }else if(command.equals("frmSearch")){
					  this.doFormSearch(request,response,user);
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
		protected void doFormSearch(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
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
	        	//System.out.println("doFormSearch ->Starting.");
	        	//printOutParam(request,"doFormSearch");
	 			//----------Open connection
				//Open connection
				if (ds == null){getDS();}			
				conn = ds.getConnection();
				conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	  			//conn.setAutoCommit(false);
	            //-------------------------
	  			String projectDDL = doString.checkString(request.getParameter("projectDDL"),"");
	  			String rbtType = doString.checkString(request.getParameter("rbtType"),""); 
	  			String fdateTxt = doString.checkString(request.getParameter("fdateTxt"),""); //02/09/2557
	  			String tdateTxt = doString.checkString(request.getParameter("tdateTxt"),""); //12/09/2557
	  			String lockTxt = doString.checkString(request.getParameter("lockTxt"),""); //12/09/2557
	  			
	  			String tempId[] = null;

	  			//System.out.println("doFormSearch ->Starting.");
	  		   if("".equals(projectDDL)||projectDDL.length()<=0){
	  			  System.out.println("!!! doFormSearch , " +sysName+":"+ clazzName + " : project is null. ");
	 			  //GenRedirectForm(out,okPage,targetPage,errorCode,"กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ ,!!!ยังไม่ระบุรหัสโครงการ.");
	            }
	  			
	  			if(!"".equals(lockTxt)){
	  				lockTxt = lockTxt.toUpperCase();
	  			}

	  			ArrayList projectList = this.ListProjectResposible(conn, user.getUserID());	  			
	  			if(!"".equals(projectDDL)&&projectDDL.length()>0){
	  				tempId = projectDDL.split("\\:");
	  			}	
				 //int x = 10/0;
		  		/**********************************/
	  				
		  		//---------------------------------------------------------------------//
				int displayLine = Integer.parseInt(doString.checkString(request.getParameter("pageNoDDL"),"10"));				
				//***************Get Row from db
		        int maxRow = this.IntCountRowByACSContr$IPV_QCHD(conn, tempId[0], tempId[1], lockTxt, rbtType, dateThai2UsYYYYMMDD(fdateTxt), dateThai2UsYYYYMMDD(tdateTxt));
		        //---------------- Generate Display Customize and Page Link -------------------------//
		        int nowPage = Integer.parseInt(doString.checkString(request.getParameter("nowPage"),"1"));
		        int startRow = ((nowPage-1)*displayLine);
		        int endRow = startRow+displayLine;       	   
		        String pageLink = "";
		        int tmpMax = maxRow;
		        pageLink = genLinkNextPageHTML(tmpMax, nowPage, displayLine);
		
				ArrayList pageNoDDL = new ArrayList();
				int intVal = 10;
				for(int i=0;i<5;i++){
					pageNoDDL.add(0,intVal); 
					intVal +=10;
				}
		        //------------------------------------------------------------------//s		
				/***********************
				 * Search HD
				 **********************/
				ArrayList listIpvQCHD = this.ListSearchByACSContr$IPV_QCHD(conn,  tempId[0], tempId[1], lockTxt, rbtType, dateThai2UsYYYYMMDD(fdateTxt), dateThai2UsYYYYMMDD(tdateTxt), startRow, endRow, maxRow);


				//*******************************************************************/
				request.setAttribute("listIpvQCHD", listIpvQCHD);
				request.setAttribute("projectList",projectList);
				request.setAttribute("projectSel",projectDDL);//LH:075
				request.setAttribute("rbtType", rbtType);//0,1
				
				request.setAttribute("fdateTxt", fdateTxt);
				request.setAttribute("tdateTxt", tdateTxt);
				request.setAttribute("lockTxt", lockTxt);	
				
				/**********************************/
				request.setAttribute("displayLinkPage", pageLink); 
				request.setAttribute("pageNoDDL",pageNoDDL);
				request.setAttribute("displayLine", displayLine);
				request.setAttribute("recordNo", startRow);
				/************************************/
		   		//*********Dispatcher  	 
			  	//System.out.println("doFormSearch ->successfully.");	  	
			  	 
			  	String tarGetUrl ="/SERV_RepBeforTrans.jsp";
		   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
				dispatcher.forward(request,response);	
				 
				/****** Clear *******/
				conn.close();
				conn = null;
			}catch(Exception e){
				System.out.println("!!! doFormSearch , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
			    //int x = 10/0;
	  			/**********************************/
				ArrayList pageNoDDL = new ArrayList();
				int intVal = 10;
				for(int i=0;i<5;i++){
					 pageNoDDL.add(0,intVal); 
					 intVal +=10;
				}
	           //------------------------------------------------------------------//
				//***************************************************************************/		
				request.setAttribute("projectList",projectList);
				request.setAttribute("pageNoDDL",pageNoDDL);
		   		//*********Dispatcher  	 
			  	//System.out.println("doFormLoad ->successfully.");	  	
			  	 
		   		String tarGetUrl ="/SERV_RepBeforTrans.jsp";
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

		public ArrayList<List> ListProjectResposible(Connection conn, String userId) {
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
	    			.append(" Order By value ");	
	    			pstmt = conn.prepareStatement(sql.toString()); 
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

		public int IntCountRowByACSContr$IPV_QCHD(Connection conn, String comId, String projId, String lock,String rbtType,String fromDate,String toDate) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			int totalRow=0; 
	        try{
	        	//initial paramter	
				/******************************************************/
	        	if(rbtType.equals("0")){//Left Join
		            sql.delete(0,sql.length());
		    		sql.append(" Select  count(a.d_close_law) as totalRow  ")
		    			.append(" FROM lan:acscontr a LEFT JOIN lan:ipv_qchd b ON ")
		    			.append(" ( a.i_company 	= b.i_company  ")
		    			.append("  and a.i_project = b.i_project   ")
		    			.append("  and a.i_sort = b.i_lock  ) ")
		    			.append("  Where ")
		    			.append("  a.i_company = ? and a.i_project = ?  ")
		    			.append("  and  a.f_contr is null ")
		    			.append("  and  i_sort = ? ");
		    		//System.out.println("SQL Query CASE 1 : "+sql.toString());
		    		pstmt = conn.prepareStatement(sql.toString()); 
		    		pstmt.setString(1,comId);
		    		pstmt.setString(2,projId);
		    		pstmt.setString(3,lock);
	    		}else if(rbtType.equals("1")){//not exists
		            sql.delete(0,sql.length());
		    		sql.append(" Select  count(a.i_sort) as totalRow  ")
		    			.append(" FROM lan:acscontr a  ")
		    			.append(" Where a.i_company = ? ")
		    			.append("  and  a.i_project = ?  ")
		    			.append("  and  a.f_contr is null ")
		    			.append("  and a.d_close_law between  '").append(fromDate).append("'").append(" and '").append(toDate).append("'")
		    			.append(" and Not Exists(   ")
		    			.append(" 	Select b.i_lock From  lan:ipv_qchd b ")
		    			.append(" 	Where a.i_company = b.i_company  ")
		    			.append("  	and a.i_project = b.i_project ")
		    			.append("  	and a.i_sort = b.i_lock ) ");
		    		//System.out.println("SQL Query CASE 2: "+sql.toString());
		    		pstmt = conn.prepareStatement(sql.toString()); 
		    		pstmt.setString(1,comId);
		    		pstmt.setString(2,projId);	    		
	    		}else if(rbtType.equals("2")){//Left Join
		            sql.delete(0,sql.length());
		    		sql.append(" Select  count(a.d_close_law) as totalRow  ")
		    			.append(" FROM lan:acscontr a LEFT JOIN lan:ipv_qchd b ON ")
		    			.append(" ( a.i_company 	= b.i_company  ")
		    			.append("  and a.i_project = b.i_project   ")
		    			.append("  and a.i_sort = b.i_lock  ) ")
		    			.append("  Where ")
		    			.append("  a.i_company = ? and a.i_project = ?  ")
		    			.append("  and  a.f_contr is null ")
		    			.append("  and a.d_close_law between  '").append(fromDate).append("'").append(" and '").append(toDate).append("'");
		    		//System.out.println("SQL Query CASE 3 : "+sql.toString());
		    		pstmt = conn.prepareStatement(sql.toString()); 
		    		pstmt.setString(1,comId);
		    		pstmt.setString(2,projId);
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
		
		public ArrayList<List> ListSearchByACSContr$IPV_QCHD(Connection conn,String comId, String projId, String lock,String rbtType,String fromDate,String toDate,int startRow,int endRow,int maxRow) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	        try{
	        	//initial paramter		
	        	//int line = 0;
	        	//System.out.println("##ListSearchByACSContr$IPV_QCHD->Starting.");   
	        	ArrayList<List>  resultList = new ArrayList<List> ();
	        	List strArr = null;    	 
	          	if(rbtType.equals("0")){//Left Join
		            sql.delete(0,sql.length());
	    			sql.append(" Select  first ").append(endRow).append("  a.i_company,a.i_project,a.i_sort,a.d_close_law as DCLOSE,b.i_docno,b.i_vendor,b.i_ipv_docno,b.i_type,b.f_status,b.c_desc,date(b.d_keyin) as DKEYIN ")
		    			.append(" FROM lan:acscontr a LEFT JOIN lan:ipv_qchd b ON ")
		    			.append(" ( a.i_company 	= b.i_company  ")
		    			.append("  and a.i_project  = b.i_project   ")
		    			.append("  and a.i_sort = b.i_lock  ) ")
		    			.append("  Where ")
		    			.append("  a.i_company = ? and a.i_project = ?  ")
		    			.append("  and  a.f_contr is null ")
		    			.append("  and  i_sort = ? ");
		    		//System.out.println("SQL Query CASE 0 : "+sql.toString());
		    		pstmt = conn.prepareStatement(sql.toString()); 
		    		pstmt.setString(1,comId);
		    		pstmt.setString(2,projId);
		    		pstmt.setString(3,lock);
	    		}else if(rbtType.equals("1")){//Not exists  Not Keyin
		            sql.delete(0,sql.length());
	    			sql.append(" Select  first ").append(endRow).append("  a.i_company,a.i_project,a.i_sort,a.d_close_law as DCLOSE,'' as i_docno,'' as i_vendor,'' as i_ipv_docno,'' as i_type,'' as f_status,'' as c_desc,'' as DKEYIN")
		    			.append(" FROM lan:acscontr a  ")
		    			.append(" Where a.i_company = ? ")
		    			.append("  and  a.i_project = ?  ")
		    			.append("  and  a.f_contr is null ")
		    			.append("  and a.d_close_law between  '").append(fromDate).append("'").append(" and '").append(toDate).append("'")
		    			.append(" and Not Exists(   ")
		    			.append(" 	Select b.i_lock From  lan:ipv_qchd b ")
		    			.append(" 	Where a.i_company = b.i_company  ")
		    			.append("  	and a.i_project = b.i_project ")
		    			.append("  	and a.i_sort = b.i_lock ) ");
		    		//System.out.println("SQL Query CASE 1: "+sql.toString());
		    		pstmt = conn.prepareStatement(sql.toString()); 
		    		pstmt.setString(1,comId);
		    		pstmt.setString(2,projId);	    		
	    		}else if(rbtType.equals("2")){//Left Join
		            sql.delete(0,sql.length());
	    			sql.append(" Select  first ").append(endRow).append("  a.i_company,a.i_project,a.i_sort,a.d_close_law as DCLOSE,b.i_docno,b.i_vendor,b.i_ipv_docno,b.i_type,b.f_status,b.c_desc,date(b.d_keyin) as DKEYIN ")
		    			.append(" FROM lan:acscontr a LEFT JOIN lan:ipv_qchd b ON ")
		    			.append(" ( a.i_company 	= b.i_company  ")
		    			.append("  and a.i_project = b.i_project   ")
		    			.append("  and a.i_sort = b.i_lock  ) ")
		    			.append("  Where ")
		    			.append("  a.i_company = ? and a.i_project = ?  ")
		    			.append("  and  a.f_contr is null ")
		    			.append("  and a.d_close_law between  '").append(fromDate).append("'").append(" and '").append(toDate).append("'");
		    		//System.out.println("SQL Query CASE 2 : "+sql.toString());
		    		pstmt = conn.prepareStatement(sql.toString()); 
		    		pstmt.setString(1,comId);
		    		pstmt.setString(2,projId);
	    		}	        		

				rs = pstmt.executeQuery();
				for (int i=0;i<maxRow;i++) { 
		                if (rs.next()) {
		                   if (i>=startRow && i<=endRow) {	
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
			   				    strArr.add(10,toDDMMYY_THAI2(doString.checkString(rs.getString("DKEYIN"),"")));//D_Keyin 2014-09-11
			   				    
			   				    strArr.add(11,GetProjectName(conn, doString.checkString(rs.getString("i_company"),""),doString.checkString(rs.getString("i_project"),"")));//N_project

			   					if(isValueStrAndObj(rs.getString("i_vendor"))){
			   						strArr.add(12,GetVendorName(conn, doString.checkString(rs.getString("i_vendor"),"&nbsp;")));
			   					}else{
			   						strArr.add(12,"");
			   					}
			   					resultList.add(strArr);	
				       		  //line++;                         
		                   } //--end if check row
			               if (i>endRow){ 
			              	 break;
			               }
		                } //end if check rs
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
		
		public String GetVendorName(Connection conn, String vendorId) {
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
		//false = object is null / str is ""
		//true = object have value / string hava value 
		public static boolean isValueStrAndObj(String str) throws Exception{
			if ((str == null) || str.equals("")) {
				 return false;
			}else{
				 return true;
			 }
		}
		//20/05/2557
		public static  String toDDMMYY_THAI2(String str){
			 if ((str == null) || str.equals("")) {
				 return  str;
			 }else{
				 String d2[] = str.split("\\-"); //2013-03-29
				 return d2[2]+"/"+d2[1]+"/"+(Integer.parseInt(d2[0])+543);
			 }
		}
		//input : 29/01/2557
		//output: 2014-01-29
		public static  String dateThai2UsYYYYMMDD(String str){
			 if ((str == null) || str.equals("")) {
				 return  str;
			 }else{
				 String temp[] = str.split("\\/"); // 29/01/2557			 
				 return (Integer.parseInt(temp[2])-543)+"-"+temp[1]+"-"+temp[0];
			 }
		}
		
//		Method get Link next page url
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
		
		
}