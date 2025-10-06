<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="serv.common.Constants"%>
<%@ page isErrorPage="true" %>
<%@ page import="java.io.*" %>

<html>
<head>
<title>Error Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<style type=text/css>
body { font-size: 10pt; font-family: "MS Sans Serif", Thonburi }
td { font-size: 10pt; font-family: "MS Sans Serif", Thonburi }
th { font-size: 12pt; font-weight: bold; font-family: "MS Sans Serif", Thonburi }
input { font-size: 10pt; font-family: "MS Sans Serif", Thonburi}
</style>
</head>
<body bgcolor="#FFFFFF">
<table width="100%" border="0">
  <tr> 
    <td width="23%" align="right">&nbsp;</td>
    <td width="77%" align="left">&nbsp;</td>
  </tr>
  <tr> 
    <td width="23%" align="right"><b></b></td>
    <td width="77%" align="left"><b><font color="red">คำเตือน :</font></b> มีการทำงานผิดปกติ 
      กรุณาเริ่มขั้นตอนนี้ใหม่</td>
  </tr>
  <tr> 
    <td width="23%" align="right">&nbsp;</td>
    <td width="77%" align="left">แล้วจด Error ไว้ และติดต่อผู้รับผิดชอบโดยด่วน!!!</td>
  </tr>
  <tr> 
    <td width="23%" align="right">&nbsp;</td>
    <td width="77%" align="left"><%=exception.getMessage()%></td>
  </tr>
  <tr>
    <td width="23%" align="right">&nbsp;</td>
    <td width="77%" align="left"><a href="<%=Constants.APP_HOME%>">เริ่มต้นใหม่</a></td>
  </tr>
</table>
</body>
</html>