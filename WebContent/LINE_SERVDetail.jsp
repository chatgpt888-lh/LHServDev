<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%//@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%!
	public static String textHideCharacter(String textDesc,int maxLength) {
		String ret = "";		
		if ((textDesc == null) || textDesc.equals("")) {			
			return textDesc;			
		}else{

			if(textDesc.length()>maxLength){
				ret = textDesc.substring(0,maxLength)+"..";
			}else {
				ret = textDesc;
			}
			return ret;
		}	
	}
	
	// 18/09/64 12.00
	public static  String toDDMMYY3(String str){
		 if ((str == null) || str.equals("")) {
			 return  str;
		 }else{
			 
			 String tmp[] = str.split("\\ ");//2021-03-28 09:04:00  "0","1"
			 String d2[] =  tmp[0].split("\\-"); //2013-03-29 
			 String x = ""+(Integer.parseInt(d2[0])+543);
			 return d2[2]+"/"+d2[1]+"/"+x.substring(2,d2[0].length())+" "+tmp[1].substring(0,5);
			 //return d2[2]+"/"+d2[1]+"/"+d2[0].substring(2,d2[0].length());
		 }
	}
	
   private String GetShortName(Connection conn,String comId,String projId){
	        StringBuffer sql = new StringBuffer();
	        PreparedStatement pstmt = null;
	        ResultSet rs = null;
	        String sName = "";
	        try {
	
	  			sql.delete(0, sql.length());
				sql.append(" SELECT i_short_nam FROM crm:acxprojt WHERE i_company = ? AND i_project = ?  ");
				
				//System.out.println("SQL GetDocumentName  :"+sql.toString());
				
				pstmt = conn.prepareStatement(sql.toString()); 
				pstmt.setString(1, comId);	
				pstmt.setString(2, projId) ; 
				
				rs = pstmt.executeQuery();	
				if(rs.next()){
				    sName  = doString.checkString(rs.getString("i_short_nam"), "");
				} 		  
	            rs.close();
	            pstmt.close();
	            return sName;
	        }catch(Exception e) {
	            System.out.println(" GetShortName Error : " + e.getMessage());
	            return "";
	        } finally{
	            try  {
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
	          }
	          catch(Exception ex) { }
	     }
  }	
  
  private String GetMsgTeleLineLog(Connection conn,String refId,String statusCode){
	        StringBuffer sql = new StringBuffer();
	        PreparedStatement pstmt = null;
	        ResultSet rs = null;
	        String yyyyMMddTime = "";
	        String empId = "";
	        String emmployName = "";
	        String msg = "";
	        try {
	           
	  			sql.delete(0, sql.length());
				sql.append(" SELECT follow_status,i_employ_update,d_employ_update FROM lan:tele_line_log WHERE i_refno = '"+refId+"'")
				.append(" order by follow_status asc,d_employ_update desc ");
				//AND follow_status = "+statusCode
				
				boolean isRec = false;
				//System.out.println("sql1 = "+sql.toString());
				pstmt = conn.prepareStatement(sql.toString()); 
				rs = pstmt.executeQuery();	
				while(rs.next()){
				    //sName  = doString.checkString(rs.getString("i_short_nam"), "");
				    yyyyMMddTime = doString.checkString(rs.getString("d_employ_update"), ""); //2020-02-11 11:30:00
				    empId = doString.checkString(rs.getString("i_employ_update"), "");
				    
				    isRec = true;
				    //------------------
				     msg += doString.checkString(rs.getString("follow_status"), "")+" : "+toDDMMYY3(yyyyMMddTime)+" น.<br>"; 
				} 
				if(isRec){
					//---------------------------Find name lan:useracl
					sql.delete(0,sql.length());
					sql.append("Select n_nemploy_th From docflow:acemploy Where i_employ = ? ");
					//System.out.println("sql2 = "+sql.toString());
					pstmt = conn.prepareStatement(sql.toString()); 
					pstmt.setString(1, empId);	
					//System.out.println("SQL :"+sql.toString());
					rs = pstmt.executeQuery();	
					if(rs.next()){
						emmployName = doString.DisplayThai(doString.checkString(rs.getString("n_nemploy_th"), ""));
					}	
					//-----------------------------
				    
				    msg = msg+ " By "+emmployName;
				    //System.out.println("msg = "+msg);
				}
	            rs.close();
	            pstmt.close();
	            return msg;
	        }catch(Exception e) {
	            System.out.println(" !!! GetMsgTeleLineLog Error : " + e.getMessage());
	            return "";
	        } finally{
	            try  {
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
	          }
	          catch(Exception ex) { }
	     }
  }	
     //DayList method
	private static ArrayList getTimeList(){
		ArrayList dayList = new ArrayList();
		dayList.add(0,"");
		dayList.add(1,"08:00");
		dayList.add(2,"08:30");
		dayList.add(3,"09:00");
		dayList.add(4,"09:30");
		dayList.add(5,"10:00");
		dayList.add(6,"10:30");
		dayList.add(7,"11:00");
		dayList.add(8,"11:30");
		dayList.add(9,"12:00");
		dayList.add(10,"12:30");
		dayList.add(11,"13:00");
		dayList.add(12,"13:30");
		dayList.add(13,"14:00");
		dayList.add(14,"14:30");
		dayList.add(15,"15:00");
		dayList.add(16,"15:30");
		dayList.add(17,"16:00");
		dayList.add(18,"16:30");
		dayList.add(19,"17:00");
		dayList.add(20,"17:30");
		dayList.add(21,"18:00");
		return dayList;
	}
	
 %>
<%

	/*String ParameterNames = "";
	for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
		ParameterNames = (String)e.nextElement();
		System.out.println(ParameterNames + " = "+request.getParameter(ParameterNames));
	}
	System.out.println("*******************************************");
	*/

//String sessionId = user.getsessionId();
//String userId = user.getUserID();

    String month[] = {"เดือน","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};   
   	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	
	ArrayList listTime = getTimeList();	
	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();   
		stmt1 = conn.createStatement();   
		
        //----=======================================----//   
        String msgTimeDesc = "";
		String option = "";	
		String project = "LHALL", i_company = "", i_project = "", n_project = "", n_proj = "", station = "", house = "", lock = "", status_detail = "", n_emp = "";
		if (request.getParameter("project") != null) {
				project = doString.DisplayThai(doString.checkString(request.getParameter("project")));
		} // End if	
		if (request.getParameter("station") != null) {
				station = doString.checkString(request.getParameter("station"));
		} // End if	
		if (request.getParameter("house") != null) {
				house = doString.checkString(request.getParameter("house")).toUpperCase();
		}
		if (request.getParameter("lock") != null) {
				lock = doString.checkString(request.getParameter("lock")).toUpperCase();
		}
		
		if (!project.equals("")) {
			i_company = project.substring(0, 2);
			i_project = project.substring(2);
		} // End if

		String Selected = "", code = "";		
		Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);	
			int cur_year = rightNow.get(Calendar.YEAR);
			int YY = rightNow.get(Calendar.YEAR);
			int MM = rightNow.get(Calendar.MONTH) + 1;
			int DD = rightNow.get(Calendar.DATE);	
		
		int begDD = DD;
		if (request.getParameter("begDD") != null) {
			begDD = Integer.parseInt(doString.checkString(request.getParameter("begDD"), Integer.toString(DD)));
		}
	
		int begMM = MM;
		if (request.getParameter("begMM") != null) {
			begMM = Integer.parseInt(doString.checkString(request.getParameter("begMM"), Integer.toString(MM)));
		}
	
		int begYY = YY;
		if (request.getParameter("begYY") != null) {
			begYY = Integer.parseInt(doString.checkString(request.getParameter("begYY"), Integer.toString(YY)));
		}
	
		int endDD = DD;
		if (request.getParameter("endDD") != null) {
			endDD = Integer.parseInt(doString.checkString(request.getParameter("endDD"), Integer.toString(DD)));
		}
	
		int endMM = MM;
		if (request.getParameter("endMM") != null) {
			endMM = Integer.parseInt(doString.checkString(request.getParameter("endMM"), Integer.toString(MM)));
		}
	
		int endYY = YY;
		if (request.getParameter("endYY") != null) {
			endYY = Integer.parseInt(doString.checkString(request.getParameter("endYY"), Integer.toString(YY)));
		}

       String startTime = doString.checkString(request.getParameter("startTime"),"");
%>

<HTML>
<HEAD>
<TITLE>LH Vender</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="LINE_SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<style>
.tooltip {
  position: relative;
  display: inline-block;
  /*border-bottom: 1px dotted #15588d;*/
}

.tooltip .tooltiptext {
  visibility: hidden;
  width:220px;
  background-color: #15588d;
  color: #fff;
  text-align: center;
  border-radius: 6px;
  padding: 5px;

  /* Position the tooltip */
  position: absolute;
  z-index: 1;
}

.tooltip:hover .tooltiptext {
  visibility: visible;
}
.tooltip:hover {
    cursor: pointer;
 }
</style>


  <link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">

  <script src="https://code.jquery.com/jquery-1.12.4.js"></script>
  <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
  <script>
  $( function() {
    $( document ).tooltip();
  } );
  </script>
  <style>
  label {
    display: inline-block;
    width: 5em;
  }
  </style>

<script language="JavaScript" type="text/JavaScript">
<!--
	function onChangeDDL() {
		do_totals1();
		document.forms[0].action="<%=request.getContextPath()%>/LINE_SERVDetail.jsp";
		document.forms[0].submit();
 }
 
function Go() {
		 //xLockId
		  do_totals1();
		 frmven.action = "LINE_SERVDetail.jsp";
		 frmven.submit();
		 
}
//-->
/*
$(document).ready(function(){
   $("#xLockId").click(function (e){
	    e.preventDefault();	
 		do_totals1(); 
 		document.forms[0].action="<%=request.getContextPath()%>/LINE_SERVDetail.jsp";
		document.forms[0].submit();
	});
}); */

function do_totals1() {
   	 	document.all.pleasewaitScreen.style.pixelTop = (document.body.scrollTop + 180);
    	document.all.pleasewaitScreen.style.visibility = "visible";
    	var msg = "<img src=\"<%=request.getContextPath()%>/images/p_loading.gif\" HEIGHT=\"60px\">";
    	document.getElementById("img1").innerHTML = msg;
    	setInterval(function () {do_totals1()}, 3000);
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

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">


<%--  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --%>
<DIV ID="pleasewaitScreen" STYLE="position: absolute; z-index: 0; top: 45%; left: 42%; visibility: hidden">
<TABLE BORDER="1" BORDERCOLOR="rgb(180,210,250)" CELLPADDING="0" CELLSPACING="0" 
	HEIGHT="125px" WIDTH="265px" ID="Table1">
	<TR>
	<TD BGCOLOR="#FFFFFF" ALIGN="CENTER" VALIGN="MIDDLE" class="test">
	<font color="rgb(255,120,0)"><b>Loading... Please wait</b></font>
	<br>
	<br>
	  <span id="img1"></span>
	</TD> 
	</TR>
</TABLE>
</DIV>
<%--  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --%>

<FORM name = "frmven" method = "post" ACTION = "LINE_SERVDetail.jsp">


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            LH Vender</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1" ><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">ระบุรายละเอียด</td>
                <td class="item_tab3"></td>
                <td>&nbsp;</td>                
              </tr>
            </table>
<%

%>

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
    <td class="item ; dotline01" height="22">Station :</td>
    <td height="22" class="dotline01"><select name="station" size="1" class="box" style="width:200px" onchange="frmven.submit()">
    <OPTION value="">-------   ทุก Station   -------</OPTION>
<%
      
        sql.delete(0, sql.length());
		sql.append("select distinct i_zone from lan:tele_stdpj ")
	       .append("order by i_zone ");	     
		rs = stmt.executeQuery(sql.toString());
		while (rs.next()) {
				option = "";	
				if (station.equals(doString.checkString(rs.getString("i_zone")))) {						
					option = " Selected";
				} // End if						 
							
%>
		<option value = "<%=doString.checkString(rs.getString("i_zone"))%>"<%=option%>>Station <%=doString.checkString(rs.getString("i_zone"))%></option>
<%			
	} // End while			
%>
    </select></td>
    <td height="22" class="item ; dotline01">โครงการ :</td>
    <td height="22" class="dotline01"><select name="project" size="1" class="box" style="width:200px">
     <OPTION value="LHALL">-------   ทุกโครงการ   -------</OPTION>
<%				
		sql.delete(0, sql.length());
		sql.append("select distinct b.i_company, b.i_project, b.n_project ")
			.append("from lan:acsbudgh a, lan:acxprojt b, lan:tele_stdpj c ")	
			.append("where a.i_company = b.i_company ")
			.append("and b.i_company = c.i_company ")
			.append("and a.i_project = b.i_project ")
			.append("and b.i_project = c.i_project ");
	if (!station.equals("ALL")) {
		 sql.append("and c.i_zone = '"+station+"' ");  
	}
		 sql.append("order by 1,2,3 ");
		 
		//System.out.println(" ---> SQL :"+sql.toString());
		rs = stmt.executeQuery(sql.toString());
		while (rs.next()) {
			option = "";
			if (project.equals(doString.checkString(rs.getString("i_company"))+doString.checkString(rs.getString("i_project")))) {
				option = " Selected ";
			} // End if

%>
			<OPTION value="<%=doString.checkString(rs.getString("i_company"))+doString.checkString(rs.getString("i_project"))%>" <%=option%>><%=doString.checkString(rs.getString("i_company"))+"-"+doString.checkString(rs.getString("i_project"))+"&nbsp;&nbsp;"+doString.MS874ToUnicode(doString.checkString(rs.getString("n_project")))%>
			</OPTION>
<%			
		} // End while
		rs.close();
		
%></select></td>
  </tr>

  <tr>
    <td class="item ; dotline01" height="22" width="15%">บ้านเลขที่
      :</td>
    <td height="22" width="39%" class="dotline01"><input type="text" name="house" value="<%=house%>" class="box" style="width:100px"></td>
    <td height="22" class="item ; dotline01" width="14%">แปลง :</td>
    <td height="22" width="32%" class="dotline01"> <input type="text" name="lock" value="<%=lock%>" class="box" style="width:100px">&nbsp;&nbsp;&nbsp;&nbsp;</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22">วันที่นัดซ่อม :</td>
    <td height="22" class="dotline01" width="45%">

<SELECT name="begDD" class="box" size="1">    
<%
		int trline = 1;
		int i = 0;
		String trcolor = "";

		for (int j = 1; j <=31; j++) {
			code = Integer.toString(j);
			if (j < 10) {
				code = "0" + code;
			}
			Selected = "";
			if (j == begDD) {
				Selected = " Selected";
			}
%>
			<OPTION value="<%=code%>"<%=Selected%>><%=code%></OPTION>
<%
		} // End for
%>
		</SELECT>&nbsp; 
		<SELECT name="begMM" class="box" size="1">   
<%
		for (int j = 1; j <=12; j++) {
			code = Integer.toString(j);
			if (j < 10) {
				code = "0" + code;
			}
			Selected = "";
			if (j == begMM) {
				Selected = " Selected";
			}
%>
			<OPTION value="<%=code%>"<%=Selected%>><%=month[j]%></OPTION>
<%
		} // End for
%>
		</SELECT>&nbsp; 
		<SELECT name="begYY" class="box" size="1">    
<%
		for (int j = begYY-5; j <=begYY+5; j++) {
			code = Integer.toString(j);
			if (j < 10) {
				code = "0" + code;
			}
			Selected = "";
			if (j == begYY) {
				Selected = " Selected";
			}
%>
			<OPTION value="<%=code%>"<%=Selected%>><%=j+543%></OPTION>
<%
		} // End for
%>
		</SELECT>&nbsp;&nbsp; ถึง &nbsp;&nbsp;
		<SELECT name="endDD" class="box" size="1">    
<%
		for (int j = 1; j <=31; j++) {
			code = Integer.toString(j);
			if (j < 10) {
				code = "0" + code;
			}
			Selected = "";
			if (j == endDD) {
				Selected = " Selected";
			}
%>
			<OPTION value="<%=code%>"<%=Selected%>><%=code%></OPTION>
<%
		} // End for
%>
		</SELECT>&nbsp; 
		<SELECT name="endMM" class="box" size="1">   
<%
		for (int j = 1; j <=12; j++) {
			code = Integer.toString(j);
			if (j < 10) {
				code = "0" + code;
			}
			Selected = "";
			if (j == endMM) {
				Selected = " Selected";
			}
%>
			<OPTION value="<%=code%>"<%=Selected%>><%=month[j]%></OPTION>
<%
		} // End for
%>
		</SELECT>&nbsp; 
		<SELECT name="endYY" class="box" size="1">    
<%
		for (int j = endYY-5; j <=endYY+5; j++) {
			code = Integer.toString(j);
			if (j < 10) {
				code = "0" + code;
			}
			Selected = "";
			if (j == endYY) {
				Selected = " Selected";
			}
%>
			<OPTION value="<%=code%>"<%=Selected%>><%=j+543%></OPTION>
<%
		} // End for
%>
		</SELECT></td>
    <td height="22" class="item ; dotline01">เวลา :</td>
    <td height="22" class="dotline01">
 		<select name="startTime" id="startTime" class="box" style="width:150px"  onchange="javascript:onChangeDDL();">
		<option value="">---กรุณาเลือกเวลา---</option>
		<%
		String selected = "";
		
		Collections.sort(listTime);
		for(int n = 1;n<listTime.size();n++){
		   if(startTime.equals(listTime.get(n))){
			    selected = "selected";
			}else{
				selected = "";
			}
		 %>
				<option value="<%=listTime.get(n) %>"   <%=selected %>>&nbsp;<%=listTime.get(n)%></option>
	     <%}%> 
		 </select>
		 <font color="#ff6400"> น.</font>      
    &nbsp;&nbsp;&nbsp;<a href="javascript:Go()"><img border="0" src="images/i_search.gif" align="absmiddle" width="20" height="20"></a></td>
  </tr>
</table>
</td>
  </tr>
</table>

<%
String tmpProj = "";
if (!project.equals("LHALL")) {
   tmpProj = GetShortName(conn,i_company,i_project);
}
 %>


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
                <td class="item_tab1" ><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายการที่ค้นได้ &nbsp;&nbsp;</td>
                <td class="item_tab3"></td>
                <td>&nbsp;<%
                if(tmpProj.length()>0){
                   out.println("รหัสย่อโครงการ : ("+tmpProj+")");
                }
                 %></td>                
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
<% if (project.equals("LHALL")) { %>                
          <td class="col_name">โครงการ</td>
<%  } %>    
          <td class="col_name">วันที่นัด</td>
          <td class="col_name">เวลานัด</td>      
          <td class="col_name">บ้านเลขที่</td>
          <td class="col_name">แปลง</td>
          <td class="col_name">ชื่อลูกค้า</td>
          <td class="col_name">โทร</td>
          <td class="col_name">สถานะ</td>
          <td class="col_name">TFU Remark</td>
          <td class="col_name">เลขที่ใบแจ้งซ่อม</td>
          <td class="col_name">รายละเอียด</td>
          <td class="col_name">ผู้บันทึกนัด</td>
        </tr>
<%		
	//System.out.println("---> station :"+station);	
		String condition = "", d_appoint_start = "", d_appoint_end = "", d_start = "", t_start = "", d_end = "", t_end = "", follow_status = "";
		String d_tracking = "", d_employ_update = "", flag = "";
		String d_up_hour = "", d_up_min = "", d_app_hour = "", d_app_min = "";
		if (!project.equals("LHALL")) {
           condition = " and a.i_company = '"+i_company+"' and a.i_project = '"+i_project+"' ";
        }  
		if (lock.trim().length()>0) {
           condition += " and a.i_lock = '"+lock+"' ";
        }   
		if (house.trim().length()>0) {
           condition += " and b.i_house = '"+house+"' ";
        }
        if(startTime.length()>0){
            condition += " and c.start_time = '"+startTime+"' ";
        }
        
        
		String tagFontColor = "";			
		sql.delete(0, sql.length());
		sql.append("select a.i_company, a.i_project, a.i_lock, b.i_house, a.d_appoint_start, a.d_appoint_end, a.n_customer, a.n_custel, a.i_refno, a.i_docno, a.i_emp_update,a.c_desc,a.c_tfu_remark, ")
		    .append("c.start_time, c.end_time, c.d_tracking ")
			.append("from lan:tele_dochd a, lan:acxlckmd b, lan:tele_tracking c ");
			
			if(!station.equals("")){
				  sql.append(" ,lan:tele_stdpj x ");
			}				
		sql.append("where a.i_company = b.i_company ")
			.append("and a.i_project = b.i_project ")
			.append("and a.i_lock = b.i_lock ")
			.append("and a.i_refno = c.i_refno ");
			
			if(!station.equals("")){
				 sql.append(" and a.i_company = x.i_company ")
				    .append(" and a.i_project = x.i_project  ")
				    .append(" and x.i_zone = '"+station+"' ");
			}	
		sql.append("and c.f_status != 'CAN' ")
			.append("and date(c.d_tracking ) between '"+doString.displayNumber("0000", begYY)+"-"+doString.displayNumber("00",begMM)+"-"+doString.displayNumber("00", begDD)+"' ")  
			.append("and '"+doString.displayNumber("0000", endYY)+"-"+doString.displayNumber("00", endMM)+"-"+doString.displayNumber("00", endDD)+"' ")
			.append(condition)
			.append("order by a.i_company, a.i_project, a.d_appoint_start, c.start_time, a.i_lock ");			
		//System.out.println("SQL => "+sql.toString());
		String tagBgcolor = "";
		String tempShortName = "";
		int loop = 0;			
		rs = stmt.executeQuery(sql.toString());
		while (rs.next()) {		
				d_appoint_start = doString.checkString(rs.getString("d_appoint_start"));
				d_appoint_end = doString.checkString(rs.getString("d_appoint_end"));
				d_tracking = doString.checkString(rs.getString("d_tracking"));
				if (d_appoint_start.trim().length() == 21){
						d_start = d_appoint_start.substring(8,10)+"/"+d_appoint_start.substring(5,7)+"/"+d_appoint_start.substring(2,4); 
						//t_start =  d_appoint_start.substring(11,16);
						t_start = doString.checkString(rs.getString("start_time"));
				} else {
						d_start = "";
						t_start = "";
				}
				if (d_appoint_end.trim().length() == 21){
						d_end = d_appoint_end.substring(8,10)+"/"+d_appoint_end.substring(5,7)+"/"+d_appoint_end.substring(2,4); 
						t_end =  d_appoint_end.substring(11,16);
				} else {
						d_end = "";
						t_end = "";
				}
				follow_status = "";				
				status_detail = "";
				d_employ_update = "";
				//msgTimeDesc = "";

				sql.delete(0, sql.length());
				sql.append("select d_employ_update from lan:tele_line_log ")
				   .append("where i_refno = '"+doString.checkString(rs.getString("i_refno"))+"' ")
				   .append("and follow_status = '100' ")
				   .append("and d_tracking = '"+d_tracking+"' ");
				  // out.println(sql.toString());
				rs1 = stmt1.executeQuery(sql.toString());
				if (rs1.next()) {		
						d_employ_update = doString.checkString(rs1.getString("d_employ_update"));
				}
					if (d_employ_update.trim().length() >= 16){
						d_up_hour = d_employ_update.substring(11,13);
						d_up_min = d_employ_update.substring(14,16);
							//22/06/2020 09:36
				    } else {
						d_up_hour = "";
						d_up_min = "";
					}
					if(t_start.trim().length() >=5) {
						d_app_hour = t_start.substring(0,2);
						d_app_min = t_start.substring(3,5);
					} else {
						d_app_hour = "";
						d_app_min = "";
					}
					flag = "";		
					if (!d_up_hour.equals("") && !d_up_min.equals("") && !d_app_hour.equals("") && !d_app_min.equals("")) {
							if (Integer.parseInt(d_up_hour) > Integer.parseInt(d_app_hour)) {
									flag = "<img border='0' src='images/i_alert.gif' align='absmiddle' width='10' height='10'>";							
							} else if ((Integer.parseInt(d_up_hour) == Integer.parseInt(d_app_hour)) && (Integer.parseInt(d_up_min) > Integer.parseInt(d_app_min))) {
									flag = "<img border='0' src='images/i_alert.gif' align='absmiddle' width='10' height='10'>";		
							} else {
									flag = "&nbsp;";
							} 
					}
				
				follow_status = "100";
				sql.delete(0, sql.length());
				sql.append("select follow_status from lan:tele_tracking ")
				   .append("where i_refno = '"+doString.checkString(rs.getString("i_refno"))+"' ")
				   .append("and d_tracking = '"+d_tracking+"' ")
				   .append("and f_status = 'OPN' "); 		
				//out.println(sql.toString());				   
				rs1 = stmt1.executeQuery(sql.toString());
				if (rs1.next()) {			
						follow_status = doString.checkString(rs1.getString("follow_status"));
				} 
				if (follow_status.equals("900")) {
						status_detail = "Finish";

				} else if (follow_status.equals("200")) {
						status_detail = "Check in";

				} else if (follow_status.equals("300")) {
						status_detail = "On Process";

				} else if (follow_status.equals("100")) {
						status_detail = "-";

				}
				msgTimeDesc = GetMsgTeleLineLog(conn,doString.checkString(rs.getString("i_refno")),"");
				//System.out.println("follow_status :"+follow_status+" , status_detail:"+status_detail +" , "+doString.checkString(rs.getString("i_refno")));			
				//--------------------find date time
				n_emp = "";
				sql.delete(0, sql.length());
				sql.append("select n_nemploy_th from docflow:acemploy ")
				   .append("where i_employ = '"+doString.checkString(rs.getString("i_emp_update"))+"' ");				
				rs1 = stmt1.executeQuery(sql.toString());
				if (rs1.next()) {
						n_emp = doString.MS874ToUnicode(doString.checkString(rs1.getString("n_nemploy_th")));					
				}
				
			if("Finish".equalsIgnoreCase(status_detail)){
				tagFontColor = " color='#5cb85c' ";
            } else if("-".equalsIgnoreCase(status_detail)){
				tagFontColor = " color='#ff0000' ";
            } else{
				tagFontColor = "  ";//color='#0078ff'
            }
            
            //-------------------------------------------
            loop++;
            tagBgcolor="#ffffff";
            if(loop%2==0){
                tagBgcolor="#e2e3e5";
            }
%>
    <tr bgcolor="<%=tagBgcolor %>">
<% if (project.equals("LHALL")) {

     tempShortName = GetShortName(conn,doString.checkString(rs.getString("i_company")),doString.checkString(rs.getString("i_project")));
 %>          
          <td align="left" class="dotline">&nbsp;
          	<%
			if(tempShortName.length()>0){
			   out.println("("+tempShortName+")");
			}
			 %>
			<%=doString.checkString(rs.getString("i_company"))%>-<%=doString.checkString(rs.getString("i_project"))%>  
         </td>
<%  } %>
          <td align="center" class="dotline"><%=d_start%>&nbsp;-&nbsp;<%=d_end%></td>
          <td align="center" class="dotline"><%=t_start%>&nbsp;<%=flag%></td>
		  <td align="center" class="dotline ; item"><%=doString.checkString(rs.getString("i_house"))%></td>
          <td class="dotline" align="center">
          
          <%
          String param = "&station="+station+"&project="+project+"&begDD="+begDD+"&begMM="+begMM+"&begYY="+begYY+"&endDD="+endDD+"&endMM="+endMM+"&endYY="+endYY+"&startTime="+startTime;
           %>
          <a id="xLockId" href="LINE_SERVList.jsp?i_company=<%=doString.checkString(rs.getString("i_company"))%>&i_project=<%=doString.checkString(rs.getString("i_project"))%>&i_lock=<%=doString.checkString(rs.getString("i_lock"))%>&i_house=<%=doString.checkString(rs.getString("i_house"))%>&i_refno=<%=doString.checkString(rs.getString("i_refno"))%><%=param %>"><%=doString.checkString(rs.getString("i_lock"))%></a></td>
          <td class="dotline" >
          <%
          	if(doString.checkString(rs.getString("n_customer"),"").length()>28){
          			%>
          			    <a href="#" class="tooltip" ><%=doString.DisplayThai(textHideCharacter(doString.checkString(rs.getString("n_customer"),""),28))%>
                		<span class='tooltiptext'><%=doString.DisplayThai(doString.checkString(rs.getString("n_customer"),""))%></span></a>   
          			<%         			
          	}else{
				out.println(doString.DisplayThai(doString.checkString(rs.getString("n_customer"))));
          	}
           %>
          </td>    
          <td align="left" class="dotline">
          <%
          if(doString.checkString(doString.DisplayThai(rs.getString("n_custel"))).length()>10){
          //doString.checkString(doString.DisplayThai(rs.getString("n_custel")));
          %>
                <a href="#" class="tooltip" ><%=doString.DisplayThai(textHideCharacter(doString.checkString(rs.getString("n_custel"),""),14))%>
                <span class='tooltiptext'><%=doString.DisplayThai(doString.checkString(rs.getString("n_custel"),""))%></span></a>            
          <%
          }else{
            out.println(doString.checkString(doString.DisplayThai(rs.getString("n_custel"))));
          }
          %>          
          &nbsp;</td>   
          <td align="center" class="dotline">
          	    <a href="#" class="tooltip" ><font <%=tagFontColor%>><%=status_detail%>&nbsp;</font><span class='tooltiptext'><%=msgTimeDesc%></span></a>         	
          </td>
          <td align="left" class="dotline" >
			<%
          	if(doString.checkString(rs.getString("c_tfu_remark"),"").length()>28){
          			%>
          			    <a href="#" class="tooltip" ><%=doString.DisplayThai(textHideCharacter(doString.checkString(rs.getString("c_tfu_remark"),""),28))%>
                		<span class='tooltiptext'><%=doString.DisplayThai(doString.checkString(rs.getString("c_tfu_remark"),""))%></span></a>   
          			<%         			
          	}else{
				out.println(doString.DisplayThai(doString.checkString(rs.getString("c_tfu_remark"))));
          	}
           %>&nbsp;</td>    
          <td align="left" class="dotline" >
              <a href="#" class="tooltip" ><%=doString.checkString(rs.getString("i_docno"))%>
                <span class='tooltiptext'>Ref_no: <%=doString.checkString(rs.getString("i_refno"),"")%></span></a> 
          &nbsp;</td>  
          <td align="left" class="dotline" >
 			<%
          	if(doString.checkString(rs.getString("c_desc"),"").length()>40){
          			%>
          			    <a href="#" class="tooltip" ><%=doString.DisplayThai(textHideCharacter(doString.checkString(rs.getString("c_desc"),""),40))%>
                		<span class='tooltiptext'><%=doString.DisplayThai(doString.checkString(rs.getString("c_desc"),""))%></span></a>   
          			<%         			
          	}else{
				out.println(doString.DisplayThai(doString.checkString(rs.getString("c_desc"))));
          	}
           %>&nbsp;
          </td>   
          <td align="left" class="dotline"><%=n_emp%>&nbsp;</td>
        </tr>    
<%
		} // end while
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
            <td width="75" class="act_tab2">&nbsp;</td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:history.back()" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>  
        </table>  

          </td>
        </tr>
      </table>

<br style="font-size:30pt">

<script language="JavaScript" type="text/JavaScript" src="LINE_SERV_Copyright.js"></script>

</FORM>	
</BODY>

</HTML>
<%
	} catch (Exception e) {
		System.out.println("!!! ERROR LINE_SERVDetail.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (rs1 != null) rs.close();
			if (stmt != null) stmt.close();
			if (stmt1 != null) stmt.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>
