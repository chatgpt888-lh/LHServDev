<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>SSO Master</title>
</head>
<body>
<% 	String token = (String)request.getAttribute("token"); 
	System.out.println("==jsp=token="+ token);
	String url = (String)request.getAttribute("url");
	System.out.println("==jsp=url="+ url);

%>
<form name="distribute" method="post" action="<%=url%>">
<input type="hidden" name="ssotoken" value="<%=token%>">
</form>
<script language="JavaScript">
document.distribute.submit();
</script>
</body>
</html>