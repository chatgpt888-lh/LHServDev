package com.svc.call.bean;

public class SVC_XSTD {
	private String i_type;
	private String i_code;	
	private String n_desc;
	private String f_date_display;
	private String i_date_type;
	private String f_end_job;
	
	public String getF_date_display() {
		return f_date_display;
	}
	public void setF_date_display(String f_date_display) {
		this.f_date_display = f_date_display;
	}
	public String getF_end_job() {
		return f_end_job;
	}
	public void setF_end_job(String f_end_job) {
		this.f_end_job = f_end_job;
	}
	public String getI_code() {
		return i_code;
	}
	public void setI_code(String i_code) {
		this.i_code = i_code;
	}
	public String getI_date_type() {
		return i_date_type;
	}
	public void setI_date_type(String i_date_type) {
		this.i_date_type = i_date_type;
	}
	public String getI_type() {
		return i_type;
	}
	public void setI_type(String i_type) {
		this.i_type = i_type;
	}
	public String getN_desc() {
		return n_desc;
	}
	public void setN_desc(String n_desc) {
		this.n_desc = n_desc;
	}
}
