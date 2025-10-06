package com.svc.call.utilize;
import java.io.UnsupportedEncodingException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

import com.lh.util.doString;
import com.svc.call.bean.SVC_XSTD;

public class Utilizer {
    public static String []  GetDayOfWeek = {"อาทิตย์","จันทร์","อังคาร","พุธ","พฤหัสบดี","ศุกร์","เสาร์",""};
	public static String GetDateSystemCalendar(Calendar cal) {
		String result = "";
		if (cal==null) return "-";
	    
		int year = cal.get(Calendar.YEAR);
		if (year<2400) year+= 543;
		doString str = new doString();
		result = str.createID(cal.get(Calendar.DATE),2);
		result += "/"+str.createID(cal.get(Calendar.MONTH)+1,2);
		result += "/"+year;	
			    
		return result;
	}
	
	public static String GetDateFromCalendar(Calendar cal) {
	    String result = "";
	    if (cal==null) {
	    	return "-";
	    }
		int year = cal.get(Calendar.YEAR);
		if (year<2400) year+= 543;
	    doString str = new doString();
	    result = str.createID(cal.get(Calendar.DATE),2);
	    result += "/"+str.createID(cal.get(Calendar.MONTH)+1,2);
	    result += "/"+year;		    
		return result;
	}
	
	public static String GetTimeFromCalendar(Calendar cal) {
	    String result = "";
	    if (cal==null){ 
	    	return "-";
	    }
	    doString str = new doString();
	    result = str.createID(cal.get(Calendar.HOUR_OF_DAY),2);
	    result += ":"+str.createID(cal.get(Calendar.MINUTE),2);		    
		return result;
	}	
	
	// Format "H:mm"
	 public static String ThisTimeNow(String dateFormat) {
		    Calendar cal = Calendar.getInstance();
		    SimpleDateFormat sdf = new SimpleDateFormat(dateFormat);
		    return sdf.format(cal.getTime());
	 }
	 
	//output : 09/03/2556
	public static  String ThisToDay(){
		Date date = Calendar.getInstance().getTime();
		DateFormat formatter = new SimpleDateFormat("dd/MM/yyyy");
		String today = formatter.format(date);
		String d2[] = today.split("\\/");
		return d2[0]+"/"+d2[1]+"/"+(Integer.parseInt(d2[2])+543); 
			
	}
	
	public static String replaceNull(String s) {
		if (s == null) {
		  s = "";
		}
		return s;
	 }
	
   public static String ThisCalendarTimeNow(Calendar cal) {
	    String result = "";
	    if (cal==null) return "-";

	    doString str = new doString();
	    result = str.createID(cal.get(Calendar.HOUR_OF_DAY),2);
	    result += ":"+str.createID(cal.get(Calendar.MINUTE),2);
			    
		return result;
	}
   
   //input :yyyy-MM-dd
   //output :2013-10-17
	 public static String NowByCalendar(String dateFormat) {
		    Calendar cal = Calendar.getInstance();
		    SimpleDateFormat sdf = new SimpleDateFormat(dateFormat);
		    return sdf.format(cal.getTime());
	  }
	 
	 //input :ArrayList,LH:075
	 //output :nunthawanchang-mai
	 public static String getLableProject(ArrayList arrList,String paramId) throws Exception{
		 List strList = null;
		 String tempName = "";
		 if(arrList!=null && arrList.size()>0){	
			 //select = "";
			String tempId = "";							 
			Iterator it = arrList.iterator();								   							   
			while(it.hasNext()){								
				strList =(ArrayList)it.next();		
				tempId = doString.checkString(strList.get(0).toString())+":"+doString.checkString(strList.get(1).toString());//LH:075
				System.out.println("-->TEST:"+tempId);
				if(tempId.equals(paramId)){
					//select="selected"; 
					tempName = doString.DisplayThai(doString.checkString(strList.get(2).toString()));
					break;
				}
			}	
		 }
		 System.out.println("-->tempName:"+tempName);
		 return tempName;
	 }
	 
     //input :ArrayList,01,02
	 //output :nunthawanchang-mai  getLableHomeRepair
	 public static String getLableNameList(ArrayList arrList,String paramId) throws Exception{
		 //List strList = null;
		 SVC_XSTD  xstdObj = null;
		 String tempName = "";
		 if(arrList!=null && arrList.size()>0){							 
			Iterator it = arrList.iterator();								   							   
			while(it.hasNext()){	
				xstdObj =(SVC_XSTD)it.next();		
				System.out.println("-->TEST:"+xstdObj.getI_code());
				if(paramId.equals(xstdObj.getI_code())){
					//select="selected"; 
					tempName = doString.DisplayThai(xstdObj.getN_desc());
					break;
				}
			}	
		 }
		 System.out.println("-->x tempName:"+tempName);
		 return tempName;
	 }
	 
	 public static String GenDisplayTableHTML(String groupName,String desc,String nameDDL,String args1,boolean isDDL,int number) throws Exception{
		 StringBuffer  str = new StringBuffer();
		 str.append("<table width='100%' border='0' cellspacing='0' cellpadding='0'>")
		   .append("<tr>")
		   .append(" <td class='bigh ; dotline01' style='padding:15px 0px 0px 0px'>")
		   .append("<img src='images/no"+number+".gif' hspace='5' border='0' align='absmiddle'>"+doString.DisplayThai(groupName));
		   if("YES".equals(args1)){
			   str.append("&nbsp;&nbsp;&nbsp;<img border=\"0\" src=\"images/i_pass.gif\" align=\"absmiddle\" width=\"19\" height=\"16\">&nbsp;ปิด Job");
		   }
		   str.append("</td>")
		    .append("</tr>")
		    .append("</table>")
		    .append(" <table width='100%' border='0' cellspacing='0' cellpadding='0'>");
		   if(isDDL){
			   str.append(" <tr height='22'>")
			   .append(" <td width='20%' class='item ; dotline01' style='padding-left:25px'>หมวด :</td>")
			   .append("<td class='dotline01'>"+nameDDL+"</td>")
			   .append("</tr>");
		   }
		   
		   str.append("<tr height='22'>")
		   .append(" <td  width='20%' class='item ; dotline01' style='padding-left:25px'>รายละเอียด :</td>")
		   .append(" <td class='dotline01'>"+doString.DisplayThai(desc)+"</td>")
		   .append("</tr>")
		   .append("</table>");
		 return str.toString();
	 }
	 
	//	output : 20131021
	public static  String ThisToDayEngID(){
			Date date = Calendar.getInstance().getTime();
			DateFormat formatter = new SimpleDateFormat("dd/MM/yyyy");
			String today = formatter.format(date);
			String d2[] = today.split("\\/");//20/10/2013
			return d2[2]+d2[1]+d2[0];	//20131021
	}
	//GenID
	public static String GenNextId(int b){
		        String temp=""+b;
		        String newSp_id;
		        switch(temp.length()){ 
		          // case 1: newSp_id="00000"+temp; break; // case 2: newSp_id="0000"+temp; break; //case 1: newSp_id="000"+temp; break;
		           case 1: newSp_id="000"+temp; break;
		           case 2: newSp_id="00"+temp; break;
		           case 3: newSp_id="0"+temp; break;
		           default:newSp_id=temp;
		        }
		    return newSp_id;
	}
	public static String GenNextID4Digit(int b){
        String temp=""+b;
        String newSp_id;
        switch(temp.length()){ 
          // case 1: newSp_id="00000"+temp; break; // case 2: newSp_id="0000"+temp; break; //case 1: newSp_id="000"+temp; break;
           case 1: newSp_id="0000"+temp; break;
           case 2: newSp_id="000"+temp; break;
           case 3: newSp_id="00"+temp; break;
           case 4: newSp_id="0"+temp; break;
           default:newSp_id=temp;
        }
        return newSp_id;
 }
	
	 public static String getMobileDisplay(String mobile1,String mobile2,String tel){
		String contact = "";
		 if(!"".equals(mobile1) &&  !"".equals(mobile2)
		         && !"".equals(tel)){
			 	contact = mobile1+","+mobile2+","+tel;
		 }else{
		    if(!"".equals(mobile1)){
		    	contact += mobile1;
			}
			if(!"".equals(mobile2) && !"".equals(mobile1)){
				contact +=","+mobile2;
			}else if(!"".equals(mobile2)){
				contact = mobile2;
			}
			if(!"".equals(tel) && !"".equals(mobile1) ||!"".equals(tel) && !"".equals(mobile2) ){
				contact +=","+tel;
			}else if(!"".equals(tel)){
				contact = tel;
			}
		 }
		 return contact;
	}
	 
	//false = object is null / str is ""
	//true = object have value / string hava value 
	public static boolean isValueStrAndObj(String str) throws Exception{
		if ((str == null) || str.equals("")) {
			 return false;
		}else{
			 return true;
		 }
	}
	
	//true= is date display
	//false = is not display change date
	public static boolean isDateAvailable(String strDate) throws Exception{
		if ((strDate == null) || "".equals(strDate)) {
			 return false;
		}else{
			 //return true;
			boolean isRet = false;
			Date date = new Date();
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
			String dday = sdf.format(date);
			Date date1 = sdf.parse(dday); //TODAY
			Date date2 = sdf.parse(strDate);//From Day dinamic
	       	System.out.println(sdf.format(date1));
	       	System.out.println(sdf.format(date2));

	       	if(date1.after(date2)){//>>>
	       		System.out.println("Date1 is after Date2");
	       		isRet =  false;
	       	}
	       	if(date1.before(date2)){//<<<
	       		System.out.println("Date1 is before Date2");
	       		isRet =  true;
	       	}
	       	if(date1.equals(date2)){
	       		System.out.println("Date1 is equal Date2");
	       		isRet =  false;
	       	}
	       	return isRet;
		 }
	}
	
	
	public static String GetThaiCurrentDDMMYYYY(){
		//Date format
	  	Date date = Calendar.getInstance().getTime();
	  	 // Display a date in day, month, year format
	  	DateFormat formatter = new SimpleDateFormat("dd/MM/yyyy");
	  	String today = formatter.format(date);
	  	String [] tempDate ;
	  	tempDate = today.split("/");
	  	int yyy = Integer.parseInt(tempDate[2])+543;
	  	return	tempDate[0]+"/"+tempDate[1]+"/"+yyy;
	}
	public static  String toDDMMYY_THAI2(String str){
		 if ((str == null) || str.equals("")) {
			 return  str;
		 }else{
			 String d2[] = str.split("\\-"); //2013-03-29
			 return d2[2]+"/"+d2[1]+"/"+(Integer.parseInt(d2[0])+543);
		 }
	}
	
	//Method get Link next page url
	public static String genLinkNextPageHTML(int tmpMax,int nowPage,int displayLine)throws Exception {
		String pageLink = "";
		int tmpPage = 0;
		//System.out.println("tmpMax :"+tmpMax);
    	while (tmpMax>0) {
    	       tmpMax -= displayLine;
    	       tmpPage++;
    	       if (nowPage==tmpPage) {
    	          pageLink += "&nbsp; <b>"+tmpPage+"</b> ";
    	       } else {
    	          pageLink += "&nbsp; <a href='#' onclick='changePage("+tmpPage+");'>"+tmpPage+"</a> ";
    	       }
    	}//End while
    	if (tmpPage>1) {
    	      int prev = nowPage-1;
    	      if (prev<1) {
    	    	  prev=1; 
    	      }
    	      pageLink = "<a href='#' onclick='changePage("+prev+");'><img src=\"images/b4_previous.gif\" border=\"0\" align=\"absmiddle\" style=\"cursor:hand\"></a>&nbsp; "+pageLink;
    	      int next = nowPage+1;
    	      if (next>tmpPage) {
    	    	  next = tmpPage;
    	      }
    	      pageLink += "&nbsp; <a href='#' onclick='changePage("+next+");'><img src=\"images/b4_next.gif\" border=\"0\" align=\"absmiddle\" style=\"cursor:hand\"></a>";      
    	   } else {
    	      pageLink = "หน้า <b>1</b>";
    	   }
    	return pageLink;
	}
	
	//	Method get Link next page url
	public static String genLinkNextPageHTML2(int tmpMax,int nowPage,int displayLine)throws Exception {
		String pageLink = "";
		int tmpPage = 0;
		//System.out.println("tmpMax :"+tmpMax);
    	while (tmpMax>0) {
    	       tmpMax -= displayLine;
    	       tmpPage++;
    	       if (nowPage==tmpPage) {
    	          pageLink += "&nbsp; <b>"+tmpPage+"</b> ";
    	       } else {
    	          pageLink += "&nbsp; <a href='#' onclick='changePage2("+tmpPage+");'>"+tmpPage+"</a> ";
    	       }
    	}//End while
    	if (tmpPage>1) {
    	      int prev = nowPage-1;
    	      if (prev<1) {
    	    	  prev=1; 
    	      }
    	      pageLink = "<a href='#' onclick='changePage2("+prev+");'><img src=\"images/b4_previous.gif\" border=\"0\" align=\"absmiddle\" style=\"cursor:hand\"></a>&nbsp; "+pageLink;
    	      int next = nowPage+1;
    	      if (next>tmpPage) {
    	    	  next = tmpPage;
    	      }
    	      pageLink += "&nbsp; <a href='#' onclick='changePage2("+next+");'><img src=\"images/b4_next.gif\" border=\"0\" align=\"absmiddle\" style=\"cursor:hand\"></a>";      
    	   } else {
    	      pageLink = "หน้า <b>1</b>";
    	   }
    	return pageLink;
	}

}
