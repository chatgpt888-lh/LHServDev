package serv.common;

/**
 * Insert the type's description here.
 * Creation date: (19/9/2002 17:20:56)
 * @author: Administrator
 */
import serv.exception.InvalidChequeException;
public class Cheque {
	private java.lang.String chequeId;
	private java.lang.String chqDate;
	private java.lang.String payDate;	
	private java.lang.String bank;
	private java.lang.String branch;
	private double amount;
	private int item;
	private java.lang.String rcvType;
	private java.lang.String mType;	
	private int payinNo;
/**
 * Cheque constructor comment.
 */
public Cheque() {
	chequeId = "";
	chqDate = "";
	payDate = "";	
	bank = "";
	branch = "";
	amount = 0;
}
/**
 * Insert the method's description here.
 * Creation date: (20/9/2002 15:48:58)
 * @param amount float
 */
public Cheque(double amount) {
	chequeId = "";
	chqDate = "";
	bank = "";
	branch = "";	
	this.amount = amount;
}
/**
 * Insert the method's description here.
 * Creation date: (20/9/2002 15:48:58)
 * @param amount float
 */
public Cheque(String chequeId, double amount, String mType) {
	this.chequeId = chequeId;
	this.amount = amount;
	this.mType = mType;
}
/**
 * Cheque constructor comment.
 */
public Cheque(String chequeId, String rcvType, int itemNo) throws InvalidChequeException {
	this.chequeId = chequeId;	
	this.rcvType = rcvType;
	this.item = itemNo;
}

public Cheque(String chequeId, String rcvType, int itemNo, String chqDate) throws InvalidChequeException {
	this.chequeId = chequeId;	
	this.rcvType = rcvType;
	this.item = itemNo;
	this.chqDate = chqDate;
}

/**
 * Cheque constructor comment.
 */
public Cheque(String chequeId, String bank, String branch, double amount) throws InvalidChequeException {
	if (chequeId.equals("")) {
		throw new InvalidChequeException("เลขที่เช็คผิดพลาด");
	}	
	this.chequeId = chequeId;	
	this.bank = bank;
	
	this.branch = branch;
	if (amount <= 0) {
		throw new InvalidChequeException("โปรดระบุจำนวนเงิน");
	}
	this.amount = amount;
}

public Cheque(String chequeId, String chqDate, String payDate, String bank, String branch, double amount) throws InvalidChequeException {
	if (chequeId.equals("")) {
		throw new InvalidChequeException("เลขที่เช็คผิดพลาด");
	}	
	this.chequeId = chequeId;	
	this.chqDate = chqDate;
	this.payDate = payDate;	
	this.bank = bank;
	this.branch = branch;
	if (amount <= 0) {
		throw new InvalidChequeException("โปรดระบุจำนวนเงิน");
	}
	this.amount = amount;
}

/**
 * Insert the method's description here.
 * Creation date: (20/9/2002 10:20:23)
 * @return float
 */
public double getAmount() {
	return amount;
}
/**
 * Insert the method's description here.
 * Creation date: (19/9/2002 17:21:37)
 * @return java.lang.String
 */
public java.lang.String getBank() {
	return bank;
}
/**
 * Insert the method's description here.
 * Creation date: (19/9/2002 17:21:58)
 * @return java.lang.String
 */
public java.lang.String getBranch() {
	return branch;
}
/**
 * Insert the method's description here.
 * Creation date: (19/9/2002 17:21:19)
 * @return java.lang.String
 */
public java.lang.String getChequeId() {
	return chequeId;
}
/**
 * Insert the method's description here.
 * Creation date: (20/9/2002 17:33:10)
 * @return int
 */
public int getItem() {
	return item;
}
/**
 * Insert the method's description here.
 * Creation date: (1/10/2002 10:12:29)
 * @return java.lang.String
 */
public java.lang.String getMType() {
	return mType;
}
/**
 * Insert the method's description here.
 * Creation date: (2/10/2002 10:29:58)
 * @return int
 */
public int getPayinNo() {
	return payinNo;
}
/**
 * Insert the method's description here.
 * Creation date: (26/9/2002 17:11:24)
 * @return java.lang.String
 */
public java.lang.String getRcvType() {
	return rcvType;
}
/**
 * Insert the method's description here.
 * Creation date: (20/9/2002 10:20:23)
 * @param newAmount float
 */
public void setAmount(double newAmount) {
	amount = newAmount;
}
/**
 * Insert the method's description here.
 * Creation date: (19/9/2002 17:21:37)
 * @param newBank java.lang.String
 */
public void setBank(java.lang.String newBank) {
	bank = newBank;
}
/**
 * Insert the method's description here.
 * Creation date: (19/9/2002 17:21:58)
 * @param newBranch java.lang.String
 */
public void setBranch(java.lang.String newBranch) {
	branch = newBranch;
}
/**
 * Insert the method's description here.
 * Creation date: (19/9/2002 17:21:19)
 * @param newChequeId java.lang.String
 */
public void setChequeId(java.lang.String newChequeId) {
	chequeId = newChequeId;
}

	public void setPayDate(String payDate) {
		this.payDate = payDate;
	}

/**
 * Insert the method's description here.
 * Creation date: (20/9/2002 17:33:10)
 * @param newItem int
 */
public void setItem(int newItem) {
	item = newItem;
}
/**
 * Insert the method's description here.
 * Creation date: (1/10/2002 10:12:29)
 * @param newMType java.lang.String
 */
public void setMType(java.lang.String newMType) {
	mType = newMType;
}
/**
 * Insert the method's description here.
 * Creation date: (2/10/2002 10:29:58)
 * @param newPayinNo int
 */
public void setPayinNo(int newPayinNo) {
	payinNo = newPayinNo;
}
/**
 * Insert the method's description here.
 * Creation date: (26/9/2002 17:11:24)
 * @param newRcvType java.lang.String
 */
public void setRcvType(java.lang.String newRcvType) {
	rcvType = newRcvType;
}
	/**
	 * Gets the chqDate
	 * @return Returns a java.lang.String
	 */
	public java.lang.String getChqDate() {
		return chqDate;
	}
	
	/**
	 * Gets the chqDate
	 * @return Returns a java.lang.String
	 */
	public java.lang.String getPayDate() {
		return payDate;
	}
		
	/**
	 * Sets the chqDate
	 * @param chqDate The chqDate to set
	 */
	public void setChqDate(java.lang.String chqDate) {
		this.chqDate = chqDate;
	}

}
