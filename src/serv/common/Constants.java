package serv.common;

//import com.lh.util.*;

public class Constants  {
	
	//---============= JNDI Name Constants ==============----//
	//public static String JDBC_LAN = "jdbc/LH";
	public static String JDBC_LAN = "jdbc/onemonth";
	public static String JDBC_DOCFLOW = "jdbc/docflow";
	
	//---=========== Web Application Constants ===========---//
	public static String COOKIE_NAME = "SERVLogon";
	//public static String APP_PATH = "/LHService";
	public static String APP_PATH = "/LHServ";
/*	
	public static String LOGIN_HOME = "/SERV_Index.jsp";
	public static String APP_HOME = "/SERV_Index.jsp";
	public static String LOGIN_PAGE = "/login.jsp";
	public static String SAVE_PAGE = "/save_ok.jsp";
	public static String WARNING_PAGE = "/warning.htm";
	public static String ERROR_PAGE = "/errorPage.jsp";
*/	
	public static String APP_SERVER = "http://132.146.1.92";
	
	public static String LOGIN_HOME = APP_PATH+"/SERV_Index.jsp";
	public static String APP_HOME = APP_PATH+"/SERV_Index.jsp";
	public static String LOGIN_PAGE = APP_PATH+"/login.jsp";
	public static String SAVE_PAGE = APP_PATH+"/save_ok.jsp";
	public static String WARNING_PAGE = APP_PATH+"/warning.htm";
	public static String ERROR_PAGE = APP_PATH+"/errorPage.jsp";
	
	//-- service
	public static String OPENJOB_PAGE = APP_PATH+"/SERV_InfOpenJob.jsp";
	public static String BOQSrch_PAGE = APP_PATH+"/SERV_INFBOQSrch.jsp";
	
	//---============ Define Common Label ===============---//
	public static String LISTBOX_SELECT_LABEL = "------ กรุณาเลือก ------";
	public static String LISTBOX_ALLPROJECT_LABEL = "ทุกโครงการ";
	public static String LISTBOX_ALLTYPE_LABEL = "ทุกประเภท";

	//---========= Define Mininum Line Per Page ============---//
	public static int SERV_XSTD_LINE = 9;
	public static int SERV_PSTAFF_LINE = 10;
	public static int SERV_BOQSEARCH_LINE = 9;
	public static int SERV_OPENJOB_LINE = 6;
	public static int SERV_OPENJOBLIST_LINE=10;
	public static int SERV_STARTTASK_LINE =5;
	public static int SERV_COMPLETETASK_LINE=5;
	public static int SERV_BOQCODE_LINE=10;
	public static int SERV_CONTRACTORLIST_LINE=10;
	public static int SERV_CONTRACTORCONF_LINE=6;
	public static int SERV_STAFFLIST_LINE=10;
	public static int SERV_STAFFCONF_LINE=6;
	public static int SERV_MANAGERLIST_LINE=10;
	public static int SERV_MANAGERCONF_LINE=5;
	public static int SERV_ZONELIST_LINE=6;
	public static int SERV_ZONECONF_LINE=10;
	public static int SERV_ZONECONF_FULL_LINE=5;
	public static int SERV_REPRINT_LINE=10;
	public static int SERV_VENPRJ_LINE=10;






	//----============ Config User Permission and Permisson Oorder  =============----//
	public static String PERMISSION_VENDOR = "V";
	public static String PERMISSION_STAFF = "S";
	public static String PERMISSION_MANAGER = "M";
	public static String PERMISSION_ZONE = "Z";
	public static String PERMISSION_VP = "P";
	public static String PERMISSION_ADMIN = "A";
	public static String PERMISSION_CENTER = "C";
	public static String[] PERMISSION_ORDER = 
								 new String[] {
															 PERMISSION_VENDOR ,
															 PERMISSION_STAFF,
															 PERMISSION_MANAGER ,
															 PERMISSION_ZONE ,
															 PERMISSION_VP ,
															 PERMISSION_ADMIN ,
															 PERMISSION_CENTER
														   };
	











	//----============ Config for Generate PDF =============----//
	//public static String FONT_ANGSANA_NORMAL = "C:\\Windows\\Fonts\\ANGSAU.TTF";
	//public static String FONT_ANGSANA_BOLD = "C:\\Windows\\Fonts\\ANGSAUB.TTF";
	//public static String PDF_HEADER_TEMPLATE = "C:\\Documents and Settings\\arthit\\IBM\\rationalsdp7.0\\workspace\\LHServ\\WebContent\\images\\LH_Header031.pdf";	
	public static String FONT_ANGSANA_NORMAL = "/usr/IBM/WebSphere/AppServer/profiles/AppSrv01/installedApps/webNode01Cell/LHServApp.ear/LHServ.war/Fonts/ANGSAU.TTF";
	public static String FONT_ANGSANA_BOLD = "/usr/IBM/WebSphere/AppServer/profiles/AppSrv01/installedApps/webNode01Cell/LHServApp.ear/LHServ.war/Fonts/ANGSAUB.TTF";
	public static String PDF_HEADER_TEMPLATE = "/usr/IBM/WebSphere/AppServer/profiles/AppSrv01/installedApps/webNode01Cell/LHServApp.ear/LHServ.war/images/LH_Header031.pdf";
		
	
	//-----============ Define Maximum Line for show in PDF Report ============----//
	public static int SERV_PRINT_OPENJOB_CUSTOMER_LINE = 9;	
	public static int SERV_PRINT_OPENJOB_VENDOR_LINE = 9;	
	public static int SERV_PRINT_OPENJOB_EMPLOYEE_LINE = 8;	

	
	
	
	
	
	

	
	//---========= Define BOQ E-Mail  ============---//
	public static String LH_HOST = "132.146.1.12";
	public static String LH_DOMAIN = "lh.co.th";
	public static String BOQ_SENDER = "Applications <application@lh.co.th>";
	
	/*
	 *
	 *    Reference Code for insert int Mail Subject & Content
	 *  
	 *    %I_REF_NO%  		= 	Refence No. of BOQ Request.
	 *    %REQ_EMP_NO% 		= 	Requester's ID
	 *    %REQ_EMP_NAME% 	= 	Requester's Name  
	 *    %REQ_APP_NO% 		= 	Approver's ID
	 *    %REQ_APP_NAME% 	= 	Approver's Name  
	 * 
	 */
	//public static String BOQ_APPROVE_LINK = "http://localhost:8080"+APP_PATH+"/SERV_BOQCode02.jsp?i_refno=%I_REF_NO%";
	//public static String BOQ_VIEW_LINK = "http://localhost:8080"+APP_PATH+"/SERV_BOQCode03.jsp?i_refno=%I_REF_NO%";
	public static String BOQ_APPROVE_LINK = "http://132.146.1.92"+APP_PATH+"/SERV_BOQCode02.jsp?i_refno=%I_REF_NO%";
	public static String BOQ_VIEW_LINK = "http://132.146.1.92"+APP_PATH+"/SERV_BOQCode03.jsp?i_refno=%I_REF_NO%";
	public static String BOQ_SUBJECT_REQUEST = "ใบอนุมัติ BOQ  เลขที่ %I_REF_NO% (%REQ_EMP_NO% : %REQ_EMP_NAME%) กำลังรอการอนุมัติ ";
	public static String BOQ_CONTENT_REQUEST = "<table><tr><td>ใบอนุมัติ BOQ  เลขที่ %I_REF_NO% (%REQ_EMP_NO% : %REQ_EMP_NAME%) กำลังรอการอนุมัติ ... โปรดตรวจสอบ</td></tr><tr><td>"+BOQ_APPROVE_LINK+"</td></tr></table>";
	public static String BOQ_SUBJECT_APPROVE = "ใบอนุมัติ BOQ  เลขที่ %I_REF_NO% (%REQ_EMP_NO% : %REQ_EMP_NAME%) ได้ถูกอนุมัติเรียบร้อยแล้ว ";
	public static String BOQ_CONTENT_APPROVE = "<table><tr><td>ใบอนุมัติ BOQ  เลขที่ %I_REF_NO% (%REQ_EMP_NO% : %REQ_EMP_NAME%) ได้รับการอนุมัติเรียบร้อยแล้ว ... โปรดตรวจสอบ</td></tr><tr><td>"+BOQ_VIEW_LINK+"</td></tr></table>";
	public static String BOQ_SUBJECT_DENY = "ใบอนุมัติ BOQ  เลขที่ %I_REF_NO% (%REQ_EMP_NO% : %REQ_EMP_NAME%) ได้ถูกปฏิเสธ ";
	public static String BOQ_CONTENT_DENY = "<table><tr><td>ใบอนุมัติ BOQ  เลขที่ %I_REF_NO% (%REQ_EMP_NO% : %REQ_EMP_NAME%) ได้รับการปฏิเสธ ... โปรดตรวจสอบ</td></tr><tr><td>"+BOQ_VIEW_LINK+"</td></tr></table>";
	
	
}
