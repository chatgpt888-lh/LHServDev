package serv.service;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashSet;
import java.util.Locale;

import javax.servlet.http.HttpSession;

import serv.common.Constants;
import serv.model.ListInfOpenJobBean;
import serv.model.ListServInfBoqBean;
import serv.model.ServInfOpenJobBean;

import com.lh.*;
import com.lh.util.DateUtil;
import com.lh.util.doString;
import com.lh.servlet.DBServlet;
import com.lh.util.*;
import com.lh.exception.InvalidParameterException;
import com.macfaq.io.*;

public class ServOpenJobServiceImpl extends DBServlet implements ServOpenJobService{
	
	
	private String moveFile(String tempPath, String attachPath,String fileName) throws Exception {
		String newName = "";
		File file = new File(tempPath,fileName);
		if (fileName.length()>0 && file.exists()) {
			File targetFile = new File(attachPath,fileName);
			if (targetFile.exists()) {
				targetFile.delete();			
			}			
			//Move the source file from its original directory
			file.renameTo(targetFile);
			newName = targetFile.getName();
		}
		return newName;						
	}
	
	private void copyFile(File inFile, File outFile) throws IOException {
		FileInputStream fin = new FileInputStream(inFile);
		FileOutputStream fout = new FileOutputStream(outFile);
		StreamCopier.copy(fin, fout);
		fin.close();
		fout.close();
	}
	
	private String getRunningNumber(String i_company, String i_project, String cur_year)throws SQLException,Exception{
		String i_docno_number = "";
		String i_docno = "";
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		StringBuffer sql = new StringBuffer();
		sql.delete(0,sql.length());
		sql.append("select i_docno" +
					" from lan:serv_infdochd" +
					" where i_docno like '"+i_company+"-"+i_project+"-"+cur_year+"%'" +
					" order by i_docno desc");
		try{
			if (ds == null) getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
			stmt = conn.createStatement();   
			rs = stmt.executeQuery(sql.toString());
			if(rs.next()){
				i_docno = rs.getString("i_docno");
			}
			if(i_docno.trim().equals("")){
				i_docno_number = "00001";
			}else{
				String max_i_docno = i_docno.trim().substring(9,14);
				i_docno_number = (Integer.parseInt(max_i_docno)+1)+"";
				
				if(i_docno_number.length()==1)
					i_docno_number = "0000"+i_docno_number;
				else if(i_docno_number.length()==2)
					i_docno_number = "000"+i_docno_number;
				else if(i_docno_number.length()==3)
					i_docno_number = "00"+i_docno_number;
				else if(i_docno_number.length()==4)
					i_docno_number = "0"+i_docno_number;
			}
			rs.close();
			stmt.close();
			conn.close();
			rs = null;
			stmt = null;
			conn = null;
			
		}catch (Exception e) {
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
		
		return i_docno_number;
	}
	
	public ServInfOpenJobBean findOpenJob(String i_docno, String attachPath, String tempPath)throws SQLException,Exception {
		System.out.println("//---- findOpenJob ----//");
		Calendar keyin = Calendar.getInstance();
		ServInfOpenJobBean openJobBean = new ServInfOpenJobBean();
		ListInfOpenJobBean listOpenjobBean = new ListInfOpenJobBean();
		ArrayList listOpenJob = new ArrayList();
		
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		StringBuffer sql = new StringBuffer();
		sql.delete(0,sql.length());
		sql.append("SELECT * FROM lan:serv_infdochd WHERE i_docno = '"+i_docno+"'");
		
		try{
			if (ds == null) getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
			stmt = conn.createStatement();   
			rs = stmt.executeQuery(sql.toString());
			
			File target = new File(tempPath);
			if (!target.exists()) {
				target.mkdirs();
			}
			
			String empId = "";
			String comId = "";
			String projN = "";
			String projId = "";
			String allotType = "";
			String keyinDate = "";
			String appDate = "";
			String closeDate = "";
			String apprId = "";
			
			if (rs != null) {
				if (rs.next() == true) {
					empId = doString.checkString(rs.getString("i_service_employ"));
					comId = doString.checkString(rs.getString("i_company"));
					projId = doString.checkString(rs.getString("i_project"));						
					keyinDate = "-";
					Timestamp tmp = rs.getTimestamp("D_KEYIN");
					if (tmp != null) {
						keyin.setTime(tmp);      
						keyinDate = getDateFromCalendar(keyin);    
						keyinDate += "&nbsp;&nbsp;"+getTimeFromCalendar(keyin)+" น.";    		            
					}			
					appDate = DateUtil.ifxToThaiDateNoTime(rs.getString("D_APPOINT"));
					closeDate = DateUtil.ifxToThaiDateNoTime(rs.getString("D_EST_CLOSE"));
					apprId = doString.checkString(rs.getString("i_approver"));	

				}
				//--- headder ----//
				openJobBean.setI_docno(i_docno);				//เลขที่ใบสั่งงานซ่อม 
				openJobBean.setI_project(comId+":"+projId);		//รหัสโครงการ 
				openJobBean.setI_service_employ(empId);			//ผู้ขออนุมัติ
				openJobBean.setI_company(comId);				//รหัสบ.
				openJobBean.setD_appoint(appDate);				//วันที่นัดซ่อม
				openJobBean.setD_est_close(closeDate);			//วันที่ประมาณการเสร็จ 
				openJobBean.setI_approver(apprId);				//ผู้อนุมัติ 
				
				rs.close();
				rs = null;
			}
			
			//---- n_project ----//
			rs = stmt.executeQuery("SELECT n_project FROM lan:acxprojt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
			if (rs != null) {
				if (rs.next() == true) {
					projN = doString.DisplayThai(rs.getString("N_PROJECT"));	//ชื่อโครงการ 
				}
				rs.close();
				rs=null;
			}
			openJobBean.setN_project(projN);				
			rs = stmt.executeQuery("SELECT d_effective, i_type FROM lan:serv_allot WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND d_effective <= TODAY ORDER BY d_effective DESC");
			if (rs != null) {
				if (rs.next() == true) {
					allotType = doString.checkString(rs.getString("I_TYPE"));
				}
				rs.close();
				rs=null;
			}			
			//--- jobItemList ---//
			int seqNo = 0;
			String i_itmjob = "";
			String n_itmjob = "";
			String i_itmtype = "";
			String n_count = "";
			String i_vendor = "";
			String com_acc = "";
			String cus_acc = "";
			double wage_price = 0;
			double wage_unit = 0;
			double good_price = 0;
			double good_unit = 0;
			double wageAmnt = 0;
			double goodAmnt = 0;
			double estAmnt = 0;
			double payAmnt = 0;
			double totWageAmnt = 0;
			double totGoodAmnt = 0;
			double totEstAmnt = 0;
			double totPayAmnt = 0;
			String comment = "";
			String fileName = "";
			String itmFiNme = "";
			String area    = "";
			String f_itmstatus = "";
			
			sql.delete(0,sql.length());
			sql.append("SELECT a.*, b.n_itmjob, b.n_count, b.i_com_acc1, b.i_cus_acc1, b.i_com_acc2, b.i_cus_acc2, b.i_com_acc3, b.i_cus_acc3, d.bus_name")
				.append(" FROM lan:serv_infdocdt a, lan:serv_infboq b, lan:stpvendr d")
				.append(" WHERE a.i_docno = '")
				.append(i_docno)
				.append("' AND a.f_itmstatus != 'CAN'")
				.append(" AND a.i_itmjob = b.i_itmjob")
				.append(" AND a.i_vendor = d.vend_code")
				.append(" ORDER BY a.i_seq");
			rs = stmt.executeQuery(sql.toString());
			if (rs != null) {
				while (rs.next() == true) {
					
					i_itmjob = rs.getString("i_itmjob");
					n_itmjob = rs.getString("n_itmjob");
					i_itmtype = rs.getString("i_itmtype");
					n_count = rs.getString("n_count");
					i_vendor = rs.getString("i_vendor");
					
					seqNo = rs.getInt("I_SEQ");
					wage_price = rs.getDouble("z_wage_price");
					wage_unit = rs.getDouble("q_wage_unit");
					wageAmnt = wage_price * wage_unit;
					totWageAmnt += wageAmnt;
					
					good_price = rs.getDouble("z_good_price");
					good_unit = rs.getDouble("q_good_unit");
					goodAmnt = good_price * good_unit;
					totGoodAmnt += goodAmnt;
					
					estAmnt = rs.getDouble("z_est_amt");
					totEstAmnt += estAmnt;
					payAmnt = rs.getDouble("z_amount_pay");
					totPayAmnt += payAmnt;
					
					comment = rs.getString("c_itmjob");
					area = rs.getString("i_itmjob_area");
					f_itmstatus = rs.getString("f_itmstatus");
					fileName = doString.MS874ToUnicode(doString.checkString(rs.getString("n_name")));
					itmFiNme = doString.checkString(rs.getString("i_file_name"));
					if (!itmFiNme.equals("")) {
						File inFile = new File(attachPath+"/"+itmFiNme);
						File outFile = new File(tempPath+"/"+itmFiNme);
						copyFile(inFile, outFile);
					}
					
					listOpenjobBean = new ListInfOpenJobBean();
					listOpenjobBean.setI_seq(seqNo);			//i_seq
					listOpenjobBean.setI_itmjob(i_itmjob);		//รายการซ่อม
					listOpenjobBean.setN_itmjob(n_itmjob);		//n รายการซ่อม
					listOpenjobBean.setI_itmtype(i_itmtype);	//ประเภทงานซ่อม
					listOpenjobBean.setN_count(n_count);		//หน่วยนับ
					listOpenjobBean.setCom_acc(com_acc);
					listOpenjobBean.setCus_acc(cus_acc);
					listOpenjobBean.setI_vender(i_vendor);		//ผู้รับเหมาซ่อม
					listOpenjobBean.setCom_acc1(rs.getString("I_COM_ACC1"));
					listOpenjobBean.setCom_acc2(rs.getString("I_COM_ACC2"));
					listOpenjobBean.setCom_acc3(rs.getString("I_COM_ACC3"));
					listOpenjobBean.setCus_acc1(rs.getString("I_CUS_ACC1"));
					listOpenjobBean.setCus_acc2(rs.getString("I_CUS_ACC2"));
					listOpenjobBean.setCus_acc3(rs.getString("I_CUS_ACC3"));						
					
					listOpenjobBean.setCustom_wage(wage_price);	//ค่าแรงต่อหน่วย
					listOpenjobBean.setWage(wage_unit);			//จำนวน
					listOpenjobBean.setWage_sum(wageAmnt);		//รวม
					
					listOpenjobBean.setCustom_goods(good_price);//ค่าของต่อหน่วย
					listOpenjobBean.setGoods(good_unit);		//จำนวน
					listOpenjobBean.setGoods_sum(goodAmnt);		//รวม
					
					listOpenjobBean.setEstimate(estAmnt);		//ประมาณการคชจ.ซ่อม
					listOpenjobBean.setSum_total(payAmnt);		//รวม
					
					listOpenjobBean.setComment(comment);		//คอมเม้น
					listOpenjobBean.setArea(area);				//พื้นที่
					
					listOpenjobBean.setFileName(fileName);		//Attach File
					listOpenjobBean.setItmFiName(itmFiNme);
					
					listOpenjobBean.setF_itmstatus(f_itmstatus);//
					
					listOpenJob.add(listOpenjobBean);
				}
				
				rs.close();
				rs = null;
			}
			
			openJobBean.setListInfBoq(listOpenJob);
			
			stmt.close();
			conn.close();
			
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
		
		
		return openJobBean;
	}
	
	public ArrayList listOpenJob(String itmjob)throws SQLException,Exception {
		System.out.println("//---- listOpenJob ----//");
		ArrayList resultList = new ArrayList();
		ListInfOpenJobBean listInfOpenJobBean = new ListInfOpenJobBean();
		
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		StringBuffer sql = new StringBuffer();
		
		sql.delete(0,sql.length());
		sql.append("SELECT i.i_group, i.i_type, i.i_itmjob, i.n_itmjob, i.z_wage_unit, i.z_good_unit, i.i_com_acc1, i.i_cus_acc1, i.i_com_acc2, i.i_cus_acc2, i.i_com_acc3, i.i_cus_acc3, g.n_itmjob AS N_GROUP, t.n_itmjob AS N_TYPE, i.n_count")
		.append(" FROM lan:serv_infboq i, lan:serv_infboq g, lan:serv_infboq t")
		.append(" WHERE i.i_itmjob IN ("+itmjob+")")
		.append(" AND i.i_seq != '0000'")
		.append(" AND i.i_group = g.i_group")
		.append(" AND g.i_type = '00'")
		.append(" AND g.i_seq = '0000'")
		.append(" AND i.i_group = t.i_group")
		.append(" AND i.i_type = t.i_type")
		.append(" AND t.i_seq = '0000'")
		.append(" ORDER BY i.i_group, i.i_type, i.i_itmjob");
		
		try{
			if (ds == null) getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
			stmt = conn.createStatement();   
			rs = stmt.executeQuery(sql.toString());
			int i = 1;
			double wage_price = 0;
			double goods_price = 0;
			while(rs.next() == true){
				wage_price = rs.getDouble("Z_WAGE_UNIT");
				goods_price = rs.getDouble("Z_GOOD_UNIT");
				listInfOpenJobBean = new ListInfOpenJobBean();
				listInfOpenJobBean.setI_itmjob(rs.getString("I_ITMJOB"));
				listInfOpenJobBean.setN_itmjob(rs.getString("N_ITMJOB"));
				listInfOpenJobBean.setN_count(rs.getString("N_COUNT"));
				listInfOpenJobBean.setCom_acc1(rs.getString("I_COM_ACC1"));
				listInfOpenJobBean.setCom_acc2(rs.getString("I_COM_ACC2"));
				listInfOpenJobBean.setCom_acc3(rs.getString("I_COM_ACC3"));
				listInfOpenJobBean.setCus_acc1(rs.getString("I_CUS_ACC1"));
				listInfOpenJobBean.setCus_acc2(rs.getString("I_CUS_ACC2"));
				listInfOpenJobBean.setCus_acc3(rs.getString("I_CUS_ACC3"));
				listInfOpenJobBean.setCustom_wage(wage_price);
				listInfOpenJobBean.setCustom_goods(goods_price);
				if (wage_price > 0) listInfOpenJobBean.setWage_boq(true);
				if (goods_price > 0) listInfOpenJobBean.setGoods_boq(true);
				resultList.add(listInfOpenJobBean);
			}// end while
			rs.close();
			rs=null;
			stmt.close();
			conn.close();
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
		return resultList;
	}
	
	public void createOpenJob(ServInfOpenJobBean openJobBean, String save_type, String attachPath, String tempPath)throws SQLException,InvalidParameterException,Exception{
		String mName = new String(this.getClass().getName() + ".performTask: ");
		System.out.println("//---- insert openjob ----//");
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		try {
			//--------- prepare valiable -------//
			Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
			String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543).substring(2, 4);
			String i_company = openJobBean.getI_company();
			i_company = openJobBean.getI_project().substring(0,2);
			String i_proj  = openJobBean.getI_project().substring(3,6);
			String running_number = this.getRunningNumber(i_company, i_proj, cur_year);
			
			String i_docno = i_company+"-"+openJobBean.getI_project().substring(3,6)+"-"+cur_year+running_number;
			//attachPath += File.separator+i_docno;
			attachPath += i_docno;
			File target = new File(attachPath);
			if (!target.exists()) {
				target.mkdirs();
			}			
			String who = "";
			String team = "";
			String empId = openJobBean.getI_service_employ();
			String apprId = openJobBean.getI_approver();
			String d_appoint = getCalendarDisplay(openJobBean.getD_appoint());
			String d_est_close = getCalendarDisplay(openJobBean.getD_est_close());
			String i_chart = "";
			String f_status = "";
			String f_itmstatus = "";
			String realFiNme = "";
			String itmType = "";
			String typeDesc = "";

			
			if (ds == null)
				getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
			
			rs = stmt.executeQuery("SELECT user_who, user_group FROM lan:useracl WHERE user_acl = 'S' AND i_employ = '"+empId+"'");
			if (rs != null) {
				if (rs.next() == true) {
					who = doString.checkString(rs.getString("USER_WHO"));
					team = doString.checkString(rs.getString("USER_GROUP"));
				}
				rs.close();
				rs=null;
			}
			if(save_type.equals("saveOpenJob")){
				f_status = "NEW";
				f_itmstatus = "100";
				i_chart = openJobBean.getN_position_employ();
			}else if(save_type.equals("sendToApprove")){
				f_status = "OPN";
				f_itmstatus = "200";
				i_chart = openJobBean.getI_chart_grp();
				if (who.equals("M") || who.equals("Z")) {
					i_chart = who;
					apprId = empId;
					f_itmstatus = "300";
				}
			}			
			
			//------------INSERT SERV_INFDOCHD TABLE ---------//
			sql.delete(0,sql.length());
			if (f_itmstatus.equals("300")) {
				sql.append("insert into lan:serv_infdochd(i_docno, i_doc_type, i_company, i_project, d_keyin, n_customer,n_cus_tel, c_desc, d_job, f_status, d_appoint, d_est_close, i_service_employ, i_chart, i_approver,i_type_cutlck,d_print_inform,i_employ_pinform,d_print_job,i_employ_pjob, f_reject, i_employ_reject, d_reject, c_reject, d_cancel, d_close_law, d_start_min, d_complete_max, i_venno, i_model, i_team) " +
						"values(?, ?, ?, ?, current, null, null, null, today, ?, '"+d_appoint+"', '"+d_est_close+"', ?, ?, ?, null, null, null, null, null, ?, null, null, null, null, null, TODAY, null, null, null, ?)");
			} else {
				sql.append("insert into lan:serv_infdochd(i_docno, i_doc_type, i_company, i_project, d_keyin, n_customer,n_cus_tel, c_desc, d_job, f_status, d_appoint, d_est_close, i_service_employ, i_chart, i_approver,i_type_cutlck,d_print_inform,i_employ_pinform,d_print_job,i_employ_pjob, f_reject, i_employ_reject, d_reject, c_reject, d_cancel, d_close_law, d_start_min, d_complete_max, i_venno, i_model, i_team) " +
						"values(?, ?, ?, ?, current, null, null, null, today, ?, '"+d_appoint+"', '"+d_est_close+"', ?, ?, ?, null, null, null, null, null, ?, null, null, null, null, null, null, null, null, null, ?)");
			}
			pstmt = conn.prepareStatement(sql.toString());
			pstmt.setString(1, i_docno);								//i_docno
			pstmt.setString(2, "J");									//i_doc_type
			pstmt.setString(3, i_company);								//i_company
			pstmt.setString(4, i_proj);									//i_project
			pstmt.setString(5, f_status);								//f_status save=new, send to approve = Open Job
			pstmt.setString(6, openJobBean.getI_service_employ());		//i_service_employ
			pstmt.setString(7, i_chart);								//i_chart
			pstmt.setString(8, apprId);									//i_approver
			pstmt.setString(9, "N");									//f_reject
			pstmt.setString(10, team);									//i_team
			pstmt.executeUpdate();
			pstmt.close();
			
			//------------INSERT SERV_INFDOCDT TABLE ---------//
			ArrayList listDetail = openJobBean.getListInfBoq();
			for(int i=0; i<listDetail.size(); i++){
				ListInfOpenJobBean jobItem= (ListInfOpenJobBean)listDetail.get(i);
				realFiNme = doString.checkString(jobItem.getItmFiName());
				if (!realFiNme.equals("")) {
					moveFile(tempPath, attachPath, realFiNme);
				}
				sql.delete(0,sql.length());
				sql.append("insert into lan:serv_infdocdt(i_docno, i_seq, i_itmjob, i_vendor, q_wage_unit, z_wage_price, q_good_unit, z_good_price, z_est_amt, z_amount_pay, c_itmjob,i_itmjob_area, f_itmstatus, i_itmtype, n_name, i_file_name)" +
							"values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
				pstmt = conn.prepareStatement(sql.toString());	
				pstmt.setString(1, i_docno);					//i_docno
				pstmt.setString(2, (i+1)+"");					//i_seq
				pstmt.setString(3, jobItem.getI_itmjob());		//i_itmjob
				pstmt.setString(4, jobItem.getI_vender());		//i_vendor
				pstmt.setDouble(5, jobItem.getWage());			//q_wage_unit
				pstmt.setDouble(6, jobItem.getCustom_wage());	//z_wage_price
				pstmt.setDouble(7, jobItem.getGoods());			//q_good_unit
				pstmt.setDouble(8, jobItem.getCustom_goods());	//z_good_price
				pstmt.setDouble(9, jobItem.getEstimate());		//z_est_amt
				pstmt.setDouble(10,jobItem.getSum_total() );	//z_amount_pay
				pstmt.setString(11, jobItem.getComment());		//c_itmjob
				pstmt.setString(12, jobItem.getArea());			//i_itmjob_area
				pstmt.setString(13, f_itmstatus);				//f_itmstatus 100=save, 200=sendToApprove, 300=Approve
				pstmt.setString(14, jobItem.getI_itmtype());	//i_itmtype
				pstmt.setString(15, doString.UnicodeToMS874(doString.checkString(jobItem.getFileName())));
				pstmt.setString(16, realFiNme);
				pstmt.executeUpdate();
				pstmt.close();
				itmType = jobItem.getI_itmtype();
			}
			if (itmType.equals("01")) { //Infra
				itmType = "I";
				typeDesc = "สาธารณูฯ";
			} else { //Pub
				itmType = "H";
				typeDesc = "สาธารณะ";
			}
			f_status = "W";
			if (f_itmstatus.equals("300")) {
				f_status = "A";
			}
			String i_chart_grp = "";
			rs = stmt.executeQuery("SELECT user_who FROM lan:useracl WHERE user_acl = 'S' AND i_employ = '"+apprId+"'");
			if (rs != null) {
				if (rs.next() == true) {
					i_chart_grp = doString.checkString(rs.getString("USER_WHO"));
				}
				rs.close();
				rs=null;
			}
			//------------INSERT SERV_INFDOCAP TABLE ---------//
			if(save_type.equals("saveOpenJob")){
				sql.delete(0,sql.length());
				sql.append("insert into lan:serv_infdocap(i_docno, i_seq, i_chart_grp, i_approver, d_approve, f_approve)" +
						"values(?,1,?,?,today,?)");
				pstmt = conn.prepareStatement(sql.toString());			//i_docno
				pstmt.setString(1, i_docno);							//i_chart_grp
				pstmt.setString(2, "S");								//i_approver
				pstmt.setString(3, openJobBean.getI_service_employ());	//d_approve
				pstmt.setString(4, "W");								//f_appprove A=Approve, W=Wait, R=Reject
				pstmt.executeUpdate();
				pstmt.close();
			}else if(save_type.equals("sendToApprove")){	
				//---- Requester ----//
				sql.delete(0,sql.length());
				sql.append("insert into lan:serv_infdocap(i_docno, i_seq, i_chart_grp, i_approver, d_approve, f_approve)" +
							"values(?,1,?,?,today,?)");
				pstmt = conn.prepareStatement(sql.toString());	
				pstmt.setString(1, i_docno);							//i_docno
				pstmt.setString(2, "S");								//i_chart_grp
				pstmt.setString(3, empId);	//i_approve 
				pstmt.setString(4, "A");								//f_appprove A=Approve, W=Wait, R=Reject
				pstmt.executeUpdate();
				pstmt.close();
				
				//---- Approver ----//
				sql.delete(0,sql.length());
				if (f_itmstatus.equals("300")) {
					sql.append("insert into lan:serv_infdocap(i_docno, i_seq, i_chart_grp, i_approver, d_approve, f_approve)" +
					"values(?,2,?,?,TODAY,?)");
				} else {
					sql.append("insert into lan:serv_infdocap(i_docno, i_seq, i_chart_grp, i_approver, d_approve, f_approve)" +
					"values(?,2,?,?,null,?)");
				}
				pstmt = conn.prepareStatement(sql.toString());	
				pstmt.setString(1, i_docno);						//i_docno
				pstmt.setString(2, i_chart_grp);					//i_chart_grp M,Z
				pstmt.setString(3, apprId);	//i_approve 
				pstmt.setString(4, f_status);							//f_appprove A=Approve, W=Wait, R=Reject
				pstmt.executeUpdate();
				pstmt.close();
				
				//Mail To Approver
				String Recipients = "";
				String subject = "เอกสารใบสั่งซ่อม"+typeDesc+" เลขที่ : "+i_docno+" รออนุมัติ";
				String link = "http://132.146.1.92/LHServ/SERV_INFOpenJob_Appr.jsp?docNo="+i_docno+"&mail=Y&mode=V&chartGrp="+i_chart_grp;
				link = "<a href='"+link+"' target=\"_blank\">ที่นี่</a>";
				String mailtext = "เอกสารใบสั่งซ่อม"+typeDesc+" เลขที่ : "+i_docno+" รออนุมัติ ท่านสามารถเข้าไปอนุมัติได้ "+link;
				String header = "<HTML><HEAD><META http-equiv=\"Content-Type\" content=\"text/html; charset=TIS-620\"><META http-equiv=\"Content-Language\" content=\"th\"><TITLE></TITLE></HEAD><BODY>";
				String footer = "</BODY></HTML>";
				LHMail MailLH = new LHMail();				
				rs = stmt.executeQuery("SELECT user_email FROM docflow:useracl WHERE i_employ = '"+apprId+"'");
				if (rs != null) {
					if (rs.next() == true) {
						Recipients = doString.checkString(rs.getString(1));
					}
					rs.close();
					rs=null;
				}
				if (!apprId.equals(empId)) {
					if (!Recipients.equals("")) {
						MailLH.sendBBMail("132.146.1.12", "lh.co.th", "application", Recipients, "", doString.MS874ToUnicode(subject), doString.MS874ToUnicode(mailtext));
					}
				}
				
				//Mail CC
				if (i_chart_grp.equals("Z")) {
					subject = "เอกสารใบสั่งซ่อม"+typeDesc+" เลขที่ : "+i_docno+" รอ Zone Manager อนุมัติ (แจ้งเพื่อทราบ)";
					link = "http://132.146.1.92/LHServ/SERV_INFOpenJob_Disp.jsp?docNo="+i_docno+"&mode=V&chartGrp="+i_chart_grp;
					link = "<a href='"+link+"' target=\"_blank\">ที่นี่</a>";
					mailtext = "เอกสารใบสั่งซ่อม"+typeDesc+" เลขที่ : "+i_docno+" รอ Zone Manager อนุมัติ ท่านสามารถเข้าไปตรวจสอบได้ "+link;
					rs = stmt.executeQuery("SELECT u.user_email FROM lan:serv_pstaff s, lan:useracl u WHERE s.com_id = '"+i_company+"' AND s.proj_id = '"+i_proj+"' AND s.user_id = u.user_id AND u.user_acl = 'S' AND u.user_who = 'M' AND u.user_group = '"+team+"'");
					if (rs != null) {
						while (rs.next() == true) {
							Recipients = doString.checkString(rs.getString(1));
							if (!Recipients.equals("")) {
								MailLH.sendBBMail("132.146.1.12", "lh.co.th", "application", Recipients, "", doString.MS874ToUnicode(subject), doString.MS874ToUnicode(mailtext));
							}
						}// end while
						rs.close();
						rs=null;
					}
				}
			}// End If SendToApprove
			
			//------------INSERT SERV_INFFLOW TABLE ---------//
			ArrayList listIvendor = this.getIvendor(listDetail);
				
			for(int i=0;i<listIvendor.size();i++){
				sql.delete(0,sql.length());
				sql.append("insert into lan:serv_infflow(i_docno, i_vendor, f_itmstatus, d_approve, i_approve, f_reject, c_reject)" +
						"values(?,?,?,current,?,null,null)");
				pstmt = conn.prepareStatement(sql.toString());
				pstmt.setString(1, i_docno);						//i_docno
				pstmt.setString(2, (String)listIvendor.get(i));		//i_vendor
				pstmt.setString(3, "100");							//f_itmstatus 100
				pstmt.setString(4, openJobBean.getI_user());	//i_approve
				pstmt.executeUpdate();
				pstmt.close();
			}
			if (f_itmstatus.equals("300")) {
				for(int i=0;i<listIvendor.size();i++){
					sql.delete(0,sql.length());
					sql.append("insert into lan:serv_infflow(i_docno, i_vendor, f_itmstatus, d_approve, i_approve, f_reject, c_reject)" +
							"values(?,?,?,current,?,null,null)");
					pstmt = conn.prepareStatement(sql.toString());
					pstmt.setString(1, i_docno);						//i_docno
					pstmt.setString(2, (String)listIvendor.get(i));		//i_vendor
					pstmt.setString(3, "200");							//f_itmstatus 200
					pstmt.setString(4, openJobBean.getI_user());	//i_approve
					pstmt.executeUpdate();
					pstmt.close();
				}
			}
			
			openJobBean.setI_docno(i_docno);
			
			conn.commit();
			stmt.close();
			conn.close();
			stmt = null;
			conn = null;
		
		} catch (Exception e) {
			try {
				if (conn != null)
					conn.rollback();
			} catch (Exception ignore) {}			
			throw new Exception(e);
		} finally {
			//out.close();
			try {
				if (rs!=null) rs.close(); 
				if (stmt != null) stmt.close();
				if (pstmt != null) pstmt.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");
	}

	public void updateOpenJob(ServInfOpenJobBean openJobBean,String save_type, String attachPath, String tempPath)throws SQLException,InvalidParameterException,Exception{
		System.out.println("//---- update openjob ----//");
		String mName = new String(this.getClass().getName() + ".performTask: ");
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		int rowEffected = 0;

		//--------- prepare valiable -------//
		String i_docno = doString.checkString(openJobBean.getI_docno());		//เลขที่ใบสั่งงานซ่อม
		String i_company = i_docno.substring(0, 2);
		String i_proj = i_docno.substring(3, 6);
		//attachPath += File.separator+i_docno;
		attachPath += i_docno;
		//------- check folder -----------//
		File target = new File(attachPath);
		if (!target.exists()) {
			target.mkdirs();
		}
		
		String f_status = "";
		String f_itmstatus = "";
		String d_appoint = getCalendarDisplay(openJobBean.getD_appoint());
		String d_est_close = getCalendarDisplay(openJobBean.getD_est_close());
		String i_chart = "";
		String who = "";
		String team = "";
		String empId = openJobBean.getI_service_employ();
		String i_approver = openJobBean.getI_approver();
		String itmType = "";
		String typeDesc = "";
		try {
			if (ds == null)
				getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
			
			rs = stmt.executeQuery("SELECT user_who, user_group FROM lan:useracl WHERE user_acl = 'S' AND i_employ = '"+empId+"'");
			if (rs != null) {
				if (rs.next() == true) {
					who = doString.checkString(rs.getString("USER_WHO"));
					team = doString.checkString(rs.getString("USER_GROUP"));
				}
				rs.close();
				rs=null;
			}
			if(save_type.equals("saveOpenJob")){
				f_status = "NEW";
				f_itmstatus = "100";
				i_chart = openJobBean.getN_position_employ();
			}else if(save_type.equals("sendToApprove")){
				f_status = "OPN";
				f_itmstatus = "200";
				if(openJobBean.getGrandTotal()>openJobBean.getP_amount())
					i_chart = "Z";
				else
					i_chart = "M";
				if (who.equals("M")||who.equals("Z")) {
					i_chart = who;
					i_approver = empId;
					f_itmstatus = "300";
				}
			}
			
			i_chart = "";
			rs = stmt.executeQuery("SELECT user_who FROM lan:useracl WHERE user_acl = 'S' AND i_employ = '"+i_approver+"'");
			if (rs != null) {
				if (rs.next() == true) {
					i_chart = doString.checkString(rs.getString("USER_WHO"));
				}
				rs.close();
				rs=null;
			}			
			//------- UPDATE SERV_INFDOCHD TABLE ------//
			rowEffected = stmt.executeUpdate("UPDATE lan:serv_infdochd " +
					" SET d_start_min = TODAY ," +
					"  d_keyin = CURRENT ," +
					"  d_job = TODAY ," +
					"  f_status ='"+f_status+"' ,"+
					"  d_appoint ='"+d_appoint+"' ,"+
					"  d_est_close ='"+d_est_close+"' ,"+
					"  i_team ='"+team+"' ,"+
					"  i_chart ='"+i_chart+"' ,"+
					"  i_approver ='"+i_approver+"' "+
					" WHERE i_docno = '"+i_docno+"'");
			if (rowEffected != 1) {
	        	throw new Exception("SERV_INFDOCHD : Wrong Update Count");
	        }
			
			//------- UPDATE SERV_INFDOCDT TABLE -----//
			
			//----- clear attach path -----//
			File attFolder = new File(attachPath);
			if (attFolder.exists() && attFolder.isDirectory()) {
				File[] listTmp = attFolder.listFiles();
				if (listTmp!=null) {
					for (int f=0;f<listTmp.length;f++) {
						listTmp[f].delete();	
					} // end for
				}
			}
			stmt.executeUpdate("delete from lan:serv_infdocdt where i_docno ='"+i_docno+"'");
			String realFiNme = "";
			ArrayList listDetail = openJobBean.getListInfBoq();
			for(int i=0; i<listDetail.size(); i++){
				ListInfOpenJobBean jobItem= (ListInfOpenJobBean)listDetail.get(i);
				realFiNme = doString.checkString(jobItem.getItmFiName());
				if (!realFiNme.equals("")) {
					moveFile(tempPath, attachPath, realFiNme);
				}				
				sql.delete(0,sql.length());
				sql.append("insert into lan:serv_infdocdt(i_docno, i_seq, i_itmjob, i_vendor, q_wage_unit, z_wage_price, q_good_unit, z_good_price, z_est_amt, z_amount_pay, c_itmjob,i_itmjob_area, f_itmstatus, i_itmtype, n_name, i_file_name)" +
							"values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
				pstmt = conn.prepareStatement(sql.toString());	
				pstmt.setString(1, i_docno);					//i_docno
				pstmt.setString(2, (i+1)+"");					//i_seq
				pstmt.setString(3, jobItem.getI_itmjob());		//i_itmjob
				pstmt.setString(4, jobItem.getI_vender());		//i_vendor
				pstmt.setDouble(5, jobItem.getWage());			//q_wage_unit
				pstmt.setDouble(6, jobItem.getCustom_wage());	//z_wage_price
				pstmt.setDouble(7, jobItem.getGoods());			//q_good_unit
				pstmt.setDouble(8, jobItem.getCustom_goods());	//z_good_price
				pstmt.setDouble(9, jobItem.getEstimate());		//z_est_amt
				pstmt.setDouble(10,jobItem.getSum_total() );	//z_amount_pay
				pstmt.setString(11, jobItem.getComment());		//c_itmjob
				pstmt.setString(12, jobItem.getArea());			//i_itmjob_area
				pstmt.setString(13, f_itmstatus);				//f_itmstatus 100=save, 200=sendToApprove, 300=Approve
				pstmt.setString(14, jobItem.getI_itmtype());	//i_itmtype			
				pstmt.setString(15, doString.UnicodeToMS874(doString.checkString(jobItem.getFileName())));
				pstmt.setString(16, realFiNme);				
				pstmt.executeUpdate();
				pstmt.close();
				itmType = jobItem.getI_itmtype();
			}
			if (itmType.equals("01")) { //Infra
				itmType = "I";
				typeDesc = "สาธารณูฯ";
			} else { //Pub
				itmType = "H";
				typeDesc = "สาธารณะ";
			}			
			
			//------------ UPDATE SERV_INFDOCAP TABLE ---------//
			f_status = "W";
			String i_chart_grp = "M";
			if(openJobBean.getGrandTotal()>openJobBean.getP_amount())
				i_chart_grp = "Z";
			
			if (f_itmstatus.equals("300")) {
				f_status = "A";
				i_chart_grp = i_chart;
			}
			if(save_type.equals("saveOpenJob")){
				//---- Requester ---//
				rowEffected = stmt.executeUpdate("UPDATE lan:serv_infdocap SET d_approve = TODAY, f_approve = 'W'  WHERE i_docno = '"+i_docno+"' AND i_approver = '"+openJobBean.getI_service_employ()+"'");
		        if (rowEffected != 1) {
		        	throw new Exception("SERV_INFDOCAP : Wrong Update Count");
		        }
				
			}else if(save_type.equals("sendToApprove")){ //SendToApprove, Submit	
				stmt.executeUpdate("delete from lan:serv_infdocap where i_docno ='"+i_docno+"'");
				
				//---- Requester ----//
				sql.delete(0,sql.length());
				sql.append("insert into lan:serv_infdocap(i_docno, i_seq, i_chart_grp, i_approver, d_approve, f_approve)" +
							"values(?,1,?,?,today,?)");
				pstmt = conn.prepareStatement(sql.toString());	
				pstmt.setString(1, i_docno);							//i_docno
				pstmt.setString(2, "S");								//i_chart_grp
				pstmt.setString(3, empId);	//i_approve 
				pstmt.setString(4, "A");								//f_appprove A=Approve, W=Wait, R=Reject
				pstmt.executeUpdate();
				pstmt.close();
				
				//---- Approver ----//
			    sql.delete(0,sql.length());
				if (f_itmstatus.equals("300")) {
					sql.append("insert into lan:serv_infdocap(i_docno, i_seq, i_chart_grp, i_approver, d_approve, f_approve)" +
					"values(?,2,?,?,today,?)");
				} else {
					sql.append("insert into lan:serv_infdocap(i_docno, i_seq, i_chart_grp, i_approver, d_approve, f_approve)" +
					"values(?,2,?,?,null,?)");
				}
				pstmt = conn.prepareStatement(sql.toString());	
				pstmt.setString(1, i_docno);						//i_docno
				pstmt.setString(2, i_chart_grp);					//i_chart_grp M,Z
				pstmt.setString(3, i_approver);	//i_approve 
				pstmt.setString(4, f_status);							//f_appprove A=Approve, W=Wait, R=Reject
				pstmt.executeUpdate();
				pstmt.close();
				
				//Mail To Approver
/*				
				String Recipients = "";
				String subject = "เอกสารใบสั่งซ่อม"+typeDesc+" เลขที่ : "+i_docno+" รออนุมัติ";
				String link = "http://132.146.1.92/LHServ/SERV_INFOpenJob_Appr.jsp?docNo="+i_docno+"&mail=Y&mode=V&chartGrp="+i_chart_grp;
				link = "<a href='"+link+"' target=\"_blank\">ที่นี่</a>";
				String mailtext = "เอกสารใบสั่งซ่อม"+typeDesc+" เลขที่ : "+i_docno+" รออนุมัติ ท่านสามารถเข้าไปอนุมัติได้ "+link;
				String header = "<HTML><HEAD><META http-equiv=\"Content-Type\" content=\"text/html; charset=TIS-620\"><META http-equiv=\"Content-Language\" content=\"th\"><TITLE></TITLE></HEAD><BODY>";
				String footer = "</BODY></HTML>";
				
				LHMail MailLH = new LHMail();				
				rs = stmt.executeQuery("SELECT user_email FROM docflow:useracl WHERE i_employ = '"+i_approver+"'");
				if (rs != null) {
					if (rs.next() == true) {
						Recipients = doString.checkString(rs.getString(1));
					}
					rs.close();
					rs=null;
				}
				if (!i_approver.equals(empId)) {
					if (!Recipients.equals("")) {
						MailLH.sendBBMail("132.146.1.12", "lh.co.th", "application", Recipients, "", doString.MS874ToUnicode(subject), doString.MS874ToUnicode(mailtext));
					}
				}
				
				//Mail CC Manager
				if (i_chart_grp.equals("Z")) {
					subject = "เอกสารใบสั่งซ่อม"+typeDesc+" เลขที่ : "+i_docno+" รอ Zone Manager อนุมัติ (แจ้งเพื่อทราบ)";
					link = "http://132.146.1.92/LHServ/SERV_INFOpenJob_Disp.jsp?docNo="+i_docno+"&mode=V&chartGrp="+i_chart_grp;
					link = "<a href='"+link+"' target=\"_blank\">ที่นี่</a>";
					mailtext = "เอกสารใบสั่งซ่อม"+typeDesc+" เลขที่ : "+i_docno+" รอ Zone Manager อนุมัติ ท่านสามารถเข้าไปตรวจสอบได้ "+link;
					rs = stmt.executeQuery("SELECT u.user_email FROM lan:serv_pstaff s, lan:useracl u WHERE s.com_id = '"+i_company+"' AND s.proj_id = '"+i_proj+"' AND s.user_id = u.user_id AND u.user_acl = 'S' AND u.user_who = 'M' AND u.user_group = '"+team+"'");
					if (rs != null) {
						while (rs.next() == true) {
							Recipients = doString.checkString(rs.getString(1));
							if (!Recipients.equals("")) {
								MailLH.sendBBMail("132.146.1.12", "lh.co.th", "application", Recipients, "", doString.MS874ToUnicode(subject), doString.MS874ToUnicode(mailtext));
							}
						}// end while
						rs.close();
						rs=null;
					}
				}
*/				
			}
			
			//------------ UPDATE SERV_INFFLOW TABLE ---------//
			stmt.executeUpdate("delete from lan:serv_infflow where i_docno ='"+i_docno+"'");
			ArrayList listIvendor = this.getIvendor(listDetail);
			
			for(int i=0;i<listIvendor.size();i++){
				sql.delete(0,sql.length());
				sql.append("insert into lan:serv_infflow(i_docno, i_vendor, f_itmstatus, d_approve, i_approve, f_reject, c_reject)" +
						"values(?,?,?,current,?,null,null)");
				pstmt = conn.prepareStatement(sql.toString());
				pstmt.setString(1, i_docno);						//i_docno
				pstmt.setString(2, (String)listIvendor.get(i));		//i_vendor
				pstmt.setString(3, "100");							//f_itmstatus 100=Open Job
				pstmt.setString(4, openJobBean.getI_user());	//i_approve
				pstmt.executeUpdate();
				pstmt.close();
			}
			if (f_itmstatus.equals("300")) {
				for(int i=0;i<listIvendor.size();i++){
					sql.delete(0,sql.length());
					sql.append("insert into lan:serv_infflow(i_docno, i_vendor, f_itmstatus, d_approve, i_approve, f_reject, c_reject)" +
							"values(?,?,?,current,?,null,null)");
					pstmt = conn.prepareStatement(sql.toString());
					pstmt.setString(1, i_docno);						//i_docno
					pstmt.setString(2, (String)listIvendor.get(i));		//i_vendor
					pstmt.setString(3, "200");							//f_itmstatus 200=Approve Job
					pstmt.setString(4, openJobBean.getI_user());	//i_approve
					pstmt.executeUpdate();
					pstmt.close();
				}
			}
			conn.commit();
			stmt.close();
			conn.close();
			stmt = null;
			conn = null;
		} catch (Exception e) {
			try {
				if (conn != null)
					conn.rollback();
			} catch (Exception ignore) {}
			throw new Exception(e);
		} finally {
			//out.close();
			try {
				if (rs!=null) rs.close(); 
				if (stmt != null) stmt.close();
				if (pstmt != null) pstmt.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");

	}
	
	//--------- prepare data for database -----//
	private ArrayList getIvendor(ArrayList listJobItem)throws Exception{
		ArrayList listAllVendor = new ArrayList();
		for(int i=0;i<listJobItem.size(); i++){
			ListInfOpenJobBean jobItem= (ListInfOpenJobBean)listJobItem.get(i);
			String i_vendor = jobItem.getI_vender();
			listAllVendor.add(i_vendor);
		}
		HashSet hashSet = new HashSet(listAllVendor);
		ArrayList i_vendor = new ArrayList(hashSet);
		Collections.sort(i_vendor);

		return i_vendor;
	}
	
	private String getCalendarDisplay(String datein) throws Exception{
		String result = "";
		
		if (datein.length()>=10) {
			int year = Integer.parseInt(datein.substring(6,10));
			if (year>2400) year -= 543;
			int month = Integer.parseInt(datein.substring(3,5));
			int day = Integer.parseInt(datein.substring(0,2));
			result = year+"-"+(month<10 ? "0"+month : ""+month)+"-"+(day<10 ? "0"+day : ""+day);
		}
		
		return result;
	}
	
	private String getTimeFromCalendar(Calendar cal)throws Exception {
	    String result = "";
	    if (cal==null) return "-";

	    doString str = new doString();
	    result = str.createID(cal.get(Calendar.HOUR_OF_DAY),2);
	    result += ":"+str.createID(cal.get(Calendar.MINUTE),2);
			    
		return result;
	}
	
	public String getDateFromCalendar(Calendar cal)throws Exception{
	    String result = "";
	    if (cal==null) return "-";
	    
		int year = cal.get(Calendar.YEAR);
		if (year<2400) year+= 543;
	    doString str = new doString();
	    result = str.createID(cal.get(Calendar.DATE),2);
	    result += "/"+str.createID(cal.get(Calendar.MONTH)+1,2);
	    result += "/"+year;	
			    
		return result;
	}

	@Override
	public ServInfOpenJobBean findOpenJob(String i_docno) throws SQLException, Exception {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void createOpenJob(ServInfOpenJobBean openJobBean, String save_type)
			throws SQLException, InvalidParameterException, Exception {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void updateOpenJob(ServInfOpenJobBean openJobBean, String save_type)
			throws SQLException, InvalidParameterException, Exception {
		// TODO Auto-generated method stub
		
	}

}
