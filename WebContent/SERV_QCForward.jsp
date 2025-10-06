<%@page contentType="text/html; charset=TIS-620"%>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>


<%
   doString str = new doString();
   //----============ Declare Variables for input data ===========----//
   String selProj = ""; 
   String comId = "";
   String projId = "";
   String qc = "";
	String type = doString.checkString(request.getParameter("type"),"");
	String chk_qc = doString.checkString(request.getParameter("qc"),"");
	String chkMonth = doString.checkString(request.getParameter("chkMonth"),"0");
	String chkYear = doString.checkString(request.getParameter("chkYear"),"0"); //ค.ศ.
	java.util.Calendar currentCal = java.util.Calendar.getInstance();  
	Calendar rightNow = Calendar.getInstance();
	int curday = rightNow.get(Calendar.DAY_OF_MONTH);
	currentCal = new GregorianCalendar(Integer.parseInt(chkYear), Integer.parseInt(chkMonth)-1, curday);
    int daysInMonth = currentCal.getActualMaximum(currentCal.DAY_OF_MONTH);
	String chkDay = "";
	if (daysInMonth < 10) {
		chkDay = "0"+Integer.toString(daysInMonth);
	} else {
		chkDay = Integer.toString(daysInMonth);
	}
	String endDate = chkYear+"-"+chkMonth+"-"+chkDay;
	String thaiMonth[] = new String[] {"","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
	String shortMonth[] = new String[] {"","ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค."};
	String showMonth = thaiMonth[Integer.parseInt(chkMonth)];
	String showYear = Integer.toString(Integer.parseInt(chkYear)+543);
	int curMnth = Integer.parseInt(chkMonth);

   String docNo = "";
   String houseId = "";
   String lock = "";
   String qcStatus = "";
   String jobStatus = "400";
   String condition = "";
   String condition2 = "";
   String subcondition = "";
			       
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
%>
<HTML>
<HEAD>
<TITLE>Reprint List</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">
<input type="hidden" name="type" value="<%=type%>">
<input type="hidden" name="qc" value="<%=chk_qc%>">
<input type="hidden" name="chkMonth" value="<%=chkMonth%>">
<input type="hidden" name="chkYear" value="<%=chkYear%>">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;ยอดยกไป</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">ช่วงเวลา</td>
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
    <td class="item ; dotline01" height="22" colspan="4">
	เดือน : <%=showMonth%> &nbsp; พ.ศ. <%=showYear%></td>
  </tr>
	<%
	  String[] projList = request.getParameterValues("sel_proj");
  	  String queryProject = "";
	  String i_proj = "";
		int line = 0;
	  if (projList!=null) {
		  for (int i=0;i<projList.length;i++) {
				 String proj = doString.checkString(projList[i],"");  
				 if (proj.trim().length()>=6) {
					 if (queryProject.trim().length()>0) queryProject += " or ";
					 queryProject += " (i_company='"+proj.substring(0,2)+"' and i_project='"+proj.substring(3,6)+"') ";
				 }


				  %><input type="hidden" name="sel_proj" value="<%=proj%>"><%


				//---============= get Project Details ===============----//
				sql.delete(0,sql.length()); 
				sql.append(" select * from lan:acxprojt ")
					  .append(" where i_company='").append(proj.length()>=6 ? proj.substring(0,2) : "").append("' ")
					  .append(" and i_project='").append(proj.length()>=6 ? proj.substring(3,6) : "").append("' ");
				rs = stmt.executeQuery(sql.toString());
				while (rs.next()) {
					 String nProject = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
					 String iProj = str.replace(proj,":","-");	

					 if (line==0) {
						 %><tr><td class="item ; dotline01" height="22" width="10%">โครงการ :</td><%
					 } else if (line%3==0 && line!=0) {
						 %><tr><td class="item ; dotline01" height="22" width="10%">&nbsp;</td><%
					}

				    %><td height="22" width="30%" class="dotline01"><%=iProj%> <%=nProject%></td><%

					if (line%3==2) {
						%></tr><%
					}

					line++;
				} // end while
				rs.close();

		  } // end for

		  while (line%3!=0) {
			  %><td height="22" width="30%" class="dotline01">&nbsp;</td><%
			  line++;

		 	  if (line%3==0) {
		 	  	out.print("</tr>");
			  }
		  }

	  } else {
		  queryProject = " i_company='' and i_project='' ";
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
          <td width="4%" class="col_name">ลำดับที่</td>
          <td width="10%" class="col_name">เลขที่ใบแจ้งซ่อม</td>
          <td width="7%" class="col_name">แปลง</td>
          <td width="8%" class="col_name">บ้านเลขที่</td>
          <td width="16%" class="col_name">วันที่ Complete Task</td>
          <td width="43%" class="col_name">ชื่อผู้แจ้ง /
            ลูกค้า</td>
          <td width="16%" class="col_name">โทรศัพท์ติดต่อ</td>
        </tr>
<%
	line = 0;
	String status = "";
	String iDocNo = "";
	String iLock = "";
	String iHouse = "";
	String nCustomer = "";
	String nCustTel = "";
	String iDocType = "";
	String iCompany = "";
	String iProject = "";
	String proj_restrict = "";
	Hashtable tmpCust = new Hashtable();
	String ownName = "";
	String ownTel = "";
	String keyinDate = "-";
	Calendar keyin = Calendar.getInstance();

	if (projList!=null) {
		for (int i=0;i<projList.length;i++) {
			String proj = doString.checkString(projList[i],"");
			if (proj.trim().length()>=6) {
				comId = proj.substring(0,2);
				projId = proj.substring(3,6);
				proj_restrict = "";
				if (!projId.equals("ALL")) {
					proj_restrict = "h.i_company = '"+comId+"' AND h.i_project = '"+projId+"' AND ";
				}
				rs = stmt.executeQuery("SELECT DISTINCT h.i_docno, h.f_qc, h.i_lock, h.d_complete_max, h.n_customer, h.n_cus_tel FROM lan:serv_dochd h, lan:serv_flow f WHERE "+proj_restrict+" (h.f_status = 'OPN' OR h.f_status = 'CLS') AND h.f_qc = 'Y' AND (h.qc_date IS NULL OR h.qc_date > '"+endDate+"') AND h.i_docno = f.i_docno AND f.f_itmstatus = '100' AND f.d_approve <= '"+endDate+" 23:59'");
				if (rs != null) {
					while (rs.next() == true) {
						line++;
						iDocNo = doString.checkString(rs.getString(1));
						qc = doString.checkString(rs.getString(2));
						iLock = doString.checkString(rs.getString("i_lock"),"-");
						tmpCust = common.getCustomerDetails(comId,projId,iLock);
						ownName = doString.DisplayThai(doString.checkString((String) tmpCust.get("n_customer"),""));
						ownTel = doString.DisplayThai(doString.checkString((String) tmpCust.get("n_cust_tel"),""));
			            nCustomer = doString.checkString(doString.DisplayThai(rs.getString("n_customer")),"");
			            nCustTel = doString.checkString(doString.DisplayThai(rs.getString("n_cus_tel")),"");
						iHouse = "&nbsp;";
						rs1 = stmt1.executeQuery("SELECT i_house FROM lan:acxlckmd WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lock = '"+iLock+"'");
						if (rs1 != null) {
							if (rs1.next() == true) {
								iHouse = doString.checkString(rs1.getString("i_house"),"-");
							}
							rs1.close();
							rs1=null;
						}
%>
					        <tr>
					          <td width="4%" align="center" class="dotline"><%=line%></td>
					          <td width="10%" align="center" class="dotline"><%=iDocNo%></td>
					          <td width="7%" class="dotline" align="center"><%=doString.checkString(iLock)%></td>
					          <td width="8%" class="dotline" align="center"><%=doString.checkString(iHouse)%></td>
					          <td width="16%" align="center" class="dotline"><%=DateUtil.ifxToThaiDateNoTime(rs.getString("d_complete_max"))%></td>
					          <td width="43%" class="dotline ; item"><%=common.joinContactAndOwner(nCustomer,ownName)%></td>
					          <td width="16%" align="center" class="dotline"><%=common.joinContactAndOwner(nCustTel,ownTel)%></td>
					        </tr>			
<%
					}// end while
					rs.close();
					rs=null;
				}
			}
		}// end for site
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
            <td class="act_tab4"><a href="javascript:history.back();"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
		System.out.println("ERROR SERV_QCForward.jsp : " + e.getMessage());
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