<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%!
   public String ToThaiDateFormat(String date){
       if(!date.equals("")){
	        String time = date.substring(10);
			String yy = date.substring(0,10);
			String delimeter = "-";
			String [] temp = yy.split(delimeter);	
		 return temp[2]+"/"+temp[1]+"/"+ (Integer.parseInt(temp [0])+543)+time;
		}else{
		 return date;
		}
   }
 %>
<%
/************************************/
// create by pradoem
// date : 2012-07-26
// decription : List Zero Defection List
// version :1.0 
/************************************/
	String sessionId = user.getsessionId();
	String userId = user.getUserID();
	String jName = "ESERV_ZeroDefect_List.jsp";
	ServLog servlog = new ServLog(sessionId, userId, jName);
    doString str = new doString();
   //******************************* Declare Variables for input data ********************************//
   String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase(); 
   
   /*if  (selProj.length()==0) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       session.setAttribute("sess_sel_proj",selProj);
   }*/
   
//****************************************
//System.out.println("********************* All param reqeust **********************");
//String ParameterNames = "";
//for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
//	ParameterNames = (String)e.nextElement();
//	System.out.println(ParameterNames + " = "+request.getParameter(ParameterNames));
//}
//System.out.println("**************** End ***************************");
//****************************************   
   
   String docNo = doString.checkString(request.getParameter("i_docno"),"").toUpperCase();
   String houseId = doString.checkString(request.getParameter("i_house"),"").toUpperCase();
   String lock = doString.checkString(request.getParameter("i_lock"),"").toUpperCase();
   String er_code = request.getParameter("er_code")==null?"":request.getParameter("er_code");
   String condition = "";		       
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	
	Statement stmt2 = null;
	ResultSet rs2 = null;
	SERV_CommonData common = null;
	try {	
        //************************** Initialize Variable **************************//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();   
		stmt2 = conn.createStatement();  
		common = new SERV_CommonData(conn);     
        //***************************************************************************//   

        //************************** Generate Serrch Condition **************************//
        if (selProj.trim().length()>=6 && !selProj.equalsIgnoreCase("ALL")) {
           //condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
		   condition = " and a.i_company='"+(selProj.substring(0,2))+"' and a.i_project='"+(selProj.substring(3,6))+"' ";
        }
        
		if (selProj.trim().length()<=0) {
		   String projList = common.getProjectListByUserId(user.getUserID());
		   //System.out.println("--Test projList :"+projList);
		   if (projList.length()>0) {
				//System.out.println("--Test test :"+projList);
			   //condition += " and substr(a.i_docno,1,6) in ("+projList+") ";
			   //************************** modified to used index field **************************//
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
				//****************************************************//
		   } 
		   
		  /* else {
				sql.delete(0,sql.length());
				sql.append(" select count(*) from lan:serv_staffqc  where user_id='").append(user.getUserID()).append("' and i_project='ALL' ");
				boolean isCheckALL = false; 
				servlog.startLog(sql.toString());
				rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
				if (rs.next()) {
				   // checkAllPermission = rs.getInt(1);
				   isCheckALL = true;
				}
				rs.close();
				
				if (isCheckALL) { 
				  	selProj = "ALL";
			     }
		   }*/
		}     
        if (docNo.trim().length()>0) {
           condition += " and a.i_docno='"+docNo+"' ";
        }

        if (lock.trim().length()>0) {
           condition += " and a.i_lock='"+lock+"' ";
        }                
       
        //************************** Get DOCHD Max Row **************************//        
       // System.out.println("--Test condition :"+condition);
        // System.out.println("--Test selProj :"+selProj);
        int maxRow = 0;
        
        if(selProj.equals("LH:ALL") || selProj.equals("ALL") ) {
			sql.delete(0,sql.length());
	        sql.append("select count(*) cnt from lan:serv_zerohd a ")
	              .append(" where a.f_status='OPN' ");
		 }else{
	        sql.delete(0,sql.length());
	        sql.append("select count(*) cnt from lan:serv_zerohd a ")
	              .append(" where a.f_status='OPN' ").append(condition);
			servlog.startLog(sql.toString());
		}
        rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
        if (rs.next()) {        
           maxRow = rs.getInt("cnt");  
        }
        rs.close();
	   //**********************************************************************************************//                
	   //************************** Generate Display Customize and Page Link **************************//
	   String displayType = doString.checkString(request.getParameter("display_type"),"");    
	   int displayLine = Integer.parseInt(doString.checkString(request.getParameter("display_line"),"0"));
	   int nowPage = Integer.parseInt(doString.checkString(request.getParameter("now_page"),"1"));
	   String criteria = doString.checkString(request.getParameter("criteria"),""); 
	   if (displayType.equalsIgnoreCase("A")) {
	      displayLine = maxRow;
	      nowPage = 1;
	   }
	 //remark by pradoem 2012-03-13
	 if (displayLine<Constants.SERV_OPENJOBLIST_LINE) displayLine = Constants.SERV_OPENJOBLIST_LINE;         
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
	 //***********************************************************************************************//                
%>
<HTML>
<HEAD>
<TITLE>Confirm การตรวจ Zero Defect </TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<style >
.fg_style1 { mso-number-format:"\@";}
.col_name1{ 	font-size: 8.0pt ; color: rgb(0,50,200) ; /*text-align: right ; */ 
			/*background-image: url(images/col_bg1.gif) ; background-repeat : repeat-x ;*/
			border-right:1px solid rgb(135,185,247) ; border-bottom:1px solid rgb(135,185,247) ; 	}

.box2 {  font-family: Tohama,Arial,sans-serif; font-size:10.1pt; font-weight:normal;
	padding-top: 1px; padding-right: 1px; padding-bottom: 1px; padding-left: 1px; 
	 color:#165396; background-color: white; border: 1px #BEDCFF solid ; 
}			
</style>
<script language="javascript" src="script_fx.js"></script>

<script type='text/javascript' src='jquery/jquery-1.11.3.min.js'></script>
<script type='text/javascript' src='jquery/loadImg.js'></script>

<script language="javascript">
<!--
function formLoadErrorCode(){
	//err_code  E01 = invalidate ,E02= Find not found record
	var err_code = "<%=er_code%>";
	if(err_code != ""){
		if(err_code=='E01'){
			alert("ไม่พบรายการตามที่เลือกเลขที่เอกสาร.");
		   return;
		}
	}
}
	
  function searchDocHD() {
   if(document.forms[0].sel_project.value==""){
    	alert('กรุณาเลือกโครงการด้วย.');
    	document.forms[0].sel_project.focus();
    	document.forms[0].sel_project.select();
    	return;
   }else{
     onPleaseWait();
     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_ZeroDefect_List.jsp";
     document.forms[0].submit();  
     }
  }
  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_ZeroDefect_List.jsp";
     document.forms[0].submit();
  } 
   function doOpenJob(docId) {
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_ZeroDefectServlet?cmd=load&i_docno="+docId;
     document.forms[0].submit();
  }    
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
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="formLoadErrorCode();">


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


<FORM METHOD="POST" ACTION="">
<input type="hidden" name="now_page" value="<%=nowPage%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" > 
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">
          &nbsp;Zero Defect List</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>
<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">Confirm การตรวจ Zero Defect</td>
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
		    <select name="sel_project" class="box2" style='width:200' size='1' > 
			<option value="">------ กรุณาเลือกโครงการ ------</option>	
			<%
			 String sel = "";
			 if(selProj.equals("LH:ALL")){
			     sel = "selected";
			}else{sel="";}
			
			 %>
			<option value='LH:ALL' <%=sel %>>--- เลือกทุกโครงการ(ALL) ---</option> 
					<%
						 boolean allProj = false;
						//---================ Normal User ===============----//
						sql.delete(0,sql.length());	
						 sql.append(" select distinct a.i_company,a.i_project,b.n_project from lan:serv_staffqc a  ")
							   .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
							   .append(" where a.user_id='").append(user.getUserID()).append("' ")
							   .append(" order by a.i_company , a.i_project ");
						 servlog.startLog(sql.toString());
						 rs = stmt.executeQuery(sql.toString());
						 servlog.endLog();
						 String selectd = "";
						 while (rs.next()) {
							 String comId = doString.checkString(rs.getString("i_company"),"");
							 String projId = doString.checkString(rs.getString("i_project"),"");
							 String nProj = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
							if (projId.equalsIgnoreCase("ALL")) {
								allProj = true;
								break;
							 }
							 if(selProj.equals(comId+":"+projId)){
							 	selectd="selected";
							 }else{
							    selectd = "";
							 }
							//if (!selProj.contains(comId+":"+projId)) {
								%><option value='<%=comId+":"+projId%>' <%=selectd %>><%="["+comId+"-"+projId+"] - "+nProj%></option><%
							//}
						 }
						 rs.close();
						//---============== For user who have ALL Project ===============----//
						if (allProj) {
							 int year = Calendar.getInstance().get(Calendar.YEAR);
							 if (year<2400) year += 543;
							 int pYear = year-1;
							sql.delete(0,sql.length());	
							 sql.append(" select distinct a.i_company,a.i_project,b.n_project from lan:acsbudgh a  ")
								   .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
								   .append(" where a.d_year in ( '").append(year).append("' , '").append(pYear).append("' ) ")
								   .append(" and a.i_budg_type in (9)  ")
								   .append(" order by a.i_company , a.i_project ");
							 servlog.startLog(sql.toString());
							 rs = stmt.executeQuery(sql.toString());
							 servlog.endLog();
							 while (rs.next()) {
								 String comId = doString.checkString(rs.getString("i_company"),"");
								 String projId = doString.checkString(rs.getString("i_project"),"");
								 String nProj = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
								//if (projId.equalsIgnoreCase("ALL")) {						
							    // allProj = true;
								//	 break;
								// }
								if(selProj.equals(comId+":"+projId)){
								 	selectd="selected";
								 }else{
								    selectd = "";
								 }
								 //if (projList.size()<=0 || !projList.contains(comId+":"+projId)) {
								 %><option value='<%=comId+":"+projId%>'  <%=selectd %>><%="["+comId+"-"+projId+"] - "+nProj%></option><%
								 //}
							 }
							 rs.close();
						}
					%>
				 </select>     
		    </td>
		    <td height="22" class="item ; dotline01" width="14%">เลขที่เอกสาร :</td>
		    <td height="22" width="32%" class="dotline01"><input type="text" name="i_docno" class="box" style="width:100px" value="<%=docNo%>"></td>
		  </tr>
		  <tr>
		    <td class="item ; dotline01" height="22" width="15%">บ้านเลขที่ :</td>
		    <td height="22" width="39%" class="dotline01"><input type="text" name="i_house" class="box" style="width:100px" value="<%=houseId%>"></td>
		    <td height="22" class="item ; dotline01" width="14%">แปลง :</td>
		    <td height="22" width="32%" class="dotline01"> <input type="text" name="i_lock" class="box" style="width:100px" value="<%=lock%>">&nbsp;&nbsp;&nbsp;&nbsp;
		      <a href="javascript:searchDocHD();" ><img border="0" src="images/i_search.gif" align="absmiddle" width="20" height="20"></a> </td>
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
    if(!selProj.equals("")){
    			boolean isCheckALL = false; 
   				sql.delete(0,sql.length());
				sql.append(" select * from lan:serv_staffqc  where user_id='").append(user.getUserID()).append("' and i_project='ALL' ");
				//System.out.println("--->SQL check admin :"+sql.toString());
				servlog.startLog(sql.toString());
				rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
				if(rs.next()) {
				   isCheckALL = true;
				}
				rs.close();
				//if (isCheckALL) { //  	selProj = "ALL";// }	
%>	
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="160">รายการซ่อม</td>
                <td class="item_tab3"></td>
                <td>&nbsp;<input type="radio" value="L" checked name="display_type" <%=(displayType.equalsIgnoreCase("L") ? "checked" : "")%>>แสดงจำนวนรายการต่อหน้า&nbsp;
                  <input type="text" name="display_line" class="boxC" style="width:50px" value="<%=displayLine%>">
                  &nbsp; รายการ&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" value="A" name="display_type" <%=(displayType.equalsIgnoreCase("A") ? "checked" : "")%>> แสดงรายการทั้งหมด&nbsp;&nbsp;&nbsp;&nbsp;
                  <a href="javascript:changePage(1);"><img border="0" src="images/bu_R.gif" align="absmiddle" style="cursor:hand" width="16" height="16"></a>
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
			String iDocNo = "";
			String iLock = "";
			String iHouse = "";
			String nCustomer = "";
			String nCustTel = "";					
			String dKayin = "";
		    int line = 0;		
		    	    		    
		  //  System.out.println("--->SQL test:"+condition); 
		   // System.out.println("--->SQL selProj:"+selProj); 
		   // System.out.println("--->isCheckALL:"+isCheckALL); 
		   
		    if(isCheckALL) {
		    	if(selProj.equals("LH:ALL")){
		    		//case permission is admin && select project all
		    		sql.delete(0,sql.length());
			        sql.append("select first ").append(endRow).append(" a.* from lan:serv_zerohd a where a.f_status='OPN' ");
			       // System.out.println("-->Admin SQL ALL:"+sql.toString());  
		    	}else{
		    		//case admin & select project
		    		sql.delete(0,sql.length());
			        sql.append("select first ").append(endRow).append(" a.* from lan:serv_zerohd a where a.f_status='OPN' ")
			         .append(condition);
			          //System.out.println("-->Admin By condition:"+sql.toString());  	
		    	}
		    }else{
		    	if(selProj.equals("LH:ALL")){
		    			//case user and select project  all
						//System.out.println("Test test test");    	
						sql.delete(0,sql.length());
						sql.append(" select user_id,i_company,i_project  from lan:serv_staffqc  where user_id='").append(user.getUserID()).append("' order by 1,2,3 ");
						//System.out.println("--->SQL User all project:"+sql.toString());			
						rs2 = stmt2.executeQuery(sql.toString());
						
						//*********SQL for fectching Data
						sql.delete(0,sql.length());
						sql.append(" select b.i_docno,b.i_company,b.i_project,b.i_lock,b.d_close_law,b.d_keyin,b.d_submit,b.i_employ_submit,b.f_status,b.i_house,b.n_customer,b.n_cus_tel")
						.append(" from lan:serv_zerohd b where b.f_status='OPN'   ");
						//********************************

						StringBuffer sqlBuf = new StringBuffer();
						sqlBuf.delete(0,sqlBuf.length());
						sqlBuf.append(" AND(  ");
						while(rs2.next()){
							sqlBuf.append("( b.i_company ='").append(doString.checkString(rs2.getString("i_company"),"")).append("' ");
							sqlBuf.append(" and b.i_project ='").append(doString.checkString(rs2.getString("i_project"),"")).append("' ) or ");
						}
						rs2.close();
						//System.out.println("Test:"+sqlBuf.toString().lastIndexOf("or"));
						String temp = sqlBuf.toString().substring(0,sqlBuf.toString().lastIndexOf("or")-1);
						sql.append(temp+")");
						//System.out.println("SQL case user and select project  all :"+sql.toString());   
					//i_docno,i_company,i_project,i_lock,d_close_law,d_keyin,d_submit,i_employ_submit,f_status,i_house,n_customer,n_cus_tel			
		    	}else{
		    		//case user and select by project  etc
		    		sql.delete(0,sql.length());
				    sql.append("select first ").append(endRow).append(" a.* from lan:serv_staffqc b,lan:serv_zerohd a  ")
				              .append(" where a.f_status='OPN' ")
	                          .append(" and b.user_id = '"+userId+"' and b.i_company = a.i_company ")
	                          .append(" and b.i_project = a.i_project ")
	                          .append(condition)
				              .append(" order by a.i_docno ");
						     servlog.startLog(sql.toString());
						   //  System.out.println("SQL case user and select by project  etc :"+sql.toString());        
		    	}
     	    }
		   // System.out.println("<<<----Final query :"+sql.toString()); 
		    rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
 %>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL"> 
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="14%" class="col_name">เลขที่เอกสาร</td>
          <td width="7%" class="col_name">แปลง</td>
          <td width="8%" class="col_name">บ้านเลขที่</td>
          <td width="16%" class="col_name">วันเวลาที่แจ้ง</td>
          <td width="39%" class="col_name">ชื่อผู้แจ้ง / ลูกค้า</td>
          <td width="16%" class="col_name">โทรศัพท์ติดต่อ</td>
        </tr>
			<%
		        for (int i=0;i<maxRow;i++) { 
                      if (rs.next()) {
                         if (i>=startRow && i<=endRow) {
	                            //------ Data is in this page , display -----//
					            iDocNo = doString.checkString(rs.getString("i_docno"),"");
					            iLock = doString.checkString(rs.getString("i_lock"),"");
					     		dKayin =  doString.checkString(rs.getString("d_keyin"),"");
					            iHouse = doString.checkString(rs.getString("i_house"),"");				     
					            nCustomer = doString.checkString(doString.DisplayThai(rs.getString("n_customer")),"");
					            nCustTel = doString.checkString(doString.DisplayThai(rs.getString("n_cus_tel")),"");
					        %>
					        <tr>
					          <td width="14%" align="center" class="dotline"><a href="javascript:doOpenJob('<%=iDocNo%>');"><%=iDocNo%></a></td>
					          <td width="7%" class="dotline ; col_name1" align="center"><%=iLock%>&nbsp;</td>
					          <td width="8%" class="dotline" align="center">&nbsp;<%=iHouse%></td>
					          <td width="16%" align="center" class="dotline"><%=ToThaiDateFormat(dKayin)%> น.</td>
					          <td width="39%" class="dotline ; item">&nbsp;<%=nCustomer%></td>
					          <td width="16%" align="center" class="dotline">&nbsp;<%=nCustTel%></td>
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
				          <td width="14%" align="center" class="dotline">&nbsp;</td>
				          <td width="7%" class="dotline" align="center">&nbsp;</td>
				          <td width="8%" class="dotline" align="center">&nbsp;</td>
				          <td width="16%" align="center" class="dotline">&nbsp;</td>
				          <td width="39%" class="dotline ; item">&nbsp;</td>
				          <td width="16%" align="center" class="dotline">&nbsp;</td>
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
	
<%
 }
 %>		
		
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
	
	
	
	<br style="font-size:20pt">
	<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
	  <tr><td width="100%" class="copyright" align="center">Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5  
	  <br>ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp; หรือ โทร. 0-2230-8279 (คุณประพัฒน์ ฝ่ายบริการ)&nbsp; 0-2230-8491-5 (ฝ่าย IT)  
	  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
	</TABLE> 
	
	</FORM>
	</BODY>
	</HTML>
<%
	} catch (Exception e) {
	     System.out.println("ERROR ESERV_ZeroDefect_List.jsp SQL: " +sql.toString()); 
		System.out.println("ERROR ESERV_ZeroDefect_List.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
	     System.out.println("-->jsp clean up.");
		// Clean up.
		try {
			if (rs2 != null) rs2.close();
			if (stmt2 != null) stmt2.close();
			if (rs != null) rs.close();
			if (stmt != null) stmt.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>