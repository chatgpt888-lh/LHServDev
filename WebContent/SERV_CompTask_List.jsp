
<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="java.text.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@page import="java.io.*" %>
<%@page import="java.net.*" %>
<%@ include file="function.jsp" %>
   

<%!
/**
 * Modify by : pradoem@lh.co.th
  last : 2021.06.23
 * date : 2015.05.27
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
  public boolean IsImgServDocAtt(Connection conn,String iDocNo){
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        
        int cnt = 0;
        boolean isRecord = false;
        try {

            stmt = conn.createStatement();
  			sql.delete(0, sql.length());
			sql.append(" Select count(*) as cnt  ")
				.append(" From lan:serv_docatt")
				.append(" Where i_docno  = '"+iDocNo+"' AND i_keygen  is not null  AND i_keygen <> '' "); 
				//System.out.println("SQL  :"+sql.toString());
				rs = stmt.executeQuery(sql.toString());    				   
			    if(rs.next()){
			       cnt  = rs.getInt("cnt");
			    } 		
			    if(cnt>0){
			      isRecord = true;
			    }			  
                rs.close();
                stmt.close();
                
        }catch(Exception e) {
            System.out.println(" IsImgServDocAtt Error : " + e.getMessage());
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
    
 // วันที่จ่าย 
 public boolean IsDatePayment(Connection conn){
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        
        String dPayment = "";
        boolean isRecord = false;
        try {

            stmt = conn.createStatement();
  			sql.delete(0, sql.length());
			sql.append(" select d_payment from lan:serv_payschd where today<=d_contructor order by d_payment  ");
				//System.out.println("SQL  :"+sql.toString());
				rs = stmt.executeQuery(sql.toString());    				   
			    if(rs.next()){
			       dPayment  = doString.checkString(rs.getString("d_payment"),""); 
			    } 		
			    if(!"".equals(dPayment)){
			      isRecord = true;
			    }			  
                rs.close();
                stmt.close();
                return isRecord;
        }catch(Exception e) {
            System.out.println(" IsDatePayment Error : " + e.getMessage());
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

//String hostName = "http://132.146.1.180:8080";
//String pathUrlX = hostName+"/AppServ/uploads";
//String pathPdfUrl = hostName+"/AppServ/uploads";
//System.out.println("pathPdfUrl="+pathPdfUrl);

String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_CompTask_List.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   doString str = new doString();
   String userWho = user.getUserWho();

   //----============ Declare Variables for input data ===========----//
   String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase();
   /*if  (selProj.length()==0) {
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
        
		//update by pradoem 2018.10.22
		boolean isDatePayment = IsDatePayment(conn);
        
        //---====================== Generate Serrch Condition ===========================---//
        if (selProj.trim().length()>=6 && !selProj.equalsIgnoreCase("ALL")) {
           //condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
		   condition = " and a.i_company='"+(selProj.substring(0,2))+"' and a.i_project='"+(selProj.substring(3,6))+"' ";
        }
		//if (selProj.trim().length()<=0) {
		if (selProj.equalsIgnoreCase("ALL")) {
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
        
		/*
        if (houseId.trim().length()>0) {
  		    condition += " and c.i_house='"+houseId+"' ";
		    condition += " and a.i_company = c.i_company and a.i_project = c.i_project and a.i_lock = c.i_lock ";
        }*/
        
        if (lock.trim().length()>0) {
           condition += " and a.i_lock='"+lock+"' ";
        }                
 	   //---=========================================================================----//   

        
    
        //----====================== Get DOCHD Max Row ==============================-----//
        int maxRow = 0;
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
	              .append(" and b.f_itmstatus='300' ").append(condition);
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
		   //---=========================================================================----//     	             
        }
        
	   //-----============== Generate Display Customize and Page Link ==================-----//
	   String displayType = doString.checkString(request.getParameter("display_type"),"");    
	   int displayLine = Integer.parseInt(doString.checkString(request.getParameter("display_line"),"0"));
	   int nowPage = Integer.parseInt(doString.checkString(request.getParameter("now_page"),"1"));
	   if (displayType.equalsIgnoreCase("A")) {
	      displayLine = maxRow;
	      nowPage = 1;
	   }
	   if (displayLine<Constants.SERV_COMPLETETASK_LINE) displayLine = Constants.SERV_COMPLETETASK_LINE;      
	   
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
<TITLE>Complete Task List</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
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
	function doViewFollowDesc(param,id){
	    if(param==true) {	
			 document.getElementById("show_"+id).style.display=''; //Enable
	     }else {
			 document.getElementById("show_"+id).style.display='none';//Disable
	     }
	 }
	 
  function doSubmitForm(url){
    //alert("submit");
    onPleaseWait();
 	$('form').attr('action', url);
	$("form:first").submit();
  }


  function searchDocHD() {
     document.forms[0].now_page.value='1';
     //document.forms[0].action="<%=Constants.APP_PATH%>/SERV_CompTask_List.jsp";
     //document.forms[0].submit(); 
     doSubmitForm("<%=Constants.APP_PATH%>/SERV_CompTask_List.jsp?sel_project=<%=selProj%>");
  }

  function changePage(page) {
     document.forms[0].now_page.value=page;
     //document.forms[0].action="<%=Constants.APP_PATH%>/SERV_CompTask_List.jsp";
     //document.forms[0].submit();
     doSubmitForm("<%=Constants.APP_PATH%>/SERV_CompTask_List.jsp?sel_project=<%=selProj%>");
  } 
  
  
  function completeTask() {     
    //Checkbox:checked.length
    var isDate = <%=isDatePayment%>
    if(!isDate){
          alert("แจ้งเตือนยังไม่มีการระบุ 'วันที่จ่าย'  กรุณาตรวจสอบหรือติดต่อผู้ดูแลระบบ  !"); 
          return false;
    }else if($(".chkVendor:checked").length==0){
        alert("กรุณาเลือกรายการซ่อม Complete Task อย่างน้อย 1 รายการ !"); 
       //focus checkbok
       $('input[type="checkbox"]:first').focus();
       return false;
    }else{
       doSubmitForm("<%=Constants.APP_PATH%>/SERV_CompTaskServlet");
    }

     /*if(validateChk1(document.forms[0].i_vendor)){
         alert("กรุณาเลือกรายการซ่อม Complete Task อย่างน้อย 1 รายการ !"); 
         document.forms[0].i_vendor[0].focus();
         return false;
     }else{
        document.forms[0].action="<%=Constants.APP_PATH%>/SERV_CompTaskServlet";
        document.forms[0].submit();
     }*/
  }   
  
    
  //modify by pradoem
  function validateChk1(Obj){
	var isVar = false;
	//var checkGroup = document.forms[0].myRadio;
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
	//alert("Radio Button " + (i+1) + " is checked.");
} 
  
  function doDetail(docId) {
	  // alert(docId);
	   document.forms[0].action="/LHServ/SERV_CompTask_UploadImg.jsp?load=YES&i_docno="+docId;  
	   document.forms[0].submit();
  }
  
  function printImage(docId) {
	   document.forms[0].action="/LHServ/SERV_OpenJobPrintImageServlet?i_docno="+docId;
	   document.forms[0].target="_blank";   
	   document.forms[0].submit();
  }
  
  var windowObjectReference = null;
  function openUploadWindow2(mm,yyyy,docIdx) {
	/*if (contextPath.length>0 && contextPath.substring(contextPath.length-1)!="/") 	{
	    contextPath += "/";
	}*/
    var vReturnValue = window.open("<%=hostName%>/AppServ/upload_file_main.jsp?mm="+mm+"&yyyy="+yyyy+"&docIdx="+docIdx,"","Left=100,Top=100,width=500,height=250; center: Yes; resizable: No; status: No;");
	//var vReturnValue = window.open(contextPath+"upload2_main.jsp?session_id="+uploadId+"&key_file="+keyFile,"","Left=100,Top=100,width=400,height=380; center: Yes; resizable: No; status: No;");
	//console.log("vReturnValue=",vReturnValue);
	return vReturnValue;
 }
 
 function  refresh() {
  	  onPleaseWait();
  	  document.forms[0].now_page.value=page;
	  doSubmitForm("<%=request.getContextPath()%>/SERV_CompTask_List.jsp?sel_project=<%=selProj%>");	
 }
		
  var hostNameX = "<%=Utilizer.getPropValue("DOMAIN_NAME")%>";
  function attachFiles(mm,yyyy,docIdx){
    	if(windowObjectReference == null || windowObjectReference.closed){
  	   		  windowObjectReference = openUploadWindow2(mm,yyyy,docIdx);   
  	    }else{
  	   		windowObjectReference.focus();
  	    }
  	    //Create IE + others compatible event handler
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
			      if (e.data==="OK") {
						document.forms[0].action='SERV_CompTask_List.jsp?sel_project=<%=selProj%>';
						document.forms[0].submit();
			      }	      
			  }
		}, false);
   }
   
      function delFile(docId,mm,yyyy,fileId) {
		if(confirm("คุณแน่ใจว่าต้องการลบไฟล์แนบนี้ ?")) {
		 var param = "docId="+docId+"&mm="+mm+"&yyyy="+yyyy+"&fileId="+fileId;
		 //alert(param);
		 $.ajax({
	        crossDomain: true,
		    type: "POST",	
			url: "<%=hostName%>/AppServ/DeleteFileById",
			data: param,
			success: function(data){
				//alert(data); //"A:11111:ทดสอบ"  "E:x:x"   				
				if(data==null || data==""){
					return;
				}  				
				var temp = data.split(":");
				document.forms[0].action='SERV_CompTask_List.jsp?sel_project=<%=selProj%>';
				document.forms[0].submit();
		    }
		  });
		}
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
            Complete Task List : Wait</td>
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
    <td height="22" width="32%" class="dotline01"> <input type="text" name="i_lock" class="box" style="width:100px" value="<%=lock%>">&nbsp;&nbsp;&nbsp;&nbsp;
      <a href="#" onclick="searchDocHD()"><img border="0" src="images/i_search.gif" align="absmiddle" width="20" height="20"></a> </td>
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
             ArrayList docList = new ArrayList(); 
             Hashtable hashDocDT = new Hashtable();
             
        	 String i_keygen = "";  
        	 String vendorName = "";
	         String nCustomer = "";
	         String nCustTel = "";
	         String iItmJob = ""; 
	         String nItmJob = ""; 
	         String dApprove = "-";
		     //----================== Select Data from SERV_DOCHD ================----//   
		    int line = 0;
		    sql.delete(0,sql.length());  
		    sql.append(" select distinct a.i_docno,b.i_vendor,a.i_company,a.i_project,a.i_lock,date(a.d_keyin) as d_keyin ")
		        .append(" from lan:serv_dochd a ,lan:serv_docdt b "); 
		        
			if (houseId.trim().length()>0) {	    
			    sql.append(" ,lan:acxlckmd c where c.i_house='"+houseId+"' ")
				  .append(" and c.i_company = a.i_company and c.i_project = a.i_project and c.i_lock = a.i_lock ");
			} else {
			    sql.append(" where 1=1 ");
			}
		    sql.append(" and b.i_docno=a.i_docno and a.f_status='OPN' and a.i_doc_type='J' ")
		       .append(" and b.f_itmstatus='300' ").append(condition)
		        .append(" order by b.i_vendor,a.i_docno ");

				//String oldVendor = "";
			    String d_keyin = "";	
			    String dMM = "";
			    String dYYYY = "";
			    String temp[] = null;
			    String docPdfPath = "";
			    String pdfFileName = "";
			    
				//boolean isRec = false;	                  
				servlog.startLog(sql.toString());
		        rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
				int i=0;
				while (i<maxRow) {
                      if (rs.next()) {
						iDocNo = doString.checkString(rs.getString("i_docno"),""); 
						d_keyin =  doString.checkString(rs.getString("d_keyin"),""); 
						if(d_keyin.length()>0){
						   temp = d_keyin.split("\\-"); //2014-09-06
						   dYYYY = temp[0];
						   dMM = temp[1];
						}
		
						docPdfPath = "";
						pdfFileName = "";
						pdfFileName = "pdf_"+iDocNo+".pdf";
						//System.out.println("pdfFileName="+pdfFileName);
						docPdfPath = Utilizer.getPropValue("IP_HOST_UPLOAD")+Utilizer.getPropValue("PATH_UPLOAD")+"/"+dYYYY+"/"+dMM+"/"+iDocNo+"/"+pdfFileName;
						//System.out.println("docPdfPath2="+docPdfPath);

						rs1 = stmt1.executeQuery("SELECT i_docno FROM lan:serv_chkuplck WHERE i_docno = '"+iDocNo+"'");
						
						//---------------
						//isRec = false;
				   		//isRec = IsImgServDocAtt(conn,iDocNo);
						//---------------
						if (rs1.next() == false) {
                         if (i>=startRow && i<endRow) {

                            String iVendor = doString.checkString(rs.getString("i_vendor"),""); 
                            String iCompany = doString.checkString(rs.getString("i_company"),""); 
                            String iProject = doString.checkString(rs.getString("i_project"),""); 
                            String iLock = doString.checkString(rs.getString("i_lock"),"");         
                            
                            Hashtable cust = common.getCustomerDetails(iCompany,iProject,iLock);
                            String iHouse = doString.checkString((String) cust.get("i_house"),"");
                            //String custName = doString.checkString((String) cust.get("n_customer"),"");      
                            

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
                     
                            //---=========== Get Item in this i_docno , i_vendor ===========---//
                            docList = new ArrayList(); 
                            
                            // i_docno,i_itmjob,i_vendor,i_itmjob_area
                            sql.delete(0,sql.length());
                            sql.append(" select a.n_customer,a.n_cus_tel,a.d_appoint,c.bus_name,d.n_itmjob,b.i_itmjob,b.i_vendor,b.i_itmjob_area,e.d_approve,b.i_seq,b.i_keygen ")
                                  .append(" from lan:serv_dochd a ,lan:serv_docdt b  ")
                                  .append(" left join lan:stpvendr c on c.vend_code=b.i_vendor ")
                                  .append(" left join lan:serv_boq d on d.i_itmjob=b.i_itmjob ")
                                  .append(" left join lan:serv_flow e on e.i_docno=b.i_docno and e.i_vendor=b.i_vendor and e.f_itmstatus='200' ")
                                  .append(" where b.i_docno=a.i_docno and a.f_status='OPN' ")
                                  .append(" and a.i_doc_type='J' and b.f_itmstatus='300' ")
                                  .append(" and a.i_docno='").append(iDocNo).append("' ")
                                  .append(" and b.i_vendor='").append(iVendor).append("' ")
                                  .append(" Order by b.i_seq,b.i_itmjob ");
                                  
                            int itmLine = 0;      
							servlog.startLog(sql.toString());
                            rs1 = stmt1.executeQuery(sql.toString());
							servlog.endLog();
                            while (rs1.next()) {
                                 itmLine++;
                                
                                 i_keygen = "";   
                                 vendorName = "";
						         nCustomer = "";
						         nCustTel = "";
						         iItmJob = ""; 
						         nItmJob = ""; 
						          //----------------------                   			 
                     			  hashDocDT= new Hashtable();
                     			  hashDocDT.put("i_itmjob",doString.checkString(rs1.getString("i_itmjob"),""));
                     			  hashDocDT.put("i_seq",doString.checkString(rs1.getString("i_seq"),""));	
				   				  hashDocDT.put("i_keygen",doString.checkString(rs1.getString("i_keygen"),""));	
				   				  
				   				  //hashDocDT.put("d_keyin",doString.checkString(rs1.getString("d_keyin"),""));	
								  //hashDocDT.put("i_itmjob",doString.checkString(rs1.getString("i_itmjob"),""));
								  hashDocDT.put("i_vendor",doString.checkString(rs1.getString("i_vendor"),""));	
								  hashDocDT.put("i_itmjob_area",doString.checkString(rs1.getString("i_itmjob_area"),""));	
								  //--------------------
								 
                                  vendorName = doString.checkString(doString.DisplayThai(rs1.getString("bus_name")),""); 
	                              nCustomer = doString.checkString(doString.DisplayThai(rs1.getString("n_customer")),""); 
	                              nCustTel = doString.checkString(doString.DisplayThai(rs1.getString("n_cus_tel")),""); 
	                              iItmJob = doString.checkString(rs1.getString("i_itmjob"),""); 
	                              nItmJob = doString.checkString(doString.DisplayThai(rs1.getString("n_itmjob")),""); 
                     			 

	                            String dAppoint = "-";   
								Timestamp tmp = rs1.getTimestamp("d_appoint");
								if (tmp!=null) {
	                               Calendar dApp = Calendar.getInstance();                         
								   dApp.setTime(tmp);     
								   dAppoint = common.getDateFromCalendar(dApp);
								}	                     


	                            dApprove = "-";   
								tmp = rs1.getTimestamp("d_approve");
								if (tmp!=null) {
	                               Calendar dApp = Calendar.getInstance();                         
								   dApp.setTime(tmp);     
								   dApprove = common.getDateFromCalendar(dApp);
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
										          <td width="45%" class="col_name">ผู้รับเหมาซ่อม</td>
										          <td width="7%" class="col_name">แปลง</td>
										          <td width="7%" class="col_name">บ้านเลขที่</td>
										          <td width="10%" class="col_name">วันที่นัดซ่อม</td>
										          <td width="10%" class="col_name">เลขที่ใบแจ้งซ่อม</td>
										          <td width="9%" class="col_name">วันที่ START</td>
										          <!-- <td width="10%" class="col_name">Print รูปภาพ</td> -->
										        </tr>
										        <tr>
										          <td width="2%" class="dotline01" align="center" height="25"><input type="checkbox" name="i_vendor" class="chkVendor"  value="<%=iDocNo+":"+iVendor%>" ></td>
										          <td width="45%" class="dotline01" height="25"><%=vendorName%></td>
										          <td width="7%" class="dotline01" align="center" height="25"><%=iLock%></td>
										          <td width="7%" class="dotline01" align="center" height="25"><%=iHouse%></td>
										          <td width="10%" class="dotline01" align="center" height="25"><%=dAppoint%></td>
										          <td width="10%" class="dotline01" align="center" height="25"><%=iDocNo%></td>
										          <td width="9%" class="dotline01" align="center" height="25"><%=dApprove%></td>
										         <!--  remark by pradoem 2023.02.14
										          <td width="10%" class="dotline" align="center" height="25">
										          <% //if(isRec){ %>
										          <img border="0" src="images/act_printPict.gif" onclick="javascript:printImage('<%//=iDocNo%>');"                                   
										    			onmouseout=nereidFade(this,70,50,5)    
										                  	onmouseover=nereidFade(this,100,50,5)     
										                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">
										            <%//}else{
										            		//out.println("&nbsp;ไม่พบรูปภาพ");
										            //} %>     	
										          </td>
										          -->
										        </tr>
										        <tr>
										          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
										          <td width="98%" class="dotline ; item" colspan="7" height="25"><img border="0" src="images/i_arrow2.gif" align="absmiddle" width="11" height="11">&nbsp;
										            ชื่อรายการซ่อม</td>
										        </tr>							        
								        <%                                
								    } // end if check first line 

									//---============== Print Item List ================----//
					                %>
							        <tr>
							          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
							          <td width="98%" class="dotline" colspan="7" style="padding-left:20px" height="25"><%=(itmLine)+". "+nItmJob%></td>
							        </tr>				                
					                <%
					                
					                //===================
					                docList.add(hashDocDT);
					                //===================
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

								<%-- ===================================  Attach File ================================================ --%>
								<br style="font-size:5pt">
								 <table border="0" width="100%" cellspacing="0" cellpadding="0">
								      <tr>
									  <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
									  <td class="item_tab2" width="180">รูปภาพงานซ่อม(ขนาดไม่เกิน 500 K)</td>
								      <td class="item_tab3"></td>
								      <td class="textgray">&nbsp;
								      <span style="color:rgb(0,120,255)">
								     	 <input type="checkbox" name="chkViewFollow" value="1" onClick="JavaScript:doViewFollowDesc(this.checked,'<%=i%>');">แสดงรูปภาพ
								      </span>
								           &nbsp;
									      <nobr>
											&nbsp;
											<a href="#"><input type="button" name="btnAttach" value="แนบไฟล์ .PDF <%=iDocNo%>" 
											onclick="attachFiles('<%=dMM %>','<%=dYYYY%>','<%=iDocNo %>');" ></a> 
											&nbsp;
											<%
											
											if(getHttpResponseCode(docPdfPath)==200){
											%>
											   <img border="0" src="images/attach-file_90371.png" align="absmiddle" width="20" height="20">
											   <a href="<%=docPdfPath%>" target="_blank"><%=pdfFileName%></a>
											   &nbsp;
											   <a href="javascript:delFile('<%=iDocNo%>','<%=dMM %>','<%=dYYYY %>','<%=pdfFileName%>');" ><img border="0" src="images/trash-9-16.png" align="absmiddle" width="16" height="16">ลบไฟล์ Attach</a>

											<%}
											%>
										 </nobr>
								      </td>
							          </tr>
								 </table>									
												<table border="0" width="100%" cellspacing="0" cellpadding="0">
												  <tr>
												    <td width="5" valign="top"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
												    <td class="frmTop">&nbsp;</td>
												    <td width="5" valign="top" align="right"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
												  </tr>
												</table>
									
									<table border="0" width="100%" cellspacing="0" cellpadding="0" style="display:none"  id="<%="show_"+i%>">
									  <tr>
									    				<td width="100%" class="frmLR" align="center">
														<table border="0" width="100%" cellspacing="0" cellpadding="0">
														<%	 
																line = 0;
																//int seq = 1;
																//String urlImg =  "";//request.getContextPath()+"/pictures/"+iDocNo+"/";
																String bgColor = "";
														
																String keyFile = "";
																String yyyyMMdd =  GetDateKeyinYYYYMMDD(conn,iDocNo);
																String []tmp = yyyyMMdd.split("\\-"); //2012-08-15
														        String yyyy = tmp[0];
														        String month = tmp[1];
														        
														        String imagesIdUrl = "";
														        
															    //String pathUrl = pathUrlX+"/"+yyyy+"/"+month+"/"+iDocNo+"/";
															    String pathUrl = Utilizer.getPropValue("DOMAIN_NAME")+Utilizer.getPropValue("PATH_UPLOAD")+"/"+yyyy+"/"+month+"/"+iDocNo+"/";	
																String pathTmp = Utilizer.getPropValue("IP_HOST_UPLOAD")+Utilizer.getPropValue("PATH_UPLOAD")+yyyy+"/"+month+"/"+iDocNo+"/";
																//for (int i=0;i<docList.size();i++) {
															    for (int x=0;x<docList.size();x++) {
														
																				 line++;
																				 bgColor = "#e8f2fe";
																				 if(line%2==0){
																				  bgColor= "#ffffff";
																				 }
																				  hashDocDT  = (Hashtable) docList.get(x);		
															                     //docdt  = (Hashtable) jobList.elementAt(i);    

														                         keyFile   = iDocNo+"_"+hashDocDT.get("i_keygen").toString()+"_"+hashDocDT.get("i_vendor").toString()+"_"+hashDocDT.get("i_itmjob_area").toString()+"_"+line;
																				 //System.out.println("keyFile = "+keyFile);
																				// System.out.println("======================== print file line ================================");
																				//======================== print file line 1 ================================//
																				%>
																				  <tr bgcolor="<%=bgColor%>">
																					<td class="item" height="22" width="5%"><nobr>รายการที่ <%=line%> : </nobr></td>	
																					<td class="item" height="22" width="20%"><nobr>รูปภาพก่อนซ่อม1 : 
																					<%
																					imagesIdUrl = pathUrl+"/"+keyFile+"_a.jpg";
																					
																					//System.out.println("imagesIdUrl a= "+imagesIdUrl);
																					int resCode = getHttpResponseCode(pathTmp+keyFile+"_a.jpg");
																					if(resCode==200) {
																					    //(docId,mm,yyyy,imgId)
																						%>
																							<a href="<%=imagesIdUrl%>" target="_blank"><img src="<%=imagesIdUrl%>" width="25" height="20" border="0"></a> &nbsp; &nbsp; 							
																						<%								
																					}else{
																						out.println("ไม่มีรูปภาพ");
																					}
																					 %>
																					</nobr></td>
																					<td class="item" height="22" width="20%"><nobr>รูปภาพก่อนซ่อม2 : 
																					<%
																					imagesIdUrl = pathUrl+"/"+keyFile+"_b.jpg";
																					//System.out.println("imagesIdUrl b= "+imagesIdUrl);
																					resCode = getHttpResponseCode(pathTmp+keyFile+"_b.jpg");
																					if(resCode==200) {
																						%>
																							<a href="<%=imagesIdUrl%>" target="_blank"><img src="<%=imagesIdUrl%>" width="25" height="20" border="0"></a> &nbsp; &nbsp; 							
																						<%								
																					}else{
																						out.println("ไม่มีรูปภาพ");
																					}
																					 %>							
																					</nobr></td>
																				  </tr>					
																				<%
																				//System.out.println("###################################################");				 
															    }
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
																			<br style="font-size:5pt">
																			
																			<%-- ===================================  Attach File ================================================ --%>  												
													
												<%
										        
					 					         line++;                         
				                         } // end if check row
				                         
			                         if (i>endRow) break;     
									 i++;
									}
									rs1.close();
								rs1=null;							 
		                      } //end if check rs
		                } // end for
	
				//-----================ If No Data , Print Blank Table =================----//
				if (line<1) {
				 %>	
					<table border="0" width="100%" cellspacing="0" cellpadding="0">
					  <tr>
					    <td width="100%" class="frmL">
					    
					      <table border="0" width="100%" cellspacing="0" cellpadding="0">
					        <tr>
					          <td width="2%" class="col_name" height="25">&nbsp;</td>
					          <td width="45%" class="col_name">ผู้รับเหมาซ่อม</td>
					          <td width="7%" class="col_name">แปลง</td>
					          <td width="7%" class="col_name">บ้านเลขที่</td>
					          <td width="10%" class="col_name">วันที่นัดซ่อม</td>
					          <td width="10%" class="col_name">เลขที่ใบแจ้งซ่อม</td>
					          <td width="9%" class="col_name">วันที่ START</td>
					        </tr>
					        <tr>
					          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
					          <td width="98%" class="dotline" colspan="6" style="padding-left:20px" height="25">&nbsp;</td>
					        </tr>
					        <tr>
					          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
					          <td width="98%" class="dotline" colspan="6" style="padding-left:20px" height="25">&nbsp;</td>
					        </tr>
					        <tr>
					          <td width="2%" align="center" class="solidline01" height="25">&nbsp;</td>
					          <td width="98%" class="dotline" colspan="6" style="padding-left:20px" height="25">&nbsp;</td>
					        </tr>
					        <tr>
					          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
					          <td width="98%" class="dotline" colspan="6" style="padding-left:20px" height="25">&nbsp;</td>
					        </tr>
					        <tr>
					          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
					          <td width="98%" class="dotline" colspan="6" style="padding-left:20px" height="25">&nbsp;</td>
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

			  <%
			} // end if check no data

        %>                  

<br style="font-size:3pt">


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr class="gray">
          <td width="100%" align="right"><%=pageLink%></td>
        </tr>
      </table>


<br style="font-size:10pt">



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">

            <a href="#" onclick="completeTask();"><img border="0" src="images/act_complete.gif"                                   
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
	
</BODY>
    
</HTML>  
<%       System.out.println("---SERV_CompTask_List.jsp--- " );
	} catch (Exception e) {
		System.out.println("!!! ERROR SERV_CompTask_List.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (rs1 != null) rs.close();
			if (stmt != null) stmt.close();
			if (stmt1 != null) stmt.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>