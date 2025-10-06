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
String jName = "SERV_Zone_Conf.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

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

    String iVendor = doString.checkString(request.getParameter("i_vendor"),"");
    if (user.getUserWho().equalsIgnoreCase(Constants.PERMISSION_VENDOR)) {
       iVendor = user.getEmpId();
    }
    
    
    //---============= For Main Comment =============---//
    String mainComment = doString.checkString(request.getParameter("main_comment"),"");
    mainComment = str.replace(mainComment,"|break|","<br>");
	mainComment = str.replace(mainComment," ","&nbsp;"); 	

    
    
    //---========== If this user is service staff or more permission , use this link , else use display link =============----//
    boolean permission = false;
    if (SERV_CommonData.checkPermissionOnPage(Constants.PERMISSION_ZONE,user.getUserWho())) {
        permission = true;
    }


    String selProj = doString.checkString(request.getParameter("sel_project"),"");
    if  (selProj.length()==0) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
    } else {
       session.setAttribute("sess_sel_proj",selProj);
    }
    String docNo = doString.checkString(request.getParameter("i_docno"),"").toUpperCase();
    String houseId = doString.checkString(request.getParameter("i_house"),"").toUpperCase();
    String lock = doString.checkString(request.getParameter("i_lock"),"").toUpperCase();
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
        if (user.getUserWho().equalsIgnoreCase(Constants.PERMISSION_VENDOR)) {
           condition += " and b.i_vendor='"+user.getEmpId()+"' ";
        }
        if (selProj.trim().length()>=6 && !selProj.equalsIgnoreCase("ALL")) {
           //condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
		   condition = " and a.i_company='"+(selProj.substring(0,2))+"' and a.i_project='"+(selProj.substring(3,6))+"' ";
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



		//----==================== Get Markup Pay from SERV_XSTD  ====================-----//
		String markupPay = "";
		if (selProj.trim().length()>0 && iVendor.trim().length()>0) {
			 sql.delete(0,sql.length());
			 sql.append(" select * from lan:serv_venprj where ")
				   .append(" i_company='").append(selProj.length()>=6 ? selProj.substring(0,2) : "").append("' ")
				   .append(" and i_project='").append(selProj.length()>=6 ? selProj.substring(3,6) : "").append("' ")
				   .append(" and i_vendor='").append(iVendor).append("' ");
			 servlog.startLog(sql.toString());
			 rs = stmt.executeQuery(sql.toString());
			 servlog.endLog();
			 if (rs.next()) {
				double pAddPay = rs.getDouble("p_add_pay");
				markupPay = doString.displayNumber("##0.0",pAddPay)+" %";
			 }				        
			 rs.close();	
		}
	   //---=========================================================================----//      
	   

       Double sumCutVendor[] =  newDoubleArray(vendorCut.size());
	 
%>

<HTML>
<HEAD>
<TITLE>Manager - ผู้จัดการกลุ่ม</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>



<script language="javascript">
<!--

  var tmpComment = new Array(); 

  function searchDocHD() {
     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Zone_Conf.jsp";
     document.forms[0].submit();  
  }

  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Zone_Conf.jsp";
     document.forms[0].submit();
  }
  
  function showComment() {
     var show = document.getElementById("show_comment");
     var sub = document.forms[0].elements("i_itmjob");
     var checkbox = new Array();
     if (sub.length!=null) {
        checkbox = sub;        
     } else {
        checkbox[0] = sub;
     }
     
     if (show!=null) {
		var mainHtml = "";

		for (var loop=0;loop<checkbox.length;loop++) {
				var obj = checkbox[loop];
				
				var comment = document.forms[0].elements(obj.value+"_comment");
				if (comment!=null) tmpComment[obj.value]=trim(comment.value);

				if (obj.checked) {
				      var value = trim(tmpComment[obj.value]);
				      if (value==null) value="";
		
			          var id = obj.value.split(":"); 
			          html   = '<br style="font-size:10px">';
			          html += '<table border="0" width="100%" cellspacing="0" cellpadding="0">';
			          html += '<tr><td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>';
			          html += '<td class="item_tab2" width="160">หมายเหตุ</td><td class="item_tab3"></td><td class="textgray">&nbsp; ';
			          html += ' สำหรับใบแจ้งซ่อมแลขที่ '+id[0]+' </td></tr></table>';
			          html += '<table border="0" width="100%" cellspacing="0" cellpadding="0">';
			          html += '<tr><td width="5" valign="top"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>';
			          html += '<td class="frmTop">&nbsp;</td><td width="5" valign="top" align="right">';
			          html += '<img border="0" src="images/Corn02.gif" width="5" height="5"></td></tr></table>';
			          html += '<table border="0" width="100%" cellspacing="0" cellpadding="0"><tr><td width="100%" class="frmLRpad01" valign="top">';
			          html += '<textarea name="'+obj.value+'_comment" rows="4" class="box" style="width:100%;" cols="20">'+value+'</textarea>';
			          html += '</td></tr></table>';
			          html += '<table border="0" width="100%" cellspacing="0" cellpadding="0">';
			          html += '<tr><td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>';
			          html += '<td class="frmBottom">&nbsp;</td><td width="5" valign="bottom" align="right">';
			          html += '<img border="0" src="images/Corn04.gif" width="5" height="5"></td>';
			          html += '</tr></table><br style="font-size:20px">';
				      
				      mainHtml += html;

		        }
        
        } // end for
      

        show.innerHTML = mainHtml;
        
        
     } // end if check null
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
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_ZoneConfServlet";
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
           /*-----==================== use for multiple comment ====================-----//           
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
         //-----==================== use for multiple comment ====================-----*/     
			
			
         if (trim(document.forms[0].main_comment.value)=="") {
	         alert(" กรุณากรอกหมายเหตุ เกี่ยวกับการ Reject !");
	         document.forms[0].main_comment.focus();
	         return false;         
         }			

          document.forms[0].mode.value="REJECT";          
          document.forms[0].action="<%=Constants.APP_PATH%>/SERV_ZoneConfServlet";
          document.forms[0].submit();
      }
  }  


  function routeback_job() {
      if (!checkTickItem()) {
         alert("กรุณาเลือกรายการที่ต้องการ RouteBack อย่างน้อย 1 รายการ !");
         return false;
      }

      if (confirm("คุณแน่ใจว่าต้องการ RouteBack ใบงานที่เลือกนี้ ?")) {
           /*-----==================== use for multiple comment ====================-----//           
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
         //-----==================== use for multiple comment ====================-----*/     
			
			
         if (trim(document.forms[0].main_comment.value)=="") {
	         alert(" กรุณากรอกหมายเหตุ เกี่ยวกับการ RouteBack !");
	         document.forms[0].main_comment.focus();
	         return false;         
         }			

          document.forms[0].mode.value="ROUTEBACK";          
          document.forms[0].action="<%=Constants.APP_PATH%>/SERV_ZoneConfServlet";
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
				}
			} else {
			   sub.checked = obj.checked;
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
			
         } // end if check mainCheck
         

     } // end if check null


    //---=========== For multiple comment ========---//
    //showComment();
          
  }    

  
//-->
</script>



<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">

<input type="hidden" name="d_payment" value="<%=dPayment%>">
<input type='hidden' name='i_vendor' value='<%=iVendor%>'>
<input type="hidden" name="mode" value="">
<input type="hidden" name="success_page" value="SERV_Zone_Conf.jsp?d_payment=<%=dPayment%>&i_vendor=<%=iVendor%>">
<input type="hidden" name="error_page" value="SERV_Zone_Conf.jsp?error=1&d_payment=<%=dPayment%>&i_vendor=<%=iVendor%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            Manager : ผู้จัดการกลุ่ม</td>
          <td width="50%" align="right">
          <table border="0" width="140" cellspacing="0" cellpadding="0">
              <tr>
                <td width="100%" class="TextMenu"><a href="SERV_Zone_Conf_Full.jsp?i_vendor=<%=iVendor%>"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="15" height="15">
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
                <td class="item_tab2" width="160">รายการซ่อม</td>
                <td class="item_tab3"></td>
                <td class="textgray">&nbsp;<%=vendorName%></td>
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
          <td class="col_name" width="2%" rowspan="2">
           <%
             if (permission) {
                %><input type="checkbox" name="main_check" onclick="checkAll(this,'main_check','i_itmjob');"><%
             } else {
                %>&nbsp;<% 
             }
           %>  
          </td>
          <td class="col_name" width="15%" rowspan="2">เลขที่ใบแจ้งซ่อม</td>
          <td class="col_name" width="9%" rowspan="2">แปลง</td>
          <td class="col_name" width="9%" rowspan="2">บ้านเลขที่</td>
          <td class="col_name" width="13%" rowspan="2">ค่าแรง</td>
          <td class="col_name" width="13%" rowspan="2">ค่าของ</td>
          <td class="col_name" width="13%" rowspan="2">ค่าของ+ค่าแรง</td>
          <td class="col_name" width="13%" rowspan="2">รวมค่า ดำเนินการ <%=markupPay%></td>
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
        
                
            //add by pradoem 2024.01.22
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
        
		     //----================== Select Data from SERV_DOCHD ================----//   
		        int line = 0;		     
		        sql.delete(0,sql.length());
		        sql.append(" select b.i_docno,sum(q_wage_unit * z_wage_price) sum_wage, ")
		              .append(" sum(q_good_unit * z_good_price) sum_goods, ")
		              .append(" sum(z_amount_pay) sum_amount_pay, sum(z_amount_pv) sum_amount_pv, ")
		              .append(" sum(z_amount_cut) sum_amount_cut from serv_dochd a,serv_payment b ")
		              .append(" where b.i_docno=a.i_docno and a.f_status='OPN' and b.f_itmstatus='700' ")
		              .append(" and b.i_vendor='").append(iVendor).append("' ")
					  .append(condition)
					  .append(sqlB.toString())
		              .append(" group by b.i_docno ")
					  .append(" order by b.i_docno ");
                      
				servlog.startLog(sql.toString());
		        rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
		        while (rs.next()) {
  
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
							sql.append(" select p_cut,sum(z_cut_pv) sum_cut_pv from serv_dochd a,serv_payment b ")
							      .append(" where b.i_docno=a.i_docno and a.f_status='OPN' and b.f_itmstatus='700' ")
							      .append(" and b.i_vendor='").append(iVendor).append("' and b.i_ven_cut<>'999999' ")
							      .append(" and b.i_docno='").append(iDocNo).append("' ")
							      .append(sqlB.toString())
							      .append(" group by p_cut ");
							servlog.startLog(sql.toString());
							//out.println(sql.toString());
							rs1 = stmt1.executeQuery(sql.toString());
							servlog.endLog();
							while (rs1.next()) {
							    double pCut = rs1.getDouble("p_cut");
							    double cutValue = rs1.getDouble("sum_cut_pv");

							    for (int c=0;c<vendorCut.size();c++) {
							          Double cut = (Double)  vendorCut.elementAt(c);
								  if (cut.doubleValue()==pCut) {
								      cutVendor[c] = new Double(cutValue);
								      sumCutVendor[c] = new Double(sumCutVendor[c].doubleValue()+cutValue);
								      break;
								  }
							    }
							}
							rs1.close();


					        %>
					        <tr>
					          <td align="center" class="dotline" width="2%">
					           <%
					             if (permission) {
					                %><input type="checkbox" name="i_itmjob" value="<%=iDocNo+":"+iVendor%>" onclick="checkAll(this,'main_check','i_itmjob');"><%
					             } else {
					                %>&nbsp;<%
					             }
					           %>						          
					          </td>
					          <td class="dotline" width="15%" align="center"><%=iDocNo%></td>
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

                } // end while
                
	           while (line<Constants.SERV_ZONECONF_LINE) {
	               line++;
	                %>
			        <tr>
			          <td align="center" class="dotline" width="2%">&nbsp;</td>
			          <td class="dotline" width="15%" align="center">&nbsp;</td>
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
          <td align="center" class="dotline ; item" colspan="4">รวมเป็นเงิน</td>
          <td align="right" class="dotline ; item" width="13%"><%=format.format(totalWage)%></td>
          <td align="right" class="dotline ; item" width="13%"><%=format.format(totalGoods)%></td>
          <td align="right" class="dotline ; item" width="13%"><%=format.format(totalPay)%></td>
          <td align="right" class="dotline ; item" width="13%"><%=format.format(totalPV)%></td>
	    <%
	     for (int c=0;c<vendorCut.size();c++) {
		  %><td width="6%" class="dotline ; item" align="right"><%=format.format(sumCutVendor[c].doubleValue())%></td><%
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

<span id="show_comment"></span>

<!---=========== Main Comment for use in every item =================---->
			<br style="font-size:10pt">
			
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="160">หมายเหตุ</td>
                <td class="item_tab3"></td>
                <td class="textgray">&nbsp; </td>                
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
			    <td width="100%" class="frmLRpad01" valign="top">
			    <textarea rows="5" name="main_comment" class="box" style="width:100%" cols="20"><%=mainComment%></textarea>
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
<!---=========== Main Comment for use in every item =================---->

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
			                  	      style="FILTER: alpha(opacity=70) ; cursor:hand" width="70" height="27">&nbsp; 
			             <img border="0" src="images/act_routeback.gif"  
			                 onclick="routeback_job();";                                 
			    			    onmouseout=nereidFade(this,70,50,5)    
			                  	   onmouseover=nereidFade(this,100,50,5)     
			                  	      style="FILTER: alpha(opacity=70) ; cursor:hand" width="70" height="27">						      
					<%
	             }
	           %>	
            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_Zone_List.jsp" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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

<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_Zone_List.jsp : " + e.getMessage());
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