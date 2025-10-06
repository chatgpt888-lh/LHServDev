package serv.model;

import java.io.Serializable;

public class ListInfOpenJobBean implements Serializable{
	private int no = 1;							//no.
	
	private int    i_seq 			= 0;						
	private String i_itmjob 		= "";		//เลขที่รายการซ่อม
	private String n_itmjob 		= "";		//รายการซ่อม
	private String i_itmtype 		= "";		//ประเภทงานซ่อม
	
	private String n_count 			= "";		//หน่วยนับ
	private String i_vender 		= "";		//ผู้รับเหมา
	private String bus_name 		= "";		//ผู้รับเหมา
	
	//--- รหัสบัญชี ---//
	private String com_acc			= "";		//บัญชีบริษัท
	private String cus_acc			= "";		//บัญชีลูกบ้าน
	private String com_acc1			= "";		//บัญชีบริษัท
	private String cus_acc1			= "";		//บัญชีลูกบ้าน
	private String com_acc2			= "";		//บัญชีบริษัท
	private String cus_acc2			= "";		//บัญชีลูกบ้าน	
	private String com_acc3			= "";		//บัญชีบริษัท
	private String cus_acc3			= "";		//บัญชีลูกบ้าน	

	
	//--- ค่าแรง ---//
	private boolean wage_boq		= false;
	private double custom_wage		= 0.0;		//ค่าแรงต่อหน่วย
	private double wage 			= 0.0;		//จำนวน
	private double wage_sum 		= 0.0;		//รวม
	
	//--- ค่าของ ---//
	private boolean goods_boq		= false;	
	private double custom_goods		= 0.0;		//ค่าของต่อหน่วย
	private double goods			= 0.0;		//จำนวน
	private double goods_sum 		= 0.0;		//รวม
	
	private double estimate			= 0.0;		//ประมาณการคชจ.ซ่อม
	private double sum_total		= 0.0;		//รวม
	
	private String comment 			= "";		//คอมเม้น
	private String area				= "";		//พื้นที่
	
	private String fileName			= "";		//ชื่อไฟล์
	private String itmFiName		= "";		//ชื่อไฟล์ที่สร้างใหม่
	private String f_itmstatus		= "";		//save = 100, send to approve = 200
	
	//------- set get method --------//
	public String getArea() {
		return area;
	}
	public void setArea(String area) {
		this.area = area;
	}
	public String getBus_name() {
		return bus_name;
	}
	public void setBus_name(String bus_name) {
		this.bus_name = bus_name;
	}
	public String getComment() {
		return comment;
	}
	public void setComment(String comment) {
		this.comment = comment;
	}
	public double getCustom_goods() {
		return custom_goods;
	}
	public void setCustom_goods(double custom_goods) {
		this.custom_goods = custom_goods;
	}
	public double getCustom_wage() {
		return custom_wage;
	}
	public void setCustom_wage(double custom_wage) {
		this.custom_wage = custom_wage;
	}
	public double getEstimate() {
		return estimate;
	}
	public void setEstimate(double estimate) {
		this.estimate = estimate;
	}
	public double getGoods() {
		return goods;
	}
	public void setGoods(double goods) {
		this.goods = goods;
	}
	public double getGoods_sum() {
		return goods_sum;
	}
	public void setGoods_sum(double goods_sum) {
		this.goods_sum = goods_sum;
	}
	public String getI_itmjob() {
		return i_itmjob;
	}
	public void setI_itmjob(String i_itmjob) {
		this.i_itmjob = i_itmjob;
	}
	public String getI_vender() {
		return i_vender;
	}
	public void setI_vender(String i_vender) {
		this.i_vender = i_vender;
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
	public int getNo() {
		return no;
	}
	public void setNo(int no) {
		this.no = no;
	}
	public double getSum_total() {
		return sum_total;
	}
	public void setSum_total(double sum_total) {
		this.sum_total = sum_total;
	}
	public double getWage() {
		return wage;
	}
	public void setWage(double wage) {
		this.wage = wage;
	}
	public double getWage_sum() {
		return wage_sum;
	}
	public void setWage_sum(double wage_sum) {
		this.wage_sum = wage_sum;
	}
	public String getF_itmstatus() {
		return f_itmstatus;
	}
	public void setF_itmstatus(String f_itmstatus) {
		this.f_itmstatus = f_itmstatus;
	}
	public int getI_seq() {
		return i_seq;
	}
	public void setI_seq(int i_seq) {
		this.i_seq = i_seq;
	}
	public String getI_itmtype() {
		return i_itmtype;
	}
	public void setI_itmtype(String i_itmtype) {
		this.i_itmtype = i_itmtype;
	}
	public String getFileName() {
		return fileName;
	}
	public void setFileName(String fileName) {
		this.fileName = fileName;
	}
	public String getItmFiName() {
		return itmFiName;
	}
	public void setItmFiName(String itmFiName) {
		this.itmFiName = itmFiName;
	}
	public boolean isGoods_boq() {
		return goods_boq;
	}
	public void setGoods_boq(boolean goods_boq) {
		this.goods_boq = goods_boq;
	}
	public boolean isWage_boq() {
		return wage_boq;
	}
	public void setWage_boq(boolean wage_boq) {
		this.wage_boq = wage_boq;
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
	public String getCom_acc1() {
		return com_acc1;
	}
	public void setCom_acc1(String com_acc1) {
		this.com_acc1 = com_acc1;
	}
	public String getCom_acc2() {
		return com_acc2;
	}
	public void setCom_acc2(String com_acc2) {
		this.com_acc2 = com_acc2;
	}
	public String getCom_acc3() {
		return com_acc3;
	}
	public void setCom_acc3(String com_acc3) {
		this.com_acc3 = com_acc3;
	}
	public String getCus_acc1() {
		return cus_acc1;
	}
	public void setCus_acc1(String cus_acc1) {
		this.cus_acc1 = cus_acc1;
	}
	public String getCus_acc2() {
		return cus_acc2;
	}
	public void setCus_acc2(String cus_acc2) {
		this.cus_acc2 = cus_acc2;
	}
	public String getCus_acc3() {
		return cus_acc3;
	}
	public void setCus_acc3(String cus_acc3) {
		this.cus_acc3 = cus_acc3;
	}

}
