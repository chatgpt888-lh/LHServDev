
<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>

<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%!
public Integer[] newIntegerArray(int size) {
	Integer data[] = new Integer[size];
	for (int l=0;l<size;l++) {
		  data[l] = new Integer(0);
	}

	return data;
}

%>


<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_Report2_1.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   doString str = new doString();
   DecimalFormat  format = new DecimalFormat("#,###,##0");


   String monthReport = doString.checkString(request.getParameter("month_report"),"0");
   String yearReport = doString.checkString(request.getParameter("year_report"),"0");
    int fp = 0;



   //----============ Declare Variables for input data ===========----//
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	SERV_CommonData common = null;


	try {

        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();
		common = new SERV_CommonData(conn);
        //----=======================================----//



		//---=========== Month Initilize =========----//
		String thaiMonth[] = new String[] {"","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
		String shortMonth[] = new String[] {"","ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค."};
		String showMonth = thaiMonth[Integer.parseInt(monthReport)];
		String showYear = Integer.toString(Integer.parseInt(yearReport)+543);
		String startQueryDate = "";
		String endQueryDate = "";

		Integer monthList[] = newIntegerArray(24);
		Integer yearList[] = newIntegerArray(24);

		Calendar now = Calendar.getInstance(Locale.ENGLISH);
		now.set(Integer.parseInt(yearReport),Integer.parseInt(monthReport)-1,1,0,0,0);

		for (int i=0;i<24;i++) {
			  int month = now.get(Calendar.MONTH)+1;
			  int year = now.get(Calendar.YEAR);
			  if (year>2400) year -= 543;
			  	
			  if (i==0)	 {
				 startQueryDate = str.createID(year,4)+"-"+str.createID(month,2)+"-01";
			  } 
			 endQueryDate = str.createID(year,4)+"-"+str.createID(month,2)+"-01";

			  now.add(Calendar.MONTH,-1);
			  monthList[i] = new Integer(month);
			  yearList[i] = new Integer(year+543);
		} // end for

%>

<HTML>
<HEAD>
<TITLE>Open Job List</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>


<script language="javascript">

function printReport() {
   document.forms[0].action='<%=Constants.APP_PATH%>/SERV_PrintReport2Servlet';
   //document.forms[0].action='http://www9.lh.co.th/LHServ/SERV_PrintReport2Servlet';
   document.forms[0].target="_blank";   
   document.forms[0].submit();
   document.forms[0].target="";   
}

function goSubReport(selproj,sd,sm,sy,ed,em,ey) {
	document.forms[0].key_project.value=selproj;
	
	document.forms[0].start_date.value=sd;
	document.forms[0].start_month.value=sm;
	document.forms[0].start_year.value=sy;

	document.forms[0].end_date.value=ed;
	document.forms[0].end_month.value=em;
	document.forms[0].end_year.value=ey;

	document.forms[0].action='<%=Constants.APP_PATH%>/SERV_Report2Det.jsp';
    document.forms[0].submit();
}

</script>


<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM ACTION="" METHOD="POST">


<input type="hidden" name="month_report" value="<%=monthReport%>">
<input type="hidden" name="year_report" value="<%=yearReport%>">


<input type="hidden" name="key_project" value="">

<input type="hidden" name="start_date" value="">
<input type="hidden" name="start_month" value="">
<input type="hidden" name="start_year" value="">

<input type="hidden" name="end_date" value="">
<input type="hidden" name="end_month" value="">
<input type="hidden" name="end_year" value="">


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp; 
            สรุปจำนวนบ้านโอนย้อนหลัง 24 เดือน</td>
          <td width="50%" align="right"></td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                
          <td class="item_tab2" width="200">รายละเอียดเดือน/ปีที่ระบุ</td>
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
    <td class="item ; dotline01" height="22" colspan="4">
	เดือน : <%=showMonth%> &nbsp; พ.ศ. <%=showYear%></td>
  </tr>


	<%
      Hashtable projectList = new Hashtable();
      Hashtable dataList = new Hashtable();
	  Integer totalData[] = newIntegerArray(25);

	  String[] projList = request.getParameterValues("sel_proj");
  	  String queryProject = "";
	  int line = 0;

	  if (projList!=null) {
		  for (int i=0;i<projList.length;i++) {
				 String proj = doString.checkString(projList[i],"");  
				 if (proj.trim().length()>=6) {
					 if (queryProject.trim().length()>0) queryProject += " or ";
					 queryProject += " (i_company='"+proj.substring(0,2)+"' and i_project='"+proj.substring(3,6)+"') ";
				 }
				 /*
				 if (queryProject.trim().length()>0) queryProject += " , ";
				 queryProject += " '"+proj+"' ";*/

				  %><input type="hidden" name="sel_proj" value="<%=proj%>"><%


				//---============= get Project Details ===============----//
				sql.delete(0,sql.length()); 
				sql.append(" select * from lan:acxprojt ")
					  .append(" where i_company='").append(proj.length()>=6 ? proj.substring(0,2) : "").append("' ")
					  .append(" and i_project='").append(proj.length()>=6 ? proj.substring(3,6) : "").append("' ");

				servlog.startLog(sql.toString());
				rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
				while (rs.next()) {
					 String nProject = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
					 if (nProject.length()>30) nProject = nProject.substring(0,30);
					 String iProj = str.replace(proj,":","-");	

					 projectList.put(proj,nProject);
					 dataList.put(proj,newIntegerArray(25));
					

					 if (line==0) {
						 %><tr><td class="item ; dotline01" height="22" width="10%">โครงการ :</td><%
					 } else if (line%3==0 && line!=0) {
						 %><tr><td class="item ; dotline01" height="22" width="10%">&nbsp;</td><%
					}

				    %><td height="22" width="30%" class="dotline01"><%=iProj%> <%=nProject%></td><%

					if (line%3==2) {
						%></tr><%
					}

					line++;
				} // end while
				rs.close();

		  } // end for


		  while (line%3!=0) {
			  %><td height="22" width="30%" class="dotline01">&nbsp;</td><%
			  line++;

		 	  if (line%3==0) {
				out.print("</tr>");
			  }
		  }

	  } else {
		  queryProject = " i_company='' and i_project='' ";
	  }



	  //-----================= Start Get Data From =================-----//
	  for (int l=0;l<24;l++) {
			sql.delete(0,sql.length());
			sql.append(" select i_company,i_project ,count(*) as cnt from lan:acsregis ")
				  .append(" where (").append(queryProject).append(") ")
				  .append(" and year(d_close_law)=").append(Integer.toString(yearList[l].intValue()-543))
				  .append(" and month(d_close_law)=").append(monthList[l].toString())
				  .append(" group by i_company,i_project ");
//out.println("<br>"+sql.toString());
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			while (rs.next()) {
				String comId = doString.checkString(rs.getString("i_company"),"");
				String projId = doString.checkString(rs.getString("i_project"),"");
				int count = rs.getInt("cnt");
				Integer data[] = (Integer[]) dataList.get(comId+":"+projId);
				if (data==null) {
					data = newIntegerArray(25);
				}

				data[l+1] = new Integer(data[l+1].intValue()+count);
				data[0] = new Integer(data[0].intValue()+count);
				dataList.put(comId+":"+projId,data);

				totalData[l+1] = new Integer(totalData[l+1].intValue()+count);

				//------- total for summary all -------//
				totalData[0] = new Integer(totalData[0].intValue()+count);
//out.println("<br> 0data[0] = "+data[0]);
			} // end while
			rs.close();
	  }


		//----================= Find old transfer ================-----//
		/*
		int lastyear = yearList[0].intValue()-543;
		int lastmonth = monthList[0].intValue()+1;
		if (lastmonth>12) {
			lastmonth = 1;
			lastyear++;
		}
		*/
		int lastyear = yearList[23].intValue()-543;
		int lastmonth = monthList[23].intValue();

		sql.delete(0,sql.length());
		sql.append(" select i_company,i_project ,count(*) as cnt from lan:acsregis ")
			  .append(" where (").append(queryProject).append(") ")
			  .append(" and d_close_law<'").append(lastyear)
			  .append("-").append(lastmonth).append("-01' ")
			  .append(" group by i_company,i_project ");
//out.println("<br>"+sql.toString());
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		while (rs.next()) {
			String comId = doString.checkString(rs.getString("i_company"),"");
			String projId = doString.checkString(rs.getString("i_project"),"");
			int count = rs.getInt("cnt");
			Integer data[] = (Integer[]) dataList.get(comId+":"+projId);
			if (data==null) {
				data = newIntegerArray(25);
			} else {
				//--- 2010-03-19 ----//
				/*
				for (int k=1;k<25;k++) {
						data[0] = new Integer(data[0].intValue()+data[k].intValue());
				} // end for
				*/
				//-------------------------//
			}
			data[0] = new Integer(data[0].intValue()+count);
//out.println("<br> 2data[0] = "+data[0]);
			dataList.put(comId+":"+projId,data);

			totalData[0] = new Integer(totalData[0].intValue()+count);
		} // end while
		rs.close();


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


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                
          <td class="item_tab2" width="200">รายละเอียดจำนวนบ้านโอนตามโครงการ</td>
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
              <tr> 
                <td width="15%" rowspan="2" class="col_name">โครงการ</td>
                <td width="3%" rowspan="2" align="center" valign="middle" class="col_name">สะสม</td>
				<%
		            int oldYear = 0;
					int colspan = 0;
					boolean printYear = false;
				    for (int i=0;i<24;i++) {
						   if (oldYear!=yearList[i].intValue()) {
							   if (oldYear>0) {
								   printYear = true;
								   %><td colspan="<%=colspan%>" align="center" valign="middle" class="col_name"><%=oldYear%></td><%
							   }
							   oldYear = yearList[i].intValue();
							   colspan=1;
						   } else {
							   colspan++;
							   printYear = false;
						   }
					} // end for

					%><td colspan="<%=colspan%>" align="center" valign="middle" class="col_name"><%=oldYear%></td><%

				%>
              </tr>
              <tr> 
				<%
				    for (int i=0;i<24;i++) {
					      String sMonth = shortMonth[monthList[i].intValue()];
						  %><td width="3%" align="center" valign="middle" class="col_name"><%=sMonth%></td><%
					} // end for
				%>
              </tr>
			  <%

			  line=0;	
		  	  if (projList!=null) {
				  for (int i=0;i<projList.length;i++) {
					      line++;
						 String proj = doString.checkString(projList[i],"");  
						 String nProject= (String) projectList.get(proj);
						 Integer data[] = (Integer[]) dataList.get(proj);

						 Calendar tmp = Calendar.getInstance(Locale.ENGLISH);
						 tmp.set(yearList[0].intValue()-543,monthList[0].intValue(),1);
						 tmp.add(Calendar.DATE,-1);
						 int endDate = tmp.get(Calendar.DATE);
						 String params = "'"+str.createID(endDate,2)+"','"+str.createID(monthList[0].intValue(),2)+"','"+(yearList[0].intValue()-543)+"'";
					     params = "'01','"+str.createID(monthList[23].intValue(),2)+"','"+(yearList[23].intValue()-543)+"',"+params;
						 String showData = "<nobr><a href=\"javascript:goSubReport('"+proj+"',"+params+");\">"+proj+" "+nProject+"</a></nobr>";

/*
						 Calendar tmp = Calendar.getInstance(Locale.ENGLISH);
						 tmp.set(yearList[23].intValue()-543,monthList[23].intValue(),1);
						 tmp.add(Calendar.DATE,-1);
						 int endDate = tmp.get(Calendar.DATE);
						 String params = "'01','"+str.createID(monthList[0].intValue(),2)+"','"+(yearList[0].intValue()-543)+"'";
					     params = "'"+str.createID(endDate,2)+"','"+str.createID(monthList[23].intValue(),2)+"','"+(yearList[23].intValue()-543)+"',"+params;
						 String showData = "<a href=\"javascript:goSubReport('"+proj+"',"+params+");\">"+proj+" "+nProject+"</a>";
*/
						 %>
						  <tr> 
							<td width="15%" align="left" class="dotline">&nbsp;<%=showData%></td>
							<%
								fp = 0;
							    tmp = Calendar.getInstance(Locale.ENGLISH);
								for (int col=0;col<25;col++)  {
										//fp = (col==25 ? 0 : col);					
										fp = col;		
							           showData = format.format(data[fp]);
									   if (fp>0) {
										   tmp.set(yearList[fp-1].intValue()-543,monthList[fp-1].intValue(),1);
										   tmp.add(Calendar.DATE,-1);
										   endDate = tmp.get(Calendar.DATE);

										   params = "'01','"+str.createID(monthList[fp-1].intValue(),2)+"','"+(yearList[fp-1].intValue()-543)+"',";
										   params += "'"+str.createID(endDate,2)+"','"+str.createID(monthList[fp-1].intValue(),2)+"','"+(yearList[fp-1].intValue()-543)+"'";

										   showData = "<a href=\"javascript:goSubReport('"+proj+"',"+params+");\">"+showData+"</a>";   
									   }
							          %><td width="3%" height="1" align="right" valign="middle" class="dotline"><%=showData%></td><%
								}
							%>
						  </tr>						 
						 <%

				  } // end for
			  }

			  while (line<10) {
				  line++; 
				  %>
				  <tr> 
					<td align="center" class="dotline">&nbsp;</td>
					<td align="center" valign="middle" class="dotline">&nbsp;</td>
					<td height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
					<td height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
					<td height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
					<td height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
					<td height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
					<td height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
					<td height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
					<td height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
					<td height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
					<td height="1" align="center" valign="middle" class="dotline">&nbsp;</td>
					<td height="1" align="center" valign="middle" class="dotline ; item">&nbsp;</td>
					<td align="center" valign="middle" class="dotline">&nbsp;</td>
					<td align="center" valign="middle" class="dotline">&nbsp;</td>
					<td align="center" valign="middle" class="dotline">&nbsp;</td>
					<td align="center" valign="middle" class="dotline">&nbsp;</td>
					<td align="center" valign="middle" class="dotline">&nbsp;</td>
					<td align="center" valign="middle" class="dotline">&nbsp;</td>
					<td align="center" valign="middle" class="dotline">&nbsp;</td>
					<td align="center" valign="middle" class="dotline">&nbsp;</td>
					<td align="center" valign="middle" class="dotline">&nbsp;</td>
					<td align="center" valign="middle" class="dotline">&nbsp;</td>
					<td align="center" valign="middle" class="dotline">&nbsp;</td>
					<td align="center" valign="middle" class="dotline ; item">&nbsp;</td>
					<td align="center" valign="middle" class="dotline">&nbsp;</td>
				  </tr>				  
				  <%
			  }
			  %>

			  <tr> 
                <td width="15%" align="center" class="dotline"> <div align="right">รวม</div></td>
				<%
					fp = 0;
					for (int col=0;col<25;col++)  {
							//fp = (col==25 ? 0 : col);
							fp = col;
						  %>
							<td width="3%" height="1" align="right" valign="middle" class="dotline"><%=format.format(totalData[fp])%>&nbsp;</td>
						  <%
					}
				%>
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




<br style="font-size:3pt">
      <br style="font-size:10pt">



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="80" class="act_tab2">

            <img border="0" src="images/act_print.gif"  onclick="javascript:printReport();" 
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="FILTER: alpha(opacity=70);cursor:hand;" width="70" height="27">&nbsp; 
            </td>      
                  	
                  	
            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_Report2.jsp" target="_self"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
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
		System.out.println("ERROR SERV_Report2_1.jsp : " + e.getMessage());
		System.out.println("ERROR SERV_Report2_1.jsp SQL : " + sql.toString());
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