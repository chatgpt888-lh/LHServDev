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
<%-- 
/**********************************************/
 * create by : pradoem wonkraso
 * date time: 2015.02.25
 * Last modify :
 * version :1.0
 * project Name : 
 * description : 
***************************************************/
--%>
<%
String APPOINT_IN_7_DAY= "7";
String APPOINT_IN_8_DAY= "8";
//String APPOINT_IN_14_DAY= "14";
String APPOINT_IN_15_DAY= "15";
String APPOINT_IN_30_DAY= "30";


String thaiMonth[] = new String[] {"","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม",""};
//String shortMonth[] = new String[] {"ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค.",""};
DecimalFormat  format1 = new DecimalFormat("#,###,##0");
DecimalFormat  format2 = new DecimalFormat("#,###,##0.0");
//******************************************
  Object obj = request.getAttribute("rptMainDataList");
  ArrayList  dataGridTableList = null;
  if(obj != null){
  	dataGridTableList =(ArrayList)obj;
  }else{
    dataGridTableList = new ArrayList();
  }
  //Dispay Header
  
  Object objDateQuery = request.getAttribute("COULUMN_DATE_QUERY");
  Object objHeader = request.getAttribute("COULUMN_MONTH_YEAR");
  String []COULUMN_MONTH_HD = null;
  if(objHeader != null){
  	COULUMN_MONTH_HD =(String[])objHeader;
  }
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
<TITLE>รายงานสรุปแนะนำบ้าน</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
function doDetails(sys,args1,f_status,fdate,tdate){
	//alert(sys+","+args1+","+f_status+","+fdate+","+tdate);
	do_totals1();
	document.forms[0].systemName.value = sys;
	document.forms[0].args2.value = args1;
	document.forms[0].fStatus.value = f_status;
	document.forms[0].startDate.value = fdate;//yyyy-MM-dd
	document.forms[0].endDate.value = tdate;//yyyy-MM-dd
	document.forms[0].action="<%=request.getContextPath() %>/SERV_ReportINTBaanServlet?cmd=desc";
	document.forms[0].submit();
	
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

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM ACTION="" METHOD="POST">
<input type="hidden" name="systemName">
<input type="hidden" name="args2">
<input type="hidden" name="fStatus">
<input type="hidden" name="startDate">
<input type="hidden" name="endDate">
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
    <td class="item ; dotline01" height="22" colspan="4">เดือน : <%=thaiMonth[Integer.parseInt(mmDDL1)]%> &nbsp; พ.ศ. <%=Integer.parseInt(yyDDL1)+543%> &nbsp; &nbsp; , ประเภท : <%=rbtType%> เดือน</td>
  </tr>
   <%  String projectID = "";  
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
                <td width="19%" height="1" class="col_name">รายละเอียดสรุปแนะนำบ้าน</td>
                <td width="10%" height="1" class="col_name">ผู้รับผิดชอบ</td>
                <%
                if(COULUMN_MONTH_HD!=null){
                   for(int i = 0;i<12;i++){   
                   	   if(i<MAX_LOOP){               
                      %>
                        <td width="4%" align="center" valign="middle" class="col_name"><%=COULUMN_MONTH_HD[i] %></td>
                      <%
                      }else{
                      	out.println("<td width='4%' align='center' valign='middle' class='col_name' >&nbsp;</td> ");
                      }
                   }
                }
                 %>
                <td width="5%" align="center" valign="middle" class="col_name">รวม</td>
              </tr>
			  <!--==================================================================---->
			  <%
			  String tagColorBG1=" bgcolor='#ffffff' ";
	       	  String tagColorBG2=" bgcolor='#f7f7f7' ";
			  
			  String[] str = null;	
			  int sumColumn = 0;
			  int sumNotAppoint = 0;
			  double percenTag  = 0d;	
			  
			  double sumColumn1 = 0d;
			  double sumColumn2 = 0d;
			  double sumPercenTag  =0d;
			  if(dataGridTableList!=null && dataGridTableList.size()>0){	
				   		 Iterator it = dataGridTableList.iterator();								   							   		
						 //---------------------
						 String strMatrix[][] = null;
						 //---------------------		
						 if(it.hasNext()){
						  //Extract data array 2dimension
						  strMatrix = (String[][])it.next();
				   	     }
			   %>
              <tr <%=tagColorBG1 %>> 
                	<td  height="1" align="center" class="dotline"><div align="left">บ้านโอน</div></td>
                	<td width="10%"  valign="middle" class="dotline" >&nbsp;</td>
                	 <%  //--------Display Line to table 
                	 	 sumColumn = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){
					             sumColumn += Integer.parseInt(strMatrix[0][i]);
					         	%>
					         	<td align="center" valign="middle" class="item ; dotline"  >&nbsp;<%=strMatrix[0][i] %></td> 
				           <% }else{
				           		out.println("<td align='center' valign='middle' class='dotline' >&nbsp;</td>  ");
				             }
				         }//End while loop 
				         %> 
                	<td align="center" valign="middle" class="item ; dotline">&nbsp;<%=format1.format(sumColumn)%></td>
              </tr>
             <tr <%=tagColorBG2 %>> 
                	<td  height="1" align="center" class="dotline"><div align="left">นัดหมายได้</div></td>
                	<td width="10%"  valign="middle" class="dotline" >&nbsp;Call Center</td>
                	 <%  //--------Display Line to table 
                	 	 sumColumn = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){
					             sumColumn += Integer.parseInt(strMatrix[1][i]);    
					             if(Integer.parseInt(strMatrix[1][i])>0){
									%>
									 <td align="center" valign="middle" class="dotline"  >
									 <a href="javascript:doDetails('SVC','','CLS','<%=getFirstDate(COULUMN_DATE_QUERY[i])%>','<%=getToDate(COULUMN_DATE_QUERY[i])%>')"><%=strMatrix[1][i] %></a></td> 
									<%					               
					             }else{
					             %>
					                <td align="center" valign="middle" class="dotline"  >&nbsp;<%=strMatrix[1][i] %></td> 
				                 <% 
				                }
				            }else{
				           		out.println("<td align='center' valign='middle' class='dotline' >&nbsp;</td>  ");
				             }
				         }//End while loop 
				         if(sumColumn>0){
				            %>
				               <td align="center" valign="middle" class="dotline"  >
							   <a href="javascript:doDetails('SVC','','CLS','<%=getFirstDate(COULUMN_DATE_QUERY[MAX_LOOP-1])%>','<%=getToDate(COULUMN_DATE_QUERY[0])%>')"><%=format1.format(sumColumn)%></a></td> 				               
				            <%
				         }else{
				         %> 
				             <td align="center" valign="middle" class="dotline">&nbsp;<%=format1.format(sumColumn)%></td>
				        <%} %>
              </tr>
              
              <tr <%=tagColorBG1 %>> 
                	<td  height="1" align="center" class="item ; dotline"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> นัดหมายได้ภายใน 7 วัน</div></td>
                	<td width="10%"  valign="middle" class="dotline" >&nbsp;Call Center</td>
                	 <%  //--------Display Line to table 
                	 	 sumColumn = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){
					             sumColumn += Integer.parseInt(strMatrix[2][i]);
					             if(Integer.parseInt(strMatrix[2][i])>0){
									%>
									 <td align="center" valign="middle" class="dotline"  >
									 <a href="javascript:doDetails('SVC','<%=APPOINT_IN_7_DAY%>','CLS','<%=getFirstDate(COULUMN_DATE_QUERY[i])%>','<%=getToDate(COULUMN_DATE_QUERY[i])%>')"><%=strMatrix[2][i] %></a></td> 
									<%					               
					             }else{
					         	   %>
					         	    <td align="center" valign="middle" class="dotline"  >&nbsp;<%=strMatrix[2][i] %></td> 					         	
				              <%   }
				             }else{
				           		out.println("<td align='center' valign='middle' class='dotline' >&nbsp;</td>  ");
				             }
				         }//End while loop 
 						if(sumColumn>0){
				            %>
				               <td align="center" valign="middle" class="dotline"  >
							   <a href="javascript:doDetails('SVC','<%=APPOINT_IN_7_DAY%>','CLS','<%=getFirstDate(COULUMN_DATE_QUERY[MAX_LOOP-1])%>','<%=getToDate(COULUMN_DATE_QUERY[0])%>')"><%=format1.format(sumColumn)%></a></td> 				               
				            <%
				         }else{
				         %> 
				             <td align="center" valign="middle" class="dotline">&nbsp;<%=format1.format(sumColumn)%></td>
				        <%} %>				         
              </tr>              
              <tr <%=tagColorBG2 %>> 
                	<td  height="1" align="center" class="item ; dotline"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> นัดหมายได้ภายใน 8-14 วัน</div></td>
                	<td width="10%"  valign="middle" class="dotline" >&nbsp;Call Center</td>
                	 <%  //--------Display Line to table 
                	 	 sumColumn = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){
					             sumColumn += Integer.parseInt(strMatrix[3][i]);
					             if(Integer.parseInt(strMatrix[3][i])>0){
									%>
									 <td align="center" valign="middle" class="dotline"  >
									 <a href="javascript:doDetails('SVC','<%=APPOINT_IN_8_DAY%>','CLS','<%=getFirstDate(COULUMN_DATE_QUERY[i])%>','<%=getToDate(COULUMN_DATE_QUERY[i])%>')"><%=strMatrix[3][i] %></a></td> 
									<%					               
					             }else{
					         	   %>
					         	    <td align="center" valign="middle" class="dotline"  >&nbsp;<%=strMatrix[3][i] %></td> 					         	
				            <%   }					         	
				            }else{
				           		out.println("<td align='center' valign='middle' class='dotline' >&nbsp;</td>  ");
				             }
				         }//End while loop 
 						if(sumColumn>0){
				            %>
				               <td align="center" valign="middle" class="dotline"  >
							   <a href="javascript:doDetails('SVC','<%=APPOINT_IN_8_DAY%>','CLS','<%=getFirstDate(COULUMN_DATE_QUERY[MAX_LOOP-1])%>','<%=getToDate(COULUMN_DATE_QUERY[0])%>')"><%=format1.format(sumColumn)%></a></td> 				               
				            <%
				         }else{
				         %> 
				             <td align="center" valign="middle" class="dotline">&nbsp;<%=format1.format(sumColumn)%></td>
				        <%} %>	
              </tr>  
             <tr <%=tagColorBG1 %>> 
                	<td  height="1" align="center" class="item ; dotline"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> นัดหมายได้ภายใน 15-30 วัน</div></td>
                	<td width="10%"  valign="middle" class="dotline" >&nbsp;Call Center</td>
                	 <%  //--------Display Line to table 
                	 	 sumColumn = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){
					             sumColumn += Integer.parseInt(strMatrix[4][i]);
					             if(Integer.parseInt(strMatrix[4][i])>0){
									%>
									 <td align="center" valign="middle" class="dotline"  >
									 <a href="javascript:doDetails('SVC','<%=APPOINT_IN_15_DAY%>','CLS','<%=getFirstDate(COULUMN_DATE_QUERY[i])%>','<%=getToDate(COULUMN_DATE_QUERY[i])%>')"><%=strMatrix[4][i] %></a></td> 
									<%					               
					             }else{
					         	   %>
					         	    <td align="center" valign="middle" class="dotline"  >&nbsp;<%=strMatrix[4][i] %></td> 					         	
				            <%   }					         	
				            }else{
				           		out.println("<td align='center' valign='middle' class='dotline' >&nbsp;</td>  ");
				             }
				         }//End while loop 
 						if(sumColumn>0){
				            %>
				               <td align="center" valign="middle" class="dotline"  >
							   <a href="javascript:doDetails('SVC','<%=APPOINT_IN_15_DAY%>','CLS','<%=getFirstDate(COULUMN_DATE_QUERY[MAX_LOOP-1])%>','<%=getToDate(COULUMN_DATE_QUERY[0])%>')"><%=format1.format(sumColumn)%></a></td> 				               
				            <%
				         }else{
				         %> 
				             <td align="center" valign="middle" class="dotline">&nbsp;<%=format1.format(sumColumn)%></td>
				        <%} %>
              </tr>   
             <tr <%=tagColorBG2 %>> 
                	<td  height="1" align="center" class="item ; dotline"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> นัดหมายได้ภายใน >30 วัน</div></td>
                	<td width="10%"  valign="middle" class="dotline" >&nbsp;Call Center</td>
                	 <%  //--------Display Line to table 
                	 	 sumColumn = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){
					             sumColumn += Integer.parseInt(strMatrix[5][i]);
					             if(Integer.parseInt(strMatrix[5][i])>0){
									%>
									 <td align="center" valign="middle" class="dotline"  >
									 <a href="javascript:doDetails('SVC','<%=APPOINT_IN_30_DAY%>','CLS','<%=getFirstDate(COULUMN_DATE_QUERY[i])%>','<%=getToDate(COULUMN_DATE_QUERY[i])%>')"><%=strMatrix[5][i] %></a></td> 
									<%					               
					             }else{
					         	   %>
					         	    <td align="center" valign="middle" class="dotline"  >&nbsp;<%=strMatrix[5][i] %></td> 					         	
				            <%   }					         	
				            }else{
				           		out.println("<td align='center' valign='middle' class='dotline' >&nbsp;</td>  ");
				             }
				         }//End while loop 
 						if(sumColumn>0){
				            %>
				               <td align="center" valign="middle" class="dotline"  >
							   <a href="javascript:doDetails('SVC','<%=APPOINT_IN_30_DAY%>','CLS','<%=getFirstDate(COULUMN_DATE_QUERY[MAX_LOOP-1])%>','<%=getToDate(COULUMN_DATE_QUERY[0])%>')"><%=format1.format(sumColumn)%></a></td> 				               
				            <%
				         }else{
				         %> 
				             <td align="center" valign="middle" class="dotline">&nbsp;<%=format1.format(sumColumn)%></td>
				        <%} %>
              </tr> 
 
              <%-- ################### SUMMARY ###########################--%>
               <tr <%=tagColorBG1 %>> 
                	<td  height="1" align="center" class="solidline03"><div align="left">&nbsp;คิดเป็น % </div></td>
                	<td width="10%"  valign="middle" class="solidline03" >&nbsp;</td>
                	 <%  //--------Display Line to table 
                	 	 sumColumn = 0;
                	     sumColumn1 = 0f;
			             sumColumn2 = 0f;
			             sumPercenTag  =0f;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){ 
				         	     percenTag = 0d;
				         	     if(Double.parseDouble(strMatrix[0][i])>0){
					             	percenTag = (Double.parseDouble(strMatrix[1][i])/Double.parseDouble(strMatrix[0][i]))*100;
					             }else{
					             	percenTag = 0d;
					             }
					             //----------------------
					             sumColumn1 +=Double.parseDouble(strMatrix[0][i]) ;
					             sumColumn2 +=Double.parseDouble(strMatrix[1][i]) ;
					             
					         	%>
					         	<td align="center" valign="middle" class="solidline03"  >&nbsp;<%=format2.format(percenTag)%> %</td> 
				           <% }else{
				           		out.println("<td align='center' valign='middle' class='solidline03' >&nbsp;</td>  ");
				             }
				         }//End while loop 
				         if(sumColumn1>0){
				           sumPercenTag = (sumColumn2/sumColumn1)*100;
				         }else{
				           sumPercenTag = 0;
				         }
				         %> 
                	<td align="center" valign="middle" class="solidline03">&nbsp;<%=format2.format(sumPercenTag)%> %</td>
              </tr>  
               <%-- ################### SUMMARY ###########################--%>           
               
             <%-- ################### SUMMARY ###########################--%>              
              <tr <%=tagColorBG2 %>> 
                	<td  height="1" align="center" class="dotline"><div align="left">นัดหมายไม่ได้</div></td>
                	<td width="10%"  valign="middle" class="dotline" >&nbsp;Call Center</td>
                	 <%  //--------Display Line to table 
                	 	 sumColumn = 0;
                	 	 sumNotAppoint = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){
				         	    sumNotAppoint = 0;
				         	    sumNotAppoint  = Integer.parseInt(strMatrix[0][i])-Integer.parseInt(strMatrix[1][i]);
					            sumColumn   += sumNotAppoint;
					         	%>
					         	<td align="center" valign="middle" class="item ; dotline"  >&nbsp;<%=sumNotAppoint %></td> 
				           <% }else{
				           		out.println("<td align='center' valign='middle' class='dotline' >&nbsp;</td>  ");
				             }
				         }//End while loop 
				         %> 
                	<td align="center" valign="middle" class="item ; dotline">&nbsp;<%=format1.format(sumColumn)%></td>
              </tr>  
              <%-- ################### SUMMARY ###########################--%>           

              <tr <%=tagColorBG1 %>> 
                	<td  height="1" align="center" class="item ; dotline"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> ติดต่อไม่ได้/ไม่รับนัด</div></td>
                	<td width="10%"  valign="middle" class="dotline" >&nbsp;Call Center</td>
                	 <%  //--------Display Line to table 
                	 	 sumColumn = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){
					             sumColumn += Integer.parseInt(strMatrix[6][i]);
					             if(Integer.parseInt(strMatrix[6][i])>0){ 
									%>
									 <td align="center" valign="middle" class="dotline"  >
									 <a href="javascript:doDetails('SVC','','CLSCAN','<%=getFirstDate(COULUMN_DATE_QUERY[i])%>','<%=getToDate(COULUMN_DATE_QUERY[i])%>')"><%=strMatrix[6][i] %></a></td> 
									<%					               
					             }else{
					         	   %>
					         	    <td align="center" valign="middle" class="dotline"  >&nbsp;<%=strMatrix[6][i] %></td> 					         	
				            <%   }					         	
				            }else{
				           		out.println("<td align='center' valign='middle' class='dotline' >&nbsp;</td>  ");
				             }
				         }//End while loop 
 						if(sumColumn>0){
				            %>
				               <td align="center" valign="middle" class="dotline"  >
							   <a href="javascript:doDetails('SVC','','CLSCAN','<%=getFirstDate(COULUMN_DATE_QUERY[MAX_LOOP-1])%>','<%=getToDate(COULUMN_DATE_QUERY[0])%>')"><%=format1.format(sumColumn)%></a></td> 				               
				            <%
				         }else{
				         %> 
				             <td align="center" valign="middle" class="dotline">&nbsp;<%=format1.format(sumColumn)%></td>
				        <%} %>
              </tr>  
             <tr <%=tagColorBG2 %>> 
                	<td  height="1" align="center" class="item ; dotline"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> ยกเลิกนัด</div></td>
                	<td width="10%"  valign="middle" class="dotline" >&nbsp;Call Center</td>
                	 <%  //--------Display Line to table   
                	 	 sumColumn = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){
					             sumColumn += Integer.parseInt(strMatrix[7][i]);
					             if(Integer.parseInt(strMatrix[7][i])>0){ 
									%>
									 <td align="center" valign="middle" class="dotline"  >
									 <a href="javascript:doDetails('SVC','','CAN','<%=getFirstDate(COULUMN_DATE_QUERY[i])%>','<%=getToDate(COULUMN_DATE_QUERY[i])%>')"><%=strMatrix[7][i] %></a></td> 
									<%					               
					             }else{
					         	   %>
					         	    <td align="center" valign="middle" class="dotline"  >&nbsp;<%=strMatrix[7][i] %></td> 					         	
				            <%   }					         	
				            }else{
				           		out.println("<td align='center' valign='middle' class='dotline' >&nbsp;</td>  ");
				             }
				         }//End while loop 
 						if(sumColumn>0){
				            %>
				               <td align="center" valign="middle" class="dotline"  >
							   <a href="javascript:doDetails('SVC','','CAN','<%=getFirstDate(COULUMN_DATE_QUERY[MAX_LOOP-1])%>','<%=getToDate(COULUMN_DATE_QUERY[0])%>')"><%=format1.format(sumColumn)%></a></td> 				               
				            <%
				         }else{
				         %> 
				             <td align="center" valign="middle" class="dotline">&nbsp;<%=format1.format(sumColumn)%></td>
				        <%} %>
              </tr>   
              
              <%-- ################### SUMMARY ###########################--%>
             <tr <%=tagColorBG1 %>> 
                	<td  height="1" align="center" class="item ; solidline03"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> ยังไม่ได้แนะนำ(ยังไม่ได้ทำการโทรนัดหมาย)</div></td>
                	<td width="10%"  valign="middle" class="solidline03" >&nbsp;Call Center</td>
                	 <%  //--------Display Line to table 
                	 	 sumColumn = 0;
                	 	 sumNotAppoint = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){
					          sumNotAppoint = 0;
				         	  sumNotAppoint  = ((Integer.parseInt(strMatrix[0][i])-Integer.parseInt(strMatrix[1][i])) - Integer.parseInt(strMatrix[6][i])- Integer.parseInt(strMatrix[7][i]));
					          sumColumn   += sumNotAppoint;
					        
					         	%>
					         	<td align="center" valign="middle" class="solidline03"  >&nbsp;<%=format1.format(sumNotAppoint)%></td> 
				           <% }else{
				           		out.println("<td align='center' valign='middle' class='solidline03' >&nbsp;</td>  ");
				             }
				         }//End while loop 
				         %> 
                	<td align="center" valign="middle" class="solidline03">&nbsp;<%=format1.format(sumColumn)%></td>
              </tr> 
              <%-- ################### SUMMARY ###########################--%>  
              
              
             <tr <%=tagColorBG2 %>> 
                	<td  height="1" align="center" class="dotline"><div align="left">ติดต่อไม่ได้/ไม่รับนัด</div></td>
                	<td width="10%"  valign="middle" class="dotline" >&nbsp;Call Center</td>
                	 <%  //--------Display Line to table 
                	 	 sumColumn = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){
					             sumColumn += Integer.parseInt(strMatrix[6][i]);
					             if(Integer.parseInt(strMatrix[6][i])>0){ 
									%>
									 <td align="center" valign="middle" class="dotline"  >
									 <a href="javascript:doDetails('SVC','','CLSCAN','<%=getFirstDate(COULUMN_DATE_QUERY[i])%>','<%=getToDate(COULUMN_DATE_QUERY[i])%>')"><%=strMatrix[6][i] %></a></td> 
									<%					               
					             }else{
					         	   %>
					         	    <td align="center" valign="middle" class="dotline"  >&nbsp;<%=strMatrix[6][i] %></td> 					         	
				            <%   }					         	
				            }else{
				           		out.println("<td align='center' valign='middle' class='dotline' >&nbsp;</td>  ");
				             }
				         }//End while loop 
 						if(sumColumn>0){
				            %>
				               <td align="center" valign="middle" class="dotline"  >
							   <a href="javascript:doDetails('SVC','','CLSCAN','<%=getFirstDate(COULUMN_DATE_QUERY[MAX_LOOP-1])%>','<%=getToDate(COULUMN_DATE_QUERY[0])%>')"><%=format1.format(sumColumn)%></a></td> 				               
				            <%
				         }else{
				         %> 
				             <td align="center" valign="middle" class="dotline">&nbsp;<%=format1.format(sumColumn)%></td>
				        <%} %>
              </tr>   
             <tr <%=tagColorBG1%>> 
                	<td  height="1" align="center" class="item ; dotline"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> ติดต่อไม่ได้/ไม่รับนัด 1 ครั้ง</div></td>
                	<td width="10%"  valign="middle" class="dotline" >&nbsp;Call Center</td>
                	 <%  //--------Display Line to table 
                	 	 sumColumn = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){
					             sumColumn += Integer.parseInt(strMatrix[8][i]);
					             if(Integer.parseInt(strMatrix[8][i])>0){ 
									%>
									 <td align="center" valign="middle" class="dotline"  >
									 <a href="javascript:doDetails('SVC','','001','<%=getFirstDate(COULUMN_DATE_QUERY[i])%>','<%=getToDate(COULUMN_DATE_QUERY[i])%>')"><%=strMatrix[8][i] %></a></td> 
									<%					               
					             }else{
					         	   %>
					         	    <td align="center" valign="middle" class="dotline"  >&nbsp;<%=strMatrix[8][i] %></td> 					         	
				            <%   }					         	
				            }else{
				           		out.println("<td align='center' valign='middle' class='dotline' >&nbsp;</td>  ");
				             }
				         }//End while loop 
 						if(sumColumn>0){
				            %>
				               <td align="center" valign="middle" class="dotline"  >
							   <a href="javascript:doDetails('SVC','','001','<%=getFirstDate(COULUMN_DATE_QUERY[MAX_LOOP-1])%>','<%=getToDate(COULUMN_DATE_QUERY[0])%>')"><%=format1.format(sumColumn)%></a></td> 				               
				            <%
				         }else{
				         %> 
				             <td align="center" valign="middle" class="dotline">&nbsp;<%=format1.format(sumColumn)%></td>
				        <%} %>
              </tr>   
              <tr <%=tagColorBG2%>> 
                	<td  height="1" align="center" class="item ; dotline"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> ติดต่อไม่ได้/ไม่รับนัด 2 ครั้ง</div></td>
                	<td width="10%"  valign="middle" class="dotline" >&nbsp;Call Center</td>
                	 <%  //--------Display Line to table 
                	 	 sumColumn = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){
					             sumColumn += Integer.parseInt(strMatrix[9][i]);
					             if(Integer.parseInt(strMatrix[9][i])>0){ 
									%>
									 <td align="center" valign="middle" class="dotline"  >
									 <a href="javascript:doDetails('SVC','','002','<%=getFirstDate(COULUMN_DATE_QUERY[i])%>','<%=getToDate(COULUMN_DATE_QUERY[i])%>')"><%=strMatrix[9][i] %></a></td> 
									<%					               
					             }else{
					         	   %>
					         	    <td align="center" valign="middle" class="dotline"  >&nbsp;<%=strMatrix[9][i] %></td> 					         	
				            <%   }					         	
				            }else{
				           		out.println("<td align='center' valign='middle' class='dotline' >&nbsp;</td>  ");
				             }
				         }//End while loop 
 						if(sumColumn>0){
				            %>
				               <td align="center" valign="middle" class="dotline"  >
							   <a href="javascript:doDetails('SVC','','002','<%=getFirstDate(COULUMN_DATE_QUERY[MAX_LOOP-1])%>','<%=getToDate(COULUMN_DATE_QUERY[0])%>')"><%=format1.format(sumColumn)%></a></td> 				               
				            <%
				         }else{
				         %> 
				             <td align="center" valign="middle" class="dotline">&nbsp;<%=format1.format(sumColumn)%></td>
				        <%} %>
              </tr>   
             <tr <%=tagColorBG1%>> 
                	<td  height="1" align="center" class="item ; dotline"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> ติดต่อไม่ได้/ไม่รับนัด 3 ครั้ง</div></td>
                	<td width="10%"  valign="middle" class="dotline" >&nbsp;Call Center</td>
                	 <%  //--------Display Line to table 
                	 	 sumColumn = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){
					             sumColumn += Integer.parseInt(strMatrix[10][i]);
					             if(Integer.parseInt(strMatrix[10][i])>0){ 
									%>
									 <td align="center" valign="middle" class="dotline"  >
									 <a href="javascript:doDetails('SVC','','003','<%=getFirstDate(COULUMN_DATE_QUERY[i])%>','<%=getToDate(COULUMN_DATE_QUERY[i])%>')"><%=strMatrix[10][i] %></a></td> 
									<%					               
					             }else{
					         	   %>
					         	    <td align="center" valign="middle" class="dotline"  >&nbsp;<%=strMatrix[10][i] %></td> 					         	
				            <%   }					         	
				            }else{
				           		out.println("<td align='center' valign='middle' class='dotline' >&nbsp;</td>  ");
				             }
				         }//End while loop 
 						if(sumColumn>0){
				            %>
				               <td align="center" valign="middle" class="dotline"  >
							   <a href="javascript:doDetails('SVC','','003','<%=getFirstDate(COULUMN_DATE_QUERY[MAX_LOOP-1])%>','<%=getToDate(COULUMN_DATE_QUERY[0])%>')"><%=format1.format(sumColumn)%></a></td> 				               
				            <%
				         }else{
				         %> 
				             <td align="center" valign="middle" class="dotline">&nbsp;<%=format1.format(sumColumn)%></td>
				        <%} %>
              </tr>   
             <tr <%=tagColorBG2%>> 
                	<td  height="1" align="center" class="item ; solidline03"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> ติดต่อไม่ได้/ไม่รับนัดมากกว่า 3 ครั้ง</div></td>
                	<td width="10%"  valign="middle" class="solidline03" >&nbsp;Call Center</td>
                	 <%  //--------Display Line to table 
                	 	 sumColumn = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){
					             sumColumn += Integer.parseInt(strMatrix[11][i]);
					             if(Integer.parseInt(strMatrix[11][i])>0){ 
									%>
									 <td align="center" valign="middle" class="solidline03"  >
									 <a href="javascript:doDetails('SVC','','004','<%=getFirstDate(COULUMN_DATE_QUERY[i])%>','<%=getToDate(COULUMN_DATE_QUERY[i])%>')"><%=strMatrix[11][i] %></a></td> 
									<%					               
					             }else{
					         	   %>
					         	    <td align="center" valign="middle" class="solidline03"  >&nbsp;<%=strMatrix[11][i] %></td> 					         	
				            <%   }					         	
				            }else{
				           		out.println("<td align='center' valign='middle' class='solidline03' >&nbsp;</td>  ");
				             }
				         }//End while loop 
 						if(sumColumn>0){
				            %>
				               <td align="center" valign="middle" class="solidline03"  >
							   <a href="javascript:doDetails('SVC','','004','<%=getFirstDate(COULUMN_DATE_QUERY[MAX_LOOP-1])%>','<%=getToDate(COULUMN_DATE_QUERY[0])%>')"><%=format1.format(sumColumn)%></a></td> 				               
				            <%
				         }else{
				         %> 
				             <td align="center" valign="middle" class="solidline03">&nbsp;<%=format1.format(sumColumn)%></td>
				        <%} %>
              </tr>                

 
             <tr <%=tagColorBG1%>> 
                	<td  height="1" align="center" class="dotline"><div align="left">ยืนยันการนัดหมาย</div></td>
                	<td width="10%"  valign="middle" class="dotline" >&nbsp;Call Center</td>
                	 <%  //--------Display Line to table    confirm
                	 	 sumColumn = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){
					             sumColumn += Integer.parseInt(strMatrix[13][i]);
					             if(Integer.parseInt(strMatrix[13][i])>0){ 
									%>
									 <td align="center" valign="middle" class="dotline"  >
									 <a href="javascript:doDetails('SVC','','confirm','<%=getFirstDate(COULUMN_DATE_QUERY[i])%>','<%=getToDate(COULUMN_DATE_QUERY[i])%>')"><%=strMatrix[13][i] %></a></td> 
									<%					               
					             }else{
					         	   %>
					         	    <td align="center" valign="middle" class="dotline"  >&nbsp;<%=strMatrix[13][i] %></td> 					         	
				            <%   }					         	
				            }else{
				           		out.println("<td align='center' valign='middle' class='dotline' >&nbsp;</td>  ");
				             }
				         }//End while loop 
 						if(sumColumn>0){
				            %>
				               <td align="center" valign="middle" class="dotline"  >
							   <a href="javascript:doDetails('SVC','','confirm','<%=getFirstDate(COULUMN_DATE_QUERY[MAX_LOOP-1])%>','<%=getToDate(COULUMN_DATE_QUERY[0])%>')"><%=format1.format(sumColumn)%></a></td> 				               
				            <%
				         }else{
				         %> 
				             <td align="center" valign="middle" class="dotline">&nbsp;<%=format1.format(sumColumn)%></td>
				        <%} %>
              </tr>   
             <tr <%=tagColorBG2%>> 
                	<td  height="1" align="center" class="item ; dotline"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> โทรยืนยัน</div></td>
                	<td width="10%"  valign="middle" class="dotline" >&nbsp;Call Center</td>
                	 <%  //--------Display Line to table confirmTEL
                	 	 sumColumn = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){
					             sumColumn += Integer.parseInt(strMatrix[14][i]);
					             if(Integer.parseInt(strMatrix[14][i])>0){ 
									%>
									 <td align="center" valign="middle" class="dotline"  >
									 <a href="javascript:doDetails('SVC','','confirmTEL','<%=getFirstDate(COULUMN_DATE_QUERY[i])%>','<%=getToDate(COULUMN_DATE_QUERY[i])%>')"><%=strMatrix[14][i] %></a></td> 
									<%					               
					             }else{
					         	   %>
					         	    <td align="center" valign="middle" class="dotline"  >&nbsp;<%=strMatrix[14][i] %></td> 					         	
				            <%   }					         	
				            }else{
				           		out.println("<td align='center' valign='middle' class='dotline' >&nbsp;</td>  ");
				             }
				         }//End while loop 
 						if(sumColumn>0){
				            %>
				               <td align="center" valign="middle" class="dotline"  >
							   <a href="javascript:doDetails('SVC','','confirmTEL','<%=getFirstDate(COULUMN_DATE_QUERY[MAX_LOOP-1])%>','<%=getToDate(COULUMN_DATE_QUERY[0])%>')"><%=format1.format(sumColumn)%></a></td> 				               
				            <%
				         }else{
				         %> 
				             <td align="center" valign="middle" class="dotline">&nbsp;<%=format1.format(sumColumn)%></td>
				        <%} %>
              </tr>   
              
             <tr <%=tagColorBG1%> > 
                	<td  height="1" align="center" class="item ; solidline03"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> SMS ยืนยัน</div></td>
                	<td width="10%"  valign="middle" class="solidline03" >&nbsp;Call Center</td>
                	 <%  //--------Display Line to table   confirmSMS
                	 	 sumColumn = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){
					             sumColumn += Integer.parseInt(strMatrix[15][i]);
					             if(Integer.parseInt(strMatrix[15][i])>0){ 
									%>
									 <td align="center" valign="middle" class="solidline03"  >
									 <a href="javascript:doDetails('SVC','','confirmSMS','<%=getFirstDate(COULUMN_DATE_QUERY[i])%>','<%=getToDate(COULUMN_DATE_QUERY[i])%>')"><%=strMatrix[15][i] %></a></td> 
									<%					               
					             }else{
					         	   %>
					         	    <td align="center" valign="middle" class="solidline03"  >&nbsp;<%=strMatrix[15][i] %></td> 					         	
				            <%   }					         	
				            }else{
				           		out.println("<td align='center' valign='middle' class='solidline03' >&nbsp;</td>  ");
				             }
				         }//End while loop 
 						if(sumColumn>0){
				            %>
				               <td align="center" valign="middle" class="solidline03"  >
							   <a href="javascript:doDetails('SVC','','confirmSMS','<%=getFirstDate(COULUMN_DATE_QUERY[MAX_LOOP-1])%>','<%=getToDate(COULUMN_DATE_QUERY[0])%>')"><%=format1.format(sumColumn)%></a></td> 				               
				            <%
				         }else{
				         %> 
				             <td align="center" valign="middle" class="solidline03">&nbsp;<%=format1.format(sumColumn)%></td>
				        <%} %>
              </tr> 
            <tr <%=tagColorBG2%> > 
                	<td  height="1" align="center" class="item ; solidline03"><div align="left">&nbsp;</div></td>
                	<td width="10%"  valign="middle" class="solidline03" >&nbsp;</td>
                	 <%  //--------Display Line to table 
                	 	 sumColumn = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
					         	%>
					         	<td align="center" valign="middle" class="solidline03"  >&nbsp;</td> 
				         <%}
				         %> 
                	<td align="center" valign="middle" class="solidline03">&nbsp;</td>
              </tr> 
              
             <tr <%=tagColorBG1%>> 
                	<td  height="1" align="center" class="dotline"><div align="left"><font color="#4cb848">Service Site เข้าแนะนำบ้านแล้ว</font></div></td>
                	<td width="10%"  valign="middle" class="dotline" ><font color="#4cb848">&nbsp;Service Site</font></td>
                	 <%  //--------Display Line to table   service   0801
                	 	 sumColumn = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){
					             sumColumn += Integer.parseInt(strMatrix[12][i]);
					             if(Integer.parseInt(strMatrix[12][i])>0){ 
									%>
									 <td align="center" valign="middle" class="dotline"  ><font color="#4cb848">
									 <a href="javascript:doDetails('service','','0801','<%=getFirstDate(COULUMN_DATE_QUERY[i])%>','<%=getToDate(COULUMN_DATE_QUERY[i])%>')"><%=strMatrix[12][i] %></a></font></td> 
									<%					               
					             }else{
					         	   %>
					         	    <td align="center" valign="middle" class="dotline"  ><font color="#4cb848">&nbsp;<%=strMatrix[12][i] %></font></td> 					         	
				            <%   }					         	
				            }else{
				           		out.println("<td align='center' valign='middle' class='dotline' >&nbsp;</td>  ");
				             }
				         }//End while loop 
 						if(sumColumn>0){
				            %>
				               <td align="center" valign="middle" class="dotline"  ><font color="#4cb848">
							   <a href="javascript:doDetails('service','','0801','<%=getFirstDate(COULUMN_DATE_QUERY[MAX_LOOP-1])%>','<%=getToDate(COULUMN_DATE_QUERY[0])%>')"><%=format1.format(sumColumn)%></a></font></td> 				               
				            <%
				         }else{
				         %> 
				             <td align="center" valign="middle" class="dotline"><font color="#4cb848">&nbsp;<%=format1.format(sumColumn)%></font></td>
				        <%} %>
              </tr>   
              
                 <%-- ################### SUMMARY ###########################--%>  
             <tr <%=tagColorBG2%>> 
                	<td  height="1" align="center" class="dotline"><div align="left"><font color="#4cb848">Service Site ยังไม่เข้าแนะนำบ้าน(ยังไม่ถึงวันนัดหมาย)</font></div></td>
                	<td width="10%"  valign="middle" class="dotline" ><font color="#4cb848">&nbsp;Serviec Site</td>
                	 <%  //--------Display Line to table 
                	 	 sumColumn = 0;
                	 	 sumNotAppoint = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){
					          sumNotAppoint = 0;
				         	  sumNotAppoint  = Integer.parseInt(strMatrix[1][i])-Integer.parseInt(strMatrix[12][i]);
					          sumColumn   += sumNotAppoint;
					         	%>
					         	<td align="center" valign="middle" class="dotline"  ><font color="#4cb848">&nbsp;<%=sumNotAppoint%></font></td> 
				           <% }else{
				           		out.println("<td align='center' valign='middle' class='dotline' >&nbsp;</td>  ");
				             }
				         }//End while loop 
				         %> 
                	<td align="center" valign="middle" class="dotline"><font color="#4cb848">&nbsp;<%=format1.format(sumColumn)%></font></td>
              </tr>   
              <%-- ################### SUMMARY ###########################--%>  
             <tr <%=tagColorBG1%>> 
                	<td  height="1" align="center" class="dotline"><div align="left"><font color="#4cb848">นัดหมายโดย Service Site</font></div></td>
                	<td width="10%"  valign="middle" class="dotline" ><font color="#4cb848">&nbsp;Service Site</font></td>
                	 <%  //--------Display Line to table   service  fservcieY
                	 	 sumColumn = 0;
				         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
				         	if(i<MAX_LOOP){
					             sumColumn += Integer.parseInt(strMatrix[16][i]);
					             if(Integer.parseInt(strMatrix[16][i])>0){ 
									%>
									 <td align="center" valign="middle" class="dotline"  ><font color="#4cb848">
									 <a href="javascript:doDetails('service','','fservcieY','<%=getFirstDate(COULUMN_DATE_QUERY[i])%>','<%=getToDate(COULUMN_DATE_QUERY[i])%>')"><%=strMatrix[16][i] %></a></font></td> 
									<%					               
					             }else{
					         	   %>
					         	    <td align="center" valign="middle" class="dotline"  ><font color="#4cb848">&nbsp;<%=strMatrix[16][i] %></font></td> 					         	
				            <%   }					         	
				            }else{
				           		out.println("<td align='center' valign='middle' class='dotline' >&nbsp;</td>  ");
				             }
				         }//End while loop 
 						if(sumColumn>0){
				            %>
				               <td align="center" valign="middle" class="dotline"  ><font color="#4cb848">
							   <a href="javascript:doDetails('service','','fservcieY','<%=getFirstDate(COULUMN_DATE_QUERY[MAX_LOOP-1])%>','<%=getToDate(COULUMN_DATE_QUERY[0])%>')"><%=format1.format(sumColumn)%></a></font></td> 				               
				            <%
				         }else{
				         %> 
				             <td align="center" valign="middle" class="dotline"><font color="#4cb848">&nbsp;<%=format1.format(sumColumn)%></font></td>
				        <%} %>
              </tr> 

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
  System.out.println("!!Errors : SERV_ReportBaanINT_View.jsp :"+e.toString());
} %>
