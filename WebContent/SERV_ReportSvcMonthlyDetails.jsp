<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="java.util.Date" %>
<%@page import="java.text.*" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@ page import="com.lh.util.doString" %>
<%--@ include file="/confirmLogin.jsp" --%>
   
<%--   

/**********************************************/
 * create by : pradoem wonkraso
 * date time: 2017.07.26
 * date time: 2015.10.06
 * Last modify :
 * version :1.0
 * project Name : LHSERV
 * description : this is page for Gen report online with search form criteria 
***************************************************/
--%>  

<%!
//input:  2015-09-05 10:00:00.0
//output: 07/10/2558
	public static  String toDDMMYY_THAI2(String str){
		if ((str == null) || str.equals("")) {
			 return  str;
		}else{
		     String x = str.substring(0,10);
			 String d2[] = x.split("\\-"); //2013-03-29
			 return d2[2]+"/"+d2[1]+"/"+(Integer.parseInt(d2[0])+543)+" "+str.substring(10,16)+" น.";
		}
	}
 %>
<%

//-----------------------Paging--------------------------
String displayLine = request.getAttribute("displayLine")==null?"25":request.getAttribute("displayLine").toString();  
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


String thaiMonth[] = new String[] {"","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม",""};

//DecimalFormat  format1 = new DecimalFormat("#,###,##0");
//DecimalFormat  format2 = new DecimalFormat("#,###,##0.0");

  Object objReportHD= request.getAttribute("reportResultHD");
  ArrayList  reportGridTableList = null;
  
  //Object objReportSub = request.getAttribute("resultSub");
  //ArrayList  rowGridTableList = null;
  
  if(objReportHD != null){
  	reportGridTableList =(ArrayList)objReportHD;
  }else{
    reportGridTableList = new ArrayList();
  }
  
  /*if(objReportSub != null){rowGridTableList =(ArrayList)objReportSub;
  }else{rowGridTableList = new ArrayList();
  }*/
  
  ArrayList projSelectdList = (ArrayList)request.getAttribute("projSelectdList");
  //String fromDate = (String)request.getAttribute("fromDate");
  String yyDDL = (String)request.getAttribute("yyDDL");
  String typeDDL = (String)request.getAttribute("typeDDL");
  String multiFlag = (String)request.getAttribute("multiFlag");//0=ALL
  String typeName = (String)request.getAttribute("typeName");//Name of desc
  String param1 = (String)request.getAttribute("param1");//param1
  String param2 = (String)request.getAttribute("param2");//param2
  String projectSel = (String)request.getAttribute("projectSel");//projSelDDL
  String grandTotal = (String)request.getAttribute("grandTotal");//projSelDDL
  String itemSub = (String)request.getAttribute("itemSub");//01 แจ้งซ่อมทั่วไป

  String Month = request.getAttribute("Month")==null?"0":(String)request.getAttribute("Month");//1,2,3,4
  
  //String []arrFromThaiDate = fromDate.split("\\/");
  //String []arrToThaiDate = toDate.split("\\/");//22/09/2558


%>

<html>
<head>

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
	//call from  utilizer.genLinkNextPageHTML
	function changePage(nowPage) { 
		document.forms[0].nowPage.value=nowPage;
		do_totals1();
		doSubmit();
	} 
	
    function onChangePageNomber() {
        do_totals1();
		doSubmit();
	}	

	function doSubmit(){
	    
		document.forms[0].action="<%=request.getContextPath()%>/SERV_ReportSvcMonthlyServlet?cmd=Desc";
	    document.forms[0].submit();
	    //alert(document.forms[0].action);
	}
	function doExport(){
		document.forms[0].action="<%=request.getContextPath()%>/SERV_ReportSvcMonthlyServlet?cmd=Desc&export2Excel=Y";
	    document.forms[0].submit();
	    //alert(document.forms[0].action);
	}
	
	
	
</script>
<script language="javascript">

    function do_totals1() {
   	 	document.all.pleasewaitScreen.style.pixelTop = (document.body.scrollTop + 180);
    	document.all.pleasewaitScreen.style.visibility = "visible";
    	var msg = "<img src=\"<%=request.getContextPath()%>/images/p_loading.gif\" HEIGHT=\"60px\">";
    	document.getElementById("img1").innerHTML = msg;
    	//document.getElementById("img1").innerHTML= "<img src=\"/CALLService/images/p_loading.gif\" HEIGHT=\"60px\">";
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

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" >

<%--  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --%>
<DIV ID="pleasewaitScreen" STYLE="position: absolute; z-index: 0; top: 45%; left: 42%; visibility: hidden">
<TABLE BORDER="1" BORDERCOLOR="rgb(180,210,250)" CELLPADDING="0" CELLSPACING="0" 
	HEIGHT="125px" WIDTH="265px" ID="Table1">
	<TR>
	<TD BGCOLOR="#FFFFFF" ALIGN="CENTER" VALIGN="MIDDLE" class="test">
	<font color="rgb(255,120,0)" Size=3><b>Loading... Please wait</b></font>
	<br>
	<br>
	  <span id="img1"></span>
	</TD> 
	</TR>
</TABLE>
</DIV>
<%--  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --%>

<FORM name="frm1" METHOD="POST" ACTION="" >
<input type="hidden" name="nowPage">

<input type="hidden" name="typeDDL" value="<%=typeDDL %>">
<input type="hidden" name="param1"  value="<%=param1 %>">
<input type="hidden" name="param2" value="<%=param2 %>">
<input type="hidden" name="Month" value="<%=Month %>">
<input type="hidden" name="yyDDL" value="<%=yyDDL %>">

<input type="hidden" name="multiFlag" value="<%=multiFlag %>">
<input type="hidden" name="projectSel" value="<%=projectSel %>">
<input type="hidden" name="grandTotal" value="<%=grandTotal %>">
<input type="hidden" name="itemSub" value="<%=itemSub %>">



<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
           <td width="100%" class="bigh" align="left"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">
           &nbsp;รายงานฐานการรับสายตามเดือน</td>
          <td width="100%" align="right">          
          </td>
        </tr>
      </table>



<BR style="FONT-SIZE: 10pt">

	<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
	<TBODY>
	<TR>
		<TD class=item_tab1><IMG border=0 src="images/i_i.gif" width=20 align=absMiddle height=20></TD>
		<TD class=item_tab2 width=400 align="left">รายละเอียดเงื่อนไขแสดงรายงาน&nbsp; 
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
	<TD>&nbsp;</TD>
	</TR>
	</TBODY>
	</TABLE>


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
    <% if("row".equals(grandTotal) && !"99".equals(grandTotal)){
    	%>
	    <tr>
	    <td class="item ; dotline01" height="22" colspan="4" align="left">
	    &nbsp;ตามช่วง :  <font color="#0078ff"> <%=thaiMonth[Integer.parseInt(Month)] %>  &nbsp;&nbsp;&nbsp;ปี พ.ศ : <%=(Integer.parseInt(yyDDL)+543) %>
	    </font></td>
	  </tr>
    	<%
    }else if("col".equals(grandTotal) && !"99".equals(grandTotal)){
   %>
        <tr>
		    <td class="item ; dotline01" height="22" colspan="4" align="left">
		    	 &nbsp;ตามประเภท : <font color="#0078ff"> <%=typeName%></font>
		    </td>
		  </tr>
		<tr>
	    <td class="item ; dotline01" height="22" colspan="4" align="left">
	    &nbsp;ปี พ.ศ : <%=(Integer.parseInt(yyDDL)+543) %>
	    </td>
	  </tr>
  <%}else if("99".equals(grandTotal)){
   %>
      <tr>
		    <td class="item ; dotline01" height="22" colspan="4" align="left">
		    	 &nbsp;<font color="#0078ff">ทุกเดือน และ ทุกประเภท   ปี พ.ศ : <%=(Integer.parseInt(yyDDL)+543) %></font>
		    </td>
     </tr>
   <%
  }else{
      %>
      <tr>
		    <td class="item ; dotline01" height="22" colspan="4" align="left">
		    	 &nbsp;ตามประเภท : <font color="#0078ff"> <%=typeName%></font>
		    </td>
     </tr>
     <tr>
	    <td class="item ; dotline01" height="22" colspan="4" align="left">
	    &nbsp;ตามช่วง :  <font color="#0078ff"> <%=thaiMonth[Integer.parseInt(Month)] %>  &nbsp;&nbsp;&nbsp;ปี พ.ศ : <%=(Integer.parseInt(yyDDL)+543) %>
	    </font></td>
	  </tr>
      <%
  } %>
  
   <%
 	 String projectSelection = "";
     if(multiFlag.equals("0")){
   			%>
   			<tr><td class="item ; dotline01" height="22" width="10%" align="left">โครงการ : เลือกทุกโครงการ</td></tr>
   			<%
        }else{
         if(!"project".equalsIgnoreCase(typeDDL)){
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
						<tr><td class="item ; dotline01" height="22" width="10%" align="left">โครงการ :</td>
					<%} else if (line%3==0 && line!=0) {  
					%><tr><td class="item ; dotline01" height="22" width="10%" >&nbsp;</td><%
				     }	
				     %><td height="22" width="30%" class="dotline01"> 
				     <%=doString.checkString(strList.get(0).toString())+"-"+doString.checkString(strList.get(1).toString())+" "+tempNameProject%></td><%
					  if (line%3==2) {
							%></tr><%
					  }
					  line++;
				  }//#end while
	
			  while (line%3!=0) {
				  %><td height="22" width="30%" class="dotline01" align="left">&nbsp;</td><%
				  line++;
			 	  if (line%3==0) {
			 	  	out.print("</tr>");
				  }
			  }//#End while
	    }//#End if check null
	   }//End check All project
	   else{
	    out.println("&nbsp;");
	   }
  }//Else
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
	<TD vAlign=bottom width=5 align=right><IMG border=0 src="images/Corn04.gif" width=5 height=5></TD>
	</TR>
</TBODY>
</TABLE>

<BR style="FONT-SIZE: 10pt">


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="160">รายละเอียดรายงานฐานการรับสายตามเดือน</td>
                <td class="item_tab3"></td>
                <td align="right">&nbsp;
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



<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL">
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="%" class="col_name">No.</td>
          <td width="%" class="col_name">เลขที่เอกสาร</td>
          <td width="%" class="col_name">เบอร์โทร</td>
          <td width="%" class="col_name">รหัสโครงการ</td>
          <td width="%" class="col_name">ชื่อโครงการ</td>
          <td width="%" class="col_name">เเปลง</td>
          <td width="%" class="col_name">บ้านเลขที่</td>
          <td width="%" class="col_name">ชื่อลูกค้า</td>
          <td width="%" class="col_name">ชื่อ Agent</td>
          <td width="%" class="col_name">วันรับเรื่อง</td>
          <td width="%" class="col_name">รหัส/หมวดหลัก</td>
          <td width="%" class="col_name">รหัส/หมวดย่อย</td>
          <td width="%" class="col_name">วันนัดหมาย</td>
          <td width="%" class="col_name">เลขที่ใบแจ้งซ่อม</td>
          
        </tr>
        <%
        //System.out.println("reportGridTableList.size :"+reportGridTableList.size());
        boolean isRec =false;
        if(reportGridTableList!=null && reportGridTableList.size()>0){
	        List strList = null;
	        String tagColor = "";
	        int loop = Integer.parseInt(recordNo)+1;
			int c = 0;
			
			String tagColorBG1=" bgcolor='#ffffff' ";
			String tagColorBG2=" bgcolor='#f7f7f7' ";
	        //---------------------

	        Iterator itHD = reportGridTableList.iterator();
	        while(itHD.hasNext()){
	    	   strList = (ArrayList)itHD.next();
	    	   c++;

			    tagColor = tagColorBG1;
			    if((c%2)==0){
					tagColor = tagColorBG2;
				}	
				isRec = true;	
                %>        
		        <tr height="18px" <%=tagColor %>>
		          <td class="dotline ; item"><%=loop%></td>
		          <td align="center" class="dotline ; item" nowrap="nowrap"><%=strList.get(0)%></td>
		          <td align="center" class="dotline" nowrap="nowrap" ><%=strList.get(1)%>&nbsp;</td>
		          <td align="center" class="dotline" nowrap="nowrap"><%=strList.get(2)%>-<%=strList.get(3)%> </td>    
		          <td align="left"    class="dotline" nowrap="nowrap" ><%=strList.get(4).toString()%>&nbsp;</td>
		          <td  align="center"  class="dotline" nowrap="nowrap"><%=strList.get(5)%>&nbsp;</td>
		          <td  align="center"  class="dotline" nowrap="nowrap"><%=strList.get(6)%>&nbsp;</td>
		          <td  align="left"    class="dotline" nowrap="nowrap"><%=strList.get(7).toString()%>&nbsp;</td>
		          <td  align="left"  class="dotline" nowrap="nowrap"><%=strList.get(10).toString()%>&nbsp;</td>
		          <td  align="left"  class="dotline ; item" nowrap="nowrap"><%=toDDMMYY_THAI2(strList.get(17).toString())%>&nbsp;</td>
		          <td  align="left"  class="dotline" nowrap="nowrap"><%=strList.get(12)%>&nbsp;<%=strList.get(16).toString()%></td>
		          <td  align="left"  class="dotline" nowrap="nowrap"><%=strList.get(13)%>&nbsp;<%=strList.get(15).toString()%></td>
		          <td  align="left"  class="dotline" nowrap="nowrap"><%=toDDMMYY_THAI2(strList.get(11).toString())%>&nbsp;</td>
		          <td  align="center" class="dotline ; item" nowrap="nowrap"><%=strList.get(14)%>&nbsp;</td>  		                       
		        </tr>
		        
		<%     loop++;
	       }//#End while Loop;  
        }//#End if chec value
        else{ //No record or data
        	%>
				<tr align="left" > 
                       <td  height="22"  align="center" colspan="13" class="side01" >***ไม่มีข้อมูล***</td>
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


        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1">&nbsp;</td>
            <td width="75" class="act_tab2">&nbsp;
            <% 
            if(isRec){
             %>
 			<a href="javascript:doExport();"><img
					border="0" src="images/act_export2excel.gif"
					onMouseOut=nereidFade(this,70,50,5)
					onMouseOver=nereidFade(this,100,50,5)
					style="FILTER: alpha(opacity=70)" width="70" height="27"></a>     
			<%
			}
			 %>		      
            </td>      	
            <td class="act_tab3"></td>   
            <td class="act_tab4">
            <a href="javascript:this.close();" target="_top"><img border="0" src="images/bu_close.gif" align="absmiddle" width="50" height="15"></a>
 			<%-- 
              <a href="javascript:history.back();" ><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="SERV_Index.jsp" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a>
             --%> 
              </td>  
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
