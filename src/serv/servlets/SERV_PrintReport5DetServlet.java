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
public class SERV_PrintReport5DetServlet extends DBServlet  {
	/*
	private String selProj = "";
	private String iVendor = "";
	private String startDate = "";
	private String endDate = "";
	private String condition = "";	
	private double markupPay = 0.0;
	private int rowPerPage = 30;
	

	private String projectName = ""; 
	private String cutVendorId = "";
	*/	
	private int nowPage = 0;

	private Document document = null;
	private Font microssfont = null;
	private Font microssfont_MINI = null;
	private Font microssfont_BOLD = null;
	private Font microssfont_HD = null;
	
	private int LIGHT_GRAY_COLOR = 15329769;
	private int DARK_GRAY_COLOR = 13882323;
	private Color  borderColor = new Color(153,153,153);
	
	
	//----- init Column width ------//
	int noWidth = 3;
	int docNoWidth = 8;
	int iLockWidth = 4;
	int iModelWidth = 5;
	int dataWidth = 2; // 2 * 12 = 24
	int keyinWidth = 5;
	int openWidth = 5;
	int appointWidth = 5;
	int estCloseWidth = 5;
	int completeWidth = 5;
	int betweenWidth = 5;
	int amountWidth = 6;
	int cut17Width = 6;
	int cut35Width = 6;
	int cutLHWidth = 6;
	int flagWidth = 2;
	
	
	
	public Integer[] newIntegerArray(int size) {
		Integer data[] = new Integer[size];
		for (int l=0;l<size;l++) {
			  data[l] = new Integer(0);
		}

		return data;
	}
  

	public Double[] newDoubleArray(int size) {
		Double data[] = new Double[size];
		for (int l=0;l<size;l++) {
			  data[l] = new Double(0.0);
		}

		return data;
	}	
	
	public String convertTimestamp(SERV_CommonData common,Timestamp data) {
		String result = "";
		Calendar cal = Calendar.getInstance();
		if (data!=null)  {
			cal.setTime(data);      
			result = common.getDateFromCalendar(cal);
			if (result.trim().length()==10) result = result.trim().substring(0,6)+result.trim().substring(8,10);
		}

		return result;
	}	
	
	
	public int printHeaderPage(PdfPTable table,String currDate,String displayReport,String[] projList,Vector projectName,Integer[] monthList,Integer[] yearList) {
       nowPage++;
       String headerReport = "";
       DecimalFormat format = new DecimalFormat("###,##0.00");				
	   String shortMonth[] = new String[] {"","ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค."};
	   int totalLine = 0;
		     

		PdfPCell cell = new PdfPCell(new Phrase("หน้า "+nowPage,microssfont));
		cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setColspan(100);
		cell.setBorder(0);
		table.addCell(cell);
		
		cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("บริษัท แลนด์ แอนด์ เฮ้าส์ จำกัด (มหาชน) \n รายละเอียดใบแจ้งซ่อม "), microssfont_HD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setColspan(100);
		cell.setBorder(0);
		table.addCell(cell);
		cell = new PdfPCell(new Phrase(displayReport, microssfont_HD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setColspan(50);
		cell.setBorder(0);
		table.addCell(cell);			
		cell = new PdfPCell(new Phrase("แบบรายงาน : SERV_PrintReport5Det ,  "+currDate, microssfont));
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
		cell = new PdfPCell(new Phrase(" ", microssfont_MINI));
		cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setColspan(100);
		cell.setBorder(0);
		table.addCell(cell);	
		totalLine += 8;
		
		
		
		
		//----============= Prnit All Project to select ==============------//
		int line = 0;
		for (int p=0;p<projectName.size();p++) {
			   String projName = (String) projectName.elementAt(p);

				if (line==0) {
					cell = new PdfPCell(new Phrase("โครงการ", microssfont_BOLD));
					cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
					cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
					cell.setPaddingTop(4);
					cell.setPaddingLeft(4);
					cell.setPaddingBottom(6);
					cell.setBorderColor(borderColor);		
					cell.setColspan(12);
					cell.setBorder(0);
					table.addCell(cell);
					totalLine++;
				} else if (line%4==0 && line!=0) {
					cell = new PdfPCell(new Phrase(" ", microssfont_BOLD));
					cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
					cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
					cell.setPaddingTop(4);
					cell.setPaddingLeft(4);
					cell.setPaddingBottom(6);
					cell.setBorderColor(borderColor);		
					cell.setColspan(12);
					cell.setBorder(0);
					table.addCell(cell);
					totalLine++;
			   }
			   
			   
				cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(projName) , microssfont_BOLD));
				cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setPaddingLeft(4);
				cell.setPaddingBottom(6);
				cell.setBorderColor(borderColor);		
				cell.setColspan(22);
				cell.setBorder(0);
				table.addCell(cell);
			   
			   line++;
		   }
		   
		   while (line%4!=0) {
				cell = new PdfPCell(new Phrase(" ", microssfont_BOLD));
				cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setPaddingTop(4);
				cell.setPaddingLeft(4);
				cell.setPaddingBottom(6);
				cell.setBorderColor(borderColor);		
				cell.setColspan(22);
				cell.setBorder(0);
				table.addCell(cell);
			    line++;
		   } // end while		   

		cell = new PdfPCell(new Phrase(" ", microssfont_MINI));
		cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setColspan(100);
		cell.setBorder(0);
		table.addCell(cell);	 
				
	   
		   
		//----============================ Add Header Table ====================================-----//
		cell = new PdfPCell(new Phrase("No", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(noWidth);
		cell.setBorder(13);
		table.addCell(cell);
		
		cell = new PdfPCell(new Phrase("เลขที่ใบแจ้งซ่อม", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(docNoWidth);
		cell.setBorder(13);
		table.addCell(cell);
		
		cell = new PdfPCell(new Phrase("แปลง", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(iLockWidth);
		cell.setBorder(13);
		table.addCell(cell);
		
		cell = new PdfPCell(new Phrase("เลขที่บ้าน", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(iModelWidth);
		cell.setBorder(13);
		table.addCell(cell);

		cell = new PdfPCell(new Phrase("รายละเอียดตามหมวดงาน\n(จำนวนรายการ)", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(dataWidth*12);
		cell.setBorder(13);
		table.addCell(cell);		
		
		cell = new PdfPCell(new Phrase("วันที่", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(keyinWidth+openWidth+appointWidth+estCloseWidth+completeWidth);
		cell.setBorder(13);
		table.addCell(cell);		
		
		cell = new PdfPCell(new Phrase("ดำเนินการ", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(betweenWidth);
		cell.setBorder(13);
		table.addCell(cell);				
		
		cell = new PdfPCell(new Phrase("รวมค่า", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(amountWidth);
		cell.setBorder(13);
		table.addCell(cell);	
		
		cell = new PdfPCell(new Phrase("ตัดเงินผู้รับเหมา", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(cut17Width+cut35Width+cutLHWidth);
		cell.setBorder(13);
		table.addCell(cell);	
		
		cell = new PdfPCell(new Phrase("F", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(flagWidth);
		cell.setBorder(13);
		table.addCell(cell);			
		
		
									
		
		
		
		cell = new PdfPCell(new Phrase(" ", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(noWidth);
		cell.setBorder(14);
		table.addCell(cell);
		
		cell = new PdfPCell(new Phrase(" ", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(docNoWidth);
		cell.setBorder(14);
		table.addCell(cell);
		
		cell = new PdfPCell(new Phrase(" ", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(iLockWidth);
		cell.setBorder(14);
		table.addCell(cell);
		
		cell = new PdfPCell(new Phrase(" ", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(iModelWidth);
		cell.setBorder(14);
		table.addCell(cell);
		
		for (int i=1;i<=12;i++) {
				cell = new PdfPCell(new Phrase(doString.checkString(Integer.toString(i)), microssfont_BOLD));
				cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setPaddingTop(4);
				cell.setPaddingLeft(4);
				cell.setPaddingBottom(6);
				cell.setBorderColor(borderColor);		
				cell.setColspan(dataWidth);
				cell.setBorder(15);
				table.addCell(cell);			
		}	
		
		cell = new PdfPCell(new Phrase("รับเรื่อง", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(keyinWidth);
		cell.setBorder(15);
		table.addCell(cell);		
		
		cell = new PdfPCell(new Phrase("Open Job", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(openWidth);
		cell.setBorder(15);
		table.addCell(cell);	
		
		cell = new PdfPCell(new Phrase("นัดซ่อม", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(appointWidth);
		cell.setBorder(15);
		table.addCell(cell);	
		
		cell = new PdfPCell(new Phrase("ประมาณ\nการ", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(estCloseWidth);
		cell.setBorder(15);
		table.addCell(cell);	
		
		cell = new PdfPCell(new Phrase("Complete Task", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(completeWidth);
		cell.setBorder(15);
		table.addCell(cell);					
		
		cell = new PdfPCell(new Phrase("ถึงปัจจุบัน", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(betweenWidth);
		cell.setBorder(14);
		table.addCell(cell);				
		
		cell = new PdfPCell(new Phrase("ดำเนินการ 17%", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(amountWidth);
		cell.setBorder(14);
		table.addCell(cell);	
		
		cell = new PdfPCell(new Phrase("17%", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(cut17Width);
		cell.setBorder(15);
		table.addCell(cell);	

		cell = new PdfPCell(new Phrase("35%", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(cut35Width);
		cell.setBorder(15);
		table.addCell(cell);	

		cell = new PdfPCell(new Phrase("LH", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(cutLHWidth);
		cell.setBorder(15);
		table.addCell(cell);	
		
		cell = new PdfPCell(new Phrase(" ", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(flagWidth);
		cell.setBorder(14);
		table.addCell(cell);					
		
		
		//----===========================================================================================-----//
		
		return totalLine;			 
	}
		
		
		
/*
	public void printDataList(String label,PdfPTable table,Object[] data,String reportType,String dataType) {
	   String headerReport = "";
	   DecimalFormat format1 = new DecimalFormat("#,###,##0 ");				
	   DecimalFormat format2 = new DecimalFormat("#,###,##0.00 ");				

		   
		//----============================ Add Header Table ====================================-----//
		PdfPCell cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(label), microssfont));
		cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(detailLength);
		cell.setBorder(15);
		table.addCell(cell);

		double totalData = 0;
		int loop = 0;
		for (int i=0;i<12;i++) {
			    String monthCol = "";		
			    String showData = "";
			    if (data!=null && i<Integer.parseInt(reportType)) {
			    	if (dataType.equals("I")) {
			    		Integer tmp = (Integer) data[i]; 
						showData = format1.format(tmp.intValue());
						totalData += tmp.intValue();			    	
			    	} else {
						Double tmp = (Double) data[i]; 
						showData = format2.format(tmp.doubleValue());
						totalData += tmp.doubleValue();			    	
			    	}
			    } else {
			    	showData = " ";
			    }
			    		
				cell = new PdfPCell(new Phrase(showData, microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setPaddingTop(4);
				cell.setPaddingLeft(4);
				cell.setPaddingBottom(6);
				cell.setBorderColor(borderColor);		
				cell.setColspan(dataLength);
				cell.setBorder(15);
				table.addCell(cell);			
			   	
				loop++;
		}	
		
		while (loop<12) {
			cell = new PdfPCell(new Phrase("", microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);		
			cell.setColspan(dataLength);
			cell.setBorder(15);
			table.addCell(cell);		
			loop++;
		}
		
		String showTotal = " ";
		if (data!=null) {
			if (dataType.equals("I")) {
				showTotal = format1.format(totalData);
			} else {
				showTotal = format2.format(totalData);
			}
		}
		cell = new PdfPCell(new Phrase(showTotal, microssfont));
		cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(dataLength);
		cell.setBorder(15);
		table.addCell(cell);		
		//----===========================================================================================-----//

	 
	}
*/	
	
	public int checkEndPage(int line,Document document,PdfWriter writer,PdfPTable table,String currDate,String displayReport,String[] projList,Vector projectName,Integer[] monthList,Integer[] yearList) throws Exception {
		line++;
		if (line>=25) {
			Rectangle page = document.getPageSize();
			PdfPTable foot = new PdfPTable(1);
			PdfPCell pcell = new PdfPCell(new Phrase(" มีหน้าต่อไป      ", microssfont));
			pcell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			pcell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			pcell.setBorder(0);
			foot.addCell(pcell);				
			foot.setTotalWidth(page.width() - document.leftMargin() - document.rightMargin());
			foot.writeSelectedRows(0, 1, document.leftMargin(), document.bottomMargin()+20,writer.getDirectContent());						
			
			//document.add(table);
			document.newPage();
			table = new PdfPTable(100);
			table.setWidthPercentage(100);
			line = printHeaderPage(table,currDate,displayReport,projList,projectName,monthList,yearList);
			document.add(table);
			line++;
		}
		
		return line;	
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
		DecimalFormat format1 = new DecimalFormat("#,###,##0 ");				
		DecimalFormat format2 = new DecimalFormat("#,###,##0.00 ");		
				

		String monthReport = doString.checkString(req.getParameter("month_report"),"0");
		String yearReport = doString.checkString(req.getParameter("year_report"),"0");
		String reportType = doString.checkString(req.getParameter("report_type"),"0");
		String[] projList = req.getParameterValues("sel_proj");
		
		String keyDetail = doString.checkString(req.getParameter("key_detail"),"");
		String monthDetail = doString.checkString(req.getParameter("month_detail"),"0");
		String yearDetail = doString.checkString(req.getParameter("year_detail"),"0");		
	
		
		nowPage = 0;


		//----============ Declare Variables for input data ===========----//
		 StringBuffer sql = new StringBuffer();
		 Connection conn = null;
		 Statement stmt = null;
		 ResultSet rs = null;
		 SERV_CommonData common = null;


		 try {

			 //----============ Initialize Variable ============----//
			 if (ds == null) getDS();
			 conn = ds.getConnection();
			 conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			 conn.setAutoCommit(true);
			 stmt = conn.createStatement();
			 common = new SERV_CommonData(conn);
			 //----=======================================----//
			 
			 
			Calendar now = Calendar.getInstance(Locale.ENGLISH); 
			String currDate = str.createID(now.get(Calendar.DATE),2)+"/"+str.createID(now.get(Calendar.MONTH)+1,2);
			int nYear = now.get(Calendar.YEAR);
			if (nYear<2500) nYear += 543;
			currDate += "/"+str.createID(nYear,4);
			currDate += " , "+str.createID(now.get(Calendar.HOUR_OF_DAY),2)+":"+str.createID(now.get(Calendar.MINUTE),2);		
			 



			 //---=========== Month Initilize =========----//
			 String thaiMonth[] = new String[] {"","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
			 String showMonth = thaiMonth[Integer.parseInt(monthReport)];	 
			 String showYear = Integer.toString(Integer.parseInt(yearReport)+543);
			 String startQueryDate = "";
			 String endQueryDate = "";

			 Integer monthList[] = newIntegerArray(12);
			 Integer yearList[] = newIntegerArray(12);
			 now.set(Integer.parseInt(yearReport),Integer.parseInt(monthReport)-1,1,0,0,0);

			 for (int i=0;i<Integer.parseInt(reportType);i++) {
				   int month = now.get(Calendar.MONTH)+1;
				   int year = now.get(Calendar.YEAR);
				   if (year>2400) year -= 543;
			  	
				   if (i==0)	 {
					  startQueryDate = str.createID(year,4)+"-"+str.createID(month,2)+"-01";
				   } 
				  endQueryDate = str.createID(year,4)+"-"+str.createID(month,2)+"-01";

				   now.add(Calendar.MONTH,-1);
				   monthList[i] = new Integer(month);
				   yearList[i] = new Integer(year+543);
			 } // end for
			
			

			  //-----============= Generate Query Project ==================----//
			  String queryProject = "";
			  Vector projectName = new Vector();
			  if (projList!=null) {
				  for (int i=0;i<projList.length;i++) {
						 String proj = doString.checkString(projList[i],"");  
						 if (queryProject.trim().length()>0) queryProject += " , ";
						 queryProject += " '"+proj+"' ";

						//---============= get Project Details ===============----//
						sql.delete(0,sql.length()); 
						sql.append(" select * from lan:acxprojt where i_company||':'||i_project='").append(proj).append("' ");
						rs = stmt.executeQuery(sql.toString());
						while (rs.next()) {
							 String nProject = doString.checkString(rs.getString("n_project"),"");
							 String iProj = str.replace(proj,":","-");
							 projectName.addElement(iProj+" "+nProject);	
						} // end while
						rs.close();

				  } // end for

			  } else {
				  queryProject = " 'NODATA' ";
			  }
			  

			//------=================== generate Condition ======================----//
			String condition = "";
			String label = "";
			if (keyDetail.equalsIgnoreCase("CURRENT")) {
				condition += " and month(a.d_keyin)="+monthDetail+" and year(a.d_keyin)="+yearDetail+" ";
				label = "ใบแจ้งซ่อมที่เกิดในเดือน";
			} else if (keyDetail.equalsIgnoreCase("COMPLETE")) {
				condition += " and month(a.d_complete)="+monthDetail+" and year(a.d_complete)="+yearDetail+" ";
				label = "ซ่อมเสร็จ (Complete แล้ว)";
			} else if (keyDetail.equalsIgnoreCase("CANCEL")) {
				condition += " and month(a.d_cancel)="+monthDetail+" and year(a.d_cancel)="+yearDetail+" ";
				label = "ใบแจ้งซ่อมที่ยกเลิกในเดือน";
			} else if (keyDetail.equalsIgnoreCase("INTIME")) {
				condition += " and a.f_appoint='Y' and a.d_complete is not null ";
				condition += " and month(a.d_complete)="+monthDetail+" and year(a.d_complete)="+yearDetail+" ";
				label = "ซ่อมเสร็จ (ตามกำหนดนัดหมาย) - ตามกำหนดนัดหมาย";
			} else if (keyDetail.equalsIgnoreCase("OVERTIME")) {
				condition += " and a.f_appoint='N' and a.d_complete is not null ";
				condition += " and month(a.d_complete)="+monthDetail+" and year(a.d_complete)="+yearDetail+" ";
				label = "ซ่อมเสร็จ (ตามกำหนดนัดหมาย) - เลยกำหนดนัดหมาย";
			} else if (keyDetail.equalsIgnoreCase("PAST_INTIME")) {
				condition += " and f_bf_past='N' ";
				label = "งานซ่อมคงค้างยกไป - ยังไม่เลยกำหนดนัดหมาย";
			} else if (keyDetail.equalsIgnoreCase("PAST_OVERTIME")) {
				condition += " and f_bf_past='Y' ";
				label = "งานซ่อมคงค้างยกไป - เลยกำหนดนัดหมาย";
			}
			//---==============================================================----//


			String displayReport = label+"  ,  เดือน "+showMonth+"   พ.ศ. "+showYear;
		
			
			
			//----================ Initialize Variables for create PDF =====================---//
			BaseFont bf = BaseFont.createFont(Constants.FONT_ANGSANA_NORMAL, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
			BaseFont bfb = BaseFont.createFont(Constants.FONT_ANGSANA_BOLD, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
			microssfont = new Font(bf, 12, Font.NORMAL);
			microssfont_MINI = new Font(bf, 10, Font.NORMAL);
			microssfont_BOLD = new Font(bfb, 10, Font.NORMAL);
			microssfont_HD = new Font(bfb, 14, Font.NORMAL);

			document = new Document(PageSize.A4.rotate(), 30, 30, 10, 10);
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			PdfWriter writer = PdfWriter.getInstance(document, baos);
			PdfContentByte cb = writer.getDirectContent();

			//PdfReader reader = new PdfReader(Constants.PDF_HEADER_TEMPLATE);
			//PdfImportedPage page1 = writer.getImportedPage(reader, 1);

			document.open();

			PdfPTable table = new PdfPTable(100);
			table.setWidthPercentage(100);
			PdfPCell cell;
		   		   	
			int line = 0;
		    line = printHeaderPage(table,currDate,displayReport,projList,projectName,monthList,yearList);
		    
			if (condition.trim().length()>0 && monthDetail.trim().length()>0 && yearDetail.trim().length()>0) {
				sql.delete(0,sql.length());
				sql.append(" select * from serv_rdet a where ")
					  .append(" a.i_company||':'||a.i_project in (").append(queryProject).append(") ")
					  .append(" and a.i_rep_type='01' and a.i_year="+(Integer.parseInt(yearDetail)+543)+" and a.i_month="+monthDetail+" ")
					  .append(condition).append(" order by a.i_docno ");
				rs = stmt.executeQuery(sql.toString());
				
					  int dataLine = 0;	
					  while (rs.next()) {
					  			dataLine++;
								String iDocNo = doString.checkString(rs.getString("i_docno"),"");
								String iLock = doString.checkString(rs.getString("i_lock"),"");
								String iModel = doString.checkString(rs.getString("i_model"),"");
								String flag = doString.checkString(rs.getString("pv_no"),"");
								if (flag.trim().length()>0) {
									flag = "Y";
								} else {
									flag = "N";
								}

								String keyinDate = convertTimestamp(common,rs.getTimestamp("d_keyin"));
								String openJobDate = convertTimestamp(common,rs.getTimestamp("d_open_job"));
								String appointDate = convertTimestamp(common,rs.getTimestamp("d_appoint"));
								String estCloseDate = convertTimestamp(common,rs.getTimestamp("d_est_close"));
								String completeDate = convertTimestamp(common,rs.getTimestamp("d_complete"));

								String zAmountPv = format2.format(rs.getDouble("z_amount_pv"));
								String cut17 = format2.format(rs.getDouble("z_cut_17"));
								String cut35 = format2.format(rs.getDouble("z_cut_35"));
								String cutLH = format2.format(rs.getDouble("z_cut_LH"));


								Timestamp complete = rs.getTimestamp("d_complete");
								Timestamp estClose = rs.getTimestamp("d_est_close");

								long dateDiff = 0;
								if (estClose!=null) {
									Calendar scal = Calendar.getInstance(Locale.ENGLISH);
									Calendar ecal = Calendar.getInstance(Locale.ENGLISH);

									if (complete!=null) {
										ecal.setTime(complete);
										scal.setTime(estClose);
									} else {
										ecal.set(Integer.parseInt(yearDetail),Integer.parseInt(monthDetail),1);
										ecal.add(Calendar.DATE,-1);
										scal.setTime(estClose);
									}

									dateDiff = ((ecal.getTime().getTime() - scal.getTime().getTime())/(1000*60*60*24));
								}



								//--------================ Print Data ===================-------//
								cell = new PdfPCell(new Phrase(Integer.toString(dataLine), microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);		
								cell.setColspan(noWidth);
								cell.setBorder(15);
								table.addCell(cell);
								
								cell = new PdfPCell(new Phrase(iDocNo, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
								cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);		
								cell.setColspan(docNoWidth);
								cell.setBorder(15);
								table.addCell(cell);										
								
								cell = new PdfPCell(new Phrase(iLock, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);		
								cell.setColspan(iLockWidth);
								cell.setBorder(15);
								table.addCell(cell);		

								cell = new PdfPCell(new Phrase(iModel, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);		
								cell.setColspan(iModelWidth);
								cell.setBorder(15);
								table.addCell(cell);		


								for (int d=1;d<=12;d++) {
									    String data = format1.format(rs.getInt("q_itmjob_"+str.createID(d,2)));
										cell = new PdfPCell(new Phrase(data, microssfont));
										cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
										cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
										cell.setPaddingTop(4);
										cell.setPaddingLeft(4);
										cell.setPaddingBottom(6);
										cell.setBorderColor(borderColor);		
										cell.setColspan(dataWidth);
										cell.setBorder(15);
										table.addCell(cell);										  
								}
								
								cell = new PdfPCell(new Phrase(keyinDate, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);		
								cell.setColspan(keyinWidth);
								cell.setBorder(15);
								table.addCell(cell);	
								
								cell = new PdfPCell(new Phrase(openJobDate, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);		
								cell.setColspan(openWidth);
								cell.setBorder(15);
								table.addCell(cell);	
								
								cell = new PdfPCell(new Phrase(appointDate, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);		
								cell.setColspan(appointWidth);
								cell.setBorder(15);
								table.addCell(cell);	
								
								cell = new PdfPCell(new Phrase(estCloseDate, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);		
								cell.setColspan(estCloseWidth);
								cell.setBorder(15);
								table.addCell(cell);	
								
								cell = new PdfPCell(new Phrase(completeDate, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);		
								cell.setColspan(completeWidth);
								cell.setBorder(15);
								table.addCell(cell);
						
								cell = new PdfPCell(new Phrase(format1.format(dateDiff), microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);		
								cell.setColspan(betweenWidth);
								cell.setBorder(15);
								table.addCell(cell);						
						
								cell = new PdfPCell(new Phrase(zAmountPv, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
								cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);		
								cell.setColspan(amountWidth);
								cell.setBorder(15);
								table.addCell(cell);			
														
								cell = new PdfPCell(new Phrase(cut17, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
								cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);		
								cell.setColspan(cut17Width);
								cell.setBorder(15);
								table.addCell(cell);		
													
								cell = new PdfPCell(new Phrase(cut35, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
								cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);		
								cell.setColspan(cut35Width);
								cell.setBorder(15);
								table.addCell(cell);			
								
								cell = new PdfPCell(new Phrase(cutLH, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
								cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);		
								cell.setColspan(cutLHWidth);
								cell.setBorder(15);
								table.addCell(cell);			
														
								cell = new PdfPCell(new Phrase(flag, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);		
								cell.setColspan(flagWidth);
								cell.setBorder(15);
								table.addCell(cell);																					
		

							    line = checkEndPage(line,document,writer,table,currDate,displayReport,projList,projectName,monthList,yearList);
								document.add(table);
								table = new PdfPTable(100);
								table.setWidthPercentage(100); 						     

					} // end while

				rs.close();

			} // end if condition 		    
		    
		    


			//----=========== Generate PDF ===============-----//
			document.add(table);
			document.close();
			res.setContentType("application/pdf");
			res.setContentLength(baos.size());
			ServletOutputStream outServ = res.getOutputStream();
			baos.writeTo(outServ);
			outServ.flush();
			
			//conn.commit();
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
				if (stmt != null) stmt.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");

	}

}
