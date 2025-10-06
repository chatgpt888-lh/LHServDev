<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="com.lh.util.DateUtil" %>
<%@page import="java.util.*" %>
<%@page import="java.text.*" %>
<%@page import="serv.common.*" %>
<%@ page import="serv.util.ServLog" %>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp" %>

<%
String sessionId = user.getsessionId();
String userId = user.getUserID();
String jName = "SERV_Contractor_Conf.jsp";
ServLog servlog = new ServLog(sessionId, userId, jName);

   doString str = new doString();

   //----============ Declare Variables for input data ===========----//
   String toDate = getDateFromCalendar(Calendar.getInstance())+"&nbsp;"+getTimeFromCalendar(Calendar.getInstance());
//   String mode = doString.checkString(request.getParameter("mode"),"add");
   String load = doString.checkString(request.getParameter("load"),"");
   String deleteJob = doString.checkString(request.getParameter("delete_job"),"");   
   String iDocNo = doString.checkString(request.getParameter("i_docno"),"");
   String iVendor = doString.checkString(request.getParameter("i_vendor"),"");
   
   
   //-----========= Declare Variables for Search Custoemr ===========----//
   String selProj = doString.checkString(request.getParameter("sel_project"),"");
   String houseId = doString.checkString(request.getParameter("house_id"),"");
   String iLock = doString.checkString(request.getParameter("i_lock"),"").toUpperCase();
   String nCustomer = doString.checkString(request.getParameter("n_customer"),"");
   String nCustTel = doString.checkString(request.getParameter("n_cust_tel"),"");
   String dAppoint = doString.checkString(request.getParameter("d_appoint"),"");
   String dEstClose = doString.checkString(request.getParameter("d_est_close"),"");
   String inFormEmp = "";
   String inFormDate = "";
   String projDesc = "";
   
   String cDesc = "";   
   String housePlan = "-";
   String custName = "-";
   String custTel = "-";
   String guranteeDesc = "-";
   String guranteeDate = "-";
   String iCustomer = "";
   String comId = "";
   String projId = "";
   String iCompany = "";
   String iProject = "";   
   String iDocType = "";
   String vendorName = "";
   String rejectStatus = "";
   String rejectComment = "";
   String rejectEmploy = "";
   String rejectDate = "";
			       
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	SERV_CommonData common = null;

	try {
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement(); 
		common = new SERV_CommonData(conn);       
        //----=======================================----//   
       
       
       
       //----=========================== load Openjob Data ===========================------//
	   if (iDocNo.length()>0 && iVendor.length()>0) {  
	   
	        //----======================== Find DocHD Data =============================----//
			 Hashtable tmpHeader = common.getDocHeaderDetails(iDocNo);
		     inFormEmp = doString.checkString((String) tmpHeader.get("inform_emp"),"");
	         projDesc = doString.checkString((String) tmpHeader.get("proj_desc"),"");
	         iCompany = doString.checkString((String) tmpHeader.get("i_company"),"");
	         iProject = doString.checkString((String) tmpHeader.get("i_project"),"");
	         iDocType = doString.checkString((String) tmpHeader.get("i_doc_type"),"");
	         selProj = iCompany+":"+iProject;
	         nCustomer = doString.checkString((String) tmpHeader.get("n_customer"),"");
	         nCustTel = doString.checkString((String) tmpHeader.get("n_cust_tel"),"");
	         iLock = doString.checkString((String) tmpHeader.get("i_lock"),"");
	         cDesc = doString.checkString((String) tmpHeader.get("c_desc"),"");
	         cDesc = str.replace(cDesc,"|break|","<br>");
	         cDesc = str.replace(cDesc," ","&nbsp;"); 			
			 inFormDate = doString.checkString((String) tmpHeader.get("inform_date"),"");
 		    dAppoint = doString.checkString((String) tmpHeader.get("d_appoint"),"");
			dEstClose = doString.checkString((String) tmpHeader.get("d_est_close"),"");	   

			
			Vector checkSess = (Vector) session.getAttribute(ItmJobManagement.SESSION_JOBLIST);
			if (iDocType.equalsIgnoreCase("J") && (checkSess==null || (checkSess.size()==0 && load.equalsIgnoreCase("YES")))) {
			    //----========== Find SERV_PAYMENT for this HD =========-----//
			    ItmJobManagement itm = new ItmJobManagement(request,response);
                Random rand = new Random();
							
				sql.delete(0,sql.length());
				sql.append(" select a.*,b.n_itmjob,b.z_wage_unit o_wage,b.z_good_unit o_goods from lan:serv_payment a  ")
				      .append(" left join lan:serv_boq b on b.i_itmjob=a.i_itmjob ")
				      .append(" where i_docno='").append(iDocNo).append("' ")
				      .append(" and i_vendor='").append(iVendor).append("' ")
				      .append(" and a.f_itmstatus='400' order by i_itmjob,i_seq ");

				Hashtable docdt = new Hashtable();
				String id = "";
				String nItmJob = "";
				String itemKey = "";
				servlog.startLog(sql.toString());
				rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
				while (rs.next()) {
					   docdt = new Hashtable();
					   id = doString.checkString(rs.getString("i_itmjob"),"");
					   nItmJob = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")),"");
					   				   
					   itemKey = id+"_";
		                           while (itemKey.length()<20) {
		                              	itemKey += rand.nextInt(10); 
		                           }
					   
					   itm.getJobList().addElement(itemKey);
					   itm.getItmJobList().put(itemKey,id);
					   itm.getVendorList().put(itemKey,doString.checkString(rs.getString("i_vendor"),""));
					   itm.getWageList().put(itemKey,doString.checkString(Double.toString(rs.getDouble("z_wage_price")),""));
					   itm.getCustomWageList().put(itemKey,doString.checkString(Double.toString(rs.getDouble("q_wage_unit")),""));
					   itm.getGoodsList().put(itemKey,doString.checkString(Double.toString(rs.getDouble("z_good_price")),""));
					   itm.getCustomGoodsList().put(itemKey,doString.checkString(Double.toString(rs.getDouble("q_good_unit")),""));
					   itm.getBOQList().put(itemKey,nItmJob+":"+Double.toString(rs.getDouble("o_wage"))+":"+Double.toString(rs.getDouble("o_goods")));					   
					   itm.getCommentList().put(itemKey,doString.checkString(doString.DisplayThai(rs.getString("c_itmjob")),""));
					   itm.getAreaList().put(itemKey,doString.checkString(rs.getString("i_itmjob_area"),""));	   
				} // end while
				rs.close();
				
				itm.updateItemSession();
			} // end if check session
			
			
			//----=================== Get Vendor Name & Reject Comment ========================----//
			sql.delete(0,sql.length());
			sql.append(" select trim(d.n_prename_th)||trim(d.n_nemploy_th)||' '||trim(d.n_semploy_th) n_app, ")
			      .append(" b.bus_name,a.* from lan:serv_flow a ")
			      .append(" left join lan:stpvendr b on b.vend_code=a.i_vendor ")
			      .append(" left join lan:useracl c on c.user_id=a.i_approve and c.user_acl='S' ")
			      .append(" left join docflow:acemploy d on d.i_employ=c.i_employ where ")
			      .append(" a.i_docno='").append(iDocNo).append("' ")
			      .append(" and a.i_vendor='").append(iVendor).append("' ")
			      .append(" order by a.f_itmstatus desc ");
			servlog.startLog(sql.toString());
			rs = stmt.executeQuery(sql.toString());
			servlog.endLog();
			if (rs.next()) {
		        vendorName = doString.checkString(doString.DisplayThai(rs.getString("bus_name")),""); 
			    rejectStatus = doString.checkString(rs.getString("f_reject"),"");
			    rejectComment = doString.checkString(doString.DisplayThai(rs.getString("c_reject")),"");
	            rejectComment = str.replace(rejectComment,"|break|","<br>");
	            rejectComment = str.replace(rejectComment," ","&nbsp;"); 	
	            rejectEmploy = doString.checkString(doString.DisplayThai(rs.getString("n_app")),"");
			    
				 Timestamp tmp = rs.getTimestamp("d_approve");
				 if (tmp!=null) {
				     Calendar cal = Calendar.getInstance();
				 	 cal.setTime(tmp);
				     rejectDate = getDateFromCalendar(cal)+" "+getTimeFromCalendar(cal);
			     }
			} // end while
			rs.close();
			//----===========================================================================----//		
			
			
					    
		}
		//-----===================================================================----//
		



		//----======================= Get Customer Details ===========================----//
		if (selProj.indexOf(":")>0) {
		   iCompany = selProj.substring(0,selProj.indexOf(":"));
		   iProject = selProj.substring(selProj.indexOf(":")+1);
		}		
		Hashtable tmpCust = common.getCustomerDetails(iCompany,iProject,iLock);
	    housePlan = doString.checkString((String) tmpCust.get("i_model"),"");
	    houseId = doString.checkString((String) tmpCust.get("i_house"),"");
	    iLock = doString.checkString((String) tmpCust.get("i_lock"),"");
	    iCustomer = doString.checkString((String) tmpCust.get("i_customer"),"");
		guranteeDesc = doString.checkString((String) tmpCust.get("gurantee_desc"),"");
		guranteeDate = doString.checkString((String) tmpCust.get("gurantee_date"),"");
		custName = doString.checkString((String) tmpCust.get("n_customer"),"");
		custTel = doString.checkString((String) tmpCust.get("n_cust_tel"),"");       


		//-----================== check project close or not ===================-----//
		boolean closeProj = false;
		sql.delete(0,sql.length());
		sql.append(" select * from lan:serv_clspj ")
			  .append(" where i_type='01' and i_company='").append(iCompany).append("'  ")
			  .append(" and i_project='").append(iProject).append("'  ");			
		servlog.startLog(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		servlog.endLog();
		if (rs.next()) {
			closeProj = true;
		} else {
			closeProj = false;				
		}
		rs.close();


       //---================ Add , Update , Delete Item List before get to use ===============----//
       ItmJobManagement itm = new ItmJobManagement(request,response);
       itm.updateItemSession(); // update session before use
       
       
       //---======== Get Item Details for show ===========---//
       Vector jobList = itm.getJobList();
       Hashtable jobItm = itm.getItmJobList();
       Hashtable jobVendor = itm.getVendorList();
       Hashtable jobWage = itm.getWageList();
       Hashtable jobCustomWage = itm.getCustomWageList();
       Hashtable jobGoods = itm.getGoodsList();
       Hashtable jobCustomGoods = itm.getCustomGoodsList();
       Hashtable jobBOQ = itm.getBOQList();
       Hashtable jobComment = itm.getCommentList();
       Hashtable jobArea = itm.getAreaList();       
      //---=========================================================================----//

%>

<HTML>
<HEAD>
<TITLE>Open Job - New</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>

<script language="javascript">
<!--
  
  function validateForm(id) {
     var wage = document.forms[0].elements(id+"_wage");
     var goods = document.forms[0].elements(id+"_goods");
     var area = document.forms[0].elements(id+"_area");
     
     if (wage.value=="") {
        alert(" กรุณากรอกจำนวนค่าแรง !");
        wage.focus();
        return false;
     }
     
     if (goods.value=="") {
        alert(" กรุณากรอกจำนวนของ !");
        goods.focus();
        return false;
     }
     
     if (area.value=="") {
        alert(" กรุณาเลือกบริเวณ !");
        area.focus();
        return false;
     }               
     
     return true;
  }
  
  function submitJob() {
     var item = document.forms[0].i_itmjob;     
     if (item==null) {
        alert("คุณต้องมีรายการซ่อม อย่างน้อย 1 รายการ !"); 
        return false; 
     } else {
        if (item.length!=null) {
            for (var i=0;i<item.length;i++) {
                  var id = item[i].value;
                  var result = validateForm(id);
                  if (!result) return false;
            }           
        } else {
           var id = item.value;
           var result = validateForm(id);
           if (!result) return false;
        }
     } // end if check item
     
     document.forms[0].action="<%=Constants.APP_PATH%>/SERV_ContractorConfServlet";
     document.forms[0].submit();
  }  

  
  function removeComma(num) {
     num = ""+num;
     var tmp = "";

     while (num.indexOf(",")>=0) {
         if (num.substring(0,1)!=",") tmp += num.substring(0,1);
         num = num.substring(1);
     }     
     
     if (num.length>0) tmp += num;

     return tmp;
  }
  
  function addComma(number) {  
     number = '' + number;
     
     var precision = "";
     if (number.indexOf(".")>=0) {
         precision = number.substring(number.indexOf(".")+1);
         number = number.substring(0,number.indexOf("."));
     }
     
     if  (number.length > 3) {
          var mod = number.length % 3;
          var output = (mod > 0 ? (number.substring(0,mod)) : '');
          for (i=0 ; i < Math.floor(number.length / 3); i++) {
          if ((mod == 0) && (i == 0))
             output += number.substring(mod+ 3 * i, mod + 3 * i + 3);
          else
             output+= ',' + number.substring(mod + 3 * i, mod + 3 * i + 3);
          }
          
          if (precision.length>0) {
             output = output + "."+precision;
          }
          
          return (output);
   } else {
      if (precision.length>0) {
         number = number + "."+precision;
      }   
      return number;
   }
   
}

  
  function calculate(id,line) {
  
     //---- Calculate Wage ------//
      var wage = document.forms[0].elements(id+"_wage");
      //var wageUnit = document.getElementById("wage_unit_"+line);
      var wageUnit = document.forms[0].elements(id+"_customwage");
      var wageSum = document.getElementById("wage_sum_"+line);      
      var sumWage = 0;      
      if (wage!=null && wageUnit!=null && wageSum!=null) {
         sumWage = (removeComma(wage.value)-0)*(removeComma(wageUnit.value)-0);
         wageSum.innerHTML = addComma(sumWage.toFixed(2));
      }
      
      //----- Calculate Goods ------//
      var goods = document.forms[0].elements(id+"_goods");
      //var goodsUnit = document.getElementById("goods_unit_"+line);
      var goodsUnit = document.forms[0].elements(id+"_customgoods");
      var goodsSum = document.getElementById("goods_sum_"+line); 
      var sumGoods = 0;
      if (goods!=null && goodsUnit!=null && goodsSum!=null) {
         sumGoods = (removeComma(goods.value)-0)*(removeComma(goodsUnit.value)-0);
         goodsSum.innerHTML = addComma(sumGoods.toFixed(2));      
      }
      
      //----- Calculate SubTotal -----//
      var sumTotal = document.getElementById("sum_total_"+line); 
      if (sumTotal!=null) {
         var sum = sumWage+sumGoods;
         sumTotal.innerHTML = addComma(sum.toFixed(2));            
      }
      
      //----- Calculate Total Wage , Total Goods and GrandTotal -----//
      var cnt = 0;
      var sumWageTotal = 0.0;
      var sumGoodsTotal = 0.0;

      while(true) {
         cnt++;
         var subWage = document.getElementById("wage_sum_"+cnt);
         var subGoods = document.getElementById("goods_sum_"+cnt);
         
         if (subWage!=null && subGoods!=null) {
            sumWageTotal += (removeComma(subWage.innerHTML)-0);
            sumGoodsTotal += (removeComma(subGoods.innerHTML)-0);
         } else {
            break;
         }
         
         if (cnt>999) break;
      } // end while
            
      
      //---- Show Total ------//
      var sumGrandTotal = (sumWageTotal+sumGoodsTotal); 
      var showTotalWage = document.getElementById("totalWage");
      var showTotalGoods = document.getElementById("totalGoods");
      var showGrandTotal = document.getElementById("grandTotal");

      showTotalWage.innerHTML = addComma(sumWageTotal.toFixed(2)); 
      showTotalGoods.innerHTML = addComma(sumGoodsTotal.toFixed(2)); 
      showGrandTotal.innerHTML = addComma(sumGrandTotal.toFixed(2)); 

  }
  
 
//-->
</script>

<base target="_self">
</HEAD>

<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">

<FORM METHOD="POST" ACTION="">

<input type='hidden' name='i_docno' value='<%=iDocNo%>'>
<input type='hidden' name='i_vendor' value='<%=iVendor%>'>
<input type="hidden" name="delete_job" value="">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="BD" >
    
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp;
            Contractor : ผู้รับเหมาส่งงาน</td>
          <td width="50%" align="right">&nbsp;
          <!--<a href="#" onclick="viewInform();"><img border="0" src="images/icon_view_IFJ.gif" width="120" height="34"></a>-->
          </td>
        </tr>
      </table>


<br style="font-size:10pt">
                


            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายละเอียดการแจ้งซ่อม</td>
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
    <td class="item ; dotline01" height="22" width="13%">โครงการ :</td>
    <td height="22" width="39%" class="dotline01"><%=doString.DisplayThai(projDesc)%>
    <input type='hidden' name='sel_project' value='<%=selProj%>'>
    </td>
    <td height="22" class="item ; dotline01" width="14%">เลขที่ใบแจ้งซ่อม :</td>
    <td height="22" width="34%" class="dotline01"><%=iDocNo%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">บ้านเลขที่ :</td>
    <td height="22" width="39%" class="dotline01"><%=houseId%></td>
    <td height="22" class="item ; dotline01" width="14%">แปลง :</td>
    <td height="22" width="34%" class="dotline01"><%=iLock%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">แบบบ้าน :</td>
    <td height="22" width="39%" class="dotline01"><%=housePlan%></td>
    <td height="22" class="item ; dotline01" width="14%">&nbsp;</td>
    <td height="22" width="34%" class="dotline01">&nbsp;</td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ชื่อผู้แจ้ง/ลูกค้า :</td>
    <td height="22" width="39%" class="dotline01">
    <%=doString.DisplayThai(common.joinContactAndOwner(nCustomer,custName))%>
    </td>
    <td height="22" class="item ; dotline01" width="14%">โทรศัพท์ติดต่อ :</td>
    <td height="22" width="34%" class="dotline01">
    <%=common.joinContactAndOwner(nCustTel,custTel)%>
    </td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ผู้รับเรื่อง :</td>
    <td height="22" width="39%" class="dotline01"><%=doString.DisplayThai(inFormEmp)%></td>
    <td height="22" class="item ; dotline01" width="14%">วันเวลาที่แจ้ง :</td>
    <td height="22" width="34%" class="dotline01"><%=inFormDate%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">วันที่นัดซ่อม :</td>
    <td height="22" width="39%" class="dotline01"><%=dAppoint%></td>
    <td height="22" class="item ; dotline01" width="14%">วันที่ประมาณการเสร็จ :</td>
    <td height="22" width="34%" class="dotline01"><%=dEstClose%></td>
  </tr>
  <tr>
    <td class="item ; dotline01" height="22" width="13%">ผู้รับเหมาซ่อม :</td>
    <td height="22" width="39%" class="dotline01"><%=vendorName%></td>
    <td height="22" class="item ; dotline01" width="14%">&nbsp;</td>
    <td height="22" width="34%" class="dotline01">&nbsp;</td>
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


 
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">รายการซ่อม</td>
                <td class="item_tab3"></td>
                <td>&nbsp;</td>
              </tr>
            </table>


<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="5" valign="top" bgcolor="#D7E6FF"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
    <td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
    <td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
  </tr>
</table>





<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmL">
    
      <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
          <td width="4%" rowspan="2" class="col_name">No.</td>
          <td width="36%" rowspan="2" class="col_name">รายการซ่อม</td>
          <td width="6%" rowspan="2" class="col_name">หน่วยนับ</td>
          <td colspan="3" class="col_name">ค่าแรง</td>
          <td colspan="3" class="col_name">ค่าของ</td>
          <td width="10%" rowspan="2" class="col_name">รวมเงิน</td>
        </tr>
        <tr>
          <td width="8%" class="col_nameLow">ต่อหน่วย</td>
          <td width="4%" class="col_nameLow">จำนวน</td>
          <td width="10%" class="col_nameLow">รวม</td>
          <td width="8%" class="col_nameLow">ต่อหน่วย</td>
          <td width="4%" class="col_nameLow">จำนวน</td>
          <td width="10%" class="col_nameLow">รวม</td>
        </tr>
        
        <%
        int line = 0;
        DecimalFormat format = new DecimalFormat("#,##0.00");
        double grandTotalWage = 0.00;
        double grandTotalGoods = 0.00;
        double grandTotal = 0.00;

		String key = "";
		String id = "";
		String vendor = "";
		String BOQDesc = "";
		double wageUnit = 0.0;
		double goodsUnit = 0.0;
		
		String itmDesc = "";
		String itmCountUnit = "";
		double wagePrice = 0.00;
		double customWagePrice = 0.00;
		double goodsPrice = 0.00;                
		double customGoodsPrice = 0.00;
		double totalWage = 0.00;
		double totalGoods = 0.00;
		double subTotal = 0.00;
		StringTokenizer boq = null;
        
        for (int i=0;i<jobList.size();i++) {
                line++;
                key = (String) jobList.elementAt(i);
                id = doString.checkString((String) jobItm.get(key),"");
                vendor = doString.checkString((String) jobVendor.get(key),"");
                BOQDesc = doString.checkString((String) jobBOQ.get(key),"");
                wageUnit = Double.parseDouble(doString.checkString((String) jobWage.get(key),"0.0"));
                goodsUnit = Double.parseDouble(doString.checkString((String) jobGoods.get(key),"0.0"));
                
                itmDesc = "";
                itmCountUnit = "";
                wagePrice = 0.00;
                customWagePrice = 0.00;
                goodsPrice = 0.00;                
                customGoodsPrice = 0.00;
                totalWage = 0.00;
                totalGoods = 0.00;
                subTotal = 0.00;
                
                boq = new StringTokenizer(BOQDesc,":");
	            sql.delete(0,sql.length());
	            sql.append(" select * from lan:serv_boq where i_itmjob='").append(id).append("' ");
				servlog.startLog(sql.toString());
	            rs = stmt.executeQuery(sql.toString());
				servlog.endLog();
	            if (rs.next()) {
	                itmDesc = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")),"");
	                itmCountUnit = doString.checkString(doString.DisplayThai(rs.getString("n_count")),"");
	                
	                if (boq.countTokens()==3) {
	                    //---===== Get data from session ======---//
	                    itmDesc = boq.nextToken();
		                wagePrice = Double.parseDouble(boq.nextToken());
		                goodsPrice = Double.parseDouble(boq.nextToken());
		                
		                customWagePrice = Double.parseDouble(doString.checkString((String) jobCustomWage.get(key),"0.00"));
		                customGoodsPrice = Double.parseDouble(doString.checkString((String) jobCustomGoods.get(key),"0.00"));
		                
	                } else {	       
	                   //---====== Load from SERV_BOQ ======--//         
		                wagePrice = rs.getDouble("z_wage_unit"); 
		                goodsPrice = rs.getDouble("z_good_unit"); 
		                customWagePrice = wagePrice;
		                customGoodsPrice = goodsPrice;
		                
		                jobBOQ.put(key,itmDesc+":"+Double.toString(wagePrice)+":"+Double.toString(goodsPrice));
		                jobComment.put(key,itmDesc);
		                jobCustomWage.put(key,Double.toString(customWagePrice));
		                jobCustomGoods.put(key,Double.toString(customGoodsPrice));
		                session.setAttribute(ItmJobManagement.SESSION_BOQ,jobBOQ);
		                session.setAttribute(ItmJobManagement.SESSION_CUSTOM_WAGE,jobCustomWage);
		                session.setAttribute(ItmJobManagement.SESSION_CUSTOM_GOODS,jobCustomGoods);
		                session.setAttribute(ItmJobManagement.SESSION_COMMENT,jobComment);		                
	                } //end if check boq	                
	                
	                totalWage = customWagePrice * (double) wageUnit;
	                totalGoods = customGoodsPrice * (double) goodsUnit;
	                subTotal = totalWage + totalGoods;
	                
	                grandTotalWage += totalWage;
	                grandTotalGoods += totalGoods;
	                grandTotal += subTotal;
	
	            }
	            rs.close();
	                

		        %>
		        <tr>
		          <td width="4%" align="center" class="dotline">
		             <%=line%>
		             <input type="hidden" name="i_itmjob" value="<%=key%>">
		          </td>
		          <td width="36%" class="dotline">
		              <%=itmDesc%>
		              <input type="hidden" name="<%=key+"_vendor"%>" value="<%=vendor%>">
				  </td>
		          <td width="6%" class="dotline" align="center"><%=itmCountUnit%></td>
		          <td width="8%" align="right" class="dotline">
		          <!--<span id="wage_unit_<%=line%>"><%=format.format(wagePrice)%></span>-->
		          <%
		             if (wagePrice==0 || closeProj) {
		                %><input type="text" maxlength="8" class="boxR" style="width:100%" onchange="calculate('<%=key%>','<%=line%>');" name="<%=key%>_customwage" value="<%=format.format(customWagePrice)%>"><%
		             } else {
		                %>
		                <%=format.format(customWagePrice)%>
		                <input type="hidden" name="<%=key%>_customwage" value="<%=format.format(customWagePrice)%>">
		                <%
		             }
		          %>
		          </td>
		          <td width="4%" align="center" class="dotline"><input type="text" maxlength="4" name="<%=key%>_wage" class="boxR" style="width:100%" value="<%=format.format(wageUnit)%>" onchange="calculate('<%=key%>','<%=line%>');"></td>
		          <td width="10%" align="right" class="dotline"><span id="wage_sum_<%=line%>"><%=format.format(totalWage)%></span></td>
		          <td width="8%" align="right" class="dotline">
		          <!--<span id="goods_unit_<%=line%>"><%=format.format(goodsPrice)%></span>-->
		          <%
		             if (goodsPrice==0 || closeProj) {
		                %><input type="text" maxlength="8" class="boxR" style="width:100%" onchange="calculate('<%=key%>','<%=line%>');" name="<%=key%>_customgoods" value="<%=format.format(customGoodsPrice)%>"><%
		             } else {
		                %>
		                <%=format.format(customGoodsPrice)%>
		                <input type="hidden" name="<%=key%>_customgoods" value="<%=format.format(customGoodsPrice)%>">
		                <%
		             }
		          %>		          
		          </td> 
<!--
		          <td width="8%" align="right" class="dotline">
		                <%=format.format(customWagePrice)%>
		                <input type="hidden" name="<%=id%>_customwage" value="<%=customWagePrice%>">
		          </td>
		          <td width="4%" align="center" class="dotline"><input type="text" maxlength="4" name="<%=id%>_wage" class="boxR" style="width:100%" value="<%=wageUnit%>" onchange="calculate('<%=id%>','<%=line%>');"></td>
		          <td width="10%" align="right" class="dotline"><span id="wage_sum_<%=line%>"><%=format.format(totalWage)%></span></td>
		          <td width="8%" align="right" class="dotline">
		                <%=format.format(customGoodsPrice)%>
		                <input type="hidden" name="<%=id%>_customgoods" value="<%=customGoodsPrice%>">          
		          </td>
-->
		          <td width="4%" align="center" class="dotline"><input type="text" maxlength="4" name="<%=key%>_goods" class="boxR" style="width:100%" value="<%=format.format(goodsUnit)%>" onchange="calculate('<%=key%>','<%=line%>');"></td>
		          <td width="10%" align="right" class="dotline"><span id="goods_sum_<%=line%>"><%=format.format(totalGoods)%></span></td>
		          <td width="10%" align="right" class="dotline"><span id="sum_total_<%=line%>"><%=format.format(subTotal)%></span></td>
		        </tr>
		        <%
        } // end for
        
        while (line<Constants.SERV_CONTRACTORCONF_LINE) {
            line++;
		        %>
		        <tr>
		          <td width="4%" align="center" class="dotline">&nbsp;</td>
		          <td width="36%" class="dotline">&nbsp;</td>
		          <td width="6%" class="dotline" align="center">&nbsp;</td>
		          <td width="8%" align="right" class="dotline">&nbsp;</td>
		          <td width="4%" align="center" class="dotline">&nbsp;</td>
		          <td width="10%" align="right" class="dotline">&nbsp;</td>
		          <td width="8%" align="right" class="dotline">&nbsp;</td>
		          <td width="4%" align="center" class="dotline">&nbsp;</td>
		          <td width="10%" align="right" class="dotline">&nbsp;</td>
		          <td width="10%" align="right" class="dotline">&nbsp;</td>
		        </tr>
				<%
		} // end while
		%>
        <tr>
          <td width="4%" align="center" class="dotline">&nbsp;</td>
          <td width="36%" class="dotline">&nbsp;</td>
          <td width="6%" class="dotline" align="center">&nbsp;</td>
          <td width="8%" align="right" class="dotline ; item">&nbsp;</td>
          <td width="4%" align="right" class="dotline ; item">&nbsp;</td>
          <td width="10%" align="right" class="dotline ; item"><span id="totalWage"><%=format.format(grandTotalWage)%></span></td>
          <td width="8%" align="right" class="dotline ; item">&nbsp;</td>
          <td width="4%" align="right" class="dotline ; item">&nbsp;</td>
          <td width="10%" align="right" class="dotline ; item"><span id="totalGoods"><%=format.format(grandTotalGoods)%></span></td>
          <td width="10%" align="right" class="dotline ; item"><span id="grandTotal"><%=format.format(grandTotal)%></span></td>
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


<%
   if (jobList.size()>0) {
%>
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">หมายเหตุ</td>
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
        <%
        line = 0;
		String jid = "";
		String comment = "";
		String area = "";
        for (int i=0;i<jobList.size();i++) {
                line++;
                jid =  doString.checkString((String) jobList.elementAt(i),""); 
                comment = doString.checkString((String) jobComment.get(jid),"");                
                area = doString.checkString((String) jobArea.get(jid),"");                
                %>
				  <tr>
				    <td class="item ; dotline01" height="22" width="12%">รายการที่ <%=line%> :</td>
				    <td height="22" width="76%" class="dotline01"><input type="text" name="<%=jid%>_comment" class="box" style="width:100%" size="20" maxlength='200'  value="<%=comment%>"></td>
				    <td height="22" width="12%" class="dotline01"><%=common.genAreaList(jid+"_area",area," class='box' style='width:100%' ")%></td>
				  </tr>
                <%
         } // end for
        
        while (line<Constants.SERV_CONTRACTORCONF_LINE) {
            line++;
		        %>
				  <tr>
				    <td class="item ; dotline01" height="22" width="12%">&nbsp;</td>
				    <td height="22" width="76%" class="dotline01">&nbsp;</td>
				    <td height="22" width="12%" class="dotline01">&nbsp;</td>
				  </tr>
				<%
		  } // end while
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

<%
   } // end if check jobList
%>


<%

   if (rejectStatus.equalsIgnoreCase("Y") || rejectComment.length()>0) {
			%>
			<br style="font-size:10pt">
			
			            <table border="0" width="100%" cellspacing="0" cellpadding="0">
			              <tr>
			                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
			                <td class="item_tab2" width="160">หมายเหตุการ Reject</td>
			                <td class="item_tab3"></td>
			                <td class="textgray">&nbsp; โดย <%=rejectEmploy+" &nbsp; เมื่อวันที่ "+rejectDate%></td>                
			              </tr>
			            </table>
			
			
			
			<table border="0" width="100%" cellspacing="0" cellpadding="0">
			  <tr>
			    <td width="5" valign="top"><img border="0" src="images/Corn01.gif" width="5" height="5"></td>
			    <td class="frmTop">&nbsp;</td>
			    <td width="5" valign="top" align="right"><img border="0" src="images/Corn02.gif" width="5" height="5"></td>
			  </tr>
			</table>
			
			<table border="0" width="100%" cellspacing="0" cellpadding="0" style="height:100px">
			  <tr>
			    <td width="100%" class="frmLRpad01" valign="top"><%=rejectComment%></td>
			  </tr>
			</table>
			
			<table border="0" width="100%" cellspacing="0" cellpadding="0">
			  <tr>
			    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
			    <td class="frmBottom">&nbsp;</td>
			    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
			  </tr>
			</table>
			<%
   }
%>


<br style="font-size:10pt">



        <table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="230" class="act_tab2">

            <img border="0" src="images/act_submit.gif"  onclick="submitJob();"                                
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="cursor:hand;FILTER: alpha(opacity=70)" width="70" height="27">&nbsp;
            <!--<img border="0" src="images/act_add.gif"  onclick="addJobList();"
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="cursor:hand;FILTER: alpha(opacity=70)" width="70" height="27">&nbsp;
            <img border="0" src="images/act_delete.gif"  onclick="deleteJob();"
    			onmouseout=nereidFade(this,70,50,5)    
                  	onmouseover=nereidFade(this,100,50,5)     
                  	style="cursor:hand;FILTER: alpha(opacity=70)" width="70" height="27">-->

            </td>   
                  	
                  	
            <td class="act_tab3"></td>   
            <td class="act_tab4"><a href="<%=Constants.APP_PATH%>/SERV_Contractor_List.jsp"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp;
              <a href="<%=Constants.APP_HOME%>" target="_top"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>  
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
		System.out.println("ERROR SERV_Contractor_Conf.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		// Clean up.
		try {
			if (rs != null) rs.close();
			if (stmt != null) stmt.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>