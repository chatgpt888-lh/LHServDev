package serv.service;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

import javax.servlet.ServletException;

import serv.model.ListServInfBoqBean;
import serv.model.ServInfBoqBean;

import com.lh.servlet.DBServlet;

public class ServServiceImpl extends DBServlet implements ServService{

	public ListServInfBoqBean listInfBoqByLike(String param_n_itmjob,int max_row, int start_row, int end_row,String listType, String itmType) throws SQLException,Exception {
		System.out.println("//---- listInfBoq ----//");
		ArrayList resultList = new ArrayList();
		ListServInfBoqBean listBean = new ListServInfBoqBean(); 
		ServInfBoqBean infBoqBean = null;
		StringBuffer sql = new StringBuffer();
		
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		
		sql.delete(0,sql.length());
		sql.append("select i.i_group,i.i_type,i.i_itmjob,i.n_itmjob,g.n_itmjob as n_group,t.n_itmjob as n_type" +
					" from lan:serv_infboq i, lan:serv_infboq g, lan:serv_infboq t where ");
		if (!itmType.equals("")) {
			sql.append("i.i_itmtype = '"+itmType+"' and ");
		}
		sql.append(" i.n_itmjob like '%"+param_n_itmjob+"%'")
		.append(" and (i.f_cancel = 'N' or i.f_cancel is null)")		
		.append(" and i.i_seq != '0000'")
		.append(" and i.i_group = g.i_group")
		.append(" and g.i_type = '00'")
		.append(" and g.i_seq = '0000'")
		.append(" and i.i_group = t.i_group")
		.append(" and i.i_type = t.i_type")
		.append(" and t.i_seq = '0000'")
		.append(" order by i.i_group, i.i_type,i.i_itmjob");
		
		try {
			if (ds == null) getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
			stmt = conn.createStatement();   
			System.out.println("ServServiceImpl.listInfBoqByLike query : "+sql.toString());
			
			if(listType.equalsIgnoreCase("ListALL")){
				rs = stmt.executeQuery(sql.toString());
				while(rs.next()){
					infBoqBean = new ServInfBoqBean();
					infBoqBean.setI_group(		rs.getString("n_group"));
					infBoqBean.setI_type(		rs.getString("n_type"));
					infBoqBean.setI_itmjob(		rs.getString("i_itmjob"));
					infBoqBean.setN_itmjob(		rs.getString("n_itmjob"));
					//infBoqBean.setI_seq(		rs.getString("i_sql"));
					//infBoqBean.setZ_wage_unit(	rs.getDouble("z_wage_unit")+"");
					//infBoqBean.setZ_good_unit(	rs.getDouble("z_good_unit")+"");
					//infBoqBean.setN_count(		rs.getDouble("N_count")+"");
					//infBoqBean.setD_keyin(		rs.getString("d_keyin")+"");
					//infBoqBean.setF_contract(	rs.getString("f_contract"));
					
					

					
					resultList.add(infBoqBean);
				}
			}	
			else{	
				rs = stmt.executeQuery(sql.toString());
				
				for(int i=0;i<=max_row;i++) { 
					if (rs.next()) {
						if (i>=start_row && i<end_row) {
							infBoqBean = new ServInfBoqBean();
							infBoqBean.setI_group(		rs.getString("n_group"));
							infBoqBean.setI_type(		rs.getString("n_type"));
							infBoqBean.setI_itmjob(		rs.getString("i_itmjob"));
							infBoqBean.setN_itmjob(		rs.getString("n_itmjob"));
							resultList.add(infBoqBean);
						}
					}
				}
			}
			
			listBean.setListBean(resultList);
			
			rs.close();
			stmt.close();
			conn.close();
			rs = null;
			stmt = null;
			conn = null;
			
		} catch (Exception e) {
			System.out.println("ERROR SERVICE : " + e.getMessage());
			throw new Exception(e.getMessage());
		} finally {
			try {
				if (rs != null) rs.close();
				if (stmt != null) stmt.close();
				if (conn != null) conn.close();
			}
			catch( SQLException ignore ){}
		}
		
		return listBean;
	}
	
	public ListServInfBoqBean listInfBoqByGroup(String i_type, String i_group, int max_row, int start_row, int end_row,String listType, String itmType) throws SQLException,Exception {
		System.out.println("//---- listInfBoq ----//");
		ArrayList resultList = new ArrayList();
		ListServInfBoqBean listBean = new ListServInfBoqBean(); 
		ServInfBoqBean infBoqBean = null;
		StringBuffer sql = new StringBuffer();
		StringBuffer sqlCount = new StringBuffer();
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		
		sql.delete(0,sql.length());
		sql.append("select i.i_group,i.i_type,i.i_itmjob,i.n_itmjob,g.n_itmjob as n_group,t.n_itmjob as n_type");
		sql.append(" from lan:serv_infboq i, lan:serv_infboq g, lan:serv_infboq t where ");
		if (!itmType.equals("")) {
			sql.append(" i.i_itmtype = '"+itmType+"' and ");	
		}
		sql.append(" i.i_group = '"+i_group+"'");
		if(!i_type.equalsIgnoreCase("all")){
			sql.append(" and i.i_type = '"+i_type+"'");
		}
		sql.append(" and (i.f_cancel = 'N' or i.f_cancel is null)");
		sql.append(" and i.i_seq != '0000'");
		sql.append(" and i.i_group = g.i_group");
		sql.append(" and g.i_type = '00'");
		sql.append(" and g.i_seq = '0000'");
		sql.append(" and i.i_group = t.i_group");
		sql.append(" and i.i_type = t.i_type");
		sql.append(" and t.i_seq = '0000'");
		sql.append(" order by i.i_group, i.i_type,i.i_itmjob");
		
		try {
			if (ds == null) getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
			stmt = conn.createStatement();   
			System.out.println("ServServiceImpl.listInfBoqByGroup query : "+sql.toString());
			
			if(listType.equalsIgnoreCase("ListALL")){
				rs = stmt.executeQuery(sql.toString());
				while(rs.next()){
					infBoqBean = new ServInfBoqBean();
					infBoqBean.setI_group(		rs.getString("n_group"));
					infBoqBean.setI_type(		rs.getString("n_type"));
					infBoqBean.setI_itmjob(		rs.getString("i_itmjob"));
					infBoqBean.setN_itmjob(		rs.getString("n_itmjob"));
					
					resultList.add(infBoqBean);
				}
			}	
			else{	
				rs = stmt.executeQuery(sql.toString());
				
				for(int i=0;i<=max_row;i++) { 
					if (rs.next()) {
						if (i>=start_row && i<end_row) {
							infBoqBean = new ServInfBoqBean();
							infBoqBean.setI_group(		rs.getString("n_group"));
							infBoqBean.setI_type(		rs.getString("n_type"));
							infBoqBean.setI_itmjob(		rs.getString("i_itmjob"));
							infBoqBean.setN_itmjob(		rs.getString("n_itmjob"));
							resultList.add(infBoqBean);
						}
					}
				}
			}
			
			listBean.setListBean(resultList);
			
			rs.close();
			stmt.close();
			conn.close();
			rs = null;
			stmt = null;
			conn = null;
			
		} catch (Exception e) {
			System.out.println("ERROR SERVICE : " + e.getMessage());
			throw new Exception(e.getMessage());
		} finally {
			try {
				if (rs != null) rs.close();
				if (stmt != null) stmt.close();
				if (conn != null) conn.close();
			}
			catch( SQLException ignore ){}
		}
		
		return listBean;
	}
	
	public int getMaxRow(String i_type, String i_group, String n_itmjob, String searchType, String itmType)throws SQLException,Exception {
		int max_row = 0;
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		StringBuffer sql = new StringBuffer();
		sql.delete(0,sql.length());
		sql.append("select count(*) as max_count ");
		sql.append(" from lan:serv_infboq i, lan:serv_infboq g, lan:serv_infboq t where ");
		if (!itmType.equals("")) {
			sql.append(" i.i_itmtype = '"+itmType+"' and ");	
		}
		
		if(searchType.equals("group")){
			sql.append(" i.i_group = '"+i_group+"'");
			if(!i_type.equalsIgnoreCase("all")){
				sql.append(" and i.i_type = '"+i_type+"'");
			}
		}else{
			sql.append(" i.n_itmjob like '%"+n_itmjob+"%'");
		}
		sql.append(" and (i.f_cancel = 'N' or i.f_cancel is null)");		
		sql.append(" and i.i_seq != '0000'");
		sql.append(" and i.i_group = g.i_group");
		sql.append(" and g.i_type = '00'");
		sql.append(" and g.i_seq = '0000'");
		sql.append(" and i.i_group = t.i_group");
		sql.append(" and i.i_type = t.i_type");
		sql.append(" and t.i_seq = '0000'");
		
		try {
			if (ds == null) getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
			stmt = conn.createStatement();  
			rs = stmt.executeQuery(sql.toString());
			System.out.println("query : "+sql.toString());
			if(rs.next()){
				max_row = rs.getInt("max_count");
			}
			
			rs.close();
			stmt.close();
			conn.close();
			rs = null;
			stmt = null;
			conn = null;
		} catch (Exception e) {
			System.out.println("ERROR SERVICE : " + e.getMessage());
			throw new Exception(e.getMessage());
		} finally {
			try {
				if (rs != null) rs.close();
				if (stmt != null) stmt.close();
				if (conn != null) conn.close();
			}
			catch( SQLException ignore ){}
		}
		
		return max_row;
	}

	@Override
	public ListServInfBoqBean listInfBoqByLike(String param_n_itmjob, int max_row, int start_row, int end_row,
			String listType) throws SQLException, Exception {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public ListServInfBoqBean listInfBoqByGroup(String i_type, String i_group, int max_row, int start_row, int end_row,
			String listType) throws SQLException, Exception {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public int getMaxRow(String i_type, String i_group, String n_itmjob, String searchType)
			throws SQLException, Exception {
		// TODO Auto-generated method stub
		return 0;
	}
}
