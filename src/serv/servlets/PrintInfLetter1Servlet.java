package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;

import com.lh.servlet.DBServlet;
import com.lh.util.*;

import java.awt.Color;
import com.lowagie.text.*;
import com.lowagie.text.pdf.*;

import serv.common.Constants;

/**
 * @version 	1.0
 * @author
 */
public class PrintInfLetter1Servlet extends DBServlet  {
	
	//---- Tru Type Font ----//		
	private Font microssfont = null;
	private Font microssfont_BOLD = null;
	private String month[] = {"มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};	
	
	static class HeaderFooter extends PdfPageEventHelper {
		protected Phrase header;
		protected PdfPTable footer;
		protected Font microssfont;
		public HeaderFooter(Font microssfont) {
				this.microssfont = microssfont;
		}

		public void onEndPage(PdfWriter writer, Document document) {
			PdfContentByte cb = writer.getDirectContent();
								
			PdfPTable footer;
			footer = new PdfPTable(1);
			footer.setTotalWidth(535);
			footer.getDefaultCell().setBorder(Rectangle.TOP);
			PdfPCell cell = new PdfPCell(new Phrase("หมายเหตุ : ท่านสามารถสอบถามข้อมูลเพิ่มเติมได้ที่ Service Center โทร 1198 กด 2  ได้ทุกวัน ในเวลาทำการ 09.00 – 17.30 น.", microssfont));
			cell.setHorizontalAlignment(Element.ALIGN_LEFT);
			cell.setBorder(0);
			footer.addCell(cell);
			
			
			footer.writeSelectedRows(0, -1, document.leftMargin(), document.bottom()+3, cb);
		}
		
	}	

	public static PdfPCell addCellData(String msg,String hAlign,String vAlign,String border,int size,Font font) {
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
		cell.setPaddingBottom(5);
		cell.setBorderColor(new Color(153,153,153));
		return cell;
	}
	
	
	public String getDateField(ResultSet rs,String fieldName) throws Exception {
		 String result = "";
		 doString str = new doString();
		 Calendar cal = null;
		 Timestamp tmp = rs.getTimestamp(fieldName);
		 if (tmp!=null) {
			 cal = Calendar.getInstance();
			 cal.setTime(tmp);  

			 int year = cal.get(Calendar.YEAR);
			 if (year<2400) year += 543;
			 result = str.createID(cal.get(Calendar.DATE),2)+"/"+str.createID(cal.get(Calendar.MONTH)+1,2)+"/"+str.createID(year,4);
		 }

		 return result;
	}	
	

	public void printLetter(Document document, String printDate, String inf_year, String projNme, String endDate) throws Exception {
	  PdfPTable table = new PdfPTable(100);
	  table.setWidthPercentage(100);
	  		  

	  //----------- Select Data from Database --------------//
	  
	  table.addCell(addCellData("","R","C","",90,microssfont));
	  table.addCell(addCellData("ฉบับที่ 1","L","C","",10,microssfont));
	  
	  table.addCell(addCellData(" ","L","C","",100,microssfont));
	  table.addCell(addCellData(" ","L","C","",100,microssfont));
	  
	  table.addCell(addCellData(" ","L","C","",60,microssfont));
	  table.addCell(addCellData("วันที่ "+printDate,"L","C","",40,microssfont));
	  table.addCell(addCellData(" ","L","C","",100,microssfont));
	  table.addCell(addCellData("เรื่อง","L","C","",5+3,microssfont));
	  table.addCell(addCellData("การจัดเก็บค่าบริการสาธารณะประจำปี "+inf_year,"L","C","",95-3,microssfont));
	  table.addCell(addCellData(" ","L","C","",5+3,microssfont));
	  table.addCell(addCellData("โครงการ "+projNme,"L","C","",95-3,microssfont));
	  
	  table.addCell(addCellData("เรียน","L","C","",5+3,microssfont));
	  table.addCell(addCellData("ท่านเจ้าของบ้าน","L","C","",95-3,microssfont));
	  table.addCell(addCellData(" ","L","C","",100,microssfont));
	  
	  table.addCell(addCellData(" ","L","C","",5+3,microssfont));
	  table.addCell(addCellData("ตามที่ทางบริษัท แลนด์ แอนด์ เฮ้าส์ จำกัด (มหาชน) ได้ดำเนินการจัดสรรบ้านพร้อมที่ดินในโครงการ ","L","C","",95-3,microssfont));
	  
	  table.addCell(addCellData(projNme+" และได้จัดให้มีการบริการสาธารณะให้กับท่านและลูกบ้านในโครงการ อาทิเช่น","L","C","",100,microssfont));
	  table.addCell(addCellData("งานรักษาความปลอดภัย งานทำความสะอาดถนน การจัดเก็บขยะ ไฟฟ้าส่องสว่าง เป็นต้น สำหรับการให้บริการดังกล่าว","L","C","",100,microssfont));
	  table.addCell(addCellData("บริษัทฯ ได้มีการเรียกเก็บค่าบริการสาธารณะจากท่านล่วงหน้าในวันโอนกรรมสิทธิ์ที่ดินพร้อมสิ่งปลูกสร้าง","L","C","",100,microssfont));
	  table.addCell(addCellData("ซึ่งปัจจุบันใกล้จะถึง วันสิ้นสุดระยะเวลาการให้บริการ ในวันที่ "+endDate+" นี้","L","C","",100,microssfont_BOLD));
	  
	  table.addCell(addCellData(" ","L","C","",5+3,microssfont));
	  table.addCell(addCellData("ทั้งนี้เพื่อให้การบริการสาธารณะได้คงอยู่และเป็นไปอย่างต่อเนื่อง บริษัทฯ จึงมีความจำเป็นที่จะต้องจัดเก็บ","L","C","",95-3,microssfont));
	  
	  table.addCell(addCellData("ค่าบริการสาธารณะใหม่จากท่าน โดยจะมีการแจ้งวันเวลาในการเริ่มจัดเก็บและค่าบริการที่จะจัดเก็บใหม่ให้ท่านรับทราบ","L","C","",100,microssfont));
	  table.addCell(addCellData("โดยจะมีการแจ้งวันเวลาในการเริ่มจัดเก็บและค่าบริการที่จะจัดเก็บใหม่ให้ท่านรับทราบในโอกาสต่อไป","L","C","",100,microssfont));
	  
	  table.addCell(addCellData(" ","L","C","",100,microssfont));
	  
	  table.addCell(addCellData(" ","L","C","",5+3,microssfont));
	  table.addCell(addCellData("จึงเรียนมาเพื่อทราบและขอขอบพระคุณในความร่วมมือล่วงหน้ามา ณ โอกาสนี้","L","C","",95-3,microssfont));
	  
	  table.addCell(addCellData(" ","L","C","",100,microssfont));
	  table.addCell(addCellData(" ","L","C","",100,microssfont));
	  table.addCell(addCellData(" ","L","C","",100,microssfont));
	  
	  table.addCell(addCellData(" ","L","C","",60,microssfont));
	  table.addCell(addCellData("ขอแสดงความนับถือ","L","C","",40,microssfont));
	  
	  table.addCell(addCellData(" ","L","C","",57,microssfont));
	  table.addCell(addCellData("ฝ่ายบริการและลูกค้าสัมพันธ์","L","C","",43,microssfont));
	  
	  table.addCell(addCellData(" ","L","C","",57,microssfont));
	  table.addCell(addCellData("โครงการ "+projNme,"L","C","",43,microssfont));
	  
	  document.add(table);
	}
	
	public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		String mName = new String(this.getClass().getName() + ".performTask: ");
		System.out.println(mName + "start.");

		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		try {
			if (ds == null)
				getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
			stmt = conn.createStatement();	
			
			
			//--------- Get Data from Request ---------//
			String day = Integer.toString(Integer.parseInt(req.getParameter("Prntday")));
			String mnth = month[Integer.parseInt(req.getParameter("Prntmnth"))-1];
			String year = req.getParameter("Prntyear");
			String printDate = day+" "+mnth+" "+year;
			
			String inf_year = doString.checkString(req.getParameter("inf_year"));
			String site = doString.checkString(req.getParameter("Project"));
			String comId = site.substring(0,2);
			String projId = site.substring(2);
			String projNme = "";
			
			day = Integer.toString(Integer.parseInt(req.getParameter("Finishday")));
			mnth = month[Integer.parseInt(req.getParameter("Finishmnth"))-1];
			year = req.getParameter("Finishyear");
			String endDate = day+" "+mnth+" "+year;				
			
			rs = stmt.executeQuery("SELECT n_project FROM lan:acxprojt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
			if (rs != null) {
				if (rs.next() == true) {
					projNme = doString.MS874ToUnicode(doString.checkString(rs.getString("N_PROJECT")));
				}
				rs.close();
				rs=null;
			}
			
			//----================ Initialize Variables for create PDF =====================---//
			
			
			BaseFont bf = BaseFont.createFont(Constants.FONT_ANGSANA_NORMAL, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
			BaseFont bfb = BaseFont.createFont(Constants.FONT_ANGSANA_BOLD, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);		
			microssfont = new Font(bf, 16, Font.NORMAL);
			microssfont_BOLD = new Font(bfb, 16, Font.NORMAL);
			
			String realPath = getServletContext().getRealPath("/");
			String pdfPath = realPath + "/images/";		
			
			Document document = new Document(PageSize.A4);
			document.setMargins(45, 0, 36, 36);

			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			PdfWriter writer = PdfWriter.getInstance(document, baos);
			
			writer.setPageEvent(new HeaderFooter(microssfont));

			PdfContentByte cb = writer.getDirectContent();
			PdfReader reader = new PdfReader(pdfPath + "/LH_Header031.pdf");
			PdfImportedPage page1 = writer.getImportedPage(reader, 1);
			document.open();
			int lockNo = 0;
			int num_lock = 0;
			//------ generate data -------//
			rs = stmt.executeQuery("SELECT COUNT(DISTINCT i_sort) FROM lan:serv_inflck WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
			if (rs != null) {
				if (rs.next() == true) {
					num_lock = rs.getInt(1);
				}
				rs.close();
				rs=null;
			}
			rs = stmt.executeQuery("SELECT DISTINCT i_sort FROM lan:serv_inflck WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
			if (rs != null) {
				while (rs.next() == true) {
					lockNo++;
					cb.addTemplate(page1, 1, 1);
					printLetter(document,printDate,inf_year,projNme,endDate);
					break;
/*					
					if (lockNo < num_lock)
						document.newPage();
*/						
				}// end while lock
				rs.close();
				rs=null;
			}
		  //----=========== Generate PDF ===============-----//
		  document.close();
		  res.setContentType("application/pdf");
		  res.setContentLength(baos.size());
		  ServletOutputStream outServ = res.getOutputStream();
		  baos.writeTo(outServ);
		  outServ.flush();
		
		  stmt.close();
		  conn.close();
		  stmt = null;
		  conn = null;
		  
		  
		 } catch (DocumentException de) {
			 System.err.println("error PrintInfLetter1Servlet  DOCUMENT: " + de.getMessage());
		} catch (Exception e) {
			System.out.println(" ERROR "+mName+" : " + e.getMessage());
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