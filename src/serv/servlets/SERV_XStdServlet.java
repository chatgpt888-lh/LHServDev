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
public class SERV_XStdServlet extends DBServlet  {
	
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
		String iType = doString.checkString(req.getParameter("i_type"), "");
		String iCode = doString.checkString(req.getParameter("i_code"), "");
		String nDesc = doString.UnicodeToMS874(doString.checkString(req.getParameter("n_desc"), ""));
		String pAmount = doString.checkString(req.getParameter("p_amount"), "0");
	
		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_XStd01.jsp";
		String errorPage = "SERV_XStd02.jsp?i_type="+iType+"&i_code="+iCode+"&n_desc="+nDesc+"&p_amount="+pAmount+"&mode="+mode+"&error=1";
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
						
		    //----======== Add Mode , Insert Query =========----//
			if (mode.equalsIgnoreCase("ADD")) {
				
				//---=========== Check i_type and i_code is exist or not =============---//
				sql.append(" select count(*) as cnt from lan:serv_xstd where ")
					  .append(" i_type='").append(iType).append("' ")
					  .append(" and i_code='").append(iCode).append("' ");
				rs = stmt.executeQuery(sql.toString());				
				int cnt = -1;
				if (rs.next()) {
					cnt = rs.getInt("cnt");
				}
				rs.close();
				
				if (cnt==0) {
					//---======= i_type and i_code is not exist ========---//
					sql.delete(0,sql.length());
					sql.append("insert into lan:serv_xstd (i_type,i_code,n_desc,p_amount ")
						  .append(" ) values ( ")
						  .append(" '").append(iType).append("' , ")
						  .append(" '").append(iCode).append("' , ")
						  .append(" '").append(nDesc).append("' , ")
						  .append(" '").append(pAmount).append("' ")
						  .append(" ) "); 
				
					stmt.executeUpdate(sql.toString());
					
					successPage = "SERV_XStd02.jsp?mode=add&i_type="+iType;
										
				} else {
				    //----========= i_type and i_code is exist , return to input page =========--//	
				    successPage = errorPage;
				    errorCode = "1";
				    otherMsg = "รหัสประเภทและรหัสย่อยที่กรอก มีอยู่ในระบบแล้วกรุณากรอกรหัสใหม่ !" ;
				}

			}
			//----======================================----//


			
			//----======== Edit Mode , Insert Query =========----//
			else if (mode.equalsIgnoreCase("EDIT")) {
				sql.append("update lan:serv_xstd set ")
					  .append(" n_desc = '").append(nDesc).append("' , ")
					  .append(" p_amount = '").append(pAmount).append("' ")
					  .append(" where i_type='").append(iType).append("' ")
					  .append(" and i_code='").append(iCode).append("' "); 
				
				stmt.executeUpdate(sql.toString());				
			}
			//----======================================----//


			
			//----======== Delete Mode , Insert Query =========----//
			else if (mode.equalsIgnoreCase("DELETE")) {		
				 successPage = Constants.APP_PATH+"/SERV_XStd01.jsp";	 
				 savePage = Constants.APP_PATH+"/SERV_XStd01.jsp";	 
	 			 errorPage = Constants.APP_PATH+"/SERV_XStd01.jsp?error=1";	
	 			 
	 			 String ttt = "";
	 			 String[] delid = req.getParameterValues("del_id");
	 			 if (delid!=null) {
	 			 	 for (int i=0;i<delid.length;i++) {
	 			 	 	    StringTokenizer id = new StringTokenizer(delid[i],":");
	 			 	 	    
	 			 	 	    //---==== If i_type or i_code is missing , continue next data =====----//
	 			 	 	    if (id.countTokens()!=2) continue;
	 			 	 	
	 			 	 	    sql.delete(0,sql.length());
							sql.append("delete from lan:serv_xstd ")
								  .append(" where i_type='").append(id.nextToken()).append("' ")
								  .append(" and i_code='").append(id.nextToken()).append("' "); 
							
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
