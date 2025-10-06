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
   	String nItm = doString.checkString(request.getParameter("n_itmjob"),"");    
   	String iGroup = doString.checkString(request.getParameter("i_group"),""); 
   	String iType = doString.checkString(request.getParameter("i_type"),""); 
   	String iSeq = doString.checkString(request.getParameter("i_seq"),"");
   	String nDesc = doString.checkString(request.getParameter("n_desc"),"");
   	String itmType = doString.checkString(request.getParameter("itmType"),"");
   	String zWageUnit = doString.checkString(request.getParameter("z_wage_unit"),"");
   	String zGoodUnit = doString.checkString(request.getParameter("z_good_unit"),"");
    String iItm = doString.checkString(request.getParameter("i_itmjob"),"");
 	String nCount = doString.checkString(request.getParameter("n_desc"),"");   	
 	String account = doString.checkString(request.getParameter("account"),"");   		String com_acc1 = "";
	String cus_acc1 = "";
	String com_acc2 = "";
	String cus_acc2 = "";
	String com_acc3 = "";
	String cus_acc3 = "";
 	
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	SERV_CommonData com = null;
	String error = doString.checkString(request.getParameter("error"),"");
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
		com = new SERV_CommonData(conn);  
	    //----=======================================----//	
	    
	    //----================== load old data  ===================----//	
	    String style = "size='1' class='box' style='width:200px' onchange='refreshPage()'";
	    
	    if(mode.equalsIgnoreCase("EDIT")){
	        style ="size='1' class='box' onchange='refreshPage()' style='color:#CCCCCC' readonly='readonly'";
	    	System.out.println(disable);
	      iItm = doString.checkString(request.getParameter("i_itmjob"),""); 

	    	if (ds == null) getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
			stmt = conn.createStatement(); 
			
	        sql.delete(0,sql.length());
	        sql.append("SELECT * FROM lan:serv_infboq a")
			   .append(" WHERE a.i_itmjob ='").append(iItm).append("'");
			rs = stmt.executeQuery(sql.toString());
			while(rs.next()){
			 iGroup = doString.checkString(rs.getString("i_group"),"");    
			 iSeq = doString.checkString(rs.getString("i_seq"),"");
			 iItm = doString.checkString(rs.getString("i_itmjob"),"");
			 iType = doString.checkString(rs.getString("i_itmjob"),"").substring(2,4);
			 nItm = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")),"");                         
			 itmType = doString.checkString(doString.DisplayThai(rs.getString("i_itmtype")),"");                         
             zWageUnit = doString.checkString(doString.DisplayThai(rs.getString("z_wage_unit")),"");
             zGoodUnit = doString.checkString(doString.DisplayThai(rs.getString("z_good_unit")),"");   
             nDesc = doString.checkString(doString.DisplayThai(rs.getString("n_count")),"");
             com_acc1 = doString.checkString(doString.DisplayThai(rs.getString("i_com_acc1")),"");             cus_acc1 = doString.checkString(doString.DisplayThai(rs.getString("i_cus_acc1")),"");

             com_acc2 = doString.checkString(doString.DisplayThai(rs.getString("i_com_acc2")),"");
             cus_acc2 = doString.checkString(doString.DisplayThai(rs.getString("i_cus_acc2")),"");

             com_acc3 = doString.checkString(doString.DisplayThai(rs.getString("i_com_acc3")),"");
             cus_acc3 = doString.checkString(doString.DisplayThai(rs.getString("i_cus_acc3")),"");
             
			} // end while
			rs.close();
			
			
		 //---=========== Get Group Name and Type Name ===============----//	
		 sql.delete(0,sql.length());
		  sql.append("SELECT b.n_itmjob AS N_GROUP, c.n_itmjob AS N_TYPE FROM lan:serv_infboq a")
		             .append(" LEFT JOIN lan:serv_infboq b ON b.i_group = a.i_group AND b.i_type = '00' AND b.i_seq = '0000'")
		             .append(" LEFT JOIN lan:serv_infboq c ON c.i_group = a.i_group AND c.i_type = a.i_type AND c.i_seq = '0000'")
		        .append(" WHERE a.i_itmjob = '").append(iItm).append("'");
			rs = stmt.executeQuery(sql.toString());
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
<TITLE>ข้อมูลพื้นฐาน : 05
ข้อมูลราคา BOQ สาธารณูฯจากส่วนกลาง</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
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
    if (!document.forms[0].itmType[0].checked && !document.forms[0].itmType[1].checked) {
       alert(" กรุณาระบุประเภทงาน !");
       return false;
    }        

 	document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFBOQServlet";
    document.forms[0].submit();
}


function refreshPage(resetObj) {
	if (resetObj != null) {
		var obj = document.getElementsByName(resetObj);
		if (obj != null) obj[0].value = "";
	}
	document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFBOQ02.jsp";
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

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
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
    <td class="item ; dotline01" height="22" width="18%">รหัสหมวด
      :</td>
    <td height="22" width="35%" class="dotline01">
    <%
       if (mode.equalsIgnoreCase("ADD")) {
          %><%=com.genINFBOQGroupList("i_group",iGroup,"size='1' class='box' style='width:200px' onchange='refreshPage(\"i_type\")' ")%><%
       } else {
           %>
           <%=groupName%> 
           <input type="hidden" name="i_group" value="<%=iGroup%>">           
           <%
       } 
    %>   
    </td>
    <td height="22" class="item ; dotline01" width="15%">ตำแหน่ง/ที่ตั้ง
      :</td>
    <td height="22" width="32%" class="dotline01">
        <%
       if (mode.equalsIgnoreCase("ADD")) {
          %><%=com.genINFBOQTypeList("i_type",iGroup,iType,"size='1' class='box' style='width:200px' onchange='refreshPage()' ",false)%><%
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
   	  sql.append(" SELECT MAX(i_seq) AS MAX_ISEQ FROM lan:serv_infboq")
   	        .append(" WHERE i_group = '").append(iGroup).append("' AND i_type = '").append(iType).append("' AND i_seq != '0000'");
      rs = stmt.executeQuery(sql.toString());
	  if (rs.next()){
	     iSeq  = doString.checkString(rs.getString("max_iseq"),"");
	  }	  
	  rs.close();
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
    <td class="item ; dotline01" height="22" width="18%">ชื่อรายละเอียดการซ่อม
      :</td>
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
    <%=com.genNCountListBox("n_desc",nDesc," size='1' class='box' style='width:200px' ")%>
    </td>
    <td height="22" class="item ; dotline01" width="15%">ประเภทงาน :</td>
	<td height="22" width="32%" class="dotline01"><input type="radio" name="itmType" value="01" <%if (itmType.equals("01")) {out.print("checked");} %>> สาธารณู
<input type="radio" name="itmType" value="02" <%if (itmType.equals("02")) {out.print("checked");} %>> สาธารณะ
	</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="18%"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="13" height="13"> กทม.ใหม่</td>
    <td height="22" width="35%" class="dotline01">&nbsp;</td>
    <td height="22" class="item ; dotline01" width="15%">&nbsp;</td>
    <td height="22" width="32%" class="dotline01">&nbsp;</td>
  </tr>  
  <tr>
    <td class="item ; dotline01" height="22" width="18%">บริษัท :</td>
    <td height="22" width="35%" class="dotline01"><input type="text"  name="com_acc1" value="<%=com_acc1%>" class="box" style="width:100px"></td>
    <td height="22" class="item ; dotline01" width="15%">ลูกบ้าน :</td>
    <td height="22" width="32%" class="dotline01"><input type="text"  name="cus_acc1" value="<%=cus_acc1%>" class="box" style="width:100px"></td>
  </tr>  
  <tr>
    <td class="item ; dotline01" height="22" width="18%"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="13" height="13"> ปริมณฑลใหม่</td>
    <td height="22" width="35%" class="dotline01">&nbsp;</td>
    <td height="22" class="item ; dotline01" width="15%">&nbsp;</td>
    <td height="22" width="32%" class="dotline01">&nbsp;</td>
  </tr>    
  <tr>
    <td class="item ; dotline01" height="22" width="18%">บริษัท :</td>
    <td height="22" width="35%" class="dotline01"><input type="text"  name="com_acc2" value="<%=com_acc2%>" class="box" style="width:100px"></td>
    <td height="22" class="item ; dotline01" width="15%">ลูกบ้าน :</td>
    <td height="22" width="32%" class="dotline01"><input type="text"  name="cus_acc2" value="<%=cus_acc2%>" class="box" style="width:100px"></td>
  </tr>  
  <tr>
    <td class="item ; dotline01" height="22" width="18%"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="13" height="13"> โครงการเดิม</td>
    <td height="22" width="35%" class="dotline01">&nbsp;</td>
    <td height="22" class="item ; dotline01" width="15%">&nbsp;</td>
    <td height="22" width="32%" class="dotline01">&nbsp;</td>
  </tr>    
  <tr>
    <td class="item ; dotline01" height="22" width="18%">บริษัท :</td>
    <td height="22" width="35%" class="dotline01"><input type="text"  name="com_acc3" value="<%=com_acc3%>" class="box" style="width:100px"></td>
    <td height="22" class="item ; dotline01" width="15%">ลูกบ้าน :</td>
    <td height="22" width="32%" class="dotline01"><input type="text"  name="cus_acc3" value="<%=cus_acc3%>" class="box" style="width:100px"></td>
  </tr>  
  
  <%
  int line=0;
  while (line<Constants.SERV_XSTD_LINE) {
  
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
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_INFBOQ01.jsp" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
</FORM>	
</BODY>

</HTML>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_INFBOQ02.jsp : " + e.getMessage());
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