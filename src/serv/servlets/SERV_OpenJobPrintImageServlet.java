package serv.servlets;
import java.io.*;
import java.text.DecimalFormat;
import java.util.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import com.lh.servlet.DBServlet;
import com.lh.util.*;
import com.lowagie.text.Image;
import com.lowagie.text.Chunk;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import com.lowagie.text.pdf.PdfReader;
import com.lowagie.text.pdf.PdfImportedPage;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Font;
import com.lowagie.text.PageSize;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import serv.common.Constants;

/**
 * @version 	1.0
 * @author
 */

/**
 * Modify by : pradoem@lh.co.th
 * date : 2015.04.28
 * version 1.1
 * desc: 
 */
public class SERV_OpenJobPrintImageServlet extends DBServlet  {
	
	
	public PdfPCell setCellAttribute(String msg,Font font,String hAlign,String vAlign,int colSpan,int border) {
		
		int h = 0;
		if (hAlign.equalsIgnoreCase("L")) {
			h = Rectangle.ALIGN_LEFT; 
		} else if (hAlign.equalsIgnoreCase("R")) {
			h = Rectangle.ALIGN_RIGHT; 
		} else {
			h = Rectangle.ALIGN_CENTER; 
		}
		

		int v = 0;
		if (vAlign.equalsIgnoreCase("T")) {
			v = Rectangle.ALIGN_TOP; 
		} else if (vAlign.equalsIgnoreCase("B")) {
			v = Rectangle.ALIGN_BOTTOM;
		} else {
			v = Rectangle.ALIGN_MIDDLE; 
		}		
		
		
		//---======= Start Set Cell Apprivutes =======---//
		 PdfPCell cell = new PdfPCell(new Phrase(msg,font));
		 cell.setHorizontalAlignment(h);
		 cell.setVerticalAlignment(v);
		 cell.setColspan(colSpan);
		 cell.setBorder(border);
		 
		 
		 return cell;
	}	
	
	public String getDateValue(Timestamp date) throws Exception {
		 String result = "";
		 doString str = new doString();
		 Calendar cal = null;
		 
		 if (date!=null) {
		 	 cal = Calendar.getInstance();
		 	 cal.setTime(date);
		 	 
		 	 int year = cal.get(Calendar.YEAR);
		 	 if (year<2400) year += 543;
		 	 
		 	 result = str.createID(cal.get(Calendar.DATE),2)+"/"+str.createID(cal.get(Calendar.MONTH)+1,2)+"/"+year;
		 }
		 
		 return result;
	}
	
	public void addImage(String[] imgName,String iDocNo,PdfPTable table,Font microssfont) throws Exception {
		PdfPCell cell = null;
		String imgPath = getServletContext().getRealPath("/pictures/"+iDocNo);
		File folder = new File(imgPath);
		boolean foundFile[] = {false,false};

		if (folder.isDirectory() && folder.exists()) {
			File check = null;
			
			for (int i=0;i<2;i++) {
					foundFile[i] = false;				
				
					check = new File(imgPath+File.separator+imgName[i]);				
					if (check.isFile() && check.exists()) {
						foundFile[i] = true;
						Image img = Image.getInstance(imgPath+File.separator+imgName[i]);
						//img.scalePercent(33,33);
						img.scaleAbsoluteWidth(210);
						img.scaleAbsoluteHeight(158);

						Chunk ck = new Chunk(img, 0, 0);          
						Phrase p1 = new Phrase("\n");
						p1.add(ck);								
						
						cell = new PdfPCell(p1);					
						cell.setColspan(50);
						cell.setBorder(0);
						cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
						cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
						table.addCell(cell);
					} else {
						//----- blank cell -------//		
						foundFile[i] = false;
						
						if (imgName[i].trim().length()>0) {
							cell = setCellAttribute("Image not found !!\n",microssfont,"C","T",50,0);
							table.addCell(cell);							
						} else if (i>0) {
							cell = setCellAttribute("\n",microssfont,"R","T",50,0);
							table.addCell(cell);						
						}
					}
			} // end for			
		} else {
			cell = setCellAttribute("Image Path not found !!\n",microssfont,"C","T",100,0);
			table.addCell(cell);
		}

		//---- if have image2 but no image1 -----//
		if (imgName[0].trim().length()<=0 && imgName[1].trim().length()>0) {
			cell = setCellAttribute("\n",microssfont,"R","T",50,0);
			table.addCell(cell);				
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

		String iDocNo = doString.checkString(req.getParameter("i_docno"),"");
		//String iVendor = doString.checkString(req.getParameter("i_vendor"),"");
    
		StringBuffer sql = new StringBuffer();
		Connection conn = null;
		Statement stmt = null;
		Statement stmt1 = null;
		ResultSet rs = null;
		ResultSet rs1 = null;

		 try {
			if (ds == null)
				getDS();

			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			//conn.setAutoCommit(true);
			stmt = conn.createStatement();	
			stmt1 = conn.createStatement();	
				
		
			//----================ Initialize Variables for create PDF =====================---//
			BaseFont bf = BaseFont.createFont(Constants.FONT_ANGSANA_NORMAL, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
			BaseFont bfb = BaseFont.createFont(Constants.FONT_ANGSANA_BOLD, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
			Font microssfont = new Font(bf, 14, Font.NORMAL);
			Font microssfont_MINI = new Font(bf, 12, Font.NORMAL);
			Font microssfont_BOLD = new Font(bfb, 14, Font.NORMAL);
			//Font microssfont_underline = new Font(bf, 14, Font.UNDERLINE);
			//Font microssfont_HD = new Font(bfb, 18, Font.NORMAL);

			Document document = new Document(PageSize.A4, 30, 30, 10, 10);
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			PdfWriter writer = PdfWriter.getInstance(document, baos);
			PdfContentByte cb = writer.getDirectContent();

			PdfReader reader = new PdfReader(Constants.PDF_HEADER_TEMPLATE);
			PdfImportedPage page1 = writer.getImportedPage(reader, 1);

			document.open();

			PdfPTable table = new PdfPTable(100);
			table.setWidthPercentage(100);
			PdfPCell cell;
			//int leftColumnWidth = 60;
			//int rightColumnWidth = 40;
			String currDate = "";
			Calendar now = Calendar.getInstance(Locale.ENGLISH);
			currDate = str.createID(now.get(Calendar.DATE),2)+"/"+str.createID(now.get(Calendar.MONTH)+1,2);
			int nYear = now.get(Calendar.YEAR);
			if (nYear<2500) nYear += 543;
			currDate += "/"+str.createID(nYear,4);
			currDate += " , "+str.createID(now.get(Calendar.HOUR_OF_DAY),2)+":"+str.createID(now.get(Calendar.MINUTE),2);

			//----===================== get Reten Data From SERV_DOCATT ======================----//
			String before[] = new String[] {"",""};
			String process[] = new String[] {"",""};
			String after[] = new String[] {"",""};
			
			
			String dJob = "";
			String dStartTask = "";
			String dComplete  = "";
			String nVendor = "";
			String itemStatus = "";
			String iVendor = "";		
			
			if(iDocNo.length()>0){
						
				sql.delete(0,sql.length());
				sql.append(" select * from lan:serv_docdt where i_docno='").append(iDocNo).append("' AND  f_itmstatus <> 'CAN' ")
					  .append(" order by i_seq,i_itmjob ");
				rs = stmt.executeQuery(sql.toString());
				
				int Loop = 1;
				while (rs.next()) {		
						iVendor = doString.checkString(rs.getString("i_vendor"),"").trim();
						//----===================== get Reten Data From SERV_DOCATT ======================----//
						before = new String[] {"",""};
						process = new String[] {"",""};
						after = new String[] {"",""};

						sql.delete(0,sql.length());
						sql.append("select * from lan:serv_docatt where i_docno='").append(iDocNo).append("' ")
						      .append(" and i_keygen ='"+doString.checkString(rs.getString("i_keygen"),"")+"' ");

						//System.out.println("rs1 : "+sql.toString());
						rs1 = stmt1.executeQuery(sql.toString());
						if (rs1.next()) {
							before[0] = doString.checkString(rs1.getString("b_file_name"),"").trim();
							before[1] = doString.checkString(rs1.getString("b_file_name2"),"").trim();
							process[0] = doString.checkString(rs1.getString("p_file_name1"),"").trim();
							process[1] = doString.checkString(rs1.getString("p_file_name2"),"").trim();
							after[0] = doString.checkString(rs1.getString("a_file_name"),"").trim();
							after[1] = doString.checkString(rs1.getString("a_file_name2"),"").trim();
						} // end while rs
						rs1.close();	
	
	
						if (before[0].length()>0 || before[1].length()>0 ||  // found before image
							process[0].length()>0 || process[1].length()>0 ||  // found process image
							after[0].length()>0 || after[1].length()>0  // found after image
						) {
							
							//----------- found image , start new page -------------//
							table = new PdfPTable(100);
							table.setWidthPercentage(100);
							cb.addTemplate(page1,1,1);
							
							
							//---------- get other data --------//
							nVendor = "";
							itemStatus = "";
							dJob = "";
							dStartTask = "";
							dComplete = "";
							
							sql.delete(0,sql.length());
							sql.append(" select f_itmstatus,d_approve ,f.i_vendor,v.bus_name ")
								  .append(" from lan:serv_flow f ")
								  .append(" left join lan:stpvendr v on v.vend_code=f.i_vendor ")
								  .append(" where f.i_docno='"+iDocNo+"' and f.i_vendor='"+iVendor+"' ")
								  .append(" order by f.f_itmstatus ");
							rs1 = stmt1.executeQuery(sql.toString());
							//System.out.println("SQL get serv_flow :"+sql.toString());
							while (rs1.next()) {
								nVendor = doString.checkString(rs1.getString("bus_name"),"");
								itemStatus = doString.checkString(rs1.getString("f_itmstatus"),"");				
					
								if (itemStatus.equals("100")) {	
									dJob = getDateValue(rs1.getTimestamp("d_approve"));
								} 
								if (itemStatus.equals("200")) {
									dStartTask = getDateValue(rs1.getTimestamp("d_approve"));
								} 
								if (itemStatus.equals("300")) {
									dComplete = getDateValue(rs1.getTimestamp("d_approve"));
								}
							} // end while
							rs1.close();
												
							
							cell = setCellAttribute("Print Date : "+currDate,microssfont_MINI,"R","T",100,0);
							table.addCell(cell);
							cell = setCellAttribute("\nภาพประกอบการซ่อม\n\n\n",microssfont_BOLD,"C","T",100,0);
							table.addCell(cell);
							
							//-- line 1 --//
							cell = setCellAttribute("เลขที่ใบแจ้งซ่อม : "+iDocNo,microssfont,"L","T",60,0);
							table.addCell(cell);					
							cell = setCellAttribute("",microssfont,"L","T",10,0);
							table.addCell(cell);					
							cell = setCellAttribute("วันที่เปิด Job : "+dJob,microssfont,"L","T",30,0);
							table.addCell(cell);					
						
							//-- line 2 --//
							cell = setCellAttribute("ลำดับที่ : "+Loop,microssfont,"L","T",60,0);
							table.addCell(cell);							
							cell = setCellAttribute("",microssfont,"L","T",10,0);
							table.addCell(cell);					
							cell = setCellAttribute("วันที่ Start Task : "+dStartTask,microssfont,"L","T",30,0);
							table.addCell(cell);							
						
							//-- line 3 --//
							cell = setCellAttribute("รายการซ่อม : "+doString.MS874ToUnicode(doString.checkString(rs.getString("c_itmjob"),"")),microssfont,"L","T",60,0);
							table.addCell(cell);			
							cell = setCellAttribute("",microssfont,"L","T",10,0);
							table.addCell(cell);					
							cell = setCellAttribute("วันที่ Complete Task : "+dComplete,microssfont,"L","T",30,0);
							table.addCell(cell);			
	
							//-- line 4 --//
							cell = setCellAttribute("ผู้รับเหมาซ่อม : "+doString.MS874ToUnicode(nVendor),microssfont,"L","T",100,0);
							table.addCell(cell);			
	
	
							//----------- start image area -----------//
							if (before[0].length()>0 || before[1].length()>0) {
								cell = setCellAttribute("\nภาพก่อนซ่อม",microssfont,"L","T",100,0);
								table.addCell(cell);
								addImage(before,iDocNo,table,microssfont);
							}
						
							if (process[0].length()>0 || process[1].length()>0) {
								cell = setCellAttribute("\nภาพระหว่างซ่อม",microssfont,"L","T",100,0);
								table.addCell(cell);
								addImage(process,iDocNo,table,microssfont);
							}
							
							if (after[0].length()>0 || after[1].length()>0) {
								cell = setCellAttribute("\nภาพหลังซ่อม",microssfont,"L","T",100,0);
								table.addCell(cell);
								addImage(after,iDocNo,table,microssfont);
							}																					
						} // end if
						else{
							//----------- found image , start new page -------------//
							table = new PdfPTable(100);
							table.setWidthPercentage(100);
							cb.addTemplate(page1,1,1);
							
							
							//---------- get other data --------//
							nVendor = "";
							itemStatus = "";
							dJob = "";
							dStartTask = "";
							dComplete = "";
							
							sql.delete(0,sql.length());
							sql.append(" select f_itmstatus,d_approve ,f.i_vendor,v.bus_name ")
								  .append(" from lan:serv_flow f ")
								  .append(" left join lan:stpvendr v on v.vend_code=f.i_vendor ")
								  .append(" where f.i_docno='"+iDocNo+"' and f.i_vendor='"+iVendor+"' ")
								  .append(" order by f.f_itmstatus ");
							rs1 = stmt1.executeQuery(sql.toString());
							//System.out.println("SQL get serv_flow :"+sql.toString());
							while (rs1.next()) {
								nVendor = doString.checkString(rs1.getString("bus_name"),"");
								itemStatus = doString.checkString(rs1.getString("f_itmstatus"),"");				
					
								if (itemStatus.equals("100")) {	
									dJob = getDateValue(rs1.getTimestamp("d_approve"));
								} 
								if (itemStatus.equals("200")) {
									dStartTask = getDateValue(rs1.getTimestamp("d_approve"));
								} 
								if (itemStatus.equals("300")) {
									dComplete = getDateValue(rs1.getTimestamp("d_approve"));
								}
							} // end while
							rs1.close();
						
							cell = setCellAttribute("Print Date : "+currDate,microssfont_MINI,"R","T",100,0);
							table.addCell(cell);
							cell = setCellAttribute("\nภาพประกอบการซ่อม\n\n\n",microssfont_BOLD,"C","T",100,0);
							table.addCell(cell);							
							//-- line 1 --//
							cell = setCellAttribute("เลขที่ใบแจ้งซ่อม : "+iDocNo,microssfont,"L","T",60,0);
							table.addCell(cell);					
							cell = setCellAttribute("",microssfont,"L","T",10,0);
							table.addCell(cell);					
							cell = setCellAttribute("วันที่เปิด Job : "+dJob,microssfont,"L","T",30,0);
							table.addCell(cell);											
							//-- line 2 --//
							cell = setCellAttribute("ลำดับที่ : "+Loop,microssfont,"L","T",60,0);
							table.addCell(cell);							
							cell = setCellAttribute("",microssfont,"L","T",10,0);
							table.addCell(cell);					
							cell = setCellAttribute("วันที่ Start Task : "+dStartTask,microssfont,"L","T",30,0);
							table.addCell(cell);													
							//-- line 3 --//
							cell = setCellAttribute("รายการซ่อม : "+doString.MS874ToUnicode(doString.checkString(rs.getString("c_itmjob"),"")),microssfont,"L","T",60,0);
							table.addCell(cell);			
							cell = setCellAttribute("",microssfont,"L","T",10,0);
							table.addCell(cell);					
							cell = setCellAttribute("วันที่ Complete Task : "+dComplete,microssfont,"L","T",30,0);
							table.addCell(cell);			
							//-- line 4 --//
							cell = setCellAttribute("ผู้รับเหมาซ่อม : "+doString.MS874ToUnicode(nVendor),microssfont,"L","T",100,0);
							table.addCell(cell);			
							//----------- start image area -----------//
							if (before[0].length()>0 || before[1].length()>0) {
								cell = setCellAttribute("\nภาพก่อนซ่อม",microssfont,"L","T",100,0);
								table.addCell(cell);
								addImage(before,iDocNo,table,microssfont);
							}					
							if (process[0].length()>0 || process[1].length()>0) {
								cell = setCellAttribute("\nภาพระหว่างซ่อม",microssfont,"L","T",100,0);
								table.addCell(cell);
								addImage(process,iDocNo,table,microssfont);
							}						
							if (after[0].length()>0 || after[1].length()>0) {
								cell = setCellAttribute("\nภาพหลังซ่อม",microssfont,"L","T",100,0);
								table.addCell(cell);
								addImage(after,iDocNo,table,microssfont);
							}						
						}						
						//----- start new page -----//	
						document.add(table);		
						document.newPage();	
						Loop++;
				} // end while rs
				rs.close();
			
	
				//----=========== Generate PDF ===============-----//
				document.close();
				res.setContentType("application/pdf");
				res.setContentLength(baos.size());
				ServletOutputStream outServ = res.getOutputStream();
				baos.writeTo(outServ);
				outServ.flush();
			}//DocId > 0
			//conn.commit();
			stmt.close();
			stmt1.close();			
			conn.close();
			conn = null;
		 } catch (DocumentException de) {
			 de.printStackTrace();
			 System.err.println("error SERV_OpenJobPrintImageServlet  DOCUMENT: " + de.getMessage());
		} catch (Exception e) {
			System.out.println(" ERROR "+mName+" : " + e.getMessage());
			System.out.println(" ERROR "+mName+" SQL : " + sql.toString());			
		} finally {
			try {
				if (rs!=null) rs.close(); 
				if (rs1!=null) rs1.close(); 
				if (stmt != null) stmt.close();
				if (stmt1 != null) stmt1.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");

	}

}
