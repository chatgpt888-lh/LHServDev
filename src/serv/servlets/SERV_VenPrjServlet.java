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
public class SERV_VenPrjServlet extends DBServlet  {
	
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
		
		String mode = doString.checkString(req.getParameter("mode"), "");
		String selProj = doString.checkString(req.getParameter("sel_project"),"");
		String iType = doString.checkString(req.getParameter("i_type"),"");
		String iVendor = doString.checkString(req.getParameter("vendor_list"),"");
		
		String savePage = Constants.SAVE_PAGE;
		String successPage = Constants.APP_PATH+"/SERV_VenPrj.jsp?sel_project="+selProj+"&i_type="+iType;
		String errorPage = "SERV_VenPrj01.jsp?sel_project="+selProj+"&i_type="+iType+"&i_vendor="+iVendor+"&error=1";
		String otherMsg = "";
		String errorCode = "";
    
       
	  	//---======== Get Item Details for show ===========---//
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
			//----======== Add Mode , Insert Query =========----//
			Hashtable typeList = (Hashtable) session.getAttribute("sess_vend_type");
			Hashtable codeList = (Hashtable) session.getAttribute("sess_vend_code");
			Hashtable addPayList = (Hashtable) session.getAttribute("sess_vend_add_pay");
			Hashtable addInfList = (Hashtable) session.getAttribute("sess_vend_inf_pay");
			
			if (typeList==null) typeList = new Hashtable();
			if (codeList==null) codeList = new Hashtable();
			if (addPayList==null) addPayList = new Hashtable();
			if (addInfList==null) addPayList = new Hashtable();
									
									
			//---------------- set last p_add_pay to session for used when error --------------------//
			if(codeList!=null && codeList.size()>0){
				Enumeration keys = codeList.keys();
				while (keys.hasMoreElements()) {	
					String key = doString.checkString((String) keys.nextElement(),"");								
				    String payVal = doString.checkString(req.getParameter("p_add_pay"+key),"17.0");
				    String infVal = doString.checkString(req.getParameter("p_inf_pay"+key),"17.0");
				    addPayList.put(key,payVal);
				    addInfList.put(key,infVal);
				}	
			}			
									
									
			
			if (mode.equalsIgnoreCase("ADD")) {
				if(selProj.length()>=6 && selProj!= null){

					String iCom = selProj.substring(0,2);
					String iProj = selProj.substring(3,6);
			
					if(codeList.size()>0){
					    Enumeration keys = codeList.keys();
						while (keys.hasMoreElements()) {
							 String key = doString.checkString((String) keys.nextElement(),"");
							 String name = doString.checkString((String) codeList.get(key),"");
							 String t = doString.checkString((String) typeList.get(key),"");
							 String payVal = doString.checkString((String) addPayList.get(key),"");
							 String infVal = doString.checkString((String) addInfList.get(key),"");
							 if (!t.equals("01")) {
								 payVal = "0.0";
								 infVal = "0.0";
							 }
							 
							 String vendorId = "";
							 if (key.length()>=2) vendorId = key.substring(0,key.length()-2);
							 if (vendorId.length()<=0) continue;		
							 					 
							 
							//---=========== Check i_company and i_project is exist or not =============---//
							sql.delete(0,sql.length());
							sql.append(" select b.bus_name,count(*) as cnt from lan:serv_venprj a ")
							      .append(" left join lan:stpvendr b on b.vend_code=a.i_vendor ")
								  .append(" where i_company='").append(iCom).append("' ")
								  .append(" and i_project='").append(iProj).append("' ")
								  .append(" and i_type='").append(t).append("' ")
								  .append(" and i_vendor='").append(vendorId).append("'")
								  .append(" group by b.bus_name ");                                                                                   
							rs = stmt.executeQuery(sql.toString());				
							 int cnt = -1;
							 String venName = "";
							  if (rs.next()) {
							       cnt = rs.getInt("cnt");
							       venName = doString.checkString(rs.getString("bus_name"),"");
							  }
							 rs.close();

							 
							 //---========== Data does not exist ==========---//
							 if (cnt<=0) {	
								//---======= i_company,i_project,i_type  is not exist ========---//
								sql.delete(0,sql.length());
								sql.append("insert into lan:serv_venprj (i_company,i_project,i_type,i_vendor,p_add_pay,p_inf_pay ")
								   .append(" ) values ( ")
								   .append(" '").append(iCom).append("' , ")
								   .append(" '").append(iProj).append("' , ")
								   .append(" '").append(t).append("' , ")
								   .append(" '").append(vendorId).append("' , ")
								   .append(" '").append(payVal).append("', ")
								   .append(" '").append(infVal).append("' ")
								   .append(" ) ");					    
							    stmt.executeUpdate(sql.toString());
							    successPage = Constants.APP_PATH+"/SERV_VenPrj.jsp?mode=add&sel_project="+selProj;						 	
							 } else {
							 	throw new Exception("<br> ผู้รับเหมา "+venName+" มีอยู่ในโครงการนี้แล้ว !!");
							 }
							 
							 
							 
					   } // end while key
					   
				} // end if check codeList

				
			} else {
				//----========= i_company and i_project  is exist , return to input page =========--//	
				successPage = errorPage;
				errorCode = "1";
				otherMsg = "พบข้อผิดพลาดในระบบ กรุณาดำเนินการใหม่อีกครั้ง !" ;
			}

		}//end  add mode
			
			//----======== Delete Mode , Insert Query =========----//
			else if (mode.equalsIgnoreCase("DELETE")) {		
				
				 successPage = Constants.APP_PATH+"/SERV_VenPrj.jsp?sel_project="+selProj+"&i_type="+iType;
				 savePage = Constants.APP_PATH+"/SERV_VenPrj.jsp?sel_project="+selProj+"&i_type="+iType;
				 errorPage = Constants.APP_PATH+"/SERV_VenPrj.jsp?error=1&sel_project="+selProj+"&i_type="+iType;
	 
				 String ttt = "";
				 String[] delid = req.getParameterValues("vend_code");
				 if (delid!=null) {
					 for (int i=0;i<delid.length;i++) {
							StringTokenizer id = new StringTokenizer(delid[i],":");
	 			 	 	    
							//---==== If i_company or i_project is missing , continue next data =====----//
							if (id.countTokens()!=4) continue;
	 			 	 	
							sql.delete(0,sql.length());
							sql.append("delete from lan:serv_venprj ")
								  .append(" where i_company ='").append(id.nextToken()).append("' ")
								  .append(" and i_project ='").append(id.nextToken()).append("' ")
								  .append(" and i_type ='").append(id.nextToken()).append("' ")
								  .append(" and i_vendor = '").append(id.nextToken()).append("' ");
					  
							
							stmt.executeUpdate(sql.toString());
					 } // end for
				 }
 			}
			//----========================================----//
			

			conn.commit();
			stmt.close();
			conn.close();
			conn = null;
			
			//----======= Clear Session =======---//
		    req.getSession().removeAttribute("sess_vend_type");
			req.getSession().removeAttribute("sess_vend_code");			
			req.getSession().removeAttribute("sess_vend_add_pay");

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
