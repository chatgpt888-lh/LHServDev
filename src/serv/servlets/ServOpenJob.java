package serv.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.io.File;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import serv.common.Constants;
import serv.common.User;
import serv.model.ListInfOpenJobBean;
import serv.model.ServInfOpenJobBean;
import serv.service.ServOpenJobService;
import serv.service.ServOpenJobServiceImpl;

import com.svc.call.ws.webservice.WebService;
import com.lh.exception.InvalidParameterException;
import com.lh.servlet.DBServlet;
import com.lh.util.doString;


public class ServOpenJob extends DBServlet {
	
	private void genRedirectCode(PrintWriter out,String page,String redirect,String error,String otherMsg) {
		out.println("<form method='post' action='"+page+"'>");		
		out.println("<input type='hidden' name='error' value='"+error+"'>");
		out.println("<input type='hidden' name='other_msg' value='"+doString.MS874ToUnicode(otherMsg)+"'>");
		out.println("<input type='hidden' name='redirect_url' value='"+doString.MS874ToUnicode(redirect)+"'>");		
		out.println("<script> document.forms[0].submit();</script>");
		out.println("</form>");		
	}
	
	private ServOpenJobService getService(){
		ServOpenJobService service = new ServOpenJobServiceImpl();
		return service;
	}
	
	public void performTask(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
		String actionMode = (String)request.getParameter("actionMode");
		if(actionMode.equals("deleteItem"))
			this.deleteItem(request, response);
		if(actionMode.equals("addJobList"))
			this.addItem(request, response);
		if(actionMode.equals("prepareForm"))
			this.prepareForm(request, response);
		if(actionMode.equals("initForm")){
			this.initForm(request, response);
		}if(actionMode.equals("saveOpenJob")|actionMode.equals("sendToApprove")){
			this.saveOpenJob(request, response);
		}if(actionMode.equals("editOpenJob")){
			this.editOpenJobForm(request, response);
		}if(actionMode.equals("back")){
			request.getSession().removeAttribute("listOpenJob");
			RequestDispatcher rd = request.getRequestDispatcher("SERV_Home.jsp");
			try {
				rd.forward(request, response);
			} catch (IOException e) {
				e.printStackTrace();
			}	
		}if(actionMode.equals("home")){
			request.getSession().removeAttribute("listOpenJob");
			RequestDispatcher rd = request.getRequestDispatcher("SERV_Home.jsp");
			try {
				rd.forward(request, response);
			} catch (IOException e) {
				e.printStackTrace();
			}	
		}if(actionMode.equals("")){
			this.prepareForm(request, response);
		}
	}
	
	public void openJob(HttpServletRequest request, HttpServletResponse response) throws ServletException{
		System.out.println("test servlete2");
		
		try {
			response.sendRedirect(Constants.OPENJOB_PAGE);
			
		} catch (IOException e) {
			e.printStackTrace();
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}
	
	private boolean checkValueItmjob(ArrayList tempOpenJob, String itmjob ){
		for(int i=0;i<tempOpenJob.size(); i++){
			ListInfOpenJobBean listInfOpenJobBean = (ListInfOpenJobBean)tempOpenJob.get(i);
			String tempItmjob = listInfOpenJobBean.getI_itmjob();
			if((itmjob.trim()).equalsIgnoreCase(tempItmjob.trim())){
				return true;
			}
		}
		
		return false;
	}
	
	private String checkItmjob(ArrayList tempOpenJob, String[]addItem){
		String param_itmjob = "";
		String param_itmjob_new = "";
		if(tempOpenJob!=null && addItem!=null){
			
			for(int i=0;i<addItem.length; i++){
				param_itmjob+=addItem[i]+",";
/*				
				if(!this.checkValueItmjob(tempOpenJob, addItem[i]))
					param_itmjob+=addItem[i]+",";
*/					
			}
		}
		if(!param_itmjob.equals(""))
			param_itmjob_new = param_itmjob.substring(0, param_itmjob.length()-1);
		
		return param_itmjob_new;
	}
	
	public void listItemJob(HttpServletRequest request, HttpServletResponse response) throws ServletException{
		System.out.println("//--- list item job ---//");
		ServInfOpenJobBean openJobBean = new ServInfOpenJobBean();
		String param_itmjob = "";
		ArrayList tempListOpenJob = new ArrayList();
		ServOpenJobService service = this.getService();
		try {
			String[]boqItemSelect = (String[])request.getAttribute("cartItem");
			
			request.setAttribute("cartItem", boqItemSelect);
			if(request.getSession().getAttribute("param_itmjob")!=null){
				param_itmjob = (String)request.getSession().getAttribute("param_itmjob");
			}
			
			if(request.getAttribute("cartItem")!=null){
				String[]cartItem = (String[])request.getAttribute("cartItem");
				if(!param_itmjob.equals(",") && !param_itmjob.equals(""))
					param_itmjob+=",";
				
				for(int i=0; i<cartItem.length; i++){
					if(i==cartItem.length-1)
						param_itmjob+=cartItem[i];
					else
						param_itmjob+=cartItem[i]+",";								
				}
				
				request.getSession().setAttribute("param_itmjob",param_itmjob);							
			}
			
			if(request.getSession().getAttribute("listOpenJob")!=null){
				openJobBean = (ServInfOpenJobBean)request.getSession().getAttribute("listOpenJob");
				tempListOpenJob = openJobBean.getListInfBoq();
			}
			/////
			String itmjob = this.checkItmjob(tempListOpenJob, boqItemSelect);
System.out.println("itmjob : "+itmjob);			
			if(itmjob!=null && itmjob!=""){
				
				ArrayList listOpenJob = service.listOpenJob(itmjob);
					
				for(int i=0; i<listOpenJob.size(); i++){
					ListInfOpenJobBean listInfOpenJobBean = (ListInfOpenJobBean)listOpenJob.get(i);
					tempListOpenJob.add(listInfOpenJobBean);
				}
				openJobBean.setListInfBoq(tempListOpenJob);
				request.getSession().removeAttribute("param_itmjob");
				request.getSession().setAttribute("listOpenJob", openJobBean);
				
			}
			
			RequestDispatcher rd = request.getRequestDispatcher("SERV_InfOpenJob.jsp");
			rd.forward(request, response);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}
	
	public void prepareForm(HttpServletRequest request, HttpServletResponse response) throws ServletException{
		System.out.println("//--- prepareForm ---//");
		try {
			String sel_project = request.getParameter("sel_project");
			String i_approver = request.getParameter("approver");
			String d_appoint = request.getParameter("d_appoint");
			String d_est_close = request.getParameter("d_est_close");
			String i_itmtype = doString.checkString(request.getParameter("i_itmtype"));
			
			//double grandTotal = Double.parseDouble(doString.checkString(request.getParameter("grandTotal"),"0"));
			double amount = Double.parseDouble(doString.checkString(request.getParameter("amount"),"0"));
			
			ServInfOpenJobBean openJobBean = (ServInfOpenJobBean)request.getSession().getAttribute("listOpenJob");
			if(openJobBean!=null){
				ArrayList listBean = openJobBean.getListInfBoq();
				listBean = this.addTempOpenJoblist(request);
				
				if(sel_project==null)
					sel_project = openJobBean.getI_project();
				
				openJobBean.setI_project(sel_project);
				openJobBean.setI_approver(i_approver);
				openJobBean.setD_appoint(d_appoint);
				openJobBean.setD_est_close(d_est_close);
				openJobBean.setI_itmtype(i_itmtype);
				if(openJobBean.getGrandTotal()>amount)
					openJobBean.setI_chart_grp("Z");
				else	
					openJobBean.setI_chart_grp("M");
					
				openJobBean.setListInfBoq(listBean);
				request.getSession().removeAttribute("listOpenJob");
				request.getSession().setAttribute("listOpenJob", openJobBean);
				
			}else{
				openJobBean = new ServInfOpenJobBean();
				openJobBean.setI_project(sel_project);
				openJobBean.setI_approver(i_approver);	
				openJobBean.setD_appoint(d_appoint);
				openJobBean.setD_est_close(d_est_close);
				openJobBean.setI_itmtype(i_itmtype);
				if(openJobBean.getGrandTotal()>amount)
					openJobBean.setI_chart_grp("Z");
				else	
					openJobBean.setI_chart_grp("M");
				
				request.getSession().removeAttribute("listOpenJob");
				request.getSession().setAttribute("listOpenJob", openJobBean);
			}
			RequestDispatcher rd = request.getRequestDispatcher("SERV_InfOpenJob.jsp");
			rd.forward(request, response);
			
		} catch (IOException e) {
			e.printStackTrace();
		} catch (Exception ex) {
			ex.printStackTrace();
		}
		
	}
	
	public void initForm(HttpServletRequest request, HttpServletResponse response) throws ServletException{
		System.out.println("//--- initForm ---//");
		try {
			String i_itmtype = doString.checkString(request.getParameter("i_itmtype"));
			String sel_project = doString.checkString(request.getParameter("sel_project"));
			
			request.getSession().removeAttribute("listOpenJob");
			request.getSession().removeAttribute("listJobItem");
			request.getSession().removeAttribute("beanPage");				
			ServInfOpenJobBean openJobBean = new ServInfOpenJobBean();
			openJobBean.setI_project(sel_project);
			openJobBean.setI_itmtype(i_itmtype);
			request.getSession().setAttribute("listOpenJob", openJobBean);
			RequestDispatcher rd = request.getRequestDispatcher("SERV_InfOpenJob.jsp");
			rd.forward(request, response);
		} catch (IOException e) {
			e.printStackTrace();
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}
	
	public void addItem(HttpServletRequest request, HttpServletResponse response) throws ServletException,IOException{
		System.out.println("//--- addItem ---//");
		
		try {
			String sel_project = request.getParameter("sel_project");
			String i_approver = request.getParameter("approver");
			String d_appoint = request.getParameter("d_appoint");
			String d_est_close = request.getParameter("d_est_close");
			String i_itmtype = doString.checkString(request.getParameter("i_itmtype"));
			
			ServInfOpenJobBean openJobBean = (ServInfOpenJobBean)request.getSession().getAttribute("listOpenJob");
			if(openJobBean!=null){
				ArrayList listBean = openJobBean.getListInfBoq();
				listBean = this.addTempOpenJoblist(request);
				
				if(sel_project==null)
					sel_project = openJobBean.getI_project();
				
				openJobBean.setI_project(sel_project);
				openJobBean.setI_approver(i_approver);
				openJobBean.setD_appoint(d_appoint);
				openJobBean.setD_est_close(d_est_close);
				openJobBean.setI_itmtype(i_itmtype);
				openJobBean.setListInfBoq(listBean);
				request.getSession().removeAttribute("listOpenJob");
				request.getSession().setAttribute("listOpenJob", openJobBean);
			}else{
				openJobBean = new ServInfOpenJobBean();
				openJobBean.setI_project(sel_project);
				openJobBean.setI_approver(i_approver);
				openJobBean.setD_appoint(d_appoint);
				openJobBean.setD_est_close(d_est_close);
				openJobBean.setI_itmtype(i_itmtype);
				request.getSession().removeAttribute("listOpenJob");
				request.getSession().setAttribute("listOpenJob", openJobBean);
			}
			
			//request.getSession().removeAttribute("param_itmjob");
			request.getSession().removeAttribute("listJobItem");
			request.getSession().removeAttribute("beanPage");			
			response.sendRedirect(Constants.BOQSrch_PAGE);
			
		} catch (IOException e) {
			e.printStackTrace();
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	private ArrayList addTempOpenJoblist(HttpServletRequest request) throws ServletException{
		System.out.println("//--- addTempOpenJob ---//");
		ArrayList tempListOpenJob = new ArrayList();
		//-----------------------------------------------------------------------------
		String[] vendor = request.getParameterValues("vendor");				//ผู้รับเหมาซ่อม
		String[] itmType = request.getParameterValues("itmtype");			//ประเภทงาน
		
		String[] customwage = request.getParameterValues("customwage");		//ต่อหน่วย
		String[] wage = request.getParameterValues("wage");					//จำนวน
		String[] wage_sum = request.getParameterValues("wage_sum");			//รวม
		String[] customgoods = request.getParameterValues("customgoods");	//ต่อหน่วย
		String[] goods = request.getParameterValues("goods");				//จำนวน
		String[] goods_sum = request.getParameterValues("goods_sum");		//รวม
		String[] estimate = request.getParameterValues("estimate");			//ประมาณการคชจ.ซ่อม
		String[] sum_total = request.getParameterValues("sum_total");		//รวมเงิน
		
		String[] comment = request.getParameterValues("comment");			//หมายเหตุ์
		String[] area = request.getParameterValues("area");					//บริเวณ
		
		double totalWage = 0.0;
		double totalGoods = 0.0;
		double totalEstimate = 0.0;
		double grandTotal = 0.0;
		
		ServInfOpenJobBean openJobBean = (ServInfOpenJobBean)request.getSession().getAttribute("listOpenJob");
		if(openJobBean!=null){
			
			ArrayList listOpenJob = openJobBean.getListInfBoq();
			for(int i=0; i<listOpenJob.size(); i++){
				ListInfOpenJobBean listInfOpenJobBean = (ListInfOpenJobBean)listOpenJob.get(i);
				if (listInfOpenJobBean != null) {
					//sumWage = Double.parseDouble(doString.displayNumber("#######0.00",sumWage));
					listInfOpenJobBean.setI_itmtype(itmType[i]);
					listInfOpenJobBean.setI_vender(		vendor[i]);
					listInfOpenJobBean.setCustom_wage(	Double.parseDouble(customwage[i].replace(",", "")));
					listInfOpenJobBean.setWage(			Double.parseDouble(wage[i].replace(",", "")));
					listInfOpenJobBean.setWage_sum(		Double.parseDouble(wage_sum[i].replace(",", "")));
					listInfOpenJobBean.setCustom_goods(	Double.parseDouble(customgoods[i].replace(",", "")));
					listInfOpenJobBean.setGoods(		Double.parseDouble(goods[i].replace(",", "")));
					listInfOpenJobBean.setGoods_sum(	Double.parseDouble(goods_sum[i].replace(",", "")));
					listInfOpenJobBean.setEstimate(		Double.parseDouble(estimate[i].replace(",", "")));
					listInfOpenJobBean.setSum_total(	Double.parseDouble(sum_total[i].replace(",", "")));
					listInfOpenJobBean.setComment(		comment[i]);
					listInfOpenJobBean.setArea(			area[i]);
					tempListOpenJob.add(listInfOpenJobBean);	
				}
				totalWage = totalWage+Double.parseDouble(wage_sum[i].replace(",", ""));
				totalGoods = totalGoods+Double.parseDouble(goods_sum[i].replace(",", ""));
				totalEstimate = totalEstimate+Double.parseDouble(estimate[i].replace(",", ""));
				grandTotal = grandTotal+Double.parseDouble(sum_total[i].replace(",", ""));
			}// end for
			openJobBean.setTotalWage(totalWage);
			openJobBean.setTotalGoods(totalGoods);
			openJobBean.setTotalEstimate(totalEstimate);
			openJobBean.setGrandTotal(grandTotal);
		
		}
		
		return tempListOpenJob;
	}
	
	
	public void deleteItem(HttpServletRequest request, HttpServletResponse response) throws ServletException{
		System.out.println("//--- deleteItem ---//");
		try {
			ArrayList listValue = new ArrayList();
			ArrayList listBean = new ArrayList();
			String[] deleteItem = request.getParameterValues("del_checkbox");
					
			ServInfOpenJobBean openJobBean = (ServInfOpenJobBean)request.getSession().getAttribute("listOpenJob");
			if(openJobBean!=null){
				listBean = openJobBean.getListInfBoq();
				listBean = this.addTempOpenJoblist(request);
			}
			if(deleteItem!=null){
				outter:for(int i=0;i<deleteItem.length; i++){
					String delete = doString.checkString(doString.DisplayThai(deleteItem[i]));
					
					for(int j=0; j<listBean.size(); j++){
						ListInfOpenJobBean listInfOpenJobBean = (ListInfOpenJobBean)listBean.get(j);
						
						if(listInfOpenJobBean!=null){
							String i_itmjob = doString.checkString(doString.DisplayThai(listInfOpenJobBean.getI_itmjob()));
							
							if(i_itmjob.equalsIgnoreCase(delete)){
								//Found Delete and continue
								listBean.set(j, null);
								continue outter;
							}else{
								continue;
							}
						}
					}
				}
				
				for(int i=0; i<listBean.size(); i++){
					ListInfOpenJobBean listInfOpenJobBean = (ListInfOpenJobBean)listBean.get(i);
					if(listInfOpenJobBean==null){
						listBean.remove(i);
					}
				}
				
			}
			
			for(int i=0; i<listBean.size(); i++){
				ListInfOpenJobBean listInfOpenJobBean = (ListInfOpenJobBean)listBean.get(i);
				if(listInfOpenJobBean!=null){
					listValue.add(listInfOpenJobBean);
				}
			}
			
			if(openJobBean!=null){
				openJobBean.setListInfBoq(listValue);
				request.getSession().setAttribute("listOpenJob", openJobBean);
			}
			
			RequestDispatcher rd = request.getRequestDispatcher("SERV_InfOpenJob.jsp");
			rd.forward(request, response);
			
		} catch (IOException e) {
			e.printStackTrace();
		} catch (Exception ex) {
			ex.printStackTrace();
		}
		
	}
	
	public void prepareForm(HttpServletRequest request) throws ServletException{
		System.out.println("//--- prepareForm ---//");
		try {
			String sel_project = request.getParameter("sel_project");
			String i_approver = request.getParameter("approver");
			String d_appoint = request.getParameter("d_appoint");
			String d_est_close = request.getParameter("d_est_close");			
			String i_itmtype = doString.checkString(request.getParameter("i_itmtype"));
			ServInfOpenJobBean openJobBean = (ServInfOpenJobBean)request.getSession().getAttribute("listOpenJob");
			if(openJobBean!=null){
				ArrayList listBean = openJobBean.getListInfBoq();
				listBean = this.addTempOpenJoblist(request);
				
				if(sel_project==null)
					sel_project = openJobBean.getI_project();
				
				openJobBean.setI_project(sel_project);
				openJobBean.setI_approver(i_approver);
				openJobBean.setD_appoint(d_appoint);
				openJobBean.setD_est_close(d_est_close);
				openJobBean.setI_itmtype(i_itmtype);
				openJobBean.setListInfBoq(listBean);
				request.getSession().removeAttribute("listOpenJob");
				request.getSession().setAttribute("listOpenJob", openJobBean);
				
			}else{
				openJobBean = new ServInfOpenJobBean();
				openJobBean.setI_project(sel_project);
				openJobBean.setI_approver(i_approver);	
				openJobBean.setD_appoint(d_appoint);
				openJobBean.setD_est_close(d_est_close);
				openJobBean.setI_itmtype(i_itmtype);
				request.getSession().removeAttribute("listOpenJob");
				request.getSession().setAttribute("listOpenJob", openJobBean);
			}
		
		} catch (Exception ex) {
			ex.printStackTrace();
		}
		
	}
	
	public void editOpenJobForm(HttpServletRequest request, HttpServletResponse response) throws ServletException,IOException{
		System.out.println("//--- edit openjob ---//");
		HttpSession session = request.getSession(false);
		Object obj = session.getAttribute("USER");
		if (obj == null) {
			response.sendRedirect(Constants.WARNING_PAGE);
			return;
		}
		User user = (User) obj;
		String sessionId = user.getsessionId();
		String mode = request.getParameter("mode");
		String i_docno = doString.checkString(request.getParameter("docNo"));
		String realPath = getServletContext().getRealPath("/");
		String tempPath = realPath + "/attach/temp/"+sessionId;
		
		
		//----- clear temp upload path -----//
		File tmpFolder = new File(tempPath);
		if (tmpFolder.exists() && tmpFolder.isDirectory()) {
			File[] listTmp = tmpFolder.listFiles();
			if (listTmp!=null) {
				for (int f=0;f<listTmp.length;f++) {
					listTmp[f].delete();	
				} // end for
			}
		} else {
			tmpFolder.mkdirs();
		}
		String attachPath = realPath + "/attach/lh/"+i_docno;		
		
		ServInfOpenJobBean openJobBean = new ServInfOpenJobBean();
		ServOpenJobService service = this.getService();
		try {
			openJobBean = service.findOpenJob(i_docno, attachPath, tempPath);
			openJobBean.setMode(mode);
			request.getSession().setAttribute("listOpenJob", openJobBean);
			RequestDispatcher rd = request.getRequestDispatcher("SERV_InfOpenJob.jsp");
			rd.forward(request, response);
		
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
	}
	
	public void saveOpenJob(HttpServletRequest request, HttpServletResponse response) throws ServletException,IOException{
		String mName = new String(this.getClass().getName() + ".performTask: ");
		System.out.println("//--- save openjob ---//");
		
		
		HttpSession session = request.getSession(false);
		if (session == null) {
			response.sendRedirect(Constants.WARNING_PAGE);
			return;
		}
		Object obj = session.getAttribute("USER");
		if (obj == null) {
			response.sendRedirect(Constants.WARNING_PAGE);
			return;
		}
		
		User user = (User) obj;
		String userId = user.getUserID();
		String sessionId = user.getsessionId();
		String realPath = getServletContext().getRealPath("/");
		String attachPath = realPath + "/attach/lh/";
		//String tempPath = getServletContext().getRealPath("/attach/temp/")+File.separator+sessionId;
		String tempPath = realPath+"/attach/temp/"+sessionId;
		
		
		
		doString str = new doString();		 		
		response.setContentType("text/html; charset=TIS620");
		PrintWriter out = response.getWriter();

		
		String savePage = Constants.SAVE_PAGE;
		String successPage = "";
		String errorPage = "SERV_InfOpenJob.jsp?error=1";
		
		String otherMsg = "";
		String errorCode = "";
		String i_itmtype = doString.checkString(request.getParameter("i_itmtype"));		
		errorPage = "SERV_InfOpenJob.jsp?error=1&itmType="+i_itmtype;
		String save_type = request.getParameter("actionMode");	//save Openjob, send to approve		
		ServOpenJobService service = this.getService();
		
		try {
			this.prepareForm(request);
			String mode = "";
			ServInfOpenJobBean openJobBean = (ServInfOpenJobBean)request.getSession().getAttribute("listOpenJob");
			if (openJobBean != null) {
				openJobBean.setI_user(userId);
				mode = openJobBean.getMode();
				if(mode.equalsIgnoreCase("E")){
					
					service.updateOpenJob(openJobBean,save_type,attachPath,tempPath);	//--edit
					request.getSession().removeAttribute("listOpenJob");
				}else{
					service.createOpenJob(openJobBean,save_type,attachPath,tempPath);//--new create
					request.getSession().removeAttribute("listOpenJob");
				}
			}
			if(save_type.equals("saveOpenJob"))
				successPage = "SERV_INFOpenJob_Disp.jsp?docNo="+openJobBean.getI_docno()+"&mode=E&chartGrp=S&itmType="+i_itmtype;
			else if(save_type.equals("sendToApprove"))
				successPage = "SERV_INFOpenJob_Disp.jsp?docNo="+openJobBean.getI_docno()+"&chartGrp=S&itmType="+i_itmtype;
			
			//----- clear temp upload path -----//
			File delFolder = new File(tempPath);
			if (delFolder.exists() && delFolder.isDirectory()) {
				File[] listTmp = delFolder.listFiles();
				if (listTmp!=null) {
					for (int f=0;f<listTmp.length;f++) {
						listTmp[f].delete();	
					} // end for
				}
				delFolder.delete();	
			}			
			
			genRedirectCode(out,savePage,successPage,errorCode,otherMsg);
			
		} catch (Exception e) {
			///if (e instanceof InvalidParameterException) {
				showError(out, doString.UnicodeToMS874(e.getMessage()));
			//} else {           
				System.out.println(" ERROR "+mName+" : " + e.getMessage());
	
			//}
		
			response.sendRedirect(errorPage);
			System.out.println("error = "+errorPage);
			genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ : "+e.getMessage());
		}
		
	}
	
}