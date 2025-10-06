<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="serv.common.User"%>
<%@ page import="serv.common.SERV_CommonData"%>
<%@ page import="serv.common.Constants"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ include file="function.jsp" %>

<%!
/**
 * Modify by : pradoem@lh.co.th
 * date : 2017.05.23
 * version 1.1
 * desc: Verify your SVC Account from table lan:svc_agent 
 * for grant permission menu SVC
 */ 
  public boolean IsGrantPermissionSvc(Connection conn,String employId){
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        String tempId = "";
        boolean isRecord = false;
        try {
            stmt = conn.createStatement();
  			sql.delete(0, sql.length());
			sql.append(" select i_employ from lan:svc_agent ")
				.append(" where i_employ = '"+employId+"' ");
				//System.out.println("SQL  :"+sql.toString());
				rs = stmt.executeQuery(sql.toString());    				   
			    if(rs.next()){
			       tempId  = doString.checkString(rs.getString("i_employ"),"");
			       isRecord = true;
			    } 		
                rs.close();
                stmt.close();
                
        }catch(Exception e) {
            System.out.println(" IsGrantPermissionSvc Error : " + e.getMessage());
        } finally{
            try  {
                if(rs != null) {
                    rs.close();
                }
                if(stmt != null){
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return isRecord;
    } 
 %>
<%
	User user = (User)session.getAttribute("USER");
	if (user == null) {
	    user  = new User();
	    user.setUserWho(Constants.PERMISSION_VENDOR);
	}
	String user_group = doString.checkString(user.getUserGroup());

	String turnkey = "";   // S
	String emp_id = user.getEmpId();
	
	if (emp_id.length() > 2) {
			System.out.println("emp_id=="+emp_id);
		turnkey = emp_id.substring(0,1);
	} 

	System.out.println("turnkey=="+turnkey);
%>

<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<meta http-equiv="Content-Language" content="th">

<title>TopMenu</title>

<link rel="STYLESHEET" type="text/css" href="SERV_Style.css">
<script src="script_fx.js" type="text/javascript"></script>

<base target="main">

</head>
<%
Connection conn = null;
boolean isSvc = false;
try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
        //----=======================================----//   
        isSvc = IsGrantPermissionSvc(conn,emp_id);
        //-------Clean connection
        conn.close();
        conn = null;
} catch (Exception e) {
		System.out.println("ERROR SERV_CompTask_List.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
	
	System.out.println("isSvc : "+isSvc);
 %>
<body topmargin="0" leftmargin="0" scroll="no" style="background-color: rgb(229,240,253)">

<SCRIPT language=JavaScript1.2 src="MenuLibrary.js"></SCRIPT>

<SCRIPT>
var bw=new lib_bwcheck() //Making browsercheck object

var mDebugging=2 //General debugging variable. Set to 0 for no debugging, 1 for alerts or 2 for status debugging.

oCMenu=new makeCoolMenu("oCMenu") //Making the menu object. Argument: menuname
oCMenu.useframes=1 //Do you want to use the menus as coolframemenu or not? (in frames or not) - Value: 0 || 1
oCMenu.frame="main" //The name of your main frame (where the menus should appear). Leave empty if you're not using frames - Value: "main_frame_name"

oCMenu.useclick= 0 //If you want the menu to be activated and deactivated onclick only set this to 1. - Value: 0 || 1

/*If you set this to 1 you will get a "hand" cursor when moving over the links in NS4. 
NOTE: This does not apply to the submenus if the menu is used in frames due some mayor problems with NS4*/
oCMenu.useNS4links=1 

//After adding the "hover effect" for netscape as well, all styles are lost. But if you want padding add it here.
oCMenu.NS4padding=0

//If you have select boxes close to your menu the menu will check for that and hide them if they are in the way of the menu.
//This feature does unfortunatly not work in NS4!
oCMenu.checkselect=1

/*If you choose to have this code inside a linked js, or if your using frames it's important to set these variables. 
This will help you get your links to link to the right place even if your files are in different folders.
The offlineUrl variable is the actual path to the directory where you js file are locally. 
This is just so you can test it without uploading. Remember to start it with file:/// and only use slashes, no backward slashes!
Also remember to end with a slash                                                                                                 */
oCMenu.offlineUrl="file:///C|/Inetpub/wwwroot/dhtmlcentral/" //Value: "path_to_menu_file_offline/"
//The onlineUrl variable is the online path to your script. Place in the full path to where your js file is. Remember to end with a slash.
oCMenu.onlineUrl="http://www.dhtmlcentral.com/coolmenus/examples/withoutframes/" //Value: "path_to_menu_file_online/"

oCMenu.pagecheck=1 //Do you want the menu to check whether any of the subitems are out of the bouderies of the page and move them in again (this is not perfect but it hould work) - Value: 0 || 1
oCMenu.checkscroll=1 //Do you want the menu to check whether the page have scrolled or not? For frames you should always set this to 1. You can set this to 2 if you want this feature only on explorer since netscape doesn't support the window.onscroll this will make netscape slower (only if not using frames) - Value: 0 || 1 || 2
oCMenu.resizecheck=1 //Do you want the page to reload if it's resized (This should be on or the menu will crash in Netscape4) - Value: 0 || 1
oCMenu.wait=1000 //How long to wait before hiding the menu on mouseout. Netscape 6 is a lot slower then Explorer, so to be sure that it works good enough there you should not have this lower then 500 - Value: milliseconds

//Background bar properties
oCMenu.usebar=0 //If you want to use a background-bar for the top items set this on - Value: 1 || 0
oCMenu.barcolor="Navy" //The color of the background bar - Value: "color"
oCMenu.barwidth="100%" //The width of the background bar. Set this to "menu" if you want it to be the same width as the menu. (this will change to match the border if you have one) - Value: px || "%" || "menu"
oCMenu.barheight="menu" //The height of the background bar. Set this to "menu" if you want it to be the same height as the menu. (this will change to match the border if you have one) - Value: px || "%" || "menu"
oCMenu.barx=0 //The left position of the bar. Set this to "menu" if you want it be the same as the left position of the menu. (this will change to match the border if you have one)  - Value: px || "%" || "menu"
oCMenu.bary=0 //The top position of the bar Set this to "menu" if you want it be the same as the top position of the menu. (this will change to match the border if you have one)  - Value: px || "%" || "menu"
oCMenu.barinheritborder=0 //Set this to 1 if you want the bar to have the same border as the top menus - Value: 0 || 1

//Placement properties
oCMenu.rows=1 //This controls whether the top items is supposed to be laid out in rows or columns. Set to 0 for columns and 1 for row - Value 0 || 1
oCMenu.fromleft=0 //This is the left position of the menu. (Only in use if menuplacement below is 0 or aligned) (will change to adapt any borders) - Value: px || "%"
oCMenu.fromtop=38 //This is the left position of the menu. (Only in use if menuplacement below is 0 or aligned) (will change to adapt any borders) - Value: px || "%"
oCMenu.pxbetween=0 //How much space you want between each of the top items. - Value: px || "%"

oCMenu.menuplacement="left"

oCMenu.level[0]=new Array() //Add this for each new level
oCMenu.level[0].width=280 //The default width for each level[0] (top) items. You can override this on each item by spesifying the width when making the item. - Value: px || "%"
oCMenu.level[0].height=22 //The default height for each level[0] (top) items. You can override this on each item by spesifying the height when making the item. - Value: px || "%"
oCMenu.level[0].bgcoloroff="rgb(255,230,200)" //The default background color for each level[0] (top) items. You can override this on each item by spesifying the backgroundcolor when making the item. - Value: "color"
oCMenu.level[0].bgcoloron="rgb(80,120,255)" //The default "on" background color for each level[0] (top) items. You can override this on each item by spesifying the "on" background color when making the item. - Value: "color"
oCMenu.level[0].textcolor="rgb(0,70,200)" //The default text color for each level[0] (top) items. You can override this on each item by spesifying the text color when making the item. - Value: "color"
oCMenu.level[0].hovercolor="rgb(255,255,255)" //The default "on" text color for each level[0] (top) items. You can override this on each item by spesifying the "on" text color when making the item. - Value: "color"
oCMenu.level[0].style="padding:0px; font-size:12px; " //The style for all level[0] (top) items. - Value: "style_settings"
oCMenu.level[0].border=0 //The border size for all level[0] (top) items. - Value: px
oCMenu.level[0].bordercolor="white" //The border color for all level[0] (top) items. - Value: "color"
oCMenu.level[0].offsetX=0 //The X offset of the submenus of this item. This does not affect the first submenus, but you need it here so it can be the default value for all levels. - Value: px
oCMenu.level[0].offsetY=0 //The Y offset of the submenus of this item. This does not affect the first submenus, but you need it here so it can be the default value for all levels. - Value: px
oCMenu.level[0].NS4font="tahoma,arial,helvetica"
oCMenu.level[0].NS4fontSize="2"

/*New: Added animation features that can be controlled on each level.*/
oCMenu.level[0].clip=1 //Set this to 1 if you want the submenus of this level to "slide" open in a animated clip effect. - Value: 0 || 1
oCMenu.level[0].clippx=15 //If you have clip spesified you can set how many pixels it will clip each timer in here to control the speed of the animation. - Value: px 
oCMenu.level[0].cliptim=50 //This is the speed of the timer for the clip effect. Play with this and the clippx to get the desired speed for the clip effect (be carefull though and try and keep this value as high or possible or you can get problems with NS4). - Value: milliseconds
//Filters - This can be used to get some very nice effect like fade, slide, stars and so on. EXPLORER5.5+ ONLY - If you set this to a value it will override the clip on the supported browsers
oCMenu.level[0].filter="progid:DXImageTransform.Microsoft.Fade(duration=0.5)" //VALUE: 0 || "filter specs"

/*Different filter specs you can try:
oCMenu.level[0].filter="progid:DXImageTransform.Microsoft.Wheel(duration=0.5,spokes=5)"
oCMenu.level[0].filter="progid:DXImageTransform.Microsoft.Barn(duration=0.5,orientation=horizontal)"
oCMenu.level[0].filter="progid:DXImageTransform.Microsoft.Blinds(duration=0.5,bands=5)"
oCMenu.level[0].filter="progid:DXImageTransform.Microsoft.CheckerBoard(duration=0.5)"
oCMenu.level[0].filter="progid:DXImageTransform.Microsoft.Fade(duration=0.5)"
oCMenu.level[0].filter="progid:DXImageTransform.Microsoft.GradientWipe(duration=0.5,wipeStyle=0)"
oCMenu.level[0].filter="progid:DXImageTransform.Microsoft.Iris(duration=0.5,irisStyle=STAR)"
oCMenu.level[0].filter="progid:DXImageTransform.Microsoft.Iris(duration=0.5,irisStyle=CIRCLE)"
oCMenu.level[0].filter="progid:DXImageTransform.Microsoft.Pixelate(duration=0.5,maxSquare=40)"
oCMenu.level[0].filter="progid:DXImageTransform.Microsoft.RadialWipe(duration=0.5)"
oCMenu.level[0].filter="progid:DXImageTransform.Microsoft.RandomBars(duration=0.5,orientation=vertical)"
oCMenu.level[0].filter="progid:DXImageTransform.Microsoft.RandomDissolve(duration=0.5)"
oCMenu.level[0].filter="progid:DXImageTransform.Microsoft.Spiral(duration=0.5)"
oCMenu.level[0].filter="progid:DXImageTransform.Microsoft.Stretch(duration=0.5,stretchStyle=push)"
oCMenu.level[0].filter="progid:DXImageTransform.Microsoft.Strips(duration=0.5,motion=rightdown)"
*/

oCMenu.level[0].align="bottom" //Value: "top" || "bottom" || "left" || "right" 

oCMenu.level[1]=new Array()
oCMenu.level[2]=new Array() 
oCMenu.level[2].offsetX=-100
oCMenu.level[2].offsetY=10 


// Argument 1.name,  2.parent, 3.text, 4.link, 5.target, 6.width, 7.height, 8.img1, 9.img2, 10.bgcoloroff, 11.bgcoloron,
//                     12.textcolor, 13.hovercolor, 14.onclick, 15.onmouseover, 16.onmouseout

		
		oCMenu.makeMenu('MenuRoot','','','','',192,10,'/LHServ/images/top_menu.gif','/LHServ/images/top_menu_over.gif')
<% if (user_group.equals("I")) {%>
		oCMenu.makeMenu('Menu13.0','MenuRoot','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">สัญญางานบริการ','','','','','','','rgb(200,230,255)' )	
		oCMenu.makeMenu('Menu13.1','Menu13.0','<img src="images/i_home_14.gif" hspace="5">รายละเอียดสัญญา','SERV_ConHome.jsp','','250','','','','rgb(200,230,255)' )
		oCMenu.makeMenu('Menu13.2','Menu13.0','<img src="images/i_home_14.gif" hspace="5">เบิกงวดตามสัญญา','SERV_ConCompTask_List.jsp','','250','','','','rgb(170,210,250)' )
		oCMenu.makeMenu('Menu13.3','Menu13.0','<img src="images/i_home_14.gif" hspace="5">พิมพ์ใบเบิกงวด','SERV_ConReprint_Pay_List.jsp','','250','','','','rgb(200,230,255)' )
		oCMenu.makeMenu('Menu13.4','Menu13.0','<img src="images/i_home_14.gif" hspace="5">ยกเลิกใบเบิกงวด','SERV_ConDeny_Pay_List.jsp','','250','','','','rgb(170,210,250)' )
<%}%>		
		
<%
	   if (!user.getUserWho().equalsIgnoreCase(Constants.PERMISSION_VENDOR) || 
			user.getUserWho().equalsIgnoreCase(Constants.PERMISSION_CENTER) || 
			user.getUserWho().equalsIgnoreCase(Constants.PERMISSION_STAFF) || 
			user.getUserWho().equalsIgnoreCase(Constants.PERMISSION_VP) || 
			user.getUserWho().equalsIgnoreCase(Constants.PERMISSION_ADMIN) || 
			user.getUserWho().equalsIgnoreCase("T") ||
			user.getUserWho().equalsIgnoreCase("J") ||
			user.getUserWho().equalsIgnoreCase("G")) {
				System.out.println("in .....case");
%>
		oCMenu.makeMenu('Menu0.0','MenuRoot','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">ใบแจ้งซ่อม','','','','','','','rgb(170,210,250)' )	
<%

	if (user.getUserWho().equalsIgnoreCase("G")) {
%>
				oCMenu.makeMenu('Menu0.5','Menu0.0','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">รายงาน Service บ้าน','','','','','','','rgb(200,230,255)' )	
				oCMenu.makeMenu('Menu0.6','Menu0.0','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">รายงาน Service สาธารณูฯ (ส่วนกลาง)','','','','','','','rgb(170,210,250)' )	
				oCMenu.makeMenu('Menu0.9','Menu0.0','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">รายงาน Service สาธารณะ','','','','','','','rgb(200,230,255)' )	

				//oCMenu.makeMenu('Menu0.1','Menu0.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">แก้ไขรายละเอียดใบแจ้งซ่อม','SERV_Reprint_List.jsp','','','','','','rgb(170,210,250)' )	

<%
	} else if (user.getUserWho().equalsIgnoreCase(Constants.PERMISSION_STAFF)) {	

%>
				oCMenu.makeMenu('Menu0.1','Menu0.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">แก้ไขรายละเอียดใบแจ้งซ่อม','SERV_Reprint_List.jsp','','','','','','rgb(200,230,255)' )	
				oCMenu.makeMenu('Menu0.2','Menu0.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">พิมพ์ใบแจ้งซ่อมแก้ไขโดยผู้รับเหมา','SERV_Reprint_Pay_List.jsp','','','','','','rgb(170,210,250)' )	
				oCMenu.makeMenu('Menu0.3','Menu0.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">ขออนุมัติรายการ BOQ','SERV_BOQCode01.jsp','','','','','','rgb(200,230,255)' )	
				oCMenu.makeMenu('Menu0.8','Menu0.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">บันทึกเบิกงวดงานบ้าน อื่นๆ','SERV_POthPayLst.jsp','','','','','','rgb(170,210,250)' )	
				oCMenu.makeMenu('Menu0.7','Menu0.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">บันทึกเบิกงวดงานสาธารณูฯ และงานสาธารณะอื่นๆ','SERV_OthPayLst.jsp','','','','','','rgb(170,210,250)' )	
				
<%  if(!turnkey.equals("S")) {   %>
				oCMenu.makeMenu('Menu0.4','Menu0.0','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">ข้อมูลพื้นฐาน','','','','','','','rgb(200,230,255)' )	
				oCMenu.makeMenu('Menu0.4.1','Menu0.4','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายละเอียดผู้รับเหมาซ่อมภายในโครงการ','<%=Constants.APP_PATH%>/SERV_VenPrj.jsp','','','','','','rgb(170,210,250)' )	
<% 
	}  // end if turnkey  
%>

				oCMenu.makeMenu('Menu0.5','Menu0.0','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">รายงาน Service บ้าน','','','','','','','rgb(200,230,255)' )	
				oCMenu.makeMenu('Menu0.6','Menu0.0','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">รายงาน Service สาธารณูฯ(ส่วนกลาง)','','','','','','','rgb(170,210,250)' )	
				oCMenu.makeMenu('Menu0.9','Menu0.0','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">รายงาน Service สาธารณะ','','','','','','','rgb(200,230,255)' )	
<%	   
		   } else {   
				if(!user.getUserWho().equalsIgnoreCase("G")) {

%>					oCMenu.makeMenu('Menu0.1','Menu0.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">แก้ไขรายละเอียดใบแจ้งซ่อม','SERV_Reprint_List.jsp','','','','','','rgb(170,210,250)' )	
 <%				
				}
if (!user.getUserWho().equalsIgnoreCase("J"))   {
%>				
				oCMenu.makeMenu('Menu0.2','Menu0.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">พิมพ์ใบแจ้งซ่อมแก้ไขโดยผู้รับเหมา','SERV_Reprint_Pay_List.jsp','','','','','','rgb(170,210,250)' )	
				oCMenu.makeMenu('Menu0.3','Menu0.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">ขออนุมัติรายการ BOQ','SERV_BOQCode01.jsp','','','','','','rgb(200,230,255)' )	
				oCMenu.makeMenu('Menu0.8','Menu0.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">บันทึกเบิกงวดงานบ้าน อื่นๆ','SERV_POthPayLst.jsp','','','','','','rgb(170,210,250)' )	
				oCMenu.makeMenu('Menu0.7','Menu0.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">บันทึกเบิกงวดงานสาธารณูฯ และงานสาธารณะอื่นๆ','SERV_OthPayLst.jsp','','','','','','rgb(170,210,250)' )	
				
				oCMenu.makeMenu('Menu0.4','Menu0.0','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">ข้อมูลพื้นฐาน','','','','','','','rgb(200,230,255)' )	
				oCMenu.makeMenu('Menu0.4.1','Menu0.4','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายละเอียดผู้รับเหมาซ่อมภายในโครงการ','<%=Constants.APP_PATH%>/SERV_VenPrj.jsp','','','','','','rgb(170,210,250)' )	
<%
if (user.getUserWho().equalsIgnoreCase("C") || user.getUserWho().equalsIgnoreCase("A") || user.getUserID().equals("sanya"))   {
%>
				oCMenu.makeMenu('Menu0.4.2','Menu0.4','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายละเอียดข้อมูลพื้นฐานเพื่อใช้ในระบบ','<%=Constants.APP_PATH%>/SERV_XStd01.jsp','','','','','','rgb(200,230,255)' )	
				oCMenu.makeMenu('Menu0.4.3','Menu0.4','<img src="/LHServ/images/i_home_14.gif" hspace="5">ตารางการจ่ายเงินผู้รับเหมา','<%=Constants.APP_PATH%>/SERV_PaySchd01.jsp','','','','','','rgb(170,210,250)' )	
				oCMenu.makeMenu('Menu0.4.4','Menu0.4','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายละเอียดโครงการที่รับผิดชอบ','<%=Constants.APP_PATH%>/SERV_PStaff01.jsp','','','','','','rgb(200,230,255)' )	
				oCMenu.makeMenu('Menu0.4.9','Menu0.4','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายละเอียดประเภทการจัดสรร','<%=Constants.APP_PATH%>/SERV_INFAllot.jsp','','','','','','rgb(170,210,250)' )	

<%
} // end if == C
		
				if (user.getUserID().equals("wiranid")) { 
		%>	
						oCMenu.makeMenu('Menu0.4.5','Menu0.4','<img src="/LHServ/images/i_home_14.gif" hspace="5">ข้อมูลราคา BOQ จากส่วนกลาง','<%=Constants.APP_PATH%>/SERV_ConBOQ01.jsp?flag=C','','','','','','rgb(170,210,250)' )	
			
		<%	} else if (user.getUserID().equals("kajonyos") || user.getUserID().equals("watinee")) {    %>
		
					oCMenu.makeMenu('Menu0.4.5','Menu0.4','<img src="/LHServ/images/i_home_14.gif" hspace="5">ข้อมูลราคา BOQ จากส่วนกลาง','<%=Constants.APP_PATH%>/SERV_ConBOQ01.jsp?flag=N','','','','','','rgb(170,210,250)' )	
		
		<%	} else if (user.getUserID().equals("prasong")) {    %>
		
					oCMenu.makeMenu('Menu0.4.5','Menu0.4','<img src="/LHServ/images/i_home_14.gif" hspace="5">ข้อมูลราคา BOQ จากส่วนกลาง','<%=Constants.APP_PATH%>/SERV_ConBOQ01.jsp?flag=E','','','','','','rgb(170,210,250)' )	
		
		<%  } else if (user.getUserWho().equalsIgnoreCase("C") || user.getUserWho().equalsIgnoreCase("A"))   {%>
						
					oCMenu.makeMenu('Menu0.4.5','Menu0.4','<img src="/LHServ/images/i_home_14.gif" hspace="5">ข้อมูลราคา BOQ จากส่วนกลาง','<%=Constants.APP_PATH%>/SERV_BOQ01.jsp','','','','','','rgb(170,210,250)' )	
					oCMenu.makeMenu('Menu0.4.8','Menu0.4','<img src="/LHServ/images/i_home_14.gif" hspace="5">ข้อมูลราคา BOQ สาธารณูจากส่วนกลาง','<%=Constants.APP_PATH%>/SERV_INFBOQ01.jsp','','','','','','rgb(200,230,255)' )	
					oCMenu.makeMenu('Menu0.4.12','Menu0.4','<img src="/LHServ/images/i_home_14.gif" hspace="5">Follow up ข้อมูลโครงการ','<%=Constants.APP_PATH%>/SERV_LStaffServlet?cmd=makeList','','','','','','rgb(170,210,250)' )	
					
		
		<%  } %>				

			<%	if (user.getUserID().equals("chawengk")) {    %>
						oCMenu.makeMenu('Menu0.4.8','Menu0.4','<img src="/LHServ/images/i_home_14.gif" hspace="5">ข้อมูลราคา BOQ สาธารณูจากส่วนกลาง','<%=Constants.APP_PATH%>/SERV_INFBOQ01.jsp','','','','','','rgb(200,230,255)' )	
			<%  } %>				
			oCMenu.makeMenu('Menu0.4.6','Menu0.4','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายละเอียดการตัดเงินตามแปลง','<%=Constants.APP_PATH%>/SERV_CutLock01.jsp','','','','','','rgb(170,210,250)' )	


				<% if (user.getUserID().equals("maneerat")) { %>
								oCMenu.makeMenu('Menu0.4.7','Menu0.4','<img src="/LHServ/images/i_home_14.gif" hspace="5">กำหนดรหัสบัญชี','<%=Constants.APP_PATH%>/SERV_INFVenVt01.jsp','','','','','','rgb(170,210,250)' )	
				<%}%>

				<%-- pradoem 2014.10.12--%>
				<% if (user.getUserID().equals("lee")|| user.getUserID().equals("wimonwan") || user.getUserID().equals("techin")||user.getUserID().equals("chawengk")) { %>
						oCMenu.makeMenu('Menu0.4.10','Menu0.4','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายละเอียดเบอร์ติดต่อ(SMS EService)','<%=Constants.APP_PATH%>/SERV_SmsMasterServlet?cmd=search','','','','','','rgb(200,230,255)' )	
				<%}%>
				<%-- pradoem 2017.10.30--%>
				<% if (user.getUserID().equals("lee") || user.getUserID().equals("dwiparat") || user.getUserID().equals("techin") ||user.getUserID().equals("wimonwan") || user.getUserID().equals("wnittaya") || user.getUserID().equals("chawengk")) { %>
						oCMenu.makeMenu('Menu0.4.11','Menu0.4','<img src="/LHServ/images/i_home_14.gif" hspace="5">เพื่มรายชื่อช่าง Scan นิ้ว','<%=Constants.APP_PATH%>/AddFingerScanForm.jsp','','','','','','rgb(200,230,255)' )	
				<%}%>
				
				oCMenu.makeMenu('Menu0.4.13','Menu0.4','<img src="/LHServ/images/i_home_14.gif" hspace="5">ต่ออายุ Password Outsource','<%=Constants.APP_PATH%>/SERV_UpdatePwdOutsource.jsp','','','','','','rgb(170,210,250)' )	
				<% if (user.getUserID().equals("lee")|| user.getUserID().equals("wimonwan")) { %>
				oCMenu.makeMenu('Menu0.4.14','Menu0.4','<img src="/LHServ/images/i_home_14.gif" hspace="5">ยกเลิกใบแจ้งซ่อมงานสาธารณูฯ และย้ายรองจ่าย','SERV_INFDeny.jsp','','','','','','rgb(200,230,255)' )	
				<%}%>
                oCMenu.makeMenu('Menu0.5','Menu0.0','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">รายงาน Service บ้าน','','','','','','','rgb(170,210,250)' )	
				oCMenu.makeMenu('Menu0.6','Menu0.0','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">รายงาน Service สาธารณูฯ(ส่วนกลาง)','','','','','','','rgb(200,230,255)' )	
				oCMenu.makeMenu('Menu0.9','Menu0.0','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">รายงาน Service สาธารณะ','','','','','','','rgb(170,210,250)' )	
<%		  
				}//#(!user.getUserWho().equalsIgnoreCase("J"))
			}//#Else
			
	} // end if check permission




	//---========== Report Section , Staff or higher can see it ==========----//
        if (SERV_CommonData.checkPermissionOnPage(Constants.PERMISSION_STAFF,user.getUserWho()) || 
			user.getUserID().equals("lee") 
			|| user.getUserID().equals("prapat")
			|| user.getUserWho().equals("T")
			|| user.getUserWho().equals("J")
			|| user.getUserWho().equals("C")
			|| user.getUserWho().equals("G")
			|| user.getUserWho().equals("J") 
			|| user.getUserWho().equals("G")) {
            
				
		if (!user.getUserWho().equals("J")) {
			
%>
			oCMenu.makeMenu('Menu0.5.1','Menu0.5','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานสรุปจำนวนบ้านโอนย้อนหลัง 24 เดือน','<%=Constants.APP_PATH%>/SERV_Report2.jsp','','380','','','','rgb(200,230,255)' )	
			oCMenu.makeMenu('Menu0.5.2','Menu0.5','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานสรุปงานซ่อมประจำเดือน','<%=Constants.APP_PATH%>/SERV_Report51.jsp','','380','','','','rgb(170,210,250)' )	
			oCMenu.makeMenu('Menu0.5.15','Menu0.5','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานสรุปใบเบิกงวดสำหรับผู้รับเหมาบ้าน','<%=Constants.APP_PATH%>/SERV_HSumPvd.jsp','','380','','','','rgb(170,210,250)' )	
			
			oCMenu.makeMenu('Menu0.5.3','Menu0.5','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานการส่งงานผู้รับเหมา (สรุปตามการตัดเงิน)','<%=Constants.APP_PATH%>/SERV_Report7.jsp','','380','','','','rgb(200,230,255)' )	
			oCMenu.makeMenu('Menu0.5.4','Menu0.5','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานการส่งงานผู้รับเหมา (สรุปตามใบแจ้งซ่อม)','<%=Constants.APP_PATH%>/SERV_Report8.jsp','','380','','','','rgb(170,210,250)' )	
			oCMenu.makeMenu('Menu0.5.5','Menu0.5','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานการส่งงานผู้รับเหมา (รายละเอียด)','<%=Constants.APP_PATH%>/SERV_Report9.jsp','','380','','','','rgb(200,230,255)' )	

			oCMenu.makeMenu('Menu0.5.6','Menu0.5','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานสรุปค่าซ่อมสะสมทั้งโครงการ','<%=Constants.APP_PATH%>/SERV_Report6.jsp','','380','','','','rgb(170,210,250)' )
			oCMenu.makeMenu('Menu0.5.7','Menu0.5','<img src="/LHServ/images/i_home_14.gif" hspace="5">จดหมายแจ้งการตรวจรับงานซ่อม','<%=Constants.APP_PATH%>/SERV_SearchLetter.jsp','','380','','','','rgb(170,210,250)' )
			oCMenu.makeMenu('Menu0.5.8','Menu0.5','<img src="/LHServ/images/i_home_14.gif" hspace="5">จดหมายแจ้งให้บริการงานซ่อมก่อนหมดประกัน','<%=Constants.APP_PATH%>/SERV_SearchLetter2.jsp','','380','','','','rgb(170,210,250)' )
			oCMenu.makeMenu('Menu0.5.9','Menu0.5','<img src="/LHServ/images/i_home_14.gif" hspace="5">สรุปงานซ่อมแยกหมวดตามเดือนที่ผู้รับเหมาส่งงวดงาน','<%=Constants.APP_PATH%>/SERV_Report11.jsp','','380','','','','rgb(170,210,250)' )
			oCMenu.makeMenu('Menu0.5.10','Menu0.5','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานรายละเอียดบ้านลูกค้า','<%=Constants.APP_PATH%>/SERV_LckDetail.jsp','','380','','','','rgb(170,210,250)' )

			oCMenu.makeMenu('Menu0.5.11','Menu0.5','<img src="/LHServ/images/i_home_14.gif" hspace="5">สรุปแยกตามสาเหตุการแจ้งซ่อม ตามวันที่โอน/วันที่แจ้ง','<%=Constants.APP_PATH%>/SERV_Report10.jsp','','380','','','','rgb(170,210,250)' )
			oCMenu.makeMenu('Menu0.5.12','Menu0.5','<img src="/LHServ/images/i_home_14.gif" hspace="5">สรุปแยกตามสาเหตุการแจ้งซ่อม ตามแบบบ้าน / ผู้รับเหมา','<%=Constants.APP_PATH%>/SERV_Report12.jsp','','380','','','','rgb(170,210,250)' )
<%	if (user.getUserID().equals("lee") || user.getUserID().equals("narong") || user.getUserID().equals("kungwal") || user.getUserID().equals("piyapong") || user.getUserID().equals("prapat") || user.getUserID().equals("techin") || user.getUserID().equals("chawengk")) {    %>
			oCMenu.makeMenu('Menu0.5.13','Menu0.5','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานค่าใช้จ่าย/ต้นทุนทางอ้อม แยกรายเดือน แสดงยอดรวม','<%=Constants.APP_PATH%>/EIS_ServAllProjExpenceMnt.jsp','','380','','','','rgb(170,210,250)' )
<%  }  %>			
			oCMenu.makeMenu('Menu0.5.14','Menu0.5','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานค่าใช้จ่าย/ต้นทุนทางอ้อม แยกรายเดือน ระบุหลายโครงการ','<%=Constants.APP_PATH%>/EIS_ServMultiProjExpenceMnt_Form.jsp','','380','','','','rgb(170,210,250)' )
			

			oCMenu.makeMenu('Menu0.5.16','Menu0.5','<img src="/LHServ/images/i_home_14.gif" hspace="5">end-product achievement by project','http://132.146.1.129/cgi-bin/con0084.cgi?+++++++<%=user.getUserID()%>++LH+111111111128099','_blank','380','','','','rgb(170,210,250)' )

			oCMenu.makeMenu('Menu0.6.1','Menu0.6','<img src="/LHServ/images/i_home_14.gif" hspace="5">พิมพ์ใบสั่งซ่อมแก้ไขโดยผู้รับเหมา','<%=Constants.APP_PATH%>/SERV_INFReprint_Pay_List.jsp','','280','','','','rgb(170,210,250)' )	
			oCMenu.makeMenu('Menu0.6.2','Menu0.6','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานการส่งงานผู้รับเหมา (สรุปตามการตัดเงิน)','<%=Constants.APP_PATH%>/SERV_INFReport7.jsp','','280','','','','rgb(200,230,255)' )	
			oCMenu.makeMenu('Menu0.6.3','Menu0.6','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานการส่งงานผู้รับเหมา (สรุปตามใบแจ้งซ่อม)','<%=Constants.APP_PATH%>/SERV_INFReport8.jsp','','280','','','','rgb(170,210,250)' )	
			oCMenu.makeMenu('Menu0.6.4','Menu0.6','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานการส่งงานผู้รับเหมา (รายละเอียด)','<%=Constants.APP_PATH%>/SERV_INFReport9.jsp','','280','','','','rgb(200,230,255)' )	
			oCMenu.makeMenu('Menu0.6.5','Menu0.6','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานสรุปใบเบิกงวดสำหรับผู้รับเหมาสาธารณู','<%=Constants.APP_PATH%>/SERV_SumPvd.jsp','','280','','','','rgb(170,210,250)' )
			oCMenu.makeMenu('Menu0.6.6','Menu0.6','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานสรุปงานซ่อมแยกหมวดตามเดือนที่จ่าย','<%=Constants.APP_PATH%>/SERV_INFReport10.jsp','','280','','','','rgb(200,230,255)' )					
			oCMenu.makeMenu('Menu0.6.7','Menu0.6','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานสาเหตุงานซ่อมสาธารณูฯ','<%=Constants.APP_PATH%>/SERV_INFCauseOfRepair.jsp?itmtype=01','','280','','','','rgb(170,210,250)' )					
			

			oCMenu.makeMenu('Menu0.9.1','Menu0.9','<img src="/LHServ/images/i_home_14.gif" hspace="5">พิมพ์ใบสั่งซ่อมแก้ไขโดยผู้รับเหมา','<%=Constants.APP_PATH%>/SERV_INFReprint_Pay_List.jsp','','280','','','','rgb(170,210,250)' )	
			oCMenu.makeMenu('Menu0.9.2','Menu0.9','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานการส่งงานผู้รับเหมา (สรุปตามการตัดเงิน)','<%=Constants.APP_PATH%>/SERV_INFReport7.jsp?itmtype=02','','280','','','','rgb(200,230,255)' )	
			oCMenu.makeMenu('Menu0.9.3','Menu0.9','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานการส่งงานผู้รับเหมา (สรุปตามใบแจ้งซ่อม)','<%=Constants.APP_PATH%>/SERV_INFReport8.jsp?itmtype=02','','280','','','','rgb(170,210,250)' )	
			oCMenu.makeMenu('Menu0.9.4','Menu0.9','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานการส่งงานผู้รับเหมา (รายละเอียด)','<%=Constants.APP_PATH%>/SERV_INFReport9.jsp?itmtype=02','','280','','','','rgb(200,230,255)' )	
			oCMenu.makeMenu('Menu0.9.5','Menu0.9','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานสาเหตุงานซ่อมสาธารณะ','<%=Constants.APP_PATH%>/SERV_INFCauseOfRepair.jsp?itmtype=02','','280','','','','rgb(170,210,250)' )					
<%
			} // end if check who != J
				//		if (!user.getUserWho().equals("J") || !user.getUserWho().equals("G")) {
%>
				
<%
				//	}
}

if(!user.getUserWho().equals("J") && !user.getUserWho().equals("G") &&!isSvc) { //&& !turnkey.equals("S") 2018.04.30 by pradoem& p'  pay


%>
		oCMenu.makeMenu('Menu1.0','MenuRoot','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">ใบวางเงินค้ำประกันต่อเติม','','','','','','','rgb(200,230,255)' )
<%

       //----================ Ret Reten Module ==============----//	
	   if (!user.getUserWho().equalsIgnoreCase("T") && !user.getUserWho().equalsIgnoreCase("F") )  {
%>
			oCMenu.makeMenu('Menu1.1','Menu1.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">ใบวางเงินค้ำประกัน','SERV_RetenHome.jsp','','','','','','rgb(200,230,255)' )	
			oCMenu.makeMenu('Menu1.2','Menu1.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">พิมพ์ใบ PayIn','SERV_PrntReten2.jsp','','','','','','rgb(170,210,250)' )
		
<%
	   }
	   if (user.getUserWho().equalsIgnoreCase("Z") || user.getUserWho().equalsIgnoreCase("C") || user.getUserWho().equalsIgnoreCase("P")) {
%>

			oCMenu.makeMenu('Menu1.7','Menu1.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">พิมพ์ใบวางเงินค้ำประกัน (Reprint)','SERV_PrntRetReten.jsp','','','','','','rgb(200,230,255)' )	
			oCMenu.makeMenu('Menu1.8','Menu1.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">พิมพ์ใบขอคืนเงินค้ำประกัน (Reprint)','SERV_PrntRetReten2.jsp','','','','','','rgb(200,230,255)' )	
<%
	   }
	   if (user.getUserWho().equalsIgnoreCase("T")) {
%>
			oCMenu.makeMenu('Menu1.3','Menu1.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">Confirm ใบขอคืนเงินค้ำประกัน (บ/ช)','SERV_Conf_ARecevChq.jsp','','','','','','rgb(170,210,250)' )	
 <%
	   }
	   	if(!isSvc){
	   	//2017-11-20 ฝากวาเปิด comment นี้หน่อย //
		%>
		    oCMenu.makeMenu('Menu1.9','Menu1.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">พิมพ์ใบเสร็จใบวางเงินค้ำประกัน','SERV_PrintRetenReceipt.jsp','','','','','','rgb(170,210,250)' )
			oCMenu.makeMenu('Menu1.4','Menu1.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">ตรวจสอบสถานะใบวางเงินค้ำประกัน','SERV_ChkRet.jsp','','','','','','rgb(200,230,255)' )
		<%}%>			
		oCMenu.makeMenu('Menu1.5','Menu1.0','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานรายละเอียดการวางเงินค้ำประกัน','','','','','','','rgb(170,210,250)' )	
		oCMenu.makeMenu('Menu1.5.1','Menu1.5','<img src="/LHServ/images/i_home_14.gif" hspace="5">สรุปเงินค้ำประกันการปลูกสร้างอาคารฯ','SERV_ScrRetSum.jsp','','','','','','rgb(200,230,255)' )	
		oCMenu.makeMenu('Menu1.5.2','Menu1.5','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายละเอียดเงินค้ำประกันการปลูกสร้างอาคารฯ','SERV_ScrRetDet.jsp','','','','','','rgb(170,210,250)' )	
		oCMenu.makeMenu('Menu1.5.3','Menu1.5','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานเงินค้ำประกันต่อเติม (บ/ช)','SERV_ScrRetDet2.jsp','','','','','','rgb(200,230,255)' )	
<% 

	   if ( user.getUserID().equals("sanchai") || user.getUserID().equals("toy") || user.getUserID().equals("ssunisa") || user.getUserID().equals("wimonwan")
	   || user.getUserID().equals("techin")|| user.getUserID().equals("podjanad") 
       || user.getUserID().equals("suriyavi") // 2025-05-08 , G12 Admin
       ) {
 %>
			oCMenu.makeMenu('Menu1.6','Menu1.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายละเอียดป้ายต่อเติม','SERV_Signb.jsp','','','','','','rgb(200,230,255)' )					   
<%
	   }
%>

		<%
		if(!isSvc){
		%>
			oCMenu.makeMenu('Menu2.0','MenuRoot','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">ค่าบริการสาธารณะ','','','','','','','rgb(170,210,300)' )		
			oCMenu.makeMenu('Menu2.1','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">บันทึกค่าบริการสาธารณะ','SERV_InfHome.jsp','','350','','','','rgb(200,230,300)' )				    		
		    oCMenu.makeMenu('Menu2.2','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">พิมพ์ใบ PayIn','SERV_InfPayin.jsp','','350','','','','rgb(170,210,300)' )	
		    oCMenu.makeMenu('Menu2.13','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">พิมพ์สำเนาใบเสร็จค่าบริการสาธารณะ','SERV_PrintInfraReceipt.jsp','','350','','','','rgb(170,210,300)' )
			oCMenu.makeMenu('Menu2.3','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">กำหนดอัตราค่าบริการสาธารณะ','SERV_InfTime.jsp','','350','','','','rgb(200,230,300)' )	
		<%
		}
		%>		
		oCMenu.makeMenu('Menu2.4','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">แก้ไขข้อมูลค่าบริการสาธารณะรายแปลง','SERV_LockDet.jsp','','350','','','','rgb(170,210,300)' )	
		oCMenu.makeMenu('Menu2.5','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานการรับชำระค่าบริการสาธารณะ','SERV_xinfList.jsp','','350','','','','rgb(200,230,300)' )	
		oCMenu.makeMenu('Menu2.6','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานการจัดเก็บค่าบริการสาธารณะ','SERV_InfPayRpt1.jsp','','350','','','','rgb(170,210,300)' )
		
		 //--- 2021-08-19 , add new menu ---//
		oCMenu.makeMenu('Menu2.15','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานสรุปค่าบริการสาธารณูปโภคแยกตามโครงการ','SERV_InfPubReport.jsp','','350','','','','rgb(200,230,300)' )
		<%
			if (user.getUserID().equals("sompoch") || user.getUserID().equals("jaturong")) {
				%>
				oCMenu.makeMenu('Menu2.18','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">ทดสอบ - รายงานค่าบริการสาธารณูปโภคคงเหลือแยกตามโครงการ','SERV_InfPubRemain.jsp','','350','','','','rgb(170,210,300)' )	
				<%
			}			
			if (user.getUserWho().equalsIgnoreCase("T")) {
				%>
				oCMenu.makeMenu('Menu2.17','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายการค่าบริการสาธารณูปโภคสำหรับทำ JV (บ/ช)','SERV_InfPubPostJV.jsp','','350','','','','rgb(170,210,300)' )	
				<%
			}
		%>		
		
		oCMenu.makeMenu('Menu2.7','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">จดหมายแจ้งการจัดเก็บค่าบริการสาธารณะประจำปี','SERV_PrintInfLetter1.jsp','','350','','','','rgb(200,230,300)' )	
		oCMenu.makeMenu('Menu2.8','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">จดหมายแจ้งอัตราการจัดเก็บค่าบริการสาธารณะประจำปี','SERV_PrintInfLetter2.jsp','','350','','','','rgb(170,210,300)' )
		oCMenu.makeMenu('Menu2.11','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">จดหมายงดให้บริการจัดเก็บขยะครัวเรือน','SERV_PrintInfLetter5.jsp','','350','','','','rgb(200,230,300)' )	
		oCMenu.makeMenu('Menu2.9','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">จดหมายขอให้ชำระค่าบริการสาธารณะ','SERV_PrintInfLetter3.jsp','','350','','','','rgb(170,210,300)' )	
		oCMenu.makeMenu('Menu2.14','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">จดหมายแจ้งขอระงับการจดทะเบียนสิทธิและนิติกรรม','SERV_PrintInfLetter6.jsp','','350','','','','rgb(170,210,300)' )
		oCMenu.makeMenu('Menu2.10','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">จดหมายขอให้ชำระค่าบริการสาธารณะ','SERV_PrintInfLetter8.jsp','','350','','','','rgb(200,230,300)' )		
		oCMenu.makeMenu('Menu2.23','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">จดหมายขอแจ้งการจัดเก็บค่าบริการสาธารณะประจำปี','SERV_PrintInfLetter9.jsp','','350','','','','rgb(200,230,300)' )		
		oCMenu.makeMenu('Menu2.16','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">จดหมายแจ้งส่ง Sticker','SERV_PrintInfLetter7.jsp','','350','','','','rgb(200,230,300)' )		
		
		oCMenu.makeMenu('Menu2.12','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">คู่มือการแก้ไขข้อมูลค่าบริการสาธารณะรายแปลง','update_lock_manual.pdf','_blank','350','','','','rgb(200,230,300)' )	
<% 		
			//--- 2023-09-18 , new menu ---//
			if (user.getUserID().equals("sompoch") || user.getUserID().equals("prapat") || user.getUserID().equals("kajonyos")) {
				%>
				oCMenu.makeMenu('Menu2.19','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">ตั้งข้อมูลพื้นฐานเฟสโครงการ (C0)','SERV_PhaseProjList.jsp','','350','','','','rgb(170,210,300)' )	
				<%
			}
			if (user.getUserID().equals("sompoch") || user.getUserID().equals("kajonyos")) {
				%>
				oCMenu.makeMenu('Menu2.20','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">ตั้งข้อมูลพื้นฐานเฟสโครงการเก่า (C5,C8)','SERV_PhaseProjList2.jsp','','350','','','','rgb(200,230,300)' )	
				<%
			}			

		}  // end if check who != J, G
	   
			if (user.getUserWho().equalsIgnoreCase("T") || user.getUserID().equals("lee") || user.getUserID().equals("piyapong") || user.getUserID().equals("banchale") || user.getUserID().equals("kungwal") || user.getUserID().equals("prapat") || user.getUserID().equals("jtaipob") || user.getUserID().equals("oranuch") || user.getUserID().equals("nipaporn") || user.getUserID().equals("prapatso") || user.getUserID().equals("aphita")) { 
	%>		
				oCMenu.makeMenu('Menu2.21','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานแสดงรายรับ-รายจ่าย ค่าบริการสาธารณะ','http://132.146.1.178:8089/service-app/ByPassLoginServlet?employId=<%=user.getEmpId()%>&forward=RptServExpenseServlet?cmd=frmLoad','_blank','350','','','','rgb(300,230,300)' )	
				oCMenu.makeMenu('Menu2.22','Menu2.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานแสดงค่าบริการสาธารณะแสดงรายละเอียดตามช่วงเวลา','http://132.146.1.178:8089/service-app/ByPassLoginServlet?employId=<%=user.getEmpId()%>&forward=RptServExpenseTimePeriodServlet?cmd=frmLoad','_blank','350','','','','rgb(300,230,250)' )	
	<%		}      %>	

	<%if(!isSvc){%>
		oCMenu.makeMenu('Menu3.0','MenuRoot','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายละเอียดการขออนุมัติ TurnKey','SERV_TurnkeyApprList.jsp','','','','','','rgb(200,230,255)' )	
	<%}%>	
		oCMenu.makeMenu('Menu4.0','MenuRoot','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">Check Up Program','','','','','','','rgb(170,210,250)' )		
<%
	 if (user.getUserWho().equals("C") || user.getUserWho().equals("A") ) {
%>
		oCMenu.makeMenu('Menu4.1','Menu4.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายละเอียดร้านค้าภายในโครงการ','SERV_ChkVenPrj.jsp','','','','','','rgb(170,210,250)' )			
<%
		}
%>
		oCMenu.makeMenu('Menu4.2','Menu4.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">บันทึกการจองเวลา','SERV_ResvTimeLst.jsp','','','','','','rgb(200,230,255)' )	
		oCMenu.makeMenu('Menu4.3','Menu4.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">บันทึกแปลงทำ Check up','/LHServ/InitChkLckServlet','','','','','','rgb(170,210,250)' )	
		oCMenu.makeMenu('Menu4.4','Menu4.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">Open Check Up Job','/LHServ/InitOpenChkupServlet','','','','','','rgb(200,230,255)' )	
		oCMenu.makeMenu('Menu4.5','Menu4.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">สละสิทธิการทำ Check up','SERV_DenLckLst.jsp','','','','','','rgb(170,210,250)' )			
		oCMenu.makeMenu('Menu4.6','Menu4.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานสรุปงาน Check up ประจำเดือน','SERV_ChkupSumRpt1.jsp','','','','','','rgb(200,230,255)' )	

		oCMenu.makeMenu('Menu5.0','MenuRoot','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">ตรวจสอบคุณภาพงานซ่อม','','','','','','','rgb(200,230,255)' )		
		oCMenu.makeMenu('Menu5.1','Menu5.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">บันทึกคุณภาพงานซ่อม','<%=request.getContextPath()%>/ServiceDistributeServlet?url=http://132.146.1.126/QCS/QCList.do?cmd=list','','280','','','','rgb(200,230,255)' )	
		oCMenu.makeMenu('Menu5.2','Menu5.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">ยกเลิกการตรวจ QC ใบแจ้งซ่อม','<%=request.getContextPath()%>/ServiceDistributeServlet?url=http://132.146.1.126/QCS/QCCancelList.do?cmd=list','','280','','','','rgb(170,210,250)' )	
		oCMenu.makeMenu('Menu5.3','Menu5.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">สรุปรวมรายการตรวจคุณภาพงานซ่อม','SERV_QCSum1.jsp','','280','','','','rgb(200,230,255)' )	
		oCMenu.makeMenu('Menu5.4','Menu5.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">สรุปภาพรวมคุณภาพงานซ่อมตามปี','<%=request.getContextPath()%>/ServiceDistributeServlet?url=http://132.146.1.126/QCS/SummaryYear.do?cmd=list','','280','','','','rgb(170,210,250)' )	
		oCMenu.makeMenu('Menu5.5','Menu5.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">สรุปภาพรวมคุณภาพงานซ่อมย้อนหลัง 3 เดือน','<%=request.getContextPath()%>/ServiceDistributeServlet?url=http://132.146.1.126/QCS/SummaryMonth.do?cmd=list','','280','','','','rgb(200,230,255)' )	

		
		oCMenu.makeMenu('Menu6.0','MenuRoot','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">แจ้งซ่อมออนไลน์','','','','','','','rgb(170,210,250)' )		
<%
		/* Group set SVC
		*/
		if(!isSvc || "0719-1".equals(user.getEmpId()) || "2154-6".equals(user.getEmpId())  ){
		
%>		
				oCMenu.makeMenu('Menu6.1','Menu6.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">กำหนดวันเข้าตรวจสอบ','<%=request.getContextPath()%>/ESERV_AppointDateServlet?cmd=formLoad','','280','','','','rgb(170,210,250)' )	

<%   }   %>
		oCMenu.makeMenu('Menu6.2','Menu6.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">ประวัติการนัดเข้าตรวจสอบรายการซ่อม','<%=request.getContextPath()%>/ESERV_MngAppointDateServlet?cmd=formLoad','','280','','','','rgb(200,230,255)' )	
		oCMenu.makeMenu('Menu6.3','Menu6.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">แก้ไขวันนัดเข้าตรวจงานซ่อม (LINE)','<%=request.getContextPath()%>/ESERV_AfterAppointDateServlet?cmd=formLoad','','280','','','','rgb(170,210,250)' )	
		<%	
		if (user.getUserID().equals("prapat")|| user.getUserID().equals("wimonwan") || user.getUserID().equals("techin")|| user.getUserID().equals("podjanad") || user.getUserID().equals("lee") || user.getUserID().equals("pradoem") ) { 
		%>
				oCMenu.makeMenu('Menu6.4','Menu6.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">Generate Password ลูกค้า','<%=request.getContextPath()%>/ESERV_GenPwdCust2Servlet?cmd=formLoad','','280','','','','rgb(200,230,255)' )			
		<%
		}
		%>
		oCMenu.makeMenu('Menu6.5','Menu6.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">Print Password ลูกค้า (Carbon)','<%=request.getContextPath()%>/ESERV_PrintPwdOldCustServlet?cmd=formLoad','','280','','','','rgb(170,210,250)' )	
		oCMenu.makeMenu('Menu6.6','Menu6.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">สรุปรายงานการแจ้งซ่อมผ่าน e-Service แยกตาม Zone','<%=request.getContextPath()%>/SERV_ReportInformRepairServlet?cmd=load','','280','','','','rgb(200,230,255)' )			

<% if (!turnkey.equals("S") &&!isSvc) {  %>

<%--    Menu Zero defect by pradoem 2012.10.11 --%>
	    oCMenu.makeMenu('Menu7.0','MenuRoot','<img src="images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="images/i_home_14.gif" hspace="5">Zero Defect & QC','','','','','','','rgb(200,230,255)' )		
	    oCMenu.makeMenu('Menu7.1','Menu7.0','<img src="images/i_home_14.gif" hspace="5">Confirm การตรวจ Zero Defect','SERV_ZeroDefect_List.jsp','','','','','','rgb(200,230,255)' )	
<%	    //wimonwan=2122-0
		if (user.getEmpId().equals("0719-1") || user.getEmpId().equals("1856-6") || user.getEmpId().equals("1463-5") ||user.getEmpId().equals("2154-6") ) { 	
%>

		oCMenu.makeMenu('Menu7.2','Menu7.0','<img src="images/i_home_14.gif" hspace="5">กำหนดโครงการที่รับผิดชอบ Zero Defect','SERV_ZeroDefectMasterServlet?cmd=formLoad','','','','','','rgb(170,210,250)' )	
<% } %>  
		oCMenu.makeMenu('Menu7.3','Menu7.0','<img src="images/i_home_14.gif" hspace="5">รายงาน Zero Defect','SERV_ReportZero01.jsp','','','','','','rgb(200,230,255)' )	
		oCMenu.makeMenu('Menu7.4','Menu7.0','<img src="images/i_home_14.gif" hspace="5">ข้อมูล BOQ ซ่อมก่อนโอน','SERV_BOQ_IPVQC01.jsp','','','','','','rgb(170,210,250)' )	
		oCMenu.makeMenu('Menu7.5','Menu7.0','<img src="images/i_home_14.gif" hspace="5">ตรวจสอบรายการเก็บก่อนโอน','SERV_RecBeforeTransferServlet?cmd=load','','','','','','rgb(200,230,255)' )	
		oCMenu.makeMenu('Menu7.6','Menu7.0','<img src="images/i_home_14.gif" hspace="5">กำหนดบริษัทรับตรวจบ้าน','IPVQC_Vendor_List.jsp','','','','','','rgb(170,210,250)' )	

<%  } // end if turn key   %>

<%--  Menu for Service Center 2013.12.12 by pradoem --%>
		oCMenu.makeMenu('Menu8.0','MenuRoot','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">Service Call Center','','','','','','','rgb(170,210,250)' )		
		oCMenu.makeMenu('Menu8.1','Menu8.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">ตารางนัดหมายงานซ่อมGoogle Calendar','<%=request.getContextPath()%>/SVCMasterGCalendarServlet?cmd=load','','280','','','','rgb(170,210,250)' )	
		<%
		if(isSvc || user.getUserID().equals("lee") || user.getUserID().equals("luck")){	
			%>
			oCMenu.makeMenu('Menu8.2','Menu8.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">แนะนำบ้าน','http://132.146.1.118/CALLService/CallOutboundHomeController.do?cmd=formLoad&employId=<%=user.getEmpId()%>','_blank','280','','','','rgb(200,230,255)' )	
		    oCMenu.makeMenu('Menu8.3','Menu8.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">การโทรกลับหาลูกค้า','http://132.146.1.118/CALLService/SVCCallOutboundController.do?cmd=formLoad&employId=<%=user.getEmpId()%>','_blank','280','','','','rgb(170,210,250)' )			    
			oCMenu.makeMenu('Menu8.4','Menu8.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">ยืนยันนัดหมายงานแนะนำบ้าน','http://132.146.1.118/CALLService/INTConfirmGuideHouseController.do?cmd=formLoad&employId=<%=user.getEmpId()%>','_blank','280','','','','rgb(200,230,255)' )	
		    oCMenu.makeMenu('Menu8.5','Menu8.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">นัดหมาย CHECKUP','http://132.146.1.118/CALLService/CheckUpHomeController.do?cmd=formLoad&employId=<%=user.getEmpId()%>','_blank','280','','','','rgb(170,210,250)' )			    

		<%}
		%>
		oCMenu.makeMenu('Menu8.6','Menu8.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานแนะนำบ้าน','<%=request.getContextPath()%>/SERV_ReportINTBaanServlet?cmd=load','','280','','','','rgb(200,230,255)' )			    
		<%-- Add Menu by pradoem 2015.10.12  --%>
		oCMenu.makeMenu('Menu8.7','Menu8.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานฐานการรับสายตามช่วงโอน','<%=request.getContextPath()%>/SERV_ReportSvcServlet?cmd=load','','280','','','','rgb(170,210,250)' )			    
		oCMenu.makeMenu('Menu8.8','Menu8.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานฐานการรับสายตามเดือน','<%=request.getContextPath()%>/SERV_ReportSvcMonthlyServlet?cmd=load','','280','','','','rgb(200,230,255)' )			    
		oCMenu.makeMenu('Menu8.9','Menu8.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">ข้อมูลพื้นฐานกำหนดสายงานผู้รับ Email','<%=request.getContextPath()%>/SERV_SettingSendMailServlet?cmd=search','','280','','','','rgb(170,210,250)' )		
		
		<%
		if(isSvc){	
		%>
			oCMenu.makeMenu('Menu8.10','Menu8.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">ตรวจสอบสถานะใบวางเงินค้ำประกัน','<%=request.getContextPath()%>/SERV_ChkRet.jsp','','280','','','','rgb(200,230,255)' )			    
			oCMenu.makeMenu('Menu8.11','Menu8.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">พิมพ์ใบ PayIn','<%=request.getContextPath()%>/SERV_InfPayin.jsp','','280','','','','rgb(170,210,250)' )		    
			oCMenu.makeMenu('Menu8.12','Menu8.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">กำหนดอัตราค่าบริการสาธารณะ','<%=request.getContextPath()%>/SERV_InfTime.jsp','','280','','','','rgb(200,230,255)' )	
			oCMenu.makeMenu('Menu8.13','Menu8.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">บันทึกค่าบริการสาธารณะ','<%=request.getContextPath()%>/SERV_InfHome.jsp','','280','','','','rgb(170,210,250)' )
			oCMenu.makeMenu('Menu8.14','Menu8.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">พิมพ์สำเนาใบเสร็จค่าบริการสาธารณะ','SERV_PrintInfraReceipt.jsp','','','','','','rgb(170,210,250)' )			
			oCMenu.makeMenu('Menu8.15','Menu8.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานการจัดเก็บค่าบริการสาธารณะ','<%=request.getContextPath()%>/SERV_InfPayRpt1.jsp','','280','','','','rgb(200,230,255)' )
			
			<%-- Add by pradoem 2019.11.14 For QC,PJ,PM,VP --%>	
			oCMenu.makeMenu('Menu14.0','MenuRoot','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">ระบบ Tele Followup ','','','','','','','rgb(200,230,255)' )		
			oCMenu.makeMenu('Menu14.1','Menu14.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">กำหนดวันนัดหมายเข้าซ่อม','https://www10.lh.co.th/LHAppServ/serviceStaffFormList.do?employId=<%=user.getEmpId()%>&projectDDL=','_blank','280','','','','rgb(170,210,250)' )	
			oCMenu.makeMenu('Menu14.2','Menu14.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">TFU ยืนยันนัดหมาย/นัดซ่อม','https://www10.lh.co.th/LHAppServ/teleConfirmDatingList.do?employId=<%=user.getEmpId()%>&projectDDL=','_blank','280','','','','rgb(200,230,250)' )	
			oCMenu.makeMenu('Menu14.3','Menu14.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">Calendar นัดหมาย/นัดซ่อม','https://www10.lh.co.th/LHAppServ/calendarViewDatingJob.do?employId=<%=user.getEmpId()%>&projectDDL=','_blank','280','','','','rgb(170,210,250)' )	
			oCMenu.makeMenu('Menu14.4','Menu14.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">แก้ไขวันที่นัดหมาย/นัดซ่อม','https://www10.lh.co.th/LHAppServ/teleMngTrackingList.do?employId=<%=user.getEmpId()%>&projectDDL=','_blank','280','','','','rgb(200,230,250)' )			 
            				
		<%}
		%>

		oCMenu.makeMenu('Menu9.0','MenuRoot','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">Follow Up','','','','','','','rgb(200,230,255)' )		
		oCMenu.makeMenu('Menu9.1','Menu9.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">งานแจ้งซ่อมตามโครงการ','SERV_Follow1.jsp','','280','','','','rgb(170,210,250)' )	
		oCMenu.makeMenu('Menu9.2','Menu9.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">งานแจ้งซ่อมตามผู้รับเหมา','SERV_VendorFollow.jsp','','280','','','','rgb(170,210,250)' )	
	    oCMenu.makeMenu('Menu9.3','Menu9.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">งานแจ้งซ่อมแยกตาม Zone','SERV_ReportService.jsp','','280','','','','rgb(170,210,250)' )
<%

		if(!isSvc || "0719-1".equals(user.getEmpId()) || "2154-6".equals(user.getEmpId())  ){
		%>
			oCMenu.makeMenu('Menu10.0','MenuRoot','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">ดำเนินการแนะนำบ้านและปิด Job','http://132.146.1.118/CALLService/INTServHomeController.do?cmd=formLoad&employId=<%=user.getEmpId()%>','_blank','','','','','rgb(170,210,250)' )		
		
		<%}%>	

<%if(!isSvc ){%>
	oCMenu.makeMenu('Menu11.0','MenuRoot','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">Finger Scan ','','','','','','','rgb(200,230,255)' )		
	oCMenu.makeMenu('Menu11.1','Menu11.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">ตารางสรุปค่าแรงช่าง และค่าแรงคนงาน','SERV_WageLabor.jsp','','280','','','','rgb(170,210,250)' )	
	oCMenu.makeMenu('Menu11.2','Menu11.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">ตารางสรุปการเข้างานของธุรการ, วิศวกร','SERV_WageLaborMnt.jsp','','280','','','','rgb(200,230,250)' )	
	oCMenu.makeMenu('Menu11.3','Menu11.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">อนุมัติรายละเอียดการปรับค่าแรงช่าง','SERV_WageHome.jsp','','280','','','','rgb(170,210,250)' )	
	
	<%-- Add by pradoem 2016.07.29 For QC,PJ,PM,VP --%>	
	oCMenu.makeMenu('Menu12.0','MenuRoot','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานเก็บก่อนโอน','','','','','','','rgb(170,210,250)' )			
	oCMenu.makeMenu('Menu12.1','Menu12.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานเก็บก่อนโอนแยกตามเดือนโอน','<%=request.getContextPath()%>/SERV_RptKeepBeforeServlet?cmd=frmLoad','','280','','','','rgb(200,230,255)' )	
	oCMenu.makeMenu('Menu12.2','Menu12.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานสรุปเก็บก่อนโอน','<%=request.getContextPath()%>/SERV_RptTransAfterEndServlet?cmd=frmLoad','','280','','','','rgb(170,210,250)' )	

	<%-- Add by pradoem 2019.11.14 For QC,PJ,PM,VP --%>	
	oCMenu.makeMenu('Menu14.0','MenuRoot','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">ระบบ Tele Followup ','','','','','','','rgb(200,230,255)' )		
	oCMenu.makeMenu('Menu14.1','Menu14.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">กำหนดวันนัดหมายเข้าซ่อม','https://www10.lh.co.th/LHAppServ/serviceStaffFormList.do?employId=<%=user.getEmpId()%>&projectDDL=','_blank','280','','','','rgb(200,230,250)' )	
	oCMenu.makeMenu('Menu14.3','Menu14.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">Calendar นัดหมาย/นัดซ่อม','https://www10.lh.co.th/LHAppServ/calendarViewDatingJob.do?employId=<%=user.getEmpId()%>&projectDDL=','_blank','280','','','','rgb(170,210,250)' )	
	oCMenu.makeMenu('Menu14.4','Menu14.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">แก้ไขวันที่นัดหมาย/นัดซ่อม','https://www10.lh.co.th/LHAppServ/teleMngTrackingList.do?employId=<%=user.getEmpId()%>&projectDDL=','_blank','280','','','','rgb(200,230,250)' )			
<%}%>
oCMenu.makeMenu('Menu14.5','Menu14.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานแสดงสถานะการเข้าซ่อม LH Vendor','<%=request.getContextPath()%>/LINE_SERVDetail.jsp','','280','','','','rgb(200,230,250)' )	

<%-- Add by pradoem 2020.09.29  For  Line Sys
oCMenu.makeMenu('Menu15.1','Menu15.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">กำหนดวันเข้าตรวจสอบ (Line)','<%//=request.getContextPath()%>/LSERV_AppointDateServlet?cmd=formLoad','','280','','','','rgb(200,230,255)' )
oCMenu.makeMenu('Menu15.2','Menu15.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">ยกเลิกวันนัดเข้าตรวจสอบ (Line)','<%//=request.getContextPath()%>/LSERV_MngAppointDateServlet?cmd=formLoad','','280','','','','rgb(170,210,250)' )	
--%>	
oCMenu.makeMenu('Menu15.0','MenuRoot','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">ระบบ Line LH SERVICE','','','','','','','rgb(170,210,250)' )		
oCMenu.makeMenu('Menu15.2.1','Menu15.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">การโทรกลับหาลูกค้า','http://132.146.1.118/CALLService/SVCCallOutboundController.do?cmd=formLoad&employId=<%=user.getEmpId()%>','_blank','280','','','','rgb(200,230,255)' )			    
oCMenu.makeMenu('Menu15.3','Menu15.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">ประชาสัมพันธ์ Broascast','https://lineapp.lh.co.th/line-bot/lser_broadcast.php','_blank','280','','','','rgb(170,210,250)' )			    
oCMenu.makeMenu('Menu15.4','Menu15.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานสรุปการแจ้งซ่อมทาง Line','https://lineapp.lh.co.th/line-bot/ReportList.php','_blank','280','','','','rgb(200,230,255)' )
oCMenu.makeMenu('Menu15.5','Menu15.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานสรุปการแจ้งซ่อมทาง Line(Excel)','https://www10.lh.co.th/LHAppServ/rptRepairLineLoad','_blank','280','','','','rgb(170,210,250)' )
oCMenu.makeMenu('Menu15.6','Menu15.0','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานสรุปแบบประเมิณลูกค้าแจ้งซ่อมทาง Line','<%=request.getContextPath()%>/LINE_Questionnair.jsp?cmd=formLoad','','280','','','','rgb(200,230,255)' )

<%-- Add by pradoem 2024.04.22 menu shardPoint --%>	
oCMenu.makeMenu('Menu16.0','MenuRoot','<img src="/LHServ/images/bu_submenu.gif" hspace="5" vspace="5" align="right"><img src="/LHServ/images/i_home_14.gif" hspace="5">Data Service (SharePoint)','https://landandhouses365.sharepoint.com/:f:/s/ServiceData/Eog1VfulJcVEkRlcsRD45lEB3Hwj0VdZZmBTA8x8uC_SnQ?e=4CvsLV','_blank','280','','','','rgb(200,230,255)' )	
<%-- Logout--%>
oCMenu.makeMenu('Menu17.0','MenuRoot','<img src="/LHServ/images/i_home_14.gif" hspace="5">รายงานวันหมดอายุประกันวัสดุ','<%=request.getContextPath()%>/SERV_ReportItmWarranty.jsp','','280','','','','rgb(170,210,250)' )	

oCMenu.makeMenu('MenuLogout','MenuRoot','<p style="font-weight:bold ; text-align:center ; color: rgb(255,255,255)">: :  Log Out  : :</p>','<%=Constants.APP_PATH%>/LogoutServlet','_top','','','','','rgb(50,80,150)')

//Leave these two lines! Making the styles and then constructing the menu 
oCMenu.makeStyle(); oCMenu.construct()			
</SCRIPT>
<script src="<%=request.getContextPath()%>/prototype.js" type="text/javascript"></script>
<SCRIPT>
window.setInterval('keepAlive()', 120000);
function keepAlive() {
	var reqParameters = new Object();
			
	new Ajax.Request('<%=request.getContextPath()+"/KeepAliveServlet"%>',
	{
	method: 'post',
	parameters: reqParameters,
	onSuccess: function(transport) {
		if(transport.status == 200 && transport.responseText != 'OK')
			{
			window.location='<%=Constants.APP_PATH%>/LogoutServlet'
			}
		if(transport.status == 302)
			{
			window.location='<%=Constants.APP_PATH%>/LogoutServlet'
			}
		},
	onFailure: function(transport) {
			window.location='<%=Constants.APP_PATH%>/LogoutServlet'
		}
	});
}
</SCRIPT>
<table border="0" width="800" cellspacing="0" cellpadding="0">
  <tr>
    <td width="192"><img border="0" src="/LHServ/images/top_logo.gif" width="192" height="38"></td>
    <td rowspan="2" style="background-image: url('/LHServ/images/top_bg.gif'); background-repeat: no-repeat" bgcolor="#E5F2FD">&nbsp;
    <div style="position:absolute ; Z-index:2 ; left:380px ; top:15px ; width: 380px"  class="SysTitle">ระบบบริการหลังการขาย</div>
    <div style="position:absolute ; Z-index:1 ; left:381px ; top:16px ; width: 380px ; color: rgb(180,180,230)"  class="SysTitle">ระบบบริการหลังการขาย</div>    
    </td>
  </tr>
  <tr>
    <td width="192">&nbsp;</td>
  </tr>
</table>
</body>
</html>
