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
 * date time: 2016.05.19
 * Last modify :
 * version :1.0
 * project Name : Report  IPV by QC
 * description :  Report  เก็บก่อนโอนแยกตามรายเดือน 
***************************************************/
--%>
<%!
		private static String lastDayOfMonth(int year,int month){
			  Calendar calendar = Calendar.getInstance(Locale.ENGLISH);  

			  calendar.set(Calendar.YEAR, year);
		      calendar.set(Calendar.MONTH, month-1);
		        
		      calendar.add(Calendar.MONTH, 1);  
		      calendar.set(Calendar.DAY_OF_MONTH, 1);  
		      calendar.add(Calendar.DATE, -1);  
		      
		      Date lastDayOfMonth = calendar.getTime();  
		      DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");  	      
		      return  sdf.format(lastDayOfMonth);
		}
		
		private static String getFirstDate(String args){////YYYY-MM-DD
			String []strArr = args.split("\\-");
			return strArr[0]+"-"+strArr[1]+"-01";
		}
		private static String getToDate(String args){//YYYY-MM-DD
			String []strArr = args.split("\\-");
			return lastDayOfMonth(Integer.parseInt(strArr[0]),Integer.parseInt(strArr[1]));
		}
 %>
<%
String thaiMonth[] = new String[] {"","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม",""};
String shortMonth[] = new String[] {"","ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค.",""};
DecimalFormat  format1 = new DecimalFormat("#,###,##0");
DecimalFormat  format2 = new DecimalFormat("#,###,##0.0");
//******************************************

  Object objTrans = request.getAttribute("TRANS_LIST");
  ArrayList  transGridTableList = null;
  Object objKeyin = request.getAttribute("KEYIN_LIST");
  ArrayList  keyinGridTableList = null;
  
  if(objTrans != null){
  	transGridTableList =(ArrayList)objTrans;
  }else{
    transGridTableList = new ArrayList();
  }
  if(objKeyin != null){
  	keyinGridTableList =(ArrayList)objKeyin;
  }else{
    keyinGridTableList = new ArrayList();
  }
  //Dispay Header
  Object objHeader = request.getAttribute("COULUMN_MONTH_YEAR");
  String []COULUMN_MONTH_HD = null;
  if(objHeader != null){
  	COULUMN_MONTH_HD =(String[])objHeader;
  }
  
  Object objDateQuery = request.getAttribute("COULUMN_DATE_QUERY");
  String []COULUMN_DATE_QUERY = null;
  if(objDateQuery != null){
  	COULUMN_DATE_QUERY =(String[])objDateQuery;
  }
  //--project selected
  ArrayList projSelectdList = (ArrayList)request.getAttribute("projSelectdList");
  String mmDDL1 = (String)request.getAttribute("mmDDL1");
  String yyDDL1 = (String)request.getAttribute("yyDDL1");
  String rbtType = (String)request.getAttribute("rbtType");
  String maxLoopStr = request.getAttribute("MAX_LOOP")==null? "0" :request.getAttribute("MAX_LOOP").toString();
  String multiFlag = (String)request.getAttribute("multiFlag");//0=ALL


  int MAX_LOOP = Integer.parseInt(maxLoopStr);//3,6,12
  int MAX_LOOP_MONTH = 12;
%>
<%@page import="java.math.BigDecimal"%>
<HTML>
<HEAD>
<TITLE>Report เก็บก่อนโอนแยกตามเดือนโอน</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script type='text/javascript' src='jquery/jquery-1.11.3.min.js'></script>
<script type='text/javascript' src='jquery/loadImg.js'></script>
<script>
function onPleaseWait(){
	document.all.pleasewaitScreen.style.pixelTop = (document.body.scrollTop + 120);
	$('#pleasewaitScreen').show();
	setTimeout(function(){  $('#pleasewaitScreen').css("visibility", 'hidden'); }, 7000); //wait 7 seconds
	$('#pleasewaitScreen').css('visibility', 'visible');
 }
 
 function doDetails(typeName,comID,projID,F_DATE,T_DATE){
 	//onPleaseWait();
 	$('input[name="type"]').val(typeName);//1,2,3,4,5
 	$('input[name="comId"]').val(comID);
 	$('input[name="projId"]').val(projID);
 	$('input[name="fdate"]').val(F_DATE);//2016-05-01
 	$('input[name="tdate"]').val(T_DATE);//2016-05-31

 	doSubmitForm("<%=Constants.APP_PATH%>/SERV_RptKeepBeforeServlet?cmd=desc");	
 } 

 function doSubmitForm(url){
    //alert("submit");
 	$('form').attr('action', url);
	$("form:first").submit();
}


 
</script>

<style type="text/css">
td.solidline04	{	
    border-bottom:1px solid rgb(135,185,247)	; 
    border-top:1px solid rgb(135,185,247)	;
    border-right:1px solid rgb(135,185,247)	;
    padding:3px ; 
  }
 td.vline01{	
    border-right:1px dashed rgb(160,210,255)	;
    padding:3px ; 
  }
td.grandtotal{
   background-color:rgb(160,220,255);
   border-bottom:1px solid rgb(135,185,247)	; 
   border-right:1px solid rgb(135,185,247)	;
   padding:3px ; 
}  
</style>
<script language="javascript">
</script>
<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM ACTION="" METHOD="POST" target="_blank">

<input type="hidden" name="type">
<input type="hidden" name="comId">
<input type="hidden" name="projId">
<input type="hidden" name="fdate">
<input type="hidden" name="tdate">
<input type="hidden" name="multiFlag" value="<%=multiFlag %>">


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
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">
          &nbsp;หน้าสรุปรายละเอียด Report เก็บก่อนโอนแยกตามเดือนโอน</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                
          <td class="item_tab2" width="400">รายละเอียด Report เก็บก่อนโอนแยกตามเดือนโอน</td>
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
    <td class="item ; dotline01" height="22" colspan="4">เดือน : <%=thaiMonth[Integer.parseInt(mmDDL1)]%> &nbsp; พ.ศ. <%=Integer.parseInt(yyDDL1)+543%> &nbsp; &nbsp; , ประเภท : <%=rbtType%> เดือน</td>
  </tr>
   <%
     String projectID = "";
     if(multiFlag.equals("0")){
   			%>
   			<tr><td class="item ; dotline01" height="22" width="10%">โครงการ : เลือกทุกโครงการ</td></tr>
   			<%
        }else{
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
          		<td class="item_tab2" width="200">รายละเอียดสรุป</td>
           		<td class="item_tab3"></td>
          		<td>&nbsp;</td>
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
               <td width="" height="1" class="col_name"  rowspan="2">ลำดับ</td>
                <td width="3%" height="1" class="col_name"  rowspan="2">รหัส</td>
                <td width="%" height="1" class="col_name" rowspan="2">ชื่อโครงการ</td>
                <%
                if(COULUMN_MONTH_HD!=null){
                   for(int i = 0;i<12;i++){   
                   	   if(i<MAX_LOOP){               
                      %> 
                         <td width="%" align="center" valign="middle" class="col_name" colspan="2"><%=COULUMN_MONTH_HD[i] %></td>
                      <%
                      }else{
                      	//out.println("<td width='7%' align='center' valign='middle' class='col_name'  colspan='4' >&nbsp;</td> ");
                      }
                   }
                }
                 %>
                <td width="%" align="center" valign="middle" class="col_name"  colspan="2">รวม</td>
              </tr>
              <tr>
              
              <%
                if(COULUMN_MONTH_HD!=null){
                   for(int i = 0;i<12;i++){   
                   	   if(i<MAX_LOOP){               
                      %> 
                        <td width="%" align="center" valign="middle" class="col_nameLow" >โอน</td>
                        <td width="%" align="center" valign="middle" class="col_nameLow" >Key</td>
                      <%
                      }else{
                      	//out.println("<td width='%' align='center' valign='middle' class='col_nameLow'  colspan='4'>&nbsp;</td> ");
                      }
                   }
                }
                 %>
                <td width="%" align="center" valign="middle" class="col_nameLow"  >โอน</td>
                <td width="%" align="center" valign="middle" class="col_nameLow"  >Key</td>
              </tr>
			  <!--==================================================================---->
			  <%
			  String tagColorBG1=" bgcolor='#ffffff' ";
	       	  String tagColorBG2=" bgcolor='#f7f7f7' ";
			  String tagColorBG = "";	
	  
			 int sumColumnArr1[] = new int[MAX_LOOP];
			 int sumColumnArr2[] = new int[MAX_LOOP];
			 int sumTotal1 = 0;
			 int sumTotal2 = 0;

			 if((transGridTableList!=null && transGridTableList.size()>0) || (keyinGridTableList!=null && keyinGridTableList.size()>0)){	
 				 Iterator it = transGridTableList.iterator();		
 				 Iterator it2 = keyinGridTableList.iterator();							   							   		
				  //---------------------
				  String strMatrixTrans[] = null;
				  String strMatrixKey[] = null;
				  
				  int sumColumn1 = 0;
				  int sumColumn2 = 0;

				  
			  	  int loop = 3;
				  String tagBreak = "";
				  int ROW = 0;
				  int CountLoop = 1;

				  //---------------------
				  while(it.hasNext()){
					//Extract data array 2dimension
					strMatrixTrans = (String[])it.next();
					strMatrixKey =(String[])it2.next();	

					ROW++;
					
					tagColorBG = tagColorBG1;
					if(ROW%2==0){
					   tagColorBG = tagColorBG2;
					}
					//-------------------------------------
				     sumColumn1 = 0;
				     sumColumn2 = 0;
					//-------------------------------------			
			   		%>
			   		<%--  ============================Fetch data ================================================--%>
	                <tr <%=tagColorBG %>> 
	                	<td   height="1" align="center" class="dotline" nowrap="nowrap"><div align="center"><%=CountLoop %></div></td>
	                	<td  valign="middle" class="dotline" nowrap="nowrap">&nbsp;<%=strMatrixTrans[0] %>-<%=strMatrixTrans[1] %></td>
	                	<td  valign="middle" class="item ; dotline" nowrap="nowrap">&nbsp;<%=strMatrixTrans[2]%></td>
	                	 <% 
	                	 	loop = 3;
	                	 	
					         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
					         	if(i<MAX_LOOP){
					         	    sumColumn1 +=Double.parseDouble(strMatrixTrans[loop]);
					         	    sumColumn2 +=Double.parseDouble(strMatrixKey[loop]);
					         	    
					         	    sumColumnArr1[i] += Integer.parseInt(strMatrixTrans[loop]);
					         	    sumColumnArr2[i] += Integer.parseInt(strMatrixKey[loop]);	
					         	    
					         	    if(Integer.parseInt(strMatrixTrans[loop])>0){

					         	    %>
					         	        <td width="%" align="center" valign="middle" class="dotline01" >
					         	        <a href="javascript:doDetails('1','<%=strMatrixTrans[0] %>','<%=strMatrixTrans[1] %>','<%=getFirstDate(COULUMN_DATE_QUERY[i])%>','<%=getToDate(COULUMN_DATE_QUERY[i])%>')" ><%=format1.format(Double.parseDouble(strMatrixTrans[loop])) %></a>
					         	        </td> 
					         	    <%
					         	    }else{
					         	    %>
					         	         <td width="%" align="center" valign="middle" class="dotline01" ><%=format1.format(Double.parseDouble(strMatrixTrans[loop])) %></td>
					         	    <%
					         	    }				         	    
						           %>
                        			  <td width="%" align="center" valign="middle" class="dotline" ><%=format1.format(Double.parseDouble(strMatrixKey[loop])) %></td>
					               <%
					               //sumColumn = 0;
					             }else{
					           		//out.println("<td width='%' align='center' valign='middle' class='dotline'  colspan='4'>&nbsp;</td> ");
					             }
					           loop++; 
					         
					         }//End for loop 				         
					         %>
	                	<td align="center" valign="middle" class="item ; dotline01">&nbsp;
	                	<%//=format1.format(sumColumn1)
	                	if(sumColumn1>0){%>
	                	 <a href="javascript:doDetails('2','<%=strMatrixTrans[0] %>','<%=strMatrixTrans[1] %>','<%=getFirstDate(COULUMN_DATE_QUERY[MAX_LOOP-1])%>','<%=getToDate(COULUMN_DATE_QUERY[0])%>')" ><%=format1.format(sumColumn1)%></a>
	       	            <%}else{
							out.println(format1.format(sumColumn1));
	                	}%>
	                	</td>
	                	<td align="center" valign="middle" class="item ; dotline">&nbsp;<%=format1.format(sumColumn2)%></td>                	
	              </tr>
	              <%--======================================Feth Data================================================== --%>
                <% 
                	sumTotal1 +=sumColumn1;
                	sumTotal2 +=sumColumn2;
                    CountLoop++;
                }//#End while it.hasNext()	 
					//--- last total                
        			%>
        			<%-- #######################Final summary #######################--%>
        			<tr  bgcolor="#dcf0ff" >
                			<td colspan="3" align="center" class="solidline04">Grand Total <%=tagBreak%></td>
                			<%     				         					            			
                			 for(int i=0; i < MAX_LOOP_MONTH; i++) {                			     
					         	if(i<MAX_LOOP){		         							          				         	
					         	%>
						         	<td width="%" align="center" valign="middle" class="solidline04 ;" >&nbsp;<%
						         	if(sumColumnArr1[i]>0){
						         	%>
						         	<a href="javascript:doDetails('3','','','<%=getFirstDate(COULUMN_DATE_QUERY[i])%>','<%=getToDate(COULUMN_DATE_QUERY[i])%>')" ><%=format1.format(sumColumnArr1[i])%></a> 	
						         	<%
						         	}else{
						         	   out.println(format1.format(sumColumnArr1[i]));
						         	}
						         	%></td>
	                        		<td width="%" align="center" valign="middle" class="solidline04 ;" >&nbsp;<%=format1.format(sumColumnArr2[i])%></td>
					         	<%
					         	}
					         }			         
					         %>
		                	<td align="center" valign="middle" class="solidline04">&nbsp;
		                	<%
		                	if(sumTotal1>0){
		                	%>
	 						<a href="javascript:doDetails('4','','','<%=getFirstDate(COULUMN_DATE_QUERY[MAX_LOOP-1])%>','<%=getToDate(COULUMN_DATE_QUERY[0])%>')" ><%=format1.format(sumTotal1)%></a>
						    <%
		                	}else{
		                		out.println(format1.format(sumTotal1));
		                	}
		                	%></td>
		                	<td align="center" valign="middle" class="solidline04">&nbsp;<%=format1.format(sumTotal2)%></td> 
		                	        			
					<%-- #######################Grand Total summary#######################--%>
        			<%
                		 
			  }//#End data grid
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
  System.out.println("!!Errors : SERV_RptKeepBefore_02_View.jsp :"+e.toString());
} %>
