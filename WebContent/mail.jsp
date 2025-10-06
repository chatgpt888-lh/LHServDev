<%@page import="java.io.InputStreamReader"%>
<%@page import="com.lh.util.doString"%>
<%@page import="serv.util.LHSendMail"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.net.URLConnection"%>
<%@page import="java.net.URL"%>
<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%
StringBuffer sourceCode = new StringBuffer("");
//URL url = new URL(request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath()+"/SERV_BeyondMail.jsp");

String doc = doString.checkString(request.getParameter("doc"),"");
if("".equals(doc)) doc = "LH-075-5800024";
URL url = new URL("http://132.146.4.23:9080/LHServ/SERV_BeyondMail.jsp?doc="+doc);
//URL url = new URL("http://132.146.4.14/SERV_Mobile/index5_mail.html");
URLConnection urlConn = url.openConnection();
BufferedReader in = new BufferedReader(new InputStreamReader(urlConn.getInputStream()));
String inputLine;
while ((inputLine = in.readLine()) != null){
	sourceCode.append(inputLine);
}
in.close(); 
String mail = doString.MS874ToUnicode(sourceCode.toString());
LHSendMail.sendMail("lh.co.th", "application", "wannavar@lh.co.th,wichai@lh.co.th,pradoem@lh.co.th"
, "" , "Beyond Mail" , mail);

%>