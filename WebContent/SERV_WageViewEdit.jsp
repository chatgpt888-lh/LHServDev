<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%//@ include file="confirmLogin.jsp" %>
<%!
	// Caching the DataSource - It is obtained in the jspInit() method	
	private javax.sql.DataSource ds = null;
	private String dsName = Constants.JDBC_LAN;
	private String month[] = {"เดือน","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
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
		try
		{
			getDS();
		}
		catch(Exception es)
		{
		  es.printStackTrace();
		}
	}
%>
<%
String jName = "SERV_WageViewEdit.jsp";
//ServLog servlog = new ServLog(sessionId, userId, jName);

    String month[] = {"เดือน","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};   
   	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();   
		stmt1 = conn.createStatement();   
        //----=======================================----//   
Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
int cur_date = rightNow.get(Calendar.DATE);

int day1 = 0;
if (request.getParameter("day1") != null ){
		day1 = Integer.parseInt(doString.checkString(request.getParameter("day1")));
} 
String project = "";
if (request.getParameter("project") != null) {
		project = doString.checkString(request.getParameter("project"));
} 
String i_company = "", i_project = "";
if (!project.equals("")) {
		i_company = project.substring(0, 2);
		i_project = project.substring(2);
} // End if
/*String chkDate = "";
if (request.getParameter("chkDate") != null) {
		chkDate = doString.checkString(request.getParameter("chkDate"));
} */
int MM = 0;
String M_MM = "";
if (request.getParameter("MM") != null) {
		MM = Integer.parseInt(doString.checkString(request.getParameter("MM")));
} 
if(MM<=9) {
     M_MM = "0"+Integer.toString(MM);
} else {
	M_MM = Integer.toString(MM);
}

int MM1 = 0;
String M_MM1 = "";
if (request.getParameter("MM1") != null) {
		MM1 = Integer.parseInt(doString.checkString(request.getParameter("MM1")));
} 
if(MM1<=9) {
     M_MM1 = "0"+Integer.toString(MM1);
} else {
	M_MM1 = Integer.toString(MM1);
}


int YY = 2558;
if (request.getParameter("YY") != null) {
		YY = Integer.parseInt(doString.checkString(request.getParameter("YY")));
} 
int YY1 = 2557;
if (request.getParameter("YY1") != null) {
		YY1 = Integer.parseInt(doString.checkString(request.getParameter("YY1")));
} 
String card_no = "";
if (request.getParameter("card_no") != null) {
		card_no = doString.checkString(request.getParameter("card_no"));
} 
String checkinedit = "";
if (request.getParameter("checkinedit") != null) {
		checkinedit = doString.checkString(request.getParameter("checkinedit"));
} 
String checkoutedit = "";
if (request.getParameter("checkoutedit") != null) {
		checkoutedit = doString.checkString(request.getParameter("checkoutedit"));
} 
int i = 0, line = 0;
String 	i_date = "",	i_checkin = "", i_checkout = "";
String i_name = "";
String checkin = "", checkout = "";
String temp = "", code = "", docno = ""; 
String DD = "", DD1 = "", n_status = "";
String i_checkin_new = "", i_checkout_new = "";
String checkin_h = "", checkin_m = "", checkout_h = "", checkout_m = "", i_comment = "";




%>
<HTML>

<HEAD>

<TITLE>Home</TITLE>

<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">

<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">

<script language="javascript" src="script_fx.js"></script>

<style type="text/css"> 

.hidden-class { display:none;  } 

.show-class { display:compact;    } 

</style>




<script language="javascript">

<!-- 

function initPage(){ 

if(document.frmSERV.hide_detail.value == 'N') { 

showDetail(); 

} 

if(document.frmSERV.hide_detail.value == 'Y'){ 

hideDetail(); 

} 

}

function gotoOpenJob(i_docno){

var form = document.frmSERV;

form.i_docno.value = i_docno;

form.edit.value = 'no'; 



form.action = '/LHServ/SERV_OpenJob_Follow.jsp'; 



form.submit();

}

function sortBy(theCol){

var form = document.frmSERV;

form.sort_col.value = theCol;

form.submit();

}

function showDetail(){ 

var elements = getElementsByClass('hidden-class'); 

for (i = 0 ; i < elements.length ; i++ ) { 

elements[i].className = 'show-class'; 

} 

document.frmSERV.hide_detail.value = 'N'; 

} 

function hideDetail(){ 

var elements = getElementsByClass('show-class'); 

for (i = 0 ; i < elements.length ; i++ ) { 

elements[i].className = 'hidden-class'; 

} 

document.frmSERV.hide_detail.value = 'Y'; 

} 

function getElementsByClass( searchClass, domNode, tagName) { 

if (domNode == null) domNode = document; 

if (tagName == null) tagName = '*'; 

var el = new Array(); 

var tags = domNode.getElementsByTagName(tagName); 

var tcl = " "+searchClass+" "; 

for(i=0,j=0; i<tags.length; i++) { 

var test = " " + tags[i].className + " "; 

if (test.indexOf(tcl) != -1) 

el[j++] = tags[i]; 

} 

return el; 

} 

//-->

</script>
<base target="_self">
<SCRIPT language="JavaScript">
<!--
function chkValue(sta) { 

	if (frmSERV.chkDate.checked == "false") {
		alert("โปรดระบุวันที่ต้องการเปลี่ยนเวลา  หรือลบวันทำงาน");
	} else {
			frmSERV.action ="/LHServ/SERV_WageAppr?status="+sta;
			frmSERV.submit();
	} // End if

} // End function

function chkAll() { 
	result = frmSERV.chk_all.checked;
	for (i = 0 ; i < frmSERV.length; i++) {
		if (frmSERV.elements[i].type == "checkbox") {
			frmSERV.elements[i].checked = result;
		} // End if
	} // End for
} // End function

function chgchk(tf) { 
	if (!tf) {
		frmSERV.chk_all.checked = false;
	}
} // End function

//-->
</SCRIPT>
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onLoad="initPage()">
<FORM NAME="frmSERV" METHOD=POST ACTION="SERV_WageViewEdit.jsp">
<input type="hidden" name="i_docno" value="" />

<input type="hidden" name="edit" value="" />

<input type="hidden" name="sort_col" value="default" />

<input type="hidden" name="i_company" value="LH" />

<input type="hidden" name="i_project" value="080" />

<input type="hidden" name="d_keyin_beg" value="" />

<input type="hidden" name="d_keyin_end" value="" />

<input type="hidden" name="itmtype" value="4.1" /> 

<input type="hidden" name="hide_detail" value="Y" />




<table border="0" width="100%" cellspacing="0" cellpadding="0">

<tr>

<td width="100%" align="center" class="BD">






<table border="0" width="100%" cellspacing="0" cellpadding="0">

<tr>

<td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;

ค่าแรงช่าง และค่าแรงคนงาน</td>


</tr>

</table>







<br style="font-size:10pt">




            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="220">รายละเอียด</td>
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
<%
		sql.delete(0, sql.length());
		sql.append("SELECT max(s_doc)+1 as s_lastno FROM lan:serv_cntrl ") 
		     .append("WHERE i_company = '"+i_company+"' ")
			 .append("AND i_project = '"+i_project+"' ")
			 .append("AND i_doc_type = 'F' ")
			 .append("AND d_year = '"+YY+"' ");
		rs = stmt.executeQuery(sql.toString());
		if (rs.next() == true) {
			if(rs.getInt("s_lastno") ==0) {
				docno = "FC-"+project+"-"+Integer.toString(YY).substring(2,4)+"-"+"001";
		
			} else {  
				docno = "FC-"+project+"-"+Integer.toString(YY).substring(2,4)+"-"+doString.displayNumber("000", rs.getInt("s_lastno"));
			
			}
  	   }  // end if rs

	
%>
  <tr>
    <td class="item ; dotline01" height="22" width="22%">เลขที่เอกสาร : </td>
    <td height="22" width="35%" class="dotline01"><%=docno%></td>
    <td height="22" class="item ; dotline01" width="6%">เดือน :</td>
    <td height="22" width="12%" class="dotline01"><%=month[MM]%></td>
    <td width="3%" class="item ; dotline01">ปี :</td>
    <td width="22%" class="dotline01"><%=YY%></td>
  </tr>
<%
   sql.delete(0,sql.length());	
   sql.append("select distinct i_name ")
		.append("from lan:serv_tstaff ")
        .append("where i_cardno = '"+card_no+"' ");
	rs = stmt.executeQuery(sql.toString());					
    if (rs.next()==true) {
		i_name = doString.checkString(doString.DisplayThai(rs.getString("i_name")));
	}
%>
<input type="hidden" name="card_no" value="<%=card_no%>">
<input type="hidden" name="i_name" value="<%=i_name%>">
<input type="hidden" name="MM" value="<%=MM%>">
<input type="hidden" name="YY" value="<%=YY%>">
<input type="hidden" name="docno" value="<%=docno%>">
<input type="hidden" name="project" value="<%=project%>">




  <tr>
    <td class="item ; dotline01" height="22">เลขที่บัตรประชาชน / Passport
      :</td>
    <td height="22" class="dotline01"><%=card_no%></td>
    <td height="22" class="item ; dotline01">ชื่อ
      :</td>
    <td height="22" colspan="3" class="dotline01"><%=i_name%></td>
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

<td valign="bottom" class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>

<td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>

</tr>

</table>







<table border="0" width="100%" cellspacing="0" cellpadding="0">










<tr>

<td width="100%" class="frmL" align="center">

<table border="0" width="100%" cellspacing="0" cellpadding="0">

<tr>
<td width="4%" class="col_name">
  &nbsp;</td> 
<td width="10%" class="col_name"><a href="#">วันที่</a></td>
<td width="12%" class="col_name"><a href="#">เวลาเข้างานจริง</a></td>
<td width="12%" class="col_name"><a href="#">เวลาออกงานจริง</a></td>
<td width="14%" class="col_name"><a href="#">เวลาเข้างาน (แก้ไข)</a></td>
<td width="14%" class="col_name"><a href="#">เวลาออกงาน (แก้ไข)</a></td>
<td width="22%" class="col_name"><a href="#">หมายเหตุ</a></td>
<td width="16%" class="col_name"><a href="#">สถานะ</a></td>
</tr>
<%
line = 0;
for (int dd = 21;dd <= day1;dd++) {  // 21 -31
			line++;
			i_date = "";
			i_checkin = "-";
			i_checkout = "-";
			checkin = "-";
			checkout = "-";

   sql.delete(0,sql.length());	
   sql.append("select distinct i_name, i_cardno, i_date, i_checkin, i_checkout ")
		.append("from lan:serv_finger ")
		.append("where i_header= '"+project+"' ")
		.append("and month(i_date) = '"+MM1+"' ")
		.append("and year(i_date) = '"+(YY1-543)+"' ")
	    .append("and day(i_date) = '"+dd+"' ")
	    .append("and i_cardno = '"+card_no+"' ")
		.append("order by i_name ");
   //out.println(sql.toString());					
	rs = stmt.executeQuery(sql.toString());					
    if (rs.next()==true) {
			i_date = doString.checkString(rs.getString("i_date"));
			i_checkin = doString.checkString(rs.getString("i_checkin"),"-");
			i_checkout = doString.checkString(rs.getString("i_checkout"),"-");
	} // end if
		if (!i_checkin.equals("-")) {
			checkin = i_checkin.substring(11);
		}
		if (!i_checkout.equals("-")) {
			checkout = i_checkout.substring(11);
		}

		if(dd<=9) {
			DD = "0"+Integer.toString(dd);
		} else {
			DD = Integer.toString(dd);
		}


   n_status = "-";
   i_checkin_new = "-";
   i_checkout_new = "-";
   checkin_h = "";
   checkin_m = "";
   checkout_h = "";
   checkout_m = "";
   i_comment = "-";


   sql.delete(0,sql.length());	
   sql.append("select distinct a.status, b.i_date, a.d_keyin, b.i_checkin_new, b.i_checkout_new, b.i_comment ")
		.append("from lan:serv_fingerhd a, lan:serv_fingerdt b ")
		.append("where a.i_docno = b.i_docno ")
		.append("and a.id_card = '"+card_no+"' ")
		.append("and b.i_date = '"+Integer.toString(YY1-543)+M_MM1+DD+"' ")
		.append("order by a.d_keyin desc ");
	rs1 = stmt1.executeQuery(sql.toString());					
    if (rs1.next()==true) {
		n_status = doString.checkString(rs1.getString("status"));
		i_checkin_new = doString.checkString(rs1.getString("i_checkin_new"), "-");
		i_checkout_new = doString.checkString(rs1.getString("i_checkout_new"), "-");
		i_comment = doString.checkString(doString.DisplayThai(rs1.getString("i_comment")),"-");

	}
	
	if (!i_checkin_new.equals("-")) {    
		checkin_h = i_checkin_new.substring(0,2);
		checkin_m = i_checkin_new.substring(3,5);
	}
	if (!i_checkout_new.equals("-")) {    
		checkout_h = i_checkout_new.substring(0,2);
		checkout_m = i_checkout_new.substring(3,5);
	}

/*out.println("checkin_h=="+checkin_h);
out.println("checkin_m=="+checkin_m);

out.println("checkout_h=="+checkout_h);
out.println("checkout_m=="+checkout_m);*/


if (checkin_h.equals("")) {
	checkin_h = doString.checkString(request.getParameter("checkinedit_h"+DD+"/"+M_MM1+"/"+YY1), "00");	
}
if (checkin_m.equals("")) {
	checkin_m = doString.checkString(request.getParameter("checkinedit_m"+DD+"/"+M_MM1+"/"+YY1), "00");	
}
if (checkout_h.equals("")) {
	checkout_h = doString.checkString(request.getParameter("checkinout_h"+DD+"/"+M_MM1+"/"+YY1), "00");	
}
if (checkout_m.equals("")) {
	checkout_m = doString.checkString(request.getParameter("checkinout_m"+DD+"/"+M_MM1+"/"+YY1), "00");	
}


//out.println("checkinedit=="+checkinedit);
//checkinedit = "08";


%>
<tr>
<td class="dotline" align="center">&nbsp;</td> 
<td align="center" class="dotline ; item" ><%=DD%>/<%=M_MM1%>/<%=YY1%></td>
<td class="dotline" align="center"><%=checkin%></td>
<td class="dotline" align="center"><%=checkout%></td>
<input type="hidden" name="checkin<%=DD%>/<%=M_MM1%>/<%=YY1%>" value="<%=checkin%>">
<input type="hidden" name="checkout<%=DD%>/<%=M_MM1%>/<%=YY1%>" value="<%=checkout%>">
<td class="dotline" align="center"><select size="1" name='checkinedit_h<%=DD%>/<%=M_MM1%>/<%=YY1%>' class='box' style='width:38px'>  

<%
			for(i=0;  i < 25;  i++ ) {
			  temp = "";
				if(i<=9)
					code = "0" + Integer.toString(i);
				else
					code = Integer.toString(i);
			
				if (code.equals(checkin_h)) {
						temp = "selected";
				} // End If
%><OPTION value="<%=code%>"<%=temp%>><%=code%></OPTION>
<%    }// End For   	%></select> : <select size="1" name='checkinedit_m<%=DD%>/<%=M_MM1%>/<%=YY1%>' class='box' style='width:38px'>   

<%
			for(i=0;  i <= 59;  i++ ) {
			  temp = "";
				if(i<=9)
					code = "0" + Integer.toString(i);
				else
					code = Integer.toString(i);
			
				if (code.equals(checkin_m)) {
						temp = "selected";
				} // End If
%><OPTION value="<%=code%>"<%=temp%>><%=code%></OPTION>
<%    }// End For   	%></select></td>
<td class="dotline" align="center"><select size="1" name='checkinout_h<%=DD%>/<%=M_MM1%>/<%=YY1%>' class='box' style='width:38px'>   

<%
			for(i=0;  i < 25;  i++ ) {
			  temp = "";
				if(i<=9)
					code = "0" + Integer.toString(i);
				else
					code = Integer.toString(i);
			
				if (code.equals(checkout_h)) {
						temp = "selected";
				} // End If
%><OPTION value="<%=code%>"<%=temp%>><%=code%></OPTION>
<%    }// End For   	%></select> : <select size="1" name='checkinout_m<%=DD%>/<%=M_MM1%>/<%=YY1%>' class='box' style='width:38px'>   

<%
			for(i=0;  i <= 59;  i++ ) {
			  temp = "";
				if(i<=9)
					code = "0" + Integer.toString(i);
				else
					code = Integer.toString(i);
			
				if (code.equals(checkout_m)) {
						temp = "selected";
				} // End If
%><OPTION value="<%=code%>"<%=temp%>><%=code%></OPTION>
<%    }// End For   	%></select></td>
<td class="dotline" align="center"><%=i_comment%></td>
<td class="dotline" align="center"><%=n_status%></td>
</tr>
<%
	
	} // end for
	for (int ed = 1;ed <= 20;ed++) {  //1 - 20
			line++;
			i_date = "";
			i_checkin = "-";
			i_checkout = "-";
			checkin = "-";
			checkout = "-";

   sql.delete(0,sql.length());	
   sql.append("select distinct i_name, i_cardno, i_date, i_checkin, i_checkout ")
		.append("from lan:serv_finger ")
		.append("where i_header= '"+project+"' ")
		.append("and month(i_date) = '"+MM+"' ")
		.append("and year(i_date) = '"+(YY-543)+"' ")
	    .append("and day(i_date) = '"+ed+"' ")
	    .append("and i_cardno = '"+card_no+"' ")
		.append("order by i_name ");
   //out.println(sql.toString());					
	rs = stmt.executeQuery(sql.toString());					
    if (rs.next()==true) {
			i_date = doString.checkString(rs.getString("i_date"));
			i_checkin = doString.checkString(rs.getString("i_checkin"),"-");
			i_checkout = doString.checkString(rs.getString("i_checkout"),"-");
	} // end if
//	27/12/2014 08:35

		if (!i_checkin.equals("-")) {
			checkin = i_checkin.substring(11);
		}
		if (!i_checkout.equals("-")) {
			checkout = i_checkout.substring(11);
		}
		if(ed<=9) {
			DD1 = "0"+Integer.toString(ed);
		} else {
			DD1 = Integer.toString(ed);
		}



/*   n_status = "-";
   sql.delete(0,sql.length());	
   sql.append("select distinct a.status, b.i_date, a.d_keyin ")
		.append("from lan:serv_fingerhd a, lan:serv_fingerdt b ")
		.append("where a.i_docno = b.i_docno ")
		.append("and a.id_card = '"+card_no+"' ")
		.append("and b.i_date = '"+Integer.toString(YY-543)+M_MM+DD1+"' ")
		.append("order by a.d_keyin desc ");
	rs1 = stmt1.executeQuery(sql.toString());					
    if (rs1.next()==true) {
		n_status = doString.checkString(rs1.getString("status"));
	}
*/
//------------
	n_status = "-";
   i_checkin_new = "-";
   i_checkout_new = "-";
   checkin_h = "";
   checkin_m = "";
   checkout_h = "";
   checkout_m = "";
   i_comment = "-";


   sql.delete(0,sql.length());	
   sql.append("select distinct a.status, b.i_date, a.d_keyin, b.i_checkin_new, b.i_checkout_new, b.i_comment ")
		.append("from lan:serv_fingerhd a, lan:serv_fingerdt b ")
		.append("where a.i_docno = b.i_docno ")
		.append("and a.id_card = '"+card_no+"' ")
		.append("and b.i_date = '"+Integer.toString(YY-543)+M_MM+DD1+"' ")
		.append("order by a.d_keyin desc ");
	rs1 = stmt1.executeQuery(sql.toString());					
    if (rs1.next()==true) {
		n_status = doString.checkString(rs1.getString("status"));
		i_checkin_new = doString.checkString(rs1.getString("i_checkin_new"), "-");
		i_checkout_new = doString.checkString(rs1.getString("i_checkout_new"), "-");
		i_comment = doString.checkString(doString.DisplayThai(rs1.getString("i_comment")),"-");

	}
	
	if (!i_checkin_new.equals("-")) {    
		checkin_h = i_checkin_new.substring(0,2);
		checkin_m = i_checkin_new.substring(3,5);
	}
	if (!i_checkout_new.equals("-")) {    
		checkout_h = i_checkout_new.substring(0,2);
		checkout_m = i_checkout_new.substring(3,5);
	}


if (checkin_h.equals("")) {
	checkin_h = doString.checkString(request.getParameter("checkinedit_h"+DD1+"/"+M_MM+"/"+YY), "00");	
}
if (checkin_m.equals("")) {
	checkin_m = doString.checkString(request.getParameter("checkinedit_m"+DD1+"/"+M_MM+"/"+YY), "00");	
}
if (checkout_h.equals("")) {
	checkout_h = doString.checkString(request.getParameter("checkinout_h"+DD1+"/"+M_MM+"/"+YY), "00");	
}
if (checkout_m.equals("")) {
	checkout_m = doString.checkString(request.getParameter("checkinout_m"+DD1+"/"+M_MM+"/"+YY), "00");	
}



//-------------

%>
<tr>
<td class="dotline" align="center">&nbsp;</td> 
<td align="center" class="dotline ; item" ><%=DD1%>/<%=M_MM%>/<%=YY%></td>
<td class="dotline" align="center"><%=checkin%></td>
<td class="dotline" align="center"><%=checkout%></td>
<input type="hidden" name="checkin<%=DD1%>/<%=M_MM%>/<%=YY%>" value="<%=checkin%>">
<input type="hidden" name="checkout<%=DD1%>/<%=M_MM%>/<%=YY%>" value="<%=checkout%>">
<td class="dotline" align="center"><select size="1" name='checkinedit_h<%=DD1%>/<%=M_MM%>/<%=YY%>' class='box' style='width:38px'>   
<%
			for(i=0;  i < 25;  i++ ) {
			  temp = "";
				if(i<=9)
					code = "0" + Integer.toString(i);
				else
					code = Integer.toString(i);
			
				if (code.equals(checkin_h)) {
						temp = "selected";
				} // End If
%><OPTION value="<%=code%>"<%=temp%>><%=code%></OPTION>
<%    }// End For   	%></select> : <select size="1" name='checkinedit_m<%=DD1%>/<%=M_MM%>/<%=YY%>' class='box' style='width:38px'>   

<%
			for(i=0;  i <= 59;  i++ ) {
			  temp = "";
				if(i<=9)
					code = "0" + Integer.toString(i);
				else
					code = Integer.toString(i);
			
				if (code.equals(checkin_m)) {
						temp = "selected";
				} // End If
%><OPTION value="<%=code%>"<%=temp%>><%=code%></OPTION>
<%    }// End For   	%></select></td>
<td class="dotline" align="center"><select size="1" name='checkinout_h<%=DD1%>/<%=M_MM%>/<%=YY%>' class='box' style='width:38px'>   

<%
			for(i=0;  i < 25;  i++ ) {
			  temp = "";
				if(i<=9)
					code = "0" + Integer.toString(i);
				else
					code = Integer.toString(i);
			
				if (code.equals(checkout_h)) {
						temp = "selected";
				} // End If
%><OPTION value="<%=code%>"<%=temp%>><%=code%></OPTION>
<%    }// End For   	%></select> : <select size="1" name='checkinout_m<%=DD1%>/<%=M_MM%>/<%=YY%>' class='box' style='width:38px'>   

<%
			for(i=0;  i <= 59;  i++ ) {
			  temp = "";
				if(i<=9)
					code = "0" + Integer.toString(i);
				else
					code = Integer.toString(i);
			
				if (code.equals(checkout_m)) {
						temp = "selected";
				} // End If
%><OPTION value="<%=code%>"<%=temp%>><%=code%></OPTION>
<%    }// End For   	%></select></td>
<td class="dotline" align="center"><%=i_comment%></td>

<td class="dotline" align="center"><%=n_status%></td>
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

<br style="font-size:5pt">


<table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">

<tr>

<td class="act_tab1"></td>

<td width="230" class="act_tab2">
<!-- 
 <A href="javascript:chkValue('OPN')"><img border="0" src="images/act_send2app.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp;
 <A href="javascript:chkValue('DEL')"><img border="0" src="images/act_delete.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
                   
<A href="javascript:chkValue('APV')"><img border="0" src="images/act_approve.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>

<A href="javascript:chkValue('CAN')"><img border="0" src="images/act_deny.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>            
-->					
                     </td> 

<td class="act_tab3"></td> 

<td class="act_tab4"><a href="javascript:history.back()" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;

<a href="/LHServ/SERV_WageHome.jsp" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td> 

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
		System.out.println("ERROR SERV_WageViewEdit.jsp : " + e.getMessage());
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
