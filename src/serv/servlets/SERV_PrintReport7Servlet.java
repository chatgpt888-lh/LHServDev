package serv.servlets;

import java.io.*;
import java.text.DecimalFormat;
import java.util.*;
import java.sql.*; 

import javax.servlet.*;
import javax.servlet.http.*;

import com.ibm.ws.jsp.translator.visitor.generator.DoBodyGenerator;
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
public class SERV_PrintReport7Servlet extends DBServlet  {
	
	private String selProj = "";
	private String iVendor = "";
	private String startDate = "";
	private String endDate = "";
	private String condition = "";	
	//private double markupPay = 0.0;
	private String companyName = "";
	private String betweenDate = ""; 
	private int nowpage = 0;
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
	private int noLength = 3;
	private int vendorLength = 26;
	private int countDocLength = 5;
	private int wageLength = 8;
	private int goodsLength = 8;
	private int payLength = 9;
	private int pvLength = 10;
	private int cutCLength = 10;
	private int totalCutVLength = 100-(noLength+vendorLength+countDocLength+wageLength+goodsLength+payLength+pvLength);
	private int tmpLength = totalCutVLength;
	private int vPerCol = 0;
	private int overflowLength = 0;	
	
	
	public Double[] newDoubleArray(int size) {
		Double result[] = new Double[size];
		for (int i=0;i<size;i++) {
			   result[i] = new Double(0.0);
		}

  	   return result;
	}
	
	public String displayFormat(double val) {
        String tmp = Double.toString(val);
        String precision = "";
        if (tmp.indexOf(".")==0) tmp = "0"+tmp; // case '.xx' value
        if (tmp.indexOf(".")<0) tmp = tmp+".000"; // case 'x' value
       
        if (tmp.indexOf(".")>0) {
              precision = tmp.substring(tmp.indexOf(".")+1);
              if (precision.length()>3) precision = precision.substring(0,3); // cut data length more than 3
              while (precision.length()<3) precision += "0"; // add 0 after if length less than 3
        } else {
              precision = "000";
        }                      
        tmp = tmp.substring(0,tmp.indexOf("."))+"."+precision;           

        return doString.displayNumber("#,###,##0.00",Double.parseDouble(tmp));
  }

	
	public void genHeaderPage(PdfPTable table,String headerReport,String currDate,Vector vendorCut,String iVendor,String vendorName,String markupPay,Font microssfont,Font microssfont_HD,Font microssfont_MINI,Font microssfont_BOLD
			,String pvNo,String cpNo) throws Exception {
			
			nowpage++;			
		    DecimalFormat format = new DecimalFormat("###,##0.00");		
			
			PdfPCell cell = new PdfPCell(new Phrase("หน้า "+nowpage,microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setColspan(100);
			cell.setBorder(0);
			table.addCell(cell);
					
			cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(companyName+"\n รายละเอียดการส่งงานของผู้รับเหมา (สรุปตามการตัดเงิน)   "+betweenDate), microssfont_HD));
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
			
			cell = new PdfPCell(new Phrase("แบบรายงาน : SERV_PrintReport7 ,  "+currDate, microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
			cell.setColspan(50);
			cell.setBorder(0);
			table.addCell(cell);

			/*
			cell = new PdfPCell(new Phrase(" ", microssfont_MINI));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setColspan(100);
			cell.setBorder(2);
			table.addCell(cell);		*/
			String nameWithId = "";
			if (vendorName.trim().length()>0 && iVendor.trim().length()>0) {
				nameWithId = iVendor+" - "+vendorName;
			} else {
				nameWithId = vendorName;
			}				 
			cell = new PdfPCell(new Phrase(" "+doString.MS874ToUnicode(nameWithId), microssfont_HD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setColspan(60);
			cell.setBorder(0);
			table.addCell(cell);
			
			cell = new PdfPCell(new Phrase("PV_NO : "+pvNo+"   , CP_NO : "+cpNo, microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
			cell.setColspan(40);
			cell.setBorder(0);
			table.addCell(cell);
			

		//----============================ Add Header Table ====================================-----//
		cell = new PdfPCell(new Phrase("No.", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setBorderColor(borderColor);
		cell.setColspan(noLength);
		cell.setBorder(13);
		table.addCell(cell);			      	   
		cell = new PdfPCell(new Phrase("ผู้รับเหมาตัดเงิน", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setPaddingTop(6);
		cell.setPaddingLeft(4);
		cell.setBorderColor(borderColor);
		cell.setColspan(vendorLength);
		cell.setBorder(13);
		table.addCell(cell);			 
		cell = new PdfPCell(new Phrase("จำนวน ", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setBorderColor(borderColor);
		cell.setColspan(countDocLength);
		cell.setBorder(13);
		table.addCell(cell);			
		cell = new PdfPCell(new Phrase("ค่าแรง ", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setBorderColor(borderColor);
		cell.setColspan(wageLength);
		cell.setBorder(13);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("ค่าของ ", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setBorderColor(borderColor);
		cell.setColspan(goodsLength);
		cell.setBorder(13);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("ค่าของ-ค่าแรง ", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setBorderColor(borderColor);
		cell.setColspan(payLength);
		cell.setBorder(13);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("รวมค่าดำเนินการ ", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setBorderColor(borderColor);
		cell.setColspan(pvLength);
		cell.setBorder(13);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("ตัดเงินผู้รับเหมา", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_CENTER);
		cell.setBorderColor(borderColor);
		cell.setColspan(totalCutVLength);
		cell.setBorder(13);
		table.addCell(cell);			   	 
		   
		   
		cell = new PdfPCell(new Phrase("", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setBorderColor(borderColor);
		cell.setColspan(noLength);
		cell.setBorder(14);
		table.addCell(cell);
		cell = new PdfPCell(new Phrase("", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setBorderColor(borderColor);
		cell.setColspan(vendorLength);
		cell.setBorder(14);
		table.addCell(cell);
		cell = new PdfPCell(new Phrase("ใบแจ้งซ่อม ", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setBorderColor(borderColor);
		cell.setPaddingBottom(5);
		cell.setColspan(countDocLength);
		cell.setBorder(14);
		table.addCell(cell);			
		cell = new PdfPCell(new Phrase("", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setBorderColor(borderColor);
		cell.setColspan(wageLength);
		cell.setBorder(14);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setBorderColor(borderColor);
		cell.setColspan(goodsLength);
		cell.setBorder(14);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase("รวม ", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setBorderColor(borderColor);
		cell.setPaddingBottom(5);
		cell.setColspan(payLength);
		cell.setBorder(14);
		table.addCell(cell);			   
		cell = new PdfPCell(new Phrase(markupPay, microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setBorderColor(borderColor);
		cell.setPaddingBottom(5);
		cell.setColspan(pvLength);// ค่าดำนเนินการ
		cell.setBorder(14);
		table.addCell(cell);		
	
		for (int i=0;i<vendorCut.size();i++) {	   
				 Double val = (Double) vendorCut.elementAt(i);
				 cell = new PdfPCell(new Phrase(format.format(val.doubleValue())+" %", microssfont_BOLD));
				 cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				 cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			     cell.setPaddingBottom(5);
	 		     cell.setBorderColor(borderColor);
				 cell.setColspan(vPerCol+(i==vendorCut.size()-1 ? overflowLength : 0));
				 cell.setBorder(15);
				 table.addCell(cell);
		}

		cell = new PdfPCell(new Phrase((selProj.length()>2 ? selProj.substring(0,2) : ""), microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setPaddingBottom(5);
		cell.setBorderColor(borderColor);
		cell.setColspan(cutCLength);
		cell.setBorder(15);
		table.addCell(cell);			  		   
		//----===========================================================================================-----//
								
	
	}
	
	
	public void genVendorData(Document document,PdfWriter writer,Connection conn,String iVendor,String companyName,String headerReport,Vector vendorCut,String markupPay,Font microssfont,Font microssfont_HD,Font microssfont_MINI,Font microssfont_BOLD) throws Exception {
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
		//DecimalFormat format = new DecimalFormat("###,##0.00");		
		SERV_CommonData common = new SERV_CommonData(conn);

		double totalWage = 0.00;
		double totalGoods = 0.00;
		double totalPay = 0.00;
		double totalPV = 0.00;
		double totalCutCompany = 0.00;		
		double grandTotalWage = 0.00;
		double grandTotalPrice = 0.00;
		int totalLine = 0;
		double t_pergood = 0;
		double t_good = 0;


		//--- init column scale ----//
		noLength = 3;
		vendorLength = 35;
		countDocLength = 6;
		wageLength = 8;
		goodsLength = 8;
		payLength = 9;
		pvLength = 10;
		cutCLength = 10;
		totalCutVLength = 100-(noLength+vendorLength+countDocLength+wageLength+goodsLength+payLength+pvLength);
		
		Double sumCutVendor[] =  newDoubleArray(vendorCut.size());
		tmpLength = totalCutVLength;
		vPerCol = 0;
		overflowLength = 0;
		   
		if (vendorCut.size()>0) {
			vPerCol = (tmpLength-(tmpLength%(vendorCut.size()+1)))/(vendorCut.size()+1);
			overflowLength = tmpLength%(vendorCut.size()+1);
			cutCLength = vPerCol;
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

			String pvNo = "";
			String cpNo = "";
			//-----------------
			//condition =  and a.i_company='LH' and a.i_project='286'   and b.i_vendor='346756'   and b.d_payment between '2025-04-01' and '2025-04-30' 
			sql.delete(0,sql.length());
			sql.append(" select unique b.pv_no,b.cp_no ")
			  .append("  from lan:serv_dochd a,lan:serv_payment b   ")
			  .append(" where b.i_docno=a.i_docno and a.f_status != 'CAN' and b.f_itmstatus='CLS'  ")
			  .append(condition)
			  //.append("  and  b.pv_no is not null ")
			  //.append(" and  b.cp_no is not null ")
			  .append(" group by b.pv_no,b.cp_no   ")
			  .append(" order by b.pv_no,b.cp_no desc  ");
			 rs = stmt1.executeQuery(sql.toString());
			 if (rs.next()) {
				 pvNo = doString.checkString(rs.getString("pv_no"),"");
				 cpNo = doString.checkString(rs.getString("cp_no"),"");
			 }
			 rs.close();			
			//-----------------
			

			//---====== Start PDF Header =======----//
			PdfPCell cell;
			genHeaderPage(table,headerReport,currDate,vendorCut,iVendor,vendorName,markupPay,microssfont,microssfont_HD,microssfont_MINI,microssfont_BOLD,pvNo,cpNo);
			totalLine += 8;

					
			 //System.out.println("condition = "+condition);
			//----================== Select Data from SERV_DOCHD ================----//   
			   int line = 0;		     
			   sql.delete(0,sql.length());
			   sql.append(" select b.i_ven_cut,sum(q_wage_unit * z_wage_price) sum_wage, ")
					 .append(" sum(q_good_unit * z_good_price) sum_goods, ")
					 .append(" sum((q_wage_unit * z_wage_price * p_add_pay)/100) sum_wage_add_pay, ")             
					 .append(" sum((q_good_unit * z_good_price * p_add_pay)/100) sum_price_add_pay, ")            								 
					 .append(" sum(z_amount_pay) sum_amount_pay, sum(z_amount_pv) sum_amount_pv, ")
					 .append(" sum(z_amount_cut) sum_amount_cut from lan:serv_dochd a,lan:serv_payment b ")
					 .append(" where b.i_docno=a.i_docno and a.f_status != 'CAN' and b.f_itmstatus='CLS' ")
				     .append(condition);
			//    if (iVendor.length()>0) sql.append(" and b.i_vendor='").append(iVendor).append("' ");				     
				sql.append(" group by b.i_ven_cut ")
					 .append(" order by b.i_ven_cut ");
  //System.out.println("xxx = "+sql.toString());
			   rs = stmt.executeQuery(sql.toString());
			   while (rs.next()) {			        
					   String vendorId = doString.checkString(rs.getString("i_ven_cut"),"");
					   double sumWage = rs.getDouble("sum_wage");
					   double sumGoods = rs.getDouble("sum_goods");
					   double amountPay = rs.getDouble("sum_amount_pay");
					   double amountPV = rs.getDouble("sum_amount_pv");
					   double sumWageAddPay = rs.getDouble("sum_wage_add_pay");
					   double sumPriceAddPay = rs.getDouble("sum_price_add_pay");
					   double cutComp = 0.00;
					   Double cutVendor[] = newDoubleArray(vendorCut.size());
					   					   
						
					   totalWage += sumWage;
					   totalGoods += sumGoods;
					   totalPay += amountPay;
					   totalPV += amountPV;
					   grandTotalWage += sumWageAddPay;
					   
					   
					   grandTotalPrice += sumPriceAddPay;
		
		
						//----======================= Get iDocNo Count ===========================----//		
						int countDoc = 0;
						sql.delete(0,sql.length());
						sql.append(" select count(*) from lan:serv_dochd a,lan:serv_payment b where ")
							  .append(" b.i_docno=a.i_docno and a.f_status in ('OPN','CLS') and b.f_itmstatus='CLS' ")
							  .append(condition)
							  .append(" and b.i_ven_cut='").append(vendorId).append("' ")
							  .append(" group by b.i_docno ");
						//System.out.println("SQL :"+sql.toString());
						rs1 = stmt1.executeQuery(sql.toString());
						while (rs1.next()) {
							countDoc++;
						}
						rs1.close();
	
	
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

		
					   //---============ Find Vendor Cut ==============---//			
					   sql.delete(0,sql.length());
					   sql.append(" select p_cut,sum(z_cut_pv) sum_cut_pv from lan:serv_dochd a,lan:serv_payment b ")
							 .append(" where b.i_docno=a.i_docno and a.f_status in ('OPN','CLS') and b.f_itmstatus='CLS' ")
							 .append(" and b.i_ven_cut='").append(vendorId).append("' ");
						//	 .append(" and b.i_docno='").append(iDocNo).append("' ");
						if (iVendor.length()>0) sql.append(" and b.i_vendor='").append(iVendor).append("' ");		
						sql.append(condition);		     							 
						sql.append(" group by p_cut ");
						//System.out.println(sql.toString());						
					   rs1 = stmt1.executeQuery(sql.toString());
					   while (rs1.next()) {
						   double pCut = rs1.getDouble("p_cut");
						   double cutValue = rs1.getDouble("sum_cut_pv");
		
						   if (pCut==0.00 && vendorId.equals("999999")) {
							   cutComp += cutValue;    
							   totalCutCompany += cutValue; 
						   } else {
							   for (int c=0;c<vendorCut.size();c++) {
								 Double cut = (Double)  vendorCut.elementAt(c);
								 if (cut.doubleValue()==pCut) {
									 cutVendor[c] = new Double(cutValue);
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
						 cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(vendorId+" - "+vendName), microssfont));
						 cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
						cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
						cell.setBorderColor(borderColor);
						cell.setFixedHeight(21);
						cell.setPaddingTop(3);
						cell.setPaddingBottom(5);
						 cell.setColspan(vendorLength);
						 cell.setBorder(15);
						 table.addCell(cell);	
					 	 cell = new PdfPCell(new Phrase(Integer.toString(countDoc), microssfont));
						 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
						cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
						cell.setBorderColor(borderColor);
						cell.setFixedHeight(21);
						cell.setPaddingTop(3);
						cell.setPaddingBottom(5);
						 cell.setColspan(countDocLength);
						 cell.setBorder(15);
						 table.addCell(cell);	
						 //cell = new PdfPCell(new Phrase(format.format(sumWage), microssfont));
				cell = new PdfPCell(new Phrase(displayFormat(sumWage), microssfont));
						 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
						cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
						cell.setBorderColor(borderColor);
						cell.setFixedHeight(21);
						cell.setPaddingTop(3);
						cell.setPaddingBottom(5);
						 cell.setColspan(wageLength);
						 cell.setBorder(15);
						 table.addCell(cell);			   
						 //cell = new PdfPCell(new Phrase(format.format(sumGoods), microssfont));
				cell = new PdfPCell(new Phrase(displayFormat(sumGoods), microssfont));
						 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
						cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
						cell.setBorderColor(borderColor);
						cell.setFixedHeight(21);
						cell.setPaddingTop(3);
						cell.setPaddingBottom(5);
						 cell.setColspan(goodsLength);
						 cell.setBorder(15);
						 table.addCell(cell);			   
						 //cell = new PdfPCell(new Phrase(format.format(amountPay), microssfont));
				cell = new PdfPCell(new Phrase(displayFormat(amountPay), microssfont));
						 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
						cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
						cell.setBorderColor(borderColor);
						cell.setFixedHeight(21);
						cell.setPaddingTop(3);
						cell.setPaddingBottom(5);
						 cell.setColspan(payLength);
						 cell.setBorder(15);
						 table.addCell(cell);			   
						 //cell = new PdfPCell(new Phrase(format.format(amountPV), microssfont));
				cell = new PdfPCell(new Phrase(displayFormat(amountPV), microssfont));
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
								  //cell = new PdfPCell(new Phrase(format.format(cutVendor[c].doubleValue()), microssfont));
							cell = new PdfPCell(new Phrase(displayFormat(cutVendor[c].doubleValue()), microssfont));
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
		
						 //cell = new PdfPCell(new Phrase(format.format(cutComp), microssfont));
				cell = new PdfPCell(new Phrase(displayFormat(cutComp), microssfont));
						 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
						cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
						cell.setBorderColor(borderColor);
						cell.setFixedHeight(21);
						cell.setPaddingTop(3);
						cell.setPaddingBottom(5);
						 cell.setColspan(cutCLength);
						 cell.setBorder(15);
						 table.addCell(cell);									
						 //------================================================================================================-----//
	
						line++; 
						totalLine++;
						
						if (totalLine>=25) {
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
							while (totalLine<27) {
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

						   genHeaderPage(table,headerReport,currDate,vendorCut,iVendor,vendorName,markupPay,microssfont,microssfont_HD,microssfont_MINI,microssfont_BOLD,pvNo,cpNo);
						   totalLine += 8;
						   						   
						}						
			  } // end while					
								
					
					
			 //------============================================ Print Total Line ==============================================-----//						 
			 cell = new PdfPCell(new Phrase("รวมเป็นเงิน", microssfont));
			 cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			 cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
 			 cell.setBorderColor(borderColor);
			 cell.setPaddingBottom(5);
			 cell.setColspan(noLength+vendorLength+countDocLength);			
			 cell.setBorder(0);
			 //cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
			 table.addCell(cell);			   	   
			 //cell = new PdfPCell(new Phrase(format.format(totalWage), microssfont));
			cell = new PdfPCell(new Phrase(displayFormat(totalWage), microssfont));
			 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			 cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingBottom(5);
			cell.setBorderColor(borderColor);
			 cell.setColspan(wageLength);
			 cell.setBorder(15);
			 //cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
			 table.addCell(cell);			   
			 //cell = new PdfPCell(new Phrase(format.format(totalGoods), microssfont));
			cell = new PdfPCell(new Phrase(displayFormat(totalGoods), microssfont));
			 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			 cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingBottom(5);
			cell.setBorderColor(borderColor);
			 cell.setColspan(goodsLength); 
			 cell.setBorder(15);
			 //cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
			 table.addCell(cell);			   
			 //cell = new PdfPCell(new Phrase(format.format(totalPay), microssfont));
			cell = new PdfPCell(new Phrase(displayFormat(totalPay), microssfont));
			 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			 cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingBottom(5);
			cell.setBorderColor(borderColor);
			 cell.setColspan(payLength);
			 cell.setBorder(15);
			 //cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
			 table.addCell(cell);			   
			 //cell = new PdfPCell(new Phrase(format.format(totalPV), microssfont));
			cell = new PdfPCell(new Phrase(displayFormat(totalPV), microssfont));
			 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			 cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingBottom(5);
			cell.setBorderColor(borderColor);
			 cell.setColspan(pvLength);
			 cell.setBorder(15);
			 cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
			 table.addCell(cell);		
			
			 for (int c=0;c<vendorCut.size();c++) {	   
					 //cell = new PdfPCell(new Phrase(format.format(sumCutVendor[c].doubleValue()), microssfont));
				cell = new PdfPCell(new Phrase(displayFormat(sumCutVendor[c].doubleValue()), microssfont));
				      cell.setBorderColor(borderColor);
		 		      cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
					  cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
				      cell.setPaddingBottom(5);
					  cell.setColspan(vPerCol+(c==vendorCut.size()-1 ? overflowLength : 0));
					  cell.setBorder(15);
					  cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
					  table.addCell(cell);
			 }
		
			 //cell = new PdfPCell(new Phrase(format.format(totalCutCompany), microssfont));
			cell = new PdfPCell(new Phrase(displayFormat(totalCutCompany), microssfont));
			 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			 cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingBottom(5);
			cell.setBorderColor(borderColor);
			 cell.setColspan(cutCLength);
			 cell.setBorder(15);
			 cell.setBackgroundColor(new Color(LIGHT_GRAY_COLOR));
			 table.addCell(cell);									
			 //------========================================================================================================-----//					


			//------======================================= Print Total Line with 17% ============================================-----//						
			cell = new PdfPCell(new Phrase("รวมค่าดำเนินการ "+markupPay+" %", microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setBorderColor(borderColor);
			cell.setPaddingBottom(5);
			cell.setColspan(noLength+vendorLength+countDocLength);			
			cell.setBorder(0);
			table.addCell(cell);			   	   
			
			//cell = new PdfPCell(new Phrase(format.format(totalWage+grandTotalWage), microssfont));			
			cell = new PdfPCell(new Phrase(displayFormat(totalWage+grandTotalWage), microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		    cell.setPaddingBottom(5);
		    cell.setBorderColor(borderColor);
			cell.setColspan(wageLength);
			cell.setBorder(15);
			table.addCell(cell);			   
			//cell = new PdfPCell(new Phrase(format.format(totalGoods+grandTotalPrice), microssfont));	
			//cell = new PdfPCell(new Phrase(displayFormat(totalGoods+grandTotalPrice), microssfont));

			t_pergood = (totalGoods*Double.parseDouble(markupPay))/100; 	
			/*System.out.println("totalGoods= "+totalGoods);
			System.out.println("markupPay ="+markupPay);
			System.out.println("t_pergood= "+t_pergood);*/
			   
			t_good = totalGoods + t_pergood;
			
			//System.out.println("t_good= "+t_good);
			

			//cell = new PdfPCell(new Phrase(doString.displayNumber("#,###,###.00", t_good), microssfont));
			cell = new PdfPCell(new Phrase(displayFormat(totalGoods+grandTotalPrice), microssfont));	
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		    cell.setPaddingBottom(5);
		    cell.setBorderColor(borderColor);
			cell.setColspan(goodsLength);
			cell.setBorder(15);
			table.addCell(cell);			   
			//cell = new PdfPCell(new Phrase(format.format(totalPay+grandTotalWage+grandTotalPrice), microssfont));			
			//cell = new PdfPCell(new Phrase(displayFormat(totalPay+grandTotalWage+grandTotalPrice), microssfont));
			cell = new PdfPCell(new Phrase(displayFormat(totalPV), microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		   cell.setPaddingBottom(5);
		   cell.setBorderColor(borderColor);
			cell.setColspan(payLength);
			cell.setBorder(15);
			table.addCell(cell);			   
			cell = new PdfPCell(new Phrase("", microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		   cell.setPaddingBottom(5);
		   cell.setBorderColor(borderColor);
			cell.setColspan(pvLength+totalCutVLength+cutCLength);
			cell.setBorder(15);
			table.addCell(cell);									
			//------========================================================================================================-----//		

			//------================================== Special Summary for LH ==========================================-----//
			double sumWageLH1 = 0.0;
			double sumGoodsLH1 = 0.0;
			double sumPayLH1 = 0.0;
			double sumPvLH1 = 0.0;
			double sumWageLH2 = 0.0;
			double sumGoodsLH2 = 0.0;
			double sumPayLH2 = 0.0;
			double sumPvLH2 = 0.0; 
									
			sql.delete(0,sql.length());
			sql.append(" select a.i_type_cutlck,b.i_ven_cut,sum(q_wage_unit * z_wage_price) sum_wage,b.f_contr, ")
				  .append(" sum(q_good_unit * z_good_price) sum_goods, ")
				  .append(" sum(z_amount_pay) sum_amount_pay, sum(z_amount_pv) sum_amount_pv ")
				  .append(" from lan:serv_dochd a,lan:serv_payment b ")
				  .append(" where b.i_docno=a.i_docno and a.f_status in ('OPN','CLS') and b.f_itmstatus='CLS' ")
				  .append(" and b.i_ven_cut='999999' ")
				  .append(condition)			     
			      .append(" group by b.i_ven_cut,a.i_type_cutlck,b.f_contr ")
				  .append(" order by b.i_ven_cut ");		  
				  
			rs1 = stmt1.executeQuery(sql.toString());
			while (rs1.next()) {
				String fContr = doString.checkString(rs1.getString("f_contr"),"");
				String typeCut = doString.checkString(rs1.getString("i_type_cutlck"),"");
		         //typeCut.equals("1") || typeCut.equals("2") || typeCut.equals("3")) && 
				if (fContr.equalsIgnoreCase("Y")) {
					//R8 only
					sumWageLH2 += rs1.getDouble("sum_wage");
					sumGoodsLH2 += rs1.getDouble("sum_goods");
					sumPayLH2 += rs1.getDouble("sum_amount_pay");
					sumPvLH2 += rs1.getDouble("sum_amount_pv");
				} else {
					//LH respone
					sumWageLH1 += rs1.getDouble("sum_wage");
					sumGoodsLH1 += rs1.getDouble("sum_goods");
					sumPayLH1 += rs1.getDouble("sum_amount_pay");
					sumPvLH1 += rs1.getDouble("sum_amount_pv");
				}
 
			} // end while rs1
			rs1.close();
			
							  
	   	   
			cell = new PdfPCell(new Phrase("", microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
		   cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		   cell.setBorderColor(borderColor);
		   cell.setFixedHeight(21);
		   cell.setPaddingTop(3);
		   cell.setPaddingBottom(5);
			cell.setColspan(100);
			cell.setBorder(0);
			table.addCell(cell);				

			cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(companyName), microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
		   cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		   cell.setBorderColor(borderColor);
		   cell.setFixedHeight(21);
		   cell.setPaddingTop(3);
		   cell.setPaddingBottom(5);
			cell.setColspan(vendorLength);
			cell.setBorder(0);
			table.addCell(cell);	
			cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(" (รับผิดชอบ) "), microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
		   cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		   cell.setBorderColor(borderColor);
		   cell.setFixedHeight(21);
		   cell.setPaddingTop(3);
		   cell.setPaddingBottom(5);
			cell.setColspan(noLength+countDocLength);
			cell.setBorder(0);
			table.addCell(cell);				
			//cell = new PdfPCell(new Phrase(format.format(sumWageLH1), microssfont));
			cell = new PdfPCell(new Phrase(displayFormat(sumWageLH1), microssfont));			
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		   cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		   cell.setBorderColor(borderColor);
		   cell.setFixedHeight(21);
		   cell.setPaddingTop(3);
		   cell.setPaddingBottom(5);
			cell.setColspan(wageLength);
			cell.setBorder(0);
			table.addCell(cell);			   
			//cell = new PdfPCell(new Phrase(format.format(sumGoodsLH1), microssfont));
			cell = new PdfPCell(new Phrase(displayFormat(sumGoodsLH1), microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		   cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		   cell.setBorderColor(borderColor);
		   cell.setFixedHeight(21);
		   cell.setPaddingTop(3);
		   cell.setPaddingBottom(5);
			cell.setColspan(goodsLength);
			cell.setBorder(0);
			table.addCell(cell);			   
			//cell = new PdfPCell(new Phrase(format.format(sumPayLH1), microssfont));
			cell = new PdfPCell(new Phrase(displayFormat(sumPayLH1), microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		   cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		   cell.setBorderColor(borderColor);
		   cell.setFixedHeight(21);
		   cell.setPaddingTop(3);
		   cell.setPaddingBottom(5);
			cell.setColspan(payLength);
			cell.setBorder(0);
			table.addCell(cell);			   
			//cell = new PdfPCell(new Phrase(format.format(sumPvLH1), microssfont));
			cell = new PdfPCell(new Phrase(displayFormat(sumPvLH1), microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		   cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		   cell.setBorderColor(borderColor);
		   cell.setFixedHeight(21);
		   cell.setPaddingTop(3);
		   cell.setPaddingBottom(5);
			cell.setColspan(pvLength);
			cell.setBorder(0);
			table.addCell(cell);		
			
			for (int c=0;c<vendorCut.size();c++) {	   
					 cell = new PdfPCell(new Phrase("", microssfont));
					 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				   cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				   cell.setBorderColor(borderColor);
				   cell.setFixedHeight(21);
				   cell.setPaddingTop(3);
				   cell.setPaddingBottom(5);
					 cell.setColspan(vPerCol+(c==vendorCut.size()-1 ? overflowLength : 0));
					 cell.setBorder(0);
					 table.addCell(cell);
			}
		
			cell = new PdfPCell(new Phrase("", microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		   cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		   cell.setBorderColor(borderColor);
		   cell.setFixedHeight(21);
		   cell.setPaddingTop(3);
		   cell.setPaddingBottom(5);
			cell.setColspan(cutCLength);
			cell.setBorder(0);
			table.addCell(cell);			
			
			
			cell = new PdfPCell(new Phrase("", microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
		   cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		   cell.setBorderColor(borderColor);
		   cell.setFixedHeight(21);
		   cell.setPaddingTop(3);
		   cell.setPaddingBottom(5);
			cell.setColspan(vendorLength);
			cell.setBorder(0);
			table.addCell(cell);	
			cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(" (เข้าเงื่อนไข R8) "), microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
		   cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		   cell.setBorderColor(borderColor);
		   cell.setFixedHeight(21);
		   cell.setPaddingTop(3);
		   cell.setPaddingBottom(5);
			cell.setColspan(noLength+countDocLength);
			cell.setBorder(0);
			table.addCell(cell);					
			//cell = new PdfPCell(new Phrase(format.format(sumWageLH2), microssfont));
			cell = new PdfPCell(new Phrase(displayFormat(sumWageLH2), microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		   cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		   cell.setBorderColor(borderColor);
		   cell.setFixedHeight(21);
		   cell.setPaddingTop(3);
		   cell.setPaddingBottom(5);
			cell.setColspan(wageLength);
			cell.setBorder(0);
			table.addCell(cell);			   
			//cell = new PdfPCell(new Phrase(format.format(sumGoodsLH2), microssfont));
			cell = new PdfPCell(new Phrase(displayFormat(sumGoodsLH2), microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		   cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		   cell.setBorderColor(borderColor);
		   cell.setFixedHeight(21);
		   cell.setPaddingTop(3);
		   cell.setPaddingBottom(5);
			cell.setColspan(goodsLength);
			cell.setBorder(0);
			table.addCell(cell);			   
			//cell = new PdfPCell(new Phrase(format.format(sumPayLH2), microssfont));
			cell = new PdfPCell(new Phrase(displayFormat(sumPayLH2), microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		   cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		   cell.setBorderColor(borderColor);
		   cell.setFixedHeight(21);
		   cell.setPaddingTop(3);
		   cell.setPaddingBottom(5);
			cell.setColspan(payLength);
			cell.setBorder(0);
			table.addCell(cell);			   
			//cell = new PdfPCell(new Phrase(format.format(sumPvLH2), microssfont));
			cell = new PdfPCell(new Phrase(displayFormat(sumPvLH2), microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		   cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		   cell.setBorderColor(borderColor);
		   cell.setFixedHeight(21);
		   cell.setPaddingTop(3);
		   cell.setPaddingBottom(5);
			cell.setColspan(pvLength);
			cell.setBorder(0);
			table.addCell(cell);		
			
			for (int c=0;c<vendorCut.size();c++) {	   
					 cell = new PdfPCell(new Phrase("", microssfont));
					 cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				   cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				   cell.setBorderColor(borderColor);
				   cell.setFixedHeight(21);
				   cell.setPaddingTop(3);
				   cell.setPaddingBottom(5);
					 cell.setColspan(vPerCol+(c==vendorCut.size()-1 ? overflowLength : 0));
					 cell.setBorder(0);
					 table.addCell(cell);
			}
		
			cell = new PdfPCell(new Phrase("", microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		   cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		   cell.setBorderColor(borderColor);
		   cell.setFixedHeight(21);
		   cell.setPaddingTop(3);
		   cell.setPaddingBottom(5);
			cell.setColspan(cutCLength);
			cell.setBorder(0);
			table.addCell(cell);			
			//------================================================================================================-----//






			document.add(table);		
			document.newPage();
								
		} catch (Exception e) { 
			System.out.println("SERV_PrintRerort7Servlet Error : "+e.getMessage()); 
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
		nowpage = 0;		

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


			
			 //----==================== Get Markup Pay from SERV_XSTD  ====================-----//
			 /*
			 markupPay = 0.00;
			 sql.delete(0,sql.length());
			 sql.append(" select * from lan:serv_xstd where i_type='02' ");
			 rs = stmt.executeQuery(sql.toString());
			 if (rs.next()) {
				markupPay = rs.getDouble("p_amount");
			 }
			 rs.close();*/
			//---=========================================================================----//    
			
			
			
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


		   String headerReport = "";
		   companyName = "";
		   betweenDate = "";
		   	
		   		   	
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
				sql.append(" select * from lan:acxprojt a  where  ")
				      .append(" a.i_company='"+(selProj.length()>0 ? selProj.substring(0,2) : "")+"' ")
				      .append(" and a.i_project='"+(selProj.length()>0 ? selProj.substring(3,6) : "")+"'  ");
				rs = stmt.executeQuery(sql.toString());
				if (rs.next()) {
					projectName = doString.checkString(rs.getString("n_project"),"");
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

				if (projectName.length()>0) headerReport += " โครงการ : "+selProj+" - "+projectName+"\n";
				if (startDate.length()>0 && endDate.length()>0)  {
					int syear = Integer.parseInt(startDate.substring(0,4));
					int eyear = Integer.parseInt(endDate.substring(0,4));
					if (syear<2400) syear += 543;
					if (eyear<2400) eyear += 543;
					startDate = startDate.substring(8,10)+"/"+startDate.substring(5,7)+"/"+Integer.toString(syear);
					endDate = endDate.substring(8,10)+"/"+endDate.substring(5,7)+"/"+Integer.toString(eyear);  			    	  
					betweenDate = " วันอนุมัติจ่าย ตั้งแต่ "+startDate+"  ถึง "+endDate+"\n";
				}
				//if (vendorName.length()>0) headerReport += " ผู้รับเหมาซ่อม : "+vendorName+"\n";
		   }
		   

		   //----================= Get p_add_pay ===============----//
		   String markupPay = "";		   
		   if (selProj.trim().length()>0 && iVendor.trim().length()>0) {
				sql.delete(0,sql.length());
				sql.append(" select * from lan:serv_venprj where ")
					  .append(" i_company='").append(selProj.length()>=6 ? selProj.substring(0,2) : "").append("' ")
					  .append(" and i_project='").append(selProj.length()>=6 ? selProj.substring(3,6) : "").append("' ")
					  .append(" and i_vendor='").append(iVendor).append("' ");
				rs = stmt.executeQuery(sql.toString());
				if (rs.next()) {
				   double pAddPay = rs.getDouble("p_add_pay");
				   markupPay = doString.displayNumber("##0.0",pAddPay);
				}				        
				rs.close();	
		   }


		  genVendorData(document,writer,conn,iVendor,companyName,headerReport,vendorCut,markupPay,microssfont,microssfont_HD,microssfont_MINI,microssfont_BOLD);
		  headerReport = "";
			
			

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
			 System.err.println("error SERV_PrintRerort7Servlet  DOCUMENT: " + de.getMessage());
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
