package serv.servlets;
import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
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
import com.lowagie.text.Font;
import com.lowagie.text.PageSize;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfImportedPage;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfReader;
import com.lowagie.text.pdf.PdfWriter;
/** Servlet implementation class for Servlet: ESERV_GenPwdCustServlet*/
/**
 * Servlet implementation class for Servlet: ESERV_GenPwdCustServlet
 * create by : pradoem wongkraso
 * date :2012.07.02
 * version : 1.0
 * description : this is class for generate password customers
 * user  service  (backEnd)
 * 
 */
 public class ESERV_GenPwdCustServlet  extends  DBServlet{
	    /* (non-Java-doc) @see javax.servlet.http.HttpServlet#HttpServlet() */
		public ESERV_GenPwdCustServlet() {
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
						// doString.checkString(doString.DisplayThai(rs.getString("n_customer")),"");
					}
				rs.close();				
				//***************************************************************************/							
			  	 session.setAttribute("projDDL", projectDDL);
			  	 request.setAttribute("selProj", null);		 
			  	 //System.out.println("test er_code :"+request.getParameter("er_code"));
			  	 request.setAttribute("er_code", request.getParameter("er_code"));
			  	 //System.out.println("formLoad ->successfully.");	  	
		   		 String tarGetUrl ="/ESERV_GenPwd2Cust.jsp";
		   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
				 dispatcher.forward(request,response);			
			}catch(Exception e){
				System.out.println("!!doFormLoad , " +sysName+":"+ cName + " : " + e.getMessage());
				System.out.println("!!SQL Exception: "+sql.toString());		
				String ERROR_PAGE = "/errorPage.jsp";
				RequestDispatcher dispatcher = context.getRequestDispatcher(ERROR_PAGE);
				dispatcher.forward(request,response);
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

		//***doGenerateAction krub.
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
	        	
	        	//validate date  case validate invalid
	        	/*if(fday.equals("") || fmm.equals("") || fyy.equals("")){
	        		response.sendRedirect(request.getContextPath()+"/ESERV_GenPwdCustServlet?cmd=formLoad&er_code=E01");
	        		return;
	        	}
	        	if(tday.equals("") || tmm.equals("") || tyy.equals("")){
	        		response.sendRedirect(request.getContextPath()+"/ESERV_GenPwdCustServlet?cmd=formLoad&er_code=E01");
	        		return;
	        	}*/
	        	
	        	String fromDate = fyy+"-"+fmm+"-"+fday;
	        	String toDate =   tyy+"-"+tmm+"-"+tday;	        	
	        	//System.out.println("Fdate :"+fromDate);
	        	//System.out.println("toDate :"+toDate);        	
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
		        			  sql.append(" order by i_sort ");
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
		        			sql.append(" order by i_sort ");
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
		        				.append(" and d_close_law between ? and ? order by i_sort");	
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
	        				.append(" and d_close_law between ? and ?  order by i_sort ");	
	        			int i = 1;
	        			pstmt = conn.prepareStatement(sql.toString()); 
						pstmt.setString(i++, fromDate);//fromDate	
						pstmt.setString(i++, toDate);//toDate	
		        	}
	        	}
	        	//**Excute Statment 		        
	        	//------call method  ExcuteData();
	        	ArrayList result = doExecute(conn,pstmt,rs);
	        	
	        	//System.out.println("result List :"+result.size());	        	
	 			/********************************************************************/		
	 			conn.commit();
	 			conn.setAutoCommit(true);	 
	        	/********************************************************************/	
	        	
	        	if(result.size()==0){
	        		//case find not found
	        		response.sendRedirect(request.getContextPath()+"/ESERV_GenPwdCustServlet?cmd=formLoad&er_code=E02");
	        	}else{
		        	       	
		        	ByteArrayOutputStream baos = doGenPDFPaper(result);
		        	response.setContentType("application/pdf");
					response.setContentLength(baos.size());
					ServletOutputStream outServ = response.getOutputStream();
					baos.writeTo(outServ);
					outServ.flush();
	        	}
	        	//System.out.println("----->doGenerateAction succesfully.");
			}catch(Exception e){
				try{
					conn.rollback();
				}catch(Exception ex){}		
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
		
		//Gen PDF
		protected ByteArrayOutputStream doGenPDFPaper(ArrayList result) throws Exception{
			
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			//try{				
				if(result !=null && result.size()>0){
						List strArr = null;
					 	//DecimalFormat dd = new DecimalFormat("#,###,##0.00");				        		
					 	//-------- Start Generate PDF File --------//
						String path = getServletContext().getRealPath("/")+"/template";
						String Thai_TTFB =  getServletContext().getRealPath("/")+"/Fonts/CORDIA.TTF";
						BaseFont bf = BaseFont.createFont(Thai_TTFB, BaseFont.IDENTITY_H, BaseFont.EMBEDDED);//
						
						//Font microSanf = new Font(bf, 18, Font.NORMAL,new Color(110,110,110));				
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
						cb.setFontAndSize(bf, 14);
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

				    	int maxRow = result.size();
				    	while(it.hasNext()){	
				    		
							
							if(row<=2){

								strArr = (ArrayList)it.next();
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
								cb.showText(doString.DisplayThai(strArr.get(0).toString())); 
								//I_HOUSE, PROJECT NAME THAI
								cb.setTextMatrix(X_60, Y_PROJ);
								cb.showText(strArr.get(3).toString()+"  "+doString.DisplayThai(strArr.get(4).toString()));
								 //LOGIN
								cb.setTextMatrix(X_300, Y_LOGIN);
								cb.showText("Login : "+strArr.get(1));
								//PASSWORD
								cb.setTextMatrix(X_300, Y_PASS);
								cb.showText("Password : "+strArr.get(2)); 	
								

								cb.setTextMatrix(X_505, Y_NAME);
								cb.showText("P : "+loop); 	
								
								cb.endText();	
					    		row++;
					    		loop++;
					    	 }else{
					    		 if(loop==maxRow){
					    			 break;
					    		 }					    		 
					    		//Second Load Page or New Load page
					    		//System.out.println("****************Page 2 XXX*****************");
					    		//System.out.println("*     LOAD Template & HEAD      *");
					    		//System.out.println("*****************Page 2XXX****************");								
					    		
					    		 document.newPage();  
					    		 reader = new PdfReader(path+"/Doc1.pdf");
								 //reader = new PdfReader(path+"/form_pwd_cust.pdf");						  
								 page1 = writer.getImportedPage(reader, 1);	
								 cb.addTemplate(page1, 0, 0);							     								
								 cb.setFontAndSize(bf, 14);
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
							//ii++;
							//System.out.println(" LOOP:"+loop);
						}//END while
						//************************************************************		
						document.close();	
						System.out.println(" *** PDF Gen Complete **** ");
				}
			return baos;
		}

		
		//**********
		protected ArrayList doExecute(Connection conn,PreparedStatement pstmt1,ResultSet rs) throws Exception {	
			ResultSet rs1 = null;
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
			
			PreparedStatement pstmt = null;
			//************************************************************************//
            List  strArr = null;
            ArrayList result = new ArrayList();
            //************************************************************************//
			
				String sumQ_area = "0";
				String Q_area = "0";
				String z_price = "";
				int iphase = 0;
				//System.out.println("--->doExcute starting.");
				
				
				rs = pstmt1.executeQuery();
				int x = 1;				
				//***************************Prepared Insert into*****************************************//
				//System.out.println("--->Prepared SQL insert into table ESER_CUST.");
				sqlInsCust.delete(0, sqlInsCust.length());
				sqlInsCust.append(" INSERT INTO lan:eser_cust (i_customer,n_customer, i_tel_home,i_tel_mobile ) ") 
            	     .append(" VALUES (?,?,?,?)");  
	            //pstmtIntEserCust = conn.prepareStatement(sql.toString()); 	            
	           
	            
	           // System.out.println("--->Prepared SQL insert into table ESER_LOGIN.");
	            sqlInsLogin.delete(0, sqlInsLogin.length());
	            sqlInsLogin.append(" INSERT INTO lan:ESER_LOGIN (USER_ID,USER_WHO,USER_ACL,USER_CUST,USER_PASSWORD,F_PRINT,D_PRINT ) ") 
            	     .append(" VALUES (?,'E','U',?,?,'Y',TODAY)");  
	            //pstmtIntEserLogin = conn.prepareStatement(sql.toString()); 
	            
	            
	           // System.out.println("--->Prepared SQL insert into table ESER_LOCK.");
	            sqlInsLock.delete(0, sqlInsLock.length());
				sqlInsLock.append(" INSERT INTO lan:ESER_LOCK(I_CUSTOMER,I_COMPANY,I_PROJECT,I_LOR,I_LOCK,D_CLOSE_LAW,Q_AREA,Q_SQM,Z_INFRA,D_INFRA,I_MODEL,F_EXTRA,I_HOUSE ) ")  
	               .append(" VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)");  
	            //pstmtIntEserLock = conn.prepareStatement(sql.toString());
	           
	            //***********************************************************************//
				while(rs.next()){
					int i = 1;
					//strArr = new ArrayList();
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
					
					//4. Find customer name & Last name
					//System.out.println("--->Find customer name.");
					sql.delete(0, sql.length());
					sql.append(" select n_prename,n_ncustomer,n_scustomer,a_id_tel,a_wk_tel,a_etc_tel from lan:acxcusto where i_customer  =? ");
					pstmt = conn.prepareStatement(sql.toString()); 
					pstmt.setString(1, iCusto.toString());//i_customer	
					rs1 = pstmt.executeQuery();
					//System.out.println("--->sql4 :"+sql.toString());
					if(rs1.next()){
						param1.delete(0, param1.length());
						param2.delete(0, param2.length());
						param3.delete(0, param3.length());
						param4.delete(0, param4.length());
						param5.delete(0, param5.length());
						param6.delete(0, param6.length());
						
						param1.append(doString.checkString(rs1.getString("n_prename"),""));
						param2.append(doString.checkString(rs1.getString("n_ncustomer"),""));
						param3.append(doString.checkString(rs1.getString("n_scustomer"),""));
						param4.append(doString.checkString(rs1.getString("a_id_tel"),""));
						param5.append(doString.checkString(rs1.getString("a_wk_tel"),""));
						param6.append(doString.checkString(rs1.getString("a_etc_tel"),""));
					}
					rs1= null;	
					/**********************/
					//***Add customer name
					//System.out.println("--->Add customer name");
					//strArr.add(0,param1.toString()); //n_prename
					//strArr.add(1,param2.toString()); //n_ncustomer
					//strArr.add(2,param3.toString());//n_scustomer
					/***********************/
					/*#5. insert into table ESER_CUST*/
					/*************************/				
					i = 1;
					//Check duplicate ESER_CUST
	     			int chkDup = 0;
	     			//System.out.println("--->Check duplicate ESER_CUST");
					sql.delete(0, sql.length());
		            sql.append(" select count(*) as no  from lan:eser_cust  where i_customer  = ?  ") ;//int 67140 
		            pstmt = conn.prepareStatement(sql.toString()); 
					i = 1;
		     		pstmt.setInt(i++,Integer.parseInt(iCusto.toString()));//USER_ID
					rs1 = pstmt.executeQuery();
					if(rs1.next()){
						chkDup = rs1.getInt("no");
					}
					rs1= null;
					if(chkDup==0){
						//pstmtIntEserCust.addBatch(); 
						//System.out.println("+++> insert ESER_CUST.");					
						//*******************case duplicate 	
						//System.out.println("--->Case ESER_CUST duplicate delete success :"+iCusto.toString());
						pstmt = conn.prepareStatement(sqlInsCust.toString());
						i = 1;
						pstmt.setString(i++,iCusto.toString());//i_customer	
						pstmt.setString(i++,param1.toString()+" "+param2.toString()+"   "+param3.toString());//n_customer	
		     			//pstmt.setString(i++,"");//i_email1		     			 
		     			//pstmt.setString(i++,"");//i_email2
						pstmt.setString(i++, param4.toString()+","+param5.toString());//i_tel_home    
						pstmt.setString(i++, param6.toString());//i_tel_mobile  
						pstmt.executeUpdate();
						//System.out.println("+++> insert ESER_CUST OK.");	
					}
					
					/***********************/
					/*#6. insert into table ESER_LOGIN*/
					/*************************/
		            i = 1;
		            param1.delete(0, param1.length());
		            param1.append(iCompany.toString()+iProject.toString()+iSort.toString());//USER_ID
		            param2.delete(0, param2.length());
		            param2.append(doGenRandomPassword());
		            
		            /************************************************/
		            //Username & password
		            //System.out.println("--->sername & password");
		            //strArr.add(3,param1.toString().toLowerCase());//USER_ID
		           // strArr.add(4,param2.toString());//USER_PASSWORD
		            /************************************************/		            
		            //******************Check duplicate ESER_LOGIN
	     			chkDup = 0;
					//System.out.println("--->Check duplicate ESER_LOGIN");
					sql.delete(0, sql.length());
		            sql.append(" select count(*) as no  from lan:ESER_LOGIN  where user_id = ? and user_cust= ? ") ;
		            pstmt = conn.prepareStatement(sql.toString()); 
					i = 1;
		     		pstmt.setString(i++, param1.toString().toLowerCase());//USER_ID
		     		pstmt.setString(i++, iCusto.toString());//user_cust
					rs1 = pstmt.executeQuery();
					if(rs1.next()){
						chkDup = rs1.getInt("no");
					}
					rs1= null;
					if(chkDup==0){
			     		pstmt = conn.prepareStatement(sqlInsLogin.toString());
						i=1;
			     		pstmt.setString(i++, param1.toString().toLowerCase());//USER_ID	
			     		pstmt.setString(i++,iCusto.toString());//USER_ICUST	
			     		pstmt.setString(i++,param2.toString());//USER_PASSWORD	
						pstmt.executeUpdate();
						//System.out.println("+++> insert ESER_LOGIN OK.");	
					}
					//pstmtIntEserLogin.executeUpdate(); 
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
     			  // System.out.println("---> Find model,i_house ");   			   
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
					rs1 =null;
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
					rs1 =null;
					/***********************/
					/*#11. insert into table ESER_LOCK*/
					/*************************/
					//System.out.println("--->insert into table ESER_LOCK.");
	     			//*******************Check duplicate ESER_CUST
	     			chkDup = 0;
	     			//System.out.println("--->Check duplicate ESER_LOCK");
					sql.delete(0, sql.length());
		            sql.append(" select count(*) as no  from lan:ESER_LOCK  where i_customer  = ? and i_company = ? and i_project = ? and i_lor = ? and i_lock = ? ") ;//int 67140 
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
						//pstmtIntEserLock.addBatch();
						//System.out.println("+++>addBatch insert ESER_LOCK.");
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
					        //System.out.println("--->insert EserLock OK..");
					}
				}//-------#End while looop		
				//System.out.println("#######-->doExcute successfully. #################");
				
				//*********************************************
				int i = 1;
				rs = pstmt1.executeQuery();
				while(rs.next()){	
					strArr = new ArrayList();
					iCompany.delete(0, iCompany.length());
					iProject.delete(0, iProject.length());
					iLor.delete(0, iLor.length());
					//iSort.delete(0, iSort.length());
					iCompany.append(doString.checkString(rs.getString("i_company"),""));
					iProject.append(doString.checkString(rs.getString("i_project"),""));
					iLor.append(doString.checkString(rs.getString("i_lor"),""));
					//iSort.append(doString.checkString(rs.getString("i_sort"),""));
					
					//System.out.println("--->select for pdf krub ");   			   
					sql.delete(0, sql.length());
					sql.append("  select a.n_customer,b.i_company,b.i_project,b.i_lock,c.user_id,c.user_password,b.i_house   ")
					   .append("  from lan:eser_cust a,lan:eser_lock b,lan:eser_login c where b.i_company = ? and b.i_project = ? and b.i_lor = ?  ")
					   .append("  and b.i_customer = c.user_cust and c.user_cust = a.i_customer order by b.i_company,b.i_project,b.i_lock  ");
					
					//System.out.println("<<<<<<<<<<<<SQL For PDF  : "+sql.toString()); 
					//System.out.println("--->i_com : "+iCompany.toString()+",i_proj:"+iProject.toString()+",iLor:"+iLor.toString()); 
					
					pstmt = conn.prepareStatement(sql.toString()); 
					i = 1;
		     		pstmt.setString(i++,iCompany.toString());//I_COMPANY	
		     		pstmt.setString(i++,iProject.toString());//I_PROJECT
		     		pstmt.setString(i++,iLor.toString());//I_Lor
		     		rs1 = pstmt.executeQuery();
					if(rs1.next()){
						//System.out.println("--->Add customer name");
						strArr.add(0,doString.checkString(rs1.getString("n_customer"),"")); //n_prename
						strArr.add(1,doString.checkString(rs1.getString("user_id"),""));//USER_ID
						strArr.add(2,doString.checkString(rs1.getString("user_password"),""));//USER_PASSWORD
						strArr.add(3,doString.checkString(rs1.getString("i_house"),""));//i_house
					}else{
						strArr.add(0,"");
						strArr.add(1,"");
						strArr.add(2,"");
						strArr.add(3,"");
					}

					//*************Find project name
					sql.delete(0, sql.length());
		            sql.append(" select n_project  from lan:acxprojt  where  i_company = ? and i_project = ?  ");
		            pstmt = conn.prepareStatement(sql.toString()); 
					i = 1;
		     		pstmt.setString(i++,iCompany.toString());//I_COMPANY	
		     		pstmt.setString(i++,iProject.toString());//I_PROJECT
					rs1 = pstmt.executeQuery();
					param6.delete(0, param6.length());
					if(rs1.next()){
						param6.append(doString.checkString(rs1.getString("n_project"),""));
					}
					/***************************************************/
					//Add n_project name
					strArr.add(4,param6.toString());
					result.add(strArr);//Add result
					/***************************************************/
				}				
				try {
					if(rs1!=null){rs1.close();}
					if(pstmt!=null){pstmt.close();}
				}catch(SQLException e) {
					e.printStackTrace();
				}				
				return result;			
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
		//doGenerateAction
		//-------Print Request parameter
		private void GetParamRQ(HttpServletRequest request){
				Enumeration <String> paramName = (Enumeration<String>) request.getParameterNames();
				 while (paramName.hasMoreElements()) {
				       String element = (String) paramName.nextElement();
				       System.out.println(element + " = " + request.getParameter(element));
				}
		 }
    
}