package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*; 
import java.text.*;

import javax.naming.NamingException;
import javax.servlet.*;
import javax.servlet.http.*;

import com.itextpdf.text.pdf.BarcodeQRCode;
import com.lh.servlet.DBServlet;
import com.lh.util.*;
import com.lh.exception.InvalidParameterException;

import java.awt.Color;
import com.lowagie.text.*;
import com.lowagie.text.pdf.Barcode128;
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


/**
 * @version 	1.0
 * @author
 */
public class SERV_PrintPayInCBServlet extends DBServlet  {
	
  public static int custCopyPosition = 349;
  public static int bankCopyPosition = 94;
  public static BaseFont bf = null;
  public static BaseFont bfb = null;
	  

  /************************************************************************************************************/
  public com.lowagie.text.Image genQrCode(String code) throws Exception {
      BarcodeQRCode qrcode = new BarcodeQRCode(code,1,1,null);
      java.awt.Image qrcodeImage = qrcode.createAwtImage(new Color(0,0,0),new Color(255,255,255));
      
	  return com.lowagie.text.Image.getInstance(qrcodeImage, null);
  }	
  
  private String getCompanyRef(String comId) {
		String refNo = "";
		
		if (comId.equals("LH")) {
			refNo = "1";
		} else if (comId.equals("AP")) {
			refNo = "2";
		} else if (comId.equals("PF")) {
			refNo = "3";
		} else if (comId.equals("AR")) {
			refNo = "4";
		} else if (comId.equals("LE")) {
			refNo = "1";
		} else if (comId.equals("LK")) {
			refNo = "2";
		} else if (comId.equals("SI")) {
			refNo = "5";
		} else if (comId.equals("NE")) {
			refNo = "6";
		} else if (comId.equals("LT")) {
			refNo = "7";
		} else if (comId.equals("LA")) {
			refNo = "8";						
		} else if (comId.equals("SA")) {
			refNo = "9";
		}
		
		return refNo;
	}
  
  	private int getPos(double amount) {
		int pos = 0;
		
		String number = doString.displayNumber("#,###,###,###.00", amount);
		int len = number.length();
		if (len>=6 && len<8) pos = 185;
		if (len>=8 && len<9) pos = 179;
		if (len>=9 && len<10) pos = 174;
		if (len>=10 && len<12) pos = 169;
		if (len==12) pos = 163;
		if (len>12) pos = 159;

		return pos;
	}  

	private String getLockRef(String lockId) {
		String refNo = "";
		char c = lockId.charAt(0);
		int i = Character.getNumericValue(c)-9;
		if (i<10) refNo = "0";
		refNo += Integer.toString(i);
		
		return refNo;
	}

	private String getAmount(String amount) {
		int idx = amount.indexOf(".");
		String number = "";
		String fraction = "";
		if (idx != -1) {
			number = amount.substring(0,idx);
			fraction = amount.substring(idx+1);
		}
		return(number+fraction);
	}	
   /************************************************************************************************************/

   
  /************************************************************************************************************/
  public void printHeader(PdfContentByte cb,String nCompany,String eCompany,String address1,String address2,String provCode,String taxId,String tel,String fax,String custName,String nProject,String iLock,String contTel1,String contTel2) {
	//---- company details ----//
	cb.setFontAndSize(bfb, 14); // font
	cb.setTextMatrix(36, 816);
	cb.showText(doString.MS874ToUnicode(nCompany));						
	cb.setTextMatrix(36, 802);
	cb.showText(doString.MS874ToUnicode(eCompany));						

	cb.setFontAndSize(bf, 8); // font
	cb.setTextMatrix(36, 790);
	cb.showText(doString.MS874ToUnicode(address1+" "+address2));						

	cb.setTextMatrix(36, 780);
	if (provCode.equals("BKK")) {
		cb.showText("โทร."+doString.MS874ToUnicode(tel)+" แฟกซ์ : "+doString.MS874ToUnicode(fax));
		cb.setTextMatrix(36, 770); // set new tax id position	
	}	
	cb.showText("เลขประจำตัวผู้เสียภาษีอากร "+doString.MS874ToUnicode(taxId));
	
	cb.setFontAndSize(bf, 12); // font
	cb.setTextMatrix(475, 697);
	//cb.showText(doString.MS874ToUnicode(contTel1));
	cb.showText(""); // 2019-02-06 , remove tel
	cb.setTextMatrix(412, 667);
	cb.showText(doString.MS874ToUnicode(contTel2));
	
	//--- customer details ---//
	cb.setFontAndSize(bf, 12); // font			
	cb.setTextMatrix(80, 758);
	cb.showText(doString.MS874ToUnicode(custName));						
	cb.setTextMatrix(80, 743);
	cb.showText(doString.MS874ToUnicode(nProject));
	cb.setTextMatrix(80, 727);
	cb.showText(iLock);
  }
  
  
  public void printDetails(int startPosition,PdfContentByte cb,String lockCode,String nCompany,String eCompany,String custName,String LHBCode,String SCBCode,String KBankCode,String billerId,String refNo1,String refNo2,String refNo,double amount) {
	cb.setFontAndSize(bfb, 13);
	cb.setTextMatrix(36,startPosition+154);
	cb.showText(doString.MS874ToUnicode(nCompany));	
	cb.setTextMatrix(36,startPosition+140);
	cb.showText(eCompany);							
			
	cb.setFontAndSize(bf, 12);							
	cb.setTextMatrix(360,startPosition+125);
	cb.showText(doString.MS874ToUnicode(custName));				
	cb.setTextMatrix(410,startPosition+110);
	cb.showText(refNo1);
	cb.setTextMatrix(378,startPosition+96);
	cb.showText(refNo);

	//---- print Comp. Code & Biller Id Bank -----//
	if (LHBCode.trim().length()>0) {
		cb.setTextMatrix(188,startPosition+125);
		cb.showText(LHBCode);		
	} else {
	    Rectangle rect = new Rectangle(35,startPosition+133, 190,startPosition+123);
	    rect.setBorder(Rectangle.BOX);
	    rect.setBackgroundColor(new Color(255,255,255));
	    cb.rectangle(rect);	
	}
	
	if (KBankCode.trim().length()>0) {
		cb.setTextMatrix(171,startPosition+96);
		cb.showText(KBankCode);	  	
	} else {
	    Rectangle rect = new Rectangle(35,startPosition+105, 190,startPosition+95);
	    rect.setBorder(Rectangle.BOX);
	    rect.setBackgroundColor(new Color(255,255,255));
	    cb.rectangle(rect);	
	}
	
	cb.setTextMatrix(151,startPosition+110);
	cb.showText(SCBCode);				
	cb.setTextMatrix(196,startPosition+83);
	cb.showText(billerId);
	
	cb.setFontAndSize(bf, 10);
	cb.setTextMatrix(218,startPosition+110);
	cb.showText("(ชำระผ่านช่องทางดิจิทัลแบงค์กิ้ง/ATM)");		
	//---------------------------------------------//
		
	cb.setFontAndSize(bf, 13);
	cb.setTextMatrix(130,startPosition+19);
	cb.showText(doString.MS874ToUnicode((new CurrencyToThai(amount)).getString()));
	cb.setTextMatrix(410,startPosition+20);
	cb.showText(doString.displayNumber("#,###,###,###.00",amount));	

	cb.setFontAndSize(bfb, 13);
	cb.setTextMatrix(37,startPosition+4);	
	cb.showText(doString.MS874ToUnicode(lockCode));
	
  }
  
  public void printMemo(PdfContentByte cb,String iCompany,String iProject,String iLock,String iDocNo,String nProject,String iHouse,String custName,String desc,String empName) {
	cb.setFontAndSize(bf, 14);
	// PROJECT
	cb.setTextMatrix(158, 765);
	cb.showText(doString.MS874ToUnicode(nProject));
	
	cb.setTextMatrix(148, 747);
	cb.showText(iLock);						

	cb.setTextMatrix(358, 747);
	cb.showText(iCompany+iProject+"-"+iDocNo);

	cb.setTextMatrix(162, 729);
	cb.showText(iHouse);												
	
	cb.setTextMatrix(348, 729);
	cb.showText(doString.MS874ToUnicode(custName));		
								
	//cb.setFontAndSize(angsaub, 14);
	cb.setTextMatrix(72, 514);
	cb.showText(desc);		
																	
	cb.setFontAndSize(bf, 13);
	cb.setTextMatrix(64, 36);
	cb.showText(doString.MS874ToUnicode(custName));
	cb.setTextMatrix(344, 36);
	cb.showText(doString.MS874ToUnicode(empName));		  
  }
  /************************************************************************************************************/ 

  
	
  /************************************************************************************************************/
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
	
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	StringBuffer sql = new StringBuffer();
	doString str = new doString();
	
	String docNo = doString.checkString(req.getParameter("docNo"),"");
	String selProject = doString.checkString(req.getParameter("sel_project"),"");
	String iCompany = selProject.length()>=6 ? selProject.substring(0,2) : "";
	String iProject = selProject.length()>=6 ? selProject.substring(3,6) : "";
	String docType = doString.checkString(req.getParameter("docType"),"A"); // default 'A'
	String empId = doString.checkString(req.getParameter("empId"),"");
	String userId = doString.checkString(req.getParameter("userId"),"");
	String empName = "";		

    String iLor = "";
    String iLock = "";
    String iHouse = "";
    String iHouseType = "";
    String retenType = "";
    String iCust = "";
    double amount = 0.0;
    String payInNo =  "";
    String desc = "";
    
    String contTel1 = "";
    String contTel2 = "";
    String custName = "";
    String nCompany = "";
    String eCompany = "";
    String nProject = "";
    String taxId = "";
    String vatId = "";
    String tel = "";
    String fax = "";
    String address1 = "";
    String address2 = "";
    String compCode = "";
    String LHBCode = "";
    String SCBCode = "";
    String KBankCode = "";
	String billerId = "";
	
	String provCode = "BKK";
	String suffix = "00"; 
	String lockCode = "";
    
	String refNo1 = "";
	String refNo2 = "";
	String refNo = "";
	char BR = (char)13;
    
    
    int currYear = (Calendar.getInstance()).get(Calendar.YEAR);
    if(currYear<2400) currYear += 543;
	
	
	try {
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(false);
		stmt = conn.createStatement();
		
		
		//-------- Start Generate PDF File --------//	
		String realPath = getServletContext().getRealPath("/");
		String fontPath = getServletContext().getRealPath("/Fonts");
        bf = BaseFont.createFont(fontPath+File.separator+"ANGSAU.TTF", BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
        bfb = BaseFont.createFont(fontPath+File.separator+"ANGSAUB.TTF", BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);         
		
		Document document = new Document(PageSize.A4, 20, 20, 20, 20);
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		PdfWriter writer = PdfWriter.getInstance(document, baos);
		PdfContentByte cb = writer.getDirectContent();
		document.open();
		
		//---- import template ----//
		PdfReader reader = new PdfReader(realPath+File.separator+"form_cb_service.pdf");
		
		
		//-------- find details ---------//
		rs = stmt.executeQuery(" select * from docflow:acemploy where i_employ = '"+empId+"' ");
		if (rs.next()) {
			empName  = doString.checkString(rs.getString("n_prename_th"),"").trim();
			empName += doString.checkString(rs.getString("n_nemploy_th"),"").trim();
			empName += " "+doString.checkString(rs.getString("n_semploy_th"),"").trim();					
		}
		rs.close();		
		
		
		sql.delete(0,sql.length());
		sql.append(" select h.i_sort, h.i_house, h.i_lor, h.n_custo, h.i_ret_custo, h.i_reten, nvl(h.z_reten,0) as reten_amt, ")
		   .append(" nvl(h.z_recv_reten,0) as recv_amt, nvl(h.s_payin,0) as payin_no ")
		   .append(" from lan:serv_rethd h ")
		   .append(" where h.i_company='"+iCompany+"' and h.i_project='"+iProject+"' ")
		   .append(" and h.i_docno='"+docNo+"' "); 		
		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
			iLor = Integer.toString(rs.getInt("i_lor"));
			iLock = doString.checkString(rs.getString("i_sort"));
			iHouse = doString.checkString(rs.getString("i_house"));
			retenType = doString.checkString(rs.getString("i_ret_custo"));
			iCust = doString.checkString(rs.getString("i_reten"));
			//amount = rs.getDouble("reten_amt")-rs.getDouble("recv_amt");
			amount = rs.getDouble("reten_amt");				
			payInNo = Integer.toString(rs.getInt("payin_no")+1);
		}
		rs.close();
		
		
		sql.delete(0,sql.length());
		sql.append(" select i_house_type from lan:acscontr ")
		   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")	
		   .append(" and i_lor='"+iLor+"' "); 	
		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
			iHouseType = doString.checkString(rs.getString("i_house_type"),"");
		}
		rs.close();
		if (iHouseType.equals("1") || iHouseType.equals("2") || iHouseType.equals("6") || iHouseType.equals("7") || iHouseType.equals("8")) {
			desc="กรณีการต่อเติมอาคาร(บ้านเดี่ยว) จำนวนเงินวางค้ำประกัน "+doString.displayNumber("###,###,##0.00",amount)+" บาท";
		}
		if (iHouseType.equals("3")) {
			desc="กรณีการต่อเติมอาคาร(ทาสน์เฮ้าส์) จำนวนเงินวางค้ำประกัน"+doString.displayNumber("###,###,##0.00",amount)+" บาท";
		}
		if (iHouseType.equals("5")) {
			desc="กรณีก่อสร้างอาคาร จำนวนเงินวางค้ำประกัน"+doString.displayNumber("###,###,##0.00",amount)+" บาท";
		}			
		
		//------------- insert serv_payin ----------------//
		if (payInNo.equals("1")) {
			sql.delete(0,sql.length());
			sql.append(" insert into lan:serv_payin ( ")
			   .append(" i_docno, 		i_company, 		i_project, 	i_sort, ")
			   .append(" i_lor, 		s_payin, 		i_due, 		z_payin, ")
			   .append(" d_frst_payin, 	i_frst_payin, 	s_receive ")
			   .append(" ) values ( ")
			   .append(" '"+docNo+"','"+iCompany+"','"+iProject+"','"+iLock+"', ")
			   .append(" '"+iLor+"','"+payInNo+"','O5', ")
			   .append(" '"+doString.displayNumber("#########.00", amount)+"', ")
			   .append(" today, '"+empId+"', 0) ");
			stmt.executeUpdate(sql.toString());	
			
			sql.delete(0,sql.length());
			sql.append(" update lan:serv_rethd set ")
			   .append(" d_prn_payin=today, i_doc_status='Y', s_payin = 1,i_prn_payin='"+empId+"' ")
			   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
			   .append(" and i_docno='"+docNo+"' ");
			stmt.executeUpdate(sql.toString());
		} else {
			payInNo = "1";
		}
	
		docNo = docNo.substring(6);
		
		if (retenType.equals("1")) {
			//--- normal customer ---//
			sql.delete(0,sql.length());
			sql.append(" select * from lan:acxcusto where i_customer='"+iCust+"' ");		
			rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
				custName  = doString.checkString(rs.getString("n_prename"),"");
				custName += doString.checkString(rs.getString("n_ncustomer"),"");
				custName += " "+doString.checkString(rs.getString("n_scustomer"),"");
			} 
			rs.close();			
		} else {
			//--- vendor ---//
			if (retenType.equals("2")) {
				retenType = "05";
			} else {
				retenType = "06";
			}
			
			sql.delete(0,sql.length());
			sql.append(" select n_pname, n_name, n_sname from lan:serv_venprj ")
			   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")	
			   .append(" and i_type='"+retenType+"' and i_vendor = '"+iCust+"' "); 		
			rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
				custName  = doString.checkString(rs.getString("n_pname"),"");
				custName += doString.checkString(rs.getString("n_name"),"");
				custName += " "+doString.checkString(rs.getString("n_sname"),"");
			} 
			rs.close();	
		}		
				
		sql.delete(0,sql.length());
		sql.append(" select * from lan:acxcompa where i_company='"+iCompany+"' ");
		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
			nCompany = doString.checkString(rs.getString("n_company"));
			taxId = doString.checkString(rs.getString("tax_id"));				
			vatId = doString.checkString(rs.getString("vat_id"));
			taxId = vatId;
			address1 = doString.checkString(rs.getString("a_company"));
			address1 = "เลขทะเบียนที่ "+vatId+" "+address1;
			address2 = doString.checkString(rs.getString("addr2"))+" "+doString.checkString(rs.getString("addr3"));
		}
		rs.close();	
		
		sql.delete(0,sql.length());
		sql.append(" select * from lan:acxecompa where i_company='"+iCompany+"' ");
		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
			eCompany = doString.checkString(rs.getString("n_company"));
			tel = doString.checkString(rs.getString("i_tel"));				
			fax = doString.checkString(rs.getString("i_fax"));
		}
		rs.close();		
		
		sql.delete(0,sql.length());
		sql.append(" select p.n_project,c.i_prov from lan:acxprojt p ")
		   .append(" left join lan:pay_prjprov c on c.i_company=p.i_company and c.i_project=p.i_project ")
		   .append(" where p.i_company='"+iCompany+"' and p.i_project='"+iProject+"' ");
		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
			nProject = doString.checkString(rs.getString("n_project"),"");
			provCode = doString.checkString(rs.getString("i_prov"),"BKK");
		}
		rs.close();
				   
		
		suffix = "00";  
	    if (provCode.equals("CM")) {
	    	suffix = "02";        	
	    } else if (provCode.equals("KK")) {
	    	suffix = "01";
		} else if (provCode.equals("KR")) {
			suffix = "03";
		} else if (provCode.equals("UD")) {
			suffix = "04";
		} else if (provCode.equals("CR")) {
			suffix = "05";
		} else if (provCode.equals("MS")) {
			suffix = "06";			
		} 
		

		//---- find comp. code ----//
		sql.delete(0,sql.length());
		sql.append(" select comp_code,i_account,i_bank,biller_id from lan:payaccnt ")
		   .append(" where i_company='"+iCompany+"' and i_prov='"+provCode+"' ");
		rs = stmt.executeQuery(sql.toString());
		while (rs.next()) {
			compCode = doString.checkString(rs.getString("comp_code"));
			billerId = doString.checkString(rs.getString("biller_id"),"");
			
			if (doString.checkString(rs.getString("i_bank"),"").equals("LHB")) {
				LHBCode = "(Comp. Code " + compCode + ")";
			} else if (doString.checkString(rs.getString("i_bank"),"").equals("SCB")) {
				if (compCode.trim().length()>0) {
					SCBCode = "(Comp. Code " + compCode + ")";
				} else {
					SCBCode = doString.checkString(rs.getString("i_account"),"");					
				}
			} else if (doString.checkString(rs.getString("i_bank"),"").equals("TFB")) {
				/*KBankCode = doString.checkString(rs.getString("i_account"),"");
				if (compCode.trim().length()>0) KBankCode += ", (Comp. Code " + compCode + ")";*/
				if (compCode.trim().length()>0) KBankCode = "(Comp. Code " + compCode + ")";
			}
		} // end while
		rs.close();	
		
		
		sql.delete(0,sql.length());
		sql.append(" select i_telno,i_telno2 from lan:paytelno ")
		   .append(" where i_company='"+iCompany+"' and i_province='"+provCode+"' and i_type = 'R' ");
		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
			contTel1 = doString.MS874ToUnicode(doString.checkString(rs.getString("i_telno")));
			contTel2 = doString.MS874ToUnicode(doString.checkString(rs.getString("i_telno2")));			
		}
		rs.close();	
		
		lockCode = iCompany+"-"+iProject+"-"+iLock+" ("+nProject+")";

		
		//------------------- print payin ----------------------//
		if (docType.equalsIgnoreCase("A") || docType.equalsIgnoreCase("P")) {
			refNo1 = iLock.substring(0,2)+getLockRef(iLock.substring(2, 3))+iLock.substring(3)+getLockRef("O")+"5";	
			refNo2 = "0"+getCompanyRef(iCompany)+iProject+docNo+payInNo+"0"+iCust;
			refNo = "0-"+getCompanyRef(iCompany)+iProject+"-"+docNo+payInNo+"-0"+iCust;

					
			//---- start print ----//
			cb.addTemplate(writer.getImportedPage(reader, 1), 1, 1);					
			cb.beginText();			
			
			printHeader(cb,nCompany,eCompany,address1,address2,provCode,taxId,tel,fax,custName,nProject,iLock,contTel1,contTel2);
			printDetails(custCopyPosition,cb,lockCode,nCompany,eCompany,custName,LHBCode,SCBCode,KBankCode,billerId,refNo1,refNo2,refNo,amount); // customer copy
			printDetails(bankCopyPosition,cb,lockCode,nCompany,eCompany,custName,LHBCode,SCBCode,KBankCode,billerId,refNo1,refNo2,refNo,amount); // bank copy
			cb.endText();
		
			//----- generate and print barcode -----//
			String barcode = "|"+taxId+suffix+BR+refNo1+BR+refNo2+BR+getAmount(doString.displayNumber("##########.00", amount));
		    Barcode128 code128 = new Barcode128();
		    code128.setTextAlignment(Element.ALIGN_LEFT);
		    code128.setBarHeight(40);        
		    code128.setCode(barcode);
			Image image128 = code128.createImageWithBarcode(cb, null, null);
			image128.scalePercent(60,60);
			image128.setAbsolutePosition(40, 36);
			document.add(image128);
			
			//---- QR Code ----//
			Image qrImage = genQrCode(barcode);
			if (barcode.length()>50) {
				//--- scale down qr code ---//
				qrImage.scalePercent(150,150);
			} else {
				qrImage.scalePercent(158,158);
			}
			qrImage.setAbsolutePosition(500, 10);
			//--> 20190507 , qrImage.scalePercent(148,148);
			//--> 20190507 , qrImage.setAbsolutePosition(500, 10);		
			/*if (amount>9999999) {
				//--- scale down qr code if amount >= 10,000,000.00 ---//
				qrImage.scalePercent(148,148);
				qrImage.setAbsolutePosition(500, 10);		
			} else {
				qrImage.scalePercent(160,160);
				qrImage.setAbsolutePosition(500, 12);
			}*/
			document.add(qrImage);			
		
			document.newPage();					
		} // end if check payin
		//------------------------------------------------------//

		
		
		//------------------- print memo -----------------------//
		if (docType.equalsIgnoreCase("A") || docType.equalsIgnoreCase("R")) {
			//---- start print ----//
			reader = new PdfReader(realPath + "/frmReten.pdf");
			cb.addTemplate(writer.getImportedPage(reader, 1), 1, 1);				
			cb.beginText();			
			printMemo(cb,iCompany,iProject,iLock,docNo,nProject,iHouse,custName,desc,empName);					
			cb.endText();
			document.newPage();	
		}
		//------------------------------------------------------//
		

	    
	    
		//----=========== Generate PDF ===============-----//	  	
		document.close();
		res.setContentType("application/pdf");
		res.setContentLength(baos.size());
		ServletOutputStream outServ = res.getOutputStream();
		baos.writeTo(outServ);
		outServ.flush();
		
		
		
		stmt.close();
		conn.commit();
		conn.close();
		conn = null;
		 
	} catch (Exception e) {
		try {
			conn.rollback();
		} catch (SQLException sqlex) {}
		
		System.out.println(" ERROR "+mName+" : " + e.getMessage());
		System.out.println(" ERROR "+mName+" SQL : " + sql.toString());
		e.printStackTrace();	
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
	/************************************************************************************************************/ 



}
