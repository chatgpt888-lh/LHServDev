<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
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
	doString str = new doString();	String user_group = doString.checkString(user.getUserGroup());
	String team_condition = "";	if (!user_group.equals("A")) {		team_condition = " AND a.i_team = '"+user_group+"' ";	}
    //----============ Declare Variables for input data ===========----//
    String dPayment = doString.checkString(request.getParameter("d_payment"),"");
    String iVendor = doString.checkString(request.getParameter("i_vendor"),"");
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
    
    
    //---========== If No i_vendor and this login is vendor , use i_vendor from login =============----//
    String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase();
   if  (selProj.length()==0) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       session.setAttribute("sess_sel_proj",selProj);
   }

    String docNo = doString.checkString(request.getParameter("i_docno"),"").toUpperCase();
	String itmType = doString.checkString(request.getParameter("itmType"));
	String itmType_restrict = "";
	if (!itmType.equals("")) {
		itmType_restrict = " AND b.i_itmtype = '"+itmType+"'";
	}
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
        if (docNo.trim().length()>0) {
           condition += " and a.i_docno='"+docNo+"' ";
        }
        if (iVendor.trim().length()>0) {
           condition += " and b.i_vendor='"+iVendor+"' ";
        }
        condition += " and b.d_payment='"+dPay+"' ";        
 	   //---=========================================================================----//   


        
        //----====================== Get PAYMENT Max Row ==============================-----//
        int maxRow = 0;
        sql.delete(0,sql.length());
        sql.append(" select count(*) from serv_infpayment b,serv_infdochd a ");
		sql.append(" where b.i_docno=a.i_docno and a.f_status='OPN' ");		sql.append(team_condition);
        sql.append(" and b.f_itmstatus='400' ").append(condition)
			.append(itmType_restrict)
             .append(" group by a.i_docno ");
        rs = stmt.executeQuery(sql.toString());
        while (rs.next()) {        
           maxRow++;
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
	   if (displayLine<Constants.SERV_CONTRACTORLIST_LINE) displayLine = Constants.SERV_CONTRACTORLIST_LINE;      
	   
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
	 String jspLink = "";
	 jspLink = "SERV_INFContractor_Conf_Disp.jsp?mode=view&i_vendor="+iVendor;
%>
<HTML>
<HEAD>
<TITLE>Contractor - ผู้รับเหมาส่งงาน</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--

  function searchDocHD() {
     document.forms[0].now_page.value='1';
     document.forms[0].action="/LHServ/SERV_INFContractor_List.jsp";
     document.forms[0].submit();  
  }

  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="/LHServ/SERV_INFContractor_List.jsp";
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
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            Contractor : ผู้รับเหมาส่งงาน</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                
            <td class="item_tab2" width="200">รายละเอียดการสั่งซ่อม</td>
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
                  <td class="item ; dotline01" height="22" width="15%">โครงการ 
                    :</td>
                  <td height="22" width="39%" class="dotline01"> <%=common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:250px' onchange='changePage(1);' ",true)%>
                  </td>
                  <td height="22" class="item ; dotline01" width="14%">&nbsp;</td>
                  <td height="22" width="32%" class="dotline01">&nbsp; </td>
                </tr>
                <tr> 
                  <td class="item ; dotline01" height="22" width="15%">ผู้รับเหมาซ่อม 
                    :</td>
                  <td height="22" width="39%" class="dotline01"><%=common.genVendorList("i_vendor",selProj,iVendor," class='box' style='width:250px' onchange='changePage(1);' ")%></td>
                  <td height="22" class="item ; dotline01" width="14%">เลขที่ใบสั่งซ่อม 
                    :</td>
                  <td height="22" width="32%" class="dotline01"> 
					<input type="text" name="i_docno" class="box" style="width:100px" value="<%=docNo%>">
                    &nbsp;&nbsp;&nbsp;&nbsp; <a href="#" onclick="searchDocHD()"><img border="0" src="images/i_search.gif" align="absmiddle" width="20" height="20"></a>
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
                <td class="item_tab2" width="160">รายการซ่อม</td>
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
                  <td width="20%" class="col_name">เลขที่ใบสั่งซ่อม</td>
                  <td width="28%" class="col_name">ชื่อผู้แจ้ง</td>
                  <td width="23%" class="col_name">วันที่นัดซ่อม</td>
                  <td width="29%" class="col_name">สถานะของงาน</td>
                </tr>


        <%
        
		     //----================== Select Data from SERV_DOCHD ================----//   
		        int line = 0;		     
		        sql.delete(0,sql.length());
		        sql.append("select first ").append(endRow).append(" distinct a.i_docno ")
		              .append(" from serv_infpayment b,serv_infdochd a ");
				sql.append(" where ");
                 sql.append(" b.i_docno=a.i_docno and a.f_status='OPN' ")						.append(team_condition)
                      .append(" and b.f_itmstatus='400' ").append(condition)
						.append(itmType_restrict)
                      .append(" order by a.i_docno");
				Hashtable tmpHeader = new Hashtable();
				Hashtable tmpCust = new Hashtable();
				String iDocNo = "";
				String inform_emp = "";
				String iLock = "";
				String iCompany = "";
				String iProject = "";
				String dAppoint = "";
				String status = "";
		        rs = stmt.executeQuery(sql.toString());
		        for (int i=0;i<maxRow;i++) { 
                      if (rs.next()) {
                         if (i>=startRow && i<=endRow) {
                            //------ Data is in this page , display -----//
				            iDocNo = doString.checkString(rs.getString("i_docno"),"");
				            
					         //----======================== Find DocHD Data =============================----//				            
							 tmpHeader = common.getInfDocHeaderDetails(iDocNo);
					         iCompany = doString.checkString((String) tmpHeader.get("i_company"),"");
					         iProject = doString.checkString((String) tmpHeader.get("i_project"),"");					         
					         inform_emp = doString.DisplayThai(doString.checkString((String) tmpHeader.get("inform_emp"),""));	
							 dAppoint = doString.checkString((String) tmpHeader.get("d_appoint"),"-");


							//----======================= Get Customer Details ===========================----//
							status = doString.DisplayThai(doString.checkString(common.getInfContractorStatus(iDocNo,iVendor),"-"));
					        %>
                <tr> 
                  <td width="20%" align="center" class="dotline"><a href="<%=jspLink%>&i_docno=<%=iDocNo%>"><%=iDocNo%></a></td>
                  <td width="28%" align="left" class="dotline"><%=inform_emp%></td>
                  <td width="23%" align="center" class="dotline"><%=dAppoint%>&nbsp;</td>
                  <td width="29%" align="center" class="dotline"><%=status%>&nbsp;</td>
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
                  <td width="20%" align="center" class="dotline">&nbsp;</td>
                  <td width="28%" align="center" class="dotline">&nbsp;</td>
                  <td width="23%" class="dotline ; item">&nbsp;</td>
                  <td width="29%" align="center" class="dotline">&nbsp;</td>
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
		stmt.close();
		conn.close();
		stmt=null;
		conn=null;
	} catch (Exception e) {
		System.out.println("ERROR SERV_INFContractor_List.jsp : " + e.getMessage());
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