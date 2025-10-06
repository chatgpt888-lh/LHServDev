<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%!  
   public String ToThaiDateFormat(String date){
       if(!date.equals("")){
	        String time = date.substring(10);
			String yy = date.substring(0,10);
			String delimeter = "-";
			String [] temp = yy.split(delimeter);	
		 return temp[2]+"/"+temp[1]+"/"+ (Integer.parseInt(temp [0])+543)+time;
		}else{
		 return date;
		}
   }
 
 %>
<%
/************************************/
// create by pradoem
// date : 2012-03-13
// decription : for E-Service system Open job list  eser_dochd krub.
// version :1.0 
/************************************/
	String sessionId = user.getsessionId();
	String userId = user.getUserID();
	String jName = "ESERV_OpenJob_List.jsp";
	ServLog servlog = new ServLog(sessionId, userId, jName);
    doString str = new doString();
   //******************************* Declare Variables for input data ********************************//
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
        //************************** Initialize Variable **************************//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();   
		common = new SERV_CommonData(conn);     
        //***************************************************************************//   

        //************************** Generate Serrch Condition **************************//
        if (selProj.trim().length()>=6 && !selProj.equalsIgnoreCase("ALL")) {
           //condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
		   condition = " and a.i_company='"+(selProj.substring(0,2))+"' and a.i_project='"+(selProj.substring(3,6))+"' ";
        }
		if (selProj.trim().length()<=0) {
		   String projList = common.getProjectListByUserId(user.getUserID());
		   if (projList.length()>0) {
			   //condition += " and substr(a.i_docno,1,6) in ("+projList+") ";
			   //************************** modified to used index field **************************//
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
				//****************************************************//
		   } else {
				sql.delete(0,sql.length());
				sql.append(" select count(*) from lan:serv_pstaff  where user_id='")
					.append(user.getUserID())
					.append("' and proj_id='ALL' ")
					.append(" AND d_keyin >= ADD_MONTHS(SYSDATE, -12) ")//fix by petch
                	;
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
           condition += " and a.i_eser_docno='"+docNo+"' ";
        }
        if (houseId.trim().length()>0) {
        	condition += " and a.i_house='"+houseId+"' ";
        }
        if (lock.trim().length()>0) {
           condition += " and a.i_lock='"+lock+"' ";
        }                
 	   //******************************************************************************//   
        //************************** Get DOCHD Max Row **************************//
        int maxRow = 0;
        sql.delete(0,sql.length());
        sql.append("select count(*) cnt from lan:eser_dochd a ")
              .append(" where a.f_status='OPN' ")
              .append(condition)
              .append(" AND a.d_keyin >= ADD_MONTHS(SYSDATE, -12) ")//fix by petch
              ;
		servlog.startLog(sql.toString());
        rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
        if (rs.next()) {        
           maxRow = rs.getInt("cnt");  
        }
        rs.close();
	   //**********************************************************************************************//                
	   //************************** Generate Display Customize and Page Link **************************//
	   String displayType = doString.checkString(request.getParameter("display_type"),"");    
	   int displayLine = Integer.parseInt(doString.checkString(request.getParameter("display_line"),"0"));
	   int nowPage = Integer.parseInt(doString.checkString(request.getParameter("now_page"),"1"));
	   String criteria = doString.checkString(request.getParameter("criteria"),""); 
	   if (displayType.equalsIgnoreCase("A")) {
	      displayLine = maxRow;
	      nowPage = 1;
	   }
	 //remark by pradoem 2012-03-13
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
	 //***********************************************************************************************//                
%>
<HTML>
<HEAD>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />


<TITLE>Open Job List</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<style type="text/css">
 .box2 {  font-family: Tohama,Arial,sans-serif; font-size:10.1pt; font-weight:normal;
		padding-top: 1px; padding-right: 1px; padding-bottom: 1px; padding-left: 1px; 
	 	color:#165396; background-color: white; border: 1px #BEDCFF solid ; 
}

.select2-selection__rendered {
  	font-family: Tohama, Arial, sans-serif;
    font-size: 10.1pt;
    color: #165396 !important;
}


.select2-results__option {
    font-family: Tohama, Arial, sans-serif;
    font-size: 10.1pt;
    color: #165396 
}    
    
</style>
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
<!--

function queryProject() {
   }

$(document).ready(function() {
      $('#sel_project').select2({
         matcher: function(params, data) {
            if ($.trim(params.term) === '') {
                return data;
            }
            var searchTerm = params.term.trim().toLowerCase().replace(/-/g, '');
            var optionText = (data.text || '').toLowerCase().replace(/-/g, '');

            if (optionText.indexOf(searchTerm) > -1) {
                return data;
            }

            return null;
        }
    });
});



  function searchDocHD() {
     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/ESERV_OpenJob_List.jsp";
     document.forms[0].submit();  
  }
  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/ESERV_OpenJob_List.jsp";
     document.forms[0].submit();
  } 
  
   function doOpenJob(docId) {
     document.forms[0].action="<%=Constants.APP_PATH%>/ESERV_OpenJobServlet?cmd=find&i_docno="+docId;
     document.forms[0].submit();
  }
  
   

//-->
</script>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM METHOD="POST" ACTION="">
<input type="hidden" name="now_page" value="<%=nowPage%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" > 
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">
          &nbsp;Open Job List : Wait</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>
<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดการแจ้งซ่อม</td>
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
		    <td class="item ; dotline01" height="22" width="15%">โครงการ :</td>
		    <td height="22" width="39%" class="dotline01">
		    <%=common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box2' style='width:250px' ",true)%> 
		    </td>
		    <td height="22" class="item ; dotline01" width="14%">เลขที่เอกสาร :</td>
		    <td height="22" width="32%" class="dotline01"><input type="text" name="i_docno" class="box" style="width:100px" value="<%=docNo%>"></td>
		  </tr>
		  <tr>
		    <td class="item ; dotline01" height="22" width="15%">บ้านเลขที่ :</td>
		    <td height="22" width="39%" class="dotline01"><input type="text" name="i_house" class="box" style="width:100px" value="<%=houseId%>"></td>
		    <td height="22" class="item ; dotline01" width="14%">แปลง :</td>
		    <td height="22" width="32%" class="dotline01"> <input type="text" name="i_lock" class="box" style="width:100px" value="<%=lock%>">&nbsp;&nbsp;&nbsp;&nbsp;
		      <a href="javascript:searchDocHD();" ><img border="0" src="images/i_search.gif" align="absmiddle" width="20" height="20"></a> </td>
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
                <td class="item_tab2" width="160">รายการซ่อม</td>
                <td class="item_tab3"></td>
                <td>&nbsp;<input type="radio" value="L" checked name="display_type" <%=(displayType.equalsIgnoreCase("L") ? "checked" : "")%>>แสดงจำนวนรายการต่อหน้า&nbsp;
                  <input type="text" name="display_line" class="boxC" style="width:50px" value="<%=displayLine%>">
                  &nbsp; รายการ&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" value="A" name="display_type" <%=(displayType.equalsIgnoreCase("A") ? "checked" : "")%>> แสดงรายการทั้งหมด&nbsp;&nbsp;&nbsp;&nbsp;
                  <a href="javascript:changePage(1);"><img border="0" src="images/bu_R.gif" align="absmiddle" style="cursor:hand" width="16" height="16"></a>
                  </td>
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
          <td width="14%" class="col_name">เลขที่เอกสาร</td>
          <td width="7%" class="col_name">แปลง</td>
          <td width="8%" class="col_name">บ้านเลขที่</td>
          <td width="16%" class="col_name">วันเวลาที่แจ้ง</td>
          <td width="39%" class="col_name">ชื่อผู้แจ้ง / ลูกค้า</td>
          <td width="16%" class="col_name">โทรศัพท์ติดต่อ</td>
          <td  class="col_name">จากระบบ</td>
          
        </tr>
        <%
			String iDocNo = "";
			String iLock = "";
			String iHouse = "";
			//String iLor = "";
			String nCustomer = "";
			String nCustTel = "";					
			String dKayin = "";
		    int line = 0;		
		    // sql.delete(0,sql.length());
			//sql.append("select first ").append(endRow).append(" a.* from lan:eser_dochd a ")
			// .append(" where a.f_status='OPN' ").append(condition)
			//.append(" order by a.i_eser_docno ");
			//servlog.startLog(sql.toString());
		    
		     if(criteria.equalsIgnoreCase("true")){    
			    sql.delete(0,sql.length());
			    sql.append("select first ").append(endRow).append(" b.* from lan:serv_pstaff a,lan:eser_dochd b  ")
			              .append(" where b.f_status='OPN' ")
                          .append(" and a.user_id = '"+userId+"' and a.com_id = b.i_company ")
                          .append(" and a.proj_id = b.i_project ")
                          .append(" AND b.d_keyin >= ADD_MONTHS(SYSDATE, -12) ") //fix by petch
			              .append(" order by b.i_eser_docno desc ");
					     servlog.startLog(sql.toString());
		    }else{
		    	sql.delete(0,sql.length());
		    	 sql.append("select first ").append(endRow).append(" a.* from lan:eser_dochd a where a.f_status='OPN' ")
                .append(condition)
                .append(" AND a.d_keyin >= ADD_MONTHS(SYSDATE, -12) ")//fix by petch
                .append(" order by a.i_eser_docno desc");
		    	//select count(*) from lan:eser_dochd a where a.f_status='OPN'  and a.i_company='AR' and a.i_project='002' 
		    }	
		    
		  // System.out.println("SQL :"+sql.toString());	
		    rs = stmt.executeQuery(sql.toString());

				servlog.endLog();
		        for (int i=0;i<maxRow;i++) { 
                      if (rs.next()) {
                         if (i>=startRow && i<=endRow) {
	                            //------ Data is in this page , display -----//
					            iDocNo = doString.checkString(rs.getString("i_eser_docno"),"");
					            iLock = doString.checkString(rs.getString("i_lock"),"");
					     		dKayin =  doString.checkString(rs.getString("d_keyin"),"");
					            iHouse = doString.checkString(rs.getString("i_house"),"");				     
					            nCustomer = doString.checkString(doString.DisplayThai(rs.getString("n_customer")),"");
					            nCustTel = doString.checkString(rs.getString("n_cus_tel"),"");
					        %>
					        <tr>
					          <td width="14%" align="center" class="dotline"><a href="javascript:doOpenJob('<%=iDocNo%>');"><%=iDocNo%></a></td>
					          <td width="7%" class="dotline" align="center"><%=iLock%></td>
					          <td width="8%" class="dotline" align="center"><%=iHouse%></td>
					          <td width="16%" align="center" class="dotline"><%=ToThaiDateFormat(dKayin)%> น.</td>
					          <td width="39%" class="dotline ; item"><%=nCustomer%></td>
					          <td width="16%" align="center" class="dotline"><%=doString.DisplayThai(nCustTel)%></td>
					          <td align="center" class="dotline">
					          <%if(iDocNo.indexOf("L-")!= -1){ %>
					           <img src="https://img.icons8.com/color/18/000000/line-me.png">
					           <%}else{ %>
					             EVC
					           <%} %>
					          </td>
					        </tr>
					        <%				        
 					         line++;                         
                         } // end if check row                       
                         if (i>endRow) break;                         
                      } //end if check rs
                } // end for             
	           while (line<displayLine) {
	               line++;
	                %>
				        <tr>
				          <td width="14%" align="center" class="dotline">&nbsp;</td>
				          <td width="7%" class="dotline" align="center">&nbsp;</td>
				          <td width="8%" class="dotline" align="center">&nbsp;</td>
				          <td width="16%" align="center" class="dotline">&nbsp;</td>
				          <td width="39%" class="dotline ; item">&nbsp;</td>
				          <td width="16%" align="center" class="dotline">&nbsp;</td>
				          <td  align="center" class="dotline">&nbsp;</td>
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
	<br style="font-size:3pt">
	      <table border="0" width="100%" cellspacing="0" cellpadding="0">
	        <tr class="gray">
	          <td width="100%" align="right"><%=pageLink%></td>
	        </tr>
	      </table>
		<br style="font-size:10pt">
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
	
	<br style="font-size:20pt">
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
		System.out.println("!!! ERROR ESERV_OpenJob_List.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
	     System.out.println("-->jsp clean up.");
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (stmt != null) stmt.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>