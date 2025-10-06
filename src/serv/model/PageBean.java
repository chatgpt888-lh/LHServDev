package serv.model;

import java.io.Serializable;

public class PageBean implements Serializable{
	private int maxRow = 0;
	private int displayLine = 0;
	private int startRow = 0;
	private int endRow = 0;
	private int nowPage = 0;
	private int tmpMax = 0;
	private String pageLink = "";
	private int tmpPage = 0;
	
	public int getDisplayLine() {
		return displayLine;
	}
	public void setDisplayLine(int displayLine) {
		this.displayLine = displayLine;
	}
	public int getEndRow() {
		return endRow;
	}
	public void setEndRow(int endRow) {
		this.endRow = endRow;
	}
	public int getMaxRow() {
		return maxRow;
	}
	public void setMaxRow(int maxRow) {
		this.maxRow = maxRow;
	}
	public int getNowPage() {
		return nowPage;
	}
	public void setNowPage(int nowPage) {
		this.nowPage = nowPage;
	}
	public String getPageLink() {
		return pageLink;
	}
	public void setPageLink(String pageLink) {
		this.pageLink = pageLink;
	}
	public int getStartRow() {
		return startRow;
	}
	public void setStartRow(int startRow) {
		this.startRow = startRow;
	}
	public int getTmpMax() {
		return tmpMax;
	}
	public void setTmpMax(int tmpMax) {
		this.tmpMax = tmpMax;
	}
	public int getTmpPage() {
		return tmpPage;
	}
	public void setTmpPage(int tmpPage) {
		this.tmpPage = tmpPage;
	}
	
	
}
