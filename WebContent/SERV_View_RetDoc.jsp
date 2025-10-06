<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="java.text.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_View_RetDoc.jsp";
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

	Vector iReceipt = new Vector();
	Vector zReceiveReten = new Vector();
	Vector dPayin = new Vector();

	String fIDCard = "";
	String fLoseReten = "";
	String fNotice = "";
	String iNotice = "";

	double zReten = 0.0;
        String reqDate = getDateFromCalendar(Calendar.getInstance())+"&nbsp;"+getTimeFromCalendar(Calendar.getInstance());


	//-----======== Get Reten Data ==========----//
	sql.delete(0,sql.length());
	sql.append(" select b.i_company||b.i_project||' | '||b.n_project as project_name , c.n_desc , ")
	      .append(" trim(d.n_prename_th)||trim(d.n_nemploy_th)||' '||trim(d.n_semploy_th) as emp_name ,a.* from lan:serv_rethd a ")
	      .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
	      .append(" left join lan:serv_xstd c on c.i_type='50' and c.i_code=a.i_doc_type ")
	      .append(" left join docflow:acemploy d on d.i_employ=a.i_staff_payback ")
	      //.append(" where a.i_doc_status in ('I','S','R','B','W') and a.z_reten=a.z_recv_reten and a.i_staff_payback is not null ")
	      .append(" where a.z_reten=a.z_recv_reten and a.i_staff_payback is not null ")
	      .append(" and a.i_docno='").append(docNo).append("' ");

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
             empName = doString.checkString(doString.DisplayThai(rs.getString("emp_name")),"");
             zReten = rs.getDouble("z_reten");

             fIDCard = doString.checkString(rs.getString("f_id_card"),"");
             fLoseReten = doString.checkString(rs.getString("f_lost_reten"),"");
             iNotice = doString.checkString(rs.getString("i_notice"),"");
             if (iNotice.trim().length()>0) fNotice = "Y";

	    Calendar payin = Calendar.getInstance(Locale.ENGLISH);
   	    Timestamp tmp = rs.getTimestamp("d_staff_payback");
	    if (tmp!=null) {
		 payin.setTime(tmp); 
		 reqDate = getDateFromCalendar(payin);
	    } else {
	         reqDate = "";
	    }

	}
	rs.close();


        //-----========== Get retCustName ============-----//
        sql.delete(0,sql.length());
        if (retCustType.equals("1")) {
   	    sql.append(" select trim(n_prename)||trim(n_ncustomer)||' '||trim(n_scustomer) as cust_name ")
	          .append(" from lan:acxcusto where i_customer='").append(iReten).append("' ");
        } else if (retCustType.equals("2")) {
	    sql.append(" select trim(n_pname)||trim(n_name)||' '||trim(n_sname) as cust_name ")
	          .append(" from lan:serv_venprj where i_vendor='").append(iReten).append("' ")
	          .append(" and i_company='").append(iCompany).append("' and i_project='").append(iProject).append("' ")
	          .append(" and i_type='05' ");
        } else {
   	    sql.append(" select trim(n_pname)||trim(n_name)||' '||trim(n_sname) as cust_name ")
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
	      .append(" and i_sort='").append(iSort).append("' and i_docno='").append(iDocNo).append("' ");
		servlog.startLog(sql.toString());
        rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
	while (rs.next()) {

	    iReceipt.addElement(doString.checkString(rs.getString("i_receipt"),""));
	    zReceiveReten.addElement(new Double(rs.getDouble("z_recv_reten")));

	    Calendar payin = Calendar.getInstance(Locale.ENGLISH);
   	    Timestamp tmp = rs.getTimestamp("d_payin");
	    if (tmp!=null) {
		 payin.setTime(tmp); 
		 dPayin.addElement(getDateFromCalendar(payin));
	    } else {
	         dPayin.addElement("");
	    }

	} // end while rs
	rs.close();


%>

<HTML>
<HEAD>
<TITLE>Pop up - ใบวางเงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">



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
                <td class="item_tab2" width="220">เอกสารประกอบการขอคืน</td>
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
    <td class="item ; dotline01" height="22" width="20%">
    <nobr><input type="checkbox" name="f_id_card" value="Y" disabled <%=fIDCard.equalsIgnoreCase("Y") ? " checked " : ""%>>
      สำเนาบัตรประชาชน : </nobr></td>
    <td height="22" class="dotline01" width="28%" colspan="5">&nbsp;</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="20%">
    <nobr><nobr><input type="checkbox" name="f_docno" value="Y" checked disabled>   
      เลขที่ใบวางเงินค้ำประกัน
      :</nobr></nobr></td>
    <td height="22" class="dotline01" width="28%"><%=doString.checkString(iDocNo,"-")%></td>
    <td height="22" class="dotline01" colspan="4">
    <nobr><input type="checkbox" name="f_lose_reten" value="Y" disabled  <%=fLoseReten.equalsIgnoreCase("Y") ? " checked " : ""%>>
      ใบวางเงินค้ำประกันหาย</nobr></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="20%">
    <nobr><input type="checkbox" name="f_signboard" value="Y" checked disabled>
      ป้ายต่อเติม เลขที่ :</nobr></td>
    <td height="22" class="dotline01" width="28%"><%=doString.checkString(iSignBoard,"-")%></td>
    <td height="22" class="item ; dotline01" width="17%">&nbsp;</td>
    <td height="22" class="dotline01" width="35%" colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="20%">
    <nobr><input type="checkbox" name="f_notice" value="Y" disabled <%=fNotice.equalsIgnoreCase("Y") ? " checked " : ""%>>
      ใบแจ้งความ เลขที่
      :</nobr></td>
    <td height="22" class="dotline01" width="28%">
    <input type="text" name="i_notice" class="box" disabled maxlength="20" style="width:150px" value="<%=iNotice%>"></td>
    <td height="22" class="dotline01" colspan="4">&nbsp;(กรณีใบเสร็จรับเงินหาย)</td>
  </tr>
  <%
      if (iReceipt.size()>0) {
          for (int i=0;i<iReceipt.size();i++) {
	         String receiptNo = (String) iReceipt.elementAt(i);
		 Double recvReten = (Double) zReceiveReten.elementAt(i);
	         String payinDate = (String) dPayin.elementAt(i);
		  %>
		  <tr>
		    <td class="item ; dotline01" height="22" width="20%">
		    <nobr><input type="checkbox" name="f_receiept" value="Y" checked disabled>
		      ใบเสร็จรับเงิน เลขที่ :</nobr></td>
		    <td height="22" class="dotline01" width="28%"><%=doString.checkString(receiptNo,"-")%></td>
		    <td height="22" class="item ; dotline01" width="17%"><nobr>จำนวนเงิน
		      :</nobr></td>
		    <td height="22" class="dotline01" width="35%"><nobr><%=format.format(recvReten.doubleValue())%>&nbsp; บาท </nobr></td>
		    <td height="22" class="item ; dotline01" width="13%"><nobr>วันที่ Pay in : </nobr></td>
		    <td height="22" class="dotline01" width="8%"><%=doString.checkString(payinDate,"-")%> </td>
		  </tr>
		  <%  
	  } // end for

      } else {
	  %>
	  <tr>
	    <td class="item ; dotline01" height="22" width="20%">
	    <nobr><input type="checkbox" name="f_receiept" value="Y" checked disabled>
	      ใบเสร็จรับเงิน เลขที่ :</nobr></td>
	    <td height="22" class="dotline01" width="28%">-</td>
	    <td height="22" class="item ; dotline01" width="17%"><nobr>จำนวนเงิน
	      :</nobr></td>
	    <td height="22" class="dotline01" width="35%">0.00&nbsp; บาท </td>
	    <td height="22" class="item ; dotline01" width="13%"><nobr>วันที่ Pay in : </nobr></td>
	    <td height="22" class="dotline01" width="8%">- </td>
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





<br style="font-size:10pt">




        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">

            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4">&nbsp; <a href="javascript:self.close()"><img border="0" src="images/bu_close.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>  
        </table>  






          </td>
        </tr>
      </table>

			
			

</BODY>

</HTML>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_View_RetDoc.jsp : " + e.getMessage());
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