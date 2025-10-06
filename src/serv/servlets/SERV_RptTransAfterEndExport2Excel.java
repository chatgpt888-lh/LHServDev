package serv.servlets;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import serv.common.User;
import com.lh.servlet.DBServlet;
import com.lh.string.doString;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.hssf.util.Region;

/**
 * Servlet implementation class for Servlet: SERV_RptKeepBeforeExport2ExcelServlet
 * by pradoem
 * 2016.08.02
 */
 public class SERV_RptTransAfterEndExport2Excel extends  DBServlet{
	    /* (non-Java-doc)
		 * @see javax.servlet.http.HttpServlet#HttpServlet()
		 */
		String sysName = "LHServ";
		String clazzName = new String(this.getClass().getName() + ".performTask :");	
		String USER_ID = "";

		public void performTask(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {	  
			System.out.println(clazzName + "start.");   
			//response.setContentType("text/html; charset=TIS-620");
			
			response.setContentType("application/vnd.ms-excel; charset=TIS-620");
			/******************Session User Check************************/
			HttpSession session = request.getSession(false);
		    if (session == null) {
		        /** Redirect user to login page if there's no session.*/
		        response.sendRedirect(request.getContextPath()+"/login.jsp");
		        return;
		    }
		    Object obj = session.getAttribute("USER");
		    if (obj == null) {
		    	System.out.println("----->User is null");
		        /** Redirect user to login page if there's no session.*/
		        response.sendRedirect(request.getContextPath()+"/login.jsp");
		        return;
		    }		    
			User user = (User) obj;	
			/******************Session User Check************************/
			/*****************
			 * medthod action
			 **************** */
			Connection conn = null;	
			try{	
					if (ds == null){getDS();}			
					conn = ds.getConnection();
					conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);

					ServletOutputStream out2 = response.getOutputStream();
					List resultList =   this.doExport2Excel(conn,request, user);
					//System.out.println("Size :"+resultList);
					if(resultList!=null && resultList.size()>0){
			   			  ByteArrayOutputStream baos = new ByteArrayOutputStream();
			   			  HSSFWorkbook wb = GenerateExcelPaperXLS(resultList);
			   			  wb.write(baos);
			   			  String fileName = "Export2Excel_"+NowByCalendar("yyyy-MM-dd")+"_"+NowByCalendar("HH:mm")+".xls"; 	  
			   			  //"Repor2Excel_"+Utilizer.ThaiDate2EngDate(fromDate)+"_TO_"+Utilizer.ThaiDate2EngDate(toDate)+".xls";
			   			  response.setHeader("Content-disposition","inline;filename=\""+fileName+"\"");
			    		  // System.out.println("doExport2Excel ->successfully.");	  	
			   			  response.setContentLength(baos.size());
			   		      //ServletOutputStream out = response.getOutputStream();
			   		      baos.writeTo(out2);
			   		      out2.flush();
			   		      out2 = null;
			   		}
					/****** Clear *******/
					conn.close();
					conn = null;
			}catch(Exception e){
				e.printStackTrace();
				System.out.println(sysName+":"+clazzName +" "+e.toString());		
			}
			finally{
				//System.out.println("======Finally======");
				//clean up.
				try{
					if(conn!=null){conn.close();}
				}catch(Exception e){}
			}
		}	

		//*****method doExport2Excel
		protected List doExport2Excel(Connection conn,HttpServletRequest request,User user) throws ServletException, IOException{
			// TODO Auto-generated method stub
	        try{
	        	//System.out.println("doExport2Excel ->Starting.");
	        	//printOutParam(request,"doFormLoad");
	            //-------------------------
				String tempProjectTxt = doString.checkString(request.getParameter("tempProjectTxt"),"");//LH:151|LH:152|LH:154|LH:156|LH:157
	  			String multiFlag = doString.checkString(request.getParameter("multiFlag"),"0"); //0=ALL Project,1= By project	  
	  			String rbtType = doString.checkString(request.getParameter("rbtType"),"A");//A,B
	 			
	  			String fromDate = doString.checkString(request.getParameter("fromDate"),""); //2016-05-01
	  			String toDate = doString.checkString(request.getParameter("toDate"),""); //2016-05-31		
	  			
	  			USER_ID = user.getUserName();
	  			String temp_tbtProject = "temp_proj_"+USER_ID;	
	  			if(multiFlag.equals("0")){//TODO: CASE : ALL Project
	  				GeneratePreparedIntoTempTableFor$DESC(conn, true, temp_tbtProject, tempProjectTxt);
		  		 }else{//TODO: CASE : By project  			
		        	 /************************************************/
		             //1.Insert project to temp table
		  			GeneratePreparedIntoTempTableFor$DESC(conn, false, temp_tbtProject, tempProjectTxt);		 	
		  			//selProjectList = this.ListProjectSelect(conn, tempProjectTxt);
		  		 }//#IF End Check ALL Proj
	  			
	  			List resultList = this.ListDetailsExport2Excel$IPV_QCHD(conn,fromDate, toDate, rbtType, temp_tbtProject);
				return resultList;
			}catch(Exception e){
				System.out.println("!!! doExport2Excel , " +sysName+":"+ clazzName + " : " + e.getMessage());	
				return null;
			}
			finally{			
			}
		} 
		//CAT_TYPE = MAIN,SUB,ITEMS  Export2Excel
		public ArrayList<List> ListDetailsExport2Excel$IPV_QCHD(Connection conn,String fromDate,String toDate,String typeRpt,String tempTableName) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	        try{
	        	//initial parameter		
	        	//int line = 0;
	        	//System.out.println("##ListDetailsExport2Excel$IPV_QCHD$->Starting.");   
	        	ArrayList<List>  resultList = new ArrayList<List> ();
	        	List strArr = null;  
	    		sql.delete(0, sql.length());
	     		sql.append(" Select unique  a.i_company,a.i_project,c.i_sort,c.d_close_law as DCLOSE,a.i_docno,a.i_vendor,a.i_ipv_docno,a.i_type,a.f_status,a.c_desc,a.d_keyin as DKEYIN   ")
	     		   .append(" ,b.i_in_out, a.f_qa_type,a.i_qa_vendor ,b.i_itmno,b.z_amount_pv,d.date_qc ,c.d_close_law - d.date_qc as diffDay ")
	     		   .append(" From lan:ipv_qchd a,lan:ipv_qcdt b,lan:acscontr c,lan:acxlckhd d , "+tempTableName+" x ")
	     		   .append(" Where a.i_docno = b.i_qc_docno  ")
	     		   .append(" and a.i_project <> '' ")
	     		   .append(" and a.i_company =  c.i_company  ")
	     		   .append(" and a.i_project =  c.i_project ")
	     		   .append(" and a.i_lock =  c.i_sort ")
	     		   .append(" and a.i_company =  d.i_company ")
	     		   .append(" and a.i_project =  d.i_project ")
	     		   .append(" and a.i_lock =  d.i_lock ")
	     		   .append(" and a.f_status <> 'CAN' ")
	     		   .append(" AND ((a.i_type = '1' and a.i_ipv_docno is not null ) or (a.i_type in ('2','3','4'))) ")
	     		   .append(" and a.i_company =  x.com_id  ")
	     		   .append(" and a.i_project =  x.proj_id ")
	     		   .append(" and c.d_close_law is not null ");	
	     		   
	     		/*if("01".equals(CAT_TYPE)){
		     		   sql.append(" and b.i_itmno[1,2] = '"+groupNo+"' ");
		     		}else if("02".equals(CAT_TYPE)){
			     	   sql.append(" and b.i_itmno[1,2] = '"+groupNo+"' ")
			     		  .append(" and b.i_itmno[3,4] = '"+subNo+"' ");
		     		}else if("03".equals(CAT_TYPE)){
		     		    sql.append(" and b.i_itmno = '"+itemsNo+"'   ");
		     		}*/
	     		
		     		if("A".equals(typeRpt)){
	 	     			sql.append(" and c.d_close_law  between '"+fromDate+"' and '"+toDate+"' ");
	 	     		}else if("B".equals(typeRpt)){
	 	     			sql.append(" and date(a.d_keyin)  between '"+fromDate+"' and '"+toDate+"' ");
	 	     		}
		     		//sql.append(this.GetWhereDiffDate(xid))
		     		sql.append(" ORDER by  a.i_company,a.i_project,c.i_sort ");
		     	//System.out.println("SQL detail 2 Excel : "+sql.toString());
		     	pstmt = conn.prepareStatement(sql.toString()); 
				rs = pstmt.executeQuery();
				while(rs.next()){
				//for (int i=0;i<maxRow;i++) { 
		        //if (rs.next()) {
		        //if (i>=startRow && i<=endRow) {	
			   		strArr = new ArrayList();
			   		strArr.add(0,doString.checkString(rs.getString("i_company"),""));//i_company		  
			   		strArr.add(1,doString.checkString(rs.getString("i_project"),""));//i_project
			   		strArr.add(2,doString.checkString(rs.getString("i_sort"),""));//i_sort	
			   		strArr.add(3,toDDMMYY_THAI2(doString.checkString(rs.getString("DCLOSE"),"")));//DCLOSE
			   		strArr.add(4,doString.checkString(rs.getString("i_docno"),""));//i_docno-----------------------KEY is Available
			   		strArr.add(5,doString.checkString(rs.getString("i_vendor"),""));//i_vendor
			   		strArr.add(6,doString.checkString(rs.getString("i_ipv_docno"),""));//i_ipv_docno
			   		strArr.add(7,doString.checkString(rs.getString("i_type"),""));//i_type
			   		strArr.add(8,doString.checkString(rs.getString("f_status"),""));//f_status
			   		strArr.add(9,doString.checkString(rs.getString("c_desc"),""));//c_desc
			   		strArr.add(10,toDDMMYY_TIME_THAI2(doString.checkString(rs.getString("DKEYIN"),"")));//D_Keyin 2014-09-11
			   				    
			   		strArr.add(11,GetProjectName(conn, doString.checkString(rs.getString("i_company"),""),doString.checkString(rs.getString("i_project"),"")));//N_project
			   		if(isValueStrAndObj(rs.getString("i_vendor"))){
			   			strArr.add(12,GetVendorName(conn, doString.checkString(rs.getString("i_vendor"),"")));
			   		}else{
			   			strArr.add(12,"");
			   		}
			   		strArr.add(13,doString.checkString(rs.getString("i_in_out"),""));//i_in_out
			   		strArr.add(14,doString.checkString(rs.getString("i_itmno"),""));//i_itmno
			   		strArr.add(15,doString.checkString(rs.getString("z_amount_pv"),"0.0"));//c_desc
			   		strArr.add(16,"");
			   		if(isValueStrAndObj(rs.getString("i_ipv_docno"))){
			   			strArr.add(16,toDDMMYY_THAI2(this.GetDpayFrom$IPV_PVDHD(conn, rs.getString("i_ipv_docno"))));
			   		}
			   		strArr.add(17,toDDMMYY_THAI2(doString.checkString(rs.getString("date_qc"),"")));//date_qc
			   		strArr.add(18,doString.checkString(rs.getString("diffDay"),""));//diffDay
			   		
		   			strArr.add(19, doString.checkString(rs.getString("f_qa_type"),""));//null,1,2
		   			if(isValueStrAndObj(rs.getString("f_qa_type"))){
		   				strArr.add(20,"");
		   				if(doString.checkString(rs.getString("f_qa_type"),"").equals("2") && isValueStrAndObj(rs.getString("i_qa_vendor"))){
			   				strArr.add(20,GetVendorNameQA(conn,doString.checkString(rs.getString("i_qa_vendor"),"")));
		   				}
		   			}else{
		   				strArr.add(20,"");
		   			}
			   		resultList.add(strArr);	
				    //line++;                         
		            //} //--end if check row
			        //if (i>endRow){ 
			        //break;
			        //}
		            //} //end if check rs
			    } // end for
				//********************************************************/	
				//System.out.println(" ========Successfully=========== ");	
	        	return resultList;			  	 
			}catch(Exception e){
				System.out.println("!!!ListDetailsExport2Excel$IPV_QCHD$ , " +sysName+":"+ clazzName + " : " + e.getMessage());
				System.out.println(" SQL Exception: "+sql.toString());		
				return null;
			}
			finally{			
				//clean up.
				try{
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
				}catch(Exception e){}
			}
		}
		private String GetDpayFrom$IPV_PVDHD(Connection conn, String docId) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			String  dPay = "";
	        try{
	        	//initial parameter	     	
				/*************************************************/			
				sql.delete(0,sql.length());
				sql.append(" Select  d_pay  ")
				   .append(" From lan:ipv_pvdhd  ")
				   .append(" Where  i_docno = ? ");
				pstmt = conn.prepareStatement(sql.toString()); 
				pstmt.setString(1, docId);	
				//System.out.println("SQL :"+sql.toString());
				rs = pstmt.executeQuery();	
				if(rs.next()){
					dPay = doString.checkString(rs.getString("d_pay"), "");
				}
				rs.close();	
		   			
				//**************************************************/
			  	//System.out.println("##GetDpayFrom$IPV_PVDHD ->successfully.");				  	 
			  	return dPay;			  	 
			}catch(Exception e){
				System.out.println("!!!GetDpayFrom$IPV_PVDHD , " +sysName+":"+ clazzName + " : " + e.getMessage());
				System.out.println(" SQL Exception: "+sql.toString());		
				return "";
			}
			finally{			
				//clean up.
				try{
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
				}catch(Exception e){}
			}
		}					
		private  HSSFWorkbook GenerateExcelPaperXLS(List excelData) throws Exception{		
	        HSSFWorkbook wb = new HSSFWorkbook();
	        HSSFSheet sheet = wb.createSheet("New Sheet");
	        HSSFRow row = null;
	        HSSFCell cell = null;
	        HSSFCellStyle align_head = wb.createCellStyle();
	        HSSFCellStyle align_center = wb.createCellStyle();
	        HSSFCellStyle align_right = wb.createCellStyle();
	        HSSFCellStyle align_left = wb.createCellStyle();
	        HSSFCellStyle align_left2 = wb.createCellStyle();

	       // HSSFCellStyle alignCenter1 = wb.createCellStyle();
	        HSSFCellStyle alignCenter2 = wb.createCellStyle();
	        
	        //-----------------------------
	       // alignCenter1.setAlignment(HSSFCellStyle.ALIGN_CENTER);
	        alignCenter2.setAlignment(HSSFCellStyle.ALIGN_CENTER);
	        
	        align_head.setAlignment(HSSFCellStyle.ALIGN_CENTER);
	        align_center.setAlignment(HSSFCellStyle.ALIGN_CENTER);
	        align_right.setAlignment(HSSFCellStyle.ALIGN_RIGHT);
	        align_left2.setAlignment(HSSFCellStyle.ALIGN_LEFT);
	        
	        /******************/ 
	        /*#set color & border to "align_head"
	         * ****************/ 
	        alignCenter2.setFillForegroundColor(HSSFColor.AQUA.index);
	        alignCenter2.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
	        alignCenter2.setBorderBottom(HSSFCellStyle.BORDER_THIN);
	        alignCenter2.setBottomBorderColor(HSSFColor.BLACK.index);
	        alignCenter2.setBorderLeft(HSSFCellStyle.BORDER_THIN);
	        alignCenter2.setLeftBorderColor(HSSFColor.BLACK.index);
	        alignCenter2.setBorderRight(HSSFCellStyle.BORDER_THIN);
	        alignCenter2.setRightBorderColor(HSSFColor.BLACK.index);
	        alignCenter2.setBorderTop(HSSFCellStyle.BORDER_MEDIUM_DASHED);
	        alignCenter2.setTopBorderColor(HSSFColor.BLACK.index);

	        /******************/ 
	        /*#set color & border to "align_head"
	         * ****************/ 
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
	     
	        
	        /******************/ 
	        /*#set color & border to  align_right
	         * ****************/ 
	        align_right.setFillForegroundColor(HSSFColor.GREY_25_PERCENT.index);
	        align_right.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
	        align_right.setBorderBottom(HSSFCellStyle.BORDER_THIN);
	        align_right.setBottomBorderColor(HSSFColor.BLACK.index);
	        align_right.setBorderLeft(HSSFCellStyle.BORDER_THIN);
	        align_right.setLeftBorderColor(HSSFColor.BLACK.index);
	        //align_right.setBorderRight(HSSFCellStyle.BORDER_THIN);
	        //align_right.setRightBorderColor(HSSFColor.BLACK.index);
	        align_right.setBorderTop(HSSFCellStyle.BORDER_MEDIUM_DASHED);

	        align_right.setTopBorderColor(HSSFColor.BLACK.index);
	        /******************/ 
	        /*#set color & border to  align_left
	         * ****************/ 
	        
	        align_left.setFillForegroundColor(HSSFColor.GREY_25_PERCENT.index);
	        align_left.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
	        align_left.setBorderBottom(HSSFCellStyle.BORDER_THIN);
	        align_left.setBottomBorderColor(HSSFColor.BLACK.index);
	        //align_left.setBorderLeft(HSSFCellStyle.BORDER_THIN);
	        //align_left.setLeftBorderColor(HSSFColor.BLACK.index);
	        align_left.setBorderRight(HSSFCellStyle.BORDER_THIN);
	        align_left.setRightBorderColor(HSSFColor.BLACK.index);
	        align_left.setBorderTop(HSSFCellStyle.BORDER_MEDIUM_DASHED);
	        align_left.setTopBorderColor(HSSFColor.BLACK.index);
	       
	        /******************/ 
	        /*#set width to column in sheet
	         * ****************/
	        int i = 0;
	        sheet.setColumnWidth((short) i++, (short) 1500); //0
	        sheet.setColumnWidth((short) i++, (short) 10000);//1
	        sheet.setColumnWidth((short) i++, (short) 2500);//2
	        sheet.setColumnWidth((short) i++, (short) 3500);//3
	        sheet.setColumnWidth((short) i++, (short) 3500);//4
	        sheet.setColumnWidth((short) i++, (short) 3500);//5
	        sheet.setColumnWidth((short) i++, (short) 8000);//6
	        sheet.setColumnWidth((short) i++,(short)  4500);//7
	        sheet.setColumnWidth((short) i++, (short) 2500);//8
	        sheet.setColumnWidth((short) i++, (short) 2500);//9
	        sheet.setColumnWidth((short) i++, (short) 10000);//10
	        sheet.setColumnWidth((short) i++, (short) 4500);//11
	        sheet.setColumnWidth((short) i++, (short) 4500);//12
	        sheet.setColumnWidth((short) i++, (short) 4500);//13
	        sheet.setColumnWidth((short) i++, (short) 4500);//14
	        sheet.setColumnWidth((short) i++, (short) 4500);//15
	        sheet.setColumnWidth((short) i++, (short) 5000);//16
	        sheet.setColumnWidth((short) i++, (short) 5000);//17
	        sheet.setColumnWidth((short) i++, (short) 5000);//18
	        sheet.setColumnWidth((short) i++, (short) 5000);//19

	        /******************/ 
	        /*#  Header
	         *# Create a row and put some cells in it. Rows are 0 based.
	         * ****************/ 
	        row = sheet.createRow((short) 0);
	        row.setHeight((short) 400);
	        /******************/ 
	        /*# Create a cell and put a value in it.
	         * ****************/ 
	        i = 0;
	        /** == H0 ==*/
	        cell = row.createCell((short)i++);
	        cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	        cell.setCellStyle(align_head);
	        cell.setCellValue("NO.");
	       
	        /** == H1 ==*/
	        cell = row.createCell((short)i++);
	        cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	        cell.setCellStyle(align_head);
	        cell.setCellValue("รหัส-โครงการ");

	        /** == H2 ==*/
	        cell = row.createCell((short)i++);
	        cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	        cell.setCellStyle(align_head);
	        cell.setCellValue("แปลง");

	        /** == H3 ==*/
	        cell = row.createCell((short)i++);
	        cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	        cell.setCellStyle(align_head);
	        cell.setCellValue("วันที่โอน");

	        /** == H4 ==*/
	        cell = row.createCell((short)i++);
	        cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	        cell.setCellStyle(align_head);
	        cell.setCellValue("เลขที่เอกสาร");
	        
	        /** == H5 ==*/
	        cell = row.createCell((short)i++);
	        cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	        cell.setCellStyle(align_head);
	        cell.setCellValue("รหัส ผรม.");

	        
	        /** == H6 ==*/
	        cell = row.createCell((short)i++);
	        cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	        cell.setCellStyle(align_head);
	        cell.setCellValue("ชื่อ ผรม.");

	        /** == H7 ==*/
	        cell = row.createCell((short)i++);
	        cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	        cell.setCellStyle(align_head);
	        cell.setCellValue("รหัส IPV");
	        
	        /** == H8 ==*/
	        cell = row.createCell((short)i++);
	        cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	        cell.setCellStyle(align_head);
	        cell.setCellValue("ประเภท");
	        
	        /** == H9 ==*/
	        cell = row.createCell((short)i++);
	        cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	        cell.setCellStyle(align_head);
	        cell.setCellValue("Status");
	        
	        /** == H10 ==*/
	        cell = row.createCell((short)i++);
	        cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	        cell.setCellStyle(align_head);
	        cell.setCellValue("รายละเอียด");
	        
	        /** == H11 ==*/
	        cell = row.createCell((short)i++);
	        cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	        cell.setCellStyle(align_head);
	        cell.setCellValue("วันที่ KEY");

	        /** == H12 ==*/
	        cell = row.createCell((short)i++);
	        cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	        cell.setCellStyle(align_head);
	        cell.setCellValue("IN_OUT");

	        /** == H13 ==*/
	        cell = row.createCell((short)i++);
	        cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	        cell.setCellStyle(align_head);
	        cell.setCellValue("รหัสวัสดุ");
	        
	        /** == H14 ==*/
	        cell = row.createCell((short)i++);
	        cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	        cell.setCellStyle(align_head);
	        cell.setCellValue("จำนวนเงิน");
	        
	        /** == H15 ==*/
	        cell = row.createCell((short)i++);
	        cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	        cell.setCellStyle(align_head);
	        cell.setCellValue("วันที่จ่าย");
	        
	        /** == H16 ==*/
	        cell = row.createCell((short)i++);
	        cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	        cell.setCellStyle(align_head);
	        cell.setCellValue("วันที่ END");
	        
	        /** == H17 ==*/
	        cell = row.createCell((short)i++);
	        cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	        cell.setCellStyle(align_head);
	        cell.setCellValue("DIFF DATE");
	        
	        /** == H18 ==*/
	        cell = row.createCell((short)i++);
	        cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	        cell.setCellStyle(align_head);
	        cell.setCellValue("ประเภทการตรวจบ้าน");
	        
	        /** == H19 ==*/
	        cell = row.createCell((short)i++);
	        cell.setEncoding(HSSFCell.ENCODING_UTF_16);
	        cell.setCellStyle(align_head);
	        cell.setCellValue("ชื่อบริษัทรับตรวจบ้าน");
	        
	       
	        /* ==Merged Column==
	        Region region = new Region();//new Region(firstRow, firstCol, lastRow, lastCol);	    
		    region.setRowFrom((short)0);
		    region.setColumnFrom((short)9);
		    region.setRowTo((short)0);
		    region.setColumnTo((short)12);
		    sheet.addMergedRegion(region);*/
	        //***********************
	        if(excelData !=null && excelData.size()>0){
				//int x = 1;
				i=1;
				//String bgColor = "";
				List arrList = null;	
				String temp = "";
				Iterator it = excelData.iterator();								   							   
				while(it.hasNext()){								
					arrList =(ArrayList)it.next();	
					//HSSFCellStyle cellHSS = (HSSFCellStyle)align_center; 
					//if(x%2==0){
					//bgColor = " bgcolor= '#f0f0f0'";
					//cellHSS = (HSSFCellStyle)alignCenter2; 
					//}	
					
					//****************************
					//Generate Excel Row
	        		 row = sheet.createRow((short) i);
	         	 	 row.setHeight((short) 300);
	         	 	 
	         	 	 /** == H0  NO.==*/
					 cell = row.createCell((short) 0);
		             cell.setCellStyle(align_left2);
		             cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		             cell.setCellValue(i++);//----------------------------------->>> i++ row counter
		             
		             /** == H1 รหัส-โครงการ==*/
		             cell = row.createCell((short) 1);
		             cell.setCellStyle(align_left2);
		             cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		             cell.setCellValue(arrList.get(0).toString()+"-"+arrList.get(1).toString()+" "+doString.DisplayThai(arrList.get(11).toString())); //LH-075-xxxx

		             /** == H2 แปลง==*/
		             cell = row.createCell((short) 2);
		             cell.setCellStyle(align_left2);
		             cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		             cell.setCellValue(doString.DisplayThai(arrList.get(2).toString()));

		             /** == H3 D_CLOSE_LAW==*/
		             cell = row.createCell((short) 3);
		             cell.setCellStyle(align_left2);
		             cell.setEncoding(HSSFCell.ENCODING_UTF_16);//
		             cell.setCellValue(arrList.get(3).toString()); //doString.MS874ToUnicode(doString.checkString(rs.getString("i_emeter")))

		             /** == H4  เลขที่เอกสาร ==*/
		             cell = row.createCell((short) 4);
		             cell.setCellStyle(align_left2);
		             cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		             cell.setCellValue(arrList.get(4).toString());

		             /** == H5 รหัส VENDOR==*/
		             cell = row.createCell((short) 5);
		             cell.setCellStyle(align_left2);
					 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
					 cell.setCellValue(arrList.get(5).toString());		
					 
					 /** == H6 VENDOR_NAME==*/
		             cell = row.createCell((short)6);
		             cell.setCellStyle(align_left2);
					 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
					 cell.setCellValue(doString.DisplayThai(arrList.get(12).toString()));
					 
					 /** == H7 รหัส IPV==*/
		             cell = row.createCell((short)7);
		             cell.setCellStyle(align_left2);
					 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
					 cell.setCellValue(arrList.get(6).toString());
					 
					 /** == H8 ประเภท==*/
		             cell = row.createCell((short)8);
		             cell.setCellStyle(align_left2);
					 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
					 cell.setCellValue(arrList.get(7).toString());
					 
					 /** == H9 Status==*/
		             cell = row.createCell((short)9);
		             cell.setCellStyle(align_left2);
					 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
					 cell.setCellValue(arrList.get(8).toString());
					 
					 /** == H10 รายละเอียด==*/
		             cell = row.createCell((short)10);
		             cell.setCellStyle(align_left2);
					 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
					 cell.setCellValue(doString.DisplayThai(arrList.get(9).toString()));
					 
					 /** == H11 วันที่ KEY==*/
		             cell = row.createCell((short)11);
		             cell.setCellStyle(align_left2);
					 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
					 cell.setCellValue(arrList.get(10).toString());

					 /** == H12 N_COMPANY==*/
		             /*cell = row.createCell((short)11);
		             cell.setCellStyle(align_left2);
					 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
					 cell.setCellValue(arrList.get(11).toString());*/

					 /** == H13 IN_OUT==*/
		             cell = row.createCell((short)12);
		             cell.setCellStyle(align_left2);
					 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
					 cell.setCellValue(arrList.get(13).toString());

					 /** == H14 รหัสย่อย==*/
		             cell = row.createCell((short)13);
		             cell.setCellStyle(align_left2);
					 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
					 cell.setCellValue(arrList.get(14).toString());
					 
					 /** == H15 Z_AMOUNT==*/
		             cell = row.createCell((short)14);
		             cell.setCellStyle(align_left2);
					 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
					 cell.setCellValue(arrList.get(15).toString());
					 
					 /** == H16 วันที่จ่าย==*/
		             cell = row.createCell((short)15);
		             cell.setCellStyle(align_left2);
					 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
					 cell.setCellValue(arrList.get(16).toString());
					 
					 /** == H17 วันที่ END==*/
		             cell = row.createCell((short)16);
		             cell.setCellStyle(align_left2);
					 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
					 cell.setCellValue(arrList.get(17).toString());
					 
					 /** == H18 DIFF DATE==*/
		             cell = row.createCell((short)17);
		             cell.setCellStyle(align_left2);
					 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
					 cell.setCellValue(arrList.get(18).toString());
					 
					 /** == H19 xxxxxxx==*/
		             cell = row.createCell((short)18);
		             cell.setCellStyle(align_left2);
					 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
					 temp = "";
					 if(arrList.get(19).toString().equals("1")){
						 temp  = "ลูกค้าตรวจเอง";
					 }else if(arrList.get(19).toString().equals("2")){
						 temp  = "บริษัทรับตรวจบ้าน";
					 } 
					 cell.setCellValue(temp);
					 
					 /** == H20 xxxxxxx==*/
		             cell = row.createCell((short)19);
		             cell.setCellStyle(align_left2);
					 cell.setEncoding(HSSFCell.ENCODING_UTF_16);
					 cell.setCellValue(arrList.get(20).toString());
				}
	        }
	        //***********************
	        return wb;
		}
		
		private void InsertTempTableProjectFor$DESC(Connection conn,String tempTableProject, String tempProjectSelect) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	        try{
	        	//initial parameter	        
	        	String sqlDelete = " Delete "+tempTableProject;
	        	//int i=1;
	        	//System.out.println("##InsertTempTableProjectFor$DESC ->Starting.");        	 
				/******************************************************/
	        	try{
		        	sql.delete(0, sql.length());
					sql.append(" Create temp table "+tempTableProject+" (  ")
					   .append(" com_id char(2),  ")
					   .append(" proj_id char(3) ")
					   .append(" ); ");	
		        	pstmt = conn.prepareStatement(sql.toString()); 
		        	pstmt.executeUpdate();
		        	//System.out.println("-->1. executeUpdate : temp  :"+tempTableProject);
	        	}catch(Exception e){
	        		System.err.println("MSG == already exists in session (bck."+tempTableProject+") ==");
		        	//pstmt = conn.prepareStatement(sqlDelete); 
		        	//pstmt.executeUpdate();
		        	//System.out.println("==========Return End ==============");
	        		return;
	        	}
	        	//insert into tblByProject values( "LH","075" )
				sql.delete(0, sql.length());
				sql.append(" INSERT INTO  "+tempTableProject+"(com_id,proj_id)  VALUES( ? , ? ); ");
				//System.out.println("2.Insert SQL :"+sql.toString());
			    pstmt = conn.prepareStatement(sql.toString()); 
			    
			    String [] temp = null;
			    final int batchSize = 1000;//1000;
			    int count = 0;
	        	if(tempProjectSelect.length()> 0){
	        		String []projectArr = tempProjectSelect.split("\\|");             
	        		for(int n = 0;n<projectArr.length;n++){
	        			temp = projectArr[n].split("\\:");
	        			pstmt.setString(1, temp[0]);
	     			    pstmt.setString(2, temp[1]);
	     			    //pstmt.executeUpdate();
	     			    //System.out.println("---Insert Okay :"+n);
	     			    pstmt.addBatch();
		  		    	if(++count % batchSize == 0) {
		  		    		 pstmt.executeBatch();
		  		    		 pstmt.clearBatch();//clear the batch after execution
		  		    	     count = 0;//reset count
		  		    	}//#End IF
	        		}//#End For
	    		    pstmt.executeBatch();
	        	}
				//********************************************************/
			  	//System.out.println("##InsertTempTableProjectFor$DESC ->successfully.");				  	 		  	 
			}catch(Exception e){
				System.out.println("!!InsertTempTableProjectFor$DESC , " +sysName+":"+ clazzName + " : " + e.getMessage());
				System.out.println(" SQL Exception: "+sql.toString());		
			}
			finally{			
				//clean up.
				try{
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
				}catch(Exception e){}
			}
		}
		private void GeneratePreparedIntoTempTableFor$DESC(Connection conn,boolean isALL,String temp_tbtProject,String tempProjectTxt) {
			StringBuffer sql1 = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	        try{
	        	//initial parameter	
	    		/************************************************/
	        	//1.Insert project to temp table
	    		/************************************************/
	  			if(isALL){
	  				this.InsertTempTableProjectALL$ForDesc(conn, temp_tbtProject);
	  			}else{
	        		this.InsertTempTableProjectFor$DESC(conn,temp_tbtProject,tempProjectTxt);	
	  			}     	
	    		/************************************************/		 
			}catch(Exception e){
				System.out.println("!!!GeneratePreparedIntoTempTableFor$DESC, " +sysName+":"+ clazzName + " : " + e.getMessage());
				System.out.println(" SQL Exception: "+sql1.toString());		
			}
			finally{			
				//clean up.
				try{
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
				}catch(Exception e){}
			}	
		}
		private void InsertTempTableProjectALL$ForDesc(Connection conn,String tempTableProject) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
	        try{
	        	//initial parameter	        
	        	String sqlDelete = " Delete "+tempTableProject;
	        	//int i=1;
	        	//System.out.println("##InsertTempTableProjectALL$ForDesc ->Starting.");        	 
				/******************************************************/
	        	try{
		        	sql.delete(0, sql.length());
					sql.append(" Create temp table "+tempTableProject+" (  ")
					   .append(" com_id char(2),  ")
					   .append(" proj_id char(3) ")
					   .append(" ); ");	
		        	pstmt = conn.prepareStatement(sql.toString()); 
		        	pstmt.executeUpdate();
		        	//System.out.println("-->1. executeUpdate : temp  :"+tempTableProject);
	        	}catch(Exception e){
	        		System.err.println("MSG == already exists in session (bck."+tempTableProject+") ==");
		        	//pstmt = conn.prepareStatement(sqlDelete); 
		        	//pstmt.executeUpdate();
		        	//System.out.println("=====Return END=========");
		        	return;
	        	}

	 			sql.delete(0, sql.length());
	 			sql.append(" Select  distinct a.i_company ,a.i_project ")
	 			   .append(" From lan:acsbudgh a ,lan:acxprojt b ")
	 			   .append(" Where a.d_year = year(TODAY)+543  and  a.i_budg_type in ('1','2','9') and  (a.i_company = b.i_company) and (a.i_project= b.i_project)  ")
	 			   .append(" AND a.i_project[1,1]<> 'G' ")
	 			   .append(" Order By i_company,i_project ");	
	 			pstmt = conn.prepareStatement(sql.toString()); 
	 			rs = pstmt.executeQuery();	
	 			
	 			
	        	//insert into tblByProject values( "LH","075" )
				sql.delete(0, sql.length());
				sql.append(" INSERT INTO  "+tempTableProject+"(com_id,proj_id)  VALUES( ? , ? ); ");
				//System.out.println("2.Insert SQL :"+sql.toString());
			    pstmt = conn.prepareStatement(sql.toString()); 

			    final int batchSize = 1000;//1000;
			    int count = 0;
			    
				while(rs.next()){
					pstmt.setString(1,doString.checkString(rs.getString("i_company"),""));
	 			    pstmt.setString(2,doString.checkString(rs.getString("i_project"),""));				
	 			    pstmt.addBatch();
	 			    if(++count % batchSize == 0) {
				    	pstmt.executeBatch();
				    	pstmt.clearBatch();//clear the batch after execution
				    	count = 0;//reset count
			    	}//#End IF
				}		    
			    pstmt.executeBatch();
				//********************************************************/
			  	//System.out.println("##InsertTempTableProjectALL$ForDesc ->successfully.");				  	 		  	 
			}catch(Exception e){
				System.out.println("!!InsertTempTableProjectALL$ForDesc , " +sysName+":"+ clazzName + " : " + e.getMessage());
				System.out.println(" SQL Exception: "+sql.toString());		
			}
			finally{			
				//clean up.
				try{
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
				}catch(Exception e){}
			}
		}
		private String GetVendorName(Connection conn, String vendorId) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			String  tempName = "";
	        try{
	        	//initial parameter	     	
				/*************************************************/			
				sql.delete(0,sql.length());
				sql.append(" Select a.i_vendor,b.bus_name   ")
				   .append(" From lan:ipv_vendor a,lan:stpvendr b ")
				   .append(" Where  a.i_vendor = b.vend_code ")
				   .append(" and  a.i_vendor = ? ");
				pstmt = conn.prepareStatement(sql.toString()); 
				pstmt.setString(1, vendorId);	
				//System.out.println("SQL :"+sql.toString());
				rs = pstmt.executeQuery();	
				if(rs.next()){
					tempName = doString.checkString(rs.getString("bus_name"), "");
				}
				rs.close();	
		   			
				//**************************************************/
			  	//System.out.println("##GetVendorName ->successfully.");				  	 
			  	return tempName;			  	 
			}catch(Exception e){
				System.out.println("!!!GetVendorName , " +sysName+":"+ clazzName + " : " + e.getMessage());
				System.out.println(" SQL Exception: "+sql.toString());		
				return "";
			}
			finally{			
				//clean up.
				try{
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
				}catch(Exception e){}
			}
		}	
		
		private static String GetVendorNameQA(Connection conn, String vendorId) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			String  tempName = "";
	        try{
	        	//initial paramter	     	
				/*************************************************/			
				sql.delete(0,sql.length());
				sql.append(" select I_COMPANY,I_PROJECT,I_VENDOR,N_VENDOR,C_DESC,STATUS from lan:IPV_QCVENDOR ")
				   .append(" WHERE STATUS = 'A' ")
				   .append(" and I_VENDOR = ? ");
				pstmt = conn.prepareStatement(sql.toString());
				pstmt.setString(1, vendorId); //vendorId
				rs = pstmt.executeQuery();
				if(rs.next()){
					tempName = doString.DisplayThai(doString.checkString(rs.getString("N_VENDOR"), ""));
				}
				rs.close();	
			}catch(Exception e){
	 				System.out.println("!!! GetVendorNameQA Error : " + e.getMessage());
			}
			finally{			
				//clean up.
				try{
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
				}catch(Exception e){}
			}
		  return tempName;		
		}
		
		private String GetProjectName(Connection conn, String comId, String projectId) {
			StringBuffer sql = new StringBuffer();	
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			String  projectNamme = "";
	        try{
	        	//initial paramter	     	
				/*************************************************/			
	        	//*****Find project by user login  
				sql.delete(0,sql.length());
				sql.append("Select n_project From lan:acxprojt Where i_company = ? and i_project = ? ");
				pstmt = conn.prepareStatement(sql.toString()); 
				pstmt.setString(1, comId);	
				pstmt.setString(2, projectId);
				//System.out.println("SQL :"+sql.toString());
				rs = pstmt.executeQuery();	
				if(rs.next()){
					projectNamme = doString.checkString(rs.getString("n_project"), "");
				}
				rs.close();	
		   			
				//**************************************************/
			  	//System.out.println("##GetProjectName ->successfully.");				  	 
			  	return projectNamme;			  	 
			}catch(Exception e){
				System.out.println("!!!GetProjectName , " +sysName+":"+ clazzName + " : " + e.getMessage());
				System.out.println(" SQL Exception: "+sql.toString());		
				return "";
			}
			finally{			
				//clean up.
				try{
					if(rs!=null){rs.close();}
					if(pstmt!=null){pstmt.close();}
				}catch(Exception e){}
			}
		}
		//2016-04-25 22:10:00
		private static  String toDDMMYY_TIME_THAI2(String str){
			 if ((str == null) || str.equals("")) {
				 return  str;
			 }else{
				 String temp[] = str.split("\\ ");//2016-04-25 22:10:00
				 
				 String d2[] = temp[0].split("\\-"); //2013-03-29
				 return d2[2]+"/"+d2[1]+"/"+(Integer.parseInt(d2[0])+543+" "+temp[1].substring(0,5));
			 }
		}
		
		private static  String toDDMMYY_THAI2(String str){
			 if ((str == null) || str.equals("")) {
				 return  str;
			 }else{
				 String d2[] = str.split("\\-"); //2013-03-29
				 return d2[2]+"/"+d2[1]+"/"+(Integer.parseInt(d2[0])+543);
			 }
		}
		//false = object is null / str is ""
		//true = object have value / string hava value 
		private static boolean isValueStrAndObj(String str) throws Exception{
			if ((str == null) || str.equals("")) {
				 return false;
			}else{
				 return true;
			 }
		} 
				
		 //input :yyyy-MM-dd
		 //output :2013-10-17
		 // use : System.out.println(Utilizer.NowByCalendar("yyyy-MM-dd"));
		 //System.out.println(Utilizer.NowByCalendar("H:mm"));
		 private static String NowByCalendar(String dateFormat) {
			 Calendar cal = Calendar.getInstance(Locale.ENGLISH);
			 SimpleDateFormat sdf = new SimpleDateFormat(dateFormat);
			 return sdf.format(cal.getTime());
		}
}