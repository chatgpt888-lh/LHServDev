package com.test;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

public class DateFormatTest {
	 
	   public static void main(String[] args) {
	      Date now = new Date();
	   
	      // Use Date.toString()
	      System.out.println(now);
	   
	      // Use DateFormat
	      DateFormat formatter = DateFormat.getInstance(); // Date and time
	      String dateStr = formatter.format(now);
	      System.out.println(dateStr);
	      formatter = DateFormat.getTimeInstance();        // time only
	      System.out.println(formatter.format(now));
	  
	      // Use locale
	      formatter = DateFormat.getDateTimeInstance(DateFormat.FULL, DateFormat.FULL, Locale.ENGLISH);
	      System.out.println("xx ;"+formatter.format(now));
	  
	      // Use SimpleDateFormat
	      SimpleDateFormat simpleFormatter = new SimpleDateFormat("E yyyy.MM.dd 'at' HH:mm:ss a zzz");
	      System.out.println(simpleFormatter.format(now));
	      
	      
	      
	      
	      
	      

		   DateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
		   //get current date time with Date()
		   Date date = new Date();
		   System.out.println(dateFormat.format(date));
	 
		   //get current date time with Calendar()
		   Calendar cal = Calendar.getInstance();
		   System.out.println(dateFormat.format(cal.getTime()));
	   }

}
