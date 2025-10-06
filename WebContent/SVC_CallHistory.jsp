<%@page language="java" contentType="text/html; charset=tis-620"
	pageEncoding="tis-620"%>
<HTML>
<%@ page import="com.lh.util.doString" %>	
<%@ page import="com.svc.call.utilize.Constant" %>
<%@ page import="com.svc.call.bean.SVC_DOCHD" %>
<%@ page import="com.svc.call.bean.SVC_DOCDT" %>
<%@ page import="com.svc.call.bean.SVC_TELNO" %>
<%@ page import="com.svc.call.bean.SVC_XSTD" %>
<%@ page import="com.svc.call.bean.SVC_STDPJ" %>
<%@ page import="com.svc.call.utilize.Utilizer" %>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>	
<%@page import="java.text.*" %>	
<%
/**********************************************
 * create by : pradoem wonkraso
 * date time: 2013.10.28
 * Last modify :
 * version :1.0
 * project Name :Service Center 
 * description : implement for Service call center End user
 ***************************************************/
 //-----------------------Paging--------------------------
  Object obj2 = request.getAttribute("pageNoDDL");
  ArrayList  pageList = null;
  if(obj2!=null){
     pageList = (ArrayList)obj2;
  }else{
    pageList = new ArrayList();
  }
  String displayLine = request.getAttribute("displayLine")==null?"10":request.getAttribute("displayLine").toString();  
  String displayLinkPage = request.getAttribute("displayLinkPage")==null?"":request.getAttribute("displayLinkPage").toString();  
  String displayLinkPage2 = request.getAttribute("displayLinkPage2")==null?"":request.getAttribute("displayLinkPage2").toString(); 
  String recordNo = request.getAttribute("recordNo")==null?"1":request.getAttribute("recordNo").toString();  
  String recordNo2 = request.getAttribute("recordNo2")==null?"1":request.getAttribute("recordNo2").toString();
 //--------------------Paging-----------------------------

	String tel = request.getAttribute("tel")==null?"":request.getAttribute("tel").toString();
	String agentId = request.getAttribute("agentId")==null?"":request.getAttribute("agentId").toString();
	String projectSel = request.getAttribute("projectDDL")==null?"":request.getAttribute("projectDDL").toString(); //LH:075
	String houseNo = request.getAttribute("houseNo")==null?"":request.getAttribute("houseNo").toString();
	String lock = request.getAttribute("lock")==null?"":request.getAttribute("lock").toString(); //LH:075
    
   Object  objProject = session.getAttribute(Constant.SS_PROJECT_AVAILABLE_LIST);
   Object  objDocHd = request.getAttribute("listDocHd");
   Object  objHistory = request.getAttribute("listHistory");
   ArrayList   listDOCHD = null;
   ArrayList   listHomeHistoryRepair  = null;
   ArrayList   projectList = null;
   
    if(objProject!=null){ projectList = (ArrayList)objProject;
	}else{  projectList = new ArrayList();}
   
   	if(objDocHd!=null){ listDOCHD = (ArrayList)objDocHd;
	}else{  listDOCHD = new ArrayList();}
	
	if(objHistory!=null){ listHomeHistoryRepair = (ArrayList)objHistory;
	}else{  listHomeHistoryRepair = new ArrayList();}

 %>


<HEAD>
<TITLE>Service Center History</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">
<!--
  //call dll page number
  function onChangePageNomber() {
   		 document.forms[0].houseNoTxt.value="<%=houseNo%>";
   		 document.forms[0].tel.value="<%=tel%>";
   		 document.forms[0].lockTxt.value="<%=lock%>";
   		 document.forms[0].projectDDL.value="<%=projectSel%>";
   		 document.forms[0].agentId.value="<%=agentId%>";
   		 
   		 document.forms[0].action = "<%=request.getContextPath() %>/SVCHistoryController.do?cmd=formLoad";
		 document.forms[0].submit();  	
  }
  
  //call from  utilizer.genLinkNextPageHTML
  function changePage(nowPage) { 
	 document.forms[0].nowPage.value=nowPage;
	 document.forms[0].houseNoTxt.value="<%=houseNo%>";
   	 document.forms[0].tel.value="<%=tel%>";
   	 document.forms[0].lockTxt.value="<%=lock%>";
   	 document.forms[0].projectDDL.value="<%=projectSel%>";
   	 document.forms[0].agentId.value="<%=agentId%>";
	 
     document.forms[0].action="<%=request.getContextPath() %>/SVCHistoryController.do?cmd=formLoad";
     document.forms[0].submit();
  } 
  
  //call from  utilizer.genLinkNextPageHTML
  function changePage2(nowPage2) { 
	 document.forms[0].nowPage2.value=nowPage2;
	 document.forms[0].houseNoTxt.value="<%=houseNo%>";
   	 document.forms[0].tel.value="<%=tel%>";
   	 document.forms[0].lockTxt.value="<%=lock%>";
   	 document.forms[0].projectDDL.value="<%=projectSel%>";
   	 document.forms[0].agentId.value="<%=agentId%>";
	 
     document.forms[0].action="<%=request.getContextPath() %>/SVCHistoryController.do?cmd=formLoad";
     document.forms[0].submit();
  } 
  
function doPostPoneAdate(docno,type,code,fdate,status){
	try{
	   		//var args = rad_val.split("\\ "); 
	      	//Main Form Reference use sent parameter to servlet
	   	  	window.opener.document.getElementById('docNo').value = docno;
			window.opener.document.getElementById('type').value = type;
			window.opener.document.getElementById('code').value = code;
			window.opener.document.getElementById('fdate').value = fdate;
			window.opener.document.getElementById('fstatus').value = status;

			window.opener.document.forms[0].action="<%=request.getContextPath() %>/SVCHistoryController.do?cmd=chngAppDate";
	    	window.opener.document.forms[0].submit();//main submit form
			window.close();//popup this close
	}catch(e){
      alert(e.message);
      window.close();
   }
}
//-->
</script>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" >

<FORM METHOD="POST" ACTION="">
<input type="hidden" name="nowPage">
<input type="hidden" name="nowPage2">
<input type="hidden" name="houseNoTxt">
<input type="hidden" name="tel">
<input type="hidden" name="lockTxt">
<input type="hidden" name="projectDDL">
<input type="hidden" name="agentId">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;&nbsp;Service Center History</td>
          <td width="50%" align="right">&nbsp;
          </td>
        </tr>
      </table>
<br style="font-size:10pt">

<!-- -------------------------------Block#xx ------------------- -->
<table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1">
                <img border="0" src="images/i_i.gif" align="absmiddle"	width="20" height="20"></td>
                <td class="item_tab2" width="200">ประวัติการติดต่อ (แจ้งผ่าน SVC)</td>
                <td class="item_tab3"></td>
                <td><img src="images/i_arrow1.gif" hspace="5" border="0" align="absmiddle">
                <font class="item">โครงการ : </font><%=projectSel %> | <%=Utilizer.getLableProject(projectList,projectSel) %><font class="item" style="padding-left:30px">แปลง : </font><%=lock %></td>
                <td class="item_tab6i">&nbsp;
			    <font style="color:rgb(0,120,255)">แสดง&nbsp;
			  	<select name="pageNoDDL" id="pageNoDDL" class="box" style="width:45px" onchange="javascript:onChangePageNomber();">
					 <%
					 		Collections.sort(pageList);
							String selected = "";
							for(int i=0;i<pageList.size();i++){
								if(pageList.get(i).toString().equals(displayLine)){
									selected ="selected"; 
								}else{
									selected = "";
								}
								%>
								<option value="<%=pageList.get(i)%>"   <%=selected %>> <%=pageList.get(i)%></option>	
								<%		     	
							}//End 
						     %>
						   </select>รายการ&nbsp;
			    </font>
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
    <td width="100%" class="frmL2">
    		<%--********************************  History Call Recent  **************************--%>
              <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <%--********************************  Header table  **************************--%>
                <tr align="left"> 

                    <td height="22" width="5%" class="col_name02" align="left">เลื่อนวันนัด</td> 
                    <td  height="22" width="5%" class="col_name02" align="left">No.</td>
                    <td  height="22" width="15%" class="col_name02" align="left">วันเวลาที่แจ้ง</td>
				    <td height="22" width="20%" class="col_name02" align="left">เลขที่อ้างอิง</td>
				    <td height="22" width="20%" class="col_name02" align="left">ผู้รับเรื่อง</td>
				    <td height="22" width="20%" class="col_name02" align="left">ชื่อผู้แจ้ง</td>
				    <td height="22" width="25%" class="col_name02" align="left">สถานะ</td>
                </tr>
                <%--********************************  end Header table   **************************
				if(projectDDL!=null && projectDDL.size()>0){
					Iterator it = projectDDL.iterator();
					while(it.hasNext()){	 strList =(ArrayList)it.next();	
    
                --%>
                <%
                System.out.println("listDOCHD.size :"+listDOCHD.size());
                if(listDOCHD!=null && listDOCHD.size()>0){
                	SVC_DOCHD  docdhObj = null;
                	SVC_DOCDT  docdtObj = null;
                	//int loop = 1;
                	int loop = Integer.parseInt(recordNo)+1;
                	//---------------------
                	Iterator itHD = listDOCHD.iterator();
                	Iterator itDT = null;
                	while(itHD.hasNext()){
                		docdhObj = (SVC_DOCHD)itHD.next();
                		%>
	                	<tr> 
	                	    <td class="dotline01 ; item" align="center">&nbsp;</td> 
						    <td  height="22" width="5%" class="dotline01 ; item" align="center"><%=loop %></td>
						    <td  height="22" width="15%" class="dotline01" align="left">&nbsp;<%=Utilizer.toDDMMYY_THAI2(docdhObj.getD_keyin()) %></td>
						    <td height="22" width="20%" class="dotline01" align="left">&nbsp;<%=docdhObj.getI_svc_docno() %></td>
						    <td height="22" width="20%" class="dotline01" align="left">&nbsp;<%=doString.DisplayThai(docdhObj.getEmployName()) %></td>
						    <td height="22" width="20%" class="dotline01" align="left">&nbsp;<%=doString.DisplayThai(docdhObj.getN_customer()) %></td>
						    <td height="22" width="15%" class="dotline02" align="left">&nbsp;
						    <%if(Utilizer.replaceNull(docdhObj.getF_status()).equals("001")){
						    	out.println("บันทึกรายการเรียบร้อยแล้ว");
						    }else if(Utilizer.replaceNull(docdhObj.getF_status()).equals("002")){
						        out.println("อยู่ระหว่างดำเนินการ");
						    }else if(Utilizer.replaceNull(docdhObj.getF_status()).equals("CLS")){
						        out.println("ดำเนินการเรียบร้อยแล้ว");
						    }%></td>
	                  	</tr>
	                   <%--********************************  Header table sub&deatil **************************--%>
		                 <tr>
		                      <td height="22" width="5%" class="dotline01" align="left">&nbsp;</td> 
				               <td  height="22" width="5%" class="dotline01" align="center">&nbsp;</td>
			                    <td  height="22" width="15%" class="dotline01 ; item" align="left">หมวด</td>
								<td height="22" width="20%" class="dotline01 ; item" align="left">รายละเอียด</td>
								<td height="22" width="20%" class="dotline01 ; item" align="left">Start Task</td>
								<td height="22" width="20%" class="dotline01 ; item" align="left">End Task</td>
								 <td height="22" width="15%" class="dotline02 ; item" align="left">สถานะ</td>
						 </tr>
						 <% 
						     itDT = null; //Iterator
						     String dd = "";
						     if(docdhObj.getSvcDocdtList()!=null && docdhObj.getSvcDocdtList().size()>0){
						     	itDT = docdhObj.getSvcDocdtList().iterator();
						     	while(itDT.hasNext()){
                					docdtObj = (SVC_DOCDT)itDT.next();	
                					System.out.println("TEST :"+docdtObj.getD_appoint());	
                					dd = "";
                					if(docdtObj.getD_appoint().length()>10){
                					   dd = docdtObj.getD_appoint().substring(0,10);
                					}
                					%>
                					<tr> 
                					<td height="22" width="5%" class="dotline01" align="left">
                					<%if(Constant.TYPE_01.equals(docdtObj.getI_itmno()) && Utilizer.isDateAvailable(dd)){ %>										 
										 <a href="javascript:doPostPoneAdate('<%=docdtObj.getI_svc_docno()%>','<%=docdtObj.getI_type()%>','<%=docdtObj.getI_itmsub()%>','<%=docdtObj.getD_appoint()%>','<%=docdtObj.getF_status()%>');">
										 <img border="0" src="images/act_ChangeDate.gif" width="100" height="20"></a>										 
                					<%} %>&nbsp;
                					</td> 
				                    <td  height="22" width="5%" class="dotline01" align="center">&nbsp;</td>
			                        <td  height="22" width="15%" class="dotline01">
			                        <img src="images/i_arrow2.gif" width="11" height="11" hspace="3" border="0" align="absmiddle"><%=doString.DisplayThai(docdtObj.getN_desc()) %></td>
							        <td height="22" width="20%" class="dotline01">&nbsp;<%=doString.DisplayThai(docdtObj.getC_detail()) %></td>
								    <td height="22" width="20%" class="dotline01">&nbsp;<%=Utilizer.toDDMMYY_THAI2(docdtObj.getD_start()) %></td>
								    <td height="22" width="20%" class="dotline01">&nbsp;<%=Utilizer.toDDMMYY_THAI2(docdtObj.getD_complete()) %></td>
								    <td height="22" width="15%" class="dotline02">&nbsp;
								   <%if(Utilizer.replaceNull(docdtObj.getF_status()).equals("001")){
								    	out.println("บันทึกรายการเรียบร้อยแล้ว");
								    }else if(Utilizer.replaceNull(docdtObj.getF_status()).equals("002")){
								        out.println("อยู่ระหว่างดำเนินการ");
								    }else if(Utilizer.replaceNull(docdtObj.getF_status()).equals("CLS")){
								    	 out.println("ดำเนินการเรียบร้อยแล้ว");
								    }%>
								    </td>
								 	</tr>
                					<%
                				}//#End itDT
						     }//#End check null&& size  docDT
						 %>
                	     <%		
                	     loop++;
                	}//#End header
                }//#End listDOCHD
                else{
                  %>
                    <tr align="left" > 
                       <td  height="22"  align="center" colspan="7" class="side01" >***ไม่มีข้อมูล***</td>
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

<table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" bgcolor="#E6F5FF">
  <tr>
   <td align="right" style="padding:5px 0px 5px 0px">&nbsp;
    <font color="#800000">หน้า :</font>
     &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  
	<%=displayLinkPage %>&nbsp;&nbsp;
	 </td>
  </tr>
</table>

<!-- -------------------------------End Block#xx ------------------- -->
<br style="font-size:10pt">
<!-- -------------------------------Block#001 ------------------- -->
<table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1">
                <img border="0" src="images/i_i.gif" align="absmiddle"
	width="20" height="20"></td>
                <td class="item_tab2" width="200">ประวัติการแจ้งซ่อม 1 ปีย้อนหลัง (แจ้งซ่อม)</td>
                <td class="item_tab3"></td>
                <td>&nbsp;</td>
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
    <td width="100%" class="frmL" align="center">
              <table border="0" width="100%" cellspacing="0" cellpadding="0">
                <tr>
                    <td  height="22" width="5%" class="col_name">No.</td> 
                    <td  height="22" width="10%" class="col_name">เลขที่ใบแจ้งซ่อม</td>
				    <td height="22" width="5%" class="col_name">แปลง</td>
				    <td height="22" width="10%" class="col_name">บ้านเลขที่</td>
				    <td height="22" width="10%" class="col_name">วันเวลาที่แจ้ง</td>
				    <td height="22" width="15%" class="col_name">ชื่อผู้แจ้ง/ลูกค้า</td>
				     <td height="22" width="15%" class="col_name">โทรศัพท์ติดต่อ</td>
				    <td height="22" width="10%" class="col_name">วันที่ Start Task</td>
				    <td height="22" width="10%" class="col_name">วันที่ Complete</td>
				    <td height="22" width="10%" class="col_name">สถานะ</td>
                </tr>
               <%
                List strList = null;
               	if(listHomeHistoryRepair!=null && listHomeHistoryRepair.size()>0){
               	    int row = Integer.parseInt(recordNo2)+1;
					Iterator it = listHomeHistoryRepair.iterator();
					while(it.hasNext()){							
						strList =(ArrayList)it.next();	
						%>
						<tr> 
					   <td  height="22" width="5%" class="dotline" align="center"><%=row++ %></td> 
	                    <td  height="22" width="10%" class="dotline">&nbsp;<%=strList.get(1) %></td>
					    <td height="22" width="5%" class="dotline">&nbsp;<%=strList.get(2) %></td>
					    <td height="22" width="10%" class="dotline">&nbsp;<%=strList.get(3) %></td>
					    <td height="22" width="10%" class="dotline">&nbsp;<%=strList.get(11) %>&nbsp;<%=strList.get(12) %>&nbsp;น.</td>
					    <td height="22" width="15%" class="dotline">&nbsp;<%=doString.DisplayThai(strList.get(4).toString()) %></td>
					    <td height="22" width="15%" class="dotline">&nbsp;<%=strList.get(5) %></td>
					    <td height="22" width="10%" class="dotline">&nbsp;</td>
					    <td height="22" width="10%" class="dotline">&nbsp;</td>
					    <td height="22" width="10%" class="dotline">&nbsp;<%=strList.get(0) %></td>
	                	</tr>
					<%
					}//#End while				 
               }else{
               	%>
	               	<tr><td colspan="10" class="side01">&nbsp;</td></tr>
	               	<tr><td colspan="10" align="center" class="side01" >&nbsp;--- ไม่มีข้อมูล ---</td></tr>
	               	<tr><td colspan="10" class="side01">&nbsp;</td></tr>
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

<table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" bgcolor="#E6F5FF">
  <tr>
   <td align="right" style="padding:5px 0px 5px 0px">&nbsp;
    <font color="#800000">หน้า :</font>
     &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  
	<%=displayLinkPage2 %>&nbsp;&nbsp;
	 </td>
  </tr>
</table>
<!-- -------------------------------End Block#001 ------------------- -->

<br style="font-size:10pt">
    <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="75" class="act_tab2">
			<!-- button krub 
			 <a href="javascript:doADD();"></a>				
			&nbsp;
			<a href="javascript:doADD();"></a>	
			-->
            </td>
            <td class="act_tab3"></td>
            <td class="act_tab4">&nbsp;
              <a href="javascript:this.close();" target="_top"><img border="0" src="images/bu_close.gif" align="absmiddle" width="50" height="15"></a></td>
          </tr>
        </table>
          </td>
        </tr>
      </table>
</FORM>
</BODY>
</HTML>
