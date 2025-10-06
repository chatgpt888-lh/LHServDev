/*
 * Created on 4 ¡.¾. 2008
 *
 * To change the template for this generated file go to
 * Window&gt;Preferences&gt;Java&gt;Code Generation&gt;Code and Comments
 */
package serv.common;
import java.io.*;
import java.util.*;
import java.sql.*;
import java.text.*;
/**
 * @author Arthit Pongvorawat
 *
 * To change the template for this generated type comment go to
 * Window&gt;Preferences&gt;Java&gt;Code Generation&gt;Code and Comments
 */
public class Period {
	public static int getMonth(Timestamp begDate, Timestamp endDate) {
		int countMonth = 0;
		Calendar dBeg = null;
		if (begDate!=null) {
			dBeg = Calendar.getInstance(Locale.ENGLISH);
			dBeg.setTime(begDate);
		}
		Calendar dEnd = null;
		if (endDate!=null) {
			dEnd = Calendar.getInstance(Locale.ENGLISH);
			dEnd.setTime(endDate);
		}
		if (dBeg!=null && dEnd!=null) {
			//dBeg.add(Calendar.MONTH,1);
			while (dBeg.before(dEnd)) {
			  countMonth++;
			  dBeg.add(Calendar.MONTH,1);	
			} // end while
		}		
		return (countMonth+1);
	}
	
	public static String getBetween(String startDate, String endDate) {
		java.text.SimpleDateFormat th_formatter = new java.text.SimpleDateFormat("MMMM/yyyy", new Locale("th","TH"));
		java.text.SimpleDateFormat en_formatter = new java.text.SimpleDateFormat("yyyy-MM-dd", new Locale("en","US"));
		try {
			java.util.Date frmDate = en_formatter.parse(startDate);
			java.util.Date toDate = en_formatter.parse(endDate);
			int i=0;
			int year = 0;	
			startDate = th_formatter.format(frmDate);
			i = startDate.indexOf("/");
			year = Integer.parseInt(startDate.substring(i+1))+543;
			startDate = startDate.substring(0, i)+" "+Integer.toString(year);
			endDate = th_formatter.format(toDate);
			i = endDate.indexOf("/");
			year = Integer.parseInt(endDate.substring(i+1))+543;
			endDate = endDate.substring(0, i)+" "+Integer.toString(year);
		} catch (Exception ignore) {}
		return startDate+" - "+endDate;
	}	
	
}
