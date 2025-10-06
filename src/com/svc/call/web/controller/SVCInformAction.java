package com.svc.call.web.controller;
import java.net.URL;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import com.svc.call.bean.CustomerBean;
import com.svc.call.bean.ESER_DATE;
import com.svc.call.bean.SVC_DOCDT;
import com.svc.call.bean.SVC_DOCHD;
import com.svc.call.bean.SVC_STDPJ;
import com.svc.call.bean.SVC_TELNO;
import com.svc.call.dao.services.Common;
import com.svc.call.dao.services.MasterSvcService;
import com.svc.call.dao.services.MasterSvcServiceImpl;
import com.svc.call.dao.services.ServiceCenterCallService;
import com.svc.call.dao.services.ServiceCenterCallServiceImpl;
import com.svc.call.utilize.Constant;
import com.svc.call.utilize.GoogleCalendarV1;
import com.svc.call.utilize.Utilizer;
import com.google.gdata.client.calendar.CalendarService;
import com.google.gdata.data.DateTime;
import com.google.gdata.data.PlainTextConstruct;
import com.google.gdata.data.calendar.CalendarEventEntry;
import com.google.gdata.data.extensions.When;
import com.lh.util.doString;

/**********************************************
 * create by : pradoem wonkraso
 * date time: 2013.10.29
 * Last modify :
 * version :1.0
 * project Name :Service Center 
 * description : 
 Insert,Update,List,search
 Use google Api 
*/
public class SVCInformAction extends DispatchAction {
	static String  clazzName =  "SVCInformAction";
	static{
		//initial  First Request  configure  datasouce only
		//Use  connection db server type  Connection pool
		Common.setConfigForConnectionPool("", Constant.DataSourceName);
		
		//***Case  authorizer google by pass proxy property System		
		java.util.Properties props = System.getProperties(); 
        System.getProperties().put(Constant.PROXY_SET_NAME,Constant.PROXY_SET); 
        props.put(Constant.PROXY_HOST_NAME,Constant.PROXY_HOST);  	//proxy
        props.put(Constant.PROXY_PORT_NAME,Constant.PROXY_PORT); 	//port
       //System.setProperties(props); 
        
       //java.util.Properties props = System.getProperties();
		props.put("javax.net.ssl.trustStore",Constant.SSL_CERTIFICATE_PATH);
		props.put("javax.net.ssl.trustStorePassword",Constant.SSL_CERTIFICATE_PASSWORD);
		props.put("java.protocol.handler.pkgs", "com.sun.net.ssl.internal.www.protocol");
		System.setProperties(props);
	}
	
	public ActionForward search1(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection conn = null;  
		String forward = "";
		try{
			printOutParam(request);
			HttpSession session = request.getSession(false);
			System.out.println("-------------11111DispatchAction------------------");
			//Test();
			/********** Connection DB *************/
			conn = Common.open();
			Common.defaultTransaction(conn);
			/********** Connection DB *************/
			String tel = doString.checkString(request.getParameter("tel"),"");
			String agentId = doString.checkString(request.getParameter("agentId"),"");			
			
			String houseNo = "";
			String lock = "";
			String projectDDL = "";
			String projectId = "";
			String companyId = "";
			//2.case Search mobile add to project  avaibable list
			ServiceCenterCallService callService = new ServiceCenterCallServiceImpl();
			List listProjectAvailible = callService.ListSearchMobile$CTASIA(conn, tel);
			
			//Get Project List prepared for search popup
			MasterSvcService msService = new MasterSvcServiceImpl();
			List popupProjectList = new ArrayList();
			popupProjectList  = msService.ListProjectAllByBudget(conn);
			
			//List standard name
			List listNameStandard = msService.ListGroupNameStandard(conn);
			//--------------------------------------------------------------	
			CustomerBean  objResult =null;
			if(listProjectAvailible!=null && listProjectAvailible.size()>0){
				List strList = new ArrayList();
				//if(listProjectAvailible.size()==1){//set default
						strList =(ArrayList)listProjectAvailible.get(0);
						lock = strList.get(3).toString();
						houseNo = strList.get(4).toString();
						projectDDL = strList.get(0).toString()+":"+strList.get(1).toString();
						companyId = strList.get(0).toString();
						projectId = strList.get(1).toString();
						System.out.println("xxx test :"+projectDDL);
						System.out.println("xxx lock :"+lock);
						System.out.println("xxx house :"+houseNo);
						
						objResult = callService.GetProjectOfCustomerByHose$Lock(conn,companyId,projectId, houseNo, lock);
						if(objResult!=null){
							System.out.println("xxxlock :"+objResult.getLock());
							System.out.println("xxxhouse :"+objResult.getHouseNo());	
							System.out.println("xxx11 :"+objResult.getPrefixName());	
							System.out.println("xx22 :"+objResult.getFName());	
							System.out.println("xxx33 :"+objResult.getLName());	
							houseNo = objResult.getHouseNo();
							lock = objResult.getLock();
						}
						//3.final ddl all
						//Get 	Annunciator
						SVC_TELNO  objTelNo = callService.GetSVC$TELNO(conn,companyId,projectId,tel);
						if(objTelNo.getNCustomer()== null){
							objTelNo.setNCustomer(Utilizer.replaceNull(objResult.getPrefixName())+" "+Utilizer.replaceNull(objResult.getFName())+"   "+Utilizer.replaceNull(objResult.getLName()));
						}
						System.out.println("==objTelNo Email :"+objTelNo.getIEmail());
						
						//4. Get AgentName 
						String employId =  msService.GetEmployIdByAgentId(conn, agentId);
						String employName = msService.GetNameEmployByAgentId(conn, employId);
						System.out.println("==Employ Id :"+employId);
						System.out.println("==Employ name :"+employName);
						
						//2.find history detail
						List  listDocHd = callService.ListHistoryContactDocHD(conn,companyId,projectId, lock);
						System.out.println("----listDocHd:"+listDocHd.size());

						//List DropdownList form xstd for homeRepire,public service ,complaint
						List  listGHomeRepair = msService.ListGroupHomeRepair(conn);
						List  listGPublicService = msService.ListGroupThePublicService(conn);
						
						//List Date 
						List listDateAppoint = callService.ListAppointDate$SVC(conn,companyId,projectId,Constant.DATE_TYPE_02);
						
						//Get google calendarName
						SVC_STDPJ  calendarObj = callService.GetSVC_STDPJ(conn,companyId,projectId);
						
						System.out.println("-----Search customer success-------");
						session.setAttribute(Constant.SS_GHOME_REPAIR_LIST,listGHomeRepair);
						session.setAttribute(Constant.SS_GPUBLIC_SERVICE_LIST,listGPublicService);	
						
						//*****Set attribute for request
						request.setAttribute("listDateAppoint",listDateAppoint);
						request.setAttribute("CustomerBean",objResult);
						request.setAttribute("SVC_TELNO",objTelNo);
						request.setAttribute("listDOCHD",listDocHd);
						request.setAttribute("SVC_STDPJ",calendarObj);
									
						request.setAttribute("employId",employId);
						request.setAttribute("employName",employName);
						request.setAttribute("tel",tel);
						request.setAttribute("agentId",agentId);
						request.setAttribute("projectSel",projectDDL);
						request.setAttribute("houseNo",houseNo);
						request.setAttribute("lock",lock); 
				 //}
			}	
			//--------------------------------------------------------------
			synchronized(session){
				session.removeAttribute(Constant.SS_PROJECT_AVAILABLE_LIST);//remove
				session.removeAttribute(Constant.SS_POPUP_PROJECT_LIST);//remove
				session.removeAttribute(Constant.SS_NAME_STANDARD_LIST);
			}
			session.setAttribute(Constant.SS_PROJECT_AVAILABLE_LIST,listProjectAvailible);//add	
			session.setAttribute(Constant.SS_POPUP_PROJECT_LIST,popupProjectList);//add	
			session.setAttribute(Constant.SS_NAME_STANDARD_LIST,listNameStandard);
			
			//*****Set attribute for request
			request.setAttribute("tel",tel);
			request.setAttribute("agentId", agentId);
			
			forward = "SHOW_CALL_INFORM";
		}catch(Exception e){
			//request.setAttribute("ERROR_CODE", "1");
		    forward = "SHOW_SORRY_PAGE";
		   // e.fillInStackTrace();	
		    System.out.println(clazzName+":"+e.getMessage());
		    System.out.println(e.fillInStackTrace());
	     }finally{
			 try{
			    Common.close(conn);
			    //Close connection
			 }catch(Exception ex){}
	     }    
		return mapping.findForward(forward);
   }
	
	//Onchange DropdownList
	public ActionForward search11(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection conn = null;  
		String forward = "";
		try{
			printOutParam(request);
			HttpSession session = request.getSession(false);
			System.out.println("-------------search11--DispatchAction------------------");
			//Test();
			/********** Connection DB *************/
			conn = Common.open();
			Common.defaultTransaction(conn);
			/********** Connection DB *************/
			String tel = doString.checkString(request.getParameter("tel"),"");
			String agentId = doString.checkString(request.getParameter("agentId"),"");			
			String projectDDL = doString.checkString(request.getParameter("projectDDL"),"");
			
			String houseNo 	= "";
			String lock 	= "";
			String projectId = "";
			String companyId = "";
			
			if("".equals(projectDDL)){//Case Errors
				return mapping.findForward("SHOW_SORRY_PAGE");
			}
			String []strTemp = projectDDL.split("\\:");
			companyId = strTemp[0];
			projectId = strTemp[1];
		
			//2.case Search mobile add to project  avaibable list
			ServiceCenterCallService callService = new ServiceCenterCallServiceImpl();
			//List listProjectAvailible = callService.ListSearchMobile$CTASIA(conn, tel);		
			//Get Project List prepared for search popup
			MasterSvcService msService = new MasterSvcServiceImpl();
			//List popupProjectList = new ArrayList();
			//popupProjectList  = msService.ListProjectAllByBudget(conn);
			//List standard name
			//List listNameStandard = msService.ListGroupNameStandard(conn);
			
			SVC_TELNO objSvcTel = callService.GetSVC$TELNO(conn, companyId, projectId, tel);
			//--------------------------------------------------------------	
			CustomerBean  objResult =null;
			if(objSvcTel!=null){
				objResult = callService.GetProjectOfCustomerByHose$Lock(conn,companyId,projectId, houseNo, lock);
				if(objResult!=null){
					System.out.println("111_lock :"+objResult.getLock());
					System.out.println("111_house :"+objResult.getHouseNo());	
					System.out.println("111_11 :"+objResult.getPrefixName());	
					System.out.println("111_22 :"+objResult.getFName());	
					System.out.println("111_33 :"+objResult.getLName());	
					houseNo = objResult.getHouseNo();
					lock = objResult.getLock();
				}
				//3.final ddl all
				//Get 	Annunciator
				SVC_TELNO  objTelNo = callService.GetSVC$TELNO(conn,companyId,projectId,tel);
				if(objTelNo.getNCustomer()== null){
					objTelNo.setNCustomer(Utilizer.replaceNull(objResult.getPrefixName())+" "+Utilizer.replaceNull(objResult.getFName())+"   "+Utilizer.replaceNull(objResult.getLName()));
				}
				System.out.println("==objTelNo Email :"+objTelNo.getIEmail());
						
				//4. Get AgentName 
				String employId =  msService.GetEmployIdByAgentId(conn, agentId);
				String employName = msService.GetNameEmployByAgentId(conn, employId);
				System.out.println("==Employ Id :"+employId);
				System.out.println("==Employ name :"+employName);
						
				//2.find history detail
				List  listDocHd = callService.ListHistoryContactDocHD(conn,companyId,projectId, lock);
				System.out.println("----listDocHd:"+listDocHd.size());

				//List DropdownList form xstd for homeRepire,public service ,complaint
				List  listGHomeRepair = msService.ListGroupHomeRepair(conn);
				List  listGPublicService = msService.ListGroupThePublicService(conn);
						
				//List Date 
				List listDateAppoint = callService.ListAppointDate$SVC(conn,companyId,projectId,Constant.DATE_TYPE_02);
						
				//Get google calendarName
				SVC_STDPJ  calendarObj = callService.GetSVC_STDPJ(conn,companyId,projectId);
						
				System.out.println("-----Search customer success-------");
				session.setAttribute(Constant.SS_GHOME_REPAIR_LIST,listGHomeRepair);
				session.setAttribute(Constant.SS_GPUBLIC_SERVICE_LIST,listGPublicService);	
						
				//*****Set attribute for request
				request.setAttribute("listDateAppoint",listDateAppoint);
				request.setAttribute("CustomerBean",objResult);
				request.setAttribute("SVC_TELNO",objTelNo);
				request.setAttribute("listDOCHD",listDocHd);
				request.setAttribute("SVC_STDPJ",calendarObj);
									
				request.setAttribute("employId",employId);
				request.setAttribute("employName",employName);
				request.setAttribute("tel",tel);
				request.setAttribute("agentId",agentId);
				request.setAttribute("projectSel",projectDDL);
				request.setAttribute("houseNo",houseNo);
				request.setAttribute("lock",lock); 
			}	
			//--------------------------------------------------------------
			/*synchronized(session){
				session.removeAttribute(Constant.SS_PROJECT_AVAILABLE_LIST);//remove
				session.removeAttribute(Constant.SS_POPUP_PROJECT_LIST);//remove
				session.removeAttribute(Constant.SS_NAME_STANDARD_LIST);
			}
			session.setAttribute(Constant.SS_PROJECT_AVAILABLE_LIST,listProjectAvailible);//add	
			session.setAttribute(Constant.SS_POPUP_PROJECT_LIST,popupProjectList);//add	
			session.setAttribute(Constant.SS_NAME_STANDARD_LIST,listNameStandard);*/
			
			//*****Set attribute for request
			request.setAttribute("tel",tel);
			request.setAttribute("agentId", agentId);	
			forward = "SHOW_CALL_INFORM";
		}catch(Exception e){
			//request.setAttribute("ERROR_CODE", "1");
		    forward = "SHOW_SORRY_PAGE";
		   // e.fillInStackTrace();	
		    System.out.println(clazzName+":"+e.getMessage());
		    System.out.println(e.fillInStackTrace());
	     }finally{
			 try{
			    Common.close(conn);
			    //Close connection
			 }catch(Exception ex){}
	     }    
		return mapping.findForward(forward);
   }

	
	public ActionForward search2(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection conn = null;  
		String forward = "";
		try{
			System.out.println("-------------2222DispatchAction------------------");
			printOutParam(request);
			HttpSession session = request.getSession(false);			
			/********** Connection DB *************/
			conn = Common.open();
			Common.defaultTransaction(conn);
			/********** Connection DB *************/
			String tel = doString.checkString(request.getParameter("tel"),"");
			String agentId = doString.checkString(request.getParameter("agentId"),"");
			String comId = doString.checkString(request.getParameter("comId"),"");
			String projId = doString.checkString(request.getParameter("projId"),"");
			String nameProject = doString.checkString(request.getParameter("nameProject"),"");			
			//boolean isDup = true;
			List  strList = null;	
			//Object obj 	 = null;
			List listProjectAvailible = new ArrayList();
	    	ServiceCenterCallService callService = new ServiceCenterCallServiceImpl();
			listProjectAvailible = callService.ListSearchMobile$CTASIA(conn, tel);
			//1.case Search i_company,i_project
			if(!"".equals(comId) && !"".equals(projId)){				
				strList = new ArrayList();
				strList.add(0,comId);
				strList.add(1,projId);
				strList.add(2,nameProject);
				listProjectAvailible.add(strList);
				request.setAttribute("projectSel", comId+":"+projId);
			}
			//2.case Search mobile add to project  avaibable list
			synchronized(session){
				session.removeAttribute(Constant.SS_PROJECT_AVAILABLE_LIST);//remove
			}
			session.setAttribute(Constant.SS_PROJECT_AVAILABLE_LIST,listProjectAvailible);//add	
			//*****Set attribute for request
			request.setAttribute("tel",tel);
			request.setAttribute("agentId", agentId);
			
			forward = "SHOW_CALL_INFORM";
		}catch(Exception e){
			//request.setAttribute("ERROR_CODE", "1");
		    forward = "SHOW_SORRY_PAGE";
		   // e.fillInStackTrace();	
		    System.out.println(clazzName+":"+e.getMessage());
		    System.out.println(e.fillInStackTrace());
	     }finally{
			 try{
			    Common.close(conn);
			    //Close connection
			 }catch(Exception ex){}
	     }    
		return mapping.findForward(forward);

   }
	
	//Search project List
	public ActionForward search3(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection conn = null;  
		String forward = "";
		try{
			System.out.println("-------------3333DispatchAction------------------");
			printOutParam(request);
			HttpSession session = request.getSession(false);
			
			//Test();
			/********** Connection DB *************/
			conn = Common.open();
			Common.defaultTransaction(conn);
			/********** Connection DB *************/
			String tel = doString.checkString(request.getParameter("tel"),"");
			String agentId = doString.checkString(request.getParameter("agentId"),"");
			String commandText = doString.checkString(request.getParameter("projectTxt"),"");
			String mode = doString.checkString(request.getParameter("mode"),"search");
		
			MasterSvcService msService = new MasterSvcServiceImpl();
			List popupProjectList = msService.ListSearchProjectAllByBudget(conn, commandText);

			//*****Set attribute for request
			request.setAttribute("searchProjectList",popupProjectList);
			request.setAttribute("tel",tel);
			request.setAttribute("agentId", agentId);
			request.setAttribute("projectTxt", commandText);
			request.setAttribute("mode", mode);
			
			forward = "SHOW_POPPROJECT_PAGE";
		}catch(Exception e){
			//request.setAttribute("ERROR_CODE", "1");
		    forward = "SHOW_SORRY_PAGE";
		   // e.fillInStackTrace();	
		    System.out.println(clazzName+":"+e.getMessage());
		    System.out.println(e.fillInStackTrace());
	     }finally{
			 try{
			    Common.close(conn);
			    //Close connection
			 }catch(Exception ex){}
	     }    
		return mapping.findForward(forward);
   }
	
	
//	Search customer by comid,projectid,house,lock
	public ActionForward searchCust(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection conn = null;  
		String forward = "";
		try{
			System.out.println("-------------Customer DispatchAction------------------");
			printOutParam(request);
			HttpSession session = request.getSession(false);
			
			//Test();
			/********** Connection DB *************/
			conn = Common.open();
			Common.defaultTransaction(conn);
			/********** Connection DB *************/
			
			String tel = doString.checkString(request.getParameter("tel"),"");
			String agentId = doString.checkString(request.getParameter("agentId"),"");
			String projectDDL = doString.checkString(request.getParameter("projectDDL"),"");
			String houseNo = doString.checkString(request.getParameter("houseNoTxt"),"");
			String lock = doString.checkString(request.getParameter("lockTxt"),"");
			lock = lock.toUpperCase();
			MasterSvcService  msService = new MasterSvcServiceImpl();
			
			//1.find customer detail
			ServiceCenterCallService  callService = new ServiceCenterCallServiceImpl();
			if("".equals(projectDDL)){//Case Errors
				return mapping.findForward("SHOW_SORRY_PAGE");
			}

			String arrStr[] = projectDDL.split("\\:");
			CustomerBean  objResult = callService.GetProjectOfCustomerByHose$Lock(conn, arrStr[0],arrStr[1], houseNo, lock);
			if(objResult!=null){
				System.out.println("lock :"+objResult.getLock());
				System.out.println("house :"+objResult.getHouseNo());	
				System.out.println("11 :"+objResult.getPrefixName());	
				System.out.println("22 :"+objResult.getFName());	
				System.out.println("33 :"+objResult.getLName());	
				houseNo =objResult.getHouseNo();
				lock = objResult.getLock();
				
			}
			//3.final ddl all
			//Get 	Annunciator
			SVC_TELNO  objTelNo = callService.GetSVC$TELNO(conn,arrStr[0],arrStr[1],tel);
			if(objTelNo.getNCustomer()== null){
				objTelNo.setNCustomer(Utilizer.replaceNull(objResult.getPrefixName())+" "+Utilizer.replaceNull(objResult.getFName())+"   "+Utilizer.replaceNull(objResult.getLName()));
			}		
			//4. Get AgentName 
			String employId =  msService.GetEmployIdByAgentId(conn, agentId);
			String employName = msService.GetNameEmployByAgentId(conn, employId);
			System.out.println("==Employ Id :"+employId);
			System.out.println("==Employ name :"+employName);
			
			//2.find history detail
			List  listDocHd = callService.ListHistoryContactDocHD(conn,arrStr[0],arrStr[1], lock);
			System.out.println("----listDocHd:"+listDocHd.size());
			
			//List DropdownList form xstd for homeRepire,public service ,complaint
			List  listGHomeRepair = msService.ListGroupHomeRepair(conn);
			List  listGPublicService = msService.ListGroupThePublicService(conn);
			
			//List Date 
			List listDateAppoint = callService.ListAppointDate$SVC(conn, arrStr[0],arrStr[1],Constant.DATE_TYPE_02);
			
			//Get google calendarName
			SVC_STDPJ  calendarObj = callService.GetSVC_STDPJ(conn,arrStr[0],arrStr[1]);
			
			System.out.println("-----Search customer success-------");
			session.setAttribute(Constant.SS_GHOME_REPAIR_LIST,listGHomeRepair);
			session.setAttribute(Constant.SS_GPUBLIC_SERVICE_LIST,listGPublicService);	
			
			//*****Set attribute for request
			request.setAttribute("listDateAppoint",listDateAppoint);
			request.setAttribute("CustomerBean",objResult);
			request.setAttribute("SVC_TELNO",objTelNo);
			request.setAttribute("listDOCHD",listDocHd);
			request.setAttribute("SVC_STDPJ",calendarObj);
						
			request.setAttribute("employId",employId);
			request.setAttribute("employName",employName);
			request.setAttribute("tel",tel);
			request.setAttribute("agentId",agentId);
			request.setAttribute("projectSel",projectDDL);
			request.setAttribute("houseNo",houseNo);
			request.setAttribute("lock",lock);
			
			forward = "SHOW_CALL_INFORM";
		}catch(Exception e){
			//request.setAttribute("ERROR_CODE", "1");
		    forward = "SHOW_SORRY_PAGE";
		   // e.fillInStackTrace();	
		    System.out.println(clazzName+":"+e.getMessage());
		    System.out.println(e.fillInStackTrace());
	     }finally{
			 try{
			    Common.close(conn);
			    //Close connection
			 }catch(Exception ex){}
	     }    
		return mapping.findForward(forward);

   }

	//Search project List
	public ActionForward submit(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection conn = null;  
		String forward = "";
		try{
			System.out.println("-------------submitForm DispatchAction------------------");
			printOutParam(request);
			HttpSession session = request.getSession(false);
			
			//Test();
			/********** Connection DB *************/
			conn = Common.open();
			Common.defaultTransaction(conn);
			
			/********** Connection DB *************/
			String tel = doString.checkString(request.getParameter("tel"),"");//Insert telNo
			String agentId = doString.checkString(request.getParameter("agentId"),"");
			String projectDDL = doString.checkString(request.getParameter("projectDDL"),"");//LH:075
			String houseNo = doString.checkString(request.getParameter("houseNoTxt"),"");
			String lock = doString.checkString(request.getParameter("lockTxt"),"");
			lock = lock.toUpperCase();
		    String employName = doString.checkString(request.getParameter("employName"),"");
		    String employId = doString.checkString(request.getParameter("employId"),""); 
		    
			String customerId = doString.checkString(request.getParameter("customerId"),"");
			//*****************************************************************************
			String chkCLS1 =  doString.checkString(request.getParameter("chkCLS1"),""); //YES
			String chkCLS2 =  doString.checkString(request.getParameter("chkCLS2"),""); //YES
			String chkCLS3 =  doString.checkString(request.getParameter("chkCLS3"),""); //YES
			String chkCLS4 =  doString.checkString(request.getParameter("chkCLS4"),""); //YES
			String chkCLS5 =  doString.checkString(request.getParameter("chkCLS5"),""); //YES
			String chkCLS6 =  doString.checkString(request.getParameter("chkCLS6"),""); //YES
			//*****************************************************************************
			String chkEdit =  doString.checkString(request.getParameter("chkEdit"),""); //YES		    
			String customerTxt = doString.checkString(request.getParameter("customerTxt"),"");
			String mobileTxt1 = doString.checkString(request.getParameter("mobileTxt1"),"");
			String mobileTxt2 = doString.checkString(request.getParameter("mobileTxt2"),""); //Insert,telNo
			String emailTxt = doString.checkString(request.getParameter("emailTxt"),"");
			String mobileTxt0 = doString.checkString(request.getParameter("mobileTxt0"),"");

			String mode = doString.checkString(request.getParameter("mode"),"edit");//edit,save default edit
			String chngMode = doString.checkString(request.getParameter("chngMode"),"");//flagMode  change Date for update
			//Case change Date
			String docNo	=doString.checkString(request.getParameter("docNo"),"");
			String type	=	doString.checkString(request.getParameter("type"),"");
			String code	=	doString.checkString(request.getParameter("code"),"");
			String fdate	=doString.checkString(request.getParameter("fdate"),"");
			String fstatus	=doString.checkString(request.getParameter("fstatus"),"");  
			String gEventId = doString.checkString(request.getParameter("gEventId"),"");  
			//-------------------------------
			//---google calendar
			String gCalendarId = doString.checkString(request.getParameter("gCalendarId"),"");
			String gMail = doString.checkString(request.getParameter("gMail"),"");
			String gPassword = doString.checkString(request.getParameter("gPassword"),"");
			String gfeedUrl = doString.checkString(request.getParameter("gfeedUrl"),"");
			String gReadOnlyUrl = doString.checkString(request.getParameter("gReadOnlyUrl"),"");

			//-------------------------------
			//******For data Save or Edit
			String jobBannDDL 		= doString.checkString(request.getParameter("jobBannDDL"),"");
			String dateDDL			=  doString.checkString(request.getParameter("dateDDL"),"");
			String timeDDL			= doString.checkString(request.getParameter("timeDDL"),"");
			String jobPublicDDL2	= doString.checkString(request.getParameter("jobPublicDDL2"),"");
			String txtAreaDescJob99	=  doString.checkString(request.getParameter("txtAreaDescJob99"),"");
			String txtAreaDescJob1	=  doString.checkString(request.getParameter("txtAreaDescJob1"),"");
			String txtAreaDescJob2	=  doString.checkString(request.getParameter("txtAreaDescJob2"),"");
			String txtAreaDescJob3	=   doString.checkString(request.getParameter("txtAreaDescJob3"),"");
			String txtAreaDescJob4	=  doString.checkString(request.getParameter("txtAreaDescJob4"),""); 
			String txtAreaDescJob5	=  doString.checkString(request.getParameter("txtAreaDescJob5"),"");
			String chkBox1	=  doString.checkString(request.getParameter("chkBox1"),"0");//1
			String chkBox2	=  doString.checkString(request.getParameter("chkBox2"),"0");//1
			
			if("".equals(projectDDL)){//Case Errors
				return mapping.findForward("SHOW_SORRY_PAGE");
			}
			//-------------------------------
			if("save".equals(mode)){ 
				//set transaction false
				/*******************************
				 * 1.Gen SVC_DOCHD
				 * 2.Insert SVC_DOCHD
				 * 3....
				 * 4. Gen InformJob :GenerateOpenJob$SERV_DOCHD
				 *******************************/
				System.out.println("-------------CASE Insert ------------------------");
				int resultInt = 0;
				int transInt = 0;
				ServiceCenterCallService callService = new ServiceCenterCallServiceImpl();
				String arrStr[] = projectDDL.split("\\:");
				//commit transaction
				//set default transaction
				Common.beginTransaction(conn);
						
				/*1. Generate SVC_DOCHD
				 * */
				String autoID = callService.GenerateAutoID_SVC_DOCHD(conn);
				System.out.println("-->AutoID :"+autoID);
				
				/*2. Insert Into SVC_DOCHD
				 * */
				SVC_DOCHD objHd = new SVC_DOCHD();
				objHd.setI_svc_docno(autoID);
				objHd.setI_tel_ctasia(tel); //i_tel_ctasia
				objHd.setI_company(arrStr[0]);//comId
				objHd.setI_project(arrStr[1]);//projId
				objHd.setI_lock(lock);
				objHd.setI_customer(customerId);//i_customer
				objHd.setI_house(houseNo);
				objHd.setN_customer(doString.UnicodeToMS874(customerTxt));
				objHd.setN_custel(Utilizer.getMobileDisplay(tel, mobileTxt2,""));//n_custel
				//if("YES".equals(chkCLS1)){
				//	objHd.setF_status(Constant.STATUS_CLS);//f_CLS
				//}else{
					objHd.setF_status(Constant.STATUS_001);//f_status
				//}
				objHd.setI_agent(agentId);//i_agent
				objHd.setI_employ(employId);//i_employ

				//*
				resultInt = callService.InsertSVC_DOCHD(conn, objHd);
				System.out.println("---> InsertSVC_DOCHD : OK..");
				if(resultInt==-1){
					forward = "SHOW_SORRY_PAGE";
					return mapping.findForward(forward);
				}else{
					transInt++;//Okay
				}
								
				/*3. Prepared data SVC_DOCDT
				 * */
				SVC_DOCDT objDt = null;
				ArrayList objList = new ArrayList<SVC_DOCDT>();
				String servDocId ="";
				if("1".equals(chkBox1)){//case :check box#1
					if("".equals(timeDDL)){
						timeDDL = "00:00";
					}
					/*********************************/
					//Generate OpenJob:SERV_DOCHD
				   servDocId = callService.GenerateAutoID_SERV_DOCHD(conn, arrStr[0],arrStr[1]);
					
					String desc = "";
					if(!"".equals(txtAreaDescJob99)){
						desc = "1."+txtAreaDescJob99+"|break|นัดเข้าวันที่ "+dateDDL+" เวลา "+timeDDL+" น. ("+autoID+")";
					}else{
						desc = txtAreaDescJob99+"|break|นัดเข้าวันที่ "+dateDDL+" เวลา "+timeDDL+" น. ("+autoID+")";
					}
					resultInt = callService.GenerateOpenJob$SERV_DOCHD(conn, servDocId, arrStr[0], arrStr[1], lock, doString.UnicodeToMS874(customerTxt),
							Utilizer.getMobileDisplay(tel, mobileTxt2, ""), employId,desc);
					System.out.println("---> GenerateOpenJob$SERV_DOCHD : OK..");
					if(resultInt==-1){
						forward = "SHOW_SORRY_PAGE";
						return mapping.findForward(forward);
					}else{
						transInt++;//Okay
					}
					/************************************/
					objDt = new SVC_DOCDT();
					objDt.setI_svc_docno(autoID);
					objDt.setI_itmno(Constant.TYPE_01);
					objDt.setI_itmsub(jobBannDDL);
					objDt.setC_detail(doString.UnicodeToMS874(txtAreaDescJob99));
					objDt.setD_appoint(dateDDL+" "+timeDDL); //2013-10-29 11:30
					objDt.setI_docno(servDocId);//OpenJobId	
					if("YES".equals(chkCLS1)){
						objDt.setF_status(Constant.STATUS_CLS);//f_CLS
					}else{
						objDt.setF_status(Constant.STATUS_001);//Save data success
					}
					objDt.setI_employ_start(employId);
					objList.add(objDt);					
					
					/*1111. Update ESER_DATE
					 * */
					ESER_DATE objEdate = new ESER_DATE();
					objEdate.setI_eser_docno(autoID);
					objEdate.setI_company(arrStr[0]);
					objEdate.setI_project(arrStr[1]);
					objEdate.setI_date(dateDDL);
					objEdate.setQ_apptime_fr1(timeDDL);

					resultInt = callService.UpdateESER_DATE(conn, objEdate);
					System.out.println("---> UpdateESER_DATE : OK..");
					if(resultInt==-1){
						forward = "SHOW_SORRY_PAGE";
						return mapping.findForward(forward);
					}else{
						transInt++;//Okay
					}
				}
				
				if("1".equals(chkBox2)){//Case :check box#2
					if(!"".equals(txtAreaDescJob1)){
						objDt = new SVC_DOCDT();
						objDt.setI_svc_docno(autoID);
						objDt.setI_itmno(Constant.TYPE_02);
						//objDt.setI_itmsub(jobBannDDL);
						objDt.setC_detail(doString.UnicodeToMS874(txtAreaDescJob1));
						if("YES".equals(chkCLS2)){
							objDt.setF_status(Constant.STATUS_CLS);//f_CLS
						}else{
							objDt.setF_status(Constant.STATUS_001);//Save data success
						}
						objDt.setI_employ_start(employId);
						objList.add(objDt);
			 		}
			 		if(!"".equals(txtAreaDescJob2)){
						objDt = new SVC_DOCDT();
						objDt.setI_svc_docno(autoID);
						objDt.setI_itmno(Constant.TYPE_03);
						objDt.setI_itmsub(jobPublicDDL2);
						objDt.setC_detail(doString.UnicodeToMS874(txtAreaDescJob2));
						if("YES".equals(chkCLS3)){
							objDt.setF_status(Constant.STATUS_CLS);//f_CLS
						}else{
							objDt.setF_status(Constant.STATUS_001);//Save data success
						}
						objDt.setI_employ_start(employId);
						objList.add(objDt);
			 		}
			 		if(!"".equals(txtAreaDescJob3)){
						objDt = new SVC_DOCDT();
						objDt.setI_svc_docno(autoID);
						objDt.setI_itmno(Constant.TYPE_04);
						//objDt.setI_itmsub(jobBannDDL);
						objDt.setC_detail(doString.UnicodeToMS874(txtAreaDescJob3));
						if("YES".equals(chkCLS4)){
							objDt.setF_status(Constant.STATUS_CLS);//f_CLS
						}else{
							objDt.setF_status(Constant.STATUS_001);//Save data success
						}
						objDt.setI_employ_start(employId);
						objList.add(objDt);
			 		}
			 		if(!"".equals(txtAreaDescJob4)){
						objDt = new SVC_DOCDT();
						objDt.setI_svc_docno(autoID);
						objDt.setI_itmno(Constant.TYPE_05);
						//objDt.setI_itmsub(jobBannDDL);
						objDt.setC_detail(doString.UnicodeToMS874(txtAreaDescJob4));
						if("YES".equals(chkCLS5)){
							objDt.setF_status(Constant.STATUS_CLS);//f_CLS
						}else{
							objDt.setF_status(Constant.STATUS_001);//Save data success
						}
						objDt.setI_employ_start(employId);
						objList.add(objDt);
			 		}
			 		if(!"".equals(txtAreaDescJob5)){
						objDt = new SVC_DOCDT();
						objDt.setI_svc_docno(autoID);
						objDt.setI_itmno(Constant.TYPE_06);
						//objDt.setI_itmsub(jobBannDDL);
						objDt.setC_detail(doString.UnicodeToMS874(txtAreaDescJob5));
						if("YES".equals(chkCLS6)){
							objDt.setF_status(Constant.STATUS_CLS);//f_CLS
						}else{
							objDt.setF_status(Constant.STATUS_001);//Save data success
						}
						objDt.setI_employ_start(employId);
						objList.add(objDt);
			 		}
				}
				objHd.setSvcDocdtList(objList);

				/*4. Insert into SVC_DOCDT
				 * */
				if(objList!=null && objList.size()>0){
					//TODO:***
					resultInt = callService.InsertSVC_DOCDT(conn,objHd);
					if(resultInt==-1){
						forward = "SHOW_SORRY_PAGE";
						return mapping.findForward(forward);
					}else{
						transInt++;//Okay
						//Insert into google caleandar side
					}
					System.out.println("---> InsertSVC_DOCDT : OK..");
				}

				/*5. Insert/Update int0 SVC_TELNO
				 * */					
				SVC_TELNO objTel = new SVC_TELNO();
				objTel.setITelCtasia(tel);
				objTel.setICustomer(customerId);
				objTel.setICompany(arrStr[0]);       
				objTel.setIProject(arrStr[1]);
				objTel.setILock(lock);
				//objTel.setDCreate(create);
				objTel.setIEmployCreate(employId);//by agentId or agentName from CTASIA
				//objTel.setDUpdate(update);
				objTel.setIEmploy_update(employId);//by agentId or agentName from CTASIA
				objTel.setNCustomer(doString.UnicodeToMS874(customerTxt));
				objTel.setITelNo(Utilizer.getMobileDisplay(tel, mobileTxt2, ""));
				objTel.setIEmail(emailTxt);
				objTel.setIHouse(houseNo);
				
				/*********************************************
				 ******************Tel#1
				 *true = duplicate please Update function
				 *false = not dup  please Insert function
				/*********************************************/
				boolean isDupSvcTelNo1 = callService.IsDuplicate$SVC_TELNO(conn, tel,arrStr[0],arrStr[1]);
				if(isDupSvcTelNo1){
					//TODO:Update function
					resultInt = callService.UpdateSVC_TELNO(conn, objTel);
					System.out.println("--->Update SVC_TELNO : OK..");
					if(resultInt==-1){
						forward = "SHOW_SORRY_PAGE";
						return mapping.findForward(forward);
					}else{
						transInt++;//Okay
					}
				}else{
					//TODO:Insert function
					resultInt = callService.InsertSVC_TELNO(conn, objTel);
					System.out.println("---> InsertSVC_TELNO : OK..");
					if(resultInt==-1){
						forward = "SHOW_SORRY_PAGE";
						return mapping.findForward(forward);
					}else{
						transInt++;//Okay
					}
				}
				
				/*********************************************
				 ************Tel#2
				 *true = duplicate please Update function
				 *false = not dup  please Insert function
				/*********************************************/
				if(!"".equals(mobileTxt2)){
					boolean isDupSvcTelNo2 = callService.IsDuplicate$SVC_TELNO(conn,mobileTxt2,arrStr[0],arrStr[1]);
					objTel.setITelCtasia(mobileTxt2);
					if(isDupSvcTelNo2){
						//TODO:Update function
						resultInt = callService.UpdateSVC_TELNO(conn, objTel);
						System.out.println("--->Update SVC_TELNO : OK..");
						if(resultInt==-1){
							forward = "SHOW_SORRY_PAGE";
							return mapping.findForward(forward);
						}else{
							transInt++;//Okay
						}
					}else{
						//TODO:Insert function
						resultInt = callService.InsertSVC_TELNO(conn, objTel);
						System.out.println("---> InsertSVC_TELNO : OK..");
						if(resultInt==-1){
							forward = "SHOW_SORRY_PAGE";
							return mapping.findForward(forward);
						}else{
							transInt++;//Okay
						}
					}
				}//#if empty  ""  mobileTxt2

				if(transInt>0){
					System.out.println("-------------CASE Insert transaction :Commpleted ------------------------");
					forward = "SHOW_SUCCESS_PAGE";//Go2Success Form
					Common.commitTransaction(conn);
					Common.defaultTransaction(conn);
					//Set attribute for display page & calendar
				}else{
					System.out.println("-------------CASE CASE Insert transaction  :Fail ------------------------");
					forward = "SHOW_SORRY_PAGE";
					Common.rollbackTransaction(conn);
				}		
				//-------------------------------------
				
				/***************************************
				 * For google Api Insert date
				 **************************************/
				String showTagCalendar = "N";
				if("1".equals(chkBox1)){//case :check box#1
					System.out.println("jobBannDDL = 01,05 only :"+jobBannDDL);
					if("01".equals(jobBannDDL)|| "05".equals(jobBannDDL)){
						//*********Gooogle Insert
						//TODO:	exampleCo-exampleApp-1
						
						CalendarService calService = new CalendarService(Constant.G_SERVICE);//exampleCo-exampleApp-1.0			
						calService.setUserCredentials(gMail,gPassword);
						//"http://www.google.com/calendar/feeds/p093iqnp6676m22cjc2f3v5edg@group.calendar.google.com/private/full"
						URL feedUrl = new URL(gfeedUrl);
						
						String queryName = jobBannDDL+":"+autoID;
						CalendarEventEntry eventEntry =  new CalendarEventEntry();
						eventEntry.setTitle(new PlainTextConstruct(doString.DisplayThai(queryName)));//01:20131029001:home Repair
						eventEntry.setContent(new PlainTextConstruct(doString.DisplayThai(txtAreaDescJob99)));						
						
							String tempDate = dateDDL+"T"+timeDDL+":00";
							When wTimes = new When();	
							wTimes.setStartTime(new DateTime().parseDateTime(tempDate)); //"2013-09-20T15:30:00"
							wTimes.setEndTime(new DateTime().parseDateTime(tempDate));
						
						eventEntry.addTime(wTimes);

						GoogleCalendarV1 gCAL1 = new GoogleCalendarV1();
						try{
							gCAL1.doAddCalendarEventEntry(calService, eventEntry, feedUrl);
							System.out.println("---> Google Event Insert OK..");
						}catch (Exception e) {
							// TODO: handle exception
						}						
						//*********Googgle api search
						String eventId = "";
						HashMap eventHasObj = null;
						List eventList = gCAL1.doSearchCalendar(calService, queryName, feedUrl);
						System.out.println("---> Google Event Search OK..:"+eventList.size());
						if(eventList!=null && eventList.size()>0){
							//for(int i = 0 ; i < eventList.size() ; i++ ){
							//eventObj = (HashMap)eventList.get(i);//}
							eventHasObj = (HashMap)eventList.get(0); //First Full query
							eventId = (String)eventHasObj.get("refId");
						}
						System.out.println("---> Google Event refID:"+eventId);

						objDt = new SVC_DOCDT();
						objDt.setI_calendar_id(eventId);//mandatory feild
						objDt.setI_svc_docno(autoID);
						objDt.setI_itmno(Constant.TYPE_01);
						objDt.setI_itmsub(jobBannDDL);
						if("YES".equals(chkCLS1)){
							objDt.setF_status(Constant.STATUS_CLS);//f_CLS
						}else{
							objDt.setF_status(Constant.STATUS_001);//Save data success
						}					
						resultInt = callService.UpdateSVC_DOCDT(conn, objDt);
						System.out.println("---> UpdateSVC_DOCDT$GCalendarId OK..");
						showTagCalendar = "Y";
					}else{
						System.out.println("other case Not insert google calendar...");
					}
				}
				
				request.setAttribute("gReadOnlyUrl", gReadOnlyUrl); //feedUrl
				request.setAttribute("tagCalendar", showTagCalendar); //Y,N
				request.setAttribute("DOC_REF_ID", autoID); //201310290001
				request.setAttribute("DOC_NO", servDocId); //OpenJobId
				request.setAttribute("tel",tel); //0841013129
				request.setAttribute("agentId",agentId); //pradoem
			}else if("CHANGE_DATE".equals(mode)){
				//TODO : Update  change Date krup. on google calendar site
				/*******************************
				 * 1.case jobBaanDDL = 05 or 01
				 * 2.Delete Event calendar by refId
				 * 3.Insert New Event calendar
				 * 4.Search Event fullText search
				 * xx.Update ESER_DATE
				 * ------------------------------
				 * 5.update SVC_DOCDT  
				 * 6.update SVC_TELNO
				 * 7.success page
				 * *****************************/
				System.out.println("-------------CASE Update Change Date ------------------------");
				String eventId = "";
				String showTagCalendar = "";
				if("05".equals(jobBannDDL)){
					//TODO:google calendar api
					CalendarService calService = new CalendarService(Constant.G_SERVICE);//exampleCo-exampleApp-1.0			
					calService.setUserCredentials(gMail,gPassword);
					URL feedUrl = new URL(gfeedUrl);
					
					GoogleCalendarV1 googleCal1 = new GoogleCalendarV1();
					//delete event by refId
					boolean isDel = googleCal1.doDeleteFeedAllEventsById(calService, feedUrl, gEventId);
					System.out.println("--delete event by refId:"+isDel);
					
					//Insert new event
					String queryName = jobBannDDL+":"+docNo;
					CalendarEventEntry eventEntry =  new CalendarEventEntry();
					eventEntry.setTitle(new PlainTextConstruct(doString.DisplayThai(queryName)));//01:20131029001:home Repair
					eventEntry.setContent(new PlainTextConstruct(doString.DisplayThai(txtAreaDescJob99)));						
					
						String tempDate = dateDDL+"T"+timeDDL+":00";
						When wTimes = new When();	
						wTimes.setStartTime(new DateTime().parseDateTime(tempDate)); //"2013-09-20T15:30:00"
						wTimes.setEndTime(new DateTime().parseDateTime(tempDate));
					
					eventEntry.addTime(wTimes);

					GoogleCalendarV1 gCAL1 = new GoogleCalendarV1();
					try{
						gCAL1.doAddCalendarEventEntry(calService, eventEntry, feedUrl);
						System.out.println("---> Google Event Insert OK..");
					}catch (Exception e) {
						// TODO: handle exception
					}						
					
					//*********Googgle api search					
					HashMap eventHasObj = null;
					List eventList = gCAL1.doSearchCalendar(calService, queryName, feedUrl);
					System.out.println("---> Google Event Search OK..:"+eventList.size());
					if(eventList!=null && eventList.size()>0){
						//for(int i = 0 ; i < eventList.size() ; i++ ){
						//eventObj = (HashMap)eventList.get(i);//}
						eventHasObj = (HashMap)eventList.get(0); //First Full query
						eventId = (String)eventHasObj.get("refId");
					}
					System.out.println("---> Google Event refID:"+eventId);
					showTagCalendar = "Y";
				}//#End case jobBannDDL= 05	
				//----------------TODO:update
				//----------------set default transaction
				Common.beginTransaction(conn);
				int transInt = 0;
				ServiceCenterCallService callService = new ServiceCenterCallServiceImpl();
				String arrStr[] = projectDDL.split("\\:");
				
				/*0000. Update ESER_DATE
				 * */
				callService.RestoreESER_DATE(conn, docNo, employId);
				
				/*1111. Update ESER_DATE
				 * */
				ESER_DATE objEdate = new ESER_DATE();
				objEdate.setI_eser_docno(docNo);
				objEdate.setI_company(arrStr[0]);
				objEdate.setI_project(arrStr[1]);
				objEdate.setI_date(dateDDL);
				objEdate.setQ_apptime_fr1(timeDDL);

				int resultInt = callService.UpdateESER_DATE(conn, objEdate);
				System.out.println("---> UpdateESER_DATE : OK..");
				if(resultInt==-1){
					forward = "SHOW_SORRY_PAGE";
					return mapping.findForward(forward);
				}else{
					transInt++;//Okay
				}
				//---------------------------
				
				SVC_DOCDT docDt = new SVC_DOCDT();
				docDt.setI_svc_docno(docNo);//where
				docDt.setI_itmno(type);//where
				docDt.setI_itmsub(jobBannDDL);//where&update
				docDt.setC_detail(txtAreaDescJob99);
				docDt.setD_appoint(dateDDL+" "+timeDDL);//2013-11-01  12:00
				//docDt.setI_docno(i_docno);
				docDt.setF_status(fstatus);//where
				docDt.setI_calendar_id(eventId);
				docDt.setD_start("TODAY");//TODAY
				docDt.setI_employ_start(employId);

				int docUpd = callService.UpdateSVC_DOCDT(conn, docDt);
				System.out.println("--->Update UpdateSVC_DOCDT : OK..");
				if(docUpd==-1){
					forward = "SHOW_SORRY_PAGE";
					return mapping.findForward(forward);
				}else{
					transInt++;//Okay
				}
				System.out.println("case Edit customer :"+chkEdit);
				if("YES".equals(chkEdit)){
					//Edit customer
					SVC_TELNO objTel = new SVC_TELNO();
					objTel.setITelCtasia(tel);
					objTel.setICustomer(customerId);
					objTel.setICompany(arrStr[0]);       
					objTel.setIProject(arrStr[1]);
					objTel.setILock(lock);
					//objTel.setDCreate(create);
					objTel.setIEmployCreate(employId);//by agentId or agentName from CTASIA
					//objTel.setDUpdate(update);
					objTel.setIEmploy_update(employId);//by agentId or agentName from CTASIA
					objTel.setNCustomer(doString.UnicodeToMS874(customerTxt));
					objTel.setITelNo(Utilizer.getMobileDisplay(tel, mobileTxt2, ""));
					objTel.setIEmail(emailTxt);
					objTel.setIHouse(houseNo);
					
					/*********************************************
					 ************Tel#1
					 *true = duplicate please Update function
					 *false = not dup  please Insert function
					/*********************************************/
					boolean isDupSvcTelNo1 = callService.IsDuplicate$SVC_TELNO(conn, tel,arrStr[0],arrStr[1]);
					if(isDupSvcTelNo1){
						//TODO:Update function
						resultInt = callService.UpdateSVC_TELNO(conn, objTel);
						System.out.println("--->Update SVC_TELNO : OK..");
						if(resultInt==-1){
							forward = "SHOW_SORRY_PAGE";
							return mapping.findForward(forward);
						}else{
							transInt++;//Okay
						}
					}else{
						//TODO:Insert function
						resultInt = callService.InsertSVC_TELNO(conn, objTel);
						System.out.println("---> InsertSVC_TELNO : OK..");
						if(resultInt==-1){
							forward = "SHOW_SORRY_PAGE";
							return mapping.findForward(forward);
						}else{
							transInt++;//Okay
						}
					}
					/*********************************************
					 ************Tel#2
					 *true = duplicate please Update function
					 *false = not dup  please Insert function
					/*********************************************/
					if(!"".equals(mobileTxt2)){
						boolean isDupSvcTelNo2 = callService.IsDuplicate$SVC_TELNO(conn,mobileTxt2,arrStr[0],arrStr[1]);
						objTel.setITelCtasia(mobileTxt2);
						if(isDupSvcTelNo2){
							//TODO:Update function
							resultInt = callService.UpdateSVC_TELNO(conn, objTel);
							System.out.println("--->Update SVC_TELNO : OK..");
							if(resultInt==-1){
								forward = "SHOW_SORRY_PAGE";
								return mapping.findForward(forward);
							}else{
								transInt++;//Okay
							}
						}else{
							//TODO:Insert function
							resultInt = callService.InsertSVC_TELNO(conn, objTel);
							System.out.println("---> InsertSVC_TELNO : OK..");
							if(resultInt==-1){
								forward = "SHOW_SORRY_PAGE";
								return mapping.findForward(forward);
							}else{
								transInt++;//Okay
							}
						}
					}//#if empty  ""  mobileTxt2

				}//End Edit Check
				if(transInt>0){
					System.out.println("-------------CASE Update Change Date :Commpleted ------------------------");
					forward = "SHOW_SUCCESS_PAGE";//Go2Success Form
					Common.commitTransaction(conn);
					Common.defaultTransaction(conn);
					//Set attribute for display page & calendar
				}else{
					System.out.println("-------------CASE Update Change Date :Fail ------------------------");
					forward = "SHOW_SORRY_PAGE";
					Common.rollbackTransaction(conn);
				}	
				request.setAttribute("gReadOnlyUrl", gReadOnlyUrl); //feedUrl
				request.setAttribute("tagCalendar", showTagCalendar); //Y,N
				request.setAttribute("DOC_REF_ID", docNo); //201310290001
				request.setAttribute("tel",tel); //0841013129
				request.setAttribute("agentId",agentId); //pradoem
				//-------------------------------------
			}else if("edit".equals(mode)){				
				/*******************************
				 * 1.retrive data from data base
				 * 2.set to session&attribute
				 * 3.dispacther to jsp
				 * *******************************/
				System.out.println("-------------CASE Edit Form ------------------------");
				//forward
				MasterSvcService  msService = new MasterSvcServiceImpl();
				//1.find customer detail
				ServiceCenterCallService  callService = new ServiceCenterCallServiceImpl();
				String arrStr[] = projectDDL.split("\\:");
				CustomerBean  objResult = callService.GetProjectOfCustomerByHose$Lock(conn, arrStr[0],arrStr[1], houseNo, lock);

				//3.final ddl all
				//Get 	Annunciator
				SVC_TELNO  objTelNo = callService.GetSVC$TELNO(conn,arrStr[0],arrStr[1],tel);
				if(objTelNo.getNCustomer()== null){
					objTelNo.setNCustomer(objResult.getFName()+" "+objResult.getFName()+"   "+objResult.getLName());
				}
				
				//4. Get AgentName 
				String agentName = msService.GetNameEmployByAgentId(conn, agentId);
				System.out.println("==Agent name :"+agentName);
				
				//2.find history detail
				List  listDocHd = callService.ListHistoryContactDocHD(conn,arrStr[0],arrStr[1], lock);
				System.out.println("----listDocHd:"+listDocHd.size());
				
			
				//List DropdownList form xstd for homeRepire,public service ,complaint
				List  listGHomeRepair = msService.ListGroupHomeRepair(conn);
				List  listGPublicService = msService.ListGroupThePublicService(conn);
				
				//List Date 
				List listDateAppoint = callService.ListAppointDate$SVC(conn, arrStr[0],arrStr[1],Constant.DATE_TYPE_02);
				
				//Get google calendarName
				SVC_STDPJ  calendarObj = callService.GetSVC_STDPJ(conn,arrStr[0],arrStr[1]);
				
				System.out.println("-----Search customer success-------");
				session.setAttribute(Constant.SS_GHOME_REPAIR_LIST,listGHomeRepair);
				session.setAttribute(Constant.SS_GPUBLIC_SERVICE_LIST,listGPublicService);	
				
				//*****Set attribute for request
				request.setAttribute("listDateAppoint",listDateAppoint);
				request.setAttribute("CustomerBean",objResult);
				request.setAttribute("SVC_TELNO",objTelNo);
				request.setAttribute("listDOCHD",listDocHd);
				request.setAttribute("SVC_STDPJ",calendarObj);
				
				
				request.setAttribute("agentName",agentName);
				request.setAttribute("tel",tel);
				request.setAttribute("agentId",agentId);
				request.setAttribute("projectSel",projectDDL);
				request.setAttribute("houseNo",houseNo);
				request.setAttribute("lock",lock);
				
				//----For Keyin value
				request.setAttribute("jobBannDDL",jobBannDDL);
				request.setAttribute("dateDDL",dateDDL);
				request.setAttribute("timeDDL",timeDDL);
				request.setAttribute("jobPublicDDL2",jobPublicDDL2);
				request.setAttribute("txtAreaDescJob99",txtAreaDescJob99);
				request.setAttribute("txtAreaDescJob1",txtAreaDescJob1);
				request.setAttribute("txtAreaDescJob2",txtAreaDescJob2);
				request.setAttribute("txtAreaDescJob3",txtAreaDescJob3);
				request.setAttribute("txtAreaDescJob4",txtAreaDescJob4);
				request.setAttribute("txtAreaDescJob5",txtAreaDescJob5);
				
				request.setAttribute("chkBox1",chkBox1);
				request.setAttribute("chkBox2",chkBox2);
				request.setAttribute("mode",mode);//edit
				request.setAttribute("chngMode",chngMode);//edit
							
				//case change date
				request.setAttribute("docNo",docNo);
				request.setAttribute("type",code);
				request.setAttribute("code",code);//edit
				request.setAttribute("fdate",fdate);
				request.setAttribute("fstatus",fstatus);
				request.setAttribute("gEventId", gEventId);
				
				//for edit customer
				request.setAttribute("chkEdit",chkEdit);
				request.setAttribute("customerTxt",customerTxt);
				request.setAttribute("mobileTxt1",mobileTxt1);//edit
				request.setAttribute("mobileTxt2",mobileTxt2);
				request.setAttribute("emailTxt",emailTxt);
				request.setAttribute("mobileTxt0", mobileTxt0);
				
				//For close Job
				request.setAttribute("chkCLS1",chkCLS1);
				request.setAttribute("chkCLS2",chkCLS2);
				request.setAttribute("chkCLS3",chkCLS3);//edit
				request.setAttribute("chkCLS4",chkCLS4);
				request.setAttribute("chkCLS5",chkCLS5);
				request.setAttribute("chkCLS6", chkCLS6);

				forward = "SHOW_CALL_INFORM";//Go2Edit Form
			}
		}catch(Exception e){
		    forward = "SHOW_SORRY_PAGE";
		    System.out.println(clazzName+":"+e.getMessage());
		    System.out.println(e.fillInStackTrace());
		    try{
		    	Common.rollbackTransaction(conn);
			    //Close connection
			 }catch(Exception ex){}
	     }finally{
			 try{
			    Common.close(conn);
			    //Close connection
			 }catch(Exception ex){}
			 //clear  session all
	     }    
		return mapping.findForward(forward);

   }

	private static void printOutParam(HttpServletRequest request){
		String paramNames = "";
		System.out.println("---------[ Parameter List] ------------");
			for(Enumeration e = request.getParameterNames();e.hasMoreElements(); ){
			paramNames = (String)e.nextElement();
			System.out.println(paramNames+" = "+request.getParameter(paramNames));
			}		
			System.out.println("---------- [END Parameter List] --------------");
	}
}
