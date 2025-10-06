<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%!
	// Caching the DataSource - It is obtained in the jspInit() method
	private javax.sql.DataSource ds = null;
	private String dsName = Constants.JDBC_LAN;
	
	private void getDS() throws NamingException {
		// Note the new Initial Context Factory interface available in WebSphere 4.0
		Hashtable parms = new Hashtable();
		parms.put(Context.INITIAL_CONTEXT_FACTORY, "com.ibm.websphere.naming.WsnInitialContextFactory");
		InitialContext ctx = new InitialContext(parms);

		// Perform a naming service lookup to get the DataSource object.
		ds = (javax.sql.DataSource) ctx.lookup(dsName);
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
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_Disp_Reten.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

String empId = user.getEmpId();
String docNo = doString.checkString(request.getParameter("docNo"));
String comId = doString.checkString(request.getParameter("comId"));
String projId = doString.checkString(request.getParameter("projId"));
String print = doString.checkString(request.getParameter("print"));
String lockId = "";
String houseNo = "";
String retenType = "";
%>
<HTML>
<HEAD>
<TITLE>รายละเอียด - ใบวางเงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม</TITLE>
<META http-equiv="Content-Type" content="text/html; charset=TIS-620">
<META http-equiv="Content-Style-Type" content="text/css">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<SCRIPT language="javascript" src="script_fx.js"></SCRIPT>
<SCRIPT language="javascript" type="text/javascript" src="chromeless_35.js"></SCRIPT>
<SCRIPT language="javascript" type="text/javascript" src="window_style.js"></SCRIPT>
<BASE target="_self">
<SCRIPT LANGUAGE="JavaScript">
<!-- Begin
function printPayIn(frm) {
	frm.target = "_blank";
	frm.submit();
}
// End -->
</script>
</HEAD>
<BODY leftMargin="0" topMargin="0" marginheight="0" marginwidth="0">
<FORM name="frmDispReten" method="post" action="/LHServ/PrintPayInServlet">
<INPUT type="hidden" name="sel_project" value="<%=comId%>:<%=projId%>">
<INPUT type="hidden" name="comId" value="<%=comId%>">
<INPUT type="hidden" name="projId" value="<%=projId%>">
<INPUT type="hidden" name="docNo" value="<%=docNo%>">
<INPUT type="hidden" name="empId" value="<%=empId%>">
<INPUT type="hidden" name="userId" value="<%=userId%>">
<INPUT type="hidden" name="docType" value="A">
<TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
  <TBODY>
    <TR>
      <TD width="100%" class="BD">
      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
        <TBODY>
          <TR>
            <TD width="80%" class="bigh"><IMG border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp; ใบวางเงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม</TD>
            <TD width="20%" class="bigh" align="right"></TD>
          </TR>
        </TBODY>
      </TABLE>
      <BR style="font-size:10pt">
<%
String empName = "";
String docType = "";
String model = "";
String custName = "";
String retenName = "";
String retentId = "";
String reqDate = "";
String conDate = "";
String comment = "";
String status = "";
double amount = 0;
double conMnth = 0;
boolean cancel = true;
 
//---- 2022-06-30 , for payin ----//
String iPayType = "";
String iPayBnk = "";
String nPayBnk = "";
String iPayAcc = "";
String iEmail = "";
//-------------------------------//

Connection conn = null;
Statement stmt = null;
ResultSet rs = null;
String sql = "";
try {
	if (ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();

	sql = "SELECT s_receive FROM lan:serv_payin WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+docNo+"' AND s_receive > 0";
	servlog.startLog(sql);
	rs = stmt.executeQuery(sql);
	servlog.endLog();
	if (rs != null) {
		if (rs.next() == true) {
			cancel = false;
		}
		rs.close();
		rs=null;
	}
	if (print.equals("true")) {
		cancel = false;
	}
	//sql = "SELECT h.i_sort, h.d_keyin, h.i_doc_type, h.i_lor, h.n_custo, h.i_model, h.i_house, h.i_ret_custo, h.i_reten, h.d_beg_cons, h.i_mon_cons, NVL(h.z_reten,0) AS RETEN_AMT, h.c_advan, h.i_staff, h.i_doc_status, TRIM(e.n_prename_th) || ' ' || TRIM(e.n_nemploy_th) || ' ' || TRIM(e.n_semploy_th) AS EMP_NAME FROM lan:serv_rethd h, docflow:acemploy e WHERE h.i_company = '"+comId+"' AND h.i_project = '"+projId+"' AND h.i_docno = '"+docNo+"' AND h.i_staff = e.i_employ";

	//---- 2022-06-30 , change sql and join lhpay_std for bank name -----//
	sql  = " SELECT NVL(h.z_reten,0) AS RETEN_AMT, NVL(h.z_recv_reten,0) AS RECV_AMT, ";
	sql += " TRIM(e.n_prename_th) || ' ' || TRIM(e.n_nemploy_th) || ' ' || TRIM(e.n_semploy_th) AS EMP_NAME, ";
	sql += " s.n_desc as n_paybnk, h.* FROM lan:serv_rethd h ";
    sql += " left join lan:lhpay_std s on s.i_type='R' and s.i_key1=h.i_paybnk ";
    sql += " , docflow:acemploy e ";
    sql += " WHERE h.i_company = '"+comId+"' AND h.i_project = '"+projId+"' ";
    sql += " AND h.i_docno = '"+docNo+"' AND h.i_staff = e.i_employ ";
	servlog.startLog(sql);
	rs = stmt.executeQuery(sql);
	servlog.endLog();
	if (rs != null) {
		if (rs.next() == true) {
			lockId = doString.checkString(rs.getString("I_SORT"));
			houseNo = doString.checkString(rs.getString("I_HOUSE"));
			model = doString.checkString(rs.getString("I_MODEL"));
			docType = doString.checkString(rs.getString("I_DOC_TYPE"));
			custName = doString.checkString(doString.DisplayThai(rs.getString("N_CUSTO")));
			retenType = doString.checkString(rs.getString("I_RET_CUSTO"));
			retentId = doString.checkString(rs.getString("I_RETEN"));
			empName = doString.checkString(doString.DisplayThai(rs.getString("EMP_NAME")));
			reqDate = DateUtil.ifxToThaiDateNoTime(doString.DisplayThai(rs.getString("D_KEYIN")));
			conDate = DateUtil.ifxToThaiDateNoTime(doString.DisplayThai(rs.getString("D_BEG_CONS")));
			amount = rs.getDouble("RETEN_AMT");
			conMnth = rs.getDouble("I_MON_CONS");
			comment = doString.checkString(doString.DisplayThai(rs.getString("C_ADVAN")));
			status = doString.checkString(rs.getString("I_DOC_STATUS"));
			
			//---- 2022-06-30 , for payin ----//
			iPayType = doString.checkString(rs.getString("i_paytype"),"");
			iPayBnk = doString.checkString(rs.getString("i_paybnk"),"");
			nPayBnk = doString.checkString(rs.getString("n_paybnk"),"");
			iPayAcc = doString.checkString(rs.getString("i_payacc"),"");
			iEmail = doString.checkString(rs.getString("i_email"),"");
			//-------------------------------//				
		}
		rs.close();
		rs=null;
	}

	if (retenType.equals("1")) {
		retenType = "04";
		sql = "SELECT n_prename, n_ncustomer, n_scustomer FROM lan:acxcusto WHERE i_customer = "+retentId;
		servlog.startLog(sql);
		rs = stmt.executeQuery(sql);
		servlog.endLog();
		if (rs != null) {
			if (rs.next() == true) {
				retenName = doString.checkString(doString.DisplayThai(rs.getString("N_PRENAME")))+" "+doString.checkString(doString.DisplayThai(rs.getString("N_NCUSTOMER")))+ " "+doString.checkString(doString.DisplayThai(rs.getString("N_SCUSTOMER")));
			}
			rs.close();
			rs=null;
		}
	} else {
		if (retenType.equals("2")) {
			retenType = "05";
		} else {
			retenType = "06";
		}
		sql = "SELECT n_pname, n_name, n_sname FROM lan:serv_venprj WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_type = '"+retenType+"' AND i_vendor = '"+retentId+"'";
		servlog.startLog(sql);
		rs = stmt.executeQuery(sql);
		servlog.endLog();
		if (rs != null) {
			if (rs.next() == true) {
				retenName = doString.checkString(doString.DisplayThai(rs.getString("N_PNAME")))+" "+doString.checkString(doString.DisplayThai(rs.getString("N_NAME")))+" "+doString.checkString(doString.DisplayThai(rs.getString("N_SNAME")));
			}
			rs.close();
			rs=null;
		}
	}
	System.out.println("PASS1");
%>
      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
        <TBODY>
          <TR>
            <TD class="item_tab1"><IMG border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></TD>
            <TD class="item_tab2" width="200">รายละเอียดการวางเงินค้ำประกันฯ</TD>
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
                  <TD class="item ; dotline01" height="22" width="13%">โครงการ :</TD>
                  <TD height="22" width="40%" class="dotline01">
<%	
	sql = "SELECT n_project FROM lan:acxprojt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'";
	servlog.startLog(sql);
	rs = stmt.executeQuery(sql);
	servlog.endLog();
	if (rs != null) {
		if (rs.next() == true) {
			out.print(doString.checkString(doString.DisplayThai(rs.getString("N_PROJECT"))));
		}// end if
		rs.close();
		rs=null;
	}
%>
                  </TD>
                  <TD height="22" class="item ; dotline01" width="12%">เลขที่ใบวางเงิน :</TD>
                  <TD height="22" width="35%" class="dotline01"><%=docNo%></TD>
                </TR>
                <TR>
                  <TD class="item ; dotline01" height="22" width="13%">บ้านเลขที่ :</TD>
                  <TD height="22" width="40%" class="dotline01"><%=houseNo%>
                </TD>
                  <TD height="22" class="item ; dotline01" width="12%">แปลง :</TD>
                  <TD height="22" width="35%" class="dotline01"><%=lockId%></TD>
                </TR>
                <TR>
                  <TD class="item ; dotline01" height="22" width="13%">แบบบ้าน</TD>
                  <TD height="22" width="40%" class="dotline01"><%=model%></TD>
                  <TD height="22" class="item ; dotline01" width="12%">ชื่อลูกค้า :</TD>
                  <TD height="22" width="35%" class="dotline01"><%=custName%></TD>
                </TR>
                <TR>
                  <TD class="item ; dotline01" height="22" width="13%">ผู้รับเรื่อง :</TD>                  
                <TD height="22" width="40%" class="dotline01"><%=empName%></TD>
                  <TD height="22" class="item ; dotline01" width="12%">วันเวลาที่แจ้ง :</TD>
                  <TD height="22" width="35%" class="dotline01"><%=reqDate%></TD>
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
      <BR style="font-size:10pt">
      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
        <TBODY>
          <TR>
            <TD class="item_tab1"><IMG border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></TD>
            <TD class="item_tab2" width="200">รายละเอียดผู้ขอวางเงินฯ</TD>
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
                  <TD class="item ; dotline01" height="22" width="13%">ผู้วางเงินค้ำประกันฯ :</TD>
                  <TD height="22" width="15%" class="dotline01">
<%
if (retenType.equals("04")) { out.print("ลูกค้า"); }
if (retenType.equals("05")) { out.print("ผู้รับเหมา"); }
if (retenType.equals("06")) { out.print("อื่นๆ"); }
%>
                   </TD>
                  <TD height="22" width="38%" class="dotline01"><%=retentId%> | <%=retenName%></TD>
                  <TD height="22" class="item ; dotline01" width="14%">&nbsp;</TD>
                  <TD height="22" width="20%" class="dotline01">&nbsp;</TD>
                </TR>

                <TR>
                  <TD class="item ; dotline01" height="22" width="13%">เพื่อค้ำประกัน :</TD>
                  <TD height="22" width="53%" class="dotline01" colspan="2">
<%
	sql = "SELECT n_desc FROM lan:serv_xstd WHERE i_type = '50'  AND i_code = '"+docType+"'";
	servlog.startLog(sql);
	rs = stmt.executeQuery(sql);
	servlog.endLog();
	if (rs != null) {
		if (rs.next() == true) {
			out.print(doString.checkString(doString.DisplayThai(rs.getString("N_DESC"))));
		}// end if
		rs.close();
		rs=null;
	}
%>
		  </TD>
                  <TD height="22" class="item ; dotline01" width="14%">เป็นจำนวนเงิน :</TD>
                  <TD height="22" width="20%" class="dotline01"><%=doString.displayNumber("###,###,###.00", amount)%>
                   บาท</TD>
                </TR>
                <TR>
                  <TD class="item ; dotline01" height="22" width="13%">วันที่เริ่มต้นก่อสร้าง :</TD>                  
                <TD height="22" width="53%" class="dotline01" colspan="2"><%=conDate%></TD>
                  <TD height="22" class="item ; dotline01" width="14%">คาดว่าเสร็จประมาณ :</TD>
                  <TD height="22" width="20%" class="dotline01"><%=conMnth%>
                   เดือน</TD>
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
						  <TD class="dotline01" height="22" width="20%">&nbsp;<%=doString.checkString(retenName,"-") %></TD>
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
						  <TD class="dotline01" height="22" width="87%"><%=doString.checkString(retenName,"-") %></TD>		                
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
	               
                      
      <BR style="font-size:10pt">
      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
        <TBODY>
          <TR>
            <TD class="item_tab1"><IMG border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></TD>
            <TD class="item_tab2" width="200">Comment</TD>
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
            <TD width="100%" class="frmLRpad01"><TEXTAREA rows="5" name="Comment" class="box" style="width:100%" cols="20"><%=comment%></TEXTAREA></TD>
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
<%
	stmt.close();
	conn.close();
	stmt=null;
	conn=null;
} catch (Exception e) {
	System.out.println("ERROR SERV_Disp_Reten.jsp : " + e.getMessage());
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
      <BR style="font-size:10pt">
      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
        <TBODY>
          <TR>
            <TD class="act_tab1"></TD>
            <TD width="300" class="act_tab2">
			<%if (status.equals("N")) {%>
			<A href="/LHServ/InitAddRetenServlet?comId=<%=comId%>&projId=<%=projId%>&docNo=<%=docNo%>"><IMG border="0" src="images/act_edit.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27"></A>&nbsp;
			<%}%>
			<%if (status.equals("N") || print.equals("true") ) {%>
			<A href="javascript:printPayIn(frmDispReten)"><IMG border="0" src="images/act_printpayin1.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27"></A>
			<%}%>
				<%if (cancel) {%>
			<A href="/LHServ/CancelRetentServlet?comId=<%=comId%>&projId=<%=projId%>&docNo=<%=docNo%>"><IMG border="0" src="images/act_cancel003.gif" onmouseout="nereidFade(this,70,50,5)" onmouseover="nereidFade(this,100,50,5)" style="FILTER: alpha(opacity=70)" width="70" height="27"></A>&nbsp;
				<%}%>
			&nbsp;</TD>
            <TD class="act_tab3"></TD>
            
          <TD class="act_tab4"><A href="javascript:history.back()" target="_top"><IMG border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></A>&nbsp; 
            <A href="SERV_RetenHome.jsp"><IMG border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></A></TD>
          </TR>
        </TBODY>
      </TABLE>
      </TD>
    </TR>
  </TBODY>
</TABLE>
<BR style="font-size:30pt">
<TABLE border="0" cellspacing="0" cellpadding="0" width="100%">
  <TBODY>
    <TR>
      <TD width="100%" class="copyright" align="center">Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer
      version 5 และ 5.5 <BR>
      ติดต่อสอบถามได้ที่ : <A href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</A>&nbsp; หรือ โทร. 0-2230-8279 (คุณประพัฒน์ ฝ่ายบริการ)&nbsp; 0-2230-8491-5
      (ฝ่าย IT) <BR>
      <IMG src="images/copyright.gif" width="475" height="26"></TD>
    </TR>
  </TBODY>
</TABLE>
</FORM>
</BODY>
</HTML>