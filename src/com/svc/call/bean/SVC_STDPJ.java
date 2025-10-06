package com.svc.call.bean;

public class SVC_STDPJ {
	
	private String companyId;
	private String projectId;
	private String calendarId;
	private String gmail;
	private String password;
	
	private String feedUrl;
	private String ReadOnlyUrl;
	
	//i_company, i_project, i_prjcal_id, i_gmail, i_password
	
	public String getCalendarId() {
		return calendarId;
	}
	public void setCalendarId(String calendarId) {
		this.calendarId = calendarId;
	}
	public String getCompanyId() {
		return companyId;
	}
	public void setCompanyId(String companyId) {
		this.companyId = companyId;
	}
	public String getGmail() {
		return gmail;
	}
	public void setGmail(String gmail) {
		this.gmail = gmail;
	}
	public String getPassword() {
		return password;
	}
	public void setPassword(String password) {
		this.password = password;
	}
	public String getProjectId() {
		return projectId;
	}
	public void setProjectId(String projectId) {
		this.projectId = projectId;
	}
	public String getFeedUrl() {
		return feedUrl;
	}
	public void setFeedUrl(String feedUrl) {
		this.feedUrl = feedUrl;
	}
	public String getReadOnlyUrl() {
		return ReadOnlyUrl;
	}
	public void setReadOnlyUrl(String readOnlyUrl) {
		ReadOnlyUrl = readOnlyUrl;
	}
}
