package serv.servlets;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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
 * Servlet implementation class for Servlet: ESERV_GenPwdOldCustServlet
 *
 */

/**
 * Servlet implementation class for Servlet: ESERV_GenPwdOldCustServlet
 * create by : pradoem wongkraso
 * date :2013.07.01
 * version : 2.0
 * description : this is class for generate password customers
 * user  service  (backEnd)
 * 
 */

 public class ESERV_GenPwdOldCustServlet extends  DBServlet{
	    /* (non-Java-doc) @see javax.servlet.http.HttpServlet#HttpServlet() */
		public ESERV_GenPwdOldCustServlet() {
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
			 * medthod action
			 **************** */
			try{
				  String  command = request.getParameter("cmd")==null?"":request.getParameter("cmd");					
				  if(command.equals("formLoad")){		
					  this.doFormLoad(request,response,user);				
				  }else if(command.equals("gen")){
					  this.doGenerateAction(request,response,user);  
				  } 
			}catch(Exception e){
				e.printStackTrace();
				System.out.println(sysName+":"+cName +" "+e.toString());		
			}
		}
		
		//*****	method FormLoad criteria projectDDL
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
	        try{	        	
	        	 //System.out.println("formLoad ->Starting.");
	        	 List projectDDL = new ArrayList();
	        	 List   strList = null;
				//Open connection
				if (ds == null){getDS();}			
				conn = ds.getConnection();
				conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
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
						strList.add(0,  doString.checkString(rs.getString("i_company"),"")+"-"+doString.checkString(rs.getString("i_project"),""));
						strList.add(1,  doString.checkString(rs.getString("n_project"),""));
						projectDDL.add(strList);
						//doString.checkString(doString.DisplayThai(rs.getString("n_customer")),"");
					}
				rs.close();				
				//***************************************************************************/							
			  	 request.setAttribute("projDDL", projectDDL);
			  	 request.setAttribute("selProj", null);		 
			  	 //System.out.println("test er_code :"+request.getParameter("er_code"));
			  	 request.setAttribute("er_code", request.getParameter("er_code"));
			  	 //System.out.println("formLoad ->successfully.");	  	
		   		 String tarGetUrl ="/ESERV_GenPwdOldCustForm.jsp";
		   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
				 dispatcher.forward(request,response);			
			}catch(Exception e){
				System.out.println("!!doFormLoad , " +sysName+":"+ cName + " : " + e.getMessage());
				System.out.println("!!SQL Exception: "+sql.toString());		
				
				//String ERROR_PAGE = "/errorPage.jsp";
				//RequestDispatcher dispatcher = context.getRequestDispatcher(ERROR_PAGE);
				//dispatcher.forward(request,response);
				
				String forward =  request.getContextPath()+"/save_ok.jsp?other_msg=&error=1&SERV_Index.jsp?";			
				response.sendRedirect(forward);
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
		
//		***doGenerateAction krub.
		protected void doGenerateAction(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
			// TODO Auto-generated method stub
			response.setContentType("text/html; charset=TIS-620");
			Connection conn = null;
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			StringBuffer sql = new StringBuffer();	
			ServletContext context = getServletContext();
			//HttpSession session = request.getSession(false);
			//*********CurrentDate Time			
			//GetParamRQ(request);		
	        try{ 
	        	String projDDL = doString.checkString(request.getParameter("projDDL"),""); 
       	
	        	String fday = request.getParameter("dayDDL1");
	        	String fmm = request.getParameter("mmDDL1");
	        	String fyy = request.getParameter("yyDDL1")==null?"0":request.getParameter("yyDDL1");
	        	String tday = request.getParameter("dayDDL2");
	        	String tmm = request.getParameter("mmDDL2");
	        	String tyy = request.getParameter("yyDDL2")==null?"0":request.getParameter("yyDDL2");     
	        	
	        	String fromDate = fyy+"-"+fmm+"-"+fday;
	        	String toDate =   tyy+"-"+tmm+"-"+tday;	        	
      	     	 	
	        	//Open connection
	 			if (ds == null){getDS();}			
	 			conn = ds.getConnection();
	 			conn.setAutoCommit(true);
				conn.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED);
				
				
				String []tempProject = projDDL.split("\\-");
	        	//select case SQL preparing statement below
    			sql.delete(0, sql.length());
    			sql.append(" select i_company,i_project,i_lor,i_sort,i_cus_intent1,i_exp_intent1,d_close_law ")
        			.append(" from lan:acscontr  ")
        			.append(" where f_contr  is null ")
        			.append(" and d_close_law between ? and ? ")
        			.append(" and i_company =? and i_project = ? ")
        			.append(" order by i_sort ");
        		//or i_company ='LH' and i_project = '234'
    			int i = 1;
    			pstmt = conn.prepareStatement(sql.toString()); 
				pstmt.setString(i++, fromDate);//fromDate	
				pstmt.setString(i++, toDate);//toDate	
				pstmt.setString(i++, tempProject[0]);//company_id
				pstmt.setString(i++, tempProject[1]);//project_id
				
				rs = pstmt.executeQuery();
	        	//**Excute Statment Insert data		        
	        	//------call method  ExcuteData();
	        	int intUpd =  doExecute(conn,rs);

	        	if(intUpd!=-1){
	        		// tarGetUrl="/save_ok.jsp?&error=0&redirect_url=ESERV_Redirect.html"; 
	        		String forward =  request.getContextPath()+"/save_ok.jsp?other_msg=&error=0&SERV_Index.jsp?";		
	        		response.sendRedirect(forward);
	        	}else{
	        		//System.out.println("-------intsert fails");	
					String forward =  request.getContextPath()+"/save_ok.jsp?other_msg=&error=99&SERV_Index.jsp?";			
					response.sendRedirect(forward);
	        	}	
	 			/********************************************************************/		
	 			//conn.commit();
	 			//conn.setAutoCommit(true);	 
	        	/********************************************************************/	
	        	//System.out.println("----->doGenerateAction succesfully.");
			}catch(Exception e){
				//try{
				//	conn.rollback();
				//}catch(Exception ex){}		
				System.out.println("!!doGenerateAction , " +sysName+":"+ cName + " : " + e.getMessage());
				System.out.println("!!SQL Exception: "+sql.toString());		

				String forward =  request.getContextPath()+"/save_ok.jsp?other_msg=&error=1&SERV_Index.jsp?";			
				response.sendRedirect(forward);
			}
			finally{//clean up.
				try{
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
					if(conn!=null){conn.close();}
				}catch(Exception e){}
			}
		} 
		

		//**********
		protected int doExecute(Connection conn,ResultSet rs) {	
			ResultSet rs1 = null;
			PreparedStatement pstmt = null;
			//ResultSet rs = null;
			StringBuffer sql = new StringBuffer();
			StringBuffer sqlInsCust = new StringBuffer();
			StringBuffer sqlInsLogin = new StringBuffer();
			StringBuffer sqlInsLock = new StringBuffer();
			//DecimalFormat df = new DecimalFormat("###.##");
			//**Main parameter
			StringBuffer iCompany = new StringBuffer();
			StringBuffer iProject = new StringBuffer();
			StringBuffer iLor = new StringBuffer();
			StringBuffer iSort = new StringBuffer();
			StringBuffer iTempCus1 = new StringBuffer();
			StringBuffer iTempCus2 = new StringBuffer();
			StringBuffer dCloseLaw = new StringBuffer();
			StringBuffer iCusto = new StringBuffer();
			//**sub param
			StringBuffer param1 = new StringBuffer();
			StringBuffer param2 = new StringBuffer();
			StringBuffer param3 = new StringBuffer();
			StringBuffer param4 = new StringBuffer();
			StringBuffer param5 = new StringBuffer();
			StringBuffer param6 = new StringBuffer();
			
			
			String tel1 = "";
			String tel2 = "";
			
			String  tblEserLogin = "lan:ESER_LOGIN";
			String  tblEserCust = "lan:ESER_CUST";
			String  tblEserLock = "lan:ESER_LOCK";
			
			
			//************************************************************************//
			String sumQ_area = "0";
			String Q_area = "0";
			String z_price = "";
			int iphase = 0;
			//System.out.println("--->doExcute starting.");
		
			int intRet = 0;	
			try{	

	 			//conn.setAutoCommit(false);
				//conn.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED);

				//***************************Prepared Insert into***********************************//
				//System.out.println("--->Prepared SQL insert into table ESER_CUST.");
				sqlInsCust.delete(0, sqlInsCust.length());
				sqlInsCust.append(" INSERT INTO "+tblEserCust+" (i_customer,n_customer, i_tel_home,i_tel_mobile ) ") 
            	     .append(" VALUES (?,?,?,?)");  
                        
	           //System.out.println("--->Prepared SQL insert into table ESER_LOGIN.");
	            sqlInsLogin.delete(0, sqlInsLogin.length());
	            sqlInsLogin.append(" INSERT INTO "+tblEserLogin+"(USER_ID,USER_WHO,USER_ACL,USER_CUST,USER_PASSWORD,F_PRINT,D_PRINT ) ") 
            	     .append(" VALUES (?,'E','U',?,?,'Y',TODAY)");  
	            
	           // System.out.println("--->Prepared SQL insert into table ESER_LOCK.");
	            sqlInsLock.delete(0, sqlInsLock.length());
				sqlInsLock.append(" INSERT INTO "+tblEserLock+"(I_CUSTOMER,I_COMPANY,I_PROJECT,I_LOR,I_LOCK,D_CLOSE_LAW,Q_AREA,Q_SQM,Z_INFRA,D_INFRA,I_MODEL,F_EXTRA,I_HOUSE ) ")  
	               .append(" VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)");  
	           
	            //***********************************************************************//
				//Check duplicate ESER_CUST
     			int chkDup = 0;
     			int i = 1;
     			String telHome = "";
     			boolean isInsert = false;
				while(rs.next()){
					 i = 1;
					 chkDup = 0;
					 isInsert = false;
					 tel1 = "";
					 tel1 = "";
					 
					//1.clean buffer String
					iCompany.delete(0, iCompany.length());
					iProject.delete(0, iProject.length());
					iLor.delete(0, iLor.length());
					iSort.delete(0, iSort.length());
					iTempCus1.delete(0, iTempCus1.length());
					iTempCus2.delete(0, iTempCus2.length());
					dCloseLaw.delete(0, dCloseLaw.length());
					iCusto.delete(0, iCusto.length());
					
					//2.**Fetch Data from rs
					iCompany.append(doString.checkString(rs.getString("i_company"),""));
					iProject.append(doString.checkString(rs.getString("i_project"),""));
					iLor.append(doString.checkString(rs.getString("i_lor"),""));
					iSort.append(doString.checkString(rs.getString("i_sort"),""));
					iTempCus1.append(doString.checkString(rs.getString("i_cus_intent1"),""));
					iTempCus2.append(doString.checkString(rs.getString("i_exp_intent1"),""));
					dCloseLaw.append(doString.checkString(rs.getString("d_close_law"),""));				
					//3.check icust
					if(iTempCus1.toString().equals("")){
						iCusto.append(iTempCus2);
					}else{
						iCusto.append(iTempCus1);
					}
					
					/***********************/
					/* insert into table ESER_LOGIN*/
					/*************************/
		            i = 1;
		            param1.delete(0, param1.length());
		            param1.append(iCompany.toString()+iProject.toString()+iSort.toString());//USER_ID
		            
		            param2.delete(0, param2.length());
		            param2.append(doGenRandomPassword());
		            
		            /************************************************/
		            //Username & password
		            //Check duplicate ESER_LOGIN
		            /************************************************/	
		            
	     			chkDup = 0;
					sql.delete(0, sql.length());
		            sql.append(" select count(*) as no  from "+tblEserLogin+"  where user_id = ? and user_cust= ? ") ;
		            pstmt = conn.prepareStatement(sql.toString()); 
					i = 1;
		     		pstmt.setString(i++, param1.toString().toLowerCase());//USER_ID
		     		pstmt.setString(i++, iCusto.toString());//user_cust
					rs1 = pstmt.executeQuery();
					if(rs1.next()){
						chkDup = rs1.getInt("no");
					}
					
					//chkDup == 0 : Not duplicate record
					//chkDup == 1 : Duplicate record
					if(chkDup == 1){
						isInsert = false;
						//System.out.println("------>Skip record.");
					}else{
						isInsert = true;
					}
					
					
					if(isInsert){
						//System.out.println("##--chkDup :"+chkDup);
						//System.out.println("##--User_id :"+param1.toString().toLowerCase());
						rs1= null;
						if(chkDup==0){
				     		pstmt = conn.prepareStatement(sqlInsLogin.toString());
							i=1;
				     		pstmt.setString(i++, param1.toString().toLowerCase());//USER_ID	
				     		pstmt.setString(i++, iCusto.toString());//USER_ICUST	
				     		pstmt.setString(i++, param2.toString());//USER_PASSWORD	
							pstmt.executeUpdate();
							//System.out.println("---> insert ESER_LOGIN2 OK.");	
						} 
	
						
						//4. Find customer name & Last name
						sql.delete(0, sql.length());
						sql.append(" select n_prename,n_ncustomer,n_scustomer,a_id_tel,a_wk_tel,a_etc_tel from lan:acxcusto where i_customer  =? ");
						pstmt = conn.prepareStatement(sql.toString()); 
						pstmt.setString(1, iCusto.toString());//i_customer	
						rs1 = pstmt.executeQuery();
						//System.out.println("--->sql4 :"+sql.toString());
	
						param1.delete(0, param1.length());
						param2.delete(0, param2.length());
						param3.delete(0, param3.length());
						param4.delete(0, param4.length());
						param5.delete(0, param5.length());
						param6.delete(0, param6.length());
						
						if(rs1.next()){
							param1.append(doString.checkString(rs1.getString("n_prename"),""));
							param2.append(doString.checkString(rs1.getString("n_ncustomer"),""));
							param3.append(doString.checkString(rs1.getString("n_scustomer"),""));
							tel1 = doString.checkString(rs1.getString("a_id_tel"),"");
							tel2 = doString.checkString(rs1.getString("a_wk_tel"),"");
							param6.append(doString.checkString(rs1.getString("a_etc_tel"),""));
						}
						rs1= null;
	
						/***********************/
						/*#5. insert into table ESER_CUST*/
						/*************************/						
						
						//System.out.println("---->iCusto:"+iCusto.toString());
						i = 1;
		     			//System.out.println("--->Check duplicate ESER_CUST");
						sql.delete(0, sql.length());
			            sql.append(" select count(*) as no  from "+tblEserCust+"  where i_customer  = ?  ") ;//int 67140 
			            pstmt = conn.prepareStatement(sql.toString()); 
						i = 1;
			     		pstmt.setInt(i++,Integer.parseInt(iCusto.toString()));//USER_ID
						rs1 = pstmt.executeQuery();
						if(rs1.next()){
							chkDup = rs1.getInt("no");
						}
						
	     				//System.out.println("---1 chkDup :"+chkDup);
						rs1= null;
						if(chkDup==0){	
							
							telHome = "";
							telHome = getMobileDisplay(tel1,tel2);
							//*******************case duplicate 	
							pstmt = conn.prepareStatement(sqlInsCust.toString());
							i = 1;
							pstmt.setString(i++,iCusto.toString());//i_customer	
							pstmt.setString(i++,param1.toString()+" "+param2.toString()+"   "+param3.toString());//n_customer	
							pstmt.setString(i++, telHome);//i_tel_home    
							pstmt.setString(i++, param6.toString());//i_tel_mobile  
							pstmt.executeUpdate();
							//System.out.println("+++> insert ESER_CUST2 OK.");	
						}
						
						//**********************************
						//PASSWORD
						//strArr.add(4,param2.toString());//USER_PASSWORD
						//*********************************
	     			             			    
	     			    //7.# Find SUM Q_AREA 
	     			    //System.out.println("--->Find SUM Q_AREA. ");   			   
						sql.delete(0, sql.length());
						sql.append(" select sum(q_area) as q_area ,min(i_phase) as i_phase from lan:acxslock where i_company = ? and i_project = ? and i_lor = ? ");
						pstmt = conn.prepareStatement(sql.toString()); 
						i = 1;
			     		pstmt.setString(i++, iCompany.toString());//i_company
			     		pstmt.setString(i++, iProject.toString());//i_project
			     		pstmt.setString(i++, iLor.toString());//i_lor
			     		//System.out.println("--->sql7 :"+sql.toString());
						rs1 = pstmt.executeQuery();
						if(rs1.next()){
							//sumQ_area = rs1.getDouble("q_area");
							sumQ_area = doString.checkString(rs1.getString("q_area"),"0");
							iphase = rs1.getInt("i_phase");
						}
						rs1= null;
						
						//8.# Find model,i_house
	     			   //System.out.println("---> Find model,i_house ");   			   
						sql.delete(0, sql.length());
						sql.append(" select b.n_model,b.i_model,a.i_house from lan:acxlckmd a,acxmodel b ")
								.append(" where a.i_company = ? ")
								.append(" and a.i_project   = ? ")
								.append(" and a.i_lor       = ? ")
								.append(" and a.s_lock      = 1 ")
								.append(" and a.i_company = b.i_company ")       
								.append(" and a.i_project   =  b.i_project ")
								.append(" and a.i_model     = b.i_model ")
								.append(" and a.i_model_type  = b.i_model_type  ");
						
						pstmt = conn.prepareStatement(sql.toString()); 
						i = 1;
			     		pstmt.setString(i++, iCompany.toString());//i_company
			     		pstmt.setString(i++, iProject.toString());//i_project
			     		pstmt.setString(i++, iLor.toString());//i_lor
			     		//System.out.println("--->sql8 :"+sql.toString());
						rs1 = pstmt.executeQuery();
						param1.delete(0, param1.length());
						param2.delete(0, param2.length());
						param3.delete(0, param3.length());
						if(rs1.next()){
							param1.append(doString.checkString(rs1.getString("n_model"),""));
							param2.append(doString.checkString(rs1.getString("i_model"),""));
							param3.append(doString.checkString(rs1.getString("i_house"),""));					
						}
						rs1= null;
						/*********************************************/
						//i_house
						//strArr.add(5,param3.toString());//i_house
						/*********************************************/
						
						//9.# Find Q_AREA 
	     			    //System.out.println("--->Find Q_AREA. ");   			   
						sql.delete(0, sql.length());
						sql.append("select q_area from lan:acmcstmh where i_company = ? and i_project = ? and i_model = ? ");
						pstmt = conn.prepareStatement(sql.toString()); 
						i = 1;
			     		pstmt.setString(i++, iCompany.toString());//i_company
			     		pstmt.setString(i++, iProject.toString());//i_project
			     		pstmt.setString(i++, param2.toString());//i_model
			     		//System.out.println("--->sql9 :"+sql.toString());
						rs1 = pstmt.executeQuery();
						if(rs1.next()){
							//Q_area = rs1.getDouble("q_area");
							Q_area = doString.checkString(rs1.getString("q_area"),"0");
						}
						rs1= null;				
						//10.# Find The Accretion
	     			    //System.out.println("--->Find The Accretion. ");   			   
						sql.delete(0, sql.length());
						sql.append(" select  a.d_end_project,a.f_extra,b.z_price")
							.append(" from lan:acspubhd a,acspubdt b")
							.append(" where a.i_company = ? ")
							.append(" and a.i_project  = ? ")
							.append(" and a.i_phase    = ? ")
							.append(" and a.i_company  = b.i_company ")
							.append(" and a.i_project  = b.i_project ")
							.append(" and a.i_phase    = b.i_phase  ")
							.append(" and b.d_public  ")
							.append(" in (select max(c.d_public) from acspubdt c where c.i_company = b.i_company  and c.i_project =b.i_project and c.i_phase =b.i_phase )")
							.append(" order by 1 ");
						pstmt = conn.prepareStatement(sql.toString()); 
						i = 1;
			     		pstmt.setString(i++, iCompany.toString());//i_company
			     		pstmt.setString(i++, iProject.toString());//i_project
			     		pstmt.setInt(i++, iphase);//i_phase
			     		//System.out.println("--->sql10 :"+sql.toString());
						rs1 = pstmt.executeQuery();
						param4.delete(0,param4.length());
						param5.delete(0,param5.length());
						if(rs1.next()){
							param4.append(doString.checkString(rs1.getString("d_end_project"),""));	//d_end_project
							param5.append(doString.checkString(rs1.getString("f_extra"),""));//f_extra	
							z_price = doString.checkString(rs1.getString("z_price"),"0");	//z_price	
						}
						rs1= null;
						/***********************/
						/*#11. insert into table ESER_LOCK*/
						/*************************/

		     			chkDup = 0;
						sql.delete(0, sql.length());
			            sql.append(" select count(*) as no  from "+tblEserLock+"  where i_customer  = ? and i_company = ? and i_project = ? and i_lor = ? and i_lock = ? ") ;//int 67140 
			            pstmt = conn.prepareStatement(sql.toString()); 
						i = 1;
			     		pstmt.setInt(i++,Integer.parseInt(iCusto.toString()));//USER_ID
			     		pstmt.setString(i++,iCompany.toString());//I_COMPANY	
			     		pstmt.setString(i++,iProject.toString());//I_PROJECT
			     		pstmt.setInt(i++,Integer.parseInt(iLor.toString()));//I_LOR		
			     		pstmt.setString(i++,iSort.toString());//I_LOCK
						rs1 = pstmt.executeQuery();
						if(rs1.next()){
							chkDup = rs1.getInt("no");
						}
						rs1= null;
						if(chkDup==0){
						    //*******************case duplicate 
							i = 1;					
								pstmt = conn.prepareStatement(sqlInsLock.toString());
								pstmt.setInt(i++, Integer.parseInt(iCusto.toString()));//I_CUSTOMER	
								pstmt.setString(i++,iCompany.toString());//I_COMPANY	
								pstmt.setString(i++,iProject.toString());//I_PROJECT
								pstmt.setInt(i++,Integer.parseInt(iLor.toString()));//I_LOR		
								pstmt.setString(i++,iSort.toString());//I_LOCK	     			
						        if(dCloseLaw.toString().equals("")){
						        	pstmt.setString(i++,null);//D_CLOSE_LAW	
					     		}else{
					     			pstmt.setString(i++,dCloseLaw.toString());//D_CLOSE_LAW	
					     		}	     				
						        pstmt.setString(i++,sumQ_area);//Q_AREA		
						        pstmt.setString(i++,Q_area);//Q_SQM	
						        pstmt.setString(i++,z_price);//Z_INFRA	
						        pstmt.setString(i++,param4.toString());//D_INFRA
						        pstmt.setString(i++,param1.toString());//n_model,I_MODEL
						        pstmt.setString(i++,param5.toString());//F_EXTRA	
						        pstmt.setString(i++,param3.toString());//I_HOUSE	
						        pstmt.executeUpdate();
						       // System.out.println("--->insert EserLock2 OK..");
						}
					}
					//System.out.println("=====Loop :"+intRet);
					//intRet++;
				}//--------------------------------#End while looop	
	 			/********************************************************************/		
	 			//conn.commit();
	 			//conn.setAutoCommit(true);	 
	        	/********************************************************************/	
	 			
				//System.out.println("####################--->doExcute successfully. #################################");
				return intRet;
			}catch(Exception e){
				System.out.println("!!doExcute :"+e.toString());
				System.out.println("!!SQL :"+sql.toString());				
				return -1;
			}finally{//clean up.
				try{
					if(rs1!=null){rs1.close();}
					if(pstmt!=null){pstmt.close();}
					//if(conn!=null){conn.close();}
				}catch(Exception e){}
			}
		}
		
		private void GetParamRQ(HttpServletRequest request){
			Enumeration <String> paramName = (Enumeration<String>) request.getParameterNames();
			 while (paramName.hasMoreElements()) {
			            String element = (String) paramName.nextElement();
			            System.out.println(element + " = " + request.getParameter(element));
			}
	  }
		
	 public static String getMobileDisplay(String mobile1,String mobile2){
				String contact = "";
				
				if(mobile1==null){
					mobile1= "";
				}
				if(mobile2==null){
					mobile2= "";
				}
				
				if(!"".equals(mobile1) &&  !"".equals(mobile2)){
					 	contact = mobile1+","+mobile2;
				 }else{
				    if(!"".equals(mobile1)){
				    	contact += mobile1;
					}
				    if(!"".equals(mobile2)){
				    	contact += mobile2;
					}
				 }
				 return contact;
	  }
		
	  protected  static String doGenRandomPassword() {
			String password = "";
			String UPPER = "YZVWMEJKFABXNLGHDSTCUPQR";
			String lowwer = "pqjkiayrsbwtunzvxhmefgd";
			String digit = "512487963";
			//-----  Password Format = UllU999 , U = UPPER , l = lower , 9 = Digit -----//				
			for(int i=0;i<7;i++){							
				if(i==0 || i==3){
					int randIdx = (int)(Math.random() * UPPER.length()); 
					password += UPPER.substring(randIdx,randIdx+1); 
				}else if (i==1 || i==2){
					int randIdx = (int)(Math.random() * lowwer.length());
					password += lowwer.substring(randIdx,randIdx+1); 
				}else{
					int randIdx = (int)(Math.random() * digit.length()); 
					password += digit.substring(randIdx,randIdx+1);
				}
			}			
			return password;
		}


}