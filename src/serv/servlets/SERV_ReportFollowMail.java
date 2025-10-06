package serv.servlets;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.URL;
import java.net.URLConnection;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.lh.servlet.DBServlet;
import com.lh.util.doString;

import serv.util.LHSendMail;

public class SERV_ReportFollowMail extends DBServlet{
	//2017-02-06 private final static String FOLLOW_MAIL_GROUP = "piyapong@lh.co.th,prapat@lh.co.th,puwanai@lh.co.th,sutida@lh.co.th,JPornchai@lh.co.th,YSomkiat@lh.co.th,schawengkiat@lh.co.th, payak@lh.co.th";
	//2018-06-14 private final static String FOLLOW_MAIL_GROUP = "piyapong@lh.co.th,prapat@lh.co.th,puwanai@lh.co.th,nattapong@lh.co.th,jerdpong@lh.co.th,tawatchai@lh.co.th";
	private final static String FOLLOW_MAIL_GROUP = "narong@lh.co.th , techin@lh.co.th";
	
	
	private final static String FOLLOW_MAIL_GROUP_CC = "sombat@lh.co.th,wichai@lh.co.th,Kriangkrai@lh.co.th,wannavar@lh.co.th,watinee@lh.co.th";
	//private final static String FOLLOW_MAIL_GROUP_CC = "";
	
	//config
	private String domain = "lh.co.th";
	private String sender = "application";
	private String sendto = "";
	private String sendcc = "";
	private String mailTitle = "";
	private String mailHeader = "";
	private String mailFooter = "";
	
	public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		String mName = new String(this.getClass().getName() + ".performTask: ");
		System.out.println(mName + "start.");
		res.setContentType("text/html; charset=TIS620");
		
		try{
			
			//getMailHeader(req.getScheme() + "://" + req.getServerName() + ":" + req.getServerPort() + req.getContextPath()+"/SERV_ReportFollowMobile.jsp?header=Y");
	        //getMailHeader("http://localhost:9080/LHServ/SERV_ReportFollow.html");
			getMailHeader(req.getScheme() + "://" + req.getServerName() + ":" + req.getServerPort() + req.getContextPath()+"/SERV_ReportFollowMobile.jsp");
			sendto = SERV_ReportFollowMail.FOLLOW_MAIL_GROUP;
			sendcc = SERV_ReportFollowMail.FOLLOW_MAIL_GROUP_CC;
			mailTitle = "Service Follow Report";
			sendMail();
	        
	        PrintWriter out = res.getWriter();
	        out.println("<h1>" + "Send email : Service follow response." + "</h1>"); 
		}catch(IOException ioe){
			ioe.printStackTrace();
		}catch(Exception e){
			e.printStackTrace();
		}
	}
	
	public void getMailHeader(String urlArg) throws IOException {
		StringBuffer sourceCode = new StringBuffer("");
		URL url = new URL(urlArg);
        URLConnection urlConn = url.openConnection();
        BufferedReader in = new BufferedReader(new InputStreamReader(urlConn.getInputStream()));
        String inputLine;
        while ((inputLine = in.readLine()) != null) {
        	sourceCode.append(inputLine);
        }
        in.close(); 
        mailHeader = doString.MS874ToUnicode(sourceCode.toString());
	}
	public void getMailFooter(String urlArg) throws IOException {
		StringBuffer sourceCode = new StringBuffer("");
		URL url = new URL(urlArg);
        URLConnection urlConn = url.openConnection();
        BufferedReader in = new BufferedReader(new InputStreamReader(urlConn.getInputStream()));
        String inputLine;
        while ((inputLine = in.readLine()) != null) {
        	sourceCode.append(inputLine);
        }
        in.close(); 
        mailFooter = doString.MS874ToUnicode(sourceCode.toString());
	}
	public void sendMail(){
		LHSendMail.sendMail(domain, sender, sendto, sendcc, mailTitle , mailHeader+mailFooter);
	}
}
