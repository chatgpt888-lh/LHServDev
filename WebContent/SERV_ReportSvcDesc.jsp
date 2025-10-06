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
 * date time: 2015.09.24
 * Last modify :
 * version :1.0
 * project Name : Html view from servlet SERV_ReportSvcServlet
 * description :  support report type,agent,and project  by select project/All project
***************************************************/
--%>
<%!

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
	 Iterator itSum = reportGridTableList.iterator();
	 String ColumnMatrixSum[] = null;
	 while(itSum.hasNext()){								
		ColumnMatrixSum = (String[])itSum.next();
		
		sumRowX = 0;
	    for(int x =4;x<ColumnMatrixSum.length;x++){		    
			sumRowX += Integer.parseInt(ColumnMatrixSum[x]);
		}
		grandTotal +=sumRowX;
	 }	
	 //-------------------
  	return grandTotal;
  }
  
  //For Normal Line
   private static String genAhrefLinkHtmlTag(String path,String typeDDL,String ColumnMatrix[],String transMonth,String fDate,String tDate,String multiFlag,String projectSel){
	     String tagTdHTML = "";
	     String flag = "";
	     if("type".equals(typeDDL)){
	     	flag = "Y";
	     }else{
	     	flag = "N";
	     }
	     tagTdHTML = "<a href='"+path+"/SERV_ReportSvcServlet?cmd=Desc&typeDDL="+typeDDL+"&param1="+ColumnMatrix[0]+"&param2="+ColumnMatrix[1]+"&transMonth="+transMonth+"&fromDate="+fDate+"&toDate="+tDate+"&multiFlag="+multiFlag+"&itemSub="+flag+"&projectSel="+projectSel+"'  target='_blank'>";
	     return tagTdHTML;
   }
   
   //For Grand total Column
  private static String genColGrandTotalLinkHtmlTag(String path,String typeDDL,String ColumnMatrix[],String fDate,String tDate,String multiFlag,String projectSel){
      String tagTdHTML = "";
      String flag = "";
	  if("type".equals(typeDDL)){
	     flag = "Y";
	  }else{
	     flag = "N";
	  }
     tagTdHTML = "<a href='"+path+"/SERV_ReportSvcServlet?cmd=Desc&typeDDL="+typeDDL+"&param1="+ColumnMatrix[0]+"&param2="+ColumnMatrix[1]+"&transMonth=&fromDate="+fDate+"&toDate="+tDate+"&multiFlag="+multiFlag+"&itemSub="+flag+"&grandTotal=col&projectSel="+projectSel+"'  target='_blank'>";
     return tagTdHTML;
   }
	
	//For Grand total ROW
    private static String genRowGrandTotalLinkHtml(String path,int param,String typeDDL,String itemNo,String transMonth,String fDate,String tDate,String multiFlag,String projectSel,String status){
	     DecimalFormat  format1 = new DecimalFormat("#,###,##0");
	     String tagTdHTML = "";
		 String flag = "";
		 if("type".equals(typeDDL)){
		    flag = "Y";
		  }else{
		    flag = "N";
		  } 
		     
	     String tagHref = "<a href='"+path+"/SERV_ReportSvcServlet?cmd=Desc&typeDDL="+typeDDL+"&param1="+itemNo+"&param2=&transMonth="+transMonth+"&fromDate="+fDate+"&toDate="+tDate+"&multiFlag="+multiFlag+"&itemSub="+flag+"&grandTotal="+status+"&projectSel="+projectSel+"'  target='_blank'>";
	     if(param<=0){
	    	tagTdHTML = format1.format(param);
	     }else{
	    	tagTdHTML = tagHref+format1.format(param)+"</a>";
	     }
         return tagTdHTML;
    }   
   
   
   
  private static String echoLineHtmlTagTD(String tagLinkA,String param,String tagXA){
    String tagTdHTML = "";
    if("0".equals(param.trim())){
    	tagTdHTML = "<TD class=\"item ; dotline\" vAlign=middle align=center>"+param+"</TD>";
    }else{
    	tagTdHTML = "<TD class=\"dotline\" vAlign=middle align=center>"+tagLinkA+param+tagXA+"</TD>";
    }
    return tagTdHTML;
  }
  
   private static String echoLineHtmlPercentTagTD(String param){
    String tagTdHTML = "";
    if("0".equals(param.trim())){
    	tagTdHTML = "<TD class=\"item ; dotline\" vAlign=middle align=right>"+param+" %</TD>";
    }else{
    	tagTdHTML = "<TD class=\"dotline\" vAlign=middle align=right>"+param+" %</TD>";
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
  String fromDate = (String)request.getAttribute("fromDate");
  String toDate = (String)request.getAttribute("toDate");
  String typeDDL = (String)request.getAttribute("typeDDL");
  String multiFlag = (String)request.getAttribute("multiFlag");//0=ALL
  String typeName = (String)request.getAttribute("typeName");//0=ALL
  String itemNo = (String)request.getAttribute("itemNo");//01 แจ้งซ่อมทั่วไป
  String projectSel=(String)request.getAttribute("projectSel");//LH:075|AR:001..
  //String itemSub = (String)request.getAttribute("itemSub");//Y,N
  try{
  
  String []arrFromThaiDate = fromDate.split("\\/");
  String []arrToThaiDate = toDate.split("\\/");//22/09/2558
%>

<HTML>
<HEAD>
<TITLE>รายงานฐานการรับสายตามช่วงโอน (<%=typeName%>)</TITLE>
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
<TD class=bigh width="50%"><IMG border=0 src="images/i_home.gif" width=20 align=absMiddle height=20>&nbsp;รายละเอียด Report สรุปลูกค้า <%=typeName%>
</TD>
<TD width="50%" align=right></TD></TR></TBODY></TABLE><BR style="FONT-SIZE: 10pt">
<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
<TBODY>
<TR>
	<TD class=item_tab1><IMG border=0 src="images/i_i.gif" width=20 align=absMiddle height=20></TD>
	<TD class=item_tab2 width=400>รายงานฐานการรับสายตามช่วงโอน  ประเภท
	&nbsp;<%=typeName%>
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
    &nbsp;ระหว่างวันที่ : <%=arrFromThaiDate[0] %> <%=thaiMonth[Integer.parseInt(arrFromThaiDate[1])]%> &nbsp; พ.ศ. <%=arrFromThaiDate[2]%> &nbsp; &nbsp; ถึง
    <%=arrToThaiDate[0] %> <%=thaiMonth[Integer.parseInt(arrToThaiDate[1])]%> &nbsp; พ.ศ. <%=arrToThaiDate[2]%> </td>
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
<TD class=item_tab2 width=400>รายละเอียด รายงานฐานการรับสายตามช่วงโอน ประเภท <%=typeName%></TD>
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

	<TD class=col_name   align=center>โอน  1 -  3 เดือน</TD>
	<TD class=col_name   align=center>โอน  3 -  6 เดือน</TD>
	<TD class=col_name   align=center>โอน  6 -  9 เดือน</TD>
	<TD class=col_name   align=center>โอน  9 - 12 เดือน</TD>
	<TD class=col_name   align=center>โอน 12 - 15 เดือน</TD>
	<TD class=col_name   align=center>โอน 15 - 24 เดือน</TD>
	<TD class=col_name   align=center>โอน 24 - 36 เดือน</TD>
	<TD class=col_name   align=center>โอน 36 - 48 เดือน</TD>
	<TD class=col_name   align=center>โอน 48 - 60 เดือน</TD>
	<TD class=col_name   align=center>โอน 60 - 72 เดือน</TD>
	<TD class=col_name   align=center>โอน 72 - 84 เดือน</TD>
	<TD class=col_name   align=center>โอน 84 - 96 เดือน</TD>
	<TD class=col_name   align=center>โอน 96 -108 เดือน</TD>
	<TD class=col_name   align=center>โอน 108 -120 เดือน</TD>
	<TD class=col_name   align=center>โอน &gt; 120 เดือน</TD>
	<TD class=col_name   align=center>Grand Total</TD>
	<TD class=col_name   align=center width="5%">&nbsp;% &nbsp;&nbsp;</TD>
</TR>

<!--==================================================================---->
<!--  #f7f7f7   #ffffff -->
<%
 int sumColumn[] = new int[16];
 int c = 0;
 
int LessThan15Month = 0;
int MoreThan15Month = 0;
int job01 = 0;
 
 if(reportGridTableList!=null && reportGridTableList.size()>0){	
 
	Iterator it = reportGridTableList.iterator();
	String ColumnMatrix[] = null;
	
	String tagColorBG1=" bgcolor='#ffffff' ";
	String tagColorBG2=" bgcolor='#f7f7f7' ";
	String tagColorBG = "";	
	int Loop = 4;
	int j    = 4;
	int ROW = 0;

	//--------------------------
	int sumRow = 0;
	int SUM_GRAND_TOTAL = GetSumGrandTotal(reportGridTableList);
	//System.out.println("Sub Grand Total :"+SUM_GRAND_TOTAL);
	double percentTag = 0d;
	//--------------------------
    String linkTag = "";
	while(it.hasNext()){								
		ColumnMatrix = (String[])it.next();
		ROW++;

		tagColorBG = tagColorBG1;
		if(ROW%2==0){
			tagColorBG = tagColorBG2;
		}
		//------------------------------------
		c = 0;
		j   = 4;
		Loop = 4;
		sumRow = 0;
		/********Calculate********/
		for(int x =4;x<ColumnMatrix.length;x++){		    
			sumRow += Integer.parseInt(ColumnMatrix[x]);
		}
		//-------Sum Column
		//sumColumn[0] += ColumnMatrix[4];
		sumColumn[c++] +=Integer.parseInt(ColumnMatrix[j++]);//4
		sumColumn[c++] +=Integer.parseInt(ColumnMatrix[j++]);//5
		sumColumn[c++] +=Integer.parseInt(ColumnMatrix[j++]);
		sumColumn[c++] +=Integer.parseInt(ColumnMatrix[j++]);
		sumColumn[c++] +=Integer.parseInt(ColumnMatrix[j++]);
		sumColumn[c++] +=Integer.parseInt(ColumnMatrix[j++]);
		sumColumn[c++] +=Integer.parseInt(ColumnMatrix[j++]);
		sumColumn[c++] +=Integer.parseInt(ColumnMatrix[j++]);
		sumColumn[c++] +=Integer.parseInt(ColumnMatrix[j++]);
		sumColumn[c++] +=Integer.parseInt(ColumnMatrix[j++]);
		sumColumn[c++] +=Integer.parseInt(ColumnMatrix[j++]);
		sumColumn[c++] +=Integer.parseInt(ColumnMatrix[j++]);
		sumColumn[c++] +=Integer.parseInt(ColumnMatrix[j++]);
		sumColumn[c++] +=Integer.parseInt(ColumnMatrix[j++]);
		sumColumn[c++] +=Integer.parseInt(ColumnMatrix[j++]);
		sumColumn[c++] +=sumRow;//sumRow
	
	    if(ROW==1){//Fix ROW
	    	//LessThan15Month =  sumRow;
	    	//MoreThan15Month = sumRow;
	    	for(int x =4;x<=8;x++){		    
				LessThan15Month += Integer.parseInt(ColumnMatrix[x]);
			}
			for(int x =9;x<ColumnMatrix.length;x++){		    
			   MoreThan15Month += Integer.parseInt(ColumnMatrix[x]);
		   }
		   job01 = LessThan15Month+MoreThan15Month;
		   //System.out.println("========LessThan15Month : "+LessThan15Month);
		   //System.out.println("========MoreThan15Month : "+MoreThan15Month);
	    }
		//------------------------------------
		%>
	  <tr <%=tagColorBG %>  height="18px"> 
			<td   height="1" align="center" class="dotline" nowrap="nowrap"><div align="center"><%=ROW %></div></td>
	       <%if("type".equalsIgnoreCase(typeDDL)){%>
				<td  valign="middle" class="dotline" nowrap="nowrap">&nbsp;<%=ColumnMatrix[1]%></td>
	        	<td  valign="middle" class="dotline" nowrap="nowrap">&nbsp;<%=ColumnMatrix[2]%></td>			
			<%}else if("agent".equalsIgnoreCase(typeDDL)){%>
				<td  valign="middle" class="dotline" nowrap="nowrap">&nbsp;<%=ColumnMatrix[0]%></td>
	       		<td  valign="middle" class="dotline" nowrap="nowrap">&nbsp;<%=ColumnMatrix[1] %><%=ColumnMatrix[2]%>&nbsp;&nbsp;&nbsp;  <%=ColumnMatrix[3]%></td>
			<%}else if("project".equalsIgnoreCase(typeDDL)){%>
				<td  valign="middle" class="dotline" nowrap="nowrap">&nbsp;<%=ColumnMatrix[0] %>-<%=ColumnMatrix[1]%></td>
	        	<td  valign="middle" class="dotline" nowrap="nowrap">&nbsp;<%=ColumnMatrix[2]%></td>
			<%}%>
			<%
				linkTag = "";
			    linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix,"1",fromDate,toDate,multiFlag,projectSel);
				out.println(echoLineHtmlTagTD(linkTag,ColumnMatrix[Loop++],"</a>"));
				
				linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix,"2",fromDate,toDate,multiFlag,projectSel);
				out.println(echoLineHtmlTagTD(linkTag,ColumnMatrix[Loop++],"</a>"));
				
				linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix,"3",fromDate,toDate,multiFlag,projectSel);
				out.println(echoLineHtmlTagTD(linkTag,ColumnMatrix[Loop++],"</a>"));
				
				linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix,"4",fromDate,toDate,multiFlag,projectSel);
				out.println(echoLineHtmlTagTD(linkTag,ColumnMatrix[Loop++],"</a>"));
				
				linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix,"5",fromDate,toDate,multiFlag,projectSel);
				out.println(echoLineHtmlTagTD(linkTag,ColumnMatrix[Loop++],"</a>"));
				
				linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix,"6",fromDate,toDate,multiFlag,projectSel);
				out.println(echoLineHtmlTagTD(linkTag,ColumnMatrix[Loop++],"</a>"));
				
				linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix,"7",fromDate,toDate,multiFlag,projectSel);
				out.println(echoLineHtmlTagTD(linkTag,ColumnMatrix[Loop++],"</a>"));
				
				linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix,"8",fromDate,toDate,multiFlag,projectSel);
				out.println(echoLineHtmlTagTD(linkTag,ColumnMatrix[Loop++],"</a>"));
				
				linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix,"9",fromDate,toDate,multiFlag,projectSel);
				out.println(echoLineHtmlTagTD(linkTag,ColumnMatrix[Loop++],"</a>"));
				
				linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix,"10",fromDate,toDate,multiFlag,projectSel);
				out.println(echoLineHtmlTagTD(linkTag,ColumnMatrix[Loop++],"</a>"));
				
				linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix,"11",fromDate,toDate,multiFlag,projectSel);
				out.println(echoLineHtmlTagTD(linkTag,ColumnMatrix[Loop++],"</a>"));
				
				linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix,"12",fromDate,toDate,multiFlag,projectSel);
				out.println(echoLineHtmlTagTD(linkTag,ColumnMatrix[Loop++],"</a>"));
				
				linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix,"13",fromDate,toDate,multiFlag,projectSel);
				out.println(echoLineHtmlTagTD(linkTag,ColumnMatrix[Loop++],"</a>"));
				
				linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix,"14",fromDate,toDate,multiFlag,projectSel);
				out.println(echoLineHtmlTagTD(linkTag,ColumnMatrix[Loop++],"</a>"));
				
				linkTag = genAhrefLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix,"15",fromDate,toDate,multiFlag,projectSel);
				out.println(echoLineHtmlTagTD(linkTag,ColumnMatrix[Loop++],"</a>"));
				
				//out.println(echoLineHtmlTagTD("",format1.format(sumRow),""));
				linkTag = genColGrandTotalLinkHtmlTag(request.getContextPath(),typeDDL,ColumnMatrix,fromDate,toDate,multiFlag,projectSel);
				out.println(echoLineHtmlTagTD(linkTag,sumRow+"","</a>"));
				if(SUM_GRAND_TOTAL==0){
				    // 100/0 =  by zero
				  out.println(echoLineHtmlPercentTagTD(format1.format(0)));
				}else{
				   percentTag = 0;
				   percentTag = ((double)sumRow/(double)SUM_GRAND_TOTAL)*100; 
				   out.println(echoLineHtmlPercentTagTD(doString.displayNumber("#,##0.0",percentTag)));
				}
				
			 %>
		</TR>
		<%
  }	//#END For Loop
}//#END Check Null of ArrayList <rowGridTableList>
 %>
<!-- #######################Grand Total summary#######################-->
<tr  >
<% c = 0; %>
                			<td colspan="3" align="center" class="grandtotal">Grand Total </td>
						    <td  align="center" valign="middle" class="grandtotal"><%=genRowGrandTotalLinkHtml(request.getContextPath(),sumColumn[c++],typeDDL,itemNo,"1",fromDate,toDate,multiFlag,projectSel,"row")%></td>
	                        <td  align="center" valign="middle" class="grandtotal"><%=genRowGrandTotalLinkHtml(request.getContextPath(),sumColumn[c++],typeDDL,itemNo,"2",fromDate,toDate,multiFlag,projectSel,"row")%></td>
	                       	<td  align="center" valign="middle" class="grandtotal"><%=genRowGrandTotalLinkHtml(request.getContextPath(),sumColumn[c++],typeDDL,itemNo,"3",fromDate,toDate,multiFlag,projectSel,"row")%></td>
	                       	<td  align="center" valign="middle" class="grandtotal"><%=genRowGrandTotalLinkHtml(request.getContextPath(),sumColumn[c++],typeDDL,itemNo,"4",fromDate,toDate,multiFlag,projectSel,"row")%></td>
                			<td  align="center" valign="middle" class="grandtotal"><%=genRowGrandTotalLinkHtml(request.getContextPath(),sumColumn[c++],typeDDL,itemNo,"5",fromDate,toDate,multiFlag,projectSel,"row")%></td> 
                			<td  align="center" valign="middle" class="grandtotal"><%=genRowGrandTotalLinkHtml(request.getContextPath(),sumColumn[c++],typeDDL,itemNo,"6",fromDate,toDate,multiFlag,projectSel,"row")%></td>  
                			<td  align="center" valign="middle" class="grandtotal"><%=genRowGrandTotalLinkHtml(request.getContextPath(),sumColumn[c++],typeDDL,itemNo,"7",fromDate,toDate,multiFlag,projectSel,"row")%></td>  
							<td  align="center" valign="middle" class="grandtotal"><%=genRowGrandTotalLinkHtml(request.getContextPath(),sumColumn[c++],typeDDL,itemNo,"8",fromDate,toDate,multiFlag,projectSel,"row")%></td>
	                        <td  align="center" valign="middle" class="grandtotal"><%=genRowGrandTotalLinkHtml(request.getContextPath(),sumColumn[c++],typeDDL,itemNo,"9",fromDate,toDate,multiFlag,projectSel,"row")%></td>
	                       	<td  align="center" valign="middle" class="grandtotal"><%=genRowGrandTotalLinkHtml(request.getContextPath(),sumColumn[c++],typeDDL,itemNo,"10",fromDate,toDate,multiFlag,projectSel,"row")%></td>
	                       	<td  align="center" valign="middle" class="grandtotal"><%=genRowGrandTotalLinkHtml(request.getContextPath(),sumColumn[c++],typeDDL,itemNo,"11",fromDate,toDate,multiFlag,projectSel,"row")%></td>
                			<td  align="center" valign="middle" class="grandtotal"><%=genRowGrandTotalLinkHtml(request.getContextPath(),sumColumn[c++],typeDDL,itemNo,"12",fromDate,toDate,multiFlag,projectSel,"row")%></td> 
                			<td  align="center" valign="middle" class="grandtotal"><%=genRowGrandTotalLinkHtml(request.getContextPath(),sumColumn[c++],typeDDL,itemNo,"13",fromDate,toDate,multiFlag,projectSel,"row")%></td>  
                			<td  align="center" valign="middle" class="grandtotal"><%=genRowGrandTotalLinkHtml(request.getContextPath(),sumColumn[c++],typeDDL,itemNo,"14",fromDate,toDate,multiFlag,projectSel,"row")%></td>  
                			<td  align="center" valign="middle" class="grandtotal"><%=genRowGrandTotalLinkHtml(request.getContextPath(),sumColumn[c++],typeDDL,itemNo,"15",fromDate,toDate,multiFlag,projectSel,"row")%></td> 
                			<TD  align="center" valign="middle" class="grandtotal"><%=genRowGrandTotalLinkHtml(request.getContextPath(),sumColumn[c++],typeDDL,itemNo,"99",fromDate,toDate,multiFlag,projectSel,"99")%></TD> 
                			<TD class="item ; grandtotal" vAlign=middle align=center><%=format1.format(100)%> %</TD>             			
</tr>
<!-- #######################Grand Total summary#######################-->
<tr  >
<% c = 0; %>
                			<td colspan="3" align="center" class="grandtotal">% Percentage </td>
						    <td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],sumColumn[15]))%> %</td>
	                        <td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],sumColumn[15]))%> %</td>
	                       	<td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],sumColumn[15]))%> %</td>
	                       	<td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],sumColumn[15]))%> %</td>
                			<td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],sumColumn[15]))%> %</td> 
                			<td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],sumColumn[15]))%> %</td>  
                			<td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],sumColumn[15]))%> %</td>  
							<td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],sumColumn[15]))%> %</td>
	                        <td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],sumColumn[15]))%> %</td>
	                       	<td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],sumColumn[15]))%> %</td>
	                       	<td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],sumColumn[15]))%> %</td>
                			<td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],sumColumn[15]))%> %</td> 
                			<td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],sumColumn[15]))%> %</td>  
                			<td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],sumColumn[15]))%> %</td>  
                			<td  align="center" valign="middle" class="grandtotal"><%=doString.displayNumber("#,##0.0",CalPercentTage(sumColumn[c++],sumColumn[15]))%> %</td> 
                			<TD align="center" valign="middle" class="grandtotal"><%=format1.format(100)%> %</TD> 
                			<TD class="item ; grandtotal" vAlign=middle align=center>&nbsp;</TD>             			
</tr>

</TBODY></TABLE></TD></TR></TBODY></TABLE>

<%
if("01".equalsIgnoreCase(itemNo)){ //ประเภทแจ้งซ่อมเท่านั้น
 %>

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
<TD class=item_tab2 width=200>รายละเอียดสรุปรายงานฐานการรับสายตามช่วงโอน คิดเป็นสัดส่วน %</TD>
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
<%
//Calulate Summary
int otherJob = 0;
otherJob = sumColumn[15]-job01;
 %>
<TBODY>
<TR >
	<TD class=col_name height=1  width="40%">ประเภท</TD>
	<TD class=col_name   align=center>จำนวน</TD>
	<TD class=col_name   align=center>&nbsp;&nbsp;&nbsp;%&nbsp;&nbsp;&nbsp;</TD>
</TR> 
<tr  bgcolor='#ffffff'>
    <TD class="item ; dotline" vAlign=middle align=center>แจ้งซ่อมบ้านทั่วไป</TD>
    <TD class="item ; dotline" vAlign=middle align=center><%=format1.format(job01)%></TD>
    <TD class="item ; dotline" vAlign=middle align=center><%=doString.displayNumber("#,##0.0",CalPercentTage(job01,sumColumn[15]))%> %</TD>
</tr> 
<tr bgcolor='#f7f7f7'>
    <TD class="item ; dotline" vAlign=middle align=center>ซ่อมบ้านทั่วไป  <= 15 เดือน (ของประเภทแจ้งซ่อมทั่วไป)</TD>
    <TD class="item ; dotline" vAlign=middle align=center><%=format1.format(LessThan15Month)%> </TD>
    <TD class="item ; dotline" vAlign=middle align=center><%=doString.displayNumber("#,##0.0",CalPercentTage(LessThan15Month,job01))%> %</TD>
</tr> 
<tr bgcolor='#ffffff' >
    <TD class="item ; dotline" vAlign=middle align=center>ซ่อมบ้านทั่วไป > 15 เดือน (ของประเภทแจ้งซ่อมทั่วไป)</TD>
    <TD class="item ; dotline" vAlign=middle align=center><%=format1.format(MoreThan15Month)%> </TD>
    <TD class="item ; dotline" vAlign=middle align=center><%=doString.displayNumber("#,##0.0",CalPercentTage(MoreThan15Month,job01))%> %</TD>
</tr>
<tr bgcolor='#f7f7f7'>
    <TD class="item ; dotline" vAlign=middle align=center>แจ้งซ่อมอื่นๆ(ของทั้งหมด)</TD>
    <TD class="item ; dotline" vAlign=middle align=center><%=format1.format(otherJob)%></TD>
    <TD class="item ; dotline" vAlign=middle align=center><%=doString.displayNumber("#,##0.0",CalPercentTage(otherJob,sumColumn[15]))%> %</TD>
</tr>
</TBODY></TABLE></TD></TR></TBODY></TABLE>

<%} %>

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
<TD class=act_tab4>
 <a href="javascript:this.close();" target="_top"><img border="0" src="images/bu_close.gif" align="absmiddle" width="50" height="15"></a>
 <%--  
		<A href="javascript:history.back();" target=_self><IMG border=0 src="images/bu_back.gif" width=50 align=absMiddle height=15></A>
&nbsp;  <A href="/LHServ/SERV_Index.jsp" target=_top><IMG border=0 src="images/bu_home.gif" width=50 align=absMiddle height=15></A>
--%>
</TD></TR></TBODY></TABLE><BR style="FONT-SIZE: 30pt">
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
  System.out.println("!!Errors : SERV_ReportSvcDesc.jsp :"+e.toString());
} %>
