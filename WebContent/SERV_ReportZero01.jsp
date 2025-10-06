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
<%-- 
/**
 * JSP :implement for Zero Defect report
 * create by : pradoem wongkraso
 * date :2012.09.17
 * version : 1.0
 * description : this is class forQC Zero Defection 
 * 
 */
--%>
<%!	// Caching the DataSource - It is obtained in the jspInit() method
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
	
		private static String GenNextId2(int b){
        String temp=""+b;
        String newSp_id;
        switch(temp.length()){ 
           case 1: newSp_id="0"+temp; break;
           default:newSp_id=temp;
        }
        return newSp_id;
   } 
%>
<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_ReportZero01.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

doString str = new doString();
Calendar rightNow = Calendar.getInstance();
//String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);  //+543
String cur_year = Integer.toString(rightNow.get(Calendar.YEAR));//2014
String cur_Xmonth = Integer.toString(rightNow.get(Calendar.MONTH)+1);//0= JANURARY   ,11=DECEMBER
String cur_month = GenNextId2(Integer.parseInt(cur_Xmonth));
String cur_year3 = Integer.toString(rightNow.get(Calendar.YEAR)-3);  //+543 : cureent 2014-4 = 2010
int intCurentYearBack4 = Integer.parseInt(cur_year3);
//System.out.println("cur_month -->> :"+cur_month);
//System.out.println("xxxCur_month -->> :"+GenNextId2(Integer.parseInt(cur_month)));

String r_type = doString.checkString(request.getParameter("r_type"),"");
String sel_time = doString.checkString(request.getParameter("sel_time"),"A");
String option = "";

StringBuffer sql = new StringBuffer();
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;
SERV_CommonData common = null;

try {
	if (ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	common = new SERV_CommonData(conn);

	//===================== modified by sompoch 2009/10/13 ====================//
	//------------------------------------ Date Job -----------------------------------------
	String A_StartM = doString.checkString(request.getParameter("A_StartM"),cur_month);
	String A_StartY = doString.checkString(request.getParameter("A_StartY"),cur_year);
	String A_EndM = doString.checkString(request.getParameter("A_EndM"),cur_month);
	String A_EndY = doString.checkString(request.getParameter("A_EndY"),cur_year);
	//------------------------------------ Date Close Law ---------------------------------
	String B_StartM = doString.checkString(request.getParameter("B_StartM"),cur_month);
	String B_StartY = doString.checkString(request.getParameter("B_StartY"),cur_year);
	String B_EndM = doString.checkString(request.getParameter("B_EndM"),cur_month);
	String B_EndY = doString.checkString(request.getParameter("B_EndY"),cur_year);
	Vector projList = new Vector();
	String[] reqProj = request.getParameterValues("sel_proj");
	int line = 0;
    if (reqProj!=null) {
		  String proj = "";
		  for (int i=0;i<reqProj.length;i++) {		
				 proj = doString.checkString(reqProj[i],"");  		
				 if (proj.length()>=6) projList.addElement(proj);
		  } // end for
	  } // end if
	//=======================================================================//
%>
<HTML>
<HEAD>
<TITLE>รายงาน Zero Defect  สรุปตามวันที่โอน/วันที่แจ้ง</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
<!--
  function goReport() {
/*	 if (document.forms[0].A_StartM.value=="") {
		 alert(" กรุณาเลือกเดือน !");
		 document.forms[0].A_StartM.focus();
		 return false;
	 }
	 if (document.forms[0].year_report.value=="") {
		 alert(" กรุณาเลือกปี !");
		 document.forms[0].year_report.focus();
		 return false;
	 }
	 if (!document.forms[0].report_type[0].checked && !document.forms[0].report_type[1].checked && !document.forms[0].report_type[2].checked) {
		 alert(" กรุณาเลือกประเภท !");
		 document.forms[0].report_type[0].focus();
		 return false;
	 }
	 */
	 if (document.forms[0].sel_proj.options.length==0) {
		 alert(" กรุณาเลือกโครงการอย่างน้อย 1 โครงการ !");
		 return false;
	 }
	 if(document.forms[0].sel_proj.options.length>12){
	 	alert(" กรุณาเลือกโครงการสูงสุดได้ 12 โครงการเท่านั้น !");
	 	for (i = 0; i < document.forms[0].sel_proj.options.length; i++) {
		    document.forms[0].sel_proj.options[i].selected = true;
	    }
		return false;
	 }
	 for (i = 0; i < document.forms[0].sel_proj.options.length; i++) {
		document.forms[0].sel_proj.options[i].selected = true;
	 }
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_ReportZero02.jsp";
     document.forms[0].submit();
  }

function MoveSelect(FromBox, TargetBox, Type) {
	var ArrFromBox = new Array();
	var ArrTargetBox = new Array();
	var ArrLookup = new Array();
	for (i = 0; i < TargetBox.options.length; i++) {
		ArrLookup[TargetBox.options[i].text] = TargetBox.options[i].value;
		ArrTargetBox[i] = TargetBox.options[i].text;
	}
	var FromLen = 0;
	var TargetLen = ArrTargetBox.length;
	for(i = 0; i < FromBox.options.length; i++) {
		ArrLookup[FromBox.options[i].text] = FromBox.options[i].value;
		if (FromBox.options[i].value != "" && (Type == 'ALL' || (Type == 'SEL' && FromBox.options[i].selected))){
			ArrTargetBox[TargetLen] = FromBox.options[i].text;
			TargetLen++;
		} else {
			ArrFromBox[FromLen] = FromBox.options[i].text;
			FromLen++;
	   }
	}
	ArrFromBox.sort();
	ArrTargetBox.sort();
	FromBox.length = 0;
	TargetBox.length = 0;
	for(i = 0; i < ArrFromBox.length; i++) {
		var Box = new Option();
		Box.value = ArrLookup[ArrFromBox[i]];
		Box.text = ArrFromBox[i];
		FromBox[i] = Box;
	}
	for(i = 0; i < ArrTargetBox.length; i++) {
		var Box = new Option();
		Box.value = ArrLookup[ArrTargetBox[i]];
		Box.text = ArrTargetBox[i];
		TargetBox[i] = Box;
	}
}
//-->
</script>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM ACTION="SERV_Report10_1.jsp" METHOD="POST" name="frm">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >  
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">
         &nbsp;สรุปรายงาน Zero Defect  สรุปตามวันที่โอน/วันที่แจ้ง</td>
        </tr>
      </table>

<br style="font-size:10pt">
  <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">กรุณาเลือกช่วงเวลาและประเภทที่ต้องการ</td>
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
    <td class="item ; dotline01" height="22" width="20%"><input name="sel_time" type="radio" value="A" <%if (sel_time.equals("A")) { out.println("checked"); }%>>เดือน/ปี ที่แจ้งซ่อม :</td>
    <td width="80%" class="dotline01">
		<%=common.genMonthListbox("A_StartM",A_StartM," class='box' ")%>&nbsp;
		<%=common.genYearListbox("A_StartY",A_StartY," class='box' ",intCurentYearBack4,5)%>&nbsp;&nbsp; ถึง&nbsp;&nbsp;
		<%=common.genMonthListbox("A_EndM",A_EndM," class='box' ")%>&nbsp;
		<%=common.genYearListbox("A_EndY",A_EndY," class='box' ",intCurentYearBack4,5)%>
	</td>
 </tr>
 <tr>
    <td class="item ; dotline01" height="22" width="20%"><input name="sel_time" type="radio" value="B" <%if (sel_time.equals("B")) { out.println("checked"); }%>>เดือน/ปี ที่โอน :</td>
    <td width="80%" class="dotline01">
		<%=common.genMonthListbox("B_StartM",B_StartM," class='box' ")%>&nbsp;
		<%=common.genYearListbox("B_StartY",B_StartY," class='box' ",intCurentYearBack4,5)%> &nbsp;&nbsp; ถึง&nbsp;&nbsp;
		<%=common.genMonthListbox("B_EndM",B_EndM," class='box' ")%>&nbsp;
		<%=common.genYearListbox("B_EndY",B_EndY," class='box' ",intCurentYearBack4,5)%>
	</td>
 </tr>
 <tr>
    <td width="20%" height="22" class="item ; dotline01" style="padding-left:27px">สาเหตุ : </td>
    <td width="80%" class="dotline01"><select size="1" name="r_type" class="box" style="width:320px">
	<option value="99">ทุกสาเหตุ</option>
<%
//System.out.println("A_StartY :"+A_StartY);
//System.out.println("A_EndY :"+A_EndY);

//System.out.println("B_StartY :"+B_StartY);
//System.out.println("B_EndY :"+B_EndY);

		//----------------------------- Reason Type----------------------------- 
		 sql.delete(0,sql.length());	
		 sql.append("select * from lan:serv_xstd ")
			  .append("where i_type = '00' ")
			  .append("order by i_code ");
		 servlog.startLog(sql.toString());
		 rs = stmt.executeQuery(sql.toString());
		 servlog.endLog();
		 while (rs.next()) {
		 option = "";			
				if (r_type.equals(doString.checkString(rs.getString("i_code")))) {
					option = " Selected ";
				} // End if
%>
	<option value="<%=doString.checkString(rs.getString("i_code"))%>"<%=option%>><%=doString.checkString(doString.DisplayThai(rs.getString("n_desc")))%></option>
<%
	} // End while
%>
</select></td>
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

<br style="font-size:2pt">

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
          <td class="col_name" width="45%">โครงการทั้งหมด</td>
          <td class="col_name" width="10%">&nbsp;</td>
          <td class="col_name" width="45%">โครงการที่เลือก</td>
        </tr>
        <tr>
          <td class="dotline" align="center" width="45%" rowspan="6" style="padding:15px 0px 15px 0px"><span class="dotline" style="padding:15px 0px 15px 0px">            
			<select size="15" name="all_proj" multiple class="box" style="width:300px" ondblclick="MoveSelect(frm.all_proj, frm.sel_proj,'SEL');">			
					<%  //update 2013.05.02
						 boolean allProj = false;
						 //String tlbServ = "serv_pstaff"; 
						//---================ Normal User ===============----//
						sql.delete(0,sql.length());	
						sql.append(" select user_id  from lan:serv_staffqc  ")
						  .append(" where user_id='").append(user.getUserID()).append("' ");
						 // System.out.println("SQL 1:"+sql.toString());
						 rs = stmt.executeQuery(sql.toString());
						 
						 //--------------------------------- SQL project main 1
						 sql.delete(0,sql.length());	
						 sql.append(" select distinct a.com_id as comId,a.proj_id as projId,b.n_project from lan:serv_pstaff a  ")
							   .append(" left join lan:acxprojt b on b.i_company=a.com_id and b.i_project=a.proj_id ")
							   .append(" where a.user_id='").append(user.getUserID()).append("' ")
							   .append(" order by a.com_id , a.proj_id ");
							  // System.out.println("SQL 2:"+sql.toString());
						 //---------------------------------
						 if(rs.next()){
						  //SQL project main 2
						  sql.delete(0,sql.length());	
						  sql.append(" select distinct a.i_company as comId,a.i_project as projId,b.n_project from lan:serv_staffqc a  ")
							   .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
							   .append(" where a.user_id='").append(user.getUserID()).append("' ")
							   .append(" order by a.i_company , a.i_project ");
							   //System.out.println("SQL 2:"+sql.toString());
						 }rs = null; 
						//--------------------------
	
						 servlog.startLog(sql.toString());
						 rs = stmt.executeQuery(sql.toString());
						 servlog.endLog();
						 while (rs.next()) {
							 String comId = doString.checkString(rs.getString("comId"),"");
							 String projId = doString.checkString(rs.getString("projId"),"");
							 String nProj = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
							 if (projId.equalsIgnoreCase("ALL")) {
							%>
							<!-- <option value='LH:ALL'>--------------เลือกทุกโครงการ--------------</option> -->
							<% 
								allProj = true;
								break;
							 }
							if (projList.size()<=0 || !projList.contains(comId+":"+projId)) {
								%><option value='<%=comId+":"+projId%>'><%="["+comId+"-"+projId+"] - "+nProj%></option><%
							}
						 }
						 rs.close();
						//---============== For user who have ALL Project ===============----//
						if (allProj) {
							 int year = Calendar.getInstance().get(Calendar.YEAR);
							 if (year<2400) year += 543;
							 int pYear = year-1;

							sql.delete(0,sql.length());	
							 sql.append(" select distinct a.i_company,a.i_project,b.n_project from lan:acsbudgh a  ")
								   .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
								   .append(" where a.d_year in ( '").append(year).append("' , '").append(pYear).append("' ) ")
								   .append(" and a.i_budg_type in (9)  ")
								   .append(" order by a.i_company , a.i_project ");
							 servlog.startLog(sql.toString());
							 rs = stmt.executeQuery(sql.toString());
							 servlog.endLog();
							 while (rs.next()) {
								 String comId = doString.checkString(rs.getString("i_company"),"");
								 String projId = doString.checkString(rs.getString("i_project"),"");
								 String nProj = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");

								 if (projId.equalsIgnoreCase("ALL")) {						
									 allProj = true;
									 break;
								 }
								 if (projList.size()<=0 || !projList.contains(comId+":"+projId)) {
								 	 %><option value='<%=comId+":"+projId%>'><%="["+comId+"-"+projId+"] - "+nProj%></option><%
								 }
							 }
							 rs.close();
						}


					%>
				 </select></span></td>
          <td align="center" class="dotline" width="10%">&nbsp;</td>
          <td align="center" class="dotline" width="45%" rowspan="6" style="padding:15px 0px 15px 0px">
		  <select size="15" name="sel_proj" multiple class="box" style="width:300px" ondblclick="MoveSelect(frm.sel_proj, frm.all_proj,'SEL');">
		  <%
			String selProj = "";
			String comId = "";
			String projId = "";
			String nProj = "";

			for (int i=0;i<projList.size();i++) {
					selProj = (String) projList.elementAt(i);
					comId = selProj.substring(0,2);
					projId = selProj.substring(3,6);

					sql.delete(0,sql.length());	
					 sql.append(" select n_project from lan:acxprojt ")
						   .append(" where i_company='").append(comId).append("' ")
						   .append(" and i_project='").append(projId).append("' ");
					 servlog.startLog(sql.toString());
					 rs = stmt.executeQuery(sql.toString());
					 servlog.endLog();
					 if (rs.next()) {
						 nProj = doString.DisplayThai(doString.checkString(rs.getString("n_project"),""));
					 }
					 rs.close();

				   %><option value='<%=selProj%>'><%="["+comId+"-"+projId+"] - "+nProj%></option><%
			} // end for
		   %>
            &nbsp; </select>
			</td>
        </tr>
        <tr>
          <td align="center" class="dotline" width="10%"><a href="javascript:MoveSelect(frm.all_proj, frm.sel_proj,'SEL')"><img border="0" src="images/bu_R.gif" style="cursor:hand" alt="Add" width="16" height="16"></td>
        </tr>
        <tr>
          <td align="center" class="dotline" width="10%"> <a href="javascript:MoveSelect(frm.all_proj, frm.sel_proj,'ALL')"><img border="0" src="images/bu_RR.gif" style="cursor:hand" alt="Add All" width="16" height="16"></td>
        </tr>
        <tr>
          <td align="center" class="dotline" width="10%"><a href="javascript:MoveSelect(frm.sel_proj, frm.all_proj,'SEL')"><img border="0" src="images/bu_L.gif" style="cursor:hand" alt="Remove" width="16" height="16"></td>
        </tr>
        <tr>
          <td align="center" class="dotline" width="10%"><a href="javascript:MoveSelect(frm.sel_proj, frm.all_proj,'ALL')"><img border="0" src="images/bu_LL.gif" style="cursor:hand" alt="Remove All" width="16" height="16"></td>
        </tr>
        <tr>
          <td align="center" class="dotline" width="10%">&nbsp;</td>
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
            <td width="75" class="act_tab2">
            <a href="#" onclick="javascript:goReport();"><img border="0" src="images/act_submit.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a></td>   
            	
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
	System.out.println("ERROR SERV_Report10.jsp : " + e.getMessage());
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
