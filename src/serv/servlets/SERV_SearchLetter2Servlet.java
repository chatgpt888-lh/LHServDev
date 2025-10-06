package serv.servlets;

import com.lh.servlet.DBServlet;
import com.lh.util.doString;
import com.lowagie.text.*;
import com.lowagie.text.pdf.*;
import java.awt.Color;
import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.sql.DataSource;
import serv.common.Constants;
import serv.common.User;

public class SERV_SearchLetter2Servlet extends DBServlet
{

    private int heightLine;
    private static String cName = "/LHServ/SERV_SearchLetter2Servlet";
    Calendar days;
    Calendar days2;
    String month[] = {
        "", "\u0E21\u0E01\u0E23\u0E32\u0E04\u0E21", "\u0E01\u0E38\u0E21\u0E20\u0E32\u0E1E\u0E31\u0E19\u0E18\u0E4C", "\u0E21\u0E35\u0E19\u0E32\u0E04\u0E21", "\u0E40\u0E21\u0E29\u0E32\u0E22\u0E19", "\u0E1E\u0E24\u0E29\u0E20\u0E32\u0E04\u0E21", "\u0E21\u0E34\u0E16\u0E38\u0E19\u0E32\u0E22\u0E19", "\u0E01\u0E23\u0E01\u0E0E\u0E32\u0E04\u0E21", "\u0E2A\u0E34\u0E07\u0E2B\u0E32\u0E04\u0E21", "\u0E01\u0E31\u0E19\u0E22\u0E32\u0E22\u0E19", 
        "\u0E15\u0E38\u0E25\u0E32\u0E04\u0E21", "\u0E1E\u0E24\u0E28\u0E08\u0E34\u0E01\u0E32\u0E22\u0E19", "\u0E18\u0E31\u0E19\u0E27\u0E32\u0E04\u0E21"
    };
    int DD;
    int MM;
    int YY;
    String Day;
    String year;
    String Mont;
    String Dayt;
    private Document document;
    private ByteArrayOutputStream baos;
    private PdfWriter writer;
    private PdfContentByte cb;
    private PdfReader reader;
    private StringBuffer query;
    private int count_i_seq;
    private int nxt;
    private String i_seq;
    private String new_i_seq;
    private String convert;
    private LinkedList lavoid;
    private int cavoid;
    private String i_address_type;
    private int d_close_law_year;
    private String d_close_law_mnth;
    private String d_close_law_date;
    private String addType;
    private int fix_d_close_law_mth;
    private String fix_d_close_law_year;
    private int fix_d_close_law_years;
    private String final_fix_d_close_law;
    private String PName;
    private String code;
    private String option;
    private int start_day;
    private String start_mnth;
    private String start_year;
    private int SEyear;
    private String firstLine;
    private String secondLine;
    private String thirdLine;
    private String fourLine;
    private int end_day;
    private String end_mnth;
    private String end_year;
    private int EEyear;
    private String realPath;
    private String templatePath;
    private String templateFiNme;
    private String i_lor;
    private String i_sort;
    private String i_house;
    private String i_exp_intent1;
    private String i_cus_intent1;
    private String full_cusname;
    private String cust_tel;
    private String i_model;
    private String d_close_law;
    private String fix_d_close_law;
    private String redirect;
    private String proj_name;
    private String Staffname;
    private String Stafftel;
    private String com_id;
    private String proj_id;
    private String company_id;
    private String project_id;
    private String cyear;
    private String name_project;
    private String id_project;
    private String Sname;
    private String Stel;
    private String optionSelected;
    private int count;
    private String b;
    private Vector Vec_i_lor;
    private String fadd2;
    private String fadd3;
    private String fadd4;
    private String fadd5;
    private String fadd6;
    private String fadd7;
    private String d;
    private String m;
    private String y;
    private int size;
    private boolean nextstate;
    private boolean checkname;
    private User user;
    private HttpSession session;
    private Object obj;

    public SERV_SearchLetter2Servlet()
    {
        heightLine = 19;
        days = Calendar.getInstance(Locale.ENGLISH);
        days2 = Calendar.getInstance(Locale.ENGLISH);
        DD = days.get(5);
        MM = days.get(2) + 1;
        YY = days.get(1);
        Day = null;
        year = null;
        Mont = null;
        Dayt = null;
        document = new Document(PageSize.A4, 0.0F, 0.0F, 0.0F, 0.0F);
        baos = new ByteArrayOutputStream();
        reader = null;
        query = new StringBuffer();
        count_i_seq = 1;
        nxt = 0;
        i_seq = "";
        new_i_seq = "";
        convert = "";
        cavoid = 0;
        i_address_type = "";
        d_close_law_year = 0;
        d_close_law_mnth = "";
        d_close_law_date = "";
        addType = "";
        fix_d_close_law_mth = 0;
        fix_d_close_law_year = "";
        fix_d_close_law_years = 0;
        final_fix_d_close_law = "";
        PName = "";
        code = "";
        option = "";
        start_day = 0;
        start_mnth = "";
        start_year = "";
        SEyear = 0;
        firstLine = "";
        secondLine = "";
        thirdLine = "";
        fourLine = "";
        end_day = 0;
        end_mnth = "";
        end_year = "";
        EEyear = 0;
        realPath = "";
        templatePath = "";
        templateFiNme = "";
        i_lor = "";
        i_sort = "";
        i_house = "";
        i_exp_intent1 = "";
        i_cus_intent1 = "";
        full_cusname = "";
        cust_tel = "";
        i_model = "";
        d_close_law = "";
        fix_d_close_law = "";
        redirect = "";
        proj_name = "";
        Staffname = "";
        Stafftel = "";
        com_id = "";
        proj_id = "";
        company_id = "";
        project_id = "";
        cyear = "";
        name_project = "";
        id_project = "";
        Sname = "";
        Stel = "";
        optionSelected = "";
        count = 0;
        b = "";
        Vec_i_lor = new Vector();
        fadd2 = "";
        fadd3 = "";
        fadd4 = "";
        fadd5 = "";
        fadd6 = "";
        fadd7 = "";
        size = 0;
        nextstate = true;
        checkname = true;
    }

    public PdfPCell addDataRight(String msg, int width, int height, Font font)
    {
        PdfPCell cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(msg), font));
        cell.setHorizontalAlignment(2);
        cell.setVerticalAlignment(4);
        cell.setColspan(width);
        cell.setFixedHeight(height);
        cell.setBorder(0);
        return cell;
    }

    public PdfPCell addDataCenter(String msg, int width, int height, Font font)
    {
        PdfPCell cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(msg), font));
        cell.setHorizontalAlignment(1);
        cell.setVerticalAlignment(4);
        cell.setColspan(width);
        cell.setFixedHeight(height);
        cell.setBorder(0);
        return cell;
    }

    public PdfPCell addData(String msg, int width, int height, Font font)
    {
        PdfPCell cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(msg), font));
        cell.setHorizontalAlignment(0);
        cell.setVerticalAlignment(4);
        cell.setColspan(width);
        cell.setFixedHeight(height);
        cell.setBorder(0);
        return cell;
    }

    public PdfPCell addDataNext(String msg, int width, Font font)
    {
        PdfPCell cell = new PdfPCell(new Phrase(doString.MS874ToUnicode(msg), font));
        cell.setHorizontalAlignment(0);
        cell.setVerticalAlignment(4);
        cell.setColspan(width);
        cell.setBorder(0);
        return cell;
    }

    public void performTask(HttpServletRequest req, HttpServletResponse res)
        throws ServletException, IOException
    {
        String projID = doString.checkString(req.getParameter("proj_name"), "LH000");
        String comId = projID.substring(0, 2);
        String projId = projID.substring(2);
        String chk_condo = "";
        id_project = req.getParameter("proj_name");
        Staffname = doString.checkString(req.getParameter("Staffname"), "");
        Stafftel = doString.checkString(req.getParameter("Stafftel"), "");
        chk_condo = doString.checkString(req.getParameter("chk_condo"), "");
        session = req.getSession();
        if(session != null)
        {
            Vec_i_lor = (Vector)session.getAttribute("VecKey");
        }
        if(Vec_i_lor == null)
        {
            Vec_i_lor = new Vector();
        }
        realPath = getServletContext().getRealPath("/");
        templatePath = realPath + "/template/";
        templateFiNme = "";
        if(chk_condo.equals("Y"))
        {
            templateFiNme = "Blank_3.pdf";
        } else
        {
            templateFiNme = "Blank_1.pdf";
        }
        System.out.println("templateFiNme==" + templatePath + templateFiNme);
        Connection conn = null;
        Statement stmt = null;
        Statement stmt1 = null;
        Statement stmt4 = null;
        Statement stmt5 = null;
        ResultSet rs = null;
        ResultSet rs1 = null;
        ResultSet rs4 = null;
        ResultSet rs5 = null;
        StringBuffer query = new StringBuffer();
        try
        {
            if(YY < 2400)
            {
                YY += 543;
            }
            if(MM < 10)
            {
                Mont = "0" + MM;
            } else
            {
                Mont = "" + MM;
            }
            if(DD < 10)
            {
                Dayt = "0" + DD;
            } else
            {
                Dayt = "" + DD;
            }
            year = doString.displayNumber("0000", YY);
            Day = Dayt + " " + month[MM] + " " + year;
            if(DBServlet.ds == null)
            {
                getDS();
            }
            conn = DBServlet.ds.getConnection();
            conn.setTransactionIsolation(1);
            conn.setAutoCommit(true);
            stmt = conn.createStatement();
            stmt1 = conn.createStatement();
            stmt4 = conn.createStatement();
            stmt5 = conn.createStatement();
            session = req.getSession(false);
            if(session == null)
            {
                res.sendRedirect("/LHServ/warning.htm");
                return;
            }
            obj = session.getAttribute("USER");
            if(obj == null)
            {
                res.sendRedirect("/LHServ/warning.htm");
                return;
            }
            user = (User)obj;
            Document document = new Document(PageSize.A4, 0.0F, 0.0F, 0.0F, 0.0F);
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            writer = PdfWriter.getInstance(document, baos);
            cb = writer.getDirectContent();
            PdfReader reader = null;
            com.lowagie.text.pdf.PdfImportedPage page1 = null;
            document.open();
            reader = new PdfReader(templatePath + templateFiNme);
            PdfPTable table = new PdfPTable(100);
            doString str = new doString();
            BaseFont bf = BaseFont.createFont(Constants.FONT_ANGSANA_NORMAL, "Identity-H", false);
            cb.addTemplate(writer.getImportedPage(reader, 1), 1.0F, 1.0F);
            Font font = new Font(bf, 14F, 0, new Color(0, 0, 0));
            query.delete(0, query.length());
            query.append("select n_project from lan:acxprojt where i_company ='").append(comId).append("' ").append(" and i_project = '").append(projId).append("' ");
            for(rs = stmt.executeQuery(query.toString()); rs.next();)
            {
                PName = doString.UnicodeToMS874(doString.checkString(rs.getString("n_project"), ""));
            }

            rs.close();
            for(int i = 0; i < Vec_i_lor.size(); i++)
            {
                i_lor = (String)Vec_i_lor.get(i);
                fix_d_close_law = doString.checkString(req.getParameter("fix_d_close_law" + i_lor));
                addType = doString.checkString(req.getParameter("CusAdd" + i_lor));
                fix_d_close_law_mth = Integer.parseInt(fix_d_close_law.substring(3, 5));
                final_fix_d_close_law = doString.checkString(fix_d_close_law.substring(0, 2) + " " + doString.UnicodeToMS874(month[fix_d_close_law_mth]) + " " + fix_d_close_law.substring(6));
                query.delete(0, query.length());
                query.append("select i_sort,d_close_law,i_cus_intent1,i_exp_intent1 from lan:acscontr where i_" +
"company ='"
).append(comId).append("' ").append(" and i_project = '").append(projId).append("' ").append(" and i_lor = '").append((String)Vec_i_lor.get(i)).append("' ").append("and f_contr is null");
                for(rs = stmt.executeQuery(query.toString()); rs != null && rs.next(); document.newPage())
                {
                    i_sort = doString.UnicodeToMS874(doString.checkString(rs.getString("i_sort"), ""));
                    i_exp_intent1 = doString.UnicodeToMS874(doString.checkString(rs.getString("i_exp_intent1"), ""));
                    i_cus_intent1 = doString.UnicodeToMS874(doString.checkString(rs.getString("i_cus_intent1"), ""));
                    d_close_law = doString.UnicodeToMS874(doString.checkString(rs.getString("d_close_law"), ""));
                    d_close_law_year = Integer.parseInt(doString.checkString(d_close_law.substring(0, 4)));
                    d_close_law_mnth = d_close_law.substring(8, 10);
                    d_close_law_date = d_close_law.substring(5, 7);
                    query.delete(0, query.length());
                    query.append("select i_house from lan:acxlckmd where i_company ='").append(comId).append("' ").append(" and i_project = '").append(projId).append("' and i_lor = '").append((String)Vec_i_lor.get(i)).append("'");
                    rs1 = stmt1.executeQuery(query.toString());
                    if(rs1.next())
                    {
                        i_house = doString.UnicodeToMS874(doString.checkString(rs1.getString("i_house"), "-"));
                    }
                    rs1.close();
                    if(i_cus_intent1.length() > 0)
                    {
                        query.delete(0, query.length());
                        query.append("select i_address_type, n_prename, n_ncustomer, n_scustomer, a_id_tel, a_wk_tel, " +
"a_etc_tel from lan:acxcusto where i_customer ='"
).append(i_cus_intent1).append("'");
                    } else
                    {
                        query.delete(0, query.length());
                        query.append("select i_address_type, n_prename, n_ncustomer, n_scustomer, a_id_tel, a_wk_tel, " +
"a_etc_tel from lan:acxcusto where i_customer ='"
).append(i_exp_intent1).append("'");
                    }
                    rs1 = stmt1.executeQuery(query.toString());
                    if(rs1.next())
                    {
                        i_address_type = doString.UnicodeToMS874(doString.checkString(rs1.getString("i_address_type"), ""));
                        full_cusname = doString.UnicodeToMS874(doString.checkString(rs1.getString("n_prename"), "")) + doString.UnicodeToMS874(doString.checkString(rs1.getString("n_ncustomer"), "") + " " + doString.checkString(rs1.getString("n_scustomer"), ""));
                        cust_tel = doString.UnicodeToMS874(doString.checkString(rs1.getString("a_id_tel"), "&nbsp") + " " + doString.checkString(rs1.getString("a_wk_tel"), "&nbsp") + " " + doString.checkString(rs1.getString("a_etc_tel"), "&nbsp"));
                    }
                    rs1.close();
                    query.delete(0, query.length());
                    query.append("select i_model from lan:acxlckhd a where i_company ='").append(comId).append("' ").append(" and i_project = '").append(projId).append("' and i_lor = '").append((String)Vec_i_lor.get(i)).append("'");
                    rs1 = stmt1.executeQuery(query.toString());
                    if(rs1.next())
                    {
                        i_model = doString.UnicodeToMS874(doString.checkString(rs1.getString("i_model"), ""));
                    }
                    rs1.close();
                    query.delete(0, query.length());
                    query.append("select max(i_seq) max from lan:serv_loglet where i_company='").append(comId).append("' and I_project='").append(projId).append("' and i_seq[1,2]='").append(year.substring(2, 4)).append("'");
                    rs1 = stmt1.executeQuery(query.toString());
                    if(rs1.next())
                    {
                        i_seq = doString.checkString(rs1.getString("max"), "");
                        if(i_seq.equalsIgnoreCase(""))
                        {
                            nxt = count_i_seq;
                            String bck = Integer.toString(nxt);
                            for(int z = bck.length(); z < 4; z++)
                            {
                                bck = "0" + bck;
                            }

                            new_i_seq = year.substring(2, 4) + bck;
                            nxt = 0;
                        } else
                        if(!i_seq.equalsIgnoreCase(""))
                        {
                            nxt = Integer.parseInt(i_seq.substring(2, i_seq.length()));
                            nxt++;
                            String bck = Integer.toString(nxt);
                            for(int z = bck.length(); z < 4; z++)
                            {
                                bck = "0" + bck;
                            }

                            i_seq = i_seq.substring(0, 2) + bck;
                            new_i_seq = i_seq;
                            nxt = 0;
                        }
                    }
                    rs1.close();
                    query.delete(0, query.length());
                    query.append("insert into lan:serv_loglet values('02','").append(comId).append("','").append(projId).append("','").append(new_i_seq).append("','").append(user.getUserName()).append("',current,'").append(i_sort).append("');");
                    stmt1.executeUpdate(query.toString());
                    cb.addTemplate(writer.getImportedPage(reader, 1), 1.0F, 1.0F);
                    table = new PdfPTable(100);
                    table.setWidthPercentage(100F);
                    table.addCell(addData("", 100, heightLine, font));
                    table.addCell(addData("", 83, heightLine, font));
                    table.addCell(addData("Seq-" + new_i_seq, 17, heightLine, font));
                    table.addCell(addData("", 100, heightLine * 2 + 11, font));
                    table.addCell(addData("", 20, heightLine + 3, font));
                    table.addCell(addData(PName, 30, heightLine + 3, font));
                    table.addCell(addData("", 50, heightLine + 3, font));
                    table.addCell(addData("", 55, heightLine + 1, font));
                    table.addCell(addData("\u0E27\u0E31\u0E19\u0E17\u0E35\u0E48 " + Day, 45, heightLine + 1, font));
                    table.addCell(addDataCenter("", 100, heightLine * 2 - 13, font));
                    table.addCell(addData("", 18, heightLine, font));
                    table.addCell(addData(full_cusname + " \u0E41\u0E1B\u0E25\u0E07 " + i_sort + " \u0E1A\u0E49\u0E32\u0E19\u0E40\u0E25\u0E02\u0E17\u0E35\u0E48 " + i_house, 82, heightLine, font));
                    table.addCell(addData("", 100, heightLine - 9, font));
                    table.addCell(addData("", 67, heightLine, font));
                    table.addCell(addData(PName, 33, heightLine, font));
                    table.addCell(addData("", 100, heightLine - 1, font));
                    table.addCell(addData("", 55, heightLine, font));
                    table.addCell(addData(d_close_law.substring(8, 10) + " " + doString.UnicodeToMS874(month[Integer.parseInt(d_close_law.substring(5, 7))]) + " " + (Integer.parseInt(doString.checkString(d_close_law.substring(0, 4))) + 544), 46, heightLine, font));
                    table.addCell(addData("", 100, heightLine * 7 + 18, font));
                    table.addCell(addDataNext("", 14, font));
                    table.addCell(addDataNext(Staffname + " \u0E42\u0E17\u0E23 " + Stafftel + " \u0E20\u0E32\u0E22\u0E43\u0E19\u0E27\u0E31\u0E19\u0E17\u0E35\u0E48 " + final_fix_d_close_law + " \u0E2B\u0E32\u0E01\u0E40\u0E25\u0E22\u0E01\u0E33\u0E2B\u0E19\u0E14\u0E19\u0E35\u0E49" +
"\u0E44\u0E1B\u0E41\u0E25\u0E49\u0E27 \u0E17\u0E32\u0E07\u0E1A\u0E23\u0E34\u0E29\u0E31" +
"\u0E17 \u0E02\u0E2D\u0E2A\u0E07\u0E27\u0E19\u0E2A\u0E34\u0E17\u0E18\u0E34\u0E4C\u0E43" +
"\u0E19\u0E01\u0E32\u0E23\u0E43\u0E2B\u0E49\u0E1A\u0E23\u0E34\u0E01\u0E32\u0E23\u0E07" +
"\u0E32\u0E19\u0E0B\u0E48\u0E2D\u0E21 "
, 78, font));
                    table.addCell(addData("", 100, heightLine, font));
                    table.addCell(addData("", 100, heightLine, font));
                    table.addCell(addData("", 14, heightLine, font));
                    table.addCell(addData("\u0E08\u0E36\u0E07\u0E40\u0E23\u0E35\u0E22\u0E19\u0E21\u0E32\u0E40\u0E1E\u0E37\u0E48" +
"\u0E2D\u0E17\u0E23\u0E32\u0E1A"
, 86, heightLine, font));
                    table.addCell(addData("", 58, heightLine, font));
                    table.addCell(addData("\u0E02\u0E2D\u0E41\u0E2A\u0E14\u0E07\u0E04\u0E27\u0E32\u0E21\u0E19\u0E31\u0E1A\u0E16" +
"\u0E37\u0E2D"
, 42, heightLine, font));
                    table.addCell(addData("", 100, heightLine, font));
                    table.addCell(addData("", 45, heightLine, font));
                    table.addCell(addDataCenter("(" + Staffname + ")", 40, heightLine, font));
                    table.addCell(addData("", 15, heightLine, font));
                    table.addCell(addData("", 50, heightLine, font));
                    table.addCell(addDataCenter("\u0E40\u0E08\u0E49\u0E32\u0E2B\u0E19\u0E49\u0E32\u0E17\u0E35\u0E48\u0E1A\u0E23\u0E34" +
"\u0E01\u0E32\u0E23\u0E25\u0E39\u0E01\u0E04\u0E49\u0E32"
, 30, heightLine, font));
                    table.addCell(addData("", 20, heightLine, font));
                    table.addCell(addData("", 100, heightLine * 4 + 5, font));
                    table.addCell(addData("", 26, heightLine, font));
                    table.addCell(addData("\u0E40\u0E23\u0E35\u0E22\u0E19", 74, heightLine, font));
                    table.addCell(addData("", 40, heightLine, font));
                    table.addCell(addData(full_cusname, 60, heightLine, font));
                    if(addType.equalsIgnoreCase("B"))
                    {
                        query.delete(0, query.length());
                        query.append("select a_add1,a_add2,a_add3,a_add4 from lan:acxprojt where i_company='").append(comId).append("' and i_project='").append(projId).append("'");
                        rs4 = stmt4.executeQuery(query.toString());
                        if(rs4.next())
                        {
                            lavoid = new LinkedList();
                            lavoid.add("0");
                            lavoid.add("1");
                            lavoid.add("2");
                            lavoid.add("3");
                            lavoid.add("4");
                            lavoid.add("5");
                            lavoid.add("6");
                            lavoid.add("7");
                            lavoid.add("8");
                            lavoid.add("9");
                            lavoid.add("/");
                            lavoid.add(" ");
                            convert = doString.checkString(rs4.getString("a_add1"), "");
                            cavoid = 0;
                            if(convert.length() > 0 && convert.length() != 0)
                            {
                                while(lavoid.contains(convert.substring(cavoid, cavoid + 1))) 
                                {
                                    cavoid++;
                                    if(!lavoid.contains(convert.substring(cavoid, cavoid + 1)))
                                    {
                                        break;
                                    }
                                }
                                if(convert.length() > 0 && convert.length() != 0)
                                {
                                    convert = convert.substring(cavoid);
                                }
                            }
                            firstLine = convert + " " + doString.checkString(rs4.getString("a_add2"));
                            secondLine = doString.checkString(rs4.getString("a_add3"));
                            thirdLine = doString.checkString(rs4.getString("a_add4"));
                            table.addCell(addData("", 40, heightLine, font));
                            table.addCell(addData(i_house + " \u0E21." + PName, 60, heightLine, font));
                            table.addCell(addData("", 40, heightLine, font));
                            table.addCell(addData(firstLine, 60, heightLine, font));
                            table.addCell(addData("", 40, heightLine, font));
                            table.addCell(addData(secondLine, 60, heightLine, font));
                            table.addCell(addData("", 40, heightLine, font));
                            table.addCell(addData(thirdLine, 60, heightLine, font));
                        }
                        rs4.close();
                    } else
                    if(addType.equalsIgnoreCase("A"))
                    {
                        String iCust = "";
                        if(i_exp_intent1.length() > 0)
                        {
                            iCust = i_exp_intent1;
                        } else
                        if(i_cus_intent1.length() > 0)
                        {
                            iCust = i_cus_intent1;
                        }
                        query.delete(0, query.length());
                        if(i_address_type.equalsIgnoreCase("1"))
                        {
                            query.append(" select '' as a_name,a_id_add1 as add1,a_id_add2 as add2,a_id_add3 as add3, ").append(" a_id_add4 as add4,a_id_add5 as add5,a_id_add6 as add6, ").append(" a_id_add7 as add7 ,a_id_postcode as postcode ").append(" from lan:acxcusto where I_customer='").append(iCust).append("'");
                        } else
                        if(i_address_type.equalsIgnoreCase("2"))
                        {
                            query.append(" select a_wk_name as a_name, a_wk_add1 as add1,a_wk_add2 as add2,a_wk_add3 as ad" +
"d3, "
).append(" a_wk_add4 as add4,a_wk_add5 as add5,a_wk_add6 as add6, ").append(" a_wk_add7 as add7 ,a_wk_postcode as postcode ").append(" from lan:acxcusto where I_customer='").append(iCust).append("'");
                        } else
                        if(i_address_type.equalsIgnoreCase("3"))
                        {
                            query.append(" select a_etc_name as a_name, a_etc_add1 as add1,a_etc_add2 as add2,a_etc_add3 a" +
"s add3, "
).append(" a_etc_add4 as add4,a_etc_add5 as add5,a_etc_add6 as add6, ").append(" a_etc_add7 as add7 ,a_etc_postcode as postcode ").append(" from lan:acxcusto where I_customer='").append(iCust).append("'");
                        }
                        if(query.length() > 0)
                        {
                            for(rs4 = stmt4.executeQuery(query.toString()); rs4.next();)
                            {
                                if(!doString.checkString(rs4.getString("add2"), "").equalsIgnoreCase(""))
                                {
                                    fadd2 = " \u0E2B\u0E21\u0E39\u0E48 " + doString.checkString(rs4.getString("add2"));
                                }
                                if(!doString.checkString(rs4.getString("add3"), "").equalsIgnoreCase(""))
                                {
                                    fadd3 = " \u0E0B." + doString.checkString(rs4.getString("add3"));
                                }
                                if(!doString.checkString(rs4.getString("add4"), "").equalsIgnoreCase(""))
                                {
                                    fadd4 = "\u0E16." + doString.checkString(rs4.getString("add4"));
                                }
                                if(!doString.checkString(rs4.getString("add5"), "").equalsIgnoreCase(""))
                                {
                                    fadd5 = " \u0E15." + doString.checkString(rs4.getString("add5"));
                                }
                                if(!doString.checkString(rs4.getString("add6"), "").equalsIgnoreCase(""))
                                {
                                    fadd6 = " \u0E2D." + doString.checkString(rs4.getString("add6"));
                                }
                                if(!doString.checkString(rs4.getString("add7"), "").equalsIgnoreCase(""))
                                {
                                    fadd7 = "\u0E08." + doString.checkString(rs4.getString("add7"));
                                }
                                firstLine = doString.checkString(rs4.getString("a_name"));
                                secondLine = doString.checkString(rs4.getString("add1")) + fadd2 + " " + fadd3;
                                thirdLine = fadd4 + " " + fadd5 + " " + fadd6;
                                fourLine = fadd7 + " " + doString.checkString(rs4.getString("postcode"));
                                if(firstLine.length() > 0)
                                {
                                    table.addCell(addData("", 40, heightLine, font));
                                    table.addCell(addData(firstLine, 60, heightLine, font));
                                }
                                table.addCell(addData("", 40, heightLine, font));
                                table.addCell(addData(secondLine, 60, heightLine, font));
                                table.addCell(addData("", 40, heightLine, font));
                                table.addCell(addData(thirdLine, 60, heightLine, font));
                                table.addCell(addData("", 40, heightLine, font));
                                table.addCell(addData(fourLine, 60, heightLine, font));
                                fadd2 = "";
                                fadd3 = "";
                                fadd4 = "";
                                fadd5 = "";
                                fadd6 = "";
                                fadd7 = "";
                            }

                            rs4.close();
                        }
                    }
                    document.add(table);
                }

                rs.close();
            }

            session = req.getSession(false);
            if(session == null)
            {
                res.sendRedirect("/LHServ/warning.htm");
                return;
            }
            obj = session.getAttribute("USER");
            if(obj == null)
            {
                res.sendRedirect("/LHServ/warning.htm");
                return;
            }
            user = (User)obj;
            document.close();
            res.setContentType("application/pdf");
            res.setContentLength(baos.size());
            javax.servlet.ServletOutputStream outServ = res.getOutputStream();
            baos.writeTo(outServ);
            outServ.flush();
            stmt.close();
            stmt1.close();
            stmt4.close();
            stmt5.close();
        }
        catch(DocumentException de)
        {
            System.out.print(de.getMessage());
        }
        catch(Exception e)
        {
            System.out.print(e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(rs1 != null)
                {
                    rs1.close();
                }
                if(rs4 != null)
                {
                    rs4.close();
                }
                if(rs5 != null)
                {
                    rs5.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
                if(stmt1 != null)
                {
                    stmt1.close();
                }
                if(stmt4 != null)
                {
                    stmt4.close();
                }
                if(stmt5 != null)
                {
                    stmt5.close();
                }
                if(conn != null)
                {
                    conn.close();
                }
            }
            catch(SQLException ignore) { }
        }
    }

}
