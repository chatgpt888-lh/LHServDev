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
public class SERV_RepRetSumServlet extends DBServlet  {
	
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
			sheet.setColumnWidth((short) 1, (short) 12000);
			sheet.setColumnWidth((short) 2, (short) 1600);
			sheet.setColumnWidth((short) 3, (short) 3500);
			sheet.setColumnWidth((short) 4, (short) 3500);
			sheet.setColumnWidth((short) 5, (short) 3500);
			sheet.setColumnWidth((short) 6, (short) 3500);
			sheet.setColumnWidth((short) 7, (short) 3500);



			//----============== Set Header Table ==============----//
			row = sheet.createRow((short) 0);
			row.setHeight((short) 400);
			cell = row.createCell((short) 0);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_page_head);
			cell.setCellValue("สรุปเงินค้ำประกันความเสียหายสาธารณูปโภคและพื้นที่บริการสาธารณะ");
			sheet.addMergedRegion(new Region(0,(short) 0,0,(short) 6));
			row = sheet.createRow((short) 1);
			row.setHeight((short) 400);
			// Create a cell and put a value in it.
			cell = row.createCell((short) 0);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_page_head);
			cell.setCellValue("วันที่ "+common.getDateFromCalendar(start)+" - "+common.getDateFromCalendar(end));
			sheet.addMergedRegion(new Region(1,(short) 0,1,(short) 6));
			
			
			row = sheet.createRow((short) 2);
			row.setHeight((short) 400);
			// Create a cell and put a value in it.
			cell = row.createCell((short) 0);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("ลำดับ");

			cell = row.createCell((short) 1);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("โครงการ");

			cell = row.createCell((short) 2);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("จำนวน");

			cell = row.createCell((short) 3);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("ยอดยกมา");

			cell = row.createCell((short) 4);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("รับเงินค้ำประกัน");

			cell = row.createCell((short) 5);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("คืนเงินค้ำประกัน");

			cell = row.createCell((short) 6);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("ยอดคงเหลือ");




			String[] projList = req.getParameterValues("sel_proj");
			int line=2;
			int totalCountProj = 0;
			double totalSumPayBack = 0.0;
			double totalSumOldReten = 0.0;
			double totalSumNowReten = 0.0;
	
	
			if (projList!=null) {
				for (int i=0;i<projList.length;i++) {
					   line++;
					   String proj = doString.checkString(projList[i],"");  
	
	
					  //---============= get Project Details ===============----//
					  String nProject = "";
					  sql.delete(0,sql.length()); 
					  sql.append(" select * from lan:acxprojt where i_company||':'||i_project='").append(proj).append("' ");
					  rs = stmt.executeQuery(sql.toString());
					  while (rs.next()) {
						   nProject = doString.checkString(rs.getString("n_project"),"");
					  }
					  rs.close();
	/*
					  //---============= get countProject ===============----//
					  int countProj = 0;
					  double sumPayback = 0.0;
					  sql.delete(0,sql.length()); 
					  sql.append(" select count(*) cnt ,sum(z_payback) sum_payback from lan:serv_rethd where i_company||':'||i_project='").append(proj).append("' ")
							.append(" and i_doc_status not in ('N','C') ")
							.append(" and (d_pvno is null or (d_pvno>='").append(startDate).append("')) ");
					  rs = stmt.executeQuery(sql.toString());
					  while (rs.next()) {
						   countProj = rs.getInt("cnt");
						   sumPayback = rs.getDouble("sum_payback");
					  }
					  rs.close();
	*/
	
	
						//---============= get countProject ===============----//
						int countProj = 0;
						double sumPayback = 0.0;
						String idocList = "";
						sql.delete(0,sql.length()); 
						sql.append(" select * from lan:serv_rethd ")
							  .append(" where i_company='").append(proj.length()>=6 ? proj.substring(0,2) : "").append("' ")
							  .append(" and i_project='").append(proj.length()>=6 ? proj.substring(3,6) : "").append("' ")
							  .append(" and (i_doc_status<>'N' and i_doc_status<>'C') ")
							  .append(" and (d_pvno is null or (d_pvno>'").append(endDate).append("')) order by i_docno ");
						rs = stmt.executeQuery(sql.toString());
						while (rs.next()) {
							  String iDocNo = doString.checkString(rs.getString("i_docno"),"");
							  double zPayback = rs.getDouble("z_payback");
							  //sumPayback += zPayback;
					
								//---============= Get Payin List ===============----//
								sql.delete(0,sql.length()); 
								sql.append(" select a.*,b.i_receipt,b.z_recv_reten as z_recv,b.d_payin from lan:serv_rethd a,lan:serv_payin b where ")
									  .append(" b.i_company=a.i_company and b.i_project=a.i_project and b.i_docno=a.i_docno ")
									  .append(" and (b.i_receipt is not null and b.i_receipt <>'999999') and b.i_cashier_conf is not null ")
									  .append(" and a.i_docno='").append(iDocNo).append("' ");
								rs1 = stmt1.executeQuery(sql.toString());
								while (rs1.next()) {
										Calendar payin = Calendar.getInstance(Locale.ENGLISH);
										Timestamp tmp = rs1.getTimestamp("d_payin");
										if (tmp!=null)  {
											payin.setTime(tmp);      
					
											try {
												int startD = Integer.parseInt(str.replace(startDate,"-",""));
												int endD = Integer.parseInt(str.replace(endDate,"-",""));
												int payD = Integer.parseInt(str.createID(payin.get(Calendar.YEAR),4)+str.createID(payin.get(Calendar.MONTH)+1,2)+str.createID(payin.get(Calendar.DATE),2));
					
												if (startD<=payD && payD<=endD) {
													countProj++;
													sumPayback += zPayback;
													if (idocList.length()>0) idocList+= ",";
													idocList += " '"+iDocNo+"' ";
												}
					
											} catch (Exception e) {
											   //sumPayback += 0;
											}
					
										} else {
										   //sumPayback += 0;
										} // end if check temp;
					
								} // end while check payin
								rs1.close(); 
					
						} // end while iDocNo
						rs.close();	
	
	
	
					  //---============= Sum Old z_reten ===============----//
					  double sumOldReten = 0.0;
					  sql.delete(0,sql.length()); 
					  sql.append(" select sum(b.z_recv_reten) sum_reten from lan:serv_rethd a,lan:serv_payin b where ")
							.append(" b.i_company=a.i_company and b.i_project=a.i_project and b.i_docno=a.i_docno ")
							.append(" and (b.i_receipt is not null and b.i_receipt <>'999999') and b.i_cashier_conf is not null ")
							.append(" and a.i_company||':'||a.i_project='").append(proj).append("' ")
							.append(" and b.d_payin<'").append(startDate).append("' ")
						    .append(" and (d_pvno is null or (a.d_pvno>'").append(endDate).append("')) ");							
					  rs = stmt.executeQuery(sql.toString());
					  while (rs.next()) {
						   sumOldReten = rs.getDouble("sum_reten");
					  }
					  rs.close();
	
	
					  //---============= Sum Now z_reten ===============----//
					  double sumNowReten = 0.0;
					  sql.delete(0,sql.length()); 
					  sql.append(" select sum(b.z_recv_reten) sum_reten from lan:serv_rethd a,lan:serv_payin b where ")
							.append(" b.i_company=a.i_company and b.i_project=a.i_project and b.i_docno=a.i_docno ")
							.append(" and (b.i_receipt is not null and b.i_receipt <>'999999') and b.i_cashier_conf is not null ")
							.append(" and a.i_company||':'||a.i_project='").append(proj).append("' ")
							.append(" and b.d_payin>='").append(startDate).append("' ")
							.append(" and b.d_payin<='").append(endDate).append("' ")
						    .append(" and (d_pvno is null or (a.d_pvno>'").append(endDate).append("')) ");							
					  rs = stmt.executeQuery(sql.toString());
					  while (rs.next()) {
						   sumNowReten = rs.getDouble("sum_reten");
					  }
					  rs.close();
	
	
					  totalCountProj += countProj;
					  totalSumPayBack += sumPayback;
					  totalSumOldReten += sumOldReten;
					  totalSumNowReten += sumNowReten;
	
	
						row = sheet.createRow((short) line);
						row.setHeight((short) 300);
										
						cell = row.createCell((short) 0);
						cell.setCellStyle(align_center);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(i+1);
						
						cell = row.createCell((short) 1);
						cell.setCellStyle(align_left);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(doString.MS874ToUnicode(doString.checkString(str.replace(proj,":","-")+" | "+nProject,"")));
						  
						cell = row.createCell((short) 2);
						cell.setCellStyle(align_right);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(countProj);
							
			
						cell = row.createCell((short) 3);
						cell.setCellStyle(align_right);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(sumOldReten);
						
						cell = row.createCell((short) 4);
						cell.setCellStyle(align_right);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(sumNowReten);
						
						cell = row.createCell((short) 5);
						cell.setCellStyle(align_right);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(sumPayback);
						
						cell = row.createCell((short) 6);
						cell.setCellStyle(align_right);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue((sumOldReten+sumNowReten)-sumPayback);
				}
			}
	
	 
		   //---==================== generate Summary =================---//
		   line++;
		   row = sheet.createRow((short) line);
		   row.setHeight((short) 300);
										
		   cell = row.createCell((short) 0);
		   cell.setCellStyle(align_center);
		   cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		   cell.setCellValue("รวม");
		   
		   cell = row.createCell((short) 1);
		   cell.setCellStyle(align_right);
		   cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		   cell.setCellValue("");
		   
		   cell = row.createCell((short) 2);
		   cell.setCellStyle(align_right);
		   cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		   cell.setCellValue("");
			
		   cell = row.createCell((short) 3);
		   cell.setCellStyle(align_right);
		   cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		   cell.setCellValue(totalSumOldReten);
						
		   cell = row.createCell((short) 4);
		   cell.setCellStyle(align_right);
		   cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		   cell.setCellValue(totalSumNowReten);
						
		   cell = row.createCell((short) 5);
		   cell.setCellStyle(align_right);
		   cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		   cell.setCellValue(totalSumPayBack);
						
		   cell = row.createCell((short) 6);
		   cell.setCellStyle(align_right);
		   cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		   cell.setCellValue((totalSumOldReten+totalSumNowReten)-totalSumPayBack);

		   sheet.addMergedRegion(new Region(line,(short) 0,line,(short) 2));
		   line++;
		   
		   
		   row = sheet.createRow((short) line);
		   row.setHeight((short) 300);
										
		   cell = row.createCell((short) 1);
		   cell.setCellStyle(top_border);
		   cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		   cell.setCellValue("");
		   
		   cell = row.createCell((short) 2);
		   cell.setCellStyle(top_border);
		   cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		   cell.setCellValue("");

		   
		   


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
