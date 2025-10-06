<%@page contentType="text/html;charset=TIS620"%>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="com.lh.util.doString" %>
<%@ page import="com.lh.util.DateUtil" %>
<%@ page import="serv.common.*" %>
<%@ include file="confirmLogin.jsp" %>
<%!
// Caching the DataSource - It is obtained in the jspInit() method
private javax.sql.DataSource ds = null;
private String dsName = Constants.JDBC_LAN;
private void getDS() throws NamingException {
	// Note the new Initial Context Factory interface available in WebSphere 4.0
	Hashtable parms = new Hashtable();
	parms.put(
		Context.INITIAL_CONTEXT_FACTORY,
		"com.ibm.websphere.naming.WsnInitialContextFactory");
	InitialContext ctx = new InitialContext(parms);

	// Perform a naming service lookup to get the DataSource object.
	ds = (javax.sql.DataSource) ctx.lookup(dsName);
	ctx.close();

}

// This Happens Once and is Reused
public void jspInit() {
	try {
		getDS();
	} catch (Exception es) {
		es.printStackTrace();
	}
}
%>
<HTML>
<HEAD>
<TITLE>สรุปภาพรวมประเมินผล QC Checklist</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=TIS-620">
<LINK rel="StyleSheet" href="SERV_Style.css" type="text/css">
<script language="javascript" src="script_fx.js"></script>
<base target="_self">
<script>
function varitext(text)
	{	text=document
		print(text)
	}

var  max_height = screen.availHeight;
var  max_width = screen.availWidth
var  frame_width = 170;
var  frame_height = 20;
var  show_div   = "<div id='show' style='position:absolute;top:-"+(frame_height+100)+";left=100;z-index:9;'>";
		show_div += "<table bgcolor=#0000FF cellpadding=0 cellspacing=1 width="+frame_width+" height="+frame_height+">";
		show_div += "<tr><td><table bgcolor=#FFFFDD width=100% height=100% style='font-size:8pt'>";
		show_div += "<tr><td align=center><div id='message'></div></td></tr></table>";
		show_div += "</td></tr></table></div>";
document.write(show_div);

function popup(msg)
{
  now_top=document.body.scrollTop+20+event.y; 
  now_left=document.body.scrollLeft+20+event.x;
  if (now_top+frame_height<max_height)
      { show.style.top=now_top;  }
  else
      { show.style.top=(now_top-(now_top-max_height))-150;  }
show.style.top=now_top;

  if (now_left+frame_width<max_width)
      { show.style.left=now_left-20;  }
  else
      { show.style.left=now_left-(now_left-max_width)-(frame_width+30);  }
  message.innerHTML=msg;

  window.status=show.style.top;
}

function hide()
{
  show.style.top=-(frame_height+100);
}
	function pleasewait() {
		if (document.getElementById) { // DOM3 = IE5, NS6
			document.getElementById ('hidepage').style.visibility = 'hidden';
		} else {
			if (document.layers) { // Netscape 4
				document.hidepage.visibility = 'hidden';
			}  else { // IE 4 document.all.hidepage.style.visibility = 'hidden';
			}
		}
	}
</script>
</HEAD>
<BODY leftMargin=0 topMargin=0 marginheight="0" marginwidth="0" onLoad="pleasewait()">
<div id="hidepage" style="position: absolute; left:300px; top:100px; background-color: white; layer-background-color: white; height: 10%; width: 30%;">
<table width=100%><tr><td valign=middle align=middle><div id="a1">Page loading ... Please wait...</div></td></tr></table></div>
<FORM NAME="frmRep" ACTION="SERV_QCByDoc.jsp" METHOD="POST">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
		<td width="100%" class="BD">
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="50%" class="bigh"><img border="0" src="images/i_home.gif"
					align="absmiddle" width="20" height="20">&nbsp;สรุปรวมรายการตรวจสอบคุณภาพงานซ่อม ประจำเดือน</td>
				<td width="50%" align="right"></td>
			</tr>
		</table>
		<br style="font-size: 10pt">
<%
String chkMonth = doString.checkString(request.getParameter("chkMonth"),"0");
String chkYear = doString.checkString(request.getParameter("chkYear"),"0");
String setId = doString.checkString(request.getParameter("Set"),"1");
String comId = "";
String projId = "";
String docNo = "";
String qc_name = "";

String thaiMonth[] = new String[] {"","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฏาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"};
String shortMonth[] = new String[] {"","ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค."};
String showMonth = thaiMonth[Integer.parseInt(chkMonth)];
String showYear = Integer.toString(Integer.parseInt(chkYear)+543);
String groupId = "";
int num_group = 0;
Comparator comparator = new GroupComparator();
String startDate = "";
String endDate = "";
String startDay = "";
String startMnth = "";
String startYear = "";
String endDay = "";
String endMnth = "";
String endYear = "";
String code = "";
double mark = 0;
double score = 0;
double jbscore = 0;
double sum_score = 0;
double sum_jbscore = 0;
int line = 0;
String optionSelected = "";
String bgcolor = "";
String mnthDate = chkYear+"-"+chkMonth+"-01";
StringBuffer sql = new StringBuffer();
Vector group_list = new Vector(11);
SERV_CommonData common = null;		
Connection conn = null;
Statement stmt = null;
Statement ustmt = null;
ResultSet rs = null;
ResultSet rsDoc = null;
try {
	if (ds == null)
		getDS();
	conn = ds.getConnection();
	conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
	conn.setAutoCommit(true);
	stmt = conn.createStatement();
	ustmt = conn.createStatement();
	
	common = new SERV_CommonData(conn);
	rs = stmt.executeQuery("SELECT COUNT(*) FROM lan:serv_qcgrp WHERE i_set = '"+setId+"' AND i_pgroup IS NULL");
	if (rs != null) {
		if (rs.next() == true) {
			num_group = rs.getInt(1);
		}
		rs.close();
		rs=null;
	}
%>

		<input type="hidden" name="chkMonth" value="<%=chkMonth%>">
		<input type="hidden" name="chkYear" value="<%=chkYear%>">
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td class="item_tab1"><img border="0" src="images/i_i.gif"
					align="absmiddle" width="20" height="20"></td>

				<td class="item_tab2" width="200">ช่วงเวลา</td>
				<td class="item_tab3"></td>
				<td>&nbsp;</td>
			</tr>
		</table>


		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="5" valign="top"><img border="0" src="images/Corn01.gif"
					width="5" height="5"></td>
				<td class="frmTop">&nbsp;</td>
				<td width="5" valign="top" align="right"><img border="0"
					src="images/Corn02.gif" width="5" height="5"></td>
			</tr>
		</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td width="100%" class="frmLR" align="center">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td class="item ; dotline01" height="22" colspan="4">
	เดือน : <%=showMonth%> &nbsp; พ.ศ. <%=showYear%></td>
  </tr>
	<%
		doString str = new doString();
	  String[] projList = request.getParameterValues("sel_proj");
  	  String queryProject = "";
	  String i_proj = "";
		line = 0;

	  if (projList!=null) {
		  for (int i=0;i<projList.length;i++) {
				 String proj = doString.checkString(projList[i],"");  
				 if (proj.trim().length()>=6) {
					 if (queryProject.trim().length()>0) queryProject += " or ";
					 queryProject += " (i_company='"+proj.substring(0,2)+"' and i_project='"+proj.substring(3,6)+"') ";
				 }


				  %><input type="hidden" name="sel_proj" value="<%=proj%>"><%


				//---============= get Project Details ===============----//
				sql.delete(0,sql.length()); 
				sql.append(" select * from lan:acxprojt ")
					  .append(" where i_company='").append(proj.length()>=6 ? proj.substring(0,2) : "").append("' ")
					  .append(" and i_project='").append(proj.length()>=6 ? proj.substring(3,6) : "").append("' ");
				rs = stmt.executeQuery(sql.toString());
				while (rs.next()) {
					 String nProject = doString.checkString(doString.DisplayThai(rs.getString("n_project")),"");
					 String iProj = str.replace(proj,":","-");	

					 if (line==0) {
						 %><tr><td class="item ; dotline01" height="22" width="10%">โครงการ :</td><%
					 } else if (line%3==0 && line!=0) {
						 %><tr><td class="item ; dotline01" height="22" width="10%">&nbsp;</td><%
					}

				    %><td height="22" width="30%" class="dotline01"><%=iProj%> <%=nProject%></td><%

					if (line%3==2) {
						%></tr><%
					}

					line++;
				} // end while
				rs.close();

		  } // end for

		  while (line%3!=0) {
			  %><td height="22" width="30%" class="dotline01">&nbsp;</td><%
			  line++;

		 	  if (line%3==0) {
		 	  	out.print("</tr>");
			  }
		  }

	  } else {
		  queryProject = " i_company='' and i_project='' ";
	  }
%>

  <tr>
    <td class="item ; dotline01" height="22" colspan="4">แบบชุด QC :&nbsp;&nbsp;
	<select size="1" name="Set" class="box" style="width:100px" onChange="frmRep.submit()">
<%
	rs = stmt.executeQuery("SELECT DISTINCT i_set FROM lan:serv_qcgrp ORDER BY i_set");
	if (rs != null) {
		while (rs.next() == true) {
				optionSelected = "";
				code = doString.checkString(rs.getString("I_SET"));
				if (code.equals(setId)) {
					optionSelected = "selected";
				}
%>
				<option value="<%=code%>" <%=optionSelected%>><%=code%></option>
<%
		}// end while
		rs.close();
		rs=null;
	}
%>
	</select>
	</td>
  </tr>
</table>

</td>
  </tr>
</table>

		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="5" valign="bottom"><img border="0"
					src="images/Corn03.gif" width="5" height="5"></td>
				<td class="frmBottom">&nbsp;</td>
				<td width="5" valign="bottom" align="right"><img border="0"
					src="images/Corn04.gif" width="5" height="5"></td>
			</tr>
		</table>

		<br style="font-size: 10pt">
		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td class="item_tab1"><img border="0" src="images/i_i.gif"
					align="absmiddle" width="20" height="20"></td>

				<td class="item_tab2" width="200">สรุปภาพรวมประเมินผล Q.C. Checklist</td>
				<td class="item_tab3"></td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
			</tr>
		</table>


		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="5" valign="top" bgcolor="#D7E6FF"><img border="0"
					src="images/Corn01.gif" width="5" height="5"></td>
				<td class="frmTop" bgcolor="#D7E6FF">&nbsp;</td>
				<td width="5" valign="top" align="right" bgcolor="#D7E6FF"><img
					border="0" src="images/Corn02.gif" width="5" height="5"></td>
			</tr>
		</table>


		<table border="0" width="100%" cellspacing="0" cellpadding="0">
			<tr>
				<td width="100%" class="frmL">
				
              <table border="0" width="100%" cellspacing="0" cellpadding="0">
                <tr> 
                  <td rowspan="2" height="4" class="col_name">เลขที่ใบแจ้งซ่อม</td>
                  <td rowspan="2" height="4" class="col_name">QC</td>                  
                  <td colspan="<%=num_group%>" align="center" valign="middle" class="col_name">Score 
                    % </td>
                  <td rowspan="2" height="4" class="col_name">ค่าเฉลี่ยรวม</td>
                </tr>
                <tr> 
<%
	rs = stmt.executeQuery("SELECT i_group, description FROM lan:serv_qcgrp WHERE i_set = '"+setId+"' AND i_pgroup IS NULL ORDER BY i_group");
	if (rs != null) {
		while (rs.next() == true) {
			code = doString.checkString(rs.getString(1));
			QCGroup group = new QCGroup();
			group.setId(code);
			group_list.addElement(group);
%>
                  <td width="6%" align="center" valign="middle" class="col_name"><A HREF="" onmouseover="popup('<%=doString.DisplayThai(rs.getString(2))%>');"  onmouseout="hide();">หมวดที่ <%=code%></a></td>
<%
		}// end while
		rs.close();
		rs=null;
	}
	Collections.sort(group_list, comparator);
%>
                </tr>





<%
	line = 0;
	if (projList!=null) {
		for (int i=0;i<projList.length;i++) {
			String proj = doString.checkString(projList[i],"");
			if (proj.trim().length()>=6) {
				comId = proj.substring(0,2);
				projId = proj.substring(3,6);
				rsDoc = ustmt.executeQuery("SELECT i_docno FROM lan:serv_dochd WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND qc_status = 'CLS' AND qc_month = '"+mnthDate+"' AND (f_status = 'OPN' OR f_status = 'CLS')");
				if (rsDoc != null) {
					while (rsDoc.next() == true) {
						docNo = doString.checkString(rsDoc.getString("I_DOCNO"));
						qc_name = "&nbsp;";
						rs = stmt.executeQuery("SELECT i_employ FROM lan:serv_qchd WHERE i_docno = '"+docNo+"'");
						if (rs != null) {
							if (rs.next() == true) {
								qc_name = doString.checkString(rs.getString("I_EMPLOY"));
							}
							rs.close();
							rs=null;
						}

						line++;
						bgcolor = ((line%2) == 0) ? "FAFAFA" : "FFFFFF";
%>
                <tr bgcolor="<%=bgcolor%>"> 
                  <td width="18%" height="1" align="center" class="dotline"><%=docNo%></td>
                  <td width="10%" height="1" align="center" class="dotline"><%=qc_name%></td>
<%
						sum_score = 0;
						sum_jbscore = 0;
						for(int g = 0 ; g < group_list.size() ; g++) {
							QCGroup group = (QCGroup)group_list.get(g);
							score = 0;
							jbscore = 0;
							mark = 0;
							if (group != null) {
								groupId = group.getId();
								rs = stmt.executeQuery("SELECT z_score, z_jbscore, z_mark FROM lan:serv_qcscore WHERE i_company = '"+comId+"' AND i_project = '"+projId+"' AND i_docno = '"+docNo+"' AND i_group = '"+groupId+"'");
								if (rs != null) {
									if (rs.next() == true) {
										mark = rs.getDouble("Z_MARK");
										score = rs.getDouble("Z_SCORE");
										jbscore = rs.getDouble("Z_JBSCORE");
									}
									rs.close();
									rs=null;
								}
								group.addScore(score);
								group.addTotscore(jbscore);
							}
							sum_score += score;
							sum_jbscore += jbscore;
%>
							<td width="6%" align="center" valign="middle" class="dotline"><%=doString.displayNumber("###.00", mark)%></td>
<%
						}// end for group
						mark = 0;
						if (sum_jbscore > 0) {
							mark = (sum_score * 100.00)/sum_jbscore;
						}
%>
                  <td width="6%" align="center" valign="middle" class="dotline"><%=doString.displayNumber("###.00", mark)%></td>
                </tr>
<%
					}// end while
					rsDoc.close();
					rsDoc=null;
				}
			}
		}// end for proj
	}
%>
                <tr> 
                  <td width="18%" height="1" align="center" class="dotline ; item"></td>
                  <td width="10%" height="1" align="center" class="dotline ; item">ค่าเฉลี่ยรวม</td>         
<%
	sum_score = 0;
	sum_jbscore = 0;
	for(int g = 0 ; g < group_list.size() ; g++) {
		QCGroup group = (QCGroup)group_list.get(g);
		score = 0;
		jbscore = 0;
		mark = 0;
		if (group != null) {
			score = group.getScore();
			jbscore = group.getTotscore();
		}
		mark = 0;
		if (jbscore > 0) {
			mark = (score * 100.00)/jbscore;
		}
		sum_score += score;
		sum_jbscore += jbscore;
%>
		<td width="6%" align="center" valign="middle" class="dotline ; item"><%=doString.displayNumber("###.00", mark)%></td>
<%
	}// end for
	mark = 0;
	if (sum_jbscore > 0) {
		mark = (sum_score * 100.00)/sum_jbscore;
	}
%>
                  <td width="6%" align="center" valign="middle" class="dotline ; item"><%=doString.displayNumber("###.00", mark)%></td>
                </tr>
	              </table>
				</td>
			</tr>
		</table>
				<table border="0" width="100%" cellspacing="0" cellpadding="0">
				  <tr>
				    <td width="5" valign="bottom"><img border="0" src="images/Corn03.gif" width="5" height="5"></td>
				    <td class="frmBottom">&nbsp;</td>
				    <td width="5" valign="bottom" align="right"><img border="0" src="images/Corn04.gif" width="5" height="5"></td>
				  </tr>
				</table>			
<%
stmt.close();
ustmt.close();
conn.close();
stmt = null;
ustmt = null;
conn = null;
} catch (Exception e) {
	System.out.println("ERROR SERV_QCByDoc.jsp : " + e.getMessage());
	throw new ServletException(e.getMessage());
} finally {
	// Clean up.
	try {
		if (rs != null)
			rs.close();
		if (stmt != null)
			stmt.close();
		if (ustmt != null)
			ustmt.close();
		if (conn != null)
			conn.close();
	} catch (SQLException ignore) {
	}
}
%> <br style="font-size: 10pt">
		<table border="0" width="100%" cellspacing="0" cellpadding="0"
			height="30">
			<tr>
				<td class="act_tab1"></td>
				<td width="80" class="act_tab2">&nbsp;</td>
				<td class="act_tab3"></td>
				<td class="act_tab4"><a href="javascript:history.back();"><img
					border="0" src="images/bu_back.gif" align="absmiddle" width="50"
					height="15"></a>&nbsp; <a href="SERV_Home.jsp"><img border="0"
					src="images/bu_home.gif" align="absmiddle" width="50" height="15"></a></td>
			</tr>
		</table>
		</td>
	</tr>
</table>

<br style="font-size: 30pt">

<TABLE border=0 cellspacing=0 cellpadding=0 width="100%">
	<tr>
		<td width="100%" class="copyright" align="center">Best viewed with
		800x600 screen resolution on&nbsp;an Internet Explorer version 5 และ
		5.5 <br>
		ติดต่อสอบถามได้ที่ : <a href="mailto:Administrator@lh.co.th">Administrator@lh.co.th</a>&nbsp;
		หรือ โทร. 0-2230-8279 (คุณประพัฒน์ ฝ่ายบริการ)&nbsp; 0-2230-8491-5
		(ฝ่าย IT) <br>
		<img src="images/copyright.gif" width="475" height="26"></td>
	</tr>
</TABLE>
</FORM>
</BODY>
</HTML>
