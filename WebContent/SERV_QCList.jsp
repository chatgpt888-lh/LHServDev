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
	String chkYear = doString.checkString(request.getParameter("chkYear"),"0");
	String thaiMonth[] = new String[] {"","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
	String shortMonth[] = new String[] {"","ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค."};
	String showMonth = thaiMonth[Integer.parseInt(chkMonth)];
	String showYear = Integer.toString(Integer.parseInt(chkYear)+543);

		int curMnth = Integer.parseInt(chkMonth);
		int curYear = Integer.parseInt(chkYear);
		int begMnth = curMnth - 1;
		int begYear = curYear;
		if (begMnth == 0) {
				begMnth = 12;
				begYear--;
		}
	String bfMnthDate = Integer.toString(begYear)+"-"+doString.displayNumber("00", begMnth)+"-01";
	String mnthDate = chkYear+"-"+chkMonth+"-01";
	String begCompDate = "";
	String endCompDate = "";

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
			rs = stmt.executeQuery("SELECT d_contructor FROM lan:serv_payschd WHERE d_contructor > '"+bfMnthDate+"' ORDER BY d_contructor");
			if (rs != null) {
				if (rs.next() == true) {
					begCompDate = doString.checkString(rs.getString(1));
				}
				rs.close();
				rs=null;
			}

			rs = stmt.executeQuery("SELECT d_contructor, d_vp FROM lan:serv_payschd WHERE d_contructor > '"+mnthDate+"' ORDER BY d_contructor");
			if (rs != null) {
				if (rs.next() == true) {
					endCompDate = doString.checkString(rs.getString(1));
				}
				rs.close();
				rs=null;
			}

        //----=======================================----//   
	   //-----============== Generate Display Customize and Page Link ==================-----//
	 //---=========================================================================----//                
%>
<HTML>
<HEAD>
<TITLE>Reprint List</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--

  function searchDocHD() {
     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_QCJobLst.jsp";
     document.forms[0].submit();  
  }

  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_QCJobLst.jsp";
     document.forms[0].submit();
  }   
  
  function validDate() {
     var sdate = document.forms[0].start_date.value;
     var smonth = document.forms[0].start_month.value;
     var syear = document.forms[0].start_year.value;
     var edate = document.forms[0].end_date.value;
     var emonth = document.forms[0].end_month.value;
     var eyear = document.forms[0].end_year.value; 
     
     //---- Check select date ---//
     if (sdate.length==0 && smonth.length==0 && syear.length==0 &&
         edate.length==0 && emonth.length==0 && eyear.length==0) {
         return true;
     }     

     
     var startDate = new Date(parseInt(syear,10),parseInt(smonth,10)-1,parseInt(sdate,10));
     var endDate = new Date(parseInt(eyear,10),parseInt(emonth,10)-1,parseInt(edate,10));
     
     if (startDate.getMonth()!=(parseInt(smonth,10)-1)) {
        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].start_date.focus();
        return false;
     }
     
     if (endDate.getMonth()!=(parseInt(emonth,10)-1)) {
        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].end_date.focus();
        return false;
     }     
     
	if (startDate>endDate) {
	    alert(" วันที่สิ้นสุดต้องไม่น้อยกว่าวันที่เริ่มต้น ! ");
	    return false;
	}
  
     return true;
  }

//-->
</script>

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
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
<%
		rs = stmt.executeQuery("SELECT n_desc FROM lan:serv_chksum WHERE i_code = '"+type+"'");
		if (rs != null) {
			if (rs.next() == true) {
				out.print(doString.DisplayThai(rs.getString("N_DESC")));
			}
			rs.close();
			rs=null;
		}
%>
</td>
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
          <td width="14%" class="col_name">เลขที่ใบแจ้งซ่อม</td>
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
	Hashtable tmpCust = new Hashtable();
	String ownName = "";
	String ownTel = "";
	String keyinDate = "-";
	Calendar keyin = Calendar.getInstance();
	boolean show = false;

	if (projList!=null) {
		for (int i=0;i<projList.length;i++) {
			String proj = doString.checkString(projList[i],"");
			if (proj.trim().length()>=6) {
				comId = proj.substring(0,2);
				projId = proj.substring(3,6);

				rs = stmt.executeQuery("SELECT h.i_docno, h.f_qc, h.i_lock, h.d_complete_max, h.n_customer, h.n_cus_tel FROM lan:serv_dochd h, lan:serv_flow f WHERE h.i_company = '"+comId+"' AND h.i_project = '"+projId+"' AND (h.f_status = 'OPN' OR h.f_status = 'CLS') AND h.i_docno = f.i_docno AND f.f_itmstatus = '100' AND MONTH(f.d_approve) = "+Integer.toString(curMnth)+" AND YEAR(f.d_approve) = "+chkYear);
				if (rs != null) {
					while (rs.next() == true) {
						show = true;
						iDocNo = doString.checkString(rs.getString(1));
						qc = doString.checkString(rs.getString(2));
						iLock = doString.checkString(rs.getString("i_lock"),"-");
						tmpCust = common.getCustomerDetails(comId,projId,iLock);
						ownName = doString.DisplayThai(doString.checkString((String) tmpCust.get("n_customer"),""));
						ownTel = doString.DisplayThai(doString.checkString((String) tmpCust.get("n_cust_tel"),""));
			            nCustomer = doString.checkString(doString.DisplayThai(rs.getString("n_customer")),"");
			            nCustTel = doString.checkString(doString.DisplayThai(rs.getString("n_cus_tel")),"");
						rs1 = stmt1.executeQuery("SELECT i_house FROM lan:acxlckmd WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lock = '"+iLock+"'");
						if (rs1 != null) {
							if (rs1.next() == true) {
								iHouse = doString.checkString(rs1.getString("i_house"),"-");
							}
							rs1.close();
							rs1=null;
						}
						if (chk_qc.equals("Y")) {
							if (!qc.equals("Y")) {
								show = false;
							}
						}
						if (show) {
%>
					        <tr>
					          <td width="14%" align="center" class="dotline"><%=iDocNo%></td>
					          <td width="7%" class="dotline" align="center"><%=doString.checkString(iLock)%></td>
					          <td width="8%" class="dotline" align="center"><%=doString.checkString(iHouse)%></td>
					          <td width="16%" align="center" class="dotline"><%=DateUtil.ifxToThaiDateNoTime(rs.getString("d_complete_max"))%></td>
					          <td width="43%" class="dotline ; item"><%=common.joinContactAndOwner(nCustomer,ownName)%></td>
					          <td width="16%" align="center" class="dotline"><%=common.joinContactAndOwner(nCustTel,ownTel)%></td>
					        </tr>			
<%
						}
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
		System.out.println("ERROR SERV_QCList.jsp : " + e.getMessage());
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