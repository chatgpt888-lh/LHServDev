<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="serv.common.Constants" %>
<%@page import="serv.common.User" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%--
* Modify by :pradoem 
 * date: 2014.11.03
 * desc : Add field d_appoint_cust  for Key in manual  inform job
 **----------------------------------------------------
 * Last Update 2015.06.25 by pradoem
 * 1. Support แจ้งซ่อม condo แสดงการประกัน (warranty) โครงการที่เป็น condo
 * 2. เพิ่มประเภทใบแจ้งซ่อม  : เก็บประกันงานโอน/ซ่อมทั่วไปเป็นต้น  type : serv_xstd = 98 
 */ --%>
<%!
public static String Get2Digit(String temp){
    String newSp_id;
    switch(temp.length()){ 
       case 1: newSp_id="0"+temp; break;
       default:newSp_id=temp;
    }
    return newSp_id;
}	

public static  String toDDMMYY_THAI2(String str){
	if ((str == null) || str.equals("")) {
		return  str;
	}else{
		str = str.substring(0,10);
		String d2[] = str.split("\\-"); //2013-03-29
		return d2[2]+"/"+d2[1]+"/"+(Integer.parseInt(d2[0])+543);
	}
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

     public String getTimeDDL(String value){
        StringBuffer html = new StringBuffer();
        //00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,
        String tempTime = "08:00,08:30"+
        				",09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30"+
        				",19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30";
        				
        String[] arrTime = tempTime.split("\\,");
       // ArrayList<String> arrList = new ArrayList<String>(); 				
        try {
         		String selected = "";
         		String val = "";
         		//html.append("<select name='").append(name).append("' ").append(params).append(" >");
         		
         		if("".equals(value)||"00:00".equals(value)){
         			value = "08:30";
         		}       		
         		for (int i = 0; i < arrTime.length;i++) {
					//System.out.println(list.get(i));
					selected = "";
					val = arrTime[i];
					if(value != null && val.equalsIgnoreCase(value)){
				     	selected = " selected='selected' ";
				    }
					html.append("<option value='"+val+"' "+selected+"> " + val + "</option>");
				}
				//html.append("</select>");
        }catch(Exception e) {
            System.out.println("--->  getTimeDDL Error : " + e.getMessage());
        } finally{
            try  {
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }	 
	
   /** For DDL เก็บประกันงานซ่อม 2015.06.25 **/ 
     public String GenInformTypeHtmlDDL(Connection conn,String name, String value, String params){
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try {
            stmt = conn.createStatement();
            sql.append(" select i_type,i_code,n_desc  from lan:serv_xstd where i_type='98' ").append(" order by i_type,i_code,n_desc  ");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(name).append("' ").append(params).append(" >");
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
            System.out.println("  GenInformTypeHtmlDDL Error : " + e.getMessage());
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
	 
	 
	    
	public HashMap FetchesHashSvcCustomer(Connection conn, String comId, String projId, String lockNo,
			String houseNo) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial parameter
        	HashMap  obj  = null; 
        	boolean isAvailable = false;
        	//System.out.println("FetchesHashSvcCustomer ->Starting.");        	 
			/******************************************************/			
        	//*****Find project by user login  
			sql.delete(0,sql.length());
			sql.append(" select c_fname,c_lname,c_tel from lan:svc_customer ")
				  .append(" Where 1 = 1  ")
				  .append(" and I_COMPANY = '"+comId+"' ")
				  .append(" and I_PROJECT = '"+projId+"'   ");  
			
			if((!"".equals(houseNo) && !"".equals(lockNo)) ||  ("".equals(houseNo) && "".equals(lockNo))){
				sql.append(" and I_HOUSE ='").append(houseNo).append("' ");
				sql.append(" and I_LOCK ='").append(lockNo).append("' ");	
			}else if(!"".equals(houseNo)){
				sql.append(" and I_HOUSE ='").append(houseNo).append("' ");
			}else if(!"".equals(lockNo)){
				sql.append(" and I_LOCK ='").append(lockNo).append("' ");	
			}

			//System.out.println("-->Get Customer SQL :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString()); 
			rs = pstmt.executeQuery();	
			if(rs.next()){
				isAvailable = true;
				obj =  new HashMap();
				obj.put("xFname",doString.checkString(rs.getString("c_fname"), ""));	
				obj.put("xLname",doString.checkString(rs.getString("c_lname"), ""));	
				obj.put("xTel",doString.checkString(rs.getString("c_tel"), ""));	
			}
			rs.close();	
			//********************************************************/		
			//System.out.println("FetchesHashSvcCustomer ->successfully. ");				  	 
		  	return obj;			  	 
		}catch(Exception e){
			System.out.println("!!!FetchesHashSvcCustomer , "  + e.getMessage());
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
%>
<%

/*System.out.println("*******************************************");
String ParameterNames = "";
for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
	ParameterNames = (String)e.nextElement();
	System.out.println(ParameterNames + " = "+request.getParameter(ParameterNames));
}

System.out.println("******************xxxxxxxxxx*************************");
*/
//java.util.Calendar currentCal = java.util.Calendar.getInstance();  
//java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyy-MM-dd", Locale.US);
Calendar rightNow = Calendar.getInstance();
int curday = rightNow.get(Calendar.DAY_OF_MONTH);
String month = Integer.toString(rightNow.get(Calendar.MONTH)+1);
String year = Integer.toString(rightNow.get(Calendar.YEAR));
String today = Get2Digit(curday+"")+"/"+Get2Digit(month)+"/"+(Integer.parseInt(year)+543);
//System.out.println("-->"+today);
//---------------------------------
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_InfJob.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   doString str = new doString();

   String toDate = getDateFromCalendar(Calendar.getInstance())+"&nbsp;"+getTimeFromCalendar(Calendar.getInstance());
   String mode = doString.checkString(request.getParameter("mode"),"add");
   String load = doString.checkString(request.getParameter("load"),"");
   String iDocNo = doString.checkString(request.getParameter("i_docno"),"");
   String searchCust = doString.checkString(request.getParameter("search_cust"),"");   
   String foundCust = "";

   //----============ Declare Variables for input data ===========----//
   String selProj = doString.checkString(request.getParameter("sel_project"),"");
   if  (selProj.length()==0) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       session.setAttribute("sess_sel_proj",selProj);
   }

   String houseId = doString.checkString(request.getParameter("house_id"),"");
   String iLock = doString.checkString(request.getParameter("i_lock"),"").toUpperCase();
   String nCustomer = doString.DisplayThai(doString.checkString(request.getParameter("n_customer"),""));
   String nCustTel = doString.checkString(request.getParameter("n_cust_tel"),"");
   String cDesc = doString.checkString(request.getParameter("c_desc"),"");
   cDesc = str.replace(cDesc,"|break|","\r\n");

   String iSystem = doString.checkString(request.getParameter("iSystem"),"");
   String dAppoint = doString.checkString(request.getParameter("dAppoint"),"");
   String InformTypeDDL = doString.checkString(request.getParameter("InformTypeDDL"),"");
   
   if("".equals(dAppoint)){
       dAppoint = today;
   }
   //-----========= Declare Variables for Search Custoemr ===========----//
   String housePlan = "-";
   String custName = "-";
   String custTel = "-";
   String guranteeDesc = "-";
   String guranteeDate = "-";
   String iCustomer = "";
   String guranteeOk = "";
   Calendar gurantee = null;
   String projName = "-";
   String fromTime = "";
   
			       
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	SERV_CommonData common = null;

	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();     
		common = new SERV_CommonData(conn);   
        //----=======================================----//   
        //System.out.println("11111111111 :"+selProj);
        /** Last Update 2015.06.24 For Repair Condo ***/
        String condoProfileArr[] = new String[] {"NO","","","","","",""};
        String tempArr[] = null;
        if(selProj.length()>0 && !selProj.equals("ALL")){
           tempArr  = selProj.split("\\:");
           condoProfileArr = GetCondoProfile(conn,tempArr[0],tempArr[1]);
        }
     	//System.out.println("222222222222");
        //-------------------------------------------------------
        if (iDocNo.length()>0 && mode.equalsIgnoreCase("EDIT")) {
           
            sql.delete(0,sql.length());
            sql.append(" select *,to_char(d_appoint_cust,'%H:%M') as time from lan:serv_dochd where i_docno='").append(iDocNo).append("' ");
			servlog.startLog(sql.toString());
            rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
            if (rs.next()) {
                selProj = doString.checkString(rs.getString("i_company"),"");
                selProj += ":"+doString.checkString(rs.getString("i_project"),"");
			    houseId = "";
			    iLock = doString.checkString(rs.getString("i_lock"),"").toUpperCase();
			    
			    if (load.equalsIgnoreCase("YES")) {
			        //------ Load in first time only ---------//
				    nCustomer = doString.checkString(doString.DisplayThai(rs.getString("n_customer")),"");
				    nCustTel = doString.checkString(doString.DisplayThai(rs.getString("n_cus_tel")),"");
				    cDesc = doString.checkString(doString.DisplayThai(rs.getString("c_desc")),"");
				    cDesc = str.replace(cDesc,"|break|","\n");
			    }
			    //***modify by pradoem 2014.11.03
			    dAppoint = toDDMMYY_THAI2(doString.checkString(rs.getString("d_appoint_cust"),""));
			    iSystem  = doString.checkString(rs.getString("i_system"),"");
			    
			    //2019.12.02
			    fromTime  = doString.checkString(rs.getString("time"),"");

			    /* modify 2015.06.25 pradoem */
			    InformTypeDDL = doString.checkString(doString.DisplayThai(rs.getString("i_warranty")),"");
            }
            rs.close();
            
			String com = selProj.length()>=6 ? selProj.substring(0,2) : "";
			String proj = selProj.length()>=6 ? selProj.substring(3,6) : "";
            sql.delete(0,sql.length());
            sql.append(" select * from lan:acxprojt where i_company='"+com+"'  and i_project='"+proj+"' ");
			servlog.startLog(sql.toString());
            rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
            if (rs.next()) {
               projName = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
            }
            rs.close();            
            
            //Modify by pradoem 2015.06.25  replace warranty desc
            String tempWarrantyMsg = getWarrantyDesc(conn,InformTypeDDL);
            //System.out.println(" TEST :"+tempWarrantyMsg);
            //cDesc = str.replace(cDesc,"("+tempWarrantyMsg+")","");
            cDesc = cDesc.replace("("+doString.DisplayThai(tempWarrantyMsg)+")","");
             
            // System.out.println(" cDesc :"+cDesc);
            searchCust = "YES";
        }
//		System.out.println("33333333333333");
	   if (searchCust.equalsIgnoreCase("YES")) {
			//----======================= Get Customer Details ===========================----//	  
			String iCompany = "";
			String iProject = "";
			if (selProj.indexOf(":")>0) {
			   iCompany = selProj.substring(0,selProj.indexOf(":"));
			   iProject = selProj.substring(selProj.indexOf(":")+1);
			}
			 
			Hashtable tmpCust = common.getCustomerDetails(iCompany,iProject,iLock,houseId);
		    housePlan = doString.checkString((String) tmpCust.get("i_model"),"");
		    houseId = doString.checkString((String) tmpCust.get("i_house"),houseId);
		    iLock = doString.checkString((String) tmpCust.get("i_lock"),iLock);
		    iCustomer = doString.checkString((String) tmpCust.get("i_customer"),"");
			guranteeDesc = doString.DisplayThai(doString.checkString((String) tmpCust.get("gurantee_desc"),"-"));
			guranteeDate = doString.checkString((String) tmpCust.get("gurantee_date"),"-");
			custName = doString.DisplayThai(doString.checkString((String) tmpCust.get("n_customer"),""));
			custTel = doString.checkString((String) tmpCust.get("n_cust_tel"),"");	
			guranteeOk = doString.checkString((String) tmpCust.get("gurantee_ok"),"");	
			foundCust = doString.checkString((String) tmpCust.get("found_cust"),"");	

	   } // end if search customer
	   
	   //System.out.println("44444444444444444");
	   //Edit by pradoem 2019.05.13
	   String comId = "";
	   String projId = "";
	  if(selProj.indexOf(":")>0) {
	   		comId = selProj.substring(0,selProj.indexOf(":"));
			projId = selProj.substring(selProj.indexOf(":")+1);
	   }
	   boolean isEditCustomer = false;
	   HashMap hashData = FetchesHashSvcCustomer(conn,comId,projId,iLock,houseId);
	   if(hashData!= null){
	   		isEditCustomer = true;
	   		/*custName = doString.DisplayThai(hashData.get("xFname")+" "+hashData.get("xLname"));
	   		custTel = doString.DisplayThai(hashData.get("xTel").toString());  
	   		
	   		nCustomer = custName;
	   		nCustTel = custTel; */		
	   }
	
%>

<HTML>
<HEAD>
<TITLE>Add Inform Job</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>



<script src="jquery3/jquery.min3.6.3.js" ></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
<script src="jquery3/loadingoverlay.min2.1.7.js"></script>

<script language="javascript">
<!--
 function validDate(fdate) {
	     var sdate = fdate.value.split("/")[0];
	     var smonth =fdate.value.split("/")[1];
	     var syear = parseInt(fdate.value.split("/")[2])-543;
	     
	    //alert(sdate+","+smonth+","+syear);
	     var d = new Date();
	     var edate = d.getDate();
	     var emonth= d.getMonth() + 1;
	     var eyear = d.getFullYear();
	     	     
	     //alert(edate+","+emonth+","+eyear);
	     //---- Check select date ---//
	     if (sdate.length==0 && smonth.length==0 && syear.length==0 &&
	         edate.length==0 && emonth.length==0 && eyear.length==0) {
	         alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
	         document.forms[0].dAppoint.focus();
	         return false;
	        // return true;
	     }
	     var startDate = new Date(parseInt(syear,10),parseInt(smonth,10)-1,parseInt(sdate,10));
	     var endDate = new Date(parseInt(eyear,10),parseInt(emonth,10)-1,parseInt(edate,10));
	     if (startDate.getMonth()!=(parseInt(smonth,10)-1)) {
	        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
	        document.forms[0].dAppoint.focus();
	        return false;
	     }
	     if (endDate.getMonth()!=(parseInt(emonth,10)-1)) {
	        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
	        document.forms[0].dAppoint.focus();
	        return false;
	     }
	    
		if (endDate>startDate) {
		    alert(" วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง ! ");
		    return false;
		}
	     return true;
	 }	
	 
  function searchCust() {
      var forms = document.forms[0];
      if (forms.house_id.value=="" && forms.i_lock.value=="") {
         alert(" กรุณากรอก บ้านเลขที่ หรือ แปลง อย่างน้อย  1 ตัว !");
      } else {
         forms.search_cust.value="YES";
         forms.action="<%=Constants.APP_PATH%>/SERV_InfJob.jsp";
         forms.submit();
      }
  }
  
  function validateCustData() {
     var forms = document.forms[0];

      if (forms.house_id.value=="") {
         alert(" กรุณากรอกบ้านเลขที่ !");
         forms.house_id.focus();
         return false;
      }

      if (forms.i_lock.value=="") {
         alert(" กรุณากรอกเลขที่แปลง !");
         forms.i_lock.focus();
         return false;
      }

      if (forms.found_cust.value.toUpperCase()!="YES") {
         alert(" กรุณาทำการดึงข้อมูลลูกค้าที่ต้องการ เพื่อทำการตรวจสอบก่อน !");
         return false;
      }
	      //Modify by pradoem : 2014.11.03
	      <%
	      if("".equals(iSystem)){
	      %>
		      if (forms.dAppoint.value=="") {
		         alert(" กรุณาระบุวันที่นัดหมายด้วย!");
		         forms.dAppoint.focus();
		         return false;
		      }
		      if(!validDate(forms.dAppoint)){	
		      	return false;
		      }
	      <%}%>
	  return true;
  }
  
  function saveInform() {
     if (!validateCustData())  {
	     return false;
	 }
	
	if($('select[name="InformTypeDDL"] option:selected').val()==''){
		alert(" กรุณาเลือกประเภทใบแจ้งซ่อม !");
		$('select[name="InformTypeDDL"]').focus();
		return false;
	}
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_InfJobServlet";
     document.forms[0].submit();
  }  
  
  function resetSearch() {
      document.forms[0].search_cust.value="";
      document.forms[0].found_cust.value="";
  }
  
  function openNewJob() {
     if (!validateCustData())  {
	     return false;
	 }

     var forms = document.forms[0];
     forms.action="<%=Constants.APP_PATH%>/SERV_OpenJob.jsp";
     forms.submit();    
  }
 
  $(document).ready(function() {
 
    $('#sel_project').select2({
         matcher: function(params, data) {
            if ($.trim(params.term) === '') {
                return data;
            }

            var searchTerm = params.term.trim().toLowerCase().replace(/-/g, '');
            var optionText = (data.text || '').toLowerCase().replace(/-/g, '');

            if (optionText.indexOf(searchTerm) > -1) {
                return data;
            }

            return null; 
        }
    });
    
});
//-->
</script>

<style type="text/css">

.select2-selection__rendered {
  	font-family: Tohama, Arial, sans-serif;
    font-size: 10.1pt;
    color: #165396 !important;
}


.select2-results__option {
	font-family: Tohama, Arial, sans-serif;
    font-size: 10.1pt;
    color: #165396;
}    
    
</style>

<script type="text/javascript">
var ggWinCal ;
function doSelChqDate(dateType,iHouse,dCloseLaw) {
	  var vWinCal = window.open('<%=request.getContextPath()%>/SERV_InfJobCalendar.jsp?dateType='+dateType,'blank','width=300,height=265,left=200,top=100');
	  vWinCal.opener = self;
	  ggWinCal = vWinCal;
}
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM method="POST" action="" name="frmInfJob">

<input type="hidden" name="mode" value="<%=mode%>">
<input type="hidden" name="search_cust" value="">
<input type="hidden" name="found_cust" value="<%=foundCust%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            Inform Job</td>
          <td width="50%" align="right">
          <!-- remark by pradoem 2023.02.09 
          <a href="#" onclick="openNewJob();"><img border="0" src="images/icon_open_Jop.gif" width="120" height="34"></a>
          -->
          </td>
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

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR" align="center">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
<%
   if (mode.equalsIgnoreCase("ADD")) {
		%>
		  <tr>
		    <td class="item ; dotline01" height="22" width="13%">โครงการ :</td>
		    <td height="22" width="39%" class="dotline01"> 
		    <%=common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:250px' onchange='resetSearch();' ")%>
		    </td>
		    <td height="22" class="item ; dotline01" width="14%">เลขที่ใบแจ้งซ่อม :</td>
		    <td height="22" width="34%" class="dotline01"><span style="width:100px">Auto Generated</span></td>
		  </tr>
		  <tr>
		    <td class="item ; dotline01" height="22" width="13%">บ้านเลขที่ :</td>
		    <td height="22" width="39%" class="dotline01">
		    <input type="text" name="house_id" class="box" style="width:100px" value="<%=houseId%>" onchange='resetSearch();'></td>
		    <td height="22" class="item ; dotline01" width="14%">แปลง :</td>
		    <td height="22" width="34%" class="dotline01"> 
		    <input type="text" name="i_lock" class="box" style="width:100px" value="<%=iLock%>" onchange='resetSearch();'>&nbsp;&nbsp;
		      <a href='#' onclick='searchCust();'><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a> </td>
		  </tr>
		  <%
  } else {
		%>
		  <tr>
		    <td class="item ; dotline01" height="22" width="13%">โครงการ :</td>
		    <td height="22" width="39%" class="dotline01">
		    <%=projName%>
		    <input type="hidden" name="sel_project" value="<%=selProj%>">
		    </td>
		    <td height="22" class="item ; dotline01" width="14%">เลขที่ใบแจ้งซ่อม :</td>
		    <td height="22" width="34%" class="dotline01">
		    <span style="width:100px"><%=iDocNo%></span>
		    <input type="hidden" name="i_docno" value="<%=iDocNo%>">
		    </td>
		  </tr>
		  <tr>
		    <td class="item ; dotline01" height="22" width="13%">บ้านเลขที่ :</td>
		    <td height="22" width="39%" class="dotline01">
		    <%=houseId%>
		    <input type="hidden" name="house_id" value="<%=houseId%>">
		    </td>
		    <td height="22" class="item ; dotline01" width="14%">แปลง :</td>
		    <td height="22" width="34%" class="dotline01"> 
		    <%=iLock%>
		    <input type="hidden" name="i_lock" value="<%=iLock%>">
            </td>
		  </tr>
		  <%  
  } // end if mode
  %>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">แบบบ้าน :</td>
    <td height="22" width="39%" class="dotline01"><%=doString.checkString(housePlan,"-")%></td>
    <td height="22" class="item ; dotline01" width="14%">จากช่องทาง :</td>
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
    <td class="item ; dotline01" height="22" width="13%">ชื่อลูกค้า
      :</td>
    <td height="22" width="39%" class="dotline01"><%=doString.checkString(custName,"-")%>
    <%
    if(isEditCustomer){
    	out.println("<font size='2' color='#FF0000'>*edit</font>");
    }
     %>
    </td>
    <td height="22" class="item ; dotline01" width="14%">โทรศัพท์ติดต่อ
      :</td>
    <td height="22" width="34%" class="dotline01"><%=doString.checkString(doString.DisplayThai(custTel),"-")%>
    <%
    if(isEditCustomer){
    	out.println("<font size='2' color='#FF0000'>*edit</font>");
    }
     %>
    </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">การประกัน
      :</td>
    <td height="22" width="39%" class="dotline01">
    <%
    //=guranteeDesc
    if(condoProfileArr[0].equals("YES")){ //CASE : is Condo
    	out.println(condoProfileArr[5]);
    }else{ // CASE : Not Condo
    	out.println(guranteeDesc);
    }
    %></td>
    <td height="22" class="item ; dotline01" width="14%">วันที่หมดประกัน
      :</td>
    <td height="22" width="34%" class="dotline01">
    <%//=doString.checkString(guranteeDate,"-")
    if(condoProfileArr[0].equals("YES")){ //CASE : is Condo
    	out.println(condoProfileArr[3]);
    }else{ // CASE : Not Condo
    	out.println(guranteeDate);
    }
    
    %></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ผู้รับเรื่อง
      :</td>
    <td height="22" width="39%" class="dotline01"><%=doString.checkString(doString.DisplayThai(user.getEmpName()),"-")%></td>
    <td height="22" class="item ; dotline01" width="14%">วันเวลาที่แจ้ง
      :</td>
    <td height="22" width="34%" class="dotline01"><%=doString.checkString(toDate,"-")%></td>
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
                <td class="item_tab2" width="200">รายละเอียดผู้แจ้งซ่อม</td>
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
    <td class="item ; dotline01" height="22" width="13%">ชื่อผู้แจ้ง
      :</td>
    <td height="22" width="39%" class="dotline01">
    <input type="text" name="n_customer" class="box" style="width:300px" value="<%=nCustomer%>" size='50' maxlength='50'></td>
    <td height="22" class="item ; dotline01" width="14%">โทรศัพท์ติดต่อ
      :</td>
    <td height="22" width="34%" class="dotline01">
    <input type="text" name="n_cust_tel" class="box" style="width:200px" value="<%=nCustTel%>" size='20' maxlength='20'></td>
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
                <td class="item_tab2" width="200">กรุณาระบุรายละเอียดงานซ่อม</td>
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
    <td width="100%" class="frmLRpad01"  >&nbsp;</td>
    <td >&nbsp;</td>
  </tr>
 
 	  <tr>
	    <td width="100%" class="frmLRpad01">
	 	    <font style="color:rgb(255,100,0)">ประเภทใบแจ้งซ่อม : </font>
	 	     <%=GenInformTypeHtmlDDL(conn,"InformTypeDDL",InformTypeDDL," class='box' style='width:150' ")%>
	    </td>
	  </tr>
	   <tr>
	    <td width="100%" class="frmLRpad01">&nbsp;</td>
	  </tr>

 <% if("".equals(iSystem)){ %>
	  <tr>
	    <td width="100%" class="frmLRpad01">
	    <span id="calImg1">
	 	    <font style="color:rgb(255,100,0)"> วันนัดหมาย : </font>
	 	    <input type="text" name="dAppoint" class="box" style="width:80px" value="<%=dAppoint %>" size='10' maxlength='8' readonly="readonly" >
	 	     
		     <A HREF="javascript:doSelChqDate('dAppoint')">
		     <IMG border="0" src="images/i_calendar.gif" align="absmiddle" width="18" height="18">
		     </A>
		     
		     
		 <font color="#ff6400">&nbsp;&nbsp;&nbsp;&nbsp; เวลา :</font>
		<select name="fromTime" id="fromTime" class="box" style="width:70px" >
			<%=getTimeDDL(fromTime) %>
		</select>
     	<font color="#ff6400"> น.</font>
		     
	      </span>
	 	    
	    </td>
	  </tr>
	   <tr>
	    <td width="100%" class="frmLRpad01">&nbsp;</td>
	  </tr>
  <%} %>
  
  <tr>
    <td width="100%" class="frmLRpad01">
 	    <textarea name="c_desc" class="box" style="width:960px;height:200px" maxlength="1500"><%=cDesc%></textarea>
    </td>
  </tr>
  
  <br>
  <%
  
  String sql1="select b.img_path from lan:eser_dochd a,lan:eser_docdt b where a.i_eser_docno = b.i_eser_docno and a.i_docno = '"+iDocNo+"' ";
  rs = stmt.executeQuery(sql1);  
  String tempImg = ""; 
  String urlImg = "";
  String pathImg = "http://lineapp.lh.co.th/line-bot"; 		
  int xLoop =1;		   
  while(rs.next()){
     	 tempImg = doString.checkString(rs.getString("img_path"),"");
   		 if( !"".equals(tempImg) && tempImg.indexOf(".")!=-1 ){
    		//System.out.println(dd.substring(1,dd.length()));   
    		//tempImg = arrList.get(5).toString();   
    		urlImg = pathImg+tempImg.substring(1,tempImg.length());	
    		//System.out.println("----img path :"+urlImg);
   %>
     <tr>
     <td width="100%" class="frmLRpad01"><%=xLoop %>&nbsp;&nbsp;รูปภาพงานซ่อม : <a href="<%=urlImg%>" target="_blank"><img src="<%=urlImg%>" width="25" height="20" border="0"></a></td>
    </tr>
   <% 
      }
      xLoop++;
  }
  rs.close();
   %>
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
            <td width="75" class="act_tab2">

            <a href="#" onclick="saveInform();"><img border="0" src="images/act_submit.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>

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

<%
  if (guranteeOk.length()>0 && !guranteeOk.equalsIgnoreCase("YES")) {
     %>
     <script>
           alert("..แปลงที่ระบุยังไม่โอน ไม่สามารถทำรายการได้..");
           document.forms[0].found_cust.value='';
     </script>
     <%
  }

  if (foundCust.trim().length()>0 && (custName.trim().length()<=0 || custName.equals("-"))) {
     %>
     <script>
           alert("ข้อมูลมีปัญหา ไม่พบชื่อลูกค้า , กรุณาตรวจสอบข้อมูลใหม่อีกครั้ง !!");
           document.forms[0].found_cust.value='';
     </script>
     <%
  }  

  if (searchCust.equalsIgnoreCase("YES") && foundCust.trim().length()==0) {
     %>
     <script>
           alert("ไม่พบข้อมูล [บ้านเลขที่ / แปลง] ที่ค้นหา , กรุณาตรวจสอบข้อมูลใหม่อีกครั้ง !!");
           document.forms[0].found_cust.value='';
     </script>
     <%
  }  
%>
	
</BODY>

</HTML>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_InfJob.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (stmt != null) stmt.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>