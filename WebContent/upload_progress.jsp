<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="be.telio.mediastore.ui.upload.MonitoredDiskFileItemFactory" %>
<%@ page import="be.telio.mediastore.ui.upload.UploadListener" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.DiskFileUpload" %>
<%@ page import="org.apache.commons.fileupload.FileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.FileUploadException" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="java.awt.Graphics2D" %>
<%@ page import="java.awt.image.BufferedImage" %>
<%@ page import="javax.imageio.*" %>
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
<%!
	private static BufferedImage resizeImage(BufferedImage originalImage, int type, double decrease){
            double mthW = Double.parseDouble(doString.displayNumber("#0", originalImage.getWidth())) / decrease;
            double mthH = Double.parseDouble(doString.displayNumber("#0", originalImage.getHeight())) / decrease;
                   
			 int parseW = Integer.parseInt(doString.displayNumber("#0", mthW));
			 int parseH = Integer.parseInt(doString.displayNumber("#0", mthH));
 			  BufferedImage resizedImage = new BufferedImage(parseW, parseH, type);
              Graphics2D g = resizedImage.createGraphics();
              //g.drawImage(originalImage, 0, 0, IMG_WIDTH, IMG_HEIGHT, null);
              g.drawImage(originalImage, 0, 0, parseW, parseH, null);
              g.dispose();
             return resizedImage;
    }
 %>

<%
 //****************************************

    UploadListener listener = new UploadListener(request,(long) 30);
    FileItemFactory factory = new MonitoredDiskFileItemFactory(listener);
    ServletFileUpload upload = new ServletFileUpload(factory);
	//DiskFileUpload fileUpload = new DiskFileUpload(); 
	boolean exists = false;
	String tempDoc = "";
    try
    {
        // process uploads ..
        //upload.parseRequest(request);

		List items = upload.parseRequest(request);
		Iterator itr = items.iterator(); 
		FileItem item;
		Random rand = new Random();

		String sessionId = (String) session.getAttribute("session_upload_id");
		if (sessionId==null) sessionId = "";
		if (sessionId.trim().length()<=0) {
			while (sessionId.length()<5) {
				 sessionId += rand.nextInt(10); 
			 }
			 session.setAttribute("session_upload_id",sessionId);
		}


		String realPath = getServletContext().getRealPath("/pictures/temp/")+File.separator+sessionId;
		//System.out.println("Real_Paht :"+realPath);
		File chkPath = new File(realPath);
		if (!chkPath.exists()) {
			chkPath.mkdirs();
		}

		while(itr.hasNext()){ 
				item = (FileItem) itr.next();
				String fieldName = item.getFieldName();

				if(!item.isFormField()){ 
					if(item.getSize() > 0){ 
						File fullFile = new File(item.getName()); 
						
						double bytes = fullFile.length();
						double kilobytes = (bytes / 1024);
						double megabytes = (kilobytes / 1024);
			
						String file_name = fullFile.getName();
						String new_file_name = "img_"+fieldName;
						tempDoc = new_file_name;
						//System.out.println("-->new_file_name :"+new_file_name);

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
						//---------- delete old file --------------//
						String oldName = (String) session.getAttribute("session_upload_"+fieldName);
						if (oldName!=null) {
							//File oldFile = new File(realPath,oldName);
							//if (oldFile.exists()) oldFile.delete();
						}
						
						//---------- start save file to temp -------------//
						//System.out.println("megabytes : " + megabytes);
						if(megabytes>1.0){

							//System.out.println("-------Compresser Images ");
							File savedFile = new File(realPath,"n_"+new_file_name); 
							item.write(savedFile); 	
							
							BufferedImage originalImage = ImageIO.read(savedFile);   
                   
			                int pictype = originalImage.getType() == 0? BufferedImage.TYPE_INT_ARGB : originalImage.getType();
			                int curW = originalImage.getWidth();
			                int curH = originalImage.getHeight();
			
			                if (curW > 1024 || curH > 768) {
			                     double per_dec = 0;
			                     if ((curW - 768) >= (curH - 768)) {
			                         per_dec = curW / 1024;                                                                                
			                     } else {
			                         per_dec = curH / 768;
			                     }
			                     double iDec = Double.parseDouble(doString.displayNumber("#0", per_dec));                                                                                 
			                   BufferedImage resizeImageJpg = resizeImage(originalImage, pictype, iDec);
			                   ImageIO.write(resizeImageJpg, "jpg", new File(realPath,new_file_name));
			                   savedFile.delete();
			                } // End if pic size > limit
						}else{
						    //Not Compresor
						   	File savedFile = new File(realPath,new_file_name); 
							item.write(savedFile); 	
							//System.out.println("-------Not Compresser ");			
						}

						session.setAttribute("session_realfile_"+fieldName,file_name);						
						//System.out.println("1.session_realfile_ : fieldName:"+fieldName);
						//System.out.println("1.session_realfile_ : file_name:"+file_name);
						
						session.setAttribute("session_upload_"+fieldName,new_file_name);						
						//System.out.println("2.session_upload_:"+fieldName);
						//System.out.println("2.session_upload_:"+new_file_name);
					}  // end if
				} // end if  check is file , not fields
		} //while
    }catch (FileUploadException e){
		System.err.println(tempDoc+",Error!! : "+e.getMessage());
        e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
    }
%>
<html>
<head><title>Done</title></head>
<body>
<script>
   <%
      if (!exists) {
		  %>window.returnValue="OK";<% 
	  } else {
           %>alert("File already exists !!");<%
	  }
   %>
   window.close();
</script>
</body>
</html>