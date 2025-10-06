<%@page language="java" contentType="text/html; charset=TIS-620"
	pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%! 
  private static String []  GetDayOfWeek = {"อาทิตย์","จันทร์","อังคาร","พุธ","พฤหัสบดี","ศุกร์","เสาร์",""};
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
 * date time: 2012.07.02
 * Last modify :
 * version :1.0
 * project Name : E-Service
 * description : this is page for display && Master Data Appiont date form
***************************************************/
--%>
<%
	ArrayList projectDDL = (ArrayList)session.getAttribute("projDDL");
	ArrayList resultList = (ArrayList)session.getAttribute("result");
	ArrayList dateList = (ArrayList)session.getAttribute("dateList");
	ArrayList timeList = (ArrayList)session.getAttribute("timeList");
	
	String sel_project	= request.getParameter("projectDDL")==null?"": request.getParameter("projectDDL").toString();	  
	String iLock	= request.getParameter("iLock")==null?"": request.getParameter("iLock").toString();	  	 
	String iDocno   = request.getParameter("iDocno")==null?"": request.getParameter("iDocno").toString();	
	String  iHouse  = request.getParameter("iHouse")==null?"": request.getParameter("iHouse").toString();	
	String dateDDL = request.getParameter("dateDDL")==null?"": request.getParameter("dateDDL").toString();		
	String custName = doString.checkString(request.getParameter("custName"),""); 
    String tel = doString.checkString(request.getParameter("tel"),"");
    String status = doString.checkString(request.getParameter("status"),"");

	//String projDDL = request.getParameter("projectDDL")==null?"": request.getParameter("projectDDL").toString();
	if(sel_project.equals("")){
		sel_project	= request.getAttribute("projectDDL")==null?"": request.getAttribute("projectDDL").toString();	
	}
	if(iLock.equals("")){
		iLock	= request.getAttribute("iLock")==null?"": request.getAttribute("iLock").toString();	  
	}
	if(iDocno.equals("")){
		iDocno   = request.getAttribute("iDocno")==null?"": request.getAttribute("iDocno").toString();	
	}
	if(dateDDL.equals("")){
		dateDDL = request.getAttribute("dateDDL")==null?"": request.getAttribute("dateDDL").toString();	
	}
	if(iHouse.equals("")){
		 iHouse  = request.getAttribute("iHouse")==null?"": request.getAttribute("iHouse").toString();	
	}
	
	if(custName.equals("")){
		 custName  = request.getAttribute("custName")==null?"": request.getAttribute("custName").toString();	
	}
	
	if(tel.equals("")){
		 tel  = request.getAttribute("tel")==null?"": request.getAttribute("tel").toString();	
	}
  if(status.equals("")){
		 status  = request.getAttribute("status")==null?"": request.getAttribute("status").toString();	
	}
 %>
<HTML>
<HEAD>
<TITLE>แก้ไขกำหนดเวลานัดเข้าตรวจสอบรายการซ่อม</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script type="text/javascript">
function doChangeDateDDL(){
	document.forms[0].action="<%=request.getContextPath()%>/ESERV_AfterAppointDateServlet?cmd=change";
	document.forms[0].submit();
}

function doSubmit(){
	if(document.forms[0].dateDDL.value ==''){
		alert("กรุณาเลือกวันที่ด้วย");
        return;
	} else if(document.forms[0].timeDDL.value ==''){
		alert("กรุณาเลือกเวลาด้วย");
        return;
	}else{   
		 //document.forms[0].action="<%=request.getContextPath()%>/ESERV_AfterAppointDateServlet?cmd=submit";
		 //document.forms[0].submit();
		 var dDate = document.forms[0].dateDDL.value;
		 var tTime = document.forms[0].timeDDL.value;
		 var proj = "<%=sel_project %>";
		 var idoc = "<%=iDocno %>";
		 var house = "<%=iHouse %>";
		 var lock = "<%=iLock %>";
		 var custName1 ="<%=doString.DisplayThai(custName) %>";
		 var tel1= "<%=doString.DisplayThai(tel) %>";
		 var status1= "<%=status %>";
		 window.opener.doPopupSubmit(dDate,tTime,proj,idoc,house,lock,custName1,tel1,status1);
	}
	window.close(); 
}
</script>
<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<form action="" name="frm" method="post">
<input type="hidden" name="projectDDL" value="<%=sel_project %>">
<input type="hidden" name="iLock" value="<%=iLock %>">
<input type="hidden" name="iDocno" value="<%=iDocno %>">
<input type="hidden" name="iHouse" value="<%=iHouse %>">
<input type="hidden" name="custName" value="<%=doString.DisplayThai(custName) %>">
<input type="hidden" name="tel" value="<%=doString.DisplayThai(tel) %>">
<input type="hidden" name="status" value="<%=status %>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">
          &nbsp; ข้อมูลพื้นฐาน</td>
        </tr>
      </table>
<br style="font-size:10pt">
   <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">แก้ไขกำหนดเวลานัดเข้าตรวจสอบรายการซ่อม</td>
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
		    <select name="projectDDL" class="box7" style='width:250' size='1' disabled="disabled" > 
			<option value="">------ กรุณาเลือกโครงการ ------</option>
   			<%
					if(projectDDL!=null && projectDDL.size()>0){
						   List  arrList = null;
							Iterator it = projectDDL.iterator();
							String select = "";
						     String strValue = "";
							while(it.hasNext()){
						     select = "";
							 strValue = ""; 									
							 arrList =(ArrayList)it.next();										
							 strValue = doString.checkString(arrList.get(0).toString());
							if (strValue.equals(sel_project)){
								select="selected"; 
							}else{ 
								select=""; 
							} %>
								<option value="<%=strValue%>"  <%=select %>><%=arrList.get(0).toString() %>
								&nbsp;<%=doString.checkString(doString.DisplayThai(arrList.get(1).toString())) %></option>
						<%}
				} %>	 
   				</select> 
		    </td>
		    <td height="22" class="item ; dotline01" width="14%">เลขที่เอกสาร :</td>
		    <td height="22" width="32%" class="dotline01"><input type="text" name="iDocno" class="box" style="width:100px" value="<%=iDocno%>" disabled="disabled"></td>
		  </tr>
		  <tr>
		    <td class="item ; dotline01" height="22" width="15%">บ้านเลขที่ :</td>
		    <td height="22" width="39%" class="dotline01"><input type="text" name="iHouse" class="box" style="width:100px" value="<%=iHouse%>" disabled="disabled"></td>
		    <td height="22" class="item ; dotline01" width="14%">แปลง :</td>
		    <td height="22" width="32%" class="dotline01"> <input type="text" name="iLock" class="box" style="width:100px" value="<%=iLock%>" disabled="disabled">&nbsp;&nbsp;&nbsp;&nbsp;
		     &nbsp; </td>
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
        <tr>
            <td class="col_name" width="15%">วันเวลาที่แจ้ง</td>
            <td class="col_name" width="17%">จากวันนัดเข้าตรวจสอบ</td>
            <td class="col_name" width="68%">เปลี่ยนเป็น</td>
		</tr>
	   
	   	<%
		 if(resultList!=null && resultList.size()> 0){
		 		StringBuffer ddTemp = new StringBuffer();
		 		StringBuffer ttTemp = new StringBuffer();
		 		StringBuffer temp = new  StringBuffer();
				 %>
				  <tr>
		          <td class="dotline ; item" ><%
					//2012-07-13 12:00:00.0 		          		
		          	if(resultList.get(5)!=null && !"".equals(resultList.get(5))){
		          		ddTemp.delete(0,ddTemp.length());
		          		ttTemp.delete(0,ttTemp.length());
		          		temp.delete(0,temp.length());
		          		String [] str = resultList.get(5).toString().split(" ");
		          		ddTemp.append(thaiDateFormate(str[0])); //2012-08-01
		          		String [] str2 = str[1].split("\\:");
		          		ttTemp.append(str2[0]+":"+str2[1]);
		          		//temp.append();
		          		out.println("&nbsp;"+ddTemp.toString()+" "+ttTemp.toString()+" น.");
		          	}else{
		          	   out.println("&nbsp;");
		          	}    
		          %></td>
				   <td class="dotline" align="left" >
		          <% //2012-07-13 12:00:00.0 		          		
		          	if(resultList.get(8)!=null && !"".equals(resultList.get(8))){
		          		ddTemp.delete(0,ddTemp.length());
		          		ttTemp.delete(0,ttTemp.length());
		          		temp.delete(0,temp.length());
		          		String [] str = resultList.get(8).toString().split(" ");
		          		ddTemp.append(thaiDateFormate(str[0])); //2012-08-01
		          		String [] str2 = str[1].split("\\:");
		          		ttTemp.append(str2[0]+":"+str2[1]);
		          		//temp.append();
		          		out.println(GetDayOfWeek[Integer.parseInt(resultList.get(9).toString())]+"&nbsp;"+ddTemp.toString()+" "+ttTemp.toString()+" น.");
		          	}else{
		          	   out.println("&nbsp;");
		          	}
		          %> 
		          </td> 
		         <td class="dotline ; item" >&nbsp;
		         <%
		         if(dateList != null && dateList.size()>0){
		      			//for date
		      			List arrList = new ArrayList();
		      			Iterator it = dateList.iterator();
		      			%>	ระบุวันเวลาให้เจ้าหน้าที่เข้าตรวจสอบ&nbsp;
		      			<span class="dotline01">
		      			<select name="dateDDL"  onchange="javascript:doChangeDateDDL();">
		      			<option value="">--กรุณาระบุวันที่ -- </option>
		      			<%String selected = "";
		      			int x = 0;      			
						while(it.hasNext()){
							x = 0;
						 	arrList =(ArrayList)it.next();				 	
						 	x = Integer.parseInt(arrList.get(1).toString());
						   if(arrList.get(0).equals(dateDDL)){
						 		selected ="selected"; 
						 	}else{
						 		selected = "";
						 	}%>
							<option value="<%=arrList.get(0)%>" <%=selected %> >วัน<%=GetDayOfWeek[x] %> &nbsp;<%=thaiDateFormate(arrList.get(0).toString())%></option>	
						 	<%
						 }%>
						 </select><font color="#FF0000"> *</font> 
						 </span>
				 <%
      		}
	       %> 
	       	    &nbsp;  เวลา &nbsp;  
	 			<select name="timeDDL"  >
		 		<option value="">--กรุณาระบุเวลา-- </option>   
	        <%
	        if(timeList!=null && timeList.size()>0){
	        	List arrList = new ArrayList();
      			Iterator it = timeList.iterator();
      			String selected = "";    			
				while(it.hasNext()){
					arrList =(ArrayList)it.next();
					if(arrList.get(0).equals("")){
				 		selected ="selected"; 
				 	}else{
				 		selected = "";
				 	}
					%>
					<option value="<%=arrList.get(0)%>"  <%=selected %>><%=arrList.get(0)%></option>	
				 <%}
				}
         %>  </select><font color="#FF0000"> *</font> 
              </td>    
		     </tr>
		<%				 	
		 }else{
		 %>
	      
	        <tr><td class="dotline" colspan="5">&nbsp;</td></tr>
	        <tr><td class="dotline" colspan="5" align="center">&nbsp;ยังไม่มีข้อมูล</td></tr>
	        <tr><td class="dotline" colspan="5">&nbsp;</td>
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
<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="150" class="act_tab2"> 
            <a href="javascript:doSubmit();"><img border="0" src="images/act_submit.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
             	&nbsp;<!--  <input type="button" name="close" value ="Close" onclick="javascript:window.close();"> --> 
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
</BODY>

</HTML>
