<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<!--  
<%@ include file="confirmLogin.jsp" %>
  -->
<%

	System.out.println("Welcome to List");
	Object objList = request.getAttribute("listData");
	List selectorList = null;
	
	if(objList != null) {
	selectorList = (List) objList;
	//System.out.println("selectorList size = "+ selectorList.size());
	}
	
    String comId = "all";
	Object icom = request.getAttribute("icom");
	Object ipro = request.getAttribute("ipro");
	String iCom = null;
	String iProj = null;
	String all  = (String) request.getAttribute("all");
	
	
	if(icom != null && ipro != null) {
	
    iCom = (String) icom;
    iProj = (String) ipro;
    
    comId = icom+"-"+ipro; 
	//System.out.println("filter = "+ iCom + "-" + iProj);
	
	}
	
	%>
	
	
	<% 
	
	Object objListS = request.getAttribute("listSearchData");
	List searchList = null;
	
	if(objListS != null) {
	searchList = (List) objListS;
	//System.out.println("searchList size = "+ searchList.size());
	}
	 
	 %>

<HTML> 
<HEAD>
<TITLE>Lstaff List</TITLE>

<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">


<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
   
    function do_totals1() {
   	 	document.all.pleasewaitScreen.style.pixelTop = (document.body.scrollTop + 120);
    	document.all.pleasewaitScreen.style.visibility = "visible";
	    document.getElementById("img1").innerHTML= "<img src=\"<%=request.getContextPath()%>/images/p_loading.gif\" HEIGHT=\"60px\">";
    }
    
    
    
    function loading(){
    	do_totals1() ;	 
	 	document.forms[0].action="<%=request.getContextPath()%>/SERV_LStaffServlet?cmd=searchLStaff";
		document.forms[0].submit();
    
    }
    
 
</script>

</head>

<BODY leftMargin=0 topMargin=0 marginwidth="0" marginheight="0">

<%-- ############################## --%>
<DIV ID="pleasewaitScreen" STYLE="position: absolute; z-index: 0; top: 45%; left: 42%; visibility: hidden">
 <TABLE BORDER="1" BORDERCOLOR="rgb(180,210,250)" CELLPADDING="0" CELLSPACING="0" HEIGHT="125px" WIDTH="265px" ID="Table1">
 <TR>
 <TD BGCOLOR="#FFFFFF" ALIGN="CENTER" VALIGN="MIDDLE" class="test">
 <font color="rgb(255,120,0)"><b>Loading... Please wait</b></font>
 <br>
 <br>
 <span id="img1"></span>
 </TD> 
 </TR>
 </TABLE>
 </DIV>

<%-- ############################## --%>



<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
  <TBODY>
  <TR>
    <TD class=BD width="100%">
      <TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
        <TBODY>
        <TR onclick="return func_1(this, event);">
          <TD class=bigh width="100%">
          <IMG border=0 src="images/i_home.gif" width=20 align=absMiddle height=20>&nbsp; ข้อมูลพื้นฐาน
          </TD>
        </TR>
        </TBODY>
        </TABLE>
    <BR style="FONT-SIZE: 10pt">
    
      <TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
        <TBODY>
        <TR>
          <TD class=item_tab1>
          <IMG border=0 src="images/i_i.gif" width=20 align=absMiddle height=20></TD>
          <TD class=item_tab2 width=250>ข้อมูล FollowUp และ Turn key โครงการ</TD>
          <TD class=item_tab3></TD>
          <TD>&nbsp;</TD>
         </TR>
         </TBODY>
         </TABLE>
      
      <TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
        <TBODY>
        <TR>
          <TD vAlign=top width=5>
          <IMG border=0 src="images/Corn01.gif" width=5 height=5></TD>
          <TD class=frmTop>&nbsp;</TD>
          <TD vAlign=top width=5 align=right>
          <IMG border=0 =src="images/Corn02.gif" width=5 height=5></TD>
          </TR></TBODY></TABLE>
      <TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
        <TBODY>
        <TR>
          <TD class=frmLR width="100%" align=center>
          <TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
          <TBODY>
       		<TR>
         	<TD class="item ; dotline01" height=22 width="5%">โครงการ</TD>
    
    <!-- selector -->              
     
       <TD class=dotline01 height=22 width="20%">
       <form method="POST" action="SERV_LStaffServlet?cmd=searchLStaff">
         <%
                  if(selectorList!=null && selectorList.size()>0){
                  	 HashMap hashmap = null;  
                  	 String select = "";
                  	%>
                  	 
                  	
                  	 <br>
                  	 <br>
                <SELECT class=box style="WIDTH: 200px" size=1 name="iCOM_ID" id="iCom">
                
					<OPTION value="">------ กรุณาเลือก ------</OPTION>
					
		
				<%if ("all".equals(all)) { 
				     select = " selected ";
				     }
				%>
                    <OPTION value="all" <%=select%> >------ ทุกโครงการ ------</OPTION>	 
                   
              
                 
                 <%  
                 for (Iterator iter = selectorList.iterator(); iter.hasNext(); ){
						 hashmap = (HashMap) iter.next(); 
						 String selectPro = "";
					
					if(null != iCom && null != iProj  ){	 
					if(iCom.equals(hashmap.get("iCOM_ID").toString()) && iProj.equals(hashmap.get("iPROJ_ID").toString())){
					selectPro = " selected ";
				      }
					}
				 %>
                    <OPTION  value=<%= hashmap.get("iCOM_ID").toString()  %>-<%=hashmap.get("iPROJ_ID").toString()%> <%=selectPro%>>
                    <%= hashmap.get("iCOM_ID").toString()%>-<%=hashmap.get("iPROJ_ID").toString()%> <%=hashmap.get("nPROJ").toString() %>
                    </OPTION>
                   
                   <% 
                  } 
                     }  else {
      System.out.println("no data"); 
       
      } %> 
      
       
       <!-- search -->
        </SELECT>
        </form>
		</TD>
	  	<td height=22 width="75%">
	  	<a href="javascript:loading();" > 
	  	<img src="images/bu_go.gif" style="CURSOR: hand" border="0" alt="Submit" width=40 align=absMiddle height=22 />
	  	</a>&nbsp;</td>
      	</TR>
      
      	</TBODY>
      	</TABLE>
      	</TD>
      	</TR>
      	</TBODY>
      	</TABLE>

              
      <TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
        <TBODY>
        <TR>
          <TD vAlign=bottom width=5>
          <IMG border=0  src="images/Corn03.gif" width=5 height=5></TD>
          <TD class=frmBottom>&nbsp;</TD>
          <TD vAlign=bottom width=5 align=right>
          <IMG border=0  src="images/Corn04.gif" width=5 height=5>
          </TD>
          </TR>
          </TBODY>
          </TABLE>
          <BR style="FONT-SIZE: 2pt">
      
      <TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
        <TBODY>
        <TR>
          <TD bgColor=#d7e6ff vAlign=top width=5>
          <IMG border=0 src="images/Corn01.gif" width=5 height=5></TD>
          <TD class=frmTop bgColor=#d7e6ff>&nbsp;</TD>
          <TD bgColor=#d7e6ff vAlign=top width=5 align=right>
          <IMG border=0 src="images/Corn02.gif" width=5 height=5>
          </TD>
        </TR>
        </TBODY>
        </TABLE>
      
      <TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
        <TBODY>
        <TR>
          <TD class=frmL width="100%">
            <TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
              <TBODY>
              <TR>
                <TD class=col_name width="15%" rowspan = "2">โครงการ</TD>
                <TD class=col_name width="5%"  rowspan = "2">Zone</TD>
                <TD class=col_name width="75%"  colspan="8">ผู้รับผิดชอบ</TD>                
                <TD class=col_name width = "5%" rowspan = "2">action</TD> 
              </TR>
                
              
              <TR>
                <TD class=col_name >Zone</TD>
                <TD class=col_name >Manager 1</TD>
                <TD class=col_name >Manager 2 </TD>
                <TD class=col_name >Service Staff 1</TD>
                <TD class=col_name >Service Staff 2</TD>
                <TD class=col_name >Status</TD>
                <TD class=col_name >Turn Key</TD>
                <TD class=col_name >ผู้รับเหมาซ่อม</TD>
              </TR>
                
              <%if(searchList !=null && searchList.size()>0){
                  HashMap hashmaps = null;
                  for (Iterator iter2 = searchList.iterator(); iter2.hasNext(); ){
						 hashmaps = (HashMap) iter2.next(); %>
			<TR> 
              <TD class=dotline vAlign=top width="20%" align=left >
              <a href="SERV_LStaffServlet?cmd=EditProject&iComId=<%=hashmaps.get("iCOM_IDs").toString()%>&iProject=<%=hashmaps.get("iPROJ_IDs").toString()%>">
              <%=hashmaps.get("iCOM_IDs").toString() %>-<%=hashmaps.get("iPROJ_IDs").toString() %> <%=hashmaps.get("nPROJs").toString() %></a>
              </TD>
                
              <TD class=dotline vAlign=top  align=center >
               <%= hashmaps.get("zones") == null ? "" : hashmaps.get("zones").toString()
                 
               %> &nbsp;
              </TD>
              <TD class=dotline vAlign=top  align=left>
               <%= hashmaps.get("iEmploys") == null? "":hashmaps.get("iEmploys").toString()
               %>  
               <%= hashmaps.get("iEmployName") == null? "":hashmaps.get("iEmployName").toString()
               %> &nbsp;
             </TD>
             <TD class=dotline vAlign=top  align=left>
               <%= hashmaps.get("iEmployM1") == null? "":hashmaps.get("iEmployM1").toString()
               %>  
               <%= hashmaps.get("iEmployM1Name") == null? "":hashmaps.get("iEmployM1Name").toString()
               %> &nbsp;
             </TD>
             <TD class=dotline vAlign=top  align=left>
              <%= hashmaps.get("iEmployM2") == null? "":hashmaps.get("iEmployM2").toString()
              %>  
              <%= hashmaps.get("iEmployM2Name") == null? "":hashmaps.get("iEmployM2Name").toString()
              %> &nbsp;
             </TD>
             <TD class=dotline vAlign=top  align=left>
              <%= hashmaps.get("iEmployS1") == null? "":hashmaps.get("iEmployS1").toString()
              %>  
              <%= hashmaps.get("iEmployS1Name") == null? "":hashmaps.get("iEmployS1Name").toString()
              %> &nbsp;
              </TD>
              <TD class=dotline vAlign=top  align=left>
              <%= hashmaps.get("iEmployS2") == null? "":hashmaps.get("iEmployS2").toString()
              %>  
              <%= hashmaps.get("iEmployS2Name") == null? "":hashmaps.get("iEmployS2Name").toString()
              %> &nbsp;&nbsp;
              </TD>
              <TD class=dotline vAlign=top  align=center>  
              <%= hashmaps.get("ftk") == null? "":hashmaps.get("ftk").toString()
              %> &nbsp;
              </TD>
              <TD class=dotline vAlign=top  align=left>
              <%= hashmaps.get("iEmployApp1") == null? "":hashmaps.get("iEmployApp1").toString()
              %>
              <%= hashmaps.get("iEmployApp1Name") == null? "":hashmaps.get("iEmployApp1Name").toString()
              %> &nbsp;
              </TD>
              <TD class=dotline vAlign=top align=left>
              <%= hashmaps.get("iVen1")==null? "":hashmaps.get("iVen1").toString() 
              %> 
              <%= hashmaps.get("iVenName")==null? "":hashmaps.get("iVenName").toString() 
              %> &nbsp;
              </TD>
              <TD class=dotline vAlign=top align=center>     
              <A href="SERV_LStaffServlet?cmd=delProject&icomdel=<%=hashmaps.get("iCOM_IDs").toString() %>&iprodel=<%=hashmaps.get("iPROJ_IDs").toString()%>&iCOM_ID=<%=comId %>"
                 onclick="return confirm('ท่านต้องการลบข้อมูลโครงการนี้ใช่หรือไม่?')"
                 id="sendForm" >
              <IMG onmouseover=nereidFade(this,100,50,5)  onmouseout=nereidFade(this,70,50,5)  style="FILTER: alpha(opacity=70)" border=0 src="images/bu_del.gif" ></A> 
              </TD>
              </TR>
              <%
                  }
                     }  else {
      System.out.println("no data"); 
      %>
           <tr>
           <TD class=dotline vAlign=top width="5%" align=center colspan = "11">  &nbsp;</TD> 
           </tr>
           <tr>
           <TD class=dotline vAlign=top width="5%" align=center colspan = "11"> ไม่พบโครงการในระบบ &nbsp;</TD> 
       	   </tr>
           <tr>
           <TD class=dotline vAlign=top width="5%" align=center colspan = "11"> &nbsp;</TD> 
           </tr>
    
       
       <%} %> 
            
      </TBODY>
      </TABLE>
      </TD>
      </TR>
      </TBODY>
      </TABLE>
      
       <TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
        <TBODY>
        <TR>
        
          <TD vAlign=bottom width=5>
          <IMG border=0 src="images/Corn03.gif" width=5 height=5></TD>
          <TD class=frmBottom>&nbsp;</TD>
          <TD vAlign=bottom width=5 align=right>
          <IMG border=0 src="images/Corn04.gif" width=5 height=5>
          </TD>
          </TR>
          </TBODY>
          </TABLE>
          </TD>
          </TR>
          </TBODY>
          </TABLE>
          <BR style="FONT-SIZE: 3pt">
      
		  <BR style="FONT-SIZE: 10pt">
        <TABLE height=30 cellSpacing=0 cellPadding=0 width="100%" border=0>
        <TBODY>
        <TR>
		  <TD class=act_tab1></TD>
          <!-- add -->
          <TD class=act_tab2 width=150>
          <A href="SERV_LStaffServlet?cmd=FrmLoad">
          <IMG onmouseover=nereidFade(this,100,50,5) onmouseout=nereidFade(this,70,50,5) style="FILTER: alpha(opacity=70)" border=0 src="images/act_add.gif" 
               width=70 height=27>
          </A>
          </TD>
            
          <TD class=act_tab3></TD>
          
          <TD class=act_tab4>
          <A href="<%=request.getContextPath()%>/SERV_Index.jsp" target=_top>
          <IMG border=0 src="images/bu_back.gif"  width=50 align=absMiddle height=15>
          </A>&nbsp; 
          <A href="<%=request.getContextPath()%>/SERV_Index.jsp" target=_top>
          <IMG border=0 src="images/bu_home.gif" width=50 align=absMiddle height=15>
          </A>
          </TD>
          </TR>
          </TBODY>
          </TABLE>
          <BR style="FONT-SIZE: 30pt">
				

      
    
      
     
      
      </BODY>
      </HTML>
