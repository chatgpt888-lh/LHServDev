package serv.common;

public class BetweenDate {
	String begDate;
	String endDate;
	public BetweenDate(String begDate, String endDate) {
		super();
		this.begDate = begDate;
		this.endDate = endDate;
	}
	public String getBegDate() {
		return begDate;
	}
	public void setBegDate(String begDate) {
		this.begDate = begDate;
	}
	public String getEndDate() {
		return endDate;
	}
	public void setEndDate(String endDate) {
		this.endDate = endDate;
	}
	
}
