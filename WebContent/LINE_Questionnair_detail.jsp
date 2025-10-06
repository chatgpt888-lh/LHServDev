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
	   String i_docno = "";
	   if (request.getParameter("i_docno") != null) {
				i_docno = doString.checkString(request.getParameter("i_docno"));
		} // End if	
	   
%>

<HTML>
<HEAD>
<TITLE>LH Service</TITLE>
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

 
function Go() {
		 frmven.action = "LINE_Questionnair_detail.jsp";
		 frmven.submit();		 
}
//-->



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

<FORM name = "frmven" method = "post" ACTION = "LINE_Questionnair_detail.jsp">


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            รายงานแบบประเมิณลูกค้า Line LH Service</td>
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
    <td class="item ; dotline01" height="22">ใบแจ้งซ่อมเลขที่ : <%=i_docno%></td>
    <td height="22" class="dotline01">&nbsp;&nbsp;</td>
<!--
    <td height="22" class="item ; dotline01">&nbsp;</td>
    <td height="22" class="dotline01">&nbsp;</td>
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
 		
	
    &nbsp;&nbsp  --> </td>
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


<br style="font-size:10pt">

            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1" ><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายการที่ค้นได้ &nbsp;&nbsp;</td>
                <td class="item_tab3"></td>
                <td>&nbsp;</td>                
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
          <td class="col_name">ลำดับ</td>
          <td class="col_name">คำถาม</td>
          <td class="col_name">คำตอบ</td> 
        </tr>
<%		
	//System.out.println("---> station :"+station);	
		/*String condition = "", d_appoint_start = "", d_appoint_end = "", d_start = "", t_start = "", d_end = "", t_end = "", follow_status = "";
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

	
            
            //-------------------------------------------
            loop++;
            tagBgcolor="#ffffff";
            if(loop%2==0){
                tagBgcolor="#e2e3e5";
            }
			
			n_emp = "";
				sql.delete(0, sql.length());
				sql.append("select n_nemploy_th from docflow:acemploy ")
				   .append("where i_employ = '"+doString.checkString(rs.getString("i_emp_update"))+"' ");				
				rs1 = stmt1.executeQuery(sql.toString());
				if (rs1.next()) {
						n_emp = doString.MS874ToUnicode(doString.checkString(rs1.getString("n_nemploy_th")));					
				}
			
			*/
	String i_ans_no = "", n_desc ="";
				sql.delete(0, sql.length());
				sql.append("select distinct i_form, i_type, i_code, n_desc, file_name from lan:lser_quesstd ")
				    .append("where i_form = 'A' and i_type = '01'  ")
                    .append("order by i_code ");		
				rs = stmt.executeQuery(sql.toString());
				while (rs.next()) {
							
							sql.delete(0, sql.length());
							sql.append("select i_ques_no, i_ans_no, i_ans_text from lan:lser_quesionair ")
								.append("where i_docno = '"+i_docno+"' ")
								.append("and i_ques_no = '"+doString.checkString(rs.getString("i_code"))+"' ")
								.append("order by i_ques_no ");				
							rs1 = stmt1.executeQuery(sql.toString());
							if (rs1.next()) {
									i_ans_no = doString.checkString(rs1.getString("i_ans_no"));					
							}
							sql.delete(0, sql.length());
							sql.append("select n_desc from lan:lser_quesstd ")
								.append("where i_form = 'A' ")
								.append("and i_type = '02' ")							
								.append("and i_code = '"+i_ans_no+"' ");
								rs1 = stmt1.executeQuery(sql.toString());
							if (rs1.next()) {
									n_desc = doString.MS874ToUnicode(doString.checkString(rs1.getString("n_desc")));					
							}
							 
		
%>
    <tr>
   <td align="center" class="dotline"><%=doString.checkString(rs.getString("i_code"))%></td>
    <td align="left" class="dotline"><%=doString.MS874ToUnicode(doString.checkString(rs.getString("n_desc")))%></td>
	 <td align="center" class="dotline"><%=n_desc%></td>

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
		System.out.println("!!! ERROR LINE_Questionnair_detail.jsp : " + e.getMessage());
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
