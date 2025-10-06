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
		
		private static  String toDDMMYY_THAI2(String str){
			 if ((str == null) || str.equals("")) {
				 return  str;
			 }else{
				 String d2[] = str.split("\\-"); //2013-03-29
				 return d2[2]+"/"+d2[1]+"/"+(Integer.parseInt(d2[0])+543);
			 }
		}	
	
	  //doDescForm(xID,xGroupId,xSubId,xItemsNo,xCAT_TYPE){	
	  private static String echoLineHtmlTagTxtTD(String param,boolean isCurrency,int xId,String groupId,String supId,String items,String code){
	    String tagTdHTML = "";
	    DecimalFormat  format1 = new DecimalFormat("#,###,###");
	    if("0".equals(param.trim())){
	    	tagTdHTML = "0";
	    }else{
	    	if(isCurrency){
	    		tagTdHTML = "<A HREF=\"javascript:doDescForm('"+xId+"','"+groupId+"','"+supId+"','"+items+"','"+code+"');\" >"+format1.format(Double.parseDouble(param))+"</A>";
	    	}else{
	    		tagTdHTML = "<A HREF=\"javascript:doDescForm('"+xId+"','"+groupId+"','"+supId+"','"+items+"','"+code+"');\">"+param+"</A>";
	    	}
	    }
	    return tagTdHTML; 
	  }
	  
	 private static String echoSubsLineHtmlTagTxtTD(String param,boolean isCurrency){
	    String tagTdHTML = "";
	    DecimalFormat  format1 = new DecimalFormat("#,###,###");
	    if("0".equals(param.trim())){
	    	tagTdHTML = "0";
	    }else{
	    	if(isCurrency){
	    		tagTdHTML = "<A HREF='#' target='_blank'>"+format1.format(Double.parseDouble(param))+"</A>";
	    	}else{
	    		tagTdHTML = "<A HREF='SERV_RptKeepBeforeDesc03.html'>"+param+"</A>";
	    	}
	    }
	    return tagTdHTML;
	  }
	  
	 private static String echoItemsLineHtmlTagTxtTD(String param,boolean isCurrency){
	    String tagTdHTML = "";
	    DecimalFormat  format1 = new DecimalFormat("#,###,###");
	    if("0".equals(param.trim())){
	    	tagTdHTML = "0";
	    }else{
	    	if(isCurrency){
	    		tagTdHTML = "<A HREF='SERV_RptKeepBeforeDesc03.html'>"+format1.format(Double.parseDouble(param))+"</A>";
	    	}else{
	    		tagTdHTML = "<A HREF='SERV_RptKeepBeforeDesc03.html'>"+param+"</A>";
	    	}
	    }
	    return tagTdHTML;
	  }
	  
    private static String echoSumLineHtmlTagTxtTD(String param,boolean isCurrency){
	    String tagTdHTML = "";
	    DecimalFormat  format1 = new DecimalFormat("#,###,###");

	    if("0".equals(param.trim())){
	    	tagTdHTML = "0";
	    }else{
	    	if(isCurrency){
	    		tagTdHTML = "<A HREF='SERV_RptKeepBeforeDesc03.html'>"+format1.format(Double.parseDouble(param))+"</A>";
	    	}else{
	    		tagTdHTML = "<A HREF='SERV_RptKeepBeforeDesc03.html'>"+param+"</A>";
	    	}
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
  Object objRptMainGroup = request.getAttribute("rptMainGroupList");
  ArrayList  rptMainGroupList = null;
  if(objRptMainGroup != null){
  	rptMainGroupList =(ArrayList)objRptMainGroup;
  }else{
    rptMainGroupList = new ArrayList();
  }
  
  Object objRptSubGroup = request.getAttribute("rptSubsList");
  ArrayList  rptSubGroupList = null;
  if(objRptSubGroup != null){
  	rptSubGroupList =(ArrayList)objRptSubGroup;
  }else{
    rptSubGroupList = new ArrayList();
  }

  Object objRptSubItems = request.getAttribute("rptItempsList");
  ArrayList  rptItemsList = null;
  if(objRptSubItems != null){
  	rptItemsList =(ArrayList)objRptSubItems;
  }else{
    rptItemsList = new ArrayList();
  }
	
  //----------------------------------------- 
   Object objMainList = request.getAttribute("arrMainList");
   Object objSubsList = request.getAttribute("arrSubsList");
   Object objItempsList = request.getAttribute("arrItempsList");
   
   ArrayList  arrMainList = null;
   ArrayList  arrSubsList = null;
   ArrayList  arrItemsList = null;
   if(objMainList != null){
  		arrMainList =(ArrayList)objMainList;
   }else{ arrMainList = new ArrayList(); }
   if(objSubsList != null){
   		arrSubsList =(ArrayList)objSubsList;
   }else{ arrSubsList = new ArrayList(); }
   
   if(objItempsList != null){
     	arrItemsList =(ArrayList)objItempsList;
   }else{	arrItemsList = new ArrayList();}
   
  //-----------------------------------------
  //--project selected
  Object pjArrList = request.getAttribute("projSelectdList");
  ArrayList projSelectdList = null;
  if(pjArrList!=null){
     projSelectdList = (ArrayList)pjArrList;
  }else{
     projSelectdList = new ArrayList();
  }
  String fromDate = request.getAttribute("fromDate")==null?"": (String)request.getAttribute("fromDate");
  String toDate = request.getAttribute("toDate")==null?"": (String)request.getAttribute("toDate");
  String rbtType = request.getAttribute("rbtType")==null?"": (String)request.getAttribute("rbtType");
  String type_amt = request.getAttribute("type_amt")==null?"A": (String)request.getAttribute("type_amt");
  String multiFlag = request.getAttribute("multiFlag")==null?"": (String)request.getAttribute("multiFlag");//0=ALL
  
  String mainDDL = request.getAttribute("mainDDL")==null?"":(String)request.getAttribute("mainDDL");
  String subDDL = request.getAttribute("subDDL")==null?"":(String)request.getAttribute("subDDL");
  String itemsDDL = request.getAttribute("itemsDDL")==null?"":(String)request.getAttribute("itemsDDL");
  String caseNumber =request.getAttribute("caseNumber")==null?"": (String)request.getAttribute("caseNumber");

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML > 
<HEAD>
<TITLE>Report รายละเอียดสรุปรายงานเก็บก่อนโอน</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620"/>
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css"/>
<script language="javascript" src="script_fx.js"></script>
<script type="text/javascript" src="jquery/jquery-1.11.3.min.js"></script>
<script type="text/javascript" src="jquery/loadImg.js"></script>
<script type="text/javascript">
  function doSearching() {
	if($('select[name="mainDDL"] option:selected').val()==''){
		 alert(" กรุณาเลือกหมวดหลัก !");
		 $('select[name="mainDDL"]').focus();
		 return;
	}else if($('select[name="subDDL"] option:selected').val()==''){
		 alert(" กรุณาเลือกหมวดรอง  !");
		 $('select[name="subDDL"]').focus();
		 return;
	}else if($('select[name="itemsDDL"] option:selected').val()==''){
		 alert(" กรุณาเลือกหมวดย่อย   !");
		 $('select[name="itemsDDL"]').focus();
		 return;
	}else{
	    onPleaseWait(); 
		doSubmitForm("<%=Constants.APP_PATH%>/SERV_RptTransAfterEndServlet?cmd=GenReport2");	
	}
  }
  
  function doDescForm(xID,xGroupId,xSubId,xItemsNo,xCAT_TYPE){
	    $('input[name="xid"]').val(xID);
	 	$('input[name="groupNo"]').val(xGroupId);
	 	$('input[name="subNo"]').val(xSubId);
	 	$('input[name="itemsNo"]').val(xItemsNo);
	    $('input[name="CAT_TYPE"]').val(xCAT_TYPE);
		doSubmitFormBlank("<%=Constants.APP_PATH%>/SERV_RptTransAfterEndServlet?cmd=desc");	
  }
  function doExport2Excel(){
  	 onPleaseWait(); 
	 doSubmitFormBlank("<%=Constants.APP_PATH%>/SERV_RptTransAfterEndExport2Excel");	
  }
  function doSubmitFormBlank(url){
	$('form').attr('action', url);
	$('form:first').attr('target', '_blank').submit();
	$('[target]').removeAttr('target');
   }

 function doSubmitForm(url){
 	$('form').attr('action', url);
	$('form:first').submit();
}
function GetDynamicDropdown(val) {
    $("#itemsDDL").html("<option value=''>------ กรุณาเลือกหมวดย่อย ------</option>	");
	$.ajax({
	type: "POST",
	url: "<%=Constants.APP_PATH%>/SERV_RptTransAfterEndServlet?cmd=onchange",
	data:'mainDDL='+val,
	success: function(data){
		$("#subDDL").html(data);
	  }
	});
}

function GetDynamicDropdownSub(val) {
	var mainDDLx = $('select[name="mainDDL"] option:selected').val();
	$.ajax({
	type: "POST",
	url: "<%=Constants.APP_PATH%>/SERV_RptTransAfterEndServlet?cmd=onchangeItems",
	data: 'mainDDL='+mainDDLx+'&subDDL='+val,
	success: function(data){
		$("#itemsDDL").html(data);
	  }
	});
}

function onPleaseWait(){
	document.all.pleasewaitScreen.style.pixelTop = (document.body.scrollTop + 120);
	$('#pleasewaitScreen').show();
	setTimeout(function(){  $('#pleasewaitScreen').css("visibility", 'hidden'); }, 20000); //wait 20 seconds
	$('#pleasewaitScreen').css('visibility', 'visible');
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
<style >

.box2 {  font-family: Tohama,Arial,sans-serif; font-size:10.1pt; font-weight:normal;
	padding-top: 1px; padding-right: 1px; padding-bottom: 1px; padding-left: 1px; 
	 color:#165396; background-color: white; border: 1px #BEDCFF solid ; 
}

.fg_style1 { mso-number-format:"\@";}
 .col_name1{ 	font-size: 8.0pt ; color: rgb(0,50,200) ; /*text-align: right ; */ 
			background-image: url(images/col_bg1.gif) ; background-repeat : repeat-x ;
			border-right:1px solid rgb(135,185,247) ; border-bottom:1px solid rgb(135,185,247) ; 	}
</style>

<base target="_self">
</HEAD>

<%-- 
/**********************************************/
 * create by : pradoem wonkraso
 * date time: 2016.06.09
 * Last modify :
 * version :1.0
 * project Name : Report  IPV by QC
 * description :  Report  เก็บก่อนโอนแยกตามรายเดือน 
***************************************************/
--%>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM ACTION="" METHOD="POST" id="rptForm" >

<input type="hidden" name="rbtType" value="<%=rbtType%>">
<input type="hidden" name="multiFlag" value="<%=multiFlag %>">
<input type="hidden" name="fromDate" value="<%=fromDate%>">
<input type="hidden" name="toDate" value="<%=toDate%>">

<input type="hidden" name="xid" >
<input type="hidden" name="groupNo" >
<input type="hidden" name="subNo" >
<input type="hidden" name="itemsNo" >
<input type="hidden" name="CAT_TYPE" >


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
          &nbsp;รายละเอียดเงือนไขการแสดงผล</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                
          <td class="item_tab2" width="400">รายละเอียด Report รายละเอียดสรุปรายงานเก็บก่อนโอน</td>
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
    <td class="item ; dotline01" height="22" colspan="4">ประเภท   :
    <%
    if("A".equalsIgnoreCase(rbtType)){
    	out.println("&nbsp; ตามวันที่แจ้งซ่อม ");
    }else{
    	out.println("&nbsp; ตามช่วงเดือนที่โอน");
    }
     %>
    </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" colspan="4">ระหว่างวันที่  &nbsp;<%=toDDMMYY_THAI2(fromDate) %>&nbsp;&nbsp;&nbsp;ถึงวันที่&nbsp;&nbsp;&nbsp;<%=toDDMMYY_THAI2(toDate) %></td>
  </tr>
  <tr>
    <td colspan="4">
    
    <table border="0" width="100%" cellspacing="0" cellpadding="0">
     <tr>
	    <td width="10%" height="22" class="item ; dotline01">ระบุหมวดหลัก  : </td>
	    <td width="25%" class="dotline01 ; item"> &nbsp;    </td>
	    <td width="" class="dotline01 ; item ">
		 	<select name="mainDDL" class="box2" style='width:280' size='1' id="mainDDL" onchange="javascript:GetDynamicDropdown(this.value);"> 
			<option value=''>------ กรุณาเลือกหมวดหลัก ------</option>
			<%
			String tempSelected= "";
			if("AAA".equals(mainDDL)){
			    tempSelected = "selected";
			}
			 %>
			<option value='AAA' <%=tempSelected %>>ALL- เลือกทุกหมวดหลัก </option>
<%
  try{
		 if(arrMainList!=null && arrMainList.size()>0){		
			//ArrayList strList = null;	
			HashMap hashMap = null;		
			String valueTxt = "";
			String nameTxt = "";	
			String tempInOut = "";
			String selected = "";
			//-----------------------			 
			Iterator it = arrMainList.iterator();								   							   
			while(it.hasNext()){									
				hashMap = (HashMap)it.next();	
				if("01".equals(doString.checkString(hashMap.get("f_in_out").toString()))){
				    tempInOut ="ภายนอก";
				}else if("02".equals(doString.checkString(hashMap.get("f_in_out").toString()))){
				    tempInOut = "ภายใน";  
				}		
				valueTxt = doString.checkString(hashMap.get("i_group").toString());
				nameTxt =  doString.checkString(hashMap.get("n_itmjob").toString());
				
				selected = "";
				if(mainDDL.equals(valueTxt)){
					selected = " selected ";
				}

				%>
				<option value="<%=doString.checkString(hashMap.get("f_in_out").toString())%>:<%=valueTxt %>" <%=selected%> ><%=tempInOut%> - <%=valueTxt%> <%=nameTxt%></option>
				<%
		  }
      } %>					 
		   	</select>
	    </td>
  </tr>
  
  <tr>
    <td width="10%" height="22" class="item ; dotline01">ระบุหมวดรอง : </td>
    <td width="25%" class="dotline01 ; item"> &nbsp;     </td>
    <td width="" class="dotline01 ; item">
 	<select name="subDDL" class="box2" style='width:280' size='1' id="subDDL"  onchange="javascript:GetDynamicDropdownSub(this.value);"> 
	 <option value=''>------ กรุณาเลือกหมวดรอง ------</option>	
	 <%
	   if("5".equals(caseNumber) || "6".equals(caseNumber) || "7".equals(caseNumber)){ 
	   String tempSubDDL = mainDDL+subDDL; //0504
		  %>
		  	 <option value='nnnn'>nnnn **** ไม่แสดงหมวดรอง ****</option>	
		     <option value='ALL'>ALL เลือกทุกหมวดรอง</option>
		  <%  
			if(arrSubsList!=null && arrSubsList.size()>0){
				HashMap hashMap = null;		
				String valueTxt = "";
				String nameTxt = "";	
				String selected = "";
				String code = "";
				//-----------------------			 
				Iterator it = arrSubsList.iterator();								   							   
				while(it.hasNext()){									
					hashMap = (HashMap)it.next();	
			    	
			    	valueTxt = doString.checkString(hashMap.get("i_type").toString());//xx:111 
			    	nameTxt = doString.checkString(hashMap.get("n_itmjob").toString());	 
			    	code =  doString.checkString(hashMap.get("i_group").toString())+doString.checkString(hashMap.get("i_type").toString());

					selected = "";
					if(tempSubDDL.equals(doString.checkString(hashMap.get("i_itmjob").toString()))){
						selected = " selected ";
					}
			    	if("".equalsIgnoreCase(code)){ // please select
			    	   continue;
			    	}
			    	if("ALLALL".equalsIgnoreCase(code)){
			    		code = "";
			    		continue;
			    	}
			    	if("nnnnnnnn".equals(code)){
			    		code = doString.checkString(hashMap.get("i_group").toString());
			    		continue;
			    	}
					%>
					<option value="<%=valueTxt %>" <%=selected%> ><%=code%> <%=nameTxt%></option>
					<%
				}//#End while	
			}//#End IF null List	
	   }//#End If 5
	  %>				 
   	</select>	
    </td>
  </tr>
  
  <tr>
    <td width="10%" height="22" class="item ; dotline01">ระบุหมวดย่อย      : </td>
    <td width="25%" class="dotline01 ; item">&nbsp; </td>
    <td width="" class="dotline01 ; item">
 	<select name="itemsDDL" class="box2" style='width:280' size='1' id="itemsDDL" > 
	 <option value=''>------ กรุณาเลือกหมวดย่อย ------</option>		
	 <option value='nnnn'>nnnn **** ไม่แสดงหมวดย่อย ****</option>	
	 <option value='ALL'>ALL เลือกทุกหมวดย่อย</option>
	 <%
	 if("7".equals(caseNumber)){
	 	String tempItemsDDL = mainDDL+subDDL+itemsDDL;
	 	//System.out.println("===== tempItemsDDL : "+tempItemsDDL);
	 	//System.out.println("===== itemsDDL : "+itemsDDL);
	 	if(arrItemsList!=null && arrItemsList.size()>0){
			HashMap hashMap = null;		
			String valueTxt = "";
			String nameTxt = "";	
			String selected = "";
			String code = "";
			//-----------------------			 
			Iterator it = arrItemsList.iterator();								   							   
			while(it.hasNext()){									
				hashMap = (HashMap)it.next();
				code =  doString.checkString(hashMap.get("i_itmjob").toString());
			    valueTxt = doString.checkString(hashMap.get("i_itmjob").toString());
			    nameTxt = doString.checkString(hashMap.get("n_itmjob").toString());
				
				selected = "";
				if(itemsDDL.equals(doString.checkString(hashMap.get("i_itmjob").toString()))){
					selected = " selected ";
				}
			    if("".equalsIgnoreCase(code)){ // please select
			      continue;
			    }
			    if("ALL".equalsIgnoreCase(code)){
			    	code = "";
			    	continue;
			    }
			    if("nnnnnnnn".equals(code)){
			    	code = doString.checkString(hashMap.get("i_itmjob").toString());
			    	continue;
			    }
				%>
				<option value="<%=valueTxt %>" <%=selected%> ><%=code%> <%=nameTxt%></option>
				<%		
			}//#End While
		}//#End arrSubsList	
	 }//#End if 7
	  %> 
   	</select>
   	&nbsp;
   	&nbsp;
   	&nbsp;<A HREF="javascript:doSearching();">
			<img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22" style="cursor:hand"></a>
    </td>
    </table>
    </td>
  </tr>
  
   <%
   
     String projectID = "";
    // System.out.println("xxxxxx 11111111111 :"+multiFlag);
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
          <td class="item_tab2" width="200">สรุปรายงานเก็บก่อนโอนแยกตามหมวด</td>
            <td class="item_tab3"></td>
           <td>&nbsp;
          
            <input type="radio" value="A" name="type_amt" <% if("A".equals(type_amt)){ out.println("checked"); } %>  >จำนวนรายการ&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" value="B" name="type_amt" <% if("B".equals(type_amt)){ out.println("checked"); } %> >จำนวนเลขที่อ้างอิง&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" value="C" name="type_amt" <% if("C".equals(type_amt)){ out.println("checked"); } %> >จำนวนเงิน&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" value="D" name="type_amt" <% if("D".equals(type_amt)){ out.println("checked"); } %> >จำนวนแปลง&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<A HREF="javascript:doSearching();">
			<img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22" style="cursor:hand"></a>
			
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

<table border="0" width="100%" cellspacing="" cellpadding="0">
  <tr>
    <td width="100%" class="frmL">
     <table border="0" width="100%" cellspacing="0" cellpadding="0">
   
    <tr>
          <td class="col_name" width="22%">สรุปรายงานโอนหลัง END</td>
          <td class="col_name" width="6%">หลัง END 1 เดือน</td>
          <td class="col_name" width="6%">หลัง END 2 เดือน</td>
          <td class="col_name" width="6%">หลัง END 3 เดือน</td>
          <td class="col_name" width="6%">หลัง END 4 เดือน</td>
          <td class="col_name" width="6%">หลัง END 5 เดือน</td>
          <td class="col_name" width="6%">หลัง END 6 เดือน</td>
          <td class="col_name" width="6%">หลัง END 7 เดือน</td>
          <td class="col_name" width="6%">หลัง END 8 เดือน</td>
          <td class="col_name" width="6%">หลัง END 9 เดือน</td>
          <td class="col_name" width="6%">หลัง END 10 เดือน</td>
          <td class="col_name" width="6%">หลัง END 11 เดือน</td>
          <td class="col_name" width="6%">หลัง END 12 เดือน</td>
          <td class="col_name" width="6%">หลัง END &gt;12 เดือน </td>
        </tr>  
        
        <%
         String  strSub[] = null;	
         String  strItems[] = null;	
         boolean isCurrency = false;
         boolean isEnableExportExcel = false;
         if("C".equals(type_amt)){
            isCurrency = true;
         }
         if(rptMainGroupList!=null && rptMainGroupList.size()>0){	
	         	Iterator itMainGroup = rptMainGroupList.iterator();		
	         	String  str[] = null;	
	         	String tempInOut = "";	
	         	isEnableExportExcel = true;
	         	int x = 1;	
	         	int y = 1;
	         	int z = 1;			   							   
				while(itMainGroup.hasNext()){	
				   str =(String [])itMainGroup.next();
				   if("01".equals(str[0])){
				      tempInOut = "ภายนอก";
				   }else if("02".equals(str[0])){
				      tempInOut = "ภายใน";
				   }
				   x = 1;	
				   //String param,boolean isCurrency,String xId,String groupId,String supId,String items
         	    %>
         			<tr bgcolor="#FFFFCC">
			            <td class="fg_style1 ; dotline" width="%"><%=tempInOut %> - <%=str[1]%> <%=str[4]%></td>			            
		                      <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(str[5],isCurrency,x++,str[1],"","","01") %></td>		                      
		                      <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(str[6],isCurrency,x++,str[1],"","","01") %></td>		                      
		                      <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(str[7],isCurrency,x++,str[1],"","","01") %></td>		                      
		                      <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(str[8],isCurrency,x++,str[1],"","","01") %></td>	                      
		                      <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(str[9],isCurrency,x++,str[1],"","","01") %></td>		                      
		                      <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(str[10],isCurrency,x++,str[1],"","","01") %></td>		                      
		                      <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(str[11],isCurrency,x++,str[1],"","","01") %></td>                      
		                      <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(str[12],isCurrency,x++,str[1],"","","01") %></td>	                      
		                      <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(str[13],isCurrency,x++,str[1],"","","01") %></td>
		                      <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(str[14],isCurrency,x++,str[1],"","","01") %></td>                     
		                      <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(str[15],isCurrency,x++,str[1],"","","01") %></td>
		                      <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(str[16],isCurrency,x++,str[1],"","","01") %></td>				  		  
		                      <!-- for subm column -->
		                      <td class="fg_style1 ; dotline" width="%"  align="center"><%=echoLineHtmlTagTxtTD(str[17],isCurrency,x++,str[1],"","","01") %>&nbsp;</td>
	               </tr> 
	               <%if("2".equals(caseNumber) || "4".equals(caseNumber) || "5".equals(caseNumber) || "6".equals(caseNumber) || "7".equals(caseNumber)){
					   if(rptSubGroupList!=null && rptSubGroupList.size()>0){		
						  strSub = null;					   							   
						  for (int s = 0; s < rptSubGroupList.size(); s++) { 
							 strSub = (String [])rptSubGroupList.get(s);
							 //System.out.println(str[1]+","+strSub[1]); 
							 if(str[1].equals(strSub[1])){   
							    y = 1;          	
	                         %>
		               		    <tr>
					                <td class="fg_style1 ; dotline" width="%"><FONT COLOR="rgb(0,50,200)">&nbsp;-&nbsp;<%=strSub[3] %> - <%=strSub[4]%></FONT></td>
							  		<td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strSub[5],isCurrency,y++,strSub[1],strSub[2],"","02") %></td>
			                        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strSub[6],isCurrency,y++,strSub[1],strSub[2],"","02") %></td>
			                        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strSub[7],isCurrency,y++,strSub[1],strSub[2],"","02") %></td>
			                        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strSub[8],isCurrency,y++,strSub[1],strSub[2],"","02") %></td>
			                        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strSub[9],isCurrency,y++,strSub[1],strSub[2],"","02") %></td>
			                        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strSub[10],isCurrency,y++,strSub[1],strSub[2],"","02") %></td>
			                        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strSub[11],isCurrency,y++,strSub[1],strSub[2],"","02") %></td>
			                        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strSub[12],isCurrency,y++,strSub[1],strSub[2],"","02") %></td>
			                        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strSub[13],isCurrency,y++,strSub[1],strSub[2],"","02") %></td>
			                        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strSub[14],isCurrency,y++,strSub[1],strSub[2],"","02") %></td>
			                        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strSub[15],isCurrency,y++,strSub[1],strSub[2],"","02") %></td>
			                        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strSub[16],isCurrency,y++,strSub[1],strSub[2],"","02") %></td>							        
				                    <!-- for subm column -->
				                    <td class="fg_style1 ; dotline" width="%"  align="center"><%=echoLineHtmlTagTxtTD(strSub[17],isCurrency,y++,strSub[1],strSub[2],"","02") %>&nbsp;</td>
			                   </tr>          
         					<%            
         					}//#if(str[3]
         				}//#
         	      }//#rptSubGroupList
         	      if("6".equals(caseNumber) || "7".equals(caseNumber)){
         	    	 if(rptItemsList!=null && rptItemsList.size()>0){		
						  strItems = null;					   							   
						  for (int s = 0; s < rptItemsList.size(); s++) {
							  strItems = (String [])rptItemsList.get(s);
							   z = 1;	
							  //System.out.println("----->>"+strItems[1]+","+strItems[2]);
							  //System.out.println("----->>mainDDL:"+strItems[1]+",SubDD:"+subDDL);
							  if(mainDDL.equals(strItems[1]) && subDDL.equals(strItems[2]) ){ 
							  //mainDDL+subDDL
							  %>
							 	<tr>
							    <td  class="fg_style1 ; item ; dotline" width="%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;<%=strItems[3] %> - <%=strItems[4]%></td>
						        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strItems[5],isCurrency,z++,strItems[1],strItems[2],strItems[3],"03") %></td>
						        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strItems[6],isCurrency,z++,strItems[1],strItems[2],strItems[3],"03") %></td>
						        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strItems[7],isCurrency,z++,strItems[1],strItems[2],strItems[3],"03") %></td>
						        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strItems[8],isCurrency,z++,strItems[1],strItems[2],strItems[3],"03") %></td>
						        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strItems[9],isCurrency,z++,strItems[1],strItems[2],strItems[3],"03") %></td>
						        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strItems[10],isCurrency,z++,strItems[1],strItems[2],strItems[3],"03") %></td>
						        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strItems[11],isCurrency,z++,strItems[1],strItems[2],strItems[3],"03") %></td>
						        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strItems[12],isCurrency,z++,strItems[1],strItems[2],strItems[3],"03") %></td>
						        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strItems[13],isCurrency,z++,strItems[1],strItems[2],strItems[3],"03") %></td>
						        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strItems[14],isCurrency,z++,strItems[1],strItems[2],strItems[3],"03") %></td>
						        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strItems[15],isCurrency,z++,strItems[1],strItems[2],strItems[3],"03") %></td>
						        <td class="fg_style1 ; dotline" width="%" align="center"><%=echoLineHtmlTagTxtTD(strItems[16],isCurrency,z++,strItems[1],strItems[2],strItems[3],"03") %></td>												        
							    <!-- for subm column -->
							    <td class="fg_style1 ; dotline" width="%"  align="center"><%=echoLineHtmlTagTxtTD(strItems[17],isCurrency,z++,strItems[1],strItems[2],strItems[3],"03") %></td>        
							  </tr>
							 <%
							 }//# End if chek Type
						 }//End For rptItemsList
					  }//#End If null List
         	       }//# caseNumber 6
         	    }//#caseNumber 2,4,5
         	 }//#While Main Group
         	 %>
         	 <tr>
				<td  class="fg_style1 ; col_name1" width="%" height="25" colspan="14" align="center">&nbsp;</td>  
			 </tr>
         	 <%
         }else{
         %>
		    <tr height="18">
		          <td class="fg_style1 ; dotline" colspan="14">&nbsp;</td>
		    </tr>
		    <tr height="18">
		          <td class="fg_style1 ; dotline" align="center" colspan="14">*** ไม่มีข้อมูล ***</td>
		    </tr>
		     <tr height="18">
		          <td class="fg_style1 ; col_name1" colspan="14">&nbsp;</td>
		    </tr>
	    <%} %>
 </table>
 </td>
 </tr>
 </table>

<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">
            <%
            if(isEnableExportExcel){
             %>
            	<a href="javascript:doExport2Excel();" ><img border="0" src="images/act_export2excel.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
            <%} %>      	
                  	&nbsp;  
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
	
</FORM> 
</BODY>
<script type='text/javascript'>
   	<%
   	 if("1".equals(caseNumber) || "3".equals(caseNumber)){ %>
		   	$(document).ready(function(){
		   	    $("#subDDL").html("<option value='nnnn'>nnnn **** ไม่แสดงหมวดรอง ****</option>	");
		   		$("#itemsDDL").html("<option value='nnnnnnnn'> nnnnnnnn **** ไม่แสดงหมวดย่อย ****</option>	");
		   	 });	
	 <%} %>  
	 <%
   	 if("2".equals(caseNumber) || "4".equals(caseNumber)  ){ %>
		   	$(document).ready(function(){
		   	    $("#subDDL").html("<option value='ALL'>ALL เลือกทุกหมวดรอง</option>	");
		   		$("#itemsDDL").html("<option value='nnnnnnnn'> nnnnnnnn **** ไม่แสดงหมวดย่อย ****</option>	");
		   	 });	
	 <%} %>
	 
	 <%
   	 if("5".equals(caseNumber)){ %>
		   	$(document).ready(function(){
		   		$("#itemsDDL").html("<option value='nnnnnnnn'> nnnnnnnn **** ไม่แสดงหมวดย่อย ****</option>	");
		   	 });	
	 <%} %> 
	 <%
   	 if("6".equals(caseNumber)){ %>
		   	$(document).ready(function(){
		   		$("#itemsDDL").html("<option value='ALL'>ALL เลือกทุกหมวดย่อย</option>	");
		   	 });	
	 <%} %> 
	</script>
</HTML>
<%}catch(Exception e){
  System.out.println("!!Errors : SERV_RptKeepBefore_02_View.jsp :"+e.toString());
} %>
