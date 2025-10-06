<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ include file="confirmLogin.jsp" %>


<%
	System.out.println("Welcome to update.jsp");
	Object objList = request.getAttribute("hashLstaff");
	HashMap editData = null;
	
	if(objList != null) {
	editData = (HashMap) objList;

	
	}%>
	



<HTML>
<HEAD>

<TITLE>รายละเอียด</TITLE>
<META content="text/html; charset=TIS-620" http-equiv=Content-Type>
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<SCRIPT language=javascript src="script_fx.js"></SCRIPT> 
<script type='text/javascript' src='jquery/jquery-1.11.3.min.js'></script>
<script type='text/javascript' src='jquery/loadImg.js'></script>
<SCRIPT language=javascript>

$(document).on('keypress', 'input,select', function (e) {
    if (e.which == 13) {
        e.preventDefault();
        var $next = $('[tabIndex=' + (+this.tabIndex + 1) + ']');
        //console.log($next.length);
        if (!$next.length) {
       $next = $('[tabIndex=1]');        }
    
       $next.focus();
       
        
        
    }
});


  
function validateForm() {
   
    
   
    if ($('#i_zone').val() == "" || $('#i_zone').val() == null) {
    alert("กรุณาเลือกโซน");
    $("#i_zone").focus();
	$("#i_zone").select();
    return false;
    }
    else if ($('#i_zone').val() != null || $('#i_zone').val() != "") {
    updateForm.action = "<%=request.getContextPath()%>/SERV_LStaffServlet?cmd=updateInfo"
    }
  }
</SCRIPT>
<!-- ajax show input / validated  -->
<script>
//check zone
$(document).ready(function() { 
    $("#i_zone").blur(function() {
	
	
	
    if($('#i_zone').val()!='' ){
	if(isNaN(document.updateForm.i_zone.value))
	{
	alert('รหัส zone ต้องเป็นตัวเลขเท่านั้น!! กรุณากรอกใหม่อีกครั้ง');
	$('#i_zone').val("");
	$("#i_zone").focus();
	$("#i_zone").select();
	return false;
	}
	if(document.updateForm.i_zone.value.length != 2){
		alert('รหัส zone ต้องเป็นจำนวนสองตัวเลขเท่านั้น เช่น 01 , 12 , 90');
		$('#i_zone').val("");
	    $("#i_zone").focus();
	    $("#i_zone").select();
		
		
		return false;
	}
     } else {
   
     }
    }); 


//check employ
 
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
		    if (param[0]=="invalid") {
		      alert("ไม่พบรหัสพนักงานที่ระบุ");
		      id.val("");
		      returnField.empty().append("&nbsp;");
		      id.focus();
		      id.select();
		      }else{
	          returnField.text(param[0]);
	        }
         }
         
      });
}

//check vendor


    $("#i_vendor1").blur(function() {
    
    if($('#i_vendor1').val()==''  )  {
     	$('#ven_name').empty().append("&nbsp;");
     }

     if($('#i_vendor1').val()!=''){
            $.ajax({
        type : "POST" , 
        url: "SERV_LStaffServlet?cmd=checkVendorId",
        data: 'vendorId='+ $("#i_vendor1").val() ,    
        success: function(data){     
	        var param = data.split(":");
	        //console.log(typeof (param));
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

// check validated form





</script>






<BODY leftMargin=0 topMargin=0 marginwidth="0" marginheight="0">

<FORM  method="POST" action = "SERV_LStaffServlet?cmd=updateInfo" name="updateForm">


<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
  <TBODY>
  

  <TR>
    <TD class=BD width="100%">
      <TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
        <TBODY>
        <TR>
          <TD class=bigh width="100%">
          <IMG border=0 src="images/i_home.gif" width=20 align=absMiddle  height=20>&nbsp; ข้อมูลพื้นฐาน
          </TD>
          </TR>
          </TBODY>
          </TABLE>
          <BR style="FONT-SIZE: 10pt">
      <TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
        <TBODY>
        <TR>
          <TD class=item_tab1><IMG border=0 src="images/i_i.gif" width=20 align=absMiddle height=20></TD>
          <TD class=item_tab2 width=200>ข้อมูลโครงการ</TD>
          <TD class=item_tab3></TD>
        
                    
                   <%
                  if(editData !=null){
                 %>
					  <TD  height=20 width="35%">
					  &nbsp;&nbsp;
	  <SELECT class=box style="WIDTH: 200px" size=1 name="iCOM_ID" id="iCOM_ID">
	  <OPTION selected value=<%=editData.get("iCOM_IDe").toString() %>-<%=editData.get("iPROJ_IDe").toString() %> >
	  <%=editData.get("iCOM_IDe").toString() %>-<%=editData.get("iPROJ_IDe").toString() %> <%=editData.get("nPROJe").toString() %>
	  </OPTION>
      </SELECT> 
          <TD>
         
          &nbsp;
             &nbsp;&nbsp;&nbsp;&nbsp; 
      
     
   
          </TD></TR></TBODY></TABLE>
           
      <TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
        <TBODY>
        <TR>
          <TD vAlign=top width=5><IMG border=0 src="images/Corn01.gif" width=5 height=5></TD>
          <TD class=frmTop>&nbsp;</TD>
          <TD vAlign=top width=5 align=right><IMG border=0 src="images/Corn02.gif" width=5 height=5></TD>
        </TR>
        </TBODY>
        </TABLE>
      
      
      <TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
        <TBODY>
        <TR>
          <TD class=frmLR width="100%" align=center>
            <TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
              <TBODY>
              <TR>
                <TD class="item ; dotline01" height=22 width="15%">กลุ่ม Zone :</TD>
                <TD class=dotline01 height=22 width="15%">
                <INPUT  class=boxC  style="WIDTH: 100px" name="i_zone" id ="i_zone" maxlength="2"  tabIndex="1"  value = <%=editData.get("zones").toString() %> ></TD>
                <TD class=dotline01 height=22 width="70%">&nbsp;</TD>
                </TR>
                
            	<TR>
                <TD class="item ; dotline01" >รหัสพนักงาน Zone :</TD>
                <TD class=dotline01 >
                <INPUT class=boxC style="WIDTH: 100px" name="i_employ_z" id="i_employ_z"  maxlength="6"  tabIndex="2" value = <%=editData.get("iEmploys").toString() %> ></TD>
                <TD class=dotline01 id="z_name" ><%=editData.get("iEmployName").toString() %>&nbsp; &nbsp;</TD>
                </TR>
                
            	<TR>
                <TD class="item ; dotline01">รหัสพนักงาน Manager 1 :</TD>
                <TD class=dotline01>
                <INPUT class=boxC style="WIDTH: 100px" name="i_employ_m1" id="i_employ_m1" maxlength="6" tabIndex="3" value = <%=editData.get("iEmployM1").toString() %> ></TD>
                <TD class=dotline01 id="m1_name" ><%=editData.get("iEmployM1Name").toString() %>&nbsp;</TD>
                </TR>                
  
            	<TR>
                <TD class="item ; dotline01">รหัสพนักงาน Manager 2 :</TD>
                <TD class=dotline01 >
                <INPUT class=boxC style="WIDTH: 100px" name="i_employ_m2" id="i_employ_m2"  maxlength="6"  tabIndex="4" value = <%=editData.get("iEmployM2").toString() %> ></TD>
                <TD class=dotline01 id="m2_name"><%=editData.get("iEmployM2Name").toString() %>&nbsp;</TD>
                </TR>
                  
            	<TR>
                <TD class="item ; dotline01">รหัสพนักงาน Staff 1 :</TD>
                <TD class=dotline01 >
                <INPUT class=boxC style="WIDTH: 100px" name="i_employ_s1" id="i_employ_s1"  maxlength="6" tabIndex="5" value = <%=editData.get("iEmployS1").toString() %>  ></TD>
                <TD class=dotline01 id="s1_name"><%=editData.get("iEmployS1Name").toString() %>&nbsp;</TD>
                </TR>
                       
            	<TR>
                <TD class="item ; dotline01" >รหัสพนักงาน Staff 2 :</TD>
                <TD class=dotline01 >
                <INPUT class=boxC style="WIDTH: 100px" name="i_employ_s2" id="i_employ_s2"  maxlength="6"  tabIndex="6" value = <%=editData.get("iEmployS2").toString() %>  ></TD>
                <TD class=dotline01 id="s2_name"><%=editData.get("iEmployS2Name").toString() %>&nbsp; </TD>
                </TR>
                  
                <TR>
                <TD class="item ; dotline01">Flag Turn Key :</TD>
                
         <% String checkY = "";
            String checkN = "";
         
            if (editData.get("ftk").toString().equals("Y") ){ 
            checkY = " checked ";
            }
            if(editData.get("ftk").toString().equals("N") ) {
            checkN = " checked ";
            }
         %>
                <TD class=dotline01 >
                <INPUT type=radio value="Y" name="f_tk" <%=checkY %> > Y 
                <INPUT type=radio value="N" name="f_tk" <%=checkN %>> N 
                </TD>
                <TD class=dotline01 id="f_tk"> &nbsp; </TD>
                </TR>
         
                <TR>
                <TD class="item ; dotline01" >ผู้อนุมัติ Turn Key 1 :</TD>
                <TD class=dotline01 >
                <INPUT class=boxC style="WIDTH: 100px" name="i_employ_app1"  id="i_employ_app1" maxlength="6" tabIndex="7" value = <%=editData.get("iEmployApp1").toString() %>></TD>
                <TD class=dotline01 id="app1_name" ><%=editData.get("iEmployApp1Name").toString() %> &nbsp;</TD>
                </TR>
                  
                <TR>
                <TD class="item ; dotline01">ผู้รับเหมาซ่อม :</TD>
                <TD class=dotline01 >
                <INPUT class=boxC style="WIDTH: 100px" name="i_vendor1"  id="i_vendor1" maxlength="6" tabIndex="8" value =<%=editData.get("iVen1").toString() %> ></TD>
                <TD class=dotline01 id="ven_name"><%=editData.get("iVenName").toString() %> &nbsp;</TD>
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
            
            
               <% } %>
                    
		<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
        <TBODY>
        <TR>
          <TD vAlign=bottom width=5>
          <IMG border=0 src="images/Corn03.gif" width=5 height=5></TD>
          <TD class=frmBottom>&nbsp;</TD>
          <TD vAlign=bottom width=5 align=right>
          <IMG border=0 src="images/Corn04.gif" width=5 height=5></TD>
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
       
   
          <TD class=act_tab2 width=150>
          <input type="image"  alt="Submit" IMG onmouseover=nereidFade(this,100,50,5) 
            onmouseout=nereidFade(this,70,50,5) 
            style="FILTER: alpha(opacity=70)" border=0 
            src="images/act_save.gif" 
            width=70 height=27 onClick="return validateForm();">
          </TD> 
     
          <TD class=act_tab3></TD>
          <TD class=act_tab4>
          <A onclick="return confirm('หากออกจากหน้านี้ข้อมูลจะไม่ได้ถูกเพิ่มลงในระบบ ยืนยันที่จะออกหรือไม่?')"
             href="SERV_LStaffServlet?cmd=makeList" target=_top><IMG 
             border=0 
             src="images/bu_back.gif" 
             width=50 align=absMiddle height=15></A>
             &nbsp; 
             <A href="<%=request.getContextPath()%>/SERV_Index.jsp" target=_top><IMG 
             border=0 
             src="images/bu_home.gif" 
             width=50 align=absMiddle height=15></A>
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
        <TD class=copyright width="100%" align=center>Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5 
        <BR>ติดต่อสอบถามได้ที่ : 
        <A  href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</A>
        &nbsp; หรือ   โทร. 0-2230-8279 (คุณประพัฒน์ ฝ่ายบริการ)&nbsp; 0-2230-8491-5 (ฝ่าย IT) 
       <BR>
       <IMG src="images/copyright.gif" width=475 height=26>
       </TD>
       </TR>
       </TBODY>
       </TABLE>
       <INPUT type=hidden value=0001 name=i_seq> 
</FORM></BODY></HTML>