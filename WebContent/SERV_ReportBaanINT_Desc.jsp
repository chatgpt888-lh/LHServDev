<%@page language="java" contentType="text/html; charset=TIS-620"
	pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="java.util.Date" %>
<%@page import="java.text.*" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="serv.common.*" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%-- 
/**********************************************/
 * create by : pradoem wonkraso
 * date time: 2015.03.11
 * Last modify :
 * version :1.0
 * project Name : 
 * description : for detail แนะนำบ้าน
***************************************************/
--%>
<%!
	public static  String toDDMMYY_THAI2(String str){
			if ((str == null) || str.equals("")) {
				return  str;
			}else{
				String d2[] = str.split("\\-"); //2013-03-29
				return d2[2]+"/"+d2[1]+"/"+(Integer.parseInt(d2[0])+543);
			}
	}
	public static String getHeaderDescription(String fstatus,String args1){	
		String ret = "";
		if ((fstatus == null) || fstatus.equals("")) {
			return "";
		}else{
			if("CLS".equals(fstatus) && "".equals(args1)){
				ret= "นัดหมายได้ ";
			}else if("CLS".equals(fstatus) && "7".equals(args1)){
				ret= "นัดหมายได้ภายใน 7 วัน ";
			}else if("CLS".equals(fstatus) && "8".equals(args1)){
				ret= "นัดหมายได้ภายใน 8-14 วัน ";
			}else if("CLS".equals(fstatus) && "15".equals(args1)){
				ret= "นัดหมายได้ภายใน 15-30 วัน ";
			}else if("CLS".equals(fstatus) && "30".equals(args1)){
				ret= "นัดหมายได้ภายใน >30 วัน ";
			}else if("CLSCAN".equals(fstatus)){
				ret= "ติดต่อไม่ได้/ไม่รับนัด ";
			}else if("CAN".equals(fstatus)){
				ret= "ยกเลิกนัด ";
			}else if("001".equals(fstatus)){
				ret= "ติดต่อไม่ได้/ไม่รับนัด 1 ครั้ง ";
			}else if("002".equals(fstatus)){
				ret= "ติดต่อไม่ได้/ไม่รับนัด 2 ครั้ง ";
			}else if("003".equals(fstatus)){
				ret= "ติดต่อไม่ได้/ไม่รับนัด 3 ครั้ง ";
			}else if("004".equals(fstatus)){
				ret= "ติดต่อไม่ได้/ไม่รับนัดมากกว่า 3 ครั้ง ";
			}else if("confirm".equals(fstatus)){
				ret= "ยืนยันการนัดหมาย ";
			}else if("confirmTEL".equals(fstatus)){
				ret= "โทรยืนยัน ";
			}else if("confirmSMS".equals(fstatus)){
				ret= "SMS ยืนยัน ";
			}else if("0801".equals(fstatus)){
				ret= "Service Site เข้าแนะนำบ้านแล้ว ";
			}else if("fserviceY".equals(fstatus)){
				ret= "นัดหมายโดย Service Site ";
			}
	        return ret;
		}
	}
 %>
<%

//****************************************** 
Object  objDescHD     = request.getAttribute("listDescHD");
ArrayList listDescHD = null;

if(objDescHD!=null){ listDescHD = (ArrayList)objDescHD;
}else{  listDescHD = new ArrayList();}

ArrayList projSelectdList = (ArrayList)request.getAttribute("projSelectdList");
//ArrayList vendorList = (ArrayList)request.getAttribute("vendorList");

//-----------------------Paging--------------------------
String displayLine = request.getAttribute("displayLine")==null?"20":request.getAttribute("displayLine").toString();  
String displayLinkPage = request.getAttribute("displayLinkPage")==null?"":request.getAttribute("displayLinkPage").toString();  
String recordNo = request.getAttribute("recordNo")==null?"1":request.getAttribute("recordNo").toString();  
Object obj2 = request.getAttribute("pageNoDDL");
ArrayList  pageList = null;
if(obj2!=null){
   pageList = (ArrayList)obj2;
}else{
  pageList = new ArrayList();
}
//-----------------------Paging--------------------------  

 //------------------------- 
String multiFlag = doString.checkString(request.getParameter("multiFlag"),""); //0=ALL Project,1= By project	  			
String systemName = doString.checkString(request.getParameter("systemName"),""); 
String args2 = doString.checkString(request.getParameter("args2"),""); //Day
String fStatus = doString.checkString(request.getParameter("fStatus"),""); 
String startDate = doString.checkString(request.getParameter("startDate"),""); 
String endDate = doString.checkString(request.getParameter("endDate"),"");  
  
%>

<%@page import="java.math.BigDecimal"%>
<HTML>
<HEAD>
<TITLE>รายละเอียด รายงานสรุปแนะนำบ้าน</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">
 	//call from  utilizer.genLinkNextPageHTML
	 function changePage(nowPage) {
		do_totals1();
		document.forms[0].nowPage.value=nowPage;
		document.forms[0].action="<%=request.getContextPath() %>/SERV_ReportINTBaanServlet?cmd=desc";
		document.forms[0].submit();
	 } 	
	
	 function onChangePageNomber() {
	     do_totals1();
		 document.forms[0].action="<%=request.getContextPath() %>/SERV_ReportINTBaanServlet?cmd=desc";
		 document.forms[0].submit();
	 }
	<%
		    int MAX_REC_NO = 0;
		    if(listDescHD!=null){
		       MAX_REC_NO = listDescHD.size();
		       if( MAX_REC_NO > Integer.parseInt(displayLine)){
		          MAX_REC_NO = Integer.parseInt(displayLine);
		       }
		    }
	%>
	 function doInit(){
		 //alert("test");
	    // document.getElementById("chkShow").checked=false;
		 <%
		 for(int i=1;i<=MAX_REC_NO;i++){
		 %>
		 	document.getElementById("subDetail<%=i%>").style.display='none';
		 <%	
		 }
		 %>
 	} 
	 function doViewDesc(param){		    
	     if(param==true) {	 
		 	  <%
			 for(int i=1;i<=MAX_REC_NO;i++){
			 %>
			 	document.getElementById("subDetail<%=i%>").style.display='';
			 <%	
			 }
			 %>
	     }else {
		 	  <%
			 for(int i=1;i<=MAX_REC_NO;i++){
			 %>
			 	document.getElementById("subDetail<%=i%>").style.display='none';
			 <%	
			 }
			 %>
	     }
   }
	
</script>
<script language="javascript">

    function do_totals1() {
   	 	document.all.pleasewaitScreen.style.pixelTop = (document.body.scrollTop + 120);
    	document.all.pleasewaitScreen.style.visibility = "visible";
	    document.getElementById("img1").innerHTML= "<img src=\"<%=request.getContextPath()%>/images/p_loading.gif\" HEIGHT=\"60px\">";
    }
    function do_totals2() {
    document.all.pleasewaitScreen.style.visibility = "hidden";
    }
    function lengthy_calculation() {
    	while(true) {
    	}
    }
</script>
<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="doInit();">

<FORM ACTION="" METHOD="POST">

<input type="hidden" name="nowPage" >
<input type="hidden" name="systemName" value="<%=systemName%>">
<input type="hidden" name="args2" value="<%=args2%>">
<input type="hidden" name="fStatus" value="<%=fStatus %>">
<input type="hidden" name="startDate" value="<%=startDate %>">
<input type="hidden" name="endDate" value="<%=endDate %>">
<input type="hidden" name="multiFlag" value="<%=multiFlag %>">


<%-- ############################## --%>
<DIV ID="pleasewaitScreen" STYLE="position: absolute; z-index: 0; top: 45%; left: 42%; visibility: hidden">
<TABLE BORDER="1" BORDERCOLOR="rgb(180,210,250)" CELLPADDING="0" CELLSPACING="0" 
HEIGHT="125px" WIDTH="265px" ID="Table1">
<TR>
<TD BGCOLOR="#FFFFFF" ALIGN="CENTER" VALIGN="MIDDLE" class="test">
<font color="rgb(255,120,0)"><b>Loading... Please wait</b></font>
<br>
<br>
  <span id="img1"></span>
</TD> 
</TR>
</TABLE>
</DIV>
<%-- ############################## --%>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp; รายงานสรุปแนะนำบ้านตามช่วงเดือน</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                
          <td class="item_tab2" width="200">รายละเอียดรายงานแนะนำบ้านที่ระบุ</td>
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
    <td class="item ; dotline01" height="22" colspan="4">ระหว่างวันที่ : <%=toDDMMYY_THAI2(startDate) %> ถึง  <%=toDDMMYY_THAI2(endDate)  %></td>
  </tr>
   <%  
    String projectID = ""; 
    if(multiFlag.equals("0")){
   			%>
   			<tr><td class="item ; dotline01" height="22" width="10%">โครงการ : เลือกทุกโครงการ</td></tr>
   			<%
        }else{
		 if(projSelectdList!=null && projSelectdList.size()>0){		
			ArrayList strList = null;	
			String tempNameProject = "";
			String tempProjectId = "";	
			  int line = 0;
			 //-----------------------			 
			Iterator it = projSelectdList.iterator();								   							   
			while(it.hasNext()){									
				strList =(ArrayList)it.next();
				tempNameProject = "";		
				tempProjectId = "";									
				tempProjectId = doString.checkString(strList.get(0).toString());//LH:075
				tempNameProject =doString.checkString(strList.get(1).toString());
				
				//LH:075|LH:011|LH:234				 
				if(projectID.equals("")){
					projectID = tempProjectId;
				}else{
				   projectID  +="|"+tempProjectId;
				}
				
				if (line==0) {%>
					<tr><td class="item ; dotline01" height="22" width="10%">โครงการ :</td>
				<%} else if (line%3==0 && line!=0) {  
				%><tr><td class="item ; dotline01" height="22" width="10%">&nbsp;</td><%
			     }	
			     %><td height="22" width="30%" class="dotline01"> <%=tempNameProject%></td><%
				  if (line%3==2) {
						%></tr><%
				  }
				  line++;
			  }//#end while

		  while (line%3!=0) {
			  %><td height="22" width="30%" class="dotline01">&nbsp;</td><%
			  line++;
		 	  if (line%3==0) {
		 	  	out.print("</tr>");
			  }
		  }//#End while
    }//#End if check null
  }//End check All project
 %>   
</table>
<input type="hidden" name="tempProjectTxt" value="<%=projectID %>"> 

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
          		<td class="item_tab2" width="200">รายละเอียดสรุปแนะนำบ้าน</td>
           		<td class="item_tab3" >&nbsp;</td>
          		<td align="left" class="item ;" style="padding-left:20">  <%=getHeaderDescription(fStatus,args2) %> </td>
          		<td align="right">
          		<input name="chkShow" type="checkbox" onClick="JavaScript:doViewDesc(this.checked);"> แสดงรายละเอียด           
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;
                 <font style="color:rgb(0,120,255)">แสดง&nbsp;
			  	<select name="pageNoDDL" id="pageNoDDL" class="box" style="width:45px" onchange="javascript:onChangePageNomber();">
					 <%
					 		Collections.sort(pageList);
							String selected = "";
							for(int i=0;i<pageList.size();i++){
								if(pageList.get(i).toString().equals(displayLine)){
									selected ="selected"; 
								}else{
									selected = "";
								}
								%>
								<option value="<%=pageList.get(i)%>"   <%=selected %>> <%=pageList.get(i)%></option>	
								<%		     	
							}//End 
						     %>
						   </select>รายการ&nbsp;
			    </font>

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
try{
 %>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr> 
          <td width="100%" class="frmL">
			<table border="0" width="100%" cellspacing="0" cellpadding="0">

			  <!--========================== Header Table ===========================---->
              <tr> 
                 <td width="5%" height="1" class="col_name">โครงการ</td>
                <td width="20%" height="1" class="col_name">โครงการ</td>
                <td width="5%" height="1" class="col_name">แปลง</td>
                <td width="5%" align="center" valign="middle" class="col_name">บ้านเลขที่</td>
                <td width="15%" align="center" valign="middle" class="col_name">ชื่อลูกค้า</td>
                <td width="20%" align="center" valign="middle" class="col_name">โทรศัพย์ติดต่อ</td>
                <td width="10%" align="center" valign="middle" class="col_name">วันที่โอน</td>
                <td width="10%" align="center" valign="middle" class="col_name">วันนัดหมาย</td>
                <td width="10%" align="center" valign="middle" class="col_name">สถานะ</td>
              </tr>
			  <!--==================================================================---->
			  <%
			  String tagColorBG1=" bgcolor='#ffffff' ";
			  //int sumColumn = 0;
			  if(listDescHD!=null && listDescHD.size()>0){	
			      Iterator itX = null;
			      ArrayList strRec = null;
				  Iterator it = listDescHD.iterator();								   							   		
				  //---------------------
				  ArrayList strArr = null;
				  
				  int x = 0;
				  int recId = 1;
				  List strList =null;
				  String tempDesc = "";
				  //---------------------		
				  while(it.hasNext()){
					  //Extract data array 2dimension
					  strArr = (ArrayList)it.next();
					  
					  tagColorBG1= "  bgcolor='#f7f7f7'  "; //#dcf0ff
					  if(x%2==0){
					  	   tagColorBG1= " bgcolor='#ffffff' ";
					  }	
					  
					  //-----------------
					  strList =null;
					  tempDesc = "";	
					  strList = (ArrayList)strArr.get(11);	
					  
					  if(strList!=null && strList.size()>0){
					      itX = null;
					      itX = strList.iterator();					  
						  while(itX.hasNext()){
						     //Extract data array 2dimension
						     strRec = (ArrayList)itX.next();
						     if(tempDesc.equals("")){
						        if(!strRec.get(1).toString().equals("") && !strRec.get(5).toString().equals("")){
									tempDesc = strRec.get(1).toString()+":"+strRec.get(5).toString()+" &nbsp; "+strRec.get(3).toString();
								}
							}else{
								 if(!strRec.get(1).toString().equals("") && !strRec.get(5).toString().equals("")){
							  		 tempDesc  +="&nbsp;&nbsp;&nbsp;,"+strRec.get(1).toString()+":"+strRec.get(5).toString()+" &nbsp; "+strRec.get(3).toString();
							     }
							}
					  	  }//#End while Loop
					 }//#End Check Null
			   	%>
	              <tr <%=tagColorBG1 %>> 
	                <td width="%" valign="middle" align="center" class="dotline"> <%=strArr.get(0)%>-<%=strArr.get(1)%> </td>
	              	<td width="%" valign="middle"  class="dotline"> <%=strArr.get(2).toString()%></td>
	                <td width="%" valign="middle" align="center" class="dotline"><%=strArr.get(3)%></td>
	                <td width="%" align="left" valign="middle" class="dotline"><%=strArr.get(5)%></td>
	                <td width="%" align="left" valign="middle" class="dotline"><%=strArr.get(6).toString()%></td>
	                <td width="%" align="left" valign="middle" class="dotline"><%=strArr.get(7).toString()%></td>
	                <td width="%" align="center" valign="middle" class="dotline">&nbsp;<%=strArr.get(8)%></td>
	                <td width="%" align="center" valign="middle" class="dotline">&nbsp;<%=strArr.get(9)%></td>
	                <td width="%" align="center" valign="middle" class="dotline">&nbsp;<%
	                if("CLS".equals(strArr.get(4).toString())){
	                	out.println("นัดหมายได้");
	                }else if("CAN".equals(strArr.get(4).toString())){
	                	out.println("ยกเลิก");
	                }else{
	                  out.println("ติดต่อไม่ได้ครั้งที่  "+strArr.get(4).toString());
	                }	
	                %></td>
	              </tr>
	              <% if(!tempDesc.equals("")) {%>
		            <tr <%=tagColorBG1 %> id="subDetail<%=recId++ %>">	                
				        <td colspan="10" class="dotline" style="border-bottom:1px solid rgb(135,185,247) ; padding-left:68"><font color="dotline"> รายละเอียด :&nbsp;</font><%=tempDesc%></td>
			      	</tr>
				 <%} %>
              	<%    x++;
              	   }//#End while Loop
              }//#End data grid
        	 else{ //No record or data
        	  %>
				<tr align="left" > 
                       <td  height="22"  align="center" colspan="9" class="side01" >***ไม่มีข้อมูล***</td>
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
          <td width="100%" align="right"><b>&nbsp;&nbsp;&nbsp;
			<%=displayLinkPage %>&nbsp;&nbsp;</b></td>
        </tr>
      </table>

<br style="font-size:5pt">


<br style="font-size:3pt">
      <br style="font-size:10pt">

        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="80" class="act_tab2">&nbsp;
			<%-- 
            <img border="0" src="images/act_print.gif"  onclick="javascript:printReport();" 
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">&nbsp; 
                  	--%>
            </td>      
                  	
                  	
            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="javascript:history.back();" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
          </tr>
        </table>


          <%-- </td>
        </tr>
      </table>
      --%>

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
<%}catch(Exception e){
  System.out.println("!!Errors : SERV_ReportBaanINT_View.jsp :"+e.toString());
} %>
