<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ page import="java.text.*"%>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<HTML>


<% 
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_CutLock01.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   String mode = doString.checkString(request.getParameter("mode"),"add");
   String search = doString.checkString(request.getParameter("search_project"),"");  	
   
   
   String selProj = doString.checkString(request.getParameter("sel_project"),"");
  //-----========= Declare Variables for Search  ===========----//
   String iCom = "";   
   String iPro ="";
   String iLock ="";   
   String dEff = "";
   String model = "";  
   String nDesc = "";


 
 	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	SERV_CommonData com = null;
	doString str = new doString();
	
	try {
			if (ds == null) getDS();
			 conn = ds.getConnection();
			 conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			 conn.setAutoCommit(true);
			 stmt = conn.createStatement();    
			 com = new SERV_CommonData(conn);    
				
        //----=======================================----//	
	 %>
<HEAD>
<TITLE>ข้อมูลพื้นฐาน : 06
รายละเอียดการตัดเงินตามแปลง</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">

function searchData() {
	//var sel = document.getElementById("sel_project").value;
	//alert(sel)
      var forms = document.forms[0];
      forms.search_project.value="YES";
      forms.action="<%=Constants.APP_PATH%>/SERV_CutLock01.jsp";
      forms.submit();
   }
function deleteData() {
    if (confirm("คุณต้องการลบข้อมูลที่ทำการเลือกทั้งหมดนี้ ?")) {
       document.forms[0].action = "<%=Constants.APP_PATH%>/SERV_CutLockServlet?mode=delete"; 
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

</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM method="POST" action="" >
<input type="hidden" name="mode" value="<%=mode%>">
<input type="hidden" name="search_project" value="">

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
                <td class="item_tab2" width="250">รายละเอียดการตัดเงินตามแปลง</td>
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
    <td class="item ; dotline01" height="22" width="10%">โครงการ :</td>
    <td height="22" width="90%" class="dotline01"> <%=com.genAllProjectListbox("sel_project",selProj," size='1' class='box' style='width:250px'",false)%>
    &nbsp;&nbsp;&nbsp;&nbsp; <a  href="#" onclick="searchData()"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a></td>
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
          <td class="col_name" width="5%"><input type="checkbox" name="main_check" onclick="checkAll(this,'main_check','del_checkbox');"></td>
          <td class="col_name" width="10%">แปลง</td>
          <td class="col_name" width="15%">Effective Date</td>
          <td class="col_name" width="18%">แบบบ้าน</td>
          <td class="col_name" width="35%">ประเภทการตัดเงิน</td>
          <td class="col_name" width="27%">จำนวนเงิน</td>
        </tr>
        <%
         System.out.println("------------ check lenght -----------");
         if(selProj.length()>0 ){
        
         	iCom = doString.checkString(request.getParameter("sel_project"),"").substring(0,2);
         	iPro = doString.checkString(request.getParameter("sel_project"),"").substring(3,6);
         	 
         	 sql.delete(0,sql.length());
 			 sql.append(" select b.n_desc,c.i_model,a.* from lan:serv_cutlck a ")
 			       .append(" left join lan:serv_xstd b on b.i_code=a.i_cut_type and b.i_type='03' ")
 			       .append(" left join lan:acxlckmd c on c.i_company=a.i_company ")
 			       .append(" and c.i_project=a.i_project and c.i_lock=a.i_lock ")
 			       .append(" where a.i_company='").append(iCom).append("' ")
 			       .append(" and a.i_project='").append(iPro).append("' ");

 			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
				 
			System.out.println("------------ executeQuery -----------");	 
			int line=0;	
			while (rs.next()){
		
			iLock = doString.checkString(rs.getString("i_lock"),"");
			model = doString.checkString(rs.getString("i_model"),"-");
			nDesc = doString.checkString(doString.DisplayThai(rs.getString("n_desc")),"");			
			String iCutType = doString.checkString(rs.getString("i_cut_type"),"");		
			double zAmount = rs.getDouble("z_amount");
			
			String dateFormat = "";
			Timestamp tmp = rs.getTimestamp("d_effective");
			Calendar dTmp = Calendar.getInstance();
			if (tmp!=null) {
			   dTmp.setTime(tmp);
			   dEff = getDateFromCalendar(dTmp); 
			   int y = dTmp.get(Calendar.YEAR);
			   if (y>2400) y -= 543;
			   dateFormat = str.createID(y,4)+"-";
			   dateFormat += str.createID(dTmp.get(Calendar.MONTH)+1,2)+"-";
			   dateFormat += str.createID(dTmp.get(Calendar.DATE),2);
			} else {
			   dEff = "-"; 
			}
		%>
       <tr>
          <td align="center" class="dotline" width="5%"><input type="checkbox" name="del_checkbox"  value="<%=selProj+":"+iLock+":"+dateFormat+":"+iCutType%>" onclick="checkAll(this,'main_check','del_checkbox');">&nbsp;</td>
          <td class="dotline" align="center" width="10%"><a href="SERV_CutLock02.jsp?mode=edit&edit_id=<%=selProj+":"+iLock+":"+dateFormat+":"+iCutType%>"><%=iLock%></a>&nbsp;</td>
          <td class="dotline" align="center" width="15%"><%=dEff%>&nbsp;</td>
          <td class="dotline" align="center" width="15%"><%=model%>&nbsp;</td>
          <td class="dotline" width="35%"><%=nDesc%>&nbsp;</td>
          <td class="dotline" width="17%" align="right"><%=doString.displayNumber("#,###,##0.00",zAmount)%>&nbsp;</td>
        </tr>  
        <%
		    line++;
		}
		rs.close();				
		
		//----========= Fill up blank line if this page display data less than 12 line ========--//
		while (line<Constants.SERV_XSTD_LINE) {
	 %>
        <tr>
          <td align="center" class="dotline" width="5%">&nbsp;</td>
          <td class="dotline" align="center" width="10%">&nbsp;</td>
          <td class="dotline" align="center" width="15%">&nbsp;</td>
          <td class="dotline" align="center" width="18%">&nbsp;</td>
          <td class="dotline" width="35%">&nbsp;</td>
          <td class="dotline" width="17%">&nbsp;</td>
        </tr>  
       <%
       line ++;
         } 
       } else {
           if ((selProj == "")||(selProj.length()==0) ){
				for (int i=0;i<Constants.SERV_XSTD_LINE;i++) {
			    %>
				<tr>
				  <td align="center" class="dotline" width="5%">&nbsp;</td>
				  <td class="dotline" align="center" width="10%">&nbsp;</td>
				  <td class="dotline" align="center" width="15%">&nbsp;</td>
				  <td class="dotline" align="center" width="18%">&nbsp;</td>
				  <td class="dotline" width="35%">&nbsp;</td>
				  <td class="dotline" width="17%">&nbsp;</td>
				</tr>  
			   <%
                }
		   }
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




<br style="font-size:10pt">



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="150" class="act_tab2">

            <a href="SERV_CutLock02.jsp?sel_project=<%=selProj%>"><img border="0" src="images/act_add.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp;
            <a href="#" onclick="deleteData();"><img border="0" src="images/act_delete.gif"                                   
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
  String error = doString.checkString(request.getParameter("error"),"");
  if (error.length()>0) {
     String msg = " พบปัญหาขณะลบข้อมูล!  กรุณาตรวจสอบข้อมูล และทำการลบใหม่อีกครั้ง";
     %><script>alert("<%=msg%>");</script><%
  }
%>
</BODY>

</HTML>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_CutLock01.jsp : " + e.getMessage());
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