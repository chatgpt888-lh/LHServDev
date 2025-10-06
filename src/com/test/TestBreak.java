package com.test;

public class TestBreak {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		
		//System.out.println("TEST :"+getMobileDisplay(null, "ddd"));
		subStringS();
	}
	
	private static void subStringS(){
		String a="You might have errors returned when you are trying to configure Secure Sockets Layer (SSL) for encrypted access. This article describes some of the common errors you might encounter and makes suggestions on how to fix the problems.";
		if(a.length()>50){
			System.out.println(""+a.substring(0,50));
		}
	}
	
	 public static String getMobileDisplay(String mobile1,String mobile2){
			String contact = "";
			
			if(mobile1==null){
				mobile1= "";
			}
			if(mobile2==null){
				mobile2= "";
			}
			
			if(!"".equals(mobile1) &&  !"".equals(mobile2)){
				 	contact = mobile1+","+mobile2;
			 }else{
			    if(!"".equals(mobile1)){
			    	contact += mobile1;
				}
			    if(!"".equals(mobile2)){
			    	contact += mobile2;
				}
			 }
			 return contact;
}

}
