package com.svc.call.dao.services;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import com.lh.util.doString;
import com.svc.call.bean.SVC_XSTD;

/**********************************************
 * create by : pradoem wonkraso
 * date time: 2013.10.29
 * Last modify :
 * version :1.0
 * project Name :Service Center 
 * description : this class implement for access database lan of SVC system
 * about to do Insert,List,Get,update,delete  etc.. 
*/


public class MasterSvcServiceImpl implements MasterSvcService {
	static String sysName = "ServiceCenter";
	static String clazzName = "MasterSvcServiceImpl";	
	
	public List ListProjectAllByBudget(Connection conn) {
		// TODO Auto-generated method stub
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter	
        	List  projectDDL = new ArrayList();
       	 	List   strList = null;	      	
        	System.out.println("ListProjectAllByBudget ->Starting.");        	 

			
			/****************************projectDLL****************************************/
			 int year = Calendar.getInstance().get(Calendar.YEAR);
			 if (year<2400) year += 543;
			 int pYear = year-1;

			 sql.append(" Select distinct a.i_company,a.i_project,b.n_project From lan:acsbudgh a  ")
				   .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
				   .append(" Where a.d_year in ( '").append(year).append("' , '").append(pYear).append("' ) ")
				   .append(" and a.i_budg_type in (9)  ")
				   .append(" order by a.i_company , a.i_project ");
			////System.out.println("SQL :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString());
			rs = pstmt.executeQuery();				
			while(rs.next()){
					strList =  new ArrayList(); 
					strList.add(0,  doString.checkString(rs.getString("i_company"),""));
					strList.add(1,  doString.checkString(rs.getString("i_project"),""));
					strList.add(2,  doString.checkString(rs.getString("n_project"),""));
					projectDDL.add(strList);
			}
			rs.close();		   			
			//********************************************************/
		  	System.out.println("ListProjectAllByBudget ->end.");				  	 
		  	return projectDDL;			  	 
		}catch(Exception e){
			System.out.println("ListProjectAllByBudget , " +sysName+":"+ clazzName + " : " + e.getMessage());
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

	public List ListSearchProjectAllByBudget(Connection conn, String criteria) {
		// TODO Auto-generated method stub
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter	
        	List  projectDDL = new ArrayList();
       	 	List   strList = null;	      	
        	System.out.println("ListSearchProjectAllByBudget ->Starting.");        	 
			
			/****************************projectDLL****************************************/
			 int year = Calendar.getInstance().get(Calendar.YEAR);
			 if (year<2400) year += 543;
			 int pYear = year-1;

			 sql.append(" Select distinct a.i_company,a.i_project,b.n_project From lan:acsbudgh a  ")
				   .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
				   .append(" Where a.d_year in ( '").append(year).append("' , '").append(pYear).append("' ) ")
				   .append(" and a.i_budg_type in (9)  ")
				   .append(" and (b.n_project LIKE '%").append(criteria.trim()).append("%'  OR b.n_project = ? ) ")
				   .append(" Order by a.i_company , a.i_project ");
			System.out.println("SQL :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString());
			pstmt.setString(1, criteria.trim());
			rs = pstmt.executeQuery();		
			
			while(rs.next()){
					strList =  new ArrayList(); 
					strList.add(0,  doString.checkString(rs.getString("i_company"),""));
					strList.add(1,  doString.checkString(rs.getString("i_project"),""));
					strList.add(2,  doString.checkString(rs.getString("n_project"),""));
					projectDDL.add(strList);
			}
			rs.close();		   			
			//********************************************************/
		  	System.out.println("ListSearchProjectAllByBudget ->end.");				  	 
		  	return projectDDL;			  	 
		}catch(Exception e){
			System.out.println("ListSearchProjectAllByBudget , " +sysName+":"+ clazzName + " : " + e.getMessage());
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

	public String GetNameEmployByAgentId(Connection conn, String employId) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String  emmployName = "";
        try{
        	//initial paramter	   
			/*************************************************/	
			sql.delete(0,sql.length());
			sql.append("Select n_prename_th,n_nemploy_th,n_semploy_th From lan:acemploy Where i_employ = ? ");
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, employId);	
			//System.out.println("SQL :"+sql.toString());
			rs = pstmt.executeQuery();	
			if(rs.next()){
				emmployName = doString.checkString(rs.getString("n_prename_th"), "")+" "+
				doString.checkString(rs.getString("n_nemploy_th"), "")+"  "+doString.checkString(rs.getString("n_semploy_th"), "");
			}
			rs.close();	
	   			
			//**************************************************/
		  	//System.out.println("##GetNameEmployAssign ->successfully.");				  	 
		  	return emmployName;			  	 
		}catch(Exception e){
			System.out.println("!!!GetNameEmployByAgentId , " +sysName+":"+ clazzName + " : " + e.getMessage());
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


	public String GetNameEmploy(Connection conn, String employId) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String  emmployName = "";
        try{
        	//initial paramter	     	
			/*************************************************/			
        	//*****Find project by user login  
			sql.delete(0,sql.length());
			sql.append("Select n_prename_th,n_nemploy_th,n_semploy_th From lan:acemploy Where i_employ = ? ");
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, employId);	
			//System.out.println("SQL :"+sql.toString());
			rs = pstmt.executeQuery();	
			if(rs.next()){
				emmployName = doString.checkString(rs.getString("n_prename_th"), "")+" "+
				doString.checkString(rs.getString("n_nemploy_th"), "")+"  "+doString.checkString(rs.getString("n_semploy_th"), "");
			}
			rs.close();	
	   			
			//**************************************************/
		  	//System.out.println("##GetNameEmployAssign ->successfully.");				  	 
		  	return emmployName;			  	 
		}catch(Exception e){
			System.out.println("!!!GetNameEmploy , " +sysName+":"+ clazzName + " : " + e.getMessage());
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

	//01,01
	public List ListGroupHomeRepair(Connection conn) {
		// TODO Auto-generated method stub
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter		
        	//System.out.println("##GetCallCT_STD ->Starting.");   
        	List  resultList = new ArrayList();
        	SVC_XSTD  obj = null;
			/******************************************************/	       	
			sql.delete(0,sql.length());
			sql.append(" Select i_type, i_code, n_desc, f_date_display, i_date_type, f_end_job ")
			   .append(" From lan:svc_xstd    ")
			   .append(" Where i_type = '01'  ")
			   .append(" and (i_code is not null or i_code != '') ")
			   .append(" Order by i_code ");

			System.out.println(" XSTD - SQL :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString());
			rs = pstmt.executeQuery();	
			while(rs.next()){	
				obj = new SVC_XSTD();
				obj.setI_type(doString.checkString(rs.getString("i_type"),""));
				obj.setI_code(doString.checkString(rs.getString("i_code"),""));
				obj.setN_desc(doString.checkString(rs.getString("n_desc"),""));
				obj.setF_date_display(doString.checkString(rs.getString("f_date_display"),""));
				obj.setI_date_type(doString.checkString(rs.getString("i_date_type"),""));
				obj.setF_end_job(doString.checkString(rs.getString("f_end_job"),""));
				resultList.add(obj);
			}
			rs.close();				
			//********************************************************/
		  	//System.out.println("##GetCallCT_STD ->end.");				  	 
		  	return resultList;			  	 
		}catch(Exception e){
			System.out.println("!!!ListGroupHomeRepair , " +sysName+":"+ clazzName + " : " + e.getMessage());
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

	//03,01
	public List ListGroupThePublicService(Connection conn) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter		
        	//System.out.println("##GetCallCT_STD ->Starting.");   
        	List  resultList = new ArrayList();
        	SVC_XSTD  obj = null;
			/******************************************************/	       	
			sql.delete(0,sql.length());
			sql.append(" Select i_type, i_code, n_desc, f_date_display, i_date_type, f_end_job ")
			   .append(" From lan:svc_xstd ")
			   .append(" Where i_type = '03'  ")
			   .append(" and (i_code is not null or i_code != '')  ")
			   .append(" Order by i_code ");

			System.out.println(" Public XSTD - SQL :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString());
			rs = pstmt.executeQuery();	
			while(rs.next()){	
				obj = new SVC_XSTD();
				obj.setI_type(doString.checkString(rs.getString("i_type"),""));
				obj.setI_code(doString.checkString(rs.getString("i_code"),""));
				obj.setN_desc(doString.checkString(rs.getString("n_desc"),""));
				obj.setF_date_display(doString.checkString(rs.getString("f_date_display"),""));
				obj.setI_date_type(doString.checkString(rs.getString("i_date_type"),""));
				obj.setF_end_job(doString.checkString(rs.getString("f_end_job"),""));
				resultList.add(obj);
			}
			rs.close();				
			//********************************************************/
		  	//System.out.println("##GetCallCT_STD ->end.");				  	 
		  	return resultList;			  	 
		}catch(Exception e){
			System.out.println("!!!ListGroupThePublicService , " +sysName+":"+ clazzName + " : " + e.getMessage());
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

	public List ListGroupNameStandard(Connection conn) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter		
        	//System.out.println("##GetCallCT_STD ->Starting.");   
        	List  resultList = new ArrayList();
        	SVC_XSTD  obj = null;
			/******************************************************/	       	
			sql.delete(0,sql.length());
			sql.append(" Select i_type,n_desc  ")
			   .append(" From lan:svc_xstd ")
			   .append(" Where  (i_code is  null or i_code = '') Order by i_type  ");

			System.out.println("ListGroupNameStandard XSTD - SQL :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString());
			rs = pstmt.executeQuery();	
			while(rs.next()){	
				obj = new SVC_XSTD();
				obj.setI_type(doString.checkString(rs.getString("i_type"),""));
				obj.setN_desc(doString.checkString(rs.getString("n_desc"),""));
				resultList.add(obj);
			}
			rs.close();				
			//********************************************************/
		  	//System.out.println("##GetCallCT_STD ->end.");				  	 
		  	return resultList;			  	 
		}catch(Exception e){
			System.out.println("!!!ListGroupNameStandard , " +sysName+":"+ clazzName + " : " + e.getMessage());
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

	public String GetEmployIdByAgentId(Connection conn, String agentid) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter	   
        	String employId = "";
			/*************************************************/	
        	sql.delete(0,sql.length());
			sql.append("Select agent_id,i_employ  From lan:svc_agent Where agent_id = ? ");
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, agentid);	
			System.out.println("Find EmployId SQL :"+sql.toString());
			rs = pstmt.executeQuery();	
			if(rs.next()){
				employId =  doString.checkString(rs.getString("i_employ"), "");
			}
			rs.close();		   			
			//**************************************************/			  	 
		  	return employId;			  	 
		}catch(Exception e){
			System.out.println("!!!GetEmployIdByAgentId , " +sysName+":"+ clazzName + " : " + e.getMessage());
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


}
