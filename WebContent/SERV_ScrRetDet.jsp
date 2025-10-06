
<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>

<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>


<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_ScrRetDet.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   doString str = new doString();


   //----============ Declare Variables for input data ===========----//
   String iCompany = doString.checkString(request.getParameter("i_company"),"");
   String condition = "";

	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
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


        //---====================== Generate Serrch Condition ===========================---//
        String startDate = common.getValueFromDateListbox("start",request);
        String endDate = common.getValueFromDateListbox("end",request);

		if (iCompany.trim().length()>0) condition += " and i_company='"+iCompany+"' ";
	//---=========================================================================----//



%>

<HTML>
<HEAD>
<TITLE>รายงานเงินค้ำประกัน</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--


var projList = new Array();
<%
	 int year = Calendar.getInstance().get(Calendar.YEAR);
	 if (year<2400) year += 543;
	 int pYear = year-1;

	 sql.append(" select distinct a.i_company,a.i_project,b.n_project from lan:acsbudgh a  ")
		   .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
		   .append(" where a.d_year in ( '").append(year).append("' , '").append(pYear).append("' ) ")
		   .append(" and a.i_budg_type in (1,2)  ")
		   .append(" order by a.i_company , a.i_project ");
	 servlog.startLog(sql.toString());
	 rs = stmt.executeQuery(sql.toString());
	 servlog.endLog();
	 int idx = 0;
	 while (rs.next()) {
		 String comId = doString.checkString(rs.getString("i_company"),"");
		 String projId = doString.checkString(rs.getString("i_project"),"");
		 String nProj = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
		 %>projList[<%=idx%>] = '<%=comId+"#"+projId+"#"+nProj%>';<%
		 idx++;
	 }
	 rs.close();
%>


function filterProject() {
   var frm = document.forms[0];

	while (frm.all_proj.options.length>0) {
		frm.all_proj.options[frm.all_proj.options.length-1] = null;
	}

	for (var i=0;i<projList.length;i++) {
		  var data = projList[i].split("#");
		  if (data[0]==frm.i_company.value || frm.i_company.value=="00") {
			  var chk = false;
			  for (var j=0;j<frm.sel_proj.length;j++) {
				    if (frm.sel_proj.options[j].value==data[0]+":"+data[1]) {
						chk = true;
						alert("1");
						break;
					}
			  }
			  if (!chk)   frm.all_proj.options[frm.all_proj.options.length] = new Option(data[0]+"-"+data[1]+" | "+data[2],data[0]+":"+data[1]);
		  }
	} // end for

}

function clearSelProj() {
	while (document.forms[0].sel_proj.options.length>0) {
		document.forms[0].sel_proj.options[document.forms[0].sel_proj.options.length-1] = null;
	}

	filterProject();
}


  function searchRetDoc() {
     if (!validDate()) {
        return false;
     }

	 if (document.forms[0].start_date.value=="" || document.forms[0].end_date.value=="") {
		 alert(" กรุณาเลือกวันที่ Payin !");
		 document.forms[0].start_date.focus();
		 return false;
	 }

	 if (document.forms[0].sel_proj.options.length==0) {
		 alert(" กรุณาเลือกโครงการอย่างน้อย 1 โครงการ !");
		 return false;
	 }

	 for (i = 0; i < document.forms[0].sel_proj.options.length; i++) {
		document.forms[0].sel_proj.options[i].selected = true;
	 }
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_RepRetDet.jsp";
     document.forms[0].submit();
  }


  function validDate() {
     var sdate = document.forms[0].start_date.value;
     var smonth = document.forms[0].start_month.value;
     var syear = document.forms[0].start_year.value;
     var edate = document.forms[0].end_date.value;
     var emonth = document.forms[0].end_month.value;
     var eyear = document.forms[0].end_year.value;

     //---- Check select date ---//
     if (sdate.length==0 && smonth.length==0 && syear.length==0 &&
         edate.length==0 && emonth.length==0 && eyear.length==0) {
         return true;
     }


     var startDate = new Date(parseInt(syear,10),parseInt(smonth,10)-1,parseInt(sdate,10));
     var endDate = new Date(parseInt(eyear,10),parseInt(emonth,10)-1,parseInt(edate,10));

     if (startDate.getMonth()!=(parseInt(smonth,10)-1)) {
        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].start_date.focus();
        return false;
     }

     if (endDate.getMonth()!=(parseInt(emonth,10)-1)) {
        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].end_date.focus();
        return false;
     }

	if (startDate>endDate) {
	    alert(" วันที่สิ้นสุดต้องไม่น้อยกว่าวันที่เริ่มต้น ! ");
	    return false;
	}

     return true;
  }


function MoveSelect(FromBox, TargetBox, Type) {
	var ArrFromBox = new Array();
	var ArrTargetBox = new Array();
	var ArrLookup = new Array();

	for (i = 0; i < TargetBox.options.length; i++) {
		ArrLookup[TargetBox.options[i].text] = TargetBox.options[i].value;
		ArrTargetBox[i] = TargetBox.options[i].text;
	}

	var FromLen = 0;
	var TargetLen = ArrTargetBox.length;
	for(i = 0; i < FromBox.options.length; i++) {
		ArrLookup[FromBox.options[i].text] = FromBox.options[i].value;
		if (FromBox.options[i].value != "" && (Type == 'ALL' || (Type == 'SEL' && FromBox.options[i].selected))){
			ArrTargetBox[TargetLen] = FromBox.options[i].text;
			TargetLen++;
		} else {
			ArrFromBox[FromLen] = FromBox.options[i].text;
			FromLen++;
	   }
	}
	ArrFromBox.sort();
	ArrTargetBox.sort();
	FromBox.length = 0;
	TargetBox.length = 0;
	for(i = 0; i < ArrFromBox.length; i++) {
		var Box = new Option();
		Box.value = ArrLookup[ArrFromBox[i]];
		Box.text = ArrFromBox[i];
		FromBox[i] = Box;
	}
	for(i = 0; i < ArrTargetBox.length; i++) {
		var Box = new Option();
		Box.value = ArrLookup[ArrTargetBox[i]];
		Box.text = ArrTargetBox[i];
		TargetBox[i] = Box;
	}
}


//-->
</script>


<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="" name="frm">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            รายงานรายละเอียดการวางเงินค้ำประกัน</td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">ระบุรายละเอียด</td>
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
    <td class="item ; dotline01" height="22" width="18%">บริษัท :</td>
    <td height="22" width="82%" class="dotline01">
	<select size="1" class="box" style="width:400px" name="i_company" onchange="filterProject();">
        <option value=''>------  กรุณาเลือก  ------</option>
		<%
	        sql.delete(0,sql.length()); 
			sql.append(" select * from lan:acxcompa order by i_company ");
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			while (rs.next()) {
				 String comId = doString.checkString(rs.getString("i_company"),"");
				 String comDesc = doString.checkString(doString.DisplayThai(rs.getString("n_company")),"");
				 %><option value='<%=comId%>'><%=comId+" | "+comDesc%></option><%
			}
			rs.close();
		%>
     </select>
	 </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="18%">วันที่ Payin
      :</td>
    <td height="22" width="82%" class="dotline01">
          <%=common.genDateListbox("start",request," class='box' ")%>
          &nbsp; &nbsp; ถึง : &nbsp; &nbsp;
          <%=common.genDateListbox("end",request," class='box' ")%>
	      &nbsp;&nbsp;&nbsp;&nbsp;
	      <a href="#" onclick="searchRetDoc()"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a>
		  <script>
			  /*
			  var sy = document.forms[0].start_year;
		      var ey = document.forms[0].end_year;
			  if (sy!=null) {
				  while (sy.options[1].value!='2007') {
					   sy.options[1] = null;
				  }
			  }
			  if (ey!=null) {
				  while (ey.options[1].value!='2007') {
					   ey.options[1] = null;
				  }
			  }
			  */
		  </script>
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


      


<table border="0" width="100%" cellspacing="0" cellpadding="0" height="9">
  <tr>
    <td width="5" valign="top" bgcolor="#D7E6FF" height="9"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop" bgcolor="#D7E6FF" height="9">&nbsp;</td>
    <td width="5" valign="top" align="right" bgcolor="#D7E6FF" height="9"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>





<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL">
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td class="col_name" width="45%">โครงการในกลุ่ม</td>
          <td class="col_name" width="10%">&nbsp;</td>
          <td class="col_name" width="45%">โครงการที่เลือก</td>
        </tr>
        <tr>
          <td class="dotline" align="center" width="45%" rowspan="6" style="padding:15px 0px 15px 0px">
		  <select size="15" name="all_proj" multiple class="box" style="width:300px" ondblclick="MoveSelect(frm.all_proj, frm.sel_proj,'SEL');">
            </select></td>
          <td align="center" class="dotline" width="10%">&nbsp;</td>
          <td align="center" class="dotline" width="45%" rowspan="6" style="padding:15px 0px 15px 0px">
		  <select size="15" name="sel_proj" multiple class="box" style="width:300px" ondblclick="MoveSelect(frm.sel_proj, frm.all_proj,'SEL');">
          </select>
		</td>
        </tr>
       <tr>
          <td align="center" class="dotline" width="10%"><a href="javascript:MoveSelect(frm.all_proj, frm.sel_proj,'SEL')"><img border="0" src="images/bu_R.gif" align="absmiddle" vspace="5" hspace="5" width="16" height="16" alt="Add"></a></td>
        </tr>
        <tr>
          <td align="center" class="dotline" width="10%"><a href="javascript:MoveSelect(frm.all_proj, frm.sel_proj,'ALL')"><img border="0" src="images/bu_RR.gif" align="absmiddle" vspace="5" hspace="5" width="16" height="16" alt="Add All"></a></td>
        </tr>
        <tr>
          <td align="center" class="dotline" width="10%"><a href="javascript:MoveSelect(frm.sel_proj, frm.all_proj,'SEL')"><img border="0" src="images/bu_L.gif" align="absmiddle" vspace="5" hspace="5" width="16" height="16" alt="Remove"></a></td>
        </tr>
        <tr>
          <td align="center" class="dotline" width="10%"><a href="javascript:MoveSelect(frm.sel_proj, frm.all_proj,'ALL')"><img border="0" src="images/bu_LL.gif" align="absmiddle" vspace="5" hspace="5" width="16" height="16"  alt="Remove All"></a></td>
        </tr>
        <tr>
          <td align="center" class="dotline" width="10%">&nbsp;</td>
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



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="150" class="act_tab2">

            <a href="#" onclick="javascript:searchRetDoc();"><img border="0" src="images/act_submit.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp; 
			<a href="javascript:clearSelProj();"><img border="0" src="images/act_clear.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>

            </td>   
                  	
                  	
            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="javascript:history.back();"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=Constants.APP_PATH%>/SERV_RetenHome.jsp" target="_self"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
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
		System.out.println("ERROR SERV_ScrDet.jsp : " + e.getMessage());
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