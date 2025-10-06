package serv.common;

import com.lh.util.doString;
import java.io.PrintStream;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServletRequest;

// Referenced classes of package serv.common:
//            Constants

public class SERV_InfCommonData
{

    private Connection conn;

    public SERV_InfCommonData(Connection conn)
    {
        this.conn = conn;
    }

    public static boolean checkPermissionOnPage(String permissionPage, String userWho)
    {
        boolean result = false;
        int pageOrder = 0;
        for(int i = 0; i < Constants.PERMISSION_ORDER.length; i++)
        {
            if(!Constants.PERMISSION_ORDER[i].equalsIgnoreCase(permissionPage))
            {
                continue;
            }
            pageOrder = i;
            break;
        }

        int userOrder = 0;
        for(int i = 0; i < Constants.PERMISSION_ORDER.length; i++)
        {
            if(!Constants.PERMISSION_ORDER[i].equalsIgnoreCase(userWho))
            {
                continue;
            }
            userOrder = i;
            break;
        }

        if(userOrder >= pageOrder)
        {
            result = true;
        } else
        {
            result = false;
        }
        return result;
    }

    public String getValueFromDateListbox(String name, HttpServletRequest req)
        throws Exception
    {
        String result = "";
        doString str = new doString();
        Calendar cal = Calendar.getInstance();
        String date = doString.checkString(req.getParameter(name + "_date"), "");
        String month = doString.checkString(req.getParameter(name + "_month"), "");
        int year = Integer.parseInt(doString.checkString(req.getParameter(name + "_year"), "0"));
        if(year > 2400)
        {
            year -= 543;
        }
        result = year + "-" + month + "-" + date;
        return result.length() != 10 ? "" : result;
    }

    public String genDateOfMonthListbox(String name, String date, String params)
    {
        StringBuffer html = new StringBuffer();
        doString str = new doString();
        html.append("<select name='").append(name).append("' ").append(params).append(" >");
        html.append("<option value=''>- -</option>");
        for(int i = 1; i <= 31; i++)
        {
            String value = str.createID(i, 2);
            String selected = "";
            if(date != null && value.equalsIgnoreCase(date))
            {
                selected = " selected ";
            }
            html.append("<option value='").append(value).append("' ").append(selected).append(">").append(value).append("</option>");
        }

        html.append("</select> ");
        return doString.UnicodeToMS874(html.toString());
    }

    public String genYearListbox(String name, String year, String params)
    {
        Calendar cal = Calendar.getInstance();
        int nowYear = cal.get(1);
        if(nowYear > 2400)
        {
            nowYear -= 543;
        }
        return genYearListbox(name, year, params, nowYear, 5);
    }

    public String genYearListbox(String name, String year, String params, int start, int next)
    {
        StringBuffer html = new StringBuffer();
        doString str = new doString();
        html.append("<select name='").append(name).append("' ").append(params).append(" >");
        html.append("<option value=''>- - - -</option>");
        for(int i = start; i <= start + next; i++)
        {
            String value = Integer.toString(i);
            String label = Integer.toString(i + 543);
            String selected = "";
            if(year != null && value.equalsIgnoreCase(year))
            {
                selected = " selected ";
            }
            html.append("<option value='").append(value).append("' ").append(selected).append(">").append(label).append("</option>");
        }

        html.append("</select> ");
        return doString.UnicodeToMS874(html.toString());
    }

    public String genMonthListbox(String name, String month, String params)
    {
        StringBuffer html = new StringBuffer();
        doString str = new doString();
		String thaiMonth[] = new String[] {"มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
        html.append("<select name='").append(name).append("' ").append(params).append(" >");
        html.append("<option value=''>- - - - - - - - - -</option>");
        for(int i = 1; i <= 12; i++)
        {
            String value = str.createID(i, 2);
            String label = thaiMonth[i - 1];
            String selected = "";
            if(month != null && value.equalsIgnoreCase(month))
            {
                selected = " selected ";
            }
            html.append("<option value='").append(value).append("' ").append(selected).append(">").append(label).append("</option>");
        }

        html.append("</select> ");
        return html.toString();
    }

    public String genDateListbox(String name, HttpServletRequest req, String params)
        throws Exception
    {
        StringBuffer html = new StringBuffer();
        doString str = new doString();
        Calendar cal = Calendar.getInstance(Locale.ENGLISH);
		String thaiMonth[] = new String[] {"มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
        String date = doString.checkString(req.getParameter(name + "_date"), "");
        String month = doString.checkString(req.getParameter(name + "_month"), "");
        String year = doString.checkString(req.getParameter(name + "_year"), "");
        html.append("<select name='").append(name + "_date").append("' ").append(params).append(" >");
        html.append("<option value=''>- -</option>");
        for(int i = 1; i <= 31; i++)
        {
            String value = str.createID(i, 2);
            String selected = "";
            if(date != null && value.equalsIgnoreCase(date))
            {
                selected = " selected ";
            }
            html.append("<option value='").append(value).append("' ").append(selected).append(">").append(value).append("</option>");
        }

        html.append("</select> ");
        html.append("<select name='").append(name + "_month").append("' ").append(params).append(" >");
        html.append("<option value=''>- - - - - - - - - -</option>");
        for(int i = 1; i <= 12; i++)
        {
            String value = str.createID(i, 2);
            String label = thaiMonth[i - 1];
            String selected = "";
            if(month != null && value.equalsIgnoreCase(month))
            {
                selected = " selected ";
            }
            html.append("<option value='").append(value).append("' ").append(selected).append(">").append(label).append("</option>");
        }

        html.append("</select> ");
        html.append("<select name='").append(name + "_year").append("' ").append(params).append(" >");
        html.append("<option value=''>- - - -</option>");
        int nowYear = cal.get(1);
        if(nowYear > 2400)
        {
            nowYear -= 543;
        }
        for(int i = nowYear - 5; i <= nowYear + 5; i++)
        {
            String value = Integer.toString(i);
            String label = Integer.toString(i + 543);
            String selected = "";
            if(year != null && value.equalsIgnoreCase(year))
            {
                selected = " selected ";
            }
            html.append("<option value='").append(value).append("' ").append(selected).append(">").append(label).append("</option>");
        }

        html.append("</select> ");
        return html.toString();
    }

    public String genAllProjectListbox(String name, String value, String params, boolean allProj)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        boolean allProject = false;
        try
        {
            stmt = conn.createStatement();
            int year = Calendar.getInstance().get(1);
            if(year < 2400)
            {
                year += 543;
            }
            int pYear = year - 1;
            sql.append(" select distinct a.i_company,a.i_project,b.n_project from lan:acsbudgh a  ").append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project" +
" "
).append(" where a.d_year in ( '").append(year).append("' , '").append(pYear).append("' ) ").append(" and a.i_budg_type in (9)  ").append(" order by a.i_company , a.i_project ");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(name).append("' ").append(params).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            if(allProj)
            {
                html.append("<option value='ALL' " + (value.equalsIgnoreCase("ALL") ? "selected" : "") + ">" + Constants.LISTBOX_ALLPROJECT_LABEL + "</option>");
            }
            String comId;
            String projId;
            String projName;
            String val;
            String selected;
            for(; rs.next(); html.append("<option value='").append(val).append("' ").append(selected).append(">").append(comId).append("-").append(projId).append(" - ").append(projName).append("</option>"))
            {
                comId = doString.checkString(rs.getString("i_company"), "");
                projId = doString.checkString(rs.getString("i_project"), "");
                projName = doString.checkString(doString.DisplayThai(rs.getString("n_project")), "");
                val = comId + ":" + projId;
                selected = "";
                if(value != null && val.equalsIgnoreCase(value))
                {
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" genAllProjectListbox Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String genProjectListboxByUserId(String userId, String name, String value, String params)
    {
        return genProjectListboxByUserId(userId, name, value, params, false);
    }

    public String genProjectListboxByUserId(String userId, String name, String value, String params, boolean getAllProj)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        boolean allProject = false;
        try
        {
            stmt = conn.createStatement();
            String userWho = "";
            String iPerson = "";
            sql.delete(0, sql.length());
            sql.append(" select * from lan:useracl where user_id='").append(userId).append("' and user_acl='S' ");
            rs = stmt.executeQuery(sql.toString());
            if(rs.next())
            {
                userWho = doString.checkString(rs.getString("user_who"), "");
                iPerson = doString.checkString(rs.getString("i_person"), "");
            }
            rs.close();
            if(userWho.equalsIgnoreCase(Constants.PERMISSION_VENDOR))
            {
                sql.delete(0, sql.length());
                sql.append(" select a.i_company com_id,a.i_project proj_id,b.n_project from lan:serv_venprj " +
"a "
).append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project" +
" "
).append(" where a.i_vendor='").append(iPerson).append("' ").append(" and a.i_type='01' order by a.com_id,a.proj_id ");
            } else
            {
                sql.delete(0, sql.length());
                sql.append(" select a.com_id, a.proj_id, b.n_project  from lan:serv_pstaff a ").append(" left join lan:acxprojt b on b.i_company=a.com_id  and  b.i_project=a.proj_id ").append(" where a.user_id = '").append(userId).append("' ").append(" order by a.com_id,a.proj_id ");
            }
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(name).append("' ").append(params).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            String comId;
            String projId;
            String projName;
            String val;
            String selected;
            for(; rs.next(); html.append("<option value='").append(val).append("' ").append(selected).append(">").append(comId).append("-").append(projId).append(" - ").append(projName).append("</option>"))
            {
                comId = doString.checkString(rs.getString("com_id"), "");
                projId = doString.checkString(rs.getString("proj_id"), "");
                projName = doString.checkString(doString.DisplayThai(rs.getString("n_project")), "");
                val = comId + ":" + projId;
                selected = "";
                if(value != null && val.equalsIgnoreCase(value))
                {
                    selected = " selected ";
                }
                if(!projId.equalsIgnoreCase("ALL"))
                {
                    continue;
                }
                allProject = true;
                break;
            }

            html.append("</select>");
            rs.close();
            stmt.close();
            if(allProject)
            {
                html.delete(0, html.length());
                html.append(genAllProjectListbox(name, value, params, getAllProj));
            }
        }
        catch(Exception e)
        {
            System.out.println(" genProjectListboxByUserId Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String getProjectListByUserId(String userId)
    {
        String result = "";
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        boolean allProject = false;
        try
        {
            stmt = conn.createStatement();
            String userWho = "";
            String iPerson = "";
            sql.delete(0, sql.length());
            sql.append(" select * from lan:useracl where user_id='").append(userId).append("' and user_acl='S' ");
            rs = stmt.executeQuery(sql.toString());
            if(rs.next())
            {
                userWho = doString.checkString(rs.getString("user_who"), "");
                iPerson = doString.checkString(rs.getString("i_person"), "");
            }
            rs.close();
            if(userWho.equalsIgnoreCase(Constants.PERMISSION_VENDOR))
            {
                sql.delete(0, sql.length());
                sql.append(" select a.i_company com_id,a.i_project proj_id,b.n_project from lan:serv_venprj " +
"a "
).append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project" +
" "
).append(" where a.i_vendor='").append(iPerson).append("' ").append(" and a.i_type='01' order by a.com_id,a.proj_id ");
            } else
            {
                sql.delete(0, sql.length());
                sql.append(" select a.com_id, a.proj_id, b.n_project  from lan:serv_pstaff a ").append(" left join lan:acxprojt b on b.i_company=a.com_id  and  b.i_project=a.proj_id ").append(" where a.user_id = '").append(userId).append("' ").append(" order by a.com_id,a.proj_id ");
            }
            for(rs = stmt.executeQuery(sql.toString()); rs.next();)
            {
                String comId = doString.checkString(rs.getString("com_id"), "");
                String projId = doString.checkString(rs.getString("proj_id"), "");
                String projName = doString.checkString(doString.DisplayThai(rs.getString("n_project")), "");
                if(projId.equalsIgnoreCase("ALL"))
                {
                    break;
                }
                if(result.length() > 0)
                {
                    result = result + ",";
                }
                result = result + " '" + comId + "-" + projId + "' ";
            }

            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" getProjectListByUserId Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return result;
    }

    public String genAllVendorList(String name, String value, String params)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = conn.createStatement();
            sql.append(" select vend_code,bus_name from lan:stpvendr  ").append(" order by  vend_code");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(name).append("' ").append(params).append(" >");
            html.append("<option value=''>").append(Constants.LISTBOX_SELECT_LABEL).append("</option>");
            int i = 0;
            String vendCode;
            String vendName;
            String val;
            String selected;
            for(; rs.next(); html.append("<option value='").append(val).append("' ").append(selected).append(">").append(vendCode).append(" | ").append(vendName).append("</option>"))
            {
                vendCode = doString.checkString(rs.getString("vend_code"), "");
                vendName = doString.checkString(doString.DisplayThai(rs.getString("bus_name")), "");
                val = vendCode + " | " + vendName;
                selected = "";
                String valCode = "";
                if(value != null && value.indexOf("|") > 0)
                {
                    valCode = value.substring(0, value.indexOf("|")).trim();
                }
                if(vendCode != null && vendCode.trim().equalsIgnoreCase(valCode))
                {
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" genAllVendorList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String genVendorList(String name, String selProj, String value, String params)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        String comId = "";
        String projId = "";
        try
        {
            stmt = conn.createStatement();
            StringTokenizer id = new StringTokenizer(selProj, ":");
            if(id != null && id.countTokens() == 2)
            {
                comId = id.nextToken();
                projId = id.nextToken();
            }
            sql.append(" select b.bus_name,a.* from lan:serv_venprj a  ").append(" left join lan:stpvendr b on b.vend_code=a.i_vendor ").append(" where a.i_type='01' ").append(" and a.i_company='").append(comId).append("' ").append(" and a.i_project='").append(projId).append("' ").append(" order by b.bus_name ");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(name).append("' ").append(params).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            String iVendor;
            String vendorName;
            String selected;
            for(; rs.next(); html.append("<option value='").append(iVendor).append("' ").append(selected).append(">").append(vendorName).append("</option>"))
            {
                iVendor = doString.checkString(rs.getString("i_vendor"), "");
                vendorName = doString.checkString(doString.DisplayThai(rs.getString("bus_name")), "");
                selected = "";
                if(value != null && iVendor.equalsIgnoreCase(value))
                {
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" genVendorList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

	public String genVendorListForCut(String name,String selProj,String value,String params) {
		 StringBuffer html = new StringBuffer();
		 StringBuffer sql = new StringBuffer();
		 Statement stmt = null;
		 ResultSet rs = null;
	     
		 String comId = "";
		 String projId = "";
	     
		 try {
			stmt = conn.createStatement();
		 	
			 //---======= Split ID from SelProj Variable =========----//
			 StringTokenizer id = new StringTokenizer(selProj,":");
			 if (id!=null && id.countTokens()==2) {
				comId = id.nextToken();
				projId = id.nextToken();
			 }

			 sql.append(" select b.bus_name,a.* from lan:serv_venprj a  ")
				   .append(" left join lan:stpvendr b on b.vend_code=a.i_vendor ")
				   .append(" where a.i_type='02' ")
				   .append(" and a.i_company='").append(comId).append("' ")
				   .append(" and a.i_project='").append(projId).append("' ")
				   .append(" order by b.bus_name ");
			 rs = stmt.executeQuery(sql.toString());
		     
			 //-------============== Generate List box ===================------//
			 html.append("<select name='").append(name).append("' ").append(params).append(" >");	
			 html.append("<option value=''>"+Constants.LISTBOX_SELECT_LABEL+"</option>");
		     	     		     
			 while (rs.next()) {
				String iVendor = doString.checkString(rs.getString("i_vendor"),"");
				String vendorName = doString.checkString(doString.DisplayThai(rs.getString("bus_name")),"");
				String selected = "";
				if (value!=null && iVendor.equalsIgnoreCase(value)) {
				   selected = " selected "; 
				}		        
		        
				html.append("<option value='").append(iVendor).append("' ").append(selected).append(">")
						.append(vendorName).append("</option>");		        
			 } // end while		  
			 
			 
			 //----================== Add Company for use in cut free ===================-----//
			 sql.delete(0,sql.length());
			 sql.append(" select * from lan:acxcompa where i_company='").append(comId).append("' ");
			 rs = stmt.executeQuery(sql.toString());
			 if (rs.next()) {
				String vendorName = comId.toUpperCase()+" - "+doString.checkString(doString.DisplayThai(rs.getString("n_company")),"");
				String selected = "";
				if (value!=null && value.equals("999999")) {
					selected = " selected "; 
				}	
								
				html.append("<option value='999999' ").append(selected).append(">")
						.append(vendorName).append("</option>");					 	 
			 }
			 rs.close();
			    
			 html.append("</select>");
			 //----=====================================================----//
		           		     
			 rs.close();
			 stmt.close();

		 } catch (Exception e) {
			 System.out.println(" genVendorList Error : "+e.getMessage());
		 } finally {
			 try {
				if (rs!=null) rs.close();
				if (stmt!=null) stmt.close();
			 } catch (Exception ex) {}
		 }
	     
		 return html.toString();
	}		

    public String genPercentCutList(String name, String value, String params)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = conn.createStatement();
            sql.append(" select * from lan:serv_xstd where i_type='04' ");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(name).append("' ").append(params).append(" >");
            html.append("<option value=''>--------</option>");
            int pAmount;
            String nDesc;
            String selected;
            for(; rs.next(); html.append("<option value='").append(pAmount).append("' ").append(selected).append(">").append(nDesc).append("</option>"))
            {
                pAmount = rs.getInt("p_amount");
                nDesc = doString.checkString(doString.DisplayThai(rs.getString("n_desc")), "");
                selected = "";
                if(value != null && Integer.toString(pAmount).equalsIgnoreCase(value))
                {
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" genVendorList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String genWrongTypeList(String name, String value, String params)
    {
        StringBuffer html = new StringBuffer();
        value = doString.checkString(value, "");
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = conn.createStatement();
            html.append("<select name='").append(name).append("' ").append(params).append(" >");
			html.append("<option value=''>- เลือก -</option>");
            sql.delete(0, sql.length());
            sql.append("select * from lan:serv_xstd where i_type='06' ");
            String iCode;
            String nDesc;
            String selected;
            for(rs = stmt.executeQuery(sql.toString()); rs.next(); html.append("<option value='").append(iCode).append("' ").append(selected).append(">").append(nDesc).append("</option>"))
            {
                iCode = doString.checkString(rs.getString("i_code"), "");
                nDesc = doString.checkString(doString.DisplayThai(rs.getString("n_desc")), "");
                selected = "";
                if(value.equalsIgnoreCase(iCode))
                {
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" genVendorList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String genAreaList(String name, String value, String params)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = conn.createStatement();
            sql.append(" select * from lan:serv_xstd where i_type='01' ").append(" order by n_desc ");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(name).append("' ").append(params).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            String iCode;
            String nDesc;
            String selected;
            for(; rs.next(); html.append("<option value='").append(iCode).append("' ").append(selected).append(">").append(nDesc).append("</option>"))
            {
                iCode = doString.checkString(rs.getString("i_code"), "");
                nDesc = doString.checkString(doString.DisplayThai(rs.getString("n_desc")), "");
                selected = "";
                if(value != null && iCode.equalsIgnoreCase(value))
                {
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" genAreaList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String genBOQApproverList(String name, String value, String params)
    {
        return genBOQApproverList(name, value, params, "");
    }

    public String genBOQApproverList(String name, String value, String params, String userId)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = conn.createStatement();
            sql.append(" select a.i_employ, trim(b.n_prename_th)||trim(b.n_nemploy_th)||' '||trim(b.n_se" +
"mploy_th) n_employ  "
).append(" from lan:useracl a left join docflow:acemploy b on b.i_employ=a.i_employ ").append(" where a.user_who='C' and a.user_acl='S' ");
            if(userId.trim().length() > 0)
            {
                sql.append(" and user_id='" + userId + "' ");
            }
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(name).append("' ").append(params).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            String iEmploy;
            String nEmploy;
            String selected;
            for(; rs.next(); html.append("<option value='").append(iEmploy).append("' ").append(selected).append(">").append(nEmploy).append("</option>"))
            {
                iEmploy = doString.checkString(rs.getString("i_employ"), "");
                nEmploy = doString.checkString(doString.DisplayThai(rs.getString("n_employ")), "");
                selected = "";
                if(value != null && iEmploy.equalsIgnoreCase(value))
                {
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" genBOQApproverList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String genBOQGroupList(String name, String value, String params)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        boolean allProject = false;
        try
        {
            stmt = conn.createStatement();
            sql.append("select * from lan:serv_boq where (i_group is not null) and ((i_type is null) or " +
"(i_type='')) "
).append(" and ((i_seq is null) or (i_seq='')) ").append(" order by i_group ");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(name).append("' ").append(params).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            String iGroup;
            String nItmJob;
            String selected;
            for(; rs.next(); html.append("<option value='").append(iGroup).append("' ").append(selected).append(">").append(nItmJob).append("</option>"))
            {
                iGroup = doString.checkString(rs.getString("i_group"), "");
                nItmJob = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")), "");
                selected = "";
                if(value != null && iGroup.equalsIgnoreCase(value))
                {
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" genBOQGroupList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String genINFBOQGroupList(String name, String value, String params)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        boolean allProject = false;
        try
        {
            stmt = conn.createStatement();
            sql.append("select * from lan:serv_infboq where i_type = '00' and i_seq = '0000' order by i_" +
"group"
);
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(name).append("' ").append(params).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            String iGroup;
            String nItmJob;
            String selected;
            for(; rs.next(); html.append("<option value='").append(iGroup).append("' ").append(selected).append(">").append(nItmJob).append("</option>"))
            {
                iGroup = doString.checkString(rs.getString("i_group"), "");
                nItmJob = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")), "");
                selected = "";
                if(value != null && iGroup.equalsIgnoreCase(value))
                {
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" genINFBOQGroupList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String genBOQProject(String userId, String DHTML_Name, String ItemValue, String cur_year, String DHTML_Stye)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = conn.createStatement();
            sql.delete(0, sql.length());
            sql.append("SELECT DISTINCT proj.i_company, proj.i_project, proj.n_project FROM lan:acxprojt" +
" proj, lan:acsbudgh bud"
);
            rs = stmt.executeQuery("SELECT proj_id FROM lan:serv_pstaff WHERE user_id = '" + userId + "' AND proj_id = 'ALL'");
            if(rs.next())
            {
                sql.append(" WHERE");
            } else
            {
                sql.append(", lan:serv_pstaff staff WHERE proj.i_company = staff.com_id AND proj.i_project =" +
" staff.proj_id AND staff.user_id = '"
).append(userId + "' AND");
            }
            rs.close();
            rs = null;
            sql.append(" bud.i_company = proj.i_company AND bud.i_project = proj.i_project AND bud.d_yea" +
"r = '"
 + cur_year + "' ORDER BY proj.i_company, proj.i_project");
            html.append("<select name='").append(DHTML_Name).append("' ").append(DHTML_Stye).append(" >");
            html.append("<option value=''>").append(Constants.LISTBOX_SELECT_LABEL).append("</option>");
            String label;
            String selected;
            String value;
            for(rs = stmt.executeQuery(sql.toString()); rs.next(); html.append("<option value='").append(value).append("' ").append(selected).append(">").append(value).append(" - ").append(label).append("</option>"))
            {
                String code = doString.checkString(rs.getString("I_COMPANY")) + ":" + doString.checkString(rs.getString("I_PROJECT"));
                String i_company = doString.checkString(doString.DisplayThai(rs.getString("I_COMPANY")), "");
                String i_proj = doString.checkString(doString.DisplayThai(rs.getString("I_PROJECT")), "");
                label = doString.checkString(doString.DisplayThai(rs.getString("N_PROJECT")), "");
                selected = "";
                value = i_company + ":" + i_proj;
                if(ItemValue != null && ItemValue.indexOf("|") > 0)
                {
                    value = ItemValue.substring(0, ItemValue.indexOf("|")).trim();
                }
                if(value != null && value.trim().equalsIgnoreCase(ItemValue))
                {
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" genAllVendorList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String getBOQServiceEmployeeName(String empId)
    {
        String empName = "";
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = conn.createStatement();
            sql.delete(0, sql.length());
            sql.append(" select n_prename_th,n_nemploy_th, n_semploy_th ");
            sql.append(" from docflow:acemploy");
            sql.append(" where i_employ ='" + empId + "' ");
            rs = stmt.executeQuery(sql.toString());
            if(rs.next())
            {
                empName = doString.checkString(doString.DisplayThai(rs.getString("n_prename_th") + " " + rs.getString("n_nemploy_th") + " " + rs.getString("n_semploy_th")));
            }
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" getBOQServiceEmployeeName Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return empName;
    }

    public String genItmTypeOpenJobDropDown(String DHTML_Name, String itemValue, String DHTML_Stye)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = conn.createStatement();
            sql.delete(0, sql.length());
            sql.append(" select i_code, n_desc from lan:serv_xstd  where i_type = '64' order by i_code");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(DHTML_Name).append("' ").append(DHTML_Stye).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            String value;
            String label;
            String selected;
            for(; rs.next(); html.append("<option value='").append(value).append("' ").append(selected).append(">").append(label).append("</option>"))
            {
                value = doString.checkString(doString.DisplayThai(rs.getString("i_code")));
                label = doString.checkString(doString.DisplayThai(rs.getString("n_desc")));
                selected = "";
                if(value != null && value.equalsIgnoreCase(itemValue))
                {
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
            rs = null;
            stmt = null;
        }
        catch(Exception e)
        {
            System.out.println(" genItmTypeOpenJobDropDown Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String genVendorOpenJobDropDown(String DHTML_Name, String itemValue, String company_id, String i_project, String DHTML_Stye)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = conn.createStatement();
            sql.delete(0, sql.length());
            sql.append(" select a.i_vendor, b.bus_name from lan:serv_venprj a,lan:stpvendr b  where a.i_" +
"company = '"
 + company_id + "'" + " and a.i_project = '" + i_project + "'" + " and a.i_type = '01'" + " and a.i_vendor = b.vend_code" + " order by b.bus_name");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(DHTML_Name).append("' ").append(DHTML_Stye).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            String value;
            String label;
            String selected;
            for(; rs.next(); html.append("<option value='").append(value).append("' ").append(selected).append(">").append(value).append(" - ").append(label).append("</option>"))
            {
                value = doString.checkString(doString.DisplayThai(rs.getString("i_vendor")));
                label = doString.checkString(doString.DisplayThai(rs.getString("bus_name")));
                selected = "";
                if(value != null && value.equalsIgnoreCase(itemValue))
                {
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
            rs = null;
            stmt = null;
        }
        catch(Exception e)
        {
            System.out.println(" genVendorOpenJobDropDown Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String genAreaBOQDropDown(String DHTML_Name, String itemValue, String DHTML_Stye)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = conn.createStatement();
            sql.append(" select i_code, n_desc  from lan:serv_xstd  where i_type='08' ");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(DHTML_Name).append("' ").append(DHTML_Stye).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            String value;
            String label;
            String selected;
            for(; rs.next(); html.append("<option value='").append(value).append("' ").append(selected).append(">").append(value).append(" - ").append(label).append("</option>"))
            {
                value = doString.checkString(doString.DisplayThai(rs.getString("i_code")));
                label = doString.checkString(doString.DisplayThai(rs.getString("n_desc")));
                selected = "";
                if(value != null && value.equalsIgnoreCase(itemValue))
                {
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
            rs = null;
            stmt = null;
        }
        catch(Exception e)
        {
            System.out.println(" genVendorList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String getUserWhoBOQ(String userId)
    {
        String empPosition = "";
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = conn.createStatement();
            sql.delete(0, sql.length());
            sql.append(" select user_who  from lan:useracl  where user_acl ='S'  and user_id = '" + userId + "'");
            rs = stmt.executeQuery(sql.toString());
            if(rs.next())
            {
                empPosition = doString.checkString(doString.DisplayThai(rs.getString("user_who")));
            }
            rs.close();
            stmt.close();
            rs = null;
            stmt = null;
        }
        catch(Exception e)
        {
            System.out.println(" genBOQGroupList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return empPosition;
    }

    public String genBOQGroupDropDown(String DHTML_Name, String ItemValue, String DHTML_Stye)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = conn.createStatement();
            sql.delete(0, sql.length());
            sql.append("select i_group,n_itmjob from lan:serv_infboq where i_type = '00' and i_seq = '0000' order by i_group");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(DHTML_Name).append("' ").append(DHTML_Stye).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            String value;
            String label;
            String selected;
            for(; rs.next(); html.append("<option value='").append(value).append("' ").append(selected).append(">").append(value).append(" - ").append(label).append("</option>"))
            {
                value = doString.checkString(doString.DisplayThai(rs.getString("i_group")));
                label = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")));
                selected = "";
                if(value != null && value.equalsIgnoreCase(ItemValue))
                {
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
            rs = null;
            stmt = null;
        }
        catch(Exception e)
        {
            System.out.println(" genBOQGroupList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String genBOQGroupDropDown(String DHTML_Name, String ItemValue, String DHTML_Stye, String itmType)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = conn.createStatement();
            sql.delete(0, sql.length());
            if (itmType.equals("")) {
            	sql.append("select i_group,n_itmjob from lan:serv_infboq where i_type = '00' and i_seq = '0000' order by i_group");
            } else {
            	sql.append("select distinct a.i_group, a.n_itmjob from lan:serv_infboq a, lan:serv_infboq b where a.i_type = '00' and a.i_seq = '0000' and a.i_group = b.i_group and b.i_itmtype = '"+itmType+"' order by a.i_group");
            }
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(DHTML_Name).append("' ").append(DHTML_Stye).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            String value;
            String label;
            String selected;
            for(; rs.next(); html.append("<option value='").append(value).append("' ").append(selected).append(">").append(value).append(" - ").append(label).append("</option>"))
            {
                value = doString.checkString(doString.DisplayThai(rs.getString("i_group")));
                label = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")));
                selected = "";
                if(value != null && value.equalsIgnoreCase(ItemValue))
                {
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
            rs = null;
            stmt = null;
        }
        catch(Exception e)
        {
            System.out.println(" genBOQGroupList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }
    
    
    public String genBOQTypeDropdown(String DHTML_Name, String iGroup, String itemValue, String params, boolean allType)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        boolean allProject = false;
        try
        {
            stmt = conn.createStatement();
            sql.append(" select i_type,n_itmjob  from lan:serv_infboq  where i_group = '" + iGroup + "'").append(" and i_type != '00' ").append(" and i_seq = '0000'").append(" order by i_type ");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(DHTML_Name).append("' ").append(params).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            for(int line = 0; rs.next(); line++)
            {
                String value = doString.checkString(rs.getString("i_type"), "");
                String label = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")), "");
                String selected = "";
                if(value != null && value.equalsIgnoreCase(itemValue))
                {
                    selected = " selected ";
                }
                if(line == 0 && allType)
                {
                    html.append("<option value='ALL' " + (value.equalsIgnoreCase("ALL") ? "selected" : "") + ">" + Constants.LISTBOX_ALLTYPE_LABEL + "</option>");
                }
                html.append("<option value='").append(value).append("' ").append(selected).append(">").append(value).append(" - ").append(label).append("</option>");
            }

            html.append("</select>");
            rs.close();
            stmt.close();
            rs = null;
            stmt = null;
        }
        catch(Exception e)
        {
            System.out.println(" genBOQTypeList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    
    
    public String genBOQTypeDropdown(String DHTML_Name, String iGroup, String itemValue, String params, boolean allType, String itmType)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        boolean allProject = false;
        try
        {
            stmt = conn.createStatement();
            if (itmType.equals("")) {
            	sql.append(" select i_type,n_itmjob  from lan:serv_infboq  where i_group = '" + iGroup + "'")
	            	.append(" and i_type != '00' ")
	            	.append(" and i_seq = '0000'")
	            	.append(" order by i_type ");            	
            } else {
	            sql.append(" select distinct a.i_type, a.n_itmjob from lan:serv_infboq a, lan:serv_infboq b where a.i_group = '" + iGroup + "'")
		            .append(" and a.i_type != '00' ")
		            .append(" and a.i_seq = '0000'")
		            .append(" and a.i_group = b.i_group and b.i_itmtype = '"+itmType+"' order by a.i_type ");
            }
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(DHTML_Name).append("' ").append(params).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            for(int line = 0; rs.next(); line++)
            {
                String value = doString.checkString(rs.getString("i_type"), "");
                String label = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")), "");
                String selected = "";
                if(value != null && value.equalsIgnoreCase(itemValue))
                {
                    selected = " selected ";
                }
                if(line == 0 && allType)
                {
                    html.append("<option value='ALL' " + (value.equalsIgnoreCase("ALL") ? "selected" : "") + ">" + Constants.LISTBOX_ALLTYPE_LABEL + "</option>");
                }
                html.append("<option value='").append(value).append("' ").append(selected).append(">").append(value).append(" - ").append(label).append("</option>");
            }

            html.append("</select>");
            rs.close();
            stmt.close();
            rs = null;
            stmt = null;
        }
        catch(Exception e)
        {
            System.out.println(" genBOQTypeList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }
    
    public double getAmount()
    {
        double amount = 0.0D;
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = conn.createStatement();
            sql.delete(0, sql.length());
            sql.append(" select p_amount from serv_xstd  where i_type ='63' and i_code='01'");
            rs = stmt.executeQuery(sql.toString());
            if(rs.next())
            {
                amount = rs.getDouble("p_amount");
            }
            rs.close();
            stmt.close();
            rs = null;
            stmt = null;
        }
        catch(Exception e)
        {
            System.out.println(" genBOQGroupList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return amount;
    }

    public String getApproverList(String comId, String projId, String manager)
    {
		String result = "('------ กรุณาเลือก ------','',true,true)|";
        HashMap map = new HashMap();
        int num = 0;
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = conn.createStatement();
            sql.append(" select e.i_employ, e.n_prename_th, e.n_nemploy_th,e.n_semploy_th  from lan:serv" +
"_pstaff s,lan:useracl u, docflow:acemploy e  where s.com_id='"
 + comId + "' and s.proj_id ='" + projId + "'" + " and s.user_id = u.user_id and u.user_acl = 'S'");
            sql.append(" and u.user_who = '" + manager + "' and u.i_employ = e.i_employ");
            sql.append(" order by e.n_prename_th, e.n_nemploy_th");
            for(rs = stmt.executeQuery(sql.toString()); rs.next();)
            {
                num++;
                String value = doString.checkString(doString.DisplayThai(rs.getString("i_employ")));
                String n_prename_th = doString.checkString(doString.DisplayThai(rs.getString("n_prename_th")));
                String n_nemploy_th = doString.checkString(doString.DisplayThai(rs.getString("n_nemploy_th")));
                String n_semploy_th = doString.checkString(doString.DisplayThai(rs.getString("n_semploy_th")));
                String label = value + " " + n_prename_th + " " + n_nemploy_th + " " + n_semploy_th;
                result = result + "('" + label + "','" + value + "')|";
            }

            rs.close();
            rs = null;
            if(manager.equals("M") && num == 0)
            {
                manager = "Z";
                sql.delete(0, sql.length());
                sql.append(" select e.i_employ, e.n_prename_th, e.n_nemploy_th,e.n_semploy_th  from lan:serv" +
"_pstaff s,lan:useracl u, docflow:acemploy e  where s.com_id='"
 + comId + "' and s.proj_id ='" + projId + "'" + " and s.user_id = u.user_id and u.user_acl = 'S'");
                sql.append(" and u.user_who = '" + manager + "' and u.i_employ = e.i_employ");
                sql.append(" order by e.n_prename_th, e.n_nemploy_th");
                for(rs = stmt.executeQuery(sql.toString()); rs.next();)
                {
                    String value = doString.checkString(doString.DisplayThai(rs.getString("i_employ")));
                    String n_prename_th = doString.checkString(doString.DisplayThai(rs.getString("n_prename_th")));
                    String n_nemploy_th = doString.checkString(doString.DisplayThai(rs.getString("n_nemploy_th")));
                    String n_semploy_th = doString.checkString(doString.DisplayThai(rs.getString("n_semploy_th")));
                    String label = value + " " + n_prename_th + " " + n_nemploy_th + " " + n_semploy_th;
                    result = result + "('" + label + "','" + value + "')|";
                }

                rs.close();
                rs = null;
            }
            stmt.close();
            stmt = null;
        }
        catch(Exception e)
        {
            System.out.println(" getApproverList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return result;
    }
    
    
    
    public String getApproverList(String comId, String projId, String manager, String itmType)
    {
		String result = "('------ กรุณาเลือก ------','',true,true)|";
        HashMap map = new HashMap();
        int num = 0;
        String group_restrict = "";
        if (!itmType.equals("")) {
        	if (itmType.equals("01")) {
        		group_restrict = " and (u.user_group = 'A' OR u.user_group = 'I')";
        	}
        	if (itmType.equals("02")) {
        		group_restrict = " and (u.user_group = 'A' OR u.user_group = 'H')";
        	}
        }
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = conn.createStatement();
            sql.append(" select e.i_employ, e.n_prename_th, e.n_nemploy_th,e.n_semploy_th  from lan:serv" +
"_pstaff s,lan:useracl u, docflow:acemploy e  where s.com_id='"
 + comId + "' and s.proj_id ='" + projId + "'" + " and s.user_id = u.user_id and u.user_acl = 'S'");
            sql.append(" and u.user_who = '" + manager + "'" + group_restrict + " and u.i_employ = e.i_employ");
            sql.append(" order by e.n_prename_th, e.n_nemploy_th");
            for(rs = stmt.executeQuery(sql.toString()); rs.next();)
            {
                num++;
                String value = doString.checkString(doString.DisplayThai(rs.getString("i_employ")));
                String n_prename_th = doString.checkString(doString.DisplayThai(rs.getString("n_prename_th")));
                String n_nemploy_th = doString.checkString(doString.DisplayThai(rs.getString("n_nemploy_th")));
                String n_semploy_th = doString.checkString(doString.DisplayThai(rs.getString("n_semploy_th")));
                String label = value + " " + n_prename_th + " " + n_nemploy_th + " " + n_semploy_th;
                result = result + "('" + label + "','" + value + "')|";
            }

            rs.close();
            rs = null;
            if(manager.equals("M") && num == 0)
            {
                manager = "Z";
                sql.delete(0, sql.length());
                sql.append(" select e.i_employ, e.n_prename_th, e.n_nemploy_th,e.n_semploy_th  from lan:serv" +
"_pstaff s,lan:useracl u, docflow:acemploy e  where s.com_id='"
 + comId + "' and s.proj_id ='" + projId + "'" + " and s.user_id = u.user_id and u.user_acl = 'S'");
                sql.append(" and u.user_who = '" + manager + "'" + group_restrict +" and u.i_employ = e.i_employ");
                sql.append(" order by e.n_prename_th, e.n_nemploy_th");
                for(rs = stmt.executeQuery(sql.toString()); rs.next();)
                {
                    String value = doString.checkString(doString.DisplayThai(rs.getString("i_employ")));
                    String n_prename_th = doString.checkString(doString.DisplayThai(rs.getString("n_prename_th")));
                    String n_nemploy_th = doString.checkString(doString.DisplayThai(rs.getString("n_nemploy_th")));
                    String n_semploy_th = doString.checkString(doString.DisplayThai(rs.getString("n_semploy_th")));
                    String label = value + " " + n_prename_th + " " + n_nemploy_th + " " + n_semploy_th;
                    result = result + "('" + label + "','" + value + "')|";
                }

                rs.close();
                rs = null;
            }
            stmt.close();
            stmt = null;
        }
        catch(Exception e)
        {
            System.out.println(" getApproverList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return result;
    }

    public String getApproverListDropDown(String DHTML_Name, String i_approver, String manager, String DHTML_Stye)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = conn.createStatement();
            sql.append(" select e.i_employ, e.n_prename_th, e.n_nemploy_th,e.n_semploy_th  from lan:serv" +
"_pstaff s,lan:useracl u, docflow:acemploy e  where s.com_id='LH' and s.proj_id =" +
"'011' and s.user_id = u.user_id and u.user_acl = 'S'"
);
            sql.append(" and u.user_who = '" + manager + "' and u.i_employ = e.i_employ");
            sql.append(" order by e.n_prename_th, e.n_nemploy_th");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(DHTML_Name).append("' ").append(DHTML_Stye).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            String value;
            String label;
            String selected;
            for(; rs.next(); html.append("<option value='").append(value).append("' ").append(selected).append(">").append(value).append(" - ").append(label).append("</option>"))
            {
                value = doString.checkString(doString.DisplayThai(rs.getString("i_employ")));
                String n_prename_th = doString.checkString(doString.DisplayThai(rs.getString("n_prename_th")));
                String n_nemploy_th = doString.checkString(doString.DisplayThai(rs.getString("n_nemploy_th")));
                String n_semploy_th = doString.checkString(doString.DisplayThai(rs.getString("n_semploy_th")));
                label = n_prename_th + " " + n_nemploy_th + " " + n_semploy_th;
                selected = "";
                if(value != null && value.equalsIgnoreCase(i_approver))
                {
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
            rs = null;
            stmt = null;
        }
        catch(Exception e)
        {
            System.out.println(" genVendorList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String genBOQTypeList(String name, String iGroup, String value, String params)
    {
        return genBOQTypeList(name, iGroup, value, params, true);
    }

    public String genBOQTypeList(String name, String iGroup, String value, String params, boolean allType)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        boolean allProject = false;
        try
        {
            stmt = conn.createStatement();
            sql.append(" select * from lan:serv_boq where (i_group is not null) and (i_type is not null)" +
" "
).append(" and  ((i_seq is null) or (i_seq='')) and i_group='").append(iGroup).append("' ").append(" order by i_group,i_type ");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(name).append("' ").append(params).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            for(int line = 0; rs.next(); line++)
            {
                String iType = doString.checkString(rs.getString("i_type"), "");
                String nItmJob = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")), "");
                String selected = "";
                if(value != null && iType.equalsIgnoreCase(value))
                {
                    selected = " selected ";
                }
                if(line == 0 && allType)
                {
                    html.append("<option value='ALL' " + (value.equalsIgnoreCase("ALL") ? "selected" : "") + ">" + Constants.LISTBOX_ALLTYPE_LABEL + "</option>");
                }
                html.append("<option value='").append(iType).append("' ").append(selected).append(">").append(nItmJob).append("</option>");
            }

            html.append("</select>");
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" genBOQTypeList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String genINFBOQTypeList(String name, String iGroup, String value, String params)
    {
        return genINFBOQTypeList(name, iGroup, value, params, true);
    }

    public String genINFBOQTypeList(String name, String iGroup, String value, String params, boolean allType)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        boolean allProject = false;
        try
        {
            stmt = conn.createStatement();
            sql.append("SELECT * FROM lan:serv_infboq WHERE i_type != '00'").append(" AND i_seq = '0000' AND i_group = '").append(iGroup).append("'").append(" ORDER BY i_type");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(name).append("' ").append(params).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            for(int line = 0; rs.next(); line++)
            {
                String iType = doString.checkString(rs.getString("i_type"), "");
                String nItmJob = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")), "");
                String selected = "";
                if(value != null && iType.equalsIgnoreCase(value))
                {
                    selected = " selected ";
                }
                if(line == 0 && allType)
                {
                    html.append("<option value='ALL' " + (value.equalsIgnoreCase("ALL") ? "selected" : "") + ">" + Constants.LISTBOX_ALLTYPE_LABEL + "</option>");
                }
                html.append("<option value='").append(iType).append("' ").append(selected).append(">").append(nItmJob).append("</option>");
            }

            html.append("</select>");
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" genINFBOQTypeList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String genBOQItemList(String name, String iGroup, String iType, String value, String params)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        boolean allProject = false;
        try
        {
            stmt = conn.createStatement();
            sql.append(" select * from lan:serv_boq where (i_group is not null) and (i_type is not null)" +
" "
).append(" and  (i_seq is not null and i_seq<>'') and i_group='").append(iGroup).append("' ").append(" and i_type='").append(iType).append("' ").append(" order by i_group,i_type ");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(name).append("' ").append(params).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            for(int line = 0; rs.next(); line++)
            {
                String iItmJob = doString.checkString(rs.getString("i_itmjob"), "");
                String nItmJob = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")), "");
                String selected = "";
                if(value != null && iItmJob.equalsIgnoreCase(value))
                {
                    selected = " selected ";
                }
                html.append("<option value='").append(iItmJob).append("' ").append(selected).append(">").append(nItmJob).append("</option>");
            }

            html.append("</select>");
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" genBOQItemList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String genDescListbox(String name, String value, String params)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = conn.createStatement();
            sql.append(" select distinct serv_xstd.n_desc ,serv_xstd.i_code from lan:serv_xstd ").append(" where serv_xstd.i_type='03' ").append(" order by serv_xstd.i_code");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(name).append("' ").append(params).append(" >");
            int i = 0;
            String iCode;
            String nDesc;
            String val;
            String selected;
            for(; rs.next(); html.append("<option value='").append(val).append("' ").append(selected).append(">").append(iCode).append("-").append(nDesc).append("</option>"))
            {
                iCode = doString.checkString(rs.getString("i_code"), "");
                nDesc = doString.checkString(doString.DisplayThai(rs.getString("n_desc")), "");
                val = iCode + " - " + nDesc;
                selected = "";
                if(value != null && val.equalsIgnoreCase(value))
                {
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" genDescListbox Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String genNCountListBox(String name, String value, String params)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = conn.createStatement();
            sql.append(" select * from lan:serv_xstd where i_type='05' ").append(" order by i_code ");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(name).append("' ").append(params).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            String nDesc;
            String selected;
            for(; rs.next(); html.append("<option value='").append(nDesc.trim()).append("' ").append(selected).append(">").append(nDesc).append("</option>"))
            {
                String iCode = doString.checkString(rs.getString("i_code"), "");
                nDesc = doString.checkString(doString.DisplayThai(rs.getString("n_desc")), "");
                selected = "";
                if(value != null && nDesc.trim().equalsIgnoreCase(value.trim()))
                {
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" genAreaList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String genAccountListBox(String name, String value, String params)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = conn.createStatement();
            sql.append(" select * from lan:serv_infacc order by i_account ");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(name).append("' ").append(params).append(" >");
            html.append("<option value=''>" + Constants.LISTBOX_SELECT_LABEL + "</option>");
            String iCode;
            String nDesc;
            String selected;
            for(; rs.next(); html.append("<option value='").append(iCode.trim()).append("' ").append(selected).append(">").append(iCode + "|" + nDesc).append("</option>"))
            {
                iCode = doString.checkString(rs.getString("i_account"), "");
                nDesc = doString.checkString(doString.DisplayThai(rs.getString("n_account")), "");
                selected = "";
                if(value != null && iCode.trim().equalsIgnoreCase(value.trim()))
                {
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" genAccountList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public Hashtable getDocHeaderDetails(String iDocNo)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        Hashtable result = new Hashtable();
        doString str = new doString();
        try
        {
            stmt = conn.createStatement();
            sql.delete(0, sql.length());
            sql.append(" select trim(c.n_prename_th)||trim(c.n_nemploy_th)||' '||trim(c.n_semploy_th) em" +
"p_name , "
).append(" b.i_company||'-'||b.i_project||' '||b.n_project sel_project,d.i_tel ,f.ven_name" +
" , a.* "
).append(" from lan:serv_dochd a ").append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project" +
" "
).append(" left join lan:acxprjdt d on d.i_company=a.i_company and d.i_project=a.i_project" +
" "
).append(" left join lan:unit e on e.i_company=a.i_company and e.i_project=a.i_project and" +
" e.i_lock=a.i_lock and e.unit_status='OPN' "
).append(" left join lan:vendor f on f.ven_no=e.ven_no  ").append(" left join docflow:acemploy c on c.i_employ=a.i_service_employ  ").append(" where a.i_docno='").append(iDocNo).append("' ");
            rs = stmt.executeQuery(sql.toString());
            if(rs.next())
            {
                result.put("inform_emp", doString.checkString(rs.getString("emp_name"), ""));
                result.put("proj_desc", doString.checkString(rs.getString("sel_project"), ""));
                result.put("i_doc_type", doString.checkString(rs.getString("i_doc_type"), ""));
                result.put("i_company", doString.checkString(rs.getString("i_company"), ""));
                result.put("i_project", doString.checkString(rs.getString("i_project"), ""));
                result.put("n_customer", doString.checkString(rs.getString("n_customer"), ""));
                result.put("n_cust_tel", doString.checkString(rs.getString("n_cus_tel"), ""));
                result.put("i_lock", doString.checkString(rs.getString("i_lock"), ""));
                result.put("response_emp", doString.checkString(rs.getString("ven_name"), ""));
                result.put("site_tel", doString.checkString(rs.getString("i_tel"), ""));
                result.put("c_desc", doString.checkString(rs.getString("c_desc"), ""));
                result.put("f_reject", doString.checkString(rs.getString("f_reject"), ""));
                result.put("c_reject", doString.checkString(rs.getString("c_reject"), ""));
                Calendar inform = Calendar.getInstance();
                java.sql.Timestamp tmp = rs.getTimestamp("d_keyin");
                if(tmp != null)
                {
                    inform.setTime(tmp);
                    result.put("inform_date", getDateFromCalendar(inform) + " " + getTimeFromCalendar(inform));
                }
                tmp = rs.getTimestamp("d_appoint");
                if(tmp != null)
                {
                    inform.setTime(tmp);
                    result.put("d_appoint", getDateFromCalendar(inform));
                }
                tmp = rs.getTimestamp("d_est_close");
                if(tmp != null)
                {
                    inform.setTime(tmp);
                    result.put("d_est_close", getDateFromCalendar(inform));
                }
				//Modify by pradoem : 2014.11.03
				tmp = rs.getTimestamp("d_appoint_cust");
				if (tmp!=null) {
				   inform.setTime(tmp);      
				   result.put("d_appoint_cust",getDateFromCalendar(inform));
				}
            }
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" getDocHeaderDetails Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return result;
    }

    public Hashtable getInfDocHeaderDetails(String iDocNo)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        Hashtable result = new Hashtable();
        doString str = new doString();
        try
        {
            stmt = conn.createStatement();
            sql.delete(0, sql.length());
            sql.append(" select trim(c.n_prename_th)||trim(c.n_nemploy_th)||' '||trim(c.n_semploy_th) em" +
"p_name , "
).append(" b.i_company||'-'||b.i_project||' '||b.n_project sel_project,d.i_tel ,a.* ").append(" from lan:serv_infdochd a ").append(" left join lan:acxprojt b on b.i_company=a.i_company and b.i_project=a.i_project" +
" "
).append(" left join lan:acxprjdt d on d.i_company=a.i_company and d.i_project=a.i_project" +
" "
).append(" left join docflow:acemploy c on c.i_employ=a.i_service_employ  ").append(" where a.i_docno='").append(iDocNo).append("'");
            rs = stmt.executeQuery(sql.toString());
            if(rs.next())
            {
                result.put("inform_emp", doString.checkString(rs.getString("emp_name"), ""));
                result.put("proj_desc", doString.checkString(rs.getString("sel_project"), ""));
                result.put("i_doc_type", doString.checkString(rs.getString("i_doc_type"), ""));
                result.put("i_company", doString.checkString(rs.getString("i_company"), ""));
                result.put("i_project", doString.checkString(rs.getString("i_project"), ""));
                result.put("site_tel", doString.checkString(rs.getString("i_tel"), ""));
                result.put("c_desc", doString.checkString(rs.getString("c_desc"), ""));
                result.put("f_reject", doString.checkString(rs.getString("f_reject"), ""));
                result.put("c_reject", doString.checkString(rs.getString("c_reject"), ""));
                Calendar inform = Calendar.getInstance();
                java.sql.Timestamp tmp = rs.getTimestamp("d_keyin");
                if(tmp != null)
                {
                    inform.setTime(tmp);
                    result.put("inform_date", getDateFromCalendar(inform) + " " + getTimeFromCalendar(inform));
                }
                tmp = rs.getTimestamp("d_appoint");
                if(tmp != null)
                {
                    inform.setTime(tmp);
                    result.put("d_appoint", getDateFromCalendar(inform));
                }
                tmp = rs.getTimestamp("d_est_close");
                if(tmp != null)
                {
                    inform.setTime(tmp);
                    result.put("d_est_close", getDateFromCalendar(inform));
                }
            }
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" getInfDocHeaderDetails Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return result;
    }

    public String getContractorStatus(String iDocNo, String iVendor)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        String result = new String();
        doString str = new doString();
        try
        {
            stmt = conn.createStatement();
            String fItmStatus = "";
            String fReject = "";
            boolean foundRec = false;
            sql.delete(0, sql.length());
            sql.append(" select * from lan:serv_flow where f_itmstatus>='400' ").append(" and i_docno='").append(iDocNo).append("' ").append(" and i_vendor='").append(iVendor).append("' ").append(" order by f_itmstatus desc ");
            rs = stmt.executeQuery(sql.toString());
            if(rs.next())
            {
                fItmStatus = doString.checkString(rs.getString("f_itmstatus"), "");
                fReject = doString.checkString(rs.getString("f_reject"), "");
                foundRec = true;
            }
			if (fReject.equalsIgnoreCase("Y")) {
				result = doString.UnicodeToMS874("รอแก้ไข");
			} else {
				if (!foundRec) {
					result = doString.UnicodeToMS874("เอกสารใหม่");
				}
			}
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" getContractorStatus Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return result;
    }

    public String getInfContractorStatus(String iDocNo, String iVendor)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        String result = new String();
        doString str = new doString();
        try
        {
            stmt = conn.createStatement();
            String fItmStatus = "";
            String fReject = "";
            boolean foundRec = false;
            sql.delete(0, sql.length());
            sql.append(" select * from lan:serv_infflow where f_itmstatus>='400' ").append(" and i_docno='").append(iDocNo).append("' ").append(" and i_vendor='").append(iVendor).append("' ").append(" order by f_itmstatus desc ");
            rs = stmt.executeQuery(sql.toString());
            if(rs.next())
            {
                fItmStatus = doString.checkString(rs.getString("f_itmstatus"), "");
                fReject = doString.checkString(rs.getString("f_reject"), "");
                foundRec = true;
            }
			if (fReject.equalsIgnoreCase("Y")) {
				result = doString.UnicodeToMS874("รอแก้ไข");
			} else {
				if (!foundRec) {
					result = doString.UnicodeToMS874("เอกสารใหม่");
				}
			}
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" getInfContractorStatus Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return result;
    }

    public Hashtable getCustomerDetails(String iCompany, String iProject, String iLock)
    {
        return getCustomerDetails(iCompany, iProject, iLock, "");
    }

    public Hashtable getCustomerDetails(String iCompany, String iProject, String iLock, String iHouse)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        Hashtable result = new Hashtable();
        try
        {
            stmt = conn.createStatement();
            sql.delete(0, sql.length());
            sql.append(" select a.i_lor,a.i_model,a.i_house,a.i_lock,b.i_exp_intent1,b.i_cus_intent1,b.d_close_law from lan:acxlckmd a "
).append(" left join lan:acscontr b on b.i_company=a.i_company and b.i_project=a.i_project" +
" "
).append(" and b.i_lor=a.i_lor and b.f_contr is null ").append(" where a.i_company='").append(iCompany).append("' ").append(" and a.i_project='").append(iProject).append("' ");
            if(iHouse.length() > 0)
            {
                sql.append(" and a.i_house='").append(iHouse).append("' ");
            }
            if(iLock.length() > 0)
            {
                sql.append(" and a.i_lock='").append(iLock).append("' ");
            }
            rs = stmt.executeQuery(sql.toString());
            String iCustomer = "";
            String iLor = "";
            if(rs.next())
            {
                result.put("i_model", doString.checkString(rs.getString("i_model"), ""));
                result.put("i_house", doString.checkString(rs.getString("i_house"), ""));
                result.put("i_lock", doString.checkString(rs.getString("i_lock"), ""));
                result.put("i_lor", doString.checkString(rs.getString("i_lor"), ""));
                result.put("close_date", doString.checkString(rs.getString("d_close_law")));
                iCustomer = doString.checkString(rs.getString("i_cus_intent1"), "");
                if(iCustomer.length() <= 0)
                {
                    iCustomer = doString.checkString(rs.getString("i_exp_intent1"), "");
                }
                result.put("i_customer", iCustomer);
                java.sql.Timestamp dCloseLaw = rs.getTimestamp("d_close_law");
                if(dCloseLaw == null)
                {
                    result.put("gurantee_ok", "no");
                    result.put("gurantee_desc", "-");
                    result.put("gurantee_date", "-");
                } else
                {
                    Calendar gurantee = Calendar.getInstance();
                    gurantee.setTime(dCloseLaw);
                    gurantee.add(1, 1);
                    result.put("gurantee_ok", "yes");
                    if(Calendar.getInstance().after(gurantee))
                    {
						result.put("gurantee_desc",doString.UnicodeToMS874("หมดประกัน"));
                    } else
                    {
						result.put("gurantee_desc",doString.UnicodeToMS874("อยู่ระหว่างประกัน"));
                    }
                    result.put("gurantee_date", getDateFromCalendar(gurantee));
                }
                result.put("found_cust", "YES");
            }
            rs.close();
            sql.delete(0, sql.length());
            sql.append("select * from lan:acxcusto where i_customer='").append(iCustomer).append("' ");
            rs = stmt.executeQuery(sql.toString());
            if(rs.next())
            {
                String custName = doString.checkString(rs.getString("n_prename"), "");
                custName = custName + doString.checkString(rs.getString("n_ncustomer"), "");
                custName = custName + " " + doString.checkString(rs.getString("n_scustomer"), "");
                result.put("n_customer", custName);
                String nCustTel = doString.checkString(rs.getString("a_id_tel"), "");
                String tel = doString.checkString(rs.getString("a_wk_tel"), "");
                if(tel.length() > 0)
                {
                    nCustTel = nCustTel + (nCustTel.length() <= 0 ? tel : " , " + tel);
                }
                tel = doString.checkString(rs.getString("a_etc_tel"), "");
                if(tel.length() > 0)
                {
                    nCustTel = nCustTel + (nCustTel.length() <= 0 ? tel : " , " + tel);
                }
                result.put("n_cust_tel", nCustTel);
            }
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" getCustomerDetails Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return result;
    }

    public String checkAmountJobdetail(String i_docno, String i_vendor, String i_itmjob, double wagePrice, double wageUnit, 
            double goodsPrice, double goodsUnit)
    {
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        double q_wage_unit = 0.0D;
        double z_wage_price = 0.0D;
        double q_good_unit = 0.0D;
        double z_good_price = 0.0D;
        try
        {
            stmt = conn.createStatement();
            sql.append(" select * from lan:serv_infdocdt where i_docno='" + i_docno + "' and i_vendor = '" + i_vendor + "' and i_itmjob = '" + i_itmjob + "'  ");
            rs = stmt.executeQuery(sql.toString());
            if(rs.next())
            {
                q_wage_unit = rs.getDouble("q_wage_unit");
                z_wage_price = rs.getDouble("z_wage_price");
                q_good_unit = rs.getDouble("q_good_unit");
                z_good_price = rs.getDouble("z_good_price");
            }
            rs.close();
            stmt.close();
            if((q_wage_unit != wageUnit) | (z_wage_price != wagePrice) | (z_good_price != goodsPrice) | (q_good_unit != goodsUnit))
            {
                return "*";
            }
        }
        catch(Exception e)
        {
            System.out.println(" genVendorList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return "";
    }

    public String genAmountCutListBox(String name, String value, String params)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        try
        {
            stmt = conn.createStatement();
            sql.append(" select p_amount,n_desc from lan:serv_xstd where i_type='09' ");
            rs = stmt.executeQuery(sql.toString());
            html.append("<select name='").append(name).append("' ").append(params).append(" >");
            html.append("<option value=''>--------</option>");
            String nDesc;
            String selected;
            for(; rs.next(); html.append("<option value='").append(nDesc.trim()).append("' ").append(selected).append(">").append(nDesc).append("</option>"))
            {
                String iCode = doString.checkString(rs.getString("p_amount"), "");
                nDesc = doString.checkString(doString.DisplayThai(rs.getString("n_desc")), "");
                selected = "";
                if(value != null && nDesc.trim().equalsIgnoreCase(value.trim()))
                {
                    selected = " selected ";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
        }
        catch(Exception e)
        {
            System.out.println(" genAreaList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String genWrongTypeCutList(String name, String value, String params, String itemId)
    {
        StringBuffer html = new StringBuffer();
        StringBuffer sql = new StringBuffer();
        Statement stmt = null;
        ResultSet rs = null;
        value = doString.checkString(value);
        try
        {
            stmt = conn.createStatement();
            rs = stmt.executeQuery("SELECT f.i_seq, s.i_code, s.n_desc FROM lan:serv_inffix f, lan:serv_xstd s WHERE f.i_itmjob = '"+itemId+"' AND f.i_cause = s.i_code AND s.i_type = '10' ORDER BY f.i_seq");
            if (rs.next() == true) {
                sql.append("SELECT f.i_seq, s.i_code, s.n_desc FROM lan:serv_inffix f, lan:serv_xstd s WHERE f.i_itmjob = '"+itemId+"' AND f.i_cause = s.i_code AND s.i_type = '10' ORDER BY f.i_seq");
            } else {
                sql.append("SELECT i_code, n_desc FROM lan:serv_xstd WHERE i_type = '10' ORDER BY i_code");
            }
            rs.close();
            rs=null;
            html.append("<select name='").append(name).append("' ").append(params).append(" >");
			html.append("<option value=''>- เลือก -</option>");	
            String code;
            String nDesc;
            String selected;
            rs = stmt.executeQuery(sql.toString());
            for(; rs.next(); html.append("<option value='").append(code).append("' ").append(selected).append(">").append(nDesc).append("</option>"))
            {
                code = doString.checkString(rs.getString("i_code"));
                nDesc = doString.checkString(doString.DisplayThai(rs.getString("n_desc")), "");
                selected = "";
                if(value != null && code.equalsIgnoreCase(value))
                {
                    selected = " selected";
                }
            }

            html.append("</select>");
            rs.close();
            stmt.close();
            rs=null;
            stmt=null;
        }
        catch(Exception e)
        {
            System.out.println(" genWrongTypeCutList Error : " + e.getMessage());
        }
        finally
        {
            try
            {
                if(rs != null)
                {
                    rs.close();
                }
                if(stmt != null)
                {
                    stmt.close();
                }
            }
            catch(Exception ex) { }
        }
        return html.toString();
    }

    public String getDateFromCalendar(Calendar cal)
    {
        String result = "";
        if(cal == null)
        {
            return "-";
        }
        int year = cal.get(1);
        if(year < 2400)
        {
            year += 543;
        }
        doString str = new doString();
        result = str.createID(cal.get(5), 2);
        result = result + "/" + str.createID(cal.get(2) + 1, 2);
        result = result + "/" + year;
        return result;
    }

    public String getTimeFromCalendar(Calendar cal)
    {
        String result = "";
        if(cal == null)
        {
            return "-";
        } else
        {
            doString str = new doString();
            result = str.createID(cal.get(11), 2);
            result = result + ":" + str.createID(cal.get(12), 2);
            return result;
        }
    }

    public String joinContactAndOwner(String contact, String owner)
    {
        String result = "";
        contact = doString.checkString(contact, "");
        owner = doString.checkString(owner, "");
        result = contact;
        if(contact.length() > 0 && owner.length() > 0)
        {
            result = result + " / ";
        }
        result = result + doString.checkString(owner, "");
        if(result.length() <= 0)
        {
            result = "-";
        }
        return result;
    }
    
	//Add by pradoem	==========================================================================================//
	public String genIPV_BOQTypeList(String name, String iGroup, String value, String params) {
		 return  genIPV_BOQTypeList(name,iGroup,value,params,true);
	}
	//==========================================================================================//
	public String genIPV_BOQTypeList(String name,String iGroup,String value,String params,boolean allType) {
		 StringBuffer html = new StringBuffer();
		 StringBuffer sql = new StringBuffer();
		 Statement stmt = null;
		 ResultSet rs = null;
		 boolean allProject = false;
	     
		 try {
			stmt = conn.createStatement();
		 	
			 sql.append(" Select i_group,i_type,n_itmjob,i_itmjob  From lan:ipv_qcboq ")
			 	.append("  Where i_group ='").append(iGroup).append("'")
			   .append("  and i_type is not null  ")
			   .append("  and i_seq is null  ")
			   .append(" Order by i_group,i_type,n_itmjob ");
			 rs = stmt.executeQuery(sql.toString());

			 //-------============== Generate List box ===================------//
			 html.append("<select name='").append(name).append("' ").append(params).append(" >");		  
			 html.append("<option value=''>"+Constants.LISTBOX_SELECT_LABEL+"</option>");
		     		        		     
			 int line = 0;
			 while (rs.next()) {
				String iType = doString.checkString(rs.getString("i_type"),"");
				String nItmJob = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")),"");
				String selected = "";
				if (value!=null && iType.equalsIgnoreCase(value)) {
				   selected = " selected "; 
				}	
	        
				//--=================== Set All Type Option to Listbox ===================---//
				if (line==0 && allType) html.append("<option value='ALL' "+(value.equalsIgnoreCase("ALL") ? "selected" : "")+">"+Constants.LISTBOX_ALLTYPE_LABEL+"</option>");	        
				
				html.append("<option value='").append(iType).append("' ").append(selected).append(">")
						.append(nItmJob).append("</option>");	
				line++;	         
			 } // end while		     
			 html.append("</select>");
			 //----=====================================================----//
		           		     
			 rs.close();
			 stmt.close();

		 } catch (Exception e) {
			 System.out.println(" genBOQTypeList Error : "+e.getMessage());
		 } finally {
			 try {
				if (rs!=null) rs.close();
				if (stmt!=null) stmt.close();
			 } catch (Exception ex) {}
		 }     
		return html.toString();		 
	}	
	

	
	//==========================================================================================//
	 //Create by pradoem 2014.10.20 For Group items
	public String genIPV_BOQGroupList(String name,String value,String params) {
		 StringBuffer html = new StringBuffer();
		 StringBuffer sql = new StringBuffer();
		 Statement stmt = null;
		 ResultSet rs = null;
		 boolean allProject = false;
	     
		 try {
			stmt = conn.createStatement();
	 	
			 sql.append(" Select i_group,n_itmjob,i_itmjob From lan:ipv_qcboq ")
			   .append("  Where i_group is not null    ")
			   .append("  and i_type is  null  ")
			   .append("  and i_seq is null  ")
			   .append(" Order by i_group,n_itmjob ");
			 rs = stmt.executeQuery(sql.toString());
		     

			 //-------============== Generate List box ===================------//
			 html.append("<select name='").append(name).append("' ").append(params).append(" >");	
			 html.append("<option value=''>"+Constants.LISTBOX_SELECT_LABEL+"</option>");
		     	     		     
			 while (rs.next()) {
				String iGroup = doString.checkString(rs.getString("i_group"),"");
				String nItmJob = doString.checkString(doString.DisplayThai(rs.getString("n_itmjob")),"");
				String selected = "";
				if (value!=null && iGroup.equalsIgnoreCase(value)) {
				   selected = " selected "; 
				}		        
		        
				html.append("<option value='").append(iGroup).append("' ").append(selected).append(">")
						.append(nItmJob).append("</option>");		        
			 } // end while		     
			 html.append("</select>");
			 //----=====================================================----//
		           		     
			 rs.close();
			 stmt.close();

		 } catch (Exception e) {
			 System.out.println(" genBOQGroupList Error : "+e.getMessage());
		 } finally {
			 try {
				if (rs!=null) rs.close();
				if (stmt!=null) stmt.close();
			 } catch (Exception ex) {}
		 }	     
		return html.toString();		 
	}	
    
    
}