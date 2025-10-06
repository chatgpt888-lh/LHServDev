package com.test;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import com.svc.call.utilize.Utilizer;

public class DateTest{
    public static void main(String[] args) throws ParseException{
        //Calendar now = Calendar.getInstance();
       // System.out.println(now.getTimeZone());
       // System.out.println(now.getTime());   	
    	/*String a = "2013-10-30 12:30:00.0";	
    	System.out.println(a.length());
    	System.out.println(a.substring(0,16));*/
    	
    	//test();
    	//test2();
    	
    	/*try {
    		String x = "2013-11-06 12:00:00.0";
    		System.out.println(x.substring(0,10));
    		
			System.out.println(Utilizer.isDateAvailable("2013-11-20"));
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}*/
    	
    	test33();
    }
    
   private static void test() throws ParseException{
	   
	   //by date
	   DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
	   //get current date time with Date()
	   Date date = new Date();
	   System.out.println(dateFormat.format(date));
	   String x = dateFormat.format(date);
	   System.out.println("DD:"+x);
	   //by calendar
	   //get current date time with Calendar()
	   Calendar cal = Calendar.getInstance();
	   System.out.println(dateFormat.format(cal.getTime()));
   }
   
   private static void test33(){
	   Calendar a = Calendar.getInstance();
	   for (int i=2011;i<2014;i++) {
	   System.out.println("i="+i+"<br>");
	   a.set(i,10,18);
	   System.out.println("18="+a.get(Calendar.DAY_OF_WEEK)+"<br>");
	   a.set(i,10,19);
	   System.out.println("19="+a.get(Calendar.DAY_OF_WEEK)+"<br>");
	   a.set(i,10,20);
	   System.out.println("20="+a.get(Calendar.DAY_OF_WEEK)+"<br>");
	   a.set(i,10,21);
	   System.out.println("21="+a.get(Calendar.DAY_OF_WEEK)+"<br>");
	   a.set(i,10,22);
	   System.out.println("22="+a.get(Calendar.DAY_OF_WEEK)+"<br>");
	   a.set(i,10,23);
	   System.out.println("23="+a.get(Calendar.DAY_OF_WEEK)+"<br>");
	   a.set(i,10,24);
	   System.out.println("24="+a.get(Calendar.DAY_OF_WEEK)+"<hr>");    
	   System.out.println("");
	   }
   }
   
   private static void test2(){
	   try{
		   
   		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
       	Date date1 = sdf.parse("2009-12-31");
       	Date date2 = sdf.parse("2010-01-31");

       	System.out.println(sdf.format(date1));
       	System.out.println(sdf.format(date2));

       	if(date1.after(date2)){
       		System.out.println("Date1 is after Date2");
       	}

       	if(date1.before(date2)){
       		System.out.println("Date1 is before Date2");
       	}

       	if(date1.equals(date2)){
       		System.out.println("Date1 is equal Date2");
       	}

   	}catch(Exception ex){
   		ex.printStackTrace();
   	}
   }
}