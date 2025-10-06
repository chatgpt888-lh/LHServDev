<%@page language="java" contentType="text/html; charset=TIS-620"
	pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%!
	private static String  thaiDateFormate(String tempDate){
	  //IN format : 2555-06-28  ,2012-06-28
	  //Out format : 28/06/2555
		if(!tempDate.equals("")){
		  String temp [] = tempDate.split("\\-");
		  //return (Integer.parseInt(temp[0])-543)+"-"+temp[1]+"-"+temp[0];
		  return temp[2]+"/"+temp[1]+"/"+(Integer.parseInt(temp[0])+543);
		}else{
			return tempDate;
		}
	}

 %>
<%-- 
/**********************************************/
 * create by : pradoem wonkraso
 * date time: 2019.11.12
 * version :1.0
 * project Name : Line Service
 * description : this is page for display && Master Data Appiont date form
***************************************************/
--%>
<%
	ArrayList dayList = (ArrayList)request.getAttribute("daysList");
	ArrayList timeList = (ArrayList)session.getAttribute("timeList");
	String []timeHD =(String[])session.getAttribute("timeHD");
	String sel_project	= request.getAttribute("selProj")==null?"": request.getAttribute("selProj").toString();	
	String projectNameThai = request.getAttribute("projectNameThai")==null?"" :request.getAttribute("projectNameThai").toString();	        
 %>
<HTML>
<HEAD>
<TITLE>(สำหรับ Line Service)กำหนดเวลานัดเข้าตรวจสอบรายการซ่อม</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<style type="text/css">
td.dotlineWhite{
	 color: rgb(255,255,255) ;	
	 border-bottom:1px dotted rgb(220,220,220)	;
	 border-right:1px solid rgb(135,185,247) ; 
	 padding:3px ; mso-number-format:"\@";  }
</style>
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
<!--
function doADD(){
     var proj = "<%=projectNameThai%>";
	 document.forms[0].action="<%=request.getContextPath()%>/LSERV_AppointDateServlet?cmd=formLoad&mode=add&projectNameThai="+proj;
	 document.forms[0].submit();
}
function doDelete(DateDel){
     var proj = "<%=projectNameThai%>";
   if(confirm("คุณต้องการลบรายการกำหนดเวลาเข้าตรวจสอบใช่หรือไม่?")==true){
       document.forms[0].DateDel.value = DateDel;
	   document.forms[0].action="<%=request.getContextPath()%>/LSERV_AppointDateServlet?cmd=delete&projectNameThai="+proj;
	   document.forms[0].submit();
	}
}

function doSave(){
	 document.forms[0].action="<%=request.getContextPath()%>/LSERV_AppointDateServlet?cmd=save";
	 document.forms[0].submit();
}
-->
</script>
<base target="_self">
</HEAD>
<%
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;    
       try {
        //******************************//
		if (ds == null) getDS();
		conn = ds.getConnection();
 %>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<form action="" name="frm" method="POST">
<input type="hidden" name="projectDDL" value="<%=sel_project %>"> 
<input type="hidden" name="DateDel" value=""> 

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">
          &nbsp;ข้อมูลพื้นฐาน</td>
        </tr>
      </table>
<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="280">(สำหรับ Line Service)กำหนดเวลานัดเข้าตรวจสอบรายการซ่อม</td>
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
	    <td class="item ; dotline01" height="22" width="12%" valign="top">โครงการ :</td>
	    <td height="22" width="88%" class="dotline01">
		   
		   <!-- Project List -->
		    <table border="0" width="100%" cellspacing="0" cellpadding="0">		
				<tr><td><%=projectNameThai%></td></tr>  
			</table>						
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
    <td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
    <td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL"> 
      <table border="0" width="100%" cellspacing="0" cellpadding="0">     
        <tr height="25">
          <td class="col_name" width="10%">DELETE</td>
          <td class="col_name" width="15%">วันที่</td>
          <% 
          if(timeList!=null && timeList.size()>0){
	           List  arrList = new ArrayList();
	           Iterator it = timeList.iterator();
	           int percent = 0;
	           percent = 75/timeList.size();          
			   while(it.hasNext()){								
			  	 arrList =(ArrayList)it.next();
			     %>
		          	  <td class="col_name" width="<%=percent+"%"%>" align="center">&nbsp; <%=arrList.get(0).toString() %></td>
		         <%
			     }
		   }
		  %>
        </tr>  
        <%
        if(dayList!=null && dayList.size()>0){
          StringBuffer tTime = new StringBuffer();
            //Unique Date krub
          for(int i=0;i<dayList.size();i++){//Loop date Unique
            		//find by date with colum time		
            		%>
            		<tr>
					<td class="dotline" width="10%" align="center"><a href="javascript:doDelete('<%=dayList.get(i)%>');">DELETE</a></td>
					<td class="dotline" width="15%" align="center"><%=thaiDateFormate(dayList.get(i).toString())%> </td>	
            		<%
            		sql.delete(0, sql.length());     
			 		sql.append(" Select  i_company,i_project,i_date,q_apptime_fr1,i_type From lan:eser_temp_date  Where i_date = ? and q_apptime_fr1 = ? ");            					
					pstmt = conn.prepareStatement(sql.toString()); 
					int percent = 75/timeHD.length;
					
					String tagColor = "#ffffff";//#7bd148  =G
										//#ff7537 = O //#ffffff
					for(int c = 0;c<timeHD.length;c++){//Loop time HD
					    pstmt.setString(1, dayList.get(i).toString());
			 		    pstmt.setString(2, timeHD[c].toString());
			 		    rs = pstmt.executeQuery();
			 		     tTime.delete(0,tTime.length());
			 		    if(rs.next()){
			 			     tTime.append(doString.checkString(rs.getString("q_apptime_fr1"),""));		
			 			     if(doString.checkString(rs.getString("i_type"),"").equals("01")){
			 			     	tagColor = "#ff7537";
							  }else if(doString.checkString(rs.getString("i_type"),"").equals("02")){
							  	tagColor = "#7bd148";
							  }else{
							     tagColor = "#ffffff";
							  }	    
			 			    %>
				 			  <td class="dotlineWhite" width="<%=percent+"%"%>" align="center" bgcolor="<%=tagColor %>">
							  <input type="checkbox" name="timeChk" value="<%=dayList.get(i)+"|"+tTime.toString()+"|"+doString.checkString(rs.getString("i_type"),"")%>" checked><%=tTime.toString() %>
							  <%
							  if(doString.checkString(rs.getString("i_type"),"").equals("01")){
							  	out.println("[ESV]");
							  }else if(doString.checkString(rs.getString("i_type"),"").equals("02")){
							  	out.println("[SVC]");
							  }else if(doString.checkString(rs.getString("i_type"),"").equals("03")){
							  	out.println("[LSV]");
							  }else{
							    out.println("&nbsp;");
							  }
							   %>
							  </td>
			 			    <%
			 		    }else{
			 		        %>
			 		     	<td class="dotline" width="<%=percent+"%"%>" align="center">&nbsp;
						    </td>
			 		        <%
			 		    }  
					} //# End Loop time HD		   
	               %>	
					</tr> 
			   <%}//#Loop time HD
			 } %>
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
<p align="left">
<font color="#ff7537">
LSV  : ระบบ Line Service<br></font>
</p>
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1">&nbsp;</td>
            <td width="40%" class="act_tab2">
            <a href="javascript:doADD();"><img border="0" src="images/act_add.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>				
			&nbsp;<a href="javascript:doSave();"><img border="0" src="images/act_save.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>        							
					</td>   	
            <td class="act_tab3">&nbsp;</td>   
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
<%
	} catch (Exception e) {
		System.out.println("ERROR ESERV_Appoint.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (pstmt != null) pstmt.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>
</BODY>
</HTML>
