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
public class SERV_PrintReport8Servlet extends DBServlet  {
	
	private String selProj = "";
	private String iVendor = "";
	private String startDate = "";
	private String endDate = "";
	private String condition = "";	
	private String orderBy = "";
	//private double markupPay = 0.0;
	private int rowPerPage = 30;
	
	private String companyName = "";
	private String projectName = ""; 
	private String cutVendorId = "";
	private int nowPage = 0;
	
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
	
	//--- init column scale ----//
	int noLength = 0;
	int docNoLength = 0;
	int sortLength = 0;
	int lockLength = 0;
	int vendorLength = 0;
	int wageLength = 0;
	int goodsLength = 0;
	int payLength = 0;
	int pvLength = 0;
	int cutR8Length = 0;
	int cutCLength = 0;
	int cutTLength = 0;
	int totalCutVLength = 0;
	int vPerCol = 0;
	int overflowLength = 0;
	
	
	
	public Double[] newDoubleArray(int size) {
		Double result[] = new Double[size];
		for (int i=0;i<size;i++) {
			   result[i] = new Double(0.0);
		}

	   return result;
	}
	
	
	public void printHeaderPage(PdfPTable table,String currDate,String iVendor,String vendorName,Vector vendorCut,String markupPay,Font microssfont,Font microssfont_HD,Font microssfont_MINI,Font microssfont_BOLD) {
			 nowPage++;
			 String headerReport = "";
			 DecimalFormat format = new DecimalFormat("###,##0.00");				     
		     
			if (projectName.length()>0) headerReport += " โครงการ : "+projectName+"\n";
			
			String betweenDate = "";
			if (startDate.length()>0 && endDate.length()>0)  {
				int syear = Integer.parseInt(startDate.substring(0,4));
				int eyear = Integer.parseInt(endDate.substring(0,4));
				if (syear<2400) syear += 543;
				if (eyear<2400) eyear += 543;
				String cStartDate = startDate.substring(8,10)+"/"+startDate.substring(5,7)+"/"+Integer.toString(syear);
				String cEndDate = endDate.substring(8,10)+"/"+endDate.substring(5,7)+"/"+Integer.toString(eyear);  			    	  
				betweenDate = "\n วันที่จ่ายตั้งแต่วันที่ "+cStartDate+"  ถึง "+cEndDate+"\n";
			}


		PdfPCell cell = new PdfPCell(new Phrase("หน้า "+nowPage,microssfont));
		cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setColspan(100);
		cell.setBorder(0);
		table.addCell(cell);
		
		cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(companyName+"\n รายละเอียดการส่งงานของผู้รับเหมา (สรุปตามใบแจ้งซ่อม)   "+betweenDate), microssfont_HD));
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
		cell = new PdfPCell(new Phrase("แบบรายงาน : SERV_PrintReport8 ,  "+currDate, microssfont));
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
		cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(iVendor+" - "+vendorName), microssfont_HD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setColspan(100);
		cell.setBorder(0);
		table.addCell(cell);				


/*		     
			//---====== Start PDF Header =======----//
			PdfPCell cell = new PdfPCell(new Phrase("Print Date : "+currDate+"\n", microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setColspan(100);
			cell.setBorder(0);
			table.addCell(cell);				     
		     
			 cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("รายละเอียดการส่งงานของผู้รับเหมา (สรุปตามใบแจ้งซ่อม)\n"+companyName+betweenDate), microssfont_HD));
			 cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			 cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			 cell.setColspan(100);
			 cell.setBorder(0);
			 table.addCell(cell);
			 cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(projectName), microssfont_HD));
			 cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			 cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			 cell.setColspan(50);
			 cell.setBorder(2);
			 table.addCell(cell);
			 cell = new PdfPCell(new Phrase("หน้าที่  : "+nowPage, microssfont_HD));
			 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			 cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			 cell.setColspan(50);
			 cell.setBorder(2);
			 table.addCell(cell);			 
			 
		cell = new PdfPCell(new Phrase("ผู้รับเหมาซ่อม "+iVendor+" - "+doString.MS874ToUnicode(vendorName)+"\n\n", microssfont_HD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setColspan(100);
		cell.setBorder(0);
		table.addCell(cell);	
*/
		   
		//----============================ Add Header Table ====================================-----//
		cell = new PdfPCell(new Phrase("No.", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(noLength);
		cell.setBorder(13);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("เลขที่ใบแจ้งซ่อม", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setColspan(docNoLength);
		cell.setBorder(13);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("แปลง", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setColspan(sortLength);
		cell.setBorder(13);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("บ้านเลขที่", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setColspan(lockLength);
		cell.setBorder(13);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("ผู้รับเหมาตัดเงิน", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setColspan(vendorLength);
		cell.setBorder(13);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("ค่าแรง", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setColspan(wageLength);
		cell.setBorder(13);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("ค่าของ", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setColspan(goodsLength);
		cell.setBorder(13);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("ค่าของ", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setColspan(payLength);
		cell.setBorder(13);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("รวมค่าดำเนินการ", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setColspan(pvLength);
		cell.setBorder(13);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("ตัดเงินผู้รับเหมา", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setColspan(totalCutVLength);
		cell.setBorder(13);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("ตัดเงินบริษัท ", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setColspan(cutR8Length+cutCLength);
		cell.setBorder(15);
		table.addCell(cell);			 
		cell = new PdfPCell(new Phrase("**", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setColspan(cutTLength);
		cell.setBorder(13);			
		table.addCell(cell);			   
		   
		cell = new PdfPCell(new Phrase("", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setColspan(noLength);
		cell.setBorder(14);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setColspan(docNoLength);
		cell.setBorder(14);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setColspan(sortLength);
		cell.setBorder(14);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setColspan(lockLength);
		cell.setBorder(14);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setColspan(vendorLength);
		cell.setBorder(14);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
	cell.setBorderColor(borderColor);
		cell.setColspan(wageLength);
		cell.setBorder(14);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setColspan(goodsLength);
		cell.setBorder(14);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("+ค่าแรง", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setColspan(payLength);
		cell.setBorder(14);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase(markupPay, microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setColspan(pvLength);
		cell.setBorder(14);
		table.addCell(cell);		
	
		for (int i=0;i<vendorCut.size();i++) {	   
				 Double val = (Double) vendorCut.elementAt(i);
				 cell = new PdfPCell(new Phrase(format.format(val.doubleValue())+" %", microssfont_BOLD));
				 cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				 cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
				 cell.setColspan(vPerCol+(i==vendorCut.size()-1 ? overflowLength : 0));
				 cell.setBorder(15);
				 table.addCell(cell);
		}


		cell = new PdfPCell(new Phrase("R8", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setColspan(cutR8Length);
		cell.setBorder(15);
		table.addCell(cell);		
		cell = new PdfPCell(new Phrase((selProj.length()>2 ? selProj.substring(0,2) : ""), microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setColspan(cutCLength);
		cell.setBorder(15);
		table.addCell(cell);		
		cell = new PdfPCell(new Phrase("", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);
		cell.setColspan(cutTLength);
		cell.setBorder(14);
		table.addCell(cell);					 		   
		//----===========================================================================================-----//			 
	}
	
	public void genVendorData(Document document,PdfWriter writer, Connection conn,String iVendor,String companyName,Vector vendorCut,String markupPay,Font microssfont,Font microssfont_HD,Font microssfont_MINI,Font microssfont_BOLD) throws Exception {
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
		SERV_CommonData common = new SERV_CommonData(conn);
		PdfPCell cell = null;

		double totalWage = 0.00;
		double totalGoods = 0.00;
		double totalPay = 0.00;
		double totalPV = 0.00;
		double totalR8 = 0.00;		
		double totalCutCompany = 0.00;		
		int totalLine = 0;


		//--- init column scale ----//
		noLength = 3;
		docNoLength = 8;
		sortLength = 4;
		lockLength = 5;
		vendorLength = 20;
		wageLength = 6;
		goodsLength = 6;
		payLength = 7;
		pvLength = 8;
		cutR8Length = 7;
		cutCLength = 7;
		cutTLength = 2;
		totalCutVLength = 100-(noLength+docNoLength+sortLength+lockLength+vendorLength+wageLength+goodsLength+payLength+pvLength+cutR8Length+cutCLength+cutTLength);
		
		Double sumCutVendor[] =  newDoubleArray(vendorCut.size());
		int tmpLength = totalCutVLength;
		vPerCol = 0;
		overflowLength = 0;
		   
		if (vendorCut.size()>0) {
			vPerCol = (tmpLength-(tmpLength%vendorCut.size()))/vendorCut.size();
			overflowLength = tmpLength%vendorCut.size();
		}			
				
				
		try {
			stmt = conn.createStatement();
			stmt1 = conn.createStatement();
			
			currDate = str.createID(now.get(Calendar.DATE),2)+"/"+str.createID(now.get(Calendar.MONTH)+1,2);
			int nYear = now.get(Calendar.YEAR);
			if (nYear<2500) nYear += 543;
			currDate += "/"+str.createID(nYear,4);
			currDate += " , "+str.createID(now.get(Calendar.HOUR_OF_DAY),2)+":"+str.createID(now.get(Calendar.MINUTE),2);		
			   	
		
			String vendorName = "";			
			if (iVendor.equals("999999")) {
				vendorName = companyName;
			} else {
			  sql.delete(0,sql.length());
			  sql.append("select bus_name from lan:stpvendr where vend_code='").append(iVendor).append("' ");
			  rs = stmt1.executeQuery(sql.toString());
			  if (rs.next()) {
				  vendorName = doString.checkString(rs.getString("bus_name"),"");
			  }
			  rs.close();					  	
			}		


			printHeaderPage(table,currDate,iVendor,vendorName,vendorCut,markupPay,microssfont,microssfont_HD,microssfont_MINI,microssfont_BOLD);		
			totalLine+=13;
					
					
			//----====================== Get All Cut Type Data ====================----//   
			String cutTypeDesc = "";
			sql.delete(0,sql.length());
			sql.append(" select * from lan:serv_xstd where i_type='03' ");                     
			rs = stmt.executeQuery(sql.toString());
			while (rs.next()) {
				if (cutTypeDesc.length()>0) cutTypeDesc += " , ";
				cutTypeDesc += doString.checkString(rs.getString("i_code"),"");
				cutTypeDesc += "="+doString.checkString(rs.getString("n_desc"),"");
			}
			rs.close();
			if (cutTypeDesc.length()>0) cutTypeDesc = "** "+cutTypeDesc;
					

			//----================== Select Data from SERV_DOCHD ================----//   
			   String oldCut = "";
			   int line = 0;		     
			   sql.delete(0,sql.length());
			   sql.append(" select a.i_lock,b.i_docno,b.i_ven_cut,sum(round(q_wage_unit * z_wage_price,2)) sum_wage, ")
					 .append(" sum(round(q_good_unit * z_good_price,2)) sum_goods, ")
					 .append(" sum(z_amount_pay) sum_amount_pay, sum(z_amount_pv) sum_amount_pv, ")
					 .append(" sum(z_amount_cut) sum_amount_cut from lan:serv_dochd a,lan:serv_payment b ")
					 .append(" where b.i_docno=a.i_docno and a.f_status in ('OPN','CLS') and b.f_itmstatus='CLS' ")
					 .append(condition);
				if (iVendor.length()>0) sql.append(" and b.i_vendor='").append(iVendor).append("' ");		
				if (cutVendorId.length()>0) sql.append(" and b.i_ven_cut='").append(cutVendorId).append("' ");
				sql.append(" group by b.i_docno,b.i_ven_cut,a.i_lock ")
				//	 .append(" order by b.i_docno,b.i_ven_cut ");
					 .append(" order by ").append(orderBy).append(",b.i_ven_cut ");					                       
			   rs = stmt.executeQuery(sql.toString());
			   while (rs.next()) {			        
					   String iDocNo = doString.checkString(rs.getString("i_docno"),"");
					   String vendorId = doString.checkString(rs.getString("i_ven_cut"),"");
					   double sumWage = rs.getDouble("sum_wage");
					   double sumGoods = rs.getDouble("sum_goods");
					   double amountPay = rs.getDouble("sum_amount_pay");
					   double amountPV = rs.getDouble("sum_amount_pv");					   
					   double cutR8 = 0.00;
					   double cutComp = 0.00;
					   Double cutVendor[] = newDoubleArray(vendorCut.size());

					  sumWage = Double.parseDouble(doString.displayNumber("#######0.00",sumWage));
					  sumGoods = Double.parseDouble(doString.displayNumber("#######0.00",sumGoods));
					  amountPay = Double.parseDouble(doString.displayNumber("#######0.00",amountPay));
					  amountPV = Double.parseDouble(doString.displayNumber("#######0.00",amountPV));
						
					   totalWage += sumWage;
					   totalGoods += sumGoods;
					   totalPay += amountPay;
					   totalPV += amountPV;
	   
		
						//----======================== Find DocHD Data =============================----//				            
						Hashtable tmpHeader = common.getDocHeaderDetails(iDocNo);
						String iLock = doString.checkString((String) tmpHeader.get("i_lock"),"");
						String iCompany = doString.checkString((String) tmpHeader.get("i_company"),"");
						String iProject = doString.checkString((String) tmpHeader.get("i_project"),"");
		
					   //----======================= Get Customer Details ===========================----//
					   Hashtable tmpCust = common.getCustomerDetails(iCompany,iProject,iLock);
					   String iHouse = doString.checkString((String) tmpCust.get("i_house"),"");
		
	
					   //----======================= Get VendorName ===========================----//
					   String vendName = "";				   
					   if (vendorId.equals("999999")) {
						   vendName = companyName;
					   } else {
						 sql.delete(0,sql.length());
						 sql.append("select bus_name from lan:stpvendr where vend_code='").append(vendorId).append("' ");
						 rs1 = stmt1.executeQuery(sql.toString());
						 if (rs1.next()) {
							vendName = doString.checkString(rs1.getString("bus_name"),"");
						 }
						 rs1.close();					  	
					   }
					   if (vendName.length()>37) vendName = vendName.substring(0,37)+"..";
					   
					   if (vendName.equalsIgnoreCase(oldCut)) {
						   vendName = "      \"       ";
					   } else {
						   oldCut = vendName;
					   }
					   
					   
					 //---============ get Cut Type ==============---//
					 String cutType = "";
					 String iTypeCutLck = "";
					 sql.delete(0,sql.length());
					 sql.append(" select a.i_type_cutlck,b.n_desc from lan:serv_dochd a ")
						   .append(" left join lan:serv_xstd b on b.i_type='03' and b.i_code=a.i_type_cutlck ")
						   .append(" where a.i_docno='").append(iDocNo).append("' ");
					 rs1 = stmt1.executeQuery(sql.toString());
					 if (rs1.next()) {					 	
						 iTypeCutLck = doString.checkString(rs1.getString("i_type_cutlck"),"");
						 cutType = doString.checkString(rs1.getString("n_desc"),"");
					 }
					 rs1.close();					   

		
					   //---============ Find Vendor Cut ==============---//					   
					   /*
					   sql.delete(0,sql.length());
					   sql.append(" select p_cut,sum(z_cut_pv) sum_cut_pv from lan:serv_dochd a,lan:serv_payment b ")
							 .append(" where b.i_docno=a.i_docno and a.f_status in ('OPN','CLS') and b.f_itmstatus='CLS' ")
							 .append(" and b.i_ven_cut='").append(vendorId).append("' ")
							 .append(" and b.i_docno='").append(iDocNo).append("' ");
						if (iVendor.length()>0) sql.append(" and b.i_vendor='").append(iVendor).append("' ");		
						if (cutVendorId.length()>0) sql.append(" and b.i_ven_cut='").append(cutVendorId).append("' ");		     							 
						sql.append(" group by p_cut ");
						*/
						/*
						sql.delete(0,sql.length());
						sql.append(" select p_cut,sum(z_cut_pv) sum_cut_pv from lan:serv_dochd a,lan:serv_payment b ")
							  .append(" where b.i_docno=a.i_docno and  a.f_status in ('OPN','CLS') and b.f_itmstatus='CLS' ")
							  .append(" and b.i_ven_cut='").append(vendorId).append("' ")
							  .append(" and b.i_docno='").append(iDocNo).append("' ");
						if (startDate.length()>0 && endDate.length()>0) {
						   sql.append(" and b.d_payment between '"+startDate+"' and '"+endDate+"' ");
						}
						if (cutVendorId.length()>0) {
							sql.append(" and b.i_ven_cut='").append(cutVendorId).append("' ");
						}							 					
  				       sql.append(" group by p_cut ");*/
						sql.delete(0,sql.length());
						sql.append(" select b.f_contr,b.p_cut,sum(z_cut_pv) as sum_cut_pv ")
						      .append(" from lan:serv_dochd a,lan:serv_payment b ")
						      .append(" where b.i_docno=a.i_docno and  a.f_status in ('OPN','CLS') ")
						      .append(" and b.f_itmstatus='CLS'  and b.i_ven_cut='").append(vendorId).append("' ")
						      .append(" and b.i_docno='").append(iDocNo).append("' ");
						if (startDate.length()>0 && endDate.length()>0) {
						      sql.append(" and b.d_payment between '"+startDate+"' and '"+endDate+"' ");
						}				   
				        if (iVendor.length()>0) {
				        	sql.append(" and b.i_vendor='").append(iVendor).append("' ");
				        } 								
						if (cutVendorId.length()>0) {
							sql.append(" and b.i_ven_cut='").append(cutVendorId).append("' ");
						}		
						sql.append(" group by b.f_contr,b.p_cut ");   				       		       
					   rs1 = stmt1.executeQuery(sql.toString());		   
					   while (rs1.next()) {
						   String fContr = doString.checkString(rs1.getString("f_contr"),"");
						   double pCut = rs1.getDouble("p_cut");
						   double cutValue = rs1.getDouble("sum_cut_pv");
		
						   //if (pCut==0.00 && cutVendorId.equals("999999")) 						   
						   if (pCut==0.00 && vendorId.equals("999999")) {
							    //if ((iTypeCutLck.equals("1") || iTypeCutLck.equals("2") || iTypeCutLck.equals("3")) && fContr.equalsIgnoreCase("Y")) {
							   //2025-06-23 by pradoem for R8
							   if (fContr.equalsIgnoreCase("Y")) {
								   //case R8
							        cutR8 += cutValue;    
									totalR8 += cutValue; 
							    } else {
									cutComp += cutValue;    
									totalCutCompany += cutValue; 
							    }
						   } else {
							   for (int c=0;c<vendorCut.size();c++) {
								 Double cut = (Double)  vendorCut.elementAt(c);
								 if (cut.doubleValue()==pCut) {
									 cutVendor[c] = new Double(cutVendor[c] .doubleValue()+cutValue);
									 sumCutVendor[c] = new Double(sumCutVendor[c].doubleValue()+cutValue);
									 break;
								 }
							   } // end for
						   }
					   } // end while rs1
					   rs1.close();
					   
					   
					   
					   
	
						
						 //------======================================== Start Print Data ==========================================-----//
						 cell = new PdfPCell(new Phrase(Integer.toString(line+1), microssfont));
						 cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
						 cell.setColspan(noLength);
						 cell.setBorder(15);
						 table.addCell(cell);			   
						 cell = new PdfPCell(new Phrase(iDocNo, microssfont));
						 cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
						 cell.setColspan(docNoLength);
						 cell.setBorder(15);
						 table.addCell(cell);			   
						 cell = new PdfPCell(new Phrase(iLock, microssfont));
						 cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
						 cell.setColspan(sortLength);
						 cell.setBorder(15);
						 table.addCell(cell);			   
						 cell = new PdfPCell(new Phrase(iHouse, microssfont));
						 cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
						 cell.setColspan(lockLength);
						 cell.setBorder(15);
						 table.addCell(cell);			   
						 cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(vendName), microssfont));
						 cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
						 cell.setColspan(vendorLength);
						 cell.setBorder(15);
						 table.addCell(cell);			   
						 cell = new PdfPCell(new Phrase(format.format(sumWage), microssfont));
						 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
						 cell.setColspan(wageLength);
						 cell.setBorder(15);
						 table.addCell(cell);			   
						 cell = new PdfPCell(new Phrase(format.format(sumGoods), microssfont));
						 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
						 cell.setColspan(goodsLength);
						 cell.setBorder(15);
						 table.addCell(cell);			   
						 cell = new PdfPCell(new Phrase(format.format(amountPay), microssfont));
						 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
						 cell.setColspan(payLength);
						 cell.setBorder(15);
						 table.addCell(cell);			   
						 cell = new PdfPCell(new Phrase(format.format(amountPV), microssfont));
						 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
						 cell.setColspan(pvLength);
						 cell.setBorder(15);
						 table.addCell(cell);		
			
						 for (int c=0;c<vendorCut.size();c++) {	   						 	
								  cell = new PdfPCell(new Phrase(format.format(cutVendor[c].doubleValue()), microssfont));
								  cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
							cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
							cell.setBorderColor(borderColor);
							cell.setFixedHeight(21);
							cell.setPaddingTop(3);
							cell.setPaddingBottom(5);
								  cell.setColspan(vPerCol+(c==vendorCut.size()-1 ? overflowLength : 0));
								  cell.setBorder(15);
								  table.addCell(cell);
						 }
		

						cell = new PdfPCell(new Phrase(format.format(cutR8), microssfont));
						cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			   cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			   cell.setBorderColor(borderColor);
			   cell.setFixedHeight(21);
			   cell.setPaddingTop(3);
			   cell.setPaddingBottom(5);
						cell.setColspan(cutR8Length);
						cell.setBorder(15);
						table.addCell(cell);		
						 cell = new PdfPCell(new Phrase(format.format(cutComp), microssfont));
						 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
						 cell.setColspan(cutCLength);
						 cell.setBorder(15);
						 table.addCell(cell);		
						 cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(iTypeCutLck), microssfont));
						 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
						 cell.setColspan(cutTLength);
						 cell.setBorder(15);
						 table.addCell(cell);				
						 //------================================================================================================-----//
	
						line++; 
						totalLine++;
						
						if (totalLine>=rowPerPage) {
							//----=========== Cut Type Desc ===========----//
							cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(cutTypeDesc), microssfont));
							cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
							cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
							cell.setColspan(100);
							cell.setBorder(0);
							table.addCell(cell);		
							
							Rectangle page = document.getPageSize();
							PdfPTable foot = new PdfPTable(1);
							PdfPCell pcell = new PdfPCell(new Phrase(" มีหน้าต่อไป      ", microssfont));
							pcell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
							pcell.setVerticalAlignment(Rectangle.ALIGN_TOP);
							pcell.setBorder(0);
							foot.addCell(pcell);				
							foot.setTotalWidth(page.width() - document.leftMargin() - document.rightMargin());
							foot.writeSelectedRows(0, 1, document.leftMargin(), document.bottomMargin()+20,writer.getDirectContent());			
														
/*
							while (totalLine<rowPerPage) {
							   cell = new PdfPCell(new Phrase("\n", microssfont));
							   cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
							   cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
							   cell.setColspan(100);
							   cell.setBorder(0);
							   table.addCell(cell);	
							   totalLine++;					  	
							}					  	
														
							cell = new PdfPCell(new Phrase(" มีหน้าต่อไป      ", microssfont));
							cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
							cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
							cell.setColspan(100);
							cell.setBorder(0);
							table.addCell(cell);	
							totalLine++;										
*/														
							
							
						   document.add(table);		
						   document.newPage();
						   table = new PdfPTable(100);
						   table.setWidthPercentage(100);		
						   totalLine = 0;
						   
						   printHeaderPage(table,currDate,iVendor,vendorName,vendorCut,markupPay,microssfont,microssfont_HD,microssfont_MINI,microssfont_BOLD);		
						   totalLine+= 13;						   
						}						
			  } // end while					
					
					
					
					
			 //------============================================ Print Total Line ==============================================-----//
			 cell = new PdfPCell(new Phrase("รวมเป็นเงิน", microssfont));
			 cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setBorderColor(borderColor);
			cell.setFixedHeight(21);
			cell.setPaddingTop(3);
			cell.setPaddingBottom(5);
			 cell.setColspan(noLength+docNoLength+sortLength+lockLength+vendorLength);			
			 cell.setBorder(0);
			 //cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
			 table.addCell(cell);			   	   
System.out.println("total="+totalGoods+" = "+format.format(totalGoods));			 
			 cell = new PdfPCell(new Phrase(format.format(totalWage), microssfont));
			 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setBorderColor(borderColor);
			cell.setFixedHeight(21);
			cell.setPaddingTop(3);
			cell.setPaddingBottom(5);
			 cell.setColspan(wageLength);
			 cell.setBorder(15);
			 //cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
			 table.addCell(cell);			   
			 cell = new PdfPCell(new Phrase(format.format(totalGoods), microssfont));
			 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setBorderColor(borderColor);
			cell.setFixedHeight(21);
			cell.setPaddingTop(3);
			cell.setPaddingBottom(5);
			 cell.setColspan(goodsLength);
			 cell.setBorder(15);
			 //cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
			 table.addCell(cell);			   
			 cell = new PdfPCell(new Phrase(format.format(totalPay), microssfont));
			 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setBorderColor(borderColor);
			cell.setFixedHeight(21);
			cell.setPaddingTop(3);
			cell.setPaddingBottom(5);
			 cell.setColspan(payLength);
			 cell.setBorder(15);
			 //cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
			 table.addCell(cell);			   
			 cell = new PdfPCell(new Phrase(format.format(totalPV), microssfont));
			 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setBorderColor(borderColor);
			cell.setFixedHeight(21);
			cell.setPaddingTop(3);
			cell.setPaddingBottom(5);
			 cell.setColspan(pvLength);
			 cell.setBorder(15);
			 cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
			 table.addCell(cell);		
			
			 for (int c=0;c<vendorCut.size();c++) {	   
					  cell = new PdfPCell(new Phrase(format.format(sumCutVendor[c].doubleValue()), microssfont));
					  cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setBorderColor(borderColor);
				cell.setFixedHeight(21);
				cell.setPaddingTop(3);
				cell.setPaddingBottom(5);
					  cell.setColspan(vPerCol+(c==vendorCut.size()-1 ? overflowLength : 0));
					  cell.setBorder(15);
					  cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
					  table.addCell(cell);
			 }
		

			cell = new PdfPCell(new Phrase(format.format(totalR8), microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		   cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		   cell.setBorderColor(borderColor);
		   cell.setFixedHeight(21);
		   cell.setPaddingTop(3);
		   cell.setPaddingBottom(5);
			cell.setColspan(cutR8Length);
			cell.setBorder(15);
			cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
			table.addCell(cell);				
			 cell = new PdfPCell(new Phrase(format.format(totalCutCompany), microssfont));
			 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setBorderColor(borderColor);
			cell.setFixedHeight(21);
			cell.setPaddingTop(3);
			cell.setPaddingBottom(5);
			 cell.setColspan(cutCLength);
			 cell.setBorder(15);
			 cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
			 table.addCell(cell);		
			cell = new PdfPCell(new Phrase("", microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setBorderColor(borderColor);
			cell.setFixedHeight(21);
			cell.setPaddingTop(3);
			cell.setPaddingBottom(5);
			cell.setColspan(cutTLength);
			cell.setBorder(15);
			//cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
			table.addCell(cell);		
			//------========================================================================================================-----//					


			//----=========== Cut Type Desc ===========----//
			cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(cutTypeDesc), microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setColspan(100);
			cell.setBorder(0);
			table.addCell(cell);		
			

			document.add(table);		
			document.newPage();
								
		} catch (Exception e) { 
			System.out.println("SERV_PrintRerort8Servlet Error : "+e.getMessage()); 
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
		Statement stmt1 = null;
		ResultSet rs = null;
		ResultSet rs1 = null;
		SERV_CommonData common = null;
		nowPage = 0;		

		try {
			if (ds == null)
				getDS();

			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();	
			stmt1 = conn.createStatement();	
			common = new SERV_CommonData(conn);		


			String currDate = "";
			Calendar now = Calendar.getInstance(Locale.ENGLISH);
			currDate = str.createID(now.get(Calendar.DATE),2)+"/"+str.createID(now.get(Calendar.MONTH)+1,2);
			int nYear = now.get(Calendar.YEAR);
			if (nYear<2500) nYear += 543;
			currDate += "/"+str.createID(nYear,4);
			currDate += " , "+str.createID(now.get(Calendar.HOUR_OF_DAY),2)+":"+str.createID(now.get(Calendar.MINUTE),2);		

			
		
			//----================== Get Parameter from request ====================----//
			selProj = doString.checkString(req.getParameter("sel_project"),"").toUpperCase();
			iVendor = doString.checkString(req.getParameter("i_vendor"),"");
			cutVendorId = doString.checkString(req.getParameter("cut_vendor"),"");
			orderBy = doString.checkString(req.getParameter("order_by"),"a.i_lock,b.i_docno");
			startDate = common.getValueFromDateListbox("start",req);
			endDate = common.getValueFromDateListbox("end",req);
			condition = "";

			//condition += " and a.i_company||':'||a.i_project='"+selProj+"'  ";
			condition += " and a.i_company='"+(selProj.length()>0 ? selProj.substring(0,2) : "")+"' and a.i_project='"+(selProj.length()>0 ? selProj.substring(3,6) : "")+"'  ";			
			if (iVendor.trim().length()>0) {
			   condition += " and b.i_vendor='"+iVendor+"'  ";
			}

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


		   //----==================== Get Vendor Percent cut from SERV_XSTD  ====================-----//
		   Vector vendorCut = new Vector();
		   sql.delete(0,sql.length());
		   sql.append(" select * from lan:serv_xstd where i_type='04' ");
		   rs = stmt.executeQuery(sql.toString());
		   while (rs.next()) {
			  double percent = rs.getDouble("p_amount");
			  vendorCut.addElement(new Double(percent));
		   }
		   rs.close();
		  //---==============================================================================----//
		
			
			
			//----================ Initialize Variables for create PDF =====================---//
			BaseFont bf = BaseFont.createFont(Constants.FONT_ANGSANA_NORMAL, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
			BaseFont bfb = BaseFont.createFont(Constants.FONT_ANGSANA_BOLD, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
			Font microssfont = new Font(bf, 12, Font.NORMAL);
			Font microssfont_MINI = new Font(bf, 10, Font.NORMAL);
			Font microssfont_BOLD = new Font(bfb, 12, Font.NORMAL);
			Font microssfont_BOLD_UNDERLINE = new Font(bfb, 12, Font.UNDERLINE);
			Font microssfont_HD = new Font(bfb, 18, Font.NORMAL);

			Document document = new Document(PageSize.A4.rotate(), 30, 30, 10, 10);
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			PdfWriter writer = PdfWriter.getInstance(document, baos);
			PdfContentByte cb = writer.getDirectContent();

			//PdfReader reader = new PdfReader(Constants.PDF_HEADER_TEMPLATE);
			//PdfImportedPage page1 = writer.getImportedPage(reader, 1);

			document.open();

			PdfPTable table = new PdfPTable(100);
			table.setWidthPercentage(100);
			PdfPCell cell;


		   companyName = "";
		   String vendorName = "";		   	
		   		   	
		   if (selProj.trim().length()>2) {
				projectName = "";
				
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
				sql.append(" select * from lan:acxprojt a where ")
					  .append(" a.i_company='"+(selProj.length()>0 ? selProj.substring(0,2) : "")+"' ")
					  .append(" and a.i_project='"+(selProj.length()>0 ? selProj.substring(3,6) : "")+"'  ");				
				rs = stmt.executeQuery(sql.toString());
				if (rs.next()) {
					//projectName =  "โครงการ "+selProj+" - "+doString.checkString(rs.getString("n_project"),"");
					projectName =  doString.checkString(rs.getString("n_project"),"");
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

		   }
		   	

		   //----==================== Find all Vendor in this result ============================-----//
		   Vector vendorList = new Vector();
		   sql.delete(0,sql.length());
		   sql.append(" select distinct i_vendor from lan:serv_dochd a,lan:serv_payment b ")
			 .append(" where a.f_status in ('OPN','CLS') and b.i_docno=a.i_docno and b.f_itmstatus='CLS' ");
		   if (iVendor.length()>0) { sql.append(" and b.i_vendor='").append(iVendor).append("' "); }
		   if (cutVendorId.length()>0) sql.append(" and b.i_ven_cut='").append(cutVendorId).append("' ");
		   //if (selProj.length()>0 && !selProj.equals("ALL")) { sql.append(" and substr(b.i_docno,1,2)||':'||substr(b.i_docno,4,3)='").append(selProj).append("' "); }
		   if (selProj.length()>0 && !selProj.equals("ALL")) { 
			   sql.append(" and a.i_company='"+(selProj.length()>=6 ? selProj.substring(0,2) : "")+"' and a.i_project='"+(selProj.length()>=6 ? selProj.substring(3,6) : "")+"' "); 
		   }		   
		   sql.append(condition);
		   rs = stmt.executeQuery(sql.toString());
		   while (rs.next()) {
			   vendorList.addElement(doString.checkString(rs.getString("i_vendor"),""));
		   }
		   rs.close();

	   if (vendorList.size()<=0) vendorList.addElement("");
	   //---=========================================================================----//					
					
			
		 for (int v=0;v<vendorList.size();v++) {
				//nowPage = 0;
				String vendorId = doString.checkString((String) vendorList.elementAt(v),"");
				
				String markupPay = "";			
				if (selProj.trim().length()>0 && vendorId.trim().length()>0) {
					 sql.delete(0,sql.length());
					 sql.append(" select * from lan:serv_venprj where ")
						   .append(" i_company='").append(selProj.length()>=6 ? selProj.substring(0,2) : "").append("' ")
						   .append(" and i_project='").append(selProj.length()>=6 ? selProj.substring(3,6) : "").append("' ")
						   .append(" and i_vendor='").append(vendorId).append("' ");
					 rs = stmt.executeQuery(sql.toString());
					 if (rs.next()) {
						double pAddPay = rs.getDouble("p_add_pay");
						markupPay = doString.displayNumber("##0.0",pAddPay)+" %";
					 }				        
					 rs.close();	
				}				
				
				genVendorData(document,writer,conn,vendorId,companyName,vendorCut,markupPay,microssfont,microssfont_HD,microssfont_MINI,microssfont_BOLD);
		 } // end for vendorList	
				
				
		 if (vendorList.size()<=0) {
			 //--====== Add Blank Page id no data ======---// 
			 table = new PdfPTable(100);
			 table.setWidthPercentage(100);		
			 document.add(table);		
			 document.newPage();				
		 }
			
			
			

			//----=========== Generate PDF ===============-----//
			document.add(table);
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
			 System.err.println("error SERV_PrintRerort8Servlet  DOCUMENT: " + de.getMessage());
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
