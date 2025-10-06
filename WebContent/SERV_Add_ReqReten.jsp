<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="java.text.*" %>
<%@page import="serv.common.*" %>
<%@page import="serv.util.ServLog" %>
<%@include file="confirmLogin.jsp" %>
<%@include file="function.jsp" %>

<%
	String sessionId = user.getsessionId();
	String userId = user.getUserID();
	String jName = "SERV_Add_ReqReten.jsp";
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

   String mode = doString.checkString(request.getParameter("mode"),"ADD").toUpperCase();
   String docNo = doString.checkString(request.getParameter("i_docno"),"").toUpperCase();
   String condition = "";

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
    String estChqDate = "";
	String empName = "";
	String lor = "";
	
	//---- 2022-06-30 , for payin ----//
	String iPayType = "";
	String iPayBnk = "";
	String nPayBnk = "";
	String iPayAcc = "";
	String iEmail = "";
	//-------------------------------//	

	Vector iReceipt = new Vector();
	Vector zReceiveReten = new Vector();

	String fIDCard = "";
	String fLoseReten = "";
	String fNotice = "";
	String iNotice = "";

	double zReten = 0.0;
        String reqDate = "";
	boolean zRetenEquals = false;
	//Calendar est = null;
	//Timestamp tmp = null;
	String tmp = "";
	Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
	int YY = rightNow.get(Calendar.YEAR);
	int MM = rightNow.get(Calendar.MONTH) + 1;
	int DD = rightNow.get(Calendar.DATE);
	int mm = rightNow.get(Calendar.MINUTE);
	int hh = rightNow.get(Calendar.HOUR);
	
	Calendar est = Calendar.getInstance();


	//-----======== Get Reten Data ==========----//
	sql.delete(0,sql.length());
	if (mode.equalsIgnoreCase("ADD")) {
	        //------ Add Mode -----//
		sql.append(" select b.i_company||b.i_project||' | '||b.n_project as project_name,c.n_desc,'' as emp_name,s.n_desc as n_paybnk,a.*  from lan:serv_rethd a ")
		      .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
		      .append(" left join lan:serv_xstd c on c.i_type='50' and c.i_code=a.i_doc_type ")
		      //----- 2022-06-30 , add payin query ------//
		      .append(" left join lan:lhpay_std s on s.i_type='R' and s.i_key1=a.i_paybnk ")
		      //-----------------------------------------//
		      .append(" where a.i_doc_status='F' ") //and a.z_reten=a.z_recv_reten ") , if z_reten not equals , alert and disable save button
		      .append(" and a.i_docno='").append(docNo).append("' ");
	} else {
		//------ Edit Mode -------//
		sql.append(" select b.i_company||b.i_project||' | '||b.n_project as project_name , c.n_desc , ")
		      .append(" trim(d.n_prename_th)||trim(d.n_nemploy_th)||' '||trim(d.n_semploy_th) as emp_name,s.n_desc as n_paybnk,a.* from lan:serv_rethd a ")
		      .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
		      .append(" left join lan:serv_xstd c on c.i_type='50' and c.i_code=a.i_doc_type ")
		      .append(" left join docflow:acemploy d on d.i_employ=a.i_staff_payback ")
		      //----- 2022-06-30 , add payin query ------//
		      .append(" left join lan:lhpay_std s on s.i_type='R' and s.i_key1=a.i_paybnk ")
		      //-----------------------------------------//		      
		      .append(" where a.i_doc_status='I' and a.z_reten=a.z_recv_reten and a.i_staff_payback is not null ")
		      .append(" and a.i_docno='").append(docNo).append("' ");
	}


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
             lor = doString.checkString(rs.getString("i_lor"),"");
             empName = doString.checkString(doString.DisplayThai(rs.getString("emp_name")),"");
             zReten = rs.getDouble("z_reten");

             fIDCard = doString.checkString(rs.getString("f_id_card"),"");
             fLoseReten = doString.checkString(rs.getString("f_lost_reten"),"");
             iNotice = doString.checkString(rs.getString("i_notice"),"");
             if (iNotice.trim().length()>0) fNotice = "Y";
             			
			 //---- 2022-06-30 , for payin ----//
			 iPayType = doString.checkString(rs.getString("i_paytype"),"PAYTO");
			 iPayBnk = doString.checkString(rs.getString("i_paybnk"),"");
			 nPayBnk = doString.checkString(rs.getString("n_paybnk"),"");
			 iPayAcc = doString.checkString(rs.getString("i_payacc"),"");
			 iEmail = doString.checkString(rs.getString("i_email"),"");
			 //-------------------------------//		   
			          

	    /*est = Calendar.getInstance(Locale.ENGLISH);
   	    tmp = rs.getTimestamp("d_est_chq");
	    if (tmp!=null) {
		 est.setTime(tmp); 
		 estChqDate = getDateFromCalendar(est);
	    } else {
	         estChqDate = "";
	    }

		est = Calendar.getInstance(Locale.ENGLISH);
   	    tmp = rs.getTimestamp("d_staff_payback");
	    if (tmp!=null) {
		 est.setTime(tmp); 
		 reqDate = getDateFromCalendar(est)+"&nbsp;,&nbsp;"+getTimeFromCalendar(est)+" น.";
	    } else {
	         reqDate = "";
	    }

		*/
		estChqDate = "";
		tmp = doString.checkString(doString.DisplayThai(rs.getString("d_est_chq")));
		if (!tmp.equals("")) {
			estChqDate = tmp.substring(8, 10) + "/" + tmp.substring(5, 7) + "/" + Integer.toString(Integer.parseInt(tmp.substring(0, 4))+ 543);
		}

		reqDate = "";
		tmp = doString.checkString(doString.DisplayThai(rs.getString("d_staff_payback")));
		if (!tmp.equals("")) {
			reqDate = tmp.substring(8, 10) + "/" + tmp.substring(5, 7) + "/" + Integer.toString(Integer.parseInt(tmp.substring(0, 4))+ 543) +"&nbsp;,&nbsp;"+ tmp.substring(11,13) + ":" + tmp.substring(14)+" น.";
		}
	} // end while
	rs.close();


	if (mode.equalsIgnoreCase("ADD") && reqDate.trim().length()<=0) {
	    //reqDate = getDateFromCalendar(Calendar.getInstance())+"&nbsp;,&nbsp;"+getTimeFromCalendar(Calendar.getInstance())+" น.";
		reqDate = doString.displayNumber("00", DD) + "/" + doString.displayNumber("00", MM) + "/" + doString.displayNumber("0000", YY+543)+"&nbsp;,&nbsp;"+doString.displayNumber("00", hh)+":"+doString.displayNumber("00", mm)+" น.";
	}

	if (mode.equalsIgnoreCase("ADD") && estChqDate.trim().length()<=0) {
	   est.add(Calendar.DATE,15);
	   /*
	   boolean workedDate = false;

	   while (!workedDate) {
		     if ((est.get(Calendar.DAY_OF_WEEK)==Calendar.SATURDAY) || (est.get(Calendar.DAY_OF_WEEK)==Calendar.SUNDAY)) {
				 workedDate = false;
				 est.add(Calendar.DATE,1);
			 } else {
				 //------- find holiday --------//
				 int chkYear = est.get(Calendar.YEAR);
				 if (chkYear>2400) chkYear -= 543;
				String dHoliday = chkYear+"-"+(est.get(Calendar.MONTH)+1)+"-"+est.get(Calendar.DATE);
				sql.delete(0,sql.length());
				sql.append(" select * from lan:acxholdy where d_holiday='").append(dHoliday).append("' ");

				rs = stmt.executeQuery(sql.toString());
				if (rs.next()) {
					workedDate = false;
				    est.add(Calendar.DATE,1);
				} else {
					workedDate = true;
				}
				rs.close();
			 }
	   } // end while */
	   estChqDate = getDateFromCalendar(est);
	}



	if (mode.equalsIgnoreCase("ADD") && empName.trim().length()<=0) {
	   empName = doString.DisplayThai(user.getEmpName());
	}


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
	double sReceiveFromAcc = 0.0;
	boolean foundReceipt = false;
	String iLor = "";
	String sReceive = "";
    sql.delete(0,sql.length());
 	sql.append(" select * from serv_payin where ")
	      .append(" i_company='").append(iCompany).append("' and i_project='").append(iProject).append("' ")
	      .append(" and i_sort='").append(iSort).append("' and i_docno='").append(iDocNo).append("' ");
		servlog.startLog(sql.toString());
        rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
	while (rs.next()) {	
	    iLor = doString.checkString(rs.getString("i_lor"),"");
	    if (sReceive.trim().length()>0) sReceive += " , ";
	    sReceive += doString.checkString(doString.DisplayThai(rs.getString("s_receive")),"");

		if (doString.checkString(rs.getString("i_receipt"),"").trim().length()>0) {
		    iReceipt.addElement(doString.checkString(rs.getString("i_receipt"),""));
			zReceiveReten.addElement(new Double(rs.getDouble("z_recv_reten")));	
			foundReceipt = true;
		}
	} // end while rs
	rs.close();
   
//------ Remark for test , use when production ready ------------//	
	if (iLor.trim().length()>0 && sReceive.trim().length()>0) {
	    sql.delete(0,sql.length());
	    sql.append(" select sum(z_price) as sum_price from acrrecev a,acrdtrec b where ")
	       .append(" a.i_company='").append(iCompany).append("' and a.i_project='").append(iProject).append("' ")
		  .append(" and a.i_lor='").append(iLor).append("' and a.i_due='O5' ")
		  .append(" and a.s_receive in (").append(sReceive).append(") ")
		  .append(" and a.i_company=b.i_company  and a.i_project=b.i_project ")
		  .append(" and a.i_lor=b.i_lor and a.s_receive=b.s_receive ")
		  .append(" and b.f_payin='Y' and b.f_status='Y' and b.f_cancel is null  ");
//out.print(sql.toString());
			servlog.startLog(sql.toString());
            rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
	    while (rs.next()) {
	        sReceiveFromAcc += rs.getDouble("sum_price");
	    } // end while rs1
	    rs.close();
	} // end if check iLor & sReceive
//*/

	//----======= Check Reten is equals Receive From Account ======---//
	if (zReten==sReceiveFromAcc) {
	    zRetenEquals = true;
	} else {
	    zRetenEquals = false;
	}

%>

<HTML>
<HEAD>
<TITLE>ใบวางเงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">
    
    function saveReten() {
        var f = document.forms[0].f_notice;
		var notice = document.forms[0].i_notice;
		
		if (f.checked && notice.value.length<=0) {
		   alert(" กรุณากรอก เลขที่ใบแจ้งความ !");
		   notice.focus();
		   return false;
		}
		
		//----- 2022-06-30 , validate payin input -----//
		if (!validatePayInData()) {
			return;
		}		

		document.forms[0].submit();
    }
    
    //--- 2022-06-30 , validate payin ---//
	function validatePayInData() {
		if (document.forms[0].iPayType[0].checked) {
			if (document.forms[0].iPayBnk.value=="") {
				alert(" กรุณาเลือกธนาคาร!! ");
				document.forms[0].iPayBnk.focus();
				return false;
			}
	
			//---- validate number ----//
	       	var numValidate = /^\d{10}$/;
	        if (!numValidate.test(document.forms[0].iPayAcc.value)) {
				alert(" กรุณากรอกเลขบัญชีธนาคารเฉพาะตัวเลข 10 หลัก!! ");
				document.forms[0].iPayAcc.focus();
				return false;        
	        }                
	
	        //----- validate email -----//
	        /*  disable input 
			if (document.forms[0].iEmail.value.length>0) {
		        var emailValidate = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
		        if (!emailValidate.test(document.forms[0].iEmail.value)) {		
					alert(" รูปแบบ Email ไม่ถูกต้อง!! ");
					document.forms[0].iEmail.focus();
					return false;
				}		
			}
			*/
			        
		} else {
			//--- no validate ---//
		}
		
		return true;
	}    

</script>


<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<form action="<%=Constants.APP_PATH%>/SERV_Add_ReqRetenServlet" method="post">


<input type="hidden" name="i_docno" value="<%=doString.checkString(iDocNo,"")%>">
<input type="hidden" name="i_company" value="<%=doString.checkString(iCompany,"")%>">
<input type="hidden" name="i_project" value="<%=doString.checkString(iProject,"")%>">
<input type="hidden" name="i_signb" value="<%=doString.checkString(iSignBoard,"")%>">
<input type="hidden" name="mode" value="<%=doString.checkString(mode,"ADD")%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="80%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ใบวางเงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม 
	    &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 
	    </td>
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
    <td height="22" width="28%" class="dotline01"><%=format.format(zReten)%>&nbsp; บาท</td>
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
                <TR>
                  <TD class="item ; dotline01" height="22" width="56%">
                  	<INPUT type="radio" value="PAYIN" name="iPayType" <%=(iPayType.equals("PAYIN") ? "checked" : "") %>>&nbsp; 
			         Pay-In เข้าบัญชี : &nbsp;
                    <SELECT size="1" name="iPayBnk" class="box" style="width:210px">
		              <OPTION value="">----- เลือกธนาคาร -----</OPTION>
					<%
						String code = "";
						String optionSelected = "";
					
						sql.delete(0, sql.length());
						sql.append(" SELECT i_key1, n_desc FROM lan:lhpay_std WHERE i_type = 'R'  ORDER BY i_key1 ");
						servlog.startLog(sql.toString());
						rs = stmt.executeQuery(sql.toString());
						servlog.endLog();
						if (rs != null) {
							while (rs.next() == true) {
								code = doString.checkString(rs.getString("i_key1"));
								optionSelected = "";
								if (iPayBnk.equals(code)) {
									optionSelected = "selected";
								}
					%>
					              <OPTION value="<%=code%>" <%=optionSelected%>><%=code+" | "+doString.checkString(doString.DisplayThai(rs.getString("n_desc"))) %></OPTION>
					<%
							}// end while
							rs.close();
							rs=null;
						}
					%>		              
					</SELECT> &nbsp; &nbsp; 
			                 ชื่อบัญชี : &nbsp;
                    <INPUT type="text" name="payInName" class="box" readonly value="<%=doString.checkString(retCustName,"-")%>" style="width:200px ; background-color:#ECECEC">
                  </TD>                  
                  <TD height="22" class="item ; dotline01" width="16%">เลขที่บัญชี 10 หลัก : &nbsp;</TD>
                  <TD height="22" width="28%" class="dotline01">&nbsp;
                  <INPUT type="text" name="iPayAcc" class="box" maxlength="10" value="<%=iPayAcc %>" style="width:100px"> &nbsp; 
                  <span style="color:red">* ไม่ต้องระบุ '-' หรือ ช่องว่าง</span>
                  </TD>
                </TR>                
                <TR>
                  <TD class="item ; dotline01" height="22" colspan="3">&nbsp;</TD>
                </TR>                             
                <TR>
                  <TD class="item ; dotline01" height="22" width="56%">
                  	<INPUT type="radio" value="PAYTO" name="iPayType" <%=(iPayType.equals("PAYTO") ? "checked" : "") %>>&nbsp; 
			                 เช็คคืนเงิน สั่งจ่ายในนาม : &nbsp;
                    <INPUT type="text" name="payToName" class="box" readonly value="<%=doString.checkString(retCustName,"-")%>" style="width:200px ; background-color:#ECECEC">
                  </TD> 
                  <TD height="22" class="item ; dotline01" width="16%">&nbsp;</TD>
                  <TD height="22" width="28%" class="dotline01">&nbsp;</TD>
                </TR>  
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
    <input type="checkbox" name="f_id_card" value="Y" <%=fIDCard.equalsIgnoreCase("Y") ? " checked " : ""%>>
      สำเนาบัตรประชาชน</td>
    <td height="22" class="dotline01" width="28%">&nbsp;</td>
    <td height="22" class="item ; dotline01" width="17%"><nobr>วันที่คาดว่าจะรับเช็ค / PayIn : </nobr></td>
    <td height="22" class="dotline01 ; item" width="35%"><%=estChqDate%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="20%">
    <input type="checkbox" name="f_docno" value="Y" checked disabled>   
      เลขที่ใบวางเงินค้ำประกัน
      :</td>
    <td height="22" class="dotline01" width="28%"><%=doString.checkString(iDocNo,"-")%></td>
    <td height="22" class="dotline01" colspan="2">
    <input type="checkbox" name="f_lose_reten" value="Y" <%=fLoseReten.equalsIgnoreCase("Y") ? " checked " : ""%>>
      ใบวางเงินค้ำประกันหาย</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="20%"><input type="checkbox" name="f_signboard" value="Y" checked disabled>
      ป้ายต่อเติม เลขที่ :</td>
    <td height="22" class="dotline01" width="28%"><%=doString.checkString(iSignBoard,"-")%></td>
    <td height="22" class="item ; dotline01" width="17%">&nbsp;</td>
    <td height="22" class="dotline01" width="35%">&nbsp;</td>
  </tr>

  <%	
	  String receiptNo = "";
	  Double recvReten = new Double("0");
	  String checkbox = "";


      if (iReceipt.size()>0) {
          for (int i=0;i<iReceipt.size();i++) {
	         receiptNo = (String) iReceipt.elementAt(i);
		     recvReten = (Double) zReceiveReten.elementAt(i);
			 
			 checkbox = "";
			 if (i==0) {
				 checkbox = "<input type='checkbox' name='f_receiept' value='Y' checked disabled>  ใบเสร็จรับเงิน เลขที่ :";
			 } else {
				 checkbox = "&nbsp;";
			 }
		  %>
		  <tr>
		    <td class="item ; dotline01" height="22" width="20%"><%=checkbox%></td>
		    <td height="22" class="dotline01" width="28%"><%=doString.checkString(receiptNo,"-")%></td>
		    <td height="22" class="item ; dotline01" width="17%">จำนวนเงิน
		      :</td>
		    <td height="22" class="dotline01" width="35%"><%//=format.format(recvReten.doubleValue())%>
			<%=doString.displayNumber("###,##0.00", recvReten.doubleValue())%>&nbsp; บาท </td>
		  </tr>
	<%  
	  } // end for

      } else {
	  %>
	  <tr>
	    <td class="item ; dotline01" height="22" width="20%"><input type="checkbox" name="f_receiept" value="Y" checked disabled>
	      ใบเสร็จรับเงิน เลขที่ :</td>
	    <td height="22" class="dotline01" width="28%">-</td>
	    <td height="22" class="item ; dotline01" width="17%">จำนวนเงิน
	      :</td>
	    <td height="22" class="dotline01" width="35%">0.00&nbsp; บาท </td>
	  </tr>
	  <%  
      }
 %>

  <tr>
    <td class="item ; dotline01" height="22" width="20%">
    <input type="checkbox" name="f_notice" value="Y" <%=fNotice.equalsIgnoreCase("Y") ? " checked " : ""%>>
      ใบแจ้งความ เลขที่
      :</td>
    <td height="22" class="dotline01" width="28%">
    <input type="text" name="i_notice" class="box" maxlength="20" style="width:150px" value="<%=iNotice%>"></td>
    <td height="22" class="dotline01" colspan="2">&nbsp;(กรณีใบเสร็จรับเงินหาย)</td>
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
            <td width="100" class="act_tab2">

	     <%
	        if (zRetenEquals && foundReceipt) {
	           %>
		    <img border="0" src="images/act_saveandclose.gif" 
		                onclick="saveReten();"
				onmouseout=nereidFade(this,70,50,5)
				onmouseover=nereidFade(this,100,50,5)
				style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">&nbsp;
		    <%
		  } else {
		  	 if (!foundReceipt) {
		        %>
			    &nbsp;
			    <script>
			      window.onload=new Function("alert('ไม่พบเลขที่ใบเสร็จ, กรุณาติดต่อฝ่ายการเงิน!')");
			    </script>
			    <%		  	 
		  	 } else if (!zRetenEquals) {
		        %>
			    &nbsp;
			    <script>
			      window.onload=new Function("alert('จำนวนเงินรับ ไม่เท่ากับ จำนวนเงินวางค้ำประกัน !')");
			    </script>
			    <%
		    }
		  }
	       %>

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


</form>
</BODY>

</HTML>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_Add_ReqReten.jsp : " + e.getMessage());
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