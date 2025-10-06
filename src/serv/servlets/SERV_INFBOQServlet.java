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
public class SERV_INFBOQServlet extends DBServlet  {
	
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

  
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();

		String mode = doString.checkString(req.getParameter("mode"), "");
		String iGroup = doString.checkString(req.getParameter("i_group"),"");
		String iType = doString.checkString(req.getParameter("i_type"),"");
		String iSeq = doString.checkString(req.getParameter("i_seq"));
		String iItm = iGroup+iType+iSeq;
		String nItm = doString.checkString(req.getParameter("n_itmjob"),"");
		
		String itmType = doString.checkString(req.getParameter("itmType"),"");
		
		String zWageUnit = doString.checkString(req.getParameter("z_wage_unit"),"");
		String zGoodUnit = doString.checkString(req.getParameter("z_good_unit"),"");
		String nCount = doString.checkString(req.getParameter("n_desc"),"");
		String com_acc1 = doString.checkString(req.getParameter("com_acc1"));
		String cus_acc1 = doString.checkString(req.getParameter("cus_acc1"));
		String com_acc2 = doString.checkString(req.getParameter("com_acc2"));
		String cus_acc2 = doString.checkString(req.getParameter("cus_acc2"));
		String com_acc3 = doString.checkString(req.getParameter("com_acc3"));
		String cus_acc3 = doString.checkString(req.getParameter("cus_acc3"));
		
		String dKeyin = doString.checkString(req.getParameter("d_keyin"),"");
			
		/* 		=======================  test  ========================
		System.out.println("mode:"+mode);
		System.out.println("iGroup:"+iGroup);
		System.out.println("iType:"+iType);
		System.out.println("iSeq:"+iSeq);
		System.out.println("nItm:"+nItm);
		System.out.println("iItm"+iItm);
		System.out.println("zWageUnit:"+zWageUnit);
		System.out.println("zGoodUnit:"+zGoodUnit);
		System.out.println("nCount:"+nCount);
		System.out.println("dKeyin:"+dKeyin);
		
		//		=======================  test  ========================*/
		
		
		
		String savePage =Constants.SAVE_PAGE;
		String successPage = "SERV_INFBOQ01.jsp";
		String errorPage = "SERV_INFBOQ02.jsp?i_group="+iGroup+"&i_type="+iType+"&i_seq="+iSeq+"&i_itmjob="+iItm+"&mode="+mode;
		errorPage += "&n_itmjob="+nItm+"&n_desc="+nCount+"&z_wage_unit="+zWageUnit+"&z_good_unit="+zGoodUnit+"&error=1";		
		
		String otherMsg = "";
		String errorCode = "";
    
		StringBuffer sql = new StringBuffer();
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;

		 try {
			if (ds == null)
				getDS();


			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
	
			sql.delete(0,sql.length());
			
			if(dKeyin.length()>0){
			   int year = Integer.parseInt(dKeyin.substring(6,10));
			    if(year>2400){year -= 543;}
			      dKeyin = Integer.toString(year)+"-"+dKeyin.substring(3,5)+"-"+dKeyin.substring(0,2);
			}
			
			
		    //----======== Add Mode , Inseitrt Query =========----//
			if (mode.equalsIgnoreCase("ADD")) {
				//---=========== Check i_group,i_type,i_seq and i_ itmtjob is exist or not =============---//
				sql.append(" select count(*) as cnt from lan:serv_infboq where ")
					  .append(" i_group='").append(iGroup).append("' ")
					  .append(" and i_type='").append(iType).append("' ")
					  .append(" and i_seq='").append(iSeq).append("' ")
					  .append(" and i_itmjob='").append(nItm).append("' ");
				rs = stmt.executeQuery(sql.toString());				
				int cnt = -1;
				if (rs.next()) {
					cnt = rs.getInt("cnt");
				}
				rs.close();
				
				if (cnt==0) {
					
					 
					//---======= i_group,i_type,i_itmjob and i_seq is not exist ========---//
					sql.delete(0,sql.length());
					sql.append("insert into lan:serv_infboq (i_group,i_type,i_seq,i_itmjob,i_itmtype,n_itmjob,z_wage_unit,z_good_unit,n_count,i_com_acc1,i_cus_acc1,i_com_acc2,i_cus_acc2,i_com_acc3,i_cus_acc3,d_keyin")
						  .append(" ) values ( ")
						  .append(" '").append(iGroup).append("' , ") 
						  .append(" '").append(iType).append("' , ")
						  .append(" '").append(iSeq).append("' , ")
						  .append(" '").append(iItm).append("' ,")
						  .append(" '").append(itmType).append("' ,")
						  .append(" '").append(nItm).append("' , ")
						  .append(" '").append(zWageUnit).append("' , ")
						  .append(" '").append(zGoodUnit).append("', ")
					      .append(" '").append(nCount).append("', ")
					      .append(" '").append(com_acc1).append("', ")
					      .append(" '").append(cus_acc1).append("', ")
					      .append(" '").append(com_acc2).append("', ")
					      .append(" '").append(cus_acc2).append("', ")
					      .append(" '").append(com_acc3).append("', ")
					      .append(" '").append(cus_acc3).append("', ")
						  .append(" '").append(dKeyin).append("' ")
						  .append(" ) "); 
				
					stmt.executeUpdate(sql.toString());
					
					//System.out.println(sql.toString());
					successPage = "SERV_INFBOQ01.jsp";
					otherMsg = "รหัส BOQ ใหม่คือ "+iItm;
										
				} else {
				    //----========= i_itmjob is exist , return to input page =========--//	
				    successPage = errorPage;
				    errorCode = "1";
				    otherMsg = "BOQ มีอยู่ในระบบแล้วกรุณากรอกใหม่ !" ;
				}

			}
			//----=================== end add mode===================----//
			
			
			// ----=================== Start Edit Mode ==================-----//	
			else  if (mode.equalsIgnoreCase("EDIT")){
				 iItm = doString.checkString(req.getParameter("i_itmjob"),""); 
				
					sql.append("update lan:serv_infboq  set ")
					   .append(" n_itmjob = '").append(nItm).append("', ")
					   .append(" i_itmtype = '").append(itmType).append("', ")
					   .append(" z_wage_unit = '").append(zWageUnit).append("', ")
					   .append(" z_good_unit = '").append(zGoodUnit).append("', ")
					   .append(" n_count = '").append(nCount).append("', ")
					   .append(" i_com_acc1 = '").append(com_acc1).append("', ")
					   .append(" i_cus_acc1 = '").append(cus_acc1).append("', ")
					   .append(" i_com_acc2 = '").append(com_acc2).append("', ")
					   .append(" i_cus_acc2 = '").append(cus_acc2).append("', ")
					   .append(" i_com_acc3 = '").append(com_acc3).append("', ")
					   .append(" i_cus_acc3 = '").append(cus_acc3).append("', ")
					   .append(" d_keyin ='").append(dKeyin).append("' ")
					   .append(" where i_itmjob='").append(iItm).append("' ");
					stmt.executeUpdate(sql.toString());
				 	successPage = "SERV_INFBOQ01.jsp";
			}
			
			
			//----======== Delete Mode , Insert Query =========----//
			else if (mode.equalsIgnoreCase("delete")) {	
				 successPage = Constants.APP_PATH+"/SERV_INFBOQ01.jsp";	 
				 savePage = Constants.APP_PATH+"/SERV_INFBOQ01.jsp";	 
	 			 errorPage = Constants.APP_PATH+"/SERV_INFBOQ01.jsp&error=1";	
	 			 otherMsg="";
	 			 
	 		
	 			 String ttt = "";
	 			 String[] delid = req.getParameterValues("del_checkbox");
	 			 if (delid!=null) {
			
	 			 	 for (int i=0;i<delid.length;i++) {
	 			 	 	    StringTokenizer id = new StringTokenizer(delid[i],":");
	 			 	 	    
	 			 	 	    //---==== If i_itmjob is missing , continue next data =====----//
	 			 	 	    if (id.countTokens()!=1) continue;
	 			 	 	
	 			 	 	    sql.delete(0,sql.length());
							sql.append("delete from lan:serv_infboq ")
								  .append(" where i_itmjob='").append(id.nextToken()).append("' ");
								  
							stmt.executeUpdate(sql.toString());
						
	 			 	 } // end for
	 			 }
	 			}
			//----========================================----//
			

			conn.commit();
			stmt.close();
			conn.close();
			conn = null;

		    // Redirect to the finish page.
			//res.sendRedirect(doString.UnicodeToMS874(successPage));
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
			genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ "+e.getMessage());
			
		} finally {
			out.close();
			try {
				if (rs!=null) rs.close(); 
				if (stmt != null) stmt.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");

	}

}
