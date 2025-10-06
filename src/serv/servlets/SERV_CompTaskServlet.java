package serv.servlets;
import java.io.*;
import java.util.*;
import java.sql.*;
import java.awt.Color;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.naming.*;
import com.lh.servlet.DBServlet;
import com.lh.util.*;
import com.lh.exception.InvalidParameterException;
import serv.common.User;
import serv.common.Constants;
import serv.common.SERV_CommonData;


/**
 * @version 	1.0
 * @author
 */

/**
 * Modify by : pradoem@lh.co.th
 * date : 2015.04.28
 * version 1.1
 * desc:  update insert i_seq_docdt,i_keygen
 *  count(*) as cnt from i_keygen is null
 *  Generate from Random and insert now 
 */
public class SERV_CompTaskServlet extends DBServlet  {
	private void genRedirectCode(PrintWriter out,String page,String redirect,String error,String otherMsg) {
		out.println("<form method='post' action='"+page+"'>");		
		out.println("<input type='hidden' name='error' value='"+error+"'>");
		out.println("<input type='hidden' name='other_msg' value='"+doString.MS874ToUnicode(otherMsg)+"'>");
		out.println("<input type='hidden' name='redirect_url' value='"+doString.MS874ToUnicode(redirect)+"'>");		
		out.println("<script> document.forms[0].submit();</script>");
		out.println("</form>");		
	}

	

	public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		String mName = new String(this.getClass().getName() + ".performTask: ");
		System.out.println(mName + "start.");
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
		User user = (User) obj;
		doString str = new doString();		 		
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
		String mode = doString.checkString(req.getParameter("mode"),"add");
		String selProj = doString.checkString(req.getParameter("sel_project"),"");

		//---======= Get Now Date =========-----//
		Calendar now = Calendar.getInstance();				
		int year = (now).get(Calendar.YEAR);
		if (year<2400) year += 543;		
		String nowDate = Integer.toString(year>2400 ? year-543 : year);	
		nowDate += "-"+str.createID(now.get(Calendar.MONTH)+1,2);
		nowDate += "-"+str.createID(now.get(Calendar.DATE),2);
		nowDate += " "+str.createID(now.get(Calendar.HOUR_OF_DAY),2);
		nowDate += ":"+str.createID(now.get(Calendar.MINUTE),2);		
	   //---=========================================================================----//		
		//----============= Define Link for redirect ===============-----//			
		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_CompTask_List.jsp?sel_project="+selProj;
		String errorPage = "SERV_CompTask_List.jsp?error=1&sel_project="+selProj;

		String otherMsg = "";
		String errorCode = "";

		StringBuffer sql = new StringBuffer();
		Connection conn = null;
		Statement stmt = null;
		Statement stmt1 = null;
		ResultSet rs = null;
		String docno = "";
		 try {
			if (ds == null)
				getDS();

			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
			stmt1 = conn.createStatement();			

			//---============== Select Percent From SERV_XSTD ================----//
			 String pAmount = "";
			 sql.delete(0,sql.length());
			 sql.append(" select * from lan:serv_xstd where i_type='02' ");
			 rs = stmt.executeQuery(sql.toString());
			 if (rs.next()) {
				 pAmount = doString.checkString(rs.getString("p_amount"),"0");
			 }				        
			 rs.close();	

			 //---======== Select Payment Date from SERV_PAYSCHD  ===========----//
			 String paymentDate = "";
			 sql.delete(0,sql.length());
			 sql.append(" select d_payment from lan:serv_payschd where today<=d_contructor order by d_payment ");
			 rs = stmt.executeQuery(sql.toString());
			 if (rs.next()) {
				 Calendar pay = Calendar.getInstance();
				 Timestamp tmp = rs.getTimestamp("d_payment");
				 if (tmp!=null)  {
					 pay.setTime(tmp);    
					 int tYear = pay.get(Calendar.YEAR);
					 if (tYear>2400) tYear-= 543;
					 paymentDate += tYear+"-"+str.createID(pay.get(Calendar.MONTH)+1,2);
					 paymentDate += "-"+str.createID(pay.get(Calendar.DATE),2);
				 }							 
			 }				        
			 rs.close();	  

			//----========================= Complete Task ==============================----//
			Random rand = new Random();
			int iSeq = 0;
			String i_keygen = "";
			String itemKey = "";
			Vector iDocNoList = new Vector();
			String[] vendor = req.getParameterValues("i_vendor");	
			if (vendor!=null) {
				for (int i=0;i<vendor.length;i++) {					   
					    //-----======== Select Data from SERV_DOCDT and insert into SERV_PAYMENT ===========----//
						StringTokenizer id = new StringTokenizer(vendor[i],":");
						if (id.countTokens()!=2) continue; 
						docno = id.nextToken();
						String vendorId = id.nextToken();
					   sql.delete(0,sql.length());
					   sql.append(" select  * from lan:serv_docdt where f_itmstatus='300' ")
							 .append(" and i_docno='").append(docno).append("' ")
					         .append(" and i_vendor='").append(vendorId).append("' ");
					        // .append(" Order by i_seq,i_itmjob ");
					   
					   rs = stmt.executeQuery(sql.toString());
					   int line = 0;

					   while (rs.next()) {
						    String iDocNo = doString.checkString(rs.getString("i_docno"),"");
					   	    String iItmJob = doString.checkString(rs.getString("i_itmjob"),"");
						    String iVendor = doString.checkString(rs.getString("i_vendor"),"");
						    String qWage = doString.checkString(rs.getString("q_wage_unit"),"0.00");
						    String zWage = doString.checkString(rs.getString("z_wage_price"),"0.00");
						    String qGoods = doString.checkString(rs.getString("q_good_unit"),"0.00");
						    String zGoods = doString.checkString(rs.getString("z_good_price"),"0.00");
						    String cItmJob = doString.checkString(rs.getString("c_itmjob"),"");
						    String iItmJobArea = doString.checkString(rs.getString("i_itmjob_area"),"");
		  				    String zAmountPay = doString.checkString(rs.getString("z_amount_pay"),"0.00");

		  				    //--------------------------
		  					iSeq = 0;
		  					i_keygen = "";
		  					itemKey = "";
		  					iSeq = rs.getInt("i_seq");
		  					i_keygen = doString.checkString(rs.getString("i_keygen"),"");
		  					
		  					if(i_keygen.equals("")){
		  						 itemKey = iItmJob+"_"; 
							   	 while (itemKey.length()<20) {
									itemKey += rand.nextInt(10); 
							      }
							   	i_keygen = itemKey;
		  					}
		  				    //--------------------------
		  				    line++;			    

							sql.delete(0,sql.length());
							sql.append(" insert into lan:serv_payment ( ")
							      .append(" i_docno , 	i_seq , 	i_itmjob , 	i_vendor , 	q_wage_unit , z_wage_price , ")
							      .append(" q_good_unit , 	z_good_price , 	c_itmjob , 	i_itmjob_area , 	f_itmstatus , d_payment , ")
							      .append(" i_ven_cut , p_cut , p_add_pay , vat_tax_code , 	z_amount_pay , 		z_amount_pv , ")
							      .append(" z_amount_vat , 	z_amount_tax , 	pv_no , 	d_post_pv , z_amount_cut , 	z_cut_pv ,  ")
							      .append(" z_cut_vat , z_cut_tax , i_refno , 	d_post_cut , f_posted , f_reject ,  ")
							      .append(" i_employ_reject , 	d_reject , 	c_reject , f_remark ,i_seq_docdt,i_keygen")
								  .append(" ) values ( ")
								  .append(" ?,?,?,?,?,?,?,?,?,?,'400',?,null,null,?,null,?,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,?,?) "); 							  
							PreparedStatement pstmt = conn.prepareStatement(sql.toString());
							pstmt.setString(1,iDocNo);
							pstmt.setInt(2,line);
							pstmt.setString(3,iItmJob);
							pstmt.setString(4,iVendor);
							pstmt.setString(5,qWage);
							pstmt.setString(6,zWage);
							pstmt.setString(7,qGoods);
							pstmt.setString(8,zGoods);
							pstmt.setString(9,doString.UnicodeToMS874(cItmJob));
							pstmt.setString(10,iItmJobArea);
							pstmt.setString(11,paymentDate);
							pstmt.setString(12,pAmount);
							pstmt.setString(13,zAmountPay);
							//---------------------------------
							pstmt.setInt(14,iSeq);
							pstmt.setString(15,i_keygen);
							//---------------------------------
							pstmt.executeUpdate();
							pstmt.close();							 							 
					   }  // end while  insert into serv_payment from docdt
					   rs.close();

					//======== move update outside loop , 2011-03-21 ==============//
					/*
					sql.delete(0,sql.length());
					sql.append("update lan:serv_docdt set ")
						  .append(" f_itmstatus='400' ") //---- Set status to 400 , Complete Task 
						  .append(" where i_docno='").append(docno).append("'  ")
						  .append(" and i_vendor='").append(vendorId).append("'  ")
						//  .append(" and i_itmjob='").append(iItmJob).append("'  ")								  
						  .append(" and f_itmstatus='300'  ");							  
					stmt1.executeUpdate(sql.toString());
					*/		
					//========================================================//					

						//---========== Check SERV_FLOW Before Insert ============----//
						int cnt = -1;
						 sql.delete(0,sql.length());
						 sql.append(" select  count(*) cnt from lan:serv_flow where f_itmstatus='300' ")
							   .append(" and i_docno='").append(docno).append("' ")
							   .append(" and i_vendor='").append(vendorId).append("' ");
						 rs = stmt.executeQuery(sql.toString());
						 if (rs.next()) {
							 cnt = rs.getInt("cnt"); 
						 }
						 rs.close();


					 	//----========== If No data in SERV_FLOW , Insert it ============----//
					 	if (cnt==0) {						
							sql.delete(0,sql.length());
							sql.append(" insert into lan:serv_flow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,c_reject ")
								  .append(") values (")
								  .append(" '").append(docno).append("' , ")
								  .append(" '").append(vendorId).append("' , ")
								  .append(" '300' , ") //-- Set Status to 300 , Complete Task Already ---//
								  .append(" '").append(nowDate).append("' , ")
								  //.append(" today , ")
								  .append(" '").append(user.getUserID()).append("' , null ) "); 
							stmt1.executeUpdate(sql.toString());
							//------ Keep iDocNo that update status to 300 for next step -------//
							if (!iDocNoList.contains(docno)) { 
								iDocNoList.addElement(docno);
							} 
					 	}


						//---========== count record in serv_docdt & serv_payment ============----//
						/*
						 *    remove 2011-03-21
						 * 					
						int countdt = 0;
						 sql.delete(0,sql.length());
						 sql.append(" select  count(*) cnt from lan:serv_docdt where f_itmstatus='400' ")
							   .append(" and i_docno='").append(docno).append("' ")
							   .append(" and i_vendor='").append(vendorId).append("' ");
						 rs = stmt.executeQuery(sql.toString());
						 if (rs.next()) {
							countdt = rs.getInt("cnt"); 
						 }
						 rs.close();		
	
						int countpay = 0;
						 sql.delete(0,sql.length());
						 sql.append(" select  count(*) cnt from lan:serv_payment where f_itmstatus='400' ")
							   .append(" and i_docno='").append(docno).append("' ")
							   .append(" and i_vendor='").append(vendorId).append("' ");
						 rs = stmt.executeQuery(sql.toString());
						 if (rs.next()) {
							countpay = rs.getInt("cnt"); 
						 }
						 rs.close();		
						 if (countdt!=countpay) {
						 		throw new Exception(" [SERV_COMPTASK - ERROR][Record in serv_docdt & serv_payment not equal] ["+docno+","+vendorId+"] "+countdt+"<>"+countpay);
						 }
						 */
				} // end for vendor list		

				//======== move update outside loop , 2011-03-21 ==============//
				for (int i=0;i<vendor.length;i++) {					   
						StringTokenizer id = new StringTokenizer(vendor[i],":");
						if (id.countTokens()!=2) continue; 
						docno = id.nextToken();
						String vendorId = id.nextToken();
						//---======== Update Item Status to 400 if that item is for this vendor ========----//
						sql.delete(0,sql.length());
						sql.append("update lan:serv_docdt set ")
							  .append(" f_itmstatus='400' ") //---- Set status to 400 , Complete Task 
							  .append(" where i_docno='").append(docno).append("'  ")
							  .append(" and i_vendor='").append(vendorId).append("'  ")
							//  .append(" and i_itmjob='").append(iItmJob).append("'  ")								  
							  .append(" and f_itmstatus='300'  ");							  
						stmt1.executeUpdate(sql.toString());					   
				} // end for				
				//========================================================//

			} // end if vendor list is not null
			//----======================================----//			

			//----========== If all job is complete task , set d_complete_max ============----//
			if (iDocNoList!=null) {
				for (int c=0;c<iDocNoList.size();c++) {
					    docno = (String) iDocNoList.elementAt(c);
						sql.delete(0,sql.length());
						sql.append(" select i_vendor ,max(f_itmstatus) max_status from lan:serv_flow ")
							  .append(" where i_docno='").append(docno).append("' ")
							  .append(" group by i_vendor ");
						rs = stmt.executeQuery(sql.toString());
						boolean completeAllTask = false;					   					   
						while (rs.next()) {
							String maxStatus = doString.checkString(rs.getString("max_status"),"0");
							try {
							   int maxStat = Integer.parseInt(maxStatus);
							   if (maxStat<300) {
								   //----- If have some status is less than 300 , stop process -----//
								   completeAllTask = false;
								   break;
							   } else {
								   completeAllTask = true;
							   }
							} catch (Exception e) {
								//---- If status is character , stop process -----// 
								completeAllTask = false;
								break;
							}
						} 
						rs.close();
						if (completeAllTask) {
							sql.delete(0,sql.length());
							sql.append(" update lan:serv_dochd set d_complete_max = today ")
								  .append(" where i_docno='").append(docno).append("' ");
							stmt1.executeUpdate(sql.toString());						  
						}					    
				} // end for c 
			}
		   //----===============================================================----//

			conn.commit();
			stmt.close();
			stmt1.close();
			conn.close();
			conn = null;
			String from_page = doString.checkString(req.getParameter("from_page"),"");
			if(!"".equals(from_page)){
				successPage = "/LHServ/"+from_page+"?sel_project="+selProj+"&i_docno="+docno+"&itmtype="+doString.checkString(req.getParameter("itmtype"),"");
				errorPage = "/LHServ/"+from_page+"?error=1&sel_project="+selProj+"&i_docno="+docno+"&itmtype="+doString.checkString(req.getParameter("itmtype"),"");
			}
			// Redirect to the finish page.
			genRedirectCode(out,savePage,successPage,errorCode,otherMsg);
		} catch (Exception e) {
			if (e instanceof InvalidParameterException) {
				showError(out, doString.UnicodeToMS874(e.getMessage()));
			} else {           
			System.out.println(" ERROR "+mName+" : " + e.getMessage());
			System.out.println(" ERROR "+mName+" SQL : " + sql.toString());
			}

			//res.sendRedirect(errorPage);
			System.out.println("error = "+errorPage);
			genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ : "+e.getMessage());
		} finally {
			out.close();
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

