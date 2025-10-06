<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>


<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_PrntRetReten2.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

	String empId = user.getEmpId();
   String selProj = doString.checkString(request.getParameter("sel_project"),"");
   String query = doString.checkString(request.getParameter("query"),"");
   String comId = "";
   String projId = "";

   String lockId = doString.checkString(request.getParameter("lockId"),"");
   lockId = lockId.toUpperCase();
   String project = "";
	String docNo = "";
   if  (selProj.length()==0 && !query.equalsIgnoreCase("YES") && session!=null) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       if (session!=null) { 
		   session.setAttribute("sess_sel_proj",selProj);
	   } else {
	 	 response.sendRedirect(Constants.WARNING_PAGE);
	   }
   }
   if (!selProj.equals("")) {
		comId = selProj.substring(0,2);
		projId = selProj.substring(3);
   }
   //-----====================== Search BOQ Data ================================------//
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	SERV_CommonData common = null;
	int linePerBlock = 5;
	int countLine = 0;

	try {
	    doString str = new doString();

        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();
		stmt1 = conn.createStatement();
		common = new SERV_CommonData(conn);
        //----=======================================----//




       //----============== Generate Condition ================-----//
       String condition = "";
       if (selProj.length()>0 && !selProj.equalsIgnoreCase("ALL"))  {
          condition = " and a.i_company||':'||a.i_project='"+selProj+"'  ";
       }


	if (selProj.trim().length()<=0) {
	   String projList = common.getProjectListByUserId(user.getUserID());
	   if (projList.length()>0) {
	       condition += " and substr(a.i_docno,1,2)||'-'||substr(a.i_docno,3,3) in ("+projList+") ";
	   } else {
	        //----- IF user have 'ALL' Permission THEN set query to select all data ELSE set query to select none data ----------// 
		sql.delete(0,sql.length());
		sql.append(" select count(*) from serv_pstaff  where user_id='").append(user.getUserID()).append("' and proj_id='ALL' ");
		int checkAllPermission = 0;
			servlog.startLog(sql.toString());
	        rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
	        if (rs.next()) {
		   checkAllPermission = rs.getInt(1);
	        }
	        rs.close();

		if (checkAllPermission<=0) {
	           //----- used for user that no project in hand , set for data not load ----//
	           condition += " and a.i_docno='NOPROEJCT' ";
	       } else {
	          selProj = "ALL";
	       }
	   } // end if check projList
	}


	//----======== Manage Parameter for SERV_Add_Reten.jsp ==========----//
	if (selProj.length()==6) {
	    project = selProj.substring(0,2)+selProj.substring(3,6);
	} else {
	    project = "LH000";
	}


	//-----================ Initial Document Status =====================----//
	Hashtable docStatus = new Hashtable();
	sql.delete(0,sql.length());
	servlog.startLog(sql.toString());
	sql.append(" select * from lan:serv_xstd where i_type='60' ");
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	while (rs.next()) {
	    String iCode = doString.checkString(rs.getString("i_code"),"").trim();
	    String nDesc = doString.checkString(doString.DisplayThai(rs.getString("n_desc")),"").trim();
	    docStatus.put(iCode,nDesc);
	} // end while
	rs.close();


%>


<HTML>
<HEAD>
<TITLE>ใบวางเงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">
<!--

   function queryProject() {
       document.forms[0].query.value="yes";
       document.forms[0].target = "";
       document.forms[0].action = "SERV_PrntRetReten2.jsp";
       document.forms[0].submit();
   }

   function PrintRetReten() {
       frmPrntRetReten.target="_blank";
       frmPrntRetReten.action = "SERV_PrintRetRetenServlet";
       frmPrntRetReten.submit();
	   frmPrntRetReten.target="";
   }

//-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM name="frmPrntRetReten" method="post" action="SERV_PrntRetReten2.jsp">

<input type="hidden" name="query" value="">
<input type="hidden" name="comId" value="<%=comId%>">
<input type="hidden" name="projId" value="<%=projId%>">
<input type="hidden" name="empId" value="<%=empId%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            พิมพ์ใบขอคืนเงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม</td>
          <td width="30%" align="right">&nbsp;</td>
        </tr>
      </table>


<br style="font-size:10pt">
                

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
    <td height="22" class="item ; dotline01" width="8%">ชื่อ :</td>
    <td height="22" width="37%" class="dotline01"><%=doString.DisplayThai(user.getEmpName())%></td>
    <td height="22" width="15%" class="item ; dotline01">เลือกโครงการ : </td>
    <td height="22" width="40%" class="dotline01">
    <%=common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:250px' ",true)%></td>
  </tr>
  <tr>
    <td height="22" class="item ; dotline01" width="8%">แปลง :</td>
    <td height="22" width="37%" class="dotline01"><INPUT type="text" name="lockId" class="box" value="<%=lockId%>" style="width:60px">
	&nbsp;&nbsp;
	<a href="javascript:queryProject();"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a>
	</td>
    <td height="22" width="15%" class="item ; dotline01">เลขที่ใบวางเงิน : </td>
    <td height="22" width="40%" class="dotline01">
		  <SELECT size="1" name="i_docno" class="box" style="width:250px" >
              <OPTION value="">----- เลือกรายการ -----</OPTION>
<%
	sql.delete(0,sql.length());
	servlog.startLog(sql.toString());
	sql.append("SELECT i_docno FROM lan:serv_rethd WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_sort = '"+lockId+"' AND i_doc_status IN ('F', 'I', 'S', 'W', 'R', 'O', 'G', 'A','Z','V') ORDER BY i_docno");
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();

	if (rs != null) {
		while (rs.next() == true) {
			docNo = doString.checkString(rs.getString("I_DOCNO"));
%>
              <OPTION value="<%=docNo%>"><%=docNo%></OPTION>
<%
		}// end while
		rs.close();
		rs=null;
	}
%>
                  </SELECT>
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


<br style="font-size:10pt">




<!---====================================== Start Block 1 ===========================================================---->

<!---====================================== End Block 1 ===========================================================---->
<br style="font-size:10pt">
<table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
  <tr>
    <td class="act_tab1"></td>
    <td width="75" class="act_tab2"><A href="javascript:PrintRetReten(frmPrntRetReten)"><IMG border="0" src="images/act_print.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27"></A></td>
    <td class="act_tab3"></td>
    <td class="act_tab4"><a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
      <a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
  </tr>
</table>

<!--/table-->


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
		System.out.println("ERROR SERV_PrntReten.jsp : " + e.getMessage());
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