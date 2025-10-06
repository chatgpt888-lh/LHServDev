package com.test;

import java.text.SimpleDateFormat;
import java.util.Date;

public class ConvertTime {
	
	public static void main(String[] args) {
        try {
            String now = new SimpleDateFormat("hh:mm aa").format(new java.util.Date().getTime());
            System.out.println("time in 12 hour format : " + now);
            SimpleDateFormat inFormat = new SimpleDateFormat("hh:mm aa");
            SimpleDateFormat outFormat = new SimpleDateFormat("HH:mm");
            String time24 = outFormat.format(outFormat.parse(now));
            System.out.println("time in 24 hour format : " + time24);
            
            
            Date date = new Date();
            SimpleDateFormat simpDate;

            simpDate = new SimpleDateFormat("kk:mm:ss");
            System.out.println(simpDate.format(date));
        } catch (Exception e) {
            System.out.println("Exception : " + e.getMessage());
        }
    }

}
