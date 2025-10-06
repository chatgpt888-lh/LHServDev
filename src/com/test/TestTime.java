package com.test;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.TimeZone;

import com.svc.call.utilize.Utilizer;

public class TestTime {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		/*Date d = new Date();
		//System.out.println("<<----------:"+d.getHours()+":"+d.getMinutes());
		int timeCurrent = Integer.parseInt(d.getHours()+""+d.getMinutes());
		System.out.println("TEST :"+timeCurrent);
		System.out.println("getHours :"+d.getHours());
		System.out.println("getMinutes :"+d.getMinutes());
		
		Calendar calendar = new GregorianCalendar();

//		set date to last day of 2009
		//calendar.set(Calendar.YEAR, 2009);
		//calendar.set(Calendar.MONTH, 11); // 11 = december
		//calendar.set(Calendar.DAY_OF_MONTH, 31); // new years eve

//		add one day
		//calendar.add(Calendar.DAY_OF_MONTH, 1);

//		date is now jan. 1st 2010
		int year       = calendar.get(Calendar.YEAR);  // now 2010
		int month      = calendar.get(Calendar.MONTH); // now 0 (Jan = 0)
		int dayOfMonth = calendar.get(Calendar.DAY_OF_MONTH); // now 1
		
		System.out.println("year :"+year);
		System.out.println("month :"+month);
		System.out.println("dayOfMonth :"+dayOfMonth);

		int hour       = calendar.get(Calendar.HOUR);        // 12 hour clock
		int hourOfDay  = calendar.get(Calendar.HOUR_OF_DAY); // 24 hour clock
		int minute     = calendar.get(Calendar.MINUTE);
		int second     = calendar.get(Calendar.SECOND);
		int millisecond= calendar.get(Calendar.MILLISECOND);
		
		System.out.println("hour"+hour);
		System.out.println("hourOfDay :"+hourOfDay);
		System.out.println("minute :"+minute);
		System.out.println("second :"+second);*/
		
		testTimeAdd();
		
	}
	
	private static void testTimeAdd(){
		
		Date d = new Date();
		//System.out.println("<<----------:"+d.getHours()+":"+d.getMinutes());
		int timeCurrent = Integer.parseInt(d.getHours()+""+d.getMinutes());
		System.out.println("TEST :"+timeCurrent);
		System.out.println("getHours :"+d.getHours());
		System.out.println("getMinutes :"+d.getMinutes());

        Calendar cal = Calendar.getInstance();
        //cal.setTimeZone(TimeZone.getTimeZone("UTC+7"));
     
        System.out.println("current date: " + getDate(cal));
        
        System.out.println("Time Before a hours : " + getTime(cal));
        cal.add(Calendar.HOUR_OF_DAY, 1);
        System.out.println("Time after 1 hours : " + getTime(cal));
        
        
        int timeCurrentPlus1Hour = Integer.parseInt(cal.get(Calendar.HOUR)+""+(cal.get(Calendar.MINUTE))); 
      //  System.out.println(Now("yyyy-MM-dd"));      
       System.out.println(timeCurrentPlus1Hour);
        
        
        SimpleDateFormat date_format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        System.out.println("TEST xx :"+date_format.format(cal.getTime()));
        
        System.out.println("Test :"+Utilizer.ThisTimeNow("HH:mm"));

	}
	
	 public static String Now(String dateFormat) {
		    Calendar cal = Calendar.getInstance();
		    SimpleDateFormat sdf = new SimpleDateFormat(dateFormat);
		    return sdf.format(cal.getTime());
	  }
	
	
	public static String getDate(Calendar cal){
        return "" + cal.get(Calendar.DATE) +"/" +
                (cal.get(Calendar.MONTH)+1) + "/" + cal.get(Calendar.YEAR);
    }
 
    /**
     *
     * @return current Date from Calendar in HH:mm:SS format
     *
     * adding 1 into month because Calendar month starts from zero
     */
    public static String getTime(Calendar cal){
        return "" + cal.get(Calendar.HOUR_OF_DAY) +":" +
                (cal.get(Calendar.MINUTE)) + ":" + cal.get(Calendar.SECOND);
    }

}
