package serv.servlets;

import java.io.*;
import java.util.*;
import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;
import com.lh.servlet.DBServlet;

import serv.common.User;
import serv.common.Constants;


/*
  This servlet is used only to handle requests to
  logout. It then redirects the browser to
  the site's login page.
*/
public class LogoutServlet extends DBServlet {

	private static String cName = "LogoutServlet";   
	
public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {

	Cookie[] cookieList = req.getCookies();
	if (cookieList != null) {
		for (int x = 0; x < cookieList.length; x++) {
			// Delete the cookie by setting its maximum age to zero
			cookieList[x].setMaxAge(0);
		}
	}
	res.addCookie(new Cookie(Constants.COOKIE_NAME, "no"));
	
	HttpSession session = req.getSession(false);
	if (session != null) {
		session.removeAttribute("USER");
		session.invalidate();
	}

	// Redirect to the site's login page.
	res.sendRedirect(Constants.LOGIN_PAGE);
}
}
