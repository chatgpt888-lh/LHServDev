<%@page language="java" contentType="text/html; charset=TIS-620"
pageEncoding="TIS-620" %> 
<%@page import="java.util.*" %>
<%@page import="java.text.SimpleDateFormat" %>

<SCRIPT LANGUAGE="JavaScript">
var EShortMonths = new Array( "Jan","Feb","Mar", "Apr","May","Jun", "Jul","Aug","Sep","Oct", "Nov", "Dec");
var EFullMonths	 = new Array( "January", "February", "March","April", "May", "June","July", "August", "September",
									 "October", "November", "December" ); 
var TShortMonths = new Array( "ม.ค.","ก.พ.","มี.ค.", "เม.ย.","พ.ค.","มิ.ย.", "ก.ค.","ส.ค.","ก.ย.","ต.ค.", "พ.ย.", "ธ.ค.");
var TFullMonths	 = new Array( "มกราคม", "กุมภาพันธ์", "มีนาคม","เมษายน", "พฤษภาคม", "มิถุนายน","กรกฏาคม",
									"สิงหาคม", "กันยายน","ตุลาคม", "พฤศจิกายน", "ธันวาคม" ); 
var EShortDow	= new Array("Sun.","Mon.","Tue.","Wed.","Thu.","Fri.","Sat."); 
var EFullDow		= new Array("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"); 
var TShortDow	= new Array("อา.","จ.","อ.","พ.","พฤ.","ศ.","ส."); 
var TFullDow		= new Array("อาทิตย์.","จันทร์","อังคาร","พุธ","พฤหัส","ศุกร์","เสาร์"); 
var arrMonth		= new Array();

var arrMonth		= new Array(); 
var SysDate		= new Date(); 
var thisMonth	= SysDate.getMonth(); 
var thisYear		= SysDate.getFullYear(); 
var URLargs		= getURLArgs(true); 
if (URLargs.year)    { thisYear = parseInt(URLargs.year); } 
if (URLargs.month)  { thisMonth = (parseInt(URLargs.month)%12); } 

function getURLArgs(caseBool) { 
	  var casefree = ( (true == caseBool) || (caseBool >= 1)) ? true: false; 
	  var args  = new Object(); 
	  var query = location.search.substring(1); 
	  var pairs = query.split("&"); 
		  for(var i = 0; i< pairs.length; i++)  { 
				pairs[i]= unescape(pairs[i]); 
				var pos=pairs[i].indexOf('='); 
				if(-1 == pos) continue; 
				var argname; 
				if(true != casefree) { argname = pairs[i].substring(0,pos); } 
				else { argname = pairs[i].substring(0,pos).toLowerCase(); } 
				var value = pairs[i].substring(pos+1); 
				args[argname] = value; 
		 }  
	 return args; 
} 

function ChkClick(myElement){
	if (myElement.id != "calDateText"){
		arrMonth[arrMonth.length] = "";
		if (myElement.bgColor == "") {
			for(i = 0; i < arrMonth.length; i++) { 	
				if (arrMonth[i] == myElement.id) {} else if (arrMonth[i] == "") arrMonth[i] = myElement.id ;	
			}
			myElement.bgColor = "#FFA000";	
		} else {
			for(i = 0; i <= arrMonth.length; i++) { if (arrMonth[i] == myElement.id) arrMonth[i] = "" ;	}
			myElement.bgColor = "";	
		}
	}
}
//click Reset OK
function ResetDate(){
    with (self.opener.document.callForm) {
        //alert(ChkList.value);
		//if (ChkList.value == '1')	{ 
		MrnList.value = ""; 
		MrnTotDate.value = 0 ; 
		//}
		//if (ChkList.value == '2')	{ AftList.value = ""; AftTotDate.value = 0 ; }
		//if (ChkList.value == '3')	{ FullList.value = ""; FullTotDate.value = 0 ; }
		//TotalDate.value = parseFloat(MrnTotDate.value)+parseFloat(AftTotDate.value)+	parseFloat(FullTotDate.value)
	} //End With
	window.close();
}

//click Button OK
function CntSelectDate(){
	Cnt = 0;
	Chk = false;
	TmpDate = '';
	arrMonth.sort();
	//*************************	   
	var today = new Date();
    //**************************        
    with (self.opener.document.callForm) {
		for(i = 0; i < arrMonth.length; i++) { 
			if ((arrMonth[i] != "") && (arrMonth[i] != TmpDate)) {
				var arrayOfStr =arrMonth[i].split("/");	
				//alert(arrMonth[i]);
				var intYY = parseFloat(arrMonth[i].substring(0,4))-543; 
				var intMM = parseFloat(arrMonth[i].substring(5,7),10);
				//var intDD = parseFloat(arrMonth[i].substring(8,10));	
				var isDate = checkDate(intYY,intMM,arrayOfStr[2]);
				if(isDate){
					 TmpDate = arrMonth[i];
					 Cnt += 0.5;
				     DateString = arrMonth[i].substring(8,10)+'/'+arrMonth[i].substring(5,7)+'/'+arrMonth[i].substring(0,4)+'\n';
					 if (Chk==false) { Chk = true; MrnList.value = "" ;}
					 MrnTotDate.value = Cnt ;
				     MrnList.value = MrnList.value + DateString;	
				}else{
					 alert("ไม่สามารถเลือกวันที่ย้อนหลังได้");			
				}	
			}//End if;
		 } // End For;
		//TotalDate.value = parseFloat(MrnTotDate.value)+parseFloat(AftTotDate.value)+parseFloat(FullTotDate.value)
	} //End With
	window.close();
}
<%
String [] temp = new SimpleDateFormat("dd-MM-yyyy", Locale.US).format(new Date()).split("\\-");	
//return temp[0]+"/"+temp[1]+"/"+(Integer.parseInt(temp[2])+543);
%>
//Modify by pradoem 2012.11.13
  function checkDate(pYY,pMM,pDD){
       /*var today = new Date();
	  //today
	   var tYY = parseInt(today.getYear()); //2012
	   var tMM = parseInt(today.getMonth()+1); //7
	   var tDD = parseInt(today.getDate());*/
	   var tYY = parseFloat(<%=temp[2]%>); //2012
	   var tMM = parseFloat(<%=temp[1]%>); //7
	   var tDD = parseFloat(<%=temp[0]%>);
	   //alert(tYY+","+tMM+","+tDD);
	   //*******************************
	   var fYY =pYY; //2012
	   var fMM =pMM; //7
	   var fDD =pDD;
	   //*********Logic check date	   
	   //alert(tYY+","+tMM+","+tDD+" || "+pYY+","+pMM+","+pDD);	    
	   if(fYY<tYY){//YY
	      return false;
	   }else{//MM
		   if(fYY>tYY){ //2013>2012
		     return true;
		   }
		   if(fMM<tMM){
			  return false;
		   }else{
		        if(fMM==tMM){
			       if(fDD<tDD){
					   return false;
					}else{
					   return true;
					}
		        }else{
		        	return true;	
		        }
		   }
	  }
}


function DrawCalendars(){
  var DocName = location.pathname; 
  Sdate	= new Date(thisYear,thisMonth-1,0);
  Pdate	= new Date(thisYear,thisMonth-1);    //  change each 1 month
  Ndate	= new Date(thisYear,thisMonth+1);    //
  CntMonth = 0;
  with (document) {
  write("<head><title>ปฏิทินกำหนดวันนัดหมายเข้าตรวจสอบ</title><meta http-equiv='Content-Type' content='text/html; charset=TIS-620'></head>\n");
  write("<Style>\n");
  write("TD { font-family:Ms Sans Serif;font-size:10pt }\n");
  write("TH { font-family:Ms Sans Serif;font-size:10pt }\n");
  write("TR { font-family:Ms Sans Serif;font-size:10pt }\n");
  write("</Style>\n");
  write("<table border='0' cellpadding='0' width='800px' align=center bgcolor=white>\n");
  while(CntMonth < 4)  {     //  
	if ((CntMonth % 4) == 0) write("<tr align=center>\n");     //
	CntMonth++;
	iDate      = new Date(Sdate.getFullYear(),Sdate.getMonth()+CntMonth);
	AmtDate	= new Date(iDate.getFullYear(),iDate.getMonth()+1,0).getDate(); 
	CurDate	= iDate.getDate();
	CurMonth	= iDate.getMonth();
	CurYear	= iDate.getFullYear();
	CntDate   = 0 - iDate.getDay();
	write("<td>\n");
	write("<table border='0' cellpadding='0' width='100%' bgcolor=white><tr><td>\n");
	write("<table border='0' cellpadding='5' cellspacing='1' width='94%'>\n");
	write("<tr bgcolor='#dcf0ff'>\n");
	write(	"<td colspan='7'><font color='#285b92'>\n");
	write(	"<b>",TFullMonths[CurMonth],'   ',CurYear+543,"</B></font></td>\n"); 
	write("</tr>\n"); 
	write("<tr bgcolor='#f0f6f8'>\n");    
	for(k=0; k< 7; k++) { write("<td><font color='#0000E0'>",TShortDow[k],"</font></td>\n");	}
	for(k=0; k< 6; k++) { 
		write("<tr bgcolor='#f0f0f0'>\n"); 
		for(i=0; i< 7; i++) { 
			CntDate++; 
		    if (CntDate > 0 && CntDate <= AmtDate) {
				FGcolor = "#000000";					
				if (i==0)	FGcolor = '#E00000';		
				if (i==6)  FGcolor = '#888888';	   
				if ((CurMonth+1) > 9) StrMonth = (CurMonth+1).toString() ; else StrMonth = '0'+(CurMonth+1).toString()
				if (CntDate > 9)   StrDate   = CntDate.toString() ;   else StrDate   = '0'+CntDate.toString()
				idTd = (CurYear+543).toString()+'/'+StrMonth+'/'+StrDate ;				 
				write("<td align='left' valign='top' id=",idTd," style='CURSOR:Hand' onclick=ChkClick(this)>");
				write("<font id=calDateText style='CURSOR:Hand;' onclick='ChkClick(this)' ");
				if (CurYear==SysDate.getFullYear() &&CurMonth==SysDate.getMonth()&&CntDate==SysDate.getDate()) 
					write(" color='#666ffd'><b>",CntDate,"</b></font></td>\n");		
				else 
					write(" color='",FGcolor ,"'>",CntDate,"</font></td>\n");			
			} 	else writeln("<td>&nbsp;</font></td>");
		} 	write("</tr>\n");
	  }
	  write("</tr></table>\n"); 
	  write("</td></tr></table>\n"); 
	  write("</td>\n"); 
  } /// end while
  write("</tr></table>\n"); 
  write("<form name='newCal' method='get' action='" + DocName + "'>\n"); 
  write("<input type='hidden' name='month' value='" + thisMonth +"'>\n");  
  write("<input type='hidden' name='year' value='" + thisYear +"'>\n");  
  write("<center>"); 
  write("  <table width='750' cellspacing='0' cellpadding='0'>");
  write("      <td width=5 valign=top><img border=0 src='images/b3_tab1.gif' width=6 height=30></td>");
  write("      <td width=165 background='images/b3_tab2.gif' style='background-repeat : repeat-x' valign=top><p>");
  write("       <a href='javascript:CntSelectDate()' ><img border=0 src='images/act_ok.gif' ></a>  ");
  write("       <a href='javascript:ResetDate()' ><img border=0 src='images/act_clear.gif' ></a>  ");
  write("       </td>  ");
  write("      <td width=57 valign=top><img border=0 src='images/b3_tab3.gif' width=57 height=30></td>  ");
  write("      <td background='images/b3_tab4.gif' style='background-repeat : repeat-x' valign='top'><p align=right>  ");
  write("        <a href='' onclick='document.newCal.month.value=\""+ Pdate.getMonth()+
			 "\"; document.newCal.year.value=\""+Pdate.getFullYear()+"\"; submit(); return false;' \n>");
  write('         <img border="0" src="images/bu_L.gif" width="16" height="16"></a>&nbsp;Previous&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;');
  write("	&nbsp;Next&nbsp;<a href='' onClick='document.newCal.month.value=\""+  Ndate.getMonth()+
			 "\"; document.newCal.year.value="+Ndate.getFullYear()+"; submit(); return false;' \n>"); 
  write('<img border="0" src="images/bu_R.gif" width="16" height="16"></a>&nbsp; ');
  write("  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href='javascript:window.close()'>\n"); 
  write('<img border="0" src="images/bu_close.gif" width="60" height="18"></a></td>  ');
  write("  </table>");
  write("</center>\n"); 
  write("</form>\n"); 
  } // end with
}
DrawCalendars();
//setTimeout("window.close()",60000);
</SCRIPT>