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

  

//2015.12.23 modify change table  acxprjdt to serv_prjdt
//modify by sompoch 2023.02.22
//modify by pradoem 2024.03.14  fix bug support DEFAULT_MANAGER LH-north east #G12,LH-Nort#G05
public class SERV_PrintOpenJobServlet extends DBServlet  {

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
	int numWidth = 4;
	int itemWidth = 45;
	int countWidth = 7;
	int qWageWidth = 6;
	int zWageWidth = 6;
	int tWageWidth = 6;
	int qGoodsWidth = 6;
	int zGoodsWidth = 6;
	int tGoodsWidth = 6;
	int sumTotalWidth = 8;
	
	
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
	
	public void genReportHeader(PdfContentByte cb,PdfImportedPage page1,PdfPTable table,String repType,String nVendor,String showPage,boolean closeProj,String Prj_Condo,String name_serv,String n_service,String empname,String call_center) throws Exception {
		  PdfPCell cell;
		  
		  String msg = "";
		  String msgHeader = "";
		  if (repType.equalsIgnoreCase("C")) {
			  msg = "สำหรับลูกค้า "+showPage;
			  msgHeader = "ใบแจ้งรายการซ่อม";
		  } else if (repType.equalsIgnoreCase("V")) {
			msg = "สำหรับผู้รับเหมา "+showPage;
			msgHeader = "ใบสั่งงานซ่อม";
		  } else {
			msg = "สำหรับเจ้าหน้าที่ "+showPage;
			msgHeader = "ใบแจ้งรายการซ่อม";
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
		  //Remark by pradoem 2015.09.02
		  //cell = setCellAttribute("Print Date : "+currDate,microssfont_MED,"L","T",50,0);
		  //table.addCell(cell);
		  cell = setCellAttribute(msg,microssfont_MED,"R","T",50,0);
		  table.addCell(cell);
		  cell = setCellAttribute((closeProj ? "โครงการปิด" : "")+"\n\n\n\n",microssfont_HD,"R","T",100,0);
		  table.addCell(cell);
		  cell = setCellAttribute(msgHeader+"\n\n",microssfont_HD,"C","M",100,0);
		  table.addCell(cell);

		  
		  //----================ Set Report Header ===========----//
		cell = setCellAttribute("โครงการ : "+doString.MS874ToUnicode(projDesc),microssfont_MED,"L","M",leftColumnWidth,0);
		table.addCell(cell);		  
		cell = setCellAttribute("เลขที่ใบแจ้งซ่อม : "+iDocNo,microssfont_MED,"L","M",rightColumnWidth,0);
		table.addCell(cell);
		
		cell = setCellAttribute("บ้านเลขที่ : "+doString.MS874ToUnicode(houseId)+"      แปลง : "+doString.MS874ToUnicode(iLock),microssfont_MED,"L","M",leftColumnWidth,0);
		table.addCell(cell);		  
		cell = setCellAttribute("แบบบ้าน : "+doString.MS874ToUnicode(housePlan),microssfont_MED,"L","M",rightColumnWidth,0);
		table.addCell(cell);
		
		cell = setCellAttribute("วันที่รับเรื่องงานซ่อม : "+inFormDate,microssfont_MED,"L","M",leftColumnWidth,0);
		table.addCell(cell);		  
		cell = setCellAttribute("วันหมดอายุประกัน : "+guranteeDate,microssfont_MED,"L","M",rightColumnWidth,0);
		table.addCell(cell);
		  
		cell = setCellAttribute("วันที่นัดซ่อม : "+dAppoint,microssfont_MED,"L","M",leftColumnWidth,0);
		table.addCell(cell);		  
		cell = setCellAttribute("วันที่คาดว่าจะเสร็จ : "+dEstClose,microssfont_MED,"L","M",rightColumnWidth,0);
		table.addCell(cell);
				
		cell = setCellAttribute("ชื่อลูกค้า / ผู้แจ้ง : "+doString.MS874ToUnicode((custName.length()>0 ?custName+" / " : "")+nCustomer),microssfont_MED,"L","M",leftColumnWidth,0);
		table.addCell(cell);		 
		 
		cell = setCellAttribute("เบอร์ติดต่อ : "+doString.MS874ToUnicode((custTel.length()>0 ? custTel+" / " : "")+nCustTel),microssfont_MED,"L","M",rightColumnWidth,0);
		table.addCell(cell);
		
		
	if(Prj_Condo.equals("Y")){	
		cell = setCellAttribute("ชื่อผู้รับผิดชอบงานซ่อม : "+doString.MS874ToUnicode(name_serv),microssfont_MED,"L","M",leftColumnWidth,0);
	} else {
		cell = setCellAttribute("ชื่อผู้รับผิดชอบงานซ่อม : "+doString.MS874ToUnicode(empname),microssfont_MED,"L","M",leftColumnWidth,0);  //inFormEmp, n_service
	}		
		table.addCell(cell);		  
		
	
		/*if(Prj_Condo.equals("Y")){
				cell = setCellAttribute("เบอร์เจ้าหน้าที่ : "+doString.MS874ToUnicode(siteTel),microssfont_MED,"L","M",rightColumnWidth,0);
		} else {*/
				cell = setCellAttribute("เบอร์เจ้าหน้าที่ : "+doString.MS874ToUnicode(call_center),microssfont_MED,"L","M",rightColumnWidth,0);
		//}
				table.addCell(cell);		

		//----================ Add Header Table for Customer Report ===========----//\
		if (repType.equalsIgnoreCase("C")) {
			cell = setCellAttribute("\n",microssfont_MED,"C","M",100,0);
			table.addCell(cell);		  
			cell = setCellAttribute("รายการที่",microssfont_BOLD,"C","M",10,15);
			cell.setFixedHeight(22);
			table.addCell(cell);		  
			cell = setCellAttribute("รายการซ่อม",microssfont_BOLD,"C","M",90,15);
			cell.setFixedHeight(22);
			table.addCell(cell);		  
		}
		
		
		
		//----================= Add Header Table for Vendor & Employee ==============----//
		else {
		if(!Prj_Condo.equals("Y")){	
			if (repType.equalsIgnoreCase("V")) {
				cell = setCellAttribute("ผู้รับเหมาที่รับผิดชอบ : "+doString.MS874ToUnicode(nVendor),microssfont_MED,"L","M",leftColumnWidth,0);
				table.addCell(cell);					  
				cell = setCellAttribute("ผู้รับเหมาสร้าง : "+doString.MS874ToUnicode(responseProject),microssfont_MED,"L","M",rightColumnWidth,0);			
				table.addCell(cell);		
			} else {				
				cell = setCellAttribute("ผู้รับเหมาสร้าง : "+doString.MS874ToUnicode(responseProject),microssfont_MED,"L","M",leftColumnWidth,0);			  
				table.addCell(cell);		  
				cell = setCellAttribute(" ",microssfont_MED,"L","M",rightColumnWidth,0);
				table.addCell(cell);		
			}
		}// end if Prj_Condo

			cell = setCellAttribute("\n",microssfont_MED,"C","M",100,0);
			table.addCell(cell);
					  
			cell = setCellAttribute("No.",microssfont_MED,"C","M",numWidth,13);
			cell.setFixedHeight(22);
			table.addCell(cell);		  
			cell = setCellAttribute("รายการซ่อม",microssfont_MED,"C","M",itemWidth,13);
			cell.setFixedHeight(22);
			table.addCell(cell);		  
			cell = setCellAttribute("จำนวนนับ",microssfont_MINI,"C","M",countWidth,13);
			cell.setFixedHeight(22);
			table.addCell(cell);		  
			cell = setCellAttribute("ค่าแรง",microssfont_MINI,"C","M",qWageWidth+zWageWidth+tWageWidth,15);
			cell.setFixedHeight(22);
			table.addCell(cell);		  
			cell = setCellAttribute("ค่าของ",microssfont_MINI,"C","M",qGoodsWidth+zGoodsWidth+tGoodsWidth,15);
			cell.setFixedHeight(22);
			table.addCell(cell);		  
			cell = setCellAttribute("รวมเงิน",microssfont_MED,"C","M",sumTotalWidth,13);
			cell.setFixedHeight(22);
			table.addCell(cell);		  

			cell = setCellAttribute(" ",microssfont_MED,"C","M",numWidth,14);
			cell.setFixedHeight(22);
			table.addCell(cell);		  
			cell = setCellAttribute(" ",microssfont_MED,"C","M",itemWidth,14);
			cell.setFixedHeight(22);
			table.addCell(cell);		  
			cell = setCellAttribute(" ",microssfont_MED,"C","M",countWidth,14);
			cell.setFixedHeight(22);
			table.addCell(cell);		  
			cell = setCellAttribute("ต่อหน่วย",microssfont_MINI,"C","M",qWageWidth,15);
			cell.setFixedHeight(22);
			table.addCell(cell);		  
			cell = setCellAttribute("จำนวน",microssfont_MINI,"C","M",zWageWidth,15);
			cell.setFixedHeight(22);
			table.addCell(cell);		  
			cell = setCellAttribute("รวม",microssfont_MINI,"C","M",tWageWidth,15);
			cell.setFixedHeight(22);
			table.addCell(cell);		  
			cell = setCellAttribute("ต่อหน่วย",microssfont_MINI,"C","M",qGoodsWidth,15);
			cell.setFixedHeight(22);
			table.addCell(cell);		  
			cell = setCellAttribute("จำนวน",microssfont_MINI,"C","M",zGoodsWidth,15);
			cell.setFixedHeight(22);
			table.addCell(cell);		  
			cell = setCellAttribute("รวม",microssfont_MINI,"C","M",tGoodsWidth,15);
			cell.setFixedHeight(22);
			table.addCell(cell);		  
			cell = setCellAttribute(" ",microssfont_MED,"C","M",sumTotalWidth,14);
			cell.setFixedHeight(22);
			table.addCell(cell);		  	 			

		} // end if check repType
		
		
	}
	
	private static String GetLocalGroupByProject(Statement stmt, String comId, String projectId) {
		StringBuffer sql = new StringBuffer();	
		//Statement stmt = null;
		ResultSet rs = null;
		String  groupName = "";
        try{
        	//initial paramter	     	
			/*************************************************/			
        	//*****Find project by user login  
			sql.delete(0,sql.length());
			sql.append(" select a.i_type from lan:serv_local a where  a.i_company = '"+comId+"' and  a.i_project = '"+projectId+"' ");
			//System.out.println("SQL :"+sql.toString());
			rs = stmt.executeQuery(sql.toString());
			if(rs.next()){
				groupName = doString.checkString(rs.getString("i_type"), "");
			}
			rs.close();		   			
			//**************************************************/
			if("".equals(groupName)){
				groupName = "LH";
			}
		  	//System.out.println("##GetLocalGroupByProject ->successfully.");				  	 
		  	return groupName;			  	 
		}catch(Exception e){
			System.out.println("!!! GetLocalGroupByProject ,  : " + e.getMessage());
			System.out.println("!!! SQL Exception: "+sql.toString());		
			return "";
		}
		finally{			
			//clean up.
			try{
				if(rs!=null){rs.close();}
			}catch(Exception e){}
		}
	}
	
	//--- 2023-01-31 , new footer function ---//
	//modify by pradoem 2024.03.14
	public void genEmployCommonFooter(Statement stmt,PdfPTable table,String empname) throws Exception {
		PdfPCell cell;
		StringBuffer sql = new StringBuffer();
		ResultSet rs = null;
		
		//--- find manager ---//
		String servManager = "";
		
		String groupLocal = GetLocalGroupByProject(stmt, iCompany, iProject);
		String defaultManager = getPropValue("DEFAULT_MANAGER_"+groupLocal) ;//"1692-0";
		if("".equals(defaultManager)){
			defaultManager = getPropValue("DEFAULT_MANAGER_LH");//default to techin
		}
		
		sql.delete(0, sql.length());
		sql.append(" select e.* from lan:serv_lstaff s ")
		   .append(" left join docflow:acemploy e on e.i_employ=nvl(s.i_employ_m1,'"+defaultManager+"') ") // default to techin
		   .append(" where s.i_company = '"+iCompany+"'  and s.i_project = '"+iProject+"' ");
		rs = stmt.executeQuery(sql.toString());
		if (rs.next()) {
			servManager  = doString.checkString(doString.DisplayThai(rs.getString("n_prename_th")),"");
			servManager += doString.checkString(doString.DisplayThai(rs.getString("n_nemploy_th")),"");
			servManager += " "+doString.checkString(doString.DisplayThai(rs.getString("n_semploy_th")),"");		
		}
		rs.close();	
		
		if (servManager.trim().length()<=0) {
			sql.delete(0, sql.length());
			sql.append(" select * from docflow:acemploy where i_employ='"+defaultManager+"' "); // default to techin
			rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
				servManager  = doString.checkString(doString.DisplayThai(rs.getString("n_prename_th")),"");
				servManager += doString.checkString(doString.DisplayThai(rs.getString("n_nemploy_th")),"");
				servManager += " "+doString.checkString(doString.DisplayThai(rs.getString("n_semploy_th")),"");		
			}
			rs.close();				
		}

		
		//----============ Footer of document =============----//
		cell = setCellAttribute("\n",microssfont_MINI,"C","M",100,12); // set blank space
		cell = setCellAttribute("\n",microssfont_MINI,"L","M",50,13);
		table.addCell(cell);
		cell = setCellAttribute("\n",microssfont_MINI,"L","M",50,13);
		table.addCell(cell);
		
		cell = setCellAttribute(doString.MS874ToUnicode(doString.checkString(empname,"-")),microssfont_MINI,"C","M",50,12);
		table.addCell(cell);
		cell = setCellAttribute(doString.MS874ToUnicode(doString.checkString(servManager,"-")),microssfont_MINI,"C","M",50,12);
		table.addCell(cell);
		cell = setCellAttribute("เจ้าหน้าที่ควบคุมงานซ่อม\n",microssfont_MINI,"C","M",50,12);
		table.addCell(cell);
		cell = setCellAttribute("ผู้จัดการส่วนบริการ\n",microssfont_MINI,"C","M",50,12);
		table.addCell(cell);
		cell = setCellAttribute("\n",microssfont_MINI,"C","M",50,14);
		table.addCell(cell);
		cell = setCellAttribute("\n",microssfont_MINI,"C","M",50,14);
		table.addCell(cell);
	}
		
	public void genCommonFooter(PdfPTable table,String vendorSign,String Prj_Condo,String n_service,String empname,String name_serv) throws Exception {
		PdfPCell cell;

		//----============ Footer of document =============----//
		cell = setCellAttribute("ส่วนของลูกค้า",microssfont_MINI,"L","M",50,13);
		table.addCell(cell);
		cell = setCellAttribute("ส่วนของบริษัท",microssfont_MINI,"L","M",50,13);
		table.addCell(cell);
		
		cell = setCellAttribute("\n................................................................................. ผู้แจ้ง",microssfont_MINI,"C","M",50,12);
		table.addCell(cell);
		
		if(Prj_Condo.equals("Y")){	
			cell = setCellAttribute("\n................................................................................. เจ้าหน้าที่รับเรื่อง",microssfont_MINI,"C","M",50,12);	
		}else {
			cell = setCellAttribute("\n                "+doString.MS874ToUnicode(name_serv)+"                    เจ้าหน้าที่รับเรื่อง",microssfont_MINI,"C","M",50,12);// Service Center
		}
		table.addCell(cell);
		
		
		cell = setCellAttribute("("+doString.MS874ToUnicode((nCustomer.length()>0 ? nCustomer : custName))+")\n\n",microssfont_MINI,"C","M",50,12);
		table.addCell(cell);		
		
		if(Prj_Condo.equals("Y")){		
			cell = setCellAttribute("("+doString.MS874ToUnicode(n_service)+")\n\n",microssfont_MINI,"C","M",50,12);
		}else{
			//cell = setCellAttribute("("+doString.MS874ToUnicode(empname)+")\n\n",microssfont_MINI,"C","M",50,12);
			cell = setCellAttribute(" เซอร์วิสเซ็นเตอร์ \n\n",microssfont_MINI,"C","M",50,12);
		}
		table.addCell(cell);
			
	
		cell = setCellAttribute("\n................................................................................. ผู้ตรวจรับงาน",microssfont_MINI,"C","M",50,12);
		table.addCell(cell);
		cell = setCellAttribute("\n................................................................................. เจ้าหน้าที่ควบคุมงานซ่อม",microssfont_MINI,"C","M",50,12); 		                                            
		table.addCell(cell);
		
		cell = setCellAttribute("("+doString.MS874ToUnicode((nCustomer.length()>0 ? nCustomer : custName))+")\n\n",microssfont_MINI,"C","M",50,14);
		table.addCell(cell);
			
			
		if(Prj_Condo.equals("Y")){	
			cell = setCellAttribute("("+doString.MS874ToUnicode(n_service)+")\n\n",microssfont_MINI,"C","M",50,14);
		}else{			
			cell = setCellAttribute("("+doString.MS874ToUnicode(empname)+")\n\n",microssfont_MINI,"C","M",50,14); // login name
		}
		
		table.addCell(cell);	
	}
	
	
	public void genVendorFooter(PdfPTable table,String nVendor,String Prj_Condo,String n_service,String empname,String name_serv) throws Exception {
		PdfPCell cell;
				
		cell = setCellAttribute("ลงชื่อผู้รับเหมารับงาน",microssfont_MED_BOLD,"C","M",50,12);
		table.addCell(cell);
		cell = setCellAttribute("ลงชื่อเจ้าหน้าที่ผู้จ่ายงาน",microssfont_MED_BOLD,"C","M",50,12);
		table.addCell(cell);
		
		cell = setCellAttribute("\n.................................................................................",microssfont_MINI,"C","M",50,12);
		table.addCell(cell);
		cell = setCellAttribute("\n.................................................................................",microssfont_MINI,"C","M",50,12); 		                                            
		table.addCell(cell);
		
		cell = setCellAttribute("("+doString.MS874ToUnicode(nVendor)+")\n\n",microssfont_MINI,"C","M",50,14);
		table.addCell(cell);
		
	if(Prj_Condo.equals("Y")){	
		cell = setCellAttribute("("+doString.MS874ToUnicode(n_service)+")\n\n",microssfont_MINI,"C","M",50,14);
	}else{		
		cell = setCellAttribute("("+doString.MS874ToUnicode(empname)+")\n\n",microssfont_MINI,"C","M",50,14);
	}
		table.addCell(cell);	
	} 
	
	
	
	public void generateItemList(Statement stmt,String itmType,Vector vendorList,Vector itmList,Document document,PdfContentByte cb,PdfImportedPage page1,PdfPTable table,boolean closeProj,String Prj_Condo,String name_serv,String n_service,String empname,String call_center) throws Exception {
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
				double sumWage = 0;
				double sumGoods = 0;
				double sumTotal = 0;
			    
			    
				while (line<vendorItem.size()) {
					//----======== Start New Page =============----//
					table = new PdfPTable(100);
					table.setWidthPercentage(100);
					cb.addTemplate(page1,1,1);
					genReportHeader(cb,page1,table,itmType,vendor[1],"("+(page+1)+"/"+maxPage+")",closeProj,Prj_Condo,name_serv,n_service,empname,call_center);
			    				    	
					//----======== Generate Item List ============---//
					int itemLine = 0;
					for (int i=(maximumLine*page);i<vendorItem.size();i++) {
							Hashtable data = (Hashtable) vendorItem.elementAt(i);
			    		    
							//---========== If this item is for this vendor , print line ===========---//
							itemLine++;
							if (itemLine>maximumLine) break;
			    		    
							String itemDesc = (String) data.get("item_desc");
							String remarkDiff = "";
							if (itemDesc.indexOf("*")==0) remarkDiff = "* ";
							itemDesc = itemDesc.indexOf(">>")>0 ? itemDesc.substring(itemDesc.lastIndexOf(">>")+2) : itemDesc;
							String countDesc = (String) data.get("count_desc");
			    		    
							cell = setCellAttribute(Integer.toString(i+1),microssfont_MINI,"C","M",numWidth,15);
							cell.setFixedHeight(25);
							table.addCell(cell);
							cell = setCellAttribute(doString.MS874ToUnicode(remarkDiff+itemDesc) ,microssfont_MINI,"L","M",itemWidth,15);
							cell.setFixedHeight(25);
							table.addCell(cell);
							cell = setCellAttribute(doString.MS874ToUnicode(countDesc),microssfont_MINI,"C","M",countWidth,15);
							cell.setFixedHeight(25);
							table.addCell(cell);
							
							double qWage = Double.parseDouble(doString.checkString((String) data.get("unit_wage"),"0"));
							double zWage = Double.parseDouble(doString.checkString((String) data.get("price_wage"),"0"));
							double qGoods = Double.parseDouble(doString.checkString((String) data.get("unit_goods"),"0"));
							double zGoods = Double.parseDouble(doString.checkString((String) data.get("price_goods"),"0"));
							sumWage += (qWage*zWage);
							sumGoods += (qGoods*zGoods);
							
							cell = setCellAttribute(format.format(qWage),microssfont_MINI,"R","M",qWageWidth,15);
							cell.setFixedHeight(25);
							table.addCell(cell);
							cell = setCellAttribute(format.format(zWage),microssfont_MINI,"R","M",zWageWidth,15);
							cell.setFixedHeight(25);
							table.addCell(cell);
							cell = setCellAttribute(format.format((qWage*zWage)),microssfont_MINI,"R","M",tWageWidth,15);
							cell.setFixedHeight(25);
							table.addCell(cell);
							cell = setCellAttribute(format.format(qGoods),microssfont_MINI,"R","M",qGoodsWidth,15);
							cell.setFixedHeight(25);
							table.addCell(cell);
							cell = setCellAttribute(format.format(zGoods),microssfont_MINI,"R","M",zGoodsWidth,15);
							cell.setFixedHeight(25);
							table.addCell(cell);
							cell = setCellAttribute(format.format((qGoods*zGoods)),microssfont_MINI,"R","M",tGoodsWidth,15);
							cell.setFixedHeight(25);
							table.addCell(cell);							
							cell = setCellAttribute(format.format((qWage*zWage)+(qGoods*zGoods)),microssfont_MINI,"R","M",sumTotalWidth,15);
							cell.setFixedHeight(25);
							table.addCell(cell);	    		    
			    		    
					} // end for i			   
			    	
			    	
					//----=============== Print Summary Line if data is finished ==================---// 
					boolean printFooter = false;
					if (itemLine<=maximumLine) {
						printFooter = true;
						cell = setCellAttribute("รวม    ",microssfont_MINI,"L","M",numWidth+itemWidth+countWidth,15);
						cell.setFixedHeight(20);
						table.addCell(cell);							
						cell = setCellAttribute(" ",microssfont_MINI,"R","M",qWageWidth,15);
						cell.setFixedHeight(20);
						table.addCell(cell);
						cell = setCellAttribute(" ",microssfont_MINI,"R","M",zWageWidth,15);
						cell.setFixedHeight(20);
						table.addCell(cell);
						cell = setCellAttribute(format.format(sumWage),microssfont_MINI,"R","M",tWageWidth,15);
						cell.setFixedHeight(20);
						table.addCell(cell);
						cell = setCellAttribute(" ",microssfont_MINI,"R","M",qGoodsWidth,15);
						cell.setFixedHeight(20);
						table.addCell(cell);
						cell = setCellAttribute(" ",microssfont_MINI,"R","M",zGoodsWidth,15);
						cell.setFixedHeight(20);
						table.addCell(cell);
						cell = setCellAttribute(format.format(sumGoods),microssfont_MINI,"R","M",tGoodsWidth,15);
						cell.setFixedHeight(20);
						table.addCell(cell);							
						cell = setCellAttribute(format.format(sumWage+sumGoods),microssfont_MINI,"R","M",sumTotalWidth,15);
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

					//----============= Generate Remark =============----//
					cell = setCellAttribute("หมายเหตุ",microssfont_MED,"L","M",100,13);
					table.addCell(cell);
					itemLine++;
			    	
					int commentLine = 0;
					for (int i=(maximumLine*page);i<vendorItem.size();i++) {
						   Hashtable data = (Hashtable) vendorItem.elementAt(i);
			    		   
						   //----========== Id this item is for this vendor , print line ==========----//
						   commentLine++;
						   if (commentLine>maximumLine) break;
			    		   
						   String comment = (String) data.get("comment");
						   String area = (String) data.get("area");
						   cell = setCellAttribute("รายการที่ "+(i+1)+". "+doString.MS874ToUnicode(comment)+"   บริเวณ : "+doString.MS874ToUnicode(area),microssfont_MED,"L","M",100,12);
						   cell.setFixedHeight(18);
						   table.addCell(cell);
			    		   
					} // end for i
   	 	
					//---=========== Fill Blank Line if comment is less than maximum ========----//
					while (commentLine<maximumLine) {
						  cell = setCellAttribute(" ",microssfont_MED,"L","M",100,12);
						  cell.setFixedHeight(18);
						  table.addCell(cell);
						 commentLine++;
					}			
	
					//---=========== If This Last Page , Print Footer ===========----//
					if (printFooter) {
						cell = setCellAttribute("\n",new Font(bf,8,Font.NORMAL),"L","M",100,14);
						table.addCell(cell);
						
						if (itmType.equalsIgnoreCase("V")) {
							genVendorFooter(table,vendor[1],Prj_Condo,n_service,empname,name_serv);
						} else {
							//--- 2023-01-31 , employee use new footer ---// 
							//genCommonFooter(table,vendor[1],Prj_Condo,n_service,empname,name_serv);
							genEmployCommonFooter(stmt,table,empname);
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
		 
		   /******************Session User Check************************/
			HttpSession session = req.getSession(false);
		    if (session == null) {
		        /** Redirect user to login page if there's no session.*/
		        res.sendRedirect(req.getContextPath()+"/login.jsp");
		        return;
		    }
		    Object obj = session.getAttribute("USER");
		    if (obj == null) {
		    	System.out.println("----->User is null");
		        /** Redirect user to login page if there's no session.*/
		        res.sendRedirect(req.getContextPath()+"/login.jsp");
		        return;
		    }		    
			User user = (User) obj;	
			
			//String empname = user.getEmpName(); // 2023-01-31 , cancel get name from login
			String empname = "";
			/******************Session User Check************************/

		
		 doString str = new doString();
		 
		 //iDocNo = doString.checkString(req.getParameter("i_docno"),"");	 
		// String empname = doString.checkString(req.getParameter("empname"),"");
		 String docNoList[] = req.getParameterValues("i_docno");
		 String printTarget = doString.checkString(req.getParameter("print_target"),"");
		 if (printTarget.equalsIgnoreCase("PAYMENT")) {
			  itemTable = "serv_payment";
		 } else {
			  itemTable = "serv_docdt";
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
			 conn.setAutoCommit(false);
			 stmt = conn.createStatement();
			 stmt1 = conn.createStatement();
			 common = new SERV_CommonData(conn);
		 	 
 
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
		 	 
		 	 
			 //---================ Save Print Date to SERV_DOCHD ===============----//

			if (docNoList!=null && docNoList.length>0) {
			   for (int loop=0;loop<docNoList.length;loop++) {
						 iDocNo = doString.checkString(docNoList[loop],"");
						//============================== 15/06/2010 - add i_docno loop =============================//		
						 
						//-----================= Get Doc Header Detals ======================-----//						
						Hashtable tmpHeader = common.getDocHeaderDetails(iDocNo);
						inFormEmp = doString.checkString((String) tmpHeader.get("inform_emp"),"");
						projDesc = doString.checkString((String) tmpHeader.get("proj_desc"),"");
						iCompany = doString.checkString((String) tmpHeader.get("i_company"),"");
						iProject = doString.checkString((String) tmpHeader.get("i_project"),"");
						nCustomer = doString.checkString((String) tmpHeader.get("n_customer"),"");
						nCustTel = doString.checkString((String) tmpHeader.get("n_cust_tel"),"");
						iLock = doString.checkString((String) tmpHeader.get("i_lock"),"");
						cDesc = doString.checkString((String) tmpHeader.get("c_desc"),"");
						cDesc = str.replace(cDesc,"|break|","<br>");
						cDesc = str.replace(cDesc," ","&nbsp;");
						inFormDate = doString.checkString((String) tmpHeader.get("inform_date"),"");
						responseProject = doString.checkString((String) tmpHeader.get("response_emp"),"");
						siteTel = doString.checkString((String) tmpHeader.get("site_tel"),"");
						dAppoint = doString.checkString((String) tmpHeader.get("d_appoint"),"");
						dEstClose = doString.checkString((String) tmpHeader.get("d_est_close"),"");
						String user_name = "", user_emp = "";
						//----==============================================================----//
						
						
						//--- 2023-01-31 , new method for find staff name ---//
						empname = "";
						sql.delete(0, sql.length());
						sql.append(" select e.*  from lan:serv_flow f ")
						   .append(" left join lan:useracl u on u.user_id=f.i_approve and u.user_acl='S' ")
						   .append(" left join docflow:acemploy e on e.i_employ=u.i_employ ")
						   .append(" where f_itmstatus  = '100' and i_docno = '"+iDocNo+"' ");
						rs = stmt.executeQuery(sql.toString());
						if (rs.next()) {
							empname  = doString.checkString(doString.DisplayThai(rs.getString("n_prename_th")),"");
							empname += doString.checkString(doString.DisplayThai(rs.getString("n_nemploy_th")),"");
							empname += " "+doString.checkString(doString.DisplayThai(rs.getString("n_semploy_th")),"");		
						}
						rs.close();		
						
						
						//---------------- Check Project is Condo ---------------					
							String emp_serv = "", name_serv = "", Prj_Condo = "", n_service = "", call_center = "";	
				
								sql.delete(0, sql.length());
								sql.append("select i_service_employ from lan:serv_dochd ")
								   .append("where i_docno = '"+iDocNo+"' ");
								rs = stmt.executeQuery(sql.toString());
								if (rs.next()) {
									emp_serv = doString.checkString(rs.getString("i_service_employ"),"");
								}
								rs.close();
								
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
											rs.close();
											
								} else {
							
											sql.delete(0, sql.length());
											sql.append("select distinct i_cust, n_name, n_sname ")
												 .append("from lan:serv_cname ")
												 .append("where i_cust = '"+emp_serv+"' ");		
											rs = stmt.executeQuery(sql.toString());
											if (rs.next()) {
												name_serv = doString.checkString(doString.DisplayThai(rs.getString("n_name")))+" "+doString.checkString(doString.DisplayThai(rs.getString("n_sname")));
											}
											rs.close();
										
								}// end if search Data 
								
								Prj_Condo = "N";
								sql.delete(0, sql.length());
								sql.append("select * from lan:serv_condo ")
								   .append("where i_company = '"+iCompany+"' ")
								   .append("and i_project = '"+iProject+"' ");				 	
								rs = stmt.executeQuery(sql.toString());
								if (rs.next()==true) {
									Prj_Condo = "Y";
								}
								rs.close();
								
								sql.delete(0, sql.length());
								sql.append("select i_tel from lan:serv_prjdt ")
								   .append("where i_company = 'LH' ")
								   .append("and i_project = '099' ");				 	
								rs = stmt.executeQuery(sql.toString());
								if (rs.next()==true) {
									call_center = doString.checkString(rs.getString("i_tel"),"");
								}
								rs.close();

								//----------------- n_service for condo site ----------------					
								 sql.delete(0, sql.length());
								 sql.append("select distinct i_approve from lan:serv_flow ")
									.append("where i_docno = '"+iDocNo+"' ")
									.append("and f_itmstatus = '100' ");
								 rs = stmt.executeQuery(sql.toString());
								 if (rs.next()==true) {
									user_name = doString.checkString(rs.getString("i_approve"),"");
								 }
								 rs.close();
								 
								 sql.delete(0, sql.length());
								 sql.append("select distinct i_employ from docflow:useracl ")
									.append("where user_id = '"+user_name+"' ");
								 rs = stmt.executeQuery(sql.toString());
								 if (rs.next()==true) {
									 user_emp = doString.checkString(rs.getString("i_employ"),"");
								 }
								 rs.close();
								 
								 sql.delete(0, sql.length());
								 sql.append("select distinct n_prename_th, n_nemploy_th, n_semploy_th ")
									  .append("from docflow:acemploy ")
									  .append("where i_employ = '"+user_emp+"' ");		
								 rs = stmt.executeQuery(sql.toString());
								 if (rs.next()) {
									n_service = doString.checkString(doString.DisplayThai(rs.getString("n_prename_th")))+doString.checkString(doString.DisplayThai(rs.getString("n_nemploy_th")))+" "+doString.checkString(doString.DisplayThai(rs.getString("n_semploy_th")));
								 }
								 rs.close();
							
						//-----==================== Get Customer Detals ========================-----//		
						Hashtable tmpCust = common.getCustomerDetails(iCompany,iProject,iLock);						
						housePlan = doString.checkString((String) tmpCust.get("i_model"),"");
						houseId = doString.checkString((String) tmpCust.get("i_house"),"");
						iLock = doString.checkString((String) tmpCust.get("i_lock"),"");
						iCustomer = doString.checkString((String) tmpCust.get("i_customer"),"");
						guranteeDate = doString.checkString((String) tmpCust.get("gurantee_date"),"");
						custName = doString.checkString((String) tmpCust.get("n_customer"),"");
						custTel = doString.checkString((String) tmpCust.get("n_cust_tel"),"");			
						//----==============================================================----//
						
						//Modify by pradoem 2015.06.25
				        /** Last Update 2015.06.24 For Repair Condo ***/
				        String condoProfileArr[] = new String[] {"NO","","","","","",""};
				        condoProfileArr = GetCondoProfile(conn,iCompany,iProject);
				        if(condoProfileArr[0].equals("YES")){ //CASE : is Condo
				        	guranteeDate = condoProfileArr[3];
				        	call_center = condoProfileArr[6];
				        }else{ // CASE : Not Condo 
				        }
				        //------------------------------------------

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
						sql.delete(0,sql.length());
						sql.append(" select trim(b.n_itmjob)||'>>'||trim(c.n_itmjob)||'>>'||trim(a.n_itmjob) itm_desc , ")
							  .append(" a.n_count , e.n_desc , f.bus_name , d.* from lan:").append(itemTable).append(" d ")
							  .append(" left join lan:serv_boq a on a.i_itmjob=d.i_itmjob ")
							  .append(" left join lan:serv_boq b on b.i_group=a.i_group and (b.i_group is not null) and ((b.i_type is null) or (b.i_type='')) and ((b.i_seq is null) or (b.i_seq='')) ")
							  .append(" left join lan:serv_boq c on c.i_group=a.i_group and c.i_type=a.i_type and (c.i_group is not null) and (c.i_type is not null) and ((c.i_seq is null) or (c.i_seq='')) ")
							  .append(" left join lan:serv_xstd e on e.i_type='01' and e.i_code=d.i_itmjob_area ")
							  .append(" left join lan:stpvendr f on f.vend_code=d.i_vendor ")
							  .append(" where d.i_docno='").append(iDocNo).append("'  and d.f_itmstatus<>'CAN' ");
						if (printTarget.equalsIgnoreCase("PAYMENT")) {
							//sql.append(" order by d.i_itmjob,d.i_seq "); //2015.06.25 by pradoem
						} else {				  
							//sql.append(" order by d.i_itmjob ");  
						}
						rs = stmt.executeQuery(sql.toString());
						
						Vector itmList = new Vector();
						Vector vendorList = new Vector();
						
						while (rs.next()) {
							String itmDesc = doString.checkString(rs.getString("itm_desc"),"");
							String cntDesc = doString.checkString(rs.getString("n_count"),"");
							String ivendor = doString.checkString(rs.getString("i_vendor"),"");
							String nvendor = doString.checkString(rs.getString("bus_name"),"");
							String comment = doString.checkString(rs.getString("c_itmjob"),"");
							String area = doString.checkString(rs.getString("n_desc"),"");
							String unitWage = doString.checkString(rs.getString("q_wage_unit"),"");
							String priceWage = doString.checkString(rs.getString("z_wage_price"),"");
							String unitGoods = doString.checkString(rs.getString("q_good_unit"),"");
							String priceGoods = doString.checkString(rs.getString("z_good_price"),"");
							
							
							if (printTarget.equalsIgnoreCase("PAYMENT")) {
								String iItmJob = doString.checkString(rs.getString("i_itmjob"),"");
								boolean noChange = false;
								sql.delete(0,sql.length());
								sql.append(" select * from lan:serv_docdt where i_itmjob='").append(iItmJob).append("' ")
									  .append(" and i_docno='").append(iDocNo).append("' ")
									  .append(" and i_vendor='").append(ivendor).append("' ");
								rs1 = stmt1.executeQuery(sql.toString());
								while (rs1.next()) {
									double checkWage = rs1.getDouble("z_wage_price");
									double checkGoods = rs1.getDouble("z_good_price");
									if (Double.parseDouble(priceWage)==checkWage && Double.parseDouble(priceGoods)==checkGoods) {
										noChange = true;
										break;
									}
									//if (Double.parseDouble(priceWage)!=checkWage || Double.parseDouble(priceGoods)!=checkGoods) {
									//	itmDesc = "* "+itmDesc;
									//}
								}
								rs1.close();
								rs1 = null;
								
								if (!noChange) {
									itmDesc = "* "+itmDesc;
								}					
							}

							//----============ Keep Data into Hashtable for used ===============----//
							Hashtable data = new Hashtable();
							data.put("item_desc",itmDesc);
							data.put("count_desc",cntDesc);
							data.put("i_vendor",ivendor);
							data.put("n_vendor",nvendor);
							data.put("comment",comment);
							data.put("area",area);
							data.put("unit_wage",unitWage);
							data.put("price_wage",priceWage);
							data.put("unit_goods",unitGoods);
							data.put("price_goods",priceGoods);
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
								
						//----==================== For Page 1 , For Customer =====================----//
						int line = 0;
						int page = 0;
						int maxPage = 0;
						int maxLine = Constants.SERV_PRINT_OPENJOB_CUSTOMER_LINE;
						int chk = itmList.size();
											
						while (chk>0) {
							maxPage++;
							chk -= maxLine;
						}
						
						while (line<itmList.size()) {			
							 table = new PdfPTable(100);
							 table.setWidthPercentage(100);
							 cb.addTemplate(page1,1,1);
							 genReportHeader(cb,page1,table,"C","","("+(page+1)+"/"+maxPage+")",closeProj,Prj_Condo,name_serv,n_service,empname,call_center);
						    //---======== generate Item List ===========----//
							 int itemLine = 0;
							 for (int i=(maxLine*page);i<itmList.size();i++) {				 	
									itemLine++;
									if (itemLine>maxLine) break;
							 	    
									Hashtable data = (Hashtable) itmList.elementAt(i);
									String itmDesc = (String) data.get("item_desc");
									cell = setCellAttribute(Integer.toString(i+1),microssfont_MED,"C","M",10,15);
									cell.setFixedHeight(30);
									table.addCell(cell);
									cell = setCellAttribute(doString.MS874ToUnicode(itmDesc) ,microssfont_MED,"L","M",90,15);
									cell.setFixedHeight(30);
									table.addCell(cell);
							 } // end for
							 
							 
							 //---=========== Fill Blank Line if item data is less than maximum ==============---//
							 boolean printFooter = false;
							 while (itemLine<maxLine) {
								printFooter = true;
								cell = setCellAttribute(" " ,microssfont_MED,"L","M",100,12);
								cell.setFixedHeight(30);
								table.addCell(cell);
								itemLine++;
							 } // end while
							 
							 
							 
							 //----=========== Generate Remark ==============----//
							cell = setCellAttribute("หมายเหตุ",microssfont_MED,"L","M",100,13);
							table.addCell(cell);		
							itemLine++;
							
							int commentLine = 0;
							for (int i=(maxLine*page);i<itmList.size();i++) {
								   commentLine++;
								   if (commentLine>maxLine) break;
								   
								   Hashtable data = (Hashtable) itmList.elementAt(i);
								   String comment = (String) data.get("comment");
								   String area = (String) data.get("area");
								   cell = setCellAttribute("รายการที่ "+(i+1)+". "+doString.MS874ToUnicode(comment)+"   บริเวณ : "+doString.MS874ToUnicode(area),microssfont_MED,"L","M",100,12);
								   cell.setFixedHeight(18);
								   table.addCell(cell);
							} // end for 
									 
							//---=========== Fill Blank Line if comment is less than maximum ==============---//
							while (commentLine<maxLine) {
							   cell = setCellAttribute(" " ,microssfont_MED,"L","M",100,12);
							   table.addCell(cell);
							   commentLine++;
							} // end while	
							
							//---- 2022-06-24 , if last page , print sign area ---//
							if (page+1>=maxPage) {
								printFooter = true;
							}
							//----------------------------------------------------//
							
							if (printFooter) {
								cell = setCellAttribute("\n" ,new Font(bf,8,Font.NORMAL),"L","M",100,14);
								table.addCell(cell);
								genCommonFooter(table,"",Prj_Condo,n_service,empname,name_serv);								
							}
							else {
								cell = setCellAttribute("\n" ,microssfont_MINI,"L","M",100,12);
								cell.setFixedHeight(80);
								table.addCell(cell);					
								cell = setCellAttribute("\n" ,microssfont_MINI,"L","M",100,14);
								table.addCell(cell);					
								cell = setCellAttribute("\nมีต่อหน้าถัดไป      " ,microssfont_MINI,"R","M",100,0);
								table.addCell(cell);										
							}			

							document.add(table);
							document.newPage();
							
							page++;
							line += maxLine;
							  
						} // end while
						//----================================================================----//
					
						 //----==================== For Page 2 , For Vendor =====================----//
						 table = new PdfPTable(100);
						 generateItemList(stmt,"V",vendorList,itmList,document,cb,page1,table,closeProj,Prj_Condo,name_serv,n_service,empname,call_center);
						 //----==============================================================----//
		 
						 //----=================== For Page 3 , For Employee ===================----//
						 table = new PdfPTable(100);
						 generateItemList(stmt,"E",vendorList,itmList,document,cb,page1,table,closeProj,Prj_Condo,name_serv,n_service,empname,call_center);
						 //----=============================================================----//

						//=====================================================================================//		 	 			
			   } // end for
			} // end if check docNoList

			 
			 //----============== generate PDF to Browser ===============-----//
			 document.close();
			 res.setContentType("application/pdf");
			 res.setContentLength(baos.size());
			 ServletOutputStream outServ = res.getOutputStream();
			 baos.writeTo(outServ);
			 outServ.flush();
			 
			 
			 conn.commit();
			 stmt.close();
			 stmt1.close();
			 conn.close();
			 conn = null;
	 
		 //} catch (DocumentException de) {
		//	 de.printStackTrace();
		//	 System.err.println("error SERV_PrintOpenJobServlet  DOCUMENT: " + de.getMessage());
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
	
	 public String[] GetCondoProfile(Connection conn,String comId,String projId){
	        StringBuffer sql = new StringBuffer();
	        Statement stmt = null;
	        ResultSet rs = null;

			boolean isCondo = false;
	        String tempStr[] = new String[] {"","","","","","",""}; //"YES,NO","LH","075","2015-06-24","Y,N","หมดประกัน/อยู่ระหว่างประกัน","0841013129"
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
	                    if(rs.getInt("x")>0) {
							tempStr[4] = "Y";
		                    tempStr[5] = doString.DisplayThai(doString.UnicodeToMS874("อยู่ระหว่างประกัน"));
	                    } else{
		                    tempStr[4] = "N";
		                    tempStr[5] = doString.DisplayThai(doString.UnicodeToMS874("หมดประกัน"));
	                    }
	                    tempStr[3] = getDateFromCalendar(gurantee);
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
	    
	    public static  String getPropValue(String key){
			Properties prop = new Properties();
			InputStream input = null;
			String ret = "";
			try {
				String filename = "config.properties";
				input = SERV_PrintOpenJobServlet.class.getClassLoader().getResourceAsStream(filename);
				if(input==null){
			        System.out.println("Sorry, unable to find " + filename);
				    return ret;
				}
				//load a properties file from class path, inside static method
				prop.load(input);
				ret = prop.getProperty(key);
			} catch (IOException ex) {
				ex.printStackTrace();
		    } finally{
		    	if(input!=null){
		    		try {
		    			input.close();
		    		} catch (IOException e) {
		    			e.printStackTrace();
		    		}
		    	}
		    }
		    return ret;
	}

}
