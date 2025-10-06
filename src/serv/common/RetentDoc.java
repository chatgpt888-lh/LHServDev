package serv.common;
public class RetentDoc {
	private java.lang.String comId=null;
	private java.lang.String projId=null;	
	private java.lang.String docNo=null;
	private java.lang.String payType=null;	
	private double cashAmnt=0;
	private java.lang.String payDate=null;	
	private java.util.Vector chequelist = null;
	private java.lang.String labelNo=null;		
	public RetentDoc() {
		comId="";
		projId="";	
		docNo="";
		payType="";	
		cashAmnt=0;
		payDate="";	
		chequelist = new java.util.Vector(5);		
		labelNo = "";
	}	
	
	public void Init() {
		comId="";
		projId="";	
		docNo="";
		payType="";	
		cashAmnt=0;
		payDate="";	
		if (chequelist != null) {
			chequelist.removeAllElements();
		}
		labelNo = "";
	}
		
	/**
	 * Gets the comId
	 * @return Returns a java.lang.String
	 */
	public java.lang.String getComId() {
		return comId;
	}
	/**
	 * Sets the comId
	 * @param comId The comId to set
	 */
	public void setComId(java.lang.String comId) {
		this.comId = comId;
	}

	/**
	 * Gets the projId
	 * @return Returns a java.lang.String
	 */
	public java.lang.String getProjId() {
		return projId;
	}
	/**
	 * Sets the projId
	 * @param projId The projId to set
	 */
	public void setProjId(java.lang.String projId) {
		this.projId = projId;
	}

	/**
	 * Gets the docNo
	 * @return Returns a java.lang.String
	 */
	public java.lang.String getDocNo() {
		return docNo;
	}
	/**
	 * Sets the docNo
	 * @param docNo The docNo to set
	 */
	public void setDocNo(java.lang.String docNo) {
		this.docNo = docNo;
	}

	/**
	 * Gets the payType
	 * @return Returns a java.lang.String
	 */
	public java.lang.String getPayType() {
		return payType;
	}
	/**
	 * Sets the payType
	 * @param payType The payType to set
	 */
	public void setPayType(java.lang.String payType) {
		this.payType = payType;
	}

	/**
	 * Gets the cashAmnt
	 * @return Returns a double
	 */
	public double getCashAmnt() {
		return cashAmnt;
	}
	/**
	 * Sets the cashAmnt
	 * @param cashAmnt The cashAmnt to set
	 */
	public void setCashAmnt(double cashAmnt) {
		this.cashAmnt = cashAmnt;
	}

	/**
	 * Gets the payDate
	 * @return Returns a java.lang.String
	 */
	public java.lang.String getPayDate() {
		return payDate;
	}
	/**
	 * Sets the payDate
	 * @param payDate The payDate to set
	 */
	public void setPayDate(java.lang.String payDate) {
		this.payDate = payDate;
	}

	/**
	 * Gets the chequelist
	 * @return Returns a java.util.Vector
	 */
	public java.util.Vector getChequelist() {
		return chequelist;
	}
	/**
	 * Sets the chequelist
	 * @param chequelist The chequelist to set
	 */
	public void setChequelist(java.util.Vector chequelist) {
		this.chequelist = chequelist;
	}

	/**
	 * Gets the labelNo
	 * @return Returns a java.lang.String
	 */
	public java.lang.String getLabelNo() {
		return labelNo;
	}
	/**
	 * Sets the labelNo
	 * @param labelNo The labelNo to set
	 */
	public void setLabelNo(java.lang.String labelNo) {
		this.labelNo = labelNo;
	}

}

