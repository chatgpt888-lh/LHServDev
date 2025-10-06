<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>

<%@ page import="java.util.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
 <!--  -->
<%@ include file="confirmLogin.jsp" %>


<%
	System.out.println("Welcome to List");
	Object objList = request.getAttribute("listData");
	List selectorList = null;
	
	if(objList != null) {
	selectorList = (List) objList;
	System.out.println("selectorList size = "+ selectorList.size());
	}%>
	


<!-- saved from url=(0054)http://132.146.1.126/LHServ/SERV_INFBOQ02.jsp -->
<HTML>
<HEAD>

<TITLE>รายละเอียด</TITLE>
<META content="text/html; charset=TIS-620" http-equiv=Content-Type>
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<SCRIPT language=javascript src="script_fx.js"></SCRIPT> 
<script type='text/javascript' src='jquery/jquery-1.11.3.min.js'></script>
<script type='text/javascript' src='jquery/loadImg.js'></script>
<SCRIPT language=javascript>







  function validateForm() {
    var iCOM_ID = document.forms["addform"]["iCOM_ID"].value;
    var izone = document.forms["addform"]["i_zone"].value;
    
    if((iCOM_ID == "" || iCOM_ID == null) &&(izone == "" || izone == null) ){
    	alert("โครงการเเละโซนไม่สามารถเว้นค่าว่างได้!");
    	$("#i_zone").focus();
	    $("#i_zone").select();
    	
    	return false;
    }
   
   
    if (iCOM_ID == "" || iCOM_ID == null) {
      alert("กรุณาเลือกโครงการ");
      return false;
    }
    if (izone == "" || izone == null) {
    alert("กรุณาเลือกโซน");
    return false;
    }
    else if ((iCOM_ID != null || iCOM_ID != "") && (izone != null || izone != "")) {
    addform.action = "<%=request.getContextPath()%>/SERV_LStaffServlet?cmd=addInfo"
    }
  }
  


</SCRIPT>
<!-- ajax show input / validated  -->
<script>



//check project



$(document).ready(function() { 
	
	
    $("#iCOM_ID").change(function() {
    

     if($('#iCOM_ID').val()!='' ){
      $.ajax({
        type : "POST" , 
        url: "SERV_LStaffServlet?cmd=chkProId",
        data: 'comId='+$('#iCOM_ID').val(),    
        success: function(data){     
	        var param = data.split(":");
	        //console.log(typeof (param));
	       // alert("data eq = "+param);
	        
	       // console.log(param);
		    if (param[0]=="N") {
		      	alert("มีข้อมูลโครงการนี้เเล้ว กรุณาเลือกใหม่อีกครั้ง");
		      	$('#iCOM_ID').prop('selectedIndex', 0);
		      	
		      	
	        }else{
	         	
	        }
         }
         
      });
     }
    }); 
});


//check zone
$(document).ready(function() { 
//cancel enterkey

$(document).on('keypress', 'input,select', function (e) {
    if (e.which == 13) {
        e.preventDefault();
        var $next = $('[tabIndex=' + (+this.tabIndex + 1) + ']');
        //console.log($next.length);
        if (!$next.length) {
       $next = $('[tabIndex=1]');        }
        $next.focus() .click();
    }
});

    $("#i_zone").blur(function() {
    
	
     if($('#i_zone').val()!='' ){
	if(isNaN(document.addform.i_zone.value))
	{
	alert('รหัส zone ต้องเป็นตัวเลขเท่านั้น!! กรุณากรอกใหม่อีกครั้ง');
	$('#i_zone').val("");
	$("#i_zone").focus();
	$("#i_zone").select();
	
	
	return false;
	}
	
	if(document.addform.i_zone.value.length != 2){
	alert('รหัส zone ต้องเป็นจำนวนสองตัวเลขเท่านั้น เช่น 01 , 12 , 90');
	$('#i_zone').val("");
	$("#i_zone").focus();
	$("#i_zone").select();
	
	return false;
	}
     } else {
  
    return true;
     }
    }); 
});


//check employ
$(document).ready(function() { 
    $("#i_employ_z").blur(function() {
	
     if($('#i_employ_z').val()!='' ){
	checkemploy( $('#i_employ_z')  , $("#z_name") );
     } else {
    $('#z_name').empty().append("&nbsp;");
     }
    }); 


    $("#i_employ_m1").blur(function() {

     if($('#i_employ_m1').val()!='' ){
	checkemploy( $('#i_employ_m1')  , $("#m1_name") );
     } else {
    $('#m1_name').empty().append("&nbsp;");
     }
    }); 



    $("#i_employ_m2").blur(function() {

     if($('#i_employ_m2').val()!='' ){
	checkemploy( $('#i_employ_m2')  , $("#m2_name") );
     }  else {
    $('#m2_name').empty().append("&nbsp;");
     }
    }); 



    $("#i_employ_s1").blur(function() {

     if($('#i_employ_s1').val()!='' ){
	checkemploy( $('#i_employ_s1')  , $("#s1_name") );
     } else {
    $('#s1_name').empty().append("&nbsp;");
     }
    }); 


    $("#i_employ_s2").blur(function() {

     if($('#i_employ_s2').val()!='' ){
	checkemploy( $('#i_employ_s2')  , $("#s2_name") );
     } else {
    $('#s2_name').empty().append("&nbsp;");
     }
    }); 



    $("#i_employ_app1").blur(function() {

     if($('#i_employ_app1').val()!='' ){
	checkemploy( $('#i_employ_app1')  , $("#app1_name") );
     }  else {
    $('#app1_name').empty().append("&nbsp;");
     }
    }); 


//check employ function
//$("#i_employ_z") -->  pattern data
function checkemploy(id,returnField) {
       $.ajax({
        type : "POST" , 
        url: "SERV_LStaffServlet?cmd=checkEmployId",
        data: 'employId='+ id.val() ,    
        success: function(data){     
	        var param = data.split(":");
	        //console.log(typeof (param));
	       // alert("data eq = "+param);
	        
	        //console.log(param);
		    if (param[0]=="invalid") 
		    {
		      alert("ไม่พบรหัสพนักงานที่ระบุ");
		      id.val("");
		      returnField.empty().append("&nbsp;");
		      id.focus();
		      id.select();
	        }else
	        {
	          returnField.text(param[0]);
	        }
         }
         
      });
}

//check vendor


    $("#i_vendor1").blur(function() {
    
    if($('#i_vendor1').val()==''  )  {
     	 $("#ven_name").text("");
     }

     if($('#i_vendor1').val()!=''){
            $.ajax({
        type : "POST" , 
        url: "SERV_LStaffServlet?cmd=checkVendorId",
        data: 'vendorId='+ $("#i_vendor1").val() ,    
        success: function(data){     
	        var param = data.split(":");
	       // console.log(typeof (param));
	       // alert("data eq = "+param);
	        
	      //console.log(param);
		    if (param[0]=="invalid") {
		      alert("ไม่พบรหัสที่ระบุ")
		      $('#i_vendor1').val("");
		      $("#i_vendor1").focus();
		      $("#i_vendor1").select();
		      $("#ven_name").empty().append("&nbsp;");
	        }else{
	          $("#ven_name").text(param[0]);
	        }
         }
         
      });
     }
    }); 
});
     
     
     


</script>






<BODY leftMargin=0 topMargin=0 marginwidth="0" marginheight="0">

<FORM  name="addform" method="POST">

<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
  <TBODY>
  

  <TR>
    <TD class=BD width="100%">
      <TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
        <TBODY>
        <TR>
          <TD class=bigh width="100%"><IMG border=0 
            src="images/i_home.gif" width=20 align=absMiddle 
            height=20>&nbsp; ข้อมูลพื้นฐาน</TD></TR></TBODY></TABLE><BR 
      style="FONT-SIZE: 10pt">
      <TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
        <TBODY>
        <TR>
     
        
       <TD class=item_tab1><IMG border=0 src="images/i_i.gif" 
            width=20 align=absMiddle height=20></TD>
          <TD class=item_tab2 width=200>ข้อมูลโครงการ</TD>
          <TD class=item_tab3></TD>
          
          
          
          <TD  height=20 width="35%">&nbsp;&nbsp;
          <SELECT  class=box  style="WIDTH: 200px" size=1 name="iCOM_ID" id="iCOM_ID" />
          <OPTION selected value="">------ กรุณาเลือก ------</OPTION>
                    
                   <%
                  if(selectorList!=null && selectorList.size()>0){
                  	 HashMap hashmap = null;
                  for (Iterator iter = selectorList.iterator(); iter.hasNext(); ){
						 hashmap = (HashMap) iter.next(); %>
						 
           <OPTION value=<%= hashmap.get("iCOM_ID").toString()%>-<%=hashmap.get("iPROJ_ID").toString()%>><%= hashmap.get("iCOM_ID").toString()%>-<%=hashmap.get("iPROJ_ID").toString()%> <%=hashmap.get("nPROJ").toString() %></OPTION>
                   
                   <%
                   
                  }
                     }  else {
      System.out.println("no data"); }
       
       %> 
         </SELECT> 
        <!-- search -->
                    
      &nbsp;&nbsp;&nbsp;&nbsp; 
      
      <!-- <input type="image" src="images/bu_go.gif" style="CURSOR: hand" border="0" alt="Submit" width=40 
      align=absMiddle height=22 />  
     <span style="color: red;" id = "projectCheck"> ${error} </span> -->
      </TD>
   		
         <TD>
         
          &nbsp;
             &nbsp;&nbsp;&nbsp;&nbsp; 
      
     
   
          </TD>
          </TR>
          </TBODY>
          </TABLE>
           
      <TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
        <TBODY>
        <TR>
          <TD vAlign=top width=5><IMG border=0 
            src="images/Corn01.gif" width=5 height=5></TD>
          <TD class=frmTop>&nbsp;</TD>
          <TD vAlign=top width=5 align=right><IMG border=0 
            src="images/Corn02.gif" width=5 
      height=5></TD></TR></TBODY></TABLE>
      
      
      <TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
        <TBODY>
        <TR>
          <TD class=frmLR width="100%" align=center>
            <TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
              <TBODY>
                <TR>
                <TD class="item ; dotline01" height=22  width="15%">กลุ่ม Zone :</TD>
                <TD class=dotline01 height=22 width="15%">
                    <INPUT class="boxC"  style="WIDTH: 100px" name="i_zone" id ="i_zone" maxlength="2" tabIndex="1"/>
                </TD>
                <TD class=dotline01 height=22  width="70%">&nbsp;</TD>
                </TR>
                
            	<TR>
                <TD class="item ; dotline01" >รหัสพนักงาน Zone :</TD>
                <TD class=dotline01 >
                    <INPUT class=boxC style="WIDTH: 100px" name="i_employ_z" id="i_employ_z" maxlength="6" tabIndex="2" ></TD>
                <TD class=dotline01 id="z_name"  > &nbsp;</TD>
                  
                </TR>
                
            	<TR>
                <TD class="item ; dotline01">รหัสพนักงาน Manager 1 :</TD>
                <TD class=dotline01>
                    <INPUT class=boxC style="WIDTH: 100px" name="i_employ_m1" id="i_employ_m1" maxlength="6" tabIndex="3"></TD>
                <TD class=dotline01 id="m1_name" > &nbsp;</TD>
                </TR>                
  
            	<TR>
                <TD class="item ; dotline01">รหัสพนักงาน Manager 2 :</TD>
                <TD class=dotline01 >
                    <INPUT class=boxC style="WIDTH: 100px" name="i_employ_m2"  id="i_employ_m2" maxlength="6" tabIndex="4"></TD>
                <TD class=dotline01 id="m2_name" > &nbsp;</TD>
                </TR>
                  
            	<TR>
                <TD class="item ; dotline01">รหัสพนักงาน Staff 1 :</TD>
                <TD class=dotline01 >
                    <INPUT class=boxC style="WIDTH: 100px" name="i_employ_s1" id="i_employ_s1"  maxlength="6" tabIndex="5"></TD>
                <TD class=dotline01 id="s1_name" > &nbsp;</TD>
                </TR>
                       
            	<TR>
                <TD class="item ; dotline01" >รหัสพนักงาน Staff 2 :</TD>
                <TD class=dotline01 >
                    <INPUT class=boxC style="WIDTH: 100px" name="i_employ_s2"  id="i_employ_s2" maxlength="6" tabIndex="6"></TD>
                <TD class=dotline01 id="s2_name"  > &nbsp;</TD>
                </TR>
                  
                <TR>
                <TD class="item ; dotline01">Flag Turn Key :</TD>
                <TD class=dotline01 >
                    <INPUT type=radio value="Y" name="f_tk" id="f_tk"> Y 
                <INPUT type=radio value="N"  name="f_tk" id="f_tk" checked tabIndex="7"> N </TD>
                <TD class=dotline01>&nbsp;</TD>
                </TR>
          
                <TR>
                <TD class="item ; dotline01" >ผู้อนุมัติ Turn Key 1 :</TD>
                <TD class=dotline01 >
                    <INPUT class=boxC style="WIDTH: 100px" name="i_employ_app1" id="i_employ_app1"  maxlength="6" tabIndex="8"></TD>
                <TD class=dotline01 id="app1_name" > &nbsp;</TD>
                </TR>
                  
                <TR>
                <TD class="item ; dotline01">ผู้รับเหมาซ่อม :</TD>
                <TD class=dotline01 >
                    <INPUT class=boxC style="WIDTH: 100px" name="i_vendor1"  id="i_vendor1" maxlength="6" value="" tabIndex="9"></TD>
                <TD class=dotline01 id="ven_name" > &nbsp;</TD>
                </TR>
          

                <TR>
                <TD class="item ; dotline01" >&nbsp;</TD>
                <TD class=dotline01 >&nbsp;</TD>
                <TD class="item ; dotline01">&nbsp;</TD>
                <TD class=dotline01 >&nbsp;</TD>
                </TR>
                
                <TR>
                <TD class="item ; dotline01" >&nbsp;</TD>
                <TD class=dotline01 >&nbsp;</TD>
                <TD class="item ; dotline01">&nbsp;</TD>
                <TD class=dotline01 >&nbsp;</TD>
                </TR>
                
                <TR>
                <TD class="item ; dotline01" >&nbsp;</TD>
                <TD class=dotline01 >&nbsp;</TD>
                <TD class="item ; dotline01">&nbsp;</TD>
                <TD class=dotline01 >&nbsp;</TD>
                </TR>
                </TBODY>
                </TABLE>
                </TD>
                </TR>
                </TBODY>
                </TABLE>
            
		<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
        <TBODY>
        <TR>
          <TD vAlign=bottom width=5>
          <IMG border=0 src="images/Corn03.gif" width=5 height=5></TD>
          <TD class=frmBottom>&nbsp;</TD>
          <TD vAlign=bottom width=5 align=right>
          <IMG border=0 src="images/Corn04.gif" width=5  height=5></TD>
          </TR>
          </TBODY>
          </TABLE>
          <BR style="FONT-SIZE: 10pt">
      <TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
      </TABLE>
      <BR style="FONT-SIZE: 10pt">
      <TABLE height=30 cellSpacing=0 cellPadding=0 width="100%" border=0>
        <TBODY>
        <TR>
          <TD class=act_tab1></TD>
   
       <!-- add -->
          <TD class=act_tab2 width=150><input type="image" id="submit" IMG 
            onmouseover=nereidFade(this,100,50,5) 
            onmouseout=nereidFade(this,70,50,5) 
            style="FILTER: alpha(opacity=70)" border=0 
            src="images/act_save.gif" 
            width=70 height=27  onClick="return validateForm();">
            &nbsp; &nbsp;  
          </TD> 
        
        <!-- back -->
          <TD class=act_tab3></TD>
          <TD class=act_tab4>
          <A onclick="return confirm('หากออกจากหน้านี้ข้อมูลจะไม่ได้ถูกเพิ่มลงในระบบ ยืนยันที่จะออกหรือไม่?')"
             href="SERV_LStaffServlet?cmd=makeList" target=_top><IMG 
             border=0 
             src="images/bu_back.gif" 
             width=50 align=absMiddle height=15></A>&nbsp; <A 
             href="<%=request.getContextPath()%>/SERV_Index.jsp" target=_top><IMG 
             border=0 
             src="images/bu_home.gif" 
             width=50 align=absMiddle  height=15>
          </A>
          </TD>
          </TR>
          </TBODY>
          </TABLE>
          </TBODY>
          </TABLE>
          <BR style="FONT-SIZE: 30pt">

<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
  <TBODY>
  <TR>
    <TD class=copyright width="100%" align=center>
    Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5 
    <BR>ติดต่อสอบถามได้ที่ : 
    <A href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</A>
    &nbsp; หรือ    โทร. 0-2230-8279 (คุณประพัฒน์ ฝ่ายบริการ)&nbsp; 0-2230-8491-5 (ฝ่าย IT) 
    <BR>
    <IMG src="images/copyright.gif" width=475 height=26>
    </TD>
    </TR>
    </TBODY>
    </TABLE>
    <INPUT type=hidden value=0001 name=i_seq> 
</FORM>
</BODY>
</HTML>