package com.svc.call.bean;

public class SVC_TELNO {
	private String iTelCtasia;
	private String iCustomer;
	private String iCompany;
	private String iProject;
	private String nProject;
	private String iLock;
	private String dCreate;
	private String iEmployCreate;
	private String dUpdate;
	private String iEmploy_update;
	private String nCustomer;
	private String iTelNo;
	private String iEmail;
	private String iHouse;
	
	
	public String getNProject() {
		return nProject;
	}
	public void setNProject(String project) {
		nProject = project;
	}
	public String getDCreate() {
		return dCreate;
	}
	public void setDCreate(String create) {
		dCreate = create;
	}
	public String getDUpdate() {
		return dUpdate;
	}
	public void setDUpdate(String update) {
		dUpdate = update;
	}
	public String getICompany() {
		return iCompany;
	}
	public void setICompany(String company) {
		iCompany = company;
	}
	public String getICustomer() {
		return iCustomer;
	}
	public void setICustomer(String customer) {
		iCustomer = customer;
	}
	public String getIEmail() {
		return iEmail;
	}
	public void setIEmail(String email) {
		iEmail = email;
	}
	public String getIEmploy_update() {
		return iEmploy_update;
	}
	public void setIEmploy_update(String employ_update) {
		iEmploy_update = employ_update;
	}
	public String getIEmployCreate() {
		return iEmployCreate;
	}
	public void setIEmployCreate(String employCreate) {
		iEmployCreate = employCreate;
	}
	public String getIHouse() {
		return iHouse;
	}
	public void setIHouse(String house) {
		iHouse = house;
	}
	public String getILock() {
		return iLock;
	}
	public void setILock(String lock) {
		iLock = lock;
	}
	public String getIProject() {
		return iProject;
	}
	public void setIProject(String project) {
		iProject = project;
	}
	public String getITelCtasia() {
		return iTelCtasia;
	}
	public void setITelCtasia(String telCtasia) {
		iTelCtasia = telCtasia;
	}
	public String getITelNo() {
		return iTelNo;
	}
	public void setITelNo(String telNo) {
		iTelNo = telNo;
	}
	public String getNCustomer() {
		return nCustomer;
	}
	public void setNCustomer(String customer) {
		nCustomer = customer;
	}

	
	/*INSERT INTO lan:svc_telno (i_tel_ctasia, i_customer, i_company, 
			i_project, i_lock,
			d_create, i_employ_create, 
			d_update, i_employ_update, 
			n_customer, i_tel_no, 
			i_email, 
			i_house) VALUES ('', null, '', '', '', null, '', null, '', '', '', '', '');*/


}
