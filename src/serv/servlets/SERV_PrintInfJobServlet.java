package serv.servlets;
import java.io.*;
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
 * 
 * @version 	1.0
 * @author * Modify by pradoem 2016.05.03
 * display checkup message program from table serv_chkuplck  where i_docno
 * ----------------
 * Modify by pradoem 2015.06.25
 * print pdf support by condo
 * 2015.12.23 modify change table  acxprjdt to serv_prjdt
 */

public class SERV_PrintInfJobServlet extends DBServlet  {
	public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		String mName = new String(this.getClass().getName() + ".performTask: ");
		System.out.println(mName + "start.");
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
		User user = (User) obj;
		String empname = user.getEmpName();
		doString str = new doString();		 		
		String iDocNo = doString.checkString(req.getParameter("i_docno"),"");		
		String emp_serv = doString.checkString(req.getParameter("emp_serv"),"");
		String who = doString.checkString(req.getParameter("who"),"");
		StringBuffer sql = new StringBuffer();
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		SERV_CommonData common = null;
		 try {
			if (ds == null)
				getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
			stmt = conn.createStatement();	
			common = new SERV_CommonData(conn);					//----================== Get Inform Job From SERV_DOCHD ====================----//
			String inFormEmp = "";
			String projDesc = "";
			String iCompany = "";
			String iProject  = "";
			String nCustomer = "";
			String nCustTel = "";
			String iLock = "";
			String cDesc = "";
			String inFormDate = "";
			String housePlan = "";
			String houseId = "";
			String iCustomer = "";
			String guranteeDate = "";
			String custName = "";
			String custTel = "";
			String siteTel = "";
			String name_serv = "";
			String Prj_Condo = "";
			String iSystem = "";
			//---------------- NAME Co-Operate ---------------
			name_serv = "";			
			if (emp_serv.trim().length()>4) {
						sql.delete(0, sql.length());
						sql.append("select distinct i_employ, n_prename_th, n_nemploy_th, n_semploy_th ")
							 .append("from docflow:acemploy ")
							 .append("where i_employ = '"+emp_serv+"' ");		
						rs = stmt.executeQuery(sql.toString());
						if (rs.next()) {
							name_serv = doString.checkString(doString.DisplayThai(rs.getString("n_prename_th")))+doString.checkString(doString.DisplayThai(rs.getString("n_nemploy_th")))+" "+doString.checkString(doString.DisplayThai(rs.getString("n_semploy_th")));
						}						
			} else {
						sql.delete(0, sql.length());
						sql.append("select distinct i_cust, n_name, n_sname ")
							 .append("from lan:serv_cname ")
							 .append("where i_cust = '"+emp_serv+"' ");		
						rs = stmt.executeQuery(sql.toString());
						if (rs.next()) {
							name_serv = doString.checkString(doString.DisplayThai(rs.getString("n_name")))+" "+doString.checkString(doString.DisplayThai(rs.getString("n_sname")));
						}
			}// end if search Data 
			//---===================== Keep Print Details to SERV_HD =====================----//
			sql.delete(0,sql.length());
			sql.append(" update lan:serv_dochd set ")
			      .append(" d_print_inform = today , ")
			      .append(" i_employ_pinform = '").append(user.getEmpId()).append("' ")
			      .append(" where i_docno='").append(iDocNo).append("' ");
			 //System.out.println(sql.toString());
			stmt.executeUpdate(sql.toString()); 
			//----======================== Find DocHD Data =============================----//
			 Hashtable tmpHeader = common.getDocHeaderDetails(iDocNo);
			 inFormEmp = doString.checkString((String) tmpHeader.get("inform_emp"),"");
			 projDesc = doString.checkString((String) tmpHeader.get("proj_desc"),"");
			 iCompany = doString.checkString((String) tmpHeader.get("i_company"),"");
			 iProject = doString.checkString((String) tmpHeader.get("i_project"),"");
			 nCustomer = doString.checkString((String) tmpHeader.get("n_customer"),"");
			 nCustTel = doString.checkString((String) tmpHeader.get("n_cust_tel"),"");
			 iLock = doString.checkString((String) tmpHeader.get("i_lock"),"");
			 cDesc = doString.checkString((String) tmpHeader.get("c_desc"),"");
			 
			 /** Modify by pradoem 2016.05.03
			  * Desc: for print description checkup program
			  * ***/
			 if("Checkup Program".equalsIgnoreCase(cDesc)){		
				 String tempDescChk = "";
				 String tempDateChk = "";
				 sql.delete(0, sql.length());
				 sql.append(" select unique a.c_comment,b.d_chckup from lan:serv_chkuplck a,lan:serv_chkupdt b ")
				    .append(" where a.i_company = b.i_company ")
				    .append(" and a.i_project = b.i_project ")
				    .append(" and a.i_lock  = b.i_lock  ")
				    .append(" and a.i_chkseq = b.i_chkseq ")
				    .append(" and  a.i_docno = '"+iDocNo+"'  ");	

				rs = stmt.executeQuery(sql.toString());
				if (rs.next()){
					tempDescChk = doString.checkString(doString.DisplayThai(rs.getString("c_comment")));
					tempDateChk = doString.checkString(rs.getString("d_chckup"),"");
				}
				cDesc += " : "+tempDescChk;
				cDesc = str.replace(cDesc,"|break|","\n");		
				//Modify by pradoem : 2014.11.04
				iSystem = doString.checkString((String) tmpHeader.get("i_system"),"");
				if("".equals(iSystem)){
				   cDesc +="\nวันนัดหมาย : "+toDDMMYY_THAI2(tempDateChk); 
				}				
			}else{
				 cDesc = str.replace(cDesc,"|break|","\n");		
				 //Modify by pradoem : 2014.11.04
				 iSystem = doString.checkString((String) tmpHeader.get("i_system"),"");
				 if("".equals(iSystem)){
					 cDesc +="\nวันนัดหมาย : "+doString.checkString((String) tmpHeader.get("d_appoint_cust"),""); 
				 }	 
			} 

			inFormDate = doString.checkString((String) tmpHeader.get("inform_date"),"");
			siteTel = doString.checkString((String) tmpHeader.get("site_tel"),"");
			//-----===================================================================------//
			//---------------- Check Project is Condo ---------------
			  Prj_Condo = "";
			  sql.delete(0, sql.length());
			  sql.append("select * from lan:serv_condo ")
				 .append("where i_company = '"+iCompany+"' ")
				 .append("and i_project = '"+iProject+"' ");				 	
			  rs = stmt.executeQuery(sql.toString());
			  if (rs.next()==true) {
				  Prj_Condo = "Y";
			  }else{
				  Prj_Condo = "N";
			  }
			//----======================= Get Customer Details ===========================----//
			Hashtable tmpCust = common.getCustomerDetails(iCompany,iProject,iLock);
			housePlan = doString.checkString((String) tmpCust.get("i_model"),"");
			houseId = doString.checkString((String) tmpCust.get("i_house"),"");
			iLock = doString.checkString((String) tmpCust.get("i_lock"),"");
			iCustomer = doString.checkString((String) tmpCust.get("i_customer"),"");
			guranteeDate = doString.checkString((String) tmpCust.get("gurantee_date"),"");
			custName = doString.checkString((String) tmpCust.get("n_customer"),"");
			custTel = doString.checkString((String) tmpCust.get("n_cust_tel"),"");
			//-----===================================================================------//			
			
			//Modify by pradoem 2015.06.25
	        /** Last Update 2015.06.24 For Repair Condo ***/
	        String condoProfileArr[] = new String[] {"NO","","","","","",""};
	        condoProfileArr = GetCondoProfile(conn,iCompany,iProject);
	        if(condoProfileArr[0].equals("YES")){ //CASE : is Condo
	        	guranteeDate = condoProfileArr[3];
	        	//call_center = condoProfileArr[6];
	        }else{ // CASE : Not Condo 
	        }
	        //------------------------------------------
			//----================ Initialize Variables for create PDF =====================---//
			BaseFont bf = BaseFont.createFont(Constants.FONT_ANGSANA_NORMAL, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
			BaseFont bfb = BaseFont.createFont(Constants.FONT_ANGSANA_BOLD, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
			Font microssfont = new Font(bf, 12, Font.NORMAL);
			Font microssfont_MINI = new Font(bf, 10, Font.NORMAL);
			Font microssfont_BOLD = new Font(bfb, 12, Font.NORMAL);
			Font microssfont_BOLD_UNDERLINE = new Font(bfb, 12, Font.UNDERLINE);
			Font microssfont_HD = new Font(bfb, 16, Font.NORMAL);
			Document document = new Document(PageSize.A4, 30, 30, 10, 10);
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			PdfWriter writer = PdfWriter.getInstance(document, baos);
			PdfContentByte cb = writer.getDirectContent();

			PdfReader reader = new PdfReader(Constants.PDF_HEADER_TEMPLATE);
			PdfImportedPage page1 = writer.getImportedPage(reader, 1);
			document.open();
			cb.addTemplate(page1, 1, 1);

			PdfPTable table = new PdfPTable(100);
			table.setWidthPercentage(100);
			PdfPCell cell;
			int leftColumnWidth = 60;
			int rightColumnWidth = 40;
			String currDate = "";
			Calendar now = Calendar.getInstance(Locale.ENGLISH);
			currDate = str.createID(now.get(Calendar.DATE),2)+"/"+str.createID(now.get(Calendar.MONTH)+1,2);
			int nYear = now.get(Calendar.YEAR);
			if (nYear<2500) nYear += 543;
			currDate += "/"+str.createID(nYear,4);
			currDate += " , "+str.createID(now.get(Calendar.HOUR_OF_DAY),2)+":"+str.createID(now.get(Calendar.MINUTE),2);
			//----========= Add Space for Header ===========----//
			cell = new PdfPCell(new Phrase("Print Date : "+currDate, microssfont));
			//cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setColspan(100);
			cell.setBorder(0);
			table.addCell(cell);		
			cell = new PdfPCell(new Phrase("\n\n\n\n\n", microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(100);
			cell.setBorder(0);
			table.addCell(cell);			
			cell = new PdfPCell(new Phrase("ใบรับรายการซ่อม\n\n", microssfont_HD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(100);
			cell.setBorder(0);
			table.addCell(cell);			
			//----=========== Set InformJob Header ============----//
			cell = new PdfPCell(new Phrase("โครงการ : "+doString.MS874ToUnicode(projDesc), microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(leftColumnWidth);
			cell.setBorder(0);
			table.addCell(cell);			
			cell = new PdfPCell(new Phrase("เลขที่ใบแจ้งซ่อม : "+iDocNo, microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(rightColumnWidth);
			cell.setBorder(0);
			table.addCell(cell);

			cell = new PdfPCell(new Phrase("บ้านเลขที่ : "+doString.MS874ToUnicode(houseId)+"      แปลง : "+doString.MS874ToUnicode(iLock), microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(leftColumnWidth);
			cell.setBorder(0);
			table.addCell(cell);					
			cell = new PdfPCell(new Phrase("แบบบ้าน : "+doString.MS874ToUnicode(housePlan), microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(rightColumnWidth);
			cell.setBorder(0);
			table.addCell(cell);
			cell = new PdfPCell(new Phrase("วันที่รับเรื่องงานซ่อม : "+inFormDate, microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(leftColumnWidth);
			cell.setBorder(0);
			table.addCell(cell);			
			cell = new PdfPCell(new Phrase("วันหมดอายุประกัน : "+guranteeDate, microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(rightColumnWidth);
			cell.setBorder(0);
			table.addCell(cell);

			cell = new PdfPCell(new Phrase("ชื่อลูกค้า / ผู้แจ้ง : "+doString.MS874ToUnicode((custName.length()>0 ? custName+" / " : "")+nCustomer), microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(leftColumnWidth);
			cell.setBorder(0);
			table.addCell(cell);			
			cell = new PdfPCell(new Phrase("เบอร์ติดต่อ : "+doString.MS874ToUnicode((custTel.length()>0 ? custTel+" / " : "")+nCustTel), microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setColspan(rightColumnWidth);
			cell.setBorder(0);
			table.addCell(cell);
			if(Prj_Condo.equals("Y")){
				cell = new PdfPCell(new Phrase("ชื่อผู้รับรายการซ่อม : "+doString.MS874ToUnicode(name_serv), microssfont));
			}else{
				cell = new PdfPCell(new Phrase("ชื่อผู้รับรายการซ่อม : "+doString.MS874ToUnicode(inFormEmp)+" เจ้าหน้าที่เซอร์วิสเซ็นเตอร์", microssfont));
			}			
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(leftColumnWidth);
			cell.setBorder(0);
			table.addCell(cell);	
			/*if(Prj_Condo.equals("Y")){
				cell = new PdfPCell(new Phrase("เบอร์เจ้าหน้าที่ : "+doString.MS874ToUnicode(siteTel), microssfont));
			} else {
				cell = new PdfPCell(new Phrase("เบอร์เจ้าหน้าที่ : 1198 กด 2", microssfont));
			}*/
			if(condoProfileArr[0].equals("YES")){
				cell = new PdfPCell(new Phrase("เบอร์เจ้าหน้าที่ : "+doString.MS874ToUnicode(condoProfileArr[6]), microssfont));
			}else{
				cell = new PdfPCell(new Phrase("เบอร์เจ้าหน้าที่ : 1198 กด 2", microssfont));
			}
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(rightColumnWidth);
			cell.setBorder(0);
			table.addCell(cell);
			//----============== Add Comment Header Table ==============----//
			cell = new PdfPCell(new Phrase("\n", microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(100);
			cell.setBorder(0);
			table.addCell(cell);					
			cell = new PdfPCell(new Phrase("รายการซ่อมที่ลูกค้าแจ้ง", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(80);
			cell.setFixedHeight(22);
			cell.setBorder(15);
			table.addCell(cell);		
			cell = new PdfPCell(new Phrase("หมายเหตุ", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(20);
			cell.setFixedHeight(22);			
			cell.setBorder(15);
			table.addCell(cell);		

			//----============== Add Comment Detail Table ==============----//
			cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(cDesc), microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setColspan(80);
			cell.setFixedHeight(450);
			cell.setBorder(12);
			table.addCell(cell);		
			cell = new PdfPCell(new Phrase("\n", microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(20);
			cell.setFixedHeight(450);
			cell.setBorder(12);
			table.addCell(cell);				

			//----============ Footer of document =============-----//
			cell = new PdfPCell(new Phrase("ส่วนของลูกค้า", microssfont_MINI));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(50);
			cell.setBorder(13);
			table.addCell(cell);		
			cell = new PdfPCell(new Phrase("ส่วนของบริษัท", microssfont_MINI));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(50);
			cell.setBorder(13);
			table.addCell(cell);	
			/*
			cell = new PdfPCell(new Phrase("ลงชื่อผู้แจ้ง", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(50);
			cell.setBorder(12);
			table.addCell(cell);		
			cell = new PdfPCell(new Phrase("ลงชื่อผู้รับรายการ", microssfont_BOLD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(50);
			cell.setBorder(12);
			table.addCell(cell);		
			*/	
			cell = new PdfPCell(new Phrase("\n..........................................................................ผู้แจ้ง", microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(50);
			cell.setBorder(12);
			table.addCell(cell);		
			cell = new PdfPCell(new Phrase("\n..........................................................................เจ้าหน้าที่ควบคุมงานซ่อม", microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(50);
			cell.setBorder(12);
			table.addCell(cell);	
			cell = new PdfPCell(new Phrase("( "+doString.MS874ToUnicode((nCustomer.length()>0 ? nCustomer : custName))+" )\n\n", microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(50);
			cell.setBorder(14);
			table.addCell(cell);		
			if(Prj_Condo.equals("Y")){
				cell = new PdfPCell(new Phrase("( "+doString.MS874ToUnicode(name_serv)+" )\n\n", microssfont));
			} else {
				cell = new PdfPCell(new Phrase("( "+doString.MS874ToUnicode(empname)+" )\n\n", microssfont)); //name login (เดิม inFormEmp)
			}
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(50);
			cell.setBorder(14);
			table.addCell(cell);			
			cell = new PdfPCell(new Phrase("\n", microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(100);
			cell.setBorder(0);
			table.addCell(cell);	
			cell = new PdfPCell(new Phrase("หมายเหตุ", microssfont_BOLD_UNDERLINE));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(8);
			cell.setBorder(0);
			table.addCell(cell);						
			cell = new PdfPCell(new Phrase("รายการแจ้งซ่อมจะสมบูรณ์ต่อเมื่อบริษัทได้ออกเอกสารใบแจ้งซ่อมแล้วเท่านั้น", microssfont));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(92);
			cell.setBorder(0);
			table.addCell(cell);					
			
			//table.setBorder(0);
			document.add(table);			
			//----=========== Generate PDF ===============-----//
			document.close();
			res.setContentType("application/pdf");
			res.setContentLength(baos.size());
			ServletOutputStream outServ = res.getOutputStream();
			baos.writeTo(outServ);
			outServ.flush();
			stmt.close();
			conn.close();
			conn = null;
		 } catch (DocumentException de) {
			 de.printStackTrace();
			 System.err.println("error SERV_PrintInfJobServlet  DOCUMENT: " + de.getMessage());
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
	
	 public String[] GetCondoProfile(Connection conn,String comId,String projId){
	        StringBuffer sql = new StringBuffer();
	        Statement stmt = null;
	        ResultSet rs = null;

			boolean isCondo = false;
	        String tempStr[] = new String[] {"NO","","","","","",""}; //"YES,NO","LH","075","2015-06-24","Y,N","หมดประกัน/อยู่ระหว่างประกัน","0841013129"
	        java.sql.Timestamp dCloseLaw = null;
	        try {
	            stmt = conn.createStatement();
	            /*1. Check project is Condo avaliable ?*/
	  			sql.delete(0, sql.length());
				sql.append(" Select i_company,i_project,d_close_law,d_close_law-today as x  ")
					.append(" From  lan:serv_condo ")
					.append(" Where i_company  = '"+comId+"'  ")
					.append(" and i_project = '"+projId+"' ");

					//System.out.println("SQL GetCondo  :"+sql.toString());
					rs = stmt.executeQuery(sql.toString());    				   
				    if(rs.next()){
				       tempStr[0] = "YES";
				       tempStr[1] = doString.checkString(rs.getString("i_company"),"");
				       tempStr[2] = doString.checkString(rs.getString("i_project"),"");
				       //tempStr[3] = doString.checkString(rs.getString("d_close_law"),"");
				       dCloseLaw = rs.getTimestamp("d_close_law");	
				       
				        Calendar gurantee = Calendar.getInstance();
	                    gurantee.setTime(dCloseLaw);
	                   // gurantee.add(1, 1);       
	                    tempStr[3] = getDateFromCalendar(gurantee);
	                    
	                    if(rs.getInt("x")>0) {
							tempStr[4] = "Y";
		                    tempStr[5] = doString.DisplayThai(doString.UnicodeToMS874("อยู่ระหว่างประกัน"));
	                    } else{
		                    tempStr[4] = "N";
		                    tempStr[5] = doString.DisplayThai(doString.UnicodeToMS874("หมดประกัน"));
	                    }
	                    
				        isCondo = true;       
				    }else{
					    tempStr[0] = "NO";
					    tempStr[2] = "";
					    tempStr[3] ="";
					    tempStr[4] ="";
				    }
	 				/** CASE : Condo = true **/
	 				if(isCondo){					
		 				sql.delete(0, sql.length());
						sql.append(" Select i_tel ")
							.append(" From  lan:serv_prjdt ")
							.append(" Where i_company  = '"+comId+"'  ")
							.append(" and i_project = '"+projId+"' ");
							//System.out.println("SQL I_tel  :"+sql.toString());
						rs = stmt.executeQuery(sql.toString());    				   
					    if(rs.next()){
					    	tempStr[6] =  doString.checkString(rs.getString("i_tel"),"");
		 				}//#RS.Close
		 			}	  
	                rs.close();
	                stmt.close();
	                
	        }catch(Exception e) {
	            System.out.println(" GetCondoProfile[]  Error : " + e.getMessage());
	        } finally{
	            try  {
	                if(rs != null) {
	                    rs.close();
	                }
	                if(stmt != null){
	                    stmt.close();
	                }
	            }
	            catch(Exception ex) { }
	        }       
	        return tempStr;
	    }
	 

	    public String getDateFromCalendar(Calendar cal) {
	        String result = "";
	        if(cal == null){
	            return "-";
	        }
	        int year = cal.get(1);
	        if(year < 2400) {
	            year += 543;
	        }
	        doString str = new doString();
	        result = str.createID(cal.get(5), 2);
	        result = result + "/" + str.createID(cal.get(2) + 1, 2);
	        result = result + "/" + year;
	        return result;
	    }
	    
		private static  String toDDMMYY_THAI2(String str){
			 if ((str == null) || str.equals("")) {
				 return  str;
			 }else{
				 String d2[] = str.split("\\-"); //2013-03-29
				 return d2[2]+"/"+d2[1]+"/"+(Integer.parseInt(d2[0])+543);
			 }
		}
}
