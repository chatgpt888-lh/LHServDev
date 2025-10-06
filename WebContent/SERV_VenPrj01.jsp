<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%//
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_VenPrj01.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

	//-------=============== Variable  for Search ==================--------
	String mode = doString.checkString(request.getParameter("mode"),"");
	String error = doString.checkString(request.getParameter("error"),"");
	String addType = doString.checkString(request.getParameter("add_type"),""); 	
	String selProj = doString.checkString(request.getParameter("sel_project"),"");
	String vendorCode = doString.checkString(request.getParameter("vendor_code"),"");
	String vendorList = doString.checkString(request.getParameter("vendor_list"),"");
	String iType = doString.checkString(request.getParameter("i_type"),"");
	String vendName = doString.checkString(request.getParameter("vend_name"),"");
	String searchValue = doString.DisplayThai(doString.checkString(request.getParameter("search_value"),""));
	String addCart = doString.checkString(request.getParameter("add_cart"),"");
	String projDesc = "-";
	String vendorId = vendorCode+iType;
		//---=========================================================================----//
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
    	
	    Hashtable typeList = (Hashtable) session.getAttribute("sess_vend_type");
       	 if (typeList==null) typeList = new Hashtable();
       	Hashtable codeList = (Hashtable) session.getAttribute("sess_vend_code");
       	 if (codeList==null) codeList = new Hashtable();
       	Hashtable addPayList = (Hashtable) session.getAttribute("sess_vend_add_pay");
       	 if (addPayList==null) addPayList = new Hashtable();
		 
       	Hashtable addPubList = (Hashtable) session.getAttribute("sess_vend_pub_pay");
       	 if (addPubList==null) addPubList = new Hashtable();
		 
       	Hashtable addInfList = (Hashtable) session.getAttribute("sess_vend_inf_pay");
       	 if (addInfList==null) addInfList = new Hashtable();

       	
		    //---============= Create no Inform , Get Project details ===========----//
			String icom = selProj.length()>=6 ? selProj.substring(0,2) : "";
			String iproj = selProj.length()>=6 ? selProj.substring(3,6) : "";
	        sql.delete(0,sql.length());
	        sql.append(" select i_company||'-'||i_project||'-'||n_project sel_project  from lan:acxprojt ")
	              .append(" where i_company='"+icom+"'  and i_project='"+iproj+"' ");
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			if (rs.next()) {
                 projDesc = doString.checkString(doString.DisplayThai(rs.getString("sel_project")),"");
			} // end while
			rs.close();		 
            	 
    
       	if (addCart.equalsIgnoreCase("DELETE")) {
       		String [] keys =request.getParameterValues("vend_code");

			if (keys!=null) {
			   for (int i=0;i<keys.length;i++) {
			       StringTokenizer id = new StringTokenizer(keys[i],":");
			       if (id.countTokens()!=2) continue;
			       
			       String venId = id.nextToken();
			       String vname = id.nextToken();
			       
			       if (codeList.containsKey(venId)) {
				       codeList.remove(venId);
				       typeList.remove(venId);
				       addPayList.remove(venId);
					   addPubList.remove(venId);
				       addInfList.remove(venId);
				       
				       session.setAttribute("sess_vend_code",codeList);
		 			   session.setAttribute("sess_vend_type",typeList);
		 			   session.setAttribute("sess_vend_add_pay",addPayList);
					   session.setAttribute("sess_vend_pub_pay",addPubList);
		 			   session.setAttribute("sess_vend_inf_pay",addInfList);
				   }
			       
			   } // end for
			} // end if check keys is not null
       	}  	
	  
	%>
	
<HTML>
<HEAD>
<TITLE>ข้อมูลพื้นฐาน : 01รายละเอียดผู้รับเหมาซ่อมภายในโครงการ</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">

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
 
 function saveData() {
 	if (document.forms[0].sel_project.value==""){
 	 	alert(" กรุณาเลือกโครงการ !");
     	document.forms[0].sel_project.focus();
     	return false;
 	} else	{ 
		for (var i=0;i<document.forms[0].length;i++) {
			  var obj = document.forms[0].elements[i];
			  if (obj!=null && obj.name.indexOf("p_add_pay")==0) {
				  if (obj.value=="") {
					  alert("กรุณากรอก % ดำเนินการ");
					  obj.focus();
					  return false;
				  }
			  }
			  if (obj!=null && obj.name.indexOf("p_pub_pay")==0) {
				  if (obj.value=="") {
					  alert("กรุณากรอก % ดำเนินการ");
					  obj.focus();
					  return false;
				  }
			  }
			  
			  if (obj!=null && obj.name.indexOf("p_inf_pay")==0) {
				  if (obj.value=="") {
					  alert("กรุณากรอก % ดำเนินการ");
					  obj.focus();
					  return false;
				  }
			  }
		}
		
 		document.forms[0].action="<%=Constants.APP_PATH%>/SERV_VenPrjServlet?mode=add";
    	document.forms[0].submit();
	}
    
  } 

 function deleteData() {
     //document.forms[0].action="<%=Constants.APP_PATH%>/SERV_VenPrjServlet?mode=delete";
     //document.forms[0].submit();
     
     if (confirm("คุณแน่ใจว่าต้องการลบข้อมูลที่เลือก ?")) {
	     document.forms[0].add_cart.value='DELETE';
	     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_VenPrj01.jsp";
	     document.forms[0].submit();     
     }
     
  } 
  
 function addToCart(index) {
     document.forms[0].add_type[index].checked = true;
     document.forms[0].add_cart.value='YES';
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_VenPrj01.jsp";
     document.forms[0].submit();
  } 

 function search(){
 	if ((document.forms[0].i_type.value=="")||(document.forms[0].i_type.value==null)) {
        alert(" กรุณาเลือกประเภทผู้รับเหมา !");
        document.forms[0].i_type.focus();
        return false;
     } else {
      var iType=document.forms[0].i_type.value ;
   //  alert("iType="+document.forms[0].i_type.value + "searchValue="+document.forms[0].value);
      var searchValue = document.forms[0].search_value.value;
     MM_openBrWindow('SERV_VenPrj02.jsp?mode=search&i_type='+iType+'&search_value='+searchValue,'','status=yes,resizable=yes,scrollbars=yes,width=520,height=370')
   }
 }
 
function test(type){
    //	alert(type);
}

function  inputFloat(obj) {
	  if((event.keyCode < 48 || event.keyCode > 57) && event.keyCode!=46) {
		 event.returnValue = false;
	  } else if (event.keyCode==46) {
		 var chkval = obj.value+".";
		 if (chkval.indexOf(".")!=chkval.lastIndexOf(".")) {
			 event.returnValue = false;
		 }
	  }
} 

</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM method="post">

<INPUT type="hidden" name="mode" value="<%=mode%>">
<INPUT type="hidden" name="add_cart" value="">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            ข้อมูลพื้นฐาน</td>
        </tr>
      </table>


<br style="font-size:10pt">
                

            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250">รายละเอียดผู้รับเหมาซ่อมภายในโครงการ</td>
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
    <td class="item ; dotline01" height="22" width="18%" colspan="2">โครงการ :</td>
    <td height="22" width="44%" class="dotline01">
	 <%=projDesc%> 
	 <input type="hidden" name="sel_project" value="<%=selProj%>">
     </td>
    <td height="22" class="item ; dotline01" width="10%">ประเภท :</td>
    <td height="22" width="28%" class="dotline01">
        <select name="i_type" size="1"  class="box" style="width:180px" >
         <option value="01" <%=iType.equals("01") ? " selected " : "" %>>01 ผู้รับเหมาซ่อม</option>
         <option value="02" <%=iType.equals("02") ? " selected " : "" %>>02 ผู้รับเหมาสร้างเพื่อตัดเงิน</option>
       </select></td>
  </tr>   
  <tr>
    <td class="item ; dotline01" height="22" width="13%">รหัสผู้รับเหมาซ่อม
      :</td>
    <td class="item ; dotline01" height="22" width="5%" align="right">
     <input type="radio" <%=(addType.equalsIgnoreCase("sel") ? "checked" : "")%> value="sel" name="add_type">
      </td>
    <td height="22" width="82%" class="dotline01" colspan="3">
	<%=com.genAllVendorList("vendor_list",vendorList,"size='1' class='box' style='width:250px'")%>    
	&nbsp;&nbsp; <a href="#" onclick='addToCart(0);'><img border="0" src="images/bu_add.gif" align="absmiddle" width="30" height="12" onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70) ; cursor:hand" ></a></td>
  
  </tr>
  
  
  <tr>
    <td class="item ; dotline01" height="22" width="13%">&nbsp;</td>
    <td class="item ; dotline01" height="22" width="5%" align="right">
        <input type="radio" <%=(addType.equalsIgnoreCase("key") ? "checked" : "")%> value="key" name="add_type">
        </td>
    <td height="22" width="82%" class="dotline01" colspan="3">
        <input type="text" name="vendor_code" class="box" style="width:250px" size="20" value="<%=vendorCode%>">&nbsp;&nbsp;
          <img border="0" src="images/bu_add.gif" align="absmiddle" width="30" height="12"
            onclick="addToCart(1)" onmouseout=nereidFade(this,70,50,5)    
               onmouseover=nereidFade(this,100,50,5)     
                 style="FILTER: alpha(opacity=70) ; cursor:hand" ></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">&nbsp;</td>
    <td class="item ; dotline01" height="22" width="5%" align="right">
        <input type="radio" value="<%=searchValue%>" name="add_type">
        </td>
    <td height="22" width="82%" class="dotline01" colspan="3">
        <input type="text" name="search_value" class="box" style="width:250px" size="20" value="<%=searchValue%>">&nbsp;&nbsp;
         <img border="0" src="images/i_search.gif" align="absmiddle" width="20" height="20" style="cursor:hand" 
          onclick="search();"></td>
    
    
    
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


<br style="font-size:2pt">

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
          <td class="col_name" width="6%"><input type="checkbox" name="main_check" onclick="checkAll(this,'main_check','vend_code');"></td>
          <td class="col_name" width="27%">ประเภทผู้รับเหมา</td>
          <td class="col_name" width="37%">รหัสผู้รับเหมา</td>
          <td class="col_name" width="10%">% ดำเนินการซ่อมบ้าน</td>
          <td class="col_name" width="10%">% ดำเนินการซ่อมสาธารณะ</td>
          <td class="col_name" width="10%">% ดำเนินการซ่อมสาธารณู</td>
        </tr>

        <% 	 
        //----========= If Click Add to CART , Update Item ===========----//
    	if ((addType.equalsIgnoreCase("sel") || addType.equalsIgnoreCase("key")) && addCart.equalsIgnoreCase("YES")) {

 		   //---=========== Type = Select from listbox ===============---// 	
          if (addType.equalsIgnoreCase("sel")) {
           StringTokenizer vend = new StringTokenizer(vendorList,"|"); //====edit
           if (vend.countTokens()==2) {
				 String id = doString.checkString(vend.nextToken(),"").trim();
				 String name = doString.DisplayThai(doString.checkString(vend.nextToken(),"").trim());
           
	             String chkCode = iType+name;
		         boolean dup = true; 
             
               	  if((codeList!=null)  || (typeList!=null)) {
           	         Enumeration keys = codeList.keys();
        			     while (keys.hasMoreElements())
                           {
	           	 				String val = (String)keys.nextElement();
	            				      if(chkCode.equals(codeList.get(val))){
	            				   	    dup= false;
	            				   	    %>
	            				   	         <script>alert('ข้อมูลซ้ำ กรุณาเพิ่มใหม่'); </script>
	            				   	      <%
	            						}
	                  					
	             		   } //end loop while
				  } // end if check null

                 if (!codeList.contains(id+iType)) { 
                       codeList.put(id+iType,iType+name);
	     	           typeList.put(id+iType,iType);
	     	     }

	     	     session.setAttribute("sess_vend_code",codeList);           
		         session.setAttribute("sess_vend_type",typeList);           
               } //end countTokens
	                
            } 
			//---==================================================----//
			


            //---=========== Type = Key Code manually ===============---// 
			else {
		    sql.delete(0,sql.length());
		    sql.append(" select * from lan:stpvendr where vend_code='").append(vendorCode).append("' ");
			servlog.startLog(sql.toString());
		    rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
		   
		    if (rs.next()) {		    
		        String name = doString.DisplayThai(rs.getString("bus_name"));		       
		    	boolean dup = true;
		    	String chkCode = iType+name;
		 					
		          Enumeration keys = codeList.keys();
		           while(keys.hasMoreElements()) {
		         	     String val =(String) keys.nextElement();
		                 if(chkCode.equals(codeList.get(val))) {
		                         dup = false;		                           
	                            %><script>alert('ข้อมูลซ้ำ กรุณาเพิ่มใหม่'); </script><%
		                 }
		    
		           }
		    
		         if (!codeList.contains(vendorCode+iType)) {
		               codeList.put(vendorCode+iType,iType+name);
		               typeList.put(vendorCode+iType,iType);
		             }
		         
		         session.setAttribute("sess_vend_code",codeList);
		         session.setAttribute("sess_vend_type",typeList);           
		    } else {
		      %><script>alert('No Data');</script><% 
		    }
		    rs.close(); 
	    } 
    	//---==================================================----//

  }  //end check addType  
  

  //------------------- update p_add_pay -------------------------//
  if (error.trim().length()==0) {
		Enumeration key1 = codeList.keys();
	    while(key1.hasMoreElements()) {
			 String val =(String) key1.nextElement();
 			 addPayList.put(val,doString.checkString(request.getParameter("p_add_pay"+val),"17"));
			 addPubList.put(val,doString.checkString(request.getParameter("p_pub_pay"+val),"17"));
 			 addInfList.put(val,doString.checkString(request.getParameter("p_inf_pay"+val),"17"));
	    }
 	    session.setAttribute("sess_vend_add_pay",addPayList);
		session.setAttribute("sess_vend_pub_pay",addPubList);
 	    session.setAttribute("sess_vend_inf_pay",addInfList);
  }
  //--------------------------------------------------------------//


        int line=0;
         if((codeList!=null)&&(typeList!=null)&&(addPayList!=null) &&(addPubList!=null) &&(addInfList!=null)) {
          
          Enumeration keys = codeList.keys();
     	  while (keys.hasMoreElements()) {
		      String key = doString.checkString((String) keys.nextElement(),"").trim();
		      String name = doString.checkString((String) codeList.get(key),"");
		      String t = doString.checkString((String) typeList.get(key),"");
			  String addPayVal = doString.checkString((String) addPayList.get(key),"");
			  String pubPayVal = doString.checkString((String) addPubList.get(key),"");
			  String infPayVal = doString.checkString((String) addInfList.get(key),"");
		      String sms ="";

		      if(t.equals("01")){sms="ผู้รับเหมาซ่อม";}
		      if(t.equals("02")){sms="ผู้รับเหมาสร้างเพื่อตัดเงิน";}

		      if (name.trim().length()==0) {
		            sql.delete(0,sql.length());
					if(key.length()>6){
						 sql.append(" select * from lan:stpvendr where vend_code='").append(key.substring(0,6)).append("' "); 
					} else {  
						sql.append(" select * from lan:stpvendr where vend_code='").append(key).append("' "); 
					}
					servlog.startLog(sql.toString());
		           rs = stmt.executeQuery(sql.toString());
				   servlog.endLog();
		           if (rs.next()) {
		               name = t+doString.checkString(doString.DisplayThai(rs.getString("bus_name")),"");
		           }
		           rs.close();
		      }
		      
             %>
	        <tr>
	          <td align="center" class="dotline" width="6%">
	             <input type="checkbox" name="vend_code" value="<%=key%>:<%=t%>" onclick="checkAll(this,'main_check','vend_code');"></td>
	          <td class="dotline" align="left" width="27%"><%out.println(sms);%>
	          </td>
	          <td align="left" class="dotline" width="37%">	          
	          <%
	            if(key.length()>=2){
					 out.println(key.substring(0,key.length()-2)+" | "+name.substring(2));
				}       
	          %>
				&nbsp;</td>
			  <td align="center" class="dotline" width="10%">
			  <%
				 if(t.equals("01")){
					%><input type="text" name="p_add_pay<%=key%>" class="box" style="width:95%" size="20" value="<%=addPayVal%>" onkeypress="inputFloat(this)"><%
				} else {
					%>&nbsp;<%
				}
			  %>			  
			  </td>


			  <td align="center" class="dotline" width="10%">
			  <%
				 if(t.equals("01")){
					%><input type="text" name="p_pub_pay<%=key%>" class="box" style="width:95%" size="20" value="<%=pubPayVal%>" onkeypress="inputFloat(this)"><%
				} else {
					%>&nbsp;<%
				}
			  %>			  
			  </td>
			  
			  <td align="center" class="dotline" width="10%">
			  <%
				 if(t.equals("01")){
					%><input type="text" name="p_inf_pay<%=key%>" class="box" style="width:95%" size="20" value="<%=infPayVal%>" onkeypress="inputFloat(this)"><%
				} else {
					%>&nbsp;<%
				}
			  %>			  
			  </td>

	        </tr>
			<%
			   line++;
 			
       }	  //end while 
	}   //end check codeList is not null    
	   
	while (line<Constants.SERV_XSTD_LINE) {
	    line++;
		%>           
         <tr>
           <td align="center" class="dotline" width="6%">&nbsp;</td>
           <td class="dotline" align="left" width="27%">&nbsp;</td>
           <td align="left" class="dotline" width="37%">&nbsp;</td>
           <td align="left" class="dotline" width="10%">&nbsp;</td>
		   <td align="left" class="dotline" width="10%">&nbsp;</td>
           <td align="left" class="dotline" width="10%">&nbsp;</td>
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




<br style="font-size:10pt">



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="150" class="act_tab2">

            <a href="#" onclick="saveData()"><img border="0" src="images/act_save.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp; 
            <a href="#" onclick="deleteData()"><img border="0" src="images/act_delete.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>

            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_VenPrj.jsp" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
		System.out.println("ERROR SERV_VenProj01.jsp : " + e.getMessage());
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
