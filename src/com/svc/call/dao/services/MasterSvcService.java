package com.svc.call.dao.services;
import java.sql.Connection;
import java.util.List;

public interface MasterSvcService {
	
	public  List ListProjectAllByBudget(Connection conn);
	public  String GetEmployIdByAgentId(Connection conn, String agentid); 
	public  String GetNameEmployByAgentId(Connection conn, String employId); 
	public  List ListSearchProjectAllByBudget(Connection conn, String criteria); 
	public  String GetNameEmploy(Connection conn, String employId);
	public  List ListGroupHomeRepair(Connection conn);//01,01
	public  List ListGroupThePublicService(Connection conn);//03,01
	public  List ListGroupNameStandard(Connection conn);
	

}
