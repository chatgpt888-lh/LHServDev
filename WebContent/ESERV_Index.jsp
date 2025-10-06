<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@page language="java" contentType="text/html; charset=tis-620"
	pageEncoding="tis-620"%>
<%@ page import="java.io.*,java.util.*" %>	
<html>
<head>
 
<title>ESER_Index</title>
<meta http-equiv="Content-Type" content="text/html; charset=tis-620">
<meta name="GENERATOR" content="Rational Application Developer">
</head>
<body >
<b>Project E-Service BackEnd</b><br>
1. <a href = "ESERV_AppointDateServlet?cmd=formLoad">ข้อมูลพื้นฐาน-> กำหนดวันเข้าตรวจสอบ</a><br>
2. <a href = "ESERV_MngAppointDateServlet?cmd=formLoad">ยกเลิกวันนัดเข้าตรวจสอบรายการซ่อม </a><br>
3. <a href = "ESERV_AfterAppointDateServlet?cmd=formLoad">แก้ไขวันเวลาให้เจ้าหน้าที่เข้าตรวจสอบ โดย After date </a><br>

4. <a href = "ESERV_GenPwdCust2Servlet?cmd=formLoad">X Auto Generate Password customer </a><br>
5. <a href = "ESERV_GenPwdCustServlet?cmd=formLoad">X (New)Auto Generate Password customer </a><br>

6. <a href = "ESERV_GenPwdCust2Servlet?cmd=formLoad">**(New)For Generate Password Old customer(OK) New Please wait image Jsp</a><br>
7. <a href = "ESERV_PrintPwdOldCustServlet?cmd=formLoad">**(New)For Print Carbon Password Old customer(OK) New Select All project</a><br>

<br>
<b>Project ZeroDefection</b><br>
1. <a href = "SERV_ZeroDefect_List.jsp">Zero Defection Form Load</a><br>
2. <a href = "SERV_ZeroDefectMasterServlet?cmd=formLoad">Master Data ZeroDefection </a>&nbsp;[date 2012.09.13]<br>
3. <a href = "SERV_ReportZero01.jsp">Report ZeroDefection </a>&nbsp;[date 2012.09.14]<br>
 <br>
 <b>SMS Master project 2014.09.02</b><br>
 1. <a href = "SERV_SmsMasterServlet?cmd=search">SMS Master</a><br>
 
 <br>
 <b>ข้อมูลพื้นฐาน IPV_QC BOQ 2014.10.13</b><br>
 1. <a href = "SERV_BOQ_IPVQC01.jsp">ข้อมูลพื้นฐาน IPV_QC BOQ</a><br>
 2. <a href = "SERV_RecBeforeTransferServlet?cmd=load">รายงาน ตรวจสอบรายการเก็บงานก่อนโอน</a> 2014.10.15<br>
 <br>
 <b>Report ระบบริการต่างๆ</b><br>
 1. <a href = "SERV_ReportINTBaanServlet?cmd=load">รายงาน แนะนำบ้าน</a> 2015.02.12<br>
 2. <a href = "SERV_ReportInformRepairServlet?cmd=load">รายงาน e-Service/SVC Summary</a> 2015.02.27<br>
 
 <br>
 <b>โปรแกรม TurnKey Approve 2015.05.11</b><br>
 1. <a href = "SERV_TurnkeyApprList.jsp">รายการโครงการ Turnkey รออนุมัติ</a><br>

 <br>
 <b>www7  Contractor Approve </b><br>
 1. <a href = "http://132.146.4.24:8080/LHServ/login.jsp" >Contractor Approve</a><br>
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 <%
  // Enumeration headerNames = request.getHeaderNames();
  // while(headerNames.hasMoreElements()) {
  //   String paramName = (String)headerNames.nextElement();
  //   out.print("<tr><td>" + paramName + "</td>\n");
  //    String paramValue = request.getHeader(paramName);
  //    out.println("<td> " + paramValue + "</td></tr>\n");
 //  }
%>
</body>
</html>
