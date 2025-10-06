package serv.servlets;
import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import serv.common.*;
import com.lh.servlet.DBServlet;
import com.lh.util.doString;
import com.lh.util.CurrencyToThai;
import com.lh.util.DateUtil;
import com.lh.exception.InvalidParameterException;
import org.apache.poi.hssf.usermodel.*;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.hssf.util.Region;

public class PrintPayinExcelServlet extends DBServlet {
    private static String cName = "/LHServ/PrintPayinExcelServlet";
    
	
public void performTask(HttpServletRequest req, HttpServletResponse res)
    throws ServletException, IOException {

    HttpSession session = req.getSession(false);

    if (session == null) {

        /*
        
        * Redirect user to login page if
        
        * there's no session.
        
        */

        res.sendRedirect("/LHServ/warning.htm");

        return;

    }

    Object obj = session.getAttribute("USER");

    if (obj == null) {

        /*
        
        * Redirect user to login page if
        
        * there's no session.
        
        */

        res.sendRedirect("/LHServ/warning.htm");

        return;

    }	
    
	    
		
		
    String mName = new String(cName + ".performTask: ");

    System.out.println(mName + "start.");

	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmthd = null;
	ResultSet rs = null;
	ResultSet rshd = null;
    try {
	if (ds == null)
	{
		getDS();
	}
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	stmthd = conn.createStatement();

		double amount = 0;
        String docNo = "", sortId = "", custType = "", custId = "", status = "", custName = "", n_status = "";
        String m_type = "", n_proj = "";
		String comId = doString.checkString(req.getParameter("comId"));
		String projId = doString.checkString(req.getParameter("projId"));
		String startDate = doString.checkString(req.getParameter("startDate"));
		String endDate = doString.checkString(req.getParameter("endDate"));
		String beg_lock = doString.checkString(req.getParameter("beg_lock"));
		String end_lock = doString.checkString(req.getParameter("end_lock"));
		String month = doString.checkString(req.getParameter("month"));
		String year = doString.checkString(req.getParameter("year"));
		String betweenDate = doString.checkString(req.getParameter("betweenDate"));
		
		System.out.println("startDate="+startDate);
		System.out.println("endDate="+endDate);
		
		 if(month.equals("01")) {
		 	m_type = "1 เดือน";			
		}else if(month.equals("02")) {
			m_type = "2 เดือน";			
		}else if(month.equals("03")) {
			m_type = "3 เดือน";			
		}else if(month.equals("04")) {
			m_type = "4 เดือน";			
		}else if(month.equals("05")) {
			m_type = "6 เดือน";			
		}else if(month.equals("06")) {
			m_type = "12 เดือน";		
		}							

		String restrict = "";
		if (!beg_lock.equals("")) {
				if (end_lock.equals("")) {
					restrict = "AND (i_sort = '"+beg_lock+"')";
				} else {
					restrict = "AND (i_sort >= '"+beg_lock+"' AND i_sort <= '"+end_lock+"')";
				}
		}
			rs = stmt.executeQuery("SELECT n_project FROM lan:acxprojt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
			if(rs.next() == true) {
				n_proj = doString.checkString(rs.getString("n_project"));
			}	 
	
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        HSSFWorkbook wb = new HSSFWorkbook();
        HSSFSheet sheet = wb.createSheet("new sheet");
        HSSFRow row = null;
        HSSFCell cell = null;
        HSSFCellStyle align_head = wb.createCellStyle();
        HSSFCellStyle align_center = wb.createCellStyle();
        HSSFCellStyle align_right = wb.createCellStyle();        
        HSSFCellStyle align_left = wb.createCellStyle();
        align_head.setAlignment(HSSFCellStyle.ALIGN_CENTER);        
        align_center.setAlignment(HSSFCellStyle.ALIGN_CENTER);
        align_right.setAlignment(HSSFCellStyle.ALIGN_RIGHT); 
		align_left.setAlignment(HSSFCellStyle.ALIGN_LEFT);	

        // set color & border to "align_head"
        align_head.setFillForegroundColor(HSSFColor.GREY_25_PERCENT.index);
        align_head.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
        align_head.setBorderBottom(HSSFCellStyle.BORDER_THIN);
        align_head.setBottomBorderColor(HSSFColor.BLACK.index);
        align_head.setBorderLeft(HSSFCellStyle.BORDER_THIN);
        align_head.setLeftBorderColor(HSSFColor.BLACK.index);
        align_head.setBorderRight(HSSFCellStyle.BORDER_THIN);
        align_head.setRightBorderColor(HSSFColor.BLACK.index);
        align_head.setBorderTop(HSSFCellStyle.BORDER_THIN);
        align_head.setTopBorderColor(HSSFColor.BLACK.index);
        
        // set width to column in sheet
	    sheet.setColumnWidth((short) 0, (short) 3500);
	    sheet.setColumnWidth((short) 1, (short) 3000);
	    sheet.setColumnWidth((short) 2, (short) 3000);
	    sheet.setColumnWidth((short) 3, (short) 7000);
	    sheet.setColumnWidth((short) 4, (short) 4500);
	    sheet.setColumnWidth((short) 5, (short) 5000);
      	
		
		//-----  HEADING ---------    
	   	sheet.addMergedRegion(new Region(0, (short) 0, 0, (short) 3));   
		sheet.addMergedRegion(new Region(0, (short) 4, 0, (short) 5));   
		sheet.addMergedRegion(new Region(1, (short) 0, 1, (short) 3)); 
		sheet.addMergedRegion(new Region(1, (short) 4, 1, (short) 5));  			
			
		row = sheet.createRow((short) 0);
		row.setHeight((short) 400);  		  
		cell = row.createCell((short) 0);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_left);
		cell.setCellValue("โครงการ  : "+comId+projId+" "+doString.MS874ToUnicode(doString.checkString(n_proj)));					
		cell = row.createCell((short) 4);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_left);
		cell.setCellValue("ประเภท : "+m_type);	
		
		row = sheet.createRow((short) 1);
		row.setHeight((short) 400);  						 
		cell = row.createCell((short) 0);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_left);
		cell.setCellValue("ช่วงเดือน : "+Period.getBetween(startDate, endDate));	

							  
		cell = row.createCell((short) 4);
		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		cell.setCellStyle(align_left);
		cell.setCellValue("ปี : "+year);
		//-----------------------							
				
			row = sheet.createRow((short) 2);
			row.setHeight((short) 400);
            // Create a cell and put a value in it.
            cell = row.createCell((short) 0);
            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
            cell.setCellStyle(align_head);
            cell.setCellValue("เลขที่เอกสาร");
            
            cell = row.createCell((short) 1);
            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
            cell.setCellStyle(align_head);
            cell.setCellValue("แปลง");

            cell = row.createCell((short) 2);
            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
            cell.setCellStyle(align_head);
            cell.setCellValue("วันที่แจ้ง");

            cell = row.createCell((short) 3);
            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
            cell.setCellStyle(align_head);
            cell.setCellValue("ผู้ชำระค่าสาธารณะ");

            cell = row.createCell((short) 4);
            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
            cell.setCellStyle(align_head);
            cell.setCellValue("จำนวนเงิน");

            cell = row.createCell((short) 5);
            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
            cell.setCellStyle(align_head);
            cell.setCellValue("สถานะ");

            // Data
			rs = stmt.executeQuery("SELECT i_docno, i_sort, i_lor, d_keyin, i_inf_custo, i_infra, NVL(z_infra,0) AS INF_AMT, i_doc_status FROM lan:serv_infhd WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' "+restrict+" AND d_start = '"+startDate+"' AND d_end = '"+endDate+"' AND i_doc_status != 'F' ORDER BY i_sort");
			for (int i = 1; rs.next() == true; i++) {
		
			    docNo = doString.checkString(rs.getString("I_DOCNO"));
				sortId = doString.checkString(rs.getString("I_SORT"));
				amount = rs.getDouble("INF_AMT");
				status = doString.checkString(rs.getString("I_DOC_STATUS"));
				custType = doString.checkString(rs.getString("I_INF_CUSTO"));
				custId = doString.checkString(rs.getString("I_INFRA"));
			    custName = "";
    	     	                
					if (custType.equals("1")) {
							rshd = stmthd.executeQuery("SELECT n_prename, n_ncustomer, n_scustomer FROM lan:acxcusto WHERE i_customer = "+custId);
							if (rshd != null) {
								if (rshd.next() == true) {
									custName = doString.checkString(rshd.getString("N_PRENAME"))+" "+doString.checkString(rshd.getString("N_NCUSTOMER"))+ " "+doString.checkString(rshd.getString("N_SCUSTOMER"));;
								}
								rshd.close();
								rshd=null;
							}			
					
					} else {
						rshd = stmthd.executeQuery("SELECT n_pname, n_name, n_sname FROM lan:serv_venprj WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_type = '07' AND i_vendor = '"+custId+"'");
							if (rshd != null) {
								if (rshd.next() == true) {
									custName = doString.checkString(rshd.getString("N_PNAME"))+" "+doString.checkString(rshd.getString("N_NAME"))+" "+doString.checkString(rshd.getString("N_SNAME"));
								}
								rshd.close();
								rshd=null;
							}
					}					
						
						n_status = "";
						if (status.equals("N")) {
							n_status = "เอกสารใหม่";
						} else if (status.equals("C")) {
							n_status = "ยกเลิก";
						} else if (status.equals("Y")) {
							n_status = "รอ Conf.PayIn";
						} else if (status.equals("P")) {
							n_status = "Conf.Payin แล้ว(รับเงินไม่ครบ)";
						} else if (status.equals("F")) {
							n_status = "รับเงินเรียบร้อย";
						} 				
      
						// Create a row and put some cells in it. Rows are 0 based.
							row = sheet.createRow((short) i+2); // + header
							row.setHeight((short) 300);

							cell = row.createCell((short) 0);
							cell.setCellStyle(align_center);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellValue(docNo);					
					
							cell = row.createCell((short) 1);
							cell.setCellStyle(align_center);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellValue(sortId);
			  
							cell = row.createCell((short) 2);
							cell.setCellStyle(align_center);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);			
							cell.setCellValue(DateUtil.ifxToThaiDateNoTime(rs.getString("D_KEYIN")));			

							cell = row.createCell((short) 3);
							cell.setCellStyle(align_left);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellValue(doString.MS874ToUnicode(doString.checkString(custName)));				

							cell = row.createCell((short) 4);
							cell.setCellStyle(align_right);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellValue(doString.displayNumber("###,###,###.00", amount));
			
							cell = row.createCell((short) 5);
							cell.setCellStyle(align_center);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellValue(n_status);	      
				} // End for 

        wb.write(baos);
        res.setContentType("application/vnd.ms-excel");
        res.setContentLength(baos.size());
        ServletOutputStream out = res.getOutputStream();
        baos.writeTo(out);
        out.flush();

    stmt.close();
	stmthd.close();
	conn.close();
	stmt = null;
	stmthd = null;
	conn = null;

    } catch (Exception e) {

        System.out.println("error PrintPayinExcelServlet : " + e.getMessage());
        System.out.println("error PrintPayinExcelServlet SQL : " + sql.toString());

    } finally {

        try {

        if (rs != null)
			rs.close();
		if (rshd != null)
			rshd.close();
		if (stmt != null)
			stmt.close();
		if (stmthd != null)
			stmthd.close();
		if (conn != null)
			conn.close();

        } catch (SQLException ignore) {

        }

    }

    System.out.println(mName + "end.");

}
}
