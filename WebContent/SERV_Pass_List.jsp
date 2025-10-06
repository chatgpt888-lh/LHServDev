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

    public Double[] newDoubleArray(int size) {
        Double result[] = new Double[size];
	for (int i=0;i<size;i++) {
	       result[i] = new Double(0.0);
	}

	return result;
    }

%>

<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_Pass_List.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   doString str = new doString();

    //----============ Declare Variables for input data ===========----//
    String dPayment = doString.checkString(request.getParameter("d_payment"),"");
    String selProj = doString.checkString(request.getParameter("sel_project"),"");
   if  (selProj.length()==0) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       session.setAttribute("sess_sel_proj",selProj);
   }

    String iVendor = "";
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


    String condition = "";
    double totalWage = 0.00;
    double totalGoods = 0.00;
    double totalPay = 0.00;
    double totalPV = 0.00;

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
        if (user.getUserWho().equalsIgnoreCase(Constants.PERMISSION_VENDOR)) {
 		   iVendor = user.getEmpId();
           condition += " and b.i_vendor='"+user.getEmpId()+"' ";
        }
		/*
        if (selProj.trim().length()>=6) {
 		    condition += " and a.i_company='"+(selProj.substring(0,2))+"' and a.i_project='"+(selProj.substring(3,6))+"' ";
        } else {
			//condition = " and a.i_company='XX' and a.i_project='999' "; // used for protect select all when no choose project 
		}*/
        if (selProj.trim().length()>=6 && !selProj.equalsIgnoreCase("ALL")) {
		   condition += " and a.i_company='"+(selProj.substring(0,2))+"' and a.i_project='"+(selProj.substring(3,6))+"' ";
        }
		if (selProj.trim().length()<=0) {
		   String projList = common.getProjectListByUserId(user.getUserID());
		   if (projList.length()>0) {
		       //condition += " and substr(a.i_docno,1,6) in ("+projList+") ";

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
						condition += " and ("+projCondition+") ";
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

        condition += " and b.d_payment='"+dPay+"' ";          
 	   //---=========================================================================----//   




        //----==================== Get Vendor Percent cut from SERV_XSTD  ====================-----//
        Vector vendorCut = new Vector();
        sql.delete(0,sql.length());
        sql.append(" select * from lan:serv_xstd where i_type='04' ");
		servlog.startLog(sql.toString());
        rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
        while (rs.next()) {
           double percent = rs.getDouble("p_amount");
	   vendorCut.addElement(new Double(percent));
        }
        rs.close();
	//---==============================================================================----//

  


        
        //----====================== Get PAYMENT Max Row ==============================-----//
        
        	StringBuilder sqlB = new StringBuilder();
			sqlB.delete(0,sqlB.length());
			
			if(user.getUserCom().equals("LH")){
				//LH-ALL
				sqlB.append(" and not exists ( ")
				    .append(" select c.i_project from lan:serv_local c  ")
				    .append(" where  a.i_company = c.i_company ")
				    .append(" and  a.i_project = c.i_project ")
				    .append(" ) ");
	             //-- and  c.i_type = "NE"
			}else{		
			    //NE-ALL,LN-ALL
			    sqlB.append(" and  exists ( ")
				    .append(" select c.i_project from lan:serv_local c  ")
				    .append(" where  a.i_company = c.i_company ")
				    .append(" and  a.i_project = c.i_project ")
				    .append(" and  c.i_type = '"+user.getUserCom()+"' ")
				    .append(" ) ");
			}
			if(user.getUserWho().equals("A")){ //lee admin
			   sqlB.delete(0,sqlB.length());
			}
		
        int maxRow = 0;
        sql.delete(0,sql.length());
        sql.append(" select count(*) from serv_payment b,serv_dochd a where ")
              .append(" b.i_docno=a.i_docno and a.f_status in ('OPN','CLS') ")
              .append(" and b.f_itmstatus='CLS' ").append(condition)  
              .append(sqlB.toString())                 
              .append(" group by b.i_docno,b.i_vendor ");
		servlog.startLog(sql.toString());
        rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
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
	   
	   if (displayLine<Constants.SERV_STAFFLIST_LINE) displayLine = Constants.SERV_STAFFLIST_LINE;      
	   
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
<TITLE>ใบแจ้งซ่อม - อนุมัติแล้ว</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>



<script language="javascript">
<!--
  function doSubmitForm(url){
    //alert("submit");
     pleaseWaiting();    
 	$('form').attr('action', url);
	$("form:first").submit();
  }
  
  var tmpComment = new Array(); 

  function searchDocHD() {
      pleaseWaiting();  
     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Pass_List.jsp";
     document.forms[0].submit();  
  }

  function changePage(page) {
       pleaseWaiting();  
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Pass_List.jsp";
     document.forms[0].submit();
  }
   
//-->
</script>



<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">

<input type="hidden" name="d_payment" value="<%=dPayment%>">
<input type="hidden" name="now_page" value="<%=nowPage%>">
<input type="hidden" name="mode" value="">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ใบแจ้งซ่อม - อนุมัติแล้ว</td>
          <td width="50%" align="right">
          <table border="0" width="140" cellspacing="0" cellpadding="0">
              <tr>
                <td width="100%" class="TextMenu"><a href="SERV_Pass_Full.jsp?sel_project=<%=selProj%>&d_payment=<%=dPayment%>&i_vendor=<%=iVendor%>"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="15" height="15">
                  แสดงแบบรายละเอียด</a></td>
              </tr>
          </table>            
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
          <td class="col_name" width="17%" rowspan="2">เลขที่ใบแจ้งซ่อม</td>
          <td class="col_name" width="9%" rowspan="2">แปลง</td>
          <td class="col_name" width="9%" rowspan="2">บ้านเลขที่</td>
          <td class="col_name" width="13%" rowspan="2">ค่าแรง</td>
          <td class="col_name" width="13%" rowspan="2">ค่าของ</td>
          <td class="col_name" width="13%" rowspan="2">ค่าของ+ค่าแรง</td>
          <td class="col_name" width="13%" rowspan="2">รวมค่า ดำเนินการ <!--<%//=(int) markupPay%>%--></td>
          <td class="col_name" width="13%" colspan="<%=vendorCut.size()%>">ตัดเงินผู้รับเหมา</td>
        </tr>       
	  <tr>
	  <%
	    for (int c=0;c<vendorCut.size();c++) {
		  Double percent = (Double) vendorCut.elementAt(c);
		  %><td width="6%" class="col_name"><nobr><%=format.format(percent.doubleValue())%> %</nobr></td><%
	    }
	  %>
	  </tr>
  
        <%
        
		     //----================== Select Data from SERV_DOCHD ================----//   
		        int line = 0;		     
		        sql.delete(0,sql.length());
		        sql.append(" select b.i_docno,sum(q_wage_unit * z_wage_price) sum_wage, ")
		              .append(" sum(q_good_unit * z_good_price) sum_goods, ")
		              .append(" sum(z_amount_pay) sum_amount_pay, sum(z_amount_pv) sum_amount_pv, ")
		              .append(" sum(z_amount_cut) sum_amount_cut from serv_dochd a,serv_payment b ")
		              .append(" where b.i_docno=a.i_docno and a.f_status in ('OPN','CLS') and b.f_itmstatus='CLS' ")
				     // .append(" and a.i_company='"+(selProj.length()>=6 ? selProj.substring(0,2) : "")+"' and a.i_project='"+(selProj.length()>=6 ? selProj.substring(3,6) : "")+"' ")
		            //  .append(" and b.i_vendor='").append(iVendor).append("' ")
				      .append(condition)
				       .append(sqlB.toString())   
		              .append(" group by b.i_docno order by b.i_docno ");	
		        //System.out.println("111 = "+sql.toString());     	 
				servlog.startLog(sql.toString());
		        rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
		        for (int i=0;i<maxRow;i++) { 
                      if (rs.next()) {
                         if (i>=startRow && i<endRow) {
  
                            //------ Data is in this page , display -----//
				            String iDocNo = doString.checkString(rs.getString("i_docno"),"");	            
							double sumWage = rs.getDouble("sum_wage");
							double sumGoods = rs.getDouble("sum_goods");
							double amountPay = rs.getDouble("sum_amount_pay");
							double amountPV = rs.getDouble("sum_amount_pv");
							Double cutVendor[] = newDoubleArray(vendorCut.size());
							
							totalWage += sumWage;
							totalGoods += sumGoods;
							totalPay += amountPay;
							totalPV += amountPV;

				            
					         //----======================== Find DocHD Data =============================----//				            
							 Hashtable tmpHeader = common.getDocHeaderDetails(iDocNo);
					         String iLock = doString.checkString((String) tmpHeader.get("i_lock"),"");
					         String iCompany = doString.checkString((String) tmpHeader.get("i_company"),"");
					         String iProject = doString.checkString((String) tmpHeader.get("i_project"),"");


							//----======================= Get Customer Details ===========================----//
							Hashtable tmpCust = common.getCustomerDetails(iCompany,iProject,iLock);
						    String iHouse = doString.checkString((String) tmpCust.get("i_house"),"");
						          


							//---============ Find Vendor Cut ==============---//
							sql.delete(0,sql.length());
							sql.append(" select b.i_docno,p_cut,sum(z_cut_pv) sum_cut_pv from serv_dochd a,serv_payment b ")
							      .append(" where b.i_docno=a.i_docno and a.f_status='OPN' and b.f_itmstatus='CLS'  and b.i_ven_cut<>'999999' ")
								  //.append(" and substr(b.i_docno,1,2)||':'||substr(b.i_docno,4,3)='").append(selProj).append("' ")
								  .append(" and a.i_company='"+(selProj.length()>=6 ? selProj.substring(0,2) : "")+"' and a.i_project='"+(selProj.length()>=6 ? selProj.substring(3,6) : "")+"' ")
							      .append(" and b.i_docno='").append(iDocNo).append("' ")
							       .append(sqlB.toString())   
							      .append(" group by b.i_docno,p_cut order by b.i_docno ");		
							//System.out.println("222 = "+sql.toString());
							servlog.startLog(sql.toString());
							rs1 = stmt1.executeQuery(sql.toString());
							servlog.endLog();
							while (rs1.next()) {
							    double pCut = rs1.getDouble("p_cut");
							    double cutValue = rs1.getDouble("sum_cut_pv");

							    for (int c=0;c<vendorCut.size();c++) {
							          Double cut = (Double)  vendorCut.elementAt(c);
								  if (cut.doubleValue()==pCut) {
								      cutVendor[c] = new Double(cutVendor[c].doubleValue()+cutValue);
								      sumCutVendor[c] = new Double(sumCutVendor[c].doubleValue()+cutValue);
								      break;
								  }
							    }
							}
							rs1.close();



					        %>
					        <tr>
					          <td class="dotline" width="17%" align="center"><%=iDocNo%></td>
					          <td class="dotline" width="9%" align="center"><%=iLock%></td>
					          <td class="dotline" width="9%" align="center"><%=iHouse%></td>
					          <td align="right" class="dotline" width="13%"><%=format.format(sumWage)%></td>
					          <td align="right" class="dotline" width="13%"><%=format.format(sumGoods)%></td>
					          <td align="right" class="dotline" width="13%"><%=format.format(amountPay)%></td>
					          <td align="right" class="dotline" width="13%">&nbsp;<%=format.format(amountPV)%></td>
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
                
	           while (line<Constants.SERV_ZONECONF_LINE) {
	               line++;
	                %>
			        <tr>
			          <td class="dotline" width="17%" align="center">&nbsp;</td>
			          <td class="dotline" width="9%" align="center">&nbsp;</td>
			          <td class="dotline" width="9%" align="center">&nbsp;</td>
			          <td align="right" class="dotline" width="13%">&nbsp;</td>
			          <td align="right" class="dotline" width="13%">&nbsp;</td>
			          <td align="right" class="dotline" width="13%">&nbsp;</td>
			          <td align="right" class="dotline" width="13%">&nbsp;</td>
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
          <td align="center" class="dotline ; item" colspan="3">รวมเป็นเงิน</td>
          <td align="right" class="dotline ; item" width="13%"><%=format.format(totalWage)%></td>
          <td align="right" class="dotline ; item" width="13%"><%=format.format(totalGoods)%></td>
          <td align="right" class="dotline ; item" width="13%"><%=format.format(totalPay)%></td>
          <td align="right" class="dotline ; item" width="13%"><%=format.format(totalPV)%></td>
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
            <td width="150" class="act_tab2">&nbsp;</td>   
                  	
                  	
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
	
</BODY>

</HTML>

<%     System.out.println("------- SERV_Pass_List.jsp -------");
	} catch (Exception e) {
		System.out.println("ERROR SERV_Pass_List.jsp : " + e.getMessage());
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