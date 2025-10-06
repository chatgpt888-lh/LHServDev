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
public class SERV_PrintReport5Servlet extends DBServlet  {
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
	private Font microssfont_BOLD_UNDERLINE = null;
	private Font microssfont_HD = null;
	
	private int LIGHT_GRAY_COLOR = 15329769;
	private int DARK_GRAY_COLOR = 13882323;
	private Color  borderColor = new Color(153,153,153);
	
	int detailLength = 22;
	int dataLength = 6;
	
	
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
	
	
	public int printHeaderPage(PdfPTable table,String currDate,String showMonth,String showYear,String reportType,String[] projList,Vector projectName,Integer[] monthList,Integer[] yearList) {
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
		
		cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("บริษัท แลนด์ แอนด์ เฮ้าส์ จำกัด (มหาชน) \n สรุปงานซ่อมประจำเดือน "), microssfont_HD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setColspan(100);
		cell.setBorder(0);
		table.addCell(cell);
		cell = new PdfPCell(new Phrase("เดือน "+showMonth+"   พ.ศ. "+showYear+"    ,  ประเภท "+reportType+" เดือน", microssfont_HD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setColspan(50);
		cell.setBorder(0);
		table.addCell(cell);			
		cell = new PdfPCell(new Phrase("แบบรายงาน : SERV_PrintReport5 ,  "+currDate, microssfont));
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
		cell = new PdfPCell(new Phrase("รายละเอียดการแจ้งซ่อม", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(detailLength);
		cell.setBorder(15);
		table.addCell(cell);

		
		int loop = 0;
		for (int i=0;i<12;i++) {
			   String monthCol = "";
				if (i<Integer.parseInt(reportType)) {
				   monthCol = shortMonth[monthList[i].intValue()]+" "+Integer.toString(yearList[i].intValue()).substring(2,4);
				}
				
				cell = new PdfPCell(new Phrase(doString.checkString(monthCol,""), microssfont_BOLD));
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
		
		while (loop<12) {
			cell = new PdfPCell(new Phrase("", microssfont_BOLD));
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
		
		cell = new PdfPCell(new Phrase("รวม", microssfont_BOLD));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
		cell.setPaddingTop(4);
		cell.setPaddingLeft(4);
		cell.setPaddingBottom(6);
		cell.setBorderColor(borderColor);		
		cell.setColspan(dataLength);
		cell.setBorder(15);
		table.addCell(cell);		
		//----===========================================================================================-----//
		
		return totalLine;			 
	}
		
		
		

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
	
	
	public int checkEndPage(int line,Document document,PdfWriter writer,PdfPTable table,String currDate,String showMonth,String showYear,String reportType,String[] projList,Vector projectName,Integer[] monthList,Integer[] yearList) throws Exception {
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
			line = printHeaderPage(table,currDate,showMonth,showYear,reportType,projList,projectName,monthList,yearList);
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
		String reportType = doString.checkString(req.getParameter("report_type"),"0");
		String[] projList = req.getParameterValues("sel_proj");
		
		
		Integer previousList[] = newIntegerArray(12);
		Integer currentList[] = newIntegerArray(12);
		Integer completeList[] = newIntegerArray(12);
		Integer cancelList[] = newIntegerArray(12);
		Integer nextList[] = newIntegerArray(12);
		Integer inTimeList[] = newIntegerArray(12);
		Integer overTimeList[] = newIntegerArray(12);
		Integer pastInTimeList[] = newIntegerArray(12);
		Integer pastOverTimeList[] = newIntegerArray(12);
		Integer transferList[] = newIntegerArray(12);
		Integer sumTransferList[] = newIntegerArray(12);
		Integer expireList[] = newIntegerArray(12);
		Integer sumExpireList[] = newIntegerArray(12);
		Integer repairList[] = newIntegerArray(12);
		Double repairPriceList[] =  newDoubleArray(12);


		int previousTotal = 0;
		int currentTotal = 0;
		int completeTotal = 0;
		int cancelTotal = 0;
		int nextTotal = 0;
		int inTimeTotal = 0;
		int overTimeTotal = 0;
		int pastInTimeTotal = 0;
		int pastOverTimeTotal = 0;
		int transferTotal = 0;
		int sumTransferTotal = 0;
		int expireTotal = 0;
		int sumExpireTotal = 0;
		int repairTotal = 0;
		double repairPriceTotal = 0.0;		
		
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
			  
			  
			//---================== Get Summary Data ======================---//
			sql.delete(0,sql.length());
			sql.append(" select i_month,i_year, sum(q_request) as sum_req , sum(q_cancel) as sum_can , ")
				  .append(" sum(q_appoint_y) as sum_appy , sum(q_appoint_n) as sum_appn , ")
				  .append(" sum(q_bf_pasty) as sum_pasty , sum(q_bf_pastn) as sum_pastn , ")
				  .append(" sum(q_tranfer) as sum_trans , sum(q_tranfer_sum) as sum_trans_sum , ")
				  .append(" sum(q_nserv) as sum_nserv , sum(q_nserv_sum) as sum_nserv_sum , ")
				  .append(" sum(q_avg_doc) as sum_avg_doc , sum(q_avg_amt) as sum_avg_amt , ")
				  .append(" sum(q_complete) as sum_com from serv_sumrep where ")
				  .append(" i_company||':'||i_project in (").append(queryProject).append(") ")
				  .append(" and i_rep_type='01' group by i_month,i_year ");
			rs = stmt.executeQuery(sql.toString());
			while (rs.next()) {
				int  iMonth = rs.getInt("i_month");
				int  iYear = rs.getInt("i_year");

				for (int j=0;j<Integer.parseInt(reportType);j++) {
					  if (monthList[j].intValue()==iMonth && yearList[j].intValue()==iYear) {
						  currentList[j] = new Integer(rs.getInt("sum_req"));
						  completeList[j] = new Integer(rs.getInt("sum_can"));
						  cancelList[j] = new Integer(rs.getInt("sum_com"));

						  inTimeList[j] = new Integer(rs.getInt("sum_appy"));
						  overTimeList[j] = new Integer(rs.getInt("sum_appn"));
						  pastInTimeList[j] = new Integer(rs.getInt("sum_pastn"));
						  pastOverTimeList[j] = new Integer(rs.getInt("sum_pasty"));
						  transferList[j] = new Integer(rs.getInt("sum_trans"));
						  sumTransferList[j] = new Integer(rs.getInt("sum_trans_sum"));
						  expireList[j] = new Integer(rs.getInt("sum_nserv"));
						  sumExpireList[j] = new Integer(rs.getInt("sum_nserv_sum"));
						  repairList[j] = new Integer(rs.getInt("sum_avg_doc"));
						  repairPriceList[j] = new Double(rs.getDouble("sum_avg_amt"));

						 currentTotal += currentList[j].intValue();
						 completeTotal += completeList[j].intValue();
						 cancelTotal += cancelList[j].intValue();

						 inTimeTotal += inTimeList[j].intValue();
						 overTimeTotal += overTimeList[j].intValue();
						 pastInTimeTotal += pastInTimeList[j].intValue();
						 pastOverTimeTotal += pastOverTimeList[j].intValue();
						 transferTotal += transferList[j].intValue();
						 sumTransferTotal += sumTransferList[j].intValue();
						 expireTotal += expireList[j].intValue();
						 sumExpireTotal = sumExpireList[j].intValue();
						 repairTotal += repairList[j].intValue();
						 repairPriceTotal += repairPriceList[j].intValue();
					  }
				} // end for

			}
			rs.close();


			for (int i=0;i<Integer.parseInt(reportType);i++) {
					//----========== Get Previous Doc ==============-----//
					sql.delete(0,sql.length());
					sql.append(" select sum(q_request) - sum(q_cancel) - sum(q_complete) as sum_prev from serv_sumrep where ")
						  .append(" i_company||':'||i_project in (").append(queryProject).append(") ")
						  .append(" and i_rep_type='01' and d_start<'"+(yearList[i].intValue()-543)+"-"+str.createID(monthList[i].intValue(),2)+"-01' ");

					rs = stmt.executeQuery(sql.toString());
					while (rs.next()) {
						previousList[i] = new Integer(rs.getInt("sum_prev"));
						nextList[i] = new Integer((previousList[i].intValue() + currentList[i].intValue()) - (completeList[i].intValue() + cancelList[i].intValue()));

						previousTotal += previousList[i].intValue();
						nextTotal += nextList[i].intValue();
					}
					rs.close();
			} // end for			  
			  
			  			
			
			
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
		    line = printHeaderPage(table,currDate,showMonth,yearReport,reportType,projList,projectName,monthList,yearList);
		    
		    printDataList("ใบแจ้งซ่อมยกมา",table,previousList,reportType,"I");
		    line = checkEndPage(line,document,writer,table,currDate,showMonth,yearReport,reportType,projList,projectName,monthList,yearList);
		    document.add(table);
			table = new PdfPTable(100);
			table.setWidthPercentage(100); 
		    
			
			printDataList("ใบแจ้งซ่อมที่เกิดในเดือน",table,currentList,reportType,"I");
			line = checkEndPage(line,document,writer,table,currDate,showMonth,yearReport,reportType,projList,projectName,monthList,yearList);
			document.add(table);
			table = new PdfPTable(100);
			table.setWidthPercentage(100); 
			
			
			printDataList("ซ่อมเสร็จ (Complete แล้ว)",table,completeList,reportType,"I");
			line = checkEndPage(line,document,writer,table,currDate,showMonth,yearReport,reportType,projList,projectName,monthList,yearList);
			document.add(table);
			table = new PdfPTable(100);
			table.setWidthPercentage(100); 
			
			
			printDataList("ใบแจ้งซ่อมที่ยกเลิกในเดือน",table,cancelList,reportType,"I");
			line = checkEndPage(line,document,writer,table,currDate,showMonth,yearReport,reportType,projList,projectName,monthList,yearList);
			document.add(table);
			table = new PdfPTable(100);
			table.setWidthPercentage(100); 
			
			
			printDataList("งานซ่อมยกไป",table,nextList,reportType,"I");
			line = checkEndPage(line,document,writer,table,currDate,showMonth,yearReport,reportType,projList,projectName,monthList,yearList);
			document.add(table);
			table = new PdfPTable(100);
			table.setWidthPercentage(100); 
			
			
			printDataList("ซ่อมเสร็จ (ตามกำหนดนัดหมาย)",table,null,reportType,"I");
			line = checkEndPage(line,document,writer,table,currDate,showMonth,yearReport,reportType,projList,projectName,monthList,yearList);
			document.add(table);
			table = new PdfPTable(100);
			table.setWidthPercentage(100); 
			
			
			printDataList("     1. ตามกำหนดนัดหมาย",table,inTimeList,reportType,"I");
			line = checkEndPage(line,document,writer,table,currDate,showMonth,yearReport,reportType,projList,projectName,monthList,yearList);
			document.add(table);
			table = new PdfPTable(100);
			table.setWidthPercentage(100); 
			
			
			printDataList("     2. เลยกำหนดนัดหมาย",table,overTimeList,reportType,"I");
			line = checkEndPage(line,document,writer,table,currDate,showMonth,yearReport,reportType,projList,projectName,monthList,yearList);
			document.add(table);
			table = new PdfPTable(100);
			table.setWidthPercentage(100); 
			
			
			printDataList("งานซ่อมคงค้างยกไป",table,null,reportType,"I");
			line = checkEndPage(line,document,writer,table,currDate,showMonth,yearReport,reportType,projList,projectName,monthList,yearList);
			document.add(table);
			table = new PdfPTable(100);
			table.setWidthPercentage(100); 
			
			
			printDataList("     1. ยังไม่เลยกำหนดนัดหมาย",table,pastInTimeList,reportType,"I");
			line = checkEndPage(line,document,writer,table,currDate,showMonth,yearReport,reportType,projList,projectName,monthList,yearList);
			document.add(table);
			table = new PdfPTable(100);
			table.setWidthPercentage(100); 
			
			
			printDataList("     2. เลยกำหนดนัดหมาย",table,pastOverTimeList,reportType,"I");
			line = checkEndPage(line,document,writer,table,currDate,showMonth,yearReport,reportType,projList,projectName,monthList,yearList);
			document.add(table);
			table = new PdfPTable(100);
			table.setWidthPercentage(100); 
			
			
			printDataList("บ้านโอนในเดือน",table,transferList,reportType,"I");
			line = checkEndPage(line,document,writer,table,currDate,showMonth,yearReport,reportType,projList,projectName,monthList,yearList);
			document.add(table);
			table = new PdfPTable(100);
			table.setWidthPercentage(100); 
			
			
			printDataList("ยอดบ้านโอนสะสม",table,sumTransferList,reportType,"I");
			line = checkEndPage(line,document,writer,table,currDate,showMonth,yearReport,reportType,projList,projectName,monthList,yearList);
			document.add(table);
			table = new PdfPTable(100);
			table.setWidthPercentage(100); 
			
			
			printDataList("บ้านหมดประกันในเดือน",table,expireList,reportType,"I");
			line = checkEndPage(line,document,writer,table,currDate,showMonth,yearReport,reportType,projList,projectName,monthList,yearList);
			document.add(table);
			table = new PdfPTable(100);
			table.setWidthPercentage(100); 
			
			
			printDataList("ยอดบ้านหมดประกันสะสม",table,sumExpireList,reportType,"I");
			line = checkEndPage(line,document,writer,table,currDate,showMonth,yearReport,reportType,projList,projectName,monthList,yearList);
			document.add(table);
			table = new PdfPTable(100);
			table.setWidthPercentage(100); 
			
			
			printDataList("รายการแจ้งซ่อมของผู้รับเหมาซ่อม เฉลี่ยต่อใบ",table,repairList,reportType,"I");
			line = checkEndPage(line,document,writer,table,currDate,showMonth,yearReport,reportType,projList,projectName,monthList,yearList);
			document.add(table);
			table = new PdfPTable(100);
			table.setWidthPercentage(100); 
			
						
			printDataList("ราคางานแจ้งซ่อมของผู้รับเหมาซ่อม เฉลี่ยต่อใบ",table,repairPriceList,reportType,"D");
			

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
