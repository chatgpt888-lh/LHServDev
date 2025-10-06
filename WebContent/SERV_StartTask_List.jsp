<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%!
/**
 * Modify by : pradoem@lh.co.th
 * date : 2016.07.29
 * version 1.1
 * desc:  
 */
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
			 
			 String selected = "";
			 //System.out.println(" value :"+value);
			 if(value.equals("ALL")){
			    selected = " selected";
			 }
			//System.out.println(" selected :"+selected);
			
			 html.append("<option value='ALL' "+selected+">"+Constants.LISTBOX_ALLPROJECT_LABEL+"</option>");
			
			 
		    String comId = "";
			String projId = "";
			String projName = "";
			String val = "";
			
			 while (rs.next()) {
				 comId = doString.checkString(rs.getString("com_id"),"");
				 projId = doString.checkString(rs.getString("proj_id"),"");
				 projName = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
				
				 val = "";
				 val = comId+":"+projId;
				 selected = "";
				 if(value!=null && val.equals(value)) {
				   selected = " selected "; 
				 }
				 //---====== Normal Case , generate project by permission =======---//
				 html.append("<option value='").append(val).append("' ").append(selected).append(">")
					.append(comId).append("-").append(projId).append(" - ").append(projName)
					.append("</option>");				                   		        
			 } // end while		 
			 //----=====================================================----//
		           		     
			 rs.close();
			 stmt.close();

		     
			 if (allProject) {
				 //----====== AllProject is true , gen All Project Listbox ========----//
				 html.delete(0,html.length());
				 html.append(common.genAllProjectListbox(name,value,params,getAllProj));
			 }		     
		     html.append("</select>");
		     
		     //System.out.println("SQL :"+html.toString());
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
/*
System.out.println("*******************************************");
String ParameterNames = "";
for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
	ParameterNames = (String)e.nextElement();
	System.out.println(ParameterNames + " = "+request.getParameter(ParameterNames));
}

System.out.println("******************xxxxxxxxxx*************************");
*/
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_StartTask_List.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   //doString str = new doString();
   String userWho = user.getUserWho();

   //----============ Declare Variables for input data ===========----//
   String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase();
  /* if  (selProj.length()==0) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       session.setAttribute("sess_sel_proj",selProj);
   }*/

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
        
 		doString str = new doString();
        //---====================== Generate Serrch Condition ===========================---//
        String startDate = common.getValueFromDateListbox("start",request);
        String endDate = common.getValueFromDateListbox("end",request);

        if (selProj.trim().length()>=6 && !selProj.equalsIgnoreCase("ALL")) {
           //condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
		   condition = " and a.i_company='"+(selProj.substring(0,2))+"' and a.i_project='"+(selProj.substring(3,6))+"' ";
        }
        
        if (selProj.equalsIgnoreCase("ALL")) {
		//if (selProj.trim().length()<=0) {
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
		
		if(userWho.equals("A") && selProj.equals("ALL")){
			 //--userWho = A and case ALL project
			 condition = "";
			 //System.out.println("Case : 11111111 ");
		}else if(userWho.equals("S") && selProj.equals("ALL")){
				//--userWho = S and case ALL by User
				String preComId = "  and a.i_company in ( "; //'LH')
				String preProj = " and a.i_project in( ";
				//--------------------

     			sql.delete(0,sql.length());
				sql.append(" select  com_id from lan:serv_pstaff  where user_id='").append(user.getUserID()).append("' and proj_id <> 'ALL' ")
					.append(" group by com_id");				
     			rs = stmt.executeQuery(sql.toString());
				while(rs.next()) {
				   preComId +=  "'"+doString.checkString(rs.getString("com_id"),"")+"',";
				}
				preComId = preComId.substring(0,preComId.length()-1)+" )";
				
				//--------------------
				sql.delete(0,sql.length());
				sql.append(" select  com_id,proj_id from lan:serv_pstaff  where user_id='").append(user.getUserID()).append("' and proj_id <> 'ALL' ")
					.append(" order by com_id,proj_id ");				
				rs = stmt.executeQuery(sql.toString());
				while(rs.next()) {
					 //comId = doString.checkString(rs.getString("com_id"),"");
					 preProj += " '"+doString.checkString(rs.getString("proj_id"),"")+"',";
				}
				preProj = preProj.substring(0,preProj.length()-1)+" )";
    			
    			condition = preComId+preProj;
    			//System.out.println("Case : 22222222222 :"+condition);
		}else  if (selProj.trim().length()>=6 && !selProj.equalsIgnoreCase("ALL")) {
		   //case select project
		    condition = " and a.i_company='"+(selProj.substring(0,2))+"' and a.i_project='"+(selProj.substring(3,6))+"' ";	
		    // System.out.println("Case : 333333333333 ");   
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
       //Fix by pradoem 2021.06.23  
       if(!selProj.equals("")){
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
        }
	   //---=========================================================================----//                

        
        
	   //-----============== Generate Display Customize and Page Link ==================-----//
	   String displayType = doString.checkString(request.getParameter("display_type"),"");    
	   int displayLine = Integer.parseInt(doString.checkString(request.getParameter("display_line"),"0"));
	   int nowPage = Integer.parseInt(doString.checkString(request.getParameter("now_page"),"1"));
	   if (displayType.equalsIgnoreCase("A")) {
	      displayLine = maxRow;
	      nowPage = 1;
	   }
	   if (displayLine<Constants.SERV_STARTTASK_LINE) displayLine = Constants.SERV_STARTTASK_LINE;      
	   
	   int startRow = ((nowPage-1)*displayLine);
	   int endRow = startRow+displayLine;
	   int tmpMax = maxRow;
	   
	   String pageLink = "";
	   int tmpPage = 0;
	   while (tmpMax>0) {
	       tmpMax -= displayLine;
	       tmpPage++;
	       if (nowPage==tmpPage) {
	          pageLink += "&nbsp; <b>"+tmpPage+"</b> ";
	       } else {
	          pageLink += "&nbsp; <a href='#' onclick='changePage("+tmpPage+");'>"+tmpPage+"</a> ";
	       }
	   }
	   
	   if (tmpPage>1) {
	      int prev = nowPage-1;
	      if (prev<1) prev=1;  
	      pageLink = "<a href='#' onclick='changePage("+prev+");'>หน้าก่อน</a>&nbsp; "+pageLink;
	      int next = nowPage+1;
	      if (next>tmpPage) next = tmpPage;
	      pageLink += "&nbsp; <a href='#' onclick='changePage("+next+");'>หน้าถัดไป</a>";      
	   } else {
	      pageLink = "หน้า <b>1</b>";
	   }
	 //---=========================================================================----//                


%>


<HTML>
<HEAD>
<TITLE>Start Task List</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<style type="text/css">
.blink-text {text-decoration:blink} 
</style>

<script language="javascript" src="script_fx.js"></script>
<script language="javascript" src="jquery/jquery-1.11.3.min.js"></script>
<script type='text/javascript' src='jquery/loadImg.js'></script>
<script language="javascript">

  function doSubmitForm(url){
    //alert("submit");
     onPleaseWait();    
 	$('form').attr('action', url);
	$("form:first").submit();
  }

  function onPleaseWait(){
	document.all.pleasewaitScreen.style.pixelTop = (document.body.scrollTop + 120);
	$('#pleasewaitScreen').show();
	//setTimeout(function(){  $('#pleasewaitScreen').css("visibility", 'hidden'); }, 9000); //wait 7 seconds
	$('#pleasewaitScreen').css('visibility', 'visible');
 }    
</script>
<script language="javascript">
<!--
  function searchDocHD() {
     if (!validDate()) {
        return false;
     }

     document.forms[0].now_page.value='1';
     //document.forms[0].action="<%=Constants.APP_PATH%>/SERV_StartTask_List.jsp";
     //document.forms[0].submit();  
     
     onSubmitForm("<%=Constants.APP_PATH%>/SERV_StartTask_List.jsp"); 
  }

  function changePage(page) {
     document.forms[0].now_page.value=page;
     //document.forms[0].action="<%=Constants.APP_PATH%>/SERV_StartTask_List.jsp";
     //document.forms[0].submit();
     onSubmitForm("<%=Constants.APP_PATH%>/SERV_StartTask_List.jsp"); 
  }

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
	onSubmitForm("<%=Constants.APP_PATH%>/SERV_StartTaskServlet");
 }
  
  function onSubmitForm(url){
    //alert("submit");
    onPleaseWait();
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
  
 function startTaskXX() {
    var cancel = false;
    var ivendor = document.forms[0].i_vendor;
	if (ivendor!=null) {
		if (ivendor.length!=null) {
			for (var i=0;i<ivendor.length;i++) {
					if (!checkCancelAllItem(ivendor[i].value)) {
						return false;
					}
			} // end for
		} else {
			if (!checkCancelAllItem(ivendor.value)) {
				return false;
			}
		}
	}
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
     if(validateChk1(document.forms[0].i_vendor)){
         alert("กรุณาเลือกรายการซ่อม Start Task อย่างน้อย 1 รายการ !"); 
         document.forms[0].i_vendor[0].focus();
         return false;
     }else{
        document.forms[0].action="<%=Constants.APP_PATH%>/SERV_StartTaskServlet";
        document.forms[0].submit();
     }
  }  
  
  function checkCancelAllItemXXX(val) {
       alert("vvv : "+val);//val = LH-075-5500044_   
        /*alert("vvv : "+val);
	    //var itemList = eval("document.forms[0].i_itmjob_" +val);    
	    var itemList = $("input[name=i_itmjob_"+val+"]:checked").val();	    
	    //document.forms[0].i_itmjob_LH-075-5500044_	    
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
		return true;*/
  }
//-->
</script>


<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM METHOD="POST" ACTION="">
<input type="hidden" name="now_page" value="<%=nowPage%>">

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
  <tr>
    <td class="item ; dotline01" height="22" width="15%">โครงการ :</td>
    <td height="22" width="39%" class="dotline01">
    <%=genProjectListboxByUserId(conn,user.getUserID(),"sel_project",selProj," class='box' style='width:250px' ",true)%>      
    <%//=common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:250px' onchange='resetSearch();' ",true)%>
    </td>
    <td height="22" class="item ; dotline01" width="14%">เลขที่ใบแจ้งซ่อม
      :</td>
    <td height="22" width="32%" class="dotline01"><input type="text" name="i_docno" class="box" style="width:100px" value="<%=docNo%>"></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="15%">บ้านเลขที่
      :</td>
    <td height="22" width="39%" class="dotline01"><input type="text" name="i_house" class="box" style="width:100px" value="<%=houseId%>"></td>
    <td height="22" class="item ; dotline01" width="14%">แปลง :</td>
    <td height="22" width="32%" class="dotline01"> <input type="text" name="i_lock" class="box" style="width:100px" value="<%=lock%>"><!--&nbsp;&nbsp;&nbsp;&nbsp;
     <a href="#" onclick="searchDocHD()"><img border="0" src="images/i_search.gif" align="absmiddle" width="20" height="20"></a>--> </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="11%">วันที่นัดซ่อม
      :</td>
    <td colspan="3" height="22" width="45%" class="dotline01">
    <%=common.genDateListbox("start",request," class='box' ")%> &nbsp; ถึง &nbsp; 
    <%=common.genDateListbox("end",request," class='box' ")%>
      &nbsp;&nbsp;&nbsp;&nbsp;
      <a href="#" onclick="searchDocHD()"><img border="0" src="images/i_search.gif" align="absmiddle" width="20" height="20"></a> 
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


<br style="font-size:10pt">



            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="160">รายการซ่อม</td>
                <td class="item_tab3"></td>
                <td>&nbsp;<input type="radio" value="L" checked name="display_type" <%=(displayType.equalsIgnoreCase("L") ? "checked" : "")%>>แสดงจำนวนรายการต่อหน้า&nbsp;
                  <input type="text" name="display_line" class="boxC" style="width:50px" value="<%=displayLine%>">&nbsp;
                  รายการ&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" value="A" name="display_type" <%=(displayType.equalsIgnoreCase("A") ? "checked" : "")%>>
                  แสดงรายการทั้งหมด&nbsp;&nbsp;&nbsp;&nbsp;
                  <a href="#" onclick="changePage(1);"><img border="0" src="images/bu_R.gif" align="absmiddle" style="cursor:hand" width="16" height="16"></a>
                  </td>
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
			while (i<maxRow) {
                      if (rs.next()) {
						iDocNo = doString.checkString(rs.getString("i_docno"),""); 
						rs1 = stmt1.executeQuery("SELECT i_docno FROM lan:serv_chkuplck WHERE i_docno = '"+iDocNo+"'"); //docNo
						if (rs1.next() == false) {

                         if (i>=startRow && i<endRow) {
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
								 
							//Modify by pradoem for Turn key project : 2015.05.13
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
										                out.println("<b class='blink-text'><font color='RED'>&nbsp;&nbsp;!!รายการยังไม่ส่งขออนุมัติ(Save&Close)</font></b>");
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
										          <td width="94%" class="item ; dotline" colspan="7" height="25"><img border="0" src="images/i_arrow2.gif" align="absmiddle" width="11" height="11">
										          &nbsp;   ชื่อรายการซ่อม</td>
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
                         } // end if check row
                         
                         if (i>endRow) break;         
						 i++;
						}
						rs1.close();
						rs1=null;						 
                      } //end if check rs
                } // end while
                
			
			
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
  
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr class="gray">
          <td width="100%" align="right"><%=pageLink%></td>
        </tr>
      </table>


<br style="font-size:10pt">

        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="150" class="act_tab2">

            <img border="0" src="images/act_starttask.gif" onclick="startTask();"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27"> &nbsp; 

            <img border="0" src="images/act_print.gif" onclick="window.print();"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">

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
	} catch (Exception e) {
		System.out.println("ERROR SERV_StartTask_List.jsp : " + e.getMessage());
		System.out.println("ERROR SERV_StartTask_List.jsp : " + sql.toString());
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