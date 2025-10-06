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


<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_DspAll_RetReten.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   doString str = new doString();
   DecimalFormat format = new DecimalFormat("#,##0.00");

   //----============ Declare Variables for input data ===========----//
   String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase();
   if  (selProj.length()==0) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       session.setAttribute("sess_sel_proj",selProj);
   }

   String docNo = doString.checkString(request.getParameter("i_docno"),"").toUpperCase();
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


	String projectName = "";
	String iSort = "";
	String iHouse = "";
	String iDocNo = "";
	String iCompany = "";
	String iProject = "";
	String iSignBoard = "";
	String retCustName = "";
	String nCustName = "";
	String guranteeDesc = "";
        String retCustType = "";
        String iReten = "";
	String empName = "";
	String iDocStatus = "";
	String iLor = "";
	String fInSpec = "";
	String iSpec = "";
	String cDamage = "";
	String cPayback = "";
	String iCurApprove = "";
	String cApprv = "";
	String cPrevApprv = "";

	String dPayCheque = "";
	String mPayCheque = "";
	String yPayCheque = "";

	Vector iReceipt = new Vector();
	Vector zReceiveReten = new Vector();

	String fIDCard = "";
	String fLoseReten = "";
	String fNotice = "";
	String iNotice = "";
	 
	//---- 2022-06-30 , for payin ----//
	String iPayType = "";
	String iPayBnk = "";
	String nPayBnk = "";
	String iPayAcc = "";
	String iEmail = "";
	//-------------------------------//		

	double zReten = 0.0;
	double zDamage = 0.0;
        String reqDate = "";

	//-----======== Get Reten Data ==========----//
	sql.delete(0,sql.length());
	sql.append(" select b.i_company||b.i_project||' | '||b.n_project as project_name , c.n_desc , e.c_apprv , ")
	      .append(" f.c_apprv as  c_prev_apprv , s.n_desc as n_paybnk , ")
	      .append(" trim(d.n_prename_th)||trim(d.n_nemploy_th)||' '||trim(d.n_semploy_th) as emp_name ,a.* from lan:serv_rethd a ")
	      .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
	      .append(" left join lan:serv_xstd c on c.i_type='50' and c.i_code=a.i_doc_type ")
	      //----- 2022-06-30 , add payin query ------//
	      .append(" left join lan:lhpay_std s on s.i_type='R' and s.i_key1=a.i_paybnk ")
	      //-----------------------------------------//	
	      .append(" left join docflow:acemploy d on d.i_employ=a.i_reten_payback ")
	      .append(" left join lan:serv_apprv e on e.i_docno=a.i_docno and e.i_doc_status='V' ")
	      .append(" left join lan:serv_apprv f on f.i_docno=a.i_docno and f.i_doc_status='O' ")
	      .append(" where a.i_docno='").append(docNo).append("' ");
	      //.append(" where a.z_reten=a.z_recv_reten  and a.i_staff_payback is not null ")
	      //.append(" and a.i_docno='").append(docNo).append("' ");
	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	while (rs.next()) {
             projectName = doString.checkString(doString.DisplayThai(rs.getString("project_name")),"");
             iSort = doString.checkString(rs.getString("i_sort"),"");
             iHouse = doString.checkString(rs.getString("i_house"),"");
             iDocNo = doString.checkString(rs.getString("i_docno"),"");
             iCompany = doString.checkString(rs.getString("i_company"),"");
             iProject = doString.checkString(rs.getString("i_project"),"");
             iSignBoard = doString.checkString(rs.getString("i_signboard"),"");
             nCustName = doString.checkString(doString.DisplayThai(rs.getString("n_custo")),"");
             guranteeDesc = doString.checkString(doString.DisplayThai(rs.getString("n_desc")),"");
             retCustType = doString.checkString(rs.getString("i_ret_custo"),"");
             iReten = doString.checkString(rs.getString("i_reten"),"");
             iLor = doString.checkString(rs.getString("i_lor"),"");
             iDocStatus = doString.checkString(rs.getString("i_doc_status"),"");
             empName = doString.checkString(doString.DisplayThai(rs.getString("emp_name")),"");
             zReten = rs.getDouble("z_reten");
             zDamage = rs.getDouble("z_damage");

             iCurApprove = doString.checkString(rs.getString("i_cur_apprv"),"");
             fIDCard = doString.checkString(rs.getString("f_id_card"),"");
             fLoseReten = doString.checkString(rs.getString("f_lost_reten"),"");
             fInSpec = doString.checkString(rs.getString("f_inspec"),"");
             cDamage = doString.checkString(doString.DisplayThai(rs.getString("c_damage")),"");
             cPayback = doString.checkString(doString.DisplayThai(rs.getString("c_payback")),"");
             cApprv = doString.checkString(doString.DisplayThai(rs.getString("c_apprv")),"");
             cPrevApprv = doString.checkString(doString.DisplayThai(rs.getString("c_prev_apprv")),"");
             iSpec = doString.checkString(rs.getString("i_inspec"),"");
             iNotice = doString.checkString(rs.getString("i_notice"),"");
             if (iNotice.trim().length()>0) fNotice = "Y";
             
			//---- 2022-06-30 , for payin ----//
			iPayType = doString.checkString(rs.getString("i_paytype"),"");
			iPayBnk = doString.checkString(rs.getString("i_paybnk"),"");
			nPayBnk = doString.checkString(rs.getString("n_paybnk"),"");
			iPayAcc = doString.checkString(rs.getString("i_payacc"),"");
			iEmail = doString.checkString(rs.getString("i_email"),"");
			//-------------------------------//			             

	    Calendar est = Calendar.getInstance(Locale.ENGLISH);
   	    Timestamp tmp = rs.getTimestamp("d_reten_payback");
	    if (tmp!=null) {
		 est.setTime(tmp);
		 reqDate =  getDateFromCalendar(est)+"&nbsp;,&nbsp;"+getTimeFromCalendar(est)+" น.";
	    } else {
	         reqDate = "";
	    }

	    est = Calendar.getInstance(Locale.ENGLISH);
   	    tmp = rs.getTimestamp("d_est_chq");
	    if (tmp!=null) {
		 est.setTime(tmp);
		 dPayCheque = str.createID(est.get(Calendar.DATE),2);
		 mPayCheque = str.createID(est.get(Calendar.MONTH)+1,2);
		 yPayCheque = str.createID(est.get(Calendar.YEAR),4);
	    } else {
	         reqDate = "";
		 dPayCheque = "";
		 mPayCheque = "";
		 yPayCheque = "";
	    }

	}
	rs.close();


        //-----========== Get retCustName ============-----//
        sql.delete(0,sql.length());
        if (retCustType.equals("1")) {
   	    sql.append(" select trim(n_prename)||trim(n_ncustomer)||' '||trim(n_scustomer) as cust_name ")
	          .append(" from lan:acxcusto where i_customer='").append(iReten).append("' ");
        } else if (retCustType.equals("2")) {
	    sql.append(" select trim(nvl(n_pname,''))||trim(nvl(n_name,''))||' '||trim(nvl(n_sname,'')) as cust_name ")
	          .append(" from lan:serv_venprj where i_vendor='").append(iReten).append("' ")
	          .append(" and i_company='").append(iCompany).append("' and i_project='").append(iProject).append("' ")
	          .append(" and i_type='05' ");
        } else {
   	    sql.append(" select trim(nvl(n_pname,''))||trim(nvl(n_name,''))||' '||trim(nvl(n_sname,'')) as cust_name ")
	          .append(" from lan:serv_venprj where i_vendor='").append(iReten).append("' ")
	          .append(" and i_company='").append(iCompany).append("' and i_project='").append(iProject).append("' ")
	          .append(" and i_type='06' ");
        }
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
	if (rs.next()) {
	    retCustName = doString.checkString(doString.DisplayThai(rs.getString("cust_name")),"");
	}
	rs.close();


        //-----========== Get Receive  ============-----//
        sql.delete(0,sql.length());
 	sql.append(" select * from serv_payin where ")
	      .append(" i_company='").append(iCompany).append("' and i_project='").append(iProject).append("' ")
	      .append(" and i_sort='").append(iSort).append("' and i_docno='").append(iDocNo).append("' ")
	      .append(" and i_lor='").append(iLor).append("' and i_cashier_conf is not null ");
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
	while (rs.next()) {
	    iReceipt.addElement(doString.checkString(rs.getString("i_receipt"),""));
	    zReceiveReten.addElement(new Double(rs.getDouble("z_recv_reten")));
	} // end while rs
	rs.close();

%>

<HTML>
<HEAD>
<TITLE>ใบวางเงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">

function approveRetReten() {
     if (confirm("คุณแน่ใจว่าต้องการ Approve ใบรายการนี้  ?")) {	
        document.forms[0].approve_flag.value="V";
        document.forms[0].submit();
     }
}

function routebackRetReten() {
     if (document.forms[0].c_apprv.value=="") {
         alert(" กรุณากรอกเหตุผลการ Route Back ! ");
	 document.forms[0].c_apprv.focus();
	 return false;
     }

     if (confirm("คุณแน่ใจว่าต้องการ Route Back ใบรายการนี้ ?")) {	
        document.forms[0].approve_flag.value="B";
        document.forms[0].submit();
     }
}
</script>


<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<form action="<%=Constants.APP_PATH%>/SERV_Apprv_RetRetenServlet" method="post">


<input type="hidden" name="i_docno" value="<%=doString.checkString(iDocNo,"")%>">
<input type="hidden" name="i_company" value="<%=doString.checkString(iCompany,"")%>">
<input type="hidden" name="i_project" value="<%=doString.checkString(iProject,"")%>">
<input type="hidden" name="i_doc_status" value="<%=doString.checkString(iDocStatus,"")%>">
<input type="hidden" name="approve_flag" value="">



<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="80%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ใบวางเงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม</td>
          <td width="20%" class="bigh" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">



            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="220">รายละเอียดการรับแจ้งขอคืนเงินค้ำประกัน</td>
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
    <td class="item ; dotline01" height="22" width="18%">โครงการ
      :</td>
    <td height="22" width="38%" class="dotline01"><%=doString.checkString(projectName,"-")%></td>
    <td height="22" class="item ; dotline01" width="16%">แปลง :</td>
    <td height="22" width="28%" class="dotline01"><%=doString.checkString(iSort,"-")%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="18%">บ้านเลขที่
      :</td>
    <td height="22" width="38%" class="dotline01"><%=doString.checkString(iHouse,"-")%></td>
    <td height="22" class="item ; dotline01" width="16%">เลขที่ใบวางเงิน
      :</td>
    <td height="22" width="28%" class="dotline01"><%=doString.checkString(iDocNo,"-")%> </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="18%">ผู้วางเงินค้ำประกัน
      :</td>
    <td height="22" width="38%" class="dotline01"><%=doString.checkString(retCustName,"-")%></td>
    <td height="22" class="item ; dotline01" width="16%">ลูกค้า :</td>
    <td height="22" width="28%" class="dotline01"><%=doString.checkString(nCustName,"-")%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="18%">เพื่อค้ำประกัน
      :</td>
    <td height="22" width="38%" class="dotline01"><%=doString.checkString(guranteeDesc,"-")%></td>
    <td height="22" class="item ; dotline01" width="16%">จำนวนเงินค้ำประกัน
      :</td>
    <td height="22" width="28%" class="dotline01">
    <input type="hidden" name="z_reten" value="<%=zReten%>">
    <%=format.format(zReten)%>&nbsp; บาท</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="18%">ผู้รับเรื่อง
      :</td>
    <td height="22" width="38%" class="dotline01"><%=doString.checkString(empName,"-")%></td>
    <td height="22" class="item ; dotline01" width="16%">วันเวลาที่แจ้ง
      :</td>
    <td height="22" width="28%" class="dotline01"><%=doString.checkString(reqDate,"-")%></td>
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
                <td class="item_tab2" width="200">รายละเอียดการคืนเงินค้ำประกันฯ</td>
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
    <td width="16%" height="22" class="item ; dotline01" valign="top">ผู้รับเงินตามเช็ค
      :</td>
    <td width="38%" height="22" class="dotline01" valign="top"><%=doString.checkString(retCustName,"-")%></td>
    <td width="16%" height="22" class="item ; dotline01" valign="top">อ้างอิงใบเสร็จเลขที่
      :</td>
    <td width="30%" height="22" class="dotline01" align='left'>
  <%
      if (iReceipt.size()>0) {
          for (int i=0;i<iReceipt.size();i++) {
	         String receiptNo = (String) iReceipt.elementAt(i);
		 if (i>0) out.println("<br>");
		  %><%=doString.checkString(receiptNo,"-")%> <%
	  } // end for
      } else {
          %>-<%
      }
    %>
    </td>
  </tr>
  </table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="16%" height="22" class="item ; dotline01">ผลการตรวจงาน</td>
    <td height="22" class="item ; dotline01" colspan="3">
    <img border="0" src="images/i_list.gif" align="absmiddle" width="18" height="18" style="cursor:hand" onClick="MM_openBrWindow('SERV_View_RetDoc.jsp?i_docno=<%=iDocNo%>','blank','width=650,height=310,left=140,top=80')">
    </td>
  </tr>
  <tr>
    <td width="16%" height="22" class="item ; dotline01">&nbsp;</td>
    <td width="16%" height="22" class="dotline01">
    <input type="radio" value="Y" name="f_inspec" <%=fInSpec.equalsIgnoreCase("Y") ? " checked " : ""%> disabled> สภาพเรียบร้อย</td>
    <td width="16%" height="22" class="dotline01">&nbsp;</td>
    <td width="52%" height="22" class="dotline01">&nbsp;</td>
  </tr>
  <tr>
    <td width="16%" height="22" class="item ; dotline01">&nbsp;</td>
    <td width="16%" height="22" class="dotline01">
    <input type="radio" value="N" name="f_inspec" <%=fInSpec.equalsIgnoreCase("N") ? " checked " : ""%> disabled> เกิดความเสียหาย</td>
    <td width="16%" height="22" class="dotline01">
      ตามใบประเมินเลขที่ :&nbsp;</td>
    <td width="52%" height="22" class="dotline01"> <input type="text" disabled name="i_inspec" class="box" style="width:100px" value="<%=iSpec%>"></td>
  </tr>
  <tr>
    <td width="16%" height="22" class="item ; dotline01" valign="top">&nbsp;</td>
    <td width="16%" height="22" class="dotline01" valign="top">&nbsp;</td>
    <td width="16%" height="22" class="dotline01" valign="top">ระบุความเสียหาย
      :</td>
    <td width="52%" height="22" class="dotline01" valign="top">
    <textarea rows="3" name="c_damage" cols="20" class="box" style="width:100%" disabled><%=cDamage%></textarea></td>
  </tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td class="item ; dotline01" height="22" width="100%" colspan="6">สรุปยอดคืนเงินค้ำประกัน
      :</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="5%">&nbsp;</td>
    <td height="22" width="20%" class="dotline01">ยอดเงินวางค้ำประกัน
      :</td>
    <td height="22" width="15%" class="dotline01" align="right"><%=format.format(zReten)%></td>
    <td height="22" width="14%" class="dotline01">&nbsp; บาท</td>
    <td height="22" width="16%" class="dotline01">&nbsp;</td>
    <td height="22" width="30%" class="dotline01">&nbsp;</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="5%">&nbsp;</td>
    <td height="22" width="20%" class="dotline01">หัก
      เงินค่าความเสียหาย :</td>
    <td height="22" width="15%" class="dotline01" align="right">
    <input type="text" name="z_damage" onchange="calculateDamageValue();" disabled class="boxR" style="width:100px" size="20" value="<%=format.format(zDamage)%>">
    </td>
    <td height="22" width="14%" class="dotline01">&nbsp; บาท</td>
    <td height="22" width="16%" class="dotline01">&nbsp;</td>
    <td height="22" width="30%" class="dotline01">&nbsp;</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="5%">&nbsp;</td>
    <td height="22" width="20%" class="dotline01">ยอดคืนเงินค้ำประกัน
      :</td>
    <td height="22" width="15%" class="dotline01" align="right"><span id="show_remain"><%=format.format(zReten-zDamage)%></span></td>
    <td height="22" width="14%" class="dotline01">&nbsp; บาท</td>
    <td height="22" width="16%" class="dotline01 ; item">วันที่ต้องการรับเช็ค
      :</td>
    <td height="22" width="30%" class="dotline01">
    <input type="text" name="d_pay_cheque" class="boxC" style="width:30px" disabled value="<%=dPayCheque%>">/
    <input type="text" name="m_pay_cheque" class="boxC" style="width:30px" disabled value="<%=mPayCheque%>">/
    <input type="text" name="y_pay_cheque" class="boxC" style="width:30px" disabled  value="<%=yPayCheque%>"></td>
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


	  <!--============================ 2022-06-30 , add refund block ========================================-->		 
      <BR style="font-size:10pt">
      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
        <TBODY>
          <TR>
            <TD class="item_tab1"><IMG border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></TD>
            <TD class="item_tab2" width="200">รายละเอียดการคืนเงิน</TD>
            <TD class="item_tab3"></TD>
            <TD>&nbsp;</TD>
          </TR>
        </TBODY>
      </TABLE>
      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
        <TBODY>
          <TR>
            <TD width="5" valign="top"><IMG border="0" src="images/Corn01.gif" width="5" height="5"></TD>
            <TD class="frmTop">&nbsp;</TD>
            <TD width="5" valign="top" align="right"><IMG border="0" src="images/Corn02.gif" width="5" height="5"></TD>
          </TR>
        </TBODY>
      </TABLE>
      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
        <TBODY>
          <TR>
            <TD width="100%" class="frmLR" align="center">
            <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
              <TBODY>
                <%
                	if (iPayType.equalsIgnoreCase("PAYIN")) {
                		//--- payin , display bank & account ---//
                		if (iPayAcc.length()>=10) {
                			iPayAcc = iPayAcc.substring(0,3)+"-"+iPayAcc.substring(3,4)+"-"+iPayAcc.substring(4,9)+"-"+iPayAcc.substring(9);
                		}
                		
						%>
		                <TR>                  
						  <TD class="item ; dotline01" height="22" width="13%">Pay-In เข้าบัญชี   : </TD>
						  <TD class="dotline01" height="22" width="20%">ธนาคาร<%=doString.DisplayThai(nPayBnk) %></TD>
						  <TD class="item ; dotline01" height="22" width="13%"> ชื่อบัญชี : </TD>
						  <TD class="dotline01" height="22" width="20%">&nbsp;<%=doString.checkString(retCustName,"-") %></TD>
						  <TD class="item ; dotline01" height="22" width="14%"> เลขที่บัญชี  : </TD>
						  <TD class="dotline01" height="22" width="20%">&nbsp;<%=doString.checkString(iPayAcc,"-") %></TD>                
		                </TR>  
		                <!-- 
		                <TR>                  
						  <TD class="item ; dotline01" height="22"><nobr>E-Mail แจ้งกลับ กรณี Pay-In เรียบร้อยแล้ว : </nobr></TD>
						  <TD class="dotline01" height="22" colspan="5"><%=doString.checkString(iEmail,"-") %></TD>
						</TR>
						-->						
		                <%
                	} else {
                		//--- payto , display cheque name ---//
                		%>	 
		                <TR>          
						  <TD class="item ; dotline01" height="22" width="13%"><nobr>เช็คคืนเงิน สั่งจ่ายในนาม : </nobr></TD>
						  <TD class="dotline01" height="22" width="87%"><%=doString.checkString(retCustName,"-") %></TD>		                
		                </TR> 	                		
                		<%
                	}
                %> 
                <TR>
                  <TD class="item ; dotline01" height="22" colspan="3">
                  <span style="color:red">* การคืนเงินจะทำคืนในชื่อของผู้วางเงินค้ำประกันเท่านั้น ไม่สามารถคืนเงินในชื่อคนอื่นได้</span>
                  </TD>
                </TR>                                  
              </TBODY>
            </TABLE>
            </TD>
          </TR>
        </TBODY>
      </TABLE>
      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
        <TBODY>
          <TR>
            <TD width="5" valign="bottom"><IMG border="0" src="images/Corn03.gif" width="5" height="5"></TD>
            <TD class="frmBottom">&nbsp;</TD>
            <TD width="5" valign="bottom" align="right"><IMG border="0" src="images/Corn04.gif" width="5" height="5"></TD>
          </TR>
        </TBODY>
      </TABLE>                       
	  <!--===================================================================================================-->	  
	  

<br style="font-size:10pt">



            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">Comment &nbsp; ผู้อนุมัติ</td>
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
    <td width="100%" class="frmLRpad01"><textarea rows="5" name="c_apprv" <%=iDocStatus.equals("O") ? "" : " disabled "%> class="box" style="width:100%" cols="20"><%=cApprv%></textarea></td>
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
          <td width="50%" style="padding-right:5px">
          

            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">Comment&nbsp;&nbsp; การขอคืน</td>
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
    <td width="100%" class="frmLRpad01"><textarea rows="5" name="c_payback" disabled class="box" style="width:100%" cols="20"><%=cPayback%></textarea></td>
  </tr>
</table>



<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>

          
          
          </td>
          <td width="50%" style="padding-left:5px">
          

            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">Comment&nbsp;
                  ผู้ตรวจเอกสาร</td>
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
    <td width="100%" class="frmLRpad01"><textarea rows="5" name="c_prev_apprv" disabled class="box" style="width:100%" cols="20"><%=cPrevApprv%></textarea></td>
  </tr>
</table>



<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>
  
          
          
          </td>
        </tr>
      </table>
                


<br style="font-size:10pt">



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>

		    <td width="160" class="act_tab2">	&nbsp; </td>


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

</BODY>

</HTML>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_Add_RetReten.jsp : " + e.getMessage());
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
