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

public class PrintInfPayInServlet extends DBServlet {
	private static String cName = "/LHServ/PrintInfPayInServlet";
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

private String getPeriod(String startDate, String endDate) {
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

public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
	String mName = new String(cName + ".performTask: ");
	System.out.println(mName + "start.");
	String docNo = doString.checkString(req.getParameter("docNo"));
	String project = req.getParameter("Project");
	String empId = req.getParameter("empId");
	String userId = req.getParameter("userId");
	String comId = project.substring(0,2);
	String projId = project.substring(2);
	String beg_lock = doString.checkString(req.getParameter("beg_lock"));
	String end_lock = doString.checkString(req.getParameter("end_lock"));
	String restrict = "";
	if (!docNo.equals("")) {
		restrict = "AND (i_docno = '"+docNo+"')";
	} else {
		if (!beg_lock.equals("")) {
			if (end_lock.equals("")) {
				restrict = "AND (i_sort = '"+beg_lock+"')";
			} else {
				restrict = "AND (i_sort >= '"+beg_lock+"' AND i_sort <= '"+end_lock+"')";
			}
		}
	}
	String betweenDate = doString.checkString(req.getParameter("between"));
	int i = betweenDate.indexOf("/");
	String startDate = betweenDate.substring(0,i);
	String endDate = betweenDate.substring(i+1);	
	String realPath = getServletContext().getRealPath("/");
	String pdfPath = realPath + "/images/";
	String filename = pdfPath+userId+"O.pdf";
	String fontPath = realPath + "/Fonts/";
	String Thai_TTF = fontPath+"micross.ttf";
	String ANGSAUB_TTF = fontPath+"ANGSAUB.TTF";
	
	DateUtil date_util = new DateUtil();

	CurrencyToThai currencyToThai = null;
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement dstmt = null;
	ResultSet rs = null;
	ResultSet rsDoc = null;	
	try {
		if (ds == null)
			getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();
		dstmt = conn.createStatement();

		String company = "";
		String lockId = "";
		String custType = "";
		String lorId = "";
		String custId = "";
		String custNo = "";
		String custNme = "";
		String id_no = "";
		String dueId = "";
		double amount = 0;
		String accountId = "";
		String bank = "";
		String LHBCode = "";
		String SCBCode = "";
		String TFBCode = "";    		
		String houseNo = "";
		String refNo = "";
		String refNo1="";
		String refNo2="";
		String expDate = "";        
		boolean acctValid = true;
		boolean isPayIn = false;        
		String ecompany = "";
		String taxId = "";
		String vatId = "";
		String address1 = "";
		String address2 = "";
		String tel = "";
		String cont_tel1 = "";
		String cont_tel2 = "";
		String fax = "";    
		String payNo = "";
		int no = 0;
		String code = "";
		String lock_code = "";
		String suffix = "00";
		char BR = (char)13;
		int bar_size = 8; //12
		int bar_x = 50; //35
		int bar_y = 33; //33
		int bar_resize = 87;
		float scaledWidth = 60; //87
		float scaledHeight  = 100; //100
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
		if ( group.equals("12") || group.equals("05") ) {	//G12, G05
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
		project = "";
		rs = stmt.executeQuery("SELECT n_project FROM lan:acxprojt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
		if (rs != null) {
			if (rs.next() == true) {
				project = doString.checkString(rs.getString("N_PROJECT"));
				project = doString.MS874ToUnicode(project);
			}
			rs.close();
			rs=null;
		}
		rs = stmt.executeQuery("SELECT i_account, comp_code, TODAY+59 AS EXP_DATE FROM lan:payaccnt WHERE i_company = '"+comId+"'");
		if (rs != null) {
			if (rs.next() == true) {
				accountId = doString.checkString(rs.getString("COMP_CODE"));
			}
			rs.close();
			rs=null;
		}
    	rs = stmt.executeQuery("SELECT i_telno, i_telno2 FROM lan:paytelno WHERE i_company = '"+comId+"' AND i_province = '"+prov_code+"' AND i_type = 'I'");
    	if (rs != null) {
    		if (rs.next() == true) {
    			cont_tel1 = doString.MS874ToUnicode(doString.checkString(rs.getString("I_TELNO")));
    			cont_tel2 = doString.MS874ToUnicode(doString.checkString(rs.getString("I_TELNO2")));
    		}
    		rs.close();
    		rs=null;
    	}		
    	if (cont_tel2.equals("")) {
    		cont_tel2 = "1198 กด 2";
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
		String formNme = "frmInfra.pdf";
		if (num_bank == 1) {
			formNme = "frmInfraSCB.pdf";
		}		    	
/*		
		rs = stmt.executeQuery("SELECT DISTINCT p.comp_code, p.i_account, a.i_bank FROM lan:payaccnt p, lan:acraccnt a WHERE p.i_prov = 'BKK' AND p.i_company = '"+comId+"' AND p.i_company = a.i_company AND p.i_account = a.n_account");
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
		
		// create simple doc and write to a ByteArrayOutputStream
		Document document = new Document();
		PdfWriter writer = PdfWriter.getInstance(document, new FileOutputStream(filename));
		PdfReader reader = new PdfReader(realPath + "/" + formNme);
		PdfContentByte cb = writer.getDirectContent();
		document.open();
		PdfImportedPage page1 = writer.getImportedPage(reader, 1);
		BaseFont micross = BaseFont.createFont(Thai_TTF, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
		BaseFont angsaub = BaseFont.createFont(ANGSAUB_TTF, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);         
        int x = 5;
        int y = 239;
        int a = 23;		
		rsDoc = dstmt.executeQuery("SELECT i_docno, i_sort, i_lor, d_start, d_end, i_inf_custo, i_infra, n_custo, NVL(z_infra,0) AS INFRA_AMT, NVL(z_recv_infra,0) AS RECV_AMT, NVL(s_payin,0) AS PAYIN_NO, NVL(d_prn_payin, today)+59 AS EXP_DATE, id_no FROM lan:serv_infhd WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' "+restrict+" AND d_start = '"+startDate+"' AND d_end = '"+endDate+"' AND i_doc_status != 'F' ORDER BY i_sort");
		if (rsDoc != null) {
			while (rsDoc.next() == true) {
				docNo = doString.checkString(rsDoc.getString("I_DOCNO"));
				lorId = Integer.toString(rsDoc.getInt("I_LOR"));
				lockId = doString.checkString(rsDoc.getString("I_SORT"));
				custType = doString.checkString(rsDoc.getString("I_INF_CUSTO"));
				custId = doString.checkString(rsDoc.getString("I_INFRA"));
				id_no = doString.checkString(rsDoc.getString("ID_NO"));
				
				startDate = doString.checkString(rsDoc.getString("D_START"));
				endDate = doString.checkString(rsDoc.getString("D_END"));
				expDate = DateUtil.ifxToThaiDate(rsDoc.getString("EXP_DATE"));
				
				amount = rsDoc.getDouble("INFRA_AMT")-rsDoc.getDouble("RECV_AMT"); //accrue
				no = rsDoc.getInt("PAYIN_NO");
				payNo = Integer.toString(no+1);
				isPayIn = false;
				if (!payNo.equals("1")) {
						rs = stmt.executeQuery("SELECT s_payin FROM lan:serv_infdt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+docNo+"' AND s_payin = "+Integer.toString(no));
						if (rs != null) {
							if (rs.next() == true) {
								isPayIn = true;
							}
							rs.close();
							rs=null;
						}
				} else {
					//insert
					isPayIn = true;
				}
				sql.delete(0, sql.length());
				if (isPayIn) {
						if (payNo.equals("1")) {					
							sql.append("INSERT INTO lan:serv_payin(i_docno, i_company, i_project, i_sort, id_no, i_lor, s_payin, i_due, z_payin, d_frst_payin, i_frst_payin, s_receive) VALUES('")
								.append(docNo)
								.append("', '")
								.append(comId)
								.append("', '")
								.append(projId)
								.append("', '")
								.append(lockId)
								.append("', '")
								.append(id_no)
								.append("', ")
								.append(lorId)
								.append(", ")
								.append(payNo)
								.append(", 'R2', ")
								.append(doString.displayNumber("#########.00", amount))
								.append(", TODAY, '")
								.append(empId+"', 0)");
							stmt.executeUpdate(sql.toString());		
							stmt.executeUpdate("UPDATE lan:serv_infhd SET d_prn_payin = TODAY, i_doc_status = 'Y', s_payin = s_payin + 1, i_prn_payin = '"+empId+"' WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+docNo+"'");
						}
						payNo = "1";
				} else {
					payNo = "1";
					if (no != 0) {
						payNo = Integer.toString(no);
					}
				}
				docNo = docNo.substring(6);
				custNme = doString.checkString(rsDoc.getString("N_CUSTO"));
				if (custNme.equals("")) {
					if (custType.equals("1")) {
						if (!lorId.equals("0")) {
							rs = stmt.executeQuery("SELECT n_prename, n_ncustomer, n_scustomer FROM lan:acxcusto WHERE i_customer = "+custId);
							if (rs != null) {
								if (rs.next() == true) {
									custNme = doString.checkString(rs.getString("N_PRENAME"))+" "+doString.checkString(rs.getString("N_NCUSTOMER"))+ " "+doString.checkString(rs.getString("N_SCUSTOMER"));;
								}
								rs.close();
								rs=null;
							}
						}
					} else {
						custType = "07";
						rs = stmt.executeQuery("SELECT n_pname, n_name, n_sname FROM lan:serv_venprj WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_type = '"+custType+"' AND i_vendor = '"+custId+"'");
						if (rs != null) {
							if (rs.next() == true) {
								custNme = doString.checkString(rs.getString("N_PNAME"))+" "+doString.checkString(rs.getString("N_NAME"))+" "+doString.checkString(rs.getString("N_SNAME"));
							}
							rs.close();
							rs=null;
						}
					}
				}
				houseNo = "";
				rs = stmt.executeQuery("SELECT i_house FROM lan:serv_inflck WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_sort = '"+lockId+"'");
				if (rs != null) {
					if (rs.next() == true) {
						houseNo = doString.checkString(rs.getString("I_HOUSE"));
					}
					rs.close();
					rs=null;
				}
				if (houseNo.equals("")) {
					rs = stmt.executeQuery("SELECT i_house FROM lan:acxlckmd WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lor = "+lorId+" AND i_lock = '"+lockId+"'");
					if (rs != null) {
						if (rs.next() == true) {
							houseNo = doString.checkString(rs.getString("I_HOUSE"));
						}
						rs.close();
						rs=null;
					}
				}
				
				if (lorId.equals("0")) {
					rs = stmt.executeQuery("SELECT i_house FROM lan:serv_inflck WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_sort = '"+lockId+"' AND i_lor = 0");
					if (rs != null) {
						if (rs.next() == true) {
							houseNo = doString.checkString(rs.getString("I_HOUSE"));
						}
						rs.close();
						rs=null;
					}
				}
				
				if (!houseNo.equals("")) {
					houseNo = " ("+houseNo+")";
				}
				custNme = doString.MS874ToUnicode(custNme);
				custNo = doString.displayNumber("00000", Integer.parseInt(custId));
				lock_code = comId+"-"+projId+"-"+lockId+" ("+project+")";
				dueId = getLockRef("R")+"2";
				currencyToThai = new CurrencyToThai(amount);
				refNo = "";
				refNo1 = lockId.substring(0, 2) + getLockRef(lockId.substring(2, 3)) + lockId.substring(3) + dueId;
				refNo2 = "0" + getCompanyRef(comId) + projId + docNo + payNo + custNo;
				refNo = "0-" + getCompanyRef(comId) + projId + "-" + docNo + payNo +"-" + custNo;

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
						//Tax
						cb.showText("เลขประจำตัวผู้เสียภาษีอากร "+taxId);							
						
						cb.setFontAndSize(micross, 10);		
						//Expire Date				
						cb.setTextMatrix(400, 755+16);
						cb.showText("ครบกำหนดชำระ "+expDate);
						
						cb.setFontAndSize(micross, 8);	
						// CUSTOMER NAME	
						cb.setTextMatrix(73+10, 715+5+37);
						cb.showText(custNme+houseNo);						
		
						// PROJECT
						cb.setTextMatrix(73+10, 695+5+41);
						cb.showText(project);
										
						// LOCK ID
						cb.setTextMatrix(73+10, 675+5+45);
						cb.showText(lockId);
						
						//Cont TelNumber
						cb.setTextMatrix(315+69, 696);
						cb.showText(cont_tel1);
						
						cb.setTextMatrix(315+4, 696-31);
						cb.showText(cont_tel2);						
						
						cb.setFontAndSize(micross, 10);	
						// PERIOD
						cb.setTextMatrix(36, 675+56-20);
						cb.showText("ค่าบริการสาธารณะเดือน");
						cb.setTextMatrix(83+80, 675+56-20);
						cb.showText(doString.displayNumber("###,###,###.00",amount)+" บาท");
						
						cb.setTextMatrix(36, 675+56-20-20);
						cb.showText(getPeriod(startDate, endDate));
						
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
						cb.setTextMatrix(187, 428+a+15-15);
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
						cb.setTextMatrix(187, 428-y+a+15-15);
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
						
						
						document.newPage();
			}// end while
			rsDoc.close();
			rsDoc=null;
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
			showError(out, "????????????????");
//			out.flush();
		}
        
		stmt.close();
		dstmt.close();
		conn.close();
		stmt = null;
		dstmt = null;
		conn = null;
	} catch (Exception e) {
		System.out.println("ERROR /LHServ/PrintInfPayInServlet : " + e.getMessage());
	} finally {
		try {
			if (rs != null)
				rs.close();
			if (rsDoc != null)
				rsDoc.close();				
			if (stmt != null)
				stmt.close();
			if (dstmt != null)
				dstmt.close();				
			if (conn != null)
				conn.close();
		} catch (SQLException ignore) {
		}
	}
	System.out.println(mName + "end.");
}
}