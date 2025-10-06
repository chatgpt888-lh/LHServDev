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
	String error = doString.checkString(request.getParameter("error"),"");	
	String errMsg = doString.checkString(request.getParameter("other_msg"),"");			

	String fProject = doString.checkString(request.getParameter("f_project"),"");
	String fExtra = doString.checkString(request.getParameter("f_extra"),"N");
	String dEndProj = doString.checkString(request.getParameter("d_end_project"),"");
	String dPublic = doString.checkString(request.getParameter("d_public"),"");
	double zPrice = Double.parseDouble(doString.checkString(request.getParameter("z_price"),"0.00"));
	double zClub = Double.parseDouble(doString.checkString(request.getParameter("z_club"),"0.00"));

	
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	doString str = new doString();
	
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
		String lastFProject = "";
		String lastFExtra = "";
		double lastPrice = 0.0;
		double lastClub = 0.0;
		boolean foundLastPhase = false;
		
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
			lastPrice = rs.getDouble("z_price");
			lastClub = rs.getDouble("z_club");
			lastFProject = doString.checkString(rs.getString("f_project"),"");
			lastFExtra = doString.checkString(rs.getString("f_extra"),"");
			lastDPublic = displayDate(doString.checkString(rs.getString("d_public"),""));
			lastDEndProj = displayDate(doString.checkString(rs.getString("d_end_project"),""));
			foundLastPhase = true;
		} 
		rs.close();	
		
		
		//--- default phase ---//
		if (iPhase.trim().length()<=0 && fProject.trim().length()<=0 && zPrice<=0 && zClub<=0) {
			iPhase = Integer.toString(lastPhase+1);
			fProject = lastFProject;
			fExtra = doString.checkString(lastFExtra,"N");
			zPrice = lastPrice;
			zClub = lastClub;
		}
		
		
		//---- always fixed d_public as today ----//
		Calendar now = Calendar.getInstance(TimeZone.getTimeZone("Asia/Bangkok"));
		int y = now.get(Calendar.YEAR);
		if (y<2400) y += 543;
		dPublic = str.createID(now.get(Calendar.DATE),2)+"/"+str.createID(now.get(Calendar.MONTH)+1,2)+"/"+y;
		
		
		//---- get default z_price from ADM ----//
		String admInfType = "";
		double admInfRate = 0.0;
		boolean foundAdmRate = false;
		
		sql.delete(0,sql.length());
		sql.append(" select h.d_allocate, r.z_inf_rate, r.i_type ")
		   .append(" from lan:aciplckd d, lan:aciplckh h, lan:aciinfrate r ")
		   .append(" where d.i_company = '"+iCompany+"' and d.i_project = '"+iProject+"' ")
		   .append(" and (d.f_cancel!='C' or d.f_cancel is null) ")
		   .append(" and d.seq_no = h.seq_no and h.f_confirm='Y' ")
		   .append(" and h.d_allocate is not null and h.seq_no=r.seq_no ")
		   .append(" order by h.d_allocate desc ");
		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
			admInfType = doString.checkString(rs.getString("i_type"),""); 
			admInfRate = rs.getDouble("z_inf_rate");
			foundAdmRate = true;
		}
		rs.close();
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
	
		if (chkForm.i_phase.value=="") {
			alert(" กรุณาระบุเฟส !!");
			chkForm.i_phase.focus();
			return false;
		}
		
		if (chkForm.f_project.value=="") {
			alert(" กรุณาระบุประเภทโครงการ !!");
			chkForm.f_project.focus();
			return false;
		}			

		if (chkForm.f_extra.value=="") {
			alert(" กรุณาระบุประเภทการจัดเก็บ !!");
			chkForm.f_extra.focus();
			return false;
		}	
				
		if (chkForm.d_end_project.value=="") {
			alert(" กรุณาระบุวันที่สิ้นสุดโครงการ !!");
			chkForm.d_end_project.focus();
			return false;
		}	
				
		/*
		if (chkForm.d_public.value=="") {
			alert(" กรุณาระบุวันที่กำหนดราคา !!");
			chkForm.d_public.focus();
			return false;
		}
		*/
		
		var tmpChk = chkForm.z_price.value;
		if (tmpChk=="" || isNaN(tmpChk) || tmpChk-0<=0.0) {
			alert(" กรุณาระบุค่าสาธารณูปโภค !!");
			chkForm.z_price.focus();
			return false;
		}
		
		//---- re-check with adm input -----//
		<%
			if (foundAdmRate) {
				//--- adm input rate , compare it ---//
				%>
				var tmpAdmRate = chkForm.default_adm_rate.value;
				var tmpAdmType = chkForm.default_adm_type.value;
				
				if (tmpAdmRate-0==0.0 || tmpAdmType=="") {
					alert("ไม่พบข้อมูลจากทางฝั่งอำนวยการ, กรุณาติดต่อฝ่ายอำนวยการเพื่อบันทึกข้อมูล !!");			
					return false;				
				} else {
					if (tmpAdmRate-0!=tmpChk-0) {
						alert("อัตราค่าบริการสาธารณะไม่ตรงกับข้อมูลฝั่งอำนวยการ, กรุณาตรวจสอบ !!");
						chkForm.z_price.focus();
						return false;				
					}
					
					if (tmpAdmType=="V") {
						if (chkForm.f_extra.value!="N") {
							alert("ประเภทการจัดเก็บไม่ตรงกับข้อมูลฝั่งอำนวยการ, กรุณาตรวจสอบ !!");
							chkForm.f_extra.focus();
							return false;				
						}
					} else if (tmpAdmType=="L") {
						if (chkForm.f_extra.value!="Y") {
							alert("ประเภทการจัดเก็บไม่ตรงกับข้อมูลฝั่งอำนวยการ, กรุณาตรวจสอบ !!");
							chkForm.f_extra.focus();
							return false;				
						}
					} 			
				}				
				<%
			} else if (!foundAdmRate && foundLastPhase) {
				//--- no adm input but found old phase , no validate ---//
			} else {
				//--- no adm input and no old phase , error and not save ---//
				%>
				alert("ไม่พบข้อมูลจากทางฝั่งอำนวยการ, กรุณาติดต่อฝ่ายอำนวยการเพื่อบันทึกข้อมูล !!");			
				return false;					
				<%
			}
		%>
		//----------------------------------//		
		
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
					
		//if (!compareDate(chkForm.d_end_project.value,"วันที่สิ้นสุดโครงการ",chkForm.d_public.value,"วันที่กำหนดราคา")) {
		//	return false;
		//}	
			
		document.forms[0].action="/LHServ/SERV_SavePhaseProjServlet";
		document.forms[0].submit();
	}
	
//-->
</script>
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM method="POST" action="">

<input type="hidden" name="act" id="act" value="ADD">
<input type="hidden" name="sel_project" id="sel_project" value="<%=selProj %>">

<input type="hidden" name="last_phase" id="last_phase" value="<%=lastPhase %>">
<input type="hidden" name="last_d_public" id="last_d_public" value="<%=lastDPublic %>">
<input type="hidden" name="last_d_end_proj" id="last_d_end_proj" value="<%=lastDEndProj %>">

<input type="hidden" name="default_adm_rate" id="default_adm_rate" value="<%=admInfRate %>">
<input type="hidden" name="default_adm_type" id="default_adm_type" value="<%=admInfType %>">

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
		<td>
		<input type="text" class="box" style="width:40px" maxlength="2" name="i_phase" id="i_phase" value="<%=iPhase %>">
		&nbsp; &nbsp;<%=lastPhase>0 ? "(เฟสปัจจุบันคือ "+lastPhase+")" : "ไม่พบข้อมูลเฟสก่อนหน้า" %>		
		</td>
	  </tr>
	  <tr class="gray">
		<td  width="120" class="item"><nobr>ประเภทโครงการ :</nobr></td>
		<td>
		<select name="f_project" id="f_project" class="box" style="width:180px">
		<option value="">--- กรุณาเลือก ---</option>
		<%
			String sel = "";
			for (int i=1;i<collectMethod.length;i++) {
				sel = "";
				if (fProject.equals(Integer.toString(i))) {
					sel = "selected";
				}
			
				%><option value="<%=i %>" <%=sel %>><%="["+i+"] - "+collectMethod[i] %></option><%
			} // end for
		%>
		</select>
		</td>
	  </tr>	      	
	  <tr>
		<td  width="120" class="item"><nobr>ประเภทการจัดเก็บ :</nobr></td>
		<td>
		<select name="f_extra" id="f_extra" class="box" style="width:80px" onchange="setType(this.value);">
			<option value="N" <%=(fExtra.equals("N") ? "selected" : "") %>>บาท / ตรว.</option>
			<option value="Y" <%=(fExtra.equals("Y") ? "selected" : "") %>>บาท / หลัง</option>
		</select>
		</td>
      </tr>		  									
	  <tr class="gray">
		<td  width="120" class="item"><nobr>วันที่สิ้นสุดโครงการ :</nobr></td>
		<td>
        <input name="d_end_project" id="d_end_project" type="text" class="boxC" style="width:80px;" value="<%=dEndProj %>"> &nbsp;
        <a href="javascript:collectdate('d_end_project')"><img src="images/i_calendar.gif" width="18" height="18" 
        align="absmiddle" style="cursor:hand" alt="วันที่สิ้นสุดโครงการ" border="0"></a>		
		</td>
      </tr>	  
      <!-- 
	  <tr>
		<td  width="120" class="item"><nobr>วันที่กำหนดราคา :</nobr></td>
		<td>	
        <input name="d_public" id="d_public" type="text" class="boxC" style="width:80px;" value="<%=dPublic %>"> &nbsp;
        <a href="javascript:collectdate('d_public')"><img src="images/i_calendar.gif" width="18" height="18" 
        align="absmiddle" style="cursor:hand" alt="วันที่กำหนดราคา" border="0"></a>			
		</td>
      </tr>	   
      -->   			 
	  <tr class="gray">
		<td  width="120" class="item"><nobr>ค่าบริการสาธารณะ :</nobr></td>
		<td>        
        <input type="hidden" name="d_public" id="d_public" value="<%=dPublic %>">
        
		<input type="text" class="boxR" name="z_price" id="z_price" style="width:80px;" value="<%=doString.displayNumber("######0.00",zPrice) %>">
		 &nbsp; <span id="price_type" style="color:red"><%=(fExtra.equals("N") ? "บาท / ตรว." : "บาท / หลัง")  %></span>
		</td>
      </tr>
	  <tr>
		<td  width="120" class="item"><nobr>ค่าสาธารณูปโภค :</nobr></td>
		<td>
		<input type="text" class="boxR" name="z_club" id="z_club" style="width:80px;" value="<%=doString.displayNumber("######0.00",zClub) %>">
		 &nbsp; <span id="club_type" style="color:red"><%=(fExtra.equals("N") ? "บาท / ตรว." : "บาท / หลัง")  %></span>
		</td>
      </tr>								      	          
	</table>	
			
	<br style="font-size:5pt">
	
	<table border="0" width="750" cellspacing="0" cellpadding="0">
	<tr><td><b style="color:red; font-size:14px">* หน้าจอนี้เป็นการตั้งเฟสค่าบริการสาธารณะสำหรับใช้คำนวนงวด C0</b></td></tr>
	<%
		if (!foundAdmRate && foundLastPhase) {
			%><tr><td><b style="color:red; font-size:14px">* ไม่พบข้อมูลอัตราค่าบริการสาธารณะจากทางอำนวยการ, ระบบจะดึงค่าจากเฟสล่าสุดมาใช้เป็นค่าเริ่มต้น!!</b></td></tr><%
		}	
	%>			
	</table>   
	
	<br style="font-size:10pt">		

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
				if (errMsg.indexOf("ERR_EXIST_PHASE")>=0) {
					errMsg = "มีข้อมูลเฟสนี้ในระบบแล้ว!!";
				} else {
					errMsg = "พบข้อผิดพลาดในการจัดเก็บข้อมูล, กรุณาติดต่อฝ่าย IT !!\\n\\n"+errMsg;
				}
			}
			%><script>alert('<%=errMsg %>');</script><%
		}


		stmt.close();
		conn.close();
		conn = null;
	}
	catch (Exception e) {
		System.out.println("!!!ERROR SERV_PhaseProjAdd.jsp : " + e.getMessage());
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