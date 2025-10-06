<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>

<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%!
/**
 * Modify by : pradoem@lh.co.th 
 * date : 2021.06.23
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
 %>

<%

/*
System.out.println("*******************************************");
String ParameterNames = "";
for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
	ParameterNames = (String)e.nextElement();
	System.out.println(ParameterNames + " = "+request.getParameter(ParameterNames));
}
System.out.println("*******************************************");
*/
	
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_Contractor_List.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

	doString str = new doString();
    String userWho = user.getUserWho();
    
    //----============ Declare Variables for input data ===========----//
    String dPayment = doString.checkString(request.getParameter("d_payment"),"");
    String iVendor = doString.checkString(request.getParameter("i_vendor"),"");
    String dPay = "";

    if (dPayment.length()==0) {
       //---========== If no data from parameter , get from session instead =============----// 
       dPayment = doString.checkString((String) session.getAttribute("sess_dPayment"),"");
       dPay = doString.checkString((String) session.getAttribute("sess_dPay"),"");
    } else {
       //---========== If receive from parameter , set to session ============----//
       session.setAttribute("sess_dPayment",dPayment);
    }
    if (dPay.length()==0 && dPayment.length()==10) {   
       //---========== First Time to use , convert format ================----//     
       int year = Integer.parseInt(dPayment.substring(6,10));
       if (year>2400) year -= 543;
       dPay = year+"-"+dPayment.substring(3,5)+"-"+dPayment.substring(0,2); 
       session.setAttribute("sess_dPay",dPay);
    }
    
    
    //---========== If No i_vendor and this login is vendor , use i_vendor from login =============----//
    if (user.getUserWho().equalsIgnoreCase(Constants.PERMISSION_VENDOR)) {
        iVendor = user.getEmpId(); 
    }

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
        

        //---====================== Generate Serrch Condition ===========================---//
        if (selProj.trim().length()>=6 && !selProj.equalsIgnoreCase("ALL")) {
           //condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
		   condition = " and a.i_company='"+(selProj.substring(0,2))+"' and a.i_project='"+(selProj.substring(3,6))+"' ";
        }
        
	   //if (selProj.trim().length()<=0) {
	   if(selProj.equalsIgnoreCase("ALL")){
		
		   String projList = common.getProjectListByUserId(user.getUserID());
		   if (projList.length()>0) {
			   //condition += " and substr(a.i_docno,1,6) in ("+projList+") ";

			   //================== modified to used index field =====================//
				if (projList.trim().length()>0) {
					String projCondition = "";
					StringTokenizer plist = new StringTokenizer(projList,",");
					String proj = "";
					String icom = "";
					String iproj = "";

					while (plist.hasMoreTokens()) {
						proj = str.replace(plist.nextToken(),"'","").trim();
						if (proj.length()>=6) {
							icom = proj.substring(0,2);
							iproj = proj.substring(3,6);
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
           condition += " and b.i_house='"+houseId+"' ";
        }*/
        if (lock.trim().length()>0) {
           condition += " and a.i_lock='"+lock+"' ";
        }                
        if (iVendor.trim().length()>0) {
           condition += " and b.i_vendor='"+iVendor+"' ";
        }

        condition += " and b.d_payment='"+dPay+"' ";        
 	   //---=========================================================================----//   


        
        //----====================== Get PAYMENT Max Row ==============================-----//
        int maxRow = 0;
        
        //Fix bug by pradoem 2021.06.23
        if(!selProj.equals("")){ 
	        sql.delete(0,sql.length());
	        sql.append(" select count(*) from serv_payment b,serv_dochd a ");
	          //    .append(" b.i_docno=a.i_docno and a.f_status='OPN' ")
			if (houseId.trim().length()>0) {	    
				sql.append(" ,lan:acxlckmd c where c.i_house='"+houseId+"' ")
				  .append(" and c.i_company = a.i_company and c.i_project = a.i_project and c.i_lock = a.i_lock ")
				  .append(" and b.i_docno=a.i_docno and a.f_status='OPN' ");
			} else {
				sql.append(" where b.i_docno=a.i_docno and a.f_status='OPN' ");
			}		
	        sql.append(" and b.f_itmstatus='400' ").append(condition)                   
	             .append(" group by a.i_docno ");
			servlog.startLog(sql.toString());
	        rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
	        while (rs.next()) {        
	           maxRow++;
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
	   if (displayLine<Constants.SERV_CONTRACTORLIST_LINE) displayLine = Constants.SERV_CONTRACTORLIST_LINE;      
	   
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
<TITLE>Contractor - ผู้รับเหมาส่งงาน</TITLE>
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

  function searchDocHD() {
     onPleaseWait();
     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Contractor_List.jsp";
     document.forms[0].submit();  
  }

  function changePage(page) {
     onPleaseWait();
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Contractor_List.jsp";
     document.forms[0].submit();
  }   

//-->
</script>



<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">


<FORM METHOD="POST" ACTION="">

<input type="hidden" name="now_page" value="<%=nowPage%>">
<input type="hidden" name="d_payment" value="<%=dPayment%>">

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
            Contractor : ผู้รับเหมาส่งงาน</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดการแจ้งซ่อม</td>
                <td class="item_tab3"></td>
                <td>&nbsp;วันที่จ่าย&nbsp; <%=dPayment%></td>                
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
    
    
  <%
     String jspLink = "";
     if (user.getUserWho().equalsIgnoreCase(Constants.PERMISSION_VENDOR)) {
         jspLink = "SERV_Contractor_Conf.jsp?load=yes&i_vendor="+iVendor;
         %>
            <input type="hidden" name="i_vendor" value="<%=iVendor%>">
			<table border="0" width="100%" cellspacing="0" cellpadding="0">
			  <tr>
			    <td class="item ; dotline01" height="22" width="15%">ผู้รับเหมาซ่อม
			      :</td>
			    <td height="22" width="39%" class="dotline01"><%=iVendor+" "+doString.DisplayThai(user.getEmpName())%></td>
			    <td height="22" class="item ; dotline01" width="14%">&nbsp;</td>
			    <td height="22" width="32%" class="dotline01">&nbsp;</td>
			  </tr>         
			  <tr>
			    <td class="item ; dotline01" height="22" width="15%">โครงการ :</td>
			    <td height="22" width="39%" class="dotline01">
			     <%=genProjectListboxByUserId(conn,user.getUserID(),"sel_project",selProj," class='box' style='width:250px' onchange='changePage(1);' ",true)%>  
			    <%//=common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:250px' onchange='changePage(1);' ",true)%>       
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
         <%
     } else {
          jspLink = "SERV_Contractor_Conf_Disp.jsp?mode=view&i_vendor="+iVendor;
     	  %>
			<table border="0" width="100%" cellspacing="0" cellpadding="0">
			  <tr>
			    <td class="item ; dotline01" height="22" width="15%">โครงการ :</td> 
			    <td height="22" width="39%" class="dotline01">
			    <%=genProjectListboxByUserId(conn,user.getUserID(),"sel_project",selProj," class='box' style='width:250px' onchange='changePage(1);' ",true)%>  			    
			    <%//=common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:250px' onchange='changePage(1);' ",true)%>
			    </td>
			    <td height="22" class="item ; dotline01" width="14%">&nbsp;</td>
			    <td height="22" width="32%" class="dotline01">&nbsp;</td>
			  </tr>         
			  <tr>
			    <td class="item ; dotline01" height="22" width="15%">ผู้รับเหมาซ่อม :</td>
			    <td height="22" width="39%" class="dotline01">
			    <%=common.genVendorList("i_vendor",selProj,iVendor," class='box' style='width:250px' onchange='changePage(1);' ")%>       
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
     	  <%
     }
  %>


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





<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL">
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="17%" class="col_name">เลขที่ใบแจ้งซ่อม</td>
          <td width="7%" class="col_name">แปลง</td>
          <td width="8%" class="col_name">บ้านเลขที่</td>
          <td width="12%" class="col_name">วันที่นัดซ่อม</td>
          <td width="41%" class="col_name">ชื่อผู้แจ้ง/ลูกค้า</td>
          <td width="15%" class="col_name">สถานะของงาน</td>
        </tr>
        
        <%
        
		     //----================== Select Data from SERV_DOCHD ================----//   
		        int line = 0;		     
		        sql.delete(0,sql.length());
		        sql.append("select first ").append(endRow).append(" distinct a.i_docno ")
		              .append(" from serv_payment b,serv_dochd a ");
				if (houseId.trim().length()>0) {	    
					sql.append(" ,lan:acxlckmd c where c.i_house='"+houseId+"' ")
					  .append(" and c.i_company = a.i_company and c.i_project = a.i_project and c.i_lock = a.i_lock ");
				} else {
					sql.append(" where 1=1 ");
				}
                 sql.append(" and b.i_docno=a.i_docno and a.f_status='OPN' ")
                      .append(" and b.f_itmstatus='400' ").append(condition)
                      .append(" order by a.i_docno");
                                     
                      
				Hashtable tmpHeader = new Hashtable();
				Hashtable tmpCust = new Hashtable();
				String iDocNo = "";
				String nCustomer = "";
				String iLock = "";
				String iCompany = "";
				String iProject = "";
				String dAppoint = "";
				String iHouse = "";
				String custName = "";
				String custTel = "";
				String status = "";
				servlog.startLog(sql.toString());
		        rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
		        for (int i=0;i<maxRow;i++) { 
                      if (rs.next()) {
                         if (i>=startRow && i<=endRow) {
                            //------ Data is in this page , display -----//
				            iDocNo = doString.checkString(rs.getString("i_docno"),"");
				            
					         //----======================== Find DocHD Data =============================----//				            
							 tmpHeader = common.getDocHeaderDetails(iDocNo);
					         nCustomer = doString.DisplayThai(doString.checkString((String) tmpHeader.get("n_customer"),""));
					         iLock = doString.checkString((String) tmpHeader.get("i_lock"),"");
					         iCompany = doString.checkString((String) tmpHeader.get("i_company"),"");
					         iProject = doString.checkString((String) tmpHeader.get("i_project"),"");					         
							 dAppoint = doString.checkString((String) tmpHeader.get("d_appoint"),"-");


							//----======================= Get Customer Details ===========================----//
							tmpCust = common.getCustomerDetails(iCompany,iProject,iLock);
						    iHouse = doString.checkString((String) tmpCust.get("i_house"),"");
							custName = doString.DisplayThai(doString.checkString((String) tmpCust.get("n_customer"),""));
							custTel = doString.checkString((String) tmpCust.get("n_cust_tel"),"");
							
							
							status = doString.DisplayThai(doString.checkString(common.getContractorStatus(iDocNo,iVendor),"-"));
						            
					        %>
					        <tr>
					          <td width="17%" align="center" class="dotline"><a href="<%=jspLink%>&i_docno=<%=iDocNo%>"><%=iDocNo%></a>&nbsp;</td>
					          <td width="7%" class="dotline" align="center"><%=iLock%>&nbsp;</td>
					          <td width="8%" class="dotline" align="center"><%=iHouse%>&nbsp;</td>
					          <td width="12%" align="center" class="dotline"><%=dAppoint%>&nbsp;</td>
					          <td width="41%" class="dotline ; item"><%=common.joinContactAndOwner(nCustomer,custName)%>&nbsp;</td>
					          <td width="15%" align="center" class="dotline"><%=status%>&nbsp;</td>
					        </tr>					        
					        <%
					        
 					         line++;                         
                         } // end if check row
                         
                         if (i>endRow) break;                         
                      } //end if check rs
                } // end for
                
	           while (line<displayLine) {
	               line++;
	                %>
			        <tr>
			          <td width="17%" align="center" class="dotline">&nbsp;</td>
			          <td width="7%" class="dotline" align="center">&nbsp;</td>
			          <td width="8%" class="dotline" align="center">&nbsp;</td>
			          <td width="12%" align="center" class="dotline">&nbsp;</td>
			          <td width="41%" class="dotline ; item">&nbsp;</td>
			          <td width="15%" align="center" class="dotline">&nbsp;</td>
			        </tr>        
	                <%               
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
		System.out.println("ERROR SERV_Contractor_List.jsp : " + e.getMessage());
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