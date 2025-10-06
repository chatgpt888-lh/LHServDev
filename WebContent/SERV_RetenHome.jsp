<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%!   
	//---- 2022-06-30 , get new method for PAYIN ----//
	private String getTargetPage(String code) {
		return getTargetPage(code,"PAYTO");
	}
	
	private String getTargetPage(String code,String iPayType) {
		String desc = "";
		if (code.equals("N") || code.equals("C")) {
			desc = "SERV_Disp_Reten.jsp";
		} else if (code.equals("Y") || code.equals("P")) {
			desc = "SERV_Conf_Reten.jsp";
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
			if (iPayType.equalsIgnoreCase("PAYIN")) {
				desc = "SERV_DspAll_RetReten.jsp";
			} else {
				desc = "SERV_Conf_SRecevChq.jsp";
			}
		} else if (code.equals("K") || code.equals("E")) {
			if (iPayType.equalsIgnoreCase("PAYIN")) {
				desc = "SERV_DspAll_RetReten.jsp";
			} else {
				desc = "SERV_Conf_CRecevChq.jsp";
			}		
			
		}
	
		return desc;
   }

  private String getTargetPageApprove(String code) {
	String desc = "";
	if (code.equals("W") || code.equals("U")) {
		desc = "SERV_Conf_RetReten.jsp";
	} else if (code.equals("G")) {
		desc = "SERV_Conf_RetReten2.jsp";
	} else if (code.equals("O")) {
		desc = "SERV_Apprv_RetReten.jsp";
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
				//servlog.startLog(sql.toString());
				retName = doString.checkString(rs1.getString("n_pname"))+" "+doString.checkString(rs1.getString("n_name"))+" "+doString.checkString(rs1.getString("n_sname"));
				//servlog.endLog();
			}
			rs1.close();
			rs1=null;
		}
	    }

	} catch (Exception e) {
	   System.out.println("SERV_RetenHome.jsp Error : "+e.getMessage());
	} finally {
	   if (rs1!=null) rs1.close();
	}

	return retName;
   }
  

%>

<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_RetenHome.jsp";
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
       if (selProj.length()>=6 && !selProj.equalsIgnoreCase("ALL"))  {
		   condition = " and a.i_company='"+selProj.substring(0,2)+"' and a.i_project='"+selProj.substring(3,6)+"' ";
           //condition = " and a.i_company||':'||a.i_project='"+selProj+"'  ";
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

System.out.println("reten home.");
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
       document.forms[0].action = "SERV_RetenHome.jsp";
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
            ใบวางเงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม</td>
          <td width="30%" align="right"><a href="SERV_Add_Reten.jsp?Project=<%=project%>"><img border="0" src="images/icon_add_Warranty.gif" align="absmiddle" width="150" height="34"></a></td>
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
    String projectName = "";
    String comId = "";
    String projId = "";
    String docNo = "";
    String iSort = "";
    String dKeyin = "";
    String status = "";
    String statusDesc = "";
    double zReten = 0.0;
    String custType = "";
    String retentId = "";
    String retName = "";
    	
	sql.delete(0,sql.length());
	sql.append(" select trim(a.i_company)||trim(a.i_project)||' '||trim(b.n_project) project_name, a.* from serv_rethd a ")
	      .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project where ")
	      .append(" ((a.i_doc_status in ('N','Y','P')) or (a.i_doc_status='C' and date(a.d_doc_cancl) between today-30 and today)) ")
	      .append(condition+" order by a.i_docno ");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	while (rs.next()) {
	    countLine++;
	    projectName = doString.checkString(doString.DisplayThai(rs.getString("project_name")),"");
	    comId = doString.checkString(rs.getString("i_company"),"");
	    projId = doString.checkString(rs.getString("i_project"),"");
	    docNo = doString.checkString(rs.getString("i_docno"),"");
	    iSort = doString.checkString(rs.getString("i_sort"),"");
	    dKeyin = doString.checkString(DateUtil.ifxToThaiDateNoTime(doString.DisplayThai(rs.getString("d_keyin"))),"");
	    status = doString.checkString(rs.getString("i_doc_status"),"");
	    statusDesc = doString.checkString((String) docStatus.get(status),"");
	    zReten = rs.getDouble("z_reten");

	    custType = doString.checkString(rs.getString("i_ret_custo"),"");
	    retentId = doString.checkString(rs.getString("i_reten"),"");
	    retName = getRetenName(stmt1,custType,retentId,comId,projId,servlog);


        %>
		<tr>
		  <td class="dotline" width="23%"><%=doString.checkString(projectName,"&nbsp;")%></td>
		  <td class="dotline" align="center" width="13%"><A href="<%=getTargetPage(status)%>?init=true&comId=<%=comId%>&projId=<%=projId%>&docNo=<%=docNo%>"><%=docNo%></A></td>
		  <td class="dotline" align="center" width="8%"><%=doString.checkString(iSort,"&nbsp;")%></td>
		  <td class="dotline" align="center" width="9%"><%=doString.checkString(dKeyin,"&nbsp;")%></td>
		  <td class="dotline" width="21%"><%=doString.checkString(doString.DisplayThai(retName),"&nbsp;")%></td>
		  <td class="dotline" align="right" width="10%"><%=doString.displayNumber("###,###,###.00",zReten )%></td>
		  <td class="dotline" align="center" width="16%"><nobr><%=doString.checkString(statusDesc,"&nbsp;")%></nobr></td>
		</tr>
	    <%
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



<!---====================================== Start Block 2 ===========================================================---->
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
	<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
	<td class="item_tab2" width="250">เอกสารขอคืนเงินค้ำประกัน</td>
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
          <td class="col_name" width="20%">โครงการ</td>
          <td class="col_name" width="12%">เลขที่ใบวางเงิน</td>
          <td class="col_name" width="7%">แปลง</td>
          <td class="col_name" width="8%">วันที่แจ้ง</td>
          <td class="col_name" width="18%">ผู้วางเงินค้ำประกัน</td>
          <td class="col_name" width="10%">จำนวนเงิน</td>
          <td class="col_name" width="14%">สถานะ</td>
          <td class="col_name" width="11%">รออนุมัติจาก</td>
        </tr>
	<%
	//-----================ Print Data List =====================----//
	countLine = 0;
    projectName = "";
    comId = "";
    projId = "";
    docNo = "";
    iSort = "";
    dKeyin = "";
    status = "";
    statusDesc = "";
    zReten = 0.0;
    custType = "";
    retentId = "";
    retName = "";
    String apprName = "";
	
	sql.delete(0,sql.length());
	sql.append(" select trim(a.i_company)||trim(a.i_project)||' '||trim(b.n_project) project_name, ")
	      .append(" trim(n_prename_th)||trim(n_nemploy_th)||' '||trim(n_semploy_th) appr_name , a.* from serv_rethd a ")
	      .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
	      .append(" left join docflow:acemploy c on c.i_employ=a.i_cur_apprv ")
	      .append(" where ( (a.i_doc_status='F') or (a.i_doc_status in ('I','S','W','O','R','B','V','U','G') ")
	      //.append(" and a.i_staff_payback='"+user.getEmpId()+"') )  ")
		  .append(" ) ) ")
	      .append(condition+" order by a.i_docno ");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	while (rs.next()) {
	    countLine++;
	    projectName = doString.checkString(doString.DisplayThai(rs.getString("project_name")),"");
	    comId = doString.checkString(rs.getString("i_company"),"");
	    projId = doString.checkString(rs.getString("i_project"),"");
	    docNo = doString.checkString(rs.getString("i_docno"),"");
	    iSort = doString.checkString(rs.getString("i_sort"),"");
	    dKeyin = doString.checkString(DateUtil.ifxToThaiDateNoTime(doString.DisplayThai(rs.getString("d_keyin"))),"");
	    status = doString.checkString(rs.getString("i_doc_status"),"");
	    statusDesc = doString.checkString((String) docStatus.get(status),"");
	    zReten = rs.getDouble("z_reten");

	    custType = doString.checkString(rs.getString("i_ret_custo"),"");
	    retentId = doString.checkString(rs.getString("i_reten"),"");
	    retName = getRetenName(stmt1,custType,retentId,comId,projId,servlog);
	    apprName = doString.checkString(doString.DisplayThai(rs.getString("appr_name")),"");

            %>
		<tr>
		  <td class="dotline" width="20%"><%=doString.checkString(projectName,"&nbsp;")%></td>
		  <td class="dotline" align="center" width="12%"><a href="<%=getTargetPage(status)%>?i_docno=<%=docNo%>"><%=docNo%></a></td>
		  <td class="dotline" align="center" width="7%"><%=doString.checkString(iSort,"&nbsp;")%></td>
		  <td class="dotline" align="center" width="8%"><%=doString.checkString(dKeyin,"&nbsp;")%></td>
		  <td class="dotline" width="18%"><%=doString.checkString(doString.DisplayThai(retName),"&nbsp;")%></td>
		  <td class="dotline" align="right" width="10%"><%=doString.displayNumber("###,###,###.00",zReten )%></td>
		  <td class="dotline" align="center" width="14%"><nobr><%=doString.checkString(statusDesc,"&nbsp;")%></nobr></td>
		  <td class="dotline" align="center" width="11%"><%=doString.checkString(apprName,"&nbsp;")%></td>
		</tr>
	    <%
	}
	rs.close();

	//---- Add blank line when data is less then linePerBlock -----//
	for (int i=countLine;i<=linePerBlock;i++) {
            %>
		<tr>
		  <td class="dotline" width="20%">&nbsp;</td>
		  <td class="dotline" align="center" width="12%">&nbsp;</td>
		  <td class="dotline" align="center" width="7%">&nbsp;</td>
		  <td class="dotline" align="center" width="8%">&nbsp;</td>
		  <td class="dotline" width="18%">&nbsp;</td>
		  <td class="dotline" align="right" width="10%">&nbsp;</td>
		  <td class="dotline" align="center" width="14%">&nbsp;</td>
		  <td class="dotline" align="center" width="11%">&nbsp;</td>
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
<!---====================================== End Block 2 ===========================================================---->



<br style="font-size:10pt">



<!---====================================== Start Block 3 ===========================================================---->
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
	<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
	<td class="item_tab2" width="250">เอกสารรอ Confirm เช็คคืนเงินค้ำประกัน</td>
	<td class="item_tab3"></td>
	<td>&nbsp;</td>
	</tr>
</table>
<table border="0" width="100%" cellspacing="0" cellpadding="0" height="7">
  <tr>
    <td width="5" valign="top" bgcolor="#D7E6FF" height="7"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop" bgcolor="#D7E6FF" height="7">&nbsp;</td>
    <td width="5" valign="top" align="right" bgcolor="#D7E6FF" height="7"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL">

      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td class="col_name" rowspan="2" width="14%">โครงการ</td>
          <td class="col_name" rowspan="2" width="9%">เลขที่ใบวางเงิน</td>
          <td class="col_name" rowspan="2" width="5%">แปลง</td>
          <td class="col_name" rowspan="2" width="10%"><nobr>วันที่คาดว่าจะรับเช็ค / PayIn</nobr></td>
          <td class="col_name" rowspan="2" width="15%">ผู้วางเงินค้ำประกัน</td>
          <td class="col_name" rowspan="2" width="7%">จำนวนเงินคืน</td>
          <td class="col_name" colspan="3" width="20%">รายละเอียดการคืนเงิน</td>
          <td class="col_name" rowspan="2" width="10%">สถานะ</td>
          <td class="col_name" rowspan="2" width="10%">รออนุมัติจาก</td>
        </tr>
        <tr>
          <td class="col_name" width="5%">ประเภท</td>
          <td class="col_name" width="9%">เลขที่เช็ค/บัญชี</td>
          <td class="col_name" width="6%">PV.SQ.</td>
        </tr>        
	<%
	//-----================ Print Data List =====================----//
	countLine = 0;
    projectName = "";
    docNo = "";
    iSort = "";
    apprName = "";
    status = "";
    statusDesc = "";
    String iPvNo = "";
    String dEstChq = "";
    double zPayback = 0.0;
    String iPayType = ""; // 2022-06-30
    
    //-- 2023-02-22 --//
    retName = "";
    comId = "";
    projId = "";
    custType = "";
    retentId = ""; 
    iPvNo = "";
    String payType = "";
    String payNo = "";
    //---------------//
	
	sql.delete(0,sql.length());
	sql.append(" select trim(a.i_company)||trim(a.i_project)||' '||trim(b.n_project) project_name, ")
	      .append(" trim(n_prename_th)||trim(n_nemploy_th)||' '||trim(n_semploy_th) appr_name , a.* from serv_rethd a ")
	      .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
	      .append(" left join docflow:acemploy c on c.i_employ=a.i_cur_apprv ")
	      .append(" left join lan:serv_apprv d on d.i_docno=a.i_docno and d.i_doc_status=a.i_doc_status ")
	      .append(" where ( (a.i_doc_status='E' and a.d_crecv_chq between today-30 and today+15) or ")
	      //.append(" (a.i_doc_status in ('A','K') and a.i_staff_payback='"+user.getEmpId()+"') )  ")
     	  .append(" (a.i_doc_status in ('A','K')) )  ")
	      .append(condition+" order by a.i_docno ");

	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	while (rs.next()) {
	    countLine++;
	    projectName = doString.checkString(doString.DisplayThai(rs.getString("project_name")),"");
	    docNo = doString.checkString(rs.getString("i_docno"),"");
	    iSort = doString.checkString(rs.getString("i_sort"),"");
	    iPvNo = doString.checkString(rs.getString("i_pvno"),"");
	    dEstChq = doString.checkString(DateUtil.ifxToThaiDateNoTime(doString.DisplayThai(rs.getString("d_est_chq"))),"");
	    apprName = doString.checkString(doString.DisplayThai(rs.getString("appr_name")),"");
	    
	    status = doString.checkString(rs.getString("i_doc_status"),"");	    
		if (status.equalsIgnoreCase("A") && iPvNo.trim().length()>0) status = "Z";
	    statusDesc = doString.checkString((String) docStatus.get(status),"");
	    zPayback = rs.getDouble("z_payback");
	    
	    
	    //--- 2022-06-30 , set new status & link ---//
	    iPayType = doString.checkString(rs.getString("i_paytype"),"").trim();
	    if (!status.equalsIgnoreCase("E") && iPayType.equalsIgnoreCase("PAYIN")) {
	    	statusDesc = "รอ PayIn เข้าบัญชี";
	    }
	    //------------------------------------------//
	    
	    
	    //---- 2023-02-02 , data for new column ----//
	    comId = doString.checkString(rs.getString("i_company"),"");
	    projId = doString.checkString(rs.getString("i_project"),"");
	    custType = doString.checkString(rs.getString("i_ret_custo"),"");
	    retentId = doString.checkString(rs.getString("i_reten"),"");	    
	    retName = getRetenName(stmt1,custType,retentId,comId,projId,servlog);
	    
	    if (iPayType.equalsIgnoreCase("PAYIN")) {
	    	payType = "PayIn";
	    	payNo = doString.checkString(rs.getString("i_payacc"),"").trim();
       		if (payNo.length()>=10) {
       			payNo = payNo.substring(0,3)+"-"+payNo.substring(3,4)+"-"+payNo.substring(4,9)+"-"+payNo.substring(9);
       		}
       			    	
			sql.delete(0,sql.length());
			sql.append(" select * from lan:lhpay_std ")
			   .append(" where i_type='R' and i_key1='"+doString.checkString(rs.getString("i_paybnk"),"")+"' ");
			servlog.startLog(sql.toString());
			rs1 = stmt1.executeQuery(sql.toString());
			servlog.endLog();
			while (rs1.next()) {
			    payNo = doString.checkString(rs1.getString("i_key2"),"")+" , "+payNo;
			} // end while
			rs1.close();       		
	    } else {
	    	payType = "PayTo";
	    	payNo = doString.checkString(rs.getString("i_cheque"),"").trim();
       		if (payNo.length()<=0) {
       			//--- no i_chqeuq , find with function ---//
				sql.delete(0,sql.length());
				sql.append(" select spl_fn_chq_no(i_company,i_pvno) as fnc_i_cheque from lan:serv_rethd ")
			       .append(" where i_docno='").append(docNo).append("' ");
				servlog.startLog(sql.toString());
				rs1 = stmt1.executeQuery(sql.toString());
				servlog.endLog();
				if (rs1.next()) {
				    payNo = doString.checkString(doString.DisplayThai(rs1.getString("fnc_i_cheque")),"").trim();
				} // end while
				rs1.close();		        
		        
		        //--- no i_cheque from function , no cheque data ---//
		        if (payNo.length()<=0) {
       				payNo = "<span style='color:red'>ไม่พบเลขที่เช็ค</span>";
       			}
       		}	    
	    }
	    //------------------------------------------//	    

	    %>
		<tr>
		  <td class="dotline"" align="left"><%=doString.checkString(projectName,"&nbsp;")%></td>
		  <td class="dotline" align="center"><a href="<%=getTargetPage(status,iPayType)%>?i_docno=<%=docNo%>"><%=docNo%></a></td>
		  <td class="dotline" align="center"><%=doString.checkString(iSort,"&nbsp;")%></td>
		  <td class="dotline" align="center"><%=doString.checkString(dEstChq,"&nbsp;")%></td>
		  <td class="dotline" align="left"><%=doString.checkString(doString.DisplayThai(retName),"&nbsp;")%></td>
		  <td class="dotline" align="right"><%=doString.displayNumber("###,###,###.00",zPayback )%>&nbsp;</td>
		  <td class="dotline" align="center">&nbsp;<%=doString.checkString(payType,"&nbsp;")%></td>
		  <td class="dotline" align="center">&nbsp;<nobr><%=doString.checkString(payNo,"&nbsp;")%></nobr></td>
		  <td class="dotline" align="center">&nbsp;<%=doString.checkString(iPvNo,"&nbsp;")%></td>
		  <td class="dotline" align="center"><nobr><%=doString.checkString(statusDesc,"&nbsp;")%></nobr></td>
		  <td class="dotline" align="left"><%=doString.checkString(apprName,"&nbsp;")%></td>
		</tr>
	    <%
	}
	rs.close();

	//---- Add blank line when data is less then linePerBlock -----//
	for (int i=countLine;i<=linePerBlock;i++) {
            %>
		<tr>
		  <td class="dotline" align="center">&nbsp;</td>
		  <td class="dotline" align="center">&nbsp;</td>
		  <td class="dotline" align="center">&nbsp;</td>
		  <td class="dotline" align="center">&nbsp;</td>
		  <td class="dotline" align="center">&nbsp;</td>
		  <td class="dotline" align="center">&nbsp;</td>
		  <td class="dotline" align="center">&nbsp;</td>
		  <td class="dotline" align="center">&nbsp;</td>
		  <td class="dotline" align="center">&nbsp;</td>
		  <td class="dotline" align="center">&nbsp;</td>
		  <td class="dotline" align="center">&nbsp;</td>
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
<!---====================================== End Block 3 ===========================================================---->



<br style="font-size:10pt">



<!---====================================== Start Block 4 ===========================================================---->
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
	<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
	<td class="item_tab2" width="250">เอกสารรอตรวจสอบและอนุมัติ</td>
	<td class="item_tab3"></td>
	<td>&nbsp;</td>
	</tr>
</table>
<table border="0" width="100%" cellspacing="0" cellpadding="0" height="7">
  <tr>
    <td width="5" valign="top" bgcolor="#D7E6FF" height="7"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop" bgcolor="#D7E6FF" height="7">&nbsp;</td>
    <td width="5" valign="top" align="right" bgcolor="#D7E6FF" height="7"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL">

      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td class="col_name" width="23%">โครงการ</td>
          <td class="col_name" width="14%">เลขที่ใบวางเงิน</td>
          <td class="col_name" width="7%">แปลง</td>
          <td class="col_name" width="14%">วันที่ขอคืนเงิน</td>
          <td class="col_name" width="14%">จำนวนเงินคืน</td>
          <td class="col_name" width="14%">สถานะ</td>
          <td class="col_name" width="14%">ผู้ขออนุมัติ</td>
        </tr>
	<%
	//-----================ Print Data List =====================----//
	countLine = 0;
    projectName = "";
    docNo = "";
    iSort = "";
    iPvNo = "";
    dEstChq = "";
    apprName = "";
    status = "";
    statusDesc = "";
    zPayback = 0.0;	
    String dStaffPayback = "";
    String iDocStatus = "";
	
	sql.delete(0,sql.length());
	sql.append(" select trim(a.i_company)||trim(a.i_project)||' '||trim(b.n_project) project_name, ")
	      .append(" trim(n_prename_th)||trim(n_nemploy_th)||' '||trim(n_semploy_th) req_name , ")
	      .append(" a.* from serv_rethd a ")
	      .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
	      .append(" left join docflow:acemploy c on c.i_employ=a.i_reten_payback ")
	      .append(" where ( a.i_doc_status in ('W','R','B','O','V','G') and a.i_cur_apprv='"+user.getEmpId()+"')  ")
	      .append(condition+" order by a.i_docno ");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	while (rs.next()) {
	    countLine++;
	    projectName = doString.checkString(doString.DisplayThai(rs.getString("project_name")),"");
	    docNo = doString.checkString(rs.getString("i_docno"),"");
	    iSort = doString.checkString(rs.getString("i_sort"),"");
	    dStaffPayback = doString.checkString(DateUtil.ifxToThaiDateNoTime(doString.DisplayThai(rs.getString("d_staff_payback"))),"");
	    iDocStatus = doString.checkString(rs.getString("i_doc_status"),"");
	    status = doString.checkString(rs.getString("i_doc_status"),"");
	    statusDesc = doString.checkString((String) docStatus.get(status),"");
	    zPayback = rs.getDouble("z_payback");


		//----============= Find Last Request Name ==================---//
		String reqName = "";
		if (iDocStatus.equalsIgnoreCase("W") || iDocStatus.equalsIgnoreCase("R")) {
			//----- Use Reten Payback Name -------//
	       reqName = doString.checkString(doString.DisplayThai(rs.getString("req_name")),"");
		} else if (iDocStatus.equalsIgnoreCase("B") || iDocStatus.equalsIgnoreCase("O") || iDocStatus.equalsIgnoreCase("G")) {
			    //----- Use Approver Name from "W" Step -------//
				sql.delete(0,sql.length());
				sql.append(" select trim(n_prename_th)||trim(n_nemploy_th)||' '||trim(n_semploy_th) req_name from serv_apprv a ")
					  .append(" left join docflow:acemploy c on c.i_employ=a.i_apprv ")
					  .append(" where a.i_doc_status='W' and a.i_flow='R' ")
					  .append(" and a.i_docno='"+docNo+"' ");
				servlog.startLog(sql.toString());
				rs1 = stmt1.executeQuery(sql.toString());
				servlog.endLog();
				if (rs1.next()) {
					reqName = doString.DisplayThai(doString.checkString(rs1.getString("req_name"),"")); 
				}
				rs1.close();

				if (reqName.trim().length()<=0) {
					//----- If Approver Name from "W" is blank , Use Approver Name from "G" instead  -------//
					sql.delete(0,sql.length());
					sql.append(" select trim(n_prename_th)||trim(n_nemploy_th)||' '||trim(n_semploy_th) req_name from serv_apprv a ")
						  .append(" left join docflow:acemploy c on c.i_employ=a.i_apprv ")
						  .append(" where a.i_doc_status='G' and a.i_flow='R' ")
						  .append(" and a.i_docno='"+docNo+"' ");
					servlog.startLog(sql.toString());
					rs1 = stmt1.executeQuery(sql.toString());
					servlog.endLog();
					if (rs1.next()) {
						reqName = doString.DisplayThai(doString.checkString(rs1.getString("req_name"),"")); 
					}
					rs1.close();
				}
		} else if (iDocStatus.equalsIgnoreCase("V")) {
			    //----- Use Approver Name from "O" Step -------//
				sql.delete(0,sql.length());
				sql.append(" select trim(n_prename_th)||trim(n_nemploy_th)||' '||trim(n_semploy_th) req_name from serv_apprv a ")
					  .append(" left join docflow:acemploy c on c.i_employ=a.i_apprv ")
					  .append(" where a.i_doc_status='O' and a.i_flow='R' ")
					  .append(" and a.i_docno='"+docNo+"' ");
				servlog.startLog(sql.toString());
				rs1 = stmt1.executeQuery(sql.toString());
				servlog.endLog();
				if (rs1.next()) {
					reqName = doString.DisplayThai(doString.checkString(rs1.getString("req_name"),"")); 
				}
				rs1.close();
		}


            %>
		<tr>
		  <td class="dotline" width="23%"><%=doString.checkString(projectName,"&nbsp;")%></td>
		  <td class="dotline" align="center" width="14%"><a href="<%=getTargetPageApprove(status)%>?i_docno=<%=docNo%>"><%=docNo%></a></td>
		  <td class="dotline" align="center" width="7%"><%=doString.checkString(iSort,"&nbsp;")%></td>
		  <td class="dotline" align="center" width="14%"><%=doString.checkString(dStaffPayback,"&nbsp;")%></td>
		  <td class="dotline" width="14%" align="right"><%=doString.displayNumber("###,###,###.00",zPayback )%></td>
		  <td class="dotline" align="center" width="14%"><nobr><%=doString.checkString(statusDesc,"&nbsp;")%></nobr></td>
		  <td class="dotline" align="left" width="14%"><%=doString.checkString(reqName,"&nbsp;")%></td>
		</tr>
	    <%
	}
	rs.close();

	//---- Add blank line when data is less then linePerBlock -----//
	for (int i=countLine;i<=linePerBlock;i++) {
            %>
	       <tr>
		  <td class="dotline" width="23%">&nbsp;</td>
		  <td class="dotline" align="center" width="14%">&nbsp;</td>
		  <td class="dotline" align="center" width="7%">&nbsp;</td>
		  <td class="dotline" align="center" width="14%">&nbsp;</td>
		  <td class="dotline" width="14%" align="right">&nbsp;</td>
		  <td class="dotline" align="center" width="14%">&nbsp;</td>
		  <td class="dotline" align="left" width="14%">&nbsp;</td>
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
<!---====================================== End Block 4 ===========================================================---->



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
<!-- /table-->


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
		System.out.println("ERROR SERV_RetenHome.jsp : " + e.getMessage());
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