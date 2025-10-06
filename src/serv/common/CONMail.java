package serv.common;
import java.io.*;
import java.sql.*;
import java.util.*;

import com.lh.util.doString;
import com.lh.util.DateUtil;
public class CONMail {
	public static int MAX_INS_DISP = 12;
	public static String header = "<HTML><HEAD><META http-equiv=\"Content-Type\" content=\"text/html; charset=TIS-6"
			+ "20\"><META http-equiv=\"Content-Language\" content=\"th\"><TITLE></TITLE></HEAD>"
			+ "<BODY>";
	public static String footer = "</BODY></HTML>";
	
	public static String findEmail(Connection conn, String userNo) throws Exception {
		String email = "";
	    Statement stmt = null;
        ResultSet rs = null;
    	try {
            stmt = conn.createStatement();
            rs = stmt.executeQuery("SELECT user_email FROM docflow:useracl WHERE i_employ = '"+userNo+"'");
            if (rs != null) {
            	if (rs.next() == true) {
            		email = doString.checkString(rs.getString(1));
            	}
            	rs.close();
            	rs=null;
            }
            stmt.close();
            stmt = null;
    	} catch (Exception e) {
    		throw e;
    	} finally {
                if(rs != null)
                {
                    try
                    {
                        rs.close();
                    }
                    catch(SQLException _ex) { }
                }
                if(stmt != null)
                {
                    try
                    {
                        stmt.close();
                    }
                    catch(SQLException _ex) { }
                }
    	}
    	return email;
		
	}
	public static String genConApproveMail(String comId, String projId, String site, String docNo) throws Exception {
		String mailtext="";
		mailtext = header+"เอกสารสัญญางานบริการโครงการ : "+comId+projId+" "+site+" เลขที่ : " + docNo + " ผ่านการอนุมัติ"+footer;
		return mailtext;
	}		
	
	public static String genConDenyMail(String comId, String projId, String site, String docNo) throws Exception {
		String mailtext="";
		mailtext = header+"เอกสารสัญญางานบริการโครงการ : "+comId+projId+" "+site+" เลขที่ : " + docNo + " ไม่ผ่านการอนุมัติ"+footer;
		return mailtext;
	}	
	public static String genConApprMail(Connection conn, String comId, String projId, String docNo, String apprId) throws Exception {
		String appr_body = "";
		String deny_body = "";
		String back_body = "";
		String company = "LH";
		String userNo = "";
		String username = "";
		String position = "";
		String project = "";
		String contractNo = "";
		String conDate = "";
		String begDate = "";
		String endDate = "";
		String vendor = "";
		String venName = "";
		String jobId = "";
		String jobDesc = "";

		int num_ins = 0;
		double amount = 0;
		String comment = "";
		doString str = new doString();
    	String content = "";
        Statement stmt = null;
        ResultSet rs = null;
    	try {
            stmt = conn.createStatement();
            
    		appr_body = doString.encode(comId+projId+docNo+"_A_"+apprId);
    		appr_body = "[APR]"+appr_body+"[/APR]%0Aเอกสารสัญญางานบริการเลขที่+"+comId+projId+docNo+"+อนุมัติ";
    		
    		deny_body = doString.encode(comId+projId+docNo+"_D_"+apprId);
    		deny_body = "[APR]"+deny_body+"[/APR]%0Aเอกสารสัญญางานบริการเลขที่+"+comId+projId+docNo+"+ไม่อนุมัติ+ระบุหมายเหตุ%0A[COMMENT]%0A%0A[/COMMENT]";
    		
    		back_body = doString.encode(comId+projId+docNo+"_B_"+apprId);
    		back_body = "[APR]"+back_body+"[/APR]%0Aเอกสารสัญญางานบริการเลขที่+"+comId+projId+docNo+"+กลับไปแก้ไขใหม่+ระบุหมายเหตุ%0A[COMMENT]%0A%0A[/COMMENT]";

			//SERV_CONHD
			rs = stmt.executeQuery("SELECT i_employ, contract_no, d_keyin, i_vendor, i_job, d_begin, d_end, s_due, z_amount, c_comment FROM lan:serv_conhd WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+docNo+"'");
			if (rs != null) {
				if (rs.next() == true) {
					userNo = doString.checkString(rs.getString(1));
					contractNo = doString.MS874ToUnicode((doString.checkString(rs.getString(2))));
					conDate = DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString(3)));
					vendor = doString.checkString(rs.getString(4));
					jobId = doString.checkString(rs.getString(5));
					begDate = DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString(6)));
					endDate = DateUtil.ifxToThaiDateNoTime(doString.checkString(rs.getString(7)));
					num_ins = rs.getInt(8);
					amount = rs.getDouble(9);
					comment = doString.MS874ToUnicode(doString.checkString(rs.getString(10)));
					if (!comment.equals("")) {
						comment = str.replace(comment,"|break|","<BR>");
					}
				}
				rs.close();
				rs=null;
			}
			rs = stmt.executeQuery("SELECT n_itmjob FROM lan:serv_infboq WHERE i_itmjob = '"+jobId+"'");
			if (rs != null) {
				if (rs.next() == true) {
					jobDesc = doString.MS874ToUnicode((doString.checkString(rs.getString(1))));
				}
				rs.close();
				rs=null;
			}
			rs = stmt.executeQuery("SELECT n_prename_th, n_nemploy_th, n_semploy_th FROM docflow:acemploy WHERE i_employ = '"+userNo+"'");
			if (rs != null) {
				if (rs.next() == true) {
					username = doString.MS874ToUnicode(doString.checkString(rs.getString(1))) + " " +
								doString.MS874ToUnicode(doString.checkString(rs.getString(2))) + " " +
									doString.MS874ToUnicode(doString.checkString(rs.getString(3)));
				}
				rs.close();
				rs=null;
			}
			rs = stmt.executeQuery("SELECT j.d_job, j.i_job, p.n_desc FROM docflow:acempjob j, docflow:acempstd p WHERE j.i_employ = '" + userNo + "' AND p.i_type = '10' AND j.i_job = p.i_code ORDER BY j.d_job DESC");
			if(rs != null) {
				if (rs.next() == true) {
					position = doString.MS874ToUnicode(doString.checkString(rs.getString(3)));
				}
			}			
			
			rs = stmt.executeQuery("SELECT n_project FROM lan:acxprojt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"'");
			if (rs != null) {
				if (rs.next() == true) {
					project = doString.MS874ToUnicode(rs.getString(1));	
				}
				rs.close();
				rs=null;
			}
			
			rs = stmt.executeQuery("SELECT bus_name FROM lan:stpvendr WHERE vend_code = '"+vendor+"'");
			if (rs != null) {
				if (rs.next() == true) {
					venName = doString.MS874ToUnicode(doString.checkString(rs.getString(1)));
				}
				rs.close();
				rs=null;
			}			
            
    	    content = "<HTML> \n";
    		content += "<HEAD> \n";
    		content += "<TITLE>เอกสารสัญญางานบริการ</TITLE> \n";
    		content += "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=TIS-620\"> \n";
    		content += "<style type=\"text/css\"> \n";
    		content += "A:link			{ color: \"9933FF\" ; TEXT-DECORATION: none ; 						 } \n";
    		content += "A:visited		{ color: \"9933FF\" ; TEXT-DECORATION: none ; 						 } \n";
    		content += "A:hover		{ color: \"FF66FF\" ; TEXT-DECORATION: overline underline ;  } \n";
    		content += "P					{ 	font-size:10.0pt ; font-family : Microsoft Sans Serif ; color : rgb(0,0,0) ; 		} \n";
    		content += "TD				{ 	font-size:8.0pt ; font-family : Microsoft Sans Serif ; color : rgb(0,0,0) ; 		} \n";
    		content += "HR				{ 	color : rgb(0,0,0) ; height: 1px ; } \n";
    		content += "</style> \n";
    		content += "<base target=\"_self\"> \n";
    		content += "</HEAD> \n";
    		content += "<BODY leftMargin=15 topMargin=15 marginheight=\"15\" marginwidth=\"15\"  \n";
    		content += "style=\"scrollbar-face-color					:		rgb(220,240,255)		;  \n";
    		content += "			  			scrollbar-shadow-color			: 		rgb(220,240,255)		;  \n";
    		content += "			  			scrollbar-highlight-color			:		rgb(220,240,255)		;  \n";
    		content += "			  			scrollbar-3dlight-color 			: 		rgb(255,255,255)		;  \n";
    		content += "			  			scrollbar-darkshadow-color	: 		rgb(120,180,255)		;  \n";
    		content += "			  			scrollbar-track-color 				: 		rgb(255,255,255)		;  \n";
    		content += "			  			scrollbar-arrow-color 				: 		rgb(120,180,255)\"> \n";
    		content += "<table border=\"0\" width=\"500px\" cellspacing=\"0\" cellpadding=\"0\"> \n";
    		content += "        <tr> \n";
    		content += "        <td> \n";
    		content += "      <table border=\"0\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\"> \n";
    		content += "        <tr> \n";
    		content += "          <td width=\"100%\" style=\"font-size: 12.0pt ; font-family: Microsoft Sans Serif ; color: rgb(0,80,220) ; TEXT-DECORATION: none ; letter-spacing:1px ; padding-left:15px\">เอกสารสัญญางานบริการ</td> \n";
    		content += "        </tr> \n";
    		content += "      </table> \n";
    		content += "<table width=\"100%\" height=\"1\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"> \n";
    		content += "  <tr> \n";
    		content += "    <td style=\"font-size:1pt\">&nbsp;</td> \n";
    		content += "  </tr> \n";
    		content += "</table> \n";
    		content += "<!-- Block01--> \n";
    		content += "<table border=\"0\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\"> \n";
    		content += "  <tr> \n";
    		content += "    <td width=\"100%\" style=\"border-top:1px solid rgb(135,185,247) ; border-bottom:1px solid rgb(135,185,247) ; border-left:1px solid rgb(135,185,247) ; border-right:1px solid rgb(135,185,247) ; padding:0px 10px 0px 10px ; background-color:rgb(230,240,255)\" align=\"left\"> \n";
    		content += "  <table border=\"0\" width=\"100%\" cellspacing=\"0\" cellpadding=\"3\"> \n";
    		content += "  <tr> \n";
    		content += "    <td width=\"100%\" height=\"22\" style=\"color:rgb(0,0,120) ; font-weight:bold ; font-size:10pt ; border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px\">รายละเอียดสัญญา</td> \n";
    		content += "    </tr> \n";
    		content += "  <tr> \n";
    		content += "    <td width=\"100%\" height=\"22\" style=\"color:rgb(0,0,0) ; font-weight:normal ; color:rgb(0,100,255) ; border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px\">เลขที่เอกสาร :<span style=\"font-weight:normal ; color:rgb(0,0,0)\"> "+docNo+"</span></td> \n";
    		content += "  </tr> \n";    		
    		content += "  <tr> \n";
    		content += "    <td width=\"100%\" height=\"22\" style=\"color:rgb(0,0,0) ; font-weight:normal ; color:rgb(0,100,255) ; border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px\">ผู้บันทึกสัญญา :<span style=\"font-weight:normal ; color:rgb(0,0,0)\"> "+username+"</span></td> \n";
    		content += "  </tr> \n";
    		content += "  <tr>   \n";
    		content += "    <td width=\"100%\" height=\"22\" style=\"color:rgb(0,0,0) ; font-weight:normal ; color:rgb(0,100,255) ; border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px\">ตำแหน่ง : <span style=\"font-weight:normal ; color:rgb(0,0,0)\">"+position+"</span></td> \n";
    		content += "  </tr> \n";
    		content += "      <tr> \n";
    		content += "    <td width=\"100%\" height=\"22\" style=\"color:rgb(0,0,0) ; font-weight:normal ; color:rgb(0,100,255) ; border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px\">โครงการ :<span style=\"font-weight:normal ; color:rgb(0,0,0)\"> "+project+"</span></td> \n";
    		content += "  </tr> \n";
    		content += "  <tr> \n";
    		content += "    <td width=\"100%\" height=\"22\" style=\"color:rgb(0,0,0) ; font-weight:normal ; color:rgb(0,100,255) ; border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px\">คู่สัญญา :<span style=\"font-weight:normal ; color:rgb(0,0,0)\"> "+venName+"</span></td> \n";
    		content += "  </tr> \n";
    		content += "  <tr> \n";
    		content += "    <td width=\"100%\" height=\"22\" style=\"color:rgb(0,0,0) ; font-weight:normal ; color:rgb(0,100,255) ; border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px\">เลขที่สัญญา :<span style=\"font-weight:normal ; color:rgb(0,0,0)\"> "+contractNo+"</span></td> \n";
    		content += "  </tr> \n";
    		content += "  <tr> \n";
    		content += "    <td width=\"100%\" height=\"22\" style=\"color:rgb(0,0,0) ; font-weight:normal ; color:rgb(0,100,255) ; border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px\">วันที่สัญญา :<span style=\"font-weight:normal ; color:rgb(0,0,0)\"> "+conDate+"</span></td> \n";
    		content += "  </tr> \n";
    		content += "  <tr> \n";
    		content += "    <td width=\"100%\" height=\"22\" style=\"color:rgb(0,0,0) ; font-weight:normal ; color:rgb(0,100,255) ; border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px\">วันที่เริ่มต้น :<span style=\"font-weight:normal ; color:rgb(0,0,0)\"> "+begDate+"</span></td> \n";
    		content += "  </tr>   \n";
    		content += "    <tr> \n";
    		content += "    <td width=\"100%\" height=\"22\" style=\"color:rgb(0,0,0) ; font-weight:normal ; color:rgb(0,100,255) ; border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px\">วันที่สิ้นสุด :<span style=\"font-weight:normal ; color:rgb(0,0,0)\"> "+endDate+"</span></td> \n";
    		content += "  </tr>   \n";    		
    		content += "  <tr> \n";
    		content += "    <td width=\"100%\" height=\"22\" style=\"color:rgb(0,0,0) ; font-weight:normal ; color:rgb(0,100,255) ; border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px\">งาน :<span style=\"font-weight:normal ; color:rgb(0,0,0)\"> "+jobDesc+"</span></td> \n";
    		content += "  </tr>   \n";
    		content += "  <tr> \n";
    		content += "    <td width=\"100%\" height=\"22\" style=\"color:rgb(0,0,0) ; font-weight:normal ; color:rgb(0,100,255) ; border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px\">หมายเหตุ :<span style=\"font-weight:normal ; color:rgb(0,0,0)\"> "+comment+"</span></td> \n";
    		content += "  </tr>   \n";    		
    		content += "  <tr> \n";
    		content += "    <td width=\"100%\" height=\"22\" style=\"color:rgb(0,0,120) ; font-weight:bold ; font-size:10pt ; border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px\">รายละเอียดงวดงาน</td> \n";
    		content += "    </tr> \n";
    		content += "</table>   \n";
    		//SERV_CONDT
    		if (num_ins <= MAX_INS_DISP) {
    			rs = stmt.executeQuery("SELECT s_due, n_job, d_pay, z_amount FROM lan:serv_condt WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+docNo+"' ORDER BY s_due");    			
                if (rs != null) {
                	while (rs.next() == true) {
        				content += "  <table border=\"0\" width=\"100%\" cellspacing=\"0\" cellpadding=\"3\"> \n";
        				content += "  <tr> \n";
        				content += "    <td width=\"100%\" height=\"22\" style=\"color:rgb(0,0,120) ; font-weight:bold ; font-size:10pt ; border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px\">งวดที่ : "+Integer.toString(rs.getInt(1))+"</td> \n";
        				content += "    </tr> \n";
        				content += "      <tr> \n";
        				content += "    <td width=\"100%\" height=\"22\" style=\"color:rgb(0,0,0) ; font-weight:normal ; color:rgb(0,100,255) ; border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px\">รายละเอียดงาน :<span style=\"font-weight:normal ; color:rgb(0,0,0)\"> "+doString.MS874ToUnicode((doString.checkString(rs.getString(2))))+"</span></td> \n";
        				content += "  </tr> \n";
        				content += "  <tr>   \n";
        				content += "    <td width=\"100%\" height=\"22\" style=\"color:rgb(0,0,0) ; font-weight:normal ; color:rgb(0,100,255) ; border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px\">จำนวนเงิน : <span style=\"font-weight:normal ; color:rgb(0,0,0)\"> "+doString.displayNumber("###,###,###.00",rs.getDouble(4))+"</span> บาท</td> \n";
        				content += "  </tr> \n";
        				content += "</table>   \n";	    			
                	}// end while
                	rs.close();
                	rs=null;
                }
    		}
			content += "<table border=\"0\" width=\"100%\" cellspacing=\"0\" cellpadding=\"3\">   \n";
			content += "  <tr> \n";
			content += "    <td width=\"100%\" height=\"22\" style=\"font-weight:bold ; color:rgb(255,0,0) ; background-color:rgb(255,230,200) ; border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px 3px 3px 3px\"> ";
			content += " รวม "+num_ins+" งวด  เป็นจำนวนเงิน :<span style=\"font-weight:normal ; color:rgb(255,0,0)\"> "+doString.displayNumber("###,###,###.00",amount)+" บาท</span></td> \n";
			content += "  </tr>         \n";
			content += "</table> \n";
    		content += "</td> \n";
    		content += "  </tr> \n";
    		content += "</table> \n";
    		content += "<!-- End of Block01--> \n";

    		content += "<table width=\"100%\" height=\"1\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"> \n";
    		content += "  <tr> \n";
    		content += "    <td style=\"font-size:1pt\">&nbsp;</td> \n";
    		content += "  </tr> \n";
    		content += "</table> \n";
    		
    		
    				
    			content += "<!-- Block02--> \n";
    			content += "<table border=\"0\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\"> \n";
    			content += "  <tr> \n";
    			content += "    <td width=\"100%\" style=\"border-top:1px solid rgb(135,185,247) ; border-bottom:1px solid rgb(135,185,247) ; border-left:1px solid rgb(135,185,247) ; border-right:1px solid rgb(135,185,247) ; padding:0px 10px 0px 10px ; background-color:rgb(230,240,255)\" align=\"left\"> \n";
    			content += "          <table border=\"0\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\"> \n";
    			content += " \n";
    			content += "  <tr> \n";
    			content += "    <td width=\"100%\" height=\"22\" style=\"color: rgb(0,100,255) ; border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px\">กรุณา Reply E-Mail For :</td> \n";
    			content += "    </tr> \n";
    			content += "</table> \n";
    			content += "<br style=\"font-size:5pt\"> \n";
    			content += "<table border=\"0\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" height=\"30\"> \n";
    			content += "          <tr> \n";
    			content += "            <td width=\"100%\" style=\"color: rgb(0,0,0) ; border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px ; font-size:12pt\"> \n";
    			content += "			<a href=\"mailto:application@lh.co.th?subject=CONSERV_"+company+"_"+comId+projId+docNo+"_A&body="+appr_body+"\">Approve</a></td> \n";
    			content += "        </tr> \n";
    			content += "          <tr> \n";
    			content += "            <td width=\"100%\" style=\"color: rgb(0,0,0) ; border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px ; font-size:12pt\"> \n";
    			content += "			<a href=\"mailto:application@lh.co.th?subject=CONSERV_"+company+"_"+comId+projId+docNo+"_D&body="+deny_body+"\">Deny</a></td> \n";
    			content += "          </tr> \n";
/*    			
    			content += "          <tr> \n";
    			content += "            <td width=\"100%\" style=\"color: rgb(0,0,0) ; border-bottom:1px solid #FFFFFF ; border-top:0px solid #FFFFFF ; border-left:0px solid #FFFFFF ; border-right:0px solid #FFFFFF ; padding:3px ; font-size:12pt\"> \n";
    			content += "			<a href=\"mailto:application@lh.co.th?subject=CONSERV_"+company+"_"+comId+projId+docNo+"_B&body="+back_body+"\">RouteBack</a></td> \n";
    			content += "          </tr>   \n";
*/    			
    			content += "</table>   \n";
    			content += "<table width=\"100%\" height=\"1\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"> \n";
    			content += "  <tr> \n";
    			content += "    <td style=\"font-size:1pt\">&nbsp;</td> \n";
    			content += "  </tr> \n";
    			content += "</table> \n";
    			content += "</td> \n";
    			content += "  </tr> \n";
    			content += "</table> \n";
    			content += "<!-- End of Block02--> \n";
    			content += "<table width=\"100%\" height=\"1\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"> \n";
    			content += "  <tr> \n";
    			content += "    <td style=\"font-size:1pt\">&nbsp;</td> \n";
    			content += "  </tr> \n";
    			content += "</table> \n";
    		content += "<br style=\"font-size:5pt\"> \n";
    		content += "          </td> \n";
    		content += "        </tr> \n";
    		content += "      </table> \n";
    		content += "</BODY> \n";
    		content += "</HTML> \n";		
    			  
            stmt.close();
            stmt = null;
    	} catch (Exception e) {
    		System.out.println("CONMail.genConApprMail : "+e.getMessage());    		
    		throw e;
    	} finally {
                if(rs != null)
                {
                    try
                    {
                        rs.close();
                    }
                    catch(SQLException _ex) { }
                }
                if(stmt != null)
                {
                    try
                    {
                        stmt.close();
                    }
                    catch(SQLException _ex) { }
                }
    	}
    	return content;
	}

}
