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
  private String getTargetPage(String code) {
/*
	String desc = "";
	if (code.equals("N") || code.equals("C")) {
		desc = "SERV_Disp_Reten.jsp";
	} else if (code.equals("Y") || code.equals("P")) {
		desc = "SERV_Conf_Reten.jsp";//
	} else if (code.equals("F")) {
		desc = "SERV_View_RetDoc.jsp";
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
	*/

	return "SERV_DspAll_RetReten.jsp";
   }

%>


<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_ChkRet.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

    doString str = new doString();


   String iSort = doString.DisplayThai(doString.checkString(request.getParameter("i_sort"),"").toUpperCase());
   String iHouse = doString.DisplayThai(doString.checkString(request.getParameter("i_house"),"").toUpperCase());
   String payMonth = doString.checkString(request.getParameter("pay_month"),"");
   String payYear = doString.checkString(request.getParameter("pay_year"),"");
   String searchCustId = doString.DisplayThai(doString.checkString(request.getParameter("cust_id"),""));
   String searchCustName = doString.DisplayThai(doString.checkString(request.getParameter("cust_name"),""));
   String searchEmpName = doString.DisplayThai(doString.checkString(request.getParameter("emp_name"),""));
   String searchEmpSName = doString.DisplayThai(doString.checkString(request.getParameter("emp_sname"),""));
   
   
   String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase();
   if  (selProj.length()==0) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       session.setAttribute("sess_sel_proj",selProj);
   }

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
        if (selProj.trim().length()>=6 && !selProj.equalsIgnoreCase("ALL")) {
           //condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
		   condition = " and a.i_company='"+(selProj.substring(0,2))+"' and a.i_project='"+(selProj.substring(3,6))+"' ";
        }
		if (selProj.trim().length()<=0) {
		   String projList = common.getProjectListByUserId(user.getUserID());
		   if (projList.length()>0) {
		       //condition += " and substr(a.i_docno,1,2)||'-'||substr(a.i_docno,3,3) in ("+projList+") ";

			   //================== modified to used index field =====================//
				if (projList.trim().length()>0) {
					String projCondition = "";
					StringTokenizer plist = new StringTokenizer(projList,",");
					while (plist.hasMoreTokens()) {
						String proj = str.replace(plist.nextToken(),"'","").trim();
						if (proj.length()>=6) {
							String icom = proj.substring(0,2);
							String iproj = proj.substring(3,6);
							if (projCondition.trim().length()>0) projCondition += " or ";
							projCondition += " (a.i_company='"+icom+"' and a.i_project='"+iproj+"') ";
						}
					} // end while

					if (projCondition.trim().length()>0) {
						condition = " and ("+projCondition+") ";
					}
				}
				//===============================================================//
		   } else {

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

		   }
		}


		if (iSort.trim().length()>0) condition += " and a.i_sort='"+iSort+"' ";
		if (iHouse.trim().length()>0) condition += " and a.i_house='"+iHouse+"' ";
		if (payMonth.trim().length()>0) condition += " and month(a.d_keyin)='"+payMonth+"' ";
		if (payYear.trim().length()>0) condition += " and year(a.d_keyin)='"+payYear+"' ";
		if (searchCustId.trim().length()>0) condition += " and a.i_reten='"+searchCustId+"' ";
		if (searchCustName.trim().length()>0) condition += " and upper(a.n_custo) like '%"+searchCustName.toUpperCase()+"%' ";

		if (searchEmpName.trim().length()>0) {
			condition += " and (upper(b.n_ncustomer) like '%"+searchEmpName.toUpperCase()+"%' ";
			condition += " or upper(c.n_name) like '%"+searchEmpName.toUpperCase()+"%' ";
			condition += " or upper(d.n_name) like '%"+searchEmpName.toUpperCase()+"%') ";
		}

		if (searchEmpSName.trim().length()>0) {
			condition += " and (upper(b.n_scustomer) like '%"+searchEmpSName.toUpperCase()+"%' ";
			condition += " or upper(c.n_sname) like '%"+searchEmpSName.toUpperCase()+"%' ";
			condition += " or upper(d.n_sname) like '%"+searchEmpSName.toUpperCase()+"%') ";
		}

 	//---=========================================================================----//



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
   //---===========================================================----//


   //----======================== set status order =====================---//
   Hashtable statusList = new Hashtable();
   statusList.put("N","1");
   statusList.put("C","1");
   statusList.put("Y","2");
   statusList.put("P","2");
   statusList.put("F","3");
   statusList.put("I","4");
   statusList.put("S","4");
   statusList.put("W","4");
   statusList.put("R","4");
   statusList.put("B","4");
   statusList.put("U","4");
   statusList.put("G","5");
   statusList.put("O","6");
   statusList.put("V","7");
   statusList.put("A","8");
   statusList.put("Z","8");
   statusList.put("K","9");
   statusList.put("E","9");
   //---===========================================================----//



	//----====================== Get SERV_RETHD Max Row =========================-----//
	int maxRow = 0;
	sql.delete(0,sql.length());
	sql.append("select count(*) as cnt from serv_rethd a ")
		  .append(" left join lan:acxcusto b on b.i_customer=a.i_reten ")
		  .append(" left join lan:serv_venprj c on c.i_vendor=a.i_reten and ")
		  .append(" c.i_company=a.i_company and c.i_project=a.i_project and c.i_type='05' ")
		  .append(" left join lan:serv_venprj d on d.i_vendor=a.i_reten and ")
		  .append(" d.i_company=a.i_company and d.i_project=a.i_project and d.i_type='06' ")
		  .append(" where a.i_doc_status<>'C' ").append(condition);
//System.out.println(sql.toString());
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
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
	   if (displayLine<Constants.SERV_MANAGERLIST_LINE) displayLine = Constants.SERV_MANAGERLIST_LINE;

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
<TITLE>Report List</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--

  function searchRetReten() {
     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_ChkRet.jsp";
     document.forms[0].submit();
  }

  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_ChkRet.jsp";
     document.forms[0].submit();
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
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ตรวจสอบรายการรอคืนเช็คลูกค้า</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดการค้นหา</td>
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
    <td class="item ; dotline01" height="22" width="11%">โครงการ :</td>
    <td height="22" width="48%" class="dotline01">
    <%
		if (user.getUserWho().equalsIgnoreCase("T")) {
	        //----------- for account , use icv_acpr to select project -------------------//
			%>
			    <select class="box" style="width:300px" name="sel_project">
				<option value="">----- กรุณาเลือก -----</option>
			   <%
				    sql.delete(0,sql.length());
					sql.append(" select unique a.i_company,a.i_project,b.n_project from docflow:icv_acpr a ")
						  .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
						  .append(" where a.i_com_emp='LH' and a.i_employ in ")
						  .append(" ( select i_employ from docflow:icv_acln where i_leader in ")
						  .append("     ( select i_leader from docflow:icv_acln where i_com_emp='LH' and i_employ='").append(user.getEmpId()).append("' ) ")
						  .append(" ) and a.i_project is not null and a.i_company is not null ")
						  .append(" order by a.i_company ,a.i_project ");
					servlog.startLog(sql.toString());
					rs = stmt.executeQuery(sql.toString());
					servlog.endLog();
					while (rs.next()) {
						String comId = doString.checkString(rs.getString("i_company"),"").toUpperCase();
						String projId = doString.checkString(rs.getString("i_project"),"");
						String nCompany = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
					String selected = "";
					if ((comId+":"+projId).equalsIgnoreCase(selProj)) {
						selected = " selected ";
					}
					%><option value="<%=comId+":"+projId%>" <%=selected%>><%=comId+"-"+projId+" - "+nCompany%></option><%
					}
					rs.close();
			   %>
				</select>			
			<%
		} else {
		     //------------- other user except account used this method ---------------//
		    out.println(common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:300px' ",true));
		}
	%>
	</td>
    <td height="22" class="item ; dotline01" width="11%">วันที่วางเงิน
      :</td>
    <td height="22" width="30%" class="dotline01">
	<%=common.genMonthListbox("pay_month",payMonth,"  class='box' style='width:85px' ")%>	
	<%=common.genYearListbox("pay_year",payYear,"  class='box' style='width:55px' ")%>		  
	</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="11%">แปลง
      :</td>
    <td height="22" width="48%" class="dotline01"><input type="text" name="i_sort" class="box" style="width:60px" value="<%=iSort%>"></td>
    <td height="22" class="item ; dotline01" width="11%">บ้านเลขที่
      :</td>
    <td height="22" width="30%" class="dotline01"> <input type="text" name="i_house" class="box" style="width:140px" value="<%=iHouse%>"> </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="11%">ชื่อผู้วางเงิน
      :</td>
    <td height="22" width="48%" class="dotline01"><input type="text" name="emp_name" class="box" style="width:140px" value="<%=searchEmpName%>"> </td>
    <td height="22" class="item ; dotline01" width="11%">นามสกุล :</td>
    <td height="22" width="30%" class="dotline01"> <input type="text" name="emp_sname" class="box" style="width:140px" value="<%=searchEmpSName%>"> </td>
  </tr>

  <tr>
    <td class="item ; dotline01" height="22" width="11%">รหัสลูกค้า
      :</td>
    <td height="22" width="48%" class="dotline01"><input type="text" name="cust_id" class="box" style="width:140px" value="<%=searchCustId%>"> </td>
    <td height="22" class="item ; dotline01" width="11%">ชื่อลูกค้า :</td>
    <td height="22" width="30%" class="dotline01"><input type="text" name="cust_name" class="box" style="width:140px" value="<%=searchCustName%>"> &nbsp;&nbsp;
      <img border="0" src="images/i_search.gif" align="absmiddle" onclick="searchRetReten()" style='cursor:hand;'></td>
    <td height="22" class="item ; dotline01" width="11%" colspan="2">&nbsp;</td>
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
                <td class="item_tab2" width="200">รายการวางเงินค้ำประกัน</td>
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
          <td width="7%" class="col_name">แปลง</td>
          <td width="8%" class="col_name">บ้านเลขที่</td>
          <td width="14%" class="col_name">เลขที่ใบวางเงิน</td>
          <td width="16%" class="col_name">วันเวลาที่แจ้ง</td>
          <td width="30%" class="col_name">ชื่อผู้วางเงิน</td>
          <td width="13%" class="col_name">จน.เงินวางเงิน</td>
          <td width="16%" class="col_name">สถานะ</td>
          <td width="16%" class="col_name">อนุมัติล่าสุด</td>
        </tr>


        <%
        
		     //----================== Select Data from SERV_DOCHD ================----//   
		        int line = 0;		     
		        sql.delete(0,sql.length());
		        sql.append(" select b.n_prename as pname_type1 , b.n_ncustomer as name_type1 , b.n_scustomer as sname_type1 , ")
					  .append(" c.n_pname as pname_type2 , c.n_name as name_type2 , c.n_sname as sname_type2 , ")
					  .append(" d.n_pname as pname_type3 , d.n_name as name_type3 , d.n_sname as sname_type3 , ")
					  .append(" trim(e.n_prename_th)||trim(e.n_nemploy_th)||' '||trim(e.n_semploy_th) as appr_name , ")
				      .append(" a.*  from serv_rethd a ")
					  .append(" left join lan:acxcusto b on b.i_customer=a.i_reten ")
					  .append(" left join lan:serv_venprj c on c.i_vendor=a.i_reten and ")
					  .append(" c.i_company=a.i_company and c.i_project=a.i_project and c.i_type='05' ")
					  .append(" left join lan:serv_venprj d on d.i_vendor=a.i_reten and ")
					  .append(" d.i_company=a.i_company and d.i_project=a.i_project and d.i_type='06' ")
				      .append(" left join docflow:acemploy e on e.i_employ=a.i_cur_apprv ")
					  .append(" where (a.i_pvno is null or (a.i_pvno is not null and a.i_doc_status<>'A' )) ")
				      .append(" and a.i_doc_status<>'C' ").append(condition)
					  .append(" order by a.i_docno ");
				servlog.startLog(sql.toString());
		        rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
		        for (int i=0;i<maxRow;i++) { 
                      if (rs.next()) {
                         if (i>=startRow && i<=endRow) {
                            //------ Data is in this page , display -----//
				            String iDocNo = doString.checkString(rs.getString("i_docno"),"");
				            String i_sort = doString.checkString(rs.getString("i_sort"),"");
				            String i_house = doString.checkString(rs.getString("i_house"),"");
							String status =  doString.checkString(rs.getString("i_doc_status"),"");
							String statusDesc = doString.checkString((String) docStatus.get(status),"");
							String apprName = doString.checkString(doString.DisplayThai(rs.getString("appr_name")),"");
							double zReten = rs.getDouble("z_reten");

							if (apprName.trim().length()>0) apprName = "<br>("+apprName+")";

				            String iCustType = doString.checkString(rs.getString("i_ret_custo"),"");
				            String nCustomer = "";
							if (iCustType.equals("1") || iCustType.equals("2") || iCustType.equals("3")) {
								nCustomer = doString.checkString(doString.DisplayThai(rs.getString("pname_type"+iCustType)),"");
								nCustomer += doString.checkString(doString.DisplayThai(rs.getString("name_type"+iCustType)),"");
								nCustomer += " "+doString.checkString(doString.DisplayThai(rs.getString("sname_type"+iCustType)),"");
							}
													

				            String keyinDate = "-";				            
			                //---- Keyin Date ----// 
						    Calendar keyin = Calendar.getInstance();
						    Timestamp tmp = rs.getTimestamp("d_keyin");
						    if (tmp!=null)  {
						        keyin.setTime(tmp);      
							    keyinDate = getDateFromCalendar(keyin);    
							    keyinDate += "&nbsp;&nbsp;"+getTimeFromCalendar(keyin)+" น.";    		            
						    }



							//-----================ get last approver =====================----//
							String lastApprv = "";
							String lastDApprv = "";
							String lastStatus = "";

							sql.delete(0,sql.length());
							sql.append(" select a.d_apprv,a.i_doc_status,trim(e.n_prename_th)||trim(e.n_nemploy_th) as emp_name ")
								  .append(" from lan:serv_apprv a,docflow:acemploy e where a.i_docno='"+iDocNo+"' ")
								  .append(" and e.i_employ=a.i_apprv and a.i_flow='R' and a.d_apprv in ")
								  .append(" (select max(d_apprv) from lan:serv_apprv where i_docno=a.i_docno) ");
							servlog.startLog(sql.toString());
							rs1 = stmt1.executeQuery(sql.toString());
							servlog.endLog();
							while (rs1.next()) {
								String dstatus = doString.checkString(rs1.getString("i_doc_status"),"").trim();
								String empName = doString.checkString(rs1.getString("emp_name"),"").trim();

								String dApprv = "";
								Timestamp tmp1 = rs1.getTimestamp("d_apprv");
								if (tmp1!=null)  {
									Calendar cal = Calendar.getInstance();
									cal.setTime(tmp1);      
									dApprv = getDateFromCalendar(cal);    
								}

								if (lastApprv.length()>0 && lastDApprv.length()>0 && lastStatus.length()>0) {
									int s1 = Integer.parseInt(doString.checkString((String) statusList.get(status),"0"));
									int s2 = Integer.parseInt(doString.checkString((String) statusList.get(lastStatus),"0"));

									if (s2>s1) {
									   empName = "";
									   dApprv = "";
									   dstatus = "";
									}
								} 


								if (empName.length()>0 && dApprv.length()>0 && dstatus.length()>0) {
									lastApprv = empName;
									lastDApprv = dApprv;
									lastStatus = dstatus;
								}

							} // end while
							rs1.close();
						   //---===========================================================----//
						    


							%>
								<tr>
								  <td width="7%" align="center" class="dotline"><%=doString.checkString(i_sort,"&nbsp;")%></td>
								  <td width="8%" class="dotline" align="center"><%=doString.checkString(i_house,"&nbsp;")%></td>
								  <td width="14%" class="dotline" align="center"><a href="<%=getTargetPage(status)%>?i_docno=<%=doString.checkString(iDocNo,"")%>&status=<%=status%>"><%=doString.checkString(iDocNo,"&nbsp;")%></a></td>
								  <td width="16%" align="center" class="dotline"><%=doString.checkString(keyinDate,"&nbsp;")%></td>
								  <td width="30%" class="dotline ; item"><%=doString.checkString(nCustomer,"&nbsp;")%></td>
								  <td width="13%" align="center" class="dotline"><%=format.format(zReten)%></td>
								  <td width="16%" align="center" class="dotline"><%=doString.checkString(statusDesc,"&nbsp;")+"&nbsp;"+apprName%></td>
								  <td width="16%" align="center" class="dotline"><nobr><%=doString.DisplayThai(lastApprv)+"<br>"+lastDApprv%></nobr></td>
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
					  <td width="7%" align="center" class="dotline">&nbsp;</td>
					  <td width="8%" class="dotline" align="center">&nbsp;</td>
					  <td width="14%" class="dotline" align="center">&nbsp;</td>
					  <td width="16%" align="center" class="dotline">&nbsp;</td>
					  <td width="30%" class="dotline ; item">&nbsp;</td>
					  <td width="13%" align="center" class="dotline">&nbsp;</td>
					  <td width="16%" align="center" class="dotline">&nbsp;</td>
					  <td width="16%" align="center" class="dotline">&nbsp;</td>
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
            <td width="75" class="act_tab2">

            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:history.back()" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
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
		System.out.println("ERROR SERV_ChkRet.jsp : " + e.getMessage());
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