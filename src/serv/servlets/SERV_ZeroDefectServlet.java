package serv.servlets;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.List;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import serv.common.Constants;
import serv.common.User;
import com.lh.servlet.DBServlet;
import com.lh.util.doString;

/**
 * date : 2016.01.28  
 * modify by pradoem
 * **********************************
 * Servlet implementation class for Servlet: SERV_ZeroDefectServlet
 * create by : pradoem wongkraso
 * date :2012.07.25
 * version : 1.0
 * description : this is class forQC Zero Defection 
 * user  service  (backEnd)
 * 
 */
 public class SERV_ZeroDefectServlet extends   DBServlet{
    /* (non-Java-doc)
	 * @see javax.servlet.http.HttpServlet#HttpServlet()
	 */
	public SERV_ZeroDefectServlet() {
		super();
	}   
	
	String sysName = "LHServ";
	String cName = new String(this.getClass().getName() + ".performTask :");	
	
	private void genRedirectCode(PrintWriter out,String page,String redirect,String error,String otherMsg) {
		out.println("<form method='post' action='"+page+"'>");		
		out.println("<input type='hidden' name='error' value='"+error+"'>");
		out.println("<input type='hidden' name='other_msg' value='"+doString.MS874ToUnicode(otherMsg)+"'>");
		out.println("<input type='hidden' name='redirect_url' value='"+doString.MS874ToUnicode(redirect)+"'>");		
		out.println("<script> document.forms[0].submit();</script>");
		out.println("</form>");		
	}
	
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
				  this.doFetchingData(request,response,user);				
			  }else if(command.equals("chg")){
				  this.doChangeRadioButton(request, response, user);
			  }else if(command.equals("submit")){
				  this.doUpdateRecord(request,response,user);  
			  }
		}catch(Exception e){
			e.printStackTrace();
			System.out.println(sysName+":"+cName +" "+e.toString());		
		}
	}
	
	//***doOnChangeDate krub.
	protected void doUpdateRecord(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub

		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		StringBuffer sql = new StringBuffer();	
		ServletContext context = getServletContext();
		HttpSession session = request.getSession(false);
		//*********CurrentDate Time

		//String msgTxt = "";// Constants.APP_PATH+Constants.SAVE_PAGE;
		//String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	

		String savePage = Constants.SAVE_PAGE;
		String errorPage ="SERV_Home.jsp";
		
		response.addHeader("Content-Type", "text/html");
		response.setContentType("text/html; charset=TIS-620");
		PrintWriter out = response.getWriter();
        try{ 	
        	  //reasonDDL3
        	  //System.out.println("-->doUpdateRecord ->Starting.");	
        	  GetParamRQ(request);
        	  String tempCnt = request.getParameter("cnt")==null?"1":request.getParameter("cnt");
        	  int cnt = Integer.parseInt(tempCnt);
        	  String [] causeDDL = new String[cnt];//01,04..N
        	  String [] f_zero = new String[cnt]; //Y,N..N
        	  String [] itemJob = new String[cnt];
        	  String [] i_seq = new String[cnt];
        	  String [] c_descNo = new String[cnt];

        	  for(int i=0;i<cnt;i++){
        		  causeDDL[i] = ""; 
        		  f_zero[i] = "";
        		  itemJob[i] = "";
        		  i_seq[i] = "";
        		  c_descNo[i] = "";
        	  }
        	 String iDocno = doString.checkString(request.getParameter("i_docno"),"");//iDocno 
        	 if("".equals(iDocno)){
        		  //return error  
        		  genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ  : !! กรุณาตรวจสอบเลขที่เอกสาร. ");
        		  return;
        	 }
        	 System.out.println("TEST :---------------------- cnt :"+cnt);
        	 for(int i = 1;i<=cnt;i++){
        		 System.out.println(i+" TEST :"+doString.checkString(request.getParameter("causeDDL"+i),""));
        		 System.out.println(i+" TEST2 :"+ doString.checkString(request.getParameter("txtComment"+i),""));
        		 if("".equals(doString.checkString(request.getParameter("causeDDL"+i),"").trim())
        		    || "".equals(doString.checkString(request.getParameter("txtComment"+i),"").trim()) ){
        			 //return error 
        			 genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ : !! กรุณาตรวจสอบรายการ Zero Defect และหมายเหตุด้วย ");
        			return;
        		 }   		 
        	 }

        	 int x = 0;
        	 for(int i=1;i<=cnt;i++,x++){
        		 causeDDL[x] =  doString.checkString(request.getParameter("causeDDL"+i),"");  
        		  f_zero[x]    =  doString.checkString(request.getParameter("rbt"+i),"");
        		  c_descNo[x]  =  doString.UnicodeToMS874(doString.checkString(request.getParameter("txtComment"+i),""));
        	  }
 
        	 List  resultDt = (ArrayList)session.getAttribute("resultDt");
	 		 //Open connection
			 if (ds == null){getDS();}			
			 conn = ds.getConnection();
			 conn.setAutoCommit(false);
			 conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);

			 int i = 1;	
			 sql.delete(0,sql.length());
			 sql.append(" UPDATE lan:serv_zerohd SET i_employ_submit = ?,d_submit= current,f_status = 'CLS' ")
				.append(" Where  i_docno = ?  ");
			 pstmt = conn.prepareStatement(sql.toString()); 
			 pstmt.setString(i++, user.getEmpId());//getUserID
			 pstmt.setString(i++, iDocno);//i_eser_dochd
			 //System.out.println("-->SQL#1:"+sql.toString());
			 pstmt.executeUpdate();
			 
			 /**********************************************/			 
			 if(resultDt!=null && resultDt.size()>0){
				    int y = 0;
		        	List  strList = new ArrayList();
		        	Iterator it = resultDt.iterator();      	
		        	 while(it.hasNext()){
		        	 	strList = (ArrayList)it.next();
		        	 	itemJob[y] = (String)strList.get(1); 	//i_itmjob	 
		        	 	i_seq[y] = (String)strList.get(0);  //i_seq
		        	 	//System.out.println("--->i_seq "+strList.get(0));
		        	 	y++;
		             }
			 }
			
			 //int n = 1;
			 for(int c=0;c<cnt;c++){
				 i = 1;	
				 
				 sql.delete(0,sql.length());
				 sql.append(" UPDATE lan:serv_zerodt SET f_zero =  ? ")
				    .append("  ,f_remark  = ? ")
				    .append("  ,c_desc_no  = ? ")
				    .append("  Where  i_docno = ? and i_itmjob= '").append(itemJob[c]).append("'  and i_seq = "+i_seq[c]);

				 pstmt = conn.prepareStatement(sql.toString()); 
 				 System.out.println("Insert SQL :"+sql.toString());
 				 pstmt.setString(i++,f_zero[c]); //f_zero
				 pstmt.setString(i++, causeDDL[c]); //f_remark
				 pstmt.setString(i++,c_descNo[c]);//c_desc_no
				 pstmt.setString(i++,iDocno);//i_docno
				 pstmt.executeUpdate();
			 }
	   		 /********************************************************************/	  	
   		  	 conn.commit();
   		     conn.setAutoCommit(true);
	  	  	 synchronized(session) { 		
		    	//Clear session
		    	session.removeAttribute("causeYesDDL");
		    	session.removeAttribute("causeNoDDL");
		    	session.removeAttribute("resultDt");
	  		 }	  	  	  
	  	    //System.out.println("-->doUpdateRecord ->successfully.");		  	    
	   		String tarGetUrl = "/save_ok.jsp?&error=0&redirect_url=SERV_Home.jsp";  //SERV_Index.jsp
	   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			dispatcher.forward(request,response);		
		}catch(Exception e){			
			//System.out.println("doUpdateRecord , " +sysName+":"+ cName + " : " + e.getMessage());
			//System.out.println(" SQL Exception: "+sql.toString());	
			try{
				conn.rollback();
			}catch(Exception ex){}

			System.err.println("!!! doUpdateRecord , " +sysName+":"+ cName + " : " + e.getMessage());
			System.err.println("!!! SQL Exception: "+sql.toString());		
			genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ :doUpdateRecord , " +sysName+":"+ cName + " : " + e.getMessage());
			return;
		}
		finally{			
			//clean up.
			out.close();
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
				if(conn!=null){conn.close();}
			}catch(Exception e){}
		}
	} 
	
	
	//modify by pradoem@2015.01.29
	protected void doChangeRadioButton(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;	
		StringBuffer sql = new StringBuffer();			
		HttpSession session = request.getSession(false);
		
		response.addHeader("Content-Type", "text/html");
		response.setContentType("text/html; charset=TIS-620");
		PrintWriter out = response.getWriter();
		//*********CurrentDate Time
	 	
   	 	GetParamRQ(request);  	
   	 	
		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Index.jsp&error=true&other_msg=";	
        try{       	

        	System.out.println("doChangeRadioButton ->Starting.");

    	    String causeCode = doString.checkString(request.getParameter("causeCode"), ""); //Y,N
    	    Object objY = session.getAttribute("causeYesDDL");
    	    Object objN = session.getAttribute("causeNoDDL");
    	    
    	    ArrayList causeYesDDL = new ArrayList();
    	    ArrayList causeNoDDL = new ArrayList();
 
    	    if(objN == null || objN == null){ //CASE Session is null
    	    	if (ds == null){getDS();}			
    			conn = ds.getConnection();
    			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
    			
    			List  strList = null;
    			/****************************Select causeYesDDL for Yese
    			 *  select * from lan:serv_xstd 
     			 * where i_type= '00'  and i_code <=50
     			 * order by i_code 
    			 * **************************/
    		  	sql.delete(0,sql.length());
    			sql.append(" Select i_code,n_desc from lan:serv_xstd ")
    				.append(" Where i_type= '00'  and i_code <=50 ")
    				.append(" Order by i_code ");
    			pstmt = conn.prepareStatement(sql.toString()); 
    			rs = pstmt.executeQuery();
    			//System.out.println("-->SQL#5:"+sql);
    			while(rs.next()){
    				strList = new ArrayList();
    				strList.add(0,  doString.checkString(rs.getString("i_code"),""));
    				strList.add(1,  doString.checkString(rs.getString("n_desc"),""));
    				causeYesDDL.add(strList);				
    			}
    		  	rs.close();	  
    		  	
    			/*****************************Select causeNoDDL for No
    			 * select * from lan:serv_xstd 
     			 * where i_type= '00'  and i_code >=50
     			 * order by i_code 
    			 * ***************************/
    		  	sql.delete(0,sql.length());
    		  	sql.append(" Select i_code,n_desc from lan:serv_xstd ")
    		  		.append(" Where i_type= '00'  and i_code >=50 ")
    		  		.append(" Order by i_code ");
    			pstmt = conn.prepareStatement(sql.toString()); 
    			rs = pstmt.executeQuery();
    			//System.out.println("-->SQL#5:"+sql);
    			while(rs.next()){
    				strList = new ArrayList();
    				strList.add(0,  doString.checkString(rs.getString("i_code"),""));
    				strList.add(1,  doString.checkString(rs.getString("n_desc"),""));
    				causeNoDDL.add(strList);				
    			}
    			
   		  	 	session.setAttribute("causeYesDDL", causeYesDDL);
   		  	 	session.setAttribute("causeNoDDL", causeNoDDL);
    			rs.close();
    			pstmt.close();
    			conn.close();
    			rs = null;
    			pstmt = null;
    			conn = null;
    	    }else{//Case to ArrayList Object from session
    	    	causeYesDDL = (ArrayList)objY;
    	    	causeNoDDL = (ArrayList)objN;
    	    }
   			//--------------------------------------------------------------------------
			StringBuffer buffer = new StringBuffer();
			if(causeCode.equalsIgnoreCase("y")){
				if(causeYesDDL!=null && causeYesDDL.size()>0){
					List arrList = null;
					Iterator it = causeYesDDL.iterator();
					while(it.hasNext()){
					  arrList = (ArrayList)it.next();
					  buffer.append("<option value='"+arrList.get(0)+"'>")
					  		.append(doString.checkString(doString.DisplayThai(arrList.get(1).toString())))
					  		.append("</option>");		
					}
				}
			}else if(causeCode.equalsIgnoreCase("n")){
				if(causeNoDDL!=null && causeNoDDL.size()>0){
					List arrList = null;
					Iterator it = causeNoDDL.iterator();
					while(it.hasNext()){
					  arrList = (ArrayList)it.next();
					  buffer.append("<option value='"+arrList.get(0)+"'>")
					  		.append(doString.checkString(doString.DisplayThai(arrList.get(1).toString())))
					  		.append("</option>");		
					}					
				}
			}
			out.println(buffer.toString());
			System.out.println(" result :"+buffer.toString());
			System.out.println(" ===== doChangeRadioButton:successfully ======");
        }catch(Exception e){
			System.err.println("!!! doChangeRadioButton , " +sysName+":"+ cName + " : " + e.getMessage());
			System.err.println("!!! SQL Exception: "+sql.toString());		
			msgTxt = "doChangeRadioButton , " +sysName+":"+ cName + " : " + e.getMessage();
			response.sendRedirect(ERROR_PAGE+msgTxt);
			return;
		}
		finally{			 
			//clean up.
			try{
				out.close();
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
				if(conn!=null){conn.close();}
			}catch(Exception e){}
		}
	} 	
	
   //method FetchingData or retrive record
   //*****	method FormLoad criteria projectDDL
	protected void doFetchingData(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub
		response.setContentType("text/html; charset=TIS-620");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;	
		StringBuffer sql = new StringBuffer();			
		ServletContext context = getServletContext();
		HttpSession session = request.getSession(false);
		//*********CurrentDate Time
   	 	//Calendar rightNow = Calendar.getInstance();
   	 	//String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);  	 	
   	 	//GetParamRQ(request);  	
		String msgTxt = "";
		String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Index.jsp&error=true&other_msg=";	
        try{       	
        	//System.out.println("doFetchingData ->Starting.");
        	String fStatus = "";
    	    List   list = new ArrayList<String>();  
    	    List   strList = null;
    	    List resultDt = new ArrayList();
    	    List remarkDt = new ArrayList();
    	    List causeNoDDL = new ArrayList();
    	    List causeYesDDL = new ArrayList();
    	    
    	    String iDocNo = doString.checkString(request.getParameter("i_docno"), "");  	    
			//Open connection
			if (ds == null){getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			//conn.setAutoCommit(false);
			boolean isEserdocHd = true;
			/********************************************************************/
			String delimiter = "\\-";
			String tempId [] = iDocNo.split(delimiter);	 // 0,1,2
			/********************************************************************/
			sql.delete(0,sql.length());
			sql.append("  select a.i_docno,a.i_lock,a.d_keyin,a.n_customer,a.d_appoint,a.d_est_close,a.n_cus_tel,a.f_status , b.n_project from lan:serv_dochd a,lan:acxprojt b ")
				.append(" Where a.i_company = ? and a.i_project = ? and a.i_docno = ?  and a.i_company = b.i_company and a.i_project = b.i_project");
			
			pstmt = conn.prepareStatement(sql.toString()); 
		  	pstmt.setString(1, tempId[0]);//i_company
		  	pstmt.setString(2, tempId[1]);//i_project
		  	pstmt.setString(3, iDocNo);//i_eser_dochd
			rs = pstmt.executeQuery();
			//System.out.println("-->SQL#1:"+sql.toString());
			int i = 0;
			if(rs.next()){
				list.add(i++,  doString.checkString(rs.getString("i_lock"),""));//0
				list.add(i++,  doString.checkString(rs.getString("d_keyin"),""));//1
				//list.add(i++, "");//2  /*doString.checkString(rs.getString("n_customer"),"")*/
				//list.add(i++, "");//3  /* doString.checkString(rs.getString("n_cus_tel"),"")*/
				list.add(i++,  doString.checkString(rs.getString("d_appoint"),""));//2
				list.add(i++,  doString.checkString(rs.getString("d_est_close"),""));//3
				list.add(i++,  doString.checkString(rs.getString("n_project"),""));//4			
				isEserdocHd = false;
			}else{
				isEserdocHd = true;//Find not Found
				list.add(i++,  "");//0
				list.add(i++,  "");//1
				//list.add(i++, "");//2  /*doString.checkString(rs.getString("n_customer"),"")*/
				//list.add(i++, "");//3  /* doString.checkString(rs.getString("n_cus_tel"),"")*/
				list.add(i++,  "");//2
				list.add(i++,  "");//3
				list.add(i++,  "");//4
			}
   		  	rs.close();
   		  	
   		    sql.delete(0,sql.length());
			sql.append("  select i_docno ,f_status from lan:serv_zerohd  ")
				.append(" Where i_docno = ?  ");
			pstmt = conn.prepareStatement(sql.toString()); 
		  	pstmt.setString(1, iDocNo);//i_eser_dochd
			rs = pstmt.executeQuery();
			//System.out.println("-->SQL#test:"+sql.toString());
			if(rs.next()){
				fStatus = doString.checkString(rs.getString("f_status"),"");//5
			}

   		  	//check record Find not Found
   		  	if(isEserdocHd){

   		  		response.sendRedirect("SERV_ZeroDefect_List.jsp?er_code=E01");
   		  		return;
   		  	}
   		  	/********************************************************************/	
		  	
		  	//**************************************************************************
		  	//Modify by pradoem
		  	//date : 2012.10.18
		  	//Get  d_approve
   		  	String d_approve = "";
			sql.delete(0,sql.length());
			sql.append(" select min(d_approve) as dd  from lan:serv_flow  ")
				 .append(" where i_docno = ?  and f_itmstatus = '100' ");
			pstmt = conn.prepareStatement(sql.toString());
			pstmt.setString(1, iDocNo);//iDocNo
			rs = pstmt.executeQuery();
			if(rs.next()){
				d_approve = doString.checkString(rs.getString("dd"),"");
			}
			rs.close();
			
		   //-->Find date diff with d_keyin-d_close_law = diff_day
		   	int DIFF_DAY = 0;
		  	//String d = list.get(1).toString().substring(0,10);
			//System.out.println("d_approve :"+d_approve);
			if(d_approve.length()>10){
				d_approve= d_approve.substring(0,10);
			}
   		  	sql.delete(0,sql.length());
			sql.append("  select a.i_model,a.i_house,b.i_exp_intent1,b.i_cus_intent1,date(b.d_close_law)+365 as d_close_law, ")
			    .append(" date('"+d_approve+"')-date(b.d_close_law) as diff ")
				.append(" from lan:acxlckmd a left join lan:acscontr b ")
				.append(" on b.i_company = a.i_company and b.i_project = a.i_project ")
				.append(" and b.i_lor = a.i_lor and b.f_contr is null ")
			.append(" where a.i_company=? and a.i_project = ? and a.i_lock = ? ");
			pstmt = conn.prepareStatement(sql.toString()); 
		  	pstmt.setString(1, tempId[0]);//i_company
		  	pstmt.setString(2, tempId[1]);//i_project
		  	pstmt.setString(3, list.get(0).toString());//i_lock
			rs = pstmt.executeQuery();
			//System.out.println("-->SQL#2:"+sql);
			String cust1 = "";
			String cust2 = "";
			if(rs.next()){
				//due_date = doString.checkString(rs.getString("d_due"),"");
				list.add(i++,  doString.checkString(rs.getString("i_model"),""));//5
				list.add(i++,  doString.checkString(rs.getString("i_house"),""));//6
				list.add(i++,  doString.checkString(rs.getString("d_close_law"),""));//7
				cust1  =doString.checkString(rs.getString("i_cus_intent1"),"");
				cust2  =doString.checkString(rs.getString("i_exp_intent1"),"");
				DIFF_DAY  = rs.getInt("diff");
			}else{
				list.add(i++,  "");
				list.add(i++,  "");
				list.add(i++,  "");
			}
		  	rs.close();
		  	list.add(i++,iDocNo);//docHD 8
		  	list.add(i++,tempId[0]);//icom 9
		  	list.add(i++,tempId[1]);//iproj 10
		  	//  **************************************************************************	
			//System.out.println("----->>List:"+list.size());
		  	//select vendor create baan
   		  	sql.delete(0,sql.length());
			sql.append("  select DISTINCT a.i_docno,a.i_lock,b.ven_no,c.bus_name  from lan:serv_zerohd a,lan:unit b,lan:stpvendr c    ")
				.append(" where a.i_company = b.i_company  	and   a.i_project = b.i_project and   a.i_lock    = b.i_lock  ")
				.append(" and   b.unit_status = 'OPN'  and   b.ven_no  = c.vend_code  and a.i_docno = ? and a.i_lock = ? ");
			pstmt = conn.prepareStatement(sql.toString()); 
		  	pstmt.setString(1, iDocNo);//iDocNo
		  	pstmt.setString(2, list.get(0).toString().toUpperCase());//i_lock
			rs = pstmt.executeQuery();
			//System.out.println("-->SQL#3:"+sql);
			if(rs.next()){
				list.add(i++,doString.checkString(rs.getString("ven_no"),""));//ven_no 11
				list.add(i++,doString.checkString(rs.getString("bus_name"),""));//bus_name 12
			}else{
				list.add(i++,"");//ven_no
				list.add(i++,"");//bus_name
			}
		  	rs.close();
		  	//***************************Find customer display thai name,tel krub **********	
		  	String custId = "";
			if(cust1.equals("")){
				custId = cust2;
			}else{
				custId = cust1;
			}			
			sql.delete(0,sql.length());
			sql.append(" select n_prename,n_ncustomer,n_scustomer,a_id_tel,a_wk_tel,a_etc_tel from lan: acxcusto where  i_customer = ? ");
			pstmt = conn.prepareStatement(sql.toString()); 
		  	pstmt.setString(1, custId);//custId
		  	//System.out.println("-->SQL#x:"+sql);
			rs = pstmt.executeQuery();
			String tel1 = "";
			String tel2 = "";
			String tel3 = "";
			String tel = "";
			if(rs.next()){
				//13
				list.add(i++, doString.checkString(rs.getString("n_prename"),"")+"  "+doString.checkString(rs.getString("n_ncustomer"),"")+"   "+doString.checkString(rs.getString("n_scustomer"),""));//2 
				tel1 = doString.checkString(rs.getString("a_id_tel"),"");
				tel2 = doString.checkString(rs.getString("a_wk_tel"),"");
				tel3 = doString.checkString(rs.getString("a_etc_tel"),"");
				if(!tel1.equals("")){
					tel = tel1;
				}
				if(!tel2.equals("")){
					tel +=","+tel2;
				}
				if(!tel3.equals("")){
					tel +=","+tel3;
				}
				list.add(i++,tel);//14
			}
			rs.close();
		  	//****************************Find zero_defect DT***************************
		  	// 'AR-002-5501180'
		  	sql.delete(0,sql.length());
			sql.append(" select a.i_seq,a.i_itmjob,a.i_docno,a.f_remark,a.f_zero,a.c_desc_no,b.n_itmjob,a.i_vendor,c.bus_name   ")
			   .append(" from lan:serv_zerodt a ,lan:serv_boq b,lan:stpvendr c ")
		       .append(" where a.i_docno =? and a.i_itmjob = b.i_itmjob ")
			   .append(" and a.i_vendor = c.vend_code ")
			   .append(" order by a.i_seq,a.i_itmjob   ");
			pstmt = conn.prepareStatement(sql.toString()); 
		  	pstmt.setString(1, iDocNo);//iDocNo
			rs = pstmt.executeQuery();
			//System.out.println("-->SQL#4:"+sql);
			while(rs.next()){
				strList = new ArrayList();
				strList.add(0,doString.checkString(rs.getString("i_seq"),""));//i_seq
				strList.add(1,doString.checkString(rs.getString("i_itmjob"),""));//i_itmjob
				strList.add(2,doString.checkString(rs.getString("i_docno"),""));//i_docno
				strList.add(3,doString.checkString(rs.getString("f_remark"),""));//f_remark
				strList.add(4,doString.checkString(rs.getString("n_itmjob"),""));//n_itmjob
				strList.add(5,doString.checkString(rs.getString("i_vendor"),""));//i_vendor
				strList.add(6,doString.checkString(rs.getString("bus_name"),""));//bus_name		
				strList.add(7,doString.checkString(rs.getString("f_zero"),""));//bus_name
				strList.add(8,doString.checkString(rs.getString("c_desc_no"),""));//c_desc_no
				 //a.i_seq,a.i_itmjob,a.i_docno,a.f_remark,b.n_itmjob,a.i_vendor,c.bus_name 
				resultDt.add(strList);				
			}
		  	rs.close();
		  	
			/****************************Select causeYesDDL for Yese
			 *  select * from lan:serv_xstd 
 			 * where i_type= '00'  and i_code <=50
 			 * order by i_code 
			 * **************************/
		  	sql.delete(0,sql.length());
			sql.append(" Select i_code,n_desc from lan:serv_xstd ")
				.append(" Where i_type= '00'  and i_code <=50 ")
				.append(" Order by i_code ");
			pstmt = conn.prepareStatement(sql.toString()); 
			rs = pstmt.executeQuery();
			//System.out.println("-->SQL#5:"+sql);
			while(rs.next()){
				strList = new ArrayList();
				strList.add(0,  doString.checkString(rs.getString("i_code"),""));
				strList.add(1,  doString.checkString(rs.getString("n_desc"),""));
				causeYesDDL.add(strList);				
			}
		  	rs.close();	  
		  	
			/*****************************Select causeNoDDL for No
			 * select * from lan:serv_xstd 
 			 * where i_type= '00'  and i_code >=50
 			 * order by i_code 
			 * ***************************/
		  	sql.delete(0,sql.length());
		  	sql.append(" Select i_code,n_desc from lan:serv_xstd ")
		  		.append(" Where i_type= '00'  and i_code >=50 ")
		  		.append(" Order by i_code ");
			pstmt = conn.prepareStatement(sql.toString()); 
			rs = pstmt.executeQuery();
			//System.out.println("-->SQL#5:"+sql);
			while(rs.next()){
				strList = new ArrayList();
				strList.add(0,  doString.checkString(rs.getString("i_code"),""));
				strList.add(1,  doString.checkString(rs.getString("n_desc"),""));
				causeNoDDL.add(strList);				
			}
		  	rs.close();	  
		  	//****************************Select Remark List Description ***************************
		  	sql.delete(0,sql.length());
			sql.append(" select  b.i_seq,a.c_itmjob,a.i_itmjob_area,c.n_desc   ")
				 .append(" from lan:serv_docdt a,lan:serv_zerodt b ,lan:serv_xstd c  ")
				 .append(" where a.i_docno = b.i_docno and a.i_itmjob = b.i_itmjob  ")
				 .append(" and a.i_itmjob_area = b.i_itmjob_area ")
				 .append(" and b.i_itmjob_area = c.i_code  ")
				 .append(" and c.i_type = '01'  ")
				 .append(" and b.i_docno  = ?  order by b.i_seq");
			pstmt = conn.prepareStatement(sql.toString());
			pstmt.setString(1, iDocNo);//iDocNo
			rs = pstmt.executeQuery();
			//System.out.println("-->SQL#6:"+sql);
			while(rs.next()){
				strList = new ArrayList();
				strList.add(0,  doString.checkString(rs.getString("i_seq"),""));//i_seq
				strList.add(1,  doString.checkString(rs.getString("c_itmjob"),""));//c_itmjob
				strList.add(2,  doString.checkString(rs.getString("i_itmjob_area"),""));//i_itmjob_area
				strList.add(3,  doString.checkString(rs.getString("n_desc"),""));//n_desc
				// b.i_seq,a.c_itmjob,a.i_itmjob_area,c.n_desc
				remarkDt.add(strList);				
			}
		  	rs.close();	
			//**************************************************************************	
		  	//Modify by pradoem 2014.05.14
		  	String F_CAN = "";
   		  	sql.delete(0,sql.length());
			sql.append(" Select  f_status From lan:serv_dochd ")
				.append(" Where i_docno = ?  and  f_status = 'CAN' ");
			pstmt = conn.prepareStatement(sql.toString()); 
		  	pstmt.setString(1, iDocNo);//iDocNo
			rs = pstmt.executeQuery();
			if(rs.next()){ //CASE :CAN
				F_CAN = doString.checkString(rs.getString("f_status"),"");
			}
			//CASE:Not CAN
		  	rs.close();
		  	//--------------------------------------------------------------------------
	
		  	 request.setAttribute("list",list);
		  	 request.setAttribute("F_CAN",F_CAN);
		  	 request.setAttribute("fStatus",fStatus);
		  	 request.setAttribute("remarkDt",remarkDt);
		  	 request.setAttribute("DIFF_DAY",DIFF_DAY);
		  	 
		  	 session.setAttribute("resultDt",resultDt);
		  	 session.setAttribute("causeYesDDL", causeYesDDL);
		  	 session.setAttribute("causeNoDDL", causeNoDDL);
		  	 //request.setAttribute("selProj", null);		 
		  	 //System.out.println("doFetchingData ->successfully.");	  	
	   		 String tarGetUrl ="/SERV_Zerodefect_View.jsp";
	   		 RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			 dispatcher.forward(request,response);			

        }catch(Exception e){

			System.err.println("!!! doFetchingData , " +sysName+":"+ cName + " : " + e.getMessage());
			System.err.println("!!! SQL Exception: "+sql.toString());		
			msgTxt = "doFetchingData , " +sysName+":"+ cName + " : " + e.getMessage();
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
	
	//-------Print Request parameter
	private void GetParamRQ(HttpServletRequest request){
			Enumeration <String> paramName = (Enumeration<String>) request.getParameterNames();
			 while (paramName.hasMoreElements()) {
			       String element = (String) paramName.nextElement();
			       System.out.println(element + " = " + request.getParameter(element));
			}
	 }

}