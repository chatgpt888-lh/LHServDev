package com.svc.call.web.controller;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import com.lh.util.doString;
import com.svc.call.bean.CustomerBean;
import com.svc.call.bean.SVC_DOCDT;
import com.svc.call.bean.SVC_STDPJ;
import com.svc.call.bean.SVC_TELNO;
import com.svc.call.dao.services.Common;
import com.svc.call.dao.services.MasterSvcService;
import com.svc.call.dao.services.MasterSvcServiceImpl;
import com.svc.call.dao.services.ServiceCenterCallService;
import com.svc.call.dao.services.ServiceCenterCallServiceImpl;
import com.svc.call.utilize.Constant;
import com.svc.call.utilize.Utilizer;

public class SVCHistoryAction extends DispatchAction {
	static String  clazzName =  "SVCHistoryAction";
	static{
		//initial  First Request  configure  datasouce only
		//Use  connection db server type  Connection pool
		Common.setConfigForConnectionPool("", Constant.DataSourceName);
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
	
	public ActionForward formLoad(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection conn = null;  
		String forward = "";
		try{
			printOutParam(request);
			HttpSession session = request.getSession(false);
			System.out.println("-------------Form Load DispatchAction------------------");
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
			
			
			ServiceCenterCallService  callService = new ServiceCenterCallServiceImpl();
			if("".equals(projectDDL)){//Case Errors
				return mapping.findForward("SHOW_SORRY_PAGE");
			}
			String arrStr[] = projectDDL.split("\\:");
			//---------------------------------------------------------------------//
			int displayLine = Integer.parseInt(doString.checkString(request.getParameter("pageNoDDL"),"10"));				
			//***************Get Row from db
        	int maxRow = callService.GetCountRowByHistoryContactDocHD(conn,arrStr[0],arrStr[1], lock);
        	//---------------- Generate Display Customize and Page Link -------------------------//
        	int nowPage = Integer.parseInt(doString.checkString(request.getParameter("nowPage"),"1"));
        	int startRow = ((nowPage-1)*displayLine);
        	int endRow = startRow+displayLine;       	   
        	String pageLink = "";
        	int tmpMax = maxRow;
        	pageLink = Utilizer.genLinkNextPageHTML(tmpMax, nowPage, displayLine);
        	
        	/**********************************/
			ArrayList pageNoDDL = new ArrayList();
			int intVal = 10;
			for(int i=0;i<5;i++){
				 pageNoDDL.add(0,intVal); 
				 intVal +=10;
			}
           //------------------------------------------------------------------//
			
			//--------------------------For paging2---------------------------------------//
			int maxRow2 = callService.GetCountRowByHistoryHomeRepair$1Y(conn,arrStr[0],arrStr[1],houseNo,lock);
			int nowPage2 = Integer.parseInt(doString.checkString(request.getParameter("nowPage2"),"1"));
			int startRow2 = ((nowPage2-1)*displayLine);
        	int endRow2 = startRow2+displayLine;       	 
			String pageLink2 = "";
        	int tmpMax2 = maxRow2;
        	pageLink2 = Utilizer.genLinkNextPageHTML2(tmpMax2, nowPage2, displayLine);
			//-----------------------------For paging2------------------------------------//
		
			List  listDocHd = callService.ListHistoryContactDocHD$Paging(conn,arrStr[0],arrStr[1], lock,startRow, endRow, maxRow);
			System.out.println("----listDocHd:"+listDocHd.size());
			
			List  listHistory  = callService.ListHistoryHomeRepairPaging$1Y(conn,arrStr[0],arrStr[1], houseNo, lock,startRow2, endRow2, maxRow2);
			System.out.println("----listHistory:"+listHistory.size());

			//*****Set attribute for request
			request.setAttribute("listDocHd",listDocHd);
			request.setAttribute("listHistory",listHistory);
			
			request.setAttribute("tel",tel);
			request.setAttribute("agentId", agentId);
			request.setAttribute("projectDDL",projectDDL);
			request.setAttribute("houseNo", houseNo);
			request.setAttribute("lock", lock);
			
			/**********************************/
			request.setAttribute("displayLinkPage", pageLink); 
			request.setAttribute("displayLinkPage2", pageLink2); 
			request.setAttribute("pageNoDDL",pageNoDDL);
			request.setAttribute("displayLine", displayLine);
			request.setAttribute("recordNo", startRow);
			request.setAttribute("recordNo2", startRow2);
			/************************************/
			
			forward = "SHOW_HISTORY_FORM";
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

//	chngAppDate
	public ActionForward chngAppDate(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection conn = null;  
		String forward = "";
		try{
			System.out.println("-------------Post Pone A date DispatchAction------------------");
			
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
			
			//**********For post pone a date
			String docNo = doString.checkString(request.getParameter("docNo"),"");
			String type = doString.checkString(request.getParameter("type"),"");
			String code = doString.checkString(request.getParameter("code"),"");
			String fdate = doString.checkString(request.getParameter("fdate"),"");
			String fstatus = doString.checkString(request.getParameter("fstatus"),"");
			//String gEventId = doString.checkString(request.getParameter("gEventId"),"");  
			
			//**********For keyin 
			String chkEdit =  doString.checkString(request.getParameter("chkEdit"),""); //YES
			String customerTxt = doString.checkString(request.getParameter("txt1"),"");
			String mobileTxt1 = doString.checkString(request.getParameter("txt2"),"");
			String mobileTxt2 = doString.checkString(request.getParameter("txt3"),"");
			String emailTxt = doString.checkString(request.getParameter("txt4"),"");
			String mobileTxt0 = doString.checkString(request.getParameter("txt5"),"");
			
			MasterSvcService  msService = new MasterSvcServiceImpl();
			
			//1.find customer detail
			ServiceCenterCallService  callService = new ServiceCenterCallServiceImpl();
			String arrStr[] = projectDDL.split("\\:");
			CustomerBean  objResult = callService.GetProjectOfCustomerByHose$Lock(conn, arrStr[0],arrStr[1], houseNo, lock);

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
			//List  listGHomeRepair = msService.ListGroupHomeRepair(conn);
			//List  listGPublicService = msService.ListGroupThePublicService(conn);
			
			//List Date 
			List listDateAppoint = callService.ListAppointDate$SVC(conn, arrStr[0],arrStr[1],Constant.DATE_TYPE_02);
			
			//Get google calendarName
			SVC_STDPJ  calendarObj = callService.GetSVC_STDPJ(conn,arrStr[0],arrStr[1]);
			
			if(!"".equals(fdate) && fdate.length()>0){				
				fdate = fdate.substring(0,16);
			}
			SVC_DOCDT objDocDT = callService.GetSVC_DOCDT(conn, docNo, type, code, fdate, fstatus);
		
			System.out.println("-----Search customer success-------");
			//session.setAttribute(Constant.SS_GHOME_REPAIR_LIST,listGHomeRepair);
			//session.setAttribute(Constant.SS_GPUBLIC_SERVICE_LIST,listGPublicService);	
			
			//*****Set attribute for request
			request.setAttribute("listDateAppoint",listDateAppoint);
			request.setAttribute("CustomerBean",objResult);
			request.setAttribute("SVC_TELNO",objTelNo);
			request.setAttribute("listDOCHD",listDocHd);
			request.setAttribute("SVC_STDPJ",calendarObj);
			request.setAttribute("SVC_DOCDT",objDocDT);
						
			request.setAttribute("employId",employId);
			request.setAttribute("employName",employName);
			request.setAttribute("tel",tel);
			request.setAttribute("agentId",agentId);
			request.setAttribute("projectSel",projectDDL);
			request.setAttribute("houseNo",houseNo);
			request.setAttribute("lock",lock);
			request.setAttribute("mode", "CHANGE_DATE");
			request.setAttribute("chngMode", "CHANGE_DATE");
			request.setAttribute("jobBannDDL", "05");//put off date
					
			//for edit customer
			request.setAttribute("chkEdit",chkEdit);
			request.setAttribute("customerTxt",customerTxt);
			request.setAttribute("mobileTxt1",mobileTxt1);//edit
			request.setAttribute("mobileTxt2",mobileTxt2);
			request.setAttribute("emailTxt",emailTxt);
			request.setAttribute("mobileTxt0", mobileTxt0);
			
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
	
}
