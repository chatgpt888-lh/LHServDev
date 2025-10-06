package serv.servlets;

import com.lh.servlet.DBServlet;
import com.lh.util.doString;
import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.PageSize;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
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
import java.util.Locale;
import java.util.Vector;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import serv.common.Constants;
import serv.common.SERV_CommonData;

public class SERV_INFPrintReport8Servlet extends DBServlet {
  private String selProj = "";
  
  private String iVendor = "";
  
  private String startDate = "";
  
  private String endDate = "";
  
  private String condition = "";
  
  private String orderBy = "";
  
  private int rowPerPage = 30;
  
  private String companyName = "";
  
  private String projectName = "";
  
  private String cutVendorId = "";
  
  private int nowPage = 0;
  
  private int LIGHT_GRAY_COLOR = 15329769;
  
  private Color borderColor = new Color(153, 153, 153);
  
  int noLength = 0;
  
  int mnthLength = 0;
  
  int docNoLength = 0;
  
  int sortLength = 0;
  
  int lockLength = 0;
  
  int vendorLength = 0;
  
  int acctLength = 0;
  
  int wageLength = 0;
  
  int goodsLength = 0;
  
  int payLength = 0;
  
  int pvLength = 0;
  
  int cutR8Length = 0;
  
  int cutCLength = 0;
  
  int cutTLength = 0;
  
  int pcLength = 0;
  
  int comLength = 0;
  
  int cusLength = 0;
  
  int totalCutVLength = 0;
  
  int vPerCol = 0;
  
  int overflowLength = 0;
  
  public Double[] newDoubleArray(int size) {
    Double[] result = new Double[size];
    for (int i = 0; i < size; i++)
      result[i] = new Double(0); 
    return result;
  }
  
  public void printHeaderPage(PdfPTable table, String currDate, String iVendor, String vendorName, Vector<Double> vendorCut, String markupPay, Font microssfont, Font microssfont_HD, Font microssfont_MINI, Font microssfont_BOLD) {
    this.nowPage++;
    String headerReport = "";
    DecimalFormat format = new DecimalFormat("###,##0.00");
    if (this.projectName.length() > 0)
      headerReport = headerReport + " โครงการ : " + this.projectName + "\n"; 
    String betweenDate = "";
    if (this.startDate.length() > 0 && this.endDate.length() > 0) {
      int syear = Integer.parseInt(this.startDate.substring(0, 4));
      int eyear = Integer.parseInt(this.endDate.substring(0, 4));
      if (syear < 2400)
        syear += 543; 
      if (eyear < 2400)
        eyear += 543; 
      String cStartDate = this.startDate.substring(8, 10) + "/" + this.startDate.substring(5, 7) + "/" + Integer.toString(syear);
      String cEndDate = this.endDate.substring(8, 10) + "/" + this.endDate.substring(5, 7) + "/" + Integer.toString(eyear);
      betweenDate = "วันที่จ่ายตั้งแต่วันที่ " + cStartDate + "  ถึง " + cEndDate + "\n";
    } 
    PdfPCell cell = new PdfPCell(new Phrase("หน้า " + this.nowPage, microssfont));
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
    cell = new PdfPCell(new Phrase("รายละเอียดการส่งงานซ่อมสาธารณูฯ(ส่วนกลาง) ของผู้รับเหมา (สรุปตามใบแจ้งซ่อม)", microssfont_HD));
    cell.setHorizontalAlignment(1);
    cell.setColspan(100);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(betweenDate, microssfont_HD));
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
    cell = new PdfPCell(new Phrase("แบบรายงาน : SERV_INFPrintReport8 ,  " + currDate, microssfont));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(6);
    cell.setColspan(50);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(" ", microssfont_MINI));
    cell.setHorizontalAlignment(0);
    cell.setVerticalAlignment(4);
    cell.setColspan(100);
    cell.setBorder(2);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(iVendor + " - " + vendorName), microssfont_HD));
    cell.setHorizontalAlignment(0);
    cell.setVerticalAlignment(4);
    cell.setColspan(100);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("เลขที่ใบสั่งซ่อม", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.docNoLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ผู้รับเหมาตัดเงิน", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.sortLength + this.vendorLength + this.cutR8Length);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("รหัสบัญชี", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.acctLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ค่าแรง", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.wageLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ค่าของ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.goodsLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ค่าของ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.payLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("รวมค่าดำเนินการ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.pvLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ตัดเงินผู้รับเหมา", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.totalCutVLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ตัดเงินบริษัท ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.cutCLength);
    cell.setBorder(15);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.docNoLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.sortLength + this.vendorLength + this.cutR8Length);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.acctLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.wageLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.goodsLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("+ค่าแรง", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setVerticalAlignment(5);
    cell.setColspan(this.payLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(markupPay, microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(5);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.pvLength);
    cell.setBorder(14);
    table.addCell(cell);
    for (int i = 0; i < vendorCut.size(); i++) {
      Double val = vendorCut.elementAt(i);
      cell = new PdfPCell(new Phrase(format.format(val.doubleValue()) + " %", microssfont_BOLD));
      cell.setHorizontalAlignment(1);
      cell.setVerticalAlignment(5);
      cell.setPaddingTop(4);
      cell.setPaddingLeft(4);
      cell.setPaddingBottom(6);
      cell.setBorderColor(this.borderColor);
      cell.setColspan(this.vPerCol + ((i == vendorCut.size() - 1) ? this.overflowLength : 0));
      cell.setBorder(15);
      table.addCell(cell);
    } 
    cell = new PdfPCell(new Phrase((this.selProj.length() > 2) ? this.selProj.substring(0, 2) : "", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(5);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.cutCLength);
    cell.setBorder(15);
    table.addCell(cell);
  }
  
  public void printPubHeaderPage(PdfPTable table, String currDate, String iVendor, String vendorName, Vector vendorCut, String markupPay, Font microssfont, Font microssfont_HD, Font microssfont_MINI, Font microssfont_BOLD) {
    this.nowPage++;
    String headerReport = "";
    DecimalFormat format = new DecimalFormat("###,##0.00");
    if (this.projectName.length() > 0)
      headerReport = headerReport + " โครงการ : " + this.projectName + "\n"; 
    String betweenDate = "";
    if (this.startDate.length() > 0 && this.endDate.length() > 0) {
      int syear = Integer.parseInt(this.startDate.substring(0, 4));
      int eyear = Integer.parseInt(this.endDate.substring(0, 4));
      if (syear < 2400)
        syear += 543; 
      if (eyear < 2400)
        eyear += 543; 
      String cStartDate = this.startDate.substring(8, 10) + "/" + this.startDate.substring(5, 7) + "/" + Integer.toString(syear);
      String cEndDate = this.endDate.substring(8, 10) + "/" + this.endDate.substring(5, 7) + "/" + Integer.toString(eyear);
      betweenDate = "วันที่จ่ายตั้งแต่วันที่ " + cStartDate + "  ถึง " + cEndDate + "\n";
    } 
    PdfPCell cell = new PdfPCell(new Phrase("หน้า " + this.nowPage, microssfont));
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
    cell = new PdfPCell(new Phrase("รายละเอียดการส่งงานซ่อมสาธารณะ ของผู้รับเหมา (สรุปตามใบแจ้งซ่อม)", microssfont_HD));
    cell.setHorizontalAlignment(1);
    cell.setColspan(100);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(betweenDate, microssfont_HD));
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
    cell = new PdfPCell(new Phrase("แบบรายงาน : SERV_INFPrintReport8 ,  " + currDate, microssfont));
    cell.setHorizontalAlignment(2);
    cell.setVerticalAlignment(6);
    cell.setColspan(50);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(" ", microssfont_MINI));
    cell.setHorizontalAlignment(0);
    cell.setVerticalAlignment(4);
    cell.setColspan(100);
    cell.setBorder(2);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(iVendor + " - " + vendorName), microssfont_HD));
    cell.setHorizontalAlignment(0);
    cell.setVerticalAlignment(4);
    cell.setColspan(100);
    cell.setBorder(0);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("No.", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.noLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ประจำ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.mnthLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("เลขที่ใบสั่งซ่อม", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.docNoLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ผู้รับเหมาตัดเงิน", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.vendorLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("รหัส", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.acctLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ค่าแรง", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.wageLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ค่าของ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.goodsLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ค่าของ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.payLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("รวมค่าดำเนินการ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(6);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.pvLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("คชจ.ของ", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.totalCutVLength);
    cell.setBorder(13);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.noLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("เดือน", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.mnthLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.docNoLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.vendorLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("บัญชี", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.acctLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.wageLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(4);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.goodsLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("+ค่าแรง", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setVerticalAlignment(5);
    cell.setColspan(this.payLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase(markupPay, microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(5);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.pvLength);
    cell.setBorder(14);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("%บริษัท", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(5);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.pcLength);
    cell.setBorder(15);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("บริษัท", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(5);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.comLength);
    cell.setBorder(15);
    table.addCell(cell);
    cell = new PdfPCell(new Phrase("ลูกบ้าน", microssfont_BOLD));
    cell.setHorizontalAlignment(1);
    cell.setVerticalAlignment(5);
    cell.setPaddingTop(4);
    cell.setPaddingLeft(4);
    cell.setPaddingBottom(6);
    cell.setBorderColor(this.borderColor);
    cell.setColspan(this.cusLength);
    cell.setBorder(15);
    table.addCell(cell);
  }
  
  public void genVendorData(Document document, PdfWriter writer, Connection conn, String iVendor, String companyName, Vector<Double> vendorCut, String markupPay, Font microssfont, Font microssfont_HD, Font microssfont_MINI, Font microssfont_BOLD) throws Exception {
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
    DecimalFormat format = new DecimalFormat("###,##0.00");
    PdfPCell cell = null;
    double totalWage = 0;
    double totalGoods = 0;
    double totalPay = 0;
    double totalPV = 0;
    double totalCutCompany = 0;
    int totalLine = 0;
    
    this.acctLength = 10;
    this.docNoLength = 8;
    this.sortLength = 4;
    this.lockLength = 5;
    this.vendorLength = 15;
    this.wageLength = 6;
    this.goodsLength = 6;
    this.payLength = 7;
    this.pvLength = 8;
    this.cutR8Length = 7;
    this.cutCLength = 7;
    this.totalCutVLength = 100 - (this.acctLength + this.docNoLength + this.sortLength + this.vendorLength + this.wageLength + this.goodsLength + this.payLength + this.pvLength + this.cutR8Length + this.cutCLength);
    Double[] sumCutVendor = newDoubleArray(vendorCut.size());
    int tmpLength = this.totalCutVLength;
    this.vPerCol = 0;
    this.overflowLength = 0;
    if (vendorCut.size() > 0) {
      this.vPerCol = (tmpLength - tmpLength % vendorCut.size()) / vendorCut.size();
      this.overflowLength = tmpLength % vendorCut.size();
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
      printHeaderPage(table, currDate, iVendor, vendorName, vendorCut, markupPay, microssfont, microssfont_HD, microssfont_MINI, microssfont_BOLD);
      
      totalLine += 13;
      String oldCut = "";
      int line = 0;
      sql.delete(0, sql.length());
      sql.append(" select b.i_docno,b.i_ven_cut, b.i_account, sum(round(q_wage_unit * z_wage_price,2)) sum_wage, ")
        .append(" sum(round(q_good_unit * z_good_price,2)) sum_goods, ")
        .append(" sum(z_amount_pay) sum_amount_pay, sum(z_amount_pv) sum_amount_pv, ")
        .append(" sum(z_amount_cut) sum_amount_cut from lan:serv_infdochd a,lan:serv_infpayment b ")
        .append(" where b.i_docno=a.i_docno and a.f_status in ('OPN','CLS') and b.f_itmstatus='CLS' and b.i_itmtype = '01' ")
        .append(this.condition);
      if (iVendor.length() > 0)
        sql.append(" and b.i_vendor='").append(iVendor).append("' "); 
      if (this.cutVendorId.length() > 0)
        sql.append(" and b.i_ven_cut='").append(this.cutVendorId).append("' "); 
      sql.append(" group by b.i_docno,b.i_ven_cut, b.i_account ")
        .append(" order by ").append(this.orderBy).append(",b.i_ven_cut, b.i_account ");
      rs = stmt.executeQuery(sql.toString());
      while (rs.next() == true) {
        String iDocNo = doString.checkString(rs.getString("i_docno"), "");
        String vendorId = doString.checkString(rs.getString("i_ven_cut"), "");
        String accountId = doString.checkString(rs.getString("i_account"), "");
        double sumWage = rs.getDouble("sum_wage");
        double sumGoods = rs.getDouble("sum_goods");
        double amountPay = rs.getDouble("sum_amount_pay");
        double amountPV = rs.getDouble("sum_amount_pv");
        double cutVend = 0;
        double cutComp = 0;
        Double[] cutVendor = newDoubleArray(vendorCut.size());
        sumWage = Double.parseDouble(doString.displayNumber("#######0.00", sumWage));
        sumGoods = Double.parseDouble(doString.displayNumber("#######0.00", sumGoods));
        amountPay = Double.parseDouble(doString.displayNumber("#######0.00", amountPay));
        amountPV = Double.parseDouble(doString.displayNumber("#######0.00", amountPV));
        totalWage += sumWage;
        totalGoods += sumGoods;
        totalPay += amountPay;
        totalPV += amountPV;
        String vendName = "";
        if (vendorId.equals("999999")) {
          vendName = companyName;
        } else {
          sql.delete(0, sql.length());
          sql.append("select bus_name from lan:stpvendr where vend_code='").append(vendorId).append("' ");
          rs1 = stmt1.executeQuery(sql.toString());
          if (rs1.next())
            vendName = doString.checkString(rs1.getString("bus_name"), ""); 
          rs1.close();
        } 
        if (vendName.length() > 37)
          vendName = vendName.substring(0, 37) + ".."; 
        if (vendName.equalsIgnoreCase(oldCut)) {
        	vendName = "      \"       ";
        } else {
          oldCut = vendName;
        } 
        sql.delete(0, sql.length());
        sql.append(" select b.p_cut,sum(z_cut_pv) as sum_cut_pv ")
          .append(" from lan:serv_infdochd a,lan:serv_infpayment b ")
          .append(" where b.i_docno=a.i_docno and  a.f_status in ('OPN','CLS') ")
          .append(" and b.f_itmstatus='CLS' and b.i_itmtype = '01' and b.i_ven_cut = '")
          .append(vendorId).append("' ")
          .append(" and b.i_account = '").append(accountId).append("' ")
          .append(" and b.i_docno='").append(iDocNo).append("' ");
        if (this.startDate.length() > 0 && this.endDate.length() > 0)
          sql.append(" and b.d_payment between '" + this.startDate + "' and '" + this.endDate + "' "); 
        if (iVendor.length() > 0)
          sql.append(" and b.i_vendor='").append(iVendor).append("' "); 
        sql.append(" group by b.p_cut ");
        rs1 = stmt1.executeQuery(sql.toString());
        while (rs1.next() == true) {
          double pCut = rs1.getDouble("p_cut");
          double cutValue = rs1.getDouble("sum_cut_pv");
          if (pCut == 0 && vendorId.equals("999999")) {
            cutComp += cutValue;
            totalCutCompany += cutValue;
            continue;
          }
          cutVend += cutValue;
          for (int j = 0; j < vendorCut.size(); j++) {
            Double cut = vendorCut.elementAt(j);
            if (cut.doubleValue() == pCut) {
              cutVendor[j] = new Double(cutVendor[j].doubleValue() + cutValue);
              sumCutVendor[j] = new Double(sumCutVendor[j].doubleValue() + cutValue);
              break;
            } 
          }//end for 
        }//end while
        rs1.close();
        rs1=null;
        if (cutVend != 0) {
            if (cutVend == amountPV) {
            	accountId = "11411";
            } else {
            	accountId = accountId+",11411";
            }
        }
        cell = new PdfPCell(new Phrase(iDocNo, microssfont));
        cell.setHorizontalAlignment(1);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.docNoLength);
        cell.setBorder(15);
        table.addCell(cell);
        cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(vendName), microssfont));
        cell.setHorizontalAlignment(0);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.sortLength + this.vendorLength + this.cutR8Length);
        cell.setBorder(15);
        table.addCell(cell);
        
        cell = new PdfPCell(new Phrase(accountId, microssfont));
        cell.setHorizontalAlignment(1);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.acctLength);
        cell.setBorder(15);
        table.addCell(cell);
        
        cell = new PdfPCell(new Phrase(format.format(sumWage), microssfont));
        cell.setHorizontalAlignment(2);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.wageLength);
        cell.setBorder(15);
        table.addCell(cell);
        cell = new PdfPCell(new Phrase(format.format(sumGoods), microssfont));
        cell.setHorizontalAlignment(2);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.goodsLength);
        cell.setBorder(15);
        table.addCell(cell);
        cell = new PdfPCell(new Phrase(format.format(amountPay), microssfont));
        cell.setHorizontalAlignment(2);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.payLength);
        cell.setBorder(15);
        table.addCell(cell);
        cell = new PdfPCell(new Phrase(format.format(amountPV), microssfont));
        cell.setHorizontalAlignment(2);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.pvLength);
        cell.setBorder(15);
        table.addCell(cell);
        for (int i = 0; i < vendorCut.size(); i++) {
          cell = new PdfPCell(new Phrase(format.format(cutVendor[i].doubleValue()), microssfont));
          cell.setHorizontalAlignment(2);
          cell.setVerticalAlignment(5);
          cell.setBorderColor(this.borderColor);
          cell.setFixedHeight(21);
          cell.setPaddingTop(3);
          cell.setPaddingBottom(5);
          cell.setColspan(this.vPerCol + ((i == vendorCut.size() - 1) ? this.overflowLength : 0));
          cell.setBorder(15);
          table.addCell(cell);
        } 
        cell = new PdfPCell(new Phrase(format.format(cutComp), microssfont));
        cell.setHorizontalAlignment(2);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.cutCLength);
        cell.setBorder(15);
        table.addCell(cell);
        line++;
        totalLine++;
        if (totalLine >= this.rowPerPage) {
          cell = new PdfPCell(new Phrase(" ", microssfont));
          cell.setHorizontalAlignment(0);
          cell.setVerticalAlignment(4);
          cell.setColspan(100);
          cell.setBorder(0);
          table.addCell(cell);
          Rectangle page = document.getPageSize();
          PdfPTable foot = new PdfPTable(1);
          PdfPCell pcell = new PdfPCell(new Phrase(" มีหน้าต่อไป      ", microssfont));
          pcell.setHorizontalAlignment(2);
          pcell.setVerticalAlignment(4);
          pcell.setBorder(0);
          foot.addCell(pcell);
          foot.setTotalWidth(page.width() - document.leftMargin() - document.rightMargin());
          foot.writeSelectedRows(0, 1, document.leftMargin(), document.bottomMargin() + 20, writer.getDirectContent());
          document.add(table);
          document.newPage();
          table = new PdfPTable(100);
          table.setWidthPercentage(100);
          totalLine = 0;
          printHeaderPage(table, currDate, iVendor, vendorName, vendorCut, markupPay, microssfont, microssfont_HD, microssfont_MINI, microssfont_BOLD);
          totalLine += 13;
        } 
      } 
      cell = new PdfPCell(new Phrase("รวมเป็นเงิน", microssfont));
      cell.setHorizontalAlignment(1);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(this.acctLength + this.docNoLength + this.sortLength + this.vendorLength + this.cutR8Length);
      cell.setBorder(0);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(format.format(totalWage), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(this.wageLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(format.format(totalGoods), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(this.goodsLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(format.format(totalPay), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(this.payLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(format.format(totalPV), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(this.pvLength);
      cell.setBorder(15);
      cell.setBackgroundColor(new Color(this.LIGHT_GRAY_COLOR));
      table.addCell(cell);
      for (int c = 0; c < vendorCut.size(); c++) {
        cell = new PdfPCell(new Phrase(format.format(sumCutVendor[c].doubleValue()), microssfont));
        cell.setHorizontalAlignment(2);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.vPerCol + ((c == vendorCut.size() - 1) ? this.overflowLength : 0));
        cell.setBorder(15);
        cell.setBackgroundColor(new Color(this.LIGHT_GRAY_COLOR));
        table.addCell(cell);
      } 
      cell = new PdfPCell(new Phrase(format.format(totalCutCompany), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(this.cutCLength);
      cell.setBorder(15);
      cell.setBackgroundColor(new Color(this.LIGHT_GRAY_COLOR));
      table.addCell(cell);
      document.add(table);
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
  
  public void genPubVendorData(Document document, PdfWriter writer, Connection conn, String iVendor, String companyName, Vector vendorCut, String markupPay, Font microssfont, Font microssfont_HD, Font microssfont_MINI, Font microssfont_BOLD) throws Exception {
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
    DecimalFormat format = new DecimalFormat("###,##0.00");
    PdfPCell cell = null;
    String com_ps = "";
    double totalWage = 0;
    double totalGoods = 0;
    double totalPay = 0;
    double totalPV = 0;
    double totalLH = 0;
    double totalCust = 0;
    int totalLine = 0;
    this.noLength = 3;
    this.mnthLength = 6;
    this.docNoLength = 8;
    this.vendorLength = 24;
    this.acctLength = 8;
    this.wageLength = 6;
    this.goodsLength = 6;
    this.payLength = 7;
    this.pvLength = 8;
    this.pcLength = 6;
    this.comLength = 9;
    this.cusLength = 9;
    this.totalCutVLength = 100 - (this.noLength + this.mnthLength + this.docNoLength + this.vendorLength + this.acctLength + this.wageLength + this.goodsLength + this.payLength + this.pvLength);
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
          vendorName = doString.checkString(rs.getString("bus_name"), ""); 
        rs.close();
        rs = null;
      } 
      printPubHeaderPage(table, currDate, iVendor, vendorName, vendorCut, markupPay, microssfont, microssfont_HD, microssfont_MINI, microssfont_BOLD);
      totalLine += 13;
      int line = 0;
      sql.delete(0, sql.length());
      sql.append("SELECT b.i_docno, b.i_month, b.p_com, b.i_ven_cut, b.i_account, SUM(ROUND(b.q_wage_unit * b.z_wage_price,2)) AS SUM_WAGE, ")
        .append(" SUM(ROUND(b.q_good_unit * b.z_good_price,2)) AS SUM_GOODS, ")
        .append(" SUM(b.z_amount_pay) AS SUM_AMOUNT_PAY, SUM(b.z_amount_pv) AS SUM_AMOUNT_PV, ")
        .append(" SUM(b.z_com_amount) AS SUM_AMOUNT_COM, SUM(b.z_cus_amount) AS SUM_AMOUNT_CUS FROM lan:serv_infdochd a, lan:serv_infpayment b ")
        .append(" WHERE b.f_itmstatus = 'CLS' AND b.i_itmtype = '02' AND b.i_docno = a.i_docno AND a.f_status IN ('OPN','CLS') ")
        .append(this.condition);
      if (iVendor.length() > 0)
        sql.append(" AND b.i_vendor = '").append(iVendor).append("' "); 
      if (this.cutVendorId.length() > 0)
        sql.append(" AND b.i_ven_cut = '").append(this.cutVendorId).append("' "); 
      sql.append(" GROUP BY b.i_docno, b.i_month, b.p_com, b.i_ven_cut, b.i_account ")
        .append(" ORDER BY b.i_docno, b.i_month, b.p_com, b.i_ven_cut, b.i_account");
      rs = stmt.executeQuery(sql.toString());
      while (rs.next()) {
        String iDocNo = doString.checkString(rs.getString("I_DOCNO"));
        String mnthDate = doString.checkString(rs.getString("I_MONTH"));
        String mnth = mnthDate.substring(5, 7);
        String year = Integer.toString(Integer.parseInt(mnthDate.substring(0, 4)) + 543);
        double p_com = rs.getDouble("P_COM");
        com_ps = doString.displayNumber("###.00", p_com);
        String vendorId = doString.checkString(rs.getString("I_VEN_CUT"));
        String acctId = doString.checkString(rs.getString("I_ACCOUNT"));
        double sumWage = rs.getDouble("SUM_WAGE");
        double sumGoods = rs.getDouble("SUM_GOODS");
        double amountPay = rs.getDouble("SUM_AMOUNT_PAY");
        double amountPV = rs.getDouble("SUM_AMOUNT_PV");
        double amountLH = rs.getDouble("SUM_AMOUNT_COM");
        double amountCust = rs.getDouble("SUM_AMOUNT_CUS");
        sumWage = Double.parseDouble(doString.displayNumber("#######0.00", sumWage));
        sumGoods = Double.parseDouble(doString.displayNumber("#######0.00", sumGoods));
        amountPay = Double.parseDouble(doString.displayNumber("#######0.00", amountPay));
        amountPV = Double.parseDouble(doString.displayNumber("#######0.00", amountPV));
        amountLH = Double.parseDouble(doString.displayNumber("#######0.00", amountLH));
        amountCust = Double.parseDouble(doString.displayNumber("#######0.00", amountCust));
        totalWage += sumWage;
        totalGoods += sumGoods;
        totalPay += amountPay;
        totalPV += amountPV;
        totalLH += amountLH;
        totalCust += amountCust;
        String vendName = "";
        if (vendorId.equals("999999")) {
          vendName = companyName;
        } else {
          rs1 = stmt1.executeQuery("SELECT bus_name FROM lan:stpvendr WHERE vend_code = '" + vendorId + "'");
          if (rs1.next())
            vendName = doString.checkString(rs1.getString("BUS_NAME"), ""); 
          rs1.close();
          rs1 = null;
        } 
        if (vendName.length() > 37)
          vendName = vendName.substring(0, 37) + ".."; 
        line++;
        cell = new PdfPCell(new Phrase(Integer.toString(line), microssfont));
        cell.setHorizontalAlignment(1);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.noLength);
        cell.setBorder(15);
        table.addCell(cell);
        cell = new PdfPCell(new Phrase(mnth + "/" + year, microssfont));
        cell.setHorizontalAlignment(1);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.mnthLength);
        cell.setBorder(15);
        table.addCell(cell);
        cell = new PdfPCell(new Phrase(iDocNo, microssfont));
        cell.setHorizontalAlignment(1);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.docNoLength);
        cell.setBorder(15);
        table.addCell(cell);
        cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(vendName), microssfont));
        cell.setHorizontalAlignment(0);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.vendorLength);
        cell.setBorder(15);
        table.addCell(cell);
        cell = new PdfPCell(new Phrase(acctId, microssfont));
        cell.setHorizontalAlignment(1);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.acctLength);
        cell.setBorder(15);
        table.addCell(cell);
        cell = new PdfPCell(new Phrase(format.format(sumWage), microssfont));
        cell.setHorizontalAlignment(2);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.wageLength);
        cell.setBorder(15);
        table.addCell(cell);
        cell = new PdfPCell(new Phrase(format.format(sumGoods), microssfont));
        cell.setHorizontalAlignment(2);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.goodsLength);
        cell.setBorder(15);
        table.addCell(cell);
        cell = new PdfPCell(new Phrase(format.format(amountPay), microssfont));
        cell.setHorizontalAlignment(2);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.payLength);
        cell.setBorder(15);
        table.addCell(cell);
        cell = new PdfPCell(new Phrase(format.format(amountPV), microssfont));
        cell.setHorizontalAlignment(2);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.pvLength);
        cell.setBorder(15);
        table.addCell(cell);
        cell = new PdfPCell(new Phrase(format.format(p_com), microssfont));
        cell.setHorizontalAlignment(2);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.pcLength);
        cell.setBorder(15);
        table.addCell(cell);
        cell = new PdfPCell(new Phrase(format.format(amountLH), microssfont));
        cell.setHorizontalAlignment(2);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.comLength);
        cell.setBorder(15);
        table.addCell(cell);
        if (amountLH > 0 && amountCust > 0) {
          cell = new PdfPCell(new Phrase(" ", microssfont));
        } else {
          cell = new PdfPCell(new Phrase(format.format(amountCust), microssfont));
        } 
        cell.setHorizontalAlignment(2);
        cell.setVerticalAlignment(5);
        cell.setBorderColor(this.borderColor);
        cell.setFixedHeight(21);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(5);
        cell.setColspan(this.cusLength);
        cell.setBorder(15);
        table.addCell(cell);
        totalLine++;
        if (totalLine >= this.rowPerPage) {
          cell = new PdfPCell(new Phrase(" ", microssfont));
          cell.setHorizontalAlignment(0);
          cell.setVerticalAlignment(4);
          cell.setColspan(100);
          cell.setBorder(0);
          table.addCell(cell);
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
          printPubHeaderPage(table, currDate, iVendor, vendorName, vendorCut, markupPay, microssfont, microssfont_HD, microssfont_MINI, microssfont_BOLD);
          totalLine += 13;
        } 
        if (amountLH > 0 && amountCust > 0) {
          rs1 = stmt1.executeQuery("SELECT i_acct_cus, SUM(z_cus_amount) AS SUM_AMOUNT_CUS FROM lan:serv_infpayment WHERE f_itmstatus = 'CLS' AND i_ven_cut = '" + vendorId + "' AND i_itmtype = '02' AND i_vendor = '" + iVendor + "' AND (d_payment BETWEEN '" + this.startDate + "' AND '" + this.endDate + "') AND i_docno = '" + iDocNo + "' AND i_account = '" + acctId + "' AND p_com = " + com_ps + " GROUP BY i_acct_cus ORDER BY i_acct_cus");
          if (rs1 != null) {
            while (rs1.next()) {
              acctId = doString.checkString(rs1.getString("i_acct_cus"));
              amountCust = rs1.getDouble("SUM_AMOUNT_CUS");
              cell = new PdfPCell(new Phrase(Integer.toString(line), microssfont));
              cell.setHorizontalAlignment(1);
              cell.setVerticalAlignment(5);
              cell.setBorderColor(this.borderColor);
              cell.setFixedHeight(21);
              cell.setPaddingTop(3);
              cell.setPaddingBottom(5);
              cell.setColspan(this.noLength);
              cell.setBorder(15);
              table.addCell(cell);
              cell = new PdfPCell(new Phrase(mnth + "/" + year, microssfont));
              cell.setHorizontalAlignment(1);
              cell.setVerticalAlignment(5);
              cell.setBorderColor(this.borderColor);
              cell.setFixedHeight(21);
              cell.setPaddingTop(3);
              cell.setPaddingBottom(5);
              cell.setColspan(this.mnthLength);
              cell.setBorder(15);
              table.addCell(cell);
              cell = new PdfPCell(new Phrase(iDocNo, microssfont));
              cell.setHorizontalAlignment(1);
              cell.setVerticalAlignment(5);
              cell.setBorderColor(this.borderColor);
              cell.setFixedHeight(21);
              cell.setPaddingTop(3);
              cell.setPaddingBottom(5);
              cell.setColspan(this.docNoLength);
              cell.setBorder(15);
              table.addCell(cell);
              cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(vendName), microssfont));
              cell.setHorizontalAlignment(0);
              cell.setVerticalAlignment(5);
              cell.setBorderColor(this.borderColor);
              cell.setFixedHeight(21);
              cell.setPaddingTop(3);
              cell.setPaddingBottom(5);
              cell.setColspan(this.vendorLength);
              cell.setBorder(15);
              table.addCell(cell);
              cell = new PdfPCell(new Phrase(acctId, microssfont));
              cell.setHorizontalAlignment(1);
              cell.setVerticalAlignment(5);
              cell.setBorderColor(this.borderColor);
              cell.setFixedHeight(21);
              cell.setPaddingTop(3);
              cell.setPaddingBottom(5);
              cell.setColspan(this.acctLength);
              cell.setBorder(15);
              table.addCell(cell);
              cell = new PdfPCell(new Phrase(" ", microssfont));
              cell.setHorizontalAlignment(2);
              cell.setVerticalAlignment(5);
              cell.setBorderColor(this.borderColor);
              cell.setFixedHeight(21);
              cell.setPaddingTop(3);
              cell.setPaddingBottom(5);
              cell.setColspan(this.wageLength);
              cell.setBorder(15);
              table.addCell(cell);
              cell = new PdfPCell(new Phrase(" ", microssfont));
              cell.setHorizontalAlignment(2);
              cell.setVerticalAlignment(5);
              cell.setBorderColor(this.borderColor);
              cell.setFixedHeight(21);
              cell.setPaddingTop(3);
              cell.setPaddingBottom(5);
              cell.setColspan(this.goodsLength);
              cell.setBorder(15);
              table.addCell(cell);
              cell = new PdfPCell(new Phrase(" ", microssfont));
              cell.setHorizontalAlignment(2);
              cell.setVerticalAlignment(5);
              cell.setBorderColor(this.borderColor);
              cell.setFixedHeight(21);
              cell.setPaddingTop(3);
              cell.setPaddingBottom(5);
              cell.setColspan(this.payLength);
              cell.setBorder(15);
              table.addCell(cell);
              cell = new PdfPCell(new Phrase(" ", microssfont));
              cell.setHorizontalAlignment(2);
              cell.setVerticalAlignment(5);
              cell.setBorderColor(this.borderColor);
              cell.setFixedHeight(21);
              cell.setPaddingTop(3);
              cell.setPaddingBottom(5);
              cell.setColspan(this.pvLength);
              cell.setBorder(15);
              table.addCell(cell);
              cell = new PdfPCell(new Phrase(" ", microssfont));
              cell.setHorizontalAlignment(2);
              cell.setVerticalAlignment(5);
              cell.setBorderColor(this.borderColor);
              cell.setFixedHeight(21);
              cell.setPaddingTop(3);
              cell.setPaddingBottom(5);
              cell.setColspan(this.pcLength);
              cell.setBorder(15);
              table.addCell(cell);
              cell = new PdfPCell(new Phrase(" ", microssfont));
              cell.setHorizontalAlignment(2);
              cell.setVerticalAlignment(5);
              cell.setBorderColor(this.borderColor);
              cell.setFixedHeight(21);
              cell.setPaddingTop(3);
              cell.setPaddingBottom(5);
              cell.setColspan(this.comLength);
              cell.setBorder(15);
              table.addCell(cell);
              cell = new PdfPCell(new Phrase(format.format(amountCust), microssfont));
              cell.setHorizontalAlignment(2);
              cell.setVerticalAlignment(5);
              cell.setBorderColor(this.borderColor);
              cell.setFixedHeight(21);
              cell.setPaddingTop(3);
              cell.setPaddingBottom(5);
              cell.setColspan(this.cusLength);
              cell.setBorder(15);
              table.addCell(cell);
              totalLine++;
              if (totalLine >= this.rowPerPage) {
                cell = new PdfPCell(new Phrase(" ", microssfont));
                cell.setHorizontalAlignment(0);
                cell.setVerticalAlignment(4);
                cell.setColspan(100);
                cell.setBorder(0);
                table.addCell(cell);
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
                printPubHeaderPage(table, currDate, iVendor, vendorName, vendorCut, markupPay, microssfont, microssfont_HD, microssfont_MINI, microssfont_BOLD);
                totalLine += 13;
              } 
            } 
            rs1.close();
            rs1 = null;
          } 
        } 
      } 
      rs.close();
      rs = null;
      cell = new PdfPCell(new Phrase("รวมเป็นเงิน", microssfont));
      cell.setHorizontalAlignment(1);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(this.noLength + this.mnthLength + this.docNoLength + this.vendorLength + this.acctLength);
      cell.setBorder(0);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(format.format(totalWage), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(this.wageLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(format.format(totalGoods), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(this.goodsLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(format.format(totalPay), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(this.payLength);
      cell.setBorder(15);
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(format.format(totalPV), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(this.pvLength);
      cell.setBorder(15);
      cell.setBackgroundColor(new Color(this.LIGHT_GRAY_COLOR));
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(" ", microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(this.pcLength);
      cell.setBorder(15);
      cell.setBackgroundColor(new Color(this.LIGHT_GRAY_COLOR));
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(format.format(totalLH), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(this.comLength);
      cell.setBorder(15);
      cell.setBackgroundColor(new Color(this.LIGHT_GRAY_COLOR));
      table.addCell(cell);
      cell = new PdfPCell(new Phrase(format.format(totalCust), microssfont));
      cell.setHorizontalAlignment(2);
      cell.setVerticalAlignment(5);
      cell.setBorderColor(this.borderColor);
      cell.setFixedHeight(21);
      cell.setPaddingTop(3);
      cell.setPaddingBottom(5);
      cell.setColspan(this.cusLength);
      cell.setBorder(15);
      cell.setBackgroundColor(new Color(this.LIGHT_GRAY_COLOR));
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
    this.nowPage = 0;
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
      this.cutVendorId = doString.checkString(req.getParameter("cut_vendor"), "");
      this.orderBy = doString.checkString(req.getParameter("order_by"), "b.i_docno");
      this.startDate = common.getValueFromDateListbox("start", req);
      this.endDate = common.getValueFromDateListbox("end", req);
      
      this.condition = "";
      this.condition = this.condition + " AND a.i_company = '" + ((this.selProj.length() > 0) ? this.selProj.substring(0, 2) : "") + "' AND a.i_project = '" + ((this.selProj.length() > 0) ? this.selProj.substring(3, 6) : "") + "' ";
      if (this.iVendor.trim().length() > 0)
        this.condition = this.condition + " AND b.i_vendor = '" + this.iVendor + "' "; 
      if (this.startDate.length() > 0 && this.endDate.length() > 0)
        this.condition = this.condition + " AND b.d_payment BETWEEN '" + this.startDate + "' AND '" + this.endDate + "' "; 
      Vector vendorCut = new Vector();
      rs = stmt.executeQuery("SELECT p_amount FROM lan:serv_xstd WHERE i_type = '09'");
      while (rs.next()) {
        double percent = rs.getDouble("p_amount");
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
      PdfContentByte cb = writer.getDirectContent();
      document.open();
      PdfPTable table = new PdfPTable(100);
      table.setWidthPercentage(100);
      
      this.companyName = "";
      if (this.selProj.trim().length() > 2) {
        this.projectName = "";
        sql.delete(0, sql.length());
        sql.append("select n_company from lan:acxcompa where i_company='").append(this.selProj.substring(0, 2)).append("' ");
        rs = stmt.executeQuery(sql.toString());
        if (rs.next())
          this.companyName = doString.checkString(rs.getString("n_company"), ""); 
        rs.close();
        sql.delete(0, sql.length());
        sql.append(" select * from lan:acxprojt a where ")
          .append(" a.i_company='" + ((this.selProj.length() > 0) ? this.selProj.substring(0, 2) : "") + "' ")
          .append(" and a.i_project='" + ((this.selProj.length() > 0) ? this.selProj.substring(3, 6) : "") + "'  ");
        rs = stmt.executeQuery(sql.toString());
        if (rs.next())
          this.projectName = doString.checkString(rs.getString("n_project"), ""); 
        rs.close();
      } 
      Vector vendorList = new Vector();
      sql.delete(0, sql.length());
      sql.append("SELECT DISTINCT b.i_vendor FROM lan:serv_infdochd a,lan:serv_infpayment b ")
        .append(" WHERE a.f_status IN ('OPN','CLS') AND b.i_docno = a.i_docno AND b.f_itmstatus = 'CLS' ");
      if (this.iVendor.length() > 0)
        sql.append(" AND b.i_vendor = '").append(this.iVendor).append("' "); 
      if (this.cutVendorId.length() > 0)
        sql.append(" AND b.i_ven_cut = '").append(this.cutVendorId).append("' "); 
      if (this.selProj.length() > 0 && !this.selProj.equals("ALL"))
        sql.append(" AND a.i_company = '" + ((this.selProj.length() >= 6) ? this.selProj.substring(0, 2) : "") + "' AND a.i_project = '" + ((this.selProj.length() >= 6) ? this.selProj.substring(3, 6) : "") + "' "); 
      sql.append(this.condition);
      rs = stmt.executeQuery(sql.toString());
      while (rs.next())
        vendorList.addElement(doString.checkString(rs.getString("i_vendor"), "")); 
      rs.close();
      rs = null;
      if (vendorList.size() <= 0)
        vendorList.addElement(""); 
      for (int v = 0; v < vendorList.size(); v++) {
        String vendorId = doString.checkString((String)vendorList.elementAt(v), "");
        String markupPay = "";
        if (this.selProj.trim().length() > 0 && vendorId.trim().length() > 0) {
          sql.delete(0, sql.length());
          sql.append(" select * from lan:serv_venprj where ")
            .append(" i_company='").append((this.selProj.length() >= 6) ? this.selProj.substring(0, 2) : "").append("' ")
            .append(" and i_project='").append((this.selProj.length() >= 6) ? this.selProj.substring(3, 6) : "").append("' ")
            .append(" and i_vendor='").append(vendorId).append("' ");
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
          rs = null;
        } 
        if (itmType.equals("01"))
          genVendorData(document, writer, conn, vendorId, this.companyName, vendorCut, markupPay, microssfont, microssfont_HD, microssfont_MINI, microssfont_BOLD); 
        if (itmType.equals("02"))
          genPubVendorData(document, writer, conn, vendorId, this.companyName, vendorCut, markupPay, microssfont, microssfont_HD, microssfont_MINI, microssfont_BOLD); 
      } 
      if (vendorList.size() <= 0) {
        table = new PdfPTable(100);
        table.setWidthPercentage(100);
        document.add(table);
        document.newPage();
      } 
      document.add(table);
      document.close();
      res.setContentType("application/pdf");
      res.setContentLength(baos.size());
      ServletOutputStream outServ = res.getOutputStream();
      baos.writeTo((OutputStream)outServ);
      outServ.flush();
      stmt1.close();
      stmt.close();
      conn.close();
      stmt1 = null;
      stmt = null;
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