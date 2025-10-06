<%@page language="java" contentType="text/html; charset=TIS-620"
	pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="java.util.Date" %>
<%@page import="java.text.*" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%-- 
/**********************************************/
 * create by : pradoem wonkraso
 * date time: 2012.06.29
 * Last modify :2014.11.19
 * version :1.0
 * project Name : E-Service
 * description : this is page for display && Master Data Appiont date form
***************************************************/
--%>
<%!
     //input type : string 2012-07-30
     //out put is : true or false
     public static boolean isComparedToDay (String yyyyMMdd){
         try{
             Date date = Calendar.getInstance().getTime();
    		  	 // Display a date in day, month, year format//dd/MM/yyyy
    		DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
    		String today = formatter.format(date);
          	Date varunteeDate = formatter.parse(yyyyMMdd);
          	Date currentDate  = formatter.parse(today);          	
          	if(currentDate.after(varunteeDate)){
          	     return true; // before current date
          	}else{
          	     return false; // after current date
          	}
          }catch(ParseException ex){
 	    	ex.printStackTrace();
 	    	return true;// 
 	    }
    }
    
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

	private static String GetDateDDMMYY(String temp){
		if(!temp.equals("")){			
			String [] aa = temp.split("\\ ");
			//System.out.println(" 1:"+aa[0]);
			//System.out.println(" 2:"+aa[1]);		
			return aa[0];
		}else{
			return temp;
		}
	}	
	private static String GetDateTimeFormat(String temp){
		if(!temp.equals("")){			
			String [] aa = temp.split("\\ ");		
			return aa[1];
		}else{
			return temp;
		}
	}	
	private static String GenNextId2(int b){
        String temp=""+b;
        String newSp_id;
        switch(temp.length()){ 
           case 1: newSp_id="0"+temp; break;
           default:newSp_id=temp;
        }
        return newSp_id;
   }  
   //DayList method
	private static ArrayList getDayList(){
		ArrayList dayList = new ArrayList();
		dayList.add(0,"");
		for(int i=1;i<32;i++){
			dayList.add(i,GenNextId2(i));
		}
		return dayList;
	}
	
	//Month List method
	private static ArrayList getMonthList(){
		ArrayList mmList = new ArrayList();
		int i = 1;
		mmList.add(0,"");
		mmList.add(i++,"มกราคม");
		mmList.add(i++,"กุมภาพันธ์");
		mmList.add(i++,"มีนาคม");
		mmList.add(i++,"เมษายน");
		mmList.add(i++,"พฤษภาคม");
		mmList.add(i++,"มิถุนายน");
		mmList.add(i++,"กรกฎาคม");
		mmList.add(i++,"สิงหาคม");
		mmList.add(i++,"กันยายน");
		mmList.add(i++,"ตุลาคม");
		mmList.add(i++,"พฤศจิกายน");
		mmList.add(i++,"ธันวาคม");		
		return mmList;
	}
	//For Year   current year-3 && year+4 
	//thai year formate ex.2555,2556
	private static ArrayList getYearList(int countYY){
		ArrayList yyList = new ArrayList();		
		for(int c=0;c<8;c++){
			yyList.add(c,""+countYY++);
		}			
		return yyList;
	}
 %>
<%
//*****************************************
	SimpleDateFormat th_formatter = new SimpleDateFormat("yyyy-MM-dd", new Locale("th","TH"));
	SimpleDateFormat en_formatter = new SimpleDateFormat("yyyy-MM-dd", new Locale("en","US"));	
	java.util.Date curDate = new java.util.Date();
	java.util.Date toDate = new java.util.Date();		
	String currentDay[] = en_formatter.format(curDate).split("\\-"); //yyyy-MM-dd	
	toDate.setMonth(curDate.getMonth()+3); //3 +current month
	String next3Month[] = en_formatter.format(toDate).split("\\-"); //yyyy-MM-dd		
	toDate.setYear(curDate.getYear()-3);  //current year-3  list year	
	String []tempYY = th_formatter.format(toDate).split("\\-");
	int countYY = Integer.parseInt(tempYY[0]); //thai current year
	ArrayList dayList =  getDayList();
	ArrayList mmList = getMonthList();
	ArrayList yyList = getYearList(countYY);
	int x = 0;
    x = 0;
 //*************************************************
	ArrayList projectDDL = (ArrayList)session.getAttribute("projDDL");
	ArrayList resultList = (ArrayList)request.getAttribute("resultList");
	String sel_project	= request.getAttribute("selProj")==null?"": request.getAttribute("selProj").toString();
	String fromDate = request.getAttribute("fromDate")==null?"": request.getAttribute("fromDate").toString();
	String t2Date = request.getAttribute("toDate")==null?"": request.getAttribute("toDate").toString();
    //**step 2 from attribute value from date && to date
    if(!fromDate.equals("")){
    	currentDay = fromDate.split("\\-"); //yyyy-MM-dd	
    }
    if(!t2Date.equals("")){
    	next3Month = t2Date.split("\\-"); //yyyy-MM-dd	
    }
 %>
<HTML>
<HEAD>
<TITLE>(LINE)ยกเลิกวันนัดเข้าตรวจสอบรายการซ่อม</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<style type="text/css">
 .box2 {  font-family: Tohama,Arial,sans-serif; font-size:10.1pt; font-weight:normal;
		padding-top: 1px; padding-right: 1px; padding-bottom: 1px; padding-left: 1px; 
	 	color:#165396; background-color: white; border: 1px #BEDCFF solid ; 
}
td.dotlineWhite{
	 color: rgb(255,255,255) ;	
	 border-bottom:1px dotted rgb(220,220,220)	;
	 border-right:1px solid rgb(135,185,247) ; 
	 padding:3px ; mso-number-format:"\@";  }
</style>
<script language="javascript" src="script_fx.js"></script>
<script type="text/javascript" src="eserv_paging.js"></script>
<script>
function initForm(){
      var e = document.getElementById('page');
      //e.style.display == 'block'
      e.style.visibility = 'hidden';
 }
function doGo(){
   if(validDate()){
       doSubmit();
   }
}
function doSubmit(){
    if(document.forms[0].projectDDL.value ==''){
		alert("กรุณาเลือกโครงการด้วย");
		document.forms[0].projectDDL.focus();
        return;
	}else{   
		 document.forms[0].action="<%=request.getContextPath()%>/LSERV_MngAppointDateServlet?cmd=search";
		 document.forms[0].submit();
	 }
}
function doDelete(){
		if(document.forms[0].projectDDL.value ==''){
			alert("กรุณาเลือกโครงการด้วย");
			document.forms[0].projectDDL.focus();
	        return;
		}else if(validateCheckBox()==false){
	     	alert("กรุณาเลือกรายการที่ต้องการลบด้วย");
	     	return;
	     } else{  
	     	 if(confirm("คุณต้องการลบรายการกำหนดเวลาเข้าตรวจสอบใช่หรือไม่?")==true){
		     //validate from client side
			 document.forms[0].action="<%=request.getContextPath()%>/LSERV_MngAppointDateServlet?cmd=delete";
			 document.forms[0].submit();
			 }
		 }
}
//validate checkbox
  function validateCheckBox(){
		var chks = document.getElementsByName('chkDel');
		var checkCount = 0;
		for (var i = 0; i < chks.length; i++){
			if (chks[i].checked){
			checkCount++;
			}
		}
		if (checkCount < 1){
			//alert("Please select at least four.");
			return false;
		}
		return true;
   }

//create by pradoem 
//click check all uncheck all
function checkAllBox(obj){
  var theForm = obj.form;
  var i;
  if(obj.checked){
   for(i=1;i<theForm.length; i++){
     theForm[i].checked = true;
   }
  }else if(!obj.checked){
   for(i=1;i<theForm.length; i++){
     theForm[i].checked = false;
   }
  }
}

  function validDate() {
     var sdate = document.forms[0].dayDDL1.value;
     var smonth = document.forms[0].mmDDL1.value;
     var syear = document.forms[0].yyDDL1.value;
     var edate = document.forms[0].dayDDL2.value;
     var emonth = document.forms[0].mmDDL2.value;
     var eyear = document.forms[0].yyDDL2.value;
     //---- Check select date ---//
     if (sdate.length==0 && smonth.length==0 && syear.length==0 &&
         edate.length==0 && emonth.length==0 && eyear.length==0) {
         return true;
     }
     var startDate = new Date(parseInt(syear,10),parseInt(smonth,10)-1,parseInt(sdate,10));
     var endDate = new Date(parseInt(eyear,10),parseInt(emonth,10)-1,parseInt(edate,10));
     if (startDate.getMonth()!=(parseInt(smonth,10)-1)) {
        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].dayDDL1.focus();
        return false;
     }
     if (endDate.getMonth()!=(parseInt(emonth,10)-1)) {
        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].dayDDL2.focus();
        return false;
     }
	if (startDate>endDate) {
	    alert(" วันที่สิ้นสุดต้องไม่น้อยกว่าวันที่เริ่มต้น ! ");
	    return false;
	}
     return true;
  }
  
  function popupSvcHistory(tel,projectId,houseId,lock){
		MM_openBrWindow('http://132.146.1.118/CALLService/SVCHistoryController.do?cmd=formLoad&tel='+tel+'&agentId=pradoem&projectDDL='+projectId+'&houseNoTxt='+houseId+'&lockTxt='+lock,
		'ServiceCenterHistory','status=yes,scrollbars=yes,resizable=yes,width=1400,height=680');
 }
</script>
<style type="text/css">    
            .pg-normal {
                font-size:14px;
                color: #20a6f4;
                font-weight: normal;
                text-decoration: none;    
                cursor: pointer;    
            }
            .pg-selected {
               font-size:1.875em;
                color: #fe8002;
                font-weight: bold;        
                text-decoration: underline;
                cursor: pointer;
            }
            
 </style>
 <style type="text/css">
	A:link {text-decoration: none}
	A:visited {text-decoration: none}
	A:active {text-decoration: none}
	A:hover {text-decoration: underline; color: red;}
</style>



  <link rel="stylesheet" href="jquery/jquery-ui.css">
  <script src="jquery/jquery-1.11.3.min.js"></script>
  <script src="jquery/jquery-ui.min.js"></script>
  
 <style>
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
  (function( $ ) {
    $.widget( "custom.combobox", {
      _create: function() {
        this.wrapper = $( "<span>" )
          .addClass( "custom-combobox" )
          .insertAfter( this.element );
 
        this.element.hide();
        this._createAutocomplete();
        this._createShowAllButton();
      },
 
      _createAutocomplete: function() {
        var selected = this.element.children( ":selected" ),
          value = selected.val() ? selected.text() : "";
 
        this.input = $( "<input>" )
          .appendTo( this.wrapper )
          .val( value )
          .attr( "title", "" )
          .addClass( "custom-combobox-input ui-widget ui-widget-content ui-state-default ui-corner-left" )
          .autocomplete({
            delay: 0,
            minLength: 0,
            source: $.proxy( this, "_source" )
          })
          .tooltip({
            tooltipClass: "ui-state-highlight"
          });
 
        this._on( this.input, {
          autocompleteselect: function( event, ui ) {
            ui.item.option.selected = true;
            this._trigger( "select", event, {
              item: ui.item.option
            });
          },
 
          autocompletechange: "_removeIfInvalid"
        });
      },
 
      _createShowAllButton: function() {
        var input = this.input,
          wasOpen = false;
 
        $( "<a>" )
          .attr( "tabIndex", -1 )
          .attr( "title", "Show All Items" )
          .tooltip()
          .appendTo( this.wrapper )
          .button({
            icons: {
              primary: "ui-icon-triangle-1-s"
            },
            text: false
          })
          .removeClass( "ui-corner-all" )
          .addClass( "custom-combobox-toggle ui-corner-right" )
          .mousedown(function() {
            wasOpen = input.autocomplete( "widget" ).is( ":visible" );
          })
          .click(function() {
            input.focus();
 
            // Close if already visible
            if ( wasOpen ) {
              return;
            }
 
            // Pass empty string as value to search for, displaying all results
            input.autocomplete( "search", "" );
          });
      },
 
      _source: function( request, response ) {
        var matcher = new RegExp( $.ui.autocomplete.escapeRegex(request.term), "i" );
        response( this.element.children( "option" ).map(function() {
          var text = $( this ).text();
          if ( this.value && ( !request.term || matcher.test(text) ) )
            return {
              label: text,
              value: text,
              option: this
            };
        }) );
      },
 
      _removeIfInvalid: function( event, ui ) {
 
        // Selected an item, nothing to do
        if ( ui.item ) {
          return;
        }
 
        // Search for a match (case-insensitive)
        var value = this.input.val(),
          valueLowerCase = value.toLowerCase(),
          valid = false;
        this.element.children( "option" ).each(function() {
          if ( $( this ).text().toLowerCase() === valueLowerCase ) {
            this.selected = valid = true;
            return false;
          }
        });
 
        // Found a match, nothing to do
        if ( valid ) {
          return;
        }
 
        // Remove invalid value
        this.input
          .val( "" )
          .attr( "title", value + " didn't match any item" )
          .tooltip( "open" );
        this.element.val( "" );
        this._delay(function() {
          this.input.tooltip( "close" ).attr( "title", "" );
        }, 2500 );
        this.input.autocomplete( "instance" ).term = "";
      },
 
      _destroy: function() {
        this.wrapper.remove();
        this.element.show();
      }
    });
  })( jQuery );
 
  $(function() {
    $( "#combobox" ).combobox();
    $( "#toggle" ).click(function() {
      $( "#combobox" ).toggle();
    });
  });
  </script>
  
  
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="initForm()">
<form action="" name="frm" method="POST">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">
          &nbsp;ข้อมูลพื้นฐาน</td>
        </tr>
      </table>
<br style="font-size:10pt">              
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">ยกเลิกวันนัดเข้าตรวจสอบรายการซ่อม(LINE)</td>
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
    <td class="item ; dotline01" height="22" width="12%">โครงการ :</td>
    <td height="22" width="88%" class="dotline01">
	<select name="projectDDL"  id="combobox" style="width:350px; height:24px"> 
			<option value="">------ กรุณาเลือกโครงการ ------</option>
   				<%
					List  arrList = null;
					if(projectDDL!=null && projectDDL.size()>0){
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
								<option value="<%=strValue%>"  <%=select %>><%=arrList.get(0)%> - <%=doString.checkString(doString.DisplayThai(arrList.get(1).toString())) %></option>
							<%}
					} %>	 
   				</select> 	
    </td>
    </tr>
   <tr>
    <td class="item ; dotline01" height="22">วันเดือนปี :</td>
    <td height="22" class="dotline01 ; item">	
	<select size="1" class="box2" style="width:90px" name="dayDDL1" >
	<option value=''>---วัน---</option>
	<%
		String selected = "";
		for(int i = 1;i<dayList.size();i++){
			if(currentDay[2].equals(dayList.get(i))){
				selected = "selected";
			}else{
				selected = "";
			}%>
				<option value="<%=dayList.get(i) %>"   <%=selected %>>&nbsp;<%=dayList.get(i)%></option>
			<%}%>       
     </select>
	 &nbsp;&nbsp;
	 	<select size="1" class="box2" style="width:100px" name="mmDDL1" >
	 	 <option value=''>--เดือน --</option>
	 	<%
	 	selected = "";
		for(int i = 1;i<mmList.size();i++){
			if(GenNextId2(Integer.parseInt(currentDay[1])).equals(dayList.get(i))){
					selected = "selected";
				}else{
					selected = "";
				}%>
					<option value="<%=i%>"  <%=selected %>>&nbsp;<%=mmList.get(i)%></option>
			<%} %> 
     </select>
	  &nbsp;&nbsp;
	 	<select size="1" class="box2" style="width:100px" name="yyDDL1" >
        <option value=''>---ปี---</option>
        <%
        selected = "";
		for(int i = 0;i<yyList.size();i++){	
		    //int yy = Integer.parseInt(yyList.get(i).toString())-543;   //2012,2555
		    String pYY = Integer.parseInt(yyList.get(i).toString())-543+"".trim();
			if(currentDay[0].equals(pYY)){
					selected = "selected";
				}else{
					selected = "";
			}%>
				<option value="<%=pYY%>" <%=selected %>><%=yyList.get(i)%></option>
			<%} %> 
     </select>
	 &nbsp;ถึง &nbsp;
	 <select size="1" class="box2" style="width:90px" name="dayDDL2" >
	<option value=''>---วัน---</option>
	<%
		 selected = "";
		for(int i = 1;i<dayList.size();i++){
			if(next3Month[2].equals(dayList.get(i))){
				selected = "selected";
			}else{
				selected = "";
			}%>
				<option value="<%=dayList.get(i) %>"   <%=selected %>>&nbsp;<%=dayList.get(i)%></option>
			<%}%>       
     </select>
	 &nbsp;&nbsp;
	 	<select size="1" class="box2" style="width:100px" name="mmDDL2" >
	 	 <option value=''>--เดือน --</option>
	 	<%
	 	selected = "";
		for(int i = 1;i<mmList.size();i++){
			if(GenNextId2(Integer.parseInt(next3Month[1])).equals(dayList.get(i))){
					selected = "selected";
				}else{
					selected = "";
				}%>
					<option value="<%=i%>"  <%=selected %>>&nbsp;<%=mmList.get(i)%></option>
			<%}%> 
     </select>
	  &nbsp;&nbsp;
	 	<select size="1" class="box2" style="width:100px" name="yyDDL2" >
        <option value=''>---ปี---</option>
        <%
        selected = "";
		for(int i = 0;i<yyList.size();i++){	
		    //int yy = Integer.parseInt(yyList.get(i).toString())-543;
		     String pYY = Integer.parseInt(yyList.get(i).toString())-543+"".trim();
			if(next3Month[0].equals(pYY)){
					selected = "selected";
				}else{
					selected = "";
			}%>
				<option value="<%=pYY%>" <%=selected %>><%=yyList.get(i)%></option>
			<%} %> 
     </select>

	&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:doGo();"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a></td>
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
      <table id="results" border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td class="col_name" width="3%"><input type="checkbox" name="C1" value="ON" onclick="checkAllBox(this)"></td>
          <td class="col_name" width="8%">วันที่</td>
          <td class="col_name" width="6%">เวลา</td>
          <td class="col_name" width="10%">เลขที่เอกสาร</td>
          <td class="col_name" width="6%">แปลง</td>
          <td class="col_name" width="5%">บ้านเลขที่</td>
          <td class="col_name" width="10%">วัน-เวลาที่แจ้ง</td>
          <td class="col_name" width="19%">ชื่อลูกค้า/ชื่อผู้แจ้ง</td>
           <td class="col_name" width="10%">โทรศัพท์ติดต่อ</td>
		  <td class="col_name" width="10%">สถานะ</td>
		  <td class="col_name" width="13%">ระบบ</td>
        </tr>
 <%
         int c = 0;
 		if(resultList!=null && resultList.size()>0){
 			ArrayList strArr = null;
 			Iterator it = resultList.iterator(); 			
 			StringBuffer tempB = new StringBuffer();
 			StringBuffer timeB = new StringBuffer();
 			
 			String tagColor = "";
 			String tagBgColor = "";
 			
			while(it.hasNext()){
			    c++;		
				strArr =(ArrayList)it.next();	
				tempB.delete(0,tempB.length());
				tempB.append(GetDateDDMMYY(strArr.get(5).toString())); //2012-04-24/			
				timeB.delete(0,timeB.length());
				timeB.append(GetDateTimeFormat(strArr.get(5).toString())); // 11:00
				boolean isCurrent = isComparedToDay(strArr.get(0).toString());
				//System.out.println("Check current date :"+isCurrent);
				tagColor="#ffffff";
				if((c%2)==0){
					tagColor="#f0f0f0";
				}
				if(strArr.get(9).toString().equals("01")){
			 		tagBgColor = "#ff7537";
				}else  if(strArr.get(9).toString().equals("02")){
					tagBgColor = "#7bd148";
				}else{
					 tagBgColor = "#ffffff";
				}	 
 %>
	        <tr bgcolor="<%=tagColor %>">
	          <td align="center" class="dotline" width="3%">
	          <%  if(strArr.get(2).equals("") && !isCurrent){ //check i_docno
	          		//AR:002|2555-06-28|12:00
	          		String keyId = sel_project+"|"+strArr.get(0)+"|"+strArr.get(1);
	          		out.println("<input type=\"checkbox\" name=\"chkDel\" value=\""+keyId+"\">");
	          }else{
	               out.println("&nbsp;");
	    	}
	       %>
	          </td>
	          <td  align="center" class="dotline ; item">&nbsp;<%=thaiDateFormate(strArr.get(0).toString()) %></td><!-- i_date -->
	          <td class="dotline" align="center" >&nbsp;<%=strArr.get(1) %></td>
	          <td class="dotline" align="left" >&nbsp;
	          <%//08=IND,01=CALL Service,CASE 11=E-Service,CASE 10=CUP or OTHER CASE
	            if("01".equals(strArr.get(10).toString()) || "08".equals(strArr.get(10).toString())){
	            //tel,projectId,houseId,lock
	           %>
	          	<a href="javascript:popupSvcHistory('<%=strArr.get(7) %>','<%=sel_project%>','<%=strArr.get(4) %>','<%=strArr.get(3) %>');"><%=strArr.get(2) %></a>
	          <%}else{
	          		out.println(strArr.get(2));
	          } %>
	          </td>
	          <td class="dotline" align="center" >&nbsp;<%=strArr.get(3) %></td>
	          <td class="dotline" align="center">&nbsp;<%=strArr.get(4) %></td>
	          <td class="dotline" align="center" >&nbsp;<%=thaiDateFormate(tempB.toString()) %>&nbsp;<% if(!"".equals(timeB.toString())){ out.println(timeB.toString().substring(0,5)+"&nbsp;น.");} %></td><!-- dateKeyIn 2012-04-24 11:25:00.0 -->
	          <td class="dotline">&nbsp;<%=doString.DisplayThai(strArr.get(6).toString()) %></td>
			  <td  class="dotline">&nbsp;<%=strArr.get(7) %></td>
	          <td align="left" class="dotline" >&nbsp;
	          <%
		         if(strArr.get(8).equals("OPN")){
			    	 out.println(strArr.get(8)+" บันทึกข้อมูลเรียบร้อยแล้ว");
			    }else if(strArr.get(8).equals("CAN")){
			    	 out.println(strArr.get(8)+" ยกเลิกรายการแล้ว");
			    }else if(strArr.get(8).equals("CLS")){
			    	 out.println("ดำเนินการแก้ไขแล้ว");
			    } else if(strArr.get(8).toString().indexOf("100")!=-1){
					out.println("รอเข้าดำเนินการแก้ไข");
				} else if(strArr.get(8).toString().indexOf("200")!=-1){
					out.println("อยู่ระหว่างดำเนินการแก้ไข");
				} else if(strArr.get(8).toString().indexOf("300")!=-1){
					out.println("ดำเนินการแก้ไขเรียบร้อยแล้ว");
				} 
				/*else if(strArr.get(8).toString().indexOf("999")!=-1){
					out.println("รับเรื่องแจ้งซ่อม");
				}*/
				else if("OPN999".equals(strArr.get(8))){
					out.println("รับเรื่องแจ้งซ่อม");
				}else if("CAN999".equals(strArr.get(8))){
					out.println("ยกเลิกใบแจ้งซ่อม");
				}else {
					out.println(strArr.get(8).toString());
				}
			    %>
	          </td>
	          <td align="center" class="dotline" ><img src="https://img.icons8.com/color/18/000000/line-me.png">&nbsp;</td>
	        </tr>  
 			<%
 			}
 	}else{
  %>       
        <tr>
		   <td  class="dotline" colspan="11" class="side01" >&nbsp;</td>
        </tr>
       <tr>
		   <td  class="dotline" colspan="11" align="center" class="side01" >&nbsp;ไม่มีข้อมูล</td>
        </tr>
        <tr>
		   <td  class="dotline" colspan="11" class="side01" >&nbsp;</td>
        </tr>
        <%}
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
<% if(c>0){ %>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr  valign="MIDDLE">
    <td align="right" nowrap="nowrap" width="50%">
    <div id="pageNavPosition"></div>
    </td>
   <td valign="middle" align="left" nowrap="nowrap" width="50%" class="pg-normal" >
   &nbsp;&nbsp;<A href="#" onclick="toggle_visibility('page');">|ALL|</A>&nbsp;&nbsp;<div id="page"></div>
    </td>
  </tr>
</table>
<%} %>
<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2"><a href="javascript:doDelete();"><img border="0" src="images/act_delete.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a></td>      	
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

</form>
<script type="text/javascript">	
    function toggle_visibility(id) {
      var intX = 0;
      var e = document.getElementById(id);
      if(e.style.visibility == 'hidden'){
         e.style.visibility = 'visible';
         intX = 1;
      }else{
         e.style.visibility = 'hidden';
      }      
      if(intX==1){
         allList();
      }else{
        pageList();
      }
    }

 	function allList(){
 		 totalRec  = "<%=c%>";
 		  var pager = new Pager('results', totalRec); 
	      pager.init(); 
	      pager.showPageNav('pager', 'pageNavPosition'); 
	      pager.showPage(1);
    }
    
    function pageList(){
 		  var pager = new Pager('results', 25); 
	      pager.init(); 
	      pager.showPageNav('pager', 'pageNavPosition'); 
	      pager.showPage(1);
    }
</script>
 <script type="text/javascript"><!--
        var pager = new Pager('results', 25); 
        pager.init(); 
        pager.showPageNav('pager', 'pageNavPosition'); 
        pager.showPage(1);
  //--></script>
</BODY>
</HTML>
