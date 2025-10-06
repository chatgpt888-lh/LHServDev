package serv.model;

import java.io.Serializable;
import java.util.ArrayList;

public class ServInfOpenJobBean implements Serializable{
	private String mode = "";				//E = edit, New = create
	
	//--- header table ---//
	private String i_project = "";			//รหัสโครงการ
	private String n_project = "";			//ชื่อโครงการ
	private String i_company = "";			//บริษัท
	private String i_docno = "";			//เลขที่ใบสั่งงานซ่อม 
	private String i_doc_type = "";			//J
	private String f_status  = "";			//new,opn,can,cls
	private String d_appoint = "";			//วันที่นัดซ่อม
	private String d_est_close = "";		//วันที่ประมาณการเสร็จ
	private String i_user = "";				//รหัสผู้ใช้งาน
	private String i_service_employ = "";	//รหัสพนักงานที่เปิด job
	private String n_service_employ = "";	//ชื่อพนักงานที่เปิด job
	private String n_position_employ = "";	//ตำแหน่งพนักงานที่เปิด job
	private String i_chart = "";			//S=Service Staff, M Service Manager, Z = Zone Manager
	private String i_approver = "";			//รหัสผู้อนุมัติ
	private String i_chart_grp = "";		//S,M,Z	ตามจำนวนเงินที่อนุมัติ
	private String f_reject = "";			//N
	
	private double p_amount = 0.0;			//วงเงินที่กำหนด
	
	
	//--- list open job ---//	
	private ArrayList listInfBoq = new ArrayList();

	private double totalWage = 0.0;
	private double totalGoods = 0.0;
	private double totalEstimate = 0.0;
	private double grandTotal = 0.0;
	
	//---------serter gerter --------------//
	public ArrayList getListInfBoq() {
		return listInfBoq;
	}
	
	public void setListInfBoq(ArrayList listInfBoq) {
		this.listInfBoq = listInfBoq;
	}

	public double getGrandTotal() {
		return grandTotal;
	}

	public void setGrandTotal(double grandTotal) {
		this.grandTotal = grandTotal;
	}

	public double getTotalEstimate() {
		return totalEstimate;
	}

	public void setTotalEstimate(double totalEstimate) {
		this.totalEstimate = totalEstimate;
	}

	public double getTotalGoods() {
		return totalGoods;
	}

	public void setTotalGoods(double totalGoods) {
		this.totalGoods = totalGoods;
	}

	public double getTotalWage() {
		return totalWage;
	}

	public void setTotalWage(double totalWage) {
		this.totalWage = totalWage;
	}

	public String getD_appoint() {
		return d_appoint;
	}

	public void setD_appoint(String d_appoint) {
		this.d_appoint = d_appoint;
	}

	public String getD_est_close() {
		return d_est_close;
	}

	public void setD_est_close(String d_est_close) {
		this.d_est_close = d_est_close;
	}

	public String getF_reject() {
		return f_reject;
	}

	public void setF_reject(String f_reject) {
		this.f_reject = f_reject;
	}

	public String getF_status() {
		return f_status;
	}

	public void setF_status(String f_status) {
		this.f_status = f_status;
	}

	public String getI_approver() {
		return i_approver;
	}

	public void setI_approver(String i_approver) {
		this.i_approver = i_approver;
	}

	public String getI_chart() {
		return i_chart;
	}

	public void setI_chart(String i_chart) {
		this.i_chart = i_chart;
	}

	public String getI_company() {
		return i_company;
	}

	public void setI_company(String i_company) {
		this.i_company = i_company;
	}

	public String getI_doc_type() {
		return i_doc_type;
	}

	public void setI_doc_type(String i_doc_type) {
		this.i_doc_type = i_doc_type;
	}

	public String getI_docno() {
		return i_docno;
	}

	public void setI_docno(String i_docno) {
		this.i_docno = i_docno;
	}

	public String getI_project() {
		return i_project;
	}

	public void setI_project(String i_project) {
		this.i_project = i_project;
	}

	public String getI_service_employ() {
		return i_service_employ;
	}

	public void setI_service_employ(String i_service_employ) {
		this.i_service_employ = i_service_employ;
	}

	public String getN_service_employ() {
		return n_service_employ;
	}

	public void setN_service_employ(String n_service_employ) {
		this.n_service_employ = n_service_employ;
	}

	public String getN_position_employ() {
		return n_position_employ;
	}

	public void setN_position_employ(String n_position_employ) {
		this.n_position_employ = n_position_employ;
	}

	public double getP_amount() {
		return p_amount;
	}

	public void setP_amount(double p_amount) {
		this.p_amount = p_amount;
	}

	public String getI_chart_grp() {
		return i_chart_grp;
	}

	public void setI_chart_grp(String i_chart_grp) {
		this.i_chart_grp = i_chart_grp;
	}

	public String getMode() {
		return mode;
	}

	public void setMode(String mode) {
		this.mode = mode;
	}

	public String getN_project() {
		return n_project;
	}

	public void setN_project(String n_project) {
		this.n_project = n_project;
	}

	public String getI_user() {
		return i_user;
	}

	public void setI_user(String i_user) {
		this.i_user = i_user;
	}

}
