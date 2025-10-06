<%@page language="java" contentType="text/html; charset=TIS-620"
	pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%@ page import="java.text.*" %>
<%@page import="java.util.Date" %>
<%@page import="java.util.Calendar" %>
<%--
/**
 * date : 2016.02.02
 * Modify by : pradoem@lh.co.th
 * change  cause  Y,
 /*For zero_defect  case YES 
 select * from lan:serv_xstd 
 where i_type= '00'  and i_code <=50
 order by i_code */ 
 
 /* New code
For zero_defect case NO
 select * from lan:serv_xstd 
 where i_type= '00'  and i_code >=50
 order by i_code  */
 * ******************************
 * Modify by : pradoem@lh.co.th
 * date : 2012.08.09
 * Last update: 
 2015.03.02 : modify new comment case no zero defect insert field :serv_zerodt.c_desc_no
 2014.05.14
 * version 1.1
 * desc:  add information list to Zero Defect 
 ** 
 */ --%>
<%!	private static String  thaiDateFormate(String tempDate){
	  //IN format :2012-06-28
	  //Out format : 28/06/2555
		if(!tempDate.equals("")){
		  String temp [] = tempDate.split("\\-");
		  return temp[2]+"/"+temp[1]+"/"+(Integer.parseInt(temp[0])+543);
		}else{
			return tempDate;
		}
	}
   private static String ToThaiDateFormat(String date){
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
   private boolean isGuaranteeYear (String dateVaruntee){
        try{
             if(dateVaruntee.equals("")){
                return true;
             }
            Date date = Calendar.getInstance().getTime();
   		  	 // Display a date in day, month, year format//dd/MM/yyyy
   		  	DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
   		  	String today = formatter.format(date);
         	Date varunteeDate = formatter.parse(dateVaruntee);
         	Date currentDate  = formatter.parse(today);
         	if(currentDate.after(varunteeDate)){
         	     return true; //expire date vanruntee
         	}else{
         	     return false; //bettween varuntee Ok.
         	}
         }catch(ParseException ex){
	    	ex.printStackTrace();
	    	return true;// 
	    }
   }
   
   private static String viewOptionHtml(List causeList,String codeVal) {
     StringBuffer buffer = new StringBuffer();
     try{
	     if(causeList!=null && causeList.size()>0){
	     	String sel = "";
			List arrList = null;
			Iterator it = causeList.iterator();
			while(it.hasNext()){
			   arrList = (ArrayList)it.next();
			   sel = "";
			   if(arrList.get(0).equals(codeVal)){
			     sel="selected"; 
			   }
			  buffer.append("<option value='"+arrList.get(0)+"' "+sel+" >")
				    .append(doString.checkString(doString.DisplayThai(arrList.get(1).toString())))
				    .append("</option>");		
		    }
		 }
	 }catch(Exception e){
	    System.out.println("Exception :"+e.toString());
	 }
	 return buffer.toString();
   }
   
 %>
<%
  List  listHD = (ArrayList)request.getAttribute("list");//Header Detail 
  List  resultDt = (ArrayList)session.getAttribute("resultDt"); //defection list
  List  remarkDt = (ArrayList)request.getAttribute("remarkDt"); //remark list
  List  causeYesDDL = (ArrayList)session.getAttribute("causeYesDDL"); //cause ddl
  List  causeNoDDL = (ArrayList)session.getAttribute("causeNoDDL"); //cause ddl
  
  String DIFF_DAY = request.getAttribute("DIFF_DAY")==null?"0":request.getAttribute("DIFF_DAY").toString();//Date diff with d_keyin-d_closelow
  String F_CAN =  request.getAttribute("F_CAN")==null?"":request.getAttribute("F_CAN").toString();//CAN = 'CAN' ,''= Not CAN
  
   int maxLoop = 0;
   if(resultDt!=null && resultDt.size()>0){
      maxLoop = resultDt.size();
   }
  
 %>
<HTML>
<HEAD>
<TITLE>Confirm รายการ Zero Defect</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<style type="text/css" >
.box2 {  font-family: Tohama,Arial,sans-serif; font-size:10.1pt; font-weight:normal;
	padding-top: 1px; padding-right: 1px; padding-bottom: 1px; padding-left: 1px; 
	 color:#165396; background-color: white; border: 1px #BEDCFF solid ; 
}			
</style>

<script language="javascript" src="script_fx.js"></script>

<script type='text/javascript' src='jquery/jquery-1.11.3.min.js'></script>
<script type='text/javascript' src='jquery/loadImg.js'></script>

<script type="text/javascript">
function onValidate(){
	var isChk = false;
    var seq = $("input[name=cnt]").val(); //document.forms[0].cnt.value; 
    var index = 1;
	for(i=1;i<=seq;i++){
	  if($('input:radio[name=rbt'+i+']:checked').length<=0){
	     isChk = true;
	     index = i;
	     break;
	  }
	}
	if(isChk==true){
		alert("กรุณาตรวจสอบรายการเป็น Zero Defect/ไม่เป็น ด้วย.");
		$('input:radio[name=rbt'+index+']').focus();
		return;
	}
	
	/* Mandatory F_CAN 
	 IF F_CAN =TRUE THEN
	 alert force checked rbt = N only
	*/
	var F_CAN = "<%=F_CAN%>";
	//alert(F_CAN);
	//F_CAN = 'CAN';
	var isChkCAN = false;
	if(F_CAN=="CAN"){
	 for(i=1;i<=seq;i++){	
	 	 alert($('input:radio[name=rbt'+i+']')[0]);
		 if($('input:radio[name=rbt'+i+']')[0].checked == true){
		 	isChkCAN = true;
		 	break;
		 }
	  } 
	}	
	if(isChkCAN == true){
		alert("กรุณาเลือก 'N' ทุกรายการ เนื่องจากเลขที่เอกสาร '<%=listHD.get(8)%>' ถูกยกเลิกแล้ว.");
		$('input:radio[name=rbt1]').focus();
		return;
	}
	
	/* Mandatory DropDownList*/
	for(i=1;i<=seq;i++){
	   	if($('select[name=causeDDL'+i+'] option:selected').val()==''){
			alert("กรุณาตรวจสอบรายการ สาเหตุ ด้วย.");
			$('#causeDDL'+i).focus();
			break;
			return;
	   }
	}

	/* Mandatory TextComment*/
	var isTxtComment = false;
	var x = 1;
	for(x=1;x<=seq;x++){
	   	if($.trim($('input[name=txtComment'+x+']').val())==''){
	   		isTxtComment = true;
			break;
	   }
	}
	if(isTxtComment){
	    alert("กรุณาระบุหมายเหตุ ด้วย.");
		$('input[name=txtComment'+x+']').focus();
		return;
	}
	//alert("submit Form");
	doSubmitForm("<%=request.getContextPath()%>/SERV_ZeroDefectServlet?cmd=submit");
}

function doSubmitForm(url){
    //alert("submit");
    onPleaseWait();
 	$('form').attr('action', url);
	$("form:first").submit();
}
</script>
<script>
function onPleaseWait(){
	document.all.pleasewaitScreen.style.pixelTop = (document.body.scrollTop + 120);
	$('#pleasewaitScreen').show();
	setTimeout(function(){  $('#pleasewaitScreen').css("visibility", 'hidden'); }, 7000); //wait 2 seconds
	$('#pleasewaitScreen').css('visibility', 'visible');
 } 
</script>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" >


<!-- ########################################## -->
<DIV ID="pleasewaitScreen" STYLE="position: absolute; z-index: 0; top: 45%; left: 42%; display: none;">
<TABLE BORDER="1" BORDERCOLOR="rgb(180,210,250)" CELLPADDING="0" CELLSPACING="0" 
HEIGHT="125px" WIDTH="265px" ID="Table1">
	<TR>
	<TD BGCOLOR="#FFFFFF" ALIGN="CENTER" VALIGN="MIDDLE" class="test">
	<font color="rgb(255,120,0)"><b>Loading... Please wait</b></font>
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

<FORM name="frm1" id="frm1" METHOD="POST" ACTION="">
<input type="hidden" name="i_docno" value="<%=listHD.get(8)%>">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
&nbsp;Confirm รายการ Zero Defect</td>
          <td width="50%" align="right">&nbsp;
          <!--<a href="#" onclick="viewInform();"><img border="0" src="images/icon_view_IFJ.gif" width="120" height="34"></a>-->
          </td>
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
    <td class="item ; dotline01" height="22" width="13%">โครงการ :</td>
    <td height="22" width="39%" class="dotline01"><%=listHD.get(9)%> <%=listHD.get(10)%> <%=doString.DisplayThai(listHD.get(4).toString()) %>
    </td>
    <td height="22" class="item ; dotline01" width="14%">เลขที่ใบแจ้งซ่อม :</td>
    <td height="22" width="34%" class="dotline01"><%=listHD.get(8)%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">บ้านเลขที่ :</td>
    <td height="22" width="39%" class="dotline01"><%=listHD.get(6)%></td>
    <td height="22" class="item ; dotline01" width="14%">แปลง :</td>
    <td height="22" width="34%" class="dotline01"><%=listHD.get(0)%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">แบบบ้าน :</td>
    <td height="22" width="39%" class="dotline01"><%=listHD.get(5)%></td>
    <td height="22" class="item ; dotline01" width="14%">&nbsp;</td>
    <td height="22" width="34%" class="dotline01">&nbsp;</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ชื่อผู้แจ้ง/ลูกค้า :</td>
    <td height="22" width="39%" class="dotline01">
   &nbsp;<%=doString.DisplayThai(listHD.get(13).toString())%>
    </td>
    <td height="22" class="item ; dotline01" width="14%">โทรศัพท์ติดต่อ :</td>
    <td height="22" width="34%" class="dotline01">
   &nbsp;<%=doString.DisplayThai(listHD.get(14).toString())%>
    </td>
  </tr>
   <tr>
    <td class="item ; dotline01" height="22" width="13%">การประกัน :</td>
    <td height="22" width="39%" class="dotline01">
    &nbsp;<%
          if(isGuaranteeYear(listHD.get(7).toString())){
             out.println("หมดประกัน");
         }else{
             out.println("อยู่ระหว่างประกัน");
          }
       %>
    </td>
    <td height="22" class="item ; dotline01" width="14%">วันที่หมดประกัน :</td>
    <td height="22" width="34%" class="dotline01">
   &nbsp;<%=thaiDateFormate(listHD.get(7).toString())%>
    </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ผู้รับเรื่อง :</td>
    <td height="22" width="39%" class="dotline01"><%=doString.DisplayThai(user.getEmpName())%></td>
    <td height="22" class="item ; dotline01" width="14%">วันเวลาที่แจ้ง :</td>
    <td height="22" width="34%" class="dotline01"><%
    String d = "";
    if(listHD.get(1).toString().length()>10){
       d = listHD.get(1).toString().substring(0,10);
    }%><%=thaiDateFormate(d) %></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">วันที่นัดซ่อม :</td>
    <td height="22" width="39%" class="dotline01"><%=thaiDateFormate(listHD.get(2).toString()) %></td>
    <td height="22" class="item ; dotline01" width="14%">วันที่ประมาณการเสร็จ :</td>
    <td height="22" width="34%" class="dotline01"><%=thaiDateFormate(listHD.get(3).toString()) %></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ผู้รับเหมาสร้าง :</td>
    <td height="22" width="39%" class="dotline01"><%=doString.DisplayThai(listHD.get(12).toString()) %></td>
    <td height="22" class="item ; dotline01" width="14%">โอนมาแล้ว :</td>
    <td height="22" width="34%" class="dotline01">&nbsp;<%=DIFF_DAY %> &nbsp; วัน</td>
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
                <td class="item_tab2" width="200">Zero Defect</td>
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
    <td width="100%" class="frmL">

      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr >
          <td  height="22" rowspan="0" class="col_name" width="2%">No.</td>
          <td  height="22" rowspan="0" class="col_name" width="35%">รายละเอียดการซ่อม</td>
          <td  height="22" rowspan="0" class="col_name" width="20%">ผู้รับเหมา</td>
          <td  height="22" rowspan="0" class="col_name" width="10%">เป็น  ZERO DEFECT/ไม่เป็น</td>
		  <td  height="22" rowspan="0" class="col_name" width="13%">สาเหตุ</td>
		  <td  height="22" rowspan="0" class="col_name" width="20%">หมายเหตุ</td>
        </tr>
        <%
        int cnt = 1;
        int c = 1;
        String fStatus = request.getAttribute("fStatus")==null?"":request.getAttribute("fStatus").toString();
        //System.out.println("-->Fstatus:"+fStatus);
        String fZero = "";
        String strVal = "";
        String  sel = "";
        //*****************************For viewer******************************
        if(fStatus.equals("CLS")){
        	if(resultDt!=null && resultDt.size()>0){
           //a.i_seq,a.i_itmjob,a.i_docno,a.f_remark,b.n_itmjob,a.i_vendor,c.bus_name 
            List  arrList = null;
        	List  strList = new ArrayList();
        	Iterator it = resultDt.iterator();      	
        	 while(it.hasNext()){
        	   strList = (ArrayList)it.next();
        	   strVal  =(String)strList.get(3);
        	   fZero = (String)strList.get(7);//FZero
        	 	%>
        	 	<tr>
		     	<td  align="center" class="dotline"><%=strList.get(0)%></td>
		     	<td  class="dotline">
		     	<%=doString.DisplayThai(strList.get(4).toString()) %>
		     	</td>
		      	<td align="left" class="dotline" >&nbsp;<%=strList.get(5).toString()%> -&nbsp;<%=doString.DisplayThai(strList.get(6).toString()) %></td>
		      	<td align="center" class="dotline" >
					 <input type="radio"  name="rbtView<%=cnt%>" value="Y" 
					 <%if(fZero.equalsIgnoreCase("Y")){out.println("checked");}else{out.println("");} %> disabled="disabled"> Yes
					 <input type="radio" name="rbtView<%=cnt%>" value="N" 
					  <%if(fZero.equalsIgnoreCase("N")){out.println("checked");}else{out.println("");} %> disabled="disabled"> No
			    </td>
		     	 <td align="center" class="dotline">
					     <SELECT name="causeViewDDL<%=cnt%>" class='box2' disabled="disabled">
					     <option value=''>---------------เลือก--------------</option>
					     <%	
					     if(fZero.equalsIgnoreCase("Y")){
							out.println(viewOptionHtml(causeYesDDL,strVal));				     
					     }else  if(fZero.equalsIgnoreCase("N")){
							out.println(viewOptionHtml(causeNoDDL,strVal));								      
					     }       	
					      %>
						</SELECT>				  
				</td>
				<td align="center" class="dotline">
				 <input type="text" name="txtViewComment<%=cnt%>" maxlength="255"  value="<%=doString.DisplayThai(strList.get(8).toString()) %>"  class="box" disabled="disabled" style="width:250px" alt="กรุณาระบุสาเหตุ">  
				</td>
		   		</tr>	
        	 	<%
        	 	cnt++;
        	 } //while List defection
         }//IF DDL
          //*****************************For viewer******************************
        }else{ //CASE F_STATUS =  OPN
         cnt = 1;
         if(resultDt!=null && resultDt.size()>0){
           //a.i_seq,a.i_itmjob,a.i_docno,a.f_remark,b.n_itmjob,a.i_vendor,c.bus_name 
            List  arrList = null;
        	List  strList = new ArrayList();
        	Iterator it = resultDt.iterator();      	
        	 while(it.hasNext()){
        	 	strList = (ArrayList)it.next();
        	 	%>
        	 	<tr>
		     	<td  align="center" class="dotline"><%=strList.get(0)%></td>
		     	<td  class="dotline">
		     	<%=doString.DisplayThai(strList.get(4).toString()) %>
		     	</td>
		      	<td align="left" class="dotline" >&nbsp;<%=strList.get(5).toString()%> -&nbsp;<%=doString.DisplayThai(strList.get(6).toString()) %></td>
		      	<td align="center" class="dotline" >
					 <input type="radio" id="rbtY<%=cnt%>"  name="rbt<%=cnt%>" value="Y" onclick="doDepedentEvent(this,<%=cnt%>)" > Yes
					 <input type="radio" id="rbtN<%=cnt%>"  name="rbt<%=cnt%>" value="N" onclick="doDepedentEvent(this,<%=cnt%>)" > No
		     	</td>
		     	<td align="center" class="dotline">
					     <SELECT name="causeDDL<%=cnt%>" id="causeDDL<%=cnt%>" class='box2' style="width:180px" >
					     	<option value=''>---------------เลือกสาเหตุ--------------</option>
						</SELECT>				  
				</td>
				<td align="center" class="dotline">
					<input type="text" name="txtComment<%=cnt%>" id="txtComment<%=cnt%>" value="" maxlength="255"  class="box"  style="width:250px" alt="กรุณาระบุสาเหตุ">  
				</td>
		   		</tr>	
        	 	<%
        	 	cnt++;
        	 } //while List defection
         }//IF DDL
        }//CLS
         %>
		     <tr>
		          <td align="center" class="dotline">&nbsp;</td>
		           <td class="dotline" >&nbsp;</td>
		          <td class="dotline" >&nbsp;</td>
		          <td align="center" class="dotline">&nbsp;</td>
		          <td align="center" class="dotline" >&nbsp;</td>
		     </tr>
			<tr>
		          <td align="center" class="dotline">&nbsp;</td>
		           <td class="dotline" >&nbsp;</td>
		          <td class="dotline" >&nbsp;</td>
		          <td align="center" class="dotline">&nbsp;</td>
		          <td align="center" class="dotline" >&nbsp;</td>
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
<br style="font-size:4pt">
<table border="0" width="95%" cellspacing="0" cellpadding="0">
<tr><td>&nbsp; </td></tr>
</table>

<br style="font-size:10pt">
<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดการซ่อม</td>
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
				<%
				// b.i_seq,a.c_itmjob,a.i_itmjob_area,c.n_desc
				//System.out.println("--->remarkDt :"+remarkDt.size());
				if(remarkDt!=null && remarkDt.size()>0){
				 	List strList = new ArrayList();
					Iterator it = remarkDt.iterator();
		        	//int i = 1;
		        	 while(it.hasNext()){
		        	 	strList = (ArrayList)it.next();
		        	 	%>
		   				 <tr>
					   	 <td class="item ; dotline01" height="22" width="12%">รายการที่ <%=strList.get(0) %>:</td>
					   	 <td height="22" width="80%" class="dotline01"><%=doString.DisplayThai(strList.get(1).toString()) %></td>
					     <td height="22" width="8%" class="dotline01"><%=doString.DisplayThai(strList.get(3).toString()) %></td>
					 	 </tr>     	 	
		        	 	<%
					}
				}		
				 %>    
				  <tr>
				    <td class="item ; dotline01" height="22" width="12%">&nbsp;</td>
				    <td height="22" width="80%" class="dotline01">&nbsp;</td>
				    <td height="22" width="8%" class="dotline01">&nbsp;</td>
				  </tr>
				
				  <tr>
				    <td class="item ; dotline01" height="22" width="12%">&nbsp;</td>
				    <td height="22" width="80%" class="dotline01">&nbsp;</td>
				    <td height="22" width="8%" class="dotline01">&nbsp;</td>
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
        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="230" class="act_tab2">
		<%
			if(!fStatus.equals("CLS")){ //OPN,"",NULL
		 %>
            <a href="javascript:onValidate();" ><img border="0" src="images/act_submit.gif"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70)" width="70" height="27"></a>&nbsp; 
            <%} %> 	
            </td>
            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="<%=request.getContextPath() %>/SERV_Staff_List.jsp"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=request.getContextPath() %>/SERV_Index.jsp" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
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
<input type ="hidden" name="cnt" value="<%=--cnt %>">
</FORM>
</BODY>
 <script type="text/javascript">
 /* create by : pradoem wonkraso
	 * date time: 2016.01.29
	 * Last modify :
	 * version :1.0
	 * project Name :
	 onChange event of the radio button will calls this function
	 which has AJAX call to Struts Action class
	 @param: dropDownList object (this)
	 @param: URL or Struts Action
	 */
  function doDepedentEvent(obj, seq) {
	if($('input:radio[name=rbt'+seq+']:checked').val() ==""){
	    $('input:radio[name=rbt1]').focus();
		alert("กรุณาเลือก Radio button ด้วย!!");
        return;
	}else{
        $.ajax({
                 type: "GET",
                 url: "SERV_ZeroDefectServlet?cmd=chg",
                 data: {causeCode:  $('input:radio[name=rbt'+seq+']:checked').val()},
                 success: function(data){
                    $("#causeDDL"+seq).html(data);
                 }
         });
	}	
 }//End
 
 /*$("input").on("click", function() {
  //$( "#log" ).html( $( "input:checked" ).val() + " is checked!" );
    $.ajax({
	      type: "GET",
	      url: "SERV_ZeroDefectServlet?cmd=test",
	      data: {reasonCode:  $('input:radio[name=rbt1]:checked').val()},
	      success: function(data){
	          alert(data);
	          $("#log").html(data);
	      },
		    error: function (xhr, data) {
		    alert(data);
		    alert(xhr.status);
	 }
   });
});*/

</script>
</HTML>
