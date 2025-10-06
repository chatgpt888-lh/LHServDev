<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="java.util.Date" %>
<%@page import="java.text.*" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@ page import="com.lh.util.doString" %>
<%@ include file="/confirmLogin.jsp" %>
<%! 
	public static String Get2Digit(String temp){
	    String newSp_id;
	    switch(temp.length()){ 
	       case 1: newSp_id="0"+temp; break;
	       default:newSp_id=temp;
	    }
	    return newSp_id;
	}	
	private static  String toDDMMYY_THAI2(String str){
		 if ((str == null) || str.equals("")) {
			 return  str;
		 }else{
			 String d2[] = str.split("\\-"); //2013-03-29
			 return d2[2]+"/"+d2[1]+"/"+(Integer.parseInt(d2[0])+543);
		 }
	}
%>

<%-- 
/**********************************************/
 * create by : pradoem wonkraso
 * date time: 2016.05.25
 * Last modify :
 * version :1.0
 * project Name : LHSERV
 * description : this is page for Gen report online with search form criteria 
***************************************************/
--%>
<%
DecimalFormat  format1 = new DecimalFormat("#,###,###.00");
java.util.Calendar currentCal = java.util.Calendar.getInstance();  
java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyy-MM-dd", Locale.US);
Calendar rightNow = Calendar.getInstance();
int curday = rightNow.get(Calendar.DAY_OF_MONTH);
String month = Integer.toString(rightNow.get(Calendar.MONTH)+1);
String year = Integer.toString(rightNow.get(Calendar.YEAR));
String today = curday+"/"+Get2Digit(month)+"/"+(Integer.parseInt(year)+543);
//System.out.println("-->"+today);


Object  obIpvQCHD     = request.getAttribute("listDescHD");
ArrayList listIpvQCHD = null;

if(obIpvQCHD!=null){ listIpvQCHD = (ArrayList)obIpvQCHD;
}else{  listIpvQCHD = new ArrayList();}

ArrayList projSelectdList = (ArrayList)request.getAttribute("projSelectdList");
ArrayList projectList = (ArrayList)request.getAttribute("projectList");
//-----------------------Paging--------------------------
String displayLine = request.getAttribute("displayLine")==null?"10":request.getAttribute("displayLine").toString();  
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

String comId  = request.getAttribute("comId")==null?"": request.getAttribute("comId").toString();//LH:075
String projId  = request.getAttribute("projId")==null?"": request.getAttribute("projId").toString();//LH:075
String projName	 = request.getAttribute("projectName")==null?"": request.getAttribute("projectName").toString();//LH:075
String type     = request.getAttribute("type")==null?"1": request.getAttribute("type").toString();//0,1
String fDate     = request.getAttribute("startDate")==null?"": request.getAttribute("startDate").toString();//2014-09-22
String tDate     = request.getAttribute("endDate")==null?"": request.getAttribute("endDate").toString();//2014-09-22
String multiFlag = (String)request.getAttribute("multiFlag");//0=ALL

if("".equals(fDate)){
	fDate=today;
}
if("".equals(tDate)){
	tDate=today;
}
if("".equals(type)){
	type = "1"; //Set default Radio button
}

%>
<html>
<head>

<TITLE>รายละเอียด Report เก็บก่อนโอน</TITLE>
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
<script type='text/javascript' src='jquery/jquery-1.11.3.min.js'></script>
<script type='text/javascript' src='jquery/loadImg.js'></script>

<script language="javascript">
<!--
	function onLoad() {
	   onPleaseWait();
	}

	 function changePage(nowPage) {
		document.forms[0].nowPage.value=nowPage;
		document.forms[0].action="<%=request.getContextPath() %>/SERV_RptKeepBeforeServlet?cmd=desc";
		document.forms[0].submit();
	 } 	
	
	 function onChangePageNomber() {
		 document.forms[0].action="<%=request.getContextPath() %>/SERV_RptKeepBeforeServlet?cmd=desc";
		 document.forms[0].submit();
	 }	
//-->
</script>

<script>
function onPleaseWait(){
	document.all.pleasewaitScreen.style.pixelTop = (document.body.scrollTop + 120);
	$('#pleasewaitScreen').show();
	setTimeout(function(){  $('#pleasewaitScreen').css("visibility", 'hidden'); }, 1000); //wait 1 seconds
	$('#pleasewaitScreen').css('visibility', 'visible');
 } 
</script>

<base target="_self">
</head>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="javascript:onLoad();"">

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

<FORM name="frm1" METHOD="POST" ACTION="" >
<input type="hidden" name="nowPage">

<input type="hidden" name="type" value="<%=type %>">
<input type="hidden" name="comId" value="<%=comId %>">
<input type="hidden" name="projId" value="<%=projId %>">
<input type="hidden" name="fdate" value="<%=fDate %>">
<input type="hidden" name="tdate" value="<%=tDate %>">
<input type="hidden" name="multiFlag" value="<%=multiFlag %>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
           <td width="100%" class="bigh" align="left"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">
           &nbsp;รายละเอียดรายงานเก็บก่อนโอน</td>
          <td width="100%" align="right">          
          </td>
        </tr>
      </table>

<br style="font-size:10pt">
                

 <table border="0" width="100%" cellspacing="0" cellpadding="0">
 <tr>
     <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
     <td class="item_tab2" width="400">รายละเอียดการค้นหา</td>
     <td class="item_tab3"></td>
     <td align="left">&nbsp;</td>                
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
    <td class="item ; dotline01" height="22" colspan="4">ระหว่างวันที่ : <%=toDDMMYY_THAI2(fDate)%> &nbsp;ถึงวันที่  :  <%=toDDMMYY_THAI2(tDate)%> &nbsp; &nbsp;</td>
  </tr>
   <%
      String projectID = "";
     if(multiFlag.equals("0")){
   			%>
   			<tr><td class="item ; dotline01" height="22" width="10%">โครงการ : เลือกทุกโครงการ</td></tr>
   			<%
        }else{
         if(type.equals("1") || type.equals("2")){%>
             <tr><td class="item ; dotline01" height="22" width="10%">โครงการ : <%=comId %>-<%=projId %> &nbsp; &nbsp; <%=projName%></td></tr>
        <% }else{
                 
		 if(projSelectdList!=null && projSelectdList.size()>0){		
			//ArrayList strList = null;	
			HashMap hashMap = null;		
			String tempNameProject = "";
			String tempProjectId = "";	
			 int line = 0;
			 //-----------------------			 
			Iterator it = projSelectdList.iterator();								   							   
			while(it.hasNext()){									
				//strList =(ArrayList)it.next();
				hashMap = (HashMap)it.next();
				tempNameProject = "";		
				tempProjectId = "";									
				tempProjectId = doString.checkString(hashMap.get("value").toString());//LH:075
				tempNameProject =doString.checkString(hashMap.get("name").toString());
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
         }
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
                <td class="item_tab2" width="160">รายละเอียดรายงานเก็บก่อนโอน</td>
                <td class="item_tab3"></td>
                <td align="right">&nbsp;
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
          <td width="3%" class="col_name">No.</td>
          <td width="14%" class="col_name">โครงการ</td>
          <td width="3%" class="col_name">แปลง</td> 
          <td width="5%" class="col_name">วันที่โอน</td>
          <td width="11%" class="col_name">ผู้รับเหมา</td>
          <td width="7%" class="col_name">วันที่ Key</td>
          <td width="7%" class="col_name">เลขที่ใบเบิก</td>
          <td width="8%" class="col_name">ประเภท</td>
          <td width="7%" class="col_name">จำนวนเงิน</td>
          <td width="7%" class="col_name">วันที่จ่าย</td>
          <td width="15%" class="col_name">หมายเหตุ</td>
          <td width="5%" class="col_name"><font color="#ff7537">**</font>ประเภทการตรวจบ้าน</td>
          <td width="8%" class="col_name">บ.รับตรวจบ้าน</td>
        </tr>
        <%
         //System.out.println("listDOCHD.size :"+listDOCHD.size());
        int loopX = 0;
        String fqa_type = "";
        String qaNameVendor = "";
        if(listIpvQCHD!=null && listIpvQCHD.size()>0){
	        List strList = null;
	        String tagColor = "";
	        int loop = Integer.parseInt(recordNo)+1;
	        
	        boolean isRecord = false;
			int c = 0;
			String lockId = "";
			boolean isECHO = false;
			int comparedLoop = 0;
	        //---------------------
	        String tempType = "";
	        Iterator itHD = listIpvQCHD.iterator();
	        while(itHD.hasNext()){
	    	   strList = (ArrayList)itHD.next();
	    	   c++;
	    	   tagColor="#ffffff";
			   if((c%2)==0){
				 tagColor="#f0f0f0";
			    }
			   tempType = "";
			   
				
			   //System.out.println("--"+strList.get(8));
			   if(strList.get(7).equals("1")){
				   tempType = "จากระบบ Billing";
			   }else if(strList.get(7).equals("2")){
				   tempType = "จากระบบ PR";
			   }else if(strList.get(7).equals("3")){
				   tempType = "มีรายการยอดจ่ายเท่ากับ 0";
			   }else if(strList.get(7).equals("4")){
				   tempType = "ไม่มีรายการ";
			   }else{
				   tempType = "";
			   }  
			   
			    fqa_type = strList.get(15).toString();
        	    qaNameVendor = strList.get(16).toString();
			    isRecord = false;
			    //System.out.println("strList.get(4).toString() :"+strList.get(4).toString());
			    if("".equals(strList.get(4).toString())){
			      isRecord = true;
			    }
			
			/*System.out.println("===lockId :"+lockId);   
			System.out.println("===comparedLoop :"+comparedLoop);   
			System.out.println("===loop :"+loop); */
			isECHO = false; 
		    //!comxId.equals(strList.get(0).toString())  && !proxjId.equals(strList.get(1).toString())  &&
			if (!lockId.equals(strList.get(2).toString())) {
                if (!lockId.trim().equals("")) {
                	 loop++;
	                 //comxId = strList.get(0).toString();
					 //proxjId = strList.get(1).toString();
					 isECHO = true;
					 
                }
               lockId = strList.get(2).toString();    
            }  	   
      %>        
		        <tr height="25px" bgcolor="<%=tagColor %>">
		          <td class="dotline ; item" align="center"><%
		          if(loop==1){
					if(comparedLoop==0){
					  out.println(loop);
					}else{
					  out.println("&nbsp;");
					}	
		          }else{
		          	  if(isECHO){
			          	out.println(loop);
			          }else{
			            out.println("&nbsp;");
			          }
			      }
		          %></td>
		          <td class="dotline "><%=strList.get(0).toString()%>-<%=strList.get(1).toString()%> <%=strList.get(11).toString()%></td>
		          <td align="center" class="dotline ; item"><%=strList.get(2).toString()%></td>
		          <td align="center" class="dotline"><%=strList.get(3).toString()%></td>    
		          <td class="dotline" align="left"><%=strList.get(12).toString()%>&nbsp;</td>
		          <td  align="center" class="dotline"><%=strList.get(10).toString()%>&nbsp;</td>
		          <td  align="center" class="dotline"><%=strList.get(6).toString()%></td>
		          <td  align="left" class="dotline"><%=tempType %>&nbsp;</td>
		          <td  align="right"  class="dotline">
		          <%
		          if(Double.parseDouble(strList.get(13).toString())==0){
		              out.println("0");
		          }else{
		             out.println(format1.format(Double.parseDouble(strList.get(13).toString())));
		          } %>&nbsp;
		          </td>
		          <td  align="center"  class="dotline"><%=strList.get(14).toString()%>&nbsp;</td>
		          <td  align="center" class="dotline ; item"><%=strList.get(9).toString()%>&nbsp;
		          <% if(isRecord){
		          	out.println("***ยังไม่ Key ข้อมูล***");
		          }
		           %>
		          </td>  
		          <td  align="center" class="dotline"><%=fqa_type %>&nbsp;</td>
		          <td  align="left" class="dotline"><%=qaNameVendor %>&nbsp;</td> 		                       
		        </tr>
		        
		<%     //loop++;
		     comparedLoop++;
	       }//#End while Loop;  
	       
	       loopX = loop;
        }//#End if chec value
        else{ //No record or data
        	%>
				<tr align="left" > 
                       <td  height="22"  align="center" colspan="12" class="side01" >***ไม่มีข้อมูล***</td>
                </tr>
       <% 	
        }
		%>        	        		                                                          
      </table>
    </td>
  </tr>
</table>

<%--  <a href="javascript:doEdit('<%//=strList.get(0).toString()%>','<%//=strList.get(6).toString()%>','<%//=mode%>');" ><%//=strList.get(0).toString()%></a> --%>
 
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
<p align="left">

<font color="#ff7537">** ประเภทการตรวจบ้าน<br></font>
<font color="#ff7537">1  : &nbsp;ลูกค้าตรวจเอง<br></font>
<font color="#ff7537">2  : &nbsp;บริษัทรับตรวจบ้าน<br></font>
</p>
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">
			<%-- 
            <a href="javascript:doFrmAdd();"><img border="0" src="images/act_add.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>  
              --%>    	
            </td>      	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:history.back();" ><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="SERV_Index.jsp" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>  
        </table>  



      </td>
        </tr>
      </table>

<%-- 
          </td>
        </tr>
      </table>
--%>
<br style="font-size: 30pt">
<TABLE border="0" cellspacing="0" cellpadding="0" width="100%">
	<TBODY>
		<tr>
			<td width="100%" class="copyright" align="center">Best viewed with
			800x600 screen resolution on&nbsp;an Internet Explorer version 6 <br>
			ติดต่อสอบถามได้ที่ : <a href="mailto:dept_IT@lh.co.th">dept_IT@lh.co.th</a>&nbsp;
			หรือ โทร. 0-2230-8457 (ฝ่าย IT) <br>
			<img src="images/copyright.gif" width="475" height="26"></td>
		</tr>
	</TBODY>
</TABLE>
	
</FORM>
	
</BODY>

</HTML>
