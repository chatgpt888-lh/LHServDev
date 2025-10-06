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
public String[] getEmployeeDetails(Statement stmt1,String iEmploy,ServLog servlog) throws Exception {
     String result[] = new String[] {"","",""};
     ResultSet rs1 = null;
     StringBuffer sql = new StringBuffer();

     try { 
		
	    //----- Find Emp Name -----//
	    sql.delete(0,sql.length());
	    sql.append("select trim(a.n_prename_th)||trim(a.n_nemploy_th)||' '||trim(a.n_semploy_th) as emp_name , ")
	          .append(" b.n_desc position from docflow:acemploy a ")
		  .append(" left join docflow:acempstd b on b.i_type='10' and b.i_code in ")
		  .append(" (select i_job from docflow:acempjob where i_employ=a.i_employ and d_job in ")
		  .append(" (select max(d_job) from docflow:acempjob where i_employ=a.i_employ)) ")
		  .append(" where a.i_employ='").append(iEmploy).append("' ");
		 servlog.startLog(sql.toString());
	     rs1 = stmt1.executeQuery(sql.toString());
		 servlog.endLog();
	     while (rs1.next()) {
		 result[0] = iEmploy;
		 result[1] = doString.checkString(rs1.getString("emp_name"),"");
		 result[2] = doString.checkString(rs1.getString("position"),"");
	     } // end while rs
	     rs1.close();	

    } catch (Exception e) {
       System.out.println("SERV_Add_RetReten.jsp : "+e.getMessage());
    } finally {
       if (rs1!=null) rs1.close();
    }
 
     return result;
}

%>


<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_Add_RetReten.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   doString str = new doString();
   DecimalFormat format = new DecimalFormat("#,##0.00");

   //----============ Declare Variables for input data ===========----//
   String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase();
   if  (selProj.length()==0) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       session.setAttribute("sess_sel_proj",selProj);
   }

   String docNo = doString.checkString(request.getParameter("i_docno"),"").toUpperCase();
   String disabledInput = "";
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


	String projectName = "";
	String iSort = "";
	String iHouse = "";
	String iDocNo = "";
	String iCompany = "";
	String iProject = "";
	String iSignBoard = "";
	String retCustName = "";
	String nCustName = "";
	String guranteeDesc = "";
        String retCustType = "";
        String iReten = "";
	String empName = "";
	String iDocStatus = "";
	String iLor = "";
	String fInSpec = "";
	String iSpec = "";
	String cDamage = "";
	String cPayback = "";
	String iCurApprove = "";

	String dPayCheque = "";
	String mPayCheque = "";
	String yPayCheque = "";

	Vector iReceipt = new Vector();
	Vector zReceiveReten = new Vector();

	String fIDCard = "";
	String fLoseReten = "";
	String fNotice = "";
	String iNotice = "";
    String usedZApprover = "";
	Timestamp checkReprint = null;
 
	//---- 2022-06-30 , for payin ----//
	String iPayType = "";
	String iPayBnk = "";
	String nPayBnk = "";
	String iPayAcc = "";
	String iEmail = "";
	//-------------------------------//	

	double zReten = 0.0;
	double zDamage = 0.0;
        String reqDate = "";

	//-----======== Get Reten Data ==========----//
	sql.delete(0,sql.length());
	sql.append(" select b.i_company||b.i_project||' | '||b.n_project as project_name , c.n_desc , s.n_desc as n_paybnk , ")
	      .append(" trim(d.n_prename_th)||trim(d.n_nemploy_th)||' '||trim(d.n_semploy_th) as emp_name ,a.* from lan:serv_rethd a ")
	      .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
	      .append(" left join lan:serv_xstd c on c.i_type='50' and c.i_code=a.i_doc_type ")
	      .append(" left join docflow:acemploy d on d.i_employ=a.i_staff_payback ")
	      //----- 2022-06-30 , add payin query ------//
	      .append(" left join lan:lhpay_std s on s.i_type='R' and s.i_key1=a.i_paybnk ")
	      //-----------------------------------------//	      
	      .append(" where a.i_doc_status in ('I','S','R','B','W','U','G') and a.z_reten=a.z_recv_reten and a.i_staff_payback is not null ")
	      .append(" and a.i_docno='").append(docNo).append("' ");

	servlog.startLog(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	servlog.endLog();
	while (rs.next()) {
             projectName = doString.checkString(doString.DisplayThai(rs.getString("project_name")),"");
             iSort = doString.checkString(rs.getString("i_sort"),"");
             iHouse = doString.checkString(rs.getString("i_house"),"");
             iDocNo = doString.checkString(rs.getString("i_docno"),"");
             iCompany = doString.checkString(rs.getString("i_company"),"");
             iProject = doString.checkString(rs.getString("i_project"),"");
             iSignBoard = doString.checkString(rs.getString("i_signboard"),"");
             nCustName = doString.checkString(doString.DisplayThai(rs.getString("n_custo")),"");
             guranteeDesc = doString.checkString(doString.DisplayThai(rs.getString("n_desc")),"");
             retCustType = doString.checkString(rs.getString("i_ret_custo"),"");
             iReten = doString.checkString(rs.getString("i_reten"),"");
             iLor = doString.checkString(rs.getString("i_lor"),"");
             iDocStatus = doString.checkString(rs.getString("i_doc_status"),"");
             empName = doString.checkString(doString.DisplayThai(rs.getString("emp_name")),"");
             zReten = rs.getDouble("z_reten");
             zDamage = rs.getDouble("z_damage");

             iCurApprove = doString.checkString(rs.getString("i_cur_apprv"),"");
             fIDCard = doString.checkString(rs.getString("f_id_card"),"");
             fLoseReten = doString.checkString(rs.getString("f_lost_reten"),"");
             fInSpec = doString.checkString(rs.getString("f_inspec"),"");
             cDamage = doString.checkString(doString.DisplayThai(rs.getString("c_damage")),"");
             cPayback = doString.checkString(doString.DisplayThai(rs.getString("c_payback")),"");
             iSpec = doString.checkString(rs.getString("i_inspec"),"");
             iNotice = doString.checkString(rs.getString("i_notice"),"");
             if (iNotice.trim().length()>0) fNotice = "Y";
             
			 //---- 2022-06-30 , for payin ----//
			 iPayType = doString.checkString(rs.getString("i_paytype"),"PAYTO");
			 iPayBnk = doString.checkString(rs.getString("i_paybnk"),"");
			 nPayBnk = doString.checkString(rs.getString("n_paybnk"),"");
			 iPayAcc = doString.checkString(rs.getString("i_payacc"),"");
			 iEmail = doString.checkString(rs.getString("i_email"),"");
			 //-------------------------------//	             

			 checkReprint = rs.getTimestamp("d_prnret_payback");

	    Calendar est = Calendar.getInstance(Locale.ENGLISH);
   	    Timestamp tmp = rs.getTimestamp("d_staff_payback");
	    if (tmp!=null) {
		 est.setTime(tmp);
		 reqDate =  getDateFromCalendar(est)+"&nbsp;,&nbsp;"+getTimeFromCalendar(est)+" น.";
	    } else {
	         reqDate = "";
	    }

	    est = Calendar.getInstance(Locale.ENGLISH);
   	    tmp = rs.getTimestamp("d_est_chq");
	    if (tmp!=null) {
		 est.setTime(tmp);
		 dPayCheque = str.createID(est.get(Calendar.DATE),2);
		 mPayCheque = str.createID(est.get(Calendar.MONTH)+1,2);
		 yPayCheque = str.createID(est.get(Calendar.YEAR),4);
	    } else {
	         reqDate = "";
		 dPayCheque = "";
		 mPayCheque = "";
		 yPayCheque = "";
	    }

	}
	rs.close();

	
	//-----========== If iDocStatus='W' , set all input to disabled Mode , find i_cur_apprv position  ==========---//
	if (iDocStatus.equalsIgnoreCase("I") || iDocStatus.equalsIgnoreCase("R") || iDocStatus.equalsIgnoreCase("S") || iDocStatus.equalsIgnoreCase("B")  || iDocStatus.equalsIgnoreCase("U")) {
  	   disabledInput = "";
	} else {
	   disabledInput = " disabled ";
	}



        //-----========== Get retCustName ============-----//
        sql.delete(0,sql.length());
        if (retCustType.equals("1")) {
   	    sql.append(" select trim(n_prename)||trim(n_ncustomer)||' '||trim(n_scustomer) as cust_name ")
	          .append(" from lan:acxcusto where i_customer='").append(iReten).append("' ");
        } else if (retCustType.equals("2")) {
	    sql.append(" select trim(nvl(n_pname,''))||trim(nvl(n_name,''))||' '||trim(nvl(n_sname,'')) as cust_name ")
	          .append(" from lan:serv_venprj where i_vendor='").append(iReten).append("' ")
	          .append(" and i_company='").append(iCompany).append("' and i_project='").append(iProject).append("' ")
	          .append(" and i_type='05' ");
        } else {
   	    sql.append(" select trim(nvl(n_pname,''))||trim(nvl(n_name,''))||' '||trim(nvl(n_sname,'')) as cust_name ")
	          .append(" from lan:serv_venprj where i_vendor='").append(iReten).append("' ")
	          .append(" and i_company='").append(iCompany).append("' and i_project='").append(iProject).append("' ")
	          .append(" and i_type='06' ");
        }
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
	if (rs.next()) {
	    retCustName = doString.checkString(doString.DisplayThai(rs.getString("cust_name")),"");
	}
	rs.close();


        //-----========== Get Receive  ============-----//
        sql.delete(0,sql.length());
 	sql.append(" select * from lan:serv_payin where ")
	      .append(" i_company='").append(iCompany).append("' and i_project='").append(iProject).append("' ")
	      .append(" and i_sort='").append(iSort).append("' and i_docno='").append(iDocNo).append("' ")
	      .append(" and i_lor='").append(iLor).append("' and i_cashier_conf is not null ");
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
	while (rs.next()) {
	    iReceipt.addElement(doString.checkString(rs.getString("i_receipt"),""));
	    zReceiveReten.addElement(new Double(rs.getDouble("z_recv_reten")));
	} // end while rs
	rs.close();


	Vector approveIdList = new Vector();
	Vector approveNameList = new Vector();
	Vector approvePositionList = new Vector();



        //-----========== Get Approve List  ============-----//
	if (
	    user.getUserWho().equalsIgnoreCase("A") ||  // can delete this line
	    user.getUserWho().equalsIgnoreCase("C") ||  // 2025-06-16 , add service center can use this page
	    user.getUserWho().equalsIgnoreCase("S") || user.getUserWho().equalsIgnoreCase("M") || user.getUserWho().equalsIgnoreCase("Z")) {

		//----============== If user_who='M' , get to approver ==============----//
		sql.delete(0,sql.length());
		sql.append(" select i_employ from lan:useracl where user_id in ( ")
		      .append(" select user_id from lan:serv_pstaff where ")
		      .append(" com_id='").append(iCompany).append("' and ")
			  .append(" (proj_id='").append(iProject).append("' or proj_id='ALL') ")
		      .append(" ) and user_who='M' and user_acl='S' ");
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		while (rs.next()) {
		   String iEmploy = doString.checkString(rs.getString("i_employ"),"");
		   String details[] = getEmployeeDetails(stmt1,iEmploy,servlog);
		   approveIdList.addElement(details[0]);
		   approveNameList.addElement(details[1]);
		   approvePositionList.addElement(details[2]);
		} // end while rs
		rs.close();
		//-----=========================================================------//




		//----======= If user_who='M' not found , use user_who='Z' instead =======----//
		if (approveIdList.size()<=0) {
			sql.delete(0,sql.length());
			sql.append(" select i_employ from lan:useracl where user_id in ( ")
				  .append(" select user_id from lan:serv_pstaff where ")
				  .append(" com_id='").append(iCompany).append("' and ")
				  .append(" (proj_id='").append(iProject).append("' or proj_id='ALL') ")
				  .append(" ) and user_who='Z' and user_acl='S' ");
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			while (rs.next()) {
			   String iEmploy = doString.checkString(rs.getString("i_employ"),"");
			   String details[] = getEmployeeDetails(stmt1,iEmploy,servlog);
			   approveIdList.addElement(details[0]);
			   approveNameList.addElement(details[1]);
			   approvePositionList.addElement(details[2]);
			   usedZApprover = "Y";
			} // end while rs
			rs.close();
		}
		//-----=========================================================------//

	}


	if (user.getUserWho().equalsIgnoreCase("F")) {
	   String details[] = getEmployeeDetails(stmt1,user.getEmpId(),servlog);
	   approveIdList.addElement(details[0]);
	   approveNameList.addElement(details[1]);
	   approvePositionList.addElement(details[2]);
	}

/*
        //-----========== Get Approve List  ============-----//
	if (
	    user.getUserWho().equalsIgnoreCase("A") ||  // can delete this line
	    user.getUserWho().equalsIgnoreCase("S") || user.getUserWho().equalsIgnoreCase("M") || user.getUserWho().equalsIgnoreCase("Z")) {
		sql.delete(0,sql.length());
		sql.append(" select trim(n_prename_th)||trim(n_nemploy_th)||' '||trim(n_semploy_th) as emp_name,i_employ ")
		      .append(" from docflow:acemploy where i_employ in ( ")
		      .append(" select  i_employ  from useracl  where user_id in   ( ")
		      .append(" select user_id from serv_pstaff   where ")
		      .append(" com_id='").append(iCompany).append("' and proj_id='").append(iProject).append("'  ) ")
		      .append(" and user_acl in ('S','M','Z') ) "); // can delete 'S'
		rs = stmt.executeQuery(sql.toString());
		while (rs.next()) {
		   String ename = doString.checkString(rs.getString("emp_name"),"");
		   String iEmploy = doString.checkString(rs.getString("i_employ"),"");
		   approveIdList.addElement(iEmploy);
		   approveNameList.addElement(ename);

		   //---- Find Approver Position -----//
		   sql.delete(0,sql.length());
		   sql.append(" select * from docflow:acempstd where i_type='10' and i_code in ")
			 .append(" (select i_job from docflow:acempjob where i_employ='").append(iEmploy).append("' and d_job in ")
			 .append(" (select max(d_job) from docflow:acempjob where i_employ='").append(iEmploy).append("')) ");
		   rs1 = stmt1.executeQuery(sql.toString());
		   while (rs1.next()) {
		       String approvePos = doString.checkString(rs1.getString("n_desc"),"");
		       approvePositionList.addElement(approvePos);
		   } // end while rs
		   rs1.close();

		} // end while rs
		rs.close();
	}


	if (user.getUserWho().equalsIgnoreCase("F")) {
		sql.delete(0,sql.length());
		sql.append(" select trim(n_prename_th)||trim(n_nemploy_th)||' '||trim(n_semploy_th) as emp_name,i_employ ")
		      .append(" from docflow:acemploy where i_employ='").append(user.getEmpId()).append("' ");
		rs = stmt.executeQuery(sql.toString());
		while (rs.next()) {
		   String ename = doString.checkString(rs.getString("emp_name"),"");
		   String iEmploy = doString.checkString(rs.getString("i_employ"),"");
		   approveIdList.addElement(iEmploy);
		   approveNameList.addElement(ename);

		   //---- Find Approver Position -----//
		   sql.delete(0,sql.length());
		   sql.append(" select * from docflow:acempstd where i_type='10' and i_code in ")
			 .append(" (select i_job from docflow:acempjob where i_employ='").append(iEmploy).append("' and d_job in ")
			 .append(" (select max(d_job) from docflow:acempjob where i_employ='").append(iEmploy).append("')) ");
		   rs1 = stmt1.executeQuery(sql.toString());
		   while (rs1.next()) {
		       String approvePos = doString.checkString(rs1.getString("n_desc"),"");
		       approvePositionList.addElement(approvePos);
		   } // end while rs
		   rs1.close();

		} // end while rs
		rs.close();
	}
*/


%>

<HTML>
<HEAD>
<TITLE>ใบวางเงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">

  function removeComma(num) {
     num = ""+num;
     var tmp = "";

     while (num.indexOf(",")>=0) {
         if (num.substring(0,1)!=",") tmp += num.substring(0,1);
         num = num.substring(1);
     }

     if (num.length>0) tmp += num;

     return tmp;
  }

  function addComma(number) {
     number = '' + number;

     var precision = "";
     if (number.indexOf(".")>=0) {
         precision = number.substring(number.indexOf(".")+1);
         number = number.substring(0,number.indexOf("."));
     }

     if  (number.length > 3) {
          var mod = number.length % 3;
          var output = (mod > 0 ? (number.substring(0,mod)) : '');
          for (i=0 ; i < Math.floor(number.length / 3); i++) {
          if ((mod == 0) && (i == 0))
             output += number.substring(mod+ 3 * i, mod + 3 * i + 3);
          else
             output+= ',' + number.substring(mod + 3 * i, mod + 3 * i + 3);
          }

          if (precision.length>0) {
             output = output + "."+precision;
          }

          return (output);
   } else {
      if (precision.length>0) {
         number = number + "."+precision;
      }
      return number;
   }

}


function calculateDamageValue() {
    var zReten = removeComma(document.forms[0].z_reten.value);
    var zDamage = removeComma(document.forms[0].z_damage.value);

	if (isNaN(parseFloat(zDamage))) {
		alert(" ในช่องค่าความเสียหาย กรุณากรอกตัวเลขเท่านั้น หากไม่มีค่าความเสียหาย กรุณากรอก 0 !"); 
		zDamage = "0.00";
	}

    if (parseFloat(zReten)<parseFloat(zDamage)) {
        alert("ไม่สามารถหักเงินค่าความเสียหาย มากกว่าเงินที่วางค้ำประกันได้ !");
       return false;
    }
    var obj = document.getElementById("show_remain");
    if (obj!=null) {
        var result = parseFloat(zReten).toFixed(2)-parseFloat(zDamage).toFixed(2);
        obj.innerHTML = addComma(result.toFixed(2));
	document.forms[0].z_damage.value = addComma(parseFloat(zDamage).toFixed(2));
    }
}

//--- 2023-02-22 , validate payin ---//
function validatePayInData() {	
	if (document.forms[0].iPayType[0].checked) {
		if (document.forms[0].iPayBnk.value=="") {
			alert(" กรุณาเลือกธนาคาร!! ");
			document.forms[0].iPayBnk.focus();
			return false;
		}

		//---- validate number ----//
       	var numValidate = /^\d{10}$/;
        if (!numValidate.test(document.forms[0].iPayAcc.value)) {
			alert(" กรุณากรอกเลขบัญชีธนาคารเฉพาะตัวเลข 10 หลัก!! ");
			document.forms[0].iPayAcc.focus();
			return false;        
        }                

        //----- validate email -----//
        /*  disable input 
		if (document.forms[0].iEmail.value.length>0) {
	        var emailValidate = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
	        if (!emailValidate.test(document.forms[0].iEmail.value)) {		
				alert(" รูปแบบ Email ไม่ถูกต้อง!! ");
				document.forms[0].iEmail.focus();
				return false;
			}		
		}
		*/
		        
	} else {
		//--- no validate ---//
	}
	
	return true;
}  
//-----------------------------------//

  

function checkComplete() {
     if (!document.forms[0].f_inspec[0].checked && !document.forms[0].f_inspec[1].checked) {
         alert(" กรุณาระบุผลการตรวจงาน ! ");
	 return false;
     }

     if (document.forms[0].f_inspec[1].checked && document.forms[0].c_damage.value.length<=0) {
         alert(" กรุณาระบุความเสียหาย ! ");
	     document.forms[0].c_damage.focus();
	     return false;
     }

	if (isNaN(parseFloat(document.forms[0].z_damage.value))) {
		alert(" ในช่องค่าความเสียหาย กรุณากรอกตัวเลขเท่านั้น หากไม่มีค่าความเสียหาย กรุณากรอก 0 !"); 
		document.forms[0].z_damage.focus();
		return false;
	}

     if (document.forms[0].z_damage.value.length==0) {
         alert("กรุณากรอกค่าความเสียหาย, กรณีไม่มีความเสียหาย กรุณากรอก 0 ! ");
	     document.forms[0].z_damage.focus();
	     return false;
     }

     if (document.forms[0].f_inspec[1].checked && (removeComma(document.forms[0].z_damage.value)-0)<=0) {
         alert(" จำนวนเงินค่าความเสียหายต้องมากกว่า 0 ! ");
	     document.forms[0].z_damage.focus();
	     return false;
     }     
     
     //--- 2023-02-22 , add validate payin ----//
	 if (!validatePayInData()) return false;
	 //----------------------------------------//

     if (document.forms[0].i_cur_apprv.value=="") {
         alert(" กรุณาเลือกผู้อนุมัติ ! ");
		 document.forms[0].i_cur_apprv.focus();
		 return false;
     }

    return true;
}

function printRetReten() {
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_PrintRetRetenServlet";
     document.forms[0].target="_blank";
     document.forms[0].submit();
     document.forms[0].target="";
}

function saveRetReten() {
     if (!checkComplete()) return false;

     document.forms[0].approve_flag.value="";
     document.forms[0].submit();
}

function approveRetReten() {
     if (!checkComplete()) return false;       

     if (confirm("คุณแน่ใจว่าต้องการส่งใบรายการนี้ไป Approve ?")) {	
        document.forms[0].approve_flag.value="Y";
        document.forms[0].submit();
     }
}

</script>


<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<form action="<%=Constants.APP_PATH%>/SERV_Add_RetRetenServlet" method="post">


<input type="hidden" name="i_docno" value="<%=doString.checkString(iDocNo,"")%>">
<input type="hidden" name="i_company" value="<%=doString.checkString(iCompany,"")%>">
<input type="hidden" name="i_project" value="<%=doString.checkString(iProject,"")%>">
<input type="hidden" name="i_doc_status" value="<%=doString.checkString(iDocStatus,"")%>">
<input type="hidden" name="approve_flag" value="">

<input type="hidden" name="use_z_approver" value="<%=usedZApprover%>">


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="80%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ใบวางเงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม</td>
          <td width="20%" class="bigh" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">



            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="220">รายละเอียดการรับแจ้งขอคืนเงินค้ำประกัน</td>
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
    <td class="item ; dotline01" height="22" width="18%">โครงการ
      :</td>
    <td height="22" width="38%" class="dotline01"><%=doString.checkString(projectName,"-")%></td>
    <td height="22" class="item ; dotline01" width="16%">แปลง :</td>
    <td height="22" width="28%" class="dotline01"><%=doString.checkString(iSort,"-")%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="18%">บ้านเลขที่
      :</td>
    <td height="22" width="38%" class="dotline01"><%=doString.checkString(iHouse,"-")%></td>
    <td height="22" class="item ; dotline01" width="16%">เลขที่ใบวางเงิน
      :</td>
    <td height="22" width="28%" class="dotline01"><%=doString.checkString(iDocNo,"-")%> </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="18%">ผู้วางเงินค้ำประกัน
      :</td>
    <td height="22" width="38%" class="dotline01"><%=doString.checkString(retCustName,"-")%></td>
    <td height="22" class="item ; dotline01" width="16%">ลูกค้า :</td>
    <td height="22" width="28%" class="dotline01"><%=doString.checkString(nCustName,"-")%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="18%">เพื่อค้ำประกัน
      :</td>
    <td height="22" width="38%" class="dotline01"><%=doString.checkString(guranteeDesc,"-")%></td>
    <td height="22" class="item ; dotline01" width="16%">จำนวนเงินค้ำประกัน
      :</td>
    <td height="22" width="28%" class="dotline01">
    <input type="hidden" name="z_reten" value="<%=zReten%>">
    <%=format.format(zReten)%>&nbsp; บาท</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="18%">ผู้รับเรื่อง
      :</td>
    <td height="22" width="38%" class="dotline01"><%=doString.checkString(empName,"-")%></td>
    <td height="22" class="item ; dotline01" width="16%">วันเวลาที่แจ้ง
      :</td>
    <td height="22" width="28%" class="dotline01">
    <%
    	//---- 2024-12-16 , always use today for staff send request date ----//
	    Calendar today = Calendar.getInstance(TimeZone.getTimeZone("Asia/Bangkok"));
	    int y = today.get(Calendar.YEAR);
	    if (y>2400) y -= 543;
   	    reqDate  = str.createID(today.get(Calendar.DATE),2);
		reqDate += "/"+str.createID(today.get(Calendar.MONTH)+1,2);
		reqDate += "/"+str.createID(y,4);
		reqDate += "&nbsp;,&nbsp;"+str.createID(today.get(Calendar.HOUR_OF_DAY),2);		
		reqDate += ":"+str.createID(today.get(Calendar.MINUTE),2)+" น.";		
    %>      
    <%=doString.checkString(reqDate,"-")%>
     &nbsp; 
    <span style="color:red">* วันเวลาที่แจ้ง จะถูกปรับปรุงเป็นวันที่ปัจจุบันเสมอ</span>
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
                <td class="item_tab2" width="200">รายละเอียดการคืนเงินค้ำประกันฯ</td>
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
    <td width="16%" height="22" class="item ; dotline01" valign="top">ผู้รับเงินตามเช็ค
      :</td>
    <td width="38%" height="22" class="dotline01" valign="top"><%=doString.checkString(retCustName,"-")%></td>
    <td width="16%" height="22" class="item ; dotline01" valign="top">อ้างอิงใบเสร็จเลขที่
      :</td>
    <td width="30%" height="22" class="dotline01" align='left'>
  <%
      if (iReceipt.size()>0) {
          for (int i=0;i<iReceipt.size();i++) {
	         String receiptNo = (String) iReceipt.elementAt(i);
		 if (i>0) out.println("<br>");
		  %><%=doString.checkString(receiptNo,"-")%> <%
	  } // end for
      } else {
          %>-<%
      }
    %>
    </td>
  </tr>
  </table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="16%" height="22" class="item ; dotline01">ผลการตรวจงาน</td>
    <td height="22" class="item ; dotline01" colspan="3">
    <img border="0" src="images/i_list.gif" align="absmiddle" width="18" height="18" style="cursor:hand" onClick="MM_openBrWindow('SERV_View_RetDoc.jsp?i_docno=<%=iDocNo%>','blank','width=650,height=310,left=140,top=80')">
    </td>
  </tr>
  <tr>
    <td width="16%" height="22" class="item ; dotline01">&nbsp;</td>
    <td width="16%" height="22" class="dotline01">
    <input type="radio" value="Y" name="f_inspec" <%=fInSpec.equalsIgnoreCase("Y") ? " checked " : ""%> <%=disabledInput%>> สภาพเรียบร้อย</td>
    <td width="16%" height="22" class="dotline01">&nbsp;</td>
    <td width="52%" height="22" class="dotline01">&nbsp;</td>
  </tr>
  <tr>
    <td width="16%" height="22" class="item ; dotline01">&nbsp;</td>
    <td width="16%" height="22" class="dotline01">
    <input type="radio" value="N" name="f_inspec" <%=fInSpec.equalsIgnoreCase("N") ? " checked " : ""%> <%=disabledInput%>> เกิดความเสียหาย</td>
    <td width="16%" height="22" class="dotline01">
      ตามใบแจ้งซ่อมเลขที่ :&nbsp;</td>
    <td width="52%" height="22" class="dotline01"> <input type="text" <%=disabledInput%> name="i_inspec" class="box" style="width:100px" value="<%=iSpec%>"></td>
  </tr>
  <tr>
    <td width="16%" height="22" class="item ; dotline01" valign="top">&nbsp;</td>
    <td width="16%" height="22" class="dotline01" valign="top">&nbsp;</td>
    <td width="16%" height="22" class="dotline01" valign="top">ระบุความเสียหาย
      :</td>
    <td width="52%" height="22" class="dotline01" valign="top">
    <textarea rows="3" name="c_damage" cols="20" class="box" style="width:100%" <%=disabledInput%>><%=cDamage%></textarea></td>
  </tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td class="item ; dotline01" height="22" width="100%" colspan="6">สรุปยอดคืนเงินค้ำประกัน
      :</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="5%">&nbsp;</td>
    <td height="22" width="20%" class="dotline01">ยอดเงินวางค้ำประกัน
      :</td>
    <td height="22" width="15%" class="dotline01" align="right"><%=format.format(zReten)%></td>
    <td height="22" width="14%" class="dotline01">&nbsp; บาท</td>
    <td height="22" width="16%" class="dotline01">&nbsp;</td>
    <td height="22" width="30%" class="dotline01">&nbsp;</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="5%">&nbsp;</td>
    <td height="22" width="20%" class="dotline01">หัก
      เงินค่าความเสียหาย :</td>
    <td height="22" width="15%" class="dotline01" align="right">
    <input type="text" name="z_damage" onchange="calculateDamageValue();" <%=disabledInput%> class="boxR" style="width:100px" size="20" value="<%=format.format(zDamage)%>">
    </td>
    <td height="22" width="14%" class="dotline01">&nbsp; บาท</td>
    <td height="22" width="16%" class="dotline01">&nbsp;</td>
    <td height="22" width="30%" class="dotline01">&nbsp;</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="5%">&nbsp;</td>
    <td height="22" width="20%" class="dotline01">ยอดคืนเงินค้ำประกัน
      :</td>
    <td height="22" width="15%" class="dotline01" align="right"><span id="show_remain"><%=format.format(zReten-zDamage)%></span></td>
    <td height="22" width="14%" class="dotline01">&nbsp; บาท</td>
    <td height="22" width="16%" class="dotline01 ; item">วันที่ต้องการรับเช็ค
      :</td>
    <td height="22" width="30%" class="dotline01">
    <%
    	//---- 2024-11-26 , always use today+15 days for cheque receive ----//
	    today.add(Calendar.DATE,15);
	    y = today.get(Calendar.YEAR);
	    if (y>2400) y -= 543;
   	    dPayCheque = str.createID(today.get(Calendar.DATE),2);
		mPayCheque = str.createID(today.get(Calendar.MONTH)+1,2);
		yPayCheque = str.createID(y,4);
    %>    
    <input type="text" name="d_pay_cheque" class="boxC" style="width:30px" disabled value="<%=dPayCheque%>">/
    <input type="text" name="m_pay_cheque" class="boxC" style="width:30px" disabled value="<%=mPayCheque%>">/
    <input type="text" name="y_pay_cheque" class="boxC" style="width:30px" disabled  value="<%=yPayCheque%>"> &nbsp; 
    <span style="color:red">* วันที่ต้องการรับเช็ค จะเป็นวันที่ปัจจุบันบวก 15 วันเสมอ</span>
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


	  <!--============================ 2022-06-30 , add refund block ========================================-->	
	  <%
	  		//---- 2023-02-22 , open input mode for edit account ----//
	  		if (iDocStatus.equalsIgnoreCase("W") || iDocStatus.equalsIgnoreCase("G")) {
	  			//--- view mode ---//
	  			%>
			      <BR style="font-size:10pt">
			      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
			        <TBODY>
			          <TR>
			            <TD class="item_tab1"><IMG border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></TD>
			            <TD class="item_tab2" width="200">รายละเอียดการคืนเงิน</TD>
			            <TD class="item_tab3"></TD>
			            <TD>&nbsp;</TD>
			          </TR>
			        </TBODY>
			      </TABLE>
			      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
			        <TBODY>
			          <TR>
			            <TD width="5" valign="top"><IMG border="0" src="images/Corn01.gif" width="5" height="5"></TD>
			            <TD class="frmTop">&nbsp;</TD>
			            <TD width="5" valign="top" align="right"><IMG border="0" src="images/Corn02.gif" width="5" height="5"></TD>
			          </TR>
			        </TBODY>
			      </TABLE>
			      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
			        <TBODY>
			          <TR>
			            <TD width="100%" class="frmLR" align="center">
			            <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
			              <TBODY>
			                <%
			                	if (iPayType.equalsIgnoreCase("PAYIN")) {
			                		//--- payin , display bank & account ---//
			                		if (iPayAcc.length()>=10) {
			                			iPayAcc = iPayAcc.substring(0,3)+"-"+iPayAcc.substring(3,4)+"-"+iPayAcc.substring(4,9)+"-"+iPayAcc.substring(9);
			                		}
			                		
									%>
					                <TR>                  
									  <TD class="item ; dotline01" height="22" width="13%">Pay-In เข้าบัญชี   : </TD>
									  <TD class="dotline01" height="22" width="20%">ธนาคาร<%=doString.DisplayThai(nPayBnk) %></TD>
									  <TD class="item ; dotline01" height="22" width="13%"> ชื่อบัญชี : </TD>
									  <TD class="dotline01" height="22" width="20%">&nbsp;<%=doString.checkString(retCustName,"-") %></TD>
									  <TD class="item ; dotline01" height="22" width="14%"> เลขที่บัญชี  : </TD>
									  <TD class="dotline01" height="22" width="20%">&nbsp;<%=doString.checkString(iPayAcc,"-") %></TD>                
					                </TR>  
					                <!-- 
					                <TR>                  
									  <TD class="item ; dotline01" height="22"><nobr>E-Mail แจ้งกลับ กรณี Pay-In เรียบร้อยแล้ว : </nobr></TD>
									  <TD class="dotline01" height="22" colspan="5"><%=doString.checkString(iEmail,"-") %></TD>
									</TR>
									-->						
					                <%
			                	} else {
			                		//--- payto , display cheque name ---//
			                		%>	 
					                <TR>          
									  <TD class="item ; dotline01" height="22" width="13%"><nobr>เช็คคืนเงิน สั่งจ่ายในนาม : </nobr></TD>
									  <TD class="dotline01" height="22" width="87%"><%=doString.checkString(retCustName,"-") %></TD>		                
					                </TR> 	                		
			                		<%
			                	}
			                %> 
			                <TR>
			                  <TD class="item ; dotline01" height="22" colspan="3">
			                  <span style="color:red">* การคืนเงินจะทำคืนในชื่อของผู้วางเงินค้ำประกันเท่านั้น ไม่สามารถคืนเงินในชื่อคนอื่นได้</span>
			                  </TD>
			                </TR>                                  
			              </TBODY>
			            </TABLE>
			            </TD>
			          </TR>
			        </TBODY>
			      </TABLE>
			      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
			        <TBODY>
			          <TR>
			            <TD width="5" valign="bottom"><IMG border="0" src="images/Corn03.gif" width="5" height="5"></TD>
			            <TD class="frmBottom">&nbsp;</TD>
			            <TD width="5" valign="bottom" align="right"><IMG border="0" src="images/Corn04.gif" width="5" height="5"></TD>
			          </TR>
			        </TBODY>
			      </TABLE>  	  			
	  			<%
	  		} else {
	  			//--- 2023-02-22 , edit mode ---//
	  			%>
			      <BR style="font-size:10pt">
			      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
			        <TBODY>
			          <TR>
			            <TD class="item_tab1"><IMG border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></TD>
			            <TD class="item_tab2" width="200">รายละเอียดการคืนเงิน</TD>
			            <TD class="item_tab3"></TD>
			            <TD>&nbsp;</TD>
			          </TR>
			        </TBODY>
			      </TABLE>
			      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
			        <TBODY>
			          <TR>
			            <TD width="5" valign="top"><IMG border="0" src="images/Corn01.gif" width="5" height="5"></TD>
			            <TD class="frmTop">&nbsp;</TD>
			            <TD width="5" valign="top" align="right"><IMG border="0" src="images/Corn02.gif" width="5" height="5"></TD>
			          </TR>
			        </TBODY>
			      </TABLE>
			      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
			        <TBODY>
			          <TR>
			            <TD width="100%" class="frmLR" align="center">
			            <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
			              <TBODY>
			                <TR>
			                  <TD class="item ; dotline01" height="22" width="56%">
			                  	<INPUT type="radio" value="PAYIN" name="iPayType" <%=(iPayType.equals("PAYIN") ? "checked" : "") %>>&nbsp; 
						         Pay-In เข้าบัญชี : &nbsp;
			                    <SELECT size="1" name="iPayBnk" class="box" style="width:210px">
					              <OPTION value="">----- เลือกธนาคาร -----</OPTION>
								<%
									String code = "";
									String optionSelected = "";
								
									sql.delete(0, sql.length());
									sql.append(" SELECT i_key1, n_desc FROM lan:lhpay_std WHERE i_type = 'R'  ORDER BY i_key1 ");
									servlog.startLog(sql.toString());
									rs = stmt.executeQuery(sql.toString());
									servlog.endLog();
									if (rs != null) {
										while (rs.next() == true) {
											code = doString.checkString(rs.getString("i_key1"));
											optionSelected = "";
											if (iPayBnk.equals(code)) {
												optionSelected = "selected";
											}
								%>
								              <OPTION value="<%=code%>" <%=optionSelected%>><%=code+" | "+doString.checkString(doString.DisplayThai(rs.getString("n_desc"))) %></OPTION>
								<%
										}// end while
										rs.close();
										rs=null;
									}
								%>		              
								</SELECT> &nbsp; &nbsp; 
						                 ชื่อบัญชี : &nbsp;
			                    <INPUT type="text" name="payInName" class="box" readonly value="<%=doString.checkString(retCustName,"-")%>" style="width:200px ; background-color:#ECECEC">
			                  </TD>                  
			                  <TD height="22" class="item ; dotline01" width="16%">เลขที่บัญชี 10 หลัก : &nbsp;</TD>
			                  <TD height="22" width="28%" class="dotline01">&nbsp;
			                  <INPUT type="text" name="iPayAcc" class="box" maxlength="10" value="<%=iPayAcc %>" style="width:100px"> &nbsp; 
			                  <span style="color:red">* ไม่ต้องระบุ '-' หรือ ช่องว่าง</span>
			                  </TD>
			                </TR>                
			                <TR>
			                  <TD class="item ; dotline01" height="22" colspan="3">&nbsp;</TD>
			                </TR>                             
			                <TR>
			                  <TD class="item ; dotline01" height="22" width="56%">
			                  	<INPUT type="radio" value="PAYTO" name="iPayType" <%=(iPayType.equals("PAYTO") ? "checked" : "") %>>&nbsp; 
						                 เช็คคืนเงิน สั่งจ่ายในนาม : &nbsp;
			                    <INPUT type="text" name="payToName" class="box" readonly value="<%=doString.checkString(retCustName,"-")%>" style="width:200px ; background-color:#ECECEC">
			                  </TD> 
			                  <TD height="22" class="item ; dotline01" width="16%">&nbsp;</TD>
			                  <TD height="22" width="28%" class="dotline01">&nbsp;</TD>
			                </TR>  
			                <TR>
			                  <TD class="item ; dotline01" height="22" colspan="3">
			                  <span style="color:red">* การคืนเงินจะทำคืนในชื่อของผู้วางเงินค้ำประกันเท่านั้น ไม่สามารถคืนเงินในชื่อคนอื่นได้</span>
			                  </TD>
			                </TR>                               
			              </TBODY>
			            </TABLE>
			            </TD>
			          </TR>
			        </TBODY>
			      </TABLE>
			      <TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
			        <TBODY>
			          <TR>
			            <TD width="5" valign="bottom"><IMG border="0" src="images/Corn03.gif" width="5" height="5"></TD>
			            <TD class="frmBottom">&nbsp;</TD>
			            <TD width="5" valign="bottom" align="right"><IMG border="0" src="images/Corn04.gif" width="5" height="5"></TD>
			          </TR>
			        </TBODY>
			      </TABLE>           	  			
	  			<%
	  		}
	  		//-------------------------------------------------------//
	  %>                     
	  <!--===================================================================================================-->	


<br style="font-size:10pt">



            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">Comment</td>
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
    <td width="100%" class="frmLRpad01"><textarea rows="5" name="c_payback" <%=disabledInput%> class="box" style="width:100%" cols="20"><%=cPayback%></textarea></td>
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
                <td class="item_tab2" width="200">สายงานการอนุมัติ</td>
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
    <td width="100%" class="frmLRpad01">
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td>


<!-- Approve#1 -->
<table cellspacing="0" cellpadding="0" width="100%">
                                  <tr>
                                    <td width="15"><img border="0" src="images/no1.gif" align="absmiddle" width="15" height="15"></td>
                                    <td width="25"><img border="0" src="images/i_pass.gif" align="absmiddle" width="19" height="16"></td>
                                    <td>
				    <%
				           String reqUser[] = getEmployeeDetails(stmt1,user.getEmpId(),servlog);
				           out.println("<font color='#000096'>"+doString.DisplayThai(reqUser[1])+"</font> &nbsp; ( "+doString.DisplayThai(reqUser[2])+" )");
				    %>
				    </td>
                                  </tr>
</table>
<!-- Approve#1 End -->


          </td>
          <td width="100" align="center">
<img border="0" src="images/arrow6.gif" align="absmiddle" width="90" height="40">
          </td>
          <td>


<!-- Approve#2 -->
<table cellspacing="0" cellpadding="0" width="100%">
                                  <tr>
                                    <td width="15"><img border="0" src="images/no2.gif" align="absmiddle" width="15" height="15"></td>
                                    <td width="25"><img border="0" src="images/i_wait.gif" align="absmiddle" width="19" height="16"></td>
                                    <td>
				    <%
					if (iDocStatus.equalsIgnoreCase("I") || iDocStatus.equalsIgnoreCase("R") || iDocStatus.equalsIgnoreCase("S") || iDocStatus.equalsIgnoreCase("B") || iDocStatus.equalsIgnoreCase("U")) {
					   %>
					    <font color="#000096">
					    <select size="1" name="i_cur_apprv" class="box" style="width:350px" <%=disabledInput%>>
					    <option value=''>---- กรุณาเลือก ----</option>
					    <%
						   String eid = "";
						   String ename = "";
						   String position = "";
						   String selected = "";	
						   int cnt = 0;				       
						   
					       if (approveIdList.size()>0) {					       
							   for (int i=0;i<approveIdList.size();i++) {
							   		eid = (String) approveIdList.elementAt(i);
							   		ename = (String) approveNameList.elementAt(i);
							   		position = (String) approvePositionList.elementAt(i);
							   		selected = "";
							   		
									if (iCurApprove.equalsIgnoreCase(eid)) {
									    selected = " selected ";
									}
	
								 	if (eid.trim().length()<=0) continue;
								 
								 	%><option value="<%=eid%>" <%=selected%>><%=doString.DisplayThai(ename)%> &nbsp; &nbsp; (<%=doString.DisplayThai(position)%>)</option><%
							   } // end for
					       }

						    //------ 2023-06-14 , add vp for choose approver -------//
							sql.delete(0,sql.length());
							sql.append(" select i_employ from lan:useracl where user_id in ( ")
							   .append("   select user_id from lan:serv_pstaff where ")
							   .append("   com_id='"+iCompany+"' and proj_id='"+iProject+"' ")
							   .append(" ) and user_who='P' and user_acl='S' ")
							   .append(" order by i_employ ");
							servlog.startLog(sql.toString());
							rs = stmt.executeQuery(sql.toString());
							servlog.endLog();
							while (rs.next()) {
							   String details[] = getEmployeeDetails(stmt1,doString.checkString(rs.getString("i_employ"),""),servlog);
							   eid = details[0];
							   ename = details[1];
							   position = details[2];
							   selected = "";
							   
							   if (iCurApprove.equalsIgnoreCase(eid)) {
								   selected = " selected ";
							   }
	
							   if (eid.trim().length()<=0) continue;
								
							   cnt++;
							   if (cnt==1) {
							   	   %><option value='' disabled>---- ระดับผู้จัดการฝ่ายขึ้นไป ----</option><%
							   }
							   
							   %><option value="<%=eid%>" <%=selected%>><%=doString.DisplayThai(ename)%> &nbsp; &nbsp; (<%=doString.DisplayThai(position)%>)</option><%								   
							} // end while rs
							rs.close();			
						    //------------------------------------------------------//					       
					    %>
					    </select>&nbsp; </font>					   
					   <%
					} else {
				           String curApprv[] = getEmployeeDetails(stmt1,iCurApprove,servlog);
				           out.println("<font color='#000096'>"+doString.DisplayThai(curApprv[1])+"</font> &nbsp; ( "+doString.DisplayThai(curApprv[2])+" )");
					} // end if check iDocStatus 
				    %>
				    </td>
                                  </tr>
</table>
<!-- Approve#2 End -->


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



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>

	    <%
	       if ((iDocStatus.equalsIgnoreCase("W") || iDocStatus.equalsIgnoreCase("G")) && checkReprint==null) {
	          %>
		    <td width="80" class="act_tab2">	    
		    <img border="0" src="images/act_refund01.gif" onclick="printRetReten();"
				onmouseout=nereidFade(this,70,50,5)
				onmouseover=nereidFade(this,100,50,5)
				style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">&nbsp;&nbsp;
		    </td>
		  <%
	       } else if (iDocStatus.equalsIgnoreCase("I") || iDocStatus.equalsIgnoreCase("R") || iDocStatus.equalsIgnoreCase("S") || iDocStatus.equalsIgnoreCase("B") || iDocStatus.equalsIgnoreCase("U")) {
	          %>
		    <td width="160" class="act_tab2">	    
		    <img border="0" src="images/act_saveandclose.gif" onclick="saveRetReten();"
				onmouseout=nereidFade(this,70,50,5)
				onmouseover=nereidFade(this,100,50,5)
				style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">&nbsp;&nbsp;
		    <img border="0" src="images/act_send2app.gif" onclick="approveRetReten();"
				onmouseout=nereidFade(this,70,50,5)
				onmouseover=nereidFade(this,100,50,5)
				style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">
		    </td>
		  <%
	       }
	     %>	

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

</BODY>

</HTML>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_Add_RetReten.jsp : " + e.getMessage());
		System.out.println("ERROR SERV_Add_RetReten.jsp : " + sql.toString());
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