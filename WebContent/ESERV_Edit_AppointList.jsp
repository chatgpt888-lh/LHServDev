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
 * Last modify :2014.02.17
 * version :1.0
 * project Name : E-Service
 * description : this is page for display && Master Data Appiont date form
***************************************************/
--%>
<%
	ArrayList projectDDL = (ArrayList)session.getAttribute("projDDL");
	ArrayList resultList = (ArrayList)request.getAttribute("result");
	//ArrayList dateList = (ArrayList)request.getAttribute("dateList");
	String sel_project	= request.getAttribute("selProj")==null?"": request.getAttribute("selProj").toString();	  
	String iLock	= request.getAttribute("iLock")==null?"": request.getAttribute("iLock").toString();	  	 
	String iDocno   = request.getAttribute("iDocno")==null?"": request.getAttribute("iDocno").toString();	
	String  iHouse  = request.getAttribute("iHouse")==null?"": request.getAttribute("iHouse").toString();	
	 
 %>
<HTML>
<HEAD>
<TITLE>(LINE)แก้ไขกำหนดเวลานัดเข้าตรวจสอบรายการซ่อม</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<style type="text/css">
 .box2 {  font-family: Tohama,Arial,sans-serif; font-size:10.1pt; font-weight:normal;
		padding-top: 1px; padding-right: 1px; padding-bottom: 1px; padding-left: 1px; 
	 	color:#165396; background-color: white; border: 1px #BEDCFF solid ; 
}
</style>
<script language="javascript" src="script_fx.js"></script>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

<script type="text/javascript">
function doGo(){   
	if(document.forms[0].projectDDL.value ==''){
		alert("กรุณาเลือกโครงการด้วย");
        return;
	} else{   
		 document.forms[0].action="<%=request.getContextPath()%>/ESERV_AfterAppointDateServlet?cmd=search";
		 document.forms[0].submit();
	 }
}
function doPopupPage(iDoc,projDDL,iLock,iHouse,custName,tel,status){   
    var param = "&projectDDL="+projDDL+
    			"&iDocno="+iDoc+
    			"&iLock="+iLock+
    			"&iHouse="+iHouse+
    			"&custName="+custName+
    			"&tel="+tel+
    			"&status="+status; 
	var url = "<%=request.getContextPath()%>/ESERV_AfterAppointDateServlet?cmd=pupup"+param;
	var name = "";
	var windowWidth = 820;
	var windowHeight = 550;	
    myleft=(screen.width)?(screen.width-windowWidth)/2:100;   
    mytop=(screen.height)?(screen.height-windowHeight)/2:100;        
    properties = "width="+windowWidth+",height="+windowHeight;  
    properties +=",scrollbars=yes, top="+mytop+",left="+myleft;     
    window.open(url,name,properties);  
}  

//------->>Opener submit
function doPopupSubmit(dDate,tTime,proj,idoc,iHouse,iLock,custName,tel,status){
	//alert(dDate+" ,"+tTime+","+proj+","+idoc);
	var param = "&dateDDL="+dDate+
	            "&timeDDL="+tTime+
	            "&projectDDL="+proj+
	            "&iDocno="+idoc+
	            "&iHouse="+iHouse+
	            "&iLock="+iLock+
	            "&custName="+custName+
    			"&tel="+tel+
    			"&status="+status; 
   // alert(param);
    document.forms[0].action="<%=request.getContextPath()%>/ESERV_AfterAppointDateServlet?cmd=submit"+param;
	document.forms[0].submit();		
}

function doSubmit(){
	if(document.forms[0].projectDDL.value ==''){
		alert("กรุณาเลือกโครงการด้วย");
        return;
	} else if(document.forms[0].bannNo.value ==''){
		alert("กรุณาเลือกกรอกบ้านเลขที่ด้วย");
        return;
	}else{   
		 document.forms[0].action="<%=request.getContextPath()%>/ESERV_AfterAppointDateServlet?cmd=submit";
		 document.forms[0].submit();
	 }
}
</script>



  <link rel="stylesheet" href="jquery/jquery-ui.css">
  <script src="jquery/jquery-1.11.3.min.js"></script>
  <script src="jquery/jquery-ui.min.js"></script>
  
   
<script src="jquery3/jquery.min3.6.3.js" ></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
<script src="jquery3/loadingoverlay.min2.1.7.js"></script>
  
 <style>
 
.select2-selection__rendered {
  	font-family: Tohama, Arial, sans-serif;
    font-size: 10.1pt;
    color: #165396 !important;
}


.select2-results__option {
	font-family: Tohama, Arial, sans-serif;
    font-size: 10.1pt;
    color: #165396;
}    
 
  .custom-combobox {
    position: relative;
    display: inline-block;
   
  }
  .custom-combobox-toggle {
    position:relative;
    top:-5px;
  /*  margin-left: 0px;*/
    padding:0px;
    height:22px;
  }
  .custom-combobox-input {
    margin: 0;
    padding:0px;
    width:250px;        
    height:24px;
     font-size:10pt;
    }            
  </style>
  <script>
   $(document).ready(function() {
 
    $('#projectDDL').select2({
         matcher: function(params, data) {
            if ($.trim(params.term) === '') {
                return data;
            }

            var searchTerm = params.term.trim().toLowerCase().replace(/:/g, '');
            var optionText = (data.text || '').toLowerCase().replace(/:/g, '');

            if (optionText.indexOf(searchTerm) > -1) {
                return data;
            }

            return null; 
        }
    });
    
});
  </script>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<form action="" name="frm" method="post">

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
                <td class="item_tab2" width="250">แก้ไขกำหนดเวลานัดเข้าตรวจสอบรายการซ่อม (LINE)</td>
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
		    <select name="projectDDL" id="projectDDL" style="width:350px; height:24px" > 
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
		    <td height="22" width="32%" class="dotline01"><input type="text" name="iDocno" class="box" style="width:100px" value="<%=iDocno%>"></td>
		  </tr>
		  <tr>
		    <td class="item ; dotline01" height="22" width="15%">บ้านเลขที่ :</td>
		    <td height="22" width="39%" class="dotline01"><input type="text" name="iHouse" class="box" style="width:100px" value="<%=iHouse%>"></td>
		    <td height="22" class="item ; dotline01" width="14%">แปลง :</td>
		    <td height="22" width="32%" class="dotline01"> <input type="text" name="iLock" class="box" style="width:100px" value="<%=iLock%>">&nbsp;&nbsp;&nbsp;&nbsp;
		      <a href="javascript:doGo();" ><img border="0" src="images/bu_go.gif" align="absmiddle" ></a> </td>
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
 <style>
     .green-icon {
    color: green;
}

/* สไตล์สำหรับข้อความ */
.styled-text {
            background-color: #4CAF50; /* สีพื้นหลังเขียว */
            color: white; /* สีข้อความขาว */
            /*  padding: 10px; เพิ่ม padding เพื่อให้ข้อความดูไม่แน่น */
            border-radius: 5px; /* มุมโค้ง */
            display: inline-block; /* ให้กล่องข้อความปรับขนาดตามเนื้อหา */
            font-family: Arial, sans-serif; /* กำหนดฟอนต์ */
            /* font-size: 16px;  ขนาดฟอนต์ */
        }

 </style>   

      <table   border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td class="col_name" width="5%">&nbsp;ลำดับ</td>
          <td class="col_name" width="10%">เลขที่ใบเอกสาร</td>
          <td class="col_name" width="10%">เเปลง</td>
          <td class="col_name" width="10%">บ้านเลขที่</td>
          <td class="col_name" width="15%">วันเวลาที่แจ้ง</td>
          <td class="col_name" width="20%">ชื่อลุกค้า</td>
          <td class="col_name" width="15%">เบอร์โทรติดต่อ</td>
          <td class="col_name" width="15%">วันนัดเข้าตรวจสอบ</td>
		</tr>
		<%
		 if(resultList!=null && resultList.size()> 0){
		 	  //List arrList = null;
		 	 StringBuffer ddTemp = new StringBuffer();
		 	 StringBuffer ttTemp = new StringBuffer();
		 	 StringBuffer temp = new StringBuffer();
		 	 List strList = null;
		     Iterator it = resultList.iterator();
		     int i = 1;
			 while(it.hasNext()){								
				 strList =(ArrayList)it.next();	
				 %>
				  <tr>
		          <td align="center" class="dotline" width="5%"><%=i++ %></td>
		          <td class="dotline" width="10%">
		          
		          <%
		             if(strList.get(12)!=null && !strList.get(12).toString().equals("") ){
		           %>
		          
		          <a href="javascript:doPopupPage('<%=strList.get(0) %>','<%=sel_project %>','<%=strList.get(3)%>','<%=strList.get(4)%>','<%=doString.DisplayThai(strList.get(6).toString())%>','<%=doString.DisplayThai(strList.get(7).toString())%>','<%=strList.get(10)%>');" >
		          <%=strList.get(0) %>   <i class="fa fa-check-circle-o green-icon" aria-hidden="true"></i> </a>
		          <%}else{ out.println(strList.get(0));} %>
		          </td>
		          <td class="dotline ; item" width="10%" align="center"><%=strList.get(3) %></td>
		          <td class="dotline ; item" width="10%" align="center"><%=strList.get(4) %></td>
		          <td class="dotline ; item" width="15%"><%
					//2012-07-13 12:00:00.0 		          		
		          	if(strList.get(5)!=null && !"".equals(strList.get(5))){
		          		ddTemp.delete(0,ddTemp.length());
		          		ttTemp.delete(0,ttTemp.length());
		          		temp.delete(0,temp.length());
		          		String [] str = strList.get(5).toString().split(" ");
		          		ddTemp.append(thaiDateFormate(str[0])); //2012-08-01
		          		String [] str2 = str[1].split("\\:");
		          		ttTemp.append(str2[0]+":"+str2[1]);
		          		//temp.append();
		          		out.println("&nbsp;"+ddTemp.toString()+" "+ttTemp.toString()+" น.");
		          	}else{
		          	   out.println("&nbsp;");
		          	}    
		          %></td>
				  <td align="left" class="dotline" width="20%"><%=doString.DisplayThai(strList.get(6).toString()) %></td>   
				  <td class="dotline ; item" width="15%"><%=doString.DisplayThai(strList.get(7).toString()) %></td>
				   <td class="dotline" align="left" width="15%" >
				    <div class="styled-text">&nbsp;

		          <% //2012-07-13 12:00:00.0 		          		
		          	if(strList.get(8)!=null && !"".equals(strList.get(8))){
		          		ddTemp.delete(0,ddTemp.length());
		          		ttTemp.delete(0,ttTemp.length());
		          		temp.delete(0,temp.length());
		          		String [] str = strList.get(8).toString().split(" ");
		          		ddTemp.append(thaiDateFormate(str[0])); //2012-08-01
		          		String [] str2 = str[1].split("\\:");
		          		ttTemp.append(str2[0]+":"+str2[1]);
		          		//temp.append();
		          		out.println(GetDayOfWeek[Integer.parseInt(strList.get(9).toString())]+"&nbsp;"+ddTemp.toString()+" "+ttTemp.toString()+" น.");
		          	}else{
		          	   out.println("&nbsp;");
		          	}
		          %> &nbsp;
		          </div>
		          </td>     
		         </tr>
				<%
			}				 	
		 }else{
		 %>
	        <tr><td class="dotline" colspan="8">&nbsp;</td></tr>
	        <tr><td class="dotline" colspan="8" align="center">&nbsp;ยังไม่มีข้อมูล</td></tr>
	        <tr><td class="dotline" colspan="8">&nbsp;</td>
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
            <!--  
            <a href="SERV_Appoint_Add.html"><img border="0" src="images/act_submit.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
             -->	&nbsp;</td>                	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:history.back()" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="SERV_Home_VP.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
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
