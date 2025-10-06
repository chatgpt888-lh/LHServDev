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
 * date time: 2015.09.10
 * Last modify :
 * version :1.0
 * project Name : Html view from servlet SERV_ReportSvcMonthlyServlet (Display by month)
 * description :  support report type,agent,and project  by select project/All project
***************************************************/
--%>
<%!

   private static String replaceNull(String str){
		 if ((str == null) || str.equals("")) {
			 return  "0";
		 }else{
            return  str;
		 }
	}
	
  private static double CalPercentTage(int param1,int sumTotal){
    double percentTag = 0d;
  	if(sumTotal==0){
  	   return 0;
  	}else{
  	    percentTag = ((double)param1/(double)sumTotal)*100; 
  	    return percentTag;
  	} 
  }
  private static int GetSumGrandTotal(ArrayList reportGridTableList){
     //-------------------
	 int grandTotal = 0;
	 int sumRowX = 0;
	 int i = 0;
	 Iterator itSum = reportGridTableList.iterator();
	 String ColumnMatrix[][] = null;
	 if(itSum.hasNext()){								
		 ColumnMatrix = (String[][])itSum.next();
		
		 for(i=0; i<ColumnMatrix.length; i++) {
		    sumRowX = 0;
			for(int x =4;x<ColumnMatrix[i].length;x++){		    
				sumRowX +=Integer.parseInt(replaceNull(ColumnMatrix[i][x]));
			}
			grandTotal +=sumRowX;
		}	
	 }	
	 //-------------------
  	return grandTotal;
  }
  
  private static String echoLineHtmlTagTD(String param,String align,String tagHref,String tagA){
    String tagTdHTML = "";
    DecimalFormat  format1 = new DecimalFormat("#,###,##0");
    if("0".equals(param.trim())){
    	tagTdHTML = "<TD class=\"item ; dotline\" vAlign=middle align="+align+">"+format1.format(Integer.parseInt(replaceNull(param)))+" </TD>";
    }else{
    	tagTdHTML = "<TD class=\"dotline\" vAlign=middle align="+align+">"+tagHref+format1.format(Integer.parseInt(replaceNull(param)))+tagA+"</TD>";
    }
    return tagTdHTML;
  }
    
  private static String echoLineHtmlTagTxtTD(String param,String align){
    String tagTdHTML = "";
    if("0".equals(param.trim())){
    	tagTdHTML = "<TD class=\"item ; dotline\" vAlign=middle align="+align+">"+param+" %</TD>";
    }else{
    	tagTdHTML = "<TD class=\"dotline\" vAlign=middle align="+align+">"+param+" %</TD>";
    }
    return tagTdHTML;
  }
  
   private static String genAhrefLinkHtmlTag(String path,String typeDDL,String param1,String param2,String Month,String yyyy,String multiFlag,String projectSel){
     String tagTdHTML = "";
     tagTdHTML = "<a href='"+path+"/SERV_ReportSvcMonthlyServlet?cmd=Desc&typeDDL="+typeDDL+"&param1="+param1+"&param2="+param2+"&Month="+Month+"&yyDDL="+yyyy+"&multiFlag="+multiFlag+"&projectSel="+projectSel+"'  target='_blank'>";
     return tagTdHTML;
   }
  
   //For Grand total Column
  private static String genColGrandTotalLinkHtmlTag(String path,String typeDDL,String param1,String param2,String Month,String yyyy,String multiFlag,String projectSel){
     String tagTdHTML = "";
     tagTdHTML = "<a href='"+path+"/SERV_ReportSvcMonthlyServlet?cmd=Desc&typeDDL="+typeDDL+"&param1="+param1+"&param2="+param2+"&Month="+Month+"&yyDDL="+yyyy+"&multiFlag="+multiFlag+"&grandTotal=col&projectSel="+projectSel+"'  target='_blank'>";
     return tagTdHTML;
   }
	
	//For Grand total ROW,*MAN= MONTH ,Not interest Item Main
    private static String genRowGrandTotalLinkHtml(String path,String typeDDL,int param,String Month,String yyyy,String multiFlag,String projectSel,String status){
	     DecimalFormat  format1 = new DecimalFormat("#,###,##0");
	     String tagTdHTML = "";
	     String tagHref = "<a href='"+path+"/SERV_ReportSvcMonthlyServlet?cmd=Desc&typeDDL="+typeDDL+"&param1=&param2=&Month="+Month+"&yyDDL="+yyyy+"&multiFlag="+multiFlag+"&grandTotal="+status+"&projectSel="+projectSel+"'  target='_blank'>";
 	     if(param<=0){
	    	tagTdHTML = format1.format(param);
	     }else{
	    	tagTdHTML = tagHref+format1.format(param)+"</a>";
	     }
         return tagTdHTML;
    }

 %>
<%


String thaiMonth[] = new String[] {"","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม",""};
String shortMonth[] = new String[] {"","ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค.",""};
DecimalFormat  format1 = new DecimalFormat("#,###,##0");
DecimalFormat  format2 = new DecimalFormat("#,###,##0.0");
//******************************************

  Object objReportHD= request.getAttribute("reportResultHD");
  ArrayList  reportGridTableList = null;
  
  Object objReportSub = request.getAttribute("resultSub");
  ArrayList  rowGridTableList = null;
  
  if(objReportHD != null){
  	reportGridTableList =(ArrayList)objReportHD;
  }else{
    reportGridTableList = new ArrayList();
  }
  
  if(objReportSub != null){
  	rowGridTableList =(ArrayList)objReportSub;
  }else{
    rowGridTableList = new ArrayList();
  }
  
  //--project selected
  ArrayList projSelectdList = (ArrayList)request.getAttribute("projSelectdList");
  String yyDDL = (String)request.getAttribute("yyDDL");
  String typeDDL = (String)request.getAttribute("typeDDL");
  String multiFlag = (String)request.getAttribute("multiFlag");//0=ALL

  try{
  
%>

<HTML>
<HEAD>
<TITLE>รายงานฐานการรับสายตามเดือน</TITLE>
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

<BODY leftMargin=0 topMargin=0 marginwidth="0" marginheight="0">
<FORM method=post action="">
<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
<TBODY>
<TR>
<TD class=BD width="100%">
<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
<TBODY>
<TR>
<TD class=bigh width="50%"><IMG border=0 src="images/i_home.gif" width=20 align=absMiddle height=20>&nbsp;รายงานฐานการรับสายตามเดือน
<% if("type".equalsIgnoreCase(typeDDL)){
			out.println("ประเภทการแจ้งซ่อม");
		}else if("agent".equalsIgnoreCase(typeDDL)){
			out.println("ตาม Agent");
		}else if("project".equalsIgnoreCase(typeDDL)){
			out.println("ตามโครงการ");	
		}
	 %>
</TD>
<TD width="50%" align=right></TD></TR></TBODY></TABLE><BR style="FONT-SIZE: 10pt">
<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
<TBODY>
<TR>
	<TD class=item_tab1><IMG border=0 src="images/i_i.gif" width=20 align=absMiddle height=20></TD>
	<TD class=item_tab2 width=400>รายละเอียดรายงานฐานการรับสายตามเดือน
	<% if("type".equalsIgnoreCase(typeDDL)){
			out.println("ประเภทการแจ้งซ่อม");
		}else if("agent".equalsIgnoreCase(typeDDL)){
			out.println("ตาม Agent");
		}else if("project".equalsIgnoreCase(typeDDL)){
			out.println("ตามโครงการ");	
		}
	 %>
	</TD>
	<TD class=item_tab3></TD>
<TD>&nbsp;</TD></TR></TBODY></TABLE>
<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
<TBODY>
<TR>
<TD vAlign=top width=5><IMG border=0 src="images/Corn01.gif" width=5 height=5></TD>
<TD class=frmTop>&nbsp;</TD>
<TD vAlign=top width=5 align=right><IMG border=0 src="images/Corn02.gif" width=5 height=5></TD></TR></TBODY></TABLE>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR" align="center">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td class="item ; dotline01" height="22" colspan="4">
    &nbsp;ปี พ.ศ : <%=(Integer.parseInt(replaceNull(yyDDL))+543) %></td>
  </tr>
   <%
     String projectSelection = "";
     if(multiFlag.equals("0")){
   			%>
   			<tr><td class="item ; dotline01" height="22" width="10%">โครงการ : เลือกทุกโครงการ</td></tr>
   			<%
        }else{
		 if(projSelectdList!=null && projSelectdList.size()>0){		
			ArrayList strList = null;	
			String tempNameProject = "";
			//String tempProjectId = "";	
			int line = 0;
			 //-----------------------			 
			Iterator it = projSelectdList.iterator();								   							   
			while(it.hasNext()){									
				strList =(ArrayList)it.next();
				tempNameProject = "";		
				//tempProjectId = "";									
				//tempProjectId = doString.checkString(strList.get(0).toString());//LH:075
				tempNameProject =doString.checkString(strList.get(2).toString());
				projectSelection +=strList.get(0).toString()+":"+doString.checkString(strList.get(1).toString())+"|";
				if (line==0) {%>
					<tr><td class="item ; dotline01" height="22" width="10%">โครงการ :</td>
				<%} else if (line%3==0 && line!=0) {  
				%><tr><td class="item ; dotline01" height="22" width="10%">&nbsp;</td><%
			     }	
			     %><td height="22" width="30%" class="dotline01"> 
			     <%=doString.checkString(strList.get(0).toString())+"-"+doString.checkString(strList.get(1).toString())+" "+tempNameProject%></td><%
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

<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
<TBODY>
<TR>
<TD vAlign=bottom width=5><IMG border=0 src="images/Corn03.gif" width=5 height=5></TD>
<TD class=frmBottom>&nbsp;</TD>
<TD vAlign=bottom width=5 align=right><IMG border=0 src="images/Corn04.gif" width=5 height=5></TD></TR></TBODY></TABLE><BR style="FONT-SIZE: 10pt">
<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
<TBODY>
<TR>
<TD class=item_tab1><IMG border=0 src="images/i_i.gif" width=20 align=absMiddle height=20></TD>
<TD class=item_tab2 width=200>รายละเอียดรายงานฐานการรับสายตามเดือน</TD>
<TD class=item_tab3></TD>
<TD>&nbsp;</TD></TR></TBODY></TABLE>
<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
<TBODY>
<TR>
<TD bgColor=#d7e6ff vAlign=top width=5><IMG border=0 src="images/Corn01.gif" width=5 height=5></TD>
<TD class=frmTop bgColor=#d7e6ff>&nbsp;</TD>
<TD bgColor=#d7e6ff vAlign=top width=5 align=right><IMG border=0 src="images/Corn02.gif" width=5 height=5></TD></TR></TBODY></TABLE>
<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
<TBODY>
<TR>
<TD class=frmL width="100%">
<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
<!--========================== Header Table ===========================---->

<TBODY>
<TR>
	<TD class=col_name height=1  >ลำดับ</TD>
	<% if("type".equalsIgnoreCase(typeDDL)){
			out.println("<TD class=col_name height=1 >รหัส</TD>");
			out.println("<TD class=col_name height=1 >ประเภทการแจ้ง</TD>");
		}else if("agent".equalsIgnoreCase(typeDDL)){
			out.println("<TD class=col_name height=1 >รหัส</TD>");
			out.println("<TD class=col_name height=1 >ชื่อ AGENT</TD>");
		}else if("project".equalsIgnoreCase(typeDDL)){
			out.println("<TD class=col_name height=1 >รหัสโครงการ</TD>");
			out.println("<TD class=col_name height=1 >โครงการ</TD>");	
		}
	 %>

	<TD class=col_name   align=center>มกราคม</TD>
	<TD class=col_name   align=center>กุมภาพันธ์</TD>
	<TD class=col_name   align=center>มีนาคม</TD>
	<TD class=col_name   align=center>เมษายน</TD>
	<TD class=col_name   align=center>พฤษภาคม</TD>
	<TD class=col_name   align=center>มิถุนายน</TD>
	<TD class=col_name   align=center>กรกฎาคม</TD>
	<TD class=col_name   align=center>สิงหาคม</TD>
	<TD class=col_name   align=center>กันยายน</TD>
	<TD class=col_name   align=center>ตุลาคม</TD>
	<TD class=col_name   align=center>พฤศจิกายน</TD>
	<TD class=col_name   align=center>ธันวาคม</TD>	
	<TD class=col_name   align=center>Grand Total</TD>
	<TD class=col_name   align=center>Percentage</TD>

</TR>

<!--==================================================================---->
<!--  #f7f7f7   #ffffff -->
<%
 int sumColumn[] = new int[16];
 int c = 0;
 int SUM_GRAND_TOTAL = 0;
 if(reportGridTableList!=null && reportGridTableList.size()>0){	
	Iterator it = reportGridTableList.iterator();
	String ColumnMatrix[][] = null;
	
	String tagColorBG1=" bgcolor='#ffffff' ";
	String tagColorBG2=" bgcolor='#f7f7f7' ";
	String tagColorBG = "";	
	int Loop = 4;
	//int LoopX = 4;
	//int j    = 4;
	int ROW = 0;
	//--------------------------
	int sumRow = 0;
	
	int i = 0;
	int j = 0;
	 SUM_GRAND_TOTAL = GetSumGrandTotal(reportGridTableList);
	//System.out.println("Sub Grand Total :"+SUM_GRAND_TOTAL);
	double percentTag = 0d;
	//--------------------------
	//while(it.hasNext()){
	 String linkTag = "";
	if(it.hasNext()){								
		 ColumnMatrix = (String[][])it.next();
		
		 for(i=0; i<ColumnMatrix.length; i++) {
			ROW++;
			tagColorBG = tagColorBG1;
			if(ROW%2==0){
				tagColorBG = tagColorBG2;
			}
			//------------------------------------
			c = 0;
			j   = 4;
			Loop = 4;
			//LoopX = 4;
			sumRow = 0;
			/********Calculate********/
			for(int x =4;x<ColumnMatrix[i].length;x++){		    
				sumRow +=Integer.parseInt(replaceNull(ColumnMatrix[i][x]));
			}
			//-------Sum Column
			sumColumn[c++] +=Integer.parseInt(replaceNull(ColumnMatrix[i][j++]));//4
			sumColumn[c++] +=Integer.parseInt(replaceNull(ColumnMatrix[i][j++]));
			sumColumn[c++] +=Integer.parseInt(replaceNull(ColumnMatrix[i][j++]));
			sumColumn[c++] +=Integer.parseInt(replaceNull(ColumnMatrix[i][j++]));
			sumColumn[c++] +=Integer.parseInt(replaceNull(ColumnMatrix[i][j++]));
			sumColumn[c++] +=Integer.parseInt(replaceNull(ColumnMatrix[i][j++]));
			sumColumn[c++] +=Integer.parseInt(replaceNull(ColumnMatrix[i][j++]));
			sumColumn[c++] +=Integer.parseInt(replaceNull(ColumnMatrix[i][j++]));
			sumColumn[c++] +=Integer.parseInt(replaceNull(ColumnMatrix[i][j++]));
			sumColumn[c++] +=Integer.parseInt(replaceNull(ColumnMatrix[i][j++]));
			sumColumn[c++] +=Integer.parseInt(replaceNull(ColumnMatrix[i][j++]));
			sumColumn[c++] +=Integer.parseInt(replaceNull(ColumnMatrix[i][j++]));
			sumColumn[c++] +=sumRow;//sumRow 
			//------------------------------------	 
			 %>
			  <tr <%=tagColorBG %> height="18px"> 
					<td   height="1" align="center" class="dotline" nowrap="nowrap"><div align="center"><%=ROW %></div></td>
			       <%if("type".equalsIgnoreCase(typeDDL)){%>
			             <td  valign="middle" class="dotline" nowrap="nowrap">&nbsp;<%=ColumnMatrix[i][0]%></td>
			        	<%if(!ColumnMatrix[i][1].equals("0")){ %>
		        			<td  valign="middle" class="dotline" nowrap="nowrap">
<a href="<%=request.getContextPath()+"/SERV_ReportSvcMonthlyServlet?cmd=Expand&itmno="+ColumnMatrix[i][0]+"&yyDDL="+yyDDL+"&typeDDL="+typeDDL+"&multiFlag="+multiFlag+"&projectSel="+projectSelection%>" target="_blank"><%=ColumnMatrix[i][2]%></a></td>	
		        	   <%}else{ %>
		        			<td  valign="middle" class="dotline" nowrap="nowrap">&nbsp;<%=ColumnMatrix[i][2]%></td>	
		        	   <%} %>
			
					<%}else if("agent".equalsIgnoreCase(typeDDL)){%>
						<td  valign="middle" class="dotline" nowrap="nowrap">&nbsp;<%=ColumnMatrix[i][0]%></td>
			       		<td  valign="middle" class="dotline" nowrap="nowrap">&nbsp;<%=ColumnMatrix[i][1] %><%=ColumnMatrix[i][2]%>&nbsp;&nbsp;&nbsp;  <%=ColumnMatrix[i][3]%></td>
					<%}else if("project".equalsIgnoreCase(typeDDL)){%>
						<td  valign="middle" class="dotline" nowrap="nowrap">&nbsp;<%=ColumnMatrix[i][0] %>-<%=ColumnMatrix[i][1]%></td>
			        	<td  valign="middle" class="dotline" nowrap="nowrap">&nbsp;<%=ColumnMatrix[i][2]%></td>
					<%}%>
					<%
					    linkTag = "";
			    		linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix[i][0],ColumnMatrix[i][1],"1",yyDDL,multiFlag,projectSelection);
						out.println(echoLineHtmlTagTD(""+ColumnMatrix[i][Loop++],"center",linkTag,"</a>"));
						
						linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix[i][0],ColumnMatrix[i][1],"2",yyDDL,multiFlag,projectSelection);
						out.println(echoLineHtmlTagTD(""+ColumnMatrix[i][Loop++],"center",linkTag,"</a>"));
						
						linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix[i][0],ColumnMatrix[i][1],"3",yyDDL,multiFlag,projectSelection);
						out.println(echoLineHtmlTagTD(""+ColumnMatrix[i][Loop++],"center",linkTag,"</a>"));
						
						linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix[i][0],ColumnMatrix[i][1],"4",yyDDL,multiFlag,projectSelection);
						out.println(echoLineHtmlTagTD(""+ColumnMatrix[i][Loop++],"center",linkTag,"</a>"));
						
						linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix[i][0],ColumnMatrix[i][1],"5",yyDDL,multiFlag,projectSelection);
						out.println(echoLineHtmlTagTD(""+ColumnMatrix[i][Loop++],"center",linkTag,"</a>"));
						
						linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix[i][0],ColumnMatrix[i][1],"6",yyDDL,multiFlag,projectSelection);
						out.println(echoLineHtmlTagTD(""+ColumnMatrix[i][Loop++],"center",linkTag,"</a>"));
						
						linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix[i][0],ColumnMatrix[i][1],"7",yyDDL,multiFlag,projectSelection);
						out.println(echoLineHtmlTagTD(""+ColumnMatrix[i][Loop++],"center",linkTag,"</a>"));
						
						linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix[i][0],ColumnMatrix[i][1],"8",yyDDL,multiFlag,projectSelection);
						out.println(echoLineHtmlTagTD(""+ColumnMatrix[i][Loop++],"center",linkTag,"</a>"));
						
						linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix[i][0],ColumnMatrix[i][1],"9",yyDDL,multiFlag,projectSelection);
						out.println(echoLineHtmlTagTD(""+ColumnMatrix[i][Loop++],"center",linkTag,"</a>"));
						
						linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix[i][0],ColumnMatrix[i][1],"10",yyDDL,multiFlag,projectSelection);
						out.println(echoLineHtmlTagTD(""+ColumnMatrix[i][Loop++],"center",linkTag,"</a>"));
						
						linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix[i][0],ColumnMatrix[i][1],"11",yyDDL,multiFlag,projectSelection);
						out.println(echoLineHtmlTagTD(""+ColumnMatrix[i][Loop++],"center",linkTag,"</a>"));
						
						linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix[i][0],ColumnMatrix[i][1],"12",yyDDL,multiFlag,projectSelection);
						out.println(echoLineHtmlTagTD(""+ColumnMatrix[i][Loop++],"center",linkTag,"</a>"));
						
						linkTag = genColGrandTotalLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix[i][0],ColumnMatrix[i][1],"99",yyDDL,multiFlag,projectSelection);
						out.println(echoLineHtmlTagTD(""+sumRow,"center",linkTag,"</a>"));
						//out.println(echoLineHtmlTagTD(""+sumRow,"center"));
						if(SUM_GRAND_TOTAL==0){
					       // 100/0 =  by zero
						   out.println(echoLineHtmlTagTD("0","center","",""));
						}else{
						   percentTag = 0;
						   percentTag = ((double)sumRow/(double)SUM_GRAND_TOTAL)*100; 
						   out.println(echoLineHtmlTagTxtTD(doString.displayNumber("#,##0.0",percentTag),"right"));
						}
					 %>
				</TR>
		<%			 	
	   }//#End for i
  }	//#END For Loop
}//#END Check Null of ArrayList <rowGridTableList>
 %>
<!-- #######################Grand Total summary#######################-->
<tr  >
<% c = 0; %>
                			<td colspan="3" align="center" class="grandtotal">Grand Total </td>
						    <td  align="center" valign="middle" class="grandtotal">&nbsp;<%=genRowGrandTotalLinkHtml(request.getContextPath(),typeDDL,sumColumn[c++],"1",yyDDL,multiFlag,projectSelection,"row")%></td>
	                        <td  align="center" valign="middle" class="grandtotal">&nbsp;<%=genRowGrandTotalLinkHtml(request.getContextPath(),typeDDL,sumColumn[c++],"2",yyDDL,multiFlag,projectSelection,"row")%></td>
	                       	<td  align="center" valign="middle" class="grandtotal">&nbsp;<%=genRowGrandTotalLinkHtml(request.getContextPath(),typeDDL,sumColumn[c++],"3",yyDDL,multiFlag,projectSelection,"row")%></td>
	                       	<td  align="center" valign="middle" class="grandtotal">&nbsp;<%=genRowGrandTotalLinkHtml(request.getContextPath(),typeDDL,sumColumn[c++],"4",yyDDL,multiFlag,projectSelection,"row")%></td>
                			<td  align="center" valign="middle" class="grandtotal">&nbsp;<%=genRowGrandTotalLinkHtml(request.getContextPath(),typeDDL,sumColumn[c++],"5",yyDDL,multiFlag,projectSelection,"row")%></td> 
                			<td  align="center" valign="middle" class="grandtotal">&nbsp;<%=genRowGrandTotalLinkHtml(request.getContextPath(),typeDDL,sumColumn[c++],"6",yyDDL,multiFlag,projectSelection,"row")%></td>  
                			<td  align="center" valign="middle" class="grandtotal">&nbsp;<%=genRowGrandTotalLinkHtml(request.getContextPath(),typeDDL,sumColumn[c++],"7",yyDDL,multiFlag,projectSelection,"row")%></td>  
							<td  align="center" valign="middle" class="grandtotal">&nbsp;<%=genRowGrandTotalLinkHtml(request.getContextPath(),typeDDL,sumColumn[c++],"8",yyDDL,multiFlag,projectSelection,"row")%></td>
	                        <td  align="center" valign="middle" class="grandtotal">&nbsp;<%=genRowGrandTotalLinkHtml(request.getContextPath(),typeDDL,sumColumn[c++],"9",yyDDL,multiFlag,projectSelection,"row")%></td>
	                       	<td  align="center" valign="middle" class="grandtotal">&nbsp;<%=genRowGrandTotalLinkHtml(request.getContextPath(),typeDDL,sumColumn[c++],"10",yyDDL,multiFlag,projectSelection,"row")%></td>
	                       	<td  align="center" valign="middle" class="grandtotal">&nbsp;<%=genRowGrandTotalLinkHtml(request.getContextPath(),typeDDL,sumColumn[c++],"11",yyDDL,multiFlag,projectSelection,"row")%></td>
                			<td  align="center" valign="middle" class="grandtotal">&nbsp;<%=genRowGrandTotalLinkHtml(request.getContextPath(),typeDDL,sumColumn[c++],"12",yyDDL,multiFlag,projectSelection,"row")%></td> 
                			<td  align="center" valign="middle" class="grandtotal">&nbsp;<%=genRowGrandTotalLinkHtml(request.getContextPath(),typeDDL,sumColumn[c++],"99",yyDDL,multiFlag,projectSelection,"99")%></td>  
                			<TD class="item ; grandtotal" vAlign=middle align=right><%=format1.format(100)%> %</TD>             			
</tr>
<tr  >
<% c = 0; %>
                			<td colspan="3" align="center" class="grandtotal">% Percentage </td>
						    <td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],SUM_GRAND_TOTAL))%> %</td>
	                        <td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],SUM_GRAND_TOTAL))%> %</td>
	                       	<td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],SUM_GRAND_TOTAL))%> %</td>
	                       	<td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],SUM_GRAND_TOTAL))%> %</td>
                			<td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],SUM_GRAND_TOTAL))%> %</td> 
                			<td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],SUM_GRAND_TOTAL))%> %</td>  
                			<td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],SUM_GRAND_TOTAL))%> %</td>  
							<td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],SUM_GRAND_TOTAL))%> %</td>
	                        <td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],SUM_GRAND_TOTAL))%> %</td>
	                       	<td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],SUM_GRAND_TOTAL))%> %</td>
	                       	<td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],SUM_GRAND_TOTAL))%> %</td>
                			<td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],SUM_GRAND_TOTAL))%> %</td> 
                			<TD align="center" valign="middle" class="grandtotal"><%=format1.format(100)%> %</TD> 
                			<TD class="item ; grandtotal" vAlign=middle align=center>&nbsp;</TD>             			
</tr>


</TBODY></TABLE></TD></TR></TBODY></TABLE>

<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
<TBODY>
<TR>
<TD vAlign=bottom width=5><IMG border=0 src="images/Corn03.gif" width=5 height=5></TD>
<TD class=frmBottom>&nbsp;</TD>
<TD vAlign=bottom width=5 align=right><IMG border=0 src="images/Corn04.gif" width=5 height=5></TD></TR></TBODY></TABLE><BR style="FONT-SIZE: 3pt">
<TABLE height=30 cellSpacing=0 cellPadding=0 width="100%" border=0>
<TBODY>
<TR>
<TD class=act_tab1></TD>
<TD class=act_tab2 width=80>&nbsp; </TD>
<TD class=act_tab3></TD>
<TD class=act_tab4><A href="javascript:history.back();" target=_self><IMG border=0 src="images/bu_back.gif" width=50 align=absMiddle height=15></A>&nbsp; <A href="/LHServ/SERV_Index.jsp" target=_top><IMG border=0 src="images/bu_home.gif" width=50 align=absMiddle height=15></A></TD></TR></TBODY></TABLE><BR style="FONT-SIZE: 30pt">
<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
<TBODY>
<TR>
<TD class=copyright width="100%" align=center>Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5 <BR>ติดต่อสอบถามได้ที่ : <A href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</A>&nbsp; หรือ โทร. 0-2230-8279 (คุณประพัฒน์ ฝ่ายบริการ)&nbsp; 0-2230-8491-5 (ฝ่าย IT) <BR><IMG src="images/copyright.gif" width=475 height=26>
</TD></TR></TBODY></TABLE>
</TR></TBODY>
</TABLE>


</FORM>
</BODY>

</HTML>
<%}catch(Exception e){
  System.out.println("!!Errors : SERV_ReportSvcMonthlyView.jsp :"+e.toString());
} %>
