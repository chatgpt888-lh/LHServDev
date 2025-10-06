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
 * Extenstion from : SERV_BOQ02.jsp
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
String jName = "SERV_BOQ_IPVQC02.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);		 	
	//----============ Declare Variables for search data ===========----//	 	
	//String searchType = doString.checkString(request.getParameter("search_type"),"");    
   	String nItm = doString.checkString(request.getParameter("n_itmjob"),"");    
   	String iGroup = doString.checkString(request.getParameter("i_group"),""); 
   	String iType = doString.checkString(request.getParameter("i_type"),""); 
   	String iSeq = doString.checkString(request.getParameter("i_seq"),"");
   	String nDesc = doString.checkString(request.getParameter("n_desc"),"");
   	String zWageUnit = doString.checkString(request.getParameter("z_wage_unit"),"");
   	String zGoodUnit = doString.checkString(request.getParameter("z_good_unit"),"");
    String iItm = doString.checkString(request.getParameter("i_itmjob"),"");
    String rbtInOut = doString.checkString(request.getParameter("rbtInOut"),""); //01=out,02=in
 	//String nCount = doString.checkString(request.getParameter("n_desc"),"");   	
 	
 	//For List Page
 	String now_page = doString.checkString(request.getParameter("now_page"),"");
 	//String mode = doString.checkString(request.getParameter("mode"),"");
 	String display_type = doString.checkString(request.getParameter("display_type"),"");
 	String display_line = doString.checkString(request.getParameter("display_line"),"");
 	String i_groupDDL = doString.checkString(request.getParameter("i_groupDDL"),"");
 	String i_typeDDL = doString.checkString(request.getParameter("i_typeDDL"),"");
 	if("".equals(i_groupDDL)){
 		i_groupDDL =iGroup;
 	}
 	if("".equals(i_typeDDL)){
 	   i_typeDDL  = iType;
 	}
	//now_page=2&d_keyin=&mode=delete&display_type=L&display_line=9&i_group=05&i_type=ALL
 	
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	SERV_CommonData com = null;
	//String error = doString.checkString(request.getParameter("error"),"");
	String mode = doString.checkString(request.getParameter("mode"),"");
	String disable = "";
	String groupName = "";
	String typeName = "";
	
	try {
	    //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();
		stmt1 = conn.createStatement();
		com = new SERV_CommonData(conn);  
	    //----=======================================----//	    
	    //----================== load old data  ===================----//	
	    String style = "size='1' class='box' style='width:200px' onchange='refreshPage()'";
	    
	    if(mode.equalsIgnoreCase("EDIT")){
	        style ="size='1' class='box' onchange='refreshPage()' style='color:#CCCCCC' readonly='readonly'";
	    	//System.out.println(disable);
	      iItm = doString.checkString(request.getParameter("i_itmjob"),""); 
	    	//disable ="disable";
	    	if (ds == null) getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
			stmt = conn.createStatement(); 
			
	        sql.delete(0,sql.length());
	        sql.append(" select * from lan:ipv_qcboq a,lan:serv_xstd b ")
			   .append(" where a.i_itmjob ='").append(iItm).append("' ");
			   //.append(" and a.n_count = b.n_desc");	
			   
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			while(rs.next()){
			 iGroup = doString.checkString(rs.getString("i_group"),"");    
			 iSeq = doString.checkString(rs.getString("i_seq"),"");
			 iItm = doString.checkString(rs.getString("i_itmjob"),"");
			 iType = doString.checkString(rs.getString("i_itmjob"),"").substring(2,4);
			 nItm = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")),"");                         
             zWageUnit = doString.checkString(doString.DisplayThai(rs.getString("z_wage_unit")),"");
             zGoodUnit = doString.checkString(doString.DisplayThai(rs.getString("z_good_unit")),"");   
             nDesc = doString.checkString(doString.DisplayThai(rs.getString("n_count")),"");
             rbtInOut =  doString.checkString(doString.DisplayThai(rs.getString("f_in_out")),"");
			} // end while
			rs.close();
						
		 //---=========== Get Group Name and Type Name ===============----//	
		 sql.delete(0,sql.length());
		  sql.append(" select b.n_itmjob n_group,c.n_itmjob n_type from lan:ipv_qcboq a ")
		        .append(" left join lan:ipv_qcboq b on b.i_group=a.i_group and  (b.i_group is not null) and ((b.i_type is null) or (b.i_type='')) and ((b.i_seq is null) or (b.i_seq='')) ")
		        .append(" left join lan:ipv_qcboq c on c.i_group=a.i_group and c.i_type=a.i_type and (c.i_group is not null) and (c.i_type is not null) and ((c.i_seq is null) or (c.i_seq='')) ")
		        .append(" where a.i_itmjob='").append(iItm).append("' ");

			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			while(rs.next()){
				 groupName = doString.checkString(doString.DisplayThai(rs.getString("n_group")),"");    
				 typeName = doString.checkString(doString.DisplayThai(rs.getString("n_type")),"");
			} // end while
			rs.close();		        
			
	    }else{
	           style = "size='1' class='box' style='width:200px' onchange='refreshPage()'"; 
	    }  	    
	 %>
<HTML>
<HEAD>
<TITLE>ข้อมูลพื้นฐาน : รายละเอียดข้อมูลราคา BOQ งานซ่อมก่อนโอน</TITLE>
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
function saveData(){
    if (document.forms[0].i_group.value=="") {
       alert(" กรุณาเลือกรหัสหมวด !");
       document.forms[0].i_group.focus();
       return false;
    }
    
    if (document.forms[0].i_type.value=="") {
       alert(" กรุณาเลือกตำแหน่ง/ที่ตั้ง !");
       document.forms[0].i_type.focus();
       return false;
    }    
    
    if (document.forms[0].n_itmjob.value=="") {
       alert(" กรุณากรอกชื่อรายละเอียดการซ่อม !");
       document.forms[0].n_itmjob.focus();
       return false;
    }   
    
    if (document.forms[0].z_wage_unit.value=="") {
       alert(" กรุณาค่าแรงต่อหน่วย !");
       document.forms[0].z_wage_unit.focus();
       return false;
    }   
    
    if (document.forms[0].z_good_unit.value=="") {
       alert(" กรุณากรอกค่าของต่อหน่วย !");
       document.forms[0].z_good_unit.focus();
       return false;
    }               
    
    if (document.forms[0].n_desc.value=="") {
       alert(" กรุณาเลือกหน่วยนับ !");
       document.forms[0].n_desc.focus();
       return false;
    } 
    
	var obj  = document.forms[0].rbtInOut;
    var check = getCheckedValue(obj);

    if(check==""){
		 alert("กรุณาเลือกบริเวณ ภายในหรือภายนอก.");
		 document.forms[0].rbtInOut.focus();
		 return false;
	}       

 	document.forms[0].action="<%=Constants.APP_PATH%>/SERV_BOQ_IPVQCServlet";
    document.forms[0].submit();
}


function refreshPage(resetObj) {
   if (resetObj!=null) {
      var obj = document.forms[0].elements(resetObj);
      if (obj!=null) obj.value="";
   }

   document.forms[0].action="<%=Constants.APP_PATH%>/SERV_BOQ_IPVQC02.jsp";
   document.forms[0].submit();
}

//return the value of the radio button that is checked
//return an empty string if none are checked, or
//there are no radio buttons
//radio check by pradoem 2012-02-28
function getCheckedValue(radioObj) {
		if(!radioObj)
			return "";
		var radioLength = radioObj.length;
		if(radioLength == undefined)
			if(radioObj.checked)
				return radioObj.value;
			else
				return "";
		for(var i = 0; i < radioLength; i++) {
			if(radioObj[i].checked) {
				return radioObj[i].value;
			}
		}
		return "";
}
 function changeGroup() {
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_BOQ_IPVQC02.jsp";
     document.forms[0].submit();
  } 
 
 function changePage(page) {  
 	 document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_BOQ_IPVQC02.jsp";
     document.forms[0].submit();
  } 
  
</script>
<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM action="" method="post">
<INPUT type="hidden" name="mode" value="<%=mode%>">
<INPUT type="hidden" name="i_itmjob" value="<%=iItm%>">
<INPUT type="hidden" name="d_keyin" value="<%=com.getDateFromCalendar(Calendar.getInstance())%>">

<INPUT type="hidden" name="now_page" value="<%=now_page%>">
<INPUT type="hidden" name="display_type" value="<%=display_type%>">
<INPUT type="hidden" name="display_line" value="<%=display_line%>">
<INPUT type="hidden" name="i_groupDDL" value="<%=i_groupDDL%>">
<INPUT type="hidden" name="i_typeDDL" value="<%=i_typeDDL%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;ข้อมูลพื้นฐาน</td>
        </tr>
      </table>
<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250"> รายละเอียดข้อมูลราคา BOQ งานซ่อมก่อนโอน</td>
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
    <td class="item ; dotline01" height="22" width="18%">รหัสหมวด :</td>
    <td height="22" width="35%" class="dotline01">
    <%
       if (mode.equalsIgnoreCase("ADD")) {
          %>
             <%=genIPV_BOQGroupList(conn,"i_group",iGroup," size='1' class='box2' style='width:200px' onchange='changeGroup();'" )%>
          
          <%
       } else {
           %>
           <%=groupName%> 
           <input type="hidden" name="i_group" value="<%=iGroup%>">           
           <%
       } 
    %>   
    </td>
    <td height="22" class="item ; dotline01" width="15%">ตำแหน่ง/ที่ตั้ง :</td>
    <td height="22" width="32%" class="dotline01">
        <%
       if (mode.equalsIgnoreCase("ADD")) {
          %><%=genIPV_BOQTypeList(conn,"i_type",iGroup,iType,"size='1' class='box2' style='width:200px' onchange='refreshPage()' ",false)%><%
       } else {
           %>
           <%=typeName%> 
           <input type="hidden" name="i_type" value="<%=iType%>">           
           <%
       } 
    %>    
    </td>
  </tr>
   <% 
   
   if(mode.equalsIgnoreCase("ADD")){
	  iSeq = "";	
      sql.delete(0,sql.length());
   	  sql.append(" select max(i_seq) max_iseq from lan:ipv_qcboq where i_seq is not null  ")
   	        .append(" and i_group='").append(iGroup).append("' and i_type='").append(iType).append("' ")
		    .append("and i_seq[1,1] != 'C' ");
	  servlog.startLog(sql.toString());
      rs = stmt.executeQuery(sql.toString());
	  servlog.endLog();
	   
	  if (rs.next()){
	     iSeq  = doString.checkString(doString.DisplayThai(rs.getString("max_iseq")),"");
	  }	  
	  rs.close();  
	  	//int seq = Integer.parseInt(iSeq.trim().length()<=0 ? "0" : iSeq)+1;	    
		if (iSeq.trim().length()>0) {
			int seq = 0;

				if (iSeq.toUpperCase().indexOf("C")==0) {
					iSeq = iSeq.substring(1);
					seq = Integer.parseInt(iSeq.trim().length()<=0 ? "0" : iSeq)+1;	
					iSeq = Integer.toString(seq);
					while (iSeq.length()<4) {
						iSeq = "0"+iSeq;
					}
					iSeq = iSeq;
				} else {
					seq = Integer.parseInt(iSeq.trim().length()<=0 ? "0" : iSeq)+1;	
					iSeq = Integer.toString(seq);

					while (iSeq.length()<4) {
						iSeq = "0"+iSeq;
					}
				}

		} else {
			iSeq = "0001";
		}
   }
 	%>
  <tr>
    <td class="item ; dotline01" height="22" width="18%">ลำดับ :</td>
    <td height="22" width="35%" class="dotline01"><%=iSeq%>
   </td>
    <td height="22" class="item ; dotline01" width="15%">รหัส BOQ :</td>
    <td height="22" width="32%" class="dotline01"><%=iGroup+iType+iSeq%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="18%">ชื่อรายละเอียดการซ่อม :</td>
    <td height="22" width="85%" class="dotline01" colspan="3"><input type="text"  name="n_itmjob" value="<%=nItm%>" class="box" style="width:100%"></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="18%">ค่าแรงต่อหน่วย :</td>
    <td height="22" width="35%" class="dotline01"><input type="text" name="z_wage_unit" value="<%=zWageUnit%>" class="boxC" style="width:100px"></td>
    <td height="22" class="item ; dotline01" width="15%">ค่าของต่อหน่วย :</td>
    <td height="22" width="32%" class="dotline01"><input type="text" name="z_good_unit" value="<%=zGoodUnit%>" class="boxC" style="width:100px"></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="18%">หน่วยนับ :</td>
    <td height="22" width="35%" class="dotline01">
    <%=com.genNCountListBox("n_desc",nDesc," size='1' class='box2' style='width:200px' ")%>
    </td>
    <td height="22" class="item ; dotline01" width="15%">&nbsp;</td>
    <td height="22" width="32%" class="dotline01">&nbsp;</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="18%">ภายใน/ภายนอก :</td>
	<td height="22" class="dotline01" width="82%" colspan = "3">
 	<input type="radio" name="rbtInOut" id="rbtInOut1" value="01" <%
 	if(rbtInOut.equals("01")){out.println("checked='checked'");} %>>&nbsp;ภายนอก
	<input type="radio" name="rbtInOut" id="rbtInOut2" value="02" <%
	if(rbtInOut.equals("02")){out.println("checked='checked'");} %>>&nbsp;ภายใน
	</td> 
  </tr>
  <%
  //int no = 0;
  int line=0;
  while (line<5) {
  %>
  <tr>
    <td class="item ; dotline01" height="22" width="18%">&nbsp;</td>
    <td height="22" width="35%" class="dotline01">&nbsp;</td>
    <td height="22" class="item ; dotline01" width="15%">&nbsp;</td>
    <td height="22" width="32%" class="dotline01">&nbsp;</td>
  </tr>
  <%
   line ++;
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
<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">

            <a href="#" onclick="saveData();"><img border="0" src="images/act_save.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
            </td>                            	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_BOQ_IPVQC01.jsp" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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

<input type="hidden" name="i_seq" value="<%=iSeq%>">
<input type="hidden" name="no" value="<%//=no%>">

</FORM>	
</BODY>

</HTML>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_BOQ_IPVQC02.jsp : " + e.getMessage());
		System.out.println("ERROR SERV_BOQ_IPVQC02.jsp SQL : " + sql.toString());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (rs1 != null) rs1.close();
			if (stmt != null) stmt.close();
			if (stmt1 != null) stmt1.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>
