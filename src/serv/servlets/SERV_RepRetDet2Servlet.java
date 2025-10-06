package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;

import com.lh.servlet.DBServlet;
import com.lh.util.*;

import org.apache.poi.hssf.usermodel.*;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.hssf.util.Region;


/**
 * @version 	1.0
 * @author
 */
public class SERV_RepRetDet2Servlet extends DBServlet  {
	
	public String dateDisplay(String date) {
		String result = "";
		
		if (date.length()>=10) {
			int y = Integer.parseInt(date.substring(0,4));
			if (y<2400) y += 543;
			result = date.substring(8,10)+"/"+date.substring(5,7)+"/"+y;
		} else {
			result = "";
		}
		
		return result;
	}	
	
	public void setBorderStyle(HSSFCellStyle style) {
		style.setBorderBottom(HSSFCellStyle.BORDER_THIN);
		style.setBottomBorderColor(HSSFColor.BLACK.index);
		style.setBorderLeft(HSSFCellStyle.BORDER_THIN);
		style.setLeftBorderColor(HSSFColor.BLACK.index);
		style.setBorderRight(HSSFCellStyle.BORDER_THIN);
		style.setRightBorderColor(HSSFColor.BLACK.index);
		style.setBorderTop(HSSFCellStyle.BORDER_THIN);
		style.setTopBorderColor(HSSFColor.BLACK.index);					
	}
	
	public void genCellData(HSSFRow row,int x,HSSFCellStyle style,Object val) {
		HSSFCell cell = row.createCell((short) x);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(style);
		if (val instanceof Double) {
			cell.setCellType(HSSFCell.CELL_TYPE_NUMERIC);
			cell.setCellValue(((Double) val).doubleValue());
		} else {
			cell.setCellType(HSSFCell.CELL_TYPE_STRING);
			if (val!=null) {
				cell.setCellValue((String) val);
			} else {
				cell.setCellValue("");
			}
		}		
	}	
	
	public void setHeaderTable(/*HSSFWorkbook wb,*/HSSFSheet sheet,String ProejctName,double previousAmt,HSSFCellStyle header,HSSFCellStyle align_head,HSSFCellStyle align_right,String startDate,int row_num,boolean printPrevious) {
/*
		HSSFCellStyle header = wb.createCellStyle();			
		header.setAlignment(HSSFCellStyle.ALIGN_LEFT);

		HSSFCellStyle align_head = wb.createCellStyle();			
		align_head.setAlignment(HSSFCellStyle.ALIGN_CENTER);
		align_head.setVerticalAlignment(HSSFCellStyle.VERTICAL_CENTER);
		align_head.setFillForegroundColor(HSSFColor.GREY_25_PERCENT.index);
		align_head.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
		setBorderStyle(align_head);
*/
		HSSFRow row = sheet.createRow((short) row_num);
		row.setHeight((short) 400);		
		HSSFCell cell = row.createCell((short) 0);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(header);
		cell.setCellValue(ProejctName);
		
		
		//========= row 1 ==========//
		row = sheet.createRow((short) row_num+1);
		row.setHeight((short) 400);		
		genCellData(row,0,align_head,"ลำดับ");
		genCellData(row,1,align_head,"เลขที่ใบวางเงิน");
		genCellData(row,2,align_head,"รับเงินค้ำประกันต่อเติม");
		genCellData(row,3,align_head,"");
		genCellData(row,4,align_head,"คืนเงินค้ำประกันลูกค้า");
		genCellData(row,5,align_head,"");
		genCellData(row,6,align_head,"แปลง");
		genCellData(row,7,align_head,"บ้านเลขที่");
		genCellData(row,8,align_head,"ผู้วางเงินค้ำประกัน");
		genCellData(row,9,align_head,"เลขที่ป้าย");
		genCellData(row,10,align_head,"ระหว่างงวด");
		genCellData(row,11,align_head,"");
		genCellData(row,12,align_head,"");
		genCellData(row,13,align_head,"ยอดคงเหลือ");
		
		//========= row 2 ==========//
		row = sheet.createRow((short) row_num+2);
		row.setHeight((short) 400);			
		for (int i=0;i<=9;i++) {
			genCellData(row,i,align_head,"");
		}
		genCellData(row,10,align_head,"รับเงินประกัน");
		genCellData(row,11,align_head,"คืนเงินประกัน");
		genCellData(row,12,align_head,"");
		genCellData(row,13,align_head,"");		
		
		//========= row 3 ==========//
		row = sheet.createRow((short) row_num+3);
		row.setHeight((short) 400);			
		genCellData(row,0,align_head,"");
		genCellData(row,1,align_head,"");
		genCellData(row,2,align_head,"วันที่ Pay in");
		genCellData(row,3,align_head,"เลขที่ใบเสร็จ");
		genCellData(row,4,align_head,"วันที่เช็คคืน");
		genCellData(row,5,align_head,"เลขที่ PV.SQ.");
		for (int i=6;i<=10;i++) {
			genCellData(row,i,align_head,"");
		}
		genCellData(row,11,align_head,"หักค่าเสียหาย");
		genCellData(row,12,align_head,"จำนวนเงินคืน");
		genCellData(row,13,align_head,"");
		
		//--========= Merge Header Region ==========----//
		sheet.addMergedRegion(new Region(row_num,(short) 0,row_num,(short) 13)); // project name 
		sheet.addMergedRegion(new Region(row_num+1,(short) 0,row_num+3,(short) 0));
		sheet.addMergedRegion(new Region(row_num+1,(short) 1,row_num+3,(short) 1));
		sheet.addMergedRegion(new Region(row_num+1,(short) 2,row_num+2,(short) 3));		
		sheet.addMergedRegion(new Region(row_num+1,(short) 4,row_num+2,(short) 5));
		sheet.addMergedRegion(new Region(row_num+1,(short) 6,row_num+3,(short) 6));
		sheet.addMergedRegion(new Region(row_num+1,(short) 7,row_num+3,(short) 7));
		sheet.addMergedRegion(new Region(row_num+1,(short) 8,row_num+3,(short) 8));
		sheet.addMergedRegion(new Region(row_num+1,(short) 9,row_num+3,(short) 9));
		sheet.addMergedRegion(new Region(row_num+1,(short) 10,row_num+1,(short) 12));
		sheet.addMergedRegion(new Region(row_num+2,(short) 10,row_num+3,(short) 10));
		sheet.addMergedRegion(new Region(row_num+2,(short) 11,row_num+2,(short) 12));
		sheet.addMergedRegion(new Region(row_num+1,(short) 13,row_num+3,(short) 13));
		
		
		//--=========== print previous amount line ===========--//
		if (printPrevious) {
			row = sheet.createRow((short) row_num+4);
			row.setHeight((short) 400);
			genCellData(row,0,align_head,"ยอดยกมาก่อนวันที่ "+startDate);
			for (int t=1;t<=12;t++) {
				//--- add space cell ---//
				genCellData(row,t,align_head,"");
			}		
			genCellData(row,13,align_right,previousAmt);	
			sheet.addMergedRegion(new Region(row_num+4,(short) 0,row_num+4,(short) 12));
		}
	}
	
	
	public double getPreviousAmt(Statement stmt,String iCompany,String iProject,String startDate) throws Exception {
		double sumAmt = 0.0;
		StringBuffer sql = new StringBuffer();
		ResultSet rs = null;
		
		//--- find minimum d_close_law from this project ---//
		String minDCloseLaw = "";
		sql.delete(0,sql.length()); 
		sql.append(" select min(d_close_law) as min_close from lan:acscontr ")
		   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
		   .append(" and d_close_law is not null ");
		rs = stmt.executeQuery(sql.toString());
		while (rs.next()) {
			minDCloseLaw = doString.checkString(rs.getString("min_close"),"");
		}
		rs.close();				
		
		//--- default to old date if can't get d_close_law ---//
		if (minDCloseLaw.length()<10) minDCloseLaw = "1990-01-01"; 
		
		
		//--- find details and loop sum amount ---//
		String fRecv = "";
		String fPv = "";
		String iPvNo = "";
		String iReceipt = "";
		double zDamage = 0.0;
		double zPayback = 0.0;
		double zRecv = 0.0;
		double totalSumRecv = 0.0;
		double totalsumDamage = 0.0;
		double totalSumPayBack = 0.0;
		
		sql.delete(0,sql.length()); 
		sql.append(" select (p.d_payin<'"+minDCloseLaw+"' or p.d_payin>'"+startDate+"') as f_recv, ")
		   .append(" (d.d_pvno is null or (d.d_pvno<'"+minDCloseLaw+"' or d.d_pvno>'"+startDate+"')) as f_pv, ")
		   .append(" p.d_payin as d_recv , p.z_payin as z_recv , p.i_receipt , d.* ")
		   .append(" from lan:serv_rethd d,lan:serv_payin p ")
		   .append(" where d.i_company='"+iCompany+"' and d.i_project='"+iProject+"' ")
		   .append(" and p.i_company=d.i_company and p.i_project=d.i_project and p.i_docno=d.i_docno ")
		   .append(" and ( ")
		   .append("   (d.d_pvno is not null and d.d_pvno between '"+minDCloseLaw+"' and '"+startDate+"') ")
		   .append("   or (p.d_payin is not null and p.d_payin between '"+minDCloseLaw+"' and '"+startDate+"') ")
		   .append("   or (d.d_pvno is null and p.i_receipt is not null and p.i_receipt <>'9999999' and p.i_cashier_conf is not null) ")
		   .append(" ) ")
		   .append(" and (d.i_doc_status<>'N' and d.i_doc_status<>'C' and d.i_doc_status<>'D') ")
		   .append(" order by d.i_docno ");	
		rs = stmt.executeQuery(sql.toString());	   
		while (rs.next()) {
			  fRecv = doString.checkString(rs.getString("f_recv"),"").toUpperCase().trim();
			  fPv = doString.checkString(rs.getString("f_pv"),"").toUpperCase().trim();						
			  if (fRecv.equals("T") && fPv.equals("T")) {
			  	 continue;
			  }	
			  
			  iPvNo = doString.checkString(rs.getString("i_pvno"),"");
			  zDamage = rs.getDouble("z_damage");
			  zPayback = rs.getDouble("z_payback");
			  zRecv = rs.getDouble("z_recv");
			  iReceipt = doString.checkString(rs.getString("i_receipt"),"");
			  
			  //--- not use record with psudo receipt ---//
			  if (iReceipt.indexOf("999999")>=0) {
			  	  continue;
			  }
						  			  
			  //--- check d_payin is out of range or not ---//
			  if (fRecv.equals("T")) {
			  	  zRecv = 0.0;	
			  }

			  //--- check d_pvno is out of range or not ---//
			  if (fPv.equals("T")) {
			  	  zDamage = 0.0;
			  	  zPayback = 0.0;	
			  	  iPvNo = "";
			  }		
			  
			  //--- if i_pvno is blank or not ---//
			  if (iPvNo.trim().length()<=0) {
			  	  zPayback = 0.0; 
			  }			
			  
			  totalSumRecv += zRecv;
			  totalsumDamage += zDamage;
			  totalSumPayBack += zPayback;			  			  
		} // end while
		rs.close();
		
		//---- find difference ----//
		sumAmt = totalSumRecv - (totalsumDamage+totalSumPayBack);		
				
		return sumAmt;
	}
	
	public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		String mName = new String(this.getClass().getName() + ".performTask: ");
		System.out.println(mName + "start.");
/*
		//-----======= Check Login session =======-----//
		HttpSession session = req.getSession(false);
		if (session == null) {
			//---===== No Session , redirect to warning =======---// 
			res.sendRedirect(Constants.WARNING_PAGE);
			return;
		}
		Object obj = session.getAttribute("USER");
		if (obj == null) {
			//---===== Can't get User Login , redirect to warning ======---// 
			res.sendRedirect(Constants.WARNING_PAGE);
			return;
		}
		//----===================================----//	
     
 
		User user = (User) obj;*/
		doString str = new doString();		 		

		StringBuffer sql = new StringBuffer();
		Connection conn = null;
		Statement stmt = null;
		Statement stmt1 = null;
		ResultSet rs = null;
		ResultSet rs1 = null;

		try {
			if (ds == null)
				getDS();

			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();	
			stmt1 = conn.createStatement();	
		
		
		 	//----========================= get request data ==========================----//
			String iCompany1 = doString.checkString(req.getParameter("i_company"),""); 	
			String startDay = doString.checkString(req.getParameter("start_date"),""); 	
			String startMonth = doString.checkString(req.getParameter("start_month"),""); 	
			String startYear = doString.checkString(req.getParameter("start_year"),""); 	
			String endDay = doString.checkString(req.getParameter("end_date"),""); 	
			String endMonth = doString.checkString(req.getParameter("end_month"),""); 	
			String endYear = doString.checkString(req.getParameter("end_year"),""); 	        
	        String startDate = startYear+"-"+startMonth+"-"+startDay;
	        String endDate = endYear+"-"+endMonth+"-"+endDay;
	        
			String reportType = doString.checkString(req.getParameter("report_type"),"ALL");	        
		    //---======================================================================----//


	        
			//---================ Initialize Excel Variables ====================----//
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			HSSFWorkbook wb = new HSSFWorkbook();
			HSSFSheet sheet = wb.createSheet("Service Retention");
			HSSFRow row = null;
			HSSFCell cell = null;
			HSSFCellStyle header = wb.createCellStyle();			
			HSSFCellStyle align_head = wb.createCellStyle();
			HSSFCellStyle align_page_head = wb.createCellStyle();
			HSSFCellStyle align_center = wb.createCellStyle();
			HSSFCellStyle align_left = wb.createCellStyle();
			HSSFCellStyle align_right = wb.createCellStyle();
			HSSFCellStyle align_total_right = wb.createCellStyle();
			HSSFCellStyle top_border = wb.createCellStyle();
			
			header.setAlignment(HSSFCellStyle.ALIGN_LEFT); // no border	
			
			align_head.setAlignment(HSSFCellStyle.ALIGN_CENTER);
			align_head.setVerticalAlignment(HSSFCellStyle.ALIGN_CENTER);
			align_head.setFillForegroundColor(HSSFColor.GREY_25_PERCENT.index);
			align_head.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
			setBorderStyle(align_head);

			align_page_head.setAlignment(HSSFCellStyle.ALIGN_CENTER); // no border
			
			align_center.setAlignment(HSSFCellStyle.ALIGN_CENTER);
			setBorderStyle(align_center);

			align_left.setAlignment(HSSFCellStyle.ALIGN_LEFT);
			setBorderStyle(align_left);

			align_right.setAlignment(HSSFCellStyle.ALIGN_RIGHT);
			align_right.setDataFormat(HSSFDataFormat.getBuiltinFormat("#,##0.00"));
			setBorderStyle(align_right);
			
			align_total_right.setAlignment(HSSFCellStyle.ALIGN_RIGHT);
			align_total_right.setFillForegroundColor(HSSFColor.GREY_25_PERCENT.index);
			align_total_right.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
			align_total_right.setDataFormat(HSSFDataFormat.getBuiltinFormat("#,##0.00"));
			setBorderStyle(align_total_right);			
			
			top_border.setBorderTop(HSSFCellStyle.BORDER_THIN);
			top_border.setTopBorderColor(HSSFColor.BLACK.index);					
			


			//---========== Set Column Width ==========----//
			sheet.setColumnWidth((short) 0, (short) 1600);
			sheet.setColumnWidth((short) 1, (short) 6000);
			sheet.setColumnWidth((short) 2, (short) 3500);
			sheet.setColumnWidth((short) 3, (short) 3500);
			sheet.setColumnWidth((short) 4, (short) 3500);
			sheet.setColumnWidth((short) 5, (short) 3500);
			sheet.setColumnWidth((short) 6, (short) 2500);
			sheet.setColumnWidth((short) 7, (short) 2500);
			sheet.setColumnWidth((short) 8, (short) 12000);
			sheet.setColumnWidth((short) 9, (short) 2500);
			sheet.setColumnWidth((short) 10, (short) 3500);
			sheet.setColumnWidth((short) 11, (short) 3500);
			sheet.setColumnWidth((short) 12, (short) 3500);
			sheet.setColumnWidth((short) 13, (short) 4500);



			//----============== Set Header Table ==============----//
			row = sheet.createRow((short) 0);
			row.setHeight((short) 400);
			cell = row.createCell((short) 0);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_page_head);
			cell.setCellValue("รายงานเงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม");
			sheet.addMergedRegion(new Region(0,(short) 0,0,(short) 13));
			row = sheet.createRow((short) 1);
			row.setHeight((short) 400);
			// Create a cell and put a value in it.
			cell = row.createCell((short) 0);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_page_head);
			cell.setCellValue("วันที่ "+dateDisplay(startDate)+" - "+dateDisplay(endDate));
			sheet.addMergedRegion(new Region(1,(short) 0,1,(short) 13));
			
			
			int cntProj = 0;
			double totalSumRecv = 0.0;
			double totalsumDamage = 0.0;
			double totalSumPayBack = 0.0;
			
			int num = 0;
			String iCom = "";
			String iDocNo = "";
			String iProj = "";
			String iReten = "";
			String iPvNo = "";
			String iSort = "";
			String iHouse = "";
			String iSignBoard = "";			
			String retCustType = "";
			String retCustName = "";
			double zDamage = 0.0;
			double zPayback = 0.0;	
			
			String dPvNo = "";
			String dPayIn = "";
			String iReceipt = "";
			double zRecv = 0.0;
			double zPreviousAmt = 0.0;
			boolean printHeader = false;			
			String fRecv = "";
			String fPv = "";				
			String[] projList = req.getParameterValues("sel_proj");
			int line=2;

			if (projList!=null) {
				for (int i=0;i<projList.length;i++) {
					String proj = doString.checkString(projList[i],"");  

					//---============= get Project Details ===============----//
					String nProject = "";
					sql.delete(0,sql.length()); 
					sql.append(" select * from lan:acxprojt  ")
					   .append(" where i_company='").append(proj.length()>=6 ? proj.substring(0,2) : "").append("' ")
					   .append(" and i_project='").append(proj.length()>=6 ? proj.substring(3,6) : "").append("' ");
					rs = stmt.executeQuery(sql.toString());
					while (rs.next()) {
						nProject = doString.checkString(rs.getString("n_project"),"");
					}
					rs.close();
					  

					//--============ start print data ==========--//
				    num = 0;
					totalSumRecv = 0;
					totalsumDamage = 0.0;
					totalSumPayBack = 0.0;
					
					iCom = "";
					iDocNo = "";
			        iProj = "";
			        iReten = "";
					iPvNo = "";
					iSort = "";
					iHouse = "";
					iSignBoard = "";			
					retCustType = "";
					retCustName = "";
					zDamage = 0.0;
					zPayback = 0.0;
			
					dPvNo = "";
					dPayIn = "";
					iReceipt = "";
					zRecv = 0.0;
					zPreviousAmt = 0.0;
					printHeader = false;
					fRecv = "";
					fPv = "";	
					
					sql.delete(0,sql.length()); 
					sql.append(" select (p.d_payin<'"+startDate+"' or p.d_payin>'"+endDate+"') as f_recv, ")
					   .append(" (d.d_pvno is null or (d.d_pvno<'"+startDate+"' or d.d_pvno>'"+endDate+"')) as f_pv, ")
					   .append(" p.d_payin as d_recv , p.z_payin as z_recv , p.i_receipt , d.* ")
					   .append(" from lan:serv_rethd d,lan:serv_payin p ")
					   .append(" where d.i_company='"+(proj.length()>=6 ? proj.substring(0,2) : "")+"' ")
					   .append(" and d.i_project='"+(proj.length()>=6 ? proj.substring(3,6) : "")+"' ")
					   .append(" and p.i_company=d.i_company and p.i_project=d.i_project and p.i_docno=d.i_docno ")
					   .append(" and ( ")
					   .append("   (d.d_pvno is not null and d.d_pvno between '"+startDate+"' and '"+endDate+"') ")
					   .append("   or (p.d_payin is not null and p.d_payin between '"+startDate+"' and '"+endDate+"') ")
					   .append("   or (d.d_pvno is null and p.i_receipt is not null and p.i_receipt <>'9999999' and p.i_cashier_conf is not null) ")
					   .append(" ) ")
					   .append(" and (d.i_doc_status<>'N' and d.i_doc_status<>'C' and d.i_doc_status<>'D') ")
					   .append(" order by d.i_docno ");
					rs = stmt.executeQuery(sql.toString());
					while (rs.next()) {
						  fRecv = doString.checkString(rs.getString("f_recv"),"").toUpperCase().trim();
						  fPv = doString.checkString(rs.getString("f_pv"),"").toUpperCase().trim();						
						  if (fRecv.equals("T") && fPv.equals("T")) {
						  	 continue;
						  }				  

						  iDocNo = doString.checkString(rs.getString("i_docno"),"");
						  iCom = doString.checkString(rs.getString("i_company"),"");
		                  iProj = doString.checkString(rs.getString("i_project"),"");
		                  iReten = doString.checkString(rs.getString("i_reten"),"");
						  iPvNo = doString.checkString(rs.getString("i_pvno"),"");
						  iSort = doString.checkString(rs.getString("i_sort"),"");
						  iHouse = doString.checkString(rs.getString("i_house"),"");
						  iSignBoard = doString.checkString(rs.getString("i_signboard"),"");
						  retCustType = doString.checkString(rs.getString("i_ret_custo"),"");
						  zDamage = rs.getDouble("z_damage");
						  zPayback = rs.getDouble("z_payback");
						  dPvNo = doString.checkString(rs.getString("d_pvno"),"");	
						  dPayIn = doString.checkString(rs.getString("d_recv"),"");	
						  iReceipt = doString.checkString(rs.getString("i_receipt"),"");
						  zRecv = rs.getDouble("z_recv");
						  
						  
						  //--- not use record with psudo receipt ---//
						  if (iReceipt.equals("9999999")) {
						  	  continue;
						  }
						  
						  //--- 2023-01-30 , move filter to bottom ---//
						  //if (reportType.equalsIgnoreCase("REMAIN") && iPvNo.trim().length()>0) {
						  //	  continue;
						  //}								  
						  
						  //--- check d_payin is out of range or not ---//
						  if (fRecv.equals("T")) {
						  	  zRecv = 0.0;	
						  }
		
						  //--- check d_pvno is out of range or not ---//
						  if (fPv.equals("T")) {
						  	  zDamage = 0.0;
						  	  zPayback = 0.0;	
						  	  dPvNo = "";
						  	  iPvNo = "";
						  }		
						  
						  //--- 2023-01-30 , filter data for report_type='REMAIN' ---//
						  if (reportType.equalsIgnoreCase("REMAIN") && iPvNo.trim().length()>0) {
						  	  continue;
						  }							  
						  
						  //--- if i_pvno is blank or not ---//
						  if (iPvNo.trim().length()<=0) {
						  	  zPayback = 0.0; 
						  }						  
		
						  //-----========== Get retCustName ============-----//
						  retCustName = "";
						  sql.delete(0,sql.length());
				          if (retCustType.equals("1")) {
				   	         sql.append(" select trim(n_prename)||trim(n_ncustomer)||' '||trim(n_scustomer) as cust_name ")
					            .append(" from lan:acxcusto where i_customer='").append(iReten).append("' ");
				          } else if (retCustType.equals("2")) {
					         sql.append(" select trim(nvl(n_pname,''))||trim(nvl(n_name,''))||' '||trim(nvl(n_sname,'')) as cust_name ")
					            .append(" from lan:serv_venprj where i_vendor='").append(iReten).append("' ")
					            .append(" and i_company='").append(iCom).append("' and i_project='").append(iProj).append("' ")
					            .append(" and i_type='05' ");
				          } else {
				   	         sql.append(" select trim(nvl(n_pname,''))||trim(nvl(n_name,''))||' '||trim(nvl(n_sname,'')) as cust_name ")
					            .append(" from lan:serv_venprj where i_vendor='").append(iReten).append("' ")
					            .append(" and i_company='").append(iCom).append("' and i_project='").append(iProj).append("' ")
					            .append(" and i_type='06' ");
				          }
						  rs1 = stmt1.executeQuery(sql.toString());
						  if (rs1.next()) {
						  	  retCustName = doString.checkString(doString.DisplayThai(rs1.getString("cust_name")),"");
						  }
						  rs1.close();					  

						  totalSumRecv += zRecv;
						  totalsumDamage += zDamage;
						  totalSumPayBack += zPayback;
						  
						  
						  //================== print header ===================//
						  if (!printHeader) {
						  	  printHeader = true;
					  	  
						     //------ find previous amount ------//
						     zPreviousAmt = 0.0;	
						     
						     if (reportType.equalsIgnoreCase("ALL")) {						     
							     for (int c=1;c<=2;c++) {						     
							     	 if (c==1) {
								     	 sql.delete(0,sql.length());
							     	 	 sql.append(" select sum(p.z_payin) as sum_amt ")
							     	 	    .append(" from lan:serv_rethd d,lan:serv_payin p ")
										    .append(" where d.i_company='"+(proj.length()>=6 ? proj.substring(0,2) : "")+"' ")
										    .append(" and d.i_project='"+(proj.length()>=6 ? proj.substring(3,6) : "")+"' ")						     	 	    
							     	 	    .append(" and p.i_company=d.i_company and p.i_project=d.i_project and p.i_docno=d.i_docno ")
							     	 	    .append(" and (d.i_doc_status<>'N' and d.i_doc_status<>'C' and d.i_doc_status<>'D')  ")
							     	 	    .append(" and p.d_payin is not null and p.d_payin<'"+startDate+"' ")
							     	 	    .append(" and p.i_receipt<>'9999999' ");
							     	 } else {
								     	 sql.delete(0,sql.length());
							     	 	 sql.append(" select sum(d.z_damage+d.z_payback) as sum_amt ")
							     	 	    .append(" from lan:serv_rethd d,lan:serv_payin p ")
										    .append(" where d.i_company='"+(proj.length()>=6 ? proj.substring(0,2) : "")+"' ")
										    .append(" and d.i_project='"+(proj.length()>=6 ? proj.substring(3,6) : "")+"' ")						     	 	    
							     	 	    .append(" and p.i_company=d.i_company and p.i_project=d.i_project and p.i_docno=d.i_docno  ")
							     	 	    .append(" and (d.i_doc_status<>'N' and d.i_doc_status<>'C' and d.i_doc_status<>'D')  ")
							     	 	    .append(" and p.d_payin is not null and p.d_payin<'"+startDate+"' and ( ")
							     	 	    .append("   (d.d_pvno is null and p.i_receipt is not null and p.i_cashier_conf is not null) ")
							     	 	    .append("   or (d.d_pvno is not null and d.d_pvno<'"+startDate+"') ")
							     	 	    .append(" ) ")
							     	 	    .append(" and p.i_receipt<>'9999999' ");
							     	 }
								     rs1 = stmt1.executeQuery(sql.toString());
								     if (rs1.next()) {
								  	     if (c==1) {
								  	  	     //--- first step , get payin amount ---//
								  	  	     zPreviousAmt += rs1.getDouble("sum_amt");
								  	     } else {
								  	  	     //--- second step , minus amount with reten amount ---//
								  	  	     zPreviousAmt -= rs1.getDouble("sum_amt");
								  	     }
								     }
								     rs1.close();
							     } // end for	
						     } // end if report_type
						     
							 //--==== Start Print Header ====----//
						     if (reportType.equalsIgnoreCase("ALL")) {
								 setHeaderTable(sheet,doString.MS874ToUnicode(str.replace(proj,":","-")+" "+nProject),zPreviousAmt,header,align_head,align_total_right,dateDisplay(startDate),line,true);
								 line+=5;
						     } else {
								 setHeaderTable(sheet,doString.MS874ToUnicode(str.replace(proj,":","-")+" "+nProject),zPreviousAmt,header,align_head,align_total_right,dateDisplay(startDate),line,false);
								 line+=4;						    	 
						     }
						     
						  } // end if print header
						  
						  
						  //---- print details line -----//
						  row = sheet.createRow((short) line);
						  row.setHeight((short) 400);
						  
						  num++;
						  genCellData(row,0,align_right,Integer.toString(num));
						  genCellData(row,1,align_center,iDocNo);
						  genCellData(row,2,align_center,dateDisplay(dPayIn));
						  genCellData(row,3,align_center,iReceipt);
						  genCellData(row,4,align_center,dateDisplay(dPvNo));
						  genCellData(row,5,align_center,iPvNo);
						  genCellData(row,6,align_center,iSort);
						  genCellData(row,7,align_center,iHouse);
						  genCellData(row,8,align_left,retCustName);
						  genCellData(row,9,align_center,iSignBoard);
						  genCellData(row,10,align_right,zRecv);
						  genCellData(row,11,align_right,zDamage);
						  genCellData(row,12,align_right,zPayback);
						  genCellData(row,13,align_right,zRecv-(zDamage+zPayback));
						    line++;
					  } // end while 
					  rs.close();
					  
					  
				    //================= print footer ======================//
				    if (printHeader && num>0) {
						row = sheet.createRow((short) line);
						row.setHeight((short) 400);
						genCellData(row,0,align_head,"รวมทั้งสิ้น");
						for (int t=1;t<=9;t++) {
							//--- add space cell ---//
							genCellData(row,t,align_head,"");
						}		
						
						genCellData(row,10,align_total_right,totalSumRecv);
						genCellData(row,11,align_total_right,totalsumDamage);
						genCellData(row,12,align_total_right,totalSumPayBack);
						genCellData(row,13,align_total_right,(totalSumRecv+zPreviousAmt)-(totalsumDamage+totalSumPayBack));
						sheet.addMergedRegion(new Region(line,(short) 0,line,(short) 9));
						
						line+= 2; // add space for next project
					    cntProj++; // count project has data
				    } // end if 							  
						  
				} // end for project
			} 			
			
	

		    //---========= Generate Excel Document ===========----//	
		    wb.write(baos);
		    res.setContentType("application/vnd.ms-excel");
		    res.setHeader("content-disposition","filename=service_reten.xls");		
		    res.setContentLength(baos.size());
		    ServletOutputStream out = res.getOutputStream();
		    baos.writeTo(out);
		    out.flush();

			conn.commit();
			stmt.close();
			conn.close();
			conn = null;
			
		} catch (Exception e) {
			System.out.println(" ERROR "+mName+" : " + e.getMessage());
			System.out.println(" ERROR "+mName+" SQL : " + sql.toString());			
		} finally {
			try {
				if (rs!=null) rs.close(); 
				if (rs1!=null) rs1.close(); 
				if (stmt != null) stmt.close();
				if (stmt1 != null) stmt1.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");

	}

}
