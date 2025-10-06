package serv.servlets;
import com.lowagie.text.Font;
import java.awt.font.TextAttribute;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.AttributedString;
import java.util.ArrayList;
import java.util.Calendar;
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
import serv.common.User;
import com.lh.servlet.DBServlet;
import com.lh.util.doString;
import com.lowagie.text.Document;
import com.lowagie.text.PageSize;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfImportedPage;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfReader;
import com.lowagie.text.pdf.PdfWriter;

/**
 * Servlet implementation class for Servlet: ESERV_PrintPwdOldCustServlet
 *
 */

/**
 * Servlet implementation class for Servlet: ESERV_PrintPwdOldCustServlet
 * create by : pradoem wongkraso
 * date :2013.07.01
 * version : 2.0
 * description : this is class for print PDF file
 * user  service  (backEnd)
 * 
 */

 public class ESERV_PrintPwdOldCustServlet  extends  DBServlet{
	    /* (non-Java-doc) @see javax.servlet.http.HttpServlet#HttpServlet() */
		public ESERV_PrintPwdOldCustServlet() {
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
		
		protected void doGenerateAction(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
			// TODO Auto-generated method stub
			response.setContentType("text/html; charset=TIS-620");
			Connection conn = null;
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			ResultSet rs1 = null;
			StringBuffer sql = new StringBuffer();	
	
			//GetParamRQ(request);		
	        try{ 
	
		        	String[] projSelDDL = request.getParameterValues("projSelDDL"); 
		        	String multiFlag = request.getParameter("multiFlag")==null?"-1":request.getParameter("multiFlag"); 
		        	//multiFlag =0 : select one project only && adding ilock1..5
		        	//multiFlag =1 : select multiple project not adding ilock
		        	//multiFlag =2 : select all project (AA:999)not adding ilock
		        	String iLock1 = request.getParameter("lock1")==null?"":request.getParameter("lock1").toUpperCase();
		        	String iLock2 = request.getParameter("lock2")==null?"":request.getParameter("lock2").toUpperCase();
		        	String iLock3 = request.getParameter("lock3")==null?"":request.getParameter("lock3").toUpperCase();
		        	String iLock4 = request.getParameter("lock4")==null?"":request.getParameter("lock4").toUpperCase();
		        	String iLock5 = request.getParameter("lock5")==null?"":request.getParameter("lock5").toUpperCase();	        	
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
		 			conn.setAutoCommit(false);
					conn.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED);
					
		        	//select case SQL preparing statement below
		        	int x = Integer.parseInt(multiFlag);
		        	switch(x){
			        	case 0 :{//multiFlag =0 : select one project only && adding ilock1..5
			        			boolean isDate = false;
			        			String []projectId = projSelDDL[0].split("\\-");
			        			sql.delete(0, sql.length());
			        			sql.append(" select i_company,i_project,i_lor,i_sort,i_cus_intent1,i_exp_intent1,d_close_law ")
			        			   .append(" from lan:acscontr  ")
			        			   .append(" where f_contr  is null ");
			        			   if(!fday.equals("") && !fmm.equals("") && !fyy.equals("") && 
			        				 (!tday.equals("") && !tmm.equals("") && !tyy.equals(""))){
			        				   sql.append(" and d_close_law between ? and ? ");
			        				   isDate = true;
			        			   }		        			  
			        			  sql.append(" and i_company =? and i_project = ?  ");
			        			  
			        			  if(!iLock1.equals("") || !iLock2.equals("") || !iLock3.equals("") ||!iLock4.equals("") ||!iLock5.equals("") ){
			        				  sql.append(" and i_sort in ('"+iLock1+"','"+iLock2+"','"+iLock3+"','"+iLock4+"','"+iLock5+"') "); 
			        			  }
			        			  sql.append(" order by i_company,i_project,i_sort ");
			        			int i = 1;
			        			pstmt = conn.prepareStatement(sql.toString()); 
			        			if(isDate){
									pstmt.setString(i++, fromDate);//fromDate	
									pstmt.setString(i++, toDate);//toDate	
			        			}
								pstmt.setString(i++, projectId[0]);//icom	
								pstmt.setString(i++, projectId[1]);//iproj	
			        		break;
			        	}
			        	case 1 :{//multiFlag =1 : select multiple project not adding ilock
			        			//LH-025
			        			StringBuffer tempSQL = new StringBuffer();
			        			String [] temp = null;
			        			String expression = "";
					        	if(projSelDDL!=null){
					        		for(int i = 0;i<projSelDDL.length;i++){
					        			//System.out.println("-->"+projSelDDL[i]);
					        			temp = projSelDDL[i].split("\\-");
					        			if(i==0){
					        				expression = " AND ( ";
					        			}else{
					        				expression = " OR ";
					        			}
					        			tempSQL.append(expression)
					        			       .append(" ( i_company ='").append(temp[0]).append("' ")
					        			       .append(" and i_project ='").append(temp[1]).append("' )");
					        		}
					        		tempSQL.append(" ) ");
					        	}				        	
			        			sql.delete(0, sql.length());
			        			sql.append(" select i_company,i_project,i_lor,i_sort,i_cus_intent1,i_exp_intent1,d_close_law ")
				        			.append(" from lan:acscontr  ")
				        			.append(" where f_contr  is null ")
				        			.append(" and d_close_law between ? and ? ")
				        			//.append(" and i_company =? and i_project = ? ")
				        			.append(tempSQL);
			        			sql.append(" order by i_company,i_project,i_sort ");
				        		//or i_company ='LH' and i_project = '234'
			        			int i = 1;
			        			pstmt = conn.prepareStatement(sql.toString()); 
								pstmt.setString(i++, fromDate);//fromDate	
								pstmt.setString(i++, toDate);//toDate	
				        		break;
			        	}
			        	case 2 :{//multiFlag =2 : select all project (AA:999)not adding ilock
			        			sql.delete(0, sql.length());
			        			sql.append(" select i_company,i_project,i_lor,i_sort,i_cus_intent1,i_exp_intent1,d_close_law ") 
			        				.append(" from lan:acscontr  ")
			        				.append(" where f_contr  is null ")
			        				.append(" and d_close_law between ? and ? order by i_company,i_project,i_sort ");	
			        			int i = 1;
			        			pstmt = conn.prepareStatement(sql.toString()); 
								pstmt.setString(i++, fromDate);//fromDate	
								pstmt.setString(i++, toDate);//toDate	
			        		break;		        		
			        	}
			        	default :{
		        			sql.delete(0, sql.length());
		        			sql.append(" select i_company,i_project,i_lor,i_sort,i_cus_intent1,i_exp_intent1,d_close_law ") 
		        				.append(" from lan:acscontr  ")
		        				.append(" where f_contr  is null ")
		        				.append(" and d_close_law between ? and ?  order by i_company,i_project,i_sort ");	
		        			int i = 1;
		        			pstmt = conn.prepareStatement(sql.toString()); 
							pstmt.setString(i++, fromDate);//fromDate	
							pstmt.setString(i++, toDate);//toDate	
			        	}
		        	}
		        	//System.out.println("--SQL Main :"+sql.toString());
		        	//-----------------------------------
		        	rs = pstmt.executeQuery();    
		        	//-----------------------------------
		        	//System.out.println("***executeQuery ***");
					
		        	//------call method  ExcuteData();
			        //List  strArr = null;
		        	String [] strArr = null;
			        ArrayList result = new ArrayList();
			        //************************************************************************//		         
		        	String comId = "";
					String projectId = "";
					String iLor = "";

					StringBuffer sqlQurey = new StringBuffer();
					StringBuffer sql2 = new StringBuffer();

					String nameProject = "";
					//*********************************************
					String  tblEserLogin = "lan:ESER_LOGIN";
					String  tblEserCust = "lan:eser_cust";
					String  tblEserLock = "lan:ESER_LOCK";
					

					sqlQurey.delete(0, sqlQurey.length());
					sqlQurey.append("  select a.n_customer,b.i_company,b.i_project,b.i_lock,c.user_id,c.user_password,b.i_house   ")
					   .append("  from "+tblEserCust+" a,"+tblEserLock+" b,"+tblEserLogin+" c where b.i_company = ? and b.i_project = ? and b.i_lor = ?  ")
					   .append("  and  c.user_id[1,2] = ?  and c.user_id[3,5] = ?  ")
					   .append("  and b.i_customer = c.user_cust and c.user_cust = a.i_customer order by b.i_company,b.i_project,b.i_lock  ");
					
		        	//*************Find project name
					sql2.delete(0, sql2.length());
		            sql2.append(" select n_project  from lan:acxprojt  where  i_company = ? and i_project = ?  ");
					/***************************************************/
					int i = 1;
					boolean isRec = false;
					
					int c = 1;
					
					while(rs.next()){
			        	comId = "";
						projectId = "";
						iLor   = "";	
						
						iLor = doString.checkString(rs.getString("i_lor"),"");
			        	comId 		= doString.checkString(rs.getString("i_company"),"");
						projectId 	= doString.checkString(rs.getString("i_project"),"");
						
						//System.out.println("-->SQL :"+sqlQurey.toString());
						
						isRec = false;
						pstmt = conn.prepareStatement(sqlQurey.toString()); 
						i = 1;
			     		pstmt.setString(i++,comId);//I_COMPANY	
			     		pstmt.setString(i++,projectId);//I_PROJECT
			     		pstmt.setString(i++,iLor.toString());//I_Lor
			     		pstmt.setString(i++,comId.toLowerCase());//I_COMPANY	
			     		pstmt.setString(i++,projectId);//I_PROJECT
			     		rs1 = pstmt.executeQuery();
						if(rs1.next()){
							strArr = new String[5];
							//System.out.println("--->Add customer name");
							strArr[0] = doString.checkString(rs1.getString("n_customer"),""); //n_prename
							strArr[1] = doString.checkString(rs1.getString("user_id"),"");//USER_ID
							strArr[2] = doString.checkString(rs1.getString("user_password"),"");//USER_PASSWORD
							strArr[3] = doString.checkString(rs1.getString("i_house"),"");//i_house
							isRec = true;
						}
						rs1 = null;
						
						if(isRec){
				        	//*************Find project name
					        pstmt = conn.prepareStatement(sql2.toString()); 
				     		pstmt.setString(1,comId);//I_COMPANY	
				     		pstmt.setString(2,projectId);//I_PROJECT
							rs1 = pstmt.executeQuery();
							nameProject = "";
							if(rs1.next()){
								nameProject = doString.checkString(rs1.getString("n_project"),"");
							}
							rs1 = null;
							//Add n_project name
							strArr[4] = nameProject;
							result.add(strArr);//Add result
							//System.out.println("--Row :"+c++);
						}
						/***************************************************/
					}//## End while Loop

				if(result.size()==0){
	        		//case find not found
	        		response.sendRedirect(request.getContextPath()+"/ESERV_PrintPwdOldCustServlet?cmd=formLoad&er_code=E02");
	        	}else{
		        	       	
		        	ByteArrayOutputStream baos = doGenPDFPaper(result);
		        	response.setContentType("application/pdf");
					response.setContentLength(baos.size());
					ServletOutputStream outServ = response.getOutputStream();
					baos.writeTo(outServ);
					outServ.flush();
	        	}

			}catch(Exception e){		
				System.out.println("!!doGenerateAction , " +sysName+":"+ cName + " : " + e.getMessage());
				System.out.println("!!SQL Exception: "+sql.toString());		

				String forward =  request.getContextPath()+"/save_ok.jsp?other_msg=&error=1&redirect_url=SERV_Home.jsp";			
				response.sendRedirect(forward);
			}
			finally{//clean up.
				try{
					if(rs1!=null){rs1.close();}
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
					if(conn!=null){conn.close();}
				}catch(Exception e){}
			}
		} 
		
		//Gen PDF
		protected ByteArrayOutputStream doGenPDFPaper(ArrayList result) throws Exception{
			
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			//try{				
				if(result !=null && result.size()>0){
						//List strArr = null;
					
						String []strArr = null;
					 	//DecimalFormat dd = new DecimalFormat("#,###,##0.00");				        		
					 	//-------- Start Generate PDF File --------//
						String path = getServletContext().getRealPath("/")+"/template";
						String Thai_TTFB =  getServletContext().getRealPath("/")+"/Fonts/CORDIA.TTF";
						BaseFont bf = BaseFont.createFont(Thai_TTFB, BaseFont.IDENTITY_H, BaseFont.EMBEDDED);						

						Document document = new Document(PageSize.A4, 0, 0, 0, 0);
						//ByteArrayOutputStream baos = new ByteArrayOutputStream();
						PdfWriter writer = PdfWriter.getInstance(document, baos);
						PdfContentByte cb = writer.getDirectContent();	
						PdfReader reader = null;
						PdfPTable table = new PdfPTable(100);
						table.setWidthPercentage(100);				
						
						//document = new Document(PageSize.A4, 10, 10, 10, 10);
						document = new Document(PageSize.A4, 0, 0, 0, 0);
						baos = new ByteArrayOutputStream();
						writer = PdfWriter.getInstance(document, baos);			
						cb = writer.getDirectContent();				
						/************************************/
						document.open();	
						PdfImportedPage page1 = null;
						
						/** Load Template && Set Header  **/
						//set setTextMatrix x,y
						//X++>> is column 
						//Y++ 0 ^ uper 
						/**********************************/	
						Iterator it = result.iterator();					
						//First Load Page
				    	//System.out.println("**********************************");
				    	//System.out.println("**     LOAD Template & HEAD     **");
				    	//System.out.println("**********************************");
						document.newPage();  
						
						reader = new PdfReader(path+"/Doc1.pdf");		
						//reader = new PdfReader(path+"/form_pwd_cust.pdf");						  
						page1 = writer.getImportedPage(reader, 1);	
						cb.addTemplate(page1, 0, 0);							     								
						cb.setFontAndSize(bf, 18);
						
						
						//******************set Header krub.
						int X_60 = 60;
						int X_300= 300;
						int X_505 = 505;
						
						//********************** -->First Position
						int Y_NAME  = 820;//820;
						int Y_PROJ  = 800;//800;						
						int Y_LOGIN = 670;//654;
						int Y_PASS  = 650;// 634;
						//*********************
				    	int row = 0;
				    	int loop = 1;
				    	//int ii = 1;
  	
				    	//int maxRow = result.size();
				    	while(it.hasNext()){					    								
							if(row<=2){
								strArr = (String[])it.next();
					    		//Fetch Data to page //0,1,2		    		 					    		
								if(row == 1){//LOOP2
									//-->second Position
									Y_NAME = 540;
									Y_PROJ = 520;
									Y_LOGIN = 390;
									Y_PASS  = 370;
								}else if(row == 2){//LOOP3
									//---->third Position
									Y_NAME = 260;
									Y_PROJ = 240;
									Y_LOGIN = 110;
									Y_PASS = 90;
								}else{
									//**-->First Position
									//Reset 
								    X_60 = 60;
									X_300= 300;
									 
									Y_NAME  = 820;
									Y_PROJ  = 800;										
									Y_LOGIN = 670;
									Y_PASS  = 650;
								}
								//**********************LOOP1

								cb.beginText();	
								//CUSTOMER NAME  LASTNAME 
								cb.setTextMatrix(X_60, Y_NAME);
								cb.showText(doString.DisplayThai(strArr[0])); 
								cb.endText();
								
								cb.beginText();	
								//I_HOUSE, PROJECT NAME THAI
								cb.setTextMatrix(X_60, Y_PROJ);
								cb.showText(strArr[3]+"  "+doString.DisplayThai(strArr[4]));
								cb.endText();
								
								cb.beginText();	
								//LOGIN
								cb.setTextMatrix(X_300, Y_LOGIN);
								cb.showText("Login : "+strArr[1]);
								cb.endText();
								
								//*******Underline charecter
								cb.beginText();	
								cb.setTextMatrix(X_300+36, Y_LOGIN);
								cb.showText("_");
								cb.endText();
								
								cb.beginText();	
								cb.setTextMatrix(X_300+43, Y_LOGIN);
								cb.showText("_");
								cb.endText();

								cb.beginText();	
								cb.setTextMatrix(X_300+81, Y_LOGIN);
								cb.showText("_");
								cb.endText();
								
								
								cb.beginText();	
								//PASSWORD
								cb.setTextMatrix(X_300, Y_PASS);
								cb.showText("Password : "+strArr[2]); 	
								cb.endText();
								
								cb.beginText();	
								cb.setTextMatrix(X_505, Y_NAME);
								cb.showText("P : "+loop); 	
								cb.endText();	
								
					    		row++;
					    		loop++;
					    	 }else{
					    		/* if(loop==maxRow){
					    			 break;
					    		 }	*/				    		 
					    		/*Second Load Page or New Load page
					    		System.out.println("****************Page 2 XXX*****************");
					    		System.out.println("*     LOAD Template & HEAD      *");
					    		System.out.println("*****************Page 2XXX****************");*/								
					    		
					    		 document.newPage();  
					    		 reader = new PdfReader(path+"/Doc1.pdf");
								 //reader = new PdfReader(path+"/form_pwd_cust.pdf");						  
								 page1 = writer.getImportedPage(reader, 1);	
								 cb.addTemplate(page1, 0, 0);							     								
								 cb.setFontAndSize(bf, 18);
								 /*********************************************/
								 X_60 = 60;
								 X_300= 300;		
								 
								 //********************** -->First Position
								Y_NAME  = 820;
								Y_PROJ  = 800;										
								Y_LOGIN = 670;
								Y_PASS  = 650;
							    //********************** 								 
								row = 0;
								//loop++;
							}
						}//END while
						//************************************************************		
						document.close();	
						System.out.println(" *** PDF Gen Complete **** ");
				}
			return baos;
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
			//HttpSession session = request.getSession(false);
			//*********CurrentDate Time
	   	 	Calendar rightNow = Calendar.getInstance();
	   	 	String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
	   	 	String cur_year1 = Integer.toString((rightNow.get(Calendar.YEAR)+543)-1);
	        try{	        	
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
					sql.delete(0, sql.length());
					sql.append(" SELECT DISTINCT proj.i_company, proj.i_project, proj.n_project")
						.append(" FROM lan:acxprojt proj, lan:acsbudgh bud")
						.append(" WHERE bud.i_company = proj.i_company AND bud.i_project = proj.i_project")
						.append(" AND bud.d_year in('"+cur_year1+"','"+cur_year+"')   ")
						//.append(cur_year)
						.append(" ORDER BY proj.i_company, proj.i_project ");
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
						strList.add(0,  doString.checkString(rs.getString("i_company"),"")+"-"+doString.checkString(rs.getString("i_project"),""));
						strList.add(1,  doString.checkString(rs.getString("n_project"),""));
						projectDDL.add(strList);
					}
				rs.close();				
				//***************************************************************************/							
			  	 request.setAttribute("projDDL", projectDDL);
			  	 request.setAttribute("selProj", null);		 
			  	 request.setAttribute("er_code", request.getParameter("er_code"));
		   		 String tarGetUrl ="/ESERV_PrintCarbonPwdOldCust.jsp";
		   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
				 dispatcher.forward(request,response);			
			}catch(Exception e){
				System.out.println("!!doFormLoad , " +sysName+":"+ cName + " : " + e.getMessage());
				System.out.println("!!SQL Exception: "+sql.toString());		

				String forward =  request.getContextPath()+"/save_ok.jsp?other_msg=&error=1&redirect_url=SERV_Home.jsp";			
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
		
		
		private void GetParamRQ(HttpServletRequest request){
			Enumeration <String> paramName = (Enumeration<String>) request.getParameterNames();
			 while (paramName.hasMoreElements()) {
			            String element = (String) paramName.nextElement();
			            System.out.println(element + " = " + request.getParameter(element));
			}
	  }

}