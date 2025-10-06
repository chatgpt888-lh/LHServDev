package com.svc.call.bean;

import java.net.URL;

public class GCalendarBean {
	
	private String gUUID;
	private String gTitle;
	private String gContent;
	private String gLocation;
	//private DateTime startTime;
	//private DateTime endTime;
	private String startTimeStr;
	private String endTimeStr;
	private String gUserName ;
	private String gPassword;
	private String gCalendarId;
	private URL    gUrl;
	public String getEndTimeStr() {
		return endTimeStr;
	}
	public void setEndTimeStr(String endTimeStr) {
		this.endTimeStr = endTimeStr;
	}
	public String getGCalendarId() {
		return gCalendarId;
	}
	public void setGCalendarId(String calendarId) {
		gCalendarId = calendarId;
	}
	public String getGContent() {
		return gContent;
	}
	public void setGContent(String content) {
		gContent = content;
	}
	public String getGLocation() {
		return gLocation;
	}
	public void setGLocation(String location) {
		gLocation = location;
	}
	public String getGPassword() {
		return gPassword;
	}
	public void setGPassword(String password) {
		gPassword = password;
	}
	public String getGTitle() {
		return gTitle;
	}
	public void setGTitle(String title) {
		gTitle = title;
	}
	public URL getGUrl() {
		return gUrl;
	}
	public void setGUrl(URL url) {
		gUrl = url;
	}
	public String getGUserName() {
		return gUserName;
	}
	public void setGUserName(String userName) {
		gUserName = userName;
	}
	public String getGUUID() {
		return gUUID;
	}
	public void setGUUID(String guuid) {
		gUUID = guuid;
	}
	public String getStartTimeStr() {
		return startTimeStr;
	}
	public void setStartTimeStr(String startTimeStr) {
		this.startTimeStr = startTimeStr;
	}
	

}
