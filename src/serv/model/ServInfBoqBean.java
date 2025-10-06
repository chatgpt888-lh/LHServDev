package serv.model;

import java.io.Serializable;

public class ServInfBoqBean implements Serializable{
	private String checkbox = ""; 
	private String i_group = "";
	private String i_type = "";
	private String i_seq = "";
	private String i_itmjob = "";
	private String n_itmjob = "";
	private String z_wage_unit = "";
	private String z_good_unit = "";
	private String n_count = "";
	private String d_keyin = "";
	private String f_contract = "";
	private String com_acc = "";
	private String cus_acc = "";
	
	//---- seter gerter method  ---//
	public String getD_keyin() {
		return d_keyin;
	}
	public void setD_keyin(String d_keyin) {
		this.d_keyin = d_keyin;
	}
	public String getF_contract() {
		return f_contract;
	}
	public void setF_contract(String f_contract) {
		this.f_contract = f_contract;
	}
	public String getI_group() {
		return i_group;
	}
	public void setI_group(String i_group) {
		this.i_group = i_group;
	}
	public String getI_itmjob() {
		return i_itmjob;
	}
	public void setI_itmjob(String i_itmjob) {
		this.i_itmjob = i_itmjob;
	}
	public String getI_seq() {
		return i_seq;
	}
	public void setI_seq(String i_seq) {
		this.i_seq = i_seq;
	}
	public String getI_type() {
		return i_type;
	}
	public void setI_type(String i_type) {
		this.i_type = i_type;
	}
	public String getN_count() {
		return n_count;
	}
	public void setN_count(String n_count) {
		this.n_count = n_count;
	}
	public String getN_itmjob() {
		return n_itmjob;
	}
	public void setN_itmjob(String n_itmjob) {
		this.n_itmjob = n_itmjob;
	}
	public String getZ_wage_unit() {
		return z_wage_unit;
	}
	public void setZ_wage_unit(String z_wage_unit) {
		this.z_wage_unit = z_wage_unit;
	}
	public String getZ_good_unit() {
		return z_good_unit;
	}
	public void setZ_good_unit(String z_good_unit) {
		this.z_good_unit = z_good_unit;
	}
	public String getCheckbox() {
		return checkbox;
	}
	public void setCheckbox(String checkbox) {
		this.checkbox = checkbox;
	}
	public String getCom_acc() {
		return com_acc;
	}
	public void setCom_acc(String com_acc) {
		this.com_acc = com_acc;
	}
	public String getCus_acc() {
		return cus_acc;
	}
	public void setCus_acc(String cus_acc) {
		this.cus_acc = cus_acc;
	}
	
}
