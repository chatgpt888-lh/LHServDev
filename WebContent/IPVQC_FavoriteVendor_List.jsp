<%@page language="java" contentType="text/html; charset=TIS-620"
	pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="java.util.Date" %>
<%@page import="java.text.*" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="serv.common.*" %>
<%@ include file="function.jsp" %>

<%-- 
/**********************************************/
 * create by : pradoem wonkraso
 * date time: 2018.02.06
 * Last modify :
 * version :1.0
 * project Name : IPVQC
 * description : IPVQC List
***************************************************/
--%>
<%!
  private static String GetProjectName(Connection conn, String comId,String projectId) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			String  projectName = "";
	        try{
	        	//initial paramter	     	
				/*************************************************/			
	        	sql.delete(0,sql.length());
				sql.append(" select n_project from lan:acxprojt  where i_company =? and i_project =? ");
				pstmt = conn.prepareStatement(sql.toString());
				pstmt.setString(1, comId); //comId
				pstmt.setString(2, projectId); //projId
				rs = pstmt.executeQuery();
				if(rs.next()){
					projectName = doString.DisplayThai(doString.checkString(rs.getString("n_project"), ""));
				}
				rs.close();	
			}catch(Exception e){
	 				System.out.println(" GetProjectName Error : " + e.getMessage());
			}
			finally{			
				//clean up.
				try{
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
				}catch(Exception e){}
			}
		  return projectName;		
   }
   
 private List ListProjectByResposible(Connection conn,String userId) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter		
        	List  resultList = new ArrayList();
        	List  tempList = null;
        	//*********CurrentDate Time
   	 		Calendar rightNow = Calendar.getInstance();
   	 		String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
			/******************************************************/	       	
    		sql.delete(0, sql.length());
    		sql.append(" SELECT user_id,com_id,proj_id  FROM lan:serv_pstaff WHERE user_id = ? AND com_id = 'LH' AND proj_id = 'ALL' ");
    		pstmt = conn.prepareStatement(sql.toString()); 
    		pstmt.setString(1,userId);			
    		rs = pstmt.executeQuery();			
    		//*******************************For Viewer************************************//
    		sql.delete(0, sql.length());
    		if (rs.next()) {
    			sql.append("SELECT DISTINCT proj.i_company, proj.i_project, proj.n_project")
    				.append(" FROM lan:acxprojt proj, lan:acsbudgh bud")
    				.append(" WHERE bud.i_company = proj.i_company AND bud.i_project = proj.i_project")
    				.append(" AND bud.d_year = '")
    				.append(cur_year)
    				.append("' ORDER BY proj.i_company, proj.i_project ");
    		} else {
    			sql.append("SELECT b.i_company, b.i_project, b.n_project ")
    				.append(" FROM lan:serv_pstaff a, lan:acxprojt b ")
    				.append(" WHERE a.user_id = '")
    				.append(userId)
    				.append("' AND a.com_id = b.i_company AND a.proj_id = b.i_project ")
    				.append(" ORDER BY b.i_company, b.i_project ");
    		}
    		pstmt = conn.prepareStatement(sql.toString()); 
    		rs = pstmt.executeQuery();

			while(rs.next()){	
				tempList = new ArrayList();			
				tempList.add(0, doString.checkString(rs.getString("i_company"),""));
				tempList.add(1, doString.checkString(rs.getString("i_project"),""));
				tempList.add(2, doString.checkString(rs.getString("n_project"),""));
				resultList.add(tempList);
			}
			rs.close();	
		  	//System.out.println("## ListProjectByResposible ->end.");				  	 
		  	return resultList;			  	 
		}catch(Exception e){
			System.out.println("!!! ListProjectByResposible , "+e.getMessage());
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

private String preparedInQurey(List projList){
  StringBuffer str = new StringBuffer();	
  String temp1 ="";
  String temp2 ="";
  try{
  	if(projList!=null && projList.size()>0){
  		List  tempList = null;
  		Set scom = new HashSet();
  		Set sproj = new HashSet();
  		for(Iterator iter = projList.iterator();iter.hasNext(); ){
  			tempList = (ArrayList)iter.next();
  			scom.add(tempList.get(0).toString());
  			sproj.add(tempList.get(1).toString());
  		}  	
  		str.delete(0,str.length());	
  		str.append(" and I_COMPANY in ( ");
  		if(scom.size()>0){
  			Object[] arrCom = scom.toArray();
			for (int i = 0; i < arrCom.length; i++) {
			  str.append(" '"+arrCom[i]+"',");
			}
			temp1 = str.toString();
			temp1 = temp1.substring(0,temp1.length()-1);
			temp1 = temp1+" )";
  		}
  		str.delete(0,str.length());		
  		str.append(" and I_PROJECT in ( ");
  		if(sproj.size()>0){
  			Object[] arrCom = sproj.toArray();
			for (int i = 0; i < arrCom.length; i++) {
			   if(!arrCom[i].equals("099")){
			      str.append(" '"+arrCom[i]+"',");
			   }
			}
			temp2 = str.toString();
			temp2 = temp2.substring(0,temp2.length()-1);
			temp2 = temp2+" )";
  		}
  	}
  	return temp1+temp2;
  }catch(Exception e){
	System.out.println("!!! preparedInQurey , "+e.getMessage());	
	return "";
  }
}

//ListAllVendor(conn,false,nVendor,tmpProj[0],tmpProj[1],projList);
private List ListAllVendor(Connection conn,boolean isAll,String comId,String projId,String txtNameVendor, List projList) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter		
        	//System.out.println("##ListAllVendor ->Starting.");   
        	List  resultList = new ArrayList();
        	HashMap hashMap = null;  
        
			/******************************************************/	
			sql.delete(0,sql.length());
			sql.append(" select I_COMPANY,I_PROJECT,I_VENDOR,N_VENDOR,C_DESC,STATUS from lan:IPV_QCVENDOR ")
			   .append(" WHERE STATUS = 'A' ");
			   if(isAll){
			        String whereClause = preparedInQurey(projList); 
				   	sql.append(whereClause);
			   }else{
			   	 sql.append(" and I_COMPANY ='"+comId+"' and I_PROJECT = '"+projId+"'  ");
			   }
			   if(txtNameVendor.length()>0){
					sql.append(" and  n_vendor like '%"+txtNameVendor+"%'  ");
				}
			sql.append(" Order by N_VENDOR ");

			//System.out.println("SQL :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString());
			rs = pstmt.executeQuery();	
			while(rs.next()){	
				hashMap = new HashMap();
	    		hashMap.put("xCOM_ID", doString.checkString(rs.getString("I_COMPANY"),""));//0
	    		hashMap.put("xPROJECT_ID", doString.checkString(rs.getString("I_PROJECT"),""));//1
	    		hashMap.put("xI_VENDOR", doString.checkString(rs.getString("I_VENDOR"),""));//1
	    		hashMap.put("xN_VENDOR", doString.checkString(rs.getString("N_VENDOR"),""));//1
	    		hashMap.put("xC_DESC", doString.checkString(rs.getString("C_DESC"),""));//1
	    		hashMap.put("xSTATUS", doString.checkString(rs.getString("STATUS"),""));//1
				hashMap.put("xN_PROJECT",GetProjectName(conn,doString.checkString(rs.getString("I_COMPANY"),""),doString.checkString(rs.getString("I_PROJECT"),"")));
				resultList.add(hashMap);
			}
			rs.close();				
			//********************************************************/
		  	//System.out.println("##ListAllVendor ->end.");				  	 
		  	return resultList;			  	 
		}catch(Exception e){
			System.out.println("!!! ListAllVendor , "+e.getMessage());
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

  private User authenUser(Connection conn, String userid) throws Exception {
	  Statement ustmt = null;
	  ResultSet rsUser = null;
	  User user = null;
	  String who = "";
	  String empId = "";
	  String name = "";
	  String password = "";
	  boolean acap = false;
	  StringBuffer sql = new StringBuffer();
	  try {
		  ustmt = conn.createStatement();
		  
		  //----========== If this user is vendor , get new name from stpvendr ==========----//
		  String userWho = "";
		  String userGroup = "";
		  String iPerson = "";
		  sql.delete(0,sql.length());
		  sql.append(" select user_who,i_person, user_group,user_password from lan:useracl where   user_id='").append(userid).append("' ");
		  rsUser = ustmt.executeQuery(sql.toString());
		  if (rsUser.next()) {
			  userWho = doString.checkString(rsUser.getString("user_who"),"");
			  iPerson = doString.checkString(rsUser.getString("i_person"),"");
			  userGroup = doString.checkString(rsUser.getString("user_group"),"");
			  password = doString.checkString(rsUser.getString("user_password"),"");
		  }
		  rsUser.close();
		  rsUser = null;
		  
		  sql.delete(0,sql.length());
		  sql.append("SELECT u.user_name, u.user_who, u.user_group, u.user_acl, u.user_email, ")
					.append("                  e.i_employ, TRIM(e.n_prename_th) || ' ' || TRIM(e.n_nemploy_th) || ' ' || TRIM(e.n_semploy_th) AS EMP_NAME, ")
					.append("                  j.i_job, j.i_company, c.n_company, j.i_division, j.d_job, d.n_desc AS DIVISION, ")
					.append("                  p.n_desc AS POSITION, g.a_dept, j.i_level ")
					.append(" FROM   lan:useracl u, docflow:acemploy e, docflow:acempjob j, ")
					.append("                 docflow:acempstd d, docflow:acempstd p, docflow:acxcompa c, docflow:dfz_dept g")
					.append(" WHERE u.user_id = '").append(userid).append("' ")
					.append("                  AND u.user_password = '").append(password).append("' ")
					.append("                  AND u.user_acl='S' AND e.i_employ = u.i_employ AND e.d_retry IS NULL ")
					.append("                  AND j.i_employ = e.i_employ AND d.i_type = '11' AND d.i_code = j.i_division ")
					.append("                  AND g.i_code = j.i_division AND p.i_type = '10' ")
					.append("                  AND p.i_code = j.i_job AND c.i_company = j.i_company ")
					.append(" ORDER BY j.d_job DESC ");
				//System.out.println("SQL : "+sql.toString());
				rsUser = ustmt.executeQuery(sql.toString());
	         
				//allow user
				if (rsUser != null) {
					if (rsUser.next() == true) {
						user = new User();
						empId = doString.checkString(rsUser.getString("I_EMPLOY"));
						user.setUserID(userid);
						user.setUserName(rsUser.getString("USER_NAME"));
						user.setUserWho(rsUser.getString("USER_WHO"));
						user.setUserGroup(rsUser.getString("USER_GROUP"));
						user.setUserACL(rsUser.getString("USER_ACL"));
						user.setEmail(rsUser.getString("USER_EMAIL"));
						user.setEmpId(empId);
						name = doString.checkString(rsUser.getString("EMP_NAME"));
						user.setEmpName(doString.checkString(rsUser.getString("EMP_NAME")));
						user.setPosition(doString.checkString(rsUser.getString("POSITION")));
						user.setDivisionId(doString.checkString(rsUser.getString("I_DIVISION")));
						user.setGroup(doString.checkString(rsUser.getString("A_DEPT")));
						user.setDivision(doString.checkString(rsUser.getString("DIVISION")));
						user.setCompanyId(doString.checkString(rsUser.getString("I_COMPANY")));
						user.setCompany(doString.checkString(rsUser.getString("N_COMPANY")));
						//user.setLevel(Integer.parseInt(doString.checkString(rsUser.getString("I_LEVEL"))));		        
					}
					rsUser.close();
					rsUser = null;
				}
		  ustmt.close();
		  ustmt = null;        
	  } catch (Exception e) {
		  System.out.println(e.getMessage());           
		   throw e;

	  }
	  // Do this no matter what.
	  finally {
		  // Clean up.
		  try {
			  try {
				  if (rsUser != null) {
					  rsUser.close();
				  }
			  } finally {
				  if (ustmt != null) {
					  ustmt.close();
				  }
			  }
		  } catch (SQLException ignore) {
		  }
	  }
	  return (user);
  }
 %>

<%
	//*****************************************
	String projectDDL = request.getParameter("projectDDL")==null?"": request.getParameter("projectDDL").toString();//LH:075
	String nVendor	 = request.getParameter("txtVendor")==null?"": request.getParameter("txtVendor").toString();//LH:075
	String userId	 = request.getParameter("userId")==null?"": request.getParameter("userId").toString();//pradoem
	Connection conn = null;
	try {

        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
        //----=======================================----//	
        //authentication
		String localUserId = "";
		System.out.println("User Id :"+userId);
		if(!"".equals(userId)){
			User user = authenUser(conn,userId);
			localUserId  = user.getUserID();
			session.setAttribute("USER",user);
		}else{
			User user = null;
			if(session != null){
				user =(User)session.getAttribute("USER");
			}
		    localUserId = user.getUserID();
		}
        List projList = ListProjectByResposible(conn,localUserId);
        
        List resultList =  new ArrayList();
        if(projectDDL.length()>0){
        	//System.out.println("==== By Project ====");
        	String tmpProj[] = projectDDL.split("\\:");
        	resultList =  ListAllVendor(conn,false,tmpProj[0],tmpProj[1],nVendor,projList);
        }else{
        	//System.out.println("==== By ALL Project ====");
        	resultList =  ListAllVendor(conn,true,"","",nVendor,projList);
        }

 %>
<HTML>
<HEAD>
<TITLE>ข้อมูลพื้นฐาน QC - รายการบริษัทตรวจรับบ้าน</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<style type="text/css">
 .box2 {  font-family: Tohama,Arial,sans-serif; font-size:10.1pt; font-weight:normal;
		padding-top: 1px; padding-right: 1px; padding-bottom: 1px; padding-left: 1px; 
	 	color:#165396; background-color: white; border: 1px #BEDCFF solid ; 
}
td.dotlineWhite{
	 color: rgb(255,255,255) ;	
	 border-bottom:1px dotted rgb(220,220,220)	;
	 border-right:1px solid rgb(135,185,247) ; 
	 padding:3px ; mso-number-format:"\@";  }
</style>
<script language="javascript" src="script_fx.js"></script>
<script type="text/javascript" src="eserv_paging.js"></script>
<script>
function initForm(){
      var e = document.getElementById('page');
      //e.style.display == 'block'
      e.style.visibility = 'hidden';
 }
function doSearch(){
    document.forms[0].action="<%=request.getContextPath()%>/IPVQC_FavoriteVendor_List.jsp";
    document.forms[0].submit();
}
function doAdd(){
	document.forms[0].action="<%=request.getContextPath()%>/IPVQC_FavoriteVendor_Add.jsp";
	document.forms[0].submit();
}

function doDelete(comId,projId,vendorId) {
	 document.forms[0].comId.value = comId;
	 document.forms[0].projId.value = projId;
     document.forms[0].vendorId.value = vendorId;
	 if(confirm("คุณต้องการลบข้อมูลบริษรับตรวจบ้าน รหัส: '"+vendorId+"' ใช่หรือไม่?")==true){
		 //validate from client side
		 document.forms[0].action="<%=request.getContextPath()%>/IPVQC_FavoriteVendorServlet?cmd=delete";
		 document.forms[0].submit();
	}
}

</script>
<style type="text/css">    
            .pg-normal {
                font-size:14px;
                color: #20a6f4;
                font-weight: normal;
                text-decoration: none;    
                cursor: pointer;    
            }
            .pg-selected {
               font-size:1.875em;
                color: #fe8002;
                font-weight: bold;        
                text-decoration: underline;
                cursor: pointer;
            }
            
 </style>
 <style type="text/css">
	A:link {text-decoration: none}
	A:visited {text-decoration: none}
	A:active {text-decoration: none}
	A:hover {text-decoration: underline; color: red;}
</style>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="initForm()">
<form action="" name="frm" method="POST">
<input type="hidden" name="vendorId" value="">
<input type="hidden" name="comId" value="">
<input type="hidden" name="projId" value="">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">
          &nbsp;ข้อมูลพื้นฐาน QC- รายการบริษัทตรวจรับบ้าน</td>
        </tr>
      </table>
<br style="font-size:10pt">              
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">Form Search </td>
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
    <td class="item ; dotline01" height="22" width="12%">โครงการ :</td>
    <td height="22" width="88%" class="dotline01">
	<select name="projectDDL" class="box2" style='width:280' size='1' > 
			<option value="">------ กรุณาเลือกโครงการ ------</option>
   				<%
					List  arrList = null;
					if(projList!=null && projList.size()>0){
							Iterator it = projList.iterator();
							String select = "";
						     String strValue = "";
							while(it.hasNext()){
						     select = "";
							 strValue = ""; 									
							 arrList =(ArrayList)it.next();										
							 strValue = doString.checkString(arrList.get(0).toString())+":"+doString.checkString(arrList.get(1).toString());
							if (strValue.equals(projectDDL)){
								select="selected"; 
							}else{ 
								select=""; 
							} %>
								<option value="<%=strValue%>"  <%=select %>><%=strValue%> - <%=doString.checkString(doString.DisplayThai(arrList.get(2).toString())) %></option>
							<%}
					} %>	 
   				</select>
    </td>
    </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="12%">ชื่อบริษัทตรวจรับบ้าน :</td>
    <td height="22" width="88%" class="dotline01">
		<input type="text" name="txtVendor" size="50"  value="<%=doString.DisplayThai(nVendor)%>" >	
   				&nbsp;&nbsp;<a href="javascript:doSearch();"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a>
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
<p align="left">
<a href="javascript:doAdd();"><img border="0" src="images/act_add.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
  </p>       	
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
      <table id="results" border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td class="col_name" width="5%">NO.</td>
          <td class="col_name" width="10%">รหัสบริษัท</td>
          <td class="col_name" width="10%">ชื่อโครงการ</td>
          <td class="col_name" width="10%">รหัสบริษัทตรวจรับบ้าน</td>
          <td class="col_name" width="20%">ชื่อบริษัทตรวจรับบ้าน</td>
          <td class="col_name" width="15%">Delete</td>
        </tr>
 <%
        int counter = 0;
 		if(resultList!=null && resultList.size()>0){
			 HashMap hashMap = null;
 			 String tagColor = "";
			 for (Iterator iter =resultList.iterator(); iter.hasNext(); ) {
			    counter++;		
				hashMap = (HashMap)iter.next(); 	
				tagColor="#ffffff";
				if((counter%2)==0){
					tagColor="#f0f0f0";
				}	 
 %>
	       <tr bgcolor="<%=tagColor %>">
	        <td align="center" class="dotline" ><%=counter%></td>
	        <td align="center" class="dotline" >&nbsp;<%=hashMap.get("xCOM_ID").toString()%>-<%=hashMap.get("xPROJECT_ID").toString()%></td>
	        <td align="center" class="dotline" >&nbsp;<%=hashMap.get("xN_PROJECT").toString()%></td>
	        <td  align="center" class="dotline ; item">&nbsp;<a href="javascript:doFormLoadEdit('<%=hashMap.get("xI_VENDOR").toString()%>');"><%=hashMap.get("xI_VENDOR").toString() %></td>
	        <td class="dotline" align="left" >&nbsp;<%=doString.DisplayThai(hashMap.get("xN_VENDOR").toString())%></td>
			<td  class="dotline" align="center"><a href="javascript:doDelete('<%=hashMap.get("xCOM_ID").toString()%>','<%=hashMap.get("xPROJECT_ID").toString()%>','<%=hashMap.get("xI_VENDOR").toString()%>');"><img src="images/bu_del.gif" width="30" height="12" border="0"                                  
	    			    onmouseout=nereidFade(this,70,50,5)    
	                  	onmouseover=nereidFade(this,100,50,5)     
	                  	style="FILTER: alpha(opacity=70)" width="70" height="27" alt="Delete"></a></td>
	       </tr>  
 			<%
 			}
 	}else{
  %>       
        <tr>
		   <td  class="dotline" colspan="6" class="side01" >&nbsp;</td>
        </tr>
       <tr>
		   <td  class="dotline" colspan="6" align="center" class="side01" >&nbsp;ไม่มีข้อมูล</td>
        </tr>
        <tr>
		   <td  class="dotline" colspan="6" class="side01" >&nbsp;</td>
        </tr>
        <%}
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
<% if(counter>0){ %>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr  valign="MIDDLE">
    <td align="right" nowrap="nowrap" width="50%">
    <div id="pageNavPosition"></div>
    </td>
   <td valign="middle" align="left" nowrap="nowrap" width="50%" class="pg-normal" >
   &nbsp;&nbsp;<A href="#" onclick="toggle_visibility('page');">|ALL|</A>&nbsp;&nbsp;<div id="page"></div>
    </td>
  </tr>
</table>
<%} %>
<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">
            <%-- <a href="javascript:doDelete();"><img border="0" src="images/act_delete.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
            --%>
           </td>      	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:history.back()" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
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

</form>
<script type="text/javascript">	
    function toggle_visibility(id) {
      var intX = 0;
      var e = document.getElementById(id);
      if(e.style.visibility == 'hidden'){
         e.style.visibility = 'visible';
         intX = 1;
      }else{
         e.style.visibility = 'hidden';
      }      
      if(intX==1){
         allList();
      }else{
        pageList();
      }
    }

 	function allList(){
 		 totalRec  = "<%=counter%>";
 		  var pager = new Pager('results', totalRec); 
	      pager.init(); 
	      pager.showPageNav('pager', 'pageNavPosition'); 
	      pager.showPage(1);
    }
    
    function pageList(){
 		  var pager = new Pager('results', 25); 
	      pager.init(); 
	      pager.showPageNav('pager', 'pageNavPosition'); 
	      pager.showPage(1);
    }
</script>
 <script type="text/javascript"><!--
        var pager = new Pager('results', 25); 
        pager.init(); 
        pager.showPageNav('pager', 'pageNavPosition'); 
        pager.showPage(1);
    //--></script>
</BODY>
</HTML>

<%
	} catch (Exception e) {
		System.out.println("ERROR IPVQC_FavoriteVendor_List.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>
