package serv.common;

import java.util.Vector;

public class ResvTime {
	String empId;
	String resvDate;
	String chkMonth;
	String chkYear;
	String vendor;
	String group;
	String comId;
	String projId;
	String lockId;
	int seqNo;
	Vector chkTimeList;
	int week;
	int firstDayOfWeek;
	java.util.Date begRegisDate;
	String comment;
	boolean view_lock = false;
	public ResvTime() {
		empId = "";
		resvDate = "";
		chkMonth = "";
		chkYear = "";
		vendor = "";
		group = "";
		comId = "";
		projId = "";
		lockId = "";
		seqNo = 0;
		chkTimeList = new Vector(5);
		week=1;
		firstDayOfWeek=1;
		comment = "";
		view_lock = false;
	}
	public String getChkMonth() {
		return chkMonth;
	}
	public void setChkMonth(String chkMonth) {
		this.chkMonth = chkMonth;
	}
	public String getChkYear() {
		return chkYear;
	}
	public void setChkYear(String chkYear) {
		this.chkYear = chkYear;
	}
	public String getComId() {
		return comId;
	}
	public void setComId(String comId) {
		this.comId = comId;
	}
	public String getEmpId() {
		return empId;
	}
	public void setEmpId(String empId) {
		this.empId = empId;
	}
	public String getProjId() {
		return projId;
	}
	public void setProjId(String projId) {
		this.projId = projId;
	}
	public String getResvDate() {
		return resvDate;
	}
	public void setResvDate(String resvDate) {
		this.resvDate = resvDate;
	}
	public String getVendor() {
		return vendor;
	}
	public void setVendor(String vendor) {
		this.vendor = vendor;
	}
	public void clearChkTime() {
		this.chkTimeList.removeAllElements();
	}
	public String getGroup() {
		return group;
	}
	public void setGroup(String group) {
		this.group = group;
	}
	public int getWeek() {
		return week;
	}
	public void setWeek(int week) {
		this.week = week;
	}
	public int getFirstDayOfWeek() {
		return firstDayOfWeek;
	}
	public void setFirstDayOfWeek(int firstDayOfWeek) {
		this.firstDayOfWeek = firstDayOfWeek;
	}
	public java.util.Date getBegRegisDate() {
		return begRegisDate;
	}
	public void setBegRegisDate(java.util.Date begRegisDate) {
		this.begRegisDate = begRegisDate;
	}
	public Vector getChkTimeList() {
		return chkTimeList;
	}
	public void setChkTimeList(Vector chkTimeList) {
		this.chkTimeList = chkTimeList;
	}
	public String getLockId() {
		return lockId;
	}
	public void setLockId(String lockId) {
		this.lockId = lockId;
	}
	public int getSeqNo() {
		return seqNo;
	}
	public void setSeqNo(int seqNo) {
		this.seqNo = seqNo;
	}
	public String getComment() {
		return comment;
	}
	public void setComment(String comment) {
		this.comment = comment;
	}
	public boolean isView_lock() {
		return view_lock;
	}
	public void setView_lock(boolean view_lock) {
		this.view_lock = view_lock;
	}
}
