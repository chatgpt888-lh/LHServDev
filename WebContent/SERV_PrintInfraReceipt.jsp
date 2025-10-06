<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%!

 public String setDateFormat(String date,String format) {
 	String result = "";
 	date = doString.checkString(date,"").trim();
 	
 	if (date.length()>=10) {
 		int y = Integer.parseInt(date.substring(0,4));
 		if (y<2400) y += 543;
 		result = date.substring(8,10)+"/"+date.substring(5,7)+"/"+y;
 		
 		if (date.length()>=16 && format.equalsIgnoreCase("T")) {
 			result += ","+date.substring(11,16);
 		}
 	} else {
 		result = "";
 	}	
 	
 	return result;
 }
 
 public String setMonthFormat(String date) {
 	String month[] = {"เดือน","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
 	String result = ""; 	
 	date = doString.checkString(date,"").trim();
 	
 	if (date.length()>=10) {
 		int y = Integer.parseInt(date.substring(0,4));
 		if (y<2400) y += 543;
 		int m = Integer.parseInt(date.substring(5,7));
 		if (m>=1 && m<=12) {
 			result = month[m]+" "+y;
 		} else {
 			result = "";
 		}
 	} else {
 		result = "";
 	}	
 	
 	return result;
 } 

%>

<%
	String sessionId = user.getsessionId();
	String userId = user.getUserID();
	String jName = "SERV_PrintInfraReceipt.jsp";
	ServLog servlog = new ServLog(sessionId, userId, jName);

	String selProj = doString.checkString(request.getParameter("sel_proj"),"");
	String selLock = doString.checkString(request.getParameter("sel_lock"),"").toUpperCase();
	String iCompany = selProj.length()==6 ? selProj.substring(0,2) : "";
	String iProject = selProj.length()==6 ? selProj.substring(3,6) : "";
	String act = doString.checkString(request.getParameter("act"),"");	

	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	StringBuffer sql = new StringBuffer();
	
	try {
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();
		stmt1 = conn.createStatement();

%>

<HTML>
<HEAD>
<TITLE>Open Job List</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<base target="_self">

<script language="javascript">

	function searchData(act) {
		if (document.forms[0].sel_proj.value=="") {
			alert("กรุณาเลือกโครงการ !!");
			document.forms[0].sel_proj.focus();
			return false;
		}
		
		if (document.forms[0].sel_lock.value=="") {
			alert("กรุณาระบุแปลงขาย !!");
			document.forms[0].sel_lock.focus();
			return false;
		}		
	
		document.forms[0].act.value=act;
		document.forms[0].action="<%=request.getContextPath()%>/SERV_PrintInfraReceipt.jsp";
		document.forms[0].submit();	
	}
	
	function printReceipt(i_com,i_receipt) {
		var params = "?recvCom="+i_com+"&i_receipt="+i_receipt;
	
		document.forms[0].target="_blank";
		document.forms[0].action="/LHServ/SERV_PrintReceiptServlet"+params;
		document.forms[0].submit();	
		document.forms[0].target="";

	}

</script>


</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">


<FORM METHOD="POST" ACTION="">


<input type="hidden" name="empId" value="<%=user.getEmpId()%>">
<input type="hidden" name="i_session" value="<%=user.getsessionId()%>">
<input type="hidden" name="recvCom" value="<%=iCompany %>">
<input type="hidden" name="flagRePrint" value="F"> <!-- fixed for force print -->
<input type="hidden" name="print_copy" value="Y"> <!-- fixed for print receipt copy -->
<input type="hidden" name="act" value="">


<table border="0" width="780" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center">

<div align="center">
  <center>

<table border="0" width="750" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center">
    

  <table border="0" width="100%" cellspacing="0" cellpadding="0" height="25">
    <tr>
      <td width="99%">
      
	<br style="font-size:4pt">      

      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
           พิมพ์สำเนาใบเสร็จค่าบริการสาธารณะ</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


	<br style="font-size:10pt">
                


      <table border="0" width="100%" cellspacing="0" cellpadding="0">
       <tr>
         <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
         <td class="item_tab2" width="200">รายละเอียดการค้นหา</td>
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
    
    
      <table border="0" width="100%" cellspacing="1" cellpadding="0">
        <tr>
          <td width="12%" height="25" class="item ; dotline01" height="22">โครงการ  :</td>  
          <td width="40%" height="25" class="dotline01" height="22">   
               <font color="#0078C8">   
		            <select class="box" style="width:280px" name="sel_proj">
		            <option value="">---- กรุณาเลือก ----</option>
		            <%
		            	String iCom = "";
		            	String iProj = "";
		            	String nProj = "";
		            	String sel = "";
		            
						sql.delete(0,sql.length());
						sql.append(" select i_company,i_project,n_project from lan:acxprojt ")
						   .append(" where d_confirm is not null ")
						   .append(" order by i_company,i_project  ");
						rs = stmt.executeQuery(sql.toString());
						while (rs.next()) {
							iCom = doString.checkString(rs.getString("i_company"),"");
							iProj = doString.checkString(rs.getString("i_project"),"");
							nProj = doString.DisplayThai(doString.checkString(rs.getString("n_project"),""));
							
							sel = "";
							if (selProj.equalsIgnoreCase(iCom+":"+iProj)) {
								sel = " selected ";
							}
						
							%><option value="<%=iCom+":"+iProj %>" <%=sel %>><%=iCom+"-"+iProj+" | "+nProj %></option><%
						} // end while
						rs.close();	  						          
		            %>         
		            </select>   
               </font></td>
          <td width="10%" class="item ; dotline01" height="22">แปลงขาย :</td>
          <td width="38%" class="dotline01" height="22">
            <input type="text" class="box" style="width:60px" name="sel_lock" value="<%=selLock %>">     
            &nbsp; &nbsp; &nbsp; 
            <img border="0" src="images/i_search.gif" align="absmiddle" onclick="searchData('SEARCH');" style='cursor:hand;'>
          </td>
        </tr>
        <%
           	String iCust = "";
           	String iCust1 = "";
           	String iCust2 = "";
           	String nCust1 = "";
           	String nCust2 = "";
           	String iLor = "";
           	String iHouse = "";
			
			
			//-----------  find lock details ---------------//
			sql.delete(0,sql.length());
			sql.append(" select m.i_house,m.s_lock,c.* from lan:acscontr c ")
			   .append(" left join lan:acxlckmd m on m.i_company=c.i_company and m.i_project=c.i_project and m.i_lock=c.i_sort ")
			   .append(" where c.i_company='"+iCompany+"' and c.i_project='"+iProject+"' ")
			   .append(" and c.i_sort='"+selLock+"' and c.f_contr is null ")
			   .append(" order by m.s_lock ");
			rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
				iLor = doString.checkString(rs.getString("i_lor"),"");
				iHouse = doString.checkString(rs.getString("i_house"),"");

				iCust1 = doString.checkString(rs.getString("i_cus_intent1"),"");
				iCust2 = doString.checkString(rs.getString("i_cus_intent2"),"");
				if (iCust1.trim().length()<=0) {
					iCust1 = doString.checkString(rs.getString("i_exp_intent1"),"");
					iCust2 = doString.checkString(rs.getString("i_exp_intent2"),"");
				}				
				
				//---- find customer name ----//
				iCust = "";
				nCust1 = "";
				nCust2 = "";
				sql.delete(0,sql.length());
				sql.append(" select * from lan:acxcusto where i_customer in ('"+iCust1+"','"+iCust2+"') ");		
				rs1 = stmt1.executeQuery(sql.toString());
				while (rs1.next()) {
					iCust = doString.checkString(rs1.getString("i_customer"),"");
					
					if (iCust.trim().length()>0) {
						if (iCust1.equals(iCust)) {
							nCust1  = doString.DisplayThai(doString.checkString(rs1.getString("n_prename"),""));				
							nCust1 += doString.DisplayThai(doString.checkString(rs1.getString("n_ncustomer"),""));				
							nCust1 += " "+doString.DisplayThai(doString.checkString(rs1.getString("n_scustomer"),""));	
						}
						
						if (iCust2.equals(iCust)) {
							nCust2  = doString.DisplayThai(doString.checkString(rs1.getString("n_prename"),""));				
							nCust2 += doString.DisplayThai(doString.checkString(rs1.getString("n_ncustomer"),""));				
							nCust2 += " "+doString.DisplayThai(doString.checkString(rs1.getString("n_scustomer"),""));	
						}
					}
				}
				rs1.close();		
				
			} // end if
			rs.close();					
        %>	
        <!--===========================  lock details ============================-->
        <tr>
          <td height="25" class="item ; dotline01" height="22"><nobr>ชื่อลูกค้าคนที่ 1 :</nobr></td>
          <td height="25" class="dotline01" height="22">&nbsp;<%=doString.checkString(nCust1,"-") %></td>
          <td width="10%" class="item ; dotline01" height="22"><nobr>ชื่อลูกค้าคนที่ 2 :</nobr></td>
          <td class="dotline01" height="22">&nbsp;<%=doString.checkString(nCust2,"-") %></td>
        </tr>                   
        <tr>
          <td height="25" class="item ; dotline01" height="22">บ้านเลขที่ :</td>
          <td height="25" class="dotline01" height="22"><%=doString.checkString(iHouse,"-") %></td>
          <td width="10%" class="item ; dotline01" height="22">&nbsp;</td>
          <td class="dotline01" height="22">&nbsp;</td>
        </tr>                           
        <!--===========================  lock details ============================-->               
      </table> 

    
<br style="font-size:5pt">      
 
      
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


  </center>
</div>

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
		   <td width="5%" class="col_name" align="center">ใบที่</td>
		   <td width="12%" class="col_name" align="center">ช่วงปี</td>
		   <td width="12%" class="col_name" align="center">วันที่ใบเสร็จ</td>
		   <td width="12%" class="col_name" align="center">เลขที่ใบเสร็จ</td>
		   <td width="12%" class="col_name" align="center">จำนวนเงิน</td>
		   <td width="27%" class="col_name" align="center">ชื่อลูกค้า</td>
		   <td width="20%" class="col_name" align="center">วันที่พิมพ์ใบเสร็จ</td>
        </tr>
	 	<%
		 	int line = 0;
		  	String iReceipt = "";
		  	String dReceipt = "";
		  	double zAmount = 0.0;
		  	double sumAmt = 0.0;  
			String period = "";
		  	String nReten = "";
		  	String printReten = "";
		  	String dAcConf = "";
		  	String iPvNo = "";
		  	
		    sql.delete(0,sql.length());
		    sql.append(" select a.i_receipt, c.d_receipt, sum(a.z_amount) as sum_amt, c.i_user , c.d_receipt>='2016-09-01' as old_recpt ")
		       .append(" from lan:acrdtrec a, lan:acrrecpt c, lan:acrrecev r ")
		       .append(" where a.i_company='"+iCompany+"' and a.i_project='"+iProject+"' ")
		       .append(" and a.i_lor='"+iLor+"' and a.i_com_recv=c.i_company ")
		       .append(" and a.i_receipt=c.i_receipt and a.d_adjust is null ")
		       .append(" and c.i_cancel is null and (a.f_cancel is null or a.f_cancel='C') ")
		       .append(" and a.s_item=r.s_item and r.i_due='R2' ") // for infra pay only
		       .append(" group by a.i_receipt, c.d_receipt, c.i_user ")
			   .append(" order by c.d_receipt ");
			rs = stmt.executeQuery(sql.toString());				
			while (rs.next()) {
				iReceipt = doString.checkString(rs.getString("i_receipt"),"");
				dReceipt = setDateFormat(rs.getString("d_receipt"),"D");
				zAmount = rs.getDouble("sum_amt");
				sumAmt += zAmount;
				

				//--- find details ---//
				period = "";
				nReten = "";
			    sql.delete(0,sql.length());
			    sql.append(" select h.* from lan:serv_payin p ")
			       .append(" left join lan:serv_infhd h on h.i_docno=p.i_docno and h.i_company=p.i_company and h.i_project=p.i_project and h.i_lor=p.i_lor ")
			       .append(" where p.i_company='"+iCompany+"' and p.i_project='"+iProject+"' ") 
			       .append(" and p.i_lor='"+iLor+"' and p.i_receipt='"+iReceipt+"' ");
			    rs1 = stmt1.executeQuery(sql.toString());
			    if (rs1.next()) {
			    	nReten = doString.checkString(rs1.getString("n_custo"),"");
			    	period = setMonthFormat(doString.checkString(rs1.getString("d_start"),""))+" - "+setMonthFormat(doString.checkString(rs1.getString("d_end"),""));
			    }
			    rs1.close();			    
			    
			    
			    //---- check receipt already print or not ----//
			    printReten = "";
				sql.delete(0,sql.length());
				sql.append(" select * from lan:log_retenrcpt ")
				   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
				   .append(" and i_lor='"+iLor+"' and i_receipt='"+iReceipt+"' ")
				   .append(" order by d_reten desc ");					
				rs1 = stmt1.executeQuery(sql.toString());
				while (rs1.next()) {
					if (doString.checkString(rs1.getString("i_reten"),"").length()>0) {
						printReten = setDateFormat(rs1.getString("d_reten"),"T");
						printReten += " ("+doString.checkString(rs1.getString("i_reten"),"")+") ";
					} else {
						printReten = "";
					}
				}
				rs1.close();				    
			    
		
				%>		
				  <tr>
				  	<td class="dotline" height="22" align="center">&nbsp;<%=(line+1) %></td>
				    <td class="dotline" height="22" align="center">&nbsp;<nobr><%=doString.checkString(period,"-") %></nobr></td>
				    <td class="dotline" height="22" align="center">&nbsp;<%=doString.checkString(dReceipt,"-") %></td>
				    <td class="dotline" height="22" align="center">
				    &nbsp; <a href="javascript:printReceipt('<%=iCompany%>','<%=iReceipt%>');"><%=iReceipt %></a>
				    <input type="hidden" name="print_receipt" value="<%=iReceipt %>">
				    </td>
				    <td class="dotline" height="22" align="right"><nobr><%=doString.displayNumber("###,###,##0.00",zAmount)%>&nbsp;</td>
				    <td class="dotline" height="22" align="left">&nbsp;<%=doString.DisplayThai(doString.checkString(nReten,"-")) %></td>
				    <td class="dotline" height="22" align="left">&nbsp;<nobr><%=doString.checkString(printReten,"") %><nobr></td>
				  </tr>		  
				<%
				
				line++;
			}
			rs.close();
			rs=null;
			 	
		 	
		 	while (line<5) { 
				%>
				  <tr>
				    <td align="center" class="item ; dotline" height="22">&nbsp;</td>
				    <td align="center" class="item ; dotline" height="22">&nbsp;</td>
				    <td align="center" class="item ; dotline" height="22">&nbsp;</td>
				    <td align="center" class="item ; dotline" height="22">&nbsp;</td>
				    <td align="center" class="item ; dotline" height="22">&nbsp;</td>
				    <td align="center" class="item ; dotline" height="22">&nbsp;</td>
				    <td align="center" class="item ; dotline" height="22">&nbsp;</td>
				  </tr>		
				<%
				
				line++;
			} // end while		  	
        
        
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

<br style="font-size:6pt">

<table border="0" width="750" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center">
     


        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td width="5" valign="top"><img border="0" src="images/b3_tab1.gif" width="6" height="30"></td>
            <td width="75" background="images/b3_tab2.gif" style="background-repeat : repeat-x" valign="top">
            &nbsp;
            </td>   
            <td width="57" valign="top"><img border="0" src="images/b3_tab3.gif" width="57" height="30"></td>   
            <td background="images/b3_tab4.gif" style="background-repeat : repeat-x" valign="middle">   
              <p align="right"><a href="javascript:history.back()"><img border="0" src="images/bu_back.gif" width="50" height="15"></a>&nbsp;&nbsp;&nbsp;
              <a href="Serv_Index.jsp"><img border="0" src="images/bu_home.gif" width="50" height="15"></a></td>  
          </tr>  
        </table>  
           
        
        


     <br style="font-size:20pt">      
           
        
	<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
	  <tr><td width="100%" class="copyright" align="center">
	  Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5  
	  <br>ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;
	  หรือ โทร. 0-2230-8279 (คุณประพัฒน์
	  ฝ่ายบริการ)&nbsp; 0-2230-8491-5 (ฝ่าย IT)  
	  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
	</TABLE> 

    </td>
  </tr>
</table>

</td>
  </tr>
</table>

</form>

<%
	if (act.equalsIgnoreCase("SEARCH") && selProj.length()>0 && selLock.length()>0 && iLor.length()<=0) {
		%><script>alert("ไม่พบแปลงขายที่ระบุ !!");</script><%
	}
%>

</body>

</html>
<%
		stmt.close();
		stmt1.close();
		conn.close();
		stmt=null;
		stmt1=null;
		conn=null;
	} catch (Exception e) {
		System.out.println("ERROR SERV_PrintInfraReceipt.jsp : " + e.getMessage());
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