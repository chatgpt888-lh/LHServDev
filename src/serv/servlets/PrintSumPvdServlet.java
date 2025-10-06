package serv.servlets;

import com.lh.servlet.DBServlet;
import com.lh.util.DateUtil;
import com.lh.util.doString;
import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Font;
import com.lowagie.text.PageSize;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DecimalFormat;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.Locale;
import java.util.Vector;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import serv.common.Constants;
import serv.common.NumberUtil;
import serv.common.Vendor;

public class PrintSumPvdServlet extends DBServlet {
  private Font microssfont = null;
  private Font microssfont_BOLD = null;
  private Font microssfont_HD = null;
  private int descLength = 35;
  private int acctLength = 13;
  private int amntLength = 13;
  private int scaleLength = 13;
  private int difLength = 13;
  private int totLength = 13;
  
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
  public double roundHalfUp(double value) {
      double factor = Math.pow(10, 2);
      return Math.round(value * factor) / factor;
  }  
  public void prntSumPvd(Statement stmt, Document document, String printDate, String mnthDate, String monthDate, String payDate, String comId, String company, String projId, String site, Vendor vendor) throws Exception {
    ResultSet rs = null;
    String venId = vendor.getId();
    String venNme = doString.MS874ToUnicode(vendor.getName());
    String ven_cut = "";
    String account = "";
    double amount = 0;
    double cutAmnt = 0;
    double wageAmnt = 0;
    double cntrlAmnt = 0;
    double wageInfAmnt = 0;
    double goodInfAmnt = 0;
    double wageDifAmnt = 0;
    double clubAmnt = 0;
    double gardAmnt = 0;
    double infOthAmnt = 0;
    double infCutAmnt = 0;
    double maintClubAmnt = 0;
    double maintGardAmnt = 0;
    double maintOthAmnt = 0;
    double totInfAmnt = 0;
    double totServAmnt = 0;
    double pubClubAmnt = 0;
    double pubGardAmnt = 0;
    double pubOthAmnt = 0;
    double maintPClubAmnt = 0;
    double maintPGardAmnt = 0;
    double maintPOthAmnt = 0;
    double totPubAmnt = 0;
    double othAmnt = 0;
    double ps100 = 100;
    boolean fixCost = true;
    double goodPubAmnt = 0;
    double wagePubAmnt = 0;
    double pubAmnt = 0;
    DecimalFormat df = new DecimalFormat("0.00");
    
    rs = stmt.executeQuery("SELECT z_wage, z_control FROM lan:serv_othpayment WHERE i_company = '" + comId + "' AND i_project = '" + projId + "' AND i_vendor = '" + venId + "' AND i_month = '" + monthDate + "'");
    if (rs != null) {
      if (rs.next() == true) {
    	  wageAmnt = Double.parseDouble(df.format(roundHalfUp(rs.getDouble(1))));
    	  cntrlAmnt = Double.parseDouble(df.format(roundHalfUp(rs.getDouble(2))));
      } 
      rs.close();
      rs = null;
    } 
    if (wageAmnt == 0) {
      fixCost = false; 
    }
    wageInfAmnt = 0;
    goodInfAmnt = 0;
    rs = stmt.executeQuery("SELECT p.i_account, p.i_acct_cus, p.z_amount_pv, (NVL(p.q_wage_unit,0)*NVL(p.z_wage_price,0))+(NVL(p.q_wage_unit,0)*NVL(p.z_wage_price,0))*(NVL(p.p_add_pay,0)/100) AS WAGE_AMNT, (NVL(p.q_good_unit,0)*NVL(p.z_good_price,0))+(NVL(p.q_good_unit,0)*NVL(p.z_good_price,0))*(NVL(p.p_add_pay,0)/100) AS GOODS_AMNT, NVL(p.z_cut_pv,0) AS CUT_PV, p.i_ven_cut FROM lan:serv_infdochd d, lan:serv_infpayment p WHERE d.i_company = '" + comId + "' AND d.i_project = '" + projId + "' AND d.i_docno = p.i_docno AND p.i_vendor = '" + venId + "' AND p.f_itmstatus = 'CLS' AND p.d_payment = '" + payDate + "' AND p.i_itmtype = '01'");
    if (rs != null) {
      while (rs.next() == true) {
        account = doString.checkString(rs.getString("I_ACCOUNT"));
        amount = Double.parseDouble(df.format(roundHalfUp(rs.getDouble("Z_AMOUNT_PV"))));
        ven_cut = doString.checkString(rs.getString("I_VEN_CUT"));
        cutAmnt = Double.parseDouble(df.format(roundHalfUp(rs.getDouble("CUT_PV"))));
        if (!ven_cut.equals("") && !ven_cut.equals("999999")) {
        	amount = Double.parseDouble(df.format(roundHalfUp(amount - cutAmnt)));
        	infCutAmnt = Double.parseDouble(df.format(roundHalfUp(infCutAmnt + cutAmnt)));
        }
        wageInfAmnt += rs.getDouble("WAGE_AMNT");
        goodInfAmnt += rs.getDouble("GOODS_AMNT");
        if (account.equals("54010")) {
          clubAmnt = Double.parseDouble(df.format(roundHalfUp(clubAmnt + amount)));
          continue;
        } 
        if (account.equals("54011")) {
        	gardAmnt = Double.parseDouble(df.format(roundHalfUp(gardAmnt + amount)));
          continue;
        } 
        if (account.equals("54012")) {
        	infOthAmnt = Double.parseDouble(df.format(roundHalfUp(infOthAmnt + amount)));
          continue;
        } 
        if (account.equals("54013")) {
        	maintClubAmnt = Double.parseDouble(df.format(roundHalfUp(maintClubAmnt + amount)));
          continue;
        } 
        if (account.equals("54014")) {
        	maintGardAmnt = Double.parseDouble(df.format(roundHalfUp(maintGardAmnt + amount)));
          continue;
        } 
        if (account.equals("54015")) {
        	maintOthAmnt = Double.parseDouble(df.format(roundHalfUp(maintOthAmnt + amount)));
          continue;
        } 
        othAmnt = Double.parseDouble(df.format(roundHalfUp(othAmnt + amount)));
      }//end while 
      rs.close();
      rs = null;
    } 
    othAmnt = Double.parseDouble(df.format(roundHalfUp(othAmnt + infCutAmnt)));
    
    goodPubAmnt = 0;
    wagePubAmnt = 0;
    pubAmnt = 0;
    rs = stmt.executeQuery("SELECT p.i_account, p.z_amount_pv, (NVL(p.q_wage_unit,0)*NVL(p.z_wage_price,0))+(NVL(p.q_wage_unit,0)*NVL(p.z_wage_price,0))*(NVL(p.p_add_pay,0)/100) AS WAGE_AMNT, (NVL(p.q_good_unit,0)*NVL(p.z_good_price,0))+(NVL(p.q_good_unit,0)*NVL(p.z_good_price,0))*(NVL(p.p_add_pay,0)/100) AS GOODS_AMNT FROM lan:serv_infdochd d, lan:serv_infpayment p WHERE d.i_company = '" + comId + "' AND d.i_project = '" + projId + "' AND d.i_docno = p.i_docno AND p.i_vendor = '" + venId + "' AND p.f_itmstatus = 'CLS' AND p.d_payment = '" + payDate + "' AND p.i_itmtype = '02'");
    if (rs != null) {
      while (rs.next() == true) {
        account = doString.checkString(rs.getString("I_ACCOUNT"));
        amount = NumberUtil.toNumber("#########.00", rs.getDouble("Z_AMOUNT_PV"));
        pubAmnt += amount;
        wagePubAmnt += NumberUtil.toNumber("#########.00", rs.getDouble("WAGE_AMNT"));
        goodPubAmnt += NumberUtil.toNumber("#########.00", rs.getDouble("GOODS_AMNT"));
        if (account.equals("54010")) {
          pubClubAmnt += amount;
          continue;
        } 
        if (account.equals("54011")) {
          pubGardAmnt += amount;
          continue;
        } 
        if (account.equals("54012")) {
          pubOthAmnt += amount;
          continue;
        } 
        if (account.equals("54013")) {
          maintPClubAmnt += amount;
          continue;
        } 
        if (account.equals("54014")) {
          maintPGardAmnt += amount;
          continue;
        } 
        if (account.equals("54015")) {
          maintPOthAmnt += amount;
          continue;
        } 
        othAmnt += amount;
      }//end while 
      rs.close();
      rs = null;
    }
    
    wageInfAmnt = NumberUtil.toNumber("#########.00", wageInfAmnt);
    clubAmnt = NumberUtil.toNumber("#########.00", clubAmnt);
    gardAmnt = NumberUtil.toNumber("#########.00", gardAmnt);
    infOthAmnt = NumberUtil.toNumber("#########.00", infOthAmnt);
    maintClubAmnt = NumberUtil.toNumber("#########.00", maintClubAmnt);
    maintGardAmnt = NumberUtil.toNumber("#########.00", maintGardAmnt);
    maintOthAmnt = NumberUtil.toNumber("#########.00", maintOthAmnt);
    othAmnt = NumberUtil.toNumber("#########.00", othAmnt);
    wagePubAmnt = NumberUtil.toNumber("#########.00", wagePubAmnt);
    pubAmnt = NumberUtil.toNumber("#########.00", pubAmnt);
    wageDifAmnt = wageAmnt - wageInfAmnt - wagePubAmnt;
    if (!fixCost) {
      wageDifAmnt = 0;
      wageAmnt = wageInfAmnt + wagePubAmnt;
    } 
    totInfAmnt = clubAmnt + gardAmnt + infOthAmnt + maintClubAmnt + maintGardAmnt + maintOthAmnt;
    totPubAmnt = pubClubAmnt + pubGardAmnt + pubOthAmnt + maintPClubAmnt + maintPGardAmnt + maintPOthAmnt;
    totServAmnt = totInfAmnt + totPubAmnt + othAmnt;
    double infPercent = 0;
    if (totServAmnt > 0)
      infPercent = NumberUtil.toNumber("###.00", totInfAmnt * ps100 / totServAmnt); 
    double oinfPercent = NumberUtil.toNumber("###.00", ps100 - infPercent);
    double oinf_dif = NumberUtil.toNumber("#########.00", wageDifAmnt * oinfPercent / ps100);
    double clubPercent = 0;
    double gardPercent = 0;
    double othPercent = 0;
    if (totInfAmnt > 0) {
      clubPercent = NumberUtil.toNumber("###.00", clubAmnt * infPercent / totInfAmnt);
      gardPercent = NumberUtil.toNumber("###.00", gardAmnt * infPercent / totInfAmnt);
      othPercent = NumberUtil.toNumber("###.00", infOthAmnt * infPercent / totInfAmnt);
    } 
    double club_dif = NumberUtil.toNumber("#########.00", wageDifAmnt * clubPercent / ps100);
    double gard_dif = NumberUtil.toNumber("#########.00", wageDifAmnt * gardPercent / ps100);
    double oth_dif = NumberUtil.toNumber("#########.00", wageDifAmnt * othPercent / ps100);
    double inf_dif = NumberUtil.toNumber("#########.00", wageDifAmnt * infPercent / ps100);
    PdfPTable table = new PdfPTable(100);
    table.setWidthPercentage(100);
    table.addCell(addCellData("สรุปรายการที่ต้องเขียนลงใบ 4 สี", "L", "", "", 100, this.microssfont_HD));
    table.addCell(addCellData("ค่าของซ่อมงานสาธารณูฯ และงานสาธารณะ", "L", "", "", 50, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", goodInfAmnt + goodPubAmnt), "R", "", "", 20, this.microssfont));
    table.addCell(addCellData(" ", "", "", "", 30, this.microssfont));
    table.addCell(addCellData("ค่าจ้างควบคุมงาน", "L", "", "", 50, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", cntrlAmnt), "R", "", "", 20, this.microssfont));
    table.addCell(addCellData(" ", "", "", "", 30, this.microssfont));
    table.addCell(addCellData("ค่าแรงซ่อมงานสาธารณูฯ และงานสาธารณะ", "L", "", "", 50, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", wageInfAmnt + wagePubAmnt), "R", "", "", 20, this.microssfont));
    table.addCell(addCellData(" ", "", "", "", 30, this.microssfont));
    table.addCell(addCellData(" ", "L", "", "", 100, this.microssfont));
    table.addCell(addCellData("ยอดส่งงานรวม", "R", "", "", 50, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", goodInfAmnt + goodPubAmnt + cntrlAmnt + wageInfAmnt + wagePubAmnt), "R", "", "B", 20, this.microssfont));
    table.addCell(addCellData(" ", "", "", "", 30, this.microssfont));
    if (!fixCost)
      wageAmnt = 0; 
    document.add(table);
    
    document.newPage();
    table = new PdfPTable(100);
    table.setWidthPercentage(100);
    table.addCell(addCellData("สรุปใบเบิกงวดงานสาธารณูฯและงานสาธารณะสำหรับผู้รับเหมา", "C", "T", "", 100, this.microssfont_HD));
    table.addCell(addCellData("", "L", "C", "", 60, this.microssfont));
    table.addCell(addCellData("วันที่พิมพ์ " + printDate, "L", "C", "", 40, this.microssfont));
    
    table.addCell(addCellData(company, "L", "C", "", 60, this.microssfont));
    table.addCell(addCellData("โครงการ " + site, "L", "C", "", 40, this.microssfont));
    
    table.addCell(addCellData("", "L", "C", "", 60, this.microssfont));
    table.addCell(addCellData("วันที่ " + mnthDate, "L", "C", "", 40, this.microssfont));
    
    table.addCell(addCellData("บริษัท/ห้างหุ้นส่วน " + venNme, "L", "C", "", 60, this.microssfont));
    table.addCell(addCellData("ขอเบิกงวดงานดังนี้", "L", "C", "", 40, this.microssfont));
    table.addCell(addCellData(" ", "C", "", "", 100, this.microssfont));
    table.addCell(addCellData("รายการ", "C", "M", "LTB", this.descLength, this.microssfont_BOLD));
    table.addCell(addCellData("รหัสบัญชี", "C", "M", "TRB", this.acctLength, this.microssfont_BOLD));
    table.addCell(addCellData("ส่งงาน\n(ของ+แรง)", "C", "M", "LTB", this.amntLength, this.microssfont_BOLD));
    table.addCell(addCellData(" ", "C", "M", "LTRB", this.scaleLength, this.microssfont_BOLD));
    table.addCell(addCellData(" ", "C", "M", "LTRB", this.difLength, this.microssfont_BOLD));
    table.addCell(addCellData(" ", "C", "M", "LTRB", this.totLength, this.microssfont_BOLD));
    table.addCell(addCellData(" 1  งานซ่อม", "L", "", "LR", this.descLength + this.acctLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "L", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.totLength, this.microssfont));
    table.addCell(addCellData("    1.1  งานซ่อมสาธารณูฯ (ส่วนกลาง)", "L", "", "LR", this.descLength + this.acctLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "L", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.totLength, this.microssfont));
    table.addCell(addCellData("          ซ่อมสโมสร-สระว่ายน้ำ", "L", "", "L", this.descLength, this.microssfont));
    table.addCell(addCellData("54010", "C", "", "R", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", clubAmnt), "R", "", "L", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.totLength, this.microssfont));
    table.addCell(addCellData("          ซ่อมต้นไม้, สวน", "L", "", "L", this.descLength, this.microssfont));
    table.addCell(addCellData("54011", "C", "", "R", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", gardAmnt), "R", "", "L", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.totLength, this.microssfont));
    table.addCell(addCellData("          ซ่อมงานสาธารณูฯ อื่นๆ", "L", "", "LB", this.descLength, this.microssfont));
    table.addCell(addCellData("54012", "C", "", "RB", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", infOthAmnt), "R", "", "LB", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.totLength, this.microssfont));
    table.addCell(addCellData("          บำรุงรักษา-สโมสร-สระว่ายน้ำ", "L", "", "L", this.descLength, this.microssfont));
    table.addCell(addCellData("54013", "C", "", "R", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", maintClubAmnt), "R", "", "L", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.totLength, this.microssfont));
    table.addCell(addCellData("          บำรุงรักษา-ต้นไม้, สวน", "L", "", "L", this.descLength, this.microssfont));
    table.addCell(addCellData("54014", "C", "", "R", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", maintGardAmnt), "R", "", "L", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.totLength, this.microssfont));
    table.addCell(addCellData("          บำรุงรักษา-สาธารณูฯ,ทรัพย์สินอื่น", "L", "", "LB", this.descLength, this.microssfont));
    table.addCell(addCellData("54015", "C", "", "RB", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", maintOthAmnt), "R", "", "LB", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.totLength, this.microssfont));
    table.addCell(addCellData("          งานซ่อมสาธารณูฯ รวม", "L", "", "LB", this.descLength, this.microssfont));
    table.addCell(addCellData(" ", "C", "", "RB", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", totInfAmnt), "R", "", "LB", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.totLength, this.microssfont));
    
    table.addCell(addCellData("    1.2  งานซ่อมสาธารณะ", "L", "", "LR", this.descLength + this.acctLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "L", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.totLength, this.microssfont));
    table.addCell(addCellData("          ซ่อมสโมสร-สระว่ายน้ำ", "L", "", "L", this.descLength, this.microssfont));
    table.addCell(addCellData("54010", "C", "", "R", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", pubClubAmnt), "R", "", "L", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.totLength, this.microssfont));
    table.addCell(addCellData("          ซ่อมต้นไม้, สวน", "L", "", "L", this.descLength, this.microssfont));
    table.addCell(addCellData("54011", "C", "", "R", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", pubGardAmnt), "R", "", "L", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.totLength, this.microssfont));
    table.addCell(addCellData("          ซ่อมงานสาธารณะ อื่นๆ", "L", "", "LB", this.descLength, this.microssfont));
    table.addCell(addCellData("54012", "C", "", "RB", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", pubOthAmnt), "R", "", "LB", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.totLength, this.microssfont));
    table.addCell(addCellData("          บำรุงรักษา-สโมสร-สระว่ายน้ำ", "L", "", "L", this.descLength, this.microssfont));
    table.addCell(addCellData("54013", "C", "", "R", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", maintPClubAmnt), "R", "", "L", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.totLength, this.microssfont));
    table.addCell(addCellData("          บำรุงรักษา-ต้นไม้, สวน", "L", "", "L", this.descLength, this.microssfont));
    table.addCell(addCellData("54014", "C", "", "R", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", maintPGardAmnt), "R", "", "L", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LR", this.totLength, this.microssfont));
    table.addCell(addCellData("          บำรุงรักษา-สาธารณะ,ทรัพย์สินอื่น", "L", "", "LB", this.descLength, this.microssfont));
    table.addCell(addCellData("54015", "C", "", "RB", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", maintPOthAmnt), "R", "", "LB", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.totLength, this.microssfont));
    table.addCell(addCellData("          งานซ่อมสาธารณะ รวม", "L", "", "LB", this.descLength, this.microssfont));
    table.addCell(addCellData(" ", "C", "", "RB", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", totPubAmnt), "R", "", "LB", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.totLength, this.microssfont));
    table.addCell(addCellData("    1.3  งานซ่อมอื่นๆ", "L", "", "LB", this.descLength, this.microssfont));
    table.addCell(addCellData(" ", "C", "", "RB", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", othAmnt), "R", "", "LB", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.totLength, this.microssfont));
    table.addCell(addCellData("          งานซ่อมรวม", "L", "", "LB", this.descLength, this.microssfont));
    table.addCell(addCellData(" ", "C", "", "RB", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", totServAmnt), "R", "", "LB", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.totLength, this.microssfont));
    table.addCell(addCellData(" 2 ค่าควบคุมงานโครงการ", "L", "", "LB", this.descLength, this.microssfont));
    table.addCell(addCellData("54021", "C", "", "BR", this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", cntrlAmnt), "R", "", "LB", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LBR", this.totLength, this.microssfont));
    table.addCell(addCellData(" ", "C", "", "", 100, this.microssfont));
    table.addCell(addCellData("          รวมทั้งสิ้น", "L", "", "LTRB", this.descLength + this.acctLength, this.microssfont));
    table.addCell(addCellData(doString.displayNumber("###,###,###.00", totServAmnt + cntrlAmnt), "R", "", "LTRB", this.amntLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LTRB", this.scaleLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LTRB", this.difLength, this.microssfont));
    table.addCell(addCellData(" ", "R", "", "LTRB", this.totLength, this.microssfont));
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
      conn.setTransactionIsolation(1);
      conn.setAutoCommit(true);
      stmt = conn.createStatement();
      stmt1 = conn.createStatement();
      String selProj = doString.checkString(req.getParameter("sel_project"), "").toUpperCase();
      String company = "";
      String comId = (selProj.length() >= 6) ? selProj.substring(0, 2) : "";
      String projId = (selProj.length() >= 6) ? selProj.substring(3, 6) : "";
      String venId = doString.checkString(req.getParameter("vendor"), "");
      String ven_restrict = "";
      if (!venId.equals(""))
        ven_restrict = "AND v.ven_no = '" + venId + "'"; 
      Vector vendor_list = new Vector(5);
      String printDate = "";
      String payMonth = doString.checkString(req.getParameter("payMonth"));
      String payYear = doString.checkString(req.getParameter("payYear"));
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
        if (rs.next())
          company = doString.MS874ToUnicode(doString.checkString(rs.getString("N_COMPANY"))); 
        rs.close();
        rs = null;
      } 
      selProj = "";
      rs = stmt.executeQuery("SELECT n_project FROM lan:acxprojt WHERE i_company = '" + comId + "' AND i_project = '" + projId + "'");
      if (rs != null) {
        if (rs.next())
          selProj = doString.MS874ToUnicode(doString.checkString(rs.getString("N_PROJECT"))); 
        rs.close();
        rs = null;
      } 
      vendor_list.removeAllElements();
      rs = stmt.executeQuery("SELECT p.i_vendor, v.ven_name FROM lan:serv_venprj p, lan:vendor v WHERE p.i_company = '" + comId + "' AND p.i_project = '" + projId + "' AND p.i_type = '01' AND p.i_vendor = v.ven_no " + ven_restrict + " ORDER BY v.ven_name");
      if (rs != null) {
        while (rs.next()) {
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
      PdfContentByte cb = writer.getDirectContent();
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
      conn = null;
      stmt = null;
      stmt1 = null;
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
      } catch (SQLException sQLException) {}
    } 
    System.out.println(mName + "end.");
  }
}