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

<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%
String userId = user.getUserID();

   doString str = new doString();


   //----============ Declare Variables for input data ===========----//
   String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase();
   if  (selProj.length()==0) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       session.setAttribute("sess_sel_proj",selProj);
   }


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



   String iVendor = doString.checkString(request.getParameter("i_vendor"),"").toUpperCase();
	String itmType = doString.checkString(request.getParameter("itmType"));
	String itmType_restrict = "";
	if (!itmType.equals("")) {
		itmType_restrict = " AND b.i_itmtype = '"+itmType+"'";
	}
   String condition = "";
   
   //---========= If Permission is denied , View Mode Only ===============----//
   boolean permission = false;
   if (SERV_CommonData.checkPermissionOnPage(Constants.PERMISSION_MANAGER,user.getUserWho())) {
       permission = true;
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
        
        
        //----====================== Get Vendor Name ==============================-----//
        String vendorName = "";
		sql.delete(0,sql.length());
		sql.append(" select bus_name from lan:stpvendr where vend_code='").append(iVendor).append("' ");
	    rs = stmt.executeQuery(sql.toString());
	    while (rs.next()) {
	        vendorName = doString.checkString(doString.DisplayThai(rs.getString("bus_name")),"");
	    }
	    rs.close();        
	   //---=========================================================================----//   
	           

        //---====================== Generate Serrch Condition ===========================---//
        if (selProj.trim().length()>=6 && !selProj.equalsIgnoreCase("ALL")) {
           //condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
		   condition = " and a.i_company='"+(selProj.substring(0,2))+"' and a.i_project='"+(selProj.substring(3,6))+"' ";
        }
        condition += " and b.d_payment='"+dPay+"' ";      		
 	   //---=========================================================================----//   

        
        //----====================== Get DOCHD Max Row ==============================-----//
        int maxRow = 0;
		sql.delete(0,sql.length());
		sql.append(" select count(*) from serv_infpayment b,serv_infdochd a where b.f_itmstatus='600' and a.f_status='OPN' ")
		     .append(" and b.i_vendor='").append(iVendor).append("' ")
		     .append(" and b.i_docno=a.i_docno ").append(condition)
		     .append(" group by b.i_docno ");
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
	   	   
	   if (displayLine<Constants.SERV_MANAGERCONF_LINE) displayLine = Constants.SERV_MANAGERCONF_LINE;      
	   
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

  var tmpComment = new Array(); 

  function searchDocHD() {
     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_CONManager_Conf.jsp";
     document.forms[0].submit();  
  }

  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_CONManager_Conf.jsp";
     document.forms[0].submit();
  }
  
  function showComment(obj) {
     var show = document.getElementById("show_comment_"+obj.value);
     if (show!=null) {
		//---======= Update HTML ========---//
        if (trim(tmpComment[obj.value])!=(show.innerHTML) && trim(show.innerHTML).length>0) {
           tmpComment[obj.value]=trim(show.innerHTML);
        }
	
		if (obj.checked) {
		      var html = trim(tmpComment[obj.value]);

		      if (html==null || html.length==0) {
		          var id = obj.value.split(":"); 
		          html   = '<br style="font-size:10px">';
		          html += '<table border="0" width="100%" cellspacing="0" cellpadding="0">';
		          html += '<tr><td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>';
		          html += '<td class="item_tab2" width="160">หมายเหตุ</td><td class="item_tab3"></td><td class="textgray">&nbsp; ';
		          html += ' สำหรับใบเบิกงวดเลขที่ '+id[0]+' </td></tr></table>';
		          html += '<table border="0" width="100%" cellspacing="0" cellpadding="0">';
		          html += '<tr><td width="5" valign="top"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>';
		          html += '<td class="frmTop">&nbsp;</td><td width="5" valign="top" align="right">';
		          html += '<img border="0" src="images/Corn02.gif" width="5" height="5"></td></tr></table>';
		          html += '<table border="0" width="100%" cellspacing="0" cellpadding="0"><tr><td width="100%" class="frmLRpad01" valign="top">';
		          html += '<textarea name="'+obj.value+'_comment" rows="4" class="box" style="width:100%;" cols="20"></textarea>';
		          html += '</td></tr></table>';
		          html += '<table border="0" width="100%" cellspacing="0" cellpadding="0">';
		          html += '<tr><td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>';
		          html += '<td class="frmBottom">&nbsp;</td><td width="5" valign="bottom" align="right">';
		          html += '<img border="0" src="images/Corn04.gif" width="5" height="5"></td>';
		          html += '</tr></table><br style="font-size:20px">';
		          tmpComment[obj.value]=html;
		      }
		      
		      show.innerHTML = html;
        } else {
             tmpComment[obj.value] = show.innerHTML;
             show.innerHTML = "";
        }
     }
  }
  
  
  function checkTickItem() {
       var sub = document.forms[0].elements["i_itmjob"];
       var checked = false;
	    if (sub.length!=null) {
			for (var i=0;i<sub.length;i++) {
			      if (sub[i].checked) {
			         checked = true;
			         break;
			      }
			} // end for
		} else {
           checked = sub.checked
		} 
		
		return checked;
  }
  
  function approve_job() {
     if (!checkTickItem()) {
         alert("กรุณาเลือกรายการที่ต้องการ Approve อย่างน้อย 1 รายการ !");
         return false;
     }
     
     document.forms[0].mode.value="APPROVE";          
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_CONManagerConfServlet";
     document.forms[0].submit();
  }  
  
  function trim(str) {
     if (str==null) return null;
  
      while (str.charAt(0)==" " && str.length>0) {
          str = str.substring(1);
      }
      while (str.lastIndexOf(" ")==(str.length-1) && str.length>0) {
         str = str.substring(0,str.length-1);
      }
      
      return str;
  }
  
  
  function reject_job() {
      if (!checkTickItem()) {
         alert("กรุณาเลือกรายการที่ต้องการ Reject อย่างน้อย 1 รายการ !");
         return false;
      }

      if (confirm("คุณแน่ใจว่าต้องการ Reject ใบงานที่เลือกนี้ ?")) {
           var sub = document.forms[0].elements["i_itmjob"];
		    if (sub.length!=null) {
				for (var i=0;i<sub.length;i++) {
					  var comment = document.forms[0].elements(sub[i].value+"_comment");
					  if (comment!=null && trim(comment.value)=="") {
				         alert(" กรุณากรอกหมายเหตุ เกี่ยวกับการ Reject !");
				         comment.focus();
				         return false;					     
					  }
				} // end for
			} else {
				  var comment = document.forms[0].elements(sub.value+"_comment");
				  if (comment!=null && trim(comment.value)=="") {
			         alert(" กรุณากรอกหมายเหตุ เกี่ยวกับการ Reject !");
			         comment.focus();
			         return false;					     
				  }
			}          

          document.forms[0].mode.value="REJECT";          
          document.forms[0].action="<%=Constants.APP_PATH%>/SERV_CONManagerConfServlet";
          document.forms[0].submit();
      }
  }  

  function  checkAll(obj,mainCheck,subCheck) {
     var main = document.forms[0].elements[mainCheck];
     var sub = document.forms[0].elements[subCheck];
     
     if (obj!=null && main!=null && sub!=null) {
     
         if (obj.name==mainCheck) {
		    if (sub.length!=null) {
				for (var i=0;i<sub.length;i++) {
					  sub[i].checked = obj.checked;
					  showComment(sub[i]);
				}
			} else {
			   sub.checked = obj.checked;
			   showComment(sub);
			}
         } else {
		    if (sub.length!=null) {
			    var flag = true;
				for (var i=0;i<sub.length;i++) {
					  flag = sub[i].checked;
					  if (!flag) break;
				}
				main.checked = flag;
			} else {
			   main.checked = obj.checked;
			} // end if check sub
			
	        showComment(obj);
         } // end if check mainCheck

     } // end if check null
          
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
	<input type='hidden' name='i_vendor' value='<%=iVendor%>'>
	<input type='hidden' name='sel_project' value='<%=selProj%>'>	
	<input type="hidden" name="mode" value="">    
<input type="hidden" name="itmType" value="<%=itmType%>">
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            Service Manager - ผู้จัดการโครงการ</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>
 

<br style="font-size:10pt">
                


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="45%" style="font-size: 16pt; color: rgb(255,100,0); letter-spacing: 3px; padding: 5px">
           <%
             if (permission) {
                %><input type="checkbox" name="main_check" onclick="checkAll(this,'main_check','i_itmjob');"><%
             }
           %>
           <%=vendorName%></td>
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
				//----==================== Get Markup Pay from SERV_XSTD  ====================-----//
				String markupPay = "";
				double pAddPay = 0.0;		     //----================== Select Data from SERV_DOCHD ================----//   
		        int line = 0;
		        String oldiDocNo = "";

				String iDocNo = "";
				String nJob = "";
				String nProject = "";
				String iHouse = "";
				String cutType = "";
				int itmLine = 0;				int dueNo = 0;
				double sumSumWage = 0.00;				double sumSumGoods = 0.00;				double sumSumTotal = 0.00;				double sumCutVendor = 0.00;				String nItmJob = "";
				String fContr = "";
				double qWage = 0.0;
				double zWage = 0.0;
				double qGoods = 0.0;
				double zGoods = 0.0;
				double sumWage = 0.0;
				double sumGoods = 0.0;
				double sumTotal = 0.0;
				double cutVendor = 0.0;
				String iVenCut = "";
				double pCut = 0.0;
				String remark = "";

		        
		        sql.delete(0,sql.length());
		        sql.append(" select first ").append(endRow).append(" a.i_docno,c.n_project ")
		              .append(" from lan:serv_infpayment b, lan:serv_infdochd a ")
		              .append(" left join acxprojt c on c.i_company=a.i_company ")
  		              .append(" and c.i_project=a.i_project where")
		              .append(" a.f_status='OPN' and b.i_docno=a.i_docno ")
		              .append(" and b.f_itmstatus='600' ")
		              .append(" and b.i_vendor='").append(iVendor).append("' ")
					   .append(condition)
					.append(itmType_restrict)
		              .append(" group by a.i_docno,c.n_project ")
		              .append(" order by a.i_docno "); 
		        rs = stmt.executeQuery(sql.toString());
		        for (int i=0;i<maxRow;i++) { 
                      if (rs.next()) {
                         if (i>=startRow && i<=endRow) {
                            //------ Data is in this page , display -----//
				            iDocNo = doString.checkString(rs.getString("i_docno"),"");				            nProject = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");				            nJob = "";				            rs1 = stmt1.executeQuery("SELECT b.n_itmjob FROM lan:serv_infpayment p, lan:serv_infboq b WHERE p.i_docno = '"+iDocNo+"' AND p.i_itmjob = b.i_itmjob");				            if (rs1 != null) {				            	if (rs1.next() == true) {				            		nJob = doString.checkString(doString.DisplayThai(rs1.getString("n_itmjob")));				            						            	}				            	rs1.close();				            	rs1=null;				            }						     //-----============================ Print Header =================================----//     
						     %>
					            <table border="0" width="100%" cellspacing="0" cellpadding="0">
					              <tr>
					                <td class="item_tab1">
							           <% 
							             if (permission) {
							                %><input type="checkbox" name="i_itmjob" value="<%=iDocNo+":"+iVendor%>" onclick="checkAll(this,'main_check','i_itmjob');"><%
							             }
							           %>					                					                
					                </td>
					                <td class="item_tab2" width="100"><%=iDocNo%></td>
					                <td class="item_tab3"></td>
					                <td class="textgray"><%=nProject%>&nbsp;&nbsp;
					                  เลขที่ใบเบิกงวด :
					                  <a href="SERV_ConOpenJob_Pay_Disp.jsp?i_docno=<%=iDocNo%>&popup=y&edit=no" target="_blank"><%=iDocNo%></a></td>                
					              </tr>
					            </table>
	
								<table border="0" width="100%" cellspacing="0" cellpadding="0">
								  <tr>
								    <td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
								    <td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
								    <td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
								  </tr>								</table>								<table border="0" width="100%" cellspacing="0" cellpadding="0">								  <tr>								    <td width="100%" class="frmL">								      <table border="0" width="100%" cellspacing="0" cellpadding="0">								        <tr>								          <td class="col_nameS" rowspan="2" width="48%"><%=nJob%></td>								          <td rowspan="2" class="col_nameS">งวดที่</td>								          <td colspan="3"  class="col_nameS">ค่าแรง</td>								          <td colspan="3"  class="col_nameS">ค่าของ</td>								          <td rowspan="2" class="col_nameS" width="7%">ค่าแรง<br>+ ค่าของ</td>								          <td rowspan="2" class="col_nameS" width="7%">รวมค่า<br>ดำเนินการ</td>								        </tr>								        <tr>								          <td class="col_nameLow" width="3%">จำนวน</td>								          <td class="col_nameLow" width="7%">ต่อหน่วย</td>								          <td class="col_nameLow" width="7%">รวม</td>								          								          <td class="col_nameLow" width="3%">จำนวน</td>								          <td class="col_nameLow" width="7%">ต่อหน่วย</td>								          <td class="col_nameLow" width="7%">รวม</td>								        </tr>						     						     <%						     //-----==========================================================================----//   						          							//----=========================== Get Payment Details ===============================----//							itmLine = 0;						    dueNo = 0;						    sumSumWage = 0.00;
						    sumSumGoods = 0.00;
						    sumSumTotal = 0.00;
						    sumCutVendor = 0.00;

							nItmJob = "";
							fContr = "";
							qWage = 0.0;
							zWage = 0.0;
							qGoods = 0.0;
							zGoods = 0.0;
							sumWage = 0.0;
							sumGoods = 0.0;
							sumTotal = 0.0;
							cutVendor = 0.0;
							iVenCut = "";
							pCut = 0.0;
							remark = "";
							
							sql.delete(0,sql.length());
							sql.append(" select d.bus_name,c.n_itmjob,b.* from lan:serv_infpayment b ")
							      .append(" left join lan:serv_infboq c on c.i_itmjob=b.i_itmjob ")
							      .append(" left join lan:stpvendr d on d.vend_code=b.i_ven_cut ")
							      .append(" where b.i_docno='").append(iDocNo).append("' ")
							      .append(" and b.i_vendor='").append(iVendor).append("' ")
							      .append(" and b.f_itmstatus='600' order by b.s_due");
							rs1 = stmt1.executeQuery(sql.toString());
							while (rs1.next()) {
							    itmLine++;							    dueNo = rs1.getInt("s_due");
							    nItmJob = doString.checkString(doString.DisplayThai(rs1.getString("c_itmjob")),"");
							    qWage = rs1.getDouble("q_wage_unit");
							    zWage = rs1.getDouble("z_wage_price");
							    qGoods = rs1.getDouble("q_good_unit");
							    zGoods = rs1.getDouble("z_good_price");
							    sumWage = qWage * (double) zWage;
							    sumGoods = qGoods * (double) zGoods;
							    sumTotal = rs1.getDouble("z_amount_pay");
							    cutVendor = rs1.getDouble("z_amount_pv");
							    
						        //sumQWage += qWage;
						        //sumQGoods += qGoods;
						        sumSumWage += sumWage;
						        sumSumGoods += sumGoods;
						        sumSumTotal += sumTotal;
						        sumCutVendor += cutVendor;
							    
							    
							    //----============= Check Remark for Cut Vendor =====================---//
							    iVenCut = doString.checkString(rs1.getString("i_ven_cut"),"");
							    pCut = rs1.getDouble("p_cut");
							    remark = "";
							    if ((!iVenCut.equals("999999")) || (iVenCut.equals("999999") && pCut>0)) {
							        double cutPv = rs1.getDouble("z_cut_pv");
							        remark = "หมายเหตุ : ตัดเงินผู้รับเหมา ";
							        remark += doString.checkString(doString.DisplayThai(rs1.getString("bus_name")),"");
							        remark += " "+format.format(pCut)+"% เป็นเงิน "+format.format(cutPv)+" บาท ";							    }							 //-----============================= Print Body =====================================----// 					        %>							        <tr>							          <td class="dotline" width="48%" valign="top"><%=nItmJob%></td>							          <td class="dotline" align="center" width="4%" valign="top"><%=dueNo%></td>							          							          <td class="dotline" align="right" width="3%" valign="top"><%=format.format(qWage)%></td>							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(zWage)%></td>							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(sumWage)%></td>							          							          <td class="dotline" align="right" width="3%" valign="top"><%=format.format(qGoods)%></td>							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(zGoods)%></td>							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(sumGoods)%></td>							          							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(sumTotal)%></td>							          <td class="dotline" align="right" width="7%" valign="top"><%=format.format(cutVendor)%></td>							        </tr>							  <%							  if (remark.length()>0) {								  %>      								        <tr>								          <td class="dotline" style="padding-left:20px" width="48%" valign="top"><img border="0" src="images/bu_nextPage.gif" align="absmiddle" width="5" height="7">&nbsp;								            <font color="#FF6699"><%=remark%></font></td>								            <td class="dotline" align="right" width="4%" valign="top">&nbsp;</td>								          <td class="dotline" align="right" width="3%" valign="top">&nbsp;</td>								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>								          								          <td class="dotline" align="right" width="3%" valign="top">&nbsp;</td>								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>								          								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>								        </tr>							     <%							  
							  }                              //-----==========================================================================----//   							}							rs1.close();							 %> 							        <tr>							          <td class="solidline ; item" colspan="2" align="center">รวม</td>							          							          <td class="dotline" align="right" width="3%">&nbsp;</td>							          <td class="solidline ; item" align="right" width="7%">&nbsp;</td>							          <td class="solidline ; item" align="right" width="7%"><%=format.format(sumSumWage)%>&nbsp;</td>							          							          <td class="solidline ; item" align="right" width="3%">&nbsp;</td>							          <td class="solidline ; item" align="right" width="7%">&nbsp;</td>							          <td class="solidline ; item" align="right" width="7%"><%=format.format(sumSumGoods)%></td>							          							          <td class="solidline ; item" align="right" width="7%"><%=format.format(sumSumTotal)%></td>							          <td class="solidline ; item" align="right" width="7%"><%=format.format(sumCutVendor)%></td>							        </tr>							  <% 						     //-----============================ Print Header =================================----//     							        							 %>							      </table>							    </td>							  </tr>							</table>							<table border="0" width="100%" cellspacing="0" cellpadding="0">							  <tr>							    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>							    <td class="frmBottom">&nbsp;</td>							    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>							  </tr>					  							</table>							<span id="show_comment_<%=iDocNo+":"+iVendor%>"></span>							<br style="font-size:10pt">		        			        					        <%
					        //-----==========================================================================----//   		 					        line++;                                                  } // end if check row                         if (i>endRow) break;                                               } //end if check rs                } // end for                //-------================== If no data , print blank table ========================------//                if (line==0) {                   %>
					            <table border="0" width="100%" cellspacing="0" cellpadding="0">					              <tr>					                <td class="item_tab1">&nbsp;</td>					                <td class="item_tab2" width="50">&nbsp;</td>					                <td class="item_tab3"></td>					                <td class="textgray">&nbsp;</td>                					              </tr>					            </table>								<table border="0" width="100%" cellspacing="0" cellpadding="0">								  <tr>								    <td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>								    <td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>								    <td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>								  </tr>								</table>								<table border="0" width="100%" cellspacing="0" cellpadding="0">								  <tr>								    <td width="100%" class="frmL">								      <table border="0" width="100%" cellspacing="0" cellpadding="0">								        <tr>								          <td class="col_nameS" rowspan="2" width="48%">รายละเอียดงาน</td>								          <td rowspan="2" class="col_nameS">งวดที่</td>								          <td colspan="3" class="col_nameS">ค่าแรง</td>								          <td colspan="3" class="col_nameS">ค่าของ</td>								          <td rowspan="2" class="col_nameS" width="7%">ค่าแรง<br>+ ค่าของ</td>								          <td rowspan="2" class="col_nameS" width="7%">รวมค่า<br>ดำเนินการ</td>								        </tr>
								        <tr>								          <td class="col_nameLow" width="3%">จำนวน</td>								          <td class="col_nameLow" width="7%">ต่อหน่วย</td>								          <td class="col_nameLow" width="7%">รวม</td>
								          <td class="col_nameLow" width="3%">จำนวน</td>								          <td class="col_nameLow" width="7%">ต่อหน่วย</td>								          <td class="col_nameLow" width="7%">รวม</td>
								        </tr>									        <%								        for (int l=0;l<5;l++) {								        %>								        <tr>
								          <td class="dotline" width="48%" valign="top"><input type="hidden" name="i_itmjob" value="">&nbsp;</td>								          <td class="dotline" align="right" width="4%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="3%" valign="top">&nbsp;</td>								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="3%" valign="top">&nbsp;</td>								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>								          <td class="dotline" align="right" width="7%" valign="top">&nbsp;</td>
								        </tr>		
								        <%
								        } // end for
								        %>
							      </table>							    </td>							  </tr>							</table>							<table border="0" width="100%" cellspacing="0" cellpadding="0">							  <tr>							    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>							    <td class="frmBottom">&nbsp;</td>							    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>							  </tr>					  							</table>							<br style="font-size:10pt">									        						                           <%                }        %>        <br style="font-size:3pt">      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr class="gray">
          <td width="100%" align="right"><%=pageLink%></td>
        </tr>
      </table>


<br style="font-size:10pt">



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="240" class="act_tab2">

	           <%
	             if (permission) {
	                %>
			            <img border="0" src="images/act_approve.gif"   
			                onclick="approve_job();"                                
			    			   onmouseout=nereidFade(this,70,50,5)    
			                      onmouseover=nereidFade(this,100,50,5)     
			                  	     style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">&nbsp; 
			             <img border="0" src="images/act_reject.gif"  
			                 onclick="reject_job();";                                 
			    			    onmouseout=nereidFade(this,70,50,5)    
			                  	   onmouseover=nereidFade(this,100,50,5)     
			                  	      style="FILTER: alpha(opacity=70) ; cursor:hand" width="70" height="27">&nbsp; 					<%
	             }
	           %>	

            </td>                     	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_CONManager_List.jsp?itmType=<%=itmType%>" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
<input type='hidden' name='i_docno' value='<%=iDocNo%>'>
</FORM>	
	
</BODY>

</HTML>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_CONManager_Conf.jsp : " + e.getMessage());
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