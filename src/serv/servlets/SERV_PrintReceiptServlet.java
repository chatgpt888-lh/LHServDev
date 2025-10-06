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

import com.lowagie.text.pdf.ColumnText;
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
import com.lowagie.text.DocumentException;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.PageSize;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;

import serv.common.User;
import serv.common.Constants;
import serv.common.SERV_CommonData;

/**
 * @version 	1.0
 * @author
 */
public class SERV_PrintReceiptServlet extends DBServlet  {
	
	private static String cName = "SERV_PrintReceiptServlet";
	private static String month[] = {"เดือน","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
	
	public String encodeVerified(String raw) throws Exception {
		Calendar curr = Calendar.getInstance(TimeZone.getTimeZone("Asia/Bangkok"));
		raw += "#"+curr.get(Calendar.YEAR)+"-"+(curr.get(Calendar.MONTH)+1)+"-"+curr.get(Calendar.DATE);
		raw += ","+curr.get(Calendar.HOUR_OF_DAY)+":"+curr.get(Calendar.MINUTE)+"."+curr.get(Calendar.SECOND);
		String enc = doString.encode(raw);
		enc = enc.replaceAll("%3D","=");
		enc = enc.replaceAll("\n","[N]");
		enc = enc.replaceAll("\r","[R]");

		if (enc.length()>10) {
			enc = enc.substring(0,10)+"L"+enc.substring(10); // insert character for protect standard decrypt
			enc = enc.substring(0,enc.length()-10)+"H"+enc.substring(enc.length()-10); // insert character for protect standard decrypt
		}
		
		return enc;
	}
	
	public String decodeVerified(String enc) throws Exception {
		//--- validate protect character & remove it ---//
		if (enc.length()>10) {
			if (enc.substring(enc.length()-11,enc.length()-10).equals("H")) {
				enc = enc.substring(0,enc.length()-11)+enc.substring(enc.length()-10);
			} else {
				throw new Exception("Invalid Encoded Data(2) : "+enc);
			}
			
			if (enc.substring(10,11).equals("L")) {
				enc = enc.substring(0,10)+enc.substring(11);
			} else {
				throw new Exception("Invalid Encoded Data(1) : "+enc);
			}	
		} else {
			throw new Exception("Invalid Encoded Data(0) : "+enc);
		}
		while (enc.indexOf("[N]")>=0) {
			enc = enc.substring(0,enc.indexOf("[N]"))+"\n"+enc.substring(enc.indexOf("[N]")+3);
		}
		while (enc.indexOf("[R]")>=0) {
			enc = enc.substring(0,enc.indexOf("[R]"))+"\r"+enc.substring(enc.indexOf("[R]")+3);
		}		
		
		return doString.decode(enc);		
	}	
	
	
	public String getR2ShortCode(Statement stmt,String iCompany,String iProject,String iLor,String iReceipt) throws Exception {
		String result = "";
		StringBuffer sql = new StringBuffer();
		iReceipt = doString.checkString(iReceipt,"").trim();
		boolean isR2 = false;

		sql.delete(0,sql.length());
	    sql.append(" select * from lan:acrdtrec a, lan:acrrecpt c, lan:acrrecev r ")
	       .append(" where a.i_company='"+iCompany+"' and a.i_project='"+iProject+"' ")
	       .append(" and a.i_lor='"+iLor+"' and a.i_receipt='"+iReceipt+"' ")
	       .append(" and a.i_com_recv=c.i_company and a.i_receipt=c.i_receipt and a.d_adjust is null ")
	       .append(" and c.i_cancel is null and (a.f_cancel is null or a.f_cancel='C') ")
	       .append(" and a.s_item=r.s_item and r.i_due='R2' ");
		ResultSet rs = stmt.executeQuery(sql.toString());		
		if (rs.next()) {
			isR2 = true;
		}
		rs.close();	
		
		if (isR2) {
		    sql.delete(0,sql.length());
		    sql.append(" select year(h.d_start) as start_year from lan:serv_payin p ")
		       .append(" left join lan:serv_infhd h on h.i_docno=p.i_docno and h.i_company=p.i_company and h.i_project=p.i_project and h.i_lor=p.i_lor ")
		       .append(" where p.i_company='"+iCompany+"' and p.i_project='"+iProject+"' ") 
		       .append(" and p.i_lor='"+iLor+"' and p.i_receipt='"+iReceipt+"' ");
		    rs = stmt.executeQuery(sql.toString());
		    if (rs.next()) {
		    	int y = rs.getInt("start_year");
		    	if (y<2400) y += 543;
		    	if (y>=1000) {
		    		result = "R"+Integer.toString(y).substring(2,4)+" ";
		    	} else {
		    		result = "R"+Integer.toString(y)+" ";
		    	}
		    } else {
		    	result = "";
		    }
		    rs.close();				
		} else {
			result = "";
		}
		
		return result;
	}	
	
	
	public String setLabelThai(String realPath,String label) throws Exception {
		if (realPath.indexOf("LHWeb")>0) {
			//--- crontab class , using DisplayThai ----//
			return doString.DisplayThai(label);
		} 
		
		//---- servlet class , using old encoding ----//
		return label;
	}	

	
	//***********************************************//
	public String[] getReprintReceiptData(Statement stmt,String iComRecv,String iReceipt) throws Exception {
		String data[] = null;
		ResultSet rs = null;
		StringBuffer sql = new StringBuffer();
				
		sql.delete(0,sql.length());
		sql.append(" select * from lan:log_recpt ")
		   .append(" where i_com_recv='"+iComRecv+"' and i_receipt='"+iReceipt+"' ");
		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
			data = new String[]{"","","","","","","","","","","","","","",""};
			data[0] = doString.checkString(rs.getString("i_com_recv"),"");
			data[1] = doString.checkString(rs.getString("i_company"),"");
			data[2] = doString.checkString(rs.getString("i_project"),"");
			data[3] = doString.checkString(rs.getString("i_lor"),"");
			data[4] = doString.checkString(rs.getString("i_sort"),"");
			data[5] = doString.checkString(rs.getString("i_receipt"),"");
			data[6] = doString.checkString(rs.getString("d_receipt"),"");
			data[7] = doString.checkString(rs.getString("s_receive"),"");
			data[8] = doString.checkString(rs.getString("i_cust1"),"");
			data[9] = doString.checkString(rs.getString("n_cust1"),"");
			data[10] = doString.checkString(rs.getString("i_cust2"),"");
			data[11] = doString.checkString(rs.getString("n_cust2"),"");
			data[12] = doString.checkString(rs.getString("n_addr1"),"");
			data[13] = doString.checkString(rs.getString("n_addr2"),"");
			data[14] = doString.checkString(rs.getString("n_addr3"),"");
		} // end while
		rs.close();					
		
		return data;
	}	
	
	public void insertLogReceipt(Connection conn,Statement stmt,String[] data,String postCode,String fCorp,String empId,boolean sendEmail) throws Exception {
		StringBuffer sql = new StringBuffer();
		boolean ok = false;
		String err = "";
		
		//--- 2023-09-15 , add new variable for insert ---//
		postCode = doString.checkString(postCode,"").trim();
		fCorp = doString.checkString(fCorp,"").trim().toUpperCase();
		
		// 1. first 8 array must have value
		for (int c=0;c<8;c++) {					
			if (data[c].trim().length()>0) {
				ok = true;
			} else {
				err = " data["+c+"] is blank. ";
				ok = false;
				break;
			}
		} // end for
		
		if (data[8].length()<=0 || data[9].length()<=0) {
			//--- found i_customer1 but no n_customer1 ---//
			err = " first customer name blank. ";
			ok = false;
		}				
		
		//--- insert new log ---//
		if (ok) {
			if (empId.indexOf("lh")==0 && empId.length()>=7) {
				empId = empId.substring(2,6)+"-"+empId.substring(6,7);
			}
					
			sql.delete(0,sql.length());
			sql.append(" insert into lan:log_recpt ( ")
			   .append(" i_com_recv, 	i_company, 	i_project, 	i_lor, 		i_sort, ")
			   .append(" i_receipt, 	d_receipt, 	s_receive, 	i_cust1, 	n_cust1, ")
			   .append(" i_cust2, 		n_cust2, 	n_addr1, 	n_addr2, 	n_addr3, ")
			   .append(" f_mail, 		i_print, 	d_print, ")
			   .append(" n_postcode, 	f_corp ") // 2023-09-15 , new field
			   .append(" ) values ( ")
			/*  2019-06-04 , change insert method
			   .append(" '"+data[0]+"','"+data[1]+"','"+data[2]+"','"+data[3]+"','"+data[4]+"', ")
			   .append(" '"+data[5]+"','"+data[6]+"','"+data[7]+"','"+data[8]+"','"+data[9]+"', ")
			   .append(" '"+data[10]+"','"+data[11]+"','"+data[12]+"','"+data[13]+"','"+data[14]+"', ")
			   .append(" "+(sendEmail ? "'Y'" : "null")+",'"+empId+"',current) ");		
			stmt.executeUpdate(doString.UnicodeToMS874(sql.toString()));	
			*/
			   .append("?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,current,?,?) "); // 2023-09-15 , new last 2 field after d_print
			
			//---- clear null and space before insert data ----//
			for (int i=0;i<=14;i++) {
				data[i] = doString.checkString(data[i],"").trim();
			}
			
			PreparedStatement pstmt = conn.prepareStatement(sql.toString());
			pstmt.setString(1,doString.UnicodeToMS874(data[0]));
			pstmt.setString(2,doString.UnicodeToMS874(data[1]));
			pstmt.setString(3,doString.UnicodeToMS874(data[2]));
			if (data[3].length()>0) {
				pstmt.setInt(4,Integer.parseInt(data[3]));
			} else {
				pstmt.setNull(4,java.sql.Types.INTEGER);
			}			
			pstmt.setString(5,doString.UnicodeToMS874(data[4]));
			if (data[5].length()>0) {
				pstmt.setInt(6,Integer.parseInt(data[5]));
			} else {
				pstmt.setNull(6,java.sql.Types.INTEGER);
			}			
			pstmt.setString(7,doString.UnicodeToMS874(data[6]));
			if (data[7].length()>0) {
				pstmt.setInt(8,Integer.parseInt(data[7]));
			} else {
				pstmt.setNull(8,java.sql.Types.INTEGER);
			}
			if (data[8].length()>0) {
				pstmt.setInt(9,Integer.parseInt(data[8]));
			} else {
				pstmt.setNull(9,java.sql.Types.INTEGER);
			}
			pstmt.setString(10,doString.UnicodeToMS874(data[9]));
			if (data[10].length()>0) {
				pstmt.setInt(11,Integer.parseInt(data[10]));
			} else {
				pstmt.setNull(11,java.sql.Types.INTEGER);
			}
			pstmt.setString(12,doString.UnicodeToMS874(data[11]));
			pstmt.setString(13,doString.UnicodeToMS874(data[12]));
			pstmt.setString(14,doString.UnicodeToMS874(data[13]));
			pstmt.setString(15,doString.UnicodeToMS874(data[14]));
			if (sendEmail) {
				pstmt.setString(16,"Y");
			} else {
				pstmt.setNull(16,java.sql.Types.CHAR);
			}			
			pstmt.setString(17,empId);	
			//--- 2023-09-15 , add new field ---//
			pstmt.setString(18,postCode);	
			if (fCorp.equalsIgnoreCase("Y")) {
				pstmt.setString(19,"Y");
			} else {
				pstmt.setNull(19,java.sql.Types.CHAR);
			}	
			//---------------------------------//			
			pstmt.executeUpdate();
		} else {
			System.out.println("Receipt Log Error (i_receipt = "+data[5]+") : "+err);
		}
	}	
	
	public void updateLogReceipt(Statement stmt,String iComRecv,String iReceipt,String empId) throws Exception {
		StringBuffer sql = new StringBuffer();
		
		if (empId.indexOf("lh")==0 && empId.length()>=7) {
			empId = empId.substring(2,6)+"-"+empId.substring(6,7);
		}		

		//--- update reprint date ---//
		sql.delete(0,sql.length());
		sql.append(" update lan:log_recpt set ")
		   .append(" i_reprint='"+empId+"' , d_reprint=current ")
		   .append(" where i_com_recv='"+iComRecv+"' and i_receipt='"+iReceipt+"' ");			
		stmt.executeUpdate(sql.toString());
	}	

	
	//***********************************************//
	public Document genReceipt(Connection Conn,Document document,PdfContentByte cb,String realPath,String recvCom,String iReceipt,String empId) throws Exception {
		StringBuffer sql = new StringBuffer("");
		Statement stmt = null;
		Statement stmt1 = null;
		Statement ustmt = null;
		ResultSet rs = null;
		ResultSet rs1 = null;
		ResultSet urs = null;
				
		String Thai_TTF = realPath+File.separator+"Fonts"+File.separator+"ANGSAU.TTF";
		String Thai_TTFB = realPath+File.separator+"Fonts"+File.separator+"ANGSAUB.TTF";
		String rawForEncode = "";
		
		try {			
			stmt = Conn.createStatement();
			stmt1 = Conn.createStatement();
			ustmt = Conn.createStatement();

			BaseFont bf = BaseFont.createFont(Thai_TTF, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
			BaseFont bfb = BaseFont.createFont(Thai_TTFB, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);			
			Font microssfont = new Font(bf, 16, Font.NORMAL);
			Font fontWhite = new Font(bf, 8, Font.NORMAL,new Color(255,255,255));
						
			String flagRePrint = "F"; // force generate pdf 
										
			//*********************************************************************************************************************************//
			//**************************************** copy code from RecptPrint4LaserServlet *************************************************//
			cb.setFontAndSize(bfb, 20);
			cb.beginText();
			
			String oldrcpt = "", currcpt = "", shw_rcpt = "", adrtyp = "", srt = "";
			String shw_iRecpt = "เลขที่ใบเสร็จ ";
			String shw_from = "ได้รับเงินจาก ", cusname = "", cusname2 = "";
			String shw_date = "วันที่ ", tmpdate = "";
			String shw_addr1 = "ที่อยู่1 ", shw_addr2 = "ที่อยู่2 ", shw_addr3 = "ที่อยู่3 ", cusadr = "", tmpadr = "";
			String shw_project = "โครงการ ";
			String shw_sort = "แปลง ";
			String shw_detail = "รายการ ";
			double shw_price = 0;
			double shw_vat = 0;
			double shw_tax = 0;
			double shw_net = 0;
			double shw_sumprice = 0;
			double shw_sumvat = 0;
			double shw_sumtax = 0;
			double shw_sumnet = 0;
			String shw_thaisumnet = "รวมจำนวนเงินรับสุทธิเป็นภาษาไทย ";
			String payby = "ชำระโดย ";
			String receiver = "ผู้รับเงิน", tmprcv = "";
			String taxINV = "", cardNo = "", ps = "", oldcomp = "", oldIRecpt = "", sItem = "";
			String dtCHQ1 = "", dtCHQ2 = "", dtCHQ3 = "", dtCHQ4 = "";
			String chgArr = "", oldArr0 = "", oldArr1 = "", oldArr2 = "", oldArr3 = "", oldArr4 = "";
			String oldArr5 = "", oldArr6 = "", oldArr7 = "", oldArr9 = "", oldArr10 = "";	
			String acm1 = "", acm2 = "", iden = "", s_name = "", n_name = "", off_branch = "";

			int i = 0, j = 0, line = 0, payCnt = 0, payRun = 0;
			double chkvat = 0, oldArr8 = 0;
			
			
			CurrencyToThai CTT = null;
			String[][] payArr = null;
			ColumnText ct = new ColumnText(cb);
			boolean wrtHD = false;		
			
			//************** 2016-07-08 , Roj ***************//	
			String reprintData[] = null; 
			String insertData[] = new String[]{"","","","","","","","","","","","","","",""}; 		
			boolean sendEmail = false;
			boolean oldSendEmail = false; 
			int idxFirstPrintReceipt = -1;
			int idxLastPrintReceipt = -1;
			Hashtable sendEmailList = new Hashtable();
			
			//--- 2023-09-15 , new field ---//
			String postCode = "";
			String fCorp = "";			
			//***********************************************//					
			
			String Tname = "", Tadr = "", vatId = "", taxId = "";
			sql.delete(0, sql.length());
			sql.append("select n_company, a_company, addr2, addr3, vat_id, tax_id")
				.append(" from lan:acxcompa")
				.append(" where i_company = '")
				.append(recvCom)
				.append("'");
			//System.out.println("sql = "+sql.toString());
			rs = stmt.executeQuery(sql.toString());
			
			if (rs.next()) {
				Tname = doString.DisplayThai(doString.checkString(rs.getString("n_company")));
				Tadr = doString.DisplayThai(doString.checkString(rs.getString("a_company"))) + " " + doString.DisplayThai(doString.checkString(rs.getString("addr2"))) + " " + doString.DisplayThai(doString.checkString(rs.getString("addr3")));
				vatId = doString.DisplayThai(doString.checkString(rs.getString("vat_id")));
				taxId = doString.DisplayThai(doString.checkString(rs.getString("tax_id")));
			}
			rs.close();
			
			String Ename = "", Eadr = "";
			sql.delete(0, sql.length());
			sql.append("select n_company, a_addr1, a_addr2")
				.append(" from lan:acxecompa")
				.append(" where i_company = '")
				.append(recvCom)
				.append("'");
			//System.out.println("sql = "+sql.toString());
			rs = stmt.executeQuery(sql.toString());
			
			if (rs.next()) {
				Ename = doString.DisplayThai(doString.checkString(rs.getString("n_company")));
				Eadr = doString.DisplayThai(doString.checkString(rs.getString("a_addr1"))) + " " + doString.DisplayThai(doString.checkString(rs.getString("a_addr2")));
			}
			rs.close();
			
						
			sql.delete(0, sql.length());
			sql.append("select a.i_company, a.i_project, a.i_lor, a.s_receive, a.i_mtype, a.i_fbank,")
				.append(" a.i_fbranch, a.i_cheque, a.d_receive, a.z_amount, a.i_com_recv, a.i_receipt,")
				.append(" a.s_item, a.f_status,")// b.z_price, b.z_vat, b.z_tax, b.i_due, b.c_receive,
				.append(" c.d_receipt, c.i_user, c.f_receipt, a.d_payin, c.i_type");
			if (flagRePrint.equals("T")) {
				sql.append(", t.i_tax_inv");
			}
			sql.append(" from lan:acrdtrec a, lan:acrrecpt c"); //lan:acrrecv b,
			if (flagRePrint.equals("T")) {
				sql.append(", lan:acrtaxinv t");
			}
			sql.append(" where a.i_com_recv = '")
				.append(recvCom)
				.append("'");
			
			if (!flagRePrint.equals("T")) {
				//************** 2016-07-08 , Roj ***************//
				/*if (!flagRePrint.equals("F")) { // new flag not check user  
					sql.append(" and c.i_user = '")
						.append(empId)
						.append("'");
				}*/
				// not used in generate pdf method
				//***********************************************//
			} else {
				sql.append(" and t.i_com_recv = c.i_company")
					.append(" and t.i_receipt = c.i_receipt");
			}
			sql//.append(" and a.s_item = b.s_item")
				.append(" and a.i_com_recv =  c.i_company")
				.append(" and a.i_receipt = c.i_receipt")
				.append(" and a.d_adjust is null")
				.append(" and a.f_cancel is null")
				.append(" and c.i_cancel is null");
			//************** 2016-07-08 , Roj ***************//
			if (flagRePrint.equals("F")) { // query set of i_receipt and not use d_receipt				
				String printReceipt[] = null;
				/*
				if (doString.checkString(req.getParameter("i_receipt"),"").length()>0) {
					//-- create array[1] for one receipt --//
					printReceipt = new String[]{doString.checkString(req.getParameter("i_receipt"),"")};
				} else {
					//-- create array[n] for multiple receipt --//
					printReceipt = req.getParameterValues("print_receipt");
				}
				*/
				//fixed i_receipt for generate pdf method
				printReceipt = new String[]{doString.checkString(iReceipt,"")};
				
				if (printReceipt!=null) {
					String receiptList = "";
					boolean send = false;
					
					for (int r=0;r<printReceipt.length;r++) {
						if (receiptList.trim().length()>0) receiptList += " , ";
						receiptList += "'"+doString.checkString(printReceipt[r],"").trim()+"'";
					} // end for

					if (receiptList.length()>0) {
						sql.append(" and a.i_receipt in ("+receiptList+") ");
					} else {
						sql.append(" and a.i_receipt='999999' "); // filter for no data print					
					}
				} else {
					sql.append(" and a.i_receipt='999999' "); // filter for no data print
				}
			} else { 
			//***********************************************//
				// not used in generate pdf method
				/* 
				if (!begRecpt.equals("") && !endRecpt.equals("")) {
					sql.append(" and a.i_receipt between '")
						.append(begRecpt)
						.append("' and '")
						.append(endRecpt)
						.append("'");
				}
				
				if (!begRecptDate.equals("") && !endRecptDate.equals("")) {
					sql.append(" and c.d_receipt between '")
						.append(begRecptDate)
						.append("' and '")
						.append(endRecptDate)
						.append("'");
				}
				*/
				// not used in generate pdf method
			} //** 2016-07-08 **//
			if (flagRePrint.equals("T")) {
				sql.append(" order by t.i_tax_inv");
			} else {				
				if (flagRePrint.equals("Y")) {
					sql.append(" and c.f_receipt = 'Y'");
				} else if (flagRePrint.equals("N")) {
					sql.append(" and (c.f_receipt is null or trim(c.f_receipt) = '')");
				}
				sql.append(" order by c.d_receipt, a.i_receipt ");
			}
			sql.append(", a.i_mtype, a.s_item, c.i_type, a.d_receive, a.i_fbank, a.i_fbranch, a.i_cheque");			
			//System.out.println("sql = "+sql.toString());
			
			
			//***************************** 2016-07-26 , check send email **************************//
			boolean send = false;
			int r = 0;
			/*--- 2017-09-26 , fix not send email for this class ---*/					
			rs = stmt.executeQuery(sql.toString());
			while (rs.next()) {	
				send = false; // fixed always not send 
				/*
				if (flagRePrint.equalsIgnoreCase("N")) {
					//--- check customer is receive by email ---//
					send = rcpt.isReceiptSendEmail(stmt1, recvCom, doString.checkString(rs.getString("i_receipt"),""));
				} else {  
					//--- force print for other flag ---//
					send = false;
				}
				*/					
				if (!send) {
					if (idxFirstPrintReceipt<0) {
						idxFirstPrintReceipt = (r+1); // start idx with 1
					}
					
					idxLastPrintReceipt = (r+1); // start idx with 1
				}
				//sendEmailList.addElement(send);
				sendEmailList.put(doString.checkString(rs.getString("i_receipt"),""),new Boolean(send));
				r++;
			}
			//**************************************************************************************//
						
			rs = stmt.executeQuery(sql.toString());						
			while (rs.next()) {		
				currcpt = "";
				postCode = ""; // 2023-09-15
				fCorp = ""; // 2023-09-15				
				
				if (flagRePrint.equals("T")) {
					currcpt = doString.checkString(rs.getString("i_tax_inv"));
				} else {
					currcpt = doString.checkString(rs.getString("i_receipt"));
					
					//************** 2016-07-08 , Roj ***************//
					reprintData = getReprintReceiptData(stmt1,recvCom,currcpt);
					// reprintData[]
					// 0 = i_com_recv , 1 = i_company , 2 = i_project , 3 = i_lor , 4 = i_sort , 5 = i_receipt
					// 6 = d_receipt , 7 = s_receive , 8 = i_cust1 , 9 = n_cust1 , 10 = i_cust2 , 11 = n_cust2
					// 12 = n_addr1 , 13 = n_addr2 , 14 = n_addr3
					//***********************************************//		
				}

				
				//************** 2016-07-08 , Roj ***************//	 
				if (flagRePrint.equalsIgnoreCase("N")) {
					//--- check customer is receive by email ---//
					sendEmail = ((Boolean) sendEmailList.get(currcpt)).booleanValue();
					if (oldrcpt.length()>0) {
						oldSendEmail = ((Boolean) sendEmailList.get(oldrcpt)).booleanValue();
					} else {
						oldSendEmail = false;
					}
				} else {
					//--- force print for other flag ---//
					sendEmail = false;
					oldSendEmail = false;
				}

				if (reprintData==null) {
					insertData[0] = doString.checkString(rs.getString("i_company"));
					insertData[1] = doString.checkString(rs.getString("i_company"));
					insertData[2] = doString.checkString(rs.getString("i_project"));
					insertData[3] = doString.checkString(rs.getString("i_lor"));
				}
				//***********************************************//								

				if (i == 0) {					
					payCnt = 0;
					payRun = 0;
					sql.delete(0, sql.length());
					sql.append("select count(a.i_mtype) as cnt")
						.append(" from lan:acrdtrec a, lan:acrrecpt c")
						.append(" where a.i_receipt = '")
						.append(doString.checkString(rs.getString("i_receipt")))
						.append("' and a.i_com_recv = '")
						.append(recvCom)	
						.append("' and a.i_com_recv =  c.i_company")
						.append(" and a.i_receipt = c.i_receipt")
						.append(" and a.d_adjust is null")
						.append(" and a.f_cancel is null")
						.append(" and c.i_cancel is null");
					//System.out.println("sql = "+sql.toString());
					rs1 = stmt1.executeQuery(sql.toString());
					
					if (rs1.next()) {
						payCnt = rs1.getInt("cnt");
					}						
					rs1.close();
					payArr = new String[payCnt][12];			
				} // end if i == 0
				i++;
				
				if (!oldrcpt.equals(currcpt)) {						
					if (i > 1) {	
						line = 575;		
						shw_sumprice = 0; shw_sumvat = 0; shw_sumtax = 0; shw_sumnet = 0;
						sql.delete(0, sql.length());
						sql.append("select sum(b.z_price) as z_price, sum(b.z_vat) as z_vat, sum(b.z_tax) as z_tax, b.i_due, b.c_receive")
							.append(" from lan:acrrecev b")
							.append(" where b.s_item in (")
							.append(sItem.substring(0, sItem.length() -2))
							.append(") group by b.i_due, b.c_receive order by b.i_due");					
						//System.out.println("1 sql = "+sql.toString());
						rs1 = stmt1.executeQuery(sql.toString());
						
						while (rs1.next()) {
							sql.delete(0, sql.length());
							sql.append("select c_prn1_msg, c_prn2_msg")
								.append(" from lan:acmsgrcp")
								.append(" where i_company = '")
								.append(payArr[payRun-1][5])	
								.append("' and i_project = '")
								.append(payArr[payRun-1][6])	
								.append("' and d_beg_effect <= '")
								.append(payArr[payRun-1][11])	
								.append("' and d_end_effect >= '")
								.append(payArr[payRun-1][11])	
								.append("' and i_beg_due <= '")
								.append(doString.checkString(rs1.getString("i_due")))
								.append("' and i_end_due >= '")
								.append(doString.checkString(rs1.getString("i_due")))
								.append("'");					
							//System.out.println("1 sql = "+sql.toString());
							urs = ustmt.executeQuery(sql.toString());
							
							if (urs.next()) {
								acm1 = doString.DisplayThai(doString.checkString(urs.getString("c_prn1_msg")));
								acm2 = doString.DisplayThai(doString.checkString(urs.getString("c_prn2_msg")));
							}
							urs.close();

							shw_detail = doString.DisplayThai(doString.checkString(rs1.getString("c_receive")));
							shw_price = rs1.getDouble("z_price");
							shw_vat = rs1.getDouble("z_vat");
							shw_tax = rs1.getDouble("z_tax");
							shw_net = shw_price + shw_vat - shw_tax;
			
							shw_sumprice += shw_price;
							shw_sumvat += shw_vat;
							shw_sumtax += shw_tax; 
							shw_sumnet += shw_net;							
			
							// LowLeftx, LowLefty,UpRightx, UpRighty							
							//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//							
							if ((!sendEmail && i>idxFirstPrintReceipt && !oldSendEmail) || (sendEmail && !oldSendEmail)) {
							//****************************************************************************************//	
							ct.setSimpleColumn(new Phrase(shw_detail, microssfont),	32, line, 210, line+19, 10, Element.ALIGN_LEFT);
							ct.go();				
							cb.endText();
							
							cb.setFontAndSize(bf, 16);
							cb.beginText();					
							ct.setSimpleColumn(new Phrase(doString.displayNumber("###,##0.00", shw_price), microssfont), 210, line, 310, line+19, 10, Element.ALIGN_RIGHT);
							ct.go();				
							cb.endText();
							
							cb.setFontAndSize(bf, 16);
							cb.beginText();							
							if (shw_vat == 0) {
								ct.setSimpleColumn(new Phrase(" ", microssfont), 310, line, 395, line+19, 10, Element.ALIGN_RIGHT);
							} else {
								ct.setSimpleColumn(new Phrase(doString.displayNumber("###,##0.00", shw_vat), microssfont), 310, line, 395, line+19, 10, Element.ALIGN_RIGHT);
							}
							ct.go();				
							cb.endText();
							
							cb.setFontAndSize(bf, 16);
							cb.beginText();								
							if (shw_tax == 0) {
								ct.setSimpleColumn(new Phrase(" ", microssfont), 395, line, 480, line+19, 10, Element.ALIGN_RIGHT);
							} else {
								ct.setSimpleColumn(new Phrase(doString.displayNumber("###,##0.00", shw_tax), microssfont), 395, line, 480, line+19, 10, Element.ALIGN_RIGHT);
							}
							ct.go();				
							cb.endText();
							
							cb.setFontAndSize(bf, 16);
							cb.beginText();								
							ct.setSimpleColumn(new Phrase(doString.displayNumber("###,##0.00", shw_net), microssfont), 480, line, 565, line+19, 10, Element.ALIGN_RIGHT);
							ct.go();				
							cb.endText();
							
							cb.setFontAndSize(bf, 16);
							cb.beginText();					
							
							line -= 20;
							//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
							} // end if sendEmail	
							//****************************************************************************************//								
						} // End while rs1
						rs1.close();			
						
						line = 350;
						// LowLeftx, LowLefty,UpRightx, UpRighty
						//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
						if ((!sendEmail && i>idxFirstPrintReceipt && !oldSendEmail) || (sendEmail && !oldSendEmail)) {
						//****************************************************************************************//						
						ct.setSimpleColumn(new Phrase(doString.displayNumber("###,##0.00", shw_sumprice), microssfont), 210, line, 310, line+19, 10, Element.ALIGN_RIGHT);
						ct.go();				
						cb.endText();
						
						cb.setFontAndSize(bf, 16);
						cb.beginText();								
						if (shw_sumvat == 0) {		
							ct.setSimpleColumn(new Phrase(" ", microssfont), 310, line, 395, line+19, 10, Element.ALIGN_RIGHT);
						} else {		
							ct.setSimpleColumn(new Phrase(doString.displayNumber("###,##0.00", shw_sumvat), microssfont), 310, line, 395, line+19, 10, Element.ALIGN_RIGHT);
						}
						ct.go();				
						cb.endText();
						
						cb.setFontAndSize(bf, 16);
						cb.beginText();							
						if (shw_sumtax == 0) {		
							ct.setSimpleColumn(new Phrase(" ", microssfont), 395, line, 480, line+19, 10, Element.ALIGN_RIGHT);
						} else {				
							ct.setSimpleColumn(new Phrase(doString.displayNumber("###,##0.00", shw_sumtax), microssfont), 395, line, 480, line+19, 10, Element.ALIGN_RIGHT);
						}
						ct.go();				
						cb.endText();
						
						cb.setFontAndSize(bf, 16);
						cb.beginText();					
						ct.setSimpleColumn(new Phrase(doString.displayNumber("###,##0.00", shw_sumnet), microssfont), 480, line, 565, line+19, 10, Element.ALIGN_RIGHT);
						ct.go();				
						cb.endText();
						
						cb.setFontAndSize(bf, 16);
						cb.beginText();	
							
						CTT = new CurrencyToThai(shw_sumnet);
						shw_thaisumnet = doString.DisplayThai(CTT.getString());
						cb.setTextMatrix(105, 336);
						cb.showText("="+shw_thaisumnet+"=");				
						//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
						} // end if sendEmail	
						//****************************************************************************************//	

						line = 308;
						wrtHD = false;
						chgArr = "";
						oldArr0 = "";
						oldArr1 = "";
						oldArr2 = "";
						oldArr3 = "";
						oldArr4 = "";
						oldArr5 = "";
						oldArr6 = "";
						oldArr7 = "";
						oldArr8 = 0;
						oldArr9 = "";
						oldArr10 = "";
						j = 0;
						for (payRun = 0; payRun < payCnt ; payRun++) {
							j++;
							if (!chgArr.equals(payArr[payRun][0]+payArr[payRun][10]+payArr[payRun][1]+payArr[payRun][2]+payArr[payRun][9]) && j > 1) {
								payby = "";
								cardNo = "";
								if (oldArr0.equals("6")) {
									sql.delete(0, sql.length());
									sql.append("select i_cr_digit")
										.append(" from lan:acrcrdig")
										.append(" where i_bank = '")
										.append(oldArr1)
										.append("' and i_cr_code = '")
										.append(oldArr2)
										.append("'");					
									//System.out.println("sql = "+sql.toString());
									rs1 = stmt1.executeQuery(sql.toString());
									
									if (rs1.next()) {
										cardNo = doString.checkString(rs1.getString("i_cr_digit")) + oldArr9;
									}						
									rs1.close();
									
									sql.delete(0, sql.length());
									sql.append("select n_finance")
										.append(" from lan:acxfinan")
										.append(" where i_finance = '")
										.append(oldArr1)
										.append("' and i_branch is null");					
									//System.out.println("sql = "+sql.toString());
									rs1 = stmt1.executeQuery(sql.toString());
									
									if (rs1.next()) {
										payby = setLabelThai(realPath,"บัตรเครดิต ") + doString.DisplayThai(doString.checkString(rs1.getString("n_finance"))) + setLabelThai(realPath," เลขที่ ");
									}						
									rs1.close();
									
									if (!cardNo.equals("")) {
										payby += cardNo.substring(0, 4) + " " + cardNo.substring(4, 8) + " " + cardNo.substring(8, 12) + " " + cardNo.substring(12);
									}
									payby += setLabelThai(realPath," จำนวนเงิน ") + doString.displayNumber("###,##0.00", oldArr8) + setLabelThai(realPath," บาท");
									
									//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
									if ((!sendEmail && i>idxFirstPrintReceipt && !oldSendEmail) || (sendEmail && !oldSendEmail)) {
									//****************************************************************************************//										
									cb.setTextMatrix(75, line);
									cb.showText(payby);
									//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
									} // end if sendEmail	
									//****************************************************************************************//										
								} else if (oldArr0.equals("4")) {
									payby = setLabelThai(realPath,"รับนอกสถานที่ ");
									
									//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
									if ((!sendEmail && i>idxFirstPrintReceipt && !oldSendEmail) || (sendEmail && !oldSendEmail)) {
									//****************************************************************************************//											
									cb.setTextMatrix(75, line);
									cb.showText(payby);
									//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
									} // end if sendEmail	
									//****************************************************************************************//										
								} else if (oldArr0.equals("1")) {
									if (oldArr3.equals("T")) {						
										sql.delete(0, sql.length());
										sql.append("select i_sort")
											.append(" from lan:acrmisdt")
											.append(" where post_date = '")
											.append(oldArr4)
											.append("' and f_confirm = 'Y' and i_company = '")
											.append(oldArr5)
											.append("' and i_project = '")
											.append(oldArr6)
											.append("' and i_sort = '")
											.append(srt)
											.append("'");					
										//System.out.println("sql 1 = "+sql.toString());
										rs1 = stmt1.executeQuery(sql.toString());
										
										if (rs1.next()) {
											tmpdate = oldArr4;
											//if (!tmpdate.equals("")) {
											//	tmpdate = tmpdate.substring(8) + "/" + tmpdate.substring(5, 7) + "/" + Integer.toString(Integer.parseInt(tmpdate.substring(0, 4))+543);  
											//} // End if !tmpdate
											
											//payby = "โอนเงินผ่านธนาคาร วันที่ "+ tmpdate + "  " + doString.displayNumber("###,##0.00", oldArr8) + " บาท";
										} else {
											tmpdate = oldArr10;
											//payby = "เงินสด     " + doString.displayNumber("###,##0.00", oldArr8) + " บาท";
										}						
										rs1.close();

										if (!tmpdate.equals("")) {
											tmpdate = tmpdate.substring(8) + "/" + tmpdate.substring(5, 7) + "/" + Integer.toString(Integer.parseInt(tmpdate.substring(0, 4))+543);  
										} // End if !tmpdate
										
										payby = setLabelThai(realPath,"โอนเงินผ่านธนาคารเป็นเงินสด จำนวนเงิน  ") + doString.displayNumber("###,##0.00", oldArr8) + setLabelThai(realPath," บาท วันที่ ")+ tmpdate;										
									} else {
										payby = setLabelThai(realPath,"เงินสด     ") + doString.displayNumber("###,##0.00", oldArr8) + setLabelThai(realPath," บาท");
									} // End if i_typ	
									
									//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
									if ((!sendEmail && i>idxFirstPrintReceipt && !oldSendEmail) || (sendEmail && !oldSendEmail)) {
									//****************************************************************************************//										
									cb.setTextMatrix(75, line);
									cb.showText(payby);
									//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
									} // end if sendEmail	
									//****************************************************************************************//										
								} else if (oldArr0.equals("2")) {			
										if (!wrtHD){
											wrtHD = true;
											//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
											if ((!sendEmail && i>idxFirstPrintReceipt && !oldSendEmail) || (sendEmail && !oldSendEmail)) {
											//****************************************************************************************//												
											cb.moveTo(88, line-2);
										    cb.lineTo(163, line-2);
										    cb.setLineWidth(0.5f);
										    cb.stroke();
											cb.setTextMatrix(88, line);
											cb.showText(setLabelThai(realPath,"เช็คธนาคาร-สาขา"));
											cb.moveTo(318, line-2);
										    cb.lineTo(356, line-2);
										    cb.setLineWidth(0.5f);
										    cb.stroke();
											cb.setTextMatrix(318, line);
											cb.showText(setLabelThai(realPath,"เลขที่เช็ค"));
											cb.moveTo(418, line-2);
										    cb.lineTo(437, line-2);
										    cb.setLineWidth(0.5f);
										    cb.stroke();
											cb.setTextMatrix(417, line);
											cb.showText(setLabelThai(realPath,"วันที่"));
											cb.moveTo(519, line-2);
										    cb.lineTo(563, line-2);
										    cb.setLineWidth(0.5f);
										    cb.stroke();
											cb.setTextMatrix(518, line);
											cb.showText(setLabelThai(realPath,"จำนวนเงิน"));
											line -= 27;
											//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
											} // end if sendEmail	
											//****************************************************************************************//																					
										}
										
										dtCHQ1 = ""; dtCHQ2 = ""; dtCHQ3 = ""; dtCHQ4 = "";
										sql.delete(0, sql.length());
										sql.append("select n_finance")
											.append(" from lan:acxfinan")
											.append(" where i_finance = '")
											.append(oldArr1)
											.append("' and i_branch is null");					
										//System.out.println("sql = "+sql.toString());
										rs1 = stmt1.executeQuery(sql.toString());
										
										if (rs1.next()) {
											dtCHQ1 = doString.DisplayThai(doString.checkString(rs1.getString("n_finance")));
										}						
										rs1.close();
				
										sql.delete(0, sql.length());
										sql.append("select n_finance")
											.append(" from lan:acxfinan")
											.append(" where i_finance = '")
											.append(oldArr1)
											.append("' and i_branch = '")									
											.append(oldArr2)
											.append("'");					
										//System.out.println("sql = "+sql.toString());
										rs1 = stmt1.executeQuery(sql.toString());
										
										if (rs1.next()) {
											dtCHQ1 += "-" + doString.DisplayThai(doString.checkString(rs1.getString("n_finance")));
										}						
										rs1.close();
				
										dtCHQ2 = oldArr9;
										tmpdate = oldArr10;
										if (!tmpdate.equals("")) {
											tmpdate = tmpdate.substring(8) + "/" + tmpdate.substring(5, 7) + "/" + Integer.toString(Integer.parseInt(tmpdate.substring(0, 4))+543);  
										} // End if !tmpdate								
										dtCHQ3 = tmpdate;
										dtCHQ4 = doString.displayNumber("###,##0.00", oldArr8);

										// LowLeftx, LowLefty,UpRightx, UpRighty
										//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
										if ((!sendEmail && i>idxFirstPrintReceipt && !oldSendEmail) || (sendEmail && !oldSendEmail)) {
										//****************************************************************************************//											
										ct.setSimpleColumn(new Phrase(dtCHQ1, microssfont),	75, line, 289, line+19, 10, Element.ALIGN_LEFT);
										ct.go();				
										cb.endText();
										
										cb.setFontAndSize(bf, 16);
										cb.beginText();			
										ct.setSimpleColumn(new Phrase(dtCHQ2, microssfont),	290, line, 379, line+19, 10, Element.ALIGN_CENTER);
										ct.go();				
										cb.endText();
										
										cb.setFontAndSize(bf, 16);
										cb.beginText();			
										ct.setSimpleColumn(new Phrase(dtCHQ3, microssfont),	380, line, 469, line+19, 10, Element.ALIGN_CENTER);
										ct.go();				
										cb.endText();								

										cb.setFontAndSize(bf, 16);
										cb.beginText();			
										ct.setSimpleColumn(new Phrase(dtCHQ4, microssfont),	470, line, 570, line+19, 10, Element.ALIGN_RIGHT);
										ct.go();				
										cb.endText();
										
										cb.setFontAndSize(bf, 16);
										cb.beginText();	
										//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
										} // end if sendEmail	
										//****************************************************************************************//										
									//} // End if i_typ	(oldArr3)
								} // End if i_mtype
								line -= 19;

								oldArr8 = 0;
							} // End if chg
							chgArr = payArr[payRun][0]+payArr[payRun][10]+payArr[payRun][1]+payArr[payRun][2]+payArr[payRun][9];
							
							oldArr0 = payArr[payRun][0];
							oldArr1 = payArr[payRun][1];
							oldArr2 = payArr[payRun][2];
							oldArr3 = payArr[payRun][3];
							oldArr4 = payArr[payRun][4];
							oldArr5 = payArr[payRun][5];
							oldArr6 = payArr[payRun][6];
							oldArr7 = payArr[payRun][7];
							oldArr8 += Double.parseDouble(payArr[payRun][8]);
							oldArr9 = payArr[payRun][9];
							oldArr10 = payArr[payRun][10];							
						} // End for payRun
						
						if (j > 0) {
							payby = "";
							cardNo = "";
							if (oldArr0.equals("6")) {
								sql.delete(0, sql.length());
								sql.append("select i_cr_digit")
									.append(" from lan:acrcrdig")
									.append(" where i_bank = '")
									.append(oldArr1)
									.append("' and i_cr_code = '")
									.append(oldArr2)
									.append("'");					
								//System.out.println("sql = "+sql.toString());
								rs1 = stmt1.executeQuery(sql.toString());
								
								if (rs1.next()) {
									cardNo = doString.checkString(rs1.getString("i_cr_digit")) + oldArr9;
								}						
								rs1.close();
								
								sql.delete(0, sql.length());
								sql.append("select n_finance")
									.append(" from lan:acxfinan")
									.append(" where i_finance = '")
									.append(oldArr1)
									.append("' and i_branch is null");					
								//System.out.println("sql = "+sql.toString());
								rs1 = stmt1.executeQuery(sql.toString());
								
								if (rs1.next()) {
									payby = setLabelThai(realPath,"บัตรเครดิต ") + doString.DisplayThai(doString.checkString(rs1.getString("n_finance"))) + setLabelThai(realPath," เลขที่ ");
								}						
								rs1.close();
								
								if (!cardNo.equals("")) {
									payby += cardNo.substring(0, 4) + " " + cardNo.substring(4, 8) + " " + cardNo.substring(8, 12) + " " + cardNo.substring(12);
								}
								payby += setLabelThai(realPath," จำนวนเงิน ") + doString.displayNumber("###,##0.00", oldArr8) + setLabelThai(realPath," บาท");
								
								//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
								if ((!sendEmail && i>idxFirstPrintReceipt && !oldSendEmail) || (sendEmail && !oldSendEmail)) {
								//****************************************************************************************//								
								cb.setTextMatrix(75, line);
								cb.showText(payby);
								//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
								} // end if sendEmail	
								//****************************************************************************************//								
							} else if (oldArr0.equals("4")) {
								payby = setLabelThai(realPath,"รับนอกสถานที่ ");
								
								//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
								if ((!sendEmail && i>idxFirstPrintReceipt && !oldSendEmail) || (sendEmail && !oldSendEmail)) {
								//****************************************************************************************//								
								cb.setTextMatrix(75, line);
								cb.showText(payby);
								//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
								} // end if sendEmail	
								//****************************************************************************************//								
							} else if (oldArr0.equals("1")) {
								if (oldArr3.equals("T")) {						
									sql.delete(0, sql.length());
									sql.append("select i_sort")
										.append(" from lan:acrmisdt")
										.append(" where post_date = '")
										.append(oldArr4)
										.append("' and f_confirm = 'Y' and i_company = '")
										.append(oldArr5)
										.append("' and i_project = '")
										.append(oldArr6)
										.append("' and i_sort = '")
										.append(srt)
										.append("'");					
									//System.out.println("sql 3 = "+sql.toString());
									rs1 = stmt1.executeQuery(sql.toString());
									
									if (rs1.next()) {
										tmpdate = oldArr4;
										//if (!tmpdate.equals("")) {
										//	tmpdate = tmpdate.substring(8) + "/" + tmpdate.substring(5, 7) + "/" + Integer.toString(Integer.parseInt(tmpdate.substring(0, 4))+543);  
										//} // End if !tmpdate
										
										//payby = "โอนเงินผ่านธนาคาร วันที่ "+ tmpdate + "  " + doString.displayNumber("###,##0.00", oldArr8) + " บาท";
									} else {
										tmpdate = oldArr10;
										//payby = "เงินสด     " + doString.displayNumber("###,##0.00", oldArr8) + " บาท";
									}						
									rs1.close();

									if (!tmpdate.equals("")) {
										tmpdate = tmpdate.substring(8) + "/" + tmpdate.substring(5, 7) + "/" + Integer.toString(Integer.parseInt(tmpdate.substring(0, 4))+543);  
									} // End if !tmpdate
									
									payby = setLabelThai(realPath,"โอนเงินผ่านธนาคารเป็นเงินสด จำนวนเงิน  ") + doString.displayNumber("###,##0.00", oldArr8) + setLabelThai(realPath," บาท วันที่ ")+ tmpdate;		
								} else {
									payby = setLabelThai(realPath,"เงินสด     ") + doString.displayNumber("###,##0.00", oldArr8) + setLabelThai(realPath," บาท");
								} // End if i_typ	
								
								//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
								if ((!sendEmail && i>idxFirstPrintReceipt && !oldSendEmail) || (sendEmail && !oldSendEmail)) {
								//****************************************************************************************//								
								cb.setTextMatrix(75, line);
								cb.showText(payby);
								//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
								} // end if sendEmail	
								//****************************************************************************************//								
							} else if (oldArr0.equals("2")) {
									if (!wrtHD){
										wrtHD = true;
										//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
										if ((!sendEmail && i>idxFirstPrintReceipt && !oldSendEmail) || (sendEmail && !oldSendEmail)) {
										//****************************************************************************************//										
										cb.moveTo(88, line-2);
									    cb.lineTo(163, line-2);
									    cb.setLineWidth(0.5f);
									    cb.stroke();
										cb.setTextMatrix(88, line);
										cb.showText(setLabelThai(realPath,"เช็คธนาคาร-สาขา"));
										cb.moveTo(318, line-2);
									    cb.lineTo(356, line-2);
									    cb.setLineWidth(0.5f);
									    cb.stroke();
										cb.setTextMatrix(318, line);
										cb.showText(setLabelThai(realPath,"เลขที่เช็ค"));
										cb.moveTo(418, line-2);
									    cb.lineTo(437, line-2);
									    cb.setLineWidth(0.5f);
									    cb.stroke();
										cb.setTextMatrix(417, line);
										cb.showText(setLabelThai(realPath,"วันที่"));
										cb.moveTo(519, line-2);
									    cb.lineTo(563, line-2);
									    cb.setLineWidth(0.5f);
									    cb.stroke();
										cb.setTextMatrix(518, line);
										cb.showText(setLabelThai(realPath,"จำนวนเงิน"));
										line -= 27;									
										//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
										} // end if sendEmail	
										//****************************************************************************************//										
									}
									
									dtCHQ1 = ""; dtCHQ2 = ""; dtCHQ3 = ""; dtCHQ4 = "";
									sql.delete(0, sql.length());
									sql.append("select n_finance")
										.append(" from lan:acxfinan")
										.append(" where i_finance = '")
										.append(oldArr1)
										.append("' and i_branch is null");					
									//System.out.println("sql = "+sql.toString());
									rs1 = stmt1.executeQuery(sql.toString());
									
									if (rs1.next()) {
										dtCHQ1 = doString.DisplayThai(doString.checkString(rs1.getString("n_finance")));
									}						
									rs1.close();
			
									sql.delete(0, sql.length());
									sql.append("select n_finance")
										.append(" from lan:acxfinan")
										.append(" where i_finance = '")
										.append(oldArr1)
										.append("' and i_branch = '")									
										.append(oldArr2)
										.append("'");					
									//System.out.println("sql = "+sql.toString());
									rs1 = stmt1.executeQuery(sql.toString());
									
									if (rs1.next()) {
										dtCHQ1 += "-" + doString.DisplayThai(doString.checkString(rs1.getString("n_finance")));
									}						
									rs1.close();
			
									dtCHQ2 = oldArr9;
									tmpdate = oldArr10;
									if (!tmpdate.equals("")) {
										tmpdate = tmpdate.substring(8) + "/" + tmpdate.substring(5, 7) + "/" + Integer.toString(Integer.parseInt(tmpdate.substring(0, 4))+543);  
									} // End if !tmpdate								
									dtCHQ3 = tmpdate;
									dtCHQ4 = doString.displayNumber("###,##0.00", oldArr8);

									// LowLeftx, LowLefty,UpRightx, UpRighty
									//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
									if ((!sendEmail && i>idxFirstPrintReceipt && !oldSendEmail) || (sendEmail && !oldSendEmail)) {
									//****************************************************************************************//									
									ct.setSimpleColumn(new Phrase(dtCHQ1, microssfont),	75, line, 289, line+19, 10, Element.ALIGN_LEFT);
									ct.go();				
									cb.endText();
									
									cb.setFontAndSize(bf, 16);
									cb.beginText();			
									ct.setSimpleColumn(new Phrase(dtCHQ2, microssfont),	290, line, 379, line+19, 10, Element.ALIGN_CENTER);
									ct.go();				
									cb.endText();
									
									cb.setFontAndSize(bf, 16);
									cb.beginText();			
									ct.setSimpleColumn(new Phrase(dtCHQ3, microssfont),	380, line, 469, line+19, 10, Element.ALIGN_CENTER);
									ct.go();				
									cb.endText();								

									cb.setFontAndSize(bf, 16);
									cb.beginText();			
									ct.setSimpleColumn(new Phrase(dtCHQ4, microssfont),	470, line, 570, line+19, 10, Element.ALIGN_RIGHT);
									ct.go();				
									cb.endText();
									
									cb.setFontAndSize(bf, 16);
									cb.beginText();	
									//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
									} // end if sendEmail	
									//****************************************************************************************//									
								// } // End if i_typ (oldArr3)	
							} // End if i_mtype
							line -= 19;

							oldArr8 = 0;
						} // end if j > 0
						
						sItem = "";
						payCnt = 0;
						payRun = 0;
						sql.delete(0, sql.length());
						sql.append("select count(a.i_mtype) as cnt")
							.append(" from lan:acrdtrec a, lan:acrrecpt c")
							.append(" where a.i_receipt = '")
							.append(doString.checkString(rs.getString("i_receipt")))
							.append("' and a.i_com_recv = '")
							.append(recvCom)	
							.append("' and a.i_com_recv =  c.i_company")
							.append(" and a.i_receipt = c.i_receipt")
							.append(" and a.d_adjust is null")
							.append(" and a.f_cancel is null")
							.append(" and c.i_cancel is null");		
						//System.out.println("sql = "+sql.toString());
						rs1 = stmt1.executeQuery(sql.toString());
						
						if (rs1.next()) {
							payCnt = rs1.getInt("cnt");
						}						
						rs1.close();
						payArr = new String[payCnt][12];		

						receiver = "";
						sql.delete(0, sql.length());
						sql.append("select n_person")
							.append(" from lan:acxpersn")
							.append(" where i_position = '5' and i_person = '")
							.append(tmprcv)
							.append("'");					
						//System.out.println("sql = "+sql.toString());
						rs1 = stmt1.executeQuery(sql.toString());
						
						if (rs1.next()) {
							receiver = doString.DisplayThai(doString.checkString(rs1.getString("n_person")));
						}						
						rs1.close();
			
						//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
						if ((!sendEmail && i>idxFirstPrintReceipt && !oldSendEmail) || (sendEmail && !oldSendEmail)) {
						//****************************************************************************************//							
						cb.setTextMatrix(52, 75);//45 55
						cb.showText(receiver);
						
						//acm1 = "X5, 150" + acm1;
						//System.out.println(">> 1 acm1 = "+acm1+"; acm2 = "+acm2);
						if (!acm1.equals("")) {
							cb.setTextMatrix(5, 150);
							cb.showText(acm1);
						}
						//acm2 = "X5, 131" + acm2;
						if (!acm2.equals("")) {
							cb.setTextMatrix(5, 131);
							cb.showText(acm2);
						}
						//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
						} // end if sendEmail	
						//****************************************************************************************//

						ps = "";
						if (flagRePrint.equals("R")) {
							ps = setLabelThai(realPath,"(ใบเสร็จรับเงินฉบับนี้ใช้แทนต้นฉบับเดิม)");
						} else if (flagRePrint.equals("N")) {							
							sql.delete(0, sql.length());
							sql.append("update lan:acrrecpt set f_receipt = 'Y'")
								.append(" where i_company = '")
								.append(oldcomp)
								.append("' and i_receipt = '")
								.append(oldIRecpt)
								.append("'");					
							stmt1.executeUpdate(sql.toString());
							
							if (chkvat > 0 && !taxINV.equals("")) {
								//---- 2024-03-05 , get d_receipt for lan:acrtaxinv ----//
								String dReceipt = "";
								sql.delete(0, sql.length());
								sql.append(" select d_receipt from  lan:acrrecpt ")
								   .append(" where i_company='"+oldcomp+"' and i_receipt='"+oldIRecpt+"' ");					
								rs1 = stmt1.executeQuery(sql.toString());
								if (rs1.next()) {
									dReceipt = doString.checkString(rs1.getString("d_receipt"),"").trim();
								}						
								rs1.close();
								//-------------------------------------------------------//
								
								sql.delete(0, sql.length());
								sql.append("insert into lan:acrtaxinv (i_com_recv, i_receipt,")
									.append(" i_tax_inv, d_tax_inv, f_print, d_print) values ('")
									.append(oldcomp)
									.append("', '")
									.append(oldIRecpt)
									.append("', '")
									.append(taxINV)
									.append("', "+(dReceipt.length()>=10 ? "'"+dReceipt+"'" : "TODAY")+", ") // 2024-03-05 , change TODAY to d_receipt
									.append(" NULL, NULL)");
								stmt1.executeUpdate(sql.toString());
							}
						} else if (flagRePrint.equals("T")) {
							sql.delete(0, sql.length());
							sql.append("update lan:acrtaxinv set f_print = 'Y', d_print = TODAY")
								.append(" where i_com_recv = '")
								.append(oldcomp)
								.append("' and i_receipt = '")
								.append(oldIRecpt)
								.append("' and i_tax_inv = '")
								.append(taxINV)
								.append("'");
							stmt1.executeUpdate(sql.toString());						
						} // End flagRePrint = 'N'
						
						//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
						if ((!sendEmail && i>idxFirstPrintReceipt && !oldSendEmail) || (sendEmail && !oldSendEmail)) {
						//****************************************************************************************//
						if (!ps.equals("")) {
							cb.setTextMatrix(20, 28); //5, 13
							cb.showText(ps);
						}
						
						//---- add summary amount before print on receipt ----//
						rawForEncode += "#"+shw_sumnet;
						cb.endText();
						cb.setFontAndSize(bf, 16);
						cb.beginText();					
						ct.setSimpleColumn(new Phrase(encodeVerified(rawForEncode), fontWhite), 20, 6, 565, 25, 10, Element.ALIGN_CENTER);
						ct.go();							

						cb.endText();
						document.newPage();

						cb.setFontAndSize(bfb, 20);
						cb.beginText();
						//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
						} // end if sendEmail	
						//****************************************************************************************//
					} // End if i > 1	
					
					
					//---- set raw data for encoding -----//
					rawForEncode  = doString.checkString(rs.getString("i_receipt"),"");	
					rawForEncode += "#"+doString.checkString(rs.getString("d_receipt"),"");
					rawForEncode += "#"+doString.checkString(rs.getString("i_company"),"");
					rawForEncode += "#"+doString.checkString(rs.getString("i_project"),"");
					rawForEncode += "#"+doString.checkString(rs.getString("i_lor"),"");
					
					acm1 = ""; acm2 = "";	

					//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
					if (!sendEmail /* end of loop i */) {
					//****************************************************************************************//
					cb.setTextMatrix(220, 810);
					cb.showText(Tname);

					cb.setTextMatrix(220, 795);
					cb.showText(Ename);
					cb.endText();
					
					cb.setFontAndSize(bfb, 12);
					cb.beginText();
					
					cb.setTextMatrix(30, 780);//790
					cb.showText(setLabelThai(realPath,"ทะเบียนเลขที่ ")+vatId);
					cb.setTextMatrix(150, 780);//790
					cb.showText(Tadr);
					
					cb.setTextMatrix(30, 770);//782
					cb.showText(setLabelThai(realPath,"เลขประจำตัวผู้เสียภาษีอากร "));
					cb.setTextMatrix(150, 770);//780
					cb.showText(Eadr);
					cb.setTextMatrix(30, 760);//774
					//cb.showText(taxId); 5/10/2555 Request
					cb.showText(vatId);
					
					cb.endText();
					
					cb.setFontAndSize(bf, 16);
					cb.beginText();
					//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
					} // end if sendEmail	
					//****************************************************************************************//					
					//System.out.println("f_receipt = "+doString.checkString(rs.getString("f_receipt")));
					
					chkvat = 0;
					sql.delete(0, sql.length());
					sql.append("select sum(b.z_vat) as z_vat")
						.append(" from lan:acrdtrec a, lan:acrrecev b")//.append(" from lan:acrdtrec a
						.append(" where a.s_item = b.s_item and a.i_receipt= '")
						.append(doString.checkString(rs.getString("i_receipt")))
						.append("' and a.i_com_recv = '")
						.append(recvCom)
						.append("'");					
					//System.out.println("sql = "+sql.toString());
					rs1 = stmt1.executeQuery(sql.toString());
					
					if (rs1.next()) {
						chkvat = rs1.getDouble("z_vat");
					}
					rs1.close();					
					
					shw_rcpt = "";
					taxINV = "";
					
					//System.out.println("f_receipt = "+doString.checkString(rs.getString("f_receipt"))+"; flagReprint = "+flagRePrint+"; chkvat = "+chkvat);

					if (doString.checkString(rs.getString("f_receipt")).equals("Y")) {
						if (flagRePrint.equals("Y") || flagRePrint.equals("R") || flagRePrint.equals("F")) { //** 2016-07-08 # Roj , add flag F condition **//
							sql.delete(0, sql.length());
							sql.append("select i_tax_inv from lan:acrtaxinv")
								.append(" where i_com_recv = '")
								.append(recvCom)
								.append("' and i_receipt = '")
								.append(doString.checkString(rs.getString("i_receipt")))
								.append("'");
							//System.out.println("sql = "+sql.toString());
							rs1 = stmt1.executeQuery(sql.toString());
							
							if (rs1.next()) {
								shw_rcpt = setLabelThai(realPath,"ใบกำกับภาษีเลขที่ ") + doString.checkString(rs1.getString("i_tax_inv"));
							} // end if rs1
							rs1.close();
						} else if (flagRePrint.equals("T")) {
							shw_rcpt = setLabelThai(realPath,"ใบกำกับภาษีเลขที่ ") + doString.checkString(rs.getString("i_tax_inv"));
						} // end if flagRePrint = 'Y' || 'R'
					} else { // else rs.getstr(f_receipt = '')
						if (chkvat == 0) {
							shw_rcpt = ""; //ไม่ต้องพิมพ์ใบกำกับภาษี							
						} else {
							int sdoc = 0;
							sql.delete(0, sql.length());
							sql.append("select s_doc as seqno from lan:acxcntrl")
								.append(" where i_company = '")
								.append(recvCom)
								.append("' and i_document = '9' and d_year = '")
								.append(Integer.toString(Integer.parseInt(doString.checkString(rs.getString("d_receipt")).substring(0, 4)) + 543))
								.append("'");
							//System.out.println("sql = "+sql.toString());
							rs1 = stmt1.executeQuery(sql.toString());
							
							if (rs1.next()) {
								sdoc = rs1.getInt("seqno");
							} // End if rs1
							rs1.close();
							sdoc++;

							sql.delete(0, sql.length());
							if (sdoc == 1) {
								sql.append("insert into lan:acxcntrl (i_company, i_project, i_document, d_year, s_doc) values ('")
									.append(recvCom)
									.append("', NULL, '9', '")
									.append(Integer.toString(Integer.parseInt(doString.checkString(rs.getString("d_receipt")).substring(0, 4)) + 543))
									.append("', '")
									.append(sdoc)
									.append("')");
							} else {
								sql.append("update lan:acxcntrl set s_doc = '")
									.append(sdoc)
									.append("' where i_company = '")
									.append(recvCom)
									.append("' and i_document = '9' and d_year = '")
									.append(Integer.toString(Integer.parseInt(doString.checkString(rs.getString("d_receipt")).substring(0, 4)) + 543))
									.append("'");
							}								
							stmt1.executeUpdate(sql.toString());

							taxINV = recvCom + Integer.toString(Integer.parseInt(doString.checkString(rs.getString("d_receipt")).substring(0, 4)) + 543) + doString.checkString(rs.getString("d_receipt")).substring(5, 7) + doString.displayNumber("0000", sdoc);
							shw_rcpt = setLabelThai(realPath,"ใบกำกับภาษีเลขที่ ") + taxINV;
						} // End if z_vat == 0						
					} // End if rs.getstr(f_receipt = 'Y')
					
					//System.out.println("shw_rcpt = "+shw_rcpt);
					//shw_rcpt = "ใบกำกับภาษีเลขที่ 123456";
					//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
					if (!sendEmail) {
					//****************************************************************************************//					
					if (!shw_rcpt.equals("")){
						cb.setTextMatrix(30, 711);//8, 730
						cb.showText(shw_rcpt);
					}					
					//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
					} // end if sendEmail	
					//****************************************************************************************//

					cusname = "";
					cusname2 = "";
					cusadr = "";
					adrtyp = "";
					shw_addr1 = "";
					shw_addr2 = "";
					shw_addr3 = "";			
					postCode = "";
					fCorp = "";						

					srt = "";
					iden = "";
					
					if (rs.getInt("i_lor") < 990000) { 
						String cusid = "", cusid2 = "";
						sql.delete(0, sql.length());
						sql.append("select i_cus_intent1, i_cus_intent2, i_exp_intent1, i_exp_intent2, i_cus_contract, i_address_type, i_sort")
							.append(" from lan:acscontr")
							.append(" where i_company = '")
							.append(doString.checkString(rs.getString("i_company")))
							.append("' and i_project = '")
							.append(doString.checkString(rs.getString("i_project")))
							.append("' and i_lor = '")
							.append(doString.checkString(rs.getString("i_lor")))
							.append("'");
						//System.out.println("sql = "+sql.toString());
						rs1 = stmt1.executeQuery(sql.toString());
						
						if (rs1.next()) {
							if (!doString.checkString(rs1.getString("i_cus_intent1")).equals(""))	{
								cusid = doString.checkString(rs1.getString("i_cus_intent1"));
								cusid2 = doString.checkString(rs1.getString("i_cus_intent2"));
							} else {
								cusid = doString.checkString(rs1.getString("i_exp_intent1"));
								cusid2 = doString.checkString(rs1.getString("i_exp_intent2"));
							}
							
							//************** 2016-07-08 , Roj ***************//	
							if (reprintData==null) {
								insertData[8] = cusid;
								insertData[10] = cusid2;
							}
							//***********************************************//	
								
							/*
							if (!doString.checkString(rs1.getString("i_cus_intent2")).equals(""))	{
								cusid2 = doString.checkString(rs1.getString("i_cus_intent2"));
							} else {
								cusid2 = doString.checkString(rs1.getString("i_exp_intent2"));
							}
							*/
							adrtyp = doString.checkString(rs1.getString("i_address_type"));
							srt = doString.checkString(rs1.getString("i_sort"));

							sql.delete(0, sql.length());
							sql.append("select * from lan:acxcusto")
								.append(" where i_customer = '")
								.append(doString.checkString(rs1.getString("i_cus_contract")))
								.append("'");							
							//System.out.println("sql = "+sql.toString());
							rs1 = stmt1.executeQuery(sql.toString());
							
							if (rs1.next()) {
								if (adrtyp.equals("")){
									adrtyp = doString.checkString(rs1.getString("i_address_type"));
								}
								if (adrtyp.equals("1")) {
									if (!doString.checkString(rs1.getString("a_id_add1")).equals("-") && !doString.checkString(rs1.getString("a_id_add1")).equals("")) {
										shw_addr1 += doString.DisplayThai(doString.checkString(rs1.getString("a_id_add1"))) + " ";
										cusadr += doString.DisplayThai(doString.checkString(rs1.getString("a_id_add1"))) + " ";
									}
									if (!doString.checkString(rs1.getString("a_id_add2")).equals("-") && !doString.checkString(rs1.getString("a_id_add2")).equals("")) {
										shw_addr1 += setLabelThai(realPath,"หมู่ ")+doString.DisplayThai(doString.checkString(rs1.getString("a_id_add2"))) + " ";
										cusadr += setLabelThai(realPath,"หมู่ ")+doString.DisplayThai(doString.checkString(rs1.getString("a_id_add2"))) + " ";
									}
									if (!doString.checkString(rs1.getString("a_id_add3")).equals("-") && !doString.checkString(rs1.getString("a_id_add3")).equals("")) {
										shw_addr1 += setLabelThai(realPath,"ซ.")+doString.DisplayThai(doString.checkString(rs1.getString("a_id_add3"))) + " ";
										cusadr += setLabelThai(realPath,"ซ.")+doString.DisplayThai(doString.checkString(rs1.getString("a_id_add3"))) + " ";
									}
									if (!doString.checkString(rs1.getString("a_id_add4")).equals("-") && !doString.checkString(rs1.getString("a_id_add4")).equals("")) {
										shw_addr1 += setLabelThai(realPath,"ถ.")+doString.DisplayThai(doString.checkString(rs1.getString("a_id_add4"))) + " ";
										cusadr += setLabelThai(realPath,"ถ.")+doString.DisplayThai(doString.checkString(rs1.getString("a_id_add4"))) + " ";
									}

									String addr7 = doString.DisplayThai(doString.checkString(rs1.getString("a_id_add7"),"")).trim();
									boolean isBangkok = (addr7.indexOf(setLabelThai(realPath,"กทม"))>=0 || addr7.indexOf(setLabelThai(realPath,"กรุงเทพ"))>=0);

									if (!doString.checkString(rs1.getString("a_id_add5")).equals("-") && !doString.checkString(rs1.getString("a_id_add5")).equals("")) {
										//if (doString.DisplayThai(doString.checkString(rs1.getString("a_id_add7"))).substring(0, 3).equals("กทม") || doString.DisplayThai(doString.checkString(rs1.getString("a_id_add7"))).substring(0, 7).equals("กรุงเทพ")) {
										if (isBangkok) {
											shw_addr2 += setLabelThai(realPath,"แขวง");
										} else {
											shw_addr2 += setLabelThai(realPath,"ต.");
										}
										shw_addr2 += doString.DisplayThai(doString.checkString(rs1.getString("a_id_add5"))) + " ";
										cusadr += doString.DisplayThai(doString.checkString(rs1.getString("a_id_add5"))) + " ";
									}
									if (!doString.checkString(rs1.getString("a_id_add6")).equals("-") && !doString.checkString(rs1.getString("a_id_add6")).equals("")) {
										//if (doString.DisplayThai(doString.checkString(rs1.getString("a_id_add7"))).substring(0, 3).equals("กทม") || doString.DisplayThai(doString.checkString(rs1.getString("a_id_add7"))).substring(0, 7).equals("กรุงเทพ")) {
										if (isBangkok) {
											shw_addr2 += setLabelThai(realPath,"เขต");
										} else {
											shw_addr2 += setLabelThai(realPath,"อ.");
										}
										shw_addr2 += doString.DisplayThai(doString.checkString(rs1.getString("a_id_add6"))) + " ";
										cusadr += doString.DisplayThai(doString.checkString(rs1.getString("a_id_add6"))) + " ";
									}
									if (!doString.checkString(rs1.getString("a_id_add7")).equals("-") && !doString.checkString(rs1.getString("a_id_add7")).equals("")) {
										if (!isBangkok) {
											shw_addr3 += setLabelThai(realPath,"จ.");
											cusadr += setLabelThai(realPath,"จ.");
										}											
										shw_addr3 += doString.DisplayThai(doString.checkString(rs1.getString("a_id_add7"))) + " ";
										cusadr += doString.DisplayThai(doString.checkString(rs1.getString("a_id_add7"))) + " ";										
									}
									if (!doString.checkString(rs1.getString("a_id_postcode")).equals("-") && !doString.checkString(rs1.getString("a_id_postcode")).equals("")) {
										shw_addr3 += doString.DisplayThai(doString.checkString(rs1.getString("a_id_postcode")));
										cusadr += doString.DisplayThai(doString.checkString(rs1.getString("a_id_postcode")));
										postCode = doString.DisplayThai(doString.checkString(rs1.getString("a_id_postcode"))); // 2023-09-15 , new field
									}
								} else if (adrtyp.equals("2")) {
									if (!doString.checkString(rs1.getString("a_wk_name")).equals("-") && !doString.checkString(rs1.getString("a_wk_name")).equals("")) {
										shw_addr1 += doString.DisplayThai(doString.checkString(rs1.getString("a_wk_name"))) + " ";
										cusadr += doString.DisplayThai(doString.checkString(rs1.getString("a_wk_name"))) + " ";
									}
									if (!doString.checkString(rs1.getString("a_wk_add1")).equals("-") && !doString.checkString(rs1.getString("a_wk_add1")).equals("")) {
										shw_addr1 += doString.DisplayThai(doString.checkString(rs1.getString("a_wk_add1"))) + " ";
										cusadr += doString.DisplayThai(doString.checkString(rs1.getString("a_wk_add1"))) + " ";
									}
									if (!doString.checkString(rs1.getString("a_wk_add2")).equals("-") && !doString.checkString(rs1.getString("a_wk_add2")).equals("")) {
										shw_addr1 += setLabelThai(realPath,"หมู่ ")+doString.DisplayThai(doString.checkString(rs1.getString("a_wk_add2"))) + " ";
										cusadr += setLabelThai(realPath,"หมู่ ")+doString.DisplayThai(doString.checkString(rs1.getString("a_wk_add2"))) + " ";
									}
									if (!doString.checkString(rs1.getString("a_wk_add3")).equals("-") && !doString.checkString(rs1.getString("a_wk_add3")).equals("")) {
										shw_addr1 += setLabelThai(realPath,"ซ.")+doString.DisplayThai(doString.checkString(rs1.getString("a_wk_add3"))) + " ";
										cusadr += setLabelThai(realPath,"ซ.")+doString.DisplayThai(doString.checkString(rs1.getString("a_wk_add3"))) + " ";
									}
									if (!doString.checkString(rs1.getString("a_wk_add4")).equals("-") && !doString.checkString(rs1.getString("a_wk_add4")).equals("")) {
										shw_addr1 += setLabelThai(realPath,"ถ.")+doString.DisplayThai(doString.checkString(rs1.getString("a_wk_add4"))) + " ";
										cusadr += setLabelThai(realPath,"ถ.")+doString.DisplayThai(doString.checkString(rs1.getString("a_wk_add4"))) + " ";
									}

									String addr7 = doString.DisplayThai(doString.checkString(rs1.getString("a_wk_add7"),"")).trim();
									boolean isBangkok = (addr7.indexOf(setLabelThai(realPath,"กทม"))>=0 || addr7.indexOf(setLabelThai(realPath,"กรุงเทพ"))>=0);
									
									if (!doString.checkString(rs1.getString("a_wk_add5")).equals("-") && !doString.checkString(rs1.getString("a_wk_add5")).equals("")) {
										//if (doString.DisplayThai(doString.checkString(rs1.getString("a_wk_add7"))).substring(0, 3).equals("กทม") || doString.DisplayThai(doString.checkString(rs1.getString("a_wk_add7"))).substring(0, 7).equals("กรุงเทพ")) {
										if (isBangkok) {
											shw_addr2 += setLabelThai(realPath,"แขวง");
										} else {
											shw_addr2 += setLabelThai(realPath,"ต.");
										}
										shw_addr2 += doString.DisplayThai(doString.checkString(rs1.getString("a_wk_add5"))) + " ";
										cusadr += doString.DisplayThai(doString.checkString(rs1.getString("a_wk_add5"))) + " ";
									}
									if (!doString.checkString(rs1.getString("a_wk_add6")).equals("-") && !doString.checkString(rs1.getString("a_wk_add6")).equals("")) {
										//if (doString.DisplayThai(doString.checkString(rs1.getString("a_wk_add7"))).substring(0, 3).equals("กทม") || doString.DisplayThai(doString.checkString(rs1.getString("a_wk_add7"))).substring(0, 7).equals("กรุงเทพ")) {
										if (isBangkok) {
											shw_addr2 += setLabelThai(realPath,"เขต");
										} else {
											shw_addr2 += setLabelThai(realPath,"อ.");
										}
										shw_addr2 += doString.DisplayThai(doString.checkString(rs1.getString("a_wk_add6"))) + " ";
										cusadr += doString.DisplayThai(doString.checkString(rs1.getString("a_wk_add6"))) + " ";
									}
									if (!doString.checkString(rs1.getString("a_wk_add7")).equals("-") && !doString.checkString(rs1.getString("a_wk_add7")).equals("")) {
										if (!isBangkok) {
											shw_addr3 += setLabelThai(realPath,"จ.");
											cusadr += setLabelThai(realPath,"จ.");
										}											
										shw_addr3 += doString.DisplayThai(doString.checkString(rs1.getString("a_wk_add7"))) + " ";
										cusadr += doString.DisplayThai(doString.checkString(rs1.getString("a_wk_add7"))) + " ";
									}
									if (!doString.checkString(rs1.getString("a_wk_postcode")).equals("-") && !doString.checkString(rs1.getString("a_wk_postcode")).equals("")) {
										shw_addr3 += doString.DisplayThai(doString.checkString(rs1.getString("a_wk_postcode")));
										cusadr += doString.DisplayThai(doString.checkString(rs1.getString("a_wk_postcode")));
										postCode = doString.DisplayThai(doString.checkString(rs1.getString("a_wk_postcode"))); // 2023-09-15 , new field
									}
								} else if (adrtyp.equals("3")) {
									if (!doString.checkString(rs1.getString("a_etc_name")).equals("-") && !doString.checkString(rs1.getString("a_etc_name")).equals("")) {
										shw_addr1 += doString.DisplayThai(doString.checkString(rs1.getString("a_etc_name"))) + " ";
										cusadr += doString.DisplayThai(doString.checkString(rs1.getString("a_etc_name"))) + " ";
									}
									if (!doString.checkString(rs1.getString("a_etc_add1")).equals("-") && !doString.checkString(rs1.getString("a_etc_add1")).equals("")) {
										shw_addr1 += doString.DisplayThai(doString.checkString(rs1.getString("a_etc_add1"))) + " ";
										cusadr += doString.DisplayThai(doString.checkString(rs1.getString("a_etc_add1"))) + " ";
									}
									if (!doString.checkString(rs1.getString("a_etc_add2")).equals("-") && !doString.checkString(rs1.getString("a_etc_add2")).equals("")) {
										shw_addr1 += setLabelThai(realPath,"หมู่ ")+doString.DisplayThai(doString.checkString(rs1.getString("a_etc_add2"))) + " ";
										cusadr += setLabelThai(realPath,"หมู่ ")+doString.DisplayThai(doString.checkString(rs1.getString("a_etc_add2"))) + " ";
									}
									if (!doString.checkString(rs1.getString("a_etc_add3")).equals("-") && !doString.checkString(rs1.getString("a_etc_add3")).equals("")) {
										shw_addr1 += setLabelThai(realPath,"ซ.")+doString.DisplayThai(doString.checkString(rs1.getString("a_etc_add3"))) + " ";
										cusadr += setLabelThai(realPath,"ซ.")+doString.DisplayThai(doString.checkString(rs1.getString("a_etc_add3"))) + " ";
									}
									if (!doString.checkString(rs1.getString("a_etc_add4")).equals("-") && !doString.checkString(rs1.getString("a_etc_add4")).equals("")) {
										shw_addr1 += setLabelThai(realPath,"ถ.")+doString.DisplayThai(doString.checkString(rs1.getString("a_etc_add4"))) + " ";
										cusadr += setLabelThai(realPath,"ถ.")+doString.DisplayThai(doString.checkString(rs1.getString("a_etc_add4"))) + " ";
									}

									String addr7 = doString.DisplayThai(doString.checkString(rs1.getString("a_etc_add7"),"")).trim();
									boolean isBangkok = (addr7.indexOf(setLabelThai(realPath,"กทม"))>=0 || addr7.indexOf(setLabelThai(realPath,"กรุงเทพ"))>=0);
									
									if (!doString.checkString(rs1.getString("a_etc_add5")).equals("-") && !doString.checkString(rs1.getString("a_etc_add5")).equals("")) {
										//if (doString.DisplayThai(doString.checkString(rs1.getString("a_etc_add7"))).substring(0, 3).equals("กทม") || doString.DisplayThai(doString.checkString(rs1.getString("a_etc_add7"))).substring(0, 7).equals("กรุงเทพ")) {
										if (isBangkok) {
											shw_addr2 += setLabelThai(realPath,"แขวง");
										} else {
											shw_addr2 += setLabelThai(realPath,"ต.");
										}
										shw_addr2 += doString.DisplayThai(doString.checkString(rs1.getString("a_etc_add5"))) + " ";
										cusadr += doString.DisplayThai(doString.checkString(rs1.getString("a_etc_add5"))) + " ";
									}
									if (!doString.checkString(rs1.getString("a_etc_add6")).equals("-") && !doString.checkString(rs1.getString("a_etc_add6")).equals("")) {
										//if (doString.DisplayThai(doString.checkString(rs1.getString("a_etc_add7"))).substring(0, 3).equals("กทม") || doString.DisplayThai(doString.checkString(rs1.getString("a_etc_add7"))).substring(0, 7).equals("กรุงเทพ")) {
										if (isBangkok) {
											shw_addr2 += setLabelThai(realPath,"เขต");
										} else {
											shw_addr2 += setLabelThai(realPath,"อ.");
										}
										shw_addr2 += doString.DisplayThai(doString.checkString(rs1.getString("a_etc_add6"))) + " ";
										cusadr += doString.DisplayThai(doString.checkString(rs1.getString("a_etc_add6"))) + " ";
									}
									if (!doString.checkString(rs1.getString("a_etc_add7")).equals("-") && !doString.checkString(rs1.getString("a_etc_add7")).equals("")) {
										if (!isBangkok) {
											shw_addr3 += setLabelThai(realPath,"จ.");
											cusadr += setLabelThai(realPath,"จ.");
										}											
										shw_addr3 += doString.DisplayThai(doString.checkString(rs1.getString("a_etc_add7"))) + " ";
										cusadr += doString.DisplayThai(doString.checkString(rs1.getString("a_etc_add7"))) + " ";
									}
									if (!doString.checkString(rs1.getString("a_etc_postcode")).equals("-") && !doString.checkString(rs1.getString("a_etc_postcode")).equals("")) {
										shw_addr3 += doString.DisplayThai(doString.checkString(rs1.getString("a_etc_postcode")));
										cusadr += doString.DisplayThai(doString.checkString(rs1.getString("a_etc_postcode")));
										postCode = doString.DisplayThai(doString.checkString(rs1.getString("a_etc_postcode"))); // 2023-09-15 , new field
									}
								}
							} // End if rs1
							rs1.close();
							
						} // End if rs1
						rs1.close(); 
						
						
						//---- 2023-09-15 , check customer is coperate or not ----// 
						fCorp = "";
						if (cusid.length()>0) {
							sql.delete(0, sql.length());
							sql.append(" select * from lan:acxcustmail where i_customer='"+cusid+"' ");
							rs1 = stmt1.executeQuery(sql.toString());							
							if (rs1.next()) {
								fCorp = doString.checkString(rs1.getString("f_corp"),"");
							}
							rs1.close();
						}
						//--------------------------------------------------------//						
							
						
						sql.delete(0, sql.length());
						//sql.append("select trim(n_prename) || trim(n_ncustomer) || ' ' || trim(n_scustomer) as name")
						sql.append("select n_prename, n_ncustomer, n_scustomer")
							.append(" from lan:acxcusto")
							.append(" where i_customer = '")
							.append(cusid)
							.append("'");
						//System.out.println("sql = "+sql.toString());
						rs1 = stmt1.executeQuery(sql.toString());
						
						if (rs1.next()) {
							//cusname = doString.checkString(doString.DisplayThai(rs1.getString("name")));
							if (!doString.checkString(doString.DisplayThai(rs1.getString("n_prename"))).equals("")) {
								cusname = doString.checkString(doString.DisplayThai(rs1.getString("n_prename")));
							} else {
								cusname = setLabelThai(realPath,"คุณ");									
							}
							//cusname = doString.checkString(doString.DisplayThai(rs1.getString("name")));
							cusname += doString.checkString(doString.DisplayThai(rs1.getString("n_ncustomer"))) + " " + doString.checkString(doString.DisplayThai(rs1.getString("n_scustomer")));
							
							n_name = doString.checkString(rs1.getString("n_ncustomer"));
							s_name = doString.checkString(rs1.getString("n_scustomer"));
						} // End if rs1
						rs1.close();
						
						sql.delete(0, sql.length());
						sql.append("select n_prename, n_ncustomer, n_scustomer")
							.append(" from lan:acxcusto")
							.append(" where i_customer = '")
							.append(cusid2)
							.append("'");
						//System.out.println("sql = "+sql.toString());
						rs1 = stmt1.executeQuery(sql.toString());
						
						if (rs1.next()) {
							if (!doString.checkString(doString.DisplayThai(rs1.getString("n_prename"))).equals("")) {
								cusname2 = doString.checkString(doString.DisplayThai(rs1.getString("n_prename")));
							} else {
								cusname2 = setLabelThai(realPath,"คุณ");									
							}
							cusname2 += doString.checkString(doString.DisplayThai(rs1.getString("n_ncustomer"))) + " " + doString.checkString(doString.DisplayThai(rs1.getString("n_scustomer")));
						} // End if rs1
						rs1.close();

						//********** 2019-06-04 , change query method ***********//
						/*sql.delete(0, sql.length());
						sql.append("select i_owner_iden")
							.append(" from lan:acsowner")
							.append(" where n_owner_nnam = '")
							.append(n_name)
							.append("' and n_owner_snam = '")
							.append(s_name)
							.append("' and i_owner_iden is not null and trim(i_owner_iden) != '' order by i_owner_iden");
						//System.out.println("sql = "+sql.toString());
						rs1 = stmt1.executeQuery(sql.toString());*/						
						//********** 2019-06-04 , change query method ***********//
						sql.delete(0, sql.length());
						sql.append(" select i_owner_iden from lan:acsowner ")
						   .append(" where n_owner_nnam = ? and n_owner_snam = ? ")
						   .append(" and i_owner_iden is not null and trim(i_owner_iden) != '' ")
						   .append(" order by i_owner_iden ");
						PreparedStatement pstmt = Conn.prepareStatement(sql.toString());
						pstmt.setString(1,n_name);
						pstmt.setString(2,s_name);
						rs1 = pstmt.executeQuery();
						//******************************************************//
						if (rs1.next()) {
							iden = doString.DisplayThai(doString.checkString(rs1.getString("i_owner_iden")));
						} // End if rs1
						rs1.close();
						pstmt.close();
						
					} else if (rs.getInt("i_lor") > 990000) {
						//--- 2023-09-15 , new field ---//
						postCode = "";
						fCorp = "";
						
						sql.delete(0, sql.length());
						sql.append("select n_vendor, a_ven_add1, a_ven_add2, i_dentity")
							.append(" from lan:acxvendr")
							.append(" where i_vendor = '")
							.append(rs.getInt("i_lor") - (rs.getInt("i_lor")<9900000 ? 990000 : 9900000)) 
							.append("'");
						//System.out.println("sql = "+sql.toString());
						rs1 = stmt1.executeQuery(sql.toString());
						
						if (rs1.next()) {
							cusname = doString.checkString(doString.DisplayThai(rs1.getString("n_vendor")));
							if (!doString.checkString(rs1.getString("a_ven_add1")).equals("-") && !doString.checkString(rs1.getString("a_ven_add1")).equals("")) {
								shw_addr1 += doString.DisplayThai(doString.checkString(rs1.getString("a_ven_add1"))) + " ";
							}
							if (!doString.checkString(rs1.getString("a_ven_add2")).equals("-") && !doString.checkString(rs1.getString("a_ven_add2")).equals("")) {
								shw_addr2 += doString.DisplayThai(doString.checkString(rs1.getString("a_ven_add2"))) + " ";
							}
							iden = doString.checkString(rs1.getString("i_dentity"));							
						} // End if rs1
						rs1.close();
						
						//************** 2016-07-08 , Roj ***************//	
						if (reprintData==null) {
							//--- set i_vendor instead i_customer ---//
							insertData[8] = Integer.toString(rs.getInt("i_lor") - (rs.getInt("i_lor")<9900000 ? 990000 : 9900000));
							insertData[10] = "";
						}
						//***********************************************//	
						 
					} // End if i_lor < 990000 and 9900000

					
					boolean isR2 = false; // 2019-05-03 , check receipt R2
					sql.delete(0, sql.length());
					sql.append("select n_reten, i_due, id_no from lan:serv_payin")
						.append(" where i_company = '")
						.append(doString.checkString(rs.getString("i_company")))
						.append("' and i_receipt = '")
						.append(doString.checkString(rs.getString("i_receipt")))
						.append("'");					
					//System.out.println("sql = "+sql.toString());
					rs1 = stmt1.executeQuery(sql.toString());
					if (rs1.next()) {
						//---- 2023-11-30 , change algorithm , if n_reten blank , skip all process fro O5 & R2  ----//
						if (doString.checkString(rs1.getString("n_reten"),"").trim().length()>0) {
							cusname = doString.DisplayThai(doString.checkString(rs1.getString("n_reten"),""));
							cusname2 = "";
							if (!doString.checkString(rs1.getString("i_due")).equals("R2") && !doString.checkString(rs1.getString("i_due")).equals("N5")) {
								shw_addr1 = "";
								shw_addr2 = "";
								shw_addr3 = "";
								postCode = "";
							}						
							iden = doString.DisplayThai(doString.checkString(rs1.getString("id_no")));

							//---- 2019-05-03 , check receipt R2 ----//
							if (doString.checkString(rs1.getString("i_due")).equals("R2")) {
								isR2 = true;
							}	
						} else {
							//---- 2023-11-30 , if n_reten is blank , fixed isR2 to false ----//
							isR2 = false;
						} // end if check n_reten
						
					} // End if rs1
					rs1.close();
					
					
					//****************** 2018-06-25  Roj , get new address ***************//
					if (isR2) {
						//--- 20019-05-03 , get new address for R2 only ---//						
						sql.delete(0, sql.length());
						sql.append(" select * from lan:acscontr c,lan:acxlckmd m ")
						   .append(" left join lan:serv_inflck l on l.i_company=m.i_company and l.i_project=m.i_project and l.i_house=m.i_house ")
						   .append(" where c.i_company='"+doString.checkString(rs.getString("i_company"))+"' ")
						   .append(" and c.i_project='"+doString.checkString(rs.getString("i_project"))+"' ")
						   .append(" and c.i_lor='"+doString.checkString(rs.getString("i_lor"))+"' ")
						   .append(" and m.i_company=c.i_company and m.i_project=c.i_project and m.i_lor=c.i_lor ");
						rs1 = stmt1.executeQuery(sql.toString());
						if (rs1.next()) {
							String tmpA1 = doString.checkString(rs1.getString("a_address1")).trim();
							String tmpA2 = doString.checkString(rs1.getString("a_address2")).trim();
							String tmpA3 = doString.checkString(rs1.getString("a_address3")).trim();						
							
							if (tmpA1.length()>1 || tmpA2.length()>1 || tmpA3.length()>1) {
								shw_addr1 = doString.DisplayThai(tmpA1);
								shw_addr2 = doString.DisplayThai(tmpA2);
								shw_addr3 = doString.DisplayThai(tmpA3);
								iden = doString.DisplayThai(doString.checkString(rs1.getString("id_no")));
								//--- 2023-09-15 , new field ---//
								postCode =  doString.DisplayThai(doString.checkString(rs1.getString("i_zipcode"))); 
								fCorp =  doString.DisplayThai(doString.checkString(rs1.getString("f_corp"))); 								
							}
						} // End if rs1
						rs1.close();
						
						
						//--- 2022-05-09 , replace address with project's address if found data ---//
						sql.delete(0, sql.length());
						sql.append(" select * from lan:serv_proj ")
						   .append(" where i_company='"+doString.checkString(rs.getString("i_company"))+"' ")
						   .append(" and i_project='"+doString.checkString(rs.getString("i_project"))+"' ");						
						rs1 = stmt1.executeQuery(sql.toString());
						if (rs1.next()) {
							String tmpA1 = doString.checkString(rs1.getString("a_address1")).trim();
							String tmpA2 = doString.checkString(rs1.getString("a_address2")).trim();
							String tmpA3 = doString.checkString(rs1.getString("a_address3")).trim();						
							
							if (tmpA1.length()>1 || tmpA2.length()>1 || tmpA3.length()>1) {
								shw_addr1 = doString.DisplayThai(tmpA1);
								shw_addr2 = doString.DisplayThai(tmpA2);
								shw_addr3 = doString.DisplayThai(tmpA3);
								//--- 2023-09-15 , new field ---//
								postCode =  doString.DisplayThai(doString.checkString(rs1.getString("i_postcode"))); 								
							}
						} // End if rs1
						rs1.close();							
					}
					//****************** 2016-06-25  Roj , get new address ***************//
					

					// เลขทะเบียนนิติบุคคล/บัตร ปชช.
					//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
					if (!sendEmail) {
					//****************************************************************************************//					
					if (chkvat > 0 && !iden.equals("")) {
						cb.setTextMatrix(300, 711);
						cb.showText(setLabelThai(realPath,"เลขทะเบียนนิติบุคคล/บัตรประชาชน ")+iden);
					} // End if chkvat			
					//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
					} // end if sendEmail	
					//****************************************************************************************//

					//System.out.println("rs get i_user = "+doString.checkString(rs.getString("i_user")));
					off_branch = "";
					if (!doString.checkString(rs.getString("i_user")).equals("")) {
						sql.delete(0, sql.length());
						sql.append("select off_branch from lan:payuser")
							.append(" where i_employ = '")
							.append(doString.checkString(rs.getString("i_user")).substring(2, 6)+"-"+doString.checkString(rs.getString("i_user")).substring(6))
							.append("'");					
						//System.out.println("sql = "+sql.toString());
						rs1 = stmt1.executeQuery(sql.toString());
						
						if (rs1.next()) {
							off_branch = doString.DisplayThai(doString.checkString(rs1.getString("off_branch")));
						} // End if rs1
						rs1.close();
					} // End if i_user != ""

					//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
					if (!sendEmail) {
					//****************************************************************************************//
					cb.setTextMatrix(515, 728);
					cb.showText(off_branch);
					
					cb.endText();
					cb.setFontAndSize(bfb, 14);
					cb.beginText();
					//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
					} // end if sendEmail	
					//****************************************************************************************//

					//************** 2016-07-08 , Roj ***************//	
					if (reprintData!=null) {
						//-- 9 = n_cust1 , 11 = n_cust2 --//
						cusname = doString.MS874ToUnicode(doString.checkString(reprintData[9]));
						cusname2 = doString.MS874ToUnicode(doString.checkString(reprintData[11]));						
					} else {
						insertData[9] = cusname;
						insertData[11] = cusname2;
					}
					//**********************************************//						

					shw_from = cusname;
					if (!cusname2.equals("")) {
						shw_from += ", " + cusname2;
					}
					//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
					if (!sendEmail) {
					//****************************************************************************************//					
					cb.setTextMatrix(137, 696);//132, 703
					// for user wilairat cb.showText(shw_from + " สาขาที่ 00001");					
					cb.showText(shw_from);					
					//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
					} // end if sendEmail	
					//****************************************************************************************//

					/*
					//System.out.println("cusadr = "+cusadr);					
					shw_addr1 = cusadr;
					shw_addr2 = "";
					shw_addr3 = "";
					tmpadr = "";
					
					if (!cusadr.equals("")) {
						if (cusadr.length() >= 30) {
							shw_addr1 = cusadr.substring(0, 30);
							tmpadr = cusadr.substring(30);							
							if (tmpadr.indexOf(" ") > -1) {
								shw_addr1 += tmpadr.substring(0, tmpadr.indexOf(" "));
								tmpadr = tmpadr.substring(tmpadr.indexOf(" ")+1);
							}						
						} 
						System.out.println("shw_addr1 = "+shw_addr1);
						System.out.println("tmpadr = "+tmpadr);									
						if (tmpadr.length() >= 30) {
							shw_addr2 = tmpadr.substring(0, 30);		
							tmpadr = tmpadr.substring(30);							
							if (tmpadr.indexOf(" ") > -1) {
								shw_addr2 += tmpadr.substring(0, tmpadr.indexOf(" "));
								tmpadr = tmpadr.substring(tmpadr.indexOf(" ")+1);
							}						
						} else {
							shw_addr2 = tmpadr;
							tmpadr = "";
						}
						System.out.println("shw_addr2 = "+shw_addr2);
						System.out.println("tmpadr = "+tmpadr);		
						if (tmpadr.length() >= 1) {
							shw_addr3 = tmpadr;	
						}
						System.out.println("shw_addr3 = "+shw_addr3);
						System.out.println("tmpadr = "+tmpadr);			
					}
					*/			

					/*
					 *   2023-01-05 , cancel auto split text 
					 * 						tmpadr = "";
					if (!shw_addr1.equals("")) {
						if (shw_addr1.length() >= 30) {					
							tmpadr = shw_addr1.substring(30);					
							shw_addr1 = shw_addr1.substring(0, 30);				
							if (tmpadr.indexOf(" ") > -1) {
								shw_addr1 += tmpadr.substring(0, tmpadr.indexOf(" "));
								tmpadr = tmpadr.substring(tmpadr.indexOf(" ")+1);
							}						
						} 
					}
					shw_addr2 = tmpadr + shw_addr2;
					tmpadr = "";
					if (!shw_addr2.equals("")) {
						if (shw_addr2.length() >= 30) {					
							tmpadr = shw_addr2.substring(30);					
							shw_addr2 = shw_addr2.substring(0, 30);				
							if (tmpadr.indexOf(" ") > -1) {
								shw_addr2 += tmpadr.substring(0, tmpadr.indexOf(" "));
								tmpadr = tmpadr.substring(tmpadr.indexOf(" ")+1);
							}						
						} 
					}					
					shw_addr3 = tmpadr + shw_addr3;
					*
					*/
					
					
					//cb.setTextMatrix(75, 688);
					
					//************** 2016-07-08 , Roj ***************//	
					if (reprintData!=null) {
						//-- 12 = n_addr1 , 13 = n_addr2 , 14 = n_addr3 --//
						shw_addr1 = doString.MS874ToUnicode(doString.checkString(reprintData[12],""));
						shw_addr2 = doString.MS874ToUnicode(doString.checkString(reprintData[13],""));
						shw_addr3 = doString.MS874ToUnicode(doString.checkString(reprintData[14],""));
					} else {
						insertData[12] = shw_addr1;						
						insertData[13] = shw_addr2;						
						insertData[14] = shw_addr3;						
					}
					//***********************************************//	
					
					//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
					if (!sendEmail) {
					//****************************************************************************************//					
					cb.setTextMatrix(137, 677); //132, 684
					cb.showText(shw_addr1);
					if (!shw_addr2.equals("")) {
						cb.setTextMatrix(137, 657); //132, 664
						cb.showText(shw_addr2);
					}
					if (!shw_addr3.equals("")) { //1132, 644
						cb.setTextMatrix(137, 637);
						cb.showText(shw_addr3);
					}

					cb.endText();
					cb.setFontAndSize(bfb, 16);
					cb.beginText();
					//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
					} // end if sendEmail	
					//****************************************************************************************//					
					
					//************** 2016-07-08 , Roj ***************//	
					shw_date = "";
					tmpdate = "";
					shw_iRecpt = "";

					if (reprintData!=null) {
						// 4 = i_sort , 5 = i_receipt , 6 = d_receipt , 7 = s_receive
						shw_iRecpt = doString.checkString(reprintData[5]) + "(" + doString.checkString(reprintData[7]) + ")";					
						tmpdate = doString.checkString(reprintData[6]);
					} else {
						shw_iRecpt = doString.checkString(rs.getString("i_receipt")) + "(" + doString.checkString(rs.getString("s_receive")) + ")";					
						tmpdate = doString.checkString(rs.getString("d_receipt"));
						insertData[4] = srt;
						insertData[5] = doString.checkString(rs.getString("i_receipt"));						
						insertData[6] = doString.checkString(rs.getString("d_receipt"));						
						insertData[7] = doString.checkString(rs.getString("s_receive"));												
					}
					//**********************************************//	
					
					
					//---- 2017-05-09 , get s_receive list ----// 
					if (shw_iRecpt.indexOf("(")>0) {
						//--- clear old s_receive before gen new list ---//
						shw_iRecpt = shw_iRecpt.substring(0,shw_iRecpt.indexOf("("));
					}
					
					sql.delete(0, sql.length());
					sql.append("select distinct s_receive from lan:acrdtrec ")
						.append(" where i_receipt = '"+doString.checkString(rs.getString("i_receipt"),"")+"' ")
						.append(" and i_com_recv = '"+recvCom+"' ")
						.append(" order by s_receive ");
					//System.out.println("sql = "+sql.toString());
					rs1 = stmt1.executeQuery(sql.toString());
					while (rs1.next()) {						
						shw_iRecpt += "("+doString.checkString(rs1.getString("s_receive"))+")";
					} // End if rs1
					rs1.close();
					
					while (shw_iRecpt.indexOf(")(")>0) {
						 // convert (1)(2) = (1,2)
						shw_iRecpt = shw_iRecpt.substring(0,shw_iRecpt.indexOf(")("))+","+shw_iRecpt.substring(shw_iRecpt.indexOf(")(")+2);
					}
					//-------------------------------------------//
					
					
					//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
					if (!sendEmail) {
					//****************************************************************************************//
						String R2Code = getR2ShortCode(stmt1,doString.checkString(rs.getString("i_company"),""),doString.checkString(rs.getString("i_project"),""),doString.checkString(rs.getString("i_lor"),""),doString.checkString(rs.getString("i_receipt"),""));
					cb.setTextMatrix(30, 637);
					cb.showText(R2Code+"("+doString.checkString(rs.getString("i_company"))+doString.checkString(rs.getString("i_project"))+"-"+srt+")");
					cb.setTextMatrix(434, 696);//432, 704
					cb.showText(shw_iRecpt);						
					
					if (!tmpdate.equals("")) {
						tmpdate = tmpdate.substring(8) + "  " + setLabelThai(realPath,month[Integer.parseInt(tmpdate.substring(5, 7))]) + "  " + Integer.toString(Integer.parseInt(tmpdate.substring(0, 4))+543);  
					} // End if !tmpdate
					shw_date = tmpdate;
					cb.setTextMatrix(432, 677);//432, 684
					cb.showText(shw_date);

					shw_project = "";
					sql.delete(0, sql.length());
					sql.append("select n_project")
						.append(" from lan:acxprojt")
						.append(" where i_company = '")
						.append(doString.checkString(rs.getString("i_company")))
						.append("' and i_project = '")
						.append(doString.checkString(rs.getString("i_project")))
						.append("'");
					//System.out.println("sql = "+sql.toString());
					rs1 = stmt1.executeQuery(sql.toString());
					
					if (rs1.next()) {
						shw_project = doString.DisplayThai(doString.checkString(rs1.getString("n_project")));
					} // End if rs1
					rs1.close();

					cb.endText();
										
					//---- 2022-09-09 , change font size for long project name ----//
					if (shw_project.length()>=35) {
						//-- small font for long name --//
						cb.setFontAndSize(bfb, 12);
					} else {
						//-- normal font size --//
						cb.setFontAndSize(bfb, 14);
					}
					cb.beginText();
					cb.setTextMatrix(434, 657);//432, 664
					cb.showText(shw_project);
					cb.endText();
					//--------------------------------------------------------------//
					
					cb.setFontAndSize(bfb, 16);
					cb.beginText();

					shw_sort = srt;
					cb.setTextMatrix(434, 637);//432, 644
					cb.showText(shw_sort);
					//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
					} // end if sendEmail	
					//****************************************************************************************//
				} // End if oldrcpt != currcpt		
				
				payArr[payRun][0] = doString.checkString(rs.getString("i_mtype"));
				payArr[payRun][1] = doString.checkString(rs.getString("i_fbank"));
				payArr[payRun][2] = doString.checkString(rs.getString("i_fbranch"));
				payArr[payRun][3] = doString.checkString(rs.getString("i_type"));
				payArr[payRun][4] = doString.checkString(rs.getString("d_payin"));
				payArr[payRun][5] = doString.checkString(rs.getString("i_company"));
				payArr[payRun][6] = doString.checkString(rs.getString("i_project"));
				payArr[payRun][8] = doString.displayNumber("#####0.00", rs.getDouble("z_amount"));
				payArr[payRun][9] = doString.checkString(rs.getString("i_cheque"));
				payArr[payRun][10] = doString.checkString(rs.getString("d_receive"));
				payArr[payRun][11] = doString.checkString(rs.getString("d_receipt"));
				
				//System.out.println("payRun = "+payRun+"; mtype = "+payArr[payRun][0]);
				
				payRun++;	
				
				oldrcpt = currcpt;
				oldcomp = doString.checkString(rs.getString("i_com_recv"));
				oldIRecpt = doString.checkString(rs.getString("i_receipt"));
				sItem += "'" + doString.checkString(rs.getString("s_item")) + "', ";
				tmprcv = doString.checkString(rs.getString("i_user"));
				
				
				//************** 2016-07-08 , Roj ***************//
				if (!flagRePrint.equals("T")) {
					if (reprintData==null) {
						insertLogReceipt(Conn,stmt1,insertData,postCode,fCorp,"SYSTEM",sendEmail); // fixed emp_id with SYSTEM
					} else {
						updateLogReceipt(stmt1,recvCom,doString.checkString(rs.getString("i_receipt")),"SYSTEM");  // fixed emp_id with SYSTEM
					}
				}
				
				if (i>=idxLastPrintReceipt) break; // stop print when reach to bottom
				//***********************************************//					
				
			} // End while rs here , 2016-07-08 Roj
			rs.close();

			if (i >= 1) {
				line = 575;		
				acm1 = ""; acm2 = "";
				shw_sumprice = 0; shw_sumvat = 0; shw_sumtax = 0; shw_sumnet = 0;
				sql.delete(0, sql.length());
				sql.append("select sum(b.z_price) as z_price, sum(b.z_vat) as z_vat, sum(b.z_tax) as z_tax, b.i_due, b.c_receive")
					.append(" from lan:acrrecev b")
					.append(" where b.s_item in (")
					.append(sItem.substring(0, sItem.length() -2))
					.append(") group by b.i_due, b.c_receive order by b.i_due");					
				//System.out.println("2 sql = "+sql.toString());
				rs1 = stmt1.executeQuery(sql.toString());
				
				while (rs1.next()) {					
					sql.delete(0, sql.length());
					sql.append("select c_prn1_msg, c_prn2_msg")
						.append(" from lan:acmsgrcp")
						.append(" where i_company = '")
						.append(payArr[payRun-1][5])	
						.append("' and i_project = '")
						.append(payArr[payRun-1][6])	
						.append("' and d_beg_effect <= '")
						.append(payArr[payRun-1][11])	
						.append("' and d_end_effect >= '")
						.append(payArr[payRun-1][11])	
						.append("' and i_beg_due <= '")
						.append(doString.checkString(rs1.getString("i_due")))
						.append("' and i_end_due >= '")
						.append(doString.checkString(rs1.getString("i_due")))
						.append("'");					
					//System.out.println("2 sql 2 = "+sql.toString());
					urs = ustmt.executeQuery(sql.toString());
					
					if (urs.next()) {
						acm1 = doString.DisplayThai(doString.checkString(urs.getString("c_prn1_msg")));
						acm2 = doString.DisplayThai(doString.checkString(urs.getString("c_prn2_msg")));
					}
					urs.close();

					shw_detail = doString.DisplayThai(doString.checkString(rs1.getString("c_receive")));
					shw_price = rs1.getDouble("z_price");
					shw_vat = rs1.getDouble("z_vat");
					shw_tax = rs1.getDouble("z_tax");
					shw_net = shw_price + shw_vat - shw_tax;
	
					shw_sumprice += shw_price;
					shw_sumvat += shw_vat;
					shw_sumtax += shw_tax; 
					shw_sumnet += shw_net;												
	
					// LowLeftx, LowLefty,UpRightx, UpRighty
					//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
					if (!sendEmail) {
					//****************************************************************************************//					
					ct.setSimpleColumn(new Phrase(shw_detail, microssfont),	32, line, 210, line+19, 10, Element.ALIGN_LEFT);
					ct.go();				
					cb.endText();
					
					cb.setFontAndSize(bf, 16);
					cb.beginText();					
					ct.setSimpleColumn(new Phrase(doString.displayNumber("###,##0.00", shw_price), microssfont), 210, line, 310, line+19, 10, Element.ALIGN_RIGHT);
					ct.go();				
					cb.endText();
					
					cb.setFontAndSize(bf, 16);
					cb.beginText();						
					if (shw_vat == 0) {			
						ct.setSimpleColumn(new Phrase(" ", microssfont), 310, line, 395, line+19, 10, Element.ALIGN_RIGHT);
					} else {							
						ct.setSimpleColumn(new Phrase(doString.displayNumber("###,##0.00", shw_vat), microssfont), 310, line, 395, line+19, 10, Element.ALIGN_RIGHT);
					}
					ct.go();				
					cb.endText();
					
					cb.setFontAndSize(bf, 16);
					cb.beginText();						
					if (shw_tax == 0) {				
						ct.setSimpleColumn(new Phrase(" ", microssfont), 395, line, 480, line+19, 10, Element.ALIGN_RIGHT);
					} else {								
						ct.setSimpleColumn(new Phrase(doString.displayNumber("###,##0.00", shw_tax), microssfont), 395, line, 480, line+19, 10, Element.ALIGN_RIGHT);
					}
					ct.go();				
					cb.endText();
					
					cb.setFontAndSize(bf, 16);
					cb.beginText();					
					ct.setSimpleColumn(new Phrase(doString.displayNumber("###,##0.00", shw_net), microssfont), 480, line, 565, line+19, 10, Element.ALIGN_RIGHT);
					ct.go();				
					cb.endText();
					
					cb.setFontAndSize(bf, 16);
					cb.beginText();					
					
					line -= 20;
					//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
					} // end if sendEmail	
					//****************************************************************************************//					
				} // End while rs1
				rs1.close();			
				
				line = 350;
				// LowLeftx, LowLefty,UpRightx, UpRighty
				//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
				if (!sendEmail) {
				//****************************************************************************************//				
				ct.setSimpleColumn(new Phrase(doString.displayNumber("###,##0.00", shw_sumprice), microssfont), 210, line, 310, line+19, 10, Element.ALIGN_RIGHT);
				ct.go();				
				cb.endText();
				
				cb.setFontAndSize(bf, 16);
				cb.beginText();				
				if (shw_sumvat == 0) {					
					ct.setSimpleColumn(new Phrase(" ", microssfont), 310, line, 395, line+19, 10, Element.ALIGN_RIGHT);
				} else {									
					ct.setSimpleColumn(new Phrase(doString.displayNumber("###,##0.00", shw_sumvat), microssfont), 310, line, 395, line+19, 10, Element.ALIGN_RIGHT);
				}
				ct.go();				
				cb.endText();
				
				cb.setFontAndSize(bf, 16);
				cb.beginText();				
				if (shw_sumtax == 0) {					
					ct.setSimpleColumn(new Phrase(" ", microssfont), 395, line, 480, line+19, 10, Element.ALIGN_RIGHT);
				} else {												
					ct.setSimpleColumn(new Phrase(doString.displayNumber("###,##0.00", shw_sumtax), microssfont), 395, line, 480, line+19, 10, Element.ALIGN_RIGHT);
				}
				ct.go();				
				cb.endText();
				
				cb.setFontAndSize(bf, 16);
				cb.beginText();					
				ct.setSimpleColumn(new Phrase(doString.displayNumber("###,##0.00", shw_sumnet), microssfont), 480, line, 565, line+19, 10, Element.ALIGN_RIGHT);
				ct.go();				
				cb.endText();
				
				cb.setFontAndSize(bf, 16);
				cb.beginText();	
					
				CTT = new CurrencyToThai(shw_sumnet);
				shw_thaisumnet = doString.DisplayThai(CTT.getString());
				cb.setTextMatrix(105, 336);
				cb.showText("="+shw_thaisumnet+"=");				
				//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
				} // end if sendEmail	
				//****************************************************************************************//

				line = 308;
				wrtHD = false;
				chgArr = "";
				oldArr0 = "";
				oldArr1 = "";
				oldArr2 = "";
				oldArr3 = "";
				oldArr4 = "";
				oldArr5 = "";
				oldArr6 = "";
				oldArr7 = "";
				oldArr8 = 0;
				oldArr9 = "";
				oldArr10 = "";
				j = 0;
				for (payRun = 0; payRun < payCnt ; payRun++) {
					j++;
					if (!chgArr.equals(payArr[payRun][0]+payArr[payRun][10]+payArr[payRun][1]+payArr[payRun][2]+payArr[payRun][9]) && j > 1) {
						payby = "";
						cardNo = "";
						if (oldArr0.equals("6")) {
							sql.delete(0, sql.length());
							sql.append("select i_cr_digit")
								.append(" from lan:acrcrdig")
								.append(" where i_bank = '")
								.append(oldArr1)
								.append("' and i_cr_code = '")
								.append(oldArr2)
								.append("'");					
							//System.out.println("sql = "+sql.toString());
							rs1 = stmt1.executeQuery(sql.toString());
							
							if (rs1.next()) {
								cardNo = doString.checkString(rs1.getString("i_cr_digit")) + oldArr9;
							}						
							rs1.close();
							
							sql.delete(0, sql.length());
							sql.append("select n_finance")
								.append(" from lan:acxfinan")
								.append(" where i_finance = '")
								.append(oldArr1)
								.append("' and i_branch is null");					
							//System.out.println("sql = "+sql.toString());
							rs1 = stmt1.executeQuery(sql.toString());
							
							if (rs1.next()) {
								payby = setLabelThai(realPath,"บัตรเครดิต ") + doString.DisplayThai(doString.checkString(rs1.getString("n_finance"))) + setLabelThai(realPath," เลขที่ ");
							}						
							rs1.close();
							
							if (!cardNo.equals("")) {
								payby += cardNo.substring(0, 4) + " " + cardNo.substring(4, 8) + " " + cardNo.substring(8, 12) + " " + cardNo.substring(12);
							}
							payby += setLabelThai(realPath," จำนวนเงิน ") + doString.displayNumber("###,##0.00", oldArr8) + setLabelThai(realPath," บาท");
							
							//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
							if (!sendEmail) {
							//****************************************************************************************//							
							cb.setTextMatrix(75, line);
							cb.showText(payby);
							//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
							} // end if sendEmail	
							//****************************************************************************************//							
						} else if (oldArr0.equals("4")) {
							payby = setLabelThai(realPath,"รับนอกสถานที่ ");
							
							//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
							if (!sendEmail) {
							//****************************************************************************************//							
							cb.setTextMatrix(75, line);
							cb.showText(payby);
							//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
							} // end if sendEmail	
							//****************************************************************************************//							
						} else if (oldArr0.equals("1")) {
							if (oldArr3.equals("T")) {						
								sql.delete(0, sql.length());
								sql.append("select i_sort")
									.append(" from lan:acrmisdt")
									.append(" where post_date = '")
									.append(oldArr4)
									.append("' and f_confirm = 'Y' and i_company = '")
									.append(oldArr5)
									.append("' and i_project = '")
									.append(oldArr6)
									.append("' and i_sort = '")
									.append(srt)
									.append("'");					
								//System.out.println("sql 5 = "+sql.toString());
								rs1 = stmt1.executeQuery(sql.toString());
								
								if (rs1.next()) {
									tmpdate = oldArr4;
									//if (!tmpdate.equals("")) {
									//	tmpdate = tmpdate.substring(8) + "/" + tmpdate.substring(5, 7) + "/" + Integer.toString(Integer.parseInt(tmpdate.substring(0, 4))+543);  
									//} // End if !tmpdate
									
									//payby = "โอนเงินผ่านธนาคาร วันที่ "+ tmpdate + "  " + doString.displayNumber("###,##0.00", oldArr8) + " บาท";
								} else {
									tmpdate = oldArr10;
									//payby = "เงินสด     " + doString.displayNumber("###,##0.00", oldArr8) + " บาท";
								}						
								rs1.close();

								if (!tmpdate.equals("")) {
									tmpdate = tmpdate.substring(8) + "/" + tmpdate.substring(5, 7) + "/" + Integer.toString(Integer.parseInt(tmpdate.substring(0, 4))+543);  
								} // End if !tmpdate
								
								payby = setLabelThai(realPath,"โอนเงินผ่านธนาคารเป็นเงินสด จำนวนเงิน  ") + doString.displayNumber("###,##0.00", oldArr8) + setLabelThai(realPath," บาท วันที่ ")+ tmpdate;		
							} else {
								payby = setLabelThai(realPath,"เงินสด     ") + doString.displayNumber("###,##0.00", oldArr8) + setLabelThai(realPath," บาท");
							} // End if i_typ	
							
							//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
							if (!sendEmail) {
							//****************************************************************************************//							
							cb.setTextMatrix(75, line);
							cb.showText(payby);
							//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
							} // end if sendEmail	
							//****************************************************************************************//							
						} else if (oldArr0.equals("2")) {
								if (!wrtHD){
									wrtHD = true;
									//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
									if (!sendEmail) {
									//****************************************************************************************//									
									cb.moveTo(88, line-2);
								    cb.lineTo(163, line-2);
								    cb.setLineWidth(0.5f);
								    cb.stroke();
									cb.setTextMatrix(88, line);
									cb.showText(setLabelThai(realPath,"เช็คธนาคาร-สาขา"));
									cb.moveTo(318, line-2);
								    cb.lineTo(356, line-2);
								    cb.setLineWidth(0.5f);
								    cb.stroke();
									cb.setTextMatrix(318, line);
									cb.showText(setLabelThai(realPath,"เลขที่เช็ค"));
									cb.moveTo(418, line-2);
								    cb.lineTo(437, line-2);
								    cb.setLineWidth(0.5f);
								    cb.stroke();
									cb.setTextMatrix(417, line);
									cb.showText(setLabelThai(realPath,"วันที่"));
									cb.moveTo(519, line-2);
								    cb.lineTo(563, line-2);
								    cb.setLineWidth(0.5f);
								    cb.stroke();
									cb.setTextMatrix(518, line);
									cb.showText(setLabelThai(realPath,"จำนวนเงิน"));
									line -= 27;
									//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
									} // end if sendEmail	
									//****************************************************************************************//									
								}
								
								dtCHQ1 = ""; dtCHQ2 = ""; dtCHQ3 = ""; dtCHQ4 = "";
								sql.delete(0, sql.length());
								sql.append("select n_finance")
									.append(" from lan:acxfinan")
									.append(" where i_finance = '")
									.append(oldArr1)
									.append("' and i_branch is null");					
								//System.out.println("sql = "+sql.toString());
								rs1 = stmt1.executeQuery(sql.toString());
								
								if (rs1.next()) {
									dtCHQ1 = doString.DisplayThai(doString.checkString(rs1.getString("n_finance")));
								}						
								rs1.close();
		
								sql.delete(0, sql.length());
								sql.append("select n_finance")
									.append(" from lan:acxfinan")
									.append(" where i_finance = '")
									.append(oldArr1)
									.append("' and i_branch = '")									
									.append(oldArr2)
									.append("'");					
								//System.out.println("sql = "+sql.toString());
								rs1 = stmt1.executeQuery(sql.toString());
								
								if (rs1.next()) {
									dtCHQ1 += "-" + doString.DisplayThai(doString.checkString(rs1.getString("n_finance")));
								}						
								rs1.close();
		
								dtCHQ2 = oldArr9;
								tmpdate = oldArr10;
								if (!tmpdate.equals("")) {
									tmpdate = tmpdate.substring(8) + "/" + tmpdate.substring(5, 7) + "/" + Integer.toString(Integer.parseInt(tmpdate.substring(0, 4))+543);  
								} // End if !tmpdate								
								dtCHQ3 = tmpdate;
								dtCHQ4 = doString.displayNumber("###,##0.00", oldArr8);

								// LowLeftx, LowLefty,UpRightx, UpRighty
								//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
								if (!sendEmail) {
								//****************************************************************************************//								
								ct.setSimpleColumn(new Phrase(dtCHQ1, microssfont),	75, line, 289, line+19, 10, Element.ALIGN_LEFT);
								ct.go();				
								cb.endText();
								
								cb.setFontAndSize(bf, 16);
								cb.beginText();			
								ct.setSimpleColumn(new Phrase(dtCHQ2, microssfont),	290, line, 379, line+19, 10, Element.ALIGN_CENTER);
								ct.go();				
								cb.endText();
								
								cb.setFontAndSize(bf, 16);
								cb.beginText();			
								ct.setSimpleColumn(new Phrase(dtCHQ3, microssfont),	380, line, 469, line+19, 10, Element.ALIGN_CENTER);
								ct.go();				
								cb.endText();								

								cb.setFontAndSize(bf, 16);
								cb.beginText();			
								ct.setSimpleColumn(new Phrase(dtCHQ4, microssfont),	470, line, 570, line+19, 10, Element.ALIGN_RIGHT);
								ct.go();				
								cb.endText();
								
								cb.setFontAndSize(bf, 16);
								cb.beginText();	
								//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
								} // end if sendEmail	
								//****************************************************************************************//								
							//} // End if i_typ oldArr3.equals("T")	
						} // End if i_mtype
						line -= 19;

						oldArr8 = 0;
					} // End if chg
					chgArr = payArr[payRun][0]+payArr[payRun][10]+payArr[payRun][1]+payArr[payRun][2]+payArr[payRun][9];
					
					oldArr0 = payArr[payRun][0];
					oldArr1 = payArr[payRun][1];
					oldArr2 = payArr[payRun][2];
					oldArr3 = payArr[payRun][3];
					oldArr4 = payArr[payRun][4];
					oldArr5 = payArr[payRun][5];
					oldArr6 = payArr[payRun][6];
					oldArr7 = payArr[payRun][7];
					oldArr8 += Double.parseDouble(payArr[payRun][8]);
					oldArr9 = payArr[payRun][9];
					oldArr10 = payArr[payRun][10];							
				} // End for payRun
				
				if (j > 0) {
					payby = "";
					cardNo = "";
					if (oldArr0.equals("6")) {
						sql.delete(0, sql.length());
						sql.append("select i_cr_digit")
							.append(" from lan:acrcrdig")
							.append(" where i_bank = '")
							.append(oldArr1)
							.append("' and i_cr_code = '")
							.append(oldArr2)
							.append("'");					
						//System.out.println("sql = "+sql.toString());
						rs1 = stmt1.executeQuery(sql.toString());
						
						if (rs1.next()) {
							cardNo = doString.checkString(rs1.getString("i_cr_digit")) + oldArr9;
						}						
						rs1.close();
						
						sql.delete(0, sql.length());
						sql.append("select n_finance")
							.append(" from lan:acxfinan")
							.append(" where i_finance = '")
							.append(oldArr1)
							.append("' and i_branch is null");					
						//System.out.println("sql = "+sql.toString());
						rs1 = stmt1.executeQuery(sql.toString());
						
						if (rs1.next()) {
							payby = setLabelThai(realPath,"บัตรเครดิต ") + doString.DisplayThai(doString.checkString(rs1.getString("n_finance"))) + setLabelThai(realPath," เลขที่ ");
						}						
						rs1.close();
						
						if (!cardNo.equals("")) {
							payby += cardNo.substring(0, 4) + " " + cardNo.substring(4, 8) + " " + cardNo.substring(8, 12) + " " + cardNo.substring(12);
						}
						payby += setLabelThai(realPath," จำนวนเงิน ") + doString.displayNumber("###,##0.00", oldArr8) + setLabelThai(realPath," บาท");
						
						//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
						if (!sendEmail) {
						//****************************************************************************************//						
						cb.setTextMatrix(75, line);
						cb.showText(payby);
						//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
						} // end if sendEmail	
						//****************************************************************************************//						
					} else if (oldArr0.equals("4")) {
						payby = setLabelThai(realPath,"รับนอกสถานที่ ");
						//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
						if (!sendEmail) {
						//****************************************************************************************//						
						cb.setTextMatrix(75, line);
						cb.showText(payby);
						//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
						} // end if sendEmail	
						//****************************************************************************************//						
					} else if (oldArr0.equals("1")) {
						if (oldArr3.equals("T")) {						
							sql.delete(0, sql.length());
							sql.append("select i_sort")
								.append(" from lan:acrmisdt")
								.append(" where post_date = '")
								.append(oldArr4)
								.append("' and f_confirm = 'Y' and i_company = '")
								.append(oldArr5)
								.append("' and i_project = '")
								.append(oldArr6)
								.append("' and i_sort = '")
								.append(srt)
								.append("'");					
							//System.out.println("sql 7 = "+sql.toString());
							rs1 = stmt1.executeQuery(sql.toString());
							
							if (rs1.next()) {
								tmpdate = oldArr4;
								//if (!tmpdate.equals("")) {
								//	tmpdate = tmpdate.substring(8) + "/" + tmpdate.substring(5, 7) + "/" + Integer.toString(Integer.parseInt(tmpdate.substring(0, 4))+543);  
								//} // End if !tmpdate
								
								//payby = "โอนเงินผ่านธนาคาร วันที่ "+ tmpdate + "  " + doString.displayNumber("###,##0.00", oldArr8) + " บาท";
							} else {
								tmpdate = oldArr10;
								//payby = "เงินสด     " + doString.displayNumber("###,##0.00", oldArr8) + " บาท";
							}						
							rs1.close();

							if (!tmpdate.equals("")) {
								tmpdate = tmpdate.substring(8) + "/" + tmpdate.substring(5, 7) + "/" + Integer.toString(Integer.parseInt(tmpdate.substring(0, 4))+543);  
							} // End if !tmpdate
							
							payby = setLabelThai(realPath,"โอนเงินผ่านธนาคารเป็นเงินสด จำนวนเงิน  ") + doString.displayNumber("###,##0.00", oldArr8) + setLabelThai(realPath," บาท วันที่ ")+ tmpdate;		
						} else {
							payby = setLabelThai(realPath,"เงินสด     ") + doString.displayNumber("###,##0.00", oldArr8) + setLabelThai(realPath," บาท");
						} // End if i_typ	
						
						//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
						if (!sendEmail) {
						//****************************************************************************************//						
						cb.setTextMatrix(75, line);
						cb.showText(payby);
						//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
						} // end if sendEmail	
						//****************************************************************************************//						
					} else if (oldArr0.equals("2")) {
							if (!wrtHD){
								wrtHD = true;
								//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
								if (!sendEmail) {
								//****************************************************************************************//								
								cb.moveTo(88, line-2);
							    cb.lineTo(163, line-2);
							    cb.setLineWidth(0.5f);
							    cb.stroke();
								cb.setTextMatrix(88, line);
								cb.showText(setLabelThai(realPath,"เช็คธนาคาร-สาขา"));
								cb.moveTo(318, line-2);
							    cb.lineTo(356, line-2);
							    cb.setLineWidth(0.5f);
							    cb.stroke();
								cb.setTextMatrix(318, line);
								cb.showText(setLabelThai(realPath,"เลขที่เช็ค"));
								cb.moveTo(418, line-2);
							    cb.lineTo(437, line-2);
							    cb.setLineWidth(0.5f);
							    cb.stroke();
								cb.setTextMatrix(417, line);
								cb.showText(setLabelThai(realPath,"วันที่"));
								cb.moveTo(519, line-2);
							    cb.lineTo(563, line-2);
							    cb.setLineWidth(0.5f);
							    cb.stroke();
								cb.setTextMatrix(518, line);
								cb.showText(setLabelThai(realPath,"จำนวนเงิน"));
								line -= 27;
								//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
								} // end if sendEmail	
								//****************************************************************************************//								
							}
							
							dtCHQ1 = ""; dtCHQ2 = ""; dtCHQ3 = ""; dtCHQ4 = "";
							sql.delete(0, sql.length());
							sql.append("select n_finance")
								.append(" from lan:acxfinan")
								.append(" where i_finance = '")
								.append(oldArr1)
								.append("' and i_branch is null");					
							//System.out.println("sql = "+sql.toString());
							rs1 = stmt1.executeQuery(sql.toString());
							
							if (rs1.next()) {
								dtCHQ1 = doString.DisplayThai(doString.checkString(rs1.getString("n_finance")));
							}						
							rs1.close();
	
							sql.delete(0, sql.length());
							sql.append("select n_finance")
								.append(" from lan:acxfinan")
								.append(" where i_finance = '")
								.append(oldArr1)
								.append("' and i_branch = '")									
								.append(oldArr2)
								.append("'");					
							//System.out.println("sql = "+sql.toString());
							rs1 = stmt1.executeQuery(sql.toString());
							
							if (rs1.next()) {
								dtCHQ1 += "-" + doString.DisplayThai(doString.checkString(rs1.getString("n_finance")));
							}						
							rs1.close();
	
							dtCHQ2 = oldArr9;
							tmpdate = oldArr10;
							if (!tmpdate.equals("")) {
								tmpdate = tmpdate.substring(8) + "/" + tmpdate.substring(5, 7) + "/" + Integer.toString(Integer.parseInt(tmpdate.substring(0, 4))+543);  
							} // End if !tmpdate								
							dtCHQ3 = tmpdate;
							dtCHQ4 = doString.displayNumber("###,##0.00", oldArr8);

							// LowLeftx, LowLefty,UpRightx, UpRighty
							//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
							if (!sendEmail) {
							//****************************************************************************************//							
							ct.setSimpleColumn(new Phrase(dtCHQ1, microssfont),	75, line, 289, line+19, 10, Element.ALIGN_LEFT);
							ct.go();				
							cb.endText();
							
							cb.setFontAndSize(bf, 16);
							cb.beginText();			
							ct.setSimpleColumn(new Phrase(dtCHQ2, microssfont),	290, line, 379, line+19, 10, Element.ALIGN_CENTER);
							ct.go();				
							cb.endText();
							
							cb.setFontAndSize(bf, 16);
							cb.beginText();			
							ct.setSimpleColumn(new Phrase(dtCHQ3, microssfont),	380, line, 469, line+19, 10, Element.ALIGN_CENTER);
							ct.go();				
							cb.endText();								

							cb.setFontAndSize(bf, 16);
							cb.beginText();			
							ct.setSimpleColumn(new Phrase(dtCHQ4, microssfont),	470, line, 570, line+19, 10, Element.ALIGN_RIGHT);
							ct.go();				
							cb.endText();
							
							cb.setFontAndSize(bf, 16);
							cb.beginText();	
							//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
							} // end if sendEmail	
							//****************************************************************************************//							
						//} // End if i_typ oldArr3.equals("T")	
					} // End if i_mtype
					line -= 19;

					oldArr8 = 0;
				} // end if j > 0
				
				//acm1 = "X5, 150" + acm1;

				//System.out.println(">> 2 acm1 = "+acm1+"; acm2 = "+acm2);
				//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
				if (!sendEmail) {
				//****************************************************************************************//				
				if (!acm1.equals("")) {
					cb.setTextMatrix(5, 150);
					cb.showText(acm1);
				}
				//acm2 = "X5, 131" + acm2;
				if (!acm2.equals("")) {
					cb.setTextMatrix(5, 131);
					cb.showText(acm2);
				}

				receiver = "";
				sql.delete(0, sql.length());
				sql.append("select n_person")
					.append(" from lan:acxpersn")
					.append(" where i_position = '5' and i_person = '")
					.append(tmprcv)
					.append("'");					
				rs1 = stmt1.executeQuery(sql.toString());
				
				if (rs1.next()) {
					receiver = doString.DisplayThai(doString.checkString(rs1.getString("n_person")));
				}						
				rs1.close();
				
				cb.setTextMatrix(52, 75);//45 65
				cb.showText(receiver);
				//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
				} // end if sendEmail	
				//****************************************************************************************//

				ps = "";
				if (flagRePrint.equals("R")) {
					ps = setLabelThai(realPath,"(ใบเสร็จรับเงินฉบับนี้ใช้แทนต้นฉบับเดิม)");
				} else if (flagRePrint.equals("N")) {							
					sql.delete(0, sql.length());
					sql.append("update lan:acrrecpt set f_receipt = 'Y'")
						.append(" where i_company = '")
						.append(oldcomp)
						.append("' and i_receipt = '")
						.append(oldIRecpt)
						.append("'");
					stmt1.executeUpdate(sql.toString());
					
					if (chkvat > 0 && !taxINV.equals("")) {
						//---- 2024-03-05 , get d_receipt for lan:acrtaxinv ----//
						String dReceipt = "";
						sql.delete(0, sql.length());
						sql.append(" select d_receipt from  lan:acrrecpt ")
						   .append(" where i_company='"+oldcomp+"' and i_receipt='"+oldIRecpt+"' ");					
						rs1 = stmt1.executeQuery(sql.toString());
						if (rs1.next()) {
							dReceipt = doString.checkString(rs1.getString("d_receipt"),"").trim();
						}						
						rs1.close();
						//-------------------------------------------------------//
						
						sql.delete(0, sql.length());
						sql.append("insert into lan:acrtaxinv (i_com_recv, i_receipt,")
							.append(" i_tax_inv, d_tax_inv, f_print, d_print) values ('")
							.append(oldcomp)
							.append("', '")
							.append(oldIRecpt)
							.append("', '")
							.append(taxINV)
							.append("', "+(dReceipt.length()>=10 ? "'"+dReceipt+"'" : "TODAY")+", ") // 2024-03-05 , change TODAY to d_receipt
							.append(" NULL, NULL)");
						stmt1.executeUpdate(sql.toString());
					}
				} else if (flagRePrint.equals("T")) {
					sql.delete(0, sql.length());
					sql.append("update lan:acrtaxinv set f_print = 'Y', d_print = TODAY")
						.append(" where i_com_recv = '")
						.append(oldcomp)
						.append("' and i_receipt = '")
						.append(oldIRecpt)
						.append("' and i_tax_inv = '")
						.append(taxINV)
						.append("'");
					stmt1.executeUpdate(sql.toString());						
				} // End flagRePrint = 'N'
				
				//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
				if (!sendEmail) {
				//****************************************************************************************//
				if (!ps.equals("")) {
					cb.setTextMatrix(20, 28);//5, 13
					cb.showText(ps);
				}
				
				//---- 2019-02-10 , add user print ----//
				Calendar now = Calendar.getInstance(TimeZone.getTimeZone("Asia/Bangkok"));
				doString str = new doString();
				int y = now.get(Calendar.YEAR);
				if (y<2400) y += 543;
				String today = str.createID(now.get(Calendar.DATE),2)+"/"+str.createID(now.get(Calendar.MONTH)+1,2)+"/"+y;
				today += " , "+str.createID(now.get(Calendar.HOUR_OF_DAY),2)+":"+str.createID(now.get(Calendar.MINUTE),2)+"."+str.createID(now.get(Calendar.SECOND),2);
			   
				cb.setFontAndSize(bf, 8);
				cb.setTextMatrix(25, 40);
				cb.showText("("+empId+")  "+today);
				
				
				//---- add summary amount before print on receipt ----//
				rawForEncode += "#"+shw_sumnet;
				cb.endText();
				cb.setFontAndSize(bf, 16);
				cb.beginText();					
				ct.setSimpleColumn(new Phrase(encodeVerified(rawForEncode), fontWhite), 20, 6, 565, 25, 10, Element.ALIGN_CENTER);
				ct.go();							
				cb.endText();
				cb.setFontAndSize(bfb, 20);
				cb.beginText();
				
				//****************** 2016-07-13  Roj , if receipt send by email , no print ***************//	
				} // end if sendEmail	
				//****************************************************************************************//				
			} // End if i >= 1		
			
			cb.endText();
			
			// we close the document (the outputstream is also closed internally)
			document.close();			
			//**************************************** copy code from RecptPrint4LaserServlet *************************************************//
			//*********************************************************************************************************************************//
			
		} catch (DocumentException de) {
			 de.printStackTrace();
			 System.err.println("ERROR " + cName + " DOCUMENT: " + de.getMessage());		
		} catch (Exception e) {
			System.out.println(cName + " SQL : " + sql.toString());
			System.out.println(cName + " ERR : " + e.getMessage());			
			e.printStackTrace();
		} finally {
			try {
				if (rs != null)
					rs.close();
				if (rs1 != null)
					rs1.close();
				if (urs != null)
					urs.close();
				if (stmt != null)
					stmt.close();
				if (stmt1 != null)
					stmt1.close();
				if (ustmt != null)
					ustmt.close();
			} catch (SQLException ignore) {
			}
		} // End finally
		
		
		return document;
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
		
		String recvCom = doString.checkString(req.getParameter("recvCom"));
		String iReceipt = doString.checkString(req.getParameter("i_receipt"),"");
		String empId = doString.checkString(req.getParameter("empId"));
		String printCopy = doString.checkString(req.getParameter("print_copy"),"");
		Connection conn = null;
		Statement stmt = null;
		StringBuffer sql = new StringBuffer();
		

		 try {
			if (ds == null)
				getDS();

			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
	
			
			//----========== create pdf =========----//
			String realPath = getServletContext().getRealPath("/");
			Document document = new Document(PageSize.A4, 0, 0, 0, 0);
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			PdfWriter writer = PdfWriter.getInstance(document, baos);
			PdfContentByte cb = writer.getDirectContent();
			
			//---- add file description -----//
	        document.addAuthor("Land & Houses Public Company Limited.");
	        document.addCreator("Land & Houses Public Company Limited.");			
			document.open();
			
			PdfReader reader = new PdfReader(realPath+File.separator+"template"+File.separator+(printCopy.equalsIgnoreCase("Y") ? "blank_receipt_copy.pdf" : "blank_receipt.pdf"));
			cb.addTemplate(writer.getImportedPage(reader, 1), 1, 1);			
			document = genReceipt(conn, document, cb, realPath, recvCom, iReceipt, empId);
			
			
			//--- update last date/time for print receipt ---//			
			sql.delete(0,sql.length());
			sql.append(" update lan:log_recpt set i_reten='"+empId+"' , d_reten=current ")
			   .append(" where i_com_recv='"+recvCom+"' and i_receipt='"+iReceipt+"' ");			
			stmt.executeUpdate(sql.toString());
			
			
			//--- find data and insert transaction log ---//
			String iCom = "";
			String iProj = "";
			String iLor = "";
			String iSort = "";
			String dReceipt = "";
			sql.delete(0,sql.length());
			sql.append(" select * from lan:log_recpt ")
			   .append(" where i_com_recv='"+recvCom+"' and i_receipt='"+iReceipt+"' ");	
			ResultSet rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
				iCom = doString.checkString(rs.getString("i_company"),"");
				iProj = doString.checkString(rs.getString("i_project"),"");
				iLor = doString.checkString(rs.getString("i_lor"),"");
				iSort = doString.checkString(rs.getString("i_sort"),"");
				dReceipt = doString.checkString(rs.getString("d_receipt"),"");
			}
			rs.close();
			
			if (iCom.length()>0 && iProj.length()>0 && iLor.length()>0) {
				sql.delete(0,sql.length());
				sql.append(" insert into lan:log_retenrcpt ( ")
				   .append(" i_company, 	i_project, 		i_lor,	 	i_sort, ")
				   .append(" i_receipt, 	d_receipt, 		i_reten, 	d_reten ")
				   .append(" ) values ( ")
				   .append(" '"+iCom+"','"+iProj+"','"+iLor+"','"+iSort+"', ")
				   .append(" '"+iReceipt+"','"+dReceipt+"','"+empId+"',current) ");
				stmt.executeUpdate(sql.toString());
			}
			

			//----=========== Generate PDF ===============-----//
			document.close();
			res.setContentType("application/pdf");
			res.setContentLength(baos.size());
			ServletOutputStream outServ = res.getOutputStream();
			baos.writeTo(outServ);
			outServ.flush();
			
			
			stmt.close();
			conn.commit();
			//conn.rollback();
			conn.close();
			stmt = null;
			conn = null;
			
		 } catch (DocumentException de) {
			 de.printStackTrace();
			 System.err.println("error SERV_PrintReceiptServlet  DOCUMENT: " + de.getMessage());
		} catch (Exception e) {
			System.out.println(" ERROR "+mName+" : " + e.getMessage());
			//System.out.println(" ERROR "+mName+" SQL : " + sql.toString());			
		} finally {
			try {
				if (stmt != null) stmt.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");

	}

}
