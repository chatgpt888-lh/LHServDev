package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;

import java.awt.Color;
import com.lowagie.text.*;
import com.lowagie.text.pdf.*;

import serv.common.Constants;
import serv.common.User;

import com.lh.exception.InvalidParameterException;
import com.lh.servlet.DBServlet;
import com.lh.util.doString;
import com.lh.util.DateUtil;
import com.lh.util.CurrencyToThai;
public class PrintRetRetenServlet extends DBServlet {
  private static String cName = "/LHServ/PrintRetRetenServlet";
	int leftColumnWidth = 60;
	int rightColumnWidth = 40;
public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
    String mName = new String(cName + ".performTask: ");
    System.out.println(mName + "start.");
    /*HttpSession session = req.getSession(false);
    if (session == null) {
        res.sendRedirect("/LHServ/warning.htm");
        return;
    }
    Object obj = session.getAttribute("USER");
    if (obj == null) {
        res.sendRedirect("/LHServ/warning.htm");
        return;
    }
    User user = (User) obj;*/
    String empId = "";//user.getEmpId();    
	StringBuffer sql = new StringBuffer();	
    Connection conn = null;
    Statement stmt = null;
    Statement lckstmt = null;    
    ResultSet rs = null;
    ResultSet rsLock = null;    
    try {
		String comId = doString.checkString(req.getParameter("comId"));
		String projId = doString.checkString(req.getParameter("projId"));
		String docNo = doString.checkString(req.getParameter("docNo"));
		String company = "";
		String projDesc = "";
		String account = "";
		String lockId = "";
		String lorId = "";
		String houseNo = "";
		String retenType = "";
		String empName = "";
		String docType = "";
		String custName = "";
		String retenName = "";
		String retentId = "";
		String reqDate = "";
		String conDate = "";
		String prntDate = "";		
		String retenTel = "";
		String staffTel = "";
		String job = "";
		String labelNo = "";
		String desc = "";
		String bank = "";
		String branch = "";
		String bankNme = "";
		String receiptNo = "";
		String accountNme = "";
		double amount = 0;
		int conMnth = 0;
		 
		//---- 2022-06-30 , for payin ----//
		String iPayType = "";
		String iPayBnk = "";
		String nPayBnk = "";
		String iPayAcc = "";
		String iEmail = "";
		//-------------------------------//
		
		CurrencyToThai currencyToThai = null;
        if (ds == null)
            getDS();
        conn = ds.getConnection();
        conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
        conn.setAutoCommit(true);
        stmt = conn.createStatement();
        lckstmt = conn.createStatement();
        
		//rs = stmt.executeQuery("SELECT h.i_sort, h.d_keyin, h.i_doc_type, h.i_lor, h.n_custo, h.i_model, h.i_house, h.i_ret_custo, h.i_reten, h.i_reten_tel, h.d_beg_cons, h.i_mon_cons, NVL(h.z_reten,0) AS RETEN_AMT, h.c_advan, h.i_staff, h.i_doc_status, h.i_signboard, h.d_prn_reten, TRIM(e.n_prename_th) || ' ' || TRIM(e.n_nemploy_th) || ' ' || TRIM(e.n_semploy_th) AS EMP_NAME, h.i_pv_bank, h.i_pv_bran FROM lan:serv_rethd h, docflow:acemploy e WHERE h.i_company = '"+comId+"' AND h.i_project = '"+projId+"' AND h.i_docno = '"+docNo+"' AND h.i_staff = e.i_employ");
		
		//---- 2022-06-30 , change sql and join lhpay_std for bank name -----//
        sql.delete(0, sql.length());
		sql.append(" SELECT (TODAY-DATE(h.d_keyin)) AS NUM_DAY, NVL(h.z_reten,0) AS RETEN_AMT, ")
		   .append(" TRIM(e.n_prename_th) || ' ' || TRIM(e.n_nemploy_th) || ' ' || TRIM(e.n_semploy_th) AS EMP_NAME, ")
		   .append(" s.n_desc as n_paybnk, h.* ")
		   .append(" FROM lan:serv_rethd h ")
		   .append("   left join lan:lhpay_std s on s.i_type='R' and s.i_key1=h.i_paybnk ")
		   .append(" , docflow:acemploy e ")
		   .append(" WHERE h.i_company = '"+comId+"' AND h.i_project = '"+projId+"' ")
		   .append(" AND h.i_docno = '"+docNo+"' AND h.i_staff = e.i_employ ");
		rs = stmt.executeQuery(sql.toString());
		if (rs != null) {
			if (rs.next() == true) {
				lockId = doString.checkString(rs.getString("I_SORT"));
				lorId = Integer.toString(rs.getInt("I_LOR"));
				houseNo = doString.checkString(rs.getString("I_HOUSE"));
				docType = doString.checkString(rs.getString("I_DOC_TYPE"));
				custName = doString.checkString(rs.getString("N_CUSTO"));
				retenType = doString.checkString(rs.getString("I_RET_CUSTO"));
				retentId = doString.checkString(rs.getString("I_RETEN"));
				retenTel = doString.checkString(rs.getString("I_RETEN_TEL"));
				empName = doString.checkString(rs.getString("EMP_NAME"));
				reqDate = DateUtil.ifxToThaiDateNoTime(rs.getString("D_KEYIN"));
				conDate = DateUtil.ifxToThaiDateNoTime(rs.getString("D_BEG_CONS"));
				amount = rs.getDouble("RETEN_AMT");
				conMnth = rs.getInt("I_MON_CONS");
				labelNo = doString.checkString(rs.getString("I_SIGNBOARD"));
				prntDate = doString.checkString(rs.getString("D_PRN_RETEN"));				
				
				//---- 2022-06-30 , for payin ----//
				iPayType = doString.checkString(rs.getString("i_paytype"),"");
				iPayBnk = doString.checkString(rs.getString("i_paybnk"),"");
				nPayBnk = doString.checkString(rs.getString("n_paybnk"),"");
				iPayAcc = doString.checkString(rs.getString("i_payacc"),"");
				iEmail = doString.checkString(rs.getString("i_email"),"");
				//-------------------------------//						
			}
			rs.close();
			rs=null;
		}
		
		rs = stmt.executeQuery("SELECT i_receipt FROM lan:serv_payin WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+docNo+"'");
		if (rs != null) {
			if (rs.next() == true) {
				receiptNo = Integer.toString(rs.getInt("I_RECEIPT"));
			}
			rs.close();
			rs=null;
		}
		
		rs = stmt.executeQuery("SELECT i_tbank, i_tbranch, i_account FROM lan:acrdtrec WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lor = "+lorId+" AND i_receipt = "+receiptNo);
		if (rs != null) {
			if (rs.next() == true) {
				bank = doString.checkString(rs.getString("I_TBANK"));
				branch = doString.checkString(rs.getString("I_TBRANCH"));
				account = doString.checkString(rs.getString("I_ACCOUNT"));
			}
			rs.close();
			rs=null;
		}
        rs = stmt.executeQuery("SELECT n_account FROM lan:acraccnt WHERE i_company = '"+comId+"' AND i_bank = '"+bank+"' AND i_branch = '"+branch+"' AND i_account = '"+account+"'");
        if(rs != null) {
            if(rs.next() == true) {
                accountNme = doString.checkString(rs.getString("N_ACCOUNT"));
            }
            rs.close();
            rs = null;
        }
        
        rs = stmt.executeQuery("SELECT n_finance FROM lan:acxfinan WHERE i_finance = '"+bank+"' AND i_branch IS NULL");
        if(rs != null) {
            if(rs.next() == true) {
                bankNme = doString.checkString(rs.getString("N_FINANCE"));
            }
            rs.close();
            rs = null;
        }
        
		sql.delete(0,sql.length());
		sql.append(" update lan:serv_rethd set ")
				  .append(" d_prn_reten = today , ")
				  .append(" i_prn_reten = '").append(empId).append("' ")
				  .append(" where i_company='").append(comId).append("' ")
				  .append(" and i_project ='").append(projId).append("' ")
				  .append(" and i_docno='").append(docNo).append("' ");
		stmt.executeUpdate(sql.toString());
		
		currencyToThai = new CurrencyToThai(amount);
		if (retenType.equals("1")) {
			retenType = "04";
			rs = stmt.executeQuery("SELECT n_prename, n_ncustomer, n_scustomer FROM lan:acxcusto WHERE i_customer = "+retentId);
			if (rs != null) {
				if (rs.next() == true) {
					retenName = doString.checkString(rs.getString("N_PRENAME"))+" "+doString.checkString(rs.getString("N_NCUSTOMER"))+ " "+doString.checkString(rs.getString("N_SCUSTOMER"));;
				}
				rs.close();
				rs=null;
			}
		} else {
			if (retenType.equals("2")) {
				retenType = "05";
			} else {
				retenType = "06";
			}
			rs = stmt.executeQuery("SELECT n_pname, n_name, n_sname, i_tel FROM lan:serv_venprj WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_type = '"+retenType+"' AND i_vendor = '"+retentId+"'");
			if (rs != null) {
				if (rs.next() == true) {
					retenName = doString.checkString(rs.getString("N_PNAME"))+" "+doString.checkString(rs.getString("N_NAME"))+" "+doString.checkString(rs.getString("N_SNAME"));
					retenTel = doString.checkString(rs.getString("I_TEL"));
				}
				rs.close();
				rs=null;
			}
		}
		rs = stmt.executeQuery("SELECT n_company FROM lan:acxcompa WHERE i_company = '"+comId+"'");
		if (rs != null) {
			if (rs.next() == true) {
				company = doString.checkString(rs.getString("N_COMPANY"));
			}// end if
			rs.close();
			rs=null;
		}
/*		
		rs = stmt.executeQuery("SELECT n_account FROM docflow:icv_acctn WHERE i_system = 'RET' AND i_com_exp = '"+comId+"' AND i_bank = '"+bank+"' AND i_bran = '"+branch+"'");
		if (rs != null) {
			if (rs.next() == true) {
				account = doString.checkString(rs.getString("N_ACCOUNT"));
			}// end if
			rs.close();
			rs=null;
		}
*/		
		rs = stmt.executeQuery("SELECT n_project FROM lan:acxprojt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
		if (rs != null) {
			if (rs.next() == true) {
				projDesc = doString.checkString(rs.getString("N_PROJECT"));
			}// end if
			rs.close();
			rs=null;
		}
		rs = stmt.executeQuery("SELECT i_tel FROM lan:serv_prjdt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
		if (rs != null) {
			if (rs.next() == true) {
				staffTel = doString.checkString(rs.getString("I_TEL"));
			}// end if
			rs.close();
			rs=null;
		}
		rs = stmt.executeQuery("SELECT n_desc FROM lan:serv_xstd WHERE i_type = '50' AND i_code = '"+docType+"'");
		if (rs != null) {
			if (rs.next() == true) {
				job = doString.checkString(rs.getString("N_DESC"));
			}// end if
			rs.close();
			rs=null;
		}
		
        // create simple doc and write to a ByteArrayOutputStream
		BaseFont bf;
		BaseFont bfb;
		Font microssfont;
		Font microssfont_MINI;
		Font microssfont_BOLD;
		Font microssfont_BOLD_UNDERLINE;
		Font microssfont_HD;
		Font microssfont_MED;
		Font microssfont_MED_UNDERLINE;
		Font microssfont_MED_BOLD;
		Font microssfont_MED_BOLD_UNDERLINE;
		
		bf = BaseFont.createFont(Constants.FONT_ANGSANA_NORMAL, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
		bfb = BaseFont.createFont(Constants.FONT_ANGSANA_BOLD, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
		microssfont = new Font(bf, 14, Font.NORMAL);
		microssfont_MINI = new Font(bf, 10, Font.NORMAL);
		microssfont_MED = new Font(bf, 12, Font.NORMAL);
		microssfont_MED_UNDERLINE = new Font(bf, 12, Font.UNDERLINE);
		microssfont_MED_BOLD = new Font(bfb, 13, Font.BOLD);
		microssfont_MED_BOLD_UNDERLINE = new Font(bfb, 13, Font.UNDERLINE);
		microssfont_BOLD = new Font(bfb, 14, Font.NORMAL);
		microssfont_BOLD_UNDERLINE = new Font(bfb, 14, Font.UNDERLINE);
		microssfont_HD = new Font(bfb, 16, Font.NORMAL);

		Document document = new Document();
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		PdfWriter writer = PdfWriter.getInstance(document, baos);
		PdfContentByte cb = writer.getDirectContent();


		PdfReader reader = new PdfReader(Constants.PDF_HEADER_TEMPLATE);
		PdfImportedPage page1 = writer.getImportedPage(reader, 1);

		document.open();

		PdfPTable table;
		PdfPCell cell;
		cb.addTemplate(page1, 1, 1);		

		for (int p=1; p<=2; p++) {
			if (p == 1)
				desc = "สำหรับลูกค้า";
			else 	
				desc = "สำหรับโครงการ";			
			if (!prntDate.equals("")) {
				desc += " (reprint)";
			}
			cb.addTemplate(page1, 1, 1);
			table = new PdfPTable(100);
			table.setWidthPercentage(100);
			//----========= Add Space for Header ===========----//
			cell = new PdfPCell(new Phrase(desc, microssfont_MED));
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setColspan(100);
			cell.setBorder(0);
			table.addCell(cell);					
			cell = new PdfPCell(new Phrase("\n\n\n\n\n", microssfont_MED));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(100);
			cell.setBorder(0);
			table.addCell(cell);			
			cell = new PdfPCell(new Phrase("ใบวางเงินค้ำประกันความเสียหายสาธารณูปโภคและพื้นที่บริการสาธารณะ\n\n", microssfont_HD));
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(100);
			cell.setBorder(0);
			table.addCell(cell);			
	
	
			//----=========== Set InformJob Header ============----//
			cell = new PdfPCell(new Phrase("โครงการ : "+doString.MS874ToUnicode(projDesc), microssfont_MED));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(leftColumnWidth);
			cell.setBorder(0);
			table.addCell(cell);			
			cell = new PdfPCell(new Phrase("เลขที่ใบวางเงินค้ำประกัน : "+docNo, microssfont_MED));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(rightColumnWidth);
			cell.setBorder(0);
			table.addCell(cell);
	
	
			cell = new PdfPCell(new Phrase("บ้านเลขที่ : "+houseNo+"      แปลง : "+lockId, microssfont_MED));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(leftColumnWidth);
			cell.setBorder(0);
			table.addCell(cell);			
			cell = new PdfPCell(new Phrase("วันที่รับวางค้ำประกัน : "+reqDate, microssfont_MED));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(rightColumnWidth);
			cell.setBorder(0);
			table.addCell(cell);
			
			
			cell = new PdfPCell(new Phrase("ชื่อผู้วางเงิน : "+doString.MS874ToUnicode(retenName), microssfont_MED));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(leftColumnWidth);
			cell.setBorder(0);
			table.addCell(cell);			
			cell = new PdfPCell(new Phrase("เบอร์โทรติดต่อ : "+doString.MS874ToUnicode(retenTel), microssfont_MED));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setColspan(rightColumnWidth);
			cell.setBorder(0);
			table.addCell(cell);
							
				
			cell = new PdfPCell(new Phrase("ชื่อผู้รับวางเงินประกัน : "+doString.MS874ToUnicode(empName), microssfont_MED));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(leftColumnWidth);
			cell.setBorder(0);
			table.addCell(cell);			
			cell = new PdfPCell(new Phrase("เบอร์เจ้าหน้าที่ : "+doString.MS874ToUnicode(staffTel), microssfont_MED));
			cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			cell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			cell.setColspan(rightColumnWidth);
			cell.setBorder(0);
			table.addCell(cell);		
	
			document.add(table);
			
			Table ctable = new Table(100);
	        ctable.setCellsFitPage(true); 
	        ctable.setAutoFillEmptyCells(true); 		
	        ctable.setBorder(0);
			ctable.setPadding(1);
	        ctable.setSpacing(0);
	        ctable.setWidth(100);        
			Cell ccell = null;
			ccell = new Cell(new Phrase("\n", microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(100);
			ccell.setBorder(0);
			ctable.addCell(ccell);			
	
			ccell = new Cell(new Phrase("\n", microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(100);
			ccell.setBorder(13);
			ctable.addCell(ccell);	
			
			ccell = new Cell(new Phrase(" " , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(9);			
			ccell.setBorder(4);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase("ข้าพเจ้า" , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(6);			
			ccell.setBorder(0);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase(doString.MS874ToUnicode(retenName) , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(27);			
			ccell.setBorder(2);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase("ผู้วางเงินค้ำประกันฯ เพื่อ" , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(16);			
			ccell.setBorder(0);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase(doString.MS874ToUnicode(custName) , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(29);			
			ccell.setBorder(2);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase("ในฐานะเจ้าของบ้าน" , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(13);			
			ccell.setBorder(8);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase("\n", microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(100);
			ccell.setBorder(12);
			ctable.addCell(ccell);					
			ccell = new Cell(new Phrase(" แปลงเลขที่" , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(9);			
			ccell.setBorder(4);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase(lockId , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(27);			
			ccell.setBorder(2);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase("บ้านเลขที่" , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(7);			
			ccell.setBorder(0);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase(houseNo , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(18);			
			ccell.setBorder(2);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase("โครงการ" , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(7);			
			ccell.setBorder(0);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase(projId+" "+doString.MS874ToUnicode(projDesc) , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(32);			
			ccell.setBorder(10);
			ctable.addCell(ccell);			
			
			
			ccell = new Cell(new Phrase("\n", microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(100);
			ccell.setBorder(12);
			ctable.addCell(ccell);					
			ccell = new Cell(new Phrase(" ได้นำเงินฝากเข้าบัญชี" , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(14);			
			ccell.setBorder(4);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase(doString.MS874ToUnicode(company), microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(34);			
			ccell.setBorder(2);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase("บัญชีเลขที่" , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(8);			
			ccell.setBorder(0);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase(accountNme, microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(20);			
			ccell.setBorder(2);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase(doString.MS874ToUnicode(bankNme) , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(24);			
			ccell.setBorder(8);
			ctable.addCell(ccell);			
	
			ccell = new Cell(new Phrase("\n", microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(100);
			ccell.setBorder(12);
			ctable.addCell(ccell);					
			ccell = new Cell(new Phrase(" จำนวนเงิน " , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(31-4);			
			ccell.setBorder(4);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase(doString.displayNumber("###,###,###.00", amount) + " ("+doString.MS874ToUnicode(currencyToThai.getString())+")", microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(45+4);			
			ccell.setBorder(2);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase("เพื่อเป็นหลักประกันในการค้ำประกัน" , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(24);			
			ccell.setBorder(8);
			ctable.addCell(ccell);			
	
	
			ccell = new Cell(new Phrase("\n", microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(100);
			ccell.setBorder(12);
			ctable.addCell(ccell);					
			ccell = new Cell(new Phrase(doString.MS874ToUnicode(job), microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(26);			
			ccell.setBorder(6);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase("ตั้งแต่วันที่" , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(7);			
			ccell.setBorder(0);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase(conDate, microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(16);			
			ccell.setBorder(2);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase("และคาดว่าจะใช้เวลาในการก่อสร้างจนแล้วเสร็จประมาณ" , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(35);			
			ccell.setBorder(0);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase(Integer.toString(conMnth), microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(10);			
			ccell.setBorder(2);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase("เดือน" , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(6);			
			ccell.setBorder(8);
			ctable.addCell(ccell);			
			
			ccell = new Cell(new Phrase("\n", microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(100);
			ccell.setBorder(12);
			ctable.addCell(ccell);									
			ccell = new Cell(new Phrase(" " , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(9);			
			ccell.setBorder(4);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase("โดยข้าพเจ้า จะปฏิบัติตามระเบียบปฏิบัติในการปลูกสร้างอาคาร หรือต่อเติมของบริษัทฯ และยินยอมวางเงินค้ำประกันความเสียหายระบบ" , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(91);			
			ccell.setBorder(8);
			ctable.addCell(ccell);			
	
			ccell = new Cell(new Phrase("\n", microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(100);
			ccell.setBorder(12);
			ctable.addCell(ccell);									
			ccell = new Cell(new Phrase(" สาธารณูปโภคในโครงการตามอัตราที่บริษัทกำหนด ทั้งนี้หากเงินค้ำประกันฯ ไม่เพียงพอที่จะชำระความเสียหายที่เกิดขึ้น ข้าพเจ้าฯ ตกลงรับผิดชอบเต็มจำนวน" , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(100);			
			ccell.setBorder(12);
			ctable.addCell(ccell);			
	
			ccell = new Cell(new Phrase("\n", microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(100);
			ccell.setBorder(12);
			ctable.addCell(ccell);									
			ccell = new Cell(new Phrase(" ความเสียหายที่เกิดขึ้นดังกล่าว และข้าพเจ้าฯ ได้รับป้ายต่อเติมเลขที่" , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(41);			
			ccell.setBorder(4);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase(doString.UnicodeToMS874(labelNo), microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(29);			
			ccell.setBorder(2);
			ctable.addCell(ccell);			
			ccell = new Cell(new Phrase("ไว้เรียบร้อยแล้ว" , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(30);			
			ccell.setBorder(8);
			ctable.addCell(ccell);
			
			
			
			//----- 2022-06-30 , insert payin details -----//
    		//// space line
			ccell = new Cell(new Phrase("\n\n", microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(100);
			ccell.setBorder(12);
			ctable.addCell(ccell);	
			
			
			if (iPayType.equalsIgnoreCase("PAYIN")) {
				//--- payin , print data with space ---//
        		if (iPayAcc.length()>=10 && iPayAcc.indexOf("-")<0) {
        			iPayAcc = iPayAcc.substring(0,3)+"-"+iPayAcc.substring(3,4)+"-"+iPayAcc.substring(4,9)+"-"+iPayAcc.substring(9);
        		}
        		
    			///// text line 1
    			ccell = new Cell(new Phrase(" " , microssfont_MED));
    			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
    			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
    			ccell.setColspan(9);			
    			ccell.setBorder(4);
    			ctable.addCell(ccell);			
    			ccell = new Cell(new Phrase("ข้าพเจ้าประสงค์ให้บริษัทคืนเงินด้วยวิธีการโอนเงินเข้าบัญชีธนาคาร", microssfont_MED));
    			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
    			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
    			ccell.setColspan(42);			
    			ccell.setBorder(0);
    			ctable.addCell(ccell);
    			ccell = new Cell(new Phrase(" "+doString.MS874ToUnicode(nPayBnk) , microssfont_MED_BOLD));
    			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
    			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
    			ccell.setColspan(24);			
    			ccell.setBorder(2);
    			ctable.addCell(ccell);	
    			ccell = new Cell(new Phrase("  เลขที่บัญชี", microssfont_MED));
    			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
    			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
    			ccell.setColspan(8);			
    			ccell.setBorder(0);
    			ctable.addCell(ccell);	    
    			ccell = new Cell(new Phrase("  "+iPayAcc, microssfont_MED_BOLD));
    			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
    			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
    			ccell.setColspan(14);			
    			ccell.setBorder(2);
    			ctable.addCell(ccell);	    			
    			ccell = new Cell(new Phrase(" " , microssfont_MED));
    			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
    			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
    			ccell.setColspan(3);			
    			ccell.setBorder(8);
    			ctable.addCell(ccell);	
    			///// text line 2
    			ccell = new Cell(new Phrase("  ชื่อบัญชี " , microssfont_MED));
    			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
    			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
    			ccell.setColspan(6);			
    			ccell.setBorder(4);
    			ctable.addCell(ccell);   
    			ccell = new Cell(new Phrase("  "+doString.MS874ToUnicode(retenName), microssfont_MED_BOLD));
    			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
    			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
    			ccell.setColspan(30);			
    			ccell.setBorder(2);
    			ctable.addCell(ccell);	
    			ccell = new Cell(new Phrase(" " , microssfont_MED));
    			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
    			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
    			ccell.setColspan(64);			
    			ccell.setBorder(8);
    			ctable.addCell(ccell);	    						
			} else {
				//--- payto , print space ---//		
    			///// text line 1
    			ccell = new Cell(new Phrase(" " , microssfont_MED));
    			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
    			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
    			ccell.setColspan(9);			
    			ccell.setBorder(4);
    			ctable.addCell(ccell);			
    			ccell = new Cell(new Phrase("ข้าพเจ้าประสงค์ให้บริษัทคืนเงินด้วยวิธีการทำเช็ค สั่งจ่ายในนาม ", microssfont_MED));
    			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
    			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
    			ccell.setColspan(40);			
    			ccell.setBorder(0);
    			ctable.addCell(ccell);
    			ccell = new Cell(new Phrase(" "+doString.MS874ToUnicode(retenName) , microssfont_MED_BOLD));
    			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
    			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
    			ccell.setColspan(30);			
    			ccell.setBorder(2);
    			ctable.addCell(ccell);	    			
    			ccell = new Cell(new Phrase(" " , microssfont_MED));
    			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
    			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
    			ccell.setColspan(21);			
    			ccell.setBorder(8);
    			ctable.addCell(ccell);	
    			///// space line
    			ccell = new Cell(new Phrase("\n", microssfont_MED));
    			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
    			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
    			ccell.setColspan(100);
    			ccell.setBorder(12);
    			ctable.addCell(ccell);					
			}		
			
			///// space line
			ccell = new Cell(new Phrase("\n\n\n", microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(100);
			ccell.setBorder(12);
			ctable.addCell(ccell);				
			//---------------------------------------------//
			
			
			/* 2022-06-30 , cancel this space 
			ccell = new Cell(new Phrase("\n\n\n\n\n\n", microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(100);
			ccell.setBorder(12);
			ctable.addCell(ccell);		
			*/
	
			ccell = new Cell(new Phrase("\nลงชื่อ................................................................................. ผู้รับใบนำฝาก", microssfont_MINI));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(50);
			ccell.setBorder(4);
			ctable.addCell(ccell);		
			ccell = new Cell(new Phrase("\nลงชื่อ................................................................................. ผู้วางเงินค้ำประกันฯ/ผู้รับป้าย", microssfont_MINI));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(50);
			ccell.setBorder(8);
			ctable.addCell(ccell);	
			ccell = new Cell(new Phrase("                                        ( "+doString.MS874ToUnicode(empName)+" )\n\n", microssfont_MINI));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(50);
			ccell.setBorder(4);
			ctable.addCell(ccell);		
			ccell = new Cell(new Phrase("                                   ( "+doString.MS874ToUnicode(retenName)+" )\n\n", microssfont_MINI));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(50);
			ccell.setBorder(8);		
			ctable.addCell(ccell);								
			ccell = new Cell(new Phrase(" " , microssfont_MED));
			ccell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
			ccell.setVerticalAlignment(Rectangle.ALIGN_MIDDLE);
			ccell.setColspan(100);			
			ccell.setBorder(14);
			ctable.addCell(ccell);			
			document.add(ctable);	
			if (p ==1)
				document.newPage();						
		}			
		//Set Header      
/*		
		Table dtable = new Table(100);
        dtable.setCellsFitPage(true); 
        dtable.setAutoFillEmptyCells(true); 		
		dtable.setPadding(4);
        dtable.setSpacing(0);
        dtable.setWidth(100);
		dtable.setDefaultHorizontalAlignment(Element.ALIGN_CENTER);
		for (int c=1; c<=100; c++)
			dtable.addCell(new Phrase(" ",microssfont));
			
		document.add(dtable);			
*/		
		
        // we close the document (the outputstream is also closed internally)
        document.close();
        lckstmt.close();        		
        stmt.close();
        conn.close();
        stmt = null;
        lckstmt = null;        
        conn = null;
        
        // write ByteArrayOutputStream to the ServletOutputStream
        res.setContentType("application/pdf");
        res.setContentLength(baos.size());
        ServletOutputStream out = res.getOutputStream();
        baos.writeTo(out);
        out.flush();		
    } catch (Exception e) {
        System.out.println("ERROR /LHServ/PrintRetRetenServlet : " + e.getMessage());
    } finally {
        if (lckstmt != null) {
            try {
                lckstmt.close();
            } catch (SQLException ignore) {
            }
        }    	
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException ignore) {
            }
        }
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException ignore) {
            }
        }
    }
    System.out.println(mName + "end.");
}
}