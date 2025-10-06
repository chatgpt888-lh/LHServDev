<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>

<%@page import="java.io.*" %>
<%@page import="java.text.*" %>
<%@page import="java.net.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%!
/**
 * Modify by : pradoem@lh.co.th
 * date : 2015.04.28
 * version 1.1
 * desc: 
 *  1. เพิ่ม  comment สำหรับผู้ขออนุมัติสำหรับ Turn Key
 *  2. เพิ่ม  Dialog box สำหรับกรณี CANCEL  
 *  3. เปลี่ยน ปุ่ม  Submit เป็น Submit to Approve กรณี Turnkey
 *  4. เพิ่มการ Attach รูปภาพ 
 */ 
 
 	
public void copyFile(File in, File out) throws Exception {
	FileInputStream fis  = new FileInputStream(in);
	FileOutputStream fos = new FileOutputStream(out);
	byte[] buf = new byte[1024];
	int i = 0;
	while((i=fis.read(buf))!=-1) {
	  fos.write(buf, 0, i);
	  }
	fis.close();
	fos.close();
}

 public String genVendorList(Connection conn,String name, String selProj, String value, String params,int index){
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        String comId = "";
        String projId = "";
        try{
            stmt = conn.createStatement();
            StringTokenizer id = new StringTokenizer(selProj, ":");
            if(id != null && id.countTokens() == 2) {
                comId = id.nextToken();
                projId = id.nextToken();
            }
            sql.append(" select b.bus_name,a.* from lan:serv_venprj a  ").append(" left join lan:stpvendr b on b.vend_code=a.i_vendor ").append(" where a.i_type='01' ").append(" and a.i_company='").append(comId).append("' ").append(" and a.i_project='").append(projId).append("' ").append(" order by b.bus_name ");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select id='vendId_"+index+"' name='").append(name).append("' ").append(params).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            String iVendor;
            String vendorName;
            String selected;
            for(; rs.next(); html.append("<option value='").append(iVendor).append("' ").append(selected).append(">").append(vendorName).append("</option>")) {
                iVendor = doString.checkString(rs.getString("i_vendor"), "");
                vendorName = doString.checkString(doString.DisplayThai(rs.getString("bus_name")), "");
                selected = "";
                if(value != null && iVendor.equalsIgnoreCase(value)){
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
        }catch(Exception e){
            System.out.println(" genVendorList Error : " + e.getMessage());
        }
        finally{
            try {
                if(rs != null)  {
                    rs.close();
                }
                if(stmt != null) {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

 //modify by pradoem 2016.02.04
  public String genAreaList(Connection conn,String name, String value, String params,int index){
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try {
            stmt = conn.createStatement();
            sql.append(" select * from lan:serv_xstd where i_type='01' ").append(" order by n_desc ");
            rs = stmt.executeQuery(sql.toString());
            //html.append("<select name='").append(name).append("' ").append(params).append(" onchange='javascript:onChangePageDDL();' >");
            html.append("<select id='areaId_"+index+"' name='").append(name).append("' ").append(params).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            String iCode;
            String nDesc;
            String selected;
            for(; rs.next(); html.append("<option value='").append(iCode).append("' ").append(selected).append(">").append(nDesc).append("</option>")) {
                iCode = doString.checkString(rs.getString("i_code"), "");
                nDesc = doString.checkString(doString.DisplayThai(rs.getString("n_desc")), "");
                selected = "";
                if(value != null && iCode.equalsIgnoreCase(value)){
                    selected = " selected ";
                }
            }
            html.append("</select>");
            rs.close();
            stmt.close();
        }catch(Exception e) {
            System.out.println(" genAreaList Error : " + e.getMessage());
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
        return html.toString();
    }
 
 
 //Fix name CauseDDL
   public String GenCauseHtmlDDL(Connection conn,String name, String value, String params){
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try {
            stmt = conn.createStatement();
            sql.append(" select i_type,i_code,n_desc  from lan:serv_xstd where i_type='55' ").append(" order by i_type,i_code,n_desc  ");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select id='"+name+"' name='").append(name).append("' ").append(params).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            String iCode;
            String nDesc;
            String selected;
            for(; rs.next(); html.append("<option value='").append(iCode).append("' ").append(selected).append(">").append(nDesc).append("</option>")) {
                iCode = doString.checkString(rs.getString("i_code"), "");
                nDesc = doString.checkString(doString.DisplayThai(rs.getString("n_desc")), "");
                selected = "";
                if(value != null && iCode.equalsIgnoreCase(value)){
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
        }catch(Exception e) {
            System.out.println("  GenCauseHtmlDDL Error : " + e.getMessage());
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
        return html.toString();
    }
 
 
   public String getKeyGen(Connection conn,String iDocNo,String iKeygen){
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        String keyGen = "";
        try {
            stmt = conn.createStatement();
  			sql.delete(0, sql.length());
			sql.append(" Select i_keygen  ")
				.append(" From lan:serv_docatt ")
				.append(" Where i_docno  = '"+iDocNo+"' AND i_keygen = "+iKeygen+" ")
				.append(" order by i_seq ");	
				//System.out.println("SQL  :"+sql.toString());
				rs = stmt.executeQuery(sql.toString());    				   
			    if(rs.next()){
			       keyGen  = doString.checkString(rs.getString("i_keygen"),"");
			    } 					  
            rs.close();
            stmt.close();
        }catch(Exception e) {
            System.out.println(" getKeyGen Error : " + e.getMessage());
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
        return keyGen;
    } 
  
   public boolean IsProjectTurnKey(Connection conn,String comId,String projectId){
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        
        String f_tk = "";
        boolean isRecord = false;
        try {

            stmt = conn.createStatement();
  			sql.delete(0, sql.length());
			sql.append(" Select f_tk  ")
				.append(" From lan:serv_lstaff ")
				.append(" Where i_company  = '"+comId+"' AND i_project = '"+projectId+"' "); 
				//System.out.println("SQL TurnKey  :"+sql.toString());
				rs = stmt.executeQuery(sql.toString());    				   
			    if(rs.next()){
			       f_tk  = doString.checkString(rs.getString("f_tk"),"");
			    } 		
			    if("Y".equalsIgnoreCase(f_tk)){ // is  project Turn Key
			       isRecord = true;
			    }else{
			       isRecord = false;
			    }	  
                rs.close();
                stmt.close();
                
        }catch(Exception e) {
            System.out.println(" IsProjectTurnKey Error : " + e.getMessage());
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
    
    //ระหัสผู้อนุมัติ และ email ผู้อนุมัติ
    public String[] GetApproval(Connection conn,String comId,String projectId){
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        
        String tempStr[] = new String[] {"","",""};
        try {

            stmt = conn.createStatement();
  			sql.delete(0, sql.length());
			sql.append("  Select  a.i_employ_app1,b.user_email  ")
				.append(" From lan:serv_lstaff a, lan:useracl b")
				.append(" Where ") 
     			.append(" a.i_company  = '"+comId+"' ")
				.append(" AND  a.i_project = '"+projectId+"'   ")
 				.append("AND  a.i_employ_app1 = b.i_employ  ")
 				.append("AND  b.user_acl = 'S' ");
				//System.out.println("SQL Approval  :"+sql.toString());
				rs = stmt.executeQuery(sql.toString());    				   
			    if(rs.next()){
			        tempStr[0]  = doString.checkString(rs.getString("i_employ_app1"),"");
			        tempStr[1]  = doString.checkString(rs.getString("user_email"),"");
			    } 		 
                rs.close();
                stmt.close();
                
        }catch(Exception e) {
            System.out.println(" GetApproval Error : " + e.getMessage());
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
        return tempStr;
    } 
    
   public String[] GetCommentServApproved(Connection conn,String docNo){
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        
       // String i_doc_type = "";
        //boolean isRecord = false;
        String tempStr[] = new String[] {"",""};
        try {

            stmt = conn.createStatement();
  			sql.delete(0, sql.length());
			sql.append(" Select i_remark,i_comment1 ")
				.append(" From lan:serv_approve ")
				.append(" Where i_docno  = '"+docNo+"'  "); //AND  i_doc_type ='3'
				//System.out.println("SQL GetCommentServApproved  :"+sql.toString());
				rs = stmt.executeQuery(sql.toString());    				   
			    if(rs.next()){
			       tempStr[0] = doString.DisplayThai(doString.checkString(rs.getString("i_remark"),""));
			       tempStr[1] = doString.DisplayThai(doString.checkString(rs.getString("i_comment1"),""));
			    } 		  
                rs.close();
                stmt.close();
                
        }catch(Exception e) {
            System.out.println(" GetCommentServApproved[]  Error : " + e.getMessage());
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
        return tempStr;
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
			sql.append("Select n_prename_th,n_nemploy_th,n_semploy_th From docflow:acemploy Where i_employ = ? ");
			pstmt = conn.prepareStatement(sql.toString()); 
			pstmt.setString(1, employId);	
			//System.out.println("SQL :"+sql.toString());
			rs = pstmt.executeQuery();	
			if(rs.next()){
				emmployName = doString.checkString(rs.getString("n_prename_th"), "")+" "+
				doString.checkString(rs.getString("n_nemploy_th"), "")+"  "+doString.checkString(rs.getString("n_semploy_th"), "");
			}
			rs.close();	
		}catch(Exception e){
 				System.out.println(" GetNameEmploy Error : " + e.getMessage());
		}
		finally{			
			//clean up.
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
			}catch(Exception e){}
		}
	  return emmployName;		
	}
	
	 /** For DDL เก็บประกันงานซ่อม 2015.06.25 **/ 
	 public String getWarrantyDesc(Connection conn,String iType){
	        StringBuffer sql = new StringBuffer();
	        Statement stmt = null;
	        ResultSet rs = null;
	        String desc = "";
	        try {
	            stmt = conn.createStatement();
	  			sql.delete(0, sql.length());
				sql.append(" Select n_desc  ")
					.append(" From lan:serv_xstd ")
					.append(" Where  i_type='98' AND i_code = '"+iType+"' ");	
					//System.out.println("SQL  :"+sql.toString());
					rs = stmt.executeQuery(sql.toString());    				   
				    if(rs.next()){
				       desc  = doString.checkString(rs.getString("n_desc"),"");
				    } 					  
	            rs.close();
	            stmt.close();
	        }catch(Exception e) {
	            System.out.println(" getInformJobDesc Error : " + e.getMessage());
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
	        return desc;
	   } 
	    
   /**** For condominium repair 2015.06.24 ****/ 
     public String[] GetCondoProfile(Connection conn,String comId,String projId){
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;

		boolean isCondo = false;
        String tempStr[] = new String[] {"","","","","","",""}; //"YES,NO","LH","075","2015-06-24","Y,N","หมดประกัน/อยู่ระหว่างประกัน","0841013129"
        java.sql.Timestamp dCloseLaw = null;
        try {
            stmt = conn.createStatement();
            /*1. Check project is Condo avaliable ?*/
  			sql.delete(0, sql.length());
			sql.append(" Select i_company,i_project,d_close_law,d_close_law-today as x  ")
				.append(" From  lan:serv_condo ")
				.append(" Where i_company  = '"+comId+"'  ")
				.append(" and i_project = '"+projId+"' ");

				//System.out.println("SQL GetCondo  :"+sql.toString());
				rs = stmt.executeQuery(sql.toString());    				   
			    if(rs.next()){
			       tempStr[0] = "YES";
			       tempStr[1] = doString.checkString(rs.getString("i_company"),"");
			       tempStr[2] = doString.checkString(rs.getString("i_project"),"");
			       //tempStr[3] = doString.checkString(rs.getString("d_close_law"),"");
			       dCloseLaw = rs.getTimestamp("d_close_law");	
			       
			        Calendar gurantee = Calendar.getInstance();
                    gurantee.setTime(dCloseLaw);
                   // gurantee.add(1, 1);       
                    if(rs.getInt("x")>0) {
						tempStr[4] = "Y";
	                    tempStr[5] = doString.DisplayThai(doString.UnicodeToMS874("อยู่ระหว่างประกัน"));
                    } else{
	                    tempStr[4] = "N";
	                    tempStr[5] = doString.DisplayThai(doString.UnicodeToMS874("หมดประกัน"));
                    }
                    tempStr[3] = getDateFromCalendar(gurantee);
			        isCondo = true;       
			    }else{
				    tempStr[0] = "NO";
				    tempStr[2] = "";
				    tempStr[3] ="";
				    tempStr[4] ="";
			    }
 				/** CASE : Condo = true **/
 				if(isCondo){					
	 				sql.delete(0, sql.length());
					sql.append(" Select i_tel ")
						.append(" From  lan:serv_prjdt ")
						.append(" Where i_company  = '"+comId+"'  ")
						.append(" and i_project = '"+projId+"' ");
						//System.out.println("SQL I_tel  :"+sql.toString());
					rs = stmt.executeQuery(sql.toString());    				   
				    if(rs.next()){
				    	tempStr[6] =  doString.checkString(rs.getString("i_tel"),"");
	 				}//#RS.Close
	 			}	  
                rs.close();
                stmt.close();
                
        }catch(Exception e) {
            System.out.println(" GetCondoProfile[]  Error : " + e.getMessage());
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
        return tempStr;
    }   
    
%>
<%--
/**
 * Modify by : pradoem@lh.co.th
 * date : 2012.08.09
 * version 1.1
 * desc:  add information list to Zero Defect && send mail to www9.lh.co.th to user
 */ --%>
 
 <%-- 
 /*********************************
 * Last modify by : pradoem
 * date : 2015.04.20
 * desc :
 * 1. attach file image for opne job
 */
 
 --%>

<%
//****************************************
/*String ParameterNames = "";
for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
	ParameterNames = (String)e.nextElement();
	System.out.println(ParameterNames + " = "+request.getParameter(ParameterNames));
}
System.out.println("*******************************************");
System.out.println("******************xxxxxxxxxx*************************");
*/
//String p2 = "";
//for(Enumeration e = session.getAttributeNames();e.hasMoreElements();){
//	p2 = (String)e.nextElement();
//	System.out.println(p2 + " = "+session.getAttribute(p2));
//}
//System.out.println("*****************xxxxxxxxxx**************************");

    //String hostName = "http://132.146.1.180:8080";
    //String pathUrlX = hostName+"/AppServ/uploads/";
    
	String sessionId = user.getsessionId();
	String userId = user.getUserID();
	String jName = "SERV_OpenJob.jsp";
	ServLog servlog = new ServLog(sessionId, userId, jName);
 	doString str = new doString();
  
   //----============ Declare Variables for input data ===========----//
   String toDate = getDateFromCalendar(Calendar.getInstance())+"&nbsp;"+getTimeFromCalendar(Calendar.getInstance());
   String mode = doString.checkString(request.getParameter("mode"),"add");
   String load = doString.checkString(request.getParameter("load"),"");
   String deleteJob = doString.checkString(request.getParameter("delete_job"),"");   
   String iDocNo = doString.checkString(request.getParameter("i_docno"),"");
   String fQC = doString.checkString(request.getParameter("f_qc"),"N").toUpperCase();
   
    String InformTypeDDL = "";
   //-----========= Declare Variables for Search Custoemr ===========----//
   String selProj = doString.DisplayThai(doString.checkString(request.getParameter("sel_project"),"")); 
   if (selProj.length()==0) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       session.setAttribute("sess_sel_proj",selProj);
   }
   

   String houseId = doString.DisplayThai(doString.checkString(request.getParameter("house_id"),""));
   String iLock = doString.DisplayThai(doString.checkString(request.getParameter("i_lock"),"").toUpperCase());
   String nCustomer = doString.DisplayThai(doString.checkString(request.getParameter("n_customer")));
   String nCustTel = doString.DisplayThai(doString.checkString(request.getParameter("n_cust_tel"),""));
   String dAppoint = doString.DisplayThai(doString.checkString(request.getParameter("d_appoint"),""));
   String dEstClose = doString.DisplayThai(doString.checkString(request.getParameter("d_est_close"),""));
  
   String i_remarkDesc = doString.DisplayThai(doString.checkString(request.getParameter("i_remarkDesc"),""));
   
   String inFormEmp = "";
   String inFormDate = "";
   String projDesc = "";
   String cDesc = "";   
   String housePlan = "-";
   String custName = "-";
   String custTel = "-";
   String guranteeDesc = "-";
   String guranteeDate = "-";
   String iCustomer = "";
   String comId = "";
   String projId = "";
   String iCompany = "";
   String iProject = "";   
   String iDocType = "";
   String cls_project = "";
   String iSystem = "";
   String chk_condo = "", emp_serv = "", name_serv = "";
	
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	
	Statement stmt2 = null;
	ResultSet rs2 = null;
	
	SERV_CommonData common = null;
	String itmtype = null;
	String from_page = null;
	try {
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement(); 
		stmt2 = conn.createStatement(); 
		common = new SERV_CommonData(conn);       
        //----=======================================----//   
  		
        //-------------- check upload file --------------//		
		String uploadId = doString.checkString((String) session.getAttribute("session_upload_id"),user.getsessionId());
		//System.out.println("session_upload_id1 : "+uploadId);
		if (uploadId.trim().length()<=0||"".equals(uploadId) || uploadId.equals(null)) {
			 uploadId = user.getsessionId();
			 session.setAttribute("session_upload_id",uploadId);
		}
		//System.out.println("session_upload_id2 : "+uploadId);
		//String realPath = getServletContext().getRealPath("/pictures/temp/")+File.separator+uploadId;
		//String docPath = getServletContext().getRealPath("/pictures/")+File.separator+iDocNo;
		//String delFile = doString.checkString(request.getParameter("del"),"");	
       itmtype = doString.checkString(request.getParameter("itmtype"),"");
       from_page = doString.checkString(request.getParameter("from_page"),"");
       //----==================--== If EDIT Mode , load Inform Data =====================------//
		
	    String editCustomer = "";
	    String editCustTel = "";
	   if (mode.equalsIgnoreCase("EDIT")) {	  
	        //----======================== Find DocHD Data =============================----//
			 Hashtable tmpHeader = common.getDocHeaderDetails(iDocNo);
		     inFormEmp = doString.DisplayThai(doString.checkString((String) tmpHeader.get("inform_emp"),""));
	         projDesc = doString.DisplayThai(doString.checkString((String) tmpHeader.get("proj_desc"),""));
	         iCompany = doString.checkString((String) tmpHeader.get("i_company"),"");
	         iProject = doString.checkString((String) tmpHeader.get("i_project"),"");
	         iDocType = doString.checkString((String) tmpHeader.get("i_doc_type"),"");
	         selProj = iCompany+":"+iProject;
	         nCustomer = doString.DisplayThai(doString.checkString((String) tmpHeader.get("n_customer"),""));
	         nCustTel = doString.DisplayThai(doString.checkString((String) tmpHeader.get("n_cust_tel"),""));
	         iLock = doString.checkString((String) tmpHeader.get("i_lock"),"");
	         cDesc = doString.DisplayThai(doString.checkString((String) tmpHeader.get("c_desc"),""));
	         cDesc = str.replace(cDesc,"|break|","<br>");
	         cDesc = str.replace(cDesc," ","&nbsp;"); 			
			 inFormDate = doString.DisplayThai(doString.checkString((String) tmpHeader.get("inform_date"),""));
			 iSystem = doString.checkString((String) tmpHeader.get("i_system"),"");
 	         if (load.equalsIgnoreCase("YES")) {
				 dAppoint = doString.DisplayThai(doString.checkString((String) tmpHeader.get("d_appoint"),""));
				 dEstClose = doString.DisplayThai(doString.checkString((String) tmpHeader.get("d_est_close"),""));	   
			  }		
			  
			 //2015.06.25 by pradoem
			 InformTypeDDL = doString.checkString((String) tmpHeader.get("i_warranty"),"");
			  	
			Vector checkSess = (Vector) session.getAttribute(ItmJobManagement.SESSION_JOBLIST);

			if (iDocType.equalsIgnoreCase("J") && (checkSess==null || (checkSess.size()==0 && load.equalsIgnoreCase("YES")))) {
				 
			    //----========== Find SERV_DOCDT for this HD =========-----//
			    ItmJobManagement itm = new ItmJobManagement(request,response);
                Random rand = new Random();
				Hashtable docdt = new Hashtable();
			    String id = "";
			    String nItmJob = "";
				String itemKey = "";	
				int seq = 1;			
			    
				sql.delete(0,sql.length());
				sql.append(" select a.*,b.n_itmjob,b.z_wage_unit o_wage,b.z_good_unit o_goods from lan:serv_docdt a  ")
				      .append(" left join lan:serv_boq b on b.i_itmjob=a.i_itmjob ")
				      .append(" where i_docno='").append(iDocNo).append("' ") 
				      .append(" order by  i_seq ,i_itmjob ");			  
	      
				servlog.startLog(sql.toString());
				rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
				while (rs.next()) {
					   docdt = new Hashtable();
					   id = doString.checkString(rs.getString("i_itmjob"),"");
					   nItmJob = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")),"");
					   //seq = doString.checkString(rs.getString("i_seq"),"");	   
					 					   
					   if (load.equalsIgnoreCase("YES")) {	
					   	  itemKey = doString.checkString(rs.getString("i_keygen"),""); //getKeyGen(conn,iDocNo, doString.checkString(rs.getString("i_keygen"),""));
					   }else{
					     itemKey = id+"_"; 
					   	 while (itemKey.length()<20) {
							itemKey += rand.nextInt(10); 
					      }
					   }
					   //System.out.println(" itemKey ="+itemKey);

					   itm.getJobList().addElement(itemKey);
					   itm.getItmJobList().put(itemKey,id);
					   itm.getItmSeqList().put(itemKey,doString.checkString(rs.getString("i_seq"),""));
					   itm.getVendorList().put(itemKey,doString.checkString(rs.getString("i_vendor"),""));
					   itm.getWageList().put(itemKey,doString.checkString(Double.toString(rs.getDouble("z_wage_price")),""));
					   itm.getCustomWageList().put(itemKey,doString.checkString(Double.toString(rs.getDouble("q_wage_unit")),""));
					   itm.getGoodsList().put(itemKey,doString.checkString(Double.toString(rs.getDouble("z_good_price")),""));
					   itm.getCustomGoodsList().put(itemKey,doString.checkString(Double.toString(rs.getDouble("q_good_unit")),""));
					   itm.getBOQList().put(itemKey,nItmJob+":"+Double.toString(rs.getDouble("o_wage"))+":"+Double.toString(rs.getDouble("o_goods")));					   
					   itm.getCommentList().put(itemKey,doString.checkString(rs.getString("c_itmjob")));
					   itm.getAreaList().put(itemKey,doString.checkString(rs.getString("i_itmjob_area"),""));
				   
					   //========================================for Edit=================================================================
						
						//------------- get file attach ----------//
						if (load.equalsIgnoreCase("YES")) {	
						   //System.out.println("//------------- get file attach ----------//");
						}//#YES
						//========================================for Edit=================================================================	
					   seq++;
				} // end while
				rs.close();							 
				//System.out.println("=== itm.updateItemSession ===");		
				itm.updateItemSession();
			}
		} else {
		    System.out.println("<<--MODE#2 xxx :"+mode);
		    //---============= Create no Inform , Get Project details ===========----//
			String com = selProj.length()>=6 ? selProj.substring(0,2) : "";
			String proj = selProj.length()>=6 ? selProj.substring(3,6) : "";
	        sql.delete(0,sql.length());
	        sql.append(" select i_company||'-'||i_project||'-'||n_project sel_project  from lan:acxprojt ")
	              .append(" where i_company='"+com+"'  and i_project='"+proj+"' ");
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			if (rs.next()) {
                 projDesc = doString.checkString(doString.DisplayThai(rs.getString("sel_project")),"");
			} // end while
			rs.close();	
			//---------------------------- Check Close Project -----------------------
			/*cls_project = "N";
			sql.delete(0,sql.length());
			sql.append("select distinct i_company, i_project from lan:serv_clspj ")
			   .append("where i_company = '"+com+"' and i_project='"+proj+"' and i_type = '01' ");
			   
			//System.out.println("SQL---------->> "+sql.toString());
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			if (rs.next()==true) {
				cls_project = "Y";
			}
			rs.close();*/	
		}//#END ELSE#

		//System.out.println("---> iSystem" +iSystem);
		//---------------------------- Check Close Project -----------------------
		//modify by pradoem 2016.05.19 edit amount case edit,add
		cls_project = "N";
		sql.delete(0,sql.length());
		sql.append("select distinct i_company, i_project from lan:serv_clspj ")
			.append("where i_company = '"+iCompany+"' and i_project='"+ iProject+"' and i_type = '01' ");
			   
		//System.out.println("SQL---------->> "+sql.toString());
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		if (rs.next()==true) {
			cls_project = "Y";
		}
		rs.close();		
		
		//System.out.println("clse status---------->> "+cls_project);
		//-----===================================================================----//
		//----======================= Get Customer Details ===========================----//
		if (selProj.indexOf(":")>0) {
		   iCompany = selProj.substring(0,selProj.indexOf(":"));
		   iProject = selProj.substring(selProj.indexOf(":")+1);
		}		
		Hashtable tmpCust = common.getCustomerDetails(iCompany,iProject,iLock);
	    housePlan = doString.checkString((String) tmpCust.get("i_model"),"");
	    houseId = doString.checkString((String) tmpCust.get("i_house"),"");
	    iLock = doString.checkString((String) tmpCust.get("i_lock"),"");
	    iCustomer = doString.checkString((String) tmpCust.get("i_customer"),"");
		guranteeDesc = doString.DisplayThai(doString.checkString((String) tmpCust.get("gurantee_desc"),""));
		guranteeDate = doString.DisplayThai(doString.checkString((String) tmpCust.get("gurantee_date"),""));
		custName = doString.DisplayThai(doString.checkString((String) tmpCust.get("n_customer"),""));
		custTel = doString.DisplayThai(doString.checkString((String) tmpCust.get("n_cust_tel"),""));        
       
           
       //---================ Add , Update , Delete Item List before get to use ===============----//
       ItmJobManagement itm = new ItmJobManagement(request,response);
       itm.updateValuesFromRequest(); // update new values from request.

	   //----========= If Click Add to CART , Update Item ===========----//
	   String addCart = doString.checkString(request.getParameter("add_cart"),"");
	   String itmList[] = null;
	   if (addCart.equalsIgnoreCase("YES")) {
	      itmList = request.getParameterValues("i_itmjob");
	      if (itmList!=null) {
	         for (int i=0;i<itmList.length;i++) {
	               itm.addItem(itmList[i]);
	         } // end for
	      }
	   } // end if check click      

       //----========= If Checkout some Item , remove that item ==========-----//   
	   Enumeration names = request.getParameterNames();
	   String pname = "";
	   String id = "";
	   String checked = "";
	   while (names.hasMoreElements()) {
	       pname = doString.checkString((String) names.nextElement(),"");
	       if (pname.indexOf("check_")==0) {
	          id = pname.substring(6);
	          checked = doString.checkString(request.getParameter(pname),"");
	          
	           //System.out.println("-->checked : "+checked);
	           if (checked.trim().length()==0) {
	           	  //System.out.println("-->id : "+id);
	              itm.removeItem(id); //--- Remove Item ----//
	          }
	       }
	   } // end while    

       //---====== If Delete item , remove and update session ========---//
       //System.out.println("Delete itemJob : "+deleteJob);      
       if (deleteJob.equalsIgnoreCase("YES")) { // If delete mode , remove item
           
           String imgKeyId = "";
           String tempId = "";
        
           itmList = request.getParameterValues("i_itmjob");
           
          if (itmList!=null) {
						 for (int i=0;i<itmList.length;i++) {
			                  itm.removeItem(itmList[i]);

				              tempId   = iDocNo+"_"+itmList[i];
							  tempId += "_999999";
						      tempId += "_99";		
							  //System.out.println("====KeyImg :"+tempId);
				             // doDeleteImage(realPath,session,tempId);
						}//#itmList
	           } // end while
	           
       }     
       itm.updateItemSession(); // update session before use


       //---======== Get Item Details for show ===========---//
       Vector jobList = itm.getJobList();
       Hashtable jobItm = itm.getItmJobList();
       Hashtable jobVendor = itm.getVendorList();
       Hashtable jobWage = itm.getWageList();
       Hashtable jobCustomWage = itm.getCustomWageList();
       Hashtable jobGoods = itm.getGoodsList();
       Hashtable jobCustomGoods = itm.getCustomGoodsList();
       Hashtable jobBOQ = itm.getBOQList();
       Hashtable jobComment = itm.getCommentList();
       Hashtable jobArea = itm.getAreaList();       

       Hashtable seqItm = itm.getItmSeqList();
      //---=========================================================================----//
 
       /** Last Update 2015.06.24 For Repair Condo ***/
        String tempArr[] = null;
        if(iDocNo.length()>0){
           tempArr  = iDocNo.split("\\-");
        }
        String condoProfileArr[] = GetCondoProfile(conn,iCompany,iProject);
        //---------------------------------------------------------------------
 
 	 
	 //1. Check the project is Turn Key ?
	 //2. if is Turn key  get Approve name & email
	 //3. display icon save&send
	 boolean isTurnKey = false;
	 isTurnKey = IsProjectTurnKey(conn,iCompany,iProject);
	 
	 //System.out.println("isTurnKey : "+isTurnKey);
	 
	 String []tempApprove = new String[] {"","",""}; //id,email,name&ser name display
	 String []tempComment = new String[]{"",""};
	 
	 tempComment = GetCommentServApproved(conn,iDocNo);
	 if(isTurnKey){
	 	//TODO: Case  project is Turn key
	 	
	 	tempApprove = GetApproval(conn,iCompany,iProject);
	 	//System.out.println("I_employ = "+tempApprove[0]);
	 	tempApprove[2] = GetNameEmploy(conn,tempApprove[0]);
	 }else{
	 	//TODO: Case Not turn key
	 }
	 
%>
<!DOCTYPE html>
<HTML>
<HEAD>
<TITLE>Service Open Job</TITLE>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">

<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<style type="text/css">
 .box2 {  font-family: Tohama,Arial,sans-serif; font-size:10.1pt; font-weight:normal;
		padding-top: 1px; padding-right: 1px; padding-bottom: 1px; padding-left: 1px; 
	 	color:#165396; background-color: white; border: 1px #BEDCFF solid ; 
}
.backgroundRed{
        background: #FFFF33;
        width:130px;
 		height:16px;
    }
</style>
<script language="javascript" src="script_fx.js"></script>

<script type='text/javascript' src='jquery/jquery-1.11.3.min.js'></script>
<script type='text/javascript' src='jquery/loadImg.js'></script>

<!--   for upload -->
<script language="javascript" src="resources/js/upload.js"></script>
<!-- use openUploadWindow(contextPath,sessionId) method --->

<script language="javascript">
<!--
  var windowObjectReference = null;
  function openUploadWindow2(contextPath,uploadId,keyFile,mm,yyyy,docIdx) {
	if (contextPath.length>0 && contextPath.substring(contextPath.length-1)!="/") 	{
	    contextPath += "/";
	}
    //console.log("key_file="+keyFile);
    //console.log("uploadId="+uploadId);
	var keys = new Array();
	keys[0] = uploadId;
	keys[1] = keyFile;
    var vReturnValue = window.open("https://portal.lh.co.th/AppServ/upload2_main.jsp?session_id="+uploadId+"&key_file="+keyFile+"&mm="+mm+"&yyyy="+yyyy+"&docIdx="+docIdx,"","Left=100,Top=100,width=500,height=380; center: Yes; resizable: No; status: No;");
	//var vReturnValue = window.open(contextPath+"upload2_main.jsp?session_id="+uploadId+"&key_file="+keyFile,"","Left=100,Top=100,width=400,height=380; center: Yes; resizable: No; status: No;");
	//console.log("vReturnValue=",vReturnValue);
	return vReturnValue;
 }
 
 function  refresh() {
  	  onPleaseWait();
	  doSubmitForm("<%=request.getContextPath()%>/SERV_OpenJob.jsp");	
 }
		
  var hostNameX = "<%=Utilizer.getPropValue("DOMAIN_NAME")%>";
  //var hostNameX = "https://portal.lh.co.th";
  function attachFiles(sessionIdx,docIdx,xKey,itemIdx,vendorIdx,qareaIdx,idx,mm,yyyy){
    if($("select[name="+xKey+"_vendor"+idx+"] option:selected").val()=="" ){	
       alert("!! กรุณาเลือกผู้รับเหมาด้วย .");
       $("#vendId_"+idx).focus();
       return;
    }else  if($("select[name="+xKey+"_area"+idx+"] option:selected").val()=="" ){	
       alert("!! กรุณาเลือกบริเวณด้วย .");
       $("#areaId_"+idx).focus();
       return;
    }else{
    
        if(vendorIdx==''){
          vendorIdx = $("#vendId_"+idx).val();
        } 
        if(qareaIdx==''){
          qareaIdx = $("#areaId_"+idx).val();
        } 

    	var myKeyFile = docIdx+"_"+xKey+"_"+vendorIdx+"_"+qareaIdx+"_"+idx;
    	//console.log("myKeyFile="+myKeyFile);
    	
    	if(windowObjectReference == null || windowObjectReference.closed){
  	   		  windowObjectReference = openUploadWindow2('<%=request.getContextPath()%>',sessionIdx,myKeyFile,mm,yyyy,docIdx); 	    
  	    }else{
  	   		windowObjectReference.focus();
  	    }
  	    // Create IE + others compatible event handler
		var eventMethod = window.addEventListener ? "addEventListener" : "attachEvent";
		var eventer = window[eventMethod];
		var messageEvent = eventMethod == "attachEvent" ? "onmessage" : "message";

		// Listen to message from child window
		 eventer(messageEvent,function(e) {
			 //console.log('origin: ', e.origin)

			  if(e.origin == hostNameX 
				  ||e.origin == 'http://132.146.1.180:8080' 
				  ||e.origin == 'http://localhost:9080' ||  e.origin == 'http://132.146.1.92' || e.origin == 'http://132.146.1.126' || e.origin == 'https://portal.lh.co.th' ){

				  console.log('popup message!: ', e.data);
				  //attachFileCallback(e.data);
			      //if (e.data==="OK") {
					document.forms[0].action='SERV_OpenJob.jsp';
					document.forms[0].submit();
			      //}	      
			  }
		}, false);
    }
  }

   //'Content-Type': 'application/json',
   function delFile(docId,mm,yyyy,imgId) {
		if(confirm("คุณแน่ใจว่าต้องการลบไฟล์แนบนี้ ?")) {
		 var param = "docId="+docId+"&mm="+mm+"&yyyy="+yyyy+"&imgId="+imgId;
		 //alert(param);
		 $.ajax({
	        crossDomain: true,
		    type: "POST",	
			url: "<%=Utilizer.getPropValue("DOMAIN_NAME")%>/AppServ/DeleteFileImagesById",
			data: param,
			success: function(data){
				//alert(data); //"A:11111:ทดสอบ"  "E:x:x"   				
				if(data==null || data==""){
					return;
				}  				
				var temp = data.split(":");
				refresh();
		    }
		  });
		}
	}
 	//--------------------------------

    function viewInform() {
        if (document.forms[0].mode.value.toUpperCase()=="ADD") {
           alert("Inform Job ของใบนี้ยังไม่ได้ถูกสร้าง !");
        } else {
           document.forms[0].action="SERV_InfJob_Disp.jsp?load=no";
           document.forms[0].submit();
        }
    }

  function addJobList() {
     MM_showLayersAppBox(false);
	 MM_showLayersCanBox(false);
	 
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_BOQSearch.jsp";
     document.forms[0].submit();
  }   

//TODO: validate by jquery logic
//text box access element 
//by input name: $('input[name="textboxname"]').val('some value');
//by input class:$('input[type=text].textboxclass').val('some value');
//by input id:$('#textboxid').val('some value');

//TODO: for span get value
//$('#textboxid').text();

function doSubmitForm(url){
    //alert("submit");
 	$('form').attr('action', url);
	$("form:first").submit();
}

  function validateForm(id) {
     var vendor = document.forms[0].elements(id+"_vendor");
     var wage = document.forms[0].elements(id+"_wage");
     var goods = document.forms[0].elements(id+"_goods");
     var area = document.forms[0].elements(id+"_area");
     if (vendor.value=="") {
        alert(" กรุณาเลือกผู้รับเหมาซ่อม !");
        vendor.focus();
        return false;
     }
     if (wage.value=="") {
        alert(" กรุณากรอกจำนวนค่าแรง !");
        wage.focus();
        return false;
     }
     if (goods.value=="") {
        alert(" กรุณากรอกจำนวนของ !");
        goods.focus();
        return false;
     }
     if (area.value=="") {
        alert(" กรุณาเลือกบริเวณ !");
        area.focus();
        return false;
     }               
     return true;
  }
 
function validateForm55(paramName){ 
	/* For Drop down List get Value */
	if($('select[name='+paramName+'_vendor] option:selected').val()==''){
		alert(" กรุณาเลือกผู้รับเหมาซ่อม !");
		$('select[name='+paramName+'_vendor]').focus();
		return false;
	}	
	/* For textbox $('input[name="textboxname"]').val('some value');*/
	if($('input[name='+paramName+'_wage]').val()==''){
		alert(" กรุณากรอกจำนวนค่าแรง !");
		$('input[name='+paramName+'_wage]').focus();
		return false;
	}
	if($('input[name='+paramName+'_goods]').val()==''){
		alert(" กรุณากรอกจำนวนของ !");
		$('input[name='+paramName+'_goods]').focus();
		return false;
	}
	/* For Drop down List get Value */
	if($('select[name='+paramName+'_area] option:selected').val()==''){
		alert(" กรุณาเลือกบริเวณ !");
		$('select[name='+paramName+'_area]').focus();
		return false;
	}
}

/*====  Submit Form narmal case ======*/
 function submitJob(){
    /*Checkbox:text .length  :check select items_job*/
    if($("input[name='i_itmjob']").length==0){
	   alert("คุณต้องทำการเพิ่มรายการซ่อม อย่างน้อย 1 รายการ !"); 
       return false; 
    }
    
    /*type:textbox||validate Date*/
    if($('input[name=d_appoint]').val()==''){
		alert(" กรุณาระบุวันที่นัดซ่อม !");
		$('input[name=d_appoint]').focus();
		return false;
	}else{
	  if (!checkFormatDate($('input[name=d_appoint]').val())) {
           $('input[name=d_appoint]').focus();
           return false;
        }
	}
	if($('input[name=d_est_close]').val()==''){
		alert(" กรุณาระบุวันที่คาดว่าจะเสร็จ !");
		$('input[name=d_est_close]').focus();
		return false;
	}else{
	  if (!checkFormatDate($('input[name=d_est_close]').val())) {
           $('input[name=d_est_close]').focus();
           return false;
        }
	}
	
	 var yearApp = parseInt($('input[name=d_appoint]').val().substring(6,10),10);
     if (yearApp>2400) yearApp-=543;
     var yearClose = parseInt($('input[name=d_est_close]').val().substring(6,10),10);
     if (yearClose>2400) yearClose-=543;     

	 var dApp = new Date(yearApp,parseInt($('input[name=d_appoint]').val().substring(3,5),10)-1,$('input[name=d_appoint]').val().substring(0,2),23,59,59);
	 var dClose = new Date(yearClose,parseInt($('input[name=d_est_close]').val().substring(3,5),10)-1,$('input[name=d_est_close]').val().substring(0,2),23,59,59);
	 var dCurrent = new Date();

	 if (dCurrent>dApp) {
	      alert("วันที่นัดซ่อมต้องไม่น้อยกว่าวันปัจจุบัน !");
          $('input[name=d_appoint]').focus();
          return false;	    
	 }
	 if (dApp>dClose) {
	    alert("วันที่ประมาณการเสร็จต้องไม่น้อยกว่าวันที่นัดซ่อม !");
        $('input[name=d_est_close]').focus();
        return false;	    
	 }

   /* type : Check box|| validate items_job*/
   var result = false;
   $.each($("input[name='i_itmjob']"), function(){            
      result = validateForm55($(this).val());
    });
    if(result==false){
    	return false;
    }
 	//alert("Submit OK..");
 	onPleaseWait();
 	doSubmitForm("<%=Constants.APP_PATH%>/SERV_OpenJobServlet");	
 }
  
//--------------------------------------------------------
/*==========Submit Form TurnKey========================*/
 function submitJobTurnKey(){
    MM_showLayersCanBox(false);
     /*Checkbox:text .length  :check select items_job*/
    if($("input[name='i_itmjob']").length==0){
	   alert("คุณต้องทำการเพิ่มรายการซ่อม อย่างน้อย 1 รายการ !"); 
       return false; 
    }
    
    /*type:textbox||validate Date*/
    if($('input[name=d_appoint]').val()==''){
		alert(" กรุณาระบุวันที่นัดซ่อม !");
		$('input[name=d_appoint]').focus();
		return false;
	}else{
	  if (!checkFormatDate($('input[name=d_appoint]').val())) {
           $('input[name=d_appoint]').focus();
           return false;
        }
	}
	if($('input[name=d_est_close]').val()==''){
		alert(" กรุณาระบุวันที่คาดว่าจะเสร็จ !");
		$('input[name=d_est_close]').focus();
		return false;
	}else{
	  if (!checkFormatDate($('input[name=d_est_close]').val())) {
           $('input[name=d_est_close]').focus();
           return false;
        }
	}
	
	 var yearApp = parseInt($('input[name=d_appoint]').val().substring(6,10),10);
     if (yearApp>2400) yearApp-=543;
     var yearClose = parseInt($('input[name=d_est_close]').val().substring(6,10),10);
     if (yearClose>2400) yearClose-=543;     

	 var dApp = new Date(yearApp,parseInt($('input[name=d_appoint]').val().substring(3,5),10)-1,$('input[name=d_appoint]').val().substring(0,2),23,59,59);
	 var dClose = new Date(yearClose,parseInt($('input[name=d_est_close]').val().substring(3,5),10)-1,$('input[name=d_est_close]').val().substring(0,2),23,59,59);
	 var dCurrent = new Date();

	 if (dCurrent>dApp) {
	      alert("วันที่นัดซ่อมต้องไม่น้อยกว่าวันปัจจุบัน !");
          $('input[name=d_appoint]').focus();
          return false;	    
	 }
	 if (dApp>dClose) {
	    alert("วันที่ประมาณการเสร็จต้องไม่น้อยกว่าวันที่นัดซ่อม !");
        $('input[name=d_est_close]').focus();
        return false;	    
	 }

   /* type : Check box|| validate items_job*/
   var result = false;
   $.each($("input[name='i_itmjob']"), function(){            
      //alert($(this).val());
      result = validateForm55($(this).val());
    });
    if(result==false){
    	return false;
    }
 	//alert("Submit OK..");
 	//doSubmitForm("<%=Constants.APP_PATH%>/SERV_OpenJobServlet");
    MM_showLayersAppBox(true);
 }
 //--------------------------------------------------------
  function deleteJob() {
     MM_showLayersAppBox(false);
	 MM_showLayersCanBox(false); 
     var selId = false;
     var item = document.forms[0].i_itmjob;
     if (item!=null) {
         if (item.length!=null) {
            for (var i=0;i<item.length;i++) {
                  if (item[i].checked) {
                     selId = true;
                     break;
                  }
            }
         } else {
            selId = item.checked;
         } 
     }
     if (!selId) {
        alert("คุณยังไม่ได้ทำการเลือกรายการที่ต้องการลบ !");
        return false;
     }    
    // alert("!!กรณีมีการ upload รูปงานซ่อมให้ไปลบรูปลบรูปภาพงานซ่อมของแต่ล่ะรายการก่อน");
     if (confirm("คุณแน่ใจว่าต้องการลบรายการซ่อมที่เลือก ?")) {
       document.forms[0].delete_job.value="YES";
       document.forms[0].action="<%=Constants.APP_PATH%>/SERV_OpenJob.jsp";
       document.forms[0].submit();        
     }
  }

  function  checkAll(obj,mainCheck,subCheck) {
     var main = document.forms[0].elements[mainCheck];
     var sub = document.forms[0].elements[subCheck];
     if (obj!=null && main!=null && sub!=null) {
         if (obj.name==mainCheck) {
		    if (sub.length!=null) {
				for (var i=0;i<sub.length;i++) {
					  sub[i].checked = obj.checked;
				}
			} 
			else {
			   sub.checked = obj.checked;
			}
         } else {
		    if (sub.length!=null) {
			    var flag = true;
				for (var i=0;i<sub.length;i++) {
					  flag = sub[i].checked;
					  if (!flag) break;
				}
				main.checked = flag;
			} else {
			   main.checked = obj.checked;
			} // end if check sub
         } // end if check mainCheck
     } // end if check null
  }  

  function removeComma(num) {
     num = ""+num;
     var tmp = "";
     while (num.indexOf(",")>=0) {
         if (num.substring(0,1)!=",") tmp += num.substring(0,1);
         num = num.substring(1);
     }       
     if (num.length>0) tmp += num;
     return tmp;
  }

  function addComma(number) {  
     number = '' + number;

     var precision = "";
     if (number.indexOf(".")>=0) {
         precision = number.substring(number.indexOf(".")+1);
         number = number.substring(0,number.indexOf("."));
     }
     if  (number.length > 3) {
          var mod = number.length % 3;
          var output = (mod > 0 ? (number.substring(0,mod)) : '');
          for (i=0 ; i < Math.floor(number.length / 3); i++) {
          if ((mod == 0) && (i == 0))
             output += number.substring(mod+ 3 * i, mod + 3 * i + 3);
          else
             output+= ',' + number.substring(mod + 3 * i, mod + 3 * i + 3);
          }

          if (precision.length>0) {
             output = output + "."+precision;
          }
          return (output);
   } else {
      if (precision.length>0) {
         number = number + "."+precision;
      }   
      return number;
   }
}

function setGoodsPrice(id) {
     var wage  = $('input[name='+id+'_wage]').val();
     $('input[name='+id+'_goods]').val(wage);
     //alert( $('input[name='+id+'_goods]').val());
}

function calculate(id,line) {
      //---- Calculate Wage ------//
      /* textbox : access by name */
      var wage     = $('input[name='+id+'_wage]').val();
      var wageUnit = $('input[name='+id+'_customwage]').val(); 
      /* textbox : access by #ID */
      //var wageSum  = $("#wage_sum_"+line) 

      var sumWage = 0;      
      //if (wage!=null && wageUnit!=null && wageSum!=null) {
      if (wage!=null && wageUnit!=null) {
         sumWage = (removeComma(wage)-0)*(removeComma(wageUnit)-0);
         //wageSum.innerHTML = addComma(sumWage.toFixed(2));
		 $("#wage_sum_"+line).text(addComma(sumWage.toFixed(2)));
      }

      //----- Calculate Goods ------//
      /* textbox : access by name */
      var goods =  $('input[name='+id+'_goods]').val(); 
      var goodsUnit =$('input[name='+id+'_customgoods]').val();  
      //var goodsSum = document.getElementById("goods_sum_"+line); 
 
      var sumGoods = 0;
      //if (goods!=null && goodsUnit!=null && goodsSum!=null) {
      if (goods!=null && goodsUnit!=null) {
         sumGoods = (removeComma(goods)-0)*(removeComma(goodsUnit)-0);
         //goodsSum.innerHTML = addComma(sumGoods.toFixed(2));      
         $("#goods_sum_"+line).text(addComma(sumGoods.toFixed(2)));
      }

      //----- Calculate SubTotal -----//
     //var sumTotal = document.getElementById("sum_total_"+line); 
      var sumTotal = $("#sum_total_"+line);
      if (sumTotal!=null) {
         var sum = sumWage+sumGoods;
         //sumTotal.innerHTML = addComma(sum.toFixed(2));    
         $("#sum_total_"+line).text(addComma(sum.toFixed(2)));        
      }

      //----- Calculate Total Wage , Total Goods and GrandTotal -----//
      var cnt = 0;
      var sumWageTotal = 0.0;
      var sumGoodsTotal = 0.0;

      while(true) {
         cnt++;
         var subWage = $("#wage_sum_"+cnt); 
         var subGoods =$("#goods_sum_"+cnt); 

         if (subWage!=null && subGoods!=null) {
            sumWageTotal += (removeComma($("#wage_sum_"+cnt).text())-0);
            sumGoodsTotal += (removeComma($("#goods_sum_"+cnt).text())-0);
         } else {
            break;
         }
         if (cnt>999) break;
      } // end while

      //---- Show Total ------//
      var sumGrandTotal = (sumWageTotal+sumGoodsTotal); 
  
      $("#totalWage").text(addComma(sumWageTotal.toFixed(2))); 
      $("#totalGoods").text(addComma(sumGoodsTotal.toFixed(2))); 
      $("#grandTotal").text(addComma(sumGrandTotal.toFixed(2)));
	}

	function convertDateFormat(dateObj) {
	   if (dateObj==null) return false;
		var countSlash = 0;
	    for (var i=0;i<dateObj.value.length;i++) {
		       if (dateObj.value.charAt(i)=='/') countSlash++;
		} // end for
		if (countSlash!=2) {
		    alert("รูปแบบวันที่ไม่ถูกต้อง!");
		    dateObj.focus();
		    return false;
		}
	    var splitDate = dateObj.value.split("/"); 
		var day = 0;
		var month = 0;
		var year = 0;
		try {
		    day = parseInt(splitDate[0],10);
		    month = parseInt(splitDate[1],10);
		    year = parseInt(splitDate[2],10);
		} catch (e) {
		   alert("วันที่ไม่ถูกต้อง!");
		   dateObj.focus();
		   return false;
		}

		if (day>=1 && day<=31) {
		    if (month>=1 && month<=12) {
		    if (isNaN(year) || (year>=100 && year<=999)) {
		        alert("กรุณาใส่ปีเป็นรูปแบบ yy หรือ yyyy เท่านั้น!");
				dateObj.focus();
				return false;
		      }
			   //----- Convert to BC. -------//	
			   if (year<45) year += 2543;
			   if (year>=45 && year<100) year += 2500;
			   if (year<2400) year += 543;
			    var dateStr = (day<10 ? "0"+day : day)+"/"+(month<10 ? "0"+month : month)+"/"+year;
	                    dateObj.value = dateStr;
				if (!checkFormatDate(dateStr)) {
				    dateObj.focus();
				    return false;
				}
			} else {
			   alert("เดือนต้องมีค่าระหว่าง 1 - 12 เท่านั้น!");
			   dateObj.focus();
			   return false;
			}
		} else {
		   alert("วันที่ต้องมีค่าระหว่าง 1 - 31 เท่านั้น!");
		   dateObj.focus();
		   return false;
		}
	}

	function checkFormatDate(str){
		mystring = str;
		if (mystring.match(/(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.]([1-9])\d\d\d/ ) ) { 
		   var yyyy = parseInt(str.substring(6,10),10);
		   var mm = parseInt(str.substring(3,5),10)-1;
		   var dd = parseInt(str.substring(0,2),10);
		   if (yyyy>2400) yyyy -= 543;

	       var cdate = new Date(yyyy,mm,dd);
		   if (mm!=cdate.getMonth()) {
		      alert("วันที่ไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
		      return false;
		   }
		} else {
			alert("รูปแบบวันที่ไม่ถูกต้อง !");
			return false;
		}
		return true;
	}  

	function cancelDoc(){
		//display Dialog Box Cancel
		//validation
		
		document.getElementById("iCanTypeDDL").style.visibility ='visible';
		//submit Form
		MM_showLayersAppBox(false);
		MM_showLayersCanBox(true);
	}

	function goBack(){
		var form = document.forms[0];
		form.action = '/LHServ/<%=from_page%>';
		form.submit();
	}
	
	function doCancelBox(status) {
		if(status){
			if(document.forms[0].iCanTypeDDL.value ==''){
				alert("กรุณาเลือกสาเหตุกรณี 'CANCEL' ด้วย!! ");
				document.forms[0].iCanTypeDDL.focus();
		        return;
			}else{  
				var form = document.forms[0];
				form.mode.value = 'CANCEL';
				form.back_page.value = 'BEYOND_DETAILS';
				form.action = '/LHServ/SERV_OpenJobServlet';
				form.submit();	
			 }
		}
		document.getElementById("canBox").style.visibility ='hidden';
		document.getElementById("iCanTypeDDL").style.visibility ='hidden';
	}
	
	//Submit Form For TurnKey Site
	function doAppBox(status) {
		if(status){
			document.forms[0].apprStatus.value = "Y";
		}else{
		    document.forms[0].apprStatus.value = "N";
		}
		document.getElementById("saveAppBox").style.visibility ='hidden';
		onPleaseWait();
		document.forms[0].action="<%=Constants.APP_PATH%>/SERV_OpenJobServlet";
		//document.forms[0].action="<%=Constants.APP_PATH%>/SERV_OpenJobServletDev";
		//alert(document.forms[0].action);
        document.forms[0].submit();
	}
	
	function MM_showLayersAppBox(status) {
	    if(status){
		  document.getElementById("saveAppBox").style.visibility ='visible';
		}else{
		  document.getElementById("saveAppBox").style.visibility ='hidden';
		}
	}
		
	function MM_showLayersCanBox(status) {
	    if(status){			 
			 document.getElementById("canBox").style.visibility ='visible';
		 }else{
		 	document.getElementById("canBox").style.visibility ='hidden';		 	
		 }
	}
	
	/* create by pradoem 2015.06.30  */
	/* Support text blink */

    $(document).ready(function () {
    var id = $(".cblink"); // div id=1
	 setInterval(function(){
        $(".cblink").toggleClass("backgroundRed");
     },200)
  });

//-->
</script>

<script>
function onPleaseWait(){
	document.all.pleasewaitScreen.style.pixelTop = (document.body.scrollTop + 120);
	$('#pleasewaitScreen').show();
	setTimeout(function(){  $('#pleasewaitScreen').css("visibility", 'hidden'); }, 7000); //wait 2 seconds
	$('#pleasewaitScreen').css('visibility', 'visible');
 } 
</script>
<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM METHOD="POST" ACTION="">

<!-- ########################################## -->
<DIV ID="pleasewaitScreen" STYLE="position: absolute; z-index: 0; top: 45%; left: 42%; display: none;">
<TABLE BORDER="1" BORDERCOLOR="rgb(180,210,250)" CELLPADDING="0" CELLSPACING="0" 
HEIGHT="125px" WIDTH="265px" ID="Table1">
	<TR>
	<TD BGCOLOR="#FFFFFF" ALIGN="CENTER" VALIGN="MIDDLE" class="test">
	<font color="rgb(255,120,0)"><b>Loading... Please wait</b></font>
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

<input type='hidden' name='back_page' >
<input type='hidden' name='mode' value='<%=mode%>'>
<input type='hidden' name='i_docno' value='<%=iDocNo%>'>
<input type="hidden" name="d_keyin_beg" value="<%=doString.checkString(request.getParameter("d_keyin_beg"), "")%>" />
<input type="hidden" name="d_keyin_end" value="<%=doString.checkString(request.getParameter("d_keyin_end"), "")%>" />
<input type="hidden" name="delete_job" value="">
<input type="hidden" name="iWarrantyCode" value="<%=InformTypeDDL%>">


<!-- Follow Back Link : itmtype i_docno i_company i_project from_page mode -->
<input type="hidden" name="itmtype" value="<%=itmtype%>" />
<input type="hidden" name="from_page" value="<%=from_page%>" />
<input type="hidden" name="i_company" value="<%=iCompany%>" />
<input type="hidden" name="i_project" value="<%=iProject%>" />

<input type="hidden" name="i_employ_app1" value="<%=tempApprove[0]%>" /> <%-- id_approve --%>
<input type="hidden" name="i_employ_email" value="<%=tempApprove[1]%>" /><%-- email_approve --%>
<input type="hidden" name="apprStatus" >


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh" align="left"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            Open Job</td>
          <td width="50%" align="right"><a href="#" onclick="viewInform();"><img border="0" src="images/icon_view_IFJ.gif" width="120" height="34"></a></td>
        </tr>
      </table>


<br style="font-size:10pt">               
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดการแจ้งซ่อม</td>
                <td class="item_tab3"></td>
                <td>&nbsp;</td>                
              </tr>
            </table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop">&nbsp;</td>
    <td width="5" valign="top" align="right"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>
<%
		//----------------------------- Project Condo ------------------------
			sql.delete(0, sql.length());
			sql.append("select i_company, i_project ")
				 .append("from lan:serv_condo ")
				 .append("where i_company = '"+iCompany+"' ")
				 .append("and i_project = '"+iProject+"' ");
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			if (rs.next()==true) {
				chk_condo = "Y";
			} else {
				chk_condo = "N";
			}

			sql.delete(0, sql.length());
			sql.append("select distinct i_service_employ ")
				 .append("from lan:serv_dochd ")
				 .append("where i_docno = '"+iDocNo+"' ");		
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			if (rs.next()) {
				emp_serv = doString.checkString(rs.getString("i_service_employ"));
			}                       
			name_serv = "";			
			if (emp_serv.trim().length()>4) {
						sql.delete(0, sql.length());
						sql.append("select distinct i_employ, n_prename_th, n_nemploy_th, n_semploy_th ")
							 .append("from docflow:acemploy ")
							 .append("where i_employ = '"+emp_serv+"' ");		
						servlog.startLog(sql.toString());
						rs = stmt.executeQuery(sql.toString());
						servlog.endLog();
						if (rs.next()) {
							name_serv = doString.checkString(doString.DisplayThai(rs.getString("n_prename_th")))+doString.checkString(doString.DisplayThai(rs.getString("n_nemploy_th")))+" "+doString.checkString(doString.DisplayThai(rs.getString("n_semploy_th")));
						}	
			} else {
						sql.delete(0, sql.length());
						sql.append("select distinct i_cust, n_name, n_sname ")
							 .append("from lan:serv_cname ")
							 .append("where i_cust = '"+emp_serv+"' ");		
						servlog.startLog(sql.toString());
						rs = stmt.executeQuery(sql.toString());
						servlog.endLog();
						if (rs.next()) {
							name_serv = doString.checkString(doString.DisplayThai(rs.getString("n_name")))+" "+doString.checkString(doString.DisplayThai(rs.getString("n_sname")));
						}				
			}//end if chk emp_serv
%>	
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR" align="center">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td class="item ; dotline01" height="22" width="13%">โครงการ :</td>
    <td height="22" width="39%" class="dotline01">
    <%=projDesc%>
    <%if(isTurnKey){ //width="120" height="34"  %>
       &nbsp;&nbsp;<img src="images/icon_TurnKey.gif" width="50" height="25" border="0" align="absmiddle">
    <%} %>
    <input type='hidden' name='sel_project' value='<%=selProj%>'>
    </td>
    <td height="22" class="item ; dotline01" width="14%">เลขที่ใบแจ้งซ่อม
      :</td>
    <td height="22" width="34%" class="dotline01">
    <%
        if (mode.equalsIgnoreCase("ADD")) {
           %><span style="width:100px">Auto Generated</span><%
        } else {
          out.println(iDocNo);
       }         
    %>
    </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">บ้านเลขที่ :</td>
    <td height="22" width="39%" class="dotline01">
    <%=houseId%>   
    <input type='hidden' name='house_id' value='<%=houseId%>'>
    </td>
    <td height="22" class="item ; dotline01" width="14%">แปลง :</td>
    <td height="22" width="34%" class="dotline01">
    <%=iLock%>       
    <input type='hidden' name='i_lock' value='<%=iLock%>'>
    </td>
  </tr>
  <tr>

    <td class="item ; dotline01" height="22" width="13%">แบบบ้าน :</td>
    <td height="22" width="39%" class="dotline01"><%=housePlan%></td>
    <td height="22" class="item ; dotline01" width="14%">มาจากช่องทาง :</td>
    <td height="22" width="34%" class="dotline01">&nbsp;
	<%
    if(iSystem.equals("LSV")){
    %>
    <img src="https://img.icons8.com/color/18/000000/line-me.png">
    <%
    }else{
      out.println(iSystem);
    }
     %>
    </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ชื่อผู้แจ้ง/ลูกค้า:</td>
    <td height="22" width="39%" class="dotline01">
    <% /*if("".equals(nCustomer)){
    	nCustomer = common.joinContactAndOwner(nCustomer,custName);
    }*/ %>
    <%=common.joinContactAndOwner(nCustomer,custName)%>
    <input type='hidden' name='n_customer' value='<%=nCustomer%>'>    
    </td>
    <td height="22" class="item ; dotline01" width="14%">โทรศัพท์ติดต่อ :</td>
    <td height="22" width="34%" class="dotline01">
    <% /*if("".equals(nCustTel)){
    	nCustTel = common.joinContactAndOwner(nCustTel,custTel);
    }*/
     %>
    <%=common.joinContactAndOwner(nCustTel,custTel)%>
    <input type='hidden' name='n_cust_tel' value='<%=nCustTel%>'>    
    </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">การประกัน :</td>
    <td height="22" width="39%" class="dotline01">
    <%
    //=guranteeDesc
    if(condoProfileArr[0].equals("YES")){ //CASE : is Condo
    	out.println(condoProfileArr[5]);
    }else{ // CASE : Not Condo
    	out.println(guranteeDesc);
    }
    %></td>
    <td height="22" class="item ; dotline01" width="14%">วันที่หมดประกัน:</td>
    <td height="22" width="34%" class="dotline01">
    <%
    //=guranteeDate
    if(condoProfileArr[0].equals("YES")){ //CASE : is Condo
    	out.println(condoProfileArr[3]);
    	guranteeDate = condoProfileArr[3];
    }else{ // CASE : Not Condo
    	out.println(guranteeDate);
    }
    %>
     <input type='hidden' name='guranteeDate' value='<%=guranteeDate%>'>  
    </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ผู้รับเรื่อง
      :</td>
    <td height="22" width="39%" class="dotline01">
    <%
        if (mode.equalsIgnoreCase("ADD")) {
           out.println(doString.DisplayThai(user.getEmpName()));
        } else {
				if (chk_condo.equals("Y")) {
						out.println(name_serv);
				} else {
						out.println(inFormEmp);
				}
       }         
    %>    
    </td>
    <td height="22" class="item ; dotline01" width="14%">วันเวลาที่แจ้ง
      :</td>
    <td height="22" width="34%" class="dotline01">
        <%
        if (mode.equalsIgnoreCase("ADD")) {
           out.println(toDate);
        } else {
          out.println(inFormDate);
       }         
    %>  
    </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">วันที่นัดซ่อม
      :</td>
    <td height="22" width="39%" class="dotline01"><input type="text"  onchange="convertDateFormat(this);" name="d_appoint" style="width:120px" class="box" value="<%=dAppoint%>"> &nbsp; (d/m/yy หรือ dd/mm/yyyy)</td>
    <td height="22" class="item ; dotline01" width="14%">วันที่ประมาณการเสร็จ
      :</td>
    <td height="22" width="34%" class="dotline01"><input type="text" onchange="convertDateFormat(this);" name="d_est_close" style="width:120px" class="box" value="<%=dEstClose%>"> &nbsp; (d/m/yy หรือ dd/mm/yyyy)</td>
  </tr>

  <tr>
    <td class="item ; dotline01" height="22" width="13%">ตรวจสอบคุณภาพงานซ่อม :</td>
    <td height="22" width="39%" class="dotline01">
		    <input type="radio" name="f_qc" value="Y" <%=fQC.equals("Y") ? " checked " : ""%>>Yes &nbsp;
		    <input type="radio" name="f_qc" value="N" <%=fQC.equals("N") ? " checked " : ""%>>No           
    <%
        if (mode.equalsIgnoreCase("ADD")) {
        } else {
       }      
    %>
    </td>
    <td height="22" class="item ; dotline01" width="14%">ประเภทใบแจ้งซ่อม : </td>
    <td height="22" width="34%" class="dotline01">
	<% String tempX =doString.DisplayThai(getWarrantyDesc(conn,InformTypeDDL));
	if(!"".equals(tempX)){
	  %>
	     <div class="cblink" ><%=tempX %>&nbsp;</div>
     <%} %>
     
    </td>
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



<br style="font-size:5pt">


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายการซ่อม</td>
                <td class="item_tab3"></td>
                <td>&nbsp;</td>
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
    <td width="100%" class="frmL">

      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="2%" rowspan="2" class="col_name"><input type="checkbox" name="main_check" onclick="checkAll(this,'main_check','i_itmjob');"></td>
          <td width="3%" rowspan="2" class="col_name">No.</td>
          <td width="15%" rowspan="2" class="col_name">รายการซ่อม</td>
          <td width="6%" rowspan="2" class="col_name">หน่วยนับ</td>
          <td width="20%" rowspan="2" class="col_name">ผู้รับเหมาซ่อม</td>
          <td colspan="3" class="col_name">ค่าแรง</td>
          <td colspan="3" class="col_name">ค่าของ</td>
          <td width="10%" rowspan="2" class="col_name">รวมเงิน</td>
        </tr>

        <tr>
          <td width="8%" class="col_nameLow">ต่อหน่วย</td>
          <td width="4%" class="col_nameLow">จำนวน</td>
          <td width="10%" class="col_nameLow">รวม</td>
          <td width="8%" class="col_nameLow">ต่อหน่วย</td>
          <td width="4%" class="col_nameLow">จำนวน</td>
          <td width="10%" class="col_nameLow">รวม</td>
        </tr>


        <%
        int line = 0;
        DecimalFormat format = new DecimalFormat("#,##0.00");
        DecimalFormat formatInput = new DecimalFormat("###0.00");
        double grandTotalWage = 0.00;
        double grandTotalGoods = 0.00;
        double grandTotal = 0.00;

		String key = "";
		id = "";
		String vendor = "";
		String BOQDesc = "";
		double wageUnit = 0.0;
		double goodsUnit = 0.0;

		String itmDesc = "";
		String itmCountUnit = "";
		double wagePrice = 0.00;
		double customWagePrice = 0.00;
		double goodsPrice = 0.00;                
		double customGoodsPrice = 0.00;
		double totalWage = 0.00;
		double totalGoods = 0.00;
		double subTotal = 0.00;
		StringTokenizer boq = null;

 		//HastableImgKey.clear();
        for (int i=0;i<jobList.size();i++) {
                line++;
                key = (String) jobList.elementAt(i);
               // System.out.println("xx key = "+key);
                
                id = doString.checkString((String) jobItm.get(key),"");
                vendor = doString.checkString((String) jobVendor.get(key),"");
                BOQDesc = doString.checkString((String) jobBOQ.get(key),"");
                wageUnit = Double.parseDouble(str.replace(doString.checkString((String) jobWage.get(key),"0"),",",""));
                goodsUnit = Double.parseDouble(str.replace(doString.checkString((String) jobGoods.get(key),"0"),",",""));

                itmDesc = "";
                itmCountUnit = "";
                wagePrice = 0.00;
                customWagePrice = 0.00;
                goodsPrice = 0.00;                
                customGoodsPrice = 0.00;
                totalWage = 0.00;
                totalGoods = 0.00;
                subTotal = 0.00;
          
                boq = new StringTokenizer(BOQDesc,":");
	            sql.delete(0,sql.length());
	            sql.append(" select * from lan:serv_boq where i_itmjob='").append(id).append("' ");
				servlog.startLog(sql.toString());
	            rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
	            if (rs.next()) {
	                //itmDesc = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")),"");
					//itmDesc = doString.DisplayThai(rs.getString("n_itmjob"));
	                itmDesc = doString.checkString(rs.getString("n_itmjob"),"");
	                itmCountUnit = doString.checkString(doString.DisplayThai(rs.getString("n_count")),"");  
	                if (boq.countTokens()==3) {
	                    //---===== Get data from session ======---//
	                    itmDesc = doString.UnicodeToMS874(boq.nextToken());
		                wagePrice = Double.parseDouble(str.replace(boq.nextToken(),",",""));
		                goodsPrice = Double.parseDouble(str.replace(boq.nextToken(),",",""));
		                customWagePrice = Double.parseDouble(str.replace(doString.checkString((String) jobCustomWage.get(key),"0.00"),",",""));
		                customGoodsPrice = Double.parseDouble(str.replace(doString.checkString((String) jobCustomGoods.get(key),"0.00"),",",""));   
	                } else {	       
	                   //---====== Load from SERV_BOQ ======--//         
		                wagePrice = rs.getDouble("z_wage_unit"); 
		                goodsPrice = rs.getDouble("z_good_unit"); 
		                customWagePrice = wagePrice;
		                customGoodsPrice = goodsPrice;
		                jobBOQ.put(key,doString.DisplayThai(itmDesc)+":"+Double.toString(wagePrice)+":"+Double.toString(goodsPrice));
						//jobBOQ.put(key,itmDesc+":"+Double.toString(wagePrice)+":"+Double.toString(goodsPrice));
		                jobComment.put(key,itmDesc);
		                jobCustomWage.put(key,Double.toString(customWagePrice));
		                jobCustomGoods.put(key,Double.toString(customGoodsPrice));
		                session.setAttribute(ItmJobManagement.SESSION_BOQ,jobBOQ);
		                session.setAttribute(ItmJobManagement.SESSION_CUSTOM_WAGE,jobCustomWage);
		                session.setAttribute(ItmJobManagement.SESSION_CUSTOM_GOODS,jobCustomGoods);
		                session.setAttribute(ItmJobManagement.SESSION_COMMENT,jobComment);		                
	                } //end if check boq	                

	                totalWage = customWagePrice * (double) wageUnit;
	                totalGoods = customGoodsPrice * (double) goodsUnit;
	                subTotal = totalWage + totalGoods;
	                grandTotalWage += totalWage;
	                grandTotalGoods += totalGoods;
	                grandTotal += subTotal;
	            }
	            rs.close();
	            
	            //HastableImgKey.put(key,key);
	            
		        %>
		        <tr>
		          <td width="2%" align="center" class="dotline"><%//=key %>
		          	<input type="checkbox" name="i_itmjob" value="<%=key%>" onclick="checkAll(this,'main_check','i_itmjob');">
		          </td>
		          <td width="3%" align="center" class="dotline"><%=line%></td>
		          <td width="15%" class="dotline"><%=doString.DisplayThai(itmDesc)%></td>
		          <td width="6%" class="dotline" align="center"><%=itmCountUnit%></td>
		          <td width="20%" class="dotline ; item"><%=genVendorList(conn,key+"_vendor"+line,selProj,vendor," class='box2' style='width:180px' ",line)%></td>
		          <td width="8%" align="right" class="dotline">
		          <!--<span id="wage_unit_<%=line%>"><%=format.format(wagePrice)%></span>-->
		          <%
		             if (wagePrice==0 || cls_project.equals("Y")) {    //  Check Close Project
		                %><input type="text" maxlength="8" class="boxR" style="width:100%" onchange="calculate('<%=key%>','<%=line%>');" name="<%=key%>_customwage" value="<%=formatInput.format(customWagePrice)%>"><%
		             } else {  //  input here
		                %>
		                <%=format.format(customWagePrice)%>
		                <input type="hidden" name="<%=key%>_customwage" value="<%=formatInput.format(customWagePrice)%>">
		                <%
		             }
		          %>
		          </td>
		          <td width="4%" align="center" class="dotline"><input type="text" maxlength="4" name="<%=key%>_wage" class="boxR" style="width:100%" value="<%=wageUnit%>" onchange="setGoodsPrice('<%=key%>');calculate('<%=key%>','<%=line%>');"></td>
		          <td width="10%" align="right" class="dotline"><span id="wage_sum_<%=line%>"><%=format.format(totalWage)%></span></td>
		          <td width="8%" align="right" class="dotline">
		          <!--<span id="goods_unit_<%=line%>"><%=format.format(goodsPrice)%></span>-->
		          <%
		             if (goodsPrice==0 || cls_project.equals("Y")) {    //  Check Close Project
		                %><input type="text" maxlength="8" class="boxR" style="width:100%" onchange="calculate('<%=key%>','<%=line%>');" name="<%=key%>_customgoods" value="<%=formatInput.format(customGoodsPrice)%>"><%
		             } else {
		                %>
		                <%=format.format(customGoodsPrice)%>
		                <input type="hidden" name="<%=key%>_customgoods" value="<%=formatInput.format(customGoodsPrice)%>">
		                <%
		             }
		          %>		          
		          </td>
		          <td width="4%" align="center" class="dotline"><input type="text" maxlength="4" name="<%=key%>_goods" class="boxR" style="width:100%" value="<%=goodsUnit%>" onchange="calculate('<%=key%>','<%=line%>');"></td>
		          <td width="10%" align="right" class="dotline"><span id="goods_sum_<%=line%>"><%=format.format(totalGoods)%></span></td>
		          <td width="10%" align="right" class="dotline"><span id="sum_total_<%=line%>"><%=format.format(subTotal)%></span></td>
		        </tr>
		        <%
        } // end for

        //while (line<Constants.SERV_OPENJOB_LINE) {
        while (line<3) {
            line++;
		        %>
		        <tr>
		          <td width="2%" align="center" class="dotline">&nbsp;</td>
		          <td width="3%" align="center" class="dotline">&nbsp;</td>
		          <td width="15%" class="dotline">&nbsp;</td>
		          <td width="6%" class="dotline" align="center">&nbsp;</td>
		          <td width="20%" class="dotline ; item">&nbsp;</td>
		          <td width="8%" align="right" class="dotline">&nbsp;</td>
		          <td width="4%" align="center" class="dotline">&nbsp;</td>
		          <td width="10%" align="right" class="dotline">&nbsp;</td>
		          <td width="8%" align="right" class="dotline">&nbsp;</td>
		          <td width="4%" align="center" class="dotline">&nbsp;</td>
		          <td width="10%" align="right" class="dotline">&nbsp;</td>
		          <td width="10%" align="right" class="dotline">&nbsp;</td>
		        </tr>
				<%
		} // end while
		%>
        <tr>
          <td width="2%" align="center" class="dotline">&nbsp;</td>
          <td width="3%" align="center" class="dotline">&nbsp;</td>
          <td width="15%" class="dotline">&nbsp;</td>
          <td width="6%" class="dotline" align="center">&nbsp;</td>
          <td width="20%" class="dotline ; item" align="right">รวม</td>
          <td width="8%" align="right" class="dotline ; item">&nbsp;</td>
          <td width="4%" align="right" class="dotline ; item">&nbsp;</td>
          <td width="10%" align="right" class="dotline ; item"><span id="totalWage"><%=format.format(grandTotalWage)%></span></td>
          <td width="8%" align="right" class="dotline ; item">&nbsp;</td>
          <td width="4%" align="right" class="dotline ; item">&nbsp;</td>
          <td width="10%" align="right" class="dotline ; item"><span id="totalGoods"><%=format.format(grandTotalGoods)%></span></td>
          <td width="10%" align="right" class="dotline ; item"><span id="grandTotal"><%=format.format(grandTotal)%></span></td>
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

<br style="font-size:5pt">
<%
     int attCnt = 0;
   	String tempWarrantyMsg = getWarrantyDesc(conn,InformTypeDDL);
   if (jobList.size()>0) {
%>
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">หมายเหตุ</td>
                <td class="item_tab3"></td>
                <td>&nbsp;</td>
              </tr>
            </table>

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
        <%
        line = 0;
		String jid =  "";
		String comment = "";
		String area = "";
	    
        for (int i=0;i<jobList.size();i++) {
                line++;
                jid =   doString.DisplayThai(doString.checkString((String) jobList.elementAt(i),"")); 
                comment = doString.checkString((String) jobComment.get(jid),"");             
				comment = doString.DisplayThai(comment.replace("("+tempWarrantyMsg+")",""));

                area = doString.checkString((String) jobArea.get(jid),"");                
                %>
				  <tr>
				    <td class="item ; dotline01" height="22" width="12%">รายการที่ <%=line%> :</td>
				    <td height="22" width="76%" class="dotline01"><input type="text" name="<%=jid%>_comment" class="box" style="width:100%" size="20" maxlength='200'  value="<%=comment%>"></td>
				    <td height="22" width="12%" class="dotline01"><%=genAreaList(conn,jid+"_area"+line,area," class='box2' style='width:100%' ",line)%></td>
				  </tr>
                <%
         } // end for
       // while (line<Constants.SERV_OPENJOB_LINE) {
        while (line<3) {
            line++;
		        %>
				  <tr>
				    <td class="item ; dotline01" height="22" width="12%">&nbsp;</td>
				    <td height="22" width="76%" class="dotline01">&nbsp;</td>
				    <td height="22" width="12%" class="dotline01">&nbsp;</td>
				  </tr>
				<%
		  } // end while
       %>
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
   } // end if check jobList
%>
<%-- ===================================  Attach File ================================================ --%>
<br style="font-size:5pt">

			            <table border="0" width="100%" cellspacing="0" cellpadding="0">
			              <tr>
			                <td class="item_tab1"><img src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
			                <td class="item_tab2" width="250px">รูปภาพงานก่อนซ่อม(ขนาดไม่เกิน 500 K)</td>
			                <td class="item_tab3"><input type="button"  value="กดปุ่ม Refresh" 
								onclick="refresh();" style="background-color:#eeeeee; "></td>
			                <td class="textgray">&nbsp; **คลิกปุ่ม Refresh สำหรับดูรูปภาพที่ไม่แสดงหลังจากแนบไฟล์ </td>
			              </tr>
			            </table>

			<table border="0" width="100%" cellspacing="0" cellpadding="0">
			  <tr>
			    <td width="5" valign="top"><img src="images/Corn01.gif" width="5" height="5"></td>
			    <td class="frmTop">&nbsp;</td>
			    <td width="5" valign="top" align="right"><img src="images/Corn02.gif" width="5" height="5"></td>
			  </tr>
			</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR" align="center">

			<input type="hidden" name="total_item" value="<%=jobList.size()%>">

			<table border="0" width="100%" cellspacing="0" cellpadding="0">
			 <%
			 
			    String yyyyMMdd =  GetDateKeyinYYYYMMDD(conn,iDocNo);
			    String []tmp = yyyyMMdd.split("\\-"); //2012-08-15
                String yyyy = tmp[0];
                String month = tmp[1];
                
			 
				line = 0;
				String keyFile = "";
				String itemId = "";
				String qareaId = "";
				String vendorId = "";
				
				//System.out.println("==========================================--------jobList :"+jobList.size());
				String bgColor = "";
				String imagesIdUrl = "";
				//pathUrlX += yyyy+"/"+month+"/"+iDocNo+"/";	
			    String pathUrlX = Utilizer.getPropValue("DOMAIN_NAME")+Utilizer.getPropValue("PATH_UPLOAD")+yyyy+"/"+month+"/"+iDocNo+"/";	
	    		String pathTmp = Utilizer.getPropValue("IP_HOST_UPLOAD")+Utilizer.getPropValue("PATH_UPLOAD")+yyyy+"/"+month+"/"+iDocNo+"/";
		
				for (int i=0;i<jobList.size();i++) {
						 line++;
						 bgColor = "#e8f2fe";
						 if(line%2==0){
						  bgColor= "#ffffff";
						 }										
	
						 key = (String) jobList.elementAt(i);               
                         itemId = doString.checkString((String) jobItm.get(key),"");
                         vendorId = doString.checkString((String) jobVendor.get(key),"");
                         qareaId = doString.checkString((String) jobArea.get(key),"");

                         keyFile   = iDocNo+"_"+key+"_"+vendorId+"_"+qareaId+"_"+line;
						 //System.out.println("keyFile = "+keyFile);
						 //System.out.println("======================== print file line ================================");
						//======================== print file line 1 ================================//
						%>
						  <tr bgcolor="<%=bgColor%>">
							<td class="item" height="22" width="5%"><nobr>รายการที่ <%=line%> : </nobr></td>	
							<td class="item" height="22" width="20%"><nobr>รูปภาพก่อนซ่อม1 : 
							<%
							imagesIdUrl = pathUrlX+keyFile+"_a.jpg";
							int resCode = getHttpResponseCode(pathTmp+keyFile+"_a.jpg");
							if(resCode==200) {
							     attCnt++;
							    //(docId,mm,yyyy,imgId)
								%>
									<a href="<%=imagesIdUrl%>" target="_blank"><img src="<%=imagesIdUrl%>" width="25" height="20" border="0"></a> &nbsp; &nbsp; 
									<input type="button" class="box" value="Delete" onclick="delFile('<%=iDocNo%>','<%=month %>','<%=yyyy %>','<%=keyFile+"_a.jpg"%>');" style="background-color:#eeeeee">								
								<%								
							}else{
								out.println("ไม่มีรูปภาพ");
							}
							 %>
							</nobr></td>
							<td class="item" height="22" width="20%"><nobr>รูปภาพก่อนซ่อม2 : 
							<%
							imagesIdUrl = pathUrlX+keyFile+"_b.jpg";
							resCode = getHttpResponseCode(pathTmp+keyFile+"_b.jpg");
							if(resCode==200) {
								attCnt++;
								%>
									<a href="<%=imagesIdUrl%>" target="_blank"><img src="<%=imagesIdUrl%>" width="25" height="20" border="0"></a> &nbsp; &nbsp; 
									<input type="button" class="box" value="Delete" onclick="delFile('<%=iDocNo%>','<%=month %>','<%=yyyy %>','<%=keyFile+"_b.jpg"%>');" style="background-color:#eeeeee">								
								<%								
							}else{
								out.println("ไม่มีรูปภาพ");
							}
							 %>							
							</nobr></td>
							<td class="item" height="22" width="10%">
							<nobr>
								<a href="#"><input type="button" class="box" value="แนบไฟล์ <%=line%>" 
								onclick="attachFiles('<%=uploadId%>','<%=iDocNo %>','<%=key %>','<%=itemId%>','<%=vendorId %>','<%=qareaId%>','<%=line%>','<%=month %>','<%=yyyy %>');" style="background-color:#eeeeee; "></a> &nbsp;
							</nobr>
							</td>
						  </tr>					
						<%
						//System.out.println("###################################################");	
				 } // end for
				%>
			</table>
	</td>
	</tr>
	</table>

			<table border="0" width="100%" cellspacing="0" cellpadding="0">
			  <tr>
			    <td width="5" valign="bottom"><img src="images/Corn03.gif" width="5" height="5"></td>
			    <td class="frmBottom">&nbsp;</td>
			    <td width="5" valign="bottom" align="right"><img src="images/Corn04.gif" width="5" height="5"></td>
			  </tr>
			</table>
<%-- ===================================  Attach File ================================================ --%>


<%if(isTurnKey){ %>

<%-- ===================================  Comment of Request ================================================ --%>
	<br style="font-size:5pt">
	 <table border="0" width="100%" cellspacing="0" cellpadding="0">
	              <tr>
	                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
	                <td class="item_tab2" width="200">หมายเหตุผู้อนุมัติ</td>
	                <td class="item_tab3"></td>
	                <td>&nbsp;</td>
	              </tr>
	            </table>
	
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
						    <td class="item ; dotline01" height="22" width="12%">รายละเอียด : &nbsp;</td>
						    <td height="22" width="76%" class="dotline01"><%=tempComment[1]%>
						    <input name="i_remark" type="hidden" value="<%=tempComment[1]%>" >
						    </td>
						    <td height="22" width="12%" class="dotline01">&nbsp;</td>
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
	<%-- ===================================  Comment of I_remark ================================================ --%>
	
	<%-- ===================================  Comment of Request ================================================ --%>
	<br style="font-size:5pt">
	 <table border="0" width="100%" cellspacing="0" cellpadding="0">
	              <tr>
	                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
	                <td class="item_tab2" width="200">หมายเหตุ(ผู้ขออนุมัติ)</td>
	                <td class="item_tab3"></td>
	                <td>&nbsp;</td>
	              </tr>
	            </table>
	
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
						    <td class="item ; dotline01" height="22" width="12%">รายละเอียด : &nbsp;</td>
						    <td height="22" width="76%" class="dotline01">
						        <textarea name="i_remarkDesc" class="box" style="width:500px;height:60px" maxlength="255"><%=tempComment[0]%></textarea>
						    </td>
						    <td height="22" width="12%" class="dotline01">&nbsp;</td>
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
	<%-- ===================================  Comment of Request ================================================ --%>
<%} %>


<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="300" class="act_tab2">
           <% if(isTurnKey){ %>
			<a href="#"><img src="images/act_SaveAndSend.gif" width="70" height="27" border="0"     
                  	style="cursor:hand;FILTER: alpha(opacity=70)"  onClick="submitJobTurnKey();"    
                  	onMouseOver=nereidFade(this,100,50,5)                                
    			onMouseOut=nereidFade(this,70,50,5)></a>&nbsp;
           <%}else{ %>
	            <a href="#"><img border="0" src="images/act_submit.gif"  onclick="submitJob();"                                
	    			onmouseout=nereidFade(this,70,50,5)    
	                  	onmouseover=nereidFade(this,100,50,5)     
	                  	style="cursor:hand;FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp;
             <%} %>  
                	
            <a href="#"><img border="0" src="images/act_add.gif"  onclick="addJobList();"
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="cursor:hand;FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp;
            <a href="#"><img border="0" src="images/act_delete.gif"  onclick="deleteJob();"
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="cursor:hand;FILTER: alpha(opacity=70)" width="70" height="27"></a>
            <a href="#"><img border="0" src="images/act_cancel.gif"  onclick="cancelDoc();"
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="cursor:hand;FILTER: alpha(opacity=70)" width="70" height="27"></a>
            </td>     
            <%-- cancelDoc(); --%>    
            <td class="act_tab3"></td>   
            <td class="act_tab4">
            <% if(!"".equals(from_page)){ %>
            <a href="javascript:goBack();"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>
            <% }else{ %>
            <a href="<%=Constants.APP_PATH%>/SERV_OpenJob_List.jsp"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>
            <% } %>
            &nbsp;
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


<!-- Click Save and Send -->
<%-- ========================= Click Save and Send =========================================---%>   
<div id="saveAppBox" style="display:block ; visibility:hidden ; z-index:1 ; position:relative ; left:50% ; top:-1000px ; margin-left:-250px ; margin-top:0px ; 
background-color:#FFFFFF ; border:5px solid rgb(200,200,200) ; padding:20px ; 
text-align:center ; width:500px">

            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">ยืนยัน Save & Send to Approve</td>
                <td class="item_tab3"></td>
                <td>&nbsp;</td>                
              </tr>
            </table>
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
    <td height="22" colspan="2" class="item ; dotline01">ท่านต้องการส่งรายละเอียดให้ผู้อนุมัติหรือไม่ ?
    &nbsp;&nbsp;<img src="images/icon_TurnKey.gif" width="50" height="25" border="0" align="absmiddle">
    </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22">ผู้อนุมัติ :</td>
    <td height="22" class="dotline01"><%=doString.DisplayThai(tempApprove[2] )%></td>
    </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">email :</td>
    <td height="22" width="39%" class="dotline01"><%=tempApprove[1] %></td>
    </tr>
  <tr>
    <td class="dotline01" height="22" width="13%" colspan="2" style="color:#FF0000" align="center">
    <img src="images/i_alert.gif" width="20" height="20" hspace="5" border="0" align="absmiddle">คำเตือน : ถ้าทำการส่งอนุมัติแล้ว จะไม่สามารถแก้ไขรายการได้อีก</td>
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
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="160" class="act_tab2">&nbsp;
                  	     <a href="#"><img src="images/act_Yes.gif" width="70" height="27" border="0"     
                  		style="FILTER: alpha(opacity=70);cursor:hand" onClick="doAppBox(true);"    
                  		onMouseOver=nereidFade(this,100,50,5)                                  
    					onMouseOut=nereidFade(this,70,50,5)></a>&nbsp;
                        <a href="#"><img src="images/act_No.gif" width="70" height="27" border="0"     
                  		style="FILTER: alpha(opacity=70);cursor:hand" onClick="doAppBox(false);"    
                  		onMouseOver=nereidFade(this,100,50,5)  
    					onMouseOut=nereidFade(this,70,50,5)></a>
</td>   
            <td class="act_tab3">&nbsp;</td>   
            <td class="act_tab4">
            <a href="#">
            <img src="images/bu_close.gif" width="50" height="15" border="0" align="absmiddle" onClick="MM_showLayersAppBox(false);" style="cursor:hand"></a></td>
            
          </tr>  
        </table>
</div>
<!-- Click Save and Send End -->
<%-- ========================= Click Save and Send End =========================================---%>   
	

<!-- Click Cancel 
i_can_type
i_can_desc-->
<%-- ========================= Click Cancel =========================================---%>   
<div id="canBox" style="display:block ; visibility:hidden ; z-index:1 ; position:relative ; left:50% ; top:-1000px ; margin-left:-250px ; margin-top:0px ; 
background-color:#dcf0ff; border:5px solid rgb(200,200,200)  ; padding:20px ; 
text-align:center ;
width:500px">

            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">ยกเลิกการแจ้งซ่อม</td>
                <td class="item_tab3"></td>
                <td>&nbsp;</td>                
              </tr>
            </table>
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
    <td class="item ; dotline01" height="22">สาเหตุการยกเลิก :</td>
    <td height="22" class="dotline01">
    	<%=GenCauseHtmlDDL(conn,"iCanTypeDDL",""," class='box2' style='width:100%; display:block ; visibility:hidden;'  ")%>

    </td>
    </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%" valign="top">รายละเอียด :</td>
    <td height="22" width="39%" class="dotline01" valign="top">
    <textarea name="iCanDesc" id="i_canDesc" rows="5" class="box" style="width:100%"></textarea>
    </td>
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
<%--  onClick="MM_showHideLayers('alert2','','hide')"    --%>
<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="80" class="act_tab2">&nbsp;
   	        <a href="#"><img src="images/act_ok.gif" width="70" height="27" border="0"     
                  		style="FILTER: alpha(opacity=70);cursor:hand" onClick="doCancelBox(true);"    
                  		onMouseOver=nereidFade(this,100,50,5)                                  
    					onMouseOut=nereidFade(this,70,50,5)></a>
    		</td>   
            <td class="act_tab3">&nbsp;</td>   
            <td class="act_tab4"><a href="#"><img src="images/bu_close.gif" width="50" height="15" border="0" align="absmiddle" onClick="doCancelBox(false);" style="cursor:hand"></a></td>
            
          </tr>  
        </table>
</div>
<%-- ========================= Click Cancel End =========================================---%>   

<input type="hidden" id="attCnt" name="attCnt" value="<%=attCnt%>">
</FORM>	
</BODY>
</HTML>
<%
       System.out.println("--- SERV_OpenJob.jsp:succes --- " );
	} catch (Exception e) {
		System.out.println("!! ERROR SERV_OpenJob.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (stmt != null) stmt.close();
			
			if (rs2 != null) rs2.close();
			if (stmt2 != null) stmt2.close();
			
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>