<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page errorPage="errorPage.jsp" %>

<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ include file="function.jsp" %>
<%@ include file="confirmLogin.jsp" %>

<%!
	//public static String[] collectMethod = new String[]{
	//	"รูปแบบการจัดเก็บไม่ถูกต้อง !!",				"กทม. จัดเก็บคราวละ 1 ปี",   				// 0,1
	//	"กทม. จัดเก็บคราวละ 1 ปี",					"ปริมณฑล จัดเก็บคราวละไม่เกิน 3 ปี (ขั้นต่ำ 1 ปี)", 	// 2,3
	//	"กทม. จัดเก็บคราวละไม่เกิน 3 ปี (ขั้นต่ำ 1 ปี)",		"ปริมณฑล จัดเก็บคราวละไม่เกิน 3 ปี (ขั้นต่ำ 1 ปี)" 	// 4,5
	//};	
	
	public static String[] collectMethod = new String[]{
		"รูปแบบการจัดเก็บไม่ถูกต้อง !!", "โครงการเก่า", "กทม.", "ปริมณฑล", "กทม. 3 ปี ไม่มีสโมสร", "ปริมณฑล  3 ปี และ กทม. 3 ปี"
	};			
	
	public String displayDate(String date) {
		String result = "";
		
		if (date.trim().length()>=10) {
			int y = Integer.parseInt(date.substring(0,4));
			if (y<2400) y += 543;
			result = date.substring(8,10)+"/"+date.substring(5,7)+"/"+y;
		} else {
			result = "-";
		}
		
		return result;
	}	
	
	public String calRemainMonth(int nowYear,int nowMonth,String dEndProj) {
		String result = "";
		
		if (dEndProj.length()>=10) {
			try {
				int endYear = Integer.parseInt(dEndProj.substring(0,4));
				if (endYear>2400) endYear -= 543;
				int endMonth = Integer.parseInt(dEndProj.substring(5,7));
				
				if (endYear>=nowYear) {
					if (nowYear==endYear && nowMonth>=endMonth) {
						result = "<span style='color:red'>- สิ้นสุดเฟสแล้ว -</span>";
					} else {
						int month = ((endYear-nowYear)*12)+(endMonth-nowMonth);
						if (month<12) {
							result = "<span style='color:red'>"+month+"</span>";
						} else {
							result = doString.displayNumber("#,##0",month);
						}
					}
				} else {
					result = "<span style='color:red'>- สิ้นสุดเฟสแล้ว -</span>";
				}
				
			} catch (Exception ex) {}			
		}
		
		return result;
	}	
	
	public String genProjectListboxByUserId(Connection conn,String userId,String name,String value,String params,boolean getAllProj) {
		 StringBuffer html = new StringBuffer();
		 StringBuffer sql = new StringBuffer();
		 Statement stmt = null;
		 ResultSet rs = null;
		 boolean allProject = false;
		 SERV_CommonData common = new SERV_CommonData(conn);

		 try {
			stmt = conn.createStatement();
			//---============= Check user is vendor or employee ===============----//
			String userWho = "";
			String iPerson = "";	

			sql.delete(0,sql.length());
			//remark by pradoem 2012.04.24: sql.append(" select * from lan:useracl where user_id='").append(userId).append("' and user_acl='S' ");
			sql.append(" select user_id,user_acl,user_who,i_person from lan:useracl where user_id='").append(userId).append("' and user_acl='S' ");
			rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
				userWho = doString.checkString(rs.getString("user_who"),""); 
				iPerson = doString.checkString(rs.getString("i_person"),""); 		
			}
			rs.close();			

			///----=============== Generate Query for Vendor and Employee ==================---//

			if (userWho.equalsIgnoreCase(Constants.PERMISSION_VENDOR)) {
				sql.delete(0,sql.length());
				sql.append(" select (a.i_company) as com_id, (a.i_project) as proj_id, b.n_project from lan:serv_venprj a ")
					  .append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project ")
					  .append(" where a.i_vendor='").append(iPerson).append("' ")
					  .append(" and a.i_type='01' order by a.i_company, a.i_project ");
			} else {
				 sql.delete(0,sql.length());
				 sql.append(" select a.com_id, a.proj_id, b.n_project  from lan:serv_pstaff a ")
					   .append(" left join lan:acxprojt b on b.i_company=a.com_id  and  b.i_project=a.proj_id ")
					   .append(" where a.user_id = '").append(userId).append("' ")
					   .append(" order by a.com_id,a.proj_id ");

			}
			 rs = stmt.executeQuery(sql.toString());
			 //-------============== Generate List box ===================------//
			 html.append("<select name='").append(name).append("' ").append(params).append(" >");
			 html.append("<option value=''>"+Constants.LISTBOX_SELECT_LABEL+"</option>");

			 while (rs.next()) {
				String comId = doString.checkString(rs.getString("com_id"),"");
				String projId = doString.checkString(rs.getString("proj_id"),"");
				String projName = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
				String val = comId+":"+projId;
				String selected = "";
				if (value!=null && val.equalsIgnoreCase(value)) {
				   selected = " selected "; 
				}

				if (projId.equalsIgnoreCase("ALL")) {
				   //---====== If ALL Permission , set flag and exit loop =======----//
				   allProject = true;
				   break;
				 } else {
				   //---====== Normal Case , generate project by permission =======---//
				   html.append("<option value='").append(val).append("' ").append(selected).append(">")
						   .append(comId).append("-").append(projId).append(" - ").append(projName)
						   .append("</option>");				                   
				 }		        
			 } // end while		 
			 //html.append("<option value='ALL_PROJ' "+(value.equalsIgnoreCase("ALL") ? "selected" : "")+">"+Constants.LISTBOX_ALLPROJECT_LABEL+"</option>");
			 String selected = "";
			 //System.out.println(" value :"+value);
			 if(value.equals("ALL")){
			    selected = " selected";
			 }

			//System.out.println(" selected :"+selected);
			 html.append("<option value='ALL' "+selected+">"+Constants.LISTBOX_ALLPROJECT_LABEL+"</option>");
			 html.append("</select>");
			 //----=====================================================----//
			 rs.close();
			 stmt.close();
			 if (allProject) {
				 //----====== AllProject is true , gen All Project Listbox ========----//
				 html.delete(0,html.length());
				 html.append(common.genAllProjectListbox(name,value,params,getAllProj));
			 }		     
		 } catch (Exception e) {
			 System.out.println(" genProjectListboxByUserId Error : "+e.getMessage());
		 } finally {
			 try {
				if (rs!=null) rs.close();
				if (stmt!=null) stmt.close();
			 } catch (Exception ex) {}
		 }
		 return html.toString();
	}	
		
	private Vector getFileList(Connection conn,Vector fileList,String iCompany,String iProject,int mainNo) throws Exception {
		StringBuffer sql = new StringBuffer();
		Statement stmt = null;
		Statement stmt1 = null;		
		ResultSet rs = null;
		ResultSet rs1 = null;
		
		try {
			stmt = conn.createStatement();
			stmt1 = conn.createStatement();
		
	   		//---- find i_code for start node ----//
	   		if (mainNo<=0) {
				sql.delete(0, sql.length());
				sql.append(" select nvl(i_code,0) as i_code from lan:admstdhd ")
	 			   .append(" where i_doc_type='01' and i_main=0 and i_seq=2 ")
	 			   .append(" and i_company='"+iCompany+"' and i_project='"+iProject+"' ");
				rs = stmt.executeQuery(sql.toString());
				if (rs.next()) {
					mainNo = rs.getInt("i_code");
				} else {
					mainNo = 0;
				}
				rs.close();
			}
		
			//---- check header ----//
			boolean found = false;
			sql.delete(0, sql.length());
			sql.append(" select i_code from lan:admstdhd where i_doc_type='01' ")
			   .append(" and i_company='"+iCompany+"' and i_project='"+iProject+"' ")
			   .append(" and i_main='"+mainNo+"' ");
			rs = stmt.executeQuery(sql.toString());
			if (rs.next()) {
				found = true;
			}
			rs.close();
					   
			//---- found data ----//	   
			if (found) {
				int codeNo = 0;
				String desc = "";
				String fileType = "";
				String fileName = "";
				String attachUrl = "";	
				String iUpload = "";
				String dUpload = "";
				String fileLink = "";			
			
				sql.delete(0, sql.length());
				sql.append(" select i_code, n_desc, f_type from lan:admstdhd ")
				   .append(" where i_doc_type='01' ")
				   .append(" and i_company='"+iCompany+"' and i_project='"+iProject+"' ")
				   .append(" and i_main='"+mainNo+"' ")
				   .append(" order by n_desc ");
				rs = stmt.executeQuery(sql.toString());
				while (rs.next()) {
					codeNo = rs.getInt("i_code");
					desc = doString.DisplayThai(doString.checkString(rs.getString("n_desc"),""));
					fileType = doString.checkString(rs.getString("f_type"),"");
					
					if (fileType.equals("F")) {
						//--- get file link ---//
						sql.delete(0, sql.length());
						sql.append(" select n_desc, d_upload, i_file_upload, n_url, i_user ")
						   .append(" from lan:admstddt where i_doc_type='01' ")
						   .append(" and i_company='"+iCompany+"' and i_project='"+iProject+"' ")
						   .append(" and i_main='"+codeNo+"' ")
				   		   .append(" order by d_upload desc ");
						rs1 = stmt1.executeQuery(sql.toString());			   		   
						while (rs1.next()) {
							desc = doString.checkString(rs1.getString("n_desc"),"");
							fileName = doString.checkString(rs1.getString("i_file_upload"),"");
							attachUrl = doString.checkString(rs1.getString("n_url"),"");
							iUpload = doString.checkString(rs1.getString("i_user"),"");
							dUpload = doString.checkString(rs1.getString("d_upload"),"");
							fileLink = "";
							
							if (attachUrl.trim().length()<=0) {
								if (fileName.trim().length()>0) {
									attachUrl = "http://132.146.1.130/LHAllot/Menu/"+fileName;	
								}
							}
							if (attachUrl.trim().length()>0) {
								fileLink = "<a href=\""+attachUrl+"\" target=\"_blank\">"+desc+"</a>";
							}
							
							if (fileLink.trim().length()>0) {
								if (fileList==null) fileList = new Vector();								
								fileList.addElement(dUpload+"#"+fileLink+"#"+iUpload);
							}
							
						} // end while
						rs1.close();
					} else if (fileType.equals("M")) { 
						//--- not used ---//
					} else { 
						//--- loop for get other file ---//
						fileList = getFileList(conn,fileList,iCompany,iProject,codeNo);
					}
					
				}// end while
				rs.close();
				
			} // end if check found

			stmt.close();
			stmt1.close();
			stmt=null;
			stmt1=null;

		} catch (Exception e) {
			System.out.println("getFileList Error : "+e.getMessage());
		} finally {
			if (stmt!=null) stmt.close();
			if (stmt1!=null) stmt1.close();
			stmt=null;
			stmt1=null;
		}
		
		return fileList;
	}	
%>

<%
	String selProj = doString.checkString(request.getParameter("sel_project"),"");
	String iCompany = selProj.length()>=6 ? selProj.substring(0,2) : "";
	String iProject = selProj.length()>=6 ? selProj.substring(3,6) : "";	
	String error = doString.checkString(request.getParameter("error"),"");	
	String errMsg = doString.checkString(request.getParameter("other_msg"),"");		

	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt1 = null;
	ResultSet rs = null;
	ResultSet rs1 = null;
	
	
	//--- get today for calculate ---//
	Calendar now = Calendar.getInstance(TimeZone.getTimeZone("Asia/Bangkok"));
	int nowYear = now.get(Calendar.YEAR);
	if (nowYear>2400) nowYear -= 543;
	int nowMonth = now.get(Calendar.MONTH)+1;
		   
	try {
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();       
		stmt1 = conn.createStatement();       
        //----=======================================----//    
        		
%>

<HTML>
<HEAD>
<TITLE>ตั้งข้อมูลพื้นฐาน เฟสโครงการ (C0)</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="MainStyle.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript" type="text/javascript" src="chromeless_35.js"></script>
<script language="javascript" type="text/javascript" src="window_style.js"></script>
<script language="javascript" type="text/javascript" src="Hscroll.js"></script>

<base target="_self">

<SCRIPT LANGUAGE="JavaScript">

  function searchData() {
  	 if (document.forms[0].sel_project.value=="") {
  		 alert(" กรุณาระบุโครงการ !!");
  	 	 return false;
  	 }
  
	 document.forms[0].action="SERV_PhaseProjList.jsp";
	 document.forms[0].submit();
  } 
  
  function addData() {
  	 if (document.forms[0].sel_project.value=="") {
  		 alert(" กรุณาระบุโครงการ !!");
  		 return false;
  	 }
  	 
  	 document.forms[0].action="SERV_PhaseProjAdd.jsp";
	 document.forms[0].submit();
  }   

  function delData(delPhase) {
  	 if (document.forms[0].sel_project.value=="") {
  		 alert(" กรุณาระบุโครงการ !!");
  		 return false;
  	 }
  	 
  	 if (confirm("หากทำการลบเฟส ระบบจะทำการลบข้อมูลค่าสาธารณูปโภคที่เคยตั้งไว้ของเฟสนี้ทั้งหมดด้วย, คุณแน่ใจว่าต้องการลบเฟส ?")) {
  	 	 document.forms[0].act.value = "DEL";
  	 	 document.forms[0].del_phase.value = delPhase;
	  	 document.forms[0].action="/LHServ/SERV_SavePhaseProjServlet";
		 document.forms[0].submit();
  	 }
  }
  

</SCRIPT>


</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">

<input type="hidden" name="act" value="">
<input type="hidden" name="del_phase" value="">

<TABLE border="0" width="100%" cellpadding="0" cellspacing="0">
<TBODY>
<TR>
<TD valign="top" width="800">

<table border="0" width="780" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center" class="BD">
    
	 <br style="font-size:8pt">
	 
      <table border="0" width="750" cellspacing="0" cellpadding="0">
        <tr>
          <td width="70%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
           ตั้งข้อมูลพื้นฐาน เฟสโครงการ (C0)</td>
          <td width="30%" align="right">
          </td>
        </tr>
      </table>


<br style="font-size:10pt">

	<table border="0" width="750" cellspacing="0" cellpadding="0">
		<tr>
			<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
			<td class="item_tab2" width="200">รายละเอียดเฟส</td>
			<td class="item_tab3"></td>
			<td class="item_tab4">&nbsp;</td>
			<td class="item_tab5" width="25">&nbsp;</td>
		</tr>
	</table>

<table border="0" width="750" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center">
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
		  <tr>
		    <td height="22" class="item ; dotline01" width="20%">โครงการ :</td>
		    <td height="22" width="80%" class="dotline01">
		    	<nobr>
				<%=genProjectListboxByUserId(conn,user.getUserID(),"sel_project",selProj," class='box' style='width:250px' ",true) %>        
			    &nbsp;&nbsp;
		        <img border="0" src="images/bu_go.gif" align="absmiddle" width="40" height="22" style="cursor:hand" onclick="searchData();">
		        </nobr>
			</td>
		  </tr> 
		  <!-- 
		  <tr class="gray">
		    <td height="22" class="item ; dotline01" width="20%"><nobr>อัตราค่าบริการสาธารณะ : &nbsp;</nobr></td>
		    <td height="22" width="80%" class="dotline01">
		    	<nobr>
				<%
					String iType = "";
					String dAllocate = "";
					double zInfRate = 0.0;
					boolean foundADMDefault = false;
					
					sql.delete(0,sql.length());
					sql.append(" select h.d_allocate, r.z_inf_rate, r.i_type ")
					   .append(" from lan:aciplckd d, lan:aciplckh h, lan:aciinfrate r ")
					   .append(" where d.i_company = '"+iCompany+"' and d.i_project = '"+iProject+"' ")
					   .append(" and (d.f_cancel!='C' or d.f_cancel is null) ")
					   .append(" and d.seq_no = h.seq_no and h.f_confirm='Y' ")
					   .append(" and h.d_allocate is not null and h.seq_no=r.seq_no ")
					   .append(" order by h.d_allocate desc ");
					rs = stmt.executeQuery(sql.toString());
					if (rs.next()) {
						iType = doString.checkString(rs.getString("i_type"),""); 
						dAllocate = doString.checkString(rs.getString("d_allocate"),""); 
						zInfRate = rs.getDouble("z_inf_rate");
						foundADMDefault = true;
					}
					rs.close();	
					
					%>
					<input type="hidden" name="i_type" id="i_type" value="<%=iType %>">
					<input type="hidden" name="z_inf_rate" id="z_inf_rate" value="<%=doString.displayNumber("######0.00",zInfRate) %>">					
					<%				
					
					if (!foundADMDefault) {
						%><span style='color:red'>ไม่พบข้อมูลอัตราค่าบริการสาธารณะ</span><%
					} else {
						if (iType.equalsIgnoreCase("V")) {
							iType = "บาท/ตรว.";
						} else if (iType.equalsIgnoreCase("L")) {
							iType = "บาท/หลัง";
						} else {
							iType = "บาท (รูปแบบการจัดเก็บไม่ถูกต้อง)";
						}
						
						out.println(doString.displayNumber("#,###,##0.00",zInfRate)+" <span id='price_type' style='color:red'>"+iType+"</span> (วันที่ใบอนุญาต : "+displayDate(dAllocate)+")");
					}
				%>
		        </nobr>
			</td>
		  </tr> 
		   -->		  
		</table>
</td>
  </tr>
</table>


<!---- attach block ---->
<br style="font-size:10pt">

	<table border="0" width="750" cellspacing="0" cellpadding="0">
		<tr>
			<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
			<td class="item_tab2" width="200">ใบอนุญาตจัดสรรที่ดิน</td>
			<td class="item_tab3"></td>
			<td class="item_tab4">&nbsp;</td>
			<td class="item_tab5" width="25">&nbsp;</td>
		</tr>
	</table>

<table border="0" width="750" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL" align="center">
    
    
	<table border="0" width="100%" cellspacing="0" cellpadding="0">
	   <tr style="height:20px">
	    <td width="10%" class="col_name1" align="center" valign="middle">ลำดับ</td>
	    <td width="25%" class="col_name2" align="center" valign="middle">วันที่</td>
	    <td width="50%" class="col_name1" align="left" valign="middle">ชื่อไฟล์</td>
	    <td width="15%" class="col_name2" align="center" valign="middle">ผู้ Upload</td>
	   </tr>
	   <%
	   		Vector fileList = getFileList(conn,new Vector(),iCompany,iProject,0);
	   		if (fileList==null) fileList = new Vector();
	   		String bgColor = "";
	   		int cnt = 0;
	   		
   			String dat[] = null;
   			for (int i=0;i<fileList.size();i++) {
   				dat = doString.checkString((String) fileList.elementAt(i),"").split("#");
   				if (dat.length==3) {
   					cnt++;
					bgColor = "col_center";
					
					if (cnt%2==0) {
						bgColor += " ; gray";		
					}	   				
	   				%>
					<tr class="<%=bgColor %>">
						<td class="dotline" align="center"><%=cnt %></td>
						<td class="dotline" align="center"><%=doString.checkString(dat[0],"") %></td>
						<td class="dotline" align="left"> &nbsp; <%=doString.DisplayThai(doString.checkString(dat[1],"")) %></td>
						<td class="dotline" align="center"><%=doString.checkString(dat[2],"") %></td>
					</tr>	   				
	   				<%
   				}
   			} // end for
   			
	   		if (cnt<=0) {	   		
	   			%>
				<tr class="col_center">
					<td class="dotline" align="center" colspan="3">ไม่พบข้อมูลเอกสาร</td>
				</tr>
	   			<%
	   		}
	   %>
	</table>    
    
    </td>
  </tr>  
</table>

<table border="0" width="750" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>	


<!---- phase block ---->
<br style="font-size:10pt">

	<table border="0" width="750" cellspacing="0" cellpadding="0">
		<tr>
			<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
			<td class="item_tab2" width="200">รายละเอียดเฟส</td>
			<td class="item_tab3"></td>
			<td class="item_tab4">&nbsp;</td>
			<td class="item_tab5" width="25">&nbsp;</td>
		</tr>
	</table>

<table border="0" width="750" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL" align="center">
    
    
<table border="0" width="100%" cellspacing="0" cellpadding="0">
   <tr style="height:20px">
    <td width="5%" class="col_name1" align="center" valign="middle" rowspan="2">เฟส</td>
    <td width="20%" class="col_name2" align="center" valign="middle" rowspan="2">การจัดเก็บ</td>
    <td width="14%" class="col_name1" align="center" valign="middle" rowspan="2"><nobr>วันที่สิ้นสุดโครงการ</nobr></td>
    <td width="14%" class="col_name2" align="center" valign="middle" rowspan="2">เดือนคงเหลือ</td>
    <td width="14%" class="col_name1" align="center" valign="middle" colspan="3">กำหนดราคาล่าสุด</td>
    <td width="5%" class="col_name2" align="center" valign="middle" rowspan="2">&nbsp;</td>
   </tr>
   <tr style="height:20px">
    <td width="14%" class="col_name1" align="center" valign="middle">วันที่</td>
    <td width="14%" class="col_name2" align="center" valign="middle">ค่าบริการสาธาณะ</td>
    <td width="14%" class="col_name1" align="center" valign="middle">ค่าสาธารณูปโภค</td>
  </tr>
  <%
  	String iPhase = "";	
	String dPublic = "";
	String dEndProj = "";
	String fExtra = "";
	String remain = "";
	int fProject = 0;
	double zClub = 0.0;
	double zPrice = 0.0;
	int cntLockUsed = 0;
	String link = "";
	bgColor = "";
	cnt = 0;
	
    sql.delete(0,sql.length());
    sql.append(" select lpad(trim(nvl(h.i_phase,'')), 3, '0') as last_phase,d.z_price,d.d_public,h.* ")
       .append(" from lan:acspubhd h,lan:acspubdt d ")
       .append(" where h.i_company='"+iCompany+"' and h.i_project='"+iProject+"' ")
       .append(" and d.i_company=h.i_company and d.i_project=h.i_project and h.i_phase=d.i_phase ")
       .append(" and d.d_public in (select max(d_public) from lan:acspubdt d2 where d2.i_company=d.i_company and d2.i_project=d.i_project and d2.i_phase=d.i_phase) ")
       .append(" order by 1 ");      
	rs = stmt.executeQuery(sql.toString());
	while (rs.next()) {
		iPhase = doString.checkString(rs.getString("i_phase"),"");			
		dEndProj = doString.checkString(rs.getString("d_end_project"),"");
		dPublic = doString.checkString(rs.getString("d_public"),"");
		fExtra = doString.checkString(rs.getString("f_extra"),"");
		fProject = Integer.parseInt(doString.checkString(rs.getString("f_project"),""));
		zClub = rs.getDouble("z_club");
		zPrice = rs.getDouble("z_price");	
		remain = calRemainMonth(nowYear,nowMonth,dEndProj);	
		cnt++;	
		
		//--- count lock used ---//
		cntLockUsed = 0;
		sql.delete(0,sql.length());
		sql.append(" select count(*) as cnt from lan:acxslock ")
		   .append(" where i_company='"+iCompany+"' and i_project='"+iProject+"' ")
		   .append(" and i_phase='"+iPhase+"' and i_lor is not null ");
		rs1 = stmt1.executeQuery(sql.toString());		
		if (rs1.next()) {
			cntLockUsed = rs1.getInt("cnt");
		}
		rs1.close();
		
		bgColor = "col_center";
		if (cnt%2==0) {
			bgColor += " ; gray";		
		}
		link = "SERV_PhaseProjForm.jsp?sel_project="+selProj+"&i_phase="+iPhase;
			
		%>
		<tr class="<%=bgColor %>">
			<td class="dotline" align="center">&nbsp;<%=iPhase %></td>
			<td class="dotline" align="left">&nbsp;
			<%											
				if (fProject<0 || fProject>=collectMethod.length) {
					fProject = 0; // reset to use error message
				}
				out.println("<span style='color:red'>["+fProject+"]</span> - "+collectMethod[fProject]);
			%>
			</td>
			<td class="dotline" align="center">&nbsp;<%=displayDate(dEndProj) %></td>
			<td class="dotline" align="center">&nbsp;<nobr><%=remain %></nobr></td>	
			<td class="dotline" align="center">&nbsp;<%=displayDate(dPublic) %></td>	
			<td class="dotline" align="right"><nobr><%=doString.displayNumber("#,###,##0.00",zPrice) %> บาท/<%=(fExtra.equalsIgnoreCase("Y") ? "หลัง" : "ตรว.") %>&nbsp;</nobr></td>		
			<td class="dotline" align="right"><nobr><%=doString.displayNumber("#,###,##0.00",zClub) %> บาท/<%=(fExtra.equalsIgnoreCase("Y") ? "หลัง" : "ตรว.") %>&nbsp;</nobr></td>		
			<td class="dotline" align="center">
				<nobr>
				&nbsp;
				<%
					if (remain.indexOf("สิ้นสุด")>0) {
						%><a href="<%=link %>&act=END"><img src="images/i_search.gif" border="0"></a><%
					} else {
						%><a href="<%=link %>&act=LOAD"><img src="images/i_pen.gif" border="0"></a><%
						
						if (cntLockUsed<=0) {
							%> &nbsp; <a href="javascript:delData('<%=iPhase %>');"><img src="images/i_delete.gif" border="0"></a><%
						}						
					}
				%>
				&nbsp;
				</nobr>
			</td>	
		</tr>							
		<%			
	} // end while
	rs.close();
	
	if (cnt<=0) {
		//--- no phase in lan:acxslock ---//
		%>
		  <tr>
			<td  colspan="8" class="dotline" align="center">&nbsp;<span style='color:red'>ไม่พบข้อมูลการตั้งเฟสแปลงขาย</span></td>
		  </tr>					
		<%
	}

  %>		
 
</table>    
    
    </td>
  </tr>  
</table>

<table border="0" width="750" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>	

<br style="font-size:5pt">

<table border="0" width="750" cellspacing="0" cellpadding="0">
<tr><td><b style="color:red; font-size:14px">* หน้าจอนี้เป็นการตั้งเฟสค่าบริการสาธารณะสำหรับใช้คำนวนงวด C0</b></td></tr>
</table>   

<br style="font-size:10pt">

<table border="0" width="750" cellspacing="0" cellpadding="0" height="30">
  <tr>
	<td class="act_tab1"></td>
	<td width="75" class="act_tab2">
	<nobr>
		<img border="0" src="images/act_add.gif" 
		onmouseout=nereidFade(this,70,50,5)
		onclick="addData();"
		onmouseover=nereidFade(this,100,50,5)     
		style="FILTER: alpha(opacity=70);cursor:hand" width="70" height="27">				
		&nbsp;	
	</nobr>
	</td>   
			
			
	<td class="act_tab3">&nbsp;</td>   
	<td class="act_tab4" valign="top">&nbsp;
	 	<a href="SERV_Home.jsp"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a> &nbsp;
	</td>  
  </tr>  
</table>  
		
		
        </td>
      </tr>
    </table>
	

<table border="0" width="750" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" align="center">

<br style="font-size:20pt">

<TABLE border=0 cellspacing=0 cellpadding=0 width="600">
  <tr><td width="100%" class="copyright" align="center">
  Best Viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5  
  <br>ติชมแสดงความคิดเห็น : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a> &nbsp;หรือ Computer Department&nbsp; โทร 2308490-98,2308451-3  
  <br><img src="images/copyright.gif" width="510" height="28"></td></tr>
</TABLE> 

    </td>
  </tr>
</table>		


</TD>
</TR>
</TBODY>
</TABLE>

 
</FORM>


</BODY>

</HTML>
<%
		if (error.length()>0) {
			if (errMsg.trim().length()>0) {
				errMsg = "\\n\\n"+errMsg;
			}
			%><script>alert('พบข้อผิดพลาดในการจัดเก็บข้อมูล, กรุณาติดต่อฝ่าย IT !!<%=errMsg %>');</script><%
		}

		stmt.close();
		stmt1.close();
		stmt = null;
		stmt1 = null;

	} catch (Exception e) {
		System.out.println("ERROR SERV_PhaseProjList.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (rs1 != null) rs1.close();
			if (stmt != null) stmt.close();
			if (stmt1 != null) stmt1.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>
