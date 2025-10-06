package serv.common;

import java.util.Comparator;

public class TimeComparator implements Comparator {

	public int compare(Object o1, Object o2) {
		// TODO Auto-generated method stub
		
		int status=0;
		ChkTime time1 = (ChkTime)o1;
		ChkTime time2 = (ChkTime)o2;
		int num1 = Integer.parseInt(time1.getChkTime());
		int num2 = Integer.parseInt(time2.getChkTime());
		if(num1 == num2) status = 0;
		else if(num1 > num2) status = 1;
		else status = -1;		
		
		return status;		
	}
	public boolean equals(Object obj) {
		return true;
	}	
}
