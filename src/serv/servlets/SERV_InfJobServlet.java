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
import serv.common.SERV_CommonData;
import serv.common.Constants;

/**
 * @version 	1.0
 * @author
 * 
 * ----------------------------
 * Modify by :pradoem
 * date: 2014.11.03
 * desc : Add field d_appoint_cust  for Key in manual  inform job
 * ----------
 * Last update 2015.06.25 by pradoem
 * 1. support Inform Job Type warranty description add c_desc 
 */

public class SERV_InfJobServlet extends DBServlet  {
	
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
		//printParamRQ(req);
 
 		User user = (User) obj;
		doString str = new doString();		 		
		res.setContentType("text/html; charset=TIS620");
		PrintWriter out = res.getWriter();
		
		//Modify by pradoem : 2014.11.03
		String dAppoint = doString.checkString(req.getParameter("dAppoint"),""); //03/11/2557
		String fromTime = doString.checkString(req.getParameter("fromTime"),"00:00"); 
		String iWarrantyDDL = doString.checkString(req.getParameter("InformTypeDDL"),""); //01,99  and i_type = 98

		String who = doString.checkString(req.getParameter("who"),"");
		String mode = doString.checkString(req.getParameter("mode"),"add");
		String selProj = doString.checkString(req.getParameter("sel_project"),"");
		String houseId = doString.UnicodeToMS874(doString.checkString(req.getParameter("house_id"),""));
		String iLock = doString.checkString(req.getParameter("i_lock"),"").toUpperCase();
		String nCustomer = doString.UnicodeToMS874(doString.checkString(req.getParameter("n_customer"),""));
		String nCustTel = doString.UnicodeToMS874(doString.checkString(req.getParameter("n_cust_tel"),""));
		String cDesc = doString.UnicodeToMS874(doString.checkString(req.getParameter("c_desc"),""));
		
		String hh = "";
		String mm = "";
		if(!"".equals(fromTime)){
			String temp[] = fromTime.split("\\:");
			hh = temp[0];
			mm = temp[1];			
		}
		
		cDesc = str.replace(cDesc,"\r","");
		cDesc = str.replace(cDesc,"\n","|break|");
		
					
		String savePage = Constants.SAVE_PAGE;
		String successPage = "SERV_Home.jsp";
		String errorPage = "";
		
		//TODO: CASE Cancel 
		//iCanTypeDDL
		//iCanDesc
		String iCanTypeDDL = doString.checkString(req.getParameter("iCanTypeDDL"),"");	
		String iCanDesc = doString.UnicodeToMS874(doString.checkString(req.getParameter("iCanDesc"),""));
		//System.out.println("who in class ="+who);
		
		if (who.equals("J")) {
			errorPage = "/LHServ/SERV_InfJobCondo.jsp?error=1&mode="+mode+"&search_cust=yes&sel_project="+selProj+"&house_id="+houseId;    
		} else {
			errorPage = "/LHServ/SERV_InfJob.jsp?error=1&mode="+mode+"&search_cust=yes&sel_project="+selProj+"&house_id="+houseId; 
		}
		
		errorPage += "&i_lock="+iLock+"&n_customer="+nCustomer+"&n_cust_tel="+nCustTel+"&c_desc="+cDesc;
		
		String otherMsg = "";
		String errorCode = "";
		String iDocNo = "";
		String iTypeCut = "";
		String iWarrantyDesc = "";
    
		StringBuffer sql = new StringBuffer();
		PreparedStatement pstmt = null;
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
			//------------------------------
			if(!"99".equals(iWarrantyDDL)){
				iWarrantyDesc = this.getInformJobDesc(conn, iWarrantyDDL);
				if(!"".equals(iWarrantyDesc)){
					iWarrantyDesc = "("+iWarrantyDesc+")";
				}
			}
			
			//----------------------------
			
						
			//----======== Add Mode , Insert Query =========----//
			if (mode.equalsIgnoreCase("ADD")) {
													
				//---==================== generate i_docno ========================---//
				StringTokenizer id = new StringTokenizer(selProj,":"); 
				String comId = id.nextToken();
				String projId = id.nextToken();
				Calendar now = Calendar.getInstance();
				
				int year = (now).get(Calendar.YEAR);
				if (year<2400) year += 543;
				String twoDigitYear = Integer.toString(year).substring(2);
				String prefixDocNo = comId+"-"+projId+"-"+twoDigitYear;
				 				 
				sql.append(" select * from lan:serv_dochd where ")
				      .append(" i_company='").append(comId).append("' ")
				      .append(" and i_project='").append(projId).append("' ")
				      .append(" and i_docno like '").append(prefixDocNo).append("%' ")
				      .append(" order by i_docno desc ");
				rs = stmt.executeQuery(sql.toString());								
				if (rs.next()) {
					//----========== DocNo Found , increase ID =========----// 
					String oldDocNo = doString.checkString(rs.getString("i_docno"),"");
					int lastId = Integer.parseInt(oldDocNo.substring(oldDocNo.length()-5));
					if (lastId<0) { 
						lastId = 1;
					} else {
						lastId++; 
					}
					iDocNo = prefixDocNo+str.createID(lastId,5);
				} else {
					//----======== No DocNo found , start 1 ========----// 
				   	iDocNo = prefixDocNo+str.createID(1,5);
				}
				rs.close();
				//-----========================================================------//
		
				//------===================== Get Cut Type =======================-----//
				String nowDate = Integer.toString(year>2400 ? year-543 : year);	
				nowDate += "-"+str.createID(now.get(Calendar.MONTH)+1,2);
				nowDate += "-"+str.createID(now.get(Calendar.DATE),2);			
				
				sql.delete(0,sql.length());
				sql.append(" select * from lan:serv_cutlck	where ")
				      .append(" i_company='").append(comId).append("' ")
				      .append(" and i_project='").append(projId).append("' ")
				      .append(" and i_lock='").append(iLock).append("' ")
				      .append(" and d_effective<='").append(nowDate).append("' ")
				      .append(" order by d_effective desc ");
				rs = stmt.executeQuery(sql.toString());				
				if (rs.next()) {
					//----========== DocNo Found , increase ID =========----// 
					iTypeCut = doString.checkString(rs.getString("i_cut_type"),"");
				}
				rs.close();				
				//-----========================================================------//

				//------==================== Start Insert ==========================-----//
				nowDate += " "+str.createID(now.get(Calendar.HOUR_OF_DAY),2);
				nowDate += ":"+str.createID(now.get(Calendar.MINUTE),2);

				sql.delete(0,sql.length());
				sql.append(" insert into lan:serv_dochd (i_docno , i_doc_type , i_company , ")
					  .append(" i_project , i_lock , d_keyin , n_customer , n_cus_tel , c_desc , ")
					  .append(" d_job , f_status , d_appoint , d_est_close , d_close , ")
					  .append(" i_service_employ , i_type_cutlck , d_print_inform , ")
					  .append(" i_employ_pinform , d_print_job , i_employ_pjob , f_reject , ")
					  .append(" i_employ_reject , d_reject , c_reject , d_appoint_cust , i_warranty ")
					  .append(" ) values ( ")
					  .append(" ? , 'I' , ? , ? , ? , current , ? , ? , ? , ")
					  .append(" null , 'OPN' , null , null , null , ") // Job Status & Date Details
					  .append(" ? , ? , ")
					  .append(" null , null , ")  // Print InformJob Description
					  .append(" null , null , ") // Print Job Description
					  .append(" 'N' , null , null , null , ?  , ? ") // Reject Description
					  .append(" ) "); 					
					  
				//---====== User PrepareStatement instead becase cDesc is an more than 256 Chars ======-----//	  					  
			    pstmt = conn.prepareStatement(sql.toString());
			    pstmt.setString(1,iDocNo);
				pstmt.setString(2,comId);
				pstmt.setString(3,projId);
				pstmt.setString(4,iLock);
				pstmt.setString(5,nCustomer);
				pstmt.setString(6,nCustTel);
				pstmt.setString(7,cDesc+iWarrantyDesc); //update 2015.06.25
				pstmt.setString(8,user.getEmpId());
				pstmt.setString(9,iTypeCut);
				//Modify by pradoem 2014.11.03
				if(!"".equals(dAppoint)){
					//pstmt.setString(10,DATE_TIME); //Feild DateTime
					pstmt.setTimestamp(10,this.GetTimestamp(dAppoint,hh,mm));
				}else{
					pstmt.setString(10,null); //Feild DateTime
				}
				pstmt.setString(11,iWarrantyDDL);
				
				pstmt.executeUpdate();
				pstmt.close();
				//-----========================================================------//
						
				if (who.equals("J")) {			
					successPage = "SERV_InfJobCondo_Disp.jsp?i_docno="+iDocNo;	
				} else {
					successPage = "SERV_InfJob_Disp.jsp?i_docno="+iDocNo;	
				}					
				
				otherMsg = "เลขที่ใบแจ้งซ่อมคือ "+iDocNo;
				session.setAttribute("sess_sel_proj",selProj);				
			}
			//----======================================----//

			//----======== Edit Mode , Update Query =========----//
			else if (mode.equalsIgnoreCase("EDIT")) {
				iDocNo =  doString.checkString(req.getParameter("i_docno"),"");
				
				if (who.equals("J")) {	
					successPage = "SERV_InfJobCondo_Disp.jsp?i_docno="+iDocNo;
					errorPage = "SERV_InfJobCondo_Disp.jsp?error=1&mode="+mode+"&i_docno="+iDocNo;
					
				} else {
					successPage = "SERV_InfJob_Disp.jsp?i_docno="+iDocNo;
					errorPage = "SERV_InfJob_Disp.jsp?error=1&mode="+mode+"&i_docno="+iDocNo;						
				}		
				sql.delete(0,sql.length());
				sql.append(" update lan:serv_dochd set ")
					  .append(" n_customer = ?, ")
					  .append(" n_cus_tel= ? ,  ")
					  .append(" c_desc = ?   ,  ")	
				      .append(" i_warranty = ?  ");		
					  //Modify by pradoem : 2014.11.03
						if(!"".equals(dAppoint) && !"".equals(fromTime)){
							sql.append(", d_appoint_cust ='").append(this.GetTimestamp(dAppoint,hh,mm).toString().substring(0, 16)).append("' ");
						}
						sql.append(" where i_docno= ? ");
				//System.out.println("SQL == > "+sql.toString());
				//---====== User PrepareStatement instead becase cDesc is an more than 256 Chars ======-----//	  					  
				pstmt = conn.prepareStatement(sql.toString());
				pstmt.setString(1,nCustomer);
				pstmt.setString(2,nCustTel);
				pstmt.setString(3,cDesc+iWarrantyDesc);
				pstmt.setString(4,iWarrantyDDL);
				pstmt.setString(5,iDocNo);
				
				pstmt.executeUpdate();				
				pstmt.close();
				//-----=========================================================================------//
			}
			//----======================================----//

			//----======== Cancel Mode , Update Query =========----//
			else if (mode.equalsIgnoreCase("CANCEL")) {
				iDocNo =  doString.checkString(req.getParameter("i_docno"),"");
				successPage = "SERV_Reprint_List.jsp";
				
				if (who.equals("J")) {	
					errorPage = "SERV_InfJobCondo_Disp.jsp?error=1&mode="+mode+"&i_docno="+iDocNo;
				} else {
					errorPage = "SERV_InfJob_Disp.jsp?error=1&mode="+mode+"&i_docno="+iDocNo;					
				}

				sql.delete(0,sql.length());
				sql.append(" update lan:serv_dochd set ")
				      .append(" f_status = 'CAN' , ")				
					  .append(" d_cancel = today , ")
					  .append(" i_employ_cancel = '").append(user.getEmpId()).append("', ")
					  .append(" i_can_type = '").append(iCanTypeDDL).append("' , ")
					   .append(" i_can_desc = '").append(iCanDesc).append("' ")
					  .append(" where i_docno='").append(iDocNo).append("' ");
				stmt.executeUpdate(sql.toString()); 	
			}
			//----======================================----//

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
			genRedirectCode(out,savePage,errorPage,"99","กรุณาจด Error นี้และติดต่อผู้ดูแลระบบ : "+e.getMessage());
			
		} finally {
			out.close();
			try {
				if (rs!=null) rs.close(); 
				if (stmt != null) stmt.close();
				if (pstmt != null) pstmt.close();
				if (conn != null) conn.close();
			} catch (SQLException ignore) {
			}
		}
		System.out.println(mName + "end.");

	}
	
	//input : 29/01/2557
	//output: 2014-01-29
	public static  String dateThai2UsYYYYMMDD(String str){
		 if ((str == null) || str.equals("")) {
			 return  str;
		 }else{
			 String temp[] = str.split("\\/"); // 29/01/2557			 
			 return (Integer.parseInt(temp[2])-543)+"-"+temp[1]+"-"+temp[0];
		 }
	}
	
	//input :29/01/2557
    //output:Long Time :2013-11-25 12:00	
	public static Timestamp GetTimestamp(String param,String hh,String mm){
    	Calendar cal = Calendar.getInstance(Locale.ENGLISH);
    	 if("".equals(param)||null==param){
    		 return new Timestamp(cal.getTimeInMillis());
    	 }
		 String temp[] = param.split("\\/"); // 29/01/2557			 
		 //return (Integer.parseInt(temp[2])-543)+"-"+temp[1]+"-"+temp[0];
    	 //YYYY-MM-DD HH:MM
    	 cal.set(Integer.parseInt(temp[2])-543,Integer.parseInt(temp[1])-1,Integer.parseInt(temp[0]),Integer.parseInt(hh),Integer.parseInt(mm));
    	 //cal.set(Integer.parseInt("2014"),Integer.parseInt("10")-1,Integer.parseInt("25"),0,0);
    	 return new Timestamp(cal.getTimeInMillis());
    }
	
	//doString.UnicodeToMS874(
	 public String getInformJobDesc(Connection conn,String iType){
	        StringBuffer sql = new StringBuffer();
	        Statement stmt = null;
	        ResultSet rs = null;
	        String desc = "";
	        try {
	            stmt = conn.createStatement();
	  			sql.delete(0, sql.length());
				sql.append(" Select n_desc  ")
					.append(" From lan:serv_xstd ")
					.append(" Where  i_type='98' AND i_code = '"+iType+"' ");	
					//System.out.println("SQL  :"+sql.toString());
					rs = stmt.executeQuery(sql.toString());    				   
				    if(rs.next()){
				       desc  = doString.checkString(rs.getString("n_desc"),"");
				    } 					  
	            rs.close();
	            stmt.close();
	        }catch(Exception e) {
	            System.out.println(" getInformJobDesc Error : " + e.getMessage());
	        } finally{
	            try  {
	                if(rs != null) {
	                    rs.close();
	                }
	                if(stmt != null){
	                    stmt.close();
	                }
	            }
	            catch(Exception ex) { }
	        }
	        return desc;
	    }
		
     //GET PARAMETER
	 private void printParamRQ(HttpServletRequest request){
			Enumeration <String> paramName = (Enumeration<String>) request.getParameterNames();
			while (paramName.hasMoreElements()) {
			       String element = (String) paramName.nextElement();
			       System.out.println(element + " = " + request.getParameter(element));
			}
	 }
}
