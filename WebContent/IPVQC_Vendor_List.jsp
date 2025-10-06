<%@page language="java" contentType="text/html; charset=TIS-620"
	pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="java.util.Date" %>
<%@page import="java.text.*" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="serv.common.*" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%-- 
/**********************************************/
 * create by : pradoem wonkraso
 * date time: 2018.02.06
 * Last modify :
 * version :1.0
 * project Name : IPVQC
 * description : IPVQC List
***************************************************/
--%>
<%!
private List ListAllVendor(Connection conn,String txtNameVendor) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial paramter		
        	//System.out.println("##ListAllVendor ->Starting.");   
        	List  resultList = new ArrayList();
        	HashMap hashMap = null;   
			/******************************************************/	
			sql.delete(0,sql.length());
			sql.append(" select I_COMPANY,I_PROJECT,I_VENDOR,N_VENDOR,C_DESC,STATUS from lan:IPV_QCVENDOR ")
			   .append(" WHERE STATUS = 'A' ")
			   .append(" and I_COMPANY = 'LH' and I_PROJECT = '099' ");
				if(txtNameVendor.length()>0){
				  sql.append(" and  n_vendor like '%"+txtNameVendor+"%'  ");
				}
			sql.append(" Order by N_VENDOR ");
			
			pstmt = conn.prepareStatement(sql.toString());
			rs = pstmt.executeQuery();	
			while(rs.next()){	

				hashMap = new HashMap();
	    		hashMap.put("xCOM_ID", doString.checkString(rs.getString("I_COMPANY"),""));//0
	    		hashMap.put("xPROJECT_ID", doString.checkString(rs.getString("I_PROJECT"),""));//1
	    		hashMap.put("xI_VENDOR", doString.checkString(rs.getString("I_VENDOR"),""));//1
	    		hashMap.put("xN_VENDOR", doString.checkString(rs.getString("N_VENDOR"),""));//1
	    		hashMap.put("xC_DESC", doString.checkString(rs.getString("C_DESC"),""));//1
	    		hashMap.put("xSTATUS", doString.checkString(rs.getString("STATUS"),""));//1

				resultList.add(hashMap);
			}
			rs.close();				
			//********************************************************/
		  	//System.out.println("##ListAllVendor ->end.");				  	 
		  	return resultList;			  	 
		}catch(Exception e){
			System.out.println("!!! ListAllVendor , "+e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
			return null;
		}
		finally{			
			//clean up.
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
			}catch(Exception e){}
		}
	}

 %>

<%
//*****************************************
//*****************************************
	String nVendor	 = request.getParameter("txtVendor")==null?"": request.getParameter("txtVendor").toString();//LH:075
	Connection conn = null;
	try {

        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
        //----=======================================----//	
	    List resultList =  ListAllVendor(conn,nVendor);
 %>
<HTML>
<HEAD>
<TITLE>ข้อมูลพื้นฐาน QC - รายการบริษัทตรวจรับบ้าน</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<style type="text/css">
 .box2 {  font-family: Tohama,Arial,sans-serif; font-size:10.1pt; font-weight:normal;
		padding-top: 1px; padding-right: 1px; padding-bottom: 1px; padding-left: 1px; 
	 	color:#165396; background-color: white; border: 1px #BEDCFF solid ; 
}
td.dotlineWhite{
	 color: rgb(255,255,255) ;	
	 border-bottom:1px dotted rgb(220,220,220)	;
	 border-right:1px solid rgb(135,185,247) ; 
	 padding:3px ; mso-number-format:"\@";  }
</style>
<script language="javascript" src="script_fx.js"></script>
<script type="text/javascript" src="eserv_paging.js"></script>
<script>
function initForm(){
      var e = document.getElementById('page');
      //e.style.display == 'block'
      e.style.visibility = 'hidden';
 }
function doSearch(){
    document.forms[0].action="<%=request.getContextPath()%>/IPVQC_Vendor_List.jsp";
    document.forms[0].submit();
}
function doAdd(){
	document.forms[0].action="<%=request.getContextPath()%>/IPVQC_Vendor_Form.jsp";
	document.forms[0].submit();
}

function doFormLoadEdit(vendorId){
	document.forms[0].vendorId.value = vendorId;
    document.forms[0].action="<%=request.getContextPath()%>/IPVQC_VendorServlet?cmd=edit";
    document.forms[0].submit();
}

function doDelete(vendorId) {
      document.forms[0].vendorId.value = vendorId;
	 if(confirm("คุณต้องการลบข้อมูลบริษรับตรวจบ้าน รหัส: '"+vendorId+"' ใช่หรือไม่?")==true){
		 //validate from client side
		 document.forms[0].action="<%=request.getContextPath()%>/IPVQC_VendorServlet?cmd=delete";
		 document.forms[0].submit();
	}
}

</script>
<style type="text/css">    
            .pg-normal {
                font-size:14px;
                color: #20a6f4;
                font-weight: normal;
                text-decoration: none;    
                cursor: pointer;    
            }
            .pg-selected {
               font-size:1.875em;
                color: #fe8002;
                font-weight: bold;        
                text-decoration: underline;
                cursor: pointer;
            }
            
 </style>
 <style type="text/css">
	A:link {text-decoration: none}
	A:visited {text-decoration: none}
	A:active {text-decoration: none}
	A:hover {text-decoration: underline; color: red;}
</style>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onload="initForm()">
<form action="" name="frm" method="POST">
<input type="hidden" name="vendorId" value="">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">
          &nbsp;ข้อมูลพื้นฐาน QC- รายการบริษัทตรวจรับบ้าน</td>
        </tr>
      </table>
<br style="font-size:10pt">              
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">Form Search </td>
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
    <td class="item ; dotline01" height="22" width="12%">ชื่อบริษัทตรวจรับบ้าน :</td>
    <td height="22" width="88%" class="dotline01">
		<input type="text" name="txtVendor" size="50"  value="<%=doString.DisplayThai(nVendor)%>" >	
   				&nbsp;&nbsp;<a href="javascript:doSearch();"><img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22"></a>
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

<br style="font-size:5pt">
<p align="left">
<a href="javascript:doAdd();"><img border="0" src="images/act_add.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
  </p>       	
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
      <table id="results" border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td class="col_name" width="5%">NO.</td>
          <td class="col_name" width="10%">รหัสบริษัทตรวจรับบ้าน</td>
          <td class="col_name" width="20%">ชื่อบริษัทตรวจรับบ้าน</td>
          <td class="col_name" width="15%">Delete</td>
        </tr>
 <%
        int counter = 0;
 		if(resultList!=null && resultList.size()>0){
			 HashMap hashMap = null;
 			 String tagColor = "";
			 for (Iterator iter =resultList.iterator(); iter.hasNext(); ) {
			    counter++;		
				hashMap = (HashMap)iter.next(); 	
				tagColor="#ffffff";
				if((counter%2)==0){
					tagColor="#f0f0f0";
				}	 
 %>
	       <tr bgcolor="<%=tagColor %>">
	        <td align="center" class="dotline" ><%=counter%></td>
	        <td  align="center" class="dotline ; item">&nbsp;<a href="javascript:doFormLoadEdit('<%=hashMap.get("xI_VENDOR").toString()%>');"><%=hashMap.get("xI_VENDOR").toString() %></td>
	        <td class="dotline" align="left" >&nbsp;<%=doString.DisplayThai(hashMap.get("xN_VENDOR").toString())%></td>
			<td  class="dotline" align="center"><a href="javascript:doDelete('<%=hashMap.get("xI_VENDOR").toString()%>');"><img src="images/bu_del.gif" width="30" height="12" border="0"                                  
	    			    onmouseout=nereidFade(this,70,50,5)    
	                  	onmouseover=nereidFade(this,100,50,5)     
	                  	style="FILTER: alpha(opacity=70)" width="70" height="27" alt="Delete"></a></td>
	       </tr>  
 			<%
 			}
 	}else{
  %>       
        <tr>
		   <td  class="dotline" colspan="4" class="side01" >&nbsp;</td>
        </tr>
       <tr>
		   <td  class="dotline" colspan="4" align="center" class="side01" >&nbsp;ไม่มีข้อมูล</td>
        </tr>
        <tr>
		   <td  class="dotline" colspan="4" class="side01" >&nbsp;</td>
        </tr>
        <%}
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
<% if(counter>0){ %>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr  valign="MIDDLE">
    <td align="right" nowrap="nowrap" width="50%">
    <div id="pageNavPosition"></div>
    </td>
   <td valign="middle" align="left" nowrap="nowrap" width="50%" class="pg-normal" >
   &nbsp;&nbsp;<A href="#" onclick="toggle_visibility('page');">|ALL|</A>&nbsp;&nbsp;<div id="page"></div>
    </td>
  </tr>
</table>
<%} %>
<br style="font-size:10pt">
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">
            <%-- <a href="javascript:doDelete();"><img border="0" src="images/act_delete.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>
            --%>
           </td>      	
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

</form>
<script type="text/javascript">	
    function toggle_visibility(id) {
      var intX = 0;
      var e = document.getElementById(id);
      if(e.style.visibility == 'hidden'){
         e.style.visibility = 'visible';
         intX = 1;
      }else{
         e.style.visibility = 'hidden';
      }      
      if(intX==1){
         allList();
      }else{
        pageList();
      }
    }

 	function allList(){
 		 totalRec  = "<%=counter%>";
 		  var pager = new Pager('results', totalRec); 
	      pager.init(); 
	      pager.showPageNav('pager', 'pageNavPosition'); 
	      pager.showPage(1);
    }
    
    function pageList(){
 		  var pager = new Pager('results', 25); 
	      pager.init(); 
	      pager.showPageNav('pager', 'pageNavPosition'); 
	      pager.showPage(1);
    }
</script>
 <script type="text/javascript"><!--
        var pager = new Pager('results', 25); 
        pager.init(); 
        pager.showPageNav('pager', 'pageNavPosition'); 
        pager.showPage(1);
    //--></script>
</BODY>
</HTML>

<%
	} catch (Exception e) {
		System.out.println("ERROR IPVQC_Vendor_List.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>
