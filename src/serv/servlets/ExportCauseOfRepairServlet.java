package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

import com.lh.servlet.DBServlet;
import com.lh.util.doString;
import com.lh.util.DateUtil;
import serv.common.User;
import org.apache.poi.hssf.usermodel.*;
import org.apache.poi.hssf.util.*;

 public class ExportCauseOfRepairServlet extends DBServlet {	 
	 private static String cName = "/LHServ/ExportCauseOfRepairServlet";
	 
		public HSSFCellStyle getStyle(HSSFWorkbook wb, short align, String border, short bgColor) {
			HSSFCellStyle style = wb.createCellStyle();
			style.setAlignment(align);
			style.setFillForegroundColor(bgColor);
			style.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
			if (border.indexOf("T")>=0) {
				style.setBorderTop(HSSFCellStyle.BORDER_THIN);
				style.setTopBorderColor(HSSFColor.BLACK.index);
			}
			if (border.indexOf("B")>=0) {
				style.setBorderBottom(HSSFCellStyle.BORDER_THIN);
				style.setBottomBorderColor(HSSFColor.BLACK.index);
			}
			if (border.indexOf("L")>=0) {
				style.setBorderLeft(HSSFCellStyle.BORDER_THIN);
				style.setLeftBorderColor(HSSFColor.BLACK.index);
			}
			if (border.indexOf("R")>=0) { 
				style.setBorderRight(HSSFCellStyle.BORDER_THIN);
				style.setRightBorderColor(HSSFColor.BLACK.index);
			}
			return style;
		}
		public HSSFCellStyle getStyle(HSSFWorkbook wb, short align, String border, short bgColor, HSSFFont font) {
			HSSFCellStyle style = wb.createCellStyle();
			style.setAlignment(align);
			style.setFont(font);
			style.setFillForegroundColor(bgColor);
			style.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
			if (border.indexOf("T")>=0) {
				style.setBorderTop(HSSFCellStyle.BORDER_THIN);
				style.setTopBorderColor(HSSFColor.BLACK.index);
			}
			if (border.indexOf("B")>=0) {
				style.setBorderBottom(HSSFCellStyle.BORDER_THIN);
				style.setBottomBorderColor(HSSFColor.BLACK.index);
			}
			if (border.indexOf("L")>=0) {
				style.setBorderLeft(HSSFCellStyle.BORDER_THIN);
				style.setLeftBorderColor(HSSFColor.BLACK.index);
			}
			if (border.indexOf("R")>=0) { 
				style.setBorderRight(HSSFCellStyle.BORDER_THIN);
				style.setRightBorderColor(HSSFColor.BLACK.index);
			}
			return style;
		}
		
	public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
	    String mName = new String(cName + ".performTask: ");
	    System.out.println(mName + "start.");
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
	    User user = (User)obj;
	    String userId = user.getUserID();
		String sessionId = user.getsessionId();
		String itmtype = doString.checkString(req.getParameter("itmtype"),"01");
		String group = doString.checkString(req.getParameter("itmGroup"));
		String cause = doString.checkString(req.getParameter("Cause"));
		String grpDesc = "";
		String CauseOfRepair = "";
	    String docYear = Integer.toString(Integer.parseInt(doString.checkString(req.getParameter("docYear")))-543);
	    String begDate = docYear+"-01-01";
	    String endDate = docYear+"-12-31";
		String docNo = "";
		String comId = "";
		String projId = "";
		String projName = "";
		String jobDate = "";
		String payDate = "";
		String empId = "";
		String empName = "";
		String apprId = "";
		String apprName = "";
		String venId = "";
		String venName = "";

		String staffId = "";
		String staffName = "";

		String managerId = "";
		String managerName = "";
		
		String zoneId = "";
		String zoneName = "";
		
		String vpId = "";
		String vpName = "";
		
		String itemId = "";
		String itemDesc = "";
		String account = "";
		String desc = "";
		String code = "";
		String area = "";
		boolean reject = false;
		double wage_unit = 0;
		double wage_price = 0;
		double wage_amnt = 0;
		
		double good_unit = 0;
		double good_price = 0;
		double good_amnt = 0;
		
		double pay_amnt = 0;
		double pv_amnt = 0;

	    String[] projList = req.getParameterValues("sel_proj");
	    String proj = "", i_com = "", i_proj = "";
	    int line = 0;
		Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
		String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);	    
		//------ forward page --------//
		StringBuffer sql = new StringBuffer();
	    Connection conn = null;
	    Statement stmt = null;
	    Statement dstmt = null;
	    Statement stmt1 = null;
	    ResultSet rs = null;
	    ResultSet rsDetail = null;
	    try {
	        if (ds == null)
	            getDS();
	        conn = ds.getConnection();
	        conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	        conn.setAutoCommit(true);
	        stmt = conn.createStatement();
	        stmt1 = conn.createStatement();
	        dstmt = conn.createStatement();
	        
			rs = stmt.executeQuery("select n_itmjob from lan:serv_infboq where i_group = '"+group+"' and i_type = '00' and i_seq = '0000'");
			if (rs != null) {
				if (rs.next() == true) {	        
					grpDesc = doString.MS874ToUnicode(doString.checkString(rs.getString(1)));
				}
				rs.close();
				rs=null;
			}	        
			rs = stmt.executeQuery("select n_desc from lan:serv_xstd where i_type = '10' and i_code = '"+cause+"'");
			if (rs != null) {
				if (rs.next() == true) {	        
					CauseOfRepair = doString.MS874ToUnicode(doString.checkString(rs.getString(1)));
				}
				rs.close();
				rs=null;
			}
			if (projList != null) {
				for (int i=0; i<projList.length; i++) {		
					proj = doString.checkString(projList[i]);  		
					i_com = proj.substring(0,2);
					i_proj = proj.substring(3,6);
					if (!i_proj.equals("ALL")) {
						stmt.executeUpdate("INSERT INTO lan:serv_selproj(i_session,i_company,i_project) VALUES("+sessionId+", '"+i_com+"', '"+i_proj+"')");
					}
			  } // end for
			}
			if (i_proj.equals("ALL")) {
					sql.delete(0,sql.length()); 
					sql.append("SELECT DISTINCT proj.i_company, proj.i_project, proj.n_project FROM lan:acxprojt proj, lan:acsbudgh bud");
					rs = stmt.executeQuery("SELECT proj_id FROM lan:serv_pstaff WHERE user_id = '"+userId+"' AND proj_id = 'ALL'");
					if (rs.next() == false) {
						sql.append(", lan:serv_pstaff staff WHERE proj.i_company = staff.com_id AND proj.i_project = staff.proj_id AND staff.user_id = '")
							.append(userId + "' AND");
					} else {
						sql.append(" WHERE");
					}
					rs.close();
					sql.append(" bud.i_company = proj.i_company AND bud.i_project = proj.i_project AND bud.d_year = '" + cur_year + "'");
					rs = stmt.executeQuery(sql.toString());
					while (rs.next() == true) {
						i_com = doString.checkString(rs.getString("I_COMPANY"));
						i_proj = doString.checkString(rs.getString("I_PROJECT"));
						stmt1.executeUpdate("INSERT INTO lan:serv_selproj(i_session,i_company,i_project) VALUES("+sessionId+", '"+i_com+"', '"+i_proj+"')");
					}// end while
					rs.close();
			}			
			HSSFWorkbook wb = new HSSFWorkbook();
			HSSFSheet sheet = wb.createSheet("new sheet");
			HSSFRow row = null;
			HSSFCell cell = null;
			String filename ="CauseOfRepair.xls";
			
			
	        HSSFFont headFont = wb.createFont();
	        headFont.setFontName(HSSFFont.FONT_ARIAL);
	        headFont.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
	        headFont.setColor(HSSFColor.BLACK.index);
			
			HSSFCellStyle align_head = wb.createCellStyle();
			align_head.setAlignment(HSSFCellStyle.ALIGN_CENTER);
			// set color & border to "align_head"
			align_head.setFillForegroundColor(HSSFColor.GREY_25_PERCENT.index);
			align_head.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);        
			align_head.setBorderBottom(HSSFCellStyle.BORDER_THIN);
			align_head.setBottomBorderColor(HSSFColor.BLACK.index);
			align_head.setBorderLeft(HSSFCellStyle.BORDER_THIN);
			align_head.setLeftBorderColor(HSSFColor.BLACK.index);
			align_head.setBorderRight(HSSFCellStyle.BORDER_THIN);
			align_head.setRightBorderColor(HSSFColor.BLACK.index);
			align_head.setBorderTop(HSSFCellStyle.BORDER_MEDIUM_DASHED);
			align_head.setTopBorderColor(HSSFColor.BLACK.index);
	        
			
			res.setContentType("application/x-download");
			res.setHeader("Content-Disposition", "attachment; filename=" + filename);
			ServletOutputStream out = res.getOutputStream();
			
    		row = sheet.createRow((short) line++);
            cell = row.createCell((short)0);
            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
            cell.setCellStyle(getStyle(wb,HSSFCellStyle.ALIGN_LEFT,"",HSSFColor.WHITE.index,headFont));            
            cell.setCellValue("รายงานสาเหตุงานซ่อม");
            
    		row = sheet.createRow((short) line++);
            cell = row.createCell((short)0);
            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
            cell.setCellStyle(getStyle(wb,HSSFCellStyle.ALIGN_LEFT,"",HSSFColor.WHITE.index,headFont));            
            cell.setCellValue("หมวดงานซ่อม : "+grpDesc);			

    		row = sheet.createRow((short) line++);
            cell = row.createCell((short)0);
            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
            cell.setCellStyle(getStyle(wb,HSSFCellStyle.ALIGN_LEFT,"",HSSFColor.WHITE.index,headFont));            
            cell.setCellValue("สาเหตุงานซ่อม : "+CauseOfRepair);			

    		row = sheet.createRow((short) line++);
            cell = row.createCell((short)0);
            cell.setEncoding(HSSFCell.ENCODING_UTF_16);
            cell.setCellStyle(getStyle(wb,HSSFCellStyle.ALIGN_LEFT,"",HSSFColor.WHITE.index,headFont));            
            cell.setCellValue("ประจำปี : "+(Integer.parseInt(docYear)+543));			
            
			row = sheet.createRow((short) line++);
			
			cell = row.createCell((short) 0);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("บริษัท");

			cell = row.createCell((short) 1);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("โครงการ");
			
			cell = row.createCell((short) 2);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("ชื่อโครงการ");

			cell = row.createCell((short) 3);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("รหัสผู้รับเหมา");
			
			cell = row.createCell((short) 4);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("ชื่อผู้รับเหมา");
			
			cell = row.createCell((short) 5);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("วันที่ Open Job");
			
			cell = row.createCell((short) 6);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("เลขที่ใบแจ้งซ่อม");
			
			cell = row.createCell((short) 7);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("รายการซ่อม");					

			cell = row.createCell((short) 8);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("รายละเอียด");								

			cell = row.createCell((short) 9);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("บริเวณ");	
			
			cell = row.createCell((short) 10);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("จำนวนแรง");	
			
			cell = row.createCell((short) 11);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("ค่าแรงต่อหน่วย");
			
			cell = row.createCell((short) 12);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("ค่าแรง");	
			
			cell = row.createCell((short) 13);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("จำนวนของ");
			
			cell = row.createCell((short) 14);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("ค่าของต่อหน่วย");
			
			cell = row.createCell((short) 15);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("ค่าของ");	
			
			cell = row.createCell((short) 16);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("ค่าแรง+ค่าของ");
			
			cell = row.createCell((short) 17);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("รวมค่าดำเนินการ");
			
			sql.delete(0,sql.length()); 
			sql.append("SELECT p.i_docno, p.i_vendor, v.ven_name, p.i_itmjob, b.n_itmjob, p.i_account, p.c_itmjob, p.i_itmjob_area, p.q_wage_unit, p.z_wage_price, p.q_wage_unit*p.z_wage_price AS WAGE_AMT, p.q_good_unit, p.z_good_price, p.q_good_unit*p.z_good_price AS GOOD_AMT, p.z_amount_pay, p.z_amount_pv, p.d_payment, h.i_company, h.i_project")
				.append(" FROM lan:serv_infboq b, lan:serv_infpayment p, lan:vendor v, lan:serv_infdochd h, lan:serv_selproj s")
				.append(" WHERE b.i_group = '"+group+"' AND b.i_seq > '0000' AND b.i_itmtype = '")
				.append(itmtype)
				.append("' AND b.i_itmjob = p.i_itmjob AND p.i_vendor = v.ven_no AND p.i_itmtype = '")
				.append(itmtype)
				.append("' AND p.f_remark = '")
				.append(cause)
				.append("' AND p.i_docno = h.i_docno")
				.append(" AND h.d_job >= '")
				.append(begDate)
				.append("' AND h.d_job <= '")
				.append(endDate)
				.append("' AND h.f_status != 'CAN' AND h.i_company = s.i_company AND h.i_project = s.i_project AND s.i_session = "+sessionId)
				.append(" ORDER BY h.i_company, h.i_project, p.i_docno");
//System.out.println(sql.toString());
			rsDetail = dstmt.executeQuery(sql.toString());
			if (rsDetail != null) {
				while (rsDetail.next() == true) {
					docNo = doString.checkString(rsDetail.getString(1));
					venId = doString.checkString(rsDetail.getString(2));
					venName = doString.MS874ToUnicode(doString.checkString(rsDetail.getString(3)));
					itemId = doString.checkString(rsDetail.getString(4));
					itemDesc = doString.MS874ToUnicode(doString.checkString(rsDetail.getString(5)));
					account = doString.checkString(rsDetail.getString(6));
					desc = doString.MS874ToUnicode(doString.checkString(rsDetail.getString(7)));
					code = doString.checkString(rsDetail.getString(8));
					wage_unit = rsDetail.getDouble(9);
					wage_price = rsDetail.getDouble(10);
					wage_amnt = rsDetail.getDouble(11);

					good_unit = rsDetail.getDouble(12);
					good_price = rsDetail.getDouble(13);
					good_amnt = rsDetail.getDouble(14);
					
					pay_amnt = rsDetail.getDouble(15);
					pv_amnt = rsDetail.getDouble(16);

					payDate = DateUtil.ifxToThaiDateNoTime(rsDetail.getString(17));
					
					reject = true;
					comId = "";
					projId = "";
					projName = "";
					jobDate = "";
					empId = "";
					empName = "";
					apprId = "";
					apprName = "";
					area = "";
					rs = stmt.executeQuery("SELECT n_desc FROM lan:serv_xstd WHERE i_type = '08' AND i_code = '" + code + "'");
					if (rs.next() == true) {
						area = doString.MS874ToUnicode(doString.checkString(rs.getString(1)));
					}
					rs.close();
					rs=null;					
					
					rs = stmt.executeQuery("SELECT h.i_company, h.i_project, p.n_project, h.d_job, h.i_service_employ, h.i_approver FROM lan:serv_infdochd h, lan:acxprojt p WHERE h.i_docno = '"+docNo+"' AND h.f_status != 'CAN' AND h.i_company = p.i_company AND h.i_project = p.i_project");
					if (rs.next() == true) {
						reject = false;
						comId = doString.checkString(rs.getString(1));
						projId = doString.checkString(rs.getString(2));
						projName = doString.MS874ToUnicode(doString.checkString(rs.getString(3)));
						jobDate = DateUtil.ifxToThaiDateNoTime(rs.getString(4));
						empId = doString.checkString(rs.getString(5));
						apprId = doString.checkString(rs.getString(6));
					}
					rs.close();
					rs=null;
					
					rs = stmt.executeQuery("SELECT i_docno FROM lan:serv_infflow WHERE i_docno = '" + docNo + "' AND i_vendor = '"+venId+"' AND f_reject = 'Y'");
					if (rs.next() == true) {
						reject = true;
					}
					rs.close();
					rs=null;


					rs = stmt.executeQuery("SELECT n_nemploy_th FROM docflow:acemploy WHERE i_employ = '"+empId+"'");
					if (rs.next() == true) {
						empName = doString.MS874ToUnicode(doString.checkString(rs.getString(1)));
					}
					rs.close();
					rs=null;
					
					rs = stmt.executeQuery("SELECT n_nemploy_th FROM docflow:acemploy WHERE i_employ = '"+apprId+"'");
					if (rs.next() == true) {
						apprName = doString.MS874ToUnicode(doString.checkString(rs.getString(1)));
					}
					rs.close();
					rs=null;
					
						row = sheet.createRow((short) line++);
						cell = row.createCell((short) 0);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(comId);
						cell = row.createCell((short) 1);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(projId);
						cell = row.createCell((short) 2);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(projName);
						cell = row.createCell((short) 3);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(venId);
						cell = row.createCell((short) 4);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(venName);
						cell = row.createCell((short) 5);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(jobDate);
						cell = row.createCell((short) 6);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(docNo);
						cell = row.createCell((short) 7);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(itemDesc);					
						cell = row.createCell((short) 8);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(desc);								
						cell = row.createCell((short) 9);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(area);	
						cell = row.createCell((short) 10);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(doString.displayNumber("#########.00", wage_unit));	
						cell = row.createCell((short) 11);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(doString.displayNumber("#########.00", wage_price));	
						cell = row.createCell((short) 12);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(doString.displayNumber("#########.00", wage_amnt));	
						cell = row.createCell((short) 13);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(doString.displayNumber("#########.00", good_unit));	
						cell = row.createCell((short) 14);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(doString.displayNumber("#########.00", good_price));	
						cell = row.createCell((short) 15);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(doString.displayNumber("#########.00", good_amnt));	
						cell = row.createCell((short) 16);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(doString.displayNumber("#########.00", pay_amnt));	
						cell = row.createCell((short) 17);
						cell.setEncoding(HSSFCell.ENCODING_UTF_16);
						cell.setCellValue(doString.displayNumber("#########.00", pv_amnt));	
					
					
				}// end while
				rsDetail.close();
				rsDetail=null;
			}
			
			stmt.executeUpdate("DELETE FROM lan:serv_selproj WHERE i_session = "+sessionId);
	        stmt.close();
	        dstmt.close();
	        stmt1.close();
	        conn.close();
	        stmt = null;
	        dstmt = null;
	        stmt1 = null;
	        conn = null;
			wb.write(out);
			out.flush();       
	    } catch (Exception e) {
	        System.out.println("ERROR /LHServ/ExportCauseOfRepairServlet : " + e.getMessage());
	    } finally {
			if (rs != null) {
	            try {
	                rs.close();
	            } catch (SQLException ignore) {
	            }				
			}
			if (rsDetail != null) {
	            try {
	                rsDetail.close();
	            } catch (SQLException ignore) {
	            }				
			}			
	        if (stmt != null) {
	            try {
	                stmt.close();
	            } catch (SQLException ignore) {
	            }
	        }
	        if (dstmt != null) {
	            try {
	                dstmt.close();
	            } catch (SQLException ignore) {
	            }
	        }	        
	        if (stmt1 != null) {
	            try {
	                stmt1.close();
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