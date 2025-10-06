<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>

<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.Constants"%>
<%@ page import="serv.util.ServLog" %>

<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>


<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_BOQCode.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

	doString str = new doString();

	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	SERV_CommonData common = null;
	   
	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();       
		common = new SERV_CommonData(conn); 
        //----=======================================----//   



	   
	   //-----=============================== Count Row ================================-----//
	   int maxRow = 0;
       sql.delete(0,sql.length());	   
	   sql.append(" select count(*) cnt from lan:serv_noboq a ")
	         .append(" left join docflow:acemploy b on b.i_employ=a.i_employ_req ")
	         .append(" where a.d_approve is null and a.d_reject is null ")
		 .append(" and a.i_employ_approve='").append(user.getEmpId()).append("' ");
	    servlog.startLog(sql.toString());
        rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
        if (rs.next()) {        
           maxRow = rs.getInt("cnt");  
        }
        rs.close();
       //----=========================================================================----//

   


   
   //-----============== Generate Display Customize and Page Link ==================-----//
   String displayType = doString.checkString(request.getParameter("display_type"),"");    
   int displayLine = Integer.parseInt(doString.checkString(request.getParameter("display_line"),"0"));
   int nowPage = Integer.parseInt(doString.checkString(request.getParameter("now_page"),"1"));
   if (displayType.equalsIgnoreCase("A")) {
      displayLine = maxRow;
      nowPage = 1;
   }
   if (displayLine<Constants.SERV_BOQCODE_LINE) displayLine = Constants.SERV_BOQCODE_LINE;      
   
   int startRow = ((nowPage-1)*displayLine);
   int endRow = startRow+displayLine;
   
   String pageLink = "";
   int tmpMax = maxRow;
   int tmpPage = 0;
   while (tmpMax>0) {
       tmpMax -= displayLine;
       tmpPage++;
       if (nowPage==tmpPage) {
          pageLink += "&nbsp; <b>"+tmpPage+"</b> ";
       } else {
          pageLink += "&nbsp; <a href='#' onclick='changePage("+tmpPage+");'>"+tmpPage+"</a> ";
       }
   }
   
   if (tmpPage>1) {
      int prev = nowPage-1;
      if (prev<1) prev=1;  
      pageLink = "<a href='#' onclick='changePage("+prev+");'>หน้าก่อน</a>&nbsp; "+pageLink;
      int next = nowPage+1;
      if (next>tmpPage) next = tmpPage;
      pageLink += "&nbsp; <a href='#' onclick='changePage("+next+");'>หน้าถัดไป</a>";      
   } else {
      pageLink = "หน้า <b>1</b>";
   }
 //---=========================================================================----//


   
%>

<HTML>
<HEAD>
<TITLE>ขอรหัส BOQ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--

  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_BOQCode.jsp";
     document.forms[0].submit();
  }   

//-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">

<input type="hidden" name="now_page" value="<%=nowPage%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ขอรหัส BOQ</td>
          <td width="50%" align="right">
          
          </td>
        </tr>
      </table>


<br style="font-size:10pt">


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="160">รายการ BOQ ที่มีผู้ขอ</td>
                <td class="item_tab3"></td>
                <td>&nbsp;<input type="radio" value="L" checked name="display_type" <%=(displayType.equalsIgnoreCase("L") ? "checked" : "")%>>แสดงจำนวนรายการต่อหน้า&nbsp;
                  <input type="text" name="display_line" class="boxC" style="width:50px" value="<%=displayLine%>">&nbsp;
                  รายการ&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" value="A" name="display_type" <%=(displayType.equalsIgnoreCase("A") ? "checked" : "")%>>
                  แสดงรายการทั้งหมด&nbsp;&nbsp;&nbsp;&nbsp;
                  <a href="#" onclick="changePage(1);"><img border="0" src="images/bu_R.gif" align="absmiddle" style="cursor:hand" width="16" height="16"></a>
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
          <td width="100%" class="frmL"> <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr> 
                <td width="29%" class="col_name">เลขที่อ้างอิง</td>
                <td width="42%" class="col_name">ชื่อผู้ขอ</td>
                <td width="29%" class="col_name">วันที่ขอ</td>
              </tr>
        <%
		        int line = 0;		     
		        sql.delete(0,sql.length());
		        sql.append(" select first ").append(endRow).append(" a.i_refno,a.d_keyin , ")
		              .append(" trim(b.n_prename_th)||trim(n_nemploy_th)||' '||trim(n_semploy_th) n_employ ")
		              .append(" from lan:serv_noboq a ")
		              .append(" left join docflow:acemploy b on b.i_employ=a.i_employ_req ")
		              .append(" where a.d_approve is null and a.d_reject is null ")
			      .append(" and a.i_employ_approve='").append(user.getEmpId()).append("' ")
		              .append(" order by a.i_refno ");
				servlog.startLog(sql.toString());
		        rs = stmt.executeQuery(sql.toString());
				servlog.endLog();

		        for (int i=0;i<maxRow;i++) { 
                      if (rs.next()) {
                         if (i>=startRow && i<=endRow) {	    
					        String iRefNo = str.createID(rs.getInt("i_refno"),4);
					        String nEmploy = doString.checkString(doString.DisplayThai(rs.getString("n_employ")),"-");
                                         
                            String dKeyIn = "-";             
							Timestamp tmp = rs.getTimestamp("d_keyin");
							if (tmp!=null) {
							    Calendar cal = Calendar.getInstance();
							    cal.setTime(tmp);    			
							    dKeyIn = getDateFromCalendar(cal);
						    }    		

		                    %>
				              <tr height="25"> 
				                <td width="29%" class="dotline ; item"><div align="center"><a href="SERV_BOQCode02.jsp?i_refno=<%=iRefNo%>"><%=iRefNo%></a></div></td>
				                <td width="42%" class="dotline ; item"> <div align="left"><%=nEmploy%></div></td>
				                <td width="29%" class="dotline ; item"> <div align="center"><%=dKeyIn%></div></td>
				              </tr>					                      
		                    <%
		                    
 					         line++;                         
                         } // end if check row
                         
                         if (i>endRow) break;
                      } //end if check rs
                } // end for
           

           while (line<displayLine) {
               line++;               
                %>
	              <tr height="25"> 
	                <td width="29%" class="dotline ; item">&nbsp;</td>
	                <td width="42%" class="dotline ; item">&nbsp;</td>
	                <td width="29%" class="dotline ; item">&nbsp;</td>
	              </tr>                 
                <%               
           }
        %>              
              
            </table></td>
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
          <td width="100%" align="right"><%=pageLink%></td>
        </tr>
      </table>






<br style="font-size:10pt">



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">

            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
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

</HTML>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_BOQCode.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (stmt != null) stmt.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>