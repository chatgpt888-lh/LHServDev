/*
 * Created on Mar 29, 2012
 *
 * To change the template for this generated file go to
 * Window&gt;Preferences&gt;Java&gt;Code Generation&gt;Code and Comments
 */
package com.svc.call.web.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;

import com.svc.call.dao.services.Common;
import com.svc.call.utilize.Constant;


/**
 * @author Administrator
 *
 * To change the template for this generated type comment go to
 * Window&gt;Preferences&gt;Java&gt;Code Generation&gt;Code and Comments
 */
public class TestBlankDispatchAction extends DispatchAction {
	static{
		//initial  First Request  configure  datasouce only
		//Use  connection db server type  Connection pool
		Common.setConfigForConnectionPool("", Constant.DataSourceName);
	}
	
	public ActionForward formLoad(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
	      
		String forward = "";
		try{
			System.out.println("-------------TestBlankDispatchAction------------------");
			Test();
			forward = "success";
			
		}catch(Exception e){
			forward = "sorry";
			e.fillInStackTrace();
		 }		
		return mapping.findForward(forward);
   }
	
	private static void Test(){
		Connection conn = null;
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try{
			
			//jdbc:informix-sqli://132.146.1.130:6848/lan:INFORMIXSERVER=ol_informix1170
			
			conn = Common.open();
			Common.defaultTransaction(conn);
			
			sql.delete(0,sql.length());
			sql.append(" SELECT date('2013-02-15')+? as DD FROM crm:crm_xtime  ");
			
			for(int i=0;i<30;i++){			
				pstmt = conn.prepareStatement(sql.toString()); 
				pstmt.setInt(1,i);
				rs = pstmt.executeQuery();
				
				if(rs.next()){				
					System.out.println(i+": "+rs.getString("DD"));
				}
			}
			rs.close();	
			pstmt.close();
			
		}catch(Exception e){
			if(conn!=null){
				try {
					conn.close();
				} catch (SQLException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
			}
		}
	}

}
