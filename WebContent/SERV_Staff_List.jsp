<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>

<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%!
/**
 * Modify by : pradoem@lh.co.th 
 * date : 2021.06.23
 * version 1.1
 * desc:  
 */ 
 	public String genProjectListboxByUserId(Connection conn,String userId,String name,String value,String params,boolean getAllProj) {
		 StringBuffer html = new StringBuffer();
		 StringBuffer sql = new StringBuffer();
		Statement stmt = null;
		 ResultSet rs = null;
		 boolean allProject = false;
		 SERV_CommonData common = new SERV_CommonData(conn);

		 try {
			stmt = conn.createStatement();

			//---============= Check user is vendor or employee ===============----//
			String userWho = "";
			String iPerson = "";	
			
			sql.delete(0,sql.length());
			//remark by pradoem 2012.04.24: sql.append(" select * from lan:useracl where user_id='").append(userId).append("' and user_acl='S' ");
			sql.append(" select user_id,user_acl,user_who,i_person from lan:useracl where user_id='").append(userId).append("' and user_acl='S' ");
			rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
				userWho = doString.checkString(rs.getString("user_who"),""); 
				iPerson = doString.checkString(rs.getString("i_person"),""); 		
			}
			rs.close();			
		 	
			///----=============== Generate Query for Vendor and Employee ==================---//
			if (userWho.equalsIgnoreCase(Constants.PERMISSION_VENDOR)) {
				sql.delete(0,sql.length());
				sql.append(" select (a.i_company) as com_id, (a.i_project) as proj_id, b.n_project from lan:serv_venprj a ")
					  .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
					  .append(" where a.i_vendor='").append(iPerson).append("' ")
					  .append(" and a.i_type='01' order by a.i_company, a.i_project ");
			} else {
				 sql.delete(0,sql.length());
				 sql.append(" select a.com_id, a.proj_id, b.n_project  from lan:serv_pstaff a ")
					   .append(" left join lan:acxprojt b on b.i_company=a.com_id  and  b.i_project=a.proj_id ")
					   .append(" where a.user_id = '").append(userId).append("' ")
					   .append(" order by a.com_id,a.proj_id ");
			}
			 rs = stmt.executeQuery(sql.toString());
		     
			 //-------============== Generate List box ===================------//
			 html.append("<select name='").append(name).append("' ").append(params).append(" >");
			 html.append("<option value=''>"+Constants.LISTBOX_SELECT_LABEL+"</option>");
			 
			 String selected = "";
			 //System.out.println(" value :"+value);
			 if(value.equals("ALL")){
			    selected = " selected";
			 }
			//System.out.println(" selected :"+selected);
			
			 html.append("<option value='ALL' "+selected+">"+Constants.LISTBOX_ALLPROJECT_LABEL+"</option>");
			
			 
		    String comId = "";
			String projId = "";
			String projName = "";
			String val = "";
			
			 while (rs.next()) {
				 comId = doString.checkString(rs.getString("com_id"),"");
				 projId = doString.checkString(rs.getString("proj_id"),"");
				 projName = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
				
				 val = "";
				 val = comId+":"+projId;
				 selected = "";
				 if(value!=null && val.equals(value)) {
				   selected = " selected "; 
				 }
				 //---====== Normal Case , generate project by permission =======---//
				 html.append("<option value='").append(val).append("' ").append(selected).append(">")
					.append(comId).append("-").append(projId).append(" - ").append(projName)
					.append("</option>");				                   		        
			 } // end while		 
			 //----=====================================================----//
		           		     
			 rs.close();
			 stmt.close();

		     
			 if (allProject) {
				 //----====== AllProject is true , gen All Project Listbox ========----//
				 html.delete(0,html.length());
				 html.append(common.genAllProjectListbox(name,value,params,getAllProj));
			 }		     
		     html.append("</select>");
		     
		     //System.out.println("SQL :"+html.toString());
		 } catch (Exception e) {
			 System.out.println(" genProjectListboxByUserId Error : "+e.getMessage());
		 } finally {
			 try {
				if (rs!=null) rs.close();
				if (stmt!=null) stmt.close();
			 } catch (Exception ex) {}
		 }
	     
		 return html.toString();
	}
 
    
 // วันที่จ่าย 
 public boolean IsDatePayment(Connection conn){
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        
        String dPayment = "";
        boolean isRecord = false;
        try {

            stmt = conn.createStatement();
  			sql.delete(0, sql.length());
			sql.append(" select d_payment from lan:serv_payschd where today<=d_contructor order by d_payment  ");
				//System.out.println("SQL  :"+sql.toString());
				rs = stmt.executeQuery(sql.toString());    				   
			    if(rs.next()){
			       dPayment  = doString.checkString(rs.getString("d_payment"),""); 
			    } 		
			    if(!"".equals(dPayment)){
			      isRecord = true;
			    }			  
                rs.close();
                stmt.close();
                return isRecord;
        }catch(Exception e) {
            System.out.println(" IsDatePayment Error : " + e.getMessage());
            return false;
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
    }    
    
 %>


<%


   	/*System.out.println("*******************************************");
	String ParameterNames = "";
	for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
		ParameterNames = (String)e.nextElement();
		System.out.println(ParameterNames + " = "+request.getParameter(ParameterNames));
	}
	System.out.println("*******************************************");
  	*/
 
   doString str = new doString();
   String userWho = user.getUserWho();
   
    //----============ Declare Variables for input data ===========----//
    String dPayment = doString.checkString(request.getParameter("d_payment"),"");
    String dPay = "";

    if (dPayment.length()==0) {
       //---========== If no data from parameter , get from session instead =============----//
       dPayment = doString.checkString((String) session.getAttribute("sess_dPayment"),"");
       dPay = doString.checkString((String) session.getAttribute("sess_dPay"),"");
    } else {
       //---========== If receive from parameter , set to session ============----//
       session.setAttribute("sess_dPayment",dPayment);
    }
    if (dPay.length()==0 && dPayment.length()==10) {
       //---========== First Time to use , convert format ================----//
       int year = Integer.parseInt(dPayment.substring(6,10));
       if (year>2400) year -= 543;
       dPay = year+"-"+dPayment.substring(3,5)+"-"+dPayment.substring(0,2);
       session.setAttribute("sess_dPay",dPay);
    }


    //---========== If this user is service staff or more permission , use this link , else use display link =============----//
    String jspLink = "";
    if (SERV_CommonData.checkPermissionOnPage(Constants.PERMISSION_STAFF,user.getUserWho())) {
        jspLink = "SERV_Staff_Conf.jsp";
    } else {
        jspLink = "SERV_Staff_Conf_Disp.jsp";
    }


   String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase();
   /*if  (selProj.length()==0) {
       selProj = doString.checkString((String) session.getAttribute("sess_sel_proj"),"");
   } else {
       session.setAttribute("sess_sel_proj",selProj);
   }*/

    String docNo = doString.checkString(request.getParameter("i_docno"),"").toUpperCase();
    String houseId = doString.checkString(request.getParameter("i_house"),"").toUpperCase();
    String lock = doString.checkString(request.getParameter("i_lock"),"").toUpperCase();
    String condition = "";
    double totalSumWage = 0.00;
    double totalSumGoods = 0.00;
    double grandTotal = 0.00;
    double sumCalMarkup = 0.00;

	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	SERV_CommonData common = null;
    DecimalFormat format = new DecimalFormat("#,##0.00");

	try {

        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
	    conn.setAutoCommit(true);
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);

		stmt = conn.createStatement();
		stmt1 = conn.createStatement();
		common = new SERV_CommonData(conn);
        //----=======================================----//


        //---====================== Generate Serrch Condition ===========================---//
        if (selProj.trim().length()>=6 && !selProj.equalsIgnoreCase("ALL")) {
           //condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
		   condition = " and a.i_company='"+(selProj.substring(0,2))+"' and a.i_project='"+(selProj.substring(3,6))+"' ";
        }
		if (selProj.equalsIgnoreCase("ALL")) {
		   String projList = common.getProjectListByUserId(user.getUserID());
		   if (projList.length()>0) {
		       //condition += " and substr(a.i_docno,1,6) in ("+projList+") ";

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
			sql.append(" select count(*) from lan:serv_pstaff  where user_id='").append(user.getUserID()).append("' and proj_id='ALL' ");
			int checkAllPermission = 0;

			rs = stmt.executeQuery(sql.toString());
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
		//System.out.println("Case : xxxxx "+condition);
		
		if(userWho.equals("A") && selProj.equals("ALL")){
			 //--userWho = A and case ALL project
			 condition = "";
			 //System.out.println("Case : 11111111 ");
		}else if(userWho.equals("S") && selProj.equals("ALL")){
				//--userWho = S and case ALL by User
				String preComId = "  and a.i_company in ( "; //'LH')
				String preProj = " and a.i_project in( ";
				//--------------------

     			sql.delete(0,sql.length());
				sql.append(" select  com_id from lan:serv_pstaff  where user_id='").append(user.getUserID()).append("' and proj_id <> 'ALL' ")
					.append(" group by com_id");				
     			rs = stmt.executeQuery(sql.toString());
				while(rs.next()) {
				   preComId +=  "'"+doString.checkString(rs.getString("com_id"),"")+"',";
				}
				preComId = preComId.substring(0,preComId.length()-1)+" )";
				
				//--------------------
				sql.delete(0,sql.length());
				sql.append(" select  com_id,proj_id from lan:serv_pstaff  where user_id='").append(user.getUserID()).append("' and proj_id <> 'ALL' ")
					.append(" order by com_id,proj_id ");				
				rs = stmt.executeQuery(sql.toString());
				while(rs.next()) {
					 //comId = doString.checkString(rs.getString("com_id"),"");
					 preProj += " '"+doString.checkString(rs.getString("proj_id"),"")+"',";
				}
				preProj = preProj.substring(0,preProj.length()-1)+" )";
    			
    			condition = preComId+preProj;
    			//System.out.println("Case : 22222222222 :"+condition);
		}else  if (selProj.trim().length()>=6 && !selProj.equalsIgnoreCase("ALL")) {
		   //case select project
		    condition = " and a.i_company='"+(selProj.substring(0,2))+"' and a.i_project='"+(selProj.substring(3,6))+"' ";	
		    // System.out.println("Case : 333333333333 ");   
		}
				    
        if (docNo.trim().length()>0) {
           condition += " and a.i_docno='"+docNo+"' ";
        }
		
       //System.out.println("Case : 1111111 "+condition);   
		//modify by pradoem 2021.05.19
		if (houseId.trim().length()>0 ) {
			//String tempLockId = "";
		    if (selProj.trim().length()>=6 && !selProj.equalsIgnoreCase("ALL")) {
				 sql.delete(0,sql.length());
		         sql.append(" Select a.i_lor,a.i_model,a.i_house,a.i_lock,b.i_exp_intent1,b.i_cus_intent1,b.d_close_law  ")
		             .append(" From lan:acxlckmd a  ")
		             .append(" left join lan:acscontr b   ")
		             .append(" on b.i_company=a.i_company   ")
		             .append(" and b.i_project=a.i_project ")
		             .append(" and b.i_lor=a.i_lor  ")
		             .append(" Where a.i_company = '"+selProj.substring(0,2)+"'  and a.i_project = '"+selProj.substring(3,6)+"'   and a.i_house='"+houseId.trim()+"' ");
		             
		        	//System.out.println("SQL xxx : "+sql.toString());      
		        	rs = stmt.executeQuery(sql.toString());		
		        	rs = stmt.executeQuery(sql.toString());
			        if(rs.next()) {
						//tempLockId = 
						lock = doString.checkString(rs.getString("i_lock"),"");
			        }      
		    }
		}
		
        if (docNo.trim().length()>0) {
           condition += " and a.i_docno='"+docNo+"' ";
        }
        /*if (houseId.trim().length()>0) {
           condition += " and b.i_house='"+houseId+"' ";
        }*/
        if (lock.trim().length()>0) {
           condition += " and a.i_lock='"+lock+"' ";
        }
        if (user.getUserWho().equalsIgnoreCase(Constants.PERMISSION_VENDOR)) {
           condition += " and b.i_vendor='"+user.getEmpId()+"' ";
        }
        condition += " and b.d_payment='"+dPay+"' ";
 	   //---=========================================================================----//
		
		//System.out.println("2222222 condition :"+condition);

        //----====================== Get PAYMENT Max Row ==============================-----//
        int maxRow = 0;
        //Fix bug by pradoem 2021.06.23
        if(!selProj.equals("")){         
	        sql.delete(0,sql.length());
	        sql.append(" select count(*) from lan:serv_payment b,lan:serv_dochd a where ")
	              .append(" b.i_docno = a.i_docno and a.f_status='OPN' ")
	              .append(" and b.f_itmstatus='500' ").append(condition)
	              .append(" group by b.i_docno,b.i_vendor ");
	        //System.out.println("SQL xxx : "+sql.toString());      
	        rs = stmt.executeQuery(sql.toString());
	        while (rs.next()) {
	           maxRow++;
	        }
	        rs.close();
        }
	   //---=========================================================================----//


	   //-----============== Generate Display Customize and Page Link ==================-----//
	   String displayType = doString.checkString(request.getParameter("display_type"),"");
	   int displayLine = Integer.parseInt(doString.checkString(request.getParameter("display_line"),"0"));
	   int nowPage = Integer.parseInt(doString.checkString(request.getParameter("now_page"),"1"));
	   if (displayType.equalsIgnoreCase("A")) {
	      displayLine = maxRow;
	      nowPage = 1;
	   }
	   if (displayLine<Constants.SERV_STAFFLIST_LINE) displayLine = Constants.SERV_STAFFLIST_LINE;

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
<TITLE>Staff List - เจ้าหน้าที่บริการ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="javascript" src="jquery/jquery-1.11.3.min.js"></script>
<script type='text/javascript' src='jquery/loadImg.js'></script>
<script language="javascript">

  function doSubmitForm(url){
    //alert("submit");
     onPleaseWait();    
 	$('form').attr('action', url);
	$("form:first").submit();
  }

  function onPleaseWait(){
	document.all.pleasewaitScreen.style.pixelTop = (document.body.scrollTop + 120);
	$('#pleasewaitScreen').show();
	//setTimeout(function(){  $('#pleasewaitScreen').css("visibility", 'hidden'); }, 9000); //wait 7 seconds
	$('#pleasewaitScreen').css('visibility', 'visible');
 }    
</script>


<script language="javascript">
<!--

  function searchDocHD() {
     onPleaseWait();
     document.forms[0].now_page.value='1';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Staff_List.jsp";
     document.forms[0].submit();
  }

  function changePage(page) {
      onPleaseWait();
     document.forms[0].now_page.value=page;
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_Staff_List.jsp";
     document.forms[0].submit();
  }

//-->
</script>



<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">

<input type="hidden" name="now_page" value="<%=nowPage%>">
<input type="hidden" name="d_payment" value="<%=dPayment%>">

<!-- ##########################################  rgb(255,120,0)-->
<DIV ID="pleasewaitScreen" STYLE="position: absolute; z-index: 0; top: 45%; left: 42%; display: none;">
<TABLE BORDER="1" BORDERCOLOR="rgb(180,210,250)" CELLPADDING="0" CELLSPACING="0" 
HEIGHT="125px" WIDTH="265px" ID="Table1">
	<TR>
	<TD BGCOLOR="#FFFFFF" ALIGN="CENTER" VALIGN="MIDDLE" class="test">
	<font  style="font-family:Tahoma,Arial,sans-serif; color:rgb(112,112,112); font-size:2.0em;" ><b>Loading... Please wait</b></font>
	<br>
	<br>
	  <span id="img1">
	   <img src="<%=request.getContextPath()%>/images/loading2.GIF" HEIGHT="64px">
	  </span>
	</TD> 
	</TR>
</TABLE>
</DIV>
<!-- ########################################## -->

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            Staff List : เจ้าหน้าที่บริการ</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">



            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">ค้นหารายการ</td>
                <td class="item_tab3"></td>
                <td>&nbsp;วันที่จ่าย&nbsp; <%=dPayment%></td>
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
			    <%=genProjectListboxByUserId(conn,user.getUserID(),"sel_project",selProj," class='box' style='width:250px' ",true)%>      			    
			    <%//=common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:250px' ",true)%>
			    </td>
			    <td height="22" class="item ; dotline01" width="14%">เลขที่ใบแจ้งซ่อม
			      :</td>
			    <td height="22" width="32%" class="dotline01"><input type="text" name="i_docno" class="box" style="width:100px" value="<%=docNo%>"></td>
			  </tr>
			  <tr>
			    <td class="item ; dotline01" height="22" width="15%">บ้านเลขที่
			      :</td>
			    <td height="22" width="39%" class="dotline01"><input type="text" name="i_house" class="box" style="width:100px" value="<%=houseId%>"></td>
			    <td height="22" class="item ; dotline01" width="14%">แปลง :</td>
			    <td height="22" width="32%" class="dotline01"> <input type="text" name="i_lock" class="box" style="width:100px" value="<%=lock%>">&nbsp;&nbsp;&nbsp;&nbsp;
			      <a href="#" onclick="searchDocHD();"><img border="0" src="images/i_search.gif" align="absmiddle" width="20" height="20"></a> </td>
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





<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL">

      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td class="col_name" rowspan="2" width="14%">เลขที่ใบแจ้งซ่อม</td>
          <td class="col_name" rowspan="2" width="6%">แปลง</td>
          <td class="col_name" rowspan="2" width="6%">บ้านเลขที่</td>
          <td class="col_name" colspan="4">ราคาสั่งงานผู้รับเหมา</td>
          <td class="col_name" rowspan="2" width="14%">ผู้รับเหมาซ่อม</td>
          <td class="col_name" rowspan="2" width="9%">วันที่ส่งงาน</td>
          <td class="col_name" rowspan="2" width="11%">สถานะ</td>
        </tr>
        <tr>
          <td class="col_nameLow" width="9%">ค่าแรง</td>
          <td class="col_nameLow" width="8%">ค่าของ</td>
          <td class="col_nameLow" width="10%">ค่าแรง+ค่าของ</td>
          <td class="col_nameLow" width="13%">รวมค่าดำเนินการ</td>
        </tr>


        <%

		     //----================== Select Data from SERV_DOCHD ================----//
			 Hashtable tmpHeader = null;
			 Hashtable tmpCust = null;
			 Calendar cal = Calendar.getInstance();
			 Timestamp tmp = null;

			String iDocNo = "";
			String iVendor = "";
			String vendorName = "";
			String dApprove = "";

			String nCustomer = "";
			String iLock = "";
			String iCompany = "";
			String iProject = "";
			String iHouse = "";
			double markupPay = 0.0; 

			double sumWage = 0.00;
			double sumGoods = 0.00;
			double totalSum = 0.00;
			double calMarkupPay = 0.00;
			String status = "";
			int checkMax = 0;

		        int line = 0;
		        sql.delete(0,sql.length());
		        sql.append(" select first ").append(endRow).append(" distinct d.bus_name,c.d_approve,b.i_docno,b.i_vendor,b.p_add_pay ")
		              .append(" from lan:serv_payment b ")
		              .append(" left join lan:serv_flow c on c.i_docno=b.i_docno and c.i_vendor=b.i_vendor and c.f_itmstatus='400' ")
		              .append(" left join lan:stpvendr d on d.vend_code=b.i_vendor ")
		              .append(" ,lan:serv_dochd a where b.i_docno=a.i_docno and a.f_status='OPN' and b.f_itmstatus='500' ")
		              .append(condition).append(" order by b.i_docno");
				
				//System.out.println("222222 :"+sql.toString());
		        rs = stmt.executeQuery(sql.toString());
		        for (int i=0;i<maxRow;i++) {
                      if (rs.next()) {
                         if (i>=startRow && i<=endRow) {
                            //------ Data is in this page , display -----//
				            iDocNo = doString.checkString(rs.getString("i_docno"),"");
				            iVendor = doString.checkString(rs.getString("i_vendor"),"");
				            vendorName = doString.DisplayThai(doString.checkString(rs.getString("bus_name"),""));
				            dApprove = "";
							tmp = rs.getTimestamp("d_approve");
							if (tmp!=null) {
							   cal.setTime(tmp);
							   dApprove = getDateFromCalendar(cal);
							}


					         //----======================== Find DocHD Data =============================----//
							tmpHeader = common.getDocHeaderDetails(iDocNo);
					        nCustomer = doString.checkString((String) tmpHeader.get("n_customer"),"");
					        iLock = doString.checkString((String) tmpHeader.get("i_lock"),"");
					        iCompany = doString.checkString((String) tmpHeader.get("i_company"),"");
					        iProject = doString.checkString((String) tmpHeader.get("i_project"),"");


							//----======================= Get Customer Details ===========================----//
							tmpCust = common.getCustomerDetails(iCompany,iProject,iLock);
						    iHouse = doString.checkString((String) tmpCust.get("i_house"),"");


							markupPay = rs.getDouble("p_add_pay");


/*
							//---============== Select markupPay ================----//
							 double markupPay = 0.0; 
							 sql.delete(0,sql.length());
							 sql.append(" select * from lan:serv_venprj where ")
								   .append(" i_company='").append(iDocNo.length()>=6 ? iDocNo.substring(0,2) : "").append("' ")
								   .append(" and i_project='").append(iDocNo.length()>=6 ? iDocNo.substring(3,6) : "").append("' ")
								   .append(" and i_vendor='").append(iVendor).append("' ");
							 rs1 = stmt1.executeQuery(sql.toString());
							 if (rs1.next()) {
								markupPay = rs1.getDouble("p_add_pay");
							 }				        
							 rs1.close();	
*/

							//----======================= Get Payment Details ===========================----//
							sumWage = 0.00;
							sumGoods = 0.00;
							totalSum = 0.00;
							calMarkupPay = 0.00;

							//------- Find Summary ---------//
							sql.delete(0,sql.length());
							sql.append(" select sum(q_wage_unit*z_wage_price) sum_wage, ")
							      .append(" sum(q_good_unit*z_good_price) sum_goods,  ")
							      .append(" sum(z_amount_pv) sum_pv  ")
							      .append(" from lan:serv_payment where f_itmstatus='500' ")
							      .append(" and i_docno='").append(iDocNo).append("' ")
							      .append(" and i_vendor='").append(iVendor).append("' ");
							rs1 = stmt1.executeQuery(sql.toString());
							if (rs1.next()) {
							    sumWage = rs1.getDouble("sum_wage");
							    sumGoods = rs1.getDouble("sum_goods");

							    totalSum = sumWage+sumGoods;
								calMarkupPay = rs1.getDouble("sum_pv");
								/*
							    calMarkupPay = (totalSum / 100) * markupPay;
								*/

							    totalSumWage += sumWage;
							    totalSumGoods += sumGoods;
							    sumCalMarkup += (calMarkupPay-totalSum);
							}
							rs1.close();



							//------- Check status , waiting confirm or routeback ---------//
							status = "รอ Confirm";
							checkMax = 0;
							sql.delete(0,sql.length());
							sql.append(" select max(f_itmstatus)  from lan:serv_flow where ")
							      .append(" i_docno='").append(iDocNo).append("' ")
							      .append(" and i_vendor='").append(iVendor).append("' ");
							rs1 = stmt1.executeQuery(sql.toString());
							if (rs1.next()) {
							    checkMax = Integer.parseInt(doString.checkString(rs1.getString(1),"0")); 
							    if (checkMax>500) status = "รอการแก้ไข";
							}
							rs1.close();


					        %>
					        <tr>
					          <td align="center" class="dotline" width="14%"><a href="<%=jspLink%>?i_docno=<%=iDocNo%>&i_vendor=<%=iVendor%>&load=yes"><%=iDocNo%></a></td>
					          <td class="dotline" align="center" width="6%"><%=iLock%>&nbsp;</td>
					          <td class="dotline" align="center" width="6%"><%=iHouse%>&nbsp;</td>
					          <td class="dotline" align="right" width="9%"><%=format.format(sumWage)%></td>
					          <td align="right" class="dotline" width="8%"><%=format.format(sumGoods)%></td>
					          <td align="right" class="dotline" width="10%"><%=format.format(totalSum)%></td>
					          <td align="right" class="dotline" width="13%"><%=format.format(calMarkupPay)%></td>
					          <td align="center" class="dotline" width="14%"><%=vendorName%>&nbsp; (<%=markupPay%> %)</td>
					          <td align="center" class="dotline" width="9%"><%=dApprove%>&nbsp;</td>
					          <td align="center" class="dotline" width="11%"><%=status%>&nbsp;</td>
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
			          <td align="center" class="dotline" width="14%">&nbsp;</td>
			          <td class="dotline" align="center" width="6%">&nbsp;</td>
			          <td class="dotline" align="center" width="6%">&nbsp;</td>
			          <td class="dotline" align="right" width="9%">&nbsp;</td>
			          <td align="right" class="dotline" width="8%">&nbsp;</td>
			          <td align="right" class="dotline" width="10%">&nbsp;</td>
			          <td align="right" class="dotline" width="13%">&nbsp;</td>
			          <td align="center" class="dotline" width="14%">&nbsp;</td>
			          <td align="center" class="dotline" width="9%">&nbsp;</td>
			          <td align="center" class="dotline" width="11%">&nbsp;</td>
			        </tr>
	                <%
	           }
        %>


        <tr>
          <td align="center" class="dotline ; item" width="14%">&nbsp;</td>
          <td align="center" class="dotline ; item" width="6%">&nbsp;</td>
          <td align="center" class="dotline ; item" width="6%">รวม</td>
          <td align="right" class="dotline ; item" width="9%"><%=format.format(totalSumWage)%></td>
          <td align="right" class="dotline ; item" width="8%"><%=format.format(totalSumGoods)%></td>
          <td align="right" class="dotline ; item" width="10%"><%=format.format(totalSumWage+totalSumGoods)%></td>
          <td align="right" class="dotline ; item" width="13%"><%=format.format(totalSumWage+totalSumGoods+sumCalMarkup)%></td>
          <td align="center" class="dotline ; item" width="14%">&nbsp;</td>
          <td align="center" class="dotline ; item" width="9%">&nbsp;</td>
          <td align="center" class="dotline ; item" width="11%">&nbsp;</td>
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




<br style="font-size:30pt">

<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
  <tr><td width="100%" class="copyright" align="center">
  Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5
  <br>ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;
  หรือ โทร. 0-2230-8279 (คุณประพัฒน์
  ฝ่ายบริการ)&nbsp; 0-2230-8491-5 (ฝ่าย IT)
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE>

</BODY>

</HTML>

<%
	} catch (Exception e) {
		System.out.println("!!! ERROR SERV_Staff_List.jsp : " + e.getMessage());
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