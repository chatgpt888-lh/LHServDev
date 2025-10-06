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
import com.svc.call.bean.SVC_STDPJ;
import com.svc.call.dao.services.Common;
import com.svc.call.dao.services.MasterSvcService;
import com.svc.call.dao.services.MasterSvcServiceImpl;
import com.svc.call.dao.services.ServiceCenterCallService;
import com.svc.call.dao.services.ServiceCenterCallServiceImpl;
import com.svc.call.utilize.Constant;
import com.svc.call.utilize.Utilizer;

public class SVCMasterGCalendarAction extends DispatchAction {
	static String  clazzName =  "SVCMasterGCalendarAction";
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
			//HttpSession session = request.getSession(false);
			System.out.println("-------------Form Load DispatchAction------------------");
			//Test();
			/********** Connection DB *************/
			conn = Common.open();
			Common.defaultTransaction(conn);
			/********** Connection DB *************/
			MasterSvcService  msService = new MasterSvcServiceImpl();
			List projectList = msService.ListProjectAllByBudget(conn);
			
			/**********************************/
			request.setAttribute("projectList", projectList); 
			/************************************/		
			forward = "SHOW_GCALENDAR_FORM";
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
	

	public ActionForward searchCal(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection conn = null;  
		String forward = "";
		try{
			printOutParam(request);
			//HttpSession session = request.getSession(false);
			System.out.println("-------------Form Load DispatchAction------------------");
			//Test();
			/********** Connection DB *************/
			conn = Common.open();
			Common.defaultTransaction(conn);
			/********** Connection DB *************/
			MasterSvcService  msService = new MasterSvcServiceImpl();
			List projectList = msService.ListProjectAllByBudget(conn);
			
			String projectDDL = request.getParameter("projectDDL");
			if("".equals(projectDDL)){
				return mapping.findForward("SHOW_SORRY_PAGE");
			}
			String arrStr[] = projectDDL.split("\\:");
			
			//Get google calendarName
			ServiceCenterCallService  callService = new ServiceCenterCallServiceImpl();
			SVC_STDPJ  calendarObj  = callService.GetSVC_STDPJ(conn,arrStr[0],arrStr[1]);

			/**********************************/
			request.setAttribute("projectList", projectList); 
			request.setAttribute("SVC_STDPJ",calendarObj);
			request.setAttribute("selProj",projectDDL);
			/************************************/		
			forward = "SHOW_GCALENDAR_VIEW";
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
