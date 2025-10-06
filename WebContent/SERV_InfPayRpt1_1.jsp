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
	doString str = new doString();
	//---------------------- Variable --------------------
	String sessionId = user.getsessionId();
	String userId = user.getUserID();
    String beg_month = doString.checkString(request.getParameter("beg_month"),"0");
    String beg_year = doString.checkString(request.getParameter("beg_year"),"0");
    String end_month = doString.checkString(request.getParameter("end_month"),"0");
    String end_year = doString.checkString(request.getParameter("end_year"),"0");    
    String begDate = beg_year+"-"+beg_month+"-01";
    String endDate = end_year+"-"+end_month+"-01";
	Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
	String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);
	//------------------------------------------------------
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	SERV_CommonData common = null;
	try {
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();
		stmt1 = conn.createStatement();
		common = new SERV_CommonData(conn);
		stmt.executeUpdate("DELETE FROM lan:serv_selproj WHERE i_session = "+sessionId);

		//---=========== Month Initilize =========----//
		String thaiMonth[] = new String[] {"","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
		String showBegMonth = thaiMonth[Integer.parseInt(beg_month)];
		String showBegYear = Integer.toString(Integer.parseInt(beg_year)+543);
		String showEndMonth = thaiMonth[Integer.parseInt(end_month)];
		String showEndYear = Integer.toString(Integer.parseInt(end_year)+543);		
%>

<HTML>
<HEAD>
<TITLE>สรุปการจัดเก็บค่าบริการสาธารณะแยกตามช่วงเวลา</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript" src="jquery3/jquery-1.10.2.js"></script>
<base target="_self">

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
	
  function dispDoc(comId, projId, status) {
	document.frmRep.comId.value = comId;
	document.frmRep.projId.value = projId;
	document.frmRep.status.value = status;
	onPleaseWait();  
     document.frmRep.action="<%=Constants.APP_PATH%>/SERV_InfPayRpt1_2.jsp";
     document.frmRep.submit();
  }
//-->
</script>
</HEAD>
<script language="JavaScript">
<!--
onPleaseWait();
//-->
</script>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="offPleaseWait();">
<FORM NAME = "frmRep" ACTION="SERV_InfPayRpt1_1.jsp" METHOD="POST">
<input type="hidden" name="beg_month" value="<%=beg_month%>">
<input type="hidden" name="beg_year" value="<%=beg_year%>">
<input type="hidden" name="end_month" value="<%=end_month%>">
<input type="hidden" name="end_year" value="<%=end_year%>">
<input type="hidden" name="comId" value="">
<input type="hidden" name="projId" value="">
<input type="hidden" name="status" value="">
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
                
          <td class="item_tab2" width="200">รายละเอียดเดือน/ปีที่ระบุ</td>
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
    <td class="item ; dotline01" height="22">
	ตั้งแต่เดือน : <%=showBegMonth%> &nbsp; พ.ศ. <%=showBegYear%> &nbsp;ถึงเดือน : <%=showEndMonth%> &nbsp; พ.ศ. <%=showEndYear%>
	 </td>
  </tr>
  
  <tr>
    <td class="item ; dotline01" height="22">&nbsp;
<%
	  String[] projList = request.getParameterValues("sel_proj");
	  String proj = "", i_com = "", i_proj = "";
	  int line = 0;
	  if (projList!=null) {
		  for (int i=0;i<projList.length;i++) {		
				 proj = doString.checkString(projList[i],"");  		
				i_com = proj.substring(0,2);
				 i_proj = proj.substring(3,6);
				 if (!i_proj.equals("ALL")) {
					stmt.executeUpdate("INSERT INTO lan:serv_selproj(i_session,i_company,i_project) VALUES("+sessionId+", '"+i_com+"', '"+i_proj+"')");
				 }
				//---============= get Project Details ===============----//
				sql.delete(0,sql.length()); 
				sql.append(" select * from lan:acxprojt ")
					  .append(" where i_company='").append(i_com).append("' ")
					  .append(" and i_project='").append(i_proj).append("' ");
				rs = stmt.executeQuery(sql.toString());
				if (rs.next()) {
							 String nProject = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");							 
							 String iProj = str.replace(proj,":","-");			
%>
							<input type="hidden" name="sel_proj" value="<%=proj%>">
<%							 
				} // end while
				rs.close();
				rs=null;
		  } // end for
	  }
	  if (i_proj.equals("ALL")) {
			sql.delete(0,sql.length()); 
			sql.append("SELECT DISTINCT proj.i_company, proj.i_project, proj.n_project FROM lan:acxprojt proj, lan:acsbudgh bud");
			rs = stmt.executeQuery("SELECT proj_id FROM lan:serv_pstaff WHERE user_id = '"+userId+"' AND proj_id = 'ALL'");
			if (rs.next() == false) {
				sql.append(", lan:serv_pstaff staff WHERE proj.i_company = staff.com_id AND proj.i_project = staff.proj_id AND staff.user_id = '")
					.append(userId + "' AND");
			} else {
				sql.append(" WHERE");
			}
			rs.close();
			sql.append(" bud.i_company = proj.i_company AND bud.i_project = proj.i_project AND bud.d_year = '" + cur_year + "'");
			rs = stmt.executeQuery(sql.toString());
			while (rs.next() == true) {
				i_com = doString.checkString(rs.getString("I_COMPANY"));
				i_proj = doString.checkString(rs.getString("I_PROJECT"));
				stmt1.executeUpdate("INSERT INTO lan:serv_selproj(i_session,i_company,i_project) VALUES("+sessionId+", '"+i_com+"', '"+i_proj+"')");
			}// end while
			rs.close();
	  }
%>
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


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                
          <td class="item_tab2" width="280">รายละเอียดการจัดเก็บค่าบริการสาธารณะแยกตามโครงการ</td>
                <td class="item_tab3">
				</td>                
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


			  <!-----------------------------------HEADER TABLE ------------------------------>
              <tr>
                <td rowspan="2" width="3%" align="center" class="col_name">NO.</td>
                <td rowspan="2" width="25%" align="center" class="col_name">โครงการ</td>
                <td rowspan="2" width="10%" align="center" class="col_name">อัตราจัดเก็บ<br>(บาท/ตรว.)</td>
                
                <td colspan="3" align="center" class="col_name">การจัดเก็บค่าบริการ(รายการ)</td>
                <td rowspan="2" width="7%" align="center" class="col_name">คิดเป็น%<br>การจัดเก็บ</td>
                <td colspan="3" align="center" class="col_name">จำนวนเงินที่จัดเก็บ</td>
                
              </tr>
              <tr>
                <td width="10%" align="center" class="col_name">จัดเก็บทั้งหมด</td>
                <td width="9%" align="center" class="col_name">จัดเก็บได้</td>
                <td width="9%" align="center" class="col_name">คงค้าง</td>
                
                <td width="10%" align="center" class="col_name">จำนวนเงินทั้งหมด</td>
                <td width="9%" align="center" class="col_name">จัดเก็บได้</td>
                <td width="8%" align="center" class="col_name">คงค้าง</td>
                
              </tr>              
			  <!---------------------------------------------------------------------------------------------->
<% 
			line=0;
			String bgcolor = "";
			String comId = "";
			String projId = "";
			String status = "";
			String infRate = "";
			int numDoc = 0;
			int numRecDoc = 0;
			int numAccDoc = 0;
			
			int totDoc = 0;
			int totRecDoc = 0;
			int totAccDoc = 0;
			double pcRecDoc = 0;
			
			double reqAmnt = 0;
			double recAmnt = 0;
			double accAmnt = 0;
			
			double totReqAmnt = 0;
			double totRecAmnt = 0;
			double totAccAmnt = 0;
			rs = stmt.executeQuery("SELECT s.i_company, s.i_project, p.n_project FROM lan:serv_selproj s, lan:acxprojt p WHERE s.i_session = "+sessionId+" AND s.i_company = p.i_company AND s.i_project = p.i_project ORDER BY s.i_company, s.i_project");
			if (rs != null) {
				while (rs.next() == true) {

					comId = doString.checkString(rs.getString("I_COMPANY"));
					projId = doString.checkString(rs.getString("I_PROJECT"));
					infRate = "";
					rs1 = stmt1.executeQuery("SELECT DISTINCT z_price FROM lan:serv_infrate WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND d_start >= '"+begDate+"' AND d_end <= '"+endDate+"' AND z_price > 0 ORDER BY z_price");
					if (rs1 != null) {
						while (rs1.next() == true) {
							infRate += doString.displayNumber("###,###,###.00", rs1.getDouble("Z_PRICE"))+",";
						}// end while
						rs1.close();
						rs1=null;
					}
					if (infRate.equals("")) {
						infRate = "&nbsp;";
					} else {
						infRate = infRate.substring(0, infRate.length()-1);
					}
					numDoc = 0;
					numRecDoc = 0;
					numAccDoc = 0;
					
					reqAmnt = 0;
					recAmnt = 0;
					accAmnt = 0;
					
					//จัดเก็บได้
					rs1 = stmt1.executeQuery("SELECT COUNT(*), SUM(NVL(z_payin_infra,0))::DECIMAL(16,2) AS REQ_AMNT, SUM(NVL(z_recv_infra,0))::DECIMAL(16,2) AS REC_AMNT FROM lan:serv_infhd WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND d_start >= '"+begDate+"' AND d_end <= '"+endDate+"' AND (i_doc_status = 'F' OR i_doc_status = 'P')");
					if (rs1 != null) {
						if (rs1.next() == true) {
							numDoc += rs1.getInt(1);
							reqAmnt += rs1.getDouble("REQ_AMNT");
							
							numRecDoc += rs1.getInt(1);
							recAmnt += rs1.getDouble("REC_AMNT");
						}
						rs1.close();
						rs1=null;
					}
					
					//คงค้าง
					rs1 = stmt1.executeQuery("SELECT COUNT(*), SUM(NVL(z_payin_infra,0))::DECIMAL(16,2) AS REQ_AMNT FROM lan:serv_infhd WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND d_start >= '"+begDate+"' AND d_end <= '"+endDate+"' AND i_doc_status NOT IN ('F', 'P', 'C')");
					if (rs1 != null) {
						if (rs1.next() == true) {
							numDoc += rs1.getInt(1);
							reqAmnt += rs1.getDouble("REQ_AMNT");
							
							numAccDoc += rs1.getInt(1);
							accAmnt += rs1.getDouble("REQ_AMNT");
						}
						rs1.close();
						rs1=null;
					}
					reqAmnt = recAmnt + accAmnt;
					
					totDoc += numDoc;
					totRecDoc += numRecDoc;
					totAccDoc += numAccDoc;		
					totReqAmnt += reqAmnt;
					totRecAmnt += recAmnt;
					totAccAmnt += accAmnt;
					if (numDoc > 0) {
						line++;
						bgcolor = ((line%2) == 0) ? "FAFAFA" : "FFFFFF";						
						pcRecDoc = (Double.parseDouble(Integer.toString(numRecDoc)) * 100.00)/Double.parseDouble(Integer.toString(numDoc));	
%>
			<tr bgcolor="#<%=bgcolor%>">
			 <td width="3%" align="center" class="dotline"><%=line%></td>
			
			 <td width="25%" align="left" class="item ; dotline"><FONT COLOR="rgb(0,50,200)"><%=comId%>-<%=projId%> <%=doString.DisplayThai(rs.getString("N_PROJECT"))%></font></td>
			 <td width="10%" align="center" class="dotline"><%=infRate%></td>
			 			 
			 <td width="10%" align="center" class="dotline"><%=doString.displayNumber("###,###",numDoc)%></td>			 
			 <td width="9%" align="center" class="dotline"><A HREF="javascript:dispDoc('<%=comId%>', '<%=projId%>', 'F')"><%=doString.displayNumber("###,###",numRecDoc)%></A></td>
			 <td width="9%" align="center" class="dotline"><A HREF="javascript:dispDoc('<%=comId%>', '<%=projId%>', 'N')"><%=doString.displayNumber("###,###",numAccDoc)%></A></td>
			 <td width="7%" align="center" class="dotline"><%=doString.displayNumber("###.00",pcRecDoc)%>%</td>
			 
			 <td width="10%" align="right" class="dotline"><%=doString.displayNumber("###,###,###.00",reqAmnt)%></td>			 
			 <td width="9%" align="right" class="dotline"><A HREF="javascript:dispDoc('<%=comId%>', '<%=projId%>', 'F')"><%=doString.displayNumber("###,###,###.00",recAmnt)%></A></td>
			 <td width="8%" align="right" class="dotline"><A HREF="javascript:dispDoc('<%=comId%>', '<%=projId%>', 'N')"><%=doString.displayNumber("###,###,###.00",accAmnt)%></A></td>
			 </tr>			 
<%					
					}
				}// end while
				rs.close();
				rs=null;
			}
			line++;
			bgcolor = ((line%2) == 0) ? "FAFAFA" : "FFFFFF";
			pcRecDoc = -1;
			if (totDoc > 0) {
				pcRecDoc = (Double.parseDouble(Integer.toString(totRecDoc)) * 100.00)/Double.parseDouble(Integer.toString(totDoc));				
			}
%>			
			<tr bgcolor="#<%=bgcolor%>">
			 <td colspan="3" align="right" class="item ; dotline">รวม <%=line-1%> โครงการ </td>
			 <td width="10%" align="center" class="item ; dotline"><%=doString.displayNumber("###,###",totDoc)%></td>			 
			 <td width="9%" align="center" class="item ; dotline"><%=doString.displayNumber("###,###",totRecDoc)%></td>
			 <td width="9%" align="center" class="item ; dotline"><%=doString.displayNumber("###,###",totAccDoc)%></td>
			 <td width="7%" align="center" class="item ; dotline">
			 <%if(pcRecDoc > -1){ out.print(doString.displayNumber("###.00",pcRecDoc)+"%"); } else { out.print("&nbsp;"); }%>
			 </td>
			 <td width="10%" align="right" class="dotline"><%=doString.displayNumber("###,###,###.00",totReqAmnt)%></td>			 
			 <td width="9%" align="right" class="dotline"><%=doString.displayNumber("###,###,###.00",totRecAmnt)%></td>
			 <td width="8%" align="right" class="dotline"><%=doString.displayNumber("###,###,###.00",totAccAmnt)%></td>
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
            <td width="80" class="act_tab2">&nbsp;</td> 	
            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_InfPayRpt1.jsp"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
	    stmt.executeUpdate("DELETE FROM lan:serv_selproj WHERE i_session = "+sessionId);
		stmt.close();
		stmt1.close();
		conn.close();
		stmt=null;
		stmt1=null;
		conn=null;
	} catch (Exception e) {
		System.out.println("ERROR SERV_InfPayRpt1_1.jsp : " + e.getMessage());
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