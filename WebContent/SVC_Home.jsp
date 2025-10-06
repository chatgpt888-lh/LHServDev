<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@page language="java" contentType="text/html; charset=tis-620"
	pageEncoding="tis-620"%>
<html>
<head>
<title>Service Center home</title>
<meta http-equiv="Content-Type" content="text/html; charset=tis-620">
<meta name="GENERATOR" content="Rational Application Developer">
<script language="javascript">
function doSubmitForm(){ 
    //var tel = document.forms[0].telNo.value; 
    //var agent = document.forms[0].agentId.value; 
    //var param = "&tel="+tel+"&agentId="+agent;
   // alert(param);
	document.forms[0].action="<%=request.getContextPath()%>/SVCInformController.do?cmd=search1";
	//alert(document.forms[0].action);
	document.forms[0].submit();
	//alert("xxx");
}
</script>
</head>
<body>
<br>&nbsp;&nbsp;Test Struts Framework 1.1  ครับ  #### (1.3.8)
<br>&nbsp;&nbsp;<a href="TestAction.do">Test Struts Action#1</a>
<br>&nbsp;&nbsp;<a href="TestDispactAction.do?cmd=formLoad">Test Dispatcher #1</a>

<br>
<hr width="100%" color="RED">
<b>(Project Service Center CALL Center version.1.0 ) ------SVC------ .</b><br/> 
[start date: 2013.10.15]<br>
1. &nbsp;&nbsp;   <a href="SVCInformController.do?cmd=search1&tel=0841013129&agentId=pradoem">SERVICE_CENTER_SERCH MOBILE</a>&nbsp;&nbsp;  [2013.10.15]<br>
2. &nbsp;&nbsp;    <a href="SVCMasterGCalendarController.do?cmd=formLoad">ข้อมูลตารางนัดซ่อม Google Calendar</a>&nbsp;&nbsp;  [2013.11.14]<br>
<!-- 
<b> ------SE-------.</b><br/> 
[start date: 2013.03.29]<br>
1. SELL&nbsp;&nbsp;    <a href="SellHomeController.do?cmd=formLoad">HOME</a> [2013.04.25]&nbsp;&nbsp; <br>
<b> ------Master Data keyin-------.</b><br/> 
[start date: 2013.03.29]<br>
1.<a href="MasterStandardController.do?cmd=formLoad">ข้อมูลพื้นฐาน (Callct_std type =05)</a> [2013.05.22]&nbsp;&nbsp; <br>
<br/> <b> ------Report CRM Follow up 1198-------.</b><br/> 
[start date: 2013.06.05]<br>
1.<a href="ReportCall01Controller.do?cmd=formLoad">Report #1 By </a> [2013.06.05]&nbsp;&nbsp;<br>
2.<a href="ReportCall02Controller.do?cmd=formLoad">Report #2 By Month</a> [2013.07.23]&nbsp;&nbsp;<br>
3.<a href="#">Report #3</a> [2013.0x.xx]&nbsp;&nbsp; <br>
4.<a href="CALL_1198FLM_ReportForm_01.jsp">Report FLM Export Excel#4</a> [2013.06.18]&nbsp;&nbsp; <br>
5.<a href="ReportSeFollowController.do?cmd=formLoad">Report SE Followup</a> [2013.07.10]&nbsp;&nbsp; <br>
 -->
<form action="" name="frm" method="post">
 Form input paramter <br>
 telephone number : <input type="text" name="tel" size="15"><br>
 agentId : <input type="text" name="agentId" size="15"><br>
 <input type="button" name="btn1" value="submit" onclick="javascript:doSubmitForm();">
 </form>
</body>
</html>
