package com.test;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

/**
 * Java program to convert  Millisecond to Date in Java. Java API provides utility
 * method to get millisecond from Date and convert Millisecond to Date in Java.
 * @author http://javarevisited.blogspot.com
 */
public class MillisToDate {
  
    public static void main(String args[]) {
      
       //Converting milliseconds to Date using java.util.Date
       //current time in milliseconds
       long currentDateTime = System.currentTimeMillis();
      
       //creating Date from millisecond
       Date currentDate = new Date(currentDateTime);
      
       //printing value of Date
       System.out.println("current Date: " + currentDate);
      
       DateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");
      
       //formatted value of current Date
       System.out.println("Milliseconds to Date: " + df.format(currentDate));
      
       //Converting milliseconds to Date using Calendar
       Calendar cal = Calendar.getInstance(Locale.getDefault());
       cal.setTimeInMillis(currentDateTime);
       System.out.println("xxx Milliseconds to Date using Calendar:"
               + df.format(cal.getTime()));
      
       //copying one Date's value into another Date in Java
       Date now = new Date();
       Date copiedDate = new Date(now.getTime());
      
       System.out.println("original Date: " + df.format(now));
       System.out.println("copied Date: " + df.format(copiedDate));
       
       
       
       //System.out.println("Date() - Time in milliseconds: " + lDateTime);
       
       Calendar lCDateTime = Calendar.getInstance();
       System.out.println("Calender - Time in milliseconds :" + lCDateTime.getTimeInMillis());

    }
      
}


