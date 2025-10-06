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
<%@ page import="serv.util.ServLog" %>

<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%!

    public Double[] newDoubleArray(int size) {
        Double result[] = new Double[size];
	for (int i=0;i<size;i++) {
	       result[i] = new Double(0.0);
	}

	return result;
    }

%>

<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_Signb.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

	doString str = new doString();


   String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase();
   String searchSignb = doString.checkString(request.getParameter("search_signb"),"").toUpperCase();
   String searchStatus = doString.checkString(request.getParameter("search_status"),"").toUpperCase();
   String condition = "";


	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	SERV_CommonData common = null;
    DecimalFormat format = new DecimalFormat("#,##0.00");	

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
        String startDate = common.getValueFromDateListbox("start",request);
        String endDate = common.getValueFromDateListbox("end",request);

        if (selProj.trim().length()>=6 && !selProj.equalsIgnoreCase("ALL")) {
           //condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
		   condition = " and a.i_company='"+(selProj.substring(0,2))+"' and a.i_project='"+(selProj.substring(3,6))+"' ";
        }

		if (searchSignb.trim().length()>0) condition += " and a.i_signb='"+searchSignb+"' ";
		if (searchStatus.trim().length()>0) condition += " and a.f_use='"+searchStatus+"' ";
		if (startDate.trim().length()>0) condition += " and a.d_beg_use='"+startDate+"' ";
		if (endDate.trim().length()>0) condition += " and a.d_fin_use='"+endDate+"' ";
 	   //---=========================================================================----//   


	   //-----=============================== Count Row ================================-----//
	   int maxRow = 0;
       sql.delete(0,sql.length());	   
	   sql.append("select count(*) as cnt from lan:serv_signb a where 1=1 ")
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
   if (displayLine<Constants.SERV_PSTAFF_LINE) displayLine = Constants.SERV_PSTAFF_LINE;      
   
   int startRow = ((nowPage-1)*displayLine);
   int endRow = (startRow-1)+displayLine;
   
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
<TITLE>ข้อมูลป้ายต่อเติม</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--

  var tmpComment = new Array(); 

  function addSignb() {
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Signb01.jsp";
     document.forms[0].submit();  
  }

function deleteData() {
    if (confirm("คุณต้องการลบข้อมูลที่ทำการเลือกทั้งหมดนี้ ?")) {
       document.forms[0].action = "<%=Constants.APP_PATH%>/SERV_SignbServlet";
	   document.forms[0].mode.value="delete";
       document.forms[0].submit();
    } 
}

  function searchSignb() {
	  if (!validDate("start")) {
		  return false;
	  }

	  if (!validDate("end")) {
		  return false;
	  }
	  
	  document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Signb.jsp";
     document.forms[0].submit();  
  }

  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Signb.jsp";
     document.forms[0].submit();
  }


  function validDate(prefix) {
     //var sdate = document.forms[0].elements(prefix+"_date").value;
     //var smonth = document.forms[0].elements(prefix+"_month").value;
     //var syear = document.forms[0].elements(prefix+"_year").value;
	 var sdate = document.getElementsByName(prefix+"_date")[0].value;	 
	 var smonth = document.getElementsByName(prefix+"_month")[0].value;	 
	 var syear = document.getElementsByName(prefix+"_year")[0].value;	 
     
     //---- Check select date ---//
     if (sdate.length==0 && smonth.length==0 && syear.length==0) {
         return true;
     }     
     
     var startDate = new Date(parseInt(syear,10),parseInt(smonth,10)-1,parseInt(sdate,10));
     
     if (startDate.getMonth()!=(parseInt(smonth,10)-1)) {
        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].start_date.focus();
        return false;
     }
  
     return true;
  }


  function  checkAll(obj,mainCheck,subCheck) {
     //var main = document.forms[0].elements[mainCheck];
     //var sub = document.forms[0].elements[subCheck];
     var main = document.getElementById(mainCheck);
     var sub = document.getElementsByName(subCheck);	 
     
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
					  if (!sub[i].disabled) sub[i].checked = obj.checked;
				}
			} else {
			   if (!sub[i].disabled) sub.checked = obj.checked;
			}
         } else {
		    if (sub.length!=null) {
			    var flag = true;
				for (var i=0;i<sub.length;i++) {
					  flag = sub[i].checked;
					  if (!flag && !sub[i].disabled) break;
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


<input type="hidden" name="now_page" value="<%=page%>">
<input type="hidden" name="mode" value="">


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center" class="BD">
    

      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ป้ายต่อเติม</td>
          <td width="30%" align="right">
          </td>
        </tr>
      </table>


<br style="font-size:10pt">
                



            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">ค้นหารายการ</td>
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
    <td class="item ; dotline01" height="22" width="10%">โครงการ :</td>
    <td height="22" class="dotline01" width="40%">
    <%=common.genAllProjectListbox("sel_project",selProj," size='1' class='box' style='width:250px'  ",false)%>
    </td>
    <td class="item ; dotline01" height="22" width="10%">เลขที่ป้ายต่อเติม :</td>
    <td height="22" width="40%" class="dotline01"><input type="text" name="search_signb" value="<%=searchSignb%>" class="box"></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="10%">วันที่เริ่มต้น :</td>
    <td height="22" class="dotline01" width="40%"><%=common.genDateListbox("start",request," class='box' ")%></td>
    <td class="item ; dotline01" height="22" width="10%">วันที่สิ้นสุด :</td>
    <td height="22" class="dotline01" width="40%"><%=common.genDateListbox("end",request," class='box' ")%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="10%">สถานะ :</td>
    <td height="22" class="dotline01" colspan="3">
    <select name="search_status" class="box" style="width:100px">
		<option value="">ทั้งหมด</option>
		<option value="N" <%=(searchStatus.equalsIgnoreCase("N") ? " selected" : "")%>>ว่าง</option>
		<option value="A" <%=(searchStatus.equalsIgnoreCase("A") ? " selected" : "")%>>ใช้งาน</option>
		<option value="D" <%=(searchStatus.equalsIgnoreCase("D") ? " selected" : "")%>>เสีย</option>
		<option value="L" <%=(searchStatus.equalsIgnoreCase("L") ? " selected" : "")%>>สูญหาย</option>
	</select>
    &nbsp;&nbsp;&nbsp;&nbsp; <img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22" onclick="searchSignb()" style='cursor:hand;'></td>
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
                <td class="item_tab2" width="200">รายละเอียดป้ายต่อเติม</td>
                <td class="item_tab3"></td>
                <td >&nbsp;</td>
              </tr>
            </table>


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td valign="bottom" class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
    <td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL" align="center">
    
    
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5%" class="col_name"><input type="checkbox" name="main_check" id="main_check"  onclick="checkAll(this,'main_check','del_checkbox');"></td>
    <td width="29%" class="col_name">โครงการ</td>
    <td width="9%" class="col_name"><nobr>เลขที่ป้ายต่อเติม</nobr></td>
    <td width="19%" class="col_name">วันเริ่มต้นใช้</td>
    <td width="19%" class="col_name">วันสิ้นสุดการใช้</td>
    <td width="19%" class="col_name">สถานะ</td>    
  </tr>  

  
        <%
        
		     //----================== Select Data from SERV_DOCHD ================----//   
		        int line = 0;		     
		        sql.delete(0,sql.length());
		        sql.append("select b.n_project,a.* from lan:serv_signb a left join lan:acxprojt b on b.i_company=a.i_company ")
					  .append(" and b.i_project=a.i_project where 1=1 ")
		              .append(condition)
		              .append(" order by a.i_company,a.i_project,a.i_signb,a.d_beg_use,a.d_fin_use ");
				servlog.startLog(sql.toString());
		        rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
		        for (int i=0;i<maxRow;i++) { 
                      if (rs.next()) {
                         if (i>=startRow && i<=endRow) {	
				            String comId = doString.checkString(rs.getString("i_company"),"");
				            String projId = doString.checkString(rs.getString("i_project"),"");
				            String projDesc = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
				            String iSignb = doString.checkString(rs.getString("i_signb"),"");
				            String status = doString.checkString(rs.getString("f_use"),"");

							  String dStart = "";
							  Calendar date = Calendar.getInstance();
							  Timestamp temp = rs.getTimestamp("d_beg_use");
							  if (temp!=null)  {
								  date.setTime(temp);      
								  dStart = getDateFromCalendar(date); 
							  }

							  String dEnd = "";
							  date = Calendar.getInstance();
							  temp = rs.getTimestamp("d_fin_use");
							  if (temp!=null)  {
								  date.setTime(temp);      
								  dEnd = getDateFromCalendar(date); 
							  }


							  String statusDesc = "";
							  if (status.equalsIgnoreCase("N")) {
								  statusDesc = "ว่าง";
							  } else if (status.equalsIgnoreCase("A")) {
								  statusDesc = "ใช้งาน";
							  } else if (status.equalsIgnoreCase("D")) {
								  statusDesc = "เสีย";
							  } if (status.equalsIgnoreCase("L")) {
								  statusDesc = "สูญหาย";
							  }


					        %>
							<tr>
							<td width="5%" class="dotline" align="center">
									<input type="checkbox" name="del_checkbox" id="del_checkbox" <%=(status.equalsIgnoreCase("N") ? "" : " disabled ")%> value="<%=comId+":"+projId+":"+iSignb%>" onclick="checkAll(this,'main_check','del_checkbox');">
							</td>
							<td width="30%" class="dotline"><%=doString.checkString(comId+"-"+projId+"&nbsp; "+projDesc,"&nbsp;")%></td>
							<td width="10%" class="dotline"><%=doString.checkString(iSignb,"&nbsp;")%></td>
							<td width="20%" class="dotline" align="center"><%=doString.checkString(dStart,"&nbsp;")%></td>
							<td width="20%" class="dotline" align="center"><%=doString.checkString(dEnd,"&nbsp;")%></td>
							<td width="20%" class="dotline" align="center"><%=doString.checkString(statusDesc,"&nbsp;")%></td>
							</tr>
					        <%
					        
 					         line++;                         

					} // end if check row
					 if (i>endRow) break;
                } //end if check rs
              } // end for
                
	           while (line<Constants.SERV_MANAGERLIST_LINE) {
	               line++;
	                %>
					  <tr>
						<td width="5%" class="dotline">&nbsp;</td>
						<td width="29%" class="dotline">&nbsp;</td>
						<td width="9%" class="dotline">&nbsp;</td>
						<td width="19%" class="dotline">&nbsp;</td>
						<td width="19%" class="dotline">&nbsp;</td>
						<td width="19%" class="dotline">&nbsp;</td>    
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

			            <img border="0" src="images/act_add.gif"   
			                onclick="addSignb();"                                
			    			   onmouseout=nereidFade(this,70,50,5)    
			                      onmouseover=nereidFade(this,100,50,5)     
			                  	     style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">&nbsp; 		

			            <img border="0" src="images/act_delete.gif"   
			                onclick="deleteData();"                                
			    			   onmouseout=nereidFade(this,70,50,5)    
			                      onmouseover=nereidFade(this,100,50,5)     
			                  	     style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">&nbsp; 		

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
		System.out.println("ERROR SERV_Signb.jsp : " + e.getMessage());
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