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


/** 2015.12.23 modify change table  acxprjdt to serv_prjdt
 * @version 	1.0
 * @author
 */
public class SERV_PrintReqRetenServlet extends DBServlet  {
	
	
	public String[] getEmployeeDetails(Statement stmt1,String iEmploy) throws Exception {
		 String result[] = new String[] {"","",""};
		 ResultSet rs1 = null;
		 StringBuffer sql = new StringBuffer();

		 try { 
		
			//----- Find Emp Name -----//
			sql.delete(0,sql.length());
			sql.append("select trim(a.n_prename_th)||trim(a.n_nemploy_th)||' '||trim(a.n_semploy_th) as emp_name , ")
				  .append(" b.n_desc position from docflow:acemploy a ")
			  .append(" left join docflow:acempstd b on b.i_type='10' and b.i_code in ")
			  .append(" (select i_job from docflow:acempjob where i_employ=a.i_employ and d_job in ")
			  .append(" (select max(d_job) from docflow:acempjob where i_employ=a.i_employ)) ")
			  .append(" where a.i_employ='").append(iEmploy).append("' ");
			 rs1 = stmt1.executeQuery(sql.toString());
			 while (rs1.next()) {
			 result[0] = iEmploy;
			 result[1] = doString.checkString(rs1.getString("emp_name"),"");
			 result[2] = doString.checkString(rs1.getString("position"),"");
			 } // end while rs
			 rs1.close();	

		} catch (Exception e) {
		   System.out.println("SERV_Conf_RetReten.jsp : "+e.getMessage());
		} finally {
		   if (rs1!=null) rs1.close();
		}
 
		 return result;
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
			conn.setAutoCommit(false);
			stmt = conn.createStatement();	
			common = new SERV_CommonData(conn);		
				
		
			//----================== Get Inform Job From SERV_DOCHD ====================----//
			String projectName = "";
			String iSort = "";
			String iHouse = "";
			String iCompany = "";
			String iProject = "";
			String iSignBoard = "";
			String retCustName = "";
			String nCustName = "";
			String guranteeDesc = "";
			String retCustType = "";
			String iReten = "";
			String estChqDate = "";
			String dKeyin = "";
			String empName = "";
			String custTel = "";
			String empTel = "";
			String iEmploy = "";

			Vector iReceipt = new Vector();
			Vector zReceiveReten = new Vector();

			String fIDCard = "";
			String fLoseReten = "";
			String fNotice = "";
			String iNotice = "";
			double zReten = 0.0;
			
			
			//---===================== Keep Print Details to SERV_RETHD =====================----//
			sql.delete(0,sql.length());
			sql.append(" update lan:serv_rethd set ")
			      .append(" d_prn_req = current  ")
			      .append(" where i_docno='").append(iDocNo).append("' ");
			stmt.executeUpdate(sql.toString()); 
			conn.commit();		


			//----===================== get Reten Data From SERV_RETHD ======================----//
	    	sql.delete(0,sql.length());
			sql.append(" select b.i_company||'-'||b.i_project||'   '||b.n_project as project_name , c.n_desc , ")
				  .append(" trim(d.n_prename_th)||trim(d.n_nemploy_th)||' '||trim(d.n_semploy_th) as emp_name , ")
				  .append(" e.i_tel , a.* from lan:serv_rethd a ")
				  .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
				  .append(" left join lan:serv_xstd c on c.i_type='50' and c.i_code=a.i_doc_type ")
				  .append(" left join docflow:acemploy d on d.i_employ=a.i_staff_payback ")
			      .append(" left join lan:serv_prjdt e on e.i_company=a.i_company and e.i_project=a.i_project ")
//				  .append(" where a.i_doc_status='I' and a.z_reten=a.z_recv_reten and a.i_staff_payback is not null ")
			.append(" where 1=1")
				  .append(" and a.i_docno='").append(iDocNo).append("' ");

			rs = stmt.executeQuery(sql.toString());
			while (rs.next()) {
					 projectName = doString.checkString(rs.getString("project_name"),"");
					 iSort = doString.checkString(rs.getString("i_sort"),"");
					 iHouse = doString.checkString(rs.getString("i_house"),"");
					 iDocNo = doString.checkString(rs.getString("i_docno"),"");
					 iCompany = doString.checkString(rs.getString("i_company"),"");
					 iProject = doString.checkString(rs.getString("i_project"),"");
					 iSignBoard = doString.checkString(rs.getString("i_signboard"),"");
					 nCustName = doString.checkString(rs.getString("n_custo"),"");
					 guranteeDesc = doString.checkString(rs.getString("n_desc"),"");
					 retCustType = doString.checkString(rs.getString("i_ret_custo"),"");
					 iReten = doString.checkString(rs.getString("i_reten"),"");
					 empName = doString.checkString(rs.getString("emp_name"),"-");
				     iEmploy = doString.checkString(rs.getString("i_staff_payback"),"");
				     empTel = doString.checkString(rs.getString("i_tel"),"-");
				     custTel = doString.checkString(rs.getString("i_reten_tel"),"-");
					 zReten = rs.getDouble("z_reten");

					 fIDCard = doString.checkString(rs.getString("f_id_card"),"");
					 fLoseReten = doString.checkString(rs.getString("f_lost_reten"),"");
					 iNotice = doString.checkString(rs.getString("i_notice"),"");
					 if (iNotice.trim().length()>0) fNotice = "Y";

					//--------- get Cheque Date Estimate ----------//
					Calendar est = Calendar.getInstance(Locale.ENGLISH);
					Timestamp tmp = rs.getTimestamp("d_est_chq");
					if (tmp!=null) {
					 est.setTime(tmp); 
					 estChqDate = common.getDateFromCalendar(est);
					} else {
						 estChqDate = "";
					}
					
					//----------- get d_keyin ----------//
					est = Calendar.getInstance(Locale.ENGLISH);
					tmp = rs.getTimestamp("d_keyin");
					if (tmp!=null) {
					    est.setTime(tmp); 
					    dKeyin = common.getDateFromCalendar(est);
					} else {
						dKeyin = "";
					}					

			}
			rs.close();


			//-----========== Get retCustName ============-----//
			sql.delete(0,sql.length());
			if (retCustType.equals("1")) {
			sql.append(" select trim(n_prename)||trim(n_ncustomer)||' '||trim(n_scustomer) as cust_name ")
				  .append(" from lan:acxcusto where i_customer='").append(iReten).append("' ");
			} else if (retCustType.equals("2")) {
			sql.append(" select trim(n_pname)||trim(n_name)||' '||trim(n_sname) as cust_name,i_tel ")
				  .append(" from lan:serv_venprj where i_vendor='").append(iReten).append("' ")
				  .append(" and i_company='").append(iCompany).append("' and i_project='").append(iProject).append("' ")
				  .append(" and i_type='05' ");
			} else {
			sql.append(" select trim(n_pname)||trim(n_name)||' '||trim(n_sname) as cust_name,i_tel ")
				  .append(" from lan:serv_venprj where i_vendor='").append(iReten).append("' ")
				  .append(" and i_company='").append(iCompany).append("' and i_project='").append(iProject).append("' ")
				  .append(" and i_type='06' ");
			}
			rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
				retCustName = doString.checkString(rs.getString("cust_name"),"-");
				if (!retCustType.equals("1")) custTel = doString.checkString(rs.getString("i_tel"),"-");
			}
			rs.close();
			


			//-----========== Get Receive  ============-----//
			double sReceiveFromAcc = 0.0;
				sql.delete(0,sql.length());
			sql.append(" select * from lan:serv_payin where ")
				  .append(" i_company='").append(iCompany).append("' and i_project='").append(iProject).append("' ")
				  .append(" and i_sort='").append(iSort).append("' and i_docno='").append(iDocNo).append("' ");
				rs = stmt.executeQuery(sql.toString());
			while (rs.next()) {

				iReceipt.addElement(doString.checkString(rs.getString("i_receipt"),""));
				zReceiveReten.addElement(new Double(rs.getDouble("z_recv_reten")));

			} // end while rs
			rs.close();
			
			
			String empDetails[] = getEmployeeDetails(stmt,iEmploy);

			
			
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
			for (int page=0;page<2;page++) {
					table = new PdfPTable(100);
					table.setWidthPercentage(100);		
				    cb.addTemplate(page1, 1, 1);
			
					cell = new PdfPCell(new Phrase("", microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(50);
					cell.setBorder(0);
					table.addCell(cell);		
					cell = new PdfPCell(new Phrase(page==0 ? "ฉบับลูกค้า  " : "ฉบับโครงการ  " , microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(50);
					cell.setBorder(0);
					table.addCell(cell);					
					cell = new PdfPCell(new Phrase("\n\n\n\n\n", microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
					cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
					cell.setColspan(100);
					cell.setBorder(0);
					table.addCell(cell);			
					//cell = new PdfPCell(new Phrase("ใบรับเรื่องขอคืนเงินค้ำประกันการปลูกสร้างอาคารหรือต่อเติม\n\n", microssfont_HD));
					cell = new PdfPCell(new Phrase("ใบรับเรื่องขอคืนเงินค้ำประกันความเสียหายสาธารณูปโภคและพื้นที่บริการสาธารณะ\n\n", microssfont_HD));
					cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
					cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
					cell.setColspan(100);
					cell.setBorder(0);
					table.addCell(cell);			
		
		
					//----=========== Set InformJob Header ============----//
					cell = new PdfPCell(new Phrase("โครงการ : "+doString.MS874ToUnicode(projectName), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
					cell.setColspan(leftColumnWidth);
					cell.setBorder(0);
					table.addCell(cell);			
					cell = new PdfPCell(new Phrase("เลขที่ใบวางเงินค้ำประกัน : "+iDocNo, microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
					cell.setColspan(rightColumnWidth);
					cell.setBorder(0);
					table.addCell(cell);
		
		
					cell = new PdfPCell(new Phrase("บ้านเลขที่ : "+doString.MS874ToUnicode(iHouse)+"      แปลง : "+doString.MS874ToUnicode(iSort), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
					cell.setColspan(leftColumnWidth);
					cell.setBorder(0);
					table.addCell(cell);					
					cell = new PdfPCell(new Phrase("วันที่รับวางค้ำประกัน : "+doString.MS874ToUnicode(dKeyin), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
					cell.setColspan(rightColumnWidth);
					cell.setBorder(0);
					table.addCell(cell);
			
					
					cell = new PdfPCell(new Phrase("ชื่อผู้ขอคืนเงินประกัน : "+doString.MS874ToUnicode(retCustName), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
					cell.setColspan(leftColumnWidth);
					cell.setBorder(0);
					table.addCell(cell);			
					cell = new PdfPCell(new Phrase("เบอร์โทรติดต่อ : "+custTel, microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
					cell.setColspan(rightColumnWidth);
					cell.setBorder(0);
					table.addCell(cell);
					
					
					cell = new PdfPCell(new Phrase("ชื่อผู้รับเรื่องขอคืนเงินประกัน : "+doString.MS874ToUnicode(empName), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
					cell.setColspan(leftColumnWidth);
					cell.setBorder(0);
					table.addCell(cell);			
					cell = new PdfPCell(new Phrase("เบอร์โทรติดต่อเจ้าหน้าที่ : "+doString.MS874ToUnicode(empTel), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(rightColumnWidth);
					cell.setBorder(0);
					table.addCell(cell);

				cell = new PdfPCell(new Phrase("\n\n\n", microssfont));
				cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
				cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
				cell.setColspan(100);
				cell.setBorder(0);
				table.addCell(cell);		
				
				
				
					//----============== Add First Detail Line ==============----//
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n  ข้าพเจ้า   "), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(15);
					cell.setBorder(5);
					table.addCell(cell);			
									
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n"+retCustName), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(25);
					cell.setBorder(3);
					table.addCell(cell);	
					
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n   ผู้วางเงินค้ำประกันฯ เพื่อ   "), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(20);
					cell.setBorder(1);
					table.addCell(cell);	
					
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n"+nCustName), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(25);
					cell.setBorder(3);
					table.addCell(cell);		
					
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n   ในฐานะเจ้าบ้าน "), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(15);
					cell.setBorder(9);
					table.addCell(cell);	
					
					
					
					//----============== Add Second Detail Line ==============----//
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n  แปลงเลขที่   "), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(10);
					cell.setBorder(4);
					table.addCell(cell);			
										
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n"+iSort), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(15);
					cell.setBorder(2);
					table.addCell(cell);	
						
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n   บ้านเลขที่   "), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(10);
					cell.setBorder(0);
					table.addCell(cell);	
						
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n"+iHouse), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(15);
					cell.setBorder(2);
					table.addCell(cell);		
						
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n   โครงการ   "), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(10);
					cell.setBorder(0);
					table.addCell(cell);						
					
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n"+projectName), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(37);
					cell.setBorder(2);
					table.addCell(cell);			

					cell = new PdfPCell(new Phrase("\n", microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(3);
					cell.setBorder(8);
					table.addCell(cell);					
					
					
					
					
					//----============== Add Third Detail Line ==============----//
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n   มีความประสงค์ขอคืนเงินค้ำประกันตามใบวางเงินค้ำประกัน เลขที่ "), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(42);
					cell.setBorder(4);
					table.addCell(cell);							
					
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n"+iDocNo), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(23);
					cell.setBorder(2);
					table.addCell(cell);		
				
					cell = new PdfPCell(new Phrase("\n  โดยข้าพเจ้าได้นำเอกสารดังต่อไปนี้มายื่นให้กับ ", microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(35);
					cell.setBorder(8);
					table.addCell(cell);	
					



				    //----============== Add Fourth Detail Line ==============----//
					cell = new PdfPCell(new Phrase("\n   เจ้าหน้าที่ เพื่อดำเนินการขอคืนเงินค้ำประกันความเสียหายสาธารณูปโภคและพื้นที่บริการสาธารณะเรียบร้อยแล้ว \n\n\n", microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(100);
					cell.setBorder(12);
					table.addCell(cell);													
							
				
					
					//----====================  ID Card ====================-----//
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n                             [ "+(fIDCard.equalsIgnoreCase("Y") ? "X" : "   ")+" ]  สำเนาบัตรประชาชน \n"), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(100);
					cell.setBorder(12);
					table.addCell(cell);												
  				    //----====================  ID Card ====================-----//
					



				    //----====================  Reten ID ====================-----//
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n                             [ X ]  ใบวางเงินค้ำประกันความเสียหายสาธารณูปโภคและพื้นที่บริการสาธารณะ เลขที่ "), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(50);
					cell.setBorder(4);
					table.addCell(cell);	 
					
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n"+iDocNo), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(15);
					cell.setBorder(2);
					table.addCell(cell);	  

					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n                [ "+(fLoseReten.equalsIgnoreCase("Y") ? "X" : "   ")+" ]  ใบวางเงินค้ำประกันหาย \n"), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(35);
					cell.setBorder(8);
					table.addCell(cell);	  					
 	 		  	    //----====================  Reten ID ====================-----//
					
					
					
				    //----====================  SignBoard ====================-----//
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n                             [ X ]  ป้ายต่อเติม เลขที่ "), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(25);
					cell.setBorder(4);
					table.addCell(cell);	 
							
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n"+iSignBoard), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(15);
					cell.setBorder(2);
					table.addCell(cell);	  
		
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("  \n"), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(60);
					cell.setBorder(8);
					table.addCell(cell);	 			    
				    //----====================  SignBoard ====================-----//
				    
				    
				    
				    //----====================  Receiept ====================-----//
				    for (int l=0;l<iReceipt.size();l++) {
						String receiptNo = (String) iReceipt.elementAt(l);
					    Double recvReten = (Double) zReceiveReten.elementAt(l);				    	

						cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n                             [ X ]  ใบเสร็จรับเงิน เลขที่ "), microssfont));
						cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
						cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
						cell.setColspan(28);
						cell.setBorder(4);
						table.addCell(cell);	
						
						cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n"+receiptNo), microssfont));
						cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
						cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
						cell.setColspan(15);
						cell.setBorder(2);
						table.addCell(cell);		
						
						cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n   จำนวนเงิน "), microssfont));
						cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
						cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
						cell.setColspan(10);
						cell.setBorder(0);
						table.addCell(cell);		
						
						cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n"+format.format(recvReten.doubleValue())), microssfont));
						cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
						cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
						cell.setColspan(15);
						cell.setBorder(2);
						table.addCell(cell);		
						
						cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n บาท  \n"), microssfont));
						cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
						cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
						cell.setColspan(32);
						cell.setBorder(8);
						table.addCell(cell);							
				    }
				   //----====================  Receiept ====================-----//
				    
				    
		    
				    //----==================== Lost Notice ====================-----//
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n                             [ "+(iNotice.trim().length()>0 ? "X" : "   ")+" ]  ใบแจ้งความเลขที่ "), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(26);
					cell.setBorder(4);
					table.addCell(cell);	 
						
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n"+iNotice), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(15);
					cell.setBorder(2);
					table.addCell(cell);	  
	
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n      (กรณีใบเสร็จรับเงินหาย)  \n"), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(59);
					cell.setBorder(8);
					table.addCell(cell);	 
				   //----==================== Lost Notice ====================-----//

				
								    
		
					cell = new PdfPCell(new Phrase(doString.MS874ToUnicode("\n\n                        โดยทางบริษัท แลนด์ แอนด์ เฮ้าส์ จำกัด (มหาชน) ให้ข้าพเจ้าติดต่อรับเช็คภายในวันที่ "+estChqDate+"\n\n\n\n"), microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
					cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
					cell.setColspan(100);
					cell.setBorder(12);
					table.addCell(cell);		
			
		
					//----============ Footer of document =============-----//
					cell = new PdfPCell(new Phrase("\n ลงชื่อ  .............................................................  ผู้ขอคืนเงินประกัน", microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
					cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
					cell.setColspan(50);
					cell.setBorder(4);
					table.addCell(cell);		
					cell = new PdfPCell(new Phrase("\n ลงชื่อ  .............................................................  ผู้รับเรื่องขอคืนเงินประกัน", microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
					cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
					cell.setColspan(50);
					cell.setBorder(8);
					table.addCell(cell);
					cell = new PdfPCell(new Phrase("( "+doString.MS874ToUnicode(retCustName)+" )\n\n\n", microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
					cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
					cell.setColspan(50);
					cell.setBorder(6);
					table.addCell(cell);		
					cell = new PdfPCell(new Phrase("( "+doString.MS874ToUnicode(empName+" - "+empDetails[2])+" )\n\n\n", microssfont));
					cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
					cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
					cell.setColspan(50);
					cell.setBorder(10);
					table.addCell(cell);			
	
					
					document.add(table);		
					document.newPage();	
			
			}	// end for gen page					


			

			//----=========== Generate PDF ===============-----//
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

}
