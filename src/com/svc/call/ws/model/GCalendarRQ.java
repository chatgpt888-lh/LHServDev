package com.svc.call.ws.model;
/*
 * date:2014-02-07
 * author: pradoem wongkraso
 * verion 1.0
 * contact : pradoem@lh.co.th,go2doem@gmail.com
 * description: For Communication parameter webService
 * */
public class GCalendarRQ {
	String referenceId; //i_docno
	String documentId;//i_docno
	String companyId;//i_company
	String projectId;//i_project
	String houseNo;//i_house :176/52
	String lockNo;//i_lock :01A01
	String desc; // not mandatory
	String fromDate; //2013-12-18
	String toDate; //2013-12-18
	String fromTime; //12:00
	String toTime; //09:30
	String appName; //SVC,ESERVIC,IND
	int chkseq; //counter check-up
	String venderId; //i_vender
	String telNo;
	String userName;
	String customerName;
	String status;
	String typeCode;
	
	public String getTypeCode() {
		return typeCode;
	}

	public void setTypeCode(String typeCode) {
		this.typeCode = typeCode;
	}

	public String getDocumentId() {
		return documentId;
	}

	public void setDocumentId(String documentId) {
		this.documentId = documentId;
	}

	public String getTelNo() {
		return telNo;
	}

	public void setTelNo(String telNo) {
		this.telNo = telNo;
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public String getCustomerName() {
		return customerName;
	}

	public void setCustomerName(String customerName) {
		this.customerName = customerName;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getReferenceId() {
		return referenceId;
	}

	public void setReferenceId(String referenceId) {
		this.referenceId = referenceId;
	}

	public String getCompanyId() {
		return companyId;
	}

	public void setCompanyId(String companyId) {
		this.companyId = companyId;
	}

	public String getProjectId() {
		return projectId;
	}

	public void setProjectId(String projectId) {
		this.projectId = projectId;
	}

	public String getHouseNo() {
		return houseNo;
	}

	public void setHouseNo(String houseNo) {
		this.houseNo = houseNo;
	}

	public String getLockNo() {
		return lockNo;
	}

	public void setLockNo(String lockNo) {
		this.lockNo = lockNo;
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

	public String getToDate() {
		return toDate;
	}

	public void setToDate(String toDate) {
		this.toDate = toDate;
	}

	public String getFromTime() {
		return fromTime;
	}

	public void setFromTime(String fromTime) {
		this.fromTime = fromTime;
	}

	public String getToTime() {
		return toTime;
	}

	public void setToTime(String toTime) {
		this.toTime = toTime;
	}

	public String getAppName() {
		return appName;
	}

	public void setAppName(String appName) {
		this.appName = appName;
	}

	public int getChkseq() {
		return chkseq;
	}

	public void setChkseq(int chkseq) {
		this.chkseq = chkseq;
	}

	public String getVenderId() {
		return venderId;
	}

	public void setVenderId(String venderId) {
		this.venderId = venderId;
	}
	
	
	public String toString(){
	    StringBuffer str = new StringBuffer();
	    str.append("[");
	    str.append("referenceId="+this.referenceId);
	    str.append("&companyId="+this.companyId);
	    str.append("&projectId="+this.projectId);
	    str.append("&houseNo="+this.houseNo);
	    str.append("&lockNo="+this.lockNo);
	    str.append("&desc="+this.desc);
	    str.append("&fromDate="+this.fromDate);
	    str.append("&fromTime="+this.fromTime);
	    str.append("&toDate="+this.toDate);
	    str.append("&toTime="+this.toTime);
	    str.append("&appName="+this.appName);		    
	    str.append("&chkseq="+this.chkseq);
	    str.append("&venderId="+this.venderId);    
	    str.append("&telNo="+this.telNo);
	    str.append("&userName="+this.userName);
	    str.append("&customerName="+this.customerName);
	    str.append("&status="+this.status);
	    str.append("]");
	    return str.toString();
	}

}
