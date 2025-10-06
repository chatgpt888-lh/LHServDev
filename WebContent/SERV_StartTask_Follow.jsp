<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%!
/*
*Modify by pradoem 2015.07.23
*version :
*descrtion :  support หน้าจอ start task project Turk key 
*
**/

 
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
  
     public boolean IsProjectTurnKey(Connection conn,String docNo){
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        
        String i_docNo = "";
        boolean isRecord = false;
        try {

            stmt = conn.createStatement();
  			sql.delete(0, sql.length());
			sql.append(" Select i_docno  ") 
				.append(" From lan:serv_approve ")
				.append(" Where i_docno  = '"+docNo+"' "); 
				//System.out.println("SQL TurnKey  :"+sql.toString());
				rs = stmt.executeQuery(sql.toString());    				   
			    if(rs.next()){
			       i_docNo  = doString.checkString(rs.getString("i_docno"),"");
			    } 		
			    if(i_docNo.length()>0){ // is  project Turn Key
			       isRecord = true;
			    }else{  //Not Turn key
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
    
  /*
  * 2= wait Approve
  * 3= Approved
  * 5= Rout back
  */  
  public String GetStatusServApproved(Connection conn,String docNo){
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        
        String i_doc_type = "";
        //boolean isRecord = false;
        try {

            stmt = conn.createStatement();
  			sql.delete(0, sql.length());
			sql.append(" Select i_doc_type  ")
				.append(" From lan:serv_approve ")
				.append(" Where i_docno  = '"+docNo+"'  "); //AND  i_doc_type ='3'
				//System.out.println("SQL GetStatusServApproved  :"+sql.toString());
				rs = stmt.executeQuery(sql.toString());    				   
			    if(rs.next()){
			       i_doc_type  = doString.checkString(rs.getString("i_doc_type"),"");
			    } 		
			    /*if("3".equals(i_doc_type)){ // is  Approve
			       isRecord = true;
			    }else{
			       isRecord = false;
			    }*/	  
                rs.close();
                stmt.close();
                
        }catch(Exception e) {
            System.out.println(" GetStatusServApproved Error : " + e.getMessage());
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
        return i_doc_type;
    }
 %>
<%

String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_StartTask_Follow.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);
doString str = new doString();

   //----============ Declare Variables for input data ===========----//
   String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase();
   if  (selProj.length()==0) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       session.setAttribute("sess_sel_proj",selProj);
   }

   String docNo = doString.checkString(request.getParameter("i_docno"),"").toUpperCase();
   String houseId = doString.checkString(request.getParameter("i_house"),"").toUpperCase();
   String lock = doString.checkString(request.getParameter("i_lock"),"").toUpperCase();
   String condition = "";
	String iDocNo = "";        
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	SERV_CommonData common = null;
	
	String i_company = "";
	String i_project = "";
	String itmtype = "";
	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();
		stmt1 = conn.createStatement();
		common = new SERV_CommonData(conn);
        //----=======================================----//   

        //---====================== Generate Serrch Condition ===========================---//
        String startDate = common.getValueFromDateListbox("start",request);
        String endDate = common.getValueFromDateListbox("end",request);
		itmtype = doString.checkString(request.getParameter("itmtype"),"");
        if (selProj.trim().length()>=6 && !selProj.equalsIgnoreCase("ALL")) {
           //condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
		   condition = " and a.i_company='"+(selProj.substring(0,2))+"' and a.i_project='"+(selProj.substring(3,6))+"' ";
			i_company = selProj.substring(0,2);
			i_project = selProj.substring(3,6);
        }
		if (selProj.trim().length()<=0) {
		   String projList = common.getProjectListByUserId(user.getUserID());
		   if (projList.length()>0) {
		       //condition += " and substr(a.i_docno,1,6) in ("+projList+") ";
			   //================== modified to used index field =====================//
				if (projList.trim().length()>0) {
					String projCondition = "";
					StringTokenizer plist = new StringTokenizer(projList,",");
					while (plist.hasMoreTokens()) {
						String proj = str.replace(plist.nextToken(),"'","").trim();
						if (proj.length()>=6) {
							String icom = proj.substring(0,2);
							String iproj = proj.substring(3,6);
							if (projCondition.trim().length()>0) projCondition += " or ";
							projCondition += " (a.i_company='"+icom+"' and a.i_project='"+iproj+"') ";
						}
					} // end while

					if (projCondition.trim().length()>0) {
						condition = " and ("+projCondition+") ";
					}
				}
				//===============================================================//
		   } else {

			sql.delete(0,sql.length());
			sql.append(" select count(*) from serv_pstaff  where user_id='").append(user.getUserID()).append("' and proj_id='ALL' ");
			int checkAllPermission = 0;

			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			if (rs.next()) {
			    checkAllPermission = rs.getInt(1);
			}
			rs.close();
			if (checkAllPermission<=0) { 
			   //----- used for user that no project in hand , set for data not load ----//
			   condition += " and a.i_docno='NOPROEJCT' ";
		       } else {
			  selProj = "ALL";
		       }

		   }
		}     
        if (docNo.trim().length()>0) {
           condition += " and a.i_docno='"+docNo+"' ";
        }
        /*if (houseId.trim().length()>0) {
           condition += " and c.i_house='"+houseId+"' ";
		   condition += " and a.i_company = c.i_company and a.i_project = c.i_project and a.i_lock = c.i_lock ";
        }*/
        if (lock.trim().length()>0) {
           condition += " and a.i_lock='"+lock+"' ";
        }                

	if (startDate.length()>0 && endDate.length()>0) {
	   condition += " and a.d_appoint between '"+startDate+"' and '"+endDate+"' ";
	}
       //---=========================================================================----//   

        
        //----====================== Get DOCHD Max Row ==============================-----//
        int maxRow = 0;
        sql.delete(0,sql.length());
        sql.append(" select distinct a.i_docno,b.i_vendor,a.i_company,a.i_project,a.i_lock from lan:serv_dochd a ,lan:serv_docdt b ");
	if (houseId.trim().length()>0) {	    
	    sql.append(" ,lan:acxlckmd c where c.i_house='"+houseId+"' ")
		  .append(" and c.i_company = a.i_company and c.i_project = a.i_project and c.i_lock = a.i_lock ");
	} else {
	    sql.append(" where 1=1 ");
	}
         sql.append(" and b.i_docno=a.i_docno and a.f_status='OPN' and a.i_doc_type='J' ")
              .append(" and b.f_itmstatus='200' ").append(condition);
//System.out.println(sql.toString());
		servlog.startLog(sql.toString());
        rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
        while (rs.next()) {     
			iDocNo = doString.checkString(rs.getString("i_docno"));
			rs1 = stmt1.executeQuery("SELECT i_docno FROM lan:serv_chkuplck WHERE i_docno = '"+iDocNo+"'");
			if (rs1.next() == false) {
				maxRow++;
			}
			rs1.close();
			rs1=null;
        }
        rs.close();
%>


<HTML>
<HEAD>
<TITLE>Start Task List</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css"><style type="text/css">
<style>
.blink-text {text-decoration:blink} 
</style>
<script language="javascript" src="script_fx.js"></script><script language="javascript" src="jquery/jquery-1.11.3.min.js"></script>

<script language="javascript">

  function checkCancelAllItem(param) {
     //alert($("."+param).length);
     //alert($("."+param+":checked").length);  
    //checkbox:checked== object checkbox.length
     if( $("."+param+":checked").length == $("."+param).length){
       	alert("ไม่สามารถยกเลิกรายการทั้งหมดในใบแจ้งซ่อมได้\nหากต้องการยกเลิกรายการทั้งหมด กรุณาทำการยกเลิกใบแจ้งซ่อมแทน !!");
		return true;
     }else{
        return false;
     }
  }
 
  	/*****
 	*  TODO: 
 	*  1. please checkbox 1 item or more than 
 	*  2. validate cacel check items con't cancel sub items all check
 	*  3. submit form
 	*****/ 
 function startTask() {
    //Checkbox :get Object Array
    var chkVenObj = $('.chkVendor:checked');
    
    //Checkbox:checked.length
    if($(".chkVendor:checked").length==0){
       alert("กรุณาเลือกรายการซ่อม Start Task อย่างน้อย 1 รายการ !"); 
       //focus checkbok
       $('input[type="checkbox"]:first').focus();
       return false;
    }
 	for(i=0;i<chkVenObj.length;i++){	  
 	   var chk = checkCancelAllItem(chkVenObj[i].value);
 	   if(chk){
 	       return false;
 	    }
 	} 	
 	//validate sub checkbox items for cancel
 	var cancel = false;
    for(i=0;i<chkVenObj.length;i++){	
       if($("."+chkVenObj[i].value+":checked").length>0){
           cancel = true;
           break;
       }
    }
 	if (cancel) {
 	   if (!confirm("มีการยกเลิกรายการซ่อมบางรายการ , คุณแน่ใจหรือไม่ ?")) {
            return false;
       }
 	}
    document.forms[0].from_page.value = 'SERV_ReportServiceDetails.jsp';
	onSubmitForm("<%=Constants.APP_PATH%>/SERV_StartTaskServlet");
 }
  
  function onSubmitForm(url){

 	$('form').attr('action', url);
	$("form:first").submit();
  }
  
  /****
  * TODO : Modify by pradoem
  * date : 2015.06.16
  * script : jquery 11, support IE,Firefox,Chrome,Safari,And mobile browsers
  * description : function for Remove attribute Check box when click check vendor and
  *  then uncheck clear check items check box and disable end.
  ****/
 function enableCancel(name,checked) {    
     if (checked) {
	    $("input."+name).removeAttr("disabled");
	  } else {
	    $("input[name=i_itmjob_"+name+"]").attr('checked', false);//true
	   	$("input."+name).attr("disabled", true);
	 }
  }
 
  function validDate() {
     var sdate = document.forms[0].start_date.value;
     var smonth = document.forms[0].start_month.value;
     var syear = document.forms[0].start_year.value;
     var edate = document.forms[0].end_date.value;
     var emonth = document.forms[0].end_month.value;
     var eyear = document.forms[0].end_year.value; 
     
     //---- Check select date ---//
     if (sdate.length==0 && smonth.length==0 && syear.length==0 &&
         edate.length==0 && emonth.length==0 && eyear.length==0) {
         return true;
     }     
     var startDate = new Date(parseInt(syear,10),parseInt(smonth,10)-1,parseInt(sdate,10));
     var endDate = new Date(parseInt(eyear,10),parseInt(emonth,10)-1,parseInt(edate,10));
     
     if (startDate.getMonth()!=(parseInt(smonth,10)-1)) {
        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].start_date.focus();
        return false;
     }
     
     if (endDate.getMonth()!=(parseInt(emonth,10)-1)) {
        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].end_date.focus();
        return false;
     }     
     
	if (startDate>endDate) {
	    alert(" วันที่สิ้นสุดต้องไม่น้อยกว่าวันที่เริ่มต้น ! ");
	    return false;
	}
     return true;
  }

  
  //modify by pradoem
  function validateChk1(Obj){
	var isVar = false;
	//var checkGroup = document.forms[0].myRadio;
	alert("test :"+Obj);
	for (var i=0; i<Obj.length; i++) {
		if (Obj[i].checked){
			break;	
		}
	}
	if (i==Obj.length){
		//return alert("No Checkbox is checked");
		isVar = true; // is Error && alert
	}
	return isVar;
} 

function doPending(){
	var form = document.forms[0];
	form.mode.value='';
	form.action = '/LHServ/SERV_Pending.jsp';
	form.submit();
} 
 

<!--
  /*function checkCancelAllItem(val) {
	    var itemList = document.forms[0].elements("i_itmjob_"+val);
		if (itemList!=null) {
			if (itemList.length!=null) {
				var countCheck = 0;
				for (var i=0;i<itemList.length;i++) {
						 if (!itemList[i].disabled && itemList[i].checked) {
							 countCheck++;
						 }					   
				} // end for
				if (countCheck==itemList.length) {
					 alert("ไม่สามารถยกเลิกรายการทั้งหมดในใบแจ้งซ่อมได้\nหากต้องการยกเลิกรายการทั้งหมด กรุณาทำการยกเลิกใบแจ้งซ่อมแทน !!");
					 return false;
				}
			} else {
				 if (!itemList.disabled && itemList.checked) {
					 alert("ไม่สามารถยกเลิกรายการทั้งหมดในใบแจ้งซ่อมได้\nหากต้องการยกเลิกรายการทั้งหมด กรุณาทำการยกเลิกใบแจ้งซ่อมแทน !!");
					 return false;
				 }
			}
		}
		return true;
  }
  function startTask() {
     var cancel = false;
     for (var i=0;i<document.forms[0].elements.length;i++) {
           var obj = document.forms[0].elements[i];
           if (obj!=null && obj.type.toUpperCase()=="CHECKBOX" && obj.name.toUpperCase().indexOf("I_ITMJOB_")==0) {
               if (!obj.disabled && obj.checked) {
                  cancel = true;
                  break;
               } 
           } 
     } 
     if (cancel) {
         if (!confirm("มีการยกเลิกรายการซ่อมบางรายการ , คุณแน่ใจหรือไม่ ?")) {
            return false;
         }
     }
     document.forms[0].from_page.value = 'SERV_ReportServiceDetails.jsp';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_StartTaskServlet";
     document.forms[0].submit();
  }  
  function enableCancel(name,checked) {
     var obj = document.forms[0].elements("i_itmjob_"+name);
     if (obj!=null) {
        if (obj.length!=null) {
		     for (var i=0;i<obj.length;i++) {  
		           obj[i].disabled = !checked;
				   if (!checked) obj[i].checked = false;
		     } // end for
		 } else {
		    obj.disabled = !checked;
 		    if (!checked) obj.checked = false;
		 }
     }
  }
  function validDate() {
     var sdate = document.forms[0].start_date.value;
     var smonth = document.forms[0].start_month.value;
     var syear = document.forms[0].start_year.value;
     var edate = document.forms[0].end_date.value;
     var emonth = document.forms[0].end_month.value;
     var eyear = document.forms[0].end_year.value; 
     //---- Check select date ---//
     if (sdate.length==0 && smonth.length==0 && syear.length==0 &&
         edate.length==0 && emonth.length==0 && eyear.length==0) {
         return true;
     }     
     var startDate = new Date(parseInt(syear,10),parseInt(smonth,10)-1,parseInt(sdate,10));
     var endDate = new Date(parseInt(eyear,10),parseInt(emonth,10)-1,parseInt(edate,10));
     
     if (startDate.getMonth()!=(parseInt(smonth,10)-1)) {
        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].start_date.focus();
        return false;
     }
     if (endDate.getMonth()!=(parseInt(emonth,10)-1)) {
        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].end_date.focus();
        return false;
     }     
	if (startDate>endDate) {
	    alert(" วันที่สิ้นสุดต้องไม่น้อยกว่าวันที่เริ่มต้น ! ");
	    return false;
	}
     return true;
  }
function doPending(){
	var form = document.forms[0];
	form.mode.value='';
	form.action = '/LHServ/SERV_Pending.jsp';
	form.submit();
}*/
//-->
</script>
<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM METHOD="POST" ACTION="">
<input type="hidden" name="mode" />
<input type="hidden" name="from_page" value="SERV_StartTask_Follow.jsp" />
<input type="hidden" name="i_company" value="<%=i_company%>" />
<input type="hidden" name="i_project" value="<%=i_project%>"/>
<input type="hidden" name="itmtype" value="<%=itmtype%>" />
<input type="hidden" name="i_docno" value="<%=iDocNo%>"/>
<input type="hidden" name="itmtype" value="<%=doString.checkString(request.getParameter("itmtype"), "")%>">
<input type="hidden" name="i_itmno" value="<%=doString.checkString(request.getParameter("i_itmno"), "")%>">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
		 <table border="0" width="100%" cellspacing="0" cellpadding="0">
		   <tr>
		     <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
		       Start Task List : Wait</td>
		     <td width="50%" align="right"></td>
		   </tr>
		 </table>            
		<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="160">รายการซ่อม</td>
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

    
        <%
        
		     //----================== Select Data from SERV_DOCHD ================----//   
	        int line = 0;
	        sql.delete(0,sql.length());  
	        sql.append(" select distinct a.i_docno,b.i_vendor,a.i_company,a.i_project,a.i_lock ")
	              .append(" from lan:serv_dochd a ,lan:serv_docdt b ");
			if (houseId.trim().length()>0) {	    
			    sql.append(" ,lan:acxlckmd c where c.i_house='"+houseId+"' ")
				  .append(" and c.i_company = a.i_company and c.i_project = a.i_project and c.i_lock = a.i_lock ");
			} else {
			    sql.append(" where 1=1 ");
			}
	        sql.append(" and b.i_docno=a.i_docno and a.f_status='OPN' and a.i_doc_type='J' ")
	              .append(" and b.f_itmstatus='200' ").append(condition)
	              .append(" order by b.i_vendor,a.i_docno ");

			String oldVendor = "";
			String oldiDocNo = "";		              
			Hashtable cust = null;
			iDocNo = ""; 
			String iVendor = ""; 
			String iCompany = ""; 
			String iProject = ""; 
			String iLock = ""; 
			
			boolean isTurnkey = false;
			String iDocType = "";
			String strDisable = "";
			String iHouse = ""; 
			String custName = ""; 
			Calendar dApp = null;
			Timestamp tmp = null;
			int i=0;
	        rs = stmt.executeQuery(sql.toString());
            if (rs.next()) {
				iDocNo = doString.checkString(rs.getString("i_docno"),""); 
				rs1 = stmt1.executeQuery("SELECT i_docno FROM lan:serv_chkuplck WHERE i_docno = '"+iDocNo+"'"); //docNo
				if (rs1.next() == false) {
                          iVendor = doString.checkString(rs.getString("i_vendor"),""); 
                          iCompany = doString.checkString(rs.getString("i_company"),""); 
                          iProject = doString.checkString(rs.getString("i_project"),""); 
                          iLock = doString.checkString(rs.getString("i_lock"),"");         
                          cust = common.getCustomerDetails(iCompany,iProject,iLock);
                          iHouse = doString.checkString((String) cust.get("i_house"),"");
                          custName = doString.DisplayThai(doString.checkString((String) cust.get("n_customer"),""));      
                  			if (line>0) {
							    %>      					        
							<table border="0" width="100%" cellspacing="0" cellpadding="0">
							  <tr>
							    <td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
							    <td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
							    <td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
							  </tr>
							</table>
						 <%
						 }
							//Modify by pradoem for Turn key project : 2015.07.23
							//=============================================================================================
							isTurnkey = false;
							isTurnkey = IsProjectTurnKey(conn,iCompany,iProject);
							//System.out.println("document Turn key :"+isTurnkey);
							if(isTurnkey){
							  iDocType = GetStatusServApproved(conn,iDocNo);
							}
							
							//=============================================================================================
							
                          //---=========== Get Item in this i_docno , i_vendor ===========---//
                          sql.delete(0,sql.length());
                          sql.append(" select a.i_docno, a.n_customer,a.n_cus_tel,a.d_appoint,c.bus_name,d.n_itmjob,b.i_itmjob ")
                                .append(" from lan:serv_dochd a ,lan:serv_docdt b ")
                                .append(" left join lan:stpvendr c on c.vend_code=b.i_vendor ")
                                .append(" left join lan:serv_boq d on d.i_itmjob=b.i_itmjob ")
                                .append(" where b.i_docno=a.i_docno and a.f_status='OPN' ")
                                .append(" and a.i_doc_type='J' and b.f_itmstatus='200' ")
                                .append(" and a.i_docno='").append(iDocNo).append("' ")
                                .append(" and b.i_vendor='").append(iVendor).append("' ");
                          	int itmLine = 0;      
							servlog.startLog(sql.toString());
                            rs1 = stmt1.executeQuery(sql.toString());
							servlog.endLog();
                         while (rs1.next()) {
                               itmLine++;
                               String vendorName = doString.checkString(doString.DisplayThai(rs1.getString("bus_name")),"-"); 
                               String nCustomer = doString.checkString(doString.DisplayThai(rs1.getString("n_customer")),""); 
                               String nCustTel = doString.checkString(doString.DisplayThai(rs1.getString("n_cus_tel")),""); 
                               String iItmJob = doString.checkString(rs1.getString("i_itmjob"),""); 
                               String nItmJob = doString.checkString(doString.DisplayThai(rs1.getString("n_itmjob")),"");                     
                              String dAppoint = "-";   
						tmp = rs1.getTimestamp("d_appoint");
						if (tmp!=null) {
                              dApp = Calendar.getInstance();                         
						      dApp.setTime(tmp);     
						      dAppoint = common.getDateFromCalendar(dApp);
						}	                                                     
                           //----============== Print Header Table ==================----//
							 if (itmLine==1) {
							 %>	
								<table border="0" width="100%" cellspacing="0" cellpadding="0">
								  <tr>
								    <td width="100%" class="frmL">										    
								      <table border="0" width="100%" cellspacing="0" cellpadding="0">
								        <tr>
								          <td width="2%" class="col_name" height="25">&nbsp;</td>
								          <td width="25%" class="col_name">ผู้รับเหมาซ่อม</td>
								          <td width="6%" class="col_name">แปลง</td>
								          <td width="7%" class="col_name">บ้านเลขที่</td>
								          <td width="23%" class="col_name">ชื่อผู้แจ้ง/ลูกค้า</td>
								          <td width="11%" class="col_name">วันที่นัดซ่อม</td>
								          <td width="12%" class="col_name">เลขที่ใบแจ้งซ่อม</td>
								          <td width="10%" class="col_name">ยกเลิกการซ่อม</td>
								        </tr>				
								        <tr>
								          <%--
								           <td width="2%" align="center" class="dotline01" height="25"><input type="hidden" name="i_vendor" value="<%=iDocNo+"_"+iVendor%>">&nbsp;</td>
								           <td width="25%" class="dotline01" height="25"><%=vendorName%></td>
								          --%>						          
										          <td width="2%" align="center" class="dotline01" height="25">
										              <%
										               strDisable = "";
										               if(isTurnkey){
										                  if("3".equals(iDocType)){//passed
										              	      strDisable ="  ";
										                  }else{ //2,5, any status
										               		 strDisable =" disabled='disabled' ";
										                  } 
										                  %>
										                  	<input type="checkbox" name="i_vendor" class="chkVendor" onclick="enableCancel(this.value,this.checked);" value="<%=iDocNo+"_"+iVendor%>" <%=strDisable %>>									               
										                  <%
										               }else{%>
										         	  	   <input type="checkbox" name="i_vendor" class="chkVendor" onclick="enableCancel(this.value,this.checked);" value="<%=iDocNo+"_"+iVendor%>" >									               
										              <%}  %>
										          </td>
										          <td width="25%" class="dotline01" height="25">
										          <%=vendorName%>
										          <%
										        //  System.out.println(" iDocType : "+iDocType);
										          if(isTurnkey){
										             if("2".equals(iDocType)){ //รออนุมัติ  Waiting
										             	%>
										             	&nbsp;&nbsp;<img src="images/icon_WaitApprove.gif" width="75" height="25" border="0" align="absmiddle" alt="รายการรออนุมัติ">
										             	<%
										             }else if("3".equals(iDocType)){//อนุมัติแล้ว Passed
										             	out.println("&nbsp;");
										             }else if("5".equals(iDocType)){ //Route Back
										             	%>
										             	&nbsp;&nbsp;<img src="images/icon_RouteBack.gif" width="75" height="25" border="0" align="absmiddle" alt="รายการ Route Back">
										             	<%
										             }else{
										                out.println("<b class='blink-text'><font color='RED'>&nbsp;&nbsp;!! ยังไม่ขออนุมัติ</font></b>");
										             }
										          }else{
										          	out.println("&nbsp;");
										          }
										           %>
										   </td>
								         
								          <td width="6%" class="dotline01" align="center" height="25"><%=iLock%></td>
								          <td width="7%" class="dotline01" align="center" height="25"><%=iHouse%></td>
								          <td width="23%" class="dotline01" height="25"><%=common.joinContactAndOwner(nCustomer,custName)%></td>
								          <td width="11%" class="dotline01" align="center" height="25"><%=dAppoint%></td>
								          <td width="12%" align="center" class="dotline01" height="25">
								          <%=iDocNo%>
								          <% if(isTurnkey){ %>
										          	   &nbsp;<img src="images/icon_TurnKey.gif" width="50" height="25" border="0" align="absmiddle">
										  <%}else{ out.println("&nbsp;");} %>
								          </td>
								          <td width="10%" align="center" class="dotline" height="25">&nbsp;</td>
								        </tr>
								        <tr>
								          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
								          <td width="94%" class="item ; dotline" colspan="7" height="25"><img border="0" src="images/i_arrow2.gif" align="absmiddle" width="11" height="11">&nbsp;
								            ชื่อรายการซ่อม</td>
								        </tr>									        
						        <%                                
						    } // end if check first line 
							//---============== Print Item List ================----//
			                %>
						      
						      	<tr>
								          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
								          <td width="84%" class="dotline01" colspan="6" style="padding-left:20px" height="25"><%=(itmLine)+". "+nItmJob%></td>
							              <td width="10%" align="center" class="dotline" height="25">
							              <input type="checkbox" name="i_itmjob_<%=iDocNo+"_"+iVendor%>" class="<%=iDocNo+"_"+iVendor%>" disabled  value="<%=iDocNo+":"+iVendor+":"+iItmJob%>"></td>
								</tr>  
						        <%-- 
						        <tr>
						          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
						          <td width="84%" class="dotline01" colspan="6" style="padding-left:20px" height="25"><%=(itmLine)+". "+nItmJob%></td>
					              <td width="10%" align="center" class="dotline" height="25"><input type="checkbox" name="i_itmjob_<%=iDocNo+"_"+iVendor%>" value="<%=iDocNo+":"+iVendor+":"+iItmJob%>"></td>
						        </tr>
						        --%>					                
			                <%
			                
			                
			                
                           } // end while item	
					 rs1.close();
                           //-----============== Print Footer ================----//
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
					
					<br style="font-size:10pt">
					<%
				   line++;            
				 	i++;
				}
				rs1.close();
				rs1=null;						 
            } //end if check rs
			//-----================ If No Data , Print Blank Table =================----//
			if (line<1) {
				 %>	
					<table border="0" width="100%" cellspacing="0" cellpadding="0">
					  <tr>
					    <td width="100%" class="frmL">										    
					      <table border="0" width="100%" cellspacing="0" cellpadding="0">
					        <tr>
					          <td width="2%" class="col_name" height="22">&nbsp;</td>
					          <td width="25%" class="col_name">ผู้รับเหมาซ่อม</td>
					          <td width="6%" class="col_name">แปลง</td>
					          <td width="7%" class="col_name">บ้านเลขที่</td>
					          <td width="23%" class="col_name">ชื่อผู้แจ้ง/ลูกค้า</td>
					          <td width="11%" class="col_name">วันที่นัดซ่อม</td>
					          <td width="12%" class="col_name">เลขที่ใบแจ้งซ่อม</td>
					          <td width="10%" class="col_name">ยกเลิกการซ่อม</td>
					        </tr>												        
							 <tr>
					          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
					          <td width="94%" class="dotline" colspan="7" style="padding-left:20px" height="25">&nbsp;</td>
					        </tr>	
							 <tr>
					          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
					          <td width="94%" class="dotline" colspan="7" style="padding-left:20px" height="25">&nbsp;</td>
					        </tr>	
							 <tr>
					          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
					          <td width="94%" class="dotline" colspan="7" style="padding-left:20px" height="25">&nbsp;</td>
					        </tr>	
							 <tr>
					          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
					          <td width="94%" class="dotline" colspan="7" style="padding-left:20px" height="25">&nbsp;</td>
					        </tr>	
							 <tr>
					          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
					          <td width="94%" class="dotline" colspan="7" style="padding-left:20px" height="25">&nbsp;</td>
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
			  <%
			} // end if check no data
        %> 
<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="300" class="act_tab2">
            <img border="0" src="images/act_starttask.gif" onclick="startTask();"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">&nbsp; 
            <img border="0" src="images/act_print.gif" onclick="window.print();"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">&nbsp;
			<img border="0" src="images/act_Pending.gif" onclick="javascript:doPending();"                               
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">
            </td>
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="/LHServ/SERV_ReportServiceDetails.jsp?i_company=<%=i_company%>&i_project=<%=i_project%>&itmtype=<%=itmtype%>" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
	} catch (Exception e) {
		System.out.println("ERROR SERV_StartTask_Follow.jsp : " + e.getMessage());
		System.out.println("ERROR SERV_StartTask_Follow.jsp : " + sql.toString());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (rs1 != null) rs1.close();
			if (stmt != null) stmt.close();
			if (stmt1 != null) stmt1.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>