package com.svc.call.dao.services;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import com.lh.util.doString;
import com.svc.call.bean.CustomerBean;
import com.svc.call.bean.ESER_DATE;
import com.svc.call.bean.SVC_DOCDT;
import com.svc.call.bean.SVC_DOCHD;
import com.svc.call.bean.SVC_STDPJ;
import com.svc.call.bean.SVC_TELNO;
import com.svc.call.utilize.Constant;
import com.svc.call.utilize.Utilizer;

/**********************************************
 * create by : pradoem wonkraso
 * date time: 2013.10.29
 * Last modify :
 * version :1.0
 * project Name :Service Center 
 * description : this class implement for access database lan of SVC system
 * about to do Insert,List,Get,update,delete  etc.. 
*/

public class ServiceCenterCallServiceImpl  implements ServiceCenterCallService {
	static String sysName = "ServiceCenter";
	static String clazzName = "ServiceCenterCallServiceImpl";
	
	public List ListSearchMobile$CTASIA(Connection conn, String tel) {
		// TODO Auto-generated method stub
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter
        	List  projectList = new ArrayList();
       	 	List  strList = null;	      	
        	//System.out.println("ListProjectName ->Starting.");        	 

			/******************************************************/			
        	//*****Find project by user login  
			sql.delete(0,sql.length());
			sql.append(" Select a.i_company,a.i_project,b.n_project,a.i_lock,a.i_house,max(a.d_update)   From lan:svc_telno a,lan:acxprojt b ")
			   .append(" Where a.i_tel_ctasia  = ?  ")
			   .append(" and a.i_company = b.i_company ")
			   .append(" and a.i_project = b.i_project ")
			   //.append(" Order by a.i_company,a.i_project ");
			   .append(" Group by a.i_company,a.i_project,b.n_project,a.i_lock,a.i_house ");
			System.out.println("SQL :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, tel);
			rs = pstmt.executeQuery();	
			while(rs.next()){				
				strList = new ArrayList();
				strList.add(0,doString.checkString(rs.getString("i_company"), ""));
				strList.add(1,doString.checkString(rs.getString("i_project"), ""));
				strList.add(2,doString.checkString(rs.getString("n_project"), ""));
				strList.add(3,doString.checkString(rs.getString("i_lock"), ""));//33
				strList.add(4,doString.checkString(rs.getString("i_house"), ""));//44
				projectList.add(strList);
			}
			rs.close();	
			
			//********************************************************/
		  	//System.out.println("ListProjectName ->successfully.");				  	 
		  	return projectList;			  	 
		}catch(Exception e){
			System.out.println("!!!ListSearchMobile$CTASIA , " +sysName+":"+ clazzName + " : " + e.getMessage());
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

	public CustomerBean GetProjectOfCustomerByHose$Lock(Connection conn, String comId, String projId, String houseNo, String lock) {
		// TODO Auto-generated method stub
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter
        	CustomerBean  obj  = new CustomerBean();
        	String iCustomer = "";     	
        	//System.out.println("ListProjectName ->Starting.");        	 
			/******************************************************/			
        	//*****Find project by user login  
			sql.delete(0,sql.length());
			sql.append(" Select a.i_lor,a.i_model,a.i_house,a.i_lock,b.i_exp_intent1,b.i_cus_intent1,b.d_close_law From lan:acxlckmd a ")
				  .append(" left join lan:acscontr b on b.i_company=a.i_company and b.i_project=a.i_project ")
				  .append(" and b.i_lor=a.i_lor and b.f_contr is null ")
				  .append(" Where a.i_company = ? ")
				  .append(" and a.i_project = ?  ");  
			if (houseNo.length()>0){ 
				sql.append(" and a.i_house='").append(houseNo).append("' ");
			}
			if (lock.length()>0){
				sql.append(" and a.i_lock='").append(lock).append("' ");	
			}  
			System.out.println("-->Get Customer SQL :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, comId);
			pstmt.setString(2, projId);
			rs = pstmt.executeQuery();	
			if(rs.next()){				
				iCustomer = doString.checkString(rs.getString("i_cus_intent1"),"");
				if (iCustomer.length()<=0) {
					iCustomer = doString.checkString(rs.getString("i_exp_intent1"),"");
				}
				obj.setCustomerId(iCustomer);
				obj.setModel(doString.checkString(rs.getString("i_model"),""));
				obj.setHouseNo(doString.checkString(rs.getString("i_house"),""));
				obj.setLor(doString.checkString(rs.getString("i_lor"),""));
				obj.setLock(doString.checkString(rs.getString("i_lock"),""));
				obj.setDCloseLaw(doString.checkString(rs.getString("d_close_law")));			
				Timestamp dCloseLaw = rs.getTimestamp("d_close_law");
				if (dCloseLaw==null) {
					obj.setFlagGuranteeDate(Constant.FLAG_GURANTEE_N); //not guruntee
				} else {
					Calendar calGurantee = Calendar.getInstance(); 
					calGurantee.setTime(dCloseLaw);
					calGurantee.add(Calendar.YEAR,1);
					if (Calendar.getInstance().after(calGurantee)) {
						obj.setFlagGuranteeDate(Constant.FLAG_GURANTEE_N); //Not gurantee
					}else{
						obj.setFlagGuranteeDate(Constant.FLAG_GURANTEE_Y);//bettween gurantee
					}
					obj.setDateGurantee(Utilizer.GetDateSystemCalendar(calGurantee));
				}
			}
			rs.close();	
			//********************************************************/
			sql.delete(0,sql.length());				
			sql.append(" Select n_prename,n_ncustomer,n_scustomer,a_id_tel,a_wk_tel,a_etc_tel ")
			   .append(" From lan:acxcusto Where i_customer='").append(iCustomer).append("' ");	
			System.out.println("SQL2 = "+sql.toString());
			pstmt = conn.prepareStatement(sql.toString()); 
			rs = pstmt.executeQuery();	
			if(rs.next()){	
				obj.setPrefixName(doString.checkString(rs.getString("n_prename"),""));
				obj.setFName(doString.checkString(rs.getString("n_ncustomer"),""));
				obj.setLName(doString.checkString(rs.getString("n_scustomer"),""));
				
				String nCustTel = doString.checkString(rs.getString("a_id_tel"),"");
				String tel = doString.checkString(rs.getString("a_wk_tel"),"");
				if (tel.length()>0) {
					nCustTel += (nCustTel.length()>0) ? " , "+tel : tel;
				}
				tel = doString.checkString(rs.getString("a_etc_tel"),"");
				if (tel.length()>0) {
					nCustTel += (nCustTel.length()>0) ? " , "+tel : tel;
				}
				obj.setTelNo(nCustTel);
			}
			rs.close();
		  	//System.out.println("ListProjectName ->successfully.");				  	 
		  	return obj;			  	 
		}catch(Exception e){
			System.out.println("!!!SearchProjectOfCustomerByHose$Lock , " +sysName+":"+ clazzName + " : " + e.getMessage());
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

	public SVC_TELNO GetSVC$TELNO(Connection conn,String comId,String projId,String telNo) {
		// TODO Auto-generated method stub
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial parameter 
        	SVC_TELNO  objTel = new SVC_TELNO();
        	objTel.setITelNo(telNo);
        	
        	//System.out.println("ListProjectName ->Starting.");        	 
			/******************************************************/	
          	//*****Find project by user login  
			sql.delete(0,sql.length());
			sql.append(" Select i_tel_ctasia,i_customer,i_company,i_project,i_lock, d_create,i_employ_create,d_update,i_employ_update,n_customer,i_tel_no,i_email, i_house  ")
			   .append(" From lan:svc_telno ")
			   .append(" Where ")
			   .append(" i_company = ? and i_project = ?  and i_tel_ctasia = ? ");
			System.out.println("SQL Get GetSVC$TELNO :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, comId);
			pstmt.setString(2, projId);
			pstmt.setString(3, telNo);
			rs = pstmt.executeQuery();	
			if(rs.next()){				
				//strList.add(0,doString.checkString(rs.getString("i_company"), ""));
				//objTel = new SVC_TELNO();
				objTel.setITelCtasia(doString.checkString(rs.getString("i_tel_ctasia"), ""));
				objTel.setICustomer(doString.checkString(rs.getString("i_customer"), ""));
				objTel.setICompany(doString.checkString(rs.getString("i_company"), ""));
				objTel.setIProject(doString.checkString(rs.getString("i_project"), ""));
				objTel.setILock(doString.checkString(rs.getString("i_lock"), ""));
				objTel.setDCreate(doString.checkString(rs.getString("d_create"), ""));
				objTel.setIEmployCreate(doString.checkString(rs.getString("i_employ_create"), ""));
				objTel.setDUpdate(doString.checkString(rs.getString("d_update"), ""));
				objTel.setIEmploy_update(doString.checkString(rs.getString("i_employ_update"), ""));
				objTel.setNCustomer(doString.checkString(rs.getString("n_customer"), ""));
				//objTel.setITelNo(doString.checkString(rs.getString("i_tel_no"), ""));
				objTel.setIEmail(doString.checkString(rs.getString("i_email"), ""));
				objTel.setIHouse(doString.checkString(rs.getString("i_house"), ""));
			}
			rs.close();				
			//********************************************************/
		  	//System.out.println("ListProjectName ->successfully.");				  	 
		  	return objTel;			  	 
		}catch(Exception e){
			System.out.println("!!!GetSVC$TELNO , " +sysName+":"+ clazzName + " : " + e.getMessage());
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

	public List ListHistoryContactDocHD$Paging(Connection conn, String comId, String projId, String lock,int startRow,int endRow,int maxRow) {
		// TODO Auto-generated method stub
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter 
        	List  listDocHd = new ArrayList();
        	SVC_DOCHD  objDoc = null;
        	int line = 0;
        	MasterSvcService msService = new MasterSvcServiceImpl();
        	ServiceCenterCallService callSerice = new ServiceCenterCallServiceImpl();
    	 
			/******************************************************/	
          	//*****Find project by user login  
			sql.delete(0,sql.length());
			sql.append(" Select first ").append(endRow).append("  i_company,i_project,i_lock,date(d_keyin) as dd,i_svc_docno,i_employ,n_customer ")
			   .append(" From lan:svc_dochd ")
			   .append(" Where ")
			   .append(" i_company = ? and i_project = ?  and i_lock = ? ");
			
			System.out.println("SQL ListHistoryContactDocHD:"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, comId);
			pstmt.setString(2, projId);
			pstmt.setString(3, lock);
			rs = pstmt.executeQuery();	
			
	        for (int i=0;i<maxRow;i++) { 
                if (rs.next()) {
                   if (i>=startRow && i<=endRow) {	
	       				objDoc = new SVC_DOCHD();
	    				objDoc.setI_company(doString.checkString(rs.getString("i_company"), ""));
	    				objDoc.setI_project(doString.checkString(rs.getString("i_project"), ""));
	    				objDoc.setI_lock(doString.checkString(rs.getString("i_lock"), ""));
	    				objDoc.setD_keyin(doString.checkString(rs.getString("dd"), ""));
	    				objDoc.setI_svc_docno(doString.checkString(rs.getString("i_svc_docno"), ""));
	    				objDoc.setI_employ(doString.checkString(rs.getString("i_employ"), ""));
	    				
	    				//*****call service get employ name
	    				objDoc.setEmployName(msService.GetNameEmploy(conn,objDoc.getI_employ()));
	    				
	    				objDoc.setN_customer(doString.checkString(rs.getString("n_customer"), ""));
	    				//objDoc
	    				objDoc.setSvcDocdtList((ArrayList)callSerice.ListSCV$DOCDT(conn, objDoc.getI_svc_docno()));
	    				System.out.println("---TEST x :"+objDoc.getSvcDocdtList().size());
	    				listDocHd.add(objDoc);
		       				
		       			line++;                         
                   } //--end if check row
	               if (i>endRow){ 
	              	 break;
	               }
                } //end if check rs
	        } // end for
			//********************************************************/
			rs.close();				
			//********************************************************/
		  	System.out.println("-->listDocHd :"+listDocHd.size());				  	 
		  	return listDocHd;			  	 
		}catch(Exception e){
			System.out.println("!!!ListHistoryContactDocHD , " +sysName+":"+ clazzName + " : " + e.getMessage());
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

	public List ListSCV$DOCDT(Connection conn, String docId) {
		// TODO Auto-generated method stub
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter
        	SVC_DOCDT  obj = null;
        	List  listDocDT = new ArrayList();
       	 	//List  strList = null;	      	
        	//System.out.println("ListProjectName ->Starting.");        	 

			/******************************************************/	
			sql.delete(0,sql.length());
			sql.append(" Select a.i_svc_docno, a.i_itmno, a.i_itmsub,a.c_detail,a.d_appoint,a.i_docno,a.f_status,a.i_calendar_id,a.d_start, ")
			   .append("   a.i_employ_start,a.c_start_desc,a.i_email_start,a.d_complete,a.i_employ_complete,a.i_email_complete, ")
			   .append("   a.c_complete_desc,a.d_svc_endjob,a.i_employ_endjob  ")
			   .append("   ,b.i_type,b.i_code,b.n_desc ")
			   .append(" From lan:svc_docdt a,lan:svc_xstd b ")
			   .append(" Where a.i_svc_docno  = ?  and a.f_status != 'CLS' ")
			   .append(" and a.i_itmno = b.i_type and (b.i_code is null or b.i_code = '')  ")
			   .append(" Order by   a.i_itmno ");
			
			System.out.println("SQL ListSCV$DOCDT&&svc_xstd :"+sql.toString());
			System.out.println("docId :"+docId);
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, docId);
			rs = pstmt.executeQuery();	
			while(rs.next()){
				obj = new SVC_DOCDT();
				//strList.add(0,doString.checkString(rs.getString("xx"), ""));
				obj.setI_svc_docno(doString.checkString(rs.getString("i_svc_docno"), ""));
				obj.setI_itmno(doString.checkString(rs.getString("i_itmno"), ""));
				obj.setI_itmsub(doString.checkString(rs.getString("i_itmsub"), ""));
				obj.setC_detail(doString.checkString(rs.getString("c_detail"), ""));
				obj.setD_appoint(doString.checkString(rs.getString("d_appoint"), ""));
				obj.setI_docno(doString.checkString(rs.getString("i_docno"), ""));
				obj.setF_status(doString.checkString(rs.getString("f_status"), ""));
				obj.setI_calendar_id(doString.checkString(rs.getString("i_calendar_id"), ""));
				obj.setD_start(doString.checkString(rs.getString("d_start"), ""));
				obj.setI_employ_start(doString.checkString(rs.getString("i_employ_start"), ""));
				obj.setC_start_desc(doString.checkString(rs.getString("c_start_desc"), ""));
				obj.setI_email_start(doString.checkString(rs.getString("i_email_start"), ""));
				obj.setD_complete(doString.checkString(rs.getString("d_complete"), ""));
				obj.setI_employ_complete(doString.checkString(rs.getString("i_employ_complete"), ""));
				obj.setI_email_complete(doString.checkString(rs.getString("i_email_complete"), ""));
				obj.setC_complete_desc(doString.checkString(rs.getString("c_complete_desc"), ""));
				obj.setD_svc_endjob(doString.checkString(rs.getString("d_svc_endjob"), ""));
				obj.setI_employ_endjob(doString.checkString(rs.getString("i_employ_endjob"), ""));
				
				//for svc_xstd
				obj.setI_type(doString.checkString(rs.getString("i_type"), ""));
				obj.setI_code(doString.checkString(rs.getString("i_code"), ""));
				obj.setN_desc(doString.checkString(rs.getString("n_desc"), ""));
				
				listDocDT.add(obj);
			}
			rs.close();			
			//********************************************************/
		  	System.out.println("xxx-->listDocDT :"+listDocDT.size());				  	 
		  	return listDocDT;			  	 
		}catch(Exception e){
			System.out.println("!!!ListSCV$DOCDT , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
	//LH,075,02  for service center
	public List ListAppointDate$SVC(Connection conn, String comId, String projId, String i_type) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter		
        	//System.out.println("##GetCallCT_STD ->Starting.");   
        	List  resultList = new ArrayList();
        	List strArr = null;    	 
			//setTransaction 			
			sql.delete(0,sql.length());
			sql.append(" Select distinct i_date,weekday(i_date) as iday From lan:eser_date  ")
				.append(" Where i_company = ? and i_project = ? ")
				.append(" and i_date >= today  ")
				.append(" and i_date <= today+30 units day ")
				.append(" and i_eser_docno is null  ")
				.append(" and i_date_type = ?  ")
				.append(" order by i_date ");		  
			
			System.out.println("SQL eser_date :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1,comId);//icom_ID
			pstmt.setString(2,projId);//iproj_ID				  
			pstmt.setString(3,i_type);//i_type
			
			rs = pstmt.executeQuery();
			while (rs.next()) {
					strArr = new ArrayList();
					strArr.add(0,doString.checkString(rs.getString("i_date"),""));			  
					strArr.add(1,doString.checkString(rs.getString("iday"),"7"));
					resultList.add(strArr);					 					 
			} // End if rs				
	
        	return resultList;			  	 
		}catch(Exception e){
			System.out.println("!!!ListAppointDate$SVC , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
	
	//	LH,075,02,2013-10-17  for service center
	public List ListAppointTime$1SVC(Connection conn, String comId, String projId, String i_type, String dateStr) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter		
        	List  resultList = new ArrayList();
        	//System.out.println("##GetCallCT_STD ->Starting.");   
        	Date d = new Date();
			//System.out.println("<<----------:"+d.getHours()+":"+d.getMinutes());
			int timeCurrent = Integer.parseInt(d.getHours()+""+d.getMinutes());
			//System.out.println("<<----------timeInt:"+timeCurrent);
			ArrayList strArr = null;
			StringBuffer tempInt = new StringBuffer();
			StringBuffer strMun = new StringBuffer();
			StringBuffer strSec = new StringBuffer();
			int getTimeInt = 0;
			sql.delete(0,sql.length());
			sql.append(" Select  q_apptime_fr1  From lan:eser_date  ")
			   .append(" Where ")
			   .append(" i_date = ? and i_company =? and i_project = ? ")
			   .append(" and i_date_type = ? ")
			   .append(" and i_eser_docno is null ");			
			 pstmt = conn.prepareStatement(sql.toString()); 
			 pstmt.setString(1,dateStr);//appointDate  2013-10-17
			 pstmt.setString(2,comId);//i_company
			 pstmt.setString(3,projId);//i_project
			 pstmt.setString(4,i_type);//i_type 02
			 System.out.println("--->SQL Get time  :"+sql.toString());
			 rs = pstmt.executeQuery();	

			 boolean isDate = false; 
			 System.out.println("TEST 1:"+Utilizer.NowByCalendar("yyyy-MM-dd"));
			 System.out.println("dateStr :"+dateStr);
			 
			 if(Utilizer.NowByCalendar("yyyy-MM-dd").equals(dateStr)){//2013-10-17
				isDate = true;
			 }else{
				isDate = false;
			 }
			 System.out.println("isDate :"+isDate);
			 while(rs.next()) {
					strArr = new ArrayList();	
					getTimeInt = 0;
					tempInt.delete(0,tempInt.length());
					tempInt.append(doString.checkString(rs.getString("q_apptime_fr1"),"00:00")); //11:00					
					strMun.delete(0,strMun.length());
					strSec.delete(0,strSec.length());
					strMun.append(tempInt.toString().substring(0,2));//11
					strSec.append(tempInt.toString().substring(3));//05							
					getTimeInt = Integer.parseInt(strMun+""+strSec);					  
					System.out.println("-->Get time :"+getTimeInt);
					System.out.println("-->current time :"+timeCurrent);														
					if(isDate){						
						if(getTimeInt>=timeCurrent ){
							strArr.add(0,doString.checkString(rs.getString("q_apptime_fr1"),""));					  
							resultList.add(strArr);
						}
					}else{
						strArr.add(0,doString.checkString(rs.getString("q_apptime_fr1"),""));					  
						resultList.add(strArr);
					}						
			 } // End if rs
        	return resultList;			  	 
		}catch(Exception e){
			System.out.println("!!!ListAppointTime$1SVC , " +sysName+":"+ clazzName + " : " + e.getMessage());
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
	public SVC_STDPJ GetSVC_STDPJ(Connection conn, String comId, String projectId) {
		//throws Exception{
		// TODO Auto-generated method stub
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter		
        	//System.out.println("##GetCallCT_STD ->Starting.");   
        	SVC_STDPJ  obj = new SVC_STDPJ();

			/******************************************************/	       	
			sql.delete(0,sql.length());
			sql.append(" Select i_company, i_project, i_prjcal_id, i_gmail, i_password From lan:SVC_STDPJ ")
			   .append(" Where i_company = ? and i_project = ?  ");
			System.out.println(" SQL Get calendar :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString());
			pstmt.setString(1, comId);
			pstmt.setString(2, projectId);
			rs = pstmt.executeQuery();	
			if(rs.next()){				
				obj.setCompanyId(doString.checkString(rs.getString("i_company"),""));
				obj.setProjectId(doString.checkString(rs.getString("i_project"),""));
				obj.setCalendarId(doString.checkString(rs.getString("i_prjcal_id"),""));
				obj.setGmail(doString.checkString(rs.getString("i_gmail"),""));
				obj.setPassword(doString.checkString(rs.getString("i_password"),""));
				obj.setReadOnlyUrl(Constant.GOOLE_CALENDAR_URL1+obj.getCalendarId()+Constant.GOOLE_CALENDAR_URL2);
				obj.setFeedUrl(Constant.FeedUrl1+obj.getCalendarId()+Constant.FeedUrl2);
			}
			rs.close();				
			//********************************************************/
		  	//System.out.println("##GetCallCT_STD ->end.");				  	 
		  	return obj;			  	 
		}catch(Exception e){
			System.out.println("!!!GetSVC_STDPJ , " +sysName+":"+ clazzName + " : " + e.getMessage());
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

	public int InsertSVC_DOCDT(Connection conn,SVC_DOCHD obj) {
		// TODO Auto-generated method stub
		//iType :?
	    //01 =  contact failure && detail  becourse check box
		//02 =  contact successs && detai becourse  no't interest project land.
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter	
        	SVC_DOCDT objItm = null;
        	//System.out.println("##InsertSVC_DOCDT ->Starting.");        	 
			/******************************************************/			

			sql.delete(0, sql.length());
			sql.append(" INSERT INTO lan:svc_docdt ")
			   .append("(i_svc_docno, i_itmno, i_itmsub, c_detail, d_appoint,")
			   .append(" i_docno, f_status, i_calendar_id, d_start, i_employ_start,")
			   .append(" c_start_desc, i_email_start, d_complete, i_employ_complete, i_email_complete,")
			   .append(" c_complete_desc, d_svc_endjob, i_employ_endjob)  ")
			   .append(" VALUES ")
			   .append(" (?, ?, ?, ?, ?,       ")
			   .append(" ?, ?, null, TODAY, ?, ")
			   .append(" '', '', null, '', '', ")
			   .append(" '', null, '')         ");
		    System.out.println("Insert SQL :"+sql.toString());
		    //pstmt = conn.prepareStatement(sql.toString()); 
		    
		    int i = 1;
		    int countRow = 0;

		     if(obj.getSvcDocdtList()!=null && obj.getSvcDocdtList().size()>0){
		        Iterator itDT = obj.getSvcDocdtList().iterator();
		     	while(itDT.hasNext()){
		     	    System.out.println("xxxxxxxxxxx = "+countRow);
		     	    objItm = (SVC_DOCDT)itDT.next();
		     	    i = 1;
		     	    pstmt = conn.prepareStatement(sql.toString());
			    	pstmt.setString(i++,objItm.getI_svc_docno());
			    	pstmt.setString(i++,objItm.getI_itmno());
			    	pstmt.setString(i++,objItm.getI_itmsub());
			    	pstmt.setString(i++,objItm.getC_detail());
			    	pstmt.setString(i++,objItm.getD_appoint()); //2013-10-29 12:00
			    	
			    	pstmt.setString(i++,objItm.getI_docno());
			    	pstmt.setString(i++,objItm.getF_status());
			    	pstmt.setString(i++,objItm.getI_employ_start());
			    	
			    	countRow += pstmt.executeUpdate();
		     	}//#End while
		     }//End if null
		     
			//********************************************************/
		  	//System.out.println("##InsertSVC_DOCDT ->end.");				  	 
		  	return countRow;			  	 
		}catch(Exception e){
			System.out.println("!!InsertSVC_DOCDT , " +sysName+":"+ clazzName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
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
	
	public int InsertSVC_DOCHD(Connection conn, SVC_DOCHD obj) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter		
        	int i=1;
        	//System.out.println("##InsertSVC_DOCHD ->Starting.");        	 
        	
			/******************************************************/					
			sql.delete(0, sql.length());
			sql.append(" INSERT INTO  lan:svc_dochd  ")
					.append(" (i_svc_docno, ")
					.append(" i_tel_ctasia,")
					.append(" i_company,   ")
					.append(" i_project,   ")
					.append(" i_lock,      ")
					.append(" d_keyin,     ")
					.append(" i_customer,  ")
					.append(" i_house,     ")
					.append(" n_customer,  ")
					.append(" n_custel,    ")
					.append(" f_status,    ")
					.append(" i_agent,     ")
					.append(" i_employ,    ")
					.append(" i_date)      ")
					.append(" VALUES (?, ?, ?, ?, ?, CURRENT, ?, ?, ?, ?, ?, ?,?,TODAY) ");
		    //System.out.println("Insert SQL :"+sql.toString());
		    pstmt = conn.prepareStatement(sql.toString()); 
		    //String autoId = this.GenerateAutoID_SVC_DOCHD(conn);		    
		    System.out.println("--->ID:"+obj.getI_svc_docno());
		    pstmt.setString(i++, obj.getI_svc_docno());
		    pstmt.setString(i++, obj.getI_tel_ctasia());
		    pstmt.setString(i++, obj.getI_company());
		    pstmt.setString(i++, obj.getI_project());
		    pstmt.setString(i++, obj.getI_lock());
		    //d_keyin=current	
		    System.out.println("Test xxx :"+obj.getI_customer());
		    pstmt.setInt(i++,Integer.parseInt(obj.getI_customer()));
		    System.out.println("Test xxx :"+obj.getI_customer());
		    pstmt.setString(i++, obj.getI_house());
		    pstmt.setString(i++, obj.getN_customer());
		    pstmt.setString(i++, obj.getN_custel());
		    
		    pstmt.setString(i++, obj.getF_status());//001
		    pstmt.setString(i++, obj.getI_agent());
		    pstmt.setString(i++, obj.getI_employ());
		    //i_date = TODAY 2013-10-22
		    
		    System.out.println("---Insert SQL :"+sql.toString());
		    int intUpd = pstmt.executeUpdate();
		    System.out.println("---Insert Okay..");
			//********************************************************/
		  	//System.out.println("##InsertSVC_DOCHD ->end.");				  	 
		  	return intUpd;			  	 
		}catch(Exception e){
			System.out.println("!!InsertSVC_DOCHD , " +sysName+":"+ clazzName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
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

	public int InsertSVC_TELNO(Connection conn, SVC_TELNO obj) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter		
        	int i=1;
        	//System.out.println("##InsertSVC_DOCHD ->Starting.");        	 
        	
			/******************************************************/					
			sql.delete(0, sql.length());
			sql.append(" INSERT INTO lan:svc_telno     ")
					.append(" (i_tel_ctasia, i_customer, i_company, i_project, i_lock, ")
					.append(" d_create, i_employ_create, d_update, i_employ_update, n_customer, ")
					.append(" i_tel_no, i_email, i_house) ")
					.append(" VALUES (?, ?, ?, ?, ?, CURRENT, ?, null,null, ?, ?, ?, ?) ");
		    System.out.println("Insert SQL :"+sql.toString());
		    pstmt = conn.prepareStatement(sql.toString()); 
		    //String autoId = this.GenerateAutoID_SVC_DOCHD(conn);		    
		    System.out.println("--->ID:"+obj.getITelCtasia());
		    pstmt.setString(i++, obj.getITelCtasia());
		    pstmt.setString(i++, obj.getICustomer());
		    pstmt.setString(i++, obj.getICompany());
		    pstmt.setString(i++, obj.getIProject());
		    pstmt.setString(i++, obj.getILock());
		    //d_create=current
		    pstmt.setString(i++, obj.getIEmployCreate());
		    //d_update=current
		    //iemploy_update
		    pstmt.setString(i++, obj.getNCustomer());
		    
		    pstmt.setString(i++, obj.getITelNo());
		    pstmt.setString(i++, obj.getIEmail());
		    pstmt.setString(i++, obj.getIHouse());
		    //i_date = TODAY 2013-10-22
		    
		    int intUpd = pstmt.executeUpdate();
		    System.out.println("---Insert Okay..");
			//********************************************************/
		  	//System.out.println("##InsertSVC_TELNO ->end.");				  	 
		  	return intUpd;			  	 
		}catch(Exception e){
			System.out.println("!!InsertSVC_TELNO , " +sysName+":"+ clazzName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
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
	 

	public int UpdateESER_DATE(Connection conn, ESER_DATE obj) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter		
        	int i=1;
        	//System.out.println("##UpdateESER_DATE ->Starting.");        	 
        	
			/******************************************************/					
       	 	sql.delete(0,sql.length());
       	 	sql.append(" UPDATE lan:eser_date SET  i_eser_docno = ?  ")
       	 	   .append(" Where  i_company = ?  and i_project = ? and i_date = ? and q_apptime_fr1 = ? and i_date_type = '02' ");
		    System.out.println("Update SQL :"+sql.toString());
		    pstmt = conn.prepareStatement(sql.toString()); 
		    pstmt.setString(i++, obj.getI_eser_docno());
		    pstmt.setString(i++, obj.getI_company());
		    pstmt.setString(i++, obj.getI_project());
		    pstmt.setString(i++, obj.getI_date());
		    pstmt.setString(i++, obj.getQ_apptime_fr1());
		    
		    System.out.println("---Update SQL :"+sql.toString());
		    int intUpd = pstmt.executeUpdate();
		    System.out.println("---Update Okay..");
			//********************************************************/
		  	//System.out.println("##UpdateESER_DATE ->end.");				  	 
		  	return intUpd;			  	 
		}catch(Exception e){
			System.out.println("!!UpdateESER_DATE , " +sysName+":"+ clazzName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
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

	public String GenerateAutoID_SVC_DOCHD(Connection conn) {
		// TODO Auto-generated method stub
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		int id = 0;
		String tempId = "";
		try{		
				//201320210005
				sql.delete(0, sql.length());
				sql.append(" Select max(i_svc_docno[9,12]) as maxid   From lan:svc_dochd Where i_date = today ");
				pstmt = conn.prepareStatement(sql.toString()); 
				rs = pstmt.executeQuery();
				if (rs.next()) {
					//0001
					id = rs.getInt("maxid");
				} // End if rs
				
				if(id>0){
					id++;
					tempId = Utilizer.ThisToDayEngID()+Utilizer.GenNextId(id);
				}else{
					tempId = Utilizer.ThisToDayEngID()+"0001"; //201310210001
				}
				System.out.println("-->MAX_ID :"+tempId);
				return tempId;
		}catch(Exception e){
			e.fillInStackTrace();
			System.out.println(clazzName+":GenerateAutoID_SVC_DOCHD :"+e.toString());
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

	public List ListHistoryHomeRepairPaging$1Y(Connection conn, String comId, String projId, String houseId, String lock,int startRow,int endRow,int maxRow) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter		
        	int line = 0;
        	Timestamp tmp = null;
        	Calendar calIns = Calendar.getInstance();
        	//System.out.println("##GetCallCT_STD ->Starting.");   
        	List  resultList = new ArrayList();
        	List strArr = null;    	 
        	List tempList = null;  
			//setTransaction 	
        	//176/52
			sql.delete(0,sql.length());
			sql.append("  SELECT first ").append(endRow).append("  case when a.i_doc_type='I' then 'INFORM' else 'OPEN' end status,b.i_house,b.i_lor, a.*  ")
				.append(" FROM lan:serv_dochd a  left join lan:acxlckmd b on b.i_company=a.i_company and b.i_project=a.i_project and b.i_lock=a.i_lock  ")
				.append(" WHERE a.f_status='OPN' and a.i_doc_type = 'J' and (a.i_docno in (SELECT  i_docno FROM lan:serv_docdt e WHERE f_itmstatus<>'CAN'  and i_docno[1,2]='"+comId+"' and i_docno[4,6]='"+projId+"' ")
				.append(" GROUP by i_docno  ))  ")
				.append(" and a.i_company='"+comId+"' and a.i_project='"+projId+"'   and b.i_house='"+houseId+"'  and a.i_lock='"+lock+"'   ")
				.append(" and date(a.d_keyin) <= today  and date(a.d_keyin) >= today-1 units year ")
				.append(" UNION SELECT case when a.i_doc_type='I' then 'INFORM' else 'OPEN' end status,b.i_house,b.i_lor, a.*  ")
				.append(" FROM lan:serv_dochd a  left join lan:acxlckmd b on b.i_company=a.i_company and b.i_project=a.i_project and b.i_lock=a.i_lock ")
				.append(" WHERE a.f_status='OPN' and a.i_doc_type = 'I'  and a.i_company='"+comId+"' and a.i_project='"+projId+"'   ")
				.append(" and b.i_house='"+houseId+"'  and a.i_lock='"+lock+"'  and date(a.d_keyin) <= today  and date(a.d_keyin) >= today-1 units year  order by 4 ");
	
			System.out.println("SQL History $1Y :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString()); 

			rs = pstmt.executeQuery();
			for (int i=0;i<maxRow;i++) { 
	                if (rs.next()) {
	                   if (i>=startRow && i<=endRow) {	
	                	   	tmp = null;
		   					strArr = new ArrayList();
		   					strArr.add(0,doString.checkString(rs.getString("status"),""));//1			  
		   					strArr.add(1,doString.checkString(rs.getString("i_docno"),""));//2
		   					strArr.add(2,doString.checkString(rs.getString("i_lock"),"-"));	
		   					strArr.add(3,doString.checkString(rs.getString("i_house"),"-"));
		   					strArr.add(4,doString.checkString(rs.getString("n_customer"),""));
		   					strArr.add(5,doString.checkString(rs.getString("n_cus_tel"),""));
		   					strArr.add(6,doString.checkString(rs.getString("i_doc_type"),""));
		   					strArr.add(7,doString.checkString(rs.getString("i_company"),""));
		   					strArr.add(8,doString.checkString(rs.getString("i_project"),""));
		   					
		   					//Call Service
		   					tempList = this.ListCustomerDetail$1Y(conn, comId, projId, lock);
		   					if(tempList!=null && tempList.size()>0){
		   						strArr.add(9,doString.checkString(tempList.get(0).toString(),""));//n_customer
		   						strArr.add(10,doString.checkString(tempList.get(1).toString(),""));//n_cust_tel
		   					}else{
		   						strArr.add(9,"-");
		   						strArr.add(10,"-");
		   					}		            
		   	                //---- Keyin Date ----// 
		   				    tmp = rs.getTimestamp("d_keyin");
		   				    if(tmp!=null){
		   				    	calIns.setTime(tmp);      
		   						strArr.add(11,Utilizer.GetDateFromCalendar(calIns));
		   						strArr.add(12,Utilizer.GetTimeFromCalendar(calIns));
		   				    }else{
		   						strArr.add(11,"-");
		   						strArr.add(12,"-");
		   				    }
		   				    //---------------------------------
		   				    if(!doString.checkString(rs.getString("status"),"").equalsIgnoreCase("INFORM")) {
		   				    	//TODO:status 100,200,300,400
		   				    	strArr.add(13,this.GetStatus$SERV_DOCDT(conn,doString.checkString(rs.getString("i_docno"),"")));
		   					}else{
		   						//TODO : No status
		   						strArr.add(13,"-");
		   					}
		   				   resultList.add(strArr);	

			       		  line++;                         
	                   } //--end if check row
		               if (i>endRow){ 
		              	 break;
		               }
	                } //end if check rs
		        } // end for
				//********************************************************/				
        	return resultList;			  	 
		}catch(Exception e){
			System.out.println("!!!ListHistoryHomeRepairPaging$1Y , " +sysName+":"+ clazzName + " : " + e.getMessage());
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

	//Return formate :xxxx|0841013129
	public List ListCustomerDetail$1Y(Connection conn, String comId, String projId, String lock) {
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		//String resultStr = "";
		try{		
				String customerId = "";
				List strList = new ArrayList();
				//201320210005
				sql.delete(0, sql.length());
				sql.append(" Select a.i_lor,a.i_model,a.i_house,a.i_lock,b.i_exp_intent1,b.i_cus_intent1,b.d_close_law ")
					.append(" From lan:acxlckmd a  left join lan:acscontr b on b.i_company=a.i_company and b.i_project=a.i_project  and b.i_lor=a.i_lor and b.f_contr is null  ")
					.append(" Where a.i_company= ?  and a.i_project= ?  and a.i_lock= ?  ");
				System.out.println("SQL#1 :"+sql.toString());
				pstmt = conn.prepareStatement(sql.toString()); 
				pstmt.setString(1, comId);
				pstmt.setString(2, projId);
				pstmt.setString(3, lock);
				rs = pstmt.executeQuery();
				if(rs.next()){
					//0001
					customerId = doString.checkString(rs.getString("i_cus_intent1"),"");
					if (customerId.length()<=0) {
						customerId = doString.checkString(rs.getString("i_exp_intent1"),"");
					}
				} // End if rs
				rs = null;
				//-------------------------------------------------------------------------
				sql.delete(0,sql.length());				
				sql.append(" Select n_prename,n_ncustomer,n_scustomer,a_id_tel,a_wk_tel,a_etc_tel From lan:acxcusto Where i_customer='").append(customerId).append("' ");				
				//System.out.println("SQL#2 :"+sql.toString());
				pstmt = conn.prepareStatement(sql.toString()); 
				rs = pstmt.executeQuery();
				if(rs.next()){
						String custName = doString.checkString(rs.getString("n_prename"),"");
						custName += doString.checkString(rs.getString("n_ncustomer"),""); 
						custName += " "+doString.checkString(rs.getString("n_scustomer"),""); 
						//System.out.println("--->custName :"+custName);
						//---========= Get Tel from id , work , etc ==========-----//
						String nCustTel = doString.checkString(rs.getString("a_id_tel"),"");
						System.out.println("--->nCustTel :"+nCustTel);
						String tel = doString.checkString(rs.getString("a_wk_tel"),"");
						System.out.println("--->tel :"+tel);
						if (tel.length()>0) {
							nCustTel += (nCustTel.length()>0) ? " , "+tel : tel;
						}
						tel = doString.checkString(rs.getString("a_etc_tel"),"");
						System.out.println("--->tel2 :"+tel);
						if (tel.length()>0) {
							nCustTel += (nCustTel.length()>0) ? " , "+tel : tel;
						}	
						//resultStr =custName+"|"+nCustTel;
						strList.add(0, custName);
						strList.add(1, nCustTel);
						System.out.println("--->custName :"+custName);
						System.out.println("--->nCustTel :"+nCustTel);
				} // end while
				return strList;
		}catch(Exception e){
			e.fillInStackTrace();
			System.out.println(clazzName+":GetCustomerDetail$1Y :"+e.toString());
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

	public String GetStatus$SERV_DOCDT(Connection conn, String docId) {
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String tempId = "";
		try{		
				//201320210005
				sql.delete(0, sql.length());
			    sql.append(" Select max(f_itmstatus) mx_status From lan:serv_docdt Where f_itmstatus<>'CAN' ")
		             .append(" and i_docno='").append(docId).append("' ");
				pstmt = conn.prepareStatement(sql.toString()); 
				rs = pstmt.executeQuery();
				if (rs.next()) {
					tempId = doString.checkString(doString.DisplayThai(rs.getString("mx_status")),"");
			         if (tempId.equals("200")) {
			           //---================== Open Status ==================---//
			        	 tempId = "Open Job";
			         } else if (tempId.equals("300")) {
			            //---=============== Start task , No edit ===========---//
			        	 tempId = "Start Task";
			         } else if (tempId.equals("400")) {
			            //---============= Complete task , No edit ==========---//
			        	 tempId = "Complete Task";
			         } else {
			             //---============ Unknown Status , No edit =========---// 
			        	 tempId = "-";
			         }
				} // End if rs
				return tempId;
		}catch(Exception e){
			e.fillInStackTrace();
			System.out.println(clazzName+":GetStatus$SERV_DOCDT :"+e.toString());
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

	public int UpdateSVC_DOCDT(Connection conn, SVC_DOCDT obj) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter		
        	int i=1;
        	//System.out.println("##UpdateSVC_DOCDT$GCalendarId ->Starting.");        	 
        	
			/******************************************************/		
       	 	sql.delete(0,sql.length());
       	 	sql.append(" UPDATE lan:SVC_DOCDT SET i_calendar_id = ? ");
       	 	
       	 	//value is null or Empty skip not' update record
       	   if(Utilizer.isValueStrAndObj(obj.getI_itmsub())){
				sql.append(" , i_itmsub = '").append(obj.getI_itmsub()).append("' ");
			}
			if(Utilizer.isValueStrAndObj(obj.getC_detail())){
				sql.append(" ,c_detail = '").append(obj.getC_detail()).append("' ");
			}
			if(Utilizer.isValueStrAndObj(obj.getD_appoint())){
				sql.append(" ,d_appoint = '").append(obj.getD_appoint()).append("' ");
			}
			if(Utilizer.isValueStrAndObj(obj.getI_docno())){
				sql.append(" ,i_docno = '").append(obj.getI_docno()).append("' ");
			}
			if(Utilizer.isValueStrAndObj(obj.getD_start())){
				sql.append(" ,d_start = ").append(obj.getD_start()).append(" ");//TODAY
			}
			if(Utilizer.isValueStrAndObj(obj.getI_employ_start())){
				sql.append(" ,i_employ_start = '").append(obj.getI_employ_start()).append("' ");
			}
			if(Utilizer.isValueStrAndObj(obj.getC_start_desc())){
				sql.append(" ,c_start_desc = '").append(obj.getC_start_desc()).append("' ");
			}

			if(Utilizer.isValueStrAndObj(obj.getI_email_start())){
				sql.append(" ,i_email_start = '").append(obj.getI_email_start()).append("' ");
			}
			if(Utilizer.isValueStrAndObj(obj.getD_complete())){
				sql.append(" ,d_complete = ").append(obj.getD_complete()).append(" ");//TODAY
			}

			if(Utilizer.isValueStrAndObj(obj.getI_employ_complete())){
				sql.append(" ,i_employ_complete = '").append(obj.getI_employ_complete()).append("' ");
			}

			if(Utilizer.isValueStrAndObj(obj.getI_email_complete())){
				sql.append(" ,i_email_complete = '").append(obj.getI_email_complete()).append("' ");
			}

			if(Utilizer.isValueStrAndObj(obj.getC_complete_desc())){
				sql.append(" ,c_complete_desc = '").append(obj.getC_complete_desc()).append("' ");
			}

			sql.append(" WHERE i_svc_docno = ? ");
			if(Utilizer.isValueStrAndObj(obj.getI_itmno())){
				sql.append(" AND i_itmno = '").append(obj.getI_itmno()).append("' ");//01
			}
			/*if(Utilizer.isValueStrAndObj(obj.getI_itmsub())){
				sql.append(" AND i_itmsub = '").append(obj.getI_itmsub()).append("' ");
			}*/
			if(Utilizer.isValueStrAndObj(obj.getF_status())){//001
				sql.append(" AND f_status = '").append(obj.getF_status()).append("' ");
			}

		    pstmt = conn.prepareStatement(sql.toString()); 
		    pstmt.setString(i++, obj.getI_calendar_id());
		    pstmt.setString(i++, obj.getI_svc_docno());

		    System.out.println("---Update SQL :"+sql.toString());
		    int intUpd = pstmt.executeUpdate();
		    System.out.println("---Update Okay..");
			//********************************************************/
		  	//System.out.println("##UpdateSVC_DOCDT->end.");				  	 
		  	return intUpd;			  	 
		}catch(Exception e){
			System.out.println("!!UpdateSVC_DOCDT , " +sysName+":"+ clazzName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
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

	//true = duplicate please Update function
	//false = not dup  please Insert function
	public boolean IsDuplicate$SVC_TELNO(Connection conn, String tel,String comId,String  projectId) {
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		boolean isResult = false;
		try{		
				//201320210005
				sql.delete(0, sql.length());
				sql.append(" Select i_tel_ctasia  From lan:SVC_TELNO Where i_tel_ctasia = ? and i_company = ? and i_project = ? ");
				pstmt = conn.prepareStatement(sql.toString()); 
				pstmt.setString(1,tel);
				pstmt.setString(2,comId);
				pstmt.setString(3,projectId);
				rs = pstmt.executeQuery();
				if(rs.next()){
					doString.checkString(rs.getString("i_tel_ctasia"), "");
					isResult = true;
				} // End if rs
				
				return isResult;
		}catch(Exception e){
			e.fillInStackTrace();
			System.out.println(clazzName+":IsDuplicate$SVC_TELNO :"+e.toString());
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

	public int UpdateSVC_TELNO(Connection conn, SVC_TELNO obj) {
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		//int i = 1;
		//***********
		try{
				//***************************************/
				sql.delete(0, sql.length());
				sql.append(" UPDATE lan:SVC_TELNO SET  d_update = CURRENT ");

				//value is null or Empty skip not' update record
				if(Utilizer.isValueStrAndObj(obj.getICustomer())){
					sql.append(" ,i_customer = '").append(obj.getICustomer()).append("' ");
				}
				
				/*if(Utilizer.isValueStrAndObj(obj.getICompany())){
					sql.append(" ,i_company = '").append(obj.getICompany()).append("' ");
				}
				
				if(Utilizer.isValueStrAndObj(obj.getIProject())){
					sql.append(" ,i_project = '").append(obj.getIProject()).append("' ");
				}*/

				if(Utilizer.isValueStrAndObj(obj.getILock())){
					sql.append(" ,i_lock = '").append(obj.getILock()).append("' ");
				}

				if(Utilizer.isValueStrAndObj(obj.getIEmploy_update())){
					sql.append(" ,i_employ_update = '").append(obj.getIEmploy_update()).append("' ");
				}
				
				if(Utilizer.isValueStrAndObj(obj.getNCustomer())){
					sql.append(" ,n_customer = '").append(obj.getNCustomer()).append("' ");
				}
				
				if(Utilizer.isValueStrAndObj(obj.getITelNo())){
					sql.append(" ,i_tel_no = '").append(obj.getITelNo()).append("' ");
				}
				
				if(Utilizer.isValueStrAndObj(obj.getIEmail())){
					sql.append(" ,i_email = '").append(obj.getIEmail()).append("' ");
				}
				if(Utilizer.isValueStrAndObj(obj.getIHouse())){
					sql.append(" ,i_house = '").append(obj.getIHouse()).append("' ");
				}

				sql.append(" Where i_tel_ctasia = ? ")
				   .append(" and i_company = '").append(obj.getICompany()).append("' ")
				   .append(" and i_project = '").append(obj.getIProject()).append("' ");
				
				System.out.println("-->Update SQL :"+sql.toString());
				pstmt = conn.prepareStatement(sql.toString()); 
				pstmt.setString(1,obj.getITelCtasia());
				int intUdp = pstmt.executeUpdate();
	   			
	   		  	/********************************/		
				//System.out.println("##UpdateSVC_TELNO : successfully.");
	   		  	return intUdp;			
		}catch(Exception e){
			System.out.println("!!!UpdateSVC_TELNO , " +sysName+":"+ clazzName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
			return -1; // update failure
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

	public SVC_DOCDT GetSVC_DOCDT(Connection conn, String docNo, String type, String code, String fdate, String status) {
		// TODO Auto-generated method stub
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter		
        	//System.out.println("##GetCallCT_STD ->Starting.");   
        	SVC_DOCDT  obj = null;

			/******************************************************/	
			sql.delete(0,sql.length());
			sql.append(" Select  ")
			   .append(" i_svc_docno, i_itmno, i_itmsub, c_detail, d_appoint, i_docno, f_status, i_calendar_id, d_start, ")
			   .append(" i_employ_start, c_start_desc, i_email_start, d_complete, i_employ_complete, i_email_complete, ")
			   .append(" c_complete_desc, d_svc_endjob, i_employ_endjob ")
			   .append(" From lan:SVC_DOCDT ")
			   .append(" Where i_svc_docno = ?   ")
			   .append(" and i_itmno =  ? ")
			   .append(" and i_itmsub = ? ")
			   .append(" and d_appoint = ? ")
			   .append(" and f_status = ? ");
			
			System.out.println(" SQL getSVC_DOCDT:"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString());
			pstmt.setString(1, docNo);
			pstmt.setString(2, type);
			pstmt.setString(3, code);
			pstmt.setString(4, fdate);
			pstmt.setString(5, status);
			rs = pstmt.executeQuery();	
			if(rs.next()){	
				obj = new SVC_DOCDT();
				obj.setI_svc_docno(doString.checkString(rs.getString("i_svc_docno"),""));
				obj.setI_itmno(doString.checkString(rs.getString("i_itmno"),""));
				obj.setI_itmsub(doString.checkString(rs.getString("i_itmsub"),""));
				obj.setC_detail(doString.checkString(rs.getString("c_detail"),""));
				obj.setD_appoint(doString.checkString(rs.getString("d_appoint"),""));
				obj.setI_docno(doString.checkString(rs.getString("i_docno"),""));
				obj.setF_status(doString.checkString(rs.getString("f_status"),""));
				obj.setI_calendar_id(doString.checkString(rs.getString("i_calendar_id"),""));
				obj.setD_start(doString.checkString(rs.getString("d_start"),""));
				obj.setI_employ_start(doString.checkString(rs.getString("i_employ_start"),""));
				obj.setC_start_desc(doString.checkString(rs.getString("c_start_desc"),""));
				obj.setI_email_start(doString.checkString(rs.getString("i_email_start"),""));
				obj.setD_complete(doString.checkString(rs.getString("d_complete"),""));
				obj.setI_employ_complete(doString.checkString(rs.getString("i_employ_complete"),""));
				obj.setI_email_complete(doString.checkString(rs.getString("i_employ_complete"),""));
				obj.setC_complete_desc(doString.checkString(rs.getString("c_complete_desc"),""));
				obj.setD_svc_endjob(doString.checkString(rs.getString("d_svc_endjob"),""));
				obj.setI_employ_endjob(doString.checkString(rs.getString("i_employ_endjob"),""));
			}
			rs.close();				
			//********************************************************/
		  	//System.out.println("##GetCallCT_STD ->end.");				  	 
		  	return obj;			  	 
		}catch(Exception e){
			System.out.println("!!!GetSVC_DOCDT , " +sysName+":"+ clazzName + " : " + e.getMessage());
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

	public int GenerateOpenJob$SERV_DOCHD(Connection conn,String autoId, String comId, String projectId, String lock, String nCustomer, String nCustel, String employId,String desc) {
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try{		
				int i_cut_type = 0;
				sql.delete(0,sql.length());
				sql.append("  Select d_effective,i_cut_type  from lan:serv_cutlck  ")
				.append(" Where i_company = ?  and i_project = ? and i_lock = ?  and d_effective <= TODAY order by d_effective desc ");
				System.out.println("SQL i_cut_type :"+sql.toString());
				pstmt = conn.prepareStatement(sql.toString()); 
			  	pstmt.setString(1,comId);//ID
			  	pstmt.setString(2,projectId);//ID
			  	pstmt.setString(3,lock);//ID
				rs = pstmt.executeQuery();
				//System.out.println("-->SQL#2:"+sql);
				if(rs.next()){
					i_cut_type = rs.getInt("i_cut_type");
				}
				rs.close();
				//-------------------------------
				
				/********************************************************************/
				sql.delete(0, sql.length());
				sql.append(" INSERT INTO lan:serv_dochd (i_docno      ,")//1
						.append(" i_doc_type        ,")//2
						.append(" i_company         ,")//3
						.append(" i_project        ,")//4
						.append(" i_lock            ,")//5
						.append(" d_keyin           ,")//6
						.append(" n_customer        ,")//7
						.append(" n_cus_tel         ,")//8
						.append(" c_desc            ,")//9
						.append(" d_job             ,")//10
						.append(" f_status          ,")//11
						.append(" d_appoint         ,")//12 
						.append(" d_est_close       ,")//13
						.append(" d_close           ,")//14
						.append(" i_service_employ  ,")//15 
						.append(" i_type_cutlck     ,")//16
						.append(" i_employ_pinform  ,")//17 
						.append(" d_print_job       ,")//18
						.append(" i_employ_pjob     ,")//19
						.append(" f_reject          ,")//20
						.append(" i_employ_reject   ,")//21
						.append(" d_reject          ,")//22
						.append(" c_reject          )")//23					
						.append("  VALUES (?, 'I', ?, ?,  ?, current, ?, ?, ?, null, 'OPN', null, null, null, ? , ?, null ,null ,null , 'N',  null, null,  null) "); 			
				                         //1   2   3  4   5    6      7  8  9   10    11    12    13     14   15  16  17    18    19     20     21    22     23
				System.out.println("AUTO_ID:"+autoId);
				int i = 1;
				pstmt = conn.prepareStatement(sql.toString()); 
	   		  	pstmt.setString(i++, autoId);//1.DOC_ID
	   		  	pstmt.setString(i++, comId);//3.i_com
	   		  	pstmt.setString(i++, projectId);//4.i_proj
	   		    pstmt.setString(i++, lock);//5.lock
	   		  	pstmt.setString(i++, nCustomer);//7.n_customer
	   		  	pstmt.setString(i++, nCustel);//8.n_cus_tel
	   		  	pstmt.setString(i++, desc);//9.c_desc
	   		  	pstmt.setString(i++, employId);//15.i_service_employ
	   		  	pstmt.setInt(i++, i_cut_type);//16.i_type_cutlck
	   		  	System.out.println("--->"+sql.toString());
	   		  	int countRow =  pstmt.executeUpdate(); 
	   		  	//*******************************************************/
	   		  	
				return countRow;
		}catch(Exception e){
			e.fillInStackTrace();
			System.out.println(clazzName+":GenerateOpenJob$SERV_DOCHD :"+e.toString());
			System.out.println(" SQL Exception: "+sql.toString());	
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

	public String GenerateAutoID_SERV_DOCHD(Connection conn,String comId,String projectId) {
		// TODO Auto-generated method stub
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		int id = 0;
		String tempId = "";
		try{		
				sql.delete(0, sql.length());
				sql.append("  select max(i_docno[10,14]) as maxid from lan:serv_dochd where i_company = ? and i_project = ?  and  i_docno[8,9] = ? ");
				
				pstmt = conn.prepareStatement(sql.toString()); 
				pstmt.setString(1,comId);
				pstmt.setString(2,projectId);
				pstmt.setString(3,Utilizer.GetThaiCurrentDDMMYYYY().substring(8));
	
				rs = pstmt.executeQuery();
				if (rs.next()) {
					//0001
					id = rs.getInt("maxid");
				} // End if rs
	
				if(id>0){
					id++;
					tempId = comId+"-"+projectId+"-"+Utilizer.GetThaiCurrentDDMMYYYY().substring(8)+Utilizer.GenNextID4Digit(id);
				}else{
					tempId = comId+"-"+projectId+"-"+Utilizer.GetThaiCurrentDDMMYYYY().substring(8)+"00001";
				}
				System.out.println("-->MAX_ID :"+tempId);
				return tempId;
		}catch(Exception e){
			e.fillInStackTrace();
			System.out.println(clazzName+":GenerateAutoID_SERV_DOCHD :"+e.toString());
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

	public int GetCountRowByHistoryContactDocHD(Connection conn, String comId, String projId, String lock) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		int totalRow=0; 
        try{
        	//initial paramter	
			/******************************************************/
        	sql.delete(0,sql.length());
			sql.append(" Select  count(*)as totalRow ")
			   .append(" From lan:svc_dochd ")
			   .append(" Where ")
			   .append(" i_company = ? and i_project = ?  and i_lock = ? ");
			System.out.println("Get count Row :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1,comId);
			pstmt.setString(2,projId);
			pstmt.setString(3,lock);
			rs = pstmt.executeQuery();	
			if(rs.next()){				
				totalRow = rs.getInt("totalRow");
			}
			rs.close();				
			//********************************************************/
		  	//System.out.println("##GetCountRowByHistoryContactDocHD ->End.");				  	 
		  	return totalRow;			  	 
		}catch(Exception e){
			System.out.println("!!!GetCountRowByHistoryContactDocHD , " +sysName+":"+ clazzName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
			return totalRow;
		}
		finally{			
			//clean up.
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
			}catch(Exception e){}
		}
	}
	
	public List ListHistoryContactDocHD(Connection conn, String comId, String projId, String lock) {
		// TODO Auto-generated method stub
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter 
        	List  listDocHd = new ArrayList();
        	SVC_DOCHD  objDoc = null;
        	int MAX_ROW = 0;
        	
        	MasterSvcService msService = new MasterSvcServiceImpl();
        	ServiceCenterCallService callSerice = new ServiceCenterCallServiceImpl();
        	//System.out.println("ListProjectName ->Starting.");        	 
			/******************************************************/	
          	//*****Find project by user login  
			sql.delete(0,sql.length());
			sql.append(" Select  i_company,i_project,i_lock,date(d_keyin) as dd,i_svc_docno,i_employ,n_customer ")
			   .append(" From lan:svc_dochd ")
			   .append(" Where ")
			   .append(" i_company = ? and i_project = ?  and i_lock = ? ")
			   .append(" Order by dd desc ");
			
			System.out.println("SQL ListHistoryContactDocHD:"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, comId);
			pstmt.setString(2, projId);
			pstmt.setString(3, lock);
			rs = pstmt.executeQuery();	
			while(rs.next()){
				if(MAX_ROW<3){
					objDoc = new SVC_DOCHD();
					objDoc.setI_company(doString.checkString(rs.getString("i_company"), ""));
					objDoc.setI_project(doString.checkString(rs.getString("i_project"), ""));
					objDoc.setI_lock(doString.checkString(rs.getString("i_lock"), ""));
					objDoc.setD_keyin(doString.checkString(rs.getString("dd"), ""));
					objDoc.setI_svc_docno(doString.checkString(rs.getString("i_svc_docno"), ""));
					objDoc.setI_employ(doString.checkString(rs.getString("i_employ"), ""));
					
					//*****call service get employ name
					objDoc.setEmployName(msService.GetNameEmploy(conn,objDoc.getI_employ()));
					
					objDoc.setN_customer(doString.checkString(rs.getString("n_customer"), ""));
					//objDoc
					objDoc.setSvcDocdtList((ArrayList)callSerice.ListSCV$DOCDT(conn, objDoc.getI_svc_docno()));
					System.out.println("---TEST x :"+objDoc.getSvcDocdtList().size());
					listDocHd.add(objDoc);
					MAX_ROW++;
				}else{
					break;
				}
			}
			rs.close();				
			//********************************************************/
		  	System.out.println("-->listDocHd :"+listDocHd.size());				  	 
		  	return listDocHd;			  	 
		}catch(Exception e){
			System.out.println("!!!ListHistoryContactDocHD , " +sysName+":"+ clazzName + " : " + e.getMessage());
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

	public int GetCountRowByHistoryHomeRepair$1Y(Connection conn, String comId, String projId, String houseId, String lock) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		int totalRow=0; 
        try{
        	//initial paramter	
			/******************************************************/
        	sql.delete(0,sql.length());
			sql.append("  SELECT case when a.i_doc_type='I' then 'INFORM' else 'OPEN' end status,b.i_house,b.i_lor, a.*  ")
				.append(" FROM lan:serv_dochd a  left join lan:acxlckmd b on b.i_company=a.i_company and b.i_project=a.i_project and b.i_lock=a.i_lock  ")
				.append(" WHERE a.f_status='OPN' and a.i_doc_type = 'J' and (a.i_docno in (SELECT  i_docno FROM lan:serv_docdt e WHERE f_itmstatus<>'CAN'  and i_docno[1,2]='"+comId+"' and i_docno[4,6]='"+projId+"' ")
				.append(" GROUP by i_docno  ))  ")
				.append(" and a.i_company='"+comId+"' and a.i_project='"+projId+"'   and b.i_house='"+houseId+"'  and a.i_lock='"+lock+"'   ")
				.append(" and date(a.d_keyin) <= today  and date(a.d_keyin) >= today-1 units year ")
				.append(" UNION SELECT case when a.i_doc_type='I' then 'INFORM' else 'OPEN' end status,b.i_house,b.i_lor, a.*  ")
				.append(" FROM lan:serv_dochd a  left join lan:acxlckmd b on b.i_company=a.i_company and b.i_project=a.i_project and b.i_lock=a.i_lock ")
				.append(" WHERE a.f_status='OPN' and a.i_doc_type = 'I'  and a.i_company='"+comId+"' and a.i_project='"+projId+"'   ")
				.append(" and b.i_house='"+houseId+"'  and a.i_lock='"+lock+"'  and date(a.d_keyin) <= today  and date(a.d_keyin) >= today-1 units year  ");
	
			System.out.println("Get Java Count SQL History $1Y :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString()); 

			rs = pstmt.executeQuery();
			while(rs.next()){
				totalRow ++;
			}
			rs.close();				
			//********************************************************/
		  	//System.out.println("##GetCountRowByHistoryHomeRepair$1Y ->End.");				  	 
		  	return totalRow;			  	 
		}catch(Exception e){
			System.out.println("!!!GetCountRowByHistoryHomeRepair$1Y , " +sysName+":"+ clazzName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
			return totalRow;
		}
		finally{			
			//clean up.
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
			}catch(Exception e){}
		}
	}

	public void RestoreESER_DATE(Connection conn, String docId,String employId) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;

        try{
        	//initial paramter	
        	int i = 1;
			/********************************************************************/
		  	String iDate = "";
		  	String iTime = "";
		  	String iCom = "";
		  	String iProj = "";
		  	boolean isFlagUp = false;
		  	
		  	sql.delete(0,sql.length());
			sql.append(" Select i_company,i_project,i_date,q_apptime_fr1 From lan:eser_date  ")
		   		.append(" where  i_eser_docno =? ");			
			 pstmt = conn.prepareStatement(sql.toString()); 
			 pstmt.setString(1,docId);//doc
			 System.out.println("--->Retrive record date old :"+sql.toString());
			 rs = pstmt.executeQuery();
			 if(rs.next()){
				 iDate = doString.checkString(rs.getString("i_date"),"");
				 iTime = doString.checkString(rs.getString("q_apptime_fr1"),"");
				 iCom  = doString.checkString(rs.getString("i_company"),"");
				 iProj = doString.checkString(rs.getString("i_project"),"");
				 isFlagUp = true;
			 }
			 
			 System.out.println("##RestoreESER_DATE  :"+isFlagUp);	
   		   /********************************************************************/
			 if(isFlagUp){
				sql.delete(0,sql.length());
				sql.append(" UPDATE lan:eser_date SET  i_eser_docno = null ,d_cancel = current ,i_employ_can=? ")
					.append(" Where  i_company = ?  and i_project = ? and i_date = ? and q_apptime_fr1 = ? and i_date_type = '02' ");
				pstmt = conn.prepareStatement(sql.toString()); 			
				pstmt.setString(i++, employId);//i_eser_docno
	   		  	pstmt.setString(i++, iCom);//3.i_com
	   		  	pstmt.setString(i++, iProj);//4.i_proj
				pstmt.setString(i++, iDate);//i_date
				pstmt.setString(i++, iTime);//q_apptime_fr1
			  	//System.out.println("-->SQL#2:"+sql.toString());
			  	pstmt.executeUpdate();
			  	System.out.println("--> RestoreESER_DATE successfully.");
			 }

			 rs.close();	
			//********************************************************/
		  	System.out.println("##RestoreESER_DATE ->End.");				  	 			  	 
		}catch(Exception e){
			System.out.println("!!!RestoreESER_DATE , " +sysName+":"+ clazzName + " : " + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
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


