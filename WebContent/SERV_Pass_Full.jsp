<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>

<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.Constants"%>
<%@ page import="serv.util.ServLog" %>

<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_Pass_Full.jsp";
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
    String condition = ""; 
    
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

    if (user.getUserWho().equalsIgnoreCase(Constants.PERMISSION_VENDOR)) {
       iVendor = user.getEmpId();
    }
    
			       
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
        
        
        //----====================== Get Project Name ==============================-----//
        String projectName = "";
		sql.delete(0,sql.length());
		sql.append(" select n_project from lan:acxprojt where i_company='"+(selProj.length()>=6 ? selProj.substring(3,6) : "")+"' and i_project='"+(selProj.length()>=6 ? selProj.substring(3,6) : "")+"' ");
		servlog.startLog(sql.toString());
	    rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
	    while (rs.next()) {
	        projectName = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
	    }
	    rs.close();        
	   //---=========================================================================----//   
	           

        //---====================== Generate Search Condition ===========================---//
        if (selProj.trim().length()>=6 && !selProj.equalsIgnoreCase("ALL")) {
           //condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
		   condition = " and a.i_company='"+(selProj.substring(0,2))+"' and a.i_project='"+(selProj.substring(3,6))+"' ";
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
						condition = " and ("+projCondition+") ";
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
        if (iVendor.trim().length()>0) {
           condition += " and b.i_vendor='"+iVendor+"'  ";
        }                    
		condition += " and b.d_payment='"+dPay+"' ";      
 	   //---=========================================================================----//   

		
        //----====================== Get DOCHD Max Row ==============================-----//
        int maxRow = 0;
		sql.delete(0,sql.length());
		sql.append(" select count(*) from serv_payment b,serv_dochd a where b.f_itmstatus='CLS' ")
		    // .append(" and b.i_vendor='").append(iVendor).append("' ")
			 //.append(" and a.i_company='"+(selProj.length()>=6 ? selProj.substring(0,2) : "")+"' and a.i_project='"+(selProj.length()>=6 ? selProj.substring(3,6) : "")+"' ")
			 .append(condition)
		     .append(" and b.i_docno=a.i_docno ").append(condition)
		     .append(" group by b.i_docno ");
		servlog.startLog(sql.toString());
	    rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
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
	   	   
	   if (displayLine<Constants.SERV_ZONECONF_FULL_LINE) displayLine = Constants.SERV_ZONECONF_FULL_LINE;      
	   
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

  function searchDocHD() {
     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Pass_Full.jsp";
     document.forms[0].submit();  
  }

  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Pass_Full.jsp";
     document.forms[0].submit();
  }
  
  
//-->
</script>


<style>
td		{	font-size:8.0pt	}
</style>

<base target="_self">
</HEAD>

<BODY leftMargin=15 topMargin=15 marginheight="15" marginwidth="15">


<FORM METHOD="POST" ACTION="">

	<input type='hidden' name='now_page' value='<%=nowPage%>'>
	<input type='hidden' name='sel_project' value='<%=selProj%>'>
	<input type="hidden" name="mode" value="">
    <input type="hidden" name="success_page" value="SERV_Pass_List.jsp">
    <input type="hidden" name="error_page" value="SERV_Pass_Full.jsp?error=1">
	
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ใบแจ้งซ่อม - อนุมัติแล้ว</td>
          <td width="50%" align="right">
          <table border="0" width="140" cellspacing="0" cellpadding="0">
              <tr>
                <td width="100%" class="TextMenu"><a href="SERV_Pass_List.jsp?sel_project=<%=selProj%>&d_payment=<%=dPayment%>"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="15" height="15">
                  แสดงแบบสรุป</a></td>
              </tr>
          </table>            
          </td>
        </tr>
      </table>



<br style="font-size:10pt">
                


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="45%" style="font-size: 16pt; color: rgb(255,100,0); letter-spacing: 3px; padding: 5px">
           <%=projectName%></td>
          <td width="55%" align="right">
				  &nbsp;<input type="radio" value="L" checked name="display_type" <%=(displayType.equalsIgnoreCase("L") ? "checked" : "")%>>แสดงจำนวนรายการต่อหน้า&nbsp;
                  <input type="text" name="display_line" class="boxC" style="width:50px" value="<%=displayLine%>">&nbsp;
                  รายการ&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" value="A" name="display_type" <%=(displayType.equalsIgnoreCase("A") ? "checked" : "")%>>
                  แสดงรายการทั้งหมด&nbsp;&nbsp;&nbsp;&nbsp;
                  <a href="#" onclick="changePage(1);"><img border="0" src="images/bu_R.gif" align="absmiddle" style="cursor:hand" width="16" height="16"></a>          
          </td>
        </tr>
      </table>
      
<%
		     //----================== Select Data from SERV_DOCHD ================----//   
		        int line = 0;
		        String oldiDocNo = "";
		        
		        sql.delete(0,sql.length());
		        sql.append(" select first ").append(endRow).append(" a.i_docno,a.i_lock,c.n_project,a.i_type_cutlck ")
		              .append(" ,d.n_desc,e.i_house from serv_payment b,serv_dochd a ")
		              .append(" left join acxprojt c on c.i_company=a.i_company ")
  		              .append(" and c.i_project=a.i_project ")
		              .append(" left join serv_xstd d on d.i_type='03' and d.i_code=a.i_type_cutlck ")
		              .append(" left join acxlckmd e on e.i_company=a.i_company and e.i_project=a.i_project ")
		              .append(" and e.i_lock=a.i_lock where ")
		              .append(" a.f_status in ('OPN','CLS') and b.i_docno=a.i_docno ")
		              .append(" and b.f_itmstatus='CLS' ")
		              //.append(" and b.i_vendor='").append(iVendor).append("' ")
				      //.append(" and a.i_company='"+(selProj.length()>=6 ? selProj.substring(0,2) : "")+"' and a.i_project='"+(selProj.length()>=6 ? selProj.substring(3,6) : "")+"' ")
					  .append(condition)
		              .append(" group by a.i_docno,a.i_lock,c.n_project,a.i_type_cutlck , d.n_desc,e.i_house ")
		              .append(" order by a.i_docno,a.i_lock ");             
				servlog.startLog(sql.toString());
		        rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
		        for (int i=0;i<maxRow;i++) { 

                      if (rs.next()) {
                         if (i>=startRow && i<endRow) {
                            //------ Data is in this page , display -----//
				            String iDocNo = doString.checkString(rs.getString("i_docno"),"");
				            String iLock = doString.checkString(rs.getString("i_lock"),"");
				            String nProject = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
				            String iHouse = doString.checkString(rs.getString("i_house"),"");
				            String cutType = doString.checkString(doString.DisplayThai(rs.getString("n_desc")),"");
				            			          
						          
						          
						     //-----============================ Print Header =================================----//     
						     %>
					            <table border="0" width="100%" cellspacing="0" cellpadding="0">
					              <tr>
					                <td class="item_tab1">&nbsp;</td>
					                <td class="item_tab2" width="50"><%=iLock%></td>
					                <td class="item_tab3"></td>
					                <td class="textgray"><%=nProject%>&nbsp;&nbsp;
					                  เลขที่ใบแจ้งซ่อม :
					                  <a href="SERV_OpenJob_Pay_Disp.jsp?i_docno=<%=iDocNo%>&popup=y&edit=no" target="_blank"><%=iDocNo%></a>&nbsp;
					                  บ้านเลขที่ : <%=iHouse%> &nbsp; <%=cutType%></td>                
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
								          <td class="col_nameS" rowspan="2" width="52%">รายการซ่อม</td>
								          <td rowspan="2" class="col_nameS">ตัดเงิน</td>
								          <td colspan="3" class="col_nameS">ค่าแรง</td>
								          <td colspan="3" class="col_nameS">ค่าของ</td>
								          <td rowspan="2" class="col_nameS" width="7%">ค่าแรง<br>
								            + ค่าของ</td>
								          <td rowspan="2" class="col_nameS" width="7%">รวมค่าดำเนิน<br>
								            การ</td>
								        </tr>
								        <tr>
								          <td class="col_nameLow" width="3%">จำนวน</td>
								          <td class="col_nameLow" width="7%">ต่อหน่วย</td>
								          <td class="col_nameLow" width="7%">รวม</td>
								          <td class="col_nameLow" width="3%">จำนวน</td>
								          <td class="col_nameLow" width="7%">ต่อหน่วย</td>
								          <td class="col_nameLow" width="7%">รวม</td>
								        </tr>						     
						     <%
						     //-----==========================================================================----//   						          
						          
						          
						          
						          
						          
						          
							//----=========================== Get Payment Details ===============================----//
							int itmLine = 0;
						    //double sumQWage = 0.00;
						    //double sumQGoods = 0.00;
						    double sumSumWage = 0.00;
						    double sumSumGoods = 0.00;
						    double sumSumTotal = 0.00;
						    double sumCutVendor = 0.00;

							sql.delete(0,sql.length());
							sql.append(" select d.bus_name,c.n_itmjob,b.* from lan:serv_payment b ")
							      .append(" left join lan:serv_boq c on c.i_itmjob=b.i_itmjob ")
							      .append(" left join lan:stpvendr d on d.vend_code=b.i_ven_cut ")
							      .append(" where b.i_docno='").append(iDocNo).append("' ")
								  .append(" and b.i_docno[1,2]='"+(iDocNo.length()>=6 ? iDocNo.substring(0,2) : "")+"' ")
								  .append(" and b.i_docno[4,6]='"+(iDocNo.length()>=6 ? iDocNo.substring(3,6) : "")+"' ")
							      .append(" and b.f_itmstatus='CLS'   ");
							servlog.startLog(sql.toString());
							rs1 = stmt1.executeQuery(sql.toString());
							servlog.endLog();
							while (rs1.next()) {
							    itmLine++;							    
							    String nItmJob = doString.checkString(rs1.getString("n_itmjob"),"");
							    String fContr = doString.checkString(rs1.getString("f_contr"),"N");
							    double qWage = rs1.getDouble("q_wage_unit");
							    double zWage = rs1.getDouble("z_wage_price");
							    double qGoods = rs1.getDouble("q_good_unit");
							    double zGoods = rs1.getDouble("z_good_price");
							    double sumWage = qWage * (double) zWage;
							    double sumGoods = qGoods * (double) zGoods;
							    double sumTotal = rs1.getDouble("z_amount_pay");
							    double cutVendor = rs1.getDouble("z_amount_pv");
								double pAddPay = rs1.getDouble("p_add_pay");
							    
						        //sumQWage += qWage;
						        //sumQGoods += qGoods;
						        sumSumWage += sumWage;
						        sumSumGoods += sumGoods;
						        sumSumTotal += sumTotal;
						        sumCutVendor += cutVendor;
							    
							    
							    //----============= Check Remark for Cut Vendor =====================---//
							    String iVenCut = doString.checkString(rs1.getString("i_ven_cut"),"");
							    double pCut = rs1.getDouble("p_cut");
							    String remark = "";
							    if ((!iVenCut.equals("999999")) || (iVenCut.equals("999999") && pCut>0)) {
							        double cutPv = rs1.getDouble("z_cut_pv");
							        //amountCut = amountCut * (pCut/(double) 100);
							        remark = "หมายเหตุ : ตัดเงินผู้รับเหมา ";
							        remark += doString.DisplayThai(doString.checkString(rs1.getString("bus_name"),""));
							        remark += " "+format.format(pCut)+"% เป็นเงิน "+format.format(cutPv)+" บาท ";
							    }
							    							    
 
							 //-----============================= Print Body =====================================----// 
					        %>
							        <tr>
							          <td class="dotline" width="52%" valign="top"><%=itmLine%>. <%=doString.DisplayThai(nItmJob)%> (<%=str.displayNumber("##0.0",pAddPay)%> %)</td>
							          <td class="dotline" align="center" width="3%" valign="top"><%=fContr%></td>
							          <td class="dotline" align="right" width="3%" valign="top"><%=format.format(zWage)%></td>
							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(qWage)%></td>
							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(sumWage)%></td>
							          <td class="dotline" align="right" width="3%" valign="top"><%=format.format(zGoods)%></td>
							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(qGoods)%></td>
							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(sumGoods)%></td>
							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(sumTotal)%></td>
							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(cutVendor)%></td>
							        </tr>
							  <%
							  
							  if (remark.length()>0) {
								  %>      
								        <tr>
								          <td class="dotline" style="padding-left:20px" width="52%" valign="top"><img border="0" src="images/bu_nextPage.gif" align="absmiddle" width="5" height="7">&nbsp;
								            <font color="#FF6699"><%=remark%></font></td>
								          <td class="dotline" align="right" width="3%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="3%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="3%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
								        </tr>
							     <%							  
							  }
							  

                              //-----==========================================================================----//   
							}
							rs1.close();

							 %> 
							        <tr>
							          <td class="solidline ; item" colspan="2" align="center">รวม</td>
							          <td class="solidline ; item" align="right" width="3%">&nbsp;</td>
							          <td class="solidline ; item" align="right" width="7%">&nbsp;</td>
							          <td class="solidline ; item" align="right" width="7%"><%=format.format(sumSumWage)%>&nbsp;</td>
							          <td class="solidline ; item" align="right" width="3%">&nbsp;</td>
							          <td class="solidline ; item" align="right" width="7%">&nbsp;</td>
							          <td class="solidline ; item" align="right" width="7%"><%=format.format(sumSumGoods)%></td>
							          <td class="solidline ; item" align="right" width="7%"><%=format.format(sumSumTotal)%></td>
							          <td class="solidline ; item" align="right" width="7%"><%=format.format(sumCutVendor)%></td>
							        </tr>
							  <% 
							        
							        
						     //-----============================ Print Header =================================----//     							        
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
							
							<span id="show_comment_<%=iDocNo+":"+iVendor%>"></span>
				
							<br style="font-size:10pt">		        			        
   			        
					        <%
					        //-----==========================================================================----//   		
					        
					        
					        					        
					        
 					        line++;                         
                         } // end if check row
                         
                         if (i>endRow) break;                         
                      } //end if check rs
                } // end for
                
          
                //-------================== If no data , print blank table ========================------//
                if (line==0) {
                   %>
					            <table border="0" width="100%" cellspacing="0" cellpadding="0">
					              <tr>
					                <td class="item_tab1">&nbsp;</td>
					                <td class="item_tab2" width="50">&nbsp;</td>
					                <td class="item_tab3"></td>
					                <td class="textgray">&nbsp;</td>                
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
								          <td class="col_nameS" rowspan="2" width="52%">รายการซ่อม</td>
								          <td colspan="3" class="col_nameS">ค่าแรง</td>
								          <td colspan="3" class="col_nameS">ค่าของ</td>
								          <td rowspan="2" class="col_nameS" width="7%">ค่าแรง<br>
								            + ค่าของ</td>
								          <td rowspan="2" class="col_nameS" width="7%">รวมค่าดำเนิน<br>
								            การ 17%</td>
								        </tr>
								        <tr>
								          <td class="col_nameLow" width="3%">จำนวน</td>
								          <td class="col_nameLow" width="7%">ต่อหน่วย</td>
								          <td class="col_nameLow" width="7%">รวม</td>
								          <td class="col_nameLow" width="3%">จำนวน</td>
								          <td class="col_nameLow" width="7%">ต่อหน่วย</td>
								          <td class="col_nameLow" width="7%">รวม</td>
								        </tr>	
								        <%
								        for (int l=0;l<5;l++) {
								        %>
								        <tr>
								          <td class="dotline" width="52%" valign="top"><input type="hidden" name="i_itmjob" value="">&nbsp;</td>
								          <td class="dotline" align="right" width="3%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="3%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
								        </tr>		
								        <%
								        } // end for
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
                   <%
                }
        %>        
        	      

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
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_Pass_List.jsp?i_company=<%=selProj.length()>=2 ? selProj.substring(0,2) : ""%>&d_payment=<%=dPayment%>" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
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
		System.out.println("ERROR SERV_Pass_Full.jsp : " + e.getMessage());
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