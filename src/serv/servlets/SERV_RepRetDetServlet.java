package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;

import com.lh.servlet.DBServlet;
import com.lh.util.*;
import com.lh.exception.InvalidParameterException;

import org.apache.poi.hssf.usermodel.*;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.hssf.util.Region;

import serv.common.User;
import serv.common.Constants;
import serv.common.SERV_CommonData;

/**
 * @version 	1.0
 * @author
 */
public class SERV_RepRetDetServlet extends DBServlet  {
	
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
	
	public void setHeaderTable(HSSFWorkbook wb,HSSFSheet sheet,String ProejctName,int row_num) {

		HSSFCellStyle header = wb.createCellStyle();			
		header.setAlignment(HSSFCellStyle.ALIGN_LEFT);

		HSSFCellStyle align_head = wb.createCellStyle();			
		align_head.setAlignment(HSSFCellStyle.ALIGN_CENTER);
		align_head.setVerticalAlignment(HSSFCellStyle.ALIGN_CENTER);
		align_head.setFillForegroundColor(HSSFColor.GREY_25_PERCENT.index);
		align_head.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
		setBorderStyle(align_head);

		HSSFRow row = sheet.createRow((short) row_num);
		row.setHeight((short) 400);		
		HSSFCell cell = row.createCell((short) 0);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(header);
		cell.setCellValue(ProejctName);
		
		row = sheet.createRow((short) row_num+1);
		row.setHeight((short) 400);		
		cell = row.createCell((short) 0);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("ลำดับ");
		cell = row.createCell((short) 1);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("เลขที่ใบวางเงิน");
		cell = row.createCell((short) 2);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("รับเงินค้ำประกันต่อเติม");
		cell = row.createCell((short) 3);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("");		
		cell = row.createCell((short) 4);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("คืนเงินค้ำประกันลูกค้า");
		cell = row.createCell((short) 5);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("");
		cell = row.createCell((short) 6);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("แปลง");
		cell = row.createCell((short) 7);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("บ้านเลขที่");
		cell = row.createCell((short) 8);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("ผู้วางเงินค้ำประกัน");
		cell = row.createCell((short) 9);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("เลขที่ป้าย");
		cell = row.createCell((short) 10);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("ยอดยกมา");
		cell = row.createCell((short) 11);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("รับเงินประกัน");
		cell = row.createCell((short) 12);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("คืนเงินประกัน");
		cell = row.createCell((short) 13);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("");		
		cell = row.createCell((short) 14);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("ยอดคงเหลือ");
		
		
		row = sheet.createRow((short) row_num+2);
		row.setHeight((short) 400);	
		cell = row.createCell((short) 0);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("");
		cell = row.createCell((short) 1);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("");
		cell = row.createCell((short) 2);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("วันที่ Pay in");
		cell = row.createCell((short) 3);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("เลขที่ใบเสร็จ");
		cell = row.createCell((short) 4);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("วันที่เช็คคืน");
		cell = row.createCell((short) 5);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("เลขที่ PV.SQ.");
		cell = row.createCell((short) 6);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("");
		cell = row.createCell((short) 7);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("");
		cell = row.createCell((short) 8);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("");
		cell = row.createCell((short) 9);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("");
		cell = row.createCell((short) 10);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("");
		cell = row.createCell((short) 11);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("");
		cell = row.createCell((short) 12);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("หักค่าเสียหาย");
		cell = row.createCell((short) 13);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("จำนวนเงินคืน");
		cell = row.createCell((short) 14);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_head);
		cell.setCellValue("");
		
		
		//--========= Merge Region ==========----//
		sheet.addMergedRegion(new Region(row_num,(short) 0,row_num,(short) 14));		
		sheet.addMergedRegion(new Region(row_num+1,(short) 0,row_num+2,(short) 0));
		sheet.addMergedRegion(new Region(row_num+1,(short) 1,row_num+2,(short) 1));
		sheet.addMergedRegion(new Region(row_num+1,(short) 2,row_num+1,(short) 3));
		sheet.addMergedRegion(new Region(row_num+1,(short) 4,row_num+1,(short) 5));
		sheet.addMergedRegion(new Region(row_num+1,(short) 6,row_num+2,(short) 6));
		sheet.addMergedRegion(new Region(row_num+1,(short) 7,row_num+2,(short) 7));
		sheet.addMergedRegion(new Region(row_num+1,(short) 8,row_num+2,(short) 8));
		sheet.addMergedRegion(new Region(row_num+1,(short) 9,row_num+2,(short) 9));
		sheet.addMergedRegion(new Region(row_num+1,(short) 10,row_num+2,(short) 10));
		sheet.addMergedRegion(new Region(row_num+1,(short) 11,row_num+2,(short) 11));
		sheet.addMergedRegion(new Region(row_num+1,(short) 12,row_num+1,(short) 13));
		sheet.addMergedRegion(new Region(row_num+1,(short) 14,row_num+2,(short) 14));
		

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
		SERV_CommonData common = null;


		try {
			if (ds == null)
				getDS();

			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();	
			stmt1 = conn.createStatement();	
			common = new SERV_CommonData(conn);		

		
		
			//----================== Get Parameter from request ====================----//
			String iCompany = doString.checkString(req.getParameter("i_company"),"");
			String startDate = doString.checkString(req.getParameter("start_date"),"");
			String endDate = doString.checkString(req.getParameter("end_date"),"");
			String condition = "";			
			Calendar start = Calendar.getInstance();
			Calendar end = Calendar.getInstance();

			if (startDate.trim().length()>=10) {
				start.set(Integer.parseInt(startDate.substring(0,4)),Integer.parseInt(startDate.substring(5,7))-1,Integer.parseInt(startDate.substring(8,10)));
			}
			if (endDate.trim().length()>=10) {
				end.set(Integer.parseInt(endDate.substring(0,4)),Integer.parseInt(endDate.substring(5,7))-1,Integer.parseInt(endDate.substring(8,10)));
			}			
		    //---===============================================================----//


			//---================ Initialize Excel Variables ====================----//
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			HSSFWorkbook wb = new HSSFWorkbook();
			HSSFSheet sheet = wb.createSheet("new sheet");
			HSSFRow row = null;
			HSSFCell cell = null;
			HSSFCellStyle align_head = wb.createCellStyle();
			HSSFCellStyle align_page_head = wb.createCellStyle();
			HSSFCellStyle align_center = wb.createCellStyle();
			HSSFCellStyle align_left = wb.createCellStyle();
			HSSFCellStyle align_right = wb.createCellStyle();
			HSSFCellStyle top_border = wb.createCellStyle();
			
			align_head.setAlignment(HSSFCellStyle.ALIGN_CENTER);
			align_head.setVerticalAlignment(HSSFCellStyle.ALIGN_CENTER);
			align_head.setFillForegroundColor(HSSFColor.GREY_25_PERCENT.index);
			align_head.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
			setBorderStyle(align_head);

			align_page_head.setAlignment(HSSFCellStyle.ALIGN_CENTER);
			
			align_center.setAlignment(HSSFCellStyle.ALIGN_CENTER);
			setBorderStyle(align_center);

			align_left.setAlignment(HSSFCellStyle.ALIGN_LEFT);
			setBorderStyle(align_left);

			align_right.setAlignment(HSSFCellStyle.ALIGN_RIGHT);
			setBorderStyle(align_right);
			
			top_border.setBorderTop(HSSFCellStyle.BORDER_THIN);
			top_border.setTopBorderColor(HSSFColor.BLACK.index);					
			


			//---========== Set Column Width ==========----//
			sheet.setColumnWidth((short) 0, (short) 1600);
			sheet.setColumnWidth((short) 1, (short) 8000);
			sheet.setColumnWidth((short) 2, (short) 3500);
			sheet.setColumnWidth((short) 3, (short) 3500);
			sheet.setColumnWidth((short) 4, (short) 3500);
			sheet.setColumnWidth((short) 5, (short) 3500);
			sheet.setColumnWidth((short) 6, (short) 3500);
			sheet.setColumnWidth((short) 7, (short) 3500);
			sheet.setColumnWidth((short) 8, (short) 12000);
			sheet.setColumnWidth((short) 9, (short) 3500);
			sheet.setColumnWidth((short) 10, (short) 3500);
			sheet.setColumnWidth((short) 11, (short) 3500);
			sheet.setColumnWidth((short) 12, (short) 3500);
			sheet.setColumnWidth((short) 13, (short) 3500);
			sheet.setColumnWidth((short) 14, (short) 3500);



			//----============== Set Header Table ==============----//
			row = sheet.createRow((short) 0);
			row.setHeight((short) 400);
			cell = row.createCell((short) 0);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_page_head);
			cell.setCellValue("สรุปเงินค้ำประกันความเสียหายสาธารณูปโภคและพื้นที่บริการสาธารณะ");
			sheet.addMergedRegion(new Region(0,(short) 0,0,(short) 14));
			row = sheet.createRow((short) 1);
			row.setHeight((short) 400);
			// Create a cell and put a value in it.
			cell = row.createCell((short) 0);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_page_head);
			cell.setCellValue("วันที่ "+common.getDateFromCalendar(start)+" - "+common.getDateFromCalendar(end));
			sheet.addMergedRegion(new Region(1,(short) 0,1,(short) 14));
			
			
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
					  
					
					 //--==== Start Print Header ====----//					  
					 setHeaderTable(wb,sheet,doString.MS874ToUnicode(str.replace(proj,":","-")+" "+nProject),line);
					 line+=3;
					 
					 
					//---============= get Doc Details ===============----//
					double totalSumOldReten  = 0.0;
					double totalSumNowReten = 0.0;
					double totalsumDamage = 0.0;
					double totalSumPayBack = 0.0;
					int num = 0;
					boolean foundPayin = false;
					
					sql.delete(0,sql.length()); 
					sql.append(" select * from lan:serv_rethd ")
						  .append(" where i_company='").append(proj.length()>=6 ? proj.substring(0,2) : "").append("' ")
						  .append(" and i_project='").append(proj.length()>=6 ? proj.substring(3,6) : "").append("' ")
						  .append(" and (i_doc_status<>'N' and i_doc_status<>'C') ")
						  .append(" and (d_pvno is null or (d_pvno>'").append(endDate).append("')) order by i_docno ");						  
					      //.append(" and (d_pvno is null or (d_pvno between '").append(startDate).append("' and '").append(endDate).append("')) order by i_docno ");						  
					rs = stmt.executeQuery(sql.toString());
					while (rs.next()) {
						  //num++;
						  foundPayin = true;			
						  
						 Vector dPayinList = new Vector();
						 Vector iReceiptList = new Vector();
						 Vector oldReceive = new Vector();
						 Vector newReceive = new Vector();
						
												  			  
						  String iDocNo = doString.checkString(rs.getString("i_docno"),"");
						  String comId = doString.checkString(rs.getString("i_company"),"");
						  String iProject = doString.checkString(rs.getString("i_project"),"");
						  String iReten = doString.checkString(rs.getString("i_reten"),"");
						  String iPvNo = doString.checkString(rs.getString("i_pvno"),"");
						  String iSort = doString.checkString(rs.getString("i_sort"),"");
						  String iHouse = doString.checkString(rs.getString("i_house"),"");
						  String iSignBoard = doString.checkString(rs.getString("i_signboard"),"");
						  String retCustType = doString.checkString(rs.getString("i_ret_custo"),"");
						  double zDamage = rs.getDouble("z_damage");
						  double zPayback = rs.getDouble("z_payback");


						  //---======= Get Cheque Confirm Date =========---//
						  String dConfChq = "";
						  Calendar chqDate = Calendar.getInstance();
						  Timestamp temp = rs.getTimestamp("d_conf_chq");
						  if (temp!=null)  {
							  chqDate.setTime(temp);      
							  dConfChq = common.getDateFromCalendar(chqDate); 
						  }


				
						//---===== Payto Date is between range , reset z_payback =========--//
						Timestamp pay = rs.getTimestamp("d_payto");
						if (pay!=null)  {
							Calendar payto = Calendar.getInstance(Locale.ENGLISH);
							payto.setTime(pay);
							
							int startD = Integer.parseInt(str.replace(startDate,"-",""));
							int endD = Integer.parseInt(str.replace(endDate,"-",""));
							int payD = Integer.parseInt(str.createID(payto.get(Calendar.YEAR),4)+str.createID(payto.get(Calendar.MONTH)+1,2)+str.createID(payto.get(Calendar.DATE),2));
							
							if (startD<=payD && payD<=endD) {
							   zPayback = 0.0;
							}
						}


							//-----========== Get retCustName ============-----//
							String retCustName = "";
							sql.delete(0,sql.length());
							if (retCustType.equals("1")) {
							sql.append(" select trim(n_prename)||trim(n_ncustomer)||' '||trim(n_scustomer) as cust_name ")
								  .append(" from lan:acxcusto where i_customer='").append(iReten).append("' ");
							} else if (retCustType.equals("2")) {
							sql.append(" select trim(n_pname)||trim(n_name)||' '||trim(n_sname) as cust_name ")
								  .append(" from lan:serv_venprj where i_vendor='").append(iReten).append("' ")
								  .append(" and i_company='").append(comId).append("' and i_project='").append(iProject).append("' ")
								  .append(" and i_type='05' ");
							} else {
							sql.append(" select trim(n_pname)||trim(n_name)||' '||trim(n_sname) as cust_name ")
								  .append(" from lan:serv_venprj where i_vendor='").append(iReten).append("' ")
								  .append(" and i_company='").append(comId).append("' and i_project='").append(iProject).append("' ")
								  .append(" and i_type='06' ");
							}
							rs1 = stmt1.executeQuery(sql.toString());
							if (rs1.next()) {
								retCustName = doString.checkString(rs1.getString("cust_name"),"");
							}
							rs1.close();


						boolean used = false;

							//---============= Get Payin List ===============----//
							sql.delete(0,sql.length()); 
							sql.append(" select a.*,b.i_receipt,b.z_recv_reten as z_recv,b.d_payin from lan:serv_rethd a,lan:serv_payin b where ")
								  .append(" b.i_company=a.i_company and b.i_project=a.i_project and b.i_docno=a.i_docno ")
								  .append(" and (b.i_receipt is not null and b.i_receipt <>'999999') and b.i_cashier_conf is not null ")
								  .append(" and a.i_docno='").append(iDocNo).append("' ");
							rs1 = stmt1.executeQuery(sql.toString());
							while (rs1.next()) {
								/*
									String iReceipt = doString.checkString(rs1.getString("i_receipt"),"");
									double zReceipt = rs1.getDouble("z_recv");
									String payinDate = "";
									used = true;									


									Calendar payin = Calendar.getInstance(Locale.ENGLISH);
									Timestamp tmp = rs1.getTimestamp("d_payin");
									if (tmp!=null)  {
										payin.setTime(tmp);      
										payinDate = common.getDateFromCalendar(payin);

										try {
											int startD = Integer.parseInt(str.replace(startDate,"-",""));
											int endD = Integer.parseInt(str.replace(endDate,"-",""));
											int payD = Integer.parseInt(str.createID(payin.get(Calendar.YEAR),4)+str.createID(payin.get(Calendar.MONTH)+1,2)+str.createID(payin.get(Calendar.DATE),2));


											if (payD<startD) {
												//---==== Payin Date < Start Date , set to old =======---//
												oldReceive.addElement(new Double(zReceipt));
												newReceive.addElement(new Double(0.00));
												used = true;
											} else if (startD<=payD && payD<=endD) {
												//---===== Payin Date is between range , set to new =========--//
												oldReceive.addElement(new Double(0.00));
												newReceive.addElement(new Double(zReceipt));
												used = true;
											} else {
												//---===== Payin Date > End Date , set blank =========--//
												used = false;
											}
/ *
										   if (payD<startD) {
											   //---==== Payin Date < Start Date , set to old =======---//
											   oldReceive.addElement(new Double(zReceipt));
											   newReceive.addElement(new Double(0.00));
										   } else if (startD<=payD && payD<=endD) {
											   //---===== Payin Date is between range , set to new =========--//
											   oldReceive.addElement(new Double(0.00));
											   newReceive.addElement(new Double(zReceipt));
										   } else {
											   //---===== Payin Date > End Date , set blank =========--//
												used = false;
										   }
* /										   
										} catch (Exception e) {
											used = false;
										}

									} else {
									   //oldReceive.addElement(new Double(zReceipt));
									   //newReceive.addElement(new Double(0.00));
									   used = false;
									} // end if check temp;

									dPayinList.addElement(payinDate);
									iReceiptList.addElement(iReceipt);
							*/
							
								String iReceipt = doString.checkString(rs1.getString("i_receipt"),"");
								double zReceipt = rs1.getDouble("z_recv");
								String payinDate = "";
								used = true;
	
	
								Calendar payin = Calendar.getInstance(Locale.ENGLISH);
								Timestamp tmp = rs1.getTimestamp("d_payin");
								if (tmp!=null)  {
									payin.setTime(tmp);      
									payinDate = common.getDateFromCalendar(payin);
	
									try {
										int startD = Integer.parseInt(str.replace(startDate,"-",""));
										int endD = Integer.parseInt(str.replace(endDate,"-",""));
										int payD = Integer.parseInt(str.createID(payin.get(Calendar.YEAR),4)+str.createID(payin.get(Calendar.MONTH)+1,2)+str.createID(payin.get(Calendar.DATE),2));
	
	
									   if (payD<startD) {
										   //---==== Payin Date < Start Date , set to old =======---//
										   oldReceive.addElement(new Double(zReceipt));
										   newReceive.addElement(new Double(0.00));
										   used = true;
									   } else if (startD<=payD && payD<=endD) {
										   //---===== Payin Date is between range , set to new =========--//
										   oldReceive.addElement(new Double(0.00));
										   newReceive.addElement(new Double(zReceipt));
										   used = true;
									   } else {
										   //---===== Payin Date > End Date , set blank =========--//
										   used = false;
									   }
	
									} catch (Exception e) {
									   used = false;
									}
	
								} else {
								   //oldReceive.addElement(new Double(zReceipt));
								   //newReceive.addElement(new Double(0.00));
								   used = false;
								} // end if check temp;
	
	
								dPayinList.addElement(payinDate);
								iReceiptList.addElement(iReceipt);
														
							
							} // end while check payin							
							rs1.close(); 

if (used) {
					num++;

							double showOldReceipt = (oldReceive.size()>0 ? ((Double) oldReceive.elementAt(0)).doubleValue() : 0.00);
							double showNewReceipt = (newReceive.size()>0 ? ((Double) newReceive.elementAt(0)).doubleValue() : 0.00);


							totalSumOldReten += showOldReceipt;
							totalSumNowReten += showNewReceipt;
							totalsumDamage += zDamage;
							totalSumPayBack += zPayback;

							row = sheet.createRow((short) line);
							row.setHeight((short) 400);		
							cell = row.createCell((short) 0);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellStyle(align_center);
							cell.setCellValue(num);
							cell = row.createCell((short) 1);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellStyle(align_left);
							cell.setCellValue(iDocNo);
							cell = row.createCell((short) 2);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellStyle(align_center);
							cell.setCellValue(doString.MS874ToUnicode((dPayinList.size()>0 ? ((String) dPayinList.elementAt(0)) : "" )));
							cell = row.createCell((short) 3);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellStyle(align_center);
							cell.setCellValue(doString.MS874ToUnicode((iReceiptList.size()>0 ? ((String) iReceiptList.elementAt(0)) : "")));		
							cell = row.createCell((short) 4);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellStyle(align_center);
							cell.setCellValue(doString.MS874ToUnicode(dConfChq));
							cell = row.createCell((short) 5);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellStyle(align_center);
							cell.setCellValue(doString.MS874ToUnicode(iPvNo));
							cell = row.createCell((short) 6);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellStyle(align_center);
							cell.setCellValue(doString.MS874ToUnicode(iSort));
							cell = row.createCell((short) 7);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellStyle(align_center);
							cell.setCellValue(doString.MS874ToUnicode(iHouse));
							cell = row.createCell((short) 8);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellStyle(align_left);
							cell.setCellValue(doString.MS874ToUnicode(retCustName));
							cell = row.createCell((short) 9);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellStyle(align_center);
							cell.setCellValue(doString.MS874ToUnicode(iSignBoard));
							cell = row.createCell((short) 10);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellStyle(align_right);
							cell.setCellValue(showOldReceipt);
							cell = row.createCell((short) 11);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellStyle(align_right);
							cell.setCellValue(showNewReceipt);
							cell = row.createCell((short) 12);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellStyle(align_right);
							cell.setCellValue(zDamage);
							cell = row.createCell((short) 13);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellStyle(align_right);
							cell.setCellValue(zPayback);		
							cell = row.createCell((short) 14);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellStyle(align_right);
							cell.setCellValue((showOldReceipt+showNewReceipt)-(zDamage+zPayback));
							line++;
							
							
						//---============= If have payin more than 1 , print other payin ================---//
						if (dPayinList.size()>1) {
							for (int n=1;n<dPayinList.size();n++) {
								   totalSumOldReten += ((Double) oldReceive.elementAt(n)).doubleValue();
								   totalSumNowReten += ((Double) newReceive.elementAt(n)).doubleValue();

									row = sheet.createRow((short) line);
									row.setHeight((short) 400);		
									cell = row.createCell((short) 0);
									cell.setEncoding(HSSFCell.ENCODING_UTF_16);
									cell.setCellStyle(align_center);
									cell.setCellValue("");
									cell = row.createCell((short) 1);
									cell.setEncoding(HSSFCell.ENCODING_UTF_16);
									cell.setCellStyle(align_center);
									cell.setCellValue("");
									cell = row.createCell((short) 2);
									cell.setEncoding(HSSFCell.ENCODING_UTF_16);
									cell.setCellStyle(align_center);
									cell.setCellValue(doString.MS874ToUnicode(doString.checkString(((String) dPayinList.elementAt(n)),"")));
									cell = row.createCell((short) 3);
									cell.setEncoding(HSSFCell.ENCODING_UTF_16);
									cell.setCellStyle(align_center);
									cell.setCellValue(doString.MS874ToUnicode(doString.checkString(((String) iReceiptList.elementAt(n)),"")));		
									cell = row.createCell((short) 4);
									cell.setEncoding(HSSFCell.ENCODING_UTF_16);
									cell.setCellStyle(align_center);
									cell.setCellValue("");
									cell = row.createCell((short) 5);
									cell.setEncoding(HSSFCell.ENCODING_UTF_16);
									cell.setCellStyle(align_center);
									cell.setCellValue("");
									cell = row.createCell((short) 6);
									cell.setEncoding(HSSFCell.ENCODING_UTF_16);
									cell.setCellStyle(align_center);
									cell.setCellValue("");
									cell = row.createCell((short) 7);
									cell.setEncoding(HSSFCell.ENCODING_UTF_16);
									cell.setCellStyle(align_center);
									cell.setCellValue("");
									cell = row.createCell((short) 8);
									cell.setEncoding(HSSFCell.ENCODING_UTF_16);
									cell.setCellStyle(align_center);
									cell.setCellValue("");
									cell = row.createCell((short) 9);
									cell.setEncoding(HSSFCell.ENCODING_UTF_16);
									cell.setCellStyle(align_center);
									cell.setCellValue("");
									cell = row.createCell((short) 10);
									cell.setEncoding(HSSFCell.ENCODING_UTF_16);
									cell.setCellStyle(align_right);
									cell.setCellValue(((Double) oldReceive.elementAt(n)).doubleValue());
									cell = row.createCell((short) 11);
									cell.setEncoding(HSSFCell.ENCODING_UTF_16);
									cell.setCellStyle(align_right);
									cell.setCellValue(((Double) newReceive.elementAt(n)).doubleValue());
									cell = row.createCell((short) 12);
									cell.setEncoding(HSSFCell.ENCODING_UTF_16);
									cell.setCellStyle(align_center);
									cell.setCellValue("");
									cell = row.createCell((short) 13);
									cell.setEncoding(HSSFCell.ENCODING_UTF_16);
									cell.setCellStyle(align_center);
									cell.setCellValue("");		
									cell = row.createCell((short) 14);
									cell.setEncoding(HSSFCell.ENCODING_UTF_16);
									cell.setCellStyle(align_center);
									cell.setCellValue("");
									
									line++;
							}
						}	// end if check payin is more than 1

} // end if check used

					} // end while iDocNo
					rs.close();

					
					//--================ If no data, print data not found ==========---//
					if (!foundPayin) {
						row = sheet.createRow((short) line);
						row.setHeight((short) 400);		
						cell = row.createCell((short) 0);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellStyle(align_center);
						cell.setCellValue("ไม่พบข้อมูล !!");
						
						for (int l=1;l<15;l++) {
							cell = row.createCell((short) l);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellStyle(align_center);
							cell.setCellValue("");
						}
										
						sheet.addMergedRegion(new Region(line,(short) 0,line,(short) 14));				
						line++;
					} 


					//----================= Print Total Line =======================----//
					else {
						row = sheet.createRow((short) line);
						row.setHeight((short) 400);		
						cell = row.createCell((short) 0);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellStyle(align_center);
						cell.setCellValue("รวมทั้งสิ้น");
						cell = row.createCell((short) 1);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellStyle(align_center);
						cell.setCellValue("");
						cell = row.createCell((short) 2);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellStyle(align_center);
						cell.setCellValue("");
						cell = row.createCell((short) 3);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellStyle(align_center);
						cell.setCellValue("");		
						cell = row.createCell((short) 4);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellStyle(align_center);
						cell.setCellValue("");
						cell = row.createCell((short) 5);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellStyle(align_center);
						cell.setCellValue("");
						cell = row.createCell((short) 6);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellStyle(align_center);
						cell.setCellValue("");
						cell = row.createCell((short) 7);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellStyle(align_center);
						cell.setCellValue("");
						cell = row.createCell((short) 8);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellStyle(align_center);
						cell.setCellValue("");
						cell = row.createCell((short) 9);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellStyle(align_center);
						cell.setCellValue("");
						cell = row.createCell((short) 10);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellStyle(align_right);
						cell.setCellValue(totalSumOldReten);
						cell = row.createCell((short) 11);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellStyle(align_right);
						cell.setCellValue(totalSumNowReten);
						cell = row.createCell((short) 12);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellStyle(align_right);
						cell.setCellValue(totalsumDamage);
						cell = row.createCell((short) 13);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellStyle(align_right);
						cell.setCellValue(totalSumPayBack);		
						cell = row.createCell((short) 14);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellStyle(align_right);
						cell.setCellValue((totalSumOldReten+totalSumNowReten)-(totalsumDamage+totalSumPayBack));					
						sheet.addMergedRegion(new Region(line,(short) 0,line,(short) 9));
						line++;						
					}

					 
					 line++;
					  
				} // end for projList
			} // end if
	   
		   


		   //---========= Generate Excel Document ===========----//	
		   wb.write(baos);
		   res.setContentType("application/vnd.ms-excel");
		   res.setContentLength(baos.size());
		   ServletOutputStream out = res.getOutputStream();
		   baos.writeTo(out);
		   out.flush();


			
			conn.commit();
			stmt.close();
			conn.close();
			conn = null;
		 /*} catch (DocumentException de) {
			 de.printStackTrace();
			 System.err.println("error SERV_RepRetSumServlet  DOCUMENT: " + de.getMessage());*/
		} catch (Exception e) {
			System.out.println(" ERROR "+mName+" : " + e.getMessage());
			System.out.println(" ERROR "+mName+" SQL : " + sql.toString());			
		} finally {
			try {
				if (rs!=null) rs.close(); 
				if (rs1!=null) rs.close(); 
				if (stmt != null) stmt.close();
				if (stmt1 != null) stmt.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");

	}

}
