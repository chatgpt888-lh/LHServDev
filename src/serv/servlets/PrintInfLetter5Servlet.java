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
import serv.servlets.PrintInfLetter2Servlet.HeaderFooter;

/**
 * @version 	1.0
 * @author
 */
public class PrintInfLetter5Servlet extends DBServlet  {
	
	//---- Tru Type Font ----//		
	private Font microssfont = null;
	private Font microssfont_BOLD = null;
	private Font microssfont_HD = null;		
	private String month[] = {"มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};	
	
	static class HeaderFooter extends PdfPageEventHelper {
		protected Phrase header;
		protected PdfPTable footer;
		protected Font microssfont;
		protected String contact;
		protected String phone;
		public HeaderFooter(Font microssfont, String contact, String phone) {
				this.microssfont = microssfont;
				this.contact = contact;
				this.phone = phone;
		}

		public void onEndPage(PdfWriter writer, Document document) {
			PdfContentByte cb = writer.getDirectContent();
								
			PdfPTable footer;
			footer = new PdfPTable(1);
			footer.setTotalWidth(535);
			footer.getDefaultCell().setBorder(Rectangle.TOP);
			PdfPCell cell = new PdfPCell(new Phrase("หมายเหตุ : ท่านสามารถสอบถามข้อมูลเพิ่มเติมได้ที่ Service Center โทร 1198 กด 2  ได้ทุกวัน ในเวลาทำการ\n09.00 – 17.30 น. หรือ ติดต่อ คุณ "+contact+" โทร "+phone, microssfont));
			cell.setHorizontalAlignment(Element.ALIGN_LEFT);
			cell.setBorder(0);
			footer.addCell(cell);
			
			footer.writeSelectedRows(0, -1, document.leftMargin(), document.bottom()+10, cb);
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
	

	public void printLetter(Document document, String printDate, String inf_year, String projNme, String custName, String houseId, String finishDate,float price,String startDate,String endDate,double amount,String name, String phoneNo) throws Exception {
	  String startMnth = month[Integer.parseInt(startDate.substring(5, 7))-1];
	  String startYear = Integer.toString(Integer.parseInt(startDate.substring(0, 4))+543);
	  String endMnth = month[Integer.parseInt(endDate.substring(5, 7))-1];
	  String endYear = Integer.toString(Integer.parseInt(endDate.substring(0, 4))+543);
	  CurrencyToThai currencyToThai = new CurrencyToThai(amount);
	  
		PdfPTable table = new PdfPTable(100);
	  table.setWidthPercentage(100);
	  
	  		  

	  //----------- Select Data from Database --------------//
	  table.addCell(addCellData("ฉบับที่ 3","R","C","",100,microssfont));
	  table.addCell(addCellData(" ","L","C","",100,microssfont));
	  table.addCell(addCellData(" ","L","C","",100,microssfont));
	  
	  table.addCell(addCellData(" ","L","C","",60,microssfont));
	  table.addCell(addCellData("วันที่ "+printDate,"L","C","",40,microssfont));
	  
	  table.addCell(addCellData(" ","L","C","",100,microssfont));
	  
	  table.addCell(addCellData("เรื่อง","L","C","",5+3,microssfont));
	  table.addCell(addCellData("การของดจัดเก็บขยะครัวเรือน","L","C","",95-3,microssfont));
	  
	  table.addCell(addCellData("เรียน","L","C","",5+3,microssfont));
	  table.addCell(addCellData(custName,"L","C","",95-3,microssfont));
	  
	  table.addCell(addCellData(" ","L","C","",5+3,microssfont));
	  table.addCell(addCellData("เจ้าของกรรมสิทธิ์บ้านเลขที่ "+houseId+" โครงการ "+projNme,"L","C","",95-3,microssfont));
	  
	  table.addCell(addCellData("สิ่งที่ส่งมาด้วย","L","C","",15-2,microssfont));
	  table.addCell(addCellData("ใบแจ้งการชำระเงิน พร้อมแบบฟอร์มการชำระเงินที่ธนาคาร ( ใบ PAY – IN )","L","C","",95+2,microssfont));
	  	  
	  table.addCell(addCellData(" ","L","C","",100,microssfont));
	  
	  table.addCell(addCellData(" ","L","C","",5+3,microssfont));
	  table.addCell(addCellData("บริษัท แลนด์ แอนด์ ต้องขอขอบคุณท่านเจ้าของบ้านทุกท่าน ที่ให้ความร่วมมือในการชำระค่าบริการสาธารณะประจำปี "+inf_year,"L","C","",95-3,microssfont));
	  
	  table.addCell(addCellData("แต่สำหรับท่านที่ยังไม่ได้ชำระค่าบริการดังกล่าว โปรดรีบดำเนินการชำระภายในวันที่ "+finishDate+" ซึ่งท่านสามารถชำระได้ 2 ทางคือ","L","C","",100,microssfont));
	  table.addCell(addCellData("ซึ่งท่านสามารถชำระได้ 2 ทางคือ","L","C","",100,microssfont));
	  table.addCell(addCellData(" ","L","C","",5+3,microssfont));
	  table.addCell(addCellData("1.โดยนำแบบฟอร์มการชำระเงินที่ธนาคารไปติดต่อชำระเงินได้ที่ธนาคารตามที่ระบุไว้","L","C","",95-3,microssfont));
	  table.addCell(addCellData(" ","L","C","",5+3,microssfont));
	  table.addCell(addCellData("2.ชำระโดยกดผ่าน QRCODE","L","C","",95-3,microssfont));
	  
	  table.addCell(addCellData(" ","L","C","",5+3,microssfont));
	  table.addCell(addCellData("หากพ้นกำหนดระยะเวลาดังกล่าวแล้ว บริษัทฯ มีความจำเป็นอย่างยิ่งที่จะต้อง","L","C","",95-3,microssfont));
	  
	  table.addCell(addCellData(" ","L","C","",5+3,microssfont));
	  table.addCell(addCellData("ขอสงวนสิทธิ์ในการงดการให้บริการจัดเก็บขยะครัวเรือนบ้านของท่าน ","L","C","",95-3,microssfont_BOLD));
	  
	  table.addCell(addCellData(" ","L","C","",5+3,microssfont));
	  table.addCell(addCellData("ทั้งนี้หากท่านได้มีการชำระเงินค่าบริการสาธารณะก่อนที่ท่านได้รับหนังสือฉบับนี้ บริษัทฯต้องกราบขออภัยมา ณ โอกาสนี้ด้วย","L","C","",95-3,microssfont));
	  
	  table.addCell(addCellData(" ","L","C","",100,microssfont));
	  
	  table.addCell(addCellData(" ","L","C","",5+3,microssfont));
	  table.addCell(addCellData("จึงเรียนมาเพื่อทราบ และขอขอบพระคุณล่วงหน้ามา ณ โอกาสนี้","L","C","",95-3,microssfont));
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
			
			mnth = doString.checkString(req.getParameter("BegMonth"));
			year = doString.checkString(req.getParameter("BegYear"));
			String startDate = year+"-"+mnth+"-01";
			
			mnth = doString.checkString(req.getParameter("EndMonth"));
			year = doString.checkString(req.getParameter("EndYear"));
			String endDate = year+"-"+mnth+"-01";
			
			String inf_year = doString.checkString(req.getParameter("inf_year"));
			String site = doString.checkString(req.getParameter("Project"));
			
			String comId = site.substring(0,2);
			String projId = site.substring(2);
			String projNme = "";
			
			day = Integer.toString(Integer.parseInt(req.getParameter("Finishday")));
			mnth = month[Integer.parseInt(req.getParameter("Finishmnth"))-1];
			year = req.getParameter("Finishyear");
			String finishDate = day+" "+mnth+" "+year;				
			
			String name = doString.MS874ToUnicode(doString.checkString(req.getParameter("Contact")));
			String phoneNo = doString.MS874ToUnicode(doString.checkString(req.getParameter("Phone")));
			
			float price = 0;
			double amount = 0;
			
			rs = stmt.executeQuery("SELECT n_project FROM lan:acxprojt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
			if (rs != null) {
				if (rs.next() == true) {
					projNme = doString.MS874ToUnicode(doString.checkString(rs.getString("N_PROJECT")));
				}
				rs.close();
				rs=null;
			}
			
			rs = stmt.executeQuery("SELECT z_price FROM lan:serv_infrate WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_year = '"+inf_year+"'");
			if (rs != null) {
				if (rs.next() == true) {
					price = rs.getFloat("Z_PRICE");
				}
				rs.close();
				rs=null;
			}			
			
			//----================ Initialize Variables for create PDF =====================---//			
			BaseFont bf = BaseFont.createFont(Constants.FONT_ANGSANA_NORMAL, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
			BaseFont bfb = BaseFont.createFont(Constants.FONT_ANGSANA_BOLD, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);		
			
			microssfont = new Font(bf, 14, Font.NORMAL);
			microssfont_BOLD = new Font(bfb, 14, Font.NORMAL);
			microssfont_HD = new Font(bfb, 14, Font.NORMAL);
			
			String realPath = getServletContext().getRealPath("/");
			String pdfPath = realPath + "/images/";	
			
			Document document = new Document(PageSize.A4);
			document.setMargins(45, 36, 36, 36);

			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			PdfWriter writer = PdfWriter.getInstance(document, baos);
			
			writer.setPageEvent(new HeaderFooter(microssfont,name,phoneNo));

			PdfContentByte cb = writer.getDirectContent();
			PdfReader reader = new PdfReader(pdfPath + "/LH_Header031.pdf");
			PdfImportedPage page1 = writer.getImportedPage(reader, 1);
			document.open();
			int i = 0;
			int lockNo = 0;
			int num_lock = 0;
			String houseId = "";
			String custName = "";
			String preName = "";
			//------ generate data -------//
			rs = stmt.executeQuery("SELECT COUNT(*) FROM lan:serv_infhd WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND d_start = '"+startDate+"' AND d_end = '"+endDate+"' AND i_doc_status = 'Y'");
			if (rs != null) {
				if (rs.next() == true) {
					num_lock = rs.getInt(1);
				}
				rs.close();
				rs=null;
			}
			rs = stmt.executeQuery("SELECT i_sort, n_custo, i_house, z_infra FROM lan:serv_infhd WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND d_start = '"+startDate+"' AND d_end = '"+endDate+"' AND i_doc_status = 'Y'");
			if (rs != null) {
				while (rs.next() == true) {
					houseId = doString.checkString(rs.getString("I_HOUSE"));
					custName = doString.MS874ToUnicode(doString.checkString(rs.getString("N_CUSTO")));
					
					i = custName.indexOf(" ", 0);
					if (i > 0) {
						preName = doString.checkString(custName.substring(0, i));
						if (preName.equals("นาย") || preName.equals("นาง") || preName.equals("นางสาว")|| preName.equals("น.ส.") || preName.equals("ด.ช.")) {
							custName = "คุณ "+custName.substring(i+1);
						}
					}
					amount = rs.getDouble("Z_INFRA");
					lockNo++;
					cb.addTemplate(page1, 1, 1);
					//------ generate data -------//
					printLetter(document,printDate,inf_year,projNme,custName,houseId,finishDate,price,startDate,endDate,amount,name,phoneNo);
					if (lockNo < num_lock)
						document.newPage();
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
			 System.err.println("error PrintInfLetter5Servlet  DOCUMENT: " + de.getMessage());
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