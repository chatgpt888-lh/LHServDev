package com.test;

import java.io.ByteArrayOutputStream;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.Iterator;

import com.lh.util.doString;
import com.lowagie.text.Document;
import com.lowagie.text.PageSize;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfImportedPage;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfReader;
import com.lowagie.text.pdf.PdfWriter;

public class TestPrintPassword {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub

		   String workingDir = System.getProperty("user.dir");
		   System.out.println("Current working directory : " + workingDir);
		    try {
		    	String path =  "D://usr//IBM//workspace2013//LHServ//WebContent//template//Doc1.pdf";
		    	//reader = new PdfReader(path+"/Doc1.pdf");
		        Document document = new Document();
		        PdfWriter.getInstance(document, new FileOutputStream(path));
		        document.open();
		        
		        //addMetaData(document);
		        //addTitlePage(document);
		        //addContent(document);
		        
		        document.close();
		      } catch (Exception e) {
		        e.printStackTrace();
		      }
		   
		   
		   
	}
	
	protected ByteArrayOutputStream doGenPDFPaper(ArrayList result) throws Exception{
		
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		//try{				
			if(result !=null && result.size()>0){
					//List strArr = null;
				
					String []strArr = null;
				 	//DecimalFormat dd = new DecimalFormat("#,###,##0.00");		
					//String workingDir = System.getProperty("user.dir");
					//D:\\usr\\IBM\workspace2013\LHServ
					
					
				 	//-------- Start Generate PDF File --------//
					String path =  "D://usr//IBM//workspace2013//LHServ//WebContent//template/";
					//getServletContext().getRealPath("/")+"/template";
					String Thai_TTFB =  "D://usr//IBM//workspace2013//LHServ//WebContent//Fonts//CORDIA.TTF";
					//getServletContext().getRealPath("/")+"/Fonts/CORDIA.TTF";
					
					BaseFont bf = BaseFont.createFont(Thai_TTFB, BaseFont.IDENTITY_H, BaseFont.EMBEDDED);//
					
					//Font microSanf = new Font(bf, 18, Font.NORMAL,new Color(110,110,110));				
					Document document = new Document(PageSize.A4, 0, 0, 0, 0);
					//ByteArrayOutputStream baos = new ByteArrayOutputStream();
					PdfWriter writer = PdfWriter.getInstance(document, baos);
					PdfContentByte cb = writer.getDirectContent();	
					PdfReader reader = null;
					PdfPTable table = new PdfPTable(100);
					table.setWidthPercentage(100);				
					//document = new Document(PageSize.A4, 10, 10, 10, 10);
					document = new Document(PageSize.A4, 0, 0, 0, 0);
					baos = new ByteArrayOutputStream();
					writer = PdfWriter.getInstance(document, baos);			
					cb = writer.getDirectContent();				
					/************************************/
					document.open();	
					PdfImportedPage page1 = null;
					
					/** Load Template && Set Header  **/
					//set setTextMatrix x,y
					//X++>> is column 
					//Y++ 0 ^ uper 
					/**********************************/	
					Iterator it = result.iterator();					
					//First Load Page
			    	//System.out.println("**********************************");
			    	//System.out.println("**     LOAD Template & HEAD     **");
			    	//System.out.println("**********************************");
					document.newPage();  
					
					reader = new PdfReader(path+"/Doc1.pdf");		
					//reader = new PdfReader(path+"/form_pwd_cust.pdf");						  
					page1 = writer.getImportedPage(reader, 1);	
					cb.addTemplate(page1, 0, 0);							     								
					cb.setFontAndSize(bf, 14);
					//******************set Header krub.
					int X_60 = 60;
					int X_300= 300;
					int X_505 = 505;
					
					//********************** -->First Position
					int Y_NAME  = 820;//820;
					int Y_PROJ  = 800;//800;						
					int Y_LOGIN = 670;//654;
					int Y_PASS  = 650;// 634;
					//*********************
			    	int row = 0;
			    	int loop = 1;
			    	//int ii = 1;

			    	//int maxRow = result.size();
			    	while(it.hasNext()){	
			    								
						if(row<=2){
							strArr = (String[])it.next();
				    		//Fetch Data to page //0,1,2		    		 					    		
							if(row == 1){//LOOP2
								//-->second Position
								Y_NAME = 540;
								Y_PROJ = 520;
								Y_LOGIN = 390;
								Y_PASS  = 370;
							}else if(row == 2){//LOOP3
								//---->third Position
								Y_NAME = 260;
								Y_PROJ = 240;
								Y_LOGIN = 110;
								Y_PASS = 90;
							}else{
								//**-->First Position
								//Reset 
							    X_60 = 60;
								X_300= 300;
								 
								Y_NAME  = 820;
								Y_PROJ  = 800;										
								Y_LOGIN = 670;
								Y_PASS  = 650;
							}
							//**********************LOOP1

							cb.beginText();	
							//CUSTOMER NAME  LASTNAME 
							cb.setTextMatrix(X_60, Y_NAME);
							cb.showText(doString.DisplayThai(strArr[0])); 
							//I_HOUSE, PROJECT NAME THAI
							cb.setTextMatrix(X_60, Y_PROJ);
							cb.showText(strArr[3]+"  "+doString.DisplayThai(strArr[4]));
							 //LOGIN
							cb.setTextMatrix(X_300, Y_LOGIN);
							cb.showText("Login : "+strArr[1]);
							//PASSWORD
							cb.setTextMatrix(X_300, Y_PASS);
							cb.showText("Password : "+strArr[2]); 	
							

							cb.setTextMatrix(X_505, Y_NAME);
							cb.showText("P : "+loop); 	
							
							cb.endText();	
				    		row++;
				    		loop++;
				    	 }else{
				    		/* if(loop==maxRow){
				    			 break;
				    		 }	*/				    		 
				    		//Second Load Page or New Load page
				    		//System.out.println("****************Page 2 XXX*****************");
				    		//System.out.println("*     LOAD Template & HEAD      *");
				    		//System.out.println("*****************Page 2XXX****************");								
				    		
				    		 document.newPage();  
				    		 reader = new PdfReader(path+"/Doc1.pdf");
							 //reader = new PdfReader(path+"/form_pwd_cust.pdf");						  
							 page1 = writer.getImportedPage(reader, 1);	
							 cb.addTemplate(page1, 0, 0);							     								
							 cb.setFontAndSize(bf, 14);
							 /*********************************************/
							 X_60 = 60;
							 X_300= 300;		
							 
							 //********************** -->First Position
							Y_NAME  = 820;
							Y_PROJ  = 800;										
							Y_LOGIN = 670;
							Y_PASS  = 650;
						    //********************** 								 
							row = 0;
							//loop++;
						}
					}//END while
					//************************************************************		
					document.close();	
					System.out.println(" *** PDF Gen Complete **** ");
			}
		return baos;
	}

}
