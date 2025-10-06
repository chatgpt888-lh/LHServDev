<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.*" %>
<%@page import="serv.common.*" %>
<%@page import="java.text.*" %>
<%@page import="serv.util.ServLog" %>
<%@include file="function.jsp" %> 
<%@page import="java.io.File"%>
<%@page import="java.net.URI"%>
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
	
	protected int CountImage(String path){
	 int countImg = 0;
	  try{
			File fPath = new File(path);//"D:\\usr\\IBM\\workspace2013\\LHServ\\WebContent\\pictures\\LH-075-5800083\\"
			File [] files = fPath.listFiles();
			for (int i = 0; i < files.length; i++){
			        if (files[i].isFile()){ //this line weeds out other directories/folders
			            //System.out.println(loop+"="+files[i]);
			        	countImg++; 
			        }
			    }		   
			   return countImg;
			 }catch(Exception e){
		return -1;
	   }
	}
	
	public int CountSERV_DOCATT(Connection conn,String docNo){
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        
        int cnt = 0;
        try {
            stmt = conn.createStatement();
  			sql.delete(0, sql.length());
			sql.append(" select sum(img_cnt) as cnt ")
				.append(" From lan:serv_docatt ")
				.append(" Where i_docno  ='"+docNo+"'  "); 
				//System.out.println("SQL CountSERV_DOCATT  :"+sql.toString());
				rs = stmt.executeQuery(sql.toString());    				   
			    if(rs.next()){
			       cnt  = rs.getInt("cnt");
			    } 	
            rs.close();
            stmt.close();
        }catch(Exception e) {	          
			e.printStackTrace();
			System.err.println(" CountSERV_DOCATT Error : " + e.getMessage());
			System.err.println(" CountSERV_DOCATT SQL: "+sql.toString());
        } finally{
            try  {
                if(rs != null) {  rs.close();}
                if(stmt != null){stmt.close();}
            }
            catch(Exception ex) { }
        }       
        return cnt;
    }
    
	 //ระหัสผู้อนุมัติ และ email ผู้อนุมัติ
	    public String[] GetApproval(Connection conn,String comId,String projectId){
	        StringBuffer sql = new StringBuffer();
	        Statement stmt = null;
	        ResultSet rs = null;
	        
	        String tempStr[] = new String[] {"","","",""};
	        try {

	            stmt = conn.createStatement();
	  			sql.delete(0, sql.length());
				sql.append("  Select  a.i_employ_app1,b.user_email,b.user_name,b.user_password ")
					.append(" From lan:serv_lstaff a, lan:useracl b")
					.append(" Where ") 
	     			.append(" a.i_company  = '"+comId+"' ")
					.append(" AND  a.i_project = '"+projectId+"'   ")
	 				.append("AND  a.i_employ_app1 = b.i_employ  ")
	 				.append("AND  b.user_acl = 'S' ");
					//System.out.println("SQL Approval  :"+sql.toString());
					rs = stmt.executeQuery(sql.toString());    				   
				    if(rs.next()){
				        tempStr[0]  = doString.checkString(rs.getString("i_employ_app1"),"");
				        tempStr[1]  = doString.checkString(rs.getString("user_email"),"");
				        tempStr[2]  = doString.checkString(rs.getString("user_name"),"");
				        tempStr[3]  = doString.checkString(rs.getString("user_password"),"");
				    } 		 
	                rs.close();
	                stmt.close();
	                
	        }catch(Exception e) {
	            System.out.println(" GetApproval Error : " + e.getMessage());
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
	        return tempStr;
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
String i_cus_tel = "";
String n_nemploy_th = "";
String n_semploy_th = "";
String n_nemploy_2 = "";
String n_semploy_2 = "";
String i_remark = "";
String cid = "cid:";
String mail = "Y";
String i_mobile_sender = "";

int tot_call = 0;
double z_amount_pv = 0.0d;


//String URL_ADDRESS = "http://132.146.4.24:9080/LHServ";
//String URL_ADDRESS = request.getContextPath();


try{
	if(ds == null) getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	stmt1 = conn.createStatement();
	
	//modify by pradoem 2015.12.14
	String fstatus = doString.checkString(request.getParameter("fstatus"),""); //fstatus=disable  from SERV_ApproveTurnkeyServlet send mail NoImages and >500 bath
	
	i_document = doString.checkString(request.getParameter("doc"),"");
	mail = doString.checkString(request.getParameter("mail"),"Y");
	if("N".equals(mail))cid = "";
	
	sql.delete(0,sql.length());
	sql.append(" select i_company , i_project , n_customer , n_cus_tel , d_keyin , d_appoint , d_est_close , i_service_employ ")
		.append(" from lan:serv_dochd ")
		.append(" where i_docno = '"+i_document+"' ");
	//System.out.println(sql.toString());
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
	//System.out.println(sql.toString());
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
	//System.out.println(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	while(rs.next()){
		n_nemploy_2 = doString.checkString(rs.getString("n_nemploy_th"),"");
		n_semploy_2 = doString.checkString(rs.getString("n_semploy_th"),"");
		i_remark  = doString.checkString(rs.getString("i_remark"),"");
	}
	rs.close();
	
	sql.delete(0,sql.length());
	sql.append(" select n_project from lan:acxprojt where i_company = '"+i_company+"' and i_project = '"+i_project+"' ");
	//System.out.println(sql.toString());
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
	//System.out.println(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	int x = 0;
	if(rs.next()){
		 x = Integer.parseInt(rs.getString("result"));
		end_warranty = doString.checkString(rs.getString("end_warranty"),"");
		i_lock = doString.checkString(rs.getString("i_lock"),"");
	}
	if(x > 0){
			status_warranty = "หมดประกัน";
		}else{
			status_warranty = "อยู่ระหว่างประกัน";
	}
	if(!"".equals(end_warranty) && end_warranty.length()>10){
      //26/08/2559 00:00
      end_warranty = end_warranty.substring(0,10);
    }
    
	rs.close();
	
	sql.delete(0,sql.length());
	sql.append(" select i_house , i_model from lan:acxlckmd ")
		.append(" where i_company = '"+i_company+"' ")
		.append(" and i_project = '"+i_project+"' ")
		.append(" and i_lock  = '"+i_lock+"' ");
	//System.out.println(sql.toString());
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
	//System.out.println(sql.toString());
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
	//System.out.println(sql.toString());
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
	//System.out.println(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	if(rs.next()){
		d_keyin_last  = doString.checkString(rs.getString("d_keyin_last"),"");
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
	//System.out.println(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	if(rs.next()){
		cus_intent  = doString.checkString(rs.getString("cus_intent"),"");
	}
	rs.close();
	
	sql.delete(0,sql.length());				
	sql.append("select n_prename , n_ncustomer , n_scustomer , a_id_tel , a_wk_tel , a_etc_tel from lan:acxcusto where i_customer='"+cus_intent+"' ");	
	//System.out.println(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	if(rs.next()){
		cus_intent = doString.checkString(rs.getString("n_prename"),"");
		cus_intent += doString.checkString(rs.getString("n_ncustomer"),""); 
		cus_intent += " "+doString.checkString(rs.getString("n_scustomer"),""); 
		i_cus_tel = doString.checkString(rs.getString("a_id_tel"),"");
		
		String tel = doString.checkString(rs.getString("a_wk_tel"),"");
		if (tel.length()>0) {
			i_cus_tel += (i_cus_tel.length()>0) ? " , "+tel : tel;
		}
		tel = doString.checkString(rs.getString("a_etc_tel"),"");
		if (tel.length()>0) {
			i_cus_tel += (i_cus_tel.length()>0) ? " , "+tel : tel;
		}	
	}	
	rs.close();
	
	sql.delete(0,sql.length());				
	sql.append(" select i_mobile_sender from lan:serv_lstaff ")
		.append(" where i_company = '"+i_company+"' ")
		.append(" and i_project = '"+i_project+"' ");
	//System.out.println(sql.toString());
	rs = stmt.executeQuery(sql.toString());
	if(rs.next()){
		i_mobile_sender = doString.checkString(rs.getString("i_mobile_sender"),"");
	}
	rs.close();
 %>


<HTML xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" xmlns:m="http://schemas.microsoft.com/office/2004/12/omml" xmlns="http://www.w3.org/TR/REC-html40">
<HEAD>
<TITLE>ระบบบริการหลังการขาย</TITLE>
<meta name=Generator content="Microsoft Word 14 (filtered medium)">
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />

<style type="text/css">
td			{	font-family:Microsoft Sans Serif ;	font-size:10pt ; 	}

.title		{	color:rgb(0,0,120) ; font-weight:normal ; font-size:12pt ; display:block ; height:25px ; 
						border-bottom:0px solid #FFFFFF ; border-top:0px solid #FFFFFF ; background-color:rgb(255,255,255) ; 
						border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px	}
.title02	{	color:rgb(0,150,255) ; font-weight:bold ; font-size:12pt ; display:block ; height:30px ; background-color:rgb(255,255,255) ; 
						border-bottom:0px solid #FFFFFF ; border-top:0px solid #FFFFFF ; 
						border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px	}				
.title03	{	color:rgb(255,0,0) ; font-weight:bold ; font-size:12pt ; display:block ; height:30px ;
						background-color:rgb(255,230,200) ; padding:3px 3px 3px 3px	 ;
						border-bottom:0px solid #FFFFFF ; border-top:0px solid #FFFFFF ; 
						border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; 
						vertical-align:middle ;  	 	}
											
.item			{	color:rgb(0,100,255) ; font-size:10pt ;  vertical-align:text-top ; width:50px ; height:25px ; background-color:rgb(255,255,255) 	}
.answer			{	color:rgb(0,0,0) ; font-size:10pt ; display:inline-block ;  
							vertical-align:text-top ; width:190px ; height:25px ; background-color:rgb(255,255,255)	}
.lineitem		{	display:inline-block	}
							
.item2			{	color:rgb(0,100,255) ; font-size:10pt ; display:inline ; 
							vertical-align:text-top ; height:25px ; background-color:rgb(255,255,255) ;  	}
.answer2		{	color:rgb(0,0,0) ; font-size:10pt ; display:inline ;  
						vertical-align:text-top ; height:25px ; background-color:rgb(255,255,255) ; 	}								
.lineitem2		{	display:block ; 	}

.pict				{	display:inline-block ; padding:10px 0px 10px 0px ; background-color:rgb(255,255,255) ; 	}

.frm				{	border-top:1px solid rgb(135,185,247) ; 
							border-bottom:1px solid rgb(135,185,247) ; 
							border-left:1px solid rgb(135,185,247) ; 
							border-right:1px solid rgb(135,185,247) ; width:100% ; 
							padding:0px 10px 0px 10px ; background-color:rgb(255,255,255) ; 	}

.action				{	color:rgb(0,100,255) ; font-size:12pt ; display:block ; 
								vertical-align:middle ; width:100% ; height:40px ;  	}
.action	A:link	{	color:rgb(0,100,255) ; TEXT-DECORATION: none ;  width:100% ;	}
.action	A:visited	{	color:rgb(0,100,255) ; TEXT-DECORATION: none ;  width:100% ;	}
.action	A:hover	{	color:rgb(0,100,255) ; TEXT-DECORATION: none ;  width:100% ; height:100% ; 
								background-color:rgb(200,255,255) ; 		}


.shadow1	{	width:100% ; height:15px ; text-align:center ; display:block ;    	}
.shadow2	{	width:97% ; display:inline-block ;
						background-image:url(images/shadow.gif) ; 	
						background-repeat:repeat-x ;  		}

body	{	scrollbar-face-color				:		rgb(220,240,255)		; 
			  			scrollbar-shadow-color		: 		rgb(220,240,255)		; 
			  			scrollbar-highlight-color		:		rgb(220,240,255)		; 
			  			scrollbar-3dlight-color 			: 		rgb(255,255,255)		; 
			  			scrollbar-darkshadow-color	: 		rgb(120,180,255)		; 
			  			scrollbar-track-color 			: 		rgb(255,255,255)		; 
			  			scrollbar-arrow-color 			: 		rgb(120,180,255)		; 
						padding								:		5px 5px 5px 5px		;	 	
		}
</style>

<base target="_self">

</HEAD>

<BODY leftMargin="0" topMargin="0" marginheight="0" marginwidth="0" style="background-color:rgb(230,230,230)">
    
<table width="100%" cellpadding="0" cellspacing="0">    
<tr>    
<td width="90%" style="font-size:14pt ; font-family: Microsoft Sans Serif ; color: rgb(0,80,220) ; font-weight:bold ; TEXT-DECORATION: none ; letter-spacing:0px ; padding:5px 5px 10px 5px ; display:inline-block ; text-align:middle">ระบบบริการหลังการขาย</td>
</tr>
</table>
         
<!-- รายละเอียดการขออนุมัติ -->
<table width="100%" cellpadding="0" cellspacing="0" border="0">
<tr>
<td class="frm">
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
<td class="title" style="height:30px ; padding-bottom:10px">รายละเอียดการขออนุมัติ</td>
 </tr>
 </table>
 <table cellpadding="0" cellspacing="0" width="100%">
<tr class="lineitem">
<td class="item" >การประกัน :</td> 
<td class="answer"><%=status_warranty%></td>
</tr>

<tr class="lineitem"> 
<td class="item">วันที่หมดประกัน :</td>
 <td class="answer"><%=DateUtil.ifxToThaiDateNoTime(end_warranty)%></td>
 </tr>

 <tr class="lineitem"> <td class="item">โครงการ :</td>
<td class="answer"><%=i_company+i_project%> <%=doString.DisplayThai(n_project)%></td>
</tr>
<%
String iEmployApp= "";
String userEmailApp = "";
String userNameApp ="";
String userPwdApp= "";


String [] approvalStr = GetApproval(conn, i_company, i_project);
if(approvalStr!=null && approvalStr.length>3){
	iEmployApp =   approvalStr[0];
	userEmailApp = approvalStr[1];
	userNameApp =  approvalStr[2];
	userPwdApp =   approvalStr[3];		 
}

String targetUrl = URL_ADDRESS+"/SERV_TurnkeyApprDisp.jsp";
String apprURL = URL_ADDRESS+"/LoginServlet?userid="+userNameApp+"&password="+userPwdApp+"&iDocNo="+i_document+"&url="+targetUrl;

 %>
 <tr class="lineitem">
 <td class="item">เลขที่ใบแจ้งซ่อม :</td> <td class="action"><a href="<%=apprURL%>"><%=i_document%></a></td>
</tr> 
 
 <!--div id="Detail00" class="hidden-class"-->
  <tr class="lineitem">
 <td class="item">แปลง :</td> <td class="answer"><%=i_lock%></td>  
 </tr>
 
 <tr class="lineitem">
 <td class="item">บ้านเลขที่ :</td> <td class="answer"><%=i_house%></td>
 </tr>
 
 <tr class="lineitem">
 <td class="item">แบบบ้าน :</td> <td class="answer"><%=i_model%></td>
</tr> 

 <tr class="lineitem">
<td class="item">จำนวนครั้งที่แจ้ง :</td> <td class="answer"><%=tot_call%></td>
</tr>

 <tr class="lineitem">
<td class="item">ค่าซ่อมสะสม :</td> <td class="answer"><%=doString.displayNumber("#,##0.00",z_amount_pv)%></td>
</tr>

 <tr class="lineitem">
<td class="item">วันที่แจ้งล่าสุด :</td> <td class="answer"><%=DateUtil.ifxToThaiDate(d_keyin_last)%></td>
</tr>

 <tr class="lineitem">
<td class="item">ชื่อผู้ขอ :</td> <td class="answer"><%=doString.DisplayThai(n_nemploy_2+" "+n_semploy_2)%></td>
</tr>

 <tr class="lineitem">
<td class="item">ชื่อผู้แจ้ง/ลูกค้า :</td> <td class="answer"><%=doString.DisplayThai(joinContactAndOwner(n_customer,cus_intent))%></td>  
</tr>

 <tr class="lineitem">
<td class="item">โทร :</td> <td class="answer"><%=doString.DisplayThai(joinContactAndOwner(n_cus_tel,i_cus_tel))%></td>
</tr>

 <tr class="lineitem">
<td class="item">ผู้รับเรื่อง :</td> <td class="answer"><%=doString.DisplayThai(n_nemploy_th+" "+n_semploy_th)%></td>
</tr>

 <tr class="lineitem">
<td class="item">วันเวลาที่แจ้ง :</td> <td class="answer"><%=DateUtil.ifxToThaiDate(d_keyin)%></td>
</tr>

 <tr class="lineitem">
<td class="item">วันที่นัดซ่อม  :</td> <td class="answer"><%=DateUtil.ifxToThaiDate(d_appoint)%></td>  
</tr>

 <tr class="lineitem">
<td class="item">วันประมาณการเสร็จ  :</td> <td class="answer"><%=DateUtil.ifxToThaiDate(d_est_close)%></td>
</tr>
</table>
</td>
</tr>
</table>
<div class="shadow1"><div class="shadow2">&nbsp;</div></div>
<!-- End of รายละเอียดการขออนุมัติ -->

<!-- รายละเอียดการแจ้งซ่อม รายการที่ 1 -->
<%
String c_itmjob,i_itmjob , bus_name , sum_total = "" , good_price = "" , wage_price = "" , i_keygen = "" , n_desc = "" ,n_itmjob = "",redtag_good_unit = "",redtag_wage_unit = "";
int count = 0;
double net_total = 0.0d;


int countImg = 0;
int line = 0;
String yyyyMMdd =  GetDateKeyinYYYYMMDD(conn,i_document);
String []tmp = yyyyMMdd.split("\\-"); //2012-08-15
String yyyy = tmp[0];
String month = tmp[1];
String vendorId = "";
String qareaId = "";

sql.delete(0,sql.length());
sql.append(" select b.i_seq , b.c_itmjob , c.bus_name ,b.i_vendor,b.i_itmjob_area,b.i_itmjob, ")
	.append(" q_wage_unit*z_wage_price+q_good_unit*z_good_price as sum_total, ")
	.append(" q_good_unit*z_good_price as good_price, ")
	.append(" q_wage_unit*z_wage_price as wage_price, ")
	.append(" b.i_keygen , b.i_itmjob_area , d.n_desc ")
	.append(" from lan:serv_dochd a , lan:serv_docdt b , lan:stpvendr c , lan:serv_xstd  d ")
	.append(" where a.i_docno = '"+i_document+"' ")
	.append(" and a.i_docno = b.i_docno ")
	.append(" and b.i_vendor = c.vend_code ")  
	.append(" and b.i_itmjob_area = d.i_code ")  
	.append(" and d.i_type = '01' ")  
	.append(" order by b.i_seq , b.i_itmjob ");
//System.out.println(sql.toString());
rs = stmt.executeQuery(sql.toString());
while(rs.next()){
	c_itmjob = doString.checkString(rs.getString("c_itmjob"),"");
	i_itmjob = doString.checkString(rs.getString("i_itmjob"),"");
	bus_name = doString.checkString(rs.getString("bus_name"),"");
	i_keygen = doString.checkString(rs.getString("i_keygen"),"");
	n_desc = doString.checkString(rs.getString("n_desc"),"");
	
	sum_total = doString.checkString(rs.getString("sum_total"),"");
	good_price = doString.checkString(rs.getString("good_price"),"0");
	if( Double.parseDouble(good_price) == 0 || !Utilizer.isValueStrAndObj(good_price)){
			redtag_good_unit = "<span style='color:red;'>**</span>";
	}
	wage_price = doString.checkString(rs.getString("wage_price"),"0");
	if(Double.parseDouble(wage_price) == 0 || !Utilizer.isValueStrAndObj(wage_price)){
			redtag_wage_unit = "<span style='color:red;'>**</span>";
	}
	net_total += Double.parseDouble(sum_total);
	
	vendorId = doString.checkString(rs.getString("i_vendor"),"");
	qareaId = doString.checkString(rs.getString("i_itmjob_area"),"");
	
	line++;
	String keyFile   = i_document+"_"+i_keygen+"_"+vendorId+"_"+qareaId+"_"+line;
	
		sql.delete(0,sql.length());
        sql.append(" select n_itmjob,z_wage_unit,z_good_unit  from lan:serv_boq ")
		   .append(" where i_itmjob = '"+i_itmjob+"' ");
		
		rs1 = stmt1.executeQuery(sql.toString());
		
		if(rs1.next()){
		n_itmjob = doString.checkString(rs1.getString("n_itmjob"),"");
		}
		rs1.close();
	
	//System.out.println("keyFile = "+keyFile);
	
	%>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
<tr>
<td class="frm">

<table cellpadding="0" cellspacing="0" width="100%">
	<tr>
		<td class="title" >รายละเอียดการแจ้งซ่อม</td>
	</tr>
	<tr>
		<td class="title02" style="display:inline-block" >รายการที่ <%=++count%></td>
	</tr>
	<tr >
		<td style="color:rgb(0,100,255);"  >1. <%=doString.DisplayThai(n_itmjob)%></td>
	</tr>
	<tr>
		<td class="title02" style="display:inline-block" >หมายเหตุที่ <%=count%></td>
	</tr>
	<tr >
		<td style="color:rgb(0,100,255);"  >1. <%=doString.DisplayThai(c_itmjob+" - "+n_desc)%></td>
	</tr>
</table>
<table cellpadding="0" cellspacing="0" width="100%">
	<tr  >
		<td style="color:rgb(0,100,255);"  width="120">2. ผู้รับเหมาซ่อม :</td>
		<td ><%=doString.DisplayThai(bus_name)%></td>
	</tr>
	<tr >
		<td style="color:rgb(0,100,255)">3. จำนวนรวม :</td>
		<td ><%=doString.displayNumber("#,##0.00",Double.parseDouble(sum_total))%> (<%=redtag_good_unit %>ค่าของ  <%=doString.displayNumber("#,##0.00",Double.parseDouble(good_price))%>  <%=redtag_wage_unit %>ค่าแรง  <%=doString.displayNumber("#,##0.00",Double.parseDouble(wage_price))%>)</td>
	</tr>
</table>
<%
    String pathUrlX = Utilizer.getPropValue("IP_HOST_UPLOAD")+Utilizer.getPropValue("PATH_UPLOAD")+yyyy+"/"+month+"/"+i_document+"/";	
	String pathTmp = Utilizer.getPropValue("IP_HOST_UPLOAD")+Utilizer.getPropValue("PATH_UPLOAD")+yyyy+"/"+month+"/"+i_document+"/";
	String imagesIdUrl = pathUrlX+keyFile+"_a.jpg";

	//System.out.println(" imagesIdUrl A:"+imagesIdUrl);
	int resCode = getHttpResponseCode(pathTmp+keyFile+"_a.jpg");
%>
<% if(resCode==200) {
    countImg++;
 %>
	<table cellpadding="0" cellspacing="0" width="100%">
	<tr>
		<td class="pict" >
	<img src="<%=cid%><%=imagesIdUrl%>" width="320" height="230" border="0">

		</td>
		</tr>
<% } %>
<% 
    imagesIdUrl = pathTmp+keyFile+"_b.jpg";
	//System.out.println("imagesIdUrl B:"+imagesIdUrl);
	resCode = getHttpResponseCode(pathTmp+keyFile+"_b.jpg");

if(resCode==200) {
    countImg++;
	 %>
		<tr>
		<td class="pict" >
		
		<img src="<%=cid%><%=imagesIdUrl%>" width="320" height="230" border="0">
		</td>
		</tr>
		
		</table>
	<%
}

 %>
<!--/div-->
</td>
</tr>
</table>
<div class="shadow1"><div class="shadow2">&nbsp;</div></div>
<%
}
rs.close();
%>
<!-- สรุป -->

<table width="100%" cellpadding="0" cellspacing="0" border="0">
<tr>
<td class="frm">

<table width="100%" cellpadding="0" cellspacing="0">
<tr>
<td class="title03" colspan="2">จำนวนรวม <font style="padding-left:20px"><%=count%> รายการ</font></td>
</tr>
<tr>
<td class="title03" colspan="2">จำนวเงินรวมสุทธิ <font style="padding-left:20px"><%=doString.displayNumber("#,##0.00",net_total)%> บาท</font></td>
</tr>
<tr>
<td class="item2" width="80">Comment </td>
<td class="answer2"><%=doString.DisplayThai(i_remark)%></td>
</tr>
<tr>
<td class="lineitem2" colspan="2"><%=doString.DisplayThai(n_nemploy_2+" "+n_semploy_2)%>  เบอร์โทร <%=doString.DisplayThai(i_mobile_sender)%></td>
</tr>
</table>
</td>
</tr>
</table>

<div class="shadow1"><div class="shadow2">&nbsp;</div></div>

<!-- End of สรุป -->

<%
/*******************
//* [APR]AFEFWF1434556GHMBVGF[/APR]
//*	String appr_subj = "LHSERV_LH_"+docNo+"_A";  Approve
//*	String appr_body = "[APR]"+doString.encode(docNo+"_A")+"[/APR]";  LH-075-5600089_A ,LH-075-5600089_D,LH-075-5600089_B 
//*	String deny_subj = "LHSERV_LH_"+docNo+"_D";  Approve
//*	String roteback_subj = "LHSERV_LH_"+docNo+"_B";  Approve 
//*******************/

//appr_subj = doString.encode("LEAVE_LH_"+docNo+"_A_"+docNo+"_A");  

String appr_subj = "LHSERV_LH_"+i_document+"_A";
String appr_body = "[APR]"+doString.encode(i_document+"_A")+"[/APR]";
String tag_msg = "[COMMENT]  [/COMMENT]";

String routeback_subj = "LHSERV_LH_"+i_document+"_B";
String routeback_body = "[APR]"+doString.encode(i_document+"_B")+"[/APR]";

//.append("<a href=\"mailto:application@lh.co.th?subject="+appr_subj+"&body="+appr_body+"\">Approve</a></td>")
//.append("<a href=\"mailto:application@lh.co.th?subject="+back_subj+"&body="+back_body+"\">Route Back</a></td>")

 %>

<!-- การอนุมัติ -->
<%
if(!"disable".equals(fstatus)){
 %>
<a name="approvement"></a>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
<tr>
<td class="frm">
<table width="100%" cellpadding="0" cellspacing="0">
<tr>
<td class="title">กรุณา Reply E-Mail For :</td>
</tr>
<%
//2016.01.20
//System.out.println("net_total :"+net_total);
//ServletContext context = session.getServletContext();
//String realContextPath = context.getRealPath(request.getContextPath());
//String targetPath = getServletContext().getRealPath("/pictures/")+File.separator+i_document;
//int attCnt = CountImage(targetPath);
//int dbCnt  = CountSERV_DOCATT(conn,i_document);
 if(net_total > 500 && countImg == 0 ) {%>
<tr >
	<td class="action">
	<font style="color:red">
	 ***คำเตือน!! จำนวนเงินมากกว่า 500 บาทและไม่มีการแนบรูป โปรดตรวจสอบก่อนอนุมัติ ** <br>
	 </font>
	</td>
</tr>
<%} %>
<tr>
<td class="action"><a href="mailto:application@lh.co.th?subject=<%=appr_subj%>&body=<%=appr_body+tag_msg%>">Approve  <font style="color:red">(จำนวน <%=count%> รายการ เป็นเงิน <%=doString.displayNumber("#,##0.00",net_total)%> บาท)</font></a></td>
</tr>
	<!-- 
	<tr>
	<td class="action"><a href="#approvement">Deny</a></td>
	</tr>
	-->
<tr>
<td class="action"><a href="mailto:application@lh.co.th?subject=<%=routeback_subj%>&body=<%=routeback_body+tag_msg%>">Route Back</a></td>
</tr>

	<tr>
		<td class="action">ใบแจ้งซ่อมเลขที่ : <a href="<%=apprURL%>"><%=i_document %></a></td>
	</tr>
	
</table>
</td>
</tr>
</table>

<div class="shadow1"><div class="shadow2">&nbsp;</div></div>
<%} %>

<!--  End of การอนุมัติ -->

</BODY>

</HTML>
<script>
function reloadImage(img) {
  img.onerror = null

  let url = new URL(img.src)
  url.searchParams.set('reload', 'true')
  img.src = url.toString()
}</script>
<%
}catch(Exception e){
	System.out.println("!!! ERROR SERV_BeyondMail.jsp : " + e.getMessage()); 
	throw new ServletException(e.getMessage());
}finally{
	// Clean up.
	try {
		if (rs != null) rs.close();
		if (stmt != null) stmt.close();
		if (rs1 != null) rs1.close();
		if (stmt1 != null) stmt1.close();
		if (conn != null) conn.close();
	}
	catch( SQLException ignore ){}
}
%>