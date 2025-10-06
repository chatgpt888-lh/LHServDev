<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%!  private String getTargetPage(String code) {
	String desc = "";
	if (code.equals("N") || code.equals("C")) {
		desc = "SERV_Disp_Reten.jsp";
	} else if (code.equals("Y") || code.equals("P")) {
		desc = "SERV_Disp_Reten.jsp";
	} else if (code.equals("F")) {
		desc = "SERV_Add_ReqReten.jsp";
	} else if (code.equals("I") || code.equals("S") || code.equals("W") || code.equals("R") ||code.equals("B") ||code.equals("U")) {
		desc = "SERV_Add_RetReten.jsp";
	} else if (code.equals("G")) {
		desc = "SERV_Conf_RetReten.jsp";
	} else if (code.equals("O")) {
		desc = "SERV_Conf_RetReten2.jsp";
	} else if (code.equals("V")) {
		desc = "SERV_Apprv_RetReten.jsp";
	} else if (code.equals("A") || code.equals("Z")) {
		desc = "SERV_Conf_SRecevChq.jsp";
	} else if (code.equals("K") || code.equals("E")) {
		desc = "SERV_Conf_CRecevChq.jsp";
	}

	return desc;
   }

   public String getRetenName(Statement stmt1,String custType,String retentId,String comId,String projId,ServLog servlog) throws Exception {
        String retName = "";
	ResultSet rs1 = null;
	String sql_str = "";

	try {
	    if (custType.equals("1")) {
		sql_str = "SELECT n_prename, n_ncustomer, n_scustomer FROM lan:acxcusto WHERE i_customer = "+retentId;
		servlog.startLog(sql_str);
		rs1 = stmt1.executeQuery(sql_str);
		servlog.endLog();
		if (rs1 != null) {
			if (rs1.next() == true) {
				retName = doString.checkString(rs1.getString("n_prename"))+" "+doString.checkString(rs1.getString("n_ncustomer"))+ " "+doString.checkString(rs1.getString("n_scustomer"));;
			}
			rs1.close();
			rs1=null;
		}
	    } else {
		if (custType.equals("2")) {
			custType = "05";
		} else {
			custType = "06";
		}
		sql_str = "SELECT n_pname, n_name, n_sname FROM lan:serv_venprj WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_type = '"+custType+"' AND i_vendor = '"+retentId+"'";
		servlog.startLog(sql_str);
		rs1 = stmt1.executeQuery(sql_str);
		servlog.endLog();
		if (rs1 != null) {
			if (rs1.next() == true) {
				retName = doString.checkString(rs1.getString("n_pname"))+" "+doString.checkString(rs1.getString("n_name"))+" "+doString.checkString(rs1.getString("n_sname"));
			}
			rs1.close();
			rs1=null;
		}
	    }

	} catch (Exception e) {
	   System.out.println("SERV_PrntReten.jsp Error : "+e.getMessage());
	} finally {
	   if (rs1!=null) rs1.close();
	}

	return retName;
   }

%>

<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_PrntReten.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);


   String selProj = doString.checkString(request.getParameter("sel_project"),"");
   String query = doString.checkString(request.getParameter("query"),"");
   String project = "";

   if  (selProj.length()==0 && !query.equalsIgnoreCase("YES") && session!=null) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       if (session!=null) { 
		   session.setAttribute("sess_sel_proj",selProj);
	   } else {
	 	 response.sendRedirect(Constants.WARNING_PAGE);
	   }
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
	sql.append(" select * from lan:serv_xstd where i_type='60' ");
	servlog.startLog(sql.toString());
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
       document.forms[0].action = "SERV_PrntReten.jsp";
       document.forms[0].submit();
   }

//-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST">

<input type="hidden" name="query" value="">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            พิมพ์ใบวางเงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม</td>
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
    <%=common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:250px' ",true)%>    
     &nbsp;&nbsp; <a href="#" onclick="queryProject();"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a> </td>
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
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
	<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
	<td class="item_tab2" width="250">เอกสารวางเงินค้ำประกัน</td>
	<td class="item_tab3"></td>
	<td>&nbsp;</td>
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
        <tr>
          <td class="col_name" width="23%">โครงการ</td>
          <td class="col_name" width="13%">เลขที่ใบวางเงิน</td>
          <td class="col_name" width="8%">แปลง</td>
          <td class="col_name" width="9%">วันที่แจ้ง</td>
          <td class="col_name" width="21%">ผู้วางเงินค้ำประกัน</td>
          <td class="col_name" width="10%">จำนวนเงิน</td>
          <td class="col_name" width="16%">สถานะ</td>
        </tr>
	<%
	//-----================ Print Data List =====================----//
	countLine = 0;
	sql.delete(0,sql.length());
	sql.append(" select trim(a.i_company)||trim(a.i_project)||' '||trim(b.n_project) project_name, a.* from serv_rethd a ")
	      .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project where ")
	      .append(" a.i_doc_status = 'Y' ")
	      .append(condition+" order by a.i_docno ");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	while (rs.next()) {
	    countLine++;
	    String projectName = doString.checkString(doString.DisplayThai(rs.getString("project_name")),"");
	    String comId = doString.checkString(rs.getString("i_company"),"");
	    String projId = doString.checkString(rs.getString("i_project"),"");
	    String docNo = doString.checkString(rs.getString("i_docno"),"");
	    String iSort = doString.checkString(rs.getString("i_sort"),"");
	    String dKeyin = doString.checkString(DateUtil.ifxToThaiDateNoTime(doString.DisplayThai(rs.getString("d_keyin"))),"");
	    String status = doString.checkString(rs.getString("i_doc_status"),"");
	    String statusDesc = doString.checkString((String) docStatus.get(status),"");
	    double zReten = rs.getDouble("z_reten");

	    String custType = doString.checkString(rs.getString("i_ret_custo"),"");
	    String retentId = doString.checkString(rs.getString("i_reten"),"");
	    String retName = getRetenName(stmt1,custType,retentId,comId,projId,servlog);
		servlog.startLog(sql.toString());
		rs1 = stmt1.executeQuery("SELECT s_receive FROM lan:serv_payin WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+docNo+"' AND s_receive = 0");
		servlog.endLog();
		if (rs1 != null) {
			if (rs1.next() == true) {
%>
		<tr>
		  <td class="dotline" width="23%"><%=doString.checkString(projectName,"&nbsp;")%></td>
		  <td class="dotline" align="center" width="13%"><A href="<%=getTargetPage(status)%>?init=true&print=true&comId=<%=comId%>&projId=<%=projId%>&docNo=<%=docNo%>"><%=docNo%></A></td>
		  <td class="dotline" align="center" width="8%"><%=doString.checkString(iSort,"&nbsp;")%></td>
		  <td class="dotline" align="center" width="9%"><%=doString.checkString(dKeyin,"&nbsp;")%></td>
		  <td class="dotline" width="21%"><%=doString.checkString(doString.DisplayThai(retName),"&nbsp;")%></td>
		  <td class="dotline" align="right" width="10%"><%=doString.displayNumber("###,###,###.00",zReten )%></td>
		  <td class="dotline" align="center" width="16%"><nobr><%=doString.checkString(statusDesc,"&nbsp;")%></nobr></td>
		</tr>
<%
			}
			rs1.close();
			rs1=null;
		}
	}
	rs.close();

	//---- Add blank line when data is less then linePerBlock -----//
	for (int i=countLine;i<=linePerBlock;i++) {
            %>
		<tr>
		  <td class="dotline" width="23%">&nbsp;</td>
		  <td class="dotline" align="center" width="13%">&nbsp;</td>
		  <td class="dotline" align="center" width="8%">&nbsp;</td>
		  <td class="dotline" align="center" width="9%">&nbsp;</td>
		  <td class="dotline" width="21%">&nbsp;</td>
		  <td class="dotline" align="right" width="10%">&nbsp;</td>
		  <td class="dotline" align="center" width="16%">&nbsp;</td>
		</tr>
	    <%
	}
	//-----================ Print Data List =====================----//
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
<!---====================================== End Block 1 ===========================================================---->
<br style="font-size:10pt">
<table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
  <tr>
    <td class="act_tab1"></td>
    <td width="75" class="act_tab2"></td>
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