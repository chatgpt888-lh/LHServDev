<%@page import="java.math.BigDecimal"%>
<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="java.text.*" %>
<%@page import="java.io.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%!    
/**
 * Modify by : pradoem@lh.co.th
 * date : 2015.06.30
 * version 1.1
 * desc: 
 *  1. 
 *  2.
 */ 
 
 public BigDecimal GetSumAmountPay(Connection conn, String docId) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		//String  projectName = "";
		BigDecimal amount = new BigDecimal("0");
     try{
     		//initial paramter	     	
			/*************************************************/			
     		sql.delete(0,sql.length());
			sql.append(" select sum(z_amount_pay) as amount from lan:serv_docdt  where i_docno =? ");
			pstmt = conn.prepareStatement(sql.toString());
			pstmt.setString(1, docId); 
			rs = pstmt.executeQuery();
			if(rs.next()){
				amount  = new BigDecimal(doString.checkString(rs.getString("amount"), "0"));
			}
			rs.close();	
		}catch(Exception e){
			System.out.println(" GetSumAmountPay Error : " + e.getMessage());
		}
		finally{			
			//clean up.
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
			}catch(Exception e){}
		}
	  return amount;		
	}
%>

<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_TurnkeyApprList.jsp";
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
   String houseId = doString.checkString(request.getParameter("i_house"),"").toUpperCase();
   String lock = doString.checkString(request.getParameter("i_lock"),"").toUpperCase();
   String condition = "";
			       
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	SERV_CommonData common = null;

	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();   
		common = new SERV_CommonData(conn);     
        //----=======================================----//   
        
  
        //---====================== Generate Serrch Condition ===========================---//
        if (selProj.trim().length()>=6 && !selProj.equalsIgnoreCase("ALL")) {
           //condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
		   condition = " and a.i_company='"+(selProj.substring(0,2))+"' and a.i_project='"+(selProj.substring(3,6))+"' ";
        }
        
        
		if (selProj.trim().length()<=0) {
		   String projList = common.getProjectListByUserId(user.getUserID());
		   if (projList.length()>0) {
			   //================== modified to used index field =====================//
				if (projList.trim().length()>0) {
					String projCondition = "";
					StringTokenizer plist = new StringTokenizer(projList,",");
					String proj = "";
					String icom = "";
					String iproj = "";

					while (plist.hasMoreTokens()) {
						proj = str.replace(plist.nextToken(),"'","").trim();
						if (proj.length()>=6) {
							icom = proj.substring(0,2);
							iproj = proj.substring(3,6);
							if (projCondition.trim().length()>0) projCondition += " or ";
							projCondition += " (a.i_company='"+icom+"' and a.i_project='"+iproj+"') ";
						}
					} // end while

					if (projCondition.trim().length()>0) {
						condition = " and ("+projCondition+") ";
					}
				}
				//===============================================================//
		   } else {

			sql.delete(0,sql.length());
			sql.append(" select count(*) from serv_pstaff  where user_id='").append(user.getUserID()).append("' and proj_id='ALL' ");
			int checkAllPermission = 0;

			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
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
        if (docNo.trim().length()>0) {
           condition += " and a.i_docno='"+docNo+"' ";
        }
        if (houseId.trim().length()>0) {
           condition += " and b.i_house='"+houseId+"' ";
        }
        if (lock.trim().length()>0) {
           condition += " and a.i_lock='"+lock+"' ";
        }                
 	    //---=========================================================================----//     
        //----====================== Get DOCHD Max Row ==============================-----//
        int maxRow = 0;
         sql.delete(0,sql.length());
         sql.append("  Select count(*) cnt From lan:serv_dochd a ,lan:acxlckmd b,lan:acscontr c, lan:serv_approve x   ")
              .append(" Where a.f_status='OPN'  and a.f_status != 'CAN'   ")
              .append(" AND b.i_company=a.i_company and b.i_project=a.i_project and b.i_lock=a.i_lock  ")
              .append(" AND c.i_company=a.i_company and c.i_project=a.i_project and c.i_lor=b.i_lor and c.f_contr is null ")
              .append(" AND a.i_docno = x.i_docno  and x.i_doc_type = '2' and  x.i_employ_appcur = '"+user.getEmpId()+"'  ")
              .append(" and a.c_desc !='Checkup Program'  ")
              .append(condition);
   
       // System.out.println("SQL Get Row :"+sql.toString());     
		servlog.startLog(sql.toString());
        rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
        if (rs.next()) {        
           maxRow = rs.getInt("cnt");  
        }
        rs.close();
	   //---=========================================================================----//                

	   //-----============== Generate Display Customize and Page Link ==================-----//
	   String displayType = doString.checkString(request.getParameter("display_type"),"");    
	   int displayLine = Integer.parseInt(doString.checkString(request.getParameter("display_line"),"0"));
	   int nowPage = Integer.parseInt(doString.checkString(request.getParameter("now_page"),"1"));
	   if (displayType.equalsIgnoreCase("A")) {
	      displayLine = maxRow;
	      nowPage = 1;
	   }
	   if (displayLine<Constants.SERV_OPENJOBLIST_LINE) displayLine = Constants.SERV_OPENJOBLIST_LINE;      
	   
	   int startRow = ((nowPage-1)*displayLine);
	   int endRow = startRow+displayLine;
	   int tmpMax = maxRow;
	   
	   String pageLink = "";
	   int tmpPage = 0;
	   while (tmpMax>0) {
	       tmpMax -= displayLine;
	       tmpPage++;
	       if (nowPage==tmpPage) {
	          pageLink += "&nbsp; <b>"+tmpPage+"</b> ";
	       } else {
	          pageLink += "&nbsp; <a href='#' onclick='changePage("+tmpPage+");'>"+tmpPage+"</a> ";
	       }
	   }
	   
	   if (tmpPage>1) {
	      int prev = nowPage-1;
	      if (prev<1) prev=1;  
	      pageLink = "<a href='#' onclick='changePage("+prev+");'>หน้าก่อน</a>&nbsp; "+pageLink;
	      int next = nowPage+1;
	      if (next>tmpPage) next = tmpPage;
	      pageLink += "&nbsp; <a href='#' onclick='changePage("+next+");'>หน้าถัดไป</a>";      
	   } else {
	      pageLink = "หน้า <b>1</b>";
	   }
	 //---=========================================================================----//                
%>
<html>
<HTML lang="th">
<HEAD>

<TITLE>TurnKey Approve List::บริการหลังการขาย</TITLE>

<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />

<link rel="stylesheet" href="tablesaw.stackonly.css">
<script src="jquery.js"></script>
<script src="tablesaw.stackonly.js"></script>


<style type="text/css">
TD		{ 	font-size:10.0pt ; font-family:Microsoft Sans Serif Tahoma Verdana ; color:rgb(0,120,255) ; 	}
.item					{	color: rgb(255,100,0) ; 	}
.item	A:link		{	color: rgb(255,100,0) ; text-decoration: underline ;	}
.item	A:visited	{	color: rgb(255,100,0) ; text-decoration: none ;	}
.item	A:hover	{	color: rgb(255,100,0) ; text-decoration: underline ; background-color: rgb(255,255,180) ;	}

.item_tab1	{	background:url(images/item_tab1.gif) ; background-repeat:no-repeat ; width:30px ; 
							height:20px ; text-align:center ; display:inline-block ; border:0px solid red ; vertical-align:top ;   }
					  
.item_tab2	{	background:url(images/item_tab2.gif) ; background-repeat:repeat-x ; height:20px ; 
							color: rgb(0,0,120) ; font-size: 10pt ; vertical-align:middle ; 
							display:inline-block ; border:0px solid red ;  }
	
.item_tab3	{	background:url(images/item_tab3.gif) ; background-repeat:no-repeat ; 
							width:25px ; height:20px ; display:inline-block ; border:0px solid red ; 			}	

.box	{	font-family: Microsoft Sans Serif Tahoma Verdana ; font-size:10pt ; font-weight:normal ;
				padding-top: 1px ; padding-right: 1px ; padding-bottom: 1px ; padding-left: 1px ; 
	 			color:rgb(0,80,220) ; background-color: white ; border: 1px #BEDCFF solid ;  	}
				
.boxC	 {	font-family: Microsoft Sans Serif Tahoma Verdana ; font-size:10pt ; font-weight:normal ;
				padding-top: 1px ; padding-right: 1px ; padding-bottom: 1px ; padding-left: 1px ; 
	 			color:rgb(0,80,220) ; background-color: white ; border: 1px #BEDCFF solid ; text-align:center ;   	}				

.Res_bigh	{	font-size: 11.0pt ; font-family: Microsoft Sans Serif Tahoma Verdana ; 
									color: rgb(0,80,220) ; TEXT-DECORATION: none ; letter-spacing:0em ; text-indent:0px ; 
									display:block ; padding:10px 0px 10px 0px ;  	}
				
.Res_BD	{	text-align:left ;  padding:0px 10px 0px 10px	}				
		
.Res_item	{	font-family: Microsoft Sans Serif Tahoma Verdana ; font-size:10pt ; font-weight:normal ;
									color: rgb(255,100,0) ; font-size:10pt ; display:inline-block ; 
									vertical-align:middle ; height:25px ; width:105px ; 
									border-bottom:1px dotted rgb(220,220,220) ; border-right:0px solid rgb(135,185,247) ; padding:3px ; 	}						
							
.Res_answer	{	font-family: Microsoft Sans Serif Tahoma Verdana ; font-size:10pt ; font-weight:normal ; 
									display:inline-block ; color:rgb(0,80,220) ; 
									vertical-align:middle ; height:25px ;  width:180px ; 
									border-bottom:1px dotted rgb(220,220,220) ; border-right:0px solid rgb(135,185,247) ; padding:3px ;	 	}

.Res_answer2	{	font-family: Microsoft Sans Serif Tahoma Verdana ; font-size:10pt ; font-weight:normal ; 
									display:inline-block ;  padding:3px ; color:rgb(0,80,220) ; border:0px solid red ; 
									vertical-align:middle ; width:180px ; height:20px ; 
							 	}
									
.Res_lineitem	{	display:inline-block ; 	}


.Res_frmLR						{	border-top:1px solid rgb(135,185,247) ; border-bottom:1px solid rgb(135,185,247) ;
											border-left:1px solid rgb(135,185,247) ; border-right:1px solid rgb(135,185,247) ;
											padding:10px 10px 10px 10px ; text-align:left ; display:block ; 		}

.shadow1 {	width:100% ; height:20px ; text-align:center ; display:block ;    	}
.shadow2 {	width:97% ; display:inline-block ;
						background-image:url(images/shadow.gif) ; 	
						background-repeat:repeat-x ;  		}

.Res_frmTable {	border-top:1px solid rgb(135,185,247) ; border-bottom:1px solid rgb(135,185,247) ;
								border-left:1px solid rgb(135,185,247) ; border-right:0px solid rgb(135,185,247) ;
								padding:0px ; text-align:left ; display:block ; 		}

.Res_col_name	{	font-size: 8.0pt ; color: rgb(0,50,200) ; text-align: center ;  height:25px ; 
								background-image: url(images/col_bg1.gif) ; background-repeat : repeat-x ;
								border-right:1px solid rgb(135,185,247) ; border-bottom:1px solid rgb(135,185,247) ; 	}

.Res_dotline{	border-bottom:1px dashed rgb(220,220,220) ; border-right:1px solid rgb(135,185,247) ; 
								padding:5px ;  	 }

.pageBar	{	font-family: Microsoft Sans Serif Tahoma Verdana ; font-size:10pt ; color:rgb(0,80,220) ; 
								width:100% ; height:20px ; text-align:right ; background-color:rgb(240,240,240) ; 
								vertical-align:middle ; 		}

BODY{		font-family: Microsoft Sans Serif Tahoma Verdana ; font-size:10pt ;
						background : url() ; background-repeat : repeat-y ; 
					  	scrollbar-face-color					:		rgb(220,240,255)		; 
			  			scrollbar-shadow-color			: 		rgb(220,240,255)		; 
			  			scrollbar-highlight-color			:		rgb(220,240,255)		; 
			  			scrollbar-3dlight-color 			: 		rgb(255,255,255)		; 
			  			scrollbar-darkshadow-color	: 		rgb(120,180,255)		; 
			  			scrollbar-track-color 				: 		rgb(255,255,255)		; 
			  			scrollbar-arrow-color 				: 		rgb(120,180,255)		;		}
	
.Res_act_tab1	{	background:url(images/act_tab1.gif) ; background-repeat:no-repeat ; 
								width:5px ; height:30px ; }					  
.Res_act_tab2	{	background:url(images/act_tab2.gif) ; background-repeat:repeat-x ; 
								height:30px ; vertical-align: top ; }		
.Res_act_tab3	{	background:url(images/act_tab3.gif) ; background-repeat:no-repeat ;
								width:57px ; height:30px ; }	
.Res_act_tab4	{	background:url(images/act_tab4.gif) ; background-repeat:repeat-x ; 
								height:30px ; text-align: right ; }		
</style>


<script language="javascript" src="script_fx.js"></script>

<!-- add by pradoem 2023.02.15 -->
<script src="jquery3/jquery.min3.6.3.js" ></script>
<script src="jquery3/loadingoverlay.min2.1.7.js"></script>

<script language="javascript">
  function searchDocHD() {
     pleaseWaiting();
     document.forms[0].now_page.value='1';
     document.forms[0].target="";  
     document.forms[0].action="<%=request.getContextPath() %>/SERV_TurnkeyApprList.jsp";
     document.forms[0].submit();  
  }

  function changePage(page) {
     pleaseWaiting();
     document.forms[0].now_page.value=page;
     document.forms[0].target="";  
     document.forms[0].action="<%=request.getContextPath() %>/SERV_TurnkeyApprList.jsp";
     document.forms[0].submit();
  }  
  
  function go2ApproveTK(doc) {
     pleaseWaiting();
	 document.forms[0].i_docno.value=doc;
	 document.forms[0].target="_blank";  
	 document.forms[0].action="<%=request.getContextPath() %>/SERV_TurnkeyApprDisp.jsp";
	 document.forms[0].submit();
  }
  
  function pleaseWaiting(){
   $.LoadingOverlay("show");
	// Hide it after 3 seconds
	setTimeout(function(){
	    $.LoadingOverlay("hide");
	}, 4000);
  }
</script>


<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<form action="">
<input type="hidden" name="now_page" value="<%=nowPage%>">



<div class="Res_BD" >
  <div class="Res_bigh">
    <span style="padding-right:10px"><img border="0" src="images/i_home.gif" width="20" height="20" align="absmiddle"></span>รายละเอียดการอนุมัติจากพนักงาน Turn Key : Wait</div>

<div style="display:block ; text-align:left ; border:0px solid black">     
<table border="0" width="215" cellspacing="0" cellpadding="0">
<tr>
<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
<td class="item_tab2" width="160">รายละเอียดการแจ้งซ่อม</td>
<td class="item_tab3"></td>
</tr>
</table>
</div>            



<div class="Res_frmLR">
<span class="Res_lineitem">
    <span class="Res_item">โครงการ :</span>
    <span class="Res_answer">
		 <%=common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj,"  class='box' style='width:188px' ",true)%>       
    </span>
</span>    

<span class="Res_lineitem">
    <span class="Res_item">เลขที่ใบแจ้งซ่อม :</span>
    <span class="Res_answer">
    	<input type="text" name="i_docno" maxlength="15"  class="box" style="width:100px" value="<%=docNo%>">
    </span>
</span>

<span class="Res_lineitem">
    <span class="Res_item">บ้านเลขที่ :</span>
    <span class="Res_answer">
   			 <input type="text" name="i_house"   maxlength="10"  class="box" style="width:100px" value="<%=houseId%>">
    </span>
</span>

<span class="Res_lineitem">    
    <span class="Res_item">แปลง :</span>
    <span class="Res_answer"> 
    	<input type="text" name="i_lock" class="box" maxlength="5" style="width:100px" value="<%=lock%>">
    <a href="#" onClick="searchDocHD();"><img border="0" src="images/i_search.gif" align="absmiddle" width="20" height="20" hspace="10"></a> 
    </span>
  </span>
  
</div>
<div class="shadow1"><div class="shadow2">&nbsp;</div></div>




<div style="display:block ; text-align:left ; border:0px solid black">
<table width="215" height="20" cellpadding="0" cellspacing="0" style="display:block ; vertical-align:bottom">
<tr>
<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
<td class="item_tab2" style="width:160px">รายการซ่อม</td>
<td class="item_tab3"></td>
</tr>
</table>
<span style="display:block ; vertical-align:middle ; border:1px solid rgb(135,185,247) ; padding:3px">
<span class="Res_answer2" style="width:300px">
	<input type="radio" value="L" checked name="display_type" <%=(displayType.equalsIgnoreCase("L") ? "checked" : "")%>>แสดงจำนวนรายการ
	<input type="text" name="display_line" class="boxC" style="width:50px" value="<%=displayLine%>">&nbsp; รายการต่อหน้า</span>
<span class="Res_answer2" style="width:180px">
	<input type="radio" value="A" name="display_type" <%=(displayType.equalsIgnoreCase("A") ? "checked" : "")%>>แสดงรายการทั้งหมด
<a href="#" onClick="changePage(1);"><img border="0" src="images/bu_R.gif" align="absmiddle" style="cursor:hand" width="16" height="16" hspace="5"></a></span>
</span>
</div>


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="Res_frmTable" style="border-top:0px">
    
<table border="0" width="100%" cellspacing="0" cellpadding="0" class="tablesaw tablesaw-stack" data-tablesaw-mode="stack">
<thead>
<tr>
          <th class="Res_col_name" scope="col" data-tablesaw-sortable-col data-tablesaw-sortable-default-col data-tablesaw-priority="3">แปลง</th>
          <th class="Res_col_name" scope="col" data-tablesaw-sortable-col data-tablesaw-priority="2">จำนวนเงิน (บาท)</th>
          </tr>
</thead>
<tbody>

    <%
			String iDocNo = "";
			String iLock = "";
			String iHouse = "";
			String iLor = "";
			String nCustomer = "";
			String nCustTel = "";
			String iDocType = "";
			String iCompany = "";
			String iProject = "";		
			//Hashtable tmpCust = new Hashtable();
			String ownName = "";
			String ownTel = "";
			
			BigDecimal amountPay = null;
									
			
			String keyinDate = "-";
		    Calendar keyin = Calendar.getInstance();
     
		     //----================== Select Data from SERV_DOCHD ================----//   
		      int line = 0;		     
		      sql.delete(0,sql.length());		      
      	 	// sql.append("  Select first ").append(endRow).append(" b.i_house,b.i_lor,c.i_exp_intent1,c.i_cus_intent1,a.*  From lan:serv_dochd a ,lan:acxlckmd b,lan:acscontr c, lan:serv_approve x   ")
              sql.append("  Select first ").append(endRow).append(" a.i_docno,a.i_lock From lan:serv_dochd a ,lan:acxlckmd b,lan:acscontr c, lan:serv_approve x   ")
      	 	   .append(" Where a.f_status='OPN'  and a.f_status != 'CAN'  ")
             	.append(" AND b.i_company=a.i_company and b.i_project=a.i_project and b.i_lock=a.i_lock  ")
              	.append(" AND c.i_company=a.i_company and c.i_project=a.i_project and c.i_lor=b.i_lor and c.f_contr is null ")
              	.append(" AND a.i_docno = x.i_docno  and x.i_doc_type = '2' and  x.i_employ_appcur = '"+user.getEmpId()+"'  ")
              	.append(" and a.c_desc !='Checkup Program'  ")
              	.append(condition)
              	.append(" order by a.i_docno,a.i_lock ");

		      // System.out.println("SQL Get Data :"+sql.toString());     

				servlog.startLog(sql.toString());
		        rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
		        for (int i=0;i<maxRow;i++) { 
                      if (rs.next()) {
                         if (i>=startRow && i<=endRow) {
                            //------ Data is in this page , display -----//
				            iDocNo = doString.checkString(rs.getString("i_docno"),"");
				            iLock = doString.checkString(rs.getString("i_lock"),"");
				            /*iHouse = doString.checkString(rs.getString("i_house"),"");
				            iLor = doString.checkString(rs.getString("i_lor"),"");
				            nCustomer = doString.checkString(doString.DisplayThai(rs.getString("n_customer")),"");
				            nCustTel = doString.checkString(doString.DisplayThai(rs.getString("n_cus_tel")),"");
				            iDocType = doString.checkString(rs.getString("i_doc_type"),"");
				            iCompany = doString.checkString(rs.getString("i_company"),"");
				            iProject = doString.checkString(rs.getString("i_project"),"");*/
						
							//tmpCust = common.getCustomerDetails(iCompany,iProject,iLock);
							//ownName = doString.DisplayThai(doString.checkString((String) tmpCust.get("n_customer"),""));
							//ownTel = doString.DisplayThai(doString.checkString((String) tmpCust.get("n_cust_tel"),""));
					    			
							amountPay = this.GetSumAmountPay(conn, iDocNo);
							
				            //keyinDate = "-";			            
			                //---- Keyin Date ----// 
						    /*Timestamp tmp = rs.getTimestamp("d_keyin");
						    if (tmp!=null)  {
						        keyin.setTime(tmp);      
							    keyinDate = getDateFromCalendar(keyin);    
							    keyinDate += "&nbsp;&nbsp;"+getTimeFromCalendar(keyin)+" น.";    		            
						    } */
					        %>
							<tr>
									<td class="Res_dotline ; item"><a href="javascript:go2ApproveTK('<%=iDocNo %>');"><%=iLock %> (<%=iDocNo %>)</a></td>
									<td class="Res_dotline"><%=format.format(amountPay)%></td>
							</tr>              
 					 <%					        
 					         line++;                         
                         } // end if check row                         
                         if (i>endRow) break;                         
                      } //end if check rs
                } // end for
                
	           while (line<10) {
	               line++;
	                %>
					<tr>
						 <td class="Res_dotline ; item">&nbsp;</td>
						 <td class="Res_dotline">&nbsp;</td>
					 </tr>           
	                <%               
	           }
        %>
	</tbody>            	                
	</table>
    </td>
  </tr>
</table>

<div class="shadow1"><div class="shadow2">&nbsp;</div></div>
<div class="pageBar"><b>หน้า </b><%=pageLink%></div>

<br style="font-size:10pt">


        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="Res_act_tab1"></td>
            <td class="Res_act_tab2" width="75"></td>                  	
            <td class="Res_act_tab3"></td>   
            <td class="Res_act_tab4"><a href="javascript:history.back()" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="/LHServ/SERV_Index.jsp" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>  
        </table>  

</div>

<br style="font-size:20pt">


</form>	
</BODY>

</HTML>

<%     System.out.println("----- SERV_TurnkeyApprList.jsp --------");
	} catch (Exception e) {
		System.out.println("ERROR SERV_TurnkeyApprList.jsp : " + e.getMessage());
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