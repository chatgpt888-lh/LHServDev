package com.test;

import com.lh.util.doString;
import com.svc.call.dao.services.Common;
import com.svc.call.dao.services.ServiceCenterCallServiceImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class TestQuery extends Common{

	/**
	 * @param args
	 */
	static{
		//132.146.1.130
		//Common.setConfig("132.146.1.130", "6848", "lan", "informix", "informix", "ol_informix1170");
		Common.setConfig("132.146.1.2", "1530", "lan", "bck", "bck", "onnetimp");
	}
	
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		 //Test2();
		 Test3();
		
		//Test();
	}
	
	
	private static void Test3(){
		Connection conn = null;
		try{
			//jdbc:informix-sqli://132.146.1.130:6848/lan:INFORMIXSERVER=ol_informix1170			
			conn = open();
			
			//ReportCallService service = new ReportCallServiceImpl();
			//service.ListGenReportMonthByProject(conn, "LH", "011", "2013");
	
			//System.out.println("SQL :"+sql);
			
			ServiceCenterCallServiceImpl call = new  ServiceCenterCallServiceImpl();
			int x = call.GetCountRowByHistoryHomeRepair$1Y(conn, "LH","075","176/52","01A01");
			System.out.println("TEST :"+x);
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
	
	
	
	
	
	private static void Test2(){
		Connection conn = null;
		try{
			//jdbc:informix-sqli://132.146.1.130:6848/lan:INFORMIXSERVER=ol_informix1170			
			conn = open();
			
			//SellExecutiveService service = new SellExecutiveServiceImpl();
			//User usr = new User();
			//usr.setUserID("lee");  //lee   //achara
			
			//String sql = service.GenMainCriteriaQuerySQL(conn, 15,"01", "47", usr);			
			//System.out.println("SQL :"+sql);
			
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
	
	private static void Test(){
		Connection conn = null;
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try{
			
			//jdbc:informix-sqli://132.146.1.130:6848/lan:INFORMIXSERVER=ol_informix1170
			
			conn = open();
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
