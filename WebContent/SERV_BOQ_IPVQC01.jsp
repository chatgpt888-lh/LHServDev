<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%-- 
/**********************************************/
 * create by : pradoem wonkraso
 * date time: 2014.10.13
 * Extenstion from : SERV_BOQ01.jsp
 * version :1.0
 * project Name : IPV_QC  BOQ
 * description :Master Data
***************************************************/
--%>
<%!
    
	//Add by pradoem	==========================================================================================//
	//public String genIPV_BOQTypeList(String name, String iGroup, String value, String params) {
	//	 return  genIPV_BOQTypeList(name,iGroup,value,params,true);
	//}
	//==========================================================================================//
	public String genIPV_BOQTypeList(Connection conn,String name,String iGroup,String value,String params,boolean allType) {
		 StringBuffer html = new StringBuffer();
		 StringBuffer sql = new StringBuffer();
		 Statement stmt = null;
		 ResultSet rs = null;
		 //boolean allProject = false;
	     
		 try {
			stmt = conn.createStatement();
		 	
			 sql.append(" Select i_group,i_type,n_itmjob,i_itmjob  From lan:ipv_qcboq ")
			 	.append("  Where i_group ='").append(iGroup).append("'")
			   .append("  and i_type is not null  ")
			   .append("  and i_seq is null  ")
			   .append(" Order by i_group,i_type,n_itmjob ");
			 rs = stmt.executeQuery(sql.toString());

			 //-------============== Generate List box ===================------//
			 html.append("<select name='").append(name).append("' ").append(params).append(" >");		  
			 html.append("<option value=''>"+Constants.LISTBOX_SELECT_LABEL+"</option>");
		     		        		     
			 int line = 0;
			 while (rs.next()) {
				String iType = doString.checkString(rs.getString("i_type"),"");
				String nItmJob = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")),"");
				String selected = "";
				if (value!=null && iType.equalsIgnoreCase(value)) {
				   selected = " selected "; 
				}	
	        
				//--=================== Set All Type Option to Listbox ===================---//
				if (line==0 && allType) html.append("<option value='ALL' "+(value.equalsIgnoreCase("ALL") ? "selected" : "")+">"+Constants.LISTBOX_ALLTYPE_LABEL+"</option>");	        
				
				html.append("<option value='").append(iType).append("' ").append(selected).append(">")
						.append(iType+"-"+nItmJob).append("</option>");	
				line++;	         
			 } // end while		     
			 html.append("</select>");
			 //----=====================================================----//
		           		     
			 rs.close();
			 stmt.close();

		 } catch (Exception e) {
			 System.out.println(" genBOQTypeList Error : "+e.getMessage());
		 } finally {
			 try {
				if (rs!=null) rs.close();
				if (stmt!=null) stmt.close();
			 } catch (Exception ex) {}
		 }     
		return html.toString();		 
	}	
	

	//Create by pradoem 2014.10.20 For Group items
	public String genIPV_BOQGroupList(Connection conn,String name,String value,String params) {
		 StringBuffer html = new StringBuffer();
		 StringBuffer sql = new StringBuffer();
		 Statement stmt = null;
		 ResultSet rs = null;

		 try {
			stmt = conn.createStatement();
	 	
			 sql.append(" Select i_group,n_itmjob,i_itmjob From lan:ipv_qcboq ")
			   .append("  Where i_group is not null    ")
			   .append("  and i_type is  null  ")
			   .append("  and i_seq is null  ")
			   .append(" Order by i_group,n_itmjob ");
			 rs = stmt.executeQuery(sql.toString());
		     

			 //-------============== Generate List box ===================------//
			 html.append("<select name='").append(name).append("' ").append(params).append(" >");	
			 html.append("<option value=''>"+Constants.LISTBOX_SELECT_LABEL+"</option>");
		     	     		     
			 while (rs.next()) {
				String iGroup = doString.checkString(rs.getString("i_group"),"");
				String nItmJob = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")),"");
				String selected = "";
				if (value!=null && iGroup.equalsIgnoreCase(value)) {
				   selected = " selected "; 
				}		        
		        
				html.append("<option value='").append(iGroup).append("' ").append(selected).append(">")
						.append(iGroup+"-"+nItmJob).append("</option>");		        
			 } // end while		     
			 html.append("</select>");
			 //----=====================================================----//
		           		     
			 rs.close();
			 stmt.close();

		 } catch (Exception e) {
			 System.out.println(" genBOQGroupList Error : "+e.getMessage());
		 } finally {
			 try {
				if (rs!=null) rs.close();
				if (stmt!=null) stmt.close();
			 } catch (Exception ex) {}
		 }	     
		return html.toString();		 
	}	
%>
<% 
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_BOQ_IPVQC01.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);
  	 //----============ Declare Variables for search data ===========----//
   	//String searchType = doString.checkString(request.getParameter("search_type"),"");    
   	//String nItmJob = doString.checkString(request.getParameter("n_itmjob"),"");    
   	String iGroup = doString.checkString(request.getParameter("i_group"),"");    
   	String iType = doString.checkString(request.getParameter("i_type"),"");    
 	String nGroup = doString.checkString(request.getParameter("n_group"),"");
	String nType = doString.checkString(request.getParameter("n_type"),"");
	String iItm = doString.checkString(request.getParameter("i_itmjob"),"");
	String nItm = doString.checkString(request.getParameter("n_itmjob"),""); 
 	String dKeyin = doString.checkString(request.getParameter("d_keyin"),"");
 	//String del = doString.checkString(request.getParameter("del_checkbox"),"");
 
    //----============ Declare Variables for data ===========----//
    //String mode = doString.checkString(request.getParameter("mode"),"");
 	//String iSeq = doString.checkString(request.getParameter("i_seq"),"");
    //String sequen = iGroup+iType+iSeq;
    String zWangUnit = doString.checkString(request.getParameter("z_wage_unit"),"-");
    String zGoodUnit = doString.checkString(request.getParameter("z_good_unit"),"");
    String nCount = doString.checkString(request.getParameter("n_count"),"");  
    
    String inOut = doString.checkString(request.getParameter("intOut"),""); 
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
		//com = new SERV_CommonData(conn);  
		     
        //----=======================================----//	     
        //-----================ Generate Condition  ===============----//
	      String condition = "";
       //-----========== Query for search by ID ===============-----//
	       condition = " where a.i_seq is not null and a.i_group = '"+iGroup+"' ";
	       if (iType.equalsIgnoreCase("ALL")) {
	          condition += " and ((a.i_group is not null and a.i_group<>'') and (a.i_type is not null and a.i_type<>'') and (a.i_seq is not null and a.i_seq<>'')) ";
	       } else {
	          condition += " and a.i_type = '"+iType+"' ";
	       }
			 //condition += " and a.i_seq[1,1] != 'C' ";		
			 condition += " and a.i_seq[1,1] not in ('C','N','E') ";   
	   //-----=============================== Count Row ================================-----//
	   int maxRow = 0;
       sql.delete(0,sql.length());	   
       sql.append(" select count(*) cnt from lan:ipv_qcboq a ")
             .append(" left join lan:ipv_qcboq b on b.i_group=a.i_group and  (b.i_group is not null) and ((b.i_type is null) or (b.i_type='')) and ((b.i_seq is null) or (b.i_seq='')) ")
             .append(" left join lan:ipv_qcboq c on c.i_group=a.i_group and c.i_type=a.i_type and (c.i_group is not null) and (c.i_type is not null) and ((c.i_seq is null) or (c.i_seq='')) ")
             .append(condition);
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
<TITLE>ข้อมูลพื้นฐาน : List ข้อมูลราคา BOQ งานซ่อมก่อนโอน</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<style type="text/css">
 .box2 {  font-family: Tohama,Arial,sans-serif; font-size:10.1pt; font-weight:normal;
		padding-top: 1px; padding-right: 1px; padding-bottom: 1px; padding-left: 1px; 
	 	color:#165396; background-color: white; border: 1px #BEDCFF solid ; 
}
</style>
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
function deleteData() {
    if (confirm("คุณต้องการลบข้อมูลที่ทำการเลือกทั้งหมดนี้ ?")) {
       document.forms[0].mode.value="delete";
	   document.forms[0].i_itmjob.value="<%=iItm%>"; //20140100600002
       document.forms[0].action = "<%=Constants.APP_PATH%>/SERV_BOQ_IPVQCServlet?mode=delete&i_itmjob=<%=iItm%>"; 
       document.forms[0].submit();
    } 
}

function searchBOQ(){
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_BOQ_IPVQC01.jsp";
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
 
 function doEdit(itemJob) {
     document.forms[0].mode.value= "edit";
	 document.forms[0].i_itmjob.value = itemJob; //20140100600002
	 document.forms[0].action="<%=Constants.APP_PATH%>/SERV_BOQ_IPVQC02.jsp?mode=edit&i_itmjob="+itemJob;
	 document.forms[0].submit();
 }

 function changeGroup() {
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_BOQ_IPVQC01.jsp";
     document.forms[0].submit();
  } 
 
 function changePage(page) {  
 	 document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_BOQ_IPVQC01.jsp";
     document.forms[0].submit();
  } 
  
function func_1(thisObj, thisEvent) {
//use 'thisObj' to refer directly to this component instead of keyword 'this'
//use 'thisEvent' to refer to the event generated instead of keyword 'event'
}

</script>

<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM action="" method="get">
<input type="hidden" name="now_page" value="<%=nowPage%>">
<input type="hidden" name="d_keyin" value="<%=dKeyin%>">
<input type="hidden" name="mode" value="delete">
<input type="hidden" name="i_itmjob" value="">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr onclick="return func_1(this, event);">
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;ข้อมูลพื้นฐาน</td>
        </tr>
      </table>
<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">List ข้อมูลราคา BOQ งานซ่อมก่อนโอน</td>
                <td class="item_tab3"></td>
                <td>&nbsp;<input type="radio" value="L" checked name="display_type" >แสดงจำนวนรายการต่อหน้า&nbsp;
                  <input type="text" name="display_line" class="boxC" style="width:50px" value="<%=displayLine%>">
                  &nbsp;รายการ&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" value="A" name="display_type"> แสดงรายการทั้งหมด&nbsp;&nbsp;&nbsp;&nbsp;
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
       <%=genIPV_BOQGroupList(conn,"i_group",iGroup," size='1' class='box2' style='width:200px' onchange='changeGroup();'" )%>
    </td>
    <td height="22" class="item ; dotline01" width="15%" >ตำแหน่ง/ที่ตั้ง
      :</td>
    <td height="22" width="35%" class="dotline01">
       <%=genIPV_BOQTypeList(conn,"i_type",iGroup,iType," size='1' class='box2' style='width:200px'",true)%>
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
          <td class="col_name" width="4%"><input type="checkbox" name="main_check" onclick="checkAll(this,'main_check','del_checkbox');"></td>
          <td class="col_name" width="15%">หมวด</td>
          <td class="col_name" width="15%">ตำแหน่ง</td>
          <td class="col_name" width="30%">ชื่อรายละเอียดการซ่อม</td>
          <td class="col_name" width="12%">ค่าแรงต่อหน่วย</td>
          <td class="col_name" width="7%">ค่าของต่อหน่วย</td>
          <td class="col_name" width="7%">หน่วยนับ</td>
          <td class="col_name" width="10%">ภายใน/ภายนอก</td>
        </tr>
           <%    String strInOut = "";
		        int line = 0;		     
		        sql.delete(0,sql.length());
		        sql.append(" select first ").append(endRow).append(" b.n_itmjob n_group,c.n_itmjob n_type,a.* from lan:ipv_qcboq a ")
		              .append(" left join lan:ipv_qcboq b on b.i_group=a.i_group and  (b.i_group is not null) and ((b.i_type is null) or (b.i_type='')) and ((b.i_seq is null) or (b.i_seq='')) ")
		              .append(" left join lan:ipv_qcboq c on c.i_group=a.i_group and c.i_type=a.i_type and (c.i_group is not null) and (c.i_type is not null) and ((c.i_seq is null) or (c.i_seq='')) ")
		              .append(condition);
				servlog.startLog(sql.toString());
		        rs = stmt.executeQuery(sql.toString());
				servlog.endLog();

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
                             inOut = doString.checkString(doString.DisplayThai(rs.getString("f_in_out")),"-");  
                             //System.out.println("inOut = "+inOut);
                             if("01".equals(inOut)){
                             	strInOut = inOut+"-ภายนอก";
                             }else if("02".equals(inOut)){
                                strInOut = inOut+"-ภายใน";
                             }
		                    %>
		                    
		     <tr height="25px">
			   	<td width="4%" align="center" class="dotline">
			   	<input type="checkbox" name="del_checkbox"  value="<%=iItm%>" onclick="checkAll(this,'main_check','del_checkbox');"></td>
			   	<td class="dotline" width="12%"><%=iGroup%>-<%=nGroup%>&nbsp;</td>
				<td class="dotline" width="12%"><%=iType%>-<%=nType%>&nbsp;</td>
				<td class="dotline" width="12%"><a href="javascript:doEdit('<%=iItm%>')"><%=iItm %>-<%=nItm%></a></td>
				<td class="dotline" width="12%" align='right'><%=zWangUnit%>&nbsp; </td>
          		<td class="dotline" width="7%" align='right'><%=zGoodUnit%>&nbsp; </td>
          		<td class="dotline" width="7%"><%=nCount%></td>
          		<td class="dotline" width="10%"><%=strInOut%></td>
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
          <td align="center" class="dotline" width="4%"  valign="top">&nbsp;</td>
          <td align="left"   class="dotline" width="15%" valign="top">&nbsp;</td>
          <td align="left"   class="dotline" width="15%" valign="top">&nbsp;</td>
          <td align="left"   class="dotline ; item" width="30%" valign="top"><%=((line==4 && msg.length()>0) ? msg : "&nbsp;")%></td>
          <td align="right"  class="dotline" width="12%" valign="top">&nbsp;</td>
          <td align="right"  class="dotline" width="7%" valign="top">&nbsp;</td>
          <td align="center" class="dotline" width="7%" valign="top">&nbsp;</td>
           <td align="center" class="dotline" width="10%" valign="top">&nbsp;</td>
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

            <a href="SERV_BOQ_IPVQC02.jsp?mode=add"><img border="0" src="images/act_add.gif"                                   
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
		System.out.println("ERROR "+jName+": " + e.getMessage());
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

