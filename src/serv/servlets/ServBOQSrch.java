package serv.servlets;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import serv.common.Constants;
import serv.model.ListServInfBoqBean;
import serv.model.PageBean;
import serv.model.ServInfBoqBean;
import serv.service.ServService;
import serv.service.ServServiceImpl;

import com.lh.servlet.DBServlet;
import com.lh.util.*;

public class ServBOQSrch extends DBServlet {
	private int pageNO = 1;
	private int pageSize = 0;
	private HashMap tempCart = new HashMap();
	
	private ServService getService(){
		ServService service = new ServServiceImpl();
		return service;
	}
	 
	public void performTask(HttpServletRequest request, HttpServletResponse response) throws ServletException{
		String action = request.getParameter("actionMode");
		if(action.equals("search"))
			this.listInfBoq(request, response);
		else if(action.equals("actionPage"))
			this.changePage(request, response);
		else if(action.equals("addToCart"))
			this.addToCart(request, response);
		else if(action.equals("checkOut"))
			this.addToCart(request, response);
		else if(action.equals("back")){
			request.getSession().removeAttribute("listJobItem");
			request.getSession().removeAttribute("beanPage");
			RequestDispatcher rd = request.getRequestDispatcher("SERV_InfOpenJob.jsp");
			try {
				rd.forward(request, response);
			} catch (IOException e) {
				
				e.printStackTrace();
			}
		}
			
			
	}
	
	public void changePage(HttpServletRequest request, HttpServletResponse response)throws ServletException{
		System.out.println("//---- chang page ----//");
		try {
			int nowPage = Integer.parseInt(doString.checkString(request.getParameter("now_page"),"1"));
			int display_line =  Integer.parseInt(doString.checkString(request.getParameter("display_line"),"0")); 	//จำนวนแถวต่อหน้า
			String searchMode = doString.checkString(request.getParameter("searchMode"));							//like,group
			String display_type = doString.checkString(request.getParameter("display_type"));						//ListByPage,ListALL
			
			ListServInfBoqBean infBoqBean = (ListServInfBoqBean)request.getSession().getAttribute("listJobItem");
			PageBean pageBean = (PageBean)request.getSession().getAttribute("beanPage");
			
			String n_itmjob = infBoqBean.getN_itmjob();
			String i_group = infBoqBean.getI_group();
			String i_type = infBoqBean.getI_type();
			int max_row = infBoqBean.getMax_row();
			
			int startRow = ((nowPage-1)*display_line);
			int endRow = startRow+display_line;
			int tmpMax = max_row;
	
			String pageLink = this.getPageLink(tmpMax, display_line, nowPage);
			pageBean.setNowPage(nowPage);
			pageBean.setPageLink(pageLink);
			
			ServService service = this.getService();
			if(searchMode.equals("like"))
				infBoqBean = service.listInfBoqByLike(infBoqBean.getN_itmjob(), max_row, startRow, endRow,display_type);
			else
				infBoqBean = service.listInfBoqByGroup(infBoqBean.getI_type(), infBoqBean.getI_group(), max_row, startRow, endRow,display_type);
			
			pageBean.setMaxRow(max_row);
			infBoqBean.setN_itmjob(n_itmjob);
			infBoqBean.setI_group(i_group);
			infBoqBean.setI_type(i_type);
			infBoqBean.setMax_row(max_row);
			infBoqBean.setDisplay_type(display_type);
			
			request.getSession().setAttribute("beanPage",pageBean);
			request.getSession().setAttribute("listJobItem", infBoqBean);
			RequestDispatcher rd = request.getRequestDispatcher("SERV_INFBOQSrch.jsp");
			rd.forward(request, response);
			
			//-- forward --//
			System.out.println("//----- forward -----//");
		
		}catch (Exception e) {
			System.out.println("ERROR SERV_INFBOQSrch.jsp : " + e.getMessage());
			throw new ServletException(e.getMessage());
		}
		
	}
	
	public void listInfBoq(HttpServletRequest request, HttpServletResponse response) throws ServletException{
		System.out.println("//---- listInfBoq ----//");
		try {
			ServService service = this.getService();
			ListServInfBoqBean infBoqBean = new ListServInfBoqBean();
			ArrayList listJobItem = new ArrayList();
			String n_itmjob = doString.checkString(request.getParameter("n_itmjob"));
			String i_group 	= doString.checkString(doString.DisplayThai(request.getParameter("i_group")));
			String i_type 	= doString.checkString(doString.DisplayThai(request.getParameter("i_type")));
			String searchMode = doString.checkString(request.getParameter("searchMode"));							//like,group
			String display_type = doString.checkString(request.getParameter("display_type"));						//ListByPage,ListALL
			int display_line =  Integer.parseInt(doString.checkString(request.getParameter("display_line"),"0")); 	//จำนวนแถวต่อหน้า
			
			int nowPage = 1;
			int max_row = 0;
			if(searchMode.equals("like"))
				max_row = service.getMaxRow(i_type, i_group,n_itmjob,"like");
			else
				max_row = service.getMaxRow(i_type, i_group,n_itmjob,"group");
			
			PageBean pageBean = (PageBean)request.getSession().getAttribute("beanPage");
			if(pageBean==null)
				pageBean = new PageBean();
			
			if(display_type.equals("ListALL"))
				display_line = max_row;
			
			int startRow = ((nowPage-1)*display_line);
			int endRow = startRow+display_line;
			int tmpMax = max_row;

			String pageLink = this.getPageLink(tmpMax, display_line, nowPage);
			
			pageBean.setNowPage(nowPage);
			pageBean.setPageLink(pageLink);
			
			if(searchMode.equals("like"))
				infBoqBean = service.listInfBoqByLike(n_itmjob, max_row, startRow, endRow,display_type);
			else
				infBoqBean = service.listInfBoqByGroup(i_type, i_group, max_row, startRow, endRow,display_type);
			
			pageBean.setMaxRow(infBoqBean.getMax_row());
			
			infBoqBean.setN_itmjob(n_itmjob);
			infBoqBean.setI_group(i_group);
			infBoqBean.setI_type(i_type);
			infBoqBean.setMax_row(max_row);
			infBoqBean.setDisplay_type(display_type);
			
			//this.tempCart = new HashMap();
			
			request.getSession().setAttribute("listJobItem", infBoqBean);
			RequestDispatcher rd = request.getRequestDispatcher("SERV_INFBOQSrch.jsp");
			rd.forward(request, response);
			
			//-- forward --//
			System.out.println("//----- forward -----//");
			
			
		}catch (Exception e) {
			System.out.println("ERROR SERV_INFBOQSrch.jsp : " + e.getMessage());
			throw new ServletException(e.getMessage());
		}
	}
	
	public void addToCart(HttpServletRequest request, HttpServletResponse response) throws ServletException{
		try {
			RequestDispatcher rd = null;
			
			String action = request.getParameter("checkOut");
			
			String nowPage 		= doString.checkString(request.getParameter("now_page"),"1");
			String[] checkItem 	= request.getParameterValues("del_checkbox");
			String[] tempCart 	= new String[0];
			String[] itemId = new String[1];
			int numItem = 0;
			
			if(nowPage!=null &&checkItem!=null ){
				//tempCart = this.addTemp(nowPage, checkItem);
				numItem = checkItem.length;
				for (int i=0; i<numItem; i++) {
					itemId[0] = doString.checkString(checkItem[i]);
					if (!itemId[0].equals("")) {
						tempCart = this.addTemp(itemId[0], itemId);
					}
				}// end for
				request.getSession().setAttribute("addToCart", tempCart);
			}
			
			if(action.equals("checkOut")){
				String[]boqItemSelect = (String[])request.getSession().getAttribute("addToCart");
				if(boqItemSelect!=null){
					request.setAttribute("cartItem", boqItemSelect);
					
					//Clear All
					request.getSession().removeAttribute("addToCart");
					request.getSession().removeAttribute("listJobItem");
					request.getSession().removeAttribute("beanPage");
					//this.tempCart = null;
					this.tempCart.clear();
				}
				
				//response.sendRedirect("/LHServ/ServOpenJob?method=post&mode=prepareForm");
				ServOpenJob openJob = new ServOpenJob();
				openJob.listItemJob(request, response);
			}
			else{
				rd = request.getRequestDispatcher("SERV_INFBOQSrch.jsp");
				rd.forward(request, response);
			}
			
		
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	private String[] addTemp(String now_page, String[]checkItem)throws ServletException{
		String[]tempValue = null;
		String checkValue = "";
		int num=0;
		if(this.tempCart!=null){
			
			this.tempCart.put(now_page, checkItem);
			
			Set set = this.tempCart.entrySet();
			Iterator iterator = set.iterator(); 
			while(iterator.hasNext())
			{
				Map.Entry map = (Map.Entry)iterator.next();
				String[] temp = (String[])map.getValue();
				if(temp!=null){
					for(int i=0; i<temp.length; i++){
						num++;
						checkValue+=temp[i]+",";
					}// end for
				}				
			}
				
			tempValue = checkValue.split(",");
		}
		for (int i=0; i<num; i++) {
			System.out.println("tempCart : "+tempValue[i]);
		}
		return tempValue;
	}

	public void chectOut(HttpServletRequest request, HttpServletResponse response) throws ServletException{
		try {
			
			String[]boqItemSelect = (String[])request.getSession().getAttribute("addToCart");
			if(boqItemSelect!=null){
				request.setAttribute("cartItem", boqItemSelect);
				request.getSession().removeAttribute("addToCart");
				request.getSession().removeAttribute("listJobItem");
				request.getSession().removeAttribute("beanPage");
				//this.tempCart = null;
				this.tempCart.clear();
			}
			
			ServOpenJob openJob = new ServOpenJob();
			openJob.listItemJob(request, response);
			//RequestDispatcher rd = request.getRequestDispatcher("SERV_InfOpenJob.jsp");
			//rd.forward(request, response);
		} catch (Exception e) {
			e.printStackTrace();
		}
		
	}
	
	private String getPageLink(int tmpMax,int display_line, int nowPage){
		String pageLink = "";
		int tmpPage = 0;
		
		while (tmpMax>0) {
			tmpMax -= display_line;
		    tmpPage++;
		    if (nowPage==tmpPage) {
		    	pageLink += "&nbsp; <b>"+tmpPage+"</b> ";
		    } else {
		    	pageLink += "&nbsp; <a href='#' onclick='changePage("+tmpPage+");'>"+tmpPage+"</a> ";
		    }
		}
		
		if(tmpPage>1) {
			int prev = nowPage-1;
			if (prev<1) prev=1;  
				pageLink = "<a href='#' onclick='changePage("+prev+");'>หน้าก่อน</a>&nbsp; "+pageLink;
				int next = nowPage+1;
			if (next>tmpPage) next = tmpPage;
		      	pageLink += "&nbsp; <a href='#' onclick='changePage("+next+");'>หน้าถัดไป</a>";      
		}else{
		    pageLink = "หน้า <b>1</b>";
		}
		
		return pageLink;
	}
	
	
}