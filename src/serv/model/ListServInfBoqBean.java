package serv.model;

import java.io.Serializable;
import java.util.ArrayList;

public class ListServInfBoqBean implements Serializable{
	//--- search condition ---//
	private String n_itmjob = ""; 		//รายการซ่อม
	private String i_group  = ""; 		//หมวดการซ่อม
	private String i_type	= ""; 		//ประเภท
	private String display_line = ""; 	//จำนวนรายการต่อหน้า  
	private String display_type = "";	//ListByPage,ListALL
	
	private int max_row = 0;			
	private int pageNow = 0;
	private ArrayList listBean = new ArrayList();	//list รายการซ่อม

	//-----------------
	public ArrayList getListBean() {
		return listBean;
	}

	public void setListBean(ArrayList listBean) {
		this.listBean = listBean;
	}

	public int getMax_row() {
		return max_row;
	}

	public void setMax_row(int max_row) {
		this.max_row = max_row;
	}

	public String getDisplay_line() {
		return display_line;
	}

	public void setDisplay_line(String display_line) {
		this.display_line = display_line;
	}

	public String getI_group() {
		return i_group;
	}

	public void setI_group(String i_group) {
		this.i_group = i_group;
	}

	public String getI_type() {
		return i_type;
	}

	public void setI_type(String i_type) {
		this.i_type = i_type;
	}

	public String getN_itmjob() {
		return n_itmjob;
	}

	public void setN_itmjob(String n_itmjob) {
		this.n_itmjob = n_itmjob;
	}

	public int getPageNow() {
		return pageNow;
	}

	public void setPageNow(int pageNow) {
		this.pageNow = pageNow;
	}

	public String getDisplay_type() {
		return display_type;
	}

	public void setDisplay_type(String display_type) {
		this.display_type = display_type;
	}


}
