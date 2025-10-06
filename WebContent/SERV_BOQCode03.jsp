<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>

<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.sql.Date" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*"%>
<%@ page import="serv.util.ServLog" %>

<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>


<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_BOQCode03.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

	doString str = new doString();
		

	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	SERV_CommonData common = null;
	
	   
	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();       
		stmt1 = conn.createStatement();       
		common = new SERV_CommonData(conn); 
        //----=======================================----//   
        

		
		//----=================== Create Condition =========================----//        
	    String iRefNo = doString.checkString(request.getParameter("i_refno"),"");    
	    String remark = "&nbsp;";
	    String condition = "";        
        if (iRefNo.length()>0) {
           condition = " and i_refno='"+iRefNo+"' "; 
        }
        
	   
	   //-----=============================== Count Row ================================-----//
       int maxRow = 0;
       sql.delete(0,sql.length());	   
	   sql.append(" select sum( ")
	      .append(" (case when length(c_desc1)>0 then 1 else 0 end)+ ")
	      .append(" (case when length(c_desc2)>0 then 1 else 0 end)+ ")
	      .append(" (case when length(c_desc3)>0 then 1 else 0 end)+ ")
	      .append(" (case when length(c_desc4)>0 then 1 else 0 end)+ ")
	      .append(" (case when length(c_desc5)>0 then 1 else 0 end) ")
	      .append(" ) sum_item from serv_noboq ")
	      .append(" where (d_keyin between (today-30) and today) ")
	      //.append(" and d_approve is not null ")
	      .append(condition);
		servlog.startLog(sql.toString());
        rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
        if (rs.next()) {        
           maxRow = rs.getInt("sum_item");  
        }
        rs.close();


	if (iRefNo.trim().length()<=0) {
	       //------ If not Specified i_refno from mail  , count new boq ------//
	       sql.delete(0,sql.length());	   
	       sql.append(" select count(*) cnt from serv_boq ")
		     .append(" where (d_keyin between (today-30) and today) ");
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		if (rs.next()) {        
		   maxRow += rs.getInt("cnt");  
		}
		rs.close();
	}
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
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_BOQCode03.jsp";
     document.forms[0].submit();
  }   

//-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">

<input type="hidden" name="now_page" value="<%=nowPage%>">
<input type="hidden" name="i_refno" value="<%=iRefNo%>">

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
                <td class="item_tab2" width="200">รายการ BOQ ที่เพิ่มใหม่จากส่วนกลาง</td>
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
    <td width="100%" class="frmL">
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr height="25">
          <td width="15%" class="col_name">ผู้ขอ</td>
          <td width="21%" class="col_name">รายการที่ขอ</td>
          <td width="15%" class="col_name">หมวด</td>
          <td width="15%" class="col_name">ตำแหน่ง</td>
          <td width="18%" class="col_name">รายการ</td>
          <td width="12%" class="col_name">สถานะ</td>
        </tr>
        
        <%
		        int line = 0;
		        int cnt = 0;
		        sql.delete(0,sql.length());
 		        sql.append(" select a.* , trim(b.n_prename_th)||trim(n_nemploy_th)||' '||trim(n_semploy_th) n_employ ")
	               .append(" from lan:serv_noboq a ")
	               .append(" left join docflow:acemploy b on b.i_employ=a.i_employ_req ")
		       .append(" where (d_keyin between (today-30) and today) ")
	               //.append(" and a.d_approve is not null ")
		       .append(condition)
	               .append(" order by a.d_keyin desc ");
				servlog.startLog(sql.toString());
		        rs = stmt.executeQuery(sql.toString());
				servlog.endLog();

				while (rs.next()) {
			        String refId = str.createID(rs.getInt("i_refno"),4);
			        String nEmploy = doString.checkString(doString.DisplayThai(rs.getString("n_employ")),"-");	
			        remark = doString.checkString(doString.DisplayThai(rs.getString("c_remark")),"&nbsp;");	

					//---============ Extract Field i_itmjob1-5 to Rows ================---//
			        for (int i=1;i<=5;i++) { 			            
			                String iItmJob = doString.checkString(rs.getString("i_itmjob"+i),"");
				        String noBoq = doString.checkString(doString.DisplayThai(rs.getString("c_desc"+i)),"");
					Date dApprove = rs.getDate("d_approve");
					Date dReject = rs.getDate("d_reject");

			            if (noBoq.length()>0) {
				            String nGroup = "-";
				            String nType = "-";
				            String nItmJob = "-";
				            String status = "-";
				            

					    if (iItmJob.length()>0) {
						    sql.delete(0,sql.length());
						    sql.append(" select b.n_itmjob n_group,c.n_itmjob n_type,a.* from serv_boq a ")
						       .append(" left join serv_boq b on b.i_group=a.i_group and b.i_group is not null ")
						       .append(" and (b.i_type is null or b.i_type='') and (b.i_seq is null or b.i_seq='') ")
						       .append(" left join serv_boq c on c.i_group=a.i_group and c.i_type=a.i_type ")
						       .append(" and c.i_group is not null and c.i_type is not null and (c.i_seq is null or c.i_seq='') ")
						       .append(" where a.i_itmjob='").append(iItmJob).append("' ");
							servlog.startLog(sql.toString());
						    rs1 = stmt1.executeQuery(sql.toString());
							servlog.endLog();
						    if (rs1.next()) {
						       nGroup = doString.checkString(rs1.getString("n_group"),"-");
						       nType = doString.checkString(rs1.getString("n_type"),"-");
						       nItmJob = doString.checkString(rs1.getString("n_itmjob"),"-");
						    }
						    rs1.close();
					    } // end if check iItmJob


					    if (dApprove==null && dReject==null) status = "รอการอนุมัติ";
					    if (dApprove!=null && dReject==null) status = "อนุมัติแล้ว";
					    if (dApprove==null && dReject!=null) status = "ปฏิเสธ";


		                    if (cnt>=startRow && cnt<endRow) {	                       
			                    %>
								<tr height="25">
								  <td width="15%" class="dotline ; item" align="center"><%=nEmploy%></td>
								  <td width="21%" class="dotline ; item"><%=noBoq%></td>
								  <td width="15%" class="dotline ; item"><%=nGroup%></td>
								  <td width="15%" class="dotline ; item"><%=nType%></td>
								  <td width="18%" class="dotline ; item"><%=nItmJob%></td>
								  <td width="12%" class="dotline ; item" align="center"><%=status%></td>
								</tr>				                      
			                    <%			                    
		 					    line++;                         
		                    } // end if check row
		                      
		                    cnt++;	                         
		                    if (cnt>endRow) break;
	                    }

	                 } // end for 1-5 to get field
                
                  } // end while main data
           



		if (iRefNo.trim().length()<=0) {
			//--------------  If Not Specified i_refno from mail , Select New Record from SERV_BOQ -----------------//
		        sql.delete(0,sql.length());
 		        sql.append(" select b.n_itmjob n_group,c.n_itmjob n_type,a.* from serv_boq a ")
			      .append(" left join serv_boq b on b.i_group=a.i_group and b.i_group is not null ")
			      .append(" and (b.i_type is null or b.i_type='') and (b.i_seq is null or b.i_seq='') ")
			      .append(" left join serv_boq c on c.i_group=a.i_group and c.i_type=a.i_type ")
			      .append(" and c.i_group is not null and c.i_type is not null ")
			      .append(" and (c.i_seq is null or c.i_seq='') ")
		              .append(" where (a.d_keyin between (today-30) and today) ")
	                      .append(" order by a.i_itmjob ");
				servlog.startLog(sql.toString());
		        rs = stmt.executeQuery(sql.toString());
				servlog.endLog();

			while (rs.next()) {
			            String nGroup = doString.checkString(doString.DisplayThai(rs.getString("n_group")),"-");
			            String nType = doString.checkString(doString.DisplayThai(rs.getString("n_type")),"-");
			            String nItmJob = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")),"-");

		                    if (cnt>=startRow && cnt<endRow) {	                       
			                    %>
								<tr height="25">
								  <td width="15%" class="dotline ; item" align="center">-</td>
								  <td width="21%" class="dotline ; item">-</td>
								  <td width="15%" class="dotline ; item"><%=nGroup%></td>
								  <td width="15%" class="dotline ; item"><%=nType%></td>
								  <td width="18%" class="dotline ; item"><%=nItmJob%></td>
								  <td width="12%" class="dotline ; item" align="center">รายการใหม่</td>
								</tr>				                      
			                    <%			                    
		 			    line++;                         
		                    } // end if check row
		                      
		                    cnt++;	                         
		                    if (cnt>endRow) break;
                
                         } // end while boq data

		 }  // end if check iRefNo



           while (line<displayLine) {
               line++;               
                %>
		        <tr height="25">
		          <td width="15%" class="dotline ; item">&nbsp;</td>
		          <td width="15%" class="dotline ; item">&nbsp;</td>
		          <td width="18%" class="dotline ; item">&nbsp;</td>
		          <td width="21%" class="dotline ; item">&nbsp;</td>
		          <td width="15%" class="dotline ; item">&nbsp;</td>
		          <td width="12%" class="dotline ; item">&nbsp;</td>
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



<%
   if (iRefNo.trim().length()>0) {
%>
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">หมายเหตุ</td>
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
    <td width="100%" height="100" class="frmLR" align="left" valign="top">
     <%=remark%>
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

<%
   } // end if check jobList
%>


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
		System.out.println("ERROR SERV_BOQCode03.jsp : " + e.getMessage());
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