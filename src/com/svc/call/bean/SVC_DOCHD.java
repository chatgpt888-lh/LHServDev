package com.svc.call.bean;

import java.util.ArrayList;

public class SVC_DOCHD {
	private String i_svc_docno;
	private String i_tel_ctasia;
	private String i_company;
	private String i_project;
	private String i_lock;
	private String d_keyin;
	private String i_customer;
	private String i_house;
	private String n_customer;
	private String n_custel;
	private String f_status;
	private String i_agent;
	private String i_employ;
	private String employName;
	private String i_date;
	private ArrayList<SVC_DOCDT> SvcDocdtList;
	
	
	public String getD_keyin() {
		return d_keyin;
	}
	public void setD_keyin(String d_keyin) {
		this.d_keyin = d_keyin;
	}
	public String getF_status() {
		return f_status;
	}
	public void setF_status(String f_status) {
		this.f_status = f_status;
	}
	public String getI_agent() {
		return i_agent;
	}
	public void setI_agent(String i_agent) {
		this.i_agent = i_agent;
	}
	public String getI_company() {
		return i_company;
	}
	public void setI_company(String i_company) {
		this.i_company = i_company;
	}
	public String getI_customer() {
		return i_customer;
	}
	public void setI_customer(String i_customer) {
		this.i_customer = i_customer;
	}
	public String getI_employ() {
		return i_employ;
	}
	public void setI_employ(String i_employ) {
		this.i_employ = i_employ;
	}
	public String getI_house() {
		return i_house;
	}
	public void setI_house(String i_house) {
		this.i_house = i_house;
	}
	public String getI_lock() {
		return i_lock;
	}
	public void setI_lock(String i_lock) {
		this.i_lock = i_lock;
	}
	public String getI_project() {
		return i_project;
	}
	public void setI_project(String i_project) {
		this.i_project = i_project;
	}
	public String getI_svc_docno() {
		return i_svc_docno;
	}
	public void setI_svc_docno(String i_svc_docno) {
		this.i_svc_docno = i_svc_docno;
	}
	public String getI_tel_ctasia() {
		return i_tel_ctasia;
	}
	public void setI_tel_ctasia(String i_tel_ctasia) {
		this.i_tel_ctasia = i_tel_ctasia;
	}
	public String getN_custel() {
		return n_custel;
	}
	public void setN_custel(String n_custel) {
		this.n_custel = n_custel;
	}
	public String getN_customer() {
		return n_customer;
	}
	public void setN_customer(String n_customer) {
		this.n_customer = n_customer;
	}
	
	public ArrayList<SVC_DOCDT> getSvcDocdtList() {
		return SvcDocdtList;
	}
	public void setSvcDocdtList(ArrayList<SVC_DOCDT> svcDocdtList) {
		SvcDocdtList = svcDocdtList;
	}
	public String getEmployName() {
		return employName;
	}
	public void setEmployName(String employName) {
		this.employName = employName;
	}
	public String getI_date() {
		return i_date;
	}
	public void setI_date(String i_date) {
		this.i_date = i_date;
	}

}
