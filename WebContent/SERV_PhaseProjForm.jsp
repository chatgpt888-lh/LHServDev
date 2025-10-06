<%@ page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page errorPage="errorPage.jsp" %>

<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ include file="function.jsp" %>
<%@ include file="confirmLogin.jsp" %>

<%!
	public static String[] collectMethod = new String[]{
		"รูปแบบการจัดเก็บไม่ถูกต้อง !!", "โครงการเก่า", "กทม.", "ปริมณฑล", "กทม. 3 ปี ไม่มีสโมสร", "ปริมณฑล  3 ปี และ กทม. 3 ปี"
	};	
			
	public String displayDate(String date) {
		String result = "";
		
		if (date.trim().length()>=10) {
			if (date.indexOf("-")==4 || date.indexOf("/")==4) {
				int y = Integer.parseInt(date.substring(0,4));
				if (y<2400) y += 543;
				result = date.substring(8,10)+"/"+date.substring(5,7)+"/"+y;
			} else {
				result = date;
			}
		} else {
			result = "-";
		}
		
		return result;
	}		
%>

<%
	String selProj = doString.checkString(request.getParameter("sel_project"),"");
	String iCompany = selProj.length()>=6 ? selProj.substring(0,2) : "";
	String iProject = selProj.length()>=6 ? selProj.substring(3,6) : "";		
	String iPhase = doString.checkString(request.getParameter("i_phase"),"");
	String act = doString.checkString(request.getParameter("act"),"");	
	String error = doString.checkString(request.getParameter("error"),"");	
	String errMsg = doString.checkString(request.getParameter("other_msg"),"");		
	boolean endPhase = false;	

	String fProject = doString.checkString(request.getParameter("f_project"),"");
	String fExtra = doString.checkString(request.getParameter("f_extra"),"N");
	String dEndProj = doString.checkString(request.getParameter("d_end_project"),"");
	double zClub = Double.parseDouble(doString.checkString(request.getParameter("z_club"),"0.00"));
	double newPrice = Double.parseDouble(doString.checkString(request.getParameter("new_price"),"0.00"));

	
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	
	try {
		if (ds == null)
		{
			getDS();
		}
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();
	
	
		//----- find n_project -------//
		String nProject = "";
		sql.delete(0,sql.length());
		sql.append(" select * from lan:acxprojt ")
		   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ");
		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
			nProject = doString.checkString(rs.getString("n_project"),"");
		} 
		rs.close();	
		
		
		//----- find lastest phase -----//
		int lastPhase = 0;
		String lastDPublic = "";
		String lastDEndProj = "";
		sql.delete(0,sql.length());
	    sql.append(" select lpad(trim(nvl(h.i_phase,'')), 3, '0') as last_phase, d.d_public, d.z_price, h.* ")
	       .append(" from lan:acspubhd h,lan:acspubdt d ")
	       .append(" where h.i_company='"+iCompany+"' and h.i_project='"+iProject+"' ")
	       .append(" and d.i_company=h.i_company and d.i_project=h.i_project and h.i_phase=d.i_phase ")
	       .append(" and d.d_public in (select max(d_public) from lan:acspubdt d2 where d2.i_company=d.i_company and d2.i_project=d.i_project and d2.i_phase=d.i_phase) ")
	       .append(" order by 1 desc ");
		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
			lastPhase = rs.getInt("i_phase");
			lastDPublic = displayDate(doString.checkString(rs.getString("d_public"),""));
			lastDEndProj = displayDate(doString.checkString(rs.getString("d_end_project"),""));
			newPrice = rs.getDouble("z_price");
		} 
		rs.close();	
		
		
		//--- count lock used ---//
		int cntLockUsed = 0;
		sql.delete(0,sql.length());
		sql.append(" select count(*) as cnt from lan:acxslock ")
		   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
		   .append(" and i_phase='"+iPhase+"' and i_lor is not null ");
		rs = stmt.executeQuery(sql.toString());		
		if (rs.next()) {
			cntLockUsed = rs.getInt("cnt");
		}
		rs.close();					
		
		if (act.equalsIgnoreCase("END")) {
			act = "VIEW";
			endPhase = true;
		}
		
		//----- find data when first load -------//
		if (act.equalsIgnoreCase("LOAD") || act.equalsIgnoreCase("VIEW") || act.equalsIgnoreCase("ADD_PRICE")) {
			sql.delete(0,sql.length());
			sql.append(" select * from lan:acspubhd ")
			   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
			   .append(" and i_phase='"+iPhase+"' ");
			rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
				fProject = doString.checkString(rs.getString("f_project"),"");
				fExtra = doString.checkString(rs.getString("f_extra"),"");
				zClub = rs.getDouble("z_club");
				dEndProj = displayDate(doString.checkString(rs.getString("d_end_project"),""));
			} 
			rs.close();
			
			//--- reset load to edit mode instead ---//
			if (!act.equalsIgnoreCase("VIEW") && cntLockUsed<=0) {
				act = "EDIT";
			} else {
				act = "VIEW";
			}
		}	
%>

<HTML>
<HEAD>
<TITLE>ตั้งข้อมูลพื้นฐาน เฟสโครงการ (C0)</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="MainStyle.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript" type="text/javascript" src="chromeless_35.js"></script>
<script language="javascript" type="text/javascript" src="window_style.js"></script>
<script language="javascript" type="text/javascript" src="Hscroll.js"></script>
<script language="javascript" type="text/javascript" src='scw.js'></script>

<base target="_self">

<script language="JavaScript">
<!--

	function isDate(val) {
		var str="0123456789/";
		var valOK = true;
		var i=0;
		for (i=0; i<val.length & valOK; i++) {
			valOK = (str.indexOf(val.charAt(i))!= -1);
		}
		if (!valOK) {
			return false;
		}
		return true;
	}
	
	function Trim(x) {
		return x.replace(/^\s+|\s+$/gm,'');
	}	

	function setDate(id) {
		var objDate = document.getElementById(id);
		var valueDate = "";
		var year = 0;
		if (objDate != null) {
			valueDate = Trim(objDate.value);
			if (valueDate != "") {
				year = parseInt(valueDate.substring(6), 10)+543;
				if (year <= 2599) {
					valueDate = valueDate.substring(0,6) + year;
					objDate.value = valueDate;
					objDate.focus();
				}
			}
		}
	}

	function checkDate(obj, keycode) {
		var charValue = Trim(String.fromCharCode(keycode));
		if (isDate(charValue)) {
			return(true);	
		} else {
			return(false);
		}
	}

	function isValidateDate(id) {
		var objDate = document.getElementById(id);
		var strDate = Trim(objDate.value);
		var valid = false;
		if (strDate != "") {
			if (isDate(strDate)) {
				if (strDate.length == 10) {
					valid = convertDateFormat(objDate);
				}
			}
		} else {
			valid = true;
		}
		
		if (!valid) {
			objDate.value = "";
		}
	}

	function collectdate(txtBox) {
		var vWinCal = window.open('calendar2.jsp?dateType='+txtBox,'owner','width=310, height=250, status=no, resizable=no, top=80, left=140');
		vWinCal.opener = self;
		ggWinCal = vWinCal;	
	}

	function compareDate(start,startLabel,end,endLabel) {
	 if (start.length>=10 && end.length>=10) {
		 startDate = start.substring(6,10)+start.substring(3,5)+start.substring(0,2);
		 endDate = end.substring(6,10)+end.substring(3,5)+end.substring(0,2);
	
		 if (startDate<=endDate) {
			 alert(startLabel+"ต้องมากกว่า"+endLabel+" !!");
			 return false;
		 }
	 } else {
	 	if (start.length<=0 || end.length<=0) {
	 		alert(" กรุณากรอก"+startLabel+"และ"+endLabel+" !!");
	 		return false;
	 	}	 
	 }
	
	 return true;
	}  
	
	function setType(val) {
		var options = document.forms[0].f_extra.options;
		if (options!=null && options.length>0) {
			var price = document.getElementById("price_type");
			var club = document.getElementById("club_type");
			if (price!=null && club!=null) {
				for (var i=0;i<options.length;i++) {
					if (options[i].value==val) {
						price.innerHTML = options[i].text;
						club.innerHTML = options[i].text;
						break;
					}
				} // end for
			}
		}
	}	

	function saveData() {
		var chkForm = document.forms[0];

		if (chkForm.d_end_project.value=="") {
			alert(" กรุณาระบุวันที่สิ้นสุดโครงการ !!");
			chkForm.d_end_project.focus();
			return false;
		}			
		
		var tmpChk = chkForm.new_price.value;
		if (tmpChk=="" || isNaN(tmpChk) || tmpChk-0<=0.0) {
			alert(" กรุณาระบุค่าสาธารณูปโภค !!");
			chkForm.new_price.focus();
			return false;
		}			

		tmpChk = chkForm.z_club.value;
		if (tmpChk=="" || isNaN(tmpChk) || tmpChk-0<0.0) {
			alert(" กรุณาระบุค่าค่าใช้จ่ายบริหารสโมสร !!");
			chkForm.z_club.focus();
			return false;
		}
		
		var currDate = new Date();
		var year = currDate.getYear()-0;
		if (year<1000) year += 1900;
		if (year<2400) year += 543;
		today = (currDate.getDate()<10 ? "0"+currDate.getDate() : ""+currDate.getDate()); // dd
		today = today+"/"+(currDate.getMonth()+1<10 ? "0"+(currDate.getMonth()+1) : ""+(currDate.getMonth()+1)); // mm
		today = today+"/"+year; // yyyy

		if (!compareDate(chkForm.d_end_project.value,"วันที่สิ้นสุดโครงการ",today,"วันที่ปัจจุบัน")) {
			return false;
		}	
		
		if (!compareDate(chkForm.d_end_project.value,"วันที่สิ้นสุดโครงการ",'<%=displayDate(lastDPublic) %>',"วันที่กำหนดราคาปัจจุบัน (<%=displayDate(lastDPublic) %>)")) {
			return false;
		}	
				
		document.forms[0].act.value = "EDIT";		
		document.forms[0].action="/LHServ/SERV_SavePhaseProjServlet";
		document.forms[0].submit();
	}
	
	function addPrice() {
		var chkForm = document.forms[0];
		
		if (chkForm.new_public.value=="") {
			alert(" กรุณาระบุวันที่กำหนดราคาใหม่ !!");
			chkForm.new_public.focus();
			return false;
		}
		
		var tmpChk = chkForm.new_price.value;
		if (tmpChk=="" || isNaN(tmpChk) || tmpChk-0<0.0) {
			alert(" กรุณาระบุค่าสาธารณูปโภคใหม่ !!");
			chkForm.new_price.focus();
			return false;
		}		
		
		if (!compareDate(chkForm.new_public.value,"วันที่กำหนดราคาใหม่",'<%=displayDate(lastDPublic) %>',"วันที่กำหนดราคาเดิม (<%=displayDate(lastDPublic) %>)")) {
			return false;
		}	
		
		if (!compareDate(chkForm.d_end_project.value,"วันที่สิ้นสุดโครงการ (<%=displayDate(lastDEndProj) %>) ",chkForm.new_public.value,"วันที่กำหนดราคาใหม่")) {
			return false;
		}						
			
		document.forms[0].act.value = "ADD_PRICE";
		document.forms[0].action="/LHServ/SERV_SavePhaseProjServlet";
		document.forms[0].submit();		
	}
	
//-->
</script>
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM method="POST" action="">

<input type="hidden" name="act" id="act" value="<%=act %>">
<input type="hidden" name="sel_project" id="sel_project" value="<%=selProj %>">

<input type="hidden" name="last_phase" id="last_phase" value="<%=lastPhase %>">
<input type="hidden" name="last_d_public" id="last_d_public" value="<%=lastDPublic %>">
<input type="hidden" name="last_d_end_proj" id="last_d_end_proj" value="<%=lastDEndProj %>">

<TABLE border="0" width="100%" cellpadding="0" cellspacing="0">
<TBODY>
<TR>
<TD valign="top" width="800">

<!-- Start insert your HTML body here -->

<table border="0" width="780" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center">
    
                    <br style="font-size:8pt">
    

      <table border="0" width="750" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
           ตั้งข้อมูลพื้นฐาน เฟสโครงการ (C0)</td>
          <td width="50%" align="right">
                  
			<div id="SubMenu">
			<table border="0" width="300" cellspacing="1" cellpadding="0">
			  <tr>
				<td width="70%" class="submenu">&nbsp;</td>
				<td width="30%" class="submenu">&nbsp;</td>
			  </tr>
			  <tr>
				<td width="70%">&nbsp;</td>
				<td width="30%">&nbsp;</td>
			</tr>
			</table>
			</div>
                  
          </td>
        </tr>
      </table>

<br style="font-size:1pt">





<table border="0" width="750" cellspacing="0" cellpadding="0">
  <tr>
	<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
	<td class="item_tab2" width="200">รายละเอียดเฟส</td>
	<td class="item_tab3"></td>
	<td class="item_tab4">&nbsp;</td>
	<td class="item_tab5"></td>
  </tr>
</table>
   <br style="font-size:3pt">

	<table border="0" width="750" cellspacing="1" cellpadding="1">
	  <tr class="gray">
		<td  width="120" class="item"><nobr>โครงการ :</nobr></td>
		<td><%=iCompany+iProject+" | "+doString.DisplayThai(nProject) %></td>
      </tr>	  	
	  <tr>
		<td  width="120" class="item"><nobr>เฟส :</nobr></td>
		<td><input type="hidden" name="i_phase" id="i_phase" value="<%=iPhase %>"><%=iPhase %></td>
	  </tr>
	  <tr class="gray">
		<td  width="120" class="item"><nobr>ประเภทโครงการ :</nobr></td>
		<td>
		<input type="hidden" name="f_project" id="f_project" value="<%=fProject %>"><%=collectMethod[Integer.parseInt(fProject)]  %>
		</td>
	  </tr>	  
	  <tr>
		<td  width="120" class="item"><nobr>ประเภทการจัดเก็บ :</nobr></td>
		<td>
		<input type="hidden" name="f_extra" id="f_extra" value="<%=fExtra %>"><%=(fExtra.equals("N") ? "บาท / ตรว." : "บาท / หลัง")  %>
		</td>
      </tr>	  	      										
	  <tr class="gray">
		<td  width="120" class="item"><nobr>วันที่สิ้นสุดโครงการ :</nobr></td>
		<td>
		<%
			if (act.equalsIgnoreCase("VIEW")) {
				%>
				<input type="hidden" name="d_end_project" id="d_end_project" value="<%=dEndProj %>"><%=dEndProj  %>
				<%
			} else {
				%>
		        <input name="d_end_project" id="d_end_project" type="text" class="boxC" style="width:80px;" value="<%=dEndProj %>"> &nbsp;
		        <a href="javascript:collectdate('d_end_project')"><img src="images/i_calendar.gif" width="18" height="18" 
		        align="absmiddle" style="cursor:hand" alt="วันที่สิ้นสุดโครงการ" border="0"></a>						
				<%
			}
		%>		
		</td>
      </tr>	     
	  <tr>
		<td  width="120" class="item"><nobr>ค่าบริการสาธารณะ :</nobr></td>
		<td>
		<%
			/****
			if (act.equalsIgnoreCase("VIEW")) {
				%>
				<input type="hidden" name="new_price" id="new_price" value="<%=doString.displayNumber("######0.00",newPrice) %>"><%=doString.displayNumber("#,###,##0.00",newPrice) %>
				 &nbsp; <span id="price_type" style="color:red"><%=(fExtra.equals("N") ? "บาท / ตรว." : "บาท / หลัง")  %></span>			
				<%
			} else {
				%>
				<input type="text" class="boxR" name="new_price" style="width:80px;" id="new_price" value="<%=doString.displayNumber("######0.00",newPrice) %>">
				 &nbsp; <span id="price_type" style="color:red"><%=(fExtra.equals("N") ? "บาท / ตรว." : "บาท / หลัง")  %></span>			
				<%
			}
			****/
			
			//---- display only , no edit z_price ----//	
		%>				
  		 <input type="hidden" name="new_price" id="new_price" value="<%=doString.displayNumber("######0.00",newPrice) %>"><%=doString.displayNumber("#,###,##0.00",newPrice) %>
		 &nbsp; <span id="price_type" style="color:red"><%=(fExtra.equals("N") ? "บาท / ตรว." : "บาท / หลัง")  %></span>					
		</td>
      </tr>	       		    		      			      		     		
	  <tr>
		<td  width="120" class="item"><nobr>ค่าสาธารณูปโภค :</nobr></td>
		<td>
		<%
			if (act.equalsIgnoreCase("VIEW")) {
				%>
				<input type="hidden" name="z_club" id="z_club" value="<%=doString.displayNumber("######0.00",zClub) %>"><%=doString.displayNumber("#,###,##0.00",zClub) %>
				 &nbsp; <span id="club_type" style="color:red"><%=(fExtra.equals("N") ? "บาท / ตรว." : "บาท / หลัง")  %></span>			
				<%
			} else {
				%>
				<input type="text" class="boxR" name="z_club" style="width:80px;" id="z_club" value="<%=doString.displayNumber("######0.00",zClub) %>">
				 &nbsp; <span id="club_type" style="color:red"><%=(fExtra.equals("N") ? "บาท / ตรว." : "บาท / หลัง")  %></span>			
				<%
			}
		%>				
		</td>
      </tr>								      	          
	</table>	
				
	<%
		if (!act.equalsIgnoreCase("VIEW")) {
			%>
			<br style="font-size:5pt">			
			<table border="0" width="750" cellspacing="0" cellpadding="0" height="30">
			  <tr>
				<td class="act_tab1"></td>
				<td width="75" class="act_tab2">
		
						<IMG border="0" src="images/act_save.gif" 
						onmouseout="nereidFade(this,70,50,5)" 
						onmouseover="nereidFade(this,100,50,5)" 
						onclick="saveData()"
						style="FILTER: alpha(opacity=70); cursor:hand" width="70" height="27">				
				&nbsp;
				</td>   
				<td class="act_tab3">&nbsp;</td>   
				<td class="act_tab4"><a href="SERV_PhaseProjList.jsp?sel_project=<%=selProj %>">
				<img border="0" src="images/bu_back.gif" width="50" height="15"></a>
				<a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" width="50" height="15"></a>
				</td>  
			  </tr>  
			</table>  
			<%
		}
	%>	
	
<br style="font-size:5pt">
<table border="0" width="750" cellspacing="0" cellpadding="0">
<tr><td><b style="color:red; font-size:14px">* หน้าจอนี้เป็นการตั้งเฟสค่าบริการสาธารณะสำหรับใช้คำนวนงวด C0</b></td></tr>
</table>   
<br style="font-size:5pt">	
	
<!------- details block -------->		
<br style="font-size:10pt">

	<table border="0" width="750" cellspacing="0" cellpadding="0">
		<tr>
			<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
			<td class="item_tab2" width="200"><nobr>รายละเอียดการกำหนดราคา</nobr></td>
			<td class="item_tab3"></td>
			<td class="item_tab4">&nbsp;</td>
			<td class="item_tab5" width="25">&nbsp;</td>
		</tr>
	</table>

<table border="0" width="750" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL" align="center">
    
    
<table border="0" width="100%" cellspacing="0" cellpadding="0">
   <tr style="height:20px">
    <td width="40%" class="col_name2" align="center" valign="middle">วันที่กำหนดราคา</td>
    <td width="40%" class="col_name2" align="center" valign="middle">ค่าบริการสาธารณะ</td>
    <td width="20%" class="col_name2" align="center" valign="middle">&nbsp;</td>
  </tr>
  <%
	String dpublic = "";
	double zprice = 0.0;
	String bgColor = "";
	int cnt = 0;
	
    sql.delete(0,sql.length());
    sql.append(" select * from lan:acspubdt ")
       .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
       .append(" and i_phase='"+iPhase+"' ")
       .append(" order by d_public ");
	rs = stmt.executeQuery(sql.toString());
	while (rs.next()) {
		iPhase = doString.checkString(rs.getString("i_phase"),"");			
		dpublic = displayDate(doString.checkString(rs.getString("d_public"),""));
		zprice = rs.getDouble("z_price");	
		cnt++;	
		
		bgColor = "col_center";
		if (cnt%2==1) {
			bgColor += " ; gray";		
		}
			
		%>
		<tr class="<%=bgColor %>" style="height:21px">
			<td class="dotline" align="center">&nbsp;<%=dpublic %></td>
			<td class="dotline" align="right"><%=doString.displayNumber("#,###,##0.00",zprice) %>
			&nbsp; <span style="color:red"> บาท / <%=(fExtra.equalsIgnoreCase("Y") ? "หลัง" : "ตรว.") %></span> &nbsp;
			</td>	
			<td>&nbsp;</td>	
		</tr>							
		<%			
	} // end while
	rs.close();
	
	if (cnt<=0) {
		//--- no phase in lan:acxslock ---//
		%>
		  <tr style="height:21px">
			<td  colspan="3" class="dotline" align="center">&nbsp;<span style='color:red'>ไม่พบข้อมูลการกำหนดราคา</span></td>			
		  </tr>					
		<%
	}

	/*
	*  cancel this add method
	*
	if (!endPhase) {
		%>
		<tr class="col_name2" style="height:21px">
			<td class="dotline" align="center">
	        <input name="new_public" id="new_public" type="text" class="boxC" style="width:80px;" value=""> &nbsp;
	        <a href="javascript:collectdate('new_public')"><img src="images/i_calendar.gif" width="18" height="18" 
	        align="absmiddle" style="cursor:hand" alt="วันที่กำหนดราคาใหม่" border="0"></a>				
			</td>
			<td class="dotline" align="right">
			<input type="text" class="boxR" name="new_price" id="new_price" style="width:80px;" value="0.00">
			 &nbsp; <span style="color:red"><%=(fExtra.equals("N") ? "บาท / ตรว." : "บาท / หลัง")  %></span>	
			</td>	
			<td>&nbsp;<a href="javascript:addPrice();"><img src="images/bu_add.gif"></a></td>	
		</tr>			
		<%
	}
	*/
  %>		
</table>    
    
    
    </td>
  </tr>  
</table>

<table border="0" width="750" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>	

<br style="font-size:10pt">

<!------- details block -------->	

	  </td>
	</tr>

    </table>

<!-- End insert your HTML body  -->

</TD>
</TR>
</TABLE>
			
			<!-- Start insert your HTML footer here -->			
			
<table border="0" width="780" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center">

<br style="font-size:20pt">

<TABLE border=0 cellspacing=0 cellpadding=0 width="600">
  <tr><td width="100%" class="copyright" align="center">
  Best Viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5  
  <br>ติชมแสดงความคิดเห็น : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a> &nbsp;หรือ Computer Department&nbsp; โทร 2308490-98,2308451-3  
  <br><img src="images/copyright.gif" width="510" height="28"></td></tr>
</TABLE> 

    </td>
  </tr>
</table>	


</FORM>      

<%
		if (error.length()>0) {
			if (errMsg.trim().length()>0) {
				errMsg = "\\n\\n"+errMsg;
			}
			%><script>alert('พบข้อผิดพลาดในการจัดเก็บข้อมูล, กรุณาติดต่อฝ่าย IT !!<%=errMsg %>');</script><%
		}


		stmt.close();
		conn.close();
		conn = null;
	}
	catch (Exception e) {
		System.out.println("!!!ERROR SERV_PhaseProjForm.jsp : " + e.getMessage());
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

</BODY>
</HTML>