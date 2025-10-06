<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.*" %>
<%@page import="serv.common.*" %>
<%@page import="serv.util.ServLog" %>
<%@include file="function.jsp" %> 
<%-- @ include file="confirmLogin.jsp" --%>
<%!
	public String joinContactAndOwner(String contact,String owner){
		//ystem.out.println(doString.MS874ToUnicode(contact)+","+doString.MS874ToUnicode(owner));		
		String result = "";
		
		contact = doString.checkString(contact,"");
		owner = doString.checkString(owner,"");
		
		result = contact;
		if (contact.length()>0 && owner.length()>0) result += " / ";
		result += doString.checkString(owner,"");
		
		if (result.length()<=0) result = "-";
			    
		return result;
	}
/*
  * 2= wait Approve
  * 3= Approved
  * 5= Rout back
  */  
  public String GetStatusServApproved(Connection conn,String docNo){
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        
        String i_doc_type = "";
        //boolean isRecord = false;
        try {

            stmt = conn.createStatement();
  			sql.delete(0, sql.length());
			sql.append(" Select i_doc_type  ")
				.append(" From lan:serv_approve ")
				.append(" Where i_docno  = '"+docNo+"'  "); //AND  i_doc_type ='3'
				//System.out.println("SQL GetStatusServApproved  :"+sql.toString());
				rs = stmt.executeQuery(sql.toString());    				   
			    if(rs.next()){
			       i_doc_type  = doString.checkString(rs.getString("i_doc_type"),"");
			    } 		
			    /*if("3".equals(i_doc_type)){ // is  Approve
			       isRecord = true;
			    }else{
			       isRecord = false;
			    }*/	  
                rs.close();
                stmt.close();
                
        }catch(Exception e) {
            System.out.println(" GetStatusServApproved Error : " + e.getMessage());
        } finally{
            try  {
                if(rs != null) {
                    rs.close();
                }
                if(stmt != null){
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }       
        return i_doc_type;
    }		
%>
<%
Calendar right = Calendar.getInstance();
int dd = right.get(Calendar.DATE);
int mm = right.get(Calendar.MONTH) + 1;
int yy = right.get(Calendar.YEAR);
if (yy < 2400) {
	yy += 543;
}
String currentDate = (dd < 10?"0"+dd:""+dd)+ "/" + (mm <10?"0"+mm:""+mm) + "/" + yy;
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;
Statement stmt1 = null;
ResultSet rs1 = null;
StringBuffer sql = new StringBuffer("");

String i_company = "";
String i_project = "";
String i_document = "";
String n_project = "";
String status_warranty = "";
String end_warranty = "";
String i_lock = "";
String i_house = "";
String i_model = "";
String d_keyin_last = "";
String d_keyin = "" , d_appoint = "" , d_est_close = "" , i_service_employ = "" , cus_intent = "";

String n_customer = "";
String n_cus_tel = "";
String n_nemploy_th = "";
String n_semploy_th = "";
String n_nemploy_2 = "";
String n_semploy_2 = "";
String i_remark = "";

int tot_call = 0;
double z_amount_pv = 0.0d;
String appStatus = "";
try{
	if(ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	stmt1 = conn.createStatement();
	
	i_document = doString.checkString(request.getParameter("i_docno"),"");
	//i_document = doString.checkString(request.getParameter("doc"),"");
	
	  appStatus = GetStatusServApproved(conn,i_document);
	
	sql.delete(0,sql.length());
	sql.append(" select i_company , i_project , n_customer , n_cus_tel , d_keyin , d_appoint , d_est_close , i_service_employ ")
		.append(" from lan:serv_dochd ")
		.append(" where i_docno = '"+i_document+"' ");
	System.out.println(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	while(rs.next()){
		i_company = doString.checkString(rs.getString("i_company"),"");
		i_project = doString.checkString(rs.getString("i_project"),"");
		n_customer = doString.checkString(rs.getString("n_customer"),"");
		d_keyin = doString.checkString(rs.getString("d_keyin"),"");
		d_appoint = doString.checkString(rs.getString("d_appoint"),"");
		d_est_close = doString.checkString(rs.getString("d_est_close"),"");
		i_service_employ = doString.checkString(rs.getString("i_service_employ"),"");
		n_cus_tel = doString.checkString(rs.getString("n_cus_tel"),"");
	}
	rs.close();
	
	sql.delete(0,sql.length());
	sql.append(" select b.n_nemploy_th , b.n_semploy_th ")
		.append(" from lan:serv_dochd a , docflow:acemploy b ")
		.append(" where a.i_docno = '"+i_document+"' ")
		.append(" and a.i_service_employ = b.i_employ ");
	System.out.println(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	while(rs.next()){
		n_nemploy_th = doString.checkString(rs.getString("n_nemploy_th"),"");
		n_semploy_th = doString.checkString(rs.getString("n_semploy_th"),"");
	}
	rs.close();
	
	sql.delete(0,sql.length());
	sql.append(" select b.n_nemploy_th , b.n_semploy_th , a.i_remark ")
		.append(" from lan:serv_approve a , docflow:acemploy b ")
		.append(" where a.i_docno = '"+i_document+"' ")
		.append(" and a.i_employ = b.i_employ ");
	System.out.println(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	while(rs.next()){
		n_nemploy_2 = doString.checkString(rs.getString("n_nemploy_th"),"");
		n_semploy_2 = doString.checkString(rs.getString("n_semploy_th"),"");
		i_remark  = doString.checkString(rs.getString("i_remark"),"");
	}
	rs.close();
	
	sql.delete(0,sql.length());
	sql.append(" select n_project from lan:acxprojt where i_company = '"+i_company+"' and i_project = '"+i_project+"' ");
	System.out.println(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	while(rs.next()){
		n_project = doString.checkString(rs.getString("n_project"),"");
	}
	rs.close();
	
	sql.delete(0,sql.length());
	sql.append(" select a.i_lock , ")
		.append(" b.d_close_law + 1 units year as end_warranty, today - (b.d_close_law + 1 units year)  as result from serv_dochd a,acscontr b ")
		.append(" where a.i_company = b.i_company ")
		.append(" and a.i_project = b.i_project ")
		.append(" and a.i_company = '"+i_company+"' ")
		.append(" and a.i_project = '"+i_project+"' ")
		.append(" and a.i_lock  = b.i_sort ")
		.append(" and b.f_contr is null ")
		.append(" and b.d_close_law is not null ")
		.append(" and a.i_docno =  '"+i_document+"' ");
	System.out.println(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	if(rs.next()){
		int x = Integer.parseInt(rs.getString("result"));
		if(x > 0){
			status_warranty = "หมดประกัน";
		}else{
			status_warranty = "อยู่ระหว่างประกัน";
		}
		end_warranty = doString.checkString(rs.getString("end_warranty"),"");
		i_lock = doString.checkString(rs.getString("i_lock"),"");
	}
	rs.close();
	
	sql.delete(0,sql.length());
	sql.append(" select i_house , i_model from lan:acxlckmd ")
		.append(" where i_company = '"+i_company+"' ")
		.append(" and i_project = '"+i_project+"' ")
		.append(" and i_lock  = '"+i_lock+"' ");
	System.out.println(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	if(rs.next()){
		i_house = doString.checkString(rs.getString("i_house"),"");
		i_model = doString.checkString(rs.getString("i_model"),"");
	}
	rs.close();
	
	sql.delete(0,sql.length());
	sql.append(" select count(*) as total from lan:serv_dochd ")
		.append(" where i_company = '"+i_company+"' ")
		.append(" and i_project = '"+i_project+"' ")
		.append(" and i_lock  = '"+i_lock+"' ")
		.append(" and c_desc <> 'Checkup Program' ")
		.append(" and f_status <> 'CAN' ");
	System.out.println(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	if(rs.next()){
		tot_call = rs.getInt("total");
	}
	rs.close();
	
	sql.delete(0,sql.length());
	sql.append(" select sum(b.z_amount_pv) as z_amount_pv from lan:serv_dochd a , lan:serv_payment b ")
		.append(" where a.i_company = '"+i_company+"' ")
		.append(" and a.i_project = '"+i_project+"' ")
		.append(" and a.i_lock  = '"+i_lock+"' ")
		.append(" and a.c_desc != 'Checkup Program' ")
		.append(" and a.i_docno = b.i_docno ")
		.append(" and  a.f_status = 'CLS' ");
	System.out.println(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	if(rs.next()){
		z_amount_pv = rs.getDouble("z_amount_pv");
	}
	rs.close();
	
	sql.delete(0,sql.length());
	sql.append(" select max(d_keyin) as d_keyin_last from lan:serv_dochd ")
		.append(" where i_company = '"+i_company+"' ")
		.append(" and i_project = '"+i_project+"' ")
		.append(" and i_lock  = '"+i_lock+"' ")
		.append(" and c_desc != 'Checkup Program' ")
		.append(" and i_docno != '"+i_document+"' ");
	System.out.println(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	if(rs.next()){
		d_keyin_last  = doString.checkString(rs.getString("d_keyin_last"),d_keyin);
	}
	rs.close();
	
	sql.delete(0,sql.length());
	sql.append(" select nvl(b.i_cus_intent1,b.i_exp_intent1) as cus_intent ")
		.append(" from lan:acxlckmd a ")
		.append(" left join lan:acscontr b on b.i_company=a.i_company and b.i_project=a.i_project ")
		.append(" and b.i_lor=a.i_lor and b.f_contr is null ")
		.append(" where a.i_company = '"+i_company+"' ")
		.append(" and a.i_project = '"+i_project+"' ")
		.append(" and a.i_lock  = '"+i_lock+"' ");
	System.out.println(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	if(rs.next()){
		cus_intent  = doString.checkString(rs.getString("cus_intent"),"");
	}
	rs.close();
	
	sql.delete(0,sql.length());				
	sql.append("select n_prename , n_ncustomer , n_scustomer from lan:acxcusto where i_customer='"+cus_intent+"' ");	
	System.out.println(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	if(rs.next()){
		cus_intent = doString.checkString(rs.getString("n_prename"),"");
		cus_intent += doString.checkString(rs.getString("n_ncustomer"),""); 
		cus_intent += " "+doString.checkString(rs.getString("n_scustomer"),""); 
	}	
	rs.close();
 %>
<HTML>
<HEAD>
<TITLE>ระบบบริการหลังการขาย[Approve Form TurnKey]</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />

<link rel="stylesheet" href="thumbnailviewer.css" type="text/css" />
<script src="thumbnailviewer.js" type="text/javascript">
/***********************************************
* Image Thumbnail Viewer Script- ? Dynamic Drive (www.dynamicdrive.com)
* This notice must stay intact for legal use.
* Visit http://www.dynamicdrive.com/ for full source code
***********************************************/
</script>
<style type="text/css">
span				{	font-family:Microsoft Sans Serif Tahoma Verdana ;	font-size:10pt ; 	}

.title				{	color:rgb(0,0,120) ; font-weight:normal ; font-size:12pt ; display:block ; height:25px ; 
						border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; 
						border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px	}
.title02			{	color:rgb(0,150,255) ; font-weight:bold ; font-size:12pt ; display:block ; height:30px ;
						border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; 
						border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px	}				
.title03			{	color:rgb(255,0,0) ; font-weight:bold ; font-size:12pt ; display:block ; height:30px ;
						background-color:rgb(255,230,200) ; padding:3px 3px 3px 3px	 ;
						border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; 
						border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; 
						vertical-align:middle ;  	 	}
.title04			{	color:rgb(255,80,0) ; font-weight:normal ; font-size:12pt ; display:inline-block ; height:20px ;
						padding:0px 5px 0px 5px	 ;  	 	}						
											
.item					{	color:rgb(0,100,255) ; font-size:10pt ; display:inline-block ; 
							vertical-align:text-top ; width:120px ; height:25px ;  	}
.answer			{	color:rgb(0,0,0) ; font-size:10pt ; display:inline-block ;  
							vertical-align:text-top ; width:192px ; height:25px ; background-color:#FFF	}
.lineitem			{	display:inline-block	}
							
.item2				{	color:rgb(0,100,255) ; font-size:10pt ; display:inline ; 
							vertical-align:text-top ; height:25px ;  	}
.answer2			{	color:rgb(0,0,0) ; font-size:10pt ; display:inline ;  
							vertical-align:text-top ; height:25px ; background-color:none	}								
.lineitem2			{	display:block ; 	}
.lineitem3			{	display:block ; 	}

.pictA				{	display:block ; padding:10px 10px 10px 10px ; background-color:rgb(255,230,200) ; 
							border:2px solid rgb(255,255,255) ;  	}
.pictB				{	display:block ; padding:10px 10px 10px 10px ; background-color:rgb(255,220,255) ; 
							border:2px solid rgb(255,255,255) ;  	}
.pictC				{	display:block ; padding:10px 10px 10px 10px ; background-color:rgb(200,230,255) ;
							border:2px solid rgb(255,255,255) ;  	}

.remark			{	font-size:8pt ; color:rgb(120,120,120) ; display:inline-block ; 
							height:20px ; padding:5px 5px 0px 5px	 ;	}

.frm					{	border-top:1px solid rgb(135,185,247) ; 
							border-bottom:1px solid rgb(135,185,247) ; 
							border-left:1px solid rgb(135,185,247) ; 
							border-right:1px solid rgb(135,185,247) ; 
							padding:5px 10px 5px 10px ; background-color:rgb(255,255,255) ; 	}

.action					{	color:rgb(0,100,255) ; font-size:12pt ; display:block ; 
								vertical-align:middle ; width:100% ; height:40px ;  	}
.action	A:link		{	color:rgb(0,100,255) ; TEXT-DECORATION: none ;  width:100% ;	}
.action	A:visited	{	color:rgb(0,100,255) ; TEXT-DECORATION: none ;  width:100% ;	}
.action	A:hover	{	color:rgb(0,100,255) ; TEXT-DECORATION: none ;  width:100% ; height:100% ; 
								background-color:rgb(200,255,255) ; 		}

td.act_tab1		{ background:url(images/act_tab1.gif) ; background-repeat:no-repeat ; width:5px ; height:30px ; }					  
td.act_tab2		{ background:url(images/act_tab2.gif) ; background-repeat:repeat-x ; height:30px ; vertical-align: top ; }		
td.act_tab3		{ background:url(images/act_tab3.gif) ; background-repeat:no-repeat ; width:57px ; height:30px ; }	
td.act_tab4		{ background:url(images/act_tab4.gif) ; background-repeat:repeat-x ; height:30px ; text-align: right ; }

.shadow1		{	width:100% ; height:15px ; text-align:center ; display:block ;    	}
.shadow2		{	width:97% ; display:inline-block ;
						background-image:url(images/shadow.gif) ; 	
						background-repeat:repeat-x ;  		}

body				{	scrollbar-face-color				:		rgb(220,240,255)		; 
			  			scrollbar-shadow-color		: 		rgb(220,240,255)		; 
			  			scrollbar-highlight-color		:		rgb(220,240,255)		; 
			  			scrollbar-3dlight-color 			: 		rgb(255,255,255)		; 
			  			scrollbar-darkshadow-color	: 		rgb(120,180,255)		; 
			  			scrollbar-track-color 			: 		rgb(255,255,255)		; 
			  			scrollbar-arrow-color 			: 		rgb(120,180,255)		; 
						padding								:		5px 5px 5px 5px		;	 	}

.hidden-class { display:none;  } 
.show-class { display:compact;    } 

</style>

<base target="_self">


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

var flag_hide = 'N';
function showDetail(){ 
if(flag_hide == 'N'){
var elements = getElementsByClass('hidden-class'); 
for (i = 0 ; i < elements.length ; i++ ) { 
elements[i].className = 'show-class'; 
} 
flag_hide = 'Y';
}else{
var elements = getElementsByClass('show-class'); 
for (i = 0 ; i < elements.length ; i++ ) { 
elements[i].className = 'hidden-class'; 
} 
flag_hide = 'N';
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


function MM_openBrWindow(theURL,winName,features) { //v2.0
  window.open(theURL,winName,features);
}

function doRouteback() {
   document.forms[0].statusApp.value='5';
   document.forms[0].action="<%=Constants.APP_PATH%>/SERV_ApproveTurnkeyServlet";
   document.forms[0].target="";      
   document.forms[0].submit();
}

function doApprove() {
   document.forms[0].statusApp.value='3';
   document.forms[0].action="<%=Constants.APP_PATH%>/SERV_ApproveTurnkeyServlet";
   document.forms[0].target="";      
   document.forms[0].submit();
}
//-->
</script>


</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onLoad="initPage()" style="background-color:rgb(230,230,230)">
<FORM METHOD="POST" ACTION="">
<input type="hidden" name="i_docno" value="<%=i_document%>">
<input type="hidden" name="d_appoint" value="<%//=dAppoint%>">
<input type="hidden" name="d_est_close" value="<%//=dEstClose%>">
<input type="hidden" name="i_lock" value="<%=i_lock %>">
<input type="hidden" name="statusApp" value="">




<span style="vertical-align:top ; display:inline-block"><img src="images/LH_Logo.png" width="200" height="32" border="0" style="padding:0px 5px 10px 0px"></span>
    
<span width="90%" style="font-size:14pt ; font-family: Microsoft Sans Serif ; color: rgb(0,80,220) ; font-weight:bold ; TEXT-DECORATION: none ; letter-spacing:0px ; padding:5px 5px 10px 5px ; display:inline-block ; text-align:middle ; vertical-align:top">ระบบบริการหลังการขาย</span>
<span style="vertical-align:top ; display:inline-block ; padding:4px 0px 0px 0px">
<input name="Show" type="button" onClick="javascript:showDetail()" value="แสดง/ซ่อน รายละเอียด" style="margin-left:0px ; font-size:13px"></span>

         
<!-- รายละเอียดการขออนุมัติ -->

<div class="frm">

<span class="title">รายละเอียดการขออนุมัติ</span>
 
<span class="lineitem">
<span class="item">การประกัน :</span> <span class="answer">หมดประกัน</span></span>

<span class="lineitem"> <span class="item">วันที่หมดประกัน :</span>
 <span class="answer">28/11/2550</span></span>

 <span class="lineitem"> <span class="item">โครงการ :</span>
 <span class="answer"><%=i_company+i_project%> - <%=doString.DisplayThai(n_project)%></span></span>

 <span class="lineitem">
 <span class="item">เลขที่ใบแจ้งซ่อม :</span> <span class="answer"><%=i_document%></span>
</span> 
 
 <div id="Detail00" class="hidden-class">
  <span class="lineitem">
 <span class="item">แปลง :</span> <span class="answer"><%=i_lock%></span>  
 </span>
 
 <span class="lineitem">
 <span class="item">บ้านเลขที่ :</span> <span class="answer"><%=i_house%></span>
 </span>
 
 <span class="lineitem">
 <span class="item">แบบบ้าน :</span> <span class="answer"><%=i_model%></span>
</span> 

 <span class="lineitem">
<span class="item">จำนวนครั้งที่แจ้ง :</span> <span class="answer"><%=tot_call%></span>
</span>

 <span class="lineitem">
<span class="item">ค่าซ่อมสะสม :</span> <span class="answer"><%=doString.displayNumber("#,##0.00",z_amount_pv)%></span>
</span>

 <span class="lineitem">
<span class="item">วันที่แจ้งล่าสุด :</span> <span class="answer"><%=DateUtil.ifxToThaiDate(d_keyin)%></span>
</span>

 <span class="lineitem">
<span class="item">ชื่อผู้ขอ :</span> <span class="answer"><%=doString.DisplayThai(n_nemploy_2+" "+n_semploy_2)%></span>
</span>

 <span class="lineitem">
<span class="item">ชื่อผู้แจ้ง/ลูกค้า :</span> <span class="answer"><%=doString.DisplayThai(joinContactAndOwner(n_customer,cus_intent))%></span>  
</span>

 <span class="lineitem">
<span class="item">โทร :</span> <span class="answer"><%=n_cus_tel%></span>
</span>

 <span class="lineitem">
<span class="item">ผู้รับเรื่อง :</span> <span class="answer"><%=doString.DisplayThai(n_nemploy_th+" "+n_semploy_th)%></span>
</span>

 <span class="lineitem">
<span class="item">วันเวลาที่แจ้ง :</span> <span class="answer"><%=DateUtil.ifxToThaiDate(d_keyin)%></span>
</span>

 <span class="lineitem">
<span class="item">วันที่นัดซ่อม  :</span> <span class="answer"><%=DateUtil.ifxToThaiDate(d_appoint)%></span>  
</span>

 <span class="lineitem">
<span class="item">วันประมาณการเสร็จ  :</span> <span class="answer"><%=DateUtil.ifxToThaiDate(d_est_close)%></span>
</span>
</div>
</div>

<div class="shadow1"><div class="shadow2">&nbsp;</div></div>
  
<!-- End of รายละเอียดการขออนุมัติ -->



<!-- รายละเอียดการแจ้งซ่อม รายการที่ 1 -->
<%
String c_itmjob, bus_name , sum_total = "" , good_price = "" , wage_price = "" , i_keygen = "" ;
int count = 0;
double net_total = 0.0d;

sql.delete(0,sql.length());
sql.append(" select b.c_itmjob , c.bus_name , ")
	.append(" q_wage_unit*z_wage_price+q_good_unit*z_good_price as sum_total, ")
	.append(" q_good_unit*z_good_price as good_price, ")
	.append(" q_wage_unit*z_wage_price as wage_price, ")
	.append(" b.i_keygen ")
	.append(" from lan:serv_dochd a , lan:serv_docdt b , lan:stpvendr c ")
	.append(" where a.i_docno = '"+i_document+"' ")
	.append(" and a.i_docno = b.i_docno ")
	.append(" and b.i_vendor = c.vend_code ")
	.append(" order by b.i_seq , b.i_itmjob ");
System.out.println(sql.toString());
rs = stmt.executeQuery(sql.toString());
while(rs.next()){
	c_itmjob = doString.checkString(rs.getString("c_itmjob"),"");
	bus_name = doString.checkString(rs.getString("bus_name"),"");
	i_keygen = doString.checkString(rs.getString("i_keygen"),"");
	
	sum_total = doString.checkString(rs.getString("sum_total"),"");
	good_price = doString.checkString(rs.getString("good_price"),"");
	wage_price = doString.checkString(rs.getString("wage_price"),"");
	
	net_total += Double.parseDouble(sum_total);
%>
<div class="frm">

<span class="title">รายละเอียดการแจ้งซ่อม</span>


<span class="title02" style="display:inline-block ; width:100%">รายการที่ <%=++count%></span>

<span class="lineitem2">
<span class="item2">1. <%=doString.DisplayThai(c_itmjob)%></span>
</span>
<span class="lineitem2">
<span class="item2">2. ผู้รับเหมาซ่อม :</span> <span class="answer2"><%=doString.DisplayThai(bus_name)%></span>
</span>
<span class="lineitem2">
<span class="item2">3. จำนวนรวม :</span> <span class="answer2"><%=doString.displayNumber("#,##0.00",Double.parseDouble(sum_total))%> (ค่าของ  <%=doString.displayNumber("#,##0.00",Double.parseDouble(good_price))%>  ค่าแรง  <%=doString.displayNumber("#,##0.00",Double.parseDouble(wage_price))%>)</span>
</span>
<%
String b_file_name = "", b_file_name2 = "", p_file_name1 = "", p_file_name2 = "", a_file_name = "", a_file_name2 = "";
sql.delete(0,sql.length());
sql.append(" select * from lan:serv_docatt where i_keygen = '"+i_keygen+"' ");
rs1 = stmt1.executeQuery(sql.toString());
if(rs1.next()){
	b_file_name = doString.checkString(rs1.getString("b_file_name"),"");
	b_file_name2 = doString.checkString(rs1.getString("b_file_name2"),"");
	p_file_name1 = doString.checkString(rs1.getString("p_file_name1"),"");
	p_file_name2 = doString.checkString(rs1.getString("p_file_name2"),"");
	a_file_name = doString.checkString(rs1.getString("a_file_name"),"");
	a_file_name2 = doString.checkString(rs1.getString("a_file_name2"),"");
	//System.out.println(request.getContextPath()+"/pictures/"+i_document+"/"+b_file_name);
%>
<!-- Before -->
<div id="Detail01" class="hidden-class">
<span class="pictA">
<span class="lineitem3">
<span class="title04">ภาพก่อนซ่อม</span>
<span class="remark">Double Click เพื่อดูภาพขนาดใหญ่ขึ้น (สำหรับการดูบน PC)</span>
</span>
<% 

if(!"".equals(b_file_name)){
 %>
<!-- ภาพที่ 1 -->
<span class="lineitem">
<img src="<%=request.getContextPath()+"/pictures/"+i_document+"/"+b_file_name%>" width="100%" hspace="5" vspace="5" border="0" style="max-width:250px" onDblClick="MM_openBrWindow('<%=request.getContextPath()+"/pictures/"+i_document+"/"+b_file_name%>','','width=600,height=400')">
<span class="lineitem2" style="padding-left:5px">
<span class="item2">ภาพ :</span> <span class="answer2">1</span>
<!--  span class="item2">วันที่ถ่ายภาพ :</span> <span class="answer2">17/04/2558</span --></span></span>
<!-- End ภาพที่ 1 -->
<% } %>
<% if(!"".equals(b_file_name2)){ %>
<!-- ภาพที่ 2 -->
<span class="lineitem">
<img src="<%=request.getContextPath()+"/pictures/"+i_document+"/"+b_file_name2%>" border="0" width="100%" style="max-width:250px" hspace="5" vspace="5" onDblClick="MM_openBrWindow('<%=request.getContextPath()+"/pictures/"+i_document+"/"+b_file_name2%>','','width=600,height=400')">

<span class="lineitem2" style="padding-left:5px">
<span class="item2">ภาพ :</span> <span class="answer2">2</span>
<!-- span class="item2">วันที่ถ่ายภาพ :</span> <span class="answer2">17/04/2558</span --></span></span>
<!-- End ภาพที่ 2 -->
<% } %>
</span></div>
<!-- End of Before -->

<!-- WIP -->
<div id="Detail01" class="hidden-class">
<span class="pictB">

<span class="lineitem3">
<span class="title04" style="width:110px">ภาพระหว่างซ่อม</span>
<span class="remark">Double Click เพื่อดูภาพขนาดใหญ่ขึ้น (สำหรับการดูบน PC)</span>
</span>

<% if(!"".equals(p_file_name1)){ %>
<!-- ภาพที่ 1 -->
<span class="lineitem">

<img src="<%=request.getContextPath()+"/pictures/"+i_document+"/"+p_file_name1%>" width="100%" hspace="5" vspace="5" border="0" style="max-width:250px" onDblClick="MM_openBrWindow('<%=request.getContextPath()+"/pictures/"+i_document+"/"+p_file_name1%>','','width=600,height=400')">
<span class="lineitem2" style="padding-left:5px">
<span class="item2">ภาพ :</span> <span class="answer2">1</span>
<!-- span class="item2">วันที่ถ่ายภาพ :</span> <span class="answer2">25/04/2558</span --></span></span>
<!-- End ภาพที่ 1 -->
<% } %>
<% if(!"".equals(p_file_name2)){ %>
<!-- ภาพที่ 2 -->
<span class="lineitem">
<img src="<%=request.getContextPath()+"/pictures/"+i_document+"/"+p_file_name2%>" border="0" width="100%" style="max-width:250px" hspace="5" vspace="5" onDblClick="MM_openBrWindow('<%=request.getContextPath()+"/pictures/"+i_document+"/"+p_file_name2%>','','width=600,height=400')">

<span class="lineitem2" style="padding-left:5px">
<span class="item2">ภาพ :</span> <span class="answer2">2</span>
<!-- span class="item2">วันที่ถ่ายภาพ :</span> <span class="answer2">25/04/2558</span --></span></span>
<!-- End ภาพที่ 2 -->
<% } %>
</span></div>
<!-- End of WIP -->

<!-- After -->
<div id="Detail01" class="hidden-class">
<span class="pictC">

<span class="lineitem3">
<span class="title04">ภาพหลังซ่อม</span>
<span class="remark">Double Click เพื่อดูภาพขนาดใหญ่ขึ้น (สำหรับการดูบน PC)</span>
</span>

<% if(!"".equals(a_file_name)){ %>
<!-- ภาพที่ 1 -->
<span class="lineitem">
<img src="<%=request.getContextPath()+"/pictures/"+i_document+"/"+a_file_name%>" width="100%" hspace="5" vspace="5" border="0" style="max-width:250px" onDblClick="MM_openBrWindow('<%=request.getContextPath()+"/pictures/"+i_document+"/"+a_file_name%>','','width=600,height=400')">
<span class="lineitem2" style="padding-left:5px">
<span class="item2">ภาพ :</span> <span class="answer2">1</span>
<!-- span class="item2">วันที่ถ่ายภาพ :</span> <span class="answer2">11/05/2558</span --></span></span>
<!-- End ภาพที่ 1 -->
<% } %>
<% if(!"".equals(a_file_name2)){ %>
<!-- ภาพที่ 2 -->
<span class="lineitem">
<img src="<%=request.getContextPath()+"/pictures/"+i_document+"/"+a_file_name2%>" border="0" width="100%" style="max-width:250px" hspace="5" vspace="5" onDblClick="MM_openBrWindow('<%=request.getContextPath()+"/pictures/"+i_document+"/"+a_file_name2%>','','width=600,height=400')">
<span class="lineitem2" style="padding-left:5px">
<span class="item2">ภาพ :</span> <span class="answer2">2</span>
<!-- span class="item2">วันที่ถ่ายภาพ :</span> <span class="answer2">11/05/2558</span --></span></span>
<!-- End ภาพที่ 2 -->
<% } %>
</span></div>
<!-- End of After -->
<%
}
rs1.close();
 %>
</div>
<div class="shadow1"><div class="shadow2">&nbsp;</div></div>
<!-- End of  รายละเอียดการแจ้งซ่อม รายการที่ 1 -->
<%
}
rs.close();
%>
<!-- สรุป -->

<div class="frm">

<span class="title03">จำนวนรวม <font style="padding-left:20px"><%=count%> รายการ</font></span>
<span class="title03">จำนวเงินรวมสุทธิ <font style="padding-left:20px"><%=doString.displayNumber("#,##0.00",net_total)%> บาท</font></span>

<span class="item2" valign="top">Comment</span>
<span class="answer2">
<textarea name="i_commentDesc" class="box" style="width:100%;height:60px" maxlength="255"></textarea>
<%//=doString.DisplayThai(i_remark)%>
</span>

 
<span class="lineitem2">
<span class="item2">ผู้อนุมัติ :</span> 
<span class="answer2"><%=doString.DisplayThai(n_nemploy_2+" "+n_semploy_2)%></span>
</span>



</div>

<div class="shadow1"><div class="shadow2">&nbsp;</div></div>

<!-- End of สรุป -->



<!-- การอนุมัติ -->
<a name="approvement"></a>
<div class="frm" style="padding:20px 5px 20px 5px ; background-image:url(images/act_tab4.gif) ; background-repeat:repeat-x ; background-position:center">

		<% if("2".equals(appStatus)){ %>
            <img border="0" src="images/act_approve.gif" style="cursor:hand ;display:inline-block" hspace="5" vspace="5" onClick="doApprove();" >
            <img border="0" src="images/act_routeback.gif" style="cursor:hand ; display:inline-block" hspace="5" vspace="5" onClick="doRouteback();" >
			 <%-- <img border="0" src="images/act_deny.gif" style="cursor:hand ;display:inline-block" hspace="5" vspace="5">--%>
		<%} %>			 	
			<span style="float:right; padding-top:6px;">
			<a href="javascript:history.back();" ><img  border="0" src="images/bu_back.gif"  width="50" height="15" hspace="5" vspace="5"></a>&nbsp;
			<a href="<%=Constants.APP_HOME%>" ><img   border="0" src="images/bu_home.gif"  width="50" height="15" hspace="5" vspace="5"></a>
			</span>

</div>

<div class="shadow1"><div class="shadow2">&nbsp;</div>

</div>

<!--  End of  การอนุมัติ -->

</form>
</BODY>

</HTML>
<%
}catch(Exception e){
	System.out.println("ERROR SERV_BeyondApprove.jsp : " + e.getMessage()); 
	throw new ServletException(e.getMessage());
}finally{
	// Clean up.
	try {
		if (rs != null) rs.close();
		if (stmt != null) stmt.close();
		if (conn != null) conn.close();
	}
	catch( SQLException ignore ){}
}
%>
