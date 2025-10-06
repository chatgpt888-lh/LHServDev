<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>

<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ page import="com.svc.call.dao.services.Common" %>

<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>



 <%!

 
 public HashMap FetchCustomerOwnership(Connection conn, String comId, String projId, String lockNo,
			String houseNo) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial parameter
        	HashMap  obj  = null; 
        	boolean isAvailable = false;
        	//System.out.println("FetchCustomerOwnership ->Starting.");        	 
			/******************************************************/			
        	//*****Find project by user login  
			sql.delete(0, sql.length());
			sql.append(" SELECT a.i_lor, a.i_model, a.i_house, a.i_lock, ")
			   .append(" b.i_exp_intent1, b.d_close_law, ")
			   .append(" c.n_prename, c.n_ncustomer, c.n_scustomer, c.a_id_tel, c.a_wk_tel, c.a_etc_tel ")
			   .append(" FROM lan:acxlckmd a ")
			   .append(" LEFT JOIN lan:acscontr b ON b.i_company = a.i_company ")
			   .append(" AND b.i_project = a.i_project ")
			   .append(" AND b.i_lor = a.i_lor AND b.f_contr IS NULL ")
			   .append(" LEFT JOIN lan:acxcusto c ON c.i_customer = COALESCE(b.i_cus_intent1, b.i_exp_intent1) ") // ถ้า i_cus_intent1 ไม่มีค่าจะเลือก i_exp_intent1
			   .append(" WHERE a.i_company = '")
			   .append(comId)
			   .append("'")
			   .append(" AND a.i_project = '")
			   .append(projId)
			   .append("'");

			
			if((!"".equals(houseNo) && !"".equals(lockNo)) || ("".equals(houseNo) && "".equals(lockNo))) {
			    sql.append(" AND a.i_house = '").append(houseNo).append("' ");
			    sql.append(" AND a.i_lock = '").append(lockNo).append("' ");
			} else if(!"".equals(houseNo)) {
			    sql.append(" AND a.i_house = '").append(houseNo).append("' ");
			} else if(!"".equals(lockNo)) {
			    sql.append(" AND a.i_lock = '").append(lockNo).append("' ");
			}


			System.out.println("-->Get Customer SQL :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString()); 
			rs = pstmt.executeQuery();	
			if(rs.next()){
				isAvailable = true;
				obj =  new HashMap();
				obj.put("xFname",doString.checkString(rs.getString("n_prename"), "")+" "+doString.checkString(rs.getString("n_ncustomer"), ""));	
				obj.put("xLname",doString.checkString(rs.getString("n_scustomer"), ""));	
				
				String nCustTel = doString.checkString(rs.getString("a_id_tel"),"");
				String tel = doString.checkString(rs.getString("a_wk_tel"),"");
				if (tel.length()>0) {
					nCustTel += (nCustTel.length()>0) ? " , "+tel : tel;
				}
				tel = doString.checkString(rs.getString("a_etc_tel"),"");
				if (tel.length()>0) {
					nCustTel += (nCustTel.length()>0) ? " , "+tel : tel;
				}
				obj.put("xTel",doString.checkString(nCustTel, ""));	
			}
			rs.close();	
			//********************************************************/		
			//System.out.println("FetchCustomerOwnership ->successfully. ");				  	 
		  	return obj;			  	 
		}catch(Exception e){
			System.out.println("!!!FetchCustomerOwnership , "  + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
			return null;
		}
		finally{			
			//clean up.
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
			}catch(Exception e){}
		}
	}	
	
	 public HashMap FetchesHashContractor(Connection conn, String comId, String projId, String lockNo,
			String houseNo) {
		StringBuffer sql = new StringBuffer();	
		PreparedStatement pstmt = null;
		ResultSet rs = null;
        try{
        	//initial parameter
        	HashMap  obj  = null; 
        	//System.out.println("FetchCustomerOwnership ->Starting.");        	 
			/******************************************************/			
        	//*****Find project by user login  
			sql.delete(0, sql.length());
			sql.append(" select first 1 n_customer,n_custel from lan:svc_dochd Where 1 = 1 ")
			   .append(" AND i_company = '")
			   .append(comId)
			   .append("'")
			   .append(" AND i_project = ")
			   .append("'")
			   .append(projId)
			   .append("'");
			if((!"".equals(houseNo) && !"".equals(lockNo)) || ("".equals(houseNo) && "".equals(lockNo))) {
			    sql.append(" AND i_house = '").append(houseNo).append("' ");
			    sql.append(" AND i_lock = '").append(lockNo).append("' ");
			} else if(!"".equals(houseNo)) {
			    sql.append(" AND i_house = '").append(houseNo).append("' ");
			} else if(!"".equals(lockNo)) {
			    sql.append(" AND i_lock = '").append(lockNo).append("' ");
			}
			
			sql.append(" order by d_keyin desc");


			System.out.println("-->Get Customer SQL :"+sql.toString());
			pstmt = conn.prepareStatement(sql.toString()); 
			rs = pstmt.executeQuery();	
			if(rs.next()){
				obj =  new HashMap();
				obj.put("xContractorName",doString.checkString(rs.getString("n_customer"), ""));	//TODO FetchesHashContractor edit name
				obj.put("xContractorTel",doString.checkString(rs.getString("n_custel"), ""));	
			}
			rs.close();	
			//********************************************************/		
			//System.out.println("FetchesHashContractor ->successfully. ");				  	 
		  	return obj;			  	 
		}catch(Exception e){
			System.out.println("!!!FetchesHashContractor , "  + e.getMessage());
			System.out.println(" SQL Exception: "+sql.toString());		
			return null;
		}
		finally{			
			//clean up.
			try{
				if(rs!=null){rs.close();}
				if(pstmt!=null){pstmt.close();}
			}catch(Exception e){}
		}
	}  
	
  %>
 
 
<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String empId = user.getEmpId();
String jName = "SERV_LckDetail.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

	doString str = new doString();


	//----=================== Get data from parameter =======================----//
    String selProj = doString.checkString(request.getParameter("sel_project"),"").toUpperCase();
    //String vendType = doString.checkString(request.getParameter("i_type"),"").toUpperCase();
	String house_id = doString.checkString(request.getParameter("house_id"),"");
	String lock = doString.checkString(request.getParameter("lock"),"");
    String condition = "";
	String i_com = "", i_proj = "";
	String folder_code = "";
	
	if (selProj.trim().length()>=6) {
		i_com = selProj.substring(0,2);
		i_proj = selProj.substring(3,6);
	}

	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	Statement stmt2 = null;
	ResultSet rs = null;
	ResultSet rs2 = null;
	SERV_CommonData common = null;
	
	Connection connCd = null;

	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();	
		stmt2 = conn.createStatement();	
		common = new SERV_CommonData(conn);
		
		
		
		
		
		
		
		
		/*Hashtable tmpCust = common.getCustomerDetails(i_com,i_proj,lock,house_id);
		housePlan = doString.checkString((String) tmpCust.get("i_model"),"");
		houseId = doString.checkString((String) tmpCust.get("i_house"),houseId);
		iLock = doString.checkString((String) tmpCust.get("i_lock"),iLock);
	    iCustomer = doString.checkString((String) tmpCust.get("i_customer"),"");
	    guranteeDesc = doString.DisplayThai(doString.checkString((String) tmpCust.get("gurantee_desc"),"-"));
	    guranteeDate = doString.checkString((String) tmpCust.get("gurantee_date"),"-");
	    custName = doString.DisplayThai(doString.checkString((String) tmpCust.get("n_customer"),""));
		custTel = doString.checkString((String) tmpCust.get("n_cust_tel"),"");	
		guranteeOk = doString.checkString((String) tmpCust.get("gurantee_ok"),"");	
		foundCust = doString.checkString((String) tmpCust.get("found_cust"),"");
		*/	
		//-------------------


%>

<style type="text/css">

.select2-selection__rendered {
  	font-family: Tohama, Arial, sans-serif;
    font-size: 10.1pt;
    color: #165396 !important;
}


.select2-results__option {
	font-family: Tohama, Arial, sans-serif;
    font-size: 10.1pt;
    color: #165396;
}    
    
</style>

<HTML>
<HEAD>
<TITLE> รายละเอียดบ้านลูกค้า | ข้อมูลพื้นฐาน</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">

<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />

<script language="javascript" src="script_fx.js"></script>

<script language="javascript">
<!--
function submit()  {
			frmDetail.lock.value = frmDetail.lock.value.toUpperCase();
			frmDetail.action = "<%=Constants.APP_PATH%>/SERV_LckDetail.jsp";
			frmDetail.submit();
}

 $(document).ready(function() {
 
 	
 	
    $('#sel_project').select2({
         matcher: function(params, data) {
            if ($.trim(params.term) === '') {
                return data;
            }

            // ปรับเปลี่ยนข้อความที่ใช้ในการค้นหาแต่ละตัวเลือก โดยลบเครื่องหมาย : และแปลงเป็นตัวอักษรเล็ก
            var searchTerm = params.term.trim().toLowerCase().replace(/-/g, '');
            var optionText = (data.text || '').toLowerCase().replace(/-/g, '');

            // ตรวจสอบว่าคำค้นหาอยู่ในตัวเลือกหรือไม่
            if (optionText.indexOf(searchTerm) > -1) {
                return data;
            }

            return null; // ไม่มีข้อมูลที่ตรงกับการค้นหา
        }
    });
    
});
  

//-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM name="frmDetail" method="post" action="">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >   
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="100%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
          รายละเอียดบ้านลูกค้า | ข้อมูลพื้นฐาน</td>
        </tr>
      </table>


<br style="font-size:10pt">
                
            
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="250"> รายละเอียดบ้านลูกค้า</td>
                <td class="item_tab3"></td>
                <td>&nbsp;</td>
              </tr>
            </table>            


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop">&nbsp;</td>
    <td width="5" valign="top" align="right"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR" align="center">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td class="item ; dotline01" height="22" width="10%" colspan="2">โครงการ :</td>
    <td height="22" width="30%" class="dotline01">
      <%=common.genProjectListboxByUserId(user.getUserID(),"sel_project",selProj," class='box' style='width:250px'  onchange='changePage(1);' ",false)%>
    </td>
    <td height="22" class="item ; dotline01" width="5%">แปลง :</td>
    <td height="22" width="10%" class="dotline01"><input type="text" name="lock" class="box" style="width:50px" value="<%=lock%>"maxlength ="5"></td>
    <td height="22" class="item ; dotline01" width="5%">บ้านเลขที่ :</td>
	<td height="22" width="40%" class="dotline01"><input type="text" name="house_id" class="box" style="width:100px" value="<%=house_id%>">&nbsp;&nbsp;<a href="javascript:submit();"><img src="images/bu_go.gif" border="0" align="absmiddle"></a></td>
  </tr>
</table>



</td>
  </tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>


<br style="font-size:2pt">


      


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
    <td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>

<%
String i_house = "", i_model = "", i_lock = "", i_cus = "", cus_name = "", d_close_law = "", ven_no = "", ven_name = "";
String v_object1 = "", v_object2 = "", v_object3 = "", v_object4 = "", v_object5 = "", v_object6 = "", v_object7 = "", v_object8 = "";
String object1 = "", object2 = "", object3 = "", object4 = "";
String cus_idtel = "", cus_wktel = "", cus_tel = "";
String smartHome = "";

String contract_id = "";
String contractor_name = ""; 
String contractor_idtel = "" ;
String contractor_wktel = "" ;
String contractor_tel = "";
String i_lor = "";




  sql.delete(0, sql.length());
  sql.append("SELECT a.i_house, a.i_model, a.i_lock, b.i_exp_intent1,b.i_cus_intent1 , b.d_close_law , b.i_lor FROM acxlckmd a, acscontr b ")                      
	.append("WHERE a.i_company = '"+i_com+"' ")
	.append("AND a.i_project = '"+i_proj+"' ")
	.append("AND (a.i_lock = '"+lock+"' or a.i_house = '"+house_id+"') ")
	.append("AND a.i_company = b.i_company ")
	.append("AND a.i_project = b.i_project ")
	.append("AND a.i_lor = b.i_lor ")
	.append("AND a.i_lor IS NOT NULL ")
	.append("AND b.d_close_law IS NOT NULL ");
//servlog.startLog(sql.toString());
//System.out.println("SQL2:"+sql.toString());
rs = stmt.executeQuery(sql.toString());
//servlog.endLog();
if (rs.next())	 {
//System.out.println("SQL2: have data");
	i_house = doString.checkString(rs.getString("i_house"));
	i_model = doString.checkString(rs.getString("i_model"));
	i_lock = doString.checkString(rs.getString("i_lock"));
	lock = i_lock;
	i_cus = doString.checkString(rs.getString("i_exp_intent1")); //ผู้ทำสัญญาหรือ 
	contract_id = doString.checkString(rs.getString("i_cus_intent1")); //ชื่อผู้โอนสิทธ์  customer
	i_lor = doString.checkString(rs.getString("i_lor")); //เลขที่ใบจองที่จะหา

		if (!doString.checkString(doString.DisplayThai(rs.getString("d_close_law"))).equals("")) {
			d_close_law = doString.checkString(doString.DisplayThai(rs.getString("d_close_law"))).substring(8,10)+"/"+doString.checkString(doString.DisplayThai(rs.getString("d_close_law"))).substring(5,7)+"/"+(Integer.parseInt(doString.checkString(doString.DisplayThai(rs.getString("d_close_law"))).substring(0,4))+543);  
		}
}  //  end if

		//*********** Transferor of rights Info ********************** //
		/*if(!"".equals(i_cus)){
				sql.delete(0, sql.length());
				sql.append("SELECT n_prename, n_ncustomer, n_scustomer, a_id_tel, a_wk_tel FROM acxcusto WHERE i_customer = '"+i_cus+"' ");
				//System.out.println(sql.toString());
				rs = stmt.executeQuery(sql.toString());
				//servlog.endLog();
				if (rs.next())	 {
						cus_name = doString.checkString(doString.DisplayThai(rs.getString("n_prename")))+"&nbsp;"+doString.checkString(doString.DisplayThai(rs.getString("n_ncustomer")))+"&nbsp;"+doString.checkString(doString.DisplayThai(rs.getString("n_scustomer")));
						cus_idtel = doString.checkString(rs.getString("a_id_tel"),"");
						cus_wktel = ", "+doString.checkString(rs.getString("a_wk_tel"),"");
						cus_tel = cus_idtel+cus_wktel;
				}
				rs.close();
		} 

	    if(!"".equals(contract_id)){ //fix to use new query
	    		//*********** Contractor Info ********************** //
				sql.delete(0, sql.length());
				sql.append("SELECT n_prename, n_ncustomer, n_scustomer, a_id_tel, a_wk_tel FROM acxcusto WHERE i_customer = '"+contract_id+"' ");
				//System.out.println(sql.toString());
				rs = stmt.executeQuery(sql.toString());
				//servlog.endLog();
				if (rs.next())	 {
						contractor_name = doString.checkString(doString.DisplayThai(rs.getString("n_prename")))+"&nbsp;"+doString.checkString(doString.DisplayThai(rs.getString("n_ncustomer")))+"&nbsp;"+doString.checkString(doString.DisplayThai(rs.getString("n_scustomer")));
						contractor_idtel = doString.checkString(rs.getString("a_id_tel"),"");
						contractor_wktel = ", "+doString.checkString(rs.getString("a_wk_tel"),"");
						contractor_tel = doString.DisplayThai(contractor_idtel+contractor_wktel);
				}
				rs.close();
	    }
	    
	    */

		//boolean isEditCustomer = false;
	    HashMap hashData = FetchCustomerOwnership(conn,i_com,i_proj,lock,house_id);
	    if(hashData!= null){
	   		//isEditCustomer = true;
	   		cus_name = doString.DisplayThai(hashData.get("xFname")+" "+hashData.get("xLname"));
	   		cus_tel = doString.DisplayThai(hashData.get("xTel").toString());  	
	   }
	   
	   
	   
	   HashMap hashDataC = FetchesHashContractor(conn,i_com,i_proj,lock,house_id);
	   if(hashDataC!= null){
	   		contractor_name = doString.DisplayThai(hashDataC.get("xContractorName").toString()); 
	   		contractor_tel = doString.DisplayThai(hashDataC.get("xContractorTel").toString()); 
	   }
	   

			
		//********** VENDOR NAME ************************** //
		sql.delete(0, sql.length());
		sql.append("SELECT ven_no FROM unit WHERE i_company = '"+i_com+"' AND i_project = '"+i_proj+"' AND i_lock = '"+lock+"' ");
		//System.out.println("VENDOR NAME="+sql.toString());
		rs = stmt.executeQuery(sql.toString());
		//servlog.endLog();
			if (rs.next())	 {
				ven_no = doString.checkString(doString.DisplayThai(rs.getString("ven_no")));
			}
			sql.delete(0, sql.length());
			sql.append("SELECT ven_name FROM vendor WHERE ven_no = '"+ven_no+"' ");
			//servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			//servlog.endLog();  
				if (rs.next())	 {
					ven_name = doString.checkString(doString.DisplayThai(rs.getString("ven_name")));
				}

		// *********** แบบ/กระเบื้อง *********************** //
		sql.delete(0, sql.length());
		sql.append("SELECT i_vendor FROM accpohdr WHERE i_company = '"+i_com+"' AND i_project = '"+i_proj+"' AND i_lock = '"+lock+"' AND grp_no = 'J3' AND f_status = 'OPN' ");
		//System.out.println("แบบ/กระเบื้อง ="+sql.toString());
		rs = stmt.executeQuery(sql.toString());
		//servlog.endLog();
		if (rs.next())	 {
			sql.delete(0, sql.length());
			sql.append("SELECT ven_name FROM vendor WHERE ven_no = '"+doString.checkString(rs.getString("i_vendor"))+"' ");
			//servlog.startLog(sql.toString());
			rs2 = stmt2.executeQuery(sql.toString());
			//servlog.endLog();
			if (rs2.next())	 {
				v_object1 = doString.checkString(rs2.getString("ven_name"));		}
		}
		// *********** ชุดครัว *********************** //
		sql.delete(0, sql.length());
		sql.append("SELECT i_vendor FROM accpohdr WHERE i_company = '"+i_com+"' AND i_project = '"+i_proj+"' AND i_lock = '"+lock+"' AND grp_no = 'O4' AND f_status = 'OPN' ");
		//System.out.println("ชุดครัว="+sql.toString());
		rs = stmt.executeQuery(sql.toString());
		//servlog.endLog();  
		if (rs.next())	 {
			sql.delete(0, sql.length());
			sql.append("SELECT ven_name FROM vendor WHERE ven_no = '"+doString.checkString(rs.getString("i_vendor"))+"' ");
			//servlog.startLog(sql.toString());
			rs2 = stmt2.executeQuery(sql.toString());
			//servlog.endLog();
			if (rs2.next())	 {
				v_object2 = doString.checkString(rs2.getString("ven_name"));		}
		}
		// ***********วอลเปเปอร์ *********************** //
		sql.delete(0, sql.length());
		sql.append("SELECT i_vendor FROM accpohdr WHERE i_company = '"+i_com+"' AND i_project = '"+i_proj+"' AND i_lock = '"+lock+"' AND grp_no = 'L7' AND f_status = 'OPN' ");
		//System.out.println("วอลเปเปอร์="+sql.toString());
		rs = stmt.executeQuery(sql.toString());
		//servlog.endLog();
		if (rs.next())	 {
			sql.delete(0, sql.length());
			sql.append("SELECT ven_name FROM vendor WHERE ven_no = '"+doString.checkString(rs.getString("i_vendor"))+"' ");
			//servlog.startLog(sql.toString());
			rs2 = stmt2.executeQuery(sql.toString());
			//servlog.endLog();
			if (rs2.next())	 {
				v_object3 = doString.checkString(rs2.getString("ven_name"));		}
		}
		// ***********สวน*********************** //
		sql.delete(0, sql.length());
		sql.append("SELECT i_vendor FROM accpohdr WHERE i_company = '"+i_com+"' AND i_project = '"+i_proj+"' AND i_lock = '"+lock+"' AND grp_no = 'S3' AND f_status = 'OPN' ");
		//System.out.println("สวน="+sql.toString());
		rs = stmt.executeQuery(sql.toString());
		//servlog.endLog();    
		if (rs.next())	 {
			sql.delete(0, sql.length());
			sql.append("SELECT ven_name FROM vendor WHERE ven_no = '"+doString.checkString(rs.getString("i_vendor"))+"' ");
			//servlog.startLog(sql.toString());
			rs2 = stmt2.executeQuery(sql.toString());
			//servlog.endLog();
			if (rs2.next())	 {
				v_object4 = doString.checkString(rs2.getString("ven_name"));		}
		}
		// ***********มุ้งลวด*********************** //
		sql.delete(0, sql.length());
		sql.append("SELECT i_vendor FROM accpohdr WHERE i_company = '"+i_com+"' AND i_project = '"+i_proj+"' AND i_lock = '"+lock+"' AND grp_no IN ('H4','H9') AND f_status = 'OPN' ");
		//System.out.println("มุ้งลวด="+sql.toString());
		rs = stmt.executeQuery(sql.toString());
		//servlog.endLog();  
		if (rs.next())	 {
			sql.delete(0, sql.length());
			sql.append("SELECT ven_name FROM vendor WHERE ven_no = '"+doString.checkString(rs.getString("i_vendor"))+"' ");
			//servlog.startLog(sql.toString());
			rs2 = stmt2.executeQuery(sql.toString());
			//servlog.endLog();
			if (rs2.next())	 {
				v_object5 = doString.checkString(rs2.getString("ven_name"));		}
		}
		// ***********หินอ่อน*********************** //
		sql.delete(0, sql.length());
		sql.append("SELECT i_vendor FROM accpohdr WHERE i_company = '"+i_com+"' AND i_project = '"+i_proj+"' AND i_lock = '"+lock+"' AND grp_no = 'L3' AND f_status = 'OPN' ");
		//System.out.println("หินอ่อน="+sql.toString());
		rs = stmt.executeQuery(sql.toString());
		//servlog.endLog(); 
		if (rs.next())	 {
			sql.delete(0, sql.length());
			sql.append("SELECT ven_name FROM vendor WHERE ven_no = '"+doString.checkString(rs.getString("i_vendor"))+"' ");
			//servlog.startLog(sql.toString());
			rs2 = stmt2.executeQuery(sql.toString());
			//servlog.endLog();
			if (rs2.next())	 {
				v_object6 = doString.checkString(rs2.getString("ven_name"));		}
		}
		// ***********บานประตู/หน้าต่าง*********************** //
		sql.delete(0, sql.length());
		sql.append("SELECT i_vendor FROM accpohdr WHERE i_company = '"+i_com+"' AND i_project = '"+i_proj+"' AND i_lock = '"+lock+"' AND grp_no IN ('H2','H7') AND f_status = 'OPN' ");
		//System.out.println("บานประตู/หน้าต่าง="+sql.toString());
		rs = stmt.executeQuery(sql.toString());
		//servlog.endLog(); 
		if (rs.next())	 {
			sql.delete(0, sql.length());
			sql.append("SELECT ven_name FROM vendor WHERE ven_no = '"+doString.checkString(rs.getString("i_vendor"))+"' ");
			//servlog.startLog(sql.toString());
			rs2 = stmt2.executeQuery(sql.toString());
			//servlog.endLog();
			if (rs2.next())	 {
				v_object7 = doString.checkString(rs2.getString("ven_name"));		}
		}
		// ***********ปลวก*********************** //
		sql.delete(0, sql.length());
		sql.append("SELECT i_vendor FROM accpohdr WHERE i_company = '"+i_com+"' AND i_project = '"+i_proj+"' AND i_lock = '"+lock+"' AND grp_no = 'B2' AND f_status = 'OPN' ");
		//System.out.println("ปลวก="+sql.toString());
		rs = stmt.executeQuery(sql.toString());
		//servlog.endLog();  
		if (rs.next())	 {
			sql.delete(0, sql.length());
			sql.append("SELECT ven_name FROM vendor WHERE ven_no = '"+doString.checkString(rs.getString("i_vendor"))+"' ");
			//servlog.startLog(sql.toString());
			rs2 = stmt2.executeQuery(sql.toString());
			//servlog.endLog();
			if (rs2.next())	 {
				v_object8 = doString.checkString(rs2.getString("ven_name"));		}
		}
		// ***********แบบสีหลังคา*********************** //
		sql.delete(0, sql.length());
		sql.append("SELECT i_menu FROM dfm_mnudt WHERE i_company = '"+i_com+"' AND i_project = '"+i_proj+"' AND i_lock1 = '"+lock+"' AND i_menu_type = '01' ");
		//System.out.println("แบบสีหลังคา="+sql.toString());
		rs = stmt.executeQuery(sql.toString());
		//servlog.endLog();  
		if (rs.next())	 {
			object1 = doString.checkString(rs.getString("i_menu"));   }
		
		//add by pradoem 2020.06.08
		String colorRoofPaint = "";
		sql.delete(0, sql.length());
		sql.append(" select a.i_vendor ,b.ven_name from lan:accpohdr a,lan:vendor b  WHERE a.i_company = '"+i_com+"' AND a.i_project = '"+i_proj+"' AND a.i_lock = '"+lock+"' AND a.grp_no = 'C7' AND a.f_status = 'OPN' and a.i_vendor = b.ven_no ");
		//System.out.println("colorRoofPaint="+sql.toString());
		rs = stmt.executeQuery(sql.toString());
		////servlog.endLog();  
		if (rs.next())	 {
			colorRoofPaint = doString.checkString(rs.getString("ven_name"));   
		}
		// ***********แบบกระเบื้อง*********************** //
		sql.delete(0, sql.length());
		sql.append("SELECT i_menu FROM dfm_mnudt WHERE i_company = '"+i_com+"' AND i_project = '"+i_proj+"' AND i_lock1 = '"+lock+"' AND i_menu_type = '02' ");
		//System.out.println("แบบกระเบื้อง="+sql.toString());
		rs = stmt.executeQuery(sql.toString());
		//servlog.endLog();
		if (rs.next())	 {
			object2 = doString.checkString(rs.getString("i_menu"));   }
		// ***********แบบชุดครัว*********************** //
		sql.delete(0, sql.length());
		sql.append("SELECT i_menu FROM dfm_mnudt WHERE i_company = '"+i_com+"' AND i_project = '"+i_proj+"' AND i_lock1 = '"+lock+"' AND i_menu_type = '03' ");
		//System.out.println("แบบชุดครัว="+sql.toString());
		rs = stmt.executeQuery(sql.toString());
		//servlog.endLog();
		if (rs.next())	 {
			object3 = doString.checkString(rs.getString("i_menu"));   }


			// ***********แอร์*********************** //
		sql.delete(0, sql.length());
		sql.append("SELECT i_vendor FROM accpohdr WHERE i_company = '"+i_com+"' AND i_project = '"+i_proj+"' AND i_lock = '"+lock+"' AND grp_no = 'F4' AND f_status = 'OPN' ");
		//System.out.println("แอร์="+sql.toString());
		rs = stmt.executeQuery(sql.toString());
		//servlog.endLog();    
		if (rs.next())	 {
			sql.delete(0, sql.length());
			sql.append("SELECT ven_name FROM vendor WHERE ven_no = '"+doString.checkString(rs.getString("i_vendor"))+"' ");
			//servlog.startLog(sql.toString());
			rs2 = stmt2.executeQuery(sql.toString());
			//servlog.endLog();
			if (rs2.next())	 {
				object4 = doString.checkString(rs2.getString("ven_name"));		}
		}
		
		// *********** Smart Home ********************** //
		
		sql.delete(0, sql.length());
		sql.append("SELECT i_vendor FROM accpohdr WHERE i_company = '"+i_com+"' AND i_project = '"+i_proj+"' AND i_lock = '"+lock+"' AND grp_no = 'QJ' AND f_status = 'OPN' ");
		//System.out.println("Smart Home :"+sql.toString());
		rs = stmt.executeQuery(sql.toString());
		//servlog.endLog();    
		if (rs.next())	 {
			sql.delete(0, sql.length());
			sql.append("SELECT ven_name FROM vendor WHERE ven_no = '"+doString.checkString(rs.getString("i_vendor"))+"' ");
			//servlog.startLog(sql.toString());
			rs2 = stmt2.executeQuery(sql.toString());
			//servlog.endLog();
			if (rs2.next())	 {
				smartHome = doString.checkString(rs2.getString("ven_name"));		}
		}
		
		
		
%>




<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL">
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
		<tr>
		  <td class="item ; dotline01" align="left" width="10%">ชื่อผู้ทำสัญญา/ผู้โอนสิทธ์ : </td>
		  <td class="dotline01" align="left" width="40%"><%=cus_name%>&nbsp;
		  <% //if(isEditCustomer){out.println("<font size='2' color='#FF0000'>*edit</font>");} %> (เบอร์โทร : <%=cus_tel %>  <%//if(isEditCustomer){out.println("<font size='2' color='#FF0000'>*edit</font>");;} %>)
		  </td>
		   <td class="item ; dotline01" align="left" width="10%">บ้านเลขที่ : </td>
		  <td class="dotline" align="left" width="40%"><%=i_house%>&nbsp;&nbsp;&nbsp;แปลง : &nbsp;<%=i_lock%>&nbsp;</td>
		</tr>     
		<tr>
		  <td class="item ; dotline01" align="left" width="10%">ชื่อผู้แจ้ง  : </td>
		  <td class="dotline01" align="left" width="40%"><%=contractor_name%>&nbsp;
		 (เบอร์โทร :<%=contractor_tel %>)
		  </td>
		   <td class="item ; dotline01" align="left" width="10%">แบบบ้าน : </td>
		  <td class="dotline" align="left" width="40%"><%=i_model%>&nbsp;</td>
		</tr>  
		<tr>
		  <td class="item ; dotline01" align="left" width="10%">วันที่โอน : </td>
		  <td class="dotline01" align="left" width="40%"><%=d_close_law%>&nbsp;</td>
		   <td class="item ; dotline01" align="left" width="10%">ผู้รับเหมา : </td>
		  <td class="dotline" align="left" width="40%"><%=ven_name%>&nbsp;</td>
		</tr>  
		<tr>
		  <td class="item ; dotline01" align="left" width="10%">สีหลังคา : </td>
		  <td class="dotline01" align="left" width="40%"><%=doString.DisplayThai(object1)%>&nbsp;&nbsp;&nbsp;&nbsp;<%=doString.DisplayThai(colorRoofPaint)%>&nbsp;</td>
		   <td class="item ; dotline01" align="left" width="10%">แบบ/กระเบื้อง : </td>
		  <td class="dotline" align="left" width="40%"><%=doString.DisplayThai(object2)%>&nbsp;&nbsp;&nbsp;&nbsp;<%=doString.DisplayThai(v_object1)%>&nbsp;</td>
		</tr>  
		<tr>
		  <td class="item ; dotline01" align="left" width="10%">ชุดครัว : </td>
		  <td class="dotline01" align="left" width="40%"><%=doString.DisplayThai(object3)%><%=doString.DisplayThai(v_object2)%>&nbsp;</td>
		   <td class="item ; dotline01" align="left" width="10%">วอลเปเปอร์ : </td>
		  <td class="dotline" align="left" width="40%"><%=doString.DisplayThai(v_object3)%>&nbsp;</td>
		</tr>  
		<tr>
		  <td class="item ; dotline01" align="left" width="10%">สวน : </td>
		  <td class="dotline01" align="left" width="40%"><%=doString.DisplayThai(v_object4)%>&nbsp;</td>
		   <td class="item ; dotline01" align="left" width="10%">มุ้งลวด : </td>
		  <td class="dotline" align="left" width="40%"><%=doString.DisplayThai(v_object5)%>&nbsp;</td>
		</tr>  
		<tr>
		  <td class="item ; dotline01" align="left" width="10%">หินอ่อน : </td>
		  <td class="dotline01" align="left" width="40%"><%=doString.DisplayThai(v_object6)%>&nbsp;</td>
		   <td class="item ; dotline01" align="left" width="10%">บานประตู/หน้าต่าง : </td>
		  <td class="dotline" align="left" width="40%"><%=doString.DisplayThai(v_object7)%>&nbsp;</td>
		</tr>  
		<tr>
		  <td class="item ; dotline01" align="left" width="10%">ปลวก : </td>
		  <td class="dotline01" align="left" width="40%"><%=doString.DisplayThai(v_object8)%>&nbsp;</td>
		   <td class="item ; dotline01" align="left" width="10%">เครื่องปรับอากาศ : </td>
		  <td class="dotline" align="left" width="40%"><%=doString.DisplayThai(object4)%>&nbsp;</td>
		</tr> 
		<tr>
		  <td class="item ; dotline01" align="left" width="10%">Smart Home : </td>
		  <td class="dotline01" align="left" width="40%"><%=doString.DisplayThai(smartHome)%>&nbsp;</td>
		   <td class="item ; dotline01" align="left" width="10%">ใบบันทึกบ้านแต่งเฟอร์ฯ : </td>
		   <td class="dotline" align="left" width="40%">
		   <%
		   // *********** ใบบันทึกบ้านแต่งเฟอร์ฯ  ********************** //
		sql.delete(0, sql.length());
		sql.append("select m.i_memo,c.i_lor,c.i_loi from lan:lor_ffmemo m left join lan:acscontr c on c.i_company=m.i_company and c.i_project=m.i_project and c.i_lor=m.i_lor where m.i_company='"+i_com+"'and m.i_project='"+i_proj+"' and m.i_lor='"+i_lor+"' and m.f_status='Y' ");
		//System.out.println("furniture :"+sql.toString());
		rs = stmt.executeQuery(sql.toString());
		//servlog.endLog();    
		if (rs.next())	 {
			%>
				
				<a href = "https://portal.lh.co.th//LHOLor/OLor_FullFernishedMemoPrintServlet?sel_project=<%=selProj%>&i_sort=<%=i_lock%>&i_memo=<%=doString.checkString(rs.getString("i_memo"))%>&i_lor=<%=i_lor%>&print_type=LOR&emp_id=<%=empId%>&act=PRINT"  target="_blank" >ฉบับจอง</a>
				<%if(!doString.checkString(rs.getString("i_loi")).equals("")){ %> , <%}  %>
				<a href = "https://portal.lh.co.th//LHOLor/OLor_FullFernishedMemoPrintServlet?sel_project=<%=selProj%>&i_sort=<%=i_lock%>&i_memo=<%=doString.checkString(rs.getString("i_memo"))%>&i_lor=<%=i_lor%>&print_type=LOI&emp_id=<%=empId%>&act=PRINT"  target="_blank">ฉบับสัญญา</a>
			<%
		}
		 %>
		  </td>
		</tr>     
		
         <tr>
		  <td class="item ; dotline01" align="left" width="10%">ใบบันทึกโปรโมชั่น : </td>
		  <td class="dotline01" align="left" width="40%">&nbsp;</td>
		   <td class="item ; dotline01" align="left" width="10%">&nbsp;</td>
		  <td class="dotline" align="left" width="40%">&nbsp;</td>
		</tr>  
		   <%
		   // *********** ใบบันทึกโปรโมชั่น  ********************** //
		sql.delete(0, sql.length());
		sql.append("select i_memo from lan:acsnoter  where  i_company='"+i_com+"' and i_project='"+i_proj+"' and i_lor='"+i_lor+"' and i_type not in ('20','30') and f_memo in ('N','Y') and d_cancl is null and i_cancl is null order by i_memo");
		//System.out.println("promotion :"+sql.toString());
		rs = stmt.executeQuery(sql.toString());
		//servlog.endLog();    
		while (rs.next())	 {
			%>
				<tr>
				<td class="item ; dotline01" align="left" width="10%">&nbsp;</td>
				 <td class="dotline01" align="left" width="40%"><a href = "https://portal.lh.co.th//LHOLor/O_CusPromoPrintServlet?sel_project=<%=selProj%>&i_sort=<%=i_lock%>&i_memo=<%=doString.checkString(rs.getString("i_memo"))%>"  target="_blank">ใบบันทึกเลขที่ <%=doString.DisplayThai(doString.checkString(rs.getString("i_memo")))%></a></td>
				<td class="item ; dotline01" align="left" width="10%">&nbsp;</td>
			    <td class="dotline01" align="left" width="40%">&nbsp;</td>
			    </tr>
			    
			<%
		}
		 %>
		          
	   </table>
    </td>
  </tr>
  

</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>


<br style="font-size:10pt">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop">&nbsp;</td>
    <td width="5" valign="top" align="right"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>

<%

connCd = Common.GetConnMyCd();
		connCd.setAutoCommit(true);
		
		
		sql.setLength(0);

		sql.append("SELECT CONCAT_WS('-', folder, NULLIF(write_no - 1, 0)) AS folder_code ")
		   .append("FROM ( ")
		   .append("    SELECT CONCAT(short_project_code, '_', plot_no, '_', ")
		   .append("               REPLACE(home_no, '/', '.')) AS folder, ")
		   .append("           MAX(write_no) AS write_no ")
		   .append("    FROM write_cd ")
		   .append("    WHERE company_code = ? ")
		   .append("      AND project_code = ? ")
		   .append("      AND plot_no      = ? ")
		   .append("    GROUP BY CONCAT(short_project_code, '_', plot_no, '_', ")
		   .append("               REPLACE(home_no, '/', '.')) ")
		   .append(") AS t ")
		   .append("ORDER BY folder;"); 
		
		System.out.println(sql.toString());
		
		PreparedStatement ps = connCd.prepareStatement(sql.toString());
		ps.setString(1, i_com);
		ps.setString(2, i_proj);
		ps.setString(3, lock);

		rs = ps.executeQuery();
		
		if(rs.next()){
			folder_code = rs.getString("folder_code");
			//System.out.println("folder_code ===== "+folder_code);
		}else{
			folder_code = "ไม่พบข้อมูล";
		}
		rs=null;
		connCd.close();


 %>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR" align="center">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td class="item ; dotline01" height="22" width="4%" colspan="2">ข้อมูลบ้านจาก CD_Rom  :</td>
    <td height="22" width="30%" class="dotline01">
      <a href="http://132.146.1.88/write_cd_file/<%=folder_code%>/index.html" target="_blank"><%=folder_code%></a>
    </td>
  </tr>
</table>

</td>
  </tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
    <td class="frmBottom">&nbsp;</td>
    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
  </tr>
</table>


<br style="font-size:10pt">

        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="150" class="act_tab2">&nbsp;</td>
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="/LHServ/SERV_Index.jsp" target="_top"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="/LHServ/SERV_Index.jsp" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
          </tr>   
        </table>  




          </td>
        </tr>
      </table>

			
			

<br style="font-size:30pt">

<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
  <tr><td width="100%" class="copyright" align="center">
  Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5  
  <br>ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;
  หรือ โทร. 0-2230-8279 (คุณประพัฒน์
  ฝ่ายบริการ)&nbsp; 0-2230-8491-5 (ฝ่าย IT)  
  <br><img src="images/copyright.gif" width="475" height="26"></td></tr>
</TABLE> 

</FORM>
	
</BODY>

</HTML>

<%
	} catch (Exception e) {
		System.out.println("ERROR SERV_LckDetail.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
		if (rs != null)
		    rs.close();
		if (rs2 != null)
		    rs2.close();
		if (stmt != null)
		    stmt.close();
		if (stmt2 != null)
		    stmt2.close();
		if (conn != null)
		    conn.close();

		if(connCd!=null){
		 connCd.close();
		}
		
		}
		
		catch( SQLException ignore ){}
	}
%>

