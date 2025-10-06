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
public class SERV_PrintReport2Servlet extends DBServlet  {

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
	
	int projectLength = 23;
	int totalLength = 5;
	int dataLength = 3;  //  3*24 = 72
	
	
	public Integer[] newIntegerArray(int size) {
		Integer data[] = new Integer[size];
		for (int l=0;l<size;l++) {
			  data[l] = new Integer(0);
		}

		return data;
	}

	
	public int printHeaderPage(PdfPTable table,String currDate,String showMonth,String showYear,Vector projectName,Integer[] monthList,Integer[] yearList) {
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
		
		cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("บริษัท แลนด์ แอนด์ เฮ้าส์ จำกัด (มหาชน) \n สรุปจำนวนบ้านโอนย้อนหลัง 24 เดือน "), microssfont_HD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setColspan(100);
		cell.setBorder(0);
		table.addCell(cell);
		cell = new PdfPCell(new Phrase("เดือน "+showMonth+"   พ.ศ. "+showYear, microssfont_HD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setColspan(50);
		cell.setBorder(0);
		table.addCell(cell);			
		cell = new PdfPCell(new Phrase("แบบรายงาน : SERV_PrintReport2 ,  "+currDate, microssfont));
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
		cell = new PdfPCell(new Phrase("โครงการ", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(projectLength);
		cell.setBorder(13);
		table.addCell(cell);
	
		cell = new PdfPCell(new Phrase("สะสม", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_BOTTOM);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(totalLength);
		cell.setBorder(13);
		table.addCell(cell);		
				
		int oldYear = 0;
		int colspan = 0;
		boolean printYear = false;
		for (int i=0;i<24;i++) {
			   if (oldYear!=yearList[i].intValue()) {
				   if (oldYear>0) {
					    printYear = true;
					    cell = new PdfPCell(new Phrase(Integer.toString(oldYear), microssfont_BOLD));
						cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
						cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
						cell.setPaddingTop(4);
						cell.setPaddingLeft(4);
						cell.setPaddingBottom(6);
						cell.setBorderColor(borderColor);		
						cell.setColspan(dataLength*colspan);
						cell.setBorder(13);
						table.addCell(cell);
				   }
				   oldYear = yearList[i].intValue();
				   colspan=1;
			   } else {
				   colspan++;
				   printYear = false;
			   }
		} // end for

		cell = new PdfPCell(new Phrase(Integer.toString(oldYear) , microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(dataLength*colspan);
		cell.setBorder(13);
		table.addCell(cell);




		cell = new PdfPCell(new Phrase(" ", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(projectLength);
		cell.setBorder(14);
		table.addCell(cell);
	
		cell = new PdfPCell(new Phrase(" ", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(totalLength);
		cell.setBorder(14);
		table.addCell(cell);	
		
		for (int i=0;i<24;i++) {
			    String sMonth = shortMonth[monthList[i].intValue()];
				cell = new PdfPCell(new Phrase(sMonth, microssfont_BOLD));
				cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
				cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
				cell.setPaddingTop(4);
				cell.setPaddingLeft(4);
				cell.setPaddingBottom(6);
				cell.setBorderColor(borderColor);		
				cell.setColspan(dataLength);
				cell.setBorder(15);
				table.addCell(cell);			  
		} // end for		
		
		totalLine += 2;

		//----===========================================================================================-----//
		
		return totalLine;			 
	}
			
	
	public int checkEndPage(int line,Document document,PdfWriter writer,PdfPTable table,String currDate,String showMonth,String showYear,Vector projectName,Integer[] monthList,Integer[] yearList) throws Exception {
		line++;
		if (line>=27) {
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
			line = printHeaderPage(table,currDate,showMonth,showYear,projectName,monthList,yearList);
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

		String monthReport = doString.checkString(req.getParameter("month_report"),"0");
		String yearReport = doString.checkString(req.getParameter("year_report"),"0");
		String[] projList = req.getParameterValues("sel_proj");
		

		
		nowPage = 0;


		//----============ Declare Variables for input data ===========----//
		 StringBuffer sql = new StringBuffer();
		 Connection conn = null;
		 Statement stmt = null;
		 ResultSet rs = null;
		 SERV_CommonData common = null;
		 DecimalFormat format = new DecimalFormat("#,###,##0");


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

			 Integer monthList[] = newIntegerArray(25);
			 Integer yearList[] = newIntegerArray(25);
			 now.set(Integer.parseInt(yearReport),Integer.parseInt(monthReport)-1,1,0,0,0);

			 for (int i=0;i<25;i++) {
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
			  Hashtable projectList = new Hashtable();
			  Hashtable dataList = new Hashtable();
			  Integer totalData[] = newIntegerArray(25);			  
			  
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
							 
							projectList.put(proj,nProject);
							dataList.put(proj,newIntegerArray(25));						 
							 
						} // end while
						rs.close();

				  } // end for

			  } else {
				  queryProject = " 'NODATA' ";
			  }
			  
			  
			//-----================= Start Get Data From =================-----//
			for (int l=0;l<24;l++) {
				  sql.delete(0,sql.length());
				  sql.append(" select i_company,i_project ,count(*) as cnt from lan:acsregis ")
						.append(" where i_company||':'||i_project in (").append(queryProject).append(") ")
						.append(" and year(d_close_law)=").append(Integer.toString(yearList[l].intValue()-543))
						.append(" and month(d_close_law)=").append(monthList[l].toString())
						.append(" group by i_company,i_project ");
				  rs = stmt.executeQuery(sql.toString());
				  while (rs.next()) {
					  String comId = doString.checkString(rs.getString("i_company"),"");
					  String projId = doString.checkString(rs.getString("i_project"),"");
					  int count = rs.getInt("cnt");
					  Integer data[] = (Integer[]) dataList.get(comId+":"+projId);
					  if (data==null) {
						  data = newIntegerArray(25);
					  }

					  data[l+1] = new Integer(data[l+1].intValue()+count);
					  dataList.put(comId+":"+projId,data);

					  totalData[l+1] = new Integer(totalData[l+1].intValue()+count);
				  } // end while
				  rs.close();
			}


			  //----================= Find old transfer ================-----//
			  sql.delete(0,sql.length());
			  sql.append(" select i_company,i_project ,count(*) as cnt from lan:acsregis ")
					.append(" where i_company||':'||i_project in (").append(queryProject).append(") ")
					.append(" and d_close_law<'").append(Integer.toString(yearList[23].intValue()-543))
					.append("-").append(monthList[23].toString()).append("-01' ")
					.append(" group by i_company,i_project ");
			  rs = stmt.executeQuery(sql.toString());
			  while (rs.next()) {
				  String comId = doString.checkString(rs.getString("i_company"),"");
				  String projId = doString.checkString(rs.getString("i_project"),"");
				  int count = rs.getInt("cnt");
				  Integer data[] = (Integer[]) dataList.get(comId+":"+projId);
				  if (data==null) {
					  data = newIntegerArray(25);
				  }

				  data[0] = new Integer(data[0].intValue()+count);
				  dataList.put(comId+":"+projId,data);

				  totalData[0] = new Integer(totalData[0].intValue()+count);
			  } // end while
			  rs.close();			  
			  
			  			
			
			
			//----================ Initialize Variables for create PDF =====================---//
			BaseFont bf = BaseFont.createFont(Constants.FONT_ANGSANA_NORMAL, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
			BaseFont bfb = BaseFont.createFont(Constants.FONT_ANGSANA_BOLD, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
			microssfont = new Font(bf, 12, Font.NORMAL);
			microssfont_MINI = new Font(bf, 10, Font.NORMAL);
			microssfont_BOLD = new Font(bfb, 12, Font.NORMAL);
			microssfont_BOLD_UNDERLINE = new Font(bfb, 12, Font.UNDERLINE);
			microssfont_HD = new Font(bfb, 18, Font.NORMAL);

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
		    line = printHeaderPage(table,currDate,showMonth,yearReport,projectName,monthList,yearList);

			if (projList!=null) {
				for (int i=0;i<projList.length;i++) {
					   String proj = doString.checkString(projList[i],"");  
					   String nProject= (String) projectList.get(proj);
					   Integer data[] = (Integer[]) dataList.get(proj);

					   Calendar tmp = Calendar.getInstance(Locale.ENGLISH);
					   tmp.set(yearList[23].intValue()-543,monthList[23].intValue(),1);
					   tmp.add(Calendar.DATE,-1);
					   int endDate = tmp.get(Calendar.DATE);
					   String params = "'01','"+str.createID(monthList[0].intValue(),2)+"','"+(yearList[0].intValue()-543)+"',";
					   params += "'"+str.createID(endDate,2)+"','"+str.createID(monthList[23].intValue(),2)+"','"+(yearList[23].intValue()-543)+"'";
					   String showData = "<a href=\"javascript:goSubReport('"+proj+"',"+params+");\">"+proj+" "+nProject+"</a>";


						//----============= Start Print Data =================----//
						cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(proj+" "+nProject), microssfont));
						cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
						cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
						cell.setPaddingTop(4);
						cell.setPaddingLeft(4);
						cell.setPaddingBottom(6);
						cell.setBorderColor(borderColor);		
						cell.setColspan(projectLength);
						cell.setBorder(15);
						table.addCell(cell);		
						
						cell = new PdfPCell(new Phrase(format.format(data[0]), microssfont));
						cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
						cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
						cell.setPaddingTop(4);
						cell.setPaddingLeft(4);
						cell.setPaddingBottom(6);
						cell.setBorderColor(borderColor);		
						cell.setColspan(totalLength);
						cell.setBorder(15);
						table.addCell(cell);								
						  

						  for (int col=1;col<25;col++)  {
								cell = new PdfPCell(new Phrase(format.format(data[col]), microssfont));
								cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
								cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
								cell.setPaddingTop(4);
								cell.setPaddingLeft(4);
								cell.setPaddingBottom(6);
								cell.setBorderColor(borderColor);		
								cell.setColspan(dataLength);
								cell.setBorder(15);
								table.addCell(cell);
						  }
						  
						  line = checkEndPage(line,document,writer,table,currDate,showMonth,showYear,projectName,monthList,yearList);						  
						 document.add(table);
						 table = new PdfPTable(100);
						 table.setWidthPercentage(100); 
											  
				} // end for
			}
			

			//----============= Start Print Total Data =================----//
			cell = new PdfPCell(new Phrase("รวม     ", microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);		
			cell.setColspan(projectLength);
			cell.setBorder(15);
			table.addCell(cell);		
						
			cell = new PdfPCell(new Phrase(format.format(totalData[0]), microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setPaddingTop(4);
			cell.setPaddingLeft(4);
			cell.setPaddingBottom(6);
			cell.setBorderColor(borderColor);		
			cell.setColspan(totalLength);
			cell.setBorder(15);
			table.addCell(cell);								
						  

			  for (int col=1;col<25;col++)  {
					cell = new PdfPCell(new Phrase(format.format(totalData[col]), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
					cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
					cell.setPaddingTop(4);
					cell.setPaddingLeft(4);
					cell.setPaddingBottom(6);
					cell.setBorderColor(borderColor);		
					cell.setColspan(dataLength);
					cell.setBorder(15);
					table.addCell(cell);
			  }			
			
			
			

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
			 System.err.println("error SERV_PrintRerort2Servlet  DOCUMENT: " + de.getMessage());
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
