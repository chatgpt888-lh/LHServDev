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


<% 
String sessionId = user.getsessionId();
//String userId = user.getUserID();
String jName = "SERV_PStaff02.jsp";
ServLog servlog = new ServLog(sessionId, user.getUserID(), jName);

	String value="";
	String params="";
	String iEmploy =doString.checkString(request.getParameter("i_employ"),"");
	String userId =doString.checkString(request.getParameter("user_id"),"");
	String iCom = doString.checkString(request.getParameter("i_company"),"");
	String iProj = doString.checkString(request.getParameter("i_project"),"");
	String selProj = doString.checkString(request.getParameter("sel_project"),"");
	
	
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	SERV_CommonData com = null;
	
	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();   
		com = new SERV_CommonData(conn);  
		
		String userName = "-";
		
	    sql.delete(0,sql.length());
  		sql.append(" select * from docflow:acemploy where i_employ='").append(iEmploy).append("' ");                         
        		
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		if (rs.next()) {
		    userName = doString.checkString(doString.DisplayThai(rs.getString("n_prename_th")),"").trim();
		    userName += doString.checkString(doString.DisplayThai(rs.getString("n_nemploy_th")),"").trim();
		    userName += " "+doString.checkString(doString.DisplayThai(rs.getString("n_semploy_th")),"").trim();
		}
		rs.close();


		if (userName.length()<=1) {
		   sql.delete(0,sql.length());
		   sql.append(" select * from lan:stpvendr where vend_code='").append(iEmploy).append("' ");
		   servlog.startLog(sql.toString());
		   rs = stmt.executeQuery(sql.toString());
		   servlog.endLog();
		   if (rs.next()) {
			 userName = doString.checkString(doString.DisplayThai(rs.getString("bus_name")));		    
		   }
		   rs.close();		
		}
		     
        //----=======================================----//	
	 %>
<HTML>
<HEAD>
<TITLE>ข้อมูลพื้นฐาน : 04
รายละเอียดโครงการที่รับผิดชอบ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">

function  checkAll(obj,mainCheck,subCheck) {
     var main = document.forms[0].elements[mainCheck];
     var sub = document.forms[0].elements[subCheck];
     
     if (obj!=null && main!=null && sub!=null) {
         if (obj.name==mainCheck) {
		    if (sub.length!=null) {
				for (var i=0;i<sub.length;i++) {
					  sub[i].checked = obj.checked;
				}
			} else {
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

function saveData(){
   <%
      if (userId.length()>0) {
          %>
          if (document.form.sel_project.value=="") {
             alert("กรุณาเลือกโครงการที่ต้องการเพิ่ม !");
             document.form.sel_project.focus();
             return false;
          }
          
         document.form.action="<%=Constants.APP_PATH%>/SERV_PStaffServlet?mode=add&user_id=<%=userId%>" ;
         document.forms[0].submit();
         <%
      } else {
          %>alert("<%=userName%> ไม่มีข้อมูล User ID กรุณาตรวจสอบข้อมูลอีกครั้ง !");<%
      }
   %>
}

function deleteData() {
   <%
      if (userId.length()>0) {
          %>
		    if (confirm("คุณต้องการลบข้อมูลที่ทำการเลือกทั้งหมดนี้ ?")) {
		       document.forms[0].action ="<%=Constants.APP_PATH%>/SERV_PStaffServlet?mode=delete&user_id=<%=userId%>";
		       document.forms[0].submit();
		    } 
          <%
      } else {
          %>alert("<%=userName%> ไม่มีข้อมูล User ID กรุณาตรวจสอบข้อมูลอีกครั้ง !");<%
      }
   %>
}

</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM method="POST" action="" name="form">

<input type="hidden" name="i_employ" value="<%=iEmploy%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ข้อมูลพื้นฐาน</td>
        </tr>
      </table>


<br style="font-size:10pt">
        
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">รายละเอียดโครงการที่รับผิดชอบ</td>
              	<td class="item_tab3"></td>  
              	<td><%=userName%></td>           
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
    <td class="item ; dotline01" height="22" width="12%">ชื่อพนักงาน
      :</td>
    <td height="22" width="30%" class="dotline01">&nbsp;<%=userName%></td>
    <td height="22" width="12%" class="item ; dotline01">รหัสโครงการ
      :
    </td>
     <td height="22" width="46%" class="dotline01">
     <%=com.genAllProjectListbox("sel_project",selProj," size='1' class='box' style='width:300px'",false)%>
     &nbsp;&nbsp;&nbsp;&nbsp;
     <img border="0" src="images/bu_add.gif" align="absmiddle" width="30" height="12" style='cursor:hand' onclick="saveData();">
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




<br style="font-size:2pt">  


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
          <td class="col_name" width="10%"><input type="checkbox" name="main_check" onclick="checkAll(this,'main_check','del_checkbox');"></td>
          <td class="col_name" width="10%">No.</td>
          <td class="col_name" width="90%">โครงการ</td>
        </tr>
      <%
      
          sql.delete(0,sql.length());
          sql.append(" select * from serv_pstaff a,acxprojt b" )
             .append(" where user_id ='").append(userId).append("' ")
             .append(" and b.i_company = a.com_id ") 
             .append(" and b.i_project = a.proj_id ");                                                
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		int line = 0;
		int i = 0;
		while (rs.next()) {
		   i++;
			String comId = doString.checkString(rs.getString("com_id"));		    
			String projId = doString.checkString(rs.getString("proj_id"));		    
			String nProj = doString.checkString(doString.DisplayThai(rs.getString("n_project")));		    
			
       %>
        <tr>
          <td align="center" class="dotline" width="10%"><input type="checkbox" name="del_checkbox" value="<%=userId%>:<%=comId%>:<%=projId%>" onclick="checkAll(this,'main_check','del_checkbox');"></td>
          <td align="center" class="dotline" width="10%"><%=i%></td>
          <td class="dotline" width="90%"><%=comId%>-<%=projId%> - <%=nProj%></td>
        </tr>
         <%
		    line++;
		    
		}
		
		rs.close();				
		
		//----========= Fill up blank line if this page display data less than 12 line ========--//
		while (line<Constants.SERV_PSTAFF_LINE) {
		    %>
        <tr>
          <td align="center" class="dotline" width="10%">&nbsp;</td>
          <td align="center" class="dotline" width="10%">&nbsp;</td>
          <td class="dotline" width="90%">&nbsp;</td>
        </tr>
        <%
		    line++;
		}
        //-----=================================================================---//        
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



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">

            <a href="#" onclick="deleteData();"><img border="0" src="images/act_delete.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>

            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_PStaff01.jsp" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
	<%
  String error = doString.checkString(request.getParameter("error"),"");
  if (error.length()>0) {
     String msg = " พบปัญหาขณะลบข้อมูล!  กรุณาตรวจสอบข้อมูล และทำการลบใหม่อีกครั้ง";
     %><script>alert("<%=msg%>");</script>
     
     <%
  }
%>
</FORM>


   <%
      if (userId.length()<=0) {
          %><script>alert("<%=userName%> ไม่มีข้อมูล User ID กรุณาตรวจสอบข้อมูลอีกครั้ง !");</script><%
      }
   %>
   

</BODY>

</HTML>

<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_PStaff02.jsp : " + e.getMessage());
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



