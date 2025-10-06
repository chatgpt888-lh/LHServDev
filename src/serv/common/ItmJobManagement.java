package serv.common;

import java.util.*;
import java.text.*;
import javax.servlet.http.*;
import com.lh.util.*;

public class ItmJobManagement {
	
   private  HttpServletRequest req;
   private HttpServletResponse res;
   private HttpSession sess;
   
   private Vector jobList;
   private Hashtable itmJobList;
   private Hashtable itmSeqList;
   private Hashtable vendorList;
   private Hashtable wageList;
   private Hashtable customWageList;
   private Hashtable goodsList;
   private Hashtable customGoodsList;
   private Hashtable BOQList;
   private Hashtable commentList;
   private Hashtable areaList;
   private Hashtable fContractList;
   
   public static String SESSION_JOBLIST = "sess_joblist";
   public static String SESSION_ITMJOBLIST = "sess_itmjoblist";
   public static String SESSION_ITMSEQLIST = "sess_itmseqlist";
   public static String SESSION_VENDOR = "sess_jobvendor";
   public static String SESSION_WAGE = "sess_jobwage";
   public static String SESSION_CUSTOM_WAGE = "sess_customwage";
   public static String SESSION_GOODS = "sess_jobgoods";
   public static String SESSION_CUSTOM_GOODS = "sess_customgoods";
   public static String SESSION_BOQ = "sess_jobboq";
   public static String SESSION_COMMENT = "sess_jobcomment";
   public static String SESSION_AREA = "sess_jobarea";
   public static String SESSION_FCONTRACT = "sess_f_contract";
   

   public ItmJobManagement(HttpServletRequest req,HttpServletResponse res) {
   	    this.req=req;
   	    this.res=res;
   	    this.sess = req.getSession();
   	    this.updateItemListFromSession();
   }
   
   public void updateItemListFromSession() {
		this.jobList = getVector(SESSION_JOBLIST);
    	this.itmJobList = getHashtable(SESSION_ITMJOBLIST);
	    this.itmSeqList = getHashtable(SESSION_ITMSEQLIST);
		this.vendorList = getHashtable(SESSION_VENDOR);
		this.wageList = getHashtable(SESSION_WAGE);
	    this.customWageList = getHashtable(SESSION_CUSTOM_WAGE);
		this.goodsList = getHashtable(SESSION_GOODS);
	    this.customGoodsList = getHashtable(SESSION_CUSTOM_GOODS);
		this.BOQList = getHashtable(SESSION_BOQ);
		this.commentList = getHashtable(SESSION_COMMENT);
		this.areaList = getHashtable(SESSION_AREA);
		this.fContractList = getHashtable(SESSION_FCONTRACT);
   }
   
   private Hashtable getHashtable(String sessKey) {
	   Hashtable result = (Hashtable) this.sess.getAttribute(sessKey);
	   if (result==null) result = new Hashtable();
	   return result;
   }    
      
   private Vector getVector(String sessKey) {
       Vector result = (Vector) this.sess.getAttribute(sessKey);
       if (result==null) result = new Vector();
       return result;
   } 
   
   public Vector getJobList() {
	   return this.jobList;
   }   
   
   public Hashtable getItmJobList() {
	   return this.itmJobList;
   }
   
   public Hashtable getItmSeqList() {
	   return this.itmSeqList;
   }   

   public Hashtable getVendorList() {
   	   return this.vendorList;
   }
       
   public Hashtable getWageList() {
	   return this.wageList;
   }
   
   public Hashtable getCustomWageList() {
	   return this.customWageList;
   }   
   
   public Hashtable getGoodsList() {
	   return this.goodsList;
   }
   
   public Hashtable getCustomGoodsList() {
	   return this.customGoodsList;
   }
                  
   public Hashtable getBOQList() {
	   return this.BOQList;
   }
   
   public Hashtable getCommentList() {
	   return this.commentList;
   }
   
   public Hashtable getAreaList() {
	   return this.areaList;
   }
   
   public Hashtable getFContractList() {
	   return this.fContractList;
   }   
   
   public void updateItemSession() {
   	  this.sess.setAttribute(SESSION_JOBLIST,this.jobList);
	  this.sess.setAttribute(SESSION_ITMJOBLIST,this.itmJobList);
	  this.sess.setAttribute(SESSION_ITMSEQLIST,this.itmSeqList);
	  this.sess.setAttribute(SESSION_VENDOR,this.vendorList);
	  this.sess.setAttribute(SESSION_WAGE,this.wageList);
  	  this.sess.setAttribute(SESSION_CUSTOM_WAGE,this.customWageList);
	  this.sess.setAttribute(SESSION_GOODS,this.goodsList);
      this.sess.setAttribute(SESSION_CUSTOM_GOODS,this.customGoodsList);
	  this.sess.setAttribute(SESSION_BOQ,this.BOQList);
	  this.sess.setAttribute(SESSION_COMMENT,this.commentList);
	  this.sess.setAttribute(SESSION_AREA,this.areaList);
	  this.sess.setAttribute(SESSION_FCONTRACT,this.fContractList);
   }
   
   public void removeItemSession() {
	  this.sess.removeAttribute(SESSION_JOBLIST);
   	  this.sess.removeAttribute(SESSION_ITMJOBLIST);
	  this.sess.removeAttribute(SESSION_ITMSEQLIST);
	  this.sess.removeAttribute(SESSION_VENDOR);
	  this.sess.removeAttribute(SESSION_WAGE);
 	  this.sess.removeAttribute(SESSION_CUSTOM_WAGE);
	  this.sess.removeAttribute(SESSION_GOODS);
	  this.sess.removeAttribute(SESSION_CUSTOM_GOODS);
	  this.sess.removeAttribute(SESSION_BOQ);
	  this.sess.removeAttribute(SESSION_COMMENT);
	  this.sess.removeAttribute(SESSION_AREA);
	  this.sess.removeAttribute(SESSION_FCONTRACT);
   }   
   
   public void removeItem(String itemKey) {
   	    //String itemKey = getItemKey(itmJob);
   	    //if (itemKey.length()==0) itemKey = itmJob;
		if (this.jobList.contains(itemKey)) {
			this.jobList.removeElement(itemKey); 
			this.itmJobList.remove(itemKey); 
			this.itmSeqList.remove(itemKey); 
			this.vendorList.remove(itemKey); 
			this.wageList.remove(itemKey); 
			this.customWageList.remove(itemKey); 
			this.goodsList.remove(itemKey); 
			this.customGoodsList.remove(itemKey); 
			this.BOQList.remove(itemKey); 
			this.commentList.remove(itemKey);                 
			this.areaList.remove(itemKey);
			this.fContractList.remove(itemKey);                         
		}
   }   
   
   public void addItem(String itmJob) {
		//if (!this.jobList.contains(itemKey)) {
		    String itemKey = itmJob+"_";
		    Random rand = new Random();
		    while (itemKey.length()<20) {
		    	itemKey += rand.nextInt(10); 
		    }
		     
			this.jobList.addElement(itemKey); 
         	this.itmJobList.put(itemKey,itmJob); 
	        this.itmSeqList.put(itemKey,""); 
			this.vendorList.put(itemKey,""); 
			this.wageList.put(itemKey,""); 
			this.customWageList.put(itemKey,""); 
			this.goodsList.put(itemKey,""); 
			this.customGoodsList.put(itemKey,""); 
			this.BOQList.put(itemKey,""); 
			this.commentList.put(itemKey,"");                 
			this.areaList.put(itemKey,"");
			this.fContractList.put(itemKey,"");
		//}
   }
   
   
   /*
   public String getItemKey(String itmJob) {
   	   String result = "";
   	   for (int i=0;i<jobList.size();i++) {
   	   	     String key = (String) jobList.elementAt(i);
   	   	     String id = (String) itmJobList.get(key);
   	   	     if (id!=null && id.equalsIgnoreCase(itmJob)) {
   	   	     	 result = key;
   	   	     	 break;
   	   	     }
   	   } // end for
   	   
   	   if (result.length()==0) result = itmJob;
   	   
   	   return result;
   }
   */
   
   public void updateValuesFromRequest() {
		Enumeration names = this.req.getParameterNames();
		while (names.hasMoreElements()) { 
			String name = doString.checkString((String) names.nextElement(),"");
	           
			//--============== Get Vendor ==============----//
			if (name.indexOf("_vendor")>0) {
			   String id = name.substring(0,name.indexOf("_vendor"));
			   String value = doString.checkString(this.req.getParameter(name),"");			   
			   this.vendorList.put(id,value);
			}
	                      
			//--============ Get Wage Unit ============----//
			if (name.indexOf("_wage")>0) {				
			   String id = name.substring(0,name.indexOf("_wage"));
			   String value = doString.checkString(this.req.getParameter(name),"0");
			   this.wageList.put(id,value);
			}
			
			//--============ Get Custom Wage Unit ============----//
			if (name.indexOf("_customwage")>0) {				
			   String id = name.substring(0,name.indexOf("_customwage"));
			   String value = doString.checkString(this.req.getParameter(name),"0");
			   this.customWageList.put(id,value);
			}			
	
			//--============ Get Goods Unit ============----//
			if (name.indexOf("_goods")>0) {
			   String id = name.substring(0,name.indexOf("_goods"));
			   String value = doString.checkString(this.req.getParameter(name),"0");
			   this.goodsList.put(id,value);
			}
			
			//--============ Get Custom Goods Unit ============----//
			if (name.indexOf("_customgoods")>0) {
			   String id = name.substring(0,name.indexOf("_customgoods"));
			   String value = doString.checkString(this.req.getParameter(name),"0");
			   this.customGoodsList.put(id,value);
			}			
	
			//--============ Get Comment ============----//
			if (name.indexOf("_comment")>0) {
			   String id = name.substring(0,name.indexOf("_comment"));
			   String value = doString.checkString(this.req.getParameter(name),"");
			   this.commentList.put(id,value);
			}
	
			//--============== Get Area ==============----//
			if (name.indexOf("_area")>0) {
			   String id = name.substring(0,name.indexOf("_area"));
			   String value = doString.checkString(this.req.getParameter(name),"");
			   this.areaList.put(id,value);
			}                     
			
			//--============== Get Area ==============----//
			if (name.indexOf("_f_contract")>0) {
			   String id = name.substring(0,name.indexOf("_f_contract"));
			   String value = doString.checkString(this.req.getParameter(name),"");
			   this.fContractList.put(id,value);
			}            
			
		} // end while          	
   }
   
}
