package com.svc.call.dao.services;
import java.sql.Connection;
import java.util.List;
import com.svc.call.bean.CustomerBean;
import com.svc.call.bean.ESER_DATE;
import com.svc.call.bean.SVC_DOCDT;
import com.svc.call.bean.SVC_DOCHD;
import com.svc.call.bean.SVC_STDPJ;
import com.svc.call.bean.SVC_TELNO;

public interface ServiceCenterCallService {
	
	public  CustomerBean GetProjectOfCustomerByHose$Lock(Connection conn,String comId,String projId,String houseNo,String lock); 
	public  SVC_TELNO GetSVC$TELNO(Connection conn,String comId,String projId,String telNo); 
	public  SVC_DOCDT GetSVC_DOCDT(Connection conn, String docNo,String type,String code,String fdate,String status); 
	public  SVC_STDPJ GetSVC_STDPJ(Connection conn,String comId,String projectId);
	public  List ListHistoryContactDocHD(Connection conn, String comId, String projId, String lock); 
	public  List ListHistoryContactDocHD$Paging(Connection conn, String comId, String projId, String lock,int startRow,int endRow,int maxRow);
	public  List ListSCV$DOCDT(Connection conn,String docId);
	public  List ListAppointDate$SVC(Connection conn,String comId,String projId,String i_type);
	public  List ListAppointTime$1SVC(Connection conn,String comId,String projId,String i_type,String dateStr);
	public  List ListHistoryHomeRepairPaging$1Y(Connection conn, String comId,String projId,String houseId,String lock,int startRow,int endRow,int maxRow); 
	public  List ListCustomerDetail$1Y(Connection conn, String comId, String projId, String lock);
	public  List ListSearchMobile$CTASIA(Connection conn, String tel); 	
	public  String GenerateAutoID_SVC_DOCHD(Connection conn); 
	public  String GenerateAutoID_SERV_DOCHD(Connection conn,String comId,String projectId); 
	public  String GetStatus$SERV_DOCDT(Connection conn, String docId); 
	public  boolean IsDuplicate$SVC_TELNO(Connection conn, String tel,String comId,String  projectId);	
	public  int GenerateOpenJob$SERV_DOCHD(Connection conn,String autoId, String comId, String projectId, String lock, String nCustomer, String nCustel, String employId,String desc);
	public  int InsertSVC_DOCHD(Connection conn,SVC_DOCHD obj);
	public  int InsertSVC_DOCDT(Connection conn,SVC_DOCHD obj);
	public  int InsertSVC_TELNO(Connection conn,SVC_TELNO obj); 
	public  int UpdateSVC_TELNO(Connection conn,SVC_TELNO obj); 
	public  int UpdateESER_DATE(Connection conn,ESER_DATE obj);
	public  int UpdateSVC_DOCDT(Connection conn,SVC_DOCDT obj);  
	public  int GetCountRowByHistoryContactDocHD(Connection conn, String comId, String projId, String lock);
	public  int GetCountRowByHistoryHomeRepair$1Y(Connection conn, String comId,String projId,String houseId,String lock); 	
	public  void RestoreESER_DATE(Connection conn, String docId,String employId);
	
}
