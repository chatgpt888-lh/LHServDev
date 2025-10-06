package com.svc.call.bean;
public class CustomerBean {
	private String customerId;
	private String prefixName;
	private String fName;
	private String lName;
	private String model;
	private String houseNo;
	private String lock;
	private String lor;
	private String telNo;
	private String dCloseLaw;
	private String flagGuranteeDate;
	private String dateGurantee;
	
	public String getCustomerId() {
		return customerId;
	}
	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}
	public String getDateGurantee() {
		return dateGurantee;
	}
	public void setDateGurantee(String dateGurantee) {
		this.dateGurantee = dateGurantee;
	}
	public String getDCloseLaw() {
		return dCloseLaw;
	}
	public void setDCloseLaw(String closeLaw) {
		dCloseLaw = closeLaw;
	}
	public String getFlagGuranteeDate() {
		return flagGuranteeDate;
	}
	public void setFlagGuranteeDate(String flagGuranteeDate) {
		this.flagGuranteeDate = flagGuranteeDate;
	}
	public String getFName() {
		return fName;
	}
	public void setFName(String name) {
		fName = name;
	}
	public String getHouseNo() {
		return houseNo;
	}
	public void setHouseNo(String houseNo) {
		this.houseNo = houseNo;
	}
	public String getLName() {
		return lName;
	}
	public void setLName(String name) {
		lName = name;
	}
	public String getLock() {
		return lock;
	}
	public void setLock(String lock) {
		this.lock = lock;
	}
	public String getLor() {
		return lor;
	}
	public void setLor(String lor) {
		this.lor = lor;
	}
	public String getModel() {
		return model;
	}
	public void setModel(String model) {
		this.model = model;
	}
	public String getPrefixName() {
		return prefixName;
	}
	public void setPrefixName(String prefixName) {
		this.prefixName = prefixName;
	}
	public String getTelNo() {
		return telNo;
	}
	public void setTelNo(String telNo) {
		this.telNo = telNo;
	}
}
