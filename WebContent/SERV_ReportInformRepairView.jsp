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
 * date time: 2014.08.02
 * Last modify :
 * version :1.0
 * project Name : Master Data SMS send
 * description : this is page for display && Master SMS List
***************************************************/
--%>
<%
String thaiMonth[] = new String[] {"","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม",""};
String shortMonth[] = new String[] {"","ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค.",""};
DecimalFormat  format1 = new DecimalFormat("#,###,##0");
DecimalFormat  format2 = new DecimalFormat("#,###,##0.0");
//******************************************
  Object objEsv = request.getAttribute("ESERVIC_LIST");
  ArrayList  eServiceGridTableList = null;
  Object objSvc = request.getAttribute("SVC_LIST");
  ArrayList  svcCallGridTableList = null;
  
  if(objEsv != null){
  	eServiceGridTableList =(ArrayList)objEsv;
  }else{
    eServiceGridTableList = new ArrayList();
  }
  if(objSvc != null){
  	svcCallGridTableList =(ArrayList)objSvc;
  }else{
    svcCallGridTableList = new ArrayList();
  }
  //Dispay Header
  Object objHeader = request.getAttribute("COULUMN_MONTH_YEAR");
  String []COULUMN_MONTH_HD = null;
  if(objHeader != null){
  	COULUMN_MONTH_HD =(String[])objHeader;
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
<TITLE>หน้าสรุปการแจ้งซ่อมผ่าน e-Service แยกตาม Zone </TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
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

<FORM ACTION="" METHOD="POST">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;หน้าสรุปการแจ้งซ่อมผ่าน e-Service แยกตาม Zone และตามช่วงเดือน</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                
          <td class="item_tab2" width="400">รายละเอียดรายงานe-Service แยกตาม Zone และเดือนที่ระบุ</td>
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
          		<td class="item_tab2" width="200">รายละเอียดสรุปแจ้งซ่อม</td>
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
                <td width="3%" height="1" class="col_name"  rowspan="2">Zone</td>
                <td width="%" height="1" class="col_name"  rowspan="2">รหัส</td>
                <td width="%" height="1" class="col_name" rowspan="2">ชื่อโครงการ</td>
                <%
                if(COULUMN_MONTH_HD!=null){
                   for(int i = 0;i<12;i++){   
                   	   if(i<MAX_LOOP){               
                      %> 
                         <td width="%" align="center" valign="middle" class="col_name" colspan="4"><%=COULUMN_MONTH_HD[i] %></td>
                      <%
                      }else{
                      	//out.println("<td width='7%' align='center' valign='middle' class='col_name'  colspan='4' >&nbsp;</td> ");
                      }
                   }
                }
                 %>
                <td width="%" align="center" valign="middle" class="col_name"  colspan="4">รวม</td>
              </tr>
              <tr>
              
              <%
                if(COULUMN_MONTH_HD!=null){
                   for(int i = 0;i<12;i++){   
                   	   if(i<MAX_LOOP){               
                      %> 
                        <td width="%" align="center" valign="middle" class="col_nameLow" >ESV</td>
                        <td width="%" align="center" valign="middle" class="col_nameLow" >SVC</td>
                        <td width="%" align="center" valign="middle" class="col_nameLow" >Total</td>
                        <td width="%" align="center" valign="middle" class="col_nameLow" >%</td>
                      <%
                      }else{
                      	//out.println("<td width='%' align='center' valign='middle' class='col_nameLow'  colspan='4'>&nbsp;</td> ");
                      }
                   }
                }
                 %>
                <td width="%" align="center" valign="middle" class="col_nameLow"  >ESV</td>
                <td width="%" align="center" valign="middle" class="col_nameLow"  >SVC</td>
                <td width="%" align="center" valign="middle" class="col_nameLow"  >รวม</td>
                <td width="%" align="center" valign="middle" class="col_nameLow"  >%</td>
              </tr>
			  <!--==================================================================---->
			  <%
			  String tagColorBG1=" bgcolor='#ffffff' ";
	       	  String tagColorBG2=" bgcolor='#f7f7f7' ";
			  String tagColorBG = "";	

			  double percenTag  = 0d;	
			  double percenTagBreak  = 0d;	
			  double percenTagTotal  = 0d;	
			  		  
			 int sumColumnArrESV[] = new int[MAX_LOOP];
			 int sumColumnArrSVC[] = new int[MAX_LOOP];
			 int sumGrandTotalESV[] = new int[MAX_LOOP]; 
			 int sumGrandTotalSVC[] = new int[MAX_LOOP]; 
			 int totalColumnArr[] = new int [4];
			 if(svcCallGridTableList!=null && svcCallGridTableList.size()>0){	
 				 Iterator it = svcCallGridTableList.iterator();		
 				 Iterator it2 = eServiceGridTableList.iterator();							   							   		
				  //---------------------
				  String strMatrix[] = null;
				  String strMatrixEsv[] = null;
				  
				  int sumColumn = 0;
				  int sumColumnBreak = 0;
				  int sumTotal = 0;
				  int sumTotalEsv = 0;
				  int sumTotalSvc = 0;
				  int sumTotalAll = 0;
				  
			  	  int loop = 4;
				  String tagBreak = "";
				  int ROW = 0;
				  int CountLoop = 0;
				 
				 
				  //---------------------
				 totalColumnArr[0]= 0;
				 totalColumnArr[1]= 0;	
				 totalColumnArr[2]= 0;
				 totalColumnArr[3]= 0;	
				  while(it.hasNext()  && it2.hasNext()){
					//Extract data array 2dimension
					strMatrix = (String[])it.next();
					strMatrixEsv =(String[])it2.next();	
					ROW++;
					
					tagColorBG = tagColorBG1;
					if(ROW%2==0){
					   tagColorBG = tagColorBG2;
					}
					//-------------------------------------
					 sumTotalEsv = 0;
				     sumTotalSvc = 0;
				     sumTotalAll = 0;
					//-------------------------------------	
					
                	if (!tagBreak.equals(strMatrix[0])) {
                		if (!tagBreak.trim().equals("")) {
                			%>
                			<%-- ####################### break summary by Brand #######################--%>
                			<tr  bgcolor="#dcf0ff" >
                			<td colspan="3" align="center" class="solidline04">Total Zone <%=tagBreak%></td>
                			<%  
                			 sumColumnBreak = 0;              			
                			 for(int i=0; i < MAX_LOOP_MONTH; i++) {                			     
					         	if(i<MAX_LOOP){
					         	   percenTagBreak = 0d;
					         	   sumColumnBreak = 0;
					         	   sumColumnBreak +=sumColumnArrESV[i]+sumColumnArrSVC[i];
					         	   
					         	   if(sumColumnBreak>0){
						             	percenTagBreak =(Double.parseDouble(""+sumColumnArrESV[i])/Double.parseDouble(""+sumColumnBreak))*100;						             		             	
						           }else{
						             	percenTagBreak = 0d;
						           }
						           //--------------------
						           sumTotalEsv  += sumColumnArrESV[i];
						           sumTotalSvc  += sumColumnArrSVC[i];
						           sumTotalAll  += sumColumnBreak;	
						          				         	
					         	%>
						         	<td width="%" align="center" valign="middle" class="solidline04" >&nbsp;<%=format1.format(sumColumnArrESV[i])%></td>
	                        		<td width="%" align="center" valign="middle" class="solidline04" >&nbsp;<%=format1.format(sumColumnArrSVC[i])%></td>
	                       			<td width="%" align="center" valign="middle" class="solidline04" ><%=format1.format(sumColumnBreak) %></td>
	                       			<td width="%" align="center" valign="middle" class="solidline04" ><%=format2.format(percenTagBreak)%>%</td>
					         	<%
					         	}
					         }
					         //---------Sum Total Column 
					         percenTagTotal = 0d;
					         //sumTotal = 0;
					         //sumTotal = totalColumnArr[0]+totalColumnArr[1];
					         if(sumTotalAll>0){
						         percenTagTotal = (Double.parseDouble(""+sumTotalEsv)/Double.parseDouble(""+sumTotalAll))*100;	
						     }else{
						         percenTagTotal = 0d;
						    }					         
					         %>
		                	<td align="center" valign="middle" class="solidline04">&nbsp;<%=format1.format(sumTotalEsv)%></td>
		                	<td align="center" valign="middle" class="solidline04">&nbsp;<%=format1.format(sumTotalSvc)%></td>
		                	<td align="center" valign="middle" class="solidline04">&nbsp;<%=format1.format(sumTotalAll)%></td>
		                	<td align="center" valign="middle" class="solidline04">&nbsp;<%=format2.format(percenTagTotal)%>%</td>	         			
                			</tr>
                			<%-- ####################### break summary by Brand #######################--%>
                			<%
                			//sumColumn1 = 0.0;
                			//clean summary by brand
                			 for(int i=0; i < MAX_LOOP; i++) {
                			 	sumColumnArrESV[i] = 0;
                			 	sumColumnArrSVC[i] = 0;
                			 }
                			totalColumnArr[0]= 0;
							totalColumnArr[1]= 0;                			 
                		}              		
                		tagBreak = strMatrix[0];
                	}//#End if break					
								
			   		%>
			   		<%--  ============================Fetch data ================================================--%>
	                <tr <%=tagColorBG %>> 
	                	<td   height="1" align="center" class="dotline" nowrap="nowrap"><div align="center"><%=strMatrix[0] %></div></td>
	                	<td  valign="middle" class="dotline" nowrap="nowrap">&nbsp;<%=strMatrix[1] %>-<%=strMatrix[2] %></td>
	                	<td  valign="middle" class="item ; dotline" nowrap="nowrap">&nbsp;<%=strMatrix[3]%></td>
	                	 <%  //--------Display Line to table 
	                	 	 sumColumn = 0;
	                	 	 loop = 4;
							
						// totalColumnArr[0]  = 0; 
	                     //totalColumnArr[1] = 0;
	                     sumTotal  =0; 
	                     percenTagTotal   = 0d;  
							//-------------------------------	
					         for(int i=0; i < MAX_LOOP_MONTH; i++) { 
					         	if(i<MAX_LOOP){
					         	   sumColumn = 0;
						           sumColumn += Integer.parseInt(strMatrixEsv[loop])+Integer.parseInt(strMatrix[loop]);
						           						           
						           percenTag = 0d;
					         	   if(sumColumn>0){
						             	percenTag = (Double.parseDouble(strMatrixEsv[loop])/sumColumn)*100;
						           }else{
						             	percenTag = 0d;
						           }
						           //--- sumColumn
						           sumColumnArrESV[i] += Integer.parseInt(strMatrixEsv[loop]);
                			       sumColumnArrSVC[i] += Integer.parseInt(strMatrix[loop]); 
				           		   
				           		   //-----Grand total
				           		   sumGrandTotalESV[i] += Integer.parseInt(strMatrixEsv[loop]);
				           		   sumGrandTotalSVC[i] += Integer.parseInt(strMatrix[loop]); 
				           		   
				           		   //----Sum column total
				           		   totalColumnArr[0]  += Integer.parseInt(strMatrixEsv[loop]);
				           		   totalColumnArr[1]  += Integer.parseInt(strMatrix[loop]);
				           		   
				           		   totalColumnArr[2] +=Integer.parseInt(strMatrixEsv[loop]);
				           		   totalColumnArr[3] +=Integer.parseInt(strMatrix[loop]);
						           %>
						         	  <td width="%" align="center" valign="middle" class="dotline01" ><%=format1.format(Double.parseDouble(strMatrixEsv[loop])) %></td>
                        			  <td width="%" align="center" valign="middle" class="dotline01" ><%=format1.format(Double.parseDouble(strMatrix[loop])) %></td>
                       				  <td width="%" align="center" valign="middle" class="dotline01" ><%=format1.format(sumColumn) %></td>
                       				  <td width="%" align="center" valign="middle" class="item ; dotline" ><%=format2.format(percenTag)%>%</td>
					               <%
					               sumColumn = 0;
					             }else{
					           		//out.println("<td width='%' align='center' valign='middle' class='dotline'  colspan='4'>&nbsp;</td> ");
					             }
					           loop++; 
					           CountLoop++;
					         }//End for loop 
					         //---------Sum Total Column 
					         percenTagTotal = 0d;
					         sumTotal = 0;
					         sumTotal = totalColumnArr[0]+totalColumnArr[1];
					         if(sumTotal>0){
						         percenTagTotal = (Double.parseDouble(""+totalColumnArr[0])/Double.parseDouble(""+sumTotal))*100;	
						     }else{
						         percenTagTotal = 0d;
						    }					         
					         %>
	                	<td align="center" valign="middle" class="dotline01">&nbsp;<%=format1.format(totalColumnArr[0])%></td>
	                	<td align="center" valign="middle" class="dotline01">&nbsp;<%=format1.format(totalColumnArr[1])%></td>
	                	<td align="center" valign="middle" class="item ; dotline01">&nbsp;<%=format1.format(sumTotal)%></td>
	                	<td align="center" valign="middle" class="item ; dotline">&nbsp;<%=format2.format(percenTagTotal)%>%</td>	                	
	              </tr>
	              <%--======================================Feth Data================================================== --%>
                <% 
                   totalColumnArr[0] = 0; 
                   totalColumnArr[1] = 0;  
 
                }//#End while it.hasNext()	 
					//--- last total                
        			%>
        			<%-- #######################Final summary #######################--%>
        			<tr  bgcolor="#dcf0ff" >
                			<td colspan="3" align="center" class="solidline04">Total Zone <%=tagBreak%></td>
                			<%
 							 sumColumnBreak = 0;  
 							 sumTotalEsv  = 0;
						     sumTotalSvc  = 0;
						     sumTotalAll  = 0;	
						          				         					            			
                			 for(int i=0; i < MAX_LOOP_MONTH; i++) {                			     
					         	if(i<MAX_LOOP){
					         	   percenTagBreak = 0d;
					         	   sumColumnBreak = 0;
					         	   sumColumnBreak +=sumColumnArrESV[i]+sumColumnArrSVC[i];
					         	   
					         	   if(sumColumnBreak>0){
						             	percenTagBreak =(Double.parseDouble(""+sumColumnArrESV[i])/Double.parseDouble(""+sumColumnBreak))*100;						             		             	
						           }else{
						             	percenTagBreak = 0d;
						           }	
						           //--------------------
						           sumTotalEsv  += sumColumnArrESV[i];
						           sumTotalSvc  += sumColumnArrSVC[i];
						           sumTotalAll  += sumColumnBreak;	
						          				         							          				         	
					         	%>
						         	<td width="%" align="center" valign="middle" class="solidline04 ;" >&nbsp;<%=format1.format(sumColumnArrESV[i])%></td>
	                        		<td width="%" align="center" valign="middle" class="solidline04 ;" >&nbsp;<%=format1.format(sumColumnArrSVC[i])%></td>
	                       			<td width="%" align="center" valign="middle" class="solidline04 ;" ><%=format1.format(sumColumnBreak) %></td>
	                       			<td width="%" align="center" valign="middle" class="solidline04" ><%=format2.format(percenTagBreak)%>%</td>
					         	<%
					         	}
					         }
							//---------Sum Total Column 
					         percenTagTotal = 0d;
					         if(sumTotalAll>0){
						         percenTagTotal = (Double.parseDouble(""+sumTotalEsv)/Double.parseDouble(""+sumTotalAll))*100;	
						     }else{
						         percenTagTotal = 0d;
						    }					         
					         %>
		                	<td align="center" valign="middle" class="solidline04">&nbsp;<%=format1.format(sumTotalEsv)%></td>
		                	<td align="center" valign="middle" class="solidline04">&nbsp;<%=format1.format(sumTotalSvc)%></td>
		                	<td align="center" valign="middle" class="solidline04">&nbsp;<%=format1.format(sumTotalAll)%></td>
		                	<td align="center" valign="middle" class="solidline04">&nbsp;<%=format2.format(percenTagTotal)%>%</td>	 
		                	        			
					<%-- #######################Grand Total summary#######################--%>
					<tr   >
                			<td colspan="3" align="center" class="grandtotal">Grand Total </td>
                			<%
                			 sumColumn = 0;
                			 for(int i=0; i < MAX_LOOP_MONTH; i++) { 
					         	if(i<MAX_LOOP){
					         	   percenTag = 0d;
					         	   sumColumn = 0;
					         	   sumColumn +=sumGrandTotalESV[i]+sumGrandTotalSVC[i];
					         	   
					         	   if(sumColumn>0){
						             	percenTag =(Double.parseDouble(""+sumGrandTotalESV[i])/Double.parseDouble(""+sumColumn))*100;						             		             	
						           }else{
						             	percenTag = 0d;
						           }					         	
					         	%>
						         	<td width="%" align="center" valign="middle" class="grandtotal" >&nbsp;<%=format1.format(sumGrandTotalESV[i])%></td>
	                        		<td width="%" align="center" valign="middle" class="grandtotal" >&nbsp;<%=format1.format(sumGrandTotalSVC[i])%></td>
	                       			<td width="%" align="center" valign="middle" class="grandtotal" >&nbsp;<%=format1.format(sumColumn)%></td>
	                       			<td width="%" align="center" valign="middle" class="grandtotal" >&nbsp;<%=format2.format(percenTag)%>%</td>
					         	<%
					         	}
					         }
					         //---------Sum Total Column 
					         percenTagTotal = 0d;
					         sumTotal = 0;
					         sumTotal = totalColumnArr[2]+totalColumnArr[3];
					         if(sumTotal>0){
						         percenTagTotal = (Double.parseDouble(""+totalColumnArr[2])/Double.parseDouble(""+sumTotal))*100;	
						     }else{
						         percenTagTotal = 0d;
						    }					         
					         
                			 %>
                			<td align="center" valign="middle" class="grandtotal">&nbsp;<%=format1.format(totalColumnArr[2])%></td> 
                			<td align="center" valign="middle" class="grandtotal">&nbsp;<%=format1.format(totalColumnArr[3])%></td>  
                			<td align="center" valign="middle" class="grandtotal">&nbsp;<%=format1.format(sumTotal)%></td>  
                			<td align="center" valign="middle" class="grandtotal">&nbsp;<%=format2.format(percenTagTotal)%>%</td>              			
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

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td align="left" valign="middle">&nbsp;ESV : รายการแจ้งซ่อมจาก e-Service (ไม่รวมยกเลิก)</td>
    <td align="center" valign="middle">&nbsp;</td>
    <td align="center" valign="middle">&nbsp;</td>
  </tr>
  <tr>
    <td align="left" valign="middle">&nbsp;SVC : รายการแจ้งซ่อมผ่าน Call Center (เฉพาะรายการซ่อมบ้าน)</td>
    <td align="center" valign="middle">&nbsp;</td>
    <td align="center" valign="middle">&nbsp;</td>
  </tr>
</table>



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
  System.out.println("!!Errors : SERV_ReportInformRepairView.jsp :"+e.toString());
} %>
