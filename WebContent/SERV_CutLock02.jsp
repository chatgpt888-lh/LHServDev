<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>

<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>
<%  
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_CutLock02.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

	String mode = doString.checkString(request.getParameter("mode"),"add");
    String editId = doString.checkString(request.getParameter("edit_id"),"");

    String selProj = doString.checkString(request.getParameter("sel_project"),"");
	String iCode = doString.checkString(request.getParameter("i_code"),"");
	String refresh = doString.checkString(request.getParameter("refresh"),"");
    
    // ---------------for date--------------------
    String eDate = doString.checkString(request.getParameter("e_date"),"");
    String eMonth = doString.checkString(request.getParameter("e_month"),"");
    String eYear = doString.checkString(request.getParameter("e_year"),"");
     
	String iModel = "-";
	String iCom = (selProj.length()>=2 ? selProj.substring(0,2) : "");
	String iPro = (selProj.length()>=6 ? selProj.substring(3,6) : "");
	String iLock = doString.checkString(request.getParameter("i_lock"),"").toUpperCase();
    double zAmount = Double.parseDouble(doString.checkString(request.getParameter("z_amount"),"0.00"));

	
    StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	SERV_CommonData com = null;
	doString str = new doString();
	
	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();   
	    com = new SERV_CommonData(conn);  
        //----=======================================----//	
        
        
        String foundLock = "";
		String disabled = "";

        
        if (!refresh.equalsIgnoreCase("YES")) {
           //---======== First Load , set Date to today ==========----//
           Calendar tmp  = Calendar.getInstance();
           eDate = str.createID(tmp.get(Calendar.DATE),2);
           eMonth = str.createID(tmp.get(Calendar.MONTH)+1,2);
		   int year = tmp.get(Calendar.YEAR);
		   if (year<2400) year += 543;
           eYear = str.createID(year,4); 
        } else {
			String icom = selProj.length()>=6 ? selProj.substring(0,2) : "";
			String iproj = selProj.length()>=6 ? selProj.substring(3,6) : "";

	        sql.delete(0,sql.length());
	        sql.append(" select * from acmpredt where i_company='"+icom+"'  and i_project='"+iproj+"' ")
	              .append(" and i_lock='").append(iLock).append("' ");
			servlog.startLog(sql.toString());
	        rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
	        if (rs.next()) {
	            foundLock = "YES";
	            iModel = doString.checkString(rs.getString("i_model"),"");
	        }
	        rs.close();        
        }
        
		if (mode.equalsIgnoreCase("EDIT") && editId.trim().length()>0) {
			StringTokenizer id = new StringTokenizer(editId,":");
			if (id.countTokens()>=5) {
				sql.delete(0,sql.length());
				sql.append(" select c.i_model,a.* from lan:serv_cutlck a ")
					  .append(" left join lan:acxlckmd c on c.i_company=a.i_company ")
					  .append(" and c.i_project=a.i_project and c.i_lock=a.i_lock ")
					  .append(" where a.i_company='").append(id.nextToken()).append("' ")
					  .append(" and a.i_project='").append(id.nextToken()).append("' ")
					  .append(" and a.i_lock='").append(id.nextToken()).append("' ")
					  .append(" and a.d_effective='").append(id.nextToken()).append("' ")
					  .append(" and a.i_cut_type='").append(id.nextToken()).append("' ");
				servlog.startLog(sql.toString());
 	            rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
				if (rs.next()){
						iLock = doString.checkString(rs.getString("i_lock"),"");
						iModel = doString.checkString(rs.getString("i_model"),"-");
						iCode = doString.checkString(rs.getString("i_cut_type"),"");		
						zAmount = rs.getDouble("z_amount");

						iCom = doString.checkString(rs.getString("i_company"),"");		
						iPro = doString.checkString(rs.getString("i_project"),"");		
						selProj = iCom+":"+iPro;
						foundLock = "YES";
						disabled = " disabled ";
						
						Timestamp tmp = rs.getTimestamp("d_effective");
						Calendar dTmp = Calendar.getInstance();
						if (tmp!=null) {
						   dTmp.setTime(tmp);
						   int y = dTmp.get(Calendar.YEAR);
						   if (y<2400) y += 543;

						   eYear = str.createID(y,4);
						   eMonth = str.createID(dTmp.get(Calendar.MONTH)+1,2);
						   eDate = str.createID(dTmp.get(Calendar.DATE),2);
						}

				 } // end if rs.next()
			} // end if check token 
		} // end if mode
        
	 %>

<HTML>
<HEAD>
<TITLE>ข้อมูลพื้นฐาน : 06
รายละเอียดการตัดเงินตามแปลง</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript">


function validateDate(d,m,y) {

    if ((parseInt(d.value,10)>=1 && parseInt(d.value,10)<=31) && d.value.length>0) {
       if((parseInt(m.value,10)>=1 && parseInt(m.value,10)<=12) && m.value.length>0) {
          if((parseInt(y.value,10)>=2000) && y.value.length>0) {
              var yy = parseInt(y.value,10);
              if (yy>2400) yy -= 543;
	           var tmpD = new Date(yy,parseInt(m.value,10)-1,d.value);
	           if (tmpD.getMonth()==(parseInt(m.value,10)-1)) {
	              return true; 
	           } else {
	              alert("วันที่ไม่ถูกต้อง กรุณาตรวจสอบวันใหม่อีกครั้ง !\n(กรณีเป็นวันสิ้นเดือน กรุณาตรวจสอบวันสิ้นเดือนว่าถูกต้องหรือไม่)");
	              d.focus();
	              return false;
	           }
          } else {
	           alert("ปีต้องมากกว่า 2000 เท่านั้น !");
	           y.focus();
	           return false;          
          }

       } else {
           alert("เดือนต้องเป็น 1 - 12 เท่านั้น !");
           m.focus();
           return false;
       }
    } else {
       alert("วันที่ต้องเป็น 1 - 31 เท่านั้น !");
       d.focus();
       return false;
    }
    
    return false;
}


function save() {
     var form = document.forms[0];

     if (form.sel_project.value=="") {
        alert(" กรุณาเลือกโครงการ !");
        return false;
     }  	  
     
     if (form.i_lock.value=="") {
        alert(" กรุณากรอกแปลง !");
        return false;
     }  	  
     
     if (form.i_lock.value=="") {
        alert(" กรุณากรอกแปลง !");
        return false;
     }       
     
	  if (form.found_lock.value!="YES") {
	     alert("ไม่พบข้อมูลแปลงที่กรอก อยู่ในโครงการนี้ , กรุณาใส่แปลงใหม่ !");
	     return false;
	  }     
     
     if (form.i_code.value=="") {
        alert(" กรุณาเลือกประเภทการตัดเงิน !");
        return false;
     }       
	 
     if (form.z_amount.value=="") {
        alert(" กรุณากรอกจำนวนเงิน !");
        return false;
     }     
  
     if (!validateDate(form.e_date,form.e_month,form.e_year)) {
        return false;
     }  

  form.action="<%=Constants.APP_PATH%>/SERV_CutLockServlet";
  form.submit();
  
}

function refreshPage() {
   document.forms[0].refresh.value="YES";
   document.forms[0].action="<%=Constants.APP_PATH%>/SERV_CutLock02.jsp";
   document.forms[0].submit();
}

function checkAutoDefault(str) {
	var start = str.indexOf("ตัด");
	var end1 = str.indexOf("บาท");
	var end2 = str.indexOf("/");
	var end3 = str.indexOf("หลัง");

	if (start>=0 && start<end1 && end1<end2 && end2<end3)	{
	    var tmp = str.substring(start+3,end1);
	    var val = "";
		for (var i=0;i<tmp.length;i++) {
		       if ("0123456789.".indexOf(tmp.substring(i,i+1))>=0) {
			       val += tmp.substring(i,i+1);
		       }
		} // end for	

		if (val.length>0) {
			document.forms[0].z_amount.value=val;
		} else {
			document.forms[0].z_amount.value="0";
		}
	} else {
		document.forms[0].z_amount.value="0";
	}
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
<FORM action="" method="post">


<input type="hidden" name="found_lock" value="<%=foundLock%>">
<input type="hidden" name="refresh" value="">
<input type="hidden" name="mode" value="<%=mode%>">
<input type="hidden" name="edit_id" value="<%=editId%>">


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
                <td class="item_tab2" width="250">รายละเอียดการตัดเงินตามแปลง</td>
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
    <td class="item ; dotline01" height="22" width="20%">โครงการ :</td>
    <td height="22" width="80%" class="dotline01">
    <%=com.genAllProjectListbox("sel_project",selProj," size='1' class='box' style='width:250px' onchange='refreshPage();' "+disabled,false)%>
	<%
	  if (mode.equalsIgnoreCase("EDIT")) {
		  %><input type="hidden" name="sel_project" value="<%=selProj%>"><%
	  }	
	%>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="20%">แปลง :</td>
    <td height="22" width="80%" class="dotline01"><input type="text""  name="i_lock" class="boxC" value="<%=iLock%>" <%=disabled%> style="width:110px"  onchange="refreshPage()"></td>
  </tr>
  <tr>
   <td class="item ; dotline01" height="22" width="20%">แบบบ้าน :</td>
    <td height="22" width="80%" class="dotline01"><%=iModel%></td>
  </tr>
 <tr>
    <td class="item ; dotline01" height="22" width="20%">Effective Date :</td>
   <td height="22" width="80%" class="dotline01">
        <input type="text" name="e_date"  value="<%=eDate%>" class="boxC" style="width:30px" maxlength="2" <%=disabled%>>/
        <input type="text" name="e_month" value="<%=eMonth%>" class="boxC" style="width:30px" maxlength="2" <%=disabled%>>/ 
        <input type="text" name="e_year" value="<%=eYear%>" class="boxC" style="width:40px" maxlength="4" <%=disabled%>>
    </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="20%">ประเภทการตัดเงิน
      :</td>
    <td height="22" width="80%" class="dotline01"> 
    <%//=com.genDescListbox("i_code",iCode," size='1' class='box' style='width:250px'")%>
    
	<select name='i_code'  size='1' class='box' style='width:250px' onchange='checkAutoDefault(this.value);'>
	<%
		 sql.delete(0,sql.length());	
		 sql.append(" select distinct serv_xstd.n_desc ,serv_xstd.i_code from lan:serv_xstd ")
			   .append(" where serv_xstd.i_type='03' ")
			   .append(" order by serv_xstd.i_code"); 
		 servlog.startLog(sql.toString());
		 rs = stmt.executeQuery(sql.toString());
		 servlog.endLog();
	 
		 //-------============== Generate List box ===================------//
		 while (rs.next()) {

			String i_code = doString.checkString(rs.getString("i_code"),"");
			String n_desc = doString.checkString(doString.DisplayThai(rs.getString("n_desc")),"");
			String val = i_code+" - "+n_desc;
			String selected = "";
			if (iCode.length()>=1 && iCode.substring(0,1).equals(i_code)) {
			   selected = " selected "; 
			}		        
		
			%><option value='<%=val%>' <%=selected%>><%=val%></option><%
		
					
		 } // end while		     
	 
		 //----=====================================================----//
					 
		 rs.close();
		 stmt.close();		
	%>
	</select>

    </td>
  </tr>
  <tr>
   <td class="item ; dotline01" height="22" width="20%">จำนวนเงิน :</td>
    <td height="22" width="80%" class="dotline01"><input type="text" name="z_amount"  onkeypress="inputFloat(this);" value="<%=doString.displayNumber("######0.00",zAmount)%>" class="box" style="width:70px"></td>
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
            <td width="75" class="act_tab2">

            <img border="0" src="images/act_saveandclose.gif" onclick="save();"                                   
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">

            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_CutLock01.jsp" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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

<%
   if (!foundLock.equalsIgnoreCase("YES") && refresh.equalsIgnoreCase("YES")) {
      %><script>alert("ไม่พบข้อมูลแปลงที่กรอก อยู่ในโครงการนี้ !");</script><%
   }

%>


</BODY>

</HTML>
<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_CutLock01.jsp : " + e.getMessage());
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