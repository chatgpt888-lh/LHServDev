package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;

import org.apache.poi.hssf.usermodel.*;
import org.apache.poi.hssf.util.*;

import com.lh.servlet.DBServlet;
import com.lh.util.*;


/**
 * @version 	1.0
 * @author 
 */
public class SERV_InfPubReportXlsServlet extends DBServlet  {
 
	  public void addData(HSSFWorkbook wb,HSSFSheet sheet,int y,int x,Object val,HSSFCellStyle style) {	  
		  HSSFRow row = sheet.createRow((short) y);
		  HSSFCell cell = row.createCell((short) x);	
		  
		  cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		  cell.setCellStyle(style);
		  if (val instanceof Double) {
			  cell.setCellType(HSSFCell.CELL_TYPE_NUMERIC);
			  cell.setCellValue(((Double) val).doubleValue());
		  } else {
			  cell.setCellType(HSSFCell.CELL_TYPE_STRING);
			  if (val!=null) {
				  cell.setCellValue((String) val);
			  } else {
				  cell.setCellValue("");
			  }
		  }		  
	  }	
	
	  public void setBorderStyle(HSSFCellStyle style) {
		  style.setBorderBottom(HSSFCellStyle.BORDER_THIN);
		  style.setBottomBorderColor(HSSFColor.BLACK.index);
		  style.setBorderLeft(HSSFCellStyle.BORDER_THIN);
		  style.setLeftBorderColor(HSSFColor.BLACK.index);
		  style.setBorderRight(HSSFCellStyle.BORDER_THIN);
		  style.setRightBorderColor(HSSFColor.BLACK.index);
		  style.setBorderTop(HSSFCellStyle.BORDER_THIN);
		  style.setTopBorderColor(HSSFColor.BLACK.index);					
	  } 	  

  /************************************************************************************************************/ 

	public String displayDate(String date) throws Exception {
		String result = "";
		
		try {
			if (date.length()>=10) {
				int year = Integer.parseInt(date.substring(0,4));
				if (year<2400) year += 543;			
			    result = date.substring(8,10)+"/"+date.substring(5,7)+"/"+year;
			}
		} catch (Exception ex) {
			throw new Exception("DISP_DATE_ERR_"+date);
		}
		
		return result;
	}	  

	public Calendar convertDate(String date) {
		Calendar result = null;
		
		try {
			if (date.length()>=10) {
				result = Calendar.getInstance();
				int y = Integer.parseInt(date.substring(0,4));
				if (y>2400) y -= 543;
				int m = Integer.parseInt(date.substring(5,7));
				int d = Integer.parseInt(date.substring(8,10));
				
				result.set(y,m-1,d);
			}
		} catch (Exception ex) {
			result = null;
		}
		
		return result;
	}
	
	public int calculateMonthDiff(String sDate,String eDate) {
		int result = 0;
		
		if (sDate.length()>=10 && eDate.length()>=10) {
			int y = Integer.parseInt(sDate.substring(0,4));
			if (y>2400) y -= 543;
			int m = Integer.parseInt(sDate.substring(5,7));
			Calendar start = Calendar.getInstance();
			start.set(y,m,1,0,0,0); // use month+1 to start calculate
			
			y = Integer.parseInt(eDate.substring(0,4));
			if (y>2400) y -= 543;
			m = Integer.parseInt(eDate.substring(5,7));
			Calendar end = Calendar.getInstance();
			end.set(y,m-1,1,0,0,0);
			
			while (!start.after(end)) {
				result++;
				start.add(Calendar.MONTH,1);
			} // end while
		}
		
		return result;
	}	
	
	public double rounding2Digit(double val) throws Exception {		
		double result = 0.0;
		
		try {
			result = Double.parseDouble(doString.displayNumber("######0.00",val));
		} catch (Exception ex) {
			throw new Exception("ROUNDING_ERR_"+val);
		}
		
		return result;
	}
	
	public double[] sumMonthly(double zUnitMonth,double[] zAmtMonth,String dCalculate,String dEndProj,int zMonth,int rptYear,String selVat) throws Exception {
		double result = 0.0;
		Calendar calDEndProj = convertDate(dEndProj);
		int yEnd = calDEndProj.get(Calendar.YEAR);
		int mEnd = calDEndProj.get(Calendar.MONTH);
		
		//--- start next month for calculate ---//
		Calendar calDCalculate = convertDate(dCalculate);
		int yClose = 0;
		int mClose = 0;
		
		for (int i=0;i<zMonth;i++) {
			calDCalculate.add(Calendar.MONTH,1);
			yClose = calDCalculate.get(Calendar.YEAR);
			mClose = calDCalculate.get(Calendar.MONTH);
			
			if (yClose==rptYear) {
				if ((yEnd>yClose) || (yEnd==yClose && mEnd>=mClose)) {
					if (selVat.equals("Y")) {
						zAmtMonth[mClose] += rounding2Digit(zUnitMonth);
					} else {
						zAmtMonth[mClose] += rounding2Digit((zUnitMonth*100)/107);
					}						
				} 							
			} else if (yClose>rptYear) {
				//--- data after report year not use ---//
				break;
			}
		} // end for
		
	
		return zAmtMonth;
	}	  
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
	
	String selCompany = doString.checkString(req.getParameter("sel_company"),"");
	String selYear = doString.checkString(req.getParameter("sel_year"),"");
	String selTransDate = doString.checkString(req.getParameter("trans_date"),"");
	String selVat = doString.checkString(req.getParameter("sel_vat"),"N");
	int rptYear = 0; 
    int line = 0;
	

	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;


	
	 try {
	
		//----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();       
		stmt1 = conn.createStatement();
		//----=======================================----//    
        
        
        //---- default year -----//
        if (selYear.trim().length()<4) {
			Calendar now = Calendar.getInstance();
			int year = now.get(Calendar.YEAR);
			if (year<2400) year += 543;
			selYear  = Integer.toString(year);
        }      
        
        
        //--- convert sel_year from B.C. to report year in D.C. ---//
        try {
        	rptYear = Integer.parseInt(doString.checkString(selYear,"0"))-543;
        } catch(Exception ex) {
        	rptYear = 0;
        }
        
        
        //----- convert trans_date format -----//
        String selTransDateQuery = "";
        if (selTransDate.length()>=10) {
	       	int y = Integer.parseInt(selTransDate.substring(6,10));
	       	if (y>2400) y -= 543;
	       	selTransDateQuery = y+"-"+selTransDate.substring(3,5)+"-"+selTransDate.substring(0,2);
        }
                
        
        //----- find header data -----//
        Vector projList = new Vector();
        if (selCompany.length()>=2 && selYear.length()>=4 && selTransDateQuery.length()>=10) {
        	String tmp = "";
    	    //sql.delete(0,sql.length());
    	    //sql.append(" select unique pr.n_project,c.i_company,c.i_project,m.i_phase,p.d_end_project ")
    	    //   .append(" from lan:acscontr c,lan:acspbmmo m,lan:acspubhd p ")
    	    //   .append(" left join lan:acxprojt pr on pr.i_company=p.i_company and pr.i_project=p.i_project ")
    	    //   .append(" where c.i_company='"+selCompany+"' ")
    	    //   .append(" and c.d_close_law <= '"+selTransDateQuery+"' ") //and p.d_end_project is not null ")
    	    //   .append(" and c.d_lor > '1999-03-31' and c.f_contr is null and c.d_close_law is not null ")
    	    //   .append(" and m.i_company=c.i_company and m.i_project=c.i_project and m.i_lor=c.i_lor ")
    	    //   .append(" and p.i_company=m.i_company and p.i_project=m.i_project and p.i_phase=m.i_phase ")
    	    //   .append(" and m.f_status = 'OPN' and year(p.d_end_project)+1>='"+rptYear+"' ")    	       
    	    //   .append(" order by c.i_company,c.i_project,m.i_phase ");
    	    
    	    //---- 2022-01-14 , change query , use i_phase from lan:acxslock instead ----//
    	    sql.delete(0,sql.length());
    	    sql.append(" select unique pr.n_project,c.i_company,c.i_project,l.i_phase,p.d_end_project ")
    	       .append(" from lan:acscontr c ")  // not used  lan:acspbmmo , use lan:acxslock instead    	       
    	       .append(" left join lan:acxslock l on l.i_company=c.i_company and l.i_project=c.i_project and l.i_lock=c.i_sort ")
    	       .append(" left join lan:acspubhd p on p.i_company=l.i_company and p.i_project=l.i_project and p.i_phase=l.i_phase ")
    	       .append(" left join lan:acxprojt pr on pr.i_company=p.i_company and pr.i_project=p.i_project ")
    	       .append(" where c.i_company='"+selCompany+"' ")
    	       .append(" and c.d_close_law <= '"+selTransDateQuery+"' ")
    	       .append(" and c.d_lor > '1999-03-31' and c.f_contr is null and c.d_close_law is not null ")
    	       .append(" and year(p.d_end_project)+1>='"+rptYear+"' ")
			   .append(" order by c.i_company,c.i_project,l.i_phase ");    	    
    		rs = stmt.executeQuery(sql.toString());
    		while (rs.next()) {
    			if (doString.checkString(rs.getString("d_end_project"),"").trim().length()>=10) {
	    			tmp  = doString.checkString(rs.getString("i_company"),"");
	    			tmp += ":"+doString.checkString(rs.getString("i_project"),"");
	    			tmp += ":"+doString.checkString(rs.getString("n_project"),"");
	    			tmp += ":"+doString.checkString(rs.getString("i_phase"),"");
	    			tmp += ":"+doString.checkString(rs.getString("d_end_project"),"");
	    			
	    			projList.addElement(tmp);    	
    			}
    		} // end while
    		rs.close();	         	
        }        
        
        
		
		//----================ Initialize Variables for Excel =====================---//
        HSSFWorkbook wb = new HSSFWorkbook();
        HSSFSheet sheet = wb.createSheet("Year "+rptYear);    
    
		//================== create style ================//
		HSSFCellStyle headerStyle = wb.createCellStyle();
		headerStyle.setBorderTop(HSSFCellStyle.BORDER_NONE);
		headerStyle.setBorderBottom(HSSFCellStyle.BORDER_NONE);
		headerStyle.setBorderLeft(HSSFCellStyle.BORDER_NONE);
		headerStyle.setBorderRight(HSSFCellStyle.BORDER_NONE);
		headerStyle.setFillForegroundColor((short) 0);
		headerStyle.setFillPattern((short) 0);        
		headerStyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_TOP);
		headerStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER);
        
		HSSFCellStyle centerStyle = wb.createCellStyle();
		setBorderStyle(centerStyle);
		centerStyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_TOP);
		centerStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER);
		
		HSSFCellStyle leftStyle = wb.createCellStyle();
		setBorderStyle(leftStyle);
		leftStyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_TOP);
		leftStyle.setAlignment(HSSFCellStyle.ALIGN_LEFT);
		
		HSSFCellStyle rightStyle = wb.createCellStyle();
		setBorderStyle(rightStyle);
		rightStyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_TOP);
		rightStyle.setAlignment(HSSFCellStyle.ALIGN_RIGHT);
		rightStyle.setDataFormat(HSSFDataFormat.getBuiltinFormat("#,##0.00"));
		
		HSSFCellStyle memoStyle = wb.createCellStyle();
		memoStyle.setWrapText(true);
		memoStyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_TOP);
		memoStyle.setAlignment(HSSFCellStyle.ALIGN_LEFT);
		setBorderStyle(memoStyle);  				
		
		//--- total ---//
		HSSFCellStyle totalLeftStyle = wb.createCellStyle();
		setBorderStyle(totalLeftStyle);
		totalLeftStyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_TOP);
		totalLeftStyle.setFillForegroundColor(HSSFColor.GREY_25_PERCENT.index);
		totalLeftStyle.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);			
		totalLeftStyle.setAlignment(HSSFCellStyle.ALIGN_LEFT);		
		
		HSSFCellStyle totalCenterStyle = wb.createCellStyle();
		setBorderStyle(totalCenterStyle);
		totalCenterStyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_TOP);
		totalCenterStyle.setFillForegroundColor(HSSFColor.GREY_25_PERCENT.index);
		totalCenterStyle.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);			
		totalCenterStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER);		
		
		HSSFCellStyle totalRightStyle = wb.createCellStyle();
		setBorderStyle(totalRightStyle);
		totalRightStyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_TOP);
		totalRightStyle.setFillForegroundColor(HSSFColor.GREY_25_PERCENT.index);
		totalRightStyle.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);			
		totalRightStyle.setAlignment(HSSFCellStyle.ALIGN_RIGHT);
		totalRightStyle.setDataFormat(HSSFDataFormat.getBuiltinFormat("#,##0.00"));		
		//===============================================//		        
        

        //------ report header -------//
    	String monthName[] = new String[]{"","ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค."};
        
    	addData(wb,sheet,0,0,"รายงานสรุปค่าบริการสาธารณูปโภคแยกตามโครงการ (รายได้ตามเกณฑ์สิทธิ์)",headerStyle);
    	addData(wb,sheet,1,0,"รายงานปี "+selYear+"         โอนนิติกรรมถึงวันที่ "+selTransDate,headerStyle);
    	addData(wb,sheet,2,0,"* แสดงผลรายงานแบบ"+(selVat.equals("N") ? "ไม่รวม Vat" : "รวม Vat"),headerStyle);
    	
    	sheet.addMergedRegion(new Region(0,(short)0,0,(short)18));
    	sheet.addMergedRegion(new Region(1,(short)0,1,(short)18));    	
    	sheet.addMergedRegion(new Region(2,(short)0,2,(short)18));
    	    	
    	//--- header table ---//
    	//addData(wb,sheet,3,0,"ลำดับ","C","TBLR",HSSFColor.GREY_25_PERCENT.index);	
    	addData(wb,sheet,3,0,"ลำดับ",totalCenterStyle);
    	addData(wb,sheet,3,1,"วันโครงการ",totalCenterStyle);
    	addData(wb,sheet,3,2,"วันที่สิ้นสุดโครงการ",totalCenterStyle);
    	addData(wb,sheet,3,3,"เฟส",totalCenterStyle);
    	addData(wb,sheet,3,4,"จำนวนหลังบ้าน",totalCenterStyle);
    	addData(wb,sheet,3,5,"จำนวนเงิน",totalCenterStyle);
    	for (int m=1;m<=12;m++) {
			addData(wb,sheet,3,5+m,monthName[m],totalCenterStyle);
    	} // end for    	
    	addData(wb,sheet,3,18,"รวม",totalCenterStyle);
    	line = 4;

    	
        double zAmtMonth[] = new double[]{0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0};
      	double totalInfPub = 0.0;
      	double zUnitMonth = 0.0;
      	double totalYear = 0.0;
      	double zPublic = 0.0;
      	String dCalculate = "";
      	int zMonth = 0;
      	int cntLock = 0;

		StringTokenizer dat = null;
		String iCompany = "";
		String iProject = "";
		String nProject = "";
		String iPhase = "";
		String dEndProject = "";
		boolean displayProj = true;
		int cntProj = 0;
		
		//--- total ---//
		int sumLock = 0;
		double sumInfPub = 0.0;
		double grandTotal = 0.0;
		double sumMonth[] = new double[]{0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0};
		

 		for (int p=0;p<projList.size();p++) {
 			dat = new StringTokenizer(doString.checkString((String) projList.elementAt(p),""),":");
 			if (dat.countTokens()<5) continue;
		
 			iCompany = doString.checkString(dat.nextToken(),"").trim();
 			iProject = doString.checkString(dat.nextToken(),"").trim();
 			nProject = doString.checkString(dat.nextToken(),"").trim();
 			iPhase = doString.checkString(dat.nextToken(),"").trim();
 			dEndProject = doString.checkString(dat.nextToken(),"").trim();
 	      	
 	      	//--- reset value ---//
 			zAmtMonth = new double[]{0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0};
 	      	totalInfPub = 0.0;
 	      	cntLock = 0; 		
 	      	zUnitMonth = 0.0;
 	      	displayProj = false;
 			
 			
 			///---- find z_public -----//				
			//sql.delete(0,sql.length());
			//sql.append(" select c.i_sort,m.d_pubtran,c.d_close_law,m.z_public,m.z_month ")
			//   .append(" from lan:acscontr c,lan:acspbmmo m,lan:acspubhd p ")
			//   .append(" where c.i_company='"+iCompany+"' and c.i_project='"+iProject+"' ")
			//   .append(" and m.i_phase='"+iPhase+"' and c.d_close_law <= '"+selTransDateQuery+"' ")
			//   .append(" and c.d_lor > '1999-03-31' and c.f_contr is null and c.d_close_law is not null ")
			//   .append(" and m.i_company=c.i_company and m.i_project=c.i_project and m.i_lor=c.i_lor ")
			//   .append(" and p.i_company=m.i_company and p.i_project=m.i_project and p.i_phase=m.i_phase ")
			//   .append(" and m.f_status = 'OPN' ");	
			
			//---- 2022-01-14 , change query , use i_phase from lan:acxslock and use amount from 'C0' in case no memo found ----//
			sql.delete(0,sql.length());
			sql.append(" select d.d_due,d.z_amount,c.i_sort,c.i_lor,c.d_close_law,m.d_pubtran,nvl(m.z_public,0) as z_public,nvl(m.z_month,0) as z_month  ")
			   .append(" from lan:acscontr c ")
			   .append(" left join lan:acrduerv d on d.i_company=c.i_company and d.i_project=c.i_project and d.i_lor=c.i_lor and d.i_due='C0' ")			   
			   .append(" left join lan:acspbmmo m on m.i_company=c.i_company and m.i_project=c.i_project and m.i_lor=c.i_lor and m.f_status = 'OPN' ")
			   .append(" left join lan:acxslock l on l.i_company=c.i_company and l.i_project=c.i_project and l.i_lock=c.i_sort ")
			   .append(" left join lan:acspubhd p on p.i_company=l.i_company and p.i_project=l.i_project and p.i_phase=l.i_phase ")
			   .append(" where c.i_company='"+iCompany+"' and c.i_project='"+iProject+"' ")
			   .append(" and l.i_phase='"+iPhase+"' and c.d_close_law <= '"+selTransDateQuery+"' ")
			   .append(" and c.d_lor > '1999-03-31' and c.f_contr is null and c.d_close_law is not null ");					
			rs = stmt.executeQuery(sql.toString());
			while (rs.next()) {
				zPublic = rs.getDouble("z_public");
				zMonth = rs.getInt("z_month");
			
				//------ 2022-01-14 , data in lan:acspbmm not found , calculate new value from 'C0' -------//
				if (zPublic<=0 || zMonth<=0) {
					zPublic = rs.getDouble("z_amount");
					zMonth = calculateMonthDiff(doString.checkString(rs.getString("d_due"),""),dEndProject);
				} 
				//-----------------------------------------------------------------------------------------//		
				
				if (selVat.equals("Y")) {
					totalInfPub += zPublic;
				} else {
					totalInfPub += rounding2Digit((zPublic*100)/107);
				}				
				
				//--- use d_pubran from memo to calculate. if blank, use d_close_law instead ---//
				dCalculate = doString.checkString(rs.getString("d_pubtran"),"");
				if (dCalculate.length()<10) {
					dCalculate = doString.checkString(rs.getString("d_close_law"),"");
				}
				
				//============ 2022-01-14 , special case for d_close_law and d_end_project is same month ============//
				if (dCalculate.substring(0,7).equals(dEndProject.substring(0,7)) && zMonth>0 && zPublic>0) {
					doString str = new doString();
					Calendar calDEndProj = convertDate(dEndProject);
					calDEndProj.add(Calendar.MONTH,1);
					int y = calDEndProj.get(Calendar.YEAR);
					if (y>2400) y -= 543;
					int m = calDEndProj.get(Calendar.MONTH)+1;
					
					zAmtMonth = sumMonthly(rounding2Digit(zPublic),zAmtMonth,dCalculate,y+"-"+str.createID(m,2)+"-01",1,rptYear,selVat);					
				}
				//===================================================================================================// 
				
				//======== normal case ========//
				else {
					zUnitMonth = 0.0;
					if (zMonth>0) {
						zUnitMonth = rounding2Digit(zPublic/zMonth);
					} else {
						zUnitMonth = 0.0;
					}
					zAmtMonth = sumMonthly(zUnitMonth,zAmtMonth,dCalculate,dEndProject,zMonth,rptYear,selVat);
				}
				//============================//

				cntLock++;
			} // end while
			rs.close();	
			
			
			//---- if all data is 0 , no display ----//
			displayProj = false;
			for (int i=0;i<zAmtMonth.length;i++) {
				if (zAmtMonth[i]>0) {
					displayProj = true;
					break;
				}
			} // end for			
	    		
						
			if (displayProj) {
	      		cntProj++;
	      		
	      		//--- sum total data ---//
	    		sumLock += cntLock;
	    		sumInfPub += totalInfPub;	    		
	    		
		    	addData(wb,sheet,line,0,doString.displayNumber("#,##0",cntProj),rightStyle);		    	
		    	addData(wb,sheet,line,1,iCompany+iProject+" | "+doString.DisplayThai(nProject),leftStyle);	
		    	addData(wb,sheet,line,2,displayDate(dEndProject),centerStyle);
		    	addData(wb,sheet,line,3,iPhase,centerStyle);
		    	addData(wb,sheet,line,4,doString.displayNumber("#,##0",cntLock),rightStyle);
		    	addData(wb,sheet,line,5,totalInfPub,rightStyle);
		    	//--- display month data ---//
				totalYear = 0.0;
		      	for (int m=0;m<12;m++) {
		      		totalYear += rounding2Digit(zAmtMonth[m]);			      		
		      		sumMonth[m] += rounding2Digit(zAmtMonth[m]);		      		
		      		addData(wb,sheet,line,m+6,zAmtMonth[m],rightStyle);
		      	} // end for		    	
		      	
		      	grandTotal += totalYear;
		    	//--------------------------//
		    	addData(wb,sheet,line,18,totalYear,rightStyle);
		    	
		    	line++;
			}
	  } // end while    	
    	
 		
 	  //----- print total line -----//
	  addData(wb,sheet,line,0,"รวม",totalCenterStyle);		    	
	  addData(wb,sheet,line,1," ",totalCenterStyle);
	  addData(wb,sheet,line,2," ",totalCenterStyle);
	  addData(wb,sheet,line,3," ",totalCenterStyle);
	  sheet.addMergedRegion(new Region(line,(short)0,line,(short)3));
	  addData(wb,sheet,line,4,doString.displayNumber("#,##0",sumLock),totalRightStyle);
	  addData(wb,sheet,line,5,sumInfPub,totalRightStyle);
	  //--- display month data ---//
  	  for (int m=0;m<12;m++) {
	  	  addData(wb,sheet,line,m+6,sumMonth[m],totalRightStyle);
  	  } // end for		    	
	  //--------------------------//
	  addData(wb,sheet,line,18,grandTotal,totalRightStyle); 		
	 		

	  
		//----=========== Generate XLS ===============-----//
		res.setContentType("application/vnd.ms-excel");  
		res.setHeader("content-disposition","filename=report.xls");		
		ServletOutputStream outServ = res.getOutputStream();
		wb.write(outServ);
		outServ.flush();			

		

		stmt.close();
		stmt1.close();
		conn.close();
		stmt = null;
		stmt1 = null;
		conn = null;	
		
		
	} catch (Exception e) {
		System.out.println(" ERROR "+mName+" : " + e.getMessage());
		//System.out.println(" ERROR "+mName+" SQL : " + sql.toString());			
	} finally {
		try {
			if (rs != null) rs.close();
			if (rs1 != null) rs1.close();
			if (stmt != null) stmt.close();
			if (stmt1 != null) stmt1.close();
			if (conn != null) conn.close();
		} catch (SQLException ignore) {
		}
	}
	System.out.println(mName + "end.");
	
	}

}
