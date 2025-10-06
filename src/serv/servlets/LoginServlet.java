package serv.servlets;
import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.naming.*;
//import com.ibm.jvm.Constants;
import com.lh.servlet.DBServlet;
import com.lh.util.doString;
import com.lh.exception.InvalidParameterException;
import com.lh.util.LHMail;
import javax.mail.*;
import javax.mail.internet.*;
import serv.common.User;
import serv.common.Constants;
/***********************************
 *  modify by :pradoem wongkrazo
 *  modify date :2012.08.09
 *  version :1.0
 *  project name: LHServ && sub program is Zero Defect
 *  description: support login from  email clik link by pass auto login krub.
 *  standard parameter receiver :
 *  userid
 *  password
 *  iDocNo
 *  url 
 **********************************/

public class LoginServlet extends DBServlet {
	
	private static String cName = "/LHServ/LoginServlet";   
  synchronized private int getsessionId(Connection conn) throws SQLException {
	int sessionid=0;
	Statement stmt = null;
	ResultSet rsSession = null;
	try {
		stmt = conn.createStatement();
		rsSession = stmt.executeQuery("SELECT i_session FROM lan:serv_session");
		if (rsSession.next() == true) {
			sessionid = rsSession.getInt("I_SESSION");
		}
		rsSession.close();
		stmt.executeUpdate("UPDATE lan:serv_session SET i_session = i_session + 1");
		stmt.close();
        
		rsSession = null;        
		stmt = null;
	}
	catch (SQLException e) {
		throw e;
	}
	// Do this no matter what.
	finally {
		// Clean up.
		try {
			if (stmt != null)
				stmt.close();
			if (rsSession != null)
				rsSession.close();
		}
		catch (SQLException ignore) { }
	}
	return (sessionid);
  }
  
  private User locate(Connection conn, String userid, String password) throws Exception {
	  Statement ustmt = null;
	  ResultSet rsUser = null;
	  User user = null;
	  String who = "";
	  String empId = "";
	  String name = "";
	  boolean acap = false;
	  StringBuffer sql = new StringBuffer();
	  try {
		  ustmt = conn.createStatement();
		  
		  //----========== If this user is vendor , get new name from stpvendr ==========----//
		  String userWho = "";
		  String userGroup = "";
		  String iPerson = "";
		  String userCom = "";
		  sql.delete(0,sql.length());
		  sql.append(" select user_who,i_person, user_group, user_com  from lan:useracl where user_acl='S' and user_id='").append(userid).append("' ");
		  System.out.println("SQL Login1:"+sql.toString());
		  rsUser = ustmt.executeQuery(sql.toString());
		  if (rsUser.next()) {
			  userWho = doString.checkString(rsUser.getString("user_who"),"");
			  iPerson = doString.checkString(rsUser.getString("i_person"),"");
			  userGroup = doString.checkString(rsUser.getString("user_group"),"");
			  userCom = doString.checkString(rsUser.getString("user_com"),""); //add by pradoem 2023.05.29 for vp home
		  }
		  rsUser.close();
		  rsUser = null;
		  		  
		  if (userWho.equalsIgnoreCase(Constants.PERMISSION_VENDOR)) {
		  	 
		  	    sql.delete(0,sql.length());
		  	    sql.append(" select * from lan:stpvendr where vend_code='").append(iPerson).append("' ");
				rsUser = ustmt.executeQuery(sql.toString());
		         
				//allow user
				if (rsUser != null) {
					if (rsUser.next() == true) {
						user = new User();
						//empId = doString.checkString(rsUser.getString("I_EMPLOY"));
						user.setUserID(userid);
						//user.setUserName(rsUser.getString("USER_NAME"));
						user.setUserWho(userWho);
						user.setUserGroup(userGroup);
						user.setUserACL("S");
						//user.setEmail(rsUser.getString("USER_EMAIL"));
						user.setEmpId(doString.checkString(rsUser.getString("VEND_CODE")));
						user.setEmpName(doString.checkString(rsUser.getString("BUS_NAME")));
						/*
						user.setPosition(doString.checkString(rsUser.getString("POSITION")));
						user.setDivisionId(doString.checkString(rsUser.getString("I_DIVISION")));
						user.setGroup(doString.checkString(rsUser.getString("A_DEPT")));
						user.setDivision(doString.checkString(rsUser.getString("DIVISION")));
						user.setCompanyId(doString.checkString(rsUser.getString("I_COMPANY")));
						user.setCompany(doString.checkString(rsUser.getString("N_COMPANY")));
						//user.setLevel(Integer.parseInt(doString.checkString(rsUser.getString("I_LEVEL"))));	
						*/	        
					}
					rsUser.close();
					rsUser = null;
				}		  	 
		  	 
		  } 
		  
		 
		 else if (userWho.equalsIgnoreCase("J")) {
			sql.delete(0,sql.length());
			sql.append(" select * from lan:useracl a,lan:serv_cname b where a.user_who='J' and a.user_acl='S'  and b.i_cust=a.i_employ ")
			      .append(" and a.user_id = '").append(userid).append("' and a.user_password = '").append(password).append("' ");
			rsUser = ustmt.executeQuery(sql.toString());
			 System.out.println("SQL Login2:"+sql.toString());    
			//allow user
			if (rsUser != null) {
				if (rsUser.next() == true) {
					user = new User();
					user.setUserID(userid);
					user.setUserName(rsUser.getString("USER_NAME"));
					user.setUserWho(userWho);
					user.setUserGroup(userGroup);
					user.setUserACL("S");
					//user.setEmail(rsUser.getString("USER_EMAIL"));
					user.setEmpId(doString.checkString(rsUser.getString("I_EMPLOY")));
					user.setEmpName(doString.checkString(rsUser.getString("N_NAME"))+" "+doString.checkString(rsUser.getString("N_SNAME"))); 
				}
				rsUser.close();
				rsUser = null;
			}		  	 		 	 
	   	 }
	   	 
		  		  
		  else {
		  	
				sql.delete(0,sql.length());
				sql
					.append("SELECT u.user_name, u.user_who, u.user_group, u.user_acl, u.user_email, ")
					.append("                  e.i_employ, TRIM(e.n_prename_th) || ' ' || TRIM(e.n_nemploy_th) || ' ' || TRIM(e.n_semploy_th) AS EMP_NAME, ")
					.append("                  j.i_job, j.i_company, c.n_company, j.i_division, j.d_job, d.n_desc AS DIVISION, ")
					.append("                  p.n_desc AS POSITION, g.a_dept, j.i_level ")
					.append(" FROM   lan:useracl u, docflow:acemploy e, docflow:acempjob j, ")
					.append("                 docflow:acempstd d, docflow:acempstd p, docflow:acxcompa c, docflow:dfz_dept g")
					.append(" WHERE u.user_id = '").append(userid).append("' ")
					.append("                  AND u.user_password = '").append(password).append("' ")
					.append("                  AND u.user_acl='S' AND e.i_employ = u.i_employ AND e.d_retry IS NULL ")
					.append("                  AND j.i_employ = e.i_employ AND d.i_type = '11' AND d.i_code = j.i_division ")
					.append("                  AND g.i_code = j.i_division AND p.i_type = '10' ")
					.append("                  AND p.i_code = j.i_job AND c.i_company = j.i_company ")
					.append(" ORDER BY j.d_job DESC ");

				rsUser = ustmt.executeQuery(sql.toString());
				System.out.println("SQL Login2:"+sql.toString());
				//allow user
				if (rsUser != null) {
					if (rsUser.next() == true) {
						user = new User();
						empId = doString.checkString(rsUser.getString("I_EMPLOY"));
						user.setUserID(userid);
						user.setUserName(rsUser.getString("USER_NAME"));
						user.setUserWho(rsUser.getString("USER_WHO"));
						user.setUserGroup(rsUser.getString("USER_GROUP"));
						user.setUserACL(rsUser.getString("USER_ACL"));
						user.setEmail(rsUser.getString("USER_EMAIL"));
						user.setEmpId(empId);
						name = doString.checkString(rsUser.getString("EMP_NAME"));
						user.setEmpName(doString.checkString(rsUser.getString("EMP_NAME")));
						user.setPosition(doString.checkString(rsUser.getString("POSITION")));
						user.setDivisionId(doString.checkString(rsUser.getString("I_DIVISION")));
						user.setGroup(doString.checkString(rsUser.getString("A_DEPT")));
						user.setDivision(doString.checkString(rsUser.getString("DIVISION")));
						user.setCompanyId(doString.checkString(rsUser.getString("I_COMPANY")));
						user.setCompany(doString.checkString(rsUser.getString("N_COMPANY")));
						//user.setLevel(Integer.parseInt(doString.checkString(rsUser.getString("I_LEVEL"))));	
						//add by pradoem 2023.05.29
						user.setUserCom(userCom);
					}
					rsUser.close();
					rsUser = null;
				}
		  } // end if check permission
		  ustmt.close();
		  ustmt = null;        
	  } catch (Exception e) {
		  System.out.println(e.getMessage());           
		   throw e;

	  }
	  // Do this no matter what.
	  finally {
		  // Clean up.
		  try {
			  try {
				  if (rsUser != null) {
					  rsUser.close();
				  }
			  } finally {
				  if (ustmt != null) {
					  ustmt.close();
				  }
			  }
		  } catch (SQLException ignore) {
		  }
	  }
	  return (user);
  }
  

  private boolean checkExpireUser(Connection conn, String iEmploy, String userid) throws SQLException {
	  Statement stmt = null;
	  ResultSet rs = null;
	  User user = null;
	  boolean result = false;

	  try {
		  stmt = conn.createStatement();	
		  StringBuffer sql = new StringBuffer();
		  sql.delete(0,sql.length());
		  sql.append(" select today-d_modify as count_date from lan:user_change ")
			 .append(" where i_employ='").append(iEmploy).append("' ")
			 .append(" and user_id='").append(userid).append("' ");
		  rs = stmt.executeQuery(sql.toString());     
		  //allow user
		  if (rs != null) {
			  if (rs.next() == true) {			
				  int countDate = rs.getInt("count_date");
				  if (countDate>=90) {
					  result = true;
				  }
			  }
			  rs.close();
			  rs = null;
		  }		  
		  stmt.close();
		  stmt = null;  
               
	  } catch (SQLException e) {
		  throw e;
	  }
	  // Do this no matter what.
	  finally {
		  // Clean up.
		  try {
			  try {
				  if (rs != null) {
					  rs.close();
				  }
			  } finally {
				  if (stmt != null) {
					  stmt.close();
				  }
			  }
		  } catch (SQLException ignore) {
		  }
	  }
	
	  return result;
  }
    
  
public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
	String mName = new String(cName + ".performTask: ");
	System.out.println(mName + "start.");
	
	res.setContentType("text/html; charset=TIS620");
	PrintWriter out = res.getWriter();

	Connection conn = null;
	User user = null;
	try {
 		
		// Get the user's id and password
		String userid = getParameter(req, "userid", true, false, true, null, "กรุณาระบุรหัสผู้ใช้");
		String password = getParameter(req, "password", true, false, true, null, "กรุณาระบุรหัสผ่าน");
        
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setAutoCommit(true);
        
		// Look for this user in the database	
		user = locate(conn, userid, password);
		boolean expireUser = false;        
		if (user!=null) expireUser = checkExpireUser(conn,user.getEmpId(),user.getUserID());
		
		// user will be null if user not found in the database
		if (user == null || expireUser) {
			// Redirect to the site's login page.
			//res.sendRedirect(res.encodeURL(loginPage));
			int error = 1;
			if (expireUser) error = 2;            			
			res.sendRedirect(res.encodeRedirectURL(Constants.LOGIN_PAGE+"?error="+error));
			return;
		} else {
			// Let's create a cookie that represents a unique user id.		
			res.addCookie(new Cookie(Constants.COOKIE_NAME, "yes"));

			// ensure that only a new session is used
			// if there is an existing session, invalidate it and
			// re-create
			// create a session and store the user information
			HttpSession session = req.getSession(true);
			if (session.isNew() == false) {
				session.invalidate();
				session = req.getSession(true);
			}
            
			user.setsessionId(Integer.toString(getsessionId(conn)));
			session.setAttribute("USER", user);

			// Redirect to the site's main page.			
			/*********************************
			 * Modify by pradoem 2012.08.09 
			 * support zerodefect clik link form email for viewer description i_document zerodefection
			 ********************************/
			String url = doString.checkString(req.getParameter("url"),"");
			String iDocNo = doString.checkString(req.getParameter("iDocNo"),"");
			System.out.println("-->target url:"+url+"?cmd=load&i_docno="+iDocNo);
			if(!"".equals(url)){
				res.sendRedirect(url+"?cmd=load&i_docno="+iDocNo);
			}else{
				String main = doString.checkString(req.getParameter("main"),"");
				if(!"".equals(main)){
					res.sendRedirect(Constants.LOGIN_HOME+"?main="+main);
				}else{
					/*edit by pradoem 2023.05.30*/
					if(user.getUserWho().equals("P")){
						res.sendRedirect("/LHServ/SERV_Index_VP.jsp"); //home for VP approve
						System.out.println("-->APP_HOME_VP:/LHServ/SERV_Index_VP.jsp");
					}else{
						res.sendRedirect(Constants.LOGIN_HOME); //home defaul for all user
					}

				}
			}
		}
        
		conn.close();
		conn = null;
	} catch (InvalidParameterException e) {
		showError(out, e.getMessage());
	} catch (Exception e) {	    
		gotoJSPErrorPage(req, res, Constants.ERROR_PAGE, e);
	} finally {
		out.close();
		if (conn != null) {
			try {			
				conn.close();
			} catch (SQLException ignore) {}
		}
	}
	System.out.println(mName + "end.");    
  }
}
