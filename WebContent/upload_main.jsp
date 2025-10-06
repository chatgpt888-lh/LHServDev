<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>

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
   String sessionId = request.getParameter("session_id");
   if (sessionId==null) sessionId = "";
   session.setAttribute("session_upload_id",sessionId);

   String keyFile = request.getParameter("key_file");

%>



<HTML>
<HEAD>
<TITLE>Attach File</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script src='resources/js/upload.js'> </script>
<script src='dwr/interface/UploadMonitor.js'> </script>
<script src='dwr/engine.js'> </script>
<script src='dwr/util.js'> </script>
<style type="text/css">
	body { font: 11px Lucida Grande, Verdana, Arial, Helvetica, sans serif; }
	#progressBar { padding-top: 5px; }
	#progressBarBox { width: 350px; height: 20px; border: 1px inset; background: #eee;}
	#progressBarBoxContent { width: 0; height: 20px; border-right: 1px solid #444; background: #3264C8; }
</style>
</HEAD>

<SCRIPT LANGUAGE="JavaScript">
<!--
	
function checkFileExt() {
	for (var idx=1;idx<=6;idx++) {
			var file = document.forms[0].elements("file"+idx);
			if (file!=null) {
				var fileName = file.value;
				if (fileName=="") return true;

				if (fileName.lastIndexOf(".")>0) {
					var ext = fileName.substring(fileName.lastIndexOf(".")+1).toUpperCase();
					if (ext!="GIF" && ext!="JPG") {
						alert(" ไฟล์ที่ upload ต้องเป็น .gif หรือ .jpg เท่านั้น !! ");
						return false;
					}
				} else {
					alert(" ไฟล์ที่ upload ต้องเป็น .gif หรือ .jpg เท่านั้น !! ");
					return false;
				}
			}
	} // end for

	return true;
}

function startupload() {
	var show = document.getElementById("show_wait");
	show.style.height="120px";
	show.style.width="300px";

	var show = document.getElementById("show_msg");
	show.style.height="118px";
	show.style.width="298px";
	show.innerHTML = "<br><br><center>Upload in progress.<br>Don\'t close window until progress complete. <br><br><img src='images/loading.gif'></center>";

	document.body.style.cursor="progress";
}

//-->
</SCRIPT>


<BODY topmargin="0" leftmargin="0">

<!--FORM action="upload_progress.jsp" enctype="multipart/form-data" method="post" onsubmit="if (checkFileExt('1') &&checkFileExt('2')) startProgress(); else return false; "-->

<FORM action="upload_progress.jsp" enctype="multipart/form-data" method="post" onsubmit="if (checkFileExt()) startupload(); else return false; ">

<span id="show_wait" style="position:absolute;background-color:black;top:95px;left:50px;z-index:10;width:0px;height:0px"></span>
<span id="show_msg" style="position:absolute;background-color:white;top:96px;left:51px;z-index:11;width:0px;height:0px">
</span>

<TABLE BORDER='0' CELLPADDING='5' CELLSPACING='2' width="390px" height="100px" valign="top">
  <TR><TD align="left" COLSPAN='7'><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;A t t a c h &nbsp; F i l e</TD></TR>

  <TR>
    <TD  width="380px"  height="100px" bgColor="#DCF0FF"><FONT face="MS Sans Serif" color="#0032FF" valign="top" align="center" >

		<center>
		<table>
			<tr><td><nobr>รูปภาพก่อนซ่อม 1 : </nobr></td><td><input type="file" id="file1" name="before_<%=keyFile%>" class="box" style="width:250px;"  /></td></tr>
			<tr><td><nobr>รูปภาพก่อนซ่อม 2 : </nobr></td><td><input type="file" id="file2" name="before2_<%=keyFile%>" class="box" style="width:250px;"  /></td></tr>
		</table>
		<hr width="80%">
		<table>
			<tr><td><nobr>รูปภาพระหว่างซ่อม 1 : </nobr></td><td><input type="file" id="file3" name="process_<%=keyFile%>" class="box" style="width:250px;"  /></td></tr>
			<tr><td><nobr>รูปภาพระหว่างซ่อม 2 : </nobr></td><td><input type="file" id="file4" name="process2_<%=keyFile%>" class="box" style="width:250px;"  /></td></tr>
		</table>
		<hr width="80%">
		<table>
			<tr><td><nobr>รูปภาพหลังซ่อม 1 : </nobr></td><td><input type="file" id="file5" name="after_<%=keyFile%>" class="box" style="width:250px;"  /></td></tr>
			<tr><td><nobr>รูปภาพหลังซ่อม 2 : </nobr></td><td><input type="file" id="file6" name="after2_<%=keyFile%>" class="box" style="width:250px;"  /></td></tr>
		</table>
        <br/>
        <input type="submit" value=" Attach File " id="uploadbutton" class="box" style="width:100px ; height:17px ; cursor:hand" /> &nbsp;
        <input type="button" value=" Cancel " id="cancelbutton" class="box" style="width:100px ; height:17px ; cursor:hand" onclick="window.close();" />
		</center>
		<!--
		<table height="80px"><tr><td>
        <br/>
        <div id="progressBar" style="display: none;">
            <div id="theMeter">
                <div id="progressBarText"></div>
                <div id="progressBarBox">
                    <div id="progressBarBoxContent"></div>
                </div>
            </div>
        </div>
		<br />
		</td></tr></table>
		-->
	</FONT></TD>
  </TR>
<TR>
<TD></TD>
</TR>
</TABLE>
      <TABLE border="0"  width="390px" cellspacing="0" cellpadding="0" height="30">
        <TBODY>
          <TR>
            <TD width="5" valign="top"><IMG border="0" src="images/b3_tab1.gif" width="6" height="30"></TD>
            <TD width="75" background="images/b3_tab2.gif" style="background-repeat : repeat-x" valign="top"></TD>
            <TD width="57" valign="top"><IMG border="0" src="images/b3_tab3.gif" width="57" height="30"></TD>
            <TD background="images/b3_tab4.gif" style="background-repeat : repeat-x" valign="middle">
            <P align="right">&nbsp;&nbsp;<A href="javascript:top.window.close()"><IMG border="0" src="images/bu_close.gif" width="50" height="15"></A></P>
            </TD>
          </TR>
        </TBODY>
      </TABLE>

</FORM>
</BODY>
</HTML>


