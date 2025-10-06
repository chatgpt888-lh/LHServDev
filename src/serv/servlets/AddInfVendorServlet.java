package serv.servlets;

import java.io.*;
import java.util.*;

import javax.servlet.*;
import javax.servlet.http.*;

import com.lh.servlet.BaseHttpServlet;
import com.lh.util.doString;

import serv.common.Vendor;
public class AddInfVendorServlet extends BaseHttpServlet {
  private static String cName = "/LHServ/AddInfVendorServlet";
public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
	String mName = new String(cName + ".performTask: ");
	System.out.println(mName + "start.");

    HttpSession session = req.getSession(false);
    if (session == null) {
        /*
        * Redirect user to login page if
        * there's no session.
        */
        res.sendRedirect("/LHServ/warning.htm");
        return;
    }
    Object obj = session.getAttribute("USER");
    if (obj == null) {
        /*
        * Redirect user to login page if
        * there's no session.
        */
        res.sendRedirect("/LHServ/warning.htm");
        return;
    }
	Vendor vendor = (Vendor) session.getAttribute("Vendor");
	if (vendor == null)
		vendor = new Vendor();
	String targetPage = "/LHServ/save_ok.jsp?popup=true&venType=I&sortId=";
    try {
        // Request Parameter
		String sortId = doString.checkString(req.getParameter("sortId"));
		String id = doString.checkString(req.getParameter("code"));        
		String pname = doString.checkString(req.getParameter("prename"));
		pname = doString.UnicodeToMS874(pname);
		String name = doString.checkString(req.getParameter("name"));
		name = doString.UnicodeToMS874(name);		
		String sname = doString.checkString(req.getParameter("surname"));
		sname = doString.UnicodeToMS874(sname);		
		String telephone = doString.checkString(req.getParameter("telephone"));
		String address1 = doString.checkString(req.getParameter("address1"));
		address1 = doString.UnicodeToMS874(address1);
		String address2 = doString.checkString(req.getParameter("address2"));
		address2 = doString.UnicodeToMS874(address2);
		targetPage += sortId + "&vendor="+pname+" "+name+" "+sname;
		vendor.setSurName(sortId);
		vendor.setId(id);
		vendor.setName(name);
		vendor.setPreName(pname);
		vendor.setSurName(sname);
		vendor.setTelephone(telephone);
		vendor.setAddress1(address1);
		vendor.setAddress2(address2);
        session.setAttribute("Vendor", vendor);
         
        // Redirect to the target page.
		res.sendRedirect(targetPage);
    } catch (Exception e) {
        System.out.println("ERROR /LHServ/AddInfVendorServlet : " + e.getMessage());
    }
	System.out.println(mName + "end.");    
}
}
