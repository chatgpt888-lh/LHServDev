<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="serv.common.Constants"%>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%
String userId = user.getUserID();String user_group = doString.checkString(user.getUserGroup());String team_restrict = "";if (!user_group.equals("A")) {	team_restrict = " AND a.i_team = '"+user_group+"' ";}
   doString str = new doString();


   //----============ Declare Variables for input data ===========----//
   String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase();
   if  (selProj.length()==0) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       session.setAttribute("sess_sel_proj",selProj);
   }

   String docNo = doString.checkString(request.getParameter("i_docno"),"").toUpperCase();
	String itmType = doString.checkString(request.getParameter("itmType"));
	String itmType_restrict = "";
	if (!itmType.equals("")) {
		itmType_restrict = " AND b.i_itmtype = '"+itmType+"'";
	}
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
        

        //---====================== Generate Serrch Condition ===========================---//
        if (selProj.trim().length()>=6 && !selProj.equalsIgnoreCase("ALL")) {
		   condition = " AND a.i_company = '"+(selProj.substring(0,2))+"' AND a.i_project = '"+(selProj.substring(3,6))+"' ";
        }
		if (selProj.trim().length()<=0) {
		   String projList = common.getProjectListByUserId(userId);
		   if (projList.length()>0) {
			   //================== modified to used index field =====================//
				if (projList.trim().length()>0) {
					String projCondition = "";
					StringTokenizer plist = new StringTokenizer(projList,",");
					while (plist.hasMoreTokens()) {
						String proj = str.replace(plist.nextToken(),"'","").trim();
						if (proj.length()>=6) {
							String icom = proj.substring(0,2);
							String iproj = proj.substring(3,6);
							if (projCondition.trim().length()>0) projCondition += " or ";
							projCondition += " (a.i_company = '"+icom+"' and a.i_project = '"+iproj+"') ";
						}
					} // end while

					if (projCondition.trim().length()>0) {
						condition = " AND ("+projCondition+") ";
					}
				}
				//===============================================================//
		   } else {

			sql.delete(0,sql.length());
			sql.append(" select count(*) from lan:serv_pstaff  where user_id='").append(userId).append("' and proj_id='ALL' ");
			int checkAllPermission = 0;
			rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
			    checkAllPermission = rs.getInt(1);
			}
			rs.close();
			if (checkAllPermission<=0) { 
			   //----- used for user that no project in hand , set for data not load ----//
			   condition += " AND a.i_docno = 'NOPROEJCT' ";
		       } else {
			  selProj = "ALL";
		       }

		   }
		}     
        if (docNo.trim().length()>0) {
           condition += " AND a.i_docno = '"+docNo+"' ";
        }
 	   //---=========================================================================----//   

        
    
        //----====================== Get DOCHD Max Row ==============================-----//
        int maxRow = 0;
        sql.delete(0,sql.length());
        sql.append("SELECT COUNT(*) FROM lan:serv_infdochd a ,lan:serv_infdocdt b")
			.append(" WHERE b.i_docno = a.i_docno "+itmType_restrict+" AND a.f_status = 'OPN' AND a.i_doc_type = 'J' ")			.append(team_restrict)
              .append(" AND b.f_itmstatus = '300' ").append(condition)
              .append(" GROUP BY a.i_docno, b.i_vendor");
        rs = stmt.executeQuery(sql.toString());
        while (rs.next()) {        
           maxRow++;
        }
        rs.close();
		rs=null;
	   //---=========================================================================----//     	             
       
        
	   //-----============== Generate Display Customize and Page Link ==================-----//
	   String displayType = doString.checkString(request.getParameter("display_type"),"");    
	   int displayLine = Integer.parseInt(doString.checkString(request.getParameter("display_line"),"0"));
	   int nowPage = Integer.parseInt(doString.checkString(request.getParameter("now_page"),"1"));
	   if (displayType.equalsIgnoreCase("A")) {
	      displayLine = maxRow;
	      nowPage = 1;
	   }
	   if (displayLine<Constants.SERV_COMPLETETASK_LINE) displayLine = Constants.SERV_COMPLETETASK_LINE;      
	   
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

<HTML>
<HEAD>
<TITLE>Complete Task List</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">
<!--

  function searchDocHD() {
     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFCompTask_List.jsp";
     document.forms[0].submit();  
  }

  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFCompTask_List.jsp";
     document.forms[0].submit();
  }
  
  
  function completeTask() {
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_INFCompTaskServlet";
     document.forms[0].submit();
  }  
  

/*
  function  checkAll(obj,mainCheck,subCheck) {
     var main = document.forms[0].elements[mainCheck];
     var sub = document.forms[0].elements[subCheck];
     
     if (obj!=null && main!=null && sub!=null) {
     
         if (obj.name==mainCheck) {
		    if (sub.length!=null) {
				for (var i=0;i<sub.length;i++) {
					  sub[i].checked = obj.checked;
				}
			} else {
			   sub.checked = obj.checked;
			}
         } else {
		    if (sub.length!=null) {
			    var flag = true;
				for (var i=0;i<sub.length;i++) {
					  flag = sub[i].checked;
					  if (!flag) break;
				}
				main.checked = flag;
			} else {
			   main.checked = obj.checked;
			} // end if check sub
         } // end if check mainCheck

     } // end if check null
          
  }    
*/
  
//-->
</script>


<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">

<input type="hidden" name="now_page" value="<%=nowPage%>">

<input type="hidden" name="itmType" value="<%=itmType%>">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            Complete Task List : Wait</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดการสั่งซ่อม</td>
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
    <%=common.genProjectListboxByUserId(userId,"sel_project",selProj," class='box' style='width:250px' onchange='resetSearch();' ",true)%>
    </td>
    <td height="22" class="item ; dotline01" width="14%">เลขที่ใบสั่งซ่อม
      :</td>
    <td height="22" width="32%" class="dotline01">
	<input type="text" name="i_docno" class="box" style="width:100px" value="<%=docNo%>">&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="#" onclick="searchDocHD()"><img border="0" src="images/i_search.gif" align="absmiddle" width="20" height="20"></a>
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
                <td class="item_tab2" width="160">รายการซ่อม</td>
                <td class="item_tab3"></td>
                <td>&nbsp;<input type="radio" value="L" checked name="display_type" <%=(displayType.equalsIgnoreCase("L") ? "checked" : "")%>>แสดงจำนวนรายการต่อหน้า&nbsp;
                  <input type="text" name="display_line" class="boxC" style="width:50px" value="<%=displayLine%>">&nbsp;
                  รายการ&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" value="A" name="display_type" <%=(displayType.equalsIgnoreCase("A") ? "checked" : "")%>>
                  แสดงรายการทั้งหมด&nbsp;&nbsp;&nbsp;&nbsp;
                  <a href="#" onclick="changePage(1);"><img border="0" src="images/bu_R.gif" align="absmiddle" style="cursor:hand" width="16" height="16"></a>
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


        <%
        
		     //----================== Select Data from SERV_DOCHD ================----//   
		        int line = 0;
		        sql.delete(0,sql.length());  
		        sql.append("SELECT DISTINCT b.i_vendor, a.i_docno")
					.append(" FROM lan:serv_infdochd a ,lan:serv_infdocdt b")
					.append(" WHERE b.i_docno = a.i_docno "+itmType_restrict+" AND a.f_status = 'OPN' AND a.i_doc_type='J' ")					.append(team_restrict)
		              .append(" AND b.f_itmstatus = '300' ").append(condition)
		              .append(" ORDER BY b.i_vendor,a.i_docno");
				String oldVendor = "";
				String oldiDocNo = "";		                  
		        rs = stmt.executeQuery(sql.toString());
		        for (int i=0;i<maxRow;i++) { 
                      if (rs.next()) {
                         if (i>=startRow && i<endRow) {
                            String iDocNo = doString.checkString(rs.getString("i_docno")); 
                            String iVendor = doString.checkString(rs.getString("i_vendor")); 
                    			if (line>0) {
  							    %>      					        
									<table border="0" width="100%" cellspacing="0" cellpadding="0">
									  <tr>
									    <td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
									    <td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
									    <td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
									  </tr>
									</table>
								 <%
								 }
								 
								 
                            
                            //---=========== Get Item in this i_docno , i_vendor ===========---//
                            sql.delete(0,sql.length());
                            sql.append("SELECT a.d_appoint, c.bus_name, d.n_itmjob, b.i_itmjob, e.d_approve")
                                  .append(" FROM lan:serv_infdochd a ,lan:serv_infdocdt b")
                                  .append(" LEFT JOIN lan:stpvendr c ON c.vend_code = b.i_vendor")
                                  .append(" LEFT JOIN lan:serv_infboq d ON d.i_itmjob = b.i_itmjob")
                                  .append(" LEFT JOIN lan:serv_infflow e ON e.i_docno = b.i_docno AND e.i_vendor = b.i_vendor AND e.f_itmstatus = '200'")
                                  .append(" WHERE b.i_docno = a.i_docno "+itmType_restrict+" AND a.f_status = 'OPN'")
                                  .append(" AND a.i_doc_type = 'J' AND b.f_itmstatus = '300'")
                                  .append(" AND a.i_docno='").append(iDocNo).append("'")
                                  .append(" AND b.i_vendor='").append(iVendor).append("'");
                            int itmLine = 0;      
                            rs1 = stmt1.executeQuery(sql.toString());
                            while (rs1.next()) {
                                 itmLine++;
                                 String vendorName = doString.checkString(doString.DisplayThai(rs1.getString("bus_name")),""); 
	                             String iItmJob = doString.checkString(rs1.getString("i_itmjob"),""); 
	                             String nItmJob = doString.checkString(doString.DisplayThai(rs1.getString("n_itmjob")),""); 
	                            String dAppoint = "-";   
								Timestamp tmp = rs1.getTimestamp("d_appoint");
								if (tmp!=null) {
	                               Calendar dApp = Calendar.getInstance();                         
								   dApp.setTime(tmp);     
								   dAppoint = common.getDateFromCalendar(dApp);
								}	                     


	                            String dApprove = "-";   
								tmp = rs1.getTimestamp("d_approve");
								if (tmp!=null) {
	                               Calendar dApp = Calendar.getInstance();                         
								   dApp.setTime(tmp);     
								   dApprove = common.getDateFromCalendar(dApp);
								}	                                        
                                                                  
                                 
	                            //----============== Print Header Table ==================----//
									 if (itmLine==1) {
									 %>	
										<table border="0" width="100%" cellspacing="0" cellpadding="0">
										  <tr>
										    <td width="100%" class="frmL">
										    
										      <table border="0" width="100%" cellspacing="0" cellpadding="0">
										        <tr>
										          <td width="2%" class="col_name" height="25">&nbsp;</td>
										          <td width="52%" class="col_name">ผู้รับเหมาซ่อม</td>
										          <td width="7%" class="col_name">&nbsp;</td>
										          <td width="7%" class="col_name">&nbsp;</td>
										          <td width="10%" class="col_name">วันที่นัดซ่อม</td>
										          <td width="13%" class="col_name">เลขที่ใบสั่งซ่อม</td>
										          <td width="9%" class="col_name">วันที่ START</td>
										        </tr>
										        <tr>
										          <td width="2%" class="dotline01" align="center" height="25"><input type="checkbox" name="i_vendor" value="<%=iDocNo+":"+iVendor%>" ></td>
										          <td width="52%" class="dotline01" height="25"><%=vendorName%></td>
										          <td width="7%" class="dotline01" align="center" height="25">&nbsp;</td>
										          <td width="7%" class="dotline01" align="center" height="25">&nbsp;</td>
										          <td width="10%" class="dotline01" align="center" height="25"><%=dAppoint%></td>
										          <td width="13%" class="dotline01" align="center" height="25"><%=iDocNo%></td>
										          <td width="9%" class="dotline" align="center" height="25"><%=dApprove%></td>
										        </tr>
										        <tr>
										          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
										          <td width="98%" class="dotline ; item" colspan="6" height="25"><img border="0" src="images/i_arrow2.gif" align="absmiddle" width="11" height="11">&nbsp;
										            ชื่อรายการซ่อม</td>
										        </tr>							        
								        <%                                
								    } // end if check first line 


									//---============== Print Item List ================----//
					                %>
							        <tr>
							          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
							          <td width="98%" class="dotline" colspan="6" style="padding-left:20px" height="25"><%=(itmLine)+". "+nItmJob%></td>
							        </tr>				                
					                <%
					                
                             } // end while item	
							 rs1.close();
                             
                             //-----============== Print Footer ================----//
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
								
								<br style="font-size:10pt">
							<%
					        
 					         line++;                         
                         } // end if check row
                         
                         if (i>endRow) break;                         
                      } //end if check rs
                } // end for
                
			
			
			//-----================ If No Data , Print Blank Table =================----//
			if (line<1) {
				 %>	
					<table border="0" width="100%" cellspacing="0" cellpadding="0">
					  <tr>
					    <td width="100%" class="frmL">
					    
					      <table border="0" width="100%" cellspacing="0" cellpadding="0">
					        <tr>
					          <td width="2%" class="col_name" height="25">&nbsp;</td>
					          <td width="52%" class="col_name">ผู้รับเหมาซ่อม</td>
					          <td width="7%" class="col_name">&nbsp;</td>
					          <td width="7%" class="col_name">&nbsp;</td>
					          <td width="10%" class="col_name">วันที่นัดซ่อม</td>
					          <td width="13%" class="col_name">เลขที่ใบสั่งซ่อม</td>
					          <td width="9%" class="col_name">วันที่ START</td>
					        </tr>
					        <tr>
					          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
					          <td width="98%" class="dotline" colspan="6" style="padding-left:20px" height="25">&nbsp;</td>
					        </tr>
					        <tr>
					          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
					          <td width="98%" class="dotline" colspan="6" style="padding-left:20px" height="25">&nbsp;</td>
					        </tr>
					        <tr>
					          <td width="2%" align="center" class="solidline01" height="25">&nbsp;</td>
					          <td width="98%" class="dotline" colspan="6" style="padding-left:20px" height="25">&nbsp;</td>
					        </tr>
					        <tr>
					          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
					          <td width="98%" class="dotline" colspan="6" style="padding-left:20px" height="25">&nbsp;</td>
					        </tr>
					        <tr>
					          <td width="2%" align="center" class="dotline01" height="25">&nbsp;</td>
					          <td width="98%" class="dotline" colspan="6" style="padding-left:20px" height="25">&nbsp;</td>
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

			  <%
			} // end if check no data


        %>                  

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

            <a href="#" onclick="completeTask();"><img border="0" src="images/act_complete.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>

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
		System.out.println("ERROR SERV_INFCompTask_List.jsp : " + e.getMessage());
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