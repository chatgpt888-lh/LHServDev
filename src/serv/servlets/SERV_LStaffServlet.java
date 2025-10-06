package serv.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import serv.common.User;

import com.lh.servlet.DBServlet;
import com.lh.util.doString;

/**
 * Last Modify by : Nutruethai
 * date :2021.07.1
 * desc :coding servlet for SERV_Lstaff function.
 * 		[selectorList 			> data in dropdown list selec for i_com and i_pro
 * 		 searchList   			> filter from dropdown list after click GO!
 * 		 Editform    			> query data show on edit page
 * 		 UpDateInfo   			> Edit project data and update
 * 		 Addproject   			> create new project if i_project still avaliable.
 * 		 VALIDATED FUNCTION 	> get i_employ name/id  i_vendor name/id ]
 * 		 VALIDATED FUNCTION for AJAX
 * ----------------------------------------
 */

 public class SERV_LStaffServlet extends  DBServlet{
	    /* (non-Java-doc)
	     *  
		 * @see javax.servlet.http.HttpServlet#HttpServlet()
		 */
		public SERV_LStaffServlet() {
			super();
		}   	
		
		
		String sysName = "LHServLStaff";
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
				  if(command.equals("FrmLoad")){		 // for put in button link to serv_lstaff page (index page)
					doLoadForm(request,response);				
				  }else if(command.equals("makeList")){
					doLoadList(request,response);  
				  }else if(command.equals("searchLStaff")){
					doListSearch(request,response);  
				  }else if(command.equals("addInfo")){
					doAddInfo(request,response);  
				  }else if(command.equals("EditProject")){
					doLoadEditFrm(request,response);  
			      }else if(command.equals("updateInfo")){
			    	doUpdateInfo(request,response);  
			      } else if(command.equals("delProject")) {
			    	doDeleteProject(request,response);
			      } else if(command.equals("checkEmployId")) {
			    	String employName =doCheckEmployId(request,response);
			    	out = response.getWriter();
					 out.println(employName);
		          } else if(command.equals("chkProId")) {
				    String result =  doCheckProId(request,response);
				    out = response.getWriter();
				    // result="Y:200";
				    out.println(result);  
		          }else if(command.equals("checkVendorId")) {
				   String vendorName =checkVendorId(request,response);
				    out = response.getWriter();
					out.println(vendorName);
			      } 
				  
			}catch(Exception e){
				e.printStackTrace();
				System.out.println(e.toString());		
			}
			finally{
				if(out != null){
				out.close();
			 }
			}
		}



protected String doCheckProId(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	
	Connection conn = null;
	String projectStatus = "N:200";
	
	System.out.println("check project status >> START");
	String[] parts = request.getParameter("comId").split("-");
	String iComs= parts[0]; //LH
	String iProjs = parts[1]; //221

	//System.out.println("icom value = "+ iComs);
	//System.out.println("iproj value = "+ iProjs);
	
	
	
//==================Check projectStatus&&Data receieved======================//		
	
	
	try {
 		System.out.println("doCheckProId >> START");
 		
 		//----------Open connection Pool
			if (ds == null){
				getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
         //-------------------------
			
			
			//System.out.println("check boolean"+result);
			if(doCheckProject(conn,iComs ,iProjs)){
				//Y:200
				projectStatus = "Y:200";
			}
				
			//System.out.println("project Status : "+projectStatus);
			conn.close();
			
		
			return projectStatus;
			
	 }catch(Exception e){
		e.printStackTrace();
		System.out.println(e.toString());	
		return null;
	}
	finally{
		try {
			if (conn != null) {
				conn.close();
			}
			
		 } catch (Exception e) {
		}
		
	}

		
}


protected String checkVendorId(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

	Connection conn = null;
	String vendorName = "invalid:200";
	String vendorId = request.getParameter("vendorId");
	//System.out.println("vendor id receieve : "+vendorId);
	
	try {
 		System.out.println("doCheckVendorId >> START");
 		
 		//----------Open connection Pool
			if (ds == null){
				getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
         //-------------------------
		
			
			if(vendorId == null){
				
				vendorName = "";
			}
			if(GetVendorId(conn, vendorId) != "invalid") {
				
				vendorName = GetVendorName(conn,vendorId)+":200";
				
			return vendorName;
			}
			System.out.println("vendorname = "+vendorName);
			conn.close();
			return vendorName;	
			
			
	 }catch(Exception e){
		e.printStackTrace();
		System.out.println(e.toString());	
		return null;
	}
	finally{
		try {
			if (conn != null) {
				conn.close();
			}
			
		 } catch (Exception e) {
		}
		
	}

		
}


protected String doCheckEmployId(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

	Connection conn = null;
	String employName = "invalid:200";
	String employId = request.getParameter("employId");
	//Statement stmt = null;
	
	//System.out.println("employ id check receieve : "+employId);
	
	
	
	try {
 		System.out.println("doCheckEmploy >> START");
 		
 		//----------Open connection Pool
			if (ds == null){
				getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
			//stmt =conn.createStatement();
         //-------------------------
			
			
			if(employId ==  null){
				
				employName = "";
			}
			if(GetEmployId(conn, employId) != "invalid") {
				
			 employName = GetEmployName(conn,employId)+":200";
				
			return employName;
			}
			//System.out.println("employname = "+employName);
			conn.close();
			return employName;	
			
			
	 }catch(Exception e){
		e.printStackTrace();
		System.out.println(e.toString());	
		return null;
	}
	finally{
		try {
			if (conn != null) {
				conn.close();
			}
			
		 } catch (Exception e) {
		}
	}

		
}


//prepared data  to editpage
protected void doLoadEditFrm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	
	Connection conn = null;
	StringBuffer sql = new StringBuffer();
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	//Statement stmt=null;
	try {
	System.out.println("doLoadEditFrm >> START");
	
	//----------Open connection Pool
		if (ds == null){
			getDS();}			
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		//stmt = conn.createStatement();
  //-------------------------
		//List<HashMap> listEditData = new ArrayList<HashMap>();
		HashMap<String,String> hVa = null;
		
		//System.out.println("icom value = "+name);
		sql.delete(0, sql.length());
		sql.append("select * from lan:serv_lstaff")			
			.append(" where i_company = ? ")  
			.append(" and i_project =  ? " );
			///////////////////////////////////////////////////////////////////////////////////////
			//																					//
			// display lstaff >> iCom , iProj , iEmployM1 , iEmployM2 ,iEmployM3, iEmployS1		//
			// iEmployS2 ,iEmployS3 ,iZone , f_tk (Y/N)	,iVendor1 ,iVendor2	 and get employ name//								//
			//																					//
			//////////////////////////////////////////////////////////////////////////////////////
			pstmt = conn.prepareStatement(sql.toString());
			pstmt.setString(1, request.getParameter("iComId"));
			pstmt.setString(2, request.getParameter("iProject"));
		
		//System.out.println("SQL :"+ sql.toString());
		rs = pstmt.executeQuery();
		
		
		
		if(rs.next()){
			hVa = new HashMap<String,String>();
			hVa.put("iCOM_IDe", rs.getString("i_company"));
			hVa.put("iPROJ_IDe",rs.getString("i_project"));
			hVa.put("nPROJe",GetProjectName(conn,rs.getString("i_company"),rs.getString("i_project")));
			hVa.put("zones",doString.checkString(rs.getString("i_zone"),""));
			
			hVa.put("iEmploys",doString.checkString(rs.getString("i_employ_z"),""));
			hVa.put("iEmployName",GetEmployName(conn,rs.getString("i_employ_z")));
			
			hVa.put("iEmployM1",doString.checkString(rs.getString("i_employ_m1"),""));
			hVa.put("iEmployM1Name",GetEmployName(conn,rs.getString("i_employ_m1")));
			
			hVa.put("iEmployM2",doString.checkString(rs.getString("i_employ_m2"),""));
			hVa.put("iEmployM2Name",GetEmployName(conn,rs.getString("i_employ_m2")));
			
			//hVa.put("iM3",doString.checkString(rs.getString("i_employ_m3"),""));
			hVa.put("iEmployS1",doString.checkString(rs.getString("i_employ_s1"),""));
			hVa.put("iEmployS1Name",GetEmployName(conn,rs.getString("i_employ_s1")));
			
			hVa.put("iEmployS2",doString.checkString(rs.getString("i_employ_s2"),""));
			hVa.put("iEmployS2Name",GetEmployName(conn,rs.getString("i_employ_s2")));
			
			//hVa.put("iS3",doString.checkString(rs.getString("i_employ_s3"),""));
			hVa.put("ftk",doString.checkString(rs.getString("f_tk"),""));
			
			hVa.put("iEmployApp1",doString.checkString(rs.getString("i_employ_app1"),""));	
			hVa.put("iEmployApp1Name",GetEmployName(conn,rs.getString("i_employ_app1")));
			hVa.put("iVen1",doString.checkString(rs.getString("i_vendor1"),""));
			hVa.put("iVenName",GetVendorName(conn, doString.checkString(rs.getString("i_vendor1"),"")));
//			
			//hVa.put("iVen2",doString.checkString(rs.getString("i_vendor2"),""));
			//listEditData.add(hVa);
			//System.out.println("PASS");
		}
		request.setAttribute("hashLstaff", hVa);
		request.getRequestDispatcher("/SERV_LStaff_Update.jsp").forward(request, response);
		System.out.println("===go to SERV_LStaff_Edit for search==");	
		rs.close();
		conn.close();
		
		
				
	
	}catch(Exception e){
	e.printStackTrace();
	System.out.println("SERVedit"+e.toString());	
	
	
}
finally{
	try {
		if (rs != null) {
			rs.close();
		}
		if (pstmt != null) {
			pstmt.close();
		}
		if (conn != null) {
			conn.close();
		}
	 } catch (Exception e) {
	}
}
	
}

 
private boolean doCheckProject (Connection conn, String iCom ,  String iProj) throws ServletException, IOException {
	StringBuffer sql = new StringBuffer();	
	PreparedStatement pstmt = null;
	ResultSet rset = null;
 try{
 	//initial paramter	
	    System.out.println("docheckprojectAvaliable >> START");
 		Boolean checkProject = true;
		/*************************************************/	
 		sql.delete(0,sql.length());
 		sql.append("select i_project from lan:serv_lstaff ")
 			.append("where i_company = ? and i_project = ?");
 	
 		
 		pstmt = conn.prepareStatement(sql.toString()); 
 		pstmt.setString(1, iCom );
		pstmt.setString(2, iProj );
		System.out.println("icom check  "+ iCom);
		System.out.println("iproj check = "+ iProj);
		
		//System.out.println("Find StatusProject (null/not) SQL :"+sql.toString());
		rset = pstmt.executeQuery()	;
		
		if(rset.next()){
			System.out.println("have project");
			checkProject = false ;
		}
		
		rset.close();		
		
		
		//**************************************************/			  	 
	  	return checkProject;			  	 
	}catch(Exception e){
		//System.out.println("!!!GetEmployIdByAgentId , " +sysName+":"+ clazzName + " : " + e.getMessage());
		
		System.out.println("Exception: "+ e.toString());		
		return false;
	}
	finally{			
		//clean up.
		try{
			if(rset!=null){rset.close();}
			if(pstmt!=null){pstmt.close();}
		}catch(Exception e){}
	}
}

protected void doLoadList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	Connection conn = null;
	 try{
		 System.out.println("===============doLoadForm===============");
		 //	----------Open connection Pool
			if (ds == null){
					getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
	    //-------------------------
		request.setAttribute("listData", doListSelectorFollowUpTurnkey(conn));
		request.getRequestDispatcher("/SERV_LStaff_List.jsp").forward(request, response);
		System.out.println("===go to SERV_LStaff_List==");	
	 }catch (Exception e){
			System.out.println ("failed load form");			
	}
	finally{
			//clean up.
			try{
				if(conn!=null){conn.close();}
			}catch(Exception e){}
	}
}

//listProjectAll()
protected List doListSelectorFollowUpTurnkey(Connection conn) {
		// TODO Auto-generated method stub
		
		
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		
		try {
 	
		
			List<HashMap> listData = new ArrayList<HashMap>();
			HashMap<String,String> hVa = null;
		
			sql = sql.delete(0, sql.length());
			sql.append("select a.i_company, a.i_project, b.n_project[1,20]")
				.append(" from lan:acsbudgh a , lan:acxprojt b")
				.append(" where a.d_year = year(today)+543 AND a.i_budg_type = 9 ")
				.append(" AND a.i_company = b.i_company AND a.i_project = b.i_project")
				.append(" order by 1,2");
			
			//System.out.println("SQL :"+ sql.toString());
			pstmt = conn.prepareStatement(sql.toString());
	
			rs = pstmt.executeQuery();
			while(rs.next()){
				hVa = new HashMap<String,String>();
				hVa.put("iCOM_ID", doString.checkString(rs.getString("i_company"),""));
				hVa.put("iPROJ_ID",doString.checkString(rs.getString("i_project"),""));
				hVa.put("nPROJ",doString.DisplayThai(doString.checkString(rs.getString("n_project"),"")));
				listData.add(hVa);
				
			
			}
			rs.close();
			
			return listData;
			
			
			
	 }catch(Exception e){
		e.printStackTrace();
		System.out.println(e.toString());	
		return null;
	}
	finally{
		try {
			if (rs != null) {
				rs.close();
			}
			if (pstmt != null) {
				pstmt.close();
			}
		 } catch (Exception e) {
		}
	}
		
	}

private static String GetProjectName(Connection conn, String comId , String projectId) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
  try{
  	//initial paramter	   
	//System.out.println("dogetProjectName >> START");
  	String projectName = "";
			/*************************************************/	
  	sql.delete(0,sql.length());
			sql.append("select n_project from lan:acxprojt where i_company = ? and i_project = ?");
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, comId);	
			pstmt.setString(2, projectId);	
			//System.out.println("Find projectName SQL :"+sql.toString());
			rs = pstmt.executeQuery();	
			if(rs.next()){
				projectName = doString.DisplayThai(rs.getString("n_project"));
			}
			rs.close();		   			
			//**************************************************/			  	 
		  	return projectName;			  	 
		}catch(Exception e){
			//System.out.println("!!!GetEmployIdByAgentId , " +sysName+":"+ clazzName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
			return "null";
		}
		finally{			
			//clean up.
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
			}catch(Exception e){}
		}
	}

private String GetEmployName(Connection conn, String employId) {
	StringBuffer sql = new StringBuffer();	
	Statement stmt = null;
	ResultSet rs = null;
	
 try{
 	stmt = conn.createStatement();
	 if("".equals(employId)|| null == employId){
		 return employId="" ;
	 }
	 //initial paramter	   
	 //System.out.println("doGetEmployName >> START");
 	String employeeName = "";
    /*************************************************/	
	sql.delete(0,sql.length());
	sql.append("select n_nemploy_th from docflow:acemploy where i_employ = '")
	    .append(employId).append("' ");
	//System.out.println("SQL : "+ sql.toString());
    rs = stmt.executeQuery(sql.toString());								
    if (rs.next()) {
	 employeeName = doString.DisplayThai(rs.getString("n_nemploy_th"));
    }
		rs.close();		 
		rs =null;
		stmt.close();
		stmt = null;
		//**************************************************/			  	 
	  	return employeeName;			  	 
	}catch(Exception e){
		//System.out.println("!!!GetEmployIdByAgentId , " +sysName+":"+ clazzName + " : " + e.getMessage());
		System.out.println("Exception: "+e.toString());		
		return "";
	}
	finally{			
		//clean up.
		try{
			if(rs!=null){rs.close();}
			//if(pstmt!=null){pstmt.close();}
		}catch(Exception e){}
	}
}
 

private static String GetEmployId(Connection conn, String employId) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		
     try{
    	 //System.out.println("dogetEmployId >> START");
    	String employeeId = "";
     	//initial paramter	   
    	
    	if(employId == null || "".equals(employId)){
    		
    	return employeeId = "";
    	}
    	if(employId != null){
			/*************************************************/	
     	sql.delete(0,sql.length());
			sql.append("select i_employ from docflow:acemploy where i_employ = ?");
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, employId);	
			//System.out.println("Find EmployId SQL :"+sql.toString());
			rs = pstmt.executeQuery();	
			if(rs.next()){
				employeeId =  rs.getString("i_employ");
			} else {
				employeeId =  "invalid";
			}
			rs.close();		   			
			//**************************************************/			  	 
		  	return employeeId;			  	 
		}
     }catch(Exception e){
			//System.out.println("!!!GetEmployIdByAgentId , " +sysName+":"+ clazzName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
			return "invalid";
		}
		finally{			
			//clean up.
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
			}catch(Exception e){}
		}
	return employId;
	}

private static String GetVendorId(Connection conn, String vendorrId) {
	StringBuffer sql = new StringBuffer();	
	PreparedStatement pstmt = null;
	ResultSet rs = null;
 try{
 	//initial paramter	   
	//System.out.println("vendorId = " + vendorrId);
 	String vendorId = "";
		/*************************************************/	
 	if(vendorrId == null || vendorrId == ""){
 		return vendorId = "";
 		
 	}
 	if(vendorId != null){
 	sql.delete(0,sql.length());
		sql.append("select vend_code from lan:stpvendr where vend_code = ? ");
		pstmt = conn.prepareStatement(sql.toString()); 
		pstmt.setString(1, vendorrId);	
		//System.out.println("Find VendorId SQL :"+sql.toString());
		rs = pstmt.executeQuery();	
		if(rs.next()){
			//System.out.println("have vendorId");
			vendorId =  rs.getString("vend_code");
		} else {
			vendorId = "invalid";
		}
 	
		rs.close();		   			
		//**************************************************/			  	 
	  	return vendorId;
 	}
	}catch(Exception e){
		//System.out.println("!!!GetEmployIdByAgentId , " +sysName+":"+ clazzName + " : " + e.getMessage());
		System.out.println(" SQL Exception: "+sql.toString());		
		return "invalid";
	}
	finally{			
		//clean up.
		try{
			if(rs!=null){rs.close();}
			if(pstmt!=null){pstmt.close();}
		}catch(Exception e){}
	}
return vendorrId;

}
 
private static String GetVendorName(Connection conn, String vendorId) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
  try{
  	//initial paramter	   
  	String vendorName = "";
			/*************************************************/	
  	sql.delete(0,sql.length());
			sql.append("select bus_name from lan:stpvendr where vend_code = ? ");
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, vendorId);	
			//System.out.println("Find vendorName SQL :"+sql.toString());
			rs = pstmt.executeQuery();	
			if(rs.next()){
				vendorName =  doString.DisplayThai(rs.getString("bus_name"));
			}
			rs.close();		   			
			//**************************************************/			  	 
		  	return vendorName;			  	 
		}catch(Exception e){
			//System.out.println("!!!GetEmployIdByAgentId , " +sysName+":"+ clazzName + " : " + e.getMessage());
			//System.out.println(" SQL Exception: "+sql.toString());		
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
 


 
 protected void doListSearch(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	 
		Connection conn = null;
		StringBuffer sql = new StringBuffer();

		PreparedStatement pstmt = null;
		ResultSet rs = null;
		ResultSet rs1 = null;
		
		Statement stmt = null;
	
		
		try {
		System.out.println("doSearchLStaff >> START");
		
		//----------Open connection Pool
			if (ds == null){
				getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
			stmt = conn.createStatement();
      //-------------------------
			List<HashMap> listSearchData = new ArrayList<HashMap>();
			HashMap<String,String> hVa = null;
			String comId = request.getParameter("iCOM_ID"); //
			String tmpEmp = "";
			
			
			//System.out.println("icom value = "+name);
			sql.delete(0, sql.length());
			sql.append("select a.i_company , a.i_project , a.i_employ_z , a.i_employ_m1 , a.i_employ_m2 , a.i_employ_s1 , a.i_employ_s2")
			.append(" , a.i_vendor1 , a.i_zone , a.f_tk , a.i_employ_app1 , b.n_project  from lan:serv_lstaff a, lan:acxprojt b  ") 	
			.append(" where a.i_company = b.i_company and a.i_project = b.i_project  ");
			if(comId.equals("all")){
				//not where
				request.setAttribute("all", "all");
				sql.append(" order by i_company , i_project ");
				pstmt = conn.prepareStatement(sql.toString());
				
			}else {
				String[] parts = comId.split("-");
				String iCom= parts[0]; //LH
				String iProj = parts[1]; //221
				
				//System.out.println("icom value = "+ iCom);
				//System.out.println("iproj value = "+ iProj);
				
				sql.append(" and a.i_company = ? ")  
				   .append(" and a.i_project =  ? " );
				///////////////////////////////////////////////////////////////////////////////////////
				//																					//
				// display lstaff >> iCom , iProj , iEmployM1 , iEmployM2 ,iEmployM3, iEmployS1		//
				// iEmployS2 ,iEmployS3 ,iZone , f_tk (Y/N)	,iVendor1 ,iVendor2									//
				//																					//
				//////////////////////////////////////////////////////////////////////////////////////
				pstmt = conn.prepareStatement(sql.toString());
				pstmt.setString(1, iCom);
				pstmt.setString(2, iProj);
				
				request.setAttribute("icom", iCom);
				request.setAttribute("ipro", iProj);
			
			}
			boolean isRec = false;
			String tmpIn = "";
			System.out.println("SQL :"+ sql.toString());
			rs = pstmt.executeQuery();
			while(rs.next()){
	
				hVa = new HashMap<String,String>();
				hVa.put("iCOM_IDs", rs.getString("i_company"));
				hVa.put("iPROJ_IDs",rs.getString("i_project"));
				
				hVa.put("nPROJs",doString.DisplayThai(rs.getString("n_project")));

				hVa.put("iVen1",doString.checkString(rs.getString("i_vendor1"),""));
				hVa.put("iVenName",GetVendorName(conn,rs.getString("i_vendor1")));

				hVa.put("zones",doString.checkString(rs.getString("i_zone"),""));
				hVa.put("iEmploys",doString.checkString(rs.getString("i_employ_z"),""));
				
				tmpIn = "";
				if(null != rs.getString("i_employ_z") && !"".equals(rs.getString("i_employ_z").trim())){
					tmpIn += "'"+rs.getString("i_employ_z").trim()+"'";
				}

				if(null != rs.getString("i_employ_m1") && !"".equals(rs.getString("i_employ_m1").trim())){
					if(!"".equals(tmpIn)) tmpIn += ",";
					tmpIn += "'"+rs.getString("i_employ_m1").trim()+"'";
				}

				if(null != rs.getString("i_employ_m2") && !"".equals(rs.getString("i_employ_m2").trim())){
					if(!"".equals(tmpIn)) tmpIn += ",";
					tmpIn += "'"+rs.getString("i_employ_m2").trim()+"'";
				}

				if(null != rs.getString("i_employ_s1") && !"".equals(rs.getString("i_employ_s1").trim())){
					if(!"".equals(tmpIn)) tmpIn += ",";
					tmpIn += "'"+rs.getString("i_employ_s1").trim()+"'";
				}

				if(null != rs.getString("i_employ_s2") && !"".equals(rs.getString("i_employ_s2").trim())){
					if(!"".equals(tmpIn)) tmpIn += ",";
					tmpIn += "'"+rs.getString("i_employ_s2").trim()+"'";
				}
				if(null != rs.getString("i_employ_app1") && !"".equals(rs.getString("i_employ_app1").trim())){
					if(!"".equals(tmpIn)) tmpIn += ",";
					tmpIn += "'"+rs.getString("i_employ_app1").trim()+"'";
				}

				if(!"".equals(tmpIn)){
					tmpIn = "("+tmpIn+")";
					isRec = true;
				} else if (rs.getString("i_company")  != "" && rs.getString("i_project") != ""){
					//System.out.print("no data")
					
					isRec = false;
				} else{
					continue;
				}

				System.out.println("Start");
//				sql.delete(0,sql.length());
//				sql.append("select i_employ , n_nemploy_th from docflow:acemploy where i_employ = '"+rs.getString("i_employ_z")+"' ");
//				System.out.println("SQL : "+ sql.toString());
//			    rs1 = stmt.executeQuery(sql.toString());								
//			    if (rs1.next()) {
//			    	hVa.put("iEmployName",doString.DisplayThai(rs1.getString("n_nemploy_th")));
//			    }
//			    rs1.close();
				if(isRec){
				sql.delete(0,sql.length());
				sql.append("select i_employ , n_nemploy_th from docflow:acemploy where i_employ in "+tmpIn);
				System.out.println("SQL : "+ sql.toString());
			    rs1 = stmt.executeQuery(sql.toString());								
			    while (rs1.next()) {
			    	if(rs1.getString("i_employ").equals(rs.getString("i_employ_z"))){
			    		hVa.put("iEmployName",doString.DisplayThai(rs1.getString("n_nemploy_th")));
			    	}
			    	if(rs1.getString("i_employ").equals(rs.getString("i_employ_m1"))){
			    		hVa.put("iEmployM1Name",doString.DisplayThai(rs1.getString("n_nemploy_th")));
			    	}
			    	if(rs1.getString("i_employ").equals(rs.getString("i_employ_m2"))){
			    		hVa.put("iEmployM2Name",doString.DisplayThai(rs1.getString("n_nemploy_th")));
			    	}
			    	if(rs1.getString("i_employ").equals(rs.getString("i_employ_s1"))){
			    		hVa.put("iEmployS1Name",doString.DisplayThai(rs1.getString("n_nemploy_th")));
			    	}
			    	if(rs1.getString("i_employ").equals(rs.getString("i_employ_s2"))){
			    		hVa.put("iEmployS2Name",doString.DisplayThai(rs1.getString("n_nemploy_th")));
			    	}
			    	if(rs1.getString("i_employ").equals(rs.getString("i_employ_app1"))){
			    		hVa.put("iEmployApp1Name",doString.DisplayThai(rs1.getString("n_nemploy_th")));
			    	}
			    }
				rs1.close();
				rs1 = null;
				System.out.println("Pass");
				}
//				hVa.put("iEmployName",GetEmployName(conn,rs.getString("i_employ_z")));
				
//				sql.delete(0,sql.length());
//				sql.append("select user_email from lan:useracl where i_employ = '")
//				    .append(rs.getString("i_employ_z")).append("' ");
//				//System.out.println("SQL : "+ sql.toString());
//			    rs1 = stmt.executeQuery(sql.toString());								
//			    if (rs1.next()) {
//			    	tmpEmp = doString.DisplayThai(rs1.getString("user_email"));
//			    }
//				rs1.close();		 
//				
				//hVa.put("iEmployName",tmpEmp);
				
				hVa.put("iEmployM1",doString.checkString(rs.getString("i_employ_m1"),""));
//				hVa.put("iEmployM1Name",GetEmployName(stmt,rs.getString("i_employ_m1")));
//				
				hVa.put("iEmployM2",doString.checkString(rs.getString("i_employ_m2"),""));
//				hVa.put("iEmployM2Name",GetEmployName(stmt,rs.getString("i_employ_m2")));
//				//hVa.put("iM3",doString.checkString(rs.getString("i_employ_m3"),""));
				hVa.put("iEmployS1",doString.checkString(rs.getString("i_employ_s1"),""));
//				hVa.put("iEmployS1Name",GetEmployName(stmt,rs.getString("i_employ_s1")));
				hVa.put("iEmployS2",doString.checkString(rs.getString("i_employ_s2"),""));
//				hVa.put("iEmployS2Name",GetEmployName(stmt,rs.getString("i_employ_s2")));
//				//hVa.put("iS3",doString.checkString(rs.getString("i_employ_s3"),""));
				hVa.put("ftk",doString.checkString(rs.getString("f_tk"),""));
//				
				hVa.put("iEmployApp1",doString.checkString(rs.getString("i_employ_app1"),""));
//				hVa.put("iEmployApp1Name",GetEmployName(stmt,rs.getString("i_employ_app1")));
				
				//hVa.put("iVen2",doString.checkString(rs.getString("i_vendor2"),""));
				listSearchData.add(hVa);

			}

			System.out.println("END");
			request.setAttribute("listSearchData", listSearchData);
			request.setAttribute("listData", doListSelectorFollowUpTurnkey(conn));
			request.getRequestDispatcher("/SERV_LStaff_List.jsp").forward(request, response);
			System.out.println("===go to SERV_LStaff_List for search==");	
			rs.close();
			stmt.close();
			rs = null;
			stmt = null;
			conn.close();
			conn = null;
		
		}catch(Exception e){
		e.printStackTrace();
		System.out.println("SERV_search"+e.toString());	
		
		
	}
	finally{
		try {
			if (rs != null) {
				rs.close();
				rs = null;
			}
			if (pstmt != null) {
				pstmt.close();
				pstmt = null;
			}
			if (stmt != null) {
				stmt.close();
				stmt = null;
			}
			if (conn != null) {
				conn.close();
				conn = null;
			}
		 } catch (Exception e) {
		}
	}
 }

 
 
 
 
 protected void doAddInfo(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	 
	 	
	 	Connection conn = null;
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		
		
		try {
		System.out.println("doAddInfo >> START");
		
		//----------Open connection Pool
			if (ds == null){
				getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
   //-------------------------
			String[] parts = request.getParameter("iCOM_ID").split("-");
			String iComs= parts[0]; //LH
			String iProjs = parts[1]; //221

			//System.out.println("icom value = "+ iComs);
			//System.out.println("iproj value = "+ iProjs);
			
			request.setAttribute("icom", iComs);
			request.setAttribute("ipro", iProjs);
			
	
		    // if(!(result.equals("invalid"))){ 

		          System.out.println("Add Project >>> START");
					
		 		sql.delete(0, sql.length());
		 		sql.append("insert into lan:serv_lstaff ( ")
		 			.append("i_company,")
		 			.append("i_project, ")
		 			.append("i_employ_z,") 
		 			.append("i_employ_m1,")
		 			.append("i_employ_m2,")
		 			.append("i_employ_s1, ") 
		 			.append("i_employ_s2,") 
		 			.append("i_vendor1,") 
		 			.append("i_zone,") 
		 			.append("f_tk,")
		 			.append("i_employ_app1 ) ")
		 			.append("VALUES ( ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? )");
		 							//1	  2   3   4   5   6   7   8   9   10  11  
		 		
		 		int i =1;
		 		//System.out.println(sql.toString());
		 		
		 		pstmt = conn.prepareStatement(sql.toString());
		 		
		 		
		 		pstmt.setString(i++,iComs); //1
		 		pstmt.setString(i++,iProjs);//2
		 		pstmt.setString(i++,request.getParameter("i_employ_z"));//3
		 		pstmt.setString(i++,request.getParameter("i_employ_m1"));//4
		 		pstmt.setString(i++,request.getParameter("i_employ_m2"));//5
		 		pstmt.setString(i++,request.getParameter("i_employ_s1"));//6
		 		pstmt.setString(i++,request.getParameter("i_employ_s2"));//7
		 		pstmt.setString(i++,request.getParameter("i_vendor1"));//8
		 		pstmt.setString(i++,request.getParameter("i_zone"));//9
		 		pstmt.setString(i++,request.getParameter("f_tk"));//10
		 		pstmt.setString(i++,request.getParameter("i_employ_app1"));//11
		 	
		 		pstmt.executeUpdate();
		 		System.out.println("=====================Add Project success!!!!=====================");
		 		request.getRequestDispatcher("SERV_LStaffServlet?cmd=searchLStaff").forward(request, response);
		     
			
		
			
			conn.close();
				
				
		 }catch(Exception e){
			e.printStackTrace();
			System.out.println("SERVAdd"+e.toString());	
			request.getRequestDispatcher("errorPage.jsp").forward(request, response);
			
		}
		finally{
			try {
			
				if (pstmt != null) {
					pstmt.close();
				}
				if (conn != null) {
					conn.close();
				}
			 } catch (Exception e) {
			}
		}
	 }
 
 
 
 protected void doUpdateInfo(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
	 	
	 	Connection conn = null;
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		
		
		try {
		System.out.println("doUpdateInfo >> START");
		
		//----------Open connection Pool
			if (ds == null){
				getDS();}			
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
   //-------------------------
			String[] parts = request.getParameter("iCOM_ID").split("-");
			String iCom= parts[0]; //LH
			String iProj = parts[1]; //221

			//System.out.println("icom value = "+ iCom);
			//System.out.println("iproj value = "+ iProj);
			
			request.setAttribute("icom", iCom);
			request.setAttribute("ipro", iProj);
			
		
	   //  if(!(result.equals("invalid"))){ 

			sql.delete(0,sql.length());
			sql.append("UPDATE lan:serv_lstaff ") 
			   .append(" set i_company = ? , i_project = ? "); //comma
			
			   
				if(!"".equals(doString.checkString(request.getParameter("i_employ_z"),  null))) {
						sql.append(", i_employ_z = ? " );
			   }
				if(!"".equals(doString.checkString(request.getParameter("i_employ_m1"), null))) {
					   sql.append(", i_employ_m1 = ? " );
				   }
				if(!"".equals(doString.checkString(request.getParameter("i_employ_m2"), null))) {
					   sql.append(", i_employ_m2 = ? " );
				   }
				if(!"".equals(doString.checkString(request.getParameter("i_employ_s1"), null))) {
					   sql.append(", i_employ_s1 = ? " );
				   }	
				if(!"".equals(doString.checkString(request.getParameter("i_employ_s2"), null))) {
					   sql.append(", i_employ_s2 = ? " );
				   }	
				if(!"".equals(doString.checkString(request.getParameter("i_vendor1"), null))) {
					   sql.append(", i_vendor1 = ? " );
				   }
				
				if(!"".equals(doString.checkString(request.getParameter("i_zone"), null))) {
					   sql.append(", i_zone = ? " );
				   }
				
				if(!"".equals(doString.checkString(request.getParameter("f_tk"),null))) {
					   sql.append(", f_tk = ? " );
				}
				if(!"".equals(doString.checkString(request.getParameter("i_employ_app1"), null))) {
					   sql.append(", i_employ_app1 = ? " );
				   }	
				
			
				
			sql.append(" where i_company = ? and i_project = ? ; ");
			System.out.println("update statement >>" + sql.toString());
			
			pstmt = conn.prepareStatement(sql.toString());
			int i =1;
			
			
		
			pstmt.setString(i++,iCom);//1
			pstmt.setString(i++,iProj);//2
			
		    if(!"".equals(doString.checkString(request.getParameter("i_employ_z") , null))) {
		    		pstmt.setString(i++,request.getParameter("i_employ_z"));
		   }
			if(!"".equals(doString.checkString(request.getParameter("i_employ_m1"), null))) {
					pstmt.setString(i++,request.getParameter("i_employ_m1"));
			   }
			if(!"".equals(doString.checkString(request.getParameter("i_employ_m2"), null))) {
					pstmt.setString(i++,request.getParameter("i_employ_m2"));
			   }
			if(!"".equals(doString.checkString(request.getParameter("i_employ_s1"), null))) {
					pstmt.setString(i++,request.getParameter("i_employ_s1"));
			   }	
			if(!"".equals(doString.checkString(request.getParameter("i_employ_s2"), null))) {
					pstmt.setString(i++,request.getParameter("i_employ_s2"));
			   }	
			if(!"".equals(doString.checkString(request.getParameter("i_vendor1"), null))) {
					pstmt.setString(i++,request.getParameter("i_vendor1"));
			   }
			
			if(!"".equals(doString.checkString(request.getParameter("i_zone"), null))) {
					pstmt.setString(i++,request.getParameter("i_zone"));
			   }
			
			if(!"".equals(doString.checkString(request.getParameter("f_tk"), null))) {
					pstmt.setString(i++,request.getParameter("f_tk"));
				}
			if(!"".equals(doString.checkString(request.getParameter("i_employ_app1"), null))) {
					pstmt.setString(i++,request.getParameter("i_employ_app1"));
			   }	
			
			
		
			
			
			pstmt.setString(i++,iCom);//1
			pstmt.setString(i++,iProj);//2
			
			pstmt.executeUpdate();
			System.out.println("Update SUCCESS");
			request.setAttribute("selector", request.getParameter("iCOM_ID"));
			request.setAttribute("listData", doListSelectorFollowUpTurnkey(conn));
			request.getRequestDispatcher("SERV_LStaffServlet?cmd=searchLStaff").forward(request, response);
			
			conn.close();
			
	
			
	    			
	//     }
		}
			catch(Exception e){
			e.printStackTrace();
			System.out.println("SERVUpdate"+e.toString());	
			System.out.println("wrong data");	
			request.getRequestDispatcher("errorPage.jsp").forward(request, response);
		}
		finally{
			try {
				
				if (pstmt != null) {
					pstmt.close();
				}
				if (conn != null) {
					conn.close();
				}
			 } catch (Exception e) {
			}
		}
	 }
 	
	 
 
 
 protected void doDeleteProject(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	 
	 StringBuffer sql = new StringBuffer();
	PreparedStatement pstmt =  null;
	Connection conn = null;	
	try {
		System.out.println("delete project >> start");
			
  		//----------Open connection Pool
 		if (ds == null){
 				getDS();}			
  		conn = ds.getConnection();
  		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
  		conn.setAutoCommit(true);
        //-------------------------
  		
  		String comId = request.getParameter("iCOM_ID");
  		//System.out.println("receieve delete selector :"+comId);
  		
  		
  		if(comId.equals("all")){
  			request.setAttribute("all", "all");
  		} else {
		String[] parts = comId.split("-");
		String iComselect  = parts[0]; //LH
		String iProjselect = parts[1]; //221
		request.setAttribute("icom",iComselect);
		request.setAttribute("ipro",iProjselect);
  		}		
		sql.delete(0,sql.length());
		sql.append("DELETE FROM lan:serv_lstaff ")
	       .append("WHERE i_company = ? AND i_project = ? ");
		
		System.out.println("Delete Staetment =" + sql.toString());
		pstmt = conn.prepareStatement(sql.toString());
		pstmt.setString(1, doString.checkString(request.getParameter("icomdel"),""));
		pstmt.setString(2, doString.checkString(request.getParameter("iprodel"),""));
		pstmt.executeUpdate();
		System.out.println("================Delete Success!!==================");
		request.getRequestDispatcher("SERV_LStaffServlet?cmd=searchLStaff").forward(request, response);
		
		
				

		
	
	}catch (Exception e) {
		System.out.println ("failed delete");	
	
	}
	finally{
		//clean up.
		try{
			if(pstmt!=null){pstmt.close();}
			if(conn!=null){conn.close();}
		}catch(Exception e){}
	}
 }
 
 protected void doLoadForm (HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	 Connection conn = null;
	 try{
	 System.out.println("===============doLoadForm===============");
//	----------Open connection Pool
		if (ds == null){
				getDS();}			
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
     //-------------------------
	 
	 request.setAttribute("listData", doListSelectorFollowUpTurnkey(conn));
	 request.getRequestDispatcher("/SERV_LStaff_Add.jsp").forward(request, response);
	 conn.close();
	 conn = null;
	 
	 }catch (Exception e) {
			System.out.println ("failed load form");	
		
		}
		finally{
			//clean up.
			try{
				if(conn!=null){conn.close();}
			}catch(Exception e){}
		}
 }
 }

 