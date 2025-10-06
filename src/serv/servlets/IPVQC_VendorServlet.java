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
* Servlet implementation class for Servlet: IPVQC_VendorServlet
* create by : pradoem wonkraso
* date time: 2018.02.07
* comment:
*/
 public class IPVQC_VendorServlet extends  DBServlet{
		/* (non-Java-doc)
		* @see javax.servlet.http.HttpServlet#HttpServlet()
		 */
		String sysName = "LHServ";
		String clazzName = new String(this.getClass().getName() + ".performTask :");	

		public IPVQC_VendorServlet() {
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
				  }else if(command.equals("edit")){
					this.doFormLoadData(request, response, user);
				  }else if(command.equals("update")){
					this.doFormUpdate(request, response, user);
				  } else if(command.equals("delete")){
					this.doFormDelete(request,response,user);  
				  }
			}catch(Exception e){
				e.printStackTrace();
				System.out.println(sysName+":"+clazzName +" "+e.toString());		
			}
		}  
		
		//*****	method doFormLoadData criteria vendorId
		protected void doFormLoadData(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
			// TODO Auto-generated method stub
			response.setContentType("text/html; charset=TIS-620");
			Connection conn = null;
			ServletContext context = getServletContext();
			HttpSession session = request.getSession(false);	
			String msgTxt = "";// Constants.APP_PATH+Constants.SAVE_PAGE;
			String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";	
	        try{
	        	//System.out.println("doFormLoadData ->Starting.");
				//Open connection
				if (ds == null){getDS();}			
				conn = ds.getConnection();
				conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
				conn.setAutoCommit(true);	

	  			String vendorId	 = request.getParameter("vendorId")==null?"": request.getParameter("vendorId").toString();
	  			
	  			HashMap hMapData = GetHashIPVQC_VENDOR(conn, vendorId);
				
	  			request.setAttribute("vendorId", hMapData.get("xI_VENDOR").toString());
	  			request.setAttribute("vendorName",hMapData.get("xN_VENDOR").toString());
				String tarGetUrl ="/IPVQC_Vendor_EditForm.jsp";
		   		RequestDispatcher dispatcher = context.getRequestDispatcher(tarGetUrl);
				dispatcher.forward(request,response);	
				
				//Close Connection
				conn.close();
				conn= null;
			}catch(Exception e){
				System.out.println("!!! doFormLoadData , " +sysName+":"+ clazzName + " : " + e.getMessage());	
				msgTxt = "doFormLoadData , " +sysName+":"+ clazzName + " : " + e.getMessage();
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
		
		//*****	method doFormDelete criteria projectDDL
		protected void doFormDelete(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
			// TODO Auto-generated method stub
			response.setContentType("text/html; charset=TIS-620");
			Connection conn = null;
			//ServletContext context = getServletContext();
			HttpSession session = request.getSession(false);	
			String errorCode = "99";	
			String msgTxt = "";

			String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";		
			String SUCCESS_PAGE = request.getContextPath()+"/save_ok.jsp?redirect_url=IPVQC_Vendor_List.jsp?txtVendor=";
		
	        try{
	        	//System.out.println(("doFormDelete ->Starting.");
				//Open connection
				if (ds == null){getDS();}			
				conn = ds.getConnection();
				conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
				conn.setAutoCommit(true);	

				String vendorId = doString.checkString(request.getParameter("vendorId"),"");
				if(vendorId.length()>0){
					DeleteIPV_QCVENDOR(conn, vendorId);
				}
				response.sendRedirect(SUCCESS_PAGE);
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
		 //*****method doFormUpdate criteria projectDDL
		protected void doFormUpdate(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
			// TODO Auto-generated method stub
			//response.setContentType("text/html; charset=TIS-620");
			Connection conn = null;
			ServletContext context = getServletContext();
			HttpSession session = request.getSession(false);		

			String errorCode = "99";	
			String msgTxt = "";
			String ERROR_PAGE 	= request.getContextPath()+"/save_ok.jsp?redirect_url=SERV_Home.jsp&error=true&other_msg=";		
			String SUCCESS_PAGE = request.getContextPath()+"/save_ok.jsp?redirect_url=IPVQC_Vendor_List.jsp?txtVendor=";
		
	        try{
	        	 //System.out.println("doFormUpdate ->Starting.");
	        	 //printOutParam(request,"===FormSubmit===");
	 			//----------Open connection
				//Open connection
				if (ds == null){getDS();}			
				conn = ds.getConnection();
				conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	  			conn.setAutoCommit(true);
	            //-------------------------
	  			String nVendor	 = request.getParameter("nVendor")==null?"": request.getParameter("nVendor").toString();//nVendor		
	  			String vendorId	 = request.getParameter("vendorId")==null?"": request.getParameter("vendorId").toString();//vendorId
	  			
	  			//***************************************************************************/		
	  			UpdateIPV_QCVENDOR(conn, vendorId, nVendor, user.getEmpId());
			  	//System.out.println(("doFormUpdate ->successfully.");	  	

				response.sendRedirect(SUCCESS_PAGE+nVendor);
				/****** Clear *******/
				conn.close();
				conn = null;
				return;
			}catch(Exception e){
				System.out.println("!!! doFormUpdate , " +sysName+":"+ clazzName + " : " + e.getMessage());	
				msgTxt = "doFormUpdate , " +sysName+":"+ clazzName + " : " + e.getMessage();
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
		 //*****method doFormAdd criteria projectDDL
		protected void doFormAdd(HttpServletRequest request, HttpServletResponse response,User user) throws ServletException, IOException{
			// TODO Auto-generated method stub
			//response.setContentType("text/html; charset=TIS-620");
			Connection conn = null;
			ServletContext context = getServletContext();
			HttpSession session = request.getSession(false);		

			String errorCode = "99";	
			String msgTxt = "";
			String ERROR_PAGE 	= request.getContextPath()+"/IPVQC_Vendor_List.jsp";		
			String SUCCESS_PAGE = request.getContextPath()+"/save_ok.jsp?redirect_url=IPVQC_Vendor_List.jsp?txtVendor=";
  			String savePage = Constants.SAVE_PAGE;
  			PrintWriter out = response.getWriter();
	        try{
	        	 //System.out.println("doFormLoad ->Starting.");
	        	 //printOutParam(request,"===FormSubmit===");
	 			//----------Open connection
				//Open connection
				if (ds == null){getDS();}			
				conn = ds.getConnection();
				conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	  			conn.setAutoCommit(true);
	            //-------------------------
	  			String nVendor	 = request.getParameter("nVendor")==null?"": request.getParameter("nVendor").toString();//LH:075			
	  			//***************************************************************************/		
	  			boolean isDup = IsDuplicateIPVQC_VENDOR(conn, nVendor);
	  			if(isDup){
	  				msgTxt = "!!! ชื่อบริษัทรับตรวจบ้านซ้ำ  '"+nVendor+"' ";
	  				GenRedirectCode(out, savePage, ERROR_PAGE, errorCode, msgTxt);
	  				//genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ "+e.getMessage());
	  				return;
	  			}
	  			InsertIPV_QCVENDOR(conn,nVendor,user.getEmpId());
			  	//System.out.println(("Submit ->successfully.");	  	

				response.sendRedirect(SUCCESS_PAGE+nVendor);
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
		
		private void DeleteIPV_QCVENDOR(Connection conn, String vendorId) {
			StringBuffer sql = new StringBuffer();
			PreparedStatement pstmt = null;
			try{
					//***************************************/
					sql.delete(0, sql.length());
					sql.append(" DELETE lan:IPV_QCVENDOR  ")
					   .append(" Where  I_VENDOR  = ? and I_COMPANY = 'LH' and I_PROJECT = '099' ");
					//System.out.println("-->DELETE SQL :"+sql.toString());
					pstmt = conn.prepareStatement(sql.toString()); 
					pstmt.setString(1, vendorId);
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
		private int UpdateIPV_QCVENDOR(Connection conn,String vendorId,String vendorName,String employId) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	        try{
	        	int i=1;
				/******************************************************/					
				sql.delete(0, sql.length());
				sql.append(" UPDATE IPV_QCVENDOR SET  N_VENDOR = ? , UPDATE_DATE = current  ,UPDATE_BY = ? ")
				   .append(" Where  I_VENDOR  = ? and I_COMPANY = 'LH' and I_PROJECT = '099' ");
				//System.out.println("-->UpdateIPV_QCVENDOR :"+sql.toString());
				pstmt = conn.prepareStatement(sql.toString());
				pstmt.setString(i++, vendorName);
				pstmt.setString(i++, employId);
				pstmt.setString(i++, vendorId);
				int intUdp = pstmt.executeUpdate();
	   		  	/********************************/		
			    //System.out.println("---Upate Okay..");				  	 
			  	return intUdp;			  	 
			}catch(Exception e){
				System.out.println("!!! UpdateIPV_QCVENDOR , " + e.getMessage());
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
		private int InsertIPV_QCVENDOR(Connection conn,String vendorName,String employId) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	        try{
	        	//initial parameter		
	        	
	        	String autoId = GenerateAutoID(conn);
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
					.append(" VALUES (  'LH',   '099',   ?,    ? ,  ?, 'A'  ) ");
					                 // 1    2    3    4     5   
			    //System.out.println("Insert SQL :"+sql.toString());
			    pstmt = conn.prepareStatement(sql.toString()); 	    
			    pstmt.setString(i++, autoId);
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
		
		private boolean IsDuplicateIPVQC_VENDOR(Connection conn,String vendorName) {
			StringBuffer sql = new StringBuffer();
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			boolean isResult = false;
			try{		
					//201320210005
					sql.delete(0,sql.length());
					sql.append(" Select N_VENDOR  ")
					   .append(" From lan:IPV_QCVENDOR ")
				       .append(" Where N_VENDOR = ?  ");
					pstmt = conn.prepareStatement(sql.toString()); 
					pstmt.setString(1,vendorName);
					rs = pstmt.executeQuery();
					if(rs.next()){
						doString.checkString(rs.getString("N_VENDOR"), "");
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
		public static HashMap GetHashIPVQC_VENDOR(Connection conn,String vendorId) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			HashMap hashMapData = null;
	        try{
	        	//initial parameter	
				/*************************************************/			
	        	//*****Find project by user login  
				sql.delete(0,sql.length());
				sql.append(" Select *  ")
				   .append(" From IPV_QCVENDOR ")
				   .append(" Where I_VENDOR = ? and I_COMPANY = 'LH' and I_PROJECT = '099' ");
				pstmt = conn.prepareStatement(sql.toString()); 
				pstmt.setString(1, vendorId);
				//System.out.println("SQL GetHashBrand :"+sql.toString());
				rs = pstmt.executeQuery();	
				if(rs.next()){
					hashMapData = new HashMap<String,String>();
					hashMapData.put("xI_COMPANY",doString.checkString(rs.getString("I_COMPANY"), ""));
					hashMapData.put("xI_PROJECT", doString.checkString(rs.getString("I_PROJECT"), ""));
					hashMapData.put("xI_VENDOR", doString.checkString(rs.getString("I_VENDOR"), ""));
					hashMapData.put("xN_VENDOR", doString.checkString(rs.getString("N_VENDOR"), ""));
					hashMapData.put("xSTATUS", doString.checkString(rs.getString("STATUS"), ""));
				}
				rs.close();	
				//**************************************************/
			  	//System.out.println("##GetHashIPVQC_VENDOR ->successfully.");				  	 
			  	return hashMapData;			  	 
			}catch(Exception e){
				System.out.println(" SQL 'GetHashIPVQC_VENDOR' Exception: "+sql.toString());		
				return hashMapData;
			}
			finally{			
				//clean up.
				try{
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
				}catch(Exception e){}
			}
		}
		
		private String GenerateAutoID(Connection conn) {
			// TODO Auto-generated method stub
			StringBuffer sql = new StringBuffer();
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			int id = 0;
			String tempId = "";
			try{		
					//201320210005
					sql.delete(0, sql.length());
					sql.append(" Select max(I_VENDOR) as maxid   From lan:IPV_QCVENDOR ")
						.append(" Where  I_COMPANY = 'LH' and I_PROJECT = '099' ");
					pstmt = conn.prepareStatement(sql.toString()); 
					rs = pstmt.executeQuery();
					if (rs.next()) {
						//0001
						id = rs.getInt("maxid");
					} // End if rs
					//System.out.println("-->id :"+id);
					if(id>0){
						id++;
						tempId = GenNextId(id);
					}else{
						tempId = "0001"; //201310210001
					}
					//System.out.println("-->MAX_ID :"+tempId);
					return tempId;
			}catch(Exception e){
				//e.fillInStackTrace();
				System.out.println(" SQL Exception (GenerateAutoID): "+sql.toString());	
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
		
		private static String GenNextId(int b){
			        String temp=""+b;
			        String newSp_id;
			        switch(temp.length()){ 
			          // case 1: newSp_id="00000"+temp; break; // case 2: newSp_id="0000"+temp; break; //case 1: newSp_id="000"+temp; break;
			           case 1: newSp_id="000"+temp; break;
			           case 2: newSp_id="00"+temp; break;
			           case 3: newSp_id="0"+temp; break;
			           default:newSp_id=temp;
			        }
			    return newSp_id;
		}
}