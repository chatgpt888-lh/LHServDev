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
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>


<%!

    public Double[] newDoubleArray(int size) {
        Double result[] = new Double[size];
	for (int i=0;i<size;i++) {
	       result[i] = new Double(0.0);
	}

	return result;
    }

%>

<%
    doString str = new doString();

    //----============ Declare Variables for input data ===========----//
    String dPayment = doString.checkString(request.getParameter("d_payment"),"");
    String dPay = "";

    if (dPayment.length()==0) {
       //---========== If no data from parameter , get from session instead =============----//
       dPayment = doString.checkString((String) session.getAttribute("sess_dPayment"),"");
       dPay = doString.checkString((String) session.getAttribute("sess_dPay"),"");
    } else {
       //---========== If receive from parameter , set to session ============----//
       session.setAttribute("sess_dPayment",dPayment);
    }
    if (dPay.length()==0 && dPayment.length()==10) {
       //---========== First Time to use , convert format ================----//
       int year = Integer.parseInt(dPayment.substring(6,10));
       if (year>2400) year -= 543;
       dPay = year+"-"+dPayment.substring(3,5)+"-"+dPayment.substring(0,2);
       session.setAttribute("sess_dPay",dPay);
    }


    String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase();
   if  (selProj.length()==0) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       session.setAttribute("sess_sel_proj",selProj);
   }
	String itmType = doString.checkString(request.getParameter("itmType"));
	String itmType_restrict = "";
	if (!itmType.equals("")) {
		itmType_restrict = " AND b.i_itmtype = '"+itmType+"'";
	}
    String condition = "";
    double totalSumWage = 0.00;
    double totalSumGoods = 0.00;
    double grandTotal = 0.00;
    double sumCalMarkup = 0.00;

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
		   condition = " and a.i_company='"+(selProj.substring(0,2))+"' and a.i_project='"+(selProj.substring(3,6))+"' ";
        }
		if (selProj.trim().length()<=0) {
		   String projList = common.getProjectListByUserId(user.getUserID());
		   if (projList.length()>0) {
			   //================== modified to used index field =====================//
				if (projList.trim().length()>0) {
					String projCondition = "";
					StringTokenizer plist = new StringTokenizer(projList,",");
					String proj = "";
					String icom = "";
					String iproj = "";

					while (plist.hasMoreTokens()) {
						proj = str.replace(plist.nextToken(),"'","").trim();
						if (proj.length()>=6) {
							icom = proj.substring(0,2);
							iproj = proj.substring(3,6);
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
			sql.append(" select count(*) from lan:serv_pstaff  where user_id='").append(user.getUserID()).append("' and proj_id='ALL' ");
			int checkAllPermission = 0;

			rs = stmt.executeQuery(sql.toString());
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
        if (user.getUserWho().equalsIgnoreCase(Constants.PERMISSION_VENDOR)) {
           condition += " and b.i_vendor='"+user.getEmpId()+"' ";
        }
        condition += " and b.d_payment='"+dPay+"' ";
 	//---=========================================================================----//




        //----==================== Get Vendor Percent cut from SERV_XSTD  ====================-----//
        Vector vendorCut = new Vector();
		double percent = 0.0;
        sql.delete(0,sql.length());
        sql.append(" select p_amount from lan:serv_xstd where i_type='09' ");
        rs = stmt.executeQuery(sql.toString());
        while (rs.next()) {
           percent = rs.getDouble("p_amount");
	       vendorCut.addElement(new Double(percent));
        }
        rs.close();
	//---==============================================================================----//





        //----====================== Get PAYMENT Max Row ==============================-----//
        int maxRow = 0;
        sql.delete(0,sql.length());
        sql.append(" select count(*) from lan:serv_infpayment b, lan:serv_infdochd a where ")
              .append(" b.i_docno=a.i_docno and a.f_status='OPN' ")
              .append(" and b.f_itmstatus='600' ").append(condition)
			.append(itmType_restrict)
              .append(" group by b.i_vendor ");
        rs = stmt.executeQuery(sql.toString());
        while (rs.next()) {
           maxRow++;
        }
        rs.close();
	   //---=========================================================================----//


       Double sumCutVendor[] =  newDoubleArray(vendorCut.size());


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
<TITLE>Service Manager - ผู้จัดการโครงการ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--

  function searchDocHD() {
     document.forms[0].now_page.value='1';
     document.forms[0].action="/LHServ/SERV_CONManager_List.jsp";
     document.forms[0].submit();
  }

  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="/LHServ/SERV_CONManager_List.jsp";
     document.forms[0].submit();
  }

//-->
</script>


<base target="_self">


</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">

<input type="hidden" name="now_page" value="<%=nowPage%>">
<input type="hidden" name="d_payment" value="<%=dPayment%>">
<input type="hidden" name="itmType" value="<%=itmType%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center" class="BD">


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            Service Manager - ผู้จัดการโครงการ</td>
          <td width="30%" align="right">
          </td>
        </tr>
      </table>


<br style="font-size:10pt">




            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">ค้นหารายการ</td>
                <td class="item_tab3"></td>
                <td>&nbsp;วันที่จ่าย&nbsp; <%=dPayment%></td>
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
    <td class="item ; dotline01" height="22" width="15%">โครงการ :</td>
    <td height="22" width="85%" class="dotline01">
	<%=common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:250px' ",true)%>
    &nbsp;&nbsp;&nbsp;&nbsp; <img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22" onclick="searchDocHD()" style='cursor:hand;'></td>
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
                
            <td class="item_tab2" width="200">รายละเอียดงานตามสัญญา</td>
                <td class="item_tab3"></td>
                <td >&nbsp;</td>
              </tr>
            </table>


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td valign="bottom" class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
    <td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL" align="center">


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="30%" class="col_name" rowspan="2">ผู้รับเหมา</td>
                  <td width="10%" class="col_name" rowspan="2">จำนวนใบเบิกงวด</td>
    <td width="12%" class="col_name" rowspan="2">ค่าแรง</td>
    <td width="12%" class="col_name" rowspan="2">ค่าของ</td>
    <td width="12%" class="col_name" rowspan="2">ค่าแรง+ค่าของ</td>
    <td width="12%" class="col_name" rowspan="2">รวมค่าดำเนินการ </td>
    <td width="12%" class="col_name" colspan="<%=vendorCut.size()%>">ตัดเงินผู้รับเหมา</td>
  </tr>
  <tr>
  <%
	Double per = new Double(0);
    for (int c=0;c<vendorCut.size();c++) {
          per = (Double) vendorCut.elementAt(c);
	  %><td width="6%" class="col_name"><nobr><%=format.format(per.doubleValue())%> %</nobr></td><%
    }
  %>
  </tr>    
  
        <%

		     //----================== Select Data from SERV_DOCHD ================----//
		        int line = 0;

				String iVendor = "";
				String vendorName = "";
				double sumWage = 0.00;
				double sumGoods = 0.00;
				double totalSum = 0.00;
				double calMarkupPay = 0.00;
				Double cutVendor[] = null;
				int countDoc = 0;
				double pCut = 0.0;
				double cutValue = 0.0;
				Double tmpCut = new Double(0);
				String markupPay = "";
				double pAddPay = 0.0;

		        sql.delete(0,sql.length());
		        sql.append(" select first ").append(endRow).append(" distinct d.bus_name,b.i_vendor ")
		              .append(" from lan:serv_infpayment b ")
		              .append(" left join lan:stpvendr d on d.vend_code=b.i_vendor ")
		              .append(" ,lan:serv_infdochd a where b.i_docno=a.i_docno and a.f_status='OPN' and b.f_itmstatus='600' ")
		              .append(condition)
						.append(itmType_restrict)
		              .append(" order by d.bus_name ");
		        rs = stmt.executeQuery(sql.toString());
		        for (int i=0;i<maxRow;i++) {
                      if (rs.next()) {
                         if (i>=startRow && i<=endRow) {
                            //------ Data is in this page , display -----//
				            iVendor = doString.checkString(rs.getString("i_vendor"),"");
							vendorName = doString.checkString(doString.DisplayThai(rs.getString("bus_name")),"");



							//----======================= Get Payment Details ===========================----//
							sumWage = 0.00;
							sumGoods = 0.00;
							totalSum = 0.00;
							calMarkupPay = 0.00;
							cutVendor = newDoubleArray(vendorCut.size());
							countDoc = 0;


							//----====================== Count Job Form ==================----//
							sql.delete(0,sql.length());
							sql.append(" select count(*) from serv_infpayment b,serv_infdochd a where b.f_itmstatus='600' ")
							     .append(" and b.i_vendor='").append(iVendor).append("' and a.f_status='OPN' ")
							     .append(" and b.i_docno=a.i_docno ").append(condition)
								.append(itmType_restrict)
							     .append(" group by b.i_docno ");
						    rs1 = stmt1.executeQuery(sql.toString());
						    while (rs1.next()) {
						        countDoc++;
						    }
						    rs1.close();


							//---============ Find All Summary Except Vendor Cut ==============---//
							sql.delete(0,sql.length());
							sql.append(" select b.i_vendor,sum(b.q_wage_unit*b.z_wage_price) sum_wage, ")
							      .append(" sum(b.q_good_unit*b.z_good_price) sum_goods, ")
							      .append(" sum(b.z_amount_pay) sum_amount_pay, ")
							      .append(" sum(b.z_amount_pv) sum_amount_pv ")
							      .append(" from lan:serv_infpayment b , lan:serv_infdochd a ")
							      .append(" where b.i_docno=a.i_docno and b.f_itmstatus='600' and a.f_status='OPN' ")
							      .append(" and b.i_vendor='").append(iVendor).append("' ")
							      .append(condition)
								.append(itmType_restrict)
							      .append(" group by i_vendor ");
							rs1 = stmt1.executeQuery(sql.toString());
							if (rs1.next()) {
							    sumWage = rs1.getDouble("sum_wage");
							    sumGoods = rs1.getDouble("sum_goods");
							    totalSum = rs1.getDouble("sum_amount_pay");
							    calMarkupPay = rs1.getDouble("sum_amount_pv");

							    totalSumWage += sumWage;
							    totalSumGoods += sumGoods;
							    sumCalMarkup += calMarkupPay;
							    grandTotal += totalSum;
							}
							rs1.close();


							//---============ Find Vendor Cut ==============---//
							pCut = 0.0;
							cutValue = 0.0;
							sql.delete(0,sql.length());
							sql.append(" select p_cut,sum(b.z_cut_pv) sum_cut_pv ")
							      .append(" from lan:serv_infpayment b , lan:serv_infdochd a ")
							      .append(" where b.i_docno=a.i_docno and b.f_itmstatus='600' and b.i_ven_cut<>'999999' ")
							      .append(" and b.i_vendor='").append(iVendor).append("' and a.f_status='OPN' ")
							      .append(condition)
								.append(itmType_restrict)
							      .append(" group by i_vendor,p_cut ");
							rs1 = stmt1.executeQuery(sql.toString());
							while (rs1.next()) {
							    pCut = rs1.getDouble("p_cut");
							    cutValue = rs1.getDouble("sum_cut_pv");

							    for (int c=0;c<vendorCut.size();c++) {
							          tmpCut = (Double)  vendorCut.elementAt(c);
									  if (tmpCut.doubleValue()==pCut) {
										  cutVendor[c] = new Double(cutValue);
										  sumCutVendor[c] = new Double(sumCutVendor[c].doubleValue()+cutValue);
										  break;
									  }
							    }
							}
							rs1.close();


						//----==================== Get Markup Pay from SERV_XSTD  ====================-----//
						markupPay = "";
						pAddPay = 0.0;
						if (selProj.trim().length()>0 && iVendor.trim().length()>0) {
							 sql.delete(0,sql.length());
							 sql.append(" select * from lan:serv_venprj where ")
								   .append(" i_company='").append(selProj.length()>=6 ? selProj.substring(0,2) : "").append("' ")
								   .append(" and i_project='").append(selProj.length()>=6 ? selProj.substring(3,6) : "").append("' ")
								   .append(" and i_vendor='").append(iVendor).append("' ");
							 rs1 = stmt1.executeQuery(sql.toString());
							 if (rs1.next()) {
							if (itmType.equals("01")) {
								pAddPay = rs1.getDouble("p_inf_pay");
							} else {
								pAddPay = rs1.getDouble("p_add_pay");
							}
								markupPay = doString.displayNumber("##0.0",pAddPay)+" %";
							 }				        
							 rs1.close();	
						}
						if (markupPay.trim().length()>0) { markupPay = "("+markupPay+")"; }
					   //---=========================================================================----//      
					        %>
					  <tr>
					    <td width="30%" class="dotline" align="left"><a href="SERV_CONManager_Conf.jsp?itmType=<%=itmType%>&i_vendor=<%=iVendor%>&sel_project=<%=selProj%>"><%=vendorName%></a></td>
					    <td width="10%" class="dotline" align="right"><%=countDoc%></td>
					    <td width="12%" class="dotline" align="right"><%=format.format(sumWage)%></td>
					    <td width="12%" class="dotline" align="right"><%=format.format(sumGoods)%></td>
					    <td width="12%" class="dotline" align="right"><%=format.format(totalSum)%></td>
					    <td width="12%" class="dotline" align="right"><%=format.format(calMarkupPay)%></td>
							    <%
							     for (int c=0;c<vendorCut.size();c++) {
								  %><td width="6%" class="dotline" align="right"><%=format.format(cutVendor[c].doubleValue())%></td><%
							     }
							    %>
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
					    <td width="30%" class="dotline" align="left">&nbsp;</td>
					    <td width="10%" class="dotline" align="right">&nbsp;</td>
					    <td width="12%" class="dotline" align="right">&nbsp;</td>
					    <td width="12%" class="dotline" align="right">&nbsp;</td>
					    <td width="12%" class="dotline" align="right">&nbsp;</td>
					    <td width="12%" class="dotline" align="right">&nbsp;</td>
					   <%
					    for (int c=0;c<vendorCut.size();c++) {
						  %><td width="6%" class="dotline" align="right">&nbsp;</td><%
					    }
					   %>
					  </tr>
	                <%
	           }

        %>              
  <tr>
    <td class="solidline ; item" align="center" colspan="2">รวม</td>
    <td width="12%" class="solidline ; item" align="right"><%=format.format(totalSumWage)%></td>
    <td width="12%" class="solidline ; item" align="right"><%=format.format(totalSumGoods)%></td>
    <td width="12%" class="solidline ; item" align="right"><%=format.format(totalSumWage+totalSumGoods)%></td>
    <td width="12%" class="solidline ; item" align="right"><%=format.format(sumCalMarkup)%></td>
    <%
     for (int c=0;c<vendorCut.size();c++) {
	  %><td width="6%" class="solidline ; item" align="right"><%=format.format(sumCutVendor[c].doubleValue())%></td><%
     }
     %>
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
            <td class="act_tab4"><a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
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
		System.out.println("ERROR SERV_CONManager_List.jsp : " + e.getMessage());
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