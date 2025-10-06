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
import serv.common.ItmJobManagement;

/**
 * @version 	1.0
 * @author
 */
public class SERV_ContractorConfServlet extends DBServlet  {
	
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

		String iDocNo = doString.checkString(req.getParameter("i_docno"),"");				
		String iVendor = doString.checkString(req.getParameter("i_vendor"),"");				
		String selProj = doString.checkString(req.getParameter("sel_project"),"");

		
		//---========================== Get Item Job List  ===============================----//
		ItmJobManagement itm = new ItmJobManagement(req,res);
		itm.updateValuesFromRequest(); // update new values from request.
		itm.updateItemSession(); // update session before use
       
		//---======== Get Item Details for show ===========---//
		Vector jobList = itm.getJobList();
		Hashtable jobItm = itm.getItmJobList();		
		Hashtable jobVendor = itm.getVendorList();
		Hashtable jobWage = itm.getWageList();
		Hashtable jobCustomWage = itm.getCustomWageList();
		Hashtable jobCustomGoods = itm.getCustomGoodsList();
		Hashtable jobGoods = itm.getGoodsList();
		Hashtable jobBOQ = itm.getBOQList();
		Hashtable jobComment = itm.getCommentList();
		Hashtable jobArea = itm.getAreaList(); 
	
	
		
		//---======= Get Now Date with time =========-----//
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
		String successPage = "SERV_Contractor_List.jsp";
		String errorPage = "SERV_Contractor_Conf.jsp?error=1&i_vendor="+iVendor+"&i_docno="+iDocNo; 
			
		
		String otherMsg = "";
		String errorCode = "";
		String iTypeCut = "";
    
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
		Connection conn = null;
		Statement stmt = null;
		Statement stmt1 = null;
		ResultSet rs = null;

		 try {
			if (ds == null)
				getDS();

			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
			stmt1 = conn.createStatement();

			
			
			//---============== Select Percent From SERV_XSTD ================----//
			// edit 06/12/2007 used p_add_pay from serv_venprj instead serv_xstd
			 //String pAmount = "";
			 double pAddPay = 0.0; 
			 sql.delete(0,sql.length());
			 //sql.append(" select * from lan:serv_xstd where i_type='02' ");
			 sql.append(" select * from lan:serv_venprj where ")
			       .append(" i_company='").append(iDocNo.length()>=6 ? iDocNo.substring(0,2) : "").append("' ")
			       .append(" and i_project='").append(iDocNo.length()>=6 ? iDocNo.substring(3,6) : "").append("' ")
			       .append(" and i_vendor='").append(iVendor).append("' ");
			 rs = stmt.executeQuery(sql.toString());
			 if (rs.next()) {
				 //pAmount = doString.checkString(rs.getString("p_amount"),"0");
				pAddPay = rs.getDouble("p_add_pay");
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
			


			//---============== Select Vat & Tax From ACCVENVT ================----//
			 int vat = 0;
			 int tax = 0;
			String pVatTax = "00";
			 sql.delete(0,sql.length());
			 sql.append(" select * from lan:accvenvt where grp_no='R8' and (ven_no='").append(iVendor).append("' ")
			       .append(" or ven_no='999999') order by ven_no ");		       
			 rs = stmt.executeQuery(sql.toString());
			 if (rs.next()) {
				 pVatTax = doString.checkString(rs.getString("vat_tax_flag"),"00");				 
				 if (pVatTax.length()==2) {
				 	 try {
				 	 	vat = Integer.parseInt(pVatTax.substring(0,1)); 
						tax = Integer.parseInt(pVatTax.substring(1)); 
				 	 } catch (Exception e) {
				 	    System.out.println("Vat , Tax Conversion Error : "+e.getMessage());
				 	 }
				 }
			 }				        
			 rs.close();	
			 



			//-----============= Manage ItemJob on SERV_PAYMENT =================----//
			
			//---- Clear Old Item before save new item list -----//
			sql.delete(0,sql.length());
			sql.append(" delete from lan:serv_payment where i_docno='").append(iDocNo).append("' ")
			      .append(" and i_vendor='").append(iVendor).append("' ")
			      .append(" and f_itmstatus='400' ");
			stmt.executeUpdate(sql.toString());
			
			
			//---- Add New Item to SERV_Payment -----//
			for (int i=0;i<jobList.size();i++) {
  				   String key = (String) jobList.elementAt(i);
				   String id = doString.checkString((String) jobItm.get(key),"");
				   String area = doString.checkString((String) jobArea.get(key),"");
				   String comment = doString.checkString((String) jobComment.get(key),"");
				   double wageUnit = Double.parseDouble(str.replace(doString.checkString((String) jobWage.get(key),"0"),",",""));
				   double goodsUnit = Double.parseDouble(str.replace(doString.checkString((String) jobGoods.get(key),"0"),",",""));

					
					String nItmJob = "";
					double wagePrice = 0.00;
					double goodsPrice = 0.00;
					String BOQDesc = doString.checkString((String) jobBOQ.get(key),"");
					StringTokenizer boq = new StringTokenizer(BOQDesc,":");
					if (boq.countTokens()==3) {
						//---- Get Data from BOQ Session list ------// 
						nItmJob = boq.nextToken();
						wagePrice = Double.parseDouble(str.replace(doString.checkString((String) jobCustomWage.get(key),"0.00"),",",""));
						goodsPrice = Double.parseDouble(str.replace(doString.checkString((String) jobCustomGoods.get(key),"0.00"),",",""));						
					} else {
						//------- Found problem in BOQ Session list , get from table instead ----------//  
						sql.delete(0,sql.length());
						sql.append(" select * from lan:serv_boq where i_itmjob='").append(id).append("' ");
						rs = stmt.executeQuery(sql.toString());
						if (rs.next()) {
							nItmJob = doString.checkString(rs.getString("n_itmjob"),"");
							wagePrice = rs.getDouble("z_wage_unit"); 
							goodsPrice = rs.getDouble("z_good_unit"); 
						}
						rs.close();						
					} // end if

				  //----- Calculate Amount total from wage and goods ------//	
				   double zAmountPay = (wagePrice * (double) wageUnit)+(goodsPrice * (double) goodsUnit);
				   
				   
				  //----- Calculate Amount PV , VAT & TAX -----//
				  //double zAmountPV = zAmountPay+(zAmountPay*(Double.parseDouble(str.replace(pAmount,",",""))/100));   // edit 06/12/2007 used p_add_pay from serv_venprj instead serv_xstd
				 double zAmountPV = zAmountPay+(zAmountPay*(pAddPay/100));   // edit 06/12/2007 used p_add_pay from serv_venprj instead serv_xstd
				  double zAmountVAT = zAmountPV*((double) vat/100);
				  double zAmountTAX = zAmountPV*((double) tax/100); 


						 
				//---================ Insert into SERV_PAYMENT =================----//
				sql.delete(0,sql.length());
				sql.append(" insert into lan:serv_payment (i_docno , i_seq , i_itmjob , i_vendor , ")
					  .append(" q_wage_unit , z_wage_price , q_good_unit , z_good_price , c_itmjob , ")
					  .append(" i_itmjob_area , f_itmstatus , d_payment , i_ven_cut , p_cut , p_add_pay , ")
					  .append(" vat_tax_code , z_amount_pay , z_amount_pv , z_amount_vat , z_amount_tax , ")
					  .append(" pv_no , d_post_pv , z_amount_cut , z_cut_pv , z_cut_vat , z_cut_tax , i_refno , ")
					  .append(" d_post_cut , f_posted , f_reject , i_employ_reject , d_reject , c_reject , f_remark ")
					  .append(" ) values ( ")
					  .append(" '").append(iDocNo).append("' , ")				         
					  .append(" '").append(i+1).append("' , ")
					  .append(" '").append(id).append("' , ")				         
					  .append(" '").append(iVendor).append("' , ")				         
					  .append(" '").append(wagePrice).append("' , ")				         
					  .append(" '").append(wageUnit).append("' , ")				         
					  .append(" '").append(goodsPrice).append("' , ")				         
					  .append(" '").append(goodsUnit).append("' , ")				         
					  .append(" '").append(doString.UnicodeToMS874(comment)).append("' , ")				         
					  .append(" '").append(area).append("' , ")				         
					  .append(" '500' , ")  //--- Set Status to 500 , Wait Service Staff Approve ---// 
					  .append(" '").append(paymentDate).append("' , ")				         
					  .append(" null , null , ")  //--- Cut Description ---// 
					  //.append(" '").append(pAmount).append("' , ")  // edit 06/12/2007 used p_add_pay from serv_venprj instead serv_xstd
					  .append(" '").append(pAddPay).append("' , ")   // edit 06/12/2007 used p_add_pay from serv_venprj instead serv_xstd				         
					  .append(" '"+pVatTax+"' , ")   
					  .append(" '").append(zAmountPay).append("' , ")
					  .append(" '").append(zAmountPV).append("' , ")
					  .append(" '").append(zAmountVAT).append("' , ")
					  .append(" '").append(zAmountTAX).append("' , ")   
					  .append(" null , null , ")  //--- Pay Description ---// 
					  .append(" null , null , null , null , null , null , 'N' , ")  //--- Constructor Cut Description ---// 
					  .append(" null , null , null , null , null ) ");  //--- Reject Description ---// 	
					  			 
				 stmt1.executeUpdate(sql.toString());
			} // end for						
			//-----==================================================================================----//
			

			
			//-----===================Clear SERV_FLOW that status more than 400 ========================----//
			sql.delete(0,sql.length());
			sql.append(" delete from lan:serv_flow where i_docno='").append(iDocNo).append("' ")
			      .append(" and i_vendor='").append(iVendor).append("' and f_itmstatus>='400' ");
			stmt.executeUpdate(sql.toString());



			//-----======================== Insert new SERV_FLOW again ==============================----//
			sql.delete(0,sql.length());
			sql.append(" insert into lan:serv_flow (i_docno,i_vendor,f_itmstatus,d_approve,i_approve,c_reject ")
				  .append(") values (")
				  .append(" '").append(iDocNo).append("' , ")
				  .append(" '").append(iVendor).append("' , ")
				  .append(" '400' , ") //-- Set Status to 400 , Contractor already send job ---//
				  .append(" '").append(nowDate).append("' , ")
				  .append(" '").append(user.getUserID()).append("' , null ) "); 
			stmt.executeUpdate(sql.toString());
			
			
			
			//-----==================================================================================----//

			conn.commit();
			stmt.close();
			conn.close();
			conn = null;
			
			//---==== Clear ItemJob Session =====----//
			itm.removeItemSession();

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
				if (pstmt != null) pstmt.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");

	}

}
