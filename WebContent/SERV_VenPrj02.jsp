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
String jName = "SERV_VenPrj02.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

	//-------=============== Variable  for Search ==================--------
	String mode = doString.checkString(request.getParameter("mode"),"");
	String checkout = doString.checkString(request.getParameter("checkout"),"");
	String selProj = doString.checkString(request.getParameter("sel_project"),"");  	
	//String searchValue = doString.DisplayThai(doString.checkString(request.getParameter("search_value"),""));
	String searchValue = doString.checkString(request.getParameter("search_value"),"");
	//String vendCode = doString.checkString(request.getParameter("vend_code"),"");
	//String vendName = doString.checkString(request.getParameter("bus_name"),"");
	String iType = doString.checkString(request.getParameter("i_type"),"");
	
	
	//-------=============== VenProj Search ==================--------
	
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	SERV_CommonData com = null;
	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement(); 
		com = new SERV_CommonData(conn);                    
        //----=======================================----//  
       

 		
   	Hashtable codeList = (Hashtable) session.getAttribute("sess_vend_code");
       if (codeList==null) codeList = new Hashtable();
    Hashtable typeList = (Hashtable) session.getAttribute("sess_vend_type");
       if (typeList==null) typeList = new Hashtable();
 
       
  //---=========================  Click add to Cart   =======================---//
 	
 	String addCart = doString.checkString(request.getParameter("add_cart"),"");
   	if(addCart.equalsIgnoreCase("YES")){
   
	String[] keys = request.getParameterValues("vend_code");
	if (keys!=null) {

	   for (int i=0;i<keys.length;i++) {
	   
	       StringTokenizer id = new StringTokenizer(keys[i],":");	     //  if (id.countTokens()!=2) continue;
	       String venId = id.nextToken();
	       String vname = id.nextToken();
	 //      if (!codeList.containsKey(venId)) {
	 	       codeList.put(venId+iType,"");
		       typeList.put(venId+iType,iType);
	//	   }
	       
	   } // end for
	} // end if check keys is not null
		
		
		 session.setAttribute("sess_vend_code",codeList);
		 session.setAttribute("sess_vend_type",typeList);
		
   	
   	}//end addCart =='Yes'
  	   

 
 
 
%>

<HTML>
<HEAD>
<TITLE>Add ผู้รับเหมา (pop up)</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">

  function searchData(){
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_VenPrj02.jsp?mode=search";
     document.forms[0].submit();  
  }
  
   function  checkAll(obj,mainCheck,subCheck) {
     var main = document.forms[0].elements[mainCheck];
     var sub = document.forms[0].elements[subCheck];
     
     if (obj!=null && main!=null && sub!=null) {
     
         var checkObj = document.forms[0].elements["check_"+obj.value];
         if (checkObj!=null && obj.checked) {
            checkObj.value = "checked";
         } else {
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
			} else {
			   main.checked = obj.checked;
			} // end if check sub
         } // end if check mainCheck
     } // end if check null
  }  

   function checkOut() {
     document.forms[0].add_cart.value='YES';  
     document.forms[0].checkout.value='YES';       
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_VenPrj02.jsp?i_type=<%=iType%>";
     document.forms[0].submit();
  } 
   
 function addToCart() { 
     document.forms[0].add_cart.value='YES';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_VenPrj02.jsp?i_type=<%=iType%>";
     document.forms[0].submit();
  } 
  
  function changePage(page) {  
 	document.forms[0].now_page.value=page;
    document.forms[0].action="<%=Constants.APP_PATH%>/SERV_VenPrj02.jsp";
    document.forms[0].submit();
  }    
  
 function test(){
    alert("iType="+document.forms[0].i_type.value);
    //alert("searchValue="+document.forms[0].search_value);
 }

<%
  if (checkout.equalsIgnoreCase("YES")) {
      %>
      window.opener.document.forms[0].submit();
      window.close();      
      <%
  }
%>


</script>


</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0"> 
<FORM method="post" action="">

<INPUT type="hidden" name="mode" value="<%=mode%>">
<INPUT type="hidden" name="search" value="">
<INPUT type="hidden" name="add_cart" value="">
<INPUT type="hidden" name="checkout" value="">
<INPUT type="hidden" name="vend_name" value="<%//=vendName%>">
<INPUT type="hidden" name="i_type" value="<%=iType%>">
<INPUT type="hidden" name="sel_project" value="<%=selProj%>">


<table border="0" width="500" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD">
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            Add รายชื่อผู้รับเหมา</td>
        </tr>
      </table>


<br style="font-size:10pt">
     

            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="100">เลือกผู้รับเหมา</td>
                <td class="item_tab3"></td>
                <td class="textgray ; small" align="right">&nbsp;<input type="text" name="search_value" value="<%=doString.DisplayThai(searchValue)%>"  class="box" style="width:280px" size="20">&nbsp;&nbsp;
                  <a href="#" onclick="searchData();"><img border="0" src="images/i_search.gif" align="absmiddle" width="20" height="20" style="cursor:hand"></a></td>
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
          <td class="col_name" width="8%"><input type="checkbox" name="main_check" onclick="checkAll(this,'main_check','vend_code');"></td>
          <td class="col_name" width="16%">รหัส</td>
          <td class="col_name" width="76%">ชื่อผู้รับเหมา</td>
        </tr>
       <%
      
       	int line=0;
        searchValue = doString.checkString(request.getParameter("search_value"),"");
     	if(!searchValue.equals("")){
     
             sql.delete(0,sql.length());
             sql.append(" select vend_code,bus_name from lan:stpvendr ")
 				.append(" where bus_name like '%"+searchValue+"%'")
 			    .append(" order by vend_code ");
 			   
			servlog.startLog(sql.toString());
	       	rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
		 
		   while(rs.next()) {
		    	 	String vendCode = doString.checkString(doString.DisplayThai(rs.getString("vend_code")),"");
			  		String vendName = doString.checkString(doString.DisplayThai(rs.getString("bus_name")),"");
		      	
		      		String checked = "";
		      		if (codeList.containsKey(vendCode)) checked = " checked ";
	    %>  
        <tr>
          <td align="center" class="dotline" width="8%">
             <input type="checkbox" name="vend_code" <%=checked%> value="<%=vendCode%>:<%=vendName%>:<%=iType%>" onclick="checkAll(this,'main_check','vend_code');">
		 
		     <input type="hidden" name="check_<%=vendCode%>" value="<%=checked%>">
		     </td>
          <td class="dotline ; item" align="center" width="16%"><%=vendCode%></td>
          <td align="left" class="dotline" width="76%"><%=vendName%></td>
          </tr>
         <%line++;
		 } //end while
		rs.close();				
		
		//----========= Fill up blank line if this page display data less than 12 line ========--//
		while(line<Constants.SERV_XSTD_LINE){
		  line++;
		    %>
           <tr>
          <td align="center" class="dotline" width="8%">&nbsp;</td>
          <td class="dotline ; item" align="center" width="16%">&nbsp;</td>
          <td align="left" class="dotline" width="76%">&nbsp;</td>
          </tr>
          
          <%
        	}
         }
         
         if(searchValue.equals("")) {
         
         for (int l=line;l<Constants.SERV_XSTD_LINE;l++) {
         %>
         <tr>
          <td align="center" class="dotline" width="8%">&nbsp;</td>
          <td class="dotline ; item" align="center" width="16%">&nbsp;</td>
          <td align="left" class="dotline" width="76%">&nbsp;</td>
          </tr>  
         <%
         } // end for
         }//end searchValue not null  
          
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


   <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr class="gray">
          <td width="100%" align="right">.</td>
        </tr>
      </table>



<br style="font-size:10pt">


   


        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="150" class="act_tab2">

             <a href="#" onclick="addToCart(); "><img border="0" src="images/act_add2cart.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp;
             <a href="javascript:checkOut();"><img border="0" src="images/act_checkout.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>

            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="javascript:self.close()"><img border="0" src="images/bu_close.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>  
        </table>  

          </td>
        </tr>
      </table>
			
</FORM>
</BODY>

</HTML>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_VenProj02.jsp : " + e.getMessage());
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