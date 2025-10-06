<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %> 
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%!
	// Caching the DataSource - It is obtained in the jspInit() method
	private javax.sql.DataSource ds = null;
	private String dsName = Constants.JDBC_LAN;
	private void getDS() throws NamingException {
		// Note the new Initial Context Factory interface available in WebSphere 4.0
		Hashtable parms = new Hashtable();
		parms.put(Context.INITIAL_CONTEXT_FACTORY, "com.ibm.websphere.naming.WsnInitialContextFactory");
		InitialContext ctx = new InitialContext(parms);
		// Perform a naming service lookup to get the DataSource object.
		ds = (javax.sql.DataSource) ctx.lookup(dsName);
		ctx.close();
	}		
	// This Happens Once and is Reused
	public void jspInit() {
		try{
			getDS();
		}catch(Exception es){
		  es.printStackTrace();
		}
	}
%>
<%
//****************************************
//String ParameterNames = "";
//for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
//	ParameterNames = (String)e.nextElement();
//	System.out.println(ParameterNames + " = "+request.getParameter(ParameterNames));
//}
//System.out.println("*******************************************");
//****************************************
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_ReportZeroDesc03.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

doString str = new doString();
Calendar rightNow = Calendar.getInstance();
StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;
Statement stmt1 = null;
ResultSet rs1 = null;
SERV_CommonData common = null;

try {
	if (ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	stmt1 = conn.createStatement();
	common = new SERV_CommonData(conn);

	String r_type = doString.checkString(request.getParameter("r_type"),""); 
	String sel_time = doString.checkString(request.getParameter("sel_time"),"");  
	String type_amt = doString.checkString(request.getParameter("type_amt"),"A");
	String type_date = "", type_display = "", chk_prj = "";
	//String mainboq = "", subboq = "", seqboq = "";
	//String option = "", grp = "", typ = "", tb_name = "";
	String c_itmjob = "", d_query2 = "", itm_query = "", n_area = "", f_remark = "", n_group = "", ven_name = "";

	String d_query = doString.checkString(request.getParameter("d_query"),""); 
	String query = doString.checkString(request.getParameter("query"),"");  
	String i_itmjob = doString.checkString(request.getParameter("i_itm"),"");//item m
	String reportAll = doString.checkString(request.getParameter("flag_report"),"");
	String args1 = doString.checkString(request.getParameter("args1"),"");
	if(!"all".equals(reportAll)){
		if (i_itmjob.length() == 2) {
				itm_query = "and a.i_itmjob[1,2] = '"+i_itmjob+"' ";
		} else if (i_itmjob.length() == 4) {
				itm_query = "and a.i_itmjob[1,4] = '"+i_itmjob+"' ";
		} else {
				itm_query = "and a.i_itmjob = '"+i_itmjob+"' ";
		}
	}
	String d_start = doString.checkString(doString.DisplayThai(request.getParameter("d_start")),"");
	String d_end = doString.checkString(doString.DisplayThai(request.getParameter("d_end")),"");
	String type_rep = doString.checkString(request.getParameter("type_rep"),"");
	
	if (sel_time.equals("A")) {   // สรุปตามวันแจ้งซ่อม
		type_date = "แจ้งซ่อม";
	} else if (sel_time.equals("B")) {    //  สรุปตามวันที่โอน
		type_date = "โอน";
	}
		//----------------------------- Reason Type----------------------------- 
		 type_display = "";
		 sql.delete(0,sql.length());	
		 sql.append("select n_desc from lan:serv_xstd ")
			  .append("where i_type = '06' ")
			  .append("and i_code = '"+r_type+"' ");
		 servlog.startLog(sql.toString());
		 rs = stmt.executeQuery(sql.toString());
		 servlog.endLog();
		 if (rs.next()==true) {
			 type_display = doString.DisplayThai(doString.checkString(rs.getString("n_desc"),""));
		 } else {
			 type_display = "ทุกสาเหตุ";
		 }
		//------------------------- Group Name Item ---------------------	
		n_group = "";		
		if(!"all".equals(reportAll)){
			if(i_itmjob.length() >=2) { 
					sql.delete(0,sql.length());
					sql.append("select n_itmjob from lan:serv_boq ")
						 .append("where i_itmjob[1,2] = '"+i_itmjob.substring(0,2)+"' ");
					servlog.startLog(sql.toString());
					rs = stmt.executeQuery(sql.toString());
					//System.out.println("SQL #1:"+sql.toString());
					servlog.endLog();
					if (rs.next()) {
							n_group = doString.DisplayThai(doString.checkString(rs.getString("n_itmjob")));
					}		
			}
	  }	
%>
<HTML>
<HEAD>
<TITLE>สรุปรายงานรายละเอียด Zero Defect</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<META http-equiv="Content-Language" content="th">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<style >
.fg_style1 { mso-number-format:"\@";}
.col_name1{ 	font-size: 8.0pt ; color: rgb(0,50,200) ; /*text-align: right ; */ 
			/*background-image: url(images/col_bg1.gif) ; background-repeat : repeat-x ;*/
			border-right:1px solid rgb(135,185,247) ; border-bottom:1px solid rgb(135,185,247) ; 	}
</style>
<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<table border="0" width="100%" cellspacing="0" cellpadding="0" >
  <tr>
    <td width="100%" class="BD" >   
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">
          &nbsp; รายละเอียด Zero Defect</td>
          <td width="50%">&nbsp;</td>
        </tr>
        </table>
  
   
<br style="font-size:10pt">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">ที่มาของข้อมูล</td>
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
    <td class="item ; dotline01" height="22" width="15%">เดือน/ปี ที่<%=type_date%> :</td>
    <td width="160%" class="dotline01"><%=d_start%>&nbsp;&nbsp; ถึง&nbsp;&nbsp;<%=d_end%></td>
    </tr>
  <tr>
    <td width="15%" height="22" class="item ; dotline01">สาเหตุ : </td>
    <td width="85%" class="dotline01"><%=type_display%></td>
  </tr>
  <%

  String nProject = "";
 String projectDDL = doString.checkString(request.getParameter("projectDDL"),"");
 String []tempId = projectDDL.split("\\:");
  if("all".equals(reportAll)|| "true".equals(args1) || "false".equals(args1)){
    %>
     <tr>
	    <td width="15%" height="22" class="item ; dotline01">โครงการ  : </td>
	    <td class="dotline01">แสดงทุกโครงการที่เลือก</td>
	  </tr>
    <%
 }else{
		  sql.delete(0,sql.length()); 
		  sql.append(" select n_project from lan:acxprojt ")
			 .append(" where i_company='"+tempId[0]+"' ")
			 .append(" and i_project='"+tempId[1]+"'  ");
			 rs = stmt.executeQuery(sql.toString());
			 //System.out.println("SQL get Project Name thai:"+sql.toString());
			 if(rs.next()){
			     nProject = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
			 }rs.close();
		   %>
	  <tr>
	    <td width="15%" height="22" class="item ; dotline01">โครงการ  : </td>
	    <td class="dotline01"><%=tempId[0]+"-"+tempId[1]%> <%=nProject %></td>
	  </tr>
<%}%>
	  <tr>
	    <td width="15%" height="22" class="item ; dotline01">หมวด : </td>
	    <td class="dotline01"><%=n_group%></td>
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
                <td class="item_tab2" width="200">รายละเอียดการซ่อม</td>
                <td class="item_tab3"></td>
                <td>&nbsp;</td>
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
           <td width="2%" class="col_name">&nbsp;</td>
		   <td width="10%" class="col_name" height="22">เลขที่ใบแจ้งซ่อม</td>
           <td width="23%" class="col_name" height="22">หมายเหตุรายการซ่อม</td>
           <td width="6%" class="col_name" height="22">แปลง</td>
           <td width="8%" class="col_name" height="22">แบบบ้าน</td>
           <td width="13%" class="col_name" height="1">ผู้รับเหมา</td>
           <td width="11%" class="col_name" height="22">ค่าของ+ค่าแรง (รวมค่าดำเนินการ) </td>
           <td width="5%" class="col_name">เข้า<br>R8 </td>
           <td width="8%" class="col_name">บริเวณ</td>
           <td width="7%" class="col_name">สาเหตุ</td>
          <td width="7%" class="col_name">สถานะ</td>
        </tr>
 <%  
 	if("all".equals(reportAll)){
 	  //System.out.println(" case all project& all item. ");
 	    //case summary all project & all  item_job
 		sql.delete(0,sql.length());
 		sql.append(" select a.i_docno,a.i_itmjob,a.i_cause  ")
 	   		.append(" from lan:serv_zerodet a  where ")
 	   		.append(" a.i_rep_type = '"+type_rep+"' ");
 	        if(!r_type.equals("99")){
 	       	     sql.append(" and a.i_cause = '"+r_type+"'  ");
 	        }
 	        sql.append(" ").append(d_query)
 	           .append(" and ( ").append(query).append(" ) order by a.i_docno ");      
 	}else{
 			//System.out.println(" args1 = "+args1);
 	        if("true".equals(args1)){
 	            //System.out.println(" case by project& all item job  column X. ");
 	        	//case by project& all item job  column X
 	        	sql.delete(0,sql.length());
 					sql.append(" select a.i_docno,a.i_itmjob,a.i_cause  ")
			 	   .append(" from lan:serv_zerodet a ")
			 	   .append(" where a.i_company = '"+tempId[0]+"' and a.i_project = '"+tempId[1]+"'  ")
			 	   .append(" and a.i_rep_type = '"+type_rep+"' ");
			 	   if(!r_type.equals("99")){
			 	   	 sql.append(" and a.i_cause = '"+r_type+"'  ");
			 	   }
	        	   sql.append(" ").append(d_query).append(" order by a.i_docno  ");
 	        }else if("false".equals(args1)){
 	             //case by project& all item job  column Y
 	              //System.out.println(" case by project& all item job  column Y");
 	             String condition = "";
			 	if(i_itmjob.length()==2){//for main
			 		//System.out.println("TEST SQL : Case main ");
			 		condition = " and a.i_itmjob_main ='"+i_itmjob+"' and  a.i_itmjob_sub is not null  and a.i_itmjob_seq   is  not null  order by a.i_docno ";
			 	}else if(i_itmjob.length()==4){ //for sub
			 		//System.out.println("TEST SQL : Case sub ");
			 		condition = " and a.i_itmjob_main ='"+i_itmjob.substring(0,2)+"' and  a.i_itmjob_sub ='"+i_itmjob.substring(2,4)+"'  and a.i_itmjob_seq   is not null  order by a.i_docno ";	
			 	}else{
			 		//System.out.println("TEST SQL : Case seq detail ");
			 		condition = " and a.i_itmjob_main ='"+i_itmjob.substring(0,2)+"' and  a.i_itmjob_sub ='"+i_itmjob.substring(2,4)+"'   and a.i_itmjob_seq   ='"+i_itmjob.substring(4,i_itmjob.length())+"'   order by a.i_docno ";
			 	}	
			 	sql.delete(0,sql.length());
 		        sql.append(" select a.i_docno,a.i_itmjob,a.i_cause  ")
 	   		       .append(" from lan:serv_zerodet a  where ")
 	   		       .append(" a.i_rep_type = '"+type_rep+"' ");
 	               if(!r_type.equals("99")){
 	       	           sql.append(" and a.i_cause = '"+r_type+"'  ");
 	                }
 	              sql.append(" ").append(d_query)
 	                 .append(" and ( ").append(query).append(" ) ")
 	                 .append(condition);  
 	        }else{
 	        
 	           //System.out.println(" case by  project&item_job .");
 			   //case by  project&item_job
			 	String condition = "";
			 	if(i_itmjob.length()==2){//for main
			 		//System.out.println("TEST SQL : Case main ");
			 		condition = " and a.i_itmjob_main ='"+i_itmjob+"' and  a.i_itmjob_sub is not null  and a.i_itmjob_seq   is  not null  order by a.i_docno ";
			 	}else if(i_itmjob.length()==4){ //for sub
			 		//System.out.println("TEST SQL : Case sub ");
			 		condition = " and a.i_itmjob_main ='"+i_itmjob.substring(0,2)+"' and  a.i_itmjob_sub ='"+i_itmjob.substring(2,4)+"'  and a.i_itmjob_seq   is not null  order by a.i_docno ";	
			 	}else{
			 		//System.out.println("TEST SQL : Case seq detail ");
			 		condition = " and a.i_itmjob_main ='"+i_itmjob.substring(0,2)+"' and  a.i_itmjob_sub ='"+i_itmjob.substring(2,4)+"'   and a.i_itmjob_seq   ='"+i_itmjob.substring(4,i_itmjob.length())+"'   order by a.i_docno ";
			 	}		 
			 	sql.delete(0,sql.length());
			 	sql.append(" select a.i_docno,a.i_itmjob,a.i_cause  ")
			 	   .append(" from lan:serv_zerodet a ")
			 	   .append(" where a.i_company = '"+tempId[0]+"' and a.i_project = '"+tempId[1]+"'  ")
			 	   .append(" and a.i_rep_type = '"+type_rep+"' ");
			 	   if(!r_type.equals("99")){
			 	   	 sql.append(" and a.i_cause = '"+r_type+"'  ");
			 	   }
			 	   sql.append(d_query) //date month
			 	   .append(condition);
		 	   }
 	   }
 	   //System.out.println("1.SQL Main :"+sql.toString());
 	   rs = stmt.executeQuery(sql.toString());
 	  
	   //servlog.endLog();
	   int i = 1;
	   StringBuffer iDocNo = new StringBuffer();
	   StringBuffer itemJob = new StringBuffer();
	   StringBuffer iLock = new StringBuffer();
	   StringBuffer remarkName = new StringBuffer();
	   StringBuffer iModel = new StringBuffer();
	   //StringBuffer venderCode = new StringBuffer();
	   StringBuffer venderName = new StringBuffer();
	   StringBuffer jobAreaCode = new StringBuffer();
	   StringBuffer jobAreaName = new StringBuffer();
	   StringBuffer reasonCode = new StringBuffer();
	   StringBuffer reasonName = new StringBuffer();
	   double zPay = 0;
	   String fContr = "";
	   boolean isFlag = true;
	   boolean isRec =  true;
	  // String s = "";
	  while (rs.next()) {
	         isRec =  false;
	  		//***************************** 
	  		//Get i_lock
	  	    iDocNo.delete(0,iDocNo.length());
	  	    iDocNo.append(doString.checkString(rs.getString("i_docno")));
	  		
	  		sql.delete(0,sql.length());
 	        sql.append(" select i_lock from lan:serv_zerohd where  i_docno  = '"+iDocNo.toString()+"'  ");
 	        //System.out.println("Get I_Lock :"+sql.toString()); 
	  		rs1 = stmt1.executeQuery(sql.toString());
	  		iLock.delete(0,iLock.length());
	  		if(rs1.next()){
	  			iLock.delete(0,iLock.length());
	  		    iLock.append(doString.checkString(rs1.getString("i_lock"),""));
	  		}rs1.close();
	  		//**************************
	  		//Get Detail
	  		itemJob.delete(0,itemJob.length());
	  		itemJob.append(doString.checkString(rs.getString("i_itmjob"),""));	
			
			//*********
			reasonCode.delete(0,reasonCode.length());
	  		reasonCode.append(doString.checkString(rs.getString("i_cause"),""));   
			//System.out.println("----i_cause test:"+reasonCode.toString());		
		  	sql.delete(0,sql.length());
 	        sql.append(" select a.i_vendor,a.f_remark,a.i_itmjob_area,b.n_itmjob  from lan:serv_zerodt a ,lan:serv_boq  b  ")
 	        .append(" where  a.i_docno  = '"+iDocNo.toString()+"'   and a. i_itmjob   = '"+itemJob.toString()+"' ")
 	        .append(" and a.i_itmjob  = b.i_itmjob  ");
 	        //System.out.println("-->Get Detail :"+sql.toString()); 
	  		rs1 = stmt1.executeQuery(sql.toString());
	  		
	  		remarkName.delete(0,remarkName.length());
	  		jobAreaCode.delete(0,jobAreaCode.length());		
	  		if(rs1.next()){
	  			remarkName.delete(0,remarkName.length());
	  		    remarkName.append(doString.DisplayThai(doString.checkString(rs1.getString("n_itmjob"),""))); 
	  		   
	  		    jobAreaCode.delete(0,jobAreaCode.length());
	  		    jobAreaCode.append(doString.checkString(rs1.getString("i_itmjob_area"),""));
	  		}rs1.close();
	  		
	  		//***********************
	  		//Get I_MODEL
	  		sql.delete(0,sql.length());
	  		if("all".equals(reportAll) || "true".equals(args1) || "false".equals(args1) ){
	  		      tempId = iDocNo.toString().split("\\-");
	  		      sql.append(" select i_model  from lan:acxlckmd  where i_company = '"+tempId[0]+"'  and i_project = '"+tempId[1]+"'  and i_lock = '"+iLock.toString()+"'	"); 
	  		}else{
	  		      sql.append(" select i_model  from lan:acxlckmd  where i_company = '"+tempId[0]+"'  and i_project = '"+tempId[1]+"'  and i_lock = '"+iLock.toString()+"'	");
	  		     
	  		}
 	       	//System.out.println("Get I_MODEL :"+sql.toString()); 
	  		rs1 = stmt1.executeQuery(sql.toString());
	  		iModel.delete(0,iModel.length());
	  		if(rs1.next()){
	  			iModel.delete(0,iModel.length());
	  		    iModel.append(doString.checkString(rs1.getString("i_model"),""));
	  		}rs1.close();
	  		//*********************
	  		//--Get  Vender

	  		sql.delete(0,sql.length());
 	        sql.append("  select DISTINCT c.bus_name  from lan:serv_zerohd a,lan:unit b,lan:stpvendr c   ")
 	        .append(" where a.i_company = b.i_company  	and   a.i_project = b.i_project and   a.i_lock    = b.i_lock   and   b.unit_status = 'OPN'  and   b.ven_no  = c.vend_code  ")
 	        .append(" and  a.i_lock = '"+iLock.toString()+"' ")
 	        .append(" and  a.i_company = '"+tempId[0]+"'  and a.i_project = '"+tempId[1]+"' ");
 	       
 	        //System.out.println("Get Vender :"+sql.toString()); 
	  		rs1 = stmt1.executeQuery(sql.toString());
	  		venderName.delete(0,venderName.length());
	  		if(rs1.next()){
	  			venderName.delete(0,venderName.length());
	  			venderName.append(doString.DisplayThai(doString.checkString(rs1.getString("bus_name"),"")));
	  		}rs1.close();
	  		//************************
	  		//Get reason
	  		sql.delete(0,sql.length());
			sql.append(" select i_code,n_desc from lan:serv_xstd where i_type= '00' and i_code = '"+reasonCode.toString()+"' ");
			rs1 = stmt1.executeQuery(sql.toString());
	  		////System.out.println("Get reason :"+sql.toString()); 
	  		reasonName.delete(0,reasonName.length());
	  		if(rs1.next()){
	  			reasonName.delete(0,reasonName.length());
	  			reasonName.append(doString.DisplayThai(doString.checkString(rs1.getString("n_desc"),"")));
	  		}rs1.close();
	  		
	  		//************************
	  		//Get area
	  		sql.delete(0,sql.length());
			sql.append(" select i_code,n_desc from lan:serv_xstd where i_type= '01' and i_code = '"+jobAreaCode.toString()+"' ");
			rs1 = stmt1.executeQuery(sql.toString());
	  		//System.out.println("Get area :"+sql.toString()); 
	  		jobAreaName.delete(0,jobAreaName.length());
	  		if(rs1.next()){
	  			jobAreaName.delete(0,jobAreaName.length());
	  			jobAreaName.append(doString.DisplayThai(doString.checkString(rs1.getString("n_desc"),"")));
	  		}rs1.close();
	  		
	  		//************************
	  		//Get serv_payment,f_conftr,status OPN,CAN  
	  		 zPay = 0;
	  		 fContr = "";
	   		 isFlag = true;
	  		sql.delete(0,sql.length());
			sql.append(" select z_amount_pv,f_contr from lan:serv_payment ")
			.append(" where i_docno = '"+iDocNo.toString()+"' and i_itmjob   = '"+itemJob.toString()+"'  ");
			rs1 = stmt1.executeQuery(sql.toString());
	  		//System.out.println("Get serv_payment :"+sql.toString()); 
	  		if(rs1.next()){
				zPay = rs1.getDouble("z_amount_pv");
	  			fContr = doString.checkString(rs1.getString("f_contr"),"");
	  		}rs1.close();	
	  		
	  		sql.delete(0,sql.length());
			//sql.append(" select count(*) as cnt from lan:serv_docdt ")
			sql.append(" select * from lan:serv_docdt ")
			.append(" where i_docno = '"+iDocNo.toString()+"' and i_itmjob   = '"+itemJob.toString()+"' and f_itmstatus != 'CAN' ");
			rs1 = stmt1.executeQuery(sql.toString());
	  		//System.out.println("Get serv_payment :"+sql.toString()); 
	  		if(rs1.next()){
	  			isFlag = false;
	  		}rs1.close();	
  %>       
        <tr>
          <td width="2%" class="dotline ; item"><%=i++ %></td>
          <td width="10%" class="dotline ; item" height="25"><%=iDocNo.toString()%></td>
		  <td width="23%" class="dotline" align="left" height="25"><%=remarkName.toString() %></td>
          <td width="6%" class="dotline ; fg_style1" align="center" height="25" ><%out.println(iLock.toString());%>&nbsp;</td>
          <td width="8%" class="dotline" align="center" height="25"><%=iModel.toString() %></td>
          <td width="13%" class="dotline" align="left" height="25"><%=venderName.toString() %></td>
          <td width="11%" class="dotline ; fg_style1 ; col_name1" align="right" height="25"><%=doString.displayNumber("#,###.00",zPay) %>&nbsp;</td>
          <td width="5%" class="dotline" align="center"><%
          if(fContr.equals("")){out.println("N");}else{out.println(fContr);}
           %>&nbsp;</td>
          <td width="8%" class="dotline" align="left"><%=jobAreaName.toString() %>&nbsp;</td>
          <td width="7%" class="dotline" align="left"><%=reasonName.toString() %>&nbsp;</td>
		   <td width="7%" class="dotline" align="center">
		   <%
		       //System.out.println("isFlag :"+isFlag);
		      if(isFlag){out.println("CAN");
		      }else{out.println("OPN");}
		    %>
		   </td>
        </tr>
        <%
       }//End Main
        	
        if(isRec){
         %>
	        <tr>
	          <td colspan="11" class="dotline ; item" align="center"> ไม่พบข้อมูล</td>
	        </tr>  
       <%} %>
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


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
  <td width="5%">&nbsp;&nbsp;&nbsp; สถานะ </td>
  <td>* OPN = รายการปรกติ</td>
  </tr>
  <tr>
  <td width="5%">&nbsp;&nbsp;&nbsp;</td>
 <td>* CAN = ฝ่ายบริการยกเลิกรายการ</td>
  </tr>
</table>

<br style="font-size:10pt">

        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">&nbsp;

           <!-- <a href="#"><img border="0" src="images/act_print.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>            --></td>   
      	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:history.back()" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>  
        </table>  

    </td>   
    </tr>   
</table> 

<br style="font-size:30pt">

<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
  <tr><td width="100%" class="copyright" align="center">
  Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5  
  <br>ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>
  &nbsp;หรือ โทร. 0-2230-8279 (คุณประพัฒน์ ฝ่ายบริการ)&nbsp; 0-2230-8491-5 (ฝ่าย IT)  
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE> 
	
</BODY>

</HTML>
<%
	stmt.close();
	conn.close();
	stmt=null;
	conn=null;
} catch (Exception e) {
    System.out.println("ERROR SERV_ReportZeroDesc03.jsp  SQL: " + sql.toString());
	System.out.println("ERROR SERV_ReportZeroDesc03.jsp : " + e.getMessage());
	throw new ServletException(e.getMessage());
} finally {
	// Clean up.
	try {
		// synchronized(session) { 		
		//  session.removeAttribute("projList");
		//}
		if (rs != null) rs.close();
		if (stmt != null) stmt.close();
		if (rs1 != null) rs1.close();
		if (stmt1 != null) stmt1.close();
		if (conn != null) conn.close();
	}
	catch( SQLException ignore ){}
}
%>
