<%@page contentType="text/html; charset=TIS-620"%>
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
<%@ include file="confirmLogin.jsp" %>
<%@ include file="PleaseWaiting.jsp" %>
<%!
	// Caching the DataSource - It is obtained in the jspInit() method
	private javax.sql.DataSource ds = null;
	private String subcontext = "java:comp/env";
	private void getDS() throws Exception {
		String dsName = "";
		Context ctx = new InitialContext();
		InitialContext initCtx = new InitialContext();
	
		// Perform a naming service lookup to get the DataSource object.
		Context env = (Context)ctx.lookup(subcontext);
		dsName = (String)env.lookup("DATASOURCE_NAME");
		dsName = subcontext + "/" + dsName;
		ds = (javax.sql.DataSource) initCtx.lookup(dsName);
		ctx.close();
	}
	
	// This Happens Once and is Reused
	public void jspInit() {
		try
		{
			getDS();
		}
		catch(Exception es)
		{
		  es.printStackTrace();
		}
	}
%>


<%
	String userId = user.getUserID();
	doString str = new doString();
	Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
	String cur_year = Integer.toString(rightNow.get(Calendar.YEAR));
	int end_year = 0;
	
   //----============ Declare Variables for input data ===========----//
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
        
%>
<HTML>
<HEAD>
<TITLE></TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript" src="jquery3/jquery-1.10.2.js"></script>

<script language="javascript">
<!--
	function onPleaseWait() {
		document.all.pleasewaitScreen.style.pixelTop = (document.body.scrollTop + 120);
		$('#pleasewaitScreen').show();
		$('#pleasewaitScreen').css('visibility', 'visible');
	}
	
	function offPleaseWait() {
		$('#pleasewaitScreen').css('visibility', 'hidden');
	}
  function goReport() {

	 if (document.forms[0].beg_month.value=="") {
		 alert(" กรุณาเลือกเดือน !");
		 document.forms[0].beg_month.focus();
		 return false;
	 }

	 if (document.forms[0].beg_year.value=="") {
		 alert(" กรุณาเลือกปี !");
		 document.forms[0].beg_year.focus();
		 return false;
	 }

	 if (document.forms[0].end_month.value=="") {
		 alert(" กรุณาเลือกเดือน !");
		 document.forms[0].end_month.focus();
		 return false;
	 }

	 if (document.forms[0].end_year.value=="") {
		 alert(" กรุณาเลือกปี !");
		 document.forms[0].end_year.focus();
		 return false;
	 }
	 
	 if (document.forms[0].sel_proj.options.length==0) {
		 alert(" กรุณาเลือกโครงการอย่างน้อย 1 โครงการ !");
		 return false;
	 }
	 
	 onPleaseWait();  
	 for (i = 0; i < document.forms[0].sel_proj.options.length; i++) {
		document.forms[0].sel_proj.options[i].selected = true;
	 }
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_InfPayRpt1_1.jsp";
     document.forms[0].submit();
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

<FORM ACTION="SERV_InfPayRpt1.jsp" METHOD="POST" name="frm">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp; 
            สรุปการจัดเก็บค่าบริการสาธารณะแยกตามช่วงเวลา</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                
          <td class="item_tab2" width="200">กรุณาเลือกช่วงเวลาที่ต้องการ</td>
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
                <td width="7%" height="22" class="item ; dotline01">ตั้งแต่เดือน :</td>
                <td width="15%" height="22" class="dotline01"> 
				<%end_year = Integer.parseInt(cur_year)+5;%>
				<%=common.genMonthListbox("beg_month","01"," class='box' ")%>&nbsp;ปี&nbsp;
				<%=common.genYearListbox("beg_year",cur_year," class='box' ",2002,(end_year-2002))%>
				</td>
                <td width="5%" height="22" class="item ; dotline01">ถึงเดือน :</td>
                <td width="73%" height="22" class="dotline01"> 
				<%=common.genMonthListbox("end_month","12"," class='box' ")%>&nbsp;ปี&nbsp;
				<%=common.genYearListbox("end_year",cur_year," class='box' ",2002,(end_year-2002))%>
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
          <td width="100%" class="frmL"><table border="0" width="98%" cellspacing="1" cellpadding="0">
              <tr> 
                <td width="8%" align="center" valign="top" bgcolor="#F5F5F5"> 
                  <p> </p></td>
                <td width="38%" valign="top" bgcolor="#F5F5F5">
				  <select size="15" name="all_proj" multiple class="box" style="width:300px" ondblclick="MoveSelect(frm.all_proj, frm.sel_proj,'SEL');">
					<%
						 boolean allProj = false;

						//---================ Normal User ===============----//
						sql.delete(0,sql.length());	
						 sql.append(" select distinct a.com_id,a.proj_id,b.n_project from lan:serv_pstaff a  ")
							   .append(" left join lan:acxprojt b on b.i_company=a.com_id and b.i_project=a.proj_id ")
							   .append(" where a.user_id='").append(userId).append("' ")
							   .append(" order by a.com_id , a.proj_id ");
						 rs = stmt.executeQuery(sql.toString());
						 while (rs.next()) {
							 String comId = doString.checkString(rs.getString("com_id"),"");
							 String projId = doString.checkString(rs.getString("proj_id"),"");
							 String nProj = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");

							 if (projId.equalsIgnoreCase("ALL")) {
								 %>
									<option value='LH:ALL'>--------------เลือกทุกโครงการ--------------</option>
							  <%
								 allProj = true;
								 break;
							 }

							 %><option value='<%=comId+":"+projId%>'><%="["+comId+"-"+projId+"] - "+nProj%></option><%
						 }
						 rs.close();


						//---============== For user who have ALL Project ===============----//
						if (allProj) {
							 int year = Calendar.getInstance().get(Calendar.YEAR);
							 if (year<2400) year += 543;
							 int pYear = year-1;

							sql.delete(0,sql.length());	
							 sql.append(" select distinct a.i_company,a.i_project,b.n_project from lan:acsbudgh a  ")
								   .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
								   .append(" where a.d_year in ( '").append(year).append("' , '").append(pYear).append("' ) ")
								   .append(" and a.i_budg_type in (9)  ")
								   .append(" order by a.i_company , a.i_project ");
							 rs = stmt.executeQuery(sql.toString());
							 while (rs.next()) {
								 String comId = doString.checkString(rs.getString("i_company"),"");
								 String projId = doString.checkString(rs.getString("i_project"),"");
								 String nProj = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
								 if (projId.equalsIgnoreCase("ALL")) {
									 allProj = true;
									 continue;
								 }
								 %><option value='<%=comId+":"+projId%>'><%="["+comId+"-"+projId+"] - "+nProj%></option><%
							 }
							 rs.close();
						}


					%>
				 </select>
				 </td>
                <td width="6%" align="center" valign="middle" bgcolor="#F5F5F5"> 
                  <table border="0" width="100%" cellspacing="1" cellpadding="0">
                    <tr> 
                      <td width="100%" align="center" height="30" bgcolor="#F0F0F0"> 
						<a href="javascript:MoveSelect(frm.all_proj, frm.sel_proj,'SEL')"><img border="0" src="images/b_r.gif" align="absmiddle" vspace="5" hspace="5" alt="Add"></a>
                      </td>
                    </tr>
                    <tr> 
                      <td width="100%" align="center" height="30" bgcolor="#F0F0F0"> 
                       <a href="javascript:MoveSelect(frm.all_proj, frm.sel_proj,'ALL')"><img border="0" src="images/b_rr.gif" align="absmiddle" vspace="5" hspace="5" alt="Add All">
                      </td>
                    </tr>
                    <tr> 
                      <td width="100%" align="center" height="30" bgcolor="#F0F0F0"> 
                        <a href="javascript:MoveSelect(frm.sel_proj, frm.all_proj,'ALL')"><img border="0" src="images/b_ll.gif" align="absmiddle" vspace="5" hspace="5" alt="Remove All"></a>
                      </td>
                    </tr>
                    <tr> 
                      <td width="100%" align="center" height="30" bgcolor="#F0F0F0"> 
                        <a href="javascript:MoveSelect(frm.sel_proj, frm.all_proj,'SEL')"><img border="0" src="images/b_l.gif" align="absmiddle" vspace="5" hspace="5" alt="Remove"></a>
                      </td>
                    </tr>
                  </table></td>
                <td width="38%" align="right" valign="top" bgcolor="#F5F5F5"> 
				  <select size="15" name="sel_proj" multiple class="box" style="width:300px" ondblclick="MoveSelect(frm.sel_proj, frm.all_proj,'SEL');">
				  </select>                  
				 </td>
                <td width="10%" align="center" valign="top" bgcolor="#F5F5F5">&nbsp; 
                </td>
              </tr>
              <tr> 
                <td align="center" valign="top" bgcolor="#F5F5F5" colspan="2">&nbsp;</td>
                <td width="6%" align="center" valign="top" bgcolor="#F5F5F5">&nbsp;</td>
                <td align="center" valign="top" bgcolor="#F5F5F5" colspan="2">&nbsp; 
                </td>
              </tr>
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
<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="80" class="act_tab2">
            <a href="#" onclick="javascript:goReport();"><img border="0" src="images/act_submit.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp; 
            </td>   
            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
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
		stmt.close();
		conn.close();
		stmt=null;
		conn=null;
	} catch (Exception e) {
		System.out.println("ERROR SERV_InfPayRpt1.jsp : " + e.getMessage());
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