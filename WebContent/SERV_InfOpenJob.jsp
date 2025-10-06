<%@page language="java" contentType="text/html; charset=TIS-620" pageEncoding="TIS-620"%>
<%@page import="java.util.*"%>
<%@page import="java.text.*"%>
<%@page import="java.io.*"%>
<%@page import="com.lh.util.*"%>
<%@page import="serv.common.*"%>
<%@page import="serv.model.ServInfOpenJobBean"%>
<%@page import="serv.model.ListInfOpenJobBean"%>
<%@ include file="confirmLogin.jsp" %>
<%@ include file="function.jsp"%> 
<jsp:useBean id="beanOpenJob" scope="request" class="serv.model.ListInfOpenJobBean" />
<%    

	//------------- userlogin session ------------//
	String sessionId = user.getsessionId();	if (sessionId==null) sessionId = "";
	session.setAttribute("session_upload_id",sessionId);
	
	String companyId = user.getCompanyId();	String userId = user.getUserID(); 
	String userGroup = doString.checkString(user.getUserGroup());
	String team = "01";
	if (userGroup.equals("H")) { //HOME
		team = "02";
	} else if (userGroup.equals("I")) { //INFRA
		team = "01";
	} else if (userGroup.equals("A")) { //ALL
		team = "01";
	}	String DATE_FORMAT_NOW = "yyyy-MM-dd_HH-mm-ss-SSS";
	String who = user.getUserWho();
	Calendar rightNow = Calendar.getInstance(Locale.ENGLISH);
	String cur_year = Integer.toString(rightNow.get(Calendar.YEAR)+543);	
	String empId = user.getEmpId();
	String jName = "SERV_InfOpenJob.jsp";
	String defaItmType = "";
	String itmDesc = "";
	//out.println("userId="+userId+" companyId="+companyId+" empId="+empId);
	
	//--------------- sql connection ----------------//
	DecimalFormat format = new DecimalFormat("#,##0.00");
	StringBuffer sql = new StringBuffer();
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	SERV_CommonData common = null;
	boolean BOQApprove = false;
	   
	try {
	    doString str = new doString();
	
        //----============ Initialize Variable ============----//
		if (ds == null) getDS();
		conn = ds.getConnection();
		conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
		conn.setAutoCommit(true);
		stmt = conn.createStatement();       
		common = new SERV_CommonData(conn); 
		
		//------------- page valiable ----------------//
		String mode = "";			//new ,edit
				String init = doString.checkString(request.getParameter("init"),"");
/*		
		String realPath = getServletContext().getRealPath("/");
		String tempPath = realPath + "/attach/temp/"+sessionId;
		if (init.equals("true")) {
			user.setFileNo(1);
			//----- clear temp upload path -----//
			File delFolder = new File(tempPath);
			if (delFolder.exists() && delFolder.isDirectory()) {
				File[] listTmp = delFolder.listFiles();
				if (listTmp!=null) {
					for (int f=0;f<listTmp.length;f++) {
						listTmp[f].delete();	
					} // end for
				}
			}			
		}//init
*/		
		String actionMode = doString.checkString(request.getParameter("actionMode"),""); 
		String approveManager = doString.checkString(request.getParameter("approveManager"),""); ;	//ผู้อนุมัติ    M,Z
		//out.println(actionMode);
		
		String n_service_employ = common.getBOQServiceEmployeeName(empId);	//ชื่อพนักงานเปิด job,ผู้ขออนุมัติ
		String n_position_employ = common.getUserWhoBOQ(userId);			//ตำแหน่งผู้ขออนุมัติ
		double amount = common.getAmount();									//วงเงินที่กำหนด if (sum<amount)approveManager=M; else approveManager = Z 
		//out.println(amount);
		
		
		String i_docno = "";
		String n_project = "";
		String sel_projrct = "";
		String i_approver = "";
		String d_appoint = "";
		String d_est_close = "";
		java.util.Date today = new java.util.Date();
		SimpleDateFormat formatter = new SimpleDateFormat("dd/MM/yyyy", new Locale("th","TH"));
		ArrayList listBean = new ArrayList();
		ServInfOpenJobBean openJobBean = new ServInfOpenJobBean();
		ListInfOpenJobBean listInfOpenJobBean = new ListInfOpenJobBean();
		int index = 1;
		if(request.getSession().getAttribute("listOpenJob")!=null){
			openJobBean = (ServInfOpenJobBean)request.getSession().getAttribute("listOpenJob");
			openJobBean.setI_company(companyId);								//รหัสบริษัท
			openJobBean.setI_service_employ(empId);								//รหัสพนักงาน
			openJobBean.setN_service_employ(n_service_employ);					//ชื่อพนักงาน
			openJobBean.setN_position_employ(n_position_employ);				//ตำแหน่ง
			openJobBean.setP_amount(amount);									//วงเงินที่กำหนด
			
			mode = openJobBean.getMode();										//save mode e=edit,new = create
			i_docno = openJobBean.getI_docno();									//i_docno
			if(openJobBean.getI_project().length()>0){
				companyId = openJobBean.getI_project().substring(0,2);				//รหัสบริษัท
				sel_projrct = openJobBean.getI_project().substring(3,6);			//รหัสโครงการ
			}
			n_project = openJobBean.getI_project()+"-"+openJobBean.getN_project();								//ชื่อโครงการ
			i_approver = openJobBean.getI_approver();							//ผู้อนุมัติ
			d_appoint  = openJobBean.getD_appoint();							//วันที่นัดซ่อม
			d_est_close = openJobBean.getD_est_close();							//วันที่ประมาณการเสร็จ

			defaItmType = openJobBean.getI_itmtype();					//ประเภทรายการ INF, PUB

			listBean  = openJobBean.getListInfBoq();
			
		}		
		if (d_appoint.equals("")) {
			d_appoint = formatter.format(today);
		}
		if (d_est_close.equals("")) {
			d_est_close = formatter.format(today);
		}
		if (defaItmType.equals("")) {
			defaItmType = doString.checkString(request.getParameter("i_itmtype"));
		}
		if (defaItmType.equals("02")) {
			itmDesc = "สาธารณะ";
		} else {
			itmDesc = "สาธารณู";
		}
		
		String managerList = common.getApproverList(companyId, sel_projrct, "M", team);				String zoneList = common.getApproverList(companyId, sel_projrct, "Z", team);
		if (who.equals("M")) {
			managerList = zoneList;
		}
		String allotType = "";
			//-- Get Allot Type ---//
			rs = stmt.executeQuery("SELECT d_effective, i_type FROM lan:serv_allot WHERE i_company = '"+companyId+"' AND i_project = '"+sel_projrct+"' AND d_effective <= TODAY ORDER BY d_effective DESC");
			if (rs != null) {
				if (rs.next() == true) {
					allotType = doString.checkString(rs.getString("I_TYPE"));
				}
				rs.close();
				rs=null;
			}	
%>
<HTML>
<HEAD>
<TITLE> เปิดใบสั่งงานซ่อมสาธารณะ /สาธารณู|Open Job - New</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">

<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<script language="javascript" src="NumberUtil.js"></script><!--   for upload -->
<script language="javascript" src="resources/js/iupload.js"></script>


<!-- add by pradoem 2023.02.15 -->
<script src="jquery3/jquery.min3.6.3.js" ></script>
<script src="jquery3/loadingoverlay.min2.1.7.js"></script>


<script language="javascript">
<!--
	 function pleaseWaiting(){
	   $.LoadingOverlay("show");
		// Hide it after 3 seconds
		setTimeout(function(){
		    $.LoadingOverlay("hide");
		}, 3000);
	  }
	function isCurrencyKey(oEvent, uns){
    	var charCode;
    	if (window.event) charCode = window.event.keyCode;
    	else if (oEvent) charCode = oEvent.which;
    	var reNum = /(\d|\.|,|-)/;
    	if(uns) reNum = /(\d|\.|,)/;
    	if(!reNum.test(String.fromCharCode(charCode)))
       		return false;
    	
    	return true;
	}

    function viewInform() {
        if (document.forms[0].mode.value.toUpperCase()=="ADD") {
           alert("Inform Job ของใบนี้ยังไม่ได้ถูกสร้าง !");
        } else {
           pleaseWaiting();
           document.forms[0].action="SERV_InfJob_Disp.html?load=no";
           document.forms[0].submit();
        }
    }

  function submitJob() {
	if(document.getElementById("sel_project")!=null && document.getElementById("sel_project").value==""){
		alert("กรุณาเลือกโครงการ !");
		document.getElementById("sel_project").focus();
		return false;
	}

     var dAppoint = document.forms[0].d_appoint;
     var dEstClose = document.forms[0].d_est_close;

     if (dAppoint.value=="") {
        alert(" กรุณาระบุวันที่นัดซ่อม !");
        dAppoint.focus();
        return false;
     } else {
        if (!checkFormatDate(dAppoint.value)) {
           dAppoint.focus();
           return false;
        }
     }

     if (dEstClose.value=="") {
        alert(" กรุณาระบุวันที่คาดว่าจะเสร็จ !");
        dEstClose.focus();
        return false;
     } else {
        if (!checkFormatDate(dEstClose.value)) {
           dEstClose.focus();
           return false;
        }
     }

     var yearApp = parseInt(dAppoint.value.substring(6,10),10);
     if (yearApp>2400) yearApp-=543;
     var yearClose = parseInt(dEstClose.value.substring(6,10),10);
     if (yearClose>2400) yearClose-=543;
	
	 var dApp = new Date(yearApp,parseInt(dAppoint.value.substring(3,5),10)-1,dAppoint.value.substring(0,2),23,59,59);
	 var dClose = new Date(yearClose,parseInt(dEstClose.value.substring(3,5),10)-1,dEstClose.value.substring(0,2),23,59,59);
	 var dCurrent = new Date();

	 if (dCurrent>dApp) {
	    alert("วันที่นัดซ่อมต้องไม่น้อยกว่าวันปัจจุบัน !");
            dAppoint.focus();
            return false;
	 }

	 if (dApp>dClose) {
	    alert("วันที่ประมาณการเสร็จต้องไม่น้อยกว่าวันที่นัดซ่อม !");
            dEstClose.focus();
            return false;
	 }
   //console.log("11111111");
     var item = document.forms[0].i_itmjob;
     if (document.getElementsByName("i_itmjob").length==0) {
        alert("คุณต้องทำการเพิ่มรายการซ่อม อย่างน้อย 1 รายการ !");
        return false;
     } 
   //console.log("222222");
     if (document.getElementsByName("i_itmjob").length>0) {
		for (var i=0; i<document.getElementsByName("i_itmjob").length; i++) {
			if(document.getElementsByName("itmtype")[i].value==""){
				alert("รายการซ่อม No."+(i+1)+"ไม่พบประเภทงาน !");
				return false;
			}
			if(document.getElementsByName("vendor")[i].value==""){
				alert("รายการซ่อม No."+(i+1)+"กรุณาเลือกผู้รับเหมาซ่อม !");
				document.getElementsByName("vendor")[i].focus();
				return false;
			}
			if(document.getElementsByName("estimate")[i].value==0){
/*
				if(document.getElementsByName("customwage")[i].value==0){
					alert("รายการซ่อม No."+(i+1)+"กรุณากรอกค่าแรงต่อหน่วย!");
					document.getElementsByName("customwage")[i].focus();
					
					return false;
				}			
				if(document.getElementsByName("wage")[i].value==0){
					alert("รายการซ่อม No."+(i+1)+"กรุณากรอกจำนวนค่าแรง!");
					document.getElementsByName("wage")[i].focus();
					return false;
				}
				if(document.getElementsByName("customgoods")[i].value==0){
					alert("รายการซ่อม No."+(i+1)+"กรุณากรอกค่าของต่อหน่วย!");
					document.getElementsByName("customgoods")[i].focus();
					return false;
				}				
				if(document.getElementsByName("goods")[i].value==0){
					alert("รายการซ่อม No."+(i+1)+"กรุณากรอกจำนวนค่าของ!");
					document.getElementsByName("goods")[i].focus();
					return false;
				}
				*/
			} else {
				if(document.getElementsByName("filename")[i].value==""){
					alert("รายการซ่อม No."+(i+1)+"กรุณาแนบไฟล์");
					return false;
				}
			}			
		}
     }
    //console.log("3333");
	if(document.getElementById("approver").value==""){
		alert("กรุณาเลือกผู้อนุมัติ !");
		document.getElementById("approver").focus();
		return false;
	}
	//console.log("44444");
	return true;	
  }


  function deleteJob() {
     var selId = false;
     var item = document.forms[0].del_checkbox;

     if (item!=null) {
         if (item.length!=null) {
            for (var i=0;i<item.length;i++) {
                  if (item[i].checked) {
                     selId = true;
                     break;
                  }
            }
         } else {
            selId = item.checked;
         }
     }

     if (!selId) {
        alert("คุณยังไม่ได้ทำการเลือกรายการที่ต้องการลบ !");
        return false;
     }

     if (confirm("คุณแน่ใจว่าต้องการลบรายการซ่อมที่เลือก ?")) {
       return true;
     }
  }

  function  checkAll(obj,mainCheck,subCheck) {
     var main = document.forms[0].elements[mainCheck];
     var sub = document.forms[0].elements[subCheck];

     if (obj!=null && main!=null && sub!=null) {

         if (obj.name==mainCheck) {
		    if (sub.length!=null) {
				for (var i=0;i<sub.length;i++) {
					  sub[i].checked = obj.checked;
				}
			}
			else {
			   sub.checked = obj.checked;
			}
         } else {
		    if (sub.length!=null) {
			    var flag = true;
				for (var i=0;i<sub.length;i++) {
					  flag = sub[i].checked;
					  if (!flag) break;
				}
				main.checked = flag;
			} else {
			   main.checked = obj.checked;
			} // end if check sub
         } // end if check mainCheck
     } // end if check null
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

function setGoodsPrice(id) {
      var wage = document.forms[0].elements(id+"_wage");
      var goods = document.forms[0].elements(id+"_goods");
      if (wage!=null && goods!=null) {
         goods.value=wage.value;
      }
}

	function convertDateFormat(dateObj) {
	   if (dateObj==null) return false;

		var countSlash = 0;
	    for (var i=0;i<dateObj.value.length;i++) {
		       if (dateObj.value.charAt(i)=='/') countSlash++;
		} // end for

		if (countSlash!=2) {
		    alert("รูปแบบวันที่ไม่ถูกต้อง!");
		    dateObj.focus();
		    return false;
		}

	    var splitDate = dateObj.value.split("/");
		var day = 0;
		var month = 0;
		var year = 0;

		try {
		    day = parseInt(splitDate[0],10);
		    month = parseInt(splitDate[1],10);
		    year = parseInt(splitDate[2],10);
		} catch (e) {
		   alert("วันที่ไม่ถูกต้อง!");
		   dateObj.focus();
		   return false;
		}

		if (day>=1 && day<=31) {
		    if (month>=1 && month<=12) {

		    if (isNaN(year) || (year>=100 && year<=999)) {
		        alert("กรุณาใส่ปีเป็นรูปแบบ yy หรือ yyyy เท่านั้น!");
			dateObj.focus();
			return false;
		      }

			   //----- Convert to BC. -------//
			   if (year<45) year += 2543;
			   if (year>=45 && year<100) year += 2500;
			   if (year<2400) year += 543;

			    var dateStr = (day<10 ? "0"+day : day)+"/"+(month<10 ? "0"+month : month)+"/"+year;
	                    dateObj.value = dateStr;

				if (!checkFormatDate(dateStr)) {
				    dateObj.focus();
				    return false;
				}

			} else {
			   alert("เดือนต้องมีค่าระหว่าง 1 - 12 เท่านั้น!");
			   dateObj.focus();
			   return false;
			}
		} else {
		   alert("วันที่ต้องมีค่าระหว่าง 1 - 31 เท่านั้น!");
		   dateObj.focus();
		   return false;
		}

	}

	function checkFormatDate(str)
	{
		mystring = str;
		if (mystring.match(/(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.]([1-9])\d\d\d/ ) ) {
		   var yyyy = parseInt(str.substring(6,10),10);
		   var mm = parseInt(str.substring(3,5),10)-1;
		   var dd = parseInt(str.substring(0,2),10);
		   if (yyyy>2400) yyyy -= 543;

	       var cdate = new Date(yyyy,mm,dd);
		   if (mm!=cdate.getMonth()) {
		      alert("วันที่ไม่ถูกต้อง , กรุณาตรวจสอบอีกครั้ง !");
		      return false;
		   }
		} else {
			alert("รูปแบบวันที่ไม่ถูกต้อง !");
			return false;
		}

		return true;
	}

//-------------------------------------	
	function back(){
	    pleaseWaiting();
		document.forms[0].actionMode.value = "back";
	   	document.forms[0].method = "post";
	   	document.forms[0].action = "/LHServ/ServOpenJob";
       	document.forms[0].submit();
	}
	
	function goHome(){
	    pleaseWaiting();
		document.forms[0].actionMode.value = "home";
	   	document.forms[0].method = "post";
	   	document.forms[0].action = "/LHServ/ServOpenJob";
       	document.forms[0].submit();
	}
	
	function saveOpenJob(){
		if(submitJob()){
		    pleaseWaiting();
			document.forms[0].actionMode.value = "saveOpenJob";
	   		document.forms[0].method = "post";
	    	document.forms[0].action = "/LHServ/ServOpenJob";
       		document.forms[0].submit();
		}
	}
	
	function sendToApprove(){
	    //console.log("--->:"+submitJob());
		if(submitJob()){
		    pleaseWaiting();
			document.forms[0].actionMode.value = "sendToApprove";
	   		document.forms[0].method = "post";
	    	document.forms[0].action = "/LHServ/ServOpenJob";
       		document.forms[0].submit();
		}
	}
	
	function prepareForm(){
	    pleaseWaiting();
		document.forms[0].actionMode.value = "prepareForm";
	   	document.forms[0].method = "post";
	    document.forms[0].action = "/LHServ/ServOpenJob";
       	document.forms[0].submit();
	}
	
	function addJobList(){
	    pleaseWaiting();
		document.forms[0].actionMode.value = "addJobList";
	   	document.forms[0].method = "post";
	   	document.forms[0].action = "/LHServ/ServOpenJob";
       	document.forms[0].submit();
       	
	}
	
	function deleteItem(){
		if(deleteJob()){
		    pleaseWaiting();
			document.forms[0].actionMode.value = "deleteItem";
	 		document.forms[0].action="/LHServ/ServOpenJob";
       		document.forms[0].submit();
		}
	}

	//------------------------------
	 var windowObjectReference = null;
	function openUploadWindow2(contextPath,sessionId, itmNo, keyFile) {
		if (contextPath.length>0 && contextPath.substring(contextPath.length-1)!="/") 	{
		    contextPath += "/";
		}	
		var keys = new Array();
		keys[0] = sessionId; 
		keys[1] = itmNo;
		keys[2] = keyFile;
		var vReturnValue = window.open(contextPath+"iupload_main.jsp?session_id="+sessionId+"&itmNo="+itmNo+"&key_file="+keyFile,keys,"Left=100,Top=100,width=400,height=280; center: Yes; resizable: No; status: No;");
		return vReturnValue;
   }
	
   function openUploadWin(itmNo, keyFile) { 	   
  	     if(windowObjectReference == null || windowObjectReference.closed){
  	   		  windowObjectReference = openUploadWindow2('<%=request.getContextPath()%>','<%=sessionId%>',itmNo, keyFile); 	    
  	    }else{
  	   		windowObjectReference.focus();
  	    }
		// Create IE + others compatible event handler
		var eventMethod = window.addEventListener ? "addEventListener" : "attachEvent";
		var eventer = window[eventMethod];
		var messageEvent = eventMethod == "attachEvent" ? "onmessage" : "message";

		// Listen to message from child window
		 eventer(messageEvent,function(e) {
			 //console.log('origin: ', e.origin)
			 //alert(e.data);
			 if( e.origin == 'http://localhost:9080' ||  e.origin == 'http://132.146.1.92' || e.origin == 'http://132.146.1.126' || e.origin == 'https://portal.lh.co.th' ){
				  console.log('popup message!: ', e.data);
				  //attachFileCallback(e.data);
			      if (e.data==="OK") {
			        pleaseWaiting();
					document.forms[0].actionMode.value = "prepareForm";
					document.forms[0].method = "post";	   
					document.forms[0].action="/LHServ/ServOpenJob";
					document.forms[0].submit();
			      }	      
			  } 
		}, false);
   }	
  	   /*
  	   old
  	   var result = openUploadWindow2('<%=request.getContextPath()%>','<%=sessionId%>',itmNo, keyFile);
	   if (result=="OK") {
	         pleaseWaiting();
			document.forms[0].actionMode.value = "prepareForm";
			document.forms[0].method = "post";	   
			document.forms[0].action="/LHServ/ServOpenJob";
			document.forms[0].submit();
	   }*/
	   
   //------------------------------	
 
	function clearEstimate(line, wage_boq, goods_boq){		if(document.getElementsByName("estimate")[line].value>0){
			if (wage_boq == "false") {				document.getElementsByName("customwage")[line].value = addComma(formatCurrency(0));			}
			document.getElementsByName("wage")[line].value = addComma(formatCurrency(0));			document.getElementsByName("wage_sum")[line].value = addComma(formatCurrency(0));
			if (goods_boq == "false") {				document.getElementsByName("customgoods")[line].value = addComma(formatCurrency(0));			}
			document.getElementsByName("goods")[line].value = addComma(formatCurrency(0));			document.getElementsByName("goods_sum")[line].value = addComma(formatCurrency(0));		}		calculate(line);	}
	
	//---------
	function populate(selected) {
		var selectedArray =null;
		var managerArray;
		var zoneArray;
		var typeArray =  new Array("('<--------------------<','',true,true)");
		var managerList = document.forms[0].managerList.value;
		var zoneList = document.forms[0].zoneList.value;
		var i=0;
		
		managerArray = managerList.split("|");
		zoneArray = zoneList.split("|");
		
		selectedArray = eval(selected + "Array");
		while (selectedArray.length < document.forms[0].approver.options.length) {
			document.forms[0].approver.options[(document.forms[0].approver.options.length - 1)] = null;
		}
		
		for(i=0; i < selectedArray.length; i++){
			document.forms[0].approver.options[i]=null;
		}
	
		for (i=0; i < selectedArray.length; i++) {
			if(selectedArray[i]!="")
				eval("document.forms[0].approver.options[i]=" + "new Option" + selectedArray[i]);
		}
		
		if (selected == "zone") {
			if (document.forms[0].team.value == "I") {
				eval("document.forms[0].approver.options[i] = new Option('0826-0 นาย เชวงเกียรติ ศรุตชีวิน','0826-0')");
			}
		}
	}

	
	function copyValue(line){

		var wage = document.getElementsByName("wage");
		var goods = document.getElementsByName("goods");
		var wageValue = removeComma(wage[line].value);
		var goodsValue = removeComma(goods[line].value);
		goods[line].value = addComma(formatCurrency(wageValue));
	}	

	
	function calculate(line){
		//--------------
		var customwage = document.getElementsByName("customwage");		var customwageValue = removeComma(customwage[line].value);		var wage = document.getElementsByName("wage");		var wageValue = removeComma(wage[line].value);

		document.getElementsByName("customwage")[line].value = addComma(formatCurrency(customwageValue));
		document.getElementsByName("wage")[line].value = addComma(formatCurrency(wageValue));
		document.getElementsByName("wage_sum")[line].value = addComma(formatCurrency(customwageValue*wageValue));
		

		//---------------
		var customgoods = document.getElementsByName("customgoods");
		var customgoodsValue = removeComma(customgoods[line].value);
		var goods = document.getElementsByName("goods");
		var goodsValue = removeComma(goods[line].value);
		var sum_wage = customwageValue * wageValue;		var sum_goods = customgoodsValue * goodsValue;
	
		document.getElementsByName("customgoods")[line].value = addComma(formatCurrency(customgoodsValue));
		document.getElementsByName("goods")[line].value = addComma(formatCurrency(goodsValue));
		document.getElementsByName("goods_sum")[line].value = addComma(formatCurrency(customgoodsValue*goodsValue));
				document.getElementsByName("estimate")[line].value = addComma(formatCurrency(document.getElementsByName("estimate")[line].value));
		var estimate = document.getElementsByName("estimate");		var estimateValue = removeComma(estimate[line].value);		//--- clear estimate ---//
		//if(customwageValue>0 | wageValue>0 | customgoodsValue>0 | goodsValue>0 ){		if(sum_wage > 0 || sum_goods > 0){
			document.getElementsByName("estimate")[line].value = addComma(formatCurrency(0));		}

		//--- sumtTotalWage ---//
		var sumtTotalWage = 0;
		for (var i=0 ; i < document.getElementsByName("wage_sum").length ; i++) {
			sumtTotalWage+= removeComma(document.getElementsByName("wage_sum")[i].value) * 1;
		}
		document.forms[0].totalWage.value = addComma(formatCurrency(sumtTotalWage));
		
		//--- sumtTotalGoods ---//
		var sumtTotalGoods = 0;
		for (var i=0 ; i < document.getElementsByName("goods_sum").length ; i++) {
			sumtTotalGoods+= removeComma(document.getElementsByName("goods_sum")[i].value) * 1;
		}
		document.forms[0].totalGoods.value = addComma(formatCurrency(sumtTotalGoods));

		//--- sumEstimate ---//
		var sumEstimate = 0;
		for (var i=0 ; i < document.getElementsByName("estimate").length ; i++) {
			sumEstimate+= removeComma(document.getElementsByName("estimate")[i].value) * 1;
		}
		document.forms[0].totalEstimate.value = addComma(formatCurrency(sumEstimate));

		//--- sum total --//
		document.getElementsByName("sum_total")[line].value = addComma(formatCurrency((customwageValue*wageValue)+(customgoodsValue*goodsValue)+(estimateValue*1)));
		

		//--sum grandTotal ---//
		var sumGrandTotal = 0;
		sumGrandTotal = sumtTotalWage+sumtTotalGoods+sumEstimate;
		document.forms[0].grandTotal.value = addComma(formatCurrency(sumGrandTotal));
		//var amount = document.getElementById("amount").value*1;
		var amount = $("#amount").val()*1; 		if (sumEstimate > 0) {
			populate("zone");
		} else {			if(sumGrandTotal>0 && sumGrandTotal<= amount){				populate("manager");			} else if(sumGrandTotal>amount){				populate("zone");			}		}
	}
//-->
</script>
<base target="_self">
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0">
<FORM method="post" ACTION="/LHServ/ServOpenJob">
<input type="hidden" name="i_itmtype" value="<%=defaItmType%>">
<input type="hidden" name="team" value="<%=userGroup%>">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
  	<tr>  
    	<td width="100%" class="BD" >
      		<table border="0" width="100%" cellspacing="0" cellpadding="0">
	        	<tr>
	            	<td width="50%" class="bigh"><img border="0" src="images/i_home.gif" align="absmiddle" width="20" height="20">&nbsp; เปิดใบสั่งงานซ่อม<%=itmDesc%></td>
	          		<td width="50%" align="right"></td>
	        	</tr>
	      	</table>
			<br style="font-size:10pt">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              	<tr>
	                <td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
	                <td class="item_tab2" width="200">รายละเอียดการสั่งงานซ่อม</td>
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
								<td height="22" width="39%" class="dotline01"> 
									<%if(mode.equalsIgnoreCase("E")){
										out.println(n_project);
									}else{
									%>
									<%=common.genBOQProject(userId,"sel_project",openJobBean.getI_project(),cur_year," class='box' style='width:250px' onchange='prepareForm();' ")%>
									<%} %>
									<input type="hidden" name="i_project"  value="<%=openJobBean.getI_project()%>">
								</td>
								<td height="22" class="item ; dotline01" width="14%">เลขที่ใบสั่งงานซ่อม :</td>
								<td height="22" width="34%" class="dotline01"> <span style="width:100px"><%=i_docno%><%if(i_docno.equals(""))out.print("Auto Generated"); %></span> </td>
				         	</tr>
				          	<tr> 
				                  <td class="item ; dotline01" height="22" width="13%">ชื่อผู้แจ้ง 
				                    :</td>
				                  <td height="22" width="39%" class="dotline01">
				                  	<%out.println(n_service_employ);%>
				                  </td>
				                  <td height="22" class="item ; dotline01" width="14%">วันเวลาที่แจ้ง 
				                    :</td>
				                  <td height="22" width="34%" class="dotline01"><%= getDateFromCalendar(Calendar.getInstance())%>&nbsp;<%=getTimeFromCalendar(Calendar.getInstance()) %>
				                  </td>
				       		</tr>
				   			<tr>
				   				<td class="item ; dotline01" height="22" width="13%">วันที่นัดซ่อม :</td>
				   				<td height="22" width="39%" class="dotline01"> 
				   					<input type="text" onchange="convertDateFormat(this);" name="d_appoint" style="width:120px" class="box" value="<%=d_appoint%>">
				                    &nbsp; (d/m/yy หรือ dd/mm/yyyy)</td>
								<td height="22" class="item ; dotline01" width="14%">วันที่ประมาณการเสร็จ :</td>
								<td height="22" width="34%" class="dotline01"> 
									<input type="text" onchange="convertDateFormat(this);" name="d_est_close" style="width:120px" class="box" value="<%=d_est_close%>">
				                    &nbsp; (d/m/yy หรือ dd/mm/yyyy)</td>
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
                  				<td width="2%" rowspan="2" class="col_name"> 
                    				<input type="checkbox" name="main_check" onclick="checkAll(this,'main_check','del_checkbox');">
                  				</td>
                  				<td width="3%" rowspan="2" class="col_name">No.</td>
			                  	<td width="15%" rowspan="2" class="col_name">รายการซ่อม</td>
			                  	<td width="6%" rowspan="2" class="col_name">หน่วยนับ</td>
			                  	<td width="6%" rowspan="2" class="col_name">ประเภทงาน</td>
			                  	<td width="12%" rowspan="2" class="col_name">ผู้รับเหมาซ่อม</td>
			                  	<td colspan="3" class="col_name">ค่าแรง</td>
			                  	<td colspan="3" class="col_name">ค่าของ</td>
			                  	<td width="8%" rowspan="2" class="col_name">ประมาณการ<br>คชจ.ซ่อม</td>
			                  	<td width="8%" rowspan="2" class="col_name">รวมเงิน</td>
                			</tr>
                			<tr> 
                  				<td width="8%" class="col_nameLow">ต่อหน่วย</td>
			                  	<td width="4%" class="col_nameLow">จำนวน</td>
			                  	<td width="8%" class="col_nameLow">รวม</td>
			                  	<td width="8%" class="col_nameLow">ต่อหน่วย</td>
			                  	<td width="4%" class="col_nameLow">จำนวน</td>
			                  	<td width="8%" class="col_nameLow">รวม</td>
                			</tr>
							<!-- data list job item-->
							<% 
							
							if(listBean.size()>0){	
								double totalWage = 0.0;
								double totalGoods = 0.0;
								double totalEstimate = 0.0;
								double grandTotal = 0.0;
								String com_acc = "";
								String cus_acc = "";
								String account = "";
								
								String itmJob = "";
								String itmType = "";
								boolean isWage_boq = false;
								boolean isGoods_boq = false;
								for(int i=0; i<listBean.size(); i++){	
									listInfOpenJobBean = (ListInfOpenJobBean)listBean.get(i);
									if(listInfOpenJobBean!=null){
										if (allotType.equals("1")) {
											com_acc = listInfOpenJobBean.getCom_acc1();
											cus_acc = listInfOpenJobBean.getCus_acc1();
										} else if (allotType.equals("2")) {
											com_acc = listInfOpenJobBean.getCom_acc2();
											cus_acc = listInfOpenJobBean.getCus_acc2();
										} else if (allotType.equals("3")) {
											com_acc = listInfOpenJobBean.getCom_acc3();
											cus_acc = listInfOpenJobBean.getCus_acc3();
										}
										com_acc = doString.checkString(com_acc);
										cus_acc = doString.checkString(cus_acc);
										itmJob = doString.checkString(listInfOpenJobBean.getI_itmjob());		
										isWage_boq = false;
										isGoods_boq = false;
										rs = stmt.executeQuery("SELECT NVL(z_wage_unit,0)::DECIMAL(16,2) AS WAGE, NVL(z_good_unit,0)::DECIMAL(16,2) AS GOOD FROM lan:serv_infboq WHERE i_itmjob = '"+itmJob+"'");
										if (rs != null) {
											if (rs.next() == true) {
												if (rs.getDouble(1) > 0) {
													isWage_boq = true;
												}
												if (rs.getDouble(2) > 0) {
													isGoods_boq = true;
												}
											}
											rs.close();
											rs=null;
										}	
										itmType = "";
										if (!com_acc.equals("") && !cus_acc.equals("")) {
											account = com_acc+","+cus_acc;
											itmType = "02";
										} else {
											account = com_acc;
											if (account.equals("")) account = cus_acc;
											if (!account.equals("")) {
												if (account.substring(0,3).equals("540") || account.substring(0,3).equals("551")) {
													itmType = "01";
												} else {
													itmType = "02";
												}
											}
										}
										if (!defaItmType.equals("")) {
											itmType = defaItmType;
										}
							%>
							<tr>
				          		<td width="2%" align="center" class="dotline"><input type="checkbox" name="del_checkbox" value="<%=doString.checkString(doString.DisplayThai(listInfOpenJobBean.getI_itmjob())) %>" onclick="checkAll(this,'main_check','del_checkbox');"></td>
				          		<td width="3%" align="center" class="dotline"><%=index++%>&nbsp;</td>
				          		<td width="15%" class="dotline">
				          			<input type="hidden" name="i_itmjob" value="<%=doString.checkString(doString.DisplayThai(listInfOpenJobBean.getI_itmjob()))%>">
									<font color="red"><%=account%></FONT><br>
				          			<%=doString.checkString(doString.DisplayThai(listInfOpenJobBean.getN_itmjob()))%>&nbsp;</td>
				          		<td width="6%" class="dotline" align="center"><%=doString.checkString(doString.DisplayThai(listInfOpenJobBean.getN_count()))%>&nbsp;</td>
				          		<td width="6%" class="dotline" align="center">
<%
								if (itmType.equals("01")) { out.print("ซ่อมสาธารณู"); }
								if (itmType.equals("02")) { out.print("ซ่อมสาธารณะ"); }
%>
								<input type="hidden" name="itmtype"  value="<%=itmType%>">
								</td>
				          		<td width="12%" class="dotline ; item">
				          			<%String vendor = listInfOpenJobBean.getI_vender().trim(); %>
				          			<%=common.genVendorOpenJobDropDown("vendor",vendor,companyId,sel_projrct," class='box' style='width:200px' " ) %>
				          			
				          		</td>
				          		<td width="8%" align="right" class="dotline">
				          		<%if (isWage_boq) {%>
				          		<input type="text" maxlength="9" class="boxDR" style="width:100%" name="customwage" value="<%=format.format(listInfOpenJobBean.getCustom_wage())%>" onFocus="this.blur()"/>
				          		<%} else {%>
				          		<input type="text" maxlength="9" class="boxR" style="width:100%" name="customwage" value="<%=format.format(listInfOpenJobBean.getCustom_wage())%>" onKeyPress="return isCurrencyKey(event)" onblur="calculate(<%=i %>);" />
				          		<%}%>
				          		</td>
				          		<td width="4%" align="center"class="dotline"><input type="text" maxlength="5" name="wage" class="boxR" style="width:100%" value="<%=format.format(listInfOpenJobBean.getWage())%>" onKeyPress="return isCurrencyKey(event)" onblur="calculate(<%=i %>);" onchange="copyValue(<%=i %>);calculate(<%=i %>);" /></td>
				          		<td width="8%" align="right" class="dotline"><input type="text" class="boxR" style="width:100%;border: none;" readonly="readonly" name="wage_sum" value="<%=format.format(listInfOpenJobBean.getWage_sum())%>" /></td>
				          		<td width="8%" align="right" class="dotline">
				          		<%if (isGoods_boq) {%>
								<input type="text" maxlength="9" class="boxDR" style="width:100%" name="customgoods" value="<%=format.format(listInfOpenJobBean.getCustom_goods())%>" onFocus="this.blur()"/>				          		
				          		<%} else {%>				          		
				          		<input type="text" maxlength="9" class="boxR" style="width:100%" name="customgoods" value="<%=format.format(listInfOpenJobBean.getCustom_goods())%>" onKeyPress="return isCurrencyKey(event)" onblur="calculate(<%=i %>);"/>
				          		<%}%>
				          		</td>
				          		<td width="4%" align="center"class="dotline"><input type="text" maxlength="5" name="goods" class="boxR" style="width:100%" value="<%=format.format(listInfOpenJobBean.getGoods())%>" onKeyPress="return isCurrencyKey(event)" onblur="calculate(<%=i %>);"/></td>
				          		<td width="8%" align="right" class="dotline"><input type="text" class="boxR" style="width:100%;border: none;" readonly="readonly" name="goods_sum" value="<%=format.format(listInfOpenJobBean.getGoods_sum())%>" onKeyPress="return isCurrencyKey(event)" onblur="calculate(<%=i%>);"/></td>
				          		<td width="8%" align="right" class="dotline">
				          		<input type="text" maxlength="9" class="boxR" style="width:100%" name="estimate" value="<%=format.format(listInfOpenJobBean.getEstimate())%>" onKeyPress="return isCurrencyKey(event)" onblur="clearEstimate(<%=i%>, '<%=listInfOpenJobBean.isWage_boq()%>', '<%=listInfOpenJobBean.isGoods_boq()%>');"/>
				          		</td>
				          		<td width="8%" align="right" class="dotline"><input type="text" class="boxR" style="width:100%;border: none;" readonly="readonly" name="sum_total" value="<%=format.format(listInfOpenJobBean.getSum_total())%>" />
				          	</tr>	
							<% 		
									totalWage		+= listInfOpenJobBean.getWage_sum();
									totalGoods		+= listInfOpenJobBean.getGoods_sum();
									totalEstimate	+= listInfOpenJobBean.getEstimate();
									grandTotal		+= listInfOpenJobBean.getSum_total();
									
									
									}
								}
								if(listBean.size()>0){
									openJobBean.setTotalWage(totalWage);
									openJobBean.setTotalGoods(totalGoods);
									openJobBean.setTotalEstimate(totalEstimate);
									openJobBean.setGrandTotal(grandTotal);
							%>	
							<tr> 
                  				<td width="2%" align="center" class="dotline">&nbsp;</td>
			                  	<td width="3%" align="center" class="dotline">&nbsp;</td>
			                  	<td width="15%" class="dotline">&nbsp;</td>
			                  	<td width="6%" class="dotline" align="center">&nbsp;</td>
			                  	<td width="6%" class="dotline" align="center">&nbsp;</td>
			                  	<td width="12%" class="dotline ; item" align="right">รวม</td>
			                  	<td width="8%" align="right" class="dotline ; item">&nbsp;</td>
			                  	<td width="4%" align="right" class="dotline ; item">&nbsp;</td>
			                  	<td width="8%" align="right" class="dotline">
			                  		<input type="text" maxlength="9" class="dotline ; item" style="width:100%;border: none;text-align: right;font-size:12" readonly="readonly" name="totalWage" value="<%=format.format(openJobBean.getTotalWage())%>" /></td>
			                  	<td width="8%" align="right" class="dotline ; item">&nbsp;</td>
			                  	<td width="4%" align="right" class="dotline ; item">&nbsp;</td>
			                  	<td width="8%" align="right" class="dotline ; item">
			                  		<input type="text" maxlength="9" class="dotline ; item" style="width:100%;border: none;text-align: right;font-size:12" readonly="readonly" name="totalGoods" value="<%=format.format(openJobBean.getTotalGoods())%>" /></td>
			                  	<td width="8%" align="right" class="dotline ; item">
			                  		<input type="text" maxlength="9" class="dotline ; item" style="width:100%;border: none;text-align: right;font-size:12" readonly="readonly" name="totalEstimate" value="<%=format.format(openJobBean.getTotalEstimate())%>" /></td>
			                  	<td width="8%" align="right" class="dotline ;">
			                  		<input type="text" maxlength="9" class="dotline ; item" style="width:100%;border: none;text-align: right;font-size:12" readonly="readonly" name="grandTotal" value="<%=format.format(openJobBean.getGrandTotal())%>" /></td>
                			</tr>
							<%	
								}else{	
								%>
							<tr>
								<td width="2%" align="center" class="dotline" colspan="14">&nbsp;</td>
							</tr>
							<% 
								}
							}else{ 
							%>
							<tr>
								<td width="2%" align="center" class="dotline" colspan="14">&nbsp;</td>
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
        	<table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          	<tr>
            	<td class="act_tab1"></td>
            	<td width="230" class="act_tab2">
	            	<a href="javascript:addJobList();"><img border="0" src="images/act_add.gif"
	    				onmouseout=nereidFade(this,70,50,5)
	                  	onmouseover=nereidFade(this,100,50,5)
	                  	style="cursor:hand;FILTER: alpha(opacity=70)" width="70" height="27"></A>&nbsp;
            		<a href="javascript:deleteItem();"><img border="0" src="images/act_delete.gif"
	    				onmouseout=nereidFade(this,70,50,5)
	                  	onmouseover=nereidFade(this,100,50,5)
	                  	style="cursor:hand;FILTER: alpha(opacity=70)" width="70" height="27"></a>
            	</td>
            	<td class="act_tab3"></td>
            	<td class="act_tab4">&nbsp; </td>
          	</tr>
        </table>
		<br style="font-size:10pt">
       	<!-- comments -->
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
        			if(listBean.size()>0){
        				//listBean = (ArrayList)request.getSession().getAttribute("listOpenJob");
						for(int i=0; i<listBean.size(); i++){	
							
							listInfOpenJobBean = (ListInfOpenJobBean)listBean.get(i);
							if(listInfOpenJobBean!=null){
											
					%>	
				  	<tr>
				    	<td class="item ; dotline01" height="22" width="12%">รายการที่ <%=i+1 %> :</td>
					    <td height="22" width="76%" class="dotline01">
					    	<input type="text" name="comment" class="box" style="width:100%" size="20" maxlength='200'  value="<%=doString.checkString(doString.DisplayThai(listInfOpenJobBean.getComment()))%>"></td>
					    <td height="22" width="12%" class="dotline01">
				          	<%=common.genAreaBOQDropDown("area",listInfOpenJobBean.getArea()," class='box' style='width:250px' " ) %>
						</td>
				  	</tr>
					<%
							}
						}
					}
					%>

				</table>
				</td>
  			</tr>
		</table>
		<!--  -->
		
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
  			<tr>
    			<td width="100%" class="frmLR" align="center">
					<table border="0" width="100%" cellspacing="0" cellpadding="0">
				  		<tr>
				    		<td class="item ; dotline01" height="22" width="12%">&nbsp;</td>
				    		<td height="22" width="76%" class="dotline01">&nbsp;</td>
				    		<td height="22" width="12%" class="dotline01">&nbsp;</td>
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
       	<!-- Attach File -->
       	<table border="0" width="100%" cellspacing="0" cellpadding="0">
        	<tr>
            	<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
                <td class="item_tab2" width="200">Attach File</td>
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
        			String keyFile = "";
        			String fileName = "";
        			String realName = "";
        			String urlAttach = "";
        			SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT_NOW);
        			if(listBean.size()>0){
						for(int i=0; i<listBean.size(); i++){	
							listInfOpenJobBean = (ListInfOpenJobBean)listBean.get(i);
							if(listInfOpenJobBean!=null){
								fileName = doString.checkString(listInfOpenJobBean.getFileName());
								fileName = doString.DisplayThai(fileName);
								realName = listInfOpenJobBean.getItmFiName();
								fileName = realName;
								Thread.sleep(500);
								keyFile = sdf.format(Calendar.getInstance(Locale.ENGLISH).getTime());
								urlAttach = request.getContextPath()+"/attach/temp/"+sessionId+"/"+realName;
								System.out.println("urlAttach:"+urlAttach);
					%>	
				  	<tr>
				    	<td class="item ; dotline01" height="22" width="10%">รายการที่ <%=i+1 %> :</td>
					    <td height="22" width="75%" class="dotline01"><%=doString.checkString(doString.DisplayThai(listInfOpenJobBean.getN_itmjob()))%></td>
					    <td height="22" width="9%" class="dotline01"><a href="<%=urlAttach%>" target="_blank"><%=fileName%></a>&nbsp;<input type="hidden" name="filename" value="<%=fileName%>"></td>
					    <td height="22" width="6%" class="dotline01"><input type="button" class="box" value="แนบไฟล์" onclick="openUploadWin('<%=i%>', '<%=keyFile%>');" style="background-color:#eeeeee; "></td>
				  	</tr>
					<%
							}
						}
					}
					%>
				</table>
				</td>
  			</tr>
		</table>
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
  			<tr>
    			<td width="100%" class="frmLR" align="center">
					<table border="0" width="100%" cellspacing="0" cellpadding="0">
				  		<tr>
				    		<td class="item ; dotline01" height="22" width="12%">&nbsp;</td>
				    		<td height="22" width="76%" class="dotline01">&nbsp;</td>
				    		<td height="22" width="12%" class="dotline01">&nbsp;</td>
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


<%

if (who.equals("M") || who.equals("Z")) {%>
<input type="hidden" id="approver" name="approver" value="<%=empId%>">
<%} else {%>
<br style="font-size:10pt"><table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
		<td class="item_tab1"><img border="0" src="images/i_i.gif" align="absmiddle" width="20" height="20"></td>
		<td class="item_tab2" width="200">สายงานการอนุมัติ</td>
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
    				<td width="44%" class="BG01" align="center">
						<table cellspacing="0" cellpadding="0" width="300">
                        	<tr>
                        		<td width="15"><img border="0" src="images/no1.gif" align="absmiddle" width="15" height="15"></td>
                               	<td width="25"><img border="0" src="images/i_pass.gif" align="absmiddle" width="19" height="16"></td>
                                <td><font color="#000096"><%out.print(n_service_employ); %></font></td>
							</tr>
							<tr>
								<td width="15"></td>
								<td width="25"></td>
								<td>ผู้ขออนุมัติ</td>
							</tr>
						</table>
    				</td>
    				<td width="12%" class="BG01" align="center" valign="middle">
						<img border="0" src="images/arrow5.gif" align="absmiddle" width="90" height="40">
					</td>
    				<td width="44%" class="BG01" align="center">
						<table cellspacing="0" cellpadding="0" width="300">
			  				<tr>
								<td width="15"><img border="0" src="images/no2.gif" align="absmiddle" width="15" height="15"></td>
								<td width="25"><img border="0" src="images/i_wait.gif" align="absmiddle" width="19" height="16"></td>                                    
			            		<td>
			            		<select id="approver" name="approver" class='box' style='width:250px'>
									<option value=''>------ กรุณาเลือก ------</option>
  								</select>
			            		</td>
		  					</tr>
		  					<tr>
								<td width="15"></td>
								<td width="25"></td>
								<td>ผู้อนุมัติ</td>
		  					</tr>
						</table>	   
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
<%}%>



<br style="font-size:10pt">
<table border="0" width="100%" cellspacing="0" cellpadding="0" height="30">
          <tr>
            <td class="act_tab1"></td>
            <td width="230" class="act_tab2">
<%if (who.equals("M") || who.equals("Z")) {%>
            <a href="javascript:sendToApprove();"><img border="0" src="images/act_submit.gif"
    			onmouseout=nereidFade(this,70,50,5)
                  	onmouseover=nereidFade(this,100,50,5)
                  	style="cursor:hand;FILTER: alpha(opacity=70)" width="70" height="27"></a>
<%} else {%>
            <a href="javascript:saveOpenJob();"><img border="0" src="images/act_save.gif"
    			onmouseout=nereidFade(this,70,50,5)
                  	onmouseover=nereidFade(this,100,50,5)
                  	style="cursor:hand;FILTER: alpha(opacity=70)" width="70" height="27"></A>&nbsp;

            <a href="javascript:sendToApprove();"><img border="0" src="images/act_send2app.gif"
    			onmouseout=nereidFade(this,70,50,5)
                  	onmouseover=nereidFade(this,100,50,5)
                  	style="cursor:hand;FILTER: alpha(opacity=70)" width="70" height="27"></a>
<%}%>
            </td>
            <td class="act_tab3"></td>
            <td class="act_tab4"><a href="javascript:history.back();"><img border="0" src="images/bu_back.gif" align="absmiddle" width="50" height="15"></a>&nbsp; 
              <a href="javascript:goHome();"><img border="0" src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
          </tr>
        </table>
          </td>
        </tr>
	</table>
	<br style="font-size:30pt">
	<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
	  	<tr>
	  		<td width="100%" class="copyright" align="center">Best viewed with 800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ 5.5
		  		<br>ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;  หรือ โทร. 0-2230-8279 (คุณประพัฒน์  ฝ่ายบริการ)&nbsp; 0-2230-8491-5 (ฝ่าย IT)
				<br><img src="images/copyright.gif" width="475" height="26">
			</td>
		</tr>
	</TABLE>
<input type="hidden" name="actionMode" value="<%=actionMode%>"/>	
<input type="hidden" id="amount" name="amount" value="<%=amount%>"/>	
<input type="hidden" name="approveManager" value="<%=approveManager%>"/>	

<input type="hidden" name="managerList" value="<%=managerList%>"/>	
<input type="hidden" name="zoneList" value="<%=zoneList%>"/>	

</FORM>
</BODY>
</HTML>
<script type="text/javascript">
var sumEstTotal = 0;
if (document.forms[0].totalEstimate != null) {
	sumEstTotal = removeComma(document.forms[0].totalEstimate.value)*1;
}

if(sumEstTotal > 0) {
	populate("zone");
} else {
	if(document.forms[0].grandTotal!=null){			var sumGrandTotal = removeComma(document.forms[0].grandTotal.value)*1;			var amount = removeComma(document.forms[0].amount.value)*1;			
			if(sumGrandTotal>0 && sumGrandTotal<= amount)				populate("manager");			else if(sumGrandTotal>amount)				populate("zone");	}

}
</script><%
		common = null;
		stmt.close();
		conn.close();
		stmt = null;
		conn = null;
		System.out.println("----SERV_InfOpenJob.jsp --- ");
	} catch (Exception e) {
		System.out.println("ERROR SERV_InfOpenJob.jsp : " + e.getMessage());
		throw new ServletException(e.getMessage());
	} finally {
		try {
			if (rs != null) rs.close();
			if (stmt != null) stmt.close();
			if (conn != null) conn.close();
		}
		catch( SQLException ignore ){}
	}
%>
