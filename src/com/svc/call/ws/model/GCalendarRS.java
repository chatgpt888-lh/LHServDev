package com.svc.call.ws.model;
/*
 * date:2014-02-07
 * author: pradoem wongkraso
 * verion 1.0
 * contact : pradoem@lh.co.th,go2doem@gmail.com
 * description: For Communication parameter webService
 * */
public class GCalendarRS {
	String referenceId;
	String errMsg;
	boolean isError; //default true:false
	String subject;
	String desc;
	String fromDate;
	String fromTime;
	String toDate;
	String toTime;
	

	public String getReferenceId() {
		return referenceId;
	}
	public void setReferenceId(String referenceId) {
		this.referenceId = referenceId;
	}
	public String getErrMsg() {
		return errMsg;
	}
	public void setErrMsg(String errMsg) {
		this.errMsg = errMsg;
	}
	public boolean isError() {
		return isError;
	}
	public void setError(boolean isError) {
		this.isError = isError;
	}
	public String getSubject() {
		return subject;
	}
	public void setSubject(String subject) {
		this.subject = subject;
	}
	public String getDesc() {
		return desc;
	}
	public void setDesc(String desc) {
		this.desc = desc;
	}
	public String getFromDate() {
		return fromDate;
	}
	public void setFromDate(String fromDate) {
		this.fromDate = fromDate;
	}
	public String getFromTime() {
		return fromTime;
	}
	public void setFromTime(String fromTime) {
		this.fromTime = fromTime;
	}
	public String getToDate() {
		return toDate;
	}
	public void setToDate(String toDate) {
		this.toDate = toDate;
	}
	public String getToTime() {
		return toTime;
	}
	public void setToTime(String toTime) {
		this.toTime = toTime;
	}
	
	public String toString(){
		    StringBuffer str = new StringBuffer();
		    str.append("[");
		    str.append("referenceId="+this.referenceId);
		    str.append("&errMsg="+this.errMsg);
		    str.append("&isError="+this.isError);
		    str.append("&subject="+this.subject);
		    str.append("&desc="+this.desc);
		    str.append("&fromDate="+this.fromDate);
		    str.append("&fromTime="+this.fromTime);
		    str.append("&toDate="+this.toDate);
		    str.append("&toTime="+this.toTime);
		    str.append("]");
		    return str.toString();
	}	
}
