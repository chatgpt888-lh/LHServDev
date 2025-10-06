<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<% 
  	 //----============ Declare Variables for search data ===========----//
   	String searchType = doString.checkString(request.getParameter("search_type"),"");    
   	String nItmJob = doString.checkString(request.getParameter("n_itmjob"),"");    
   	String iGroup = doString.checkString(request.getParameter("i_group"),"");    
   	String iType = doString.checkString(request.getParameter("i_type"),"");    
 	String nGroup = doString.checkString(request.getParameter("n_group"),"");
	String nType = doString.checkString(request.getParameter("n_type"),"");
	String iItm = doString.checkString(request.getParameter("i_itmjob"),"");
	String nItm = doString.checkString(request.getParameter("n_itmjob"),""); 
 	String dKeyin = doString.checkString(request.getParameter("d_keyin"),"");
 	String del = doString.checkString(request.getParameter("del_checkbox"),"");
 
    //----============ Declare Variables for data ===========----//
    String mode = doString.checkString(request.getParameter("mode"),"");
 	String iSeq = doString.checkString(request.getParameter("i_seq"),"");
    String sequen = iGroup+iType+iSeq;
    String zWangUnit = doString.checkString(request.getParameter("z_wage_unit"),"-");
    String zGoodUnit = doString.checkString(request.getParameter("z_good_unit"),"");
    String nCount = doString.checkString(request.getParameter("n_count"),"");
	String account = "";
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	SERV_CommonData com = null;
		
	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();   
		com = new SERV_CommonData(conn);  
		     
        //----=======================================----//	
        
        //-----================ Generate Condition  ===============----//
	      String condition = "";
       //-----========== Query for search by ID ===============-----//
	       condition = " WHERE a.i_seq != '0000' AND a.i_group = '"+iGroup+"'";
	       if (iType.equalsIgnoreCase("ALL")) {
	          condition += " AND a.i_type != '00'";
	       } else {
	          condition += " AND a.i_type = '"+iType+"'";
	       }
			condition += " AND a.i_seq != '0000' and a.i_itmtype != '03' and (a.f_cancel = 'N' or a.f_cancel is null) ";
	   //-----=============================== Count Row ================================-----//
	   int maxRow = 0;
       sql.delete(0,sql.length());	   
       sql.append(" SELECT COUNT(*) CNT FROM lan:serv_infboq a")
             .append(" LEFT JOIN lan:serv_infboq b ON b.i_group = a.i_group AND b.i_type = '00' AND b.i_seq = '0000'")
             .append(" LEFT JOIN lan:serv_infboq c ON c.i_group = a.i_group AND c.i_type = a.i_type AND c.i_seq = '0000'")
             .append(condition);
        rs = stmt.executeQuery(sql.toString());
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
   if (displayLine<Constants.SERV_BOQSEARCH_LINE) displayLine = Constants.SERV_BOQSEARCH_LINE;      
   
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
<TITLE>ข้อมูลพื้นฐาน : 05
ข้อมูลราคา BOQ สาธารณูฯจากส่วนกลาง</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">

function deleteData() {
    if (confirm("คุณต้องการลบข้อมูลที่ทำการเลือกทั้งหมดนี้ ?")) {
       document.forms[0].action = "<%=Constants.APP_PATH%>/SERV_INFBOQServlet?mode=delete&i_itmjob=<%=iItm%>"; 
       document.forms[0].submit();
    } 
}

function searchBOQ(){
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFBOQ01.jsp";
     document.forms[0].submit();  
  }

function  checkAll(obj,mainCheck,subCheck) {
     var main = document.forms[0].elements[mainCheck];
     var sub = document.forms[0].elements[subCheck];
     
     if (obj!=null && main!=null && sub!=null) {
     
         var checkObj = document.forms[0].elements["check_"+obj.value];
         if (checkObj!=null && obj.checked) {
            checkObj.value = "checked";
         } else {
            if (checkObj!=null) checkObj.value = "";
         }
     
         if (obj.name==mainCheck) {
		    if (sub.length!=null) {
				for (var i=0;i<sub.length;i++) {
					  sub[i].checked = obj.checked;
				}
			} else {
			   sub.checked = obj.checked;
			}
         } else {
		    if (sub.length!=null) {
			    var flag = true;
				for (var i=0;i<sub.length;i++) {
					  flag = sub[i].checked;
					  if (!flag) break;
				}
				main.checked = flag;
			} else {
			   main.checked = obj.checked;
			} // end if check sub
         } // end if check mainCheck
     } // end if check null
  } 
 
 function changeGroup() {
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFBOQ01.jsp";
     document.forms[0].submit();
  } 
 
 function changePage(page) {  
 	 document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFBOQ01.jsp";
     document.forms[0].submit();
  } 
  

function func_1(thisObj, thisEvent) {
//use 'thisObj' to refer directly to this component instead of keyword 'this'
//use 'thisEvent' to refer to the event generated instead of keyword 'event'

}</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM action="" method="get">

<input type="hidden" name="now_page" value="<%=nowPage%>">
<input type="hidden" name="d_keyin" value="<%=dKeyin%>">
<input type="hidden" name="mode" value="delete">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr onclick="return func_1(this, event);">
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ข้อมูลพื้นฐาน</td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">ข้อมูลราคา BOQ สาธารณูฯจากส่วนกลาง</td>
                <td class="item_tab3"></td>
                <td>&nbsp;<input type="radio" value="L" checked name="display_type" >แสดงจำนวนรายการต่อหน้า&nbsp;
                  <input type="text" name="display_line" class="boxC" style="width:50px" value="<%=displayLine%>">&nbsp;
                  รายการ&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" value="A" name="display_type">
                  แสดงรายการทั้งหมด&nbsp;&nbsp;&nbsp;&nbsp;
                  <a href="#" onclick="changePage(1);"><img border="0" src="images/bu_R.gif" align="absmiddle" style="cursor:hand" width="16" height="16"></a>
                  </td>               
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
    <td class="item ; dotline01" height="22" width="15%">รหัสหมวด
      :</td>
    <td height="22" width="35%" class="dotline01">
       <%=com.genINFBOQGroupList("i_group",iGroup," size='1' class='box' style='width:200px' onchange='changeGroup();'" )%>
    </td>
    <td height="22" class="item ; dotline01" width="15%" >ตำแหน่ง/ที่ตั้ง
      :</td>
    <td height="22" width="35%" class="dotline01">
       <%=com.genINFBOQTypeList("i_type", iGroup,iType, " size='1' class='box' style='width:200px'")%>
    &nbsp;&nbsp;&nbsp;&nbsp; <img border="0" src="images/bu_go.gif"  align="absmiddle" width="40" height="22" onclick="searchBOQ();" style='cursor:hand'></td>
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


<br style="font-size:2pt">


      


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
          <td class="col_name" rowspan="2" width="2%"><input type="checkbox" name="main_check" onclick="checkAll(this,'main_check','del_checkbox');"></td>
          <td class="col_name" rowspan="2" width="15%">หมวด</td>
          <td class="col_name" rowspan="2" width="8%">ตำแหน่ง</td>
          <td class="col_name" rowspan="2" width="30%">ชื่อรายละเอียดการซ่อม</td>
          <td class="col_name" rowspan="2" width="7%">ค่าแรงต่อหน่วย</td>
          <td class="col_name" rowspan="2" width="7%">ค่าของต่อหน่วย</td>
          <td class="col_name" rowspan="2" width="7%">หน่วยนับ</td>
          <td class="col_name" colspan="2">กทม.ใหม่</td>
          <td class="col_name" colspan="2">ปริมณฑลใหม่</td>          <td class="col_name" colspan="2">โครงการเก่า</td>
        </tr>  <tr> 
	<td class="col_name">บริษัท</td>  
	<td class="col_name">ลูกบ้าน</td>  	
	<td class="col_name">บริษัท</td>  
	<td class="col_name">ลูกบ้าน</td>  	
	<td class="col_name">บริษัท</td>  
	<td class="col_name">ลูกบ้าน</td>  	
  </tr>
           <%
		        int line = 0;		     
		        sql.delete(0,sql.length());
		        sql.append("SELECT FIRST ").append(endRow).append(" b.n_itmjob AS N_GROUP, c.n_itmjob AS N_TYPE, a.* FROM lan:serv_infboq a ")
		             .append(" LEFT JOIN lan:serv_infboq b ON b.i_group = a.i_group AND b.i_type = '00' AND b.i_seq = '0000'")
		             .append(" LEFT JOIN lan:serv_infboq c ON c.i_group = a.i_group AND c.i_type = a.i_type AND c.i_seq = '0000'")
		              .append(condition);
		        rs = stmt.executeQuery(sql.toString());
		        for (int i=0;i<maxRow;i++) { 
                      if (rs.next()) {
                         if (i>=startRow && i<=endRow) {	
                         	 iGroup = doString.checkString(rs.getString("i_group"),"");    
					         nGroup = doString.checkString(doString.DisplayThai(rs.getString("n_group")),"");
					         nType = doString.checkString(doString.DisplayThai(rs.getString("n_type")),"");
					         iItm = doString.checkString(rs.getString("i_itmjob"),"");
					         nItm = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")),"");                         
                             zWangUnit = doString.checkString(doString.DisplayThai(rs.getString("z_wage_unit")),"");
                             zGoodUnit = doString.checkString(doString.DisplayThai(rs.getString("z_good_unit")),"");   
                             nCount = doString.checkString(doString.DisplayThai(rs.getString("n_count")),"-");   
                             account = doString.checkString(doString.DisplayThai(rs.getString("i_account")),"12345");   
		                    %>
		                    
		     <tr height="25px">
			   	<td width="2%" align="center" class="dotline"><input type="checkbox" name="del_checkbox"  value="<%=iItm%>" onclick="checkAll(this,'main_check','del_checkbox');"></td>
			   	<td class="dotline" width="15%"><%=nGroup%></td>
				<td class="dotline" width="8%"><%=nType%></td>
				<td class="dotline" width="30%"><a href="SERV_INFBOQ02.jsp?mode=edit&i_itmjob=<%=iItm%>"><%=nItm%></a></td>
				<td class="dotline" width="7%" align='right'><%=zWangUnit%>&nbsp; </td>
          		<td class="dotline" width="7%" align='right'><%=zGoodUnit%>&nbsp; </td>
          		<td class="dotline" width="7%" align='center'><%=nCount%></td>
          		<td class="dotline" width="4%" align='center'><%=doString.checkString(rs.getString("i_com_acc1"),"-")%></td>          		<td class="dotline" width="4%" align='center'><%=doString.checkString(rs.getString("i_cus_acc1"),"-")%></td>
          		<td class="dotline" width="4%" align='center'><%=doString.checkString(rs.getString("i_com_acc2"),"-")%></td>
          		<td class="dotline" width="4%" align='center'><%=doString.checkString(rs.getString("i_cus_acc2"),"-")%></td>
          		<td class="dotline" width="4%" align='center'><%=doString.checkString(rs.getString("i_com_acc3"),"-")%></td>
          		<td class="dotline" width="4%" align='center'><%=doString.checkString(rs.getString("i_cus_acc3"),"-")%></td>
			</tr> 
      
        <%
		     line++;                         
             } // end if check row
               if (i>endRow) break;
                } //end if check rs
              } // end for
           
           String msg = "";
           if (line==0) msg = "<center>ไม่พบข้อมูล !!</center>";
           
           while (line<displayLine) {
               line++;               
                %>
        <tr>
          <td align="center" class="dotline" width="2%"  valign="top">&nbsp;</td>
          <td align="left"   class="dotline" width="15%" valign="top">&nbsp;</td>
          <td align="left"   class="dotline" width="8%" valign="top">&nbsp;</td>
          <td align="left"   class="dotline ; item" width="30%" valign="top"><%=((line==4 && msg.length()>0) ? msg : "&nbsp;")%></td>
          <td align="right"  class="dotline" width="7%" valign="top">&nbsp;</td>
          <td align="right"  class="dotline" width="7%" valign="top">&nbsp;</td>
          <td align="center" class="dotline" width="7%" valign="top">&nbsp;</td>
          <td align="center" class="dotline" width="4%" valign="top">&nbsp;</td>
          <td align="center" class="dotline" width="4%" valign="top">&nbsp;</td>                    <td align="center" class="dotline" width="4%" valign="top">&nbsp;</td>
          <td align="center" class="dotline" width="4%" valign="top">&nbsp;</td>          
          <td align="center" class="dotline" width="4%" valign="top">&nbsp;</td>
          <td align="center" class="dotline" width="4%" valign="top">&nbsp;</td>          

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
            <td width="150" class="act_tab2">

            <a href="SERV_INFBOQ02.jsp?mode=add"><img border="0" src="images/act_add.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp; 
             <a href="#" onclick="deleteData();"><img border="0" src="images/act_delete.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>

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
		System.out.println("ERROR SERV_INFBOQ01.jsp : " + e.getMessage());
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