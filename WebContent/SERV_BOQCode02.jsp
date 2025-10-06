<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>

<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
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
String jName = "SERV_BOQCode02.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

	doString str = new doString();

	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	SERV_CommonData common = null;
	

   //-----========= Declare Variables for Approve Page ===========----//
   String mode = doString.checkString(request.getParameter("mode"),"");
   String iRefNo = doString.checkString(request.getParameter("i_refno"),"");
   String cRemark = doString.checkString(request.getParameter("c_remark"),"");
   String iGroup[] = new String[] {"","","","",""};
   String iType[] = new String[] {"","","","",""};
   String iItmJob[] = new String[] {"","","","",""};
   String nItmJob[] = new String[] {"","","","",""};
   String reqName = "";
   String reqId = "";
   String dKeyIn = "";
   
   for (int i=0;i<5;i++) {
         iGroup[i] = doString.checkString(request.getParameter("i_group_"+(i+1)),"");
         iType[i] = doString.checkString(request.getParameter("i_type_"+(i+1)),"");
         iItmJob[i] = doString.checkString(request.getParameter("i_itmjob_"+(i+1)),"");
   }
   
	   
	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();       
		common = new SERV_CommonData(conn); 
        //----=======================================----//   
        
        
        //---============= Get Description from BOQ Request ==============----//
        sql.delete(0,sql.length());
        sql.append(" select trim(b.n_prename_th)||trim(n_nemploy_th)||' '||trim(n_semploy_th) n_employ , ")
              .append(" a.*  from lan:serv_noboq a ")
              .append(" left join docflow:acemploy b on b.i_employ=a.i_employ_req ")
              .append(" where a.i_refno='").append(iRefNo).append("' ");
		servlog.startLog(sql.toString());
        rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
        if (rs.next()) {
            reqName = doString.checkString(doString.DisplayThai(rs.getString("n_employ")),"");
            reqId = doString.checkString(rs.getString("i_employ_req"),"");
            dKeyIn = "-";             
			Timestamp tmp = rs.getTimestamp("d_keyin");
			if (tmp!=null) {
			    Calendar cal = Calendar.getInstance();
			    cal.setTime(tmp);    			
			    dKeyIn = getDateFromCalendar(cal);
		    } 
		    
		    //---======== Get Request Item from 1 - 5 =============---//
		    for (int i=0;i<5;i++) {
		           nItmJob[i] = doString.checkString(doString.DisplayThai(rs.getString("c_desc"+(i+1))),"");
		    }
        }
        rs.close();

%>
<HTML>
<HEAD>
<TITLE>ขอรหัส BOQ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--

  function refreshPage() {
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_BOQCode02.jsp";
     document.forms[0].submit();
  }   
  
  function approveData() {
     for (var i=1;i<=5;i++) {
           var obj = document.forms[0].elements("i_itmjob_"+i);
           if (obj!=null && obj.value=="") {
               alert("กรุณาระบุรายการซ่อมจาก BOQ !");
               obj.focus();
               return false
           }
     }
  
     document.forms[0].mode.value="APPROVE";
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_BOQCodeApproveServlet";
     document.forms[0].submit();
  } 
  
  function denyData() {
      if (document.forms[0].c_remark.value.length<=0) {
         alert("กรุณากรอกหมายเหตุ !");
	 return false;
      }

      if (confirm("คุณแน่ใจว่าต้องการ Deny รายการขออนุมัตินี้ ?")) {
          document.forms[0].mode.value="DENY";
          document.forms[0].action="<%=Constants.APP_PATH%>/SERV_BOQCodeApproveServlet";
          document.forms[0].submit();
      }
  }     

//-->
</script>


<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">


<input type="hidden" name="mode" value="APPROVE">
<input type="hidden" name="i_refno" value="<%=iRefNo%>">
<input type="hidden" name="req_id" value="<%=reqId%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ขอรหัส BOQ</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดการขอรหัส
                  BOQ</td>
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
    <td class="item ; dotline01" height="22" width="10%">ผู้ขออนุมัติ
      :</td>
    <td height="22" width="42%" class="dotline01"><%=reqName%></td>
    <td height="22" width="7%" class="item ; dotline01">วันที่ :</td>
    <td height="22" width="20%" class="dotline01"><%=dKeyIn%></td>
    <td height="22" class="item ; dotline01" width="8%">Ref No. :</td>
    <td height="22" width="13%" class="dotline01"><%=iRefNo%></td>
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
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายการงานแจ้งซ่อม</td>
                <td class="item_tab3"></td>
                <td >&nbsp;</td>
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
    <td width="100%" class="frmL" align="center">
    
    
<table border="0" width="100%" cellspacing="0" cellpadding="0">
   <tr>
	    <td width="10%" class="col_name">Item</td>
	    <td width="30%" class="col_name">รายละเอียด</td>
	    <td width="60%" class="col_name">รายการ  BOQ</td>
	    <!--
	    <td width="20%" class="col_name">หมวด</td>
	    <td width="20%" class="col_name">ตำแหน่ง</td>
	    <td width="20%" class="col_name">รายการซ่อม</td>
	    -->
   </tr>
  <%
     for (int i=0;i<5;i++) {
              if (nItmJob[i].trim().length()>0) {
				  %>  
				  <tr height="25">
				    <td width="10%" class="item ; side01" align="left" height="25">รายการที่ <%=(i+1)%> :</td>
				    <td width="30%" class="side01" height="25"><%=nItmJob[i]%></td>
				    <td width="20%" class="side01" align="left" height="25">
					    <%=common.genBOQGroupList("i_group_"+(i+1),iGroup[i],"  class='box' style='width:285' onchange='refreshPage();' ")%>&nbsp;
					    <%=common.genBOQTypeList("i_type_"+(i+1),iGroup[i],iType[i],"  class='box' style='width:285' onchange='refreshPage();' ",false)%>
				    </td>
                  </tr><tr>				    
				    <td width="10%" class="item ; dotline" align="left" height="25">&nbsp;</td>
				    <td width="30%" class="dotline" height="25">&nbsp;</td>
				    <td width="20%" class="dotline" align="left" height="25"><%=common.genBOQItemList("i_itmjob_"+(i+1),iGroup[i],iType[i],iItmJob[i],"  class='box' style='width:576' ")%></td>
				  </tr>
				  <%
			  } else {
			  	  %>
				  <tr height="25">
				    <td width="10%" class="item ; dotline" align="left" height="25">&nbsp;</td>
				    <td width="30%" class="dotline" height="25">&nbsp;</td>
				    <td width="60%" class="dotline" align="center" height="25">&nbsp;</td>
				  </tr>			  	  
			  	  <%	
			  }
     } // end for
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
    <td width="100%" class="frmLRpad01"><textarea rows="5" name="c_remark" class="box" style="width:100%" cols="20"><%=cRemark%></textarea></td>
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
            <td width="150" class="act_tab2">

            <img border="0" src="images/act_approve.gif" onclick="approveData();"
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">&nbsp; 
	
	   <img border="0" src="images/act_deny.gif" onclick="denyData();"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">
            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_BOQCode.jsp" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>  
        </table>  






          </td>
        </tr>
      </table>

			
			

<br style="font-size:30pt">

<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
  <tr><td width="100%" class="copyright" align="center">
  Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer
  version 5 และ 5.5  
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