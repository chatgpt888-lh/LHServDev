<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.text.*" %>
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
	doString str = new doString();


	//----=================== Get data from parameter =======================----//
    String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase();
    String vendType = doString.checkString(request.getParameter("i_type"),"").toUpperCase();
    String condition = "";


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
        

        //---====================== Generate Serrch Condition ===========================---//
        //if (selProj.trim().length()>0 && !selProj.equalsIgnoreCase("ALL")) {
        //condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
        //}

        if (selProj.trim().length()>=6) {
 		    condition = " and a.i_company='"+(selProj.substring(0,2))+"' and a.i_project='"+(selProj.substring(3,6))+"' ";
        } else {
			condition = " and a.i_company='XX' and a.i_project='999' "; // used for protect select all when no choose project 
		}

        if (vendType.trim().length()>0) {
           condition += " and a.i_type='"+vendType+"' ";
        }
 	   //---=========================================================================----//   



        
        //----====================== Get Vendor Max Row ==============================-----//
        int maxRow = 0;
        sql.delete(0,sql.length());
        sql.append(" select count(*) cnt from lan:serv_venprj a where (i_type='03' or i_type='04') ").append(condition);                  
        rs = stmt.executeQuery(sql.toString());
        while (rs.next()) {        
           maxRow = rs.getInt("cnt");
        }
        rs.close();
	   //---=========================================================================----//            

                        
        
        
	   //-----============== Generate Display Customize and Page Link ==================-----//
	   String displayType = doString.checkString(request.getParameter("display_type"),"");    
	   int displayLine = Integer.parseInt(doString.checkString(request.getParameter("display_line"),"0"));
	   int nowPage = Integer.parseInt(doString.checkString(request.getParameter("now_page"),"1"));
	   if (displayType.equalsIgnoreCase("A")) {
	      displayLine = maxRow;
	      nowPage = 1;
	   }   
	   if (displayLine<Constants.SERV_VENPRJ_LINE) displayLine = Constants.SERV_VENPRJ_LINE;      
	   
	   int startRow = ((nowPage-1)*displayLine);
	   int endRow = startRow+displayLine;
	   int tmpMax = maxRow;
	   
	   String pageLink = "";
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
<TITLE>ข้อมูลพื้นฐาน : 01รายละเอียดร้านค้าภายในโครงการ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">
<!--

  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_ChkVenPrj.jsp";
     document.forms[0].submit();
  }   
  
  function addVendor() {
     if (document.forms[0].sel_project.value=="") {
	    alert(" กรุณาเลือกโครงการที่ต้องการก่อนทำการเพิ่ม !");
		return false;
	 }
     if (document.forms[0].i_type.value=="") {
	    alert(" กรุณาเลือกประเภท !");
		return false;
	 }
	 var num = parseInt(document.forms[0].num_ven.value);
	 if (num > 0) {
	 	alert("มีร้านค้าอยู่ในโครงการนี้แล้ว");
	 	return false;
	 }
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_ChkVenPrj01.jsp";
     document.forms[0].submit();  
  }
  
  function deleteVendor() {
     if (confirm(" คุณแน่ใจว่าต้องการลบข้อมูลที่เลือก ?")) {
	     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_ChkVenPrjServlet?mode=delete";
	     document.forms[0].submit();       
     }
  }
  

function  checkAll(obj,mainCheck,subCheck) {
     var main = document.forms[0].elements[mainCheck];
     var sub = document.forms[0].elements[subCheck];
     
     if (obj!=null && main!=null && sub!=null) {
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
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ข้อมูลพื้นฐาน</td>
        </tr>
      </table>


<br style="font-size:10pt">
                
            
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">รายละเอียดร้านค้าภายในโครงการ</td>
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
    <td class="item ; dotline01" height="22" width="18%" colspan="2">โครงการ :</td>
    <td height="22" width="44%" class="dotline01">
     <%=common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:250px'  onchange='changePage(1);' ",false)%>       
    </td>
    <td height="22" class="item ; dotline01" width="10%">ประเภท :</td>
    <td height="22" width="28%" class="dotline01">
    <select name='i_type' class='box' style='width:180px' onchange="changePage(1);">
       <option value="">------ กรุณาเลือก ------</option>
       <option value="03" <%=vendType.equals("03") ? " selected " : ""%>>03 ร้านค้าแอร์</option>
       <option value="04" <%=vendType.equals("04") ? " selected " : ""%>>04 ร้านค้าปลวก</option>
    </select>
     </td>
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
          <td class="col_name" width="6%"><input type="checkbox" name="main_check" onclick="checkAll(this,'main_check','vend_code');"></td>
          <td class="col_name" width="20%">ประเภท</td>
          <td class="col_name" width="14%">รหัสร้านค้า</td>
          <td class="col_name" width="60%">ชื่อร้านค้า</td>
          <td class="col_name" width="10%"><nobr>Staff No.</nobr></td>
        </tr>
        
        
        <%
        
		     //----================== Select Data from SERV_VENPRJ ================----//   
		     	int num_ven = 0;
		        int line = 0;		     
		        sql.delete(0,sql.length());
		        sql.append(" select b.bus_name,a.* from lan:serv_venprj a ")
		              .append(" left join lan:stpvendr b on b.vend_code=a.i_vendor ")
		              .append(" where (i_type='03' or i_type='04') ").append(condition)
                      .append( " order by i_type, i_vendor, i_group ");
		        rs = stmt.executeQuery(sql.toString());
		        for (int i=0;i<maxRow;i++) { 
                      if (rs.next()) {
                         if (i>=startRow && i<=endRow) {
                         	num_ven++;
                            //------ Data is in this page , display -----//
				            String iVendor = doString.checkString(rs.getString("i_vendor"),"-");
				            String iType = doString.checkString(rs.getString("i_type"),"-");
				            String vendorName = doString.checkString(doString.DisplayThai(rs.getString("bus_name")),"-");
				            String iGroup = doString.checkString(rs.getString("i_group"));				            
					        %>
					        <tr>
					          <td align="center" class="dotline" width="6%">
					          <input type="checkbox" name="vend_code" value="<%=selProj+":"+iType+":"+iVendor%>" onclick="checkAll(this,'main_check','vend_code');"></td>
					          <td class="dotline" align="left" width="20%"><%=iType.equalsIgnoreCase("03") ? "ร้านค้าแอร์" : "ร้านค้าปลวก"%></td>
					          <td class="dotline" align="center" width="14%"><%=iVendor%></td>
					          <td align="left" class="dotline" width="60%"><%=vendorName%></td>
					          <td align="center" class="dotline" width="10%"><%=iGroup%>&nbsp;</td>
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
			        <tr>
			          <td align="center" class="dotline" width="6%">&nbsp;</td>
			          <td class="dotline" align="left" width="20%">&nbsp;</td>
			          <td class="dotline" align="left" width="14%">&nbsp;</td>
			          <td align="left" class="dotline" width="60%">&nbsp;</td>
			          <td align="left" class="dotline" width="10%">&nbsp;</td>
			        </tr>     
	                <%               
	           }
        %>        
        <input type="hidden" name="num_ven" value="<%=num_ven%>">
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

            <img border="0" src="images/act_add.gif" onclick="addVendor();"
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">&nbsp; 
             <img border="0" src="images/act_delete.gif" onclick="deleteVendor();"
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">

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
		System.out.println("ERROR SERV_ChkVenPrj.jsp : " + e.getMessage());
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
