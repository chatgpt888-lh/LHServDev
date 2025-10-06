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
	doString str = new doString();	String user_group = doString.checkString(user.getUserGroup());	String team_condition = "";	if (!user_group.equals("A")) {		team_condition = " AND a.i_team = '"+user_group+"' ";	}

    //----============ Declare Variables for input data ===========----//
    String iCompany = doString.checkString(request.getParameter("i_company"),"");
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
    
    
    //---============= For Main Comment =============---//
    String mainComment = doString.checkString(request.getParameter("main_comment"),"");
    mainComment = str.replace(mainComment,"|break|","<br>");
	mainComment = str.replace(mainComment," ","&nbsp;"); 	
    
    
    
    //---========== If this user is service staff or more permission , use this link , else use display link =============----//
    boolean permission = false;
    if (SERV_CommonData.checkPermissionOnPage(Constants.PERMISSION_VP,user.getUserWho())) {  //PERMISSION_ZONE
        permission = true;
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
	int TotalDoc = 0;
	double TotalcutValue = 0.0;

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
		/*
        if (selProj.trim().length()>0 && !selProj.equalsIgnoreCase("ALL")) {
           condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
        }    
		if (selProj.trim().length()<=0) {
		   String projList = common.getProjectListByUserId(user.getUserID());
		   if (projList.length()>0) {
		       condition += " and substr(a.i_docno,1,6) in ("+projList+") ";
		   } else {

			sql.delete(0,sql.length());
			sql.append(" select count(*) from serv_pstaff  where user_id='").append(user.getUserID()).append("' and proj_id='ALL' ");
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
		*/
        if (user.getUserWho().equalsIgnoreCase(Constants.PERMISSION_VENDOR)) {
           condition += " and b.i_vendor='"+user.getEmpId()+"' ";
        }
        condition += " and b.d_payment='"+dPay+"' ";       
        condition += " and substr(b.i_docno,1,2)='"+iCompany+"' ";    
 	   //---=========================================================================----//   




        //----==================== Get Vendor Percent cut from SERV_XSTD  ====================-----//
        Vector vendorCut = new Vector();
        sql.delete(0,sql.length());
        sql.append(" select * from lan:serv_xstd where i_type='09' ");
		
        rs = stmt.executeQuery(sql.toString());
		while (rs.next()) {
           double percent = rs.getDouble("p_amount");
	   vendorCut.addElement(new Double(percent));
        }
        rs.close();
	//---==============================================================================----//
       Double sumCutVendor[] =  newDoubleArray(vendorCut.size());
%>

<HTML>
<HEAD>
<TITLE>VP - ผู้จัดการฝ่าย</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--

  var tmpComment = new Array(); 

  function searchDocHD() {
     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFVP_List2.jsp";
     document.forms[0].submit();  
  }

  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFVP_List2.jsp";
     document.forms[0].submit();
  }
  
  function showComment() {
     var show = document.getElementById("show_comment");
     var sub = document.forms[0].elements("i_project");
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
				      
				      var vendor = document.forms[0].elements(obj.value+"_name");
				      var vendorName = "";
				      if (vendor!=null) vendorName = vendor.value;
		
			          var id = obj.value.split(":"); 
			          html   = '<br style="font-size:10px">';
			          html += '<table border="0" width="100%" cellspacing="0" cellpadding="0">';
			          html += '<tr><td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>';
			          html += '<td class="item_tab2" width="160">หมายเหตุ</td><td class="item_tab3"></td><td class="textgray">&nbsp; ';
			          html += ' สำหรับผู้รับเหมาซ่อม : '+vendorName+' </td></tr></table>';
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
       var sub = document.forms[0].elements["i_project"];
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
     
     document.forms[0].mode.value="APPROVE_PROJECT";          
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFVPConfServlet";
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
          var sub = document.forms[0].elements["i_project"];
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

          document.forms[0].mode.value="REJECT_PROJECT";          
          document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFVPConfServlet";
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


  //--========= Use for multiple comment =========---//
  //  showComment();
          
  }    

  
//-->
</script>


<base target="_self">


</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">


<input type="hidden" name="d_payment" value="<%=dPayment%>">
<input type="hidden" name="i_company" value="<%=iCompany%>">
<input type="hidden" name="mode" value="">
<input type="hidden" name="success_page" value="SERV_INFVP_List2.jsp?itmType=<%=itmType%>&d_payment=<%=dPayment%>&i_company=<%=iCompany%>">
<input type="hidden" name="error_page" value="SERV_INFVP_List2.jsp?error=1&itmType=<%=itmType%>&d_payment=<%=dPayment%>&i_company=<%=iCompany%>">
<input type="hidden" name="itmType" value="<%=itmType%>">
<input type="hidden" name="queryString" value="<%=request.getQueryString()%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center" class="BD">
    

      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            VP - ผู้จัดการฝ่าย</td>
          <td width="30%" align="right">
          </td>
        </tr>
      </table>


<br style="font-size:10pt">
                





            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดงานแจ้งซ่อม</td>
                <td class="item_tab3"></td>
                <td >&nbsp;วันที่จ่าย&nbsp; <%=dPayment%></td>
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
    <td width="2%" class="col_name" rowspan="2">
    <%
        if (permission) {
            %>&nbsp;<!-- <input type="checkbox" name="main_check" onclick="checkAll(this,'main_check','i_project');"> --><%
        } else {
            %>&nbsp;<%
        }
    %>
   </td>
    <td width="30%" class="col_name" rowspan="2">โครงการ</td>
    <td width="10%" class="col_name" rowspan="2">จำนวนใบแจ้งซ่อม</td>
    <td width="11%" class="col_name" rowspan="2">ค่าแรง</td>
    <td width="11%" class="col_name" rowspan="2">ค่าของ</td>
    <td width="12%" class="col_name" rowspan="2">ค่าแรง+ค่าของ</td>
    <td width="12%" class="col_name" rowspan="2">รวมค่าดำเนินการ <!--<%//=(int) markupPay%>%--></td>
    <td width="12%" class="col_name" colspan="<%=vendorCut.size()%>">ตัดเงินผู้รับเหมา</td>
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
		     //edit by pradoem 2024.01.22
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
			  
		        int line = 0;		     
		        sql.delete(0,sql.length());
		        sql.append(" select distinct d.n_project,d.i_company,d.i_project from lan:serv_infpayment b ")
		              .append(" left join lan:acxprojt d on d.i_company=substr(b.i_docno,1,2) and d.i_project=substr(b.i_docno,4,3) ")
		              .append(" ,lan:serv_infdochd a where b.i_docno=a.i_docno and a.f_status='OPN' and b.f_itmstatus='800' ")					  .append(team_condition)
		              .append(condition)
					.append(itmType_restrict)
		              .append(" order by d.i_company,d.i_project ");  		              
				
		        rs = stmt.executeQuery(sql.toString());
				
                      while (rs.next()) {

                            //------ Data is in this page , display -----//
				            String iProject = doString.checkString(rs.getString("i_project"),"");
				            String proejectName = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");			            
				            
						          
						          
							//----======================= Get Payment Details ===========================----//
							double sumWage = 0.00;
							double sumGoods = 0.00;
							double totalSum = 0.00;
							double calMarkupPay = 0.00;
							Double cutVendor[] = newDoubleArray(vendorCut.size());
							int countDoc = 0;
								

				
							//----====================== Count Job Form ==================----//
							sql.delete(0,sql.length());
							sql.append(" select count(*) from serv_infpayment b,serv_infdochd a where b.f_itmstatus='800' ")
							     .append(" and substr(b.i_docno,1,2)='").append(iCompany).append("' ")
								 .append(" and substr(b.i_docno,4,3)='").append(iProject).append("' ")  // เพิ่มเติม by pay
							     .append(" and b.i_docno=a.i_docno ").append(condition).append(itmType_restrict)
								 .append(" and a.f_status = 'OPN' ")    // เพิ่มเติม by pay								 .append(team_condition)
								 .append(sqlB.toString());
							     //.append(" group by b.i_docno ");
							
						    rs1 = stmt1.executeQuery(sql.toString());
							while (rs1.next()) {
						        countDoc++;
								
						    }
						    rs1.close();
							TotalDoc += countDoc;									
						
							//---============ Find All Summary Except Vendor Cut ==============---//
							sql.delete(0,sql.length());
							sql.append(" select b.i_docno,sum(b.q_wage_unit*b.z_wage_price) sum_wage, ")
							      .append(" sum(b.q_good_unit*b.z_good_price) sum_goods, ")
							      .append(" sum(b.z_amount_pay) sum_amount_pay, ")
							      .append(" sum(b.z_amount_pv) sum_amount_pv ")
							      .append(" from lan:serv_infpayment b , lan:serv_infdochd a ")
							      .append(" where b.i_docno=a.i_docno and b.f_itmstatus='800' ")
							      .append(" and substr(b.i_docno,1,2)='").append(iCompany).append("' ")
								  .append(" and substr(b.i_docno,4,3)='").append(iProject).append("' ")  // เพิ่มเติม by pay								  .append(team_condition)
							      .append(condition)
							      .append(itmType_restrict)
							      .append(sqlB.toString())
							      .append(" group by b.i_docno ");
				      
							rs1 = stmt1.executeQuery(sql.toString());
							while (rs1.next()) {
							    sumWage += rs1.getDouble("sum_wage");
							    sumGoods += rs1.getDouble("sum_goods");							    
							    totalSum += rs1.getDouble("sum_amount_pay");
							    calMarkupPay += rs1.getDouble("sum_amount_pv");
							}
							rs1.close();

							//---====== Calculate Summary ======---//
						    totalSumWage += sumWage;
						    totalSumGoods += sumGoods;
						    sumCalMarkup += calMarkupPay;
						    grandTotal += totalSum;


							//---============ Find Vendor Cut ==============---//
							sql.delete(0,sql.length());
							sql.append(" select p_cut,sum(z_cut_pv) sum_cut_pv ")
							      .append(" from lan:serv_infpayment b , lan:serv_infdochd a ")
							      .append(" where b.i_docno=a.i_docno and b.f_itmstatus='800'  and b.i_ven_cut<>'999999' ")
							      .append(" and substr(b.i_docno,1,2)='").append(iCompany).append("' ")
								  .append(" and substr(b.i_docno,4,3)='").append(iProject).append("' ")  // เพิ่มเติม by pay								  .append(team_condition)
							      .append(condition)
									.append(itmType_restrict)
							       .append(sqlB.toString())
							      .append(" group by b.i_docno,p_cut ");
							//	  out.println("sql="+sql.toString());
							
							rs1 = stmt1.executeQuery(sql.toString());
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
							    } // end for
							}
							rs1.close();
					        %>
							  <tr>
							    <td width="2%" class="dotline" align="center">
							    <%
							        if (permission) {
							            %>
							            <input type="checkbox" name="i_project" value="<%=iCompany+":"+iProject%>" onclick="checkAll(this,'main_check','i_project');">
							            <input type="hidden" name="<%=iCompany%>_name" value="<%=proejectName%>">
							            <%
							        } else {
							            %>&nbsp;<%
							        }
        						%>							    
							    </td>
							    <td width="30%" class="dotline" align="left"><a href="SERV_INFVP_List3.jsp?itmType=<%=itmType%>&sel_project=<%=iCompany+":"+iProject%>&d_payment=<%=dPayment%>"><%=iCompany+"-"+iProject%> <%=proejectName%></a></td>
							    <td width="10%" class="dotline" align="right"><%=countDoc%></td>
							    <td width="11%" class="dotline" align="right"><%=format.format(sumWage)%></td>
							    <td width="11%" class="dotline" align="right"><%=format.format(sumGoods)%></td>
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

                } // end for
                
	           while (line<Constants.SERV_ZONELIST_LINE) {
	               line++;
	                %>				  
					  <tr>
					    <td width="2%" class="dotline" align="center">&nbsp;</td>
					    <td width="30%" class="dotline" align="left">&nbsp;</td>
					    <td width="10%" class="dotline" align="right">&nbsp;</td>
					    <td width="11%" class="dotline" align="right">&nbsp;</td>
					    <td width="11%" class="dotline" align="right">&nbsp;</td>
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
	<td width="12%" class="solidline ; item" align="right"><%=TotalDoc%></td>
    <td width="12%" class="solidline ; item" align="right"><%=format.format(totalSumWage)%></td>
    <td width="12%" class="solidline ; item" align="right"><%=format.format(totalSumGoods)%></td>
    <td width="12%" class="solidline ; item" align="right"><%=format.format(grandTotal)%></td>
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


<span id="show_comment"></span>



<!---=========== Main Comment for use in every item =================---->
<%
  if (permission) {
%>
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
<%
  } // end if check permission

%>

<br style="font-size:10pt">





        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="150" class="act_tab2">
			<%
			  if (permission) {
					%>
			        <img border="0" src="images/act_approve.gif" onclick="approve_job();" 
						onmouseout=nereidFade(this,70,50,5)    
			              	onmouseover=nereidFade(this,100,50,5)     
			              	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">&nbsp;
			        <img border="0" src="images/act_reject.gif" onclick="reject_job();"                                  
						onmouseout=nereidFade(this,70,50,5)    
			              	onmouseover=nereidFade(this,100,50,5)     
			              	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">
					<%
			   } else {
			       %>&nbsp;<%
			   }
			%>
            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_INFVP_List.jsp?itmType=<%=itmType%>&sel_project=<%=selProj%>&d_payment=<%=dPayment%>" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
          	System.out.println("---- SERV_INFVP_List2.jsp ----");
	} catch (Exception e) {
		System.out.println("ERROR SERV_INFVP_List2.jsp : " + e.getMessage());
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