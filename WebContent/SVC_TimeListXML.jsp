<?xml version="1.0" encoding="TIS-620" ?>
<%@page contentType="text/xml; charset=TIS-620"%>
<%		com.svc.call.dao.services.Common.setConfigForConnectionPool("",com.svc.call.utilize.Constant.DataSourceName);
		java.sql.Connection conn = null;	
		StringBuffer buffer = new StringBuffer();
		/********** Connection DB *************/
		conn = com.svc.call.dao.services.Common.open();
		com.svc.call.dao.services.Common.defaultTransaction(conn);
		/********** Connection DB *************/
	    String projectDDL =  com.lh.util.doString.checkString(request.getParameter("projectDDL"),"");
		String dateAppoint = com.lh.util.doString.checkString(request.getParameter("dateDDL"),"");

		String tempStr[] = projectDDL.split("\\:");
		//System.out.println("-->productTypeDDL :"+productTypeId);
        	
		com.svc.call.dao.services.ServiceCenterCallService  callService = new com.svc.call.dao.services.ServiceCenterCallServiceImpl();
		java.util.List listTimeDDL = callService.ListAppointTime$1SVC(conn,tempStr[0],tempStr[1],com.svc.call.utilize.Constant.DATE_TYPE_02,dateAppoint);
		
		//close connection
		com.svc.call.dao.services.Common.close(conn);

		if(listTimeDDL!=null ){
				java.util.List strList = null;
				//System.out.println("List--->ProjectNameDDL :"+ProjectNameDDL.size());	
				java.util.Iterator it = listTimeDDL.iterator();
				//buffer.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
				buffer.append("\n");
				buffer.append("<root>");
				buffer.append("\n");
				while(it.hasNext()){								
					strList =(java.util.ArrayList)it.next();										
					buffer.append("<labelValueBean>");
					buffer.append("\n");
					buffer.append("<label>"+strList.get(0).toString()+"</label>");
					buffer.append("\n");
					buffer.append("<value>"+strList.get(0).toString()+"</value>");
					buffer.append("\n");
					buffer.append("</labelValueBean>");					
				}
				buffer.append("\n");
				buffer.append("</root>");
			}
	/***********************************************/
	//System.out.println(buffer.toString());
	response.addHeader("Content-Type", "text/xml");
	response.setContentType("text/xml; charset=TIS-620");
	out.write(buffer.toString());
%>