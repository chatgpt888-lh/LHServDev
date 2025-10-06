package serv.servlets;

import java.io.*;
import java.text.DecimalFormat;
import java.util.*;
import java.sql.*;
 
import javax.servlet.*;
import javax.servlet.http.*;

import com.lh.servlet.DBServlet;
import com.lh.util.*;
import com.lh.exception.InvalidParameterException;

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

import serv.common.User;
import serv.common.Constants;
import serv.common.SERV_CommonData;


/**
 * @version 	1.0
 * @author
 */
public class SERV_INFPrintReport9Servlet extends DBServlet  {
	
	private String selProj = "";
	private String iVendor = "";
	private String startDate = "";
	private String endDate = "";
	private String condition = "";	
	private String companyName = "";
	private String betweenDate = ""; 
	//private double markupPay = 0.0;
	private int nowpage = 0;
	private int rowPerPage = 33;
	/*
	private Document document = null;
	private Font microssfont = null;
	private Font microssfont_MINI = null;
	private Font microssfont_BOLD = null;
	private Font microssfont_BOLD_UNDERLINE = null;
	private Font microssfont_HD = null;
	*/
	private int LIGHT_GRAY_COLOR = 15329769;
	private int DARK_GRAY_COLOR = 13882323;
	private Color  borderColor = new Color(153,153,153);	
	

	public void genHeaderPage(PdfPTable table,String headerReport,String currDate,Font microssfont,Font microssfont_HD,Font microssfont_MINI) throws Exception {
			
			nowpage++;
			PdfPCell cell = new PdfPCell(new Phrase("หน้า "+nowpage,microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setColspan(100);
			cell.setBorder(0);
			table.addCell(cell);
					
			cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(companyName+"\n รายละเอียดการส่งงานของผู้รับเหมา (รายละเอียด)   "+betweenDate), microssfont_HD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setColspan(100);
			cell.setBorder(0);
			table.addCell(cell);
			cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(headerReport), microssfont_HD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setColspan(50);
			cell.setBorder(0);
			table.addCell(cell);			
			cell = new PdfPCell(new Phrase("แบบรายงาน : SERV_INFPrintReport9 ,  "+currDate, microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
			cell.setColspan(50);
			cell.setBorder(0);
			table.addCell(cell);				
			cell = new PdfPCell(new Phrase(" ", microssfont_MINI));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setColspan(100);
			cell.setBorder(2);
			table.addCell(cell);	
	
	}
	
	
	public void genVendorData(PdfWriter writer,Connection conn,String iVendor,String headerReport,boolean moreVendor,String markupPay,Document document) throws Exception {
		String currDate = "";
		Calendar now = Calendar.getInstance(Locale.ENGLISH);
		doString str = new doString();
		Statement stmt = null;
		Statement stmt1 = null;
		ResultSet rs = null;
		ResultSet rs1 = null;
		StringBuffer sql = new StringBuffer();
		PdfPTable table = new PdfPTable(100);
		table.setWidthPercentage(100);		
		DecimalFormat format = new DecimalFormat("###,##0.00");
		
		
		//------- init font --------//
		BaseFont bf = BaseFont.createFont(Constants.FONT_ANGSANA_NORMAL, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
		BaseFont bfb = BaseFont.createFont(Constants.FONT_ANGSANA_BOLD, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
		Font microssfont = new Font(bf, 12, Font.NORMAL);
		Font microssfont_MINI = new Font(bf, 10, Font.NORMAL);
		Font microssfont_BOLD = new Font(bfb, 12, Font.NORMAL);
		Font microssfont_BOLD_UNDERLINE = new Font(bfb, 12, Font.UNDERLINE);
		Font microssfont_HD = new Font(bfb, 18, Font.NORMAL);	
					
		
		//--- init column scale ----//
		int itemLength = 54;
		int zwLength = 4;
		int qwLength = 6;
		int swLength = 6;
		int zgLength = 4;
		int qgLength = 6;
		int sgLength = 6;
		int stLength = 6;
		int scLength = 8; 
		
		int totalLine = 0;
		
				
		try {
			stmt = conn.createStatement();
			stmt1 = conn.createStatement();
			
			currDate = str.createID(now.get(Calendar.DATE),2)+"/"+str.createID(now.get(Calendar.MONTH)+1,2);
			int nYear = now.get(Calendar.YEAR);
			if (nYear<2500) nYear += 543;
			currDate += "/"+str.createID(nYear,4);
			currDate += " , "+str.createID(now.get(Calendar.HOUR_OF_DAY),2)+":"+str.createID(now.get(Calendar.MINUTE),2);		
		
			String vendorName = "";
			sql.delete(0,sql.length());
			sql.append(" select vend_code,bus_name from lan:stpvendr ")
				  .append(" where vend_code='").append(iVendor).append("' order by  vend_code ");
			rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
				vendorName = doString.checkString(rs.getString("bus_name"),"");
			}
			rs.close();	
			
		
			//---====== Start PDF Header =======----//
			genHeaderPage(table,headerReport,currDate,microssfont,microssfont_HD,microssfont_MINI);	
			totalLine += 6;

				
			PdfPCell cell = new PdfPCell(new Phrase("ผู้รับเหมาซ่อม "+iVendor+" - "+doString.MS874ToUnicode(vendorName)+"\n", microssfont_HD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setColspan(100);
			cell.setBorder(0);
			table.addCell(cell);	
			totalLine += 3;	

			
			//---============= Count iDocNo in this vendor ===============---//
			int countDoc = 0;
			sql.delete(0,sql.length());
			sql.append(" select count(*) from lan:serv_infpayment b,lan:serv_infdochd a where ")
				  .append(" a.f_status in ('OPN','CLS') and b.i_docno=a.i_docno ")
				  .append(" and b.f_itmstatus='CLS' ");
			if (iVendor.length()>0) { sql.append(" and b.i_vendor='").append(iVendor).append("' "); }
			if (selProj.length()>0 && !selProj.equals("ALL")) { 
				sql.append(" and a.i_company='"+(selProj.length()>=6 ? selProj.substring(0,2) : "")+"' and a.i_project='"+(selProj.length()>=6 ? selProj.substring(3,6) : "")+"' "); 
			}			
			sql.append(condition);
			sql.append(" group by a.i_docno ");
			rs = stmt.executeQuery(sql.toString());
			while (rs.next()) {
				countDoc++;
			}
			rs.close();
	

			//----============================= Get Data ================================----//
			sql.delete(0,sql.length());
			sql.append("SELECT a.i_docno, c.n_project ")
				  .append(" FROM lan:serv_infpayment b,lan:serv_infdochd a ")
				  .append(" LEFT JOIN acxprojt c ON c.i_company = a.i_company ")
				  .append(" AND c.i_project = a.i_project WHERE ")
				  .append(" a.f_status IN ('OPN','CLS') AND b.i_docno = a.i_docno ")
				  .append(" AND b.f_itmstatus = 'CLS' ");
			if (iVendor.length()>0) { sql.append(" AND b.i_vendor = '").append(iVendor).append("' "); }
			if (selProj.length()>0 && !selProj.equals("ALL")) { 
				sql.append(" AND a.i_company = '"+(selProj.length()>=6 ? selProj.substring(0,2) : "")+"' AND a.i_project = '"+(selProj.length()>=6 ? selProj.substring(3,6) : "")+"' "); 
			}			
			sql.append(condition);
				sql.append(" GROUP BY a.i_docno, c.n_project ")
					  .append(" ORDER BY a.i_docno");	
			rs = stmt.executeQuery(sql.toString());
			int countRec = 0;
			while (rs.next()) {
				//------ Data is in this page , display -----//
				countRec++;
				String iDocNo = doString.checkString(rs.getString("i_docno"),"");
				String nProject = doString.checkString(rs.getString("n_project"),"");
				if (totalLine>=rowPerPage) {
					
					if (countRec<countDoc) {
						Rectangle page = document.getPageSize();
						PdfPTable foot = new PdfPTable(1);
						PdfPCell pcell = new PdfPCell(new Phrase(" มีหน้าต่อไป      ", microssfont));
						pcell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
						pcell.setVerticalAlignment(Rectangle.ALIGN_TOP);
						pcell.setBorder(0);
						foot.addCell(pcell);				
						foot.setTotalWidth(page.width() - document.leftMargin() - document.rightMargin());
						foot.writeSelectedRows(0, 1, document.leftMargin(), document.bottomMargin()+20,writer.getDirectContent());						  	
					}  	

				   //---- add New Table -------//
				   document.add(table);		
				   document.newPage();
				   table = new PdfPTable(100);
				   table.setWidthPercentage(100);		
				   totalLine = 0;
						
				   genHeaderPage(table,headerReport,currDate,microssfont,microssfont_HD,microssfont_MINI);	
				   totalLine += 6;		

				}								
								
								
								
				//--=========================== Table Header =============================---//	
				String tableDesc = " เลขที่ใบสั่งซ่อม "+iDocNo;
				cell = new PdfPCell(new Phrase("\n", microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
				cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
				cell.setColspan(100);
				cell.setBorder(0);
				table.addCell(cell);		
				cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(tableDesc+"\n\n"), microssfont_BOLD));
				cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
				cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
				cell.setColspan(100);
				cell.setBorder(0);
				table.addCell(cell);
				totalLine += 2;
				

				cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("รายการซ่อม"), microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
				cell.setColspan(itemLength);
				cell.setBorderColor(borderColor);
				cell.setBorder(13);
				table.addCell(cell);				
				cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("ค่าแรง"), microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
				cell.setColspan(zwLength+qwLength+swLength);
				cell.setBorderColor(borderColor);
				cell.setPaddingBottom(5);				
				cell.setBorder(13);
				table.addCell(cell);		
				cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("ค่าของ"), microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
				cell.setColspan(zgLength+qgLength+sgLength);
				cell.setBorderColor(borderColor);
				cell.setPaddingBottom(5);
				cell.setBorder(13);
				table.addCell(cell);											
				cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("ค่าแรง"), microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
				cell.setColspan(stLength);
				cell.setBorderColor(borderColor);
				cell.setBorder(13);
				table.addCell(cell);		
				cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("รวมค่าดำเนิน"), microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
				cell.setColspan(scLength);
				cell.setBorderColor(borderColor);
				cell.setBorder(13);
				table.addCell(cell);		
				
				
				cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(""), microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
				cell.setColspan(itemLength);
				cell.setBorderColor(borderColor);
				cell.setPaddingBottom(5);
				cell.setBorder(14);
				table.addCell(cell);	
				cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("จำนวน"), microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
				cell.setColspan(zwLength);
				cell.setBorderColor(borderColor);
				cell.setPaddingBottom(5);
				cell.setBorder(15);
				table.addCell(cell);	
				cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("ต่อหน่วย"), microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
				cell.setColspan(qwLength);
				cell.setBorderColor(borderColor);
				cell.setPaddingBottom(5);
				cell.setBorder(15);
				table.addCell(cell);	
				cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("รวม"), microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
				cell.setColspan(swLength);
				cell.setBorderColor(borderColor);
				cell.setPaddingBottom(5);
				cell.setBorder(15);
				table.addCell(cell);				
				cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("จำนวน"), microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
				cell.setColspan(zgLength);
				cell.setBorderColor(borderColor);
				cell.setPaddingBottom(5);
				cell.setBorder(15);
				table.addCell(cell);	
				cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("ต่อหน่วย"), microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
				cell.setColspan(qgLength);
				cell.setBorderColor(borderColor);
				cell.setPaddingBottom(5);
				cell.setBorder(15);
				table.addCell(cell);	
				cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("รวม"), microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
				cell.setColspan(sgLength);
				cell.setBorderColor(borderColor);
				cell.setPaddingBottom(5);
				cell.setBorder(15);
				table.addCell(cell);	
				cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("+ค่าของ"), microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
				cell.setColspan(stLength);
				cell.setBorderColor(borderColor);
				cell.setPaddingBottom(5);
				cell.setBorder(14);
				table.addCell(cell);	
				cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("การ "+markupPay), microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
				cell.setColspan(scLength);
				cell.setBorderColor(borderColor);
				cell.setPaddingBottom(5);
				cell.setBorder(14);
				table.addCell(cell);
				totalLine += 2;	
				//--=======================================================================---//				





				//--============================= Table Data ===============================---//	
				int itmLine = 0;
				double sumSumWage = 0.00;
				double sumSumGoods = 0.00;
				double sumSumTotal = 0.00;
				double sumCutVendor = 0.00;
				double sumCutOnly = 0.00;


				Vector vendorItem = new Vector();
				sql.delete(0,sql.length());
				sql.append("SELECT d.bus_name, c.n_itmjob, b.* FROM lan:serv_infpayment b ")
					  .append(" LEFT JOIN lan:serv_infboq c ON c.i_itmjob = b.i_itmjob ")
					  .append(" LEFT JOIN lan:stpvendr d on d.vend_code = b.i_ven_cut ")
					  .append(" WHERE b.i_docno='").append(iDocNo).append("' ");
				if (iVendor.length()>0) { sql.append(" AND b.i_vendor = '").append(iVendor).append("' "); }
				if (selProj.length()>0 && !selProj.equals("ALL")) { 
					sql.append(" AND b.i_docno[1,2] = '"+(selProj.length()>=6 ? selProj.substring(0,2) : "")+"' AND b.i_docno[4,6] = '"+(selProj.length()>=6 ? selProj.substring(3,6) : "")+"' ");
				}
				sql.append(" AND b.f_itmstatus = 'CLS'");
				rs1 = stmt1.executeQuery(sql.toString());
				while (rs1.next()) {
					//itmLine++;
					String nItmJob = doString.checkString(rs1.getString("n_itmjob"),"");
					double qWage = rs1.getDouble("q_wage_unit");
					double zWage = rs1.getDouble("z_wage_price");
					double qGoods = rs1.getDouble("q_good_unit");
					double zGoods = rs1.getDouble("z_good_price");
					double sumWage = qWage * (double) zWage;
					double sumGoods = qGoods * (double) zGoods;
					double sumTotal = rs1.getDouble("z_amount_pay");
					double cutVendor = rs1.getDouble("z_amount_pv");

					sumSumWage += sumWage;
					sumSumGoods += sumGoods;
					sumSumTotal += sumTotal;
					sumCutVendor += cutVendor;


					//----============= Check Remark for Cut Vendor =====================---//
					String iVenCut = doString.checkString(rs1.getString("i_ven_cut"),"");
					double pCut = rs1.getDouble("p_cut");
					String remark = "";
					if ((!iVenCut.equals("999999")) || (iVenCut.equals("999999") && pCut>0)) {
						double amountCut = rs1.getDouble("z_cut_pv");
						remark = " - หมายเหตุ : ตัดเงินผู้รับเหมา ";
						remark += doString.checkString(rs1.getString("bus_name"),"");
						remark += " "+format.format(pCut)+"% เป็นเงิน "+format.format(amountCut)+" บาท";
  					    sumCutOnly += amountCut;
					}
					
					
					Hashtable data = new Hashtable();
					data.put("n_itmjob",nItmJob);
					data.put("remark",remark);
					data.put("q_wage_unit",new Double(qWage));
					data.put("z_wage_price",new Double(zWage));
					data.put("q_good_unit",new Double(qGoods));
					data.put("z_good_price",new Double(zGoods));
					data.put("z_amount_pay",new Double(sumTotal));
					data.put("z_amount_pv",new Double(cutVendor));
					vendorItem.addElement(data);
					
		    } // end while rs1
			rs1.close();
			for (int n=0;n<vendorItem.size();n++) {
				   itmLine++;
				   totalLine++;
				  Hashtable data = (Hashtable) vendorItem.elementAt(n);				
				  String nItmJob = doString.checkString((String) data.get("n_itmjob"),"");
				  String remark = doString.checkString((String) data.get("remark"),"");
				  double qWage = ((Double) data.get("q_wage_unit")).doubleValue();
				  double zWage = ((Double) data.get("z_wage_price")).doubleValue();
				  double qGoods = ((Double) data.get("q_good_unit")).doubleValue();
				  double zGoods = ((Double) data.get("z_good_price")).doubleValue();
				  double sumWage = qWage * (double) zWage;
				  double sumGoods = qGoods * (double) zGoods;
				  double sumTotal = ((Double) data.get("z_amount_pay")).doubleValue();
				  double cutVendor = ((Double) data.get("z_amount_pv")).doubleValue();			
				
				  if (remark.trim().length()>0) {
				      nItmJob += "\n     "+remark; 
				      totalLine++;
				  }				
				
				 //-----============================= Print Body =====================================----//
				 cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(itmLine+". "+nItmJob), microssfont));
				 cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
				 cell.setColspan(itemLength);
				 cell.setBorder(15);
				 table.addCell(cell);	
				 cell = new PdfPCell(new Phrase(format.format(zWage), microssfont));
				 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
				 cell.setColspan(zwLength);
				 cell.setBorder(15);
				 table.addCell(cell);	
				 cell = new PdfPCell(new Phrase(format.format(qWage), microssfont));
				 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
				 cell.setColspan(qwLength);
				 cell.setBorder(15);
				 table.addCell(cell);	
				 cell = new PdfPCell(new Phrase(format.format(sumWage), microssfont));
				 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
				 cell.setColspan(swLength);
				 cell.setBorder(15);
				 table.addCell(cell);				
				 cell = new PdfPCell(new Phrase(format.format(zGoods), microssfont));
				 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
				 cell.setColspan(zgLength);
				 cell.setBorder(15);
				 table.addCell(cell);	
				 cell = new PdfPCell(new Phrase(format.format(qGoods), microssfont));
				 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
				 cell.setColspan(qgLength);
				 cell.setBorder(15);
				 table.addCell(cell);	
				 cell = new PdfPCell(new Phrase(format.format(sumGoods), microssfont));
				 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				 cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
				 cell.setColspan(sgLength);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
				 cell.setBorder(15);
				 table.addCell(cell);	
				 cell = new PdfPCell(new Phrase(format.format(sumTotal), microssfont));
				 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				 cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
				 cell.setColspan(stLength);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
				 cell.setBorder(15);
				 table.addCell(cell);	
				 cell = new PdfPCell(new Phrase(format.format(cutVendor), microssfont));
				 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				 cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
				 cell.setColspan(scLength);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
				 cell.setBorder(15);
				 table.addCell(cell);				
				 totalLine++;	 
				  //-----==========================================================================----//
			  
					  if (totalLine>=rowPerPage && n<(vendorItem.size()-1)) {
						Rectangle page = document.getPageSize();
						PdfPTable foot = new PdfPTable(1);
						PdfPCell pcell = new PdfPCell(new Phrase(" มีหน้าต่อไป      ", microssfont));
						pcell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
						pcell.setVerticalAlignment(Rectangle.ALIGN_TOP);
						pcell.setBorder(0);
						foot.addCell(pcell);				
						foot.setTotalWidth(page.width() - document.leftMargin() - document.rightMargin());
						foot.writeSelectedRows(0, 1, document.leftMargin(), document.bottomMargin()+20,writer.getDirectContent());					  	

					  	 //---- add New Table -------//
						 document.add(table);		
						 document.newPage();
						 table = new PdfPTable(100);
						 table.setWidthPercentage(100);		
						 totalLine = 0;
						
						 genHeaderPage(table,headerReport,currDate,microssfont,microssfont_HD,microssfont_MINI);	
						 totalLine += 6;		
						 
						cell = new PdfPCell(new Phrase(" ", microssfont));
						cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
						cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
						cell.setColspan(100);
						cell.setBorder(0);
						table.addCell(cell);	
						totalLine++;
					  }
				  				  
				} // end for 
				vendorItem.clear();
				vendorItem = null;
			
				
				//-----======================= Print Summary Cut Only ===============================----//
				if (sumCutOnly>0) {
					cell = new PdfPCell(new Phrase("รวมตัดเงินผู้รับเหมาทั้งหมด "+format.format(sumCutOnly)+" บาท", microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
					cell.setColspan(itemLength);
					cell.setBorderColor(borderColor);
					cell.setFixedHeight(21);
					cell.setPaddingTop(3);
					cell.setPaddingBottom(5);
					cell.setBorder(15);
					//cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
					table.addCell(cell);	
					cell = new PdfPCell(new Phrase("", microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(zwLength);
					cell.setBorderColor(borderColor);
					cell.setFixedHeight(21);
					cell.setPaddingTop(3);
					cell.setPaddingBottom(5);
					cell.setBorder(15);
					//cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
					table.addCell(cell);					
					cell = new PdfPCell(new Phrase("", microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(qwLength);
					cell.setBorderColor(borderColor);
					cell.setFixedHeight(21);
					cell.setPaddingTop(3);
					cell.setPaddingBottom(5);
					cell.setBorder(15);
					//cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
					table.addCell(cell);	
					cell = new PdfPCell(new Phrase("", microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(swLength);
					cell.setBorderColor(borderColor);
					cell.setFixedHeight(21);
					cell.setPaddingTop(3);
					cell.setPaddingBottom(5);
					cell.setBorder(15);
					//cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
					table.addCell(cell);				
					cell = new PdfPCell(new Phrase("", microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(zgLength);
					cell.setBorderColor(borderColor);
					cell.setFixedHeight(21);
					cell.setPaddingTop(3);
					cell.setPaddingBottom(5);
					cell.setBorder(15);
					//cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
					table.addCell(cell);	
					cell = new PdfPCell(new Phrase("", microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(qgLength);
					cell.setBorderColor(borderColor);
					cell.setFixedHeight(21);
					cell.setPaddingTop(3);
					cell.setPaddingBottom(5);
					cell.setBorder(15);
					//cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
					table.addCell(cell);	
					cell = new PdfPCell(new Phrase("", microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(sgLength);
					cell.setBorderColor(borderColor);
					cell.setFixedHeight(21);
					cell.setPaddingTop(3);
					cell.setPaddingBottom(5);
					cell.setBorder(15);
					//cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
					table.addCell(cell);	
					cell = new PdfPCell(new Phrase("", microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(stLength);
					cell.setBorderColor(borderColor);
					cell.setFixedHeight(21);
					cell.setPaddingTop(3);
					cell.setPaddingBottom(5);
					cell.setBorder(15);
					//cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
					table.addCell(cell);	
					cell = new PdfPCell(new Phrase("", microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(scLength);
					cell.setBorderColor(borderColor);
					cell.setFixedHeight(21);
					cell.setPaddingTop(3);
					cell.setPaddingBottom(5);
					cell.setBorder(15);
					//cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
					table.addCell(cell);			
					totalLine++;		 					
				}
				 //-----==========================================================================----//		
				 				
				
				
				//-----========================== Print Summary ===================================----//
				cell = new PdfPCell(new Phrase("รวมทั้งหมด", microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
				cell.setColspan(itemLength+zwLength+qwLength);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
				cell.setBorder(0);
				//cell.setBackgroundColor(new Color(DARK_GRAY_COLOR));
				table.addCell(cell);	
				cell = new PdfPCell(new Phrase(format.format(sumSumWage), microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
				cell.setColspan(swLength);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
				cell.setBorder(15);
				//cell.setBackgroundColor(new Color(DARK_GRAY_COLOR));
				table.addCell(cell);	
				cell = new PdfPCell(new Phrase("", microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
				cell.setColspan(zgLength+qgLength);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
				cell.setBorder(0);
				//cell.setBackgroundColor(new Color(DARK_GRAY_COLOR));
				table.addCell(cell);	
				cell = new PdfPCell(new Phrase(format.format(sumSumGoods), microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
				cell.setColspan(sgLength);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
				cell.setBorder(15);
				//cell.setBackgroundColor(new Color(DARK_GRAY_COLOR));
				table.addCell(cell);	
				cell = new PdfPCell(new Phrase(format.format(sumSumTotal), microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
				cell.setColspan(stLength);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
				cell.setBorder(15);
				cell.setBackgroundColor(new Color(DARK_GRAY_COLOR));
				table.addCell(cell);	
				cell = new PdfPCell(new Phrase(format.format(sumCutVendor), microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
				cell.setColspan(scLength);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
				cell.setBorder(15);
				cell.setBackgroundColor(new Color(DARK_GRAY_COLOR));
				table.addCell(cell);	
				totalLine++;				 
				 //-----==========================================================================----//				
						
			} // end while rs
			rs.close();


			
			if (moreVendor) {
				Rectangle page = document.getPageSize();
				PdfPTable foot = new PdfPTable(1);
				PdfPCell pcell = new PdfPCell(new Phrase(" มีหน้าต่อไป      ", microssfont));
				pcell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				pcell.setVerticalAlignment(Rectangle.ALIGN_TOP);
				pcell.setBorder(0);
				foot.addCell(pcell);				
				foot.setTotalWidth(page.width() - document.leftMargin() - document.rightMargin());
				foot.writeSelectedRows(0, 1, document.leftMargin(), document.bottomMargin()+20,writer.getDirectContent());				
			}

			document.add(table);		
			document.newPage();
								
		} catch (Exception e) { 
			System.out.println("SERV_INFPrintReport9Servlet Error : "+e.getMessage()); 
		} finally {
			if (rs!=null) rs.close();  
			if (rs1!=null) rs1.close();  
			if (stmt!=null) stmt.close();  
			if (stmt1!=null) stmt1.close();  			
		}
		
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
		ResultSet rs = null;
		SERV_CommonData common = null;
		nowpage = 0;

		try {
			if (ds == null)
				getDS();

			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
			stmt = conn.createStatement();	
			common = new SERV_CommonData(conn);		
				
		
			//----================== Get Parameter from request ====================----//
			String iDocNo = doString.checkString(req.getParameter("i_docno"),"");			
			selProj = doString.checkString(req.getParameter("sel_project"),"").toUpperCase();
			iVendor = doString.checkString(req.getParameter("i_vendor"),"");
			startDate = common.getValueFromDateListbox("start",req);
			endDate = common.getValueFromDateListbox("end",req);
			condition = "";


			if (iDocNo.trim().length()>0) {
			   condition += " and a.i_docno='"+iDocNo+"'  ";
			   if (iDocNo.length()>=6) {
				   selProj = iDocNo.substring(0,2)+":"+iDocNo.substring(3,6);
			   }
			}
			//condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
			condition += " and a.i_company='"+(selProj.length()>=6 ? selProj.substring(0,2) : "")+"' and a.i_project='"+(selProj.length()>=6 ? selProj.substring(3,6) : "")+"' ";


/*			
			if (selProj.trim().length()>0 && !selProj.equalsIgnoreCase("ALL")) {
			   condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
			}

		if (selProj.trim().length()<=0) {
			   String projList = common.getProjectListByUserId(user.getUserID());
			   if (projList.length()>0) {
				   condition += " and substr(a.i_docno,1,6) in ("+projList+") ";
			   } else {
	
				sql.delete(0,sql.length());
				sql.append(" select count(*) from serv_pstaff  where user_id='").append(user.getUserID()).append("' and proj_id='ALL' ");
				int checkAllPermission = 0;
	
				rs = stmt.executeQuery(sql.toString());
				if (rs.next()) {
					checkAllPermission = rs.getInt(1);
				}
				rs.close();
				
				if (checkAllPermission<=0) {
				      //----- used for user that no project in hand , set for data not load ----//
				      condition += " and a.i_docno='NOPROEJCT' ";
				   } else {
				      selProj = "ALL";
				   }
			   }		   
		   } // end if check selProj length
*/

		   if (startDate.length()>0 && endDate.length()>0) {
			  condition += " and b.d_payment between '"+startDate+"' and '"+endDate+"' ";
		   }
		   //---=========================================================================----//



		   //----==================== Find all Vendor in this result ============================-----//
		   Vector vendorList = new Vector();
		   sql.delete(0,sql.length());
		   sql.append(" select distinct i_vendor from lan:serv_infdochd a,lan:serv_infpayment b ")
			 .append(" where a.f_status in ('OPN','CLS') and b.i_docno=a.i_docno and b.f_itmstatus='CLS' ");
		   if (iVendor.length()>0) { sql.append(" and b.i_vendor='").append(iVendor).append("' "); }
		   if (selProj.length()>0 && !selProj.equals("ALL")) { 
			   sql.append(" and a.i_company='"+(selProj.length()>=6 ? selProj.substring(0,2) : "")+"' and a.i_project='"+(selProj.length()>=6 ? selProj.substring(3,6) : "")+"' "); 
		   }		   
		   sql.append(condition);
		   rs = stmt.executeQuery(sql.toString());
		   while (rs.next()) {
			   vendorList.addElement(doString.checkString(rs.getString("i_vendor"),""));
		   }
		   rs.close();
  	     //---=========================================================================----//

			
			
			
			//----================ Initialize Variables for create PDF =====================---//
			Document document = new Document(PageSize.A4.rotate(), 30, 30, 10, 10);
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			PdfWriter writer = PdfWriter.getInstance(document, baos);
			PdfContentByte cb = writer.getDirectContent();

			document.open();

			PdfPTable table = new PdfPTable(100);
			table.setWidthPercentage(100);
			PdfPCell cell;

		   String headerReport = "";	
		   if (selProj.trim().length()>2) {
		   	    String projectName = "";
		   	    String vendorName = "";
		   	
				//----================= Get Company Name ===============----//
				sql.delete(0,sql.length());
				sql.append("select n_company from lan:acxcompa where i_company='").append(selProj.substring(0,2)).append("' ");
				rs = stmt.executeQuery(sql.toString());
				if (rs.next()) {
					companyName = doString.checkString(rs.getString("n_company"),"");
				}
				rs.close();		   	
		   	
		   	    //----================= Get Project Name ===============----//
				sql.delete(0,sql.length());
				sql.append(" select * from lan:acxprojt a where  ")
			          .append(" a.i_company='"+(selProj.length()>=6 ? selProj.substring(0,2) : "")+"' and a.i_project='"+(selProj.length()>=6 ? selProj.substring(3,6) : "")+"' ");
				rs = stmt.executeQuery(sql.toString());
				if (rs.next()) {
				    projectName = str.replace(selProj,":","-")+" "+doString.checkString(rs.getString("n_project"),"");
				}
				rs.close();


  			    //----================= Get Vendor Name ===============----//
				sql.delete(0,sql.length());
				sql.append("select bus_name from lan:stpvendr where vend_code='").append(iVendor).append("' ");
				rs = stmt.executeQuery(sql.toString());
				if (rs.next()) {
					vendorName = doString.checkString(rs.getString("bus_name"),"");
				}
				rs.close();

				if (projectName.length()>0) headerReport += " โครงการ : "+projectName+"\n";
  			    if (startDate.length()>0 && endDate.length()>0)  {
  			    	int syear = Integer.parseInt(startDate.substring(0,4));
					int eyear = Integer.parseInt(endDate.substring(0,4));
					if (syear<2400) syear += 543;
					if (eyear<2400) eyear += 543;
					startDate = startDate.substring(8,10)+"/"+startDate.substring(5,7)+"/"+Integer.toString(syear);
					endDate = endDate.substring(8,10)+"/"+endDate.substring(5,7)+"/"+Integer.toString(eyear);  			    	  
					betweenDate  = " วันที่จ่ายตั้งแต่วันที่ "+startDate+"  ถึง "+endDate+"\n";
  			    }
				if (vendorName.length()>0) headerReport += " ผู้รับเหมาซ่อม : "+iVendor+" - "+vendorName+"\n";
		   }
		   	

			for (int v=0;v<vendorList.size();v++) {
				    String nowVendor = (String) vendorList.elementAt(v);
				    
					//----==================== Get Markup Pay from SERV_XSTD  ====================-----//
				   String markupPay = "";			
				   if (selProj.trim().length()>0 && nowVendor.trim().length()>0) {
						sql.delete(0,sql.length());
						sql.append(" select * from lan:serv_venprj where ")
							  .append(" i_company='").append(selProj.length()>=6 ? selProj.substring(0,2) : "").append("' ")
							  .append(" and i_project='").append(selProj.length()>=6 ? selProj.substring(3,6) : "").append("' ")
							  .append(" and i_vendor='").append(nowVendor).append("' ");
						rs = stmt.executeQuery(sql.toString());
						if (rs.next()) {
						   double pAddPay = rs.getDouble("p_add_pay");
						   markupPay = doString.displayNumber("##0.0",pAddPay)+" %";
						}				        
						rs.close();	
				   }		
				   //---=========================================================================----//    				    
				    
					//----================== Select Data from SERV_DOCHD ================----//
					//writer.getPageEvent().onEndPage();
					genVendorData(writer,conn,nowVendor,headerReport,v<(vendorList.size()-1),markupPay,document);
			} // end for vendorList	

	
			if (vendorList.size()<=0) {
				//--====== Add Blank Page id no data ======---// 
				 table = new PdfPTable(100);
				 table.setWidthPercentage(100);		
			     document.add(table);		
				 document.newPage();				
			}
			
			

			//----=========== Generate PDF ===============-----//
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
			 System.err.println("error SERV_INFPrintRerort9Servlet  DOCUMENT: " + de.getMessage());
		} catch (Exception e) {
			System.out.println(" ERROR "+mName+" : " + e.getMessage());
			System.out.println(" ERROR "+mName+" SQL : " + sql.toString());			
		} finally {
			System.gc();			
			try {
				if (rs!=null) rs.close(); 
				if (stmt != null) stmt.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {}
		}
		System.out.println(mName + "end.");

	}

}
