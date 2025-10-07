package serv.util;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;

import javax.mail.*;
import javax.mail.internet.*;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.activation.*;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

public class LHSendMail{
		public static void sendMail( String domain, String sender, String recipientsTO, String recipientsCC, String subject, String content) {
		try {
	    	Context ctx = new InitialContext();
			javax.mail.Session mailSession = (javax.mail.Session) ctx.lookup("mail/lhmail");
			ctx.close();
	        Transport transport = mailSession.getTransport();

	    	/* For Apache Tomcat
	        Properties props = System.getProperties();
	        props.put("mail.transport.protocol", "smtp");
	        props.put("mail.smtp.host", host);
			props.put("mail.smtp.port", "25");
			props.put("mail.smtp.user", "application");
			props.put("mail.smtp.password", "password");
	        props.put("mail.smtp.auth", "true");
	        // Get session
	        System.out.println(" LHSendMail : Get mail session.");
	        Session mailSession = Session.getInstance(props, new javax.mail.Authenticator() {
	            protected javax.mail.PasswordAuthentication getPasswordAuthentication() {
	                return new javax.mail.PasswordAuthentication("application", "password");
	            }
	        });
	        System.out.println(" LHSendMail : Get transport SMTP.");
	        Transport transport = mailSession.getTransport("smtp");
			transport.connect(host, "application", "password");
			*/
	    	
	    
	    	
	        MimeMessage message = new MimeMessage(mailSession);
	        message.setSubject(subject, "UTF-8");
	        message.setFrom(new InternetAddress(sender + "@" + domain));
	
	        InternetAddress to = null;
	        StringTokenizer st = new StringTokenizer(recipientsTO, ",");
	        while (st.hasMoreTokens()) {
	            to = new InternetAddress(st.nextToken());
	            message.addRecipient(Message.RecipientType.TO, to);
	        }
	        // Set the cc address
	        if (!recipientsCC.equals("")) {
	            st = new StringTokenizer(recipientsCC, ",");
	            while (st.hasMoreTokens()) {
	                to = new InternetAddress(st.nextToken());
	                message.addRecipient(Message.RecipientType.CC, to);
	            }
	        }
	        message.setSentDate(new java.util.Date());
	
	        // This HTML mail have to 2 part, the BODY and the embedded image
	        MimeMultipart multipart = new MimeMultipart("related");
	
	        // first part  (the html)
	        BodyPart messageBodyPart = new MimeBodyPart();
	        messageBodyPart.setContent(content, "text/html; charset=UTF-8");
	        // add it
	        multipart.addBodyPart(messageBodyPart);
	
	        
	        // second part (the image)
	        List<String> images = getImgURL(content);
	        if(images.size() > 0){
	        	for(String image:images){
			        messageBodyPart = new MimeBodyPart();
			        //DataSource fds = new FileDataSource("/LHServ/test/"+new File(image).getName());
			        messageBodyPart.setDataHandler(new DataHandler(new URL(pathImages+image.substring(4))));
			        messageBodyPart.setHeader("Content-ID","<"+image.substring(4)+">");
			        // add it
			        multipart.addBodyPart(messageBodyPart);
	        	}
	        }
	        
	        // put everything together
	        message.setContent(multipart);

	        System.out.println(" LHSendMail : Prepare mail...");
	        transport.send(message);
	        transport.close();
	        System.out.println("LHSendMail : Send mail to "+recipientsTO+" complete.");
	    } catch (Exception e) {
	        System.out.println("Error sendMail : "+e.getMessage());
	    } finally{
	    	
	    }
	}
	
	public static List<String> getImgURL(String htmlFile){
		Document doc = Jsoup.parse(htmlFile);
		Elements src = doc.select("img");
		List<String> srcUrls = new ArrayList<String>();
		for(Element element:src){
			srcUrls.add(element.attr("src"));
		}
		return srcUrls;
	}
}
