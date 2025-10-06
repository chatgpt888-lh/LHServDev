package serv.servlets;

import java.io.IOException;
import javax.servlet.Servlet;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.awt.Color;
import com.lowagie.text.*;
import com.lowagie.text.pdf.GrayColor;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import com.lowagie.text.pdf.PdfReader;
import com.lowagie.text.pdf.PdfImportedPage;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfPCell; 
import com.lowagie.text.Document;

import java.io.*;
import java.text.DecimalFormat;
import java.util.*;
import java.sql.*;
import com.lh.servlet.DBServlet;
import com.lh.util.doString;
import serv.common.User;
import serv.common.Constants;
import serv.common.SERV_CommonData;


public class SERV_PrintReport6Servlet extends DBServlet {
	
	private int noLength = 3;
	private int iLockLength = 4;
	private int iModelLength = 6;
	private int dCloseLawLength = 5;
	private int venNameLength = 17;
	private int prevSumContrLength = 7;
	private int prevSumOtherLength = 7;
	private int currSumContrLength = 7;
	private int currSumOtherLength = 7;
	private int totalContrLength = 7;
	private int totalOtherLength = 7;
	private int totalLength = 7;
	private int percentLength = 2;
	private int amountLength = 7;
	private int remainLength = 7;	
	private String allCutType = "";

	public PdfPCell addCellData(String msg,String hAlign,String vAlign,String border,int size,Font font) {
		PdfPCell cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(msg),font));
		
		//----- L = Left Align , C = Center Align ,R = Right Align -----// 
		if (hAlign.trim().length()==1) {
			switch (hAlign.charAt(0)) {
			  case 'L' : cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT); break; 	
			  case 'C' : case 'M' : cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER); break; 	
			  case 'R' : cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT); break; 	
			}
		}
		
		//----- T = Top Align , C or M = Middle Align , B = Bottom Align -----//				
		if (vAlign.trim().length()==1) {
			switch (hAlign.charAt(0)) {
			  case 'T' : cell.setVerticalAlignment(Rectangle.ALIGN_TOP); break; 	
			  case 'C' : case 'M' : cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE); break; 	
			  case 'B' : cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM); break; 	
			}
		}	
		
		int borderId = 0; 
		//----- T = Top Border , B = Bottom Border , L = Left Border , R = Right Border ----//
		if (border.trim().length()>0) {
			if (border.indexOf("T")>=0) borderId += 1; 
			if (border.indexOf("B")>=0) borderId += 2; 
			if (border.indexOf("L")>=0) borderId += 4; 
			if (border.indexOf("R")>=0) borderId += 8; 
		}
		cell.setBorder(borderId);
		cell.setColspan(size);
		cell.setPaddingBottom(3);
		cell.setPaddingBottom(5);
		cell.setBorderColor(new Color(153,153,153));
				
		return cell;
	}
	

	public void printHeader(PdfPTable table,int nowpage,String projName,String monthName,String currDate,Font font,Font bold,Font hd) {
		table.addCell(addCellData("หน้า "+nowpage,"R","M","",100,font));
		table.addCell(addCellData(doString.MS874ToUnicode("\n รายงานสรุปค่าซ่อมสะสมทั้งโครงการ \n"),"C","M","",100,hd));
		table.addCell(addCellData(doString.MS874ToUnicode("โครงการ : "+projName),"L","M","",50,font));
		table.addCell(addCellData("แบบรายงาน : SERV_PrintReport6 ,  "+currDate,"R","M","",50,font));
		table.addCell(addCellData("","C","M","",100,font));
	
		table.addCell(addCellData("No.","C","B","LRT",noLength,bold));
		table.addCell(addCellData("แปลง","C","B","LRT",iLockLength,bold));
		table.addCell(addCellData("แบบบ้าน","C","B","LRT",iModelLength,bold));
		table.addCell(addCellData("วันที่หมด","C","B","LRT",dCloseLawLength,bold));
		table.addCell(addCellData("ผู้รับเหมาสร้าง","C","B","LRT",venNameLength,bold));
		table.addCell(addCellData("สะสมก่อนเดือน "+monthName,"C","M","LRTB",prevSumContrLength+prevSumOtherLength,bold));
		table.addCell(addCellData("เดือนที่เบิก "+monthName,"C","M","LRTB",currSumContrLength+currSumOtherLength,bold));
		table.addCell(addCellData("สะสมทั้งหมด","C","M","LRTB",totalContrLength+totalOtherLength+totalLength,bold));
		table.addCell(addCellData("รูปแบบการตัดเงิน","C","M","LRTB",percentLength+amountLength,bold));
		table.addCell(addCellData("คงเหลือ","C","M","LRT",remainLength,bold));
		
		table.addCell(addCellData("","C","M","LRB",noLength,bold));
		table.addCell(addCellData("","C","M","LRB",iLockLength,bold));
		table.addCell(addCellData("","C","M","LRB",iModelLength,bold));
		table.addCell(addCellData("ประกัน","C","T","LRB",dCloseLawLength,bold));
		table.addCell(addCellData("","C","M","LRB",venNameLength,bold));		
		table.addCell(addCellData("ตามสัญญา","C","M","LRTB",prevSumContrLength,bold));
		table.addCell(addCellData("อื่นๆ","C","M","LRTB",prevSumOtherLength,bold));
		table.addCell(addCellData("ตามสัญญา","C","M","LRTB",currSumContrLength,bold));
		table.addCell(addCellData("อื่นๆ","C","M","LRTB",currSumOtherLength,bold));
		table.addCell(addCellData("ตามสัญญา","C","M","LRTB",totalContrLength,bold));
		table.addCell(addCellData("อื่นๆ","C","M","LRTB",totalOtherLength,bold));
		table.addCell(addCellData("รวม","C","M","LRTB",totalLength,bold));
		table.addCell(addCellData("%","C","M","LRTB",percentLength,bold));
		table.addCell(addCellData("บาท","C","M","LRTB",amountLength,bold));
		table.addCell(addCellData("","C","M","LRB",remainLength,bold));

	}


	public void genReportData(SERV_CommonData common,Statement stmt,Statement stmt1,Document document,HttpServletRequest req) throws Exception {
		doString str = new doString();
		DecimalFormat format = new DecimalFormat("#,###,##0.00");
		Calendar now = Calendar.getInstance(Locale.ENGLISH);
		ResultSet rs = null;
		ResultSet rs1 = null;
		StringBuffer sql = new StringBuffer();


		//----================== Init data before generate report  ====================----//
		String selProj = doString.checkString(req.getParameter("sel_project"),"").toUpperCase(); 
		String iCompany = (selProj.length()==6 ? selProj.substring(0,2) : "");
		String iProject = (selProj.length()==6 ? selProj.substring(3,6) : "");
		int nowpage = 1;

		String showMonth[] = new String[] {"","ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค."};
		String selMonth = doString.checkString(req.getParameter("sel_month"),"");			
		String selYear = doString.checkString(req.getParameter("sel_year"),"");

		String startDate = common.getValueFromDateListbox("start",req);
		String endDate = common.getValueFromDateListbox("end",req);
		String t_typ = doString.checkString(req.getParameter("t_typ"),"B");		
		
		String monthName = "";
		if (selMonth.length()>0 && selYear.length()>0) {
			 try {
				 int month = Integer.parseInt(selMonth);
				 int year = Integer.parseInt(selYear);
				 if (year<2400) year += 543;
				 monthName = showMonth[month]+" "+Integer.toString(year).substring(2,4);
			 } catch (Exception ex) {
				 monthName = "";
			 }
		}		   	
		
		String projName = "";
		 sql.delete(0,sql.length());
		 sql.append(" select * from lan:acxprojt a where  a.i_company='"+iCompany+"' and a.i_project='"+iProject+"' ");			
		 rs = stmt.executeQuery(sql.toString());
		 if (rs.next()) {
			 projName = doString.checkString(rs.getString("n_project"),"");
		 }
		 rs.close();		
		
		
		 String currDate = str.createID(now.get(Calendar.DATE),2)+"/"+str.createID(now.get(Calendar.MONTH)+1,2);
		 int nYear = now.get(Calendar.YEAR);
		 if (nYear<2500) nYear += 543;
		 currDate += "/"+str.createID(nYear,4);
		 currDate += " , "+str.createID(now.get(Calendar.HOUR_OF_DAY),2)+":"+str.createID(now.get(Calendar.MINUTE),2);					
	   //---===============================================================----//

		

		//----====================== Init PDF Variables ========================----//
		BaseFont bf = BaseFont.createFont(Constants.FONT_ANGSANA_NORMAL, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
		BaseFont bfb = BaseFont.createFont(Constants.FONT_ANGSANA_BOLD, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
		Font microssfont = new Font(bf, 12, Font.NORMAL);
		Font microssfont_BOLD = new Font(bfb, 12, Font.NORMAL);
		Font microssfont_HD = new Font(bfb, 18, Font.NORMAL);
					
		PdfPTable table = new PdfPTable(100);
		table.setWidthPercentage(100);
		PdfPCell cell;			


		//-----==================== start print data ======================------//
		int line = 1;
		int checkMonth = 0;
		int checkYear = 0;
		try {
			 checkMonth = Integer.parseInt(selMonth);
			 checkYear = Integer.parseInt(selYear);
			 if (checkYear>2400) checkYear -= 543;
		 } catch (Exception ex) {}


		sql.delete(0,sql.length());
		sql.append(" select b.i_lor,b.i_model,b.i_house, c.d_close_law,e.ven_name,a.* from lan:serv_cutlck a ")
			  .append(" left join lan:acxlckmd b on b.i_company=a.i_company and b.i_project=a.i_project and b.i_lock=a.i_lock ")
			  .append(" left join lan:acscontr c on c.i_company=a.i_company and c.i_project=a.i_project and c.i_sort=a.i_lock and c.f_contr is null ")
			  .append(" left join lan:unit d on d.i_company=a.i_company and d.i_project=a.i_project and d.i_lock=a.i_lock and d.unit_status='OPN' ")
			  .append(" left join lan:vendor e on e.ven_no=d.ven_no where 1=1 ");
		if (!selProj.equalsIgnoreCase("ALL")) {
			  sql.append(" and a.i_company='").append(iCompany).append("' ")
					.append(" and a.i_project='").append(iProject).append("' ");
		}
		if (t_typ.equals("A")) {
			  sql.append(" and c.d_close_law between '"+startDate+"' and '"+endDate+"' ");
		}		
		rs = stmt.executeQuery(sql.toString());

	  while (rs.next()) {

			//------ Data is in this page , display -----//
			String iCom = doString.checkString(rs.getString("i_company"),""); 
			String iProj = doString.checkString(rs.getString("i_project"),""); 
			String iLock = doString.checkString(rs.getString("i_lock"),"");
			String iModel = doString.checkString(rs.getString("i_model"),"");
			String venName = doString.checkString(rs.getString("ven_name"),"");
			String iCutType = doString.checkString(rs.getString("i_cut_type"),"");
			double zCutAmount = rs.getDouble("z_amount");
			double prevSumContr = 0.0;
			double prevSumOther = 0.0;
			double currSumContr = 0.0;
			double currSumOther = 0.0;
		            
		            
			//-------- d_close_law Date --------// 
			String dCloseLaw = "";
			Timestamp tmp = rs.getTimestamp("d_close_law");
			if (tmp!=null)  {
				Calendar cal = Calendar.getInstance();
				cal.setTime(tmp);      
				cal.add(Calendar.YEAR,1);
				
				int year = cal.get(Calendar.YEAR);
				if (year<2400) year+= 543;
				dCloseLaw = str.createID(cal.get(Calendar.DATE),2);
				dCloseLaw += "/"+str.createID(cal.get(Calendar.MONTH)+1,2);
				dCloseLaw += "/"+year;					
			}


			//-------------- get old commulative money ---------//
			sql.delete(0,sql.length());
			sql.append(" select * from lan:serv_sumcut a ")
				  .append(" where a.i_company='").append(iCom).append("' ")
				  .append(" and a.i_project='").append(iProj).append("' ")
				  .append(" and a.i_lock='").append(iLock).append("' ");
			rs1 = stmt1.executeQuery(sql.toString());
			while (rs1.next()) {
					prevSumContr += rs1.getDouble("z_sumcut_con");
					prevSumOther += rs1.getDouble("z_sumcut_oth");									
			}
			rs1.close();


			//-------------- get summary money ---------//
			sql.delete(0,sql.length());
			sql.append(" select b.i_ven_cut,month(b.d_payment) as pay_month,year(b.d_payment) as pay_year , ")
				  .append(" b.f_contr,sum(b.z_amount_pv) as sum_pv from lan:serv_dochd a, lan:serv_payment b ")
				  .append(" where b.f_itmstatus='CLS' and b.i_docno=a.i_docno ")
				  .append(" and a.i_company='").append(iCom).append("' ")
				  .append(" and a.i_project='").append(iProj).append("' ")
				  .append(" and a.i_lock='").append(iLock).append("' ");
			if (t_typ.equals("A")) {
				  sql.append(" and a.d_close_law between '"+startDate+"' and '"+endDate+"' ");
			}				  
			sql.append(" group by b.i_ven_cut,b.d_payment,b.f_contr ");				  
			rs1 = stmt1.executeQuery(sql.toString());
			while (rs1.next()) {
					String fContr = doString.checkString(rs1.getString("f_contr"),"");
				    String iVenCut = doString.checkString(rs1.getString("i_ven_cut"),"");
					int payMonth = rs1.getInt("pay_month");
					int payYear = rs1.getInt("pay_year");
					double sumPv = rs1.getDouble("sum_pv");
					if (payYear>2400) payYear -= 543;


					if (payYear==checkYear && payMonth==checkMonth) {
						
						/* old original  if ((iCutType.equals("1") || iCutType.equals("2") || iCutType.equals("3")) && (iVenCut.equalsIgnoreCase("999999"))) {
							if (fContr.equalsIgnoreCase("Y")) {
								currSumContr += sumPv;
							} else {
								currSumOther += sumPv;
							}
						} else {
							currSumOther += sumPv;
						}*/
						
						//add by pradoem 2025-06-23
						if (fContr.equalsIgnoreCase("Y") && (iVenCut.equalsIgnoreCase("999999"))) {
							currSumContr += sumPv;
						} else {
							currSumOther += sumPv;
						}
						
						
						/*
						if (fContr.equalsIgnoreCase("N")) {
							currSumOther += sumPv;
						} else {
							currSumContr += sumPv;
						}
						*/
					} else if ((payYear<checkYear) || ((payYear==checkYear) && payMonth<checkMonth)) {
						if (payYear>2007 || (payYear==2007 && payMonth>10)) {
							
							/*if ((iCutType.equals("1") || iCutType.equals("2") || iCutType.equals("3")) && (iVenCut.equalsIgnoreCase("999999"))) {
								if (fContr.equalsIgnoreCase("Y")) {
									prevSumContr += sumPv;
								} else {
									prevSumOther += sumPv;
								}
							} else {
								prevSumOther += sumPv;
							}*/	
							
							//add by pradoem 2025-06-23
							if (fContr.equalsIgnoreCase("Y") && (iVenCut.equalsIgnoreCase("999999"))) {
								currSumContr += sumPv;
							} else {
								currSumOther += sumPv;
							}
							
							
							/*
							if (fContr.equalsIgnoreCase("N")) {
								prevSumOther += sumPv;
							} else {
								prevSumContr += sumPv;
							}
							*/
						}						
					} else {
						continue;
					}

			}
			rs1.close();
			
			
			//-------------- if data have more than 10 line , start new page -------------------//	
			if ((line%20)==1) {
				if (line>1) {
					table.addCell(addCellData(allCutType,"L","M","",100,microssfont));			
					document.add(table);
					document.newPage();
					nowpage++;	
					
					table = new PdfPTable(100);
					table.setWidthPercentage(100);						
				}
				
				printHeader(table,nowpage,projName,monthName,currDate,microssfont,microssfont_BOLD,microssfont_HD);				
			}


			if (venName.trim().length()>32) {
				venName = venName.substring(0,32)+"...";
			}

			//-------------- print data --------------------//
			table.addCell(addCellData(line+" ","R","M","LRTB",noLength,microssfont));
			table.addCell(addCellData(iLock,"C","M","LRTB",iLockLength,microssfont));
			table.addCell(addCellData(iModel,"C","M","LRTB",iModelLength,microssfont));
			table.addCell(addCellData(dCloseLaw,"C","M","LRTB",dCloseLawLength,microssfont));
			table.addCell(addCellData(venName,"L","M","LRTB",venNameLength,microssfont));		
			table.addCell(addCellData(format.format(prevSumContr),"R","M","LRTB",prevSumContrLength,microssfont));
			table.addCell(addCellData(format.format(prevSumOther),"R","M","LRTB",prevSumOtherLength,microssfont));
			table.addCell(addCellData(format.format(currSumContr),"R","M","LRTB",currSumContrLength,microssfont));
			table.addCell(addCellData(format.format(currSumOther),"R","M","LRTB",currSumOtherLength,microssfont));
			table.addCell(addCellData(format.format(currSumContr+prevSumContr),"R","M","LRTB",totalContrLength,microssfont));
			table.addCell(addCellData(format.format(currSumOther+prevSumOther),"R","M","LRTB",totalOtherLength,microssfont));
			table.addCell(addCellData(format.format(currSumContr+prevSumContr+currSumOther+prevSumOther),"R","M","LRTB",totalLength,microssfont));
			table.addCell(addCellData(iCutType,"C","M","LRTB",percentLength,microssfont));
			table.addCell(addCellData(format.format(zCutAmount),"R","M","LRTB",amountLength,microssfont));
			//table.addCell(addCellData(format.format(zCutAmount-(currSumContr+prevSumContr+currSumOther+prevSumOther)),"R","M","LRTB",remainLength,microssfont));							
			table.addCell(addCellData(format.format(zCutAmount-(currSumContr+prevSumContr)),"R","M","LRTB",remainLength,microssfont));
								        
			 line++;                                              
	  } //end while


		
		
		//----============= print total data ================----//
		//-------------- get total money ---------//
		double prevTotalContr = 0.0;
		double prevTotalOther = 0.0;
		double currTotalContr = 0.0;
		double currTotalOther = 0.0;
		double cutTotal = 0.0;

		//-------------- get old commulative money ---------//
		sql.delete(0,sql.length());
		sql.append(" select sum(z_sumcut_con) as sum_con,sum(z_sumcut_oth) as sum_oth from lan:serv_sumcut a ");
		if (!selProj.equalsIgnoreCase("ALL")) {
			  sql.append(" where a.i_company='").append(iCompany).append("' ")
					.append(" and a.i_project='").append(iProject).append("' ");
		}
		rs1 = stmt1.executeQuery(sql.toString());
		while (rs1.next()) {
				prevTotalContr += rs1.getDouble("sum_con");
				prevTotalOther += rs1.getDouble("sum_oth");									
		}
		rs1.close();
/*
		//-------------- get total money ---------//
		sql.delete(0,sql.length());
		sql.append(" select b.i_ven_cut,a.i_type_cutlck,month(b.d_payment) as pay_month,year(b.d_payment) as pay_year , ")
			  .append(" b.f_contr,sum(b.z_amount_pv) as sum_pv from lan:serv_dochd a, lan:serv_payment b ")
			  .append(" where b.f_itmstatus='CLS' and b.i_docno=a.i_docno ");
		if (!selProj.equalsIgnoreCase("ALL")) {
			  sql.append(" and a.i_company='").append(iCompany).append("' ")
					.append(" and a.i_project='").append(iProject).append("' ");
		}
		if (t_typ.equals("A")) {
			  sql.append(" and a.d_close_law between '"+startDate+"' and '"+endDate+"' ");
		}		
		sql .append(" group by b.i_ven_cut,a.i_type_cutlck,b.d_payment,b.f_contr ");
*/
		//-------------- get total money ---------//
		currTotalContr = 0;
		currTotalOther = 0;
		prevTotalContr = 0;
		cutTotal = 0;
		
		sql.delete(0,sql.length());
		sql.append(" select b.i_ven_cut,a.i_type_cutlck,month(b.d_payment) as pay_month,year(b.d_payment) as pay_year , ")
			  .append(" b.f_contr,sum(b.z_amount_pv) as sum_pv from lan:serv_dochd a, lan:serv_payment b ")
			  .append(" where b.f_itmstatus='CLS' and b.i_docno=a.i_docno ");
		if (!selProj.equalsIgnoreCase("ALL")) {
			  sql.append(" and a.i_company='").append(iCompany).append("' ")
					.append(" and a.i_project='").append(iProject).append("' ");    
		}
		if (t_typ.equals("A")) {
					  sql.append(" and a.d_close_law between '"+startDate+"' and '"+endDate+"' ");
		}
		sql .append(" group by b.i_ven_cut,a.i_type_cutlck,b.d_payment,b.f_contr ");

		rs1 = stmt1.executeQuery(sql.toString());
		while (rs1.next()) {
			   String iCutType = doString.checkString(rs1.getString("i_type_cutlck"),"");
			   String iVenCut = doString.checkString(rs1.getString("i_ven_cut"),"");
				String fContr = doString.checkString(rs1.getString("f_contr"),"");
				int payMonth = rs1.getInt("pay_month");
				int payYear = rs1.getInt("pay_year");
				double sumPv = rs1.getDouble("sum_pv");
				if (payYear>2400) payYear -= 543;


				if (payYear==checkYear && payMonth==checkMonth) {
					/*if ((iCutType.equals("1") || iCutType.equals("2") || iCutType.equals("3")) && (iVenCut.equalsIgnoreCase("999999"))) {
						if (fContr.equalsIgnoreCase("Y")) {
							currTotalContr += sumPv;
						} else {
							currTotalOther += sumPv;
						}
					} else {
						currTotalOther += sumPv;
					}*/
					
					//add by pradoem 2025-06-23
					if (fContr.equalsIgnoreCase("Y") && (iVenCut.equalsIgnoreCase("999999"))) {
						currTotalContr += sumPv;
					} else {
						currTotalOther += sumPv;
					}
					
					
					
					/*
					if (fContr.equalsIgnoreCase("N")) {
						currTotalOther += sumPv;
					} else {
						currTotalContr += sumPv;
					}
					*/
				} else if ((payYear<checkYear) || ((payYear==checkYear) && payMonth<checkMonth)) {
					if (payYear>2007 || (payYear==2007 && payMonth>10)) {
						/*if ((iCutType.equals("1") || iCutType.equals("2") || iCutType.equals("3")) && (iVenCut.equalsIgnoreCase("999999"))) {
							if (fContr.equalsIgnoreCase("Y")) {
								prevTotalContr += sumPv;
							} else {
								prevTotalOther += sumPv;
							}
						} else {
							prevTotalOther += sumPv;
						}*/
						
						//add by pradoem 2025-06-23
						if (fContr.equalsIgnoreCase("Y") && (iVenCut.equalsIgnoreCase("999999"))) {
							currTotalContr += sumPv;
						} else {
							currTotalOther += sumPv;
						}
						
						
						/*
						if (fContr.equalsIgnoreCase("N")) {
							prevTotalOther += sumPv;
						} else {
							prevTotalContr += sumPv;
						}
						*/
					}					
				} else {
					continue;
				}

		}
		rs1.close();				
		
		
		//------------- find cut total ---------//
		sql.delete(0,sql.length());
		sql.append(" select  sum(z_amount) as sum_cut from lan:serv_cutlck a ")
			  .append(" left join lan:acscontr c on c.i_company=a.i_company and c.i_project=a.i_project and c.i_sort=a.i_lock and c.f_contr is null ")
			  .append(" where 1=1 ");
		if (!selProj.equalsIgnoreCase("ALL")) {
			  sql.append(" and a.i_company='").append(iCompany).append("' ")
					.append(" and a.i_project='").append(iProject).append("' ");    
		}
		if (t_typ.equals("A")) {
					  sql.append(" and c.d_close_law between '"+startDate+"' and '"+endDate+"' ");
		}

		rs1 = stmt1.executeQuery(sql.toString());
		if (rs1.next()) {
			cutTotal = rs1.getDouble("sum_cut");
		} // if 
		rs1.close();		
				
		table.addCell(addCellData(" รวม ","C","M","LRTB",noLength+iLockLength+iModelLength+dCloseLawLength+venNameLength,microssfont));		
		table.addCell(addCellData(format.format(prevTotalContr),"R","M","LRTB",prevSumContrLength,microssfont));
		table.addCell(addCellData(format.format(prevTotalOther),"R","M","LRTB",prevSumOtherLength,microssfont));
		table.addCell(addCellData(format.format(currTotalContr),"R","M","LRTB",currSumContrLength,microssfont));
		table.addCell(addCellData(format.format(currTotalOther),"R","M","LRTB",currSumOtherLength,microssfont));
		table.addCell(addCellData(format.format(currTotalContr+prevTotalContr),"R","M","LRTB",totalContrLength,microssfont));
		table.addCell(addCellData(format.format(currTotalOther+prevTotalOther),"R","M","LRTB",totalOtherLength,microssfont));
		table.addCell(addCellData(format.format(currTotalContr+prevTotalContr+currTotalOther+prevTotalOther),"R","M","LRTB",totalLength,microssfont));
		table.addCell(addCellData("","R","M","LRTB",percentLength,microssfont));
		table.addCell(addCellData(format.format(cutTotal),"R","M","LRTB",amountLength,microssfont));
		table.addCell(addCellData(format.format(cutTotal-(currTotalContr+prevTotalContr)),"R","M","LRTB",remainLength,microssfont));
		table.addCell(addCellData(allCutType,"L","M","",100,microssfont));			
		document.add(table);
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
		DecimalFormat format = new DecimalFormat("#,##0.00");

		StringBuffer sql = new StringBuffer();
		Connection conn = null;
		Statement stmt = null;
		Statement stmt1 = null;
		ResultSet rs = null;
		ResultSet rs1 = null;
		SERV_CommonData common = null;
		allCutType = "";

		try {
			if (ds == null)
				getDS();

			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();	
			stmt1 = conn.createStatement();	
			common = new SERV_CommonData(conn);		

			//----================= find all cut type list ==================---//
			rs = stmt.executeQuery(" select * from lan:serv_xstd where i_type='03' ");
			while (rs.next()) {
				if (allCutType.length()>0) allCutType += " , ";
			   allCutType += doString.checkString(rs.getString("i_code"),"");
			   allCutType += " = "+doString.checkString(rs.getString("n_desc"),"");
			}
			rs.close();
			
			
			//----================ Initialize Variables for create PDF =====================---//
			Document document = new Document(PageSize.A4.rotate(), 20, 20, 10, 10);
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			PdfWriter writer = PdfWriter.getInstance(document, baos);
			PdfContentByte cb = writer.getDirectContent();
			document.open();

		   


		   genReportData(common,stmt,stmt1,document,req);
			

			//----=========== Generate PDF ===============-----//
			//document.add(table);
			document.close();
			res.setContentType("application/pdf");
			res.setContentLength(baos.size());
			ServletOutputStream outServ = res.getOutputStream();
			baos.writeTo(outServ);
			outServ.flush();
			
			conn.commit();
			stmt.close();
			conn.close();
			conn = null;
		 } catch (DocumentException de) {
			 de.printStackTrace();
			 System.err.println("error SERV_PrintRerort6Servlet  DOCUMENT: " + de.getMessage());
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
