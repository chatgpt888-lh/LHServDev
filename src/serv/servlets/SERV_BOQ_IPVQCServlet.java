package serv.servlets;
import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import com.lh.servlet.DBServlet;
import com.lh.util.*;
import com.lh.exception.InvalidParameterException;
import serv.common.Constants;
/**
 * @version 	1.0
 * @author  : pradoem@lh.co.th
 * date: 2014.10.14
 */
public class SERV_BOQ_IPVQCServlet extends DBServlet  {
	
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
		String zWageUnit = doString.checkString(req.getParameter("z_wage_unit"),"");
		String zGoodUnit = doString.checkString(req.getParameter("z_good_unit"),"");
		String nCount = doString.checkString(req.getParameter("n_desc"),"");   	
		String dKeyin = doString.checkString(req.getParameter("d_keyin"),"");
		//String no = doString.checkString(req.getParameter("no"),"");
		String  rbtInOut = doString.checkString(req.getParameter("rbtInOut"),""); //01=out,02=in
		String savePage =Constants.SAVE_PAGE;
		String successPage = "SERV_BOQ_IPVQC01.jsp"; 
		//SERV_BOQ_IPVQC01.jsp
		//SERV_BOQ_IPVQC02.jsp

	 	String now_page = doString.checkString(req.getParameter("now_page"),"");
	 	String display_type = doString.checkString(req.getParameter("display_type"),"");
	 	String display_line = doString.checkString(req.getParameter("display_line"),"");
	 	String i_groupDDL = doString.checkString(req.getParameter("i_groupDDL"),"");
	 	String i_typeDDL = doString.checkString(req.getParameter("i_typeDDL"),"");		
	 	String parameter = "?&now_page="+now_page+"&d_keyin=&mode=delete&display_type="+display_type+"&display_line="+display_line+"&i_group="+i_groupDDL+"&i_type="+i_typeDDL;
	 	String parameterDelete = "?&now_page="+now_page+"&d_keyin=&mode=delete&display_type="+display_type+"&display_line="+display_line+"&i_group="+iGroup+"&i_type="+iType;
	 	//now_page=1&d_keyin=&mode=delete&display_type=L&display_line=9&i_group=01&i_type=04
 	
		String errorPage = "SERV_BOQ_IPVQC02.jsp?i_group="+iGroup+"&i_type="+iType+"&i_seq="+iSeq+"&i_itmjob="+iItm+"&mode="+mode;
		errorPage += "&n_itmjob="+nItm+"&n_desc="+nCount+"&z_wage_unit="+zWageUnit+"&z_good_unit="+zGoodUnit+"&error=1&rbtInOut="+rbtInOut;		
		
		String otherMsg = "";
		String errorCode = "";
    
		StringBuffer sql = new StringBuffer();
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		 try {
			if (ds == null){
				getDS();
			}

			conn = ds.getConnection();
			conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
			conn.setAutoCommit(false);
			stmt = conn.createStatement();
			sql.delete(0,sql.length());		
			if(dKeyin.length()>0){
			   int year = Integer.parseInt(dKeyin.substring(6,10));
			    if(year>2400){year -= 543;}
			      dKeyin = Integer.toString(year)+"-"+dKeyin.substring(3,5)+"-"+dKeyin.substring(0,2);
			      System.out.println("d_keyin="+dKeyin);
			}				
		    //----======== Add Mode , Inseitrt Query =========----//
			if (mode.equalsIgnoreCase("ADD")) {
				//---=========== Check i_group,i_type,i_seq and i_ itmtjob is exist or not =============---//
				sql.append(" select count(*) as cnt from lan:ipv_qcboq where ")
					  .append(" i_group='").append(iGroup).append("' ")
					  .append(" and i_type='").append(iType).append("' ")
					  .append(" and i_seq='").append(iSeq).append("' ")
					  .append(" and i_itmjob='").append(nItm).append("' ");
				rs = stmt.executeQuery(sql.toString());				
				int cnt = -1;
				if (rs.next()) {
					cnt = rs.getInt("cnt");
				}
				//*********//Duplicate ID
				
				rs.close();			
				if (cnt==0) {					 
					//---======= i_group,i_type,i_itmjob and i_seq is not exist ========---//
					sql.delete(0,sql.length());
					sql.append("insert into lan:ipv_qcboq (i_group,i_type,i_seq,i_itmjob,n_itmjob,z_wage_unit,z_good_unit,n_count,d_keyin,f_in_out")
						  .append(" ) values ( ")
						  .append(" '").append(iGroup).append("' , ") 
						  .append(" '").append(iType).append("' , ")
						  .append(" '").append(iSeq).append("' , ")
						  .append(" '").append(iItm).append("' ,") 
						  .append(" '").append(nItm).append("' , ")
						  .append(" '").append(zWageUnit).append("' , ")
						  .append(" '").append(zGoodUnit).append("', ")
					      .append(" '").append(nCount).append("', ")
						  .append(" '").append(dKeyin).append("', ")
						   .append(" '").append(rbtInOut).append("' ")
						  .append(" ) "); 				
					stmt.executeUpdate(sql.toString()); 									
					successPage = "SERV_BOQ_IPVQC01.jsp"+parameter;
					otherMsg = "รหัส BOQ ใหม่คือ "+iItm;
										
				} else { //Duplicate ID
				    //----========= i_itmjob is exist , return to input page =========--//	
				    successPage = errorPage;
				    errorCode = "1";
				    otherMsg = "BOQ มีอยู่ในระบบแล้วกรุณากรอกใหม่ !" ;
				}
			}
			//----=================== end add mode===================----//		
			// ----=============== Start Edit Mode ==================-----//	
			else  if (mode.equalsIgnoreCase("EDIT")){
				 iItm = doString.checkString(req.getParameter("i_itmjob"),""); 			
					System.out.println("--->start update data<----");		 	
					sql.append(" Update lan:ipv_qcboq  set ")
					   .append(" n_itmjob = '").append(nItm).append("', ")
					   .append(" z_wage_unit = '").append(zWageUnit).append("', ")
					   .append(" z_good_unit = '").append(zGoodUnit).append("', ")
					   .append(" n_count = '").append(nCount).append("', ")
					   .append(" d_keyin ='").append(dKeyin).append("', ")
					   .append(" f_in_out ='").append(rbtInOut).append("' ")
					   .append(" Where i_itmjob='").append(iItm).append("' ");					
					stmt.executeUpdate(sql.toString());		
				 	successPage = "SERV_BOQ_IPVQC01.jsp"+parameter;			 
			}	
			//----======== Delete Mode , Insert Query =========----//
			else if (mode.equalsIgnoreCase("delete")) {	
				 successPage = Constants.APP_PATH+"/SERV_BOQ_IPVQC01.jsp"+parameterDelete;	 
				 savePage = Constants.APP_PATH+"/SERV_BOQ_IPVQC01.jsp"+parameterDelete;	 
	 			 errorPage = Constants.APP_PATH+"/SERV_BOQ_IPVQC01.jsp&error=1";	
	 			 otherMsg="";			 	
	 			 //String ttt = "";
	 			 String itm = "";
	 			 String[] delid = req.getParameterValues("del_checkbox");
	 			 if (delid!=null) {			
	 			 	 for (int i=0;i<delid.length;i++) {
	 			 	 	    StringTokenizer id = new StringTokenizer(delid[i],":");	 			 	 	    
	 			 	 	    //---==== If i_itmjob is missing , continue next data =====----//
	 			 	 	    if (id.countTokens()!=1) continue;	 			 	 	    	 			 	 		
	 			 	 	    itm = id.nextToken();	 			 	 	    
	 			 	 	    sql.delete(0,sql.length());
							sql.append("delete from lan:ipv_qcboq ")
								  .append(" where i_itmjob='").append(itm).append("' ");		
							System.out.println(i+",Delete :"+sql.toString());
							stmt.executeUpdate(sql.toString());									
	 			 	 } // end for
	 			 }
	 			}
			//----========================================----//			
			conn.commit();
			//conn.rollback();
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
