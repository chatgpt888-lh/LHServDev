<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%!  
  public int getCountValue(Statement stmt,String sql,ServLog servlog) throws Exception {
       int result = 0;
	   servlog.startLog(sql.toString());
       ResultSet rs = stmt.executeQuery(sql);
	   servlog.endLog();
       if (rs.next()) {
          result = rs.getInt(1);
       }
       rs.close();
       
       return result;
  }
  
  public int countResultRow(Statement stmt,String sql,ServLog servlog) throws Exception {
       int result = 0;
	   servlog.startLog(sql.toString());
       ResultSet rs = stmt.executeQuery(sql);
	   servlog.endLog();
       while (rs.next()) {
          result++;
       }
       rs.close();
       
       return result;
  }  
  
  public String getDateFromResultSet(ResultSet rs,String fieldName) throws Exception {
      String result = "";      
	  Calendar cal = Calendar.getInstance();
	  Timestamp tmp = rs.getTimestamp(fieldName);
	
	  if (tmp!=null)  {
	      cal.setTime(tmp);
	      result = getDateFromCalendar(cal);
	  }      
      
      return result;
  }
  
  public int countDocFromPayment(SERV_CommonData common,Statement stmt,User user,String date,String status,String condition,boolean isReject,ServLog servlog) throws Exception {
      StringBuffer sql = new StringBuffer();
      sql.append(" select count(*) from serv_dochd a,serv_payment b ")
            .append(" where  a.f_status='OPN' and a.i_doc_type='J' and ")
            .append(" b.f_itmstatus='").append(status).append("' and b.f_itmstatus!='CAN' ")
            .append(" and b.i_docno=a.i_docno ").append(condition)
            .append(" and b.d_payment='"+date+"' ");
            
      if (user.getUserWho().equalsIgnoreCase(Constants.PERMISSION_VENDOR)) { 
         sql.append(" and b.i_vendor='").append(user.getEmpId()).append("' "); 
      } else {
          //------- Add project id that user is permission ---------//
		  /*
		   String projList = common.getProjectListByUserId(user.getUserID());
		   if (projList.length()>0) {
		       sql.append(" and substr(a.i_docno,1,6) in ("+projList+") ");
		   } else {
		       //----- used for user that no project in hand , set for data not load ----//
		       condition += " and a.i_docno='NOPROEJCT' ";
		   }
		   */
      }
                  
      if (isReject) { 
         sql.append(" and a.f_reject='Y' and a.d_reject is not null "); 
      } else {
         sql.append(" and a.f_reject='N' and a.d_reject is null "); 
      }
      
      sql.append(" group by a.i_docno ");            

      return countResultRow(stmt,sql.toString(),servlog);
  }
  
%>

<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_Home_backup.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   String selProj = doString.checkString(request.getParameter("sel_project"),"");
   
   //-----====================== Search BOQ Data ================================------//
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	SERV_CommonData common = null;
	boolean BOQApprove = false;
	   
	try {
	    doString str = new doString();
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();       
		common = new SERV_CommonData(conn); 
        //----=======================================----//    
        
        
        
        //---============== Check BOQ Approve Permission =================----//
        if (user.getUserWho().equalsIgnoreCase("C") && user.getUserACL().equalsIgnoreCase("S")) {
           BOQApprove = true;
        }


       //----============== Generate Conditionm ================-----//
       String condition = "";
       if (selProj.length()>0 && !selProj.equalsIgnoreCase("ALL"))  {
          condition = " and a.i_company||':'||a.i_project='"+selProj+"'  ";
       }
		if (selProj.trim().length()<=0) {
		   String projList = common.getProjectListByUserId(user.getUserID());
		   if (projList.length()>0) {
		       condition += " and substr(a.i_docno,1,6) in ("+projList+") ";
		   } else {
		       //----- used for user that no project in hand , set for data not load ----//
		       condition += " and a.i_docno='NOPROEJCT' ";
		   }
		}        

        
        //----=========== Get Payment Date =============----//        
        String showCurrentPaymentDate = "";
        String showCurrentConstructorDate = "";
        String showCurrentServiceStaffDate = "";
        String showCurrentServiceManagerDate = "";
        String showCurrentManagerDate = "";
        String showCurrentVPDate = "";

        String showNextPaymentDate = "";
        String showNextConstructorDate = "";
        String showNextServiceStaffDate = "";
        String showNextServiceManagerDate = "";
        String showNextManagerDate = "";
        String showNextVPDate = "";
                
        String currentPaymentDate = "";
        String nextPaymentDate = "";
                
        sql.delete(0,sql.length());
        sql.append(" select * from serv_payschd where d_payment>=today order by d_payment ");
		servlog.startLog(sql.toString());
        rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
        int cnt = 1;
        while (rs.next()) {
            //---- Payment Date ----// 
		    Calendar pay = Calendar.getInstance();
		    Timestamp tmp = rs.getTimestamp("d_payment");

		    if (tmp!=null)  {
		        pay.setTime(tmp);    
		        
		        String tmpDate = "";
		        int year = pay.get(Calendar.YEAR);
		        if (year>2400) year -= 543;
		        tmpDate = year+"-"+str.createID((pay.get(Calendar.MONTH)+1),2)+"-"+str.createID(pay.get(Calendar.DATE),2);
		          
	            if (cnt==1) { 
	               currentPaymentDate = tmpDate;
	               showCurrentPaymentDate = getDateFromResultSet(rs,"d_payment");
                   showCurrentConstructorDate = getDateFromResultSet(rs,"d_contructor");
                   showCurrentServiceStaffDate = getDateFromResultSet(rs,"d_service_staff");
                   showCurrentServiceManagerDate = getDateFromResultSet(rs,"d_service_man");
                   showCurrentManagerDate = getDateFromResultSet(rs,"d_service_zone");
                   showCurrentVPDate = getDateFromResultSet(rs,"d_vp");
	            } else if (cnt==2) {
	               nextPaymentDate = tmpDate;
	               showNextPaymentDate = getDateFromResultSet(rs,"d_payment");
                   showNextConstructorDate = getDateFromResultSet(rs,"d_contructor");
                   showNextServiceStaffDate = getDateFromResultSet(rs,"d_service_staff");
                   showNextServiceManagerDate = getDateFromResultSet(rs,"d_service_man");
                   showNextManagerDate = getDateFromResultSet(rs,"d_service_zone");
                   showNextVPDate = getDateFromResultSet(rs,"d_vp");
	            } else { break; }
		    }         
            cnt++;
        }
                        
        
        //----=========== Count for OpenJob Table =============----//        
        int jobWait = 0;
        int jobPass = 0;
        int taskWait = 0;
        int taskPass = 0;
        int completeWait = 0;
        int completePass = 0;
        
        sql.delete(0,sql.length());
        sql.append(" select count(*) from serv_dochd a where a.f_status='OPN' and a.i_doc_type='I' ")
              .append(condition);
        jobWait = getCountValue(stmt,sql.toString(),servlog); 
        
        sql.delete(0,sql.length());
        sql.append(" select count(*) from serv_dochd a,serv_docdt b ")
              .append(" where  a.f_status='OPN' and a.i_doc_type='J' and b.f_itmstatus='200' ")
              .append(" and b.i_docno=a.i_docno ").append(condition)
              .append(" group by a.i_docno ");
        jobPass = countResultRow(stmt,sql.toString(),servlog);
        
        taskWait = jobPass;
        
        sql.delete(0,sql.length());
        sql.append(" select count(*) from serv_dochd a,serv_docdt b ")
              .append(" where  a.f_status='OPN' and a.i_doc_type='J' and b.f_itmstatus='300' and b.f_itmstatus!='CAN' ")
              .append(" and b.i_docno=a.i_docno ").append(condition)
              .append(" group by a.i_docno ");
        taskPass = countResultRow(stmt,sql.toString(),servlog);

        completeWait = taskPass;
        
        sql.delete(0,sql.length());
        sql.append(" select count(*) from serv_dochd a,serv_payment b ")
              .append(" where  a.f_status='OPN' and a.i_doc_type='J' and b.f_itmstatus='400' and b.f_itmstatus!='CAN' ")
              .append(" and b.i_docno=a.i_docno ").append(condition)
              .append(" group by a.i_docno ");
        completePass = countResultRow(stmt,sql.toString(),servlog);
       

        //----=========== Count for Current Payment Table =============----//        
        int cConstructorWait = 0;
        int cConstructorPass = 0;
        int cConstructorReject = 0;
        int cServiceStaffWait = 0;
        int cServiceStaffPass = 0;
        int cServiceManagerWait = 0;
        int cServiceManagerPass = 0;        
        int cManagerWait = 0;
        int cManagerPass = 0;              
        int cVPWait = 0;
        int cVPPass = 0;      
        
        //----- Constructor -----//
        cConstructorWait = countDocFromPayment(common,stmt,user,currentPaymentDate,"400",condition,false,servlog);   
        cConstructorPass = countDocFromPayment(common,stmt,user,currentPaymentDate,"500",condition,false,servlog);   
        cConstructorReject = countDocFromPayment(common,stmt,user,currentPaymentDate,"400",condition,true,servlog);   
		//------ ServiceStaff ------//
        cServiceStaffWait = countDocFromPayment(common,stmt,user,currentPaymentDate,"500",condition,false,servlog);   
        cServiceStaffPass = countDocFromPayment(common,stmt,user,currentPaymentDate,"600",condition,false,servlog);   
		//------ ServiceManager ------//
        cServiceManagerWait = countDocFromPayment(common,stmt,user,currentPaymentDate,"600",condition,false,servlog);   
        cServiceManagerPass = countDocFromPayment(common,stmt,user,currentPaymentDate,"700",condition,false,servlog);   
		//------ Manager ------//
        cManagerWait = countDocFromPayment(common,stmt,user,currentPaymentDate,"700",condition,false,servlog);   
        cManagerPass = countDocFromPayment(common,stmt,user,currentPaymentDate,"800",condition,false,servlog);   
		//------ VP ------//
        cVPWait = countDocFromPayment(common,stmt,user,currentPaymentDate,"800",condition,false,servlog);   
        cVPPass = countDocFromPayment(common,stmt,user,currentPaymentDate,"CLS",condition,false,servlog);       
        
                
        //----=========== Count for Next Payment Table =============----//        
        int nConstructorWait = 0;
        int nConstructorPass = 0;
        int nConstructorReject = 0;
        int nServiceStaffWait = 0;
        int nServiceStaffPass = 0;
        int nServiceManagerWait = 0;
        int nServiceManagerPass = 0;        
        int nManagerWait = 0;
        int nManagerPass = 0;              
        int nVPWait = 0;
        int nVPPass = 0;            
        
        //----- Constructor -----//
        nConstructorWait = countDocFromPayment(common,stmt,user,nextPaymentDate,"400",condition,false,servlog);   
        nConstructorPass = countDocFromPayment(common,stmt,user,nextPaymentDate,"500",condition,false,servlog);   
        nConstructorReject = countDocFromPayment(common,stmt,user,nextPaymentDate,"400",condition,true,servlog);   
		//------ ServiceStaff ------//
        nServiceStaffWait = countDocFromPayment(common,stmt,user,nextPaymentDate,"500",condition,false,servlog);   
        nServiceStaffPass = countDocFromPayment(common,stmt,user,nextPaymentDate,"600",condition,false,servlog);   
		//------ ServiceManager ------//
        nServiceManagerWait = countDocFromPayment(common,stmt,user,nextPaymentDate,"600",condition,false,servlog);   
        nServiceManagerPass = countDocFromPayment(common,stmt,user,nextPaymentDate,"700",condition,false,servlog);   
		//------ Manager ------//
        nManagerWait = countDocFromPayment(common,stmt,user,nextPaymentDate,"700",condition,false,servlog);   
        nManagerPass = countDocFromPayment(common,stmt,user,nextPaymentDate,"800",condition,false,servlog);   
		//------ VP ------//
        nVPWait = countDocFromPayment(common,stmt,user,nextPaymentDate,"800",condition,false,servlog);   
        nVPPass = countDocFromPayment(common,stmt,user,nextPaymentDate,"CLS",condition,false,servlog);   

     
     
     
        //----=========== Count for BOQ Request =============----//        
        int boqWait = 0;
        int boqPass = 0;
     
		sql.delete(0,sql.length());
		sql.append(" select count(*) cnt from serv_noboq ")
		   .append(" where d_keyin between (today-30) and today and d_approve is null ");
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		if (rs.next()) {
		    boqWait = rs.getInt("cnt");
		}
		rs.close();

		sql.delete(0,sql.length());
		sql.append(" select count(*) cnt from serv_noboq ")
		   .append(" where d_keyin between (today-30) and today and d_approve is not null ");
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		if (rs.next()) {
		    boqPass = rs.getInt("cnt");
		}
		rs.close();
   
%>

<HTML>
<HEAD>
<TITLE>Home</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--

   function queryProject() {
       document.forms[0].action = "SERV_Home.jsp";
       document.forms[0].submit();
   }
   
//-->
</script>


<base target="_self">


</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM method="POST" action="">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center" class="BD">
    

      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ยินดีต้อนรับสู่ระบบบริการหลังการขาย</td>
          <td width="30%" align="right">
          <a href="SERV_InfJob.jsp"><img border="0" src="images/icon_add_IFJ.gif" width="120" height="34"></a>
          </td>
        </tr>
      </table>


<br style="font-size:10pt">
                

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
    <td height="22" class="item ; dotline01" width="8%">ชื่อ :</td>
    <td height="22" width="37%" class="dotline01"><%=doString.DisplayThai(user.getEmpName())%></td>
    <td height="22" width="15%" class="item ; dotline01">เลือกโครงการ : </td>
    <td height="22" width="40%" class="dotline01">
    <%=common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:250px' ",true)%>    
     &nbsp;&nbsp; <a href="#" onclick="queryProject();"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a> </td>
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



<%
   if (!user.getUserWho().equalsIgnoreCase(Constants.PERMISSION_VENDOR)) {
%>
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดงานแจ้งซ่อม</td>
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
    <td width="55%" class="col_name">Description</td>
    <td width="15%" class="col_name">Wait</td>
    <td width="15%" class="col_name">Pass</td>
    <td width="15%" class="col_name">Reject</td>
  <tr>
    <td width="55%" class="item ; dotline" align="left"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="13" height="13">
      Job - ใบแจ้งซ่อม</td>
    <td width="15%" class="dotline" align="center"><a href="SERV_OpenJob_List.jsp?sel_project=<%=selProj%>"><%=jobWait%></a></td>
    <td width="15%" class="dotline" align="center"><%=jobPass%></td>
    <td width="15%" class="dotline" align="center">0</td>
  </tr>
    <td width="55%" class="item ; dotline" align="left"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="13" height="13">
      Task -
      ผู้รับเหมาเริ่มดำเนินงาน</td>
    <td width="15%" class="dotline" align="center"><a href="SERV_StartTask_List.jsp?sel_project=<%=selProj%>"><%=taskWait%></a></td>
    <td width="15%" class="dotline" align="center"><%=taskPass%></td>
    <td width="15%" class="dotline" align="center">0</td>
  <tr>
    <td width="55%" class="item ; dotline" align="left"><img border="0" src="images/i_arrow1.gif" align="absmiddle" width="13" height="13">
      Complete - ผู้รับเหมาปิดงาน</td>
    <td width="15%" class="dotline" align="center"><a href="SERV_CompTask_List.jsp?sel_project=<%=selProj%>"><%=completeWait%></a></td>
    <td width="15%" class="dotline" align="center"><%=completePass%></td>
    <td width="15%" class="dotline" align="center">0</td>
  </tr>
  <tr>
    <td width="55%" class="item ; solidline" align="left">&nbsp;</td>
    <td width="15%" class="solidline" align="center">&nbsp;</td>
    <td width="15%" class="solidline" align="center">&nbsp;</td>
    <td width="15%" class="solidline" align="center">&nbsp;</td>
  </tr>
  <tr>
    <td width="55%" class="solidline" align="left"><a href="SERV_BOQCode03.jsp"><img border="0" src="images/i_arrow2.gif" align="absmiddle" width="13" height="13">
      <font color="#000080">ขออนุมัติรหัส BOQ</font></a></td>
    <td width="15%" class="solidline" align="center"><font color="#000080"><%=(BOQApprove ? "<a href='SERV_BOQCode.jsp'>"+boqWait+"</a>" : "&nbsp;")%></font></td>
    <td width="15%" class="solidline" align="center"><font color="#000080"><%=(BOQApprove ? boqPass+"" : "&nbsp;")%></font></td>
    <td width="15%" class="solidline" align="center"><font color="#000080"><%=(BOQApprove ? "0" : "&nbsp;")%></font></td>
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

<%
  } // end if check permission
%>

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
		System.out.println("ERROR SERV_Home.jsp : " + e.getMessage());
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