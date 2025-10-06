package serv.servlets;

import java.awt.Color;
import java.io.*;
import java.sql.*;
import java.util.*;
import java.text.DecimalFormat;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.lowagie.text.*;
import com.lowagie.text.pdf.*;
import com.lh.servlet.DBServlet;
import com.lh.util.doString;
import serv.common.Constants;
import serv.common.SERV_CommonData;

public class SERV_INFPrintReport7Servlet extends DBServlet {
  private String selProj = "";
  private String iVendor = "";
  private String startDate = "";
  private String endDate = "";
  private String condition = "";
  private String companyName = "";
  private String betweenDate = "";
  private int nowpage = 0;
  private int LIGHT_GRAY_COLOR = 15329769;
  private Color borderColor = new Color(153, 153, 153);
  private int noLength = 3;
  private int vendorLength = 21;
  private int mnthLength = 5;
  private int acctLength = 10;
  private int countDocLength = 5;
  private int wageLength = 8;
  private int goodsLength = 8;
  private int payLength = 9;
  private int pvLength = 10;
  private int cutCLength = 10;
  private int pcLength = 10;
  private int comLength = 11;
  private int cusLength = 10;
  private int totalCutVLength = 100 - (this.noLength + this.vendorLength + this.countDocLength + this.wageLength + this.goodsLength + this.payLength + this.pvLength);
  private int tmpLength = this.totalCutVLength;
  private int vPerCol = 0;
  private int overflowLength = 0;
  
  public Double[] newDoubleArray(int size) {
    Double[] result = new Double[size];
    for (int i = 0; i < size; i++)
      result[i] = new Double(0); 
    return result;
  }
  
  public String displayFormat(double val) {
    String result = "";
    DecimalFormat sub = new DecimalFormat("#######.###");
    String num = sub.format(val);
    if (num.indexOf(".") >= 0) {
      String data = num.substring(0, num.indexOf("."));
      String precision = num.substring(num.indexOf(".") + 1);
      for (; precision.length() < 3; precision = precision + "0");
      int digit3 = Integer.parseInt(precision.substring(2, 3));
      if (digit3 >= 5) {
        int tmp = Integer.parseInt(precision.substring(0, 2));
        tmp++;
        precision = Integer.toString(tmp);
      } else {
        precision = precision.substring(0, 2);
      } 
      result = data + "." + precision;
    } else {
      if (num.trim().length() == 0)
        num = "0"; 
      num = num + ".00";
      result = num;
    } 
    try {
      double tmp = Double.parseDouble(result);
      result = doString.displayNumber("#,###,##0.00", tmp);
    } catch (Exception exception) {}
    return result;
  }
  
  public void genHeaderPage(PdfPTable table, String headerReport, String currDate, Vector vendorCut, String iVendor, String vendorName, String markupPay, Font microssfont, Font microssfont_HD, Font microssfont_MINI, Font microssfont_BOLD) throws Exception {
    this.nowpage++;
    DecimalFormat format = new DecimalFormat("###,##0.00");
    PdfPCell cell = new PdfPCell(new Phrase("หน้า " + this.nowpage, microssfont));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(4);
    cell.setColspan(100);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(this.companyName), microssfont_HD));
    cell.setHorizontalAlignment(1);
    cell.setColspan(100);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("รายละเอียดการส่งงานซ่อมสาธารณูฯ(ส่วนกลาง) ของผู้รับเหมา (สรุปตามการตัดเงิน)", microssfont_HD));
    cell.setHorizontalAlignment(1);
    cell.setColspan(100);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(this.betweenDate, microssfont_HD));
    cell.setHorizontalAlignment(1);
    cell.setColspan(100);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(headerReport), microssfont_HD));
    cell.setHorizontalAlignment(0);
    cell.setVerticalAlignment(4);
    cell.setColspan(50);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("แบบรายงาน : SERV_INFPrintReport7 ,  " + currDate, microssfont));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(6);
    cell.setColspan(50);
    cell.setBorder(0);
    table.addCell(cell);
    String nameWithId = "";
    if (vendorName.trim().length() > 0 && iVendor.trim().length() > 0) {
      nameWithId = iVendor + " - " + vendorName;
    } else {
      nameWithId = vendorName;
    } 
    cell = new PdfPCell(new Phrase(" " + doString.MS874ToUnicode(nameWithId), microssfont_HD));
    cell.setHorizontalAlignment(0);
    cell.setVerticalAlignment(4);
    cell.setColspan(100);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ผู้รับเหมาตัดเงิน", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingTop(6);
    cell.setPaddingLeft(4);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.vendorLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("จำนวน", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.countDocLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("รหัสบัญชี", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.acctLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ค่าแรง ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.wageLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ค่าของ ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.goodsLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ค่าของ-ค่าแรง ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.payLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("รวมค่าดำเนินการ ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.pvLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ตัดเงินผู้รับเหมา", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(1);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.totalCutVLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.vendorLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ใบสั่งซ่อม ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setPaddingBottom(5);
    cell.setColspan(this.countDocLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.acctLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.wageLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.goodsLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("รวม ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setBorderColor(this.borderColor);
    cell.setPaddingBottom(5);
    cell.setColspan(this.payLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(markupPay, microssfont_BOLD));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(4);
    cell.setBorderColor(this.borderColor);
    cell.setPaddingBottom(5);
    cell.setColspan(this.pvLength);
    cell.setBorder(14);
    table.addCell(cell);
    for (int i = 0; i < vendorCut.size(); i++) {
      Double val = (Double)vendorCut.elementAt(i);
      cell = new PdfPCell(new Phrase(format.format(val.doubleValue()) + " %", microssfont_BOLD));
      cell.setHorizontalAlignment(1);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.vPerCol + ((i == vendorCut.size() - 1) ? this.overflowLength : 0));
      cell.setBorder(15);
      table.addCell(cell);
    } 
    cell = new PdfPCell(new Phrase((this.selProj.length() > 2) ? this.selProj.substring(0, 2) : "", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingBottom(5);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.cutCLength);
    cell.setBorder(15);
    table.addCell(cell);
  }
  
  public void genPubHeaderPage(PdfPTable table, String headerReport, String currDate, Vector vendorCut, String iVendor, String vendorName, String markupPay, Font microssfont, Font microssfont_HD, Font microssfont_MINI, Font microssfont_BOLD) throws Exception {
    this.nowpage++;
    PdfPCell cell = new PdfPCell(new Phrase("หน้า " + this.nowpage, microssfont));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(4);
    cell.setColspan(100);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(this.companyName), microssfont_HD));
    cell.setHorizontalAlignment(1);
    cell.setColspan(100);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("รายละเอียดการส่งงานซ่อมสาธารณะ ของผู้รับเหมา (สรุปตามการตัดเงิน)", microssfont_HD));
    cell.setHorizontalAlignment(1);
    cell.setColspan(100);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(this.betweenDate, microssfont_HD));
    cell.setHorizontalAlignment(1);
    cell.setColspan(100);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(headerReport), microssfont_HD));
    cell.setHorizontalAlignment(0);
    cell.setVerticalAlignment(4);
    cell.setColspan(50);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("แบบรายงาน : SERV_INFPrintReport7 ,  " + currDate, microssfont));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(6);
    cell.setColspan(50);
    cell.setBorder(0);
    table.addCell(cell);
    String nameWithId = "";
    if (vendorName.trim().length() > 0 && iVendor.trim().length() > 0) {
      nameWithId = iVendor + " - " + vendorName;
    } else {
      nameWithId = vendorName;
    } 
    cell = new PdfPCell(new Phrase(" " + doString.MS874ToUnicode(nameWithId), microssfont_HD));
    cell.setHorizontalAlignment(0);
    cell.setVerticalAlignment(4);
    cell.setColspan(100);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("No.", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.noLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ผู้รับเหมาตัดเงิน", microssfont_BOLD));
    cell.setHorizontalAlignment(0);
    cell.setVerticalAlignment(6);
    cell.setPaddingTop(6);
    cell.setPaddingLeft(4);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.vendorLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ประจำ ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.mnthLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("รหัสบัญชี ", microssfont_BOLD));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.acctLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("จำนวน ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.countDocLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ค่าแรง ", microssfont_BOLD));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.wageLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ค่าของ ", microssfont_BOLD));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.goodsLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ค่าของ-ค่าแรง ", microssfont_BOLD));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.payLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("รวมค่าดำเนินการ ", microssfont_BOLD));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.pvLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("คชจ.ของ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(1);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.totalCutVLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.noLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.vendorLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("เดือน ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setPaddingBottom(5);
    cell.setColspan(this.mnthLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(" ", microssfont_BOLD));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setPaddingBottom(5);
    cell.setColspan(this.acctLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ใบสั่งซ่อม ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setPaddingBottom(5);
    cell.setColspan(this.countDocLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.wageLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.goodsLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("รวม ", microssfont_BOLD));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(4);
    cell.setBorderColor(this.borderColor);
    cell.setPaddingBottom(5);
    cell.setColspan(this.payLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(markupPay, microssfont_BOLD));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(4);
    cell.setBorderColor(this.borderColor);
    cell.setPaddingBottom(5);
    cell.setColspan(this.pvLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("%บริษัท", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingBottom(5);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.pcLength);
    cell.setBorder(15);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("บริษัท", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingBottom(5);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.comLength);
    cell.setBorder(15);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ลูกบ้าน", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingBottom(5);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.cusLength);
    cell.setBorder(15);
    table.addCell(cell);
  }
  
  public void genInfPubHeaderPage(PdfPTable table, String headerReport, String currDate, Vector vendorCut, String iVendor, String vendorName, String markupPay, Font microssfont, Font microssfont_HD, Font microssfont_MINI, Font microssfont_BOLD) throws Exception {
    this.nowpage++;
    PdfPCell cell = new PdfPCell(new Phrase("หน้า " + this.nowpage, microssfont));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(4);
    cell.setColspan(100);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(this.companyName), microssfont_HD));
    cell.setHorizontalAlignment(1);
    cell.setColspan(100);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("รายละเอียดการส่งงานซ่อมสาธารณูฯ(ส่วนกลาง) ของผู้รับเหมา (สรุปตามการตัดเงิน)", microssfont_HD));
    cell.setHorizontalAlignment(1);
    cell.setColspan(100);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(this.betweenDate, microssfont_HD));
    cell.setHorizontalAlignment(1);
    cell.setColspan(100);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(headerReport), microssfont_HD));
    cell.setHorizontalAlignment(0);
    cell.setVerticalAlignment(4);
    cell.setColspan(50);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("แบบรายงาน : SERV_INFPrintReport7 ,  " + currDate, microssfont));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(6);
    cell.setColspan(50);
    cell.setBorder(0);
    table.addCell(cell);
    String nameWithId = "";
    if (vendorName.trim().length() > 0 && iVendor.trim().length() > 0) {
      nameWithId = iVendor + " - " + vendorName;
    } else {
      nameWithId = vendorName;
    } 
    cell = new PdfPCell(new Phrase(" " + doString.MS874ToUnicode(nameWithId), microssfont_HD));
    cell.setHorizontalAlignment(0);
    cell.setVerticalAlignment(4);
    cell.setColspan(100);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("No.", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.noLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ผู้รับเหมาตัดเงิน", microssfont_BOLD));
    cell.setHorizontalAlignment(0);
    cell.setVerticalAlignment(6);
    cell.setPaddingTop(6);
    cell.setPaddingLeft(4);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.vendorLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ประจำ ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.mnthLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("รหัสบัญชี ", microssfont_BOLD));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.acctLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("จำนวน ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.countDocLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ค่าแรง ", microssfont_BOLD));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.wageLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ค่าของ ", microssfont_BOLD));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.goodsLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ค่าของ-ค่าแรง ", microssfont_BOLD));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.payLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("รวมค่าดำเนินการ ", microssfont_BOLD));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.pvLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("คชจ.ของ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(1);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.totalCutVLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.noLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.vendorLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("เดือน ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setPaddingBottom(5);
    cell.setColspan(this.mnthLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(" ", microssfont_BOLD));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setPaddingBottom(5);
    cell.setColspan(this.acctLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ใบสั่งซ่อม ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setBorderColor(this.borderColor);
    cell.setPaddingBottom(5);
    cell.setColspan(this.countDocLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.wageLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.goodsLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("รวม ", microssfont_BOLD));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(4);
    cell.setBorderColor(this.borderColor);
    cell.setPaddingBottom(5);
    cell.setColspan(this.payLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(markupPay, microssfont_BOLD));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(4);
    cell.setBorderColor(this.borderColor);
    cell.setPaddingBottom(5);
    cell.setColspan(this.pvLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("%บริษัท", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingBottom(5);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.pcLength);
    cell.setBorder(15);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("บริษัท", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingBottom(5);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.comLength);
    cell.setBorder(15);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ลูกบ้าน", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingBottom(5);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.cusLength);
    cell.setBorder(15);
    table.addCell(cell);
  }
  
  public void genVendorData(Document document, PdfWriter writer, Connection conn, String iVendor, String companyName, String headerReport, Vector vendorCut, String markupPay, Font microssfont, Font microssfont_HD, Font microssfont_MINI, Font microssfont_BOLD) throws Exception {
    String currDate = "";
    Calendar now = Calendar.getInstance(Locale.ENGLISH);
    doString str = new doString();
    Statement stmt = null;
    Statement stmt1 = null;
    ResultSet rs = null;
    ResultSet rs1 = null;
    StringBuffer sql = new StringBuffer();
    PdfPTable table = new PdfPTable(100);
    table.setWidthPercentage(100);
    double totalWage = 0;
    double totalGoods = 0;
    double totalPay = 0;
    double totalPV = 0;
    double totalCutCompany = 0;
    double grandTotalWage = 0;
    double grandTotalPrice = 0;
    int totalLine = 0;
    this.noLength = 3;
    this.vendorLength = 30;
    this.countDocLength = 5;
    this.acctLength = 8;
    this.wageLength = 7;
    this.goodsLength = 7;
    this.payLength = 7;
    this.pvLength = 8;
    this.cutCLength = 11;
    this.totalCutVLength = 100 - (this.acctLength + this.vendorLength + this.countDocLength + this.wageLength + this.goodsLength + this.payLength + this.pvLength);
    Double[] sumCutVendor = newDoubleArray(vendorCut.size());
    this.tmpLength = this.totalCutVLength;
    this.vPerCol = 0;
    this.overflowLength = 0;
    if (vendorCut.size() > 0) {
      this.vPerCol = (this.tmpLength - this.tmpLength % (vendorCut.size() + 1)) / (vendorCut.size() + 1);
      this.overflowLength = this.tmpLength % (vendorCut.size() + 1);
      this.cutCLength = this.vPerCol;
    } 
    try {
      stmt = conn.createStatement();
      stmt1 = conn.createStatement();
      currDate = str.createID(now.get(5), 2) + "/" + str.createID(now.get(2) + 1, 2);
      int nYear = now.get(1);
      if (nYear < 2500)
        nYear += 543; 
      currDate = currDate + "/" + str.createID(nYear, 4);
      currDate = currDate + " , " + str.createID(now.get(11), 2) + ":" + str.createID(now.get(12), 2);
      String vendorName = "";
      if (iVendor.equals("999999")) {
        vendorName = companyName;
      } else {
        sql.delete(0, sql.length());
        sql.append("select bus_name from lan:stpvendr where vend_code='").append(iVendor).append("' ");
        rs = stmt1.executeQuery(sql.toString());
        if (rs.next())
          vendorName = doString.checkString(rs.getString("bus_name"), ""); 
        rs.close();
      } 
      genHeaderPage(table, headerReport, currDate, vendorCut, iVendor, vendorName, markupPay, microssfont, microssfont_HD, microssfont_MINI, microssfont_BOLD);
      totalLine += 8;
      int line = 0;
      sql.delete(0, sql.length());
      sql.append("SELECT b.i_ven_cut, b.i_account, SUM(q_wage_unit * z_wage_price) AS SUM_WAGE, ")
        .append(" SUM(q_good_unit * z_good_price) AS SUM_GOODS, ")
        .append(" SUM((q_wage_unit * z_wage_price * p_add_pay)/100) AS SUM_WAGE_ADD_PAY, ")
        .append(" SUM((q_good_unit * z_good_price * p_add_pay)/100) AS SUM_PRICE_ADD_PAY, ")
        .append(" SUM(z_amount_pay) AS SUM_AMOUNT_PAY, SUM(z_amount_pv) AS SUM_AMOUNT_PV, ")
        .append(" SUM(z_amount_cut) AS SUM_AMOUNT_CUT FROM lan:serv_infpayment b, lan:serv_infdochd a ")
        .append(" WHERE b.f_itmstatus = 'CLS' AND b.i_itmtype = '01' ")
        .append(this.condition);
      sql.append(" AND b.i_docno = a.i_docno AND a.f_status IN ('OPN','CLS') GROUP BY b.i_ven_cut, b.i_account ")
        .append(" ORDER BY b.i_ven_cut, b.i_account");
      rs = stmt.executeQuery(sql.toString());
      while (rs.next() == true) {
        String vendorId = doString.checkString(rs.getString("I_VEN_CUT"), "");
        String accountId = doString.checkString(rs.getString("I_ACCOUNT"), "");
        double sumWage = rs.getDouble("sum_wage");
        double sumGoods = rs.getDouble("sum_goods");
        double amountPay = rs.getDouble("sum_amount_pay");
        double amountPV = rs.getDouble("sum_amount_pv");
        double sumWageAddPay = rs.getDouble("sum_wage_add_pay");
        double sumPriceAddPay = rs.getDouble("sum_price_add_pay");
        double cutVend = 0;
        double cutComp = 0;
        Double[] cutVendor = newDoubleArray(vendorCut.size());
        totalWage += sumWage;
        totalGoods += sumGoods;
        totalPay += amountPay;
        totalPV += amountPV;
        grandTotalWage += sumWageAddPay;
        grandTotalPrice += sumPriceAddPay;
        int countDoc = 0;
        sql.delete(0, sql.length());
        sql.append("SELECT COUNT(*) FROM lan:serv_infpayment b, lan:serv_infdochd a WHERE ")
          
          .append(" b.f_itmstatus = 'CLS' AND b.i_itmtype = '01' ")
          .append(" AND b.i_ven_cut = '").append(vendorId).append("' ")
          .append(" AND b.i_account = '").append(accountId).append("' ")
          .append(this.condition)
          .append(" AND b.i_docno = a.i_docno AND a.f_status IN ('OPN','CLS') GROUP BY b.i_docno");
        rs1 = stmt1.executeQuery(sql.toString());
        while (rs1.next() == true) {
          countDoc++; 
        }
        rs1.close();
        rs1=null;
        String vendName = "";
        if (vendorId.equals("999999")) {
          vendName = companyName;
        } else {
          sql.delete(0, sql.length());
          sql.append("SELECT bus_name FROM lan:stpvendr WHERE vend_code = '").append(vendorId).append("'");
          rs1 = stmt1.executeQuery(sql.toString());
          if (rs1.next() == true) {
            vendName = doString.checkString(rs1.getString("BUS_NAME"), "");
          }
          rs1.close();
          rs1 = null;
        } 
        sql.delete(0, sql.length());
        sql.append("SELECT p_cut, SUM(z_cut_pv) AS SUM_CUT_PV FROM lan:serv_infpayment b, lan:serv_infdochd a ")
          .append(" WHERE b.f_itmstatus = 'CLS' AND b.i_itmtype = '01' ")
          .append(" AND b.i_ven_cut = '").append(vendorId).append("' ")
          .append(" AND b.i_account = '").append(accountId).append("' ");
        if (iVendor.length() > 0) {
          sql.append(" AND b.i_vendor = '").append(iVendor).append("' ");
        }
        sql.append(this.condition);
        sql.append(" AND b.i_docno = a.i_docno AND a.f_status IN ('OPN','CLS') GROUP BY p_cut");
        rs1 = stmt1.executeQuery(sql.toString());
        while (rs1.next() == true) {
          double pCut = rs1.getDouble("P_CUT");
          double cutValue = rs1.getDouble("SUM_CUT_PV");
          if (pCut == 0 && vendorId.equals("999999")) {
            cutComp += cutValue;
            totalCutCompany += cutValue;
            continue;
          }
          cutVend += cutValue;
          for (int k = 0; k < vendorCut.size(); k++) {
            Double cut = (Double)vendorCut.elementAt(k);
            if (cut.doubleValue() == pCut) {
              cutVendor[k] = new Double(cutValue);
              sumCutVendor[k] = new Double(sumCutVendor[k].doubleValue() + cutValue);
              break;
            } 
          } 
        } 
        rs1.close();
        rs1 = null;
        if (cutVend > 0) {
            if (amountPV == cutVend) {
            	accountId = "11411";
            } else {
            	accountId += ",11411";
            }
        }
        PdfPCell pdfPCell = new PdfPCell(new Phrase(doString.MS874ToUnicode(vendorId + " - " + vendName), microssfont));
        pdfPCell.setHorizontalAlignment(0);
        pdfPCell.setVerticalAlignment(5);
        pdfPCell.setBorderColor(this.borderColor);
        pdfPCell.setFixedHeight(21);
        pdfPCell.setPaddingTop(3);
        pdfPCell.setPaddingBottom(5);
        pdfPCell.setColspan(this.vendorLength);
        pdfPCell.setBorder(15);
        table.addCell(pdfPCell);
        
        pdfPCell = new PdfPCell(new Phrase(Integer.toString(countDoc), microssfont));
        pdfPCell.setHorizontalAlignment(2);
        pdfPCell.setVerticalAlignment(5);
        pdfPCell.setBorderColor(this.borderColor);
        pdfPCell.setFixedHeight(21);
        pdfPCell.setPaddingTop(3);
        pdfPCell.setPaddingBottom(5);
        pdfPCell.setColspan(this.countDocLength);
        pdfPCell.setBorder(15);
        table.addCell(pdfPCell);
        
        pdfPCell = new PdfPCell(new Phrase(accountId, microssfont));
        pdfPCell.setHorizontalAlignment(1);
        pdfPCell.setVerticalAlignment(5);
        pdfPCell.setBorderColor(this.borderColor);
        pdfPCell.setFixedHeight(21);
        pdfPCell.setPaddingTop(3);
        pdfPCell.setPaddingBottom(5);
        pdfPCell.setColspan(this.acctLength);
        pdfPCell.setBorder(15);
        table.addCell(pdfPCell);
        pdfPCell = new PdfPCell(new Phrase(displayFormat(sumWage), microssfont));
        pdfPCell.setHorizontalAlignment(2);
        pdfPCell.setVerticalAlignment(5);
        pdfPCell.setBorderColor(this.borderColor);
        pdfPCell.setFixedHeight(21);
        pdfPCell.setPaddingTop(3);
        pdfPCell.setPaddingBottom(5);
        pdfPCell.setColspan(this.wageLength);
        pdfPCell.setBorder(15);
        table.addCell(pdfPCell);
        pdfPCell = new PdfPCell(new Phrase(displayFormat(sumGoods), microssfont));
        pdfPCell.setHorizontalAlignment(2);
        pdfPCell.setVerticalAlignment(5);
        pdfPCell.setBorderColor(this.borderColor);
        pdfPCell.setFixedHeight(21);
        pdfPCell.setPaddingTop(3);
        pdfPCell.setPaddingBottom(5);
        pdfPCell.setColspan(this.goodsLength);
        pdfPCell.setBorder(15);
        table.addCell(pdfPCell);
        pdfPCell = new PdfPCell(new Phrase(displayFormat(amountPay), microssfont));
        pdfPCell.setHorizontalAlignment(2);
        pdfPCell.setVerticalAlignment(5);
        pdfPCell.setBorderColor(this.borderColor);
        pdfPCell.setFixedHeight(21);
        pdfPCell.setPaddingTop(3);
        pdfPCell.setPaddingBottom(5);
        pdfPCell.setColspan(this.payLength);
        pdfPCell.setBorder(15);
        table.addCell(pdfPCell);
        pdfPCell = new PdfPCell(new Phrase(displayFormat(amountPV), microssfont));
        pdfPCell.setHorizontalAlignment(2);
        pdfPCell.setVerticalAlignment(5);
        pdfPCell.setBorderColor(this.borderColor);
        pdfPCell.setFixedHeight(21);
        pdfPCell.setPaddingTop(3);
        pdfPCell.setPaddingBottom(5);
        pdfPCell.setColspan(this.pvLength);
        pdfPCell.setBorder(15);
        table.addCell(pdfPCell);
        for (int j = 0; j < vendorCut.size(); j++) {
          pdfPCell = new PdfPCell(new Phrase(displayFormat(cutVendor[j].doubleValue()), microssfont));
          pdfPCell.setHorizontalAlignment(2);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.vPerCol + ((j == vendorCut.size() - 1) ? this.overflowLength : 0));
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
        }//end for 
        pdfPCell = new PdfPCell(new Phrase(displayFormat(cutComp), microssfont));
        pdfPCell.setHorizontalAlignment(2);
        pdfPCell.setVerticalAlignment(5);
        pdfPCell.setBorderColor(this.borderColor);
        pdfPCell.setFixedHeight(21);
        pdfPCell.setPaddingBottom(5);
        pdfPCell.setColspan(this.cutCLength);
        pdfPCell.setBorder(15);
        table.addCell(pdfPCell);
        line++;
        totalLine++;
        if (totalLine >= 25) {
          Rectangle page = document.getPageSize();
          PdfPTable foot = new PdfPTable(1);
          PdfPCell pcell = new PdfPCell(new Phrase(" มีหน้าต่อไป      ", microssfont));
          pcell.setHorizontalAlignment(2);
          pcell.setVerticalAlignment(4);
          pcell.setBorder(0);
          foot.addCell(pcell);
          foot.setTotalWidth(page.width() - document.leftMargin() - document.rightMargin());
          foot.writeSelectedRows(0, 1, document.leftMargin(), document.bottomMargin() + 20, writer.getDirectContent());
          document.add((Element)table);
          document.newPage();
          table = new PdfPTable(100);
          table.setWidthPercentage(100);
          totalLine = 0;
          genHeaderPage(table, headerReport, currDate, vendorCut, iVendor, vendorName, markupPay, microssfont, microssfont_HD, microssfont_MINI, microssfont_BOLD);
          totalLine += 8;
        } 
      } 
      PdfPCell cell = new PdfPCell(new Phrase("รวมเป็นเงิน", microssfont));
      cell.setHorizontalAlignment(1);
      cell.setVerticalAlignment(4);
      cell.setBorderColor(this.borderColor);
      cell.setPaddingBottom(5);
      cell.setColspan(this.acctLength + this.vendorLength + this.countDocLength);
      cell.setBorder(0);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalWage), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.wageLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalGoods), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.goodsLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalPay), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.payLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalPV), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.pvLength);
      cell.setBorder(15);
      cell.setBackgroundColor(new Color(this.LIGHT_GRAY_COLOR));
      table.addCell(cell);
      for (int c = 0; c < vendorCut.size(); c++) {
        cell = new PdfPCell(new Phrase(displayFormat(sumCutVendor[c].doubleValue()), microssfont));
        cell.setBorderColor(this.borderColor);
        cell.setHorizontalAlignment(2);
        cell.setVerticalAlignment(4);
        cell.setPaddingBottom(5);
        cell.setColspan(this.vPerCol + ((c == vendorCut.size() - 1) ? this.overflowLength : 0));
        cell.setBorder(15);
        cell.setBackgroundColor(new Color(this.LIGHT_GRAY_COLOR));
        table.addCell(cell);
      } 
      cell = new PdfPCell(new Phrase(displayFormat(totalCutCompany), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.cutCLength);
      cell.setBorder(15);
      cell.setBackgroundColor(new Color(this.LIGHT_GRAY_COLOR));
      table.addCell(cell);
      cell = new PdfPCell(new Phrase("รวมค่าดำเนินการ " + markupPay, microssfont));
      cell.setHorizontalAlignment(1);
      cell.setVerticalAlignment(4);
      cell.setBorderColor(this.borderColor);
      cell.setPaddingBottom(5);
      cell.setColspan(this.acctLength + this.vendorLength + this.countDocLength);
      cell.setBorder(0);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalWage + grandTotalWage), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.wageLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(doString.displayNumber("###,###,###.00", totalGoods + grandTotalPrice), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.goodsLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalPV), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.payLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase("", microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.pvLength + this.totalCutVLength + this.cutCLength);
      cell.setBorder(15);
      table.addCell(cell);
      double sumWageLH1 = 0;
      double sumGoodsLH1 = 0;
      double sumPayLH1 = 0;
      double sumPvLH1 = 0;
      sql.delete(0, sql.length());
      sql.append(" SELECT b.i_ven_cut, sum(q_wage_unit * z_wage_price) sum_wage, ")
        .append(" sum(q_good_unit * z_good_price) sum_goods, ")
        .append(" sum(z_amount_pay) sum_amount_pay, sum(z_amount_pv) sum_amount_pv ")
        .append(" FROM lan:serv_infpayment b, lan:serv_infdochd a ")
        
        .append(" WHERE b.f_itmstatus = 'CLS' AND b.i_itmtype = '01' ")
        .append(" AND b.i_ven_cut = '999999' ")
        .append(this.condition)
        .append(" AND b.i_docno = a.i_docno AND a.f_status IN ('OPN','CLS') GROUP BY b.i_ven_cut ")
        .append(" ORDER BY b.i_ven_cut ");
      rs1 = stmt1.executeQuery(sql.toString());
      while (rs1.next()) {
        sumWageLH1 += rs1.getDouble("sum_wage");
        sumGoodsLH1 += rs1.getDouble("sum_goods");
        sumPayLH1 += rs1.getDouble("sum_amount_pay");
        sumPvLH1 += rs1.getDouble("sum_amount_pv");
      } 
      rs1.close();
      cell = new PdfPCell(new Phrase("", microssfont));
      cell.setHorizontalAlignment(0);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(100);
      cell.setBorder(0);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(companyName), microssfont));
      cell.setHorizontalAlignment(0);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(this.vendorLength);
      cell.setBorder(0);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(" (รับผิดชอบ) "), microssfont));
      cell.setHorizontalAlignment(0);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(this.acctLength + this.countDocLength);
      cell.setBorder(0);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(sumWageLH1), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(this.wageLength);
      cell.setBorder(0);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(sumGoodsLH1), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(this.goodsLength);
      cell.setBorder(0);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(sumPayLH1), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(this.payLength);
      cell.setBorder(0);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(sumPvLH1), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(this.pvLength);
      cell.setBorder(0);
      table.addCell(cell);
      for (int i = 0; i < vendorCut.size(); i++) {
        cell = new PdfPCell(new Phrase("", microssfont));
        cell.setHorizontalAlignment(2);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.vPerCol + ((i == vendorCut.size() - 1) ? this.overflowLength : 0));
        cell.setBorder(0);
        table.addCell(cell);
      } 
      cell = new PdfPCell(new Phrase("", microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(this.cutCLength);
      cell.setBorder(0);
      table.addCell(cell);
      document.add((Element)table);
      document.newPage();
    } catch (Exception e) {
    
    } finally {
      if (rs != null)
        rs.close(); 
      if (rs1 != null)
        rs1.close(); 
      if (stmt != null)
        stmt.close(); 
      if (stmt1 != null)
        stmt1.close(); 
    } 
  }
  
  public void genPubVendorData(Document document, PdfWriter writer, Connection conn, String iVendor, String companyName, String headerReport, Vector vendorCut, String markupPay, Font microssfont, Font microssfont_HD, Font microssfont_MINI, Font microssfont_BOLD) throws Exception {
    String currDate = "";
    Calendar now = Calendar.getInstance(Locale.ENGLISH);
    doString str = new doString();
    Statement stmt = null;
    Statement stmt1 = null;
    ResultSet rs = null;
    ResultSet rs1 = null;
    StringBuffer sql = new StringBuffer();
    PdfPTable table = new PdfPTable(100);
    table.setWidthPercentage(100);
    String acctId = "";
    String com_ps = "";
    double totalWage = 0;
    double totalGoods = 0;
    double totalPay = 0;
    double totalPV = 0;
    double grandTotalWage = 0;
    double grandTotalPrice = 0;
    double totalLH = 0;
    double totalCust = 0;
    int totalLine = 0;
    int num = 0;
    this.noLength = 3;
    this.vendorLength = 21;
    this.mnthLength = 6;
    this.acctLength = 8;
    this.countDocLength = 6;
    this.wageLength = 8;
    this.goodsLength = 8;
    this.payLength = 8;
    this.pvLength = 9;
    this.pcLength = 5;
    this.comLength = 9;
    this.cusLength = 9;
    this.totalCutVLength = 100 - (this.noLength + this.vendorLength + this.mnthLength + this.acctLength + this.countDocLength + this.wageLength + this.goodsLength + this.payLength + this.pvLength);
    this.tmpLength = this.totalCutVLength;
    this.vPerCol = 0;
    this.overflowLength = 0;
    try {
      stmt = conn.createStatement();
      stmt1 = conn.createStatement();
      currDate = str.createID(now.get(5), 2) + "/" + str.createID(now.get(2) + 1, 2);
      int nYear = now.get(1);
      if (nYear < 2500)
        nYear += 543; 
      currDate = currDate + "/" + str.createID(nYear, 4);
      currDate = currDate + " , " + str.createID(now.get(11), 2) + ":" + str.createID(now.get(12), 2);
      String vendorName = "";
      if (iVendor.equals("999999")) {
        vendorName = companyName;
      } else {
        rs = stmt1.executeQuery("SELECT bus_name FROM lan:stpvendr WHERE vend_code = '" + iVendor + "'");
        if (rs.next())
          vendorName = doString.checkString(rs.getString("BUS_NAME")); 
        rs.close();
        rs = null;
      } 
      genPubHeaderPage(table, headerReport, currDate, vendorCut, iVendor, vendorName, markupPay, microssfont, microssfont_HD, microssfont_MINI, microssfont_BOLD);
      totalLine += 8;
      int line = 0;
      sql.delete(0, sql.length());
      sql.append("SELECT b.i_ven_cut, b.i_month, b.p_com, b.i_account, SUM(b.q_wage_unit * b.z_wage_price) AS SUM_WAGE, ")
        .append(" SUM(b.q_good_unit * b.z_good_price) AS SUM_GOODS, ")
        .append(" SUM((b.q_wage_unit * b.z_wage_price * p_add_pay)/100) AS SUM_WAGE_ADD_PAY, ")
        .append(" SUM((b.q_good_unit * b.z_good_price * p_add_pay)/100) AS SUM_PRICE_ADD_PAY, ")
        .append(" SUM(b.z_amount_pay) AS SUM_AMOUNT_PAY, SUM(b.z_amount_pv) AS SUM_AMOUNT_PV, ")
        .append(" SUM(b.z_com_amount) AS SUM_AMOUNT_COM, SUM(b.z_cus_amount) AS SUM_AMOUNT_CUS FROM lan:serv_infpayment b, lan:serv_infdochd a ")
        .append(" WHERE b.f_itmstatus = 'CLS' AND b.i_itmtype = '02' ")
        .append(this.condition);
      sql.append(" AND b.i_docno = a.i_docno AND a.f_status IN ('OPN','CLS') GROUP BY b.i_ven_cut, b.i_month, b.p_com, b.i_account ")
        .append(" ORDER BY b.i_ven_cut, b.i_month, b.p_com, b.i_account");
      rs = stmt.executeQuery(sql.toString());
      if (rs != null) {
        while (rs.next()) {
          String vendorId = doString.checkString(rs.getString("I_VEN_CUT"));
          String mnthDate = doString.checkString(rs.getString("I_MONTH"));
          String mnth = mnthDate.substring(5, 7);
          String year = Integer.toString(Integer.parseInt(mnthDate.substring(0, 4)) + 543);
          double p_com = rs.getDouble("P_COM");
          com_ps = doString.displayNumber("###.00", p_com);
          acctId = doString.checkString(rs.getString("I_ACCOUNT"));
          double sumWage = rs.getDouble("SUM_WAGE");
          double sumGoods = rs.getDouble("SUM_GOODS");
          double amountPay = rs.getDouble("SUM_AMOUNT_PAY");
          double amountPV = rs.getDouble("SUM_AMOUNT_PV");
          double sumWageAddPay = rs.getDouble("SUM_WAGE_ADD_PAY");
          double sumPriceAddPay = rs.getDouble("SUM_PRICE_ADD_PAY");
          double amountLH = rs.getDouble("SUM_AMOUNT_COM");
          double amountCust = rs.getDouble("SUM_AMOUNT_CUS");
          totalWage += sumWage;
          totalGoods += sumGoods;
          totalPay += amountPay;
          totalPV += amountPV;
          totalLH += amountLH;
          totalCust += amountCust;
          grandTotalWage += sumWageAddPay;
          grandTotalPrice += sumPriceAddPay;
          int countDoc = 0;
          sql.delete(0, sql.length());
          sql.append("SELECT COUNT(*) FROM serv_infpayment b, lan:serv_infdochd a WHERE b.p_com = ")
            .append(com_ps)
            .append(" AND b.f_itmstatus = 'CLS'")
            .append(" AND b.i_ven_cut = '").append(vendorId).append("' ")
            .append(" AND b.i_month = '").append(mnthDate).append("' ")
            .append(" AND b.i_itmtype = '02' AND b.i_account = '").append(acctId).append("' ")
            .append(this.condition)
            .append(" AND b.i_docno = a.i_docno AND a.f_status IN ('OPN','CLS') GROUP BY b.i_docno ");
          rs1 = stmt1.executeQuery(sql.toString());
          while (rs1.next())
            countDoc++; 
          rs1.close();
          rs1 = null;
          String vendName = "";
          if (vendorId.equals("999999")) {
            vendName = companyName;
          } else {
            sql.delete(0, sql.length());
            sql.append("SELECT bus_name FROM lan:stpvendr WHERE vend_code = '").append(vendorId).append("'");
            rs1 = stmt1.executeQuery(sql.toString());
            if (rs1.next())
              vendName = doString.checkString(rs1.getString("bus_name"), ""); 
            rs1.close();
          } 
          num++;
          PdfPCell pdfPCell = new PdfPCell(new Phrase(Integer.toString(num), microssfont));
          pdfPCell.setHorizontalAlignment(1);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.noLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          pdfPCell = new PdfPCell(new Phrase(doString.MS874ToUnicode(vendorId + " - " + vendName), microssfont));
          pdfPCell.setHorizontalAlignment(0);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.vendorLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          pdfPCell = new PdfPCell(new Phrase(mnth + "/" + year, microssfont));
          pdfPCell.setHorizontalAlignment(1);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.mnthLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          pdfPCell = new PdfPCell(new Phrase(acctId, microssfont));
          pdfPCell.setHorizontalAlignment(1);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.acctLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          pdfPCell = new PdfPCell(new Phrase(Integer.toString(countDoc), microssfont));
          pdfPCell.setHorizontalAlignment(1);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.countDocLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          pdfPCell = new PdfPCell(new Phrase(displayFormat(sumWage), microssfont));
          pdfPCell.setHorizontalAlignment(2);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.wageLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          pdfPCell = new PdfPCell(new Phrase(displayFormat(sumGoods), microssfont));
          pdfPCell.setHorizontalAlignment(2);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.goodsLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          pdfPCell = new PdfPCell(new Phrase(displayFormat(amountPay), microssfont));
          pdfPCell.setHorizontalAlignment(2);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.payLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          pdfPCell = new PdfPCell(new Phrase(displayFormat(amountPV), microssfont));
          pdfPCell.setHorizontalAlignment(2);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.pvLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          pdfPCell = new PdfPCell(new Phrase(displayFormat(p_com), microssfont));
          pdfPCell.setHorizontalAlignment(2);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.pcLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          pdfPCell = new PdfPCell(new Phrase(displayFormat(amountLH), microssfont));
          pdfPCell.setHorizontalAlignment(2);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.comLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          if (amountLH > 0 && amountCust > 0) {
            pdfPCell = new PdfPCell(new Phrase(" ", microssfont));
          } else {
            pdfPCell = new PdfPCell(new Phrase(displayFormat(amountCust), microssfont));
          } 
          pdfPCell.setHorizontalAlignment(2);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.cusLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          line++;
          totalLine++;
          if (totalLine >= 25) {
            Rectangle page = document.getPageSize();
            PdfPTable foot = new PdfPTable(1);
            PdfPCell pcell = new PdfPCell(new Phrase(" มีหน้าต่อไป      ", microssfont));
            pcell.setHorizontalAlignment(2);
            pcell.setVerticalAlignment(4);
            pcell.setBorder(0);
            foot.addCell(pcell);
            foot.setTotalWidth(page.width() - document.leftMargin() - document.rightMargin());
            foot.writeSelectedRows(0, 1, document.leftMargin(), document.bottomMargin() + 20, writer.getDirectContent());
            document.add((Element)table);
            document.newPage();
            table = new PdfPTable(100);
            table.setWidthPercentage(100);
            totalLine = 0;
            genPubHeaderPage(table, headerReport, currDate, vendorCut, iVendor, vendorName, markupPay, microssfont, microssfont_HD, microssfont_MINI, microssfont_BOLD);
            totalLine += 8;
          } 
          if (amountLH > 0 && amountCust > 0) {
            sql.delete(0, sql.length());
            sql.append("SELECT b.i_acct_cus, SUM(b.z_cus_amount) AS SUM_AMOUNT_CUS FROM serv_infpayment b, lan:serv_infdochd a WHERE b.p_com = ")
              .append(com_ps)
              .append(" AND b.f_itmstatus = 'CLS'")
              .append(" AND b.i_ven_cut = '").append(vendorId).append("' ")
              .append(" AND b.i_month = '").append(mnthDate).append("' ")
              .append(" AND b.i_itmtype = '02' AND b.i_account = '").append(acctId).append("' ")
              .append(this.condition)
              .append(" AND b.i_docno = a.i_docno AND a.f_status IN ('OPN','CLS') GROUP BY b.i_acct_cus");
            rs1 = stmt1.executeQuery(sql.toString());
            if (rs1 != null) {
              while (rs1.next()) {
                acctId = doString.checkString(rs1.getString("I_ACCT_CUS"));
                amountCust = rs1.getDouble("SUM_AMOUNT_CUS");
                pdfPCell = new PdfPCell(new Phrase(Integer.toString(num), microssfont));
                pdfPCell.setHorizontalAlignment(1);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.noLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(doString.MS874ToUnicode(vendorId + " - " + vendName), microssfont));
                pdfPCell.setHorizontalAlignment(0);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.vendorLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(mnth + "/" + year, microssfont));
                pdfPCell.setHorizontalAlignment(1);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.mnthLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(acctId, microssfont));
                pdfPCell.setHorizontalAlignment(1);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.acctLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(Integer.toString(countDoc), microssfont));
                pdfPCell.setHorizontalAlignment(1);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.countDocLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(" ", microssfont));
                pdfPCell.setHorizontalAlignment(2);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.wageLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(" ", microssfont));
                pdfPCell.setHorizontalAlignment(2);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.goodsLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(" ", microssfont));
                pdfPCell.setHorizontalAlignment(2);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.payLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(" ", microssfont));
                pdfPCell.setHorizontalAlignment(2);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.pvLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(" ", microssfont));
                pdfPCell.setHorizontalAlignment(2);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.pcLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(" ", microssfont));
                pdfPCell.setHorizontalAlignment(2);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.comLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(displayFormat(amountCust), microssfont));
                pdfPCell.setHorizontalAlignment(2);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.cusLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                line++;
                totalLine++;
                if (totalLine >= 25) {
                  Rectangle page = document.getPageSize();
                  PdfPTable foot = new PdfPTable(1);
                  PdfPCell pcell = new PdfPCell(new Phrase(" มีหน้าต่อไป      ", microssfont));
                  pcell.setHorizontalAlignment(2);
                  pcell.setVerticalAlignment(4);
                  pcell.setBorder(0);
                  foot.addCell(pcell);
                  foot.setTotalWidth(page.width() - document.leftMargin() - document.rightMargin());
                  foot.writeSelectedRows(0, 1, document.leftMargin(), document.bottomMargin() + 20, writer.getDirectContent());
                  document.add((Element)table);
                  document.newPage();
                  table = new PdfPTable(100);
                  table.setWidthPercentage(100);
                  totalLine = 0;
                  genPubHeaderPage(table, headerReport, currDate, vendorCut, iVendor, vendorName, markupPay, microssfont, microssfont_HD, microssfont_MINI, microssfont_BOLD);
                  totalLine += 8;
                } 
              } 
              rs1.close();
              rs1 = null;
            } 
          } 
        } 
        rs.close();
        rs = null;
      } 
      PdfPCell cell = new PdfPCell(new Phrase("รวมเป็นเงิน", microssfont));
      cell.setHorizontalAlignment(1);
      cell.setVerticalAlignment(4);
      cell.setBorderColor(this.borderColor);
      cell.setPaddingBottom(5);
      cell.setColspan(this.noLength + this.vendorLength + this.mnthLength + this.acctLength + this.countDocLength);
      cell.setBorder(0);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalWage), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.wageLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalGoods), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.goodsLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalPay), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.payLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalPV), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.pvLength);
      cell.setBorder(15);
      cell.setBackgroundColor(new Color(this.LIGHT_GRAY_COLOR));
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(" ", microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.pcLength);
      cell.setBorder(15);
      cell.setBackgroundColor(new Color(this.LIGHT_GRAY_COLOR));
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalLH), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.comLength);
      cell.setBorder(15);
      cell.setBackgroundColor(new Color(this.LIGHT_GRAY_COLOR));
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalCust), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.cusLength);
      cell.setBorder(15);
      cell.setBackgroundColor(new Color(this.LIGHT_GRAY_COLOR));
      table.addCell(cell);
      cell = new PdfPCell(new Phrase("รวมค่าดำเนินการ " + markupPay, microssfont));
      cell.setHorizontalAlignment(1);
      cell.setVerticalAlignment(4);
      cell.setBorderColor(this.borderColor);
      cell.setPaddingBottom(5);
      cell.setColspan(this.noLength + this.vendorLength + this.mnthLength + this.acctLength + this.countDocLength);
      cell.setBorder(0);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalWage + grandTotalWage), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.wageLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalGoods + grandTotalPrice), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.goodsLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalPV), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.payLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase("", microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.pvLength + this.totalCutVLength);
      cell.setBorder(15);
      table.addCell(cell);
      document.add((Element)table);
      document.newPage();
    } catch (Exception e) {
    
    } finally {
      if (rs != null)
        rs.close(); 
      if (rs1 != null)
        rs1.close(); 
      if (stmt != null)
        stmt.close(); 
      if (stmt1 != null)
        stmt1.close(); 
    } 
  }
  
  public void genInfPubVendorData(Document document, PdfWriter writer, Connection conn, String iVendor, String companyName, String headerReport, Vector vendorCut, String markupPay, Font microssfont, Font microssfont_HD, Font microssfont_MINI, Font microssfont_BOLD) throws Exception {
    String currDate = "";
    Calendar now = Calendar.getInstance(Locale.ENGLISH);
    doString str = new doString();
    Statement stmt = null;
    Statement stmt1 = null;
    ResultSet rs = null;
    ResultSet rs1 = null;
    StringBuffer sql = new StringBuffer();
    PdfPTable table = new PdfPTable(100);
    table.setWidthPercentage(100);
    String acctId = "";
    String com_ps = "";
    double totalWage = 0;
    double totalGoods = 0;
    double totalPay = 0;
    double totalPV = 0;
    double grandTotalWage = 0;
    double grandTotalPrice = 0;
    double totalLH = 0;
    double totalCust = 0;
    int totalLine = 0;
    int num = 0;
    this.noLength = 3;
    this.vendorLength = 21;
    this.mnthLength = 6;
    this.acctLength = 8;
    this.countDocLength = 6;
    this.wageLength = 8;
    this.goodsLength = 8;
    this.payLength = 8;
    this.pvLength = 9;
    this.pcLength = 5;
    this.comLength = 9;
    this.cusLength = 9;
    this.totalCutVLength = 100 - (this.noLength + this.vendorLength + this.mnthLength + this.acctLength + this.countDocLength + this.wageLength + this.goodsLength + this.payLength + this.pvLength);
    this.tmpLength = this.totalCutVLength;
    this.vPerCol = 0;
    this.overflowLength = 0;
    try {
      stmt = conn.createStatement();
      stmt1 = conn.createStatement();
      currDate = str.createID(now.get(5), 2) + "/" + str.createID(now.get(2) + 1, 2);
      int nYear = now.get(1);
      if (nYear < 2500)
        nYear += 543; 
      currDate = currDate + "/" + str.createID(nYear, 4);
      currDate = currDate + " , " + str.createID(now.get(11), 2) + ":" + str.createID(now.get(12), 2);
      String vendorName = "";
      if (iVendor.equals("999999")) {
        vendorName = companyName;
      } else {
        rs = stmt1.executeQuery("SELECT bus_name FROM lan:stpvendr WHERE vend_code = '" + iVendor + "'");
        if (rs.next())
          vendorName = doString.checkString(rs.getString("BUS_NAME")); 
        rs.close();
        rs = null;
      } 
      genInfPubHeaderPage(table, headerReport, currDate, vendorCut, iVendor, vendorName, markupPay, microssfont, microssfont_HD, microssfont_MINI, microssfont_BOLD);
      totalLine += 8;
      int line = 0;
      sql.delete(0, sql.length());
      sql.append("SELECT b.i_ven_cut, b.i_month, b.p_com, b.i_account, SUM(b.q_wage_unit * b.z_wage_price) AS SUM_WAGE, ")
        .append(" SUM(b.q_good_unit * b.z_good_price) AS SUM_GOODS, ")
        .append(" SUM((b.q_wage_unit * b.z_wage_price * p_add_pay)/100) AS SUM_WAGE_ADD_PAY, ")
        .append(" SUM((b.q_good_unit * b.z_good_price * p_add_pay)/100) AS SUM_PRICE_ADD_PAY, ")
        .append(" SUM(b.z_amount_pay) AS SUM_AMOUNT_PAY, SUM(b.z_amount_pv) AS SUM_AMOUNT_PV, ")
        .append(" SUM(b.z_com_amount) AS SUM_AMOUNT_COM, SUM(b.z_cus_amount) AS SUM_AMOUNT_CUS FROM lan:serv_infpayment b, lan:serv_infdochd a ")
        .append(" WHERE b.f_itmstatus = 'CLS' AND b.i_itmtype = '01' AND b.i_type = '02' ")
        .append(this.condition);
      sql.append(" AND b.i_docno = a.i_docno AND a.f_status IN ('OPN','CLS') GROUP BY b.i_ven_cut, b.i_month, b.p_com, b.i_account ")
        .append(" ORDER BY b.i_ven_cut, b.i_month, b.p_com, b.i_account");
      rs = stmt.executeQuery(sql.toString());
      if (rs != null) {
        while (rs.next()) {
          String vendorId = doString.checkString(rs.getString("I_VEN_CUT"));
          String mnthDate = doString.checkString(rs.getString("I_MONTH"));
          String mnth = mnthDate.substring(5, 7);
          String year = Integer.toString(Integer.parseInt(mnthDate.substring(0, 4)) + 543);
          double p_com = rs.getDouble("P_COM");
          com_ps = doString.displayNumber("###.00", p_com);
          acctId = doString.checkString(rs.getString("I_ACCOUNT"));
          double sumWage = rs.getDouble("SUM_WAGE");
          double sumGoods = rs.getDouble("SUM_GOODS");
          double amountPay = rs.getDouble("SUM_AMOUNT_PAY");
          double amountPV = rs.getDouble("SUM_AMOUNT_PV");
          double sumWageAddPay = rs.getDouble("SUM_WAGE_ADD_PAY");
          double sumPriceAddPay = rs.getDouble("SUM_PRICE_ADD_PAY");
          double amountLH = rs.getDouble("SUM_AMOUNT_COM");
          double amountCust = rs.getDouble("SUM_AMOUNT_CUS");
          totalWage += sumWage;
          totalGoods += sumGoods;
          totalPay += amountPay;
          totalPV += amountPV;
          totalLH += amountLH;
          totalCust += amountCust;
          grandTotalWage += sumWageAddPay;
          grandTotalPrice += sumPriceAddPay;
          int countDoc = 0;
          sql.delete(0, sql.length());
          sql.append("SELECT COUNT(*) FROM serv_infpayment b, lan:serv_infdochd a WHERE b.p_com = ")
            .append(com_ps)
            .append(" AND b.f_itmstatus = 'CLS'")
            .append(" AND b.i_ven_cut = '").append(vendorId).append("' ")
            .append(" AND b.i_month = '").append(mnthDate).append("' ")
            .append(" AND b.i_itmtype = '01' AND b.i_type = '02' AND b.i_account = '").append(acctId).append("' ")
            .append(this.condition)
            .append(" AND b.i_docno = a.i_docno AND a.f_status IN ('OPN','CLS') GROUP BY b.i_docno ");
          rs1 = stmt1.executeQuery(sql.toString());
          while (rs1.next())
            countDoc++; 
          rs1.close();
          rs1 = null;
          String vendName = "";
          if (vendorId.equals("999999")) {
            vendName = companyName;
          } else {
            sql.delete(0, sql.length());
            sql.append("SELECT bus_name FROM lan:stpvendr WHERE vend_code = '").append(vendorId).append("'");
            rs1 = stmt1.executeQuery(sql.toString());
            if (rs1.next())
              vendName = doString.checkString(rs1.getString("bus_name"), ""); 
            rs1.close();
          } 
          num++;
          PdfPCell pdfPCell = new PdfPCell(new Phrase(Integer.toString(num), microssfont));
          pdfPCell.setHorizontalAlignment(1);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.noLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          pdfPCell = new PdfPCell(new Phrase(doString.MS874ToUnicode(vendorId + " - " + vendName), microssfont));
          pdfPCell.setHorizontalAlignment(0);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.vendorLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          pdfPCell = new PdfPCell(new Phrase(mnth + "/" + year, microssfont));
          pdfPCell.setHorizontalAlignment(1);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.mnthLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          pdfPCell = new PdfPCell(new Phrase(acctId, microssfont));
          pdfPCell.setHorizontalAlignment(1);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.acctLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          pdfPCell = new PdfPCell(new Phrase(Integer.toString(countDoc), microssfont));
          pdfPCell.setHorizontalAlignment(1);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.countDocLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          pdfPCell = new PdfPCell(new Phrase(displayFormat(sumWage), microssfont));
          pdfPCell.setHorizontalAlignment(2);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.wageLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          pdfPCell = new PdfPCell(new Phrase(displayFormat(sumGoods), microssfont));
          pdfPCell.setHorizontalAlignment(2);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.goodsLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          pdfPCell = new PdfPCell(new Phrase(displayFormat(amountPay), microssfont));
          pdfPCell.setHorizontalAlignment(2);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.payLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          pdfPCell = new PdfPCell(new Phrase(displayFormat(amountPV), microssfont));
          pdfPCell.setHorizontalAlignment(2);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.pvLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          pdfPCell = new PdfPCell(new Phrase(displayFormat(p_com), microssfont));
          pdfPCell.setHorizontalAlignment(2);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.pcLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          pdfPCell = new PdfPCell(new Phrase(displayFormat(amountLH), microssfont));
          pdfPCell.setHorizontalAlignment(2);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.comLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          if (amountLH > 0 && amountCust > 0) {
            pdfPCell = new PdfPCell(new Phrase(" ", microssfont));
          } else {
            pdfPCell = new PdfPCell(new Phrase(displayFormat(amountCust), microssfont));
          } 
          pdfPCell.setHorizontalAlignment(2);
          pdfPCell.setVerticalAlignment(5);
          pdfPCell.setBorderColor(this.borderColor);
          pdfPCell.setFixedHeight(21);
          pdfPCell.setPaddingTop(3);
          pdfPCell.setPaddingBottom(5);
          pdfPCell.setColspan(this.cusLength);
          pdfPCell.setBorder(15);
          table.addCell(pdfPCell);
          line++;
          totalLine++;
          if (totalLine >= 25) {
            Rectangle page = document.getPageSize();
            PdfPTable foot = new PdfPTable(1);
            PdfPCell pcell = new PdfPCell(new Phrase(" มีหน้าต่อไป      ", microssfont));
            pcell.setHorizontalAlignment(2);
            pcell.setVerticalAlignment(4);
            pcell.setBorder(0);
            foot.addCell(pcell);
            foot.setTotalWidth(page.width() - document.leftMargin() - document.rightMargin());
            foot.writeSelectedRows(0, 1, document.leftMargin(), document.bottomMargin() + 20, writer.getDirectContent());
            document.add((Element)table);
            document.newPage();
            table = new PdfPTable(100);
            table.setWidthPercentage(100);
            totalLine = 0;
            genPubHeaderPage(table, headerReport, currDate, vendorCut, iVendor, vendorName, markupPay, microssfont, microssfont_HD, microssfont_MINI, microssfont_BOLD);
            totalLine += 8;
          } 
          if (amountLH > 0 && amountCust > 0) {
            sql.delete(0, sql.length());
            sql.append("SELECT b.i_acct_cus, SUM(b.z_cus_amount) AS SUM_AMOUNT_CUS FROM serv_infpayment b, lan:serv_infdochd a WHERE b.p_com = ")
              .append(com_ps)
              .append(" AND b.f_itmstatus = 'CLS'")
              .append(" AND b.i_ven_cut = '").append(vendorId).append("' ")
              .append(" AND b.i_month = '").append(mnthDate).append("' ")
              .append(" AND b.i_itmtype = '01' AND b.i_type = '02' ")
              .append(this.condition)
              .append(" AND b.i_docno = a.i_docno AND a.f_status IN ('OPN','CLS') GROUP BY b.i_acct_cus");
            rs1 = stmt1.executeQuery(sql.toString());
            if (rs1 != null) {
              while (rs1.next()) {
                acctId = doString.checkString(rs1.getString("I_ACCT_CUS"));
                amountCust = rs1.getDouble("SUM_AMOUNT_CUS");
                pdfPCell = new PdfPCell(new Phrase(Integer.toString(num), microssfont));
                pdfPCell.setHorizontalAlignment(1);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.noLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(doString.MS874ToUnicode(vendorId + " - " + vendName), microssfont));
                pdfPCell.setHorizontalAlignment(0);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.vendorLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(mnth + "/" + year, microssfont));
                pdfPCell.setHorizontalAlignment(1);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.mnthLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(acctId, microssfont));
                pdfPCell.setHorizontalAlignment(1);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.acctLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(Integer.toString(countDoc), microssfont));
                pdfPCell.setHorizontalAlignment(1);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.countDocLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(" ", microssfont));
                pdfPCell.setHorizontalAlignment(2);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.wageLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(" ", microssfont));
                pdfPCell.setHorizontalAlignment(2);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.goodsLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(" ", microssfont));
                pdfPCell.setHorizontalAlignment(2);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.payLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(" ", microssfont));
                pdfPCell.setHorizontalAlignment(2);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.pvLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(" ", microssfont));
                pdfPCell.setHorizontalAlignment(2);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.pcLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(" ", microssfont));
                pdfPCell.setHorizontalAlignment(2);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.comLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                pdfPCell = new PdfPCell(new Phrase(displayFormat(amountCust), microssfont));
                pdfPCell.setHorizontalAlignment(2);
                pdfPCell.setVerticalAlignment(5);
                pdfPCell.setBorderColor(this.borderColor);
                pdfPCell.setFixedHeight(21);
                pdfPCell.setPaddingTop(3);
                pdfPCell.setPaddingBottom(5);
                pdfPCell.setColspan(this.cusLength);
                pdfPCell.setBorder(15);
                table.addCell(pdfPCell);
                line++;
                totalLine++;
                if (totalLine >= 25) {
                  Rectangle page = document.getPageSize();
                  PdfPTable foot = new PdfPTable(1);
                  PdfPCell pcell = new PdfPCell(new Phrase(" มีหน้าต่อไป      ", microssfont));
                  pcell.setHorizontalAlignment(2);
                  pcell.setVerticalAlignment(4);
                  pcell.setBorder(0);
                  foot.addCell(pcell);
                  foot.setTotalWidth(page.width() - document.leftMargin() - document.rightMargin());
                  foot.writeSelectedRows(0, 1, document.leftMargin(), document.bottomMargin() + 20, writer.getDirectContent());
                  document.add((Element)table);
                  document.newPage();
                  table = new PdfPTable(100);
                  table.setWidthPercentage(100);
                  totalLine = 0;
                  genPubHeaderPage(table, headerReport, currDate, vendorCut, iVendor, vendorName, markupPay, microssfont, microssfont_HD, microssfont_MINI, microssfont_BOLD);
                  totalLine += 8;
                } 
              } 
              rs1.close();
              rs1 = null;
            } 
          } 
        } 
        rs.close();
        rs = null;
      } 
      PdfPCell cell = new PdfPCell(new Phrase("รวมเป็นเงิน", microssfont));
      cell.setHorizontalAlignment(1);
      cell.setVerticalAlignment(4);
      cell.setBorderColor(this.borderColor);
      cell.setPaddingBottom(5);
      cell.setColspan(this.noLength + this.vendorLength + this.mnthLength + this.acctLength + this.countDocLength);
      cell.setBorder(0);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalWage), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.wageLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalGoods), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.goodsLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalPay), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.payLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalPV), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.pvLength);
      cell.setBorder(15);
      cell.setBackgroundColor(new Color(this.LIGHT_GRAY_COLOR));
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(" ", microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.pcLength);
      cell.setBorder(15);
      cell.setBackgroundColor(new Color(this.LIGHT_GRAY_COLOR));
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalLH), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.comLength);
      cell.setBorder(15);
      cell.setBackgroundColor(new Color(this.LIGHT_GRAY_COLOR));
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalCust), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.cusLength);
      cell.setBorder(15);
      cell.setBackgroundColor(new Color(this.LIGHT_GRAY_COLOR));
      table.addCell(cell);
      cell = new PdfPCell(new Phrase("รวมค่าดำเนินการ " + markupPay, microssfont));
      cell.setHorizontalAlignment(1);
      cell.setVerticalAlignment(4);
      cell.setBorderColor(this.borderColor);
      cell.setPaddingBottom(5);
      cell.setColspan(this.noLength + this.vendorLength + this.mnthLength + this.acctLength + this.countDocLength);
      cell.setBorder(0);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalWage + grandTotalWage), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.wageLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalGoods + grandTotalPrice), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.goodsLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(displayFormat(totalPV), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.payLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase("", microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(4);
      cell.setPaddingBottom(5);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.pvLength + this.totalCutVLength);
      cell.setBorder(15);
      table.addCell(cell);
      document.add((Element)table);
      document.newPage();
    } catch (Exception e) {
    
    } finally {
      if (rs != null)
        rs.close(); 
      if (rs1 != null)
        rs1.close(); 
      if (stmt != null)
        stmt.close(); 
      if (stmt1 != null)
        stmt1.close(); 
    } 
  }
  
  public void performTask(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
    String mName = new String(getClass().getName() + ".performTask: ");
    System.out.println(mName + "start.");
    doString str = new doString();
    StringBuffer sql = new StringBuffer();
    Connection conn = null;
    Statement stmt = null;
    Statement stmt1 = null;
    ResultSet rs = null;
    ResultSet rs1 = null;
    SERV_CommonData common = null;
    this.nowpage = 0;
    try {
      if (ds == null)
        getDS(); 
      conn = ds.getConnection();
      conn.setTransactionIsolation(1);
      conn.setAutoCommit(true);
      stmt = conn.createStatement();
      stmt1 = conn.createStatement();
      common = new SERV_CommonData(conn);
      String currDate = "";
      Calendar now = Calendar.getInstance(Locale.ENGLISH);
      currDate = str.createID(now.get(5), 2) + "/" + str.createID(now.get(2) + 1, 2);
      int nYear = now.get(1);
      if (nYear < 2500)
        nYear += 543; 
      currDate = currDate + "/" + str.createID(nYear, 4);
      currDate = currDate + " , " + str.createID(now.get(11), 2) + ":" + str.createID(now.get(12), 2);
      this.selProj = doString.checkString(req.getParameter("sel_project"), "").toUpperCase();
      String itmType = doString.checkString(req.getParameter("itmtype"), "");
      this.iVendor = doString.checkString(req.getParameter("i_vendor"), "");
      this.startDate = common.getValueFromDateListbox("start", req);
      this.endDate = common.getValueFromDateListbox("end", req);
      this.condition = "";
      if (this.iVendor.trim().length() > 0)
        this.condition = this.condition + " AND b.i_vendor = '" + this.iVendor + "' "; 
      if (this.startDate.length() > 0 && this.endDate.length() > 0)
        this.condition = this.condition + " AND b.d_payment BETWEEN '" + this.startDate + "' AND '" + this.endDate + "' "; 
      this.condition = this.condition + " AND a.i_company = '" + ((this.selProj.length() > 0) ? this.selProj.substring(0, 2) : "") + "' AND a.i_project = '" + ((this.selProj.length() > 0) ? this.selProj.substring(3, 6) : "") + "' ";
      Vector vendorCut = new Vector();
      rs = stmt.executeQuery("SELECT p_amount FROM lan:serv_xstd WHERE i_type = '09'");
      while (rs.next()) {
        double percent = rs.getDouble("P_AMOUNT");
        vendorCut.addElement(new Double(percent));
      } 
      rs.close();
      rs = null;
      BaseFont bf = BaseFont.createFont(Constants.FONT_ANGSANA_NORMAL, "Identity-H", false);
      BaseFont bfb = BaseFont.createFont(Constants.FONT_ANGSANA_BOLD, "Identity-H", false);
      Font microssfont = new Font(bf, 12, 0);
      Font microssfont_MINI = new Font(bf, 10, 0);
      Font microssfont_BOLD = new Font(bfb, 12, 0);
      Font microssfont_HD = new Font(bfb, 18, 0);
      Document document = new Document(PageSize.A4.rotate(), 30, 30, 10, 10);
      ByteArrayOutputStream baos = new ByteArrayOutputStream();
      PdfWriter writer = PdfWriter.getInstance(document, baos);
      document.open();
      PdfPTable table = new PdfPTable(100);
      table.setWidthPercentage(100);
      String headerReport = "";
      this.companyName = "";
      this.betweenDate = "";
      if (this.selProj.trim().length() > 2) {
        String projectName = "";
        rs = stmt.executeQuery("SELECT n_company FROM lan:acxcompa WHERE i_company = '" + this.selProj.substring(0, 2) + "'");
        if (rs.next())
          this.companyName = doString.checkString(rs.getString("n_company")); 
        rs.close();
        rs = null;
        sql.delete(0, sql.length());
        sql.append(" select * from lan:acxprojt a  where  ")
          .append(" a.i_company='" + ((this.selProj.length() > 0) ? this.selProj.substring(0, 2) : "") + "' ")
          .append(" and a.i_project='" + ((this.selProj.length() > 0) ? this.selProj.substring(3, 6) : "") + "'  ");
        rs = stmt.executeQuery(sql.toString());
        if (rs.next())
          projectName = doString.checkString(rs.getString("n_project"), ""); 
        rs.close();
        if (projectName.length() > 0)
          headerReport = headerReport + " โครงการ : " + this.selProj + " - " + projectName + "\n"; 
        if (this.startDate.length() > 0 && this.endDate.length() > 0) {
          int syear = Integer.parseInt(this.startDate.substring(0, 4));
          int eyear = Integer.parseInt(this.endDate.substring(0, 4));
          if (syear < 2400)
            syear += 543; 
          if (eyear < 2400)
            eyear += 543; 
          this.startDate = this.startDate.substring(8, 10) + "/" + this.startDate.substring(5, 7) + "/" + Integer.toString(syear);
          this.endDate = this.endDate.substring(8, 10) + "/" + this.endDate.substring(5, 7) + "/" + Integer.toString(eyear);
          this.betweenDate = " วันอนุมัติจ่าย ตั้งแต่ " + this.startDate + "  ถึง " + this.endDate + "\n";
        } 
      } 
      String markupPay = "";
      if (this.selProj.trim().length() > 0 && this.iVendor.trim().length() > 0) {
        sql.delete(0, sql.length());
        sql.append(" select * from lan:serv_venprj where ")
          .append(" i_company='").append((this.selProj.length() >= 6) ? this.selProj.substring(0, 2) : "").append("' ")
          .append(" and i_project='").append((this.selProj.length() >= 6) ? this.selProj.substring(3, 6) : "").append("' ")
          .append(" and i_vendor='").append(this.iVendor).append("' ");
        rs = stmt.executeQuery(sql.toString());
        if (rs.next()) {
          double pAddPay = 0;
          if (itmType.equals("01")) {
            pAddPay = rs.getDouble("p_inf_pay");
          } else if (itmType.equals("02")) {
            pAddPay = rs.getDouble("p_pub_pay");
          } else {
            pAddPay = rs.getDouble("p_add_pay");
          } 
          markupPay = doString.displayNumber("##0.0", pAddPay) + " %";
        } 
        rs.close();
      } 
      if (itmType.equals("01"))
        genVendorData(document, writer, conn, this.iVendor, this.companyName, headerReport, vendorCut, markupPay, microssfont, microssfont_HD, microssfont_MINI, microssfont_BOLD); 
      if (itmType.equals("02"))
        genPubVendorData(document, writer, conn, this.iVendor, this.companyName, headerReport, vendorCut, markupPay, microssfont, microssfont_HD, microssfont_MINI, microssfont_BOLD); 
      headerReport = "";
      document.close();
      res.setContentType("application/pdf");
      res.setContentLength(baos.size());
      ServletOutputStream outServ = res.getOutputStream();
      baos.writeTo((OutputStream)outServ);
      outServ.flush();
      
      stmt.close();
      stmt1.close();
      conn.close();
      stmt = null;
      stmt1 = null;
      conn = null;
    } catch (DocumentException de) {
    } catch (Exception e) {
      System.out.println(" ERROR " + mName + " : " + e.getMessage());
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