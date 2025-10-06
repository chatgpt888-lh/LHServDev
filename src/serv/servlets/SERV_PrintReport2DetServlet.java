    package serv.servlets;

	import java.io.*;
	import java.text.DecimalFormat;
	import java.util.*;
import java.security.acl.LastOwnerException;
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
	public class SERV_PrintReport2DetServlet extends DBServlet  {
	

//		private String companyName = "";
//		private String projectName = ""; 
		private int nowPage = 0;
	
		private Document document = null;
		private Font microssfont = null;
		private Font microssfont_MINI = null;
		private Font microssfont_BOLD = null;
		private Font microssfont_BOLD_UNDERLINE = null;
		private Font microssfont_HD = null;
	
		private int LIGHT_GRAY_COLOR = 15329769;
		private int DARK_GRAY_COLOR = 13882323;
		private Color  borderColor = new Color(153,153,153);
	
	
		//----- init Column width ------//
		int noWidth = 3;
		int custWidth = 15;
		int telWidth = 7;
		int iLockWidth = 4;
		int iHouseWidth = 5;
		int qAreaWidth = 4;
		int iModelWidth = 5;
		
		int dLoiWidth = 4;
		int dCloseLawWidth = 4;
		int expireWidth = 4;
		int lastPaidWidth = 4;
		int qcDateWidth = 4;
		
		int vendWidth = 5;
		int estConstWidth = 8;
		int cutDescWidth = 3;
		int amountWidth = 7;
		int publicTypeWidth = 3;
		int publicAvgWidth = 4;
		int publicAmountWidth = 8;
	
	
	
		public Double[] newDoubleArray(int size) {
			Double result[] = new Double[size];
			for (int i=0;i<size;i++) {
				   result[i] = new Double(0.0);
			}

		   return result;
		}
		
		
		public String convertTimestamp(SERV_CommonData common,Timestamp data,int addType,int addVal) {
			String result = "";
			Calendar cal = Calendar.getInstance();
			if (data!=null)  {
				cal.setTime(data);
				if (addType>0) {
					cal.add(addType,addVal); 
				} 
				result = common.getDateFromCalendar(cal);
				if (result.trim().length()==10) result = result.trim().substring(0,6)+result.trim().substring(8,10);
			}

			return result;
		}		
	
	
		public void printHeaderPage(PdfPTable table,String currDate,String startDate,String endDate,String projectName,String companyName) {
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
			cell = new PdfPCell(new Phrase("", microssfont_MINI));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setColspan(100);
			cell.setBorder(0);
			table.addCell(cell);				


		   
			//----============================ Add Header Table ====================================-----//
			cell = new PdfPCell(new Phrase("No", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(0);
			cell.setBorderColor(borderColor);		
			cell.setColspan(noWidth);
			cell.setBorder(13);
			table.addCell(cell);		
			
			cell = new PdfPCell(new Phrase("ชื่อ - สกุล  /  โทรศัพท์", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(0);
			cell.setBorderColor(borderColor);
			cell.setColspan(custWidth+telWidth);
			cell.setBorder(13);
			table.addCell(cell);					
			
				   /*
			cell = new PdfPCell(new Phrase("ชื่อ - สกุล", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
			cell.setColspan(custWidth);
			cell.setBorder(13);
			table.addCell(cell);			   
			cell = new PdfPCell(new Phrase("โทรศัพท์", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
			cell.setColspan(telWidth);
			cell.setBorder(13);
			table.addCell(cell);		
			*/
			cell = new PdfPCell(new Phrase("แปลง", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(0);
			cell.setBorderColor(borderColor);
			cell.setColspan(iLockWidth);
			cell.setBorder(13);
			table.addCell(cell);			
			cell = new PdfPCell(new Phrase("บ้านเลขที่", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(0);
			cell.setBorderColor(borderColor);
			cell.setColspan(iHouseWidth);
			cell.setBorder(13);
			table.addCell(cell);			   
			cell = new PdfPCell(new Phrase("พื้นที่", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(0);
			cell.setBorderColor(borderColor);
			cell.setColspan(qAreaWidth);
			cell.setBorder(13);
			table.addCell(cell);			   
			cell = new PdfPCell(new Phrase("แบบบ้าน", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(0);
			cell.setBorderColor(borderColor);
			cell.setColspan(iModelWidth);
			cell.setBorder(13);
			table.addCell(cell);			   
			cell = new PdfPCell(new Phrase("วันที่", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(0);
			cell.setBorderColor(borderColor);
			cell.setColspan(dLoiWidth);
			cell.setBorder(13);
			table.addCell(cell);			   
			cell = new PdfPCell(new Phrase("วันที่โอน", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(0);
			cell.setBorderColor(borderColor);
			cell.setColspan(dCloseLawWidth);
			cell.setBorder(13);
			table.addCell(cell);			   
			cell = new PdfPCell(new Phrase("วันที่", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(0);
			cell.setBorderColor(borderColor);
			cell.setColspan(expireWidth);
			cell.setBorder(13);
			table.addCell(cell);			   
			cell = new PdfPCell(new Phrase("วันที่", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(0);
			cell.setBorderColor(borderColor);
			cell.setColspan(lastPaidWidth);
			cell.setBorder(13);
			table.addCell(cell);			   
			cell = new PdfPCell(new Phrase("วันที่", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(0);
			cell.setBorderColor(borderColor);
			cell.setColspan(qcDateWidth);
			cell.setBorder(13);
			table.addCell(cell);			 
			cell = new PdfPCell(new Phrase("ผู้รับเหมา", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(0);
			cell.setBorderColor(borderColor);
			cell.setColspan(vendWidth);
			cell.setBorder(13);			
			table.addCell(cell);			   
			cell = new PdfPCell(new Phrase("ราคา", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(0);
			cell.setBorderColor(borderColor);
			cell.setColspan(estConstWidth);
			cell.setBorder(13);			
			table.addCell(cell);		
			cell = new PdfPCell(new Phrase("รูปแบบ\nการตัดเงิน", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingTop(3);
			cell.setPaddingLeft(5);
			cell.setPaddingBottom(5);
			cell.setBorderColor(borderColor);
			cell.setColspan(cutDescWidth+amountWidth);
			cell.setBorder(13);			
			table.addCell(cell);		
			cell = new PdfPCell(new Phrase("ค่าบริการสาธารณะ", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(5);
			cell.setBorderColor(borderColor);
			cell.setColspan(publicTypeWidth+publicAvgWidth+publicAmountWidth);
			cell.setBorder(13);			
			table.addCell(cell);		
			
		   
			 		   
			cell = new PdfPCell(new Phrase("", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingTop(0);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);		
			cell.setColspan(noWidth);
			cell.setBorder(14);
			table.addCell(cell);
			cell = new PdfPCell(new Phrase("", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
			cell.setPaddingTop(0);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
			cell.setColspan(custWidth+telWidth);
			cell.setBorder(14);
			table.addCell(cell);					
			/*			   
			cell = new PdfPCell(new Phrase("", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
			cell.setColspan(custWidth);
			cell.setBorder(14);
			table.addCell(cell);			   
			cell = new PdfPCell(new Phrase("", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
			cell.setColspan(telWidth);
			cell.setBorder(14);
			table.addCell(cell);		
			*/
			cell = new PdfPCell(new Phrase("", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingTop(0);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
			cell.setColspan(iLockWidth);
			cell.setBorder(14);
			table.addCell(cell);			
			cell = new PdfPCell(new Phrase("", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingTop(0);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
			cell.setColspan(iHouseWidth);
			cell.setBorder(14);
			table.addCell(cell);			   
			cell = new PdfPCell(new Phrase("", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingTop(0);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
			cell.setColspan(qAreaWidth);
			cell.setBorder(14);
			table.addCell(cell);			   
			cell = new PdfPCell(new Phrase("", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingTop(0);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
			cell.setColspan(iModelWidth);
			cell.setBorder(14);
			table.addCell(cell);			   
			cell = new PdfPCell(new Phrase("ทำสัญญา", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingTop(0);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
			cell.setColspan(dLoiWidth);
			cell.setBorder(14);
			table.addCell(cell);			   
			cell = new PdfPCell(new Phrase("", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingTop(0);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
			cell.setColspan(dCloseLawWidth);
			cell.setBorder(14);
			table.addCell(cell);			   
			cell = new PdfPCell(new Phrase("หมด\nประกัน", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingTop(0);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
			cell.setColspan(expireWidth);
			cell.setBorder(14);
			table.addCell(cell);			   
			cell = new PdfPCell(new Phrase("จ่าย\nงวด 9", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingTop(0);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
			cell.setColspan(lastPaidWidth);
			cell.setBorder(14);
			table.addCell(cell);			   
			cell = new PdfPCell(new Phrase("End\nProduct", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingTop(0);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
			cell.setColspan(qcDateWidth);
			cell.setBorder(14);
			table.addCell(cell);			 
			cell = new PdfPCell(new Phrase("สร้าง", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingTop(0);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
			cell.setColspan(vendWidth);
			cell.setBorder(14);			
			table.addCell(cell);			   
			cell = new PdfPCell(new Phrase("จ้างเหมา", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingTop(0);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
			cell.setColspan(estConstWidth);
			cell.setBorder(14);			
			table.addCell(cell);		
			cell = new PdfPCell(new Phrase("% *", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingTop(0);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
			cell.setColspan(cutDescWidth);
			cell.setBorder(15);			
			table.addCell(cell);	
			cell = new PdfPCell(new Phrase("บาท", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingTop(0);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
			cell.setColspan(amountWidth);
			cell.setBorder(15);			
			table.addCell(cell);	
			cell = new PdfPCell(new Phrase("แบบ", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingTop(0);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
			cell.setColspan(publicTypeWidth);
			cell.setBorder(15);			
			table.addCell(cell);			
			cell = new PdfPCell(new Phrase("บาท/\nตรว.", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingTop(0);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
			cell.setColspan(publicAvgWidth);
			cell.setBorder(15);			
			table.addCell(cell);		
			cell = new PdfPCell(new Phrase("จำนวน\nเงิน", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setPaddingTop(0);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);
			cell.setColspan(publicAmountWidth);
			cell.setBorder(15);			
			table.addCell(cell);					
			//----===========================================================================================-----//			 
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
			DecimalFormat format2 = new DecimalFormat("#,##0.00 ");

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
			   String monthReport = doString.checkString(req.getParameter("month_report"),"0");
			   String yearReport = doString.checkString(req.getParameter("year_report"),"0");

			   String keyProject = doString.checkString(req.getParameter("key_project"),"");
			   String[] projList = req.getParameterValues("sel_proj");

			   String startDate = doString.checkString(req.getParameter("start_date"),"");
			   String startMonth = doString.checkString(req.getParameter("start_month"),"");
			   String startYear = doString.checkString(req.getParameter("start_year"),"0");
			   String endDate = doString.checkString(req.getParameter("end_date"),"");
			   String endMonth = doString.checkString(req.getParameter("end_month"),"");
			   String endYear = doString.checkString(req.getParameter("end_year"),"0");


			   String startQueryDate = startYear+"-"+startMonth+"-"+startDate;
			   String endQueryDate = endYear+"-"+endMonth+"-"+endDate;			   
			   //---==============================================================----//


			
			
			
				//----================ Initialize Variables for create PDF =====================---//
				BaseFont bf = BaseFont.createFont(Constants.FONT_ANGSANA_NORMAL, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
				BaseFont bfb = BaseFont.createFont(Constants.FONT_ANGSANA_BOLD, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
				microssfont = new Font(bf, 10, Font.NORMAL);
				microssfont_MINI = new Font(bf, 10, Font.NORMAL);
				microssfont_BOLD = new Font(bfb, 10, Font.NORMAL);
				microssfont_HD = new Font(bfb, 16, Font.NORMAL);

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


			   String companyName = "";
			   String projectName = "";
	   	
		   		   	
			   if (keyProject.trim().length()>2) {
					projectName = "";
				
					//----================= Get Company Name ===============----//
					sql.delete(0,sql.length());
					sql.append("select n_company from lan:acxcompa where i_company='").append(keyProject.substring(0,2)).append("' ");
					rs = stmt.executeQuery(sql.toString());
					if (rs.next()) {
						companyName = doString.checkString(rs.getString("n_company"),"");
					}
					rs.close();
		   	
					//----================= Get Project Name ===============----//
					sql.delete(0,sql.length());
					sql.append(" select * from lan:acxprojt a where  a.i_company||':'||a.i_project='"+keyProject+"' ");
					rs = stmt.executeQuery(sql.toString());
					if (rs.next()) {
						projectName =  doString.checkString(rs.getString("n_project"),"");
					}
					rs.close();
			   }
			   

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
			   if (cutTypeDesc.length()>0) cutTypeDesc = "* "+cutTypeDesc;
			   			   

			   printHeaderPage(table,currDate,startQueryDate,endQueryDate,projectName,companyName);
			   int line = 10;
			   int dataLine = 0;
			   
			   
			   //----============== Count Max Row ==================-----//
			   int maxRow = 0;
			   sql.delete(0,sql.length());
			   sql.append(" select count(*) cnt from lan:acsregis a ")
					 .append(" where a.d_close_law between '").append(startQueryDate).append("' and '").append(endQueryDate).append("' ")
					 .append(" and a.i_company||':'||a.i_project='").append(keyProject).append("' ");
			   rs = stmt.executeQuery(sql.toString());
			   while (rs.next()) {
					maxRow = rs.getInt("cnt");
			   } // end while
			   rs.close();
			   
			   

			   //----========================= Get DOCHD Data  ==============================-----//
			   sql.delete(0,sql.length());
			   sql.append(" select trim(b.n_prename)||trim(b.n_ncustomer)||' '||trim(b.n_scustomer) as cust_name ")
					 .append(" ,b.a_id_tel,b.a_wk_tel,b.a_etc_tel,a.d_close_law,a.i_company,a.i_project,a.i_lor ")
					 .append(" from lan:acsregis a ")
					 .append(" left join lan:acxcusto b on b.i_customer=a.i_cus_intent1 ")
					 .append(" where a.d_close_law between '").append(startQueryDate).append("' and '").append(endQueryDate).append("' ")
					 .append(" and a.i_company||':'||a.i_project='").append(keyProject).append("' ")
					 .append(" order by 1 ");
			   rs = stmt.executeQuery(sql.toString());
			   while (rs.next()) {
							   line++;
							   dataLine++;

							   String custName = doString.checkString(rs.getString("cust_name"),"");
							   String iLor = doString.checkString(rs.getString("i_lor"),"");

							   String dCloseLaw = convertTimestamp(common,rs.getTimestamp("d_close_law"),0,0);
							   String expireDate = convertTimestamp(common,rs.getTimestamp("d_close_law"),Calendar.YEAR,1);

							   String idTel = doString.checkString(rs.getString("a_id_tel"),"");
							   String workTel = doString.checkString(rs.getString("a_wk_tel"),"");
							   String etcTel = doString.checkString(rs.getString("a_etc_tel"),"");
							   String showTel = idTel;
							   if (showTel.trim().length()>0 && workTel.trim().length()>0) showTel += " , ";
							   showTel += workTel;
							   if (showTel.trim().length()>0 && etcTel.trim().length()>0) showTel += " , ";
							   showTel += etcTel;



								//----=============== Get Other Data with i_lor ====================-----//
								String iLock = "";
								String iHouse = "";
								String qArea = "";
								String iModel = "";
								String dLoi = "";
								String qcDate = "";
								String zPrice = "";
								String zPublicAmount = "";
								sql.delete(0,sql.length());
								sql.append(" select a.i_lock,d.i_house,a.q_area,d.i_model,e.d_loi,g.date_qc,k.z_price,l.z_amount from lan:acxslock a ")
									  .append(" left join lan:acxlckmd d on d.i_company=a.i_company and d.i_project=a.i_project and d.i_lor=a.i_lor ")
									  .append(" left join lan:acscontr e on e.i_company=a.i_company and e.i_project=a.i_project and e.i_lor=a.i_lor ")
									  .append(" left join lan:acxlckhd g on g.i_company=a.i_company and g.i_project=a.i_project and g.i_lor=a.i_lor ")
									  .append(" left join lan:acspubdt k on k.i_company=a.i_company and k.i_project=a.i_project and k.i_phase=a.i_phase ")
									  .append(" left join lan:acrduerv l on l.i_company=a.i_company and l.i_project=a.i_project and l.i_lor=a.i_lor and l.i_due='C0' ")
									  .append(" where a.i_company||':'||a.i_project='").append(keyProject).append("' ")
									  .append(" and a.i_lor='").append(iLor).append("'  ");
								rs1 = stmt1.executeQuery(sql.toString());
								if (rs1.next()) {
									iLock = doString.checkString(rs1.getString("i_lock"),"");
									iHouse = doString.checkString(rs1.getString("i_house"),"");
									qArea = format2.format(rs1.getDouble("q_area"));
									iModel = doString.checkString(rs1.getString("i_model"),"");
									dLoi = convertTimestamp(common,rs1.getTimestamp("d_loi"),0,0);
									qcDate = convertTimestamp(common,rs1.getTimestamp("date_qc"),0,0);
									zPrice = format2.format(rs1.getDouble("z_price"));
									zPublicAmount = format2.format(rs1.getDouble("z_amount"));
								}
								rs1.close();



							   //----=============== Get Other Data width i_lock ====================-----//
							   String lastPaidDate = "";
							   String venNo = "";
							   String estConst1 = "";
							   String zAmount = "";
							   String iCutType = "";
							   sql.delete(0,sql.length());
							   sql.append(" select a.last_paid_date,h.ven_no,h.est_const_1 ,i.i_cut_type,i.z_amount from lan:untcon a ")
									 .append(" left join lan:unit h on h.i_company=a.i_company and h.i_project=a.i_project and h.i_lock=a.i_lock ")
									 .append(" left join lan:serv_cutlck i on i.i_company=a.i_company and i.i_project=a.i_project and i.i_lock=a.i_lock ")
									 .append(" where a.i_company||':'||a.i_project='").append(keyProject).append("' ")
									 .append(" and a.i_lock='").append(iLock).append("' and a.ins_no='9'  ");
							   rs1 = stmt1.executeQuery(sql.toString());
							   if (rs1.next()) {
								   lastPaidDate = convertTimestamp(common,rs1.getTimestamp("last_paid_date"),0,0);
								   venNo = doString.checkString(rs1.getString("ven_no"),"");
								   estConst1 = format2.format(rs1.getDouble("est_const_1"));
								   zAmount = format2.format(rs1.getDouble("z_amount"));
								   iCutType = doString.checkString(rs1.getString("i_cut_type"),"");
							   }
							   rs1.close();
							   
							   
							   
							   if (custName.trim().length()>40) custName = custName.substring(0,37)+"...";
							   if (showTel.trim().length()>40) showTel = showTel.substring(0,37)+"...";
								String showCustDetails = " "+custName+"\n "+showTel;



								//----================= Start Print Data ====================-----//
								cell = new PdfPCell(new Phrase(Integer.toString(dataLine) , microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);		
								cell.setColspan(noWidth);
								cell.setBorder(14);
								table.addCell(cell);		
								
								
								cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(showCustDetails), microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
								cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);
								cell.setColspan(custWidth+telWidth);
								cell.setBorder(14);
								table.addCell(cell);			   
												
								
									   /*
								cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(custName), microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
								cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);
								cell.setColspan(custWidth);
								cell.setBorder(14);
								table.addCell(cell);			   
								cell = new PdfPCell(new Phrase(str.replace(doString.MS874ToUnicode(showTel),",",",\n"), microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);
								cell.setColspan(telWidth);
								cell.setBorder(14);
								table.addCell(cell);	*/	
								cell = new PdfPCell(new Phrase(iLock, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);
								cell.setColspan(iLockWidth);
								cell.setBorder(14);
								table.addCell(cell);			
								cell = new PdfPCell(new Phrase(iHouse, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);
								cell.setColspan(iHouseWidth);
								cell.setBorder(14);
								table.addCell(cell);			   
								cell = new PdfPCell(new Phrase(qArea, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
								cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);
								cell.setColspan(qAreaWidth);
								cell.setBorder(14);
								table.addCell(cell);			   								
								cell = new PdfPCell(new Phrase(iModel, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(2);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);
								cell.setColspan(iModelWidth);
								cell.setBorder(14);
								table.addCell(cell);			   
								cell = new PdfPCell(new Phrase(dLoi, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);
								cell.setColspan(dLoiWidth);
								cell.setBorder(14);
								table.addCell(cell);			   
								cell = new PdfPCell(new Phrase(dCloseLaw, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);
								cell.setColspan(dCloseLawWidth);
								cell.setBorder(14);
								table.addCell(cell);			   
								cell = new PdfPCell(new Phrase(expireDate, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);
								cell.setColspan(expireWidth);
								cell.setBorder(14);
								table.addCell(cell);			   
								cell = new PdfPCell(new Phrase(lastPaidDate, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);
								cell.setColspan(lastPaidWidth);
								cell.setBorder(14);
								table.addCell(cell);			   
								cell = new PdfPCell(new Phrase(qcDate, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);
								cell.setColspan(qcDateWidth);
								cell.setBorder(14);
								table.addCell(cell);			 
								cell = new PdfPCell(new Phrase(venNo, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);
								cell.setColspan(vendWidth);
								cell.setBorder(14);			
								table.addCell(cell);			   
								cell = new PdfPCell(new Phrase(estConst1, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
								cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);
								cell.setColspan(estConstWidth);
								cell.setBorder(14);			
								table.addCell(cell);		
								cell = new PdfPCell(new Phrase(iCutType, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);
								cell.setColspan(cutDescWidth);
								cell.setBorder(15);			
								table.addCell(cell);	
								cell = new PdfPCell(new Phrase(zAmount, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
								cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);
								cell.setColspan(amountWidth);
								cell.setBorder(15);			
								table.addCell(cell);	
								cell = new PdfPCell(new Phrase("C0", microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
								cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);
								cell.setColspan(publicTypeWidth);
								cell.setBorder(15);			
								table.addCell(cell);			
								cell = new PdfPCell(new Phrase(zPrice, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
								cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);
								cell.setColspan(publicAvgWidth);
								cell.setBorder(15);			
								table.addCell(cell);		
								cell = new PdfPCell(new Phrase(zPublicAmount, microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
								cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);
								cell.setColspan(publicAmountWidth);
								cell.setBorder(15);			
								table.addCell(cell);			
								
								
								
								line++;										
								if (line>30 && dataLine<maxRow) {
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
							
									document.add(table);
									document.newPage();
									table = new PdfPTable(100);
									table.setWidthPercentage(100);
											
									printHeaderPage(table,currDate,startQueryDate,endQueryDate,projectName,companyName);
									line = 10;
								} else if (dataLine==maxRow) {
									//----=========== Cut Type Desc ===========----//
									cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(cutTypeDesc), microssfont));
									cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
									cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
									cell.setColspan(100);
									cell.setBorder(0);
									table.addCell(cell);											
								}	  	

			   } // end while
			   rs.close();
			   			   


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
