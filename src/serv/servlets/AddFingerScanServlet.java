package serv.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import serv.common.Constants;
import serv.common.User;

import com.lh.servlet.DBServlet;
import com.lh.util.doString;

/**
 * Servlet implementation class AddFingerScanServlet
 */
public class AddFingerScanServlet extends   DBServlet{
	private static final long serialVersionUID = 1L;
	String sysName = "LHServ";
	String cName = new String(this.getClass().getName() + ".performTask :");	
	
    /**
     * @see HttpServlet#HttpServlet()
     */
    public AddFingerScanServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

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
			doSaveFinger(request, response, user);				
		}catch(Exception e){
			e.printStackTrace();
			System.out.println(sysName+":"+cName +" "+e.toString());		
		}
	}

	//***doSaveFinger krub.
	protected void doSaveFinger(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
		// TODO Auto-generated method stub

		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		Statement stmt = null;

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
        	
        	/*String ParameterNames = "";
        	for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
        		ParameterNames = (String)e.nextElement();
        		System.out.println(ParameterNames + " = "+request.getParameter(ParameterNames));
        	}*/
        	
        	  //reasonDDL3
        	  //System.out.println("-->doSaveFinger ->Starting.");	
        	 // GetParamRQ(request);
        	  String IdCard = request.getParameter("IdCardNo")==null?"1":request.getParameter("IdCardNo"); //textbox บัตรปชช
        	  //System.out.println("Pass IdCard");   	  
        	  String NameSur = request.getParameter("NameSurname")==null?"1":request.getParameter("NameSurname"); //textbox ชื่อ-สกุล
        	  //System.out.println("Pass NameSur");
        	  String ProjCode = request.getParameter("ProjectCode").toUpperCase()==null?"1":request.getParameter("ProjectCode").toUpperCase(); //textbox รหัสโครงการ(ตอน request มาก้แปลงเป็นตัวพิมไหญ่ไปเลย)
        	  //System.out.println("Pass ProjCode");
        	  String Pos = request.getParameter("Position")==null?"1":request.getParameter("Position");//textbox ตำแหน่ง
        	  //System.out.println("Pass Pos");
        	  String Wage = request.getParameter("Wage")==null?"1":request.getParameter("Wage");//textbox ค่าแรง
        	  //System.out.println("Pass Wage");
        	  String Aff = request.getParameter("Affiliation")==null?"1":request.getParameter("Affiliation");//textbox สังกัด
        	  //System.out.println("Pass Aff");
        	  String mode = request.getParameter("mode")==null?"1":request.getParameter("mode");//textbox mode
        	  //System.out.println("Pass mode");
        	  //double ConvertWage = Double.parseDouble(Wage); //Convert Wage from String into Double
        	  //System.out.println("-->doSaveFinger ->Finished.");	

	 		 //Open connection
			 if (ds == null){getDS();}			
			 conn = ds.getConnection();
			 //conn.setAutoCommit(false);
	  
       	     //System.out.println("IF condition");	
			 if("del".equals(mode)){ //If mode='del' --> del. selected records
				 //System.out.println("Condition 1:Delete data");
				 
				 int i = 1;	
    			 sql.delete(0,sql.length());
    			 sql.append("delete lan:serv_tstaff where i_cardno = ? and i_header = ?" );
    			 pstmt = conn.prepareStatement(sql.toString()); 
    			 pstmt.setString(i++, IdCard);
    			 pstmt.setString(i++, ProjCode);
	 
    			 int y = pstmt.executeUpdate();
    			 //System.out.println("Delete Status:"+y);
    			 
			 }else{
				 
			     //System.out.println("Condition 2:Not del. (Not match in condition = 'del')");
			     //System.out.println("begin sql");	
           	     double ConvertWage = Double.parseDouble(Wage); //Convert Wage from String into Double

	             //Check duplicated information from IdCardNo and ProjectCode

				sql.append(" select i_cardno,i_header from lan:serv_tstaff where i_cardno = "+IdCard)
					 .append(" and i_header = "+" '"+ProjCode+"' ");
				      pstmt = conn.prepareStatement(sql.toString());
				      rs = pstmt.executeQuery();
				        
				 //System.out.println("Query executed");

			  String temp="";
			  String temp2=""; 
			  if(rs.next()){
				temp = doString.checkString(rs.getString("i_cardno"),"");
				temp2 = doString.checkString(rs.getString("i_header"),"");
			  }
			   
			  if(temp.equals("")&&temp2.equals("")){
		        	//insert
				  	//System.out.println("Begin insert");
				  	int i = 1;	
				  	sql.delete(0,sql.length());
				  	sql.append(" insert into lan: serv_tstaff(i_cardno  ,i_name  ,i_header  ,n_job ,  z_wage  , i_dept  ) ")
				  	.append(" values (?,?,?,?,?,?)  ");
				  	pstmt = conn.prepareStatement(sql.toString()); 
				  	//pstmt.setString(i++, user.getEmpId());//getUserID
				  	pstmt.setString(i++, IdCard);
				  	pstmt.setString(i++, NameSur);
				  	pstmt.setString(i++, ProjCode);
				  	pstmt.setString(i++, Pos);
				  	pstmt.setDouble(i++, ConvertWage);
				  	pstmt.setString(i++, "");
				  	
				  	int x = pstmt.executeUpdate();
				  	//System.out.println("Insert Status:"+x);	    			 
				  	//System.out.println("No duplicated records, inserted!");

		        }else if(!temp.equals("") && !temp2.equals("")){
	    			//System.out.println("Begin update");
	        		 int i = 1;	
	    			 sql.delete(0,sql.length());
	    			 sql.append(" update lan:serv_tstaff set i_cardno = ?  ,i_name = ?  ,i_header = ?  ,n_job = ? ,  z_wage = ? where i_cardno = "+IdCard+" and i_header = "+" '"+ProjCode+"' " );
	    			 pstmt = conn.prepareStatement(sql.toString()); 
	    			 pstmt.setString(i++, IdCard);
	    			 pstmt.setString(i++, NameSur);
	    			 pstmt.setString(i++, ProjCode);
	    			 pstmt.setString(i++, Pos);
	    			 pstmt.setDouble(i++, ConvertWage);
	    			 		    			 
	    			 int y = pstmt.executeUpdate();
	    			 //System.out.println("Update Status:"+y);
	    			 //System.out.println("Duplicated records, Update!");
		        }
			 }
			
			 
			 /********************************************************************/			 
			 /********************************************************************/	  	
   		  	 conn.close();
   		  	 conn = null;
 	  	  
	  	    //System.out.println("-->doUpdateRecord ->successfully.");		  	    
	   		String tarGetUrl = "/save_ok.jsp?&error=0&redirect_url=AddFingerScanForm.jsp";  //SERV_Index.jsp
	   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
			dispatcher.forward(request,response);		
		}catch(Exception e){			
			System.out.println("doUpdateRecord , " +sysName+":"+ cName + " : " + e.getMessage());
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
}





	
	
