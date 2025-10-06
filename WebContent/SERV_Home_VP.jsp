<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %> 
<%@ page import="com.svc.call.utilize.*" %>
<%--
//last modify by : pradoem@lh.co.th
//last date:2012-08-07
//description: Add entrance link for E-Service OpenJob
//version:1.0
 --%>

<%!



    /**
 * Modify by : pradoem@lh.co.th
 * date : 2021.06.23
 * version 1.1
 * desc: Verify your SVC Account from table lan:svc_agent 
 * for grant permission menu SVC
 */ 
     /*
     * lee  select ALL ddl, and serv_pstaff = LHALL  : not jont pstaff
     * sanya select ALL ddl, and serv_pstaff = '' : jont pstaff 
     */


     public boolean IsLHALL(Connection conn,String userId,String sel_project){
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        String allProject = "";
        boolean isRecord = false;
        try {
            stmt = conn.createStatement();
  			sql.delete(0, sql.length());
			sql.append("  select a.com_id, a.proj_id from lan:serv_pstaff a  ")
				.append(" where a.user_id = '"+userId+"' ")
				.append(" and com_id ='LH' and proj_id = 'ALL' ");
				//System.out.println("SQL  :"+sql.toString());
				rs = stmt.executeQuery(sql.toString());    				   
			    if(rs.next()){
			       allProject  = doString.checkString(rs.getString("proj_id"),"");
			       isRecord = true;
			    } 		
             rs.close();
             stmt.close();
             //System.out.println("sel_project="+sel_project);
             //System.out.println("allProject="+allProject);
             
             if("ALL".equals(allProject)){ //all case p'lee = LH-ALL
              	return false;
             }else{
             	  if("ALL".equals(sel_project)){ //all case user
             	 	isRecord = true;
             	  }else{
                  	isRecord = false;
             	  }
             	  //System.out.println("isRecord="+isRecord);
            	  return isRecord;
             }
        }catch(Exception e) {
            System.out.println("!! IsLHALL Error : " + e.getMessage());
            return false;
        } finally{
            try  {
                if(rs != null) {
                    rs.close();
                }
                if(stmt != null){
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
    }
 
    public boolean IsGrantPermissionSvc(Connection conn,String employId){
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        String tempId = "";
        boolean isRecord = false;
        try {
            stmt = conn.createStatement();
  			sql.delete(0, sql.length());
			sql.append(" select i_employ from lan:svc_agent ")
				.append(" where i_employ = '"+employId+"' ");
				//System.out.println("SQL  :"+sql.toString());
				rs = stmt.executeQuery(sql.toString());    				   
			    if(rs.next()){
			       tempId  = doString.checkString(rs.getString("i_employ"),"");
			       isRecord = true;
			    } 		
                rs.close();
                stmt.close();
        }catch(Exception e) {
            System.out.println(" IsGrantPermissionSvc Error : " + e.getMessage());
        } finally{
            try  {
                if(rs != null) {
                    rs.close();
                }
                if(stmt != null){
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return isRecord;
    }

    
  public int getCountValue(Statement stmt,String sql,ServLog servlog) throws Exception {
       int result = 0;
	   servlog.startLog(sql.toString());
       ResultSet rs = stmt.executeQuery(sql);
	   servlog.endLog();
       if (rs.next()) {
          result = rs.getInt(1);
       }
       rs.close();    
       return result;
  }
  
  public int countResultRow(Statement stmt,String sql,ServLog servlog) throws Exception {
       int result = 0;
	   servlog.startLog(sql.toString());
       ResultSet rs = stmt.executeQuery(sql);
	   servlog.endLog();
       while (rs.next()) {
          result++;
       }
       rs.close();       
       return result;
  }  
  
  public String getDateFromResultSet(ResultSet rs,String fieldName) throws Exception {
      String result = "";      
	  Calendar cal = Calendar.getInstance();
	  Timestamp tmp = rs.getTimestamp(fieldName);
	
	  if (tmp!=null)  {
	      cal.setTime(tmp);
	      result = getDateFromCalendar(cal);
	  }      
      
      return result;
  }

	public String genProjectListboxByUserId(Connection conn,String userId,String name,String value,String params,boolean getAllProj) {
		 StringBuffer html = new StringBuffer();
		 StringBuffer sql = new StringBuffer();
		Statement stmt = null;
		 ResultSet rs = null;
		 boolean allProject = false;
		 SERV_CommonData common = new SERV_CommonData(conn);

		 try {
			stmt = conn.createStatement();
			//---============= Check user is vendor or employee ===============----//
			String userWho = "";
			String iPerson = "";	

			sql.delete(0,sql.length());
			//remark by pradoem 2012.04.24: sql.append(" select * from lan:useracl where user_id='").append(userId).append("' and user_acl='S' ");
			sql.append(" select user_id,user_acl,user_who,i_person from lan:useracl where user_id='").append(userId).append("' and user_acl='S' ");
			rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
				userWho = doString.checkString(rs.getString("user_who"),""); 
				iPerson = doString.checkString(rs.getString("i_person"),""); 		
			}
			rs.close();			

			///----=============== Generate Query for Vendor and Employee ==================---//

			if (userWho.equalsIgnoreCase(Constants.PERMISSION_VENDOR)) {
				sql.delete(0,sql.length());
				sql.append(" select (a.i_company) as com_id, (a.i_project) as proj_id, b.n_project from lan:serv_venprj a ")
					  .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
					  .append(" where a.i_vendor='").append(iPerson).append("' ")
					  .append(" and a.i_type='01' order by a.i_company, a.i_project ");
			} else {
				 sql.delete(0,sql.length());
				 sql.append(" select a.com_id, a.proj_id, b.n_project  from lan:serv_pstaff a ")
					   .append(" left join lan:acxprojt b on b.i_company=a.com_id  and  b.i_project=a.proj_id ")
					   .append(" where a.user_id = '").append(userId).append("' ")
					   .append(" order by a.com_id,a.proj_id ");

			}
			 rs = stmt.executeQuery(sql.toString());
			 //-------============== Generate List box ===================------//
			 html.append("<select name='").append(name).append("' ").append(params).append(" >");
			 html.append("<option value=''>"+Constants.LISTBOX_SELECT_LABEL+"</option>");

			 while (rs.next()) {
				String comId = doString.checkString(rs.getString("com_id"),"");
				String projId = doString.checkString(rs.getString("proj_id"),"");
				String projName = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
				String val = comId+":"+projId;
				String selected = "";
				if (value!=null && val.equalsIgnoreCase(value)) {
				   selected = " selected "; 
				}

				if (projId.equalsIgnoreCase("ALL")) {
				   //---====== If ALL Permission , set flag and exit loop =======----//
				   allProject = true;
				   break;
				 } else {
				   //---====== Normal Case , generate project by permission =======---//
				   html.append("<option value='").append(val).append("' ").append(selected).append(">")
						   .append(comId).append("-").append(projId).append(" - ").append(projName)
						   .append("</option>");				                   
				 }		        
			 } // end while		 
			 //html.append("<option value='ALL_PROJ' "+(value.equalsIgnoreCase("ALL") ? "selected" : "")+">"+Constants.LISTBOX_ALLPROJECT_LABEL+"</option>");
			 String selected = "";
			 //System.out.println(" value :"+value);
			 if(value.equals("ALL")){
			    selected = " selected";
			 }

			//System.out.println(" selected :"+selected);
			 html.append("<option value='ALL' "+selected+">"+Constants.LISTBOX_ALLPROJECT_LABEL+"</option>");
			 html.append("</select>");
			 //----=====================================================----//
			 rs.close();
			 stmt.close();
			 if (allProject) {
				 //----====== AllProject is true , gen All Project Listbox ========----//
				 html.delete(0,html.length());
				 html.append(common.genAllProjectListbox(name,value,params,getAllProj));
			 }		     
		 } catch (Exception e) {
			 System.out.println(" genProjectListboxByUserId Error : "+e.getMessage());
		 } finally {
			 try {
				if (rs!=null) rs.close();
				if (stmt!=null) stmt.close();
			 } catch (Exception ex) {}
		 }
		 return html.toString();
	}


%>

<%


/*System.out.println("**************** SERV_HOME ***************************");
String ParameterNames = "";
for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
	ParameterNames = (String)e.nextElement();
	System.out.println(ParameterNames + " = "+request.getParameter(ParameterNames));
}
System.out.println("****************** SERV_HOME *************************");*/
 

String sessionId = user.getsessionId();
String userId = user.getUserID();
String empId = user.getEmpId();
String user_group = doString.checkString(user.getUserGroup());


//user_group = "A";
//System.out.println("user:"+user_group);
String jName = "SERV_Home.jsp";


ServLog servlog = new ServLog(sessionId, userId, jName);

   String search = doString.checkString(request.getParameter("search"),"");
   String selProj = doString.checkString(request.getParameter("sel_project"),"");
   //System.out.println("sel_project = "+selProj);

   if  (selProj.length()==0) {
       if (!search.equalsIgnoreCase("Y")) selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       session.setAttribute("sess_sel_proj",selProj);
   }
   
   //System.out.println("selProj="+selProj);
   //System.out.println("sess_sel_proj="+selProj);

   //-----====================== Search BOQ Data ================================------//
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	SERV_CommonData common = null;

	try {
	    doString str = new doString();
		String userWho = user.getUserWho();
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();

		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);//informix

		conn.setAutoCommit(true);	

		
		stmt = conn.createStatement();       
		stmt1 = conn.createStatement();       
		//common = new SERV_CommonData(conn); 
        //----=======================================----//    


		boolean isSvc = false; //IsGrantPermissionSvc(conn,empId);
	    boolean isLHALL = IsLHALL(conn,user.getUserID(),selProj);


        if (user.getUserWho().equalsIgnoreCase("J")) {
	
		} else { //--------------=================== for other user ==========================------//

		//----============== Generate Condition ================-----//
       String condition = "";	
       String inf_condition = "";	
	   String team_condition = "";	
	   boolean viewAllStaffProj = false;


		if(userWho.equals("A") && (selProj.equals("ALL") || selProj.equals("ALL_PROJ"))){
			 //--userWho = A and case ALL project
			 condition = "";
			 //System.out.println("Case : 11111111 "); 
		}else if(userWho.equals("S") && (selProj.equals("ALL") || selProj.equals("ALL_PROJ"))){

		}else  if (selProj.trim().length()>=6 && !selProj.equalsIgnoreCase("ALL")) {
		   //case select project
		    condition = " and a.i_company='"+(selProj.substring(0,2))+"' and a.i_project='"+(selProj.substring(3,6))+"' ";	
		     //System.out.println("Case : 333333333333 ");   
		}
		//System.out.println("------------->selProj :"+selProj);   
		if(selProj.equals("")) {
		   condition = " and a.i_docno='NOPROEJCT' ";  
		} 

        //System.out.println("------------->condition :"+condition);   
        //----=========== Get Payment Date =============----//        
        String showCurrentPaymentDate = "";
        String showCurrentConstructorDate = "";
        String showCurrentServiceStaffDate = "";
        String showCurrentServiceManagerDate = "";
        String showCurrentManagerDate = "";
        String showCurrentVPDate = "";

        String showNextPaymentDate = "";
        String showNextConstructorDate = "";
        String showNextServiceStaffDate = "";
        String showNextServiceManagerDate = "";
        String showNextManagerDate = "";
        String showNextVPDate = "";
                
        String currentPaymentDate = "";
        String nextPaymentDate = "";
		String dChangeDate = "";
                
        sql.delete(0,sql.length());
       //remark by pradoem 2012.04.24 : sql.append(" select * from lan:serv_payschd where d_change>=today order by d_payment ");
        sql.append(" select d_payment,d_contructor,d_service_staff ,d_service_man,d_service_zone,d_vp     from lan:serv_payschd where d_change>=today order by d_payment ");
		servlog.startLog(sql.toString());
        rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
        int cnt = 1;
		String tmpDate = "";
		 Calendar pay =null;
		 Timestamp tmp = null;
		 int year = 0;
  		//System.out.println("------------->eeeeeeeeeeeeeeeee");
        while (rs.next()) {
            //---- Payment Date ----// 
		    pay = Calendar.getInstance();
		    tmp = rs.getTimestamp("d_payment");

		    if (tmp!=null)  {
		        pay.setTime(tmp);    
		        
		        tmpDate = "";
		        year = pay.get(Calendar.YEAR);
		        if (year>2400) year -= 543;
		        tmpDate = year+"-"+str.createID((pay.get(Calendar.MONTH)+1),2)+"-"+str.createID(pay.get(Calendar.DATE),2);
		          
	            if (cnt==1) { 
	               currentPaymentDate = tmpDate;
	               showCurrentPaymentDate = getDateFromResultSet(rs,"d_payment");
                   showCurrentConstructorDate = getDateFromResultSet(rs,"d_contructor");
                   showCurrentServiceStaffDate = getDateFromResultSet(rs,"d_service_staff");
                   showCurrentServiceManagerDate = getDateFromResultSet(rs,"d_service_man");
                   showCurrentManagerDate = getDateFromResultSet(rs,"d_service_zone");
                   showCurrentVPDate = getDateFromResultSet(rs,"d_vp");
	            } else if (cnt==2) {
	               nextPaymentDate = tmpDate;
	               showNextPaymentDate = getDateFromResultSet(rs,"d_payment");
                   showNextConstructorDate = getDateFromResultSet(rs,"d_contructor");
                   showNextServiceStaffDate = getDateFromResultSet(rs,"d_service_staff");
                   showNextServiceManagerDate = getDateFromResultSet(rs,"d_service_man");
                   showNextManagerDate = getDateFromResultSet(rs,"d_service_zone");
                   showNextVPDate = getDateFromResultSet(rs,"d_vp");
	            } else { break; }
		    }         
            cnt++;
        }
                        
        
        //----=========== Count for OpenJob Table =============----//        
		String itemStatus = "";

		//***************************************** by pradoem f_status = 'OPN' and i_eser_docno is not null
		//----============== Count For Payment job =============-----//
        int cConstructorWait = 0;
        int cConstructorPass = 0;
        int cConstructorReject = 0;
        int cServiceStaffWait = 0;
        int cServiceStaffPass = 0;
        int cServiceManagerWait = 0;
        int cServiceManagerPass = 0;        
        int cManagerWait = 0;
        int cManagerPass = 0;              
        int cVPWait = 0;
        int cVPPass = 0;      

        int nConstructorWait = 0;
        int nConstructorPass = 0;
        int nConstructorReject = 0;
        int nServiceStaffWait = 0;
        int nServiceStaffPass = 0;
        int nServiceManagerWait = 0;
        int nServiceManagerPass = 0;        
        int nManagerWait = 0;
        int nManagerPass = 0;              
        int nVPWait = 0;
        int nVPPass = 0;       

		itemStatus = "";
		String fReject = "";
		String dReject = "";
		String dPayment = "";
		int count = 0;

		//modify by pradoem 2021.06.23
		//System.out.println("viewAllStaffProj = "+viewAllStaffProj);
		
		//Utilizer.getPropValue(user.getUserCom());
		//String userType = Utilizer.getPropValue("SERV_VP_USER_"+user.getUserCom());//narong|prasong|sathapor
		StringBuilder sqlB = new StringBuilder();
		sqlB.delete(0,sqlB.length());
		
		if(user.getUserCom().equals("LH")){
			//LH-ALL
			sqlB.append(" and not exists ( ")
			    .append(" select c.i_project from lan:serv_local c  ")
			    .append(" where  a.i_company = c.i_company ")
			    .append(" and  a.i_project = c.i_project ")
			    .append(" ) ");
             //-- and  c.i_type = "NE"
		}else{		
		    //NE-ALL,LN-ALL
		    sqlB.append(" and  exists ( ")
			    .append(" select c.i_project from lan:serv_local c  ")
			    .append(" where  a.i_company = c.i_company ")
			    .append(" and  a.i_project = c.i_project ")
			    .append(" and  c.i_type = '"+user.getUserCom()+"' ")
			    .append(" ) ");
		}
		
		
			sql.delete(0,sql.length());
			if (viewAllStaffProj) {
				//---- query for staff view all project by user ----//
				sql.append(" select count(distinct c.i_docno) as cnt, c.f_itmstatus, b.f_reject, b.d_reject, c.d_payment ")
					  .append("  from lan:serv_payment c, lan:serv_dochd b,lan:serv_pstaff a ")
					  .append(" where b.f_status != 'CAN' and a.user_id = '").append(userId).append("' ")
					  .append(" and a.com_id = b.i_company and a.proj_id = b.i_project ")
					  .append(" and b.i_doc_type = 'J' and b.i_docno = c.i_docno ")
					  .append(" and (c.d_payment = '"+currentPaymentDate+"' or c.d_payment = '"+nextPaymentDate+"') ")
					  .append(" and c.f_itmstatus != 'CAN' ")
					  .append("  group by c.f_itmstatus, b.f_reject, b.d_reject, c.d_payment  ");
			} else {
			
				 if(isLHALL){ //isLHALL==true
				     //by user
				 	sql.append(" select count(distinct c.i_docno) as cnt, c.f_itmstatus, b.f_reject, b.d_reject, c.d_payment ")
					  .append("  from lan:serv_payment c, lan:serv_dochd b,lan:serv_pstaff a ")
					  .append(" where b.f_status != 'CAN' and a.user_id = '").append(userId).append("' ")
					  .append(" and a.com_id = b.i_company and a.proj_id = b.i_project ")
					  .append(" and b.i_doc_type = 'J' and b.i_docno = c.i_docno ")
					  .append(" and (c.d_payment = '"+currentPaymentDate+"' or c.d_payment = '"+nextPaymentDate+"') ")
					  .append(" and c.f_itmstatus != 'CAN' ")
					  .append("  group by c.f_itmstatus, b.f_reject, b.d_reject, c.d_payment  ");
					  //System.out.println("VP222:"+sql);
				 }else{
				   // by all (VP เท่านั้น)
				 	sql.append(" select {+index(b serv_payment_idx4 )} count(distinct b.i_docno) as cnt ,b.f_itmstatus,a.f_reject,a.d_reject,b.d_payment ")
					  .append(" from lan:serv_dochd a,lan:serv_payment b where a.f_status in('OPN','CLS') and a.i_doc_type='J' ")
					  .append(" and b.f_itmstatus!='CAN' and b.i_docno=a.i_docno "+condition+" ")
					  .append(" and (b.d_payment='"+currentPaymentDate+"' or b.d_payment='"+nextPaymentDate+"') ")
					  .append(sqlB.toString()) //add by pradoem 2023.05.30
					  .append(" group by b.f_itmstatus,a.f_reject,a.d_reject,b.d_payment ");
					  //System.out.println("VP333:"+sql);
				 }		
			}
			//System.out.println("test user_group:"+user_group);

			
			if (user_group.equals("A") || user_group.equals("H")) {
			    //System.out.println("111 = "+sql.toString());
				rs = stmt.executeQuery(sql.toString());
				while (rs.next()) {
					itemStatus = doString.checkString(rs.getString("f_itmstatus"),"");
					fReject = doString.checkString(rs.getString("f_reject"),"");
					dReject = doString.checkString(doString.DisplayThai(rs.getString("d_reject")),"");
					dPayment = doString.checkString(doString.DisplayThai(rs.getString("d_payment")),"");
					count = rs.getInt("cnt");
	
					if (itemStatus.equalsIgnoreCase("400")) {
						if (fReject.equalsIgnoreCase("N") && dReject.trim().length()>0) {
							if (currentPaymentDate.equals(dPayment)) {
								cConstructorReject += count; // Constructor Reject , current payment
							} else if (nextPaymentDate.equals(dPayment)) {
								nConstructorReject += count; // Constructor Reject , next payment
							}
						} else {
							if (currentPaymentDate.equals(dPayment)) {
								cConstructorWait += count; // Constructor Wait , current payment
							} else if (nextPaymentDate.equals(dPayment)) {
								nConstructorWait += count; // Constructor Wait , next payment
							}
						}
					} 
					
					else if (itemStatus.equalsIgnoreCase("500")) {
							if (currentPaymentDate.equals(dPayment)) {
								cConstructorPass += count; // Constructor Pass , current payment
								cServiceStaffWait += count; // Service Staff Wait , current payment
							} else if (nextPaymentDate.equals(dPayment)) {
								nConstructorPass += count; // Constructor Pass , next payment
								nServiceStaffWait += count; // Service Staff Wait , next payment
							}
					}
	
					else if (itemStatus.equalsIgnoreCase("600")) {
							if (currentPaymentDate.equals(dPayment)) {
								cServiceStaffPass += count; // Service Staff Pass , current payment
								cServiceManagerWait += count; // Service Managet Wait , current payment
							} else if (nextPaymentDate.equals(dPayment)) {
								nServiceStaffPass += count; // Service Staff Pass , next payment
								nServiceManagerWait += count; // Service Managet Wait , next payment
							}
					}
	
					else if (itemStatus.equalsIgnoreCase("700")) {
							if (currentPaymentDate.equals(dPayment)) {
								cServiceManagerPass += count; // Service Manager Pass , current payment
								cManagerWait += count; // Manager Wait , current payment
							} else if (nextPaymentDate.equals(dPayment)) {
								nServiceManagerPass += count; // Service Manager Pass , next payment
								nManagerWait += count; // Manager Wait , next payment
							}
					}
	
					else if (itemStatus.equalsIgnoreCase("800")) {
							if (currentPaymentDate.equals(dPayment)) {
								cManagerPass += count; // Managet Pass , current payment
								cVPWait += count;  // VP Wait , current payment 
							} else if (nextPaymentDate.equals(dPayment)) {
								nManagerPass += count; // Managet Pass , next payment
								nVPWait += count;  // VP Wait , next payment 
							}
					}
	
					else if (itemStatus.equalsIgnoreCase("CLS")) {
							if (currentPaymentDate.equals(dPayment)) {
								cVPPass += count;  // VP Pass , current payment 
							} else if (nextPaymentDate.equals(dPayment)) {
								nVPPass += count;  // VP Pass , next payment 
							}
					}
				}
				rs.close();
			}//End 
                                    

        //System.out.println("---->cVPWait = "+cVPWait);
  
        int cINFConstructorWait = 0;
        int cINFConstructorPass = 0;
        int cINFConstructorReject = 0;
        int cINFServiceStaffWait = 0;
        int cINFServiceStaffPass = 0;
        int cINFServiceManagerWait = 0;
        int cINFServiceManagerPass = 0;        
        int cINFManagerWait = 0;
        int cINFManagerPass = 0;              
        int cINFVPWait = 0;
        int cINFVPPass = 0;      

        int nINFConstructorWait = 0;
        int nINFConstructorPass = 0;
        int nINFConstructorReject = 0;
        int nINFServiceStaffWait = 0;
        int nINFServiceStaffPass = 0;
        int nINFServiceManagerWait = 0;
        int nINFServiceManagerPass = 0;        
        int nINFManagerWait = 0;
        int nINFManagerPass = 0;              
        int nINFVPWait = 0;
        int nINFVPPass = 0;    


        int cPUBConstructorWait = 0;
        int cPUBConstructorPass = 0;
        int cPUBConstructorReject = 0;
        int cPUBServiceStaffWait = 0;
        int cPUBServiceStaffPass = 0;
        int cPUBServiceManagerWait = 0;
        int cPUBServiceManagerPass = 0;        
        int cPUBManagerWait = 0;
        int cPUBManagerPass = 0;              
        int cPUBVPWait = 0;
        int cPUBVPPass = 0;      

        int nPUBConstructorWait = 0;
        int nPUBConstructorPass = 0;
        int nPUBConstructorReject = 0;
        int nPUBServiceStaffWait = 0;
        int nPUBServiceStaffPass = 0;
        int nPUBServiceManagerWait = 0;
        int nPUBServiceManagerPass = 0;        
        int nPUBManagerWait = 0;
        int nPUBManagerPass = 0;              
        int nPUBVPWait = 0;
        int nPUBVPPass = 0;  

		
		itemStatus = "";
		fReject = "";
		dReject = "";
		dPayment = "";
		count = 0;

		//modify by pradoem 2021.06.23

	
	        sql.delete(0,sql.length());
			if (viewAllStaffProj) {
				//---- query for staff view all project ----//
				sql.append(" select count(distinct c.i_docno) as cnt, c.f_itmstatus, b.f_reject, b.d_reject, c.d_payment ")
					  .append("  from lan:serv_infpayment c, lan:serv_infdochd b,lan:serv_pstaff a ")
					  .append(" where b.f_status != 'CAN' and a.user_id = '").append(userId).append("' ")
					  .append(" and a.com_id = b.i_company and a.proj_id = b.i_project ")
					  .append(" and b.i_doc_type = 'J' and b.i_docno = c.i_docno ")
					  .append(" and c.i_itmtype = '01' and (c.d_payment = '"+currentPaymentDate+"' or c.d_payment = '"+nextPaymentDate+"') ")
					  .append(" and c.f_itmstatus != 'CAN' ")
					  .append("  group by c.f_itmstatus, b.f_reject, b.d_reject, c.d_payment  ");
			} else {
				sql.append(" select count(distinct b.i_docno) as cnt ,b.f_itmstatus,a.f_reject,a.d_reject,b.d_payment ")
					  .append(" from lan:serv_infdochd a,lan:serv_infpayment b where a.f_status!='CAN' and a.i_doc_type='J' ")
					  .append(" and b.f_itmstatus!='CAN' and b.i_docno=a.i_docno and b.i_itmtype = '01' "+condition+" ")
					  .append(" and (b.d_payment='"+currentPaymentDate+"' or b.d_payment='"+nextPaymentDate+"') ")
					  .append(" group by b.f_itmstatus,a.f_reject,a.d_reject,b.d_payment ");
			}
			
			//System.out.println("222 = "+user_group);
			if (user_group.equals("A") || user_group.equals("I")) {
				rs = stmt.executeQuery(sql.toString());
				//System.out.println("222 = "+sql.toString());
				while (rs.next()) {
					itemStatus = doString.checkString(rs.getString("f_itmstatus"),"");
					fReject = doString.checkString(rs.getString("f_reject"),"");
					dReject = doString.checkString(doString.DisplayThai(rs.getString("d_reject")),"");
					dPayment = doString.checkString(doString.DisplayThai(rs.getString("d_payment")),"");
					count = rs.getInt("cnt");
	
					if (itemStatus.equalsIgnoreCase("400")) {
						if (fReject.equalsIgnoreCase("N") && dReject.trim().length()>0) {
							if (currentPaymentDate.equals(dPayment)) {
								cINFConstructorReject += count; // Constructor Reject , current payment
							} else if (nextPaymentDate.equals(dPayment)) {
								nINFConstructorReject += count; // Constructor Reject , next payment
							}
						} else {
							if (currentPaymentDate.equals(dPayment)) {
								cINFConstructorWait += count; // Constructor Wait , current payment
							} else if (nextPaymentDate.equals(dPayment)) {
								nINFConstructorWait += count; // Constructor Wait , next payment
							}
						}
					} 
					
					else if (itemStatus.equalsIgnoreCase("500")) {
							if (currentPaymentDate.equals(dPayment)) {
								cINFConstructorPass += count; // Constructor Pass , current payment
								cINFServiceStaffWait += count; // Service Staff Wait , current payment
							} else if (nextPaymentDate.equals(dPayment)) {
								nINFConstructorPass += count; // Constructor Pass , next payment
								nINFServiceStaffWait += count; // Service Staff Wait , next payment
							}
					}
	
					else if (itemStatus.equalsIgnoreCase("600")) {
							if (currentPaymentDate.equals(dPayment)) {
								cINFServiceStaffPass += count; // Service Staff Pass , current payment
								cINFServiceManagerWait += count; // Service Managet Wait , current payment
							} else if (nextPaymentDate.equals(dPayment)) {
								nINFServiceStaffPass += count; // Service Staff Pass , next payment
								nINFServiceManagerWait += count; // Service Managet Wait , next payment
							}
					}
	
					else if (itemStatus.equalsIgnoreCase("700")) {
							if (currentPaymentDate.equals(dPayment)) {
								cINFServiceManagerPass += count; // Service Manager Pass , current payment
								cINFManagerWait += count; // Manager Wait , current payment
							} else if (nextPaymentDate.equals(dPayment)) {
								nINFServiceManagerPass += count; // Service Manager Pass , next payment
								nINFManagerWait += count; // Manager Wait , next payment
							}
					}
	
					else if (itemStatus.equalsIgnoreCase("800")) {
							if (currentPaymentDate.equals(dPayment)) {
								cINFManagerPass += count; // Managet Pass , current payment
								cINFVPWait += count;  // VP Wait , current payment 
							} else if (nextPaymentDate.equals(dPayment)) {
								nINFManagerPass += count; // Managet Pass , next payment
								nINFVPWait += count;  // VP Wait , next payment 
							}
					}
	
					else if (itemStatus.equalsIgnoreCase("CLS")) {
							if (currentPaymentDate.equals(dPayment)) {
								cINFVPPass += count;  // VP Pass , current payment 
							} else if (nextPaymentDate.equals(dPayment)) {
								nINFVPPass += count;  // VP Pass , next payment 
							}
					}
				}
				rs.close();
			}


		itemStatus = "";
		fReject = "";
		dReject = "";
		dPayment = "";
		count = 0;

	
	        sql.delete(0,sql.length());
			if (viewAllStaffProj) {
				//---- query for staff view all project ----//
				team_condition = "";
				if (!user_group.equals("A")) {
					team_condition = " AND b.i_team = '"+user_group+"'";
				}		
				sql.append(" select count(distinct c.i_docno) as cnt, c.f_itmstatus, b.f_reject, b.d_reject, c.d_payment ")
					  .append("  from lan:serv_infpayment c, lan:serv_infdochd b,lan:serv_pstaff a ")
					  .append(" where b.f_status != 'CAN' and a.user_id = '").append(userId).append("' ")
					  .append(" and a.com_id = b.i_company and a.proj_id = b.i_project ")
					  .append(" and b.i_doc_type = 'J' "+team_condition+" and b.i_docno = c.i_docno ")
					  .append(" and c.i_itmtype = '02' and (c.d_payment = '"+currentPaymentDate+"' or c.d_payment = '"+nextPaymentDate+"') ")
					  .append(" and c.f_itmstatus != 'CAN' ")
					  .append("  group by c.f_itmstatus, b.f_reject, b.d_reject, c.d_payment  ");
			} else {
				team_condition = "";
				if (!user_group.equals("A")) {
					team_condition = " AND a.i_team = '"+user_group+"'";
				}			
				sql.append(" select count(distinct b.i_docno) as cnt ,b.f_itmstatus,a.f_reject,a.d_reject,b.d_payment ")
					  .append(" from lan:serv_infdochd a,lan:serv_infpayment b where a.f_status!='CAN' and a.i_doc_type='J' ")
					.append(team_condition)
					  .append(" and b.f_itmstatus!='CAN' and b.i_docno=a.i_docno and b.i_itmtype = '02' "+condition+" ")
					  .append(" and (b.d_payment='"+currentPaymentDate+"' or b.d_payment='"+nextPaymentDate+"') ")
					  .append(" group by b.f_itmstatus,a.f_reject,a.d_reject,b.d_payment ");
			}
			if (user_group.equals("A") || user_group.equals("I") || user_group.equals("H")) {
				rs = stmt.executeQuery(sql.toString());
				//System.out.println("333 = "+sql.toString());
				while (rs.next()) {
					itemStatus = doString.checkString(rs.getString("f_itmstatus"),"");
					fReject = doString.checkString(rs.getString("f_reject"),"");
					dReject = doString.checkString(doString.DisplayThai(rs.getString("d_reject")),"");
					dPayment = doString.checkString(doString.DisplayThai(rs.getString("d_payment")),"");
					count = rs.getInt("cnt");
	
					if (itemStatus.equalsIgnoreCase("400")) {
						if (fReject.equalsIgnoreCase("N") && dReject.trim().length()>0) {
							if (currentPaymentDate.equals(dPayment)) {
								cPUBConstructorReject += count; // Constructor Reject , current payment
							} else if (nextPaymentDate.equals(dPayment)) {
								nPUBConstructorReject += count; // Constructor Reject , next payment
							}
						} else {
							if (currentPaymentDate.equals(dPayment)) {
								cPUBConstructorWait += count; // Constructor Wait , current payment
							} else if (nextPaymentDate.equals(dPayment)) {
								nPUBConstructorWait += count; // Constructor Wait , next payment
							}
						}
					} 
					
					else if (itemStatus.equalsIgnoreCase("500")) {
							if (currentPaymentDate.equals(dPayment)) {
								cPUBConstructorPass += count; // Constructor Pass , current payment
								cPUBServiceStaffWait += count; // Service Staff Wait , current payment
							} else if (nextPaymentDate.equals(dPayment)) {
								nPUBConstructorPass += count; // Constructor Pass , next payment
								nPUBServiceStaffWait += count; // Service Staff Wait , next payment
							}
					}
	
					else if (itemStatus.equalsIgnoreCase("600")) {
							if (currentPaymentDate.equals(dPayment)) {
								cPUBServiceStaffPass += count; // Service Staff Pass , current payment
								cPUBServiceManagerWait += count; // Service Managet Wait , current payment
							} else if (nextPaymentDate.equals(dPayment)) {
								nPUBServiceStaffPass += count; // Service Staff Pass , next payment
								nPUBServiceManagerWait += count; // Service Managet Wait , next payment
							}
					}
	
					else if (itemStatus.equalsIgnoreCase("700")) {
							if (currentPaymentDate.equals(dPayment)) {
								cPUBServiceManagerPass += count; // Service Manager Pass , current payment
								cPUBManagerWait += count; // Manager Wait , current payment
							} else if (nextPaymentDate.equals(dPayment)) {
								nPUBServiceManagerPass += count; // Service Manager Pass , next payment
								nPUBManagerWait += count; // Manager Wait , next payment
							}
					}
	
					else if (itemStatus.equalsIgnoreCase("800")) {
							if (currentPaymentDate.equals(dPayment)) {
								cPUBManagerPass += count; // Managet Pass , current payment
								cPUBVPWait += count;  // VP Wait , current payment 
							} else if (nextPaymentDate.equals(dPayment)) {
								nPUBManagerPass += count; // Managet Pass , next payment
								nPUBVPWait += count;  // VP Wait , next payment 
							}
					}
	
					else if (itemStatus.equalsIgnoreCase("CLS")) {
							if (currentPaymentDate.equals(dPayment)) {
								cPUBVPPass += count;  // VP Pass , current payment 
							} else if (nextPaymentDate.equals(dPayment)) {
								nPUBVPPass += count;  // VP Pass , next payment 
							}
					}
				}
				rs.close();
			}

	 
		//Contact
		itemStatus = "";
		fReject = "";
		dReject = "";
		dPayment = "";
		count = 0;

		//System.out.println("==111111==");
		//modify by pradoem 2021.06.23
        //----=========== Count for BOQ Request =============----//        
  		//modify by pradoem 2021.06.23

%>

<HTML>
<HEAD>
<TITLE>Home</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<!--  
<script language="javascript" src="prototype.js"></script>
-->
<script
  src="https://code.jquery.com/jquery-1.12.4.js"
  integrity="sha256-Qw82+bXyGq6MydymqBxNPYTaUXXq7c8v3CwiYwLLNXU="
  crossorigin="anonymous"></script>
<!--
<script type='text/javascript' src='jquery/jquery-1.11.3.min.js'></script>
<script src="jquery3/jquery.min3.6.3.js" ></script>
-->

<script src="jquery3/loadingoverlay.min2.1.7.js"></script>

<script type='text/javascript' src='jquery/loadImg.js'></script>
<script language="javascript">
   function queryProject() {

       pleaseWaiting();
       document.forms[0].action = "SERV_Home_VP.jsp?search=y";
       document.forms[0].submit();
   }
  function doSubmitForm(url){
    //alert("submit");
     pleaseWaiting();    
 	$('form').attr('action', url);
	$("form:first").submit();
  }

  function onPleaseWait(){
	document.all.pleasewaitScreen.style.pixelTop = (document.body.scrollTop + 120);
	$('#pleasewaitScreen').show();
	//setTimeout(function(){  $('#pleasewaitScreen').css("visibility", 'hidden'); }, 9000); //wait 7 seconds
	$('#pleasewaitScreen').css('visibility', 'visible');
 }  
 
  /*function pleaseWaiting(){
   $.LoadingOverlay("show");
	// Hide it after 3 seconds
	setTimeout(function(){
	    $.LoadingOverlay("hide");
	}, 3000);
  }*/

</script>


<base target="_self">

</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM method="POST" action="">


<!-- ##########################################  rgb(255,120,0)-->
<DIV ID="pleasewaitScreen" STYLE="position: absolute; z-index: 0; top: 45%; left: 42%; display: none;">
<TABLE BORDER="1" BORDERCOLOR="rgb(180,210,250)" CELLPADDING="0" CELLSPACING="0" 
HEIGHT="125px" WIDTH="265px" ID="Table1">
	<TR>
	<TD BGCOLOR="#FFFFFF" ALIGN="CENTER" VALIGN="MIDDLE" class="test">
	<font  style="font-family:Tahoma,Arial,sans-serif; color:rgb(112,112,112); font-size:2.0em;" ><b>Loading... Please wait</b></font>
	<br>
	<br>
	  <span id="img1">
	   <img src="<%=request.getContextPath()%>/images/loading2.GIF" HEIGHT="64px">
	  </span>
	</TD> 
	</TR>
</TABLE>
</DIV>
<!-- ########################################## -->


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center" class="BD">
    

      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ยินดีต้อนรับสู่ระบบบริการหลังการขาย</td>
          <td width="30%" align="right">&nbsp;</td>
        </tr>
      </table>


<br style="font-size:10pt">
                

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop">&nbsp;</td>
    <td width="5" valign="top" align="right"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR" align="center">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td height="22" class="item ; dotline01" width="8%">ชื่อ :</td>
    <td height="22" width="37%" class="dotline01"><%=doString.DisplayThai(user.getEmpName())%></td>
    <td height="22" width="15%" class="item ; dotline01">เลือกโครงการ : </td>
    <td height="22" width="40%" class="dotline01">
    <%=genProjectListboxByUserId(conn,user.getUserID(),"sel_project",selProj," class='box' style='width:250px' ",true)%>    
     &nbsp;&nbsp; <a href="javascript:queryProject();" ><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a> </td>
  </tr>
</table>

</td>
  </tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>

<br style="font-size:10pt">

<!-- ################################################################################################################################ -->
<%  if (!user.getUserWho().equalsIgnoreCase(Constants.PERMISSION_VENDOR)) { %>

            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดการขอเบิก
                  Payment งวดนี้</td>
                <td class="item_tab3"></td>
                <td>&nbsp;วันที่จ่าย&nbsp; <%=showCurrentPaymentDate%></td>
              </tr>
            </table>


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
    <td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL" align="center">

<table border="0" width="100%" cellspacing="0" cellpadding="0">

                <tr> 
                  <td rowspan="2" class="col_name">Description</td>
                  <td colspan="3" class="col_name">บ้าน</td>
                  <td colspan="3" class="col_name">สาธารณะ</td>
                  <td colspan="3" class="col_name">สาธารณูฯ</td>
                
                <tr> 
                  <td width="7%" class="col_name">Wait</td>
                  <td width="7%" class="col_name">Pass</td>
                  <td width="7%" class="col_name">Reject</td>

                  <td width="7%" class="col_name">Wait</td>
                  <td width="7%" class="col_name">Pass</td>
                  <td width="7%" class="col_name">Reject</td>

                  <td width="8%" class="col_name">Wait</td>
                  <td width="8%" class="col_name">Pass</td>
                  <td width="8%" class="col_name">Reject</td>

                <tr> 
  <tr>
    <td width="34%" class="item ; dotline" align="left"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="13" height="13">
      Contractor - ผู้รับเหมาส่งงาน&nbsp; <font color="#993300">ภายในวันที่ <%=showCurrentConstructorDate%></font></td>
    <td width="7%" class="dotline" align="center">

     	<%if(cConstructorWait>0){ %>

    	<a href="#" onclick="javascript:doSubmitForm('SERV_Contractor_List.jsp?sel_project=<%=selProj%>&d_payment=<%=showCurrentPaymentDate%>');"><%=cConstructorWait%></a>

    	<%}else {out.println(cConstructorWait);} %>

    </td>
    <td width="7%" class="dotline" align="center"><%=cConstructorPass%></td>
    <td width="7%" class="dotline" align="center">&nbsp;</td>

    <td width="7%" class="dotline" align="center"><a href="SERV_INFContractor_List.jsp?itmType=02&sel_project=<%=selProj%>&d_payment=<%=showCurrentPaymentDate%>"><%=cPUBConstructorWait%></a></td>
    <td width="7%" class="dotline" align="center"><%=cPUBConstructorPass%></td>
    <td width="7%" class="dotline" align="center">&nbsp;</td>

    <td width="8%" class="dotline" align="center"><a href="SERV_INFContractor_List.jsp?itmType=01&sel_project=<%=selProj%>&d_payment=<%=showCurrentPaymentDate%>"><%=cINFConstructorWait%></a></td>
    <td width="8%" class="dotline" align="center"><%=cINFConstructorPass%></td>
    <td width="8%" class="dotline" align="center">&nbsp;</td>
  </tr>

  <tr>
    <td width="34%" class="item ; dotline" align="left"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="13" height="13">
      Approve 1&nbsp; <font color="#993300">อนุมัติภายในวันที่ <%=showCurrentServiceStaffDate%></font></td>
    <td width="7%" class="dotline" align="center">

    <%if(cServiceStaffWait>0){ %>

    	<a href="#" onclick="javascript:doSubmitForm('SERV_Staff_List.jsp?sel_project=<%=selProj%>&d_payment=<%=showCurrentPaymentDate%>');"><%=cServiceStaffWait%></a>

    <%}else{out.println(cServiceStaffWait);} %>

    </td>
    <td width="7%" class="dotline" align="center"><%=cServiceStaffPass%></td>
    <td width="7%" class="dotline" align="center">&nbsp;</td>

    <td width="7%" class="dotline" align="center"><a href="SERV_INFStaff_List.jsp?itmType=02&sel_project=<%=selProj%>&d_payment=<%=showCurrentPaymentDate%>"><%=cPUBServiceStaffWait%></a></td>
    <td width="7%" class="dotline" align="center"><%=cPUBServiceStaffPass%></td>
    <td width="7%" class="dotline" align="center">&nbsp;</td>

    <td width="8%" class="dotline" align="center"><a href="SERV_INFStaff_List.jsp?itmType=01&sel_project=<%=selProj%>&d_payment=<%=showCurrentPaymentDate%>"><%=cINFServiceStaffWait%></a></td>
    <td width="8%" class="dotline" align="center"><%=cINFServiceStaffPass%></td>
    <td width="8%" class="dotline" align="center">&nbsp;</td>
  </tr>

  <tr>
    <td width="34%" class="item ; dotline" align="left"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="13" height="13">
      Approve 2&nbsp; <font color="#993300">อนุมัติภายในวันที่ <%=showCurrentServiceManagerDate%></font></td>
    <td width="7%" class="dotline" align="center">

    <%if(cServiceManagerWait>0){ %>

    	<a href="#" onclick="javascript:doSubmitForm('SERV_Manager_List.jsp?sel_project=<%=selProj%>&d_payment=<%=showCurrentPaymentDate%>');"><%=cServiceManagerWait%></a>

    <%}else{out.println(cServiceManagerWait);} %>

    </td>
    <td width="7%" class="dotline" align="center"><%=cServiceManagerPass%></td>
    <td width="7%" class="dotline" align="center">&nbsp;</td>

    <td width="7%" class="dotline" align="center"><a href="SERV_INFManager_List.jsp?itmType=02&sel_project=<%=selProj%>&d_payment=<%=showCurrentPaymentDate%>"><%=cPUBServiceManagerWait%></a></td>
    <td width="7%" class="dotline" align="center"><%=cPUBServiceManagerPass%></td>
    <td width="7%" class="dotline" align="center">&nbsp;</td>

    <td width="8%" class="dotline" align="center"><a href="SERV_INFManager_List.jsp?itmType=01&sel_project=<%=selProj%>&d_payment=<%=showCurrentPaymentDate%>"><%=cINFServiceManagerWait%></a></td>
    <td width="8%" class="dotline" align="center"><%=cINFServiceManagerPass%></td>
    <td width="8%" class="dotline" align="center">&nbsp;</td>
  </tr>

  <tr>
    <td width="34%" class="item ; dotline" align="left"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="13" height="13">
       AVP ผู้ช่วยผู้จัดการฝ่าย&nbsp; <font color="#993300">อนุมัติภายในวันที่ <%=showCurrentManagerDate%></font></td>
    <td width="7%" class="dotline" align="center">

    <%if(cManagerWait>0){ %>

    	<a href="#" onclick="javascript:doSubmitForm('SERV_Zone_List.jsp?sel_project=<%=selProj%>&d_payment=<%=showCurrentPaymentDate%>');"><%=cManagerWait%></a>

    <%}else{out.println(cManagerWait);} %>

    </td>
    <td width="7%" class="dotline" align="center"><%=cManagerPass%></td>
    <td width="7%" class="dotline" align="center">&nbsp;</td>

    <td width="7%" class="dotline" align="center"><a href="SERV_INFZone_List.jsp?itmType=02&sel_project=<%=selProj%>&d_payment=<%=showCurrentPaymentDate%>"><%=cPUBManagerWait%></a></td>
    <td width="7%" class="dotline" align="center"><%=cPUBManagerPass%></td>
    <td width="7%" class="dotline" align="center">&nbsp;</td>

    <td width="8%" class="dotline" align="center"><a href="SERV_INFZone_List.jsp?itmType=01&sel_project=<%=selProj%>&d_payment=<%=showCurrentPaymentDate%>"><%=cINFManagerWait%></a></td>
    <td width="8%" class="dotline" align="center"><%=cINFManagerPass%></td>
    <td width="8%" class="dotline" align="center">&nbsp;</td>
  </tr>

  <tr>
    <td width="34%" class="item ; dotline" align="left"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="13" height="13">
      VP - ผู้จัดการฝ่าย&nbsp; <font color="#993300">อนุมัติภายในวันที่ <%=showCurrentVPDate%></font></td>
    <td width="7%" class="dotline" align="center">

    <%if(cVPWait>0){ %>

    	<a href="#" onclick="javascript:doSubmitForm('SERV_VP_List.jsp?sel_project=<%=selProj%>&d_payment=<%=showCurrentPaymentDate%>');"><%=cVPWait%></a>

    <%}else{out.println(cVPWait);} %>

    </td>
    <td width="7%" class="dotline" align="center"><a href="#" onclick="javascript:doSubmitForm('SERV_Pass_List.jsp?sel_project=<%=selProj%>&d_payment=<%=showCurrentPaymentDate%>');"><%=cVPPass%></a></td>
    <td width="7%" class="dotline" align="center">&nbsp;</td>

    <td width="7%" class="dotline" align="center"><a href="SERV_INFVP_List.jsp?itmType=02&sel_project=<%=selProj%>&d_payment=<%=showCurrentPaymentDate%>"><%=cPUBVPWait%></a></td>
    <td width="7%" class="dotline" align="center"><a href="SERV_INFPass_List.jsp?itmType=02&sel_project=<%=selProj%>&d_payment=<%=showCurrentPaymentDate%>"><%=cPUBVPPass%></a></td>
    <td width="7%" class="dotline" align="center">&nbsp;</td>

    <td width="8%" class="dotline" align="center"><a href="SERV_INFVP_List.jsp?itmType=01&sel_project=<%=selProj%>&d_payment=<%=showCurrentPaymentDate%>"><%=cINFVPWait%></a></td>
    <td width="8%" class="dotline" align="center"><a href="SERV_INFPass_List.jsp?itmType=01&sel_project=<%=selProj%>&d_payment=<%=showCurrentPaymentDate%>"><%=cINFVPPass%></a></td>
    <td width="8%" class="dotline" align="center">&nbsp;</td>
  </tr>
</table>    
    
    
    </td>
  </tr>
</table>


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>

<br style="font-size:10pt">


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดการขอเบิก
                  Payment งวดหน้า</td>
                <td class="item_tab3"></td>
                <td>&nbsp;วันที่จ่าย&nbsp; <%=showNextPaymentDate%></td>
              </tr>
            </table>


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
    <td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL" align="center">
    
    
<table border="0" width="100%" cellspacing="0" cellpadding="0">
                <tr> 
                  <td rowspan="2" class="col_name">Description</td>
                  <td colspan="3" class="col_name">บ้าน</td>
                  <td colspan="3" class="col_name">สาธารณะ</td>
                  <td colspan="3" class="col_name">สาธารณูฯ</td>
                
                <tr> 
                  <td width="7%" class="col_name">Wait</td>
                  <td width="7%" class="col_name">Pass</td>
                  <td width="7%" class="col_name">Reject</td>
                  <td width="7%" class="col_name">Wait</td>
                  <td width="7%" class="col_name">Pass</td>
                  <td width="7%" class="col_name">Reject</td>
                  <td width="8%" class="col_name">Wait</td>
                  <td width="8%" class="col_name">Pass</td>
                  <td width="8%" class="col_name">Reject</td>
                <tr> 
  <tr>
    <td width="34%" class="item ; dotline" align="left"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="13" height="13">
      Contractor - ผู้รับเหมาส่งงาน&nbsp; <font color="#993300">ภายในวันที่ <%=showNextConstructorDate%></font></td>
    <td width="7%" class="dotline" align="center">

    <%if(nConstructorWait>0){ %>

    	<a href="#" onclick="javascript:doSubmitForm('SERV_Contractor_List.jsp?sel_project=<%=selProj%>&d_payment=<%=showNextPaymentDate%>');"><%=nConstructorWait%></a>

    <%}else{out.println(nConstructorWait);} %>

    </td>
    <td width="7%" class="dotline" align="center"><%=nConstructorPass%></td>
    <td width="7%" class="dotline" align="center">&nbsp;</td>
    
	<td width="7%" class="dotline" align="center"><a href="SERV_INFContractor_List.jsp?itmType=02&sel_project=<%=selProj%>&d_payment=<%=showNextPaymentDate%>"><%=nPUBConstructorWait%></a></td>
    <td width="7%" class="dotline" align="center"><%=nPUBConstructorPass%></td>
    <td width="7%" class="dotline" align="center">&nbsp;</td>

	<td width="8%" class="dotline" align="center"><a href="SERV_INFContractor_List.jsp?itmType=01&sel_project=<%=selProj%>&d_payment=<%=showNextPaymentDate%>"><%=nINFConstructorWait%></a></td>
    <td width="8%" class="dotline" align="center"><%=nINFConstructorPass%></td>
    <td width="8%" class="dotline" align="center">&nbsp;</td>
  </tr>

  <tr>
    <td width="34%" class="item ; dotline" align="left"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="13" height="13">
       Approve 1&nbsp; <font color="#993300">อนุมัติภายในวันที่ <%=showNextServiceStaffDate%></font></td>
    <td width="7%" class="dotline" align="center">

    <%if(nServiceStaffWait>0){ %>

    	<a href="#" onclick="javascript:doSubmitForm('SERV_Staff_List.jsp?sel_project=<%=selProj%>&d_payment=<%=showNextPaymentDate%>');"><%=nServiceStaffWait%></a>

    <%}else{out.println(nServiceStaffWait);} %>

    </td>
    <td width="7%" class="dotline" align="center"><%=nServiceStaffPass%></td>
    <td width="7%" class="dotline" align="center">&nbsp;</td>

    <td width="7%" class="dotline" align="center"><a href="SERV_INFStaff_List.jsp?itmType=02&sel_project=<%=selProj%>&d_payment=<%=showNextPaymentDate%>"><%=nPUBServiceStaffWait%></a></td>
    <td width="7%" class="dotline" align="center"><%=nPUBServiceStaffPass%></td>
    <td width="7%" class="dotline" align="center">&nbsp;</td>

    <td width="8%" class="dotline" align="center"><a href="SERV_INFStaff_List.jsp?itmType=01&sel_project=<%=selProj%>&d_payment=<%=showNextPaymentDate%>"><%=nINFServiceStaffWait%></a></td>
    <td width="8%" class="dotline" align="center"><%=nINFServiceStaffPass%></td>
    <td width="8%" class="dotline" align="center">&nbsp;</td>
  </tr>

  <tr>
    <td width="34%" class="item ; dotline" align="left"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="13" height="13">
      Approve 2&nbsp; <font color="#993300">อนุมัติภายในวันที่ <%=showNextServiceManagerDate%></font></td>
    <td width="7%" class="dotline" align="center">

    <%if(nServiceManagerWait>0){ %>

    	<a href="#" onclick="javascript:doSubmitForm('SERV_Manager_List.jsp?sel_project=<%=selProj%>&d_payment=<%=showNextPaymentDate%>');"><%=nServiceManagerWait%></a>

    <%}else{out.println(nServiceManagerWait);} %>

    </td>
    <td width="7%" class="dotline" align="center"><%=nServiceManagerPass%></td>
    <td width="7%" class="dotline" align="center">&nbsp;</td>

    <td width="7%" class="dotline" align="center"><a href="SERV_INFManager_List.jsp?itmType=02&sel_project=<%=selProj%>&d_payment=<%=showNextPaymentDate%>"><%=nPUBServiceManagerWait%></a></td>
    <td width="7%" class="dotline" align="center"><%=nPUBServiceManagerPass%></td>
    <td width="7%" class="dotline" align="center">&nbsp;</td>

    <td width="8%" class="dotline" align="center"><a href="SERV_INFManager_List.jsp?itmType=01&sel_project=<%=selProj%>&d_payment=<%=showNextPaymentDate%>"><%=nINFServiceManagerWait%></a></td>
    <td width="8%" class="dotline" align="center"><%=nINFServiceManagerPass%></td>
    <td width="8%" class="dotline" align="center">&nbsp;</td>
  </tr>

  <tr>
    <td width="34%" class="item ; dotline" align="left"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="13" height="13">
      AVP ผู้ช่วยผู้จัดการฝ่าย&nbsp; <font color="#993300">อนุมัติภายในวันที่ <%=showNextManagerDate%></font></td>
    <td width="7%" class="dotline" align="center">

    <%if(nManagerWait>0){ %>

    	<a href="#" onclick="javascript:doSubmitForm('SERV_Zone_List.jsp?sel_project=<%=selProj%>&d_payment=<%=showNextPaymentDate%>');"><%=nManagerWait%></a>

    <%}else{out.println(nManagerWait);} %>

    </td>
    <td width="7%" class="dotline" align="center"><%=nManagerPass%></td>
    <td width="7%" class="dotline" align="center">&nbsp;</td>

    <td width="7%" class="dotline" align="center"><a href="SERV_INFZone_List.jsp?itmType=02&sel_project=<%=selProj%>&d_payment=<%=showNextPaymentDate%>"><%=nPUBManagerWait%></a></td>
    <td width="7%" class="dotline" align="center"><%=nPUBManagerPass%></td>
    <td width="7%" class="dotline" align="center">&nbsp;</td>

    <td width="8%" class="dotline" align="center"><a href="SERV_INFZone_List.jsp?itmType=01&sel_project=<%=selProj%>&d_payment=<%=showNextPaymentDate%>"><%=nINFManagerWait%></a></td>
    <td width="8%" class="dotline" align="center"><%=nINFManagerPass%></td>
    <td width="8%" class="dotline" align="center">&nbsp;</td>

  </tr>

  <tr>
    <td width="34%" class="item ; dotline" align="left"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="13" height="13">
      VP - ผู้จัดการฝ่าย&nbsp; <font color="#993300">อนุมัติภายในวันที่ <%=showNextVPDate%></font></td>
    <td width="7%" class="dotline" align="center">

    <%if(nVPWait>0){ %>

    	<a href="#" onclick="javascript:doSubmitForm('SERV_VP_List.jsp?sel_project=<%=selProj%>&d_payment=<%=showNextPaymentDate%>');"><%=nVPWait%></a>

    <%}else{out.println(nVPWait);} %>

    </td>
    <td width="7%" class="dotline" align="center"><a href="SERV_Pass_List.jsp?sel_project=<%=selProj%>&d_payment=<%=showNextPaymentDate%>"><%=nVPPass%></a></td>
    <td width="7%" class="dotline" align="center">&nbsp;</td>

	<td width="7%" class="dotline" align="center"><a href="SERV_INFVP_List.jsp?itmType=02&sel_project=<%=selProj%>&d_payment=<%=showNextPaymentDate%>"><%=nPUBVPWait%></a></td>
    <td width="7%" class="dotline" align="center"><a href="SERV_INFPass_List.jsp?itmType=02&sel_project=<%=selProj%>&d_payment=<%=showNextPaymentDate%>"><%=nPUBVPPass%></a></td>
    <td width="7%" class="dotline" align="center">&nbsp;</td>

	<td width="8%" class="dotline" align="center"><a href="SERV_INFVP_List.jsp?itmType=01&sel_project=<%=selProj%>&d_payment=<%=showNextPaymentDate%>"><%=nINFVPWait%></a></td>
    <td width="8%" class="dotline" align="center"><a href="SERV_INFPass_List.jsp?itmType=01&sel_project=<%=selProj%>&d_payment=<%=showNextPaymentDate%>"><%=nINFVPPass%></a></td>
    <td width="8%" class="dotline" align="center">&nbsp;</td>
  </tr>
  
<%  }  %>
</table>            
    </td>
  </tr>
</table>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>

<% 
//}  

//System.out.println(" --- SERV_Home.jsp : Complete ---" );
%>
<br style="font-size:2pt">

 <table border="0" width="100%" cellspacing="0" cellpadding="0" height="10">
          <tr>
           <td class="act_tab1">งานซ่อมบ้าน  Approve 1 = Service Staff เจ้าหน้าที่บริการ ,    Approve 2 = Service Manager</td>
		   </tr>
		   <tr>
           <td class="act_tab1">งานซ่อมสาธารณูฯ,สาธารณะ  Approve 1 = Service Manager ,   Approve 2 = Senior Manager</td>
		   </tr>
	</table>		

        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">

            </td>   
      	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>  
        </table>  

          </td>
        </tr>
      </table>

<br style="font-size:30pt">

<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
  <tr><td width="100%" class="copyright" align="center">
  Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5  
  <br>ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;
  หรือ โทร. 0-2230-8279 (คุณประพัฒน์
  ฝ่ายบริการ)&nbsp; 0-2230-8491-5 (ฝ่าย IT)  
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE> 
	
</FORM>

</BODY>

</HTML>
<%

		} //--------------=================== for other user ==========================------//

       System.out.println("--------- SERV_Home_VP.jsp ---------");
	} catch (Exception e) {
		System.out.println("!!! ERROR SERV_Home_VP.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (stmt != null) stmt.close();
			if (stmt1 != null) stmt1.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>