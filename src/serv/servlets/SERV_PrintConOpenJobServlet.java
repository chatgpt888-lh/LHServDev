package serv.servlets;
 
import java.io.*;
import java.util.*;
import java.sql.*;
import java.text.*;

import javax.servlet.*;
import javax.servlet.http.*;


import com.lh.servlet.DBServlet;
import com.lh.util.doString;
import com.lh.exception.InvalidParameterException;

import java.awt.Color;
import com.lowagie.text.*;
import com.lowagie.text.Document;
import com.lowagie.text.pdf.GrayColor;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import com.lowagie.text.pdf.PdfReader;
import com.lowagie.text.pdf.PdfImportedPage;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.BaseFont;


import serv.common.User;
import serv.common.Constants;
import serv.common.SERV_CommonData;





public class SERV_PrintConOpenJobServlet extends DBServlet  {

    private BaseFont bf;
	private BaseFont bfb;
	private Font microssfont;
	private Font microssfont_MINI;
	private Font microssfont_BOLD;
	private Font microssfont_BOLD_UNDERLINE;
	private Font microssfont_HD;
	private Font microssfont_MED;
	private Font microssfont_MED_BOLD;
	private Font microssfont_MED_BOLD_UNDERLINE;
	
	private String iDocNo = "";
	private String inFormEmp = "";
	private String projDesc = "";
	private String iCompany = "";
	private String iProject = "";
	private String nCustomer = "";
	private String nCustTel = "";
	private String iLock = "";
	private String cDesc = "";
	private String inFormDate = "";
	private String housePlan = "";
	private String houseId = "";
	private String iCustomer = "";
	private String guranteeDate = "";
	private String custName = "";
	private String custTel = "";
	private String siteTel = "";
	private String responseProject = "";
	private String dAppoint = "";
	private String dEstClose = "";
	private String itemTable = "";
	
	
	//---================ Config Column width for customer page ===========---//
	int leftColumnWidth = 60;
	int rightColumnWidth = 40;
	
	//---=============== Define Width Column Variables for itemList in Vendor & Employee Page ======---//
	int numWidth = 10;
	int itemWidth = 70;
	int sumTotalWidth = 10;
	int countWidth = 10;
	
	
	int itmtypeWidth = 8;
	int qWageWidth = 6;
	int zWageWidth = 6;
	int tWageWidth = 6;
	int qGoodsWidth = 6;
	int zGoodsWidth = 6;
	int tGoodsWidth = 6;
	int estWidth = 8;
	
	
	
	public PdfPCell setCellAttribute(String msg,Font font,String hAlign,String vAlign,int colSpan,int border) {
		
		int h = 0;
		if (hAlign.equalsIgnoreCase("L")) {
			h = Rectangle.ALIGN_LEFT; 
		} else if (hAlign.equalsIgnoreCase("R")) {
			h = Rectangle.ALIGN_RIGHT; 
		} else {
			h = Rectangle.ALIGN_CENTER; 
		}
		

		int v = 0;
		if (vAlign.equalsIgnoreCase("T")) {
			v = Rectangle.ALIGN_TOP; 
		} else if (vAlign.equalsIgnoreCase("B")) {
			v = Rectangle.ALIGN_BOTTOM;
		} else {
			v = Rectangle.ALIGN_MIDDLE; 
		}		
		
		
		//---======= Start Set Cell Apprivutes =======---//
		 PdfPCell cell = new PdfPCell(new Phrase(msg,font));
		 cell.setHorizontalAlignment(h);
		 cell.setVerticalAlignment(v);
		 cell.setColspan(colSpan);
		 cell.setBorder(border);
		 
		 return cell;
	}
	
	public void genReportHeader(PdfContentByte cb,PdfImportedPage page1,PdfPTable table,String repType,String nVendor,String showPage,boolean closeProj,String Prj_Condo,String name_serv) throws Exception {
		  PdfPCell cell;
		  
		  String msg = "";
		  String msgHeader = "";
		  if (repType.equalsIgnoreCase("C")) {
		  	  msg = "สำหรับลูกค้า "+showPage;
		  	  msgHeader = "ใบเบิกงวดงาน";
		  } else if (repType.equalsIgnoreCase("V")) {
			msg = "สำหรับผู้รับเหมา "+showPage;
			msgHeader = "ใบเบิกงวดงาน";
		  } else {
			msg = "สำหรับเจ้าหน้าที่ "+showPage;
			msgHeader = "ใบเบิกงวดงาน";
		  }
		  
		  doString str = new doString();
		  Calendar now = Calendar.getInstance(Locale.ENGLISH);
		  String currDate  = str.createID(now.get(Calendar.DATE),2)+"/"+str.createID(now.get(Calendar.MONTH)+1,2);
		  int nYear = now.get(Calendar.YEAR);
		  if (nYear<2500) nYear += 543;
		  currDate += "/"+str.createID(nYear,4);
		  currDate += " , "+str.createID(now.get(Calendar.HOUR_OF_DAY),2)+":"+str.createID(now.get(Calendar.MINUTE),2);
		  
		  
		  //--===== Add Template Header =====--//
		  cb.addTemplate(page1,1,1);
		  
		  
		  //---======= Add Space for Header =========---//
	 	  cell = setCellAttribute(msg+" Print Date : "+currDate,microssfont_MED,"R","T",100,0);
		  table.addCell(cell);
		  
		  cell = setCellAttribute((closeProj ? "โครงการปิด" : "")+"\n\n\n\n",microssfont_HD,"R","T",100,0);
		  table.addCell(cell);
		  
		  cell = setCellAttribute(msgHeader+"\n\n",microssfont_HD,"C","M",100,0);
		  table.addCell(cell);
		  
		  
		  
		  //----================ Set Report Header ===========----//
		cell = setCellAttribute("โครงการ : "+doString.MS874ToUnicode(projDesc),microssfont_MED,"L","M",leftColumnWidth,0);
		table.addCell(cell);		  
		cell = setCellAttribute("เลขที่ใบเบิก : "+iDocNo,microssfont_MED,"L","M",rightColumnWidth,0);
		table.addCell(cell);
		
		cell = setCellAttribute("วันที่ขอเบิก : "+dAppoint,microssfont_MED,"L","M",leftColumnWidth,0);
		table.addCell(cell);		
		cell = setCellAttribute("ชื่อผู้ขอเบิก : "+doString.MS874ToUnicode(inFormEmp),microssfont_MED,"L","M",rightColumnWidth,0);
		table.addCell(cell);
		
		//----================ Add Header Table for Customer Report ===========----//\
		if (repType.equalsIgnoreCase("C")) {
			cell = setCellAttribute("\n",microssfont_MED,"C","M",100,0);
			table.addCell(cell);		  
			cell = setCellAttribute("รายการที่",microssfont_BOLD,"C","M",10,15);
			cell.setFixedHeight(22);
			table.addCell(cell);		  
			cell = setCellAttribute("รายการงวดงาน",microssfont_BOLD,"C","M",90,15);
			cell.setFixedHeight(22);
			table.addCell(cell);		  
		}
		
		
		
		//----================= Add Header Table for Vendor & Employee ==============----//
		else {
		if(!Prj_Condo.equals("Y")){	
			if (repType.equalsIgnoreCase("V")) {
				cell = setCellAttribute("ผู้รับเหมา : "+doString.MS874ToUnicode(nVendor),microssfont_MED,"L","M",leftColumnWidth,0);
				table.addCell(cell);	
				cell = setCellAttribute(" ",microssfont_MED,"L","M",rightColumnWidth,0);
				table.addCell(cell);					
			}
		}// end if Prj_Condo

			cell = setCellAttribute("\n",microssfont_MED,"C","M",100,0);
			table.addCell(cell);
					  
			cell = setCellAttribute("งวดที่",microssfont_MED,"C","M",numWidth,13);
			cell.setFixedHeight(22);
			table.addCell(cell);
			cell = setCellAttribute("รายละเอียดงวดงาน",microssfont_MED,"C","M",itemWidth,13);
			cell.setFixedHeight(22);
			table.addCell(cell);
			cell = setCellAttribute("จำนวนเงิน",microssfont_MED,"C","M",sumTotalWidth,13);
			cell.setFixedHeight(22);
			table.addCell(cell);
			cell = setCellAttribute("หน่วยนับ",microssfont_MED,"C","M",countWidth,13);
			cell.setFixedHeight(22);
			table.addCell(cell);
		} // end if check repType
	}
	
	public void genCommonFooter(PdfPTable table,String vendorSign,String Prj_Condo,String n_service) throws Exception {
		
		
		
		PdfPCell cell;
		
		cell = setCellAttribute(" ",microssfont_MED_BOLD,"C","M",50,4);
		table.addCell(cell);
		cell = setCellAttribute("ลงชื่อเจ้าหน้าที่ผู้ขอเบิก",microssfont_MED_BOLD,"C","M",50,8);
		table.addCell(cell);
		
		cell = setCellAttribute("\n",microssfont_MINI,"C","M",50,4);
		table.addCell(cell);
		cell = setCellAttribute("\n.................................................................................",microssfont_MINI,"C","M",50,8); 		                                            
		table.addCell(cell);
		
		cell = setCellAttribute(" \n\n",microssfont_MINI,"C","M",50,6);
		table.addCell(cell);
		cell = setCellAttribute("("+doString.MS874ToUnicode(inFormEmp)+")\n\n",microssfont_MINI,"C","M",50,10);
		table.addCell(cell);
	}
	
	
	
	public void genVendorFooter(PdfPTable table,String nVendor,String Prj_Condo,String n_service) throws Exception {
		PdfPCell cell;
				
		cell = setCellAttribute("ลงชื่อผู้รับเหมารับงาน",microssfont_MED_BOLD,"C","M",50,12);
		table.addCell(cell);
		cell = setCellAttribute("ลงชื่อเจ้าหน้าที่ผู้ขอเบิก",microssfont_MED_BOLD,"C","M",50,12);
		table.addCell(cell);
		
		cell = setCellAttribute("\n.................................................................................",microssfont_MINI,"C","M",50,12);
		table.addCell(cell);
		cell = setCellAttribute("\n.................................................................................",microssfont_MINI,"C","M",50,12); 		                                            
		table.addCell(cell);
		
		cell = setCellAttribute("("+doString.MS874ToUnicode(nVendor)+")\n\n",microssfont_MINI,"C","M",50,14);
		table.addCell(cell);
		cell = setCellAttribute("("+doString.MS874ToUnicode(inFormEmp)+")\n\n",microssfont_MINI,"C","M",50,14);
		table.addCell(cell);	
	} 
	
	
	
	public void generateItemList(String itmType,Vector vendorList,Vector itmList,Document document,PdfContentByte cb,PdfImportedPage page1,PdfPTable table,boolean closeProj,String Prj_Condo,String name_serv,String n_service) throws Exception {
		DecimalFormat format = new DecimalFormat("#,##0.00");
		DecimalFormat uformat = new DecimalFormat("#,##0");
		PdfPCell cell;
		int maximumLine = 0;
		if (itmType.equalsIgnoreCase("V")) {
			 maximumLine = Constants.SERV_PRINT_OPENJOB_VENDOR_LINE;
		} else {
			maximumLine = Constants.SERV_PRINT_OPENJOB_EMPLOYEE_LINE;
		}
		
		
		for (int loop=0;loop<vendorList.size();loop++) {
			    String[] vendor = (String[]) vendorList.elementAt(loop);
			    Vector vendorItem = new Vector();
			    
			    
			    //----========== For Employee Page , Print 1 copy only ==============-----//
			    if (itmType.equalsIgnoreCase("E") && loop>0) break;
			    
			    
			    
			    //----=========== Get Item Data for this vendor only ==================-----//
			    for (int c=0;c<itmList.size();c++) {
			    	    Hashtable data = (Hashtable) itmList.elementAt(c);
			    	    if (vendor[0].equalsIgnoreCase((String) data.get("i_vendor")) || itmType.equalsIgnoreCase("E")) {
			    	    	vendorItem.addElement(data);
			    	    }
			    }
			    
			    
			    //--===== Calculate Max Page ====---//
			    int maxPage = 0;
			    int chk = vendorItem.size();
			    while (chk>0) {
			    	maxPage++;
			    	chk -= maximumLine;
			    }
			    
			    int line = 0;
			    int page = 0;
			    double sumPayAmnt = 0;
			    while (line<vendorItem.size()) {
			    	//----======== Start New Page =============----//
			    	table = new PdfPTable(100);
			    	table.setWidthPercentage(100);
			    	cb.addTemplate(page1,1,1);
			    	genReportHeader(cb,page1,table,itmType,vendor[1],"("+(page+1)+"/"+maxPage+")",closeProj,Prj_Condo,name_serv);
			    				    	
			    	//----======== Generate Item List ============---//
			    	int itemLine = 0;
			    	for (int i=(maximumLine*page);i<vendorItem.size();i++) {
			    		
			    		    Hashtable data = (Hashtable) vendorItem.elementAt(i);
			    		    
			    		    //---========== If this item is for this vendor , print line ===========---//
			    		    itemLine++;
			    		    if (itemLine>maximumLine) break;
			    		    String dueNo = (String) data.get("dueNo");
			    		    String itemDesc = (String) data.get("comment");
			    		    String countDesc = (String) data.get("count_desc");
			    		    
			    		    cell = setCellAttribute(dueNo,microssfont_MINI,"C","M",numWidth,15);
			    		    cell.setFixedHeight(25);
			    		    table.addCell(cell);
			    		    
							cell = setCellAttribute(doString.MS874ToUnicode(itemDesc) ,microssfont_MINI,"L","M",itemWidth,15);
							cell.setFixedHeight(25);
							table.addCell(cell);
							
							double payAmnt = Double.parseDouble(doString.checkString((String) data.get("pay_amnt"),"0"));
							sumPayAmnt += payAmnt;
							
							cell = setCellAttribute(format.format(payAmnt),microssfont_MINI,"R","M",sumTotalWidth,15);
							cell.setFixedHeight(25);
							table.addCell(cell);	    		    
							
							
							cell = setCellAttribute(doString.MS874ToUnicode(countDesc),microssfont_MINI,"C","M",countWidth,15);
							cell.setFixedHeight(25);
							table.addCell(cell);
			    	} // end for i			   
			    	
			    	
			    	//----=============== Print Summary Line if data is finished ==================---// 
			    	boolean printFooter = false;
			    	if (itemLine<=maximumLine) {
			    		printFooter = true;
						cell = setCellAttribute(" ",microssfont_MINI,"C","M",numWidth,15);
						cell.setFixedHeight(20);
						table.addCell(cell);
			    		
						cell = setCellAttribute("รวม",microssfont_MINI,"R","M",itemWidth,15);
						cell.setFixedHeight(20);
						table.addCell(cell);
													
						cell = setCellAttribute(format.format(sumPayAmnt),microssfont_MINI,"R","M",sumTotalWidth,15);
						cell.setFixedHeight(20);
						table.addCell(cell);
						
							 
						cell = setCellAttribute(" ",microssfont_MINI,"C","M",countWidth,15);
						cell.setFixedHeight(20);
						table.addCell(cell);
							 
			    	}
			    	
			    	//---=========== Fill Blank Line if item data is less than maximum ========----//
			    	while (itemLine<maximumLine) {
			    		  cell = setCellAttribute(" ",microssfont_MED,"L","M",100,12);
			    		  cell.setFixedHeight(25);
			    		  table.addCell(cell);
			    		  itemLine++;
			    	}
			    	
			    	
			    	
			    	itemLine++;
			    	int commentLine = 0;
					//---=========== If This Last Page , Print Footer ===========----//
					if (printFooter) {
						cell = setCellAttribute("\n",new Font(bf,8,Font.NORMAL),"L","M",100,14);
						table.addCell(cell);
						
						if (itmType.equalsIgnoreCase("V")) {
							genVendorFooter(table,vendor[1],Prj_Condo,n_service);
						} else {
							genCommonFooter(table,vendor[1],Prj_Condo,n_service);
						}
					}
					
					
					//---======== Print Label Next Page if have more pages ========----//
					else {
						cell = setCellAttribute("\n",microssfont_MINI,"L","M",100,12);
						cell.setFixedHeight(itmType.equalsIgnoreCase("V") ? 90 : 120);
						table.addCell(cell);
						cell = setCellAttribute("\n",microssfont_MINI,"R","M",100,14);
						table.addCell(cell);
						cell = setCellAttribute("\nมีต่อหน้าถัดไป    ",microssfont_MINI,"R","M",100,0);
						table.addCell(cell);
					}
					
					
					document.add(table);
					document.newPage();
					
					
					page++;
					line += maximumLine;
			    	
			    } // end while
			
		} // end for loop
		
	}
	
	
	
	public void performTask(HttpServletRequest req,HttpServletResponse res) throws ServletException, IOException {
		 String mName = new String(this.getClass().getName()+".performTask: ");
		 System.out.println(mName+" start.");
		 
/*		 		 
		 //-----======= Check Login session ===========-----//
		 HttpSession session = req.getSession(false);
		 if (session == null) {
		 	 res.sendRedirect(Constants.WARNING_PAGE);
		 	 return;
		 }
		 Object obj = session.getAttribute("USER");
		 if (obj==null) {
		 	res.sendRedirect(Constants.WARNING_PAGE);
		 	return;
		 }
		 //-----=====================================-----//
		 
		 
		 User user = (User) obj;*/
		 doString str = new doString();
		 
		 iDocNo = doString.checkString(req.getParameter("docNo"),"");	 	
		 String printTarget = doString.checkString(req.getParameter("print_target"),"");
		 if (printTarget.equalsIgnoreCase("PAYMENT")) {
		 	  itemTable = "serv_infpayment";
		 } else {
		 	  itemTable = "serv_infdocdt";
		 }
		 
		 
		 StringBuffer sql = new StringBuffer();
		 Connection conn = null;
		 Statement stmt = null;
		 Statement stmt1 = null;
		 ResultSet rs = null;
		 ResultSet rs1 = null;
		 SERV_CommonData common = null;
		 
		 
		 try {
		 	
		 	 if (ds==null) getDS();
		 	 conn = ds.getConnection();
		 	 conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		 	 conn.setAutoCommit(true);
		 	 stmt = conn.createStatement();
		 	 stmt1 = conn.createStatement();
		 	 common = new SERV_CommonData(conn);
		 	 
		 	//-----================= Get Doc Header Detals ======================-----//
		 	Hashtable tmpHeader = common.getInfDocHeaderDetails(iDocNo);
		 	inFormEmp = doString.checkString((String) tmpHeader.get("inform_emp"),"");
			projDesc = doString.checkString((String) tmpHeader.get("proj_desc"),"");
			iCompany = doString.checkString((String) tmpHeader.get("i_company"),"");
			iProject = doString.checkString((String) tmpHeader.get("i_project"),"");
			cDesc = doString.checkString((String) tmpHeader.get("c_desc"),"");
			cDesc = str.replace(cDesc,"|break|","<br>");
			cDesc = str.replace(cDesc," ","&nbsp;");
			inFormDate = doString.checkString((String) tmpHeader.get("inform_date"),"");
			siteTel = doString.checkString((String) tmpHeader.get("site_tel"),"");
			dAppoint = doString.checkString((String) tmpHeader.get("d_appoint"),"");
			dEstClose = doString.checkString((String) tmpHeader.get("d_est_close"),"");
			//----==============================================================----//
			
			
			//---------------- Check Project is Condo ---------------					
				String emp_serv = "", name_serv = "", Prj_Condo = "", n_service = "";	
	
					sql.delete(0, sql.length());
					sql.append("select i_service_employ from lan:serv_infdochd ")
					   .append("where i_docno = '"+iDocNo+"'");
	 				rs = stmt.executeQuery(sql.toString());
					if (rs.next()) {
						emp_serv = doString.checkString(rs.getString("i_service_employ"));
					}	
					
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
					
					Prj_Condo = "N";
					sql.delete(0, sql.length());
					sql.append("select n_service from lan:acxprjdt ")
					   .append("where i_company = '"+iCompany+"' ")
					   .append("and i_project = '"+iProject+"' ");				 	
					rs = stmt.executeQuery(sql.toString());
					if (rs.next()==true) {
						n_service = doString.checkString(rs.getString("n_service"),"");
					} 
				
			//-----==================== Get Customer Detals ========================-----//		
			housePlan = "";
			houseId = "";
			iLock = "";
			iCustomer = "";
			guranteeDate = "";
			custName = "";
			custTel = "";			
			//----==============================================================----//
			


			//-----================== check project close or not ===================-----//
			boolean closeProj = false;
			sql.delete(0,sql.length());
			sql.append(" select * from lan:serv_clspj ")
				  .append(" where i_type='01' and i_company='").append(iCompany).append("'  ")
				  .append(" and i_project='").append(iProject).append("'  ");			
			rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
				closeProj = true;
			} else {
				closeProj = false;				
			}
			rs.close();



			//-----==================== Get Customer Detals ========================-----//
			Vector itmList = new Vector();
			Vector vendorList = new Vector();
			sql.delete(0,sql.length());
			sql.append("SELECT TRIM(b.n_itmjob)||'>>'||TRIM(c.n_itmjob)||'>>'||TRIM(a.n_itmjob) AS ITM_DESC, ")
				  .append(" a.n_count , a.z_wage_unit, a.z_good_unit, e.n_desc , t.n_desc AS ITEM_TYPE, f.bus_name , d.* from lan:").append(itemTable).append(" d ")
				  .append(" LEFT JOIN lan:serv_infboq a on a.i_itmjob = d.i_itmjob")
		          .append(" LEFT JOIN lan:serv_infboq b ON b.i_group = a.i_group AND b.i_type = '00' AND b.i_seq = '0000'")
		          .append(" LEFT JOIN lan:serv_infboq c ON c.i_group = a.i_group AND c.i_type = a.i_type AND c.i_seq = '0000'")				  
				  .append(" LEFT JOIN lan:serv_xstd e ON e.i_type = '08' AND e.i_code = d.i_itmjob_area")
				  .append(" LEFT JOIN lan:serv_xstd t ON t.i_type = '64' AND t.i_code = d.i_itmtype")
				  .append(" LEFT JOIN lan:stpvendr f ON f.vend_code = d.i_vendor")
				  .append(" WHERE d.i_docno = '").append(iDocNo).append("' AND d.f_itmstatus != 'CAN'");
			if (printTarget.equalsIgnoreCase("PAYMENT")) {
				sql.append(" ORDER BY d.i_itmjob, d.i_seq");
			} else {				  
				sql.append(" ORDER BY d.i_itmjob");
			}
			rs = stmt.executeQuery(sql.toString());
			while (rs.next()) {
				String dueNo = Integer.toString(rs.getInt("s_due"));
				String itmDesc = doString.checkString(rs.getString("itm_desc"),"");
				String cntDesc = doString.checkString(rs.getString("n_count"),"");
				String itemType = doString.checkString(rs.getString("item_type"),"");
				String ivendor = doString.checkString(rs.getString("i_vendor"),"");
				String nvendor = doString.checkString(rs.getString("bus_name"),"");
				String comment = doString.checkString(rs.getString("c_itmjob"),"");
				String area = doString.checkString(rs.getString("n_desc"),"");
				
				
				String unitWage = doString.checkString(rs.getString("q_wage_unit"),"");
				String priceWage = doString.checkString(rs.getString("z_wage_price"),"");
				String unitGoods = doString.checkString(rs.getString("q_good_unit"),"");
				String priceGoods = doString.checkString(rs.getString("z_good_price"),"");
				
				String estAmnt = doString.checkString(rs.getString("z_est_amt"),"");
				String payAmnt = doString.checkString(rs.getString("z_amount_pay"),"");
				String boq = "";
				double wage_boq = rs.getDouble("z_wage_unit");
				double goods_boq = rs.getDouble("z_good_unit");
				if (wage_boq > 0 || goods_boq > 0) {
					boq = "B";
				}
				//----============ Keep Data into Hashtable for used ===============----//
				Hashtable data = new Hashtable();
				data.put("boq",boq);
				data.put("dueNo", dueNo);
				data.put("item_desc",itmDesc);
				data.put("count_desc",cntDesc);
				data.put("item_type",itemType);
				data.put("i_vendor",ivendor);
				data.put("n_vendor",nvendor);
				data.put("comment",comment);
				data.put("area",area);
				data.put("unit_wage",unitWage);
				data.put("price_wage",priceWage);
				data.put("unit_goods",unitGoods);
				data.put("price_goods",priceGoods);
				data.put("est_amnt", estAmnt);
				data.put("pay_amnt", payAmnt);
				itmList.addElement(data);
				//-----========== Keep Vendor into vector ==========----//
				boolean exist = false;
				for (int k=0;k<vendorList.size();k++) {
					   String[] chk = (String[]) vendorList.elementAt(k);
					   if (chk[0].equalsIgnoreCase(ivendor)) {
					   	   exist = true;
					   	   break;
					   }
				}
				if (!exist) {
					 vendorList.addElement(new String[] {ivendor,nvendor}); 
				}
			}
			rs.close();
			//----==============================================================----//
		



		    //----=============== Initilize Variables for create PDF ===================---//
		    bf = BaseFont.createFont(Constants.FONT_ANGSANA_NORMAL,BaseFont.IDENTITY_H,BaseFont.NOT_EMBEDDED);
			bfb = BaseFont.createFont(Constants.FONT_ANGSANA_BOLD,BaseFont.IDENTITY_H,BaseFont.NOT_EMBEDDED);
		    microssfont = new Font(bf,14,Font.NORMAL);
			microssfont_MINI = new Font(bf,10,Font.NORMAL);
			microssfont_MED = new Font(bf,12,Font.NORMAL);
			microssfont_MED_BOLD = new Font(bf,12,Font.BOLD);
			microssfont_MED_BOLD_UNDERLINE = new Font(bfb,12,Font.UNDERLINE);
			microssfont_BOLD = new Font(bfb,14,Font.NORMAL);
			microssfont_BOLD_UNDERLINE = new Font(bfb,14,Font.UNDERLINE);
			microssfont_HD = new Font(bfb,16,Font.NORMAL);
			
			Document document = new Document(PageSize.A4,30,30,10,10);
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			PdfWriter writer = PdfWriter.getInstance(document,baos);
			PdfContentByte cb = writer.getDirectContent();
			
			PdfReader reader = new PdfReader(Constants.PDF_HEADER_TEMPLATE);
			PdfImportedPage page1 = writer.getImportedPage(reader,1);
			
			document.open();
			
			PdfPTable table;
			PdfPCell cell;		 
		 
			 //----==================== For Page 2 , For Vendor =====================----//
			 table = new PdfPTable(100);
			 generateItemList("V",vendorList,itmList,document,cb,page1,table,closeProj,Prj_Condo,name_serv,n_service);
			 //----==============================================================----//
			 
			 
			 			 
			 //----=================== For Page 3 , For Employee ===================----//
			 table = new PdfPTable(100);
			 generateItemList("E",vendorList,itmList,document,cb,page1,table,closeProj,Prj_Condo,name_serv,n_service);
			 //----=============================================================----//
			 
			 
			 
			 
			 //----============== generate PDF to Browser ===============-----//
			 document.close();
			 res.setContentType("application/pdf");
			 res.setContentLength(baos.size());
			 ServletOutputStream outServ = res.getOutputStream();
			 baos.writeTo(outServ);
			 outServ.flush();
			 
			 
			 stmt.close();
			 stmt1.close();
			 conn.close();
			 stmt=null;
			 stmt1=null;
			 conn=null;
		} catch (Exception e) {
		 	System.out.println(" ERROR "+mName+" : "+e.getMessage());
			System.out.println(" ERROR "+mName+" SQL : "+sql.toString());
 		 } finally {
 		 	  try{
  		 	  	    if (rs!=null) rs.close();
					if (rs1!=null) rs1.close();
					if (stmt!=null) stmt.close();
					if (stmt1!=null) stmt1.close();
					if (conn!=null) conn.close();
 		      } catch (SQLException ignore) {}
		 }
	
	
	
	    System.out.println(mName+" end.");
	
	}
	
	

}