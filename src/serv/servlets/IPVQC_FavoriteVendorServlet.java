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

import serv.common.Constants;
import serv.common.User;
import com.lh.servlet.DBServlet;
import com.lh.string.doString;
import java.util.*;

/**
* Servlet implementation class for Servlet: IPVQC_FavoriteVendorServlet
* create by : pradoem wonkraso
* date time: 2018.02.08
* comment:
*/
 public class IPVQC_FavoriteVendorServlet extends  DBServlet{
		/* (non-Java-doc)
		* @see javax.servlet.http.HttpServlet#HttpServlet()
		 */
		String sysName = "LHServ";
		String clazzName = new String(this.getClass().getName() + ".performTask :");	

		public IPVQC_FavoriteVendorServlet() {
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
				  if(command.equals("add")){		
					this.doFormAdd(request,response,user);				
				  }else if(command.equals("delete")){		
					this.doFormDelete(request,response,user);		
				  }
			}catch(Exception e){
				e.printStackTrace();
				System.out.println(sysName+":"+clazzName +" "+e.toString());		
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

			String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=IPVQC_FavoriteVendor_List.jsp&error=true&other_msg=";		
			String SUCCESS_PAGE = request.getContextPath()+"/save_ok.jsp?redirect_url=IPVQC_FavoriteVendor_List.jsp?";
		
	        try{
	        	//System.out.println(("doFormDelete ->Starting.");
				//Open connection
				if (ds == null){getDS();}			
				conn = ds.getConnection();
				conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
				conn.setAutoCommit(true);	
				
				String projectSel = doString.checkString(request.getParameter("projectDDL"),"");
				String txtVendor = doString.checkString(request.getParameter("txtVendor"),"");
				String param = "";
				if(projectSel.length()>0){
					param += "projectDDL="+projectSel;
				}
				if(txtVendor.length()>0){
					param += "|txtVendor="+txtVendor;
				}
				String comId = doString.checkString(request.getParameter("comId"),"");
				String projId = doString.checkString(request.getParameter("projId"),"");
				String vendorId = doString.checkString(request.getParameter("vendorId"),"");
				if(vendorId.length()>0){
					DeleteIPV_QCVENDOR(conn, comId,projId,vendorId);
				}
				response.sendRedirect(SUCCESS_PAGE+param);
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

		//*****method doFormAdd criteria projectDDL
		protected void doFormAdd(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
			// TODO Auto-generated method stub
			//response.setContentType("text/html; charset=TIS-620");
			Connection conn = null;
			ServletContext context = getServletContext();
			HttpSession session = request.getSession(false);		

			String SUCCESS_PAGE = request.getContextPath()+"/save_ok.jsp?redirect_url=IPVQC_FavoriteVendor_List.jsp?txtVendor=";
		
			String errorCode = "99";	
			String msgTxt = "";
			String ERROR_PAGE 	= request.getContextPath()+"/IPVQC_FavoriteVendor_List.jsp";		
			//String SUCCESS_PAGE2 = request.getContextPath()+"/IPVQC_Vendor_List.jsp?txtVendor=";
  			String savePage = Constants.SAVE_PAGE;
  			PrintWriter out = response.getWriter();
	        try{
	        	 //System.out.println("doFormLoad ->Starting.");
	        	 //printOutParam(request,"===Add Favorite ===");
	            
	  			//-------------------------
	  			String projSel	 = request.getParameter("projectDDL")==null?"": request.getParameter("projectDDL").toString();//LH:075			
	  			String []chkItemsSel = request.getParameterValues("chkItemsSel"); 
	  			if("".equals(projSel)){
	  				msgTxt = "!!! กรุณาเลือกโครงการ";
	  				//response.sendRedirect(ERROR_PAGE+msgTxt);
	  				GenRedirectCode(out, savePage, ERROR_PAGE, errorCode, msgTxt);
	  				return;
	  			}
	  			if(chkItemsSel==null || chkItemsSel.length==0){
	  				msgTxt = "!!! กรุณาเลือก Check Bok";
	  				//response.sendRedirect(ERROR_PAGE+msgTxt);
	  				GenRedirectCode(out, savePage, ERROR_PAGE, errorCode, msgTxt);
	  				return;
	  			}
	 			//----------Open connection
				//Open connection
				if (ds == null){getDS();}			
				conn = ds.getConnection();
				conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	  			conn.setAutoCommit(true);

		  	     if(chkItemsSel!=null && chkItemsSel.length>0){
	  				String [] tempArr = null;
	  				String delimiter = "\\:"; //chkItemsSel :1472-4:121:A4
	  				String []projArr = projSel.split(delimiter);
	  				boolean isDuplicate = false;
	  				for(int loop =0;loop<chkItemsSel.length;loop++){
	  					tempArr  = chkItemsSel[loop].split(delimiter);
	  					//System.out.println("chkItemsSel :"+chkItemsSel[loop]);				
	  					isDuplicate = IsDuplicateIPVQC_VENDOR(conn, projArr[0], projArr[1], tempArr[0]);
	  					if(!isDuplicate){ //Insert
	  						InsertIPV_QCVENDOR(conn, projArr[0], projArr[1], tempArr[0], tempArr[1], user.getEmpId());
	  					}
	  				}
	  			}    
	  			//***************************************************************************/		
				response.sendRedirect(SUCCESS_PAGE);
				/****** Clear *******/
				conn.close();
				conn = null;
				return;
			}catch(Exception e){
				System.out.println("!!! doFormAdd , " +sysName+":"+ clazzName + " : " + e.getMessage());	
				msgTxt = "doFormAdd , " +sysName+":"+ clazzName + " : " + e.getMessage();
				response.sendRedirect(ERROR_PAGE+msgTxt);
				return;
			}
			finally{			
				//clean up.
				/*synchronized(session){
					//session.invalidate();	
					session.removeAttribute(SS_projectList);
				}*/
				try{
					if(conn!=null){conn.close();}
				}catch(Exception e){}
			}
		} 
		
		private void DeleteIPV_QCVENDOR(Connection conn,String comId,String projId, String vendorId) {
			StringBuffer sql = new StringBuffer();
			PreparedStatement pstmt = null;
			try{
					//***************************************/
					sql.delete(0, sql.length());
					sql.append(" DELETE lan:IPV_QCVENDOR  ")
					   .append(" Where I_COMPANY = ? and I_PROJECT = ? and I_VENDOR  = ? ");
					//System.out.println("-->DELETE SQL :"+sql.toString());
					pstmt = conn.prepareStatement(sql.toString()); 
					pstmt.setString(1, comId);
					pstmt.setString(2, projId);
					pstmt.setString(3, vendorId);
					int delete = pstmt.executeUpdate();	
		   		  	/********************************/		
				    //System.out.println("##DeleteIPV_QCVENDOR : successfully. : "+delete);
		   		  	return;			
			}catch(Exception e){
				System.out.println("!!!DeleteIPV_QCVENDOR , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
		private int InsertIPV_QCVENDOR(Connection conn,String comId,String projId,String vendorId,String vendorName,String employId) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	        try{
	        	//initial parameter		
	        	int i=1;
				/******************************************************/					
				sql.delete(0, sql.length());
				sql.append(" INSERT INTO IPV_QCVENDOR ( ")
				    .append(" I_COMPANY,")//1
				    .append(" I_PROJECT ,")//2
					.append(" I_VENDOR,")//3
					.append(" N_VENDOR,")//4
					.append(" CREATE_BY ,  ")//5
					.append(" STATUS )  ")//5
					.append(" VALUES (  ?,   ?,   ?,    ? ,  ?, 'A'  ) ");
					                 // 1    2    3    4     5   
			    //System.out.println("Insert SQL :"+sql.toString());
			    pstmt = conn.prepareStatement(sql.toString()); 	  
			    pstmt.setString(i++, comId);
			    pstmt.setString(i++, projId);
			    pstmt.setString(i++, vendorId);
			    pstmt.setString(i++, vendorName);
			    pstmt.setString(i++, employId);
			    //System.out.println("---InsertIPV_QCVENDOR:"+sql.toString());
			    int intUpd = pstmt.executeUpdate();
			    //System.out.println("---Insert Okay..");
				//********************************************************/
			  	//System.out.println("##InsertIPV_QCVENDOR ->end.");				  	 
			  	return intUpd;			  	 
			}catch(Exception e){
				System.out.println("!!! InsertIPV_QCVENDOR , " + e.getMessage());
				System.out.println("!!! SQL Exception: "+sql.toString());		
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

		private boolean IsDuplicateIPVQC_VENDOR(Connection conn,String comId,String  projectId,String vendorId) {
			StringBuffer sql = new StringBuffer();
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			boolean isResult = false;
			try{		
					//201320210005
					sql.delete(0,sql.length());
					sql.append(" Select I_VENDOR  ")
					   .append(" From lan:IPV_QCVENDOR ")
				       .append(" Where I_COMPANY = ? and I_PROJECT = ?  and I_VENDOR = ? ");
					pstmt = conn.prepareStatement(sql.toString()); 
					pstmt.setString(1,comId);
					pstmt.setString(2,projectId);
					pstmt.setString(3,vendorId);
					rs = pstmt.executeQuery();
					if(rs.next()){
						doString.checkString(rs.getString("I_VENDOR"), "");
						isResult = true;
					} // End if rs
					
					return isResult;
			}catch(Exception e){
				e.fillInStackTrace();
				System.out.println(clazzName+":IsDuplicateIPVQC_VENDOR:"+e.toString());
				System.out.println(" SQL Exception: "+sql.toString());	
				return isResult;
			}
			finally{
				//clean up.
				try{
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
				}catch(Exception e){}
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