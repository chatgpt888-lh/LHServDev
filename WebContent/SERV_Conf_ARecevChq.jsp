<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.text.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%//@ page import="serv.util.ServLog" %>

<%//@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>


<%
/*String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_Conf_ARecevChq.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);*/

   doString str = new doString();
   DecimalFormat format = new DecimalFormat("#,##0.00");
	User user = null;
	if (session != null) {
		user = (User)session.getAttribute("USER");
	}


   //----============ Declare Variables for input data ===========----//
   String iCompany = doString.checkString(request.getParameter("i_company"),"").toUpperCase();
   String iProject = doString.checkString(request.getParameter("i_project"),"").toUpperCase();
   String actionFlag = doString.checkString(request.getParameter("action_flag"),"").toUpperCase();
   String selType = doString.checkString(request.getParameter("sel_type"),"A").toUpperCase();
   String funcType = doString.checkString(request.getParameter("func_type"),"C").toUpperCase();
   String pvAcct = doString.checkString(request.getParameter("pv_acct"),"");   
   String iEmploy = "";
   String condition = "";

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
        //----=======================================----//


		//---============== get I-Employ from session or parameter =================---//
		if (user!=null) {
			iEmploy =  user.getEmpId();
		} else {
			iEmploy = doString.checkString(request.getParameter("i_employ"),"");
		}

		if ( user == null && iEmploy.trim().length()==0) {
			response.sendRedirect(Constants.WARNING_PAGE+"?url="+request.getRequestURI());
		}	


        //---====================== Generate Search Condition ===========================---//
        String startDate = common.getValueFromDateListbox("start",request);

	if (iCompany.length()>0) {
	   condition += " and a.i_company='"+iCompany+"' ";
	}
	//if (iProject.length()>0) {
	   condition += " and a.i_project='"+iProject+"' ";
	//}
	if (startDate.length()>0) {
	   //condition += " and a.d_est_chq between '"+startDate+"' and '"+startDate+"' ";
	   condition += " and a.d_est_chq <= '"+startDate+"' ";
	}
	//---=========================================================================----//


	//--- 2022-06-30 , find default request date from payin table ---//
	Calendar pay = null;
	boolean noPayInTable = false;
	
    sql.delete(0,sql.length());
    sql.append(" select d_payin from lan:acxruled ")
       .append(" where i_type='70' and d_approve >= today ")
       .append(" order by d_approve ");
    rs = stmt.executeQuery(sql.toString());
    if (rs.next()) {
    	Timestamp tmp = rs.getTimestamp("d_payin");
	    if (tmp!=null) {
	    	pay = Calendar.getInstance(Locale.ENGLISH);
	    	pay.setTime(tmp);
	    	noPayInTable = false;
	    } else {
	    	noPayInTable = true;
	    }
    } else {
    	noPayInTable = true;
    } 
    rs.close();	

%>


<HTML>
<HEAD>
<TITLE>Confirm
รายการขอคืนเงินค้ำประกัน</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--

  function refreshPage() {
     document.forms[0].action_flag.value="R";
     document.forms[0].submit();
  }

  function searchReten() {
     if (!validDate()) {
        return false;
     }

     document.forms[0].action_flag.value="S";
	 document.forms[0].action = "SERV_Conf_ARecevChq.jsp";
     document.forms[0].submit();
  }

  function validDate() {
     var sdate = document.forms[0].start_date.value;
     var smonth = document.forms[0].start_month.value;
     var syear = document.forms[0].start_year.value;

     //---- Check select date ---//
     if (sdate.length==0 && smonth.length==0 && syear.length==0) {
         return true;
     }

     var startDate = new Date(parseInt(syear,10),parseInt(smonth,10)-1,parseInt(sdate,10));

     if (startDate.getMonth()!=(parseInt(smonth,10)-1)) {
        alert("วันที่ ที่เลือกไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
        document.forms[0].start_date.focus();
        return false;
     }

     return true;
  }


  var printId = new Array();
  function confirmReten() {
      var chk = document.forms[0].conf_id;
	  var idList = "";
	  var cnt = 0;

       if (chk!=null) {
          if (chk.length!=null) {
			  for (var i=0;i<chk.length;i++) {
					try {
						if (chk[i].checked) {
						    cnt++;

						    //---- check receive cheque date ----//
						    //var pay = document.forms[0].elements("d_payto"+chk[i].value); // 2023-02-22 , edit for chrome
						    var pay = document.getElementById("dPayTo"+chk[i].value);
							if (pay!=null) {
								if (!convertDateFormat(pay)) {
									 return false; 
								}
							}

							//---- check print ----//
							if (printId[i]!=null && printId[i].length>0) {
								idList += "    "+(i+1)+". "+printId[i]+"\n";
							}
						} // end if check chk[i].checked
					} catch (e) {}
			  }
		  } else {
				if (chk.checked) {
						cnt++;

					    //---- check receive cheque date ----//
					    //var pay = document.forms[0].elements("d_payto"+chk.value); // 2023-02-22 , edit for chrome
					    var pay = document.getElementById("dPayTo"+chk.value);
						if (pay!=null) {
							if (!convertDateFormat(pay)) {
								 return false; 
							}
						}

						//---- check print ----//
						if (printId[0]!=null && printId[0].length>0) {
							idList += "    1. "+printId[0]+"\n";
						}
				} // end if check chk[i].checked
		  } 
      }


	  if (idList.length>0) {
		  alert("เอกสารที่คุณเลือก ยังไม่ได้ทำการพิมพ์ ดังต่อไปนี้ \n"+idList);
		  return false;
	  }

	if (cnt<=0) {
		alert(" กรุณาเลือกรายการที่จะทำการ Confirm !!");
		return false;
	}
	
	
   if (document.forms[0].pv_acct.value=="") {
	   alert("กรุณาเลือกเลขที่บัญชี PV !!");
	   return false;
   }
	  	

     if (confirm("คุณแน่ใจว่าต้องการ Confirm รายการที่เลือกนี้  ?")) {	
        document.forms[0].action="<%=Constants.APP_PATH%>/SERV_ManageChequeServlet";
        document.forms[0].action_flag.value="A";
        document.forms[0].submit();
     }
  }


  function clearCheckbox() {
      var chk = document.forms[0].conf_id;
       if (chk!=null) {
          if (chk.length!=null) {
	      for (var i=0;i<chk.length;i++) {
	            chk[i].checked = false;
	      }
	  } else {
	     chk.checked = false;
	  }
       }
  }

  function PrintAccRetReten(line,docNo,funcType) {
 	 document.forms[0].target="_blank";
 	 document.forms[0].action="<%=Constants.APP_PATH%>/SERV_PrintAccRetenServlet?i_docno="+docNo+"&func_type="+funcType;
	 document.forms[0].submit();
 	 document.forms[0].target="";
	 printId[line] = "";
  }


	function convertDateFormat(dateObj) {
	   if (dateObj==null) return false;

		var countSlash = 0;
	    for (var i=0;i<dateObj.value.length;i++) {
		       if (dateObj.value.charAt(i)=='/') countSlash++;
		} // end for

		if (countSlash!=2) {
		    alert("รูปแบบวันที่ไม่ถูกต้อง!");
		    dateObj.focus();
		    return false;
		}

	    var splitDate = dateObj.value.split("/"); 
		var day = 0;
		var month = 0;
		var year = 0;

		try {
		    day = parseInt(splitDate[0],10);
		    month = parseInt(splitDate[1],10);
		    year = parseInt(splitDate[2],10);
		} catch (e) {
		   alert("วันที่ไม่ถูกต้อง!");
		   dateObj.focus();
		   return false;
		}

		if (day>=1 && day<=31) {
		    if (month>=1 && month<=12) {

		    if (isNaN(year) || (year>=100 && year<=999)) {
		        alert("กรุณาใส่ปีเป็นรูปแบบ yy หรือ yyyy เท่านั้น!");
			dateObj.focus();
			return false;
		      }

			   //----- Convert to BC. -------//	
			   if (year<45) year += 2543;
			   if (year>=45 && year<100) year += 2500;
			   if (year<2400) year += 543;

			    var dateStr = (day<10 ? "0"+day : day)+"/"+(month<10 ? "0"+month : month)+"/"+year;
	                    dateObj.value = dateStr;

				if (!checkFormatDate(dateStr)) {
				    dateObj.focus();
				    return false;
				}

			} else {
			   alert("เดือนต้องมีค่าระหว่าง 1 - 12 เท่านั้น!");
			   dateObj.focus();
			   return false;
			}
		} else {
		   alert("วันที่ต้องมีค่าระหว่าง 1 - 31 เท่านั้น!");
		   dateObj.focus();
		   return false;
		}

		return true;
	}
  
	function checkFormatDate(str)
	{
		mystring = str;
		if (mystring.match(/(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.]([1-9])\d\d\d/ ) ) { 
		   var yyyy = parseInt(str.substring(6,10),10);
		   var mm = parseInt(str.substring(3,5),10)-1;
		   var dd = parseInt(str.substring(0,2),10);
		   if (yyyy>2400) yyyy -= 543;
	
	       var cdate = new Date(yyyy,mm,dd);
		   if (mm!=cdate.getMonth()) {
		      alert("วันที่ไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
		      return false;
		   }
		} else {
			alert("รูปแบบวันที่ไม่ถูกต้อง !");
			return false;
		}
		
		return true;
	}  

//-->
</script>


<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM ACTION="SERV_Conf_ARecevChq.jsp" METHOD="POST">

<input type="hidden" name="action_flag" value="">
<input type="hidden" name="i_employ" value="<%=iEmploy%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ใบวางเงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">



            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">Confirm
                  รายการขอคืนเงินค้ำประกัน</td>
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
    <td class="item ; dotline01" height="22" width="12%">ระบุบริษัท
      :</td>
    <td height="22" width="43%" class="dotline01">
    <select size="1" class="box" style="width:250px" name="i_company" onchange="refreshPage();">
    <option value="">----- กรุณาเลือก -----</option>
   <%
        sql.delete(0,sql.length());
        sql.append(" select * from lan:acxcompa order by i_company ");
		//servlog.startLog(sql.toString());
        rs = stmt.executeQuery(sql.toString());
		//servlog.endLog();
        while (rs.next()) {
            String comId = doString.checkString(rs.getString("i_company"),"").toUpperCase();
            String nCompany = doString.checkString(doString.DisplayThai(rs.getString("n_company")),"");
	    String selected = "";
	    if (iCompany.equalsIgnoreCase(comId)) {
	        selected = " selected ";
	    }
	    %><option value="<%=comId%>" <%=selected%>><%=comId+" - "+nCompany%></option><%
        }
        rs.close();
   %>
    </select>
     </td>
    <td height="22" class="item ; dotline01" width="15%"><nobr>วันที่คาดว่าจะรับเช็ค / PayIn</nobr>
      :</td>
    <td height="22" width="30%" class="dotline01">
    <%=common.genDateListbox("start",request," class='box' ")%>
     </td>
  </tr>
  <tr>
    <td class="dotline01" >&nbsp;</td>
    <td height="22" width="30%" class="dotline01">
	    <input type="radio" name="sel_type" value="A" <%=selType.equalsIgnoreCase("A") ? " checked" : "" %> onclick="refreshPage();">ทุกโครงการตามสาย &nbsp; 
	    <input type="radio" name="sel_type" value="E" <%=selType.equalsIgnoreCase("E") ? " checked" : "" %> onclick="refreshPage();">เฉพาะโครงการที่ดูแล &nbsp; 
	</td>
    <td height="22" class="item ; dotline01" width="15%"> รูปแบบ : &nbsp; </td>
    <td height="22" width="30%" class="dotline01">
	<select name="func_type" class="box" style="width:100px">
		<option value="C" <%=funcType.equals("C") ? " selected " : "" %>>Confirm</option>
		<option value="P" <%=funcType.equals("P") ? " selected " : "" %>>Reprint</option>
	</select>
	</td>	
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="12%">โครงการ :</td>
    <td height="22" width="43%" class="dotline01">
    <select size="1" class="box" style="width:250px" name="i_project" onchange="refreshPage();">
    <option value="">----- กรุณาเลือก -----</option>
   <%
   		String selected = "";
   
        sql.delete(0,sql.length());
	    if (selType.equalsIgnoreCase("A")) {
			sql.append(" select unique a.i_company,a.i_project,b.n_project from docflow:icv_acpr a ")
				  .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
				  .append(" where a.i_com_emp='LH' and a.i_employ in ")
				  .append(" ( select i_employ from docflow:icv_acln where i_leader in ")
				  .append("     ( select i_leader from docflow:icv_acln where i_com_emp='LH' and i_employ='").append(iEmploy).append("' ) ")
				  .append(" ) and a.i_project is not null and a.i_company='").append(iCompany).append("' ");
		} else {
			sql.append(" select unique a.i_company,a.i_project,b.n_project from docflow:icv_acpr a ")
				  .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
				  .append(" where a.i_com_emp='LH' and a.i_employ='").append(iEmploy).append("' ")
				  .append(" and a.i_project is not null and a.i_company='").append(iCompany).append("' ");
		}

/*
        sql.delete(0,sql.length());
        sql.append("select * from acxprojt a,docflow:icv_acpr b ")
	      .append(" where a.i_company='").append(iCompany).append("' and a.i_company=b.i_company ")
	      .append(" and a.i_project=b.i_project and b.i_ap_typ='GRP' and b.i_com_emp='LH' ")
	      .append("  order by a.i_company , a.i_project ");
*/
		//servlog.startLog(sql.toString());
        rs = stmt.executeQuery(sql.toString());
		//servlog.endLog();
        while (rs.next()) {
            String comId = doString.checkString(rs.getString("i_company"),"").toUpperCase();
            String projId = doString.checkString(rs.getString("i_project"),"");
            String nCompany = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
		    selected = "";
		    if ((iCompany+iProject).equalsIgnoreCase(comId+projId)) {
		        selected = " selected ";
		    }
	    %><option value="<%=projId%>" <%=selected%>><%=comId+"-"+projId+" - "+nCompany%></option><%
        }
        rs.close();
   %>
    </select>
    	&nbsp; <img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22" style="cursor:hand;" onclick="searchReten();">
    </td>
    <td height="22" class="item ; dotline01" colspan="2">&nbsp; </td>
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


<br style="font-size:5pt">


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
          <td width="5%" class="col_name">Confirm</td>
          <td width="22%" class="col_name">โครงการ</td>
          <td width="5%" class="col_name">แปลง</td>
          <td width="12%" class="col_name">เลขที่ใบวางเงิน</td>
          <td width="10%" class="col_name">ประเภทการคืนเงิน</td>
          <td width="17%" class="col_name">ผู้รับเงินตามเช็ค / PayIn</td>
          <td width="12%" class="col_name">จำนวนเงินคืน</td>
          <td width="12%" class="col_name">วันที่คาดว่าจะรับเช็ค / PayIn</td>
          <td width="12%" class="col_name">วันที่รับเช็คจริง / PayIn</td>
          <td width="5%" class="col_name">Print</td>
        </tr>
	<%
        //----====================== Get SERV_RETHD Data  ===========================-----//
		int countLine = 0;
        String projectName = "";
        String iDocNo = "";
        String nPayType = "";
        String iSort = "";
        String comId = "";
        String projId = "";
        String iReten = "";
	    String retCustType = "";
	    double zPayback = 0.0;	  
	    boolean canEditDate = false;  
	    int cntPayTo = 0; // 2022-11-07
	    int cntPayIn = 0; // 2022-11-07

		String reqDate = "";
		Calendar est = null;			
	
        sql.delete(0,sql.length());
        sql.append(" select b.i_company||b.i_project||' - '||b.n_project as project_name, a.* from lan:serv_rethd a ")
	      .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
	      .append(" where ");
		if (funcType.equalsIgnoreCase("C")) {
			sql.append(" a.i_doc_status='V' and a.i_pvno is null  ");
		} else {
			sql.append(" a.i_doc_status='A' ");
		}
	    sql.append(condition);
		//servlog.startLog(sql.toString());
        rs = stmt.executeQuery(sql.toString());
		//servlog.endLog();
        while (rs.next()) {
	     countLine++;
         projectName = doString.checkString(doString.DisplayThai(rs.getString("project_name")),"");
         iDocNo = doString.checkString(rs.getString("i_docno"),"");
         iSort = doString.checkString(rs.getString("i_sort"),"");
         comId = doString.checkString(rs.getString("i_company"),"");
         projId = doString.checkString(rs.getString("i_project"),"");
         iReten = doString.checkString(rs.getString("i_reten"),"");
	     retCustType = doString.checkString(rs.getString("i_ret_custo"),"");
	     zPayback = rs.getDouble("z_payback");

		 reqDate = "";	
	     est = Calendar.getInstance(Locale.ENGLISH);
   	     Timestamp tmp = rs.getTimestamp("d_est_chq");
	     if (tmp!=null) {
			 est.setTime(tmp);
			 reqDate =  getDateFromCalendar(est);
	     } else {
	         reqDate = "";
	     }
	     
	     canEditDate = false;
         nPayType = doString.checkString(rs.getString("i_paytype"),"");
         if (nPayType.equalsIgnoreCase("PAYIN")) {
         	nPayType = "โอนเงิน";
         	canEditDate = false;
         	cntPayIn++; // 2022-11-07
         } else {
         	nPayType = "ทำเช็คคืน";
         	canEditDate = true;
         	cntPayTo++; // 2022-11-07
         }


		//-----========== Get retCustName ============-----//
		String retCustName = "";
		sql.delete(0,sql.length());
		if (retCustType.equals("1")) {
		    sql.append(" select trim(n_prename)||trim(n_ncustomer)||' '||trim(n_scustomer) as cust_name ")
			  .append(" from lan:acxcusto where i_customer='").append(iReten).append("' ");
		} else if (retCustType.equals("2")) {
		    sql.append(" select trim(nvl(n_pname,''))||trim(nvl(n_name,''))||' '||trim(nvl(n_sname,'')) as cust_name ")
			  .append(" from lan:serv_venprj where i_vendor='").append(iReten).append("' ")
			  .append(" and i_company='").append(comId).append("' and i_project='").append(projId).append("' ")
			  .append(" and i_type='05' ");
		} else {
		    sql.append(" select trim(nvl(n_pname,''))||trim(nvl(n_name,''))||' '||trim(nvl(n_sname,'')) as cust_name ")
			  .append(" from lan:serv_venprj where i_vendor='").append(iReten).append("' ")
			  .append(" and i_company='").append(comId).append("' and i_project='").append(projId).append("' ")
			  .append(" and i_type='06' ");
		}
		//servlog.startLog(sql.toString());
		rs1 = stmt1.executeQuery(sql.toString());
		//servlog.endLog();
		if (rs1.next()) {
		    retCustName = doString.checkString(rs1.getString("cust_name"),"");
		}
		rs1.close();

	   //--- 2022-06-30 , change default to use date from payin table instead ---//	
	   //Calendar pay = Calendar.getInstance();
	   //pay.add(Calendar.DATE,4);
	   
	   
	   //--- 2022-06-30 , if payment date from payin table has data , check holiday ---//
	   String dPayTo = "";
	   if (pay!=null) {
		   boolean workedDate = false;
	
		   while (!workedDate) {
			     if ((pay.get(Calendar.DAY_OF_WEEK)==Calendar.SATURDAY) || (pay.get(Calendar.DAY_OF_WEEK)==Calendar.SUNDAY)) {
					 workedDate = false;
					 pay.add(Calendar.DATE,1);
				 } else {
					 //------- find holiday --------//
					 int chkYear = est.get(Calendar.YEAR);
					 if (chkYear>2400) chkYear -= 543;
					String dHoliday = chkYear+"-"+(pay.get(Calendar.MONTH)+1)+"-"+pay.get(Calendar.DATE);
					sql.delete(0,sql.length());
					sql.append(" select * from lan:acxholdy where d_holiday='").append(dHoliday).append("' ");
	
					//servlog.startLog(sql.toString());
					rs1 = stmt1.executeQuery(sql.toString());
					//servlog.endLog();
					if (rs1.next()) {
						workedDate = false;
					    pay.add(Calendar.DATE,1);
					} else {
						workedDate = true;
					}
					rs1.close();
				 }
		   } // end while 
		   
		   dPayTo = getDateFromCalendar(pay);
	   }	   


		if (funcType.equalsIgnoreCase("P")) {
			Timestamp time = rs.getTimestamp("d_payto");
			if (time!=null) {
				pay = Calendar.getInstance();
				pay.setTime(time);
				dPayTo = getDateFromCalendar(pay);
			} else {
				dPayTo = "-";
			}
		}		

	     %>
		<tr>
		  <td width="5%" align="center" class="dotline">
		  <%
				if (funcType.equalsIgnoreCase("C")) {
					%> <input type="checkbox" name="conf_id" value="<%=iDocNo%>"><%
				} else {
					%> &nbsp;<%
				}			 
		  %>
		 </td>
		  <td class="dotline"><%=doString.checkString(projectName,"-")%></td>
		  <td class="dotline" align="center"><%=doString.checkString(iSort,"-")%></td>
		  <td align="center" class="dotline"><%=doString.checkString(iDocNo,"-")%></td>
		  <td align="center" class="dotline"><%=doString.checkString(nPayType,"-")%></td>
		  <td class="dotline ; item"><%=doString.DisplayThai(doString.checkString(retCustName,"-"))%></td>
		  <td align="right" class="dotline"><%=format.format(zPayback)%></td>
		  <td align="center" class="dotline"><%=doString.checkString(reqDate,"-")%></td>		  
		  <td align="center" class="dotline">
		  <%
				if (funcType.equalsIgnoreCase("C")) {
					if (canEditDate) {
						%><input type='text' name='d_payto<%=iDocNo%>' id='dPayTo<%=iDocNo%>' value='<%=dPayTo%>' onchange="convertDateFormat(this);" style="width:80px" class="box" ><%
					} else {
						%>
						<input type='text' name='d_payto<%=iDocNo%>' id='dPayTo<%=iDocNo%>' value='<%=dPayTo%>' readonly style="width:80px; background-color:#ECECEC" class="box" >
						<%
					}
				} else {
					%> <%=dPayTo%> <%
				}			 
		  %>
		  
		  
		  </td>		  
		  <td width="5%" align="center" class="dotline"><a href="#"><img border="0" src="images/i_printPDF.gif" align="absmiddle"
		  onmouseout=nereidFade(this,70,50,5) onmouseover=nereidFade(this,100,50,5) style="FILTER: alpha(opacity=70)"
		  onClick="PrintAccRetReten(<%=countLine-1%>,'<%=iDocNo%>','<%=funcType%>');"></a></td>
		  <!--
		  <td width="5%" align="center" class="dotline"><a href="#"><img border="0" src="images/bu_view.gif" align="absmiddle"
		  onmouseout=nereidFade(this,70,50,5) onmouseover=nereidFade(this,100,50,5) style="FILTER: alpha(opacity=70)"
		  onClick="MM_openBrWindow('SERV_View_RetDoc.jsp?i_docno=<%=iDocNo%>','blank','width=650,height=280,left=140,top=80')" width="30" height="12"></a></td>-->
		</tr>
		<script>printId[<%=countLine-1%>] = "<%=iDocNo%>"; </script>
	     <%
        }
        rs.close();
        //---=========================================================================----//


	for (int l=countLine;l<10;l++) {
	      %>
		<tr>
		  <td align="center" class="dotline">&nbsp;</td>
		  <td class="dotline">&nbsp;</td>
		  <td class="dotline" align="center">&nbsp;</td>
		  <td align="center" class="dotline">&nbsp;</td>
		  <td align="center" class="dotline">&nbsp;</td>
		  <td class="dotline ; item">&nbsp;</td>
		  <td align="right" class="dotline">&nbsp;</td>
		  <td align="center" class="dotline">&nbsp;</td>
		  <td align="center" class="dotline">&nbsp;</td>
		  <td align="center" class="dotline">&nbsp;</td>
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



<!--======================= 2014-07-07 , Account List box ================================-->
<br style="font-size:5pt">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop">&nbsp;</td>
    <td width="5" valign="top" align="right"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR">
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
		<tr>
		    <td height="22" width="99" class="item ; dotline01" align="left"> 
			<nobr>  เลือกบัญชี PV : &nbsp; 
			<select name="pv_acct" class="box" style="width:430px">
		    <option value="">----- กรุณาเลือก -----</option>			
			<%
				String projProv = "";
				
				String pvBank = "";				
				String pvBran = "";
				String pvAccType = "";		
				String pvAccount = "";								
				String pvVal = "";
				int cntPvAcct = 0;
				
				//---- 2022-11-07 , for payin account ----//
				String payInBank = "";
				String payInBran = "";
				String payInAccType = "";
				String payInAccount = "";
				String payInVal = "";
				int cntPayInAcct = 0;
				//---------------------------------------//
				
				
				if (iCompany.length()>0 && iProject.length()>0) {
			        //----- find project province -----//				        
			        sql.delete(0,sql.length());
			        sql.append("select i_prov from lan:pay_prjprov ")
				      .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ");
			        rs = stmt.executeQuery(sql.toString());
			        if (rs.next()) {
			            projProv = doString.checkString(rs.getString("i_prov"),"");
			        } else {
			        	//--- if no data in pay_prjprov , default BKK ---//
			        	projProv = "BKK";
			        } // end if
			        rs.close();		
			        
			        //----- find pv account -----//
			        sql.delete(0,sql.length());
			        sql.append(" select distinct i_pv_bank,i_pv_bran,i_pv_acctyp,i_pv_acct, ")
			           .append(" i_payin_bnk, i_payin_brn, i_payin_actyp, i_payin_acct ")
			           .append(" from docflow:icv_acctn ")
				       .append(" where i_com_exp='"+iCompany+"' and i_system='RET' ");				       
					if (projProv.equalsIgnoreCase("BKK")) {
						sql.append(" and length(nvl(i_province,''))=0 "); // if BKK , no province code
					} else {
						sql.append(" and i_province='"+projProv+"' ");
					}						      
			        rs = stmt.executeQuery(sql.toString());
			        while (rs.next()) {
						pvBank = doString.checkString(rs.getString("i_pv_bank"),"");
						pvBran = doString.checkString(rs.getString("i_pv_bran"),"");
						pvAccType = doString.checkString(rs.getString("i_pv_acctyp"),"");
						pvAccount = doString.checkString(rs.getString("i_pv_acct"),"");
						pvVal = pvBank+"-"+pvBran+"-"+pvAccType+"-"+pvAccount;
						if (pvVal.length()>3) {
							cntPvAcct++;
						}
						
						//--- 2022-11-07 , get payin account ---//
						payInBank = doString.checkString(rs.getString("i_payin_bnk"),"");
						payInBran = doString.checkString(rs.getString("i_payin_brn"),"");
						payInAccType = doString.checkString(rs.getString("i_payin_actyp"),"");						
						payInAccount = doString.checkString(rs.getString("i_payin_acct"),"");
						payInVal = payInBank+"-"+payInBran+"-"+payInAccType+"-"+payInAccount;
							
						if (payInVal.length()>3) {
							cntPayInAcct++;
						}
						
					    selected = "";
					    if (pvAcct.equalsIgnoreCase(pvVal+"#"+payInVal)) {
					        selected = " selected ";
					    }
					            
			            %>
			            <option value="<%=pvVal+"#"+payInVal %>" <%=selected%>>
			                        บัญชีสำหรับทำเช็คคืน : <%=pvVal.length()>3 ? "<span style='color:red'>"+pvVal+"</span>" : "ไม่พบเลขบัญชี" %> &nbsp; | &nbsp;   
			                        บัญชีสำหรับโอนเงิน : <%=payInVal.length()>3 ? payInVal : "ไม่พบเลขบัญชี" %>
			            </option><%
			        } // end while
			        rs.close();	
			        
				} // end if check project
      
			%>
			</select></nobr>
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
<!--======================================================================================-->



<br style="font-size:10pt">



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="150" class="act_tab2">
			<%			
				boolean chkPVAndPvAcct = false;
				if (cntPayTo<=0 || (cntPayTo>0 && cntPvAcct>0)) {
					//--- no payto data or found payto data and found payto account ---//
					chkPVAndPvAcct = true;
				}
				
				boolean chkPayInAndPayInAcct = false;
				if (cntPayIn<=0 || (cntPayIn>0 && cntPayInAcct>0)) {
					//--- no payin data or found payin data and found payin account ---//
					chkPayInAndPayInAcct = true;
				}
				
				if (!noPayInTable && chkPVAndPvAcct && chkPayInAndPayInAcct) {
					%>
			           <img border="0" src="images/act_saveandclose.gif" onclick="confirmReten();"
			    			onmouseout=nereidFade(this,70,50,5)
			                  	onmouseover=nereidFade(this,100,50,5)
			                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">&nbsp;
			            <img border="0" src="images/act_clear.gif" onclick="clearCheckbox();"
			    			onmouseout=nereidFade(this,70,50,5)
			                  	onmouseover=nereidFade(this,100,50,5)
			                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">					
					<%
				}
			%>
			&nbsp;
            </td>


            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="javascript:history.back();"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=Constants.APP_PATH%>/SERV_RetenHome.jsp" target="_self"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
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

<%
	if (noPayInTable) {
		//--- alert error and disable save button ---//
		%><script>alert("ยังไม่มีการตั้งตารางทำจ่าย, กรุณาตรวจสอบ  !!");</script><%
	}
	
	if (!chkPVAndPvAcct && !chkPayInAndPayInAcct) {
		%><script>alert("ไม่พบข้อมูลบัญชีสำหรับทำเช็คคืนและโอนเงิน , กรุณาตรวจสอบ  !!");</script><%		
	} else if (!chkPVAndPvAcct && chkPayInAndPayInAcct) {
		%><script>alert("ไม่พบข้อมูลบัญชีสำหรับทำเช็คคืน , กรุณาตรวจสอบ  !!");</script><%		
	} else if (chkPVAndPvAcct && !chkPayInAndPayInAcct) {
		%><script>alert("ไม่พบข้อมูลบัญชีสำหรับโอนเงิน , กรุณาตรวจสอบ  !!");</script><%		
	}
%>

</BODY>

</HTML>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_Conf_ARecevChq.jsp : " + e.getMessage());
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
