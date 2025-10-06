package com.test;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Locale;

public class GetCurrentDateTime {

	/**
	 * @param args
	 * @throws ParseException 
	 */
	public static void main(String[] args) throws ParseException {
		SimpleDateFormat df = new SimpleDateFormat("hh:mm");
		  Date d1 = df.parse("23:30");
		  Calendar c1 = GregorianCalendar.getInstance();
		  c1.setTime(d1);
		  System.out.println(c1.getTime());

	}

}
