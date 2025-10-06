function getLastDateOfMonth(month,year){
	/* note -- en_US year */
	return new Date(year, month, 0);
}
function checkValidDate(sdate,smonth,syear) {
     
	 //---- Check select date ---//
     if (sdate.length==0 && smonth.length==0 && syear.length==0) {
     	alert("กรุณาระบุวันที่");
        return false;
     }     
     
     var startDate = new Date(parseInt(syear,10),parseInt(smonth,10)-1,parseInt(sdate,10));
     
     if (startDate.getMonth()!=(parseInt(smonth,10)-1)) {
        alert("วันที่ไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง !");
        return false;
     }
     return true;
}