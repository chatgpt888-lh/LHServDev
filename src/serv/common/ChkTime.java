package serv.common;

public class ChkTime {
	int week;
	String chkDate;
	String chkTime;
	String desc;
	boolean reserve;
	public ChkTime() {
		// TODO Auto-generated constructor stub
		week=0;
		chkDate = "";
		chkTime = "";
		desc = "";
		reserve=false;
	}
	public String getChkDate() {
		return chkDate;
	}
	public void setChkDate(String chkDate) {
		this.chkDate = chkDate;
	}
	public String getChkTime() {
		return chkTime;
	}
	public void setChkTime(String chkTime) {
		this.chkTime = chkTime;
	}
	public String getDesc() {
		return desc;
	}
	public void setDesc(String desc) {
		this.desc = desc;
	}
	public int getWeek() {
		return week;
	}
	public void setWeek(int week) {
		this.week = week;
	}
	public boolean isReserve() {
		return reserve;
	}
	public void setReserve(boolean reserve) {
		this.reserve = reserve;
	}

}
