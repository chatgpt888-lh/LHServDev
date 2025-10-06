
package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;
import java.text.*;

import javax.naming.NamingException;
import javax.servlet.*;
import javax.servlet.http.*;

import com.lh.servlet.DBServlet;
import com.lh.util.*;
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
import com.lowagie.text.pdf.PdfPCell; 
import com.lowagie.text.Document;

import serv.common.User;
import serv.common.Constants;

/**
 * @version 	1.0
 * @author
 */
public class gensearchletter extends DBServlet  {
	
	
	
	
  private String i_seq = "";
  private String[] List_i_seq;
  private int nxt = 0;
  
  
  
	
  private String[] check; 	
  //-------- Variable Generate PDF File --------//	
  private int heightLine = 19;
  private static String cName = "/LHServ/gensearchletter";
  
  //-------- Variable Calendar --------//
  //private Calendar days = Calendar.getInstance(Locale.ENGLISH);
  private String month[] =
	  {
		  "",
		  "มกราคม",
		  "กุมภาพันธ์",
		  "มีนาคม",
		  "เมษายน",
		  "พฤษภาคม",
		  "มิถุนายน",
		  "กรกฎาคม",
		  "สิงหาคม",
		  "กันยายน",
		  "ตุลาคม",
		  "พฤศจิกายน",
		  "ธันวาคม" };
  private String Day = null;
  private String year = null;
  private String Mont = null;
  private String Dayt = null;

  //-------- Variable Generate PDF File --------//		
  private Document document = new Document(PageSize.A4, 0, 0, 0, 0);
  private ByteArrayOutputStream baos = new ByteArrayOutputStream();
  private PdfWriter writer ;
  private PdfContentByte cb ;
  private PdfReader reader = null;
		
  //-------- Variable --------//
  private StringBuffer query = new StringBuffer();
  private String com_id = "";
  private String proj_id = "";
  private String I_company = "";
  private String I_project = "";
  private String I_docno = "";
  private String I_tel = "";
  private String I_cus_intent1 = "";
  private String I_exp_intent1 = "";
  private String n_ncustomer = "";
  private String n_scustomer = "";
  private String n_service = ""; // ชื่อเจ้าหน้าที่
  private String[] List_I_docno;
  private int count = 0;
  private String nn_project[];


  private String mName ="";
  private String realPath = "";
  private String templatePath = "";
  private String templateFiNme = "";
  private String n_project = ""; // ชื่อโครงการ
  private String n_customer = ""; // ชื่อผู้แจ้ง/ลูกค้า
//  private String I_house = ""; // บ้านเลขที่
//  private String I_lock = ""; // แปลง
  private String I_address_type = "";

  //----========== Insert to PDFGen ==========----
  
  private String[] List_n_project; // List Project
  private String[] List_Days; // List วันเวลานัดแจ้ง
  private String[] List_Times; // List เวลานัดแจ้ง
  private String[] List_n_service; // List ชื่อเจ้าหน้าที่ (input)
  private String[] List_t_service; // List เบอร์โทรติดต่อเจ้าหน้าที่ (input)
  private String[] List_address; // List ที่อยู่ที่ต้องแจ้งให้ลูกค้า
  private String[] List_I_lock; // List แปลงลูกค้า
  private String[] List_n_customer; // List ชื่อลูกค้า
  private String[] List_I_house; // List บ้านเลขที่ลูกค้า
  private String[] mAddress1; // ที่อยู่แถวที่ 1
  private String[] mAddress2; // ที่อยู่แถวที่ 2
  private String[] mAddress3; // ที่อยู่แถวที่ 3
  private String[] mAddress4; // ที่อยู่แถวที่ 4
  private String d; // Detail วันเวลานัดแจ้ง (Input day)
  private String m; // Detail วันเวลานัดแจ้ง(Input month)
  private String y; // Detail วันเวลานัดแจ้ง(Input year)

  private String[] temporary;
  private StringTokenizer split;
			
  private String adDetail1 = " ";
  private String adDetail2 = " ";
  private String adDetail3 = " ";
  private String adDetail4 = " ";
  private String adDetail5 = " ";
  private String adDetail6 = " ";
  private String convert = "";
  private LinkedList lavoid;
  private int cavoid = 0;
  
  //----========== Use in program ==========----
  private int size=0;
  private boolean nextstate = true;
  private boolean checkname = true;
	
  private User user;
  private HttpSession session;
  private Object obj;
	
	

  /*********************************************************************************************************/ 
	    public PdfPCell addDataRight(String msg,int width,int height,Font font) {
		PdfPCell cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(msg),font));
		cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setColspan(width);
		cell.setFixedHeight(height);
		cell.setBorder(0);	
		return cell;	
	  }  
  /************************************************************************************************************/ 


  /************************************************************************************************************/ 
	    public PdfPCell addDataCenter(String msg,int width,int height,Font font) {
		PdfPCell cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(msg),font));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setColspan(width);
		cell.setFixedHeight(height);
		cell.setBorder(0);	
		return cell;	
	  }  
  /************************************************************************************************************/ 

  
  /************************************************************************************************************/ 
	    public PdfPCell addData(String msg,int width,int height,Font font) {
		PdfPCell cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(msg),font));
		cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setColspan(width);
		cell.setFixedHeight(height);
		cell.setBorder(0);	
		return cell;	
	  }
  /************************************************************************************************************/ 

  		public PdfPCell addDataNext(String msg,int width,Font font) {
		  PdfPCell cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(msg),font));
		  cell.setHorizontalAlignment(Rectangle.ALIGN_LEFT);
		  cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		  cell.setColspan(width);
		  cell.setBorder(0);	
		  return cell;	
		}




 


  /************************************************************************************************************/ 
	  public void printRecordForm(Statement stmt,Document document) throws Exception {

		//----================ Initialize Variables for create PDF =====================---//
		BaseFont bf = BaseFont.createFont(Constants.FONT_ANGSANA_NORMAL, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
		Font font = new Font(bf, 14, Font.NORMAL,new Color(0,0,0));
			
		PdfPTable table = new PdfPTable(100);
		table.setWidthPercentage(100);
		PdfPCell cell;
		ResultSet rs = null;
		doString str = new doString();


		count = 0;
		
		
		//============== Split Day From Input ==============
				
		StringTokenizer dd ;
				
		//==================================================
				
		for (int i = 0; i < List_I_docno.length;i++)
		{
			dd = new StringTokenizer(List_Days[count],"/");
			if (dd.countTokens()==3) {
				d = dd.nextToken();		
				m = dd.nextToken();		
				y = dd.nextToken();
				m = month[Integer.parseInt(m)];		
				if(y.length()==2)
				{
					y = "25"+y;
				}
			}			
			if(List_I_docno[count]!=""&&List_I_docno[count]!=null)
			{
				if (List_n_customer[count].equalsIgnoreCase("")){
					List_n_customer[count] = "null";
				}
				if (mAddress1[count].equalsIgnoreCase("")){
					mAddress1[count] = "null";
				}
				if (mAddress2[count].equalsIgnoreCase("")){
					mAddress2[count] = "null";
				}
				if (mAddress3[count].equalsIgnoreCase("")){
					mAddress3[count] = "null";
				}
				if (mAddress4[count].equalsIgnoreCase("")){
					mAddress4[count] = "null";
				}

				cb.addTemplate(writer.getImportedPage(reader, 1), 1, 1);
				table.addCell(addData("",100,(heightLine),font));
				
				table.addCell(addData("",83,heightLine,font));
				table.addCell(addData("Seq-"+List_i_seq[count],17,heightLine,font));
				
				table.addCell(addData("",100,(heightLine*3)+6,font));
			
				table.addCell(addDataCenter("",100,(heightLine),font));
				
				
				table.addCell(addData("",23,heightLine,font));
				table.addCell(addData(nn_project[count],77,heightLine,font));
						
				table.addCell(addData("",55,heightLine,font));
				table.addCell(addData("วันที่ "+Day,45,heightLine,font));
		
				table.addCell(addData("",100,(heightLine)+10,font));
		
				table.addCell(addData("",20,heightLine-1,font));
				table.addCell(addData("คุณ "+List_n_customer[count]+" เจ้าของบ้านเลขที่ "+List_I_house[count]+" แปลง "+List_I_lock[count],80,heightLine-1,font));
		
				table.addCell(addData("",38,heightLine,font));
				table.addCell(addData(List_I_docno[count],62,heightLine,font));
					
				table.addCell(addData("",100,(heightLine*3),font));
		
				table.addCell(addData("",75,heightLine,font));
				table.addCell(addData(" "+d+"  "+m+"  "+y,25,heightLine,font));		

   				table.addCell(addDataNext("",14,font));
				table.addCell(addDataNext("เวลา "+List_Times[count]+" น. ถ้าท่านไม่สะดวกโปรดติดต่อกลับมายัง คุณ "+List_n_service[count]
				+" โทร. "+List_t_service[count],72,font));
				table.addCell(addDataNext("",14,font));

				table.addCell(addData("",20,heightLine,font));
				table.addCell(addData("อนึ่งหากท่านไม่เข้ามาทำการตรวจรับงานซ่อมในวันและเวลาดังกล่าง ทางบริษัทฯ ถือว่างานซ่อมบ้านของท่านนั้น",80,heightLine,font));				
				
				table.addCell(addData("",14,heightLine,font));
				table.addCell(addData("เสร็จสิ้นสมบูรณ์ตามที่แจ้ง",86,heightLine,font));
				
				table.addCell(addData("",100,heightLine,font));
				
				table.addCell(addData("",20,heightLine,font));
				table.addCell(addData("จึงเรียนมาเพื่อทราบ",80,heightLine,font));
				
				table.addCell(addData("",100,heightLine*2,font));
				
				table.addCell(addData("",55,heightLine,font));
				table.addCell(addData("ขอแสดงความนับถือ",45,heightLine,font));
				
				table.addCell(addData("",100,heightLine+9,font));
				
				table.addCell(addData("",23,heightLine,font));
				table.addCell(addDataCenter("( "+List_n_service[count]+" )",77,heightLine,font));
				
				table.addCell(addData("",55,heightLine,font));
				table.addCell(addData("เจ้าหน้าที่บริการลูกค้า",45,heightLine,font));
				
				//----------------------------------------------------
				//------------Address-Customer------------------------
				table.addCell(addData("",100,heightLine*6,font));
				
				table.addCell(addData("",25,heightLine,font));
				table.addCell(addData("เรียน",75,heightLine,font));
				
				table.addCell(addData("",35,heightLine,font));
				table.addCell(addData("คุณ "+List_n_customer[count],65,heightLine,font));
				
				table.addCell(addData("",35,heightLine,font));
				table.addCell(addData(mAddress1[count],65,heightLine,font));

				table.addCell(addData("",35,heightLine,font));
				table.addCell(addData(mAddress2[count],65,heightLine,font));
				
				table.addCell(addData("",35,heightLine,font));
				table.addCell(addData(mAddress3[count],65,heightLine,font));
				
				table.addCell(addData("",35,heightLine,font));
				table.addCell(addData(mAddress4[count],65,heightLine,font));
				
				
				count++;
				
				//====================== Reset to Create Next PDF ======================
				document.add(table);
				document.newPage();	
				table = new PdfPTable(100);
				table.setWidthPercentage(100);
			}
			
		}
	  } 
  /************************************************************************************************************/ 




  
  
	
  /************************************************************************************************************/ 
	  public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		mName = new String(this.getClass().getName() + ".performTask: ");
		System.out.println(mName + "start.");
	

		realPath = getServletContext().getRealPath("/");
		templatePath = realPath + "/template/";
		templateFiNme = "SearchLetter.pdf";
	
		//	=========================================
	
		StringBuffer sql = new StringBuffer();
		Connection conn = null;
		Statement stmt = null;
		Statement stmt1 = null;
		ResultSet rs = null;
		ResultSet rs1 = null;
		
		Calendar days = Calendar.getInstance(Locale.ENGLISH);
		int DD = days.get(Calendar.DATE);
		int MM = days.get(Calendar.MONTH) + 1;
		int YY = days.get(Calendar.YEAR);		
		 try {
			//============= Calendar ==========
			YY = days.get(Calendar.YEAR);
		   	YY = YY+543;
		   	if (MM<10)
		   	{
				Mont = "0"+MM;
		   	}
		   else
		   {
			   Mont = ""+MM;
		   }
		   if (DD<10)
		   {
			   Dayt = "0"+DD;
		   }
		   else
		   {
			   Dayt = ""+DD;
		   }


		   
		   
		   
		   year = doString.displayNumber("0000", YY);
		   Day = Dayt+" "+month[MM]+" "+year;		 	
		 	
			//----============ Initialize Variable ============----//
			if (ds == null) getDS();
			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(true);
			stmt = conn.createStatement();       
			stmt1 = conn.createStatement();
				 	
			//= ID
			
			session = req.getSession(false);
			if (session == null) {
				/*
				* Redirect user to login page if
				* there's no session.
				*/
				res.sendRedirect("/LHServ/warning.htm");
				return;
			}
			obj = session.getAttribute("USER");
			if (obj == null) {
				/*
				* Redirect user to login page if
				* there's no session.
				*/
				res.sendRedirect("/LHServ/warning.htm");
				return;
			}
			user = (User) obj;
			
				
			//		----========== Start ==========----
			
			check = getParameterValues(req,"check",true,true,null,"กรุณาเลือก File ที่จะ Print");
			size = check.length;

			List_I_docno = new String[size];
			List_I_lock = new String[size];
			nn_project = new String[size];

			
			List_Days = new String[size];
			List_Times = new String[size];
			List_n_service = new String[size];
			List_t_service = new String[size];
			List_address = new String[size];
			n_project = "";
			List_I_house = new String[size];
			List_n_customer = new String[size];
			mAddress1 = new String[size];
			mAddress2 = new String[size];
			mAddress3 = new String[size];
			mAddress4 = new String[size];
			List_i_seq = new String[size];
			
			
			







			for(int i =0;i<check.length;i++)
			{
				com_id = check[i].substring(0,2);
				proj_id = check[i].substring(3,6);	
				
				query.delete(0, query.length());
				query
					.append("select n_project from lan:acxprojt where I_company='")
					.append(com_id)
					.append("' and I_project ='")
					.append(proj_id)
					.append("'");
				rs = stmt.executeQuery(query.toString());
				if (rs.next()) {
					n_project = doString.checkString(rs.getString("n_project"),"");
				}
				rs.close();				
							
				split = new StringTokenizer(check[i],";");
				if (split.countTokens()==2)
				{
					List_I_docno[i] = split.nextToken();
					List_I_lock[i] = split.nextToken();
				}
				temporary = req.getParameterValues(List_I_docno[i]);
				List_Days[i] = temporary[0];
				List_Times[i] = temporary[1];
				List_n_service[i] = temporary[2];
				List_t_service[i] = temporary[3];
				List_address[i] = temporary[4];
				

				query.delete(0, query.length());
				query
					.append("select I_house from lan:acxlckmd where I_company='")
					.append(com_id)
					.append("' and I_project='")
					.append(proj_id)
					.append("' and I_lock='")
					.append(List_I_lock[i])
					.append("'");
				rs = stmt.executeQuery(query.toString());
				if (rs.next())
				{
					List_I_house[i] = doString.checkString(rs.getString("I_house"),"");
				}
				rs.close();

				
				String i_cust = "";
				I_cus_intent1 = "";
				I_exp_intent1 = "";
				query.delete(0, query.length());
				query
					.append("select I_cus_intent1,I_exp_intent1 from lan:acscontr where I_company='")
					.append(com_id)
					.append("' and I_project ='")
					.append(proj_id)
					.append("' and f_contr is null and i_sort='")
					.append(List_I_lock[i])
					.append("'");
				rs = stmt.executeQuery(query.toString());
				if(rs.next())
				{
					I_cus_intent1 = doString.checkString(rs.getString("I_cus_intent1"),"");
					I_exp_intent1 = doString.checkString(rs.getString("I_exp_intent1"),"");
					
					if (I_cus_intent1.length() > 0) {
						i_cust = I_cus_intent1;
					} else {
						i_cust = I_exp_intent1;
					}					
				}
				query.delete(0, query.length());
				query
					.append("select n_ncustomer,n_scustomer from lan:acxcusto where I_customer='")
					.append(i_cust)
					.append("'");
				rs = stmt.executeQuery(query.toString());
				if(rs.next())
				{
					n_ncustomer = doString.checkString(rs.getString("n_ncustomer"),"");
					n_scustomer = doString.checkString(rs.getString("n_scustomer"),"");
				}
				rs.close();
				List_n_customer[i] = n_ncustomer+" "+n_scustomer;
				
				
				
				/*
				query.delete(0, query.length());
				query
					.append("select n_customer from lan:serv_dochd a where I_company='")
					.append(com_id)
					.append("' and I_project='")
					.append(proj_id)
					.append("' and f_status in ('OPN','CLS') and d_complete_max is not null");
					if (!List_I_docno[i].equalsIgnoreCase(""))
					{
						I_docno = I_docno.toUpperCase();
						query
							.append(" and I_docno ='")
							.append(List_I_docno[i])
							.append("'");
					}
				rs = stmt.executeQuery(query.toString());
				if (rs.next())
				{
					List_n_customer[i] = doString.checkString(rs.getString("n_customer"),"");
				}
				rs.close();*/
				
				//============= update get address type
				
				
				query.delete(0, query.length());
				query
					.append("select I_address_type from lan:acxcusto where I_customer='")
					.append(I_exp_intent1)
					.append("'");
				rs = stmt.executeQuery(query.toString());
				if(rs.next())
				{
					I_address_type = doString.checkString(rs.getString("I_address_type"),"");
				}
				rs.close();
				
			   // ========== Address ==========
			   if (List_address[i].equalsIgnoreCase("proj_address"))
			   {
				   convert = "";
				   query.delete(0, query.length());
				   query
					   .append("select a_add1,a_add2,a_add3,a_add4 from lan:acxprojt where I_company='")
					   .append(com_id)
					   .append("' and I_project='")
					   .append(proj_id)
					   .append("'");
				   rs = stmt.executeQuery(query.toString());
				   if(rs.next())
				   {
											
					   mAddress1[i] = List_I_house[i]+" ม."+n_project;
											
					   lavoid = new LinkedList();
					   
					   lavoid.add("0");					
					   lavoid.add("1");
					   lavoid.add("2");
					   lavoid.add("3");
					   lavoid.add("4");
					   lavoid.add("5");
					   lavoid.add("6");
					   lavoid.add("7");
					   lavoid.add("8");
					   lavoid.add("9");
					   lavoid.add("/");
					   lavoid.add(" ");
					   
					   convert = doString.checkString(rs.getString("a_add1"),"");
					   
					if(convert.length()!=0 && convert.length()>0)
					{
					   
					   cavoid = 0;
					   while(lavoid.contains(convert.substring(cavoid,cavoid+1)))
					   {
						   cavoid++;
						   if (!lavoid.contains(convert.substring(cavoid,cavoid+1)))
						   {
							   break;
						   }
					   }
					   convert = convert.substring(cavoid);
				   }
																			
					   mAddress2[i] = convert+" "+doString.checkString(rs.getString("a_add2"),"");
											
					   mAddress3[i] = doString.checkString(rs.getString("a_add3"),"");
											
					   mAddress4[i] = doString.checkString(rs.getString("a_add4"),"");									
				   }
				   rs.close();
			   }
			   if (List_address[i].equalsIgnoreCase("old_address"))
			   {
				   adDetail1 = " ";
				   adDetail2 = " ";
				   adDetail3 = "";
				   adDetail4 = " ";
				   adDetail5 = " ";
				   adDetail6 = "";
				   if (I_address_type.equalsIgnoreCase(""))
				   {
					   mAddress1[i] = "null";
												
					   mAddress2[i] = "null";
		
					   mAddress3[i] = "null";
		
					   mAddress4[i] = "null";

				   }
				   if (I_address_type.equalsIgnoreCase("1"))
				   {
					   query.delete(0, query.length());
					   query
						   .append("select a_id_add1,a_id_add2,a_id_add3,a_id_add4,a_id_add5,a_id_add6,a_id_add7,a_id_postcode from lan:acxcusto where I_customer='")
						   .append(I_exp_intent1)
						   .append("'");
					   rs = stmt.executeQuery(query.toString());
					   if(rs.next())
					   {
						   if (!(doString.checkString(rs.getString("a_id_add2"),"")).equalsIgnoreCase(""))
						   {
							   adDetail1 = " หมู่ ";
						   }
						   if (!(doString.checkString(rs.getString("a_id_add3"),"")).equalsIgnoreCase(""))
						   {
							   adDetail2 = " ซ. ";
						   }
						   if (!(doString.checkString(rs.getString("a_id_add4"),"")).equalsIgnoreCase(""))
						   {
							   adDetail3 = "ถ. ";
						   }
						   if (!(doString.checkString(rs.getString("a_id_add5"),"")).equalsIgnoreCase(""))
						   {
							   adDetail4 = " ต. ";
						   }
						   if (!(doString.checkString(rs.getString("a_id_add6"),"")).equalsIgnoreCase(""))
						   {
							   adDetail5 = " อ. ";
						   }									
						   if (!(doString.checkString(rs.getString("a_id_add7"),"")).equalsIgnoreCase(""))
						   {
							   adDetail6 = "จ. ";
						   }
												
						   mAddress1[i] = doString.checkString(rs.getString("a_id_add1"),"")
							   +adDetail1+doString.checkString(rs.getString("a_id_add2"),"")							
							   +adDetail2+doString.checkString(rs.getString("a_id_add3"),"");
													
						   mAddress2[i] = adDetail3+doString.checkString(rs.getString("a_id_add4"),"")
							   +adDetail4+doString.checkString(rs.getString("a_id_add5"),"")
							   +adDetail5+doString.checkString(rs.getString("a_id_add6"),"");
			
						   mAddress3[i] = adDetail6+doString.checkString(rs.getString("a_id_add7"),"")
							   +" "+doString.checkString(rs.getString("a_id_postcode"),"");
			
						   mAddress4[i] = "";						
					   }
					   rs.close();								
				   }
				   if (I_address_type.equalsIgnoreCase("2"))
				   {
					   query.delete(0, query.length());
					   query
						   .append("select a_wk_name,a_wk_add1,a_wk_add2,a_wk_add3,a_wk_add4,a_wk_add5,a_wk_add6,a_wk_add7,a_wk_postcode from lan:acxcusto where I_customer='")
						   .append(I_exp_intent1)
						   .append("'");
					   rs = stmt.executeQuery(query.toString());
					   if(rs.next())
					   {
						   if (!(doString.checkString(rs.getString("a_wk_add2"),"")).equalsIgnoreCase(""))
						   {
							   adDetail1 = " หมู่ ";
						   }
						   if (!(doString.checkString(rs.getString("a_wk_add3"),"")).equalsIgnoreCase(""))
						   {
							   adDetail2 = " ซ. ";
						   }
						   if (!(doString.checkString(rs.getString("a_wk_add4"),"")).equalsIgnoreCase(""))
						   {
							   adDetail3 = "ถ. ";
						   }
						   if (!(doString.checkString(rs.getString("a_wk_add5"),"")).equalsIgnoreCase(""))
						   {
							   adDetail4 = " ต. ";
						   }
						   if (!(doString.checkString(rs.getString("a_wk_add6"),"")).equalsIgnoreCase(""))
						   {
							   adDetail5 = " อ. ";
						   }									
						   if (!(doString.checkString(rs.getString("a_wk_add7"),"")).equalsIgnoreCase(""))
						   {
							   adDetail6 = "จ. ";
						   }									
												
						   mAddress1[i] = doString.checkString(rs.getString("a_wk_name"),"");
			
						   mAddress2[i] = doString.checkString(rs.getString("a_wk_add1"),"")
							   +adDetail1+doString.checkString(rs.getString("a_wk_add2"),"")							
							   +adDetail2+doString.checkString(rs.getString("a_wk_add3"),"");
			
						   mAddress3[i] = adDetail3+doString.checkString(rs.getString("a_wk_add4"),"")
							   +adDetail4+doString.checkString(rs.getString("a_wk_add5"),"")
							   +adDetail5+doString.checkString(rs.getString("a_wk_add6"),"");
			
						   mAddress4[i] = adDetail6+doString.checkString(rs.getString("a_wk_add7"),"")
							   +" "+doString.checkString(rs.getString("a_wk_postcode"),"");
					   }
					   rs.close();																
				   }
				   if (I_address_type.equalsIgnoreCase("3"))
				   {
					   query.delete(0, query.length());
					   query
						   .append("select a_etc_name,a_etc_add1,a_etc_add2,a_etc_add3,a_etc_add4,a_etc_add5,a_etc_add6,a_etc_add7,a_etc_postcode from lan:acxcusto where I_customer='")
						   .append(I_exp_intent1)
						   .append("'");
					   rs = stmt.executeQuery(query.toString());
					   if(rs.next())
					   {
						   if (!(doString.checkString(rs.getString("a_etc_add2"),"")).equalsIgnoreCase(""))
						   {
							   adDetail1 = " หมู่ ";
						   }
						   if (!(doString.checkString(rs.getString("a_etc_add3"),"")).equalsIgnoreCase(""))
						   {
							   adDetail2 = " ซ. ";
						   }
						   if (!(doString.checkString(rs.getString("a_etc_add4"),"")).equalsIgnoreCase(""))
						   {
							   adDetail3 = "ถ. ";
						   }
						   if (!(doString.checkString(rs.getString("a_etc_add5"),"")).equalsIgnoreCase(""))
						   {
							   adDetail4 = " ต. ";
						   }
						   if (!(doString.checkString(rs.getString("a_etc_add6"),"")).equalsIgnoreCase(""))
						   {
							   adDetail5 = " อ. ";
						   }									
						   if (!(doString.checkString(rs.getString("a_etc_add7"),"")).equalsIgnoreCase(""))
						   {
							   adDetail6 = "จ. ";
						   }
																					
						   mAddress1[i] = doString.checkString(rs.getString("a_etc_name"),"");
			
						   mAddress2[i] = doString.checkString(rs.getString("a_etc_add1"),"")
							   +adDetail1+doString.checkString(rs.getString("a_etc_add2"),"")							
							   +adDetail2+doString.checkString(rs.getString("a_etc_add3"),"");
			
						   mAddress3[i] = adDetail3+doString.checkString(rs.getString("a_etc_add4"),"")
							   +adDetail4+doString.checkString(rs.getString("a_etc_add5"),"")
							   +adDetail5+doString.checkString(rs.getString("a_etc_add6"),"");
			
						   mAddress4[i] = adDetail6+doString.checkString(rs.getString("a_etc_add7"),"")
							   +" "+doString.checkString(rs.getString("a_etc_postcode"),"");
					   }
					   rs.close();																
				   }							
										
			   }
			   // End Address
			   

			//	if (List_n_customer[i].equalsIgnoreCase(""))
			//	{
					checkname = true;
					I_cus_intent1 = "";
					I_exp_intent1 = "";
					query.delete(0, query.length());
					query
						.append("select I_cus_intent1,I_exp_intent1 from lan:acscontr where I_company='")
						.append(com_id)
						.append("' and I_project ='")
						.append(proj_id)
						.append("' and f_contr is null and i_sort='")
						.append(List_I_lock[i])
						.append("'");
					rs = stmt.executeQuery(query.toString());
					if(rs.next())
					{
						I_cus_intent1 = doString.checkString(rs.getString("I_cus_intent1"),"");
						I_exp_intent1 = doString.checkString(rs.getString("I_exp_intent1"),"");
						
						if (I_cus_intent1.length() > 0) {
							i_cust = I_cus_intent1;
						} else {
							i_cust = I_exp_intent1;
						}
												
							/*	if (I_exp_intent1.equalsIgnoreCase(""))
								{
									I_exp_intent1 = I_cus_intent1;
									checkname = false;
								}
								else if(I_exp_intent1.length()!=0)
								{
									checkname = false;
								}*/
					}


					rs.close();
					if(checkname==false)
					{
						query.delete(0, query.length());
						query
							.append("select n_ncustomer,n_scustomer from lan:acxcusto where I_customer='")
							.append(i_cust)
							.append("'");
						rs = stmt.executeQuery(query.toString());
						if(rs.next())
						{
							n_ncustomer = doString.checkString(rs.getString("n_ncustomer"),"");
							n_scustomer = doString.checkString(rs.getString("n_scustomer"),"");
						}
						rs.close();
						List_n_customer[i] = n_ncustomer+" "+n_scustomer;
						

					}
				
		
				//============================ SEQ
				nxt = 0;
				query.delete(0,query.length());
				query
					.append("select max(i_seq) max from lan:serv_loglet where i_company='")
					.append(com_id)
					.append("' and I_project='")
					.append(proj_id)
					.append("' and i_seq[1,2]='")
					.append(year.substring(2,4))
					.append("'");
				rs = stmt.executeQuery(query.toString());
				while (rs.next())
				{
					i_seq = doString.checkString(rs.getString("max"),"");
					System.out.println("i_seq =" + i_seq);
				}
				rs.close();
				//=============================
				int j = i;
				if (i_seq.equalsIgnoreCase("")) 
				{
					nxt = 1;
		//			if(j-1>0)
		//			{
		//				if(com_id.equalsIgnoreCase(List_I_docno[j].substring(0,2))
		//				&&proj_id.equalsIgnoreCase(List_I_docno[j].substring(3,6)))
		//				{
		//					nxt = j+1;		
		//				}
		//				else
		//				{
		//					j = 0;
		//					nxt = j+1;
		//				}
		//			}
					
					String bck = Integer.toString(nxt);
					for (int z = bck.length();z<4;z++)
					{
						bck = "0"+bck;
					}
					List_i_seq[i] = year.substring(2,4)+bck;
				}
				else if(!i_seq.equalsIgnoreCase(""))
				{
					nxt = Integer.parseInt(i_seq.substring(2,i_seq.length()));
					nxt = nxt+1;
					/*if(j-1>0)
					{
					
						if(com_id.equalsIgnoreCase(List_I_docno[j].substring(0,2))
						&&proj_id.equalsIgnoreCase(List_I_docno[j].substring(3,6)))
						{
									
						}
						else
						{
							j = 0;
							nxt = nxt+j+1;
						}
					}
					*/
					String bck = Integer.toString(nxt);
					for (int z = bck.length();z<4;z++)
					{
						bck = "0"+bck;
					}
					i_seq = i_seq.substring(0,2)+(bck);
					List_i_seq[i] = i_seq;
				}
				
				System.out.println("A ="+List_I_docno[i].substring(0,2));
				System.out.println("B ="+List_I_docno[i].substring(3,6));
				System.out.println("i" + i);
				
	query.delete(0, query.length());
					query
						.append("select n_project from lan:acxprojt where I_company='")
						.append(List_I_docno[i].substring(0,2))
						.append("' and I_project ='")
						.append(List_I_docno[i].substring(3,6))
						.append("'");
					rs = stmt.executeQuery(query.toString());
					if (rs.next()) {
						nn_project[i] = doString.checkString(rs.getString("n_project"),"");
						System.out.println(nn_project[i]);
						
						
					}
					rs.close();
				
				
				// -- insert log
				query.delete(0,query.length());
				query
				   .append("insert into lan:serv_loglet values('01','")
				   .append(List_I_docno[i].substring(0,2))
				   .append("','")
				   .append(List_I_docno[i].substring(3,6))
				   .append("','")
				   .append(List_i_seq[i])
				   .append("','")
				   .append(user.getUserName())
				   .append("',current,'")
				   .append(List_I_docno[i])
				   .append("');");
				   //System.out.println(query.toString());
				stmt.executeUpdate(query.toString());
				
				
			}
				
				//=======================================
		

	

				

		
		
				//-------- Start Generate PDF File --------//		
				document = new Document(PageSize.A4, 0, 0, 0, 0);
//				ByteArrayOutputStream baos = new ByteArrayOutputStream();
				writer = PdfWriter.getInstance(document, baos);
				cb = writer.getDirectContent();
			
//				PdfReader reader = null;
				PdfImportedPage page1 = null;	
				document.open();
				reader = new PdfReader(templatePath+templateFiNme);
				cb.addTemplate(writer.getImportedPage(reader, 1), 1, 1);
				
				//Content

				printRecordForm(stmt,document);

				//----=========== Generate PDF ===============-----//
				document.close();
				res.setContentType("application/pdf");
				res.setContentLength(baos.size());
				ServletOutputStream outServ = res.getOutputStream();
				baos.writeTo(outServ);
				outServ.flush();
				
				// ========== Insert Log ==========	
//				for(int i=0;i<List_I_docno.length;i++)
//				{
//					 
//				}
				// =========== End Log ===========					
				
				
				stmt.close();
				stmt1.close();
				conn.close();
				stmt=null;
				stmt1=null;
				conn = null;
			} catch (DocumentException de) {
					System.out.println(" ERROR "+mName+" : " + de.getMessage());
					System.out.println(" ERROR "+mName+" SQL : " + query.toString());
				
			} catch (Exception e) {
				System.out.println(" ERROR "+mName+" : " + e.getMessage());
				System.out.println(" ERROR "+mName+" SQL : " + query.toString());
			} finally {
				try {
					if (rs!=null) rs.close(); 
					if (stmt != null) stmt.close();
					if (stmt1 != null) stmt1.close();
					if (conn != null) conn.close();
				} catch (SQLException ignore) {
				}
			}
			System.out.println(mName + "end."); 
		}
}
