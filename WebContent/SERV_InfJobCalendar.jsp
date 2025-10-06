<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %> 
<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>

<%    
  java.util.Calendar currentCal = java.util.Calendar.getInstance();  
  java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyy-MM-dd", Locale.US);

  Calendar rightNow = Calendar.getInstance();
  int curday = rightNow.get(Calendar.DAY_OF_MONTH);

  String dateType 	= doString.checkString(request.getParameter("dateType"));

  
  String month = doString.checkString(request.getParameter("Month"));
  if (month.equals("")) {
	month = Integer.toString(rightNow.get(Calendar.MONTH));
  }

  String year = doString.checkString(request.getParameter("Year"));
  if (year.equals("")) {
	year = Integer.toString(rightNow.get(Calendar.YEAR));
  }
  int curMnth = Integer.parseInt(month);
  int curYear = Integer.parseInt(year);
  currentCal = new  GregorianCalendar(curYear, curMnth, curday);
  String strdate = "";

  /***********************************************
  *Modify by pradoem
  *Last Modify : 2014.02.17
  *Version :
  */

%>
<HTML>
<HEAD>
<META http-equiv="Content-Type" content="text/html; charset=TIS-620">
<META http-equiv="Content-Language" content="th">
<META http-equiv="Content-Style-Type" content="text/css">
<TITLE>เลือกวันที่ (Pop Up)</TITLE>
<STYLE TYPE="text/css">
<!--
A:link {color:"#0066FF";TEXT-DECORATION: none;}
A:visited {color:"646482";TEXT-DECORATION: none;}
A:hover {color:"red";TEXT-DECORATION:none;}
TD {
  font-family: Microsoft Sans Serif;
  font-size: 10pt; color: #0066FF;
}
.box{ font-family: "Microsoft Sans Serif" ; font-size: 8pt; color: #0066FF; 
      padding-top: 1px; padding-right: 2px; padding-bottom: 1px; padding-left: 2px; 
      background-color: rgb(255,255,255); border: 1px rgb(235,210,255) solid ; scrollbar-color: white }
.currentDay {  
  color: #FF0000;
}
.otherDay {
  color: #0066FF;
}
.holidayDay {
  color: #FF6600;
}
.dayHeading {  
  font-size: 9pt; color: #666699; 
}
.titleStyle { 
  font-size: 14pt; color: #FFFFFF;
  background-color: #666699; text-align: center;
  font-weight: bold;
}

-->
</STYLE>

<SCRIPT LANGUAGE="JavaScript">
<!-- Begin
function setDate(strdate){
	year = parseInt(strdate.substring(0,4))+543;
	//set Form main call opener
	with (self.opener.document.frmInfJob) {
		<%=dateType%>.value = strdate.substring(8)+"/"+strdate.substring(5,7)+"/"+year;
		//window.opener.document.getElementById('txtAreaDescJob6').value = descTxt;
		<%=dateType%>.focus();
	}
	top.window.close();
}

// End -->
</script>
</HEAD>
<BODY>
<FORM NAME="frmCalendar" METHOD=POST ACTION="SERV_InfJobCalendar.jsp">
<INPUT type="hidden" name="dateType" value="<%=dateType%>">

<TABLE BORDER='0' CELLPADDING='1' CELLSPACING='2'>
  <TR><TD align="left" COLSPAN='7'><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;C a l e n d a r</TD></TR>
  <TR><TD align="left" COLSPAN='7'><font color=rgb(0,0,255)>เดือน :
  <SELECT size="1" name="Month" class="box" style="width:100" onChange="frmCalendar.submit()">
<%
	String optionSelected = "";	
	for (int m=0; m<12; m++) {
		optionSelected = "";
		if (m == curMnth){
			optionSelected = "selected";
		}
%>
  <option value="<%=m%>" <%=optionSelected%>><%=DateUtil.TH_month[m]%></option>
<%
	}
%>
	</SELECT>&nbsp;

	ปี : </font>&nbsp;<SELECT name=Year class="box" onChange="frmCalendar.submit()">
<%
	int Byear = curYear - 5;
	int Eyear = curYear + 5;
	for( int y = Byear;  y <= Eyear; y++ ){
  		    optionSelected = "";
			if (y == curYear) {
				optionSelected = "selected";
			}
%>
			<OPTION value="<%=y%>" <%=optionSelected%>><%=y+543%></OPTION>
<%
	}
%> 
			</SELECT>&nbsp;&nbsp;<input type="image" border="0" name="Go" src="images/bu_go.gif" width="40" height="22">
  </TD></TR>

  <TR>
    <TD WIDTH=14% bgColor=rgb(220,240,255)><FONT face="MS Sans Serif" color=rgb(0,50,255) size=1>Sun</FONT></TD>
    <TD WIDTH=14% bgColor=rgb(240,248,255)><FONT face="MS Sans Serif" color=rgb(0,50,255) size=1>Mon</FONT></TD>
    <TD WIDTH=14% bgColor=rgb(220,240,255)><FONT face="MS Sans Serif" color=rgb(0,50,255) size=1>Tue</FONT></TD>
    <TD WIDTH=14% bgColor=rgb(240,248,255)><FONT face="MS Sans Serif" color=rgb(0,50,255) size=1>Wed</FONT></TD>
    <TD WIDTH=14% bgColor=rgb(220,240,255)><FONT face="MS Sans Serif" color=rgb(0,50,255) size=1>Thu</FONT></TD>
    <TD WIDTH=14% bgColor=rgb(240,248,255)><FONT face="MS Sans Serif" color=rgb(0,50,255) size=1>Fri</FONT></TD>
    <TD WIDTH=14% bgColor=rgb(220,240,255)><FONT face="MS Sans Serif" color=rgb(0,50,255) size=1>Sat</FONT></TD>
  </TR>


<%  // Set the current day of the month
    int currentDay = currentCal.get(currentCal.DAY_OF_MONTH);
     
    // Calculate the totals days in the month
    int daysInMonth = currentCal.getActualMaximum(currentCal.DAY_OF_MONTH);

    // Calculate the day of the week for the first
    currentCal.set(currentCal.DAY_OF_MONTH, 1);
    int dayOfWeek = currentCal.get(currentCal.DAY_OF_WEEK);

    // Prefill the calendar with blank spaces
    if (dayOfWeek != 1) {
      out.println("    <TD COLSPAN=" + (dayOfWeek-1) + ">&nbsp;</TD>");
    }
	String strDay = "";
	String strMnth = "";
	String strYear = "";
	String bgcolor = "";
	int line = 0;
	boolean holiday = false;
	bgcolor = ((line%2) == 0) ? "white" : "#f5f5f5";
    // Fill in dates
    for (int day=1; day <= daysInMonth; day++) {
		holiday = false;
		strDay = doString.checkNumber(day);
		strMnth = doString.checkNumber(curMnth+1);
		strYear = Integer.toString(curYear+543);
		strdate = Integer.toString(curYear) + "-" + strMnth + "-" + strDay;
      if (day == currentDay) {
		if (holiday) {
	        out.println("    <TD CLASS='holidayDay' align='center' bgcolor=\""+bgcolor+"\"><A href=\"javascript:setDate('"+strdate+"');\">" + day + "</A></TD>");
		} else {
	        out.println("    <TD CLASS='currentDay' align='center' bgcolor=\""+bgcolor+"\"><A href=\"javascript:setDate('"+strdate+"');\">" + day + "</A></TD>");
		}
      } else {
		if (holiday) {
	        out.println("    <TD CLASS='holidayDay' align='center' bgcolor=\""+bgcolor+"\"><A href=\"javascript:setDate('"+strdate+"');\">" + day + "</A></TD>");

		} else {
	        out.println("    <TD CLASS='otherDay' align='center' bgcolor=\""+bgcolor+"\"><A href=\"javascript:setDate('"+strdate+"');\">" + day + "</A></TD>");
		}
      }
      
      if (dayOfWeek == 7) { 
		line++;
		bgcolor = ((line%2) == 0) ? "white" : "#f5f5f5";
        out.println("  </TR>\n\n  <TR bgcolor=\""+bgcolor+"\">");
		dayOfWeek = 1;
      } else {
        dayOfWeek++;
      }
    }// end for

    // Postfill the calendar with blank spaces
    if ((8-dayOfWeek) != 0) {
      out.println("    <TD COLSPAN=" + (8-dayOfWeek) + ">&nbsp;</TD>");
    }
	out.print("</TR></TABLE>");    
%>

      <TABLE border="0" width="270" cellspacing="0" cellpadding="0" height="30">
        <TBODY>
          <TR>
            <TD width="5" valign="top"><IMG border="0" src="images/b3_tab1.gif" width="6" height="30"></TD>
            <TD width="75" background="images/b3_tab2.gif" style="background-repeat : repeat-x" valign="top"></TD>
            <TD width="57" valign="top"><IMG border="0" src="images/b3_tab3.gif" width="57" height="30"></TD>
            <TD background="images/b3_tab4.gif" style="background-repeat : repeat-x" valign="middle">
            <P align="right">&nbsp;&nbsp;<A href="javascript:top.window.close()"><IMG border="0" src="images/bu_close.gif" width="50" height="15"></A></P>
            </TD>
          </TR>
        </TBODY>
      </TABLE>

</FORM>

</BODY>
</HTML>
