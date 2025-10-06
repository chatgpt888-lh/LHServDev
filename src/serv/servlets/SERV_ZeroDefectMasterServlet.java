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
import com.lh.exception.InvalidParameterException;
import com.lh.servlet.DBServlet;
import com.lh.util.doString;
import serv.common.User;
/**
 * Servlet implementation class for Servlet: SERV_ZeroMasterDefectServlet
 * create by : pradoem wongkraso
 * date :2012.09.13
 * version : 1.0
 * description : this is class forQC Zero Defection 
 * user  service  (blackEnd)
 *  
 */
 public class SERV_ZeroDefectMasterServlet extends   DBServlet{
    /* (non-Java-doc)
	 * @see javax.servlet.http.HttpServlet#HttpServlet()
	 */
	String sysName = "LHServ";
	String cName = new String(this.getClass().getName() + ".performTask :");	
	public void performTask(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {	  
		System.out.println(cName + "start.");
		//response.setContentType("text/html; charset=TIS-620");
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
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;	
		ResultSet rs2 = null;
		StringBuffer sql = new StringBuffer();			
		ServletContext context = getServletContext();	
		//*********CurrentDate Time
   	 	Calendar rightNow = Calendar.getInstance();
   	 	String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);		
		try{
	        	//Open connection
				if (ds == null){getDS();}			
				conn = ds.getConnection();
				conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
				//conn.setAutoCommit(false);
				//conn.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED);					
				String  command = request.getParameter("cmd")==null?"":request.getParameter("cmd");
				  
				if(command.equals("formLoad")){		
						/********************************************************************/
						 List   strList = null;
						 List resultObj = new ArrayList();
						/********************************************************************/
						sql.delete(0,sql.length());
						sql.append(" select  DISTINCT a.i_employ,a.n_prename_th,a.n_nemploy_th  ,a.n_semploy_th ,c.user_id ")          
							.append(" from docflow:acemploy a,docflow:acempjob b ,docflow:useracl c ")
							.append(" where a.i_employ   = b.i_employ ")  
							.append(" and b.i_employ     = c.i_employ ")    
							.append(" and b.d_job in (select max(d_job)  from docflow:acempjob where  i_employ = a.i_employ) ") 
							.append(" and a.d_retry is null ") 
							.append(" and b.i_division = '03' ") 
							.append(" order by a.i_employ  ") ;			
						pstmt = conn.prepareStatement(sql.toString()); 
						rs = pstmt.executeQuery();
						//int i = 0;
						while(rs.next()){ 
							strList = new ArrayList();
							strList.add(0,doString.checkString(rs.getString("i_employ"),""));//i_employ
							strList.add(1,doString.checkString(rs.getString("n_prename_th"),""));//n_prename_th
							strList.add(2,doString.checkString(rs.getString("n_nemploy_th"),""));//n_nemploy_th
							strList.add(3,doString.checkString(rs.getString("n_semploy_th"),""));//n_semploy_th
							strList.add(4,doString.checkString(rs.getString("user_id"),""));//user_id
				
							resultObj.add(strList);				
						}			
						//**************************************************************************	
					  	 request.setAttribute("resultObj",resultObj);			 
					  	 //System.out.println("doFormLoad ->successfully.");	  	
				   		 String tarGetUrl ="/SERV_ZeroMasterListStaff.jsp";
				   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
						 dispatcher.forward(request,response);
					  	 //response.sendRedirect(tarGetUrl);
			  }else if(command.equals("list")){
				  /********************************************************************/
					 List   strList = null;
					 List resultObj = new ArrayList();
					 List projectDDL = new ArrayList();
					 String userId = request.getParameter("userId")==null?"":request.getParameter("userId");//watana
					 String prefix = request.getParameter("prefix")==null?"":request.getParameter("prefix");//prefix
					 String fname = request.getParameter("fname")==null?"":request.getParameter("fname");//fname
					 String lname = request.getParameter("lname")==null?"":request.getParameter("lname");//lname					 
					/********************************************************************/		
					//Find all list project to DDL
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
					//***************************************************************************/							
					sql.delete(0,sql.length());
					sql.append(" select user_id,i_company,i_project  from lan: serv_staffqc  ")          
						.append(" where user_id = ?  order by i_company,i_project ") ;			
					pstmt = conn.prepareStatement(sql.toString()); 
					pstmt.setString(1,userId);
					rs = pstmt.executeQuery();
					//System.out.println("-->SQL#1:"+sql.toString());
					//int i = 0;
					while(rs.next()){
						strList = new ArrayList();
						strList.add(0,doString.checkString(rs.getString("user_id"),""));//user_id
						strList.add(1,doString.checkString(rs.getString("i_company"),""));//i_company
						strList.add(2,doString.checkString(rs.getString("i_project"),""));//i_project							
						sql.delete(0,sql.length());
						sql.append(" select i_company,i_project,n_project  from lan:acxprojt ")          
							.append(" where i_company = ? and i_project = ? ") ;			
						pstmt = conn.prepareStatement(sql.toString()); 
						pstmt.setString(1,rs.getString("i_company"));
						pstmt.setString(2,rs.getString("i_project"));
						rs2 = pstmt.executeQuery();
						if(rs2.next()){
							strList.add(3,doString.checkString(rs2.getString("n_project"),""));//n_project	
						}else{
							strList.add(3,doString.checkString(rs2.getString("n_project"),""));//n_project	
						}
						resultObj.add(strList);				
					}			
					//**************************************************************************	
				  	 request.setAttribute("listObj",resultObj);
				  	 request.setAttribute("prefix",prefix);
				  	 request.setAttribute("fname",fname);
				  	 request.setAttribute("lname",lname);
				  	 request.setAttribute("userId",userId);
				  	 request.setAttribute("projDDL", projectDDL);
		 
				  	 //System.out.println("doFormList ->successfully.");	  	
			   		 String tarGetUrl ="/SERV_ZeroMasterFormStaff.jsp";
			   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
					 dispatcher.forward(request,response);			
			  } else if(command.equals("action")){
				  		out = response.getWriter();
						conn.setAutoCommit(false);
						conn.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED);	
					  	//mode=add
						//mode=delete
						String mode = request.getParameter("mode")==null?"":request.getParameter("mode").toString();
						String userId = request.getParameter("userId")==null?"":request.getParameter("userId").toString();	
						 String prefix = request.getParameter("prefix")==null?"":request.getParameter("prefix");//prefix
						 String fname = request.getParameter("fname")==null?"":request.getParameter("fname");//fname
						 String lname = request.getParameter("lname")==null?"":request.getParameter("lname");//lname					 

						if("add".equals(mode)){
							String projDDL = request.getParameter("projectDDL"); //format : AR:002
							 String delimiter = "\\:";//for ID  AR : 031
							 String [] tempId  = projDDL.split(delimiter);							 
							int rec = 0;
							sql.delete(0, sql.length());
							sql.append("SELECT count(*) as rec from lan:serv_staffqc  WHERE user_id = ? AND i_company = ? AND i_project = ? ");
							pstmt = conn.prepareStatement(sql.toString()); 
							pstmt.setString(1, userId);		
							pstmt.setString(2, tempId[0]);		
							pstmt.setString(3, tempId[1]);	
							//System.out.println("SQL:"+sql.toString());
							rs = pstmt.executeQuery();
							if(rs.next()){
								rec = rs.getInt("rec");
							}
							 //System.out.println("---->INSERT OK dddd");
							 //System.out.println("---->isDup:"+rec);
							if(rec==0){
								sql.delete(0, sql.length());
								sql.append(" INSERT INTO lan:serv_staffqc(user_id,i_company,i_project) values(?,?,?)");
								pstmt = conn.prepareStatement(sql.toString()); 
								pstmt.setString(1, userId);		
								pstmt.setString(2, tempId[0]);		
								pstmt.setString(3, tempId[1]);	
								//System.out.println("SQL:"+sql.toString());
								int countRow =  pstmt.executeUpdate(); 	
								//System.out.println("---->INSERT OK test..");
							}else{
								//retInt = -1;
								throw new InvalidParameterException("โครงการที่ต้องการเพิ่มซ้ำ ไม่สามารถเพิ่มโครงการได้.");
							}
							 //System.out.println("---->INSERT OK");
						}else if("delete".equals(mode)){
					      	 //2.Get parameter  AR:002|2555-06-28|12:00  or AR:002|2012-06-28|12:00
				        	 String []arrCheckList = request.getParameterValues("chkDel");     	 
				        	 if(arrCheckList!=null && arrCheckList.length>0){ 
				        		 /***************************/
				            	 sql.delete(0, sql.length());
				            	 sql.append(" delete from lan:serv_staffqc ")
				            	 	.append(" where user_id = ? and i_company = ? and i_project = ? ");	
				            	 String delimiter = "\\:";//for ID  AR : 031
				        		 //int recNo = 0;
				        		 int c = 1;
				        		 for(int loop =0;loop<arrCheckList.length;loop++){
				        			//System.out.println("-->Loop :"+loop);
				        			 c = 1;
				        			 /**************split*****************/
				        			 String [] tempArr  = arrCheckList[loop].split(delimiter);    			 	 
				        			 //System.out.println("-->"+tempArr[2]);      			 
					        		 pstmt = conn.prepareStatement(sql.toString()); 
					     			 pstmt.setString(c++,tempArr[0]);//userid	
					     			 pstmt.setString(c++,tempArr[1]);//icom		     			 
					     			 pstmt.setString(c++,tempArr[2]);//iproject	     			 
					     			 //System.out.println("SQL  :"+sql.toString());
					     			 int countRow =  pstmt.executeUpdate(); 	 
					     			 //System.out.println("--->>Delete :"+countRow);
				        		 }//End FOR		
				        	 }//End check Null arrChecklist    	     	 
						}
						//*************************
			   		    conn.commit();
			   		    conn.setAutoCommit(true);
						//**************************************************************************	
			   		 //SERV_ZeroDefectMasterServlet?cmd=formLoad
			   		    String param = "cmd=list&userId="+userId+"&prefix="+prefix+"&fname="+fname+"&lname="+lname;
			   		  response.sendRedirect("SERV_ZeroDefectMasterServlet?"+param);
			        }	  
		}catch(Exception e){
			try{
				conn.rollback();
			}catch(Exception ex){}		
			if (e instanceof InvalidParameterException) {
				showError(out, e.getMessage());
			}else{
				//System.out.println("doFormLoad , " +sysName+":"+ cName + " : " + e.getMessage());
				System.out.println(" SQL Exception: "+sql.toString());		
				e.printStackTrace();
				System.out.println(sysName+":"+cName +" "+e.toString());		
			}			
		}finally{			
			try{
				if(rs!=null){rs.close();}
				if(rs2!=null){rs2.close();}
				if(pstmt!=null){pstmt.close();}
				if(conn!=null){conn.close();}
			}catch(Exception e){}
		}
	}
	
	 	  	    
}