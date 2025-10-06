package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

import com.lh.servlet.DBServlet;
import com.lh.util.doString;
import com.lh.util.DateUtil;

import serv.common.Constants;
import serv.common.User;
import serv.common.ResvTime;
import serv.common.ChkTime;
import serv.common.BetweenDate;
import serv.common.SERV_CommonData;

import org.apache.poi.hssf.usermodel.*;
import org.apache.poi.hssf.util.*;
/**
 * Servlet implementation class for Servlet: InitResvTimeServlet
 *
 */
 public class ExportOpenChkupServlet extends DBServlet {	 
	 private static String cName = "/LHServ/ExportOpenChkupServlet";
		private void genRedirectCode(PrintWriter out,String page,String redirect,String error,String otherMsg) {
			out.println("<form method='post' action='"+page+"'>");		
			out.println("<input type='hidden' name='error' value='"+error+"'>");
			out.println("<input type='hidden' name='other_msg' value='"+doString.MS874ToUnicode(otherMsg)+"'>");
			out.println("<input type='hidden' name='redirect_url' value='"+doString.MS874ToUnicode(redirect)+"'>");		
			out.println("<script> document.forms[0].submit();</script>");
			out.println("</form>");		
		}	 
	public BetweenDate getBetweenDate(int mnth, int year, int bckMnth) {
		for (int m=1; m<bckMnth; m++) {
			mnth--;
			if (mnth == 0) {
				mnth = 12;
				year--;
			}			
		}// end for
		java.util.Calendar currentCal = java.util.Calendar.getInstance(Locale.ENGLISH);
		currentCal = new GregorianCalendar(year, mnth-1, 1);
		int daysInMonth = currentCal.getActualMaximum(currentCal.DAY_OF_MONTH);		
		String begDate = Integer.toString(year)+"-"+doString.displayNumber("00", mnth)+"-01";
		String endDate = Integer.toString(year)+"-"+doString.displayNumber("00", mnth)+"-"+doString.displayNumber("00", daysInMonth);
		
		
		BetweenDate betweenDate = new BetweenDate(begDate, endDate);
		return betweenDate;
	}		
	public String getStatus(String status) {
		if (status.equals("N")) {
			status = "รอบันทึกนัด";
		}
		if (status.equals("D")) {
			status = "ยกเลิกนัด";
		}
		if (status.equals("R")) {
			status = "บันทึกนัดแล้ว";
		}
		if (status.equals("O")) {
			status = "Open Job";
		}
		if (status.equals("S")) {
			status = "Start Task";
		}
		
		if (status.equals("C")) {
			status = "Complete Task";
		}
		return status;		
	}	

	public String getSeqStatus(String status) {
		int seqNo=0;
		if (status.equals("N")) {
			seqNo = 1;
		}
		if (status.equals("D")) {
			seqNo = 3;
		}
		if (status.equals("R")) {
			seqNo = 2;
		}
		if (status.equals("O")) {
			seqNo = 4;
		}
		if (status.equals("O")) {
			seqNo = 5;
		}		
		if (status.equals("C")) {
			seqNo = 6;
		}
		return Integer.toString(seqNo);		
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
		String empId = user.getEmpId();
		
		String brand = "";
	    String project = doString.checkString(req.getParameter("Project"));
	    String comId = "";
	    String projId = "";
	    String site = "";
	    if (!project.equals("")) {
		    comId = project.substring(0, 2);
		    projId = project.substring(2);
	    }
	    String mnthDate = "";	    
	    String chkDate = "";
	    String docNo = "";
	    String venId = "";
	    String venName = "";
	    String shop = "";
	    String lockId="";
	    int seqNo=0;
		String houseId="";
		String custName="";
		String custTel="";
		String closeDate="";
		String status = "";
		String chkDay = "";
		String chkTime = "";
		String time = "";
		String comment = "";
		String staffId = "";
		String staffName = "";
		String site_restrict = "";
		//------ forward page --------//
		String savePage = Constants.SAVE_PAGE;
		String targetPage = "SERV_OpenChkUp.jsp";
		String errorPage = ""; 		
		String otherMsg = "";
		String errorCode = "";
		doString doStr = new doString();
		StringBuffer sql = new StringBuffer();
	    Connection conn = null;
	    Statement stmt = null;
	    Statement ustmt = null;
	    Statement cstmt = null;
	    Statement sstmt = null;
	    ResultSet rs =null;
	    ResultSet rsChkup =null;
	    ResultSet rsTime =null;
	    ResultSet rsStaff =null;
	    SERV_CommonData common = null;
	    try {
	        if (ds == null)
	            getDS();
	        conn = ds.getConnection();
	        conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	        conn.setAutoCommit(true);
	        stmt = conn.createStatement();
	        ustmt = conn.createStatement();
	        cstmt = conn.createStatement();
	        sstmt = conn.createStatement();
	        common = new SERV_CommonData(conn);
			HSSFWorkbook wb = new HSSFWorkbook();
			HSSFSheet sheet = wb.createSheet("new sheet");
			HSSFRow row = null;
			HSSFCell cell = null;
			String filename ="Checkup.xls";
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
			int line = 0;
			row = sheet.createRow((short) line++);
			
			cell = row.createCell((short) 0);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("รหัสโครงการ");

			cell = row.createCell((short) 1);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("ชื่อโครงการ");
					
			cell = row.createCell((short) 2);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("แปลง");

			cell = row.createCell((short) 3);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("Check Up ครั้งที่");

			cell = row.createCell((short) 4);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("วันนัด Check up");

			cell = row.createCell((short) 5);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("เวลานัด Check up");			
			
			cell = row.createCell((short) 6);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("สถานะ");

			cell = row.createCell((short) 7);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("ร้านค้า");			
			
			cell = row.createCell((short) 8);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("ผรม.Service");			
			
			cell = row.createCell((short) 9);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("บ้านเลขที่");
						

			cell = row.createCell((short) 10);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("ชื่อลูกค้า");
			
			cell = row.createCell((short) 11);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("เบอร์โทรศัพท์");
			
			cell = row.createCell((short) 12);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("วันที่โอน");
			
			cell = row.createCell((short) 13);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("ชื่อเจ้าหน้าที่");

			cell = row.createCell((short) 14);
			cell.setEncoding(HSSFCell.ENCODING_UTF_16);
			cell.setCellStyle(align_head);
			cell.setCellValue("หมายเหตุ");				        
	        
	    	String begDate = common.getValueFromDateListbox("start",req);
	    	String endDate = common.getValueFromDateListbox("end",req);
	    	
	    	
	    	rsStaff = sstmt.executeQuery("SELECT com_id, proj_id FROM lan:serv_pstaff WHERE user_id = '"+userId+"' ORDER BY proj_id DESC");
	    	if (rsStaff != null) {
	    		while (rsStaff.next() == true) {
	    			
	    			comId = doString.checkString(rsStaff.getString("COM_ID"));
	    			projId = doString.checkString(rsStaff.getString("PROJ_ID"));
	    			if (projId.equals("ALL")) {
	    				site_restrict = "";
	    			} else {
	    				site_restrict = " i_company = '"+comId+"' AND i_project = '"+projId+"' AND";
	    			}
	    			
	    		    if (!project.equals("")) {
	    			    comId = project.substring(0, 2);
	    			    projId = project.substring(2);
	    			    site_restrict = " i_company = '"+comId+"' AND i_project = '"+projId+"' AND";
	    		    }	    			
					rsChkup = ustmt.executeQuery("SELECT DISTINCT i_company, i_project, i_lock, i_chkseq, i_month FROM lan:serv_chkupdt WHERE "+site_restrict+" d_chckup >= '"+begDate+"' AND d_chckup <= '"+endDate+"' AND i_chkseq > 0");			
					if (rsChkup != null) {
						while (rsChkup.next() == true) {
							comId = doString.checkString(rsChkup.getString("I_COMPANY"));
							projId = doString.checkString(rsChkup.getString("I_PROJECT"));
							lockId = doString.checkString(rsChkup.getString("I_LOCK"));
							seqNo = rsChkup.getInt("I_CHKSEQ");
							mnthDate = doString.checkString(rsChkup.getString("I_MONTH"));
							Hashtable tmpCust = common.getCustomerDetails(comId,projId,lockId,"");
						    houseId = doString.checkString((String) tmpCust.get("i_house"));
							custName = doString.checkString((String) tmpCust.get("n_customer"));
							custTel = doString.checkString((String) tmpCust.get("n_cust_tel"));
							closeDate = doString.checkString((String) tmpCust.get("close_date"));
							site = "";
							rs = stmt.executeQuery("SELECT n_project FROM lan:acxprojt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
							if (rs != null) {
								if (rs.next() == true) {
									site = doString.checkString(rs.getString("N_PROJECT"));
								}
								rs.close();
								rs=null;
							}
							brand = "";
					    	rs = stmt.executeQuery("SELECT i_brand FROM lan:serv_brand WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
					    	if (rs != null) {
					    		if (rs.next() == true) {
					    			brand = doString.checkString(rs.getString(1));
					    		}
					    		rs.close();
					    		rs=null;
					    	}					
							docNo = "";
							status = "";
							venId = "";
							venName = "";
							comment = "";
							rs = stmt.executeQuery("SELECT i_docno, i_vendor, f_status, c_comment FROM lan:serv_chkuplck WHERE i_month = '"+mnthDate+"' AND i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lock = '"+lockId+"' AND i_chkseq = "+Integer.toString(seqNo)+" AND f_status != 'D'");
							if (rs != null) {
								if (rs.next() == true) {
									docNo = doString.checkString(rs.getString("I_DOCNO"));
									status = doString.checkString(rs.getString("F_STATUS"));
									venId = doString.checkString(rs.getString("I_VENDOR"));
									comment = doString.checkString(rs.getString("C_COMMENT"));
								}
								rs.close();
								rs=null;
							}
							rs = stmt.executeQuery("SELECT bus_name FROM lan:stpvendr WHERE vend_code = '"+venId+"'");
							if (rs != null) {
								if (rs.next() == true) {
									venName = doString.checkString(rs.getString("BUS_NAME"));
								}
								rs.close();
								rs=null;
							}
							
							
							chkDay = "-";
							chkTime = "-";
							chkDate = "";
							staffId = "";
							staffName = "";
							venId = "";
							shop = "";
							rsTime = cstmt.executeQuery("SELECT i_employ, i_vendor, d_chckup, DAY(d_chckup) AS CHK_DAY, i_time FROM lan:serv_chkupdt WHERE i_month = '"+mnthDate+"' AND i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_lock = '"+lockId+"' AND i_chkseq = "+Integer.toString(seqNo));
							if (rsTime != null) {
								if (rsTime.next() == true) {
									staffId = doString.checkString(rsTime.getString("I_EMPLOY"));
									venId = doString.checkString(rsTime.getString("I_VENDOR"));
									chkDay = doString.displayNumber("00", rsTime.getInt("CHK_DAY"));
									chkTime = doString.checkString(rsTime.getString("I_TIME"));
									chkDate = doString.checkString(rsTime.getString("D_CHCKUP"));
								}
								rsTime.close();
								rsTime=null;
							}
						
							rs = stmt.executeQuery("SELECT TRIM(e.n_prename_th) || ' ' || TRIM(e.n_nemploy_th) || ' ' || TRIM(e.n_semploy_th) AS EMP_NAME FROM docflow:acemploy e WHERE e.i_employ = '"+staffId+"'");
							if (rs != null) {
								if (rs.next() == true) {
									staffName = doString.checkString(rs.getString(1));
								}
								rs.close();
								rs=null;
							}			
							rs = stmt.executeQuery("SELECT bus_name FROM lan:stpvendr WHERE vend_code = '"+venId+"'");
							if (rs != null) {
								if (rs.next() == true) {
									shop = doString.checkString(rs.getString("BUS_NAME"));
								}
								rs.close();
								rs=null;
							}					
							
							rsTime = cstmt.executeQuery("SELECT b_time FROM lan:serv_bctime WHERE i_brand = '"+brand+"' AND c_time = '"+chkTime+"'");
							if (rsTime != null) {
								if (rsTime.next() == true) {
									chkTime = doString.checkString(rsTime.getString("B_TIME"));
								} else {
									chkTime = "-";
								}
								rsTime.close();
								rsTime=null;
							}
							time = "";
							if (doString.checkString(chkTime).equals("-")) {
								time = "-";						
							} else {
								rs = stmt.executeQuery("SELECT n_time FROM lan:serv_btime WHERE i_brand = '"+brand+"' AND i_time = '"+chkTime+"'");
								if (rs != null) {
									if (rs.next() == true) {
										time = doString.checkString(rs.getString("N_TIME"));		
									}
									rs.close();
									rs=null;
								}					
							}					
							
							
							row = sheet.createRow((short) line++);
		
							cell = row.createCell((short) 0);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellValue(comId+projId);
							
							cell = row.createCell((short) 1);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellValue(doStr.MS874ToUnicode(site));
							
							cell = row.createCell((short) 2);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellValue(lockId);
							
							cell = row.createCell((short) 3);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellValue(Integer.toString(seqNo));
							
							cell = row.createCell((short) 4);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellValue(DateUtil.ifxToThaiDateNoTime(chkDate));
							
							cell = row.createCell((short) 5);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellValue(doStr.MS874ToUnicode(time));					
							
							cell = row.createCell((short) 6);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellValue(getStatus(status));
		
							cell = row.createCell((short) 7);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellValue(doStr.MS874ToUnicode(shop));					
		
							cell = row.createCell((short) 8);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellValue(doStr.MS874ToUnicode(venName));
							
							cell = row.createCell((short) 9);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellValue(houseId);
							
							cell = row.createCell((short) 10);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellValue(doStr.MS874ToUnicode(custName));
							
							cell = row.createCell((short) 11);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellValue(doStr.MS874ToUnicode(custTel));
		
							cell = row.createCell((short) 12);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellValue(DateUtil.ifxToThaiDateNoTime(closeDate));
							
							cell = row.createCell((short) 13);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellValue(doStr.MS874ToUnicode(staffName));
							
							cell = row.createCell((short) 14);
							cell.setEncoding(HSSFCell.ENCODING_UTF_16);
							cell.setCellValue(doStr.MS874ToUnicode(comment));
							
						}// end while
						rsChkup.close();
						rsChkup=null;
					}
	    			if (site_restrict.equals("")) {
	    				break;
	    			}
	    			if (!project.equals("")) {
	    				break;
	    			}
	    		}// end while
	    		rsStaff.close();
	    		rsStaff=null;
	    	}					
	        stmt.close();
	        ustmt.close();
	        cstmt.close();
	        sstmt.close();
	        conn.close();
	        stmt = null;
	        ustmt = null;
	        cstmt = null;
	        sstmt = null;
	        conn = null;
			wb.write(out);
			out.flush();       
	    } catch (Exception e) {
	        System.out.println("ERROR /LHServ/ExportOpenChkupServlet : " + e.getMessage());
	    } finally {
	        if (stmt != null) {
	            try {
	                stmt.close();
	            } catch (SQLException ignore) {
	            }
	        }
	        if (ustmt != null) {
	            try {
	                ustmt.close();
	            } catch (SQLException ignore) {
	            }
	        }
	        if (cstmt != null) {
	            try {
	                cstmt.close();
	            } catch (SQLException ignore) {
	            }
	        }	   
	        if (sstmt != null) {
	            try {
	                sstmt.close();
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