<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="be.telio.mediastore.ui.upload.MonitoredDiskFileItemFactory" %>
<%@ page import="be.telio.mediastore.ui.upload.UploadListener" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.DiskFileUpload" %>


<%@ page import="org.apache.commons.fileupload.FileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.FileUploadException" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="serv.model.ListInfOpenJobBean" %>
<%@ page import="serv.model.ServInfOpenJobBean" %>
<%@page import="com.lh.util.doString"%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
/* Licence:
*   Use this however/wherever you like, just don't blame me if it breaks anything.
*
* Credit:
*   If you're nice, you'll leave this bit:
*
*   Class by Pierre-Alexandre Losson -- http://www.telio.be/blog
*   email : plosson@users.sourceforge.net
*/
--%>

<%
    UploadListener listener = new UploadListener(request,(long) 30);
    FileItemFactory factory = new MonitoredDiskFileItemFactory(listener);
    ServletFileUpload upload = new ServletFileUpload(factory);
	DiskFileUpload fileUpload = new DiskFileUpload(); 
	boolean exists = false;

    try
    {
        // process uploads ..
        //upload.parseRequest(request);

		List items = upload.parseRequest(request);
		Iterator itr = items.iterator(); 
		FileItem item;
		Random rand = new Random();
		ArrayList listBean = new ArrayList();
		
		String sessionId = (String) session.getAttribute("session_upload_id");
		if (sessionId==null) sessionId = "";
		if (sessionId.trim().length()<=0) {
			while (sessionId.length()<5) {
				 sessionId += rand.nextInt(10); 
			 }
			 session.setAttribute("session_upload_id",sessionId);
		}
		String itemNo = (String) session.getAttribute("itemNo");
		itemNo = doString.checkString(itemNo);
		String keyFile = (String) session.getAttribute("key_file");
System.out.println("Upload itemNo : "+itemNo);		
		ServInfOpenJobBean openJobBean = (ServInfOpenJobBean)request.getSession().getAttribute("listOpenJob");
		if(openJobBean!=null){
			listBean = openJobBean.getListInfBoq();
		}
/*		
		for(int j=0; j<listBean.size(); j++){
		}
*/		
		String realPath = getServletContext().getRealPath("/") + "/attach/temp/"+sessionId;
		File chkPath = new File(realPath);
		if (!chkPath.exists()) {
			chkPath.mkdirs();
		}

		while(itr.hasNext()){ 
				item = (FileItem) itr.next();
				String fieldName = doString.checkString(item.getFieldName());
System.out.println("fieldName : "+fieldName);
				if(!item.isFormField()){ 
					if(item.getSize() > 0){ 
						File fullFile = new File(item.getName()); 
						String file_name = fullFile.getName(); //Unicode String
						String new_file_name = "file"+keyFile;
						
						int i = -1;
						if (!itemNo.equals("")) {
							i = Integer.parseInt(itemNo);
						}
						
						
						if (file_name.lastIndexOf("\\")>0) {
							file_name = file_name.substring(file_name.lastIndexOf("\\")+1);
						}

						if (file_name.lastIndexOf("/")>0) {
							file_name =file_name.substring(file_name.lastIndexOf("/")+1);
						}
						//---------- check extension file and add it --------//
						if (file_name.lastIndexOf(".")>0) {
							new_file_name += file_name.substring(file_name.lastIndexOf("."));
						}
						if ((listBean != null) && (i >= 0)) {
							ListInfOpenJobBean listInfOpenJobBean = (ListInfOpenJobBean)listBean.get(i);
							if(listInfOpenJobBean != null){
								listInfOpenJobBean.setFileName(new_file_name);
								listInfOpenJobBean.setItmFiName(new_file_name);
							}
							//---------- delete old file --------------//
							String oldName = (String) session.getAttribute("session_upload_"+fieldName);
							if (oldName!=null) {
								//File oldFile = new File(realPath,oldName);
								//if (oldFile.exists()) oldFile.delete();
							}
							//---------- start save file to temp -------------//
							File savedFile = new File(realPath,new_file_name); 
							item.write(savedFile); 
							session.setAttribute("session_realfile_"+fieldName, file_name);
							session.setAttribute("session_upload_"+fieldName, new_file_name);
						}
					}  // end if
				} // end if  check is file , not fields

		} //while


    }
    catch (FileUploadException e)
    {
		System.out.println("Error : "+e.getMessage());
        e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
    }
%>
<html>
<head><title>Done</title></head>
<body>
<script>
   <%
      if (!exists) {
		  %>
		  /*window.returnValue="OK";*/
		  window.opener.postMessage('OK', '*');
		  <% 
	  } else {
           %>alert("File already exists !!");<%
	  }
   %>
   window.close();
</script>
</body>
</html>