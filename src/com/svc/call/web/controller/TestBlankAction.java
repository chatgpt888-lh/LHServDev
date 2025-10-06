package com.svc.call.web.controller;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

public class TestBlankAction extends Action {
	
	public ActionForward execute(ActionMapping actionMapping, ActionForm actionForm, HttpServletRequest request, HttpServletResponse response)throws Exception{
	 ActionForward forward = null;
	 
	 try{
			 System.out.println("------>TestBankAction process..");
			 //ystem.out.println("xx:"+request.getParameter("test"));
			 forward = actionMapping.findForward("success");		
		 
		}catch(Exception e){
		   e.printStackTrace();
		}
		return forward;
 }

}
