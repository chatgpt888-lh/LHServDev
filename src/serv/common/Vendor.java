package serv.common;

/**
 * Insert the type's description here.
 * Creation date: (17/11/2006 15:55:22)
 * @author: Administrator
 */
public class Vendor {
	private java.lang.String comId;
	private java.lang.String projId;
	private java.lang.String sortId;
	private java.lang.String id;
	private java.lang.String preName;
	private java.lang.String name;
	private java.lang.String surName;
	private java.lang.String telephone;
	private java.lang.String type;
	private java.lang.String address1;
	private java.lang.String address2;
/**
 * Vendor constructor comment.
 */
public Vendor() {
		comId = "";
		projId = "";
		sortId = "";
		id = "";
		preName = "";
		name = "";
		surName = "";
		telephone = "";
		type = "";
		address1="";
		address2="";
}
/**
 * Vendor constructor comment.
 */
public Vendor(String id, String pname, String name, String sname, String telephone) {
		this.id = id;
		preName = pname;
		this.name = name;
		surName = sname;
		this.telephone = telephone;
}
/**
 * Insert the method's description here.
 * Creation date: (17/11/2006 15:55:45)
 * @return java.lang.String
 */
public java.lang.String getId() {
	return id;
}
/**
 * Insert the method's description here.
 * Creation date: (17/11/2006 15:56:20)
 * @return java.lang.String
 */
public java.lang.String getName() {
	return name;
}
/**
 * Insert the method's description here.
 * Creation date: (17/11/2006 15:56:07)
 * @return java.lang.String
 */
public java.lang.String getPreName() {
	return preName;
}
/**
 * Insert the method's description here.
 * Creation date: (17/11/2006 15:56:39)
 * @return java.lang.String
 */
public java.lang.String getSurName() {
	return surName;
}
/**
 * Insert the method's description here.
 * Creation date: (17/11/2006 15:56:55)
 * @return java.lang.String
 */
public java.lang.String getTelephone() {
	return telephone;
}
/**
 * Insert the method's description here.
 * Creation date: (17/11/2006 15:55:45)
 * @param newId java.lang.String
 */
public void setId(java.lang.String newId) {
	id = newId;
}
/**
 * Insert the method's description here.
 * Creation date: (17/11/2006 15:56:20)
 * @param newName java.lang.String
 */
public void setName(java.lang.String newName) {
	name = newName;
}
/**
 * Insert the method's description here.
 * Creation date: (17/11/2006 15:56:07)
 * @param newPreName java.lang.String
 */
public void setPreName(java.lang.String newPreName) {
	preName = newPreName;
}
/**
 * Insert the method's description here.
 * Creation date: (17/11/2006 15:56:39)
 * @param newSurName java.lang.String
 */
public void setSurName(java.lang.String newSurName) {
	surName = newSurName;
}
/**
 * Insert the method's description here.
 * Creation date: (17/11/2006 15:56:55)
 * @param newTelephone java.lang.String
 */
public void setTelephone(java.lang.String newTelephone) {
	telephone = newTelephone;
}
	/**
	 * @return
	 */
	public java.lang.String getComId() {
		return comId;
	}

	/**
	 * @return
	 */
	public java.lang.String getProjId() {
		return projId;
	}

	/**
	 * @return
	 */
	public java.lang.String getSortId() {
		return sortId;
	}

	/**
	 * @param string
	 */
	public void setComId(java.lang.String string) {
		comId = string;
	}

	/**
	 * @param string
	 */
	public void setProjId(java.lang.String string) {
		projId = string;
	}

	/**
	 * @param string
	 */
	public void setSortId(java.lang.String string) {
		sortId = string;
	}

	/**
	 * @return
	 */
	public java.lang.String getType() {
		return type;
	}

	/**
	 * @param string
	 */
	public void setType(java.lang.String string) {
		type = string;
	}

	/**
	 * @return
	 */
	public java.lang.String getAddress1() {
		return address1;
	}

	/**
	 * @return
	 */
	public java.lang.String getAddress2() {
		return address2;
	}

	/**
	 * @param string
	 */
	public void setAddress1(java.lang.String string) {
		address1 = string;
	}

	/**
	 * @param string
	 */
	public void setAddress2(java.lang.String string) {
		address2 = string;
	}

}
