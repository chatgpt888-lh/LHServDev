<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_BOQSearch.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   doString str = new doString();


   //----============ Declare Variables for search data ===========----//
   String searchType = doString.checkString(request.getParameter("search_type"),"");    
   String nItmJob = doString.checkString(request.getParameter("n_itmjob"),""); 
   String iGroup = doString.checkString(request.getParameter("i_group"),"");    
   String iType = doString.checkString(request.getParameter("i_type"),"");

   
   //-----========= Declare Variables for OpenJob Page ===========----//
   String mode = doString.checkString(request.getParameter("mode"),"add");
   String iDocNo = doString.checkString(request.getParameter("i_docno"),"");
   String selProj = doString.checkString(request.getParameter("sel_project"),"");
   String houseId = doString.checkString(request.getParameter("house_id"),"");
   String iLock = doString.checkString(request.getParameter("i_lock"),"").toUpperCase();
   String nCustomer = doString.DisplayThai(doString.checkString(request.getParameter("n_customer"),""));
   String nCustTel = doString.checkString(request.getParameter("n_cust_tel"),"");
   String dAppoint= doString.checkString(request.getParameter("d_appoint"),"");
   String dEstClose= doString.checkString(request.getParameter("d_est_close"),"");
   String fQC = doString.checkString(request.getParameter("f_qc"),"N").toUpperCase();   
//System.out.println("====selProj :"+selProj);
//System.out.println("====selProj :"+selProj.length()); String iCompany  = "";
 String iProject = "";
 
 if(selProj.length()==6){
	 iCompany = (selProj.length()<=6 ? selProj.substring(0,2) : "");
	 iProject = (selProj.length()<=6 ? selProj.substring(3,6) : "");
 }

   boolean condo = false;
   boolean site_east = false;
   boolean site_north = false; 
   
   //---================ Add , Update , Delete Item List before get to use ===============----//
   ItmJobManagement itm = new ItmJobManagement(request,response);
   itm.updateValuesFromRequest(); // update new values from request.

/*
		Vector jobList1 = itm.getJobList();
		Hashtable jobComment = itm.getCommentList();
        for (int i=0;i<jobList1.size();i++) {
                String jid =   doString.DisplayThai(doString.checkString((String) jobList1.elementAt(i),"")); 
                String comment = doString.checkString((String) jobComment.get(jid),"");                
				//String comment = "";
				comment = doString.DisplayThai(comment);

out.println(comment+" = "+ doString.DisplayThai(doString.checkString(request.getParameter(jid+"_comment"),"")+"<hr>"));
         } // end for
*/


   //----========= If Click Add to CART , Update Item ===========----//
   String addCart = doString.checkString(request.getParameter("add_cart"),"");
   if (addCart.equalsIgnoreCase("YES")) {
      String itmList[] = request.getParameterValues("i_itmjob");
      if (itmList!=null) {
         for (int i=0;i<itmList.length;i++) {
               itm.addItem(itmList[i]);
         } // end for
      }
   } // end if check click     
      
      
   //----========= If Checkout some Item , remove that item ==========-----//   
   Enumeration names = request.getParameterNames();
   String pname = "" , id="" , checked ="";
   while (names.hasMoreElements()) {
       pname = doString.checkString((String) names.nextElement(),"");
       if (pname.indexOf("check_")==0) {
          id = pname.substring(6);
          checked = doString.checkString(request.getParameter(pname),"");
          if (checked.trim().length()==0) {
              itm.removeItem(id); //--- Remove Item ----//
          }
       }
   } // end while    

   itm.updateItemSession();  //---- Update Session before user ----//
   Vector jobList = itm.getJobList();
  //---=========================================================================----//
       

   
   //-----====================== Search BOQ Data ================================------//
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	SERV_CommonData common = null;
	   
	String itmtype = null;
	String from_page = null;
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
        
       itmtype = doString.checkString(request.getParameter("itmtype"),"");
       from_page = doString.checkString(request.getParameter("from_page"),"");

        
		//----------- find condo -------------//
		sql.delete(0,sql.length());
		sql.append(" select count(*) as cnt from lan:serv_condo where ")
			  .append(" i_company='"+doString.checkString(iCompany,"")+"' ")
			  .append(" and i_project='"+doString.checkString(iProject,"")+"' ");
		servlog.startLog(sql.toString());
		rs = stmt1.executeQuery(sql.toString());
		servlog.endLog();
		if (rs.next()) {
			int count = rs.getInt("cnt");
			if (count>0) {
				condo = true;
			} else {
				condo = false;
			}
		} else {
			condo = false;
		}
		rs.close();

		int cnt_site = 0; 
		//------------- find north east project ---------------
		/*  G12 ใช้เหมือน boq กทม  2024.02.01 pradoem	
		sql.delete(0,sql.length());
		sql.append(" select count(*) as cnt from lan:serv_local where ")
			  .append(" i_company='"+doString.checkString(iCompany,"")+"' ")
			  .append(" and i_project='"+doString.checkString(iProject,"")+"' ")
			  .append(" and i_type = 'NE' ");
		servlog.startLog(sql.toString());
		rs = stmt1.executeQuery(sql.toString());
		servlog.endLog();
		if (rs.next()) {
				cnt_site = rs.getInt("cnt");
			if (cnt_site>0) {
				site_east = true;
			} else {
				site_east = false;
			}
		} else {
			site_east = false;
		}
		rs.close(); */


		int cnt_site2 = 0; 
		//------------- find north  project ---------------
		sql.delete(0,sql.length());
		sql.append(" select count(*) as cnt from lan:serv_local where ")
			  .append(" i_company='"+doString.checkString(iCompany,"")+"' ")
			  .append(" and i_project='"+doString.checkString(iProject,"")+"' ")
			  .append(" and i_type = 'LN' ");
		servlog.startLog(sql.toString());
		rs = stmt1.executeQuery(sql.toString());
		servlog.endLog();
		if (rs.next()) {
				cnt_site2 = rs.getInt("cnt");
			if (cnt_site2>0) {
				site_north = true;
			} else {
				site_north = false;
			}
		} else {
			site_north = false;
		}
		rs.close();


        //-----================ Generate Condition  ===============----//
       String condition = "";
	   if (searchType.equalsIgnoreCase("detail")) {
	      //----========= Query for search by BOQ Details ===========----//
	       condition = " where (a.i_group is not null) and (a.i_type is not null) and (a.i_seq is not null and a.i_seq<>'') ";   
	       condition += " and a.n_itmjob like '%"+nItmJob+"%' ";
	   } else {
	      //-----========== Query for search by ID ===============-----//
	       condition = " where (a.i_seq is not null and a.i_seq<>'') and a.i_group = '"+iGroup+"' ";
	       if (iType.equalsIgnoreCase("ALL")) {
	          condition += " and ((a.i_group is not null and a.i_group<>'') and (a.i_type is not null and a.i_type<>'') and (a.i_seq is not null and a.i_seq<>'')) ";
	       } else {
	          condition += " and a.i_type = '"+iType+"' ";
	       }
	   }    

	   if (condo) {
		   condition += " and upper(a.i_itmjob[5])='C' ";
	   } else if (site_east) { 
			condition += " and upper(a.i_itmjob[5])='E' ";
		} else if (site_north) { 
			condition += " and upper(a.i_itmjob[5])='N' ";			
	   } else {
		   condition += " and upper(a.i_itmjob[5])<>'C' and upper(a.i_itmjob[5])<>'E' and upper(a.i_itmjob[5])<>'N' ";
	   }

	   
	   //-----=============================== Count Row ================================-----//
	   int maxRow = 0;
       sql.delete(0,sql.length());	   
       sql.append(" select count(*) cnt from lan:serv_boq a ")
//             .append(" left join lan:serv_boq b on b.i_group=a.i_group and  (b.i_group is not null) and ((b.i_type is null) or (b.i_type='')) and ((b.i_seq is null) or (b.i_seq='')) ")
//             .append(" left join lan:serv_boq c on c.i_group=a.i_group and c.i_type=a.i_type and (c.i_group is not null) and (c.i_type is not null) and ((c.i_seq is null) or (c.i_seq='')) ")
             .append(condition);
		//	 out.println(sql.toString());
		servlog.startLog(sql.toString());
        rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
        if (rs.next()) {        
           maxRow = rs.getInt("cnt");  
        }
        rs.close();
       //----=========================================================================----//

   


   
   //-----============== Generate Display Customize and Page Link ==================-----//
   String displayType = doString.checkString(request.getParameter("display_type"),"");    
   int displayLine = Integer.parseInt(doString.checkString(request.getParameter("display_line"),"0"));
   int nowPage = Integer.parseInt(doString.checkString(request.getParameter("now_page"),"1"));
   if (displayType.equalsIgnoreCase("A")) {
      displayLine = maxRow;
      nowPage = 1;
   }
   if (displayLine<Constants.SERV_BOQSEARCH_LINE) displayLine = Constants.SERV_BOQSEARCH_LINE;      
   
   int startRow = ((nowPage-1)*displayLine);
   int endRow = startRow+displayLine;
   
   String pageLink = "";
   int tmpMax = maxRow;
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
<TITLE>BOQ Search</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">
<!--
  function searchBOQ(searchType) {
  
	 if  (searchType==0 || searchType==1) {
	     document.forms[0].search_type[searchType].checked = true;
     } else if (!document.forms[0].search_type[0].checked && !document.forms[0].search_type[1].checked) {
        alert("กรุณาระบุประเภทการค้นหาที่ด้านหน้า !");
        document.forms[0].search_type[0].focus();
        return false;
     }
     
     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_BOQSearch.jsp";
     document.forms[0].submit();  
  }
  
  function checkOut() {
     document.forms[0].add_cart.value='YES';  
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_OpenJob.jsp";
     document.forms[0].submit();
  }   
  
  function changeGroup() {
     document.forms[0].i_type.value="";
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_BOQSearch.jsp";
     document.forms[0].submit();
  }     
  
  function addToCart() {
     document.forms[0].add_cart.value='YES';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_BOQSearch.jsp";
     document.forms[0].submit();
  }     

  function changePage(page) {
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_BOQSearch.jsp";
     document.forms[0].submit();
  }   
  
  function  checkAll(obj,mainCheck,subCheck) {
     var main = document.forms[0].elements[mainCheck];
     var sub = document.forms[0].elements[subCheck];
   
     if (obj!=null && main!=null && sub!=null) {
     
         var checkObj = document.forms[0].elements["check_"+obj.value];
        
		 if (checkObj!=null && obj.checked) {
            checkObj.value = "checked";
         }  else {
            if (checkObj!=null) checkObj.value = "";
         }
		      
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
			} 
				else {
			   main.checked = obj.checked;
			} // end if check sub
         } // end if check mainCheck


     } // end if check null
  }  

//-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">

<input type="hidden" name="now_page" value="<%=nowPage%>">
<input type="hidden" name="add_cart" value="">

<input type="hidden" name="mode" value="<%=mode%>">
<input type="hidden" name="i_docno" value="<%=iDocNo%>">
<input type="hidden" name="sel_project" value="<%=selProj%>">
<input type="hidden" name="house_id" value="<%=houseId%>">
<input type="hidden" name="i_lock" value="<%=iLock%>">
<input type="hidden" name="n_customer" value="<%=nCustomer%>">
<input type="hidden" name="n_cust_tel" value="<%=nCustTel%>">
<input type="hidden" name="d_appoint" value="<%=dAppoint%>">
<input type="hidden" name="d_est_close" value="<%=dEstClose%>">
<input type="hidden" name="f_qc" value="<%=fQC%>">

<!-- Follow Back Link : itmtype i_docno i_company i_project from_page mode -->
<input type="hidden" name="itmtype" value="<%=itmtype%>" />
<input type="hidden" name="from_page" value="<%=from_page%>" />
<input type="hidden" name="i_company" value="<%=iCompany%>" />
<input type="hidden" name="i_project" value="<%=iProject%>" />

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            BOQ Search</td>
          <td width="50%" align="right">

<%
   if (condo) {
	  %>&nbsp;<%
   } else if (site_east) {
	  %>&nbsp;<%	  
	} else if (site_north) {
	   %>&nbsp;<%	  		  
   }else {
	  %>
		<span style="position: absolute; left: 72%; top: 0">
		<a href="SERV_BOQCode01.jsp">
		<img border="0" src="images/icon_appr24hrs.gif" width="185" height="75" border="0">
		</a>          
		</span> 	  
	  <%
   }
%>		  
        
          
          </td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="160">เลือกวิธีการค้นหา</td>
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
    <td height="22" width="100%" class="dotline01 ; item">
      <input type="radio" <%=(searchType.equalsIgnoreCase("detail") ? "checked" : "")%>  value="detail" name="search_type">
      <input type="text" name="n_itmjob" class="box" style="width:490px" value="<%=doString.checkString(doString.DisplayThai(nItmJob))%>">&nbsp;&nbsp; *
      ใส่รายการซ่อมที่ต้องการค้นหา&nbsp;&nbsp;&nbsp;&nbsp;
      <a href="#" onclick="searchBOQ(0);"><img border="0" src="images/i_search.gif" width="20" height="20"> </a> </td>
  </tr>
    <td height="22" width="100%" class="dotline01">
    <input type="radio" <%=(searchType.equalsIgnoreCase("list") ? "checked" : "")%> value="list" name="search_type">
     <%
          out.println(common.genBOQGroupList("i_group",iGroup," class='box' onchange='changeGroup();' "));
          out.println(common.genBOQTypeList("i_type",iGroup,iType," class='box' "));
     %>
     &nbsp;&nbsp; <a href="#" onclick="searchBOQ(1);"><img border="0" src="images/i_search.gif" width="20" height="20"> </a> </td>
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





<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL">
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="4%" class="col_name"><input type="checkbox" name="main_check" onclick="checkAll(this,'main_check','i_itmjob');"></td>
          <td width="25%" class="col_name">หมวด</td>
          <td width="25%" class="col_name">ตำแหน่ง/ที่ตั้ง</td>
          <td width="46%" class="col_name">รายการซ่อม</td>
        </tr>
        <%
		        int line = 0;		     
		        sql.delete(0,sql.length());
		        sql.append(" select first ").append(endRow).append(" a.* from lan:serv_boq a ")
		        //sql.append(" select first ").append(endRow).append(" b.n_itmjob n_group,c.n_itmjob n_type,a.* from lan:serv_boq a ")
		        //      .append(" left join lan:serv_boq b on b.i_group=a.i_group and  (b.i_group is not null) and ((b.i_type is null) or (b.i_type='')) and ((b.i_seq is null) or (b.i_seq='')) ")
		        //      .append(" left join lan:serv_boq c on c.i_group=a.i_group and c.i_type=a.i_type and (c.i_group is not null) and (c.i_type is not null) and ((c.i_seq is null) or (c.i_seq='')) ")
		              .append(condition)
					  .append(" order by a.n_itmjob ");   //  เพิ่มเติม 

					 // out.println(sql.toString());
				servlog.startLog(sql.toString());
		        rs = stmt.executeQuery(sql.toString());
				servlog.endLog();


				String nGroup = "";
				String nType = "";
				String iItm = "";
				String nItm = "";
				for (int i=0;i<maxRow;i++) { 
                      if (rs.next()) {
					        nGroup = "";
					        nType = "";
					        iItm = "";
					        nItm = "";

                         if (i>=startRow && i<=endRow) {	    
					        iItm = doString.checkString(rs.getString("i_itmjob"),"");
					        nItm = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")),"-");                         

							//----------- find n_group -------------//
							sql.delete(0,sql.length());
							sql.append(" select n_itmjob from lan:serv_boq where ")
								  .append(" (i_group is not null) and ((i_type is null) or (i_type='')) and ((i_seq is null) or (i_seq='')) ")
								  .append(" and i_group='"+doString.checkString(rs.getString("i_group"),"-")+"' ");
							servlog.startLog(sql.toString());
					        rs1 = stmt1.executeQuery(sql.toString());
							servlog.endLog();
							if (rs1.next()) {
								nGroup = doString.checkString(doString.DisplayThai(rs1.getString("n_itmjob")),"-");
							} 
							rs1.close();


							//----------- find n_type -------------//
							sql.delete(0,sql.length());
							sql.append(" select n_itmjob from lan:serv_boq where ")
								  .append(" (i_group is not null) and (i_type is not null) and ((i_seq is null) or (i_seq='')) ")
								  .append(" and i_group='"+doString.checkString(rs.getString("i_group"),"-")+"' ")
								  .append(" and i_type='"+doString.checkString(rs.getString("i_type"),"-")+"' ");
							servlog.startLog(sql.toString());
					        rs1 = stmt1.executeQuery(sql.toString());
							servlog.endLog();
							if (rs1.next()) {
								nType = doString.checkString(doString.DisplayThai(rs1.getString("n_itmjob")),"-");
							} 
							rs1.close();

                                         
	                        checked = "";
	                        if (jobList.contains(iItm)) checked = " checked ";

		                    %>
					        <tr height="25px">
					          <td width="4%" align="center" class="dotline">
					          <input type="checkbox" name="i_itmjob" <%=checked%> value="<%=iItm%>" onclick="checkAll(this,'main_check','i_itmjob');">
					          <input type="hidden" name="check_<%=iItm%>" value="<%=checked%>">
					          </td>
					          <td width="25%" class="dotline ; item"><%=nGroup%></td>
					          <td width="25%" class="dotline ; item"><%=nType%></td>
					          <td width="46%" class="dotline ; item"><%=nItm%></td>
					        </tr>                    
		                    <%
		                    
 					         line++;                         
                         } // end if check row
                         
                         if (i>endRow) break;
                      } //end if check rs
                } // end for
           
           String msg = "";
           if (line==0) msg = "<center>ไม่พบข้อมูล !!</center>";
           
           while (line<displayLine) {
               line++;               
                %>
		        <tr height="25px">
		          <td width="4%" align="center" class="dotline">&nbsp;</td>
		          <td width="25%" class="dotline ; item">&nbsp;</td>
		          <td width="25%" class="dotline ; item"><%=((line==4 && msg.length()>0) ? msg : "&nbsp;")%></td>
		          <td width="46%" class="dotline ; item">&nbsp;</td>
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
            <td width="150" class="act_tab2">

            <a href="#" onclick='addToCart();'><img border="0" src="images/act_add2cart.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp;
            <a href="#" onclick="checkOut();"><img border="0" src="images/act_checkout.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>

            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="#" onclick="checkOut();"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
		System.out.println("ERROR SERV_BOQSearch.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (rs1 != null) rs1.close();
			if (stmt != null) stmt.close();
			if (stmt1 != null) stmt1.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>