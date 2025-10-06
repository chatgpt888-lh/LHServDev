<%@ page import="serv.common.User"%>
<%@ page import="serv.common.SERV_CommonData"%>
<%@ page import="serv.common.Constants"%>
<%@ page import="serv.common.ItmJobManagement"%>

<%
	User user = null;
	if (session != null)
	{
		user = (User)session.getAttribute("USER");
	}
	
	String check = request.getRequestURI();
	if ( user == null ) {
		response.sendRedirect(Constants.WARNING_PAGE+"?url="+check);
	}	
	
	//----- If current page is not in these pages , clear itemjob session  ------//
	if (check.indexOf("SERV_OpenJob.jsp")<0 &&
	    check.indexOf("SERV_InfJob_Disp.jsp")<0 &&
	    check.indexOf("SERV_BOQSearch.jsp")<0 && 
	    check.indexOf("SERV_BOQCode01.jsp")<0 && 
	    check.indexOf("save_ok.jsp")<0) {
	    ItmJobManagement itm = new ItmJobManagement(request,response);
	    itm.removeItemSession(); // remove all itemjob session from memory
	}
	
	//----- If current page is not in these pages , clear vendor project session  ------//
	if (check.indexOf("SERV_VenPrj01.jsp")<0 &&
	    check.indexOf("SERV_VenPrj02.jsp")<0) {
	    session.removeAttribute("sess_vend_type");
		session.removeAttribute("sess_vend_code");			    
	}	
	
%>