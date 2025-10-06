package serv.servlets;

import java.awt.Color;
import java.io.*;
import java.sql.*;
import java.util.*;
import java.text.*;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Font;
import com.lowagie.text.PageSize;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;

import com.lh.servlet.DBServlet;
import com.lh.util.DateUtil;
import com.lh.util.doString;

import serv.common.Constants;
import serv.common.Vendor;

public class PrintHSumPvdServlet extends DBServlet {
  private Font microssfont = null;
  private Font microssfont_BOLD = null;
  private Font microssfont_HD = null;
  private int descLength = 35;
  private int acctLength = 13;
  private int amntLength = 13;
  private int scaleLength = 13;
  private int difLength = 13;
  private int totLength = 13;
  
  public static double roundHalfUp(double value) {
      double factor = Math.pow(10, 2);
      return Math.round(value * factor) / factor;
  }
  
  public static PdfPCell addCellData(String msg, String hAlign, String vAlign, String border, int size, Font font) {
    PdfPCell cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(msg), font));
    if (hAlign.trim().length() == 1)
      switch (hAlign.charAt(0)) {
        case 'L':
          cell.setHorizontalAlignment(0);
          break;
        case 'C':
        case 'M':
          cell.setHorizontalAlignment(1);
          break;
        case 'R':
          cell.setHorizontalAlignment(2);
          break;
      }
    if (vAlign.trim().length() == 1)
      switch (hAlign.charAt(0)) {
        case 'T':
          cell.setVerticalAlignment(4);
          break;
        case 'C':
        case 'M':
          cell.setVerticalAlignment(5);
          break;
        case 'B':
          cell.setVerticalAlignment(6);
          break;
      }
    int borderId = 0;
    if (border.trim().length() > 0) {
      if (border.indexOf("T") >= 0)
        borderId++;
      if (border.indexOf("B") >= 0)
        borderId += 2;
      if (border.indexOf("L") >= 0)
        borderId += 4;
      if (border.indexOf("R") >= 0)
        borderId += 8;
    }
    cell.setBorder(borderId);
    cell.setColspan(size);
    cell.setPaddingBottom(5);
    cell.setBorderColor(new Color(0, 0, 0));
    return cell;
  }

  public void prntSumPvd(Statement stmt, Document document, String printDate, String mnthDate, String monthDate, String payDate, String comId, String company, String projId, String site, Vendor vendor) throws Exception {
    ResultSet rs = null;
    StringBuffer sql = new StringBuffer();
    String venId = vendor.getId();
    String venNme = doString.MS874ToUnicode(vendor.getName());
    double wageAmnt = 0;
    double cntrlAmnt = 0;
    double wageHomAmnt = 0;
    double goodHomAmnt = 0;
    double wageDifAmnt = 0;
    double pvAmnt = 0;
    double venHomAmnt = 0;
    double comHomAmnt = 0;
    double difAmnt = 0;
    double r8Amnt = 0;
    double totHomAmnt = 0;
    double totServAmnt = 0;
    double ps100 = 100;
    DecimalFormat df = new DecimalFormat("0.00");
    rs = stmt.executeQuery("SELECT NVL(z_wage,0), NVL(z_control,0) FROM lan:serv_pothpayment WHERE i_company = '" + comId + "' AND i_project = '" + projId + "' AND i_vendor = '" + venId + "' AND i_month = '" + monthDate + "'");
    if (rs != null) {
      if (rs.next() == true) {
        wageAmnt = Double.parseDouble(df.format(roundHalfUp(rs.getDouble(1))));
        cntrlAmnt = Double.parseDouble(df.format(roundHalfUp(rs.getDouble(2))));
      }
      rs.close();
      rs = null;
    }
    
    rs = stmt.executeQuery("SELECT SUM(p.q_wage_unit * p.z_wage_price) + SUM(p.q_wage_unit*p.z_wage_price*p.p_add_pay)/100 AS SUM_WAGE_ADD_PAY, SUM(p.q_good_unit*p.z_good_price) + SUM((p.q_good_unit * p.z_good_price * p.p_add_pay)/100) AS SUM_GOODS_ADD_PAY FROM lan:serv_dochd d, lan:serv_payment p WHERE d.i_company = '" + comId + "' AND d.i_project = '" + projId + "' AND d.f_status != 'CAN' AND d.i_docno = p.i_docno AND p.i_vendor = '" + venId + "' AND p.f_itmstatus = 'CLS' AND p.d_payment = '" + payDate + "'");
    if (rs != null) {
      if (rs.next() == true) {
    	  wageHomAmnt = Double.parseDouble(df.format(roundHalfUp(rs.getDouble("SUM_WAGE_ADD_PAY"))));
    	  goodHomAmnt = Double.parseDouble(df.format(roundHalfUp(rs.getDouble("SUM_GOODS_ADD_PAY"))));
      }
      rs.close();
      rs = null;
    }
    rs = stmt.executeQuery("SELECT SUM(p.z_cut_pv) AS CUT_PV, SUM(p.z_amount_pv) AS AMNT_PV FROM lan:serv_dochd d, lan:serv_payment p WHERE d.i_company = '" + comId + "' AND d.i_project = '" + projId + "' AND d.f_status != 'CAN' AND d.i_docno = p.i_docno AND p.i_vendor = '" + venId + "' AND p.f_itmstatus = 'CLS' AND p.d_payment = '" + payDate + "' AND p.i_ven_cut != '999999'");
    if (rs != null) {
      if (rs.next() == true) {
    	  venHomAmnt = Double.parseDouble(df.format(roundHalfUp(rs.getDouble("CUT_PV"))));
    	  pvAmnt = Double.parseDouble(df.format(roundHalfUp(rs.getDouble("AMNT_PV"))));
    	  difAmnt = Double.parseDouble(df.format(roundHalfUp(venHomAmnt - pvAmnt)));
      }
      rs.close();
      rs = null;
    }
    
    String fContr = "";
    String typeCut = "";
    double amount = 0;
    sql.delete(0, sql.length());
    sql.append("SELECT a.i_type_cutlck, b.i_ven_cut, SUM(q_wage_unit * z_wage_price) sum_wage, b.f_contr, ")
      .append(" SUM(q_good_unit * z_good_price) sum_goods, ")
      .append(" SUM(z_amount_pay) sum_amount_pay, SUM(z_amount_pv) sum_amount_pv ")
      .append(" from lan:serv_dochd a,lan:serv_payment b ")
      .append(" where b.i_docno = a.i_docno and a.f_status in ('OPN','CLS') and b.f_itmstatus='CLS' ")
      .append(" and b.i_ven_cut = '999999' ")
      .append(" and a.i_company = '")
      .append(comId)
      .append("' and a.i_project = '")
      .append(projId)
      .append("' and b.i_vendor = '")
      .append(venId)
      .append("' and b.d_payment = '")
      .append(payDate)
      .append("' group by b.i_ven_cut,a.i_type_cutlck,b.f_contr ")
      .append(" order by b.i_ven_cut ");
    rs = stmt.executeQuery(sql.toString());
    while (rs.next() == true) {
      fContr = doString.checkString(rs.getString("f_contr"), "");
      typeCut = doString.checkString(rs.getString("i_type_cutlck"), "");
      amount = Double.parseDouble(df.format(roundHalfUp(rs.getDouble("sum_amount_pv"))));
      if (fContr.equalsIgnoreCase("Y")) {
    	  r8Amnt = Double.parseDouble(df.format(roundHalfUp(r8Amnt + amount)));
    	  continue;
      }
      comHomAmnt = Double.parseDouble(df.format(roundHalfUp(comHomAmnt + amount)));
    }//end while
    rs.close();
    rs = null;
    if (difAmnt != 0) {
    	comHomAmnt = Double.parseDouble(df.format(roundHalfUp(comHomAmnt - difAmnt)));
    }
    
    wageDifAmnt = Double.parseDouble(df.format(roundHalfUp(wageAmnt - wageHomAmnt)));
    if (wageAmnt == 0) wageDifAmnt = 0;
    
    totHomAmnt = Double.parseDouble(df.format(roundHalfUp(comHomAmnt + r8Amnt)));
    totServAmnt = Double.parseDouble(df.format(roundHalfUp(venHomAmnt + totHomAmnt)));
    double homPercent = ps100;
    
    if (totHomAmnt == 0) {
      homPercent = 0;
    }
    
    double venPercent = 0;
    double comPercent = 0;
    if (totHomAmnt > 0) {
    	comPercent = Double.parseDouble(df.format(roundHalfUp(comHomAmnt * homPercent / totHomAmnt)));
    }
    double r8Percent = Double.parseDouble(df.format(roundHalfUp(homPercent - comPercent)));
    
    double ven_dif = 0;
    double com_dif = Double.parseDouble(df.format(roundHalfUp(wageDifAmnt * comPercent / ps100)));
    double r8_dif = Double.parseDouble(df.format(roundHalfUp(wageDifAmnt * r8Percent / ps100)));
    double home_dif = Double.parseDouble(df.format(roundHalfUp(wageDifAmnt * homPercent / ps100)));
    double totJobAmnt = Double.parseDouble(df.format(roundHalfUp(goodHomAmnt + cntrlAmnt)));
    totJobAmnt = Double.parseDouble(df.format(roundHalfUp(totJobAmnt + wageAmnt)));
    
    PdfPTable table = new PdfPTable(100);
    table.setWidthPercentage(100);
    table.addCell(addCellData("สรุปรายการที่ต้องเขียนลงใบ 4 สี", "L", "", "", 100, this.microssfont_HD));
    table.addCell(addCellData("ค่าของซ่อมงานบ้าน", "L", "", "", 30, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", goodHomAmnt), "R", "", "", 20, this.microssfont));
    table.addCell(addCellData(" ", "", "", "", 50, this.microssfont));
    table.addCell(addCellData("ค่าจ้างควบคุมงาน", "L", "", "", 30, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", cntrlAmnt), "R", "", "", 20, this.microssfont));
    table.addCell(addCellData(" ", "", "", "", 50, this.microssfont));
    table.addCell(addCellData("ค่าแรงซ่อมบ้าน", "L", "", "", 30, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", wageAmnt), "R", "", "", 20, this.microssfont));
    table.addCell(addCellData(" ", "", "", "", 50, this.microssfont));
    table.addCell(addCellData(" ", "L", "", "", 100, this.microssfont));
    table.addCell(addCellData("ยอดส่งงานรวม", "R", "", "", 30, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", totJobAmnt), "R", "", "B", 20, this.microssfont));
    table.addCell(addCellData(" ", "", "", "", 50, this.microssfont));
    document.add(table);
    
    document.newPage();
    table = new PdfPTable(100);
    table.setWidthPercentage(100);
    table.addCell(addCellData("สรุปใบเบิกงวดงานบ้านสำหรับผู้รับเหมา", "C", "T", "", 100, this.microssfont_HD));
    table.addCell(addCellData("", "L", "C", "", 60, this.microssfont));
    table.addCell(addCellData("วันที่พิมพ์ " + printDate, "L", "C", "", 40, this.microssfont));
    
    table.addCell(addCellData(company, "L", "C", "", 60, this.microssfont));
    table.addCell(addCellData("โครงการ " + site, "L", "C", "", 40, this.microssfont));
    table.addCell(addCellData("", "L", "C", "", 60, this.microssfont));
    table.addCell(addCellData("วันที่ " + mnthDate, "L", "C", "", 40, this.microssfont));
    table.addCell(addCellData("บริษัท/ห้างหุ้นส่วน " + venNme, "L", "C", "", 60, this.microssfont));
    table.addCell(addCellData("ขอเบิกงวดงานดังนี้", "L", "C", "", 40, this.microssfont));
    table.addCell(addCellData(" ", "C", "", "B", 100, this.microssfont));
    table.addCell(addCellData("รายการส่งงานงวดนี้", "L", "", "", this.descLength + this.acctLength + this.amntLength + this.scaleLength, this.microssfont));
    table.addCell(addCellData("ส่งงาน", "C", "", "", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "C", "", "", this.totLength, this.microssfont));
    table.addCell(addCellData(" ค่าแรงงาน (ใบสรุปจ่ายค่าแรง)", "L", "", "", this.descLength + this.acctLength + this.amntLength + this.scaleLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", wageAmnt), "R", "", "", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "C", "", "", this.totLength, this.microssfont));
    table.addCell(addCellData(" ค่าแรงงาน(ตามใบแจ้งซ่อม)", "L", "", "", this.descLength - 5, this.microssfont));
    table.addCell(addCellData("ซ่อมบ้านหลังขาย (รวมค่าดำเนินการ)", "R", "", "", this.acctLength + this.amntLength + 5, this.microssfont));
    table.addCell(addCellData("", "R", "", "", this.scaleLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", wageHomAmnt), "R", "", "", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "C", "", "", this.totLength, this.microssfont));
    table.addCell(addCellData("ผลต่างค่าแรง", "L", "", "", this.descLength, this.microssfont));
    table.addCell(addCellData("54002", "C", "", "", this.acctLength, this.microssfont));
    table.addCell(addCellData(" ", "C", "", "", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "C", "", "", this.scaleLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", wageDifAmnt), "R", "", "B", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "C", "", "", this.totLength, this.microssfont));
    table.addCell(addCellData(" ", "C", "", "", 100, this.microssfont));
    table.addCell(addCellData("รายการ", "C", "M", "LTB", this.descLength, this.microssfont_BOLD));
    table.addCell(addCellData("รหัสบัญชี", "C", "M", "TRB", this.acctLength, this.microssfont_BOLD));
    table.addCell(addCellData("ส่งงาน\n(ของ+แรง)", "C", "M", "LTB", this.amntLength, this.microssfont_BOLD));
    table.addCell(addCellData("สัดส่วน\nงานซ่อม", "C", "M", "TB", this.scaleLength, this.microssfont_BOLD));
    table.addCell(addCellData("ส่วนต่าง\nค่าแรง", "C", "M", "TRB", this.difLength, this.microssfont_BOLD));
    table.addCell(addCellData("รวม", "C", "M", "LTRB", this.totLength, this.microssfont_BOLD));
    table.addCell(addCellData(" 1  งานซ่อม", "L", "", "LR", this.descLength + this.acctLength, this.microssfont));
    table.addCell(addCellData(" ", "L", "", "LRT", this.amntLength + this.scaleLength + this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "L", "", "LTR", this.totLength, this.microssfont));
    table.addCell(addCellData("    1.1  งานซ่อมบ้าน", "L", "", "LR", this.descLength + this.acctLength, this.microssfont));
    table.addCell(addCellData(" ", "L", "", "LR", this.amntLength + this.scaleLength + this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "L", "", "LR", this.totLength, this.microssfont));
    table.addCell(addCellData("          ผู้รับเหมารับผิดชอบ", "L", "", "L", this.descLength, this.microssfont));
    table.addCell(addCellData("11411", "C", "", "R", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", venHomAmnt), "R", "", "L", this.amntLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###.00", venPercent) + "%", "R", "", "", this.scaleLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", ven_dif), "R", "", "R", this.difLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", venHomAmnt + ven_dif), "R", "", "LR", this.totLength, this.microssfont));
    
    table.addCell(addCellData("          บริษัทรับผิดชอบ เป็นค่าใช้จ่าย", "L", "", "L", this.descLength, this.microssfont));
    table.addCell(addCellData("54000", "C", "", "R", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", comHomAmnt), "R", "", "L", this.amntLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###.00", comPercent) + "%", "R", "", "", this.scaleLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", com_dif), "R", "", "R", this.difLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", comHomAmnt + com_dif), "R", "", "LR", this.totLength, this.microssfont));
    
    table.addCell(addCellData("          บริษัทรับผิดชอบ เป็นต้นทุน (R8)", "L", "", "LB", this.descLength, this.microssfont));
    table.addCell(addCellData("11730", "C", "", "RB", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", r8Amnt), "R", "", "LB", this.amntLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###.00", r8Percent) + "%", "R", "", "B", this.scaleLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", r8_dif), "R", "", "RB", this.difLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", r8Amnt + r8_dif), "R", "", "LRB", this.totLength, this.microssfont));
    
    table.addCell(addCellData("          งานซ่อมบ้านรวม", "L", "", "LB", this.descLength, this.microssfont));
    table.addCell(addCellData(" ", "C", "", "RB", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", totHomAmnt), "R", "", "LB", this.amntLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###.00", homPercent) + "%", "R", "", "B", this.scaleLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", home_dif), "R", "", "RB", this.difLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", totHomAmnt + home_dif), "R", "", "LRB", this.totLength, this.microssfont));
    table.addCell(addCellData("          งานซ่อมรวม", "L", "", "LB", this.descLength, this.microssfont));
    table.addCell(addCellData(" ", "C", "", "RB", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", totServAmnt), "R", "", "LB", this.amntLength, this.microssfont));
    table.addCell(addCellData("", "R", "", "B", this.scaleLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", wageDifAmnt), "R", "", "RB", this.difLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", totServAmnt + wageDifAmnt), "R", "", "LRB", this.totLength, this.microssfont));
    
    table.addCell(addCellData(" 2 ค่าควบคุมงานโครงการ", "L", "", "LB", this.descLength, this.microssfont));
    table.addCell(addCellData("54021", "C", "", "BR", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", cntrlAmnt), "R", "", "LB", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "B", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "L", "", "RB", this.difLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", cntrlAmnt), "R", "", "LTRB", this.totLength, this.microssfont));
    table.addCell(addCellData(" ", "C", "", "", 100, this.microssfont));
    
    table.addCell(addCellData("          รวมทั้งสิ้น", "L", "", "LTRB", this.descLength + this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", totServAmnt + cntrlAmnt), "R", "", "LTB", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "TB", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "TBR", this.difLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", totServAmnt + wageDifAmnt + cntrlAmnt), "R", "", "LTRB", this.totLength, this.microssfont));
    document.add(table);
  }

  public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
    String mName = new String(getClass().getName() + ".performTask: ");
    System.out.println(mName + "start.");
    StringBuffer sql = new StringBuffer();
    Connection conn = null;
    Statement stmt = null;
    Statement stmt1 = null;
    ResultSet rs = null;
    ResultSet rs1 = null;
    try {
      if (ds == null)
        getDS();
      conn = ds.getConnection();
      conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
      conn.setAutoCommit(true);
      stmt = conn.createStatement();
      stmt1 = conn.createStatement();
	  
      String selProj = doString.checkString(req.getParameter("sel_project"), "LH-286").toUpperCase();
      String company = "";
      String comId = (selProj.length() >= 6) ? selProj.substring(0, 2) : "";
      String projId = (selProj.length() >= 6) ? selProj.substring(3, 6) : "";
      String venId = doString.checkString(req.getParameter("vendor"), "346756");
      String ven_restrict = "";
      if (!venId.equals("")) {
        ven_restrict = "AND v.ven_no = '" + venId + "'";
      }
      Vector vendor_list = new Vector(5);
      String printDate = "";
      String payMonth = doString.checkString(req.getParameter("payMonth"),"02");
      String payYear = doString.checkString(req.getParameter("payYear"),"2025");
      
      Calendar currentCal = Calendar.getInstance(Locale.ENGLISH);
      currentCal = new GregorianCalendar(Integer.parseInt(payYear), Integer.parseInt(payMonth) - 1, 1);
      int daysInMonth = currentCal.getActualMaximum(5);
      String mnthDate = payYear + "-" + payMonth + "-" + doString.displayNumber("00", daysInMonth);
      String monthDate = payYear + "-" + payMonth + "-01";
      String payDate = "";
      int i = 0;
      rs = stmt.executeQuery("SELECT d_contructor, d_payment, CURRENT FROM lan:serv_payschd WHERE d_contructor <= '" + mnthDate + "' ORDER BY d_contructor DESC");
      if (rs != null) {
        if (rs.next() == true) {
          payDate = doString.checkString(rs.getString("D_PAYMENT"));
          printDate = DateUtil.ifxToThaiDate(doString.checkString(rs.getString(3)));
        }
        rs.close();
        rs = null;
      }
      
      mnthDate = DateUtil.TH_month[Integer.parseInt(payMonth) - 1] + " " + Integer.toString(Integer.parseInt(payYear) + 543).substring(2);
      rs = stmt.executeQuery("SELECT n_company FROM lan:acxcompa WHERE i_company = '" + comId + "'");
      if (rs != null) {
        if (rs.next() == true) {
          company = doString.MS874ToUnicode(doString.checkString(rs.getString("N_COMPANY")));
        }
        rs.close();
        rs = null;
      }
      selProj = "";
      rs = stmt.executeQuery("SELECT n_project FROM lan:acxprojt WHERE i_company = '" + comId + "' AND i_project = '" + projId + "'");
      if (rs != null) {
        if (rs.next() == true) {
          selProj = doString.MS874ToUnicode(doString.checkString(rs.getString("N_PROJECT")));
        }
        rs.close();
        rs = null;
      }
      vendor_list.removeAllElements();
      rs = stmt.executeQuery("SELECT p.i_vendor, v.ven_name FROM lan:serv_venprj p, lan:vendor v WHERE p.i_company = '" + comId + "' AND p.i_project = '" + projId + "' AND p.i_type = '01' AND p.i_vendor = v.ven_no " + ven_restrict + " ORDER BY v.ven_name");
      if (rs != null) {
        while (rs.next() == true) {
          venId = doString.checkString(rs.getString("I_VENDOR"));
          Vendor aVendor = new Vendor();
          aVendor.setId(venId);
          aVendor.setName(doString.checkString(rs.getString("VEN_NAME")));
          vendor_list.add(i, aVendor);
          i++;
        }
        rs.close();
        rs = null;
      }
      BaseFont bf = BaseFont.createFont(Constants.FONT_ANGSANA_NORMAL, "Identity-H", false);
      BaseFont bfb = BaseFont.createFont(Constants.FONT_ANGSANA_BOLD, "Identity-H", false);
      this.microssfont = new Font(bf, 16, 0);
      this.microssfont_BOLD = new Font(bfb, 16, 0);
      this.microssfont_HD = new Font(bfb, 18, 0);
      Document document = new Document(PageSize.A4, 30, 30, 20, 20);
      ByteArrayOutputStream baos = new ByteArrayOutputStream();
      PdfWriter writer = PdfWriter.getInstance(document, baos);
      document.open();
      for (i = 0; i < vendor_list.size(); i++) {
        Vendor aVendor = (Vendor)vendor_list.elementAt(i);
        if (aVendor != null) {
          venId = aVendor.getId();
          if (!venId.equals("")) {
            prntSumPvd(stmt, document, printDate, mnthDate, monthDate, payDate, comId, company, projId, selProj, aVendor);
            document.newPage();
          }
        }
      }
      document.close();
      stmt.close();
      stmt1.close();
      conn.close();
	  stmt = null;
	  stmt1 = null;
      conn = null;
	  
      res.setContentType("application/pdf");
      res.setContentLength(baos.size());
      ServletOutputStream outServ = res.getOutputStream();
      baos.writeTo((OutputStream)outServ);
      outServ.flush();
    } catch (DocumentException de) {

    } catch (Exception e) {
      System.out.println(" ERROR " + mName + " : " + e.getMessage());
      System.out.println(" ERROR " + mName + " SQL : " + sql.toString());
    } finally {
      try {
        if (rs != null)
          rs.close();
        if (rs1 != null)
          rs1.close();
        if (stmt != null)
          stmt.close();
        if (stmt1 != null)
          stmt1.close();
        if (conn != null)
          conn.close();
        stmt = null;
        stmt1 = null;
        conn = null;        
      } catch (SQLException sQLException) {}
    }
    System.out.println(mName + "end.");
  }
}