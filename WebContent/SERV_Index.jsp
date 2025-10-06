<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ include file="confirmLogin.jsp" %>
<%@page import="com.lh.util.doString"%>
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<meta http-equiv="Content-Language" content="th">
<title>... ยินดีต้อนรับสู่ระบบบริการหลังการขาย</title>
</head>
<%
String mainPage = doString.checkString(request.getParameter("main"),"");
if("".equals(mainPage) || null == mainPage){
	mainPage = "SERV_Home.jsp";
}
//add by pradoem 2023.05.30
if(user.getUserWho().equals("P")){
	mainPage = "SERV_Home_VP.jsp";
}


 %>
<frameset framespacing="0" border="0" rows="48,*" frameborder="0">
  <frame name="header" scrolling="no" noresize target="main" src="SERV_TopMenu.jsp">
  <frame name="main" src="<%=mainPage%>" target="_self" scrolling="auto">
  <noframes>
  <body topmargin="0" leftmargin="0">

  <p>This page uses frames, but your browser doesn't support them.</p>

  </body>
  </noframes>
</frameset>

</html>
