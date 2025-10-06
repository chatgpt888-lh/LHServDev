package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.naming.*;

import serv.common.User;
import com.lh.servlet.DBServlet;
import com.lh.util.*;
import com.lh.exception.InvalidParameterException;



/**
 * @version 	1.0
 * @author
 */
public class SERV_SavePhaseProjServlet extends DBServlet  {
	
	
	
  /************************************************************************************************************/
  private void genRedirectCode(PrintWriter out,String page,String error,String otherMsg) {
	out.println("<html><body>");		
	out.println("<form method='post' action='"+page+"'>");		
	out.println("<input type='hidden' name='error' value='"+error+"'>");
	out.println("<input type='hidden' name='other_msg' value='"+doString.MS874ToUnicode(otherMsg)+"'>");
	out.println("<script> document.forms[0].submit();</script>");
	out.println("</form></body></html>");		
  }
  /************************************************************************************************************/
  
  
  	public String converDateSQL(String date) throws Exception {
  		String result = "";
  		
  		if (date.length()>=10) {
  			if ((date.indexOf("/")==2 || date.indexOf("-")==2) && (date.lastIndexOf("/")==5 || date.lastIndexOf("-")==5)) {
  				int y = Integer.parseInt(date.substring(6,10));
  				if (y>2400) y -= 543;
  				result = y+"-"+date.substring(3,5)+"-"+date.substring(0,2);
  			} else {
  				int y = Integer.parseInt(date.substring(0,4));
  				if (y>2400) y -= 543;
  				result = y+"-"+date.substring(5,7)+"-"+date.substring(8,10);  				
  			}
  		} else {
  			throw new Exception("DATE_ERR_"+date);
  		}
  		
  		return result;
  	}
  
  
	public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		String mName = new String(this.getClass().getName() + ".performTask: ");
		System.out.println(mName + "start.");

		//-----======= Check Login session =======-----//
		HttpSession session = req.getSession(false);
		if (session == null) {
			//---===== No Session , redirect to warning =======---// 
			res.sendRedirect("/warning.htm");
			return;
		}
		Object obj = session.getAttribute("USER");
		if (obj == null) {
			//---===== Can't get User Login , redirect to warning ======---// 
			res.sendRedirect("/warning.htm");
			return;
		}
		
		User user = (User) obj;
		//----===================================----//	
 
		res.setContentType("text/html; charset=TIS-620");
	    PrintWriter out = res.getWriter();
	    
		String selProj = doString.checkString(req.getParameter("sel_project"),"");
		String iCompany = selProj.length()>=6 ? selProj.substring(0,2) : "";
		String iProject = selProj.length()>=6 ? selProj.substring(3,6) : "";		
		String act = doString.checkString(req.getParameter("act"),"");

	    
		String successPage = "/LHServ/save_ok.jsp?redirect_url=SERV_PhaseProjList.jsp?d=";
		String errorPage = "/LHServ/SERV_PhaseProjAdd.jsp?d=";

	    String params = "&act="+act+"&sel_project="+selProj;	    
	    String errorParams = "";
	    
	    
		StringBuffer sql = new StringBuffer();
		Connection conn = null;
		Statement stmt = null;
		
		

		 try {
			if (ds == null)
				getDS();

			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
			
			
			if (act.equalsIgnoreCase("ADD") || act.equalsIgnoreCase("EDIT")) {
				String iPhase = doString.checkString(req.getParameter("i_phase"),"");
				String fProject = doString.checkString(req.getParameter("f_project"),"");
				String fExtra = doString.checkString(req.getParameter("f_extra"),"N");
				String dEndProj = doString.checkString(req.getParameter("d_end_project"),"");
				String dPublic = doString.checkString(req.getParameter("d_public"),"");
				double zPrice = Double.parseDouble(doString.checkString(req.getParameter("z_price"),"0.00"));
				double zClub = Double.parseDouble(doString.checkString(req.getParameter("z_club"),"0.00"));
				errorParams  = "&i_phase="+iPhase+"&f_project="+fProject+"&f_extra="+fExtra;
				errorParams += "&d_end_project="+dEndProj+"&d_public="+dPublic+"&z_price="+zPrice;
				errorParams += "&z_club="+zClub;

				
				//=========== Add new phase ===========//
				if (act.equalsIgnoreCase("ADD")) {
					errorPage = "/LHServ/SERV_PhaseProjAdd.jsp?d=";
					
					//--- check exist before insert ---//
					int cntPhase = 0;
					sql.delete(0,sql.length());
					sql.append(" select count(*) as cnt from lan:acspubhd ")
					   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
					   .append(" and i_phase='"+iPhase+"' ");
					ResultSet rs = stmt.executeQuery(sql.toString());		
					if (rs.next()) {
						cntPhase = rs.getInt("cnt");
					}
					rs.close();							
 					
					if (cntPhase>0) {
						throw new Exception("ERR_EXIST_PHASE");
					}
					
					//---- insert header ----//
					sql.delete(0,sql.length());
					sql.append(" insert into lan:acspubhd ( ")
					   .append(" i_company, 	i_project, 	i_phase, 	z_thiev_ins,   ")
					   .append(" d_end_project, f_extra, 	f_project, 	z_club	")
					   .append(" ) values ( ")
					   .append(" '"+iCompany+"', '"+iProject+"', '"+iPhase+"', null, ")
					   .append(" '"+converDateSQL(dEndProj)+"', '"+fExtra+"', '"+fProject+"', ")
					   .append(" '"+doString.displayNumber("######0.00", zClub)+"') ");
System.out.println(sql.toString());					
					stmt.executeUpdate(doString.UnicodeToMS874(sql.toString()));		

					//---- insert detail ----//
					sql.delete(0,sql.length());
					sql.append(" insert into lan:acspubdt ( ")
					   .append(" i_company, i_project, i_phase, z_price, d_public ")
					   .append(" ) values ( ")
					   .append(" '"+iCompany+"', '"+iProject+"', '"+iPhase+"', ")
					   .append(" '"+doString.displayNumber("######0.00", zPrice)+"', ")
					   .append(" '"+converDateSQL(dPublic)+"') ");
System.out.println(sql.toString());					
					stmt.executeUpdate(doString.UnicodeToMS874(sql.toString()));
				}
				//=====================================//
				
				
				//========== Edit new phase ===========//
				else {
					errorPage = "/LHServ/SERV_PhaseProjForm.jsp?d=";
					double newPrice = Double.parseDouble(doString.checkString(req.getParameter("new_price"),"0.00"));
				
					sql.delete(0,sql.length());
					sql.append(" update lan:acspubhd set ")
					   .append(" d_end_project='"+converDateSQL(dEndProj)+"', ")
					   //.append(" f_extra='"+fExtra+"', f_project='"+fProject+"', ")
					   .append(" z_club='"+doString.displayNumber("######0.00", zClub)+"' ")
					   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
					   .append(" and i_phase='"+iPhase+"' ");					
					stmt.executeUpdate(doString.UnicodeToMS874(sql.toString()));					

					/*
					 * 
					 *   2024-07-09 , no edit or update z_price in lan:acspubdt 
					 * 
					 * 
					//--- check z_price with lastest ---//
					double lastPrice = 0.0;
					String lastPublic = "";
					sql.delete(0,sql.length());
					sql.append(" select * from lan:acspubdt ")
					   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
					   .append(" and i_phase='"+iPhase+"' ")
					   .append(" order by d_public desc ");
					ResultSet rs = stmt.executeQuery(sql.toString());		
					if (rs.next()) {
						lastPublic = doString.checkString(rs.getString("d_public"),"");
						lastPrice = rs.getDouble("z_price");
					}
					rs.close();	
					
					//---- insert detail if z_price is change ----//
					if (newPrice>0 && lastPrice>0 && lastPrice!=newPrice && lastPublic.length()>=10) {
						//--- delete all d_public with future than today, use today's price as an active price ---//
						sql.delete(0,sql.length());
						sql.append(" delete from lan:acspubdt ")
						   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
						   .append(" and i_phase='"+iPhase+"' and d_public>=today ");
						stmt.executeUpdate(doString.UnicodeToMS874(sql.toString()));									
						
						//--- insert today price ---//
						sql.delete(0,sql.length());
						sql.append(" insert into lan:acspubdt ( ")
						   .append(" i_company, i_project, i_phase, z_price, d_public ")
						   .append(" ) values ( ")
						   .append(" '"+iCompany+"', '"+iProject+"', '"+iPhase+"', ")
						   .append(" '"+doString.displayNumber("######0.00", newPrice)+"', ")
						   .append(" today) ");
						stmt.executeUpdate(doString.UnicodeToMS874(sql.toString()));							
					} // end if change price
					*
					*
					*
					*/
				}
				//=====================================//
			} 
			
			
			//========== Add new price ===========//
			/*
			 * cancel , use update method above instead
			 *  
			else if (act.equalsIgnoreCase("ADD_PRICE")) {				
				String iPhase = doString.checkString(req.getParameter("i_phase"),"");
				String newPublic = doString.checkString(req.getParameter("new_public"),"");
				double newPrice = Double.parseDouble(doString.checkString(req.getParameter("new_price"),"0.00"));
				
				errorPage = "/LHServ/SERV_PhaseProjForm.jsp?d=";				
				errorParams = "&i_phase="+iPhase+"&new_public="+newPublic+"&new_price="+newPrice;		
				
				//---- insert detail ----//
				sql.delete(0,sql.length());
				sql.append(" insert into lan:acspubdt ( ")
				   .append(" i_company, i_project, i_phase, z_price, d_public ")
				   .append(" ) values ( ")
				   .append(" '"+iCompany+"', '"+iProject+"', '"+iPhase+"', ")
				   .append(" '"+doString.displayNumber("######0.00", newPrice)+"', ")
				   .append(" '"+converDateSQL(newPublic)+"') ");
				stmt.executeUpdate(doString.UnicodeToMS874(sql.toString()));		
			}*/
			//=====================================//
			
			
			//========== Delete Phase ============//
			else if (act.equalsIgnoreCase("DEL")) {				
				String delPhase = doString.checkString(req.getParameter("del_phase"),"");
				errorPage = "/LHServ/SERV_PhaseProjList.jsp?d=";				
				
				//---- delete phase header ----//
				sql.delete(0,sql.length());
				sql.append(" delete from lan:acspubhd ")
				   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
				   .append(" and i_phase='"+delPhase+"' ");				
				stmt.executeUpdate(doString.UnicodeToMS874(sql.toString()));
				
				//---- delete all detail ----//
				sql.delete(0,sql.length());
				sql.append(" delete from lan:acspubdt ")
				   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
				   .append(" and i_phase='"+delPhase+"' ");				
				stmt.executeUpdate(doString.UnicodeToMS874(sql.toString()));	
			}
			//=====================================//
			
			
			
			
			//************************************* Manage lan:acspublc **************************************//
			else if (act.indexOf("PUBLC_")==0) {
				String iPhase = doString.checkString(req.getParameter("i_phase"),"");
				successPage = "/LHServ/save_ok.jsp?redirect_url=SERV_PhaseProjList2.jsp?d=";
				errorPage = "/LHServ/SERV_PhaseProjForm2.jsp?act="+act;
				act = act.substring(6); // remove prefix 'PUBLC_'

				//--- add ---//
				if (act.equalsIgnoreCase("ADD")) {					
					int iPublic = Integer.parseInt(doString.checkString(req.getParameter("i_public"),"0"));
					int qYear = Integer.parseInt(doString.checkString(req.getParameter("q_year"),"0"));
					double zPayAmt = Double.parseDouble(doString.checkString(req.getParameter("z_pay_amt"),"0.00"));
					errorPage += "&i_phase="+iPhase+"&i_public="+iPublic+"&q_year="+qYear;
					errorPage += "&z_pay_amt="+doString.displayNumber("######0.00", zPayAmt);
					
					//--- check exist before insert ---//
					int cntPhase = 0;
					sql.delete(0,sql.length());
					sql.append(" select count(*) as cnt from lan:acspublc ")
					   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
					   .append(" and i_phase='"+iPhase+"' ");
					ResultSet rs = stmt.executeQuery(sql.toString());		
					if (rs.next()) {
						cntPhase = rs.getInt("cnt");
					}
					rs.close();							
 					
					if (cntPhase>0) {
						throw new Exception("ERR_EXIST_PHASE");
					}
					
					//--- insert data ---//
					sql.delete(0,sql.length());
					sql.append(" insert into lan:acspublc ( ")
					   .append(" i_company, i_project, i_phase, i_public, q_year, z_pay_amt ")
					   .append(" ) values ( ")
					   .append(" '"+iCompany+"', '"+iProject+"', '"+iPhase+"', ")
					   .append(" '"+iPublic+"', '"+qYear+"', ")
					   .append(" '"+doString.displayNumber("######0.00", zPayAmt)+"') ");					
					stmt.executeUpdate(doString.UnicodeToMS874(sql.toString()));						
				}
				
				//--- edit ---//
				if (act.equalsIgnoreCase("EDIT")) {
					int iPublic = Integer.parseInt(doString.checkString(req.getParameter("i_public"),"0"));
					int qYear = Integer.parseInt(doString.checkString(req.getParameter("q_year"),"0"));
					double zPayAmt = Double.parseDouble(doString.checkString(req.getParameter("z_pay_amt"),"0.00"));
					errorPage += "&i_phase="+iPhase+"&i_public="+iPublic+"&q_year="+qYear;
					errorPage += "&z_pay_amt="+doString.displayNumber("######0.00", zPayAmt);
					
					sql.delete(0,sql.length());
					sql.append(" update lan:acspublc set ")
					   .append(" i_public='"+iPublic+"', q_year='"+qYear+"', ")
					   .append(" z_pay_amt='"+doString.displayNumber("######0.00", zPayAmt)+"' ")
					   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
					   .append(" and i_phase='"+iPhase+"' ");					
					stmt.executeUpdate(doString.UnicodeToMS874(sql.toString()));					
				}
				
				//--- delete ---//
				if (act.equalsIgnoreCase("DEL")) {
					String delPhase = doString.checkString(req.getParameter("del_phase"),"");
					errorPage = "/LHServ/SERV_PhaseProjList2.jsp?d=";				
					
					//---- delete phase header ----//
					sql.delete(0,sql.length());
					sql.append(" delete from lan:acspublc ")
					   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
					   .append(" and i_phase='"+delPhase+"' ");					
					stmt.executeUpdate(doString.UnicodeToMS874(sql.toString()));						
				}
			}
			//************************************************************************************************//				
			
			
			
			stmt.close();
			stmt = null;
			conn.commit();
			//conn.rollback();
			conn.close();
			conn = null;
			
						
			genRedirectCode(out,successPage+(params.replaceAll("&","|")),"",""); // replace & to | for save_ok.jsp	

		} catch (Exception e) {
			//*
			try {
				System.out.println("Data Rollback!");
				conn.rollback();				
			} catch (Exception ex) {}

			String err = doString.checkString(e.getMessage(),"");
			System.out.println(" ERROR "+mName+" : " + err);
			System.out.println(" ERROR "+mName+" SQL : " + sql.toString());	
			genRedirectCode(out,errorPage+params+errorParams,"1",err);			
			
			e.printStackTrace();
			
		} finally {
			out.close();
			try {
				if (stmt != null) stmt.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");

	}

}
