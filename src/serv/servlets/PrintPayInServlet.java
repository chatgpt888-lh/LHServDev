package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;

import com.lowagie.text.*;
import com.lowagie.text.pdf.*;

import com.lh.servlet.DBServlet;
import com.lh.util.doString;
import com.lh.util.DateUtil;
import com.lh.util.CurrencyToThai;
import com.lh.exception.InvalidParameterException;

public class PrintPayInServlet extends DBServlet {
	private static String cName = "/LHServ/PrintPayInServlet";
/**
 * Insert the method's description here.
 * Creation date: (9/10/2002 17:26:28)
 * @return java.lang.String
 * @param comId java.lang.String
 */
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
/**
 * Insert the method's description here.
 * Creation date: (9/10/2002 17:26:28)
 * @return java.lang.String
 * @param comId java.lang.String
 */
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

public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
	String mName = new String(cName + ".performTask: ");
	System.out.println(mName + "start.");
	String docNo = req.getParameter("docNo");
	String site = req.getParameter("sel_project");
	String comId = site.substring(0,2);
	String projId = site.substring(3);
	String docType = req.getParameter("docType");
	if (docType == null) {
		docType = "A";
	}
	String empId = req.getParameter("empId");
	String userId = req.getParameter("userId");
	String empNme = "";	
	String realPath = getServletContext().getRealPath("/");
	String pdfPath = realPath + "/images/";
	String filename = pdfPath+userId+"O.pdf";
	String fontPath = realPath + "/Fonts/";
	String Thai_TTF = fontPath+"micross.ttf";
	String ANGSAUB_TTF = fontPath+"ANGSAUB.TTF";
	String ANGSAU_TTF = fontPath+"ANGSAU.TTF";
	
	DateUtil date_util = new DateUtil();

	CurrencyToThai currencyToThai = null;
	StringBuffer sql = new StringBuffer();
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

		String company = "";
		String project = "";
		String lockId = "";
		String houseId = "";
		String houseType = "";
		String retenType = "";
		String lorId = "";
		String custId = "";
		String custNo = "";
		String custNme = "";
		String desc = "";
		String dueId = "";
		double amount = 0;
		String accountId = "";
		String bank = "";
		String LHBCode = "";
		String SCBCode = "";
		String TFBCode = "";         
		String refNo = "";
		String refNo1="";
		String refNo2="";        
		boolean acctValid = true;
		boolean isPayIn = false;        
		String ecompany = "";
		String taxId = "";
		String vatId = "";
		String address1 = "";
		String address2 = "";
		String tel = "";
		String fax = "";    
		String cont_tel1 = "";
		String cont_tel2 = "";
		String payNo = "";
		int no = 0;
		String code = "";
		String lock_code = "";
		String suffix = "00";
		char BR = (char)13;
		int bar_size = 12;
		int bar_x = 35; //300
		int bar_y = 33; //22
		int bar_resize = 87;
		float scaledWidth = 87;
		float scaledHeight  = 100; 
		
		rs = stmt.executeQuery("SELECT n_prename_th, n_nemploy_th, n_semploy_th FROM docflow:acemploy WHERE i_employ = '"+empId+"'");
		if (rs != null) {
			if (rs.next() == true) {
				empNme = doString.checkString(rs.getString(2))+" "+doString.checkString(rs.getString(3));
				empNme = doString.MS874ToUnicode(empNme);
			}
			rs.close();
			rs=null;
		}
		
		rs = stmt.executeQuery("SELECT h.i_sort, h.i_house, h.i_lor, h.n_custo, h.i_ret_custo, h.i_reten, NVL(h.z_reten,0) AS RETEN_AMT, NVL(h.z_recv_reten,0) AS RECV_AMT, NVL(h.s_payin,0) AS PAYIN_NO FROM lan:serv_rethd h WHERE h.i_company = '"+comId+"' AND h.i_project = '"+projId+"' AND h.i_docno = '"+docNo+"'");
		if (rs != null) {
			if (rs.next() == true) {
				lorId = Integer.toString(rs.getInt("I_LOR"));
				lockId = doString.checkString(rs.getString("I_SORT"));
				houseId = doString.checkString(rs.getString("I_HOUSE"));
				retenType = doString.checkString(rs.getString("I_RET_CUSTO"));
				custId = doString.checkString(rs.getString("I_RETEN"));
				//amount = rs.getDouble("RETEN_AMT")-rs.getDouble("RECV_AMT");
				amount = rs.getDouble("RETEN_AMT");				
				no = rs.getInt("PAYIN_NO");
				payNo = Integer.toString(no+1);
			}
			rs.close();
			rs=null;
		}
		rs = stmt.executeQuery("SELECT i_house_type FROM lan:acscontr WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lor = "+lorId);
		if (rs != null) {
			if (rs.next() == true) {
				houseType = doString.checkString(rs.getString(1));
			}
			rs.close();
			rs=null;
		}
		if (houseType.equals("1") || houseType.equals("2") || houseType.equals("6") || houseType.equals("7") || houseType.equals("8")) {
			desc = "กรณีการต่อเติมอาคาร(บ้านเดี่ยว) จำนวนเงินวางค้ำประกัน "+doString.displayNumber("###,###,###",amount)+" บาท";
		}
		if (houseType.equals("3")) {
			desc = "กรณีการต่อเติมอาคาร(ทาสน์เฮ้าส์) จำนวนเงินวางค้ำประกัน"+doString.displayNumber("###,###,###",amount)+" บาท";
		}
		if (houseType.equals("5")) {
			desc = "กรณีก่อสร้างอาคาร จำนวนเงินวางค้ำประกัน"+doString.displayNumber("###,###,###",amount)+" บาท";
		}
		
		if (payNo.equals("1")) {
				sql.append("INSERT INTO lan:serv_payin(i_docno, i_company, i_project, i_sort, i_lor, s_payin, i_due, z_payin, d_frst_payin, i_frst_payin, s_receive) VALUES('")
					.append(docNo)
					.append("', '")
					.append(comId)
					.append("', '")
					.append(projId)
					.append("', '")
					.append(lockId)
					.append("', ")
					.append(lorId)
					.append(", ")
					.append(payNo)
					.append(", 'O5', ")
					.append(doString.displayNumber("#########.00", amount))
					.append(", TODAY, '")
					.append(empId+"', 0)");
				stmt.executeUpdate(sql.toString());		
				stmt.executeUpdate("UPDATE lan:serv_rethd SET d_prn_payin = TODAY, i_doc_status = 'Y', s_payin = 1, i_prn_payin = '"+empId+"' WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+docNo+"'");
		} else {
			payNo = "1";
		}
		
		docNo = docNo.substring(6);
		if (retenType.equals("1")) {
			rs = stmt.executeQuery("SELECT n_prename, n_ncustomer, n_scustomer FROM lan:acxcusto WHERE i_customer = "+custId);
			if (rs != null) {
				if (rs.next() == true) {
					custNme = doString.checkString(rs.getString("N_PRENAME"))+" "+doString.checkString(rs.getString("N_NCUSTOMER"))+ " "+doString.checkString(rs.getString("N_SCUSTOMER"));;
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
			rs = stmt.executeQuery("SELECT n_pname, n_name, n_sname FROM lan:serv_venprj WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_type = '"+retenType+"' AND i_vendor = '"+custId+"'");
			if (rs != null) {
				if (rs.next() == true) {
					custNme = doString.checkString(rs.getString("N_PNAME"))+" "+doString.checkString(rs.getString("N_NAME"))+" "+doString.checkString(rs.getString("N_SNAME"));
				}
				rs.close();
				rs=null;
			}
		}
		custNme = doString.MS874ToUnicode(custNme);
		custNo = doString.displayNumber("00000", Integer.parseInt(custId));
		
		rs = stmt.executeQuery("SELECT * FROM lan:acxcompa WHERE i_company = '"+comId+"'");
		if (rs != null) {
			if (rs.next() == true) {
				company = doString.checkString(rs.getString("N_COMPANY"));
				company = doString.MS874ToUnicode(company);
				taxId = doString.checkString(rs.getString("TAX_ID"));				
				vatId = doString.checkString(rs.getString("VAT_ID"));
				vatId = doString.MS874ToUnicode(vatId);
				taxId = vatId;
				address1 = doString.checkString(rs.getString("A_COMPANY"));
				address1 = doString.MS874ToUnicode(address1);
				address1 = "เลขทะเบียนที่ "+vatId+" "+address1;
				address2 = doString.checkString(rs.getString("ADDR2"))+" "+doString.checkString(rs.getString("ADDR3"));
				address2 = doString.MS874ToUnicode(address2);
			}
			rs.close();
			rs=null;
		}
		rs = stmt.executeQuery("SELECT * FROM lan:acxecompa WHERE i_company = '"+comId+"'");
		if (rs != null) {
			if (rs.next() == true) {
				ecompany = doString.checkString(rs.getString("N_COMPANY"));
				tel = doString.checkString(rs.getString("I_TEL"));				
				fax = doString.checkString(rs.getString("I_FAX"));
			}
			rs.close();
			rs=null;
		}
			
		rs = stmt.executeQuery("SELECT n_project FROM lan:acxprojt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
		if (rs != null) {
			if (rs.next() == true) {
				project = doString.checkString(rs.getString("N_PROJECT"));
				project = doString.MS874ToUnicode(project);
			}
			rs.close();
			rs=null;
		}
		lock_code = comId+"-"+projId+"-"+lockId+" ("+project+")";
		rs = stmt.executeQuery("SELECT i_account, comp_code FROM lan:payaccnt WHERE i_company = '"+comId+"'");
		if (rs != null) {
			if (rs.next() == true) {
				accountId = doString.checkString(rs.getString("COMP_CODE"));
			}
			rs.close();
			rs=null;
		}
		
		Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
		String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);		
		String group = "";
		String prov_code = "";
		rs = stmt.executeQuery("SELECT i_group FROM lan:acsbudgh WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND d_year = '"+cur_year+"' AND i_budg_type = '1'");
		if (rs != null) {
			if (rs.next() == true) {
				group = doString.checkString(rs.getString("I_GROUP"));
			}
			rs.close();
			rs=null;
		}
		if ( group.equals("12") || group.equals("05")) {	//G12, G05
			rs = stmt.executeQuery("SELECT i_prov FROM lan:pay_prjprov WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
			if (rs != null) {
				if (rs.next() == true) {
					prov_code = doString.checkString(rs.getString("I_PROV"));
				}
				rs.close();
				rs=null;
			}
		} else {
			prov_code = "BKK";
		}
		
		if (prov_code.equals("CM")) {
			suffix = "02";        	
		} else if (prov_code.equals("KK")) {
			suffix = "01";
		} else if (prov_code.equals("KR")) {
			suffix = "03";					
		} else if (prov_code.equals("UD")) {
			suffix = "04";
		} else if (prov_code.equals("CR")) {
			suffix = "05";
		} else if (prov_code.equals("MS")) {
			suffix = "06";							
		}
		int num_bank = 0;
		rs = stmt.executeQuery("SELECT COUNT(DISTINCT i_bank) AS NUM_BANK FROM lan:payaccnt WHERE i_prov = '"+prov_code+"' AND i_company = '"+comId+"'");
		if (rs != null) {
			if (rs.next() == true) {
				num_bank = rs.getInt("NUM_BANK");
			}
			rs.close();
			rs=null;
		}		
		String formNme = "frmServ.pdf";
		if (num_bank == 1) {
			formNme = "frmServSCB.pdf";
		}		
/*				
		rs = stmt.executeQuery("SELECT DISTINCT p.comp_code, p.i_account, a.i_bank FROM lan:payaccnt p, lan:acraccnt a WHERE p.i_company = '"+comId+"' AND p.i_prov = 'BKK' AND p.i_company = a.i_company AND p.i_account = a.n_account");
		if (rs != null) {
			while (rs.next() == true) {
				bank = doString.checkString(rs.getString("I_BANK"));
				accountId = doString.checkString(rs.getString("COMP_CODE"));
				if (bank.equals("LHB")) {
					LHBCode = "(Comp. Code " + accountId + ")";
				} else if (bank.equals("SCB")) {
					SCBCode = "(Comp. Code " + accountId + ")";
				} else if (bank.equals("TFB")) {
					TFBCode = doString.checkString(rs.getString("I_ACCOUNT")) + ", (Comp. Code " + accountId + ")";
				}
			}// end while
			rs.close();
			rs=null;
		}
*/
		rs = stmt.executeQuery("SELECT comp_code, i_account, i_bank FROM lan:payaccnt WHERE i_prov = '"+prov_code+"' AND i_company = '"+comId+"'");		
		if (rs != null) {
			while (rs.next() == true) {
				bank = doString.checkString(rs.getString("I_BANK"));
				accountId = doString.checkString(rs.getString("COMP_CODE"));
				if (bank.equals("LHB")) {
					LHBCode = "(Comp. Code " + accountId + ")";
				} else if (bank.equals("SCB")) {
					if (accountId.equals("")) {
						SCBCode = doString.checkString(rs.getString("I_ACCOUNT"));
					} else {
						SCBCode = "(Comp. Code " + accountId + ")";
					}					
				} else if (bank.equals("TFB")) {
					TFBCode = doString.checkString(rs.getString("I_ACCOUNT")) + ", (Comp. Code " + accountId + ")";
				}
			}// end while
			rs.close();
			rs=null;
		}	
		rs = stmt.executeQuery("SELECT i_telno, i_telno2 FROM lan:paytelno WHERE i_company = '"+comId+"' AND i_province = '"+prov_code+"' AND i_type = 'R'");
		if (rs != null) {
			if (rs.next() == true) {
				cont_tel1 = doString.MS874ToUnicode(doString.checkString(rs.getString("I_TELNO")));
				cont_tel2 = doString.checkString(rs.getString("I_TELNO2"));
			}
			rs.close();
			rs=null;
		}			
		   		
		// create simple doc and write to a ByteArrayOutputStream
		BaseFont micross = BaseFont.createFont(Thai_TTF, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
		BaseFont angsaub = BaseFont.createFont(ANGSAUB_TTF, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
		BaseFont angsau = BaseFont.createFont(ANGSAU_TTF, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);         
		int x = 5;
		int y = 239;
		int a = 23;
		Document document = new Document();
		PdfWriter writer = PdfWriter.getInstance(document, new FileOutputStream(filename));
		PdfReader reader = new PdfReader(realPath + "/" + formNme);
		PdfContentByte cb = writer.getDirectContent();
		document.open();
		if (docType.equals("A") || docType.equals("P")) {
						PdfImportedPage page1 = writer.getImportedPage(reader, 1);
						dueId = getLockRef("O")+"5";
						currencyToThai = new CurrencyToThai(amount);
						refNo = "";
						refNo1 = lockId.substring(0, 2) + getLockRef(lockId.substring(2, 3)) + lockId.substring(3) + dueId;
						refNo2 = "0" + getCompanyRef(comId) + projId + docNo + payNo + "0" + custNo;
						refNo = "0-" + getCompanyRef(comId) + projId + "-" + docNo + payNo +"-0" + custNo;
												
						cb.addTemplate(page1, 0, 0);
						cb.beginText();
						cb.setFontAndSize(micross, 10);
						
						
						// COMPANY THAI
						cb.setFontAndSize(angsaub, 16);
						cb.setTextMatrix(36, 801+5+12);
						cb.showText(company);						
		
						// COMPANY ENG
						cb.setFontAndSize(angsaub, 16);
						cb.setTextMatrix(36, 782+8+14);
						cb.showText(ecompany);		
										
						cb.setFontAndSize(micross, 8);
						// ADDRESS1,2
						cb.setTextMatrix(36, 770+7+14);
						cb.showText(address1+" "+address2);						
						
						//Tel				
						cb.setTextMatrix(36, 755+7+18);
						if (prov_code.equals("BKK")) {
							cb.showText("โทร."+tel+" แฟกซ์ : "+fax);
							cb.setTextMatrix(36, 740+7+22);		
						}
						
						// Tax
						cb.showText("เลขประจำตัวผู้เสียภาษีอากร "+taxId);
						
						cb.setFontAndSize(micross, 8);	
						// CUSTOMER NAME	
						cb.setTextMatrix(73+10, 715+5+37);
						cb.showText(custNme);						
		
						// PROJECT
						cb.setTextMatrix(73+10, 695+5+41);
						cb.showText(project);
										
						// LOCK ID
						cb.setTextMatrix(73+10, 675+5+45);
						cb.showText(lockId);
						
						//Cont TelNumber
						cb.setTextMatrix(315+156, 696);
						cb.showText(cont_tel1);
								
						cb.setTextMatrix(315+91, 696-45+15);
						cb.showText(cont_tel2);											
						
						cb.setFontAndSize(micross, 10);						
						/////////////////////////////////////////////// CUSTOMER COPY //////////////////////////////////////////////
						// COMPANY THAI
						cb.setFontAndSize(angsaub, 16);
						cb.setTextMatrix(36, 430+a+34);
						cb.showText(company);	
		
						// COMPANY ENG
						cb.setTextMatrix(36, 411+a+34);
						cb.showText(ecompany);			
												
						cb.setFontAndSize(micross, 10);							
						// CUSTOMER NAME
						cb.setTextMatrix(355+5, 428+a+15-16);
						cb.showText(custNme);				
		
						//CUST. NO.
						cb.setTextMatrix(355+45, 410+a+16-15);
						cb.showText(refNo1);
						
						// A/C NO.
						cb.setFontAndSize(micross, 6);
						cb.setTextMatrix(184, 428+a+15-15);
						cb.showText(LHBCode);
						cb.setTextMatrix(200, 410+a+16-13);
						cb.showText(SCBCode);				
						cb.setTextMatrix(170, 393+a+20-14);
						cb.showText(TFBCode);						
														
						// REFERENCE
						cb.setFontAndSize(micross, 10);				
						cb.setTextMatrix(355+14, 393+a+20-15);
						cb.showText(refNo);
						
						// AMOUNT
						cb.setTextMatrix(130, 332+a+36-16);
						cb.showText(doString.MS874ToUnicode(currencyToThai.getString()));
						cb.setTextMatrix(410, 332+a+36-16);
						cb.showText(doString.displayNumber("#,###,###,###.00", amount));
						

						cb.setTextMatrix(36, 320+40);
						cb.showText(lock_code);						
						/////////////////////////////////////////////// BANK COPY //////////////////////////////////////////////
						cb.setFontAndSize(angsaub, 16);
						// COMPANY THAI
						cb.setTextMatrix(36, 430-y+a+34);
						cb.showText(company);	
		
						// COMPANY ENG
						cb.setTextMatrix(36, 411-y+a+34);
						cb.showText(ecompany);					
										
						cb.setFontAndSize(micross, 10);							
						// CUSTOMER NAME	
						cb.setTextMatrix(355+5, 428-y+a+15-16);
						cb.showText(custNme);				
		
						//CUST. NO.
						cb.setTextMatrix(355+45, 410-y+a+16-15);
						cb.showText(refNo1);
						
						cb.setFontAndSize(micross, 6);
						cb.setTextMatrix(184, 428-y+a+15-15);
						cb.showText(LHBCode);
						cb.setTextMatrix(200, 410-y+a+16-13);
						cb.showText(SCBCode);				
						cb.setTextMatrix(170, 393-y+a+20-14);
						cb.showText(TFBCode);							
						
						// REFERENCE
						cb.setFontAndSize(micross, 10);	
						cb.setTextMatrix(355+14, 393-y+a+20-15);
						cb.showText(refNo);
	
						// AMOUNT
						cb.setTextMatrix(130, 332-y+a+36-16);
						cb.showText(doString.MS874ToUnicode(currencyToThai.getString()));
						currencyToThai = null;
						cb.setTextMatrix(410, 332-y+a+36-16);
						cb.showText(doString.displayNumber("#,###,###,###.00", amount));

						cb.setTextMatrix(36, 320-y+40);
						cb.showText(lock_code);						
						cb.endText();
						code = "|"+taxId+suffix+BR+refNo1+BR+refNo2+BR+getAmount(doString.displayNumber("##########.00", amount));
						Barcode128 code128 = new Barcode128();
						code128.setTextAlignment(Element.ALIGN_LEFT);
						code128.setBarHeight(bar_size*3);        
						code128.setCode(code);
				        
						Image image128 = code128.createImageWithBarcode(cb, null, null);
						image128.scalePercent(scaledWidth,scaledHeight);
						image128.setAbsolutePosition(bar_x, bar_y);
						document.add(image128);	
						
		}
		if (docType.equals("A") || docType.equals("R")) {
						if (docType.equals("A")) {
							document.newPage();
						}
						PdfReader reader2 = new PdfReader(realPath + "/frmReten.pdf");
						PdfImportedPage page2 = writer.getImportedPage(reader2, 1);
						cb.addTemplate(page2, 0, 0);						
						cb.beginText();
						cb.setFontAndSize(angsau, 14);
						// PROJECT
						cb.setTextMatrix(158, 765);
						cb.showText(project);
						
						cb.setTextMatrix(148, 747);
						cb.showText(lockId);						

						cb.setTextMatrix(358, 747);
						cb.showText(comId+projId+"-"+docNo);

						cb.setTextMatrix(162, 729);
						cb.showText(houseId);												
						
						cb.setTextMatrix(348, 729);
						cb.showText(custNme);		
													
						//cb.setFontAndSize(angsaub, 14);
						cb.setTextMatrix(72, 512);
						cb.showText(desc);		
																						
						cb.setFontAndSize(angsau, 13);
						cb.setTextMatrix(64, 35);
						cb.showText(custNme);
						cb.setTextMatrix(344, 35);
						cb.showText(empNme);									
						cb.endText();								
		}
		
		// we close the document (the outputstream is also closed internally)
		document.close();
		File f = new File(filename);
		InputStream in = null;
		in = new BufferedInputStream(new FileInputStream(f));
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		int ch;
		while ((ch = in.read()) !=-1) {
			baos.write((byte)ch);
		}// end while 
		in.close();
		f.delete();                
		
		if (acctValid) {
			// write ByteArrayOutputStream to the ServletOutputStream
			res.setContentType("application/pdf");
			res.setContentLength(baos.size());
			ServletOutputStream out = res.getOutputStream();
			baos.writeTo(out);
			out.flush();	   
		} else {
			res.setContentType("text/html; charset=TIS620");
			PrintWriter out = res.getWriter();
			showError(out, "ไม่พบเลขที่บัญชี");
//			out.flush();
		}
        
		stmt.close();
		conn.close();
		stmt = null;
		conn = null;
	} catch (Exception e) {
		System.out.println("ERROR /LHServ/PrintPayInServlet : " + e.getMessage());
	} finally {
		try {
			if (rs != null)
				rs.close();
			if (stmt != null)
				stmt.close();
			if (conn != null)
				conn.close();
		} catch (SQLException ignore) {
		}
	}
	System.out.println(mName + "end.");
}
}