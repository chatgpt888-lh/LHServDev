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
public class SERV_PrintInfPayInCBServlet extends DBServlet  {
	
  public static int custCopyPosition = 347;
  public static int bankCopyPosition = 93;
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
	
	public String getPeriod(String startDate, String endDate) {
		java.text.SimpleDateFormat th_formatter = new java.text.SimpleDateFormat("MMMM/yyyy", new Locale("th","TH"));
		java.text.SimpleDateFormat en_formatter = new java.text.SimpleDateFormat("yyyy-MM-dd", new Locale("en","US"));
		try {
			java.util.Date frmDate = en_formatter.parse(startDate);
			java.util.Date toDate = en_formatter.parse(endDate);
			int i=0;
			int year = 0;	
			startDate = th_formatter.format(frmDate);
			i = startDate.indexOf("/");
			//year = Integer.parseInt(startDate.substring(i+1))+543;
			year = Integer.parseInt(startDate.substring(i+1));
			startDate = startDate.substring(0, i)+" "+Integer.toString(year);
			endDate = th_formatter.format(toDate);
			i = endDate.indexOf("/");
			//year = Integer.parseInt(endDate.substring(i+1))+543;
			year = Integer.parseInt(endDate.substring(i+1));
			endDate = endDate.substring(0, i)+" "+Integer.toString(year);
		} catch (Exception ignore) {}
		return startDate+" - "+endDate;
	}	
   /************************************************************************************************************/

   
  /************************************************************************************************************/
  public void printHeader(PdfContentByte cb,String nCompany,String eCompany,String address1,String address2,String provCode,String taxId,String tel,String fax,String custName,String nProject,String iLock,String contTel1,String contTel2,double amount,String startDate,String endDate,String expDate) {
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
	
	if (doString.MS874ToUnicode(contTel1).indexOf("โทร.")==0) {
		contTel1 = contTel1.substring(4);
	} else if (doString.MS874ToUnicode(contTel1).indexOf("โทร")==0) {
		contTel1 = contTel1.substring(3);		
	}
	cb.setFontAndSize(bf, 12); // font
	cb.setTextMatrix(409, 697);
	cb.showText(doString.MS874ToUnicode(contTel1));
	cb.setFontAndSize(bfb, 12); // font
	cb.setTextMatrix(323, 669);
	cb.showText(doString.MS874ToUnicode(contTel2));
	
	cb.setFontAndSize(bfb, 12); // font
	cb.setTextMatrix(390, 771);
	//cb.showText("ครบกำหนดชำระ "+expDate);
	cb.showText(" "); // 2021-07-09 , remove text
	
	
	//--- customer details ---//
	cb.setFontAndSize(bf, 12); // font			
	cb.setTextMatrix(80, 758);
	cb.showText(doString.MS874ToUnicode(custName));						
	cb.setTextMatrix(80, 743);
	cb.showText(doString.MS874ToUnicode(nProject));
	cb.setTextMatrix(80, 727);
	cb.showText(iLock);

	
	//--- print amount list ---//
	cb.setTextMatrix(36, 710);
	cb.showText("ค่าบริการสาธารณะเดือน");
	cb.setTextMatrix(getPos(amount), 710);
	cb.showText(doString.displayNumber("#,###,###,###.00", amount));			
	cb.setTextMatrix(230, 710);
	cb.showText("บาท");	
	cb.setTextMatrix(36, 690);
	cb.showText(getPeriod(startDate,endDate));
  }
  
  
  public void printDetails(int startPosition,PdfContentByte cb,String lockCode,String nCompany,String eCompany,String custName,String LHBCode,String SCBCode,String KBankCode,String billerId,String refNo1,String refNo2,String refNo,double amount) {
	cb.setFontAndSize(bfb, 13);
	cb.setTextMatrix(36,startPosition+154);
	cb.showText(doString.MS874ToUnicode(nCompany));	
	cb.setTextMatrix(36,startPosition+140);
	cb.showText(eCompany);							
			
	cb.setFontAndSize(bf, 12);							
	cb.setTextMatrix(362,startPosition+125);
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
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	StringBuffer sql = new StringBuffer();
	doString str = new doString();
	
	String docNo = doString.checkString(req.getParameter("docNo"),"");
	String selProject = doString.checkString(req.getParameter("Project"),"");
	String empId = doString.checkString(req.getParameter("empId"),"");
	String userId = doString.checkString(req.getParameter("userId"),"");
	String iCompany = selProject.length()>=5 ? selProject.substring(0,2) : "";
	String iProject = selProject.length()>=5 ? selProject.substring(2,5) : "";
	String startLock = doString.checkString(req.getParameter("beg_lock"),"");
	String endLock = doString.checkString(req.getParameter("end_lock"),"");
	String restrict = "";
	if (!docNo.equals("")) {
		restrict = "AND (i_docno = '"+docNo+"')";
	} else {
		if (!startLock.equals("")) {
			if (endLock.equals("")) {
				restrict = "AND (i_sort = '"+startLock+"')";
			} else {
				restrict = "AND (i_sort >= '"+startLock+"' AND i_sort <= '"+endLock+"')";
			}
		}
	}
	String betweenDate = doString.checkString(req.getParameter("between"),"");
	int i = betweenDate.indexOf("/");
	String startDate = betweenDate.substring(0,i);
	String endDate = betweenDate.substring(i+1);	
    String suffix = "00";
    String provCode = "BKK"; 
    String iCust = "";
    String custType = "";
    String iLock = "";  
    String iLor = "";
    String idNo = "";
    String expDate = "";
    String lockCode = "";
    int no = 0;
    String payInNo = "";
    boolean isPayIn = false;
    String iHouse = "";
    
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
	String dueDesc = "";
	String refNo1 = "";
	String refNo2 = "";
	String refNo = "";
	double amount = 0.0;
	char BR = (char)13;


    
    int currYear = (Calendar.getInstance()).get(Calendar.YEAR);
    if(currYear<2400) currYear += 543;
	
	
	try {
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(false);
		stmt = conn.createStatement();
		stmt1 = conn.createStatement();
		
		
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
		PdfReader reader = new PdfReader(realPath+File.separator+"form_cb_infra.pdf");
		
		
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
		   .append(" where i_company='"+iCompany+"' and i_province='"+provCode+"' and i_type = 'I' ");
		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
			contTel1 = doString.checkString(rs.getString("i_telno"),"");
			contTel2 = doString.checkString(rs.getString("i_telno2"),"");
		}
		rs.close();			
			

		//----- start print data ------//
		sql.delete(0,sql.length());
		sql.append(" select i_docno, i_sort, i_lor, d_start, d_end, i_inf_custo, i_infra, n_custo, nvl(z_infra,0) as infra_amt, ")
		   .append(" nvl(z_recv_infra,0) as recv_amt, nvl(s_payin,0) as payin_no, nvl(d_prn_payin, today)+59 as exp_date, id_no ")
		   .append(" from lan:serv_infhd ")
		   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' "+restrict+" ")
		   .append(" and d_start='"+startDate+"' and d_end='"+endDate+"' and i_doc_status<>'F' ")
		   .append(" order by i_sort ");		
		rs = stmt.executeQuery(sql.toString());
		while (rs.next()) {
			docNo = doString.checkString(rs.getString("i_docno"),"");
			iLor = doString.checkString(rs.getString("i_lor"),"");
			iLock = doString.checkString(rs.getString("i_sort"),"");
			custType = doString.checkString(rs.getString("i_inf_custo"),"");
			iCust = doString.checkString(rs.getString("i_infra"),"");
			idNo = doString.checkString(rs.getString("id_no"),"");
			
			startDate = doString.checkString(rs.getString("d_start"),"");
			endDate = doString.checkString(rs.getString("d_end"),"");
			expDate = DateUtil.ifxToThaiDate(rs.getString("exp_date"));
			
			amount = rs.getDouble("infra_amt")-rs.getDouble("recv_amt"); //accrue
			no = rs.getInt("payin_no");
			payInNo = Integer.toString(no+1);
			isPayIn = false;
			
			if (!payInNo.equals("1")) {
				sql.delete(0,sql.length());
				sql.append(" select s_payin from lan:serv_infdt ")
				   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
				   .append(" and i_docno='"+docNo+"' and s_payin='"+Integer.toString(no)+"' "); 				
				rs1 = stmt1.executeQuery(sql.toString());
				if (rs1.next()) {
					isPayIn = true;
				}
				rs1.close();
			} else {
				isPayIn = true;
			}
			
			
			sql.delete(0, sql.length());
			if (isPayIn) {
				if (payInNo.equals("1")) {		
					sql.delete(0,sql.length());
					sql.append(" insert into lan:serv_payin ( ")
					   .append(" i_docno, 		i_company, 		i_project, 		i_sort, ")
					   .append(" id_no,			i_lor, 			s_payin, 		i_due, ")
					   .append(" z_payin,		d_frst_payin, 	i_frst_payin, 	s_receive ")
					   .append(" ) values ( ")
					   .append(" '"+docNo+"','"+iCompany+"','"+iProject+"','"+iLock+"', ")
					   .append(" '"+idNo+"', '"+iLor+"','"+payInNo+"','R2', ")
					   .append(" '"+doString.displayNumber("#########.00", amount)+"', ")
					   .append(" today, '"+empId+"', 0) ");
					stmt1.executeUpdate(sql.toString());	
					
					sql.delete(0,sql.length());
					sql.append(" update lan:serv_infhd set ")
					   .append(" d_prn_payin=today, i_doc_status='Y', s_payin=s_payin+1,i_prn_payin='"+empId+"' ")
					   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
					   .append(" and i_docno='"+docNo+"' ");	
					stmt1.executeUpdate(sql.toString());
				}
				payInNo = "1";
			} else {
				payInNo = "1";
				if (no != 0) {
					payInNo = Integer.toString(no);
				}
			}	
			
			
			docNo = docNo.substring(6);
			custName = doString.checkString(rs.getString("n_custo"),"");
			if (custName.equals("")) {
				if (custType.equals("1")) {
					if (!iLor.equals("0")) {
						sql.delete(0,sql.length());
						sql.append(" select * from lan:acxcusto where i_customer='"+iCust+"' ");		
						rs1 = stmt1.executeQuery(sql.toString());
						if (rs1.next()) {
							custName  = doString.checkString(rs1.getString("n_prename"),"");
							custName += doString.checkString(rs1.getString("n_ncustomer"),"");
							custName += " "+doString.checkString(rs1.getString("n_scustomer"),"");
						}
						rs1.close();
					}
				} else {
					custType = "07";
					
					sql.delete(0,sql.length());
					sql.append(" select n_pname, n_name, n_sname from lan:serv_venprj ")
					   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")	
					   .append(" and i_type='"+custType+"' and i_vendor = '"+iCust+"' "); 		
					rs1 = stmt1.executeQuery(sql.toString());
					if (rs1.next()) {
						custName  = doString.checkString(rs1.getString("n_pname"),"");
						custName += doString.checkString(rs1.getString("n_name"),"");
						custName += " "+doString.checkString(rs1.getString("n_sname"),"");
					} 
					rs1.close();	
				}
			}
			
			iHouse = "";
			sql.delete(0,sql.length());
			sql.append(" select i_house from lan:serv_inflck ")
			   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")	
			   .append(" and i_sort='"+iLock+"' "); 		
			rs1 = stmt1.executeQuery(sql.toString());
			if (rs1.next()) {
				iHouse = doString.checkString(rs1.getString("i_house"),"");
			} 
			rs1.close();	
			
			if (iHouse.equals("")) {
				sql.delete(0,sql.length());
				sql.append(" select i_house from lan:acxlckmd ")
				   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")	
				   .append(" and i_lock='"+iLock+"' and i_lor='"+iLor+"' "); 		
				rs1 = stmt1.executeQuery(sql.toString());
				if (rs1.next()) {
					iHouse = doString.checkString(rs1.getString("i_house"),"");
				} 
				rs1.close();
			}
			
			if (iLor.equals("0")) {
				sql.delete(0,sql.length());
				sql.append(" select i_house from lan:serv_inflck ")
				   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")	
				   .append(" and i_sort='"+iLock+"' and i_lor = 0 "); 		
				rs1 = stmt1.executeQuery(sql.toString());
				if (rs1.next()) {
					iHouse = doString.checkString(rs1.getString("i_house"),"");
				} 
				rs1.close();	
			}
			
			if (!iHouse.equals("")) {
				iHouse = " ("+iHouse+")";
			}
			
			lockCode = iCompany+"-"+iProject+"-"+iLock+" ("+nProject+")";
			refNo1 = iLock.substring(0,2)+getLockRef(iLock.substring(2, 3))+iLock.substring(3)+getLockRef("R")+"2";	
			refNo2 = "0"+getCompanyRef(iCompany)+iProject+docNo+payInNo+iCust;
			refNo = "0-"+getCompanyRef(iCompany)+iProject+"-"+docNo+payInNo+"-"+iCust;
			
			//---- start print ----//
			cb.addTemplate(writer.getImportedPage(reader, 1), 1, 1);					
			cb.beginText();			
			
			printHeader(cb,nCompany,eCompany,address1,address2,provCode,taxId,tel,fax,custName+iHouse,nProject,iLock,contTel1,contTel2,amount,startDate,endDate,expDate);			
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
			image128.setAbsolutePosition(40, 35);
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
			document.add(qrImage);		
		
			document.newPage();					
		}
		rs.close();

		
	    
	    
		//----=========== Generate PDF ===============-----//	  	
		document.close();
		res.setContentType("application/pdf");
		res.setContentLength(baos.size());
		ServletOutputStream outServ = res.getOutputStream();
		baos.writeTo(outServ);
		outServ.flush();
		
		
		
		stmt.close();
		stmt1.close();
		conn.commit();
		//conn.rollback();
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
			if (rs1!=null) rs1.close(); 
			if (stmt != null) stmt.close();
			if (stmt1 != null) stmt1.close();
			if (conn != null) conn.close();
		} catch (SQLException ignore) {
		}
	}
	System.out.println(mName + "end.");
	
	}
	/************************************************************************************************************/ 



}
